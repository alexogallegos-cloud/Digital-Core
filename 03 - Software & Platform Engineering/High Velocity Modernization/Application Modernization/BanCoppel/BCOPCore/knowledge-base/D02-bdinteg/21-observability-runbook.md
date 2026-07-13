# D02 · Integración y Autenticación — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** Integración y AutenticaciónService
> **Wave:** Wave 5 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Arquitectura de observabilidad

```
[Integración y AutenticaciónService (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard]
        │
        ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]
```

## Métricas clave (Golden Signals)

### 1. Latency — SPs principales

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---------------------|--------------------|--------------------|-----|
| `sp_cnsif_confirmaejecutivo` | `bancoppel.bdinteg.cnsif_confirmaejecutivo.latency` | `bancoppel.bdinteg.cnsif_confirmaejecutivo.errors` | [SME-PENDING] ms |
| `sp_cnsif_permisosejecutivo` | `bancoppel.bdinteg.cnsif_permisosejecutivo.latency` | `bancoppel.bdinteg.cnsif_permisosejecutivo.errors` | [SME-PENDING] ms |
| `sp_valida_perfil_usuario` | `bancoppel.bdinteg.valida_perfil_usuario.latency` | `bancoppel.bdinteg.valida_perfil_usuario.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdinteg.requests.total` | Custom | Total de requests al microservicio |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | 🟠 WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | 🔴 CRITICAL |
| `bancoppel.bdinteg.errors.l4` (divergencias financieras) | > 0 | 🔴 CRITICAL (rollback) |
| Aurora `DatabaseConnections` | > 80% del max | 🟠 WARNING |
| Aurora `FreeLocalStorage` | < 20% | 🟠 WARNING |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---------|---------|--------|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Latencia p50/p95/p99", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "latency.p50"], ["bancoppel/bdinteg", "latency.p99"]]},
  {"title": "Error rate", "type": "metric",
    "metrics": [["bancoppel/bdinteg", "errors.total"], ["bancoppel/bdinteg", "errors.l4"]]},
  {"title": "Throughput", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdinteg-service"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdinteg-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

## Runbook de incidentes

### INC-D02-01: Alta latencia en endpoints

```
DETECTAR: Alarma CloudWatch latency.p99 > SLO + 20%
DIAGNOSTICAR:
  1. CloudWatch Insights: filtrar logs por RequestId de los requests lentos
  2. X-Ray: identificar el tramo más lento en el trace
  3. Aurora: verificar `aurora_db_instance_identifier` — ¿hay slow queries?
  4. Lambda: verificar cold starts (init_duration en logs)
RESOLVER:
  A. Si cold start: activar Lambda SnapStart o aumentar concurrencia reservada
  B. Si Aurora slow query: revisar explain plan, agregar índice
  C. Si MSK lag: escalar particiones del topic
ESCALAR si no resuelve en 30 min: SRE Lead + Cloud Architect AWS
```

### INC-D02-02: Divergencias financieras (L4)

```
DETECTAR: Alarma bancoppel.bdinteg.errors.l4 > 0
ACCIÓN INMEDIATA:
  1. ROLLBACK automático: AppConfig feature flag al 0%
  2. Tráfico vuelve a Informix
  3. Notificación a: QA Lead + Domain Expert BanCoppel + Program Manager
DIAGNOSTICAR (post-rollback):
  1. Identificar el SP y los parámetros exactos que generaron la divergencia
  2. Verificar si es MONEY rounding (RoundingMode.HALF_EVEN)
  3. Verificar si es DATETIME timezone
  4. Agregar caso de prueba al golden master
ESCALAR: QA Lead + Specialist Informix SPL Analysis
```

### INC-D02-03: Falla total del microservicio

```
DETECTAR: Lambda Errors = 100% o Health Check falla
DIAGNOSTICAR:
  1. CloudWatch Logs: buscar stack trace en últimos 5 min
  2. Aurora: verificar disponibilidad (failover si aplica)
  3. AppConfig: verificar que feature flag no cambió inesperadamente
RESOLVER:
  A. Si Lambda falla: redeploy de la versión anterior (CodeDeploy rollback)
  B. Si Aurora: activar failover manual a réplica
  C. Si es incidente crítico: ejecutar DR plan
RTO target: < 30 min (CNBV requirement para sistemas críticos)
```

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-03T22:00:00.000-06:00",
  "level": "INFO",
  "service": "bdinteg-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_nombre_equivalente",
  "domain": "bdinteg",
  "wave": "Wave 5",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, correo, celular). Solo loguear identificadores anonimizados.

---
*Generado por: SRE & AIOps · 2026-07-03 · [SME-PENDING] umbrales de alarma requieren validación con baseline real de QA Lead*

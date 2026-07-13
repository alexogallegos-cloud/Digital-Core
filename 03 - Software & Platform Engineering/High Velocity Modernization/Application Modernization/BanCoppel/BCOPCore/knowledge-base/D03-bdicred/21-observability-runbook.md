# D03 · Créditos — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** CréditosService
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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
[CréditosService (Lambda/ECS)]
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
| `sp_consulta_saldos_general` | `bancoppel.bdicred.consulta_saldos_general.latency` | `bancoppel.bdicred.consulta_saldos_general.errors` | [SME-PENDING] ms |
| `sp_mon_buro_conssolcredlincred2` | `bancoppel.bdicred.mon_buro_conssolcredlincred2.latency` | `bancoppel.bdicred.mon_buro_conssolcredlincred2.errors` | [SME-PENDING] ms |
| `sp_inserta_productos` | `bancoppel.bdicred.inserta_productos.latency` | `bancoppel.bdicred.inserta_productos.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdicred.requests.total` | Custom | Total de requests al microservicio |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | 🟠 WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | 🔴 CRITICAL |
| `bancoppel.bdicred.errors.l4` (divergencias financieras) | > 0 | 🔴 CRITICAL (rollback) |
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
    "metrics": [["bancoppel/bdicred", "latency.p50"], ["bancoppel/bdicred", "latency.p99"]]},
  {"title": "Error rate", "type": "metric",
    "metrics": [["bancoppel/bdicred", "errors.total"], ["bancoppel/bdicred", "errors.l4"]]},
  {"title": "Throughput", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdicred-service"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdicred-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

## Runbook de incidentes

### INC-D03-01: Alta latencia en endpoints

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

### INC-D03-02: Divergencias financieras (L4)

```
DETECTAR: Alarma bancoppel.bdicred.errors.l4 > 0
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

### INC-D03-03: Falla total del microservicio

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
  "service": "bdicred-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_nombre_equivalente",
  "domain": "bdicred",
  "wave": "Wave 4",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, correo, celular). Solo loguear identificadores anonimizados.

---
*Generado por: SRE & AIOps · 2026-07-03 · [SME-PENDING] umbrales de alarma requieren validación con baseline real de QA Lead*

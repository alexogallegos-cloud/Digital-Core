# D01 · Canal Digital Web — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** Canal Digital WebService
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
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
[Canal Digital WebService (Lambda/ECS)]
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
| `sp_split_cadena` | `bancoppel.bdicnweb.split_cadena.latency` | `bancoppel.bdicnweb.split_cadena.errors` | [SME-PENDING] ms |
| `sp_ope_consultarutalmacenamientoxml` | `bancoppel.bdicnweb.ope_consultarutalmacenamientoxml.latency` | `bancoppel.bdicnweb.ope_consultarutalmacenamientoxml.errors` | [SME-PENDING] ms |
| `sp_bitacora` | `bancoppel.bdicnweb.bitacora.latency` | `bancoppel.bdicnweb.bitacora.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdicnweb.requests.total` | Custom | Total de requests al microservicio |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | 🟠 WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | 🔴 CRITICAL |
| `bancoppel.bdicnweb.errors.l4` (divergencias financieras) | > 0 | 🔴 CRITICAL (rollback) |
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
    "metrics": [["bancoppel/bdicnweb", "latency.p50"], ["bancoppel/bdicnweb", "latency.p99"]]},
  {"title": "Error rate", "type": "metric",
    "metrics": [["bancoppel/bdicnweb", "errors.total"], ["bancoppel/bdicnweb", "errors.l4"]]},
  {"title": "Throughput", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdicnweb-service"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdicnweb-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

## Runbook de incidentes

### INC-D01-01: Alta latencia en endpoints

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

### INC-D01-02: Divergencias financieras (L4)

```
DETECTAR: Alarma bancoppel.bdicnweb.errors.l4 > 0
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

### INC-D01-03: Falla total del microservicio

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

### INC-D01-04 — 2 defectos activos DEFECTO-PROD en componente P655 (N5)

> **Diagnóstico completo**: [inc-003-d01-defecto-prod.html](../../portal/incidents/inc-003-d01-defecto-prod.html)

> **Ver risk register:** `migration-risk-register.md` · P655-R001 · P655-R002

**Impacto funcional:** Dos defectos activos en producción en el dominio Canal Digital Web. Bloquean el avance a DESIGN — ninguna wave del dominio puede progresar hasta que los defectos sean validados y mitigados.

**Causa raíz (desde risk register):**
- P655-R001: primer DEFECTO-PROD activo en el componente P655. Detalles pendientes de sesión de validación con DBA IBM Informix y Core Banking Transformation.
- P655-R002: segundo DEFECTO-PROD activo en el componente P655. Detalles pendientes de sesión de validación con los mismos SMEs.
- Categoría: TAR (Target Architecture Risk). Ambos defectos están en D01-bdicnweb y son clasificados como N5 — nivel máximo del registro.

**SPs afectados:** pendientes de identificar en sesión de validación con DBA IBM Informix.

**Estado:** BLOQUEANTE — bloquea avance a DESIGN. No iniciar ninguna wave de D01 hasta que ambos defectos tengan plan de mitigación aprobado (regla de bloqueo del risk register).

**Acción inmediata:**
1. Convocar sesión de validación con DBA IBM Informix IDS y Core Banking Transformation.
2. Clasificar el alcance de cada defecto: ¿cuáles SPs están afectados? ¿cuál es el impacto en producción actual?
3. Documentar en este runbook los SPs afectados y el plan de mitigación una vez identificados.
4. Actualizar el risk register (`migration-risk-register.md`) con el resultado de la sesión.

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-03T22:00:00.000-06:00",
  "level": "INFO",
  "service": "bdicnweb-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_nombre_equivalente",
  "domain": "bdicnweb",
  "wave": "ÚLTIMO",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, correo, celular). Solo loguear identificadores anonimizados.

---
*Generado por: SRE & AIOps · 2026-07-03 · [SME-PENDING] umbrales de alarma requieren validación con baseline real de QA Lead*

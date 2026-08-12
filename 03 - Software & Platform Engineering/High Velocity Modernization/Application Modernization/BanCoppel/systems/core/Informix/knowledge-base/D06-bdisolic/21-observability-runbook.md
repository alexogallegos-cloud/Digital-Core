# D06 · bdisolic (Solicitudes / Scoring) — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** SolicitudesYScoringService
> **Wave:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-31
> **Inventario:** 84 SPs · 65,541 LOC · 710 campos MONEY · 250 cross-DB calls
> **God procedures:** `califica_scoring2_cjunk` (3,068 LOC, 167 callers) · `determina_lincred_tc_cjunk` (1,832 LOC, 208 callers)
> **Cross-DB top:** bdicred 89 · bdinteg 81 · bdimnsj 23
> **Sistemas llamantes (logs):** AU_PPCOPPEL (PrestamoPersonal) · OFI_WEB

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional de scoring y crédito)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Arquitectura de observabilidad

```
[AU_PPCOPPEL / PrestamoPersonal]   [OFI_WEB]
              │                        │
              └────────────┬───────────┘
                           ▼
          [SolicitudesYScoringService (Lambda/ECS)]
                    │  structured logs (JSON)
                    ▼
          [CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard]
                    │
                    ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
                    │
                    └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace custom: bancoppel.bdisolic.*
Cross-DB monitoreado:
  bdisolic → bdicred  (89 calls — principal dependencia de scoring)
  bdisolic → bdinteg  (81 calls)
  bdisolic → bdimnsj  (23 calls)
```

---

## Métricas clave (Golden Signals)

### 1. Latency — God procedures

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---|---|---|---|
| `califica_scoring2_cjunk` | `bancoppel.bdisolic.califica_scoring2_cjunk.latency` | `bancoppel.bdisolic.califica_scoring2_cjunk.errors` | [SME-PENDING] ms |
| `determina_lincred_tc_cjunk` | `bancoppel.bdisolic.determina_lincred_tc_cjunk.latency` | `bancoppel.bdisolic.determina_lincred_tc_cjunk.errors` | [SME-PENDING] ms |

> Verificar lógica de cada SP en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar umbrales.

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---|---|---|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdisolic.requests.total` | Custom | Total de requests al microservicio |
| `bancoppel.bdisolic.scoring.requests` | Custom | Solicitudes de crédito nuevas procesadas por scoring |
| `bancoppel.bdisolic.crossdb.bdicred.calls` | Custom | Cross-DB calls hacia bdicred (89 baseline) |
| `bancoppel.bdisolic.crossdb.bdinteg.calls` | Custom | Cross-DB calls hacia bdinteg (81 baseline) |
| `bancoppel.bdisolic.crossdb.bdimnsj.calls` | Custom | Cross-DB calls hacia bdimnsj (23 baseline) |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---|---|---|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdisolic.califica_scoring2_cjunk.errors` | > 0 en 1 min | CRITICAL — scoring caído |
| `bancoppel.bdisolic.determina_lincred_tc_cjunk.errors` | > 0 en 1 min | CRITICAL — línea de crédito no visible |
| `bancoppel.bdisolic.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL — rollback inmediato |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---|---|---|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB bdicred | latency p99 | Alerta si bdicred degradado — 89 calls de scoring en riesgo |

---

## Patrones de carga validados desde logs de producción

| Ventana | Descripción | Impacto en bdisolic |
|---|---|---|
| **Peak:** 10:00–14:00 CDMX | Solicitudes de crédito y préstamos personales en horario bancario | `califica_scoring2_cjunk` y `determina_lincred_tc_cjunk` bajo carga máxima; AU_PPCOPPEL activo |
| **Off-peak:** 02:00–06:00 CDMX | Tráfico mínimo; ventana preferida para deploys | Volumen bajo; safe para mantenimiento y ajuste de modelos |
| **Batch:** 22:00–02:00 CDMX | Procesos nocturnos de scoring diferido y actualización de líneas | Ejecutar con monitoreo activo por dependencia con bdicred |

> Escenario de riesgo: `califica_scoring2_cjunk` tiene 167 callers y `determina_lincred_tc_cjunk` tiene 208 callers. Un fallo en peak hora equivale a bloquear todas las solicitudes de crédito nuevas del sistema.

---

## Ruido de fondo conocido — NO es incidente

| Evento | Origen | Código | Frecuencia | Acción |
|---|---|---|---|---|
| NullPointerException background | Huellas442 | 4395 | Cada ~60 s aprox. | Ignorar — issue pre-existente conocido; no crear ticket |

> Filtrar en CloudWatch Insights: `filter @message not like /4395/ and source != "Huellas442"` para no saturar alarmas operativas.

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Scoring califica_scoring2_cjunk p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdisolic", "califica_scoring2_cjunk.latency.p50"],
                ["bancoppel/bdisolic", "califica_scoring2_cjunk.latency.p99"]]},
  {"title": "Línea de crédito determina_lincred_tc_cjunk p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdisolic", "determina_lincred_tc_cjunk.latency.p50"],
                ["bancoppel/bdisolic", "determina_lincred_tc_cjunk.latency.p99"]]},
  {"title": "Error rate total + L4 MONEY", "type": "metric",
    "metrics": [["bancoppel/bdisolic", "errors.total"],
                ["bancoppel/bdisolic", "errors.l4"]]},
  {"title": "Throughput scoring (Invocations)", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdisolic-service"]]},
  {"title": "Cross-DB calls bdicred / bdinteg / bdimnsj", "type": "metric",
    "metrics": [["bancoppel/bdisolic", "crossdb.bdicred.calls"],
                ["bancoppel/bdisolic", "crossdb.bdinteg.calls"],
                ["bancoppel/bdisolic", "crossdb.bdimnsj.calls"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdisolic-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D06-01: Motor de scoring caído — `califica_scoring2_cjunk` no responde

```
CONTEXTO:
  - califica_scoring2_cjunk: 3,068 LOC · 167 callers
  - Impacto: todas las solicitudes de crédito nuevas fallan simultáneamente
  - Sistemas afectados: AU_PPCOPPEL (PrestamoPersonal) + OFI_WEB
  - Ventana crítica: peak 10:00–14:00 CDMX

DETECTAR:
  - Alarma bancoppel.bdisolic.califica_scoring2_cjunk.errors > 0 en 1 min
  - Alarma bancoppel.bdisolic.scoring.requests cae a 0 (scoring detenido)
  - AU_PPCOPPEL y OFI_WEB reportan errores en logs de caller

DIAGNOSTICAR:
  1. brain.py — identificar callers activos y dependencias del SP:
       python BCOPCore/digital-brain/brain.py callers "califica_scoring2_cjunk"
       python BCOPCore/digital-brain/brain.py search "califica_scoring2_cjunk"

  2. Verificar si bdicred (D03) está respondiendo — bdisolic hace 89 cross-DB
     a bdicred; si bdicred está degradado el scoring no puede completar la
     calificación → ver INC-D06-03:
       python BCOPCore/digital-brain/brain.py search "bdicred"

  3. Revisar lógica interna del SP en:
       source/BCOPCore/informix/califica_scoring2_cjunk.sql
     Identificar paths de error, cursores, y dependencias de tablas

  4. X-Ray: localizar el tramo exacto de falla en el trace del SP

  5. CloudWatch Insights — frecuencia de errores por ventana de tiempo:
       fields @timestamp, @message
       | filter operation = "califica_scoring2_cjunk"
       | filter @message like /ERROR/
       | sort @timestamp desc
       | limit 50

RESOLVER:
  A. Si bdicred degradado: escalar a equipo D03-bdicred; activar respuesta
     degradada de scoring hasta restaurar la dependencia
  B. Si error interno del SP: activar AppConfig feature flag al 0%
     (rollback al Informix legacy) — 167 callers vuelven al sistema legacy
  C. Si Aurora saturado: escalar concurrencia reservada de Lambda;
     revisar connection pooling
  D. Notificar a AU_PPCOPPEL y OFI_WEB del modo degradado activo

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel + QA Lead
RTO: < 30 min (CNBV — sistema bancario crítico)
```

### INC-D06-02: Línea de crédito indeterminada — `determina_lincred_tc_cjunk` timeout

```
CONTEXTO:
  - determina_lincred_tc_cjunk: 1,832 LOC · 208 callers
  - Impacto: clientes no pueden ver su línea de crédito disponible
  - 208 callers = mayor fanout de god procedures en D06
  - Ventana crítica: peak 10:00–14:00 CDMX cuando clientes consultan crédito

DETECTAR:
  - Alarma bancoppel.bdisolic.determina_lincred_tc_cjunk.latency.p99 > SLO + 20%
  - Alarma bancoppel.bdisolic.determina_lincred_tc_cjunk.errors > 0 en 1 min
  - Múltiples callers de OFI_WEB reportando timeout simultáneamente

DIAGNOSTICAR:
  1. brain.py — mapear los 208 callers para priorizar impacto:
       python BCOPCore/digital-brain/brain.py callers "determina_lincred_tc_cjunk"

  2. Revisar lógica del SP en:
       source/BCOPCore/informix/determina_lincred_tc_cjunk.sql
     Con 1,832 LOC y 208 callers, identificar si hay paths de ejecución
     costosos que solo se activan con ciertos parámetros de entrada

  3. X-Ray: identificar si el timeout ocurre en bdisolic → bdicred cross-DB
     (89 calls) o dentro del propio SP en Aurora

  4. Aurora: verificar si hay cambio de plan de ejecución por estadísticas;
     si la cardinalidad cambió repentinamente el SP puede tomar un plan subóptimo

  5. Verificar correlación con carga pico de AU_PPCOPPEL en horario peak

RESOLVER:
  A. Si Aurora slow query: revisar explain plan; escalar a DBA IDS para
     analizar estadísticas equivalentes en el sistema Informix legacy
  B. Si timeout bajo carga de 208 callers simultáneos: implementar queue
     con throttle en SolicitudesYScoringService ([SME-PENDING] Domain Expert)
  C. Si cross-DB bdicred es la causa: ver INC-D06-03
  D. Rollback al Informix legacy: AppConfig feature flag al 0%

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel
RTO: < 30 min (CNBV — sistema bancario crítico)
```

### INC-D06-03: Cascada scoring → bdicred — bdisolic pierde acceso a crédito

```
CONTEXTO:
  - bdisolic hace 89 cross-DB calls a bdicred (D03)
  - Si bdicred está degradado, califica_scoring2_cjunk no puede completar
    la calificación crediticia → bloqueo total del motor de scoring
  - bdisolic también hace 81 cross-DB a bdinteg — degradación doble posible

DETECTAR:
  - Alarma bancoppel.bdisolic.crossdb.bdicred.calls cae bruscamente
  - Alarma bancoppel.bdisolic.califica_scoring2_cjunk.errors > 0 correlacionado
    con alertas de D03-bdicred
  - X-Ray muestra latencia elevada únicamente en el tramo cross-DB hacia bdicred

DIAGNOSTICAR:
  1. Confirmar estado de bdicred (D03):
       python BCOPCore/digital-brain/brain.py search "bdicred"
     Verificar si la alarma proviene de D03 o si es error de conexión cross-DB
     en la capa de SolicitudesYScoringService

  2. brain.py — identificar qué SPs de bdisolic disparan las 89 calls a bdicred:
       python BCOPCore/digital-brain/brain.py crossdb "bdisolic" "bdicred"

  3. CloudWatch Insights — aislar errores de cross-DB:
       fields @timestamp, @message
       | filter domain = "bdisolic"
       | filter @message like /bdicred/
       | sort @timestamp desc
       | limit 50

  4. Verificar si bdinteg (81 calls) también está degradado simultáneamente;
     degradación doble indica posible incidente de infraestructura más amplio

RESOLVER:
  A. Escalar a equipo D03-bdicred como incidente externo; no hay fix local
     en bdisolic para la dependencia cross-DB
  B. Mientras bdicred está degradado: activar respuesta de scoring con datos
     de caché si existe ([SME-PENDING] verificar si hay caché de líneas de crédito)
  C. Si tanto bdicred como bdinteg están degradados simultáneamente: activar
     rollback total al Informix legacy (AppConfig feature flag al 0%)
  D. Revisar lógica de los SPs involucrados para identificar si los cross-DB
     son indispensables o tienen fallback definido:
       source/BCOPCore/informix/califica_scoring2_cjunk.sql
       source/BCOPCore/informix/determina_lincred_tc_cjunk.sql

ESCALAR si no resuelve en 30 min: SRE Lead + equipo D03-bdicred + Program Manager
RTO: < 30 min (CNBV — sistema bancario crítico)
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdisolic-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "califica_scoring2_cjunk",
  "domain": "bdisolic",
  "wave": "Wave 3",
  "callingSystem": "AU_PPCOPPEL",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, score crediticio, correo, celular). Solo loguear identificadores anonimizados. El resultado del scoring es dato sensible — loguear únicamente el outcome categórico (APROBADO / RECHAZADO / PENDIENTE), nunca el valor numérico del score.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales SLO requieren validación con baseline real de QA Lead + Domain Expert BanCoppel.*
*Lógica de SPs: verificar en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar cualquier umbral o implementar fix.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 20.05% (CRÍTICO — revisar)


### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Alerta sugerida |
|----|-------------|--------|-----------------|
| `sp_obtienedatos_reevaluacion_web` | 227 | 100.0% | Alerta si error_rate > 50.0% en 5 min |
| `sp_determina_linea_pre_aprobados` | 6,564 | 95.95% | Alerta si error_rate > 48.0% en 5 min |
| `sp_prepara_buro_preaprobados` | 443 | 41.08% | Alerta si error_rate > 20.5% en 5 min |
| `sp_generareportepp_web` | 4,609 | 38.32% | Alerta si error_rate > 19.2% en 5 min |
| `sp_verifica_pre_aprobados` | 751 | 37.42% | Alerta si error_rate > 18.7% en 5 min |
| `sp_consulta_status_solic_wsp` | 3,252 | 9.78% | Alerta si error_rate > 4.9% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

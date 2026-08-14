# D05 · bdisac (Saldos y Cuentas) — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** SaldosYCuentasService
> **Wave:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-31
> **Inventario:** 145 SPs · 378,076 LOC · 22,232 campos MONEY · 642 cross-DB calls
> **God procedures:** `sp_reportebts_edocta` (10,152 LOC, 52 callers) · `sp_grabapagocoppel` (7,295 LOC, 23 callers)
> **Cross-DB top:** bdicheq 331 (52%) · bdinteg 145
> **Sistemas llamantes (logs):** OFI_WEB · REM_AUT_APZ (RemesasWU)

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional de saldos y cuentas)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Arquitectura de observabilidad

```
[OFI_WEB]          [REM_AUT_APZ / RemesasWU]
     │                        │  (DSN: ifx_bdisac_remesas)
     └────────────┬───────────┘
                  ▼
     [SaldosYCuentasService (Lambda/ECS)]
             │  structured logs (JSON)
             ▼
     [CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard]
             │
             ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
             │
             └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace custom: bancoppel.bdisac.*
Cross-DB monitoreado: bdisac → bdicheq (331 calls · 52%) · bdinteg (145 calls)
```

---

## Métricas clave (Golden Signals)

### 1. Latency — God procedures y SPs críticos confirmados en logs

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---|---|---|---|
| `sp_reportebts_edocta` | `bancoppel.bdisac.reportebts_edocta.latency` | `bancoppel.bdisac.reportebts_edocta.errors` | [SME-PENDING] ms |
| `sp_grabapagocoppel` | `bancoppel.bdisac.grabapagocoppel.latency` | `bancoppel.bdisac.grabapagocoppel.errors` | [SME-PENDING] ms |
| `sp_consulta_wu_web` | `bancoppel.bdisac.consulta_wu_web.latency` | `bancoppel.bdisac.consulta_wu_web.errors` | [SME-PENDING] ms |

> Verificar lógica de cada SP en `source/informix/{sp_name}.sql` antes de ajustar umbrales.

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---|---|---|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdisac.requests.total` | Custom | Total de requests al microservicio |
| `bancoppel.bdisac.crossdb.bdicheq.calls` | Custom | Cross-DB calls hacia bdicheq (331 baseline) |
| `bancoppel.bdisac.crossdb.bdinteg.calls` | Custom | Cross-DB calls hacia bdinteg (145 baseline) |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---|---|---|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdisac.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL — rollback inmediato |
| `bancoppel.bdisac.reportebts_edocta.latency.p99` | > SLO + 20% en fecha de corte | CRITICAL |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |

> **MONEY = 22,232** — el campo monetario con mayor densidad del sistema. Cualquier divergencia de redondeo escala directamente a CNBV. Usar `RoundingMode.HALF_EVEN` sin excepción.

### 4. Saturation

| Recurso | Métrica | Umbral |
|---|---|---|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB bdicheq | latency p99 | Alerta si bdicheq degradado — 331 calls en riesgo |

---

## Patrones de carga validados desde logs de producción

| Ventana | Descripción | Impacto en bdisac |
|---|---|---|
| **Peak:** 10:00–14:00 CDMX | Horario bancario pleno; OFI_WEB y sucursales activos | `sp_grabapagocoppel` bajo carga máxima |
| **Off-peak:** 02:00–06:00 CDMX | Tráfico mínimo; ventana preferida para deploys | Volumen bajo; safe para mantenimiento |
| **Batch:** 22:00–02:00 CDMX | Procesos nocturnos; cierres de cuentas y estados de cuenta | `sp_reportebts_edocta` puede ejecutarse masivamente en fecha de corte |

> Escenario de riesgo especial: en fecha de corte mensual, `sp_reportebts_edocta` (52 callers, 10,152 LOC) puede recibir spike de volumen simultáneo durante el batch o al inicio del peak del día siguiente.

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
  {"title": "Latencia sp_reportebts_edocta p50/p95/p99", "type": "metric",
    "metrics": [["bancoppel/bdisac", "reportebts_edocta.latency.p50"],
                ["bancoppel/bdisac", "reportebts_edocta.latency.p99"]]},
  {"title": "Latencia sp_grabapagocoppel p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdisac", "grabapagocoppel.latency.p50"],
                ["bancoppel/bdisac", "grabapagocoppel.latency.p99"]]},
  {"title": "Latencia sp_consulta_wu_web p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdisac", "consulta_wu_web.latency.p50"],
                ["bancoppel/bdisac", "consulta_wu_web.latency.p99"]]},
  {"title": "Error rate total + L4 MONEY", "type": "metric",
    "metrics": [["bancoppel/bdisac", "errors.total"],
                ["bancoppel/bdisac", "errors.l4"]]},
  {"title": "Throughput (Invocations)", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdisac-service"]]},
  {"title": "Cross-DB calls bdicheq / bdinteg", "type": "metric",
    "metrics": [["bancoppel/bdisac", "crossdb.bdicheq.calls"],
                ["bancoppel/bdisac", "crossdb.bdinteg.calls"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdisac-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D05-01: Estado de cuenta masivo — timeout en `sp_reportebts_edocta`

```
CONTEXTO:
  - sp_reportebts_edocta: 10,152 LOC · 52 callers
  - Trigger probable: fecha de corte mensual (spike simultáneo de 52 callers)
  - Ventana crítica: batch 22:00–02:00 CDMX o peak 10:00–14:00 CDMX siguiente día

DETECTAR:
  - Alarma bancoppel.bdisac.reportebts_edocta.latency.p99 > SLO + 20%
  - CloudWatch Logs: errores de timeout en logs de OFI_WEB
  - Múltiples traceIds con duración > [SME-PENDING] ms en X-Ray

DIAGNOSTICAR:
  1. brain.py — identificar callers activos:
       python Informix/digital-brain/brain.py callers "sp_reportebts_edocta"
     Confirmar cuáles de los 52 callers están ejecutando en paralelo

  2. CloudWatch Insights — correlacionar spike con fecha de corte:
       fields @timestamp, @message
       | filter operation = "sp_reportebts_edocta"
       | stats count() by bin(5m)

  3. Aurora — verificar slow queries generadas por el SP (10,152 LOC implica
     múltiples cursores anidados); revisar lógica completa en:
       source/informix/sp_reportebts_edocta.sql

  4. Verificar si bdicheq está respondiendo (331 cross-DB calls en riesgo)

RESOLVER:
  A. Corto plazo: activar circuit breaker en SaldosYCuentasService para
     sp_reportebts_edocta; retornar HTTP 503 con Retry-After a los callers
  B. Si Aurora degradado: failover manual a réplica de lectura
  C. Distribuir carga: si 52 callers ejecutan simultáneamente, implementar
     queue con throttle en fecha de corte ([SME-PENDING] validar con Domain Expert)
  D. Rollback al Informix legacy: AppConfig feature flag al 0%

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel + QA Lead
RTO: < 30 min (CNBV — sistema bancario crítico)
```

### INC-D05-02: Falla en pago Coppel — `sp_grabapagocoppel` no procesa

```
CONTEXTO:
  - sp_grabapagocoppel: 7,295 LOC · 23 callers
  - Confirmado en logs de producción como SP activo
  - Impacto: pagos en sucursal quedan en limbo; cliente sin confirmación
  - Ventana crítica: peak 10:00–14:00 CDMX (horario de sucursales)

DETECTAR:
  - Alarma bancoppel.bdisac.grabapagocoppel.errors > 0 en 1 min
  - Alarma bancoppel.bdisac.grabapagocoppel.latency.p99 > SLO + 20%
  - Llamadas entrantes de OFI_WEB acumulándose sin respuesta

DIAGNOSTICAR:
  1. brain.py — verificar dependencias del SP:
       python Informix/digital-brain/brain.py search "sp_grabapagocoppel"
       python Informix/digital-brain/brain.py callers "sp_grabapagocoppel"

  2. Revisar lógica de transacción en:
       source/informix/sp_grabapagocoppel.sql
     Identificar si el SP hace BEGIN WORK y si hay transacción abierta sin COMMIT

  3. X-Ray: identificar en qué tramo del SP falla (7,295 LOC — múltiples paths)

  4. Verificar cross-DB hacia bdicheq (331 calls totales de bdisac):
     si bdicheq está degradado, sp_grabapagocoppel puede estar esperando lock

  5. Aurora: buscar transacciones bloqueadas o locks por pagos incompletos

RESOLVER:
  A. Si transacción abierta sin COMMIT: ejecutar rollback del pago en limbo
     (coordinar con Domain Expert BanCoppel antes de cualquier DML manual)
  B. Si bdicheq degradado: escalar a equipo D04-bdicheq; bdisac depende 52%
     de bdicheq para cross-DB
  C. Activar modo degradado: deshabilitar temporalmente pagos Coppel vía
     AppConfig flag hasta restaurar el SP
  D. Notificar a sucursales afectadas (canal OFI_WEB) del estado

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel
RTO: < 30 min (CNBV — sistema bancario crítico)
```

### INC-D05-03: Caída de remesas WU — `sp_consulta_wu_web` via DSN `ifx_bdisac_remesas`

```
CONTEXTO:
  - sp_consulta_wu_web confirmado en logs de producción (DSN: ifx_bdisac_remesas)
  - Sistema llamante: REM_AUT_APZ (RemesasWU)
  - MONEY = 22,232 — densidad más alta del sistema BanCoppel
  - Cualquier discrepancia de redondeo en montos de remesas escala a CNBV

DETECTAR:
  - Alarma bancoppel.bdisac.consulta_wu_web.errors > 0 en 1 min
  - Logs de REM_AUT_APZ reportan timeout o SQLCODE de error en DSN
  - bancoppel.bdisac.errors.l4 > 0 (divergencia financiera en MONEY)

DIAGNOSTICAR:
  1. Verificar conectividad del DSN ifx_bdisac_remesas:
       python Informix/digital-brain/brain.py search "sp_consulta_wu_web"
       python Informix/digital-brain/brain.py search "ifx_bdisac_remesas"

  2. Revisar lógica del SP en:
       source/informix/sp_consulta_wu_web.sql
     Verificar cómo maneja tipos MONEY y si hay operaciones aritméticas
     que puedan producir redondeo distinto al esperado

  3. Si errors.l4 > 0: identificar el monto exacto y el tipo de redondeo
     para reportar a CNBV con evidencia (obligatorio regulatorio)

  4. CloudWatch Insights — correlacionar errores con horario de remesas:
       fields @timestamp, @message
       | filter operation = "sp_consulta_wu_web"
       | filter @message like /ERROR/
       | sort @timestamp desc
       | limit 50

RESOLVER:
  A. Si DSN ifx_bdisac_remesas no conecta: verificar configuración de red
     y credenciales del DSN en el ambiente target; no modificar sin aprobación DBA
  B. Si divergencia MONEY (errors.l4 > 0): ROLLBACK inmediato al Informix legacy
     vía AppConfig flag; notificar a: QA Lead + Domain Expert + Cybersecurity
  C. Coordinar con QA Lead para agregar caso de prueba de redondeo al golden master
  D. Si incidente > 30 min con impacto en remesas internacionales: notificar
     a Compliance/CNBV per protocolo regulatorio

ESCALAR si no resuelve en 30 min: SRE Lead + QA Lead + Cybersecurity (CNBV)
RTO: < 30 min (CNBV — sistema bancario crítico)
NOTA REGULATORIA: MONEY=22,232 requiere trazabilidad completa de cada discrepancia.
```

### INC-D05-04: Remesa internacional atascada — loop APPRIZA sin resolución

> **Diagnóstico completo con evidencia de logs**: [inc-001-d05-appriza.html](../../portal/incidents/inc-001-d05-appriza.html)  
> Incluye: call stack, patrones de retry, risk register INC-001, cadena de causalidad y plan de remediación detallado.

```
CONTEXTO:
  - sp_app_confirmpayment: 61,280 llamadas/día vía RemesasAPPRIZAAutomaticas
  - Tasa de error APPRIZA: 8.7% (5,163/día con codRetorno=9999)
  - Patrón: excepción en ConfirmPayment.java:179 → estado PENDIENTE → batch
    reintenta indefinidamente sin circuit breaker ni max_retries
  - ~400 remesas únicas en loop por día · cada una con hasta 13 reintentos
  - ALERTA REGULATORIA: Banxico Circular 14/2017 — plazo máx. 2 días hábiles
    para notificar errores en transferencias al exterior

DETECTAR:
  - Alarma: bancoppel.bdisac.confirmpayment.errors.appriza_9999 > umbral en 5 min
  - CloudWatch Insights: transacciones en estado PENDIENTE > 2 horas
       fields @timestamp, @message
       | filter operation = "sp_app_recordorder" and estado = "PENDIENTE"
       | stats count() by bin(30m)
  - HUD de monitoreo: contador de reintentos por idTrxGlobal > 5

DIAGNOSTICAR:
  1. Verificar si APPRIZA está degradado (todos los 9999 son del mismo período):
       - Si los fallos son < 8.7% del día → fallo puntual de transacción
       - Si los fallos superan 20% en ventana de 1h → APPRIZA degradado → activar circuit breaker
  2. Revisar si el UUID de sesión sigue siendo válido:
       22e4e9ee-32ea-484e-b89f-2573549bc625 — si APPRIZA expiró el token, TODOS fallarán
  3. Verificar SSL — si hay errores 3165 en la misma ventana → certificado expirado
  4. Leer código fuente:
       source/informix/sp_app_confirmpayment.sql
       source/informix/sp_app_recordorder.sql

RESOLVER:
  A. Corto plazo (producción actual Informix):
     - Identificar remesas PENDIENTES > 2 días hábiles → notificación manual al cliente
     - Escalar a BanCoppel para verificar estado en APPRIZA directamente
     - Si UUID expirado: renovar token de sesión del proceso batch
  B. Target (post-migración):
     - Circuit breaker Resilience4j: threshold 50% errores/60s → OPEN
     - max_retries=3 con backoff exponencial (1min → 5min → 30min)
     - On max_retries: INSERT reconciliacion_remesas + notificación cliente + flag CNBV
  C. Si supera 2 días hábiles sin resolución:
     - Iniciar proceso de devolución al cliente
     - Registrar en log regulatorio CNBV per Circular 14/2017

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel + Compliance
RTO: < 2 días hábiles (Banxico Circular 14/2017) — idealmente < 4 horas operativas
RIESGO: Exposición a sanción CONDUSEF si > 2 días hábiles sin notificación al cliente
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdisac-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_grabapagocoppel",
  "domain": "bdisac",
  "wave": "Wave 3",
  "callingSystem": "OFI_WEB",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, monto exacto, correo, celular). Solo loguear identificadores anonimizados. Para remesas WU no loguear datos del beneficiario.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales SLO requieren validación con baseline real de QA Lead + Domain Expert BanCoppel.*
*Lógica de SPs: verificar en `source/informix/{sp_name}.sql` antes de ajustar cualquier umbral o implementar fix.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 4.07% (Normal)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `4395` | 1,102 | ALTA | Verificar NullPointerException en el plugin Java — revisar datos de en |
| `4394` | 714 | MEDIA | Revisar MbUserException en IIB — validar que el SP devuelve el tipo es |
| `3743` | 340 | MEDIA | Aumentar timeout en configuración del canal ESB — verificar disponibil |
| `3701` | 331 | MEDIA | Revisar endpoint SOAP — verificar que el WSDL sea accesible y la respu |
| `3166` | 7 | BAJA | Aumentar SSL timeout — verificar latencia del endpoint externo |

### SPs críticos para monitoring

> **LECTURA CORRECTA DE BASELINES (2026-08-01):** Los SPs con tasa > 50% tienen mecanismos verificados en código. Alertar si la tasa CAMBIA inesperadamente, no si es "alta". Leer la columna Mecanismo antes de crear alarmas.

| SP | Llamadas/día | Error% | Mecanismo (verificado 2026-08-01) | Alerta sugerida |
|----|-------------|--------|-----------------------------------|-----------------|
| `sp_consultasaldocortemin` | 6,651 | 99.85% | **Defecto CWE-390** — ON EXCEPTION convierte fallo cross-DB en código numérico. 99.85% es baseline **con defecto activo**. | Alerta si rate BAJA de 90% sin fix notificado (cambio inesperado); recalibrar a `< 5%` post-corrección |
| `sp_consultaregtarjeta` | 6,560 | 97.29% | **Gating query** — `00002` = "tarjeta/lote no encontrado" es respuesta de negocio esperada para mayoría de consultas | Alerta si rate BAJA de 87% (cambio en patrón de uso); NO alertar por alta tasa |
| `sp_cat_carac_tae` | 7,330 | 96.77% | [SME-PENDING] mecanismo no verificado en código | Alerta si error_rate sale de rango [87%, 99.9%] en 5 min |
| `sp_reverso_msw` | 8,034 | 69.22% | **Restricción de fecha** — reverso solo permitido el mismo día (`cFechaFormat <> pFecha → '00400'`); 69.22% son intentos de días anteriores rechazados por diseño | Alerta si rate BAJA de 50% (cambio inesperado de patrón de uso); NO alertar por alta tasa |
| `sp_app_recuperapayment` | 7,724 | 23.14% | [SME-PENDING] mecanismo no verificado | Alerta si error_rate > 11.6% en 5 min |
| `sp_consulta_cardif` | 11,736 | 8.78% | Respuestas Cardif (validar si gating) | Alerta si error_rate > 4.4% en 5 min |
| `sp_app_confirmpayment` | 61,686 | 8.64% | APPRIZA codRetorno=9999 (ver INC-D05-04) | Alerta si error_rate > 4.3% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

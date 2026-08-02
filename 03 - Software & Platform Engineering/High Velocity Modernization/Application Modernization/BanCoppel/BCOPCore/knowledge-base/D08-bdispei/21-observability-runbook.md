# D08 · bdispei (SPEI / Pagos Interbancarios) — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** SPEIService
> **Wave:** Wave 2 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-31
> **Inventario:** 46 SPs · 53,582 LOC · 343 campos MONEY · 118 cross-DB calls
> **God procedures:** `spei_aplicaordenpago` (4,899 LOC) · `spei_reccancelacion` (4,240 LOC) · `spei_recdevolucion` (3,954 LOC) · `spei_recerrorescodi` (2,707 LOC, 27 callers)
> **Cross-DB top:** bdicheq 67 (57%) · bdimnsj 24 · bdicred 9
> **Sistemas llamantes (logs):** OFI_WEB · BEX
> **Regulatorio:** Banxico — SPEI es sistema de pagos de alto valor; RTO máximo 15 min

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional SPEI y CoDi)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)
- Regulatory — Banxico (SPEI — sistema de pagos de alto valor; notificación obligatoria si RTO > 15 min)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Arquitectura de observabilidad

```
[OFI_WEB]          [BEX]
     │               │
     └───────┬───────┘
             ▼
    [SPEIService (Lambda/ECS)]
          │  structured logs (JSON)
          ▼
    [CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard]
          │
          ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
          │
          └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]
                                                          │
                                                          └─ [Banxico notification webhook]
                                                             (si RTO supera 15 min)

Namespace custom: bancoppel.bdispei.*
Cross-DB monitoreado:
  bdispei → bdicheq  (67 calls · 57% del total — acreditación en cuenta destino)
  bdispei → bdimnsj  (24 calls)
  bdispei → bdicred  (9 calls)

ALERTA REGULATORIA: cualquier interrupción de SPEIService > 15 min requiere
notificación a Banxico. El protocolo de notificación debe activarse si la alarma
de bdispei persiste más de 10 min sin resolución (5 min de margen).
```

---

## Métricas clave (Golden Signals)

### 1. Latency — God procedures SPEI y CoDi

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---|---|---|---|
| `spei_aplicaordenpago` | `bancoppel.bdispei.spei_aplicaordenpago.latency` | `bancoppel.bdispei.spei_aplicaordenpago.errors` | [SME-PENDING] ms |
| `spei_recerrorescodi` | `bancoppel.bdispei.spei_recerrorescodi.latency` | `bancoppel.bdispei.spei_recerrorescodi.errors` | [SME-PENDING] ms |
| `spei_reccancelacion` | `bancoppel.bdispei.spei_reccancelacion.latency` | `bancoppel.bdispei.spei_reccancelacion.errors` | [SME-PENDING] ms |
| `spei_recdevolucion` | `bancoppel.bdispei.spei_recdevolucion.latency` | `bancoppel.bdispei.spei_recdevolucion.errors` | [SME-PENDING] ms |

> Verificar lógica de cada SP en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar umbrales.

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---|---|---|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdispei.requests.total` | Custom | Total de órdenes SPEI procesadas |
| `bancoppel.bdispei.ordenes.pendientes` | Custom | Órdenes SPEI en cola sin procesar (debe ser 0 en operación normal) |
| `bancoppel.bdispei.crossdb.bdicheq.calls` | Custom | Cross-DB calls hacia bdicheq (67 baseline — acreditación) |
| `bancoppel.bdispei.codi.errors` | Custom | Errores CoDi procesados por spei_recerrorescodi |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---|---|---|
| `Errors` (Lambda) | > 0 en 30 s | CRITICAL — notificar Banxico si persiste > 10 min |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdispei.spei_aplicaordenpago.errors` | > 0 en 1 min | CRITICAL — órdenes SPEI bloqueadas |
| `bancoppel.bdispei.ordenes.pendientes` | > 0 por más de 5 min | CRITICAL — reloj Banxico corre |
| `bancoppel.bdispei.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL — rollback inmediato |
| `bancoppel.bdispei.codi.errors` | spike > baseline en 1 min | WARNING — revisar spei_recerrorescodi |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |

> **RTO BANXICO = 15 min.** Este umbral es más estricto que el general de 30 min de CNBV. Activar protocolo de notificación a Banxico si la alarma persiste 10 min sin resolución confirmada.

### 4. Saturation

| Recurso | Métrica | Umbral |
|---|---|---|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review inmediato |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB bdicheq | latency p99 | Alerta si bdicheq (D04) degradado — 67 calls de acreditación en riesgo (57%) |

---

## Patrones de carga validados desde logs de producción

| Ventana | Descripción | Impacto en bdispei |
|---|---|---|
| **Peak:** 10:00–14:00 CDMX | Mayor volumen de pagos interbancarios del día; OFI_WEB y BEX activos | `spei_aplicaordenpago` bajo carga máxima; acreditación vía bdicheq crítica |
| **Off-peak:** 02:00–06:00 CDMX | Tráfico mínimo; ventana preferida para deploys | Volumen bajo pero SPEI sigue operando 24/7 — nunca hay ventana de 0 riesgo |
| **Batch:** 22:00–02:00 CDMX | Conciliación de órdenes del día; devoluciones y cancelaciones nocturnas | `spei_recdevolucion` (3,954 LOC) y `spei_reccancelacion` (4,240 LOC) activos |

> SPEI es un sistema 24/7 por mandato Banxico. No existe una ventana real de "off-peak" sin riesgo regulatorio. Cualquier degradación en cualquier horario activa el reloj de 15 min.

---

## Ruido de fondo conocido — NO es incidente

| Evento | Origen | Código | Frecuencia | Acción |
|---|---|---|---|---|
| NullPointerException background | Huellas442 | 4395 | Cada ~60 s aprox. | Ignorar — issue pre-existente conocido; no crear ticket |

> Filtrar en CloudWatch Insights: `filter @message not like /4395/ and source != "Huellas442"` para no saturar alarmas operativas.
> En D08-bdispei es especialmente crítico filtrar este ruido para no generar falsos positivos que activen el protocolo de notificación a Banxico.

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "SPEI aplicaordenpago p50/p99 — CRÍTICO", "type": "metric",
    "metrics": [["bancoppel/bdispei", "spei_aplicaordenpago.latency.p50"],
                ["bancoppel/bdispei", "spei_aplicaordenpago.latency.p99"]]},
  {"title": "Órdenes SPEI pendientes (debe ser 0)", "type": "metric",
    "metrics": [["bancoppel/bdispei", "ordenes.pendientes"]]},
  {"title": "CoDi errores spei_recerrorescodi", "type": "metric",
    "metrics": [["bancoppel/bdispei", "spei_recerrorescodi.errors"],
                ["bancoppel/bdispei", "codi.errors"]]},
  {"title": "Cancelaciones y devoluciones p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdispei", "spei_reccancelacion.latency.p99"],
                ["bancoppel/bdispei", "spei_recdevolucion.latency.p99"]]},
  {"title": "Error rate total + L4 MONEY", "type": "metric",
    "metrics": [["bancoppel/bdispei", "errors.total"],
                ["bancoppel/bdispei", "errors.l4"]]},
  {"title": "Throughput órdenes SPEI", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdispei-service"]]},
  {"title": "Cross-DB calls bdicheq / bdimnsj / bdicred", "type": "metric",
    "metrics": [["bancoppel/bdispei", "crossdb.bdicheq.calls"],
                ["bancoppel/bdispei", "crossdb.bdimnsj.calls"],
                ["bancoppel/bdispei", "crossdb.bdicred.calls"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdispei-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D08-01: Falla en aplicación de orden de pago — `spei_aplicaordenpago` no procesa

```
CONTEXTO:
  - spei_aplicaordenpago: 4,899 LOC
  - Impacto: órdenes SPEI quedan en estado pendiente sin acreditar
  - REGULATORIO BANXICO: si el servicio no se restaura en < 15 min,
    se requiere notificación formal a Banxico
  - Sistemas afectados: OFI_WEB + BEX
  - Reloj regulatorio: empieza en el momento de la primera alarma CRITICAL

DETECTAR:
  - Alarma bancoppel.bdispei.spei_aplicaordenpago.errors > 0 en 1 min
  - Alarma bancoppel.bdispei.ordenes.pendientes > 0 por más de 5 min
  - OFI_WEB y BEX reportan errores en envío de órdenes SPEI

DIAGNOSTICAR (tiempo máximo de diagnóstico: 5 min para dejar 10 min de resolución):
  1. brain.py — verificar dependencias de spei_aplicaordenpago:
       python BCOPCore/digital-brain/brain.py search "spei_aplicaordenpago"
       python BCOPCore/digital-brain/brain.py callers "spei_aplicaordenpago"

  2. Verificar si bdicheq (D04) está respondiendo — bdispei hace 67 cross-DB
     a bdicheq (57% del total); si bdicheq está degradado la acreditación falla:
       python BCOPCore/digital-brain/brain.py search "bdicheq"
     Si bdicheq es la causa → ver INC-D08-03

  3. Revisar lógica del SP en:
       source/BCOPCore/informix/spei_aplicaordenpago.sql
     Identificar si el SP hace UPDATE de saldo en bdicheq y en qué paso falla

  4. X-Ray: localizar el tramo de falla en el trace

  5. Aurora: verificar si hay transacciones bloqueadas de órdenes previas
     sin COMMIT (lock en tabla de órdenes SPEI)

RESOLVER:
  A. Si bdicheq degradado: → INC-D08-03; escalar a D04 inmediatamente
  B. Si error interno del SP: activar AppConfig feature flag al 0%
     (rollback al Informix legacy) — acción más rápida para cumplir RTO 15 min
  C. Si Aurora: failover manual a réplica
  D. PROTOCOLO BANXICO: si a los 10 min de la primera alarma el servicio
     no está restaurado, notificar a Banxico vía canal oficial establecido
     con: hora de inicio, número de órdenes pendientes, causa identificada,
     ETA de resolución

ESCALAR EN T+0: SRE Lead + Domain Expert BanCoppel
ESCALAR EN T+10 min: Program Manager + Regulatory Banxico (si no está resuelto)
RTO: < 15 min (Banxico — sistema de pagos de alto valor)
```

### INC-D08-02: Cascada de errores CoDi — `spei_recerrorescodi` recibe spike

```
CONTEXTO:
  - spei_recerrorescodi: 2,707 LOC · 27 callers
  - spei_devcodi (4,054 LOC) puede quedar en estado inconsistente
    si los errores CoDi no se procesan correctamente
  - CoDi es el sistema de cobros digitales de Banxico; errores no procesados
    pueden implicar cargos duplicados o devoluciones incorrectas

DETECTAR:
  - Alarma bancoppel.bdispei.codi.errors spike > baseline + [SME-PENDING]% en 1 min
  - Alarma bancoppel.bdispei.spei_recerrorescodi.errors > 0 en 1 min
  - 27 callers reportando errores de CoDi simultáneamente

DIAGNOSTICAR:
  1. brain.py — identificar callers activos y relación con spei_devcodi:
       python BCOPCore/digital-brain/brain.py callers "spei_recerrorescodi"
       python BCOPCore/digital-brain/brain.py search "spei_devcodi"

  2. Revisar lógica de manejo de errores en:
       source/BCOPCore/informix/spei_recerrorescodi.sql
       source/BCOPCore/informix/spei_devcodi.sql
     Identificar si el SP tiene transacciones sin COMMIT ante errores y si
     hay lógica de rollback parcial que pueda dejar estado inconsistente

  3. CloudWatch Insights — correlacionar el spike con su origen:
       fields @timestamp, @message
       | filter operation = "spei_recerrorescodi"
       | filter @message like /ERROR/
       | sort @timestamp asc
       | limit 100
     Identificar si el spike es externo (Banxico envía más errores de lo normal)
     o interno (el SP falla al procesar)

  4. Verificar si spei_devcodi quedó en estado inconsistente:
       python BCOPCore/digital-brain/brain.py search "spei_devcodi"
     Si hay transacciones de devolución CoDi sin completar, el riesgo
     regulatorio es equivalente a INC-D08-01

RESOLVER:
  A. Si el spike proviene de Banxico (errores externos aumentaron):
     verificar que spei_recerrorescodi los está procesando correctamente;
     si no — activar rollback al Informix legacy
  B. Si spei_devcodi quedó en estado inconsistente: no ejecutar DML manual;
     coordinar con Domain Expert BanCoppel y DBA IDS para identificar
     el estado real de las devoluciones CoDi afectadas
  C. Activar AppConfig feature flag al 0% si el estado inconsistente
     no puede resolverse en < 10 min (margen para RTO de 15 min)
  D. Documentar todas las transacciones CoDi afectadas para reconciliación
     post-incidente con Banxico

ESCALAR si no resuelve en 10 min: SRE Lead + Domain Expert BanCoppel + Regulatory Banxico
RTO: < 15 min (Banxico — sistema de pagos de alto valor)
```

### INC-D08-03: SPEI-to-cheq cross-DB bloqueado — bdicheq (D04) degradado

```
CONTEXTO:
  - bdispei hace 67 cross-DB calls a bdicheq (D04 — 57% del total de bdispei)
  - bdicheq es la base de cheques/cuentas; sin ella, SPEI no puede acreditar
    el pago en la cuenta destino del beneficiario
  - Cross-DB visible en logs: OFI_WEB → bdicheq → bdispei
  - Degradación de bdicheq impacta directamente en spei_aplicaordenpago

DETECTAR:
  - Alarma bancoppel.bdispei.crossdb.bdicheq.calls cae bruscamente
  - Alarma bancoppel.bdispei.spei_aplicaordenpago.errors > 0 correlacionado
    con alertas de D04-bdicheq
  - X-Ray muestra latencia elevada únicamente en el tramo cross-DB hacia bdicheq
  - bancoppel.bdispei.ordenes.pendientes > 0 (órdenes sin acreditar)

DIAGNOSTICAR:
  1. Confirmar estado de bdicheq (D04) como causa raíz — no debuggear bdispei
     hasta confirmar que D04 es el origen del problema:
       python BCOPCore/digital-brain/brain.py search "bdicheq"

  2. brain.py — identificar los SPs de bdispei que disparan las 67 calls:
       python BCOPCore/digital-brain/brain.py crossdb "bdispei" "bdicheq"

  3. CloudWatch Insights — aislar errores de cross-DB hacia bdicheq:
       fields @timestamp, @message
       | filter domain = "bdispei"
       | filter @message like /bdicheq/
       | sort @timestamp desc
       | limit 50

  4. Evaluar órdenes SPEI pendientes sin acreditar:
     Registrar número de órdenes en bancoppel.bdispei.ordenes.pendientes
     como evidencia para notificación a Banxico si supera 15 min

RESOLVER:
  A. Escalar a equipo D04-bdicheq como incidente externo y propietario;
     bdispei no puede resolver la dependencia de 67 cross-DB calls
  B. PROTOCOLO BANXICO simultáneo: si bdicheq no se restaura en < 10 min
     desde la primera alarma de bdispei, activar notificación a Banxico
     con las órdenes SPEI pendientes y ETA de resolución
  C. Mientras bdicheq está degradado: suspender recepción de nuevas órdenes
     SPEI en SPEIService para evitar acumulación; retornar HTTP 503 con
     Retry-After a OFI_WEB y BEX ([SME-PENDING] validar con Domain Expert)
  D. Al restaurar bdicheq: procesar las órdenes pendientes en orden FIFO
     con monitoreo activo de bancoppel.bdispei.ordenes.pendientes
  E. Si bdicheq no se restaura antes del RTO de 15 min:
     activar rollback total al Informix legacy (AppConfig feature flag al 0%)

ESCALAR EN T+0: SRE Lead + equipo D04-bdicheq
ESCALAR EN T+10 min: Program Manager + Regulatory Banxico (si no está resuelto)
RTO: < 15 min (Banxico — sistema de pagos de alto valor)
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdispei-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "spei_aplicaordenpago",
  "domain": "bdispei",
  "wave": "Wave 2",
  "callingSystem": "OFI_WEB",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid",
  "speiOrderId": "ANON-uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, CLABE origen/destino en texto plano, nombre del beneficiario, monto exacto). Solo loguear identificadores anonimizados. Las CLABEs deben estar enmascaradas (primeros 6 + últimos 2 dígitos como máximo). Los montos SPEI no se loguean en claro — solo el outcome y el ID de la orden anonimizado.
> El campo `speiOrderId` debe ser un UUID interno trazable para Banxico, nunca el número de referencia SPEI directamente visible.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales SLO requieren validación con baseline real de QA Lead + Domain Expert BanCoppel + Regulatory Banxico.*
*Lógica de SPs: verificar en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar cualquier umbral o implementar fix.*
*RTO Banxico = 15 min — más estricto que el RTO general CNBV de 30 min. Este runbook tiene precedencia operativa sobre otros dominios en caso de incidente simultáneo.*

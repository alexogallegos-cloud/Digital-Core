# D07 · bdiaclaracion (Aclaraciones) — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** AclaracionesService
> **Wave:** Wave 2 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-31
> **Inventario:** 84 SPs · 412,868 LOC · 4,786 campos MONEY · 858 cross-DB calls
> **God procedures:** `sp_fal_cancelacion_cuenta_debito` (11,516 LOC, 40 callers) · `sp_fal_busca_beneficiarios_por_cuenta` (12,269 LOC, 0 callers directos)
> **Nota arquitectural:** 9 de 10 god procedures tienen 0 callers directos — invocación probable por batch nocturno o sistemas externos
> **Cross-DB top:** bdinteg 452 (53%) · bdicheq 153 · bdicred 139
> **Sistemas llamantes:** [SME-PENDING] — identificar llamantes de los 40 callers de sp_fal_cancelacion_cuenta_debito

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional de aclaraciones y cancelaciones)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)
- Regulatory — CONDUSEF (cancelaciones de cuentas requieren cumplimiento regulatorio)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Arquitectura de observabilidad

```
[Callers externos — 40 callers de sp_fal_cancelacion_cuenta_debito]
[Batch nocturno 22:00–02:00 CDMX — 9 god procedures con 0 callers directos]
                           │
                           ▼
          [AclaracionesService (Lambda/ECS)]
                    │  structured logs (JSON)
                    ▼
          [CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard]
                    │
                    ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
                    │
                    └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace custom: bancoppel.bdiaclaracion.*
Cross-DB monitoreado:
  bdiaclaracion → bdinteg  (452 calls · 53% del total — dependencia crítica)
  bdiaclaracion → bdicheq  (153 calls)
  bdiaclaracion → bdicred  (139 calls)
```

---

## Métricas clave (Golden Signals)

### 1. Latency — God procedures con callers activos

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---|---|---|---|
| `sp_fal_cancelacion_cuenta_debito` | `bancoppel.bdiaclaracion.fal_cancelacion_cuenta_debito.latency` | `bancoppel.bdiaclaracion.fal_cancelacion_cuenta_debito.errors` | [SME-PENDING] ms |
| `sp_fal_busca_beneficiarios_por_cuenta` | `bancoppel.bdiaclaracion.fal_busca_beneficiarios_por_cuenta.latency` | `bancoppel.bdiaclaracion.fal_busca_beneficiarios_por_cuenta.errors` | [SME-PENDING] ms |
| `sp_fal_busca_documentos_faltantes` | `bancoppel.bdiaclaracion.fal_busca_documentos_faltantes.latency` | `bancoppel.bdiaclaracion.fal_busca_documentos_faltantes.errors` | [SME-PENDING] ms |

> Verificar lógica de cada SP en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar umbrales.
> Los 9 god procedures con 0 callers directos deben instrumentarse con trazas de batch para capturar su ejecución nocturna.

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---|---|---|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdiaclaracion.requests.total` | Custom | Total de requests al microservicio |
| `bancoppel.bdiaclaracion.batch.executions` | Custom | Ejecuciones de god procedures en ventana batch (22:00–02:00 CDMX) |
| `bancoppel.bdiaclaracion.crossdb.bdinteg.calls` | Custom | Cross-DB calls hacia bdinteg (452 baseline — 53%) |
| `bancoppel.bdiaclaracion.crossdb.bdicheq.calls` | Custom | Cross-DB calls hacia bdicheq (153 baseline) |
| `bancoppel.bdiaclaracion.crossdb.bdicred.calls` | Custom | Cross-DB calls hacia bdicred (139 baseline) |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---|---|---|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdiaclaracion.fal_cancelacion_cuenta_debito.errors` | > 0 en 1 min | CRITICAL — proceso regulatorio CONDUSEF bloqueado |
| `bancoppel.bdiaclaracion.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL — rollback inmediato |
| `bancoppel.bdiaclaracion.batch.executions` = 0 en ventana batch | Ausencia de batch | CRITICAL — procesos nocturnos no ejecutaron |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---|---|---|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB bdinteg | latency p99 | Alerta si bdinteg (D02) degradado — 452 calls en riesgo (53%) |

---

## Patrones de carga validados desde logs de producción

| Ventana | Descripción | Impacto en bdiaclaracion |
|---|---|---|
| **Peak:** 10:00–14:00 CDMX | Atención al cliente en sucursal; aclaraciones de pagos y cancelaciones | `sp_fal_cancelacion_cuenta_debito` (40 callers) activo; proceso CONDUSEF en curso |
| **Off-peak:** 02:00–06:00 CDMX | Tráfico mínimo; ventana segura para deploys | Volumen bajo; safe para mantenimiento |
| **Batch:** 22:00–02:00 CDMX | Los 9 god procedures con 0 callers directos se invocan probablemente aquí; cierre de aclaraciones | `sp_fal_busca_documentos_faltantes` (12,110 LOC) candidato a ejecución nocturna |

> Riesgo de batch: 9 de 10 god procedures tienen 0 callers directos confirmados en logs. Es probable que sean invocados por procesos externos no instrumentados o batch nocturno. Pendiente identificar el disparador real con Domain Expert antes de Wave 2.

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
  {"title": "Cancelación cuenta debito p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdiaclaracion", "fal_cancelacion_cuenta_debito.latency.p50"],
                ["bancoppel/bdiaclaracion", "fal_cancelacion_cuenta_debito.latency.p99"]]},
  {"title": "Búsqueda documentos faltantes (batch) p50/p99", "type": "metric",
    "metrics": [["bancoppel/bdiaclaracion", "fal_busca_documentos_faltantes.latency.p50"],
                ["bancoppel/bdiaclaracion", "fal_busca_documentos_faltantes.latency.p99"]]},
  {"title": "Error rate total + L4 MONEY", "type": "metric",
    "metrics": [["bancoppel/bdiaclaracion", "errors.total"],
                ["bancoppel/bdiaclaracion", "errors.l4"]]},
  {"title": "Throughput (Invocations)", "type": "metric",
    "metrics": [["AWS/Lambda", "Invocations", "FunctionName", "bdiaclaracion-service"]]},
  {"title": "Cross-DB calls bdinteg / bdicheq / bdicred", "type": "metric",
    "metrics": [["bancoppel/bdiaclaracion", "crossdb.bdinteg.calls"],
                ["bancoppel/bdiaclaracion", "crossdb.bdicheq.calls"],
                ["bancoppel/bdiaclaracion", "crossdb.bdicred.calls"]]},
  {"title": "Batch executions (22:00–02:00 CDMX)", "type": "metric",
    "metrics": [["bancoppel/bdiaclaracion", "batch.executions"]]},
  {"title": "Aurora connections", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdiaclaracion-aurora"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D07-01: Cancelación de cuenta fallecido bloqueada — `sp_fal_cancelacion_cuenta_debito` falla

```
CONTEXTO:
  - sp_fal_cancelacion_cuenta_debito: 11,516 LOC · 40 callers
  - Proceso regulatorio: cancelación de cuenta por fallecimiento o mandato CONDUSEF
  - Impacto regulatorio: si el proceso queda pendiente, BanCoppel incurre en
    incumplimiento ante CONDUSEF; el plazo regulatorio es un SLA externo
  - Ventana crítica: peak 10:00–14:00 CDMX (atención presencial en sucursal)

DETECTAR:
  - Alarma bancoppel.bdiaclaracion.fal_cancelacion_cuenta_debito.errors > 0 en 1 min
  - Alarma bancoppel.bdiaclaracion.fal_cancelacion_cuenta_debito.latency.p99 > SLO + 20%
  - Callers (40) reportando fallo en su log; procesos de cancelación en estado PENDIENTE

DIAGNOSTICAR:
  1. brain.py — identificar callers activos y dependencias:
       python BCOPCore/digital-brain/brain.py callers "sp_fal_cancelacion_cuenta_debito"
       python BCOPCore/digital-brain/brain.py search "sp_fal_cancelacion_cuenta_debito"

  2. Revisar lógica completa del SP en:
       source/BCOPCore/informix/sp_fal_cancelacion_cuenta_debito.sql
     Con 11,516 LOC, identificar las secciones de cierre de cuenta y si hay
     dependencias de cross-DB hacia bdinteg, bdicheq o bdicred

  3. Verificar si la falla está en el cross-DB hacia bdinteg:
       python BCOPCore/digital-brain/brain.py crossdb "bdiaclaracion" "bdinteg"
     bdiaclaracion hace 452 cross-DB a bdinteg (53% del total)

  4. X-Ray: localizar el tramo de falla dentro del SP (11,516 LOC)

  5. CloudWatch Insights — identificar cuentas en proceso de cancelación bloqueadas:
       fields @timestamp, @message
       | filter operation = "sp_fal_cancelacion_cuenta_debito"
       | filter @message like /ERROR/
       | sort @timestamp desc
       | limit 50

RESOLVER:
  A. Si error en cross-DB hacia bdinteg: escalar a equipo D02-bdinteg;
     no hay fix local posible para la dependencia de 452 cross-DB calls
  B. Si error interno del SP: activar AppConfig feature flag al 0%
     (rollback al Informix legacy); 40 callers vuelven al sistema legacy
  C. Notificar a Compliance / área CONDUSEF de BanCoppel sobre cancelaciones
     pendientes y tiempo estimado de resolución (obligatorio regulatorio)
  D. Post-resolución: documentar todas las cuentas que quedaron en estado
     PENDIENTE para procesamiento prioritario al restaurar el servicio

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel + Regulatory CONDUSEF
RTO: < 30 min (CNBV — sistema bancario crítico; riesgo regulatorio CONDUSEF adicional)
```

### INC-D07-02: Búsqueda de documentos faltantes timeout — `sp_fal_busca_documentos_faltantes` en batch

```
CONTEXTO:
  - sp_fal_busca_documentos_faltantes: 12,110 LOC · 0 callers directos confirmados
  - Invocación probable: batch nocturno 22:00–02:00 CDMX o sistema externo
    no instrumentado en logs actuales
  - Impacto: timeout bloquea el cierre del ciclo de aclaraciones; los casos
    pendientes no avanzan al estado de resolución

DETECTAR:
  - Alarma bancoppel.bdiaclaracion.batch.executions = 0 durante ventana batch
    (indica que el proceso nocturno no ejecutó o falló silenciosamente)
  - Alarma bancoppel.bdiaclaracion.fal_busca_documentos_faltantes.latency.p99
    excede umbral durante ventana 22:00–02:00 CDMX
  - Alarma bancoppel.bdiaclaracion.fal_busca_documentos_faltantes.errors > 0

DIAGNOSTICAR:
  1. brain.py — confirmar mecanismo de invocación (batch vs. externo):
       python BCOPCore/digital-brain/brain.py search "sp_fal_busca_documentos_faltantes"
       python BCOPCore/digital-brain/brain.py callers "sp_fal_busca_documentos_faltantes"

  2. Revisar lógica del SP en:
       source/BCOPCore/informix/sp_fal_busca_documentos_faltantes.sql
     Con 12,110 LOC, identificar si hay cursores que iteran sobre conjuntos
     grandes de datos; probable causa de timeout en lotes con alto volumen

  3. Verificar si el batch nocturno completó en su ventana:
     CloudWatch Logs — buscar logs de inicio y fin del proceso batch:
       fields @timestamp, @message
       | filter operation = "sp_fal_busca_documentos_faltantes"
       | filter @timestamp > datefloor(@timestamp, 1d) + 22h
       | sort @timestamp asc

  4. Verificar disponibilidad de bdinteg durante la ventana batch
     (452 cross-DB calls — 53% del total de bdiaclaracion)

RESOLVER:
  A. Si timeout por volumen de datos: coordinar con DBA IDS para analizar
     el SP y revisar estrategia de paginación ([SME-PENDING] DBA + Domain Expert)
  B. Si bdinteg degradado durante el batch: reejecutar el proceso batch
     cuando bdinteg esté disponible; confirmar ventana con equipo D02
  C. Si el SP nunca ejecutó (batch.executions = 0): verificar el scheduler
     que dispara el batch; puede ser un job de Informix no migrado aún
  D. Rollback al Informix legacy si el proceso completo está bloqueado:
     AppConfig feature flag al 0%

ESCALAR si no resuelve en 30 min: SRE Lead + Domain Expert BanCoppel + DBA IDS
RTO: < 30 min (CNBV — sistema bancario crítico)
NOTA: identificar el mecanismo de invocación real de este SP es un DATO-REQUERIDO
para Wave 2 — coordinar sesión con Domain Expert BanCoppel.
```

### INC-D07-03: Cascada hacia bdinteg — bdiaclaracion pierde 53% de sus dependencias

```
CONTEXTO:
  - bdiaclaracion hace 452 de 858 cross-DB calls hacia bdinteg (D02 — 53%)
  - Si bdinteg (D02) cae, bdiaclaracion pierde más de la mitad de sus dependencias
    externas simultáneamente
  - bdiaclaracion también depende de bdicheq (153 calls) y bdicred (139 calls)
  - Degradación triple posible si hay incidente de infraestructura transversal

DETECTAR:
  - Alarma bancoppel.bdiaclaracion.crossdb.bdinteg.calls cae bruscamente
  - Alertas de D02-bdinteg activas simultáneamente
  - Múltiples SPs de bdiaclaracion fallan concurrentemente sin causa interna visible
  - X-Ray muestra todos los errores en el tramo cross-DB hacia bdinteg

DIAGNOSTICAR:
  1. Confirmar estado de bdinteg (D02) como causa raíz:
       python BCOPCore/digital-brain/brain.py search "bdinteg"
     No iniciar debug interno de bdiaclaracion hasta confirmar que D02 es el origen

  2. brain.py — identificar qué SPs de bdiaclaracion disparan las 452 calls a bdinteg:
       python BCOPCore/digital-brain/brain.py crossdb "bdiaclaracion" "bdinteg"

  3. Evaluar impacto adicional:
       python BCOPCore/digital-brain/brain.py search "bdicheq"
       python BCOPCore/digital-brain/brain.py search "bdicred"
     Si bdicheq (153) y bdicred (139) también están degradados, el incidente
     es de infraestructura transversal — escalar a nivel de plataforma

  4. CloudWatch Insights — aislar errores de cross-DB bdinteg:
       fields @timestamp, @message
       | filter domain = "bdiaclaracion"
       | filter @message like /bdinteg/
       | sort @timestamp desc
       | limit 50

RESOLVER:
  A. Escalar a equipo D02-bdinteg como incidente externo y propietario;
     bdiaclaracion no puede resolver la dependencia de 452 cross-DB calls
  B. Mientras bdinteg está degradado: desactivar los flujos de aclaraciones
     que dependen de bdinteg vía AppConfig flags ([SME-PENDING] Domain Expert
     debe indicar cuáles flows pueden operar sin bdinteg)
  C. Si degradación triple (bdinteg + bdicheq + bdicred): activar rollback
     total al Informix legacy (AppConfig feature flag al 0%) y escalar a
     SRE Lead + Program Manager como P1
  D. Post-resolución: verificar que todos los procesos de aclaración
     pendientes durante el incidente completen correctamente

ESCALAR si no resuelve en 30 min: SRE Lead + equipo D02-bdinteg + Program Manager
RTO: < 30 min (CNBV — sistema bancario crítico)
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdiaclaracion-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_fal_cancelacion_cuenta_debito",
  "domain": "bdiaclaracion",
  "wave": "Wave 2",
  "executionMode": "ONLINE",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, nombre del titular fallecido, num_tarjeta, correo, celular). Solo loguear identificadores anonimizados. Los procesos de cancelación de cuenta tienen implicaciones legales — el log debe ser suficientemente detallado para auditoría CONDUSEF sin contener datos personales directos.
> Campo `executionMode`: valor "ONLINE" para invocaciones directas, "BATCH" para procesos nocturnos.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales SLO requieren validación con baseline real de QA Lead + Domain Expert BanCoppel.*
*Lógica de SPs: verificar en `source/BCOPCore/informix/{sp_name}.sql` antes de ajustar cualquier umbral o implementar fix.*
*Pendiente crítico: identificar mecanismo de invocación de los 9 god procedures con 0 callers directos antes de Wave 2.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 5.59% (ELEVADO — monitorear)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `3170` | 2 | BAJA | Investigar con equipo ESB |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

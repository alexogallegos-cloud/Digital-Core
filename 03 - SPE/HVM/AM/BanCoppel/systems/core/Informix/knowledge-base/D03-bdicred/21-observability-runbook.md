# D03 · bdicred — Crédito — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Base de datos:** bdicred (Crédito)
> **Wave:** 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-31

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional — ciclo de crédito)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS — datos crediticios y de scoring)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Perfil del dominio

| Atributo | Valor |
|----------|-------|
| SPs totales | 380 |
| LOC totales | 687,797 |
| Ocurrencias MONEY | 13,500 |
| Referencias cross-DB | 1,099 |
| God procedure — respaldo | `sp_respalda_credito_rr` (9,811 LOC, 8 callers) |
| God procedure — reversión | `reversioncrd` (8,045 LOC, 48 callers) |
| God procedure — cancelación | `cancelatarjeta_web` (8,806 LOC) |
| Cross-DB primarios | bdicheq (288 refs), bdinteg (226 refs), bdisolic (212 refs), bdicobranza (152 refs) |
| Sistemas llamadores (logs) | OFI_WEB (módulos: Caja2, Cliente2, CreditoPreAprobado) |
| SPs observados en logs | `sp_consulta_pre_aprobado`, `obt_datos_caratula` |

> **Nota de fuente:** Los perfiles completos de cada SP se deben validar contra
> `source/informix/{sp_name}.sql` antes de confirmar umbrales de alarma
> en producción. `sp_respalda_credito_rr` y `reversioncrd` requieren revisión de
> Specialist Informix SPL Analysis por su criticidad en el ciclo de vida del crédito.

---

## Patrones de carga validados (logs de producción)

| Ventana | Horario CDMX | Volumen aprox. | Sistemas activos |
|---------|-------------|----------------|-----------------|
| Pico operativo | 10:00 – 14:00 | 80 – 216 MB/hr | OFI_WEB (Caja2, Cliente2, CreditoPreAprobado) |
| Valle nocturno | 02:00 – 06:00 | 4 – 7 MB/hr | Procesos batch residuales |
| Ventana batch | 22:00 – 02:00 | Variable | Respaldos de crédito, cierre contable, cobranza |

El módulo CreditoPreAprobado de OFI_WEB genera el pico más intenso de llamadas a
`sp_consulta_pre_aprobado` entre 10:00 y 14:00. Las reversiones (`reversioncrd`)
tienen un segundo pico al inicio de la ventana batch (22:00–23:00) por procesos
de cierre. Con 48 callers directos, `reversioncrd` es el SP más expuesto a avalancha
en ese horario.

---

## Arquitectura de observabilidad

```
[bdicred — Crédito Service (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard bancoppel.bdicred]
        │
        ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace raíz: bancoppel.bdicred.*

Fuentes adicionales:
  - Aurora (bdicred cluster):   AWS/RDS DatabaseConnections, FreeLocalStorage
  - MSK (Kafka topic bdicred.events):  SumOffsetLag
  - Cross-DB traces:  X-Ray spans hacia bdicheq (288), bdinteg (226), bdisolic (212), bdicobranza (152)
```

---

## Métricas clave (Golden Signals)

### 1. Latency — SPs principales

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---------------------|--------------------|--------------------|-----|
| `sp_consulta_pre_aprobado` | `bancoppel.bdicred.consulta_pre_aprobado.latency` | `bancoppel.bdicred.consulta_pre_aprobado.errors` | [SME-PENDING] ms |
| `obt_datos_caratula` | `bancoppel.bdicred.obt_datos_caratula.latency` | `bancoppel.bdicred.obt_datos_caratula.errors` | [SME-PENDING] ms |
| `sp_respalda_credito_rr` | `bancoppel.bdicred.respalda_credito_rr.latency` | `bancoppel.bdicred.respalda_credito_rr.errors` | [SME-PENDING] ms |
| `reversioncrd` | `bancoppel.bdicred.reversioncrd.latency` | `bancoppel.bdicred.reversioncrd.errors` | [SME-PENDING] ms |
| `cancelatarjeta_web` | `bancoppel.bdicred.cancelatarjeta_web.latency` | `bancoppel.bdicred.cancelatarjeta_web.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones al servicio bdicred |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdicred.requests.total` | Custom | Total de requests al microservicio |
| `bancoppel.bdicred.reversiones.rate` | Custom | Tasa de reversiones por minuto (detectar avalancha) |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdicred.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL (rollback inmediato) |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |
| `bancoppel.bdicred.credito.inconsistente` | > 0 | CRITICAL (crédito en estado inconsistente) |
| `bancoppel.bdicred.reversiones.rate` | pico > 3x baseline | WARNING (avalancha de reversiones) |
| `bancoppel.bdicred.crossdb.bdicheq.errors` | > 0.1% en 5 min | CRITICAL (caída cruzada) |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---------|---------|--------|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB bdicheq | `bancoppel.bdicred.crossdb.bdicheq.latency` | [SME-PENDING] ms — 288 refs críticas |

---

## SLOs del dominio

> `[SME-PENDING]` — Los SLOs definitivos requieren baseline de QA Lead con carga real de pico (10:00–14:00 CDMX).

| Indicador | SLO target | Error budget | Estado |
|-----------|------------|--------------|--------|
| Disponibilidad servicio bdicred | [SME-PENDING] % | [SME-PENDING] min/mes | Pendiente |
| Latencia p99 `sp_consulta_pre_aprobado` | [SME-PENDING] ms | — | Pendiente |
| Latencia p99 `reversioncrd` | [SME-PENDING] ms | — | Pendiente |
| Créditos en estado inconsistente | 0 por ventana batch | — | Pendiente |
| Divergencias financieras MONEY | 0 eventos/mes | — | Pendiente |

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Latencia p50/p95/p99 — SPs clave", "type": "metric",
    "metrics": [["bancoppel/bdicred", "consulta_pre_aprobado.latency.p50"],
                ["bancoppel/bdicred", "consulta_pre_aprobado.latency.p99"],
                ["bancoppel/bdicred", "reversioncrd.latency.p99"]]},
  {"title": "Error rate + créditos inconsistentes + MONEY divergencias", "type": "metric",
    "metrics": [["bancoppel/bdicred", "errors.total"],
                ["bancoppel/bdicred", "credito.inconsistente"],
                ["bancoppel/bdicred", "errors.l4"]]},
  {"title": "Tasa de reversiones (reversioncrd — 48 callers)", "type": "metric",
    "metrics": [["bancoppel/bdicred", "reversiones.rate"]]},
  {"title": "Throughput por módulo OFI_WEB", "type": "metric",
    "metrics": [["bancoppel/bdicred", "requests.caja2"],
                ["bancoppel/bdicred", "requests.cliente2"],
                ["bancoppel/bdicred", "requests.creditopreaprobado"]]},
  {"title": "Aurora connections bdicred", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdicred-aurora"]]},
  {"title": "Cross-DB latency (bdicheq 288 / bdinteg 226 / bdisolic 212 / bdicobranza 152)", "type": "metric",
    "metrics": [["bancoppel/bdicred", "crossdb.bdicheq.latency"],
                ["bancoppel/bdicred", "crossdb.bdinteg.latency"],
                ["bancoppel/bdicred", "crossdb.bdisolic.latency"],
                ["bancoppel/bdicred", "crossdb.bdicobranza.latency"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D03-01: Falla en respaldo de crédito — `sp_respalda_credito_rr` / `sp_respalda_credito_pp`

```
TRIGGER:
  - Alarma bancoppel.bdicred.credito.inconsistente > 0
  - O: bancoppel.bdicred.respalda_credito_rr.errors > 0 durante ventana batch
  - O: reporte operativo de créditos que no aparecen en carátula después de alta

CONTEXTO:
  sp_respalda_credito_rr (9,811 LOC, 8 callers) y sp_respalda_credito_pp son
  responsables del respaldo del estado del crédito en tablas de soporte.
  Si fallan, el crédito queda en estado "activo en pantalla" pero sin registro
  de respaldo: el cliente puede ver el crédito aprobado pero el sistema no tiene
  el snapshot necesario para recuperación o auditoría.
  Este escenario es especialmente crítico durante la ventana batch (22:00–02:00),
  cuando se procesan cierres masivos de créditos del día.

DIAGNOSTICAR:
  1. CloudWatch Insights — filtrar errores de sp_respalda_credito_rr en el periodo:
       fields @timestamp, @message, requestId
       | filter operation like /respalda_credito/ and outcome = "ERROR"
       | sort @timestamp desc | limit 50

  2. Digital Brain — obtener el perfil del SP y sus 8 callers:
       brain.sp('sp_respalda_credito_rr')
       brain.callers_of('sp_respalda_credito_rr')
       # Identificar cuáles callers estaban activos en el momento del fallo;
       # cruzar con los módulos de OFI_WEB reportados en logs (Caja2, Cliente2)

  3. Digital Brain — buscar reglas de negocio asociadas al respaldo:
       brain.rules_of_sp('sp_respalda_credito_rr')
       # Identificar condiciones de guarda que pueden causar el fallo

  4. Aurora bdicred — verificar si hay lock en las tablas de respaldo:
       CloudWatch DB Load → wait events durante la ventana de fallo
       Performance Insights → top SQL por wait time en tablas de respaldo

  5. Verificar si el fallo coincide con llamadas cross-DB a bdicheq (288) o bdisolic (212):
       X-Ray → buscar spans cross-DB fallidos simultáneos al error de respaldo
       Si bdicheq o bdisolic no responden, el SP puede fallar por dependencia ausente

  6. Fuente del SP:
       source/informix/sp_respalda_credito_rr.sql
       Validar con Specialist Informix SPL Analysis la lógica de transacción y
       los puntos exactos donde el SP puede quedar en estado parcial.

RESOLVER:
  A. Si el fallo es por lock contention en Aurora:
       - Identificar sesión bloqueante en Performance Insights
       - Matar sesión solo con autorización de DBA IBM Informix IDS
       - Reintentar el respaldo manualmente para los créditos afectados (con QA Lead)

  B. Si el fallo es por dependencia cross-DB ausente (bdicheq / bdisolic):
       - Activar circuit-breaker en la integración bdicred → bdicheq/bdisolic
       - Encolar los respaldos pendientes en MSK para reproceso cuando la DB dependiente
         vuelva a estar disponible
       - Seguir runbook INC-D04 (bdicheq) si esa es la causa raíz

  C. Si los créditos ya están en estado inconsistente:
       - Rollback de tráfico a Informix legacy vía AppConfig
       - Generar listado de créditos afectados (num_cred, fecha, estado) para auditoría
       - Notificar: Domain Expert BanCoppel + QA Lead + Program Manager
       - No procesar nuevos créditos hasta confirmar que el respaldo funciona

ESCALAR si no resuelve en 20 min: SRE Lead + Specialist Informix SPL Analysis + Domain Expert BanCoppel
RTO target: < 20 min (créditos en estado inconsistente representan riesgo regulatorio CNBV)
```

---

### INC-D03-02: Avalancha de reversiones — `reversioncrd` con 48 callers

```
TRIGGER:
  - Alarma bancoppel.bdicred.reversiones.rate supera 3x el baseline de la ventana horaria
  - O: bancoppel.bdicred.reversioncrd.latency.p99 supera umbral durante ventana pico o batch
  - O: Lambda Throttles > 0 asociados a invocaciones de reversioncrd

CONTEXTO:
  reversioncrd tiene 8,045 LOC y 48 callers directos — es el SP de reversión con
  mayor fan_in en todo bdicred. Durante eventos de quincena (días 15 y 30 del mes)
  o fallos de batch parcial, múltiples callers pueden disparar reversiones simultáneas.
  A 8,045 LOC por ejecución, el timeout en cadena puede saturar el pool de conexiones
  de Aurora bdicred en minutos y derramarse a los 4 dominios con los que tiene
  dependencias cross-DB (bdicheq 288, bdinteg 226, bdisolic 212, bdicobranza 152).

DIAGNOSTICAR:
  1. CloudWatch Metrics — confirmar el pico de reversiones y su duración:
       Gráfica bancoppel.bdicred.reversiones.rate en ventana de 30 minutos
       Comparar con baseline histórico de la misma franja horaria

  2. Digital Brain — obtener los 48 callers de reversioncrd:
       brain.callers_of('reversioncrd', limit=48)
       # Identificar cuáles callers tienen mayor fan_in; son los que más contribuyen
       # al volumen de reversiones concurrentes

  3. Digital Brain — obtener reglas de negocio de reversioncrd:
       brain.rules_of_sp('reversioncrd')
       # Identificar condiciones de reintento automático dentro del SP que puedan
       # amplificar el volumen de llamadas en escenario de error parcial

  4. Aurora bdicred — verificar saturación del pool de conexiones:
       DatabaseConnections / MaxConnections → si > 80%, las reversiones están
       compitiendo por conexiones con el tráfico normal de crédito

  5. X-Ray — verificar si las reversiones están generando llamadas cross-DB adicionales:
       Expandir traces de reversioncrd y verificar spans a bdicheq (288 refs)
       Una avalancha de reversiones puede generar un segundo pico de llamadas
       cross-DB que degrade bdicheq simultáneamente

  6. Fuente del SP:
       source/informix/reversioncrd.sql
       Validar con Specialist Informix SPL Analysis si hay lógica de reintento
       interno que pueda estar amplificando el volumen real de ejecuciones.

RESOLVER:
  A. Si el volumen es legítimo (quincena, fallo de batch):
       - Aplicar rate limiting en la capa de API Gateway para reversioncrd:
         reducir concurrencia máxima a un valor que Aurora pueda absorber
       - Encolar el exceso de reversiones en MSK topic bdicred.reversiones
         para reproceso ordenado y monitoreado
       - Notificar a Domain Expert BanCoppel sobre la ventana de procesamiento ampliada

  B. Si hay timeout en cadena (p99 > umbral y connections > 80%):
       - Activar RDS Proxy con connection multiplexing inmediatamente
       - Priorizar reversiones de mayor monto (MONEY) sobre las de monto menor
         si el SP permite filtrado por parámetro
       - Reducir Lambda ReservedConcurrency para reversioncrd temporalmente

  C. Si la avalancha está desbordando a bdicheq (cross-DB bdicheq.errors > 0):
       - Activar circuit-breaker bdicred → bdicheq
       - Seguir runbook INC-D04-01 (Reversion storm en bdicheq)
       - Coordinar con SRE de bdicheq la ventana de recuperación compartida

ESCALAR si no resuelve en 25 min: SRE Lead + Cloud Architect AWS + Domain Expert BanCoppel
RTO target: < 25 min (48 callers afectados; riesgo de cascada a 4 dominios cross-DB)
```

---

### INC-D03-03: Caída cruzada a bdicheq — pérdida del 26% de dependencias externas

```
TRIGGER:
  - Alarma bancoppel.bdicred.crossdb.bdicheq.errors > 0.1% en 5 min
  - O: X-Ray muestra spans a bdicheq con error rate elevado
  - O: alertas simultáneas en runbook bdicheq (INC-D04-*)

CONTEXTO:
  bdicred hace 288 llamadas cross-DB hacia bdicheq — la mayor concentración de
  dependencias externas de bdicred con cualquier dominio único. Esas 288 referencias
  representan el 26% (288/1,099) del total cross-DB de bdicred. Si bdicheq cae,
  bdicred pierde acceso a datos de cuenta de cheques que son necesarios para:
  - Validar saldo disponible antes de otorgar crédito o procesar cargo
  - Ejecutar cargos contra cuenta corriente (cargon_ref en bdicheq)
  - Conciliar movimientos de crédito contra cuenta (flujo Caja2 / OFI_WEB)

DIAGNOSTICAR:
  1. CloudWatch — confirmar que el error es en bdicheq y no en bdicred:
       bancoppel.bdicred.crossdb.bdicheq.errors vs bancoppel.bdicred.errors.total
       Si errors.total es bajo pero crossdb.bdicheq.errors es alto: la causa raíz
       está en bdicheq, no en bdicred

  2. Digital Brain — obtener los SPs de bdicred que dependen de bdicheq:
       brain.sps_in_domain('D03')
       # Identificar los SPs con llamadas cross_db = 1 hacia bdicheq
       # Priorizar por fan_in: los de mayor fan_in son los que más callers afectan

  3. X-Ray — aislar los traces que fallan por dependencia bdicheq:
       Filtrar traces de bdicred con span de bdicheq en estado ERROR
       Identificar qué operación de bdicheq es la que falla (cons_sdos2_web,
       cargo_ref u otras observadas en logs de bdicheq)

  4. Coordinar con equipo SRE de bdicheq:
       Verificar si INC-D04-01 (reversion storm) o INC-D04-02 (ischar timeout)
       están activos en bdicheq y son la causa raíz de la indisponibilidad

  5. Evaluar el impacto en OFI_WEB:
       Si las 288 llamadas cross-DB a bdicheq corresponden principalmente al
       módulo Caja2, los cajeros no pueden procesar cargos nuevos → impacto
       operativo inmediato en sucursales

  6. Fuente de los SPs afectados:
       source/informix/  — revisar los SPs de bdicred que hacen
       llamadas cross-DB a bdicheq para entender si tienen fallback local
       o si la dependencia es bloqueante (sin alternativa).

RESOLVER:
  A. Si bdicheq está degradada pero no caída (latencia alta):
       - Aumentar timeout de las llamadas cross-DB bdicred → bdicheq temporalmente
       - Activar circuit-breaker con fallback: responder con datos cacheados (solo lectura)
         para las operaciones que lo permitan (consultas de saldo)
       - Las operaciones de escritura (cargos) deben quedar en cola MSK
         hasta que bdicheq se recupere

  B. Si bdicheq está caída completamente:
       - Activar modo degradado en bdicred:
         suspender operaciones que requieren bdicheq (cargos cruzados)
         mantener operaciones que no requieren bdicheq (consultas de crédito puro)
       - Rollback de tráfico de Caja2/OFI_WEB a Informix legacy si el modo degradado
         no es suficiente para sostener la operación de cajeros
       - Coordinar recuperación con SRE de bdicheq siguiendo INC-D04

  C. Comunicación operativa:
       - Notificar a Domain Expert BanCoppel el alcance del modo degradado
       - Estimar ventana de recuperación con base en el RTO de bdicheq (< 15 min INC-D04)
       - Registrar en el incident log: número de transacciones encoladas pendientes

ESCALAR si no resuelve en 20 min: SRE Lead + SRE bdicheq + Domain Expert BanCoppel
RTO target: < 20 min (288 llamadas cross-DB afectadas; impacto directo en Caja2 / OFI_WEB)
```

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdicred-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_consulta_pre_aprobado",
  "domain": "bdicred",
  "wave": "4",
  "callingSystem": "OFI_WEB",
  "callingModule": "CreditoPreAprobado",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota de PII:** bdicred maneja datos crediticios (scoring, límite aprobado, historial de pagos)
> y datos de tarjeta. Nunca loguear: num_cte, num_tarjeta, score crediticio, datos de buró.
> Solo loguear identificadores anonimizados.
> Marco regulatorio: CNBV Disposiciones de Crédito, LFPDPPP, PCI-DSS, CONDUSEF.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales de SLO requieren
baseline real con QA Lead. `sp_respalda_credito_rr` y `reversioncrd` pendientes de
validación contra `source/informix/` con Specialist Informix SPL Analysis.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 33.99% (CRÍTICO — revisar)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `4394` | 38 | BAJA | Revisar MbUserException en IIB — validar que el SP devuelve el tipo es |
| `3743` | 10 | BAJA | Aumentar timeout en configuración del canal ESB — verificar disponibil |
| `3170` | 7 | BAJA | Investigar con equipo ESB |
| `5714` | 2 | BAJA | Investigar con equipo ESB |
| `3701` | 1 | BAJA | Revisar endpoint SOAP — verificar que el WSDL sea accesible y la respu |

### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Alerta sugerida |
|----|-------------|--------|-----------------|
| `sp_borrardigi` | 1,319 | 99.17% | Alerta si error_rate > 49.6% en 5 min |
| `sp_val_datos_promo` | 516 | 84.3% | Alerta si error_rate > 42.1% en 5 min |
| `sp_consulta_pre_aprobado` | 38,210 | 78.37% | Alerta si error_rate > 39.2% en 5 min |
| `obt_datos_caratula` | 10,621 | 77.54% | Alerta si error_rate > 38.8% en 5 min |
| `sp_tdcoro_web` | 2,273 | 75.63% | Alerta si error_rate > 37.8% en 5 min |
| `sp_consulta_incremento_linea_tc` | 486 | 62.35% | Alerta si error_rate > 31.2% en 5 min |
| `sp_buscarctesamigrar_web` | 6,631 | 12.65% | Alerta si error_rate > 6.3% en 5 min |
| `sp_evaldispefec_cred` | 650 | 7.85% | Alerta si error_rate > 3.9% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

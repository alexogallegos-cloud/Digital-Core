# D04 · bdicheq — Cheques / Cuentas — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Base de datos:** bdicheq (Cheques / Cuentas)
> **Wave:** 4 · Riesgo: **CRÍTICO**
> **Última actualización:** 2026-07-31

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional — cuentas y cargos)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS — datos de cuenta y saldo)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Perfil del dominio

| Atributo | Valor |
|----------|-------|
| SPs totales | 111 |
| LOC totales | 333,811 |
| Ocurrencias MONEY | 18,433 |
| Referencias cross-DB | 512 |
| God procedure — LOC | `ischar` (83,661 LOC, 12 callers, 97 callees) |
| God procedure — callers | `reversion` (7,312 LOC, **377 callers**) |
| God procedure — cargo | `cargon_ref` (8,587 LOC, 70 callers) |
| Cross-DB primarios | bdinteg (130 refs), bdispei (74 refs), bdimnsj (72 refs) |
| Sistemas llamadores (logs) | OFI_WEB, SOBRES_DIGITALES |
| SPs observados en logs | `cons_sdos2_web`, `sp_retiro_sd`, `sp_whatscoppel_consdos`, `cargo_ref` |

> **Nota de fuente:** Los perfiles completos de cada SP se deben validar contra
> `source/informix/{sp_name}.sql` antes de confirmar umbrales de alarma
> en producción. `ischar` (83,661 LOC, 97 callees) y `reversion` (377 callers)
> son los SPs de mayor riesgo arquitectónico del dominio y requieren revisión
> prioritaria de Specialist Informix SPL Analysis.

---

## Patrones de carga validados (logs de producción)

| Ventana | Horario CDMX | Volumen aprox. | Sistemas activos |
|---------|-------------|----------------|-----------------|
| Pico operativo | 10:00 – 14:00 | 80 – 216 MB/hr | OFI_WEB, SOBRES_DIGITALES |
| Valle nocturno | 02:00 – 06:00 | 4 – 7 MB/hr | Procesos batch residuales |
| Ventana batch | 22:00 – 02:00 | Variable | Cierres de cuenta, liquidaciones, conciliación SPEI |

bdicheq es un dominio receptor crítico: además de su propio tráfico de OFI_WEB
y SOBRES_DIGITALES, recibe 288 llamadas cross-DB desde bdicred y 74 desde bdispei.
Cualquier degradación de bdicheq se propaga en cascada hacia esos dominios, afectando
el ciclo completo de crédito y los pagos SPEI en curso. El volumen de callers de
`reversion` (377) convierte a bdicheq en el punto con mayor blast radius de reversiones
de todo Informix.

---

## Arquitectura de observabilidad

```
[bdicheq — Cheques/Cuentas Service (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard bancoppel.bdicheq]
        │
        ├─ [X-Ray traces]  →  [Service Map]  →  [Anomaly detection]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace raíz: bancoppel.bdicheq.*

Fuentes adicionales:
  - Aurora (bdicheq cluster):   AWS/RDS DatabaseConnections, FreeLocalStorage
  - MSK (Kafka topic bdicheq.events):  SumOffsetLag
  - Cross-DB inbound:  trazas X-Ray desde bdicred (288 refs), bdispei (74 refs)
  - Cross-DB outbound: X-Ray spans hacia bdinteg (130), bdispei (74), bdimnsj (72)
```

---

## Métricas clave (Golden Signals)

### 1. Latency — SPs principales

| SP (origen Informix) | Métrica de latencia | Métrica de errores | SLO |
|---------------------|--------------------|--------------------|-----|
| `cons_sdos2_web` | `bancoppel.bdicheq.cons_sdos2_web.latency` | `bancoppel.bdicheq.cons_sdos2_web.errors` | [SME-PENDING] ms |
| `sp_retiro_sd` | `bancoppel.bdicheq.retiro_sd.latency` | `bancoppel.bdicheq.retiro_sd.errors` | [SME-PENDING] ms |
| `sp_whatscoppel_consdos` | `bancoppel.bdicheq.whatscoppel_consdos.latency` | `bancoppel.bdicheq.whatscoppel_consdos.errors` | [SME-PENDING] ms |
| `cargo_ref` | `bancoppel.bdicheq.cargo_ref.latency` | `bancoppel.bdicheq.cargo_ref.errors` | [SME-PENDING] ms |
| `reversion` | `bancoppel.bdicheq.reversion.latency` | `bancoppel.bdicheq.reversion.errors` | [SME-PENDING] ms |
| `ischar` | `bancoppel.bdicheq.ischar.latency` | `bancoppel.bdicheq.ischar.errors` | [SME-PENDING] ms |

### 2. Traffic (throughput)

| Métrica | Namespace | Descripción |
|---------|-----------|------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones al servicio bdicheq |
| `ConcurrentExecutions` | `AWS/Lambda` | Ejecuciones concurrentes (alerta si > 80% del límite) |
| `bancoppel.bdicheq.requests.total` | Custom | Total de requests al microservicio |
| `bancoppel.bdicheq.reversiones.rate` | Custom | Tasa de reversiones/min vía `reversion` (377 callers) |
| `bancoppel.bdicheq.spei.inbound.requests` | Custom | Llamadas inbound desde bdispei (SPEI) |

### 3. Errors

| Métrica | Umbral de alarma | Severidad |
|---------|-----------------|----------|
| `Errors` (Lambda) | > 0.1% en 5 min | WARNING |
| `Throttles` (Lambda) | > 0 en 1 min | CRITICAL |
| `bancoppel.bdicheq.errors.l4` (divergencias financieras MONEY) | > 0 | CRITICAL (rollback inmediato) |
| Aurora `DatabaseConnections` | > 80% del max | WARNING |
| Aurora `FreeLocalStorage` | < 20% | WARNING |
| `bancoppel.bdicheq.reversiones.rate` | pico > 3x baseline | CRITICAL (reversion storm) |
| `bancoppel.bdicheq.ischar.errors` | > 0 | CRITICAL (97 callees bloqueados) |
| `bancoppel.bdicheq.spei.latency` | [SME-PENDING] ms | CRITICAL (pagos SPEI degradados) |

### 4. Saturation

| Recurso | Métrica | Umbral |
|---------|---------|--------|
| Lambda concurrencia | `ConcurrentExecutions / ReservedConcurrency` | > 80% → scale review |
| Aurora connections | `DatabaseConnections / MaxConnections` | > 80% → connection pooling |
| MSK (Kafka) lag | `SumOffsetLag` | > 10,000 mensajes → investigate |
| Cross-DB inbound bdicred | `bancoppel.bdicheq.crossdb.inbound.bdicred.latency` | [SME-PENDING] ms — 288 refs |
| Cross-DB inbound bdispei | `bancoppel.bdicheq.crossdb.inbound.bdispei.latency` | [SME-PENDING] ms — 74 refs SPEI |

---

## SLOs del dominio

> `[SME-PENDING]` — Los SLOs definitivos requieren baseline de QA Lead con carga real de pico (10:00–14:00 CDMX).

| Indicador | SLO target | Error budget | Estado |
|-----------|------------|--------------|--------|
| Disponibilidad servicio bdicheq | [SME-PENDING] % | [SME-PENDING] min/mes | Pendiente |
| Latencia p99 `reversion` (377 callers) | [SME-PENDING] ms | — | Pendiente |
| Latencia p99 `ischar` (83,661 LOC) | [SME-PENDING] ms | — | Pendiente |
| Latencia p99 SPEI-to-cheq cross-DB | [SME-PENDING] ms | — | Pendiente |
| Divergencias financieras MONEY | 0 eventos/mes | — | Pendiente |

---

## CloudWatch Dashboard — widgets obligatorios

```json
[
  {"title": "Latencia p50/p95/p99 — SPs clave", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "reversion.latency.p99"],
                ["bancoppel/bdicheq", "ischar.latency.p99"],
                ["bancoppel/bdicheq", "cargo_ref.latency.p99"]]},
  {"title": "Reversion storm monitor (377 callers)", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "reversiones.rate"]]},
  {"title": "ischar errors (97 callees en riesgo)", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "ischar.errors"],
                ["bancoppel/bdicheq", "errors.l4"]]},
  {"title": "SPEI inbound latency y errors", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "spei.inbound.requests"],
                ["bancoppel/bdicheq", "spei.latency"]]},
  {"title": "Throughput por sistema llamador", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "requests.ofi_web"],
                ["bancoppel/bdicheq", "requests.sobres_digitales"]]},
  {"title": "Aurora connections bdicheq", "type": "metric",
    "metrics": [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "bdicheq-aurora"]]},
  {"title": "Cross-DB outbound (bdinteg 130 / bdispei 74 / bdimnsj 72)", "type": "metric",
    "metrics": [["bancoppel/bdicheq", "crossdb.bdinteg.latency"],
                ["bancoppel/bdicheq", "crossdb.bdispei.latency"],
                ["bancoppel/bdicheq", "crossdb.bdimnsj.latency"]]},
  {"title": "X-Ray Service Map", "type": "trace_map"}
]
```

---

## Runbook de incidentes

### INC-D04-01: Reversion storm — `reversion` con 377 callers en pico simultáneo

```
TRIGGER:
  - Alarma bancoppel.bdicheq.reversiones.rate supera 3x el baseline de la ventana horaria
  - O: bancoppel.bdicheq.reversion.latency.p99 supera umbral
  - O: Lambda Throttles > 0 para el servicio bdicheq durante ventana de quincena o batch

CONTEXTO:
  reversion tiene 7,312 LOC y 377 callers directos — el SP con mayor fan_in de callers
  en todo bdicheq y uno de los más altos de Informix completo. Durante quincenas
  (días 15 y 30) o eventos de batch parcialmente fallidos, múltiples callers pueden
  disparar reversiones simultáneas. Con 7,312 LOC por ejecución, el timeout en cadena
  puede saturar el pool de Aurora bdicheq en segundos. bdicred (288 refs inbound) y
  bdispei (74 refs inbound) quedan degradados como consecuencia directa, afectando
  el crédito y los pagos SPEI activos en ese momento.

DIAGNOSTICAR:
  1. CloudWatch Metrics — confirmar el pico y su magnitud:
       Gráfica bancoppel.bdicheq.reversiones.rate en ventana de 30 minutos
       Comparar con baseline histórico de la misma franja horaria y día del mes
       Si el incidente ocurre en día 15 o 30: escenario de quincena (esperado, pero
       debe estar dentro del capacity plan)

  2. Digital Brain — obtener los callers de reversion para cuantificar el blast radius:
       brain.callers_of('reversion', limit=100)
       # Con 377 callers, solo los de mayor fan_in son accionables en tiempo real;
       # identificar los 10 de mayor fan_in y verificar cuáles están activos en los logs

  3. Digital Brain — obtener perfil del SP y sus reglas de negocio:
       brain.sp('bdicheq:reversion')
       brain.rules_of_sp('reversion')
       # Buscar lógica de reintento automático que pueda multiplicar el volumen

  4. Aurora bdicheq — verificar saturación de conexiones durante el pico:
       DatabaseConnections / MaxConnections: si > 80%, la aurora está saturada
       Performance Insights → top SQL por número de ejecuciones en la ventana

  5. X-Ray — verificar si la storm de reversiones está propagándose cross-DB:
       Buscar spans fallidos hacia bdinteg (130 refs) o bdimnsj (72 refs)
       Si bdicred está reportando INC-D03-02 simultáneamente: es la misma storm
       vista desde ambos dominios

  6. Fuente del SP:
       source/informix/reversion.sql
       Validar con Specialist Informix SPL Analysis si el SP tiene locks exclusivos
       durante su ejecución y durante cuánto tiempo los mantiene (7,312 LOC).

RESOLVER:
  A. Si el volumen es legítimo y dentro del capacity plan (quincena):
       - Aplicar rate limiting en API Gateway para el endpoint de reversiones:
         reducir concurrencia a un nivel que Aurora pueda absorber sin saturarse
       - Encolar el exceso en MSK topic bdicheq.reversiones.pending
         para reproceso ordenado con monitoreo de lag
       - Notificar a Domain Expert BanCoppel que la ventana de procesamiento
         se extenderá más allá de lo habitual en quincena

  B. Si hay timeout en cadena (p99 > umbral y connections > 80%):
       - Activar RDS Proxy con connection multiplexing inmediatamente
       - Escalar Lambda ReservedConcurrency para bdicheq si hay capacidad disponible
       - Priorizar reversiones de mayor MONEY si el SP permite filtrado por parámetro

  C. Si la storm está afectando bdicred y bdispei (cross-DB inbound degradado):
       - Activar circuit-breaker en los endpoints que reciben de bdicred y bdispei
       - Comunicar a SRE de bdicred (INC-D03-02) y SRE de bdispei el estado
       - Coordinar ventana de recuperación conjunta

ESCALAR si no resuelve en 15 min: SRE Lead + Cloud Architect AWS + Domain Expert BanCoppel
RTO target: < 15 min (377 callers afectados; propagación cross-DB a bdicred y bdispei)
```

---

### INC-D04-02: ischar timeout — god SP de 83,661 LOC con 97 callees bloqueados

```
TRIGGER:
  - Alarma bancoppel.bdicheq.ischar.errors > 0
  - O: bancoppel.bdicheq.ischar.latency.p99 supera umbral
  - O: errores en cascada en SPs de bdicheq sin correlación con tráfico externo
    (señal de que ischar está bloqueando a sus 97 callees)

CONTEXTO:
  ischar tiene 83,661 LOC — el mayor god SP de bdicheq — y llama directamente a
  97 callees con solo 12 callers directos. Su patrón es opuesto al de reversion:
  pocos callers que desencadenan un árbol masivo de 97 dependencias downstream.
  Cualquier lock en las tablas base de ischar bloquea toda la cadena de llamadas
  de sus callees simultáneamente. Con 18,433 campos MONEY en bdicheq, un bloqueo
  de ischar puede afectar el procesamiento de saldos, cargos y retiros activos.

DIAGNOSTICAR:
  1. Digital Brain — obtener el árbol completo de callees de ischar:
       brain.callees_of('ischar', limit=97)
       # Identificar cuáles de los 97 callees tienen mayor fan_in propio;
       # son los que generan mayor impacto cuando ischar los bloquea

  2. Digital Brain — obtener perfil del SP:
       brain.sp('bdicheq:ischar')
       brain.rules_of_sp('ischar')
       # Las reglas pueden revelar qué tablas base usa y en qué condiciones
       # ischar entra en una ruta de ejecución especialmente larga

  3. Aurora bdicheq — verificar lock contention en tablas base de ischar:
       CloudWatch DB Load → wait events durante la ventana del incidente
       Performance Insights → top SQL por wait time
       Identificar si hay una sesión externa (bdicred inbound, bdispei inbound)
       que esté bloqueando las tablas que ischar necesita

  4. X-Ray — identificar en qué sub-tramo de ischar ocurre el bloqueo:
       Expandir el span de ischar y verificar sub-spans de sus callees;
       el primer sub-span en estado PENDING o ERROR apunta al callee bloqueante

  5. Verificar si el incidente coincide con tráfico inbound de bdicred (288 refs):
       Un pico de llamadas desde bdicred puede generar lock contention en
       las tablas de cuenta que ischar también necesita leer o escribir

  6. Fuente del SP:
       source/informix/ischar.sql
       Con 83,661 LOC, localizar los bloques de BEGIN WORK / COMMIT WORK
       que contienen locks exclusivos. Validar con Specialist Informix SPL Analysis
       la duración esperada de cada lock bajo carga de pico (80–216 MB/hr).

RESOLVER:
  A. Si el bloqueo es por lock de otra sesión (bdicred inbound o bdispei):
       - Identificar sesión bloqueante en Performance Insights
       - Matar sesión bloqueante solo con autorización de DBA IBM Informix IDS
       - Activar circuit-breaker temporal en la integración hacia bdicheq
         desde bdicred y bdispei para reducir la presión de conexiones concurrentes

  B. Si el bloqueo es interno a ischar (ruta de 83,661 LOC especialmente larga):
       - Rollback de tráfico a Informix legacy vía AppConfig feature flag
       - Notificar: Specialist Informix SPL Analysis + QA Lead
       - Documentar los parámetros exactos de entrada que desencadenaron la ruta larga
         como caso de prueba prioritario en el golden master

  C. Si hay 97 callees en estado bloqueado simultáneamente:
       - Evaluar si es necesario reiniciar el servicio Lambda bdicheq para limpiar
         las conexiones pendientes (solo con autorización SRE Lead)
       - Priorizar el reproceso de los callees de mayor fan_in una vez que ischar
         vuelva a estar operativo

ESCALAR si no resuelve en 20 min: SRE Lead + Specialist Informix SPL Analysis + DBA IBM Informix IDS
RTO target: < 20 min (97 callees bloqueados; 18,433 campos MONEY en riesgo)
```

---

### INC-D04-03: SPEI-to-cheq cross-DB latency — pagos SPEI degradados

```
TRIGGER:
  - Alarma bancoppel.bdicheq.spei.latency supera umbral
  - O: bancoppel.bdicheq.crossdb.inbound.bdispei.latency supera umbral
  - O: alertas de bdispei reportando timeouts en llamadas hacia bdicheq
  - O: reporte operativo de pagos SPEI en estado "pendiente" por más tiempo del esperado

CONTEXTO:
  bdicheq recibe 74 llamadas cross-DB inbound desde bdispei (SPEI). Estas llamadas
  son parte del flujo de acreditación SPEI: cuando bdispei recibe un pago entrante,
  necesita consultar y actualizar la cuenta destino en bdicheq. Si bdicheq se degrada
  — por un reversion storm (INC-D04-01), por ischar timeout (INC-D04-02), o por
  saturación de Aurora — bdispei no puede completar la acreditación y los pagos SPEI
  quedan en estado "pendiente" con riesgo regulatorio frente a Banxico (SPEI tiene
  SLAs de acreditación de segundos, no de minutos).

DIAGNOSTICAR:
  1. CloudWatch — confirmar que la latencia es en bdicheq y no en bdispei:
       bancoppel.bdicheq.spei.latency (latencia de bdicheq procesando las llamadas de bdispei)
       vs. latencia interna de bdispei
       Si la latencia alta es en bdicheq: la causa raíz está en este dominio

  2. Verificar si hay un incidente activo en bdicheq que explique la degradación:
       - INC-D04-01 activo (reversion storm): bdicheq saturado por 377 callers
       - INC-D04-02 activo (ischar timeout): ischar bloqueó tablas que bdispei necesita
       - Saturación de Aurora (DatabaseConnections > 80%): pool agotado

  3. Digital Brain — identificar los SPs de bdicheq que reciben llamadas desde bdispei:
       brain.sps_in_domain('D04')
       # Filtrar SPs con cross_db = 1 y origen en bdispei
       # Confirmar qué operaciones de cuenta son afectadas (consulta de saldo,
       # acreditación, actualización de movimiento)

  4. X-Ray — rastrear los traces de bdispei que fallan al llamar a bdicheq:
       Filtrar por span bdicheq con origen bdispei en estado ERROR o TIMEOUT
       Identificar el SP específico de bdicheq que no responde

  5. Verificar el volumen de pagos SPEI pendientes:
       MSK topic bdicheq.spei.pending → SumOffsetLag
       Si el lag supera 10,000 mensajes: hay acumulación que puede crecer exponencialmente
       hasta que bdicheq se recupere

  6. Fuente de los SPs afectados:
       source/informix/  — revisar los SPs de bdicheq que reciben
       llamadas cross-DB desde bdispei (74 refs)
       Validar con Specialist Informix SPL Analysis si los SPs tienen lógica de
       retry o si la falla es silenciosa (sin señal a bdispei).

RESOLVER:
  A. Si la degradación de bdicheq es causada por INC-D04-01 o INC-D04-02:
       - Resolver el incidente primario primero (reversion storm o ischar timeout)
       - Una vez que bdicheq se estabiliza, procesar los pagos SPEI encolados
         en MSK en orden de llegada, con monitoreo de lag hasta que se vacíe la cola

  B. Si la degradación es por saturación de Aurora (sin incidente secundario):
       - Activar RDS Proxy con connection multiplexing
       - Priorizar las conexiones de bdispei frente a tráfico interno de bdicheq
         para cumplir el SLA regulatorio de Banxico sobre acreditación SPEI

  C. Si los pagos SPEI llevan más de 5 min en estado "pendiente":
       - Notificar inmediatamente a: Domain Expert BanCoppel + Program Manager + Cybersecurity
       - Verificar el umbral regulatorio de Banxico para pagos SPEI diferidos
       - Activar el procedimiento de comunicación a Banxico si aplica (validar
         con Domain Expert BanCoppel el umbral exacto de notificación obligatoria)
       - Documentar cada pago afectado con timestamp de inicio de degradación

  D. Reproceso post-recuperación:
       - Confirmar con bdispei que todos los pagos en MSK.spei.pending fueron
         acreditados correctamente en bdicheq
       - Conciliar los movimientos procesados contra el golden master de bdispei
         para detectar posibles dobles acreditaciones por reintento

ESCALAR si no resuelve en 10 min: SRE Lead + Cloud Architect AWS + Domain Expert BanCoppel
(SLA SPEI de Banxico — escalar a 10 min, no a 30 min)
RTO target: < 10 min (pagos SPEI tienen SLA regulatorio de Banxico — máxima urgencia)
```

---

### INC-D04-04: Sobres Digitales — latencia P95 extrema (35–220s en operaciones SD)

```
TRIGGER:
  - P95 de bancoppel.bdicheq.{retiro,abono,crea,edic,perso,consmov}_sd.latency supera 10s
  - O: usuarios reportan lentitud o timeout en operaciones de Sobres Digitales
  - O: errores 00009/00010 con volumen inusual sin correlación con cambio de tráfico —
    puede indicar abortos por timeout dentro de sp_retiro_sd o sp_abono_sd

CONTEXTO:
  En producción (logs 2026-04-24), los SPs de Sobres Digitales muestran P95 de 35–220s.
  Esta latencia NO la genera Informix — las transacciones bancarias (UPDATE/INSERT en
  sc_mae_sd + sc_mov_sd) se completan en milisegundos. Las causas son estructurales:

  (1) NOTIFICACIONES SÍNCRONAS POST-COMMIT — sp_retiro_sd, sp_crea_sd, sp_abono_sd,
      sp_edic_sd: todos ejecutan bdimnsj:sp_registra_evento (push y/o mail) DESPUÉS del
      COMMIT, dentro del mismo flujo ESB. Si D09-bdimnsj tiene carga, el cliente espera
      la confirmación de encolado antes de recibir la respuesta bancaria.

  (2) CONTADOR GLOBAL sc_param (concsd) — sp_crea_sd: UPDATE en fila única de sc_param
      serializa todas las creaciones concurrentes. Con 6,394 creaciones/día en pico, cada
      operación bloqueada espera hasta 3s (SET LOCK MODE TO WAIT 3).

  (3) sp_retencion_cobranza_automatica — sp_retiro_sd: SP añadido en RQM 09 704 (oct-2025),
      ejecutado post-COMMIT. Puede ser lento si la cuenta tiene posiciones de crédito activas.

  (4) LOCK CONTENTION + POSIBLE FULL SCAN — sp_perso_sd (P95=202s) y sp_consmov_sd
      (P95=220s, P50=44s): ambos SPs son simples (1 UPDATE / 1 FOREACH) sin llamadas
      cross-domain. El P50=44s de sp_consmov_sd evidencia una consulta lenta en condiciones
      no congestionadas — indicador de índice insuficiente en sc_mov_sd para el patrón
      WHERE cuenta_sobre=? AND cuenta_eje=? ORDER BY fecha_operacion DESC.

  En el target Aurora los patrones 1 y 2 desaparecen por diseño. El target debe medir:
  - SLO-AM-02a: P95 confirmación bancaria (operación DB pura) ≤ 2s
  - SLO-AM-02b: P95 entrega de notificación ≤ 30s (medido en el servicio de mensajería)

DIAGNOSTICAR:
  1. Localizar si el span lento es DB o notificación:
       X-Ray → expandir span del SP y ver sub-span más largo
       Si el sub-span lento es una llamada saliente a D09-bdimnsj → causa 1
       Si el sub-span lento está dentro de la transacción Aurora → causa 3 o 4

  2. Si D09-bdimnsj está degradado (causa 1):
       MSK topic bd09.mensajeria.outbound → SumOffsetLag
       Si lag > 10,000: D09 bajo presión — notificaciones en cola

  3. Si hay lock contention en Aurora (causa 4):
       Performance Insights → top wait events en sc_mae_sd / sc_mov_sd
       Verificar si sp_cobroauto_sd (batch de cobranza automática, FOREACH de 1,000 en 1,000)
       está corriendo concurrentemente — genera locks en sc_mov_sd
       Para sp_consmov_sd: ejecutar EXPLAIN y confirmar si hay índice en
         (cuenta_sobre, cuenta_eje, fecha_operacion DESC) — si no existe, es full/partial scan

RESOLVER:
  A. D09 degradado — notificaciones síncronas atascadas:
       Activar circuit-breaker: notificaciones al DLQ del MSK topic correspondiente;
       el cliente recibe la confirmación bancaria inmediata
       Notificar a SRE de D09-bdimnsj
       Procesar DLQ en orden de llegada una vez que D09 se recupere

  B. Batch sp_cobroauto_sd en horario de pico (lock contention):
       Throttle del batch para liberar sc_mov_sd durante pico diurno (10:00–14:00 CDMX)
       Rate limiting en endpoints SD durante el período de contención

  C. sp_consmov_sd con full scan en sc_mov_sd:
       Crear índice en sc_mov_sd (cuenta_sobre, cuenta_eje, fecha_operacion DESC)
       con el DBA IBM Informix IDS en ventana de mantenimiento nocturna
       En el target Aurora: CREATE INDEX CONCURRENTLY antes del parallel-run

ESCALAR si no resuelve en 15 min: SRE Lead + Domain Expert BanCoppel
(Sobres Digitales es producto de captación activa — impacto directo en clientes)
RTO target: < 15 min
```

---

## Análisis de causa raíz — Sobres Digitales

> **Fuente**: análisis de código SPL · `source/informix/bdicheq_sp_*.sql` · 2026-08-03
> **SPs analizados**: sp_retiro_sd (P95=208s) · sp_crea_sd (P95=144s) · sp_abono_sd (P95=188s) · sp_edic_sd (P95=187s) · sp_perso_sd (P95=202s) · sp_consmov_sd (P95=220s)

La latencia observable de 35–220s en los SPs de Sobres Digitales no es generada por Informix. El motor de base de datos completa las transacciones de negocio (UPDATE sc_mae_sd + INSERT sc_mov_sd + UPDATE sc_maechq) en milisegundos. Las cuatro causas raíz identificadas por lectura directa del código fuente SPL:

| Causa | SPs afectados | Mecanismo | Implicación en target |
|-------|---------------|-----------|----------------------|
| Notificaciones síncronas post-COMMIT a bdimnsj | retiro · crea · abono · edic | `EXECUTE PROCEDURE bdimnsj:sp_registra_evento` después del COMMIT — espera confirmación de D09 | Publicar evento asíncrono (Kafka/SNS); retornar confirmación bancaria inmediata |
| Contador global sc_param (campo `concsd`) | crea | UPDATE en fila única serializa todas las creaciones concurrentes bajo WAIT 3 | ID via secuencia DB, UUID o Snowflake ID |
| sp_retencion_cobranza_automatica en ruta crítica | retiro | SP añadido RQM 09 704 oct-2025; ejecutado post-COMMIT sobre tablas de crédito | Evaluar si puede moverse a proceso asíncrono o ejecutarse en paralelo |
| Lock contention + ausencia de índice eficiente | perso · consmov | 70K ops/día en sc_mae_sd/sc_mov_sd · WAIT 3 · P50 de sp_consmov_sd = 44s sin bloqueo | Índice compuesto en sc_mov_sd (cuenta_sobre, cuenta_eje, fecha_operacion DESC) antes del parallel-run |

**sp_consmov_sd** es el caso más revelador: FOREACH simple sobre sc_mov_sd sin ninguna llamada cross-domain, pero P50=44s. El P50 alto en condiciones no congestionadas es la firma de una consulta sin índice eficiente: cada llamada hace un partial o full scan sobre sc_mov_sd para encontrar los movimientos de una cuenta_sobre específica ordenados por fecha.

**sp_perso_sd** confirma el patrón de lock contention: solo 1 UPDATE en sc_mae_sd, sin llamadas externas, P95=202s. Con 41,546 retiros + 25,414 abonos + 6,394 creaciones/día que actualizan sc_mae_sd concurrentemente, las operaciones simples quedan atrapadas en cola de locks bajo WAIT 3.

### SLO-AM-02 — Redefinición requerida para Sobres Digitales

Comparar directamente P95 del target con P95 del legacy en SPs de SD es incorrecto. El P95 legacy incluye el tiempo de notificaciones síncronas a D09; el target tendrá notificaciones asíncronas por diseño — ese tiempo desaparece de la operación bancaria.

| SLO | Alcance | Umbral objetivo target |
|-----|---------|------------------------|
| SLO-AM-02a | Confirmación de la transacción bancaria (DB + validaciones, excluyendo notificación) | P95 ≤ 2s |
| SLO-AM-02b | Entrega de notificación push / email | P95 ≤ 30s · medido en el servicio de mensajería independientemente |
| ~~SLO-AM-02 original~~ | ~~P95 target ≤ P95 legacy~~ | No aplicable directamente para SPs de SD — comparación con el legacy incluiría latencia de notificación que el target no tendrá |

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-07-31T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdicheq-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "cons_sdos2_web",
  "domain": "bdicheq",
  "wave": "4",
  "callingSystem": "OFI_WEB",
  "inboundCrossDb": "none",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota de PII:** bdicheq maneja saldos de cuenta, movimientos de cheques y datos de retiro
> (especialmente `sp_retiro_sd` y `sp_whatscoppel_consdos`). Nunca loguear: num_cuenta,
> num_cte, saldo, clabe interbancaria. Solo loguear identificadores anonimizados.
> Marco regulatorio: CNBV, Banxico (SPEI), LFPDPPP, PCI-DSS.

---

*Generado por: SRE & AIOps · 2026-07-31 · [SME-PENDING] umbrales de SLO requieren
baseline real con QA Lead. `ischar` (83,661 LOC, 97 callees) y `reversion` (377 callers)
son los SPs de mayor riesgo arquitectónico del dominio y requieren validación prioritaria
contra `source/informix/` con Specialist Informix SPL Analysis. El RTO de
INC-D04-03 (SPEI) es 10 min por SLA regulatorio Banxico — validar el umbral exacto
de notificación obligatoria con Domain Expert BanCoppel.*

<!-- LOG-DATA-BEGIN -->
## Patrones de incidente observados — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Error rate del dominio:** 4.73% (Normal)

### Acciones por código de error

| Código | Vol/día | Prioridad | Acción inmediata |
|--------|---------|-----------|-----------------|
| `4395` | 517 | MEDIA | Verificar NullPointerException en el plugin Java — revisar datos de en |
| `4394` | 208 | MEDIA | Revisar MbUserException en IIB — validar que el SP devuelve el tipo es |
| `3743` | 42 | BAJA | Aumentar timeout en configuración del canal ESB — verificar disponibil |

### SPs críticos para monitoring

| SP | Llamadas/día | Error% | Alerta sugerida |
|----|-------------|--------|-----------------|
| `sp_whatscoppel_consdos` | 32,975 | 48.67% | Alerta si error_rate > 24.3% en 5 min |
| `consnomtit` | 4,001 | 9.37% | Alerta si error_rate > 4.7% en 5 min |
| `sp_consmov_sd` | 2,260 | 5.62% | Alerta si error_rate > 2.8% en 5 min |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->

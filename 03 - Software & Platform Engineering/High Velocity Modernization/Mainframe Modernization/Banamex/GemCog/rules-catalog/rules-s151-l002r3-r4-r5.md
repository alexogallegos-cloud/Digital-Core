# Reglas de Negocio — BC-04 ACL GL Interface: L002R3 · L002R4 · L002R5 (ALGOL)
> Bounded Context: BC-04 ACL GL Interface
> Sistema: S151 GL | Tecnología: ALGOL ClearPath MCP | Tipo: Librería multi-canal
> Rango total: RN-S151-633..689 | Total: 57 reglas
> Generado: 2026-07-16 · Extracción directa por coordinador (estrategia por chunks)
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

## Resumen de contenido

| Programa | Rango IDs | Reglas | Descripción |
|----------|-----------|--------|-------------|
| L002R3 | 633..659 | 27 | Librería multi-canal base — PROC_CONTROL, ARMALOG/ARMADES, GRABALOG, BAJA |
| L002R4 | 660..674 | 15 | Versión con dispatch explícito — REBLOCKADE, FINAL, COMMPOST, B05 registro |
| L002R5 | 675..689 | 15 | Versión enriquecida — P015/P016 directo, FILLERXAPL, LYENDA1-5, P025 |

## Arquitectura del BC-04 ACL GL Interface

```
Consumidores:                    L002R3/R4/R5 (REGISTRAS)        Archivos:
P015 (intraday)  ──────────────→ [GRABALOG / CARGAMOV]   ──────→ LOGS[0:9]  MOV
P016 (nightly)   ──────────────→ [ELIMINA]               ──────→ DESS[0:9]  DES
P025 (recovery)  ──────────────→ [INICIA/TERMINA]        ──────→ SDOS[0:9]  SDO
                                  [REBLOCKADE]                   CBII[0:9]  (S500)
                                  [PREFINAL/FINAL]               CDIR[0:9]  (S500)
                                  [BAJA/PROC_CONTROL]
```

## Diferencias clave entre versiones

| Característica | L002R3 | L002R4 | L002R5 |
|----------------|--------|--------|--------|
| Tamaño fuente | 9,355 LOC | 7,280 LOC | 7,414 LOC |
| SIST_LIB soportados | 500 | 151,500,403,404 | 151,500,403,404 |
| Dispatch FUNCION | Implícito (CARGAMEMORY) | CASE 10 funciones | CASE 10 funciones |
| REBLOCKADE | No | Sí (31=10800, 32=150) | Sí |
| Lanzamiento P015/P016 | PROC_CONTROL LEVANTA_PASOS | PROC_CONTROL | CARGAMOV directo |
| Lanzamiento P025 | PROC_CONTROL | PROC_CONTROL | CARGAMOV (TIPPROC>15) |
| FILLERXAPL 165w | No | No | Sí |
| LYENDA1-5 | No | No | Sí |
| COMMPOST/CPOST | No | Sí (comentado) | Sí (comentado) |
| B05 registro | No | Sí (FUNCION=19) | Sí |
| Validación sistema | IDFSISTFAN | IDFSISTFAN | IDFSISTEMA |
| Offsets BCO_ORIG/DEST | — | 342+345 (3 dig) | 262+267 (5 dig) |

## Gaps de numeración

| Rango | Uso |
|-------|-----|
| 633..659 | L002R3 (27 reglas) |
| 660..674 | L002R4 (15 reglas) |
| 675..689 | L002R5 (15 reglas) |
| 690..709 | Reserva BC-04 (futuros hallazgos) |

---

# Reglas de Negocio — L002R3 (ALGOL)
> Programa: L002R3 (REGISTRAS) | Sistema: S151 GL | BC: BC-04 ACL GL Interface
> Rango: RN-S151-633..659 | Total: 27 reglas
> Extracción directa (coordinador) — secciones leídas del código fuente:
>   líneas 5530-5590 (forward declarations), 6060-6195 (GRABALOG+SEPARA_S500),
>   6510-6583 (CARGAMEMORY+ACTNIVEL+ELIMINA+INICIA+TERMINA),
>   7985-8084 (CARGACVES), 8120-8440 (LEVANTA/ARMALOG/ARMADES),
>   9020-9275 (BAJA+EJECUTA_P169+PROC_CONTROL completo)

## Contexto arquitectónico

L002R3 es la librería ALGOL (proceso MCP biblioteca) que gestiona los 10 canales paralelos de archivo MOV (movimientos) y DES (descriptores) del GL bancario S151. Opera como proceso servidor: P015 (intraday), P016 (noche) y P025 (recuperación) se enlistan como consumidores y llaman sus procedimientos exportados.

---

## RN-S151-633 — Arquitectura multi-canal con 10 canales concurrentes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-633 |
| **Nombre** | Arquitectura multi-canal con 10 canales concurrentes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L002R3 mantiene 10 canales paralelos (arrays LOGS[0:9], DESS[0:9], CBII[0:9], CDIR[0:9]). La variable NUMDIAC1 indica el canal activo según el día contable en curso. Cada canal tiene su propio write pointer (NIVLOG_A[i]), fecha (FEC_DIA[i]) y contador de registros pendientes (REG_X_BLOCK[i]).

**Impacto migración:** Debe replicarse la semántica multi-canal — probablemente como 10 particiones/hilos independientes con su propio cursor de escritura y fecha de contabilización.

---

## RN-S151-634 — Convención de nombre de archivo MOV y DES por fecha

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-634 |
| **Nombre** | Convención de nombre de archivo MOV y DES por fecha |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_MAESTRO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Nombre del archivo MOV = `ARC_MOV + FECDIA(6 dígitos) + " ON " + PK_MOV + "."`. Archivo DES = `ARC_DES + FECDIA + " ON " + PK_DES + "."`. La fecha AAAMMDD está embebida en el nombre — determina qué archivo se abre para cada día contable. Archivo SDO (saldos) sigue el mismo patrón con ARC_SDO/PK_SDO.

**Impacto migración:** La lógica de localización de archivos por fecha debe reemplazarse por consulta a store con clave (canal, fecha). Los nombres de archivo físico no tienen equivalente en arquitecturas cloud.

---

## RN-S151-635 — Doble validación del encabezado al abrir archivo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-635 |
| **Nombre** | Doble validación del encabezado al abrir archivo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VALIDACION |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al abrir cualquier archivo MOV, DES o SDO, se validan dos condiciones: (1) `HFUNCION ≠ 99` — el encabezado no es centinela (archivo no cerrado previamente); (2) `HFECLOG = FECDIA` — fecha del encabezado coincide con la fecha de procesamiento activa. Ambas condiciones deben cumplirse. Si alguna falla, el archivo se rechaza y se activa el flujo de recuperación por operador.

**Impacto migración:** La integridad temporal del archivo (fecha embedded en encabezado) debe validarse en la capa de apertura de partición equivalente.

---

## RN-S151-636 — Búsqueda binaria del centinela FUNCION=99

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-636 |
| **Nombre** | Búsqueda binaria del centinela FUNCION=99 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ALGORITMO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al inicializar cada canal (ARMALOG/ARMADES), se ejecuta búsqueda binaria para localizar el registro centinela (FUNCION=99) — el marcador del último registro válido escrito. La posición encontrada se almacena en NIVLOG_A[canal] y sirve como write pointer para escrituras subsecuentes de GRABALOG. La búsqueda es necesaria porque el archivo puede tener "huecos" de registros de sesiones previas.

**Referencia cruzada:** Ver RN-S151-026 (P109) para el centinela W77-EOF equivalente en COBOL.

**Impacto migración:** En arquitecturas modernas el write pointer es el offset/secuencia de la partición. No hay centinela embedded. El concepto de centinela FUNCION=99 no tiene equivalente directo — reemplazar por cursor de escritura persistente.

---

## RN-S151-637 — Recuperación de archivo faltante por intervención de operador

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-637 |
| **Nombre** | Recuperación de archivo faltante por intervención de operador |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RECUPERACION / OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si un archivo MOV o DES no se encuentra al intentar abrirse (OPEN falla): (1) Se envía mensaje `"FALTA ARCHIVO {nombre} FAVOR DE COPIARLO"` a consola del operador via LJ. (2) Se ejecuta ACCEPT — el proceso queda suspendido esperando respuesta del operador. (3) Se reintenta apertura via GO VERIFICA (loop de reintento). El proceso permanece bloqueado hasta que el operador copie el archivo correcto al directorio esperado.

**Impacto migración:** La dependencia en intervención humana manual (ACCEPT en consola) debe reemplazarse por alertas automáticas (PagerDuty/Slack) + re-encolamiento con SLA. El operador ya no puede "copiar" un archivo a un path — la recuperación debe ser via re-procesamiento de la fuente o restore de snapshot.

---

## RN-S151-638 — Timeout de 30 segundos para cierre automático de archivos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-638 |
| **Nombre** | Timeout de 30 segundos para cierre automático de archivos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | TIEMPO_REAL / RENDIMIENTO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** PROC_CONTROL usa `WAITANDRESET((30), MYSELF.EXCEPTIONEVENT, BLOCK_LLENO, LEVANTA_PASOS, INICIA_DIA, RESET_EVE, AMBIENTA)`. En timeout de 30 segundos (Evento 1): cierra (CIERRALOG) todos los canales donde `REG_X_BLOCK[i] > 0 AND NIVLOG_A[i] > 0 AND FEC_DIA[i] >= FEC_PRO_BASE`. No cierra canales sin registros pendientes ni con fecha anterior a FEC_PRO_BASE. Resets REG_X_BLOCK_D = 0 y REG_X_BLOCK_DX = 0.

**Impacto migración:** El timeout de 30 segundos es un flush automático de buffers. En migración debe implementarse como flush periódico con el mismo SLA temporal. FEC_PRO_BASE debe mapearse como la fecha de procesamiento mínima aceptable.

---

## RN-S151-639 — BLOCK_LLENO: cierre acumulativo al 20° evento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-639 |
| **Nombre** | BLOCK_LLENO: cierre acumulativo al 20° evento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RENDIMIENTO / BUFFER |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 3 (BLOCK_LLENO): incrementa contador N_BLOCK_LLENO. Solo al 20° evento acumulado (`N_BLOCK_LLENO = 20`) se cierran canales donde `REG_X_BLOCK[i] > 0 AND NIVLOG_A[i] > 0 AND FEC_DIA[i] > FECPROC`. Importante: la condición de fecha usa FECPROC (fecha proceso actual, comparación estricta mayor-que) vs. el timeout (Evento 1) que usa FEC_PRO_BASE (comparación mayor-o-igual). Después del cierre, N_BLOCK_LLENO = 0.

**Impacto migración:** El concepto "block lleno" de ClearPath MCP no tiene equivalente directo. En arquitecturas modernas el flush se maneja por tamaño de lote o tiempo, no por bloques físicos de disco.

---

## RN-S151-640 — P016 tiene restricción horaria: solo antes de 20:00:00

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-640 |
| **Nombre** | P016 tiene restricción horaria: solo antes de 20:00:00 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | TIEMPO_REAL / CONTROL |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 4 (LEVANTA_PASOS): P016 (procesamiento nocturno) se activa solo si `ACTIVA_P016 AND NIVLOG_A[IND_COPIA] > 0 AND STATUS_MIX_P016(IND_COPIA) < 1 AND HORA < 200000`. Después de las 20:00:00, aunque ACTIVA_P016 sea TRUE, P016 no se lanzará. P015 (intraday) no tiene esta restricción horaria.

**Impacto migración:** La ventana operativa de P016 (antes 20:00:00 hora local México) debe implementarse como regla de scheduler en el equivalente moderno. SME debe confirmar la zona horaria (¿CST/CDT?).

---

## RN-S151-641 — AMBIENTA: protocolo de cierre de fin de día en 7 pasos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-641 |
| **Nombre** | AMBIENTA: protocolo de cierre de fin de día en 7 pasos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | PROCESO_BATCH / OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 7 (AMBIENTA): secuencia de cierre de fin de día: (1) DCKEYIN `"{NUM_MIX_P015(L)} HI 4"` a todos los canales P015 activos (STATUS > 0); (2) DCKEYIN `"{NUM_MIX_P016(L)} HI 4"` a todos P016 activos; (3) `WAIT((2))` — espera 2 segundos para que P015/P016 procesen el halt; (4) CIERRALOG para L=0..9 (cierra todos los 10 canales); (5) `CLOSE(ERRORES1, LOCK)`; (6) Desactiva LEVANTA_P015 = FALSE, ACTIVA_P015 = ACTIVA_P016 = FALSE; (7) Valida S151LOTE en CTLVERS (control de versión WFL).

**Impacto migración:** El protocolo de halt (DCKEYIN) debe reemplazarse por señales de cancelación de tarea modernas (SIGTERM / gRPC cancellation / Kafka consumer group rebalance). El WAIT(2) de cortesía debe convertirse en await con timeout.

---

## RN-S151-642 — INICIA_DIA espera señal explícita FIN_DIA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-642 |
| **Nombre** | INICIA_DIA espera señal explícita FIN_DIA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SINCRONIZACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 5 (INICIA_DIA): ejecuta `WAITANDRESET(FIN_DIA)`. El procesamiento del nuevo día no inicia hasta recibir la señal explícita FIN_DIA. Este es un handshake de sincronización batch que garantiza que el cierre del día anterior está completo antes de abrir nuevos archivos MOV/DES.

**Impacto migración:** En arquitecturas modernas reemplazar con barrera de sincronización o evento de coordinación (Kafka topic "cierre-dia-completado", barrier en DAG orquestador).

---

## RN-S151-643 — 4 flags requeridos para ejecutar P169 (solo SIST_LIB=500)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-643 |
| **Nombre** | 4 flags requeridos para ejecutar P169 (solo SIST_LIB=500) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | COORDINACIÓN / CONDICIONAL |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para SIST_LIB=500 únicamente: `EJECUTA_P169` se llama si y solo si los 4 flags son TRUE simultáneamente: `FIN_S408 AND FIN_S500 AND FUNCION_82 AND FUNCION_83`. P169 no debe ejecutarse si alguno de los 4 está en FALSE. Esta condición es la señal de "todos los subsistemas de captación completaron" para que el GL pueda ejecutar la fase final de P169.

**Referencia cruzada:** Ver RN-S500-* para la lógica que activa FIN_S408 y FIN_S500.

**Impacto migración:** Los 4 flags deben replicarse como variables de estado persistidas (Redis/DB). La evaluación de la condición AND debe ser atómica para evitar race conditions con consumidores concurrentes.

---

## RN-S151-644 — Loop principal activo mientras LIBRARYUSERS > 0

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-644 |
| **Nombre** | Loop principal activo mientras LIBRARYUSERS > 0 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** `PROC_CONTROL: WHILE MYSELF.LIBRARYUSERS > 0 DO`. L002R3 permanece activo (como librería MCP) mientras haya al menos un consumidor enlazado. Al desconectarse el último consumidor, el WHILE termina y se ejecuta BAJA. `MYSELF.LIBRARYUSERS` es un contador del sistema operativo MCP — decrementado automáticamente cuando un consumidor ejecuta UNATTACH o termina.

**Impacto migración:** El patrón biblioteca-consumidor de MCP no tiene equivalente directo. En microservicios se reemplaza con un sidecar o servicio gRPC que mantiene conexiones activas por cliente.

---

## RN-S151-645 — Routing de comandos operator via EXCEPTIONEVENT

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-645 |
| **Nombre** | Routing de comandos operator via EXCEPTIONEVENT |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 2 (EXCEPTIONEVENT — señal "HI" de consola): lee NUM_HI (4 dígitos) de `MYSELF.TASKVALUE` → construye DAT_CONTROL → llama `CONTROLES(DAT_CONTROL)` → `RESET(MYSELF.EXCEPTIONEVENT)` + `MYSELF.TASKVALUE := 0`. Es el mecanismo de despacho de comandos operator enviados via `"HI {num}"` desde la consola MCP.

**Impacto migración:** Los comandos operator de consola MCP deben reemplazarse por API de control (REST/gRPC) o mensajes en topic dedicado de administración. CONTROLES debe exponerse como endpoint seguro.

---

## RN-S151-646 — GRABALOG con 12 parámetros y 4 tipos de archivo por canal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-646 |
| **Nombre** | GRABALOG con 12 parámetros y 4 tipos de archivo por canal |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | INTERFAZ |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Firma: `GRABALOG(LOG, ALOG, NIVLOG, FECDIA, BLOG, DES, NIVDES, CD_LOG, NIV_CD, AR_CD, NIV_CB, AR_CB)`. Tipos por canal: LOG (archivo MOV — movimientos), DES (archivo descriptores), AR_CD (CDIR), AR_CB (CBII). Contiene procedimiento anidado SEPARA_S500 para transformación de datos TESOFE. ALOG y BLOG son los buffers; NIVLOG/NIVDES/NIV_CD/NIV_CB son los write pointers.

**Impacto migración:** Los 4 tipos de archivo por canal deben mapearse a 4 streams/topics o colecciones independientes. Los write pointers (NIVLOG etc.) deben ser offsets atómicos persistidos.

---

## RN-S151-647 — SEPARA_S500: transformación TESOFE de 20 tipos de campo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-647 |
| **Nombre** | SEPARA_S500: transformación TESOFE de 20 tipos de campo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | TRANSFORMACIÓN / TESOFE |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Dentro de GRABALOG, el procedimiento anidado SEPARA_S500 maneja registros S500 (SISTEMA_TESOFE). `CASE ID_CAMPO (1..20)`: mapea cada campo TESOFE desde buffer FILLER_ADIC (EBCDIC) a offsets específicos en PAR_LOG usando EBCDICTOHEX. Offsets destino: 1951-2212 en PAR_LOG. Cambio introducido en 2017-05-08 (comentario "CAMBIO TESOFE").

**Impacto migración:** Los 20 tipos de campo TESOFE deben documentarse en vocabulario y mapearse explícitamente en el schema destino. La conversión EBCDICTOHEX es crítica para integridad de datos.

---

## RN-S151-648 — CARGAMEMORY: expansión automática de archivos al límite 300

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-648 |
| **Nombre** | CARGAMEMORY: expansión automática de archivos al límite 300 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | GESTIÓN_ARCHIVO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CARGAMEMORY: si registros restantes < 300, llama DFAMPLIAFILE. Tamaños por tipo: LOG = 75 words/reg, DES = 90 words/reg, CBII = 210 words/reg (2000 regs expansión), CDIR = 210 words/reg (2000 regs expansión). CBII y CDIR solo se expanden para SIST_LIB=500. Se verifica CBII/CDIR con `.RESIDENT` antes de expandir.

**Impacto migración:** La pre-asignación de espacio en archivo Unisys no tiene equivalente. En almacenamiento moderno la capacidad es elástica; eliminar este mecanismo.

---

## RN-S151-649 — Solo FUNCION=1 (inserción) se persiste en GRABALOG

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-649 |
| **Nombre** | Solo FUNCION=1 (inserción) se persiste en GRABALOG |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | FILTRO_DATOS |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CARGAMEMORY llama GRABALOG solo cuando `IDFFUNCION(ALOG1) = 1` (inserción). Otros valores de FUNCION no generan escritura física al archivo MOV.

**Impacto migración:** En la arquitectura destino, los eventos de inserción (FUNCION=1) son los únicos que producen mensajes a Kafka/stream.

---

## RN-S151-650 — ELIMINA usa borrado lógico via DFELIMINA (no físico)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-650 |
| **Nombre** | ELIMINA usa borrado lógico via DFELIMINA (no físico) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONSISTENCIA_DATOS |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El procedimiento ELIMINA llama `DFELIMINA(LOGS, ALOG1, NIVLOG_A, FEC_DIA, BLOG1, NIVDES_A, LOG_CD, NIVLOG_CD, CDIR, NIVLOG_CB, CBII, DESS, BLOG2)` — borrado lógico. Los registros quedan marcados, no se eliminan físicamente. El archivo MOV mantiene su tamaño y los registros marcados persisten hasta el proceso de purga.

**Impacto migración:** El borrado lógico debe replicarse. En Kafka sería un tombstone event; en DB sería columna deleted_at.

---

## RN-S151-651 — Tracking de autorizaciones FEC_X_PROC[canal, TIPPROC]

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-651 |
| **Nombre** | Tracking de autorizaciones FEC_X_PROC[canal, TIPPROC] |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | AUDITORÍA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CARGAMEMORY mantiene array `FEC_X_PROC[canal, TIPPROC]` (100 entradas por canal) con el número de autorización `IDFAUT(BLOG1)` por tipo de proceso. Si `FEC_X_PROC[NUMDIAC1, IDFTIPPROC(BLOG1)] = 0` (primera vez), almacena la autorización y escribe PROCESOS[NUMDIAC1] (150 words). Optimiza FUNCION=21.

**Impacto migración:** Mapear a tabla de auditoría de autorizaciones en la arquitectura destino.

---

## RN-S151-652 — BAJA: secuencia de apagado ordenado en 7 pasos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-652 |
| **Nombre** | BAJA: secuencia de apagado ordenado en 7 pasos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACIONES / SINCRONIZACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** BAJA: (1) CIERRALOG para I=0..9; (2) DCKEYIN `"{NUM_MIX_P015} HI 4"` a todos P015 activos; (3) DCKEYIN `"{NUM_MIX_P016} HI 4"` a todos P016 activos; (4) DCKEYIN `"{NUM_MIX_P025} HI 4"` a todos P025; (5) WHILE loop esperando confirmación de detención; (6) `B05PROCESOS FUNCION=22` (desregistro); (7) `CLOSE(PROCESOS, LOCK)`.

**Impacto migración:** DCKEYIN es API de IPC exclusiva de ClearPath MCP. Reemplazar por mensajes de cancelación a cada microservicio consumidor.

---

## RN-S151-653 — IDFSTADES=1 determina si archivo DES es requerido

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-653 |
| **Nombre** | IDFSTADES=1 determina si archivo DES es requerido |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VALIDACION / CONDICIONAL |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En ARMADES: si el archivo DES (DESS) no se encuentra pero LOGS está residente, se verifica `IDFSTADES=1`. Si es 1, el archivo DES es requerido — se solicita copia al operador. Si IDFSTADES≠1, el archivo DES es opcional — el canal continúa sin él.

**Impacto migración:** La flag IDFSTADES debe mapearse a configuración de canal. El modo "operación sin descriptores" debe documentarse como modo degradado explícito.

---

## RN-S151-654 — ARMADES abre archivo SDOS (saldos) además de DESS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-654 |
| **Nombre** | ARMADES abre archivo SDOS (saldos) además de DESS |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_MAESTRO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** ARMADES inicializa dos archivos por canal: DESS (descriptores) y SDOS (saldos). Ambos usan la misma validación doble (HFUNCION ≠ 99, HFECLOG = FECDIA) y búsqueda binaria de centinela.

---

## RN-S151-655 — INICIA y TERMINA son thin wrappers de CARGAMEMORY

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-655 |
| **Nombre** | INICIA y TERMINA son thin wrappers de CARGAMEMORY |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** `INICIA { CARGAMEMORY; }` y `TERMINA { CARGAMEMORY; }` son thin wrappers. Ambos llaman exclusivamente CARGAMEMORY. La llamada a ACTNIVEL está comentada con `%` en ambos — la sincronización de niveles con L001 fue desactivada en producción.

---

## RN-S151-656 — ACTNIVEL llama CONSISDIA para sincronización con L001 (comentado)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-656 |
| **Nombre** | ACTNIVEL llama CONSISDIA para sincronización con L001 (comentado) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | COORDINACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** ACTNIVEL (declarado pero comentado en INICIA/TERMINA): llama `CONSISDIA(ARCTRL)` con FUNCION=08, SIST_LIB, CSI_LIB, FEC_DIA[NUMDIAC1], NIVLOG_A[NUMDIAC1]. CONSISDIA es función de librería L001 para sincronización de niveles. El código de error también está comentado. Estaba diseñado para notificar a L001 el nivel actual de escritura tras cada transacción.

**Impacto migración:** SME debe confirmar si esta sincronización fue desactivada definitivamente o es un bug latente.

---

## RN-S151-657 — RESET_EVE (Evento 6) reinicia el contador de 30 segundos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-657 |
| **Nombre** | RESET_EVE (Evento 6) reinicia el contador de 30 segundos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Evento 6 (RESET_EVE): cuerpo vacío — `6 : BEGIN %SE RESETEA EL TIMER END`. El mecanismo WAITANDRESET reinicia su contador de 30 segundos automáticamente al dispararse cualquier evento. RESET_EVE existe para forzar ese reinicio explícitamente sin ejecutar ninguna acción adicional.

---

## RN-S151-658 — SIST_LIB=500 añade archivos CBII y CDIR por canal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-658 |
| **Nombre** | SIST_LIB=500 añade archivos CBII y CDIR por canal |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | S500 / ARQUITECTURA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando SIST_LIB=500: cada canal usa adicionalmente CBII[0:9] y CDIR[0:9]. CBII se verifica con `.RESIDENT` antes de operar. La expansión usa 2000 registros por expansión (vs. AMPL_REG para LOG/DES). Tamaño de registro: 210 words para ambos.

**Impacto migración:** CBII y CDIR son tipos de almacenamiento adicionales solo para captación S500. Deben mapearse a colecciones/topics separados.

---

## RN-S151-659 — Validación WFL S151LOTE en CTLVERS durante AMBIENTA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-659 |
| **Nombre** | Validación WFL S151LOTE en CTLVERS durante AMBIENTA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL_VERSIONES / OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R3 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante AMBIENTA (Evento 7): `DAME_TIT(CTLVER_ID="S151LOTE    ", CTLVER_NOM)` recupera el nombre del WFL lote del registro CTLVERS. Si no existe: error `"I>020901< L002/REGISTRAS {SIST_LIB} ERROR EN CTLVERS, NO EXISTE IDENTIFICADOR DEL WFL LOTE (S151LOTE)"`. El nombre recuperado (STR_NOMB_LOTE, 72 chars) controla la versión del ciclo batch.

**Impacto migración:** CTLVERS → tabla de configuración/versión en la arquitectura destino. El identificador S151LOTE debe ser parámetro de configuración externa con validación al inicio del proceso.

---

# Reglas de Negocio — L002R4 (ALGOL)
> Programa: L002R4 (REGISTRAS) | Sistema: S151 GL | BC: BC-04 ACL GL Interface
> Rango: RN-S151-660..674 | Total: 15 reglas
> Extracción directa (coordinador) — secciones leídas:
>   líneas 5500-5600 (REBLOCKADE+PREFINAL+FINAL), 5600-5740 (CARGAMOV outer block),
>   6900-6960 (LEVANTA/B05 registro), 7100-7180 (L002COMMPOST+CIERRALOG+BAJA)

## Contexto

L002R4 es una versión evolucionada de L002R3 con un modelo de dispatch explícito por FUNCION (10 funciones: 1..98), detección de duplicado de instancia, y sistema de monitoreo CPOST. Soporta SIST_LIB 151, 500, 403 y 404.

---

## RN-S151-660 — Tabla de dispatch: 10 FUNCIONes reconocidas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-660 |
| **Nombre** | Tabla de dispatch: 10 FUNCIONes reconocidas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA / INTERFAZ |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** CARGAMOV ejecuta un `CASE IDFFUNCION(ALOG1)` con 10 funciones válidas:

| FUNCION | Procedimiento | Descripción |
|---------|---------------|-------------|
| 1 | CARGAMEMORY | Inserción de registro |
| 2 | ELIMINA | Borrado lógico |
| 11 | INICIA | Inicio de canal |
| 12 | TERMINA | Fin de canal |
| 21 | ELIMXPROC | Elimina por proceso |
| 22 | ELIMXAUT | Elimina por autorización |
| 31 | REBLOCKADE | Re-bloqueo alta capacidad (10800) |
| 32 | REBLOCKADE | Re-bloqueo normal (150) |
| 97 | PREFINAL | Pre-cierre (sin sync L001) |
| 98 | FINAL | Cierre final (con sync L001) |

FUNCION inválida → RESULT=2, GRABAMOV=FALSE, error "FUNCION NO VALIDA".

**Impacto migración:** Esta es la API pública de la librería. Cada FUNCION debe mapearse a un endpoint o operación en la arquitectura destino.

---

## RN-S151-661 — REBLOCKADE FUNCION=31: modo alta capacidad (blocksize 10800)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-661 |
| **Nombre** | REBLOCKADE FUNCION=31: modo alta capacidad (blocksize 10800) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RENDIMIENTO / CONFIGURACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** REBLOCKADE con FUNCION=31: (1) CARGAMEMORY (flush pendientes); (2) `CLOSE(LOGS[NUMDIAC1], LOCK)` + `CLOSE(DESS[NUMDIAC1], LOCK)`; (3) `LOGS[NUMDIAC1].BLOCKSIZE := 10800` + `LOGS.SYNCHRONIZE := VALUE(NO)` + `DESS.BLOCKSIZE := 10800`; (4) Re-lee headers si archivos RESIDENT. Blocksize 10800 = modo batch de alto rendimiento (sin sincronización en disco por cada write).

**Impacto migración:** Reemplazar con configuración de durabilidad en la escritura del sistema destino (ej. fsync=off en PostgreSQL, acks=0 en Kafka para bulk load).

---

## RN-S151-662 — REBLOCKADE FUNCION=32: modo normal (blocksize 150, SYNCHRONIZE=OUT)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-662 |
| **Nombre** | REBLOCKADE FUNCION=32: modo normal (blocksize 150, SYNCHRONIZE=OUT) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RENDIMIENTO / CONFIGURACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** REBLOCKADE con FUNCION=32: (1) CARGAMEMORY (flush); (2) `CLOSE(LOGS, LOCK)` + `CLOSE(DESS, LOCK)`; (3) `LOGS.BLOCKSIZE := 150` + `LOGS.SYNCHRONIZE := VALUE(OUT)` + `DESS.BLOCKSIZE := 90`. Modo normal: flush a disco en cada cierre de buffer. Es el modo inverso de FUNCION=31.

---

## RN-S151-663 — PREFINAL (FUNCION=97): cierre sin sincronización L001

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-663 |
| **Nombre** | PREFINAL (FUNCION=97): cierre sin sincronización L001 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | PROCESO_BATCH |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** PREFINAL (FUNCION=97): (1) CARGAMEMORY; (2) CLOSE(LOGS, LOCK) + CLOSE(DESS, LOCK); (3) Re-lee headers. NO llama CONSISDIA — sin sincronización L001. Es el "pre-cierre" de dos fases: PREFINAL (97) → FINAL (98).

---

## RN-S151-664 — FINAL (FUNCION=98): cierre con sincronización L001, hasta 3 reintentos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-664 |
| **Nombre** | FINAL (FUNCION=98): cierre con sincronización L001, hasta 3 reintentos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | PROCESO_BATCH / SINCRONIZACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** FINAL (FUNCION=98): (1) CARGAMEMORY; (2) CLOSE(LOGS + DESS + SDOS, LOCK); (3) Hasta 3 reintentos de `CONSISDIA(ACONTROLE1)` con FUNCION B01F05=5, SIST_LIB, CSI_LIB. Si RESULT_CTL > 0 tras 3 intentos: error "ERROR EN FUNCION 98 L002/REGISTRAS{SIST_LIB}, RESULT L001/CONTROL {RESULT_CTL}".

**Impacto migración:** CONSISDIA FUNCION=5 es el "commit final" con L001. Debe mapearse a commit distribuido en arquitectura destino. Los 3 reintentos deben preservarse.

---

## RN-S151-665 — CIERRALOG: solo cierra LOGS y DESS (no SDOS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-665 |
| **Nombre** | CIERRALOG: solo cierra LOGS y DESS (no SDOS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DIFERENCIA_CRITICA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** `CIERRALOG(LOGN1)` en L002R4: `CLOSE(LOGS[LOGN1], LOCK)` + `CLOSE(DESS[LOGN1], LOCK)`. NO cierra SDOS. SDOS solo se cierra en FINAL (FUNCION=98). Los timeouts y cierres parciales no afectan a SDOS — los saldos se committan solo al final del día.

---

## RN-S151-666 — Lock CAMBIA_FECHA: espera activa antes de escritura

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-666 |
| **Nombre** | Lock CAMBIA_FECHA: espera activa antes de escritura |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SINCRONIZACIÓN / CONCURRENCIA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de cualquier escritura en CARGAMOV: `WHILE LOCKSTATUS(CAMBIA_FECHA).[1:2] > 0 DO WAIT((.3))` — espera activa en ciclos de 0.3 segundos mientras CAMBIA_FECHA esté locked. Este lock se activa durante el cambio de fecha de procesamiento; las escrituras se bloquean para garantizar que los registros caen en el día correcto.

**Impacto migración:** Reemplazar con read-write lock: lecturas en reader-side, cambio de fecha en writer-side.

---

## RN-S151-667 — Validación de sistema: IDFSISTFAN ≠ SIST_LIB → rechazo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-667 |
| **Nombre** | Validación de sistema: IDFSISTFAN ≠ SIST_LIB → rechazo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VALIDACION |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si `IDFSISTFAN(ALOG1) ≠ SIST_LIB`: error "SISTEMA NO HABILITADO EN S151, SISTEMA : {IDFSISTEMA(ALOG1)}", RESULT=1, GRABAMOV=FALSE. Previene que registros de un sistema aterricen en instancia de otro sistema.

---

## RN-S151-668 — Selección de canal por fecha contable (IDFFECCONT)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-668 |
| **Nombre** | Selección de canal por fecha contable (IDFFECCONT) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ROUTING / MULTI-DÍA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Selección de canal NUMDIAC1 por IDFFECCONT(ALOG1):
- BETA: escanea FEC_DIA[0:9] para canal matching
- Producción: IDFFECCONT = FECHAPROC → NUMDIAC1 = DIA_SEMANA
- IDFFECCONT > FECHAPROC → busca en FEC_DIA[0:9]; no encontrado → RESULT=4
- IDFFECCONT < FECHAPROC → RESULT=4 (fecha pasada rechazada)

RESULT=4 = "FECHA CONTABLE NO VALIDA"; continúa con DIA_SEMANA.

**Impacto migración:** El routing por fecha contable en multi-canal es crítico. En arquitecturas modernas, cada partición/shard tiene una fecha asociada.

---

## RN-S151-669 — SIST_LIB 500/403/404 tienen manejo diferencial de campos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-669 |
| **Nombre** | SIST_LIB 500/403/404 tienen manejo diferencial de campos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | VARIANTE_SISTEMA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si SIST_LIB ≠ 500 AND ≠ 403 AND ≠ 404: sobrescribe `POINTER(ALOG1,4)+342` y `+345` con valor 2 (3 dígitos). Para sistemas 500, 403 y 404 estas posiciones NO se modifican. SME debe confirmar qué representan los sistemas 403 y 404 (no documentados previamente).

---

## RN-S151-670 — L002COMMPOST: sistema de monitoreo de errores via CPOST

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-670 |
| **Nombre** | L002COMMPOST: sistema de monitoreo de errores via CPOST |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OBSERVABILIDAD / MONITOREO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L002COMMPOST formatea y envía eventos de error al sistema CPOST: evento "5308000", tipo I_TIPO (3=error), origen "S151/L002", concepto "S{SIST_LIB}/PR{PROCE}". Texto dividido en fragmentos de 62 bytes: `[frag1] [frag2] [frag3] []`. Envío via `RSENDAUTO(A_CPOST)`. Actualmente comentado (`%L002COMMPOST`) en los puntos de error — desactivado en producción.

**Impacto migración:** CPOST → sistema de eventos equivalente (Datadog/Dynatrace). El event type "5308000" es código de la plataforma CPOST de Banamex.

---

## RN-S151-671 — Registro en B05PROCESOS (FUNCION=19) al inicio

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-671 |
| **Nombre** | Registro en B05PROCESOS (FUNCION=19) al inicio |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | REGISTRO / PROCESO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante LEVANTA: `B05PROCESOS(ACONTROLE2)` con FUNCION=19 y SNR. Si RESULT_CTL > 0: error "NO SE PUDO DAR DE ALTA REG. EN B05" + `MYSELF.STATUS := -1` (termina con error). B05PROCESOS es el registry centralizado de procesos activos en el entorno MCP.

**Impacto migración:** B05 registro → service registry en arquitectura destino. El error fatal (STATUS=-1) indica que la librería no puede operar sin registro exitoso.

---

## RN-S151-672 — Detección de instancia duplicada L002 en ejecución

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-672 |
| **Nombre** | Detección de instancia duplicada L002 en ejecución |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | SINGLETON / CONCURRENCIA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante LEVANTA: si existe otra instancia L002 con el mismo nombre (MIX_SIN_MTP = LIB_SIN_MTP): DCKEYIN `"{MIX_L002} HI 4"` → WAIT(5) → re-intento. Tras 3 intentos (INTENTOS_BAJA=3): mensaje operador "EXISTE UNA L002 CON MIX {MIX_L002} DARLA DE BAJA PARA PODER CONTINUAR" + ACCEPT. Si el sistema es diferente: desregistra de B05 (FUNCION=22) y continúa.

**Impacto migración:** Singleton de biblioteca MCP → leader election o mutex distribuido.

---

## RN-S151-673 — BAJA inicia cerrando ERRORES1 y todos los canales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-673 |
| **Nombre** | BAJA inicia cerrando ERRORES1 y todos los canales |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OPERACIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** BAJA en L002R4: (1) `CLOSE(ERRORES1, LOCK)` (primero cierra el log de errores); (2) CIERRALOG(I) para I=0..9; (3) Loop REGRESA: verifica STATUS_MIX_P015(I) y STATUS_MIX_P016(I) — si STATUS > 0, llama ERRORMSG (diferente de L002R3 que usaba DCKEYIN).

---

## RN-S151-674 — SDO archive name viene de CONSISDIA (L001 controla nombres)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-674 |
| **Nombre** | SDO archive name viene de CONSISDIA (L001 controla nombres) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_MAESTRO / COORDINACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R4 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al inicializar: `ARC_SDO := SISDNOMSDO(ACONTROLE1) FOR 34` + `PK_SDO := SISDPKSDOS(ACONTROLE1) FOR 17`. Los nombres del archivo SDO y su pack key vienen del resultado de CONSISDIA con L001. L001 es la autoridad sobre qué archivos SDO están activos; L002 no determina autónomamente los nombres.

**Impacto migración:** L001 → servicio de configuración centralizado que provee identificadores de almacenamiento activos. Mapear a endpoint de configuración dinámica.

---

# Reglas de Negocio — L002R5 (ALGOL)
> Programa: L002R5 (REGISTRAS) | Sistema: S151 GL | BC: BC-04 ACL GL Interface
> Rango: RN-S151-675..689 | Total: 15 reglas
> Extracción directa (coordinador) — secciones leídas:
>   líneas 5400-5480 (MAPEO/MAPEO6D: layout de record), 5720-5880 (CARGAMOV outer block)

## Contexto

L002R5 extiende el modelo de L002R4 con lanzamiento directo de P015/P016/P025 desde CARGAMOV (sin pasar por PROC_CONTROL), un cambio de blocksize antes del lanzamiento, y un layout de record enriquecido con FILLERXAPL (165 words) y 5 campos LYENDA. Soporta SIST_LIB: 151, 500, 403, 404.

---

## RN-S151-675 — Misma tabla de dispatch de 10 FUNCIONes que L002R4

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-675 |
| **Nombre** | Misma tabla de dispatch de 10 FUNCIONes que L002R4 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ARQUITECTURA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L002R5 implementa exactamente el mismo `CASE IDFFUNCION(ALOG1)` con las 10 funciones: 1 (CARGAMEMORY), 2 (ELIMINA), 11 (INICIA), 12 (TERMINA), 21 (ELIMXPROC), 22 (ELIMXAUT), 31 (REBLOCKADE), 32 (REBLOCKADE), 97 (PREFINAL), 98 (FINAL). FUNCION inválida → RESULT=2, GRABAMOV=FALSE.

**Referencia cruzada:** Ver RN-S151-660 (L002R4) para la descripción completa de cada función.

---

## RN-S151-676 — Lanzamiento directo de P015 y P016 desde CARGAMOV

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-676 |
| **Nombre** | Lanzamiento directo de P015 y P016 desde CARGAMOV |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DIFERENCIA_CRITICA / COORDINACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A diferencia de L002R3 (PROC_CONTROL LEVANTA_PASOS), L002R5 lanza P015/P016 directamente desde CARGAMOV tras cada operación exitosa. Condición: `FUNCIONVAL < 98 AND (STATUS_MIX_P015 < 1 OR (STATUS_MIX_P016 < 1 AND HORA < 200000)) AND FEC_DIA[NUMDIAC1] >= FEC_CON AND IDFTIPPROC(ALOG1) < 16 AND LEVANTA_P015`. Lógica de lanzamiento:

| Condición | Acción |
|-----------|--------|
| P015 + P016 disponibles AND HORA < 200000 | VERSION_P015 + VERSION_P016 → WAIT(3) → EXTERNO_P015 + EXTERNO_P016 |
| Solo P015 disponible | VERSION_P015 → WAIT(3) → EXTERNO_P015 |
| Solo P016 disponible AND HORA < 200000 | VERSION_P016 → WAIT(3) → EXTERNO_P016 |

**Impacto migración:** En L002R5 el trigger de P015/P016 es síncrono con cada escritura. Cada inserción FUNCION=1 puede disparar un proceso externo. La semántica síncrona debe preservarse.

---

## RN-S151-677 — Rebloqueo de archivo antes de lanzar P015/P016

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-677 |
| **Nombre** | Rebloqueo de archivo antes de lanzar P015/P016 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | RENDIMIENTO / SINCRONIZACIÓN |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de lanzar P015/P016: `CLOSE(LOGS, LOCK)` + `CLOSE(DESS, LOCK)` → `LOGS.BLOCKSIZE := 150` + `LOGS.SYNCHRONIZE := VALUE(OUT)` + `DESS.BLOCKSIZE := 90`. El rebloqueo garantiza que P015/P016 reciben archivos en modo sincronizado (transaccional-seguro) aunque el archivo estuviera en modo bulk (blocksize 10800).

**Impacto migración:** Equivale a un fsync/flush antes de notificar al consumer.

---

## RN-S151-678 — VERSION_P015/P016: verificación de versión antes del lanzamiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-678 |
| **Nombre** | VERSION_P015/P016: verificación de versión antes del lanzamiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL_VERSIONES |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de cada lanzamiento externo: VERSION_P015 y/o VERSION_P016 (verificación de compatibilidad de versión entre librería y proceso externo). Tras la verificación: `WAIT((3))` — 3 segundos antes de ejecutar EXTERNO_P015/P016. El WAIT da tiempo para completar el handshake de versión.

**Impacto migración:** Check de versión → validación de contrato de API (schema compatibility). WAIT(3) → await con timeout o confirmación explícita.

---

## RN-S151-679 — P025 activado desde CARGAMOV: TIPPROC > 15, FECS151, STATUS_BDSDO < 99

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-679 |
| **Nombre** | P025 activado desde CARGAMOV: TIPPROC > 15, FECS151, STATUS_BDSDO < 99 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | COORDINACIÓN / CONDICIONAL |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P025 se activa desde CARGAMOV cuando: `STATUS_MIX_P025 < 1 AND FEC_DIA[NUMDIAC1] = FECS151 AND FUNCIONVAL = 1 AND IDFTIPPROC(ALOG1) > 15 AND STATUS_BDSDO < 99`. Cinco condiciones simultáneas requeridas. TIPPROC > 15 = procesos de consolidación (no intraday).

**Impacto migración:** TIPPROC > 15 es la frontera entre procesos intraday (0-15) y de consolidación (16+). P025 es el proceso de sincronización con DMSII; STATUS_BDSDO < 99 garantiza disponibilidad del DMSII.

---

## RN-S151-680 — STATUS_BDSDO=99: indica cierre de base de datos SDO (DMSII)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-680 |
| **Nombre** | STATUS_BDSDO=99: indica cierre de base de datos SDO (DMSII) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | ESTADO_SISTEMA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** STATUS_BDSDO = 99 indica que la base de datos SDO (DMSII — Unisys Data Management System II) está cerrada. Cuando STATUS_BDSDO = 99, P025 NO se activa aunque todas las demás condiciones se cumplan.

**Referencia cruzada:** Ver RN-S151-735 (P360) para el uso de DMSII y DMTERMINATE.

**Impacto migración:** STATUS_BDSDO debe mapearse al estado de disponibilidad del almacenamiento persistente equivalente. El sentinel 99 debe reemplazarse por health check real.

---

## RN-S151-681 — MAPEO: layout de record con 50+ campos mapeados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-681 |
| **Nombre** | MAPEO: layout de record con 50+ campos mapeados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | TRANSFORMACIÓN / DATO_MAESTRO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El procedimiento MAPEO en L002R5 construye BLOG1 copiando 50+ campos de ALOG1 con sus offsets exactos. Campos clave: MONEDA (+280,4), ORIGEN (+278,2), INDEFECTIVO (+208,2), CVEMDA (+228,2), NUMMDA (+230,20), AUTO_APLI (+192,8), AUTO_S151 (+284,8), TIP_PROC (+308,2), FECHA_MAQUI (+162,8), FEC_CONTAB (+176,8), FEC_VALOR (+184,8), NOMINAFUN1 (+360,8), NOMINAFUN2 (+368,8), entre otros.

**Impacto migración:** El MAPEO define el schema completo del registro de movimiento de L002R5. Todos los campos deben documentarse en el vocabulario y mapearse al schema destino.

---

## RN-S151-682 — FILLERXAPL: 165 words de datos heredados en el registro

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-682 |
| **Nombre** | FILLERXAPL: 165 words de datos heredados en el registro |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_HEREDADO / EQUIVALENCIA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En MAPEO: `REPLACE POINTER(FILLERXAPL, 4) FOR 330` copia 165 words (330 halfwords) desde buffer FILLERXAPL hacia BLOG1. Tras la copia: `REPLACE POINTER(BLOG1) BY 40"0" FOR 165 WORDS` — resetea BLOG1. FILLERXAPL es un buffer polimórfico de compatibilidad con datos de sistemas "aplicativos" (APL). Tiene 15+ REDEFINES según el sistema de origen — identificado en el audit report como "máxima complejidad equivalencia".

**Impacto migración:** FILLERXAPL debe modelarse como campo JSON/JSONB o union type con discriminador por sistema. No es un filler vacío.

---

## RN-S151-683 — LYENDA1-5: cinco campos de leyenda de 80 bytes (offsets 630-950)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-683 |
| **Nombre** | LYENDA1-5: cinco campos de leyenda de 80 bytes (offsets 630-950) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_MAESTRO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** MAPEO incluye: LYENDA1 (+630, 80 bytes), LYENDA2 (+710, 80 bytes), LYENDA3 (+790, 80 bytes), LYENDA4 (+870, 80 bytes), LYENDA5 (+950, 80 bytes). Total: 400 bytes de texto descriptivo del movimiento. Destinados a estados de cuenta y reportes al cliente. No presentes en L002R3 ni L002R4.

**Impacto migración:** Los 5 campos LYENDA mapean al campo de descripción/concepto del movimiento en el sistema destino.

---

## RN-S151-684 — Campos FIRMA y REFCLIENTE en el layout

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-684 |
| **Nombre** | Campos FIRMA y REFCLIENTE en el layout |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DATO_MAESTRO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** MAPEO incluye FIRMA (offset +430, 1 byte), REFCLIENTE (32 bytes), REF1-4_CTE (4 × 70 bytes = 280 bytes total). FIRMA = flag de firma digital del movimiento. REFCLIENTE + REF1-4 = referencias del cliente para identificación en estado de cuenta.

**Impacto migración:** REFCLIENTE y REF1-4 son datos de trazabilidad cliente-movimiento. Deben preservarse para reconciliación y estados de cuenta.

---

## RN-S151-685 — Offsets 262/267 para sistemas no-500/403/404 (diferente a L002R4)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-685 |
| **Nombre** | Offsets 262/267 para sistemas no-500/403/404 (diferente a L002R4) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DIFERENCIA_CRITICA |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para SIST_LIB ≠ 500/403/404: `REPLACE POINTER(ALOG1,4)+262 BY 2 FOR 5 DIGITS` + `REPLACE POINTER(ALOG1,4)+267 BY 2 FOR 5 DIGITS`. L002R4 usa offsets 342+345 con 3 dígitos; L002R5 usa 262+267 con 5 dígitos. Los record layouts de R4 y R5 son INCOMPATIBLES — los mismos campos están en posiciones y tamaños distintos.

**Referencia cruzada:** Ver RN-S151-669 (L002R4) para el equivalente en offsets 342+345.

**Impacto migración:** Las dos librerías (R4 y R5) no pueden intercambiarse. El sistema destino debe distinguir el tipo de record para aplicar la transformación correcta.

---

## RN-S151-686 — IDFTIPPROC: segmentación procesos intraday (0-15) vs consolidación (16+)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-686 |
| **Nombre** | IDFTIPPROC: segmentación procesos intraday (0-15) vs consolidación (16+) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CLASIFICACIÓN / PROCESO |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** IDFTIPPROC(ALOG1) clasifica tipos de proceso: 0-15 = intraday (P015/P016 cuando TIPPROC < 16); 16+ = consolidación/cierre (P025 cuando TIPPROC > 15). El mismo campo controla el routing de procesamiento secundario en ambos L002R4 y L002R5.

**Impacto migración:** Tipo de proceso es dimensión clave para routing de procesamiento secundario. Debe preservarse como campo en el schema destino.

---

## RN-S151-687 — LNG_MSG=800 indica mensaje de monitoreo más pequeño que L002R4

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-687 |
| **Nombre** | LNG_MSG=800 indica mensaje de monitoreo más pequeño que L002R4 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | OBSERVABILIDAD |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L002R5 usa `LNG_MSG := 800` (vs L002R4: 1901). Refleja tamaños de registro distintos. MONITOREA está comentado en producción en ambas versiones.

---

## RN-S151-688 — LEVANTA_P015 como flag de habilitación de P015/P016

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-688 |
| **Nombre** | LEVANTA_P015 como flag de habilitación de P015/P016 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | CONTROL |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La condición de lanzamiento de P015/P016 requiere `LEVANTA_P015 = TRUE`. Aunque STATUS y HORA sean válidos, si LEVANTA_P015 = FALSE, P015 y P016 no se lanzan. Este flag permite suspender el lanzamiento durante ventanas operativas críticas (cambio de fecha, mantenimiento).

---

## RN-S151-689 — Validación IDFSISTEMA (no IDFSISTFAN) para sistema habilitado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-689 |
| **Nombre** | Validación IDFSISTEMA (no IDFSISTFAN) para sistema habilitado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-04 |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | DIFERENCIA_CRITICA / VALIDACION |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | L002R5 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** L002R5 usa `IDFSISTEMA(ALOG1) ≠ SIST_LIB` para validación de sistema (line 5738). L002R4 usa `IDFSISTFAN(ALOG1) ≠ SIST_LIB` (line 5629). IDFSISTEMA = campo "sistema" del header del movimiento; IDFSISTFAN = campo "fan" (identificador del subsistema fuente). La distinción determina qué campo del record se valida como identificador del sistema origen.

**Impacto migración:** SME debe confirmar la diferencia entre IDFSISTEMA e IDFSISTFAN en el record layout — son campos distintos del mismo registro.

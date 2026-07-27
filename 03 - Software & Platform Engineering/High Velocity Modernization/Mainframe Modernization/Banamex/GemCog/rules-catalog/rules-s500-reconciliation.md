# Catálogo de Reglas de Negocio — S500 Reconciliation · MQ Async
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P080 · P186 · P104 · P197 · P131 · P195 · P125 · P140 · P190 · P055 · P200 · P188 · P430 · P420 (Reconciliation) · P091 · P093 (MQ Async)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-721 a RN-S500-776 (56 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-721 — Orquestación de confirmación de operaciones sincronizadas y masivas (P080)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-721 |
| **Nombre** | Orquestación de confirmación de operaciones sincronizadas y masivas (P080) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P080 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P080 es el orquestador de captación que separa el flujo en archivos de operaciones sincronizadas (ARCHSINC), masivas (ARCHMASIV) y su reproceso (ARCHMASIV-R), más un archivo de problemas (ARCH-PROB) y monitoreo (R-MONITOR). Coordina el ciclo de vida de la corrida invocando entry points de la librería L080/L081 para inicio, confirmación e identificación de modo batch.

**Fórmula/pseudocódigo:**
```
CALL L081INICIO            → WS-L081-RESULT   (arranque de la corrida)
CALL L080ESBATCH           → determina si corre en modo batch y fija WS-FECHA-PROCESO
CALL L080CONFIRMHI         → WS-L080-RESULT   (confirma operación iniciada por host)
routing: operación → { ARCHSINC | ARCHMASIV | ARCH-PROB } según tipo y resultado
```

**Vocabulario en la fórmula:** ARCHSINC · ARCHMASIV · ARCH-SINC-B03 · L080CONFIRMHI · L081INICIO · L080ESBATCH · WS-FECHA-PROCESO

**Excepciones:**
- Operaciones que fallan validación se desvían a ARCH-PROB (archivo de problemas) para reconciliación posterior.
- El modo batch fija una fecha de proceso distinta a la del sistema (`L080ESBATCH`).

**Estado validación:** Verificado fuente líneas 13-22 (SELECT), 3359-3529 (CALLs a L080/L081)

---

## RN-S500-722 — Interruptor operativo de displays de traza (P080)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-722 |
| **Nombre** | Interruptor operativo de displays de traza (P080) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P080 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P080 incorpora un interruptor de traza en línea (`WS-DISPLAYS`) que habilita o deshabilita en caliente los mensajes de diagnóstico `<PBA>` enviados a consola. Se conmuta mediante una transacción de entry point "HI 4020 - DISPLAYS P080", permitiendo activar el rastreo de resultados de los CALL a L080/L081 sin recompilar ni detener el proceso.

**Fórmula/pseudocódigo:**
```
88 WS-88-DISPLAYS VALUE 1
al recibir "HI 4020 - DISPLAYS P080":
   IF WS-88-DISPLAYS  → MOVE 0 TO WS-DISPLAYS  ("DISPLAYS DESACTIVADOS")
   ELSE               → MOVE 1 TO WS-DISPLAYS  ("DISPLAYS ACTIVADOS")
IF WS-88-DISPLAYS  DISPLAY "<PBA> ..."
```

**Vocabulario en la fórmula:** WS-DISPLAYS · WS-88-DISPLAYS · PBA · HI 4020

**Excepciones:**
- Estado por defecto: displays desactivados (`VALUE ZERO`).

**Estado validación:** Verificado fuente líneas 139-140, 3359-3668

---

## RN-S500-723 — Alta de programa en librería de monitoreo MAPLI (P080)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-723 |
| **Nombre** | Alta de programa en librería de monitoreo MAPLI (P080) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P080 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Todo programa del S500 se da de alta al iniciar y de baja al terminar contra la librería de monitoreo MAPLI mediante los entry points `S038L035_01_PROG_INI` y `S038L035_02_PROG_FIN`. El alta devuelve un identificador de programa (`ID-PROG-S`, PIC 9(08)) que se usa para todas las señales de monitoreo subsecuentes. La copia se codifica: 1 = programa batch o línea, 2 = librería.

**Fórmula/pseudocódigo:**
```
S038L035_01_PROG_INI(NUM-COPIA, DSP-INFO, INICIO-GRUPO, NUM-TIPO-PROC, NOM-TIPO-PROC)
                     → ID-PROG-S  (9-8)
DSP-INFO: 1 = info tipo ACTIVIDADES · 2 = info tipo LIBRERIA
INICIO-GRUPO: 0 = no inicia grupo · >0 = número de grupo que inicia
... S038L035_02_PROG_FIN(ID-PROG-E)   al terminar
```

**Vocabulario en la fórmula:** MAPLI · S038L035 · ID-PROG · NUM-COPIA · TIPO-PROC · INICIO-GRUPO

**Excepciones:**
- Programas con múltiples copias envían el número de copia (1..N); sin copias envían 1.

**Estado validación:** Verificado fuente líneas 1765-1830 (formatos de entry points MAPLI)

---

## RN-S500-724 — Reenvío de sincronizadas al bloque contable B03 (P080)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-724 |
| **Nombre** | Reenvío de sincronizadas al bloque contable B03 (P080) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P080 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las operaciones sincronizadas confirmadas se replican a un archivo dedicado al bloque contable B03 (`ARCH-SINC-B03`), separado del flujo sincronizado general (`ARCHSINC`). Esta bifurcación garantiza que las operaciones que deben impactar contabilidad viajen por un canal propio hacia el amarre con S151, evitando mezclar el reproceso operativo con el asiento contable.

**Fórmula/pseudocódigo:**
```
IF operación confirmada AND requiere asiento contable
   WRITE ARCH-SINC-B03   (canal contable B03)
ELSE
   WRITE ARCHSINC        (canal operativo)
```

**Vocabulario en la fórmula:** ARCH-SINC-B03 · ARCHSINC · Bloque contable B03

**Excepciones:**
- Confianza media: el criterio exacto de enrutamiento B03 vive en la librería L080 (no en P080 directo).

**Estado validación:** Verificado fuente línea 22 (SELECT ARCH-SINC-B03); lógica en librería L080

---

## RN-S500-725 — Cálculo de tarifas de tarjeta con versionamiento e IVA/UDIS (P186)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-725 |
| **Nombre** | Cálculo de tarifas de tarjeta con versionamiento e IVA/UDIS (P186) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P186 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P186 procesa tarjetas cruzando dos bases (S500BD04TARJETAS y S500BD01CAPTACION) aplicando catálogos de tarifas, IVA y UDIS bajo control de versiones (S100VERSIONES, S080TARIFAS, S080IVA, S080L700UDIS). El uso de UDIS implica conversión de valores indexados a la inflación, y el IVA se aplica sobre las comisiones tarifadas según catálogo vigente.

**Fórmula/pseudocódigo:**
```
$SET S080TARIFAS S080IVA S080L700UDIS S080CATALOGOS S100VERSIONES
comisión_tarjeta = tarifa(catálogo_vigente, versión)
IVA              = comisión_tarjeta * tasa_IVA(catálogo)
valor_UDIS       = importe / valor_UDI(fecha)   (indexación inflacionaria)
```

**Vocabulario en la fórmula:** S080TARIFAS · S080IVA · S080L700UDIS · UDIS · S100VERSIONES · S500BD04TARJETAS

**Excepciones:**
- El catálogo de tarifas e IVA se resuelve por versión vigente a la fecha de proceso (control de versiones S100VERSIONES).

**Estado validación:** Verificado fuente líneas 56-79 (includes de bases y catálogos)

---

## RN-S500-726 — Dispersión de traspasos a Cuenta Global y Cuenta de Beneficencia hacia S274 (P186)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-726 |
| **Nombre** | Dispersión de traspasos a Cuenta Global y Cuenta de Beneficencia hacia S274 (P186) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P186 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P186 recibe traspasos a Cuenta Global desde otros sistemas y desde el propio S500 (`I01-TRP-CTAGLB`, registro de 140 caracteres) y genera el archivo de dispersión `E02-DISP-S274` (240 caracteres) hacia el sistema S274 para materializar los traspasos a Cuenta Global y/o Cuenta de Beneficencia. La expansión de 140 a 240 caracteres agrega los campos de ruteo y control que S274 exige.

**Fórmula/pseudocódigo:**
```
READ  I01-TRP-CTAGLB (140)   ← traspasos recibidos (otros sistemas + S500)
para cada traspaso válido:
   armar registro dispersión (240) → E02-DISP-S274  (SECURITYTYPE PUBLIC)
destino = Cuenta Global | Cuenta de Beneficencia
```

**Vocabulario en la fórmula:** Cuenta Global · Cuenta de Beneficencia · I01-TRP-CTAGLB · E02-DISP-S274 · S274

**Excepciones:**
- Traspasos rechazados se listan en R02-RECHAZOS y se registran en I06-ARCH-INCIDENTE.

**Estado validación:** Verificado fuente líneas 109-112 (FD I01-TRP-CTAGLB / E02-DISP-S274)

---

## RN-S500-727 — Dispersión separada de reactivaciones a Cuenta Global (P186)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-727 |
| **Nombre** | Dispersión separada de reactivaciones a Cuenta Global (P186) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P186 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las reactivaciones a Cuenta Global viajan por un archivo de dispersión propio (`E02-DISP-REAC-S274`), separado del archivo de traspasos ordinarios (`E02-DISP-S274`). Esta segregación permite a S274 tratar reactivación y traspaso con reglas contables distintas, aun compartiendo el formato de 240 caracteres.

**Fórmula/pseudocódigo:**
```
IF operación = REACTIVACION
   → E02-DISP-REAC-S274 (240)
ELSE traspaso normal
   → E02-DISP-S274      (240)
```

**Vocabulario en la fórmula:** Reactivación · E02-DISP-REAC-S274 · E02-DISP-S274 · Cuenta Global

**Excepciones:**
- Ambos archivos son SECURITYTYPE PUBLIC para consumo por el sistema receptor S274.

**Estado validación:** Verificado fuente líneas 112210-112230 (FD E02-DISP-REAC-S274)

---

## RN-S500-728 — Bitácora de incidentes y ligas de traspaso (P186)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-728 |
| **Nombre** | Bitácora de incidentes y ligas de traspaso (P186) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P186 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P186 mantiene trazabilidad de reconciliación registrando incidentes en `I06-ARCH-INCIDENTE`, las ligas de correspondencia entre operaciones en `ARCH-HLIG`, y emite una cifra de control (`R01-CIFCTRL`) que amarra el número e importe de traspasos recibidos contra los dispersados a S274.

**Fórmula/pseudocódigo:**
```
por cada traspaso: registrar liga origen↔destino → ARCH-HLIG
si anomalía: escribir I06-ARCH-INCIDENTE
al cierre: R01-CIFCTRL = Σ(recibidos) vs Σ(dispersados a S274)
```

**Vocabulario en la fórmula:** I06-ARCH-INCIDENTE · ARCH-HLIG · R01-CIFCTRL · Cifra de control

**Excepciones:**
- La cifra de control es el punto de amarre para detectar traspasos perdidos entre recepción y dispersión.

**Estado validación:** Verificado fuente líneas 108300-108600 (SELECT de reportes e incidentes)

---

## RN-S500-729 — Reproceso de dispersos reactivos vía archivo S274 al S500 (P186)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-729 |
| **Nombre** | Reproceso de dispersos reactivos vía archivo S274 al S500 (P186) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P186 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P186 opera como puente bidireccional entre la captación S500 y el sistema de tarjetas S274: consume archivos de otros sistemas, actualiza las bases de tarjetas (BD04) y captación (BD01), y la clave de correspondencia (`W77-KEY-I01`) se deriva restando 1 al último registro leído, preservando el orden secuencial de la liga entre registros de entrada y salida.

**Fórmula/pseudocódigo:**
```
W77-KEY-I01   = W77-LAST-I01
W77-REG-LEIDO = W77-KEY-I01 - 1     (liga secuencial entrada→salida)
actualizar BD04TARJETAS + BD01CAPTACION con traspasos confirmados
```

**Vocabulario en la fórmula:** W77-KEY-I01 · W77-LAST-I01 · S500BD04TARJETAS · S500BD01CAPTACION

**Excepciones:**
- Confianza media: la mecánica exacta de la liga secuencial depende de la estructura del archivo I01.

**Estado validación:** Verificado fuente líneas 3114, 3230 (COMPUTE W77-KEY-I01 / W77-REG-LEIDO)

---

## RN-S500-730 — Umbral de saturación 80% en bases de tarjetas B06 (P104)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-730 |
| **Nombre** | Umbral de saturación 80% en bases de tarjetas B06 (P104) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P104 vigila la capacidad de los archivos históricos del bloque B06 de tarjetas calculando el porcentaje de uso (registros históricos máximos entre capacidad máxima). Cuando el uso supera 79.9% y antes estaba por debajo de 79.8%, cuenta el archivo como saturado (`W77-NUM-ARCH-SAT`). El umbral de 80% está hardcodeado con banda de histéresis 79.8/79.9.

**Fórmula/pseudocódigo:**
```
IF B06P-MAXIMA-CAP > 0
   COMPUTE W77-PORC-USO ROUNDED = B06P-REGMAXHIST / B06P-MAXIMA-CAP * 100
IF W77-PORC-USO > 79.9  AND  B06P-PORC-USO < 79.8
   ADD 1 TO W77-NUM-ARCH-SAT        (archivo recién saturado)
IF B06P-PORC-USO < W77-PORC-USO
   MOVE W77-PORC-USO TO B06P-PORC-USO ; STORE-B06P   (persiste nuevo máximo)
```

**Vocabulario en la fórmula:** W77-PORC-USO · B06P-MAXIMA-CAP · B06P-REGMAXHIST · W77-NUM-ARCH-SAT · B06 · 79.9

**Excepciones:**
- La banda 79.8/79.9 evita recontar un archivo que oscila alrededor del umbral (histéresis).
- Umbral 80% no parametrizado: cambio de política de capacidad exige recompilar.

**Estado validación:** Verificado fuente líneas 2066-2078

---

## RN-S500-731 — Transacción de base no auditada para actualización B06 (P104)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-731 |
| **Nombre** | Transacción de base no auditada para actualización B06 (P104) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las actualizaciones al bloque B06 se envuelven en una transacción de base de datos NO auditada (`90400000-BEGIN-TRANSAC-NOAUD` / `END-TRANSAC-NOAUD`), a diferencia de los asientos contables. El uso de transacción no auditada indica que estos registros son de control operativo/estadístico (máximos históricos, % uso) y no forman parte del rastro contable formal.

**Fórmula/pseudocódigo:**
```
BEGIN-TRANSAC-NOAUD
   SETB06P-LOCK / DATAB06P-STORE   (actualiza máximo de uso)
   IF WS-STATUS-BASE = 15 → conflicto de lock, reintento
END-TRANSAC-NOAUD
```

**Vocabulario en la fórmula:** TRANSAC-NOAUD · B06P · WS-STATUS-BASE · DATAB06P-STORE · SETB06P-LOCK

**Excepciones:**
- Status de base = 15 señala bloqueo/conflicto y dispara manejo de reintento.

**Estado validación:** Verificado fuente líneas 2081-2084; includes BD4B00R01/R04 líneas 100-107

---

## RN-S500-732 — Ventana de años relativa a la fecha de máquina para consultas históricas (P104)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-732 |
| **Nombre** | Ventana de años relativa a la fecha de máquina para consultas históricas (P104) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P104 calcula el año anterior y el año posterior a partir del año de la fecha de máquina (`WKS-AAAA-MAQ`) para acotar la ventana de búsqueda histórica de tarjetas, evitando barrer todo el histórico. La ventana es siempre [año-1, año+1] relativa al día de proceso, no un rango fijo.

**Fórmula/pseudocódigo:**
```
COMPUTE W77-ANH-ANT = WKS-AAAA-MAQ - 1
COMPUTE W77-ANH-POS = WKS-AAAA-MAQ + 1
ventana_consulta = [W77-ANH-ANT .. W77-ANH-POS]
```

**Vocabulario en la fórmula:** WKS-AAAA-MAQ · W77-ANH-ANT · W77-ANH-POS · Fecha de máquina

**Excepciones:**
- La ventana ±1 año depende de la fecha del sistema; correr con fecha errónea desplaza la ventana.

**Estado validación:** Verificado fuente líneas 1565-1566

---

## RN-S500-733 — Dimensionamiento de memoria por área × 15000 (P104)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-733 |
| **Nombre** | Dimensionamiento de memoria por área × 15000 (P104) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P104 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P104 predimensiona sus estructuras fijando disco y memoria con constantes hardcodeadas (disco = 300000, memoria = 400000) y calcula capacidad de trabajo como el tamaño de área multiplicado por 15000. Estos valores son específicos del volumen operativo de tarjetas al momento de la última liberación.

**Fórmula/pseudocódigo:**
```
COMPUTE W77-TOT-DISKSIZE = 300000
COMPUTE W77-TOT-MEMSIZE  = 400000
COMPUTE W77-CAPACIDAD    = W77-AREASIZE * 15000
```

**Vocabulario en la fórmula:** W77-TOT-DISKSIZE · W77-TOT-MEMSIZE · W77-CAPACIDAD · W77-AREASIZE · 15000

**Excepciones:**
- Constantes de sizing no parametrizadas: crecimiento del volumen exige ajuste manual y recompilación.

**Estado validación:** Verificado fuente líneas 3066-3067, 3269

---

## RN-S500-734 — Identificación de CSI origen por hostname para transferencia inter-host (P197)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-734 |
| **Nombre** | Identificación de CSI origen por hostname para transferencia inter-host (P197) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P197 transfiere archivos de reconciliación entre los host Unisys de la plataforma leyendo el hostname de la máquina (`ATTRIBUTE HOSTNAME OF MYSELF`) para determinar el CSI de origen: CSI 04 = Monterrey (nodo 04), CSI 10 = México (nodo 10). El CSI origen selecciona la matriz de rutas productiva/UAT/SIT/desarrollo hacia el CSI destino.

**Fórmula/pseudocódigo:**
```
MOVE ATTRIBUTE HOSTNAME OF MYSELF TO WKS-MY-HOST → deriva WKS-CSI-ORIG
IF WKS-CSI-ORIG = 04  → rutas MTY  (MONBETA-VDMALFA ...)
IF WKS-CSI-ORIG = 10  → rutas MEX
CSI 04 = Monterrey · CSI 10 = México
```

**Vocabulario en la fórmula:** HOSTNAME · WKS-CSI-ORIG · CSI 04 · CSI 10 · Nodo · MONBETA · VDMALFA

**Excepciones:**
- Las rutas de host difieren por ambiente (PRODUCCION, UAT, SIT, DESARROLLO), codificadas en la cabecera del programa.

**Estado validación:** Verificado fuente líneas 1563, 1901-1919; matriz de nodos líneas 132-166 (cabecera)

---

## RN-S500-735 — Transferencia de archivos vía INTELAR con verificación de resultado (P197)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-735 |
| **Nombre** | Transferencia de archivos vía INTELAR con verificación de resultado (P197) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El envío de archivos hacia ETL se ejecuta invocando la librería de transferencia INTELAR (`CALL "INTELARSND IN ADMONXFERS"`), y su resultado se valida contra cero: cualquier valor distinto de cero en `WS77-INTELAR-RESULT` significa transferencia fallida y dispara la ruta de manejo de error, incluyendo un comando de transferencia manual como fallback.

**Fórmula/pseudocódigo:**
```
MOVE ZEROS TO WS77-INTELAR-RESULT
CALL "INTELARSND IN ADMONXFERS" ... GIVING WS77-INTELAR-RESULT
IF WS77-INTELAR-RESULT NOT = 0
   → error: reintento / "TRANSFERIR MANUAL: " WS-TRF-COMANDO
```

**Vocabulario en la fórmula:** INTELAR · INTELARSND · ADMONXFERS · WS77-INTELAR-RESULT · TRANSFERIR MANUAL

**Excepciones:**
- Ante falla de INTELAR se documenta el comando manual, evidenciando dependencia de intervención operativa.

**Estado validación:** Verificado fuente líneas 2775-2784, 2573

---

## RN-S500-736 — Fallback de copia inter-host mediante WFL SYSTEM (P197)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-736 |
| **Nombre** | Fallback de copia inter-host mediante WFL SYSTEM (P197) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además de INTELAR, P197 puede disparar la copia física entre hosts invocando trabajos WFL del MCP (`CALL SYSTEM WFL USING WKS-COPY-DUMPALL-8x`). Cada variante 81..89 corresponde a un par host-origen/host-destino de la matriz de rutas, y el programa recibe sus parámetros de arranque por contenido (`W77-PARAM-WFL RECEIVED BY CONTENT`).

**Fórmula/pseudocódigo:**
```
PROCEDURE DIVISION USING W77-PARAM-WFL   (RECEIVED BY CONTENT)
según ruta origen→destino:
   CALL SYSTEM WFL USING WKS-COPY-DUMPALL-81 .. -89
```

**Vocabulario en la fórmula:** WFL · CALL SYSTEM · WKS-COPY-DUMPALL · W77-PARAM-WFL · RECEIVED BY CONTENT

**Excepciones:**
- Las 9 variantes DUMPALL codifican rutas fijas; agregar un host exige nueva variante.

**Estado validación:** Verificado fuente líneas 253, 1530, 2591-2615

---

## RN-S500-737 — Ruta especial de reconciliación por opción 66 en CSI Monterrey (P197)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-737 |
| **Nombre** | Ruta especial de reconciliación por opción 66 en CSI Monterrey (P197) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P197 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P197 reserva un tratamiento especial cuando la opción de parámetro es "66" y el CSI origen es 04 (Monterrey), aplicando una ruta de transferencia distinta a la del flujo estándar. Esta combinación option/CSI actúa como interruptor de comportamiento específico de la plaza Monterrey.

**Fórmula/pseudocódigo:**
```
IF WKS-PAR-OPCION = "66" AND WKS-CSI-ORIG = 04
   → ruta especial de transferencia (solo Monterrey)
```

**Vocabulario en la fórmula:** WKS-PAR-OPCION · 66 · WKS-CSI-ORIG · CSI 04 · Monterrey

**Excepciones:**
- Confianza media: el efecto exacto de la opción 66 requiere leer el bloque de rama completo.

**Estado validación:** Verificado fuente línea 2649

---

## RN-S500-738 — Cálculo de comisiones y rewards desde reglas parametrizadas para Teradata (P131)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-738 |
| **Nombre** | Cálculo de comisiones y rewards desde reglas parametrizadas para Teradata (P131) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P131 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P131 lee el archivo de transacciones enviado por Teradata (`EVCOMIS`) y, con las reglas cargadas en la base S500BD04TARJETAS (tabla B13 de comisiones y tabla B14 de rewards), calcula comisiones y rewards por transacción. Genera dos salidas: el archivo de respuesta a Teradata con los importes calculados (`RESEVAL`) y el archivo de posteo para el procesamiento contable en el S500.

**Fórmula/pseudocódigo:**
```
READ EVCOMIS (transacciones Teradata)
cargar T1 = reglas B13 (comisiones) ; T2 = reglas B14 (rewards) desde BD04TARJETAS
por transacción:
   comisión = buscar_regla_B13(producto, instrumento, moneda, esquema) → IMP-COMISION
   reward   = aplicar_reglas_B14(...)  con STATUS-REWARD activo
WRITE RESEVAL (respuesta Teradata) + WRITE archivo-posteo (contable S500)
```

**Vocabulario en la fórmula:** EVCOMIS · RESEVAL · B13 (comisiones) · B14 (rewards) · Teradata · Posteo

**Excepciones:**
- Producto no encontrado en la tabla de reglas (`WKS-PROD-FOUND = 0`) omite el cálculo para esa transacción.

**Estado validación:** Verificado fuente líneas 173-190 (cabecera), 613-697 (tablas B13/B14)

---

## RN-S500-739 — Llave de producto y mapeo de tipo de evaluación a esquema (P131)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-739 |
| **Nombre** | Llave de producto y mapeo de tipo de evaluación a esquema (P131) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P131 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La llave de búsqueda de reglas se compone concatenando producto, instrumento, moneda y tipo de esquema (1=SALDO, 2=RENTA, 3=REWARD). El tipo de evaluación recibido de Teradata se traduce a esquema: evaluación 05 → esquema 01 (SALDO), evaluación 06 → esquema 02 (RENTA). Este mapeo determina qué familia de reglas aplica a cada transacción.

**Fórmula/pseudocódigo:**
```
WKS-PRODUCTO = producto || instrumento || moneda || tipo-esquema
tipo-esquema: 1=SALDO · 2=RENTA · 3=REWARD
IF WKS-EPP-DET-TIP-EVA = 05  MOVE 01 TO WKS-ESQUEMA-C   (SALDO)
IF WKS-EPP-DET-TIP-EVA = 06  MOVE 02 TO WKS-ESQUEMA-C   (RENTA)
```

**Vocabulario en la fórmula:** WKS-PRODUCTO · WKS-ESQUEMA-C · TIP-EVA · SALDO · RENTA · REWARD · Moneda

**Excepciones:**
- Solo se soportan evaluaciones 05 (saldo) y 06 (renta); ver eliminación del esquema 3 de rewards.

**Estado validación:** Verificado fuente líneas 2143-2154

---

## RN-S500-740 — Moneda de rewards con valor inicial 10 e incremento por regla aplicada (P131)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-740 |
| **Nombre** | Moneda de rewards con valor inicial 10 e incremento por regla aplicada (P131) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P131 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En el archivo de respuesta a Teradata, la moneda del esquema de rewards arranca en un valor fijo de 10 (`WKS-CONT-REWARDS`) y se incrementa en 1 por cada regla de reward aplicada. Este contador codifica en el campo moneda cuántas reglas se dispararon, un uso no estándar del campo moneda documentado explícitamente en la cabecera del programa (versión 25MTP010).

**Fórmula/pseudocódigo:**
```
MOVE 10 TO WKS-CONT-REWARDS          (valor inicial)
por cada regla de reward aplicada:  ADD 1 TO WKS-CONT-REWARDS
MONEDA-R (respuesta) := WKS-CONT-REWARDS
```

**Vocabulario en la fórmula:** WKS-CONT-REWARDS · MONEDA-R · Rewards · 10

**Excepciones:**
- Sobrecarga semántica del campo moneda: transporta un conteo de reglas, no una divisa (riesgo de mala interpretación downstream).

**Estado validación:** Verificado fuente líneas 187-189 (cabecera), 2088

---

## RN-S500-741 — Eliminación del esquema 3 de rewards y evaluación exclusiva de esquemas 5 y 6 (P131)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-741 |
| **Nombre** | Eliminación del esquema 3 de rewards y evaluación exclusiva de esquemas 5 y 6 (P131) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P131 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La versión 26MTP001 de P131 modificó la política de rewards: se eliminó el esquema 3 (rewards independiente) y ahora los rewards se evalúan únicamente acoplados dentro del esquema 5 (saldo + rewards) y el esquema 6 (renta + rewards). Un reward ya no se calcula de forma aislada, sino como componente de la evaluación de saldo o renta.

**Fórmula/pseudocódigo:**
```
esquema 5 → SE EVALUA (SALDO + REWARDS)
esquema 6 → SE EVALUA (RENTA + REWARDS)
esquema 3 → SE ELIMINA (rewards independiente, obsoleto)
```

**Vocabulario en la fórmula:** Esquema 5 · Esquema 6 · Esquema 3 · Saldo · Renta · Rewards

**Excepciones:**
- Transacciones que aún llegaran con tipo de evaluación de esquema 3 ya no producen reward.

**Estado validación:** Verificado fuente líneas 183-190 (cabecera de versión)

---

## RN-S500-742 — Registro de waiver (exención de comisión) por transacción (P131)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-742 |
| **Nombre** | Registro de waiver (exención de comisión) por transacción (P131) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF |
| **Programa ejecutor** | P131 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Por cada comisión y cada reward, P131 registra por separado el monto de waiver (exención/bonificación aplicada) en campos dedicados (`WKS-B13P-WAIVER` para comisiones, `WKS-WAIVER-RW` para rewards) y acumula un total de waiver (`WKS-TOT-WAIVER`, PIC 9(10)V99). La exención se reporta explícitamente para transparencia del monto no cobrado al cliente.

**Fórmula/pseudocódigo:**
```
por comisión:  waiver_comi = WKS-B13P-WAIVER
por reward:    waiver_rew  = WKS-WAIVER-RW
WKS-TOT-WAIVER := Σ(waiver_comi + waiver_rew)
importe_cobrado = comisión - waiver
```

**Vocabulario en la fórmula:** Waiver · Exención · WKS-B13P-WAIVER · WKS-WAIVER-RW · WKS-TOT-WAIVER

**Excepciones:**
- Confianza media: la condición que dispara un waiver reside en la regla parametrizada B13/B14, no en código.

**Estado validación:** Verificado fuente líneas 462, 491, 595

---

## RN-S500-743 — Clasificación y ruteo de rechazos por clave de rechazo (P195)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-743 |
| **Nombre** | Clasificación y ruteo de rechazos por clave de rechazo (P195) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P195 lee el archivo consolidado de rechazos (`I01-RECHAZOS`, registro de 276 caracteres) que porta una clave de rechazo de 4 dígitos (`CVE-RECHAZO`) y su concepto (`CONC-RECH`, 50 caracteres), los ordena por tipo de registro/nodo/sucursal, y los distribuye a reportes segregados por destino de reconciliación: contabilidad S151, interfaz S408, operaciones sin confirmar, y recuperados.

**Fórmula/pseudocódigo:**
```
READ I01-RECHAZOS (276) → CVE-RECHAZO (9-4), CONC-RECH (50)
SORT S03-SORTMOVS ON TPOREG, NODOIMP, SUC-OPERO
según tipo/destino → { R02-RECHS151 | R03-RECHS408 | R04-RECHSINCONF | R06-RECHRECUP }
```

**Vocabulario en la fórmula:** I01-RECHAZOS · CVE-RECHAZO · CONC-RECH · RECHS151 · RECHS408 · RECHSINCONF · RECHRECUP

**Excepciones:**
- Cada reporte tiene ancho de 132 caracteres (formato impresora clásico).

**Estado validación:** Verificado fuente líneas 29-56, 113-118, 1774-1776

---

## RN-S500-744 — Tratamiento segregado de movimientos borrados (P195)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-744 |
| **Nombre** | Tratamiento segregado de movimientos borrados (P195) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P195 procesa los movimientos borrados en un flujo dedicado (`I05-BORRADOS` → reporte `R10-BORRADOS`), separado de los rechazos ordinarios. La segregación permite auditar de forma independiente qué movimientos fueron eliminados del proceso de línea antes de su conciliación contable, dejando rastro impreso.

**Fórmula/pseudocódigo:**
```
READ I05-BORRADOS
por cada registro borrado: WRITE R10-BORRADOS (listado de auditoría)
ADD 1 TO contador de borrados
```

**Vocabulario en la fórmula:** I05-BORRADOS · R10-BORRADOS · Movimiento borrado

**Excepciones:**
- El archivo de borrados es distinto del de rechazos: un borrado no es un rechazo, es una eliminación explícita.

**Estado validación:** Verificado fuente líneas 43, 68-72, 169

---

## RN-S500-745 — Dimensionamiento de sort de rechazos por volumen de sucursal (P195)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-745 |
| **Nombre** | Dimensionamiento de sort de rechazos por volumen de sucursal (P195) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P195 predimensiona el archivo de trabajo del sort de rechazos multiplicando el total de registros por sucursal por 46 bytes y por un factor de holgura de 3.5. El factor 3.5 es una constante de sobreaprovisionamiento de disco recurrente en toda la familia S500 (aparece idéntico en P190, P125, P104).

**Fórmula/pseudocódigo:**
```
COMPUTE W77-TOT-DSKSIZE = W77-TOT-REGASUC * 46 * 3.5
```

**Vocabulario en la fórmula:** W77-TOT-DSKSIZE · W77-TOT-REGASUC · 46 · 3.5

**Excepciones:**
- Factor 3.5 hardcodeado: si el registro de rechazo crece de 46 bytes, el sizing queda subestimado.

**Estado validación:** Verificado fuente línea 1755

---

## RN-S500-746 — Cálculo de devoluciones de cheques e intereses de pago (P125)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-746 |
| **Nombre** | Cálculo de devoluciones de cheques e intereses de pago (P125) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico |
| **Programa ejecutor** | P125 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P125 concilia devoluciones de cheques y el interés de pago asociado. Lee el archivo de devoluciones (`I01-DEVOLUCION`) y el de interés/pago (`I02-INTPAGO`), los ordena y produce reportes por sucursal (DEVASUC), por ventanilla (DEVVENT), consolidado (DEVCONSDO) y de interés de pago (INTPAG), más un reporte de cheques VV (`REPCHVV`).

**Fórmula/pseudocódigo:**
```
SORT I01-DEVOLUCION → S01-SORTDEVOL   (devoluciones)
SORT I02-INTPAGO    → S02-SORTINTPAG  (interés de pago)
reportes: DEVASUC (x sucursal) · DEVVENT (x ventanilla) · DEVCONSDO (consolidado) · INTPAG
```

**Vocabulario en la fórmula:** I01-DEVOLUCION · I02-INTPAGO · DEVASUC · DEVVENT · DEVCONSDO · INTPAG · Cheque VV

**Excepciones:**
- El interés de pago viaja en archivo aparte de la devolución del principal.

**Estado validación:** Verificado fuente líneas 280-288 (SELECT)

---

## RN-S500-747 — Niveles de validación del código CHVV de seguridad lógica de cheques (P125)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-747 |
| **Nombre** | Niveles de validación del código CHVV de seguridad lógica de cheques (P125) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico |
| **Programa ejecutor** | P125 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código CHVV (seguridad lógica del cheque) define el alcance de validación aplicado a cada cheque devuelto según una escala 00-04 de rigor creciente. Un valor fuera de {1,2,3,4} se marca como DESCONOCIDO. La escala determina contra qué estados de cheque (prevenidos, pagados, inexistentes, no liberados) se contrasta el cheque.

**Fórmula/pseudocódigo:**
```
CHVV = 00 → valida cheques PREVENIDOS
CHVV = 01 → valida PREVENIDOS + PAGADOS         (01 SIN CODIGO CHVV EN S127)
CHVV = 02 → valida PREVENIDOS + PAGADOS + INEXISTENTES   (02 SIN CODIGO CHVV EN CHEQUE)
CHVV = 03 → valida PREVENIDOS + PAGADOS + INEXISTENTES + NO LIBERADOS  (03 CODIGOS CHVV DIFERENTES)
CHVV = 04 → valida PREVENIDOS + INEXISTENTES
CHVV ∉ {1,2,3,4} → "VALOR DIFERENTE DE 1,2,3,4 DESCONOCIDO"
```

**Vocabulario en la fórmula:** CHVV · Seguridad lógica · Cheque prevenido · Cheque pagado · Cheque inexistente · No liberado · S127

**Excepciones:**
- Discrepancia entre CHVV del cheque y CHVV en S127 se reporta como "CODIGOS CHVV DIFERENTES" (posible fraude/inconsistencia).

**Estado validación:** Verificado fuente líneas 782-817

---

## RN-S500-748 — Validación de CHECKBOLT y detección de intento de pago de cheque protegido (P125)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-748 |
| **Nombre** | Validación de CHECKBOLT y detección de intento de pago de cheque protegido (P125) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico |
| **Programa ejecutor** | P125 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Junto al CHVV lógico, P125 valida el CHECKBOLT (candado físico de seguridad del cheque) y su código precámara. Un intento de pagar un cheque protegido se marca explícitamente ("01 INTENTO DE PAGO DE CHEQUE PROTEGIDO P/PRECAMARA"), y el CHECKBOLT se clasifica: incorrecto (01) o no capturado (02). Es un control antifraude en el flujo de devolución de cheques.

**Fórmula/pseudocódigo:**
```
causa CHECKBOLT:
   01 → "INTENTO DE PAGO DE CHEQUE PROTEGIDO P/PRECAMARA"
código precámara CHECKBOLT:
   01 → "CHECKBOLT INCORRECTO"
   02 → "CHECKBOLT NO CAPTURADO"
   valor ∉ {1,2,3,4} → "DESCONOCIDO"
```

**Vocabulario en la fórmula:** CHECKBOLT · Precámara · Cheque protegido · Candado físico

**Excepciones:**
- Un CHECKBOLT no capturado (02) deja el cheque sin validación física: hueco de control silencioso.

**Estado validación:** Verificado fuente líneas 825-847

---

## RN-S500-749 — Monitoreo de arranque y fin de programas en batch (P140 / S500BATCH)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-749 |
| **Nombre** | Monitoreo de arranque y fin de programas en batch (P140 / S500BATCH) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P140 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P140 (PROGRAM-ID S500BATCH) es el motor de monitoreo de tareas del sistema S500. Registra los primeros datos de cada programa que arranca en un archivo de control (`FILE-PROGRAMAS`) y emite el reporte de monitoreo de tareas (`FILE-MONI`). Es el consumidor de las señales que los programas envían vía la librería MAPLI (ver RN-S500-723).

**Fórmula/pseudocódigo:**
```
al registrarse un programa (entry point MAPLI):
   WRITE FILE-PROGRAMAS (datos de arranque: id, tipo proceso, grupo)
periódicamente:
   WRITE FILE-MONI (reporte de tareas activas)
```

**Vocabulario en la fórmula:** S500BATCH · FILE-PROGRAMAS · FILE-MONI · MAPLI · Monitoreo de tareas

**Excepciones:**
- Versión MZO/2005; es infraestructura transversal, no específica de un dominio de negocio.

**Estado validación:** Verificado fuente líneas 291-331 (cabecera y FILE-CONTROL)

---

## RN-S500-750 — Agrupación de programas por tipo de proceso para monitoreo (P140)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-750 |
| **Nombre** | Agrupación de programas por tipo de proceso para monitoreo (P140) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P140 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P140 organiza los programas monitoreados por tipo de proceso y grupo. El campo de inicio de grupo marca qué programa abre un grupo de proceso (valor >0 indica el número de grupo), permitiendo al reporte de monitoreo presentar la cadena batch como bloques lógicos en lugar de programas sueltos, base para la vigilancia de dependencias de corrida.

**Fórmula/pseudocódigo:**
```
INICIO-GRUPO = 0  → programa no abre grupo
INICIO-GRUPO > 0  → abre grupo número N
NUM-TIPO-PROC / NOM-TIPO-PROC → clasifica el programa dentro de un tipo de proceso
```

**Vocabulario en la fórmula:** Tipo de proceso · Inicio de grupo · Grupo de proceso · Monitoreo

**Excepciones:**
- Confianza media: la semántica de grupos vive compartida con la librería MAPLI (S038L035).

**Estado validación:** Verificado fuente líneas 296-302; formato entry point en P080 líneas 171100-171800

---

## RN-S500-751 — Punteo de conciliación S500 contra S151 por cargos, abonos y no contables (P190)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-751 |
| **Nombre** | Punteo de conciliación S500 contra S151 por cargos, abonos y no contables (P190) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P190 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P190 es el programa de punteo (tie-out) que concilia el sistema de captación S500 contra la contabilidad S151. Lee los archivos de ambos (`I03-ARCHS500`, `E02-ARCHS151`) y compara por tres categorías (Cargos, Abonos, No Contables), cada una en dos dimensiones: número de movimientos (NUM) e importe (IMP). La diferencia S500 menos S151 debe ser cero para un cuadre correcto.

**Fórmula/pseudocódigo:**
```
para categoría ∈ {CARGOS, ABONOS, NO-CONTABLES}:
   DIF-NUM = TOT-500-NUM(cat) - TOT-151-NUM(cat)
   DIF-IMP = TOT-500-IMP(cat) - TOT-151-IMP(cat)
cuadre_ok ⟺ (DIF-NUM = 0  AND  DIF-IMP = 0)  para las 3 categorías
```

**Vocabulario en la fórmula:** Punteo · Cargos · Abonos · No contables · NUMCGO · IMPCGO · NUMABO · IMPABO · S500 · S151

**Excepciones:**
- Los "No Contables" se puntean también aunque no impacten mayor, para detectar movimientos mal clasificados.

**Estado validación:** Verificado fuente líneas 1584-1621

---

## RN-S500-752 — Fórmula de diferencia de conciliación por conteo e importe (P190)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-752 |
| **Nombre** | Fórmula de diferencia de conciliación por conteo e importe (P190) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV |
| **Programa ejecutor** | P190 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El motor de diferencia de P190 resta directamente los totales de S500 menos S151 para cargos, abonos y no contables, tanto en número como en importe, e imprime la fila de diferencia en el reporte de punteo. Una diferencia distinta de cero es la señal operativa de descuadre que dispara investigación manual.

**Fórmula/pseudocódigo:**
```
COMPUTE WKS-TOT-DIF-NUMCGO = WKS-TOT-500-NUMCGO - WKS-TOT-151-NUMCGO
COMPUTE WKS-TOT-DIF-IMPCGO = WKS-TOT-500-IMPCGO - WKS-TOT-151-IMPCGO
COMPUTE WKS-TOT-DIF-NUMABO = WKS-TOT-500-NUMABO - WKS-TOT-151-NUMABO
COMPUTE WKS-TOT-DIF-IMPABO = WKS-TOT-500-IMPABO - WKS-TOT-151-IMPABO
COMPUTE WKS-TOT-DIF-NUMNOC = WKS-TOT-500-NUMNOC - WKS-TOT-151-NUMNOC
COMPUTE WKS-TOT-DIF-IMPNOC = WKS-TOT-500-IMPNOC - WKS-TOT-151-IMPNOC
```

**Vocabulario en la fórmula:** WKS-TOT-DIF · WKS-TOT-500 · WKS-TOT-151 · NUMCGO · IMPCGO · NUMABO · IMPABO · NUMNOC · IMPNOC

**Excepciones:**
- No hay tolerancia: cualquier diferencia distinta de 0 (centavos incluidos) se reporta como descuadre.

**Estado validación:** Verificado fuente líneas 1589-1620

---

## RN-S500-753 — Sucursal y nombre de CSI hardcodeados en reporte de punteo (P190)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-753 |
| **Nombre** | Sucursal y nombre de CSI hardcodeados en reporte de punteo (P190) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P190 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El encabezado del reporte de punteo determina la sucursal y el nombre del centro de proceso (CSI) por una bifurcación hardcodeada sobre el CSI de máquina: CSI 4 imprime sucursal 3667 "CYSAU MTY CTROL PROD" / "C.S.I. MONTERREY"; cualquier otro CSI imprime sucursal 3084 "PYCP JARDINES" / "C.S.I. MEXICO". Los números de sucursal y los nombres están incrustados en código.

**Fórmula/pseudocódigo:**
```
IF W77-MY-CSI = 4
   SUC = 3667 ; NBSUC = "CYSAU MTY CTROL PROD" ; NCSI = "C.S.I. MONTERREY"
ELSE
   SUC = 3084 ; NBSUC = "PYCP JARDINES"        ; NCSI = "C.S.I. MEXICO"
```

**Vocabulario en la fórmula:** W77-MY-CSI · 3667 · 3084 · CSI Monterrey · CSI México

**Excepciones:**
- Solo contempla dos CSIs (4 y "otro"): un tercer centro rompería el reporte por defecto al de México.

**Estado validación:** Verificado fuente líneas 1638-1645

---

## RN-S500-754 — Validación de integridad del archivo bandera de proceso especial (P055)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-754 |
| **Nombre** | Validación de integridad del archivo bandera de proceso especial (P055) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P055 ejecuta procesos especiales solo si el archivo bandera (`ARCHBANDERA`) supera una validación de cabecera de seis campos: tipo = 01, CSI = CSI local, fecha = fecha de línea, paso = "P055", sistema = "S500" y secuencia esperada. Cualquier discrepancia aborta la ejecución con "ERROR HEADER". Un archivo vacío produce "ERROR EN ARCHIVO ... VACIO SIN REGS, NO SE APLICA".

**Fórmula/pseudocódigo:**
```
READ ARCHBANDERA header:
IF TPO=01 AND CSI=CSI-LOCAL AND FECH=FEC-LINEA
   AND QPASO="P055" AND QSIS="S500" AND QSEQ=TIT-SEQ
   → LEE-REG-ARCH (procede)
ELSE → "ERROR HEADER" ; W77-ERR-ARCH = 2 (no aplica)
archivo vacío → "VACIO SIN REGS, NO SE APLICA"
```

**Vocabulario en la fórmula:** ARCHBANDERA · Proceso especial · CSI-LOCAL · FEC-LINEA · QPASO · QSEQ · Header

**Excepciones:**
- La secuencia (QSEQ) evita reaplicar un archivo bandera ya procesado (idempotencia).

**Estado validación:** Verificado fuente líneas 1397-1419

---

## RN-S500-755 — Ventana horaria para ejecución del proceso especial (P055)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-755 |
| **Nombre** | Ventana horaria para ejecución del proceso especial (P055) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso especial solo se dispara cuando la hora del host (obtenida vía GENERALSUPPORT) es mayor a la hora de proceso programada en el registro de datos del archivo bandera (`HORAPROC`, registro TPOREG=03). Antes de esa hora, P055 no aplica el proceso y espera/reintenta. Es un mecanismo de agendamiento intradía embebido en el archivo bandera.

**Fórmula/pseudocódigo:**
```
leer registro datos (TPOREG=03) → HORAPROC (WKS-HRA-ARCH)
CALL GENERALSUPPORT → WKS-HRA-HOST-HMSC
IF WKS-HRA-HOST-HMSC > WKS-HRA-ARCH
   MOVE 1 TO W77-IN-TIME  (dentro de ventana → puede ejecutar)
ELSE espera / no aplica aún
```

**Vocabulario en la fórmula:** HORAPROC · WKS-HRA-HOST-HMSC · WKS-HRA-ARCH · W77-IN-TIME · GENERALSUPPORT

**Excepciones:**
- El tipo de proceso debe ser válido (`W88-TPO-PRO-OK`); si no, "NO EFECTUO PROC-ESPECIAL TIPO-PROCESO ERRONEO".

**Estado validación:** Verificado fuente líneas 1422-1461

---

## RN-S500-756 — Validación de versión, reintentos e identidad XATMI antes del proceso especial (P055)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-756 |
| **Nombre** | Validación de versión, reintentos e identidad XATMI antes del proceso especial (P055) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P055 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de ejecutar el proceso especial, P055 valida la versión de la pieza a ejecutar (`VALIDA-VERSION`) y se identifica como transacción distribuida ante XATMI (`TP_IDENTIFY IN XATMI`, programa "S500P055"). Maneja reintentos acotados (`W77-INTENTOS`, 2 dígitos). Un tipo de proceso 90 activa el modo de remover el archivo bandera (`W88-REMOVER-ARCH`) sin ejecutar la pieza.

**Fórmula/pseudocódigo:**
```
CHANGE-XATMI ; TP_IDENTIFY IN XATMI (WS-XATMI-PROG-NAME = "S500P055")
IF WS-XATMI-RSLT NOT = 0 → error "AL OBTENER EL TP_IDENTIFY IN XATMI"
IF W88-REMOVER-ARCH (tipo=90) → solo remueve archivo bandera
ELSE VALIDA-VERSION ; reintentar hasta W77-INTENTOS
```

**Vocabulario en la fórmula:** XATMI · TP_IDENTIFY · S500P055 · W77-INTENTOS · W88-REMOVER-ARCH · VALIDA-VERSION

**Excepciones:**
- Tipo de proceso 90 es un comando de limpieza (remover bandera), no una ejecución de negocio.

**Estado validación:** Verificado fuente líneas 162, 1044-1052, 1463

---

## RN-S500-757 — Generación de archivo de tasas para Tesorería por rangos calificados en S080 (P200)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-757 |
| **Nombre** | Generación de archivo de tasas para Tesorería por rangos calificados en S080 (P200) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico |
| **Programa ejecutor** | P200 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P200 genera el archivo de tasas pagadas para Tesorería a partir de los rangos de saldo calificados en la librería S080 (`I01-RANGOS`). Construye un archivo puente, lo clasifica, genera el archivo para Tesorería, lo reclasifica y produce un reporte de validación. Cada rango porta la tasa neta pagada (TASANP), tasa bruta pagada (TASABP) y tasa nominal (TASANT).

**Fórmula/pseudocódigo:**
```
READ I01-RANGOS (rangos calificados S080) → TASANP, TASABP, TASANT
SORT S01-RANGOS
generar archivo puente → clasificar → archivo Tesorería → clasificar → reporte validación
```

**Vocabulario en la fórmula:** Rangos calificados · S080 · TASANP · TASABP · TASANT · Tesorería · Archivo puente

**Excepciones:**
- Las tasas se almacenan con precisión 9(03)V9(03) COMP (3 enteros, 3 decimales).

**Estado validación:** Verificado fuente líneas 44-91 (SELECT/FD rangos y tasas), cabecera 433-441

---

## RN-S500-758 — Cálculo de tasa neta y tasa bruta con precisión extendida (P200)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-758 |
| **Nombre** | Cálculo de tasa neta y tasa bruta con precisión extendida (P200) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico |
| **Programa ejecutor** | P200 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P200 deriva la tasa neta (`WKS-TASANETA`, PIC 9(04)V9(06)) y la tasa bruta (`WKS-TASABRUTA`, 9(04)V9(06)) con seis decimales de precisión, a partir de las tasas pagadas del rango. El uso de mayor precisión en el cálculo intermedio (6 decimales) que en el almacenamiento del rango (3 decimales) reduce el error de redondeo antes de reportar a Tesorería.

**Fórmula/pseudocódigo:**
```
WKS-TASANETA  = f(TASANP del rango)   [9(04)V9(06), 6 decimales]
WKS-TASABRUTA = f(TASABP del rango)   [9(04)V9(06)]
comparación contra tasa anterior (WKS-TASANP-ANT / WKS-TASABP-ANT)
```

**Vocabulario en la fórmula:** WKS-TASANETA · WKS-TASABRUTA · TASANP · TASABP · Tasa anterior

**Excepciones:**
- Confianza media: la fórmula exacta neta↔bruta (retención ISR sobre intereses) requiere leer el bloque de cálculo completo.

**Estado validación:** Verificado fuente líneas 202-213

---

## RN-S500-759 — Purga del archivo puente al finalizar la generación de Tesorería (P200)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-759 |
| **Nombre** | Purga del archivo puente al finalizar la generación de Tesorería (P200) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P200 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo puente intermedio que P200 usa para clasificar los rangos se elimina físicamente al terminar el proceso (`CLOSE WITH PURGE`). Solo persisten el archivo final para Tesorería y el reporte de validación. Esto evita que un archivo puente huérfano se reprocese o se confunda con la salida oficial.

**Fórmula/pseudocódigo:**
```
... generar archivo Tesorería + reporte validación
CLOSE archivo-puente WITH PURGE   (se destruye el intermedio)
```

**Vocabulario en la fórmula:** Archivo puente · CLOSE WITH PURGE · Tesorería

**Excepciones:**
- Si el proceso aborta antes del CLOSE, el archivo puente puede quedar residual y requerir limpieza manual.

**Estado validación:** Verificado fuente cabecera línea 441 ("EL ARCHIVO PUENTE SE TIRA AL FINAL (CLOSE WITH PURGE)")

---

## RN-S500-760 — Generación de reporte de detalle y borrado de bandera de control P187 (P188)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-760 |
| **Nombre** | Generación de reporte de detalle y borrado de bandera de control P187 (P188) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P188 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P188 genera el reporte de detalle (`R04-DETALLE`) para los archivos de salida que lo requieren y, al terminar, elimina el archivo de control del paso P187 (`S500/LIST/P187`) como señal de que el detalle ya fue generado. El borrado de la bandera P187 es el mecanismo de handshake entre P187 y P188 en la cadena batch.

**Fórmula/pseudocódigo:**
```
para cada archivo de salida que requiere detalle:
   WRITE R04-DETALLE (REPORTE-DETA)
al terminar:
   DELETE / CHANGE ATTRIBUTE archivo "S500/LIST/P187"  (borra bandera de control)
```

**Vocabulario en la fórmula:** R04-DETALLE · P187 · Bandera de control · Handshake batch

**Excepciones:**
- Mientras exista la bandera P187, el detalle se considera pendiente; su ausencia significa "detalle generado".

**Estado validación:** Verificado fuente líneas 285, 302, 336 (referencias a P187); cabecera 478-483

---

## RN-S500-761 — Generación de listado en el pack del sistema invocador (P188)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-761 |
| **Nombre** | Generación de listado en el pack del sistema invocador (P188) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P188 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P188 es un utilitario reutilizable: puede ser llamado desde cualquier sistema y genera su listado de detalle en el pack (volumen de disco) del sistema que lo invoca, no en un pack fijo. El destino se resuelve por el título de pack (`A04-DET-TITPACK`) y el hostname, lo que lo convierte en un servicio de reporte compartido de la plataforma.

**Fórmula/pseudocódigo:**
```
$SET HOSTNAME
título_reporte := pack(sistema_invocador) || "DETALLE"
A04-DET-TITPACK ← pack destino dinámico
WRITE listado en pack del invocador
```

**Vocabulario en la fórmula:** TITPACK · Pack · HOSTNAME · Sistema invocador · Servicio compartido

**Excepciones:**
- Al ser transversal, no valida reglas de negocio del sistema llamador; solo formatea y ubica el listado.

**Estado validación:** Verificado fuente líneas 203, 228; cabecera 482-483

---

## RN-S500-762 — Fusión de archivos gerenciales de ambos CSIs en cinta única (P430)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-762 |
| **Nombre** | Fusión de archivos gerenciales de ambos CSIs en cinta única (P430) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P430 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P430 concilia la vista gerencial fusionando los archivos X/Gerencial de los dos CSIs (`GERENCIAL-MTY` de Monterrey y `GERENCIAL-VDM` de México/VDM) en una sola cinta consolidada (`GERENCIAL-TAPE`, registro de 90 caracteres). Consolidar ambos CSIs en un solo archivo permite un reporte gerencial nacional único enviado a ETL.

**Fórmula/pseudocódigo:**
```
READ GERENCIAL-MTY  (CSI Monterrey)
READ GERENCIAL-VDM  (CSI México/VDM)
merge → GERENCIAL-TAPE (90)   [visión nacional consolidada]
IMPRESION-CSI ← reporte por CSI
```

**Vocabulario en la fórmula:** GERENCIAL-MTY · GERENCIAL-VDM · GERENCIAL-TAPE · CSI · X/Gerencial · AHOSDOS

**Excepciones:**
- El modelo asume exactamente dos CSIs (MTY y VDM); estructura rígida a dos plazas.

**Estado validación:** Verificado fuente líneas 39-102 (SELECT/FD gerenciales)

---

## RN-S500-763 — Marca de CSI de procedencia en la fusión gerencial (P430)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-763 |
| **Nombre** | Marca de CSI de procedencia en la fusión gerencial (P430) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P430 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la fusión, P430 mantiene el CSI de procedencia (`WS-CSI`, PIC 9(02) BINARY) de cada registro para poder desglosar por plaza en el reporte impreso y preservar la trazabilidad del origen contable de cada cifra gerencial en la cinta consolidada.

**Fórmula/pseudocódigo:**
```
WS-CSI := CSI del archivo origen (MTY | VDM)
cada REG-GER-TAPE conserva su CSI de procedencia
IMPRESION-CSI totaliza por WS-CSI
```

**Vocabulario en la fórmula:** WS-CSI · Plaza · Procedencia · REG-GER-TAPE

**Excepciones:**
- Confianza media: el desglose exacto por CSI en el reporte requiere el bloque de impresión completo.

**Estado validación:** Verificado fuente líneas 92-93, 131

---

## RN-S500-764 — Concentración de saldos de tarjeta por turno matutino y vespertino (P420)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-764 |
| **Nombre** | Concentración de saldos de tarjeta por turno matutino y vespertino (P420) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P420 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P420 (CONCENTRADOR-SALDOSTB) unifica los archivos de saldos de tarjetas de ambos turnos: matutino (`SALDOSTBM`, `SALDOSTBTM`) y vespertino (`SALDOSTBV`, `SALDOSTBTV`). La unión de los cuatro archivos SALDOTB produce el saldo consolidado del día por tarjeta, base para el cuadre de tarjetas contra contabilidad.

**Fórmula/pseudocódigo:**
```
UNION( SALDOSTBM, SALDOSTBTM,   -- turno matutino
       SALDOSTBV, SALDOSTBTV )  -- turno vespertino
→ saldo consolidado del día por tarjeta
```

**Vocabulario en la fórmula:** SALDOSTBM · SALDOSTBV · SALDOSTBTM · SALDOSTBTV · Matutino · Vespertino · SALDOTB

**Excepciones:**
- Requiere que ambos turnos hayan cerrado; falta de un turno produce saldo incompleto.

**Estado validación:** Verificado fuente líneas 29-32 (SELECT SALDOSTB*), cabecera 548

---

## RN-S500-765 — Salida del saldo consolidado a cintas etiquetadas CM y CH (P420)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-765 |
| **Nombre** | Salida del saldo consolidado a cintas etiquetadas CM y CH (P420) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-12 |
| **bian_ref** | 6.7.2 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P420 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El saldo consolidado se escribe en dos cintas de 90 caracteres con etiqueta dinámica: `CINTACM` (etiqueta `WS-ETIQ-CINTACM`) y `CINTACH`. La separación en dos salidas responde al ruteo posterior de la cinta hacia los dos destinos/CSIs de contabilidad, cerrando el ciclo de concentración de saldos de tarjeta.

**Fórmula/pseudocódigo:**
```
saldo consolidado → WRITE CINTACM (90, TITLE = WS-ETIQ-CINTACM)
                  → WRITE CINTACH (90)
```

**Vocabulario en la fórmula:** CINTACM · CINTACH · WS-ETIQ-CINTACM · Cinta · Etiqueta

**Excepciones:**
- Confianza media: el criterio exacto de reparto entre CM y CH requiere el bloque de escritura.

**Estado validación:** Verificado fuente líneas 33-34, 85-97 (FD CINTACM/CINTACH)

---

## RN-S500-766 — Cola en memoria de cancelaciones asíncronas como librería congelada compartida (L091 / P091 / P093)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-766 |
| **Nombre** | Cola en memoria de cancelaciones asíncronas como librería congelada compartida (L091 / P091 / P093) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-17 |
| **bian_ref** | T.2.3 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (P091 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El envío asíncrono de cancelaciones se implementa como una librería NEWP/ALGOL congelada y compartida por todos (`$SET SHARING=SHAREDBYALL` + `FREEZE(CONTROL,USO)`), no como un middleware MQ comercial. Mantiene en memoria una cola de mensajes de cancelación que un proceso asíncrono (`ENVIA_CANCELACIONES`) reintenta enviar por COMS hasta confirmar o vencer. P091 y P093 son los wrappers COMS/DCI que arrancan el procedimiento en modo online.

**Fórmula/pseudocódigo:**
```
Librería L091 (SHAREDBYALL, FREEZE) exporta:
   SETMSGSZ, GUARDAMSG, RESUELVEMSG, BORRAMSG, ENVIA_CANCELACIONES, OLVIDATODO
P091/P093: ENABLE(COMSINHDR,"ONLINE") ; ENVIA_CANCELACIONES(COMS_IN, COMS_OUT, IN_EV, TSK_EV)
patrón: enviar y reintentar hasta confirmación o vencimiento (fire-and-forget con reintento)
```

**Vocabulario en la fórmula:** L091 · ENVIA_CANCELACIONES · SHAREDBYALL · FREEZE · COMS · Asíncrono · Cancelación

**Excepciones:**
- No hay garantía transaccional de entrega tipo MQ: la resiliencia depende de reintentos y persistencia propia (ver RN-S500-772).

**Estado validación:** Verificado fuente L091 líneas 1-2, 162-165, 503-514; P091/P093 líneas 9-11, 46-55

---

## RN-S500-767 — Almacenamiento de mensaje con detección de duplicados por folio y códigos de resultado (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-767 |
| **Nombre** | Almacenamiento de mensaje con detección de duplicados por folio y códigos de resultado (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (GUARDAMSG) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El alta de un mensaje de cancelación (`GUARDAMSG`) detecta duplicados por folio usando `MASKSEARCH` sobre el vector de folios en memoria: si el folio ya existe, devuelve código 2 (duplicado) sin reinsertar, garantizando idempotencia. Devuelve códigos de error diferenciados que el llamador debe interpretar.

**Fórmula/pseudocódigo:**
```
GUARDAMSG(FOLIO, MSG_SZ, EDO, MSG):
   IF MSG_SZ > MAX_SZ      → 3
   IF MSG_SZ > SIZE(MSG)   → 4
   IF FOLIO < 1            → 5
   IF folio ya en MEM (MASKSEARCH) → 2 (DUPLICADO)
   IF no hay lugar / lock ocupado  → 1
   ELSE inserta en MEM[J], marca RESUMEN, guarda CONTEXTO → 0 (ok)
```

**Vocabulario en la fórmula:** GUARDAMSG · FOLIO · MASKSEARCH · Duplicado · MAX_SZ · Código de resultado

**Excepciones:**
- Código 1 (sin lugar o lock) es reintentable; códigos 2-5 son fallas definitivas del llamador.

**Estado validación:** Verificado fuente L091 líneas 74-110

---

## RN-S500-768 — Capacidad fija de 2016 posiciones en la cola de cancelaciones (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-768 |
| **Nombre** | Capacidad fija de 2016 posiciones en la cola de cancelaciones (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La cola de cancelaciones tiene una capacidad fija de 2016 posiciones, codificada en las constantes `N=2015` (posiciones 0..2015) y `M=41` (42 palabras × 48 bits = 2016 bits de resumen). Alcanzada la capacidad, `GUARDAMSG` devuelve 1 (sin lugar) y el mensaje debe reintentarse más tarde. No hay crecimiento dinámico del número de slots.

**Fórmula/pseudocódigo:**
```
DEFINE N = 2015   (posiciones memoria - 1)
DEFINE M = 41     ((0-41=42)*16... 2016 entradas de bitmap RESUMEN)
capacidad = N+1 = 2016 mensajes simultáneos máximo
lugares_libres = (N+1) - Σ ONES(RESUMEN[0..M])
```

**Vocabulario en la fórmula:** N · M · 2016 · RESUMEN · Bitmap · Capacidad

**Excepciones:**
- Saturación de los 2016 slots frena el alta de nuevas cancelaciones (código 1), no las pierde: presión de reintento sobre el llamador.

**Estado validación:** Verificado fuente L091 líneas 20-21, 28-35, 240-241

---

## RN-S500-769 — Tope de tamaño de mensaje 2994 bytes y vigencia por defecto 2 horas (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-769 |
| **Nombre** | Tope de tamaño de mensaje 2994 bytes y vigencia por defecto 2 horas (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (SETMSGSZ) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** `SETMSGSZ` fija el tamaño máximo de mensaje topándolo a 2994 bytes (`MIN(2994, APL_SZ)`) y las horas de vigencia de un mensaje en memoria entre 1 y 24, con valor por defecto 2 horas si el parámetro está fuera de rango. Existe además una regla especial: si el identificador de instancia (`YO`) es "32", la vigencia se reduce a la mitad. El timeout de reenvío arranca en 60 segundos (`TIME_OUT_DEF`).

**Fórmula/pseudocódigo:**
```
MAX_SZ := MIN(2994, APL_SZ)
IF HORAS < 1 OR HORAS > 24 → HORAS := 2   (default)
HORAS_VENCE := 3600 * HORAS
IF YO = "32" → HORAS_VENCE := HORAS_VENCE / 2   (instancia especial vive la mitad)
TIME_OUT_DEF = 60 segundos
```

**Vocabulario en la fórmula:** MAX_SZ · 2994 · HORAS_VENCE · TIME_OUT_DEF · YO · 32

**Excepciones:**
- El caso `YO="32"` es un hardcode de comportamiento por instancia difícil de rastrear (magic string).

**Estado validación:** Verificado fuente L091 líneas 382-394, 22-23

---

## RN-S500-770 — Reenvío automático y bitácora de vencidos por el proceso asíncrono (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-770 |
| **Nombre** | Reenvío automático y bitácora de vencidos por el proceso asíncrono (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (REVISA / ENVIA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso asíncrono revisa cíclicamente la cola (`REVISA`) y reenvía cada mensaje cuya hora de último envío es anterior al límite calculado (`VENCE[J] < LIMITE`), marcándolo como cancelado y despachándolo por COMS (`SEND`). Cuando un mensaje supera su hora de vencimiento (`OLVIDA[J] < T_60`), se descarta de memoria y se escribe en el archivo LOG de RECHAZOS para trazabilidad de cancelaciones no confirmadas.

**Fórmula/pseudocódigo:**
```
REVISA (cada DELTA ≤ TIEMPO segundos):
  para cada slot ocupado:
     IF VENCE[J] < LIMITE:
        MEM[J].[47:1] := 1        (marca CANCELADO)
        SEND(COMS_OUT, SZ[J], CONTEXTO[J])   ; ENVIOS := +1
        IF OLVIDA[J] < T_60:      (mensaje vencido)
           WRITE(LOG, ...)        (bitácora RECHAZOS) ; libera slot
```

**Vocabulario en la fórmula:** REVISA · ENVIA · VENCE · LIMITE · OLVIDA · SEND · LOG RECHAZOS · Cancelado

**Excepciones:**
- Un mensaje que nunca se confirma vive hasta HORAS_VENCE y termina en el log de RECHAZOS (pérdida controlada, no silenciosa).

**Estado validación:** Verificado fuente L091 líneas 277-343, 185-192 (cierre de LOG)

---

## RN-S500-771 — Persistencia de la cola en disco entre reinicios (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-771 |
| **Nombre** | Persistencia de la cola en disco entre reinicios (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (FIN_LIB / ARRANCAN) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para no perder cancelaciones pendientes al bajar la librería, el epílogo `FIN_LIB` vuelca los mensajes vivos en memoria al archivo de disco `S500/FILE/I91/MOVTOS/PEND` (junto con MAX_SZ, HORAS_VENCE y TIEMPO). Al arrancar, `ARRANCAN` detecta ese archivo residente, recarga los mensajes a memoria conservando su hora de vencimiento y lo purga. La cola sobrevive a reinicios de la librería.

**Fórmula/pseudocódigo:**
```
FIN_LIB (al bajar):
   WRITE SALVA(/, MAX_SZ, HORAS_VENCE, TIEMPO)
   para cada MEM[J] ≠ 0: WRITE registro(MEM,SZ,VENCE,OLVIDA,CONTEXTO) → PEND
ARRANCAN (al subir):
   IF PEND.RESIDENT: READ params ; recargar mensajes a MEM ; CLOSE(PEND, PURGE)
```

**Vocabulario en la fórmula:** PEND · FIN_LIB · ARRANCAN · MOVTOS · RESIDENT · Persistencia

**Excepciones:**
- Una caída dura del MCP (sin ejecutar FIN_LIB) sí pierde los mensajes en memoria: la persistencia es solo en paro ordenado.

**Estado validación:** Verificado fuente L091 líneas 396-451, 453-476

---

## RN-S500-772 — Timeout de reenvío autoajustable según tiempo de respuesta (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-772 |
| **Nombre** | Timeout de reenvío autoajustable según tiempo de respuesta (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (USO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La librería ajusta dinámicamente su intervalo de reenvío (`TIEMPO`) en función del tiempo de respuesta observado: si el tiempo promedio de respuesta supera la mitad del timeout actual, lo incrementa 50% (backoff); si no, lo reduce a dos tercios, con piso en el default de 60 segundos. Evita saturar el canal COMS cuando el consumidor responde lento.

**Fórmula/pseudocódigo:**
```
cada 40 s (USO):
   D := respuestas_en_periodo
   IF D > 0:
      IF (Σt_respuesta / D) > TIEMPO/2 → TIEMPO := 1.5 * TIEMPO   (backoff)
      ELSE                              → TIEMPO := MAX(60, 2*TIEMPO/3)  (acelera)
```

**Vocabulario en la fórmula:** TIEMPO · TIME_OUT_DEF · Backoff · STS (estadísticas) · Tiempo de respuesta

**Excepciones:**
- El piso duro de 60 s impide que el reenvío se vuelva demasiado agresivo.

**Estado validación:** Verificado fuente L091 líneas 478-501

---

## RN-S500-773 — Alerta a consola por inactividad del proceso asíncrono (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-773 |
| **Nombre** | Alerta a consola por inactividad del proceso asíncrono (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (USO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si el proceso asíncrono no está activo (`ACTIVO = FALSE`) durante más de 2 ciclos de verificación, la librería emite una alerta a consola: "PRECAUCION: FAVOR DE ACTIVAR PROGRAMA ASINCRONO". Es el mecanismo que evita que las cancelaciones se acumulen silenciosamente en memoria sin que nadie las despache cuando P091/P093 no está corriendo.

**Fórmula/pseudocódigo:**
```
cada 40 s (USO):
   IF NOT ACTIVO AND (VECES_SIN_ASC := +1) > 2:
      VECES_SIN_ASC := 0
      DISPLAY("060103 01 S500 L091 25MTP002 PRECAUCION: FAVOR DE ACTIVAR PROGRAMA ASINCRONO")
```

**Vocabulario en la fórmula:** ACTIVO · VECES_SIN_ASC · PRECAUCION · Asíncrono · DISPLAY

**Excepciones:**
- La alerta es solo un aviso a consola; no auto-arranca el asíncrono ni detiene el alta de mensajes.

**Estado validación:** Verificado fuente L091 líneas 493-499, 46, 352

---

## RN-S500-774 — Control de concurrencia por interlocks global y por slot (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-774 |
| **Nombre** | Control de concurrencia por interlocks global y por slot (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al ser compartida por todos los procesos (SHAREDBYALL), la cola protege su integridad con interlocks: uno global (`LK_S500`) que serializa el alta de mensajes, y uno por posición (`LK_MEM[0:N]`) que permite resolver o reenviar mensajes en paralelo sin bloquear toda la cola. Los intentos de lock son con timeout, devolviendo código 1 (reintentable) cuando el lock está ocupado.

**Fórmula/pseudocódigo:**
```
GUARDAMSG: IF LOCK(LK_S500,3)=2 → return 1 (ocupado, reintente)
RESUELVEMSG/BORRAMSG: LOCK(LK_MEM[J],3)  (lock fino por slot)
excepción/epílogo: UNLOCK si el proceso es dueño (LOCKSTATUS = PROCESSID)
```

**Vocabulario en la fórmula:** INTERLOCK · LK_S500 · LK_MEM · LOCK · UNLOCK · PROCESSID · Concurrencia

**Excepciones:**
- El lock fino por slot es lo que permite throughput; un solo lock global sería cuello de botella con 2016 slots.

**Estado validación:** Verificado fuente L091 líneas 42-44, 80-81, 94, 118-123

---

## RN-S500-775 — Confirmación y baja de mensajes con medición de tiempo de respuesta (L091)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-775 |
| **Nombre** | Confirmación y baja de mensajes con medición de tiempo de respuesta (L091) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | L091 (RESUELVEMSG / BORRAMSG) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando llega la confirmación de una cancelación, `RESUELVEMSG(FOLIO, ESTADO)` localiza el mensaje por folio, valida que el estado coincida, libera el slot y acumula el tiempo de respuesta (minutos entre inserción y resolución) en las estadísticas. `BORRAMSG(FOLIO)` permite la baja explícita e incondicional de un mensaje. Ambos alimentan el ajuste adaptativo del timeout (RN-S500-772).

**Fórmula/pseudocódigo:**
```
RESUELVEMSG(FOLIO, ESTADO):
   J := MASKSEARCH(FOLIO)  ; si no existe → 2
   IF MEM[J].[47:1] ≠ ESTADO → 1 (estado no coincide)
   t_resp := TIME(1)/60 - OLVIDA[J]   ; STS[1] += 1 ; STS[2] += t_resp
   liberar slot (MEM/OLVIDA/VENCE := 0)
BORRAMSG(FOLIO): localizar y liberar incondicional ; si no existe → 1
```

**Vocabulario en la fórmula:** RESUELVEMSG · BORRAMSG · FOLIO · ESTADO · STS · Tiempo de respuesta

**Excepciones:**
- Confirmar con estado que no coincide (código 1) protege contra acks cruzados/tardíos.

**Estado validación:** Verificado fuente L091 líneas 112-160

---

## RN-S500-776 — Wrappers COMS/DCI de arranque online y versionamiento de instancia (P091 / P093)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-776 |
| **Nombre** | Wrappers COMS/DCI de arranque online y versionamiento de instancia (P091 / P093) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-17 |
| **bian_ref** | T.2.3 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P091 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P091 y P093 son wrappers casi idénticos que habilitan el ambiente COMS online (`ENABLE(COMSINHDR,"ONLINE")`) e invocan `ENVIA_CANCELACIONES` de la librería TIME_OUT (L091). Difieren en versión e identificador de instancia: P091 usa VERSION 99.01.00 y MY_ID "25MTP002" (título de log L091ASIN); P093 usa VERSION 06.001.06000, MY_ID "18MTP002", título L093ASIN y activa `$SET TADS` (modo depuración/test). El título del log resuelve su nombre por control de versiones (CTLVERS).

**Fórmula/pseudocódigo:**
```
P091: $SET VERSION 99.01.00 ; MY_ID "25MTP002" ; "L091ASIN"
P093: $SET VERSION 06.001.06000 ; MY_ID "18MTP002" ; "L093ASIN" ; %$ SET TADS (test)
ambos: DAME_TIT(CTLVERS) → título ; ENABLE(COMSINHDR,"ONLINE") ; ENVIA_CANCELACIONES(...)
```

**Vocabulario en la fórmula:** COMSINHDR · ENABLE · ONLINE · ENVIA_CANCELACIONES · TADS · CTLVERS · MY_ID · TIME_OUT

**Excepciones:**
- P093 con `$SET TADS` es una instancia de prueba/depuración; correrla en producción cambiaría el comportamiento de traza.

**Estado validación:** Verificado fuente P091 líneas 1-56; P093 líneas 1-57

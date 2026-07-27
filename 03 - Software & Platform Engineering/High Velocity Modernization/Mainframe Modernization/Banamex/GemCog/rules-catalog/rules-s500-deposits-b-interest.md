# Catálogo de Reglas de Negocio — S500 Deposits B + Interest
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P107 · P189 · P117 · P168 · P315 · P181 · P187 · P108 · P050 · P199 · P305 · P121 (Deposits) · P330 · P320 (Interest & Fees)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-361 a RN-S500-430 (70 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-361 — Modo de ejecución del proceso de comisiones EPP y TESOFE por TASKVALUE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-361 |
| **Nombre** | Modo de ejecución del proceso de comisiones EPP y TESOFE por TASKVALUE |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa P107 se autoconfigura según el atributo TASKVALUE que recibe del ejecutor de batch. Un solo módulo cubre tres modos de operación: pagar/vencer comisiones EPP, conciliar saldos TESOFE, o ambos. Si el TASKVALUE no está en el conjunto válido {01, 02, 03}, el programa se aborta (STATUS = -1) para no ejecutar un proceso indefinido sobre la contabilidad.

**Fórmula/pseudocódigo:**
```
WKS-TASK-VALUE = ATTRIBUTE TASKVALUE OF MYSELF
88 W88-TASK-VAL-OK      = 01, 02, 03
88 W88-TASK-VAL-EPP     = 01   → sólo Comisiones EPP
88 W88-TASK-VAL-TESOFE  = 02   → sólo Proceso TESOFE
88 W88-TASK-VAL-TODO    = 03   → ambos procesos

IF NOT W88-TASK-VAL-OK
   MOVE "ERROR TASK VALUE" → mensaje
   CHANGE ATTRIBUTE STATUS OF MYSELF TO -1   (aborta paso)
```

**Vocabulario en la fórmula:** TASKVALUE · W88-TASK-VAL-EPP · W88-TASK-VAL-TESOFE · W88-TASK-VAL-TODO · COMPENDEPP

**Excepciones:**
- TASKVALUE fuera de {01,02,03} termina el paso con status -1 sin procesar nada.

**Estado validación:** Verificado fuente líneas 366-370, 620-630

---

## RN-S500-362 — Comisión EPP con saldo cero se marca como pagada (STATUS 4)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-362 |
| **Nombre** | Comisión EPP con saldo cero se marca como pagada (STATUS 4) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la primera vuelta de revisión de comisiones (estructura B49), toda comisión EPP cuyo saldo pendiente sea cero y que aún esté en estado activo (STATUS 0) se reclasifica a estado 4 (pagada) y se le sella la fecha de última actualización con la fecha de lote del proceso. Es el cierre contable de una comisión liquidada.

**Fórmula/pseudocódigo:**
```
IF B49-SALDO = 0
   PERFORM COMISION-PAGADA
      IF B49-STATUS = 0
         MOVE 4            TO B49-STATUS       (pagada)
         MOVE WKS-FEC-BASE TO B49-FECHA-ULTACT
         STORE B49
```

**Vocabulario en la fórmula:** B49-SALDO · B49-STATUS · B49-FECHA-ULTACT · WKS-FEC-BASE (fecha de lote)

**Excepciones:**
- Sólo aplica si STATUS previo = 0; comisiones ya en 3/4 no se re-tocan.

**Estado validación:** Verificado fuente líneas 932-961

---

## RN-S500-363 — Comisión EPP vencida se marca STATUS 3 cuando la fecha de línea es anterior a la proyección

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-363 |
| **Nombre** | Comisión EPP vencida se marca STATUS 3 cuando la fecha de línea es anterior a la proyección |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Una comisión EPP con saldo distinto de cero se declara vencida (STATUS 3) cuando su fecha de línea original es anterior a la fecha proyectada de vencimiento calculada a partir de los meses de vigencia del instrumento EPP. La validación sólo se dispara si en la tabla EPP el instrumento tiene meses de vigencia configurados y su indicador de vencimiento está en cero (aún no vencido por asistencia).

**Fórmula/pseudocódigo:**
```
IF B49-SALDO ≠ 0  → COMISION-VENCIDA
   IF B49-STATUS = 0  → VALIDA-CLAVE
      idx = B49-CLAVE-COBRO
      IF WS-TAB-NUMEPP-MESVIG(idx) > 0 AND WS-TAB-INDEPP-VENC(idx) = 0
         WKS-FEC-PROY = WS-TAB-FEC-PROY(idx)
         IF B49-FECHA-LINEA < WKS-FEC-PROY
            MOVE 3            TO B49-STATUS       (vencida)
            MOVE WKS-FEC-BASE TO B49-FECHA-ULTACT
            STORE B49
```

**Vocabulario en la fórmula:** B49-FECHA-LINEA · WKS-FEC-PROY · B49-CLAVE-COBRO · WS-TAB-NUMEPP-MESVIG · WS-TAB-INDEPP-VENC

**Excepciones:**
- Segunda vuelta (REVISO-ASISTENCIAS) aplica la misma marca 3 cuando INDEPP-VENC = 1 (vencimiento por asistencia).

**Estado validación:** Verificado fuente líneas 965-991, 1137-1156

---

## RN-S500-364 — Proyección de la fecha de vencimiento sumando meses de vigencia (rutina LOCSUP)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-364 |
| **Nombre** | Proyección de la fecha de vencimiento sumando meses de vigencia (rutina LOCSUP) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La fecha proyectada de vencimiento de cada clave de cobro EPP se obtiene invocando la librería común de fechas S006LOCSUP con función 22 y formato 13, tomando como base la fecha de lote y como parámetro el número de meses de vigencia del instrumento. El resultado se cachea en la tabla EPP indexada por clave de transacción para no recalcular por cada comisión.

**Fórmula/pseudocódigo:**
```
PROY-FECH-ATRAS:
   WS-S006-FECHA1  = WKS-FEC-BASE       (fecha lote)
   WS-S006-FECHA2  = WKS-NUM-MESVIG     (meses de vigencia)
   WS-S006-FUNCION = 22
   WS-S006-FORMATO = 13
   PERFORM LOCSUP
   IF WS-S006-FUNCION = 0  (OK)
      WKS-FEC-PROY = WS-S006-FECHA1
```

**Vocabulario en la fórmula:** S006LOCSUP · WS-S006-FUNCION (22) · WS-S006-FORMATO (13) · WKS-NUM-MESVIG · WKS-FEC-PROY

**Excepciones:**
- La proyección se cachea por clave; si NUMEPP-MESVIG repite el valor anterior se reutiliza sin recalcular.

**Estado validación:** Verificado fuente líneas 730-802 (rutina 40005900)

---

## RN-S500-365 — Identificación de nodo/plaza y sucursal promotora por HOSTNAME (VDM vs MTY)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-365 |
| **Nombre** | Identificación de nodo/plaza y sucursal promotora por HOSTNAME (VDM vs MTY) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa determina en qué plaza corre según el HOSTNAME de la máquina y de ahí deriva por hardcode el número de CSI (centro de servicio informático) y la sucursal promotora usados para nombrar archivos y reportes. Valle de México (VDM) usa CSI 10 y sucursal 870; cualquier otro host (Monterrey/MTY) usa CSI 04 y sucursal 519. Estos valores están incrustados en el código, no parametrizados.

**Fórmula/pseudocódigo:**
```
CALL HOSTNAME
IF WS-DH-HOSTNAME-VDM
   CSI = 10 ; WKS-SUC-PROMOTORA-S015 = 870
ELSE
   CSI = 04 ; WKS-SUC-PROMOTORA-S015 = 519
```

**Vocabulario en la fórmula:** WS-DH-HOSTNAME-VDM · WKS-EPP-CSIO · WKS-SUC-PROMOTORA-S015

**Excepciones:**
- No existe rama para un tercer datacenter; cualquier host no-VDM cae en los valores de MTY por defecto.

**Estado validación:** Verificado fuente líneas 678-690

---

## RN-S500-366 — Determinación de proceso mensual por cambio de mes entre fecha de línea y fecha base

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-366 |
| **Nombre** | Determinación de proceso mensual por cambio de mes entre fecha de línea y fecha base |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P107 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso decide si el corrido es "mensual" comparando el mes de la fecha de línea próxima contra el mes de la fecha base del lote. Si los meses difieren, activa el bandera de proceso mensual (WKS-ES-MENSUAL = 1), que gobierna la conciliación de saldos TESOFE de fin de mes.

**Fórmula/pseudocódigo:**
```
B02-FECHA-LOTE  → WKS-FEC-BASE
B02-FECHA-LINEA → WKS-FEC-PROX
IF WKS-MM-FPROX = WKS-MM-FBASE
   WKS-ES-MENSUAL = 0   (proceso diario)
ELSE
   WKS-ES-MENSUAL = 1   (proceso mensual / cambio de mes)
```

**Vocabulario en la fórmula:** B02-FECHA-LOTE · B02-FECHA-LINEA · WKS-MM-FPROX · WKS-MM-FBASE · WKS-ES-MENSUAL

**Excepciones:**
- Bloque de año bisiesto (día 29 de febrero) está comentado en el fuente, no vigente.

**Estado validación:** Verificado fuente líneas 753-767

---

## RN-S500-367 — Cobertura de procesamiento distribuido por plaza y sincronización cruzada de movimientos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-367 |
| **Nombre** | Cobertura de procesamiento distribuido por plaza y sincronización cruzada de movimientos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P189 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P189 opera en dos plazas espejo y sincroniza la base de captación recibiendo los movimientos de la plaza contraria. Según el HOSTNAME define nodo local, nodo foráneo y el sistema externo a integrar: en Valle de México (VDM) el nodo local es 10, el foráneo 04 y recibe el archivo de movimientos S084 (Monterrey); en la otra plaza (MTY) el local es 04, el foráneo 10 y recibe S087. El objetivo es empatar la base de datos de ambas plazas con un modelo activo-activo distribuido.

**Fórmula/pseudocódigo:**
```
CALL HOSTNAME
IF WS-DH-HOSTNAME-VDM
   NOD-LOC = 10 ; NOD-FOR = 04 ; SIS-EXT = 084   (recibe movtos MTY)
ELSE
   NOD-LOC = 04 ; NOD-FOR = 10 ; SIS-EXT = 087   (recibe movtos VDM)
```

**Vocabulario en la fórmula:** WS-DH-HOSTNAME-VDM · WKS-NOD-LOC · WKS-NOD-FOR · WKS-SIS-EXT · A01-S500 · A03-S084S087

**Excepciones:**
- Si no llega el archivo S500, el proceso puede continuar con archivo default o marcarse como reinicio (RN de reinicio idempotente).

**Estado validación:** Verificado fuente líneas 33-41, 778-785

---

## RN-S500-368 — Reinicialización del estatus del cliente para gobernar desbloqueos (archivos sólo transportan bloqueos)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-368 |
| **Nombre** | Reinicialización del estatus del cliente para gobernar desbloqueos (archivos sólo transportan bloqueos) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P189 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de aplicar los movimientos del día, P189 barre toda la estructura B09PMOTOR para poner el estatus del cliente a cero. Esto es necesario porque los archivos de intercambio S500/S084/S087 sólo transportan bloqueos (nuevas marcas), nunca desbloqueos; reinicializar a cero permite que los contratos que ya no traen bloqueo queden efectivamente desbloqueados tras reaplicar sólo los bloqueos vigentes.

**Fórmula/pseudocódigo:**
```
INI-STA-CTE: barre B09PMOTOR
   IF B09P-ULTACT-LOC = FEC-DEFAULT OR B09P-ULTACT-FOR = FEC-DEFAULT
      NEXT   (registro sin fecha válida, no tocar)
   ELSE IF B09P-STA-CTE > 0
      MOVE 0 TO B09P-STA-CTE   (desbloquea)
      PERFORM MARCA-STABENF
      STORE B09P
```

**Vocabulario en la fórmula:** B09P-STA-CTE · B09P-ULTACT-LOC · B09P-ULTACT-FOR · WKS-DEF-FEC

**Excepciones:**
- Registros con fecha de última actualización = default (nunca actualizados) se omiten.

**Estado validación:** Verificado fuente líneas 1753-1798

---

## RN-S500-369 — Marca de cuenta en abandono / beneficencia (Artículo 61 LIC) por inactividad

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-369 |
| **Nombre** | Marca de cuenta en abandono / beneficencia (Artículo 61 LIC) por inactividad |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV / LIC Art. 61 |
| **Programa ejecutor** | P189 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P189 marca el estatus de beneficencia del cliente (STA-BENF) implementando el Artículo 61 de la Ley de Instituciones de Crédito: las cuentas cuya fecha de último movimiento es anterior a la fecha de corte del Artículo 61 y que no tienen movimiento se marcan para el tratamiento de abandono (traspaso de saldos a la cuenta global de beneficencia pública). La marca se enciende sólo si el cliente está desbloqueado (STA-CTE = 0) y su último movimiento es previo a la fecha Art. 61; se apaga si el cliente vuelve a tener movimiento posterior o queda bloqueado.

**Fórmula/pseudocódigo:**
```
MARCA-STABENF:
   IF B09P-STA-BENF = 0
      IF B09P-STA-CTE = 0
         IF B09P-FECH-ULTMOV < WKS-FEC-ART61
            MOVE 1 TO B09P-STA-BENF        (entra a beneficencia)
   ELSE   (ya marcada)
      IF (B09P-FECH-ULTMOV > WKS-FEC-ART61 AND WKS-FEC-ART61 > 0)
         OR B09P-STA-CTE = 1
         MOVE 0 TO B09P-STA-BENF           (sale de beneficencia)

WKS-FEC-ART61 tomada del header del archivo (WKS-HED-FECART61) o de B09P-FECH-ULTMOV
```

**Vocabulario en la fórmula:** B09P-STA-BENF · B09P-STA-CTE · B09P-FECH-ULTMOV · WKS-FEC-ART61 (fecha corte Art. 61)

**Excepciones:**
- La fecha Art. 61 debe ser numérica y mayor a cero; si el header trae fecha inválida se emite mensaje y no se recalcula el corte.

**Estado validación:** Verificado fuente líneas 1152-1154, 1704-1718

---

## RN-S500-370 — Propagación condicional de fecha de último movimiento y estatus del cliente a la B06 histórica

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-370 |
| **Nombre** | Propagación condicional de fecha de último movimiento y estatus del cliente a la B06 histórica |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P189 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Tras consolidar el motor B09P, P189 sincroniza la estructura histórica B06 por cliente. La fecha de último movimiento sólo se sobrescribe si la del motor es más reciente que la histórica (nunca retrocede), y el estatus del cliente se copia únicamente cuando difiere del histórico. Con esto la B06 refleja saldo, estatus y fecha de último movimiento consolidados de ambas plazas.

**Fórmula/pseudocódigo:**
```
IF B09P-FECH-ULTMOV > B06-FECH-XCTE
   MOVE B09P-FECH-ULTMOV TO B06-FECH-XCTE   (avanza, no retrocede)
IF B09P-STA-CTE NOT = B06-STA-XCTE
   MOVE B09P-STA-CTE     TO B06-STA-XCTE
STORE B06
```

**Vocabulario en la fórmula:** B09P-FECH-ULTMOV · B06-FECH-XCTE · B09P-STA-CTE · B06-STA-XCTE

**Excepciones:**
- Si la fecha del motor es igual o menor a la histórica, la fecha B06 no se modifica.

**Estado validación:** Verificado fuente líneas 1952-1957

---

## RN-S500-371 — Rechazo de registros con número de cliente inválido (cero o nueves)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-371 |
| **Nombre** | Rechazo de registros con número de cliente inválido (cero o nueves) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P189 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El detalle de los archivos de intercambio define como cliente erróneo todo número de cliente igual a cero o al valor centinela de doce nueves (999999999999). Estos registros se tratan como inválidos y no deben aplicarse contra la base de captación, evitando corromper contratos con un cliente inexistente.

**Fórmula/pseudocódigo:**
```
05 WKS-DET-CTE  PIC 9(12)
   88 WKS-CTE-ERROR  VALUE 0 , 999999999999

IF WKS-CTE-ERROR  → registro inválido, no se aplica
```

**Vocabulario en la fórmula:** WKS-DET-CTE · WKS-CTE-ERROR

**Excepciones:**
- Los doce nueves funcionan como centinela de "cliente no identificado".

**Estado validación:** Verificado fuente líneas 532-533

---

## RN-S500-372 — Envío de saldos idempotente gobernado por estatus B18 (pendiente vs enviado)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-372 |
| **Nombre** | Envío de saldos idempotente gobernado por estatus B18 (pendiente vs enviado) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El envío de saldos se controla por el estatus de la estructura B18PENVIOSDOS. Un registro con estatus 1 (pendiente) se graba al archivo de saldos como registro nuevo; un registro con estatus 2 (ya enviado) cuya fecha de transacción sea menor o igual a la fecha proyectada se totaliza y se elimina de la base bajo transacción. Este patrón garantiza que un saldo se envíe una sola vez y que el reproceso sea idempotente.

**Fórmula/pseudocódigo:**
```
IF WS18P-EST-ENVIO = 2 AND WS18P-FECHA-TRANS <= WS-FECHA-PROY
   REGISTRA-TOTAL-B18
   BEGIN-TRANSAC ; DELETE B18PENVIOSDOS ; END-TRANSAC   (drena enviados)
ELSE IF WS18P-EST-ENVIO = 1
   MUEVE-TEMP-3   (graba pendiente al archivo)
```

**Vocabulario en la fórmula:** WS18P-EST-ENVIO (1=pendiente, 2=enviado) · WS18P-FECHA-TRANS · WS-FECHA-PROY

**Excepciones:**
- Si ocurre error de BD durante el DELETE se cierra la transacción sin eliminar (no se pierde el registro).

**Estado validación:** Verificado fuente líneas 1172-1188, 1214-1224

---

## RN-S500-373 — Aborto con aviso cuando no existen saldos para la fecha de proceso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-373 |
| **Nombre** | Aborto con aviso cuando no existen saldos para la fecha de proceso |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si al recorrer la B18 no se encuentran registros y el acumulado de depurados está en cero, el proceso emite el mensaje explícito "NO EXISTEN REGISTROS PARA LA FECHA" y termina. Es un control de guarda para no generar un archivo de saldos vacío hacia downstream.

**Fórmula/pseudocódigo:**
```
IF WS-DB-NOTFOUND
   IF WS-TOTAL-DEP-DEP(1) = 0
      MENSAJE "NO EXISTEN REGISTROS PARA LA FECHA: " WS-FECHA-PROY
   MOVE 1 TO WS-TERMINA
```

**Vocabulario en la fórmula:** WS-DB-NOTFOUND · WS-TOTAL-DEP-DEP · WS-FECHA-PROY

**Excepciones:**
- Aún con cero registros el proceso termina de forma controlada (no error fatal).

**Estado validación:** Verificado fuente líneas 1201-1209

---

## RN-S500-374 — Drenado de la bitácora maker-checker (B56) a archivo de control operativo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-374 |
| **Nombre** | Drenado de la bitácora maker-checker (B56) a archivo de control operativo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV (segregación de funciones) |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P117 recorre la estructura B56MAKERCHEK, que es la bitácora del esquema maker-checker (autorización a cuatro ojos) de las operaciones, y vuelca cada registro a un archivo temporal con número de autorización, contrato, importe, estado de transacción, sucursal, operador, hora y checker. Cada registro se elimina de la base tras copiarlo (drenado), y alimenta el reporte de control MAKERCHECK que evidencia quién capturó (maker) y quién autorizó (checker) cada movimiento.

**Fórmula/pseudocódigo:**
```
SET B56MAKERCHEK TO BEGINNING ; LOCK-NEXT
PROCESO-B56-1:
   MUEVE-B56-TEMP: mueve NUM-AUT, CONTRATO, IMPORTE-OPER, EST-TRAN,
                   SUC-TRANS, NOM-OPE (operador), HRA-TRAN, NUM-INT
   DELETE B56   (drena registro procesado)
```

**Vocabulario en la fórmula:** B56-NUM-AUT · B56-EST-TRAN · B56-NOM-OPE · B56-HRA-TRAN · WS-DT-MAKER · WS-DT-CHECKER

**Excepciones:**
- El reporte MAKERCHECK separa el detalle B57 (checker) del detalle B56 (maker).

**Estado validación:** Verificado fuente líneas 1257-1300, 699-729

---

## RN-S500-375 — Registro de saldo pendiente con precisión de 18 dígitos (16 enteros, 2 decimales)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-375 |
| **Nombre** | Registro de saldo pendiente con precisión de 18 dígitos (16 enteros, 2 decimales) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El detalle de saldos en el archivo de entrada define el saldo pendiente como un número de 16 enteros y 2 decimales (9(16)V99). Esta capacidad de 18 dígitos condiciona cualquier reingeniería del tipo de dato en el destino (evitar truncamiento de importes de alta magnitud en la migración).

**Fórmula/pseudocódigo:**
```
02 I02-R-TIP-REG           PIC 9(02)
03 I02-DET-SALDO-PENDIENTE PIC 9(16)V99   → hasta 9,999,999,999,999,999.99
```

**Vocabulario en la fórmula:** I02-DET-SALDO-PENDIENTE · I02-R-TIP-REG

**Excepciones:**
- El tipo de registro (TIP-REG) discrimina header/detalle/trailer del archivo de saldos.

**Estado validación:** Verificado fuente líneas 107-124

---

## RN-S500-376 — Doble esquema de archivos: saldos genéricos (ARCSDOS) y control maker-checker (ARCMAKRCHECK)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-376 |
| **Nombre** | Doble esquema de archivos: saldos genéricos (ARCSDOS) y control maker-checker (ARCMAKRCHECK) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P117 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P117 gestiona dos flujos independientes con su propio archivo de trabajo, sort y reporte: el envío de saldos (I01/I02-ARCSDOS, reporte 001REPSALDOS) y el control maker-checker (I01-ARCMAKRCHECK, reporte 001MAKERCHECK). Cada flujo ordena y totaliza por separado, permitiendo ejecutar la conciliación de saldos y la auditoría de operaciones en el mismo paso batch.

**Fórmula/pseudocódigo:**
```
Flujo A: I01/I02-ARCSDOS  --sort S01-ARCSDOS--  reporte "001REPSALDOS"
Flujo B: I01-ARCMAKRCHECK --sort S01-ARCMAKRCHECK-- reporte "001MAKERCHECK"
```

**Vocabulario en la fórmula:** ARCSDOS · ARCMAKRCHECK · 001REPSALDOS · 001MAKERCHECK

**Excepciones:**
- Ambos flujos comparten la apertura de BD pero mantienen sort y totales separados.

**Estado validación:** Verificado fuente líneas 39-45, 979-985

---

## RN-S500-377 — Generación del archivo regulatorio IPAB por contrato (seguro de depósitos)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-377 |
| **Nombre** | Generación del archivo regulatorio IPAB por contrato (seguro de depósitos) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | IPAB (Ley de Protección al Ahorro Bancario) |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P168 arma el archivo regulatorio para el IPAB con un registro por contrato de captación, incluyendo producto, instrumento, moneda, contrato, cliente, rendimiento bruto, rendimiento neto, impuesto (ISR), saldo promedio del ciclo, días del ciclo y tasa de ISR. Este reporte sustenta el cálculo de las cuotas al seguro de depósitos y la obligación fiscal sobre intereses.

**Fórmula/pseudocódigo:**
```
REG-IPAB-DETALLE (TPOREG 02):
   PRD, INST, MON, NUMCTO, NUMCTE
   RENDBRTO  = rendimiento bruto
   RENDNETO  = rendimiento neto
   IMPUESTO  = ISR retenido
   PROMCICLO = saldo promedio del ciclo
   DIASCICLO = días del ciclo
   TASAISR   = tasa de ISR aplicada
```

**Vocabulario en la fórmula:** WR02-IPAB-RENDBRTO · WR02-IPAB-RENDNETO · WR02-IPAB-IMPUESTO · WR02-IPAB-PROMCICLO · WR02-IPAB-DIASCICLO · WR02-IPAB-TASAISR

**Excepciones:**
- El header (TPOREG 01) lleva fecha de proceso y CSI de la plaza que genera el archivo.

**Estado validación:** Verificado fuente líneas 424-443

---

## RN-S500-378 — Rendimiento bruto igual a rendimiento neto más el ISR retenido

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-378 |
| **Nombre** | Rendimiento bruto igual a rendimiento neto más el ISR retenido |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (ISR sobre intereses) |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El rendimiento bruto reportado se reconstruye sumando el rendimiento neto pagado al cliente más el impuesto sobre la renta retenido. Es la relación fiscal fundamental: bruto = neto + retención de ISR sobre intereses.

**Fórmula/pseudocódigo:**
```
COMPUTE WS-CAP-RENDBRTO = WS-CAP-RENDNETO + WS-CAP-IMPUESTO
```

**Vocabulario en la fórmula:** WS-CAP-RENDBRTO · WS-CAP-RENDNETO · WS-CAP-IMPUESTO (ISR)

**Excepciones:**
- Si el impuesto retenido es cero, bruto = neto (instrumentos exentos).

**Estado validación:** Verificado fuente líneas 1717-1718

---

## RN-S500-379 — Tasa bruta y neta anualizadas base 360 con factor 36000

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-379 |
| **Nombre** | Tasa bruta y neta anualizadas base 360 con factor 36000 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno / Banxico |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Las tasas bruta y neta del ciclo se anualizan dividiendo el rendimiento entre el saldo promedio del ciclo, multiplicando por 36000 y dividiendo entre los días del ciclo. El factor 36000 = 360 días × 100, convirtiendo a tasa porcentual anual sobre base comercial de 360 días. El cálculo sólo se ejecuta si hay días de ciclo y saldo promedio mayores a cero (evita división por cero).

**Fórmula/pseudocódigo:**
```
IF WS-CAP-DIASCICLO > 0 AND WS-CAP-PROMCICLO > 0
   TASABRUTA = RENDBRTO / PROMCICLO * 36000 / DIASCICLO
   TASANETA  = RENDNETO / PROMCICLO * 36000 / DIASCICLO
```

**Vocabulario en la fórmula:** WS-CAP-TASABRUTA · WS-CAP-TASANETA · WS-CAP-PROMCICLO · WS-CAP-DIASCICLO · factor 36000 (360×100)

**Excepciones:**
- Con días o promedio en cero no se calcula la tasa (queda en cero) para evitar división por cero.

**Estado validación:** Verificado fuente líneas 1723-1730

---

## RN-S500-380 — Origen del rendimiento e ISR según tipo de capitalización (diaria vs mensual)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-380 |
| **Nombre** | Origen del rendimiento e ISR según tipo de capitalización (diaria vs mensual) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El rendimiento neto, el impuesto y el saldo promedio del ciclo se toman de campos distintos según el esquema de capitalización del contrato. En capitalización diaria se usan los campos de rendimiento e ISR del día (B03-RENDIA-IPAB, B03-ISRDIA-IPAB) y el saldo promedio IPAB de la B06; en capitalización mensual se usan los intereses capitalizados y el impuesto retenido del mes (B03-INTS-CAPIT, B03-IMPUESTO-RET) con el promedio y días de ciclo mensuales.

**Fórmula/pseudocódigo:**
```
Capitalización diaria:
   RENDNETO  = B03-RENDIA-IPAB
   IMPUESTO  = B03-ISRDIA-IPAB
   PROMCICLO = B06-SDOPROM-IPAB
   DIASCICLO = WS-DIAS-INHAXCTO
Capitalización mensual:
   RENDNETO  = B03-INTS-CAPIT
   IMPUESTO  = B03-IMPUESTO-RET
   PROMCICLO = B06-PROM-CICLO(12)
   DIASCICLO = B06-DIAS-CICLO
```

**Vocabulario en la fórmula:** B03-RENDIA-IPAB · B03-ISRDIA-IPAB · B06-SDOPROM-IPAB · B03-INTS-CAPIT · B03-IMPUESTO-RET · B06-PROM-CICLO

**Excepciones:**
- Los campos legacy USO-FILLER/USO-FUTURO quedaron comentados al migrar a los campos IPAB dedicados.

**Estado validación:** Verificado fuente líneas 1695-1713

---

## RN-S500-381 — Reconstrucción del saldo anterior descontando el rendimiento neto capitalizado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-381 |
| **Nombre** | Reconstrucción del saldo anterior descontando el rendimiento neto capitalizado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para determinar el saldo base sobre el que se generó el rendimiento, el proceso reconstruye el saldo anterior restando el rendimiento neto capitalizado del saldo actual. Con esto separa el principal del interés capitalizado antes de calcular las tasas y el promedio del ciclo.

**Fórmula/pseudocódigo:**
```
COMPUTE W77-SALDO-ANTERIOR = W77-SALDO-ACTUAL - WS-CAP-RENDNETO
```

**Vocabulario en la fórmula:** W77-SALDO-ANTERIOR · W77-SALDO-ACTUAL · WS-CAP-RENDNETO

**Excepciones:**
- Existe una variante donde el saldo anterior se calcula sin restar el rendimiento (capitalización mensual), según la rama de capitalización.

**Estado validación:** Verificado fuente líneas 1703-1708

---

## RN-S500-382 — Segregación producto 500 instrumento 6 a capitalización de ahorros; el resto a cancelados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-382 |
| **Nombre** | Segregación producto 500 instrumento 6 a capitalización de ahorros; el resto a cancelados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P315 (CAPAHO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al recorrer los contratos ordenados, P315 clasifica cada registro por producto e instrumento: los contratos de producto 500 instrumento 6 (ahorro) entran al listado de capitalización mensual de ahorros; cualquier otro producto/instrumento se dirige al reporte de contratos cancelados en forma automática. Es la bifurcación central del proceso de capitalización de ahorros.

**Fórmula/pseudocódigo:**
```
IF INV-PRODUCTO-S = 500 AND INV-INSTRUMENTO-S = 6
   INIAHO ; DETALLE           (capitalización de ahorros)
ELSE
   INICAN ; DETALLE-CANCEL     (reporte de cancelados)
```

**Vocabulario en la fórmula:** INV-PRODUCTO-S (500) · INV-INSTRUMENTO-S (6) · FILE-CAPAHO · FILE-CANCEL

**Excepciones:**
- Hardcode del par producto/instrumento (500/6) para identificar el ahorro capitalizable.

**Estado validación:** Verificado fuente líneas 1642-1648

---

## RN-S500-383 — Envío mensual del archivo de saldos al CIG (Gerencia) con saldo promedio y tasa

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-383 |
| **Nombre** | Envío mensual del archivo de saldos al CIG (Gerencia) con saldo promedio y tasa |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P315 (CAPAHO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P315 genera de forma mensual el archivo dirigido al CIG (estructura GERENCIA) con la información de cada cuenta de ahorro: número de cuenta, cliente, fecha de último movimiento, moneda, tipo de persona, saldo actual, saldo promedio, tasa y sucursal. Es el insumo gerencial de la capitalización de ahorros.

**Fórmula/pseudocódigo:**
```
REG-GERENCIA (INFORMACION):
   NUM-CTA, NUM-CTE, FEC-ULMOV, MONEDA, PERSONA
   SDO-ACTUAL  PIC 9(12)V99
   SDO-PROM    PIC 9(12)V99
   TASA        PIC 9(03)V9(03)
   SUC
```

**Vocabulario en la fórmula:** GER-SDO-ACTUAL · GER-SDO-PROM · GER-TASA · GER-NUM-CTA · GER-FEC-ULMOV

**Excepciones:**
- El header del archivo GERENCIA lleva fecha de proceso y fecha de operación de la corrida mensual.

**Estado validación:** Verificado fuente líneas 86-107

---

## RN-S500-384 — Identificación y archivo separado de contratos dentro de Artículo 61

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-384 |
| **Nombre** | Identificación y archivo separado de contratos dentro de Artículo 61 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV / LIC Art. 61 |
| **Programa ejecutor** | P315 (CAPAHO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la capitalización mensual, P315 identifica los contratos que caen dentro del supuesto del Artículo 61 (cuentas inactivas / abandono) y los aparta en un archivo dedicado (FILE-ART61), ordenado por su propio sort. Esto separa el tratamiento regulatorio de cuentas abandonadas del flujo normal de capitalización.

**Fórmula/pseudocódigo:**
```
SELECT FILE-ART61 ASSIGN TO DISK
SELECT SORT-ART61 ASSIGN TO SORT DISK
→ contratos en supuesto Art. 61 se escriben a FILE-ART61 clasificado
```

**Vocabulario en la fórmula:** FILE-ART61 · SORT-ART61

**Excepciones:**
- La marca fina de Art. 61 (fecha corte, saldo) se coordina con la B09P del sistema (ver RN-S500-369).

**Estado validación:** Verificado fuente líneas 70-71, 67-68

---

## RN-S500-385 — Reconstrucción del saldo disponible pendiente en la capitalización de ahorros

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-385 |
| **Nombre** | Reconstrucción del saldo disponible pendiente en la capitalización de ahorros |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P315 (CAPAHO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso calcula el saldo disponible pendiente del contrato a partir del saldo anterior de la B03 como base para la capitalización de ahorros. Es el punto de partida contable sobre el que se aplican los intereses del ciclo.

**Fórmula/pseudocódigo:**
```
COMPUTE WKS-DISPONIBLE-PTE = B03-SDO-ANTERIOR - (ajustes del ciclo)
```

**Vocabulario en la fórmula:** WKS-DISPONIBLE-PTE · B03-SDO-ANTERIOR

**Excepciones:**
- El detalle exacto de los ajustes depende de la moneda e instrumento del contrato de ahorro.

**Estado validación:** Verificado fuente líneas 1656 (rutina de capitalización)

---

## RN-S500-386 — Separación de backups del reporte por nodo (CI/subnodo) al cambiar de nodo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-386 |
| **Nombre** | Separación de backups del reporte por nodo (CI/subnodo) al cambiar de nodo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P315 (CAPAHO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los reportes de capitalización y de cancelados se materializan como backups nombrados por usuario, uno por nodo. Cuando el nodo del registro cambia respecto al anterior, el proceso cierra el archivo del nodo previo, reinicia el contador de página y abre un nuevo archivo con la etiqueta del nuevo nodo/subnodo. Así cada plaza recibe su propio backup del reporte.

**Fórmula/pseudocódigo:**
```
SET FILE-CAPAHO(USERBACKUPNAME) TO VALUE TRUE
IF INV-NODO-S NOT = WS-NODO-ANT
   TOT-NODO ; CLOSE FILE-CAPAHO ; MOVE 0 TO WS-PAGINA
   MOVE INV-NODO-S TO WS-CAP-CI ; CHANGE TITLE ; OPEN OUTPUT FILE-CAPAHO
```

**Vocabulario en la fórmula:** FILE-CAPAHO · USERBACKUPNAME · INV-NODO-S · WS-NODO-ANT · WS-CAP-CI · WS-CAP-SUBNODO

**Excepciones:**
- El reporte de cancelados (FILE-CANCEL) aplica la misma lógica de corte por nodo de forma independiente.

**Estado validación:** Verificado fuente líneas 1694-1736

---

## RN-S500-387 — Enrutamiento de productos a archivos de saldos (ahorro vs CMA vs cheques)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-387 |
| **Nombre** | Enrutamiento de productos a archivos de saldos (ahorro vs CMA vs cheques) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P181 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P181 clasifica los productos de captación de la B05 hacia distintos flujos de saldos. El producto 1 (ahorro) se acumula en la tabla de totales y se excluye del archivo CMA; los productos 66 o el 500 instrumento 1 se enrutan al archivo de cuenta maestra (CMASDOS); los productos de cheques alimentan CHESDOS. Este ruteo define qué productos viajan en cada archivo hacia Datoteca, Teradata y Genesis.

**Fórmula/pseudocódigo:**
```
IF B05-NUM-PRODUCTO = 1
   → tabla totales (ahorro, no CMA)
ELSE IF B05-NUM-PRODUCTO = 66
     OR (B05-NUM-PRODUCTO = 500 AND B05-NUM-INSTRUM = 1)
   → tabla CMA (CMASDOS)
```

**Vocabulario en la fórmula:** B05-NUM-PRODUCTO (1, 66, 500) · B05-NUM-INSTRUM · WS-NUMCMA-PRD · WS-TBTOT-PRD

**Excepciones:**
- El ahorro (producto 1) queda explícitamente fuera del archivo CMA, según cabecera "NO INCLUYE AHORROS".

**Estado validación:** Verificado fuente líneas 1046-1063, 69

---

## RN-S500-388 — Generación de archivos de intercambio hacia Datoteca, Teradata y Genesis

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-388 |
| **Nombre** | Generación de archivos de intercambio hacia Datoteca, Teradata y Genesis |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P181 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P181 produce los archivos de saldos de cheques (CHESDOS) y de cuenta maestra (CMASDOS) bajo la ruta INTS/50003S02, más los archivos adicionales S691 (ADICIONALCHEQ, ADICIONALCMAE), destinados a Datoteca, Teradata y Genesis. Es un punto de integración analítica del sistema de captación hacia las plataformas de datos.

**Fórmula/pseudocódigo:**
```
"S500/FILE/INTS/50003S02/XX/AAAAMMDD/CHESDOS"
"S500/FILE/INTS/50003S02/XX/AAAAMMDD/CMASDOS"
"S500/FILE/S691/XX/ADICIONALCHEQ/AAAAMMDD"
"S500/FILE/S691/XX/ADICIONALCMAE/AAAAMMDD"
```

**Vocabulario en la fórmula:** CHESDOS · CMASDOS · S691 · ADICIONALCHEQ · ADICIONALCMAE · Datoteca · Genesis

**Excepciones:**
- El archivo INVEPTE se genera aparte para consumo del paso P180.

**Estado validación:** Verificado fuente líneas 15-19, 562, 587

---

## RN-S500-389 — Detección de cambio de mes para el corte de proceso mensual

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-389 |
| **Nombre** | Detección de cambio de mes para el corte de proceso mensual |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P181 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P181 compara el mes de la fecha de proceso contra el mes de la fecha próxima de línea para decidir si el corrido corresponde a un cierre mensual. Cuando los meses difieren, se activa la lógica de fin de mes que gobierna los totales y el envío de los archivos de saldos.

**Fórmula/pseudocódigo:**
```
IF WS-PRO-MM NOT = WS-FEC-PROX-MM
   → proceso de cambio de mes (cierre mensual)
```

**Vocabulario en la fórmula:** WS-PRO-MM · WS-FEC-PROX-MM

**Excepciones:**
- La fecha próxima proviene del calendario de línea del sistema (B02).

**Estado validación:** Verificado fuente líneas 843

---

## RN-S500-390 — Reacomodo del formato del archivo para agrupar las llaves de sort contiguas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-390 |
| **Nombre** | Reacomodo del formato del archivo para agrupar las llaves de sort contiguas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P181 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En la versión de abril 2019, P181 reacomodó el formato del archivo INVEPTE para dejar las llaves de ordenamiento (producto, instrumento, moneda, contrato) contiguas al inicio del registro. El objetivo fue optimizar el sort que ejecuta el paso downstream P180 al generar sus archivos y reportes.

**Fórmula/pseudocódigo:**
```
SORT-INVE por PRD, INS, MON, CTO   (llaves juntas al frente del registro)
Archivo "S500/FILE/INVEPTE/XX/AAAAMMDD" → consumido por P180
```

**Vocabulario en la fórmula:** SORT-INVE · SD-INV-PRODUCTO · INVEPTE

**Excepciones:**
- Esta versión eliminó el proceso previo de cierre de sucursales sobre S500B03PREALTAS.

**Estado validación:** Verificado fuente líneas 4-13, 88-90

---

## RN-S500-391 — Cancelación explícita de librerías compartidas para liberar memoria

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-391 |
| **Nombre** | Cancelación explícita de librerías compartidas para liberar memoria |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P181 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Tras cargar en memoria las tablas de nodos y catálogos, P181 cancela explícitamente las librerías compartidas (CTLVERS, S080TARIFAS, S080BD01CON) para liberar los recursos de la máquina ClearPath MCP. Es una optimización de memoria propia del entorno Unisys donde las librerías vinculadas permanecen residentes hasta un CANCEL explícito.

**Fórmula/pseudocódigo:**
```
CARGO-TABLA (nodos y catálogos)
CANCEL "CTLVERS"
CANCEL "S080TARIFAS"
CANCEL "S080BD01CON"
```

**Vocabulario en la fórmula:** CANCEL · CTLVERS · S080TARIFAS · S080BD01CON

**Excepciones:**
- El CANCEL sólo procede una vez cargadas las tablas de las hasta 10,000 sucursales.

**Estado validación:** Verificado fuente líneas 1068-1078

---

## RN-S500-392 — Clasificación de archivos por letra de estatus en procesados, rechazados y pendientes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-392 |
| **Nombre** | Clasificación de archivos por letra de estatus en procesados, rechazados y pendientes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P187 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P187 clasifica cada archivo/registro según su letra de estatus en tres categorías mutuamente excluyentes: procesado (estatus D, T o H), rechazado (G, I, J, K, ...) y pendiente (A, B, C, E, F, V, W). Esta taxonomía de estados con codificación de una letra es la que determina en qué reporte y archivo cae cada registro.

**Fórmula/pseudocódigo:**
```
88 W88-STA-PROCESADO  VALUE "D","T","H"
88 W88-STA-RECHAZADO  VALUE "G","I","J","K",...
88 W88-STA-PENDIENTE  VALUE "A","B","C","E","F","V","W"
```

**Vocabulario en la fórmula:** W88-STA-PROCESADO · W88-STA-RECHAZADO · W88-STA-PENDIENTE

**Excepciones:**
- Cualquier estatus fuera de los tres conjuntos queda sin clasificar (posible registro huérfano).

**Estado validación:** Verificado fuente líneas 355-359

---

## RN-S500-393 — Generación segregada de tres reportes con archivo titulado por categoría

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-393 |
| **Nombre** | Generación segregada de tres reportes con archivo titulado por categoría |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P187 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P187 materializa tres reportes independientes (REPORTE-PROC, REPORTE-PEND, REPORTE-RECH), cada uno con su archivo titulado en disco bajo la ruta S500/FILE/P187/. Cada reporte totaliza su propia categoría, permitiendo consumo y archivado por separado del resultado del procesamiento diario.

**Fórmula/pseudocódigo:**
```
REP-PROCESADO → "S500/FILE/P187/PROCESADOS"
REP-PENDIENTE → "S500/FILE/P187/PENDIENTES"
REP-RECHAZADO → "S500/FILE/P187/RECHAZADOS"
```

**Vocabulario en la fórmula:** REPORTE-PROC · REPORTE-PEND · REPORTE-RECH

**Excepciones:**
- Los reportes de detalle profundo se delegan al paso P188 (ver RN-S500-394).

**Estado validación:** Verificado fuente líneas 73-83, 127, 151

---

## RN-S500-394 — Invocación condicional a P188 para reportes de detalle solicitados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-394 |
| **Nombre** | Invocación condicional a P188 para reportes de detalle solicitados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P187 → P188 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además de los reportes de resumen, P187 invoca al paso P188 para generar los reportes de detalle únicamente de los archivos que lo hayan solicitado explícitamente. Es un patrón de encadenamiento batch donde el detalle es opcional y bajo demanda, evitando generar detalle para todo el universo.

**Fórmula/pseudocódigo:**
```
Para cada archivo con bandera de detalle solicitado:
   PERFORM / CALL P188  (genera reporte de detalle)
```

**Vocabulario en la fórmula:** P188 · reporte de detalle solicitado

**Excepciones:**
- Los archivos sin solicitud de detalle sólo aparecen en los reportes de resumen.

**Estado validación:** Verificado fuente líneas 33-36

---

## RN-S500-395 — Cuadre de totales de procesamiento (OK, rechazados, foráneos, no procesados)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-395 |
| **Nombre** | Cuadre de totales de procesamiento (OK, rechazados, foráneos, no procesados) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P187 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El reporte de control de P187 cuadra el universo de registros del día en categorías: total de registros, OK, rechazados, foráneos y no procesados. Este desglose es el mecanismo de conciliación operativa que evidencia que todo registro leído fue contabilizado en alguna categoría de salida.

**Fórmula/pseudocódigo:**
```
Total registros = OK + RECHAZADOS + FORANEOS + NO-PROCESADOS
Columnas del reporte: TOTAL REG. · PROCESADOS · RECHAZADOS · FORANEOS · NO PROCESADOS
```

**Vocabulario en la fórmula:** WS-REG-NPROCESADOS · WKS-R1-NOPROCESADOS · TRNXSEG

**Excepciones:**
- Los archivos foráneos (de la otra plaza) se contabilizan aparte de los rechazados propios.

**Estado validación:** Verificado fuente líneas 693-695, 767-792

---

## RN-S500-396 — Generación diaria del archivo de saldos GBNP con clave de banco 485 (Banamex)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-396 |
| **Nombre** | Generación diaria del archivo de saldos GBNP con clave de banco 485 (Banamex) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno / Grupo global |
| **Programa ejecutor** | P108 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P108 genera diariamente el archivo secuencial de saldos hacia GBNP con un header identificado como VDBAL, sistema MX y clave de banco 485, que es la clave de institución de Banamex incrustada como literal. Header, detalle y trailer conforman el layout estándar del feed global de saldos.

**Fórmula/pseudocódigo:**
```
WKS-HDR-GBNP: ID "HDR" · HAN "VDBAL" · SIS "MX " · BRCO 485
WKS-DET-GBNP: ID "DET" · BRCO 485 · CTOS(SUC+CTO) · FECAP · SDO · MON
WRITE REG-GBNP FROM WKS-HDR-GBNP / WKS-DET-GBNP / WKS-TRL-GBNP
```

**Vocabulario en la fórmula:** WKS-HDR-GBNP-HAN (VDBAL) · WKS-HDR-GBNP-BRCO (485) · GBNPSDOS

**Excepciones:**
- La clave 485 está hardcodeada tanto en header como en detalle; cambio de institución requiere modificar el fuente.

**Estado validación:** Verificado fuente líneas 167-194, 1400

---

## RN-S500-397 — Selección de contratos para GBNP: excluye clones y exige indicador de servicio activo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-397 |
| **Nombre** | Selección de contratos para GBNP: excluye clones y exige indicador de servicio activo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P108 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Sólo se envían a GBNP los contratos que no son clones (marca de clonación distinta de 2 y 3) y que tienen encendido el indicador de servicio GBNP (B03-GBNP-SERV-IND mayor a cero). Los contratos clon o sin servicio GBNP se omiten del archivo, evitando duplicar o filtrar cuentas no suscritas al servicio global.

**Fórmula/pseudocódigo:**
```
IF B03-MARCA-CLON = 2 OR 3
   NEXT SENTENCE          (excluye clones)
ELSE IF B03-GBNP-SERV-IND > 0
   MUEV-DET ; VALIDA-DIA-CORTE ; RECORD-STAT ; CALCULA-SALDO
   WRITE REG-GBNP FROM WKS-DET-GBNP
```

**Vocabulario en la fórmula:** B03-MARCA-CLON · B03-GBNP-SERV-IND · WKS-DET-GBNP

**Excepciones:**
- Se contabiliza el estatus del contrato (B03-STATUS = 0, 1 o 5) al armar el detalle.

**Estado validación:** Verificado fuente líneas 1376-1394, 1425-1426

---

## RN-S500-398 — Mapeo de moneda interna a código ISO en el feed GBNP (01→MXN, 05→USD)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-398 |
| **Nombre** | Mapeo de moneda interna a código ISO en el feed GBNP (01→MXN, 05→USD) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P108 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de moneda interno del sistema de captación se traduce a código ISO alfabético para el feed GBNP: moneda 01 se mapea a MXN (pesos) y moneda 05 a USD (dólares). Sólo estas dos monedas tienen equivalencia definida en el envío global.

**Fórmula/pseudocódigo:**
```
IF B03-MONEDA = 01  → WKS-DET-GBNP-MON = "MXN"
ELSE IF B03-MONEDA = 05  → WKS-DET-GBNP-MON = "USD"
```

**Vocabulario en la fórmula:** B03-MONEDA (01, 05) · WKS-DET-GBNP-MON (MXN, USD)

**Excepciones:**
- Monedas distintas de 01/05 quedan sin código ISO asignado en el detalle (posible espacio/valor previo).

**Estado validación:** Verificado fuente líneas 1417-1421

---

## RN-S500-399 — Control de secuencia y fecha del envío de saldos GBNP desde la B02

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-399 |
| **Nombre** | Control de secuencia y fecha del envío de saldos GBNP desde la B02 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P108 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El disparo del envío de saldos GBNP está gobernado por la estructura de control B02: la generación sólo procede cuando la fecha de saldos GBNP coincide con la fecha base del proceso, y la secuencia (1, 2, 3) selecciona qué corrida/segmento del envío se ejecuta. Con esto se coordina un envío multisecuencia dentro del mismo día contable.

**Fórmula/pseudocódigo:**
```
IF B02-GBNP-SALDOS-FEC = WKS-FEC-BASE
   MOVE "ENVIAGBNPSDOS" TO parámetro
   IF B02-GBNP-SALDOS-SEC = 1 AND WKS-PARAM = 1 → segmento 1
   IF B02-GBNP-SALDOS-SEC = 2 AND WKS-PARAM = 1 → segmento 2
   IF B02-GBNP-SALDOS-SEC = 3               → segmento 3
```

**Vocabulario en la fórmula:** B02-GBNP-SALDOS-FEC · B02-GBNP-SALDOS-SEC · WKS-FEC-BASE · ENVIAGBNPSDOS

**Excepciones:**
- Si la fecha de saldos GBNP no coincide con la fecha base, no se genera el archivo ese día.

**Estado validación:** Verificado fuente líneas 1114-1155

---

## RN-S500-400 — Cálculo del saldo por contrato para el feed GBNP con precisión de 14 enteros

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-400 |
| **Nombre** | Cálculo del saldo por contrato para el feed GBNP con precisión de 14 enteros |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P108 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El saldo enviado a GBNP se determina en una rutina dedicada (CALCULA-SALDO) que consolida el saldo del contrato considerando producto, instrumento y día de corte, con una precisión interna de 14 enteros y 2 decimales, presentado en el detalle con edición de hasta 20 posiciones más decimales.

**Fórmula/pseudocódigo:**
```
BUSCA-PRODINST → VALIDA-DIA-CORTE → RECORD-STAT → CALCULA-SALDO
WKS-SALDO-GBNP  PIC 9(14)V99
WKS-DET-GBNP-SDO PIC ZZ...ZZ9.99   (20 enteros editados)
```

**Vocabulario en la fórmula:** WKS-SALDO-GBNP · WKS-SALDO-PEND · WKS-DET-GBNP-SDO · CALCULA-SALDO

**Excepciones:**
- La validación de día de corte (VALIDA-DIA-CORTE) ajusta qué saldo aplica según el ciclo del producto.

**Estado validación:** Verificado fuente líneas 292-293, 1386-1394

---

## RN-S500-401 — Envío al S016 de los avisos de apertura de cuenta

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-401 |
| **Nombre** | Envío al S016 de los avisos de apertura de cuenta |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P050 (P050LIN) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La función central de P050 es enviar al sistema S016 los avisos de apertura de cuenta, para que S016 active los medios de acceso asociados. Cada nueva cuenta abierta en captación genera un aviso que viaja hacia el sistema de medios, integrando el alta de la cuenta con la emisión de tarjetas/medios.

**Fórmula/pseudocódigo:**
```
FUNCION: enviar al S016 los avisos de apertura
I01-ACTIVAMED (medios a activar) → PROC → S016
```

**Vocabulario en la fórmula:** S016 · ACTIVAMED · aviso de apertura · L428

**Excepciones:**
- Usa la librería S016L428 (varios releases R01/R03/R04/R05) para el formato del aviso.

**Estado validación:** Verificado fuente líneas 24, 41-53

---

## RN-S500-402 — Gestión idempotente de avisos vía entry points L010 sobre archivo GENMDA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-402 |
| **Nombre** | Gestión idempotente de avisos vía entry points L010 sobre archivo GENMDA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P050 (P050LIN) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El manejo de avisos al S016 se realiza a través de los entry points de la librería L010 sobre el archivo GENMDA con tres operaciones: graba el registro de aviso, lee un registro de aviso pendiente y regraba el aviso ya procesado. Este ciclo grabar-leer-regrabar permite reprocesar sin duplicar, marcando cada aviso como procesado.

**Fórmula/pseudocódigo:**
```
Entry point 1: GRABA el registro de aviso en archivo GENMDA
Entry point 2: LEE un registro de aviso del archivo GENMDA
Entry point 2: REGRABA el registro de aviso procesado en GENMDA
```

**Vocabulario en la fórmula:** L010 · GENMDA · WKS-PROCESAR-REG-DE-AVISO-VA

**Excepciones:**
- Los avisos con problema se apartan en el archivo I03-ARCH-PROB.

**Estado validación:** Verificado fuente líneas 109-125, 279-280

---

## RN-S500-403 — Requisito regulatorio Charity III (beneficencia) activado el 24/MAR/2020

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-403 |
| **Nombre** | Requisito regulatorio Charity III (beneficencia) activado el 24/MAR/2020 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV (beneficencia / Charity) |
| **Programa ejecutor** | P050 (P050LIN) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P050 incorpora el requisito regulatorio "Charity Regulatory Requirement III" (beneficencia), que estuvo apagado para pruebas y se encendió en la liberación del 24 de marzo de 2020 mediante la activación de la librería S016L428R05. Es una marca de cumplimiento cuya activación quedó fechada en el propio fuente.

**Fórmula/pseudocódigo:**
```
*SE ENCIENDE 24/MAR/2020 LIBERACION CHARITY
$SET S016L428R05      (activa el release con Charity III)
```

**Vocabulario en la fórmula:** Charity Regulatory Requirement III · S016L428R05 · beneficencia

**Excepciones:**
- Antes del 24/MAR/2020 el requisito estaba reseteado para pruebas unitarias (código conservado).

**Estado validación:** Verificado fuente líneas 8-11, 172, 257

---

## RN-S500-404 — Activación de medios de acceso y apartado de avisos con problema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-404 |
| **Nombre** | Activación de medios de acceso y apartado de avisos con problema |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P050 (P050LIN) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P050 lee el archivo de medios a activar (ACTIVAMED), procesa la activación y escribe los medios procesados en PROCMED; los avisos que no pueden procesarse por inconsistencia se apartan en el archivo de problemas (ARCH-PROB) para su revisión, en lugar de detener el proceso completo.

**Fórmula/pseudocódigo:**
```
I01-ACTIVAMED (medios a activar) → procesa → I04-PROCMED (procesados)
avisos con inconsistencia → I03-ARCH-PROB (problemas)
```

**Vocabulario en la fórmula:** I01-ACTIVAMED · I04-PROCMED · I03-ARCH-PROB · R01-ACTMEDIOS

**Excepciones:**
- El reporte R01-ACTMEDIOS resume la activación de medios de la corrida.

**Estado validación:** Verificado fuente líneas 41-78

---

## RN-S500-405 — Carga de saldos de otras inversiones a la B06 antes del batch diario (durante la línea)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-405 |
| **Nombre** | Carga de saldos de otras inversiones a la B06 antes del batch diario (durante la línea) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P199 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P199 precarga en la B06 del S500 los saldos de otras inversiones utilizando la librería S050. Este proceso debe ejecutarse antes del batch diario, durante la línea, para agilizar el posterior paso P130. Es una optimización de ventana batch: adelanta el cálculo de saldos consolidados mientras el sistema aún está en línea.

**Fórmula/pseudocódigo:**
```
Durante la línea (antes del batch diario):
   PARA productos con fecha de corte del día:
      cargar saldo de otras inversiones (lib S050) → B06
→ agiliza el paso S500/P130
```

**Vocabulario en la fórmula:** S050SALDOS · B06 · P130 · fecha de corte del día

**Excepciones:**
- El paso original era P300; se renombró a P199 en junio/2005 para correr diariamente.

**Estado validación:** Verificado fuente líneas 26-30, 47-48

---

## RN-S500-406 — Universo de productos con fecha de corte del día procesados por P199

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-406 |
| **Nombre** | Universo de productos con fecha de corte del día procesados por P199 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P199 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P199 procesa un conjunto acotado de productos de captación identificados por la terna producto-instrumento-moneda: cuenta maestra tradicional (0066-0006-001), cuenta maestra opción (0066-0007-001), cuenta perfil/acceso (0066-0008-001), cuenta perfil universitario (0066-0009-001), cheques M.N. físicas (0001-0001-001) y cuenta productiva (0001-0003-001), más los productos SOR (0066-0011-001 y 0066-0012-001). Estas ternas están fijas en el código como niveles de condición.

**Fórmula/pseudocódigo:**
```
88 WS03-88-ES-CTAMAE    VALUE 00660006001
88 WS03-88-ES-CTAMAEOP  VALUE 00660007001
88 WS03-88-ES-CTACCESO  VALUE 00660008001
88 WS03-88-ES-PERFUNIV  VALUE 00660009001
88 WS03-88-ES-PROD-A-SOR VALUE 00660011001
88 WS03-88-ES-PROD-B-SOR VALUE 00660012001
+ cheques M.N. 0001-0001-001 · productiva 0001-0003-001
```

**Vocabulario en la fórmula:** CTAMAE · CTAMAEOP · CTACCESO · PERFUNIV · PROD-A-SOR · PROD-B-SOR

**Excepciones:**
- El ahorro tradicional no forma parte de este universo (se procesa en otros pasos).

**Estado validación:** Verificado fuente líneas 32-37, 406-412

---

## RN-S500-407 — Cobro de comisión por consulta de estado de cuenta con calificación de tarifa (S050/L190)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-407 |
| **Nombre** | Cobro de comisión por consulta de estado de cuenta con calificación de tarifa (S050/L190) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF / Banxico (comisiones) |
| **Programa ejecutor** | P199 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además de cargar saldos, P199 procesa la carga de consultas de estado de cuenta usando la librería S050/L190 para los productos que cobran comisión, aplicando la calificación de tarifa y la clave de comisión configuradas en los occurs 06, 24 y 25 de la B05. Este es el punto donde se determina la comisión por consulta/estado de cuenta según la tarifa del producto.

**Fórmula/pseudocódigo:**
```
PARA productos que cobran comisión:
   usar lib S050/L190 con:
      B05-CLAVE-TARIF (occurs 06, 24, 25)
      B05-CLAVE-COMIS (occurs 06, 24, 25)
   → califica tarifa y aplica comisión de estado de cuenta
```

**Vocabulario en la fórmula:** S050L190 · B05-CLAVE-TARIF · B05-CLAVE-COMIS · occurs 06/24/25

**Excepciones:**
- Los productos sin clave de tarifa/comisión no generan cobro por consulta.

**Estado validación:** Verificado fuente líneas 39-45, 11-13

---

## RN-S500-408 — Marca por producto de aplicabilidad de la librería S050/L190 con conteo de cobertura

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-408 |
| **Nombre** | Marca por producto de aplicabilidad de la librería S050/L190 con conteo de cobertura |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P199 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P199 mantiene por producto una marca que indica si aplica la librería de tarifas S050/L190 (WKS-TB-B05-S050L190) y lleva contadores de cuántos productos sí tienen y cuántos no tienen tarifa S050. Esto permite auditar la cobertura de la calificación de comisiones y detectar productos sin tarifa configurada.

**Fórmula/pseudocódigo:**
```
04 WKS-TB-B05-S050L190  PIC 9(01) COMP   (1 = aplica S050L190)
W77-NUM-SI-S050 = productos con tarifa S050
W77-NUM-NO-S050 = productos sin tarifa S050
```

**Vocabulario en la fórmula:** WKS-TB-B05-S050L190 · W77-NUM-SI-S050 · W77-NUM-NO-S050 · W77-SW-S050L190

**Excepciones:**
- Un producto sin librería S050 (WKS-SIN-LBS050) se contabiliza aparte y no cobra comisión por esa vía.

**Estado validación:** Verificado fuente líneas 104-146, 168, 212

---

## RN-S500-409 — Aplicación de IVA sobre la comisión mediante la librería S080IVA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-409 |
| **Nombre** | Aplicación de IVA sobre la comisión mediante la librería S080IVA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (IVA) |
| **Programa ejecutor** | P199 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para el cobro de comisiones por consulta/estado de cuenta, P199 vincula la librería S080IVA, que aplica el impuesto al valor agregado sobre el importe de la comisión. Toda comisión de servicio bancario incorpora el IVA calculado por esta librería estándar.

**Fórmula/pseudocódigo:**
```
$SET S080IVA
comisión_total = comisión_base + IVA(comisión_base)   (vía librería S080IVA)
```

**Vocabulario en la fórmula:** S080IVA · comisión · IVA

**Excepciones:**
- La tasa de IVA y las exenciones las resuelve la librería S080IVA, no el programa.

**Estado validación:** Verificado fuente líneas 11 ($SET S050SALDOS S080IVA)

---

## RN-S500-410 — Depuración de comisiones pendientes al cancelar una inversión (Cuenta Uno)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-410 |
| **Nombre** | Depuración de comisiones pendientes al cancelar una inversión (Cuenta Uno) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando se cancela una inversión de Cuenta Uno, P305 busca las comisiones pendientes asociadas y las depura de las estructuras B48 y B49 bajo control transaccional. Es la limpieza contable que evita comisiones huérfanas vivas sobre una inversión ya cancelada.

**Fórmula/pseudocódigo:**
```
* BUSCO LAS COMISIONES PENDIENTES DE LA INVERSION QUE SE CANCELO
LOCK B49COMPENDEPP
IF B49-STATUS = 1 OR 2 OR 3 OR 4
   WS-FECHA-EPP = B49-FECHA-ULTACT
   VALIDO-BORRADOB49
```

**Vocabulario en la fórmula:** B48-STATUS · B49-STATUS · B49-FECHA-ULTACT · WS-FECHA-EPP

**Excepciones:**
- Registros B49 fuera de los estatus {1,2,3,4} no se consideran para depuración.

**Estado validación:** Verificado fuente líneas 1074, 1631-1645

---

## RN-S500-411 — Borrado de comisión EPP B49 por coincidencia del mes de vigencia

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-411 |
| **Nombre** | Borrado de comisión EPP B49 por coincidencia del mes de vigencia |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Una comisión EPP se elimina de la B49 cuando su estatus está en {1,2,3,4} y el mes EPP calculado coincide con el mes EPP del registro. Este cruce de mes garantiza que sólo se borren las comisiones del ciclo mensual correspondiente y no de otros periodos.

**Fórmula/pseudocódigo:**
```
IF (B49-STATUS = 1 OR 2 OR 3 OR 4) AND WS-EPPMES-MM = WS-EPP-MM
   MOVE 1 TO WS-BAN-B49
   PERFORM 53400000-BORRO   (elimina la comisión B49)
```

**Vocabulario en la fórmula:** B49-STATUS · WS-EPPMES-MM · WS-EPP-MM · WS-BAN-B49

**Excepciones:**
- Si el mes EPP no coincide, la comisión se conserva para su ciclo.

**Estado validación:** Verificado fuente líneas 1656-1659

---

## RN-S500-412 — Decremento cíclico del mes de vigencia EPP (enero retrocede a diciembre)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-412 |
| **Nombre** | Decremento cíclico del mes de vigencia EPP (enero retrocede a diciembre) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El mes de vigencia EPP se retrocede de forma cíclica: si el mes es 1 (enero) se ajusta a 12 (diciembre), en cualquier otro caso se resta 1. Esta aritmética modular de meses evita un mes cero al calcular el periodo EPP anterior.

**Fórmula/pseudocódigo:**
```
IF WS-EPPMES-MM = 1
   MOVE 12 TO WS-EPPMES-MM
ELSE
   COMPUTE WS-EPPMES-MM = WS-EPPMES-MM - 1
```

**Vocabulario en la fórmula:** WS-EPPMES-MM (1..12 cíclico)

**Excepciones:**
- No ajusta el año al cruzar de enero a diciembre (sólo el mes).

**Estado validación:** Verificado fuente líneas 1651-1654

---

## RN-S500-413 — Borrado de registro de comisión B48 cuando su estatus es 2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-413 |
| **Nombre** | Borrado de registro de comisión B48 cuando su estatus es 2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los registros de la estructura de comisiones B48 cuyo estatus sea 2 se eliminan durante la depuración de comisiones de la inversión cancelada. El estatus 2 identifica el registro elegible de borrado en este flujo.

**Fórmula/pseudocódigo:**
```
IF B48-STATUS = 2
   MOVE 1 TO WS-BAN-B48
   PERFORM 53400000-BORRO
```

**Vocabulario en la fórmula:** B48-STATUS · WS-BAN-B48

**Excepciones:**
- Registros B48 con otro estatus permanecen.

**Estado validación:** Verificado fuente líneas 1623-1625

---

## RN-S500-414 — Depuración transaccional por lotes del control de arribos B08P vencidos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-414 |
| **Nombre** | Depuración transaccional por lotes del control de arribos B08P vencidos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P305 depura la estructura de control de arribos B08P eliminando los registros cuya fecha de proceso es anterior a la fecha del sistema. El borrado se agrupa en transacciones por lote: cuando el número de contratos procesados alcanza el tope configurado se cierra la transacción (END-TRANSACTION), controlando el tamaño de cada commit.

**Fórmula/pseudocódigo:**
```
LOCK B08PCTRA
IF B08P-FEC-PROC < WS-S006-FECHA1
   DELETE B08PCTRA
IF W77-NUM-CTOS-BEGIN = W77-NUM-BEG-END-T   (tope de lote)
   END-TRANSAC-NOAUD ; reinicia contador
```

**Vocabulario en la fórmula:** B08P-FEC-PROC · WS-S006-FECHA1 · W77-NUM-BEG-END-T (tope de commit)

**Excepciones:**
- Un status de fin de transacción 15 se tolera como no error.

**Estado validación:** Verificado fuente líneas 1664-1677

---

## RN-S500-415 — Marca de inicio de corrida vía librería de fechas S006 (función 10)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-415 |
| **Nombre** | Marca de inicio de corrida vía librería de fechas S006 (función 10) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P305 (S500P305) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P305 marca el inicio de la corrida del programa invocando la librería común de fechas S006 con función 10. Es el control estándar de arranque que registra y valida la fecha de proceso antes de abrir la base en modo actualización.

**Fórmula/pseudocódigo:**
```
* FUNCION: PARA INDICAR EL INICIO DE CORRIDA DE UN PROGRAMA
MOVE 10 TO WKS-INP-FUNCION → WS-S006-FUNCION
PERFORM LOCSUP
IF WS-S006-FUNCION > 0  → error de fecha
```

**Vocabulario en la fórmula:** WKS-INP-FUNCION (10) · WS-S006-FUNCION · S006LOCSUP

**Excepciones:**
- Un retorno de función mayor a cero se reporta como error de fecha.

**Estado validación:** Verificado fuente líneas 493, 596-609, 1479-1484

---

## RN-S500-416 — Planchado de autorizaciones pendientes en B03 (neteo FILLER1 menos FILLER2)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-416 |
| **Nombre** | Planchado de autorizaciones pendientes en B03 (neteo FILLER1 menos FILLER2) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P121 (ACTB03) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P121 "plancha" (reconcilia y consolida) las autorizaciones pendientes de cada contrato en la B03. Para un contrato no planchado con montos pendientes, recalcula la autorización pendiente como la diferencia FILLER1 menos FILLER2 cuando FILLER1 es mayor; en caso contrario deja la autorización en cero. Tras el ajuste sincroniza el indicador de control del contrato con el de la B02 y limpia los campos FILLER.

**Fórmula/pseudocódigo:**
```
IF (B03-AUT-PENDIENTE > 0) OR (B03-FILLER1 > 0) OR (B03-FILLER2 > 0)
   IF B03-FILLER1 > B03-FILLER2
      COMPUTE B03-AUT-PENDIENTE = B03-FILLER1 - B03-FILLER2
      MOVE W77-B02-IND-AUTPEND TO B03-CTR-AUTSPEND
      MOVE ZERO TO B03-FILLER1 B03-FILLER2 ; MOVE 1 TO WKS-SI-B03
   ELSE
      MOVE ZERO TO B03-AUT-PENDIENTE B03-FILLER1 B03-FILLER2
      MOVE W77-B02-IND-AUTPEND TO B03-CTR-AUTSPEND
```

**Vocabulario en la fórmula:** B03-AUT-PENDIENTE · B03-FILLER1 · B03-FILLER2 · B03-CTR-AUTSPEND · W77-B02-IND-AUTPEND

**Excepciones:**
- Si FILLER1 no supera a FILLER2, la autorización pendiente se anula (no queda negativa).

**Estado validación:** Verificado fuente líneas 20-44, 329-334

---

## RN-S500-417 — Sólo se actualizan contratos activos o bloqueados (B03-STATUS 0 o 1)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-417 |
| **Nombre** | Sólo se actualizan contratos activos o bloqueados (B03-STATUS 0 o 1) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P121 (ACTB03) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El planchado de autorizaciones sólo se aplica a contratos cuyo estatus sea 0 (activo) o 1 (bloqueado). Los contratos en cualquier otro estatus (cancelados u otros) se leen pero no se actualizan, protegiendo su información de autorizaciones.

**Fórmula/pseudocódigo:**
```
* B03-STATUS=0 ACTIVO   B03-STATUS=1 BLOQUEADO
IF B03-STATUS = 0 OR 1
   PERFORM 50110000-ACTUALIZACION
```

**Vocabulario en la fórmula:** B03-STATUS (0=activo, 1=bloqueado)

**Excepciones:**
- Contratos con estatus distinto de 0/1 se cuentan como leídos pero no modificados.

**Estado validación:** Verificado fuente líneas 313-315

---

## RN-S500-418 — Cobertura de actualización sólo en la plaza VDM (CSI 10)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-418 |
| **Nombre** | Cobertura de actualización sólo en la plaza VDM (CSI 10) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P121 (ACTB03) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de planchado distingue la plaza por CSI: en cobertura de Valle de México (CSI 10) actualiza la B03, mientras que en Monterrey (CSI 04) opera bajo su propia rama. Un CSI distinto de 10 o 04 genera el error "NODO ERRONEO" y no procesa, evitando aplicar cambios en una plaza no reconocida.

**Fórmula/pseudocódigo:**
```
IF W77-MY-CSI = 10  → APLI-DES-VDM  (VDM actualiza)
ELSE IF W77-MY-CSI = 04  → APLI-DES-MTY
ELSE  MENSAJE "NODO ERRONEO"
```

**Vocabulario en la fórmula:** W77-MY-CSI (10=VDM, 04=MTY) · APLI-DES-VDM · APLI-DES-MTY

**Excepciones:**
- El comentario del fuente indica que en cobertura de MTY no actualiza; sólo VDM materializa los cambios.

**Estado validación:** Verificado fuente líneas 267-297

---

## RN-S500-419 — Ejecución del planchado condicionada al parámetro de entrada (WS-PARAM-121 = 1)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-419 |
| **Nombre** | Ejecución del planchado condicionada al parámetro de entrada (WS-PARAM-121 = 1) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P121 (ACTB03) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de planchado sólo se ejecuta si el parámetro de entrada del programa es igual a 1. Cualquier otro valor produce el mensaje "PARAMETRO NO RECONOCIDO" y no se realiza ninguna actualización, actuando como candado de seguridad para no correr el planchado por accidente.

**Fórmula/pseudocódigo:**
```
IF WS-PARAM-121 = 1
   PERFORM 50000100-PROCESO-PLANCHADO
ELSE
   MENSAJE "PARAMETRO NO RECONOCIDO"
```

**Vocabulario en la fórmula:** WS-PARAM-121

**Excepciones:**
- Sin el parámetro correcto el programa termina sin tocar la B03.

**Estado validación:** Verificado fuente líneas 258-264

---

## RN-S500-420 — Detección de contrato "no planchado" por discrepancia de indicadores de control

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-420 |
| **Nombre** | Detección de contrato "no planchado" por discrepancia de indicadores de control |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P121 (ACTB03) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Un contrato se considera "no planchado" (pendiente de reconciliar) cuando el indicador de autorizaciones pendientes de la B02 difiere del control del contrato en la B03 y además el control secundario tampoco coincide. Sólo estos contratos con doble discrepancia entran a la lógica de neteo de autorizaciones, evitando reprocesar contratos ya reconciliados.

**Fórmula/pseudocódigo:**
```
IF W77-B02-IND-AUTPEND        NOT = B03-CTR-AUTSPEND
   IF W77-B02-CTR-AUTSPENDEAS  NOT = B03-CTR-AUTSPEND
*     CONTRATO NO PLANCHADO
      → aplica neteo de autorizaciones (RN-S500-416)
```

**Vocabulario en la fórmula:** W77-B02-IND-AUTPEND · W77-B02-CTR-AUTSPENDEAS · B03-CTR-AUTSPEND

**Excepciones:**
- Si cualquiera de los controles ya coincide, el contrato se considera planchado y no se re-netea.

**Estado validación:** Verificado fuente líneas 329-330

---

## RN-S500-421 — Cálculo de comisiones de productos especiales de cheques con separación de importe e IVA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-421 |
| **Nombre** | Cálculo de comisiones de productos especiales de cheques con separación de importe e IVA |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (IVA) |
| **Programa ejecutor** | P330 (CALCULOS-PROD-ESP) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P330 calcula las comisiones de productos especiales de chequera desglosando por separado el importe de la operación y su IVA. Cada clave de transacción lleva un par importe/importe-IVA (CVETRAN e CVETRANIVA), de modo que la base de comisión y el impuesto viajan en campos distintos para su registro contable y fiscal.

**Fórmula/pseudocódigo:**
```
CVETRAN-S500 · IMPORTE-S500      (base de comisión)
CVETRANIVA-S500 · IMPORTEIVA-S500 (IVA de la comisión)
WS-IVA / WS-SIVA / WS-CIVA acumulan el IVA calculado
```

**Vocabulario en la fórmula:** CVETRAN-S500 · IMPORTE-S500 · CVETRANIVA-S500 · IMPORTEIVA-S500 · WS-IVA

**Excepciones:**
- El importe y su IVA se manejan con claves de transacción separadas para trazabilidad fiscal.

**Estado validación:** Verificado fuente líneas 2963-2973, 201-203

---

## RN-S500-422 — Consolidación de cheques de ambas plazas (VDM y MTY) para el cálculo unificado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-422 |
| **Nombre** | Consolidación de cheques de ambas plazas (VDM y MTY) para el cálculo unificado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P330 (CALCULOS-PROD-ESP) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P330 lee los archivos de cuenta-producto de cheques de las dos plazas (S001CTAPRODVDM y S001CTAPRODMTY), los combina y los ordena por CSI, sucursal, cuenta y clave de transacción para producir un cálculo unificado de productos especiales de chequera a nivel banco.

**Fórmula/pseudocódigo:**
```
S001CTAPRODVDM (Valle de México) + S001CTAPRODMTY (Monterrey)
→ SORT por SD-SORCSI, SD-SORSUC, SD-SORCTA, SD-SORCVETRAN
→ cálculo unificado
```

**Vocabulario en la fórmula:** S001CTAPRODVDM · S001CTAPRODMTY · SD-SORCSI · SD-SORSUC · SD-SORCTA · SD-SORCVETRAN

**Excepciones:**
- Los importes de cheques (CHQVDM/CHQMTY) traen precisión 9(09)V99 en formato binario.

**Estado validación:** Verificado fuente líneas 26-27, 66-70, 2941-2942

---

## RN-S500-423 — Aplicación de rangos de tarifa mediante catálogo S080/L100

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-423 |
| **Nombre** | Aplicación de rangos de tarifa mediante catálogo S080/L100 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF (comisiones) |
| **Programa ejecutor** | P330 (CALCULOS-PROD-ESP) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El cálculo de comisiones aplica rangos de tarifa (clave de rango) resueltos con el catálogo de la librería S080/L100. Según el rango en que caiga la operación se aplica la tarifa correspondiente, materializada en el listado de rangos (LISTRANGOS).

**Fórmula/pseudocódigo:**
```
L100-COD080-CVERANGO / L100R080-CTR-CVERANGO  (clave de rango del catálogo S080)
→ tarifa por rango → LISTRANGOS
```

**Vocabulario en la fórmula:** L100-COD080-CVERANGO · L100R080-CTR-CVERANGO · S080CATALOGOS

**Excepciones:**
- La definición de los límites de cada rango vive en el catálogo S080, no en el programa.

**Estado validación:** Verificado fuente líneas 2700-2709, 32 (LISTRANGOS)

---

## RN-S500-424 — Opción de pago con grupo y cuenta de pago (estructura B37)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-424 |
| **Nombre** | Opción de pago con grupo y cuenta de pago (estructura B37) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P330 (CALCULOS-PROD-ESP) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P330 resuelve la opción de pago de las comisiones a partir de la estructura B37, que define el grupo de pago y la cuenta de pago (cada uno compuesto por sucursal y cuenta). Esto determina a qué cuenta se carga la comisión del producto especial, generando el archivo OPCIONPAGO ordenado por opción.

**Fórmula/pseudocódigo:**
```
WS-B37-NUM-GPO  = grupo (6 + 4)
WS-B37-CTA-PGO  = cuenta de pago (SUC 4 + CTA 8)
→ SORT-OPCION por SD-OPCIONS → OPCIONPAGO
```

**Vocabulario en la fórmula:** WS-B37-NUM-GPO · WS-B37-CTA-PGO · SD-OPCIONS · OPCIONPAGO

**Excepciones:**
- El grupo y la cuenta de pago se descomponen en primera y segunda parte para el ruteo.

**Estado validación:** Verificado fuente líneas 2784-2792, 34, 83-87

---

## RN-S500-425 — Cálculo del IVA de la comisión con tabla de tasa de cuatro decimales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-425 |
| **Nombre** | Cálculo del IVA de la comisión con tabla de tasa de cuatro decimales |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (IVA) |
| **Programa ejecutor** | P330 (CALCULOS-PROD-ESP) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El IVA de la comisión se calcula usando una tabla de tasa con precisión de cuatro decimales (WS-TABIVA PIC 9(04)V9(04)), lo que permite representar la tasa vigente con exactitud. El resultado se acumula con precisión de 20 enteros y 2 decimales para soportar volúmenes altos.

**Fórmula/pseudocódigo:**
```
WS-TABIVA  PIC 9(04)V9(04)   (tasa de IVA con 4 decimales)
WS-IVA     PIC 9(20)V99      (IVA acumulado)
IVA = base_comisión * WS-TABIVA
```

**Vocabulario en la fórmula:** WS-TABIVA · WS-TABIVA-ENTEROS · WS-IVA · WS-TAR-IVADEC-SAL

**Excepciones:**
- La tasa de IVA se toma de la tabla/librería S080IVA, no está hardcodeada en el cálculo.

**Estado validación:** Verificado fuente líneas 3018-3022, 201-203, 264-265

---

## RN-S500-426 — Detección de clientes con más de 2 devoluciones de cheque en el bimestre

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-426 |
| **Nombre** | Detección de clientes con más de 2 devoluciones de cheque en el bimestre |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico / CONDUSEF |
| **Programa ejecutor** | P320 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P320 identifica a los clientes que acumulan más de 2 devoluciones de cheque en el bimestre. Superar este umbral es la condición para reportar al cliente en el listado bimestral de devoluciones, insumo del tratamiento por manejo inadecuado de cuenta de cheques (cancelación de chequera, reporte a buró).

**Fórmula/pseudocódigo:**
```
IF WKS-I01-R01-DEVMES-TOT > 2
   → cliente con "MAS DE 2 DEVOLUCIONES", se reporta en DEVOLBIM
```

**Vocabulario en la fórmula:** WKS-I01-R01-DEVMES-TOT · umbral 2 devoluciones

**Excepciones:**
- Clientes con 2 o menos devoluciones en el bimestre no se listan.

**Estado validación:** Verificado fuente líneas 919-921, 479

---

## RN-S500-427 — Total bimestral de devoluciones como suma de mes actual y mes anterior

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-427 |
| **Nombre** | Total bimestral de devoluciones como suma de mes actual y mes anterior |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P320 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El total de devoluciones del bimestre se obtiene sumando las devoluciones del mes actual y las del mes anterior almacenadas en la estructura B20. Esta ventana móvil de dos meses es la que define el conteo contra el umbral de 2 devoluciones.

**Fórmula/pseudocódigo:**
```
COMPUTE WKS-I01-R01-DEVMES-TOT = B20-DEV-MES-ANT + DEV-MES-ACT
DEVMES-TOT = DEVMES-ANT + DEVMES-ACT
```

**Vocabulario en la fórmula:** B20-DEV-MES-ANT · WKS-S02-R01-DEVMES-ACT · WKS-S02-R01-DEVMES-TOT

**Excepciones:**
- El promedio del mes y del año (PROM-MES, PROM-ANH) acompañan el conteo para contexto.

**Estado validación:** Verificado fuente líneas 63-66, 919

---

## RN-S500-428 — Segmentación del reporte de devoluciones por sucursal y nodo de impresión

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-428 |
| **Nombre** | Segmentación del reporte de devoluciones por sucursal y nodo de impresión |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P320 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El reporte de clientes con más de 2 devoluciones se genera segmentado por sucursal promotora y por nodo de impresión, ordenando la entrada (SORTDEVMES) por nodo, sucursal y contrato. Así cada sucursal/nodo recibe su corte con totales propios.

**Fórmula/pseudocódigo:**
```
SORT S02-SORTDEVMES por NODO, SUC-PROM, CONTRATO
Corte por sucursal y por nodo de impresión → reporte DEVOLBIM
```

**Vocabulario en la fórmula:** WKS-S02-R01-NODO · WKS-S02-R01-SUC-PROM · WKS-S02-R01-CONTRATO

**Excepciones:**
- Los totales se emiten por sucursal, por nodo y generales.

**Estado validación:** Verificado fuente líneas 28-29, 58-65

---

## RN-S500-429 — Reporte de comisiones pendientes sin IVA por devoluciones acumuladas (COMIPEND)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-429 |
| **Nombre** | Reporte de comisiones pendientes sin IVA por devoluciones acumuladas (COMIPEND) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (IVA) / CONDUSEF |
| **Programa ejecutor** | P320 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además del listado de devoluciones, P320 genera el reporte de comisiones pendientes expresadas sin IVA (COMIPEND), acumulando el importe de comisión por devolución de cheque desde la estructura B12. El reporte separa explícitamente la base de comisión del impuesto, dejando el IVA para su cálculo posterior.

**Fórmula/pseudocódigo:**
```
GENERA-COMIPEND:
   ADD B12-IMP-ACUMULADO(idx) TO W77-CHQDEV-CTO
   reporte "002COMIPEND" con "COMISIONES PENDIENTES SIN IVA"
```

**Vocabulario en la fórmula:** B12-IMP-ACUMULADO · W77-CHQDEV-CTO · COMIPEND · comisión sin IVA

**Excepciones:**
- El importe reportado es la base sin IVA; el impuesto se aplica en el cobro efectivo.

**Estado validación:** Verificado fuente líneas 495, 1199-1278

---

## RN-S500-430 — Backup nombrado por usuario de los reportes de devoluciones y comisiones

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-430 |
| **Nombre** | Backup nombrado por usuario de los reportes de devoluciones y comisiones |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P320 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los reportes de P320 se materializan como backups nombrados por usuario (USERBACKUPNAME) con título estándar, permitiendo su archivado y recuperación por nombre en el entorno ClearPath MCP. El reporte de devoluciones se identifica como 001DEVOLBIM y el de comisiones pendientes como 002COMIPEND.

**Fórmula/pseudocódigo:**
```
SET R02-COMIPEND(USERBACKUPNAME) TO VALUE TRUE
SET R02-COMIPEND(TITLE) TO "002COMIPEND"
OPEN OUTPUT ; ... ; CLOSE WITH SAVE
```

**Vocabulario en la fórmula:** USERBACKUPNAME · 001DEVOLBIM · 002COMIPEND · CLOSE WITH SAVE

**Excepciones:**
- El cierre con SAVE preserva el backup para consumo posterior.

**Estado validación:** Verificado fuente líneas 1200-1204, 1310, 326

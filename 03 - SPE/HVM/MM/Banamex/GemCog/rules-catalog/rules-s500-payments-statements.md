# Catálogo de Reglas de Negocio — S500 Payments · Statements · SPEI
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P155 · P178 · P176 · P174 · P161 · P179 (Payments) · P335 · P400 · P185 · P184 (Statements) · P165 (SPEI/CLABE)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-501 a RN-S500-560 (60 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-501 — Depuración de pagos pendientes en BD01/B25 (borrado por estatus, vencimiento o saldo cero)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-501 |
| **Nombre** | Depuración de pagos pendientes en BD01/B25 (borrado por estatus, vencimiento o saldo cero) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P155 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa comparativo elimina de la base de pagos pendientes (B25) todo registro que cumpla al menos una de tres condiciones de purga: registro marcado como eliminado o inactivo, registro cuya fecha límite de cobro ya venció frente a la fecha de proceso, o registro sin saldo cuya fecha límite es la fecha centinela `99999999`. Cada registro purgado se actualiza en base y se escribe al archivo de auditoría de borrados.

**Fórmula/pseudocódigo:**
```
IF (B25-STATUS = 1 OR B25-STATUS = 2)
   OR (B25-FECHA-LTECOBR NOT > WS-FECHA-PRO-AMD)
   OR (B25-SALDO = 0 AND B25-FECHA-LTECOBR = 99999999)
   MOVE 1 TO WS-BAN-B25
   PERFORM 51001100-ACTUALIZO
   PERFORM 51001200-GEN-ARCH
```

**Vocabulario en la fórmula:** B25-STATUS · B25-FECHA-LTECOBR · B25-SALDO · WS-FECHA-PRO-AMD

**Excepciones:**
- El valor de fecha `99999999` actúa como centinela de "sin fecha límite"; combinado con saldo 0 fuerza el borrado.
- STATUS = 1 significa eliminado, STATUS = 2 es un segundo estado inactivo purgable.

**Estado validación:** Verificado fuente líneas 537610-539310 (párrafo 50600100-BORRO)

---

## RN-S500-502 — Empate de cambios de clientes S016 contra S500

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-502 |
| **Nombre** | Empate de cambios de clientes S016 contra S500 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P155 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa lee el archivo de clientes provenientes del S016 y aplica en el S500 los cambios detectados, empatando el estado de cliente entre ambos sistemas. El archivo se identifica con la etiqueta `(S016)S016/FILE/S500/` y el proceso valida existencia y último registro antes de recorrerlo para sincronizar contra la base de contratos B03.

**Fórmula/pseudocódigo:**
```
SET CLIENTES (TITLE) TO WS-ETIQ-CTE
IF ATTRIBUTE RESIDENT OF CLIENTES IS = VALUE TRUE
   OPEN INPUT CLIENTES
   MOVE ATTRIBUTE LASTRECORD OF CLIENTES TO WS-LASTRECORDM1
   PERFORM 50700000-ACT-CTES  (empata cambios S016 vs S500)
```

**Vocabulario en la fórmula:** WS-ETIQ-CTE · CLIENTES · B03-CONTRATOS · S016

**Excepciones:**
- Si el archivo de clientes no está residente, el empate de ese ciclo no se ejecuta.

**Estado validación:** Verificado fuente líneas 545610-552010 (párrafo 50700000-ACT-CTES)

---

## RN-S500-503 — Bloqueo de cuentas por expedientes incompletos vía librería S016

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-503 |
| **Nombre** | Bloqueo de cuentas por expedientes incompletos vía librería S016 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P155 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa consume del S016 el archivo de bloqueos por expedientes incompletos (`FUSCTASOTS`) e invoca la interfaz S016 0102 para marcar como bloqueadas las cuentas cuyo expediente de identificación del cliente no está completo. El expediente incompleto es un requisito de conocimiento del cliente (KYC) exigido por CNBV; su ausencia debe restringir la operación de la cuenta.

**Fórmula/pseudocódigo:**
```
MOVE ALL @00@ TO WS-S016-0102-ENTRADA
MOVE 155     TO WS-S016-0102-CTR-NUMPASO-I
MOVE CTE-PRD TO WS-S016-0102-CTA-NUMPROD-I
MOVE CTE-INS TO WS-S016-0102-CTA-CVEINST-I
PERFORM interfaz S016-0102  → resultado de bloqueo por expediente
IF WS-BLQ-R01-BLOQUEO > 0  → cuenta bloqueada
```

**Vocabulario en la fórmula:** S016-0102 · CTESBLOQUEOS · WS-BLQ-R01-BLOQUEO · FUSCTASOTS

**Excepciones:**
- Si el archivo `FUSCTASOTS` llega sin header se genera error de proceso, no bloqueo silencioso.

**Estado validación:** Verificado fuente líneas 613610-614610 y 088810 (FD CTESBLOQUEOS)

---

## RN-S500-504 — Asignación de clave de cobro y comisión para Cuenta Productiva Especial (CPE)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-504 |
| **Nombre** | Asignación de clave de cobro y comisión para Cuenta Productiva Especial (CPE) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P155 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para las cuentas del S500 marcadas como Cuenta Productiva Especial, el programa consulta la interfaz S016 0101 con producto 1 e instrumento 3, y recupera la clave de cobro y el importe de comisión de captación aplicables (posición 4 del arreglo de cobros), poblando el registro de salida CPE. Esto liga la política de comisiones del expediente CPE con el registro de captación.

**Fórmula/pseudocódigo:**
```
MOVE 500 TO WS-S016-0101-CTR-NUMSIST-I
MOVE 155 TO WS-S016-0101-CTR-NUMPASO-I
MOVE 1   TO WS-S016-0101-CTA-NUMPROD-I
MOVE 3   TO WS-S016-0101-CTA-CVEINST-I
MOVE B03-NUM-CONTRATO TO WS-S016-0101-CTO-NUM-I
IF WS-S016-0101-RESULT-ORIG NOT = 0
   MOVE WS-S016-0101-CVECOBRO(04) TO CPE-CVE-COBRO
   MOVE WS-S016-0101-COBCOM (04)  TO CPE-IMP-COM-CAP
```

**Vocabulario en la fórmula:** S016-0101 · CPE-CVE-COBRO · CPE-IMP-COM-CAP · B03-NUM-CONTRATO

**Excepciones:**
- El índice fijo `(04)` para clave de cobro y comisión es un [HARDCODE-IMPLÍCITO]: la posición 4 del arreglo se asume como la comisión CPE vigente.

**Estado validación:** Verificado fuente líneas 511770-511890 (párrafo de armado CPE)

---

## RN-S500-505 — Bitácora de auditoría de registros borrados (header, detalle, trailer)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-505 |
| **Nombre** | Bitácora de auditoría de registros borrados (header, detalle, trailer) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P155 (COMPARATIVO) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Todo registro purgado de BD01/B25 (ver RN-S500-501) se escribe en un archivo de auditoría con estructura de tres bloques: un header, un detalle por cada registro eliminado (incluye saldo y estatus originales) y un trailer. Esta bitácora es la evidencia de qué se borró en cada corrida y por qué motivo (`BORRO B25-SALDO=0 Y B25-STATUS=1`).

**Fórmula/pseudocódigo:**
```
MOVE B25-SALDO  TO WS-SALDO
MOVE B25-STATUS TO WS-STATUS
WRITE REG-BORRADOS FROM REG-ELIMINADOS  INVALID KEY → error
* estructura: HDR + DET(n) + TRL
```

**Vocabulario en la fórmula:** REG-BORRADOS · REG-ELIMINADOS · WS-SALDO · WS-STATUS

**Excepciones:**
- Errores de grabado (INVALID KEY) en header/detalle/trailer se reportan con mensaje MAPLI; no se pierde silenciosamente el registro.

**Estado validación:** Verificado fuente líneas 829724-829900 y 500810

---

## RN-S500-506 — Consolidación del punteo de los tres CSI (líneas L1/L2/L3 y batch B1/B2/B3) en PUNTEOT

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-506 |
| **Nombre** | Consolidación del punteo de los tres CSI (líneas L1/L2/L3 y batch B1/B2/B3) en PUNTEOT |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P178 (S500P178) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de punteo (conciliación de movimientos aplicados) recibe seis archivos particionados por CSI: tres de captura en línea (PUNTEOL1, PUNTEOL2, PUNTEOL3) y tres de captura batch (PUNTEOB1, PUNTEOB2, PUNTEOB3). El programa los concatena en un único archivo de trabajo PUNTEOT que representa el universo total de movimientos a puntear del S500 hacia el S111. La partición por CSI refleja la arquitectura distribuida de captación en múltiples centros de servicio.

**Fórmula/pseudocódigo:**
```
FOR cada CSI en (L1,L2,L3, B1,B2,B3):
    READ REG-PUNTEO(csi)
    WRITE REG-PUNTEOT
```

**Vocabulario en la fórmula:** PUNTEOL1..L3 · PUNTEOB1..B3 · PUNTEOT · CSI

**Excepciones:**
- Error al grabar PUNTEOT genera mensaje `ERROR AL GRABAR ARC. PUNTEOT`.

**Estado validación:** Verificado fuente líneas 026510-037510 (FILE-CONTROL) y 342010

---

## RN-S500-507 — Ordenamiento del punteo por contrato-movimiento y clave-movimiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-507 |
| **Nombre** | Ordenamiento del punteo por contrato-movimiento y clave-movimiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P178 (S500P178) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo consolidado se ordena ascendentemente por la llave compuesta contrato-movimiento (`CTOMOV-SORT`) seguida de la clave de movimiento (`CVEMOV-SORT`). Este orden agrupa todos los movimientos de un mismo contrato de forma contigua, condición necesaria para que el punteo posterior empate cargos y abonos del mismo contrato sin lecturas aleatorias.

**Fórmula/pseudocódigo:**
```
SORT PUNTEO-SORT ON ASCENDING KEY CTOMOV-SORT CVEMOV-SORT
```

**Vocabulario en la fórmula:** CTOMOV-SORT · CVEMOV-SORT · PUNTEO-SORT

**Excepciones:**
- Ninguna registrada; el orden es determinístico.

**Estado validación:** Verificado fuente línea 401010 (SORT)

---

## RN-S500-508 — Separación de movimientos de línea vs batch en el punteo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-508 |
| **Nombre** | Separación de movimientos de línea vs batch en el punteo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P178 (S500P178) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El punteo distingue estructuralmente la captura en línea (archivos serie L) de la captura batch (archivos serie B), manteniéndolos en flujos separados hasta la consolidación. Esta separación permite trazar el canal de origen (online vs batch) de cada movimiento conciliado y es relevante para diagnosticar descuadres por canal.

**Fórmula/pseudocódigo:**
```
* serie L → movimientos capturados en línea (online)
* serie B → movimientos capturados en batch
* ambos convergen en PUNTEOT antes del SORT
```

**Vocabulario en la fórmula:** PUNTEOL* · PUNTEOB* · REG-PUNTEOT

**Excepciones:**
- La distinción canal se pierde tras la consolidación salvo por campos internos del registro.

**Estado validación:** Verificado fuente líneas 044010-087953 (declaraciones FD)

---

## RN-S500-509 — Copias múltiples de los archivos de punteo (redundancia operativa L1/L2/L3 copia 2 y 3)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-509 |
| **Nombre** | Copias múltiples de los archivos de punteo (redundancia operativa L1/L2/L3 copia 2 y 3) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P178 (S500P178) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa declara copias 2 y 3 de los archivos de punteo de línea (`PUNTEOL1 COPIA 2`, `PUNTEOL1 COPIA 3`), un patrón de redundancia operativa que permite reprocesar el punteo sin regenerar el insumo original desde captación. Es un mecanismo de resiliencia ante fallos de corrida en un ambiente MCP donde reconstruir el archivo primario es costoso.

**Fórmula/pseudocódigo:**
```
* PUNTEOL1        → archivo primario
* PUNTEOL1 COPIA 2 → respaldo de reproceso
* PUNTEOL1 COPIA 3 → segundo respaldo
```

**Vocabulario en la fórmula:** PUNTEOL1 · COPIA 2 · COPIA 3

**Excepciones:**
- Las copias no se sincronizan automáticamente si el primario cambia intracorrida.

**Estado validación:** Verificado fuente líneas 087530-087953 (declaraciones de copias)

---

## RN-S500-510 — Aplicación de altas, bloqueos y desbloqueos de prealtas TEF provenientes del S111

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-510 |
| **Nombre** | Aplicación de altas, bloqueos y desbloqueos de prealtas TEF provenientes del S111 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa aplica el archivo `(S500)S111/FILE/S500/PREALTAS/` con solicitudes de alta, bloqueo y desbloqueo de prealtas de asignación TEF (Transferencia Electrónica de Fondos) originadas en el S111. Cada registro de prealta se procesa contra las bases del S500 para materializar la asignación de pago electrónico a la tarjeta o contrato destino.

**Fórmula/pseudocódigo:**
```
OPEN INPUT E01-S111-PREALTAS
READ E01-REG-S111-PREALTA
   → 70000400-OBTENGO-CSI      (valida sucursal, ver RN-S500-511)
   → 80000000-VALIDA-TARJETA   (localiza/crea tarjeta en BD04)
   → aplica alta / bloqueo / desbloqueo
```

**Vocabulario en la fórmula:** E01-S111-PREALTAS · TEF · B03PREALTAS · B04P-NUM-TEF

**Excepciones:**
- Si ya se está corriendo otra instancia o no existe fecha parámetro válida, el proceso aborta con mensaje (`NO PUEDO PROCESAR PREALTAS...`).

**Estado validación:** Verificado fuente líneas 101800-101900 (OBJETIVO) y 106200 (FD)

---

## RN-S500-511 — Validación de sucursal promotora contra catálogo S080 y obtención del CSI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-511 |
| **Nombre** | Validación de sucursal promotora contra catálogo S080 y obtención del CSI |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada prealta el programa valida la sucursal promotora contra el catálogo S080; si la sucursal existe obtiene su CSI (centro de servicio), de lo contrario marca error de sucursal y rechaza el registro al reporte de rechazos. La sucursal promotora válida es requisito para asignar correctamente el movimiento al centro operativo.

**Fórmula/pseudocódigo:**
```
MOVE E01-S111-DET-SUC-PROM TO WKS-S080-NUMSUC
PERFORM 42000080-DATOS-S080
IF W88-S080-STA-NOOK
   MOVE 1 TO WKS-E01-SUC-ERROR-VA        (→ rechazo)
ELSE
   MOVE WKS-S080-NUMCSI TO WKS-E01-NUM-CSI
```

**Vocabulario en la fórmula:** S080 · SUC-PROM · WKS-E01-NUM-CSI · W88-E01-SUC-ERROR

**Excepciones:**
- Nota de mantenimiento ABR/2008 MTP 005: se amplió la tabla de sucursales válidas, evidencia de que el catálogo evoluciona.

**Estado validación:** Verificado fuente líneas 182600-183600 (párrafo 70000400-OBTENGO-CSI)

---

## RN-S500-512 — Localización o alta de tarjeta en BD04 durante la asignación TEF

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-512 |
| **Nombre** | Localización o alta de tarjeta en BD04 durante la asignación TEF |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al aplicar la prealta, el programa bloquea (LOCK) el registro de la tarjeta en BD04; si la tarjeta no existe la crea, y si existe la actualiza con el número de TEF, medio de entrada, fecha y bandera de asignación de pago. Esto vincula la asignación de pago electrónico del S111 con el registro de tarjeta del cliente.

**Fórmula/pseudocódigo:**
```
MOVE I01-TEF-DET-TARJETA TO WS-NUM-TARJETA
PERFORM 90400004-B04PSXTARJ-LOCK
IF WS-DB-ERROR AND WS-DB-NOTFOUND
   PERFORM 80050000-CREA-REG-BD04
ELSE
   MOVE I01-TEF-DET-NUMTEF TO B04P-NUM-TEF
   MOVE I01-TEF-ASIG-PAGO  TO B04P-ASIGNA-PAGO
```

**Vocabulario en la fórmula:** B04PSXTARJ · B04P-NUM-TEF · B04P-ASIGNA-PAGO · WS-NUM-TARJETA

**Excepciones:**
- Un error de BD04 distinto de "no encontrado" fuerza `DMTERMINATE` (aborta el proceso).

**Estado validación:** Verificado fuente líneas 183604-183638 (párrafo 80000000-VALIDA-TARJETA)

---

## RN-S500-513 — Bloqueo de reproceso concurrente de prealtas (mutex operativo)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-513 |
| **Nombre** | Bloqueo de reproceso concurrente de prealtas (mutex operativo) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar, el programa valida las bases y verifica que no exista otra corrida activa de prealtas; de estar corriendo aborta con mensaje `NO PUEDO PROCESAR PREALTAS... SE ESTA CORRIENDO`. Es un candado operativo que impide doble aplicación de altas/bloqueos, evitando duplicidad de asignaciones TEF.

**Fórmula/pseudocódigo:**
```
PERFORM 10010400-VALIDA-BASES
IF proceso ya corriendo
   STRING "NO PUEDO PROCESAR PREALTAS... SE ESTA CORRIENDO"
   ABORT
IF fecha parametro invalida
   STRING "ERROR, FECHA PARAMETRO INVALIDA"  → ABORT
```

**Vocabulario en la fórmula:** 10010400-VALIDA-BASES · fecha parámetro

**Excepciones:**
- La fecha parámetro debe existir y ser válida; ausencia o formato inválido aborta.

**Estado validación:** Verificado fuente líneas 631/128600 (VALIDA-BASES) y 136100-138200

---

## RN-S500-514 — Reporte de rechazos de asignación TEF con conteo total

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-514 |
| **Nombre** | Reporte de rechazos de asignación TEF con conteo total |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Todo registro de prealta que no pasa la validación de sucursal (o cuyas bases fallan) se escribe al reporte `RECHAZOS ASIGNACION TEF PREALTAS` con su causa de rechazo, y al cierre se imprime el total de registros rechazados. Este reporte es la evidencia operativa de las prealtas no aplicadas que deben corregirse y reenviarse desde el S111.

**Fórmula/pseudocódigo:**
```
IF W88-E01-SUC-ERROR
   MOVE causa TO REG-RECHAZOS
   WRITE REG-RECHAZOS
   ADD 1 TO WS-CONT-RECHAZOS
* al final:
MOVE WS-CONT-RECHAZOS TO WS-TOT-RECHA   → "REGISTROS RECHAZADOS :"
```

**Vocabulario en la fórmula:** R01-RECHAZOS · WS-CONT-RECHAZOS · CAUSA RECHAZO · W88-E01-SUC-ERROR

**Excepciones:**
- Ninguna; todos los rechazos se contabilizan.

**Estado validación:** Verificado fuente líneas 155100, 177160-177163 y 113448 (encabezado)

---

## RN-S500-515 — Actualización de fecha del próximo archivo de prealtas S111 a aplicar

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-515 |
| **Nombre** | Actualización de fecha del próximo archivo de prealtas S111 a aplicar |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P176 (S500P176) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al concluir la aplicación, el programa actualiza la fecha del próximo archivo del S111 que deberá aplicarse, encadenando las corridas diarias de prealtas. Este control secuencial garantiza que no se salte ni se reprocese un día de prealtas.

**Fórmula/pseudocódigo:**
```
* ACTUALIZA LA FECHA PARA EL PROXIMO ARCHIVO A APLICAR DEL S111
MOVE siguiente-fecha TO parametro-control
```

**Vocabulario en la fórmula:** S111 · fecha próximo archivo · parámetro de control

**Excepciones:**
- Depende de la integridad de la fecha parámetro validada en RN-S500-513.

**Estado validación:** Verificado fuente línea 174000 (comentario de proceso)

---

## RN-S500-516 — Barrido de contratos B03 y selección de cuentas elegibles para archivo de saldos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-516 |
| **Nombre** | Barrido de contratos B03 y selección de cuentas elegibles para archivo de saldos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P174 (GENARCHSDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa hace un barrido del data set B03CONTRATOS y selecciona las cuentas elegibles para el archivo de saldos según producto, instrumento y moneda: cuentas producto 500 con instrumento 1 en moneda 1 (nacional), o cuentas producto 66 en moneda 1. El estatus del contrato se mapea (0=activo → 1 o 5; otro → 9) para clasificar el registro de salida.

**Fórmula/pseudocódigo:**
```
IF (B03-NUM-PRODUCTO = 500 AND B03-NUM-INSTRUM = 1 AND B03-MONEDA = 1)
OR (B03-NUM-PRODUCTO = 66  AND B03-MONEDA = 1)
   → incluir en archivo de saldos
VALIDA B03-STATUS: 0(activo) → 1 OR 5 ; otro → 9
```

**Vocabulario en la fórmula:** B03-NUM-PRODUCTO · B03-NUM-INSTRUM · B03-MONEDA · B03-STATUS

**Excepciones:**
- Los códigos de producto 500/66 e instrumento 1 y moneda 1 están embebidos como filtro de negocio [HARDCODE-IMPLÍCITO].

**Estado validación:** Verificado fuente líneas 001400-002100 (cabecera de objetivo)

---

## RN-S500-517 — Cálculo del saldo disponible como saldo actual menos saldo pendiente

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-517 |
| **Nombre** | Cálculo del saldo disponible como saldo actual menos saldo pendiente |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P174 (GENARCHSDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada contrato elegible el programa calcula el saldo disponible restando el saldo pendiente (importes comprometidos aún no liberados) del saldo actual. El saldo disponible es la cifra que otros sistemas usan para autorizar cargos, por lo que la fórmula es un invariante contable crítico.

**Fórmula/pseudocódigo:**
```
WS-SDO-DISPONIBLE = WS03-SDO-ACTUAL - WS03-SDO-PENDIENTE
* campos de salida: CONTRATO, SDOACTUAL S9(12)V99, SDOAPEND, SDODISP S9(12)V99, SUCPROM
```

**Vocabulario en la fórmula:** WS-SDO-DISPONIBLE · WS03-SDO-ACTUAL · WS03-SDO-PENDIENTE

**Excepciones:**
- El saldo disponible puede ser negativo (campo con signo S9), reflejando sobregiro o pendientes mayores al actual.

**Estado validación:** Verificado fuente líneas 003000-003100 (cabecera de objetivo)

---

## RN-S500-518 — Transferencia interregional del archivo de saldos MTY → VDM vía XRAPID

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-518 |
| **Nombre** | Transferencia interregional del archivo de saldos MTY → VDM vía XRAPID |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P174 (GENARCHSDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de saldos generado en Monterrey (MTY) se transfiere al centro Valle de México (VDM) mediante el mecanismo XRAPID, y luego se incorporan los registros de VDM al mismo archivo. Esto refleja la arquitectura de doble centro de datos del core de captación, donde cada región mantiene su propio B03CONTRATOS y deben consolidarse.

**Fórmula/pseudocódigo:**
```
GENERA archivo saldos en MTY
TRANSFIERE archivo VIA XRAPID  MTY → VDM
INCLUYE registros de VDM al archivo
```

**Vocabulario en la fórmula:** XRAPID · MTY · VDM · B03CONTRATOS

**Excepciones:**
- La consolidación depende de que ambos centros hayan generado su parte; un centro atrasado produce saldos incompletos.

**Estado validación:** Verificado fuente líneas 003200-003400 (cabecera de objetivo)

---

## RN-S500-519 — Consolidación y ordenamiento del archivo de saldos por contrato

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-519 |
| **Nombre** | Consolidación y ordenamiento del archivo de saldos por contrato |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P174 (GENARCHSDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Tras incluir los registros de VDM, el archivo consolidado se ordena por número de contrato (`WS-REG-CONTRATO`), garantizando un archivo único ordenado que el S036 puede procesar secuencialmente por contrato.

**Fórmula/pseudocódigo:**
```
SORT archivo ON ASCENDING WS-REG-CONTRATO
```

**Vocabulario en la fórmula:** WS-REG-CONTRATO · SORT

**Excepciones:**
- Ninguna.

**Estado validación:** Verificado fuente línea 003500 (cabecera de objetivo)

---

## RN-S500-520 — Estructura de doble header y doble trailer con cifras de control

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-520 |
| **Nombre** | Estructura de doble header y doble trailer con cifras de control |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P174 (GENARCHSDOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de saldos se entrega con dos headers y dos trailers, más un encabezado de cifras de control (`S500-P174-CIFRAS-SALDOS`). Los dobles bloques distinguen las cifras de MTY y VDM, permitiendo que el receptor valide por separado el cuadre de cada centro antes de consolidar.

**Fórmula/pseudocódigo:**
```
* estructura de salida:
* HDR-1 (MTY) + HDR-2 (VDM)
* DETALLE con datos adicionales
* TRL-1 (MTY) + TRL-2 (VDM)  con cifras de saldos
```

**Vocabulario en la fórmula:** CIFRAS-SALDOS · HEADER · TRAILER · MTY · VDM

**Excepciones:**
- El descuadre de cifras entre header y trailer de un centro debe detenerse aguas abajo (validación en el receptor).

**Estado validación:** Verificado fuente líneas 003700-003800 y 041500-041900

---

## RN-S500-521 — Preparación del archivo de movimientos aplicados (altas/bloqueos/desbloqueos) hacia el S111

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-521 |
| **Nombre** | Preparación del archivo de movimientos aplicados (altas/bloqueos/desbloqueos) hacia el S111 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P161 (S500P161) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa prepara el archivo de retroalimentación con los movimientos de altas, bloqueos y desbloqueos que el S500 efectivamente aplicó (contraparte de las prealtas recibidas en P176), para devolverlos al S111. Cierra el ciclo de conciliación: el S111 solicita, el S500 aplica y confirma qué se aplicó.

**Fórmula/pseudocódigo:**
```
LEE movimientos aplicados en S500 (altas/bloqueos/desbloqueos)
ARMA registro de carga para S111
WRITE archivo (S500)...S111
```

**Vocabulario en la fórmula:** S111 · altas · bloqueos · desbloqueos · archivo de carga

**Excepciones:**
- Solo se preparan movimientos con estatus de aplicado; los rechazados no viajan de vuelta.

**Estado validación:** Verificado fuente líneas 101400-101500 (OBJETIVO) y 105100

---

## RN-S500-522 — Registro de carga S111 con estructura de trabajo por CSI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-522 |
| **Nombre** | Registro de carga S111 con estructura de trabajo por CSI |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P161 (S500P161) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de trabajo para el archivo de carga del S111 se estructura con las variables provenientes del sistema S111, preservando la correspondencia de campos entre la solicitud original y la confirmación de aplicación. Esto mantiene la trazabilidad extremo a extremo del movimiento.

**Fórmula/pseudocódigo:**
```
* VARIABLES PARA EL ARCHIVO DE CARGA DEL S111
* REGISTROS PROVENIENTES DEL SISTEMA S111
MOVE campos-aplicados TO registro-carga-S111
```

**Vocabulario en la fórmula:** archivo de carga S111 · registro de trabajo

**Excepciones:**
- Ninguna registrada.

**Estado validación:** Verificado fuente líneas 109400-110400

---

## RN-S500-523 — Cierre ordenado de bases y archivo de movimientos aplicados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-523 |
| **Nombre** | Cierre ordenado de bases y archivo de movimientos aplicados |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P161 (S500P161) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al finalizar, el programa cierra explícitamente las bases de datos y el archivo de movimientos aplicados en una rutina dedicada, garantizando que el archivo hacia el S111 quede completo y persistido (WITH SAVE) antes de que el S111 lo consuma. Evita entregas parciales por cierre implícito.

**Fórmula/pseudocódigo:**
```
* CIERRA BASES Y ARCHIVO DE MOV APLICADOS
CLOSE bases
CLOSE archivo-mov-aplicados WITH SAVE
```

**Vocabulario en la fórmula:** CLOSE · WITH SAVE · mov aplicados

**Excepciones:**
- Ninguna registrada.

**Estado validación:** Verificado fuente línea 144750

---

## RN-S500-524 — Consolidación de movimientos aplicados de MTY y VDM en un solo archivo para el S111

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-524 |
| **Nombre** | Consolidación de movimientos aplicados de MTY y VDM en un solo archivo para el S111 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P179 (S500P179) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa genera un único archivo con los movimientos aplicados combinando los archivos preparados de forma independiente en Monterrey (MTY) y Valle de México (VDM). Es el punto de convergencia de la retroalimentación distribuida hacia el S111: cada centro aplica sus movimientos y P179 los une en una sola confirmación.

**Fórmula/pseudocódigo:**
```
OPEN I01-S111-APLICADO-MTY
OPEN I01-S111-APLICADO-VDM
merge ambos → archivo aplicado consolidado
```

**Vocabulario en la fórmula:** I01-S111-APLICADO-MTY · I01-S111-APLICADO-VDM · S111

**Excepciones:**
- Si falta el archivo de un centro, la confirmación al S111 queda incompleta para esa región.

**Estado validación:** Verificado fuente líneas 101200-101300 (OBJETIVO) y 103600-107100

---

## RN-S500-525 — Trazabilidad de movimientos aplicados por CSI del sistema S111

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-525 |
| **Nombre** | Trazabilidad de movimientos aplicados por CSI del sistema S111 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P179 (S500P179) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro de trabajo conserva el desglose de movimientos aplicados por cada CSI del sistema S111, de modo que el S111 pueda reconciliar la confirmación contra la solicitud CSI por CSI. Mantiene la granularidad por centro de servicio a lo largo de la consolidación.

**Fórmula/pseudocódigo:**
```
* REGISTRO DE TRABAJO DE ARCHIVOS DE MOVIMIENTOS
* APLICADOS POR CADA CSI DEL SISTEMA S111
FOR cada CSI: acumula movimientos aplicados
```

**Vocabulario en la fórmula:** CSI · movimientos aplicados · S111

**Excepciones:**
- Ninguna registrada.

**Estado validación:** Verificado fuente líneas 109000-111300

---

## RN-S500-526 — Registro de aplicado S111 de longitud fija de 40 caracteres

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-526 |
| **Nombre** | Registro de aplicado S111 de longitud fija de 40 caracteres |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-06 |
| **bian_ref** | 6.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P179 (S500P179) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El contrato de interfaz de movimientos aplicados entre S500 y S111 es un registro de longitud fija de 40 caracteres (`PIC X(040)`) tanto para MTY como para VDM. La longitud fija es el contrato de datos entre sistemas MCP; cualquier modernización debe preservar o mapear explícitamente este layout.

**Fórmula/pseudocódigo:**
```
01 I01-REG-S111-APLICADO-MTY PIC X(040).
01 I01-REG-S111-APLICADO-VDM PIC X(040).
```

**Vocabulario en la fórmula:** I01-REG-S111-APLICADO-MTY · I01-REG-S111-APLICADO-VDM · X(040)

**Excepciones:**
- El registro es opaco (X(40)); su estructura interna se define en el copybook del S111, no en P179.

**Estado validación:** Verificado fuente líneas 106100-107100 (FD)

---

## RN-S500-527 — Validación de cuadre de trailer del archivo S111 (número de registros e importe bruto)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-527 |
| **Nombre** | Validación de cuadre de trailer del archivo S111 (número de registros e importe bruto) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar un archivo de entrada (S111 diario o semanal), el programa valida el trailer comparando el número de registros leídos contra el número declarado en el trailer y la suma de importes brutos acumulada contra el importe bruto del trailer. Cualquier diferencia marca error de trailer y detona el mensaje de descuadre. Es el control de integridad que impide procesar un archivo truncado o corrupto hacia estados de cuenta.

**Fórmula/pseudocódigo:**
```
IF (WS-INTRAIL-NUMREG-E   NOT = REG-LEIDOS)
OR (WS-INTRAIL-IMPBRUTO-E NOT = WS-SUM-TOT-BRUTO)
   MOVE 1 TO WS-ERROR-TRAILER
   STRING " DETALLE Y TRAI. DIF ARC. " ... (reporta cifras)
```

**Vocabulario en la fórmula:** WS-INTRAIL-NUMREG-E · REG-LEIDOS · WS-INTRAIL-IMPBRUTO-E · WS-SUM-TOT-BRUTO

**Excepciones:**
- Ver RN-S500-528: existe un bypass condicionado por rango de fechas y por autorización manual.

**Estado validación:** Verificado fuente líneas 612800-615510 (párrafo 50002452-VAL-TRAILER-S111)

---

## RN-S500-528 — Bypass de validación de trailer por ventana de fechas hardcodeada (2011-12-01 a 2011-12-07)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-528 |
| **Nombre** | Bypass de validación de trailer por ventana de fechas hardcodeada (2011-12-01 a 2011-12-07) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el trailer no cuadra (RN-S500-527), el programa evalúa la fecha de proceso: si cae dentro de la ventana codificada `20111201 < WS-FECHA-PRO < 20111207` omite silenciosamente el error de trailer y continúa el proceso sin pedir autorización. Es un parche histórico embebido que sigue vivo en el código y representa un riesgo latente: cualquier corrida con fecha de proceso manipulada a ese rango salta el control de integridad de estados de cuenta.

**Fórmula/pseudocódigo:**
```
50002454-MSG-TRAI-ERROR.
   IF WS-FECHA-PRO > 20111201 AND WS-FECHA-PRO < 20111207
      NEXT SENTENCE                (bypass silencioso)
   ELSE
      ... solicita autorización manual (ver RN-S500-529)
```

**Vocabulario en la fórmula:** WS-FECHA-PRO · 20111201 · 20111207 · WS-ERROR-TRAILER

**Excepciones:**
- La ventana de 2011 nunca fue removida; es un [BUG-LATENTE] de control regulatorio.

**Estado validación:** Verificado fuente líneas 615532-615560 (párrafo 50002454-MSG-TRAI-ERROR)

---

## RN-S500-529 — Anulación manual del control de trailer con captura de SOEID autorizador

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-529 |
| **Nombre** | Anulación manual del control de trailer con captura de SOEID autorizador |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [SILENCIOSO-CRÍTICO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Fuera de la ventana hardcodeada, ante un trailer descuadrado el operador puede autorizar el procesamiento respondiendo `SI` a la pregunta interactiva y capturando el SOEID de quien autoriza; el SOEID queda registrado en bitácora. Si responde distinto de `SI`, el proceso se detiene. Es un control de segregación de funciones que permite procesar datos no cuadrados bajo responsabilidad nominal, pero depende de intervención humana en batch.

**Fórmula/pseudocódigo:**
```
STRING "¿DESEA PROCESAR SIN VALIDAR TRAILER (SI/NO)?"
ACCEPT WS-SINO
IF WS-SINO = "SI"
   ACCEPT WS-SOEID-VOBO-TRAILER    (SOEID del autorizador)
   registra "EL SOEID DE QUIEN AUTORIZO ... ES: " WS-SOEID-VOBO-TRAILER
ELSE
   DMTERMINATE
```

**Vocabulario en la fórmula:** WS-SINO · WS-SOEID-VOBO-TRAILER · DMTERMINATE

**Excepciones:**
- El proceso requiere entrada interactiva (`ACCEPT`); en ejecución desatendida quedaría bloqueado esperando respuesta.

**Estado validación:** Verificado fuente líneas 615600-615726 (párrafo 50002454-MSG-TRAI-ERROR)

---

## RN-S500-530 — Validación de sistema interno en el header del archivo (S111 y EAS/ECMS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-530 |
| **Nombre** | Validación de sistema interno en el header del archivo (S111 y EAS/ECMS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa valida en el header que el sistema interno emisor sea el esperado: para el flujo S111 el identificador de control debe ser literal `"S111"`, y para el flujo EAS/ECMS diario el código de sistema debe ser `175172`. Si el sistema no coincide se emite mensaje de "SIS. INT. DIFERENTE" y, junto con la fecha de header, se exige inyectar un archivo con header correcto. Impide procesar un archivo del sistema equivocado hacia estados de cuenta.

**Fórmula/pseudocódigo:**
```
IF WS-INTCTL-ID-UNO = "S111"   → MOVE 1 TO WS-HEA-SIS-D
ELSE  "SIS. INT. DIFERENTE DE S111"
IF EAS-R01-SISTEMA = 175172    → MOVE 1 TO WS-HEA-SIS-D
ELSE  "SIS. INT. DIFERENTE DE EAS DIARIO"
IF WS-HEA-FEC-D = 0 OR WS-HEA-SIS-D = 0 → "ARCH CON HEADER ERRONEO"
```

**Vocabulario en la fórmula:** WS-INTCTL-ID-UNO · EAS-R01-SISTEMA · 175172 · WS-HEA-SIS-D · WS-HEA-FEC-D

**Excepciones:**
- El código de sistema EAS `175172` está hardcodeado [HARDCODE-IMPLÍCITO].
- La instrucción `DMTERMINATE` está comentada: un header erróneo ya no aborta, solo pide reinyección manual.

**Estado validación:** Verificado fuente líneas 538010-541010 y 559254-559360

---

## RN-S500-531 — Distinción de flujo diario vs semanal de tarjetas (TARJETADIA)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-531 |
| **Nombre** | Distinción de flujo diario vs semanal de tarjetas (TARJETADIA) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa distingue el ciclo de procesamiento por el nombre del data set: si el data set es `"TARJETADIA"` el archivo es diario del S111, de lo contrario es semanal. Esta distinción etiqueta los mensajes de error de trailer y selecciona las fechas de control diario vs semanal, reflejando que el estado de cuenta se alimenta de dos cadencias distintas.

**Fórmula/pseudocódigo:**
```
IF WS-TAR-DS = "TARJETADIA"
   MOVE "DIARIO S111"  TO WS-TIT-ARCH-TRAI-ERROR
ELSE
   MOVE "SEMANAL S111" TO WS-TIT-ARCH-TRAI-ERROR
```

**Vocabulario en la fórmula:** WS-TAR-DS · TARJETADIA · WS-SEMANAL · WS-FECHA-DIARIO · WS-FECHA-SEMANAL

**Excepciones:**
- El literal `"TARJETADIA"` es un [HARDCODE-IMPLÍCITO] que ancla la clasificación diario/semanal.

**Estado validación:** Verificado fuente líneas 612820-612880 y 130010-131010

---

## RN-S500-532 — Doble fuente de estado de cuenta: S111 (tarjetas) y EAS/ECMS

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-532 |
| **Nombre** | Doble fuente de estado de cuenta: S111 (tarjetas) y EAS/ECMS |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P335 (PROGRAM-ID S500P400) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El proceso de estado de cuenta integra dos fuentes de movimientos: el archivo de tarjetas del S111 y el archivo EAS/ECMS (banca electrónica), cada uno con su propia validación de trailer y de sistema interno. La bandera `WS-INT-CONTROL` (88 ARCH-S111 = 1, 88 ARCH-ECMS = 2) enruta el registro a la rutina de validación correspondiente. El estado de cuenta del cliente consolida ambos canales.

**Fórmula/pseudocódigo:**
```
88 ARCH-S111 VALUE 1
88 ARCH-ECMS VALUE 2
IF ARCH-S111 PERFORM 50002452-VAL-TRAILER-S111
ELSE IF ARCH-ECMS PERFORM 50002451-VAL-TRAILER-EAS
```

**Vocabulario en la fórmula:** ARCH-S111 · ARCH-ECMS · EAS · S111 · VAL-TRAILER

**Excepciones:**
- Cada fuente debe cuadrar de forma independiente antes de consolidar el estado de cuenta.

**Estado validación:** Verificado fuente líneas 173738-173740 y 612580-612640

---

## RN-S500-533 — Estructura jerárquica del estado de cuenta CPE (grupo, subgrupo, cuenta) con tipos de registro

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-533 |
| **Nombre** | Estructura jerárquica del estado de cuenta CPE (grupo, subgrupo, cuenta) con tipos de registro |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El estado de cuenta de Cuenta Productiva Especial se genera con una jerarquía de tres niveles (grupo B37, subgrupo/cliente B38, cuenta B39) barriendo el data set B39CTASCPE. Cada nivel emite registros tipados: header y total por grupo (700000/709000), header y total por cliente-subgrupo (701110/701119), y detalle de cuenta. Los totales se acumulan de cuenta → subgrupo → grupo, produciendo un estado de cuenta consolidado por corporativo.

**Fórmula/pseudocódigo:**
```
PERFORM 200-GENERA-EDOCTA UNTIL EOF-B39
   240-GRABA-POR-SGRUPO  → RHC 701110 / RTC 701119
   detalle cuenta (B39)  → acumula WKS-*-X-CTE
   total grupo           → RTG 709000
tipos: 700000 grupo · 701110/701119 cliente · 709000 total
```

**Vocabulario en la fórmula:** B37-GRUPO · B38-SUB-GPO · B39CTASCPE · ED1-ARCHED1 · RTC/RTG/RHC

**Excepciones:**
- Cuentas sin subgrupo se etiquetan `SIN SUB-GRUPO` (bandera NO-EXIS-SGPO).

**Estado validación:** Verificado fuente líneas 176600-180080 (párrafo 240-GRABA-POR-SGRUPO)

---

## RN-S500-534 — Retención de ISR sobre rendimientos conforme tasa Artículo 152 LISR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-534 |
| **Nombre** | Retención de ISR sobre rendimientos conforme tasa Artículo 152 LISR |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | SAT (LISR) |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El estado de cuenta refleja la retención de ISR sobre los rendimientos de la cuenta usando la tasa y el importe retenido del registro B39 correspondientes al Artículo 152 de la Ley del ISR (`B39-TASA-ISR-152`, `B39-ISR-RET-152`). El importe de ISR retenido se muestra en el detalle de cuenta y se acumula para el reporte fiscal del cliente. Es la materialización de la obligación del banco como retenedor de ISR sobre intereses.

**Fórmula/pseudocódigo:**
```
MOVE B39-TASA-ISR-152 TO RDC-TASA-ISR
MOVE B39-ISR-RET-152  TO RDC-SDO-ISR
ADD  RDC-SDO-ISR      TO WKS-SDISR-X-CTE, WKS-SDISR-X-GPO, WKS-SDISR-X-GRL
```

**Vocabulario en la fórmula:** B39-TASA-ISR-152 · B39-ISR-RET-152 · RDC-TASA-ISR · WKS-SDISR-X-CTE

**Excepciones:**
- Existe código comentado que sumaba `B39-TASA-ISR-500 + B39-TASA-ISR-152`; la versión vigente usa solo la tasa 152 (ver RN-S500-538).

**Estado validación:** Verificado fuente líneas 174600-175200 (párrafo de detalle de cuenta)

---

## RN-S500-535 — IVA sobre comisiones de cheques y giros a dos tasas (10% zona fronteriza y 15% resto)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-535 |
| **Nombre** | IVA sobre comisiones de cheques y giros a dos tasas (10% zona fronteriza y 15% resto) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-FISCAL-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | SAT (LIVA) |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El estado de cuenta desglosa el IVA cobrado sobre las comisiones de cheques y giros en dos tasas paralelas: 10% y 15%. Los importes de comisión e IVA a cada tasa se toman de B37 (`B37-COMIS-10`/`B37-IVA-10` y `B37-COMIS-15`/`B37-IVA-15`) y se acumulan por separado. Las dos tasas corresponden históricamente al régimen de IVA de zona fronteriza (10%) frente al resto del país (15%).

**Fórmula/pseudocódigo:**
```
MOVE B37-COMIS-10 TO RTG-TOT-CHQ-GIR-10P : ADD B37-COMIS-10 TO WKS-CHQ-GIR-10P
MOVE B37-IVA-10   TO RTG-IVA-CHQ-GIR-10P : ADD B37-IVA-10   TO WKS-IVA-GIR-10P
MOVE B37-COMIS-15 TO RTG-TOT-CHQ-GIR-15P : ADD B37-COMIS-15 TO WKS-CHQ-GIR-15P
MOVE B37-IVA-15   TO RTG-IVA-CHQ-GIR-15P : ADD B37-IVA-15   TO WKS-IVA-GIR-15P
```

**Vocabulario en la fórmula:** B37-IVA-10 · B37-IVA-15 · B37-COMIS-10 · B37-COMIS-15 · WKS-IVA-GIR-10P

**Excepciones:**
- Las tasas 10% y 15% están fijadas por campo separado [HARDCODE-IMPLÍCITO]; un cambio de tasa IVA (p.ej. 16%) requiere ajuste de campos y de la lógica de acumulación.

**Estado validación:** Verificado fuente líneas 168100-168800 (párrafo total por grupo)

---

## RN-S500-536 — Producto neto del periodo como productos menos comisiones, con signo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-536 |
| **Nombre** | Producto neto del periodo como productos menos comisiones, con signo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada nivel de la jerarquía (cuenta, subgrupo, grupo) el estado de cuenta presenta el producto neto del periodo. Cuando el neto es negativo (las comisiones superan a los productos generados) se marca con signo `"-"` en el campo de despliegue. El signo explícito permite que el cliente lea correctamente un periodo con cargo neto de comisiones.

**Fórmula/pseudocódigo:**
```
MOVE WKS-PNETO-X-GPO TO RTG-PROD-NETOS
MOVE SPACES          TO RTG-SIGNO
IF WKS-PNETO-X-GPO < 0
   MOVE "-"          TO RTG-SIGNO
```

**Vocabulario en la fórmula:** WKS-PNETO-X-GPO · WKS-PRODS-X-GPO · WKS-COMIS-X-GPO · RTG-SIGNO

**Excepciones:**
- El neto se despliega en valor absoluto más signo separado, no como número con signo embebido.

**Estado validación:** Verificado fuente líneas 167400-167900 y 179600-179900

---

## RN-S500-537 — Acumulación de ISR retenido en tres niveles (cuenta, grupo, general)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-537 |
| **Nombre** | Acumulación de ISR retenido en tres niveles (cuenta, grupo, general) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | SAT (LISR) |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El ISR retenido de cada cuenta (RN-S500-534) se suma simultáneamente a tres acumuladores: por cuenta (`WKS-SDISR-X-CTE`), por grupo (`WKS-SDISR-X-GPO`) y general (`WKS-SDISR-X-GRL`). Esto entrega, en una sola pasada, el ISR retenido a nivel cuenta, el consolidado del corporativo y el gran total, cifras que deben cuadrar contra la declaración informativa al SAT.

**Fórmula/pseudocódigo:**
```
ADD RDC-SDO-ISR TO WKS-SDISR-X-CTE
                   WKS-SDISR-X-GPO
                   WKS-SDISR-X-GRL
MOVE WKS-SDISR-X-CTE TO RTC-SDO-ISR   (total por cuenta)
```

**Vocabulario en la fórmula:** WKS-SDISR-X-CTE · WKS-SDISR-X-GPO · WKS-SDISR-X-GRL · RTC-SDO-ISR

**Excepciones:**
- El descuadre entre la suma de niveles indicaría error de acumulación fiscal.

**Estado validación:** Verificado fuente líneas 175000-175200 y 180000

---

## RN-S500-538 — Código fiscal versionado: tasa ISR-500 vs ISR-152 (lógica desactivada por comentario)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-538 |
| **Nombre** | Código fiscal versionado: tasa ISR-500 vs ISR-152 (lógica desactivada por comentario) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | SAT (LISR) |
| **Programa ejecutor** | P400 (PROGRAM-ID P335-EDOCTA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa contiene lógica comentada que combinaba dos tasas de ISR (`B39-TASA-ISR-500 + B39-TASA-ISR-152`) y su condicional de precedencia, ahora reemplazada por el uso exclusivo de la tasa 152. También está comentada una salvaguarda que ponía el ISR en cero cuando los productos netos no superaban al ISR retenido. Es evidencia de una migración de régimen fiscal donde reglas antiguas quedaron latentes en el fuente y deben limpiarse en modernización.

**Fórmula/pseudocódigo:**
```
*** COMPUTE RDC-TASA-ISR = B39-TASA-ISR-500 + B39-TASA-ISR-152   (desactivado)
*** IF B39-TASA-ISR-500 > 0 MOVE B39-TASA-ISR-500 ... ELSE       (desactivado)
    MOVE B39-TASA-ISR-152 TO RDC-TASA-ISR                        (vigente)
*** IF RDC-SIGNO = "-" AND WKS-PROD-NETOS NOT > RDC-SDO-ISR
***    MOVE ZEROS TO RDC-SDO-ISR                                 (desactivado)
```

**Vocabulario en la fórmula:** B39-TASA-ISR-500 · B39-TASA-ISR-152 · RDC-SDO-ISR · WKS-PROD-NETOS

**Excepciones:**
- El código muerto puede reactivarse por error; representa deuda técnica fiscal [BUG-LATENTE].

**Estado validación:** Verificado fuente líneas 174600-174960 (bloques comentados)

---

## RN-S500-539 — Extracción del saldo promedio del ciclo 12 del histórico B06 hacia el S084

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-539 |
| **Nombre** | Extracción del saldo promedio del ciclo 12 del histórico B06 hacia el S084 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P185 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa genera el archivo de saldos promedios para el S084 tomando, de cada contrato del histórico B06, el saldo promedio del ciclo 12 (`B06-PROM-CICLO(12)`), que corresponde al promedio del periodo más reciente/completo del arreglo de doce ciclos. El registro de salida acompaña el saldo con contrato, producto, instrumento y moneda tomados de B03.

**Fórmula/pseudocódigo:**
```
50001500-GEN-ARCHIVO.
   MOVE B06-PROM-CICLO(12) TO WKS-E04-R02-SDOPROM
   MOVE B03-NUM-CONTRATO   TO WKS-E04-R02-CONTRATO
   MOVE B03-NUM-PRODUCTO   TO WKS-E04-R02-PRODUCTO
   MOVE B03-NUM-INSTRUM    TO WKS-E04-R02-INSTRUM
   MOVE B03-MONEDA         TO WKS-E04-R02-MONEDA
```

**Vocabulario en la fórmula:** B06-PROM-CICLO · WKS-E04-R02-SDOPROM · B03-NUM-CONTRATO · S084

**Excepciones:**
- El índice fijo `(12)` [HARDCODE-IMPLÍCITO] asume que el ciclo 12 es el promedio a reportar; el arreglo B06 mantiene 12 ciclos rotatorios.

**Estado validación:** Verificado fuente líneas 176100-176900 (párrafo 50001500-GEN-ARCHIVO)

---

## RN-S500-540 — Etiquetado de origen y destino del archivo de promedios (sistema 0500 → 0084)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-540 |
| **Nombre** | Etiquetado de origen y destino del archivo de promedios (sistema 0500 → 0084) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P185 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El header del archivo de promedios fija sistema origen `0500` (captación S500) y sistema destino `0084` (S084), más el CSI de origen y la fecha de movimiento. Este ruteo declarativo permite al S084 validar la procedencia del archivo antes de consumir los saldos promedio.

**Fórmula/pseudocódigo:**
```
WKS-E04-R01-SISORI VALUE 0500   (origen S500)
WKS-E04-R01-SISDES VALUE 0084   (destino S084)
WKS-E04-R01-CSIORIG · WKS-E04-R01-FEC-MOVTO
```

**Vocabulario en la fórmula:** WKS-E04-R01-SISORI · WKS-E04-R01-SISDES · 0500 · 0084

**Excepciones:**
- Los códigos de sistema 0500/0084 son literales [HARDCODE-IMPLÍCITO] del contrato entre subsistemas.

**Estado validación:** Verificado fuente líneas 120100-120900 (header E04-R01)

---

## RN-S500-541 — Cifras de control del archivo de promedios (total de registros e importe total)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-541 |
| **Nombre** | Cifras de control del archivo de promedios (total de registros e importe total) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P185 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A medida que escribe cada registro de promedio, el programa acumula el total de registros (`WKS-E04-R09-TOTREGS`) y la suma de saldos promedio (`WKS-E04-R09-TOTDSOS`) para el trailer de control. El S084 usa estas cifras para verificar que recibió el archivo completo y cuadrado.

**Fórmula/pseudocódigo:**
```
ADD 1                   TO WKS-E04-R09-TOTREGS
ADD WKS-E04-R02-SDOPROM TO WKS-E04-R09-TOTDSOS
PERFORM 50001550-ESC-ARCHS084
```

**Vocabulario en la fórmula:** WKS-E04-R09-TOTREGS · WKS-E04-R09-TOTDSOS · WKS-E04-R02-SDOPROM

**Excepciones:**
- Ninguna; el trailer siempre refleja lo escrito en el detalle.

**Estado validación:** Verificado fuente líneas 177100-177500

---

## RN-S500-542 — Límite de 30 instrumentos por base carga de tabla B05 en memoria

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-542 |
| **Nombre** | Límite de 30 instrumentos por base carga de tabla B05 en memoria |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P185 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al cargar en memoria el catálogo de instrumentos (B05) que define qué saldos se envían al S084, el programa aborta con `DMTERMINATE` si encuentra más de 30 instrumentos, ya que la tabla interna tiene capacidad fija de 30 entradas. Es un límite estructural: exceder 30 instrumentos configurados rompe el proceso de promedios.

**Fórmula/pseudocódigo:**
```
ADD 1 TO W77-IND-INST
IF W77-IND-INST > 30
   STRING "MAS DE 30 INSTRUMENTOS EN LA BASE; IND-INSTRUM: " W77-IND-INST
   PERFORM 70000050-MENSAJE
   CALL SYSTEM DMTERMINATE
```

**Vocabulario en la fórmula:** W77-IND-INST · WKS-TB05-NUM-INST · B05-ENV-SDOP-S084 · DMTERMINATE

**Excepciones:**
- El límite `30` es un [HARDCODE-SOSPECHOSO]: acoplado al tamaño de la tabla, no configurable; un producto nuevo con muchos instrumentos detendría el ciclo de promedios.

**Estado validación:** Verificado fuente líneas 153100-155500 (párrafo 20000155-B05-A-MEMORIA)

---

## RN-S500-543 — Inventario impreso de grupos CPE con ficha de identificación del corporativo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-543 |
| **Nombre** | Inventario impreso de grupos CPE con ficha de identificación del corporativo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P184 (P184-INVCPE) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa produce, vía Report Writer, el inventario de Cuentas Productivas Especiales recorriendo el data set de grupos B37GRUPOCPE. Por cada grupo imprime su ficha de identificación: número de grupo, nombre, ciudad, código postal, representante, domicilio, tipo de persona, contrato y sucursal de cargo de pago, y fechas de vigencia y última actualización. Es el catálogo de control de los corporativos CPE exigible ante revisión regulatoria.

**Fórmula/pseudocódigo:**
```
RD INVENTACPE CONTROLS ARE FINAL
PERFORM UNTIL FIN-B37-GRUPOS
   READ B37GRUPOCPE
   GENERATE detalle-grupo (B37-GRUPO, B37-NOMBRE, B37-CIUDAD,
            B37-COD-POSTAL, B37-REPRES, B37-CTO-PAGO, B37-FECH-VIG ...)
```

**Vocabulario en la fórmula:** B37GRUPOCPE · B37-GRUPO · B37-CTO-PAGO · B37-FECH-VIG · INVENTACPE

**Excepciones:**
- Reporte de solo lectura; no altera bases.

**Estado validación:** Verificado fuente líneas 101900-126700 (RD INVENTACPE y detalle B37)

---

## RN-S500-544 — Desglose de cuentas por grupo CPE (relación B37 grupo → B39 cuentas)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-544 |
| **Nombre** | Desglose de cuentas por grupo CPE (relación B37 grupo → B39 cuentas) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | CNBV |
| **Programa ejecutor** | P184 (P184-INVCPE) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Bajo cada grupo, el inventario lista las cuentas asociadas leyendo el data set B39CTASCPE, mostrando nombre y tipo de persona de cada cuenta subordinada. Esto materializa la relación jerárquica corporativo (B37) → cuentas miembro (B39) que sustenta la agregación del estado de cuenta CPE (ver RN-S500-533).

**Fórmula/pseudocódigo:**
```
PERFORM UNTIL FIN-B39-CTAS
   READ B39CTASCPE (de este grupo)
   GENERATE detalle-cuenta (B39-NOMBRE, B39-TPO-PERS ...)
```

**Vocabulario en la fórmula:** B39CTASCPE · B39-NOMBRE · B39-TPO-PERS · FIN-B39-CTAS

**Excepciones:**
- Un grupo sin cuentas B39 se imprime solo con su ficha de grupo.

**Estado validación:** Verificado fuente líneas 102100 y 127900-127950 (detalle B39)

---

## RN-S500-545 — Formato paginado del inventario CPE con fecha de saldos y contador de página

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-545 |
| **Nombre** | Formato paginado del inventario CPE con fecha de saldos y contador de página |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-07 |
| **bian_ref** | 6.1.4 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Interno |
| **Programa ejecutor** | P184 (P184-INVCPE) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El inventario CPE se emite con formato de página fija (58 líneas, primer detalle en línea 11, último en 56) mediante Report Writer, imprimiendo en el encabezado la fecha de saldos y el contador de página, y sellando la fecha de máquina (`NUMERIC-DATE`). Este formato estandariza el documento de control para archivo físico y auditoría.

**Fórmula/pseudocódigo:**
```
RD INVENTACPE CONTROLS ARE FINAL
   PAGE LIMIT 58 · HEADING 1 · FIRST DETAIL 11 · LAST DETAIL 56 · FOOTING 58
PH: "FECHA SALDOS:" ...  PAGE-COUNTER
WKS-FECHA-MAQUINA TYPE IS NUMERIC-DATE
```

**Vocabulario en la fórmula:** INVENTACPE · PAGE-COUNTER · FECHA SALDOS · WKS-FECHA-MAQUINA

**Excepciones:**
- Los límites de página (58/11/56) son [HARDCODE-IMPLÍCITO] ligados al formato de impresión.

**Estado validación:** Verificado fuente líneas 119400-122700 (RD y PH)

---

## RN-S500-546 — Estructura de la CLABE de 18 dígitos como llave de destino de pago SPEI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-546 |
| **Nombre** | Estructura de la CLABE de 18 dígitos como llave de destino de pago SPEI |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de pagos que el S500 envía a los sistemas de pago porta la CLABE (Clave Bancaria Estandarizada) del destino como un entero de 18 dígitos (`PIC 9(18)`), tanto en el registro de pago primario (`PAGO1-CLABE`) como en el secundario (`PAGO2-CLABE`). La CLABE de 18 posiciones es el estándar Banxico que codifica banco (3), plaza (3), cuenta (11) y dígito de control (1); es la llave de ruteo para la dispersión SPEI.

**Fórmula/pseudocódigo:**
```
02 PAGO1-CLABE PIC 9(18).
02 PAGO2-CLABE PIC 9(18).
* estructura CLABE: BBB PPP CCCCCCCCCCC D
*   BBB = banco · PPP = plaza · C(11) = cuenta · D = dígito verificador
```

**Vocabulario en la fórmula:** PAGO1-CLABE · PAGO2-CLABE · CLABE · SPEI

**Excepciones:**
- El campo almacena la CLABE como numérico de 18; el programa la transporta pero el dígito verificador se valida aguas arriba en la captura/dispersión, no en P165 (resultado).

**Estado validación:** Verificado fuente líneas 026803 (PAGO1-CLABE) y 120256 (PAGO2-CLABE)

---

## RN-S500-547 — Clasificación de movimientos de dispersión en abonos, cargos, reembolsos y no contables por clave de transacción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-547 |
| **Nombre** | Clasificación de movimientos de dispersión en abonos, cargos, reembolsos y no contables por clave de transacción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa clasifica cada movimiento dispersado según su clave de transacción de 4 dígitos en cuatro familias mutuamente excluyentes: no contables (1 a 999), abonos (1000-1113, 1116-1999, 3000-3999 y 527), reembolsos (1114, 1115) y cargos (2000-2999, 4000-4999 y claves puntuales 526, 577, 584, 585, 613, 615, 694, 700, 701, 712). Esta clasificación determina si el importe suma a entradas (abonos/reembolsos) o salidas (cargos) en las cifras de la dispersión.

**Fórmula/pseudocódigo:**
```
01 WS-CLAVE-TRAN PIC 9(04).
   88 NOCONTAB VALUE 1 THRU 999.
   88 ABONOS   VALUE 1000 THRU 1113, 1116 THRU 1999, 3000 THRU 3999, 527.
   88 REMBOLSO VALUE 1114, 1115.
   88 CARGOS   VALUE 2000 THRU 2999, 4000 THRU 4999,
                     526,577,584,585,613,615,694,700,701,712.
```

**Vocabulario en la fórmula:** WS-CLAVE-TRAN · NOCONTAB · ABONOS · REMBOLSO · CARGOS

**Excepciones:**
- Los rangos y claves puntuales son un [HARDCODE-SOSPECHOSO] de amplitud considerable; añadir una nueva clave de transacción exige tocar estos rangos o el movimiento quedará mal clasificado.
- Las claves 1114/1115 se separan como reembolso pese a caer en el rango de abonos.

**Estado validación:** Verificado fuente líneas 129010-129620 (nivel 88 de WS-CLAVE-TRAN)

---

## RN-S500-548 — Estatus de operación de la dispersión: aceptado (TIPERROR = 2) vs rechazado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-548 |
| **Nombre** | Estatus de operación de la dispersión: aceptado (TIPERROR = 2) vs rechazado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada movimiento de la dispersión trae un indicador de tipo de error; el valor `TIPERROR = 2` significa operado/aceptado, cualquier otro valor significa rechazado. Con base en este indicador el programa acumula el importe en los contadores de aceptados (`IMPACEP`) o de rechazados (`IMPRECH`), cruzando con su naturaleza de abono o cargo (RN-S500-547) y con su prioridad. Es la regla que separa lo que efectivamente se dispersó de lo que se devolvió.

**Fórmula/pseudocódigo:**
```
53211400-ACUMULA-ACEPRECH.
  IF ORDENADO-TB-TIPERROR = 2                       (aceptado)
     IF ABONOS OR REMBOLSO → ADD importe TO WS-ENT-IMPACEP(prioridad)
     IF CARGOS             → ADD importe TO WS-SAL-IMPACEP(prioridad)
  ELSE                                              (rechazado)
     IF ABONOS OR REMBOLSO → ADD importe TO WS-ENT-IMPRECH(prioridad)
     IF CARGOS             → ADD importe TO WS-SAL-IMPRECH(prioridad)
```

**Vocabulario en la fórmula:** ORDENADO-TB-TIPERROR · WS-ENT-IMPACEP · WS-SAL-IMPRECH · WS-IND1 (prioridad)

**Excepciones:**
- El valor `2` como código de "aceptado" es un [HARDCODE-IMPLÍCITO].

**Estado validación:** Verificado fuente líneas 760210-767410 (párrafo 53211400-ACUMULA-ACEPRECH)

---

## RN-S500-549 — Ruteo de rechazos por producto e instrumento (tarjetas/contabilidad vs ahorros)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-549 |
| **Nombre** | Ruteo de rechazos por producto e instrumento (tarjetas/contabilidad vs ahorros) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los movimientos rechazados (TIPERROR distinto de 2) se enrutan a un reporte según producto e instrumento: productos 66, 1, o 500 con instrumento 1 van al reporte general de rechazos; producto 500 con instrumento 6 (ahorros) va al listado de rechazos de ahorros del S087. Solo se imprimen los que efectivamente fueron rechazados (`TIPERROR NOT = 2`). Separa la devolución de dispersión por línea de producto para su reproceso.

**Fórmula/pseudocódigo:**
```
53211000-VALIDA-STACVE.
  IF (PRODUCTO = 66 OR 1 OR (PRODUCTO = 500 AND INSTRUM = 1))
     AND TIPERROR NOT = 2 → 53211200-IMPRIME-RECHAZOS
  ELSE IF TIPERROR NOT = 2 AND PRODUCTO = 500 AND INSTRUM = 6
     → 53211300-GRABO-AHORROS
```

**Vocabulario en la fórmula:** ORDENADO-TB-PRODUCTO · ORDENADO-TB-INSTRUM · TIPERROR · S087

**Excepciones:**
- Instrumento 6 = ahorros [HARDCODE-IMPLÍCITO]; instrumento 1 = cuenta contable/tarjeta.

**Estado validación:** Verificado fuente líneas 681010-684610 (párrafo 53211000-VALIDA-STACVE)

---

## RN-S500-550 — Reembolsos con reporte de rechazos independiente por clave de transacción

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-550 |
| **Nombre** | Reembolsos con reporte de rechazos independiente por clave de transacción |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los movimientos clasificados como reembolso (claves 1114, 1115) que resultan rechazados se imprimen en un reporte separado (`RECHAZOREMBOL`), agrupado y totalizado por clave de transacción con cambio de control cuando cambia la clave. Los demás rechazos van al reporte estándar de dispersión agrupado por prioridad. Distingue los reembolsos por su tratamiento contable diferenciado.

**Fórmula/pseudocódigo:**
```
53211200-IMPRIME-RECHAZOS.
  IF REMBOLSO → 53211204-IMPRIME-RECHAREMBOLSO   (agrupa por WS-CLAVE-TRAN)
  ELSE        → 53211208-IMPRIME-RECHAZOS1       (agrupa por prioridad)
* control break: IF WS-CLAVE-TRAN NOT = WS-CLAVE-TRAN-ANT → total + nuevo encabezado
```

**Vocabulario en la fórmula:** REMBOLSO · WS-CLAVE-TRAN-ANT · RECHAZOREMBOL · WS-PRIORIDAD-ANT

**Excepciones:**
- El nombre del reporte cambia según WS-VAL-165 (1 vs 2): `RECHAZOREMBO1` para el flujo intermedio y `RECHAZOREMBOL` para el final.

**Estado validación:** Verificado fuente líneas 686710-693810 (párrafos 53211200/53211204/53211208)

---

## RN-S500-551 — Separación de cifras de rechazo en dólares vs moneda nacional por prioridad

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-551 |
| **Nombre** | Separación de cifras de rechazo en dólares vs moneda nacional por prioridad |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al totalizar los importes rechazados, el programa separa las cifras en dólares y moneda nacional según la prioridad del movimiento: las prioridades 8, 10, 11, 19 y 21 corresponden a operaciones en dólares (cuentas maestras dólar y autorizaciones dólar) y se acumulan en `WS-TOTAL-IMPRECHDL`; el resto se acumula en `WS-TOTAL-IMPRECH` (moneda nacional). Esta bifurcación es requisito para cuadrar la dispersión por moneda ante Banxico.

**Fórmula/pseudocódigo:**
```
IF ORDENADO-TB-PRIORIDAD = 8 OR 10 OR 11 OR 19 OR 21
   ADD 1                  TO WS-TOTAL-NUMRECHDL
   ADD IMPORTE, IMPORTE2, IMP-AUT TO WS-TOTAL-IMPRECHDL   (dólares)
ELSE
   ADD 1                  TO WS-TOTAL-NUMRECH
   ADD IMPORTE, IMPORTE2, IMP-AUT TO WS-TOTAL-IMPRECH     (moneda nacional)
```

**Vocabulario en la fórmula:** ORDENADO-TB-PRIORIDAD · WS-TOTAL-IMPRECHDL · WS-TOTAL-IMPRECH · IMP-AUT

**Excepciones:**
- El conjunto de prioridades dólar {8,10,11,19,21} está hardcodeado [HARDCODE-SOSPECHOSO]; documentado en la tabla de prioridades (CTAM DOL, AUT DOL).

**Estado validación:** Verificado fuente líneas 732310-734600 y tabla de prioridades 759620-759740

---

## RN-S500-552 — Tipo de cambio Banxico como factor de conversión de operaciones en dólares

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-552 |
| **Nombre** | Tipo de cambio Banxico como factor de conversión de operaciones en dólares |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO por SME Regulatorio (triaje 2026-07) — Banxico tipo de cambio FIX, valuación ME (6 decimales) — 🟡 |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro ordenado de la dispersión porta el tipo de cambio Banxico (`ORDENADO-TB-TC-BANXICO`, `PIC 9(05)V9(06)`), con cinco enteros y seis decimales de precisión, usado para valorizar las operaciones en dólares al peso. La precisión de seis decimales atiende el requerimiento Banxico de aplicar el tipo de cambio FIX publicado para valuación de operaciones en moneda extranjera.

**Fórmula/pseudocódigo:**
```
05 ORDENADO-TB-TC-BANXICO PIC 9(05)V9(06).
* valor_MN = importe_USD * TC-BANXICO   (aplicado en valuación de dispersión)
```

**Vocabulario en la fórmula:** ORDENADO-TB-TC-BANXICO · importe USD · tipo de cambio FIX

**Excepciones:**
- La precisión 9(05)V9(06) es un contrato de dato rígido; un tipo de cambio con más de 5 enteros (hiperdevaluación) desbordaría el campo [BUG-LATENTE].

**Estado validación:** Verificado fuente líneas 048040 y 149365 (definición TC-BANXICO)

---

## RN-S500-553 — Exclusión de claves 700, 701, 613 y 615 del listado de rechazos de tarjetas contables

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-553 |
| **Nombre** | Exclusión de claves 700, 701, 613 y 615 del listado de rechazos de tarjetas contables |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al imprimir el detalle de rechazos, el programa excluye explícitamente las claves de transacción 700, 701, 613 y 615: para estas claves no genera línea en el reporte de rechazos de tarjetas contables (prioridades 4, 14, 15, 17), saltando al siguiente movimiento. Son claves cuyo tratamiento de devolución se maneja por otro canal, pero la exclusión hardcodeada puede ocultar rechazos si el catálogo cambia.

**Fórmula/pseudocódigo:**
```
IF WS-CLAVE-TRAN = 700 OR 701 OR 613 OR 615
   NEXT SENTENCE                          (no imprime rechazo)
ELSE
   IF ORDENADO-TB-PRIORIDAD = 4 OR 14 OR 15 OR 17
      WRITE RECHAZOS-CM-LINEA FROM WS-RECHA-DISPER
```

**Vocabulario en la fórmula:** WS-CLAVE-TRAN · 700 · 701 · 613 · 615 · RECHAZOS-CM-LINEA

**Excepciones:**
- Las claves 613 y 615 sí figuran como cargos en RN-S500-547 pero se suprimen del listado impreso: inconsistencia potencial entre cifras y detalle.

**Estado validación:** Verificado fuente líneas 734720-736510 (párrafo 53211220-IMPRIME-DETALLE)

---

## RN-S500-554 — Ejecución bifásica por parámetro WS-VAL-165 (fase 1 genera pagos, fase 2 genera resultados)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-554 |
| **Nombre** | Ejecución bifásica por parámetro WS-VAL-165 (fase 1 genera pagos, fase 2 genera resultados) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa recibe por USING el parámetro `WS-VAL-165` que gobierna dos modos de ejecución: en fase 1 abre y genera el archivo de pagos (`PAGOS1`) que se envía a los sistemas que poseen pagos en el S500; en fase 2 genera los reportes de resultado de la dispersión (operados, rechazados, cifras, calificativos). El nombre de los archivos de reporte también depende de la fase (`002DISPERRECHAZ1` intermedio vs `002DISPERRECHAZO` final).

**Fórmula/pseudocódigo:**
```
PROCEDURE DIVISION USING WS-VAL-165.
IF WS-VAL-165 = 1
   OPEN OUTPUT PAGOS1 · PERFORM 50010000-ARC-PAGOS
IF WS-VAL-165 = 2
   MOVE "002DISPERRECHAZO." TO WS-RECH-NOMBRE-REP · genera reportes
```

**Vocabulario en la fórmula:** WS-VAL-165 · PAGOS1 · DISPERRECHAZO · RESULTADO-DISPERSION

**Excepciones:**
- Correr la fase equivocada sobre datos de la otra produce archivos vacíos o reportes inconsistentes.

**Estado validación:** Verificado fuente líneas 453610-457870 y 470410 (párrafo de control WS-VAL-165)

---

## RN-S500-555 — Importe efectivamente pagado como importe menos saldo pendiente

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-555 |
| **Nombre** | Importe efectivamente pagado como importe menos saldo pendiente |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada pago pendiente tomado de la base B24, el importe efectivamente pagado se calcula como el importe original menos el saldo que aún queda pendiente (`IMPPAG = IMPORTE - SALDO`). Esto refleja los pagos parciales: lo dispersado es la diferencia entre lo debido y lo que resta por cobrar, no el importe nominal completo.

**Fórmula/pseudocódigo:**
```
COMPUTE WS-PAGO-IMPPAG = B24-IMPORTE - B24-SALDO
MOVE WS-PAGO-IMPPAG TO PAGO1-IMPPAG
MOVE B24-IMPORTE    TO PAGO1-IMPORI
```

**Vocabulario en la fórmula:** WS-PAGO-IMPPAG · B24-IMPORTE · B24-SALDO · PAGO1-IMPPAG · PAGO1-IMPORI

**Excepciones:**
- Si el saldo es igual al importe, el importe pagado es cero (pago no aplicado).

**Estado validación:** Verificado fuente líneas 474287-474288 (párrafo 50011000-LEO-PAGOS)

---

## RN-S500-556 — Consolidación de pagos de múltiples orígenes (B17 línea, B24, B25) y ordenamiento por sistema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-556 |
| **Nombre** | Consolidación de pagos de múltiples orígenes (B17 línea, B24, B25) y ordenamiento por sistema |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de pagos consolida movimientos de tres orígenes de la BD01: pagos de línea (B17), pagos pendientes B24 y pagos pendientes especiales B25, marcando en cada registro el sistema generador (`PAGO1-SISTEMA`), el estado generador (`PAGO1-ESTGEN` = 17/24/25) y el nivel de detalle. El archivo resultante se ordena por sistema, estado generador y detalle para que cada sistema destino consuma solo sus pagos.

**Fórmula/pseudocódigo:**
```
* B17 → PAGO1-ESTGEN 17 (línea)
* B24 → PAGO1-ESTGEN 24 (pendientes)   DETALLE = 1
* B25 → PAGO1-ESTGEN 25 (pendientes PE) DETALLE = 1
SORT PAGOS-SORT ON ASCENDING KEY PASORT-SISTEMA PASORT-ESTGEN ...
```

**Vocabulario en la fórmula:** PAGO1-SISTEMA · PAGO1-ESTGEN · B17-SISTEMA-ARCH · B24 · B25 · PASORT-SISTEMA

**Excepciones:**
- Un origen sin registros (STATUS=1 o SISTEMA-ARCH=0) se omite del archivo de pagos.

**Estado validación:** Verificado fuente líneas 458470-458510, 474281-474288, 475059-475070 y SORT 475556

---

## RN-S500-557 — Trailer de control del archivo de pagos (registros, importe original e importe pagado)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-557 |
| **Nombre** | Trailer de control del archivo de pagos (registros, importe original e importe pagado) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de pagos cierra con un trailer que consolida el número total de registros (`PAGO-NUMREG`), la suma de importes originales (`PAGO-IMPORIT`) y la suma de importes efectivamente pagados (`PAGO-IMPPAGT`). Estas tres cifras permiten a cada sistema destino cuadrar el lote de pagos recibido antes de aplicarlo, control indispensable en un flujo de dispersión SPEI.

**Fórmula/pseudocódigo:**
```
ADD 1              TO WS-SUMPAG-REG
ADD PAGO1-IMPORI   TO WS-SUMPAG-IMPORI
ADD PAGO1-IMPPAG   TO WS-SUMPAG-IMPPAG
* trailer:
MOVE WS-SUMPAG-REG    TO PAGO-NUMREG
MOVE WS-SUMPAG-IMPORI TO PAGO-IMPORIT
MOVE WS-SUMPAG-IMPPAG TO PAGO-IMPPAGT
```

**Vocabulario en la fórmula:** WS-SUMPAG-REG · WS-SUMPAG-IMPORI · WS-SUMPAG-IMPPAG · PAGO-NUMREG · PAGO-IMPPAGT

**Excepciones:**
- Los contadores se reinician a cero al inicio de cada lote (párrafo de apertura).

**Estado validación:** Verificado fuente líneas 494410-495010, 500110-500710 y 502530-502550

---

## RN-S500-558 — Integración de movimientos de tarjetas/cajeros diarios y semanales (MOVTBINT/EAS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-558 |
| **Nombre** | Integración de movimientos de tarjetas/cajeros diarios y semanales (MOVTBINT/EAS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El resultado de dispersión integra los movimientos del sistema de tarjetas y cajeros mediante cuatro archivos indexados de acceso aleatorio: diario (`MOVTBINT`) y semanal (`MOVTBINTSEM`), con sus contrapartes EAS (`MOVTBINT-EAS`, `MOVTBINTSEM-EAS`), todos con registro de 156 caracteres y llave numérica de 11 posiciones. Esto cruza la dispersión con los movimientos de tarjeta para conciliar cargos/abonos de cajeros.

**Fórmula/pseudocódigo:**
```
SELECT OPTIONAL MOVTBINT ... ORGANIZATION SEQUENTIAL ACCESS RANDOM
   ACTUAL KEY WS-LLAVE-TBINT PIC 9(11) BINARY
FD MOVTBINT · REG-MOVTBINT PIC X(156)
* variantes: MOVTBINTSEM (semanal), *-EAS (banca electrónica)
```

**Vocabulario en la fórmula:** MOVTBINT · MOVTBINTSEM · WS-LLAVE-TBINT · REG-MOVTBINT · EAS

**Excepciones:**
- Archivos declarados OPTIONAL: su ausencia no aborta, la conciliación de tarjeta simplemente no se integra ese día.

**Estado validación:** Verificado fuente líneas 014440-014960, 072660-073180 y 115810-119960

---

## RN-S500-559 — Acumulación de cargos y abonos totales de la dispersión

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-559 |
| **Nombre** | Acumulación de cargos y abonos totales de la dispersión |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El programa mantiene los grandes totales de la dispersión en dos acumuladores de 16 enteros y 2 decimales: `WS-CARGOS` y `WS-ABONOS`, alimentados según la clasificación de la clave de transacción (RN-S500-547). El cuadre de la dispersión exige que la partida doble se refleje: los abonos (entradas) contra los cargos (salidas) deben conciliar con las cifras de aceptados y rechazados.

**Fórmula/pseudocódigo:**
```
77 WS-CARGOS PIC 9(16)V99.
77 WS-ABONOS PIC 9(16)V99.
IF ABONOS OR REMBOLSO → acumula en entradas (WS-ABONOS)
IF CARGOS             → acumula en salidas  (WS-CARGOS)
```

**Vocabulario en la fórmula:** WS-CARGOS · WS-ABONOS · ABONOS · CARGOS · REMBOLSO

**Excepciones:**
- Los movimientos NOCONTAB (claves 1-999) no participan en cargos/abonos contables.

**Estado validación:** Verificado fuente líneas 119110-119410 y 760810-765910

---

## RN-S500-560 — Reporte de calificativos y evaluación de la dispersión

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-560 |
| **Nombre** | Reporte de calificativos y evaluación de la dispersión |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-23 |
| **bian_ref** | T.1.3 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | Banxico |
| **Programa ejecutor** | P165 (S500P165-RESULTADO-DISPERSION) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Además de operados y rechazados, el programa emite un reporte de calificativos de la dispersión (`INFORMACION DE CALIFICATIVOS/DISPERSION`) que evalúa el resultado de la corrida con su detalle y totales. Es el tablero de control operativo de la dispersión SPEI que resume el desempeño del lote (operados, rechazados por causa, cifras por moneda) para monitoreo y toma de decisiones.

**Fórmula/pseudocódigo:**
```
* TITULOS PARA EVALUACION DE DISPERSION
* detalle de evaluación + totales de calificativos
WRITE reporte "INFORMACION DE CALIFICATIVOS/DISPERSION"
```

**Vocabulario en la fórmula:** calificativos · evaluación dispersión · operados · rechazados

**Excepciones:**
- El reporte es informativo; no altera la aplicación de los pagos.

**Estado validación:** Verificado fuente líneas 236810-237310 (títulos de evaluación de dispersión)

# Catálogo de Reglas de Negocio — S151 Contabilidad GL B
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P122 · P152 · P168 · P114 · P113 · P171 · P153 · P195 · P170 · P196 · P102 · P194 · P103
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S151-850 a RN-S151-920 (71 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S151-850 — Ruteo de fuente contable por sistema originador (C402 vs S707)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-850 |
| **Nombre** | Ruteo de fuente contable por sistema originador (C402 vs S707) |
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
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P122 recibe los archivos de movimientos generados por las plataformas C/S e IBM (sistemas C402, C600, S804) y Tandem (S707, S203), y ruta la lectura a la estructura de archivo correcta según el sistema recibido como parámetro. Los sistemas 707 y 203 se leen del archivo ARCHS707 (formato nuevo CitiDirect, registro 1261); el resto (402, 600, 804) del archivo ARCHC402 (registro 720). El prefijo del identificador de sistema en el título es "C" para 402/600 y "S" para 804/707/203.

**Fórmula/pseudocódigo:**
```
IF W77-SIST-PARAM = 600  → título ARCHC402 = WKS-TIT-RECIBE-600 ; ID = "C"
ELSE IF W77-SIST-PARAM = 402 OR 600 → ID = "C" ; ARCHC402
ELSE IF W77-SIST-PARAM = 804 → ID = "S" ; ARCHC402
ELSE → ID = "S" ; ARCHS707
IF W77-SIST-PARAM = 707 OR 203 → OPEN INPUT ARCHS707 ; PERFORM 700-PROCESO-S707
ELSE → OPEN INPUT ARCHC402 ; PERFORM 100-PROCESO
```

**Vocabulario en la fórmula:** W77-SIST-PARAM · ARCHC402 · ARCHS707 · WKS-TIT-ID-SISTEMA

**Excepciones:**
- El sistema 600 usa un título físico distinto (WKS-TIT-RECIBE-600) apuntando a C600 aunque comparte el FD ARCHC402.

**Estado validación:** Verificado fuente líneas 1618-1669

---

## RN-S151-851 — Validación de integridad Header/Trailer del archivo de movimientos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-851 |
| **Nombre** | Validación de integridad Header/Trailer del archivo de movimientos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de cargar movimientos al S151, P122 valida que el archivo contenga un registro Header ("HD") y un Trailer ("TR") consistente. Un archivo sin header es rechazado. En el trailer, el total de registros calculado (menos el propio trailer) y el total de importe calculado deben coincidir con los totales declarados en el trailer (R01-MOV-TRA-TOTREG, R01-MOV-TRA-TOTIMPORTE); si no coinciden, se marca error y se solicita cambiar el archivo. Solo el sistema 804 ejecuta la validación completa de trailer (082-VALIDA-TR-402).

**Fórmula/pseudocódigo:**
```
IF R01-MOV-HDR-HD NOT = "HD" → rechazar archivo (sin header)
Acumular por registro FUNCION=1: TOT-CLAVES, TOT-IMPORTE
Al leer "TR":
   TOT-REGISTROS = TOT-REGISTROS - 1
   IF TOT-REGISTROS = TRA-TOTREG AND TOT-IMPORTE = TRA-TOTIMPORTE → OK
   ELSE → HEADER = 0 ; mensaje "ARCHIVO CON TRAILER ERRONEO"
IF HEADER = 1 AND TRAILER = 1 → ARCHIVO-OK
```

**Vocabulario en la fórmula:** R01-MOV-HDR-HD · R01-MOV-TRA-TOTREG · R01-MOV-TRA-TOTIMPORTE · W77-TOT-IMPORTE

**Excepciones:**
- La comparación de TOT-CLAVES contra TRA-TOTCLAVES está comentada en el fuente (líneas 1744, 1831); solo se validan registros e importe.
- Para sistemas distintos de 804 y 707/203, el trailer se fuerza a 1 sin validación real.

**Estado validación:** Verificado fuente líneas 1686-1867

---

## RN-S151-852 — Catálogo de funciones válidas de movimiento (01/11/21/98)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-852 |
| **Nombre** | Catálogo de funciones válidas de movimiento (01/11/21/98) |
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
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada registro de movimiento contable trae una FUNCION que determina la operación en el S151. Solo se consideran funciones válidas de detalle 01 (inicio/movimiento), 11, 21 y 98 (fin de proceso), definidas en el condicional 88 W88-VALIDA-FUNCION. Un registro cuya función no está catalogada se interpreta como fin del bloque de movimientos: se envía el fin de movimientos y se termina la lectura del archivo.

**Fórmula/pseudocódigo:**
```
88 W88-VALIDA-FUNCION VALUE 01, 11, 21, 98
MOVE R01-MOV-FUNCION TO W77-VALIDA-FUNCION
IF NOT W88-VALIDA-FUNCION
   PERFORM 400-ENVIA-FIN-MOVTOS
   MOVE 1 TO W77-FIN
```

**Vocabulario en la fórmula:** W88-VALIDA-FUNCION · R01-MOV-FUNCION · WKS-NVO-FUNCION

**Excepciones:**
- La función 01 dispara adicionalmente la grabación del archivo de punteo (PERFORM 500-GRABA-PUNTEO / 850-GRABA-PUNTEO).

**Estado validación:** Verificado fuente líneas 117-118, 1983-1989, 2014-2020

---

## RN-S151-853 — Forzado de tipo de proceso a 1 en carga C402

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-853 |
| **Nombre** | Forzado de tipo de proceso a 1 en carga C402 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al transformar el registro C402 (R01-MOV) al formato de llamado a la librería L002 (WKS-MOV), P122 ignora el tipo de proceso que trae el registro origen y lo fuerza al valor constante 1. La línea original que copiaba R01-MOV-TIPO-PROC quedó comentada. Esto significa que todo movimiento cargado por esta vía se marca como tipo de proceso 1 (proceso normal), sin importar el valor real enviado por el sistema originador.

**Fórmula/pseudocódigo:**
```
*   MOVE R01-MOV-TIPO-PROC  TO WKS-MOV-TIPO-PROC   (comentado)
    MOVE 1                  TO WKS-MOV-TIPO-PROC
```

**Vocabulario en la fórmula:** WKS-MOV-TIPO-PROC · R01-MOV-TIPO-PROC

**Excepciones:**
- Riesgo de equivalencia: cualquier movimiento con tipo de proceso distinto de 1 en origen pierde ese atributo en la carga contable.

**Estado validación:** Verificado fuente líneas 1938-1939

---

## RN-S151-854 — Centinela de fin de movimientos (función 98) hacia L002

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-854 |
| **Nombre** | Centinela de fin de movimientos (función 98) hacia L002 |
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
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al terminar de procesar el archivo de un sistema, P122 envía a la librería CARGAMOV1 IN LIB-REG (L002) un registro centinela con FUNCION 98, el sistema en proceso y la fecha contable de proceso. Este registro marca el cierre del batch de movimientos de ese sistema en el log del S151, permitiendo a L002 cerrar el ciclo de carga contable del día.

**Fórmula/pseudocódigo:**
```
400-ENVIA-FIN-MOVTOS:
   MOVE LOW-VALUES        TO WKS-MOV-DATOS
   MOVE 98                TO WKS-MOV-FUNCION
   MOVE W77-SIST-PARAM    TO WKS-MOV-SISTEMA
   MOVE WKS-TIT-FECHAPRO  TO WKS-MOV-FECCONT
   CALL "CARGAMOV1 IN LIB-REG" USING WKS-MOV-DATOS GIVING WKS-151-RESULT
```

**Vocabulario en la fórmula:** WKS-MOV-FUNCION · CARGAMOV1 · WKS-TIT-FECHAPRO · WKS-151-RESULT

**Excepciones:**
- Ninguna. Se ejecuta siempre al cierre del proceso normal y al detectar función no catalogada.

**Estado validación:** Verificado fuente líneas 2079-2086

---

## RN-S151-855 — Control de reproceso B05 (Alta Disponibilidad) para sistemas 203/804

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-855 |
| **Nombre** | Control de reproceso B05 (Alta Disponibilidad) para sistemas 203/804 |
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
| **Programa ejecutor** | P122 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Bajo el esquema de Alta Disponibilidad (IBM), exclusivamente para los sistemas 203 y 804 y cuando la tarea corre en el host primario (ATTRIBUTE VALUE OF MYSELF = 0), P122 consulta un registro de control de proceso B05 con la fecha del día. Si el B05 existe y ya está terminado (STAPGM distinto de 0) el programa se detiene para evitar reproceso; si no existe, lo crea (función 19). Al terminar la carga marca el B05 como terminado (función 37, STAPGM=01). Esto implementa idempotencia de reejecución del batch contable en el clúster.

**Fórmula/pseudocódigo:**
```
IF (SIST = 203 OR 804) AND MYSELF = 0:
   1000-VERIFICA-B05: CALL B05PROCESOS func=01
       IF result=0 AND STAPGM<>0 → STOP RUN  (ya procesado)
       IF result<>0 → 1100-CREA-B05 (func=19)
   ...proceso...
   1200-ACTUALIZA-B05: CALL B05PROCESOS func=37, STAPGM=01
```

**Vocabulario en la fórmula:** WKS-B05-FUNCION · WKS-B05-STAPGM · B05PROCESOS · S151LIBCONTROL

**Excepciones:**
- Los sistemas 402, 600, 707 no participan del control B05 (no son de Alta Disponibilidad en este flujo).

**Estado validación:** Verificado fuente líneas 1639-1642, 1679-1682, 2146-2217

---

## RN-S151-856 — Filtro de movimientos acumulables (FUNCION 01, STATUS 01, ORIGEN 01/02)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-856 |
| **Nombre** | Filtro de movimientos acumulables (FUNCION 01, STATUS 01, ORIGEN 01/02) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P152 acumula importes de cargos y abonos por producto, instrumento y moneda al finalizar el batch de cada sistema. Del log de movimientos del S151 (L01-DATOS) solo se toman para acumular los registros que son movimiento real efectivo: función 01, estatus 01 y origen 01 o 02. Cualquier otro registro se ignora en la acumulación. La función 99 se trata aparte como fin de proceso (ver RN-S151-859).

**Fórmula/pseudocódigo:**
```
IF A00-R01-FUNCION = 01 AND A00-R01-STATUS = 01
   AND (A00-R01-ORIGEN = 01 OR 02)
   → PERFORM 001500-GUARDA-TABLA  (acumula)
ELSE IF A00-R01-FUNCION = 99
   → actualiza base B05 y termina
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · A00-R01-STATUS · A00-R01-ORIGEN

**Excepciones:**
- Origen distinto de 01/02 (p.ej. movimientos reversados o de sistemas externos con otro origen) no participa del acumulado contable diario.

**Estado validación:** Verificado fuente líneas 1824-1836

---

## RN-S151-857 — Clasificación cargo/abono por naturaleza contable del catálogo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-857 |
| **Nombre** | Clasificación cargo/abono por naturaleza contable del catálogo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada clave de transacción (CVETRAN, hasta 5 por movimiento) P152 determina si el importe es cargo o abono según la naturaleza contable (NATCON) que el catálogo paramétrico asocia a esa clave: NATCON=1 es cargo y NATCON=2 es abono. Se acumulan por separado número de cargos, importe de cargos, número de abonos e importe de abonos. En catálogos de formato 3, la naturaleza se selecciona según el esquema contable (ESQCON) del movimiento coincida con TIP-MOV (natural primaria) o TIP-MOV2 (natural secundaria).

**Fórmula/pseudocódigo:**
```
IF NATCON(CVETRAN) = 1 → +1 NUM-CAR ; +IMPORTE a IMP-CAR   (cargo)
IF NATCON(CVETRAN) = 2 → +1 NUM-ABO ; +IMPORTE a IMP-ABO   (abono)
FORMATO 3 y ESQCON in (1,2):
   IF TIP-MOV(CVETRAN)=ESQCON  → usar NATCON(CVETRAN)
   ELSE IF TIP-MOV2(CVETRAN)=ESQCON → usar NATCON2(CVETRAN)
```

**Vocabulario en la fórmula:** WKS-CAT-NATCON · WKS-CAT-NATCON2 · A00-R01-ESQCON · A00-R01-CVETRAN · A00-R01-IMPORTE

**Excepciones:**
- Una clave con NATCON distinto de 1 o 2 no se acumula ni como cargo ni como abono (NEXT SENTENCE).

**Estado validación:** Verificado fuente líneas 1879-1923

---

## RN-S151-858 — Llave de agregación PIMC y persistencia de totales B05

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-858 |
| **Nombre** | Llave de agregación PIMC y persistencia de totales B05 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La acumulación se agrupa por una llave compuesta de 12 dígitos PIMC = Producto (4) + Instrumento (2) + Moneda (2) + CPAE (4). Cada combinación distinta genera una entrada en la tabla de totales; al cierre, cada entrada se persiste en el dataset S151B05BATCH con sus totales de número e importe de cargos y abonos, llaveado además por sistema, CSI y fecha de proceso. Si el registro B05 ya existe (LOCK exitoso) se actualiza; si no existe se crea (CREATE/STORE). Solo se persisten entradas con al menos un total mayor a cero.

**Fórmula/pseudocódigo:**
```
W77-PIMC = W77-PRD(4) & W77-INST(2) & W77-MONEDA(2) & W77-CEPAE(4)
LOCK B05SXPRODINST por (SISTEMA, CSI, FECINF, PRODUCTO, INSTSERV, MONEDA, CPAE)
   IF NOTFOUND → 030000-CREA-B05 (CREATE + STORE)
   ELSE        → 002000-ACT-B05 (actualiza NUMCARGOS/ABONOS, IMPCARGOS/ABONOS) + STORE
Solo si algún total (NUM/IMP CAR/ABO) > 0
```

**Vocabulario en la fórmula:** W77-PIMC · B05-TOT-PRODUCTO · B05-TOT-INSTSERV · B05-TOT-MONEDA · B05-TOT-CPAE · B05-TOT-IMPCARGOS · B05-TOT-IMPABONOS

**Excepciones:**
- Entradas con producto, instrumento, moneda y CPAE en ceros marcan fin de tabla (no se persisten).

**Estado validación:** Verificado fuente líneas 82-90, 1863-1867, 1988-2070

---

## RN-S151-859 — Centinela de reinicio contable (FUNCION 99) y volcado transaccional a base

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-859 |
| **Nombre** | Centinela de reinicio contable (FUNCION 99) y volcado transaccional a base |
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
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El registro con función 99 en el log marca el fin del proceso de acumulación. Al detectarlo, P152 abre una transacción no auditada sobre el dataset de control de reinicio S151B99REINICTL y vuelca toda la tabla de totales acumulados en memoria hacia la base (S151B05BATCH), recorriéndola hasta agotarla. Solo tras cerrar la transacción marca fin de logs. El uso de NO-AUDIT indica que este volcado no genera pistas de auditoría DMSII (recuperación por reinicio, no por rollback auditado).

**Fórmula/pseudocódigo:**
```
IF A00-R01-FUNCION = 99
   BEGIN-TRANSACTION NO-AUDIT S151B99REINICTL OF BIFINDB
   PERFORM 001900-ACT-BASE UNTIL W88-FIN-TAB   (vuelca tabla → B05)
   END-TRANSACTION NO-AUDIT S151B99REINICTL OF BIFINDB
   MOVE 1 TO W77-END-LOGS
```

**Vocabulario en la fórmula:** A00-R01-FUNCION · S151B99REINICTL · BEGIN-TRANSACTION NO-AUDIT · W88-FIN-TAB

**Excepciones:**
- Si nunca llega función 99, la tabla acumulada no se persiste (dependencia crítica del centinela de cierre).

**Estado validación:** Verificado fuente líneas 1830-1836, 1988-2004

---

## RN-S151-860 — Resolución de catálogo y formato de claves por sistema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-860 |
| **Nombre** | Resolución de catálogo y formato de claves por sistema |
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
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de acumular, P152 carga desde el catálogo paramétrico S080 la relación de claves de transacción y su naturaleza contable para el sistema en proceso. Los sistemas CFR (203, 404, 707, 804) usan el catálogo 1059 con llave alfanumérica "S"+sistema; el resto usa el catálogo 523 con el número de sistema como llave. El formato del catálogo (1 a 4) determina el orden de búsqueda y qué campo del registro es la clave y cuál la naturaleza contable; un formato distinto de 1-4 aborta el programa con estatus -1.

**Fórmula/pseudocódigo:**
```
IF sistema IN (203,404,707,804) → CATALOGO=1059 ; llave="S"+sistema
ELSE → CATALOGO=523 ; llave=sistema
FORMATO=2 → orden 1, clave campo(2)
FORMATO=1 → orden 2, clave campo(1)
FORMATO=3 → clave campo(1), doble naturaleza TIP-MOV/TIP-MOV2
FORMATO=4 → clave campo(1), naturaleza campo(4)
ELSE → "NUMERO DE FORMATO NO VALIDO" ; STATUS=-1
```

**Vocabulario en la fórmula:** W88-SISTEMAS-CFR · S080-CPPE-CATALOGO · W77-CAT-FORMATO · WKS-CAT-CVE · WKS-CAT-NATCON

**Excepciones:**
- Solo se cargan claves con naturaleza 01 o 02 en formatos 1 y 2 (líneas 1715, 1727).

**Estado validación:** Verificado fuente líneas 1572-1580, 1621-1648, 1704-1760

---

## RN-S151-861 — Carga y asignación de CPAE exclusiva para sistema 18

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-861 |
| **Nombre** | Carga y asignación de CPAE exclusiva para sistema 18 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-IMPLÍCITO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P152 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El componente CPAE (Centro de Proceso Administrativo / Estación) de la llave de agregación solo se resuelve para el sistema 18. Únicamente cuando WKS-SISTE-PARAM = 18 se carga en memoria el catálogo 231 de CPAEs (pares sucursal-operadora → CPAE, con CPAE entre 1 y 9999) y, por cada movimiento, se busca el CPAE por sucursal operadora. Para el resto de sistemas el CPAE queda en ceros y no diferencia la agregación.

**Fórmula/pseudocódigo:**
```
IF WKS-SISTE-PARAM = 18
   PERFORM 000800-CARGA-CPAE  (catálogo 231)
   ...por movimiento: 045500-TRAE-CEPAE
       SEARCH WKS-TAB-CPAE WHEN T-SUCOPER = A00-R01-SUCOPER → W77-CEPAE
Guarda CPAE solo si 0 < campo(2) < 10000
```

**Vocabulario en la fórmula:** WKS-SISTE-PARAM · WKS-TAB-CPAE · WKS-T-SUCOPER · W77-CEPAE

**Excepciones:**
- El número 18 está embebido en código; agregar otro sistema con CPAE requiere modificación de fuente.

**Estado validación:** Verificado fuente líneas 1565-1566, 1762-1817, 2072-2078

---

## RN-S151-862 — Punteo de saldos AHR vs ACC por cuenta

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-862 |
| **Nombre** | Punteo de saldos AHR vs ACC por cuenta |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P168 concilia (puntea) los saldos entre el archivo AHR (saldos CBII, mayor auxiliar) y el archivo ACC (contabilidad), cuenta por cuenta. Se lee AHR ordenado por cuenta y por cada cuenta se busca su registro en ACC2 (indexado por cuenta). Si el saldo de mayor (LDGR-AMT) y su signo coinciden con el saldo y signo de ACC, la cuenta se considera cuadrada. Si difieren, la cuenta se graba en ARCH-CTAS como diferencia con ambos saldos para el reporte de auditoría.

**Fórmula/pseudocódigo:**
```
Por cuenta AHR:
   READ ACC2 KEY = cuenta
   IF WKS-SALDO-T = ACC-SALDO AND WKS-SSDO-T = ACC-SSDO → cuadra (no diferencia)
   ELSE → GRABA-CTAS (cuenta, SDO-AHR, SSDO-AHR, SDO-ACC, SSDO-ACC)
   IF ACC no existe (INVALID KEY) → diferencia con SDO-ACC = 0
```

**Vocabulario en la fórmula:** AHRST-ACCT-NBR · AHRST-LDGR-AMT · AHRST-LDGR-AMT-SIGN · ACC-SALDO · ACC-SSDO

**Excepciones:**
- Cuenta presente en AHR pero ausente en ACC se reporta como diferencia con saldo contable cero.

**Estado validación:** Verificado fuente líneas 1603-1699, 1721-1726

---

## RN-S151-863 — Cálculo de saldo de apertura y naturaleza del movimiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-863 |
| **Nombre** | Cálculo de saldo de apertura y naturaleza del movimiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para los movimientos de cuentas INTEL, P168 reconstruye el saldo de apertura a partir del saldo de mayor (LDGR-AMT), el importe de la transacción (TXN-AMT) y su naturaleza deudora/acreedora (DR-CR-IND), considerando el signo del saldo. La lógica invierte el efecto del movimiento sobre el saldo final para obtener el inicial, y determina la naturaleza contable resultante (C/D) según si el importe excede o no al saldo de mayor.

**Fórmula/pseudocódigo:**
```
IF LDGR-SIGN = "+" AND DR-CR = "C":
   SDO-APERTURA = LDGR-AMT - TXN-AMT
   NAT = "D" si TXN-AMT > LDGR-AMT, si no "C"
IF LDGR-SIGN = "+" AND DR-CR = "D": SDO-APERTURA = LDGR-AMT + TXN-AMT ; NAT="C"
IF LDGR-SIGN = "-" AND DR-CR = "C": SDO-APERTURA = LDGR-AMT + TXN-AMT ; NAT="D"
IF LDGR-SIGN = "-" AND DR-CR = "D":
   SDO-APERTURA = LDGR-AMT - TXN-AMT
   NAT = "C" si TXN-AMT > LDGR-AMT, si no "D"
```

**Vocabulario en la fórmula:** AHRST-LDGR-AMT-SIGN · AHRST-DR-CR-IND · AHRST-TXN-AMT · A00-R00-INTE-SDO-APERTURA · A00-R00-INTE-NAT

**Excepciones:**
- Solo se aplica a cuentas marcadas como INTEL (W88-CTA-INTEL).

**Estado validación:** Verificado fuente líneas 1741-1766

---

## RN-S151-864 — Cálculo de diferencia de saldos por signo en reporte de auditoría

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-864 |
| **Nombre** | Cálculo de diferencia de saldos por signo en reporte de auditoría |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En el reporte de diferencias de saldos, P168 calcula la diferencia entre el saldo AHR y el saldo ACC de cada cuenta descuadrada considerando los signos. Si ambos saldos tienen el mismo signo, la diferencia es el valor absoluto de la resta (mayor menos menor); si tienen signo distinto, la diferencia es la suma de ambos saldos (magnitud total de descuadre).

**Fórmula/pseudocódigo:**
```
IF SSDO-AHR = SSDO-ACC:
   IF SDO-AHR > SDO-ACC → DIFERENCIA = SDO-AHR - SDO-ACC
   ELSE               → DIFERENCIA = SDO-ACC - SDO-AHR
ELSE:
   DIFERENCIA = SDO-ACC + SDO-AHR
```

**Vocabulario en la fórmula:** WKS-SSDO-AHR · WKS-SSDO-ACC · WKS-SDO-AHR · WKS-SDO-ACC · WLI-DIFERENCIA

**Excepciones:**
- Ninguna. Aplica a toda cuenta grabada en ARCH-CTAS como descuadre.

**Estado validación:** Verificado fuente líneas 1852-1864

---

## RN-S151-865 — Cuentas INTEL: extracción de detalle y transferencia por INTELAR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-865 |
| **Nombre** | Cuentas INTEL: extracción de detalle y transferencia por INTELAR |
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
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Existe un conjunto acotado de hasta 8 cuentas catalogadas como INTEL (condicional W88-CTA-INTEL). Solo para esas cuentas P168 genera un archivo de detalle de movimientos (encabezado con saldos de apertura/cierre más renglones de movimiento) y al terminar lo envía por el canal INTELAR llamando a INTELARSND IN ADMONXFERS. Las cuentas INTEL que no aparecieron en AHR se completan igual (VERI-CTAS-FALTAN) usando su saldo de cierre como apertura, para no dejar huecos en el envío.

**Fórmula/pseudocódigo:**
```
Por cuenta AHR marcada W88-CTA-INTEL:
   escribe HDR-INTE (apertura/cierre) + REGMOV por movimiento
   MARCA-CTA (marca la cuenta como encontrada en tabla de 8)
Al final: VERI-CTAS-FALTAN por cada INTEL no encontrada
   → escribe HDR con SDO-APERTURA = SDO-CIERRE
UNSTRING título ; CALL "INTELARSND IN ADMONXFERS" GIVING W77-INTE-SNT
```

**Vocabulario en la fórmula:** W88-CTA-INTEL · WKS-CTA-INTEL · WKS-IND-ENCONTRE · INTELARSND · ADMONXFERS

**Excepciones:**
- Si el envío INTELAR devuelve código distinto de cero se registra error tipo "E" pero no se aborta el proceso.

**Estado validación:** Verificado fuente líneas 1585-1601, 1690-1719, 1768-1777

---

## RN-S151-866 — Derivación de naturaleza contable de cierre desde el signo del saldo ACC

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-866 |
| **Nombre** | Derivación de naturaleza contable de cierre desde el signo del saldo ACC |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P168 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al armar el encabezado del archivo INTEL, la naturaleza contable del saldo de cierre se deriva del signo del saldo ACC: signo "+" es naturaleza acreedora "C" y cualquier otro signo es deudora "D". Si la cuenta INTEL no existe en ACC, se asume naturaleza acreedora "C" y saldo de cierre cero.

**Fórmula/pseudocódigo:**
```
IF ACC existe:
   IF ACC-SSDO = "+" → NAT-CIERRE = "C"  ELSE → NAT-CIERRE = "D"
   SDO-CIERRE = ACC-SALDO
ELSE:
   NAT-CIERRE = "C" ; SDO-CIERRE = 0
```

**Vocabulario en la fórmula:** ACC-SSDO · A00-R00-INTE-NAT-CIERRE · A00-R00-INTE-SDO-CIERRE

**Excepciones:**
- La convención "+"→C aplica a la representación de saldo del archivo ACC de contabilidad.

**Estado validación:** Verificado fuente líneas 1728-1739

---

## RN-S151-867 — Extracción de información ICA del sistema 264 y ruteo por CSI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-867 |
| **Nombre** | Extracción de información ICA del sistema 264 y ruteo por CSI |
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
| **Programa ejecutor** | P114 (S151-P114-EXTRAEICA) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P114 extrae la información de operaciones ICA del sistema 264 leyendo el archivo del día vía la librería LIBICA (ABREDIAICA / REGISTRO-ICA). El nombre del archivo host origen/destino se determina por el CSI donde corre el proceso: CSI 04 o 12 usan "MON" y CSI 10 o 32 usan "VDM". La fecha de proceso se obtiene de S151LIBCONTROL (CONSISDIA) para el sistema 264. Si no existe el archivo ICA del día, el programa termina de forma anormal (STATUS -1).

**Fórmula/pseudocódigo:**
```
CALL CONSISDIA sistema=264 → fecha de proceso
IF NUMCSI = 04 OR 12 → host = "MON"
ELSE IF NUMCSI = 10 OR 32 → host = "VDM"
CALL "ABREDIAICA OF LIBICA" USING control, fecha, host
IF WS-RSLT-ICA > 0 → "NO EXISTE ARCHIVO ICA, TERMINACION ANORMAL" ; STATUS=-1
```

**Vocabulario en la fórmula:** WKS-NUMCSI · NOM-ARCH-NO-ORI · ABREDIAICA · LIBICA · WKS-B01-SISTEMA (264)

**Excepciones:**
- CSIs distintos de 04/12/10/32 no asignan nombre de host (posible archivo mal formado).

**Estado validación:** Verificado fuente líneas 1571-1603, 1627-1663

---

## RN-S151-868 — Filtro de códigos de servicio válidos y exclusión de estados erróneos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-868 |
| **Nombre** | Filtro de códigos de servicio válidos y exclusión de estados erróneos |
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
| **Programa ejecutor** | P114 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al armar el archivo de clasificación, P114 solo procesa registros con código de servicio válido (COD-SERV-VALIDO) y cuenta las ocurrencias por código de servicio. En la extracción posterior, los registros cuyo estado ICA es sospechoso, revocado o por revocar se marcan como erróneos y se descartan (no generan registro de salida en INFOICA).

**Fórmula/pseudocódigo:**
```
2200-ARMA-SORT:
   IF COD-SERV-VALIDO → +1 ELEM-CODIG-SERV(MSG-TRC1-COD) ; WRITE CLASIFICA
2600-ARMA-REGISTROS:
   IF EDO-ICA-SOSPECHOSO OR EDO-ICA-REVOCADO OR EDO-ICA-POR-REVOCAR
      → WS-EDO-ERRONEO = 1
   IF EDO-ERRONEO → NEXT SENTENCE (descarta)
```

**Vocabulario en la fórmula:** COD-SERV-VALIDO · ELEM-CODIG-SERV · EDO-ICA-SOSPECHOSO · EDO-ICA-REVOCADO · EDO-ICA-POR-REVOCAR

**Excepciones:**
- Un registro con estado erróneo se ignora silenciosamente (no hay contabilización de rechazos por estado).

**Estado validación:** Verificado fuente líneas 1743-1771

---

## RN-S151-869 — Derivación de estatus de transacción ICA y captura de autorización

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-869 |
| **Nombre** | Derivación de estatus de transacción ICA y captura de autorización |
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
| **Programa ejecutor** | P114 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El estatus de la transacción ICA en el registro de salida se deriva del flujo de mensajería: para transacciones interactivas confirmadas o procesadas en origen/destino, si el mensaje de respuesta trae código de respuesta, entregado o aceptado, se captura el número de autorización (TMSYR-TRN-NUM-AUTOR) y se asigna estatus 3 si la operación ya fue procesada en origen, o estatus 2 en otro caso. Solo las transacciones con estatus 2 o 3 se arman y escriben en INFOICA.

**Fórmula/pseudocódigo:**
```
IF SA2-INTERACTIVO:
   IF EDO-ICA-CONFIRMADO → MSG-CONFIRMADO = 1
   ELSE IF (PROCESADO-ORI AND MSG-CONFIRMADO) OR PROCESADO-DES:
      IF MSG-REGRESO → 2610-VERIFICA-RESPUESTA
2610: IF MSG-COD-RESP OR ENTREGADO OR ACEPTADO:
        WS-CVE-AUTORIZACION = TMSYR-TRN-NUM-AUTOR
        IF SA2-APLICADA:
           STA-TRN = 3 si PROCESADO-ORI, si no 2
IF STA-TRN = 2 OR 3 → arma y escribe INFOICA
```

**Vocabulario en la fórmula:** SA2-INTERACTIVO · EDO-ICA-CONFIRMADO · WS-RDI-STA-TRN · TMSYR-TRN-NUM-AUTOR · WS-CVE-AUTORIZACION

**Excepciones:**
- Transacciones no interactivas o sin respuesta válida quedan con estatus 0 y no se extraen.

**Estado validación:** Verificado fuente líneas 1759-1796, 1784-1827

---

## RN-S151-870 — Estructura Header/Detalle/Trailer de INFOICA con deduplicación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-870 |
| **Nombre** | Estructura Header/Detalle/Trailer de INFOICA con deduplicación |
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
| **Programa ejecutor** | P114 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo de salida INFOICA se estructura con un registro Header inicial, N registros de detalle y un Trailer final con el conteo total de registros. Los registros de detalle se deduplican: solo se escribe un registro si difiere del anterior (WS-REG-INFOICA-ANT), evitando duplicados consecutivos. Al cerrar, el conteo de registros del trailer se reescribe también en el header, reabriendo el archivo en modo I-O para actualizar el primer registro.

**Fórmula/pseudocódigo:**
```
2700-CREA-HEADER: WRITE HEA-INFOICA
2640-ESCRIBE: IF WS-REG-DET-INFOICA NOT = WS-REG-INFOICA-ANT
                 → +1 NUM-REG ; WRITE detalle
2800-CREA-TRAILER: MOVE NUM-REG TO RTI-REG ; WRITE TRA-INFOICA
2900: CLOSE ; OPEN I-O ; READ header ; MOVE NUM-REG TO RHI-NUM-REG ; REWRITE
```

**Vocabulario en la fórmula:** WS-REG-HEA-INFOICA · WS-REG-DET-INFOICA · WS-REG-INFOICA-ANT · WS-NUM-REG · WS-RTI-REG · WS-RHI-NUM-REG

**Excepciones:**
- La deduplicación solo compara contra el registro inmediato anterior, no elimina duplicados no consecutivos.

**Estado validación:** Verificado fuente líneas 1829-1852

---

## RN-S151-871 — Dimensionamiento dinámico de memoria y disco para el SORT

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-871 |
| **Nombre** | Dimensionamiento dinámico de memoria y disco para el SORT |
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
| **Programa ejecutor** | P114 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de ordenar el archivo CLASIFICA por llave y estado ICA, P114 calcula dinámicamente el tamaño de memoria y disco del SORT a partir de los atributos físicos del archivo (FRAMESIZE, MAXRECSIZE, LASTRECORD). Ajusta el tamaño de registro cuando el FRAMESIZE es 8 (palabras de 6 caracteres) y dimensiona memoria como (MAXRECSIZE+3)*2000+1500 palabras y disco como MAXRECSIZE*LASTRECORD*3.5. Esto adapta el consumo de recursos al volumen real del día.

**Fórmula/pseudocódigo:**
```
IF FRAMESIZE = 8 → MAXRECSIZE ajustado = ceil(MAXRECSIZE/6)
MEMORY-SIZE = (MAXRECSIZE + 3) * 2000 + 1500
DISK-SIZE   = MAXRECSIZE * LASTRECORD * 3.5
SORT SD-INFOICA ON ASCENDING KEY SD-LLAVE, SD-EDO-ICA
     MEMORY SIZE DISK-SIZE WORDS  DISK SIZE MEMORY-SIZE WORDS
```

**Vocabulario en la fórmula:** W77-FRAMESIZE · W77-MAXRECSIZE · W77-LASTRECORD · W77-MEMORY-SIZE · W77-DISK-SIZE

**Excepciones:**
- Nota MCP-específica: las cláusulas MEMORY SIZE / DISK SIZE y atributos FRAMESIZE son propios de ClearPath MCP; requieren equivalencia al migrar.

**Estado validación:** Verificado fuente líneas 1679-1713

---

## RN-S151-872 — Conciliación de movimientos foráneos transmitidos vs recibidos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-872 |
| **Nombre** | Conciliación de movimientos foráneos transmitidos vs recibidos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P113 (PFORANEOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P113 concilia los movimientos foráneos (entre plazas/CSIs) comparando el archivo de movimientos transmitidos (A01-MOVTRA) contra el de recibidos (A01-MOVREC), ambos ordenados por la misma llave. Es una conciliación por mezcla (merge): si las llaves coinciden, el par cuadra (movimiento OK); si la llave transmitida es mayor que la recibida, existe un recibido sin transmitido (error) y avanza REC; si es menor, existe un transmitido sin recibido (error) y avanza TRA. Cada descuadre se imprime en el reporte de foráneos.

**Fórmula/pseudocódigo:**
```
IF KEY(MOVTRA) = KEY(MOVREC) → +1 MOVS-OK ; 4030-ADD-OK ; avanza ambos
ELSE IF KEY(MOVTRA) > KEY(MOVREC) → 4010-SUCREC-ERROR ; avanza REC
ELSE → 4020-SUCTRA-ERROR ; avanza TRA
IF FINTRA=1 AND FINREC=1 → corte de moneda ; fin
```

**Vocabulario en la fórmula:** A00-F01-KEY · A01-MOVTRA · A01-MOVREC · W77-MOVS-OK · W77-MOVSERR

**Excepciones:**
- Si no existen movimientos de un lado se fuerza tipo 99 (centinela de fin) para que el otro lado se reporte completo como descuadre.

**Estado validación:** Verificado fuente líneas 1385-1447, 1543-1563

---

## RN-S151-873 — Procesamiento bidireccional por CSI (transmisión y recepción invertidas)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-873 |
| **Nombre** | Procesamiento bidireccional por CSI (transmisión y recepción invertidas) |
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
| **Programa ejecutor** | P113 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Por cada sistema foráneo, P113 ejecuta la conciliación dos veces invirtiendo los CSIs origen y destino: primero con CSI transmisor 04 y receptor 10, y luego con transmisor 10 y receptor 04. Esto cubre el flujo foráneo en ambos sentidos entre las dos plazas de proceso (los CSIs 04/10 corresponden a los hosts identificados como MON y VDM).

**Fórmula/pseudocódigo:**
```
Por sistema con TAB-SIST(J) > 0:
   CSI-TRA=04 ; CSI-REC=10 → inicializa, sortea, genera reporte
   CSI-TRA=10 ; CSI-REC=04 → inicializa, sortea, genera reporte
```

**Vocabulario en la fórmula:** W77-CSI-TRA · W77-CSI-REC · WKS-TAB-SIST · W77-SISTEMA

**Excepciones:**
- Los valores 04 y 10 están embebidos en el fuente (plazas fijas).

**Estado validación:** Verificado fuente líneas 1347-1367

---

## RN-S151-874 — Validación de fecha de header contra fecha de proceso

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-874 |
| **Nombre** | Validación de fecha de header contra fecha de proceso |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P113 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de conciliar, P113 valida que la fecha del registro header de ambos archivos foráneos (transmitidos y recibidos) coincida con la fecha de proceso obtenida del archivo de control. Si la fecha del header difiere de la fecha de proceso, se registra error grave y el programa aborta con estatus -1, evitando conciliar archivos de días distintos.

**Fórmula/pseudocódigo:**
```
READ MOVTRA header
IF HDR-FCH(MOVTRA) NOT = FECHA-PROCESO → error "FECHA DIF A HEADER" ; STATUS=-1
READ MOVREC header
IF HDR-FCH(MOVREC) NOT = FECHA-PROCESO → error "FECHA DIF A HEADER" ; STATUS=-1
```

**Vocabulario en la fórmula:** A00-F00-HDR-FCH · W77-FECHA-PROCESO · WKS-HD-FECPRO

**Excepciones:**
- La fecha de proceso proviene del header del archivo de control A01-CONTROL (WKS-HD-FECPRO).

**Estado validación:** Verificado fuente líneas 1271-1278, 1506-1541

---

## RN-S151-875 — Clasificación cargo/abono foráneo por indicador AFC del catálogo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-875 |
| **Nombre** | Clasificación cargo/abono foráneo por indicador AFC del catálogo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P113 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para acumular importes, P113 obtiene por cada clave de transacción (CVETRAN1) su indicador AFC desde el catálogo cargado (WKS-CVE-AFC): AFC igual a 1 clasifica el importe como abono y AFC igual a 2 como cargo. Los importes se acumulan en contadores separados según el resultado de la conciliación: OK (par cuadrado), TRA (transmitido sin recibido) o REC (recibido sin transmitido). Solo se acumulan importes mayores a cero.

**Fórmula/pseudocódigo:**
```
W77-AFC = WKS-CVE-AFC(CVETRAN1)
IF IMPORTE1 > 0:
   IF AFC = 1 → +IMPORTE a IMP-ABO{OK|TRA|REC}
   IF AFC = 2 → +IMPORTE a IMP-CAR{OK|TRA|REC}
```

**Vocabulario en la fórmula:** WKS-CVE-AFC · A00-F01-CVETRAN1 · A00-F01-IMPORTE1 · W77-AFC

**Excepciones:**
- La convención AFC 1→abono / 2→cargo es propia de este catálogo foráneo (523) y difiere de otras naturalezas contables.

**Estado validación:** Verificado fuente líneas 1570-1580, 1616-1626, 1662-1672

---

## RN-S151-876 — Selección de sistemas foráneos desde archivo de control (INDPF)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-876 |
| **Nombre** | Selección de sistemas foráneos desde archivo de control (INDPF) |
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
| **Programa ejecutor** | P113 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los sistemas a conciliar como foráneos no están fijos en código sino que se leen del archivo de control A01-CONTROL: solo los registros de detalle con indicador de proceso foráneo INDPF igual a 1 se cargan en la tabla de sistemas (hasta un máximo implícito de 10). El registro con sistema 999 marca el fin del catálogo de sistemas.

**Fórmula/pseudocódigo:**
```
Por registro de A01-CONTROL:
   IF WKS-DET-INDPF = 1 → TAB-SIST(I) = WKS-DET-SIST ; TAB-FECPRO(I) = WKS-DET-FECPRO
   IF WKS-DET-SIST = 999 → fin
Proceso recorre TAB-SIST(1..10)
```

**Vocabulario en la fórmula:** WKS-DET-INDPF · WKS-DET-SIST · WKS-TAB-SIST · WKS-TAB-FECPRO

**Excepciones:**
- El proceso solo recorre 10 posiciones de la tabla; más de 10 sistemas foráneos no se procesarían.

**Estado validación:** Verificado fuente líneas 1291-1301, 1340-1349

---

## RN-S151-877 — Leyenda especial de subcuenta para el sistema 500

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-877 |
| **Nombre** | Leyenda especial de subcuenta para el sistema 500 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P113 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En el reporte de descuadres foráneos, la leyenda del renglón cambia específicamente para el sistema 500: cuando el sistema en proceso es 500 y el movimiento trae indicador de subcuenta INDSUBCTA igual a 1, se usa la leyenda de subcuenta (variante "SC"); en cualquier otro caso se usa la leyenda estándar. Aplica tanto al lado transmitido como al recibido.

**Fórmula/pseudocódigo:**
```
IF W77-SISTEMA = 500 AND INDSUBCTA = 1
   → WRS-D1-LEY = WKS-LEYENDA-{REC|TRA}-SC
ELSE
   → WRS-D1-LEY = WKS-LEYENDA-{REC|TRA}
```

**Vocabulario en la fórmula:** W77-SISTEMA (500) · A00-F01-INDSUBCTA · WKS-LEYENDA-REC-SC · WKS-LEYENDA-TRA-SC

**Excepciones:**
- El número 500 está embebido; la lógica de subcuenta está acoplada a ese sistema específico.

**Estado validación:** Verificado fuente líneas 1598-1602, 1644-1648

---

## RN-S151-878 — Punteo de saldos CitiDirect AHR vs ACC

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-878 |
| **Nombre** | Punteo de saldos CitiDirect AHR vs ACC |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P171 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P171 concilia los saldos entre el archivo AHR y el archivo ACC de la plataforma CitiDirect, análogo a P168 pero con la estructura de cuenta CitiDirect (ACCT-NBR2). Carga el archivo ACC en un archivo indexado ACC2 por cuenta, luego recorre AHR y por cada cuenta compara su saldo de mayor contra el saldo ACC. Las cuentas cuyo saldo no cuadra se graban en ARCH-CTAS para el reporte de auditoría de saldos.

**Fórmula/pseudocódigo:**
```
Carga ACC → ACC2 (indexado por ACC-CUENTA)
Por cuenta AHR (WKS-AHR-ACCT-NBR):
   READ ACC2 KEY = cuenta
   IF WKS-SALDO-T = ACC-SALDO → cuadra
   ELSE → 20170-GRABA-CTAS (descuadre)
```

**Vocabulario en la fórmula:** AHRST-ACCT-NBR2 · WKS-AHR-ACCT-NBR · AHRST-LDGR-AMT · ACC-SALDO · WKS-TOTREG-ARCH-CTAS

**Excepciones:**
- Difiere de P168 en que no genera archivos INTEL ni envío INTELAR (flujo CitiDirect puro de conciliación).

**Estado validación:** Verificado fuente líneas 1428-1531

---

## RN-S151-879 — Signo del saldo no comparado en el punteo CitiDirect

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-879 |
| **Nombre** | Signo del saldo no comparado en el punteo CitiDirect |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [BUG-LATENTE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P171 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** A diferencia de P168 (que compara saldo y signo), en P171 la comparación del signo del saldo (WKS-SSDO-T = ACC-SSDO) está comentada en el fuente. El punteo CitiDirect considera cuadrada una cuenta cuando el importe del saldo coincide, sin verificar el signo (naturaleza deudora/acreedora). Esto implica que dos cuentas con el mismo importe pero signo contrario (por ejemplo un saldo deudor vs acreedor de igual magnitud) se reportarían como cuadradas, ocultando un descuadre real de naturaleza.

**Fórmula/pseudocódigo:**
```
IF WKS-SALDO-T = ACC-SALDO
*  WKS-SSDO-T  = ACC-SSDO      ← LÍNEA COMENTADA
   → se considera cuadrada (sin validar signo)
```

**Vocabulario en la fórmula:** WKS-SALDO-T · ACC-SALDO · WKS-SSDO-T · ACC-SSDO

**Excepciones:**
- Riesgo contable: descuadres de solo signo no se detectan. Requiere validación con negocio antes de replicar en el sistema destino.

**Estado validación:** Verificado fuente líneas 1502-1507

---

## RN-S151-880 — Cuenta AHR sin contraparte en ACC tratada como saldo contable cero

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-880 |
| **Nombre** | Cuenta AHR sin contraparte en ACC tratada como saldo contable cero |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P171 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando una cuenta existe en AHR pero no se encuentra en el archivo ACC (INVALID KEY en ACC2), P171 la trata como un descuadre con saldo contable cero y signo positivo "+", grabándola en ARCH-CTAS con el saldo AHR completo como diferencia. Así toda cuenta de mayor sin registro contable se hace visible en el reporte de auditoría.

**Fórmula/pseudocódigo:**
```
20200-LEE-ACC2: IF INVALID KEY → W77-ACC = 1
IF W77-ACC <> 0 (no existe en ACC):
   WKS-SDO-ACC = 0 ; WKS-SSDO-ACC = "+"
   PERFORM 20170-GRABA-CTAS (descuadre)
```

**Vocabulario en la fórmula:** W77-ACC · WKS-SDO-ACC · WKS-SSDO-ACC · WKS-CTA-AHR

**Excepciones:**
- No se detecta el caso inverso (cuenta en ACC sin AHR) porque el recorrido es dirigido por AHR.

**Estado validación:** Verificado fuente líneas 1520-1541

---

## RN-S151-881 — Cálculo de diferencia y detalle de movimientos por cuenta descuadrada

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-881 |
| **Nombre** | Cálculo de diferencia y detalle de movimientos por cuenta descuadrada |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P171 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada cuenta descuadrada (guardada en ARCH-CTAS2), P171 imprime en el reporte AUDSDOSCTD la diferencia de saldos y luego el detalle de todos los movimientos de esa cuenta leídos de AHR (código de transacción, importe, naturaleza, saldo, referencias). La diferencia se calcula igual que en el punteo: mismo signo da la resta del mayor menos el menor, signo distinto da la suma de ambos saldos.

**Fórmula/pseudocódigo:**
```
IF SSDO-AHR = SSDO-ACC:
   DIFERENCIA = |SDO-AHR - SDO-ACC|
ELSE:
   DIFERENCIA = SDO-ACC + SDO-AHR
Luego 30400/30500: por cada movimiento AHR de la cuenta → imprime detalle
```

**Vocabulario en la fórmula:** WKS-SSDO-AHR · WKS-SSDO-ACC · WLI-DIFERENCIA · AHRST-TXN-CODE · AHRST-TXN-AMT

**Excepciones:**
- El detalle solo se imprime para cuentas presentes en ARCH-CTAS2 (las descuadradas).

**Estado validación:** Verificado fuente líneas 1623-1681

---

## RN-S151-882 — Bandera de terminación BANDE-171 y purga de archivo temporal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-882 |
| **Nombre** | Bandera de terminación BANDE-171 y purga de archivo temporal |
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
| **Programa ejecutor** | P171 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al terminar, P171 escribe un archivo bandera (ARCHIVO-P171 con el registro literal "BANDE-171") que sirve de señal de fin exitoso para el orquestador del batch (dependencias de WFL). Además cierra el archivo temporal de cuentas descuadradas ARCH-CTAS2 con PURGE, eliminándolo del disco por ser intermedio de trabajo.

**Fórmula/pseudocódigo:**
```
OPEN OUTPUT ARCHIVO-P171
MOVE "BANDE-171" TO REG-ARCH-171 ; WRITE ; CLOSE WITH SAVE
CLOSE ARCH-CTAS2 WITH PURGE
```

**Vocabulario en la fórmula:** ARCHIVO-P171 · REG-ARCH-171 · ARCH-CTAS2 · WITH PURGE

**Excepciones:**
- La bandera es un contrato implícito con el JCL/WFL; su ausencia bloquea pasos posteriores del batch.

**Estado validación:** Verificado fuente líneas 1590-1594

---

## RN-S151-883 — Depuración selectiva de la base contable S151BD13BIFIN

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-883 |
| **Nombre** | Depuración selectiva de la base contable S151BD13BIFIN |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P153 depura la base de datos contable S151BD13BIFIN eliminando registros históricos. Recorre y borra los sets: B01 TOTPROD, B03 ALARMAS, B02 POSICION, B07 PROTCOB, B10, B05 BATCH, B06 CTLENVIO, B08 TDMIGCAP y B09 TICKETSBN. Según el diseño, para B01, B03 y B06 se eliminan todos los registros cuya fecha es anterior al umbral, mientras que B02 y B05 se eliminan por fecha y estatus de envío. Cada set se recorre con LOCK FIRST / LOCK NEXT filtrando por fecha de información menor al umbral.

**Fórmula/pseudocódigo:**
```
LOCK FIRST/NEXT B0x  AT B0x-FECINF < WKS-FECHAOUT
   ON EXCEPTION NOTFOUND → SW = 1 (fin del set)
DELETE S151B0x
Orden: TOTPROD → ALARMAS → POSICION → PROTCOB → B10 → BATCH → CTLENVIO → TDMIGCAP → TICKETS
```

**Vocabulario en la fórmula:** BIFINDB · B01SXTOTPROD · B03SXALARMA · B02SXPRODINST · B05BATCH · B06CTLENVIO · WKS-FECHAOUT

**Excepciones:**
- Los globales B00-GLO-SISTBIFIN y B00-GLO-NCTLBIFIN se reinician antes de depurar (ver RN-S151-888).

**Estado validación:** Verificado fuente líneas 7-15, 904-956, 1068-1166

---

## RN-S151-884 — Umbral de retención por día hábil anterior

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-884 |
| **Nombre** | Umbral de retención por día hábil anterior |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El umbral de retención WKS-FECHAOUT se calcula como el día hábil anterior a la fecha de proceso, invocando DAME_ANTHAB2K de la librería FECHAS con clave de semana 65 y clave de festivos 1 (respeta calendario bancario y días inhábiles). Todo registro de los sets contables con fecha de información menor a ese umbral se elimina; los del día vigente se conservan.

**Fórmula/pseudocódigo:**
```
MOVE 65 TO WKS-CVESEM ; MOVE 1 TO WKS-CVEFEST
MOVE WKS-FECHA-PROCR TO WKS-FECHAIN
CALL "DAME_ANTHAB2K IN FECHAS" USING FECHAIN, FECHAOUT, CVESEM, CVEFEST
Criterio de borrado: FECINF < WKS-FECHAOUT
```

**Vocabulario en la fórmula:** DAME_ANTHAB2K · WKS-FECHAOUT · WKS-CVESEM (65) · WKS-CVEFEST (1) · WKS-FECHA-PROCR

**Excepciones:**
- La clave de semana 65 y festivos 1 son parámetros del calendario bancario Banamex.

**Estado validación:** Verificado fuente líneas 896-902

---

## RN-S151-885 — Retención extendida a 15 días para PROTCOB (B07) y TDMIGCAP (B08)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-885 |
| **Nombre** | Retención extendida a 15 días para PROTCOB (B07) y TDMIGCAP (B08) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Ciertos sets tienen una retención distinta al día hábil anterior. Para PROTCOB (B07) y TDMIGCAP (B08) el umbral se calcula proyectando la fecha de proceso hacia adelante o atrás una ventana de 15 (vía THECALENDAR de LOCSUP función 10, valor 15, formato 13), definiendo una retención de 15 días para esos protegidos de cobranza y capturas de migración, mayor que la del resto de los sets.

**Fórmula/pseudocódigo:**
```
0400-CALCULA-FECHA / 5900-CALCULA-FECHA-B08:
   WKS-CAL-FUNCION = 10 ; WKS-CAL-FECHA2 = 15 ; WKS-CAL-FORMATO = 13
   CALL "THECALENDAR OF LOCSUP" USING FUNCION, FECHA1, FECHA2, FORMATO
   IF FUNCION = 0 → WKS-FECHACALC = fecha proyectada a 15
```

**Vocabulario en la fórmula:** WKS-CAL-FUNCION · WKS-CAL-FECHA2 (15) · WKS-FECHACALC · THECALENDAR · B07SXFECHA

**Excepciones:**
- El valor 15 estaba antes en 2 (línea comentada JMLT), indicando cambio de política de retención.

**Estado validación:** Verificado fuente líneas 920-925, 957-971, 944

---

## RN-S151-886 — Commit por lotes de 100 registros en transacción no auditada

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-886 |
| **Nombre** | Commit por lotes de 100 registros en transacción no auditada |
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
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para controlar el tamaño de las transacciones de borrado y permitir reinicio, P153 confirma (END-TRANSACTION) cada 100 registros eliminados. Abre una transacción NO-AUDIT sobre el control de reinicio S151B99REINICTL cuando el contador de borrados es cero, y la cierra al llegar a 100 borrados o al terminar el set, reiniciando el contador. Esto acota el volumen por transacción y usa el dataset de reinicio como punto de recuperación.

**Fórmula/pseudocódigo:**
```
IF W77-BORRADOS = 0 → BEGIN-TRANSACTION NO-AUDIT S151B99REINICTL
DELETE ... ; NEXT ...
ADD 1 TO W77-BORRADOS
IF W77-BORRADOS = 100 OR SW-set = 1
   → MOVE 0 TO W77-BORRADOS ; END-TRANSACTION NO-AUDIT S151B99REINICTL
```

**Vocabulario en la fórmula:** W77-BORRADOS · BEGIN-TRANSACTION NO-AUDIT · END-TRANSACTION · S151B99REINICTL

**Excepciones:**
- El uso de NO-AUDIT implica que estos borrados masivos no generan pistas de auditoría DMSII.

**Estado validación:** Verificado fuente líneas 991-1066

---

## RN-S151-887 — Aborto controlado por interrupción HI entre bloques de depuración

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-887 |
| **Nombre** | Aborto controlado por interrupción HI entre bloques de depuración |
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
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P153 instala una rutina de interrupción (DECLARATIVES INTERRUPT-BY-HI) enganchada al EXCEPTIONEVENT de la tarea. Cuando el operador envía un HI con valor 4 (W88-HI-4), la rutina prepara una salida ordenada. Cada bloque de borrado se ejecuta con la condición de parar si W88-HI-4, y entre bloques se valida el HI (9999-VALIDA-HI). Esto permite detener la depuración de forma segura sin corromper la base, cerrando la transacción activa.

**Fórmula/pseudocódigo:**
```
DECLARATIVES INTERRUPT-BY-HI USE AS INTERRUPT PROCEDURE:
   DISALLOW INTERRUPT ; W77-HI = TASKVALUE
   IF W88-HI-4 → 800100-HI-SALIDA ; ALLOW INTERRUPT
Cada PERFORM ...-DELE-... UNTIL SW=1 OR W88-HI-4
Entre bloques: PERFORM 9999-VALIDA-HI
```

**Vocabulario en la fórmula:** INTERRUPT-BY-HI · W88-HI-4 · EXCEPTIONEVENT · 9999-VALIDA-HI

**Excepciones:**
- MCP-específico: ATTACH INTERRUPT y EXCEPTIONEVENT son mecanismos ClearPath MCP; requieren equivalente de cancelación cooperativa al migrar.

**Estado validación:** Verificado fuente líneas 814-823, 830, 909-956

---

## RN-S151-888 — Reinicialización de globales de control BIFIN

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-888 |
| **Nombre** | Reinicialización de globales de control BIFIN |
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
| **Programa ejecutor** | P153 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de depurar, P153 reinicializa los campos de control globales de la base contable: el arreglo B00-GLO-NCTLBIFIN (30 posiciones, contadores de control por sistema) se pone en ceros dentro de una transacción no auditada, tras hacer LOCK del registro global. Esto restablece los contadores de control BIFIN al inicio del ciclo de depuración.

**Fórmula/pseudocódigo:**
```
BEGIN-TRANSACTION NO-AUDIT S151B99REINICTL
   5400-LOCK-GLOB
   IF WKS-IERR = 0:
      PERFORM 0800-INICIALIZA-CAMPOS VARYING INDICE 1..30
          MOVE ZEROS TO B00-GLO-NCTLBIFIN(INDICE)
      5500-STORE-GLOB
END-TRANSACTION NO-AUDIT
```

**Vocabulario en la fórmula:** B00-GLO-NCTLBIFIN · B00-GLO-SISTBIFIN · W77-INDICE · WKS-IERR

**Excepciones:**
- Solo se reinicializan los 30 elementos del arreglo de control; el store solo ocurre si el LOCK fue exitoso.

**Estado validación:** Verificado fuente líneas 973-989

---

## RN-S151-889 — Exportación de datasets de control a archivos secuenciales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-889 |
| **Nombre** | Exportación de datasets de control a archivos secuenciales |
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
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P195 genera, a partir de la base de control S151BD99CONTROL, archivos planos secuenciales que contienen la información de los datasets B01SISDIA, B02ARCINTER, B03SISMEN, B04SISTEM, B05PROCESOS y B09CONXSIS. Cada dataset se recorre completo con FIND FIRST / FIND NEXT y cada registro se vuelca a su archivo de salida. Esto materializa la configuración del sistema para respaldo o transferencia a otras plataformas.

**Fórmula/pseudocódigo:**
```
OPEN INQUIRY S151BD99CONTROL
Por cada dataset B0x:
   FIND FIRST S151B0x (ON EXCEPTION NOTFOUND → EOF)
   PERFORM VACIA-B0x UNTIL EOF:
      MOVE S151B0x TO A0x-R00 ; WRITE ; FIND NEXT
   CLOSE A0x WITH SAVE
```

**Vocabulario en la fórmula:** S151BD99CONTROL · S151B01SISDIA · S151B02ARCINTER · S151B03SISMEN · FIND FIRST/NEXT

**Excepciones:**
- Si un dataset no tiene registros (NOTFOUND), su archivo se genera vacío.

**Estado validación:** Verificado fuente líneas 7-11, 851-867, 940-1023

---

## RN-S151-890 — Fecha de proceso común desde B01 para todos los archivos exportados

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-890 |
| **Nombre** | Fecha de proceso común desde B01 para todos los archivos exportados |
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
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La fecha de proceso que rotula todos los archivos exportados se obtiene una sola vez del primer registro de B01SISDIA (campo B01-SIS-FECPRO), y se propaga a las variables de fecha de todos los archivos (B01, B02, B03, B04, B05, B09). Adicionalmente, para Alta Disponibilidad, la fecha de proceso también se consulta vía CONSISDIA del sistema 151. Si no existe registro B01 (NOTFOUND), las fechas se ponen en ceros.

**Fórmula/pseudocódigo:**
```
CALL CONSISDIA sistema=151 → WKS-FECHA-PROC (B01-FECPRO151)
FIND FIRST S151B01SISDIA
IF NOTFOUND → todas las WKS-FECHA-B0x = ZERO
ELSE → B01-SIS-FECPRO → WKS-FECHA-B01..B09
```

**Vocabulario en la fórmula:** B01-SIS-FECPRO · WKS-FECHA-B01SISDIA · CONSISDIA · WKS-B01-FECPRO151

**Excepciones:**
- La fecha de todos los archivos depende del primer registro de B01; su ausencia deja las fechas en ceros.

**Estado validación:** Verificado fuente líneas 827-834, 942-981

---

## RN-S151-891 — Conversión de fecha CAMD a AMD condicionada por versión (Cronos 2000)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-891 |
| **Nombre** | Conversión de fecha CAMD a AMD condicionada por versión (Cronos 2000) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [GESTIÓN-VERSIONES] |
| **Confianza** | media |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de conversión de fecha coexiste en dos versiones controladas por directivas de compilación ($SET OMIT=OLDCODE / OMIT=NOT OLDCODE) de la renovación Cronos 2000. La versión antigua movía directamente B01-SIS-FECPRO a las fechas; la versión nueva convierte el formato CAMD (centuria-año-mes-día) a AMD mediante la rutina A2K-CONV-CAMD-TO-AMD antes de rotular los archivos. Solo una versión queda activa según la directiva de compilación.

**Fórmula/pseudocódigo:**
```
$SET OMIT=OLDCODE   → (código viejo: MOVE B01-SIS-FECPRO directo)
$SET OMIT=NOT OLDCODE →
   MOVE B01-SIS-FECPRO TO A2K-FEC-CAMD-001
   PERFORM A2K-CONV-CAMD-TO-AMD
   MOVE A2K-FEC-AMD-001 TO WKS-FECHA-B0x
```

**Vocabulario en la fórmula:** $SET OMIT=OLDCODE · A2K-FEC-CAMD-001 · A2K-CONV-CAMD-TO-AMD · A2K-FEC-AMD-001

**Excepciones:**
- MCP-específico: las directivas $SET OMIT son de compilación ClearPath; la migración debe fijar una única versión.

**Estado validación:** Verificado fuente líneas 962-983

---

## RN-S151-892 — Expansión de ciclos mensuales de bases en B03SISMEN

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-892 |
| **Nombre** | Expansión de ciclos mensuales de bases en B03SISMEN |
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
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al exportar B03SISMEN (control mensual por sistema), P195 expande las bases de datos por ciclo: para cada sistema recorre hasta 5 posiciones o hasta el número de ciclos mensuales declarado (B03-SIS-NUMCICMES), lo que ocurra primero, armando los nombres de bases de saldos e histórico de movimientos por ciclo. Tras escribir el registro limpia las variables de nombres de bases para el siguiente sistema.

**Fórmula/pseudocódigo:**
```
PERFORM 04-00111-BASES-CICLO VARYING IND FROM 1 BY 1
   UNTIL IND > 5 OR IND > B03-SIS-NUMCICMES
WRITE A03-R00-SISMEN
PERFORM 04-00112-LIMPIA-VAR-BASES VARYING IND2 ...
   UNTIL IND2 > 5 OR IND2 > B03-SIS-NUMCICMES
```

**Vocabulario en la fórmula:** B03-SIS-NUMCICMES · A03-R00-NOMBDSAL · A03-R00-NOMBDMOVHI · 04-00111-BASES-CICLO

**Excepciones:**
- El máximo de 5 ciclos está embebido; sistemas con más de 5 ciclos mensuales quedarían truncados.

**Estado validación:** Verificado fuente líneas 1040-1071

---

## RN-S151-893 — Control B05 de Alta Disponibilidad en la exportación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-893 |
| **Nombre** | Control B05 de Alta Disponibilidad en la exportación |
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
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Bajo Alta Disponibilidad, cuando la tarea corre con TASKVALUE igual a 1 (W77-VALUE=1), P195 verifica el registro de control de proceso B05 antes de generar los archivos y actualiza su estatus a 1 al finalizar. Esto coordina el reproceso de la exportación en el esquema de clúster, evitando duplicidad y marcando la terminación del paso.

**Fórmula/pseudocódigo:**
```
W77-VALUE = ATTRIBUTE TASKVALUE OF MYSELF
IF W77-VALUE = 1 → 08-01000-VERIFICA-B05  (antes de exportar)
...generación de archivos...
IF W77-VALUE = 1 → 08-01200-ACTUALIZA-B05  (estatus = 1 al terminar)
```

**Vocabulario en la fórmula:** W77-VALUE · ATTRIBUTE TASKVALUE · VERIFICA-B05 · ACTUALIZA-B05

**Excepciones:**
- Si TASKVALUE no es 1, la exportación corre sin control B05 (ejecución fuera del esquema de alta disponibilidad).

**Estado validación:** Verificado fuente líneas 746-747, 852-866

---

## RN-S151-894 — Asignación errónea de secuencia de error a campo de información (B03)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-894 |
| **Nombre** | Asignación errónea de secuencia de error a campo de información (B03) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [BUG-LATENTE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P195 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al armar el registro de exportación de B03SISMEN, el campo de secuencia de error del histórico (B03-SIS-SECERRHI) se mueve al campo de secuencia de información (A03-R00-SECINFHI), que ya había recibido B03-SIS-SECINFHI en la línea anterior. El campo destino de secuencia de error (A03-R00-SECERRHI) nunca se llena y el valor de SECINFHI se sobrescribe. Es una asignación cruzada sospechosa que produce datos incorrectos en el archivo exportado.

**Fórmula/pseudocódigo:**
```
MOVE B03-SIS-SECINFHI TO A03-R00-SECINFHI
MOVE B03-SIS-SECERRHI TO A03-R00-SECINFHI   ← sobrescribe con secuencia de error
(A03-R00-SECERRHI queda sin asignar)
```

**Vocabulario en la fórmula:** B03-SIS-SECERRHI · B03-SIS-SECINFHI · A03-R00-SECINFHI

**Excepciones:**
- Requiere confirmación con negocio: puede ser intencional (colapso de secuencias) o defecto. Marcar para validación en equivalencia.

**Estado validación:** Verificado fuente líneas 1055-1057

---

## RN-S151-895 — Reimpresión de backups desde archivo pre-formateado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-895 |
| **Nombre** | Reimpresión de backups desde archivo pre-formateado |
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
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P170 toma como entrada un archivo pre-formateado generado por los pasos P106, P108, P109 o P158 y reimprime los backups (listados) que ese archivo tiene grabados línea por línea. Reproduce el listado hacia un backup de impresión y a un archivo de disco I01-MOVIMIENTOS. El número de sistema se recibe por parámetro para rotular los listados.

**Fórmula/pseudocódigo:**
```
OPEN INPUT ARCHIVOENT ; OPEN OUTPUT I01-MOVIMIENTOS
READ ARCHIVOENT INTO REG-IMPRESION
PERFORM 02-0150-IMPRIME-BACKUPS UNTIL EOF:
   interpreta control de impresión ; WRITE LINEA-REP-MOVTOS
   READ ARCHIVOENT
```

**Vocabulario en la fórmula:** ARCHIVOENT · REG-IMPRESION · LINEA-IMPRESION · I01-MOVIMIENTOS · WKS-PARAM-SIS

**Excepciones:**
- No transforma datos contables; solo materializa listados ya calculados por los pasos previos.

**Estado validación:** Verificado fuente líneas 7-16, 986-990, 1100-1148

---

## RN-S151-896 — Códigos de control de impresión embebidos en el archivo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-896 |
| **Nombre** | Códigos de control de impresión embebidos en el archivo |
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
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El propio archivo de entrada trae códigos de control de impresión al inicio de cada línea. Cuando la opción1 es "INICI" y la opción2 es "BACK" se cierra el backup en curso y se abre uno nuevo. Cuando la opción2 es "PAGE" se hace salto de página antes de escribir; en otro caso se avanzan tantas líneas como indica la opción2 numérica. Así el espaciado y la segmentación del listado están gobernados por datos, no por lógica de programa.

**Fórmula/pseudocódigo:**
```
IF OPCION1 = "INICI" AND OPCION2 = "BACK":
   IF backup abierto → CLOSE MOVIMIENTOS WITH SAVE
   abre nuevo backup con título = LINEA-IMPRESION
ELSE IF OPCION2 = "PAGE" → WRITE ... AFTER PAGE
ELSE → WRITE ... AFTER WKS-OPCION2-NUM
```

**Vocabulario en la fórmula:** WKS-OPCION1-IMP · WKS-OPCION2-IMP · WKS-OPCION2-NUM · W88-BACK-ABIERTO

**Excepciones:**
- La semántica de "INICI"/"BACK"/"PAGE" es un contrato de formato compartido con P106/P108/P109/P158.

**Estado validación:** Verificado fuente líneas 1115-1137

---

## RN-S151-897 — Título dinámico por backup impreso (USERBACKUPNAME)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-897 |
| **Nombre** | Título dinámico por backup impreso (USERBACKUPNAME) |
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
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada listado se materializa como un archivo de backup de impresión independiente cuyo título se asigna dinámicamente en tiempo de ejecución con el contenido de la línea de control (CHANGE ATTRIBUTE TITLE OF MOVIMIENTOS TO LINEA-IMPRESION), usando el atributo USERBACKUPNAME de ClearPath MCP. Al detectar el inicio de un nuevo listado se cierra el backup previo con SAVE y se abre otro con el nuevo título.

**Fórmula/pseudocódigo:**
```
SET MOVIMIENTOS(USERBACKUPNAME) TO VALUE TRUE
CHANGE ATTRIBUTE TITLE OF MOVIMIENTOS TO LINEA-IMPRESION
OPEN OUTPUT MOVIMIENTOS
...al fin o nuevo listado: CLOSE MOVIMIENTOS WITH SAVE
```

**Vocabulario en la fórmula:** USERBACKUPNAME · CHANGE ATTRIBUTE TITLE · MOVIMIENTOS · W88-BACK-ABIERTO

**Excepciones:**
- MCP-específico: USERBACKUPNAME y títulos dinámicos de printer backup no tienen equivalente directo fuera de MCP; requieren rediseño de la estrategia de impresión al migrar.

**Estado validación:** Verificado fuente líneas 1107, 1127-1131, 1159-1162

---

## RN-S151-898 — Identificación de tipo de listado (bitácora vs movimientos por contrato)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-898 |
| **Nombre** | Identificación de tipo de listado (bitácora vs movimientos por contrato) |
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
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P170 se parametriza con un nombre de identificación de paso (WKS-NOMBRE-IDPASO) que distingue si el listado corresponde a una bitácora (generada por P106, P108 o P109) o a MOVXCONT (movimientos por contrato). Ese identificador se propaga a los títulos de los archivos de salida (WKS-ID-PASO, WKS-ID-INMOVPASO), permitiendo que un mismo programa reimprima ambos tipos de listado según el parámetro.

**Fórmula/pseudocódigo:**
```
MOVE WKS-NOMBRE-IDPASO TO WKS-ID-PASO, WKS-ID-INMOVPASO
(bitácora ← P106/P108/P109 ; MOVXCONT ← movimientos por contrato)
```

**Vocabulario en la fórmula:** WKS-NOMBRE-IDPASO · WKS-ID-PASO · WKS-ID-INMOVPASO

**Excepciones:**
- El significado de cada nombre depende del paso generador que produjo el archivo de entrada.

**Estado validación:** Verificado fuente líneas 12-15, 966-967

---

## RN-S151-899 — Resolución de fecha de proceso con doble conversión AMD/CAMD

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-899 |
| **Nombre** | Resolución de fecha de proceso con doble conversión AMD/CAMD |
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
| **Programa ejecutor** | P170 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P170 obtiene la fecha de proceso del sistema (parámetro WKS-PARAM-SIS) consultando B01 (CONSISDIA) y, si la tarea trae fecha en su atributo VALUE, usa esa. Para rotular los archivos de salida convierte la fecha entre formatos: la fecha de ejecución (hoy) de AMD a CAMD para la fecha de corrida, y la fecha de proceso de CAMD a AMD para el nombre de los archivos de movimientos por contrato. También toma el nombre del pack de movimientos desde B01.

**Fórmula/pseudocódigo:**
```
CALL CONSISDIA sistema=WKS-PARAM-SIS
IF MYSELF VALUE = 0 → pack = B01-NOMPACMOV
ELSE → fecha proceso = MYSELF VALUE ; pack = B01-NOMPACMOV
Fecha ejecución: AMD → CAMD (fecha de corrida)
Fecha proceso:   CAMD → AMD (título MOVSXCONT)
```

**Vocabulario en la fórmula:** WKS-PARAM-SIS · WKS-B01-NOMPACMOV · A2K-CONV-AMD-TO-CAMD · A2K-CONV-CAMD-TO-AMD · WKS-FEC-MOVSXCONTLM

**Excepciones:**
- La fecha de proceso puede provenir del atributo VALUE de la tarea (reejecución con fecha específica).

**Estado validación:** Verificado fuente líneas 1048-1086

---

## RN-S151-900 — Depuración de B05 de control por modo de operación

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-900 |
| **Nombre** | Depuración de B05 de control por modo de operación |
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
| **Programa ejecutor** | P196 (DEPURACTL) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P196 depura los registros B05 de control creados en el lote para el esquema de Alta Disponibilidad. Opera en tres modos según el TASKVALUE de la tarea (WKS-MODO): modo 1 regresa la fecha (restaura fecha de proceso), modo 2 mantiene la fecha del sistema 500, y cualquier otro modo ejecuta el proceso normal de eliminación/actualización de B05. Recibe por parámetro sistema, fecha, número de proceso y registro inicial.

**Fórmula/pseudocódigo:**
```
WKS-MODO = ATTRIBUTE TASKVALUE OF MYSELF
IF WKS-MODO = 1 → 000150-REGRESO-FECHA
ELSE IF WKS-MODO = 2 → 000140-MANTEN-FECHA-S500
ELSE → 000200-PROCESO (depura B05)
```

**Vocabulario en la fórmula:** WKS-MODO · ATTRIBUTE TASKVALUE · B05SXPROCESO · WKS-PARAM-SISTEMA

**Excepciones:**
- Entrada documentada: SISTEMA(3), FECHA(8), NUMERO PROCESO(3), REGINI(2).

**Estado validación:** Verificado fuente líneas 5-8, 739-748, 824

---

## RN-S151-901 — Eliminación puntual de B05 por parámetros específicos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-901 |
| **Nombre** | Eliminación puntual de B05 por parámetros específicos |
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
| **Programa ejecutor** | P196 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando se recibe una fecha de parámetro mayor a cero, P196 elimina/actualiza un registro B05 puntual identificado por sistema, fecha de proceso, número de proceso y registro inicial, invocando B05PROCESOS de la librería de control. El resultado se registra en bitácora indicando si el B05 se eliminó/actualizó correctamente o no.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-FECHA > 0:
   000230-ELIMINA-ACTUALIZA
   B05: SISTEMA=PARAM-SISTEMA, FCHPRO=PARAM-FECHA,
        NUMPRO=PARAM-NUMPRO, NUMREGINI=PARAM-NUMREGINI
   CALL "B05PROCESOS IN LIBCTL"
   log éxito/error
```

**Vocabulario en la fórmula:** WKS-PARAM-FECHA · WKS-B05-SISTEMA · WKS-B05-FCHPRO · WKS-B05-NUMPRO · B05PROCESOS

**Excepciones:**
- Si no se recibe fecha, se aplica la depuración masiva por fecha proyectada (ver RN-S151-902).

**Estado validación:** Verificado fuente líneas 831-857

---

## RN-S151-902 — Depuración masiva de B05 por listas de procesos según sistema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-902 |
| **Nombre** | Depuración masiva de B05 por listas de procesos según sistema |
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
| **Programa ejecutor** | P196 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Sin fecha de parámetro, P196 depura de forma masiva los B05 anteriores a la fecha proyectada. Para el sistema 151 usa la tabla de procesos "PRELINEA" recorriendo 4 procesos más un tratamiento especial del proceso previo del sistema 500; para el resto de sistemas usa la tabla "NNN" recorriendo 9 procesos. Cada proceso elimina sus B05 cuya fecha de proceso es menor a la fecha proyectada y mayor a 3 (evita fechas centinela), bajo LOCK y en transacción no auditada.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SISTEMA = 151:
   tabla = WKS-PROCESOSLIN ; PERFORM ELIMINA-B05 IND 1..4
   + ELI-B05-PRELIN500 + ACT-B05-P196-PRELINEA
ELSE:
   tabla = WKS-PROCESOSNNN ; PERFORM ELIMINA-B05 IND 1..9
LOCK B05SXPROCESO AT SISTEMA=param AND FCHPRO < FEC-ANT AND FCHPRO > 3
   AND NUMPRO = proceso AND NUMREGINI = W77-REGINI
DELETE S151B05PROCESOS
```

**Vocabulario en la fórmula:** WKS-PROCESOSLIN · WKS-PROCESOSNNN · B05-SIS-FCHPRO · WKS-FEC-ANT · B05-SIS-NUMREGINI

**Excepciones:**
- La condición FCHPRO > 3 protege registros con fechas de control especiales (0..3).

**Estado validación:** Verificado fuente líneas 859-939

---

## RN-S151-903 — Proyección de la fecha hábil anterior para el umbral de depuración

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-903 |
| **Nombre** | Proyección de la fecha hábil anterior para el umbral de depuración |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P196 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El umbral de depuración WKS-FEC-ANT se calcula proyectando la fecha de proceso (WKS-FECPRO151) mediante THECALENDAR de LOCSUP con función 15 y formato 13, obteniendo una fecha hábil de referencia. Si la rutina de calendario retorna error (función mayor a cero), el programa aborta con estatus -1. Este cálculo respeta el calendario bancario para no depurar registros de días hábiles vigentes.

**Fórmula/pseudocódigo:**
```
WKS-FECHA1 = WKS-FECPRO151
W77-FUNCION = 15 ; WKS-FECHA2 = "00000001" ; W77-FORMATO = 13
CALL "THECALENDAR IN LOCSUP" USING FUNCION, FECHA1, FECHA2, FORMATO
IF W77-FUNCION > 0 → error de calendar ; STATUS = -1
ELSE → WKS-FEC-ANT = WKS-FECHA1
```

**Vocabulario en la fórmula:** THECALENDAR · W77-FUNCION (15) · W77-FORMATO (13) · WKS-FEC-ANT · WKS-FECPRO151

**Excepciones:**
- Un error en el cálculo de fecha detiene toda la depuración (dependencia dura del calendario).

**Estado validación:** Verificado fuente líneas 941-967

---

## RN-S151-904 — Tratamiento diferenciado de procesos 196 (REGINI) y 197 (marca sin borrar)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-904 |
| **Nombre** | Tratamiento diferenciado de procesos 196 (REGINI) y 197 (marca sin borrar) |
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
| **Programa ejecutor** | P196 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Dentro de la depuración masiva, dos números de proceso reciben trato especial. El proceso 196 fija el registro inicial de búsqueda en 1 (W77-REGINI=1) en lugar de cero. El proceso 197 no se elimina: en su lugar se marca su registro poniendo B05-SIS-FCHINI en 1 y se re-almacena (STORE), preservándolo como referencia de reinicio en vez de borrarlo.

**Fórmula/pseudocódigo:**
```
IF WKS-PROCESO(IND) = 196 → W77-REGINI = 1
...delete normal de los demás...
IF WKS-PROCESO(IND) = 197:
   LOCK FIRST B05SXPROCESO por (sistema, FEC-ANT, 197)
   IF encontrado → MOVE 1 TO B05-SIS-FCHINI ; STORE (no DELETE)
```

**Vocabulario en la fórmula:** WKS-PROCESO · W77-REGINI · B05-SIS-FCHINI · S151B05PROCESOS

**Excepciones:**
- Los números 196 y 197 están embebidos; representan al propio depurador y a un proceso conservado.

**Estado validación:** Verificado fuente líneas 875-903

---

## RN-S151-905 — Alta automática de B01SISDIA del sistema 151 con fecha fija

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-905 |
| **Nombre** | Alta automática de B01SISDIA del sistema 151 con fecha fija |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-05 |
| **bian_ref** | 5.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P196 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si al consultar B01SISDIA del sistema 151 el registro no existe (resultado 1), P196 lo crea automáticamente (función 19, MANTSISDIA) inicializando las fechas de proceso, proceso 151 y contable a la constante 20150525. Esta fecha fija embebida es un valor de bootstrap; si la lógica se ejecutara tras ese registro faltar, quedaría con una fecha histórica hardcodeada de mayo de 2015.

**Fórmula/pseudocódigo:**
```
IF WKS-PARAM-SISTEMA = 151 AND W77-RESULT-LIBCON = 1:
   MOVE 19 TO WKS-B01-FUNCION
   MOVE 20150525 TO WKS-B01-FECPRO, WKS-B01-FECPRO151, WKS-B01-FECCON
   CALL "MANTSISDIA IN LIBCTL"
```

**Vocabulario en la fórmula:** WKS-B01-FUNCION (19) · WKS-B01-FECPRO (20150525) · MANTSISDIA · WKS-PARAM-SISTEMA (151)

**Excepciones:**
- Fecha 20150525 hardcodeada; requiere validación de negocio y parametrización antes de migrar.

**Estado validación:** Verificado fuente líneas 793-804

---

## RN-S151-906 — Determinación de nodos origen/destino por topología de hosts

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-906 |
| **Nombre** | Determinación de nodos origen/destino por topología de hosts |
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
| **Programa ejecutor** | P102 (CALLLIBCTL) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P102 transfiere archivos entre equipos Unisys. El nodo origen y el nodo destino se determinan a partir del nombre del host donde corre (WKS-NOM-HOST), mediante una topología de pares fija: ACYPGAMA↔MONALFA, VDMALFA↔MONBETA, ACYPBETA↔VDMBETA y ACYPOMEGA↔VDMKAPPA. Cada host tiene un contraparte definido para el enrutamiento del archivo.

**Fórmula/pseudocódigo:**
```
CASE WKS-NOM-HOST:
   "ACYPGAMA." → ORI=ACYPGAMA  DES=MONALFA
   "MONALFA."  → ORI=MONALFA   DES=ACYPGAMA
   "VDMALFA."  → ORI=VDMALFA   DES=MONBETA
   "MONBETA."  → ORI=MONBETA   DES=VDMALFA
   "ACYPBETA." → ORI=ACYPBETA  DES=VDMBETA
   "VDMBETA."  → ORI=VDMBETA   DES=ACYPBETA
   "ACYPOMEGA."→ ORI=ACYPOMEGA DES=VDMKAPPA
   "VDMKAPPA." → ORI=VDMKAPPA  DES=ACYPOMEGA
```

**Vocabulario en la fórmula:** WKS-NOM-HOST · WKS-NODO-ORI · WKS-NODO-DES

**Excepciones:**
- La topología de nodos está embebida en código; agregar equipos requiere modificar el fuente.

**Estado validación:** Verificado fuente líneas 745-777

---

## RN-S151-907 — Ruteo especial a usercode S702 para archivos de contabilidad en CSI 10/12

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-907 |
| **Nombre** | Ruteo especial a usercode S702 para archivos de contabilidad en CSI 10/12 |
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
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Ciertos archivos contables se redirigen al usercode destino S702 en lugar del ruteo estándar. Cuando el archivo es PROTCOB, o es uno de los archivos S500ALRCD, S701OCMCD, S500AHRCD o S500ACCCD y el CSI es 10 o 12, el usercode destino se fuerza a S702 y el nodo destino se ajusta según el host origen. Esto dirige información de alertas, avisos y saldos S500/S701 al ambiente S702.

**Fórmula/pseudocódigo:**
```
IF NOM-S015 = "S151/FILE/PROTCOB/"
   OR (NOM-S151 IN {S500ALRCD, S701OCMCD, S500AHRCD, S500ACCCD}
       AND WKS-NUMCSI IN {10, 12}):
   WKS-USER-TARG = "S702"
IF USER-TARG = "S702": ajusta NODO-DES según NOM-HOST
```

**Vocabulario en la fórmula:** WKS-NOM-S015 · WKS-NOM-S151 · WKS-NUMCSI (10/12) · WKS-USER-TARG (S702)

**Excepciones:**
- Las rutas de archivo y el CSI 10/12 están embebidos (cambio VL38112 2020).

**Estado validación:** Verificado fuente líneas 779-810

---

## RN-S151-908 — Ruteo a usercode S028 para archivo de movimientos por terminal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-908 |
| **Nombre** | Ruteo a usercode S028 para archivo de movimientos por terminal |
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
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el archivo a transferir es el de movimientos por terminal (S711/FILE/MOVSXTERM), P102 fuerza el usercode destino a S028 y valida el nodo destino según el host origen, recorriendo la misma topología de equipos. Esto dirige los movimientos por terminal del sistema S711 al ambiente S028.

**Fórmula/pseudocódigo:**
```
IF WKS-NOM-S028 = "S711/FILE/MOVSXTERM/":
   WKS-USER-TARG = "S028"
   PERFORM 000400-VALIDA-NODO (mapea NODO-DES según NOM-HOST)
```

**Vocabulario en la fórmula:** WKS-NOM-S028 · WKS-USER-TARG (S028) · 000400-VALIDA-NODO

**Excepciones:**
- La ruta S711/FILE/MOVSXTERM está embebida como disparador del ruteo S028.

**Estado validación:** Verificado fuente líneas 812-814, 833-856

---

## RN-S151-909 — Ejecución de transferencia XFER con fallback a copia manual

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-909 |
| **Nombre** | Ejecución de transferencia XFER con fallback a copia manual |
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
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La transferencia se ejecuta llamando a ENVIA_XFER de la librería XFER con el comando armado (título de archivo de captura, longitud 193). Si el resultado es mayor a cero (error), P102 no aborta sino que emite un mensaje al operador solicitando copiar manualmente el archivo indicado, degradando de forma controlada la automatización de la transferencia.

**Fórmula/pseudocódigo:**
```
MOVE WKS-TITULO-ARCH-CAP TO WS-TRF-COMANDO
MOVE 193 TO WS-TRF-TAMACOM
CALL "ENVIA_XFER IN XFER" USING COMANDO, TAMACOM GIVING WS-TRF-RESULT
IF WS-TRF-RESULT > 0 →
   log "ERROR ... FAVOR DE COPIAR MANUALMENTE EL ARCHIVO ..."
```

**Vocabulario en la fórmula:** ENVIA_XFER · WS-TRF-COMANDO · WS-TRF-TAMACOM (193) · WS-TRF-RESULT · WKS-TITULO-ARCH-CAP

**Excepciones:**
- El fallback es manual (operador); no hay reintento automático de la transferencia.

**Estado validación:** Verificado fuente líneas 816-832

---

## RN-S151-910 — Replicación del nombre de archivo en múltiples usercodes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-910 |
| **Nombre** | Replicación del nombre de archivo en múltiples usercodes |
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
| **Programa ejecutor** | P102 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El nombre de archivo recibido por parámetro se replica en varias variables asociadas a distintos usercodes (S015, S028, S151, ARTG) para permitir que la lógica de ruteo evalúe el archivo contra los patrones de cada sistema y decida el usercode y nodo destino. Un mismo archivo físico puede así ser reconocido bajo varias convenciones de nombre de sistema.

**Fórmula/pseudocódigo:**
```
MOVE WKS-ARCHIVO TO WKS-NOMB-ARCH, WKS-NOM-S015,
                    WKS-NOM-S028, WKS-NOM-S151, WKS-NOMB-ARTG
(cada variable se compara contra los patrones de su sistema en el ruteo)
```

**Vocabulario en la fórmula:** WKS-ARCHIVO · WKS-NOM-S015 · WKS-NOM-S028 · WKS-NOM-S151 · WKS-NOMB-ARTG

**Excepciones:**
- La marca LDRM-SOFTTEK-CC2020 indica que WKS-NOM-S151 fue añadido en un cambio posterior.

**Estado validación:** Verificado fuente líneas 711-717

---

## RN-S151-911 — Depuración de directorios en disco dirigida por archivo de control

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-911 |
| **Nombre** | Depuración de directorios en disco dirigida por archivo de control |
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
| **Programa ejecutor** | P194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P194 elimina archivos de disco leyendo de un archivo de control (S151/FILE/I10/DEPURAR/DIRECTORIOS) la lista de directorios a depurar. Cada renglón se separa por puntos en usuario, directorio, pack, CSI y días de retención. Con esos datos arma el título del directorio y llama a REMUEVE_ARCHIVOS de la librería BORRA para eliminar los archivos anteriores a la fecha de retención calculada.

**Fórmula/pseudocódigo:**
```
Por renglón A01-REG-DIR:
   UNSTRING por "." → USER, DIR, PACK, CSI, DIAS
   STRING → "(USER)DIR ON PACK."
   CALL "REMUEVE_ARCHIVOS IN BORRA" USING DIRECTORIO, REM-FECHA
```

**Vocabulario en la fórmula:** A01-DIR-INPUT · A01-REG-DIR · WKS-DIRECTORIO · REMUEVE_ARCHIVOS · WKS-REM-FECHA

**Excepciones:**
- La retención por directorio se conserva usando la fecha de último acceso del archivo.

**Estado validación:** Verificado fuente líneas 6-16, 693-698, 814-853

---

## RN-S151-912 — Política de retención: 1 día en producción, N días en otros equipos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-912 |
| **Nombre** | Política de retención: 1 día en producción, N días en otros equipos |
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
| **Programa ejecutor** | P194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La ventana de retención depende del ambiente. En equipos de producción (W88-EQUIPO-PRODUCCION) se conserva solo 1 día de información en disco, forzando WKS-DIAS-NUM a 1 sin importar lo declarado en el archivo. En los demás equipos (pruebas: ACYPBETA, VDMBETA, ACYPGAMA, MONALFA, ACYPOMEGA, VDMKAPPA, ACYPDELTA) se respeta el número de días indicado en el archivo de control, con una fecha base adicional desplazada 4 días.

**Fórmula/pseudocódigo:**
```
IF W88-EQUIPO-PRODUCCION → WKS-DIAS-NUM = 1
IF equipo IN {ACYPBETA, VDMBETA, ACYPGAMA, MONALFA, ACYPOMEGA, VDMKAPPA, ACYPDELTA}:
   EQUIPO-PRUEBAS = 1 ; WKS-FECHA = FECHAOUT - 4
Selección de fecha de remoción según DIAS (1..4)
```

**Vocabulario en la fórmula:** W88-EQUIPO-PRODUCCION · W77-EQUIPO-PRUEBAS · WKS-DIAS-NUM · WKS-NOMEQUIPO

**Excepciones:**
- Versión 21MTP002 (2021): se suprimió la proyección de 1 día atrás y se dejó 1 día de retención en producción.

**Estado validación:** Verificado fuente líneas 761-793, 830-844

---

## RN-S151-913 — Cálculo de fechas de retención 1 a 4 días vía calendario y juliana

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-913 |
| **Nombre** | Cálculo de fechas de retención 1 a 4 días vía calendario y juliana |
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
| **Programa ejecutor** | P194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P194 precalcula cuatro fechas de retención (WKS-FECHA-1 a WKS-FECHA-4) proyectando hacia atrás mediante THECALENDAR de LOCSUP (función 15, formato 13) y convirtiéndolas a formato juliano con VALY_CAMBIAFORM. Al depurar cada directorio, según los días de retención (1 a 4) se selecciona la fecha correspondiente como fecha de remoción; cualquier valor fuera de 1-4 usa la fecha de 1 día.

**Fórmula/pseudocódigo:**
```
0150-CALCULA-FECHA-ATRAS (x4):
   CALL THECALENDAR func=15 formato=13 → fecha atrás
   CALL VALY_CAMBIAFORM (formin=5, formout=6) → fecha juliana
Selección: DIAS=1→FECHA-1 ; =2→FECHA-2 ; =3→FECHA-3 ; =4→FECHA-4 ; else→FECHA-1
```

**Vocabulario en la fórmula:** 0150-CALCULA-FECHA-ATRAS · THECALENDAR · VALY_CAMBIAFORM · WKS-FECHA-JULIANA · WKS-REM-FECHA

**Excepciones:**
- La fecha de proceso base proviene de B01 del sistema 500 (CONSISDIA) o del atributo VALUE de la tarea.

**Estado validación:** Verificado fuente líneas 759-812, 830-844

---

## RN-S151-914 — Filtro de depuración por CSI del equipo (coincidencia o CSI 32)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-914 |
| **Nombre** | Filtro de depuración por CSI del equipo (coincidencia o CSI 32) |
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
| **Programa ejecutor** | P194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Un directorio del archivo de control solo se depura si el CSI del equipo donde corre P194 coincide con el CSI declarado para ese directorio, o si el CSI de ejecución es 32 (CSI maestro que puede depurar cualquier directorio). Esto evita que un equipo borre directorios que pertenecen a otro CSI, salvo el CSI 32 con alcance global.

**Fórmula/pseudocódigo:**
```
IF WKS-NUMCSI = WKS-CSI-NUM OR WKS-NUMCSI = 32:
   DISPLAY WKS-DIRECTORIO
   CALL "REMUEVE_ARCHIVOS IN BORRA" USING DIRECTORIO, REM-FECHA
```

**Vocabulario en la fórmula:** WKS-NUMCSI · WKS-CSI-NUM · WKS-CSI (32)

**Excepciones:**
- El CSI 32 actúa como comodín; representa un equipo con alcance de depuración global.

**Estado validación:** Verificado fuente líneas 846-853

---

## RN-S151-915 — Armado del título de directorio a depurar

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-915 |
| **Nombre** | Armado del título de directorio a depurar |
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
| **Programa ejecutor** | P194 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El título del directorio a depurar se construye en formato de nombre de archivo ClearPath MCP a partir de los campos parseados del archivo de control: usuario entre paréntesis, ruta de directorio, la palabra " ON " y el pack, terminado en punto. Ese título completo se pasa a la rutina de borrado junto con la fecha de retención.

**Fórmula/pseudocódigo:**
```
STRING "(" USER ")" DIR " ON " PACK "." → WKS-DIRECTORIO
Ej.: "(S151)S151/FILE/... ON CMEMP."
```

**Vocabulario en la fórmula:** WKS-USER · WKS-DIR · WKS-PACK · WKS-DIRECTORIO

**Excepciones:**
- MCP-específico: el formato "(user)file ON pack." es propio de ClearPath MCP; requiere traducción de convención de nombres al migrar.

**Estado validación:** Verificado fuente líneas 816-828

---

## RN-S151-916 — Modos de operación del proyector de fecha corporativa (consulta/proyecta)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-916 |
| **Nombre** | Modos de operación del proyector de fecha corporativa (consulta/proyecta) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P103 (S151 contabilidad GL) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P103 (variante contabilidad GL de S151, distinta del P103 de S500 FraudLink) proyecta la fecha de proceso del S151 en el CSI corporativo. Opera en dos modos según el parámetro: parámetro 01 ejecuta la consulta de la fecha de proceso vigente; parámetro 02 ejecuta la proyección de la próxima fecha, la verificación de estatus de los sistemas y la actualización del archivo de control corporativo.

**Fórmula/pseudocódigo:**
```
IF W77-PARAMETRO = 01 → 000050-CONSULTA
ELSE IF W77-PARAMETRO = 02 → 000080-PROYECTA
```

**Vocabulario en la fórmula:** W77-PARAMETRO · 000050-CONSULTA · 000080-PROYECTA · A01-CONTROL

**Excepciones:**
- Parámetros distintos de 01/02 no ejecutan ninguna acción (solo STOP RUN).

**Estado validación:** Verificado fuente líneas 7-11, 314-329

---

## RN-S151-917 — Consulta y publicación de la fecha de proceso corporativa

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-917 |
| **Nombre** | Consulta y publicación de la fecha de proceso corporativa |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P103 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En modo consulta, P103 lee el registro header del archivo de control corporativo (S151/FILE/CONTROL/CORP), extrae la fecha de proceso (WKS-HD-FECPRO) y la publica hacia el orquestador del batch asignándola al atributo VALUE de la propia tarea (en formato de 6 dígitos). Así otros pasos del WFL pueden obtener la fecha de proceso vigente del sistema.

**Fórmula/pseudocódigo:**
```
OPEN INPUT A01-CONTROL ; READ header
MOVE WKS-HD-FECPRO TO W77-FECHA-PROCESO, WKS-FECHA8D
CHANGE ATTRIBUTE VALUE OF MYSELF TO WKS-FEC-6D
CLOSE A01-CONTROL WITH SAVE
```

**Vocabulario en la fórmula:** WKS-HD-FECPRO · ATTRIBUTE VALUE OF MYSELF · WKS-FEC-6D · WKS-FECHA8D

**Excepciones:**
- MCP-específico: la publicación por ATTRIBUTE VALUE (task value) es el mecanismo de paso de datos al WFL en ClearPath.

**Estado validación:** Verificado fuente líneas 410-444

---

## RN-S151-918 — Proyección de la próxima fecha hábil y actualización del control corporativo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-918 |
| **Nombre** | Proyección de la próxima fecha hábil y actualización del control corporativo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P103 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En modo proyección, P103 calcula la próxima fecha de proceso a partir de la fecha actual del header mediante THECALENDAR de LOCSUP (función 13, formato 12 → siguiente día hábil). Si el calendario falla, aborta con estatus -1 y no actualiza el control. Si tiene éxito, tras generar el reporte de estatus reabre el archivo de control en modo I-O y reescribe el header con la fecha proyectada, avanzando el ciclo contable del sistema.

**Fórmula/pseudocódigo:**
```
MOVE WKS-HD-FECPRO TO WKS-FECHA1
W77-FUNCION = 13 ; W77-FORMATO = 12 ; WKS-FECHA2 = "00000001"
CALL "THECALENDAR IN LOCSUP" USING FUNCION, FECHA1, FECHA2, FORMATO
IF W77-FUNCION > 0 → error ; STATUS = -1
ELSE → W77-FECHA-PROFUT = WKS-FECHA1
...reporte...
OPEN I-O A01-CONTROL ; READ header
MOVE W77-FECHA-PROFUT TO WKS-HD-FECPRO ; REWRITE header
```

**Vocabulario en la fórmula:** THECALENDAR · W77-FUNCION (13) · W77-FORMATO (12) · W77-FECHA-PROFUT · WKS-HD-FECPRO

**Excepciones:**
- Un error de proyección impide actualizar la fecha del próximo proceso y detiene el paso.

**Estado validación:** Verificado fuente líneas 478-533

---

## RN-S151-919 — Reporte de estatus de ejecución por sistema contra la fecha corporativa

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-919 |
| **Nombre** | Reporte de estatus de ejecución por sistema contra la fecha corporativa |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P103 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al proyectar, P103 recorre los registros de detalle del archivo de control y compara la fecha de proceso de cada sistema contra la fecha del header corporativo. Si coinciden, reporta que el sistema "SE EJECUTO CORRECTAMENTE"; si difieren, reporta "NO HA SIDO PROCESADO DESDE". El registro con sistema 999 marca el fin de la lista. Esto genera el tablero de estatus de ejecución diaria de los sistemas contables.

**Fórmula/pseudocódigo:**
```
Por registro de detalle A01-CONTROL:
   IF WKS-DET-SIST = 999 → fin
   ELSE:
      IF WKS-DET-FECPRO = WKS-HD-FECPRO → "SE EJECUTO CORRECTAMENTE"
      ELSE → "NO HA SIDO PROCESADO DESDE"
      WRITE renglón de reporte
```

**Vocabulario en la fórmula:** WKS-DET-SIST · WKS-DET-FECPRO · WKS-HD-FECPRO · WLI-SIS-MSG

**Excepciones:**
- El centinela de sistema 999 delimita el catálogo de sistemas monitoreados.

**Estado validación:** Verificado fuente líneas 547-562

---

## RN-S151-920 — Sistemas contables verificados por el control corporativo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-920 |
| **Nombre** | Sistemas contables verificados por el control corporativo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-14 |
| **bian_ref** | 8.1.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV/Interno |
| **Programa ejecutor** | P103 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El control corporativo del S151 verifica la fecha de ejecución de un conjunto acotado de sistemas alimentadores de contabilidad: S084, S087, S408, S500 y S701. La fecha de proceso del CSI corporativo es la referencia única (single source of truth) contra la cual se valida que cada uno de esos sistemas haya procesado su información del día. La lista de sistemas concreta vive como datos en el archivo de control (registros de detalle), no en código.

**Fórmula/pseudocódigo:**
```
Sistemas monitoreados (por diseño): S084, S087, S408, S500, S701
Referencia: WKS-HD-FECPRO (fecha del CSI corporativo)
Cada sistema del archivo de control se compara contra esa fecha (ver RN-S151-919)
```

**Vocabulario en la fórmula:** WKS-HD-CSI · WKS-HD-FECPRO · WKS-DET-SIST · S151/FILE/CONTROL/CORP

**Excepciones:**
- El alcance real de sistemas depende del contenido del archivo de control, que puede ampliarse sin recompilar.

**Estado validación:** Verificado fuente líneas 7-11, 413-418, 547-562

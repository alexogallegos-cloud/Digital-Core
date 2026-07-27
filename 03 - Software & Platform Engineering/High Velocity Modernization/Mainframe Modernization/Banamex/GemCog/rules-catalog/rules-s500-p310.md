# Catálogo de Reglas de Negocio — S500 P310
**Versión:** 1.0 — 2026-07-17
**Programas fuente:** P310-CARGA (Captación CPE — Cuentas de Pago Electrónico)
**Extractor:** Business Rules Champion — Gemelo Cognitivo Capa 4 (Intención)
**Numeración:** RN-S500-183 a RN-S500-202 (20 reglas)
**Indexado:** ✅ 2026-07-17

---

## RN-S500-183 — Ejecución restringida a CSI 10 (VDM)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-183 |
| **Nombre** | Ejecución restringida a CSI 10 (VDM) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [HARDCODE-IMPLÍCITO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P310 solo ejecuta procesamiento completo cuando el CSI (Centro de Servicios de Información) del B02CONTROL es igual a 10 (VDM — Valle de México). En cualquier otro CSI el programa abre la BD, lee el control, y termina sin procesar ninguna cuenta. La lógica de actualización real y la generación de archivos SAT están concentradas en VDM.

**Fórmula/pseudocódigo:**
```
IF B02-NUM-CSI = 10
    PERFORM 180-GENERA-ARCHIVO-SAT
    PERFORM 200-ACTUALIZA-CUENTAS
ELSE
    CLOSE S500BD01CAPTACION
    STOP RUN
```

**Vocabulario en la fórmula:** B02-NUM-CSI · B02CONTROL · S500BD01CAPTACION

**Excepciones:**
- El valor 10 es un `[HARDCODE-IMPLÍCITO]` que identifica VDM en toda la suite S500. El sistema target debe mapear este valor a una constante de entorno (env=VDM/MTY).

**Estado validación:** Verificado fuente líneas 118150-118300

---

## RN-S500-184 — Retroceso de mes para etiquetado de archivos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-184 |
| **Nombre** | Retroceso de mes para etiquetado de archivos |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [LÓGICA-TEMPORAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P310 opera sobre datos del mes anterior al de procesamiento. Toma `B02-FECHA-LINEA` y retrocede un mes para construir la etiqueta de los archivos físicos MCP y el campo de fecha en el header SAT. En enero, el retroceso lleva a diciembre del año anterior.

**Fórmula/pseudocódigo:**
```
IF MM = 01
    WS-FECHA-PROCER-MM = 12
    WS-FECHA-PROCER-AA = B02-AA - 1
    WS-FECHA-PROCER-DD = WS-MESES(12)  (31)
ELSE
    WS-FECHA-PROCER-MM = MM - 1
    WS-FECHA-PROCER-DD = WS-MESES(MM-1)
```

**Vocabulario en la fórmula:** B02-FECHA-LINEA · WS-FECHA-PROCER · WS-MESES · WS-FECHA-PROC-AAAAMM

**Excepciones:**
- La tabla `WS-MESES` tiene 28 fijo para febrero — no incorpora lógica de año bisiesto en este paso. Ver RN-S500-199 para la lógica de bisiesto.

**Estado validación:** Verificado fuente líneas 133243-133254

---

## RN-S500-185 — Carga de tasa ISR estándar desde tarifa 254

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-185 |
| **Nombre** | Carga de tasa ISR estándar desde tarifa 254 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Carga la tasa ISR estándar vigente desde el catálogo S080. Usa tarifa 254, categoría 9991, instrumento 1, moneda 0. El resultado se normaliza dividiendo por la potencia decimal declarada en S080 para obtener el factor de retención de rendimientos.

**Fórmula/pseudocódigo:**
```
CALL L700 (tarifa=254, cat=9991, instrum=1, moneda=0)
IF WS-S080-0201-RESULT = 0 OR 1
    WS-ISR-0-9991-254 = WS-S080-ENT-CAMPO-01(01) / (10 ** WS-S080-DEC-CAMPO-01(01))
    WS-ISR-0     = WS-ISR-0-9991-254
    WS-ISR-0-NVO = WS-ISR-0-9991-254
ELSE
    WS-ISR-0 = 0  (silencioso — sin abort)
```

**Vocabulario en la fórmula:** WS-ISR-0 · WS-ISR-0-NVO · WS-ISR-0-9991-254 · L700 · WS-S080-0201-RESULT

**Excepciones:**
- Si L700 retorna RESULT ≠ 0 y ≠ 1, la tasa ISR queda en 0 sin abort ni alerta — los rendimientos se calcularán sin retención fiscal. `[SILENCIOSO-CRÍTICO]`

**Estado validación:** Verificado fuente líneas 122342-122398

---

## RN-S500-186 — Carga de tasa ISR extraordinaria desde tarifa 259

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-186 |
| **Nombre** | Carga de tasa ISR extraordinaria desde tarifa 259 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] [CAMBIO-2022] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Agregado en 2022 (mantenimiento MTDP-2467, Stefanini). Carga la tasa ISR para personas residentes en el extranjero desde tarifa 259, categoría 9991. A diferencia de la tarifa 254, aplica una división adicional por 100 después de la normalización decimal del catálogo.

**Fórmula/pseudocódigo:**
```
CALL L700 (tarifa=259, cat=9991, instrum=1, moneda=0)
IF WS-S080-0201-RESULT = 0 OR 1
    WS-ISR-0-9991-259 = WS-S080-ENT-CAMPO-01(01) / (10 ** WS-S080-DEC-CAMPO-01(01))
    WS-ISR-0-9991-259 = WS-ISR-0-9991-259 / 100  (división adicional)
    WS-ISR-EXTR-0     = WS-ISR-0-9991-259
    WS-ISR-EXTR-0-NVO = WS-ISR-0-9991-259
```

**Vocabulario en la fórmula:** WS-ISR-EXTR-0 · WS-ISR-EXTR-0-NVO · WS-ISR-0-9991-259 · L700

**Excepciones:**
- La división adicional `/100` es `[HARDCODE-SOSPECHOSO]` — HITL requerido para confirmar si la tarifa 259 viene en porcentaje×100 en S080 o si esta doble división es un bug latente.

**Estado validación:** Verificado fuente líneas 122502-122662 · Tag INI-STEFANINI CPE 2022R09M MTDP-2467

---

## RN-S500-187 — Selección de tasa ISR por tipo de persona

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-187 |
| **Nombre** | Selección de tasa ISR por tipo de persona |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Selecciona la tasa de retención ISR a aplicar según el tipo de persona del titular del contrato. Los tipos 11, 12 y 15 corresponden a entidades con tratamiento fiscal especial (personas morales extranjeras y físicas extranjeras) que reciben la tarifa extraordinaria 259. Todos los demás reciben la tarifa estándar 254.

**Fórmula/pseudocódigo:**
```
IF B03-TIPO-PERSONA = 11 OR 12 OR 15
    WS-TASA-ISR-A-USAR = WS-ISR-EXTR-0
ELSE
    WS-TASA-ISR-A-USAR = WS-ISR-0
```

**Vocabulario en la fórmula:** B03-TIPO-PERSONA · WS-ISR-0 · WS-ISR-EXTR-0 · B39-TASA-ISR-500

**Excepciones:**
- Esta misma lógica aplica para cuentas MTY usando `IND-TIP-PER` del archivo índice en lugar de B03-TIPO-PERSONA.
- HITL requerido: confirmar que los tipos 11/12/15 siguen vigentes en el catálogo actual de tipos de persona.

**Estado validación:** Verificado fuente líneas 141802-142102 y 144811-144826

---

## RN-S500-188 — Generación de archivo índice CPE para proceso MTY

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-188 |
| **Nombre** | Generación de archivo índice CPE para proceso MTY |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar cuentas MTY, P310 convierte el archivo secuencial ARCHSMTY (generado por el CSI de Monterrey) en un archivo indexado ARCHIMTY con clave por número de contrato PIC9(12). Este índice permite lookups por contrato durante la actualización masiva de B39CTASCPE. El programa espera en loop de 40 segundos hasta que ARCHSMTY esté disponible en disco MCP.

**Fórmula/pseudocódigo:**
```
WAIT(40) UNTIL ARCHSMTY IS RESIDENT
OPEN INPUT ARCHSMTY
OPEN OUTPUT ARCHIMTY (KEY=IND-NUM-CTO PIC9(12))
READ ARCHSMTY header (TIP-REG=01) → validar nombre
WHILE NOT EOF ARCHSMTY
    READ detalle (TIP-REG=02) → WRITE ARCHIMTY
READ ARCHSMTY trailer (TIP-REG=99) → validar conteo
CLOSE ARCHSMTY · ARCHIMTY
```

**Vocabulario en la fórmula:** ARCHSMTY · ARCHIMTY · IND-NUM-CTO · TIP-REG · WS-CPS-CSIO · WS-REGS-CPESEC

**Excepciones:**
- Si el archivo está vacío, header inválido, trailer inválido o detalle con tipo ≠ 02: DMTERMINATE.
- El WAIT(40) no tiene límite de reintentos — puede esperar indefinidamente si MTY no genera el archivo.

**Estado validación:** Verificado fuente líneas 133260-133471

---

## RN-S500-189 — Validación de integridad de estructura CPESEC

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-189 |
| **Nombre** | Validación de integridad de estructura CPESEC |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] [VALIDACIÓN-ENTRADA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P310 valida la integridad del archivo CPESEC en tres puntos: (1) nombre de archivo en el header debe coincidir con el nombre externo MCP, (2) el conteo en el trailer debe igualar los registros de detalle procesados, (3) el archivo no debe estar vacío. Cualquier fallo termina el programa inmediatamente con DMTERMINATE.

**Fórmula/pseudocódigo:**
```
VALIDACIÓN 1 — Header
IF WS-ETIQ-ARCHSMTY ≠ SEC-NOM-ARC → DMTERMINATE

VALIDACIÓN 2 — Archivo vacío
IF WS-REGS-CPESEC = 0 AT EOF → DMTERMINATE

VALIDACIÓN 3 — Conteo trailer
IF SEC-REG-DET ≠ WS-REGS-CPESEC-02 → DMTERMINATE
```

**Vocabulario en la fórmula:** WS-ETIQ-ARCHSMTY · SEC-NOM-ARC · SEC-REG-DET · WS-REGS-CPESEC · WS-REGS-CPESEC-02

**Excepciones:**
- No hay rollback manual posible — DMSII maneja la reversión automáticamente al DMTERMINATE.

**Estado validación:** Verificado fuente líneas 133346-133366

---

## RN-S500-190 — Filtro de elegibilidad por producto e instrumento (art.61)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-190 |
| **Nombre** | Filtro de elegibilidad por producto e instrumento (art.61) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] [CAMBIO-2022] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (art.61 ISR) |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Agregado en 2022 (MTDP-2466). Solo las cuentas con PRODUCTO=1 e INSTRUMENTO=3 son elegibles para actualización de rendimientos CPE. Las cuentas con STATUS_BENEFICIARIO 3 u 8 quedan excluidas por el artículo 61 del ISR (beneficio de retención reducida para cuentas especiales). Todas las cuentas excluidas reciben STATUS=4.

**Fórmula/pseudocódigo:**
```
IF B03-NUM-PRODUCTO ≠ 1 OR B03-NUM-INSTRUM ≠ 3
    MOVE 4 TO B39-STATUS → PERFORM 235-STORE-B39 → siguiente cuenta

IF B03-STA-BENEF = 3 OR 8  (art.61)
    MOVE 4 TO B39-STATUS → PERFORM 235-STORE-B39 → siguiente cuenta

ELSE
    PERFORM 220-BUSCA-B06 → procesar rendimientos
```

**Vocabulario en la fórmula:** B03-NUM-PRODUCTO · B03-NUM-INSTRUM · B03-STA-BENEF · B39-STATUS · B06HISTORICO

**Excepciones:**
- PRODUCTO=1/INSTRUMENTO=3 son `[HARDCODE-IMPLÍCITO]` — representan el segmento CPE en el catálogo S500. Deben mapearse a constantes de negocio en el sistema target.

**Estado validación:** Verificado fuente líneas 138943-139125 · Tag MTDP-2466

---

## RN-S500-191 — Actualización de campos de rendimiento VDM en B39

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-191 |
| **Nombre** | Actualización de campos de rendimiento VDM en B39 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cuentas VDM elegibles, actualiza B39CTASCPE combinando B03CONTRATOS (maestro) y B06HISTORICO (historial del ciclo). Los campos de rendimiento (tasa neta, rendimiento pagado, ISR, tasa bruta) solo se actualizan si el grupo tiene OPCION 1, 2 o 5 en B37; para otros grupos estos campos se fuerzan a cero.

**Fórmula/pseudocódigo:**
```
B39-TASA-ISR-500 ← WS-TASA-ISR-A-USAR (ver RN-S500-187)
B39-CHQS-GIRADO  ← B06-CONT-COMIS(50)
B39-DIAS-CICLO   ← B06-DIAS-CICLO
B39-SDO-PROMEDIO ← B06-PROM-CICLO(12)
B39-TPO-PERS     ← B03-TIPO-PERSONA
B39-NOMBRE       ← B03-NOMBRE
B39-STATUS       ← B03-STATUS

IF B37-OPCION = 1 OR 2 OR 5
    B39-TASA-NTA-500 ← B03-TASA-ANTERIOR
    B39-REND-PAG-500 ← B03-INTS-CAPIT
    B39-ISR-RET-500  ← B03-IMPUESTO-RET
    B39-TASA-BRT-500 ← B06-TASA-BRUTA
ELSE
    B39-TASA-NTA-500 = B39-REND-PAG-500 = B39-ISR-RET-500 = B39-TASA-BRT-500 = 0
```

**Vocabulario en la fórmula:** B39CTASCPE · B03CONTRATOS · B06HISTORICO · B37-OPCION · B06-CONT-COMIS · B06-PROM-CICLO · B03-TASA-ANTERIOR · B03-INTS-CAPIT · B03-IMPUESTO-RET

**Excepciones:**
- `B06-CONT-COMIS(50)` — el índice 50 es un `[HARDCODE-SOSPECHOSO]` que selecciona la comisión CPE específica del ciclo. Verificar con SME si el índice 50 siempre corresponde al concepto correcto.
- Si B06 no se encuentra para un contrato: STATUS=4 (ver RN-S500-198).

**Estado validación:** Verificado fuente líneas 141802-144713

---

## RN-S500-192 — Actualización de campos de rendimiento MTY en B39

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-192 |
| **Nombre** | Actualización de campos de rendimiento MTY en B39 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [ARQUITECTURA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cuentas MTY, los datos de rendimiento provienen del archivo índice ARCHIMTY (pre-calculado por CSI=04) en lugar de tablas DMSII directas. La estructura `IND-*` replica los campos de B03/B06 pre-procesados por Monterrey. Si un contrato MTY no tiene entrada en ARCHIMTY, se marca STATUS=4.

**Fórmula/pseudocódigo:**
```
READ ARCHIMTY KEY B39-NUM-CONTRATO
IF FOUND
    B39-CHQS-GIRADO  ← IND-CON-COM
    B39-DIAS-CICLO   ← IND-DIA-CIC
    B39-SDO-PROMEDIO ← IND-PRO-CIC
    B39-TPO-PERS     ← IND-TIP-PER
    B39-NOMBRE       ← IND-NOM-CTE
    B39-STATUS       ← IND-STA-CTO
    B39-USO-FUT-01   ← IND-CVE-COBRO
    B39-TARI-CHQGIR  ← IND-IMP-COM-CAP
    (B39-TASA/REND/ISR/BRT ← IND-* si B37-OPCION=1/2/5, sino 0)
IF NOT FOUND
    MOVE 4 TO B39-STATUS
```

**Vocabulario en la fórmula:** ARCHIMTY · IND-CON-COM · IND-DIA-CIC · IND-PRO-CIC · IND-TIP-PER · IND-NOM-CTE · IND-STA-CTO · IND-CVE-COBRO · IND-IMP-COM-CAP

**Excepciones:**
- La misma lógica de OPCION 1/2/5 de RN-S500-191 aplica para cuentas MTY.

**Estado validación:** Verificado fuente líneas 144804-144880

---

## RN-S500-193 — Obtención de comisión por cuenta vía L422

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-193 |
| **Nombre** | Obtención de comisión por cuenta vía L422 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para cada cuenta VDM elegible, invoca la librería L422 (S016) para obtener la clave de cobro y el importe de comisión. El índice `(04)` selecciona el elemento del array de tarifas correspondiente al concepto CPE. Si L422 falla, aplica fallback hardcodeado.

**Fórmula/pseudocódigo:**
```
WS-S016-0101-CTR-NUMSIST-I = 500
WS-S016-0101-CTR-NUMPASO-I = 310
WS-S016-0101-CTR-NUMPROD-I = 1  [HARDCODE]
WS-S016-0101-CTR-CVEINST-I = 3  [HARDCODE]
WS-S016-0101-CTR-NUMCTO-I  = B03-NUM-CONTRATO
CALL S016L422 (20000016-L422-COMXCTA)

IF WS-S016-0101-CTR-RESULT = 0
    B39-USO-FUT-01  ← CVECOBRO(04)
    B39-TARI-CHQGIR ← COBCOM(04)
ELSE (fallback)
    B39-USO-FUT-01  = 2
    B39-TARI-CHQGIR = 100
```

**Vocabulario en la fórmula:** S016L422 · CVECOBRO · COBCOM · B39-USO-FUT-01 · B39-TARI-CHQGIR · WS-S016-0101-CTR-RESULT

**Excepciones:**
- El índice `(04)` en `CVECOBRO(04)/COBCOM(04)` es `[HARDCODE-SOSPECHOSO]` — si la posición del concepto CPE cambia en el array L422, la comisión será incorrecta silenciosamente.
- HITL requerido: confirmar que PRODUCTO=1/INSTRUMENTO=3 en L422 son correctos para CPE.

**Estado validación:** Verificado fuente líneas 147502-148802

---

## RN-S500-194 — Selección de clave IVA por zona de sucursal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-194 |
| **Nombre** | Selección de clave IVA por zona de sucursal |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Determina la clave de IVA a aplicar según el tipo de IVA de la sucursal del promedio (`B39-SUCPROM`). Sucursales en zona frontera aplican tasa reducida (8%); el resto aplica tasa general (16%). Ambos valores se obtienen del catálogo S080.

**Fórmula/pseudocódigo:**
```
CALL S080 (sucursal=B39-SUCPROM) → WKS-S080-TPO-IVA

IF WKS-S080-TPO-IVA = 1  (zona frontera)
    B39-CVE-IVA ← WS-IVA-FRONT
ELSE
    B39-CVE-IVA ← WS-IVA-GRAL
```

**Vocabulario en la fórmula:** B39-SUCPROM · B39-CVE-IVA · WKS-S080-TPO-IVA · WS-IVA-FRONT · WS-IVA-GRAL

**Excepciones:**
- Error del 50% en IVA declarado si la lógica frontera/general no se preserva exactamente. `[REGULATORIO-FISCAL]` — validación obligatoria antes de cutover.

**Estado validación:** Verificado fuente líneas 145210-145260

---

## RN-S500-195 — Persistencia de cuenta B39CTASCPE con transacción explícita

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-195 |
| **Nombre** | Persistencia de cuenta B39CTASCPE con transacción explícita |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] [ARQUITECTURA-TRANSACCIONAL] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada actualización de cuenta CPE es atómica: envuelve el STORE de B39 en un BEGIN/END-TRANSACTION explícito con la opción NOAU (No Audit) — no genera registro de auditoría en DMSII. Cualquier fallo en los tres pasos termina el programa y DMSII hace rollback automático.

**Fórmula/pseudocódigo:**
```
BEGIN-TRANSACTION (B00CTRLPASO)
    B39CTASCPE-STORE (con campos actualizados)
END-TRANSACTIONNOAU

ON ERROR → DMTERMINATE (DMSII rollback automático)
```

**Vocabulario en la fórmula:** B39CTASCPE · B00CTRLPASO · BEGIN-TRANSACTION · END-TRANSACTIONNOAU · DMTERMINATE

**Excepciones:**
- El `NOAU` debe mapearse explícitamente en el sistema target — ORM/JPA con auditoría automática generaría volúmenes de log inesperados.

**Estado validación:** Verificado fuente líneas 145300-147200

---

## RN-S500-196 — Acumulación y actualización del grupo CPE en B37GRUPOCPE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-196 |
| **Nombre** | Acumulación y actualización del grupo CPE en B37GRUPOCPE |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-BANCARIA-MX] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P310 procesa B39SXGPOSBGMDA ordenado por grupo. Al detectar cambio de grupo (o EOF), actualiza B37GRUPOCPE con la suma de saldos promedio, rendimientos pagados y cheques girados del grupo. Si el grupo no tiene cuentas activas, no se actualiza B37. Los acumuladores se reinician a cero tras cada STORE.

**Fórmula/pseudocódigo:**
```
POR CADA CUENTA EN GRUPO
    WT-G-PROM-CICLO   += B06-PROM-CICLO(12)
    WT-G-REND-PAG-500 += B03-INTS-CAPIT
    WS-CHQS-GIR-XGPO  += B06-CONT-COMIS(50)

AL CAMBIO DE GRUPO (o EOF)
    IF WS-CTAS-X-GPO > 0
        B37-SDO-PROMEDIO ← WT-G-PROM-CICLO
        B37-RENDIMIENTOS ← WT-G-REND-PAG-500
        B37-CHQS-GIRADOS ← WS-CHQS-GIR-XGPO
        BEGIN-TRANSACTION → B37GRUPOCPE-STORE → END-TRANSACTIONNOAU
    REINICIAR acumuladores = 0
```

**Vocabulario en la fórmula:** B37GRUPOCPE · B39SXGPOSBGMDA · WT-G-PROM-CICLO · WT-G-REND-PAG-500 · WS-CHQS-GIR-XGPO · WS-CTAS-X-GPO · B37-SDO-PROMEDIO · B37-RENDIMIENTOS · B37-CHQS-GIRADOS

**Excepciones:**
- Si todos los contratos de un grupo resultan en STATUS=4, `WS-CTAS-X-GPO = 0` y B37 no se actualiza — el grupo queda con los valores del ciclo anterior.

**Estado validación:** Verificado fuente líneas 137200-150500

---

## RN-S500-197 — Generación de archivo SAT de constancias regulatorias

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-197 |
| **Nombre** | Generación de archivo SAT de constancias regulatorias |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-FISCAL-MX] [REGULATORIO] [HARDCODE-REGULATORIO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Genera el archivo mensual de constancias de retención para el SAT. Estructura Header(01)/Detalle(02)/Trailer(99) en CSV con comas. El identificador de sistema en el header es `"S152"` hardcodeado — referencia al sistema de movimientos contables que provee las tasas de la vista 152 de B39.

**Fórmula/pseudocódigo:**
```
HEADER (TIP-REG=01):
    SAT-IDSISTEMA = "S152"  [HARDCODE-REGULATORIO]
    SAT-FECHAH    = WS-FECHA-PROCER (mes anterior)

POR CADA B39 CON STATUS ≠ 4:
    DETALLE (TIP-REG=02):
        SAT-AREA/DIV/SDIV/EJE/SGPO/GPO ← descomposición de B39-GRUPO (10 dígitos)
        SAT-CTE     ← B39-SUB-GPO
        SAT-SUC/CTA ← descomposición de B39-NUM-MDA (4+8 dígitos)
        SAT-SDOPRO  ← B39-SDO-PROMEDIO
        SAT-TASANETA ← B39-TASA-NTA-152
        SAT-PRODNET  ← B39-REND-PAG-152
        SAT-OPCION   ← B37-OPCION
        SAT-RAN      ← B37-RANGO
        SAT-FECHA    ← WS-FECHA-PROC-AAAAMM

TRAILER (TIP-REG=99):
    SAT-TOTREGS = conteo de registros detalle
```

**Vocabulario en la fórmula:** ARCHISAT · SAT-IDSISTEMA · SAT-FECHAH · B39-GRUPO · B39-NUM-MDA · B39-TASA-NTA-152 · B39-REND-PAG-152 · B37-OPCION · B37-RANGO

**Excepciones:**
- `SAT-IDSISTEMA = "S152"` `[BLOQUEA CUTOVER]` — el SAT puede rechazar archivos con identificador de sistema incorrecto post-migración. Requiere coordinación con SAT/tesorería antes de go-live.
- Las tasas provienen de la vista 152 (B39-TASA-NTA-152 / B39-REND-PAG-152) — implica dependencia del procesamiento previo de S151/S152.

**Estado validación:** Verificado fuente líneas 136310-136490

---

## RN-S500-198 — Marcado de cuentas excluidas (STATUS=4)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-198 |
| **Nombre** | Marcado de cuentas excluidas (STATUS=4) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT (art.61) / Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Todas las rutas de exclusión de P310 convergen en el mismo marcador STATUS=4. Este estado indica "cuenta CPE sin rendimientos este ciclo" y excluye la cuenta del acumulador de grupo B37 y del archivo SAT. Cuatro causas distintas activan el STATUS=4.

**Fórmula/pseudocódigo:**
```
CAUSAS DE STATUS=4:
1. B03-NUM-PRODUCTO ≠ 1 OR B03-NUM-INSTRUM ≠ 3 (producto/instrumento inelegible)
2. B03-STA-BENEF = 3 OR 8 (excluido art.61 ISR)
3. B06 no encontrado para el contrato VDM (WS-STATUS-BASE ≠ 0)
4. Contrato MTY sin entrada en ARCHIMTY (INVALID KEY)

ACCIÓN: MOVE 4 TO B39-STATUS → PERFORM 235-STORE-B39 → NEXT SENTENCE
```

**Vocabulario en la fórmula:** B39-STATUS · B03-STA-BENEF · B03-NUM-PRODUCTO · B03-NUM-INSTRUM · B06HISTORICO · ARCHIMTY

**Excepciones:**
- Cuentas con STATUS=4 sí se persisten en B39CTASCPE (se hace el STORE) — el marcador queda para auditoría del ciclo aunque no se procesen rendimientos.

**Estado validación:** Verificado fuente líneas 144773-144793 y 144940-144960

---

## RN-S500-199 — Ajuste de año bisiesto en retroceso de mes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-199 |
| **Nombre** | Ajuste de año bisiesto en retroceso de mes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [LÓGICA-TEMPORAL] [BUG-LATENTE] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cuando el retroceso de mes cae en febrero, aplica corrección de días para años bisiestos. La lógica es año bisiesto si `AA MOD 4 = 0`. **No implementa la excepción centenaria** — el año 2100 se calculará incorrectamente como bisiesto.

**Fórmula/pseudocódigo:**
```
CALL 155-BISIESTO
    DIVIDE WS-FECHA-PROCER-AA BY 4 GIVING ... REMAINDER WS-RESTO
    IF WS-RESTO = 0 AND WS-FECHA-PROCER-MM = 02
        WS-FECHA-PROCER-DD = WS-FECHA-PROCER-DD + 1
```

**Vocabulario en la fórmula:** WS-FECHA-PROCER-AA · WS-FECHA-PROCER-MM · WS-FECHA-PROCER-DD · WS-RESTO

**Excepciones:**
- `[BUG-LATENTE-2100]`: no crítico en horizonte de migración 2025-2027. El sistema target debe usar `java.time.Year.isLeap()` o equivalente.

**Estado validación:** Verificado fuente líneas 134230-134290

---

## RN-S500-200 — Handler de señales HI para monitoreo del operador

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-200 |
| **Nombre** | Handler de señales HI para monitoreo del operador |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-OPERACIONAL] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P310 implementa un handler de interrupciones MCP (`USE AS INTERRUPT PROCEDURE`) que responde a señales HI (High Interrupt) con TASKVALUE=10. Al recibir la señal, reporta el estado actual del proceso y contadores de avance por CSI (VDM/MTY encontrados/no encontrados).

**Fórmula/pseudocódigo:**
```
ON HI-NUMHI = 10:
    IF DONDE-ESTOY = 0 → "NO HE INICIADO"
    IF DONDE-ESTOY = 1 → "VALIDA Y GENERA ARCH INDEX MTY"
    IF DONDE-ESTOY = 2 → "PROCESANDO, LEIDOS B39 {N}, EN VDM:{N}, NO EN VDM {N}, EN MTY:{N}, NO EN MTY {N}"
    IF DONDE-ESTOY = 3 → "TERMINANDO..." + contadores
ON HI-NUMHI ≠ 10 → "NUM HI ERRONEO {N}"
```

**Vocabulario en la fórmula:** HI-NUMHI · DONDE-ESTOY · W77-REG-LEI-B39 · W77-SI-REG-VDM · W77-NO-REG-VDM · W77-SI-REG-MTY · W77-NO-REG-MTY

**Excepciones:**
- Mecanismo MCP sin equivalente directo en Java/Cloud. Migrar a métricas de observabilidad (Prometheus/Micrometer) con los mismos contadores expuestos como métricas de negocio.

**Estado validación:** Verificado fuente líneas 117704-117790

---

## RN-S500-201 — Retry automático en apertura de BD (error tipo 39)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-201 |
| **Nombre** | Retry automático en apertura de BD (error tipo 39) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [ARQUITECTURA-RESILIENCIA] [MCP-ESPECÍFICO] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al abrir la base de datos principal, si DMSII retorna error tipo 39 (BD bloqueada/en uso), el programa espera 60 segundos y reintenta. No hay límite de reintentos — puede esperar indefinidamente. Cualquier otro error termina con DMTERMINATE.

**Fórmula/pseudocódigo:**
```
OPEN S500BD01CAPTACION
ON DMSTATUS(DMERRORTYPE) = 39
    WAIT(60)
    RETRY OPEN (sin límite de intentos)
ON OTHER ERROR
    LOG error → DMTERMINATE
```

**Vocabulario en la fórmula:** S500BD01CAPTACION · DMERRORTYPE · DMSTATUS · DMTERMINATE

**Excepciones:**
- El retry sin límite debe acotarse en el sistema target con máximo de reintentos y circuit breaker.

**Estado validación:** Verificado fuente líneas 125340-126800

---

## RN-S500-202 — Validación de versión del programa contra catálogo S000

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-202 |
| **Nombre** | Validación de versión del programa contra catálogo S000 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | [REGLA-CONTROL] [GESTIÓN-VERSIONES] |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Interno |
| **Programa ejecutor** | P310 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Al inicio, P310 registra su identidad en el sistema de versiones S000 y verifica que la versión en ejecución coincida con la registrada en el catálogo. Si hay discrepancia, termina con `CHANGE ATTRIBUTE STATUS TO -1` (abort MCP).

**Fórmula/pseudocódigo:**
```
W77-S000-MY-ID      = "S500P310"
W77-S000-MY-VERSION = "25MTP004"
W77-MY-PASO         = 310

CALL S000LIBLJ (CHECAME-VERSION, código=051010)
IF S000-CTR-CVEERROR < 0
    LOG "VERSION INCORRECTA"
    CHANGE ATTRIBUTE STATUS TO -1  (abort MCP)
```

**Vocabulario en la fórmula:** W77-S000-MY-ID · W77-S000-MY-VERSION · W77-MY-PASO · S000LIBLJ · S000-CTR-CVEERROR

**Excepciones:**
- En el sistema target no existirá S000 — reemplazar por versionado de artefactos (Docker image tag, Kubernetes ConfigMap) con validación equivalente.

**Estado validación:** Verificado fuente líneas 120000-121515

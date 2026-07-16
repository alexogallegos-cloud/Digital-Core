# Reglas P112 — PUNTEO POR CLAVES DE TRANSACCION (con vocabulario)

> **Archivo fuente:** `COBOL_P112.txt` (~3,326 LOC)
> **Enriquecido con:** vocabulario vocab-s151.md · ente regulador · nivel de confianza · schema v2 (capacidad bancaria · frecuencia · sistemas downstream · fórmula · excepciones)
> **Referencia cruzada:** `rules-s151.md` sección P112
> **Generado:** 2026-07-16 · Specialist - Business Rules · S151 Banamex

---

## Contexto del Programa

P112 (PUNTEO POR CLAVES DE TRANSACCION) es un programa batch que reconcilia movimientos S500 (Sistema de Cargos/Abonos) contra S151 (Libro Mayor GL) usando como eje la combinación de claves contables: LIBRO + PRODUCTO + MONEDA + CVETRAN + ESQCON. Su resultado determina si cada movimiento tiene su contraparte equivalente en el otro sistema. La ausencia de equivalencia es una brecha de reconciliación reportable al regulador.

**Tags de riesgo utilizados:**
- `[HARDCODE-SOSPECHOSO]` — valor literal en código sin parámetro externo; riesgo en modernización
- `[RIESGO-EQUIVALENCIA]` — regla que afecta la reconciliación contable diaria S500↔S151
- `[REGLA-CNBV]` — regla con impacto regulatorio directo

---

## RN-S151-001 — Validación de sistema en base de control antes de iniciar proceso

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** P112 lee WKS-PARAM-SIS del JCL de ejecución para identificar el sistema a puntear. Antes de procesar cualquier movimiento, invoca LIBCONTROL para verificar que el sistema existe y está activo en BD99CONTROL. El resultado de la validación se almacena en W77-RESULT-LIBCON; si el valor es distinto de cero, el proceso termina con un mensaje de error crítico sin procesar registros.

**Campos involucrados:** `WKS-PARAM-SIS`, `WKS-B01-FUNCION`, `WKS-B01-SISTEMA`, `WKS-B01-FECPRO`, `WKS-B01-NOMPACMOV`, `W77-RESULT-LIBCON`

**Fórmula / pseudocódigo:**
```
CALL LIBCONTROL USING WKS-B01-SISTEMA, WKS-B01-FUNCION, WKS-B01-FECPRO
IF W77-RESULT-LIBCON NOT = 0
   DISPLAY "ERROR: SISTEMA NO EXISTE EN BASE DE CONTROL"
   STOP RUN
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PARAM-SIS` | CAMPO-NUM | Efimero | Código de parámetro del sistema (3 dígitos); selector de parámetro en tiempo de ejecución para configurar el procesamiento GL |
| `WKS-B01-FUNCION` | CAMPO-NUM | Interfaz-Externo | Código de función (2 dígitos) del campo B01 del mensaje estandarizado de comunicación entre sistemas del GL |
| `WKS-B01-SISTEMA` | CAMPO-NUM | Interfaz-Externo | Código del sistema origen (4 dígitos) en el bloque B01 de la estructura de trabajo; identifica el sistema que generó los movimientos del batch |
| `WKS-B01-FECPRO` | CAMPO-NUM | Interfaz-Externo | Fecha de proceso del movimiento en formato AAAAMMDD en el área de trabajo B01; campo compartido por 64 programas |
| `WKS-B01-NOMPACMOV` | CAMPO-ALFA | Interfaz-Externo | Nombre del paquete de movimientos en la cola B01 de la base de datos DMSII del GL S151 |
| `LIBCONTROL` | ENTIDAD | N/A-componente | Librería de control de proceso GL — gestiona el registro y validación de cada paso del WFL LOTE |
| `CONTROL` | ENTIDAD | N/A-componente | Módulo de control del proceso GL — BD99CONTROL almacena el estado de cada paso del lote batch: fechas, parámetros y estados |

> **Nota:** `W77-RESULT-LIBCON` no tiene entrada directa en vocab-s151.md. El término más cercano es `W77-RESULT-B01` (CAMPO-NUM, Efimero): "Código de resultado de la operación B01 (8 dígitos). Variable de trabajo nivel 77 que almacena el código de retorno de la llamada al servicio B01."

**Excepciones documentadas:**
- Si LIBCONTROL no responde (BD99CONTROL no disponible), el proceso puede quedar esperando indefinidamente — no hay timeout documentado en el código.
- WKS-PARAM-SIS = 0 (valor por defecto no inicializado) puede o no existir en BD99CONTROL según el ambiente; el resultado es impredecible.

---

## RN-S151-002 — Determinación de fecha de proceso (parámetro vs base de control)

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** P112 determina la fecha de proceso mediante lógica de precedencia: si WKS-PARAM-FCH llega con valor distinto de ceros desde el JCL, esa fecha prevalece sobre la base de control. Si WKS-PARAM-FCH es cero, P112 lee WKS-B01-FECPRO de BD99CONTROL como fecha de proceso. El valor resultante se almacena en dos formatos: WKS-FECHA-PROCESO (8 dígitos AAAAMMDD) y WKS-FPROCESO-A6 (6 dígitos AAMMDD, requerido por módulos de reporte heredados con CRONOS2K).

**Campos involucrados:** `WKS-PARAM-FCH`, `WKS-B01-FECPRO`, `WKS-FECHA-PROCESO`, `WKS-FPROCESO-A6`

**Fórmula / pseudocódigo:**
```
IF WKS-PARAM-FCH = ZEROS
   MOVE WKS-B01-FECPRO TO WKS-FECHA-PROCESO
ELSE
   MOVE WKS-PARAM-FCH TO WKS-FECHA-PROCESO
END-IF
MOVE WKS-FECHA-PROCESO(3:6) TO WKS-FPROCESO-A6   *> AAMMDD
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PARAM-FCH` | CAMPO-NUM | Efimero | Parametro de fecha del proceso de 8 digitos en formato AAAAMMDD; fecha operativa pasada como parametro de control al programa S151 |
| `WKS-B01-FECPRO` | CAMPO-NUM | Interfaz-Externo | Fecha de proceso del movimiento en formato AAAAMMDD en el área de trabajo B01; campo compartido por 64 programas |
| `WKS-FPROCESO-A6` | CAMPO-NUM | Efimero | Fecha del proceso batch de 6 dígitos en formato AAMMDD para control del ciclo nocturno LOTE |

> **Nota:** `WKS-FECHA-PROCESO` no tiene entrada directa en vocab-s151.md. Ver `WKS-B01-FECPRO151` (CAMPO-NUM, Interfaz-Externo): "Fecha de proceso del sistema S151 en formato AAAAMMDD; fecha contable de proceso utilizada en la mayoría de los programas del S151."

**Excepciones documentadas:**
- Si WKS-PARAM-FCH contiene una fecha inválida (ej: 20260231), el proceso avanza con esa fecha sin validación de rangos — el error se detecta más tarde en el procesamiento contable.
- La conversión a AAMMDD trunca el siglo; si el parche CRONOS2K se aplica a WKS-FPROCESO-A6, un año=50 exacto es interpretado como 2050 (umbral inclusivo ≤50).

---

## RN-S151-003 — Filtro FUNCION=1 AND STATUS=1

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** El archivo de entrada de movimientos pendientes de punteo es filtrado al inicio del proceso. Solo ingresan al ciclo de reconciliación los registros que cumplen simultáneamente: A00-R01-FUNCION = 1 (tipo de operación: alta) y A00-R01-STATUS = 1 (estatus: pendiente de punteo). Registros con cualquier otro valor en alguno de los dos campos son ignorados sin dejar traza en el reporte. Este filtro doble protege contra el reprocesamiento de movimientos ya punteados o de operaciones distintas a altas.

**Campos involucrados:** `A00-R01-FUNCION`, `A00-R01-STATUS`

**Fórmula / pseudocódigo:**
```
IF A00-R01-FUNCION = 1 AND A00-R01-STATUS = 1
   PERFORM PROCESO-PUNTEO
ELSE
   PERFORM SIGUIENTE-REGISTRO
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-FUNCION` | CAMPO-COMP | Interfaz-Externo | Código de función u operación solicitada al sistema S151 a través de la interfaz R01 (alta, cancelación, reversa, consulta, etc.) |
| `A00-R01-STATUS` | CAMPO-COMP | Control-proceso | Estatus del procesamiento del registro en la interfaz R01; código numérico que refleja el resultado de la operación en S151 |

**Excepciones documentadas:**
- Registros con STATUS=0 (nunca procesados) no ingresan al punteo — pérdida silenciosa de movimientos con alta pendiente.
- FUNCION=2 (baja) o FUNCION=3 (modificación) con STATUS=1 son ignorados sin traza, incluso si representan operaciones contables válidas que requieren reconciliación.

---

## RN-S151-004 — Clave sort compuesta 5 dimensiones (LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON)

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Antes del ciclo de punteo, los movimientos filtrados se ordenan por una clave compuesta de 5 dimensiones que define los grupos de reconciliación. El orden de prioridad determina la jerarquía de los totales del reporte. La clave tiene longitud total de 16 posiciones: WKS-RS-LIBRO (2) + WKS-RS-NUM-PRODUCTO (4) + WKS-RS-MONEDA (2) + WKS-RS-CVETRAN (4) + WKS-RS-ESQCON (4). Movimientos con la misma clave de 16 posiciones se puntean entre sí.

**Campos involucrados:** `WKS-RS-LIBRO`, `WKS-RS-NUM-PRODUCTO`, `WKS-RS-MONEDA`, `WKS-RS-CVETRAN`, `WKS-RS-ESQCON`

**Fórmula / pseudocódigo:**
```
SORT ARCHIVO-MOVIMIENTOS ASCENDING KEY
   WKS-RS-LIBRO
   WKS-RS-NUM-PRODUCTO
   WKS-RS-MONEDA
   WKS-RS-CVETRAN
   WKS-RS-ESQCON
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-RS-LIBRO` | CAMPO-NUM | Efimero | Numero de libro contable de 2 digitos en el registro de saldo; identifica el libro del mayor general al que pertenece el saldo registrado |
| `WKS-RS-NUM-PRODUCTO` | CAMPO-NUM | Efimero | Numero de producto de 4 digitos en el registro de saldo; identifica el producto financiero asociado al saldo en el GL bancario |
| `WKS-RS-MONEDA` | CAMPO-NUM | Efimero | Código de moneda en el registro de esquema RS. PIC 9(02). Identificador de divisa del esquema contable: 01=MXN, 02=USD, etc. |
| `WKS-RS-CVETRAN` | CAMPO-NUM | Efimero | Clave de transacción en el registro de respuesta RS del esquema contable. PIC 9(04). Código de 4 dígitos de la transacción devuelta por el subsistema de esquemas de contabilización |
| `WKS-RS-ESQCON` | CAMPO-NUM | Efimero | Esquema de contabilización en el registro de respuesta RS. PIC 9(04). Código del esquema contable aplicado al movimiento GL, rige la distribución de cargos y abonos |
| `CVETRA` | ENTIDAD | N/A-componente | Clave de trayectoria contable — identifica el tipo de asiento GL: el par débito/crédito que corresponde a cada tipo de movimiento bancario |

**Excepciones documentadas:**
- Movimientos con los 5 campos de clave idénticos pero de distinto tipo de operación se agrupan en el mismo grupo de punteo — posible punteo cruzado no deseado.
- Archivo de entrada vacío (0 registros tras el filtro de RN-S151-003): el SORT no falla pero el reporte queda vacío sin mensaje de advertencia.

---

## RN-S151-005 — S403/S404 FIDEICOMISO como producto

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para movimientos de los sistemas S403 (captación fiduciaria) y S404 (fideicomiso con actividad empresarial), identificados por el valor de A00-R01-IND-CONTA, P112 sustituye el código de producto estándar por el número de fideicomiso A00-R01-FIDEICO en el campo WKS-RS-NUM-PRODUCTO. Esta sustitución garantiza que todas las operaciones del mismo fideicomiso se agrupen en la misma clave de punteo, independientemente del producto bancario subyacente. Tiene impacto regulatorio por la obligación CNBV de segmentación fiduciaria.

**Campos involucrados:** `A00-R01-IND-CONTA`, `A00-R01-FIDEICO`, `A00-R01-PRODUCTO`, `WKS-RS-NUM-PRODUCTO`

**Fórmula / pseudocódigo:**
```
IF A00-R01-IND-CONTA = 'S403' OR 'S404'
   MOVE A00-R01-FIDEICO TO WKS-RS-NUM-PRODUCTO
ELSE
   MOVE A00-R01-PRODUCTO TO WKS-RS-NUM-PRODUCTO
END-IF
```

**Ente regulador:** CNBV — Segmentación regulatoria de operaciones fiduciarias (Circular Única de Bancos)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-IND-CONTA` | CAMPO-COMP | Interfaz-Externo | Indicador del libro contable al que pertenece el movimiento. Redefine A00-R01-LIBRO-CONTABLE; distingue entre libros paralelos CNBV, Banxico, etc. |
| `A00-R01-FIDEICO` | CAMPO-COMP | Interfaz-Externo | Número de fideicomiso asociado al movimiento contable. Requerido para la segmentación regulatoria de operaciones fiduciarias ante la CNBV |
| `A00-R01-PRODUCTO` | CAMPO-COMP | Interfaz-Externo | Código de 4 dígitos que identifica el producto bancario (cuenta de cheques, inversión, nómina, etc.) en el registro R01 del GL |
| `WKS-RS-NUM-PRODUCTO` | CAMPO-NUM | Efimero | Numero de producto de 4 digitos en el registro de saldo; identifica el producto financiero asociado al saldo en el GL bancario |
| `A00-BIT-FIDEICO` | CAMPO-NUM | Efimero | Número de fideicomiso asociado al movimiento en bitácora GL; numérico 6 dígitos conforme a CNBV |

**Excepciones documentadas:**
- A00-R01-FIDEICO = 0 para S403/S404: WKS-RS-NUM-PRODUCTO queda en 0, que puede no tener entrada en ARCH-CAT → brecha de reconciliación silenciosa.
- Si el campo IND-CONTA contiene caracteres parciales que coinciden con 'S403' por truncamiento, la sustitución se aplica incorrectamente a movimientos no fiduciarios.

---

## RN-S151-006 — S087 PRODUCTO hardcoded=87 `[HARDCODE-SOSPECHOSO]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Cuando WKS-PARAM-SIS identifica el sistema S087 (sistema de crédito/comisiones especiales), P112 asigna el literal numérico 87 directamente al campo de producto sin leer A00-R01-PRODUCTO. Este hardcode implica que todos los movimientos de S087, sin importar su producto real, quedan clasificados bajo el código 87. Riesgo en modernización: si S087 incorpora nuevos productos, el punteo seguirá usando 87 en silencio, generando brecha de reconciliación invisible.

**Campos involucrados:** `WKS-PARAM-SIS`, `A00-R01-PRODUCTO`

**Fórmula / pseudocódigo:**
```
IF WKS-PARAM-SIS = 087
   MOVE 87 TO WKS-RS-NUM-PRODUCTO    *> HARDCODE — no lee A00-R01-PRODUCTO
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PARAM-SIS` | CAMPO-NUM | Efimero | Código de parámetro del sistema (3 dígitos); selector de parámetro en tiempo de ejecución para configurar el procesamiento GL |
| `A00-R01-PRODUCTO` | CAMPO-COMP | Interfaz-Externo | Código de 4 dígitos que identifica el producto bancario (cuenta de cheques, inversión, nómina, etc.) en el registro R01 del GL |
| `A00-BIT-PRODUCTO` | CAMPO-NUM | Efimero | Código de producto bancario del movimiento en bitácora GL; numérico 4 dígitos del catálogo de productos Banamex |

**Excepciones documentadas:**
- Si S087 agrega nuevos tipos de producto, todos quedan clasificados bajo código 87 sin distinción — brecha de reconciliación invisible hasta la próxima recompilación de P112.
- Si el código 87 es eliminado del catálogo de productos, P112 produce claves KEY-CAT con referencia inválida sin abortar.

---

## RN-S151-007 — Naturaleza S028 por clave (CARGO/ABONO/N/C)

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para cada clave de transacción procesada en el punteo, P112 determina la naturaleza contable consultando la tabla paramétrica del sistema S028. El campo WKS-PT-NATS028 contiene el código de naturaleza (2 dígitos): 1=CARGO, 2=ABONO, 3=NEUTRO, 4=COMPENSACION. El resultado se escribe en WLI-AFECS028 como código de afectación de 3 caracteres (C/A/N/C respectivamente). Esta naturaleza controla si el importe del movimiento suma al acumulado de cargos o de abonos en los totales del reporte de punteo.

**Campos involucrados:** `WKS-PT-NATS028`, `WLI-AFECS028`

**Fórmula / pseudocódigo:**
```
EVALUATE WKS-PT-NATS028
   WHEN 1  MOVE 'C  ' TO WLI-AFECS028   *> CARGO
   WHEN 2  MOVE 'A  ' TO WLI-AFECS028   *> ABONO
   WHEN 3  MOVE 'N  ' TO WLI-AFECS028   *> NEUTRO
   WHEN 4  MOVE 'COM' TO WLI-AFECS028   *> COMPENSACION
END-EVALUATE
```

**Ente regulador:** N/A — Control interno (catálogo S028 implícito en normativa CNBV de naturaleza contable)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PT-NATS028` | CAMPO-COMP | Efimero | Código de 2 dígitos de la naturaleza transaccional del sistema S028 en el punto de proceso del GL |
| `WLI-AFECS028` | CAMPO-ALFA | Efimero | Código de afectación del sistema 028 (3 car., default=SPACES). Clave de afectación para la interfaz con el sistema 028 en líneas de reporte del S151 |
| `WKS-DET-NATS028` | CAMPO-NUM | Efimero | Naturaleza de la cuenta según tabla S028 (tabla de naturalezas contables), 2 dígitos; indica el comportamiento contable de la cuenta en GL |

**Excepciones documentadas:**
- Si WKS-PT-NATS028 tiene valor fuera de 1-4 (p.ej. 0 o 5+), el EVALUATE no ejecuta ningún WHEN y WLI-AFECS028 queda con su valor previo (SPACES) — el movimiento se reporta con afectación vacía sin error explícito.
- Código 4 (COMPENSACION → 'COM') suma a ambas naturalezas en algunos contextos de totales — verificar que el comportamiento acumulativo sea intencional.

---

## RN-S151-008 — Gate equivalencia S500↔S151 via INDS151=2 y guía contable `[RIESGO-EQUIVALENCIA]`

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Esta es la regla central de equivalencia del programa. P112 considera que un movimiento tiene correspondencia válida entre S500 y S151 cuando se cumplen dos condiciones: (1) WKS-PT-INDS151 = 2 (indicador de que el movimiento pertenece al universo S151) y (2) la clave KEY-CAT (sistema+cvetran+esqcon+moneda+libro+cia+guia) localiza un registro en el catálogo paramétrico ARCH-CAT. Si la guía contable no existe en ARCH-CAT, el movimiento se clasifica como brecha: WLI-TIPOERROR recibe el texto diagnóstico y WLI-AFECS115 activa el código de afectación del sistema 115. Esta brecha debe ser investigada antes del cierre contable.

**Campos involucrados:** `WKS-PT-INDS151`, `WLI-AFECS115`, `WLI-TIPOERROR`, `KEY-CAT`

**Fórmula / pseudocódigo:**
```
IF WKS-PT-INDS151 = 2
   PERFORM BUSCA-EN-ARCH-CAT
   IF KEY-CAT-ENCONTRADO
      PERFORM PUNTEO-EXITOSO
   ELSE
      MOVE 'REL-TRAN-GUIA CONTABLE INEXISTENTE' TO WLI-TIPOERROR
      MOVE '15' TO WLI-AFECS115
      PERFORM REPORTA-BRECHA
   END-IF
END-IF
```

**Ente regulador:** CNBV — Reconciliación contable diaria obligatoria (Circular Única de Bancos, disposiciones de contabilidad)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PT-INDS151` | CAMPO-COMP | Efimero | Indicador S151 (COMP 2 dígitos). Bandera de control específica del S151 en el módulo PT del programa P112; indica si la operación pertenece al sistema de movimientos contables S151 |
| `WLI-AFECS115` | CAMPO-ALFA | Efimero | Código de afectación del sistema 115 (2 car., default=SPACES). Clave de afectación para la interfaz con el sistema 115 en líneas de reporte |
| `WLI-TIPOERROR` | CAMPO-ALFA | Efimero | Descripción del tipo de error en el procesamiento del movimiento GL (35 chars, valor SPACES). Texto del error para impresión en reporte de excepciones |

> **Nota:** `KEY-CAT` no tiene entrada en vocab-s151.md. Corresponde a la clave compuesta de acceso al catálogo ARCH-CAT (ver RN-S151-009).

**Excepciones documentadas:**
- Si WKS-PT-INDS151 ≠ 2 (p.ej. valor 1 o 3), el movimiento pasa sin punteo ni reporte — no queda traza de cuántos movimientos fueron excluidos por esta condición.
- Si la tabla PT no se cargó (overflow por RN-S151-013), este gate nunca se ejecuta para ningún movimiento del día — toda la reconciliación falla silenciosamente.

---

## RN-S151-009 — Clave compuesta ARCH-CAT con REDEFINES COMP

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** El catálogo paramétrico ARCH-CAT (archivo de reglas de punteo) usa una clave compuesta de 7 campos para su acceso. El layout COBOL utiliza REDEFINES con tipo COMP (packed decimal) para la búsqueda binaria: CAT-SIST (3 dígitos, sistema origen), CAT-CVETRA (4 dígitos, clave de transacción), CAT-ESQ (4 dígitos, esquema contable), CAT-MON (2 dígitos, moneda), CAT-LIBRO (2 dígitos, libro contable), CAT-CIA (4 dígitos, compañía), CAT-GUIAC (4 dígitos, guía contable). Cualquier modificación en el layout de esta clave requiere recompilación de todos los programas que acceden ARCH-CAT.

**Campos involucrados:** `CAT-SIST`, `CAT-CVETRA`, `CAT-ESQ`, `CAT-MON`, `CAT-LIBRO`, `CAT-CIA`, `CAT-GUIAC`

**Fórmula / pseudocódigo:**
```
01 KEY-CAT.
   05 CAT-SIST  PIC 9(03) COMP.
   05 CAT-CVETRA PIC 9(04) COMP.
   05 CAT-ESQ   PIC 9(04) COMP.
   05 CAT-MON   PIC 9(02) COMP.
   05 CAT-LIBRO PIC 9(02) COMP.
   05 CAT-CIA   PIC 9(04) COMP.
   05 CAT-GUIAC PIC 9(04) COMP.
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

> Los campos `CAT-SIST`, `CAT-CVETRA`, `CAT-ESQ`, `CAT-MON`, `CAT-LIBRO`, `CAT-CIA` y `CAT-GUIAC` no tienen entrada directa en vocab-s151.md. Los términos más cercanos son:

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `CVETRA` | ENTIDAD | N/A-componente | Clave de trayectoria contable — identifica el tipo de asiento GL: el par débito/crédito que corresponde a cada tipo de movimiento bancario |
| `WKS-RS-ESQCON` | CAMPO-NUM | Efimero | Esquema de contabilización en el registro de respuesta RS. PIC 9(04). Código del esquema contable aplicado al movimiento GL |
| `WKS-RS-LIBRO` | CAMPO-NUM | Efimero | Numero de libro contable de 2 digitos en el registro de saldo; identifica el libro del mayor general |
| `BOOK` | ENTIDAD | N/A-componente | Libro contable GL — estructura DMSII que agrupa los movimientos por tipo de cuenta contable según el catálogo de cuentas Banamex |
| `A00-BIT264-LIBRO-CONTABLE` | CAMPO-NUM | Efimero | Codigo del libro contable al que corresponde la transaccion en la bitacora 264 (2 digitos) |
| `A00-BIT264-ESQCONT` | CAMPO-NUM | Efimero | Esquema de contabilizacion aplicado a la transaccion en la bitacora formato 264 (4 digitos) |
| `A00-BIT-ESQCON` | CAMPO-NUM | Efimero | Código de esquema contable del movimiento en bitácora GL; numérico 4 dígitos que determina las reglas de contabilización |

**Excepciones documentadas:**
- Datos corruptos en cualquier campo COMP de la clave (valores fuera de rango numérico) producen comportamiento impredecible en el acceso binario sin mensaje de error.
- Incremento de dígitos en cualquier campo de la clave requiere recompilación de TODOS los programas que acceden ARCH-CAT — no hay control de versión del layout en tiempo de ejecución.

---

## RN-S151-010 — Normalización MON/LIBRO para S403/S404 en lookup ARCH-CAT

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para los sistemas S403 y S404, antes de construir KEY-CAT y hacer el lookup en ARCH-CAT, P112 normaliza dos campos de la clave: CAT-MON se fuerza a 0 (moneda genérica) y CAT-LIBRO se fuerza a 0 (libro genérico). Esta normalización permite que una sola entrada en ARCH-CAT cubra todas las combinaciones de moneda y libro de las operaciones fiduciarias, reduciendo la cardinalidad del catálogo. Sin esta regla, sería necesario duplicar entradas en ARCH-CAT para cada moneda y libro por fideicomiso.

**Campos involucrados:** `CAT-MON`, `CAT-LIBRO`

**Fórmula / pseudocódigo:**
```
IF A00-R01-IND-CONTA = 'S403' OR 'S404'
   MOVE 0 TO CAT-MON
   MOVE 0 TO CAT-LIBRO
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

> `CAT-MON` y `CAT-LIBRO` no tienen entrada directa en vocab-s151.md. Los términos más cercanos son:

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-RS-MONEDA` | CAMPO-NUM | Efimero | Código de moneda en el registro de esquema RS. PIC 9(02). Identificador de divisa del esquema contable: 01=MXN, 02=USD, etc. |
| `WKS-RS-LIBRO` | CAMPO-NUM | Efimero | Numero de libro contable de 2 digitos en el registro de saldo; identifica el libro del mayor general |
| `BOOK` | ENTIDAD | N/A-componente | Libro contable GL — estructura DMSII que agrupa los movimientos por tipo de cuenta contable según el catálogo de cuentas Banamex |
| `A00-BIT-MONEDA` | CAMPO-NUM | Efimero | Código de moneda del movimiento contable en bitácora GL; numérico 4 dígitos (catálogo interno de monedas Banamex) |
| `500-R02-MONEDA` | CAMPO-NUM | Interfaz-Externo | Código de moneda ISO del registro tipo 2 (detalle) de la interfaz 500; numérico 3 dígitos (p.ej. 484 MXN, 840 USD) |

**Excepciones documentadas:**
- Si ARCH-CAT tiene entradas para S403/S404 con MON≠0 o LIBRO≠0, esas entradas quedan inaccesibles porque la clave siempre se normaliza a cero — entradas del catálogo inutilizables.
- La normalización se aplica DESPUÉS de la sustitución de producto (RN-S151-005) pero ANTES del lookup — el orden de estas dos transformaciones es parte de la regla de negocio y debe preservarse.

---

## RN-S151-011 — S264/S703/S018/S017 solo moneda base

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para los sistemas S264 (compensación), S703 (transferencias), S018 y S017, P112 aplica una restricción adicional antes del lookup en ARCH-CAT: CAT-MON se fuerza al código de moneda base (MXN, código interno 01). Movimientos de estos sistemas en divisas distintas a MXN no tienen entrada en ARCH-CAT y son reportados como brechas. Esta restricción refleja que los sistemas mencionados solo operan en pesos mexicanos según su diseño funcional original.

**Campos involucrados:** `CAT-MON`

**Fórmula / pseudocódigo:**
```
IF WKS-PARAM-SIS = 264 OR 703 OR 018 OR 017
   MOVE 01 TO CAT-MON   *> HARDCODE moneda base MXN
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

> `CAT-MON` no tiene entrada directa en vocab-s151.md. Los términos más cercanos son:

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-RS-MONEDA` | CAMPO-NUM | Efimero | Código de moneda en el registro de esquema RS. PIC 9(02). Identificador de divisa del esquema contable: 01=MXN, 02=USD, etc. |
| `A00-BIT-MONEDA` | CAMPO-NUM | Efimero | Código de moneda del movimiento contable en bitácora GL; numérico 4 dígitos (catálogo interno de monedas Banamex) |
| `A00-BIT264-MONEDA` | CAMPO-NUM | Efimero | Codigo de moneda de la transaccion en la bitacora formato 264 (4 digitos) |
| `500-R02-MONEDA` | CAMPO-NUM | Interfaz-Externo | Código de moneda ISO del registro tipo 2 (detalle) de la interfaz 500; numérico 3 dígitos (p.ej. 484 MXN, 840 USD) |

**Excepciones documentadas:**
- Un movimiento USD de S264 generado por error de captura es rechazado silenciosamente como brecha sin mensaje de error específico — la causa raíz (restricción de moneda) no aparece en el reporte.
- El código interno "01" para MXN difiere del ISO 484 — si el catálogo interno de monedas cambia la codificación, la restricción deja de ser "moneda base" sin ser visible en el código.

---

## RN-S151-012 — Límite 12,000 claves en tablas de leyendas `[HARDCODE-SOSPECHOSO]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Las tablas internas WKS-TABLA-LEYENDAS-TRANS1 a TRANS4 almacenan hasta 12,000 claves de leyendas (3,000 por tabla). El índice activo en cada tabla se controla mediante WKS-PT-NUM-LEYEN. Si durante la carga del catálogo paramétrico se intenta agregar la entrada 12,001, P112 emite error de overflow de tabla y termina el proceso antes de haber punteado ningún registro. Este límite es invisible al operador durante la ejecución normal. El riesgo se materializa si el catálogo de clave-leyenda del banco crece por encima de 12,000 entradas.

**Campos involucrados:** `WKS-TABLA-LEYENDAS-TRANS1`, `WKS-TABLA-LEYENDAS-TRANS2`, `WKS-TABLA-LEYENDAS-TRANS3`, `WKS-TABLA-LEYENDAS-TRANS4`, `WKS-PT-NUM-LEYEN`

**Fórmula / pseudocódigo:**
```
IF WKS-PT-NUM-LEYEN > 12000
   DISPLAY "ERROR: OVERFLOW TABLA LEYENDAS - LIMITE 12000"
   STOP RUN
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PT-NUM-LEYEN` | CAMPO-COMP | Efimero | Número de leyenda del estado de cuenta; código que identifica la leyenda regulatoria o informativa a incluir en el estado de cuenta |
| `WKS-TABLA-LEYENDAS-TRANS1` | GRUPO | Efimero | Tabla de leyendas de transacciones segmento 1 (grupo, confianza baja — sin descripción en vocab) |
| `WKS-TABLA-LEYENDAS-TRANS2` | GRUPO | Efimero | Tabla de leyendas de transacciones segmento 2 (grupo, confianza baja — sin descripción en vocab) |
| `WKS-TABLA-LEYENDAS-TRANS3` | GRUPO | Efimero | Tabla de leyendas de transacciones segmento 3 (grupo, confianza baja — sin descripción en vocab) |
| `WKS-TABLA-LEYENDAS-TRANS4` | GRUPO | Efimero | Tabla de leyendas de transacciones segmento 4 (grupo, confianza baja — sin descripción en vocab) |

**Excepciones documentadas:**
- Si el catálogo tiene 11,999 claves y se agregan 2 nuevas en la misma ejecución, el proceso aborta a mitad de la carga del catálogo — ningún movimiento es punteado en ese ciclo.
- El límite está distribuido en 4 tablas (3,000 c/u) — si la distribución entre tablas es desigual, una tabla puede hacer overflow antes de alcanzar el límite global de 12,000.

---

## RN-S151-013 — Límite 9,999 claves en catálogo paramétrico `[HARDCODE-SOSPECHOSO]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** El catálogo paramétrico de reglas de punteo (tabla PT) tiene capacidad máxima de 9,999 registros, controlado por WKS-PT-NUM-LEYEN como índice de carga. Cada registro de la tabla PT contiene cuatro campos de control: WKS-PT-CGENTRA (código de generación de entrada, 2 dígitos), WKS-PT-NATS028 (naturaleza S028, 2 dígitos), WKS-PT-INDS151 (indicador S151, 2 dígitos) y WKS-PT-INDBITA (indicador bitácora, 2 dígitos). Al alcanzar el registro 10,000, el proceso aborta. La tabla PT es el corazón de las reglas de equivalencia: su corrupción o saturación detiene todo el punteo.

**Campos involucrados:** `WKS-PT-NUM-LEYEN`, `WKS-PT-CGENTRA`, `WKS-PT-NATS028`, `WKS-PT-INDS151`, `WKS-PT-INDBITA`

**Fórmula / pseudocódigo:**
```
IF WKS-PT-NUM-LEYEN > 9999
   DISPLAY "ERROR: OVERFLOW CATALOGO PT - LIMITE 9999"
   STOP RUN
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-PT-NUM-LEYEN` | CAMPO-COMP | Efimero | Número de leyenda del estado de cuenta; código que identifica la leyenda regulatoria o informativa a incluir en el estado de cuenta |
| `WKS-PT-CGENTRA` | CAMPO-COMP | Efimero | Código de generación de entrada en la tabla PT (2 dígitos COMP); controla la versión del registro en tabla de parámetros |
| `WKS-PT-NATS028` | CAMPO-COMP | Efimero | Código de 2 dígitos de la naturaleza transaccional del sistema S028 en el punto de proceso del GL |
| `WKS-PT-INDS151` | CAMPO-COMP | Efimero | Indicador S151 (COMP 2 dígitos). Bandera de control específica del S151 en el módulo PT del programa P112; indica si la operación pertenece al sistema de movimientos contables S151 |
| `WKS-PT-INDBITA` | CAMPO-COMP | Efimero | Indicador de 2 dígitos del estado o tipo de registro en la bitácora del proceso GL; aparece en 7 programas |

**Excepciones documentadas:**
- El overflow de la tabla PT aborta el proceso antes de puntear cualquier movimiento del día — la reconciliación completa falla sin procesar un solo registro.
- Registros duplicados en el catálogo durante su carga pueden alcanzar el límite 9,999 artificialmente; la tabla PT es volátil y se recarga desde cero en cada ejecución (no hay acumulación entre corridas).

---

## RN-S151-014 — 5 niveles de control break en reporte (LIBRO>PRODUCTO>MONEDA>CVETRAN>ESQCON)

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** El reporte de punteo implementa 5 niveles de control break jerárquicos en el mismo orden que la clave de sort. Al detectar un cambio en cualquier nivel, P112 imprime los totales parciales acumulados antes de iniciar el nuevo grupo. Los contadores principales son W77-IMPMOV (importe acumulado del grupo, en formato COMP-3 de 14+2 decimales) y W77-NUMMOV (número de movimientos del grupo, 5 dígitos). Nivel 1 (más externo): LIBRO; nivel 5 (más interno): ESQCON. El cambio en el nivel 1 también genera una línea de total general de todos los libros.

**Campos involucrados:** `W77-IMPMOV`, `W77-NUMMOV`

**Fórmula / pseudocódigo (seudocódigo de control break):**
```
NIVEL-1: cambio en WKS-RS-LIBRO      -> imprime total LIBRO
NIVEL-2: cambio en WKS-RS-NUM-PRODUCTO -> imprime total PRODUCTO
NIVEL-3: cambio en WKS-RS-MONEDA    -> imprime total MONEDA
NIVEL-4: cambio en WKS-RS-CVETRAN   -> imprime total CVETRAN
NIVEL-5: cambio en WKS-RS-ESQCON    -> imprime total ESQCON
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `W77-NUMMOV` | CAMPO-NUM | Efimero | Número de movimientos (5 dígitos, valor=0). Contador del total de movimientos contables procesados en el ciclo actual del GL S151; se inicializa en cero |
| `WKS-RS-LIBRO` | CAMPO-NUM | Efimero | Numero de libro contable de 2 digitos en el registro de saldo; identifica el libro del mayor general |
| `WKS-RS-NUM-PRODUCTO` | CAMPO-NUM | Efimero | Numero de producto de 4 digitos en el registro de saldo; identifica el producto financiero asociado al saldo en el GL bancario |
| `WKS-RS-MONEDA` | CAMPO-NUM | Efimero | Código de moneda en el registro de esquema RS. PIC 9(02). Identificador de divisa del esquema contable: 01=MXN, 02=USD, etc. |
| `WKS-RS-CVETRAN` | CAMPO-NUM | Efimero | Clave de transacción en el registro de respuesta RS del esquema contable. PIC 9(04) |
| `WKS-RS-ESQCON` | CAMPO-NUM | Efimero | Esquema de contabilización en el registro de respuesta RS. PIC 9(04). Código del esquema contable aplicado al movimiento GL |

> **Nota:** `W77-IMPMOV` no tiene entrada en vocab-s151.md. El término más cercano es `W77-NUMMOV` (CAMPO-NUM, Efimero) que comparte el mismo patrón de variable de trabajo nivel-77.

**Excepciones documentadas:**
- Si los datos no están ordenados correctamente (falla en el SORT de RN-S151-004), los totales de control break son incorrectos — el programa no valida el orden de los registros.
- Cambio simultáneo en múltiples niveles (p.ej. nuevo LIBRO también implica nuevo PRODUCTO): los totales deben imprimirse en orden interno→externo; cualquier inversión produce subtotales incompletos sin error.

---

## RN-S151-015 — 12 libros contables hardcoded (incl. FOBAPROA) `[HARDCODE-SOSPECHOSO]` `[REGLA-CNBV]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** P112 valida el campo WKS-RS-LIBRO contra una tabla interna de 12 libros contables válidos hardcodeados en la WORKING-STORAGE. La tabla incluye el libro FOBAPROA (Fondo Bancario de Protección al Ahorro, activo residual de la crisis bancaria de 1994-1995), además de los libros principales de contabilidad CNBV. Movimientos con un libro fuera de los 12 valores hardcoded son rechazados y reportados. Riesgo de modernización: la adición de un nuevo libro contable regulatorio (por ejemplo, por reforma CNBV) requiere modificación de código fuente y recompilación.

**Campos involucrados:** `WKS-RS-LIBRO` (validado contra tabla interna)

**Fórmula / pseudocódigo (implícita):**
```
EVALUATE WKS-RS-LIBRO
   WHEN 01 THRU 12   CONTINUE   *> libros válidos
   WHEN OTHER        PERFORM RECHAZA-POR-LIBRO-INVALIDO
END-EVALUATE
```

**Ente regulador:** CNBV — Catálogo de libros contables regulatorios (Circular Única de Bancos, Criterios Contables)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `BOOK` | ENTIDAD | N/A-componente | Libro contable GL — estructura DMSII que agrupa los movimientos por tipo de cuenta contable según el catálogo de cuentas Banamex. Referenciado en BD12MC001S151 (catálogo contable MC001) |
| `WKS-RS-LIBRO` | CAMPO-NUM | Efimero | Numero de libro contable de 2 digitos en el registro de saldo; identifica el libro del mayor general al que pertenece el saldo registrado |
| `A00-BIT264-LIBRO-CONTABLE` | CAMPO-NUM | Efimero | Codigo del libro contable al que corresponde la transaccion en la bitacora 264 (2 digitos) |
| `WKS-DET-LIBCON` | CAMPO-ALFA | Efimero | Código del libro contable en detalle del reporte GL, 8 caracteres; identifica el libro o diario contable donde se registra el movimiento |
| `LIBCONTROL` | ENTIDAD | N/A-componente | Librería de control de proceso GL — gestiona el registro y validación de cada paso del WFL LOTE |

> **Nota:** `FOBAPROA` no tiene entrada en vocab-s151.md. Contexto histórico: Fondo Bancario de Protección al Ahorro, rescate bancario 1994-1995, convertido en IPAB en 1999. Su presencia como libro contable activo en P112 indica obligaciones contables residuales.

**Excepciones documentadas:**
- FOBAPROA (residual de 1994-1995) genera movimientos aceptados por el código — si IPAB cancela las obligaciones residuales, esos movimientos quedan huérfanos sin error explícito.
- Un nuevo libro contable regulatorio por reforma CNBV (p.ej. IFRS 17 o nuevo catálogo) no será aceptado hasta recompilación — el regulador puede observar movimientos rechazados sin causa aparente.

---

## RN-S151-016 — S403 fondos+instrumentos hardcoded (FIRA, FONATUR, BANCOMEXT, NAFIN) `[HARDCODE-SOSPECHOSO]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para el sistema S403 (captación de fondos de fomento económico), P112 tiene hardcodeada la lista de fondos válidos: FIRA (Fideicomisos Instituidos en Relación con la Agricultura), FONATUR (Fondo Nacional de Fomento al Turismo), BANCOMEXT (Banco Nacional de Comercio Exterior) y NAFIN (Nacional Financiera). El número de fideicomiso (A00-R01-FIDEICO) se valida contra estos cuatro valores. Movimientos S403 cuyo fideicomiso no pertenece a ninguno son rechazados silenciosamente. Riesgo: si el banco incorpora un nuevo fondo de fomento (p.ej. por programa gubernamental nuevo), el punteo lo descartará hasta que se recompile P112.

**Campos involucrados:** `A00-R01-FIDEICO`, `A00-R01-IND-CONTA`

**Fórmula / pseudocódigo (implícita):**
```
IF A00-R01-IND-CONTA = 'S403'
   EVALUATE A00-R01-FIDEICO
      WHEN FIRA-RANGE    CONTINUE   *> válido
      WHEN FONATUR-RANGE CONTINUE   *> válido
      WHEN BANCOMEXT-RANGE CONTINUE *> válido
      WHEN NAFIN-RANGE   CONTINUE   *> válido
      WHEN OTHER         PERFORM RECHAZA-FONDO-INVALIDO
   END-EVALUATE
END-IF
```

**Ente regulador:** CNBV / Banxico — Fondos de fomento regulados (SHCP, Banxico, CNBV normativa de crédito dirigido)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-FIDEICO` | CAMPO-COMP | Interfaz-Externo | Número de fideicomiso asociado al movimiento contable. Requerido para la segmentación regulatoria de operaciones fiduciarias ante la CNBV |
| `A00-R01-IND-CONTA` | CAMPO-COMP | Interfaz-Externo | Indicador del libro contable al que pertenece el movimiento. Distingue entre libros paralelos CNBV, Banxico, etc. |
| `A00-BIT-FIDEICO` | CAMPO-NUM | Efimero | Número de fideicomiso asociado al movimiento en bitácora GL; numérico 6 dígitos conforme a CNBV |
| `A00-BITNF-FIDEICO` | CAMPO-NUM | Efimero | Número de fideicomiso (6 dígitos) en la bitácora NF A00. Identificador del fideicomiso bancario asociado a la transacción |

> **Nota:** FIRA, FONATUR, BANCOMEXT y NAFIN no tienen entrada en vocab-s151.md. Son fondos de fomento económico mexicanos bajo supervisión CNBV/Banxico.

**Excepciones documentadas:**
- Un nuevo fondo de fomento bajo S403 (p.ej. por programa gubernamental) tiene sus movimientos rechazados silenciosamente — brecha de reconciliación invisible hasta la próxima recompilación de P112.
- Los rangos de número de fideicomiso por fondo son implícitos en el código — si los rangos se solapan entre fondos, un fideicomiso puede ser aceptado bajo el fondo incorrecto sin error.

---

## RN-S151-017 — S404 9 tipos de producto hardcoded `[HARDCODE-SOSPECHOSO]`

**Confianza:** media
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Para el sistema S404 (fideicomiso con actividad empresarial), P112 acepta únicamente 9 códigos de producto hardcodeados en tabla interna. Movimientos S404 con un código de producto fuera de estos 9 valores son descartados sin mensaje de error descriptivo, lo cual genera riesgo de brecha de reconciliación silenciosa. Esta restricción refleja que S404 solo cubre 9 productos fiduciarios según el diseño original del sistema. Si Banamex/Citibank crea un décimo producto S404 (por ejemplo por nueva regulación fiduciaria), el punteo lo ignorará hasta que se modifique el hardcode.

**Campos involucrados:** `A00-R01-PRODUCTO`, `A00-R01-IND-CONTA`

**Fórmula / pseudocódigo (implícita):**
```
IF A00-R01-IND-CONTA = 'S404'
   IF A00-R01-PRODUCTO NOT IN (TABLA-9-PRODS-S404)
      PERFORM DESCARTA-SIN-ERROR
   END-IF
END-IF
```

**Ente regulador:** CNBV — Productos fiduciarios regulados (normativa CNBV de fideicomisos con actividad empresarial)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `A00-R01-PRODUCTO` | CAMPO-COMP | Interfaz-Externo | Código de 4 dígitos que identifica el producto bancario (cuenta de cheques, inversión, nómina, etc.) en el registro R01 del GL |
| `A00-R01-IND-CONTA` | CAMPO-COMP | Interfaz-Externo | Indicador del libro contable al que pertenece el movimiento. Distingue entre libros paralelos CNBV, Banxico, etc. |
| `A00-BIT-PRODUCTO` | CAMPO-NUM | Efimero | Código de producto bancario del movimiento en bitácora GL; numérico 4 dígitos del catálogo de productos Banamex |
| `WKS-RS-NUM-PRODUCTO` | CAMPO-NUM | Efimero | Numero de producto de 4 digitos en el registro de saldo; identifica el producto financiero asociado al saldo en el GL bancario |

**Excepciones documentadas:**
- El rechazo silencioso (PERFORM DESCARTA-SIN-ERROR) hace invisible la brecha S404 en el reporte — no hay contador de descartados por este motivo.
- Un décimo producto S404 por reforma fiduciaria CNBV tiene todos sus movimientos descartados sin aviso — la brecha regulatoria puede acumularse durante semanas antes de ser detectada.

---

## RN-S151-018 — Paginación 50 líneas/hoja y encabezado

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** El reporte de punteo P112 usa paginación fija de 50 líneas por hoja (constante hardcodeada en WORKING-STORAGE). Al completar la línea 50, P112 emite un carácter de salto de página (AFTER PAGE en WRITE) e imprime el encabezado de nueva página con: fecha del proceso (WKS-B01-FECPRO en formato imprimible), número de hoja correlativo, nombre del programa (P112 PUNTEO POR CLAVES DE TRANSACCION), y títulos de columna fijos. El literal '....CONTINUA' (WLI-CONTINUA) se imprime al final de cada hoja como indicador de continuación.

**Campos involucrados:** (contador de líneas interno, constante 50), `WKS-B01-FECPRO`, `WLI-CONTINUA`

**Fórmula / pseudocódigo:**
```
ADD 1 TO WKS-CONTADOR-LINEAS
IF WKS-CONTADOR-LINEAS > 50
   WRITE LINEA-REPORTE AFTER PAGE
   PERFORM IMPRIME-ENCABEZADO
   MOVE 0 TO WKS-CONTADOR-LINEAS
END-IF
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WKS-B01-FECPRO` | CAMPO-NUM | Interfaz-Externo | Fecha de proceso del movimiento en formato AAAAMMDD en el área de trabajo B01; campo compartido por 64 programas |
| `WLI-CONTINUA` | CAMPO-ALFA | Efimero | Literal fijo '....CONTINUA' (12 chars) que indica continuación de página en el reporte GL. Leyenda de pie de página al generar listados |

**Excepciones documentadas:**
- Si el reporte tiene exactamente 50 líneas, la página siguiente se genera con encabezado pero sin cuerpo — página en blanco al final del reporte.
- WLI-CONTINUA de 12 caracteres es fijo — si el ancho del reporte se modifica en el target, el literal puede quedar desalineado visualmente.

---

## RN-S151-019 — Y2K umbral año 50 para siglo (CRONOS2K) `[HARDCODE-SOSPECHOSO]`

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** P112 implementa el parche CRONOS2K para convertir años de 2 dígitos a 4 dígitos con la siguiente regla hardcodeada: si el año de 2 dígitos es menor o igual a 50, se interpreta como año 20XX (siglo XXI); si es mayor que 50, se interpreta como 19XX (siglo XX). El umbral 50 aplica a la conversión de WKS-FPROCESO-A6 (AAMMDD de 6 dígitos) a WKS-FECHA-PROCESO (AAAAMMDD de 8 dígitos). En el año 2051 (o si aparecen datos con año > 50 antes de esa fecha), la lógica producirá años erróneos (2051 interpretado como 1951). Este parche es el mismo presente en los programas P167, P177, P178, P195, P197 y las librerías L002R* y L011.

**Campos involucrados:** `WKS-FPROCESO-A6`

**Fórmula / pseudocódigo:**
```
*> CRONOS2K — parche Y2K
IF WKS-FPROCESO-A6(1:2) <= 50
   MOVE '20' TO WKS-FECHA-PROCESO(1:2)
ELSE
   MOVE '19' TO WKS-FECHA-PROCESO(1:2)
END-IF
MOVE WKS-FPROCESO-A6 TO WKS-FECHA-PROCESO(3:6)
```

**Ente regulador:** N/A — Control interno

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `CRONOS2K` | ENTIDAD | N/A-componente | Código de parche Y2K presente en múltiples programas S151 — patrón $SET OLDCODE, a2k_base_year. Afecta librerías L002R* y L011, y programas P167, P177, P178, P195, P197. Riesgo para modernización |
| `WKS-FPROCESO-A6` | CAMPO-NUM | Efimero | Fecha del proceso batch de 6 dígitos en formato AAMMDD para control del ciclo nocturno LOTE |

**Excepciones documentadas:**
- Datos históricos con año > 50 (p.ej. año 95 de 1995) son correctamente interpretados como 1995 — el parche funciona para el rango histórico conocido de Banamex.
- Cualquier dato con año = 51 generado antes de 2051 (error de captura o datos de prueba con fecha futura) será interpretado como 1951 — error silencioso que puede afectar la reconciliación contable.

---

## RN-S151-020 — "REL-TRAN-GUIA CONTABLE INEXISTENTE" — diagnóstico de brecha de reconciliación `[RIESGO-EQUIVALENCIA]`

**Confianza:** alta
**Capacidad bancaria:** 6.7.1 Financial Reconciliation — Conciliación GL
**Frecuencia:** cierre-diario
**Sistemas downstream:** S151 GL, CNBV B-0111B, auditoría interna

**Descripción:** Cuando P112 no localiza la clave KEY-CAT (combinación sistema+cvetran+esqcon+moneda+libro+cia+guia) en el catálogo ARCH-CAT, emite el mensaje diagnóstico exacto "REL-TRAN-GUIA CONTABLE INEXISTENTE" en WLI-TIPOERROR (35 caracteres). Simultáneamente, WLI-AFECS115 recibe el código de afectación del sistema 115 (módulo de reconciliación). Este diagnóstico es el indicador primario de una brecha de equivalencia: un movimiento registrado en S500 no tiene guía contable correspondiente en S151, por lo que no puede ser punteado ni reconciliado. Cada ocurrencia de este mensaje debe ser investigada por el equipo de contabilidad antes del cierre del día contable. La acumulación de brechas sin investigar constituye un riesgo regulatorio CNBV de primer orden.

**Campos involucrados:** `WLI-TIPOERROR`, `WLI-AFECS115`, `KEY-CAT`

**Fórmula / pseudocódigo:**
```
*> Cuando KEY-CAT no encuentra match en ARCH-CAT
MOVE 'REL-TRAN-GUIA CONTABLE INEXISTENTE' TO WLI-TIPOERROR
MOVE '15'                                  TO WLI-AFECS115
PERFORM IMPRIME-LINEA-ERROR
ADD 1 TO WKS-CONTADOR-BRECHAS
```

**Ente regulador:** CNBV — Reconciliación contable diaria obligatoria; cada brecha es un asiento contable sin contraparte documentada (Circular Única de Bancos, Criterios Contables para Instituciones de Crédito)

**Vocabulario relacionado (vocab-s151.md):**

| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| `WLI-TIPOERROR` | CAMPO-ALFA | Efimero | Descripción del tipo de error en el procesamiento del movimiento GL (35 chars, valor SPACES). Texto del error para impresión en reporte de excepciones |
| `WLI-AFECS115` | CAMPO-ALFA | Efimero | Código de afectación del sistema 115 (2 car., default=SPACES). Clave de afectación para la interfaz con el sistema 115 en líneas de reporte |
| `WKS-PT-INDS151` | CAMPO-COMP | Efimero | Indicador S151 (COMP 2 dígitos). Bandera de control específica del S151 en el módulo PT del programa P112 |
| `PUNTEO ON CMEMP` | ENTIDAD | patron-unisys | Marca de punteo contable con tercer nivel — encontrado en BD99CONTROL: field B01-SIS-3ERNIV 'PUNTEO CON TERCER NIVEL'. Referencia a archivo de punteo S253 |

> **Nota:** `KEY-CAT` no tiene entrada en vocab-s151.md. Es la clave compuesta de acceso al catálogo ARCH-CAT descrita en RN-S151-009.

**Excepciones documentadas:**
- Si la misma clave KEY-CAT produce múltiples brechas en el mismo día, el contador WKS-CONTADOR-BRECHAS acumula todas, pero el reporte muestra cada ocurrencia individualmente sin agrupar — el equipo contable puede subestimar la frecuencia de una brecha recurrente.
- El texto exacto de 35 caracteres es la única señal de diagnóstico — cualquier cambio en el texto (incluso espacios) rompe parsers downstream que detectan brechas automáticamente.

---

## Resumen ejecutivo P112

| ID | Nombre abreviado | Confianza | Ente regulador | Tags |
|----|------------------|-----------|----------------|------|
| RN-S151-001 | Validación sistema en BD99CONTROL | alta | N/A | — |
| RN-S151-002 | Fecha proceso: parámetro vs control | alta | N/A | — |
| RN-S151-003 | Filtro FUNCION=1 AND STATUS=1 | alta | N/A | — |
| RN-S151-004 | Sort 5 dimensiones LIBRO+PROD+MON+CVE+ESQ | alta | N/A | — |
| RN-S151-005 | S403/S404 fideicomiso como producto | alta | CNBV | — |
| RN-S151-006 | S087 producto hardcoded=87 | media | N/A | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-007 | Naturaleza S028 CARGO/ABONO/N/C | alta | N/A | — |
| RN-S151-008 | Gate equivalencia INDS151=2 + ARCH-CAT | alta | CNBV | `[RIESGO-EQUIVALENCIA]` |
| RN-S151-009 | Clave ARCH-CAT 7 campos REDEFINES COMP | alta | N/A | — |
| RN-S151-010 | Normalización MON/LIBRO para S403/S404 | alta | N/A | — |
| RN-S151-011 | S264/S703/S018/S017 solo moneda base | media | N/A | — |
| RN-S151-012 | Límite 12,000 claves tabla leyendas | media | N/A | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-013 | Límite 9,999 claves catálogo PT | media | N/A | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-014 | 5 niveles control break en reporte | alta | N/A | — |
| RN-S151-015 | 12 libros hardcoded incl. FOBAPROA | media | CNBV | `[HARDCODE-SOSPECHOSO]` `[REGLA-CNBV]` |
| RN-S151-016 | S403 fondos FIRA/FONATUR/BANCOMEXT/NAFIN | media | CNBV/Banxico | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-017 | S404 9 tipos producto hardcoded | media | CNBV | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-018 | Paginación 50 líneas/hoja | alta | N/A | — |
| RN-S151-019 | Y2K umbral año 50 CRONOS2K | alta | N/A | `[HARDCODE-SOSPECHOSO]` |
| RN-S151-020 | REL-TRAN-GUIA CONTABLE INEXISTENTE | alta | CNBV | `[RIESGO-EQUIVALENCIA]` |

**Reglas con mayor riesgo para modernización:**
1. RN-S151-008 + RN-S151-020 — equivalencia S500↔S151: cualquier cambio en la guía contable rompe la reconciliación
2. RN-S151-009 — clave ARCH-CAT con REDEFINES COMP: extremadamente frágil ante cambios de layout
3. RN-S151-015 + RN-S151-016 + RN-S151-017 — hardcodes regulatorios: requieren mantenimiento manual ante cada cambio normativo
4. RN-S151-019 — CRONOS2K: bomba de tiempo activa en 2051 (o antes con datos fuera de rango)
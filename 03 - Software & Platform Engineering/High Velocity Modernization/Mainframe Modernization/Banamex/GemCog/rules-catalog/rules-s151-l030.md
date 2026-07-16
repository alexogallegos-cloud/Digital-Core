# Reglas L030 — LIBRERÍA COBOL MAESTRA S151 (Wave 3)

> **Tipo:** COBOL library (S151LIB030) — 19,253 LOC — Unisys ClearPath MCP
> **CRÍTICO:** L030 es la librería de consulta y control que usan prácticamente todos los programas de visualización S151. Aunque la tarea la denomina "ALGOL L030", el archivo fuente es **COBOL** (`COBOL_L030.txt`, PROGRAM-ID: `S151LIB030`). No es transpilable con herramientas COBOL estándar sin revisión humana extensiva por su complejidad (Unisys DMSII, OPEN/CLOSE INQUIRY, CHANGE ATTRIBUTE, CANCEL). Debe ser **reimplementada desde cero** como servicio de plataforma en el sistema objetivo.
> **Usada por:** todos los programas de pantallas S151 y los procesos batch que consultan el estado diario del sistema.
> **Rango:** RN-S151-526 a RN-S151-550
> **Autor:** Business Rules Champion · extracción 2026-07-16

---

## Índice de reglas

| ID | Título | Tipo | Confianza |
|----|--------|------|-----------|
| RN-S151-526 | Determinación de siglo — pivote año 50 (Y2K) | [HARDCODE-SOSPECHOSO] | alta |
| RN-S151-527 | Habilitación/bloqueo del programa principal P000 vía STAREG | [LÓGICA-CONTABLE] | alta |
| RN-S151-528 | Control de disponibilidad del archivo de movimientos (STAARCLOG) | [LÓGICA-CONTABLE] | alta |
| RN-S151-529 | Protocolo de apertura de la base semanal — OPEN INQUIRY BASESEMANAL | [RIESGO-EQUIVALENCIA] | alta |
| RN-S151-530 | Ventana deslizante de 10 semi-días para localización de dataset diario | [RIESGO-EQUIVALENCIA] | alta |
| RN-S151-531 | Catálogo de claves de transacción (CVETRAN) — límite 10,000 entradas | [HARDCODE-SOSPECHOSO] | alta |
| RN-S151-532 | Catálogo de leyendas de transacción — límite 2,000 entradas | [HARDCODE-SOSPECHOSO] | alta |
| RN-S151-533 | Formato de catálogo CVETRA: sistemas CFR vs. sistemas estándar | [REGLA-DISTRIBUIDA] | alta |
| RN-S151-534 | Estatus válido de movimiento para consulta: STA = 1 ó 2 | [LÓGICA-CONTABLE] | alta |
| RN-S151-535 | Consulta de movimientos por autorización de aplicación (función 11 — CONAPL) | [REGLA-DISTRIBUIDA] | alta |
| RN-S151-536 | Paginación de resultados de consultas de movimientos | [LÓGICA-CONTABLE] | alta |
| RN-S151-537 | Consulta de movimientos por contrato diaria (función 12 — CONXCTO-DIA) | [REGLA-DISTRIBUIDA] | alta |
| RN-S151-538 | Cálculo de variación créditos-abonos en totales nacionales | [LÓGICA-CONTABLE] | alta |
| RN-S151-539 | Jerarquía de consulta en TOTXPROD-DIA: caja > sucursal > sistema | [LÓGICA-CONTABLE] | alta |
| RN-S151-540 | Total nacional diario — acumulación cross-CSI por ciclos (función 17) | [LÓGICA-CONTABLE] | alta |
| RN-S151-541 | Control de ciclos mensuales en CONSISMEN — ciclos AAMM hasta 99 entradas | [LÓGICA-CONTABLE] | alta |
| RN-S151-542 | Separación fecha de consulta (FECCON) vs. fecha de proceso (FECPRO) en CONSISDIA | [LÓGICA-CONTABLE] | alta |
| RN-S151-543 | Fecha de proceso S151 independiente de S500 (FECPRO vs. FECPRO151) | [REGLA-DISTRIBUIDA] | alta |
| RN-S151-544 | Manejo de errores DMSII — catálogo de 21 tipos | [RIESGO-EQUIVALENCIA] | alta |
| RN-S151-545 | Resolución de nombre de cliente vía S016L422 durante consulta de movimientos | [REGLA-DISTRIBUIDA] | alta |
| RN-S151-546 | Jerarquía organizacional Banamex: 7 niveles CSI→Sucursal | [HARDCODE-SOSPECHOSO] | alta |
| RN-S151-547 | Control de versiones de librería vía CTRLVERS (DAME_TIT) | [RIESGO-EQUIVALENCIA] | alta |
| RN-S151-548 | Validación de consistencia CSI primario vs. CSI secundario (RESCSI) | [LÓGICA-CONTABLE] | alta |
| RN-S151-549 | Flag de enrutamiento de transacciones a Citi (ENVCITI) | [REGLA-DISTRIBUIDA] | media |
| RN-S151-550 | Contadores de secuencia histórica: SECOKHI, SECINFHI, SECERRHI | [LÓGICA-CONTABLE] | alta |

---

## Reglas detalladas

---

### RN-S151-526 — Determinación de siglo — pivote año 50 (Y2K)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-526 |
| **Tipo** | [HARDCODE-SOSPECHOSO] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno (proyecto CRONOS 2000) |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Librería Utilitaria de Fechas |
| **Programa(s) fuente** | L030 (COBOL_L030.txt) — párrafos A2K-OBTAIN-CENTURY, A2K-CONV-AMD-TO-CAMD, A2K-CONV-MDA-TO-MDCA, A2K-CONV-DMA-TO-DMCA |
| **Frecuencia** | por-transacción (cada conversión de fecha) |
| **Sistemas downstream** | todos los programas S151 + S500 que usan fechas de 6 dígitos |

**Fórmula / pseudocódigo:**
```cobol
01  A2K-BASE-YEAR   PIC 9(02) VALUE 50.   ← HARDCODE

A2K-OBTAIN-CENTURY.
    IF A2K-FEC-YEAR-AA < A2K-BASE-YEAR
        MOVE 20 TO A2K-FEC-YEAR-CC        ← año 00-49 → siglo 21 (2000-2049)
    ELSE
        MOVE 19 TO A2K-FEC-YEAR-CC.       ← año 50-99 → siglo 20 (1950-1999)

-- Casos especiales:
IF fecha-6-digitos = 0      → fecha completa = 0 (fecha nula)
IF fecha-6-digitos = 999999 → fecha completa = 99999999 (fecha máxima / abierta)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| A2K-BASE-YEAR | CONSTANTE-HARDCODE | L030 | Pivote de siglo: < 50 → siglo 20, >= 50 → siglo 19 |
| A2K-FEC-YEAR-AA | CAMPO-FECHA | L030 | Año de 2 dígitos a interpretar |
| A2K-FEC-YEAR-CC | CAMPO-FECHA | L030 | Siglo calculado (19 ó 20) |

**Excepciones documentadas:**
- Fecha = 0: se trata como fecha nula, no se aplica conversión.
- Fecha = 999999: se mapea a 99999999 (fecha "abierta" / sin vencimiento).
- El pivote 50 es un HARDCODE de 1999. Si algún contrato tiene fecha AA >= 50 que sea realmente siglo 21, producirá un error de interpretación — riesgo confirmado para migraciones.

**Estado validación:** pendiente HITL

---

### RN-S151-527 — Habilitación/bloqueo del programa principal P000 vía STAREG

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-527 |
| **Tipo** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno batch |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Ciclo Diario |
| **Programa(s) fuente** | L030 — CONSISDIA Función 5 (WKS-CONSISDIA-F05) |
| **Frecuencia** | bajo-demanda (antes/después del batch principal) |
| **Sistemas downstream** | P000 (programa maestro del batch S151) |

**Fórmula / pseudocódigo:**
```
FUNCION 5 de CONSISDIA:
  WKS-B01F05-VALOR = 0  → habilita ejecución de P000
  WKS-B01F05-VALOR = 1  → bloquea ejecución de P000

El campo B01-SIS-STAREG en S151B01SISDIA controla si P000 puede ejecutarse.
Parámetros de entrada: FUNCION=5, SISTEMA, CSI, VALOR (0 o 1).
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| STAREG | CAMPO-CONTROL | S151 | Estatus de registro — 0=habilita P000, 1=bloquea P000 |
| P000 | PROGRAMA | S151 | Programa maestro del batch S151 |
| CSI | CAMPO-CLAVE | S151+S500 | Centro de Servicio Integrado (2 dígitos) |

**Excepciones documentadas:**
- Solo valores 0 y 1 son válidos. Cualquier otro valor no está documentado en el código.
- La función la puede llamar cualquier proceso con acceso a L030 — no hay autenticación adicional en la librería.

**Estado validación:** pendiente HITL

---

### RN-S151-528 — Control de disponibilidad del archivo de movimientos (STAARCLOG)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-528 |
| **Tipo** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno batch |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Movimientos Diarios |
| **Programa(s) fuente** | L030 — CONSISDIA Función 7 (WKS-CONSISDIA-F07) |
| **Frecuencia** | bajo-demanda |
| **Sistemas downstream** | procesos asíncronos que leen el archivo de movimientos |

**Fórmula / pseudocódigo:**
```
FUNCION 7 de CONSISDIA — actualiza B01-SIS-STAARCLOG:
  ESTATUS = 0  → archivo de movimientos DISPONIBLE (asíncrono puede leer)
  ESTATUS = 1  → archivo de movimientos NO DISPONIBLE (asíncrono debe esperar)

Parámetros: FUNCION=7, SISTEMA, CSI, FECHA (fecha del estatus a modificar), ESTATUS.
El campo se actualiza por fecha — hay un arreglo de 10 slots (WKS-B01-CTL-DIA OCCURS 10 TIMES).
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| STAARCLOG | CAMPO-CONTROL | S151 | Estatus de archivo de movimientos — 0=disponible, 1=no disponible |
| FECARCMOV | CAMPO-FECHA | S151 | Fecha del archivo de movimientos (por slot) |
| CTL-DIA | ESTRUCTURA | S151 | Arreglo de 10 slots de control diario |

**Excepciones documentadas:**
- El arreglo CTL-DIA tiene exactamente 10 slots — los slots se reutilizan en la ventana semanal.
- La granularidad es por fecha — si hay doble proceso en la misma fecha, el flag se sobreescribe.

**Estado validación:** pendiente HITL

---

### RN-S151-529 — Protocolo de apertura de la base semanal — OPEN INQUIRY BASESEMANAL

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-529 |
| **Tipo** | [RIESGO-EQUIVALENCIA] [REGLA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Regulador** | N/A — Arquitectura Unisys DMSII |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Acceso a Base de Datos Diaria |
| **Programa(s) fuente** | L030 — 01-00600-ABRE-BASEDIA, 01-00650-CIERRA-BASEDIA |
| **Frecuencia** | por-inicialización (función 0 y funciones 60/61/68/69) |
| **Sistemas downstream** | todos los procesos de consulta de movimientos (funciones 11-25) |

**Fórmula / pseudocódigo:**
```
01-00600-ABRE-BASEDIA:
  IF WKS-R01-STMDIA = 0          ← base diaria en estatus válido
    IF WKS-ABRE-SEM = 0          ← base no está abierta todavía
      CHANGE ATTRIBUTE TITLE OF BASESEMANAL TO WKS-R01-MOVDIA  ← nombre dinámico
      OPEN INQUIRY BASESEMANAL
        ON EXCEPTION PERFORM 900000-CHE-STA
                     MOVE 1 TO W77-ERROR-BASE
      IF W77-ERROR-BASE = 0
        MOVE 1 TO WKS-ABRE-SEM   ← marca como abierta

01-00650-CIERRA-BASEDIA:
  IF WKS-ABRE-SEM = 1
    CLOSE BASESEMANAL
      ON EXCEPTION PERFORM 900000-CHE-STA
                   MOVE 1 TO W77-ERR
    IF W77-ERR = 0
      MOVE ZERO TO WKS-ABRE-SEM  ← marca como cerrada
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| BASESEMANAL | ESTRUCTURA-BD | S151 | Base de datos DMSII de movimientos diarios (nombre dinámico) |
| WKS-R01-STMDIA | CAMPO-CONTROL | S151 | Estatus de la base diaria: 0=válida, 1=inválida |
| WKS-R01-MOVDIA | CAMPO-NOMBRE | S151 | Nombre dinámico del dataset de movimientos diarios |
| WKS-ABRE-SEM | FLAG | L030 | Flag interno: 0=cerrada, 1=abierta en memoria |

**Excepciones documentadas:**
- El nombre de la base es dinámico (cambia cada día) — viene de CONSISDIA.
- OPEN INQUIRY = solo lectura en DMSII; el sistema moderno equivalente es una conexión de solo lectura a la base del día.
- Si la base está en estatus inválido (STMDIA = 1), NO se intenta abrir.

**Estado validación:** pendiente HITL

---

### RN-S151-530 — Ventana deslizante de 10 semi-días para localización de dataset diario

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-530 |
| **Tipo** | [RIESGO-EQUIVALENCIA] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Ventana de Consulta Diaria |
| **Programa(s) fuente** | L030 — 11-00100-DAME-DATASET, 11-00110-DAME-NUMSET, 12-00100-DAME-DATASET, 17-00100-DAME-DATASET |
| **Frecuencia** | por-transacción (cada consulta de movimientos) |
| **Sistemas downstream** | funciones 11, 12, 13, 14, 16, 17, 18, 19, 21, 24 |

**Fórmula / pseudocódigo:**
```
DAME-NUMSET (aplica a funciones 11, 12, 17):
  PERFORM VARYING W77-IND FROM 1 BY 1
          UNTIL W77-IND > 10 OR W77-ENCONTRADO = 1
    IF WKS-R01-FECSEM(W77-IND) = WKS-PARAM-FECHA
      MOVE 1 TO W77-ENCONTRADO
      IF W77-IND > 5
        COMPUTE W77-BASE-NUMDIA = W77-IND - 5  ← slot 6-10 → día 1-5 (base anterior)
      ELSE
        MOVE W77-IND TO W77-BASE-NUMDIA          ← slot 1-5  → día 1-5 (base actual)

Estructura CTL-DIA: 10 slots, cada uno con FECARCMOV, NIVARCMOV, NIVBDMOV, STAARCLOG.
Los slots 1-5 y 6-10 representan los mismos 5 días pero en diferentes semanas (doble buffer).
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-R01-FECSEM | ARREGLO-FECHAS | S151 | Array de 10 fechas del ciclo semanal |
| W77-BASE-NUMDIA | CAMPO-ÍNDICE | L030 | Número de slot de la base diaria (1-5) |
| CTL-DIA | ESTRUCTURA | S151 | 10 slots de control — doble buffer semanal |

**Excepciones documentadas:**
- Máximo 10 semi-días en ventana. Si la fecha de consulta no está en la ventana → W77-MSG = 19 (fecha no disponible).
- Si la base semanal no está abierta → W77-MSG = 7 (base no disponible).
- El doble buffer (slots 1-5 y 6-10) permite solapar dos semanas durante el cierre mensual.

**Estado validación:** pendiente HITL

---

### RN-S151-531 — Catálogo de claves de transacción (CVETRAN) — límite 10,000 entradas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-531 |
| **Tipo** | [HARDCODE-SOSPECHOSO] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Catálogo interno S151/S500 |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Catálogo de Tipos de Movimiento |
| **Programa(s) fuente** | L030 — 01-00800-CLAVES, 01-00805-CARGA-CVETRAN, 01-00811-MUEVE-CLAVES |
| **Frecuencia** | por-inicialización (función 0) |
| **Sistemas downstream** | todas las funciones de consulta que clasifican movimientos por CVETRA |

**Fórmula / pseudocódigo:**
```
WKS-CVE-SIS OCCURS 10000 TIMES:    ← HARDCODE del límite
  WKS-CVE-CVE    PIC 9(04) COMP    ← clave de transacción
  WKS-CVE-TMOV   PIC 9(02) COMP    ← tipo de movimiento
  WKS-CVE-LEY    PIC 9(04) COMP    ← número de leyenda asociada
  WKS-CVE-INDMOV PIC 9(02) COMP    ← indicador de movimiento
WKS-CVE-SIS-2 OCCURS 10000 TIMES:
  WKS-CVE-EDOCTA  PIC 9(02) COMP   ← indicador estado de cuenta
  WKS-CVE-S28     PIC 9(02) COMP   ← flag S028
  WKS-CVE-INDBIT  PIC 9(02) COMP   ← indicador bit
  WKS-CVE-SUMASCR PIC 9(02) COMP   ← sumacría
  WKS-CVE-ENVCITI PIC 9(02) COMP   ← flag envío a Citi

Si W77-IND >= 10001 → error de desbordamiento → log "CVETRAN > 10000".
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-CVE-CVE | CAMPO-CLAVE | S151+S500 | Clave numérica del tipo de transacción |
| WKS-CVE-TMOV | CAMPO-TIPO | S151+S500 | Tipo de movimiento (débito/crédito) |
| WKS-CVE-LEY | CAMPO-REF | S151+S500 | Referencia a catálogo de leyendas |
| WKS-CVE-ENVCITI | FLAG | S151+S500 | 1=enviar a Citi, 2=otra regla de envío |

**Excepciones documentadas:**
- El límite de 10,000 es un HARDCODE en memoria. Si el catálogo crece más allá de este límite, el programa registra un error y deja de cargar claves adicionales.
- El catálogo se carga una sola vez en la inicialización (función 0) y permanece en memoria durante toda la sesión.
- Formatos de catálogo 1-4 tienen layouts de campos distintos — crítico replicar la lógica de selección.

**Estado validación:** pendiente HITL

---

### RN-S151-532 — Catálogo de leyendas de transacción — límite 2,000 entradas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-532 |
| **Tipo** | [HARDCODE-SOSPECHOSO] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Catálogo interno |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Catálogo de Leyendas de Transacción |
| **Programa(s) fuente** | L030 — 01-00830-CARGA-LEYENDAS-TRAN, 01-00831-LEYENDAS |
| **Frecuencia** | por-inicialización (función 0) |
| **Sistemas downstream** | pantallas de visualización de movimientos (S151 display screens) |

**Fórmula / pseudocódigo:**
```
WKS-CATALOGO-LEY-CVETRA OCCURS 2000 TIMES:  ← HARDCODE del límite
  WKS-LEY-CVELEY  PIC 9(04) COMP   ← número de leyenda
  WKS-LEY-TCORTO  PIC X(20)        ← texto corto (20 chars)

Si W77-IND >= 2001 → error → log "NUM. LEY. CVETRA > 2000".

Caso especial S500: carga además WKS-CATALOGO-LEYDEV (leyendas de devolución):
  WKS-LEYDEV-TCORTO OCCURS 100 TIMES PIC X(20)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-LEY-TCORTO | CAMPO-TEXTO | S151+S500 | Texto corto de la leyenda (20 chars) para pantallas |
| WKS-LEY-CVELEY | CAMPO-CLAVE | S151+S500 | Número de leyenda — referenciado por WKS-CVE-LEY |
| LEYDEV | SUBCAT | S500 | Catálogo de leyendas de devolución (solo S500, hasta 100) |

**Excepciones documentadas:**
- La carga de leyendas es independiente de la carga de CVETRAN pero posterior — el orden de carga en `01-00800-CLAVES` es: primero CVETRAN, luego LEYENDAS.
- El texto corto está limitado a 20 caracteres — posibles truncamientos de leyendas largas en el sistema objetivo.

**Estado validación:** pendiente HITL

---

### RN-S151-533 — Formato de catálogo CVETRA: sistemas CFR vs. sistemas estándar

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-533 |
| **Tipo** | [REGLA-DISTRIBUIDA] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Clasificación de Sistemas |
| **Programa(s) fuente** | L030 — 01-00805-CARGA-CVETRAN (líneas 10726-10736) |
| **Frecuencia** | por-inicialización |
| **Sistemas downstream** | sistemas con número 804, 404, 707, 203 (CFR) |

**Fórmula / pseudocódigo:**
```
W88-ESQ-CFR VALUE 804, 404, 707, 203.   ← HARDCODE: sistemas CFR

IF W88-ESQ-CFR                                ← sistema es CFR
  MOVE 1059 TO WKS-EL710-CAT                  ← catálogo 1059 (CFR)
  STRING "S" WKS-SISTEMA-STR INTO WKS-EL710-LLAVE1-STR  ← llave = "Sxxx"
ELSE
  MOVE WKS-PARAM-SIST TO WKS-EL710-LLAVE1    ← llave numérica
  MOVE 523 TO WKS-EL710-CAT.                  ← catálogo 523 (estándar)

Formatos de catálogo (W77-CAT-FORMATO):
  Formato 1: catálogo 6, búsqueda por sistema (LLAVE2)
  Formato 2: catálogo numcat, búsqueda directa (LLAVE1)
  Formato 3: catálogo numcat, sin llave (LLAVE1=0, LLAVE2=0)
  Formato 4: catálogo numcat, sin llave (LLAVE1=0, LLAVE2=0)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| W88-ESQ-CFR | CONDICION-88 | L030 | Sistemas bajo esquema CFR: 804, 404, 707, 203 |
| WKS-EL710-CAT | CAMPO-CLAVE | L030 | Número de catálogo a consultar en L710 |
| WKS-EL710-BUSQUEDA | CAMPO-CONTROL | L030 | Tipo de búsqueda: 1=directa, 2=por llave |

**Excepciones documentadas:**
- Los sistemas CFR tienen su llave formateada como cadena "Sxxx" (no numérica pura).
- El catálogo 1059 vs 523 es un bifurcación crítica — si el sistema objetivo no mantiene esta distinción, el catálogo de transacciones se cargará incorrectamente para sistemas CFR.

**Estado validación:** pendiente HITL

---

### RN-S151-534 — Estatus válido de movimiento para consulta: STA = 1 ó 2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-534 |
| **Tipo** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno de movimientos |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Estado de Movimiento Contable |
| **Programa(s) fuente** | L030 — 11-00070-BUSCA-MOVTO, 11-00300-SALIDA-P11SAL, 12-00200-BUSCA-REGISTRO |
| **Frecuencia** | por-transacción |
| **Sistemas downstream** | pantallas P11, P12, P15, P16, P17 de S151 |

**Fórmula / pseudocódigo:**
```
-- Validación universal en todas las funciones de consulta:
IF (WKS-D01-STA = 1 OR WKS-D01-STA = 2) AND
   WKS-D01-AUTAPL = WKS-PARAM-AUTAPL AND
   WKS-D01-FECCONT = WKS-PARAM-FECHA
THEN
   → movimiento elegible para consulta
ELSE
   → movimiento ignorado (STA = 0 = eliminado/pendiente, STA >= 3 = otro estado)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-D01-STA | CAMPO-ESTADO | S151 | Estatus del movimiento: 1=activo, 2=procesado. 0 y >=3 = no consultable |
| WKS-D01-AUTAPL | CAMPO-CLAVE | S151 | Número de autorización de aplicación |
| WKS-D01-FECCONT | CAMPO-FECHA | S151 | Fecha contable del movimiento |

**Excepciones documentadas:**
- STA = 0 no es consultable — posiblemente representa movimientos eliminados o en proceso.
- STA = 3+ no se documenta en el código de esta librería — su semántica requiere validación HITL.
- La combinación STA + AUTAPL + FECHA es la clave de búsqueda lógica del movimiento.

**Estado validación:** pendiente HITL

---

### RN-S151-535 — Consulta de movimientos por autorización de aplicación (función 11 — CONAPL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-535 |
| **Tipo** | [REGLA-DISTRIBUIDA] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Control operacional |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Consulta de Movimientos por Aplicación |
| **Programa(s) fuente** | L030 — 11-00050-CONAPL y sub-párrafos |
| **Frecuencia** | bajo-demanda |
| **Sistemas downstream** | pantalla P11 de S151, operadores bancarios |

**Fórmula / pseudocódigo:**
```
Validaciones previas:
  IF WKS-PARAM-SUCOPE NOT IN (859, 100, 342, 110, 511, 870) → MSG=45 (sucursal no válida)
  IF WKS-PARAM-CAJA = 0                                      → MSG=48 (caja requerida)

Flujo con SECMOV previo (paginación):
  IF WKS-P11SECMOV > 0
    PERFORM 11-00510-FF-AUTS151    ← posicionar en el registro secuencial
    IF W77-ERROR-BASE = 0
      PERFORM 11-00070-BUSCA-MOVTO UNTIL
        W77-MOVTOS = WKS-P11NUMMOV OR W77-ENCONTRADO = 1 OR W77-ERROR-BASE > 0
      PERFORM 11-00300-SALIDA-P11SAL UNTIL
        W77-EOF=1 OR W77-ERROR-BASE>0 OR W77-MOVTOS=W77-LINEAS(5)

Flujo sin SECMOV (inicio):
  PERFORM 11-00500-FF-AUTAPL        ← find-first por autorización
  PERFORM 11-00300-SALIDA-P11SAL UNTIL
    W77-EOF=1 OR W77-ERROR-BASE>0 OR W77-MOVTOS=5
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-PARAM-AUTAPL | CAMPO-CLAVE | S151 | Número de autorización de aplicación a consultar |
| WKS-P11SECMOV | CAMPO-PAGINACION | S151 | Posición secuencial para paginación |
| WKS-P11NUMMOV | CAMPO-PAGINACION | S151 | Número del último movimiento presentado |
| SUCOPE | CAMPO-CLAVE | S151 | Sucursal-operación. Solo válidas: 859, 100, 342, 110, 511, 870 |

**Excepciones documentadas:**
- La lista de sucursales válidas (859, 100, 342, 110, 511, 870) es un HARDCODE — posiblemente ATMs y cajas especiales de Banamex.
- Si SECMOV = 0 → inicio de búsqueda desde el primer registro.
- Máximo 5 movimientos por pantalla (W77-LINEAS = 5 hardcoded para función 11).

**Estado validación:** pendiente HITL

---

### RN-S151-536 — Paginación de resultados de consultas de movimientos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-536 |
| **Tipo** | [LÓGICA-CONTABLE] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Regulador** | N/A — Control de pantallas |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Paginación de Movimientos |
| **Programa(s) fuente** | L030 — inicio de cada función de consulta |
| **Frecuencia** | por-transacción |
| **Sistemas downstream** | pantallas P11, P12, P15, P16, P17 de S151 |

**Fórmula / pseudocódigo:**
```
Límites de paginación por función (HARDCODE):
  Función 11 (CONAPL):       W77-LINEAS = 5   ← máximo 5 movimientos por pantalla
  Función 12 (CONXCTO-DIA):  W77-LINEAS = 14  ← máximo 14 movimientos por pantalla
  Función 16 (TOTXPROD-DIA): W77-LINEAS = 12  ← máximo 12 conceptos
  Función 17 (TOTNAL-DIA):   W77-LINEAS = 12  ← máximo 12 conceptos

Mecanismo:
  IF W77-MOVTOS = W77-LINEAS → parar presentación (pantalla llena)
  El campo SECMOV (posición secuencial) se devuelve al llamador
  En siguiente llamada, el llamador provee SECMOV para continuar desde ahí
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| W77-LINEAS | CONSTANTE | L030 | Máximo de renglones por pantalla — HARDCODE por función |
| W77-MOVTOS | CONTADOR | L030 | Contador de movimientos presentados en la página actual |
| WKS-P1xSECMOV | CAMPO-PAGINACION | S151 | Posición secuencial para continuar en siguiente llamada |

**Excepciones documentadas:**
- Los límites (5, 14, 12) son hardcodes del diseño de pantallas originales — en el sistema objetivo se deben parametrizar.
- La paginación es stateful: el sistema recibe SECMOV del cliente y reposita en DMSII (FIND BY SEEKING) — modelo de sesión Unisys sin equivalente directo en sistemas REST.

**Estado validación:** pendiente HITL

---

### RN-S151-537 — Consulta de movimientos por contrato diaria (función 12 — CONXCTO-DIA)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-537 |
| **Tipo** | [REGLA-DISTRIBUIDA] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Consulta operacional |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Consulta de Movimientos por Cuenta/Contrato |
| **Programa(s) fuente** | L030 — 12-00050-CONXCTO-DIA, 12-00070-BUSCA-CLIENTE, 12-00080-LLAMA-L422 |
| **Frecuencia** | bajo-demanda |
| **Sistemas downstream** | pantalla P12 de S151; llama a S016L422 para nombre de cliente |

**Fórmula / pseudocódigo:**
```
Parámetros: SISTEMA, SUC, CTA (contrato), FEC (fecha), SECMOV

Validaciones:
  IF SISTEMA = 500 AND ENT-P12NIO ≠ " "
    MOVE "S" TO SAL-P12NIO          ← flag NIO (Nuevo Instrumento Operativo) solo S500
  ELSE
    MOVE SPACES TO SAL-P12NIO ENT-P12NIO

Búsqueda con SECMOV previo:
  PERFORM 12-00400-FF-AUTS151       ← posicionar en registro previo
  IF WKS-D01-CTO ≠ WKS-PARAM-CONTRATO → MOVE ZERO TO WKS-P12SECMOV (descarta posición)

Presentación:
  PERFORM 12-00300-SALIDA-P12SAL UNTIL
    W77-MSG > 0 OR W77-IND = 14 OR W77-ERROR-BASE > 0

Resolución de nombre cliente:
  IF W77-IND-S016 = 1 AND CONTRATO > 0
    CALL "S016_L422_B01SXCTE IN S016L422"
    → retorna CTE-NOM, CTE-NUM

Manejo especial: MSG=61 → no se encontró primer movimiento
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-PARAM-CONTRATO | CAMPO-CLAVE | S151+S500 | Número de contrato/cuenta a consultar |
| WKS-D01-CTO | CAMPO-CLAVE | S151 | Contrato del registro de movimiento |
| NIO | FLAG | S500 | Nuevo Instrumento Operativo — solo aplica a sistema 500 |
| S016L422 | LIBRERÍA | S500 | Librería de consulta de datos de clientes S500 |

**Excepciones documentadas:**
- El NIO solo aplica a sistema 500 — si el sistema es distinto, el campo se limpia automáticamente.
- La llamada a S016L422 depende de que la librería esté cargada (W77-IND-S016 = 1).
- MSG=4 indica que no hay más movimientos (fin de datos) — el SECMOV se limpia.

**Estado validación:** pendiente HITL

---

### RN-S151-538 — Cálculo de variación créditos-abonos en totales nacionales

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-538 |
| **Tipo** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno (puede alimentar reportes CNBV) |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Totales Nacionales Diarios |
| **Programa(s) fuente** | L030 — 17-00300-CALCULA-VARIACION |
| **Frecuencia** | cierre-diario |
| **Sistemas downstream** | pantalla P17 de S151, reportes de operación |

**Fórmula / pseudocódigo:**
```
17-00300-CALCULA-VARIACION:
  IF WKS-CONXCSI-IMPCR > WKS-CONXCSI-IMPAB
    COMPUTE WKS-CONXCSI-IMPVAR = WKS-CONXCSI-IMPCR - WKS-CONXCSI-IMPAB
    MOVE " -" TO WKS-CONXCSI-SIGNO          ← créditos superan abonos → variación negativa de fondos
  ELSE
  IF WKS-CONXCSI-IMPCR = WKS-CONXCSI-IMPAB
    MOVE ZERO TO WKS-CONXCSI-IMPVAR
    MOVE "  " TO WKS-CONXCSI-SIGNO          ← balance neto = 0
  ELSE
    COMPUTE WKS-CONXCSI-IMPVAR = WKS-CONXCSI-IMPAB - WKS-CONXCSI-IMPCR
    MOVE " +" TO WKS-CONXCSI-SIGNO          ← abonos superan créditos → variación positiva de fondos

Acumulación previa (17-00211-ACUMULA-TOTXCSI):
  COMPUTE WKS-CONXCSI-NUMCR += WKS-D03-NUMCR(W77-IND2)  (solo si > 0)
  COMPUTE WKS-CONXCSI-IMPCR += WKS-D03-IMPCR(W77-IND2)
  COMPUTE WKS-CONXCSI-NUMAB += WKS-D03-NUMAB(W77-IND2)
  COMPUTE WKS-CONXCSI-IMPAB += WKS-D03-IMPAB(W77-IND2)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-CONXCSI-IMPCR | MONTO-ACUM | S151 | Importe total de créditos acumulado (PIC 9(12)) |
| WKS-CONXCSI-IMPAB | MONTO-ACUM | S151 | Importe total de abonos acumulado (PIC 9(12)) |
| WKS-CONXCSI-IMPVAR | MONTO-VAR | S151 | Variación neta (valor absoluto) |
| WKS-CONXCSI-SIGNO | CAMPO-SIGNO | S151 | " -"=créditos>abonos, "  "=balance, " +"=abonos>créditos |

**Excepciones documentadas:**
- La semántica del signo es contra-intuitiva: " -" cuando IMPCR > IMPAB (más créditos que abonos reduce fondos disponibles en GL).
- El signo es un campo alfanumérico de 2 caracteres — no es un campo numérico con signo COMP.

**Estado validación:** pendiente HITL

---

### RN-S151-539 — Jerarquía de consulta en TOTXPROD-DIA: caja > sucursal > sistema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-539 |
| **Tipo** | [LÓGICA-CONTABLE] [REGLA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control operacional |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Totales por Producto Diarios |
| **Programa(s) fuente** | L030 — 16-00050-TOTXPROD-DIA (líneas 13620-13634) |
| **Frecuencia** | bajo-demanda (consulta de totales del día) |
| **Sistemas downstream** | pantallas P15, P16 de S151 |

**Fórmula / pseudocódigo:**
```
16-00050-TOTXPROD-DIA:
  IF SISTEMA > 0
    IF SUCOPE > 0
      IF CAJA > 0
        MOVE 5 TO W77-TIPO-CON
        PERFORM 16-01300-FF-TOTXCAJA-DIA   ← consulta por caja específica
      ELSE
        MOVE 4 TO W77-TIPO-CON
        PERFORM 16-01400-FF-TOTXSUC-DIA    ← consulta por sucursal
    ELSE
      IF CAJA > 0
        MOVE 45 TO W77-MSG               ← ERROR: caja sin sucursal no permitido
      ELSE
        MOVE 1 TO W77-TIPO-CON
        PERFORM 16-01500-FF-TOTXSIS       ← consulta por sistema (nivel nacional)
  ELSE
    MOVE 42 TO W77-MSG                   ← ERROR: sistema requerido

Moneda de contrato:
  IF WKS-ALFA-MONCON NOT IS NUMERIC → MOVE ZERO TO WKS-PARAM-MONCON
  (moneda de contrato solo válida si el valor es numérico)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| W77-TIPO-CON | CAMPO-TIPO | L030 | Tipo de consulta: 1=sistema, 4=sucursal, 5=caja |
| WKS-PARAM-SUCOPE | CAMPO-CLAVE | S151 | Sucursal-Operación |
| WKS-PARAM-CAJA | CAMPO-CLAVE | S151 | Número de caja |
| WKS-PARAM-MONCON | CAMPO-MONEDA | S151 | Moneda de contrato (opcional, numérico) |

**Excepciones documentadas:**
- Caja sin sucursal → MSG=45 (error de parámetros). La jerarquía es estricta: caja requiere sucursal.
- Sistema = 0 → MSG=42 (sistema requerido).
- Sistema S501 tiene lógica especial para caja alfanumérica (sucursales 519, 1037, 1905).

**Estado validación:** pendiente HITL

---

### RN-S151-540 — Total nacional diario — acumulación cross-CSI por ciclos (función 17)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-540 |
| **Tipo** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Reporte operacional interno |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Totales Nacionales |
| **Programa(s) fuente** | L030 — 17-00050-TOTNAL-DIA, 17-00200-AVANZA-REGISTRO, 17-00211-ACUMULA-TOTXCSI |
| **Frecuencia** | cierre-diario / bajo-demanda |
| **Sistemas downstream** | pantalla P17 de S151 |

**Fórmula / pseudocódigo:**
```
17-00200-AVANZA-REGISTRO:
  PERFORM 17-00211-ACUMULA-TOTXCSI
          VARYING W77-IND2 FROM 1 BY 1 UNTIL W77-IND2 > 10
  IF W88-CON-SIS
    PERFORM 17-01000-FN-TOTXSIS      ← avanzar al siguiente registro del sistema

17-00211-ACUMULA-TOTXCSI:
  WKS-D03-NUMCR(W77-IND2), WKS-D03-IMPCR(W77-IND2)   → acumular créditos
  WKS-D03-NUMAB(W77-IND2), WKS-D03-IMPAB(W77-IND2)   → acumular abonos
  (solo se acumula si > 0)

Ciclos de 10 posiciones por registro D03 (WKS-D03 OCCURS):
  Cada posición = un CSI diferente
  Total nacional = suma de todos los CSIs disponibles en el dataset
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-D03 | ESTRUCTURA-BD | S151 | Registro de totales por sistema en la base semanal |
| WKS-D03-NUMCR | CAMPO-CONTADOR | S151 | Número de transacciones de crédito en el slot CSI |
| WKS-D03-IMPCR | MONTO | S151 | Importe de créditos en el slot CSI |
| WKS-D03-MONEDA | CAMPO-MONEDA | S151 | Moneda del registro de totales |

**Excepciones documentadas:**
- La moneda del primer registro D03 se usa para determinar la moneda de la consulta (WKS-D03-MONEDA → WKS-PARAM-MONEDA).
- El ciclo de 10 posiciones permite hasta 10 CSIs por registro — límite de la estructura DMSII.

**Estado validación:** pendiente HITL

---

### RN-S151-541 — Control de ciclos mensuales en CONSISMEN — ciclos AAMM hasta 99 entradas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-541 |
| **Tipo** | [LÓGICA-CONTABLE] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Regulador** | N/A — Control interno mensual |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Ciclo Mensual |
| **Programa(s) fuente** | L030 — WKS-S151B03SISMEN (campo CICLO OCCURS 99 TIMES) + funciones 15-22 |
| **Frecuencia** | cierre-mensual |
| **Sistemas downstream** | procesos de cierre mensual S151 |

**Fórmula / pseudocódigo:**
```
WKS-B03-CICLO OCCURS 99 TIMES:   ← HARDCODE: máximo 99 meses en historial
  WKS-B03-NOMBDMOV    PIC X(17)  ← nombre del dataset de movimientos del mes
  WKS-B03-NUMBDMOV    PIC 9(02)  ← número del dataset
  WKS-B03-AAMM        PIC 9(06)  ← período AÑO-MES (ej. 202406 = jun 2024)
  WKS-B03-SECOK       PIC 9(10)  ← secuencia OK del mes
  WKS-B03-SECINF      PIC 9(10)  ← secuencia informativa del mes
  WKS-B03-SECERR      PIC 9(10)  ← secuencia de error del mes
  WKS-B03-STABDMOV    PIC 9(02)  ← estatus del dataset del mes

Función 18 (CAMBIA AAMM): actualiza el período mes-año de un ciclo dado.
Función 15 (MODIFICA CICLO): actualiza todos los campos de un ciclo.
Función 22 (MODIFICA STATUS BD): actualiza estatus de la base de movimientos de un ciclo.
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| AAMM | CAMPO-PERIODO | S151 | Período mensual en formato AAAAMM (6 dígitos) |
| STABDMOV | CAMPO-ESTADO | S151 | Estatus del dataset de movimientos del ciclo mensual |
| SECOK | CAMPO-CONTADOR | S151 | Secuencia de registros exitosos del mes |
| NOMBDMOV | CAMPO-NOMBRE | S151 | Nombre del dataset DMSII del mes |

**Excepciones documentadas:**
- El límite de 99 ciclos mensuales corresponde a aproximadamente 8 años de historial — HARDCODE que puede ser un problema en migraciones con retención regulatoria mayor.
- AAMM usa 6 dígitos (AAAAMM) — mismo patrón que el formato AAMMDD con solo año+mes.

**Estado validación:** pendiente HITL

---

### RN-S151-542 — Separación fecha de consulta (FECCON) vs. fecha de proceso (FECPRO) en CONSISDIA

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-542 |
| **Tipo** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | CNBV — control de fecha valor vs. fecha proceso |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Fechas del Sistema |
| **Programa(s) fuente** | L030 — CONSISDIA Funciones 2 y 3, 01-00220-DAME-FECPRO |
| **Frecuencia** | por-inicialización + bajo-demanda |
| **Sistemas downstream** | todos los programas que consultan la fecha de proceso S151 |

**Fórmula / pseudocódigo:**
```
Dos fechas distintas en S151B01SISDIA:
  WKS-B01-FECCON  PIC 9(08)   ← fecha de consulta (cuando se consultó el sistema)
  WKS-B01-FECPRO  PIC 9(08)   ← fecha de proceso (fecha del batch que procesó)

01-00220-DAME-FECPRO:
  MOVE WKS-B01-FECPRO TO WKS-R00-FECPRO    ← copia a estructura de trabajo
                          WKS-R01-FECPRO    ← replica en primer slot de control
                          WKS-FECHA-PROCESO ← variable global de fecha de proceso

Función 2 (actualiza FECCON): para registrar cuándo se realizó la última consulta.
Función 3 (actualiza FECPRO): para registrar cuándo corrió el batch.
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| FECCON | CAMPO-FECHA | S151 | Fecha de la última consulta realizada al sistema |
| FECPRO | CAMPO-FECHA | S151 | Fecha del último batch de procesamiento |
| WKS-FECHA-PROCESO | CAMPO-FECHA | L030 | Fecha de proceso actual — usada en todas las consultas |

**Excepciones documentadas:**
- FECCON ≠ FECPRO en días normales — FECCON puede estar adelantada si se consultan movimientos del día actual.
- Esta separación es regulatoriamente relevante: CNBV distingue fecha de operación vs. fecha de registro contable.

**Estado validación:** pendiente HITL

---

### RN-S151-543 — Fecha de proceso S151 independiente de S500 (FECPRO vs. FECPRO151)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-543 |
| **Tipo** | [REGLA-DISTRIBUIDA] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Arquitectura de sistemas |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Sincronización de Fechas S151/S500 |
| **Programa(s) fuente** | L030 — WKS-B01-FECPRO151, CONSISDIA Función 11 |
| **Frecuencia** | por-inicialización del batch |
| **Sistemas downstream** | procesos de reconciliación S151 ↔ S500 |

**Fórmula / pseudocódigo:**
```
S151B01SISDIA contiene DOS fechas de proceso:
  WKS-B01-FECPRO     PIC 9(08)  ← fecha de proceso del sistema "padre" (S500)
  WKS-B01-FECPRO151  PIC 9(08)  ← fecha de proceso exclusiva de S151

Función 11 (actualiza FECPRO151):
  WKS-B01F11-FECPRO151 → se actualiza independientemente de FECPRO

Uso en DAME-FECPRO: solo se mueve FECPRO (no FECPRO151) a WKS-FECHA-PROCESO.
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| FECPRO | CAMPO-FECHA | S151+S500 | Fecha de proceso del sistema padre (S500 / captación) |
| FECPRO151 | CAMPO-FECHA | S151 | Fecha de proceso exclusiva del GL (S151) |

**Excepciones documentadas:**
- La existencia de dos fechas de proceso confirma que S151 y S500 pueden tener fechas de proceso distintas — situación que ocurre cuando el GL se adelanta o atrasa respecto a captación.
- En el sistema objetivo esta separación debe mantenerse para reconciliaciones intradía.

**Estado validación:** pendiente HITL

---

### RN-S151-544 — Manejo de errores DMSII — catálogo de 21 tipos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-544 |
| **Tipo** | [RIESGO-EQUIVALENCIA] [REGLA-DISTRIBUIDA] |
| **Confianza** | alta |
| **Regulador** | N/A — Arquitectura Unisys DMSII |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Errores de Base de Datos |
| **Programa(s) fuente** | L030 — WKS-TAB-ERRDMSII (líneas 6440-6487) |
| **Frecuencia** | por-transacción (en errores) |
| **Sistemas downstream** | todos los procesos que acceden a bases DMSII |

**Fórmula / pseudocódigo:**
```
WKS-TAB-ERRDMSII (catálogo hardcoded de 21 errores × 20 bytes):
  01 NOTFOUND       02 DUPLICATES      03 DEADLOCK
  04 DATAERROR      05 NOTLOCKED       06 KEYCHANGE
  07 SYSTEMERROR    08 READONLY        09 IOERROR
  10 LIMITERROR     11 OPENERROR       12 CLOSEERROR
  13 NORECORD       14 INUSE           15 AUDITERROR
  16 ABORT          17 SECURITYERROR   18 VERSIONERROR
  19 FATALERROR     20 INTEGRITY ERROR 21 INTLIBERROR

W77-RES-LIBCON (resultado retornado al llamador):
  0 = OK
  2 = función inválida (FUNCION-ERROR)
  5 = error de inicialización
  Otros = código de mensaje de error (MSG code)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-ERR-DMSII | CAMPO-ERROR | L030 | Código numérico del error DMSII (1-21) |
| WKS-NOM-BDERR-DMSII | CAMPO-NOMBRE | L030 | Nombre del dataset que causó el error |
| W77-RES-LIBCON | CÓDIGO-RETORNO | L030 | Código de resultado devuelto al llamador |

**Excepciones documentadas:**
- El error 03 (DEADLOCK) en DMSII no tiene reintento automático — el programa termina con error.
- El error 18 (VERSIONERROR) es específico de Unisys DMSII — no tiene equivalente directo en bases de datos relacionales.
- En el sistema objetivo, estos 21 tipos deben mapearse a excepciones del motor de BD elegido.

**Estado validación:** pendiente HITL

---

### RN-S151-545 — Resolución de nombre de cliente vía S016L422 durante consulta de movimientos

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-545 |
| **Tipo** | [REGLA-DISTRIBUIDA] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Integración S151 ↔ S500 |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Enriquecimiento de Datos de Cliente |
| **Programa(s) fuente** | L030 — 12-00070-BUSCA-CLIENTE, 12-00080-LLAMA-L422 |
| **Frecuencia** | por-transacción (consulta de movimientos con nombre) |
| **Sistemas downstream** | S016L422 (30+ funciones de consulta S500) |

**Fórmula / pseudocódigo:**
```
12-00080-LLAMA-L422:
  IF W77-IND-S016 = 1 AND WKS-PARAM-CONTRATO > 0
    MOVE LOW-VALUES TO E422-84-CTR-ENTRADA, S422-84-CTR-SALIDA
    MOVE ZERO TO R422-84-CTR-ERROR, E422-84-CTA-NUMPREF
    MOVE WKS-PARAM-CONTRATO TO E422-84-CTA-NUM
    MOVE WKS-PARAM-PROD     TO E422-84-CTA-NUMPROD
    MOVE ZERO                TO E422-84-CTE-NUM
    MOVE WKS-PARAM-INS       TO E422-84-CTA-CVEINST
    MOVE 2                   TO E422-84-OPCION         ← opción 2 = búsqueda por cuenta
    CALL "S016_L422_B01SXCTE IN S016L422"
         USING E422-84-CTR-ENTRADA, S422-84-CTR-SALIDA
         GIVING R422-84-CTR-ERROR
    IF R422-84-CTR-ERROR = 0
      MOVE S422-84-CTE-NOM TO WKS-SAL-P12NOMCTE        ← nombre del cliente
      MOVE S422-84-CTE-NUM TO WKS-SAL-P12CTE            ← número del cliente
    ELSE
      MOVE SPACES TO WKS-SAL-P12NOMCTE
      MOVE ZERO   TO WKS-SAL-P12CTE
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| S016L422 | LIBRERÍA | S500 | Librería de datos de clientes/cuentas S500 (30+ entry points) |
| E422-84-OPCION | CAMPO-FUNCIÓN | S500 | Opción de consulta en S016L422_B01SXCTE: 2=por cuenta |
| W77-IND-S016 | FLAG | L030 | 1=S016L422 está cargada en memoria, 0=no disponible |
| S422-84-CTE-NOM | CAMPO-SALIDA | S500 | Nombre del cliente retornado por S016L422 |

**Excepciones documentadas:**
- Si S016L422 no está cargada (W77-IND-S016 = 0), el nombre de cliente se omite silenciosamente — no es un error.
- La librería S016L422 tiene 30+ entry points propios — es un sistema completo de consulta de datos de clientes/captación.

**Estado validación:** pendiente HITL

---

### RN-S151-546 — Jerarquía organizacional Banamex: 7 niveles CSI→Sucursal

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-546 |
| **Tipo** | [HARDCODE-SOSPECHOSO] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Estructura organizacional del banco |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Jerarquía Organizacional |
| **Programa(s) fuente** | L030 — WKS-ESTRUCTURA (OCCURS 2000 TIMES), WKS-COMITE, WKS-AREA, WKS-DIVISION, WKS-DIRECCION, WKS-REGIONAL, WKS-OPECOM, WKS-SUCURSAL |
| **Frecuencia** | por-inicialización |
| **Sistemas downstream** | reportes por dimensión organizacional, pantallas de totales |

**Fórmula / pseudocódigo:**
```
Jerarquía de 7 niveles con límites hardcoded:
  Comité    (COM): OCCURS 10 TIMES  ← HARDCODE
  Área      (AREA): OCCURS 50 TIMES ← HARDCODE
  División  (DIV): OCCURS 100 TIMES ← HARDCODE
  Dirección (DIR): OCCURS 500 TIMES ← HARDCODE
  Regional  (REG): OCCURS 1000 TIMES ← HARDCODE
  Operación (OPE): OCCURS 1500 TIMES ← HARDCODE
  Sucursal  (SUC): OCCURS 2000 TIMES ← HARDCODE

WKS-ESTRUCTURA OCCURS 2000 TIMES:
  WKS-EST-CSI   PIC 9(02)   ← CSI
  WKS-EST-COM   PIC 9(04)   ← Comité
  WKS-EST-AREA  PIC 9(04)   ← Área
  WKS-EST-DIV   PIC 9(04)   ← División
  WKS-EST-DIR   PIC 9(04)   ← Dirección
  WKS-EST-REG   PIC 9(04)   ← Regional
  WKS-EST-OPE   PIC 9(04)   ← Operación
  WKS-EST-SUC   PIC 9(04)   ← Sucursal
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| CSI | CAMPO-CLAVE | S151+S500 | Centro de Servicio Integrado (agrupador máximo) |
| COM | CAMPO-ORG | S151 | Comité — primer nivel bajo CSI |
| SUC | CAMPO-ORG | S151 | Sucursal — nivel operativo más granular |

**Excepciones documentadas:**
- Los límites de todos los niveles son HARDCODES en memoria — si la estructura de Banamex creció, podrían haber desbordamientos silenciosos.
- La estructura se carga desde ESTRUCTURA (S080BD01CON) — dataset externo que debe replicarse en el sistema objetivo.
- El límite de 2,000 sucursales define la granularidad máxima de reportes.

**Estado validación:** pendiente HITL

---

### RN-S151-547 — Control de versiones de librería vía CTRLVERS (DAME_TIT)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-547 |
| **Tipo** | [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control de versiones de software Unisys |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Gestión de Versiones de Librería |
| **Programa(s) fuente** | L030 — 01-00040-LEVANTA-L001, 01-00300-ESTABLECE-LIBRERIAS |
| **Frecuencia** | por-inicialización (función 0) |
| **Sistemas downstream** | L001CTL, S016L422, S080BD01CON (ESTRUCTURA) |

**Fórmula / pseudocódigo:**
```
01-00040-LEVANTA-L001:
  MOVE "S151L001CTL" TO WKS-LIBID
  CALL "DAME_TIT IN CTRLVERS" USING WKS-LIBID, WKS-NOMBLIB
                               GIVING W77-ERR-CTLVER
  IF W77-ERR-CTLVER = 0
    CHANGE ATTRIBUTE TITLE OF "LIB-CONTROL" TO WKS-NOMBLIB  ← nombre dinámico
  ELSE
    CHANGE ATTRIBUTE TITLE OF "LIB-CONTROL" TO
           "(S151)S151/OBJECT/L001/CONTROL ON CMEMP"         ← nombre por defecto

01-00300-ESTABLECE-LIBRERIAS:
  Similar para: S080BD01CON → ESTRUCTURA
                S016L422    → S016L422

Función 53: actualiza título de S016L422 en runtime
Función 55: CANCEL "S016L422" (descarga librería de memoria)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| CTRLVERS | LIBRERÍA | Unisys | Controlador de versiones Unisys ClearPath |
| DAME_TIT | FUNCIÓN | CTRLVERS | Obtiene el título (nombre físico) de una librería |
| CHANGE ATTRIBUTE TITLE | INSTRUCCIÓN | Unisys | Cambia dinámicamente el nombre de una librería vinculada |
| WKS-LIBID | CAMPO-NOMBRE | L030 | ID lógico de la librería a resolver (12 chars) |

**Excepciones documentadas:**
- CHANGE ATTRIBUTE TITLE es una instrucción exclusiva de Unisys ClearPath — no tiene equivalente directo en ninguna plataforma estándar.
- Si CTRLVERS no está disponible → se usa el nombre hardcoded por defecto.
- Este mecanismo permite tener múltiples versiones de una librería y seleccionar la correcta en runtime.

**Estado validación:** pendiente HITL

---

### RN-S151-548 — Validación de consistencia CSI primario vs. CSI secundario (RESCSI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-548 |
| **Tipo** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Regulador** | N/A — Control de integridad multi-CSI |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Control de Consistencia CSI |
| **Programa(s) fuente** | L030 — 01-00200-INICIA-DATOS (líneas 10622-10629) |
| **Frecuencia** | por-inicialización |
| **Sistemas downstream** | todos los procesos multi-CSI de S151 |

**Fórmula / pseudocódigo:**
```
01-00200-INICIA-DATOS (tras cargar CONSISDIA):
  MOVE WKS-B03-RESCSI TO WKS-R01-RESCSI      ← CSI de respaldo desde SISMEN

  IF (WKS-R01-CSI = WKS-R01-RESCSI AND        ← CSI primario = CSI de respaldo
      WKS-R01-RESCSI = WKS-R02-CSI)           ← Y CSI de respaldo = CSI del host
  OR WKS-R01-RESCSI = ZERO                    ← O no hay CSI de respaldo configurado
    NEXT SENTENCE                             ← configuración válida
  ELSE
    MOVE 23 TO W77-ERR                        ← ERROR: inconsistencia de CSI

WKS-R01-CSI  = CSI primario (de CONSISDIA)
WKS-R02-CSI  = CSI del host (detectado via SOPORTECOMS)
WKS-B03-RESCSI = CSI de respaldo (de CONSISMEN)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| CSI | CAMPO-CLAVE | S151+S500 | Centro de Servicio Integrado (identificador de nodo) |
| RESCSI | CAMPO-CONTROL | S151 | CSI de respaldo configurado en SISMEN |
| W77-ERR = 23 | CÓDIGO-ERROR | L030 | Error de inconsistencia de CSI — impide inicialización |

**Excepciones documentadas:**
- Si RESCSI = 0, la validación se omite (single-CSI setup).
- En un entorno multi-CSI, los tres valores deben ser iguales para que la inicialización proceda.
- Error 23 es fatal — el sistema no inicializa si hay inconsistencia de CSI.

**Estado validación:** pendiente HITL

---

### RN-S151-549 — Flag de enrutamiento de transacciones a Citi (ENVCITI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-549 |
| **Tipo** | [REGLA-DISTRIBUIDA] |
| **Confianza** | media |
| **Regulador** | N/A — Separación operativa Banamex / Citibank |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Enrutamiento de Transacciones |
| **Programa(s) fuente** | L030 — 01-00811-MUEVE-CLAVES (WKS-CVE-ENVCITI), 11-00310-MUEVE-SALP11 |
| **Frecuencia** | por-transacción |
| **Sistemas downstream** | Sistema Citi (integración con Citibank) |

**Fórmula / pseudocódigo:**
```
En la carga del catálogo CVETRAN (01-00811-MUEVE-CLAVES):
  MOVE WKS-SL710-DAT(W77-IND-S080,17) TO WKS-CVE-ENVCITI(W77-IND)

Uso durante consulta de movimientos (referencia en 11-00300-SALIDA-P11SAL y peers):
  IF WKS-CVE-ENVCITI(WKS-D01-CVETRA) = 1
    → [lógica de envío tipo 1 a Citi]
  IF WKS-CVE-ENVCITI(WKS-D01-CVETRA) = 2
    → [lógica de envío tipo 2 a Citi]
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| WKS-CVE-ENVCITI | FLAG | S151+S500 | Flag de envío a Citi por tipo de transacción: 0=no, 1=tipo1, 2=tipo2 |
| WKS-D01-CVETRA | CAMPO-CLAVE | S151 | Clave de transacción del movimiento actual |

**Excepciones documentadas:**
- Confianza media porque el código referencia el campo pero la lógica completa de envío a Citi está en otra librería (no visible en L030).
- Este campo es relevante para la separación operativa Banamex/Citi en el contexto de la escisión regulatoria — debe ser validado con el equipo de integración.

**Estado validación:** escalado-Legal

---

### RN-S151-550 — Contadores de secuencia histórica: SECOKHI, SECINFHI, SECERRHI

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-550 |
| **Tipo** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Regulador** | N/A — Control de integridad histórica |
| **Capacidad bancaria** | 7.1.1 Finance (GL) — Auditoría de Procesamiento Histórico |
| **Programa(s) fuente** | L030 — WKS-S151B03SISMEN (campos SECOKHI, SECINFHI, SECERRHI + funciones 11, 12, 13) |
| **Frecuencia** | cierre-mensual |
| **Sistemas downstream** | reportes de auditoría, control de calidad de procesamiento histórico |

**Fórmula / pseudocódigo:**
```
En WKS-S151B03SISMEN:
  WKS-B03-SECOKHI   PIC 9(10) ← contador de registros OK en base histórica
  WKS-B03-SECINFHI  PIC 9(10) ← contador de registros informativos en base histórica
  WKS-B03-SECERRHI  PIC 9(10) ← contador de registros con error en base histórica

Por ciclo mensual (WKS-B03-CICLO OCCURS 99 TIMES):
  WKS-B03-SECOK   PIC 9(10) ← OK del ciclo mensual específico
  WKS-B03-SECINF  PIC 9(10) ← informativos del ciclo mensual específico
  WKS-B03-SECERR  PIC 9(10) ← errores del ciclo mensual específico

Funciones CONSISMEN que actualizan estos contadores:
  F11 (SECOKHI)   → registra número de secuencia del último exitoso en histórico
  F12 (SECINFHI)  → registra número de secuencia del último informativo en histórico
  F13 (SECERRHI)  → registra número de secuencia del último error en histórico
  F19 (SECOK/ciclo), F20 (SECINF/ciclo), F21 (SECERR/ciclo)
```

**Vocabulario en la fórmula:**
| Término | Categoría | Alcance | Significado |
|---------|-----------|---------|-------------|
| SECOKHI | CAMPO-CONTADOR | S151 | Secuencia acumulada de registros exitosos en base histórica |
| SECINFHI | CAMPO-CONTADOR | S151 | Secuencia acumulada de registros informativos en base histórica |
| SECERRHI | CAMPO-CONTADOR | S151 | Secuencia acumulada de registros con error en base histórica |
| NOMBDMOVHI | CAMPO-NOMBRE | S151 | Nombre del dataset DMSII de movimientos históricos |

**Excepciones documentadas:**
- Los contadores son de 10 dígitos (PIC 9(10)) — máximo ~9.999 millones de registros por tipo.
- La distinción OK/INF/ERR implica que el sistema clasifica los registros históricos en tres categorías — la semántica exacta de "informativo" vs. "error" requiere validación HITL.
- Estos contadores son críticos para verificar integridad del proceso histórico durante la migración.

**Estado validación:** pendiente HITL

---

## Nota crítica de reimplementación

`S151LIB030` **no puede transpilarse** con herramientas COBOL estándar por las siguientes razones:

1. **CHANGE ATTRIBUTE TITLE / LIBACCESS / FUNCTIONNAME** — instrucciones exclusivas Unisys ClearPath para gestión dinámica de librerías. Sin equivalente en ninguna plataforma estándar.
2. **OPEN/CLOSE INQUIRY ... ON EXCEPTION** — patrón DMSII de Unisys para bases de datos de solo lectura. Debe reimplementarse como conexión de solo lectura al motor de BD del target.
3. **CANCEL "libreria"** — descarga de librería de memoria en Unisys. Equivalente aproximado en JVM: classloader manipulation; en .NET: AppDomain.Unload (obsoleto en .NET 5+).
4. **CALL "función IN librería"** — binding dinámico Unisys. Debe reimplementarse como llamadas a servicios con contratos explícitos (OpenAPI/gRPC).
5. **GO TO ... DEPENDING ON** — tabla de dispatch con hasta 92 entradas. Reimplementar como switch/strategy pattern.
6. **BASESEMANAL** — nombre dinámico de base de datos cambia cada día. Reimplementar como configuración externalizada (tabla de routing, no hardcode).

**Estimado de esfuerzo de reimplementación:** L030 debe convertirse en 4-6 microservicios del dominio GL:
- `sistema-fechas-service` (lógica de conversión de fechas Cronos 2000)
- `catalogo-transacciones-service` (CVETRAN + leyendas)
- `control-batch-service` (CONSISDIA + CONSISMEN + apertura/cierre de bases)
- `consulta-movimientos-service` (funciones 11, 12, 16, 17, 18, 19, 21, 24)
- `estructura-organizacional-service` (jerarquía CSI → Sucursal)
- `cliente-enrichment-service` (integración S016L422 → S500)

---

*Generado: 2026-07-16 · Business Rules Champion · Wave 3 — Librería Maestra L030 · Rango RN-S151-526 a RN-S151-550 · 25 reglas extraídas de 19,253 LOC (COBOL_L030.txt)*
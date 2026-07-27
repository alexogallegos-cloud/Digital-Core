# Catálogo de Reglas de Negocio — Sistema S151 (GL / Movimientos Contables)

> **Sistema:** S151 — Movimientos Contables · General Ledger · Unisys ClearPath MCP · Banamex
> **Extractor:** `Specialist - Business Rules` + swarm de agentes (Digital Core)
> **Estado:** en construcción — extracción activa (swarm 11 agentes)
> **Última actualización:** 2026-07-16

---

## Resumen ejecutivo

| Métrica | Valor |
|---------|-------|
| Programas analizados | 1 / ~104 (P109 completo; otros en progreso) |
| Reglas extraídas | 40 (P109: 40) |
| Reglas validadas SME | 0 (pendiente HITL) |
| Reglas con `[REQUIERE-LEGAL]` | 0 identificadas hasta ahora |
| Cobertura estimada | ~2% (incrementando) |

---

## Programas cubiertos (swarm activo 2026-07-16)

| Programa | LOC | Dominio | Estado | Reglas |
|----------|-----|---------|--------|--------|
| **P109** | ~19,381 | GL posting engine | ✅ Completo | 40 (RN-021..060) |
| **P330** | 2,506 | Extracción saldos GL (BC-09) | ✅ Completo | 13 (RN-720..732) |
| P112 | ~3,326 | PUNTEO / reconciliación | 🔄 En progreso | — |
| P130 | ~13,360 | AGRUPADOR CONTABLE CFR | 🔄 En progreso | — |
| P131 | ~11,833 | TRADUCTOR CONTABLE CFR | 🔄 En progreso | — |
| P108 | ~14,572 | GL Bitácora / Ledger | 🔄 En progreso | — |
| P150 | ~12,746 | Reportes ALR/AHR/OCM CITI | 🔄 En progreso | — |
| P021 | TBD | Cierre diario (3×/día) | 🔄 En progreso | — |
| P103 | TBD | Control fecha/período | 🔄 En progreso | — |
| P120 | TBD | Proceso Concentrador | 🔄 En progreso | — |
| P010 | ~18,943 | Gateway online MOVIMIENTOS | 🔄 En progreso | — |
| P050 | ~15,722 | Intereses/comisiones | 🔄 En progreso | — |
| P052 | ~13,708 | Intereses/comisiones (compl.) | 🔄 En progreso | — |
| P151 | ~17,370 | GL consolidación | 🔄 En progreso | — |
| P158 | ~13,694 | Movimientos por contrato | 🔄 En progreso | — |
| P178 | TBD | Verificación de saldos | 🔄 En progreso | — |
| P138 | TBD | Posición global | 🔄 En progreso | — |
| P140 | TBD | Riesgos y excepciones | 🔄 En progreso | — |
| DASDL ×6 | — | Schemas de BD | 🔄 En progreso | — |
| P199 | TBD | Saldos S500↔S151 bridge | 🔄 En progreso | — |
| P610 | TBD | Reporte regulatorio | 🔄 En progreso | — |
| P612 | TBD | Reporte regulatorio | 🔄 En progreso | — |
| P677 | TBD | Reporte regulatorio | 🔄 En progreso | — |

---

## Secuencia batch (WFL_LOTE.txt — orden de ejecución)

P710 → P005 → **P021** → P102 → P104 → **P103** → P107 → **P108** → **P109** → **P112** → P111 → P113-P117 → **P120** → P122 → P123 → **P178** → **P130** → **P131** → P134 → P135 → **P138** → **P140** → **P150** → **P151** → P152-P153 → P169-P172 → P312/P330/P360 → **P158** → P167/P177 → P194-P197 → P118-P119 → P000 → P001 → P680/P602/P606/**P610**/**P612**/**P677**/P690/P620/P670/P671 → **P199** → P650/P630/P655

*(Negrita = cubierto por swarm)*

---

## Reglas extraídas

---

## Programa P109 — GL POSTING ENGINE (CONTABILIDAD)

> **LOC:** ~19,381 · **Tipo:** batch (update) · **Dominio:** contabilidad / GL
> **Rol en batch:** Motor de asientos GL — procesa movimientos post-punteo, genera partidas dobles, acumula posición y produce reportes de cuadre contable

---

### RN-S151-021 — Validación de cabecera LOG151

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-021 |
| **Nombre** | Validación de cabecera LOG151 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — control de integridad |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de procesar cualquier movimiento, P109 valida que el archivo LOG151 tenga una cabecera válida: `A00-R00-HDR-HD = "HD"` Y `WKS-FECHA-PROCESO = A00-R00-HDR-FCH`. Si alguna condición falla, el proceso se aborta. Garantiza que el motor GL solo procese archivos generados en la fecha del ciclo correcto.

**Trigger:** Apertura de LOG151 INPUT

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R00-HDR-HD` | ALPHA 2 | Literal de cabecera — debe ser "HD" |
| `WKS-FECHA-PROCESO` | fecha | Fecha del ciclo de proceso |
| `A00-R00-HDR-FCH` | fecha | Fecha registrada en cabecera del archivo |

**Traza de código:**
```
PROGRAMA: P109
SECCIÓN/PÁRRAFO: 20000-PROCESA-MOVIMIENTOS
Líneas aproximadas: ~10050
Lógica clave: IF A00-R00-HDR-HD ≠ "HD" OR WKS-FECHA-PROCESO ≠ A00-R00-HDR-FCH → ABORT
```

**Riesgos de migración:**
- Si el nuevo sistema cambia el formato de cabecera de LOG151, P109 aborta — migrar con cuidado la estructura de header
- Si la fecha del archivo no coincide con la fecha de proceso, el batch entero falla

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R00-HDR-HD` | A00-R00-HDR-HD | CAMPO-ALFA | inc-p052 | Encabezado (header) del registro R00 en la interfaz de entrada; identifica el tipo de mensaje o cabecera de 2 caracteres. |
| `WKS-FECHA-PROCESO` | WKS-FECHA-PROCESO | CAMPO-NUM | inc-p052 | Fecha del proceso batch del GL (formato AAAAMMDD, 8 dígitos); fecha de ejecución del proceso nocturno de movimientos contables de S151. |
| `A00-R00-HDR-FCH` | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-022 — Centinela de fin de archivo FUNCION=99

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-022 |
| **Nombre** | Centinela de fin de archivo FUNCION=99 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El fin del archivo LOG151 no usa el mecanismo AT END estándar de COBOL, sino un registro centinela lógico: cuando `A00-R01-FUNCION = 99`, P109 activa `W77-EOF = 1`. Permite que LOG151 tenga registros de control intercalados sin ambigüedad. Los registros FUNCION=99 nunca se procesan como asientos.

**Trigger:** Lectura de cada registro de LOG151

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-FUNCION` | PIC 9(2) | Tipo de registro — 99 = fin lógico |
| `W77-EOF` | flag | Control de fin de loop principal |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 20000-PROCESA-MOVIMIENTOS · Líneas: ~10100
IF A00-R01-FUNCION = 99 → MOVE 1 TO W77-EOF
```

**Riesgos de migración:**
- El archivo de interface LOG151 debe mantener el registro centinela FUNCION=99 o la interfaz debe ser rediseñada

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-FUNCION` | A00-R01-FUNCION | CAMPO-COMP | inc-p052 | Código de función u operación solicitada al sistema S151 a través de la interfaz R01 (alta, cancelación, reversa, consulta, etc.). |
| `W77-EOF` | — | — | — | no encontrado en vocab-s151.md |

**Nota:** ETL-A00-R01-FUNCION (inc-p109, CAMPO-NUM) es la variante ETL del mismo campo con el mismo rol semántico.

**Estado validación:** pendiente HITL

---

### RN-S151-023 — Filtro de selección de movimientos (FUNCION/STATUS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-023 |
| **Nombre** | Filtro de selección de movimientos (FUNCION/STATUS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 aplica un filtro de dos dimensiones para determinar qué movimientos generan asientos GL. Solo FUNCION=1 (movimiento contabilizable) Y STATUS=1 (autorizado) o STATUS=2 (en proceso) generan asientos. STATUS=1 además dispara `GRABA-PUNTEO` (retroalimentación al sistema origen); STATUS=2 produce el asiento sin punteo. Otros registros se cuentan como ELIMINADOS.

**Trigger:** Lectura de cada registro LOG151 con FUNCION ≠ 99

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-FUNCION` | PIC 9(2) | 1=contabilizable, 2=reversa/eliminado |
| `A00-R01-STATUS` | PIC 9(1) | 1=autorizado, 2=en proceso |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21000-ESCOGE-MOVS · Líneas: ~10411
IF A00-R01-FUNCION = 1 AND A00-R01-STATUS = 1 OR 2 → PERFORM 21100-GRABA-ARCHIVOS
STATUS=1 → además PERFORM GRABA-PUNTEO
```

**Riesgos de migración:**
- La semántica FUNCION + STATUS es el gate de contabilización — cualquier cambio en cómo el sistema origen llena estos campos rompe el filtro

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-FUNCION` | A00-R01-FUNCION | CAMPO-COMP | inc-p052 | Código de función u operación solicitada al sistema S151 a través de la interfaz R01. |
| `A00-R01-STATUS` | A00-R01-STATUS | CAMPO-COMP | inc-p052 | Estatus del procesamiento del registro en la interfaz R01; código numérico que refleja el resultado de la operación en S151. |
| `GRABA-PUNTEO` (párrafo) | — | — | — | no encontrado en vocab-s151.md (párrafo de código, no campo de datos) |

**Estado validación:** pendiente HITL

---

### RN-S151-024 — Hasta 5 CVETRANs (claves de transacción) por movimiento

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-024 |
| **Nombre** | Hasta 5 CVETRANs (claves de transacción) por movimiento |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Cada registro de LOG151 puede contener hasta 5 pares CVETRAN/IMPORTE/ESQCON independientes (CVETRAN1..5). P109 genera un registro MOVIMIENTOS separado por cada CVETRAN mayor que cero. Permite que un movimiento comercial (pago con comisión e impuesto) genere múltiples líneas GL con distintos esquemas contables sin duplicar la cabecera.

**Trigger:** Registro LOG151 aprobado por filtro RN-S151-023

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-CVETRAN1..5` | PIC 9(n) | Claves de transacción 1 a 5 |
| `A00-R01-IMPORTE1..5` | PIC 9(14)V99 | Importes correspondientes |
| `A00-R01-ESQCON1..5` | PIC 9(n) | Esquemas contables correspondientes |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21100-GRABA-ARCHIVOS · Líneas: ~10580
FOR n=1 TO 5: IF A00-R01-CVETRANn > 0 → WRITE REG-MOVIMIENTOS con CVETRANn/IMPORTEn/ESQCONn
```

**Riesgos de migración:**
- El nuevo sistema debe manejar multiplicidad 1:N movimiento→asientos GL; no asumir 1:1

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-CVETRAN1` | A00-R01-CVETRAN1 | CAMPO-COMP | inc-p052 | Primera clave de transacción que identifica el tipo de operación dentro del sistema de movimientos contables. |
| `A00-R01-CVETRAN2` | A00-R01-CVETRAN2 | CAMPO-COMP | inc-p052 | Clave del segundo tipo de transacción contable dentro del registro R01; complementa la clasificación del movimiento GL. |
| `A00-R01-CVETRAN3` | A00-R01-CVETRAN3 | CAMPO-COMP | inc-p052 | Tercera clave de transacción del movimiento en el registro R01; identifica el tipo de operación contable. |
| `A00-R01-CVETRAN4` | A00-R01-CVETRAN4 | CAMPO-COMP | inc-p052 | Clave de la transacción de cuarto nivel que categoriza el movimiento contable dentro del catálogo de tipos de transacción. |
| `A00-R01-CVETRAN5` | A00-R01-CVETRAN5 | CAMPO-COMP | inc-p052 | Clave de transacción (campo 5) de 6 dígitos para el reporte Banxico R01; identifica el tipo de operación que origina el asiento contable. |
| `A00-R01-ESQCON1` | A00-R01-ESQCON1 | CAMPO-COMP | inc-p052 | Esquema contable 1 del registro R01; determina el esquema de contabilización aplicado al asiento GL. |
| `A00-R01-ESQCON2` | A00-R01-ESQCON2 | CAMPO-COMP | inc-p052 | Código del esquema contable secundario (4 dígitos) aplicado al movimiento en la interfaz R01. |
| `A00-R01-ESQCON3` | A00-R01-ESQCON3 | CAMPO-COMP | inc-p052 | Esquema contable número 3 aplicado al movimiento; determina las reglas de distribución y clasificación del asiento. |
| `A00-R01-ESQCON4` | A00-R01-ESQCON4 | CAMPO-COMP | inc-p052 | Esquema de contabilización número 4 (4 dígitos) que determina las reglas de débito/crédito y las cuentas GL afectadas. |
| `A00-R01-ESQCON5` | A00-R01-ESQCON5 | CAMPO-COMP | inc-p052 | Código del quinto esquema contable aplicado al movimiento en la interfaz R01; determina la plantilla de cuentas GL a usar. |
| `A00-R01-IMPORTE1..5` | — | — | — | no encontrado en vocab-s151.md con sufijo numérico; los importes numerados no tienen entrada explícita |

**Estado validación:** pendiente HITL

---

### RN-S151-025 — Cadena de resolución ESQCON (CVETRAN → cuenta GL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-025 |
| **Nombre** | Cadena de resolución ESQCON (CVETRAN → cuenta GL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-CNBV-REPORTE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (mecánica en fuente + rationale SME regulatorio) |
| **Regulador** | CUB Criterios de Contabilidad (Anexo 33) + Catálogo Mínimo (Anexo 34/35) + Control interno Art. 144-148 |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:10982 (párrafo 21122-MUEVE-ESQUEMA); rechazo registrado "ESQUEMA NO EXISTE" en :10849 y :10977, "ERROR READ, ARCHIVO ESQCON" en :10908 |
| **Dataset DMSII** | Lee catálogos ARCH-CAT7 y ARCH-ESQCON (archivos indexados, no dataset DMSII de negocio); el asiento resuelto se escribe en registro RMC |

**Descripción:** La resolución cuenta GL desde CVETRAN sigue 4 pasos: (1) Lookup `WKS-PT-INDS250(CVETRAN)` → agrupación contable; (2) Si `WKS-TIPO-CAT=2`: ruta alternativa CAT7 directa; (3) Lectura ARCH-CAT7 → índice de esquema `W77-IND3`; (4) Lectura ARCH-ESQCON → `WKS-EQ-NAT-MOV`, `WKS-EQ-CUENTA`, `WKS-EQ-CAUSA`. Si paso 3 falla → W77-IND3=0 → se registra "ESQUEMA NO EXISTE" (con traza, no silencioso) y el movimiento queda fuera del asiento. Este es el corazón del motor GL.

**Condición:** Se procesa un CVETRAN de un movimiento contabilizable.

**Consecuencia:** Se resuelve la cuenta GL destino y la naturaleza del asiento vía la cadena INDS250→CAT7→ESQCON. Si el esquema no existe, se registra el rechazo y el movimiento no se contabiliza (la contrapartida sí, produciendo descuadre).

**Trigger:** WRITE REG-MOVIMIENTOS completado para un CVETRANn

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-PT-INDS250` | tabla memoria | Índice CVETRAN → agrupación contable |
| `WKS-PT-AGR-CONT` | PIC 9(n) | Código de agrupación contable |
| `ARCH-CAT7` | file | Catálogo 7 — agrupación → índice esquema |
| `ARCH-ESQCON` | file | Catálogo de esquemas contables |
| `W77-IND3` | PIC 9(n) | Índice de esquema (0 = error) |
| `WKS-EQ-NAT-MOV` | PIC 9(1) | 1=débito / 2=crédito |
| `WKS-EQ-CUENTA` | PIC 9(12) | Cuenta GL destino |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21120-GRABA-MOV-CONTABLE / 21122-MUEVE-ESQUEMA · Líneas: ~10807-10870
1. WKS-PT-AGR-CONT = WKS-PT-INDS250(RMC-CVETRAN)
2. IF WKS-TIPO-CAT = 2 → CAT7 directo
3. READ ARCH-CAT7 KEY (AGR-CONT, ESQ) → W77-IND3
4. READ ARCH-ESQCON KEY (W77-IND3, W77-IND4) → WKS-EQ-NAT-MOV, WKS-EQ-CUENTA
IF W77-IND3 = 0 → error "ESQUEMA NO EXISTE"
```

**Riesgos de migración:**
- El catálogo ESQCON + CAT7 + tabla INDS250 deben migrarse como servicio de resolución de cuentas
- Error "ESQUEMA NO EXISTE" implica movimiento no contabilizado → gap en GL

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-PT-INDS250` | WKS-PT-INDS250 | CAMPO-COMP | inc-p109 | Indicador del sistema S250 en la estructura de punto de proceso (2 dígitos COMP). Bandera que señala si el sistema S250 (cuentas de cheques) está involucrado en el movimiento. **Nota:** la regla lo usa como tabla indexada por CVETRAN; posible discrepancia semántica con vocab. |
| `WKS-PT-AGR-CONT` | WKS-PT-AGR-CONT | CAMPO-COMP | inc-p109 | Puntero al área de agrupador de contabilización. PIC 9(04) COMP. Índice de acceso al bloque de datos de contabilización agrupada en las tablas del proceso GL. |
| `ARCH-CAT7` (archivo) | WKS-SIS-CAT7 | CAMPO-NUM | inc-p109 | Código del sistema para la categoría 7 del plan de cuentas GL (3 dígitos); identifica el sistema que gestiona los movimientos de la categoría contable 7 (P109). |
| `ARCH-ESQCON` (archivo) | A00-R01-ESQCON | CAMPO-COMP | inc-p052 | Código del esquema de contabilización aplicado para generar el asiento contable en el GL de S151. |
| `W77-IND3` | WS-IND3 | CAMPO-NUM | inc-pro | Contador o índice auxiliar número 3 de 2 dígitos con valor inicial 0 en el programa P050. Variable de control para ciclos de iteración. |
| `W77-IND4` | — | — | — | no encontrado en vocab-s151.md |
| `WKS-EQ-NAT-MOV` | WSR-RCC-NAT-MOV | CAMPO-NUM | inc-p109 | Naturaleza del movimiento (1 dígito) para el reporte RCC. Indica si el movimiento es débito (cargo) o crédito (abono). |
| `WKS-EQ-CUENTA` | WKS-CTA-CONT-ACT | CAMPO-COMP | inc-p109 | Número de cuenta contable actual en COMP de 12 dígitos. Almacena la cuenta GL del período en proceso. (Más cercano encontrado) |

**Rationale (validado por SME Regulatorio CNBV):** La cadena INDS250→CAT7→ESQCON es el motor de mapeo transacción→cuenta que materializa la política de clasificación contable del banco hacia el plan de cuentas interno, que a su vez reconcilia contra el catálogo mínimo (Anexo 34/35). No es "el mapeo del Anexo 33" (Anexo 33 son criterios de reconocimiento/valuación, no una tabla de cuentas). Corrección de hecho sobre la extracción previa: el rechazo **no es silencioso** — hay traza ("ESQUEMA NO EXISTE", "ERROR READ ARCHIVO ESQCON"); el problema es que el movimiento queda fuera del asiento (medio asiento perdido), lo que descuadra el cierre diario y contamina la Serie R.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — evidencia COBOL_P109.txt:10982 |
| **Validado por SME** | SME Regulatorio Mainframe (CNBV), 2026-07 — [CRÍTICO] gap de asiento → descuadre Serie R; corrige "silencioso" y la atribución a Anexo 33 |
| **Equivalencia (requisito SME)** | Resolución de cuenta **100% determinística** legacy vs nuevo (no 99.99%; ese umbral aplica al importe agregado). Migrar CAT7/ESQCON/INDS250 como snapshot con histórico de versiones. Reconciliar el conteo de rechazos "ESQUEMA NO EXISTE": el nuevo debe reportar exactamente los mismos |

---

### RN-S151-026 — Partida doble: NAT-MOV=1 (débito) / NAT-MOV=2 (crédito)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-026 |
| **Nombre** | Partida doble: NAT-MOV=1 (débito) / NAT-MOV=2 (crédito) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (mecánica en fuente + rationale SME regulatorio) |
| **Regulador** | NIF A-1 dualidad económica (supletorio) + CUB Catálogo Mínimo Anexo 34 |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:10915-10917 (párrafo 21121-MUEVE-CUENTAS-CONTABLES; `IF WKS-EQ-NAT-MOV = 1 OR 2` en :10915) |
| **Dataset DMSII** | Análisis interno: registro RMC → archivo MOVCONTABLES (verificar dataset DMSII destino BD10MOVDIA151) |

**Descripción:** P109 implementa la partida doble mediante `WKS-EQ-NAT-MOV` del ESQCON. Solo los valores 1 (débito) y 2 (crédito) generan asiento. Cualquier otro valor descarta el asiento silenciosamente. El par débito/crédito garantiza el cuadre contable; el balance se verifica en sección 40000.

**Condición:** El esquema contable (ESQCON) resuelto entrega una naturaleza de movimiento `WKS-EQ-NAT-MOV`.

**Consecuencia:** Si la naturaleza es 1 (débito) o 2 (crédito), se puebla el registro contable (RMC-TIPO-MOV, RMC-NAT-MOV, RMC-CTA-CONT, RMC-CAUSA) y se genera el asiento. Cualquier otro valor descarta el asiento sin escribir y sin dejar traza.

**Excepciones:** El descarte por naturaleza inválida es silencioso (no hay log ni contador de rechazo), lo que hace invisible un asiento faltante hasta el cuadre de sección 40000.

**Trigger:** Resultado de lookup ESQCON con W77-IND3 > 0

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-EQ-NAT-MOV` | PIC 9(1) | 1=débito, 2=crédito, otro=inválido |
| `RMC-NAT-MOV` | PIC 9(1) | Naturaleza del asiento en MOVCONTABLES |
| `RMC-CTA-CONT` | PIC 9(12) | Cuenta GL del asiento |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21121-MUEVE-CUENTAS-CONTABLES · Líneas: ~10895
IF WKS-EQ-NAT-MOV = 1 OR 2 → poblat RMC-TIPO-MOV, RMC-NAT-MOV, RMC-CTA-CONT, RMC-CAUSA
ELSE → descarte silencioso (no WRITE)
```

**Riesgos de migración:**
- Entradas de ESQCON con NAT-MOV ≠ 1/2 producen asientos faltantes — invisible hasta el cuadre
- Deben existir validaciones de calidad del catálogo ESQCON antes de migración

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-EQ-NAT-MOV` / `RMC-NAT-MOV` | WSR-RCC-NAT-MOV | CAMPO-NUM | inc-p109 | Naturaleza del movimiento (1 dígito) para el reporte RCC. Indica si el movimiento es débito (cargo) o crédito (abono) en el listado de cargos y créditos. |
| `RMC-CTA-CONT` | WSR-RMC-CTA-CONT | CAMPO-EDICION | inc-pro | Número de cuenta contable del Registro de Movimientos Contables (RMC) formateado para edición/impresión. Edición Z(12), 12 dígitos con supresión de ceros. |

**Rationale (validado por SME Regulatorio CNBV):** El filtro NAT-MOV=1/2 materializa el postulado de dualidad económica (partida doble), exigible a bancos por supletoriedad del Anexo 33 de la CUB. El punto regulatoriamente peligroso no es que 1 y 2 generen asiento, sino que cualquier otro valor cae por el ELSE implícito **sin WRITE y sin log** (a diferencia de RN-S151-025, que sí registra el rechazo): un renglón ESQCON con NAT-MOV=3 descarta una pierna del asiento y deja la contrapartida huérfana, produciendo descuadre que se propaga al catálogo mínimo y a la Serie R. La decisión de convertir el descarte silencioso en excepción es del cliente y auditoría, no del transpiler.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — evidencia COBOL_P109.txt:10915-10917 |
| **Validado por SME** | SME Regulatorio Mainframe (CNBV), 2026-07 — dualidad económica confirmada; descarte silencioso NAT-MOV≠1/2 es el riesgo real |
| **Equivalencia (requisito SME)** | Sembrar dataset con NAT-MOV inválido (3-9) y confirmar descarte idéntico legacy vs nuevo (mismo conteo de registros no escritos). Inventariar catálogo ESQCON con NAT-MOV∉{1,2} como remediación pre-cutover |

---

### RN-S151-027 — Cuenta contable por defecto cuando CTA1-CONT=0

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-027 |
| **Nombre** | Cuenta contable por defecto cuando CTA1-CONT=0 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (lectura AS-IS; SME Contabilidad CNBV) — [ANTIPATRÓN] de control interno, no migrar literal |
| **Regulador** | Integridad del catálogo mínimo (Anexo 34/35) + clasificación sectorial Serie R + control interno Art. 144-148 |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:10920-10925 (párrafo 21121-MUEVE-CUENTAS-CONTABLES; `MOVE 5 TO RMC-CTA1-CONT` en :10921) |
| **Dataset DMSII** | Análisis interno: registro RMC → MOVCONTABLES |

**Descripción:** Cuando el ESQCON entrega `RMC-CTA1-CONT = 0`, P109 aplica un fallback hardcoded: `MOVE 5 TO RMC-CTA1-CONT`. Además —y esto la extracción previa lo omitía— el mismo bloque ejecuta `MOVE 0 TO RMC-BANCA, RMC-SECTOR, RMC-ACTIVIDAD` (:10922-10925): el fallback no solo redirige la cuenta, también **borra los atributos de sectorización regulatoria** del movimiento. Dirige el asiento a cuentas de control (grupo 5) hasta que el catálogo ESQCON se corrija.

**Condición:** El ESQCON no resuelve el primer dígito de la cuenta (`RMC-CTA1-CONT = 0`).

**Consecuencia:** El primer dígito de la cuenta se fuerza a 5 (grupo de control) y se ceroan las dimensiones BANCA, SECTOR y ACTIVIDAD del asiento, que por tanto pierde su clasificación sectorial en la Serie R.

**Trigger:** Resultado de lookup ESQCON con RMC-CTA1-CONT = 0

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `RMC-CTA1-CONT` | PIC 9 COMP | Dígito 1 de cuenta GL (0 = no resuelto) |
| `RMC-BANCA` / `RMC-SECTOR` / `RMC-ACTIVIDAD` | PIC 9 COMP | Dimensiones de sectorización regulatoria (ceradas en el fallback) |

**Traza de código:**
```
21121-MUEVE-CUENTAS-CONTABLES (COBOL_P109.txt:10919-10925)
MOVE WKS-EQ-CUENTA TO RMC-CTA-CONT              (:10919)
IF RMC-CTA1-CONT = 0                             (:10920)
   MOVE 5 TO RMC-CTA1-CONT                       (:10921)
   MOVE 0 TO RMC-BANCA, RMC-SECTOR, RMC-ACTIVIDAD (:10922-10925)
```

**Riesgos de migración:**
- El prefijo/grupo 5 debe validarse contra el catálogo destino — [DATO-REQUERIDO] su naturaleza exacta
- Pérdida de BANCA/SECTOR/ACTIVIDAD debe replicarse o corregirse conscientemente (cambia la Serie R)
- [HARDCODE-SOSPECHOSO]: el catálogo ESQCON debe corregirse para no producir CTA=0

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `RMC-CTA1-CONT` | — | — | — | no encontrado en vocab-s151.md |
| — (más cercano) | WKS-CTA-CONT-ACT | CAMPO-COMP | inc-p109 | Número de cuenta contable actual en COMP de 12 dígitos; almacena la cuenta GL del período en proceso. |

**Rationale (validado por SME Regulatorio CNBV):** Es la regla más delicada del batch. Dirigir movimientos no resueltos a una cuenta de control es un paliativo operativo que CNBV vería como deficiencia de control interno (Art. 144-148) si el saldo acumulado es material o persistente. El borrado de BANCA/SECTOR/ACTIVIDAD degrada la clasificación sectorial de la Serie R (p.ej. R04 cartera por sector). No hay norma que autorice el prefijo 5.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — evidencia COBOL_P109.txt:10920-10925 |
| **Validado por SME** | SME Regulatorio Mainframe (CNBV), 2026-07 — [CRÍTICO]; confirma y amplía (borra sectorización); sube el hallazgo del `MOVE 0` a SECTOR/BANCA/ACTIVIDAD |
| **Validado por SME Contable** | SME Contabilidad Bancaria CNBV, 2026-07 — grupo 5 = **resultados deudores (gasto/P&L)**, naturaleza deudora, NO cuenta de control de balance. El fallback carga gasto contra el resultado del período (mal-clasificación Anexo 33 Serie D) y el cereo de sectorización degrada R04. Diseño correcto sería una transitoria vigilada de "partidas por identificar" conservando dimensiones, no gasto |
| **DATO-REQUERIDO neto (catálogo Banamex)** | Cuenta 5 puntual a la que aterriza el fallback y materialidad del saldo histórico volcado ahí (¿hallazgo de auditoría o marginal?) |
| **Equivalencia + migración (requisito SME)** | [ANTIPATRÓN] no transpilar el hardcode; externalizar a cuenta transitoria parametrizada conservando BANCA/SECTOR/ACTIVIDAD (ADR contable). Tolerancia cero determinística: cada asiento que caiga en el fallback es trigger de divergencia visible; contar y reportar los hits en parallel-run (si el AS-IS los ocultaba en gasto, el TO-BE debe exponerlos) |

---

### RN-S151-028 — Exclusión de cuenta 1503 del cuadre contable

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-028 |
| **Nombre** | Exclusión de cuenta 1503 del cuadre contable |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (lectura AS-IS; SME Contabilidad CNBV) — exclusión legítima solo condicionada, ver validación |
| **Regulador** | Vigilancia de cuentas puente/transitorias (CUB Criterios Anexo 33) + control interno Art. 144-148 |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:14693-14703 (párrafo 40005-VALIDA-CTA-1503); literales de cuenta también en :14610, :15208, :15364, :15392 |
| **Dataset DMSII** | Análisis interno: reporte de cuadre, sección 40000-GENERA-CUADRE-CONTABLE |

**Descripción:** Durante la generación del cuadre (sección 40000), cuando la cuenta contable es 1503, P109 zerifica los importes acumulados y marca el registro como nulo (`W77-PAQ-VACIO=1`). Corrección de alcance (SME): no zerifica dos acumuladores sino **seis** — `WKS-TCP-CARGOS`, `WKS-TCP-ABONOS`, `WKS-TRA-CARGOS`, `WKS-TRA-ABONOS`, `WKS-AUT-CARGOS`, `WKS-AUT-ABONOS` — es decir, exclusión transversal a las cuatro dimensiones del cuadre (transitorio y autorizado), con lógica relacionada sobre las subcuentas 150399 y 150359. La 1503 es cuenta puente/compensatoria que no debe aparecer en el cuadre final.

**Condición:** El registro de cuadre pertenece a la cuenta 1503 (o subcuentas 150399000000 / 150359000000).

**Consecuencia:** Se ceroan los seis acumuladores de cargos y abonos (simple, transitorio y autorizado) y el paquete se marca vacío, excluyendo la cuenta del cuadre.

**Trigger:** Lectura de registro MOVCONTABLES con cuenta = 1503 durante sección 40000

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WS-CTA4-250-ANT` | PIC 9(4) | Cuenta GL (4 dígitos iniciales) |
| `WKS-TCP-CARGOS` / `WKS-TCP-ABONOS` | PIC S9(16)V99 COMP | Acumulado cargos/abonos simple |
| `WKS-TRA-CARGOS` / `WKS-TRA-ABONOS` | PIC S9(16)V99 COMP | Acumulado transitorio |
| `WKS-AUT-CARGOS` / `WKS-AUT-ABONOS` | PIC S9(16)V99 COMP | Acumulado autorizado |
| `W77-PAQ-VACIO` | flag | Marca de paquete vacío |

**Traza de código:**
```
40005-VALIDA-CTA-1503 (COBOL_P109.txt:14693-14703)
IF WS-CTA4-250-ANT = 1503
   MOVE 0 TO WKS-TCP-CARGOS, WKS-TCP-ABONOS,
             WKS-TRA-CARGOS, WKS-TRA-ABONOS,
             WKS-AUT-CARGOS, WKS-AUT-ABONOS
   MOVE 1 TO W77-PAQ-VACIO
```

**Riesgos de migración:**
- Literales de cuenta (1503, 150399000000, 150359000000) hardcodeados en 6+ párrafos (:14610, :14696, :15208, :15325, :15364, :15392) — alto riesgo de migración incompleta si no se centralizan
- Si 1503 se remapea en el nuevo plan, los literales quedan apuntando a la cuenta equivocada
- Riesgo inverso: CNBV quiere que las cuentas puente/transitorias se vigilen; excluirlas del cuadre oculta lo que el regulador quiere ver

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WS-CTA4-250-ANT` | — | — | — | no encontrado en vocab-s151.md |
| `WKS-TCP-CARGOS` | WKS-TCP-CARGOS | CAMPO-COMP | inc-p109 | Total de cargos por cuenta y período (COMP S9(16)V99). Suma firmada acumulada de cargos en el período de procesamiento contable del S151. |
| `WKS-TCP-ABONOS` | WKS-TCP-ABONOS | CAMPO-COMP | inc-p109 | Total de abonos por cuenta y período (COMP S9(16)V99). Suma firmada acumulada de abonos en el período de procesamiento contable del S151. |

**Rationale (validado por SME Regulatorio CNBV):** La exclusión puede ser legítima para el reporte operativo de cuadre del día, pero no debe traducirse en "esta cuenta no se concilia nunca": CNBV vigila saldos en tránsito prolongados como observación de auditoría. El riesgo regulatorio es inverso al esperado — excluir la cuenta oculta precisamente lo que el regulador quiere ver.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — evidencia COBOL_P109.txt:14693-14703 |
| **Validado por SME** | SME Regulatorio Mainframe (CNBV), 2026-07 — [CRÍTICO]; corrige alcance (6 acumuladores, no 2) y el sentido del riesgo (inverso) |
| **Validado por SME Contable** | SME Contabilidad Bancaria CNBV, 2026-07 — grupo 15 = **activo transitorio / operaciones en tránsito-liquidación**; 1503 = cuenta puente compensatoria; 150399/150359 = subcuentas de contrapartida. Excluir del cuadre del **paquete** es legítimo **solo si** la cuenta netea a cero **y** se concilia/depura por separado. El cereo de los 6 acumuladores puede ocultar un descuadre real → [ANTIPATRÓN] exclusión permanente de una transitoria de la conciliación (CUB Art. 144-148, vigilancia de saldos en tránsito) |
| **DATO-REQUERIDO neto (catálogo Banamex)** | Contenido exacto de 1503/150399/150359 en Anexo 34/35 aplicado + existencia hoy de un proceso de conciliación y depuración con antigüedad de saldos. Si no existe, el hallazgo de control interno ya está en el AS-IS |
| **Equivalencia + migración (requisito SME)** | Conservar la exclusión del cuadre **solo con** proceso explícito de conciliación/depuración de 1503 (ADR contable); nunca excluir de la conciliación contable. Verificar: (1) saldo neto de 1503 = 0 por paquete; si arrastra saldo ≠ 0 es descuadre oculto → hallazgo pre-cutover; (2) que ningún movimiento legítimo caiga en 1503 por error de esquema; (3) antigüedad de saldos histórica |

---

### RN-S151-029 — Mapeo hardcoded CSI=12 → CSI=10

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-029 |
| **Nombre** | Mapeo hardcoded CSI=12 → CSI=10 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — mapeo histórico de CSI |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Durante la inicialización, P109 aplica: `IF CSI = 12 → MOVE 10 TO W77-CSI-PROCESO`. El CSI (Centro de Servicio Informático) 12 se trata igual al CSI 10 para todos los efectos. Probablemente refleja una fusión/renumeración histórica de centros de proceso.

**Trigger:** Resultado de CALL CONSISDIA durante inicio

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-CSI-PROCESO` | PIC 9(2) | CSI efectivo usado como dimensión en llaves GL |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 10000-INICIO-PROGRAMA · Líneas: ~8012
IF CSI = 12 → MOVE 10 TO W77-CSI-PROCESO
```

**Riesgos de migración:**
- Si el nuevo sistema numera CSIs diferente, este mapeo puede quedar obsoleto o incorrecto

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-CSI-PROCESO` | — | — | — | no encontrado en vocab-s151.md con ese nombre exacto |
| CSI (concepto) | A00-BIT264-CSI-DEST | CAMPO-NUM | inc-p109 | Código de sistema integral destino CSI de la transacción en la bitácora formato 264 (2 dígitos). |
| CSI (concepto) | A00-BIT264-CSI-ORIG | CAMPO-NUM | inc-p109 | Código de sistema integral origen CSI de la transacción en la bitácora formato 264 (2 dígitos). |

**Estado validación:** pendiente HITL

---

### RN-S151-030 — Umbral de memoria/disco para tabla S016

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-030 |
| **Nombre** | Umbral de memoria/disco para tabla S016 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para sistemas S084 (tarjetas) y S087 (cheques), P109 carga la tabla de contratos S016 en memoria si el número de registros es < 4,500: `IF W77-NUMREG-LOG < 4500 → W77-ACCESO=1 (memoria)`. Si ≥ 4,500, fuerza acceso a disco. La tabla en memoria es `WKS-REG-MEM OCCURS 4500 TIMES`.

**Trigger:** Inicialización para S084/S087

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-NUMREG-LOG` | PIC 9(n) | Número de registros en LOG S016 |
| `W77-ACCESO` | PIC 9(1) | 1=memoria, 0=disco |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 20000-PROCESA-MOVIMIENTOS · Líneas: ~9980
IF W77-NUMREG-LOG < 4500 → MOVE 1 TO W77-ACCESO (memoria)
ELSE → MOVE 0 TO W77-ACCESO (disco)
```

**Riesgos de migración:**
- El umbral 4,500 puede ser insuficiente si el volumen de contratos crece — debe convertirse a configuración

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-NUMREG-LOG` | — | — | — | no encontrado en vocab-s151.md |
| `W77-ACCESO` | ACC | ACCION | dominio | Medio de acceso del cliente en transacciones GL — identifica el canal. Campos W77-ACCESO PIC 9(02) VALUE ZERO y WSR-MEDIO-ACCESO PIC X(03) en P109. |
| S016 (sistema) | COMISIONES2K ON CLIENTES | COPY | patron-unisys | COPY de parámetros del sistema externo S016; estructura de comisiones con soporte Y2K. Dependencia cross-sistema: S151 consume librería de S016. |
| S016 (sistema) | A00-R01-INST-S016 | CAMPO-COMP | inc-p052 | Número de institución financiera en el sistema S016 dentro del registro R01; identifica la entidad bancaria interviniente. |

**Estado validación:** pendiente HITL

---

### RN-S151-031 — Clave de acumulación MOVCONTASORT (11 dimensiones)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-031 |
| **Nombre** | Clave de acumulación MOVCONTASORT (11 dimensiones) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — modelo dimensional GL |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los asientos individuales se acumulan por clave compuesta de 11 dimensiones: FILIAL, ORIGEN, MONEDA, BANCO, SUC-PROM, FECVEN, PRODUCTO, INSTRUMENTO, SECTOR, CVETRAN, ESQCON. Mientras la clave no cambie: `ADD RMS-IMPORTE TO W77-IMP-SORT`. Al cambiar cualquier clave → write registro acumulado a MOVCONTABLES. Esta clave define la granularidad mínima del libro mayor GL.

**Trigger:** Lectura de SMOVCONTASORT (post-sort) en 20010-ACUMULA-IMPORTE

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `SMS-FILIAL..SMS-ESQCON` | varios | 11 dimensiones de la clave GL |
| `W77-IMP-SORT` | PIC 9(14)V99 | Acumulador de importe |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 20000+20010 · Líneas: ~10200
SORT SMOVCONTASORT ON ASCENDING SMS-FILIAL, SMS-ORIGEN, SMS-MONEDA, SMS-BANCO,
     SMS-SUC-PROM, SMS-FECVEN, SMS-PRODUCTO, SMS-INSTRUMENTO, SMS-SECTOR, SMS-CVETRAN, SMS-ESQCON
ADD RMS-IMPORTE TO W77-IMP-SORT mientras clave igual
WRITE MOVCONTABLES cuando cambia clave
```

**Riesgos de migración:**
- El modelo dimensional del nuevo GL debe soportar exactamente estas 11 dimensiones como granularidad mínima

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `SMS-FILIAL` | — | — | — | no encontrado en vocab-s151.md (campo de sort intermedio) |
| `SMS-ORIGEN` / `A00-R01-ORIGEN` | A00-R01-ORIGEN | CAMPO-COMP | inc-p052 | Código de 2 dígitos que identifica el sistema de origen del movimiento GL en el registro R01. |
| `SMS-MONEDA` | — | — | — | no encontrado en vocab-s151.md con ese prefijo |
| `SMS-BANCO` | — | — | — | no encontrado en vocab-s151.md con ese prefijo |
| `SMS-SUC-PROM` | — | — | — | no encontrado en vocab-s151.md con ese prefijo |
| `SMS-FECVEN` | — | — | — | no encontrado en vocab-s151.md con ese prefijo |
| `SMS-PRODUCTO` / `A00-R01-PRODUCTO-S016` | A00-R01-PRODUCTO-S016 | CAMPO-COMP | inc-p052 | Código del producto bancario S016 asociado al movimiento contable. |
| `SMS-INSTRUMENTO` / `A00-R01-INSTRUMENTO-S016` | A00-R01-INSTRUMENTO-S016 | CAMPO-COMP | inc-p052 | Clave del instrumento financiero (campo S016) que origina el movimiento contable R01. |
| `SMS-SECTOR` | — | — | — | no encontrado en vocab-s151.md con ese prefijo |
| `SMS-CVETRAN` / `A00-R01-CVETRAN` | A00-R01-CVETRAN | CAMPO-COMP | inc-p052 | Clave de transacción del registro R01; código de 6 dígitos que identifica el tipo específico de operación contable. |
| `SMS-ESQCON` / `A00-R01-ESQCON` | A00-R01-ESQCON | CAMPO-COMP | inc-p052 | Código del esquema de contabilización aplicado para generar el asiento contable en el GL de S151. |

**Estado validación:** pendiente HITL

---

### RN-S151-032 — Enrutamiento por sistema (W77-SISTEMA-PARAMETRO)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-032 |
| **Nombre** | Enrutamiento por sistema (W77-SISTEMA-PARAMETRO) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — arquitectura multi-sistema |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 es un motor multi-sistema controlado por `W77-SISTEMA-PARAMETRO` (PIC 9(3)). Sistemas conocidos: 17=S017, 18=S018, 84=S084 tarjetas, 87=S087 cheques, 264=S264 SPEI, 333, 402-408=crédito, 500=caja (ruta especial 20001), 501, 502=nómina, 701=hacienda, 702=CBII, 703=SWIFT, 711=cheques MICR. El sistema 500 es el único que usa ruta alternativa `PERFORM 20001`.

**Trigger:** Inicio de 000000-PROGRAMA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | Código del sistema que invoca P109 |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 000000-PROGRAMA · Líneas: ~7750
IF W77-SISTEMA-PARAMETRO = 500 → PERFORM 20001-PROCESA-MOVIMIENTOS
ELSE → PERFORM 20000-PROCESA-MOVIMIENTOS
+ condicionantes internas por sistema para banco, sector, datalake, posglobal
```

**Riesgos de migración:**
- P109 contiene 15+ subsistemas en un binario — la arquitectura destino debe descomponerlos en microservicios o configuración externalizada
- Cada subsistema puede tener comportamientos únicos no documentados fuera de este código

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). Número de sistema utilizado para la consulta de parámetros en S080; parámetro de entrada al servicio de parámetros del GL. |

**Estado validación:** pendiente HITL

---

### RN-S151-033 — Mapeo instrumento→S016-INST para S087 (tabla hardcoded)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-033 |
| **Nombre** | Mapeo instrumento→S016-INST para S087 (tabla hardcoded) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — mapeo de productos cheques |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para S087 (cheques), mapeo hardcoded de instrumento a contrato S016: INSTRUMENTO=1→38, =2→36, =4/7→35, =3/5→37, =8/9→39. Permite ubicar el contrato intercompany/fideicomiso correspondiente a cada tipo de cheque.

**Trigger:** Procesamiento de movimiento S087

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-INSTRUMENTO` | PIC 9(n) | Código de tipo de cheque |
| `S016-CTO-INST` | PIC 9(n) | Código de contrato S016 |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 20000 · Líneas: ~10500-10518
IF W77-SISTEMA-PARAMETRO = 087:
  EVALUATE A00-R01-INSTRUMENTO
    WHEN 1 → S016-CTO-INST = 38
    WHEN 2 → S016-CTO-INST = 36
    WHEN 4 OR 7 → S016-CTO-INST = 35
    WHEN 3 OR 5 → S016-CTO-INST = 37
    WHEN 8 OR 9 → S016-CTO-INST = 39
```

**Riesgos de migración:**
- Si se agregan nuevos tipos de cheque, el hardcode no los maneja — tabla de configuración obligatoria en nuevo sistema

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-INSTRUMENTO` | A00-R01-INSTRUMENTO-S016 | CAMPO-COMP | inc-p052 | Clave del instrumento financiero (campo S016) que origina el movimiento contable R01; redefine el agrupador de desviación. |
| `S016-CTO-INST` | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-034 — S264 MONEDA=1 → BANCO=0 (SPEI pesos sin dimensión banco)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-034 |
| **Nombre** | S264 MONEDA=1 → BANCO=0 (SPEI pesos sin dimensión banco) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO |
| **Regulador** | CNBV (contabilidad regulatoria) — NO es reporte SPEI de Banxico |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:10748-10753 (párrafo 21115-VERIFICA-SISTEMA, inicia en :10737) |
| **Dataset DMSII** | — (opera sobre el registro de sort RMS en memoria; no accede DMSII directamente) |

**Descripción:** En el motor de asientos contables, las transferencias SPEI (sistema S264) reciben un tratamiento especial de la dimensión banco según la moneda. Cuando la transferencia es en pesos (MONEDA=1), el asiento se registra sin banco asociado, de modo que la posición del sistema de pagos se consolida a nivel global y no se fragmenta por institución. Cuando no es en pesos, el asiento conserva el banco de la contraparte, salvo que ese dato venga vacío.

**Condición:** El movimiento se procesa bajo el sistema de pagos S264.

**Consecuencia:** Si MONEDA=1, la dimensión banco del asiento se fija en ceros. En otro caso, si el banco de origen viene informado, se toma el banco real de la contraparte.

**Excepciones (corregido por SME SPEI):** La rama MONEDA≠1 NO es "SPEI en divisa" — SPEI liquida exclusivamente en pesos. Esa rama corresponde a SPID (SPEI Directo, USD) o a liquidación por corresponsalía/nostro, que sí conservan el banco por ser liquidación bilateral. Además, en esa rama solo se mueve el banco real si `A00-R01-BCOS-R NOT = SPACES`; si viene en blanco, RMS-BANCO conserva su valor previo (guard confirmado en fuente :10752-10753, omitido en la versión anterior de la regla).

**Trigger:** Procesamiento de movimiento S264

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-MONEDA` | PIC 9(04) COMP | 1=MXN, otro=SPID/divisa |
| `RMS-BANCO` | PIC 9(04) COMP | Dimensión banco en el registro de asiento (sort RMS) |
| `A00-R01-BCOS` | PIC 9(10) COMP | Banco real de la contraparte (rama no-MXN) |
| `A00-R01-BCOS-R` | REDEFINES BCOS | Guard: solo aplica si NOT = SPACES |

**Traza de código (verificada en fuente):**
```
21115-VERIFICA-SISTEMA. (COBOL_P109.txt:10737)
IF W77-SISTEMA-PARAMETRO = 264            (:10748)
   IF A00-R01-MONEDA = 1                   (:10749)
      MOVE ZEROS TO RMS-BANCO              (:10750)
   ELSE
      IF A00-R01-BCOS-R NOT = SPACES       (:10752)
         MOVE A00-R01-BCOS TO RMS-BANCO    (:10753)
```

**Riesgos de migración:** El nuevo sistema debe conservar banco=0 en SPEI pesos. La prueba de equivalencia NO es un test de conformidad SPEI, sino un **test de cuadre contable (reconciliation parity)**: correr el mismo lote en legacy y target y verificar que (1) la pierna en pesos consolida con banco=0, (2) la pierna no-MXN conserva banco real, y (3) ambos GL concilian contra los Avisos de Liquidación de Banxico y contra nostro/SPID respectivamente. Si el target conserva banco en SPEI pesos, genera subsaldos fantasma por contraparte que corrompen el cuadre.

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-MONEDA` | — | — | — | no encontrado en vocab-s151.md con ese nombre exacto |
| `RMS-BANCO` | — | — | — | no encontrado en vocab-s151.md |
| S264 (sistema) | A00-BIT264-* (múltiples) | CAMPO-NUM/DECIMAL | inc-p109 | Campos del sistema S264 (SPEI/compensación interbancaria): CSI-DEST, CSI-ORIG, CVETRAN, ESQCONT, IMPORTE, FUNCION, etc. — ampliamente documentados. |
| S264 (sistema) | E00-R01-S264-* (múltiples) | CAMPO-NUM/ALFA | inc-pro | Registros de salida hacia S264: autorización, banco, importe, referencia, tipo de registro. |

**Rationale (validado por SME SPEI):** El asiento GL de SPEI en pesos se registra sin dimensión banco porque SPEI es un sistema RTGS/LBTR que liquida cada orden individual, bruta e irrevocablemente contra la cuenta de depósito única del participante en Banxico, sin netting multilateral; por tanto no existe posición bilateral neta en pesos frente a cada institución contraparte que amerite fragmentar el asiento. La rama no-MXN (SPID USD o corresponsalía) conserva el banco porque esas operaciones liquidan mediante relaciones bilaterales (cuentas nostro o estructura de cuentas USD segregada). La regla es una convención de contabilidad interna que refleja fielmente la mecánica de liquidación de cada moneda; su cumplimiento asociado es de contabilidad regulatoria CNBV, no de reporte SPEI Banxico.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — mecánica confirmada contra fuente COBOL_P109.txt:10748-10753 |
| **Validado por SME** | SME SPEI, 2026-07 — rationale RTGS/LBTR confirmado; corrige premisa "SPEI divisa" → SPID/corresponsalía |
| **DATO-REQUERIDO (contabilidad Banamex)** | (a) ¿la rama no-MXN enruta a SPID o a corresponsalía? (b) ¿existe requerimiento CNBV de desagregación por contraparte en ME que justifique conservar el banco? |

---

### RN-S151-035 — Gate de actualización POSICION por tipo BD (WKS-B03-TIPBD)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-035 |
| **Nombre** | Gate de actualización POSICION por tipo BD (WKS-B03-TIPBD) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La actualización de la base de datos de posición solo se ejecuta cuando `WKS-B03-TIPBD = 1 OR 2 OR 5 OR 6`. Para otros tipos, la sección 50000 (POSICION) se omite, permitiendo ejecutar P109 en modo "solo cuadre" sin actualizar posición GL.

**Trigger:** Fin de procesamiento de movimientos

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-B03-TIPBD` | PIC 9(1) | Tipo de base de datos del proceso |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 000000-PROGRAMA · Líneas: ~8060
IF WKS-B03-TIPBD = 1 OR 2 OR 5 OR 6 → PERFORM 50000-POSICION
```

**Riesgos de migración:**
- El nuevo sistema debe replicar el concepto de "tipo de BD" o externalizar este control en configuración de pipeline

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-B03-TIPBD` | WKS-B03-TIPBD | CAMPO-NUM | inc-p052 | Tipo de base de datos DMSII en el bloque B03 del área de trabajo; clasifica la BD (movimientos, saldos, control) a acceder. |
| `POSICION` (concepto) | POSICION | ENTIDAD | dominio | Dataset B02POSICION de BD13BIFIN. Posición financiera por sistema: saldo inicial y final (número e importe) de cargos y abonos. Clave: SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA. |

**Estado validación:** pendiente HITL

---

### RN-S151-036 — CUADRE contable no se genera para S502 y S702

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-036 |
| **Nombre** | CUADRE contable no se genera para S502 y S702 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El reporte de cuadre contable (sección 40000) se genera si `WKS-B03-NOMBDSAL NOT = SPACES` OR sistema es 502/702. Los sistemas S502 (nómina externa) y S702 (CBII) siempre fuerzan generación del cuadre; otros sistemas lo generan solo si NOMBDSAL está configurado.

**Trigger:** Fin del proceso en 000000-PROGRAMA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-B03-NOMBDSAL` | ALPHA | Nombre BD de saldos (en blanco = no configurado) |
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | Sistema origen |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 000000-PROGRAMA · Líneas: ~8070
IF (WKS-B03-NOMBDSAL NOT = SPACES) OR (W77-SISTEMA-PARAMETRO = 502 OR 702) → 40000
```

**Riesgos de migración:**
- La lógica de generación de cuadre debe replicarse por sistema en la arquitectura destino

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-B03-NOMBDSAL` | WKS-B03-NOMBDSAL | CAMPO-ALFA | inc-p052 | Nombre de la base de datos de saldos en el bloque B03 (17 chars). Nombre literal de la BD DMSII de saldos (BD11SDOS151) para apertura del set. |
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). Parámetro de entrada al servicio de parámetros del GL. |

**Estado validación:** pendiente HITL

---

### RN-S151-037 — Salida DATALAKE exclusiva para S264 (SPEI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-037 |
| **Nombre** | Salida DATALAKE exclusiva para S264 (SPEI) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — trazabilidad de pagos |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo DATALAKE solo se abre y escribe cuando `W77-SISTEMA-PARAMETRO = 264` (SPEI). Para todos los demás sistemas, DATALAKE no se genera. S264 es el único sistema que alimenta directamente la capa de datalake en tiempo de proceso batch, posiblemente para cumplir requisitos de trazabilidad de pagos electrónicos.

**Trigger:** Fin del loop de movimientos en 20000

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | 264=SPEI |
| archivo DATALAKE | file | Output de trazabilidad SPEI |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: post-20000 · Líneas: ~7900
IF W77-SISTEMA-PARAMETRO = 264 → OPEN DATALAKE + WRITE registros
```

**Riesgos de migración:**
- En migración, el canal DATALAKE de SPEI debe redirigirse al data lake destino sin pérdida de trazabilidad

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). |
| `DATALAKE` (archivo) | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-038 — Negación de cargos en cuadre (CARGOS = TCP-CARGOS × −1)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-038 |
| **Nombre** | Negación de cargos en cuadre (CARGOS = TCP-CARGOS × −1) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (mecánica en fuente + rationale SME regulatorio) |
| **Regulador** | Convención de presentación interna consistente con dualidad económica — no es requisito normativo CNBV explícito |
| **Programa ejecutor** | P109 |
| **Evidencia código** | COBOL_P109.txt:14618 y :15355 (`COMPUTE A00-R01-S250-CAR = (WKS-TCP-CARGOS * -1)`); campo firmado `A00-R01-S250-CAR PIC S9(16)V99` en :2905 |
| **Dataset DMSII** | Análisis interno: reporte de cuadre, sección 40000 (campo de salida A00-R01-S250-CAR y su copia A00-R01-S115-CAR) |

**Descripción:** Los cargos acumulados se invierten de signo antes de escribirse al reporte de cuadre: `COMPUTE A00-R01-S250-CAR = WKS-TCP-CARGOS * -1`. Los débitos se representan como valores negativos en el reporte y los abonos mantienen signo positivo, de modo que la suma algebraica cargos+abonos = 0 evidencie el cuadre. Es una convención de presentación de signos.

**Condición:** Se genera el registro de cuadre para una cuenta en la sección 40000.

**Consecuencia:** El importe de cargos del reporte se calcula como el acumulado interno multiplicado por −1 (débitos negativos), mientras los abonos conservan signo positivo.

**Trigger:** Acumulación de registros MOVCONTABLES en cuadre (sección 40000)

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-TCP-CARGOS` | PIC 9(n) | Acumulado cargos (positivo interno) |
| `A00-R01-S250-CAR` | PIC S9(n) | Cargos en reporte (negativo por convención) |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 40000-GENERA-CUADRE-CONTABLE · Líneas: ~14560
COMPUTE A00-R01-S250-CAR = WKS-TCP-CARGOS * -1
```

**Riesgos de migración:**
- El nuevo sistema debe replicar la convención de signos o los reportes de cuadre mostrarán valores invertidos

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-TCP-CARGOS` | WKS-TCP-CARGOS | CAMPO-COMP | inc-p109 | Total de cargos por cuenta y período (COMP S9(16)V99). Suma firmada acumulada de cargos en el período de procesamiento contable del S151. |
| `A00-R01-S250-CAR` | — | — | — | no encontrado en vocab-s151.md |

**Rationale (validado por SME Regulatorio CNBV):** Convención de presentación consistente con la dualidad económica (la suma debe netear a cero para demostrar cuadre). No hay norma CNBV que imponga el signo negativo del cargo; es criterio de reportería interna. El riesgo real de migración es aritmético, no regulatorio: un mal manejo del signo del packed decimal / del `S` del PIC, o una doble negación (acumulación firmada + `×−1`), invierte el cuadre completo.

**Validación:**

| Rol | Estado |
|-----|--------|
| **Validado por Lead** | Swarm dt-mainframe-analyst, 2026-07-27 — evidencia COBOL_P109.txt:14618, :15355, campo S9(16)V99 en :2905 |
| **Validado por SME** | SME Regulatorio Mainframe (CNBV), 2026-07 — correcto; matiza "NIF" → convención de presentación interna; riesgo aritmético (signo/packed decimal), no regulatorio |
| **Equivalencia (requisito SME)** | Golden-master byte a byte del campo A00-R01-S250-CAR y su copia A00-R01-S115-CAR: mismo signo, magnitud y 2 decimales. Casos borde de rounding y packed decimal (centavos, negativos de origen, −0 vs +0). Verificar que los consumidores downstream lean la misma convención |

---

### RN-S151-039 — Cuatro dimensiones del reporte de cuadre contable

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-039 |
| **Nombre** | Cuatro dimensiones del reporte de cuadre contable |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — reportería interna |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La sección 40000 genera cuatro vistas de cuadre: (1) por instrumento, (2) por producto, (3) por banco, (4) por sistema. En cada dimensión se acumulan: `RCC-CARTRA` (cargos transitorios), `RCC-ABOTRA` (abonos transitorios), `RCC-CARAUT` (cargos autorizados), `RCC-ABOAUT` (abonos autorizados). Son la base de los reportes de cuadre que operaciones usa para validar el cierre del día.

**Trigger:** Inicio de sección 40000

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `RCC-CARTRA` | PIC 9(n) | Cargos transitorios |
| `RCC-ABOTRA` | PIC 9(n) | Abonos transitorios |
| `RCC-CARAUT` | PIC 9(n) | Cargos autorizados |
| `RCC-ABOAUT` | PIC 9(n) | Abonos autorizados |

**Traza de código:**
```
PROGRAMA: P109 · SECCIONES: 40010, 40020, 40030, 40040 · Líneas: ~14515+
Agrupación: instrumento / producto / banco / sistema
```

**Riesgos de migración:**
- El nuevo sistema debe producir los mismos cuatro reportes de cuadre para que operaciones pueda validar el cierre

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `RCC-CARTRA` | WKS-TC-CARTRA | CAMPO-COMP | inc-p109 | Total de cargos por transacción acumulados (COMP 9(16)V99). Suma de cargos originados en transacciones procesadas en el ciclo GL del S151. |
| `RCC-ABOTRA` | WKS-TC-ABOTRA | CAMPO-COMP | inc-p109 | Total de abonos por transacción acumulados (COMP 9(16)V99). Suma de abonos originados en transacciones procesadas en el ciclo GL del S151. |
| `RCC-CARAUT` | WKS-TC-CARAUT | CAMPO-COMP | inc-p109 | Total de cargos automáticos acumulados (COMP 9(16)V99). Suma de cargos generados automáticamente en el ciclo de procesamiento contable. |
| `RCC-ABOAUT` | WKS-TC-ABOAUT | CAMPO-COMP | inc-p109 | Total de abonos automáticos acumulados (COMP 9(16)V99). Suma de abonos generados automáticamente en el ciclo de procesamiento contable. |

**Nota:** Los nombres exactos RCC-CARTRA, RCC-ABOTRA, RCC-CARAUT, RCC-ABOAUT (prefijo RCC) no tienen entrada independiente en vocab; se mapean a las variantes WKS-TC-* que corresponden semánticamente al mismo concepto en P109.

**Estado validación:** pendiente HITL

---

### RN-S151-040 — Ciclo completo de reemplazo de posición DMS (DELETE→CREATE→STORE)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-040 |
| **Nombre** | Ciclo completo de reemplazo de posición DMS (DELETE→CREATE→STORE) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — idempotencia de posición GL |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La actualización de posición en DMSII sigue tres fases idempotentes: (1) **Elimina** (51000): borra todos los registros de posición del día actual via `LOCK FIRST/NEXT` + `DELETE`; (2) **Crea saldo inicial** (53000): por cada registro de POSICIONDIAANT ejecuta `CREATE` con SDOANT=día anterior, CARGOS=0, ABONOS=0; (3) **Actualiza** (54000): aplica movimientos del día — `LOCK` + acumula + `STORE`; si no existe: `CREATE` nuevo. Garantiza idempotencia: P109 puede re-ejecutarse y el resultado siempre es correcto.

**Trigger:** Gate RN-S151-035 habilitado (WKS-B03-TIPBD=1/2/5/6)

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B72-SDO-SDOANT` | PIC 9(14)V99 | Saldo anterior |
| `B72-SDO-SDOACT` | PIC 9(14)V99 | Saldo actual |
| `B72-SDO-CARGOS` | PIC 9(14)V99 | Cargos del día |
| `B72-SDO-ABONOS` | PIC 9(14)V99 | Abonos del día |

**Traza de código:**
```
PROGRAMA: P109 · SECCIONES: 51000, 53000, 54000 · Líneas: 16626-16709
51000: LOCK FIRST B72SXPOSCONTA → DELETE S151B72POSCONTA (loop)
53000: READ POSICIONDIAANT → CREATE S151B72POSCONTA (SDOANT=ayer, CAR=0, ABO=0)
54000: LOCK B72SXPOSCONTA → acumula → STORE; ON EXCEPTION → CREATE nuevo
```

**Riesgos de migración:**
- El nuevo GL debe implementar un upsert transaccional equivalente con garantía de idempotencia
- El DELETE masivo + rebuild es costoso — el nuevo sistema debe optimizarlo sin perder la idempotencia

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `B72-SDO-SDOANT` | WKS-TC-SDOANT | CAMPO-COMP | inc-p109 | Saldo anterior firmado de la cuenta (COMP S9(17)V99). Saldo previo al inicio del ciclo de procesamiento, usado para verificación de cuadre GL. (Equivalente semántico) |
| `B72-SDO-SDOACT` | WKS-TC-SDOACT | CAMPO-COMP | inc-p109 | Saldo actual firmado de la cuenta (COMP S9(17)V99). Saldo vigente después de aplicar todos los movimientos del ciclo de procesamiento GL. (Equivalente semántico) |
| `B72-SDO-CARGOS` | — | — | — | no encontrado en vocab-s151.md (campo DMS directo) |
| `B72-SDO-ABONOS` | — | — | — | no encontrado en vocab-s151.md (campo DMS directo) |
| B72 (conjunto DMS) | TOTALB72SDOACT | CAMPO-EDICION | inc-pro | Total del saldo actual para el tipo B72 en edición (ZZZ...ZZ9). Suma acumulada del saldo actual del libro B72 (posición contable) del sistema GL S151. |

**Estado validación:** pendiente HITL

---

### RN-S151-041 — S408: asignación de sector por instrumento (hardcoded CNBV)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-041 |
| **Nombre** | S408: asignación de sector por instrumento (hardcoded CNBV) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [REGLA-CNBV] [HARDCODE-SOSPECHOSO] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista) — dimensión regulatoria: ver SME (RN-026 partida doble / sector CNBV) |
| **Regulador** | CNBV — clasificación de cartera hipotecaria |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para S408 (crédito hipotecario) cuando sector=0, asigna sector CNBV por instrumento: instrumento 10→sector 31, instrumento 20→sector 32, otro→sector 0. Refleja la clasificación regulatoria CNBV de carteras hipotecarias donde el instrumento distingue el tipo (vivienda interés social vs media/residencial).

**Trigger:** Procesamiento de movimiento S408 con W77-SEC-SORT=0

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-INSTRUMENTO` | PIC 9(n) | Tipo de crédito hipotecario |
| `W77-SEC-SORT` | PIC 9(n) | Sector para acumulación |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21121 · Líneas: ~10960
IF W77-SISTEMA-PARAMETRO=408 AND W77-SEC-SORT=0:
  WHEN INSTRUMENTO=10 → sector=31
  WHEN INSTRUMENTO=20 → sector=32
  OTHERWISE → sector=0
```

**Riesgos de migración:**
- [RIESGO-CNBV-REPORTE]: Si la clasificación de sectores CNBV cambia, este hardcode produce reportes incorrectos

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-INSTRUMENTO` | A00-R01-INSTRUMENTO-S016 | CAMPO-COMP | inc-p052 | Clave del instrumento financiero (campo S016) que origina el movimiento contable R01. |
| `W77-SEC-SORT` | — | — | — | no encontrado en vocab-s151.md |
| S408 (sistema) | A00-BIT-IMPORTE-S408 | CAMPO-DECIMAL | inc-p109 | Importe monetario del bit de entrada proveniente del sistema S408 (operaciones de transferencia/captación) para registro en GL. |
| S408 (sistema) | A00-BITNF-IMPORTE-S408 | CAMPO-DECIMAL | inc-p109 | Importe de la operación en el sistema S408 para instrumentos de inversión sin fondeo (BITNF) registrados en el GL. |

**Estado validación:** pendiente HITL

---

### RN-S151-042 — Ruta especial S500 (efectivo/caja) via 20001

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-042 |
| **Nombre** | Ruta especial S500 (efectivo/caja) via 20001 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El sistema 500 (efectivo/caja) es el único que ejecuta `PERFORM 20001-PROCESA-MOVIMIENTOS` en lugar del flujo normal `20000`. La sección 20001 omite ciertos pasos del flujo normal y va directamente a la acumulación, optimizando el proceso para el volumen masivo de operaciones de caja.

**Trigger:** `IF W77-SISTEMA-PARAMETRO = 500` al inicio de 000000-PROGRAMA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | 500=efectivo/caja |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 000000-PROGRAMA · Líneas: ~7780
IF W77-SISTEMA-PARAMETRO = 500 → PERFORM 20001; ELSE → PERFORM 20000
```

**Riesgos de migración:**
- El microservicio de caja en la arquitectura destino debe implementar la misma lógica optimizada

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). Número de sistema utilizado para la consulta de parámetros en S080. |
| S500 (sistema) | 500-R02-FUNCION | CAMPO-NUM | inc-pro | Código de función en el registro 02 de S500; código numérico de 2 dígitos que identifica la función contable del movimiento en el sistema S151 reportada a S500. |
| S500 (sistema) | 500-R02-IMPORTRAN | CAMPO-DECIMAL | inc-pro | Importe monetario de la transacción recibida del sistema S500 vía registro R02, expresado en pesos con dos decimales. |

**Estado validación:** pendiente HITL

---

### RN-S151-043 — Reporte HACIENDA condicional (solo S701)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-043 |
| **Nombre** | Reporte HACIENDA condicional (solo S701) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [REGLA-CNBV] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | SAT/SHCP — reportería fiscal |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La generación del reporte de Hacienda (SAT/SHCP) solo se ejecuta cuando `W77-SISTEMA-PARAMETRO = 701`. La sección 21500 es la variante S701 que obtiene cuentas de tablas separadas del ESQCON (`WKS-EQ-CUENTA1/2/3-S701`) y el NAT-MOV desde `W77-IND3` directamente.

**Trigger:** `IF W77-SISTEMA-PARAMETRO = 701`

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-EQ-CUENTA1-S701` | PIC 9(n) | Cuenta GL específica Hacienda |
| `WKS-EQ-CUENTA2-S701` | PIC 9(n) | Segunda cuenta GL Hacienda |
| `WKS-EQ-CUENTA3-S701` | PIC 9(n) | Tercera cuenta GL Hacienda |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21500-GRABA-PAR-CONTAB · Líneas: ~8090
SÓLO SI W77-SISTEMA-PARAMETRO = 701
Cuentas desde tablas S701 separadas del ESQCON estándar
```

**Riesgos de migración:**
- Las tablas de cuentas S701 son independientes del ESQCON principal — migrar como catálogo separado

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-EQ-CUENTA1-S701` | — | — | — | no encontrado en vocab-s151.md |
| `WKS-EQ-CUENTA2-S701` | — | — | — | no encontrado en vocab-s151.md |
| `WKS-EQ-CUENTA3-S701` | — | — | — | no encontrado en vocab-s151.md |
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). |

**Nota de riesgo:** Las tablas de cuentas S701 son exclusivas de Hacienda y no están en el vocab; requieren análisis independiente para migración.

**Estado validación:** pendiente HITL

---

### RN-S151-044 — Semilla de posición: SDOACT día anterior → SDOANT nuevo día

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-044 |
| **Nombre** | Semilla de posición: SDOACT día anterior → SDOANT nuevo día |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | NIF — continuidad de saldos |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La posición del día se inicializa tomando el saldo actual (`B72-SDO-SDOACT`) del día anterior y moviéndolo como `RPDA-SDOANT`. Al crear los registros del nuevo día: `SDOANT = RPDA-SDOANT`, `SDOACT = RPDA-SDOANT`, CARGOS=0, ABONOS=0. Invariante: `SDOACT[t] = SDOANT[t+1]`.

**Trigger:** Inicio de 53000-CREA-SALDO-INICIAL

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B72-SDO-SDOACT` | PIC 9(14)V99 | Saldo actual (día anterior) |
| `B72-SDO-SDOANT` | PIC 9(14)V99 | Saldo anterior (nuevo día) |
| `RPDA-SDOANT` | PIC 9(14)V99 | Semilla para nuevo día |

**Traza de código:**
```
PROGRAMA: P109 · SECCIONES: 52000, 53000 · Líneas: 16637-16675
MOVE B72-SDO-SDOACT TO RPDA-SDOANT (del día anterior)
CREATE S151B72POSCONTA con B72-SDO-SDOANT = B72-SDO-SDOACT = RPDA-SDOANT, CARGOS=0, ABONOS=0
```

**Riesgos de migración:**
- Si la inicialización de saldos falla para alguna cuenta, esa cuenta arranca el día con saldo cero — error silencioso que se detecta hasta el cierre

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `B72-SDO-SDOACT` | WKS-TC-SDOACT | CAMPO-COMP | inc-p109 | Saldo actual firmado de la cuenta (COMP S9(17)V99). Saldo vigente después de aplicar todos los movimientos del ciclo de procesamiento GL. |
| `B72-SDO-SDOANT` | WKS-TC-SDOANT | CAMPO-COMP | inc-p109 | Saldo anterior firmado de la cuenta (COMP S9(17)V99). Saldo previo al inicio del ciclo de procesamiento, usado para verificación de cuadre GL. |
| `RPDA-SDOANT` | — | — | — | no encontrado en vocab-s151.md |
| `POSICIONDIAANT` (archivo) | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-045 — POSGLOBAL: sistemas que guardan vs. purgan el archivo

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-045 |
| **Nombre** | POSGLOBAL: sistemas que guardan vs. purgan el archivo |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El archivo POSGLOBAL se cierra con SAVE (retiene para downstream) solo para sistemas: 084, 087, 408, 701, 264, 17, 18, 333, 702, 502. Para cualquier otro sistema: `CLOSE POSGLOBAL WITH PURGE`. Determina qué sistemas contribuyen a la posición global integrada.

**Trigger:** Fin de 50020-POS-POR-SIST-SUBCTA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | Sistema origen |
| archivo POSGLOBAL | file | Posición global por subcuenta |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 50020 · Líneas: ~16392
IF W77-SISTEMA-PARAMETRO = 084 OR 087 OR 408 OR 701 OR 264 OR 17 OR 18 OR 333 OR 702 OR 502
→ CLOSE POSGLOBAL (SAVE)
ELSE → CLOSE POSGLOBAL WITH PURGE
```

**Riesgos de migración:**
- Si se agrega un nuevo sistema, por defecto se purga — regla debe convertirse a configuración

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). |
| `POSGLOBAL` (archivo) | WKS-TIT-POSGLOBAL | GRUPO | inc-p109 | Grupo de cabecera/título del reporte POSGLOBAL en P109 (estructura de presentación, no entidad de datos). Archivo POSGLOBAL como entidad independiente no tiene entrada vocab. |

**Estado validación:** pendiente HITL

---

### RN-S151-046 — FID siempre=0 en llaves de POSICION (sin dimensión fideicomiso)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-046 |
| **Nombre** | FID siempre=0 en llaves de POSICION (sin dimensión fideicomiso) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** En todas las operaciones de LOCK sobre S151B72POSCONTA, `B72-SDO-KEYFID` (fideicomiso) siempre es 0. La dimensión fideicomiso existe en la estructura de datos pero no se usa en la llave de posición de S151. La dimensionalidad efectiva de posición es: CSI + FECHA + BANCO + PRODUCTO + INSTRUMENTO + MONEDA + CUENTA + CAUSA + SECTOR (sin FID).

**Trigger:** Toda operación LOCK/CREATE en S151B72POSCONTA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B72-SDO-KEYFID` | PIC 9(n) | Dimensión fideicomiso (siempre 0) |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 54000 · Líneas: ~16691
B72-SDO-KEYFID = 0 (constante en todas las operaciones)
```

**Riesgos de migración:**
- El nuevo GL no debe incluir FID como dimensión de posición GL — puede confundir si se mapea desde DASDL

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `B72-SDO-KEYFID` | — | — | — | no encontrado en vocab-s151.md |

**Nota:** La dimensión FID existe en la estructura DASDL de S151B72POSCONTA pero no tiene entrada vocab propia; su ausencia en el vocab es coherente con el hecho de que se usa siempre con valor 0.

**Estado validación:** pendiente HITL

---

### RN-S151-047 — Seis vistas de posición con dimensiones distintas

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-047 |
| **Nombre** | Seis vistas de posición con dimensiones distintas |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 genera hasta 6 vistas del archivo POSICION: (1) por cuenta (50010), (2) por subcuenta+POSGLOBAL (50020), (3) por banco (50030), (4) por sector (50040), (5) por instrumento (50050), (6) por producto (50060). Las vistas 50030-50060 solo se generan `IF NOT W88-SIST-CEN-CONTABLE`, excluyendo el sistema de contabilidad central de los reportes detallados.

**Trigger:** Ejecución de 50000-POSICION

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W88-SIST-CEN-CONTABLE` | flag | Indica si es el sistema de contabilidad central |

**Traza de código:**
```
PROGRAMA: P109 · SECCIONES: 50010-50060 · Líneas: 16311-16574
50010, 50020: siempre; 50030-50060: IF NOT W88-SIST-CEN-CONTABLE
```

**Riesgos de migración:**
- El nuevo sistema debe producir las 6 vistas de posición para los procesos downstream que las consumen

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W88-SIST-CEN-CONTABLE` | — | — | — | no encontrado en vocab-s151.md |
| POSICION (concepto) | POSICION | ENTIDAD | dominio | Dataset B02POSICION de BD13BIFIN. Posición financiera por sistema: saldo inicial y final de cargos y abonos. Clave: SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA. |
| SUBCTA (concepto) | WKS-TOTAL-SUBCTA-CONT | GRUPO | inc-p109 | Grupo de total de subcuenta contable (estructura de acumulación, nivel bajo). |

**Estado validación:** pendiente HITL

---

### RN-S151-048 — STATUS=1 dispara retroalimentación GRABA-PUNTEO al sistema origen

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-048 |
| **Nombre** | STATUS=1 dispara retroalimentación GRABA-PUNTEO al sistema origen |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — integración bidireccional |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Los movimientos con STATUS=1 (autorizados) disparan adicionalmente `PERFORM GRABA-PUNTEO` — escribe una confirmación de contabilización de vuelta al sistema origen. Los movimientos STATUS=2 generan asientos GL pero NO confirman al origen — quedan pendientes de confirmación. Esta distinción es crítica para sistemas de banca en línea que necesitan saber si su movimiento fue definitivamente contabilizado.

**Trigger:** `IF A00-R01-STATUS = 1` dentro de 21100-GRABA-ARCHIVOS

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-STATUS` | PIC 9(1) | 1=autorizado (confirma al origen), 2=en proceso |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21100-GRABA-ARCHIVOS · Líneas: ~10600
IF STATUS = 1 → asiento GL + GRABA-PUNTEO (confirmación al origen)
IF STATUS = 2 → solo asiento GL (sin confirmación)
```

**Riesgos de migración:**
- [RIESGO-EQUIVALENCIA]: Si el nuevo sistema no implementa el canal de confirmación de punteo, los sistemas origen quedarán con movimientos "pendientes" permanentemente

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-STATUS` | A00-R01-STATUS | CAMPO-COMP | inc-p052 | Estatus del procesamiento del registro en la interfaz R01; código numérico que refleja el resultado de la operación en S151. |
| PUNTEO (concepto) | PUNTEO ON CMEMP | ENTIDAD | patron-unisys | Marca de punteo contable con tercer nivel — campo B01-SIS-3ERNIV 'PUNTEO CON TERCER NIVEL'. Referencia a archivo de punteo S253: B02-SIS-NOMARC253. El punteo con tercer nivel indica verificación supervisora del movimiento en el cierre GL. |

**Estado validación:** pendiente HITL

---

### RN-S151-049 — Asignación de código de banco por sistema

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-049 |
| **Nombre** | Asignación de código de banco por sistema |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El código de banco en el asiento GL (`RMS-BANCO`) se obtiene de campos distintos según el sistema: S018/S017 → `A00-R01-BCO-S018`; S703 (SWIFT) → `A00-R01-BCOS`; S264+MXN → 0; S264+divisa → `A00-R01-BCOS`. La variabilidad refleja que diferentes sistemas fuente almacenan el banco en campos distintos de LOG151.

**Trigger:** Procesamiento de cada movimiento en 21115-VERIFICA-SISTEMA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `A00-R01-BCO-S018` | PIC 9(n) | Banco para S018/S017 |
| `A00-R01-BCOS` | PIC 9(n) | Banco genérico |
| `RMS-BANCO` | PIC 9(n) | Dimensión banco en asiento GL |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21115 · Líneas: ~10738
IF S018 OR S017 → RMS-BANCO = A00-R01-BCO-S018
IF S703 → RMS-BANCO = A00-R01-BCOS
IF S264+MXN → RMS-BANCO = 0
IF S264+divisa → RMS-BANCO = A00-R01-BCOS
```

**Riesgos de migración:**
- Cada sistema debe mapear correctamente su campo de banco — documento de interfaz LOG151 por sistema es crítico

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `A00-R01-BCO-S018` | A00-R01-BCO-S018 | CAMPO-COMP | inc-p052 | Código de banco proveniente del sistema S018 en el registro R01; identifica la institución bancaria participante en el movimiento. |
| `A00-R01-BCOS` | — | — | — | no encontrado en vocab-s151.md con ese nombre exacto |
| `RMS-BANCO` | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-050 — RECHAZOS no se genera para S702 y S502

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-050 |
| **Nombre** | RECHAZOS no se genera para S702 y S502 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El reporte de RECHAZOS (movimientos no contabilizados) se genera para todos los sistemas EXCEPTO S702 (CBII) y S502 (nómina externa). Esos dos sistemas manejan sus errores por un canal diferente. Condición: `IF W77-SISTEMA-PARAMETRO NOT = 702 OR 502`.

**Trigger:** Fin del proceso en 000000-PROGRAMA

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `W77-SISTEMA-PARAMETRO` | PIC 9(3) | Sistema origen |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 000000 · Líneas: ~8100
IF W77-SISTEMA-PARAMETRO NOT = 702 OR 502 → genera RECHAZOS
```

**Riesgos de migración:**
- S702 y S502 necesitan un canal alternativo de notificación de errores en el nuevo sistema

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `W77-SISTEMA-PARAMETRO` | W77-SISTEMA-PARAMETRO | CAMPO-NUM | inc-pro | Sistema de parámetro global (3 dígitos). |
| RECHAZOS (concepto) | WKS-TOT-RECHAZOS | CAMPO-COMP | inc-p109 | Total acumulado de transacciones rechazadas en el proceso; contador binario COMP de 6 dígitos compartido en programas de validación P107-P130. |
| RECHAZOS (fecha) | WKS-FECHA-RECHA | CAMPO-NUM | inc-p109 | Fecha del rechazo del movimiento contable en formato AAMMDD (6 dígitos). Fecha en que S151 rechazó el movimiento; queda registrada en el log de rechazos. |

**Estado validación:** pendiente HITL

---

### RN-S151-051 — Validez de entrada ESQCON: NAT-MOV debe ser 1 o 2

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-051 |
| **Nombre** | Validez de entrada ESQCON: NAT-MOV debe ser 1 o 2 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista) — dimensión regulatoria: ver SME (RN-026 partida doble / sector CNBV) |
| **Regulador** | NIF — partida doble |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Si el catálogo ESQCON tiene una entrada con `WKS-EQ-NAT-MOV` distinto de 1 o 2, el asiento se descarta SILENCIOSAMENTE — no se generan errores explícitos. Este comportamiento puede causar que movimientos contabilizados no aparezcan en el cuadre si el catálogo tiene entradas inválidas.

**Trigger:** Resultado de lookup ESQCON en 21121 con W77-IND3 > 0

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-EQ-NAT-MOV` | PIC 9(1) | 1=débito, 2=crédito, otro=inválido |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21121 · Líneas: ~10910
IF WKS-EQ-NAT-MOV = 1 OR 2 → genera asiento
ELSE → descarte silencioso (sin WRITE, sin error)
```

**Riesgos de migración:**
- Las entradas inválidas del ESQCON son invisibles en el legacy — el nuevo sistema debe implementar alertas explícitas para este caso

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-EQ-NAT-MOV` | WSR-RCC-NAT-MOV | CAMPO-NUM | inc-p109 | Naturaleza del movimiento (1 dígito) para el reporte RCC. Indica si el movimiento es débito (cargo) o crédito (abono). |
| `ARCH-ESQCON` | A00-R01-ESQCON | CAMPO-COMP | inc-p052 | Código del esquema de contabilización aplicado para generar el asiento contable en el GL de S151. |

**Estado validación:** pendiente HITL

---

### RN-S151-052 — S087 fuerza PRODUCTO=087 en MOVCONTABLES

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-052 |
| **Nombre** | S087 fuerza PRODUCTO=087 en MOVCONTABLES |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Para S087 (cheques), independientemente del producto del movimiento original, P109 fuerza: `MOVE 087 TO RMC-PRODUCTO`. Asegura que todos los asientos GL de cheques se acumulen bajo producto 087, consolidando la posición de cheques en una sola dimensión.

**Trigger:** Generación de asiento GL con W77-SISTEMA-PARAMETRO=087

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `RMC-PRODUCTO` | PIC 9(3) | Dimensión producto en asiento GL |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21121 · Líneas: ~10900
IF W77-SISTEMA-PARAMETRO = 087 → MOVE 087 TO RMC-PRODUCTO
```

**Riesgos de migración:**
- El override de producto para cheques debe documentarse como regla explícita en el nuevo sistema

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `RMC-PRODUCTO` | A00-R01-PRODUCTO-S016 | CAMPO-COMP | inc-p052 | Código del producto bancario S016 asociado al movimiento contable. (Más cercano encontrado) |
| S087 (sistema) | ETL-LTL | ENTIDAD | dominio | Logs de la interfaz ETL en S151 — P109 declara LOG151-ETL para registrar el procesamiento de carga de sistemas externos (como S087). |

**Estado validación:** pendiente HITL

---

### RN-S151-053 — MOVCONTASORT: 11 dimensiones como granularidad mínima GL

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-053 |
| **Nombre** | MOVCONTASORT: 11 dimensiones como granularidad mínima GL |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — modelo dimensional GL |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** El SORT de SMOVCONTASORT en 11 dimensiones (FILIAL, ORIGEN, MONEDA, BANCO, SUC-PROM, FECVEN, PRODUCTO, INSTRUMENTO, SECTOR, CVETRAN, ESQCON) define la granularidad de acumulación. Dos movimientos con diferencia en cualquier dimensión producen asientos separados; coincidencia en todas → se acumulan. Esta clave es la representación canónica del modelo dimensional GL de Banamex S151.

**Trigger:** Inicio de proceso de acumulación MOVCONTASORT

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `SMS-FILIAL..SMS-ESQCON` | varios | 11 dimensiones de llave GL |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 20000+SORT SMOVCONTASORT · Líneas: ~10200
SORT ON ASCENDING: SMS-FILIAL, SMS-ORIGEN, SMS-MONEDA, SMS-BANCO, SMS-SUC-PROM,
                   SMS-FECVEN, SMS-PRODUCTO, SMS-INSTRUMENTO, SMS-SECTOR, SMS-CVETRAN, SMS-ESQCON
```

**Riesgos de migración:**
- El nuevo GL debe soportar exactamente estas 11 dimensiones — agregar o quitar dimensiones cambia la granularidad y rompe el cuadre

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `MOVCONTASORT` (archivo sort) | — | — | — | no encontrado en vocab-s151.md |
| `SMS-FILIAL..SMS-ESQCON` (11 campos) | — | — | — | no encontrados en vocab-s151.md (campos de sort intermedios) |
| Dimensiones canónicas | A00-R01-ORIGEN | CAMPO-COMP | inc-p052 | ORIGEN: código de 2 dígitos del sistema de origen del movimiento GL. |
| Dimensiones canónicas | A00-R01-CVETRAN | CAMPO-COMP | inc-p052 | CVETRAN: clave de 6 dígitos que identifica el tipo de operación contable. |
| Dimensiones canónicas | A00-R01-ESQCON | CAMPO-COMP | inc-p052 | ESQCON: código del esquema de contabilización aplicado. |

**Estado validación:** pendiente HITL

---

### RN-S151-054 — Cálculo de siguiente/anterior día hábil via THECALENDAR

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-054 |
| **Nombre** | Cálculo de siguiente/anterior día hábil via THECALENDAR |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Cálculo |
| **Tipo técnico** | [REGLA-BANCARIA-MX] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | Banxico — calendario de días hábiles bancarios |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 usa la librería externa `THECALENDAR IN LOCSUP` para: (1) calcular el siguiente día hábil al de proceso (WKS-FUNCION=15, semilla "00000001"), y (2) determinar el día anterior para la semilla de posición. El formato 13 es Cronos 2000 (Y2K). Esta librería maneja el calendario bancario mexicano incluyendo festivos Banxico.

**Trigger:** 10000-INICIO-PROGRAMA (siguiente día) y 50000-POSICION (día anterior)

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-FUNCION` | PIC 9(2) | 15=calcular día hábil siguiente/anterior |
| `WKS-FORMATO` | PIC 9(2) | 13=Cronos 2000 |
| `WKS-FECHA2` | "00000001" | Semilla: avanzar 1 día hábil |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 10000 y 50000
CALL "THECALENDAR" USING WKS-FUNCION=15, WKS-FECHA1, WKS-FECHA2="00000001", WKS-FORMATO=13
```

**Riesgos de migración:**
- La librería THECALENDAR es Unisys MCP — debe reemplazarse por un servicio de calendario bancario en el nuevo sistema que maneje los mismos festivos Banxico

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `THECALENDAR` (librería) | — | — | — | no encontrado en vocab-s151.md (librería Unisys externa) |
| `WKS-FECHA-PROCESO` | WKS-FECHA-PROCESO | CAMPO-NUM | inc-p052 | Fecha del proceso batch del GL (formato AAAAMMDD, 8 dígitos); fecha de ejecución del proceso nocturno de movimientos contables de S151. |
| `WKS-FECHA-PROCESO-HABIL` | WKS-FECHA-PROCESO-HABIL | CAMPO-NUM | inc-pro | Fecha del proceso hábil en formato AAAAMMDD; fecha del día hábil de proceso contable, excluyendo feriados y fines de semana. |

**Estado validación:** pendiente HITL

---

### RN-S151-055 — Renombrado dinámico de SALDOSDB via CHANGE ATTRIBUTE TITLE

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-055 |
| **Nombre** | Renombrado dinámico de SALDOSDB via CHANGE ATTRIBUTE TITLE |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — multi-instancia MCP |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 usa el mecanismo Unisys MCP `CHANGE ATTRIBUTE TITLE OF SALDOSDB TO WKS-NOMBRE-BASE-SALDOS` para cambiar en runtime el nombre físico de la base de datos de posición. El nombre se construye desde `WKS-B03-NOMBDSAL` (parámetro de configuración). Permite acceder a diferentes instancias (por CSI, por ambiente) sin recompilar.

**Trigger:** Inicio de 50000-POSICION

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-B03-NOMBDSAL` | ALPHA | Nombre configurado de la BD de saldos |
| `WKS-NOMBRE-BASE-SALDOS` | ALPHA | Nombre efectivo en runtime |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 50000 · Líneas: ~16213
CHANGE ATTRIBUTE TITLE OF SALDOSDB TO WKS-NOMBRE-BASE-SALDOS
```

**Riesgos de migración:**
- Este mecanismo Unisys no existe en Java/SQL — debe reemplazarse por configuración de datasource dinámica

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `SALDOSDB` (BD DMSII) | — | — | — | no encontrado en vocab-s151.md como entidad independiente |
| `WKS-B03-NOMBDSAL` | WKS-B03-NOMBDSAL | CAMPO-ALFA | inc-p052 | Nombre de la base de datos de saldos en el bloque B03 (17 chars). Nombre literal de la BD DMSII de saldos (BD11SDOS151) para apertura del set. |
| `WKS-NOMBRE-BASE-SALDOS` | WKS-NOMBRE-BASE-SALDOS | GRUPO | inc-p109 | Grupo de estructura que contiene el nombre efectivo de la base de saldos en runtime (nivel bajo). |

**Estado validación:** pendiente HITL

---

### RN-S151-056 — WKS-TIPO-CAT=2 activa ruta alternativa de lookup CAT7

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-056 |
| **Nombre** | WKS-TIPO-CAT=2 activa ruta alternativa de lookup CAT7 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Habilitación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** La sección 21120 tiene bifurcación: `IF WKS-TIPO-CAT = 2` → ruta directa a CAT7 sin tabla en memoria WKS-PT-INDS250; para otros valores, primero verifica la tabla INDS250. El tipo 2 corresponde a un formato de catálogo diferente donde la agrupación contable se obtiene directamente de la CVETRAN.

**Trigger:** Procesamiento de MOVCONTASORT en 21120

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `WKS-TIPO-CAT` | PIC 9(1) | Tipo de catálogo ESQCON (2=directo) |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21120 · Líneas: ~10807
IF WKS-TIPO-CAT = 2 → CAT7 directo (sin INDS250)
ELSE → check WKS-PT-INDS250 → CAT7 → ARCH-ESQCON
```

**Riesgos de migración:**
- El servicio de resolución de cuentas del nuevo sistema debe soportar ambas rutas del catálogo

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `WKS-TIPO-CAT` | WKS-TIPO-CAT | CAMPO-NUM | inc-p109 | Código de categoría del tipo de proceso del GL, inicializado en cero (9(04), valor=0, nivel 1, P109). |
| `ARCH-CAT7` (ruta directa) | WKS-SIS-CAT7 | CAMPO-NUM | inc-p109 | Código del sistema para la categoría 7 del plan de cuentas GL (3 dígitos); identifica el sistema que gestiona los movimientos de la categoría contable 7. |

**Estado validación:** pendiente HITL

---

### RN-S151-057 — MOVCONTABLES: output canónico del motor GL

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-057 |
| **Nombre** | MOVCONTABLES: output canónico del motor GL |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — registro definitivo de asientos GL |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** MOVCONTABLES es el output definitivo de P109. Cada registro contiene: FILIAL, PRODUCTO, INSTRUMENTO, SUC-PROM, MONEDA, CTA-CONT (PIC 9(12)), IMPORTE (PIC 9(14)V99), TIPO-MOV, NAT-MOV (1=débito/2=crédito), FOLIO, SECTOR, ACTIVIDAD, BANCA, CAUSA, ORIGEN, AUT-S151, CVETRAN, BANCO. Es el input de la sección 40000 (cuadre) y de todos los procesos downstream. La combinación TIPO-MOV + NAT-MOV + CTA-CONT + IMPORTE es la partida doble mínima.

**Trigger:** Resultado exitoso de 21121-MUEVE-CUENTAS-CONTABLES

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `RMC-CTA-CONT` | PIC 9(12) | Cuenta GL destino |
| `RMC-IMPORTE` | PIC 9(14)V99 | Importe del asiento |
| `RMC-NAT-MOV` | PIC 9(1) | 1=débito, 2=crédito |
| `RMC-TIPO-MOV` | PIC 9(n) | Tipo de movimiento |
| `RMC-CAUSA` | PIC 9(n) | Causa/concepto del asiento |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 21118-GRABA-MOVCONT / 21120 · Líneas: ~10787-10810
WRITE REG-MOVCONTABLES con todos los campos canónicos
```

**Riesgos de migración:**
- [RIESGO-EQUIVALENCIA]: MOVCONTABLES es el contrato de equivalencia — el nuevo sistema debe producir exactamente los mismos campos con los mismos valores

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `REG-MOVCONTABLES` | REG-MOVCONTABLESP | GRUPO | inc-pro | Estructura del registro de movimientos contables (variante P; nivel bajo). |
| `RMC-CTA-CONT` | WSR-RMC-CTA-CONT | CAMPO-EDICION | inc-pro | Número de cuenta contable del Registro de Movimientos Contables (RMC) formateado para edición/impresión. Edición Z(12), 12 dígitos con supresión de ceros. |
| `RMC-IMPORTE` | WKS-TCP-CARGOS / WKS-TCP-ABONOS | CAMPO-COMP | inc-p109 | Acumuladores de importe por período: cargos y abonos firmados (S9(16)V99). Representan el importe acumulado en MOVCONTABLES. |
| `RMC-NAT-MOV` | WSR-RCC-NAT-MOV | CAMPO-NUM | inc-p109 | Naturaleza del movimiento (1 dígito) para el reporte RCC: débito o crédito. |
| `RMC-TIPO-MOV` | — | — | — | no encontrado en vocab-s151.md |
| `RMC-CAUSA` | — | — | — | no encontrado en vocab-s151.md |

**Estado validación:** pendiente HITL

---

### RN-S151-058 — POSICION: upsert (LOCK falla → CREATE nuevo registro)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-058 |
| **Nombre** | POSICION: upsert (LOCK falla → CREATE nuevo registro) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Derivación |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Dentro de 54000, cuando `LOCK B72SXPOSCONTA` falla con EXCEPTION (llave no existe), P109 ejecuta `CREATE S151B72POSCONTA` en lugar de reportar error. Maneja el caso de combinaciones nuevas (banco/producto/instrumento/cuenta/causa/sector) que no tenían posición en el día anterior. El CREATE inicializa con las llaves del movimiento y SDOANT=0.

**Trigger:** ON EXCEPTION de LOCK B72SXPOSCONTA en 54000

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `B72-SDO-KEYBCO` | PIC 9(n) | Llave banco |
| `B72-SDO-KEYPRD` | PIC 9(n) | Llave producto |
| `B72-SDO-KEYINS` | PIC 9(n) | Llave instrumento |
| `B72-SDO-KEYCTA` | PIC 9(n) | Llave cuenta GL |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 54000 · Líneas: ~16701-16709
LOCK B72SXPOSCONTA → ON EXCEPTION → CREATE S151B72POSCONTA (SDOANT=0)
```

**Riesgos de migración:**
- El nuevo sistema debe implementar upsert transaccional equivalente — no un INSERT que falla si ya existe

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `B72-SDO-KEYBCO` | — | — | — | no encontrado en vocab-s151.md |
| `B72-SDO-KEYPRD` | — | — | — | no encontrado en vocab-s151.md |
| `B72-SDO-KEYINS` | — | — | — | no encontrado en vocab-s151.md |
| `B72-SDO-KEYCTA` | — | — | — | no encontrado en vocab-s151.md |
| POSICION (entidad) | POSICION | ENTIDAD | dominio | Dataset B02POSICION de BD13BIFIN. Posición financiera por sistema. Clave: SISTEMA+CSI+FECHA+PRODUCTO+INSTSERV+MONEDA. |

**Nota:** Los campos de llave del set B72 (B72-SDO-KEY*) son campos DASDL directos sin entrada vocab independiente; la entidad POSICION cubre la estructura conceptual.

**Estado validación:** pendiente HITL

---

### RN-S151-059 — Sort MOVCONTABLES por TIPO-MOV y NAT-MOV antes del cuadre

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-059 |
| **Nombre** | Sort MOVCONTABLES por TIPO-MOV y NAT-MOV antes del cuadre |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Clasificación / Mapeo |
| **Tipo técnico** | [LÓGICA-CONTABLE] |
| **Confianza** | alta |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** Antes de la sección 40000, MOVCONTABLES se ordena con claves primarias `SRMC-TIPO-MOV` y `SRMC-NAT-MOV`. El cuadre contable está organizado primero por tipo de movimiento y luego por naturaleza (débito/crédito), agrupando asientos de la misma naturaleza para facilitar la verificación de balance.

**Trigger:** Inicio de 40000-GENERA-CUADRE-CONTABLE

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| `SRMC-TIPO-MOV` | PIC 9(n) | Clave primaria de sort |
| `SRMC-NAT-MOV` | PIC 9(1) | Clave secundaria de sort |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: 40000 · Líneas: ~14512
SORT S250 ON ASCENDING KEY SRMC-TIPO-MOV, SRMC-NAT-MOV (+ dimensiones adicionales)
```

**Riesgos de migración:**
- El orden de presentación del cuadre debe replicarse para que operaciones valide de la misma manera

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `SRMC-TIPO-MOV` | — | — | — | no encontrado en vocab-s151.md (campo de sort intermedio con prefijo SRMC) |
| `SRMC-NAT-MOV` | WSR-RCC-NAT-MOV | CAMPO-NUM | inc-p109 | Naturaleza del movimiento (1 dígito): débito o crédito. (Equivalente semántico sin prefijo SRMC) |

**Estado validación:** pendiente HITL

---

### RN-S151-060 — Integración CIG/SCIG: frontera Citi-Banamex

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-060 |
| **Nombre** | Integración CIG/SCIG: frontera Citi-Banamex |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Definición |
| **Tipo técnico** | [LÓGICA-CONTABLE] [RIESGO-EQUIVALENCIA] |
| **Confianza** | media |
| **Veredicto** | VALIDADO (analista dt-mainframe-analyst) |
| **Regulador** | N/A — reporting intercompany Citi |
| **Programa ejecutor** | P109 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Descripción:** P109 genera el archivo SCIG (transmisión hacia CIG — Central Integrated General Ledger de Citi) con los asientos consolidados en formato de transmisión intercompany. Este archivo cruza la frontera Citi/Banamex y es crítico en el contexto de la separación corporativa: la migración de S151 debe mantener la producción del SCIG o reemplazarlo con un mecanismo equivalente hacia el nuevo sistema de contabilidad corporativa.

**Trigger:** Fase de outputs finales de P109 (condicional por sistema)

**Campos involucrados:**

| Campo COBOL | Tipo | Rol |
|-------------|------|-----|
| archivo SCIG | file | Output intercompany hacia CIG Citi |

**Traza de código:**
```
PROGRAMA: P109 · SECCIÓN: outputs finales
Sistemas que generan SCIG → WRITE SCIG con asientos en formato transmisión CIG
```

**Riesgos de migración:**
- [RIESGO-EQUIVALENCIA]: Si la separación Citi-Banamex elimina el canal CIG, todos los asientos que hoy van a SCIG deben redirigirse al nuevo sistema de contabilidad corporativa de Banamex
- La ausencia de SCIG puede ser una hallazgo en auditoría Citi hasta que la separación esté formalizada

**Vocabulario en la fórmula:**

| Término COBOL | Término vocab | Categoría | Alcance | Significado (vocab) |
|---------------|---------------|-----------|---------|---------------------|
| `SCIG` (archivo salida) | WKS-TIT-MOVSCIG | GRUPO | inc-p109 | Grupo de título/cabecera de movimientos SCIG en P109 (estructura presentación). |
| CIG (sistema Citi) | WKS-HEADER-CIG | GRUPO | inc-p109 | Estructura de encabezado del archivo CIG (Central Integrated General Ledger). |
| CIG (sistema Citi) | WKS-TRAILER-CIG | GRUPO | inc-p109 | Estructura de trailer/cierre del archivo CIG. |
| CIG (sistema Citi) | WKS-HD264-CIG | GRUPO | inc-p109 | Grupo de encabezado CIG específico para movimientos S264 (SPEI). |
| CIG (sistema Citi) | WKS-HDNF-CIG | GRUPO | inc-p109 | Grupo de encabezado CIG para movimientos NF (no financieros). |
| CIG (sistema Citi) | WKS-TR264-CIG | GRUPO | inc-p109 | Grupo de trailer CIG específico para movimientos S264. |
| CIG (sistema Citi) | WKS-TRNF-CIG | GRUPO | inc-p109 | Grupo de trailer CIG para movimientos NF. |
| CIG (sistema Citi) | WKS-TIT-MOVSCIGNF | GRUPO | inc-p109 | Grupo de título de movimientos SCIG no financieros. |
| CIG (sistema Citi) | WKS-TIT-MOVSCIGS264MN | GRUPO | inc-p109 | Grupo de título de movimientos SCIG sistema S264 moneda nacional. |

**Estado validación:** pendiente HITL

---

## Cola de validación HITL

| ID regla | Motivo de escalación | Asignado a | Estado |
|----------|---------------------|-----------|--------|
| RN-S151-027 | Fallback prefijo 5 — validar con equipo contable | Contador Bancario SME | pendiente |
| RN-S151-028 | Exclusión cuenta 1503 — confirmar si aplica en nuevo catálogo | Contador Bancario SME | pendiente |
| RN-S151-041 | Sectores CNBV hardcoded (31, 32) — confirmar vigencia | Regulatorio CNBV SME | pendiente |
| RN-S151-060 | Separación CIG/SCIG — impacto en separación Citi-Banamex | Architecture + Legal | pendiente |

---

## Vocabulario global P109

> **Fuente:** `rules-s151-p109-vocab-enrichment.md` · Swarm Specialist - Business Rules · 2026-07-16
> **Método:** Grep sistemático por campo COBOL de "Campos involucrados" en cada regla contra `vocab-s151.md` (GemCog Capa 1 v3.2)

### Leyenda de columnas vocab

| Columna | Valores posibles |
|---------|-----------------|
| Categoría | CAMPO-COMP · CAMPO-NUM · CAMPO-ALFA · CAMPO-DECIMAL · CAMPO-EDICION · ENTIDAD · GRUPO · ACCION · COPY |
| Alcance | inc-p109 · inc-p052 · inc-pro · dominio · patron-unisys · bcop-cruzada |
| Confianza vocab | alta · media · baja |

---

### Resumen de cobertura vocab por regla (P109)

| Regla | Campos regla | Encontrados en vocab | No encontrados | Cobertura |
|-------|-------------|----------------------|----------------|-----------|
| RN-S151-021 | 3 | 2 | 1 (LOG151 como archivo) | 67% |
| RN-S151-022 | 2 | 1 | 1 (W77-EOF) | 50% |
| RN-S151-023 | 3 | 2 | 1 (GRABA-PUNTEO párrafo) | 67% |
| RN-S151-024 | 3 grupos×5 | CVETRAN1..5 ✓, ESQCON1..5 ✓, IMPORTE1..5 ✗ | IMPORTE1..5 | 67% |
| RN-S151-025 | 8 | 5 | 3 (W77-IND4, WKS-EQ-CUENTA exacto) | 63% |
| RN-S151-026 | 2 | 2 | 0 | 100% |
| RN-S151-027 | 1 | 0 (solo equivalente) | 1 | 0% |
| RN-S151-028 | 3 | 2 | 1 (WS-CTA4-250-ANT) | 67% |
| RN-S151-029 | 1 | 0 (solo contexto CSI) | 1 | 0% |
| RN-S151-030 | 2 | 2 | 0 | 100% |
| RN-S151-031 | 11 | 3 (ORIGEN, CVETRAN, ESQCON) | 8 (FILIAL, MONEDA, BANCO, SUC-PROM, FECVEN, PRODUCTO-SMS, INSTRUMENTO-SMS, SECTOR) | 27% |
| RN-S151-032 | 1 | 1 | 0 | 100% |
| RN-S151-033 | 2 | 1 | 1 (S016-CTO-INST) | 50% |
| RN-S151-034 | 2 | 0 (S264 sí, campos exactos no) | 2 | 0% |
| RN-S151-035 | 2 | 2 | 0 | 100% |
| RN-S151-036 | 2 | 2 | 0 | 100% |
| RN-S151-037 | 2 | 1 | 1 (DATALAKE archivo) | 50% |
| RN-S151-038 | 2 | 1 | 1 (A00-R01-S250-CAR) | 50% |
| RN-S151-039 | 4 | 4 | 0 | 100% |
| RN-S151-040 | 4 | 2 (equivalentes semánticos) | 2 (B72 directos) | 50% |
| RN-S151-041 | 2 | 1 | 1 (W77-SEC-SORT) | 50% |
| RN-S151-042 | 1 | 1 | 0 | 100% |
| RN-S151-043 | 3 | 0 | 3 (S701 tablas) | 0% |
| RN-S151-044 | 3 | 2 (equiv.) | 1 (POSICIONDIAANT) | 67% |
| RN-S151-045 | 2 | 1 (parcial) | 1 (POSGLOBAL archivo) | 50% |
| RN-S151-046 | 1 | 0 | 1 (B72-SDO-KEYFID) | 0% |
| RN-S151-047 | 2 | 2 | 0 | 100% |
| RN-S151-048 | 2 | 2 | 0 | 100% |
| RN-S151-049 | 2 | 1 | 1 (A00-R01-BCOS, RMS-BANCO) | 50% |
| RN-S151-050 | 1 | 1 | 0 | 100% |
| RN-S151-051 | 2 | 2 | 0 | 100% |
| RN-S151-052 | 1 | 1 (equiv.) | 0 | 100% |
| RN-S151-053 | 11+archivo | 3 (equiv.) | 9 | 27% |
| RN-S151-054 | 2 | 2 | 1 (THECALENDAR) | 67% |
| RN-S151-055 | 2 | 2 | 1 (SALDOSDB archivo) | 67% |
| RN-S151-056 | 2 | 2 | 0 | 100% |
| RN-S151-057 | 5 | 3 | 2 (TIPO-MOV, CAUSA) | 60% |
| RN-S151-058 | 4 | 0 (solo entidad padre) | 4 (B72 llaves) | 0% |
| RN-S151-059 | 2 | 1 | 1 (SRMC-TIPO-MOV) | 50% |
| RN-S151-060 | 1 archivo | 9 grupos CIG/SCIG | 0 (SCIG como entidad standalone) | 90% |

---

### Campos no encontrados — candidatos para Capa 2 vocab

Los siguientes campos aparecen en reglas P109 pero no tienen entrada en vocab-s151.md. Son candidatos para enriquecimiento en la siguiente iteración del Gemelo Cognitivo:

| Campo | Regla(s) | Tipo probable | Comentario |
|-------|----------|---------------|------------|
| `W77-EOF` | RN-022 | flag COMP | Bandera de fin de loop, típicamente 77-level |
| `GRABA-PUNTEO` | RN-023, RN-048 | párrafo/sección | Es un párrafo de código, no campo de datos |
| `W77-IND4` | RN-025 | índice COMP | Par de W77-IND3 |
| `WKS-EQ-CUENTA` exacto | RN-025 | CAMPO-COMP | Posible alias de WKS-CTA-CONT-ACT |
| `RMC-CTA1-CONT` | RN-027 | CAMPO-COMP | Dígito 1 de cuenta GL en registro MC |
| `WS-CTA4-250-ANT` | RN-028 | CAMPO-COMP/NUM | Prefijo cuenta 4 dígitos |
| `W77-CSI-PROCESO` | RN-029 | CAMPO-NUM | CSI efectivo de proceso (2 dígitos) |
| `W77-NUMREG-LOG` | RN-030 | CAMPO-COMP | Contador de registros LOG S016 |
| `SMS-FILIAL..SMS-ESQCON` (11) | RN-031, RN-053 | CAMPO-COMP | Campos de clave sort SMOVCONTASORT |
| `S016-CTO-INST` | RN-033 | CAMPO-NUM | Código contrato S016 para instrumento cheque |
| `A00-R01-MONEDA` exacto | RN-034 | CAMPO-COMP | Código de moneda en R01 |
| `RMS-BANCO` | RN-034, RN-049 | CAMPO-COMP | Dimensión banco en registro MOVCONTASORT |
| `DATALAKE` (archivo) | RN-037 | archivo | Output SPEI hacia data lake |
| `A00-R01-S250-CAR` | RN-038 | CAMPO-DECIMAL | Cargos en reporte cuadre (signo negativo) |
| `W77-SEC-SORT` | RN-041 | CAMPO-NUM | Sector para acumulación GL |
| `WKS-EQ-CUENTA1/2/3-S701` | RN-043 | CAMPO-NUM | Cuentas GL específicas Hacienda |
| `POSICIONDIAANT` (archivo) | RN-044 | archivo/entidad | Posición del día anterior (semilla) |
| `RPDA-SDOANT` | RN-044 | CAMPO-DECIMAL | Semilla saldo anterior para nuevo día |
| `POSGLOBAL` (archivo) | RN-045 | archivo | Posición global por subcuenta |
| `B72-SDO-KEYFID` | RN-046 | CAMPO-COMP | Llave fideicomiso (siempre 0) |
| `W88-SIST-CEN-CONTABLE` | RN-047 | flag | Indicador contabilidad central |
| `A00-R01-BCOS` | RN-049 | CAMPO-COMP | Banco genérico en R01 |
| `RMC-TIPO-MOV` | RN-057, RN-059 | CAMPO-NUM | Tipo de movimiento en MOVCONTABLES |
| `RMC-CAUSA` | RN-057 | CAMPO-NUM | Causa/concepto del asiento |
| `SRMC-TIPO-MOV` | RN-059 | CAMPO-COMP | Clave sort primaria MOVCONTABLES |
| `MOVCONTASORT` (archivo) | RN-053 | archivo sort | Archivo sort intermedio GL |
| `THECALENDAR` | RN-054 | librería Unisys | Calendar lib MCP (externo, no campo) |
| `SALDOSDB` | RN-055 | BD DMSII | Base de datos de posición (renombrado dinámico) |
| `B72-SDO-KEY*` (4 campos) | RN-058 | CAMPO-COMP | Llaves del set DMS B72SXPOSCONTA |

# Reglas de Negocio — P151 (Transformador IBM-Citibank ALR/AHR/OCM)
> **Capacidad bancaria:** 6.7.1 Financial Reconciliation · Interfaz IBM-Citibank (ALR/AHR/OCM)
> **Programa fuente:** COBOL_P151.txt · Autor: ING. JAVIER MERCADO FLORES
> **Frecuencia:** cierre-diario
> **Sistemas downstream:** ARCH-ALR · ARCH-AHR · ARCH-OCM · MOVSCIG · PUNTEO (ARCH-SAL)
> **Rango:** RN-S151-331 a RN-S151-360 (30 reglas)
> **Actualizado:** 2026-07-16
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

---

## RN-S151-331

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-331 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Sistema ≠ 500/701 no tiene lógica activa — programa termina sin generar archivos.
**Estado validación:** Verificado en PROCEDURE DIVISION línea 12483.

---

## RN-S151-332

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-332 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** IND-SIS=0 excluye el movimiento de todos los archivos Citi.
**Estado validación:** Verificado en paragraphs 41000-GRABA-ARCHIVOS-CITI líneas 14268-14392.

---

## RN-S151-333

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-333 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Subnodo sin mapping a región conocida fallará silenciosamente — movimiento perdido.
**Estado validación:** Verificado en FD declarations líneas 1082-1199.

---

## RN-S151-334

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-334 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Sin W88-HOSTNAME verdadero, los archivos BNE no se generan — downstream BNE queda sin datos.
**Estado validación:** Verificado en líneas 14218-14223 y comentarios ISILOA.

---

## RN-S151-335

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-335 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** BRCH-NBR siempre es 485 (hardcode) — no varía por sucursal real.
**Estado validación:** Verificado en FD ARCH-ALR líneas 764-822 y lógica 14268-14330.

---

## RN-S151-336

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-336 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Reconciliación por CURRENT-NO en IBM no tiene correspondencia directa con AUTS151 de BD10.
**Estado validación:** Verificado en código comentado líneas 14285-14286.

---

## RN-S151-337

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-337 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Los tres formatos de signo son distintos — inconsistencia al reconciliar entre ALR, AHR y OCM.
**Estado validación:** Verificado en lógica de escritura de los tres archivos.

---

## RN-S151-338

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-338 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** RFC en AHR es X(20) mientras que en REG-MOVIMIENTOS es X(13)/X(18) — requiere padding en mapeo.
**Estado validación:** Verificado en FD ARCH-AHR líneas 992-1077 con marcadores AHM INI/FIN.

---

## RN-S151-339

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-339 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Fallo en validación SAT puede dejar campos vacíos en AHR, generando rechazo en IBM.
**Estado validación:** Verificado en líneas 14372-14374.

---

## RN-S151-340

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-340 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** REVRS-IND=SPACE inicializado explícitamente — no usar el valor de memoria anterior.
**Estado validación:** Verificado en líneas 14315/14363 y estructura AHRST-REC.

---

## RN-S151-341

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-341 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** COUNTER-OCM reinicia cada ejecución — no es correlativo cross-day.
**Estado validación:** Verificado en líneas 14393-14418.

---

## RN-S151-342

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-342 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Campos 2..10 en ceros — si IBM espera múltiples cheques, la lógica de lectura downstream los ignorará.
**Estado validación:** Verificado en líneas 14422-14453.

---

## RN-S151-343

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-343 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** LEYENDA de solo 1 (vs 5 del registro principal) — movimientos con LEY2-5 las pierden en el archivo Citi.
**Estado validación:** Verificado en SD SMOVTOS-CITICTD línea 729.

---

## RN-S151-344

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-344 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** La doble carga de catálogos (500 y 408) implica que sistema 408 es un alias de 500 para catalogación.
**Estado validación:** Verificado en líneas 12575-12584.

---

## RN-S151-345

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-345 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Contrato sin registro en ARCH-SAL falla el lookup RANDOM — requiere inicialización previa.
**Estado validación:** Verificado en WKS-TIT-SALS500 línea 615 y análisis de FILE-CONTROL.

---

## RN-S151-346

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-346 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Close sin WKS-CIERRA-DESC correcto puede dejar el LOG en estado inconsistente.
**Estado validación:** Verificado en WKS-TIT-LOG151-COMP líneas 465-473.

---

## RN-S151-347

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-347 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Un RFC de persona física es X(13) con posición 10-13 libre — no confundir con RFC-BENEF(18).
**Estado validación:** Verificado en estructura REG-MOVIMIENTOS líneas 224-370 y AHR layout.

---

## RN-S151-348

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-348 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Nombre con caracteres especiales (acentos, ñ) puede corromper en sistemas ASCII estrictos.
**Estado validación:** Verificado en campo RM-NOM-BENEF línea 260 (aprox) del DATA DIVISION.

---

## RN-S151-349

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-349 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** NIO numérico con ceros iniciales debe preservarse como ALPHA — conversión numérica elimina ceros.
**Estado validación:** Verificado en RM-NIO en DATA DIVISION y NIO ALPHA(16) en DASDL BD10.

---

## RN-S151-350

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-350 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Combinación SIST-ORIG/CVETRAN sin case definido usa el ELSE por defecto — puede producir líneas vacías.
**Estado validación:** Verificado en 41100-VALIDA-REFERENCIAS-ALR líneas 14464-14509.

---

## RN-S151-351

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-351 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Slots 2-5 pueden estar en ceros si el movimiento solo tiene un importe — no iterar sobre ceros.
**Estado validación:** Verificado en DATA DIVISION REG-MOVIMIENTOS.

---

## RN-S151-352

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-352 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Leyendas con texto en posiciones 36-40 se cortan si solo se usa LEYENDA-35.
**Estado validación:** Verificado en SD SMOVTOS-CITICTD REDEFINES y 41100-VALIDA-REFERENCIAS-ALR.

---

## RN-S151-353

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-353 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Referencia vacía (SPACES) mapeada a TEXT-LINE produce línea en blanco en el ALR.
**Estado validación:** Verificado en DATA DIVISION y 41100-VALIDA-REFERENCIAS-ALR.

---

## RN-S151-354

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-354 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** FORMATO no reconocido puede saltar validaciones SAT, generando AHR con campos vacíos.
**Estado validación:** Campo identificado en DATA DIVISION REG-MOVIMIENTOS.

---

## RN-S151-355

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-355 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Saldo negativo en cuenta de captación puede ser válido (sobregiro autorizado) — no filtrar.
**Estado validación:** Verificado en líneas 14354-14356.

---

## RN-S151-356

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-356 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Cambiar BLOCK sin ajustar receptor en IBM produce errores de lectura en el FTP downstream.
**Estado validación:** Verificado en FD declarations líneas 764, 825, 992.

---

## RN-S151-357

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-357 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si P940 falla (red, credenciales), los archivos quedan en /CO/ sin transferir — P151 no detecta este error.
**Estado validación:** Verificado en líneas 12605-12612.

---

## RN-S151-358

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-358 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Si HR-REAL > HOROPER, el movimiento fue capturado fuera de horario — puede afectar el sort por hora.
**Estado validación:** Verificado en SD SMOVTOS-VIVOSCTD y PERFORM 51000/71000.

---

## RN-S151-359

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-359 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Zeroing del importe en ciertas comisiones significa que no se reporta el monto al archivo Citi.
**Estado validación:** Verificado en líneas 14250-14253.

---

## RN-S151-360

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-360 |
| **Nombre** |  |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-13 |
| **bian_ref** | 7.1.1 |
| **Tipo regla** | Restricción |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | VALIDADO (analista · SBVR heurístico) |
| **Regulador** | — |
| **Programa ejecutor** | p151 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones:** Movimientos no contables (IND-CONTA=0) en ALR pueden generar diferencias de cuadre con el libro mayor.
**Estado validación:** Verificado en DATA DIVISION RM-IND-CONTA y WKS-SORT-REG campo INDCTACON-SUBC.

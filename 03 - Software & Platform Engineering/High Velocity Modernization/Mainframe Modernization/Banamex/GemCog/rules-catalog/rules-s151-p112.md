# Reglas P112 — PUNTEO POR CLAVES DE TRANSACCION (con vocabulario)
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

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

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-001 |
| **Nombre** | Validación de sistema en base de control antes de iniciar proceso |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** `W77-RESULT-LIBCON` no tiene entrada directa en vocab-s151.md. El término más cercano es `W77-RESULT-B01` (CAMPO-NUM, Efimero): "Código de resultado de la operación B01 (8 dígitos). Variable de trabajo nivel 77 que almacena el código de retorno de la llamada al servicio B01."

**Excepciones documentadas:**
- Si LIBCONTROL no responde (BD99CONTROL no disponible), el proceso puede quedar esperando indefinidamente — no hay timeout documentado en el código.
- WKS-PARAM-SIS = 0 (valor por defecto no inicializado) puede o no existir en BD99CONTROL según el ambiente; el resultado es impredecible.

---

## RN-S151-002 — Determinación de fecha de proceso (parámetro vs base de control)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-002 |
| **Nombre** | Determinación de fecha de proceso (parámetro vs base de control) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** `WKS-FECHA-PROCESO` no tiene entrada directa en vocab-s151.md. Ver `WKS-B01-FECPRO151` (CAMPO-NUM, Interfaz-Externo): "Fecha de proceso del sistema S151 en formato AAAAMMDD; fecha contable de proceso utilizada en la mayoría de los programas del S151."

**Excepciones documentadas:**
- Si WKS-PARAM-FCH contiene una fecha inválida (ej: 20260231), el proceso avanza con esa fecha sin validación de rangos — el error se detecta más tarde en el procesamiento contable.
- La conversión a AAMMDD trunca el siglo; si el parche CRONOS2K se aplica a WKS-FPROCESO-A6, un año=50 exacto es interpretado como 2050 (umbral inclusivo ≤50).

---

## RN-S151-003 — Filtro FUNCION=1 AND STATUS=1

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-003 |
| **Nombre** | Filtro FUNCION=1 AND STATUS=1 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Registros con STATUS=0 (nunca procesados) no ingresan al punteo — pérdida silenciosa de movimientos con alta pendiente.
- FUNCION=2 (baja) o FUNCION=3 (modificación) con STATUS=1 son ignorados sin traza, incluso si representan operaciones contables válidas que requieren reconciliación.

---

## RN-S151-004 — Clave sort compuesta 5 dimensiones (LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-004 |
| **Nombre** | Clave sort compuesta 5 dimensiones (LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Movimientos con los 5 campos de clave idénticos pero de distinto tipo de operación se agrupan en el mismo grupo de punteo — posible punteo cruzado no deseado.
- Archivo de entrada vacío (0 registros tras el filtro de RN-S151-003): el SORT no falla pero el reporte queda vacío sin mensaje de advertencia.

---

## RN-S151-005 — S403/S404 FIDEICOMISO como producto

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-005 |
| **Nombre** | S403/S404 FIDEICOMISO como producto |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- A00-R01-FIDEICO = 0 para S403/S404: WKS-RS-NUM-PRODUCTO queda en 0, que puede no tener entrada en ARCH-CAT → brecha de reconciliación silenciosa.
- Si el campo IND-CONTA contiene caracteres parciales que coinciden con 'S403' por truncamiento, la sustitución se aplica incorrectamente a movimientos no fiduciarios.

---

## RN-S151-006 — S087 PRODUCTO hardcoded=87 `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-006 |
| **Nombre** | S087 PRODUCTO hardcoded=87 `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Si S087 agrega nuevos tipos de producto, todos quedan clasificados bajo código 87 sin distinción — brecha de reconciliación invisible hasta la próxima recompilación de P112.
- Si el código 87 es eliminado del catálogo de productos, P112 produce claves KEY-CAT con referencia inválida sin abortar.

---

## RN-S151-007 — Naturaleza S028 por clave (CARGO/ABONO/N/C)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-007 |
| **Nombre** | Naturaleza S028 por clave (CARGO/ABONO/N/C) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Si WKS-PT-NATS028 tiene valor fuera de 1-4 (p.ej. 0 o 5+), el EVALUATE no ejecuta ningún WHEN y WLI-AFECS028 queda con su valor previo (SPACES) — el movimiento se reporta con afectación vacía sin error explícito.
- Código 4 (COMPENSACION → 'COM') suma a ambas naturalezas en algunos contextos de totales — verificar que el comportamiento acumulativo sea intencional.

---

## RN-S151-008 — Gate equivalencia S500↔S151 via INDS151=2 y guía contable `[RIESGO-EQUIVALENCIA]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-008 |
| **Nombre** | Gate equivalencia S500↔S151 via INDS151=2 y guía contable `[RIESGO-EQUIVALENCIA]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** `KEY-CAT` no tiene entrada en vocab-s151.md. Corresponde a la clave compuesta de acceso al catálogo ARCH-CAT (ver RN-S151-009).

**Excepciones documentadas:**
- Si WKS-PT-INDS151 ≠ 2 (p.ej. valor 1 o 3), el movimiento pasa sin punteo ni reporte — no queda traza de cuántos movimientos fueron excluidos por esta condición.
- Si la tabla PT no se cargó (overflow por RN-S151-013), este gate nunca se ejecuta para ningún movimiento del día — toda la reconciliación falla silenciosamente.

---

## RN-S151-009 — Clave compuesta ARCH-CAT con REDEFINES COMP

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-009 |
| **Nombre** | Clave compuesta ARCH-CAT con REDEFINES COMP |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Datos corruptos en cualquier campo COMP de la clave (valores fuera de rango numérico) producen comportamiento impredecible en el acceso binario sin mensaje de error.
- Incremento de dígitos en cualquier campo de la clave requiere recompilación de TODOS los programas que acceden ARCH-CAT — no hay control de versión del layout en tiempo de ejecución.

---

## RN-S151-010 — Normalización MON/LIBRO para S403/S404 en lookup ARCH-CAT

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-010 |
| **Nombre** | Normalización MON/LIBRO para S403/S404 en lookup ARCH-CAT |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Si ARCH-CAT tiene entradas para S403/S404 con MON≠0 o LIBRO≠0, esas entradas quedan inaccesibles porque la clave siempre se normaliza a cero — entradas del catálogo inutilizables.
- La normalización se aplica DESPUÉS de la sustitución de producto (RN-S151-005) pero ANTES del lookup — el orden de estas dos transformaciones es parte de la regla de negocio y debe preservarse.

---

## RN-S151-011 — S264/S703/S018/S017 solo moneda base

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-011 |
| **Nombre** | S264/S703/S018/S017 solo moneda base |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Un movimiento USD de S264 generado por error de captura es rechazado silenciosamente como brecha sin mensaje de error específico — la causa raíz (restricción de moneda) no aparece en el reporte.
- El código interno "01" para MXN difiere del ISO 484 — si el catálogo interno de monedas cambia la codificación, la restricción deja de ser "moneda base" sin ser visible en el código.

---

## RN-S151-012 — Límite 12,000 claves en tablas de leyendas `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-012 |
| **Nombre** | Límite 12,000 claves en tablas de leyendas `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Si el catálogo tiene 11,999 claves y se agregan 2 nuevas en la misma ejecución, el proceso aborta a mitad de la carga del catálogo — ningún movimiento es punteado en ese ciclo.
- El límite está distribuido en 4 tablas (3,000 c/u) — si la distribución entre tablas es desigual, una tabla puede hacer overflow antes de alcanzar el límite global de 12,000.

---

## RN-S151-013 — Límite 9,999 claves en catálogo paramétrico `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-013 |
| **Nombre** | Límite 9,999 claves en catálogo paramétrico `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- El overflow de la tabla PT aborta el proceso antes de puntear cualquier movimiento del día — la reconciliación completa falla sin procesar un solo registro.
- Registros duplicados en el catálogo durante su carga pueden alcanzar el límite 9,999 artificialmente; la tabla PT es volátil y se recarga desde cero en cada ejecución (no hay acumulación entre corridas).

---

## RN-S151-014 — 5 niveles de control break en reporte (LIBRO>PRODUCTO>MONEDA>CVETRAN>ESQCON)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-014 |
| **Nombre** | 5 niveles de control break en reporte (LIBRO>PRODUCTO>MONEDA>CVETRAN>ESQCON) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** `W77-IMPMOV` no tiene entrada en vocab-s151.md. El término más cercano es `W77-NUMMOV` (CAMPO-NUM, Efimero) que comparte el mismo patrón de variable de trabajo nivel-77.

**Excepciones documentadas:**
- Si los datos no están ordenados correctamente (falla en el SORT de RN-S151-004), los totales de control break son incorrectos — el programa no valida el orden de los registros.
- Cambio simultáneo en múltiples niveles (p.ej. nuevo LIBRO también implica nuevo PRODUCTO): los totales deben imprimirse en orden interno→externo; cualquier inversión produce subtotales incompletos sin error.

---

## RN-S151-015 — 12 libros contables hardcoded (incl. FOBAPROA) `[HARDCODE-SOSPECHOSO]` `[REGLA-CNBV]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-015 |
| **Nombre** | 12 libros contables hardcoded (incl. FOBAPROA) `[HARDCODE-SOSPECHOSO]` `[REGLA-CNBV]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** `FOBAPROA` no tiene entrada en vocab-s151.md. Contexto histórico: Fondo Bancario de Protección al Ahorro, rescate bancario 1994-1995, convertido en IPAB en 1999. Su presencia como libro contable activo en P112 indica obligaciones contables residuales.

**Excepciones documentadas:**
- FOBAPROA (residual de 1994-1995) genera movimientos aceptados por el código — si IPAB cancela las obligaciones residuales, esos movimientos quedan huérfanos sin error explícito.
- Un nuevo libro contable regulatorio por reforma CNBV (p.ej. IFRS 17 o nuevo catálogo) no será aceptado hasta recompilación — el regulador puede observar movimientos rechazados sin causa aparente.

---

## RN-S151-016 — S403 fondos+instrumentos hardcoded (FIRA, FONATUR, BANCOMEXT, NAFIN) `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-016 |
| **Nombre** | S403 fondos+instrumentos hardcoded (FIRA, FONATUR, BANCOMEXT, NAFIN) `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

> **Nota:** FIRA, FONATUR, BANCOMEXT y NAFIN no tienen entrada en vocab-s151.md. Son fondos de fomento económico mexicanos bajo supervisión CNBV/Banxico.

**Excepciones documentadas:**
- Un nuevo fondo de fomento bajo S403 (p.ej. por programa gubernamental) tiene sus movimientos rechazados silenciosamente — brecha de reconciliación invisible hasta la próxima recompilación de P112.
- Los rangos de número de fideicomiso por fondo son implícitos en el código — si los rangos se solapan entre fondos, un fideicomiso puede ser aceptado bajo el fondo incorrecto sin error.

---

## RN-S151-017 — S404 9 tipos de producto hardcoded `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-017 |
| **Nombre** | S404 9 tipos de producto hardcoded `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- El rechazo silencioso (PERFORM DESCARTA-SIN-ERROR) hace invisible la brecha S404 en el reporte — no hay contador de descartados por este motivo.
- Un décimo producto S404 por reforma fiduciaria CNBV tiene todos sus movimientos descartados sin aviso — la brecha regulatoria puede acumularse durante semanas antes de ser detectada.

---

## RN-S151-018 — Paginación 50 líneas/hoja y encabezado

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-018 |
| **Nombre** | Paginación 50 líneas/hoja y encabezado |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Si el reporte tiene exactamente 50 líneas, la página siguiente se genera con encabezado pero sin cuerpo — página en blanco al final del reporte.
- WLI-CONTINUA de 12 caracteres es fijo — si el ancho del reporte se modifica en el target, el literal puede quedar desalineado visualmente.

---

## RN-S151-019 — Y2K umbral año 50 para siglo (CRONOS2K) `[HARDCODE-SOSPECHOSO]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-019 |
| **Nombre** | Y2K umbral año 50 para siglo (CRONOS2K) `[HARDCODE-SOSPECHOSO]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Excepciones documentadas:**
- Datos históricos con año > 50 (p.ej. año 95 de 1995) son correctamente interpretados como 1995 — el parche funciona para el rango histórico conocido de Banamex.
- Cualquier dato con año = 51 generado antes de 2051 (error de captura o datos de prueba con fecha futura) será interpretado como 1951 — error silencioso que puede afectar la reconciliación contable.

---

## RN-S151-020 — "REL-TRAN-GUIA CONTABLE INEXISTENTE" — diagnóstico de brecha de reconciliación `[RIESGO-EQUIVALENCIA]`

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S151-020 |
| **Nombre** | "REL-TRAN-GUIA CONTABLE INEXISTENTE" — diagnóstico de brecha de reconciliación `[RIESGO-EQUIVALENCIA]` |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-11 |
| **bian_ref** | 6.7.1 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | — |
| **Confianza** | — |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — |
| **Programa ejecutor** | p112 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

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

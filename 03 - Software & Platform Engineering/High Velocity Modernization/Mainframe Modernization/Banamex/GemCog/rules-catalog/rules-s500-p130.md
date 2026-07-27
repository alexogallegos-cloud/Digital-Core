# Catálogo de Reglas de Negocio — S500 P130 · WFL LINEA
**Indexado:** ✅ 2026-07-17 — correlacionado vocab↔reglas↔capacidad (traceability-matrix.md)

> **Sistema:** S500 — Cargos y Abonos de Cuentas de Cheque · Unisys ClearPath MCP · Banamex
> **Extractor:** Specialist - Business Rules (Digital Core · Gemelo Cognitivo)
> **Wave:** 1 — primer ciclo de extracción en formato canónico v2
> **Numeración:** RN-S500-079 → RN-S500-107 (continúa desde las 78 previas en `rules-report-gemcog.html`)
> **Fuentes primarias:** `S500_SOURCE_P130.txt` (31,762 LOC) · `S500_WFL_LOTE.txt` (contenido real: WFL LINEA, 1,961 LOC) · `vocab-s500-v4.json` (165 términos SME-enriched)
> **Fecha de extracción:** 2026-07-16
> **Estado general:** `[EXTRAÍDA-PENDIENTE-HITL]`

---

## 1. Clasificación P0/P1/P2 — Programas S500

| Programa | LOC est. | Dominio | Prioridad | Rango RN propuesto | Justificación P0 |
|----------|----------|---------|-----------|--------------------|-----------------|
| WFL LOTE | 3,920 | ORQUESTADOR BATCH | **P0** | — (orquestador, reglas en programas invocados) | Raíz de la cadena batch nocturna; 26 salidas directas |
| WFL LINEA | 1,961 | ORQUESTADOR ONLINE | **P0** | RN-S500-104 → 107 | Habilita/deshabilita LINCOMS; calcula flags calendario para todo S500 |
| P010 | 52,656 | GATEWAY TRANSACCIONAL | **P0** | RN-S500-164 → 220 (Wave 2) | Mayor LOC; procesa toda operación online (cargos/abonos en tiempo real); ya tiene 32 reglas en HTML |
| P020 | 44,012 | GATEWAY SECUNDARIO | **P0** | RN-S500-221 → 270 (Wave 3) | Respaldo P010; procesa operaciones cuando P010 no disponible |
| P130 | 31,762 | CAPTACION / RENDIMIENTOS / ISR / COMISIONES | **P0** | RN-S500-079 → 103 (**esta wave**) | Cierre mensual de captación: rendimientos, ISR, comisiones, contabiliza en S151 |
| P142 | 29,138 | CAPTACION / INVERSIONES | **P0** | RN-S500-108 → 140 (Wave 2) | Proceso de instrumentos de inversión (CETES, pagarés, fondos) |
| P144 | 28,994 | CAPTACION / CHEQUES ESPECIALES | **P0** | RN-S500-141 → 163 (Wave 2) | Cheques de caja y certificados; genera asientos Serie R CNBV |
| S151REGISTRA | library | INTEGRACIÓN GL (cross-sistema) | **P0** | RN-S500-271 → 300 (Wave 4) | Interfaz hacia S151; toda contabilidad de S500 pasa por esta librería |
| P103 | 664 | FRAUDE / CONTROL DE ACCESO | **P0** | RN-S500-301 → 315 (Wave 4) | Claves 2001/2444/2496: bloqueo de acceso por fraude; corto pero crítico |
| P330 | 15,642 | CAPTACION / INVERSIONES L.P. | **P1** | RN-S500-316 → 340 (Wave 5) | Inversiones a plazo fijo y largo plazo; depende de P130 para tasas |
| P050 | ~8,000 | CAPTACION / TESORERÍA | **P1** | RN-S500-341 → 360 (Wave 5) | Operaciones de tesorería con captación; no en camino crítico CNBV diario |
| P080 | ~6,000 | CAPTACION / ESPECIALES | **P1** | RN-S500-361 → 375 (Wave 5) | Operaciones especiales corporativas |
| P015 | ~5,000 | CAPTACION / INICIO MES | **P1** | RN-S500-376 → 390 (Wave 5) | Proceso de primer día hábil del mes; habilitado condicionalmente |
| P038 | ~4,000 | CONTROL / REORG | **P2** | Wave 6 | Reorganización de bases DMSII; mantenimiento técnico |
| P091 | ~3,500 | GARBAGE / LIMPIEZA | **P2** | Wave 6 | Limpieza de registros obsoletos en DMSII |
| P093 | ~3,000 | SCRAMBLING / SEGURIDAD | **P2** | Wave 6 | Ofuscación de datos para ambientes no productivos |
| P045 / P046 | ~2,000 | TELETHON (TEMPORAL) | **P2** | Wave 6 | Solo activos durante campaña Telethon; no camino crítico regulatorio |

---

## 2. Reglas Extraídas — P130 (RN-S500-079 a RN-S500-103)

> P130 es el motor de cierre de captación: procesa rendimientos, ISR, comisiones y asientos contables hacia S151 para todas las cuentas de cheque activas. 31,762 LOC. JUNIO/1995, JOSE LUIS IBARRA LARA. Librerías: S151REGISTRA + S151REGISTRA2, S080L100/TARIFAS/IVA, ESQCOMIS, CAPITALIZA, FECHA2000 (CRONOS2K).

---

### RN-S500-079 — Detección del Modo de Proceso Mensual (WKS-ES-MENSUAL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-079 |
| **Nombre** | Detección del Modo de Proceso Mensual (WKS-ES-MENSUAL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[BATCH-SCHEDULING]` `[CIERRE-MENSUAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Art. 2 (periodicidad de reportes Serie R de captación) |
| **Programa ejecutor** | P130 (líneas 3026-3028) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF DIA30 (flag calculado en WFL LINEA = último día hábil del mes):
    WKS-ES-MENSUAL = 1   → activa proceso mensual completo
ELSE:
    WKS-ES-MENSUAL = 0   → proceso diario/periódico ordinario
```

**Vocabulario en la fórmula**
- `WKS-ES-MENSUAL`: flag de proceso mensual (PIC 9(01) COMP); valor 1 = cierre mensual; valor 0 = proceso diario
- `DIA30`: flag booleano calculado por WFL LINEA; representa el último día hábil del mes calendario (no necesariamente el día 30)

**Excepciones documentadas**
- Puede activarse antes del día 30 si el último día hábil del mes es el 28 o 29 por festivos
- Los procesos condicionales de cálculo de tasa promedio (modo IND-RENDDIA=1) solo ejecutan su versión extendida cuando WKS-ES-MENSUAL=1 (ver RN-S500-088)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-080 — Identificador de Asiento GL para S151 (W77-ID-P-S151)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-080 |
| **Nombre** | Identificador de Asiento GL para S151 (W77-ID-P-S151) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[GL-POSTING]` `[CONTABILIDAD]` `[CONTROL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Serie R (identificación de proceso contable en reportes mensuales) |
| **Programa ejecutor** | P130 (líneas 3070-3077 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Inicialización al inicio del proceso:
IF proceso_normal:          W77-ID-P-S151 = 30
IF proceso_alterno:         W77-ID-P-S151 = 31
IF proceso_especial:        W77-ID-P-S151 = 32

-- Uso en cada llamada a S151REGISTRA:
WS-S151-0101-TIPO-PROC-I = W77-ID-P-S151
CALL S151REGISTRA (o S151REGISTRA2) USING WS-S151-0101-...
```

**Vocabulario en la fórmula**
- `W77-ID-P-S151`: identificador de tipo de proceso para S151 (PIC 9(02) COMP); 30=normal, 31=alterno, 32=especial/cancelaciones
- `WS-S151-0101-TIPO-PROC-I`: campo de interfaz de llamada a S151REGISTRA (campo TIPO-PROC-I del paquete 0101)
- `S151REGISTRA1`: variante comentada en `$SET` — desactivada; solo activos `S151REGISTRA` y `S151REGISTRA2`

**Excepciones documentadas**
- S151REGISTRA1 está comentado (`*$SET S151REGISTRA S151REGISTRA1`); su reactivación requería cambio de `$SET` — riesgo de migración si se modifica el mecanismo de selección de librería
- El valor 32 se usa en cancelaciones especiales (transferencias a cuenta global o beneficencia)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-081 — Bypass de Emergencia de Librería S151 (WKS-SIN-LBS151)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-081 |
| **Nombre** | Bypass de Emergencia de Librería S151 (WKS-SIN-LBS151) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[EMERGENCIA]` `[BREAK-GLASS]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — (operacional interno; genera divergencia contable no regulada) |
| **Programa ejecutor** | P130 (línea ~2900 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WKS-SIN-LBS151 = 1:
    OMIT all PERFORM 50116700-LLENA-MOVS-S151 calls
    → No se generan asientos en S151 (GL queda sin movimientos de rendimientos)
ELSE (default = 0):
    Proceso normal con S151REGISTRA activo
```

**Vocabulario en la fórmula**
- `WKS-SIN-LBS151`: flag de bypass de librería S151 (valor 1=bypass activo, 0=normal); solo activable por operadores con acceso a WFL

**Excepciones documentadas**
- Activar este bypass genera omisión de asientos contables → divergencia entre saldo de captación y GL → requiere reconciliación manual posterior
- No existe mecanismo automático de regeneración de asientos; debe ejecutarse reproceso manual del día afectado
- **Riesgo de migración**: equivalente moderno debe implementar circuit-breaker con replay automático de eventos GL

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-082 — Validación de Tasas CETES/LIBOR como Gate de Proceso (VAL-CETES-LIBOR)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-082 |
| **Nombre** | Validación de Tasas CETES/LIBOR como Gate de Proceso (VAL-CETES-LIBOR) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[VALIDACIÓN-PREPROCESS]` `[GATE]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico Circular 3/2012 (tasas de referencia para captación) |
| **Programa ejecutor** | P130 (PERFORM 40089900-VAL-CETES-LIBOR en flujo principal) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
PERFORM 40089900-VAL-CETES-LIBOR:
    IF tasas CETES/LIBOR cargadas de S080 están fuera de rango válido:
        EMIT mensaje de error
        ABORT proceso → PERFORM 59999990-FIN-PGM
    ELSE:
        Continuar a CANCEL-LIBS y PROCESO-PRINCIPAL
```

**Vocabulario en la fórmula**
- `VAL-CETES-LIBOR`: rutina de validación de tasas de mercado antes del proceso masivo
- `CETES`: Certificados de la Tesorería de la Federación — tasa de referencia Banxico para depósitos MXN
- `LIBOR`: tasa internacional de referencia — usada en contratos legacy de captación en USD (pre-2021); riesgo de migración por discontinuación LIBOR
- `I07-TASASTARIF83`: archivo de tasas históricas pre-1983 — valores fuera del rango actual pero válidos para contratos vintage

**Excepciones documentadas**
- I07-TASASTARIF83 contiene tasas de la era de inflación alta (pre-1983); deben validarse contra rango histórico propio, no el rango actual
- **Riesgo LIBOR**: referencias a LIBOR en contratos vigentes son riesgo regulatorio post-2021; la migración debe sustituir por SOFR u otra tasa sustituta

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-083 — Cálculo del Saldo Promedio Anual (WKS-PROM-ANUAL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-083 |
| **Nombre** | Cálculo del Saldo Promedio Anual (WKS-PROM-ANUAL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CÁLCULO]` `[PROMEDIO-ANUAL]` `[BASE-RENDIMIENTO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Anexo 33 (Series R-02 y B-05 — depósitos y rendimientos) |
| **Programa ejecutor** | P130 (líneas 7531-7536) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF W77-DIAS-ANUAL > 0:
    WKS-PROM-ANUAL = B06-ACUM-PROMANU / W77-DIAS-ANUAL
ELSE:
    WKS-PROM-ANUAL = 0
```

**Vocabulario en la fórmula**
- `B06-ACUM-PROMANU`: acumulado de saldo diario del año en curso (DMSII BD06, campo persistido entre ejecuciones)
- `W77-DIAS-ANUAL`: días del año contados en el proceso hasta la fecha de corte
- `WKS-PROM-ANUAL`: saldo promedio anual resultante (base del cálculo de rendimiento)

**Excepciones documentadas**
- Si el contrato cambió de producto (`W77-HAY-CAMB-PROD=1`) o está cancelado (`B03-STATUS=2`), se resta 1 día de W77-DIAS-ANUAL antes del cálculo (ver RN-S500-084)
- División por cero protegida explícitamente por el `IF W77-DIAS-ANUAL > 0`

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-084 — Ajuste de Días por Cancelación o Cambio de Producto (-1 día)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-084 |
| **Nombre** | Ajuste de Días por Cancelación o Cambio de Producto (-1 día) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[AJUSTE-DÍAS]` `[CANCELACIÓN]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB (el rendimiento se paga hasta el día anterior a la cancelación, no el día de cancelación) |
| **Programa ejecutor** | P130 (líneas 7527-7529 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Comentario en código: "se restan los días anuales porque los rendimientos
-- se pagan hasta un día antes de la cancelación o cambio de producto"

IF W77-HAY-CAMB-PROD = 1 OR B03-STATUS = 2:
    SUBTRACT 1 FROM W77-DIAS-ANUAL
-- (luego se usa W77-DIAS-ANUAL en RN-S500-083)
```

**Vocabulario en la fórmula**
- `W77-HAY-CAMB-PROD`: indicador de cambio de producto en el día (1=sí)
- `B03-STATUS`: estado del contrato en DMSII BD03 (0=activo, 1=bloqueado, 2=cancelado, 5=especial)
- `W77-DIAS-ANUAL`: contador de días del año; se modifica in-place antes del cálculo de promedio

**Excepciones documentadas**
- B03-STATUS = 0, 1 o 5 (contratos vigentes) → no se restan días; se usa el conteo completo
- Si el contrato se cancela el primer día del año (W77-DIAS-ANUAL=1) → resta 1 → promedio sobre 0 días → protección por IF en RN-S500-083

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-085 — Saldo Promedio Anual Extendido para Ciclos Parciales (WKS-PROM-ANUAL-EXT)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-085 |
| **Nombre** | Saldo Promedio Anual Extendido para Ciclos Parciales (WKS-PROM-ANUAL-EXT) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CÁLCULO]` `[PROMEDIO-ANUAL-EXT]` `[CICLO-PARCIAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Anexo 33 (base para reportes de rendimiento real) |
| **Programa ejecutor** | P130 (líneas 7540-7551) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF TB-B05-IND-RENDDIA(inst) = 1:
    WKS-PROM-ANUAL-EXT = WKS-PROM-ANUAL   (instrumento de rendimiento diario: promedio simple)
ELSE IF W77-DIAS-ANUAL <= W77-DIAS-CORTE-GRL:
    WKS-PROM-ANUAL-EXT = WKS-PROM-ANUAL   (ciclo completo: sin ajuste)
ELSE IF WS-CAP-DIASCICLO = W77-DIAS-CORTE-GRL:
    WKS-PROM-ANUAL-EXT = WKS-PROM-ANUAL   (coincidencia exacta de ciclo: sin ajuste)
ELSE:
    WKS-PROM-ANUAL-EXT = B06-ACUM-PROMANU /
                         (W77-DIAS-ANUAL - W77-DIAS-CORTE-GRL + WS-CAP-DIASCICLO)
    -- (ajuste extendido: normaliza el promedio al período de ciclo real del contrato)
```

**Vocabulario en la fórmula**
- `WKS-PROM-ANUAL-EXT`: saldo promedio anual extendido, ajustado por ciclo parcial
- `TB-B05-IND-RENDDIA(inst)`: indicador de rendimiento diario por instrumento (0=periódico, 1=diario)
- `W77-DIAS-CORTE-GRL`: días de corte general del proceso (parámetro del día de ejecución)
- `WS-CAP-DIASCICLO`: días del ciclo actual del contrato (puede diferir del corte general)
- `B06-ACUM-PROMANU`: acumulado bruto diario del año (mismo campo que en RN-S500-083)

**Excepciones documentadas**
- La rama "ELSE" (ajuste extendido) aplica cuando el contrato tiene un ciclo de corte diferente al ciclo general del proceso; típico en contratos con fecha de vencimiento no alineada al fin de mes
- Para instrumentos IND-RENDDIA=1 siempre se usa el promedio simple — el ajuste no aplica a rendimiento diario

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-086 — Decisión de Capitalización por Estado del Contrato (50116000-ANALIZA-CAPITALIZ)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-086 |
| **Nombre** | Decisión de Capitalización por Estado del Contrato (50116000-ANALIZA-CAPITALIZ) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[SWITCH-CAPITALIZACIÓN]` `[ESTADO-CONTRATO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB (obligación de aplicar rendimientos a contratos vigentes; Art. 61 para cuentas inactivas) |
| **Programa ejecutor** | P130 (líneas 7554-7601) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF B03-STATUS IN (0, 1, 5):               -- Contrato VIGENTE
    PERFORM 50116100-ACUMULA-RENDIMIENTOS
    PERFORM 50116300-ACUMULA-COMISIONES
    PERFORM 50116500-ACUMULA-COMIPENDTES

ELSE IF B03-STATUS = 2                    -- Contrato CANCELADO
     AND (TB-B05-PGOREND(inst) = 1        -- instrumento paga rend. en cancelación
          OR WS-ES-ART61 = 1):            -- o cuenta Art. 61 (beneficencia/inactiva)
    WS-CAP-RENDNETO  = B03-INTS-CAPIT
    WS-CAP-IMPUESTO  = B03-IMPUESTO-RET
    WS-CAP-TASANETA  = B03-TASA-ANTERIOR
    WS-CAP-TASABRUTA = B06-TASA-BRUTA
    WS-CAP-RENDBRTO  = WS-CAP-RENDNETO + WS-CAP-IMPUESTO
    PERFORM 50116200-ACUMULA-REND-CANC

ELSE:                                     -- Cancelado SIN pago de rendimientos
    B03-TASA-ANT-ANT  = B03-TASA-ANTERIOR
    ZEROS → B03-INTS-CAPIT, B03-IMPUESTO-RET, B03-TASA-ANTERIOR, B06-TASA-BRUTA
```

**Vocabulario en la fórmula**
- `B03-STATUS`: estado del contrato en DMSII BD03 (0=activo, 1=bloqueado, 2=cancelado, 5=especial)
- `TB-B05-PGOREND(inst)`: indicador de pago de rendimiento en cancelación (por instrumento en BD05)
- `WS-ES-ART61`: indicador de cuenta clasificada bajo Art. 61 CUB (cuenta de beneficencia por inactividad prolongada)
- `B03-INTS-CAPIT`: interés capitalizado acumulado en BD03
- `B03-IMPUESTO-RET`: ISR retenido acumulado en BD03

**Excepciones documentadas**
- ART61 fuerza pago de rendimientos en cancelación aun cuando `TB-B05-PGOREND=0` — excepción regulatoria
- B03-STATUS=5 (contrato especial) se trata como vigente para efectos de capitalización

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-087 — Rendimiento Periódico al Vencimiento del Ciclo (IND-RENDDIA = 0)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-087 |
| **Nombre** | Rendimiento Periódico al Vencimiento del Ciclo (IND-RENDDIA = 0) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CÁLCULO]` `[RENDIMIENTO-PERIÓDICO]` `[CAPITALIZACIÓN]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB (rendimiento al vencimiento del ciclo para instrumentos de plazo) |
| **Programa ejecutor** | P130 (líneas 7620-7629 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Aplica cuando TB-B05-IND-RENDDIA(inst) = 0 (rendimiento periódico)
-- AND (TB-B05-PGOREND(inst)=1 OR WS-ES-ART61=1) AND WS-CAP-SINRENDI=0

B03-IMPUESTO-RET  = WS-CAP-IMPUESTO       -- ISR del período
B03-INTS-CAPIT    = WS-CAP-RENDNETO       -- interés neto del período
B03-SDO-ACTUAL   += WS-CAP-RENDNETO       -- capitaliza rendimiento al saldo
B03-TASA-ANT-ANT  = B03-TASA-ANTERIOR     -- guarda tasa anterior
B03-TASA-ANTERIOR = WS-CAP-TASANETA       -- actualiza última tasa neta
WKS-SI-B03 = 1                            -- flag: escribir BD03 en DMSII
```

**Vocabulario en la fórmula**
- `TB-B05-IND-RENDDIA(inst)`: indicador de rendimiento diario (0=periódico/al vencimiento, 1=diario)
- `WS-CAP-IMPUESTO`: ISR calculado por el proceso de capitalización (fuente: rutina CAPITALIZA)
- `WS-CAP-RENDNETO`: rendimiento neto (bruto - ISR)
- `WS-CAP-SINRENDI`: flag "sin rendimiento" — si=1 se fuerza cero (contratos sin tasa pactada)
- `WKS-SI-B03`: flag de escritura a BD03 DMSII (1=escribir)

**Excepciones documentadas**
- `WS-CAP-SINRENDI=1` evita la capitalización aun cuando `IND-RENDDIA=0`; aplica a contratos bloqueados o sin tasa pactada
- Para IND-RENDDIA=1 (rendimiento diario), ver RN-S500-088

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-088 — Rendimiento Diario: Acumulación Diaria y Tasa Promedio en Cierre Mensual (IND-RENDDIA = 1)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-088 |
| **Nombre** | Rendimiento Diario: Acumulación Diaria y Tasa Promedio en Cierre Mensual (IND-RENDDIA = 1) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CÁLCULO]` `[RENDIMIENTO-DIARIO]` `[TASA-PROMEDIO]` `[IPAB]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB (cuentas de ahorro con rendimiento diario; IPAB — Instituto de Protección al Ahorro Bancario) |
| **Programa ejecutor** | P130 (líneas 7630-7660 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Aplica cuando TB-B05-IND-RENDDIA(inst) = 1 (rendimiento diario)

-- ACUMULACIÓN DIARIA (todos los días):
ADD WS-CAP-IMPUESTO TO B03-IMPUESTO-RET    -- acumula ISR del día
ADD WS-CAP-RENDNETO TO B03-INTS-CAPIT      -- acumula rendimiento neto del día
ADD WS-CAP-RENDNETO TO B03-SDO-ACTUAL      -- aplica al saldo inmediatamente
B03-ISRDIA-IPAB    = WS-CAP-IMPUESTO       -- ISR del día para IPAB
B03-RENDIA-IPAB    = WS-CAP-RENDNETO       -- rendimiento del día para IPAB
WS-CANCE-PROMCIC-03 → B06-SDOPROM-IPAB    -- saldo promedio del ciclo para IPAB
WKS-SI-B03 = 1

-- TASA NETA AL CIERRE MENSUAL (WKS-ES-MENSUAL = 1):
IF W77-SDOPROM-RENDIA > 0 AND B06-DIAPAG-RENDIA > 0:
    B03-TASA-ANTERIOR = B03-INTS-CAPIT / W77-SDOPROM-RENDIA * 36000 / B06-DIAPAG-RENDIA
    B06-TASA-BRUTA    = (B03-INTS-CAPIT + B03-IMPUESTO-RET) / W77-SDOPROM-RENDIA
                        * 36000 / B06-DIAPAG-RENDIA
ELSE:
    B03-TASA-ANTERIOR = WS-CAP-TASANETA    -- tasa directa si denominador = 0
```

**Vocabulario en la fórmula**
- `W77-SDOPROM-RENDIA`: saldo promedio del período de rendimiento diario (base del denominador)
- `B06-DIAPAG-RENDIA`: días pagados con rendimiento diario en el período (denominador de días)
- `36000`: factor de anualización (360 días × 100% para expresar en porcentaje anual)
- `B03-ISRDIA-IPAB` / `B03-RENDIA-IPAB`: campos dedicados al reporte IPAB de ISR y rendimiento diario
- `B06-SDOPROM-IPAB`: saldo promedio del ciclo reportado al IPAB

**Excepciones documentadas**
- Si `W77-SDOPROM-RENDIA=0` o `B06-DIAPAG-RENDIA=0` → evita división por cero; usa tasa directa `WS-CAP-TASANETA`
- La acumulación diaria implica que el saldo (B03-SDO-ACTUAL) crece cada día — diferente al modo periódico donde solo crece al vencimiento del ciclo
- Factor 36000 es hardcoded; cambio regulatorio a base 365 días requiere modificación en múltiples COMPUTEs

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-089 — ISR Valorizado No Acumulado en Cancelación en Línea (Compensación P010→P130)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-089 |
| **Nombre** | ISR Valorizado No Acumulado en Cancelación en Línea (Compensación P010→P130) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[ISR]` `[CANCELACIÓN]` `[FX-CONVERSIÓN]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT ISR Art. 54 (retención de ISR sobre intereses bancarios; base para DIOT) |
| **Programa ejecutor** | P130 (líneas 6626-6637; comentario explícito: "En una cancelación en línea |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- P010 (online) cancela el contrato dejando B03-STATUS=2 pero
-- no acumula B06-IMPTO-VALMN para cuentas USD. P130 lo completa:

IF B06-FEC-CANCEL = WKS-FEC-BASE    -- cancelado HOY
AND B03-STATUS = 2:                  -- cancelado por P010 en línea
    IF B03-MONEDA = 5 (USD):
        W77-VAL-PUENTE ROUNDED = B03-IMPUESTO-RET * W77-TCAMBIO-VTA
        ADD W77-VAL-PUENTE TO B06-IMPTO-VALMN
    -- (MXN: B06-IMPTO-VALMN ya acumulado en campo normal; no requiere conversión aquí)
```

**Vocabulario en la fórmula**
- `B06-FEC-CANCEL`: fecha de cancelación del contrato (DMSII BD06)
- `WKS-FEC-BASE`: fecha base del proceso del día (= fecha contable actual)
- `B06-IMPTO-VALMN`: ISR valorizado en MXN (campo de BD06 para reportes CNBV Serie B)
- `W77-TCAMBIO-VTA`: tipo de cambio venta del día (cargado al inicio del proceso desde S080 o tabla de cambio)

**Excepciones documentadas**
- Para evitar doble acumulación en cancelaciones por traspaso a Cuenta Global: la condición compuesta garantiza que solo se procesa cuando la cancelación fue hoy
- Solo aplica a `B03-MONEDA=5` (USD); cuentas MXN no requieren conversión cambiaria

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-090 — ISR de Plan de Ahorro Empresarial (EPP) en Cierre Mensual

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-090 |
| **Nombre** | ISR de Plan de Ahorro Empresarial (EPP) en Cierre Mensual |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[ISR]` `[BENEFICIO-EMPLEADOS]` `[CIERRE-MENSUAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT ISR Art. 93 (exención parcial de ISR en planes de ahorro para el retiro de empleados) |
| **Programa ejecutor** | P130 (líneas 6648-6649) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WKS-ES-MENSUAL = 1                -- solo en cierre mensual
AND B06-ISR-RET-EPP > 0:            -- hay ISR acumulado de EPP en el mes
    PERFORM 50120000-SALIDA-IMPUESTO
```

**Vocabulario en la fórmula**
- `B06-ISR-RET-EPP`: ISR retenido acumulado de plan de ahorro empresarial (DMSII BD06; se acumula diariamente, se paga mensualmente)
- `50120000-SALIDA-IMPUESTO`: rutina de envío de ISR a S151REGISTRA; tipo de salida determinado por `W77-TPO-SAL-ISR`
- `W77-TPO-SAL-ISR`: tipo de salida de impuesto (PIC 9(02)); valor 1=tipo especial EPP, valor 0=tipo normal

**Excepciones documentadas**
- Durante el mes, B06-ISR-RET-EPP se acumula sin generar asientos GL — solo al cierre mensual se registra en S151
- Si WKS-ES-MENSUAL=0 y B06-ISR-RET-EPP>0 → no se procesa; el acumulado permanece para el siguiente cierre mensual

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-091 — Asiento GL: Rendimiento Neto hacia S151 (CVE-COMUN 3000)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-091 |
| **Nombre** | Asiento GL: Rendimiento Neto hacia S151 (CVE-COMUN 3000) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[GL-POSTING]` `[RENDIMIENTO-NETO]` `[FX-CONVERSIÓN]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB (obligación de contabilizar intereses pagados a clientes) |
| **Programa ejecutor** | P130 (líneas 7663-7714) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WS-CAP-RENDNETO > 0:
    W77-IMP-COMUN    = WS-CAP-RENDNETO
    W77-CVE-COMUN    = 3000              -- clave GL: rendimiento neto
    W77-HAY-PAGO-REND = 1               -- flag: se pagó rendimiento
    PERFORM 50116700-LLENA-MOVS-S151
    IF B03-MONEDA = 5 (USD):
        W77-VAL-PUENTE ROUNDED = WS-CAP-RENDNETO * W77-TCAMBIO-VTA
        ADD W77-VAL-PUENTE   TO WKS-VAL-CGOMN   -- cargo en MXN
        ADD WS-CAP-RENDNETO  TO WKS-VAL-CGODLS  -- cargo en USD
```

**Vocabulario en la fórmula**
- `W77-CVE-COMUN=3000`: clave de movimiento GL para rendimiento neto (convenio interno S500-S151)
- `50116700-LLENA-MOVS-S151`: rutina que empaqueta W77-CVE-COMUN + W77-IMP-COMUN en la interfaz de S151REGISTRA
- `WKS-VAL-CGOMN`: acumulado de cargos del día en MXN (para cuadre contable)
- `WKS-VAL-CGODLS`: acumulado de cargos del día en USD

**Excepciones documentadas**
- Si RENDNETO=0 → no se genera movimiento GL (contratos sin saldo promedio suficiente)
- Para esquema GBNP (`WS-88-PAGA-CON-GBNP`): si IND-RENDDIA=0 no agrega leyenda adicional; si IND-RENDDIA=1 agrega leyenda con tasa neta al estado de cuenta

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-092 — Asiento GL: ISR Retenido hacia S151 (CVE-COMUN 4009)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-092 |
| **Nombre** | Asiento GL: ISR Retenido hacia S151 (CVE-COMUN 4009) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[GL-POSTING]` `[ISR]` `[FX-CONVERSIÓN]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | SAT ISR Art. 54 + CNBV CUB (obligación de contabilizar retención ISR en libros bancarios) |
| **Programa ejecutor** | P130 (líneas 7716-7727) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WS-CAP-IMPUESTO > 0:
    W77-IMP-COMUN = WS-CAP-IMPUESTO
    W77-CVE-COMUN = 4009             -- clave GL: ISR retenido
    PERFORM 50116700-LLENA-MOVS-S151
    IF B03-MONEDA = 5 (USD):
        W77-VAL-PUENTE ROUNDED = WS-CAP-IMPUESTO * W77-TCAMBIO-VTA
        ADD W77-VAL-PUENTE   TO WKS-VAL-CGOMN, WKS-VAL-ABOMN, B06-IMPTO-VALMN
        ADD WS-CAP-IMPUESTO  TO WKS-VAL-CGODLS, WKS-VAL-ABODLS
```

**Vocabulario en la fórmula**
- `W77-CVE-COMUN=4009`: clave GL para ISR retenido (convenio interno S500-S151)
- `WKS-VAL-ABOMN` / `WKS-VAL-ABODLS`: acumulados de abonos MXN/USD del día (ISR suma en cargo Y abono — partida doble)
- `B06-IMPTO-VALMN`: ISR valorizado en MXN acumulado en BD06 (base de reporte CNBV y DIOT SAT)

**Excepciones documentadas**
- Para cuentas USD el ISR se registra en GL tanto en MXN (cargo+abono = partida doble) como en USD → genera 4 líneas de movimiento GL vs 2 para MXN
- Tasa de ISR sobre rendimientos (Art. 54) es anual y se aplica sobre la tasa bruta; si el Congreso modifica la tasa → riesgo de hardcode en el factor de ISR dentro de la librería CAPITALIZA

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-093 — Asiento GL: Rendimiento Bruto hacia S151 (CVE-COMUN 809)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-093 |
| **Nombre** | Asiento GL: Rendimiento Bruto hacia S151 (CVE-COMUN 809) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[GL-POSTING]` `[RENDIMIENTO-BRUTO]` `[REPORTING-CNBV]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Serie R-04 (rendimientos brutos de captación para Circular Única de Bancos) |
| **Programa ejecutor** | P130 (líneas 7729-7732) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WS-CAP-RENDBRTO > 0:
    W77-IMP-COMUN = WS-CAP-RENDBRTO     -- rendimiento bruto = RENDNETO + ISR
    W77-CVE-COMUN = 809                  -- clave GL: rendimiento bruto
    PERFORM 50116700-LLENA-MOVS-S151

-- Relación invariante:
-- WS-CAP-RENDBRTO = WS-CAP-RENDNETO + WS-CAP-IMPUESTO
-- CVE 809 = CVE 3000 + CVE 4009 (cuadre contable)
```

**Vocabulario en la fórmula**
- `WS-CAP-RENDBRTO`: rendimiento bruto antes de ISR (= rendimiento neto + ISR)
- `W77-CVE-COMUN=809`: clave GL para rendimiento bruto (convenio interno S500-S151)

**Excepciones documentadas**
- El cuadre contable requiere que CVE 809 = CVE 3000 + CVE 4009 en cada contrato; cualquier divergencia indica error en el cálculo de ISR
- No hay conversión FX adicional para este asiento en cuentas USD (se acumula en los mismos totales WKS-VAL-CGOMN/CGODLS del paso anterior)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-094 — Conversión Cambiaria para Asientos GL en Cuentas USD (B03-MONEDA = 5)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-094 |
| **Nombre** | Conversión Cambiaria para Asientos GL en Cuentas USD (B03-MONEDA = 5) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CÁLCULO]` `[FX-CONVERSIÓN]` `[GL-POSTING]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico (uso del tipo de cambio venta para conversión en libros bancarios) |
| **Programa ejecutor** | P130 (líneas 7710-7714 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF B03-MONEDA = 5 (USD):
    W77-VAL-PUENTE ROUNDED = WS-CAP-[MONTO_USD] * W77-TCAMBIO-VTA
    ADD W77-VAL-PUENTE     TO WKS-VAL-CGOMN   -- acumula cargo MXN
    ADD WS-CAP-[MONTO_USD] TO WKS-VAL-CGODLS  -- acumula cargo USD
-- Cláusula ROUNDED: redondeo al centavo más cercano
```

**Vocabulario en la fórmula**
- `B03-MONEDA`: moneda del contrato en DMSII BD03 (1=MXN, 5=USD; no hay otras divisas hardcoded)
- `W77-TCAMBIO-VTA`: tipo de cambio venta USD/MXN del día (cargado al inicio del proceso desde tabla de tipos de cambio)
- `W77-VAL-PUENTE`: variable de trabajo para conversión (reutilizada por diferentes movimientos)
- `ROUNDED`: cláusula COBOL de redondeo — riesgo si se cambia a truncación en la migración

**Excepciones documentadas**
- Solo aplica a `B03-MONEDA=5`; no existe código para EUR u otras divisas
- **Riesgo de migración**: la cláusula `ROUNDED` en COBOL usa reglas de redondeo específicas (half-up); la implementación en Java/Python debe replicar exactamente `RoundingMode.HALF_UP`

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-095 — Clasificación de Contratos en Archivo de Rendimientos I05 (ESQ-REND)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-095 |
| **Nombre** | Clasificación de Contratos en Archivo de Rendimientos I05 (ESQ-REND) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CLASIFICACIÓN]` `[RENDIMIENTO-REPORTING]` `[SERIE-R-CNBV]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Anexo 33 (reportes de tasas y rendimientos por producto/instrumento/tarifa) |
| **Programa ejecutor** | P130 (líneas 7782-7809 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Determinación de TARIFA y REGION en archivo I05:
IF B03-ESQ-REND = 1:  TARIFA=5, REGION=B03-SGTO-REND    -- Bracketing
IF B03-ESQ-REND = 2:  TARIFA=6, REGION=B03-SGTO-REND    -- Curvas de rendimiento
IF B03-ESQ-REND = 3:  TARIFA=7, REGION=B03-SGTO-REND    -- Grupos de rendimiento
IF WS-CAP-ES-DLSP=1 OR WS-CAP-ES-0112P=1 OR WS-CAP-ES-0115P=1:
                       TARIFA=3, REGION=WS-CAP-PGORGO+10 -- Tasas preferenciales
IF WS-CAP-ES-RGOS=1:  TARIFA=2, REGION=0                -- Por rangos
IF WS-HAY-GPOREND=1:  TARIFA=4, REGION=WS-IND-GPOREND   -- Por grupo de rendimiento
DEFAULT:               TARIFA=1, REGION=WS-IND-REGION    -- Tarifa estándar

-- Leyenda en estado de cuenta según B03-ESQ-REND:
-- ESQ-REND=1 → "SU REND.POND. BRACKETING {segmento}/T.N. {tasa}%"
-- ESQ-REND=2 → "SU RENDIMIENTO CURVAS {segmento}/T.N. {tasa}%"
-- ESQ-REND=3 → "SU RENDIMIENTO GRUPOS {segmento}/T.N. {tasa}%"
```

**Vocabulario en la fórmula**
- `B03-ESQ-REND`: esquema de rendimiento del contrato (0=estándar, 1=bracketing, 2=curvas, 3=grupos)
- `B03-SGTO-REND`: segmento o grupo dentro del esquema de rendimiento
- `I05-FD-R00-TARIFA`: código de tarifa en el archivo de rendimientos (1-7)
- `I05-FD-R00-REGION`: identificador de región/segmento en el archivo de rendimientos
- `WS-CAP-ES-DLSP/0112P/0115P`: flags de producto con tasa preferencial (DLSP, producto 0112, producto 0115)
- `WS-CAP-PGORGO`: identificador de grupo de rendimiento preferencial

**Excepciones documentadas**
- TARIFA alimenta directamente los reportes Serie R-04 CNBV — error en clasificación genera inconsistencia regulatoria irrecuperable en el reporte del período
- La leyenda en estado de cuenta (CONDUSEF) debe corresponder exactamente al esquema aplicado

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-096 — Pre-Cancelación por Saldo Promedio Mínimo (50116650-VE-PRECANCEL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-096 |
| **Nombre** | Pre-Cancelación por Saldo Promedio Mínimo (50116650-VE-PRECANCEL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[CANCELACIÓN-AUTOMÁTICA]` `[SALDO-MÍNIMO]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF LTOSF Art. 4 (transparencia en condiciones de cancelación; 30 días de aviso previo) |
| **Programa ejecutor** | P130 (líneas 6531-6537) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF W77-HOY-CORTA > 0                           -- es día de corte
AND TB-B05-MES-BLQ-6614(inst) > 0:             -- instrumento tiene regla de bloqueo por saldo mínimo
    W77-MES-BLOQ = TB-B05-MES-BLQ-6614(inst)   -- carga límite de meses en bloqueo
    PERFORM 50116650-VE-PRECANCEL               -- evalúa y ejecuta pre-cancelación si aplica
ELSE:
    B03-MES-PROM-MIN = 0                        -- reset contador si no aplica la regla
```

**Vocabulario en la fórmula**
- `W77-HOY-CORTA`: días desde el último corte (>0 = es día de corte del ciclo)
- `TB-B05-MES-BLQ-6614(inst)`: meses máximos en bloqueo por saldo promedio mínimo insuficiente (tabla parametrizada por instrumento en DMSII BD05)
- `B03-MES-PROM-MIN`: contador de meses consecutivos sin saldo promedio mínimo (DMSII BD03)
- `W77-MES-BLOQ`: límite de meses en bloqueo antes de cancelación

**Excepciones documentadas**
- La notificación previa de 30 días al cliente es obligación CONDUSEF antes de ejecutar la cancelación
- Si el instrumento no tiene configurado `TB-B05-MES-BLQ-6614` (valor=0) → limpia `B03-MES-PROM-MIN` (reset); la regla no aplica a ese tipo de cuenta
- **Riesgo de migración**: la lógica de "cuántos meses ha tenido saldo insuficiente" vive acumulada en BD03; el target debe implementar un contador equivalente persistente

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-097 — Comisión por Exceso de Depósitos en el Ciclo (50116660-VE-IMPDEPCICLO)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-097 |
| **Nombre** | Comisión por Exceso de Depósitos en el Ciclo (50116660-VE-IMPDEPCICLO) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[DEPÓSITOS-EXCEDIDOS]` `[MENSUAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF LTOSF Art. 4 (transparencia en comisiones por operaciones que exceden el umbral gratuito) |
| **Programa ejecutor** | P130 (líneas 6539-6545) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF W77-HOY-CORTA > 0                           -- es día de corte
AND TB-B05-MES-EXE-DEP(inst) > 0:              -- instrumento tiene regla de exceso de depósitos
    W77-MES-DEP = TB-B05-MES-EXE-DEP(inst)     -- carga límite de meses de exceso
    PERFORM 50116660-VE-IMPDEPCICLO             -- calcula y cobra comisión por exceso
ELSE:
    B03-MES-ABO-EXCE = 0                        -- reset contador
```

**Vocabulario en la fórmula**
- `TB-B05-MES-EXE-DEP(inst)`: meses de exceso de depósitos permitido por instrumento (parámetro en BD05)
- `B03-MES-ABO-EXCE`: contador de depósitos excedentes acumulados en el ciclo (DMSII BD03)
- `W77-MES-DEP`: límite de meses de exceso antes de cobrar comisión

**Excepciones documentadas**
- Aplica principalmente a productos de ahorro con número de depósitos gratuitos limitado por contrato
- Si el instrumento no tiene esta regla configurada (`TB-B05-MES-EXE-DEP=0`) → reset del contador sin cobro

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-098 — Traspaso Automático a Cuenta de Beneficencia (Art. 61 CUB)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-098 |
| **Nombre** | Traspaso Automático a Cuenta de Beneficencia (Art. 61 CUB) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[REGLA-NEGOCIO]` `[INACTIVIDAD]` `[BENEFICENCIA]` `[ART61]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV CUB Art. 61 (cuentas inactivas con saldo a favor deben transferirse a cuenta de beneficencia después del período de inactividad) |
| **Programa ejecutor** | P130 (líneas 6600-6607) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WKS-ES-1ERVIE-ANH = 1            -- primer viernes después del aniversario
AND B03-MONEDA = 1                   -- solo cuentas MXN
AND B03-STA-BENEF IN (3, 8)          -- estado: pendiente traspaso (3) o aprobado para traspaso (8)
AND WKS-MESES-TRP-BENEF > 0         -- meses de espera cumplidos
AND W77-SDO-MAX-BENF > 0:           -- saldo máximo para beneficencia configurado
    PERFORM 50113600-TRASP-BENEF
```

**Vocabulario en la fórmula**
- `WKS-ES-1ERVIE-ANH`: flag del primer viernes después del aniversario del contrato (calculado en WFL)
- `B03-STA-BENEF`: estado de beneficencia (0=sin beneficencia, 1=elegible, 2=bloqueada, 3=pendiente traspaso, 8=aprobada para traspaso)
- `WKS-MESES-TRP-BENEF`: meses de espera antes de iniciar el traspaso (parámetro del proceso)
- `W77-SDO-MAX-BENF`: saldo máximo para clasificar como cuenta de beneficencia (umbral)

**Excepciones documentadas**
- Solo aplica a cuentas MXN (`B03-MONEDA=1`); cuentas USD excluidas del flujo Art. 61
- Cuentas CTAGLOB (`WS03-88-PIM-CTAGLOB`), BENEF y GLOBMPS excluidas del flujo normal
- El traspaso a Cuenta Global y a beneficencia son flujos mutuamente excluyentes; flags separados (`W77-TRP-CTA-GLB` vs `W77-TRP-CTA-BENEF`)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-099 — Consulta Central de Comisión vía DAME-COMISION / S080

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-099 |
| **Nombre** | Consulta Central de Comisión vía DAME-COMISION / S080 |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[TARIFA]` `[CONSULTA-CATÁLOGO]` `[CONDUSEF]` |
| **Confianza** | alta (vocab-s500-v4.json, término 20039000-dame-comision) |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF LTOSF Art. 4 + LFPIORPI + BEF (Buró de Entidades Financieras — todas las comisiones cobradas deben estar en BEF) |
| **Programa ejecutor** | P130 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
F-COMISION = DAME-COMISION(
    CVTARIF  = clave_tarifa,         -- clave en catálogo S080
    PRODUCTO = B03-NUM-PRODUCTO,     -- código de producto bancario
    INSTRUM  = B03-NUM-INSTRUM,      -- instrumento
    MONEDA   = B03-MONEDA,           -- 1=MXN, 5=USD
    PERSONA  = WS-IND-PERS,          -- 1=PF, 2=PM
    PLAZO    = ESQCOM,               -- esquema de comisión (posiciones 1-210 en S080)
    FECHVIG  = fecha_proceso         -- fecha de vigencia
)
```

**Vocabulario en la fórmula**
- `CVTARIF`: clave de tarifa en S080 (identifica el tipo de comisión)
- `ESQCOM`: esquema de comisión seleccionado del catálogo S080 (OCCURS 210 — hasta 210 esquemas diferentes)
- `FECHVIG`: fecha de vigencia de la tarifa en S080 (permite tarifas con fecha de inicio/fin)
- `WS-IND-PERS`: indicador de tipo de persona (1=Persona Física, 2=Persona Moral)

**Excepciones documentadas**
- Toda comisión cobrada debe estar registrada en BEF (CONDUSEF) — cobrar una comisión no registrada en BEF es infracción directa
- ESQCOM tiene 210 posibles valores en el OCCURS de S080 → hardcode del tamaño; si S080 amplía más de 210 esquemas requiere recompilación
- **Riesgo de migración**: S080 es un servicio externo (catálogo Banamex); la fachada moderna debe ser un API que retorne el mismo contrato funcional

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-100 — Despachador de Comisiones Mensuales (20530000-COMIS-MENSUAL)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-100 |
| **Nombre** | Despachador de Comisiones Mensuales (20530000-COMIS-MENSUAL) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[DESPACHADOR]` `[MENSUAL]` `[MAYOR-RIESGO-CONDUSEF]` |
| **Confianza** | alta (vocab-s500-v4.json, término 20530000-comis-mensual) |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF LTOSF Art. 4 (mayor riesgo regulatorio — volumen y variedad de comisiones mensuales) |
| **Programa ejecutor** | P130 (COMIS-MENSUAL dispatcher; invocado en WKS-ES-MENSUAL=1) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Solo en WKS-ES-MENSUAL = 1 (cierre mensual)
FOR i = 1 TO 15:
    IF TB-B05-CVECOMI(inst, i) > 0:           -- instrumento tiene comisión en slot i
        PERFORM DAME-COMISION using TB-B05-CVECOMI(inst, i)
        IF comisión aplica al contrato:
            PERFORM COBRO-COMISION
            W77-CVE-COMUN = WS-CAP-CVECOMI(i)
            W77-IMP-COMUN = WS-CAP-COMISINIVA(i)
            PERFORM 50116700-LLENA-MOVS-S151
-- Exclusiones explícitas del dispatcher:
TESOFE  → NOT processed here (vía separada)
CONCENSO → NOT processed here (vía separada)
```

**Vocabulario en la fórmula**
- `TB-B05-CVECOMI(inst, i)`: tabla de claves de comisión por instrumento y slot (hasta 15 comisiones por instrumento, definidas en BD05)
- `WS-CAP-CVECOMI(i)`: clave GL de la comisión en el slot i (extraída de S080 vía DAME-COMISION)
- `WS-CAP-COMISINIVA(i)`: importe de la comisión más IVA en el slot i
- `TESOFE`: cuentas de Tesorería de la Federación — excluidas del dispatcher regular
- `CONCENSO`: concepto de consultoría interna — excluido del cobro regular de comisiones

**Excepciones documentadas**
- Hasta 15 comisiones simultáneas por contrato; si el instrumento requiere más de 15 tipos → limitación estructural
- TESOFE y CONCENSO tienen vías de cobro separadas fuera del dispatcher — si se consolidan en la migración, se requiere validación CONDUSEF
- **Mayor riesgo CONDUSEF** de todo P130: error en el dispatcher mensual afecta a todos los contratos en la misma ejecución

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-101 — Comisión de Manejo de Cuenta con Exención por Saldo Promedio (COMISION-MANEJO-CTA)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-101 |
| **Nombre** | Comisión de Manejo de Cuenta con Exención por Saldo Promedio (COMISION-MANEJO-CTA) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[MANEJO-CTA]` `[EXENCIÓN-SBC]` `[NÓMINA]` |
| **Confianza** | alta (vocab-s500-v4.json, término 20530500-comision-manejo-cta) |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | Banxico Circular (exención incondicional para cuentas nómina) + CONDUSEF LTOSF Art. 4 |
| **Programa ejecutor** | P130 (invocado desde COMIS-MENSUAL dispatcher) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Evaluación del SBC (Saldo Bancario de Compensación = promedio mensual):
IF SBC < WS-SDO-MANEJO:           -- saldo insuficiente
    COBRO = WS-COM-MANEJO         -- cobra comisión de manejo completa
ELSE:
    COBRO = 0                     -- exento: saldo promedio suficiente

-- Exención especial para cuentas nómina (Circular Banxico):
IF es_cuenta_nomina:
    COBRO = 0 (siempre, independiente del SBC)

-- Tarifa consultada en S080: tariff #018
WS-COM-MANEJO = DAME-COMISION(CVTARIF=018, PRODUCTO, INSTRUM, MONEDA, PERSONA)
WS-SDO-MANEJO = saldo mínimo de exención retornado por S080
```

**Vocabulario en la fórmula**
- `SBC`: Saldo Bancario de Compensación — promedio mensual del saldo en la cuenta
- `WS-SDO-MANEJO`: saldo mínimo para exención de comisión de manejo (devuelto por S080, tariff #018)
- `WS-COM-MANEJO`: importe de la comisión de manejo mensual (devuelto por S080, tariff #018)

**Excepciones documentadas**
- Cuentas nómina tienen exención incondicional por regulación Banxico — no dependen del SBC
- Cuentas USD: el SBC se calcula en USD y se convierte a MXN para comparar con WS-SDO-MANEJO (ambos deben estar en la misma moneda)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-102 — Comisión de Aniversario (20530400-COMISION-ANIVERSARIO)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-102 |
| **Nombre** | Comisión de Aniversario (20530400-COMISION-ANIVERSARIO) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[ANIVERSARIO]` `[ANUAL]` `[NOTIFICACIÓN-30-DÍAS]` |
| **Confianza** | alta (vocab-s500-v4.json, término 20530400-comision-aniversario) |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF LTOSF Art. 4 (notificación obligatoria 30 días antes de cobro de comisión anual) |
| **Programa ejecutor** | P130 |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF TB-B05-CVECOMI(inst, 4) > 0           -- slot 4 = comisión de aniversario
AND fecha_proceso = aniversario_contrato:
    COBRO = DAME-COMISION(CVTARIF=017, PRODUCTO, INSTRUM, MONEDA, PERSONA, FECHVIG)
    PERFORM COBRO-COMISION
    PERFORM 50116700-LLENA-MOVS-S151
-- Prereq: notificación de 30 días enviada al cliente (fuera de P130)
```

**Vocabulario en la fórmula**
- `TB-B05-CVECOMI(inst, 4)`: slot 4 de comisiones del instrumento, reservado para comisión de aniversario
- `tariff #017`: tarifa de comisión anual en catálogo S080

**Excepciones documentadas**
- La notificación de 30 días al cliente es una obligación CONDUSEF previa; si no se notificó en tiempo, no se puede cobrar aunque caiga la fecha de aniversario
- **Riesgo hardcode**: la posición `(inst, 4)` como slot de aniversario es una convención implícita del sistema; debe documentarse explícitamente en el catálogo de instrumentos (BD05) del target

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-103 — Resolución de Esquema de Comisión PF vs PM (20530130-DAME-ESQCOMI)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-103 |
| **Nombre** | Resolución de Esquema de Comisión PF vs PM (20530130-DAME-ESQCOMI) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | BC-08 |
| **bian_ref** | 6.1.5 |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[COMISIÓN]` `[CLASIFICACIÓN-PERSONA]` `[PF-PM]` |
| **Confianza** | alta (vocab-s500-v4.json, término 20530130-dame-esqcomi) |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CONDUSEF (diferenciación de comisiones entre Persona Física y Persona Moral) |
| **Programa ejecutor** | P130 (rutina DAME-ESQCOMI |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
IF WS-IND-PERS = 1:
    ESQCOM = esquema_Persona_Física(inst)     -- PF: tarifa diferenciada por tipo de persona
IF WS-IND-PERS = 2:
    ESQCOM = esquema_Persona_Moral(inst)      -- PM: esquema de comisión empresarial

DAME-COMISION(PLAZO=ESQCOM, ...)             -- consulta S080 con ESQCOM como índice
-- S080 tiene OCCURS 210: hasta 210 esquemas distintos indexados por ESQCOM
```

**Vocabulario en la fórmula**
- `WS-IND-PERS`: indicador de tipo de persona (1=Persona Física, 2=Persona Moral)
- `ESQCOM`: esquema de comisión; valor que indexa la dimensión OCCURS 210 en S080
- `DAME-ESQCOMI`: rutina de resolución del esquema según tipo de persona e instrumento

**Excepciones documentadas**
- S080 tiene OCCURS 210: hardcode de tamaño máximo; ampliar más de 210 esquemas requiere recompilación de P130 y modificación del catálogo S080
- Error en clasificación PF/PM genera comisión incorrecta → exposición CONDUSEF directa
- **Riesgo de migración**: la lógica de selección de ESQCOM debe documentarse como catálogo, no como lógica implícita en el código

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

## 3. Reglas Extraídas — WFL LINEA (RN-S500-104 a RN-S500-107)

> WFL LINEA (`S500/WFL/LINEA/24MTP005`) es el controlador online de S500. Calcula los flags de calendario para todo el sistema (DIA5/DIA15/DIA30/DIA1MES/DIAFINSEM), habilita/deshabilita los LINCOMS en COMS (Communication Management System), y condiciona la activación de P045/P046 (Telethon). 1,961 LOC. AUTOR: L.MARIN, NOVIEMBRE 1991.
>
> **ANOMALÍA ANO-001 (documentada en vocab-s500):** el archivo `S500_WFL_LOTE.txt` contiene en realidad el WFL LINEA (`BEGIN JOB S500/WFL/LINEA/24MTP005`). El WFL LOTE real es el orquestador batch nocturno; sus reglas de secuencia se obtienen del grafo de dependencias.

---

### RN-S500-104 — Detección del Último Día Hábil del Mes (DIA30)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-104 |
| **Nombre** | Detección del Último Día Hábil del Mes (DIA30) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CALENDARIO]` `[CONTROL-BATCH]` `[CIERRE-MENSUAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV (el cierre mensual de captación debe ocurrir el último día hábil del mes) |
| **Programa ejecutor** | WFL LINEA S500 (sección FECHAS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- DIA30 = último día hábil del mes
-- Se determina comparando la fecha de proceso (HOY) con la siguiente fecha hábil (PRÓXIMO):
DIA30 = TRUE IF: IFECHAPROX MOD 100 = 1 AND  -- mañana es día 1 del mes siguiente
                 IFECHAHOY  MOD 100 > 1        -- y hoy NO es el primer día del mes
-- (IFECHA en formato AAMMDD → MOD 100 extrae el día)
```

**Vocabulario en la fórmula**
- `DIA30`: flag WFL (booleano); nombre histórico — no necesariamente el día 30 del calendario
- `IFECHAHOY`: fecha del día de proceso en formato interno (AAMMDD)
- `IFECHAPROX`: fecha del siguiente día hábil (ya considera festivos y fines de semana)
- `MOD 100`: operación de módulo para extraer el número de día del mes

**Excepciones documentadas**
- En febrero, DIA30 puede activarse el día 26, 27 o 28 dependiendo del año
- En meses con festivos en los últimos días, DIA30 puede adelantarse hasta el día 27
- Nombre "DIA30" es una convención histórica; el sistema no asume que será el día 30

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-105 — Detección del Quincenal (DIA15) para Comisiones y Cortes

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-105 |
| **Nombre** | Detección del Quincenal (DIA15) para Comisiones y Cortes |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CALENDARIO]` `[CONTROL-BATCH]` `[QUINCENAL]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | CNBV (cortes quincenales de captación en ciertos instrumentos) |
| **Programa ejecutor** | WFL LINEA S500 (sección FECHAS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
DIA15 = TRUE IF:
    IFECHAHOY MOD 100 = 15                          -- es exactamente el día 15
    OR DIA30                                         -- o es el último día hábil del mes
    OR (15 > IFECHAHOY MOD 100                      -- o el día 15 ya pasó
        AND 15 < IFECHAPROX MOD 100)                -- y mañana es después del 15
        -- (caso puente: festivo que hace el día 15 un día no hábil)
```

**Vocabulario en la fórmula**
- `DIA15`: flag WFL de procesamiento quincenal
- `DIA30`: flag de último día hábil del mes (ya calculado; DIA15 siempre es TRUE cuando DIA30 es TRUE)
- Lógica de puente: si el día 15 cae en fin de semana o festivo, DIA15 se activa el último día hábil antes del 15

**Excepciones documentadas**
- DIA30 implica DIA15 (el último día del mes es también quincenal) — evitar doble procesamiento en rutinas que verifican DIA15 independientemente
- La condición de puente puede activar DIA15 el día 14 (viernes antes de sábado 15)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-106 — Activación Condicional de Telethon (P045/P046 si BD06TELETON Residente)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-106 |
| **Nombre** | Activación Condicional de Telethon (P045/P046 si BD06TELETON Residente) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[ACTIVACIÓN-CONDICIONAL]` `[CAMPAÑA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — (carácter social; sin obligación regulatoria) |
| **Programa ejecutor** | WFL LINEA S500 (sección SUBETODOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
SUBETODOS:
    ENABLE P010, P014, P016, P020, P038, P050, P055, P060, P080, P091, P093 IN COMS
    IF FILE S500BD06TELETON/CONTROL IS RESIDENT:    -- archivo de control existe en DMSII
        ENABLE P045 IN COMS                          -- activa captación Telethon
        ENABLE P046 IN COMS                          -- activa dispersión Telethon
    ELSE:
        -- P045 y P046 permanecen deshabilitados silenciosamente en COMS
```

**Vocabulario en la fórmula**
- `S500BD06TELETON/CONTROL`: archivo de control DMSII BD06 para la campaña Telethon (su presencia es el único trigger de activación)
- `P045`: programa de captación de donaciones Telethon
- `P046`: programa de dispersión de fondos Telethon
- `ENABLE {pgm} IN COMS`: instrucción WFL para habilitar un programa en el Communication Management System Unisys
- `IS RESIDENT`: verificación DMSII de existencia del archivo en memoria/disco

**Excepciones documentadas**
- Sin fecha hardcoded — la presencia del archivo `CONTROL` en BD06TELETON es el único mecanismo de activación; la campaña se controla creando/eliminando ese archivo
- Si el archivo se deja residente fuera de período de campaña, P045/P046 quedan habilitados inadvertidamente — riesgo operativo
- **Riesgo de migración**: el mecanismo "archivo como feature flag" debe equivalerse a un feature flag moderno (LaunchDarkly, GCP Feature Flags, etc.)

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

### RN-S500-107 — Secuencia de Habilitación de LINCOMS al Inicio del Día (SUBETODOS)

| Campo | Valor |
|-------|-------|
| **Identificador** | RN-S500-107 |
| **Nombre** | Secuencia de Habilitación de LINCOMS al Inicio del Día (SUBETODOS) |
| **Versión** | v2 |
| **Estado ciclo** | En validación |
| **Fecha actualización** | 2026-07-27 |
| **BC-ID** | — (arquitectura/librería · no BC de negocio) |
| **bian_ref** | — |
| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |
| **Tipo técnico** | `[CONTROL]` `[SISTEMA]` `[COMS]` `[INICIO-DÍA]` |
| **Confianza** | alta |
| **Veredicto** | PENDIENTE SME |
| **Regulador** | — (operacional interno; afecta disponibilidad de servicios bancarios) |
| **Programa ejecutor** | WFL LINEA S500 (sección SUBETODOS) |
| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |
| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |

**Fórmula / Pseudocódigo**
```
-- Habilitación base (todos los días):
ENABLE P010 IN COMS   -- Gateway principal (LINCOM P010: cargos/abonos)
ENABLE P014 IN COMS   -- Subconsulta de cuenta
ENABLE P016 IN COMS   -- Proceso de actualización
ENABLE P020 IN COMS   -- Gateway secundario (LINCOM P020)
ENABLE P038 IN COMS   -- Control REORG
ENABLE P050 IN COMS   -- Tesorería
ENABLE P055 IN COMS   -- Proceso especial 55
ENABLE P060 IN COMS   -- Proceso 60
ENABLE P080 IN COMS   -- Especiales corporativos
ENABLE P091 IN COMS   -- Garbage/limpieza
ENABLE P093 IN COMS   -- Scrambling/seguridad

-- Condicionales:
IF DIA1MES:     ENABLE P015   -- proceso de inicio de mes (DIA1MES = primer día hábil)
IF Telethon:    ENABLE P045, P046 (ver RN-S500-106)
```

**Vocabulario en la fórmula**
- `SUBETODOS`: subroutine WFL de habilitación masiva de programas
- `ENABLE {pgm} IN COMS`: instrucción WFL para registrar un programa como disponible en COMS
- `COMS`: Communication Management System de Unisys; gestiona los tres LINCOMS: P010 (primario), P020 (secundario), P280 (terciario)
- `DIA1MES`: flag del primer día hábil del mes (calculado en sección FECHAS del WFL)

**Excepciones documentadas**
- P015 solo se habilita en DIA1MES; ejecuta el procesamiento especial de inicio de mes (reconciliación, apertura de ciclo)
- P280 (LINCOM terciario) no aparece en SUBETODOS explícitamente; se activa por un mecanismo separado de failover
- **Riesgo de migración**: el orden de habilitación en COMS debe respetarse; habilitar P020 antes de P010 podría redirigir tráfico prematuramente al gateway secundario

**Estado validación** `[EXTRAÍDA-PENDIENTE-HITL]`

---

## 4. Resumen de la Wave 1

| Métrica | Valor |
|---------|-------|
| Reglas extraídas en esta wave | **29** (RN-S500-079 → RN-S500-107) |
| Programas cubiertos | P130 (25 reglas) + WFL LINEA (4 reglas) |
| Reglas de contabilidad GL | 6 (RN-S500-080, 091, 092, 093, 094, 089) |
| Reglas de ISR / SAT | 4 (RN-S500-089, 090, 092, 088) |
| Reglas de comisiones / CONDUSEF | 7 (RN-S500-096→103) |
| Reglas de rendimientos / CNBV | 7 (RN-S500-083→088, 095) |
| Reglas de control / calendario | 5 (RN-S500-079, 081, 104→107) |
| Reglas con riesgo de migración documentado | **11** |
| Total acumulado S500 (HTML + wave 1) | **107 reglas** |
| Cobertura estimada S500 | ~10% (2/20+ programas P0/P1 cubiertos parcialmente) |

### Riesgos de migración identificados (top 5 de esta wave)

| # | Riesgo | Regla(s) | Severidad |
|---|--------|---------|-----------|
| 1 | Factor 36000 hardcoded (base 360 días) — cambio regulatorio a 365 requiere COMPUTE multi-archivo | RN-S500-088 | ALTA |
| 2 | Cláusula ROUNDED en conversiones FX — Java debe usar `RoundingMode.HALF_UP` exactamente | RN-S500-094 | ALTA |
| 3 | LIBOR como tasa de referencia en contratos vigentes — riesgo post-2021 | RN-S500-082 | ALTA |
| 4 | OCCURS 210 en S080 (ESQCOM) — límite estructural hardcoded | RN-S500-099, 103 | MEDIA |
| 5 | Archivo DMSII como feature flag (Telethon) — sin mecanismo moderno equivalente | RN-S500-106 | MEDIA |

### Próximas waves recomendadas

| Wave | Programas | Reglas estimadas | Prioridad |
|------|-----------|-----------------|-----------|
| Wave 2 | P142 (inversiones) + P144 (cheques especiales) | ~60 | P0 |
| Wave 3 | P010 (gateway transaccional, 52K LOC) | ~70 | P0 |
| Wave 4 | S151REGISTRA (librería GL cross-sistema) + P103 (fraude) | ~30 | P0 |
| Wave 5 | P330 + P050 + P080 + P015 | ~60 | P1 |
| Wave 6 | P038, P091, P093, P045, P046 | ~40 | P2 |

---

*Extraído por: Specialist - Business Rules (Gemelo Cognitivo Capa 4 — Intención) · 2026-07-16 · Banamex S500 · Formato canónico v2*

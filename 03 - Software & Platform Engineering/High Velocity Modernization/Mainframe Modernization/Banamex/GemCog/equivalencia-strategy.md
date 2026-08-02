# Capa 7 — Equivalencia Funcional · Estrategia Golden-Master
> Gemelo Cognitivo GemCog v2.2 · SPE-MM-001 (S500) + SPE-MM-002 (S151) · Banamex
> Estado: DRAFT · Requiere firma: Software Engineering SME + Finance/Risk Officer + Regulatory (CNBV)
> Indexado: ✅ 2026-07-17 — Capa 7 — estrategia de equivalencia

---

## 1. Objetivo y Contexto

La Capa 7 cierra el ciclo del Gemelo Cognitivo: los contratos sembrados en Capa 6 (OpenAPI 3.1 / AsyncAPI 2.6) se convierten en el **golden-master** que define qué significa "equivalente" para el target Java.

**Threshold obligatorio**: ≥ **99.99%** de equivalencia por campo y por BC (DoD-SPE-MM-01).
Esto es 5× más estricto que Application Modernization (99.95%) porque toda divergencia en S151 genera un asiento de ajuste auditable ante CNBV.

---

## 2. Framework Golden-Master

### 2.1 Inputs

| Input | Fuente | Período mínimo |
|-------|--------|----------------|
| Dataset de producción reproducible | Snapshot de S500+S151 en DMSII | 6 meses calendario |
| Reglas de negocio | `rules-report-gemcog.html` — 68 reglas COBOL | Todas |
| Journeys orquestadores | `journeys-gemcog.html` — 20 journeys | Todos |
| Contratos API | Capas 6 · OpenAPI/AsyncAPI por BC | Versión 0.1.0-seed |
| Campos COMP-3 | `equivalencia-strategy.md` §3 | 495 campos |

### 2.2 Reglas de comparación

| Tipo de campo legacy | Tipo Java target | Regla de comparación |
|----------------------|-----------------|----------------------|
| `PIC S9(N)V9(4) COMP-3` (importe monetario) | `BigDecimal` serializado como `String` | Comparación exacta a 4 decimales · `RoundingMode.HALF_EVEN` |
| `PIC 9(8)` (fecha AAAAMMDD) | `LocalDate` | Equivalencia calendario · validar era antes/después de 2000 |
| `PIC 9(6)` (fecha AAMMDD legacy) | `LocalDate` con ajuste CRONOS2K | Ver §4 — programas marcados `@LegacyY2kPatch` |
| `PIC X(N)` (alfanumérico) | `String` | Trim de espacios trailing · comparación exacta |
| `PIC 9(N)` (entero) | `Long` / `Integer` | Igualdad exacta |
| Indicadores `PIC X(1)` (Y/N/S/N) | `Boolean` / `enum` | Mapeo declarado en ADR-SPE-MM-002 |

### 2.3 Módulos de soporte (`banamex-test-support`)

```java
// Comparación de importe monetario
GoldenMasterAssertion.assertMonetaryEquals(legacyValue, targetValue, EquivalenceThreshold.BANKING);

// Threshold bancario
EquivalenceThreshold.BANKING = 0.9999;  // ≥ 99.99%

// Anotaciones de trazabilidad
@GemcogSource(sistema="S500", programa="P130", vocab="SALDO")
@LegacyY2kPatch(programas={"L011","P167","P177"}, reviewRequired=true)
```

---

## 3. Distribución de los 495 Campos COMP-3 por Bounded Context

### Resumen por BC

| BC | Nombre | Sistema | Wave | Campos COMP-3 | % del total | Tier-1 (crítico) |
|----|--------|---------|------|--------------|-------------|-----------------|
| BC-01 | Captación | S500 | 1 | **191** | 38.6% | 87 |
| BC-02 | Control | S500 | 1 | **24** | 4.8% | 4 |
| BC-03 | Tarjetas | S500 | 1 | **44** | 8.9% | 18 |
| BC-05 | GL Account | S151 | 2 | **105** | 21.2% | 62 |
| BC-06 | Movimientos | S151 | 2 | **96** | 19.4% | 71 |
| BC-09 | Ajustes GL | S151 | 2 | **35** | 7.1% | 35 |
| **Total** | | | | **495** | 100% | **277** |

> **BC-08 Reportería** pendiente (journeys insuficientes para mapeado Capa 6 → sin contratos → sin golden-master definido).

### Campos Tier-1 por BC (muestra representativa)

**BC-01 Captación** (191 campos · 87 Tier-1):
- `SALDO-DISPONIBLE`, `SALDO-CONTABLE`, `IMPORTE-DEPOSITO`, `IMPORTE-RETIRO`, `IMPORTE-TRANSFERENCIA`
- `IMPORTE-DISPERSION`, `SALDO-PROMEDIO`, `TASA-INTERES`, `COMISION`, `RENDIMIENTO`
- Todos los importes de P130 (15K LOC) y P142 (14K LOC) que alimentan `S151REGISTRA`

**BC-05 GL Account** (105 campos · 62 Tier-1):
- `SALDO-CONTABLE-GL`, `SALDO-PERIODO`, `IMPORTE-MOVIMIENTO-GL`, `TOTAL-CVETRA`
- `SALDO-BILATERAL-CITI` (BD13BIFIN), `POSICION-FINANCIERA`
- Todos los campos de BD02ADSALDO (saldos diarios GL) y BD11SDOS151 (saldos período)

**BC-06 Movimientos** (96 campos · 71 Tier-1):
- `IMPORTE-MOVIMIENTO`, `IMPORTE-ACUMULADO`, `TOTAL-MOVIMIENTOS-DIA`
- Todos los campos de BD10MOVDIA151 con tipo `PIC S9(N)V9(4) COMP-3`
- DISEÑO-GENERICO: los mismos campos deben ser equivalentes para las 19 instancias

**BC-09 Ajustes** (35 campos · 35 Tier-1 — todos críticos):
- `IMPORTE-AJUSTE`, `IMPORTE-DIFERENCIA`, `TOTAL-AJUSTES-DIA`
- 100% críticos: todo ajuste GL genera asiento auditable CNBV

---

## 4. Programas CRONOS2K — Riesgo de Fechas

Los siguientes programas contienen el parche Y2K (`%INICIA CODIGO DE RENOVACION CRONOS 2000`). Sus campos de fecha `PIC 9(6)` requieren revisión humana antes de cutover.

| Programa | Sistema | LOC | BC afectado | Tipo de riesgo |
|----------|---------|-----|-------------|----------------|
| `L002R2` | S151 | - | BC-04 (ACL) | Interfaz S151REGISTRA — fechas de posteo GL |
| `L002R3` | S151 | - | BC-04 (ACL) | Interfaz S151REGISTRA — versión 3 |
| `L002R4` | S151 | - | BC-04 (ACL) | Interfaz S151REGISTRA — versión 4 |
| `L002R5` | S151 | - | BC-04 (ACL) | Interfaz S151REGISTRA — versión activa |
| `L011` | S151 | 7.2K | BC-06 | Consulta BD10 — fechas de movimientos GL |
| `P167` | S151 | - | BC-06 | Proceso GL — fechas de movimientos |
| `P177` | S151 | - | BC-06 | Proceso GL — fechas de cierre |
| `P178` | S151 | - | BC-06 | Proceso GL — fechas de reconciliación |
| `P195` | S151 | - | BC-06 | Migración saldos — fechas de corte |
| `P197` | S151 | - | BC-06 | Migración saldos — fechas de período |

**Regla de test obligatoria**: para cada campo de fecha en estos programas, el dataset de golden-master debe incluir casos que crucen el límite año 2000 en ambas direcciones. Los campos resultantes se anotan `@LegacyY2kPatch(reviewRequired=true)` — requieren revisión humana antes del cutover a producción.

---

## 5. Plan de Parallel-Run (≥ 3 Meses)

### Arquitectura de parallel-run

```
  Transacción entrante
         │
         ├──► [LEGACY S500/S151] ──► resultado legacy
         │
         └──► [TARGET Java BCs] ──► resultado target
                                           │
                                    [COMPARATOR]
                                           │
                              ┌────────────┴───────────┐
                          equivalente              divergencia
                              │                       │
                         log match             alert + log
                                               CNBV audit trail
```

### Calendario (Wave 1 primero)

| Mes | Actividad | BCs activos | Sign-off |
|-----|-----------|-------------|---------|
| Mes 1 | Parallel-run Wave 1 · shadow mode (S500 procesa, target observa) | BC-01, BC-02, BC-03 | Arquitecto + QA |
| Mes 2 | Wave 1 · comparación activa · primeras divergencias corregidas | BC-01, BC-02, BC-03 | QA + Risk Officer |
| Mes 3 | Wave 1 · estabilización ≥ 99.99% · sign-off finance | BC-01, BC-02, BC-03 | **Finance/Risk (mensual)** |
| Mes 4 | Parallel-run Wave 2 · shadow mode | BC-05, BC-06, BC-09 | Arquitecto + QA |
| Mes 5 | Wave 2 · comparación activa · ADR-003 y ADR-004 resueltos | BC-05, BC-06, BC-09 | QA + Risk Officer |
| Mes 6 | Wave 2 · estabilización ≥ 99.99% · sign-off finance | BC-05, BC-06, BC-09 | **Finance/Risk (mensual)** |

**Reconciliación diaria**: el comparator genera un reporte de divergencias cada día. Finance/Risk firma la reconciliación mensualmente.

### Métricas de salud del parallel-run

| Métrica | Umbral de salida | Alerta |
|---------|-----------------|--------|
| Equivalencia global por BC | ≥ 99.99% | < 99.99% → block cutover |
| Divergencias Tier-1 abiertas | 0 | ≥ 1 → P1 inmediato |
| Divergencias Tier-2 pendientes | 0 al cierre de mes | > 5 → revisión semanal |
| Latencia target vs legacy | ≤ SLA legacy | > SLA → block cutover |
| Reconciliation daily success | ≥ 99.99% | < 99.99% → alert |

---

## 6. Taxonomía de Divergencias

| Tier | Nombre | Criterio | Acción |
|------|--------|----------|--------|
| **Tier-1** | CRÍTICO | Campo monetario Tier-1 difiere · afecta balance o posteo GL | P1 inmediato · block cutover · corrección obligatoria |
| **Tier-2** | REGULATORIO | Campo aparece en reporte CNBV · no afecta balance | CR de aceptación firmado por Regulatory + Risk antes de cutover |
| **Tier-3** | OPERACIONAL | Campo afecta procesamiento interno · no visible al regulador | Bug en backlog · aceptable con justificación documentada |
| **Tier-4** | INFORMATIVO | Campo de display o código · no afecta lógica | Puede cerrar sin corrección si stakeholder acepta |

### Casos especiales de divergencia aceptable

- **Timestamps de procesamiento**: el legacy usa reloj Unisys MCP; el target usa `Instant.now()`. Divergencia esperada y documentada — no impacta el valor del movimiento.
- **Orden de registros sin PK natural**: DMSII no garantiza orden en sets sin índice. El comparator debe ordenar antes de comparar.
- **Espacios trailing en alfanuméricos**: COBOL `PIC X(N)` rellena con espacios. El target trimea. Regla: comparar post-trim.

---

## 7. Integración con Capa 6 (contratos como golden-master)

Cada endpoint de los contratos Capa 6 define implícitamente un test de equivalencia:

| Contrato | Operación | Campo clave de equivalencia |
|----------|-----------|----------------------------|
| BC-01 · `/cuentas-captacion/{id}/saldo` | GET saldo | `SaldoCuenta.importe` (COMP-3 Tier-1) |
| BC-01 · `/depositos` POST | Depósito | `resultado.nuevoSaldo` vs legacy SALDO-DISPONIBLE |
| BC-05 · `/cuentas-gl/{id}/saldo-contable` | GET saldo GL | `SaldoContable.importe` (COMP-3 Tier-1) |
| BC-06 · `s151/movimientos/registrado` | Kafka event | `MovimientoContable.importe` = legacy IMPORTE-MOVIMIENTO |
| BC-09 · `/ajustes-contables` POST | Ajuste GL | `AjusteContable.importe` negativo = cargo, positivo = abono |

---

## 8. Firma y Estado

| Rol | Firma | Fecha |
|-----|-------|-------|
| Software Engineering SME | ⬜ Pendiente | — |
| Finance / Risk Officer (Banamex) | ⬜ Pendiente | — |
| Regulatory (CNBV compliance) | ⬜ Pendiente | — |
| Arquitecto de Solución | ⬜ Pendiente | — |

**[DRAFT — no ejecutar parallel-run sin firmas de Finance/Risk y Regulatory]**

---

*Capa 7 Equivalencia · GemCog v2.2 · Specialist - Domain Seeding → input para Specialist - Equivalence Testing*
*Threshold: DoD-SPE-MM-01 ≥ 99.99% · Parallel-run: DoD-SPE-MM-02 ≥ 3 meses · Versión: 0.1-DRAFT · 2026-07-14*

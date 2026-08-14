# D03 · Créditos — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — BanCoppel (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de BanCoppel antes de pasar a Etapa 2.
---


## Perfil de riesgo del dominio

| Dimensión | Valor | Nivel |
|-----------|-------|-------|
| Riesgo global | CRÍTICO | — |
| Wave de migración | Wave 4 | — |
| SPs en el dominio | 380 | — |
| LOC total | 687,797 | — |
| Ocurrencias de MONEY | 13,500 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 1,586 | 🟠 ALTO |
| Ocurrencias de SERIAL | 109 | 🟠 ALTO |
| Llamadas cross-DB salientes | 1,099 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdicred`:** 13,500

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdicred`:** 1,099

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdicred` → `bdicheq` | 288 | MEDIO |
| `bdicred` → `bdinteg` | 226 | MEDIO |
| `bdicred` → `bdisolic` | 212 | MEDIO |
| `bdicred` → `bdicobranza` | 152 | MEDIO |
| `bdicred` → `bdimnsj` | 77 | MEDIO |
| `bdicred` → `bdisitesp` | 37 | MEDIO |
| `bdicred` → `bdicont` | 35 | MEDIO |
| `bdicred` → `intercard` | 31 | MEDIO |
| `bdicred` → `bdiburo` | 22 | MEDIO |
| `bdicred` → `bdiauditor` | 16 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdicred`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 1,586

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟠 ALTO
**Ocurrencias:** 109

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `sp_respalda_credito_rr` | 9,811 LOC | 8 callers | 29 callees | Dificultad: EXTREMA |
| `sp_respalda_credito_pp` | 9,607 LOC | 4 callers | 29 callees | Dificultad: EXTREMA |
| `respalda_creditocrd` | 9,118 LOC | 9 callers | 29 callees | Dificultad: EXTREMA |
| `reversioncrd_new` | 8,918 LOC | 1 callers | 29 callees | Dificultad: EXTREMA |
| `cancelatarjeta_web` | 8,806 LOC | 0 callers | 40 callees | Dificultad: EXTREMA |
| `cons_cta_o_tar_per_web` | 8,682 LOC | 0 callers | 40 callees | Dificultad: EXTREMA |
| `sp_consultadatos_motor_pp` | 8,254 LOC | 0 callers | 39 callees | Dificultad: EXTREMA |
| `ugenera_layoutedocuentacrd` | 8,084 LOC | 0 callers | 23 callees | Dificultad: EXTREMA |
| `reversioncrd` | 8,045 LOC | 48 callers | 29 callees | Dificultad: EXTREMA |
| `ugenera_layoutedocuentacrdpp` | 7,546 LOC | 0 callers | 23 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdicred` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Créditos?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicred_*.sql + callgraph-data.json*

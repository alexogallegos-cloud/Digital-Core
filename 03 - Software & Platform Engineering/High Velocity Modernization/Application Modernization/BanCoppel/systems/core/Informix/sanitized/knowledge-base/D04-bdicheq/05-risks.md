# D04 · Cheques / Cuentas — Riesgos de Equivalencia

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — LegacyCore (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de LegacyCore antes de pasar a Etapa 2.
---


## Perfil de riesgo del dominio

| Dimensión | Valor | Nivel |
|-----------|-------|-------|
| Riesgo global | CRÍTICO | — |
| Wave de migración | Wave 4 | — |
| SPs en el dominio | 111 | — |
| LOC total | 333,811 | — |
| Ocurrencias de MONEY | 18,433 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 918 | 🟠 ALTO |
| Ocurrencias de SERIAL | 23 | 🟠 ALTO |
| Llamadas cross-DB salientes | 512 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdicheq`:** 18,433

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería LegacyCore antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdicheq`:** 512

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdicheq` → `bdinteg` | 130 | MEDIO |
| `bdicheq` → `bdispei` | 74 | MEDIO |
| `bdicheq` → `bdimnsj` | 72 | MEDIO |
| `bdicheq` → `bdicred` | 45 | MEDIO |
| `bdicheq` → `bdiprog` | 43 | MEDIO |
| `bdicheq` → `bdicnweb` | 31 | MEDIO |
| `bdicheq` → `bdisac` | 28 | MEDIO |
| `bdicheq` → `bdidomi` | 20 | MEDIO |
| `bdicheq` → `bditrans` | 19 | MEDIO |
| `bdicheq` → `bditrapres` | 10 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdicheq`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 918

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟠 ALTO
**Ocurrencias:** 23

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `ischar` | 83,661 LOC | 12 callers | 97 callees | Dificultad: EXTREMA |
| `sp_notif_cambios_portacec` | 11,423 LOC | 1 callers | 4 callees | Dificultad: EXTREMA |
| `reversion_web` | 10,074 LOC | 6 callers | 18 callees | Dificultad: EXTREMA |
| `cargo_ref_pos` | 8,933 LOC | 4 callers | 28 callees | Dificultad: EXTREMA |
| `reversion_td` | 8,779 LOC | 1 callers | 18 callees | Dificultad: EXTREMA |
| `cargon_ref` | 8,587 LOC | 70 callers | 24 callees | Dificultad: EXTREMA |
| `reversion_sif` | 8,215 LOC | 37 callers | 18 callees | Dificultad: EXTREMA |
| `sp_nom_gen_mov_mes` | 7,528 LOC | 5 callers | 23 callees | Dificultad: EXTREMA |
| `cargon_ref_web` | 7,523 LOC | 3 callers | 24 callees | Dificultad: EXTREMA |
| `reversion` | 7,312 LOC | 377 callers | 18 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdicheq` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Cheques / Cuentas?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicheq_*.sql + callgraph-data.json*

# D05 · Saldos y Cuentas — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Riesgo global | ALTO | — |
| Wave de migración | Wave 3 | — |
| SPs en el dominio | 145 | — |
| LOC total | 378,076 | — |
| Ocurrencias de MONEY | 22,232 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 2,607 | 🟠 ALTO |
| Ocurrencias de SERIAL | 6 | 🟠 ALTO |
| Llamadas cross-DB salientes | 642 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdisac`:** 22,232

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdisac`:** 642

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdisac` → `bdicheq` | 331 | MEDIO |
| `bdisac` → `bdinteg` | 145 | MEDIO |
| `bdisac` → `bdicred` | 49 | MEDIO |
| `bdisac` → `bditef` | 42 | MEDIO |
| `bdisac` → `bdicnweb` | 29 | MEDIO |
| `bdisac` → `bdimnsj` | 23 | MEDIO |
| `bdisac` → `bdinvers` | 6 | MEDIO |
| `bdisac` → `bditrans` | 6 | MEDIO |
| `bdisac` → `bdisuc` | 6 | MEDIO |
| `bdisac` → `bdispei` | 4 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdisac`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 2,607

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟠 ALTO
**Ocurrencias:** 6

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `sp_reportebts_edocta` | 10,152 LOC | 52 callers | 18 callees | Dificultad: EXTREMA |
| `sp_sacreportemensualsuk` | 8,227 LOC | 0 callers | 18 callees | Dificultad: EXTREMA |
| `sp_sacreportesemanalsuk` | 8,153 LOC | 0 callers | 18 callees | Dificultad: EXTREMA |
| `sp_sacreportesremesasnoconciliadasbtsrev` | 7,983 LOC | 26 callers | 18 callees | Dificultad: EXTREMA |
| `sp_grabapagocoppel` | 7,295 LOC | 23 callers | 18 callees | Dificultad: EXTREMA |
| `sp_sacreportemensual` | 7,159 LOC | 31 callers | 18 callees | Dificultad: EXTREMA |
| `sp_sacreportesemanal` | 7,085 LOC | 19 callers | 18 callees | Dificultad: EXTREMA |
| `sp_wu_truncacatalogosdas` | 6,913 LOC | 0 callers | 18 callees | Dificultad: EXTREMA |
| `sp_wu_obtparamdas` | 6,776 LOC | 0 callers | 18 callees | Dificultad: EXTREMA |
| `sp_obtiene_bitacoragdf` | 6,576 LOC | 0 callers | 18 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdisac` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Saldos y Cuentas?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisac_*.sql + callgraph-data.json*

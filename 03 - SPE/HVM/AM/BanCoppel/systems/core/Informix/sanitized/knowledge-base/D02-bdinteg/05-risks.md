# D02 · Integración y Autenticación — Riesgos de Equivalencia

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Wave de migración | Wave 5 | — |
| SPs en el dominio | 220 | — |
| LOC total | 464,892 | — |
| Ocurrencias de MONEY | 18,511 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 25,910 | 🟠 ALTO |
| Ocurrencias de SERIAL | 4,448 | 🟠 ALTO |
| Llamadas cross-DB salientes | 787 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdinteg`:** 18,511

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería LegacyCore antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdinteg`:** 787

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdinteg` → `bdicheq` | 194 | MEDIO |
| `bdinteg` → `bdicred` | 165 | MEDIO |
| `bdinteg` → `bdimnsj` | 79 | MEDIO |
| `bdinteg` → `bdisolic` | 51 | MEDIO |
| `bdinteg` → `bdisitesp` | 40 | MEDIO |
| `bdinteg` → `bdibpi` | 36 | MEDIO |
| `bdinteg` → `bdicnweb` | 35 | MEDIO |
| `bdinteg` → `bdisac` | 31 | MEDIO |
| `bdinteg` → `bdiburo` | 24 | MEDIO |
| `bdinteg` → `bdicobranza` | 23 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdinteg`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 25,910

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟠 ALTO
**Ocurrencias:** 4,448

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `sysbldsqltextin` | 213,929 LOC | 0 callers | 134 callees | Dificultad: EXTREMA |
| `consprodcte` | 7,396 LOC | 0 callers | 15 callees | Dificultad: EXTREMA |
| `consinteg` | 7,220 LOC | 0 callers | 15 callees | Dificultad: EXTREMA |
| `consinteg_web` | 6,865 LOC | 0 callers | 15 callees | Dificultad: EXTREMA |
| `sp_cnsif_consprodcte` | 6,526 LOC | 205 callers | 15 callees | Dificultad: EXTREMA |
| `sp_cnsif_consprodcte_fstatus` | 5,653 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `sp_cnsif_consaldoscap` | 5,253 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `sp_cnsif_consaldoscap3` | 4,929 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `sp_cnsif_consaldoscap2` | 4,563 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `sp_consulta_datos_cte_grupo` | 4,216 LOC | 0 callers | 13 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdinteg` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Integración y Autenticación?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdinteg_*.sql + callgraph-data.json*

# D08 · SPEI — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Wave de migración | Wave 2 | — |
| SPs en el dominio | 46 | — |
| LOC total | 53,582 | — |
| Ocurrencias de MONEY | 343 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 122 | 🟠 ALTO |
| Ocurrencias de SERIAL | 0 | 🟢 BAJO |
| Llamadas cross-DB salientes | 118 | 🟡 MEDIO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdispei`:** 343

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟡 MEDIO
**Llamadas cross-DB desde `bdispei`:** 118

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdispei` → `bdicheq` | 67 | MEDIO |
| `bdispei` → `bdimnsj` | 24 | MEDIO |
| `bdispei` → `bdicred` | 9 | MEDIO |
| `bdispei` → `bdinteg` | 9 | MEDIO |
| `bdispei` → `bditef` | 8 | MEDIO |
| `bdispei` → `bdicont` | 1 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdispei`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 122

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟡 BAJO
**Ocurrencias:** 0

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `spei_aplicaordenpago` | 4,899 LOC | 0 callers | 15 callees | Dificultad: EXTREMA |
| `spei_reccancelacion` | 4,240 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `spei_devcodi` | 4,054 LOC | 0 callers | 10 callees | Dificultad: EXTREMA |
| `spei_recdevolucion` | 3,954 LOC | 2 callers | 14 callees | Dificultad: EXTREMA |
| `spei_recextemporanea` | 3,733 LOC | 2 callers | 14 callees | Dificultad: EXTREMA |
| `spei_recordenpago` | 3,415 LOC | 2 callers | 14 callees | Dificultad: EXTREMA |
| `spei_recerrorescodi` | 2,707 LOC | 27 callers | 10 callees | Dificultad: EXTREMA |
| `sp_regordenctecte_bex_codi_exp1` | 2,310 LOC | 0 callers | 10 callees | Dificultad: EXTREMA |
| `spei_recordenpago_ws` | 2,295 LOC | 0 callers | 12 callees | Dificultad: EXTREMA |
| `sp_regordenctecte_bex_codi` | 2,291 LOC | 0 callers | 9 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdispei` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para SPEI?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdispei_*.sql + callgraph-data.json*

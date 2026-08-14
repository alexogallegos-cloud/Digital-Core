# D11 · Cobranza — Riesgos de Equivalencia

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Riesgo global | MEDIO | — |
| Wave de migración | Wave 2 | — |
| SPs en el dominio | 82 | — |
| LOC total | 113,323 | — |
| Ocurrencias de MONEY | 55 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 376 | 🟠 ALTO |
| Ocurrencias de SERIAL | 2 | 🟡 MEDIO |
| Llamadas cross-DB salientes | 223 | 🟡 MEDIO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdicobranza`:** 55

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería LegacyCore antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟡 MEDIO
**Llamadas cross-DB desde `bdicobranza`:** 223

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdicobranza` → `bdicred` | 74 | MEDIO |
| `bdicobranza` → `bdinteg` | 57 | MEDIO |
| `bdicobranza` → `bdimnsj` | 53 | MEDIO |
| `bdicobranza` → `bdisitesp` | 27 | MEDIO |
| `bdicobranza` → `bdimonitorcob` | 12 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdicobranza`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 376

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟡 BAJO
**Ocurrencias:** 2

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `fn_formaretiquetaxml` | 32,559 LOC | 0 callers | 43 callees | Dificultad: EXTREMA |
| `sp_layout_in_triad_cob` | 6,686 LOC | 0 callers | 5 callees | Dificultad: EXTREMA |
| `sp_rep_cobvent_ctesvencsuc` | 2,673 LOC | 0 callers | 4 callees | Dificultad: EXTREMA |
| `sp_generafechpagoreestructura_baja` | 2,585 LOC | 0 callers | 8 callees | Dificultad: EXTREMA |
| `sp_consultatargetphone` | 2,492 LOC | 0 callers | 5 callees | Dificultad: EXTREMA |
| `sp_rep_cobvent_ctetitular` | 2,426 LOC | 0 callers | 4 callees | Dificultad: EXTREMA |
| `sp_obtienecobranzaadministrativa` | 2,313 LOC | 0 callers | 5 callees | Dificultad: EXTREMA |
| `sp_generafechpagoreestructura` | 2,201 LOC | 0 callers | 5 callees | Dificultad: EXTREMA |
| `sp_indicadores_hist_triad_primera_vez` | 2,185 LOC | 0 callers | 3 callees | Dificultad: EXTREMA |
| `sp_rep_cobvent_mtvosrechazo` | 2,182 LOC | 0 callers | 4 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdicobranza` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Cobranza?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicobranza_*.sql + callgraph-data.json*

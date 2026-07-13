# D06 · Solicitudes — Riesgos de Equivalencia

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| SPs en el dominio | 84 | — |
| LOC total | 65,541 | — |
| Ocurrencias de MONEY | 710 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 188 | 🟠 ALTO |
| Ocurrencias de SERIAL | 1 | 🟡 MEDIO |
| Llamadas cross-DB salientes | 250 | 🟡 MEDIO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdisolic`:** 710

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟡 MEDIO
**Llamadas cross-DB desde `bdisolic`:** 250

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdisolic` → `bdicred` | 89 | MEDIO |
| `bdisolic` → `bdinteg` | 81 | MEDIO |
| `bdisolic` → `bdimnsj` | 23 | MEDIO |
| `bdisolic` → `bdiburo` | 16 | MEDIO |
| `bdisolic` → `bdiprospectos` | 15 | MEDIO |
| `bdisolic` → `bdicheq` | 12 | MEDIO |
| `bdisolic` → `bdicobranza` | 11 | MEDIO |
| `bdisolic` → `bdisitesp` | 2 | MEDIO |
| `bdisolic` → `bdisac` | 1 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdisolic`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 188

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟡 BAJO
**Ocurrencias:** 1

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `califica_scoring2_cjunk` | 3,068 LOC | 167 callers | 19 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk` | 2,798 LOC | 6 callers | 17 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_motor` | 2,364 LOC | 1 callers | 16 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_precal_opt` | 2,307 LOC | 0 callers | 16 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_precal` | 2,281 LOC | 1 callers | 15 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_precal_opt_motor` | 2,278 LOC | 0 callers | 15 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_pba` | 2,251 LOC | 0 callers | 14 callees | Dificultad: EXTREMA |
| `califica_scoring_cjunk_pbagh` | 1,993 LOC | 0 callers | 15 callees | Dificultad: ALTA |
| `determina_lincred_tc_cjunk` | 1,832 LOC | 208 callers | 6 callees | Dificultad: ALTA |
| `sp_obtiene_productos` | 1,800 LOC | 0 callers | 9 callees | Dificultad: ALTA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdisolic` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Solicitudes?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisolic_*.sql + callgraph-data.json*

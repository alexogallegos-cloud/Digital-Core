# D10 · Sucursales — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| SPs en el dominio | 37 | — |
| LOC total | 37,901 | — |
| Ocurrencias de MONEY | 1,455 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 142 | 🟠 ALTO |
| Ocurrencias de SERIAL | 4 | 🟡 MEDIO |
| Llamadas cross-DB salientes | 40 | 🟡 MEDIO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdisuc`:** 1,455

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟡 MEDIO
**Llamadas cross-DB desde `bdisuc`:** 40

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdisuc` → `bdinteg` | 27 | MEDIO |
| `bdisuc` → `bdicont` | 11 | MEDIO |
| `bdisuc` → `bdmis` | 1 | MEDIO |
| `bdisuc` → `bdicheq` | 1 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdisuc`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 142

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟡 BAJO
**Ocurrencias:** 4

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `sp_consultadatospiezas_bym2` | 2,164 LOC | 376 callers | 0 callees | Dificultad: EXTREMA |
| `sp_consulta_sucxcg2` | 2,052 LOC | 39 callers | 1 callees | Dificultad: EXTREMA |
| `sp_catsecciones_oemn` | 1,990 LOC | 0 callers | 1 callees | Dificultad: ALTA |
| `sp_ope_actualizacuentas` | 1,906 LOC | 0 callers | 1 callees | Dificultad: ALTA |
| `sp_reiniciapaseatm` | 1,906 LOC | 0 callers | 2 callees | Dificultad: ALTA |
| `pasecont_web_2` | 1,870 LOC | 0 callers | 2 callees | Dificultad: ALTA |
| `sp_tipo_servicio_etv2` | 1,859 LOC | 82 callers | 1 callees | Dificultad: ALTA |
| `sp_generasecciones_oemn` | 1,819 LOC | 0 callers | 1 callees | Dificultad: ALTA |
| `sp_ope_actualizanivcuentas` | 1,741 LOC | 0 callers | 1 callees | Dificultad: ALTA |
| `sp_ope_actualizatransportadora` | 1,576 LOC | 0 callers | 1 callees | Dificultad: ALTA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdisuc` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Sucursales?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdisuc_*.sql + callgraph-data.json*

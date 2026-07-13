# D12 · Contabilidad — Riesgos de Equivalencia

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicont` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Wave de migración | Wave 4 | — |
| SPs en el dominio | 19 | — |
| LOC total | 51,885 | — |
| Ocurrencias de MONEY | 924 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 101 | 🟠 ALTO |
| Ocurrencias de SERIAL | 0 | 🟢 BAJO |
| Llamadas cross-DB salientes | 682 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdicont`:** 924

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdicont`:** 682

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdicont` → `bdicnweb` | 639 | MEDIO |
| `bdicont` → `bdinteg` | 43 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdicont`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 101

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
| `sp_cont_conssaldosdiariosb4` | 4,462 LOC | 0 callers | 84 callees | Dificultad: EXTREMA |
| `sp_cont_productotransaccionb5` | 3,990 LOC | 0 callers | 72 callees | Dificultad: EXTREMA |
| `sp_cont_cargamovimientob3` | 3,693 LOC | 0 callers | 63 callees | Dificultad: EXTREMA |
| `sp_cont_catalogob3` | 3,356 LOC | 0 callers | 55 callees | Dificultad: EXTREMA |
| `sp_cont_divisasb4` | 3,281 LOC | 0 callers | 55 callees | Dificultad: EXTREMA |
| `sp_cont_empresasb3` | 3,226 LOC | 0 callers | 55 callees | Dificultad: EXTREMA |
| `sp_si_empresasb4` | 3,161 LOC | 1 callers | 55 callees | Dificultad: EXTREMA |
| `sp_gen_devob3` | 3,091 LOC | 0 callers | 55 callees | Dificultad: EXTREMA |
| `sp_cam_cargamanualb3` | 2,858 LOC | 0 callers | 50 callees | Dificultad: EXTREMA |
| `sp_cam_monitorarchivosb3` | 2,660 LOC | 0 callers | 37 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdicont` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Contabilidad?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicont_*.sql + callgraph-data.json*

# D01 · Canal Digital Web — Riesgos de Equivalencia

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Riesgo global | ALTO | — |
| Wave de migración | ÚLTIMO | — |
| SPs en el dominio | 2,122 | — |
| LOC total | 19,043,773 | — |
| Ocurrencias de MONEY | 145,721 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 24,850 | 🟠 ALTO |
| Ocurrencias de SERIAL | 593 | 🟠 ALTO |
| Llamadas cross-DB salientes | 52,006 | 🔴 CRÍTICO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdicnweb`:** 145,721

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería LegacyCore antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🔴 CRÍTICO
**Llamadas cross-DB desde `bdicnweb`:** 52,006

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdicnweb` → `bdinteg` | 15,304 | CRÍTICO |
| `bdicnweb` → `bdicred` | 10,903 | CRÍTICO |
| `bdicnweb` → `bdisuc` | 6,094 | CRÍTICO |
| `bdicnweb` → `bdirech` | 3,541 | ALTO |
| `bdicnweb` → `bdisac` | 3,464 | ALTO |
| `bdicnweb` → `bdicheq` | 2,346 | ALTO |
| `bdicnweb` → `bdisolic` | 2,326 | ALTO |
| `bdicnweb` → `bditef` | 2,130 | ALTO |
| `bdicnweb` → `bdisitesp` | 1,755 | ALTO |
| `bdicnweb` → `bdimnsj` | 949 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdicnweb`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 24,850

Informix almacena timestamps sin zona horaria, asumiendo `America/Mexico_City` del servidor AIX. PostgreSQL `TIMESTAMP WITHOUT TIME ZONE` es equivalente, pero `TIMESTAMPTZ` (con zona horaria) aplicaría conversión automática a UTC, rompiendo la semántica temporal.

**Mitigación:**
- Usar exclusivamente `TIMESTAMP(5) WITHOUT TIME ZONE` en el target
- Verificar que el timezone del servidor AIX es `America/Mexico_City` antes del CDC
- No usar `TIMESTAMPTZ` en ningún campo migrado desde Informix

## R04 — Riesgo de secuencias: SERIAL

**Nivel:** 🟠 ALTO
**Ocurrencias:** 593

Informix `SERIAL` no decrementa al hacer `ROLLBACK` (igual que PostgreSQL `SEQUENCE`). Sin embargo, en el cutover, el valor actual del `SERIAL` debe migrarse con margen suficiente para evitar colisiones durante el período de parallel-run.

**Mitigación:**
- En el cutover, inicializar `SEQUENCE` en PostgreSQL con `MAX(id) * 1.5` del dato migrado
- Coordinar la ventana de migración para evitar inserciones concurrentes

## R05 — God procedures

**Nivel:** 🟠 ALTO
**Detectados (> 500 LOC):** 10

| SP | LOC | Fan-in | Fan-out | Esfuerzo |
|----|-----|--------|---------|----------|
| `sp_consultainforeportebc_detalleconsultas` | 50,524 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_cedulacontablenombre` | 50,418 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_conscedulasusuariosccl` | 50,344 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_usuariocedulacons` | 50,251 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_usuarioscedulasmantto` | 50,132 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_consreportesctasinactivasart61` | 49,998 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_consreportesctasinactivasart61_totales` | 49,912 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_consultafechasart61` | 49,845 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_verificastatusconsultafechasart61` | 49,653 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |
| `sp_reportebloqueoctasmasivocre` | 49,577 LOC | 0 callers | 124 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdicnweb` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Canal Digital Web?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql + callgraph-data.json*

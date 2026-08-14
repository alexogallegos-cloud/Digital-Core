# D07 · Aclaraciones — Riesgos de Equivalencia

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Wave de migración | Wave 2 | — |
| SPs en el dominio | 84 | — |
| LOC total | 412,868 | — |
| Ocurrencias de MONEY | 4,786 | 🔴 CRÍTICO |
| Ocurrencias de DATETIME | 1,904 | 🟠 ALTO |
| Ocurrencias de SERIAL | 0 | 🟢 BAJO |
| Llamadas cross-DB salientes | 858 | 🟠 ALTO |

## R01 — Riesgo financiero: tipo MONEY (rounding)

**Nivel:** 🔴 CRÍTICO
**Ocurrencias en `bdiaclaracion`:** 4,786

Informix `MONEY(p,s)` aplica redondeo bancario (half-even) implícito en el motor. PostgreSQL `NUMERIC(p,s)` usa half-up por defecto. En operaciones financieras acumuladas, la diferencia se propaga y genera discrepancias de conciliación.

**Mitigación:**
- Configurar `decimal.handling.mode=string` en Debezium CDC
- Implementar `RoundingMode.HALF_EVEN` en JDBC/Java para todas las operaciones con este tipo
- Generar ≥200 casos de prueba con valores de borde (0.005, 0.0050001, etc.)
- Obtener sign-off de Tesorería BanCoppel antes del cutover

## R02 — Riesgo de acoplamiento: dependencias cross-DB

**Nivel:** 🟠 ALTO
**Llamadas cross-DB desde `bdiaclaracion`:** 858

| Dependencia | Volumen | Riesgo |
|------------|---------|--------|
| `bdiaclaracion` → `bdinteg` | 452 | MEDIO |
| `bdiaclaracion` → `bdicheq` | 153 | MEDIO |
| `bdiaclaracion` → `bdicred` | 139 | MEDIO |
| `bdiaclaracion` → `bdidomi` | 40 | MEDIO |
| `bdiaclaracion` → `bdimnsj` | 34 | MEDIO |
| `bdiaclaracion` → `bdinvers` | 19 | MEDIO |
| `bdiaclaracion` → `bdisitesp` | 12 | MEDIO |
| `bdiaclaracion` → `bdibpi` | 9 | MEDIO |

En Informix, estas llamadas son intra-proceso (sin latencia). En el target distribuido, cada llamada cross-DB se convierte en llamada de red (HTTP/gRPC) o consulta via `postgres_fdw`. Las transacciones distribuidas (`BEGIN WORK` cross-DB) no tienen equivalente directo.

**Mitigación:**
- Definir patrón Saga o 2PC como ADR antes de migrar este dominio
- La Anti-Corruption Layer (ACL) debe absorber las llamadas cross-DB como llamadas de API interna
- Priorizar migración de dominios dependientes antes de `bdiaclaracion`

## R03 — Riesgo temporal: DATETIME YEAR TO FRACTION

**Nivel:** 🟠 ALTO
**Ocurrencias:** 1,904

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
| `sp_fal_busca_beneficiarios_por_cuenta` | 12,269 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_documentos_faltantes` | 12,110 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_pagares_cliente` | 12,044 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_producto_deb_cheq_cliente` | 11,892 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_producto_deb_cheq_cliente_1` | 11,824 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_producto_deb_cheq_cliente_2` | 11,752 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_producto_deb_cheq_cliente_3` | 11,687 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_busca_producto_pcuenta_deb_cte_fallecido` | 11,619 LOC | 0 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_cancelacion_cuenta_debito` | 11,516 LOC | 40 callers | 20 callees | Dificultad: EXTREMA |
| `sp_fal_consulta_ciudades` | 11,349 LOC | 0 callers | 17 callees | Dificultad: EXTREMA |

**Mitigación:**
- Cada god procedure requiere reverse engineering manual por SME
- Estimar: 1 god procedure > 1,000 LOC ≈ 3-5 días de análisis + test
- Considerar strangler-fig por función dentro del god procedure

## R06 — Riesgos regulatorios

**[SME-PENDING]** El dominio `bdiaclaracion` puede tener obligaciones regulatorias específicas:

```
[Completar con Risk Officer — Modernización]
- ¿Aplica CNBV Circular X/XXXX?
- ¿Aplica regulación Banxico para Aclaraciones?
- ¿Aplica PCI-DSS (manejo de datos de tarjeta)?
- ¿Existe auditoría CONDUSEF sobre este dominio?
- ¿El parallel-run mínimo requerido es 3 meses (banca)?
```

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdiaclaracion_*.sql + callgraph-data.json*

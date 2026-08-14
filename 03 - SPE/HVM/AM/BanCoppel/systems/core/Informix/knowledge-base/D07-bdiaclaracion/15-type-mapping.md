# D07 · Aclaraciones — Mapeo de Tipos Informix → PostgreSQL

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdiaclaracion` → Target: Aurora PostgreSQL 15+
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Propósito

Este documento es la **referencia canónica de conversión de tipos** para el dominio `bdiaclaracion`. Cada desarrollador que migre un SP de este dominio debe seguir esta tabla sin excepción. Las decisiones inconsistentes en tipos de datos son la causa #1 de divergencias financieras en producción.

## Tabla de mapeo canónico

| Tipo Informix | Tipo PostgreSQL target | Riesgo | Nota crítica |
|--------------|----------------------|--------|-------------|
| `MONEY(p,s)` | `NUMERIC(p,s)` | 🔴 CRÍTICO | Redondeo half-even Informix ≠ half-up PG. RoundingMode.HALF_EVEN en JDBC. ADR-SPE-AM-006. |
| `DECIMAL(p,s)` | `NUMERIC(p,s)` | 🟡 MEDIO | Mismo riesgo que MONEY pero menos frecuente. Verificar cálculos acumulativos. |
| `DATETIME YEAR TO FRACTION(n)` | `TIMESTAMP(n) WITHOUT TIME ZONE` | 🟠 ALTO | NUNCA usar TIMESTAMPTZ — timezone es del servidor AIX (America/Mexico_City). Debezium: configurar timezone explícito. |
| `SERIAL` | `IDENTITY / SEQUENCE` | 🟠 ALTO | Capturar MAX(id)+margen en ventana de freeze del cutover. Coordinar con DBA IBM Informix. |
| `BIGSERIAL` | `BIGINT GENERATED ALWAYS AS IDENTITY` | 🟡 MEDIO | Igual que SERIAL. Menos frecuente. |
| `CHAR(n)` | `CHAR(n)` | 🟢 BAJO | Informix padea con espacios. Verificar TRIM en comparaciones si target usa VARCHAR. |
| `VARCHAR(n)` | `VARCHAR(n)` | 🟢 BAJO | Sin diferencia funcional. |
| `DATE` | `DATE` | 🟢 BAJO | Sin diferencia. |
| `INTEGER` | `INTEGER` | 🟢 BAJO | Sin diferencia. |
| `SMALLINT` | `SMALLINT` | 🟢 BAJO | Sin diferencia. |
| `FLOAT` | `DOUBLE PRECISION` | 🟡 MEDIO | Precisión IEEE 754 — verificar en cálculos financieros. |
| `TEXT` | `TEXT` | 🟢 BAJO | Sin diferencia. |
| `BYTE` | `BYTEA` | 🟡 MEDIO | Verificar si es binario real o texto codificado. |
| `INTERVAL` | `INTERVAL` | 🟡 MEDIO | Validar unidades YEAR TO MONTH vs DAY TO SECOND. |
| `LVARCHAR(n)` | `VARCHAR(n) o TEXT` | 🟢 BAJO | n puede ser grande — usar TEXT si n > 32,767. |
| `SERIAL8` | `BIGSERIAL / IDENTITY BIGINT` | 🟡 MEDIO | Igual que SERIAL. |
| `NCHAR(n)` | `CHAR(n)` | 🟢 BAJO | Internacionalización — verificar charset UTF-8. |

## Riesgo principal para `bdiaclaracion`: MONEY rounding

```java
// OBLIGATORIO en todo acceso JDBC a columnas MONEY/NUMERIC desde este dominio:
BigDecimal valor = resultSet.getBigDecimal("columna_money");
valor = valor.setScale(escala, RoundingMode.HALF_EVEN); // simula Informix MONEY

// NUNCA usar:
// valor = valor.setScale(escala, RoundingMode.HALF_UP); // distinto a Informix
// double d = resultSet.getDouble("columna_money");       // pierde precisión
```

## Configuración Debezium para CDC de este dominio

```json
{
  "connector.class": "io.debezium.connector.informix.InformixConnector",
  "database.hostname": "DCMSIF01",
  "database.dbname": "bdiaclaracion",
  "decimal.handling.mode": "string",
  "time.precision.mode": "adaptive_time_microseconds",
  "database.serverTimezone": "America/Mexico_City"
}
```

> `decimal.handling.mode: string` previene la conversión automática de MONEY a float en el conector.

## Funciones built-in Informix sin equivalente PostgreSQL

| Función Informix | Equivalente PostgreSQL | Riesgo | Acción |
|-----------------|----------------------|--------|--------|
| `EXTEND(x, YEAR TO FRACTION)` | `x::TIMESTAMP(5)` | 🟠 | Reescribir en capa de aplicación |
| `MDY(m, d, y)` | `MAKE_DATE(y, m, d)` | 🟡 | Reemplazar directamente |
| `TODAY` | `CURRENT_DATE` | 🟢 | Reemplazar directamente |
| `CURRENT YEAR TO FRACTION(5)` | `CURRENT_TIMESTAMP(5)` | 🟢 | Reemplazar directamente |
| `NVL(x, y)` | `COALESCE(x, y)` | 🟢 | Reemplazar directamente |
| `DECODE(x, v1, r1, ...)` | `CASE WHEN x=v1 THEN r1 ... END` | 🟡 | Reescribir — más verboso |
| `DBINFO('sqlca.sqlerrd2')` | `lastval()` o `currval('seq')` | 🔴 | Sin equivalente directo — rediseñar |
| `SET ISOLATION TO DIRTY READ` | `SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED` | 🟠 | Verificar semántica — en PG tiene diferencias |

## Checklist de validación por SP migrado

- [ ] Todas las columnas MONEY convertidas a `NUMERIC(p,s)` con `HALF_EVEN`
- [ ] DATETIME convertidas a `TIMESTAMP WITHOUT TIME ZONE` (nunca TIMESTAMPTZ)
- [ ] SERIAL migrado con SEQUENCE inicializada en `MAX(id) * 1.5`
- [ ] CHAR(n) — verificar si comparaciones esperan trailing spaces
- [ ] Funciones built-in reemplazadas (EXTEND, MDY, TODAY, NVL, DECODE)
- [ ] Revisión de QA Lead — Equivalencia Funcional antes del merge

---
*Generado por: Specialist — Informix SPL Analysis + QA Lead Equivalencia Funcional · 2026-07-03*

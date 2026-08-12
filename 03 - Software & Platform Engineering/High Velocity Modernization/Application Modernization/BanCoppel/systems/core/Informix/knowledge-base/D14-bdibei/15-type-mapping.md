# D14 · Banca Electrónica Institucional (BEI) — Mapeo de Tipos Informix → PostgreSQL

> **Componente:** BCOPCore · SPE-AM-001 · BUILD Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (tipos reales desde `syscolumns` — Etapa 2) ← FUENTE DE VERDAD
- Data Architect — target PostgreSQL / Aurora (mapeo y scripts de migración)
- QA Lead — Equivalencia Funcional (verificación de redondeo financiero y precisión)
- Specialist — Informix SPL Analysis (tipos observados en variables DEFINE del código SPL)

> **CRÍTICO:** el tipo `MONEY` es el de mayor riesgo de equivalencia en este dominio. Cualquier diferencia de redondeo en montos de dispersión es inaceptable en un dominio de pagos masivos.
---

## Tabla de mapeo de tipos — bdibei

| Tipo Informix | Descripción | Usos en BEI | Tipo PostgreSQL target | Riesgo | Notas |
|--------------|-------------|-------------|----------------------|--------|-------|
| `MONEY(p,s)` | Monto monetario con precisión fija | Montos de dispersión, comisiones, límites | `NUMERIC(p,s)` con misma escala | **CRÍTICO** | Ver sección MONEY abajo |
| `DECIMAL(p,s)` | Número decimal | Tasas de comisión, IVA | `NUMERIC(p,s)` | ALTO | Misma precisión obligatoria |
| `SERIAL` | Entero autoincrementable (32 bits) | Folios de dispersión, IDs | `BIGSERIAL` (64 bits) | ALTO | Seed debe inicializarse en max+1 del legado |
| `SERIAL8` | Entero autoincrementable (64 bits) | IDs de detalle de dispersión | `BIGSERIAL` | BAJO | Equivalencia directa |
| `INTEGER` | Entero 32 bits | Contadores, cantidades | `INTEGER` | BAJO | Directo |
| `SMALLINT` | Entero 16 bits | Flags, indicadores | `SMALLINT` | BAJO | Directo |
| `INT8` | Entero 64 bits | Variables de cálculo LCG, folios grandes | `BIGINT` | BAJO | Directo |
| `CHAR(n)` | Cadena de longitud fija | CLABE (18), RFC (13), códigos fijos | `CHAR(n)` | BAJO | Misma longitud |
| `VARCHAR(n)` | Cadena de longitud variable | Nombres, razones sociales, descripciones | `VARCHAR(n)` | BAJO | Directo |
| `DATE` | Fecha sin hora | Fecha de dispersión, fecha de alta | `DATE` | BAJO | Directo |
| `DATETIME YEAR TO FRACTION` | Timestamp con microsegundos | Timestamp de procesamiento batch | `TIMESTAMP(5)` | MEDIO | Verificar precisión |
| `DATETIME YEAR TO SECOND` | Timestamp con segundos | Log de operaciones, bitácora | `TIMESTAMP` | BAJO | Directo |

---

## MONEY — Riesgo Crítico de Equivalencia Financiera

El tipo `MONEY` de Informix almacena valores monetarios con redondeo bancario (ROUND_HALF_UP). En PostgreSQL, `NUMERIC(p,s)` almacena con precisión exacta pero las operaciones de división o porcentaje pueden tener comportamiento diferente.

### Reglas de equivalencia para montos BEI

```
REGLA-MONEY-BEI-01: Todo monto de dispersión debe ser IDÉNTICO bit-a-bit entre
el cálculo en Informix y el cálculo en PostgreSQL.

REGLA-MONEY-BEI-02: Las comisiones se calculan como:
  comision = ROUND(monto_dispersion * tasa_comision / 100, 2)
  El redondeo ROUND_HALF_UP es el estándar bancario.

REGLA-MONEY-BEI-03: El IVA se calcula como:
  iva = ROUND(comision * tasa_iva / 100, 2)
  donde tasa_iva = 16.00 (general) o 8.00 (frontera norte)

REGLA-MONEY-BEI-04: La suma de los montos individuales de bei_dispersiones_det
debe ser IGUAL al monto total en bei_dispersiones (sin diferencia de centavos).
```

### Prueba de equivalencia obligatoria para MONEY

```sql
-- Test PostgreSQL para verificar equivalencia de redondeo
SELECT
  round(cast(1234567.895 AS NUMERIC(18,2)), 2) AS pg_resultado,
  -- Expected: 1234567.90 (ROUND_HALF_UP)
  -- Si PostgreSQL da 1234567.89 (ROUND_HALF_EVEN), hay discrepancia
;
```

```java
// En Java, usar BigDecimal con RoundingMode.HALF_UP
BigDecimal monto = new BigDecimal("1234567.895");
BigDecimal resultado = monto.setScale(2, RoundingMode.HALF_UP);
// resultado = 1234567.90
```

---

## SERIAL — Migración de secuencias

El tipo `SERIAL` de Informix genera valores autoincrementales. En la migración a PostgreSQL, las secuencias deben inicializarse en `MAX(id_actual) + 1` para que los nuevos registros no colisionen con los migrados.

```sql
-- Después del bulk load de datos históricos:
SELECT setval('bei_dispersiones_folio_seq',
  (SELECT MAX(folio) FROM bei_dispersiones) + 1);

SELECT setval('bei_dispersiones_det_id_seq',
  (SELECT MAX(id_detalle) FROM bei_dispersiones_det) + 1);
```

**Riesgo:** si el seed no se ajusta correctamente, los primeros INSERTs en producción intentarán usar folios ya existentes, causando conflictos de PK y fallos en la primera dispersión post-cutover.

---

## DATETIME YEAR TO FRACTION — Precision de timestamps

Informix `DATETIME YEAR TO FRACTION(5)` tiene precisión de 10 microsegundos (5 dígitos). PostgreSQL `TIMESTAMP(5)` también tiene precisión de microsegundos.

```sql
-- Informix: 2026-08-03 14:30:45.12345
-- PostgreSQL: equivalente directo con TIMESTAMP(5)
-- Riesgo: solo si la precisión se trunca durante la migración
```

---

## Funciones built-in de Informix sin equivalente directo en PostgreSQL

| Función Informix | Usos en BEI | Equivalente PostgreSQL | Riesgo |
|-----------------|------------|----------------------|--------|
| `NVL(expr, default)` | Valores nulos en campos de empresa / beneficiario | `COALESCE(expr, default)` | BAJO — ajuste menor |
| `TRIM(cadena)` | Limpieza de CLABE, RFC, nombres | `TRIM(cadena)` | BAJO — directo |
| `TODAY` | Fecha del día en validaciones | `CURRENT_DATE` | BAJO — directo |
| `CURRENT` | Timestamp actual | `NOW()` / `CURRENT_TIMESTAMP` | BAJO — ajuste menor |
| `MDY(m,d,y)` | Construcción de fecha | `MAKE_DATE(y,m,d)` | BAJO — ajuste de orden de argumentos |
| `DBINFO('sessionid')` | ID de sesión en `getrandomcode` | No se migra (LCG eliminado) | N/A — reemplazar todo `getrandomcode` |
| `YEAR(fecha)` | Año de fecha en reportes | `EXTRACT(YEAR FROM fecha)` | BAJO |
| `MONTH(fecha)` | Mes de fecha en reportes | `EXTRACT(MONTH FROM fecha)` | BAJO |

---

## Tipos de variables observados en sp-specs-bdibei.md

De los dos SPs verificados en detalle (`getrandomcode`):

| Variable | Tipo Informix | Equivalente Java/PostgreSQL |
|----------|--------------|---------------------------|
| `m` | `INT8` | `long` / `BIGINT` |
| `a` | `INT8` | `long` / `BIGINT` |
| `time` | `INT8` | `long` / `BIGINT` |
| `x` | `INT8` | `long` / `BIGINT` |
| `_x` | `DECIMAL(24)` | `BigDecimal(24,0)` / `NUMERIC(24,0)` |
| `c` | `INT8` | `long` / `BIGINT` |
| `k` | `INT8` | `long` / `BIGINT` |
| `_rnd` | `CHAR(8)` | `String` de 8 chars |
| `i` | `INTEGER` | `int` / `INTEGER` |
| `iSqlErr` | `INTEGER` | `int` (código de error SQL) |
| `cCadRnds` | `CHAR(64)` | `String` de 64 chars (alfabeto LCG) |
| `cAscii` | `CHAR(1)` | `char` |
| `iRows` | `INTEGER` | `int` (contador de iteración) |
| `y` | `INT8` | `long` (resultado ASCII LCG) |

> **Nota:** estas variables pertenecen a `getrandomcode` que se eliminará en el target. Se documentan para completitud del análisis.

---
*Generado por: Data Architect + Specialist — Informix SPL Analysis · 2026-08-03 · Fuente: sp-specs-bdibei.md + tipos observados en código SPL + convenciones dominio BEI*

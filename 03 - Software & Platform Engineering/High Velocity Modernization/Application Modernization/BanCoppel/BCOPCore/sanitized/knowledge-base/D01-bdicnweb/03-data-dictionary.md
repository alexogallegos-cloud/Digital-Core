# D01 · Canal Digital Web — Diccionario de Datos

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


## Descripción

Diccionario de datos del dominio `bdicnweb` construido a partir del análisis estático de los headers `CREATE PROCEDURE / FUNCTION` en 2184 archivos SQL. Incluye la firma de los SPs más significativos y el inventario de tipos de datos Informix utilizados.

> **Limitación:** Los tipos de *columnas* de tablas solo se pueden extraer conectando a `syscolumns`. Este documento cubre exclusivamente los **parámetros de SPs** (capa de lógica) no las columnas de tablas (capa de persistencia).

## Inventario de tipos de datos Informix por dominio

| Tipo Informix | Ocurrencias en código | Equivalente PostgreSQL | Riesgo de migración |
|--------------|----------------------|----------------------|---------------------|
| `CHAR` | 2,629,542 ocurrencias | CHAR(n) | 🟢 BAJO |
| `INTEGER` | 881,981 ocurrencias | INTEGER | 🟢 BAJO |
| `DATE` | 216,103 ocurrencias | DATE | 🟢 BAJO |
| `MONEY` | 145,721 ocurrencias | NUMERIC(p,s) | 🔴 CRÍTICO |
| `DECIMAL` | 125,801 ocurrencias | NUMERIC(p,s) | 🟡 MEDIO |
| `SMALLINT` | 82,149 ocurrencias | SMALLINT | 🟢 BAJO |
| `VARCHAR` | 50,590 ocurrencias | VARCHAR(n) | 🟢 BAJO |
| `FLOAT` | 28,818 ocurrencias | DOUBLE PRECISION | 🟢 BAJO |
| `DATETIME` | 24,850 ocurrencias | TIMESTAMP(n) WITHOUT TIME ZONE | 🟠 ALTO |
| `SERIAL` | 549 ocurrencias | IDENTITY / SEQUENCE | 🟠 ALTO |
| `INTERVAL` | 246 ocurrencias | INTERVAL | 🟡 MEDIO |
| `BIGSERIAL` | 44 ocurrencias | BIGINT GENERATED ALWAYS AS IDENTITY | 🟡 MEDIO |

## Firmas de SPs principales (top por LOC)

Los siguientes SPs son los más grandes del dominio y por tanto los de mayor riesgo de equivalencia.

> [SME-PENDING] No se encontraron firmas parseables en los archivos analizados.

## Equivalencias de tipos — guía de migración

| Tipo Informix | PostgreSQL equivalente | Precaución |
|--------------|----------------------|------------|
| `MONEY(p,s)` | `NUMERIC(p,s)` | **Redondeo**: Informix usa half-even, PG usa half-up. Requiere override en JDBC. |
| `DATETIME YEAR TO FRACTION(5)` | `TIMESTAMP(5) WITHOUT TIME ZONE` | **Timezone**: asumir America/Mexico_City. NUNCA usar TIMESTAMPTZ. |
| `SERIAL` | `IDENTITY` / `SEQUENCE` | **Gaps**: rollback no decrementa el contador en ambos motores. Coordinar en cutover. |
| `CHAR(n)` | `CHAR(n)` | Sin diferencia funcional. Verificar padding con espacios. |
| `VARCHAR(n)` | `VARCHAR(n)` | Sin diferencia. |
| `BYTE` | `BYTEA` | Verificar si hay contenido binario o solo se usa como blob de texto. |
| `INTERVAL` | `INTERVAL` | Validar unidades (YEAR TO MONTH vs DAY TO SECOND). |
| `TEXT` | `TEXT` | Sin diferencia. |

## Pendientes Etapa 2 (Data RE)

- [ ] Catálogo de columnas por tabla (`syscolumns` en instancia viva)
- [ ] Constraints declarados e implícitos
- [ ] Índices y su equivalencia en PostgreSQL
- [ ] Valores posibles de campos de tipo catálogo (enums implícitos)
- [ ] Campos PII/PCI-DSS para clasificación de sensibilidad

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql*

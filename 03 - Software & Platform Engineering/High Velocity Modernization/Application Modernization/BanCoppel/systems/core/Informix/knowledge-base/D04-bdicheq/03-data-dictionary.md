# D04 · Cheques / Cuentas — Diccionario de Datos

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — BanCoppel (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de BanCoppel antes de pasar a Etapa 2.
---


## Descripción

Diccionario de datos del dominio `bdicheq` construido a partir del análisis estático de los headers `CREATE PROCEDURE / FUNCTION` en 1535 archivos SQL. Incluye la firma de los SPs más significativos y el inventario de tipos de datos Informix utilizados.

> **Limitación:** Los tipos de *columnas* de tablas solo se pueden extraer conectando a `syscolumns`. Este documento cubre exclusivamente los **parámetros de SPs** (capa de lógica) no las columnas de tablas (capa de persistencia).

## Inventario de tipos de datos Informix por dominio

| Tipo Informix | Ocurrencias en código | Equivalente PostgreSQL | Riesgo de migración |
|--------------|----------------------|----------------------|---------------------|
| `CHAR` | 101,625 ocurrencias | CHAR(n) | 🟢 BAJO |
| `INTEGER` | 20,202 ocurrencias | INTEGER | 🟢 BAJO |
| `MONEY` | 18,433 ocurrencias | NUMERIC(p,s) | 🔴 CRÍTICO |
| `DATE` | 15,100 ocurrencias | DATE | 🟢 BAJO |
| `DECIMAL` | 8,672 ocurrencias | NUMERIC(p,s) | 🟡 MEDIO |
| `SMALLINT` | 7,999 ocurrencias | SMALLINT | 🟢 BAJO |
| `VARCHAR` | 2,971 ocurrencias | VARCHAR(n) | 🟢 BAJO |
| `DATETIME` | 918 ocurrencias | TIMESTAMP(n) WITHOUT TIME ZONE | 🟠 ALTO |
| `INTERVAL` | 40 ocurrencias | INTERVAL | 🟡 MEDIO |
| `SERIAL` | 23 ocurrencias | IDENTITY / SEQUENCE | 🟠 ALTO |
| `FLOAT` | 3 ocurrencias | DOUBLE PRECISION | 🟢 BAJO |
| `TEXT` | 2 ocurrencias | TEXT | 🟢 BAJO |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicheq_*.sql*

# D10 · Sucursales — Diccionario de Datos

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
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


## Descripción

Diccionario de datos del dominio `bdisuc` construido a partir del análisis estático de los headers `CREATE PROCEDURE / FUNCTION` en 293 archivos SQL. Incluye la firma de los SPs más significativos y el inventario de tipos de datos Informix utilizados.

> **Limitación:** Los tipos de *columnas* de tablas solo se pueden extraer conectando a `syscolumns`. Este documento cubre exclusivamente los **parámetros de SPs** (capa de lógica) no las columnas de tablas (capa de persistencia).

## Inventario de tipos de datos Informix por dominio

| Tipo Informix | Ocurrencias en código | Equivalente PostgreSQL | Riesgo de migración |
|--------------|----------------------|----------------------|---------------------|
| `CHAR` | 19,992 ocurrencias | CHAR(n) | 🟢 BAJO |
| `INTEGER` | 5,748 ocurrencias | INTEGER | 🟢 BAJO |
| `FLOAT` | 3,165 ocurrencias | DOUBLE PRECISION | 🟢 BAJO |
| `DATE` | 1,982 ocurrencias | DATE | 🟢 BAJO |
| `MONEY` | 1,455 ocurrencias | NUMERIC(p,s) | 🔴 CRÍTICO |
| `VARCHAR` | 747 ocurrencias | VARCHAR(n) | 🟢 BAJO |
| `SMALLINT` | 733 ocurrencias | SMALLINT | 🟢 BAJO |
| `DECIMAL` | 260 ocurrencias | NUMERIC(p,s) | 🟡 MEDIO |
| `DATETIME` | 142 ocurrencias | TIMESTAMP(n) WITHOUT TIME ZONE | 🟠 ALTO |
| `SERIAL` | 4 ocurrencias | IDENTITY / SEQUENCE | 🟠 ALTO |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisuc_*.sql*

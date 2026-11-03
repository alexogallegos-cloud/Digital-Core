# ADR-EB-001 — SQLite como motor del Enterprise Brain

**Estado**: APROBADO
**Fecha**: 2026-09-29
**Autores**: alejandro.gallegos@accenture.com
**Contexto**: Elección del motor de almacenamiento canónico para el Enterprise Brain


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE
templates/brain.py :: sqlite3
-->

---

## Contexto

Al diseñar el Enterprise Brain, se evaluaron múltiples opciones de almacenamiento:

| Opción | Tipo |
|--------|------|
| PostgreSQL / MySQL | RDBMS con servidor |
| MongoDB / Cosmos DB | NoSQL document store |
| Pinecone / Weaviate / pgvector | Vector database |
| SQLite 3.43+ | Embedded relational |
| DuckDB | Embedded OLAP |

El brain requiere: búsqueda fulltext (FTS), queries relacionales complejas (JOIN entre reglas, components, vocabulary, etb_l3), federación entre múltiples instancias (bank-brain), portabilidad sin servidor, y reproducibilidad total desde pipeline.

> **[ENMIENDA 2026-10-05]** `etb_l3` se retiró con ADR-EB-006 en favor de `capabilities` con columna `ontology`, porque en el estate conviven cuatro ontologías incompatibles. La mención se conserva como registro de los requisitos tal como se plantearon; la decisión de fondo sobre SQLite no cambia.

---

## Decisión

**SQLite 3.43+** es el motor canónico del Enterprise Brain.

Extensiones requeridas:
- **FTS5** — búsqueda fulltext sobre reglas, vocabulario y journeys
- **JSON1** — campos JSON para arrays (domains, regulation, related_terms)
- **ATTACH DATABASE** — federación de múltiples brains en bank-brain (Regla B4)

---

## Razones

1. **Portabilidad total**: brain.db es un archivo único — se copia, se distribuye, se inspecciona con cualquier cliente SQLite sin dependencias de servidor.
2. **Reproducibilidad**: `build-brain.py` reconstruye el brain desde cero en minutos. No hay estado de servidor que sincronizar entre ambientes.
3. **Federación nativa (Regla B4)**: SQLite ATTACH permite queries cross-brain sin API runtime entre instancias — arquitectura P2P simple. Agregar un sistema = ATTACHar su brain.db.
4. **FTS5**: búsqueda fulltext nativa sobre millones de reglas sin Elasticsearch ni configuración de servidor.
5. **Cero operaciones**: no hay servidor que mantener, parchear, escalar, respaldar ni monitorear.
6. **Velocidad de desarrollo**: un `SELECT` desde el REPL de Python o cualquier GUI SQLite (DB Browser, TablePlus, DataGrip) — sin credenciales, sin conexión de red.
7. **Rendimiento suficiente**: los brains más grandes actuales (~12,812 SPs, ~9,000 reglas) responden en < 100ms en SQLite. Por encima de ~50M filas por tabla, evaluar DuckDB.

---

## Consecuencias

- **brain.db en .gitignore** (Regla P5): no se commitea — se reconstruye desde el pipeline en cualquier ambiente.
- **Schema = contrato**: cambios de schema son versión MAJOR del brain. Requieren ADR y migración de todos los brains afectados.
- **Federación requiere mismo filesystem**: ATTACH necesita acceso directo a los archivos. Para brains en cloud (S3, Azure Blob), se requiere download previo.
- **Concurrencia limitada**: SQLite soporta múltiples lectores concurrentes pero solo un escritor. Para el patrón de uso del Enterprise Brain (builds batch + lecturas de DTs) esto es suficiente.

---

## Alternativas rechazadas

| Alternativa | Por qué se rechazó |
|-------------|-------------------|
| PostgreSQL / MySQL | Requiere servidor, credenciales, operaciones. Overkill para un brain de análisis/desarrollo. |
| MongoDB | Flexibilidad sin schema no es útil cuando el schema ES el contrato del brain. |
| Vector DB (Pinecone, Weaviate) | Útil para búsqueda semántica pero no reemplaza el modelo relacional. Se puede agregar como capa adicional sobre SQLite. |
| DuckDB | Mejor para analítica OLAP sobre datasets grandes, pero sin ATTACH para federación P2P simple. Candidato para brains > 50M filas. |

---

## Revisión prevista

Si algún brain supera 50M filas en alguna tabla, iniciar evaluación de DuckDB como motor alternativo para ese brain específico.

---

*ADR-EB-001 · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*

# ADR-EB-014 — El catálogo de fuentes entra al esquema: el CORE llega a 19

> Estado: **APROBADO** · Propuesto: 2026-10-16 · Aprobado: 2026-10-16 · Asset: Enterprise Brain · Digital Core
> Formaliza la tabla que `dt-source-steward` ya opera. Enmienda el conteo del CORE de ADR-EB-013.


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS source_catalog
dt/dt-brain-auditor/validate.py :: "source_catalog"
dt/dt-brain-auditor/CLAUDE.md :: `source_catalog`
canon/brain-rules.md :: `source_catalog`
canon/mapa-tablas.md :: source_catalog
dt/cobertura-dt.md :: tabla CORE desde ADR-EB-014
dt/dt-source-steward/CLAUDE.md :: es CORE desde `ADR-EB-014`
-->
---

## Contexto

La Regla B17 obliga a que el brain declare lo que no sabe, y la B35 a que lo declare como consulta concreta. Pero las dos operan **después** de que el dato entró: registran el hueco cuando alguien lo encuentra. Falta el paso anterior, que es saber de antemano con qué fuentes se cuenta y cuáles faltan.

`dt-source-steward` se creó para cubrir eso y es el guardián de la Capa 1. Su primera función es catalogar las fuentes disponibles, clasificar el tier natural de cada tipo y mapear qué casos de uso habilita cada una. El problema es que **opera sobre un artefacto que el esquema no conoce**: el catálogo vive en un Markdown por instancia, `knowledge-base/source-catalog.md`, y cuatro documentos del asset ya lo citan como si fuera parte del modelo.

Eso produce tres consecuencias concretas:

- El `dt-brain-auditor` no puede auditar la cobertura de fuentes, porque no hay tabla que consultar.
- `brain.py` no puede responder "qué fuentes sostienen esta afirmación" sin leer un Markdown, lo cual viola el contrato de la Capa 3, donde `brain.db` es el único artefacto de conocimiento.
- Cuando una fuente se vuelve obsoleta, nada lo detecta: `last_refresh` vive en prosa.

### Por qué la fuente es el eslabón que faltaba

El modelo de calidad de B37 asigna un tier a cada afirmación. Pero el tier **no nace en la afirmación: nace en la fuente**. Código productivo es gold por definición; una minuta es bronze por definición. `dt-source-steward` ya documenta esa clasificación en su función F2, y es la única regla del asset que determina calidad **antes** de que el dato exista en el brain.

Sin `source_catalog`, esa clasificación es una tabla en prosa que cada instancia reinterpreta. Con ella, es un dato que el validador puede verificar.

---

## Decisión

### 1. `source_catalog` entra al CORE

El CORE pasa de 18 a **19 tablas**. Es tabla de CORE y no de extensión porque las tres variantes de `brain_type` tienen fuentes: un brain SYSTEM las tiene en código, uno PROJECT en artefactos firmados y uno ENTERPRISE en brains federados.

El DDL ejecutable vive en `templates/schema.sql`, nunca transcrito aquí. Los campos y su semántica:

| Campo | Para qué |
|-------|----------|
| `ontology` | A qué ontología pertenece la fuente; permite multi-industria (B20) |
| `source_type` | código, doc, ppt, audio, git, jira, monitoring, cmdb, logs, regulación |
| `generator_type` | `parser` para fuente estática, `connector` para sistema vivo |
| `cadence` | batch, continuo o bajo demanda. Sin ella no se sabe cuándo el dato está viejo |
| `status` | activa, parcial, ausente o planeada |
| `natural_tier` | gold, silver o bronze. **Derivado de `source_type`**, no de captura libre |
| `coverage_pct` | Qué porcentaje del sistema cubre. Una fuente activa al 30% no está resuelta |
| `enables` | Qué puede responder el brain gracias a ella. Vuelve accionable la ausencia |
| `last_refresh` | Frescura. Una fuente vieja es un hallazgo, no un supuesto |

### 2. El tier natural lo fija el tipo de fuente, no quien la carga

`natural_tier` **se deriva de `source_type`** según la tabla F2 de `dt-source-steward`. No es un campo de captura libre. Una instancia que marque como gold una minuta está violando el canon y el validador lo detecta.

Esto cierra el ciclo de B37: el tier de una afirmación no puede superar el tier natural de la fuente que la sostiene.

### 3. Una fuente ausente es un hueco, no un silencio

Toda fila con `status = 'ausente'` genera automáticamente una fila en `knowledge_gaps` con `gap_type = 'source'`. Esa correspondencia ya es propiedad declarada de `dt-source-steward` en `cobertura-dt.md`; aquí se vuelve verificable.

La diferencia práctica: hoy un brain sin logs de producción simplemente no sabe nada de su comportamiento en operación, y nada lo dice. Con esto, la ausencia es una fila con dueño y acción.

### 4. El Markdown se mantiene como vista, no como fuente

`knowledge-base/source-catalog.md` **no se retira**. Se convierte en una vista generada desde la tabla, igual que el portal. Sirve para revisión humana en DISCOVER, cuando el brain todavía no existe y el catálogo se está levantando a mano.

El orden es: se levanta en Markdown durante DISCOVER, se carga a `source_catalog` al construir el brain, y de ahí en adelante el Markdown se regenera desde la tabla.

### 5. Dueño

`dt-source-steward` posee la tabla en el eje vertical, como ya declara `cobertura-dt.md`. `dt-knowledge-manager` sigue respondiendo por la columna `tier` de toda tabla, incluida esta.

---

## Consecuencias

**Lo que se gana.** El brain puede responder qué sabe **y con qué lo sabe**. El `dt-brain-auditor` gana una dimensión nueva: cobertura de fuentes contra fuentes esperadas por tipo de sistema. Y la frescura deja de ser invisible: una fuente con `last_refresh` viejo es un hallazgo, no un supuesto.

**Lo que cuesta.** Diecinueve tablas de CORE son muchas para un brain pequeño. Se acepta porque `source_catalog` se puebla con pocas filas, entre cinco y quince por sistema, y porque sin ella la Capa 1 no tiene artefacto verificable.

**Lo que hay que actualizar.** El encabezado de `templates/schema.sql`, la Regla B15, la dimensión D1 del `dt-brain-auditor` y la constante `CORE_TABLES` de `validate.py`. Mientras no se haga, la tabla existe en el DDL y no se valida.

---

## Alternativas consideradas y rechazadas

**Dejarlo en Markdown.** Es lo que había. Se rechaza porque viola el contrato de la Capa 3: el conocimiento vive en `brain.db` y se accede por `brain.py`. Un catálogo en prosa no es auditable ni consultable, y cuatro documentos ya lo citaban como si fuera modelo.

**Meterlo como extensión y no como CORE.** Se rechaza porque las tres variantes de `brain_type` tienen fuentes. Una tabla que toda instancia necesita es CORE por definición (B15).

**Derivarlo de `knowledge_gaps`.** Se rechaza porque invierte la causalidad: el hueco es consecuencia de la fuente ausente, no al revés. Además `knowledge_gaps` no puede representar una fuente presente pero parcial, que es el caso más común.

**Fusionarlo con `documents`.** Se rechaza porque `documents` es extensión de ENTERPRISE y guarda contenido; `source_catalog` guarda la declaración de qué fuentes existen, incluidas las que no son documentos: logs, monitoreo, CMDB, repositorios.

---

*ADR canónico del asset Enterprise Brain · Digital Core · Accenture México*

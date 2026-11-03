# ADR-EB-015 — El pipeline de fuentes y la Etapa 0: el brain deja de entrar solo por el código

> Estado: **APROBADO** · Propuesto: 2026-11-03 · Aprobado: 2026-11-03 · Asset: Enterprise Brain · Digital Core
> Enmienda la metodología de cuatro etapas. Lleva el CORE de 19 a 23 tablas.


<!-- PROPAGACION
templates/schema.sql :: CREATE TABLE IF NOT EXISTS company_profile
templates/schema.sql :: CREATE TABLE IF NOT EXISTS driver_links
templates/schema.sql :: 23 tablas
templates/build-brain.py :: def load_source_catalog
templates/build-brain.py :: def load_driver_links
dt/dt-brain-auditor/validate.py :: "company_profile"
dt/dt-brain-auditor/CLAUDE.md :: `driver_links`
canon/brain-rules.md :: 24 DTs canónicos
canon/brain-rules.md :: `strategic_drivers`
canon/mapa-tablas.md :: driver_links
dt/cobertura-dt.md :: dt-client-intelligence
dt/dt-client-intelligence/CLAUDE.md :: Client Intelligence
knowledge-base/methodology/00-etapa-identidad.md :: Etapa 0
knowledge-base/methodology/01-etapa-lenguaje.md :: de cinco
reference-architecture-enterprise-brain.md :: 0 · Identidad
-->
---

## Contexto

El asset declara que toda fuente de conocimiento tiene un lugar. `ADR-EB-014` creó `source_catalog` y `dt-source-steward` clasifica dieciséis tipos de fuente con su tier natural, desde código productivo hasta minutas de reunión. La teoría está completa y es buena: el tier no nace en la afirmación, nace en la fuente, y por eso una minuta no puede entrar como irrefutable por mucho que alguien lo quiera.

La práctica es otra. Hay tres huecos y los tres apuntan al mismo sitio.

**El constructor solo sabe escribir.** `BrainBuilder` tiene veintinueve métodos de carga y todos están modelados por destino: `load_rules`, `load_vocabulary`, `load_journeys`, `load_components`. Ninguno está modelado por origen. Reciben datos ya extraídos y los escriben en tablas. El tramo anterior, el que va de un PDF, de un stream de logs o de un export de Jira hasta esos datos, no existe en el asset: vive en los `generators/` de cada brain, reinventado cliente por cliente. Esa es la razón concreta de que BanCoppel, MONEX y Liverpool no se parezcan entre sí teniendo el mismo canon.

**La tabla diecinueve no tiene quién la llene.** No existe `load_source_catalog`. La tabla está en el DDL y el validador ya la exige, pero ningún cargador la puebla.

**El método asume un solo tipo de fuente.** La Etapa 1 se llama Lenguaje y arranca extrayendo el vocabulario del sistema legacy, con fuentes que son nombres de stored procedures, nombres de tablas y comentarios en código. Un cliente sin código accesible, o uno cuyo conocimiento vive en contratos, reportes y entrevistas, no tiene por dónde entrar al método.

### El hueco que ese tercer punto esconde

El brain modela lo que el cliente **hace** en `capabilities` y `processes`, lo que **tiene** en `components` y `applications`, **quién** trabaja ahí en `stakeholders` y lo que lo **obliga** en `regulatory_obligations`. No modela en ninguna parte **quién es**: ni su identidad ni su trayectoria ni sus números ni su estrategia ni sus retos ni contra quién compite.

La consecuencia es que el brain puede decir qué hace un sistema y no puede decir por qué le importa al negocio que lo hace. Un hallazgo sobre un stored procedure de cobranza no sabe si la cobranza es el frente donde el banco está perdiendo margen o una función estable que nadie mira.

Y ese conocimiento no sale de código nunca. Sale de reportes anuales, de notas de prensa, de presentaciones y de entrevistas, que son justo los tipos de fuente que el asset clasifica y no sabe ingerir. Por eso los dos problemas son uno: **sin pipeline de fuentes no estructuradas, el estudio del cliente no se puede construir aunque se declare.**

---

## Decisión

### 1. El pipeline de fuentes es capa de primera clase, con contrato por tipo

Todo tipo de fuente del catálogo tiene un **extractor** con contrato declarado. Dos familias, ya nombradas en `source_catalog.generator_type`:

| Familia | Qué es | Cadencia | Ejemplos |
|---|---|---|---|
| `parser` | Fuente estática que se lee entera | batch | Código, PDF, PPT, transcripción, normativa publicada |
| `connector` | Sistema vivo que se consulta | continuo o bajo demanda | Logs, monitoreo, CMDB, Jira, git |

El contrato es el mismo para los dos: el extractor recibe una fuente registrada en `source_catalog` y emite registros normalizados con su procedencia, nunca escribe en `brain.db` directamente. La escritura sigue siendo de los veintinueve cargadores. Así el pipeline queda partido en dos mitades verificables por separado, y un extractor nuevo no puede corromper el esquema.

### 2. El tier se estampa en la frontera de entrada

El extractor asigna el tier derivándolo de `source_catalog.natural_tier`, que a su vez se deriva de `source_type` según la tabla F2 de `dt-source-steward`. No es captura libre y no se renegocia aguas abajo: ninguna afirmación puede superar el tier natural de la fuente que la sostiene.

Esto cierra el ciclo que `ADR-EB-010` abrió con B37 y que hasta hoy dependía de que quien cargara el dato se acordara de la regla.

### 3. `load_source_catalog` cierra el hueco del constructor

La tabla diecinueve gana su cargador, y se convierte en el **primer** paso de todo build: antes de poblar nada, el brain declara con qué fuentes cuenta, cuáles faltan y qué cubre cada una. Toda fila con `status = 'ausente'` genera su fila en `knowledge_gaps` con `gap_type = 'source'`, como ya mandaba `ADR-EB-014` sin implementación.

### 4. Etapa 0 — Identidad, antes del Lenguaje

La metodología pasa de cuatro etapas a cinco. La nueva es la primera y responde quién es el cliente antes de que el método toque una línea de código.

| Etapa | Pregunta | Tabla destino |
|---|---|---|
| **0. Identidad** | Quién es la empresa, de dónde viene, cuánto vale, qué la presiona y hacia dónde va | `company_profile`, `business_milestones`, `strategic_drivers`, `measurements` |
| 1. Lenguaje | Cómo nombra sus conceptos | `vocabulary` |
| 2. Almas | Qué piezas son irremplazables | `components.is_soul` |
| 3. Biografía | Cómo recorre el cliente sus procesos | `journeys` |
| 4. Intención | Qué decide y bajo qué criterio | `rules` |

La Etapa 0 se alimenta de fuentes no estructuradas por definición, y es por tanto el primer consumidor del pipeline del punto 1. Su tier dominante será silver y bronze, lo cual es correcto y debe declararse: una estrategia declarada en un reporte anual es intención, no hecho.

### 5. Tres tablas nuevas, y las cifras reutilizan `measurements`

El CORE pasa de 19 a **23 tablas**. Son CORE y no extensión porque las tres variantes de `brain_type` tienen cliente: un brain de sistema sirve a una empresa igual que uno de proyecto o uno de empresa.

El DDL ejecutable vive en `templates/schema.sql`, nunca transcrito aquí.

| Tabla | Qué guarda |
|---|---|
| `company_profile` | La ficha de identidad, una fila: entidad legal, fundación, propiedad, escala, geografía, industrias donde opera |
| `business_milestones` | La trayectoria: fusiones, adquisiciones, crisis, entradas y salidas de mercado, con su año y su efecto |
| `strategic_drivers` | Pilares, objetivos, retos y amenazas competitivas, tipados en una sola tabla porque comparten estructura y se consultan juntos |
| `driver_links` | La traza de vuelta: qué capability, producto, regla o hallazgo sirve a qué driver |

Las cifras de negocio (ingresos, empleados, sucursales, participación de mercado) **no llevan tabla propia**: son filas de `measurements`, que ya es genérica por `entity_table` y `entity_id`, ya tiene ventana temporal y ya distingue el origen del dato. Una serie de ingresos por año ancla a `company_profile` sin inventar nada.

### 6. Eje rector significa traza de vuelta, no prólogo

`driver_links` es lo que convierte el estudio del cliente en eje rector en vez de en un capítulo introductorio que nadie vuelve a leer. Con ella, el brain puede responder qué parte del estate sirve a cada pilar estratégico, y al revés, qué reto queda sin ninguna capacidad que lo atienda. Ese segundo caso es un hallazgo, no un silencio.

La relación es N:M y genérica por `entity_table`, igual que `measurements`, porque un driver se sirve desde capabilities en un brain de empresa, desde user stories en uno de proyecto y desde reglas en uno de sistema.

### 7. Dueños

`dt-source-steward` gana el pipeline del punto 1 y su propia tabla, que ya poseía nominalmente. La Etapa 0 y sus cuatro tablas son de un DT nuevo, **`dt-client-intelligence`**, de categoría C, cuya pregunta central es quién es la empresa y qué la mueve. El precedente existe y está probado en la flota: `dt-inteligencia-cliente` opera hoy en BanCoppel, Gentera y Liverpool, y `ADR-EB-011` ya lo exoneró explícitamente de la absorción declarando que investiga al cliente como empresa y no al cliente del cliente.

---

## Consecuencias

**Lo que se gana.** El brain deja de depender de que exista código legible. Un cliente en evaluación, sin acceso todavía a repositorios, puede tener brain desde el primer reporte anual. Y todo hallazgo gana un porqué de negocio, que es lo que lo vuelve accionable frente a un comité.

**Lo que cuesta.** Veintitrés tablas de CORE son muchas, y `ADR-EB-014` ya advertía que diecinueve lo eran. Se acepta porque las cuatro nuevas se pueblan con pocas filas, entre diez y cuarenta por brain, y porque sin ellas la pregunta "por qué le importa esto al negocio" no tiene dónde vivir. El costo real no es el esquema sino el pipeline: escribir extractores por tipo de fuente es trabajo de ingeniería, no de documentación.

**Lo que hay que actualizar al aprobarse.** `templates/schema.sql` con las cuatro tablas y su encabezado, la Regla B15 con su cifra y su enumeración, la dimensión D1 y `CORE_TABLES` de `validate.py`, el roster de B41 con el DT nuevo, `dt/cobertura-dt.md`, `canon/mapa-tablas.md` por regeneración, la tabla de etapas de `reference-architecture-enterprise-brain.md`, y en `knowledge-base/methodology/` el archivo nuevo de la etapa Identidad más la renumeración de los cuatro existentes.

Esa lista es larga a propósito. La auditoría de noviembre de 2026 encontró que `ADR-EB-011`, `ADR-EB-012` y `ADR-EB-014` se aprobaron y nunca bajaron a los artefactos, y que el canon escrito llegó a contradecir decisiones aprobadas. Este ADR no se aprobó hasta que su propagación estuvo hecha, y se aprueba junto con ella.

---

## Alternativas consideradas y rechazadas

**Dejar la Etapa 0 fuera del brain, en el `CLAUDE.md` del cliente.** Es donde vive hoy, en prosa. Se rechaza porque no es consultable ni trazable: `driver_links` no puede apuntar a un párrafo, y la pregunta "qué reto no tiene capacidad que lo atienda" no se responde leyendo.

**Una sola tabla de contexto con un campo de texto largo.** Más barata y es lo que haría un atajo. Se rechaza porque un bloque de prosa no se consulta por dimensión ni se versiona por período, y porque mataría la traza de vuelta, que es el punto entero.

**Tabla propia para las cifras de negocio.** Se rechaza porque duplicaría `measurements`, que ya resuelve ventana temporal, unidad, origen y tier. Reusarla es además coherente con `ADR-EB-012`, que la creó genérica a propósito.

**Extractores que escriban directo en `brain.db`.** Más corto de implementar. Se rechaza porque rompe la frontera que hace verificable al pipeline: con veintinueve cargadores como único punto de escritura, un extractor defectuoso produce datos malos pero nunca un esquema corrupto.

**Meterlo como extensión y no como CORE.** Se rechaza por la misma razón que `source_catalog` en `ADR-EB-014`: toda instancia tiene cliente, y una tabla que toda instancia necesita es CORE por definición (B15).

---

*ADR canónico del asset Enterprise Brain · Digital Core · Accenture México*

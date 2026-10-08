# Brain Rules — Reglas Canónicas del Enterprise Brain

> Versión 3.0 · 2026-10-05 · Asset Enterprise Brain · Digital Core · Accenture México

Estas reglas son el estándar de implementación de todo Enterprise Brain. No son opcionales — son el contrato de interoperabilidad entre brains de distintos sistemas y proyectos.

Los números de regla (B1-B45, V1-V2, P1-P5) son **IDs estables** referenciados en código (`schema.sql`, `validate.py`, `callosum.py`, `build-brain.py`). El índice a continuación organiza esos mismos IDs por alcance, importancia y granularidad para navegación y aprendizaje — sin cambiar los identificadores.

---

## Índice Canónico por Alcance, Importancia y Granularidad

### Nivel 1 — Contratos Fundamentales
> Alcance: todo brain, toda instancia. Impacto: si se rompe, el brain no puede federarse ni razonarse. Granularidad: principios arquitectónicos.

| Rango | Regla | Enunciado en una línea | Artefacto verificable |
|-------|-------|----------------------|----------------------|
| 1 | **B25** | El brain es el espejo de la empresa, no su idealización | Fuente de verdad declarada en `system_info` |
| 2 | **B29** | Los DTs construyen el brain en enjambre — como abejas | `build_agent` en `system_info` |
| 3 | **B41** | 21 DTs canónicos en tres categorías: 10 de rol de TI, 6 de negocio y 5 de ingeniería | `dt/cobertura-dt.md` con cobertura 38 de 38 |
| 4 | **B42** | Confidencialidad: el acceso se autoriza por propósito; tres fronteras, negado por defecto | `queries.purpose` NOT NULL · `knowledge_lineage.exposed_for` · `brain.py abrir_consulta()` (ADR-EB-013) |
| 5 | **B34** | Ambos hemisferios son transformacionales, impulsados por IA | **Sin artefacto**: es un principio, no una regla verificable |
| 6 | **B35** | El brain evalúa el resultado esperado y solicita lo que falta | `knowledge_gaps` con consulta concreta al SME |
| 7 | **B45** | Toda consulta es un objeto con ciclo de vida de seis etapas | Tabla `queries` · las seis etapas en `brain.py` (ADR-EB-013) |
| 8 | **B38** | Capa agéntica que escala la IA en Run y Change, sin sustituir herramientas dedicadas (CMDB, Tosca) | **Pendiente**: no hay catálogo de casos de uso |
| 9 | **B39** | Autonomía A0-A3: el nivel lo fija la acción, no la intención; se gana con historial y se pierde con incidentes | **Pendiente**: no existe registro de acciones ni de su autonomía |
| 10 | **B1** | Cada brain es auto-sustentable — 5 métodos sin federación | Interfaz `brain.py` |
| 11 | **B15** | CORE (18 tablas) + exactamente una extensión por `brain_type` | D1 del DT-Validador |
| 12 | **B21** | Ontología = matriz 2×2: ETB × ITOM, Change × Run | `ontology_bindings` poblada |
| 13 | **B36** | Frameworks complementarios: ETB da el north star, ITOM habilita, TOGAF gobierna | Trazas `itom_layer.process_id` y SLO a KPI |
| 14 | **B24** | Los hemisferios se hablan en ambos sentidos (puente calloso) | D8 del DT-Validador |
| 15 | **B4** | Federación via SQLite ATTACH — sin servidor entre brains | `federated_brains` + ATTACH |

### Nivel 2 — Honestidad y Calidad del Conocimiento
> Alcance: todo dato que entra al brain. Impacto: si se rompe, el brain miente. Granularidad: contratos de calidad del dato.

| Rango | Regla | Enunciado en una línea | Artefacto verificable |
|-------|-------|----------------------|----------------------|
| 16 | **B37** | Calidad y linaje: gold, silver, bronze; los hechos irrefutables entran directo a gold | `knowledge_lineage` y D9 del DT-Validador |
| 17 | **B43** | El brain se mide a sí mismo en cinco ejes, incluido el acierto de su consejo | `decisions` con evidencia y resultado · `brain.py autoevaluacion()` (ADR-EB-013) |
| 18 | **B40** | Bi-temporal: el tiempo del negocio (`valid_from`/`valid_to`) no es el tiempo del brain (`recorded_at`) | `brain.py snapshot(date)` y `latencia_bitemporal()` · SLO-EB-05 |
| 19 | **B17** | Ningún hueco se rellena con datos inventados — va a `knowledge_gaps` | `knowledge_gaps` con `resolution_action` |
| 20 | **B30** | El `business_name` es el contrato de calidad de cada pieza de conocimiento | D3 del DT-Validador |
| 21 | **B31** | El brain declara su corpus fuente (`source_of_truth`) | D1 advertencia si vacío |
| 22 | **B32** | Transición sin `run_owner` no puede cerrar (cutover/done) | D8 bloqueante |
| 23 | **B5** | Cross-deps declaradas en ambos lados con evidencia cuantificada | `cross_dependencies` bilateral |

### Nivel 3 — Ontología y Semántica
> Alcance: el modelo de conocimiento del brain. Impacto: sin ontología, los hallazgos no se pueden agregar ni comparar entre brains. Granularidad: contratos de semántica.

| Rango | Regla | Enunciado en una línea | Artefacto verificable |
|-------|-------|----------------------|----------------------|
| 24 | **B27** | Cadena de valor: Productos → KPIs → Procesos → Apps → Infra → Datos | `products` + `kpis` en CORE |
| 25 | **B28** | TOGAF es el gobierno de la arquitectura: da estructura (BDAT), método (ADM) y gobierno | Cada tabla mapeada a un dominio BDAT |
| 26 | **B22** | Todo conocimiento ata a un proceso de negocio (`process_id`) | D7 del DT-Validador |
| 27 | **B19** | La ontología de la industria la suministra el Industry SME, no el brain | `system_info.industry_sme` |
| 28 | **B20** | Cada empresa compone su propia ontología (multi-industria es la norma) | `ontology_bindings` multi-fila |
| 29 | **B23** | El ITOM lo ancla `itom_layer`; el SME lo prescribe — el brain no inventa | `itom_layer` + `itom_sme` |
| 30 | **B2** | Capabilities embebidas + ontología declarada en `system_info` | `capabilities` + `capability_model` |
| 31 | **B33** | El enterprise brain expone `value_chain()` federada | Método en `brain.py` enterprise |

### Nivel 4 — Estructura y Federación
> Alcance: cómo se organizan y nombran los brains. Impacto: sin estructura correcta, los loaders genéricos fallan y los análisis cross-brain son inconsistentes. Granularidad: convenciones arquitectónicas.

| Rango | Regla | Enunciado en una línea | Artefacto verificable |
|-------|-------|----------------------|----------------------|
| 32 | **B13** | Hemisferio declarado en `system_info.hemisphere` (change/run) | `system_info.hemisphere` |
| 33 | **B14** | `brain_type` declarado en `system_info` (enterprise/project/system) | `system_info.brain_type` |
| 34 | **B18** | El brain de cliente se nombra por industria: `{industria}-brain` | Carpeta + `slug` |
| 35 | **B16** | Homologar por vista (`CREATE VIEW`), no por migración de datos | Vista canónica sobre tabla histórica |
| 36 | **B7** | Capability gap = 0 antes de decommission (`[BREAK-GLASS]` si no) | `bank-brain.capability_gap()` |
| 37 | **B3** | El bank-brain detecta desalineación ETB vía `capability_alignment()` | Método enterprise en `brain.py` |
| 38 | **B6** | Sistemas externos con suficiente complejidad siguen la estructura canónica | `external_systems` |

### Nivel 5 — Historia, Descubrimiento y Propagación
> Alcance: cómo crece el brain a partir de evidencia nueva. Impacto: sin estas reglas el brain no puede ser bootstrapeado desde cero ni enriquecerse con descubrimientos. Granularidad: protocolo operativo.

| Rango | Regla | Enunciado en una línea | Artefacto verificable |
|-------|-------|----------------------|----------------------|
| 39 | **B26** | Todo brain comienza con el estudio histórico de la organización | **Pendiente**: la carpeta no existe en el asset |
| 40 | **B44** | El brain sobrevive al sistema que refleja y se archiva con reglas propias | `status='archived'` y `snapshot(date)` vigente |
| 41 | **B8** | Evidencia operativa es prueba de existencia de un sistema | `system_info` semilla |
| 42 | **B9** | Acción inmediata al descubrir un sistema significativo | Estructura canónica vacía + CLAUDE.md |
| 43 | **B10** | Knowledge Interlock: conocimiento descubierto se propaga a ambos extremos | Commits en ≥ 2 `build-brain.py` |
| 44 | **B11** | Seeds push: el brain emite evidencia a sus vecinos sin esperar | `seeds/{receptor}-seed.json` |
| 45 | **B12** | Un sistema descubierto arranca con `brain.db` inicializado desde seeds | `brain.db` mínimo desde B9 |

**Siete reglas no tienen artefacto verificable hoy, y el índice lo declara.** Cinco esperan implementación (B38, B39, B40, B42, B43), una espera un artefacto del asset (B26) y una es un principio y no una regla auditable (B34). `quality-gates-enterprise-brain.md` lista en su sección de gates no exigibles qué falta para poder exigir cada una. Mientras el índice prometía artefactos inexistentes, el canon no se podía usar para auditar nada, y B42 quedaba autorrefutada: dice que una política que vive en un documento y no en el filtro no es política sino intención.

### Reglas de Vocabulario (V1-V2)
> Alcance: vocabulario empresarial cross-sistema. Importancia: alta para consistency semántica; no bloquea activación.

| Regla | Enunciado |
|-------|-----------|
| **V1** | Vocabulario empresarial como semilla cross-sistema (confirmar/enriquecer/proponer) |
| **V2** | Conflictos de vocabulario: los resuelve el Industry SME, no el agente técnico |

### Reglas de Pipeline (P1-P5)
> Alcance: cómo se construye el brain. Importancia: alta para reproducibilidad; no bloquea consulta.

| Regla | Enunciado |
|-------|-----------|
| **P1** | Toda actualización del brain pasa por un generador o conector — nunca directo desde la fuente. Fuentes estáticas: `source/` → `knowledge-base/` → `digital-brain/`. Fuentes vivas (Git, Jira, monitoring, CMDB): conector → (opcionalmente `knowledge-base/`) → `digital-brain/` |
| **P2** | Principio de pipeline — ningún dato en `brain.db` sin el parser o conector capaz de recrearlo desde la fuente original; para connectors, reproducir significa re-pull desde el historial del sistema origen |
| **P3** | Marks de alta confianza (`CTM_ENTRY`, `CTM_HINT`) no se sobreescriben |
| **P4** | Portal HTML generado siempre desde `build-portal.py` — nunca hand-authored |
| **P5** | `brain.db` en `.gitignore` — se reconstruye desde el pipeline |

**Sobre los generadores de Capa 2.** Los generadores son ad-hoc por diseño y se dividen en dos tipos. Los **parsers** procesan fuentes estáticas que el cliente entrega: código SPL, COBOL, ABAP, T-SQL, pero también PPTs, Word, PDFs, diagramas de arquitectura, minutas de entrevistas. Los **connectors** integran sistemas vivos — Git, Jira, herramientas de monitoreo, CMDB, pipelines de CI/CD — y pueden alimentar el brain de forma continua o bajo demanda. No existe un template único porque las fuentes no son únicas.

Lo que no varía nunca es P2: si un dato está en `brain.db` y no existe el parser o conector capaz de producirlo desde la fuente original, ese dato es deuda no trazable. Para un parser, reproducir significa re-parsear el archivo. Para un connector, reproducir significa re-pull desde el historial del sistema origen (el log de commits de Git, el historial de Jira, las métricas históricas del monitor). Actualizar `brain.db` directamente sin esa capacidad es el anti-patrón que invalida al brain como fuente de verdad — un brain que no se puede reconstruir no es un gemelo cognitivo sino un documento que envejece.

---

## Reglas de Arquitectura de Brains (B)

> Los IDs B1-B33 son estables y referenciados en código. El **Índice Canónico** al inicio de este documento los organiza por alcance, importancia y granularidad (5 niveles). Las reglas aquí están agrupadas por grupo temático para lectura continua.

**B1 — Brain auto-sustentable**: cada brain funciona de forma independiente sin depender de bank-brain en runtime. La interfaz estándar de 5 métodos (`coverage`, `components`, `search`, `rules`, `domains`) opera sin federación.

**B2 — Catálogo de capabilities embebido, ontología declarada**: cada brain embebe su catálogo completo de capabilities en la tabla `capabilities`, declarando en `system_info.capability_model` qué ontología usa (ETB, BIAN, RTL+FSV, ETB P&C o custom) y en `capability_version` su versión. El brain responde "¿qué capabilities cubro?" sin preguntar a nadie más.

La ontología es un atributo del cliente, no del canon: en el estate conviven ETB banca (BanCoppel, Banamex), RTL+FSV retail (Liverpool), BIAN (Gentera) y ETB P&C seguros (AXA). El canon fija la estructura jerárquica L1/L2/L3; el catálogo lo elige el cliente.

**B3 — bank-brain como custodio del modelo ETB**: cuando ETB evoluciona, bank-brain detecta qué brains tienen `etb_version` desalineada via `capability_alignment()` y coordina la realineación. Cada brain desalineado recorre su `build-brain.py` con el nuevo catálogo.

**B4 — Federación via ATTACH**: bank-brain federada queries mediante SQLite `ATTACH DATABASE`. No hay servidor de API entre brains — solo archivos `brain.db`. Agregar un sistema al federation = ATTACHar su brain.db y añadir un UNION en los métodos federados.

**B5 — Cross-brain dependencies declaradas en ambos lados**: cuando A depende de B, ambos sistemas declaran la dependencia explícitamente en su tabla `cross_dependencies` con dirección (`inbound`/`outbound`) y evidencia cuantificada. La dependencia se documenta aunque el sistema externo no tenga brain propio.

**B6 — Estructura canónica para sistemas externos con brain propio**: cuando un sistema externo tiene suficiente complejidad para merecer un brain (Control-M, portal externo, sistema regulatorio), sigue la misma estructura canónica que cualquier sistema interno.

### Autonomía y federación (B1-B6)

### Descubrimiento y estructura (B7-B14)

**B7 — Capability gap como gate de decommission**: antes de apagar un sistema legacy, `bank-brain.capability_gap()` debe retornar cero capabilities sin cobertura — o cada gap tiene `[BREAK-GLASS]` firmado con owner del riesgo.

**B8 — Evidencia operativa como prueba de existencia**: un artefacto operativo (inventario CTM, logs ESB, catálogo de interfaces, topología de red) es prueba suficiente para abrir un sistema en la estructura canónica. No se necesita el código fuente para declarar que el sistema existe.

**B9 — Acción inmediata al descubrir un sistema**: todo sistema descubierto con presencia significativa (≥10 jobs/interfaces, o nombrado explícitamente en arquitectura del cliente) recibe su estructura canónica inmediatamente. La estructura vacía + CLAUDE.md con metadatos es suficiente para sembrar el sistema.

**B10 — Knowledge Interlock**: todo conocimiento comprobado sobre un sistema, descubierto mientras se analiza otro, se propaga a ambos extremos. El commit debe incluir cambios en al menos 2 archivos: `build-brain.py` del descubridor + `build-brain.py` o `CLAUDE.md` del receptor.

**B11 — Seed Generation**: todo `build-brain.py` genera activamente seeds — evidencia estructurada en `digital-brain/seeds/{receptor}-seed.json` — para cada sistema con relación conocida. Los seeds son push, no pull.

**B12 — Seed Brain Initialization**: cuando B9 crea la estructura canónica de un sistema descubierto, B12 inicializa un `brain.db` mínimo con toda la evidencia disponible de sistemas emisores. `digital-brain/brain.db` existe desde el momento en que la estructura se crea. El brain crece de seed → completo; nunca retrocede.

**B13 — Asignación de Hemisferio**: todo brain pertenece a uno de dos hemisferios del cliente, declarado en `system_info.hemisphere`:

| Hemisferio | Valor | Carpeta canónica | Tipo de trabajo |
|-----------|-------|-----------------|-----------------|
| Change (izquierdo) | `change` | `projects/` | Proyectos de transformación, modernización, nuevas implementaciones — Change the Business |
| Run (derecho) | `run` | `systems/` | Sistemas en producción bajo operación continua — Run the Business |

El bank-brain federada ambos hemisferios vía ATTACH. Un brain no puede cambiar de hemisferio sin ADR-EB firmado — la asignación es una propiedad de la naturaleza del trabajo, no del estado del proyecto.

**B14 — brain_type en system_info**: todo brain declara su tipo en `system_info.brain_type`:

| Tipo | Valor | Descripción |
|------|-------|-------------|
| Enterprise (bank-brain) | `enterprise` | Nivel más alto del cliente — federación de todos los brains Change y Run |
| Proyecto | `project` | Brain de un proyecto específico dentro del hemisferio Change |
| Sistema | `system` | Brain de un sistema en producción dentro del hemisferio Run |

El bank-brain del cliente es el único brain de tipo `enterprise`. Los demás son `project` o `system` según su hemisferio.

### Schema y contrato (B15-B17)

**B15 — CORE + una extensión**: todo brain implementa las 18 tablas del CORE (`system_info`, `ontology_bindings`, `capabilities`, `processes`, `products`, `kpis`, `stakeholders`, `data_entities`, `technology_components`, `suppliers`, `measurements`, `costs`, `itom_layer`, `cross_dependencies`, `signals`, `knowledge_gaps`, `knowledge_lineage`, `queries`) más exactamente la extensión que le corresponde por `brain_type`. El DDL ejecutable es `templates/schema.sql` — única fuente de verdad, nunca transcrito en documentos.

**El CORE tiene dos fundamentos legítimos** (ADR-EB-011). El primero es la destilación: una tabla entra cuando existe en tres o más brains independientes (ADR-EB-006), con la excepción acotada de ADR-EB-009 para `kpis`, `data_entities` y `technology_components`. El segundo es la implicación del roster: si un DT canónico obligatorio posee una tabla, esa tabla es CORE por consecuencia, y es el caso de `suppliers`. Hay un **tercer fundamento** (ADR-EB-012): una tabla entra cuando una regla vigente exige una capacidad que ninguna tabla sostiene, como ocurrió con `measurements` y `costs`. Exige tres condiciones simultáneas: que la regla ya esté aprobada y no se escriba junto con la tabla, que ninguna tabla existente pueda sostener la capacidad, y que el ADR nombre la frase exacta que queda incumplida sin ella. Existe porque la destilación tiene un punto ciego: solo canoniza lo que alguien ya construyó, y el canon puede prometer en una regla lo que su esquema no puede cumplir.

El segundo fundamento es más exigente de lo que parece, porque solo aplica a tablas poseídas por un DT del roster y el roster solo crece con ADR. Ver ADR-EB-006, ADR-EB-009, ADR-EB-010, ADR-EB-011, ADR-EB-012 y ADR-EB-013.

El CORE es el contrato de interoperabilidad: es lo que un brain debe exponer para que otro pueda federarlo. Un brain de proyecto no implementa `rules` y eso es correcto — su ontología es `applications`/`waves`/`risks`/`decisions`.

**B16 — Homologar por vista, no por migración**: un brain con corpus poblado no reescribe su pipeline para adoptar los nombres canónicos. Crea una vista con el nombre canónico sobre su tabla histórica:

```sql
CREATE VIEW IF NOT EXISTS components AS
SELECT id, name, label AS display_name, biz AS description, ...
FROM sps;
```

Preserva la inversión en el pipeline, es reversible y homologa la interfaz de inmediato. El patrón está validado en Banamex (`risks` ← `hallazgos`) y probado contra los 11,391 SPs de Informix.

La migración real de datos solo se justifica cuando la tabla histórica no puede expresar un campo obligatorio del canon. En ese caso el hueco se declara en `knowledge_gaps`, no se inventa.

**B17 — Ningún hueco se deja muerto**: ningún campo del canon se rellena con datos inventados ni con `PENDIENTE`. Un dato que falta se registra en `knowledge_gaps` con `resolution_action` redactada como consulta concreta a un SME identificado. El schema es el spec de lo que falta.

### Ontología (B18-B23)

**B18 — El brain de cliente se nombra por industria, no por cliente**: el brain de nivel `enterprise` se llama `{industria}-brain` — `bank-brain`, `insurance-brain`, `retail-brain` — nunca `{cliente}-brain`.

La razón no es cosmética. La semántica del brain la determina la industria, no el cliente: dos bancos comparten vocabulario, ontología de capabilities, ontología de procesos y regulador; un banco y una aseguradora no comparten ninguno de los cuatro. Nombrar por cliente oculta lo que el brain realmente es y rompe cualquier loader genérico.

| Industria | Brain | Clientes del estate |
|-----------|-------|--------------------|
| Banca | `bank-brain` | BanCoppel · Banamex · Santander · MONEX · Gentera |
| Seguros | `insurance-brain` | AXA |
| Retail | `retail-brain` | Liverpool · Coppel |

**B19 — La ontología de industria la suministra el Industry SME, no el brain**: el brain no inventa vocabulario, capabilities ni procesos de su industria. Los toma del Industry SME correspondiente en `SME/Industry/`, declarado en `system_info.industry_sme`.

Cada industria trae **cuatro ontologías distintas e incompatibles entre sí**:

| Dimensión | Banca | Seguros | Retail |
|-----------|-------|---------|--------|
| Capabilities | ETB banca (L3 numerado) · BIAN | ETB por ramo (P&C v3.0, Life v2.0) | RTL + overlay FSV |
| **Procesos** | Por producto financiero: captación, crédito, pagos, tarjetas, disputas | Ramo primero, luego ciclo de póliza: suscripción → emisión → siniestro → reaseguro | Cadena de valor por fases: PLAN → BUY → MOVE → SELL → SERVE |
| Regulador | CNBV · Banxico · CONDUSEF · IPAB · UIF | CNSF · IFRS 17 | PROFECO · SAT (+ CNBV si hay brazo financiero) |
| Eje LOB / ramo | No existe | **Sí, es el eje raíz** — P&C, Vida-AP, Salud-GMM, Fianzas | No (pero sí categoría/departamento) |

**B22 — Todo conocimiento ata a un proceso de negocio**: cada fila de cada tabla de conocimiento del brain declara a qué proceso pertenece. `processes` es tabla del CORE y las tablas de conocimiento llevan `process_id`:

| Tabla | Trazabilidad |
|-------|-------------|
| `rules` · `vocabulary` · `capabilities` | `process_id` |
| `applications` · `risks` · `user_stories` | `process_id` |
| `regulatory_obligations` · `knowledge_gaps` | `process_id` |
| `journeys` | `process_id` — qué proceso realiza la traza |
| `components` | `component_processes` (N:M — un componente sirve a varios procesos) |

**Por qué es regla y no recomendación.** Conocimiento sin proceso no se puede accionar ni priorizar. Una regla de negocio que no ata a un proceso no se sabe a quién afecta si cambia; un riesgo sin proceso no se sabe qué operación pone en peligro; un término de vocabulario sin proceso no se sabe dónde se usa. El brain deja de responder la pregunta que justifica su existencia: *¿qué parte del negocio toca esto?*

Consecuencias operativas:

- **La dimensión D7 del DT-Validador cuenta conocimiento huérfano** por tabla. Es hallazgo bloqueante: un brain no se activa con conocimiento que no ata a nada.
- **Un hueco de trazabilidad no se rellena a la fuerza.** Si no se sabe a qué proceso pertenece una regla, va a `knowledge_gaps` con la consulta al SME correspondiente (Regla B17). Inventar el enlace es peor que declararlo faltante.
- **El enlace lleva confianza.** En `component_processes`, `confidence` distingue `confirmed` (evidencia directa: journey, job de CTM, documento) de `inferred` y `suspected`. Un enlace inferido es utilizable pero auditable.

**B27 extiende B22, no la reemplaza.** El ancla mínima sigue siendo el `process_id` — sin él, el conocimiento no se puede accionar. El ancla completa es la cadena de valor de B27: `product_id` → `kpi_id` → `process_id`. Un componente sin proceso no sabe a qué operación sirve. Un KPI sin producto no sabe por qué importa. Nunca inventar el enlace: si no se sabe, va a `knowledge_gaps` (B17).

**B20 — Cada empresa tiene su propia ontología, compuesta de los ETB que le corresponden**: la multi-industria es la norma, no la excepción. Una empresa no "elige" una industria y le agrega un parche: compone su ontología a partir de los ETB de todas las industrias en las que opera, más sus extensiones propias.

La composición se declara en la tabla `ontology_bindings` y cada capability lleva su `ontology` de origen.

Caso probado — Liverpool:

| Ontología | Catálogo | Versión | L3 | Rol |
|-----------|---------|---------|-----|-----|
| `retail` | Retail_ETB_V4 | 5.0 | 171 | primary |
| `retail` | **Newly Added** (extensión propia) | 5.0 | **61** | primary |
| `financial_services` | financial_services | 1.0 | 50 | secondary |

Los 61 "Newly Added" son capabilities de Liverpool que no existen en el ETB base. Son legítimas y se marcan con `is_extension=1` — la ontología de la empresa es **ETB base + extensiones propias**, no solo el catálogo heredado.

Tres consecuencias:

- **La regulación viaja con la capability, no con la empresa.** Las 50 capabilities FSV de Liverpool cargan CONDUSEF y Banxico dentro de una empresa de retail, porque su operación de tarjeta está regulada como financiera. Por eso `regulation` es columna de `capabilities` y `regulators` es JSON array por ontología en `ontology_bindings`.
- **El nombre del brain lo fija la industria ancla** (`system_info.industry`), no la composición. Liverpool sigue siendo `retail-brain` aunque componga dos ontologías.
- **Declaración y carga deben coincidir.** Toda ontología presente en `capabilities` debe estar declarada en `ontology_bindings` y viceversa. El DT-Validador contrasta ambas.

Consecuencias prácticas:

- La ontología de procesos **no se deriva** de la de capabilities. Son modelos distintos y ambos se declaran: `capability_model` y `process_ontology` en `system_info`.
- `lob_dimension` se deja NULL cuando la industria no tiene ese eje. No se inventa un eje que no existe — es la razón por la que el brain de AXA necesitó 11 columnas de ramo que ningún brain bancario tiene.
- La composición de ontologías se gobierna con la Regla B20 y la tabla `ontology_bindings`.
- Las tablas `processes` y `journeys` son distintas y ambas necesarias: `processes` es el modelo de la industria (cómo debería operar); `journeys` son las trazas reales por el código (qué hace de hecho). **La brecha entre ambas es hallazgo de negocio**, no error de datos.

**B21 — La ontología del brain es una matriz 2×2**: dos dimensiones (ETB y ITOM) × dos hemisferios (Change y Run). Toda celda debe estar cubierta — el hemisferio del brain determina el **lente** con que se lee cada capacidad, no si la ontología aplica.

```
              │  Definición del negocio (ETB)         │  Habilitador IT (ITOM)
──────────────┼───────────────────────────────────────┼──────────────────────────
Change the    │  Estrategia del negocio               │  IT Strategy + Delivery
Business      │  ¿Qué capacidades transformamos?      │  ¿Cómo IT diseña y entrega?
──────────────┼───────────────────────────────────────┼──────────────────────────
Run the       │  Operaciones del negocio              │  Technology Operations
Business      │  ¿Qué capacidades operamos hoy?       │  ¿Cómo IT sostiene y opera?
```

Las tablas del CORE cubren las cuatro celdas:
- `capabilities` + `processes` → columna ETB (Change y Run leen el mismo catálogo; el lente lo da `hemisphere`)
- `itom_layer` → columna ITOM (Change usa `it-strategy`+`delivery`; Run usa `technology-operations`)
- `ontology_bindings` declara ambas columnas — `model_type` diferencia el lado negocio (`etb`·`bian`·`regulatory`…) del lado IT (`itom`)

Un brain que solo tiene ETB sabe qué hace el negocio pero no sabe cómo IT lo habilita. Un brain que solo tiene ITOM sabe cómo opera IT pero no contra qué capacidad de negocio. Las dos dimensiones son necesarias para que el brain sea accionable.

Un brain sin ancla acumula hallazgos que no se pueden agregar, comparar ni federar con nada — deja de ser brain y se vuelve un repositorio de notas.

El ancla no tiene que ser un ETB. El estate usa hoy seis tipos de modelo, todos legítimos:

| `model_type` | Modelo | Dónde está en uso |
|-------------|--------|------------------|
| `etb` | ETB sectorial | Banca (BanCoppel, Banamex) · Retail_ETB_V4 (Liverpool) · P&C y Life ETB (AXA) |
| `bian` | BIAN Service Landscape | Gentera · Banamex (`capability_bian_map`) |
| `regulatory` | Obligaciones de un instrumento | BanCoppel CAN (Banxico Circ. 6/2025) · Santander CAN (Circ. 3/2012) |
| `it-capability` | Modelo de capacidades TI | Unity (`it_capabilities`) |
| `value-chain` | Cadena de valor | Liverpool (`value_chain`) |
| `client-logical` | Modelo operativo lógico propio del cliente | AXA P&C |

**Los brains de proyecto no están exentos.** La evidencia del estate lo confirma: 4 de 5 ya lo cumplen — Unity ancla a capacidades TI, BanCoppel CAN a obligaciones Banxico, Santander CAN a ETB más obligaciones, MONEX payments-modernization a macro-capacidades de pagos. **Exodus es el único sin ancla**, y eso es brecha, no decisión de diseño.

Para un brain de proyecto, la ontología de negocio es el modelo contra el cual se mide el cambio: qué capabilities toca la migración, qué obligaciones cubre el proyecto. Sin eso no hay forma de responder "¿qué parte del negocio queda afectada?".

**B23 — La ontología de IT Operating Model la define el SME; el brain la ancla en `itom_layer`**: el SME canónico es `SME/Framework/IT Operating Model` (ITOM v9.0 + marco conceptual 2024–2027). Ese SME prescribe la tabla `itom_layer` como el punto de anclaje en los Digital Brains — por eso es CORE, no extensión.

`itom_layer` declara qué dominios del IT Operating Model cubre el brain y en qué nivel de madurez. Los seis dominios canónicos y sus sub-capacidades:

| `layer` | Dominio ITOM | Sub-capacidades |
|---------|-------------|----------------|
| `customer-engagement` | Customer and Ecosystem Engagement | business-strategy · supplier-mgmt · demand-mgmt · service-performance |
| `it-strategy` | IT Strategy | it-strategy · product-service-strategy · portfolio-mgmt · enterprise-arch |
| `delivery` | Product / Service Delivery | product-service-design · solution-architecture · product-creation · release-deployment · delivery-mgmt |
| `technology-operations` | Technology Operations | service-mgmt · infra-platform-ops · service-ops |
| `information-analytics` | Information and Analytics | analytics · information-data-mgmt |
| `it-management` | IT Management | tech-financial-mgmt · risk-compliance · talent-change · security-strategy |

El dominio más relevante para sistemas heredados en operación (core bancario, ERP, mainframe) es **`technology-operations`** — ahí viven ITSM/ITIL, la operación de infraestructura (IBM POWER/AIX, z/OS) y los Service Operations (batch, interfaces, schedulers). El análisis ITOM de un sistema legacy empieza aquí y se expande a los otros dominios.

El brain también declara en `system_info`:
- `itom_model` — qué versión del framework aplica ("IT Operating Model v9.0", "ITIL v4 SMP")
- `itom_sme` — siempre `"SME/Framework/IT Operating Model"`

Ambas dimensiones aplican a los dos hemisferios. Los dominios ITOM no son opcionales por hemisferio — lo que difiere es cuáles son los predominantes:

| Hemisferio | Dominio ITOM | Sub-capacidades clave | Por qué |
|-----------|-------------|----------------------|---------|
| **Change** | `it-strategy` | IT Strategy · Portfolio Management · Enterprise Architecture | El proyecto define dirección tecnológica y arquitectura |
| **Change** | `delivery` | Solution Architecture · Product Creation · Release & Deployment | El proyecto diseña y entrega la capacidad IT |
| **Run** | `technology-operations` | Service Management · Infrastructure & Platform Ops · Service Ops | El sistema opera en producción continua |
| **Ambos** | `customer-engagement` | Business Strategy · Demand Management · Service Performance | Conecta negocio con IT en ambos hemisferios |
| **Ambos** | `information-analytics` | Analytics · Information & Data Management | El activo de datos aplica en Change y Run |
| **Ambos** | `it-management` | FinOps · Risk & Compliance · Talent · Security | Gobernanza transversal a todo el ciclo |

**`itom_layer` vacía** es válida solo en scaffolds recién iniciados — no por hemisferio. Un brain `status='active'` sin `itom_layer` poblada es conocimiento huérfano en ambos hemisferios.

El modelo completo — 38 procesos canónicos, 46 roles, Balanced Scorecard, principios de arquitectura por plataforma — vive en la `knowledge_base/` del SME, no en el brain.

**Por qué ITOM está en el CORE.** No solo para describir cómo opera TI. El brain es una capa agéntica (B38) que participa en las capacidades de TI, y cada capacidad de TI existe para habilitar al negocio. `itom_layer` es por eso el ancla de los casos de uso de IA: dice en qué capacidad participa la IA, qué proceso de negocio soporta esa capacidad y, por la cadena de valor, qué KPI termina moviendo.

### Puente Change-Run (B24)

**B24 — Cuerpo calloso: los hemisferios se hablan en ambos sentidos.** Lo que Change decide tiene que llegar a Run, y lo que Run aprende tiene que volver a Change. Ningún brain puede verificarlo solo, así que cada hemisferio declara su lado del puente desde su propia perspectiva (Regla B1) y el cruce lo razona el enterprise brain con `templates/callosum.py`, vía ATTACH y sin copiar datos.

| Lado | Brain | Tablas | Qué declara |
|------|-------|--------|-------------|
| Change → Run | proyecto | `plateaus` · `transitions` · `readiness_gates` · `slos` | Qué se mueve, de qué sistema a cuál, en qué estado de arquitectura, con qué patrón, quién lo operará y qué tiene que estar listo antes |
| Run → Change | sistema | `findings` · `slos` | Lo que la operación aprendió (incidentes, recurrencias, deuda, patrones), con su ruteo hacia el brain de proyecto que debe saberlo |
| Trazabilidad | ambos | `components.origin_transition_id` · `user_stories.origin_finding_id` · `risks.origin_finding_id` | De qué transición vino lo que Run opera; de qué hallazgo nació lo que Change construye |

Tres reglas de contenido:

- **Un destino desconocido no es transición.** `fate` se declara en vocabulario canónico (retain, retire, rehost, replatform, refactor, rearchitect, replace, encapsulate) y el valor original del cliente se conserva en `fate_source`. Si no se sabe, va a `knowledge_gaps` (Regla B17).
- **Nada cruza a Run sin dueño ni readiness.** Una transición en `cutover` o `done` exige `run_owner` y todos sus `readiness_gates` en `done` o `waived`.
- **El SLO es el objeto que vive en los dos hemisferios.** Change fija el `target` al diseñar; Run mide el `current` al operar, con el mismo id. Un SLO sin current es una promesa; sin target, una medición sin contrato.

El razonamiento de `callosum.py` detecta seis rupturas:

| Código | Dirección | Ruptura |
|--------|-----------|---------|
| C1 | Change → Run | Transición hacia o desde un sistema sin brain federado |
| C2 | Change → Run | Change dice cutover o done; Run no tiene componentes con `origin_transition_id` |
| C3 | Change → Run | Change dice done; Run sigue operando la entidad |
| C4 | Change → Run | SLO comprometido que Run no mide |
| R1 | Run → Change | Hallazgo abierto que toca una entidad en transición |
| R2 | Run → Change | Hallazgo ruteado que Change no registró |

**Evidencia en el estate.** Siete brains modelan el destino de la migración, cada uno a su manera: bank-brain `migrations` con 11,391 filas, Unity `informix_migration_map`, Liverpool `migration_fate`, Coppel `platform_capabilities`, Banamex `sevenr_decisions`, Exodus `apo_class` y `ams_support_proposal`. Ninguno implementa el camino de regreso.

Al razonar el puente entre Unity e Informix (2026-10-01) aparecieron tres rupturas reales:

- El hallazgo del incidente de `intercard` del 2026-09-14 toca SPs del dominio D03, que Unity está migrando a SmartVista, y nunca llegó a Unity.
- Unity da por terminados D01, D02 y D04 hacia Transact, pero Informix sigue con 5,743 SPs activos en esos dominios.
- Esas tres transiciones cerradas no tienen `run_owner` ni readiness, porque el PRR de Unity está registrado por capability y no por transición.

### Verdad, transformación y razonamiento (B25-B45)

**B25 — El brain es el espejo de la empresa, no su idealización**: el Enterprise Brain no modela lo que la empresa debería ser — refleja lo que es. De ahí viene su nombre: *Enterprise* Brain, no *Target* Brain ni *Future* Brain. Cada hemisferio alimenta de su fuente de verdad natural y no de otra:

| Hemisferio | Fuente de verdad | Qué refleja |
|-----------|-----------------|-------------|
| **Run the Business** | Lo que está en productivo: código real en ejecución, jobs activos, incidentes operativos, SPs que corren hoy, comportamiento medido | La empresa como opera ahora — con sus fortalezas, su deuda técnica, sus workarounds y sus contradicciones |
| **Change the Business** | Los objetivos estratégicos aprobados: roadmap firmado, decisiones de arquitectura con dueño, metas de transformación comprometidas, OKRs | La empresa a donde se dirige — con sus prioridades reales y sus restricciones de entrega |

Un brain que refleja documentación en lugar del sistema productivo, o aspiraciones en lugar de objetivos aprobados, no es un espejo — es una ilusión. El brain no corrige ni embellece la realidad que refleja: si el sistema productivo tiene deuda técnica, el brain la registra. Si la estrategia tiene brechas, el brain las declara como `knowledge_gaps`. Un hallazgo que contradice el estado productivo real es un error del brain, no de la producción.

**La cultura organizacional es parte del espejo.** El brain refleja también cómo la empresa piensa y habla sobre sí misma:

- Usa el vocabulario del negocio, no el del extractor técnico. Los `business_name` de las reglas hablan el idioma del área de negocio que las entiende, no el idioma del SP que las implementa.
- Respeta las convenciones de nombrado y la jerarquía de decisión del cliente. Un término que el cliente llama de una forma no se renombra arbitrariamente en el brain.
- Reconoce el peso cultural de los sistemas heredados. En muchas organizaciones el sistema legacy es la cultura — reemplazarlo sin entender lo que hace (y por qué lo hace así) no es modernización sino destrucción de valor.

Esta regla tiene consecuencia directa en el pipeline: **Run the Business alimenta desde el código y la operación; nunca desde documentación que nadie ha verificado contra producción.** Change the Business alimenta desde artefactos firmados; nunca desde ideas o intenciones no comprometidas. El gap entre lo que dice la documentación y lo que hace el código es, en sí mismo, uno de los hallazgos más valiosos que el brain puede producir.

**B26 — Todo brain comienza con un estudio histórico de la organización**: antes de construir el brain, se documenta la historia de la empresa desde su fundación hasta hoy. La historia no es contexto decorativo — es la explicación del porqué del código. Un SP escrito de una forma extraña tiene una razón histórica. Una regla de negocio que parece arbitraria responde a una regulación de hace veinte años. Un sistema heredado con cuatro métodos distintos de calcular lo mismo fue absorbiendo tres adquisiciones distintas.

El estudio histórico se materializa en `knowledge-base/history/` y cubre al menos cinco dimensiones:

| Dimensión | Qué documenta | Por qué importa al brain |
|-----------|--------------|--------------------------|
| **Fundación y modelo de negocio original** | Año, giro, mercado inicial, propuesta de valor fundacional | Explica las capabilities más antiguas y los procesos más arraigados |
| **Hitos de crecimiento y expansión** | Adquisiciones, fusiones, nuevos mercados, alianzas estratégicas | Explica la heterogeneidad tecnológica: sistemas que no dialogan porque nunca fueron diseñados juntos |
| **Eventos regulatorios** | Cambios de ley que obligaron a transformar procesos (circulares, reformas, crisis) | Explica reglas de negocio que parecen arbitrarias: responden a obligaciones legales ahora olvidadas |
| **Decisiones tecnológicas históricas** | Plataformas adoptadas, migraciones intentadas y sus resultados, sistemas nunca reemplazados | Explica la deuda técnica: por qué aún corre COBOL, por qué hay tres formas de calcular el mismo campo |
| **Cultura organizacional y poder** | Cómo se toman decisiones, quién tiene autoridad real, qué se valora y qué se evita | Explica por qué algunas capacidades están subdesarrolladas y otras sobrediseñadas |

El estudio histórico es el **primer artefacto de DISCOVER** — antes de leer código, antes de mapear sistemas, antes de construir la primera tabla del brain. Sin él, el brain puede describir con precisión qué hace el sistema hoy, pero no puede responder la pregunta que más importa en una modernización: *¿por qué lo hace así?*

El estudio histórico se referencia desde `system_info.source_of_truth` y se vincula a los `knowledge_gaps` que la historia abre. No tiene que ser exhaustivo desde el día uno: puede comenzar con lo que se sabe y crecer con cada conversación con stakeholders.

**B27 — El brain está orientado a los KPIs y productos del cliente**: el brain no existe para describir código — existe para responder *¿qué parte del negocio toca esto y qué impacto tiene en los resultados del cliente?* Eso solo es posible si el conocimiento técnico está anclado en la cadena de valor del negocio. La cadena es la columna vertebral del brain:

```
Productos → KPIs → Procesos → Aplicaciones/Componentes → Infraestructura → Datos
```

| Eslabón | Tabla CORE | Pregunta que responde |
|---------|-----------|----------------------|
| **Productos** | `products` | ¿Qué ofrece el negocio al mercado? |
| **KPIs** | `kpis` | ¿Cómo se mide el éxito de cada producto? |
| **Procesos** | `processes` | ¿Cómo opera el negocio para entregar el producto? |
| **Aplicaciones / Componentes** | `applications` · `components` | ¿Qué sistemas realizan esos procesos? |
| **Infraestructura** | `technology_components` | ¿Qué plataformas sostienen esas aplicaciones? |
| **Datos** | `data_entities` · `component_data` (matriz CRUD) | ¿Qué entidades de datos usan esas aplicaciones? |

Los dos últimos eslabones se agregaron con ADR-EB-009. `itom_layer` no es infraestructura: describe cómo opera TI, y se conecta con lo que opera vía `technology_components.itom_layer_id` (Regla B36). `rules`, `vocabulary` y `journeys` no son entidades de datos: son lógica de negocio, lenguaje y trazas de ejecución. Un eslabón sin poblar se declara en `knowledge_gaps` (B17, B35).

Consecuencias prácticas:

- **Cada KPI tiene un `product_id` y un `process_id`**. Un KPI sin proceso no sabe quién lo mueve; un KPI sin producto no sabe por qué importa.
- **Change fija el `target`; Run mide el `current`**. El mismo objeto KPI vive en los dos hemisferios — es el contrato entre lo que el negocio prometió y lo que la operación entrega.
- **Un componente sin traza a la cadena es conocimiento muerto**. Si no se puede responder "¿qué producto y qué KPI toca este SP?", ese componente va a `knowledge_gaps` con la consulta concreta al SME de dominio (Regla B17).
- **`value_chain(product_id)`** es el método de razonamiento que materializa la cadena: dado un producto, devuelve sus KPIs, los procesos que los mueven, los componentes que realizan esos procesos y la infraestructura que los sostiene.

**B28 — TOGAF es el gobierno de la arquitectura y le da estructura al brain**: TOGAF no es una tercera ontología que compite con ETB e ITOM; es el marco que las ordena. ETB dice qué es el negocio, ITOM dice cómo TI lo habilita, y TOGAF dice dónde vive cada pieza, cómo se gobierna y cómo evoluciona (Regla B36). Aporta tres cosas:

| Aporte de TOGAF | Qué le da al brain | Dónde se materializa |
|----------------|-------------------|---------------------|
| **Estructura** (metamodelo de contenido, dominios BDAT) | Un lugar para cada pieza de conocimiento: negocio, datos, aplicación y tecnología | Cada tabla pertenece a un dominio; el dominio es de la tabla, no de la fila |
| **Método** (ADM) | El ciclo de evolución de la arquitectura: visión, arquitecturas BDAT, oportunidades, migración, gobierno de la implementación y gestión del cambio | Hemisferio Change (`plateaus`, `transitions`); la Fase H se alimenta de los `findings` de Run |
| **Gobierno** | Principios, cumplimiento, dispensas, decisiones y building blocks | `decisions`, `readiness_gates`; principios, dispensas y building blocks aún sin tabla canónica |

La estructura BDAT y qué la puebla:

| Dominio TOGAF | Lo puebla | Tablas canónicas hoy | Brecha |
|--------------|-----------|---------------------|--------|
| **B: Negocio** | ETB, vía el Industry SME | `products` · `kpis` · `capabilities` · `processes` · `regulatory_obligations` · `stakeholders` · `vocabulary` | Objetivos y drivers, servicios de negocio, value streams, ubicaciones |
| **D: Datos** | Evidencia de TI en Run, operada según ITOM | `data_entities` · `component_data` | Componentes lógicos de datos y linaje |
| **A: Aplicación** | Evidencia de TI en Run y portafolio de Change | `components` · `component_calls` · `applications` · `external_systems` · `cross_dependencies` | Servicios de aplicación (APIs como servicio expuesto) |
| **T: Tecnología** | Evidencia de TI en Run, operada según ITOM | `technology_components` | Servicios de plataforma y matriz aplicación-tecnología |

`itom_layer` no es el dominio T. Describe cómo la organización de TI planea, entrega y opera los dominios D, A y T: es la cara operativa de TI dentro de la estructura que da TOGAF.

Vocabulario: `togaf_state` (baseline, transitional, target) sí es TOGAF y mapea a `plateaus.kind` (as_is, transition, to_be). En cambio, los valores de `togaf_type` (core, processors, channels, data, integration, compliance) son una taxonomía propia del canon (ADR-SPE-AM-008), no términos del metamodelo de TOGAF, y se documentan como tal. Lo mismo aplica a Pace Layers, que viene de Gartner.

**B36 — Los frameworks son complementarios: el negocio da el north star, TI lo habilita y TOGAF lo gobierna**: ETB, ITOM y TOGAF no se eligen entre sí ni se superponen. Cada uno responde una pregunta distinta, y juntos forman un círculo virtuoso:

```
                 TOGAF: gobierno y estructura de la arquitectura
     ┌──────────────────────────────────────────────────────────────┐
     │                                                              │
     │    ETB (negocio)  ── da el north star ──▶  ITOM (TI)         │
     │         ▲                                      │             │
     │         └────────── habilita al negocio ───────┘             │
     │                                                              │
     └──────────────────────────────────────────────────────────────┘
```

| Framework | Rol en el círculo | Pregunta que responde | Dónde vive en el brain |
|-----------|------------------|----------------------|-----------------------|
| **ETB** | Negocio. Da el north star | ¿Qué productos, capabilities, procesos y KPIs persigue la empresa? | `products` · `kpis` · `capabilities` · `processes` |
| **ITOM** | TI. Habilita al negocio | ¿Cómo planea, construye y opera TI la tecnología que hace posible ese norte? | `itom_layer` |
| **TOGAF** | Gobierno. Da la estructura | ¿Dónde vive cada pieza, cómo se decide y cómo evoluciona la arquitectura? | Dominios BDAT, ADM, `decisions`, `readiness_gates`, `plateaus`, `transitions` |

Reglas de uso:

- **Ningún framework se usa para lo que no es.** ITOM no modela la infraestructura (eso es el dominio T de TOGAF). TOGAF no define las capabilities de una industria (eso es ETB). ETB no define cómo opera TI (eso es ITOM).
- **ITIL vive dentro de ITOM, como su capa de prácticas.** No es un cuarto framework al mismo nivel. ITOM define el modelo operativo de TI (dominios, roles y madurez) e ITIL 4 aporta las prácticas con que se opera el servicio: gestión de incidentes y problemas (`findings`), gestión de niveles de servicio (`slos`) y habilitación del cambio y liberaciones (`readiness_gates`). Pesa sobre todo en Run y también aparece en Change con las liberaciones.
- **El círculo se cierra con trazabilidad en ambos sentidos.** Lo que TI mide tiene que trazarse a lo que el negocio persigue: cada capacidad ITOM declara el proceso de negocio que soporta (`itom_layer.process_id`) y cada SLO declara el KPI de negocio que habilita (`slos.kpi_id`). Lo que el negocio persigue tiene que tener un habilitador de TI: una capability sin componente ni capacidad ITOM que la soporte es un north star sin motor; una capacidad de TI sin capability de negocio es un motor sin dirección. Las dos son hallazgos.
- **Los dos hemisferios hacen girar el círculo** (Regla B34). Change lo gira hacia adelante: el negocio redefine su norte y TI se transforma para habilitarlo. Run lo mantiene girando y lo mejora: TI opera, mide y devuelve aprendizaje que recalibra el norte.
- **TOGAF envuelve, no compite.** Cuando el brain clasifica, gobierna o hace evolucionar la arquitectura, usa la estructura y el vocabulario de TOGAF. Cuando describe el negocio, usa ETB. Cuando describe la operación de TI, usa ITOM.

**B37 — El brain gestiona la calidad y el linaje de su conocimiento**: no todo lo que el brain sabe pesa lo mismo. Cada afirmación declara su nivel de certeza y de dónde viene. Hay conocimiento duro, irrefutable y comprobable, y hay conocimiento que todavía puede cambiar o que nadie ha validado. Mezclarlos sin marcarlos es la forma más rápida de que el brain deje de ser espejo de la empresa (B25).

| Nivel | Qué es | Run the Business | Change the Business |
|-------|--------|------------------|---------------------|
| **Gold** | Hecho irrefutable y comprobable. Cualquiera que vuelva a la fuente llega a lo mismo | Lógica de negocio en el código productivo; logs; monitoreo; ejecuciones de jobs | Regulación publicada; reglas de negocio firmadas; objetivos estratégicos aprobados; ADRs aprobados |
| **Silver** | Tiene fuente identificada, pero todavía puede cambiar o falta confirmarlo | Hipótesis de incidentes y RCA en curso; interpretaciones del código aún sin validar; enlaces inferidos | Estatus de proyecto; diseños funcionales en ejecución; planes, estimaciones y riesgos abiertos |
| **Bronze** | Volumen sin validar, pendiente del humano en el loop (HITL) | Tickets sin clasificar; exportaciones masivas; seeds de otro brain | Minutas; documentos crudos; extracciones masivas de backlog |
| **Rejected** | Lo que el HITL descartó. No se borra: se conserva para auditoría y para que nadie lo vuelva a proponer | | |

**Los hechos irrefutables entran directo a gold.** Una regulación publicada no es debatible, y un log tampoco: representa la realidad que gobierna al negocio. Por eso hay seis fuentes que entran a gold por origen, sin pasar por silver ni esperar validación humana: código productivo (`code`), logs (`log`), monitoreo (`monitoring`), ejecuciones de jobs (`job_run`), regulación publicada (`regulation`) y artefactos firmados o aprobados (`signed_artifact`). En este último caso la aprobación humana ya ocurrió: la firma es el acto de gobierno.

**El hecho es gold; su interpretación tiene su propio nivel.** El texto de una circular es gold, pero la afirmación de que obliga a tal proceso es una interpretación. Lo mismo con un SP: su código es gold, el `business_name` que un LLM sintetizó leyéndolo es silver hasta que el SME lo valide. Por eso el nivel se registra por afirmación, incluso por campo, y no por archivo ni por fuente.

**Ciclo de vida**:

| Movimiento | Cuándo ocurre | Quién lo ejecuta |
|-----------|--------------|-----------------|
| Entrada directa a gold | La fuente es un hecho irrefutable | El DT que extrae, con referencia exacta (archivo y línea, id de log, instrumento y artículo) |
| De bronze a silver | Un DT lo estructura, lo ancla a la ontología (cadena B27, dominio TOGAF) e identifica su fuente | El enjambre de DTs (B29) |
| De silver a gold | Un rol con autoridad sobre ese dominio lo confirma | HITL, registrado con nombre de rol, fecha y evidencia |
| Degradación de gold a silver | La fuente cambió: nuevo deploy, nueva versión del log, regulación reformada | Automática, comparando `source_version` |
| Reemplazo | Un objetivo cambia o una regulación se deroga | Se registra `superseded_by`; nada se borra |
| Rechazo | El HITL lo descarta | HITL |

**Conflictos.** Gold le gana a silver, siempre. Gold contra gold nunca se resuelve en automático: es un hallazgo. Si el código (Run) contradice a la regla firmada (Change), no es un error de datos sino una ruptura real entre lo que la empresa es y lo que decidió ser, y se trata como tal en el puente (B24).

**Nivel mínimo por decisión.** El brain no sostiene una decisión de gate sobre conocimiento que puede cambiar:

| Decisión | Nivel mínimo |
|----------|-------------|
| Decommission (B7), cutover o cierre de una transición (B32), gate de readiness en `done`, afirmación de cumplimiento regulatorio | Gold |
| Planeación, priorización, estimación, hipótesis de impacto | Silver, declarado como tal |
| Cualquier salida al cliente | Nunca bronze, salvo marcado como "por validar" |

**Cómo se implementa**:

- Toda tabla de conocimiento lleva `tier` (por defecto `bronze`: nada se presume cierto). `knowledge_lineage` (CORE) guarda por cada afirmación su nivel, la base del nivel (`origin`, `validated`, `sourced`, `ingested`, `demoted`, `rejected`), el tipo y la ubicación de la fuente, su versión, quién la afirmó, quién la validó y qué la reemplazó. Generaliza `rule_enrichment_log` de Informix.
- `build-brain.py` impide en construcción que una fuente no irrefutable entre directo a gold, y que un gold por validación no diga quién validó.
- `brain.py` acepta `min_tier` en `value_chain()`, devuelve un resumen de niveles con cada respuesta (B35), expone `lineage()` y prioriza `hitl_queue()` por la cadena de valor: primero se valida lo que toca productos, KPIs y decisiones de gate.
- La dimensión D9 del DT-Validador mide la distribución de niveles y bloquea gold sin fuente, saltos indebidos a gold, gold por validación sin validador y decisiones de gate sobre silver.
- Homologación por vista (B16): la columna `confidence` que ya existe en el estate se mapea a un nivel inicial (`confirmed` con fuente primaria a gold; `inferred` a silver; `suspected` a bronze) sin tocar los pipelines.

**B38 — El brain es una capa agéntica que escala la IA en Run y Change, sin sustituir a las herramientas dedicadas**: el brain no es un repositorio que se consulta de vez en cuando. Forma parte de la operación y de la transformación: es la capa sobre la que corren los casos de uso de IA de ambos hemisferios. Así es como cumple la segunda mitad de su definición, *anticipa y aconseja*: no con un módulo aparte, sino a través de cada caso de uso que razona con su conocimiento.

Su función es que pasar de un caso de uso a cien no cueste cien veces más. Cada caso nuevo reutiliza la misma ontología (B21, B36), la misma cadena de valor (B27) y el mismo linaje (B37), en lugar de reconstruir el contexto desde cero. Eso es escalar la IA.

| Hemisferio | Casos de uso (ejemplos, pueden ser cientos) | Qué aporta el brain |
|-----------|---------------------------------------------|--------------------|
| **Run** | Acelerar la documentación de RCA; generar y mantener runbooks; correlacionar señales de observabilidad con componentes, procesos y KPIs; detectar desviaciones entre la CMDB y lo observado | El sistema tal como opera: código, call graph, datos, hallazgos, y la cadena hasta el KPI afectado |
| **Change** | Escribir definiciones funcionales; generar código; identificar casos de prueba desde DISCOVER; analizar el impacto de un cambio | Reglas de negocio, procesos, regulación, dependencias y decisiones, con su nivel de certeza |

**El mapa de los casos de uso es el IT Operating Model.** Es una de las razones por las que ITOM está en el CORE (B23): el brain participa como capa agéntica en las capacidades de TI, cada capacidad de TI existe para habilitar al negocio y la IA tiene que ser parte de ese objetivo. Por eso cada caso de uso se ancla a una sub-capacidad ITOM, y no a una lista suelta de ideas:

| Dominio ITOM | Hemisferio predominante | Casos de uso de IA sobre el brain (ejemplos) | Cómo habilita al negocio |
|-------------|------------------------|---------------------------------------------|-------------------------|
| **Customer and Ecosystem Engagement** | Ambos | Traducir la demanda del negocio a requerimientos con su impacto en KPIs; evaluar a proveedores contra sus SLOs | TI entiende y prioriza lo que el negocio necesita |
| **IT Strategy** | Change | Racionalizar el portafolio de aplicaciones (7R) con la cadena de valor; gap analysis de arquitectura en los dominios BDAT; roadmap de transformación | La inversión de TI va a donde mueve los KPIs |
| **Product / Service Delivery** | Change | Definiciones funcionales; generación de código; casos de prueba desde DISCOVER; análisis de impacto; readiness de liberación | Las capacidades nuevas llegan antes y con menos riesgo |
| **Technology Operations** | Run | RCA; runbooks; correlación de observabilidad; desviaciones entre la CMDB y lo observado; pronóstico de capacidad | El servicio se sostiene y mejora continuamente |
| **Information and Analytics** | Ambos | Linaje y calidad de datos; matriz CRUD; glosario de negocio | El negocio decide con datos confiables |
| **IT Management** | Ambos | Costo de TI por producto y KPI (FinOps); cumplimiento regulatorio trazado hasta el código; mapas de conocimiento para onboarding; riesgos | TI opera de forma eficiente, segura y conforme |

La trazabilidad completa de un caso de uso es la del círculo virtuoso (B36): el caso de uso potencia una capacidad ITOM, la capacidad soporta un proceso de negocio (`itom_layer.process_id`) y el proceso mueve un KPI. Un caso de uso que no se puede anclar así es IA sin propósito: puede ser técnicamente brillante, pero no habilita nada.

La participación de la IA se vuelve también una medida de madurez del IT Operating Model. Cuántos casos de uso potencian cada capacidad, con qué nivel de validación y qué KPI movieron dice cuánto de esa capacidad ya está aumentada por IA. Es la huella agéntica del brain sobre TI.

**Anatomía de un caso de uso.** Todo caso de uso declara:
- la sub-capacidad ITOM que potencia (en `itom_layer`) y su hemisferio; en Change, también la fase ADM;
- el DT que lo ejecuta (B29);
- el eslabón de la cadena de valor que lo ancla (B27);
- el contexto que consume del brain y de las herramientas;
- el artefacto que produce y la herramienta que lo recibe;
- el nivel con que sale ese artefacto (B37), normalmente silver;
- el rol que lo valida;
- el KPI que mueve, porque un caso de uso que no se mide no escala.

**El brain razona; las herramientas dedicadas registran y ejecutan.** El brain no sustituye a la CMDB, a la herramienta de pruebas ni a la plataforma de observabilidad. Se alimenta de ellas, las conecta con el negocio y les devuelve lo que descubre. La relación es un ciclo, no una extracción:

| Herramienta dedicada | Es sistema de registro de | Qué hace el brain con ella |
|---------------------|--------------------------|---------------------------|
| CMDB (por ejemplo ServiceNow) | Configuration items y sus relaciones | Se alimenta de ella y la correlaciona con la ontología; detecta desviaciones contra lo observado y se las devuelve como hallazgo para corregir. No se vuelve una segunda CMDB |
| Automatización de pruebas (por ejemplo Tricentis Tosca) | Casos de prueba y su ejecución | Identifica y redacta casos de prueba desde reglas y procesos; los entrega a la herramienta y lee sus resultados |
| Observabilidad (por ejemplo Dynatrace, Datadog) | Métricas, trazas y eventos | Correlaciona las señales con componentes, procesos y KPIs |
| ITSM | Incidentes, problemas y cambios | Redacta RCA y runbooks y los registra en el ITSM |
| Repositorio de código y CI/CD | Código y despliegues | Lee el código productivo como gold; propone código nuevo como pull request |
| Backlog (por ejemplo Jira, Azure DevOps) | Historias y su estatus | Redacta historias y criterios de aceptación; lee el estatus como silver |
| Scheduler (por ejemplo Control-M) | Jobs y sus ejecuciones | Lee las ejecuciones como gold |

Seis reglas de la frontera:

- **Una sola verdad por dato.** El brain no copia el registro de la herramienta: guarda su referencia (el id del registro en `knowledge_lineage.source_ref`) y solo lo que necesita para razonar. Duplicar crea dos verdades que tarde o temprano divergen.
- **Lo que entra de una herramienta lleva el nivel que su naturaleza sostiene** (B37). Lo observado es gold: monitoreo, logs, discovery automático, ejecuciones. Lo capturado a mano es silver: un CI dado de alta manualmente o el estatus de un ticket.
- **Lo que el brain produce sale como silver** hacia la herramienta. Sube a gold cuando el rol responsable lo valida o cuando la herramienta lo confirma: las pruebas pasan, el pull request se aprueba, el RCA se cierra.
- **Un desacuerdo entre la herramienta y la realidad observada es un hallazgo.** Si la CMDB dice una cosa y el monitoreo otra, el brain no elige: lo registra. Es uno de los casos de uso de más valor, porque es el brain cumpliendo su papel de espejo (B25).
- **Los hallazgos retroalimentan a la herramienta.** Un hallazgo que corrige el registro de una herramienta se rutea a ella (`findings.routed_to_tool`), igual que un hallazgo de Run se rutea a un brain de proyecto (B24). La corrección la hace el dueño de la herramienta, en la herramienta: el brain propone, no **modifica** el registro ajeno.

  **La frontera es entre crear y modificar, no entre leer y escribir.** Sin esa precisión la regla se vuelve incumplible, porque abrir un ticket también es escribir. Lo que el brain no hace es alterar el dato que la herramienta custodia como verdad: corregir un CI, reclasificar una entidad, cambiar el estatus de un registro ajeno. Lo que sí puede hacer, cuando está preautorizado (B39), es **crear un registro nuevo por la vía de entrada que la herramienta ofrece**: levantar un ticket, dar de alta un caso de prueba, abrir una historia. Crear por la puerta de entrada respeta a la herramienta como sistema de registro; modificar su contenido la sustituye. Cuando el brain vuelve a leer la herramienta y el desacuerdo desapareció, el hallazgo se cierra. Así la CMDB mejora con cada ciclo, en vez de que el brain se convierta en su copia corregida.
- **El valor del brain está en lo que las herramientas no conectan.** La CMDB no conoce el proceso de negocio, la observabilidad no conoce la regulación y la herramienta de pruebas no conoce el KPI. El brain sí, y por eso cada herramienta rinde más con él que sin él.

**B29 — Los Digital Twins construyen y mantienen el brain**: el brain no se escribe a mano ni se construye en un taller de documentación. Lo construyen los Digital Twins (DTs) — agentes especializados que trabajan en enjambre, como abejas construyendo el panal. Cada DT lee una parte del conocimiento (código, documentación, señales operativas, regulación, conversaciones con stakeholders) y lo organiza, mapea y correlaciona con base en la ontología del negocio y la tecnología.

El patrón de enjambre tiene tres principios:

| Principio | Descripción |
|-----------|-------------|
| **Especialización** | Cada DT tiene un dominio propio: uno extrae del código, otro infiere semántica, otro valida regulación y otro razona entre sistemas. Ningún DT hace todo; el enjambre hace todo.

> **Nota de vocabulario.** Esta regla llamaba "Capa 1" a "Capa 4" a esas cuatro especialidades, lo que chocaba de frente con la metodología canónica del asset, donde Capa 1 es Lenguaje, Capa 2 son Almas, Capa 3 es Biografía y Capa 4 es Intención (`knowledge-base/methodology/`). Eran dos taxonomías distintas de cuatro elementos con los mismos nombres, en el mismo asset. **La numeración por capas pertenece a la metodología**; las especialidades del enjambre se nombran por lo que hacen, no por un número. |
| **Correlación ontológica** | El DT no acumula datos — los *correlaciona*. Cada hallazgo se ancla en la cadena B27 (producto → KPI → proceso → componente) y se clasifica con el vocabulario TOGAF (B28). Un hecho sin ancla ontológica no entra al brain. |
| **Push, no pull** | El DT emite lo que aprendió (seeds, señales, hallazgos) hacia los brains vecinos sin esperar a que se lo pidan (Regla B11). El conocimiento fluye hacia donde se necesita. |

La consecuencia directa es que el brain refleja el estado del conocimiento *del enjambre de DTs*, no de ningún humano individual. El humano define qué preguntar y valida los hallazgos. Los DTs construyen y mantienen el panal.

**B30 — El business_name es el contrato de calidad de cada pieza de conocimiento** (ADR-EB-004): el extractor emite `business_name = ""`. El nombre se infiere leyendo el código fuente completo del SP — nunca se transcribe la fórmula ni se copia el identificador. Un `business_name` defectuoso es peor que uno vacío: miente sobre lo que el componente hace y envenena los análisis de impacto.

El DT-Validador (D3) rechaza como bloqueante:

| Tipo de defecto | Señal | Ejemplo |
|----------------|-------|---------|
| **Vacío** | `IS NULL OR = ''` | — |
| **Genérico** | Verbos sin objeto o nombre de tabla | "Calcular valor" · "Procesar datos" · "Ejecutar procedimiento" |
| **Token de código** | Identificadores del SP, prefijos húngaros, SQL embebido | "vsql" · "cCmd" · "bdiburo" · "sp_" · "IF ..." |
| **Plantilla sin completar** | Literales del template | "Fórmula de [X]" · "REEMPLAZAR" |
| **Error factual por fragmento truncado** | Nombre incorrecto porque el extractor vio solo parte del SP | El SP hace pagos pero el nombre dice "valida saldo" |

La regla es universal: aplica a `rules`, a `vocabulary.term` y a `capabilities.name`. El mismo estándar de calidad semántica rige en todos.

**B31 — El brain declara su corpus fuente**: `system_info.source_of_truth` es obligatorio para brains en estado `building` o superior. Declara la ruta del corpus desde el que se construyó el brain (por ejemplo: `"source/docs"` o `"source/code/sps"`). Un brain sin `source_of_truth` declarado no puede ser auditado — nadie puede verificar de dónde vino el conocimiento ni actualizarlo cuando el corpus cambia.

El DT-Validador (D1) reporta como advertencia no bloqueante si el campo está vacío, y como bloqueante si el brain está en estado `active` sin declararlo.

**B32 — Una transición sin `run_owner` no puede cerrar**: cualquier transición cuyo `status` avance a `cutover` o `done` requiere `run_owner` declarado. El campo responde la pregunta *¿quién en Run hereda la responsabilidad operativa de lo que Change entregó?* Sin ese dato, Run no sabe que tiene algo nuevo bajo su responsabilidad. No es un campo opcional — es el mecanismo que cierra el loop del puente Change-Run (Regla B24).

El DT-Validador D8 reporta como bloqueante toda transición en `cutover`/`done` con `run_owner` vacío. La transición permanece en `in_progress` hasta que el dueño en Run esté identificado y aceptado. Si el sistema de destino no tiene aún un owner operativo, eso es un `knowledge_gap` (B17), no una razón para omitir el campo.

**B34 — Ambos hemisferios son transformacionales, impulsados por IA**: el Enterprise Brain no es un sistema de registro — es un agente de transformación continua. Los dos hemisferios tienen misión propia:

| Hemisferio | Misión transformacional | IA que lo impulsa |
|-----------|------------------------|------------------|
| **Run the Business** | Transforma la manera de operar — eleva las operaciones actuales a las mejores prácticas, reduce deuda técnica, predice incidentes antes de que ocurran, automatiza lo repetible | AIOps · SRE inteligente · observabilidad predictiva · automatización de runbooks |
| **Change the Business** | Evoluciona la empresa hacia sus mejores capacidades — prioriza qué cambiar, en qué orden y con qué impacto, alineando cada decisión a los KPIs del negocio | GenAI para arquitectura · análisis de impacto asistido · priorización de backlog por valor |

El brain no separa "operar" de "transformar" — en el contexto de IA, la operación *es* transformación continua. Cada señal de Run informa a Change; cada decisión de Change redefine el estándar de operación en Run. La frontera no es una barrera sino un flujo.

Consecuencia para el pipeline: el brain emite señales de mejora operativa hacia los SMEs de AMS Reinvention (Offering 07) y recibe prioridades estratégicas desde TS&T (Offering 01). El enterprise brain es el conector entre ambos extremos del SDLC.

**B35 — El brain evalúa el resultado esperado antes de responder**: en cada consulta, el brain no devuelve lo que puede — devuelve lo que se necesita. Para eso, evalúa primero qué tipo de resultado se espera y detecta qué información falta en la cadena de valor (B27) para construirlo.

El mecanismo opera en tres pasos:

| Paso | Qué hace el brain | Ejemplo |
|------|-------------------|---------|
| **1 Clasifica la consulta** | Identifica qué eslabón de la cadena B27 ancla la pregunta (Producto · KPI · Proceso · Componente · Infraestructura · Dato) | "¿Qué impacto tiene cambiar este SP?" → ancla en Componente |
| **2 Traza la cadena** | Sube y baja la cadena para encontrar los eslabones necesarios para el resultado | Componente → Proceso → KPI → Producto → impacto en negocio |
| **3 Solicita lo que falta** | Si algún eslabón tiene `process_id IS NULL`, o el producto no está declarado, o el KPI no tiene target, el brain lo declara como `knowledge_gap` y solicita la información concreta al SME responsable, sin inventar | "El SP X no tiene proceso_id — no puedo calcular el impacto en KPIs. ¿A qué proceso pertenece?" |

La ontología (B21, B27, B28) es el mapa que define qué información es necesaria para qué tipo de resultado. Sin ontología, el brain no sabe qué le falta — acumula datos sin poder razonar sobre ellos. Con ontología, el brain sabe exactamente qué pregunta hacer y a quién.

Esta regla cierra el loop de honestidad iniciado en B17 (ningún hueco muerto) y B30 (business_name como contrato de calidad): el brain no solo registra lo que falta — lo gestiona activamente para poder responder la pregunta que se le hace.

**B33 — El enterprise brain expone la cadena de valor federada**: el brain de nivel `enterprise` implementa `value_chain()` federada: dado un `product_id`, cruza vía ATTACH todos los brains de los dos hemisferios y devuelve la cadena completa — KPIs de Change + mediciones actuales de Run, procesos, aplicaciones en migración y sistemas en producción que los realizan, infraestructura que los sostiene. Ningún brain individual puede responder esta pregunta solo; solo el enterprise brain tiene la vista completa.

Sin `value_chain()` federada, el enterprise brain sabe qué sistemas existen y qué brecha hay, pero no puede responder la pregunta de negocio más importante: *¿qué producto se ve afectado y cómo se mide el impacto en KPIs?*

**B39 — Del consejo a la acción: niveles de autonomía del brain**: el brain puede observar, proponer y, en casos preautorizados, ejecutar. Para las acciones rige el mismo principio que B37 aplica al conocimiento: el nivel no lo decide la intención sino la naturaleza de la acción y la certeza con que se sustenta. La escala usa el vocabulario de *change enablement* de ITIL 4 (dentro de ITOM, B36) — el brain no inventa su propio gobierno de acciones sino que usa el que TI ya entiende.

| Nivel | Nombre | Qué hace el brain | ¿Requiere humano? |
|-------|--------|-------------------|------------------|
| **A0** | Observar | Lee, correlaciona, explica. No cambia nada fuera de sí mismo | No |
| **A1** | Proponer | Genera un artefacto en estado silver (B37) y lo entrega a la herramienta o al humano. El receptor decide si lo adopta | No para crearlo; sí para adoptarlo |
| **A2** | Ejecutar (preautorizado) | Dispara una acción de un catálogo aprobado previamente por un rol con autoridad | No en cada ejecución: la aprobación está en el catálogo |
| **A3** | Ejecutar con aprobación | Prepara la acción y espera la aprobación explícita del rol accountable antes de disparar | Sí, siempre |

Cuatro reglas del nivel:

- **A2 y A3 exigen knowledge gold (B37).** Si el conocimiento que sustenta la acción es silver o bronze, el nivel máximo posible es A1. El brain propone; el humano decide bajo incertidumbre.
- **Toda acción tiene un dueño humano.** El brain no es el responsable final de ninguna acción. Cada tipo de acción declara su rol accountable en `stakeholders` (CORE). El brain sugiere; el dueño responde.
- **La autonomía se gana con historial y se pierde con incidentes.** Un tipo de acción que acumula ejecuciones A3 sin incidentes puede catalogarse como A2. Si una acción autónoma causa un incidente, ese tipo regresa a A3 de inmediato — automáticamente, sin debate.
- **Toda acción deja linaje.** Qué se hizo, con qué nivel de autonomía, sobre qué conocimiento, quién aprobó y cuál fue el resultado. Es el equivalente de `knowledge_lineage` (B37) para acciones: la auditoría que permite ganar o perder autonomía con evidencia.

Cuatro tipos de acción que **nunca bajan de A3**, independientemente del historial, porque su impacto es irreversible o tiene consecuencias regulatorias directas: cambio en producción, decommission de un sistema, cambio de configuración de seguridad e impacto financiero directo al cliente.

**Qué puede ejecutar A2 sin contradecir a B38.** B38 prohíbe que el brain modifique el registro que otra herramienta custodia como verdad. A2 no lo contradice porque opera del otro lado de esa frontera:

| El brain puede, en A2 | El brain no puede, en ningún nivel |
|----------------------|-----------------------------------|
| **Crear** un registro nuevo por la vía de entrada de la herramienta: levantar un ticket, dar de alta un caso de prueba, abrir una historia | **Modificar** un registro existente del que la herramienta es sistema de registro: corregir un CI, reclasificar una entidad, cambiar el estatus de algo ajeno |
| Adjuntar su hallazgo al registro, como evidencia | Sustituir el dato de la herramienta por el suyo |

Cuando el brain detecta que el registro ajeno está mal, su salida es un hallazgo ruteado (`findings.routed_to_tool`), nunca una corrección directa. El dueño de la herramienta corrige; el brain vuelve a leer y cierra el hallazgo si el desacuerdo desapareció.

Tabla de referencia por dominio ITOM (B23):

| Dominio ITOM | A1 — Propone (silver) | A2 — Ejecuta (preautorizado) | A3 — Ejecuta (con aprobación) |
|---|---|---|---|
| **Technology Operations** | RCA; runbook de diagnóstico | Abrir ticket en ITSM con campos preestablecidos | Ejecutar runbook de remediación en producción |
| **Product / Service Delivery** | Código como pull request; casos de prueba | Dar de alta casos nuevos en la herramienta de automatización | Merge a producción; release a producción |
| **Information and Analytics** | Reporte de calidad de datos; glosario enriquecido | Adjuntar el hallazgo de calidad al registro del catálogo | Enriquecer o reclasificar el registro del catálogo |
| **IT Management** | Reporte de brecha regulatoria | Notificar a risk owner por canal configurado | Escalar hallazgo con consecuencia regulatoria |

**B40 — El brain es bi-temporal: el tiempo del negocio y el tiempo del brain son relojes distintos**: toda afirmación del brain tiene dos fechas que nunca deben confundirse. Una dice cuándo algo fue verdad en la empresa; la otra, cuándo el brain lo supo. Mezclarlas vuelve al brain incapaz de razonar sobre el pasado y le hace creer que todo lo que sabe es vigente.

| Reloj | Campos | Qué mide | Quién lo pone |
|-------|--------|----------|---------------|
| **Tiempo del negocio** | `valid_from` · `valid_to` | Cuándo la afirmación fue verdad en la empresa | El DT, tomándolo de la fuente: fecha del commit, de la circular, del incidente, del cutover |
| **Tiempo del brain** | `recorded_at` | Cuándo el brain registró la afirmación | Automático en la carga — nunca se edita a mano |

Ambos relojes viven en `knowledge_lineage` (B37), junto a `tier` y `superseded_by`. Que el brain conozca tarde la realidad del negocio no es un defecto a esconder: es un hecho que el brain registra con honestidad (B25).

Tres reglas de tiempo:

- **`valid_to IS NULL` significa que sigue siendo verdad hoy.** Un hecho no se borra cuando expira: se le pone `valid_to`. Nada se borra nunca — lo corregido lleva `superseded_by` y lo descartado va a `rejected` (B37), pero el registro histórico persiste para poder reconstruir el pasado.
- **Sin `valid_from`, la afirmación se interpreta como verdad desde el origen del sistema.** Para todo conocimiento que el brain necesite razonar en el tiempo — reglas de negocio, obligaciones regulatorias, decisiones de arquitectura, transiciones, hallazgos — `valid_from` es obligatorio y se toma de la fuente, no de la fecha de carga.
- **Un gate de decommission (B7) o de cutover (B32) exige que no queden afirmaciones gold activas del sistema retirado.** Si el brain todavía sostiene como hecho irrefutable algo con `valid_to IS NULL` de un sistema que se apaga, el gate no cierra: el brain está afirmando como vigente algo que dejó de existir.

**`snapshot(date)` es el método que materializa el reloj del negocio.** Devuelve el estado del conocimiento tal como fue verdad en esa fecha, filtrando `valid_from <= date AND (valid_to IS NULL OR valid_to >= date)`. Sin él el brain solo responde sobre el presente: no puede reconstruir cómo estaba la arquitectura antes de una ola de migración, ni verificar qué regulación estaba vigente cuando ocurrió un incidente, ni mostrar la evolución de un KPI contra las decisiones que lo movieron.

**La brecha entre relojes es un hallazgo medible.** Si el brain supo en mayo que algo dejó de ser verdad en marzo, hubo dos meses en los que el brain afirmaba algo falso. La diferencia entre `valid_from` o `valid_to` y `recorded_at` mide la latencia real del brain frente a su empresa — es la métrica honesta de su frescura, más exacta que `brain_freshness_days`, que solo mira la fecha del último build. Una latencia creciente en un dominio es señal de que el enjambre de DTs (B29) perdió cobertura ahí.

**Relación con el estudio histórico (B26).** El estudio histórico es el reloj del negocio aplicado al pasado profundo: explica por qué una regla nació cuando nació. B40 es el mecanismo que permite que esa historia siga viva en el brain en lugar de quedarse en un documento aparte.

**B41 — Todo brain implementa los 20 DTs canónicos, en tres categorías**: B29 establece que los Digital Twins construyen el brain en enjambre, pero no dice cuáles deben existir siempre. Sin un roster fijo, cada brain inventa su propio conjunto y nadie responde por lo que ninguno reclamó. La evidencia lo confirma: en los 16 brains del estate hay 124 DTs, de los cuales unos 115 son dimensiones de análisis y solo dos tipos encarnan un rol de TI. No existía ni un `dt-arquitecto` ni un `dt-change-manager` en ningún brain.

Los 20 DTs canónicos se dividen en tres categorías con **sistemas de coordenadas distintos**. Confundirlas es lo que deja huecos estructurales: diez agentes pueden cubrir el modelo operativo completo de TI y nadie responder por la reproducibilidad del pipeline ni por el modelo de negocio contra el que se compara la evidencia.

| Categoría | Razona sobre | Se mide contra | DTs |
|-----------|-------------|----------------|-----|
| **A. Rol de TI** | La organización de TI del cliente | Los 38 procesos del IT Operating Model (B23) | 10 |
| **B. Ingeniería del brain** | El brain como producto | El Brain Lifecycle y las reglas P1 a P5 | 4 |
| **C. Negocio** | El modelo de negocio del cliente | Los 6 dominios L1 comunes a los catálogos de industria | 6 |

**Categoría A, los diez DTs de rol.** Cada uno encarna un rol del catálogo de 46 que prescribe el SME de IT Operating Model, y es dueño único de una porción del schema:

| DT | Rol ITOM que encarna | Procesos | Posee |
|----|---------------------|----------|-------|
| `dt-arquitectura` | Domain Architect, CAO, Lead-Architecture | 6, 7, 8, 10, 11 | `system_info`, `ontology_bindings`, `capabilities`, `itom_layer`, `decisions`, `plateaus` |
| `dt-informacion` | Information Architect | 33, 34 | `data_entities`, `component_data`, `vocabulary` |
| `dt-conocimiento` | Knowledge Manager | 35, 38 | `knowledge_lineage`, `knowledge_gaps`, `stakeholders`, la columna `tier` en toda tabla |
| `dt-configuracion` | Asset and Configuration Manager | 26, 28 | `components`, `component_calls`, `technology_components`, `cross_dependencies`, `external_systems` |
| `dt-cambio` | Change Manager, Service Readiness Manager | 2, 15, 16, 27 | `transitions`, `readiness_gates`, el `target` de `slos` |
| `dt-operacion` | Lead-SM&O, Incident y Problem Manager | 2, 19, 21, 22, 23, 24, 25, 29, 30 | `findings`, `signals`, el `current` de `slos` |
| `dt-riesgo` | IT Risk Manager, CISO, Business Continuity Manager | 20, 31, 32, 37 | `regulatory_obligations`, `risks` |
| `dt-valor` | Demand Manager, IT Finance Manager, UX Architect | 1, 3, 9, 12, 36 | `products`, `kpis`, `processes`, `journeys` |
| `dt-entrega` | Programme Manager, Project Manager, Resource Manager | 13, 14, 17 | `applications`, `waves`, `user_stories` |
| `dt-proveedores` | IT Sourcing Manager, Contracts Manager | 4, 5 | `suppliers` |

**Categoría B, los cuatro DTs de ingeniería.** No razonan sobre el cliente: construyen y cuidan el brain.

| DT | Rol que encarna | Cubre | Pregunta que responde |
|----|----------------|-------|----------------------|
| `dt-pipeline` | Data Engineer, DataOps | P1, P2, P3, B11, B12 | ¿Se puede reconstruir este brain desde cero y obtener el mismo resultado? |
| `dt-hitl` | Data Steward, orquestador de validación | B37 y B39 en su operación | ¿Quién debe validar o aprobar qué, desde cuándo y qué se decidió? |
| `dt-ingenieria` | Application Developer, Test Manager | P4, P5, B16, B1 | ¿El código que construye y consulta el brain está sano y consistente entre deployments? |
| `dt-validador` | Quality Manager | Proceso 18, las 9 dimensiones | ¿Este brain puede activarse? Reporta, no corrige |

**Categoría C, los seis DTs de negocio.** No existe un marco de capacidades de negocio agnóstico de industria publicado en el ecosistema: no hay APQC ni equivalente, y el único SME de negocio tipo Framework es metodológico y no ontológico. Por eso estos seis dominios **no se inventaron, se destilaron** de los cuatro catálogos de industria que sí existen (Banking ETB V5.0, el marco ACORD de seguros con su taxonomía L1 a L4, ETB P&C v3.0, ETB Health Payer v6.0 y la cadena de valor de retail). Cada uno aparece con etiqueta equivalente en todos ellos:

| DT | Dominio L1 | Banca | Seguros | Retail |
|----|-----------|-------|---------|--------|
| `dt-negocio-canales` | Canales e interacción | Channel Management | Distribución y Canales | SELL omnicanal |
| `dt-negocio-distribucion` | Distribución, marketing y ventas | Marketing & Sales | Distribución e intermediarios | PLAN y SELL |
| `dt-negocio-productos` | Producto y servicio | Product & Service | Producto y Actuaría | PLAN y BUY |
| `dt-negocio-clientes` | Gestión de cliente | Customer & Partner Mgmt | Gestión de Cliente | SERVICE y lealtad |
| `dt-negocio-operaciones` | Operaciones del core | Business Support | Pólizas, Cobranza, Siniestros | MOVE |
| `dt-negocio-funciones` | Funciones de empresa | Enterprise Functions | Finanzas y Regulatorio | Finanzas y personas |

"Enterprise Functions" aparece con etiqueta textual en tres de los cuatro catálogos, lo que lo vuelve el dominio con más respaldo. Quedaron fuera dos candidatos con evidencia de solo dos de cuatro: socios y ecosistema, que se absorbe en distribución porque en seguros el distribuidor es el socio y en retail el proveedor vive en BUY; y analítica de negocio, que en el lado de TI ya cubre `dt-informacion` con el proceso 34.

**El dominio es genérico; su contenido lo especializa cada industria.** El SME de Seguros lo enuncia con precisión: el modelo de capacidades es independiente del ramo, lo que cambia son los procesos y las reglas dentro de cada capacidad. Ningún DT de negocio inventa el catálogo de su industria: lo toma del Industry SME declarado en `system_info.industry_sme` (Regla B19).

**Propiedad vertical contra propiedad horizontal.** Las categorías A y B poseen **tablas**; la categoría C posee **dominios** dentro de esas tablas. `dt-negocio-clientes` no es dueño de la tabla `capabilities`: es dueño de las capabilities, los procesos, los productos y los KPIs que pertenecen al L1 de gestión de cliente. La intersección es una celda, no una tabla, y por eso las tres categorías conviven sin que ninguna tabla cambie de dueño.

**El modelo es de negocio, la evidencia es de TI, y la brecha es el hallazgo.** Esta es la razón de fondo para tener las dos caras y no solo una. La categoría C declara qué dice el modelo de la industria; la categoría A aporta lo que el código demuestra. Una capability que el ETB dice que debería existir y que ningún componente cubre es brecha de negocio. Un componente que no mapea a ninguna capability es deuda sin propósito. Un proceso modelado que el código ejecuta de otra forma es la divergencia más reveladora de cualquier modernización. Es la generalización de la Regla B20, que ya decía que la brecha entre `processes` y `journeys` es hallazgo de negocio y no error de datos.

**El humano en el loop tiene un operador, y sirve para dos cosas.** `dt-hitl` no se solapa con `dt-conocimiento`: el segundo define el modelo de calidad (qué nivel tiene cada afirmación y cuál es su linaje), el primero opera el flujo humano. Y ese flujo cubre dos objetos distintos que antes no tenían dueño: promover conocimiento de silver a gold (B37) y aprobar una acción de nivel A3 antes de ejecutarla (B39).

**Tres capas de propiedad, no una.** La propiedad única es sobre la estructura y la semántica, nunca sobre el contenido:

| Capa | Quién | De qué responde |
|------|-------|-----------------|
| Estructura | Los 10 DTs de categoría A | Las tablas del CORE y de extensión, su semántica y su anclaje a la cadena B27 |
| Extracción | Los DTs de dimensión propios de cada brain | El contenido de `rules`, `journeys`, `vocabulary`, almas |
| Calidad | `dt-conocimiento`, `dt-hitl` y `dt-validador` | El nivel, el linaje, la validación humana y la auditoría |

Por eso `rules` no tiene dueño en el roster y es correcto: la llena el DT de dimensión, la ancla `dt-valor`, responde por su nivel `dt-conocimiento`, consigue su validación `dt-hitl` y la audita `dt-validador`.

**Los DTs canónicos no sustituyen a los de dimensión.** Los 115 que ya existen en el estate siguen siendo los que extraen conocimiento del código y del negocio. Los canónicos organizan lo que esos extraen y responden por su calidad. Es la diferencia entre la abeja que trae el néctar y la que construye la celda (B29).

**La cobertura es artefacto verificable, no declaración.** `dt/cobertura-dt.md` mapea los 38 procesos, las 5 reglas de pipeline, las 8 fases del lifecycle y los 10 criterios de DoD contra su DT dueño. Un proceso sin dueño es hallazgo bloqueante; dos DTs reclamando lo mismo es solapamiento que se resuelve con ADR. Hoy la cobertura es 38 de 38, con el proceso 2 compartido por diseño entre `dt-cambio` y `dt-operacion` (B24 y B36).

**Un DT canónico en estado SCAFFOLD es válido y es invocable.** Declara su identidad, su propiedad y su cobertura, aunque no tenga implementación ni datos. Pasa a ACTIVE cuando posee al menos una tabla con contenido y su primer hallazgo con linaje. Una carpeta de DT sin `CLAUDE.md` no es un scaffold: es una carpeta, y no la puede invocar nadie ni verificar el validador. El estate tiene 36 de esas, todas en un mismo brain, y son deuda (B9).

Ver ADR-EB-011.

**B42 — Confidencialidad y fronteras del conocimiento: el acceso se autoriza por propósito, no solo por identidad**: un brain concentra lo que una empresa sabe de sí misma, y eso lo vuelve el activo más sensible del proyecto. Hasta B41 el canon gobernaba qué sabe el brain y con qué certeza, pero no quién puede preguntárselo ni para qué. Sin esa frontera, la federación que hace valioso al brain (B4) es también su mayor riesgo de fuga.

El acceso se gobierna en cuatro dimensiones, y la cuarta es la que resuelve los casos que las otras tres no alcanzan:

| Dimensión | Pregunta que responde | Ejemplo |
|-----------|----------------------|---------|
| **Política** | ¿Qué política gobierna esta pieza de conocimiento? | Las obligaciones regulatorias y su evidencia solo se exponen a roles con autoridad de cumplimiento |
| **Atributo** | ¿Qué atributos tiene quien pregunta? | Su rol en `stakeholders`, su organización y su relación contractual con el cliente |
| **Propósito** | ¿Para qué lo pide? | El mismo dato se autoriza para documentar una causa raíz y se niega para comparar desempeño entre proveedores |
| **Entitlement** | ¿Qué le corresponde de forma explícita? | Lista explícita por principal. Lo que no está permitido, está negado |

**Tres fronteras, con reglas distintas.**

La **frontera de cliente** es absoluta: el conocimiento de un cliente nunca cruza al brain de otro cliente. Los brains no se federan entre clientes, solo dentro de uno (B4). Lo único que sube es el aprendizaje hacia el Industry SME, y sube **como patrón, nunca como caso**. Que los cores bancarios sobre cierto motor concentren la lógica de autorización en procedimientos de más de quinientas líneas es un patrón legítimo de subir; el nombre del banco, el del procedimiento y la cifra exacta no suben. La anonimización no es opcional ni posterior: es la condición para que el patrón exista.

La **frontera de tercero** reconoce que en el ambiente de un cliente conviven proveedores que no son parte del cliente. Cuando un tercero es responsable de un frente y a la vez competidor en otro, el análisis propio no se comparte con él: las validaciones y los hallazgos van al cliente, y el cliente decide qué comparte. Esto no se resuelve con criterio del momento sino con lista explícita de qué ve cada tercero.

La **frontera interna** reconoce que dentro del mismo cliente no todos ven lo mismo. El `concern` de cada stakeholder determina qué le expone el brain, y esto no es solo control de acceso: es relevancia. Quien pregunta cambia la respuesta, porque la misma verdad se mira desde viewpoints distintos (B28).

**Cuatro reglas operativas.**

- **Negado por defecto en toda frontera.** Dentro de un brain el conocimiento fluye; al cruzar cualquiera de las tres fronteras, solo pasa lo explícitamente permitido.
- **El propósito se declara y se registra.** Toda consulta que cruza una frontera declara para qué, y eso queda en el linaje. Un propósito nuevo exige autorización nueva aunque el solicitante sea el mismo: la autorización es del par solicitante y propósito, no del solicitante.
- **La restricción se aplica al consultar, no al documentar.** Una política que vive en un documento y no en el filtro de `brain.py` no es una política: es una intención. El cumplimiento se verifica en tiempo de consulta.
- **No copiar reduce la exposición.** La regla de guardar la referencia y no el registro ajeno (B38) tiene aquí su segunda razón: lo que el brain no copió no lo puede filtrar.

**Clasificación de sensibilidad.** Toda entidad de datos declara su sensibilidad y si contiene datos personales. Lo clasifica `dt-informacion` con el criterio que fija `dt-riesgo`; sin clasificación, una entidad se trata como sensible, no como pública. Dueños: `dt-riesgo` define la política, `dt-informacion` clasifica el dato, `dt-hitl` opera las excepciones y `dt-validador` audita que la frontera se respete.

**B43 — El brain se mide a sí mismo, incluida la calidad de su consejo**: un brain que aconseja y nunca comprueba si su consejo sirvió es un oráculo que nadie audita. La definición canónica dice que el brain explica, anticipa y aconseja; esta regla cierra la última palabra de esa frase.

El brain se mide en cinco ejes:

| Eje | Qué responde | Cómo se mide |
|-----|-------------|--------------|
| **Uso** | ¿Alguien lo usa? | Consultas por período, DTs activos, casos de uso corriendo sobre él |
| **Costo** | ¿Cuánto cuesta sostenerlo? | Costo de construcción y de consulta, y costo por caso de uso habilitado |
| **Desempeño** | ¿Responde a tiempo? | Latencia P95 de consulta (SLO-EB-04) |
| **Frescura** | ¿Refleja la realidad de hoy? | La latencia bitemporal de B40, no la fecha del último build |
| **Trazabilidad de decisión** | ¿Se puede reconstruir qué sostuvo una decisión? | Porcentaje de decisiones con su evidencia trazable y su resultado registrado |

**La decisión es un objeto distinto del conocimiento y de la acción,** y hasta aquí no tenía linaje propio. B37 registra qué sabe el brain y con qué certeza. B39 registra qué hizo y con qué autonomía. Falta el eslabón del medio: qué se decidió, entre qué opciones, sobre qué conocimiento y con qué resultado. Una decisión no es una acción: decidir rehospedar una aplicación es la decisión, migrarla es la acción, y el mapa de sus dependencias es el conocimiento.

Toda decisión trazable registra cuatro cosas: las opciones que se consideraron y por qué se descartaron; el conocimiento que la sostuvo **con el nivel que tenía en ese momento**, porque por B40 ese nivel pudo cambiar después; el rol que decidió; y el resultado, cuando se conozca.

**El resultado es lo que convierte al brain en aprendiz.** Si el brain aconsejó algo y el KPI no se movió como se esperaba, eso no es un dato incómodo que se esconde: es su hallazgo más valioso, porque corrige su propio razonamiento. Un brain que solo acumula consejos sin verificar su acierto no mejora, y además pierde el derecho a que le crean. Por eso el acierto del consejo es métrica del brain y no del equipo que lo siguió.

**El brain es también un producto con KPIs.** La cadena de valor de B27 se aplica al propio brain: su producto es el razonamiento que entrega, sus KPIs son estos cinco ejes, y los procesos que lo mueven son las fases de su lifecycle. Un brain que no puede declarar su propio impacto está pidiendo inversión sin evidencia, que es justo lo que le reprocha a cualquier iniciativa que analiza.

Dueños: `dt-validador` mide los cinco ejes en OBSERVE, `dt-conocimiento` responde por la trazabilidad de decisión y `dt-valor` por el costo y el impacto en KPIs.

**B44 — El brain sobrevive al sistema que refleja, y se archiva con reglas propias**: el canon tenía regla de nacimiento (B12) y ninguna de muerte. Un brain cuyo sistema se apaga no desaparece con él, y confundir los dos eventos es el error que esta regla evita.

**Son dos eventos distintos, separados en el tiempo.** El sistema se apaga cuando pasa su gate de decommission (B7). El brain se archiva después, cuando ya nadie necesita interrogarlo sobre el presente. Entre uno y otro hay una ventana en la que el sistema ya no existe y el brain sigue siendo la única fuente que puede explicar cómo era.

**Por qué el brain sobrevive.** La Regla B40 permite reconstruir el estado del conocimiento en cualquier fecha pasada con `snapshot(date)`. Si el brain muere con el sistema, se pierde la capacidad de responder cómo estaba la arquitectura antes de la migración, qué regla gobernaba una operación que hoy se disputa, o qué obligación regulatoria aplicaba cuando ocurrió un incidente. En industria regulada esa capacidad tiene valor de retención, no solo histórico.

| Estado | Qué significa | Qué puede hacer |
|--------|--------------|-----------------|
| `active` | El sistema está vivo y el brain lo refleja | Todo |
| `stale` | El corpus cambió y el brain no se ha reconstruido (SLO-EB-01) | Responde, declarando su desfase |
| `archived` | El sistema se apagó y el brain cerró su ciclo | Solo lectura. Sigue sirviendo `snapshot(date)` sobre su periodo de vigencia |

**Cuatro cosas hay que resolver antes de archivar**, y ninguna se resuelve borrando:

| Qué queda abierto | Cómo se cierra |
|-------------------|----------------|
| Los `knowledge_gaps` sin resolver | Se transfieren al brain que hereda el dominio, o se cierran con `resolution_action` que declare por qué ya no son contestables. Nunca se borran (B17) |
| Las filas de `federated_brains` que lo apuntan | Cada vecino marca la federación como archivada. El `ATTACH` sigue siendo válido en modo lectura |
| Las `cross_dependencies` declaradas en ambos lados (B5) | El vecino cierra su lado con `valid_to`, no lo elimina: la dependencia existió y el registro lo prueba |
| Los seeds que emitió (B11) | Se quedan donde están. Un seed es evidencia entregada, no un préstamo |

**Nada se borra; todo se cierra con fecha.** Archivar un brain es ponerle `valid_to` a su vigencia operativa, igual que a cualquier otra afirmación (B40). El `brain.db` se conserva, deja de reconstruirse desde el pipeline y queda fuera del alcance del DT-Validador, porque medirlo contra el canon vigente no dice nada útil: refleja un sistema que ya no existe.

**Quién lo decide.** El archivado exige el rol accountable del sistema en Run y la ventana que fije el cliente, que por defecto es de doce meses después del cutover. Es decisión de nivel A3 (B39) y no baja de ahí por historial: apagar la memoria de un sistema es irreversible.

**B45 — Toda consulta es un objeto con ciclo de vida**: hasta aquí el canon gobernaba con detalle cómo se construye el conocimiento y casi nada cómo se consume. Esa asimetría dejaba sin piso a tres reglas simultáneas: B42 exige registrar el propósito de cada consulta, B43 exige medir el uso y trazar las decisiones, y B35 exige evaluar el resultado esperado. Las tres presuponen un objeto que el canon nunca definió.

**La consulta tiene identidad.** Sin un identificador no hay dónde registrar el propósito, no hay qué contar para medir uso, y una respuesta equivocada no se puede rastrear hasta el conocimiento que la produjo. Es la pieza que vuelve verificables a B42 y B43 en lugar de declarativas.

Seis etapas, cada una gobernada por una regla que ya existe:

| Etapa | Qué ocurre | Regla |
|-------|-----------|-------|
| **1 Admisión** | Se adjuntan identidad, rol y **propósito**. Sin propósito declarado, la consulta no cruza ninguna frontera | B42 |
| **2 Resolución** | El brain determina qué significa la pregunta, qué eslabón de la cadena la ancla y qué política aplica | B35, B27, B42 |
| **3 Recuperación** | Se lee de la fuente autorizada. Lo que vive en otra herramienta se lee por referencia, no se copia | B38, B4 |
| **4 Razonamiento** | Se compone la respuesta y se declara con qué nivel de certeza se sostiene cada parte | B37 |
| **5 Respuesta** | Se entrega con su resumen de niveles y con lo que faltó: los huecos se declaran, no se rellenan | B17, B35 |
| **6 Registro** | Se guarda qué se preguntó, para qué, qué conocimiento se usó y qué se decidió después | B43 |

**Tres reglas de la consulta.**

- **El propósito es parte de la consulta, no del solicitante.** La misma persona que puede leer un hallazgo para documentar una causa raíz no puede leerlo para comparar proveedores. La autorización es del par solicitante y propósito (B42), y eso solo es registrable si la consulta existe como objeto.
- **Una respuesta sin nivel de certeza está incompleta.** El brain no devuelve lo que puede: devuelve lo que se necesita, y dice con qué confianza lo sostiene. Una respuesta que no distingue el hecho irrefutable de la interpretación obliga a desconfiar de ambos.
- **La consulta es el eslabón entre el conocimiento y la decisión.** B37 traza de dónde viene lo que el brain sabe; B43 traza qué se decidió y con qué resultado. La consulta es lo que une ambas puntas: sin ella, una decisión equivocada no se puede rastrear hasta la respuesta que la motivó.

**Qué falta para cumplirla.** No existe tabla de consultas, ni columna de propósito en `knowledge_lineage`, ni filtro en `brain.py`. Esta regla declara el contrato; `quality-gates-enterprise-brain.md` lista en sus gates no exigibles qué hace falta para poder auditarlo.

---

## Reglas de Vocabulario (V)

**V1 — Vocabulario Empresarial como Semilla Cross-Sistema**: todo pipeline de extracción de vocabulario DEBE: (1) cargar el vocabulario empresarial del bank-brain como capa de referencia; (2) cruzar términos en 3 categorías: Confirmar, Enriquecer, Proponer; (3) nombrar reglas y journeys con términos del vocabulario empresarial — nunca con nombres internos de variables.

**V2 — Resolución de Conflictos de Vocabulario**: cuando dos sistemas usan el mismo término con significados distintos, el bank-brain documenta el conflicto en `knowledge-base/vocab/conflicts-v{N}.json`. La resolución la decide el Industry SME del dominio — no el agente técnico del sistema. El término ganador queda en el vocabulario con `est: "resolved"`.

---

## Reglas de Pipeline (P)

**P1 — Flujo de carpetas `source/` → `knowledge-base/` → `digital-brain/`**: esta es la invariante real del estate, presente en los 6 brains maduros. El corpus crudo nunca se lee directo desde el builder: pasa por una capa de conocimiento curado y versionado.

El pipeline se organiza en tres etapas: **extracción** (JSON crudo desde la fuente), **enriquecimiento** (JSON enriquecido, por ejemplo con síntesis LLM) y **carga** (brain.db). Materializar la etapa intermedia es recomendado para brains que extraen de código fuente, no obligatorio. Ver ADR-EB-006.

Las palabras Bronze, Silver y Gold quedan reservadas para la **calidad del conocimiento** (Regla B37), no para las etapas del pipeline. Un brain.db contiene los tres niveles, cada afirmación marcada con el suyo; la carga no convierte nada en gold por sí misma.

**P2 — Idempotencia**: todo `build-brain.py` es idempotente — reconstruye el brain desde cero sin perder marks de pasos anteriores. INSERT OR IGNORE como patrón base; UPDATE explícito solo para marks de alta confianza.

**P3 — Preservación de marks**: `CTM_ENTRY` y `CTM_HINT` son marcas de alta confianza; ningún paso posterior las sobreescribe. El orden de precedencia es: CTM_ENTRY (evidencia directa de ejecución) > CTM_HINT (inferido de código) > arquetipos de contenido (clasificador automático).

**P4 — Portal generado siempre**: `portal/*.html` es invariablemente generado por `build-portal.py` desde el `brain.db` activo. Un HTML editado a mano no es la fuente de verdad: el brain es la fuente de verdad.

El script vive en dos lugares según el contexto, y confundirlos hacía que la regla apuntara a una ruta inexistente:

| Contexto | Ubicación | Qué es |
|----------|-----------|--------|
| Brain implementado | `generators/build-portal.py` | El generador del brain, adaptado a su corpus |
| Asset Enterprise Brain | `templates/build-portal.py` | La implementación de referencia que cada brain copia y adapta |

El asset no tiene `generators/` y es correcto que no lo tenga: no construye un `brain.db` propio, define cómo construirlo. Dueño del script en ambos contextos: `dt-ingenieria` (Regla B41).

**P5 — brain.db en .gitignore**: brain.db nunca se commitea al repositorio. Se reconstruye desde el pipeline. El `.gitignore` del proyecto debe incluir `**/digital-brain/brain.db` y `**/digital-brain/brain.db.backup-*`.

---

## Regla Ontológica — Dos evaluaciones del AS-IS

Estas dos evaluaciones son ortogonales y NO deben mezclarse en el mismo DT ni en el mismo output:

| Evaluación | Pregunta | SME responsable | Artefacto |
|-----------|----------|----------------|-----------|
| **Entendimiento** | ¿Qué hace el sistema? | Specialist RE + Domain SMEs | BCOPBrain (vocabulario, almas, journeys, reglas) |
| **Salud** | ¿Qué tan sano está el código? | Code Quality Assessment SME | ISO 5055, CWE, deuda técnica, 7R decision |

---

## Nota — business_name

Ver **Regla B30** para el estándar completo de calidad del `business_name`. La regla está en la sección B (Reglas de Arquitectura) porque afecta la integridad estructural del brain, no solo el vocabulario.

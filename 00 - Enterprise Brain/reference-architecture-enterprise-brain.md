# Reference Architecture — Enterprise Brain
> Versión 2.0 · 2026-10-07 · Digital Core · Accenture México

---

## Arquitectura de una Instancia (un sistema)

La fuente ejecutable del schema es [`templates/schema.sql`](templates/schema.sql). El diagrama muestra el flujo completo de una instancia individual.

```
CAPA 1 · CORPUS              CAPA 2 · EXTRACCIÓN Y CURACIÓN          CAPA 3 · EL BRAIN       CAPA 4 · RAZONAMIENTO
────────────────────         ──────────────────────────────          ─────────────────       ─────────────────────

FUENTES ESTÁTICAS            parsers (batch / demanda)               digital-brain/
source/                      ┌──────────────────────────┐            ├── brain.db             brain.py (Agent API)
├── code/        ──────────→ │ 1. Extracción            │       ──→  │   CORE (19 tablas)     DT Swarm (×20)
├── docs/                    │ 2. Curación              │            │   + extensión          Portal HTML
└── PPTs · diags             │ 3. Enriquecimiento (LLM) │            │     brain_type         bank-brain ATTACH
                             │ 4. Anclaje ontológico    │            │
FUENTES VIVAS                └──────────────────────────┘            └── seeds/
├── Git / GitHub  connectors (continuo / demanda)
├── Jira          ──────────→ knowledge-base/ (curado)
├── Monitoring               build-brain.py → brain.db
└── CMDB · CI/CD · etc.

P2: ningún dato en brain.db sin parser o conector capaz de recrearlo desde la fuente original.
```

---

## Arquitectura de Federación (bank-brain = Enterprise Brain del cliente)

El **bank-brain** es el brain de nivel más alto del cliente (`brain_type='enterprise'`). Federa los dos hemisferios del cliente vía SQLite ATTACH:

```
{cliente}/
├── bank-brain/                          ← Enterprise Brain del cliente (nivel más alto)
│   ├── bank-brain.db                    ← SQLite ATTACH — federa Change + Run
│   ├── bank-brain.py                    ← Agent API federada
│   └── build-bank-brain.py             ← pipeline de construcción
│
├── projects/                            ← Hemisferio Change (Change the Business)
│   ├── exodus/digital-brain/brain.db   ← brain_type='project', hemisphere='change'
│   ├── can/digital-brain/brain.db
│   └── unity/digital-brain/brain.db
│
└── systems/                             ← Hemisferio Run (Run the Business)
    ├── core/informix/digital-brain/brain.db    ← brain_type='system', hemisphere='run'
    ├── channels/appmovil/digital-brain/brain.db
    └── integration/controlm/digital-brain/brain.db

  bank-brain.db — ATTACH de ambos hemisferios:
    -- Hemisferio Change
    ATTACH 'projects/exodus/digital-brain/brain.db' AS exodus
    ATTACH 'projects/can/digital-brain/brain.db' AS can
    -- Hemisferio Run
    ATTACH 'systems/core/informix/digital-brain/brain.db' AS informix
    ATTACH 'systems/channels/appmovil/digital-brain/brain.db' AS appmovil
         │
         ├── capabilities_consolidated()   ── UNION ALL etb_l3 de Change + Run
         ├── capability_gap()              ── L3 sin cobertura en ningún brain
         ├── capability_alignment()        ── brains con etb_version desalineada
         ├── system_dependencies()         ── grafo global de dependencias
         ├── change_inventory()            ── proyectos activos en Change
         └── run_inventory()              ── sistemas en producción en Run
```

---

## Arquitectura por Capas — Definición Canónica

Seis capas organizan el Enterprise Brain de extremo a extremo. Cada capa tiene una **definición arquitectónica** (qué es, qué contiene, dónde vive, qué reglas la gobiernan, qué no es) y una **definición funcional** (qué hace, cómo se verifica, qué significa que falle). La definición rige para toda instancia del asset; el contenido varía por cliente y sistema, la estructura no.

Las 6 capas de arquitectura y las 4 capas del Gemelo Cognitivo son taxonomías distintas y no se confunden: las 4 capas (Lenguaje, Almas, Biografía, Intención) describen **qué tipo de conocimiento** se construye; las 6 capas de arquitectura describen **dónde y cómo** se construye, almacena y usa ese conocimiento.

---

### Capa 1 — Corpus

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | Archivos fuente crudos del sistema, sin modificación. Tres subcarpetas: `source/code/` (código ejecutable: SPs, COBOL, ABAP, PL-SQL, T-SQL, Java, configs), `source/docs/` (documentación: especificaciones, runbooks, manuales de vendor) y `source/ops/` (operación: scripts CTM, JCL, configuración de schedules). |
| Contrato de frontera | Entrada: olas de entrega del cliente — código productivo verificado. Salida: ninguna. La Capa 1 es origen; la Capa 2 lee de ella sin modificarla. |
| Ubicación física | `{brain-root}/source/` — siempre la misma ruta relativa, sin excepción. |
| Reglas que la gobiernan | B25 (el brain refleja lo que el sistema ES — el corpus es esa realidad sin interpretación); B26 (todo brain comienza con el estudio histórico — el corpus es la evidencia primaria); ADR-EB-002 (brain.db se reconstruye desde el código fuente — el corpus es la fuente que lo hace posible). |
| Qué no es | No es el knowledge-base: los archivos en `source/` no se curan, no se interpretan y no se transforman. No es un repositorio de versiones del sistema: si el cliente entrega varias olas, se organiza por ola, pero el control de versiones pertenece al sistema de origen. |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Preservar el código y la documentación del sistema tal como existe en producción — sin editar, sin resumir. |
| Operaciones | Recibir olas de código, organizar por subcarpeta, documentar la cobertura de cada ola y su origen en el CLAUDE.md del sistema. |
| Digital Twin que la opera | `dt-source-steward` es el guardián de Capa 1: cataloga las fuentes disponibles, clasifica su tier natural y mapea qué casos de uso habilita cada una. `dt-build-operator` recibe y organiza `source/`. El Specialist RE de la tecnología valida completitud en el momento de la entrega. |
| Verificación | `source/code/` no está vacío; `knowledge-base/source-catalog.md` declara las fuentes activas con su tier y cobertura; el CLAUDE.md del sistema documenta la ola y su origen; no hay archivos interpretados o generados dentro de `source/`. |
| Qué significa que falle | Corpus vacío → la Capa 2 no tiene qué extraer → brain.db no puede poblarse. Corpus incompleto sin catálogo de fuentes → el brain no sabe qué no sabe → decisiones basadas en evidencia parcial sin advertencia. Fuente sin tier declarado → `dt-build-operator` asigna bronze por defecto → todo va a la cola de HITL innecesariamente. |

---

### Capa 2 — Extracción y Curación

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | Dos tipos de generador, cuatro actos. Los **parsers** procesan fuentes estáticas que el cliente entrega (código, documentación, presentaciones, diagramas) mediante cuatro actos: **(1) Extracción** — parseo para producir JSON crudo; **(2) Curación** — organización, deduplicación y estructura en `knowledge-base/`; **(3) Enriquecimiento** — síntesis LLM del `business_name` leyendo el artefacto completo (ADR-EB-004); **(4) Anclaje ontológico** — asignación de `process_id`, `capability_id` y `product_id`. Los **connectors** integran sistemas vivos (Git, Jira, herramientas de monitoreo, CMDB, pipelines de CI/CD) y pueden alimentar el brain de forma continua o bajo demanda, ejecutando los mismos cuatro actos sobre datos del sistema origen. La distinción entre parser y connector es de fuente y cadencia, no de función. |
| Contrato de frontera | Entrada: (a) archivos crudos de `source/` para parsers; (b) APIs, webhooks o eventos de sistemas vivos para connectors. Salida: conocimiento curado con los campos críticos completos — `business_name`, `tier`, `process_id`, `capability_id`. El contrato de salida es invariante; el camino de entrada depende del tipo de fuente. |
| Ubicación física | `generators/` (parsers y connectors ad-hoc por tipo de fuente y sistema origen — no existe un template único) · `knowledge-base/` (corpus curado — referencia canónica para parsers batch; algunos connectors pueden entregar directamente a `build-brain.py`). |
| Reglas que la gobiernan | P1 (toda actualización del brain pasa por un generador o conector — nunca directo desde la fuente); P2 (principio de pipeline — ningún dato en `brain.db` sin el parser o conector capaz de recrearlo; para connectors, reproducir significa re-pull desde el historial del sistema origen); P3 (marcas de alta confianza no se sobreescriben); B37 (cada afirmación recibe su nivel gold/silver/bronze al curar); B40 (bi-temporalidad — los connectors de fuentes vivas acortan la latencia entre `valid_from` y `recorded_at`); ADR-EB-004 (síntesis LLM — `business_name` se sintetiza leyendo el artefacto completo, nunca mediante heurísticos). |
| Qué no es | No toca `brain.db` directamente — eso es Capa 3. No razona sobre el contenido del sistema — eso es Capa 4. No genera el portal — eso es Capa 4. No existe un template único: la forma del generador depende del tipo de fuente y su cadencia. Lo que es invariante es P2, no el generador. |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Convertir código opaco en conocimiento estructurado, nombrado y anclado a la ontología del negocio — listo para ser cargado en el brain. |
| Operaciones | Parsear fuentes por tecnología (Specialist RE); sintetizar `business_name` vía LLM source-read en lotes de 70-80; asignar `tier` (gold para código productivo, silver para lo que puede cambiar, bronze para lo que espera validación); anclar a proceso, capability y producto del negocio. |
| Digital Twin que la opera | `dt-build-operator` posee los tres primeros actos (extracción, curación, enriquecimiento). El anclaje ontológico no tiene DT dueño en el canon vigente — es la brecha activa de esta capa (requiere ADR). |
| Verificación | P2 idempotencia (correr el pipeline dos veces produce el mismo resultado); DoD-EB-02 (0 `business_name` vacíos o genéricos); D7 del Brain Auditor (0 `process_id` nulos en tablas de conocimiento — este criterio bloquea si el anclaje no se ejecutó). |
| Qué significa que falle | `business_name` genéricos → D3 FAIL. `process_id` nulos → D7 FAIL (bloqueante). Extracción parcial → brain.db incompleto sin que el validador lo detecte por sí solo. El fallo más silencioso es un anclaje omitido: el brain carga y valida las dimensiones D1-D6, pero sus hallazgos no se pueden priorizar ni comparar entre sistemas porque el conocimiento no está conectado a la cadena de valor. |

---

### Capa 3 — El Brain

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | Base de datos SQLite con tres componentes estructurales. El **CORE** (19 tablas — contrato de interoperabilidad universal) organiza cuatro contratos: **identidad** (`system_info`), **ontología** (`ontology_bindings` + sus dos dimensiones — `capabilities`/`processes` para el negocio y `itom_layer` para TI, según la matriz B21), **federación** (`cross_dependencies` + `signals`) y **honestidad** (`knowledge_gaps` + `knowledge_lineage`). Más exactamente **una extensión** según `brain_type` (B15): `SYSTEM` para sistemas en Run (`components`, `rules`, `vocabulary`, `journeys`, etc.), `PROJECT` para proyectos en Change (`applications`, `waves`, `risks`, `decisions`, etc.) o `ENTERPRISE` para el bank-brain (`federated_brains`, `documents`). Más el **puente Change-Run** de su lado (ADR-EB-008): los brains Change declaran `plateaus`, `transitions`, `readiness_gates` y `slos`; los brains Run declaran `findings` y `slos`. *Nota de evolución: ADR-EB-014 (pendiente) agregaría `source_catalog` como tabla 19 del CORE.* |
| Contrato de frontera | Entrada: JSON curado de `knowledge-base/` vía `build-brain.py`. Salida: `brain.db` como artefacto binario — accedido exclusivamente a través de `brain.py` (Capa 4) en modo lectura (`PRAGMA query_only=1`). Excepción única: `_db_registro()` usa una conexión de escritura separada solo para la tabla de runtime `queries` (B45). Nada más toca `brain.db` directamente en producción. |
| Ubicación física | `{brain-root}/digital-brain/brain.db` — en `.gitignore`, reconstruido desde pipeline (ADR-EB-002). Las tablas de runtime (`queries`) se preservan entre builds vía `RUNTIME_TABLES`. |
| Reglas que la gobiernan | ADR-EB-001 (SQLite); ADR-EB-002 (gitignore — brain.db no se commitea); ADR-EB-006 (CORE destilado del estate); ADR-EB-007 (la industria determina la semántica — vocabulario, capabilities y regulador los suministra el Industry SME); ADR-EB-008 (puente Change-Run — cada hemisferio declara su lado); B15 (CORE + exactamente una extensión por `brain_type`); B21 (ontología = matriz 2×2: ETB × ITOM, Change × Run); B22 (toda pieza de conocimiento ancla a un `process_id`); B37 (calidad y linaje en `knowledge_lineage`); B40 (bi-temporalidad: `valid_from`/`valid_to` + `recorded_at`). |
| Qué no es | No es la base de datos de producción del cliente. No es CMDB. No es el portal. No es la API de razonamiento — eso es `brain.py` (Capa 4). No determina su propia semántica — la industria la define vía el Industry SME (ADR-EB-007). No se edita directamente: todo cambio entra por el pipeline (Capa 2). |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Ser la fuente de verdad única del conocimiento sobre el sistema, con su calidad declarada, su linaje registrado y su historia preservada. |
| Operaciones | Carga idempotente (INSERT OR IGNORE); `snapshot(date)` para reconstruir el conocimiento en una fecha de negocio pasada (B40); preservación de `RUNTIME_TABLES` entre builds; federación vía SQLite ATTACH desde el enterprise brain (ADR-EB-003). |
| Digital Twin que la opera | `dt-build-operator` construye; `dt-brain-engineer` mantiene el schema y los templates; `dt-brain-auditor` audita. |
| Verificación | Brain Auditor D1 (19 tablas CORE + extensión correcta + puente declarado); D7 (0 `process_id` nulos en tablas de conocimiento — B22); D8 (puente Change-Run sin transición sin `run_owner` ni SLO sin `current`); D9 (calidad y linaje — sin gold huérfano de fuente, sin gold por validación sin `validated_by`). |
| Qué significa que falle | `brain.db` incompleto → Brain Auditor D1 FAIL → RELEASE bloqueado. Puente incompleto → D8 FAIL — el brain no puede detectar rupturas Change↔Run. `brain.db` con datos incorrectos y validador que pasa → razonamiento incorrecto sin error visible — el error más costoso porque se detecta tarde, cuando una decisión ya se tomó. |

---

### Capa 4 — Razonamiento y Agentes

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | `brain.py` (Agent API — interfaz estándar de métodos obligatorios) + el enjambre de 20 Digital Twins canónicos (B41) + `build-portal.py` (generador del portal HTML). |
| Contrato de frontera | Entrada: `brain.db` vía `brain.py` (conexión read-only, `PRAGMA query_only=1`). Salida: respuestas estructuradas a consultas, hallazgos, portal HTML, seeds para sistemas vecinos. La Capa 4 nunca escribe en `brain.db` salvo `registrar_consulta()` que usa `_db_registro()` — conexión de escritura separada, solo para `queries` (B45). |
| Ubicación física | `templates/brain.py` · `dt/` (cada DT con su `CLAUDE.md`) · `generators/build-portal.py` · `portal/` (output generado — nunca hand-authored, ADR-EB-005). |
| Reglas que la gobiernan | B41 (23 DTs canónicos); B42 (confidencialidad por propósito — `abrir_consulta()` valida propósito antes de recuperar); B43 (autoevaluación en 5 ejes); B45 (toda consulta es un objeto con ciclo de vida de 6 etapas); B39 (autonomía graduada A0-A3); ADR-EB-005 (portal generado); ADR-EB-003 (federación vía ATTACH). |
| Qué no es | No modifica el conocimiento del brain — eso va por el pipeline (Capas 2→3). No ejecuta acciones en sistemas de producción del cliente — eso es Capas 5/6 con nivel de autonomía declarado. No es el corpus ni el pipeline. |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Exponer el conocimiento del brain para razonamiento, consulta, generación de hallazgos y portal — siempre con el nivel de certeza de cada respuesta declarado. |
| Operaciones | `abrir_consulta()`, `responder()`, `registrar_consulta()` (B45); `autoevaluacion()` (B43); `snapshot(date)` (B40); `coverage()`, `value_chain()`, `capability_gap()`, `system_dependencies()` (análisis); `build-portal.py` (portal HTML). |
| Digital Twin que la opera | `dt-brain-engineer` mantiene `brain.py` y `build-portal.py`; los 20 DTs en enjambre consultan vía `brain.py`. |
| Verificación | DoD-EB-08 (interfaz estándar de 5 métodos expuesta); DoD-EB-07 (portal generado desde `brain.db`, nunca hand-authored); `dt/dt-brain-auditor/test-brain-api.py` (20 checks funcionales sobre B40, B42, B43, B45). |
| Qué significa que falle | `brain.py` sin métodos obligatorios → el DT swarm no puede interrogar el brain sistémicamente. Portal hand-authored → viola ADR-EB-005 y se desincroniza del brain. Consulta respondida sin registrar → B42 y B43 no tienen evidencia para operar (propósito sin registro, uso sin contador). |

---

### Capa 5 — Capa Agéntica

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | Casos de uso de IA que corren sobre el brain como plataforma: documentación asistida de RCA, generación de runbooks, correlación de señales de observabilidad, identificación de casos de prueba (QE shift-left), escritura de definiciones funcionales, generación de código en Change. Cada caso de uso se ancla a una sub-capacidad del IT Operating Model. |
| Contrato de frontera | Entrada: `brain.py` API + contexto del caso de uso específico. Salida: artefactos de entrega (runbooks, specs, test cases, código) siempre en nivel silver — el brain propone; las herramientas de registro del cliente y sus dueños promueven a gold (B39). |
| Ubicación física | Sin tabla en `brain.db` para el catálogo de casos de uso (B38 pendiente — requiere ADR). Los artefactos producidos van a `knowledge-base/` del sistema o a los repositorios del proyecto según su naturaleza. |
| Reglas que la gobiernan | B38 (el brain es la plataforma de casos de uso de IA de ambos hemisferios — Run y Change); B39 (autonomía graduada — los cuatro tipos de acción que nunca bajan de A3); ITOM (cada caso de uso se ancla a una sub-capacidad de TI que a su vez mueve un KPI de negocio — la IA tiene que ser parte de ese objetivo). |
| Qué no es | No razona sobre el brain mismo — eso es Capa 4. No toma decisiones de negocio sin aprobación del nivel de autonomía requerido — eso es Capa 6. No modifica los sistemas de registro (CMDB, ITSM, observabilidad) directamente: si hay un hallazgo, va al dueño de la herramienta y el dueño decide si lo adopta. |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Amplificar la productividad de los equipos de delivery usando el brain como contexto estructurado — sin duplicar los sistemas de registro existentes. |
| Operaciones | Documentar RCA asistido (Run); generar runbooks desde el grafo de dependencias; correlacionar señales de observabilidad con el mapa de componentes; identificar casos de prueba desde los journeys (QE shift-left — B37 anotación temprana); escribir definiciones funcionales desde las reglas catalogadas; generar código en Change desde el modelo del sistema. |
| Digital Twin que la opera | Los DTs especializados por caso de uso + `dt-human-reviewer` (validación humana para los niveles que lo requieren). |
| Verificación | Cada caso de uso declara su nivel de autonomía (A0-A3) y su sub-capacidad ITOM de referencia. Todo output sale como silver; la herramienta de registro del cliente lo promueve a gold cuando lo adopta. |
| Qué significa que falle | Caso de uso sin ancla ITOM → no se puede medir su aporte al negocio ni priorizar su operación. Output sin nivel de autonomía declarado → `dt-human-reviewer` no sabe si debe bloquear o aprobar. Catálogo de casos de uso no registrado en `brain.db` (B38 pendiente) → el brain no puede reportar cuántos casos de uso lo consumen ni con qué frecuencia, lo que ciega el eje de uso de `autoevaluacion()` (B43). |

---

### Capa 6 — Decisiones y Acciones · Plano de Gobierno

**Definición arquitectónica**

| Eje | Definición |
|-----|-----------|
| Composición | Dos planos superpuestos. El **plano de decisiones** — objeto `decisions` en `brain.db` (extensión PROJECT) — registra cada decisión con sus opciones descartadas, el conocimiento que la sostuvo con el nivel que tenía en ese momento, el rol que decidió y el resultado observado. El **plano de gobierno** define las reglas del asset: qué puede hacer el brain, con qué autonomía, quién aprueba, y cuándo el brain sobrevive al sistema que refleja. |
| Contrato de frontera | Entrada: hallazgos de Capa 4 + artefactos de Capa 5 + aprobaciones del nivel de autonomía requerido. Salida: decisiones trazables que cierran el ciclo de aprendizaje — si el KPI no se movió como se esperaba, ese dato retroalimenta el razonamiento del brain. |
| Ubicación física | `decisions` en `brain.db` (extensión PROJECT); el plano de gobierno en `CLAUDE.md` del sistema, `canon/brain-rules.md` y los ADRs. |
| Reglas que la gobiernan | B39 (autonomía graduada — los 4 tipos de acción que nunca bajan de A3: cambio en producción, decommission, cambio de configuración de seguridad, impacto financiero directo al cliente); B43 (trazabilidad de decisión — quinto eje de `autoevaluacion()`); B44 (el brain sobrevive al sistema que refleja — ventana de 12 meses post-cutover antes de archivar). |
| Qué no es | No es la ejecución de la acción en sistemas de registro ajenos — el brain propone, no escribe en CMDB ni ITSM ni en ningún sistema del cliente. No es el historial de commits del repositorio. No es el registro de autonomía de las herramientas del cliente — es el registro del brain sobre sus propios consejos y sus resultados. |

**Definición funcional**

| Eje | Definición |
|-----|-----------|
| Responsabilidad única | Cerrar el ciclo — cada consejo del brain debe poder verificar si su KPI se movió como se esperaba, para que el brain aprenda y mantenga el derecho de que le crean. |
| Operaciones | Registrar decisiones con opciones descartadas y el conocimiento que las sostuvo; registrar el resultado observado vs el esperado; aplicar el nivel de autonomía correcto antes de ejecutar cualquier acción de Capa 5; archivar el brain con ventana de 12 meses después del cutover, resolviendo los huecos abiertos y avisando a los brains que lo federan (B44). |
| Digital Twin que la opera | `dt-change-manager` (catálogo de autonomía y gate de decommission); `dt-human-reviewer` (aprobaciones A3 — las cuatro acciones que nunca bajan de A3); `dt-brain-auditor` (auditoría de que ningún gate cierra sobre conocimiento silver). |
| Verificación | `autoevaluacion()['trazabilidad_decision'] > 0%` (hay decisiones registradas con outcome); ningún gate de decommission o cutover cierra con conocimiento silver que lo sostenga; la ventana de 12 meses post-cutover está documentada antes de archivar. |
| Qué significa que falle | Decisiones sin outcome registrado → el brain acumula consejos sin verificar su acierto y pierde credibilidad progresivamente. Acción A3 ejecutada sin aprobación explícita del rol accountable → riesgo operativo en producción. Brain archivado antes de 12 meses → se pierde la capacidad de reconstruir cómo estaba la arquitectura antes de la migración, con los costos legales y operativos que eso implica. |

---

## Los Dos Ejes del Conocimiento

El asset describe el conocimiento con dos modelos y ambos usan la palabra *capa*. No son versiones del mismo modelo ni uno sustituye al otro: son **ejes ortogonales**. Uno dice cómo está estructurado el sistema; el otro, en qué orden se construye el entendimiento. Leer uno como si fuera una versión vieja del otro es un error documentado — se ha cometido teniendo el repositorio completo a la vista — y esta sección existe para impedirlo.

| | Seis capas de arquitectura | Cuatro etapas de metodología |
|---|---|---|
| Pregunta que responde | ¿Dónde vive el conocimiento y cómo fluye? | ¿En qué orden se construye hasta llegar a la intención del negocio? |
| Naturaleza del eje | Estructural — son estratos simultáneos | Secuencial — son etapas que se ejecutan en orden |
| Nombres | Corpus · Extracción y Curación · El Brain · Razonamiento y Agentes · Capa Agéntica · Decisiones y Acciones | Lenguaje · Almas · Biografía · Intención |
| Alcance | Todo brain, sin excepción | Solo `brain_type = SYSTEM` (ver abajo) |
| Dónde se define | Esta sección, "Arquitectura por Capas" | los cuatro archivos de `knowledge-base/methodology/` |
| Qué pasa si falta | El brain no se puede construir ni consultar | El brain de un sistema legacy se puebla sin orden y las reglas quedan sin vocabulario que las sostenga |

### Cómo se cruzan

Las cuatro etapas **no son una capa de la arquitectura: son el método de trabajo de la Capa 2** (Extracción y Curación) cuando la fuente es un sistema legacy. Su producto aterriza en la Capa 3, y cada etapa llena exactamente una tabla de la extensión `SYSTEM`:

| Etapa | Qué extrae | Tabla que puebla | Capa que la ejecuta | Capa donde aterriza |
|------|-----------|------------------|---------------------|---------------------|
| 1 · Lenguaje | El vocabulario nativo del sistema: los términos con que nombra conceptos, procesos, actores y estados | `vocabulary` | Capa 2 | Capa 3 |
| 2 · Almas | Los módulos funcionales con identidad propia, reconocibles como actores del dominio y no como agrupaciones técnicas | `components.is_soul` | Capa 2 | Capa 3 |
| 3 · Biografía | Los flujos de negocio: cómo una transacción atraviesa el sistema desde el punto de entrada hasta el resultado | `journeys` | Capa 2 | Capa 3 |
| 4 · Intención | Las decisiones de negocio: qué valida, qué calcula, qué transforma, bajo qué condiciones y con qué consecuencia | `rules` | Capa 2 | Capa 3 |

**El orden de las etapas no es arbitrario y por eso es una secuencia y no un conjunto.** Sin el vocabulario de la etapa 1, las almas se nombran con jerga técnica en lugar de términos de negocio. Sin las almas de la etapa 2, los journeys no tienen actores entre los cuales trazarse. Sin los journeys de la etapa 3, las reglas quedan sueltas, sin el flujo que explica cuándo se disparan. La etapa 4 es el destino del método: la intención del negocio es lo que hay que preservar en una modernización, y las tres etapas previas existen para poder enunciarla sin inventarla.

### Alcance y fronteras

La metodología de cuatro etapas se declara a sí misma "del Gemelo Cognitivo del **Sistema**" y eso es literal: aplica a `brain_type = SYSTEM`, donde la fuente es código productivo de un sistema en Run. Los brains `PROJECT` y `ENTERPRISE` se pueblan de otras fuentes — artefactos firmados, documentos, brains federados — y por eso no recorren estas cuatro etapas. La arquitectura de seis capas, en cambio, rige para los tres tipos sin excepción.

**Qué no es.** Las cuatro etapas no son capas de la arquitectura y no deben numerarse junto a ellas. No son los niveles de calidad del conocimiento, que son bronze, silver y gold de la Regla B37. No son los `plateaus` del puente Change-Run (ADR-EB-008), que son estados de una transformación y no etapas de extracción. Y no son un pipeline alterno: el invariante P2 de la Capa 2 — todo brain se reconstruye desde cero y produce el mismo resultado — rige igual para las cuatro etapas.

---

## Extractores por Tecnología

| Tecnología | Extractor | Estado | Instancia de referencia |
|-----------|-----------|--------|------------------------|
| IBM Informix SPL | Specialist - Informix SPL | ACTIVE | BanCoppel EB-001 |
| Unisys COBOL/DMSII | Mainframe Migration SME | ACTIVE | Banamex EB-004 |
| SAP ABAP | Specialist - SAP ABAP | ACTIVE | Gentera SPE-AM-002 |
| Oracle Forms + PL/SQL | Specialist - Oracle Forms PL-SQL | PROPOSED | — |
| SQL Server T-SQL | Specialist - SQL Server T-SQL | PROPOSED | — |
| Java EE monolito | Software Engineering SME + análisis estático | via análisis | — |

**Principio de reutilización**: el método (las 4 capas del Gemelo Cognitivo) es constante e independiente de la tecnología. Lo que varía por tecnología es la **mecánica de extracción** — cómo parsear el código fuente para producir el JSON crudo. El pipeline de extracción, enriquecimiento y carga es siempre el mismo. Bronze, Silver y Gold designan la calidad de cada afirmación (Regla B37), no las etapas.

---

## Schema Canónico de brain.db (v2.0 — destilado)

**La fuente de verdad ejecutable es [`templates/schema.sql`](templates/schema.sql).**
Este documento no transcribe el DDL: un schema duplicado en prosa se desincroniza.

El canon v2.0 está destilado de los 16 brains con implementación real del estate
(ver ADR-EB-006). Reemplaza el schema aspiracional de 9 tablas de la v1.0, que
ningún brain implementaba.

### Estructura

Todo brain implementa **CORE + exactamente una extensión** según su `brain_type`.

| Capa | Tablas | Obligatoriedad |
|------|--------|---------------|
| **CORE** | `system_info` · `ontology_bindings` · `capabilities` · `processes` · `products` · `kpis` · `stakeholders` · `data_entities` · `technology_components` · `suppliers` · `measurements` · `costs` · `itom_layer` · `cross_dependencies` · `signals` · `knowledge_gaps` · `knowledge_lineage` · `queries` | Todo brain, sin excepción |
| **SYSTEM** (`hemisphere='run'`) | `components` · `component_calls` · `component_data` · `rules` · `rule_enrichment_log` · `vocabulary` · `journeys` · `component_capabilities` · `regulatory_obligations` · `external_systems` | Solo `brain_type='system'` |
| **PROJECT** (`hemisphere='change'`) | `applications` · `waves` · `risks` · `decisions` · `user_stories` | Solo `brain_type='project'` |
| **ENTERPRISE** | `federated_brains` · `documents` | Solo `brain_type='enterprise'` |

El CORE cubre cuatro contratos: **identidad** (`system_info`), **ontología** (`ontology_bindings` + sus dos dimensiones), **federación** (`cross_dependencies` + `signals`) y **honestidad** (`knowledge_gaps`).

La ontología tiene dos dimensiones inseparables — ambas declaradas en `ontology_bindings`:

| Dimensión | Tablas | `model_type` | Fuente |
|-----------|--------|-------------|--------|
| **Definición del negocio** — qué es el negocio y cómo opera | `capabilities` · `processes` | `etb` · `bian` · `regulatory` · `value-chain` · `client-logical` | Industry SME |
| **Habilitador IT** — cómo IT entrega y opera lo que el negocio necesita | `itom_layer` | `itom` | SME IT Operating Model |

| `model_type` en uso | En |
|--------------------|----|
| `etb` | BanCoppel · Banamex · Liverpool · AXA |
| `bian` | Gentera · Banamex |
| `regulatory` | BanCoppel CAN · Santander CAN |
| `it-capability` | Unity |
| `value-chain` | Liverpool |
| `client-logical` | AXA P&C |

### Puente Change–Run (cuerpo calloso)

Además del CORE y de su extensión, cada brain implementa **su lado** del puente entre hemisferios (Regla B24 · ADR-EB-008):

| Lado | brain_type | Tablas |
|------|-----------|--------|
| Change → Run | `project` | `plateaus` · `transitions` · `readiness_gates` · `slos` |
| Run → Change | `system` | `findings` · `slos` |

El cruce no se copia entre brains. Lo razona el enterprise brain con `templates/callosum.py`, vía ATTACH, y produce seis tipos de ruptura. Ejemplos: un hallazgo de Run que toca algo que Change está migrando y nunca se ruteó, o una transición que Change da por terminada mientras Run sigue operando la entidad.

### Las tres ontologías no se confunden

| Tabla | Qué contiene | Pregunta que responde |
|-------|-------------|----------------------|
| `capabilities` | Modelo de capacidades de la industria | ¿Qué sabe hacer el negocio? |
| `processes` | Ontología de procesos de la industria | ¿Cómo debería operar? |
| `journeys` | Trazas reales por el call graph | ¿Qué hace de hecho el sistema? |

La brecha entre `processes` y `journeys` es **hallazgo de negocio**, no error de datos: un proceso sin journey que lo realice es capacidad declarada sin soporte en código; un journey sin proceso es funcionalidad no documentada.

El CORE es el contrato de interoperabilidad: es lo que un brain debe exponer
para que los demás puedan federarlo. Su criterio de destilación (ADR-EB-006)
exige que cada tabla exista en al menos 3 brains independientes. Las cuatro
tablas incorporadas por fundamento de exigencia de regla — `suppliers`
(ADR-EB-011), `measurements` y `costs` (ADR-EB-012), `queries` (ADR-EB-013) —
aún no cumplen ese umbral en el estate; el estándar de destilación aplica en la
siguiente ronda de homologación.

### Por qué las ontologías divergen por tipo

Los brains de proyecto y de sistema modelan realidades distintas, y eso es
correcto. Cinco brains construidos de forma independiente (Exodus, Unity, CAN
BanCoppel, CAN Santander, payments-modernization MONEX) convergieron en
`applications`/`waves`/`risks`/`decisions` en lugar de `components`/`rules`.
El canon acomoda esa distinción en vez de forzar un molde único.

### Decisiones de homologación

| Concepto | Resolución | Razón |
|----------|-----------|-------|
| Identidad del brain | `system_info` tabular | Mayor base instalada (44 scaffolds) sobre `project_info`, `program_info`, `brain_meta`, `hemisphere_meta` |
| `cross_dependencies` | Modelo de perspectiva (`other_system` + `direction`) | Preserva autonomía del brain (Regla B1) — no requiere grafo global |
| Capabilities | `capabilities` con columna `ontology` | Conviven ETB, BIAN, RTL+FSV y ETB P&C. El canon fija la jerarquía, no el catálogo |
| Procesos | `processes` — tabla propia, L1-L4 + `lob` | La ontología de procesos es distinta por industria y **no se deriva** de la de capabilities (ADR-EB-007) |
| Nombre del brain de cliente | `{industria}-brain` | La semántica la determina la industria, no el cliente (ADR-EB-007) |
| `souls` | Retirada como tabla → `components.is_soul` | Cero brains la implementaban como tabla |
| Regulación | `system_info.regulator` configurable | El hook es universal; el regulador cambia (CNBV, CNSF, PROFECO) |

### Homologar sin reescribir: vista de compatibilidad

Para brains productivos con corpus poblado (Informix 90 MB, Banamex 122 MB) la
ruta por defecto **no es migrar datos**, sino el patrón validado en Banamex
(`risks` ← `hallazgos`): crear una vista con el nombre canónico sobre la tabla
histórica.

```sql
-- El brain de Informix expone la interfaz canónica sin tocar su pipeline
CREATE VIEW IF NOT EXISTS components AS
SELECT id, name, label AS display_name, biz AS description, domain,
       'sp' AS tipo, fan_in, fan_out, loc, is_soul, soul_rank,
       batch_archetype AS archetype
FROM sps;
```

Homologa la interfaz, preserva la inversión en el pipeline y es reversible.

---

## Frameworks de Referencia

| Framework | Uso en Enterprise Brain | Cuándo aplica |
|-----------|------------------------|---------------|
| TOGAF | Gobierno de la arquitectura: estructura (dominios BDAT), método (ADM) y gobierno. Envuelve a ETB e ITOM (Reglas B28 y B36) | Todo deployment |
| IT Operating Model (ITOM v9.0) | Cómo TI planea, entrega y opera la tecnología que habilita al negocio (`itom_layer`) | Todo deployment |
| ITIL 4 | Capa de prácticas dentro de ITOM: incidentes y problemas (`findings`), niveles de servicio (`slos`), cambio y liberaciones (`readiness_gates`) | Todo deployment, sobre todo Run |
| Taxonomía System-of-X (ADR-SPE-AM-008) | Clasificación del sistema en `togaf_type` (core, processors, channels, data, integration, compliance). Es taxonomía propia, no del metamodelo TOGAF | Todo deployment |
| BIAN Service Landscape v14 | Mapeo de dominios legacy a capabilities bancarias estándar (bian-mapping.json) | Clientes bancarios |
| ETB (Enterprise Technology Blueprint) | 261 capabilities L3 — lenguaje común de cobertura entre todos los brains | Todo deployment |
| ISO/IEC 5055:2021 | Evaluación de salud del código AS-IS (transversal Calidad — Code Quality Assessment SME) | DISCOVER en HVM AM/MM |
| Calidad y linaje del conocimiento (Gold/Silver/Bronze) | Nivel de certeza de cada afirmación; los hechos irrefutables entran directo a gold (Regla B37, ADR-EB-010) | Todo brain |
| SQLite FTS5 | Búsqueda fulltext sobre reglas y vocabulario | Todo brain activo |

---

## ADRs Canónicos del Asset

| ADR | Decisión | Estado |
|-----|---------|--------|
| ADR-EB-001 | SQLite como motor del brain (vs Postgres, MongoDB, vector DB) | APROBADO |
| ADR-EB-002 | brain.db en .gitignore — reconstruido desde pipeline | APROBADO |
| ADR-EB-003 | Federación via SQLite ATTACH (vs API runtime entre brains) | APROBADO |
| ADR-EB-004 | Síntesis LLM source-read como fuente de business_name (vs heurísticos) | APROBADO |
| ADR-EB-005 | Portal HTML generado siempre desde build-portal.py (prohibición de hand-authored) | APROBADO |
| ADR-EB-006 | Canon v2.0 destilado del estate (CORE + extensión por brain_type); retiro del schema aspiracional de 9 tablas | APROBADO |
| ADR-EB-007 | La industria determina la semántica del brain; nomenclatura `{industria}-brain`; ontología de procesos separada de capabilities | APROBADO |
| ADR-EB-008 | Cuerpo calloso: cada hemisferio declara su lado del puente Change–Run; el cruce lo razona `callosum.py` vía ATTACH | APROBADO |
| ADR-EB-009 | Estructura TOGAF en el CORE: `stakeholders`, `data_entities`, `technology_components`, `component_data` y `slos.kpi_id`; excepción acotada al principio de destilación | APROBADO |
| ADR-EB-010 | Calidad y linaje del conocimiento: gold, silver y bronze por afirmación; `knowledge_lineage` en el CORE; D9 | APROBADO |
| ADR-EB-011 | `suppliers` entra al CORE por implicación del roster — todo brain con DT de proveedores requiere la tabla (fundamento B) | APROBADO |
| ADR-EB-012 | `measurements` y `costs` entran al CORE por exigencia de regla — B43 necesita ejes de costo y desempeño que ninguna tabla existente sostenía (fundamento C) | APROBADO |
| ADR-EB-013 | `queries` entra al CORE como 18ª tabla — B42 necesita registrar propósito, B43 necesita contar uso, B45 necesita un objeto para el ciclo de vida de 6 etapas (fundamento C) | APROBADO |

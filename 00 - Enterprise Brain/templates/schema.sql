-- =============================================================================
-- schema.sql — Schema Canónico del Enterprise Brain
-- Versión 2.0 · 2026-09-29 · Digital Core · Accenture México
--
-- Este schema NO es aspiracional: está DESTILADO de la auditoría de los 15
-- brains con implementación real del estate (BanCoppel, Banamex, MONEX,
-- Santander, Liverpool, AXA, Coppel, Gentera). Cada tabla del CORE existe
-- hoy en producción en al menos 3 brains independientes.
--
-- La v1.0 (9 tablas) se retira: incluía `souls` (tabla que no existe en
-- ningún brain) y exigía pipeline Medallion (que ningún brain implementa).
-- Ver ADR-EB-006.
--
-- ESTRUCTURA:
--   CORE        — 15 tablas · TODO brain, sin excepción (ADR-EB-009, ADR-EB-010, ADR-EB-011)
--   SYSTEM      — brains de sistema productivo (hemisphere='run')
--   PROJECT     — brains de proyecto de transformación (hemisphere='change')
--   ENTERPRISE  — {industria}-brain (brain_type='enterprise')
--   PUENTE      — cuerpo calloso Change–Run; cada hemisferio implementa su lado
--                 (project: plateaus·transitions·readiness_gates·slos ·
--                  system: findings·slos) — Regla B24
--
-- Un brain implementa CORE + exactamente UNA extensión según su brain_type,
-- más su lado del PUENTE.
-- =============================================================================


-- =============================================================================
-- CORE — obligatorio en todo brain (15 tablas · Reglas B15, B27, B28, B36, B37, B41 · ADR-EB-009, ADR-EB-010, ADR-EB-011)
--
-- Cubre cinco contratos irrenunciables:
--   identidad       → system_info
--   ontología       → ontology_bindings (declara ambas dimensiones — Regla B21)
--               La ontología es una matriz 2×2:
--               ┌──────────────┬───────────────────┬──────────────────────┐
--               │              │ ETB (negocio)      │ ITOM (habilitador IT)│
--               ├──────────────┼───────────────────┼──────────────────────┤
--               │ Change       │ capabilities       │ itom_layer           │
--               │              │ (qué transforma)   │ (it-strategy+delivery│
--               ├──────────────┼───────────────────┼──────────────────────┤
--               │ Run          │ capabilities       │ itom_layer           │
--               │              │ (qué opera hoy)    │ (technology-ops)     │
--               └──────────────┴───────────────────┴──────────────────────┘
--               processes aplica a ambas filas: cómo debería operar el negocio.
--   federación → cross_dependencies + signals
--   honestidad → knowledge_gaps
--
-- Regla B22 — todo conocimiento del brain ata a un proceso de negocio.
-- `processes` es CORE y las tablas de conocimiento llevan `process_id`
-- (o `component_processes` cuando la relación es N:M). Conocimiento sin
-- proceso es conocimiento que no se puede accionar ni priorizar.
-- =============================================================================

-- Identidad del brain.
-- Homologa 5 nombres en uso: system_info (MONEX scaffolds, AppMóvil),
-- project_info (Unity, Coppel), program_info (Exodus), brain_meta (CAN,
-- Liverpool, AXA, Santander), hemisphere_meta (Informix).
-- Gana `system_info`: es tabular (consultable) y ya es el nombre de los 33
-- scaffolds de BanCoppel + los 11 de MONEX — la mayor base instalada.
CREATE TABLE IF NOT EXISTS system_info (
    slug             TEXT PRIMARY KEY,
    display_name     TEXT NOT NULL,

    -- Regla B14 — enterprise | project | system
    brain_type       TEXT NOT NULL,
    -- Regla B13 — change | run  (de Informix.hemisphere_meta, ya en producción)
    hemisphere       TEXT NOT NULL,

    -- TOGAF — core | processors | channels | data | integration | compliance
    togaf_type       TEXT,
    togaf_state      TEXT,             -- baseline | transitional | target
    togaf_abb        TEXT,

    -- Industria ANCLA — determina el nombre del brain (Regla B18) y la
    -- semántica dominante. NO es la única: la composición completa vive en
    -- `ontology_bindings`, porque la multi-industria es la norma (ADR-EB-007).
    industry         TEXT NOT NULL,
    industry_sme     TEXT,             -- "SME/Industry/Industry Retail"

    -- Ontología de CAPABILITIES — qué sabe hacer el negocio.
    -- Describe la COMPOSICIÓN en texto legible; el detalle está en
    -- ontology_bindings. Ej: "Retail ETB v5.0 (RTL) + FS ETB v1.0 (FSV)"
    capability_model TEXT,

    -- Ontología de PROCESOS — cómo opera el negocio. Es DISTINTA por industria
    -- y no se deriva de la de capabilities:
    --   banca   → procesos por producto financiero, anclados a ETB numerado
    --   seguros → ramo primero, luego ciclo de póliza dentro de cada ramo
    --   retail  → cadena de valor por fases (PLAN→BUY→MOVE→SELL→SERVE)
    process_ontology TEXT,
    process_ontology_version TEXT,

    -- Ontología de OPERACIONES IT — cómo se opera el IT que soporta el negocio.
    -- La define el SME de ITOM/AMS (Regla B23); el brain la ANCLA, no la define.
    -- Ej: "ServiceNow ITOM Discovery v2.0", "ITIL v4 SMP", "AMS AIOps v1.0"
    -- El modelo completo (CIs, service map, SLOs, runbooks) vive en el SME.
    itom_model       TEXT,
    itom_sme         TEXT,            -- "SME/Framework/IT Operating Model"

    -- ¿La industria tiene eje de línea de negocio / ramo?
    -- Seguros sí (P&C, Vida-AP, Salud-GMM, Fianzas) — cada ramo con su ETB.
    -- Banca no. Deja NULL cuando no aplica; no inventar un eje que no existe.
    lob_dimension    TEXT,

    version          TEXT,             -- SemVer del brain
    status           TEXT NOT NULL,    -- discovered|seeded|building|active|stale|archived
    built_at         TEXT,             -- ISO datetime del último build
    source_of_truth  TEXT,             -- ruta del corpus fuente (Regla B31 — obligatoria)
    build_agent      TEXT              -- DT que construyó el brain (Regla B29 — trazabilidad)
);

-- Contrato de federación. Es la ÚNICA tabla presente en prácticamente todo el
-- estate y por tanto el contrato de interoperabilidad real.
-- Homologa 3 firmas incompatibles:
--   Informix : other_system + dependency_type + evidence
--   AppMóvil : source_system + target_system (modelo de arista)
--   Exodus   : other_system + relationship + origin_artifact
-- Gana el modelo de PERSPECTIVA (other_system + direction): 2 de 3 lo usan y
-- es el que permite que cada brain sea autónomo (Regla B1) — un brain declara
-- sus dependencias desde su propio punto de vista, sin conocer el grafo global.
-- `dependency_type` gana sobre `relationship` (Informix es la referencia madura).
CREATE TABLE IF NOT EXISTS cross_dependencies (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    other_system    TEXT NOT NULL,
    dependency_type TEXT,              -- orchestrates|calls|reads|writes|feeds|notifies
    direction       TEXT NOT NULL,     -- inbound | outbound
    volume          INTEGER DEFAULT 0,
    domains         TEXT,              -- JSON array
    regulation      TEXT,              -- JSON array
    description     TEXT,
    criticality     TEXT,              -- critical | high | medium | low

    -- Provenance. De Exodus: toda fila declara de qué artefacto salió.
    evidence        TEXT,
    origin_artifact TEXT
);

-- Bus de señales entre brains. De AppMóvil: `emit_signals()` al cierre del
-- pipeline. Es lo único que comparten los 33 brains de systems/ de BanCoppel,
-- así que ya es canon de facto.
CREATE TABLE IF NOT EXISTS signals (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    signal   TEXT NOT NULL,
    value    TEXT,
    source   TEXT,
    ts       TEXT NOT NULL
);

-- Composición de ontologías de la empresa (ADR-EB-007 · Regla B20).
--
-- Toda empresa tiene su PROPIA ontología, compuesta de los ETB de las
-- industrias que le corresponden más sus extensiones propias. La
-- multi-industria es la norma, no la excepción.
--
-- Caso probado (Liverpool): retail v5.0 (171 del Retail ETB V4 + 61
-- extensiones propias) + financial_services v1.0 (50, por su operación de
-- tarjeta con FICO-TRIAD, reguladas por CONDUSEF y Banxico).
--
-- Esta tabla declara la INTENCIÓN; `capabilities.ontology` registra lo que
-- de hecho está cargado. El DT-Validador contrasta ambas.
CREATE TABLE IF NOT EXISTS ontology_bindings (
    ontology       TEXT PRIMARY KEY,   -- retail | financial_services | insurance
    role           TEXT NOT NULL,      -- primary | secondary

    -- El ancla puede ser un ETB u otro modelo lógico de negocio (Regla B21).
    -- El estate usa hoy seis tipos, todos legítimos:
    --   etb        → ETB sectorial (Retail_ETB_V4, P&C ETB, Banking ETB)
    --   bian       → BIAN Service Landscape (Gentera, Banamex)
    --   regulatory → obligaciones de un instrumento (Banxico CAN, Circular 3/2012)
    --   it-capability → modelo de capacidades TI (Unity)
    --   value-chain   → cadena de valor (Liverpool)
    --   client-logical → modelo operativo lógico propio del cliente (AXA P&C)
    model_type     TEXT NOT NULL,
    catalog        TEXT,               -- "Retail_ETB_V4" · "BIAN v14" · "Circular 6/2025"
    catalog_version TEXT,

    industry_sme   TEXT,               -- "SME/Industry/Industry Retail"
    regulators     TEXT,               -- JSON array — cada ontología trae los suyos
    l3_base        INTEGER DEFAULT 0,  -- capabilities del catálogo base
    l3_extension   INTEGER DEFAULT 0,  -- extensiones propias de la empresa
    rationale      TEXT                -- por qué este modelo aplica a esta empresa
);

-- Ontología de negocio del brain — OBLIGATORIA en todo brain (Regla B21).
--
-- Todo brain, sea de sistema, proyecto o enterprise, ancla su ontología de
-- negocio a un ETB o a otro modelo lógico del negocio. Sin ancla, un brain
-- acumula hallazgos que no se pueden agregar ni comparar con nada.
--
-- El canon fija la ESTRUCTURA jerárquica L1/L2/L3, no el catálogo: el catálogo
-- lo declara `ontology_bindings.model_type` + `catalog`. Reemplaza `etb_l3` de
-- la v1.0, que asumía un único catálogo ETB de 261 L3.
--
-- Evidencia: 4 de 5 brains de proyecto del estate ya la tienen, cada uno con
-- un modelo distinto (Unity → capacidades TI, BanCoppel CAN → obligaciones
-- Banxico, Santander CAN → ETB + obligaciones, MONEX → macro-capacidades de
-- pagos). Exodus es el único sin ancla, y es brecha, no decisión de diseño.
CREATE TABLE IF NOT EXISTS capabilities (
    -- El prefijo del ID encoda la ontología: RTL.1.01 · FSV.1.01 · ETB-L3-001
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected

    -- FK lógica a ontology_bindings.ontology
    ontology        TEXT NOT NULL,     -- retail | financial_services | banking | insurance
    ontology_version TEXT,

    -- Distingue capability del ETB base vs. extensión propia de la empresa.
    -- Liverpool: 171 base + 61 extensiones, ambas legítimas y trazables.
    catalog_source  TEXT,              -- "Retail_ETB_V4" | "Newly Added"
    is_extension    INTEGER DEFAULT 0,

    l1_name         TEXT,
    l2_name         TEXT,
    l3_name         TEXT,
    definition      TEXT,

    -- La regulación viaja con la capability, no con la empresa: una capability
    -- financiera dentro de un retailer carga CONDUSEF y Banxico.
    regulation      TEXT,              -- JSON array

    coverage_status TEXT,              -- COVERED|PARTIAL|CROSS_CUTTING|NOT_COVERED
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    coverage_confidence TEXT,          -- high | medium | low (de Liverpool)
    coverage_evidence TEXT,
    primary_system  TEXT,
    component_count INTEGER DEFAULT 0
);

-- Ontología de PROCESOS de la industria.
-- Distinta de `capabilities` y distinta de `journeys`:
--   capabilities → qué sabe hacer el negocio (modelo de capacidades)
--   processes    → cómo opera, según la ontología de SU industria (este modelo)
--   journeys     → trazas técnicas reales por el código (entry point → cadena)
-- La jerarquía L1-L4 es genérica (de AXA); lo que la puebla lo define el
-- Industry SME. Nunca se hardcodea un modelo bancario para un cliente de otra
-- industria.
CREATE TABLE IF NOT EXISTS processes (
    id            TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    ontology      TEXT NOT NULL,       -- banca-etb | pc-etb | life-etb | retail-valuechain
    ontology_version TEXT,

    -- Eje de línea de negocio / ramo. NULL cuando la industria no lo tiene.
    lob           TEXT,

    l1_name       TEXT,                -- Captación · Suscripción · PLAN
    l2_name       TEXT,                -- fase
    l3_name       TEXT,                -- etapa
    l4_name       TEXT,                -- paso
    description   TEXT,

    capability_id TEXT,                -- FK lógica a capabilities.id (de AXA)
    systems       TEXT,                -- JSON array de slugs que lo ejecutan
    coverage_status TEXT,              -- COVERED | PARTIAL | NOT_COVERED
    source_sme    TEXT                 -- Industry SME que suministró el modelo
);

-- El brain como su propio backlog.
-- De Informix (knowledge_gaps + vista knowledge_completeness), Exodus
-- (open_questions) y Banamex (traceability_unresolved) — tres brains llegaron
-- al mismo concepto por su cuenta, señal fuerte de canon.
-- Principio Banamex: "ningún campo se inventa, ningún hueco se deja muerto".
-- Un hueco se expresa como pregunta dirigida a un SME, no como 'PENDIENTE'.
CREATE TABLE IF NOT EXISTS knowledge_gaps (
    id                TEXT PRIMARY KEY,
    gap_type          TEXT,            -- dato | decisión | acceso | validación
    dimension         TEXT,            -- negocio | tecnología | regulatoria | cultural
    domain            TEXT,
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    description       TEXT NOT NULL,
    impact            TEXT,
    required_for      TEXT,            -- fase/gate que bloquea
    resolution_action TEXT,            -- "Consulta {SME}: {pregunta concreta}"
    owner             TEXT,
    status            TEXT DEFAULT 'open',   -- open | resolved | accepted
    opened_at         TEXT,
    resolved_at       TEXT
);


-- Ontología de IT Operating Model — cómo se entrega y opera el IT que soporta
-- el negocio. Los 6 dominios canónicos y sus sub-capacidades los define el SME
-- "SME/Framework/IT Operating Model" (ITOM v9.0 + marco conceptual 2024-2027).
-- El brain ANCLA esta ontología; el modelo completo (procesos, roles, BSC,
-- métricas) vive en el SME (Regla B23).
--
-- Valores canónicos de `layer` (ITOM v9.0):
--   customer-engagement | it-strategy | delivery |
--   technology-operations | information-analytics | it-management
--
-- Aplica a ambos hemisferios:
--   Change → it-strategy (arquitectura) + delivery (diseño y desarrollo)
--   Run   → technology-operations (service-mgmt, infra, service-ops)
--   Ambos → customer-engagement + information-analytics + it-management
-- Puede estar vacía en scaffolds recién iniciados; no por hemisferio.
CREATE TABLE IF NOT EXISTS itom_layer (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    layer           TEXT NOT NULL,        -- dominio ITOM canónico (ver arriba)
    technology      TEXT,                 -- sub-capacidad slug del dominio
    maturity        INTEGER,              -- 1-5 (IT OM Maturity Framework)
    coverage_status TEXT,                 -- covered | partial | gap
    evidence        TEXT,                 -- artifact o fuente que lo sustenta
    process_id      TEXT,                 -- B22 — ata a proceso de negocio
    itom_sme        TEXT DEFAULT 'SME/Framework/IT Operating Model'
);


-- Catálogo de productos del cliente (Regla B27 — orientación a producto y KPI).
-- Los productos son el punto de partida de la cadena de valor:
--   Producto → KPI → Proceso → Aplicación → Infraestructura → Dato
-- El brain no puede responder "¿qué impacto tiene este cambio?" sin saber
-- qué producto afecta y qué KPI mueve.
-- Lo puebla ETB (north star, Regla B36); TOGAF lo estructura en el dominio B (Regla B28).
CREATE TABLE IF NOT EXISTS products (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name            TEXT NOT NULL,
    description     TEXT,
    product_type    TEXT,               -- cuenta | credito | seguro | pago | inversion | …
    product_line    TEXT,               -- línea de negocio (retail, banca-personas, etc.)
    status          TEXT DEFAULT 'active',  -- active | deprecated | planned
    channel         TEXT,               -- digital | sucursal | telefono | all
    process_id      TEXT,               -- FK lógica a processes.id (proceso principal)
    regulation      TEXT,               -- JSON array de reguladores aplicables
    owner_domain    TEXT,               -- dominio de negocio propietario
    launched_at     TEXT,               -- ISO date de lanzamiento al mercado
    source_doc      TEXT
);

-- KPIs del negocio vinculados a productos y procesos (Regla B27).
-- Change fija el target; Run mide el current. Patrón análogo a slos del puente
-- pero a nivel de producto de negocio, no de transición de migración.
-- Dominio B de TOGAF. Los SLOs de TI deberían trazarse al KPI que habilitan (Regla B36).
CREATE TABLE IF NOT EXISTS kpis (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    product_id      TEXT NOT NULL,      -- FK a products.id
    name            TEXT NOT NULL,
    description     TEXT,
    metric_type     TEXT,               -- volumen | tasa | tiempo | calidad | financiero
    unit            TEXT,               -- %, MXN, dias, txs/seg, NPS
    target          TEXT,               -- valor objetivo (lo fija Change/negocio)
    current         TEXT,               -- valor actual medido (lo registra Run/operación)
    frequency       TEXT,               -- diario | mensual | trimestral
    process_id      TEXT,               -- FK a processes.id — qué proceso mueve este KPI
    data_source     TEXT,               -- sistema/tabla/campo que lo alimenta
    owner           TEXT,
    status          TEXT DEFAULT 'active'
);

-- Stakeholders: quién decide, quién opera y a quién le importa (dominio B de TOGAF).
-- Destilado de 3 brains: Unity (capability_stakeholders, program_stakeholders),
-- Coppel (stakeholders) y Santander CAN (team_roles). ADR-EB-009.
-- Los portales compartibles nunca muestran nombres ni cargos de personas del cliente:
-- usan stakeholder_type y role como etiqueta genérica.
CREATE TABLE IF NOT EXISTS stakeholders (
    id               TEXT PRIMARY KEY,   -- "STK-{nnn}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name             TEXT NOT NULL,      -- unidad, equipo, rol o persona
    stakeholder_type TEXT,               -- executive_sponsor | business_owner | it_owner | operations | vendor | regulator | acn_sme
    organization     TEXT,               -- cliente, grupo, proveedor, Accenture
    role             TEXT,               -- rol en el programa o en la operación
    area             TEXT,               -- unidad organizacional
    raci             TEXT,               -- responsible | accountable | consulted | informed
    influence        TEXT,               -- high | medium | low
    concern          TEXT,               -- qué le importa: el viewpoint TOGAF que necesita
    capability_id    TEXT,               -- FK lógica a capabilities.id
    hemisphere       TEXT,               -- change | run | both
    confidence       TEXT,               -- confirmed | inferred | suspected
    active           INTEGER DEFAULT 1,
    source_doc       TEXT
);

-- Entidades de datos (dominio D de TOGAF). Eslabón Datos de la cadena B27.
-- Destilado de Informix sp_table_refs (200,761 referencias de SP a tabla). ADR-EB-009.
-- La operación de estos datos la describe ITOM (information-analytics); TOGAF les da lugar (B36).
CREATE TABLE IF NOT EXISTS data_entities (
    id              TEXT PRIMARY KEY,   -- convención: "{store}:{name}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name            TEXT NOT NULL,      -- nombre físico (tabla, colección, archivo)
    business_name   TEXT,               -- nombre de negocio (Regla B30)
    description     TEXT,
    entity_level    TEXT DEFAULT 'physical',  -- conceptual | logical | physical
    store           TEXT,               -- base de datos o esquema que la contiene
    technology_id   TEXT,               -- FK lógica a technology_components.id
    classification  TEXT,               -- public | internal | confidential | personal | sensitive
    regulation      TEXT,               -- JSON array: LFPDPPP, secreto bancario, PCI-DSS
    owner_id        TEXT,               -- FK lógica a stakeholders.id (data owner)
    row_count       INTEGER,
    source_doc      TEXT
);

-- Componentes tecnológicos (dominio T de TOGAF). Eslabón Infraestructura de B27.
-- Destilado de Coppel platforms y de components.current_platform. ADR-EB-009.
-- No confundir con itom_layer: ITOM describe CÓMO opera TI; esta tabla, QUÉ opera.
CREATE TABLE IF NOT EXISTS technology_components (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name            TEXT NOT NULL,      -- "IBM Informix IDS" · "HCL Commerce"
    category        TEXT,               -- dbms | os | hardware | middleware | runtime | platform | cloud_service | saas | network | it_tool
    -- Regla B38 — si es herramienta dedicada (it_tool), de qué es sistema de registro.
    -- El brain se alimenta de ella y la retroalimenta; nunca la sustituye.
    record_scope    TEXT,               -- cmdb | test_automation | observability | itsm | code_repo | backlog | scheduler
    vendor          TEXT,
    version         TEXT,
    hosting         TEXT,               -- on_prem | cloud | hybrid | saas
    location        TEXT,               -- data center, región o proyecto cloud
    status          TEXT DEFAULT 'active',  -- active | migrating | retiring | retired | planned
    support_status  TEXT,               -- supported | extended | end_of_support | unknown
    end_of_support  TEXT,               -- ISO date
    standard_status TEXT,               -- standard | tolerated | sunset | prohibited (Standards Information Base)
    itom_layer_id   TEXT,               -- FK lógica a itom_layer.id: capacidad de TI que lo opera (B36)
    description     TEXT,
    source_doc      TEXT
);


-- Proveedores y socios estratégicos (Regla B41 · ADR-EB-011).
-- Dueño: DT-Proveedores. Cierra los procesos ITOM 4 (Commercial Services
-- Management) y 5 (Strategic Partner Management), los únicos dos del catálogo
-- de 38 que ningún otro DT canónico cubría.
-- Un proveedor se evalúa contra su SLO medido, nunca contra su propuesta.
CREATE TABLE IF NOT EXISTS suppliers (
    id              TEXT PRIMARY KEY,
    tier            TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37
    name            TEXT NOT NULL,
    business_name   TEXT,               -- Regla B30: nombre en el idioma del negocio
    kind            TEXT,               -- strategic_partner | service_provider | software_vendor |
                                        -- infrastructure | staffing | niche
    -- ITOM separa los procesos 4 y 5 porque se gobiernan distinto:
    -- un socio estratégico co-desarrolla; un proveedor transaccional entrega contra contrato.
    criticality     TEXT,               -- critical | high | medium | low
    -- En banca supervisada un proveedor crítico es materia regulatoria, no solo contractual.
    regulatory_flag INTEGER DEFAULT 0,  -- 1 = su criticidad tiene implicación ante el regulador
    contract_ref    TEXT,               -- referencia al contrato; el documento no se copia (B38)
    contract_end    TEXT,               -- ISO date
    slo_id          TEXT,               -- FK lógica a slos.id: contra qué SLO medido se evalúa
    exit_plan       TEXT,               -- qué pasa si sale. NULL en crítico es hallazgo
    process_id      TEXT,               -- Regla B22: proceso de negocio que habilita
    itom_layer_id   TEXT,               -- capacidad de TI que el proveedor opera
    status          TEXT DEFAULT 'active',  -- active | onboarding | exiting | exited
    owner_role      TEXT,               -- rol accountable en stakeholders (Regla B39)
    description     TEXT,
    source_doc      TEXT
);
CREATE INDEX IF NOT EXISTS ix_suppliers_crit ON suppliers(criticality, status);


-- Linaje del conocimiento (Regla B37 · ADR-EB-010). Generaliza rule_enrichment_log
-- de Informix (22,425 filas de procedencia campo por campo) a todo el brain.
-- Cada afirmación del brain tiene aquí su nivel, su fuente y quién la validó.
--   gold   → hecho irrefutable. Por ORIGEN (sin HITL): código productivo, log,
--            monitoreo, ejecución de job, regulación publicada, artefacto firmado.
--            Por VALIDACIÓN: un rol con autoridad (HITL) confirmó un silver.
--   silver → con fuente identificada, pero puede cambiar o falta confirmar
--   bronze → volumen sin validar, pendiente de HITL
--   rejected → descartado por HITL; se conserva para auditoría
-- La fuente puede ser gold y la interpretación silver: el SP es gold, el
-- business_name que un LLM sintetizó de él es silver hasta validarse.
CREATE TABLE IF NOT EXISTS knowledge_lineage (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_table   TEXT NOT NULL,      -- tabla de la afirmación
    entity_id      TEXT NOT NULL,      -- id de la fila; PK compuesta como "a|b"
    field          TEXT,               -- NULL = la fila completa
    tier           TEXT NOT NULL,      -- gold | silver | bronze | rejected
    tier_basis     TEXT NOT NULL,      -- origin | validated | sourced | ingested | demoted | rejected
    source_type    TEXT NOT NULL,      -- code | log | monitoring | job_run | regulation | signed_artifact |
                                       -- document | interview | llm_synthesis | seed | bulk
    source_ref     TEXT,               -- archivo:línea · id de log · instrumento y artículo · doc y página
    source_version TEXT,               -- hash, commit, versión de deploy o fecha de publicación
    asserted_by    TEXT,               -- DT o persona que hizo la afirmación (Regla B29)
    method         TEXT,               -- extracción, síntesis LLM, entrevista, carga masiva
    validated_by   TEXT,               -- rol con autoridad (HITL). NULL si es gold por origen
    validated_at   TEXT,
    superseded_by  INTEGER,            -- id del registro que lo reemplaza (no se borra nada)
    notes          TEXT,
    -- Regla B40 — el brain es bi-temporal. Dos relojes que no se confunden:
    --   valid_from/valid_to = TIEMPO DEL NEGOCIO. Cuándo la afirmación fue verdad
    --     en la empresa. Lo pone el DT desde la fuente: fecha del commit, de la
    --     circular, del incidente, del cutover. valid_to NULL = sigue siendo verdad.
    --   recorded_at = TIEMPO DEL BRAIN. Cuándo el brain lo supo. Automático.
    -- La diferencia entre ambos mide la latencia real del brain frente a su empresa.
    valid_from     TEXT,               -- ISO date. NULL = verdad desde el origen del sistema
    valid_to       TEXT,               -- ISO date. NULL = sigue siendo verdad hoy
    recorded_at    TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_lineage_entity ON knowledge_lineage(entity_table, entity_id);
-- snapshot(date): valid_from <= date AND (valid_to IS NULL OR valid_to >= date)
CREATE INDEX IF NOT EXISTS ix_lineage_valid ON knowledge_lineage(valid_from, valid_to);

-- =============================================================================
-- SYSTEM — brains de sistema productivo (hemisphere='run')
-- Referencias: Informix (90MB), Banamex (122MB), Gentera, Coppel-ecommerce
-- =============================================================================

-- Homologa: sps (Informix) · services (AppMóvil) · objects (Gentera) ·
-- programs/inventario (Banamex) · platforms (Coppel).
CREATE TABLE IF NOT EXISTS components (
    id             TEXT PRIMARY KEY,   -- convención canónica: "{db}:{name}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name           TEXT NOT NULL,
    display_name   TEXT,
    description    TEXT,
    domain         TEXT,
    tipo           TEXT,               -- sp | program | object | service | table | api | job
    fan_in         INTEGER DEFAULT 0,
    fan_out        INTEGER DEFAULT 0,
    loc            INTEGER DEFAULT 0,

    -- De Informix: `is_soul` es COLUMNA, no tabla. La v1.0 del canon pedía una
    -- tabla `souls` que no existe en ningún brain del estate.
    is_soul        INTEGER DEFAULT 0,
    soul_rank      INTEGER,

    archetype      TEXT,               -- CTM_ENTRY|CTM_HINT|FILE_LOADER|DATA_MAINT
    primary_capability TEXT,           -- FK lógica a capabilities.id

    -- Migración. De Coppel (mejor modelado que migration_fate de Liverpool).
    current_platform  TEXT,
    target_platform   TEXT,
    migration_status  TEXT,
    -- Regla B24 — de qué transición de Change heredó Run este componente
    origin_transition_id TEXT,

    -- Provenance. De Liverpool/AXA (seeded_by + fill_quality).
    seeded_by      TEXT,
    fill_quality   TEXT,               -- complete | partial | stub
    source_doc     TEXT,
    status         TEXT DEFAULT 'active'
);

-- Grafo de llamadas. De Gentera (object_calls) e Informix (sp_calls).
-- Habilita flow_diagram(), callers_of(), callees_of(), impact_of().
CREATE TABLE IF NOT EXISTS component_calls (
    from_component TEXT NOT NULL,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    to_component   TEXT NOT NULL,
    cross_db       INTEGER DEFAULT 0,
    PRIMARY KEY (from_component, to_component)
);

-- Reglas de negocio.
-- La de Gentera es la mejor del estate: trazabilidad a nivel de LÍNEA.
-- Se le suma `clase` (Informix/Banamex) y `enrichment_method` (ADR-EB-004).
CREATE TABLE IF NOT EXISTS rules (
    id            TEXT PRIMARY KEY,    -- "{PREFIX}-{db}-{component}-{line}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    component_id  TEXT NOT NULL,
    linea         INTEGER,             -- línea exacta en el fuente (Gentera)
    tipo          TEXT,                -- FÓRMULA|VALIDACIÓN|UMBRAL|TRANSFORMACIÓN
    sub_tipo      TEXT,
    clase         TEXT NOT NULL,       -- NEGOCIO|INFRAESTRUCTURA|ENSAMBLAJE|PRESENTACION
    condicion     TEXT,
    fragmento     TEXT,                -- fragmento del código fuente, tal como se extrajo

    -- ADR-EB-004: sintetizado leyendo el fuente completo, nunca transcrito.
    business_name TEXT NOT NULL,
    description   TEXT,

    reg           TEXT NOT NULL,       -- '' válido = sin regulación; NULL = no revisado
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    riesgo        TEXT,                -- JSON array: MONEY|DIV|ROUND|FX|UDI
    source_file   TEXT,
    enrichment_method TEXT,
    confidence    TEXT,                -- confirmed | inferred | suspected
    domain        TEXT
);

-- Bitácora de enriquecimiento. De Informix (rule_enrichment_log, 22,425 filas).
-- Provenance campo-por-campo: quién cambió qué, cuándo y con qué método.
-- Es lo que hace auditable la síntesis LLM.
CREATE TABLE IF NOT EXISTS rule_enrichment_log (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_id    TEXT NOT NULL,
    swarm      TEXT,
    field      TEXT,
    old_value  TEXT,
    new_value  TEXT,
    method     TEXT,
    confidence TEXT,
    notes      TEXT,
    timestamp  TEXT
);

-- Vocabulario. Homologa: terms (Informix, Gentera) · vocab (MONEX, AXA,
-- Santander) · vocab_full/vocab_terms (Banamex) · vocabulary (Unity, Coppel).
-- Gana `vocabulary`: es el nombre que el canon ya declaraba y el que usan los
-- dos brains más recientes.
CREATE TABLE IF NOT EXISTS vocabulary (
    id            TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    term          TEXT NOT NULL,
    definition    TEXT,
    categoria     TEXT,
    scope         TEXT,                -- enterprise | system | domain
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    domain        TEXT,
    maturity      TEXT,                -- confirmed | proposed | deprecated
    source_system TEXT,
    aliases       TEXT,                -- JSON array
    est           TEXT                 -- 'resolved' tras conflicto (Regla V2)
);

-- Journeys — trazas REALES por el código, derivadas del call graph.
-- No confundir con `processes`: el proceso es el modelo de la industria (cómo
-- debería operar); el journey es lo que el sistema hace de hecho (entry point
-- → cadena de llamadas). La brecha entre ambos es hallazgo de negocio.
-- Informix las deriva de entry points; Banamex las modela como `flujos`.
CREATE TABLE IF NOT EXISTS journeys (
    id             TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    display_name   TEXT,
    description    TEXT,
    entry_component TEXT NOT NULL,     -- SP/programa de entrada
    call_depth     INTEGER,
    component_count INTEGER,
    domain         TEXT,
    cross_domains  TEXT,               -- JSON array
    process_id     TEXT,               -- FK lógica a processes.id — qué realiza
    capability_id  TEXT,
    systems        TEXT,               -- JSON array de slugs
    source_type    TEXT                -- ctm_entry|esb_exposed|channel|scheduled
);

CREATE TABLE IF NOT EXISTS component_capabilities (
    component_id TEXT NOT NULL,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    capability_id TEXT NOT NULL,
    mapping_type TEXT,                 -- primary | secondary | inferred
    source       TEXT,
    confidence   TEXT,
    PRIMARY KEY (component_id, capability_id)
);

-- Regla B22 — un componente sirve típicamente a varios procesos, así que su
-- trazabilidad es N:M en vez de columna. Un componente sin ningún proceso es
-- código cuyo propósito de negocio nadie estableció.
CREATE TABLE IF NOT EXISTS component_processes (
    component_id TEXT NOT NULL,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    process_id   TEXT NOT NULL,
    mapping_type TEXT,                 -- primary | secondary | inferred
    evidence     TEXT,                 -- journey, CTM, doc que sustenta el enlace
    confidence   TEXT,                 -- confirmed | inferred | suspected
    PRIMARY KEY (component_id, process_id)
);

-- Matriz CRUD aplicación-dato de TOGAF. Homologa Informix sp_table_refs.
-- Un componente que escribe una entidad personal o sensible hereda su regulación.
CREATE TABLE IF NOT EXISTS component_data (
    component_id TEXT NOT NULL,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    entity_id    TEXT NOT NULL,        -- FK lógica a data_entities.id
    access_type  TEXT,                 -- R | W | RW
    operations   TEXT,                 -- JSON array: SELECT | INSERT | UPDATE | DELETE
    cross_store  INTEGER DEFAULT 0,    -- la entidad vive en otro store (de is_cross_db)
    line_first   INTEGER,              -- primera línea del fuente donde aparece
    confidence   TEXT,                 -- confirmed | inferred | suspected
    PRIMARY KEY (component_id, entity_id)
);

-- Obligaciones regulatorias como tabla first-class, no como anotación.
-- Convergencia espontánea Informix + CAN + Santander → canon.
CREATE TABLE IF NOT EXISTS regulatory_obligations (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    regulator       TEXT NOT NULL,
    instrument      TEXT,
    article         TEXT,
    description     TEXT,
    obligation_type TEXT,
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    rol_aplicable   TEXT,              -- de Santander CAN: regla por rol de actor
    frequency       TEXT,
    penalty_risk    TEXT,
    effective_date  TEXT
);

-- Sistemas externos observados (endpoints, tasas de error, timeouts).
CREATE TABLE IF NOT EXISTS external_systems (
    id              TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    name            TEXT,
    description     TEXT,
    system_type     TEXT,
    total_endpoints INTEGER DEFAULT 0,
    error_codes     TEXT,              -- JSON array
    failure_rate    REAL,
    timeout_ms      INTEGER,
    regulation      TEXT
);


-- =============================================================================
-- PROJECT — brains de proyecto de transformación (hemisphere='change')
-- Referencias: Exodus, Unity, CAN (BanCoppel + Santander), payments-modernization
--
-- Los brains de proyecto NO tienen components/rules: su ontología es
-- applications/waves/risks/decisions. Esto NO es divergencia a corregir —
-- 4 brains independientes convergieron en ella.
-- =============================================================================

CREATE TABLE IF NOT EXISTS applications (
    id            TEXT PRIMARY KEY,    -- convención: "{wave}::{app_id}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    app_id        TEXT,
    name          TEXT NOT NULL,
    wave_id       TEXT,
    criticality   TEXT,
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    complexity    TEXT,
    hosting       TEXT,
    description   TEXT,
    migration_approach TEXT,           -- 7R: rehost|replatform|refactor|...
    component_count INTEGER DEFAULT 0,
    source_doc    TEXT
);

CREATE TABLE IF NOT EXISTS waves (
    id                TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    seq               INTEGER,
    title             TEXT NOT NULL,
    horizon           TEXT,
    objective         TEXT,
    executive_summary TEXT,
    app_count         INTEGER DEFAULT 0,
    source_doc        TEXT
);

CREATE TABLE IF NOT EXISTS risks (
    id          TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    title       TEXT NOT NULL,
    category    TEXT,
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    severity    TEXT,
    probability TEXT,
    description TEXT,
    mitigation  TEXT,
    owner       TEXT,
    related     TEXT,                  -- JSON array
    -- Regla B24 — hallazgo de Run que originó este riesgo
    origin_finding_id TEXT,
    status      TEXT DEFAULT 'open'
);

-- ADR dentro del brain. Convergencia Coppel + Unity + Santander CAN.
CREATE TABLE IF NOT EXISTS decisions (
    id          TEXT PRIMARY KEY,      -- "ADR-{SLUG}-{NNN}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    date        TEXT,
    title       TEXT NOT NULL,
    context     TEXT,
    decision    TEXT,
    alternatives TEXT,
    consequences TEXT,
    status      TEXT,                  -- propuesto | aprobado | superseded
    domain      TEXT
);

CREATE TABLE IF NOT EXISTS user_stories (
    id           TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    title        TEXT NOT NULL,
    description  TEXT,
    capability_id TEXT,
    obligation_id TEXT,
    priority     TEXT,
    -- Regla B22 — todo conocimiento ata a un proceso de negocio
    process_id    TEXT,
    estimate     TEXT,
    -- Regla B24 — hallazgo de Run que originó esta story
    origin_finding_id TEXT,
    status       TEXT
);


-- =============================================================================
-- ENTERPRISE — bank-brain / {cliente}-brain (brain_type='enterprise')
-- Referencias: BanCoppel bank-brain, MONEX, Liverpool, AXA, Santander
-- =============================================================================

-- Registro de brains federados. De MONEX (la mejor implementación del patrón)
-- + Liverpool (attach real) + AXA (brain_attached como control de salud).
CREATE TABLE IF NOT EXISTS federated_brains (
    slug           TEXT PRIMARY KEY,
    display_name   TEXT NOT NULL,
    brain_type     TEXT NOT NULL,      -- project | system
    hemisphere     TEXT NOT NULL,      -- change | run
    togaf_type     TEXT,
    togaf_state    TEXT,
    brain_path     TEXT NOT NULL,      -- ruta relativa al brain.db
    brain_attached INTEGER DEFAULT 0,  -- 1 = ATTACH exitoso en el último build
    status         TEXT,               -- SCAFFOLD | SEEDED | ACTIVE
    last_built_at  TEXT,
    component_count INTEGER DEFAULT 0,
    rule_count     INTEGER DEFAULT 0
);

-- Corpus documental del cliente + red de seguridad de cero pérdida.
-- De Banamex (kb_documents + kb_fts, 283 docs): el texto crudo completo
-- indexado garantiza que nada del corpus se pierde en la destilación.
CREATE TABLE IF NOT EXISTS documents (
    path      TEXT PRIMARY KEY,
    filename  TEXT,
    categoria TEXT,
    n_lineas  INTEGER,
    contenido TEXT
);


-- =============================================================================
-- PUENTE CHANGE–RUN (cuerpo calloso) — Regla B24 · ADR-EB-008
--
-- Une los dos hemisferios. Cada brain declara SU lado del puente desde su
-- propia perspectiva (Regla B1); el cruce lo razona el enterprise brain vía
-- ATTACH (templates/callosum.py). Nada se copia entre brains.
--
--   Change → Run   plateaus · transitions · readiness_gates   (brain de proyecto)
--   Run → Change   findings con ruteo                          (brain de sistema)
--   Ambos lados    slos — Change compromete el objetivo, Run mide el actual
--
-- Destilado de: bank-brain.migrations (11,391) · Unity informix_migration_map,
-- capability_routing, coexistence_rules, capability_prr, capability_slos ·
-- Exodus ams_support_proposal · Coppel platform_capabilities, slos ·
-- Banamex sevenr_decisions, hallazgos · Informix tribal_knowledge ·
-- Liverpool ticket_recurrence · AXA pain_points.
-- =============================================================================

-- Estados de la arquitectura (ArchiMate: plateau). Mapean a togaf_state:
-- as_is = baseline · transition = transitional · to_be = target.
-- De Unity/bank-brain (releases R2, R4) y Exodus (waves W1..Wn).
CREATE TABLE IF NOT EXISTS plateaus (
    id            TEXT PRIMARY KEY,    -- "PL-{slug}-{n}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    kind          TEXT NOT NULL,       -- as_is | transition | to_be
    seq           INTEGER,
    name          TEXT NOT NULL,       -- "R4 · TDC P4900 en SmartVista"
    wave_id       TEXT,                -- FK lógica a waves.id
    release       TEXT,
    target_date   TEXT,
    reached_date  TEXT,
    status        TEXT DEFAULT 'planned',  -- planned | in_progress | reached
    description   TEXT
);

-- Lado Change del puente: qué se mueve, de dónde, a dónde y cómo.
-- `to_system` / `from_system` son slugs de brains de Run: es la llave con que
-- el enterprise brain encuentra al brain que hereda la transición.
CREATE TABLE IF NOT EXISTS transitions (
    id               TEXT PRIMARY KEY, -- "TR-{slug}-{nnn}"
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    entity_type      TEXT NOT NULL,    -- capability | component | domain | application | product
    entity_id        TEXT NOT NULL,
    capability_id    TEXT,
    -- Regla B22
    process_id       TEXT,
    from_system      TEXT NOT NULL,    -- brain de Run que hoy lo opera
    to_system        TEXT NOT NULL,    -- brain de Run que lo heredará
    plateau_id       TEXT NOT NULL,    -- en qué estado de arquitectura ocurre

    -- Destino canónico (7R + encapsulate). `fate_source` preserva el valor
    -- original: "replaces" (Unity), "ENCAPSULATE" (Banamex), "Migrar
    -- (Transformar)" (Exodus APO).
    fate             TEXT NOT NULL,    -- retain|retire|rehost|replatform|refactor|rearchitect|replace|encapsulate
    fate_source      TEXT,
    pattern          TEXT,             -- strangler-fig | big-bang | phased | parallel-run

    -- Coexistencia y ruteo. De Unity capability_routing + coexistence_rules.
    pre_route        TEXT,
    post_route       TEXT,
    switch_mechanism TEXT,             -- feature_flag | dns | config | cutover_window
    parallel_run     INTEGER DEFAULT 0,
    coexistence_rule TEXT,             -- condición que decide qué ruta aplica

    -- Quién opera después del cutover. De Exodus ams_support_proposal.
    -- Sin run_owner, Run no sabe que hereda algo.
    run_owner        TEXT,
    run_service_type TEXT,             -- AMS-dev | AMS-ops | in-house | vendor
    run_coverage     TEXT,             -- full | high | partial

    status           TEXT NOT NULL DEFAULT 'planned',
                                       -- planned|in_progress|coexisting|cutover|done|cancelled
    confidence       TEXT,             -- confirmed | inferred | suspected
    evidence         TEXT,
    origin_artifact  TEXT,
    updated_at       TEXT
);

-- Gates de readiness operativa: lo que Run exige antes de heredar.
-- De Unity capability_prr, normalizado de columnas a filas para que cada
-- gate tenga evidencia, aprobador y fecha propios.
CREATE TABLE IF NOT EXISTS readiness_gates (
    transition_id TEXT NOT NULL,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    gate          TEXT NOT NULL,       -- runbook|oncall|slo|rollback|drp|test|knowledge|prr
    status        TEXT NOT NULL DEFAULT 'pending',  -- pending | done | waived | blocked
    blocker       TEXT,
    evidence      TEXT,
    approved_by   TEXT,
    approved_at   TEXT,
    PRIMARY KEY (transition_id, gate)
);

-- El objeto que vive en ambos hemisferios: Change fija `target` al diseñar,
-- Run mide `current` al operar. Un SLO sin current es promesa; sin target es
-- medición sin contrato. De Unity capability_slos y Coppel slos.
CREATE TABLE IF NOT EXISTS slos (
    id             TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    capability_id  TEXT,
    transition_id  TEXT,
    process_id     TEXT,
    -- Regla B36 — el SLO de TI declara el KPI de negocio que habilita; así se cierra el círculo
    kpi_id         TEXT,
    metric         TEXT NOT NULL,      -- availability | latency_p95 | error_rate | mttr | tps
    target         TEXT,
    current        TEXT,
    unit           TEXT,
    window         TEXT,
    status         TEXT DEFAULT 'pending',  -- pending | met | breaching | unknown
    committed_by   TEXT,               -- brain/rol que fijó el target (Change)
    measured_by    TEXT,               -- brain/fuente que mide el current (Run)
    measured_at    TEXT
);

-- Lado Run del puente: lo que la operación aprende y Change debe saber.
-- Homologa tribal_knowledge (Informix) · hallazgos (Banamex) · audit_findings
-- (Unity) · pain_points (AXA) · ticket_recurrence (Liverpool).
-- Un hallazgo que toca algo en transición y no se rutea es ruptura del puente.
CREATE TABLE IF NOT EXISTS findings (
    id               TEXT PRIMARY KEY,
    tier           TEXT NOT NULL DEFAULT 'bronze',  -- Regla B37: gold | silver | bronze | rejected
    finding_type     TEXT NOT NULL,    -- incident_pattern|performance_pattern|recurrence|
                                       -- tech_debt|capacity|data_quality|pain_point|tribal
    title            TEXT NOT NULL,
    description      TEXT,
    impact_if_ignored TEXT,            -- de Informix impact_if_lost
    severity         TEXT NOT NULL,    -- blocker | critical | high | medium | low
    severity_source  TEXT,             -- valor original ("BLOQUEADOR", "Alta")
    entity_type      TEXT,             -- component | domain | capability | application
    entity_ids       TEXT,             -- JSON array (de Informix sp_keys)
    domain           TEXT,
    capability_id    TEXT,
    -- Regla B22
    process_id       TEXT,
    occurrences      INTEGER,          -- de Liverpool ticket_recurrence
    first_seen       TEXT,
    last_seen        TEXT,
    recommended_action TEXT,
    discovered_from  TEXT,
    discovered_at    TEXT,
    validated_by     TEXT,
    confidence       TEXT,             -- confirmed | inferred | suspected

    -- Ruteo hacia Change. `routed_ref` es el id de la user story o riesgo que
    -- el brain de proyecto creó; el enterprise brain verifica que exista.
    routed_to_brain  TEXT,             -- slug del brain de proyecto
    -- Regla B38 — hallazgo que corrige el registro de una herramienta dedicada
    -- (por ejemplo, un CI de la CMDB que no coincide con lo observado).
    routed_to_tool   TEXT,             -- FK lógica a technology_components.id (category='it_tool')
    routed_ref       TEXT,
    route_status     TEXT NOT NULL DEFAULT 'open'
                                       -- open | routed | accepted | rejected | resolved
);


-- =============================================================================
-- FTS5 — índices de búsqueda
-- Se crean solo para las tablas que el brain realmente puebla.
-- =============================================================================

CREATE VIRTUAL TABLE IF NOT EXISTS rules_fts
    USING fts5(id, business_name, description, fragmento);

CREATE VIRTUAL TABLE IF NOT EXISTS vocabulary_fts
    USING fts5(id, term, definition);

CREATE VIRTUAL TABLE IF NOT EXISTS components_fts
    USING fts5(id, name, display_name, description);

CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts
    USING fts5(path, filename, contenido);

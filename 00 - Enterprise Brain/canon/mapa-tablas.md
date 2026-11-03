# Mapa de tablas del canon

> Generado el 2026-11-03 por `canon/build-mapa-tablas.py` desde `templates/schema.sql`. **No editar a mano**: se regenera.

El canon son **46 tablas**. Ningún brain las implementa todas: implementa el CORE más la extensión que le corresponde por su `brain_type`, más su lado del puente (Reglas B14 y B15).

## Resumen por capa

| Capa | Tablas | A quién aplica |
|------|--------|----------------|
| **CORE** | 23 | Todo brain, sin excepción |
| **SYSTEM** | 11 | `brain_type='system'`, sistemas en operación |
| **PROJECT** | 5 | `brain_type='project'`, proyectos de transformación |
| **ENTERPRISE** | 2 | `brain_type='enterprise'`, el brain de nivel cliente |
| **PUENTE** | 5 | Cada hemisferio implementa su lado (Regla B24) |

---

## Las tablas, por capa

### CORE

| Tabla | Dueño | Columnas | Reglas | Se relaciona con |
|-------|-------|----------|--------|------------------|
| `system_info` | `dt-domain-architect` | 20 | B13 B14 B18 B23 B29 B31 | — |
| `cross_dependencies` | `dt-asset-configuration-manager` | 12 | B37 | — |
| `signals` | `dt-service-operations-lead` | 5 | — | — |
| `ontology_bindings` | `dt-domain-architect` | 10 | B21 | — |
| `capabilities` | `dt-domain-architect` | 17 | B22 B37 | `ontology_bindings`, `processes` |
| `processes` | `dt-demand-manager` | 14 | B37 | `capabilities` |
| `knowledge_gaps` | `dt-knowledge-manager` | 13 | B22 | `processes` |
| `itom_layer` | `dt-domain-architect` | 9 | B22 B37 | `processes` |
| `products` | `dt-demand-manager` | 13 | B37 | `processes` |
| `kpis` | `dt-demand-manager` | 14 | B37 | `processes`, `products` |
| `stakeholders` | `dt-knowledge-manager` | 15 | B37 | `capabilities` |
| `data_entities` | `dt-information-architect` | 13 | B30 B37 B42 | `stakeholders`, `technology_components` |
| `technology_components` | `dt-asset-configuration-manager` | 16 | B36 B37 B38 | `itom_layer` |
| `suppliers` | `dt-supplier-relationship-manager` | 17 | B22 B30 B37 B38 B39 | `itom_layer`, `processes`, `slos` |
| `measurements` | `dt-service-operations-lead` | 15 | B22 B37 B40 | `kpis`, `processes` |
| `costs` | `dt-demand-manager` | 16 | B22 B27 B37 | `kpis`, `processes`, `products` |
| `queries` | `dt-knowledge-manager` | 15 | B17 B27 B35 B37 B42 B43 | `decisions` |
| `knowledge_lineage` | `dt-knowledge-manager` | 19 | B29 B40 B42 | — |
| `source_catalog` | `dt-source-steward` | 13 | — | — |
| `company_profile` | `dt-client-intelligence` | 13 | B37 | — |
| `business_milestones` | `dt-client-intelligence` | 8 | B37 | — |
| `strategic_drivers` | `dt-client-intelligence` | 10 | B37 | — |
| `driver_links` | `dt-client-intelligence` | 8 | B37 | — |

### SYSTEM

| Tabla | Dueño | Columnas | Reglas | Se relaciona con |
|-------|-------|----------|--------|------------------|
| `components` | `dt-asset-configuration-manager` | 22 | B24 B37 | `capabilities` |
| `component_calls` | `dt-asset-configuration-manager` | 4 | B37 | — |
| `rules` | `dt-asset-configuration-manager` | 18 | B22 B37 | `components`, `processes` |
| `rule_enrichment_log` | `dt-knowledge-manager` | 10 | — | `rules` |
| `vocabulary` | `dt-information-architect` | 12 | B22 B37 | `processes` |
| `journeys` | `dt-demand-manager` | 13 | B37 | `processes` |
| `component_capabilities` | `dt-asset-configuration-manager` | 6 | B37 | `components` |
| `component_processes` | `dt-asset-configuration-manager` | 6 | B37 | `components`, `processes` |
| `component_data` | `dt-information-architect` | 8 | B37 | `components`, `data_entities` |
| `regulatory_obligations` | `dt-it-risk-manager` | 12 | B22 B37 | `processes` |
| `external_systems` | `dt-asset-configuration-manager` | 10 | B37 | — |

### PROJECT

| Tabla | Dueño | Columnas | Reglas | Se relaciona con |
|-------|-------|----------|--------|------------------|
| `applications` | `dt-programme-manager` | 13 | B22 B37 | `processes`, `waves` |
| `waves` | `dt-programme-manager` | 9 | B37 | — |
| `risks` | `dt-it-risk-manager` | 13 | B22 B24 B37 | `processes` |
| `decisions` | `dt-domain-architect` | 20 | B37 B39 B40 B43 | `queries` |
| `user_stories` | `dt-programme-manager` | 11 | B22 B24 B37 | `processes` |

### ENTERPRISE

| Tabla | Dueño | Columnas | Reglas | Se relaciona con |
|-------|-------|----------|--------|------------------|
| `federated_brains` | `dt-domain-architect` | 12 | — | — |
| `documents` | `dt-knowledge-manager` | 5 | — | — |

### PUENTE

| Tabla | Dueño | Columnas | Reglas | Se relaciona con |
|-------|-------|----------|--------|------------------|
| `plateaus` | `dt-domain-architect` | 11 | B37 | `waves` |
| `transitions` | `dt-change-manager` | 25 | B22 B37 | `plateaus`, `processes` |
| `readiness_gates` | `dt-change-manager` | 8 | B37 | `transitions` |
| `slos` | `dt-change-manager` | 15 | B36 B37 | `kpis`, `processes`, `transitions` |
| `findings` | `dt-service-operations-lead` | 25 | B22 B37 B38 | `processes`, `technology_components` |

---

## Vista por cadena de valor (Regla B27)

El conocimiento técnico se ancla en la cadena del negocio. Un componente que no se puede trazar hasta un producto y un KPI es conocimiento muerto.

**Productos** — *¿Qué ofrece el negocio al mercado?*  
  `products`

**KPIs** — *¿Cómo se mide el éxito de cada producto?*  
  `kpis`

**Procesos** — *¿Cómo opera el negocio para entregarlo?*  
  `processes`, `journeys`

**Aplicaciones** — *¿Qué sistemas realizan esos procesos?*  
  `components`, `component_calls`, `applications`, `external_systems`, `component_capabilities`, `component_processes`, `rules`

**Infraestructura** — *¿Qué plataformas los sostienen?*  
  `technology_components`, `suppliers`

**Datos** — *¿Qué entidades de información consumen y producen?*  
  `data_entities`, `component_data`

**Fuera de la cadena** — gobierno, ontología, federación y calidad  
  `business_milestones`, `capabilities`, `company_profile`, `costs`, `cross_dependencies`, `decisions`, `documents`, `driver_links`, `federated_brains`, `findings`, `itom_layer`, `knowledge_gaps`, `knowledge_lineage`, `measurements`, `ontology_bindings`, `plateaus`, `queries`, `readiness_gates`, `regulatory_obligations`, `risks`, `rule_enrichment_log`, `signals`, `slos`, `source_catalog`, `stakeholders`, `strategic_drivers`, `system_info`, `transitions`, `user_stories`, `vocabulary`, `waves`

---

## Detalle de cada tabla

### `system_info`

**Capa**: CORE, **Dueño**: `dt-domain-architect`, **Reglas**: B13 B14 B18 B23 B29 B31

Identidad del brain. Homologa 5 nombres en uso: system_info (MONEX scaffolds, AppMóvil), project_info (Unity, Coppel), program_info (Exodus), brain_meta (CAN, Liverpool, AXA, Santander), hemisphere_meta (Informix). Gana `system_in

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `slug` (PK) | TEXT | no |  |
| `display_name` | TEXT | sí |  |
| `brain_type` | TEXT | sí |  |
| `hemisphere` | TEXT | sí |  |
| `togaf_type` | TEXT | no |  |
| `togaf_state` | TEXT | no | baseline ,  transitional ,  target |
| `togaf_abb` | TEXT | no |  |
| `industry` | TEXT | sí |  |
| `industry_sme` | TEXT | no | "SME/Industry/Industry Retail" |
| `capability_model` | TEXT | no |  |
| `process_ontology` | TEXT | no |  |
| `process_ontology_version` | TEXT | no |  |
| `itom_model` | TEXT | no |  |
| `itom_sme` | TEXT | no | "SME/Framework/IT Operating Model" |
| `lob_dimension` | TEXT | no |  |
| `version` | TEXT | no | SemVer del brain |
| `status` | TEXT | sí | discovered, seeded, building, active, stale, archived |
| `built_at` | TEXT | no | ISO datetime del último build |
| `source_of_truth` | TEXT | no | ruta del corpus fuente (Regla B31 — obligatoria) |
| `build_agent` | TEXT | no | DT que construyó el brain (Regla B29 — trazabilidad) |

### `cross_dependencies`

**Capa**: CORE, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B37

Contrato de federación. Es la ÚNICA tabla presente en prácticamente todo el estate y por tanto el contrato de interoperabilidad real. Homologa 3 firmas incompatibles: Informix : other_system + dependency_type + evidence AppMóvil :

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `other_system` | TEXT | sí |  |
| `dependency_type` | TEXT | no | orchestrates, calls, reads, writes, feeds, notifies |
| `direction` | TEXT | sí | inbound ,  outbound |
| `volume` | INTEGER | no |  |
| `domains` | TEXT | no | JSON array |
| `regulation` | TEXT | no | JSON array |
| `description` | TEXT | no |  |
| `criticality` | TEXT | no | critical ,  high ,  medium ,  low |
| `evidence` | TEXT | no |  |
| `origin_artifact` | TEXT | no |  |

### `signals`

**Capa**: CORE, **Dueño**: `dt-service-operations-lead`

Bus de señales entre brains. De AppMóvil: `emit_signals()` al cierre del pipeline. Es lo único que comparten los 33 brains de systems/ de BanCoppel, así que ya es canon de facto.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | INTEGER | no |  |
| `signal` | TEXT | sí |  |
| `value` | TEXT | no |  |
| `source` | TEXT | no |  |
| `ts` | TEXT | sí |  |

### `ontology_bindings`

**Capa**: CORE, **Dueño**: `dt-domain-architect`, **Reglas**: B21

Composición de ontologías de la empresa (ADR-EB-007 · Regla B20).  Toda empresa tiene su PROPIA ontología, compuesta de los ETB de las industrias que le corresponden más sus extensiones propias. La multi-industria es la norma, no 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `ontology` (PK) | TEXT | no | retail ,  financial_services ,  insurance |
| `role` | TEXT | sí | primary ,  secondary |
| `model_type` | TEXT | sí |  |
| `catalog` | TEXT | no | "Retail_ETB_V4" · "BIAN v14" · "Circular 6/2025" |
| `catalog_version` | TEXT | no |  |
| `industry_sme` | TEXT | no | "SME/Industry/Industry Retail" |
| `regulators` | TEXT | no | JSON array — cada ontología trae los suyos |
| `l3_base` | INTEGER | no | capabilities del catálogo base |
| `l3_extension` | INTEGER | no | extensiones propias de la empresa |
| `rationale` | TEXT | no | por qué este modelo aplica a esta empresa |

### `capabilities`

**Capa**: CORE, **Dueño**: `dt-domain-architect`, **Reglas**: B22 B37

Ontología de negocio del brain — OBLIGATORIA en todo brain (Regla B21).  Todo brain, sea de sistema, proyecto o enterprise, ancla su ontología de negocio a un ETB o a otro modelo lógico del negocio. Sin ancla, un brain acumula hal

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `ontology` | TEXT | sí | retail ,  financial_services ,  banking ,  insurance |
| `ontology_version` | TEXT | no |  |
| `catalog_source` | TEXT | no | "Retail_ETB_V4" ,  "Newly Added" |
| `is_extension` | INTEGER | no |  |
| `l1_name` | TEXT | no |  |
| `l2_name` | TEXT | no |  |
| `l3_name` | TEXT | no |  |
| `definition` | TEXT | no |  |
| `regulation` | TEXT | no | JSON array |
| `coverage_status` | TEXT | no | COVERED, PARTIAL, CROSS_CUTTING, NOT_COVERED |
| `process_id` | TEXT | no |  |
| `coverage_confidence` | TEXT | no | high ,  medium ,  low (de Liverpool) |
| `coverage_evidence` | TEXT | no |  |
| `primary_system` | TEXT | no |  |
| `component_count` | INTEGER | no |  |

**Se relaciona con**: `ontology_bindings` (por `ontology`), `processes` (por `process_id`)

### `processes`

**Capa**: CORE, **Dueño**: `dt-demand-manager`, **Reglas**: B37

Ontología de PROCESOS de la industria. Distinta de `capabilities` y distinta de `journeys`: capabilities → qué sabe hacer el negocio (modelo de capacidades) processes    → cómo opera, según la ontología de SU industria (este model

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `ontology` | TEXT | sí | banca-etb ,  pc-etb ,  life-etb ,  retail-valuechain |
| `ontology_version` | TEXT | no |  |
| `lob` | TEXT | no |  |
| `l1_name` | TEXT | no | Captación · Suscripción · PLAN |
| `l2_name` | TEXT | no | fase |
| `l3_name` | TEXT | no | etapa |
| `l4_name` | TEXT | no | paso |
| `description` | TEXT | no |  |
| `capability_id` | TEXT | no | FK lógica a capabilities.id (de AXA) |
| `systems` | TEXT | no | JSON array de slugs que lo ejecutan |
| `coverage_status` | TEXT | no | COVERED ,  PARTIAL ,  NOT_COVERED |
| `source_sme` | TEXT | no | Industry SME que suministró el modelo |

**Se relaciona con**: `capabilities` (por `id`)

### `knowledge_gaps`

**Capa**: CORE, **Dueño**: `dt-knowledge-manager`, **Reglas**: B22

El brain como su propio backlog. De Informix (knowledge_gaps + vista knowledge_completeness), Exodus (open_questions) y Banamex (traceability_unresolved) — tres brains llegaron al mismo concepto por su cuenta, señal fuerte de cano

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `gap_type` | TEXT | no | dato ,  decisión ,  acceso ,  validación |
| `dimension` | TEXT | no | negocio ,  tecnología ,  regulatoria ,  cultural |
| `domain` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `description` | TEXT | sí |  |
| `impact` | TEXT | no |  |
| `required_for` | TEXT | no | fase/gate que bloquea |
| `resolution_action` | TEXT | no | "Consulta {SME}: {pregunta concreta}" |
| `owner` | TEXT | no |  |
| `status` | TEXT | no | open ,  resolved ,  accepted |
| `opened_at` | TEXT | no |  |
| `resolved_at` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `itom_layer`

**Capa**: CORE, **Dueño**: `dt-domain-architect`, **Reglas**: B22 B37

Ontología de IT Operating Model — cómo se entrega y opera el IT que soporta el negocio. Los 6 dominios canónicos y sus sub-capacidades los define el SME "SME/Framework/IT Operating Model" (ITOM v9.0 + marco conceptual 2024-2027). 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `layer` | TEXT | sí | dominio ITOM canónico (ver arriba) |
| `technology` | TEXT | no | sub-capacidad slug del dominio |
| `maturity` | INTEGER | no | 1-5 (IT OM Maturity Framework) |
| `coverage_status` | TEXT | no | covered ,  partial ,  gap |
| `evidence` | TEXT | no | artifact o fuente que lo sustenta |
| `process_id` | TEXT | no | B22 — ata a proceso de negocio |
| `itom_sme` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `products`

**Capa**: CORE, **Dueño**: `dt-demand-manager`, **Reglas**: B37

Catálogo de productos del cliente (Regla B27 — orientación a producto y KPI). Los productos son el punto de partida de la cadena de valor: Producto → KPI → Proceso → Aplicación → Infraestructura → Dato El brain no puede responder 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `product_type` | TEXT | no | cuenta ,  credito ,  seguro ,  pago ,  inversion ,  … |
| `product_line` | TEXT | no | línea de negocio (retail, banca-personas, etc.) |
| `status` | TEXT | no | active ,  deprecated ,  planned |
| `channel` | TEXT | no | digital ,  sucursal ,  telefono ,  all |
| `process_id` | TEXT | no | FK lógica a processes.id (proceso principal) |
| `regulation` | TEXT | no | JSON array de reguladores aplicables |
| `owner_domain` | TEXT | no | dominio de negocio propietario |
| `launched_at` | TEXT | no | ISO date de lanzamiento al mercado |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `kpis`

**Capa**: CORE, **Dueño**: `dt-demand-manager`, **Reglas**: B37

KPIs del negocio vinculados a productos y procesos (Regla B27). Change fija el target; Run mide el current. Patrón análogo a slos del puente pero a nivel de producto de negocio, no de transición de migración. Dominio B de TOGAF. L

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `product_id` | TEXT | sí | FK a products.id |
| `name` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `metric_type` | TEXT | no | volumen ,  tasa ,  tiempo ,  calidad ,  financiero |
| `unit` | TEXT | no | %, MXN, dias, txs/seg, NPS |
| `target` | TEXT | no | valor objetivo (lo fija Change/negocio) |
| `current` | TEXT | no | valor actual medido (lo registra Run/operación) |
| `frequency` | TEXT | no | diario ,  mensual ,  trimestral |
| `process_id` | TEXT | no | FK a processes.id — qué proceso mueve este KPI |
| `data_source` | TEXT | no | sistema/tabla/campo que lo alimenta |
| `owner` | TEXT | no |  |
| `status` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`), `products` (por `product_id`)

### `stakeholders`

**Capa**: CORE, **Dueño**: `dt-knowledge-manager`, **Reglas**: B37

Stakeholders: quién decide, quién opera y a quién le importa (dominio B de TOGAF). Destilado de 3 brains: Unity (capability_stakeholders, program_stakeholders), Coppel (stakeholders) y Santander CAN (team_roles). ADR-EB-009. Los p

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "STK-{nnn}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | sí | unidad, equipo, rol o persona |
| `stakeholder_type` | TEXT | no | executive_sponsor ,  business_owner ,  it_owner ,  operations ,  vendor ,  regulator ,  acn_sme |
| `organization` | TEXT | no | cliente, grupo, proveedor, Accenture |
| `role` | TEXT | no | rol en el programa o en la operación |
| `area` | TEXT | no | unidad organizacional |
| `raci` | TEXT | no | responsible ,  accountable ,  consulted ,  informed |
| `influence` | TEXT | no | high ,  medium ,  low |
| `concern` | TEXT | no | qué le importa: el viewpoint TOGAF que necesita |
| `capability_id` | TEXT | no | FK lógica a capabilities.id |
| `hemisphere` | TEXT | no | change ,  run ,  both |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |
| `active` | INTEGER | no |  |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `capabilities` (por `id`)

### `data_entities`

**Capa**: CORE, **Dueño**: `dt-information-architect`, **Reglas**: B30 B37 B42

Entidades de datos (dominio D de TOGAF). Eslabón Datos de la cadena B27. Destilado de Informix sp_table_refs (200,761 referencias de SP a tabla). ADR-EB-009. La operación de estos datos la describe ITOM (information-analytics); TO

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | convención: "{store}:{name}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | sí | nombre físico (tabla, colección, archivo) |
| `business_name` | TEXT | no | nombre de negocio (Regla B30) |
| `description` | TEXT | no |  |
| `entity_level` | TEXT | no | conceptual ,  logical ,  physical |
| `store` | TEXT | no | base de datos o esquema que la contiene |
| `technology_id` | TEXT | no | FK lógica a technology_components.id |
| `classification` | TEXT | no | public ,  internal ,  confidential ,  personal ,  sensitive |
| `regulation` | TEXT | no | JSON array: LFPDPPP, secreto bancario, PCI-DSS |
| `owner_id` | TEXT | no | FK lógica a stakeholders.id (data owner) |
| `row_count` | INTEGER | no |  |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `stakeholders` (por `id`), `technology_components` (por `id`)

### `technology_components`

**Capa**: CORE, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B36 B37 B38

Componentes tecnológicos (dominio T de TOGAF). Eslabón Infraestructura de B27. Destilado de Coppel platforms y de components.current_platform. ADR-EB-009. No confundir con itom_layer: ITOM describe CÓMO opera TI; esta tabla, QUÉ o

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | sí | "IBM Informix IDS" · "HCL Commerce" |
| `category` | TEXT | no | dbms ,  os ,  hardware ,  middleware ,  runtime ,  platform ,  cloud_service ,  saas ,  network ,  it_to |
| `record_scope` | TEXT | no | cmdb ,  test_automation ,  observability ,  itsm ,  code_repo ,  backlog ,  scheduler |
| `vendor` | TEXT | no |  |
| `version` | TEXT | no |  |
| `hosting` | TEXT | no | on_prem ,  cloud ,  hybrid ,  saas |
| `location` | TEXT | no | data center, región o proyecto cloud |
| `status` | TEXT | no | active ,  migrating ,  retiring ,  retired ,  planned |
| `support_status` | TEXT | no | supported ,  extended ,  end_of_support ,  unknown |
| `end_of_support` | TEXT | no | ISO date |
| `standard_status` | TEXT | no | standard ,  tolerated ,  sunset ,  prohibited (Standards Information Base) |
| `itom_layer_id` | TEXT | no | FK lógica a itom_layer.id: capacidad de TI que lo opera (B36) |
| `description` | TEXT | no |  |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `itom_layer` (por `itom_layer_id`)

### `suppliers`

**Capa**: CORE, **Dueño**: `dt-supplier-relationship-manager`, **Reglas**: B22 B30 B37 B38 B39

Proveedores y socios estratégicos (Regla B41 · ADR-EB-011). Dueño: `dt-supplier-relationship-manager`. Cierra los procesos ITOM 4 (Commercial Services Management) y 5 (Strategic Partner Management), los únicos dos del catálogo de 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37 |
| `name` | TEXT | sí |  |
| `business_name` | TEXT | no | Regla B30: nombre en el idioma del negocio |
| `kind` | TEXT | no | strategic_partner ,  service_provider ,  software_vendor ,  |
| `criticality` | TEXT | no | critical ,  high ,  medium ,  low |
| `regulatory_flag` | INTEGER | no | 1 = su criticidad tiene implicación ante el regulador |
| `contract_ref` | TEXT | no | referencia al contrato; el documento no se copia (B38) |
| `contract_end` | TEXT | no | ISO date |
| `slo_id` | TEXT | no | FK lógica a slos.id: contra qué SLO medido se evalúa |
| `exit_plan` | TEXT | no | qué pasa si sale. NULL en crítico es hallazgo |
| `process_id` | TEXT | no | Regla B22: proceso de negocio que habilita |
| `itom_layer_id` | TEXT | no | capacidad de TI que el proveedor opera |
| `status` | TEXT | no | active ,  onboarding ,  exiting ,  exited |
| `owner_role` | TEXT | no | rol accountable en stakeholders (Regla B39) |
| `description` | TEXT | no |  |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `itom_layer` (por `itom_layer_id`), `processes` (por `process_id`), `slos` (por `slo_id`)

### `measurements`

**Capa**: CORE, **Dueño**: `dt-service-operations-lead`, **Reglas**: B22 B37 B40

Serie de medición (Regla B43 · ADR-EB-012). Tercer fundamento del CORE: una regla vigente exige una capacidad que ninguna tabla sostenía. `kpis.current` y `slos.current` guardan el valor VIGENTE, que es lo que casi toda consulta n

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | INTEGER | no |  |
| `tier` | TEXT | sí | Regla B37 |
| `entity_table` | TEXT | sí | kpis ,  slos ,  technology_components ,  components |
| `entity_id` | TEXT | sí |  |
| `metric` | TEXT | no | cuando la entidad mide varias cosas |
| `value_num` | REAL | no | valor numérico, el caso normal |
| `value_text` | TEXT | no | cuando la medición no es numérica |
| `unit` | TEXT | no | %, ms, MXN, transacciones, GB |
| `measured_at` | TEXT | sí | ISO date o datetime |
| `period_start` | TEXT | no | para métricas de ventana |
| `period_end` | TEXT | no |  |
| `source_type` | TEXT | no | monitoring ,  job_run ,  report ,  manual ,  forecast |
| `source_ref` | TEXT | no |  |
| `process_id` | TEXT | no | Regla B22 |
| `recorded_at` | TEXT | sí |  |

**Se relaciona con**: `kpis` (por `id`), `processes` (por `process_id`)

### `costs`

**Capa**: CORE, **Dueño**: `dt-demand-manager`, **Reglas**: B22 B27 B37

Costo de la tecnología del cliente (Reglas B41 y B43 · ADR-EB-012). FRONTERA: guarda lo que al CLIENTE le cuesta operar su tecnología. NO guarda precios, tarifas por hora ni cifras de propuesta: eso es territorio de Pricing & Comm

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37 |
| `entity_table` | TEXT | sí | products ,  technology_components ,  applications ,  suppliers |
| `entity_id` | TEXT | sí |  |
| `cost_type` | TEXT | no | licencia ,  nube ,  infraestructura ,  soporte ,  personas |
| `amount` | REAL | no |  |
| `currency` | TEXT | no | MXN ,  USD |
| `period_start` | TEXT | no |  |
| `period_end` | TEXT | no |  |
| `allocation_basis` | TEXT | no | directo ,  por consumo ,  por headcount ,  por transacción |
| `product_id` | TEXT | no | Regla B27: a qué producto se atribuye |
| `kpi_id` | TEXT | no | Regla B27: qué KPI afecta |
| `process_id` | TEXT | no | Regla B22 |
| `source_system` | TEXT | no | sistema de registro del que proviene |
| `source_ref` | TEXT | no |  |
| `recorded_at` | TEXT | no |  |

**Se relaciona con**: `kpis` (por `kpi_id`), `processes` (por `process_id`), `products` (por `product_id`)

### `queries`

**Capa**: CORE, **Dueño**: `dt-knowledge-manager`, **Reglas**: B17 B27 B35 B37 B42 B43

El objeto consulta (Regla B45 · ADR-EB-013). Sin identidad de consulta no hay dónde registrar el propósito que exige B42, no hay qué contar para medir el uso que pide B43, y una respuesta equivocada no se puede rastrear hasta el c

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí |  |
| `requester` | TEXT | no | rol en stakeholders, no nombre de persona |
| `requester_org` | TEXT | no | cliente ,  consultora ,  tercero |
| `purpose` | TEXT | sí | sin propósito declarado no cruza frontera |
| `question` | TEXT | no |  |
| `anchor_table` | TEXT | no | eslabón de la cadena que la ancla |
| `anchor_id` | TEXT | no |  |
| `tier_summary` | TEXT | no | JSON: cuánto de la respuesta es gold, silver, bronze |
| `gaps_declared` | TEXT | no | JSON: qué faltó y se declaró en vez de rellenar |
| `denied_reason` | TEXT | no | si la frontera la rechazó, por qué |
| `decision_id` | TEXT | no | FK lógica a decisions.id, si derivó en decisión |
| `latency_ms` | INTEGER | no | eje de desempeño de B43 |
| `answered_at` | TEXT | no |  |
| `asked_at` | TEXT | sí |  |

**Se relaciona con**: `decisions` (por `decision_id`)

### `knowledge_lineage`

**Capa**: CORE, **Dueño**: `dt-knowledge-manager`, **Reglas**: B29 B40 B42

Linaje del conocimiento (Regla B37 · ADR-EB-010). Generaliza rule_enrichment_log de Informix (22,425 filas de procedencia campo por campo) a todo el brain. Cada afirmación del brain tiene aquí su nivel, su fuente y quién la validó

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | INTEGER | no |  |
| `entity_table` | TEXT | sí | tabla de la afirmación |
| `entity_id` | TEXT | sí | id de la fila; PK compuesta como "a, b" |
| `field` | TEXT | no | NULL = la fila completa |
| `tier` | TEXT | sí | gold ,  silver ,  bronze ,  rejected |
| `tier_basis` | TEXT | sí | origin ,  validated ,  sourced ,  ingested ,  demoted ,  rejected |
| `source_type` | TEXT | sí | code ,  log ,  monitoring ,  job_run ,  regulation ,  signed_artifact ,  |
| `source_ref` | TEXT | no | archivo:línea · id de log · instrumento y artículo · doc y página |
| `source_version` | TEXT | no | hash, commit, versión de deploy o fecha de publicación |
| `asserted_by` | TEXT | no | DT o persona que hizo la afirmación (Regla B29) |
| `method` | TEXT | no | extracción, síntesis LLM, entrevista, carga masiva |
| `validated_by` | TEXT | no | rol con autoridad (HITL). NULL si es gold por origen |
| `validated_at` | TEXT | no |  |
| `superseded_by` | INTEGER | no | id del registro que lo reemplaza (no se borra nada) |
| `notes` | TEXT | no |  |
| `exposed_for` | TEXT | no | JSON: propósitos bajo los que se ha consultado |
| `valid_from` | TEXT | no | ISO date. NULL = verdad desde el origen del sistema |
| `valid_to` | TEXT | no | ISO date. NULL = sigue siendo verdad hoy |
| `recorded_at` | TEXT | sí |  |

### `source_catalog`

**Capa**: CORE, **Dueño**: `dt-source-steward`

Catalogo de fuentes - ADR-EB-014. Dueno: dt-source-steward. El tier natural lo fija el tipo de fuente (funcion F2), no quien la carga: el tier de una afirmacion nunca puede superar el de la fuente que la sostiene (B37). Toda fila 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `ontology` | TEXT | sí |  |
| `name` | TEXT | sí |  |
| `source_type` | TEXT | no | codigo ,  doc ,  ppt ,  audio ,  git ,  jira ,  monitoring ,  cmdb ,  logs ,  regulacion |
| `generator_type` | TEXT | no | parser (fuente estatica) ,  connector (sistema vivo) |
| `cadence` | TEXT | no | batch ,  continuo ,  bajo demanda |
| `status` | TEXT | no | activa ,  parcial ,  ausente ,  planeada |
| `natural_tier` | TEXT | no | gold ,  silver ,  bronze - derivado de source_type |
| `coverage_pct` | REAL | no | porcentaje del sistema que cubre esta fuente |
| `enables` | TEXT | no | JSON: casos de uso que habilita |
| `location` | TEXT | no | ruta o endpoint |
| `last_refresh` | TEXT | no |  |
| `owner` | TEXT | no |  |

### `company_profile`

**Capa**: CORE, **Dueño**: `dt-client-intelligence`, **Reglas**: B37

Ficha de identidad. Una sola fila por brain, con el mismo slug de system_info. Las CIFRAS no viven aqui: ingresos, empleados y participacion de mercado son filas de measurements ancladas a esta tabla (ADR-EB-015 decision 5).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `slug` (PK) | TEXT | no | mismo slug que system_info |
| `tier` | TEXT | sí | Regla B37 |
| `legal_name` | TEXT | sí | razon social completa |
| `display_name` | TEXT | sí | como se le nombra en el mercado |
| `founded_year` | INTEGER | no |  |
| `ownership` | TEXT | no | publica ,  privada ,  familiar ,  estatal ,  cooperativa ,  subsidiaria |
| `parent_group` | TEXT | no | grupo controlador, si es subsidiaria |
| `ticker` | TEXT | no | clave de cotizacion, si cotiza |
| `hq_country` | TEXT | no |  |
| `geographies` | TEXT | no | JSON: paises o regiones donde opera |
| `industries` | TEXT | no | JSON: multi-industria es la norma (ADR-EB-007) |
| `business_model` | TEXT | no | como gana dinero, en una frase |
| `source_ref` | TEXT | no | de donde salio: reporte anual, sitio, entrevista |

### `business_milestones`

**Capa**: CORE, **Dueño**: `dt-client-intelligence`, **Reglas**: B37

Trayectoria. Lo que explica por que la empresa es como es hoy.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "MIL-{nnn}" |
| `tier` | TEXT | sí | Regla B37 |
| `occurred_year` | INTEGER | sí |  |
| `milestone_type` | TEXT | no | fundacion ,  fusion ,  adquisicion ,  ipo ,  crisis ,  entrada_mercado ,  salida_mercado ,  reestructu |
| `title` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `impact` | TEXT | no | que cambio en el negocio a partir de aqui |
| `source_ref` | TEXT | no |  |

### `strategic_drivers`

**Capa**: CORE, **Dueño**: `dt-client-intelligence`, **Reglas**: B37

Pilares, objetivos, retos y amenazas. Tipados en una sola tabla porque comparten estructura y se consultan juntos: el eje rector del brain.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "DRV-{nnn}" |
| `tier` | TEXT | sí | Regla B37 |
| `driver_type` | TEXT | sí | pilar ,  objetivo ,  reto ,  amenaza |
| `title` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `horizon` | TEXT | no | ISO date o anio objetivo |
| `priority` | TEXT | no | alta ,  media ,  baja |
| `status` | TEXT | no | declarado ,  en_ejecucion ,  logrado ,  abandonado |
| `declared_by` | TEXT | no | FK logica a stakeholders.id, o el documento que lo declara |
| `source_ref` | TEXT | no |  |

### `driver_links`

**Capa**: CORE, **Dueño**: `dt-client-intelligence`, **Reglas**: B37

La traza de vuelta: que parte del estate sirve a que driver. Es lo que convierte el estudio del cliente en eje rector y no en prologo. Generica por entity_table igual que measurements: un driver se sirve desde capabilities en un b

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | INTEGER | no |  |
| `tier` | TEXT | sí | Regla B37 |
| `driver_id` | TEXT | sí | FK logica a strategic_drivers.id |
| `entity_table` | TEXT | sí | capabilities ,  products ,  processes ,  rules ,  findings ,  risks ,  user_stories ,  applications |
| `entity_id` | TEXT | sí |  |
| `relation` | TEXT | no | sirve ,  bloquea ,  mide |
| `rationale` | TEXT | no | por que este elemento se ata a este driver |
| `source_ref` | TEXT | no |  |

### `components`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B24 B37

Homologa: sps (Informix) · services (AppMóvil) · objects (Gentera) · programs/inventario (Banamex) · platforms (Coppel).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | convención canónica: "{db}:{name}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | sí |  |
| `display_name` | TEXT | no |  |
| `description` | TEXT | no |  |
| `domain` | TEXT | no |  |
| `tipo` | TEXT | no | sp ,  program ,  object ,  service ,  table ,  api ,  job |
| `fan_in` | INTEGER | no |  |
| `fan_out` | INTEGER | no |  |
| `loc` | INTEGER | no |  |
| `is_soul` | INTEGER | no |  |
| `soul_rank` | INTEGER | no |  |
| `archetype` | TEXT | no | CTM_ENTRY, CTM_HINT, FILE_LOADER, DATA_MAINT |
| `primary_capability` | TEXT | no | FK lógica a capabilities.id |
| `current_platform` | TEXT | no |  |
| `target_platform` | TEXT | no |  |
| `migration_status` | TEXT | no |  |
| `origin_transition_id` | TEXT | no |  |
| `seeded_by` | TEXT | no |  |
| `fill_quality` | TEXT | no | complete ,  partial ,  stub |
| `source_doc` | TEXT | no |  |
| `status` | TEXT | no |  |

**Se relaciona con**: `capabilities` (por `id`)

### `component_calls`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B37

Grafo de llamadas. De Gentera (object_calls) e Informix (sp_calls). Habilita flow_diagram(), callers_of(), callees_of(), impact_of().

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `from_component` (PK) | TEXT | sí |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `to_component` (PK) | TEXT | sí |  |
| `cross_db` | INTEGER | no |  |

### `rules`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B22 B37

Reglas de negocio. La de Gentera es la mejor del estate: trazabilidad a nivel de LÍNEA. Se le suma `clase` (Informix/Banamex) y `enrichment_method` (ADR-EB-004).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "{PREFIX}-{db}-{component}-{line}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `component_id` | TEXT | sí |  |
| `linea` | INTEGER | no | línea exacta en el fuente (Gentera) |
| `tipo` | TEXT | no | FÓRMULA, VALIDACIÓN, UMBRAL, TRANSFORMACIÓN |
| `sub_tipo` | TEXT | no |  |
| `clase` | TEXT | sí | NEGOCIO, INFRAESTRUCTURA, ENSAMBLAJE, PRESENTACION |
| `condicion` | TEXT | no |  |
| `fragmento` | TEXT | no | fragmento del código fuente, tal como se extrajo |
| `business_name` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `reg` | TEXT | sí | '' válido = sin regulación; NULL = no revisado |
| `process_id` | TEXT | no |  |
| `riesgo` | TEXT | no | JSON array: MONEY, DIV, ROUND, FX, UDI |
| `source_file` | TEXT | no |  |
| `enrichment_method` | TEXT | no |  |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |
| `domain` | TEXT | no |  |

**Se relaciona con**: `components` (por `component_id`), `processes` (por `process_id`)

### `rule_enrichment_log`

**Capa**: SYSTEM, **Dueño**: `dt-knowledge-manager`

Bitácora de enriquecimiento. De Informix (rule_enrichment_log, 22,425 filas). Provenance campo-por-campo: quién cambió qué, cuándo y con qué método. Es lo que hace auditable la síntesis LLM.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | INTEGER | no |  |
| `rule_id` | TEXT | sí |  |
| `swarm` | TEXT | no |  |
| `field` | TEXT | no |  |
| `old_value` | TEXT | no |  |
| `new_value` | TEXT | no |  |
| `method` | TEXT | no |  |
| `confidence` | TEXT | no |  |
| `notes` | TEXT | no |  |
| `timestamp` | TEXT | no |  |

**Se relaciona con**: `rules` (por `rule_id`)

### `vocabulary`

**Capa**: SYSTEM, **Dueño**: `dt-information-architect`, **Reglas**: B22 B37

Vocabulario. Homologa: terms (Informix, Gentera) · vocab (MONEX, AXA, Santander) · vocab_full/vocab_terms (Banamex) · vocabulary (Unity, Coppel). Gana `vocabulary`: es el nombre que el canon ya declaraba y el que usan los dos brai

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `term` | TEXT | sí |  |
| `definition` | TEXT | no |  |
| `categoria` | TEXT | no |  |
| `scope` | TEXT | no | enterprise ,  system ,  domain |
| `process_id` | TEXT | no |  |
| `domain` | TEXT | no |  |
| `maturity` | TEXT | no | confirmed ,  proposed ,  deprecated |
| `source_system` | TEXT | no |  |
| `aliases` | TEXT | no | JSON array |
| `est` | TEXT | no | 'resolved' tras conflicto (Regla V2) |

**Se relaciona con**: `processes` (por `process_id`)

### `journeys`

**Capa**: SYSTEM, **Dueño**: `dt-demand-manager`, **Reglas**: B37

Journeys — trazas REALES por el código, derivadas del call graph. No confundir con `processes`: el proceso es el modelo de la industria (cómo debería operar); el journey es lo que el sistema hace de hecho (entry point → cadena de 

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `display_name` | TEXT | no |  |
| `description` | TEXT | no |  |
| `entry_component` | TEXT | sí | SP/programa de entrada |
| `call_depth` | INTEGER | no |  |
| `component_count` | INTEGER | no |  |
| `domain` | TEXT | no |  |
| `cross_domains` | TEXT | no | JSON array |
| `process_id` | TEXT | no | FK lógica a processes.id — qué realiza |
| `capability_id` | TEXT | no |  |
| `systems` | TEXT | no | JSON array de slugs |
| `source_type` | TEXT | no | ctm_entry, esb_exposed, channel, scheduled |

**Se relaciona con**: `processes` (por `process_id`)

### `component_capabilities`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B37

SYSTEM — brains de sistema productivo (hemisphere='run') Referencias: Informix (90MB), Banamex (122MB), Gentera, Coppel-ecommerce

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `component_id` (PK) | TEXT | sí |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `capability_id` (PK) | TEXT | sí |  |
| `mapping_type` | TEXT | no | primary ,  secondary ,  inferred |
| `source` | TEXT | no |  |
| `confidence` | TEXT | no |  |

**Se relaciona con**: `components` (por `component_id`)

### `component_processes`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B37

Regla B22 — un componente sirve típicamente a varios procesos, así que su trazabilidad es N:M en vez de columna. Un componente sin ningún proceso es código cuyo propósito de negocio nadie estableció.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `component_id` (PK) | TEXT | sí |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `process_id` (PK) | TEXT | sí |  |
| `mapping_type` | TEXT | no | primary ,  secondary ,  inferred |
| `evidence` | TEXT | no | journey, CTM, doc que sustenta el enlace |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |

**Se relaciona con**: `components` (por `component_id`), `processes` (por `process_id`)

### `component_data`

**Capa**: SYSTEM, **Dueño**: `dt-information-architect`, **Reglas**: B37

Matriz CRUD aplicación-dato de TOGAF. Homologa Informix sp_table_refs. Un componente que escribe una entidad personal o sensible hereda su regulación.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `component_id` (PK) | TEXT | sí |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `entity_id` (PK) | TEXT | sí | FK lógica a data_entities.id |
| `access_type` | TEXT | no | R ,  W ,  RW |
| `operations` | TEXT | no | JSON array: SELECT ,  INSERT ,  UPDATE ,  DELETE |
| `cross_store` | INTEGER | no | la entidad vive en otro store (de is_cross_db) |
| `line_first` | INTEGER | no | primera línea del fuente donde aparece |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |

**Se relaciona con**: `components` (por `component_id`), `data_entities` (por `id`)

### `regulatory_obligations`

**Capa**: SYSTEM, **Dueño**: `dt-it-risk-manager`, **Reglas**: B22 B37

Obligaciones regulatorias como tabla first-class, no como anotación. Convergencia espontánea Informix + CAN + Santander → canon.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `regulator` | TEXT | sí |  |
| `instrument` | TEXT | no |  |
| `article` | TEXT | no |  |
| `description` | TEXT | no |  |
| `obligation_type` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `rol_aplicable` | TEXT | no | de Santander CAN: regla por rol de actor |
| `frequency` | TEXT | no |  |
| `penalty_risk` | TEXT | no |  |
| `effective_date` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `external_systems`

**Capa**: SYSTEM, **Dueño**: `dt-asset-configuration-manager`, **Reglas**: B37

Sistemas externos observados (endpoints, tasas de error, timeouts).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `name` | TEXT | no |  |
| `description` | TEXT | no |  |
| `system_type` | TEXT | no |  |
| `total_endpoints` | INTEGER | no |  |
| `error_codes` | TEXT | no | JSON array |
| `failure_rate` | REAL | no |  |
| `timeout_ms` | INTEGER | no |  |
| `regulation` | TEXT | no |  |

### `applications`

**Capa**: PROJECT, **Dueño**: `dt-programme-manager`, **Reglas**: B22 B37

PROJECT — brains de proyecto de transformación (hemisphere='change') Referencias: Exodus, Unity, CAN (BanCoppel + Santander), payments-modernization  Los brains de proyecto NO tienen components/rules: su ontología es applications/

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | convención: "{wave}::{app_id}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `app_id` | TEXT | no |  |
| `name` | TEXT | sí |  |
| `wave_id` | TEXT | no |  |
| `criticality` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `complexity` | TEXT | no |  |
| `hosting` | TEXT | no |  |
| `description` | TEXT | no |  |
| `migration_approach` | TEXT | no | 7R: rehost, replatform, refactor, ... |
| `component_count` | INTEGER | no |  |
| `source_doc` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`), `waves` (por `wave_id`)

### `waves`

**Capa**: PROJECT, **Dueño**: `dt-programme-manager`, **Reglas**: B37

PROJECT — brains de proyecto de transformación (hemisphere='change') Referencias: Exodus, Unity, CAN (BanCoppel + Santander), payments-modernization  Los brains de proyecto NO tienen components/rules: su ontología es applications/

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `seq` | INTEGER | no |  |
| `title` | TEXT | sí |  |
| `horizon` | TEXT | no |  |
| `objective` | TEXT | no |  |
| `executive_summary` | TEXT | no |  |
| `app_count` | INTEGER | no |  |
| `source_doc` | TEXT | no |  |

### `risks`

**Capa**: PROJECT, **Dueño**: `dt-it-risk-manager`, **Reglas**: B22 B24 B37

PROJECT — brains de proyecto de transformación (hemisphere='change') Referencias: Exodus, Unity, CAN (BanCoppel + Santander), payments-modernization  Los brains de proyecto NO tienen components/rules: su ontología es applications/

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `title` | TEXT | sí |  |
| `category` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `severity` | TEXT | no |  |
| `probability` | TEXT | no |  |
| `description` | TEXT | no |  |
| `mitigation` | TEXT | no |  |
| `owner` | TEXT | no |  |
| `related` | TEXT | no | JSON array |
| `origin_finding_id` | TEXT | no |  |
| `status` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `decisions`

**Capa**: PROJECT, **Dueño**: `dt-domain-architect`, **Reglas**: B37 B39 B40 B43

ADR dentro del brain. Convergencia Coppel + Unity + Santander CAN.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "ADR-{SLUG}-{NNN}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `date` | TEXT | no |  |
| `title` | TEXT | sí |  |
| `context` | TEXT | no |  |
| `decision` | TEXT | no |  |
| `alternatives` | TEXT | no |  |
| `consequences` | TEXT | no |  |
| `status` | TEXT | no | propuesto ,  aprobado ,  superseded |
| `domain` | TEXT | no |  |
| `options_rejected` | TEXT | no | JSON: qué se descartó y por qué |
| `knowledge_refs` | TEXT | no | JSON: ids de knowledge_lineage que la sostienen |
| `knowledge_tier` | TEXT | no | el nivel que ese conocimiento tenía AL DECIDIR. |
| `decided_by` | TEXT | no | rol accountable en stakeholders (B39) |
| `decided_at` | TEXT | no |  |
| `query_id` | TEXT | no | FK lógica a queries.id: qué consulta la motivó |
| `outcome` | TEXT | no | logrado ,  parcial ,  no_logrado ,  pendiente |
| `outcome_kpi_id` | TEXT | no | qué KPI debía moverse |
| `outcome_measured_at` | TEXT | no |  |
| `outcome_notes` | TEXT | no |  |

**Se relaciona con**: `queries` (por `id`)

### `user_stories`

**Capa**: PROJECT, **Dueño**: `dt-programme-manager`, **Reglas**: B22 B24 B37

PROJECT — brains de proyecto de transformación (hemisphere='change') Referencias: Exodus, Unity, CAN (BanCoppel + Santander), payments-modernization  Los brains de proyecto NO tienen components/rules: su ontología es applications/

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `title` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `capability_id` | TEXT | no |  |
| `obligation_id` | TEXT | no |  |
| `priority` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `estimate` | TEXT | no |  |
| `origin_finding_id` | TEXT | no |  |
| `status` | TEXT | no |  |

**Se relaciona con**: `processes` (por `process_id`)

### `federated_brains`

**Capa**: ENTERPRISE, **Dueño**: `dt-domain-architect`

Registro de brains federados. De MONEX (la mejor implementación del patrón) + Liverpool (attach real) + AXA (brain_attached como control de salud).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `slug` (PK) | TEXT | no |  |
| `display_name` | TEXT | sí |  |
| `brain_type` | TEXT | sí | project ,  system |
| `hemisphere` | TEXT | sí | change ,  run |
| `togaf_type` | TEXT | no |  |
| `togaf_state` | TEXT | no |  |
| `brain_path` | TEXT | sí | ruta relativa al brain.db |
| `brain_attached` | INTEGER | no | 1 = ATTACH exitoso en el último build |
| `status` | TEXT | no | SCAFFOLD ,  SEEDED ,  ACTIVE |
| `last_built_at` | TEXT | no |  |
| `component_count` | INTEGER | no |  |
| `rule_count` | INTEGER | no |  |

### `documents`

**Capa**: ENTERPRISE, **Dueño**: `dt-knowledge-manager`

Corpus documental del cliente + red de seguridad de cero pérdida. De Banamex (kb_documents + kb_fts, 283 docs): el texto crudo completo indexado garantiza que nada del corpus se pierde en la destilación.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `path` (PK) | TEXT | no |  |
| `filename` | TEXT | no |  |
| `categoria` | TEXT | no |  |
| `n_lineas` | INTEGER | no |  |
| `contenido` | TEXT | no |  |

### `plateaus`

**Capa**: PUENTE, **Dueño**: `dt-domain-architect`, **Reglas**: B37

Estados de la arquitectura (ArchiMate: plateau). Mapean a togaf_state: as_is = baseline · transition = transitional · to_be = target. De Unity/bank-brain (releases R2, R4) y Exodus (waves W1..Wn).

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "PL-{slug}-{n}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `kind` | TEXT | sí | as_is ,  transition ,  to_be |
| `seq` | INTEGER | no |  |
| `name` | TEXT | sí | "R4 · TDC P4900 en SmartVista" |
| `wave_id` | TEXT | no | FK lógica a waves.id |
| `release` | TEXT | no |  |
| `target_date` | TEXT | no |  |
| `reached_date` | TEXT | no |  |
| `status` | TEXT | no | planned ,  in_progress ,  reached |
| `description` | TEXT | no |  |

**Se relaciona con**: `waves` (por `wave_id`)

### `transitions`

**Capa**: PUENTE, **Dueño**: `dt-change-manager`, **Reglas**: B22 B37

Lado Change del puente: qué se mueve, de dónde, a dónde y cómo. `to_system` / `from_system` son slugs de brains de Run: es la llave con que el enterprise brain encuentra al brain que hereda la transición.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no | "TR-{slug}-{nnn}" |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `entity_type` | TEXT | sí | capability ,  component ,  domain ,  application ,  product |
| `entity_id` | TEXT | sí |  |
| `capability_id` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `from_system` | TEXT | sí | brain de Run que hoy lo opera |
| `to_system` | TEXT | sí | brain de Run que lo heredará |
| `plateau_id` | TEXT | sí | en qué estado de arquitectura ocurre |
| `fate` | TEXT | sí | retain, retire, rehost, replatform, refactor, rearchitect, replace, encapsulate |
| `fate_source` | TEXT | no |  |
| `pattern` | TEXT | no | strangler-fig ,  big-bang ,  phased ,  parallel-run |
| `pre_route` | TEXT | no |  |
| `post_route` | TEXT | no |  |
| `switch_mechanism` | TEXT | no | feature_flag ,  dns ,  config ,  cutover_window |
| `parallel_run` | INTEGER | no |  |
| `coexistence_rule` | TEXT | no | condición que decide qué ruta aplica |
| `run_owner` | TEXT | no |  |
| `run_service_type` | TEXT | no | AMS-dev ,  AMS-ops ,  in-house ,  vendor |
| `run_coverage` | TEXT | no | full ,  high ,  partial |
| `status` | TEXT | sí |  |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |
| `evidence` | TEXT | no |  |
| `origin_artifact` | TEXT | no |  |
| `updated_at` | TEXT | no |  |

**Se relaciona con**: `plateaus` (por `plateau_id`), `processes` (por `process_id`)

### `readiness_gates`

**Capa**: PUENTE, **Dueño**: `dt-change-manager`, **Reglas**: B37

Gates de readiness operativa: lo que Run exige antes de heredar. De Unity capability_prr, normalizado de columnas a filas para que cada gate tenga evidencia, aprobador y fecha propios.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `transition_id` (PK) | TEXT | sí |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `gate` (PK) | TEXT | sí | runbook, oncall, slo, rollback, drp, test, knowledge, prr |
| `status` | TEXT | sí | pending ,  done ,  waived ,  blocked |
| `blocker` | TEXT | no |  |
| `evidence` | TEXT | no |  |
| `approved_by` | TEXT | no |  |
| `approved_at` | TEXT | no |  |

**Se relaciona con**: `transitions` (por `transition_id`)

### `slos`

**Capa**: PUENTE, **Dueño**: `dt-change-manager`, **Reglas**: B36 B37

El objeto que vive en ambos hemisferios: Change fija `target` al diseñar, Run mide `current` al operar. Un SLO sin current es promesa; sin target es medición sin contrato. De Unity capability_slos y Coppel slos.

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `capability_id` | TEXT | no |  |
| `transition_id` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `kpi_id` | TEXT | no |  |
| `metric` | TEXT | sí | availability ,  latency_p95 ,  error_rate ,  mttr ,  tps |
| `target` | TEXT | no |  |
| `current` | TEXT | no |  |
| `unit` | TEXT | no |  |
| `window` | TEXT | no |  |
| `status` | TEXT | no | pending ,  met ,  breaching ,  unknown |
| `committed_by` | TEXT | no | brain/rol que fijó el target (Change) |
| `measured_by` | TEXT | no | brain/fuente que mide el current (Run) |
| `measured_at` | TEXT | no |  |

**Se relaciona con**: `kpis` (por `kpi_id`), `processes` (por `process_id`), `transitions` (por `transition_id`)

### `findings`

**Capa**: PUENTE, **Dueño**: `dt-service-operations-lead`, **Reglas**: B22 B37 B38

Lado Run del puente: lo que la operación aprende y Change debe saber. Homologa tribal_knowledge (Informix) · hallazgos (Banamex) · audit_findings (Unity) · pain_points (AXA) · ticket_recurrence (Liverpool). Un hallazgo que toca al

| Columna | Tipo | Obligatoria | Qué guarda |
|---------|------|-------------|------------|
| `id` (PK) | TEXT | no |  |
| `tier` | TEXT | sí | Regla B37: gold ,  silver ,  bronze ,  rejected |
| `finding_type` | TEXT | sí | incident_pattern, performance_pattern, recurrence,  |
| `title` | TEXT | sí |  |
| `description` | TEXT | no |  |
| `impact_if_ignored` | TEXT | no | de Informix impact_if_lost |
| `severity` | TEXT | sí | blocker ,  critical ,  high ,  medium ,  low |
| `severity_source` | TEXT | no | valor original ("BLOQUEADOR", "Alta") |
| `entity_type` | TEXT | no | component ,  domain ,  capability ,  application |
| `entity_ids` | TEXT | no | JSON array (de Informix sp_keys) |
| `domain` | TEXT | no |  |
| `capability_id` | TEXT | no |  |
| `process_id` | TEXT | no |  |
| `occurrences` | INTEGER | no | de Liverpool ticket_recurrence |
| `first_seen` | TEXT | no |  |
| `last_seen` | TEXT | no |  |
| `recommended_action` | TEXT | no |  |
| `discovered_from` | TEXT | no |  |
| `discovered_at` | TEXT | no |  |
| `validated_by` | TEXT | no |  |
| `confidence` | TEXT | no | confirmed ,  inferred ,  suspected |
| `routed_to_brain` | TEXT | no | slug del brain de proyecto |
| `routed_to_tool` | TEXT | no | FK lógica a technology_components.id (category='it_tool') |
| `routed_ref` | TEXT | no |  |
| `route_status` | TEXT | sí |  |

**Se relaciona con**: `processes` (por `process_id`), `technology_components` (por `id`)

# Alineación del brain de Banamex al canon del Enterprise Brain

> Generado por `build-canon.py` el 2026-11-11. **No editar a mano.**

Identidad declarada: `brain_type='system'`, `hemisphere='run'`, `togaf_type='core'`, slug `unisys-core`, versión 4.0.0.

Implementa el CORE, la extensión SYSTEM y el lado Run del puente (Reglas B15 y B24). La homologación sigue la Regla B16: ninguna fila del pipeline histórico se reescribió.

## Cobertura

| Tabla canónica | Capa | Objeto | Origen histórico | Filas |
|---|---|---|---|---|
| `system_info` | CORE | table | nueva | 1 |
| `cross_dependencies` | CORE | table | cross_dependencies (homologada in situ) | 18 |
| `signals` | CORE | table | nueva | 5 |
| `ontology_bindings` | CORE | table | nueva | 1 |
| `capabilities` | CORE | view | capacidades | 26 |
| `processes` | CORE | table | nueva | 0 |
| `knowledge_gaps` | CORE | table | nueva | 29 |
| `itom_layer` | CORE | table | nueva | 0 |
| `products` | CORE | table | nueva | 0 |
| `kpis` | CORE | table | nueva | 0 |
| `stakeholders` | CORE | table | nueva | 0 |
| `data_entities` | CORE | view | datasets, db_fisicas | 192 |
| `technology_components` | CORE | table | nueva | 15 |
| `suppliers` | CORE | table | nueva | 5 |
| `measurements` | CORE | table | nueva | 0 |
| `costs` | CORE | table | nueva | 0 |
| `queries` | CORE | table | nueva | 0 |
| `knowledge_lineage` | CORE | table | nueva | 7 |
| `source_catalog` | CORE | table | nueva | 4 |
| `company_profile` | CORE | table | nueva | 1 |
| `business_milestones` | CORE | table | nueva | 0 |
| `strategic_drivers` | CORE | table | nueva | 3 |
| `driver_links` | CORE | table | nueva | 407 |
| `action_catalog` | CORE | table | nueva | 20 |
| `actions` | CORE | table | nueva | 0 |
| `components` | SYSTEM | view | inventario, programs | 218 |
| `component_calls` | SYSTEM | table | nueva | 0 |
| `rules` | SYSTEM | table | rules (homologada in situ) | 1583 |
| `rule_enrichment_log` | SYSTEM | table | nueva | 0 |
| `vocabulary` | SYSTEM | view | vocab_full | 69587 |
| `journeys` | SYSTEM | view | flujos | 45 |
| `component_capabilities` | SYSTEM | view | programs | 139 |
| `component_processes` | SYSTEM | table | nueva | 0 |
| `component_data` | SYSTEM | table | nueva | 0 |
| `regulatory_obligations` | SYSTEM | view | regulatory_reports | 13 |
| `external_systems` | SYSTEM | table | nueva | 0 |
| `findings` | PUENTE | view | hallazgos | 178 |
| `slos` | PUENTE | table | nueva | 0 |

## Huecos declarados

Cada hueco es una consulta concreta a un responsable identificado, nunca un `PENDIENTE` (Regla B17).

| Id | Tipo | Qué falta | A quién se le pregunta |
|---|---|---|---|
| KG-C-001 | dato | El canon pide `rules.linea` y el brain no lo tiene. | dt-mainframe-analyst |
| KG-C-002 | dato | El canon pide `rules.condicion` y el brain no lo tiene. | dt-mainframe-analyst |
| KG-C-003 | dato | El canon pide `components.fan_in` y el brain no lo tiene. | dt-mainframe-analyst |
| KG-C-004 | decisión | El canon pide `components.is_soul` y el brain no lo tiene. | dt-mainframe-analyst |
| KG-C-005 | dato | El canon pide `company_profile.ownership` y el brain no lo tiene. | Accenture — Account Lead |
| KG-C-006 | dato | El canon pide `technology_components.support_status` y el brain no lo tiene. | Banamex — mainframe |
| KG-C-007 | decisión | El canon pide `capabilities.ontology (ETB)` y el brain no lo tiene. | SME/Industry/Industry Banking |
| KG-O-001 | dato | `capacidades.dominio` y `capacidades.subdominio` están vacías en la KB, así que capabilities.l1_name y l2_name salen nulas. | SME/Industry/Industry Banking |
| KG-S-001 | acceso | P138 (S151) está documentado en la KB pero su archivo fuente no está en el corpus. | Banamex — mainframe |
| KG-S-002 | acceso | P093 (S500) está documentado en la KB pero su archivo fuente no está en el corpus. | Banamex — mainframe |
| KG-S-003 | acceso | P629 (S500) está documentado en la KB pero su archivo fuente no está en el corpus. | Banamex — mainframe |
| KG-S-004 | acceso | P630 (S500) está documentado en la KB pero su archivo fuente no está en el corpus. | Banamex — mainframe |
| KG-S-005 | acceso | P655 (S500) está documentado en la KB pero su archivo fuente no está en el corpus. | Banamex — mainframe |
| KG-T-001 | dato | La tabla canónica `actions` está vacía en este brain. | dt-change-manager |
| KG-T-002 | dato | La tabla canónica `business_milestones` está vacía en este brain. | Accenture — Account Lead |
| KG-T-003 | dato | La tabla canónica `component_calls` está vacía en este brain. | dt-mainframe-analyst |
| KG-T-004 | dato | La tabla canónica `component_data` está vacía en este brain. | dt-mainframe-analyst |
| KG-T-005 | dato | La tabla canónica `component_processes` está vacía en este brain. | SME/Industry/Industry Banking |
| KG-T-006 | acceso | La tabla canónica `costs` está vacía en este brain. | Banamex — finanzas de TI |
| KG-T-007 | acceso | La tabla canónica `external_systems` está vacía en este brain. | Banamex — integración |
| KG-T-008 | dato | La tabla canónica `itom_layer` está vacía en este brain. | SME/Framework/IT Operating Model |
| KG-T-009 | dato | La tabla canónica `kpis` está vacía en este brain. | Banamex — dueño de producto |
| KG-T-010 | acceso | La tabla canónica `measurements` está vacía en este brain. | Banamex — operación de mainframe |
| KG-T-011 | dato | La tabla canónica `processes` está vacía en este brain. | SME/Industry/Industry Banking |
| KG-T-012 | dato | La tabla canónica `products` está vacía en este brain. | SME/Industry/Industry Banking |
| KG-T-013 | dato | La tabla canónica `queries` está vacía en este brain. | dt-knowledge-manager |
| KG-T-014 | validación | La tabla canónica `rule_enrichment_log` está vacía en este brain. | dt-knowledge-curator |
| KG-T-015 | acceso | La tabla canónica `slos` está vacía en este brain. | Banamex — operación de mainframe |
| KG-T-016 | dato | La tabla canónica `stakeholders` está vacía en este brain. | Accenture — Account Lead |

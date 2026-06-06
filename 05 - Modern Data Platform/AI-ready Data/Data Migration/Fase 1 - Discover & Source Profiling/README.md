# Fase 1 - Discover & Source Profiling

> Fase del sub-offering **Data Migration** (offering domain AI-ready Data). Fuente de verdad: el `CLAUDE.md` del sub-offering (seccion "Fases de la Migracion"). Esta carpeta es el contenedor orquestador de la fase; el delivery lo ejecuta el SME via `[INVOKE]`.

| Campo | Valor |
|-------|-------|
| Mapea a (DataOps) | DISCOVER |
| Objetivo | Inventario del data estate, volumetria, dependencias, clasificacion de tablas por riesgo. |
| Gate de salida | Source Profile + mapa de dependencias + clasificacion firmados. |
| Ejecuta (`[INVOKE]`) | Data & ML SME, Data Architect |

## Entregable

`profiler/profile.py` produce el deliverable **Source Profiling & Discovery Assessment**: `artifacts/` (inventory, profiling, DQ baseline, dependency-graph, entity-coupling, dispositions, wave-plan, handoff) + `discovery-assessment.html` + `graph-view.html`. Hoy corre sobre el data seed banking+CRM (con filas); para discovery a escala consume el modelo `seed-sap-banking-ecc-scale-graph` (~1,500 tablas) del Reference Data Lab.

`[GATE]` Cuando el modelo proviene del Reference Data Lab, **Fase 1 solo lo consume tras el sign-off de fidelidad del SME `SAP Banking Services`** (`../Enablement/Training - Reference Data Lab/seed-sap-banking-ecc-scale-graph/validation/validation-sap-core-banking-signoff.md`). El modelo es de referencia, sin IP de cliente; el sign-off certifica fidelidad al patrón SAP Banking.

## Dos vistas del discovery (complementarias, como las dos escalas del lab)

| Profiler | Consume | Produce | Para |
|----------|---------|---------|------|
| `profiler/profile.py` | data seed banking+CRM (con filas) | `discovery-assessment.html` + `artifacts/` | DQ con filas, entity resolution, reconciliacion a nivel dato (9 tablas) |
| `profiler/profile_scale.py` | `seed-sap-banking-ecc-scale-graph` (~1,500 tablas) | `discovery-assessment-scale.html` + `artifacts-scale/` | discovery a escala: hubs, comunidades, dead clusters, acoplamiento oculto, wave plan |

La vista a escala (~1,500 tablas) refleja el volumen real de un core bancario SAP; la vista con filas valida la mecanica de transformacion/DQ/entity-resolution. El grafo se renderiza con `render_graph.py` (RE) + `adapt_to_data.py`.

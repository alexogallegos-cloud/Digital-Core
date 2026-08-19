# Unity — Programa de Modernización del Core Bancario BanCoppel
# project_type: core-banking-modernization
# project_state: active
# platform: Temenos Transact
# horizon_present: productos en producción sobre Temenos (pendiente de especificar)
# horizon_future: capabilities en construcción hacia sustitución o coexistencia con Informix
# replaces_or_complements: systems/core/Informix (baseline actual)

> **Tipo:** Proyecto de modernización (no es un sistema técnico — ver `systems/` para sistemas en producción)
> **Estado:** `[STATE: ACTIVE]` — productos en producción + construcción activa  
> **Release activo:** R4 — Tarjeta de Crédito Clásica Digital (Producto 4900) · Go-Live: enero 2027  
> **Última actualización:** 2026-08-19

---

## ¿Qué es Unity?

Unity es el **programa estratégico de BanCoppel para modernizar el core bancario**, basado en la plataforma **Temenos Transact**. Nació con la visión de sustituir el core actual (IBM Informix / PISA), lanzando primero productos nuevos sobre la plataforma moderna.

El programa opera en dos horizontes simultáneos:

| Horizonte | Descripción |
|-----------|-------------|
| **PRESENTE** | Productos ya en producción sobre Temenos Transact — knowledge verificado |
| **FUTURO** | Capabilities en construcción — knowledge incubado, sujeto a evolución |

> **Regla de oro:** Todo artefacto en este proyecto debe declarar explícitamente si describe el PRESENTE o el FUTURO. Nunca mezclar sin etiqueta.

---

## Relación con el Core Actual (Informix)

Los escenarios de coexistencia no están cerrados. Los posibles:

| Escenario | Descripción | Probabilidad actual |
|-----------|-------------|---------------------|
| **Sustitución total** | Unity reemplaza Informix capability por capability | Visión original — largo plazo |
| **Coexistencia permanente** | Ambos sistemas operan en dominios distintos indefinidamente | Escenario probable |
| **Híbrido** | Unity reemplaza algunos dominios; Informix persiste en otros | Escenario actual |

La `migration_fate` de los SPs Informix (registrada en `systems/core/Informix/digital-brain/brain.db`) refleja el estado actual de esta decisión por capability.

---

## Arquitectura del Brain del Proyecto

El `digital-brain/brain.db` de Unity acumula conocimiento **forward** — diferente al brain de Informix que analiza código existente.

| Tabla | Qué almacena |
|-------|-------------|
| `products` | Productos que Unity entrega (PRESENTE y FUTURO) |
| `capabilities` | Capabilities ETB cubiertas, en desarrollo, o planeadas |
| `decisions` | ADRs del programa (coexistencia, arquitectura, tecnología) |
| `coexistence_rules` | Reglas de routing entre Unity e Informix por canal/producto |
| `informix_migration_map` | Mapeo de capabilities Informix → Unity por status |
| `program_stakeholders` | Registro ejecutivo de stakeholders del programa (62 personas: sponsors, directores, track owners, equipo ACN, vendors — incluye alerts EY como competidor) |
| `capability_stakeholders` | SMEs ACN + arquitectos + owners por capability (RACI técnico) |

---

## Conexión con bank-brain

El `bank-brain` federa este brain para responder:
- ¿Qué capabilities ETB cubre Informix HOY en producción?
- ¿Qué capabilities tiene Unity en producción?
- ¿Qué capabilities están en construcción en Unity?
- ¿Qué gap queda sin cobertura en ninguno de los dos?

---

## Productos Unity

| ID | Producto | Status | Release | Plataforma | Informix: reemplaza / complementa |
|----|----------|--------|---------|------------|----------------------------------|
| UNITY-R1-P-CE-N2 | Cuenta Efectiva N2 | `live` | R1 | Temenos Transact | — |
| UNITY-R2-P-CED-N4 | Cuenta Efectiva Digital N4 | `live` | R2 | Temenos Transact | — |
| UNITY-R3-P-NOM-N4 | Nómina N4 | `live` | R3 | Temenos Transact | — |
| UNITY-RX-P-PS | Préstamo Simple | `live` | Rx* | Temenos Transact | — |
| UNITY-R4-P4900 | Tarjeta de Crédito Clásica Digital | `building` | R4 | SmartVista (BPC) + APOLO | CMS / Intercard / Macweb |

> *Rx: Release exacto de Préstamo Simple no confirmado. **DATO-REQUERIDO**: confirmar con PMO Unity.

Ver `dt/dt-productos.md` para el catálogo completo con componentes R4.

---

## Componentes R4

| ID | Nombre | Tipo | User Stories | Estado |
|----|--------|------|-----|--------|
| `smartvista` | SmartVista (BPC) | core | 22 | development |
| `apolo` | APOLO — Originación Digital | core | 22 | development |
| `app` | APP / AppMovil | channel | 18 | development |
| `cat` | CAT — Contact Center | channel | 12 | **at_risk** — proveedor no contratado |
| `siweb` | SIWEB — Sucursales | channel | 5 | **blocked** — esperando APIs |
| `cobranza` | Cobranza Direccionada | enabler | 37–50 | development |
| `apificacion` | Apificación (Accenture) | transversal | — | development |

---

## Cronograma R4

| Hito | Fecha | Estado |
|------|-------|--------|
| Cierre de análisis (último track) | 16 oct 2026 | pending |
| Cierre desarrollo + UT | 15 oct 2026 | pending |
| Inicio SIT | 15 oct 2026 | **at_risk** |
| Pentest Cobranza (conflicto SIT) | 15–20 nov 2026 | **at_risk** |
| Fin SIT / Code Freeze | 15 dic 2026 | pending |
| **Go-Live Producto 4900** | **~15 ene 2027** | pending |

Ver `dt/dt-cronograma.md` para el cronograma detallado con riesgos.

---

## Riesgos Críticos (resumen)

| ID | Descripción corta | Componente | Due Date |
|----|-------------------|-----------|----------|
| RISK-001 | Proveedor CAT no contratado | `cat` | 2026-08-31 |
| RISK-002 | 6 User Stories Must Have APP cierran en noviembre | `app` | 2026-10-01 |
| RISK-010 | Sin sign-off formal de negocio | transversal | 2026-09-15 |

Ver `dt/dt-riesgos.md` para los 10 riesgos con detalle completo.

---

## Decisiones de Arquitectura (ADRs del Programa)

| ID | Decisión | Status |
|----|----------|--------|
| ADR-UNITY-001 | Plataforma: Temenos Transact como nuevo core | Aceptada |
| ADR-UNITY-002 | *(pendiente: estrategia de coexistencia con Informix)* | Propuesta |
| ADR-UNITY-003 | *(pendiente: routing de canales por producto)* | Propuesta |
| ADR-UNITY-004 | SmartVista (BPC) como plataforma de gestión de tarjetas R4 | Aceptada |

---

## Digital Twins

| DT | Descripción | Archivo |
|----|-------------|---------|
| dt-productos | Catálogo de productos y componentes R4 | `dt/dt-productos.md` |
| dt-riesgos | Registro de 10 riesgos con mitigaciones | `dt/dt-riesgos.md` |
| dt-cronograma | Hitos R4 con semáforo de estado | `dt/dt-cronograma.md` |
| dt-smartvista | 58 HDUs · 14 DTMs · PreGame coverage · gaps críticos (DPP, BYU0039, OCG manual) | `dt/dt-smartvista.md` |
| dt-vendors | 8 vendors · SIAM model · CAT sin contratar (🔴 deadline 31-ago) · BYU0039 · DPP · maquiladores | `dt/dt-vendors.md` |
| dt-gobierno | Gobernanza del programa · comités · RACI · RAID owners · protocolo escalación | `dt/dt-gobierno.md` |
| dt-equipo | Equipo por componente · rotación 60% dic-ene · capacidad vs. demanda · change management | `dt/dt-equipo.md` |
| dt-coexistencia | Routing Informix↔Unity por canal/producto · tipos MONEY · migration_fate · parallel run | `dt/dt-coexistencia.md` |
| dt-slo-observabilidad | SLIs/SLOs por componente · criterios cuantitativos de cutover · business observability | `dt/dt-slo-observabilidad.md` |
| dt-sit-uat | Plan SIT/UAT por capability · conflicto pentest nov 15-20 · triage · criterios entrada/salida | `dt/dt-sit-uat.md` |
| dt-compliance | CNBV Art.76 LIC · PCI-DSS v4.0 scope SmartVista · CONDUSEF · timeline regulatorio | `dt/dt-compliance.md` |
| dt-ops-readiness | PRR por capability · runbooks · on-call model · DRP · rollback plan · handoff AMS | `dt/dt-ops-readiness.md` |
| dt-apolo | 37 HDUs · 17 BBs · plan integral 10 fases · 13 sprints backend · integración crítica SV (HDU-20) | `dt/dt-apolo.md` |
| dt-plan-director | Gobierno del programa por producto (TDC P4900) · KPI framework · 8 acciones críticas · RAG cruzado · anti-silos | `dt/dt-plan-director.md` |

---

## Fuentes Procesadas

| Carpeta | Status | Documentos |
|---------|--------|------------|
| `source/docs/Minuta de Sesiones/` | ✓ Procesada | 17 documentos (10 minutas + 7 sesiones trabajo User Stories) → `brain.db::track_analysis` (7 tracks) |
| `source/docs/RAID/` | ✓ Procesada | RAID_Log_Programa_Unity_R4_v2.0.xlsx — 18 riesgos, 4 supuestos, 3 issues, 2 dependencias · **Propuesta de RAID_R4.pptx — 3 slides · contexto de governance del RAID: por qué se creó, proceso de integración semanal, valor para Go/No-Go diciembre (solo contexto, datos ya en XLSX)** |
| `source/docs/Referencia Docs Bancoppel - Smart Vista y Canales/` | ✓ Procesada | HDU R4 canales (58 HDUs · 4 canals) + PreGame Appwhere → `dt/dt-smartvista.md` + `brain.db::hdu_catalog+dtm_catalog` |
| `source/docs/Referencia Docs Bancoppel - Plan de trabajo/` | ✓ Procesada | Plan de Trabajo XLSX (12-ago) → `brain.db::plan_progress` (11 actividades) · DEF PV ✓ · **Plan de trabajo R4_v1 Julio.pptx — baseline original: TDC=18 (SV=7+App=7+CAT=3+Promotoría=1) + Onboarding=27 (Apolo); scope out-of-scope confirmado (ATM, tarjetas adicionales, incrementos, corresponsales); R5 deferidos (cliente prospecto, retoma); stakeholders Barragán/Vázquez/Madinaveitia/Bueno; riesgos DTMs (R01) y Cobranza (R06) identificados desde julio → `dt/dt-cronograma.md` v1.1.0** |
| `source/docs/Referencia Docs Bancoppel -Apolo R4/` | ✓ Procesada | APOLO_R4_HDU_TDC.xlsm (37 HDUs) · Plan_Integral (10 fases, 13 sprints) → `dt-apolo.md` + `brain.db::apolo_hdu_catalog` · **ADP_Onboarding (17 DTMs REC_* · 8 Critical Breakers · equipo AppWhere · governance 5 comités) → `dt-apolo.md` v1.1.0** · **Plan Apolo N4 F2 (Gantt 151 días · tensión fechas 15-ene vs 22-ene) → `dt-apolo.md`** |
| `source/docs/Respaldo Docs Bancoppel - App/` | ✓ Procesada | 13 User Stories Jira (SMART-3962…4531) TDC F&D canal App → `brain.db::app_user_stories` |
| `source/docs/Roadmap Accenture/` | ✓ Procesada | BCPL_R4 Roadmap PPTX (5 tracks RAG · 8 acciones críticas · 9 User Stories R4.1) + Consolidacion User Stories v2 (76 User Stories scoring) + Inventario Integraciones v1.0 (18 integraciones) → `brain.db::user_stories_inventory + r4_integrations + track_rag` |

---

## brain.db — Estado v1.3.0 (2026-08-19)

| Tabla | Registros | Notas |
|-------|-----------|-------|
| `products` | 5 | 4 live (R1-R3+Rx) + 1 building (R4-P4900) |
| `program_capabilities` | 14 | Spine del brain — 1 configurable + 8 partial + 4 not_covered + 1 tbd |
| `hdu_catalog` | 58 | 4 canales: SV(22) APP(20) CAT(12) SIWEB(5) — todos con capability_id |
| `dtm_catalog` | 14 | 5 con gap crítico — todos con capability_id |
| `capability_vendors` | 22 | Vendor responsable por capability + status contrato |
| `capability_slos` | 14 | SLI/SLO targets por capability |
| `capability_test_plan` | 14 | Plan SIT/UAT por capability + bloqueantes |
| `capability_compliance` | 14 | CNBV Art.76 / PCI-DSS / CONDUSEF por capability |
| `capability_prr` | 14 | Production Readiness Review por capability |
| `capability_routing` | 11 | Routing Informix↔Unity por canal y capability |
| **`program_stakeholders`** | **62** | **Roster ejecutivo del programa: sponsors(2) + director(1) + PM(1) + track_owners(7) + pmo(3+1) + arquitectos(4) + acn(12) + vendors(6) + otros — incluye 15 alertas (4 EY competidor)** |
| `capability_stakeholders` | 49 | SMEs ACN + arquitectos del programa + owners BanCoppel por capability (RACI técnico) |
| **`program_systems`** | **11** | **Marco 3D — dimensión SISTEMA: smartvista · transact · informix · apolo · app-movil · siweb · cat · atlas · controlm · eglobal · connect-direct (togaf_type + togaf_state + vendor)** |
| **`it_capabilities`** | **16** | **Marco 3D — CAPACIDAD IT: 13 top-level + 3 sub-caps QE. Top-level: qe · devops · ambientacion · seguridad · interoperabilidad · data · arquitectura · change-mgmt · ai · release-management · vendor-management · observabilidad · compliance. Sub-caps QE (parent_id=qe): qe-strategy · qe-tem · qe-tdm** |
| `apolo_hdu_catalog` | 37 | HDUs de APOLO originación digital: 22 VoBo + 10 MVP2 + 3 Taggeo + 2 Desestimada |
| **`track_analysis`** | **7** | **User Stories por sesión de trabajo: SV/APOLO/APP/CAT/SIWEB/Cobranza/Apificación — complejidad, integraciones, MoSCoW** |
| **`plan_progress`** | **11** | **Plan de Trabajo 12-ago: global 20.66% vs 34% esperado — 9 retrasadas, 3 críticas** |
| **`product_vision_requirements`** | **28** | **RFs del DEF PV 1006626 — todos Alta/Esencial · canal: app(13) cat(4) cross(1) multi(4) siweb(2) smartvista(4)** |
| **`app_user_stories`** | **13** | **User Stories Jira canal App TDC F&D: backlog(8) release(3) removed(2) · SMART-3962…4531** |
| **`user_stories_inventory`** | **76** | **Inventario Accenture con scoring MoSCoW: must=43 should=28 could=2 wont=3 · tracks: SV(22)+Apolo(22)+App(15)+CAT(12)+SIWEB(5)** |
| **`r4_integrations`** | **18** | **Integraciones R4: API(15) Batch(2) Evento(1) · Nueva(9) Modificar(9) · SmartVista(7)+CAT(7)+APP(4)** |
| **`track_rag`** | **5** | **RAG por track (PPTX 11-ago): red=app,cat · yellow=smartvista,siweb,apolo · fuente: Roadmap Accenture** |
| `risks` | 18 | 9 alta + 8 media + 1 cerrado |
| `vocabulary` | 89 | RAID v2.0 + SmartVista/Canales |
| `decisions` | 4 | ADR-UNITY-001 a 004 |
| **`capability_360`** | **vista** | **Cross-join 7 dimensiones (vendors · SLOs · test · compliance · PRR · routing · stakeholders)** |

## Plan Director — DTs v1.0.0 (2026-08-16)

| DT Plan Director | Propósito | Status |
|-----------------|-----------|--------|
| dt-gobierno | Gobernanza, comités, RACI, escalación | ✓ v1.0.0 |
| dt-vendors | SIAM, 8 vendors, CAT urgente, BYU0039 | ✓ v1.0.0 |
| dt-equipo | Equipo, rotación, capacidad, change mgmt | ✓ v1.0.0 |
| dt-coexistencia | Routing Informix↔Unity, migration fate | ✓ v1.0.0 |
| dt-slo-observabilidad | SLOs, cutover criteria, observability | ✓ v1.0.0 |
| dt-sit-uat | Plan pruebas, pentest conflict, triage | ✓ v1.0.0 |
| dt-compliance | CNBV Art.76, PCI-DSS v4.0, CONDUSEF | ✓ v1.0.0 |
| dt-ops-readiness | PRR, runbooks, DRP, rollback, AMS | ✓ v1.0.0 |
| **dt-plan-director** | **Gestión transversal por producto · KPI framework · dashboard RAG cruzado** | **✓ v1.0.0** |

## Próximos Pasos

- [x] Cargar productos live en `brain.db::products` (R1-R3+Rx) — v0.4.0
- [x] Procesar carpeta RAID/ — 18 riesgos, 4 supuestos, 3 issues, 2 deps — v0.3.0
- [x] Procesar carpeta SmartVista y Canales — 58 HDUs, 14 DTMs, `dt-smartvista.md` — v0.4.0
- [x] Elevar capabilities a spine del brain (`program_capabilities` + FK en HDUs/DTMs) — v0.5.0
- [x] 8 DTs plan director creados — v1.0.0
- [ ] **SIGUIENTE**: Enriquecer `build-brain.py` con semántica y ontología cross-DT (v0.6.0)
- [x] Capa semántica/ontológica v0.6.0 — `capability_vendors`, `capability_slos`, `capability_test_plan`, `capability_compliance`, `capability_prr`, `capability_routing`, `capability_stakeholders` (49 rows: SMEs ACN + arquitectos + owners BCO), vista `capability_360` 7 dimensiones
- [x] v0.7.0 — `track_analysis` (7 sesiones User Stories: MoSCoW, complejidad, integraciones, APIficación scope) + `plan_progress` (Plan de Trabajo 12-ago: avance global 20.66% vs 34%, 9 retrasadas, 3 críticas)
- [x] Procesar `DEF PV 1006626 Mercado Abierto (R4).docx` — 28 RFs en `brain.db::product_vision_requirements` — v0.8.0
- [x] Procesar `Respaldo Docs Bancoppel - App/` — 13 User Stories Jira TDC F&D en `brain.db::app_user_stories` — v0.9.0
- [x] Procesar `Roadmap Accenture/` — 76 User Stories scoring + 18 integraciones + 5 tracks RAG en `brain.db::user_stories_inventory+r4_integrations+track_rag` — v1.0.0
- [x] **v1.1.0 — `program_stakeholders`: 62 personas del programa (sponsors·directores·track owners·acn·vendors·ey-competidor) extraídas de pd/ minutas (mar–abr 2026) + DTs + capability_stakeholders**
- [x] **v1.2.0 — Marco 3D PRODUCTO × SISTEMA × CAPACIDAD IT: `program_systems` (11) + `it_capabilities` (9, con madurez y lead) + ejes system_id/itcapability_ids en todo el RAID (18 riesgos + 3 issues) + system_id en user_stories_inventory (76 User Stories) y plan_progress + reclasificación program_components (7: 5 sistema · 1 producto · 1 itcapacity)**
- [x] **v1.3.0 — QE sub-capacidades: qe-strategy + qe-tem (TEM) + qe-tdm (TDM) con parent_id; non-prod-environments eliminada (absorbida en qe-tem); Issue I02 re-taggeado a qe-tem. Nuevas IT capabilities standalone: observabilidad (SLOs · dashboards negocio · audit trail regulatorio · trazabilidad cross-sistema) + compliance (CNBV Art.76 · PCI-DSS v4.0 SmartVista · CONDUSEF). Total: 16 filas (13 top-level + 3 sub-caps)**
- [ ] Mapear capabilities ETB de los productos live en `brain.db`
- [ ] Registrar ADR-UNITY-002 (coexistencia) + ADR-UNITY-003 (routing)
- [ ] Conectar al `bank-brain` vía ATTACH

---

*Creado: 2026-08-15 · Actualizado: 2026-08-19 (v1.3.0: QE sub-capacidades TEM+TDM; observabilidad + compliance como IT capabilities standalone — 16 filas en it_capabilities)*

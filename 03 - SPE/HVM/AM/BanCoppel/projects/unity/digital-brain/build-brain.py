"""
build-brain.py  --  Unity Project Brain Builder v1.7.0
Construye brain.db con el conocimiento incubado del programa Unity.
Fuente: forward-knowledge (productos, componentes, riesgos, cronograma, vocabulario)
        --  diferente al brain de Informix que analiza cÃ³digo existente.

Uso:
    python build-brain.py                  # build completo (incremental)
    python build-brain.py --reset          # borra y reconstruye desde cero

Changelog:
    0.9.0  --  2026-08-16  app_user_stories (13 User Stories canal App TDC F&D: backlog=8 release=3 removed=2)
    1.0.0  --  2026-08-16  user_stories_inventory (76 User Stories scoring) + r4_integrations (18) + track_rag (5 tracks RAG Roadmap)
    1.1.0  --  2026-08-19  user_stories_inventory (79 User Stories, +3 APP Encendido/Apagado TDC) + product_releases dual-plataforma
    1.7.0  --  2026-08-20  Gaps --reset cerrados: DDL completo con system_id/risk_id/hdu_id en todas las
                           -- tablas (risks, user_stories_inventory, dtm_catalog, hdu_catalog,
                           -- apolo_hdu_catalog, audit_findings) + load_system_id_mappings ampliado
                           -- (ALTER TABLE idempotentes + mapeo apificacion/reportes-regulatorios/NULL) +
                           -- load_dtm_risks (14 riesgos desde dtm_catalog, risk_id FK back) +
                           -- load_cobranza_placeholders (8 USs placeholder track cobranza)
    1.6.0  --  2026-08-20  Marco 3D STAKEHOLDER: program_stakeholders (96 personas integradas en pipeline) +
                           -- bancoppel(45) · accenture(12) · ey(4) · grupo_coppel(3) · otros(deloitte/bpc/appwhere/vendor)
                           -- FTS5 program_stakeholders_fts
    1.5.0  --  2026-08-20  Marco 3D SISTEMA: program_systems (11 sistemas TOGAF) +
                           -- it_capabilities (13 capacidades IT del programa) +
                           -- system_id en risks + system_id/itcapability_ids en user_stories_inventory
    1.4.0  --  2026-08-20  swarm2 QA: HDU-APP-R4-09 macro APP-MF-01→APP-MF-02
                           -- TA-SMARTVISTA integrations_api 7→5 (2 Batch)
                           -- TDC-R6 status retracted (DDL extended)
                           -- RISK-UNITY-R27 CAT sin proveedor (due 2026-08-31)
                           -- dt-appmovil.md RAG corrected YELLOW; DTs creados
    1.3.0  --  2026-08-20  Swarm QA: correcciones verificadas contra source/docs (5 agentes paralelos)
                           -- program_capabilities: 3 coverage_status corregidos (not_covered->partial:
                              CAP-CARD-MANUFACTURING, CAP-DEFERRED-PURCHASE, CAP-BALANCE-STATEMENT)
                           -- program_capabilities: 2 filas nuevas (CAP-ONBOARDING-DIGITAL + CAP-COLLECTIONS-ENGINE)
                           -- legacy_systems: IBM-BUS nombre corregido, BAJAWARE tipo, RISKLOGIC provider+tipo
                           -- legacy_systems: SOC plataforma, notas INTERACT/BRM-*/ONBASE enriquecidas
                           -- track_analysis: APP hu_total 18->20, integrations_total SmartVista/APP/Apolo
                           -- product_releases: TDC-R5 platform_release retractado, TDC-R6 retractado
                           -- risks: RISK-R20 fecha precision, RISK-R05 latencia P95 concreta
    1.2.0  --  2026-08-20  legacy_systems (14 sistemas ecosistema) + audit_findings (19 hallazgos barrido documental)
                           + reportes_regulatorios en program_components + RISK-UNITY-R19..R26 (Reportes Reg.)
    0.8.0  --  2026-08-16  product_vision_requirements (28 RFs Product Vision R4, todos Alta/Esencial)
    0.7.0  --  2026-08-16  track_analysis (7 sesiones User Stories: CAT/SIWEB/APOLO/APP/SV/Cobranza/APIf) +
                         plan_progress (Plan de Trabajo corte 17-ago: avance global 21.19% vs 60.58%  --  RETRASADO)
    0.6.1  --  2026-08-16  capability_stakeholders (49 rows RACI) + apolo_hdu_catalog (37 User Stories APOLO)
    0.6.0  --  2026-08-16  Capa semÃ¡ntica/ontolÃ³gica: capability_vendors, capability_slos,
                         capability_test_plan, capability_compliance, capability_prr,
                         capability_routing + vista capability_360  --  brain conecta todos los DTs
    0.5.0  --  2026-08-16  program_capabilities (14 caps de negocio R4), capability_id en hdu/dtm
    0.4.0  --  2026-08-16  SmartVista/Canales: hdu_catalog (58 User Stories), dtm_catalog (14 DTMs),
                         vocabulario SV (+52 terminos), 4 productos live (R1-R3+Rx)
    0.3.0  --  2026-08-14  RAID v2.0: risks(18), raid_assumptions(4), raid_issues(3), raid_dependencies(2)
    0.2.0  --  2026-08-14  Minutas R4: program_components, risks, milestones, vocabulary
    0.1.0  --  2026-08-15  Estructura inicial: products, capabilities, decisions, coexistence
"""

import sqlite3
import json
import argparse
from pathlib import Path
from datetime import datetime

DB_PATH  = Path(__file__).parent / "brain.db"
ROOT     = Path(__file__).parent.parent

# â"€â"€ Schema â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€

DDL = """
CREATE TABLE IF NOT EXISTS project_info (
    key   TEXT PRIMARY KEY,
    value TEXT
);

CREATE TABLE IF NOT EXISTS products (
    id                  TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    status              TEXT NOT NULL CHECK(status IN ('live','building','planned','retired')),
    launch_date         TEXT,
    temenos_module      TEXT,
    etb_capabilities    TEXT,
    informix_domains    TEXT,
    coexistence_mode    TEXT CHECK(coexistence_mode IN ('replaces','complements','parallel','unknown')),
    -- v1.1.0: Unity tiene DOS productos en alcance formal (documento CNBV), no cinco.
    -- cnbv-scope  = uno de los dos productos que el Documento de Arquitectura UNITY v1.0
    --               declara como alcance para revision y autorizacion de CNBV.
    -- prior-scope = producto de captacion en produccion sobre Transact, NO listado en ese
    --               documento. Pertenencia al programa sin confirmar (DATO-REQUERIDO).
    scope               TEXT CHECK(scope IN ('cnbv-scope','prior-scope')),
    notes               TEXT,
    updated_at          TEXT DEFAULT (datetime('now'))
);

-- Tren de releases por producto (v1.1.0) --------------------------------------
-- Existe porque hay DOS numeraciones que no se contradicen y confundirlas produce
-- cronogramas falsos: la del PRODUCTO y la de la PLATAFORMA. En SmartVista coinciden
-- (solo hospeda la TDC); en Transact difieren (hospeda varios productos, su tren va
-- por delante). El Credito Simple Empresarial esta en su R1 del producto, que corre
-- sobre Transact R4 de plataforma.
CREATE TABLE IF NOT EXISTS product_releases (
    id               TEXT PRIMARY KEY,
    product_id       TEXT REFERENCES products(id),
    release_label    TEXT,
    platform_release TEXT,
    scope            TEXT,
    status           TEXT CHECK(status IN ('productivo','building','backlog','sin-definir','abierto','retracted')),
    release_date     TEXT,
    functionalities  INTEGER,
    channels         TEXT,
    provenance       TEXT
);

CREATE TABLE IF NOT EXISTS program_components (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    type            TEXT CHECK(type IN ('core','channel','enabler','transversal')),
    hus_total       INTEGER,
    provider        TEXT,
    provider_status TEXT CHECK(provider_status IN ('contracted','pending','internal','tbd')),
    status          TEXT CHECK(status IN ('analysis','design','development','testing','done','blocked','at_risk')),
    product_id      TEXT REFERENCES products(id),
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS program_capabilities (
    id                  TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    domain              TEXT,
    bian_domain         TEXT,
    description         TEXT,
    mandatory_r4        INTEGER DEFAULT 1,
    coverage_status     TEXT CHECK(coverage_status IN ('native','configurable','partial','not_covered','tbd')),
    gap_type            TEXT CHECK(gap_type IN ('not_licensed','not_built','dependency','tbd')),
    gap_description     TEXT,
    blocker_id          TEXT,
    confidence          TEXT CHECK(confidence IN ('confirmed','inferred','assumed')),
    component_ids       TEXT,
    lifecycle_stage     TEXT CHECK(lifecycle_stage IN ('designed','in_dev','in_sit','in_uat','deployed','operating')),
    notes               TEXT,
    updated_at          TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS decisions (
    id          TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    status      TEXT CHECK(status IN ('proposed','accepted','deprecated','superseded')),
    context     TEXT,
    decision    TEXT,
    consequences TEXT,
    date        TEXT,
    updated_at  TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS coexistence_rules (
    id              TEXT PRIMARY KEY,
    description     TEXT NOT NULL,
    trigger_cond    TEXT,
    channels        TEXT,
    product_id      TEXT REFERENCES products(id),
    implemented     INTEGER DEFAULT 0,
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS informix_migration_map (
    id              TEXT PRIMARY KEY,
    informix_domain TEXT,
    informix_sp     TEXT,
    unity_product   TEXT REFERENCES products(id),
    migration_fate  TEXT CHECK(migration_fate IN ('replaces','complements','retires','out_of_scope','unknown')),
    migration_status TEXT CHECK(migration_status IN ('done','in_progress','planned','unknown')),
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS risks (
    id              TEXT PRIMARY KEY,
    raid_id         TEXT,
    description     TEXT NOT NULL,
    component_id    TEXT REFERENCES program_components(id),
    category        TEXT,
    impact          TEXT CHECK(impact IN ('critical','high','medium','low')),
    probability     TEXT CHECK(probability IN ('high','medium','low')),
    status          TEXT CHECK(status IN ('open','mitigated','closed','escalated')),
    mitigation      TEXT,
    due_date        TEXT,
    owner           TEXT,
    source          TEXT,
    notes           TEXT,
    tracks          TEXT,
    breach          INTEGER DEFAULT 0,
    updated_at      TEXT DEFAULT (datetime('now')),
    system_id       TEXT REFERENCES program_systems(id)
);

CREATE TABLE IF NOT EXISTS raid_assumptions (
    id              TEXT PRIMARY KEY,
    raid_id         TEXT,
    description     TEXT NOT NULL,
    component_id    TEXT REFERENCES program_components(id),
    relevance       TEXT CHECK(relevance IN ('critical','high','medium','low')),
    status          TEXT CHECK(status IN ('validated','pending','rejected')),
    validator       TEXT,
    validation_date TEXT,
    source          TEXT,
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS raid_issues (
    id              TEXT PRIMARY KEY,
    raid_id         TEXT,
    description     TEXT NOT NULL,
    component_id    TEXT REFERENCES program_components(id),
    category        TEXT,
    severity        TEXT CHECK(severity IN ('critical','high','medium','low')),
    current_impact  TEXT,
    remediation     TEXT,
    status          TEXT CHECK(status IN ('open','in_progress','resolved')),
    owner           TEXT,
    due_date        TEXT,
    source          TEXT,
    notes           TEXT,
    tracks          TEXT,
    breach          INTEGER DEFAULT 0,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS raid_dependencies (
    id              TEXT PRIMARY KEY,
    raid_id         TEXT,
    description     TEXT NOT NULL,
    successor       TEXT,
    predecessor     TEXT,
    severity        TEXT CHECK(severity IN ('severe','moderate','immaterial')),
    status          TEXT CHECK(status IN ('active','resolved','blocked')),
    due_date        TEXT,
    source          TEXT,
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS milestones (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    target_date     TEXT,
    status          TEXT CHECK(status IN ('pending','at_risk','achieved','missed')),
    component_id    TEXT REFERENCES program_components(id),
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS vocabulary (
    term            TEXT PRIMARY KEY,
    definition      TEXT NOT NULL,
    category        TEXT CHECK(category IN ('tecnico','proceso','negocio','proveedor','canal')),
    source          TEXT,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE VIRTUAL TABLE IF NOT EXISTS products_fts USING fts5(
    id, name, description, notes,
    content='products', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS program_capabilities_fts USING fts5(
    id, name, domain, description, gap_description, notes,
    content='program_capabilities', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS components_fts USING fts5(
    id, name, notes,
    content='program_components', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS risks_fts USING fts5(
    id, description, mitigation, notes,
    content='risks', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS issues_fts USING fts5(
    id, description, current_impact, remediation,
    content='raid_issues', content_rowid='rowid'
);

CREATE TABLE IF NOT EXISTS hdu_catalog (
    id              TEXT PRIMARY KEY,
    canal           TEXT CHECK(canal IN ('smartvista','app','cat','siweb')),
    funcionalidad_macro TEXT,
    narrativa_corta TEXT NOT NULL,
    pregame_status  TEXT CHECK(pregame_status IN ('native','configurable','partial','not_covered','tbd')),
    capability_id   TEXT REFERENCES program_capabilities(id),
    dtm_id          TEXT,
    hdus_asociadas  TEXT,
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now')),
    system_id       TEXT REFERENCES program_systems(id)
);

CREATE TABLE IF NOT EXISTS dtm_catalog (
    id              TEXT PRIMARY KEY,
    funcionalidad_macro TEXT,
    hdus_asociadas  TEXT,
    funcion         TEXT NOT NULL,
    status          TEXT CHECK(status IN ('native','configurable','partial','not_covered','tbd')),
    capability_id   TEXT REFERENCES program_capabilities(id),
    gap_description TEXT,
    canal           TEXT,
    notes           TEXT,
    updated_at      TEXT DEFAULT (datetime('now')),
    system_id       TEXT REFERENCES program_systems(id),
    risk_id         TEXT REFERENCES risks(id)
);

CREATE VIRTUAL TABLE IF NOT EXISTS hdu_fts USING fts5(
    id, canal, funcionalidad_macro, narrativa_corta, notes,
    content='hdu_catalog', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS dtm_fts USING fts5(
    id, funcionalidad_macro, funcion, gap_description,
    content='dtm_catalog', content_rowid='rowid'
);

-- User Stories de APOLO  --  37 historias de originaciÃ³n digital (fuente: APOLO_R4_HDU_TDC.xlsm)
CREATE TABLE IF NOT EXISTS apolo_hdu_catalog (
    id              TEXT PRIMARY KEY,            -- HDU-TDC-R4-NN
    descripcion     TEXT NOT NULL,
    building_blocks TEXT,                        -- BBs impactados (CSV)
    epica           TEXT,                        -- Fuente/Ã©pica funcional
    mvp_scope       TEXT CHECK(mvp_scope IN ('mvp1','mvp2','taggeo','desestimada')),
    status          TEXT,                        -- VoBo / MVP2 / Taggeo por Modyo / Desestimada
    capability_id   TEXT REFERENCES program_capabilities(id),
    criterios_count INTEGER DEFAULT 0,           -- nÃºmero de CAs
    notes           TEXT,
    system_id       TEXT REFERENCES program_systems(id)
);

-- â"€â"€ AnÃ¡lisis de tracks por sesiÃ³n (v0.7.0) â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
-- Fuente: minutas de sesiones de trabajo User Stories (3-7 agosto 2026)
CREATE TABLE IF NOT EXISTS track_analysis (
    id                  TEXT PRIMARY KEY,           -- TA-{TRACK}
    track               TEXT NOT NULL,              -- smartvista, apolo, app, cat, siweb, cobranza, apificacion
    session_date        TEXT,                       -- fecha de la sesiÃ³n de trabajo
    hu_total            INTEGER DEFAULT 0,
    hu_must             INTEGER DEFAULT 0,          -- Must Have (MoSCoW)
    hu_should           INTEGER DEFAULT 0,          -- Should Have
    hu_could            INTEGER DEFAULT 0,          -- Could Have
    hu_wont             INTEGER DEFAULT 0,          -- Won't (diferidas)
    hu_tipo_solucion    INTEGER DEFAULT 0,          -- solo soluciÃ³n (sin integraciones)
    hu_tipo_integracion INTEGER DEFAULT 0,          -- solo integraciones
    hu_tipo_mixta       INTEGER DEFAULT 0,          -- soluciÃ³n + integraciones
    complexity_low      INTEGER DEFAULT 0,          -- baja
    complexity_mid      INTEGER DEFAULT 0,          -- media
    complexity_high     INTEGER DEFAULT 0,          -- alta
    complexity_pending  INTEGER DEFAULT 0,          -- pendiente de confirmar
    integrations_total  INTEGER,                    -- integraciones identificadas (null = sin confirmar)
    integrations_api    INTEGER,                    -- tipo API
    integrations_event  INTEGER,                    -- tipo evento/batch
    apificacion_scope   TEXT,                       -- alcance del equipo de ApificaciÃ³n en este track
    key_risk            TEXT,                       -- riesgo crÃ­tico identificado en la sesiÃ³n
    key_decision        TEXT,                       -- decisiÃ³n o punto de atenciÃ³n crÃ­tico
    source_doc          TEXT,                       -- nombre del documento fuente
    notes               TEXT
);

-- â"€â"€ Avance del Plan de Trabajo (v0.7.0) â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
-- Fuente: Plan de Trabajo UNITY R4_12082026.xlsx (corte 16-ago-2026)
CREATE TABLE IF NOT EXISTS plan_progress (
    id                  TEXT PRIMARY KEY,           -- PP-{SEQ}
    track               TEXT NOT NULL,              -- canal/track (smartvista, app, apolo, cat, ...)
    activity_id         TEXT,                       -- ID numÃ©rico del plan (1.1, 1.2, etc.)
    activity            TEXT NOT NULL,              -- descripciÃ³n de la actividad
    responsible         TEXT,                       -- responsable (BPC, AppWhere, persona)
    start_date          TEXT,                       -- fecha inicio
    end_date            TEXT,                       -- fecha fin
    pct_real            REAL,                       -- avance real %
    pct_expected        REAL,                       -- avance esperado %
    deviation           REAL,                       -- desviaciÃ³n (real - esperado)
    status              TEXT CHECK(status IN ('on_time','delayed','at_risk','blocked','completed')),
    blocker_note        TEXT,                       -- comentario de bloqueo
    as_of_date          TEXT DEFAULT '2026-08-16'   -- fecha de corte del dato
);

-- -- Product Vision Requirements (v0.8.0) -----------------------------------
-- Fuente: DEF PV 1006626 Mercado Abierto (R4 ).docx (Sergio Arellano Payan)
-- 28 Requisitos Funcionales del Product Vision R4 -- todos Alta/Esencial
CREATE TABLE IF NOT EXISTS product_vision_requirements (
    id              TEXT PRIMARY KEY,
    rf_num          INTEGER,
    name            TEXT NOT NULL,
    priority        TEXT NOT NULL CHECK(priority IN ('alta','media','baja')),
    moscow          TEXT CHECK(moscow IN ('must','should','could','wont')),
    channel         TEXT,
    capability_id   TEXT REFERENCES program_capabilities(id),
    description     TEXT,
    business_rules  TEXT,
    actors          TEXT,
    systems_involved TEXT,
    scope_product   TEXT,
    source_doc      TEXT DEFAULT 'DEF PV 1006626 Mercado Abierto (R4 ).docx',
    notes           TEXT
);

-- App User Stories (v0.9.0) -------------------------------------------------
-- Fuente: Respaldo US-20260805T010347Z-1-001.zip (13 tickets Jira SMART-XXXX)
-- Canal App: User Stories de TDC F&D -- gestion tarjeta, movimientos, activacion, pagos
CREATE TABLE IF NOT EXISTS app_user_stories (
    smart_id        TEXT PRIMARY KEY,
    title           TEXT NOT NULL,
    estado          TEXT CHECK(estado IN ('backlog','release','removed')),
    resolucion      TEXT,
    canal           TEXT DEFAULT 'app',
    capability_id   TEXT REFERENCES program_capabilities(id),
    has_unity_r4_label INTEGER DEFAULT 0,
    assignee        TEXT,
    pages           INTEGER,
    nota            TEXT,
    source_doc      TEXT DEFAULT 'Respaldo US-20260805T010347Z-1-001.zip'
);

-- User Story Inventory (v1.0.0) -------------------------------------------------------
-- Fuente: Consolidacion y priorizacion_HUs_R4_v2.xlsx (Inventario User Stories sheet)
-- 79 User Stories Accenture con scoring MoSCoW + complejidad ponderada
-- Tracks: smartvista(22), apolo(22), app(18), cat(12), siweb(5)
--
-- v1.1.0 (2026-08-20): se agregaron las 3 User Stories Must de "Encendido y Apagado TDC Fisica y
-- Digital" del track APP, que el cargador anterior descartaba. Causa raiz: en el xlsx esas
-- filas NO TIENEN valor en la columna "ID HU" (arrancan directo en Track), y el cargador
-- las omitia al no poder derivar la clave primaria. Se les asigna un ID sintetico APP-ENC-nn
-- y se documenta la ausencia de ticket Jira en source_doc.
-- Con esto el total pasa de 76 a 79 y APP de 15 a 18, que es lo que reportan tanto el deck
-- BCPL_R4 Roadmap_Remediaciones_v1_11082026 ("User Stories validadas 18 | 15 Must, 1 Could, 2 Won't")
-- como la minuta del 06-ago-2026 del track APP.
CREATE TABLE IF NOT EXISTS user_stories_inventory (
    id              TEXT PRIMARY KEY,
    track           TEXT,
    title           TEXT NOT NULL,
    producto        TEXT,
    funcionalidad   TEXT,
    moscow          TEXT CHECK(moscow IN ('must','should','could','wont')),
    tipo_solucion   TEXT,
    impacto_solucion TEXT,
    reusabilidad    TEXT,
    num_integraciones INTEGER DEFAULT 0,
    num_criterios   INTEGER DEFAULT 0,
    num_pantallas   INTEGER DEFAULT 0,
    score_ponderado REAL,
    complejidad     TEXT,
    source_doc      TEXT DEFAULT 'Consolidacion y priorizacion_HUs_R4_v2.xlsx',
    system_id       TEXT REFERENCES program_systems(id),
    itcapability_ids TEXT,
    hdu_id          TEXT REFERENCES hdu_catalog(id)
);

-- R4 Integrations (v1.0.0) ----------------------------------------------------
-- Fuente: Inventario de Integraciones_HUs_ R4_v1.0.xlsx
-- 18 integraciones: API(15) Batch(2) Evento(1) | Nueva(9) Modificar(9)
-- Tracks: smartvista(7), cat(7), app(4)
CREATE TABLE IF NOT EXISTS r4_integrations (
    id              TEXT PRIMARY KEY,
    hu_id           TEXT REFERENCES user_stories_inventory(id),
    track           TEXT,
    hu_title        TEXT,
    nombre          TEXT,
    descripcion     TEXT,
    sistema_origen  TEXT,
    sistema_destino TEXT,
    tipo            TEXT,
    formato         TEXT,
    frecuencia      TEXT,
    complejidad     TEXT,
    existe_hoy      INTEGER DEFAULT 0,
    estado          TEXT,
    source_doc      TEXT DEFAULT 'Inventario de Integraciones_HUs_ R4_v1.0.xlsx'
);

-- Track RAG (v1.0.0) ----------------------------------------------------------
-- Fuente: BCPL_R4 Roadmap_Remediaciones_v1_11082026.pptx slides 17-20
-- RAG por track: rag_color in (red, yellow, green)
CREATE TABLE IF NOT EXISTS track_rag (
    track                   TEXT PRIMARY KEY,
    rag_color               TEXT CHECK(rag_color IN ('red','yellow','green')),
    hu_total                INTEGER,
    hu_must                 INTEGER,
    hu_should               INTEGER,
    hu_could                INTEGER,
    hu_wont                 INTEGER,
    integraciones_count     INTEGER,
    rag_general             TEXT,
    rag_solucion            TEXT,
    rag_integraciones       TEXT,
    tipo_solucion_detail    TEXT,
    impacto_solucion_detail TEXT,
    complejidad_detail      TEXT,
    source_date             TEXT DEFAULT '2026-08-11'
);

-- â"€â"€ Capa semÃ¡ntica v0.6.1 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
-- Cada tabla conecta una capability con una dimensiÃ³n del programa.
-- La vista capability_360 consolida las 6 dimensiones en una sola consulta.

CREATE TABLE IF NOT EXISTS capability_vendors (
    id              TEXT PRIMARY KEY,
    capability_id   TEXT NOT NULL REFERENCES program_capabilities(id),
    vendor_id       TEXT NOT NULL,
    vendor_name     TEXT NOT NULL,
    role            TEXT CHECK(role IN ('primary','support','governance')),
    contract_status TEXT CHECK(contract_status IN ('contracted','pending','tbd')),
    open_tickets    TEXT,
    risk_note       TEXT,
    dt_source       TEXT DEFAULT 'dt-vendors'
);

CREATE TABLE IF NOT EXISTS capability_slos (
    id                      TEXT PRIMARY KEY,
    capability_id           TEXT NOT NULL REFERENCES program_capabilities(id),
    slo_availability_pct    REAL,
    slo_latency_p95_ms      INTEGER,
    slo_latency_p99_ms      INTEGER,
    slo_error_rate_pct      REAL,
    slo_tps_min             INTEGER,
    measurement_window      TEXT,
    status                  TEXT CHECK(status IN ('defined','pending','blocked')),
    notes                   TEXT,
    dt_source               TEXT DEFAULT 'dt-slo-observabilidad'
);

CREATE TABLE IF NOT EXISTS capability_test_plan (
    id                  TEXT PRIMARY KEY,
    capability_id       TEXT NOT NULL REFERENCES program_capabilities(id),
    sit_included        INTEGER DEFAULT 1,
    sit_status          TEXT CHECK(sit_status IN ('planned','blocked','not_applicable')),
    sit_blocker         TEXT,
    uat_included        INTEGER DEFAULT 1,
    uat_signer          TEXT,
    test_cases_planned  INTEGER,
    test_type           TEXT,
    notes               TEXT,
    dt_source           TEXT DEFAULT 'dt-sit-uat'
);

CREATE TABLE IF NOT EXISTS capability_compliance (
    id              TEXT PRIMARY KEY,
    capability_id   TEXT NOT NULL REFERENCES program_capabilities(id),
    cnbv_art76      INTEGER DEFAULT 0,
    pci_dss_scope   INTEGER DEFAULT 0,
    condusef_scope  INTEGER DEFAULT 0,
    regulation_note TEXT,
    deadline        TEXT,
    status          TEXT CHECK(status IN ('compliant','pending','blocked','not_applicable')),
    dt_source       TEXT DEFAULT 'dt-compliance'
);

CREATE TABLE IF NOT EXISTS capability_prr (
    id                  TEXT PRIMARY KEY,
    capability_id       TEXT NOT NULL REFERENCES program_capabilities(id),
    runbook_done        INTEGER DEFAULT 0,
    oncall_assigned     INTEGER DEFAULT 0,
    slo_configured      INTEGER DEFAULT 0,
    rollback_tested     INTEGER DEFAULT 0,
    drp_covered         INTEGER DEFAULT 0,
    prr_approved        INTEGER DEFAULT 0,
    prr_blocker         TEXT,
    dt_source           TEXT DEFAULT 'dt-ops-readiness'
);

CREATE TABLE IF NOT EXISTS capability_routing (
    id              TEXT PRIMARY KEY,
    capability_id   TEXT NOT NULL REFERENCES program_capabilities(id),
    channel         TEXT CHECK(channel IN ('app','cat','siweb','cobranza','apificacion','all')),
    pre_r4_route    TEXT,
    post_r4_route   TEXT,
    switch_mechanism TEXT,
    parallel_run    INTEGER DEFAULT 0,
    notes           TEXT,
    dt_source       TEXT DEFAULT 'dt-coexistencia'
);

CREATE TABLE IF NOT EXISTS capability_stakeholders (
    id                  TEXT PRIMARY KEY,
    capability_id       TEXT NOT NULL REFERENCES program_capabilities(id),
    name                TEXT NOT NULL,
    stakeholder_type    TEXT CHECK(stakeholder_type IN ('acn_sme','program_architect','bancoppel_owner','vendor_contact')),
    raci_role           TEXT CHECK(raci_role IN ('responsible','accountable','consulted','informed')),
    organization        TEXT,
    sme_path            TEXT,
    contact_note        TEXT,
    dt_source           TEXT DEFAULT 'dt-equipo + dt-gobierno'
);

CREATE VIRTUAL TABLE IF NOT EXISTS stakeholders_fts USING fts5(
    id, name, capability_id, stakeholder_type, organization, contact_note
);

-- Vista capability_360: responde preguntas cross-dimensiÃ³n sin JOINs manuales
CREATE VIEW IF NOT EXISTS capability_360 AS
SELECT
    c.id,
    c.name,
    c.domain,
    c.bian_domain,
    c.coverage_status,
    c.gap_type,
    c.blocker_id,
    c.mandatory_r4,
    -- vendor primario
    cv.vendor_name,
    cv.contract_status          AS vendor_contract,
    cv.open_tickets             AS vendor_open_tickets,
    -- SME ACN responsable
    sme.name                    AS acn_sme,
    sme.sme_path                AS acn_sme_path,
    -- arquitecto del programa (responsible/accountable en BanCoppel o ACN)
    arch.name                   AS program_architect,
    arch.organization           AS architect_org,
    -- slos
    cs.slo_availability_pct,
    cs.slo_latency_p95_ms,
    cs.slo_error_rate_pct,
    cs.status                   AS slo_status,
    -- test plan
    ct.sit_included,
    ct.sit_status,
    ct.sit_blocker,
    ct.uat_included,
    -- compliance
    cc.cnbv_art76,
    cc.pci_dss_scope,
    cc.condusef_scope,
    cc.status                   AS compliance_status,
    -- prr
    cp.runbook_done,
    cp.oncall_assigned,
    cp.rollback_tested,
    cp.prr_approved,
    cp.prr_blocker
FROM program_capabilities c
LEFT JOIN capability_vendors cv ON cv.capability_id = c.id AND cv.role = 'primary'
LEFT JOIN (
    SELECT capability_id,
           GROUP_CONCAT(name, ' / ')    AS name,
           GROUP_CONCAT(sme_path, ' | ') AS sme_path
    FROM   capability_stakeholders
    WHERE  stakeholder_type = 'acn_sme' AND raci_role = 'responsible'
    GROUP BY capability_id
) sme  ON sme.capability_id = c.id
LEFT JOIN (
    SELECT capability_id,
           GROUP_CONCAT(name, ' / ')       AS name,
           GROUP_CONCAT(organization, ' / ') AS organization
    FROM   capability_stakeholders
    WHERE  stakeholder_type IN ('program_architect','bancoppel_owner')
      AND  raci_role IN ('responsible','accountable')
    GROUP BY capability_id
) arch ON arch.capability_id = c.id
LEFT JOIN capability_slos cs        ON cs.capability_id = c.id
LEFT JOIN capability_test_plan ct   ON ct.capability_id = c.id
LEFT JOIN capability_compliance cc  ON cc.capability_id = c.id
LEFT JOIN capability_prr cp         ON cp.capability_id = c.id;

-- Legacy Systems inventory (v1.2.0) -----------------------------------------
-- Sistemas del legado y plataforma TO-BE descubiertos en barrido documental
-- 2026-08-19. Captura quienes comparten el ecosistema con Unity.
CREATE TABLE IF NOT EXISTS legacy_systems (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    acronym         TEXT,
    type            TEXT CHECK(type IN ('core-app','middleware','channel','mdm','dwh','rules-engine','regulatory-reporting','risk-management','document-mgmt','scheduler','auth','rpa','other')),
    provider        TEXT,
    platform        TEXT,
    description     TEXT,
    unity_relation  TEXT CHECK(unity_relation IN ('coexists','to-replace','to-decommission','complementary','data-source','unknown')),
    core_path       INTEGER DEFAULT 0,
    discovered_via  TEXT,
    notes           TEXT
);

-- Audit findings (v1.2.0) ----------------------------------------------------
-- Hallazgos del barrido de 257 documentos del corpus Unity (2026-08-19).
CREATE TABLE IF NOT EXISTS audit_findings (
    id              TEXT PRIMARY KEY,
    category        TEXT NOT NULL CHECK(category IN ('cifra-huerfana','correccion','ambiguedad','hallazgo','dato-requerido')),
    title           TEXT NOT NULL,
    description     TEXT,
    impact          TEXT CHECK(impact IN ('critical','high','medium','low')),
    status          TEXT DEFAULT 'open' CHECK(status IN ('open','resolved','watchlist')),
    verified_date   TEXT DEFAULT '2026-08-19',
    source_doc      TEXT,
    notes           TEXT,
    system_id       TEXT REFERENCES program_systems(id),
    risk_id         TEXT REFERENCES risks(id)
);

CREATE TABLE IF NOT EXISTS lifecycle_phase_steps (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    phase_id    TEXT NOT NULL,
    step_n      INTEGER NOT NULL,
    paso        TEXT NOT NULL,
    sistema     TEXT NOT NULL,
    us_id       TEXT DEFAULT '—',
    us_title    TEXT DEFAULT '',
    fuente      TEXT DEFAULT 'manual' CHECK(fuente IN ('manual','brain')),
    UNIQUE(phase_id, step_n)
);
CREATE TABLE IF NOT EXISTS program_systems (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    vendor          TEXT,
    togaf_type      TEXT NOT NULL CHECK(togaf_type IN ('core','processors','channels','data','integration','compliance')),
    togaf_state     TEXT NOT NULL CHECK(togaf_state IN ('baseline','transitional','target')),
    togaf_abb       TEXT,
    role_in_r4      TEXT,
    status          TEXT DEFAULT 'active' CHECK(status IN ('active','at_risk','planned','retired')),
    notes           TEXT
);

CREATE TABLE IF NOT EXISTS it_capabilities (
    id                  TEXT PRIMARY KEY,
    name                TEXT NOT NULL,
    description         TEXT,
    category            TEXT,
    owner_component     TEXT,
    owner_name          TEXT,
    maturity_current    INTEGER DEFAULT 1,
    maturity_target     INTEGER DEFAULT 4,
    next_action         TEXT,
    next_action_due     TEXT,
    next_action_owner   TEXT
);

CREATE TABLE IF NOT EXISTS program_stakeholders (
    id              TEXT PRIMARY KEY,
    full_name       TEXT NOT NULL,
    organization    TEXT NOT NULL
        CHECK(organization IN ('bancoppel','grupo_coppel','accenture','ey','deloitte','bpc','appwhere','vendor','unknown')),
    role_title      TEXT,
    program_role    TEXT NOT NULL
        CHECK(program_role IN (
            'executive_sponsor','program_director','program_manager',
            'track_owner','product_owner','delivery_lead','pmo','pmo_financial',
            'architect','internal_consultant','vendor_lead','vendor_team',
            'acn_lead','acn_team','acn_ams','acn_global_expert',
            'operations','stakeholder','former_vendor','delivery','unknown'
        )),
    raci            TEXT CHECK(raci IN ('responsible','accountable','consulted','informed','tbd')),
    seniority       TEXT CHECK(seniority IN ('executive','director','manager','specialist','coordinator','support','unknown')),
    confidence      TEXT CHECK(confidence IN ('confirmed','inferred','assumed')) DEFAULT 'confirmed',
    alert           TEXT,
    relevant_notes  TEXT,
    source_docs     TEXT,
    active          INTEGER DEFAULT 1,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE VIRTUAL TABLE IF NOT EXISTS program_stakeholders_fts USING fts5(
    id, full_name, organization, role_title, program_role, relevant_notes,
    content='program_stakeholders', content_rowid='rowid'
);

-- ── Duplicidad Funcional — Swarm DT-SWAP (v1.7.0) ────────────────────────────────────
-- 23 candidatos de duplicidad funcional entre sistemas Unity y sistemas legado.
-- Producido por 8 agentes DT (DT-SWAP-01..08). Cada entrada es un CANDIDATO: requiere
-- analisis tecnico detallado antes de decidir el escenario final.
-- status: candidate → analyzing → decided → closed
-- recommended_scenario: coexistence | decommission | complement | absorb | migrate | tbd
CREATE TABLE IF NOT EXISTS functional_duplicity (
    id                   TEXT PRIMARY KEY,         -- DUP-NNN
    dt_agent             TEXT NOT NULL,             -- DT-SWAP-NN que genero el registro
    capability_domain    TEXT NOT NULL,             -- dominio funcional
    etb_capability       TEXT,                      -- L3 ETB si aplica
    legacy_system        TEXT NOT NULL,             -- sistema legado (slug legacy_systems)
    legacy_capability    TEXT,                      -- capacidad especifica en legado
    legacy_evidence      TEXT,                      -- evidencia cuantitativa
    new_system           TEXT NOT NULL,             -- sistema Unity (slug program_systems)
    new_capability       TEXT,                      -- capacidad especifica en Unity
    overlap_type         TEXT CHECK(overlap_type IN ('full','partial','potential','to_confirm')),
    scenarios            TEXT,                      -- JSON [{type, probability, condition}]
    recommended_scenario TEXT CHECK(recommended_scenario IN
                             ('sustituir','convivir','complemento','analizar')),
    scenario_confidence  TEXT CHECK(scenario_confidence IN ('high','medium','low')),
    migration_blocker    INTEGER DEFAULT 0,          -- 1 si bloquea decommission del legado
    blocker_description  TEXT,                      -- que especificamente bloquea
    decision_dependency  TEXT,                      -- que decision previa se necesita
    evidence             TEXT,                      -- fuente documental
    status               TEXT DEFAULT 'candidate' CHECK(status IN
                             ('candidate','analyzing','decided','closed')),
    notes                TEXT,
    updated_at           TEXT DEFAULT (datetime('now'))
);

CREATE VIRTUAL TABLE IF NOT EXISTS functional_duplicity_fts USING fts5(
    id, capability_domain, legacy_system, legacy_capability, new_system, new_capability, notes,
    content='functional_duplicity', content_rowid='rowid'
);

"""

# â"€â"€ Datos â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€

PROJECT_INFO = {
    "project_name":      "Unity",
    "program_type":      "core-banking-modernization",
    "platform":          "Temenos Transact",
    "client":            "BanCoppel",
    "state":             "active",
    "brain_version":     "1.6.0",
    "built_at":          datetime.now().isoformat(),
    "scope_note":        "PRESENTE (en produccion) + FUTURO (en construccion  --  R4 Producto 4900)",
}

# â"€â"€ Capabilities de negocio del programa Unity R4 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
# Organizadas por dominio bancario. Cada capability agrupa uno o mÃ¡s DTMs y un
# conjunto de User Stories. Es el eje central del brain: todo lo demÃ¡s cuelga de aquÃ­.

PROGRAM_CAPABILITIES = [
    # â"€â"€ MAQUILA â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-CARD-MANUFACTURING",
        "name":             "Fabricacion y Maquila de Tarjetas",
        "domain":           "maquila",
        "bian_domain":      "Issued Device Administration",
        "description":      "Calcular, solicitar y controlar la fabricacion de tarjetas fisicas con maquiladores "
                            "(GID, Forza, TGS). Incluye calculo de abasto, generacion segura de archivos "
                            "(PGP+HSM), envio via Connect Direct y seguimiento de lotes.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Calculo automatico de abasto (piso, semanas, redondeo 250) no nativo en SmartVista. "
                            "OCG y Connect Direct manuales en R4 (tickets #13830642 y #13830651).",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories R4-01 a R4-08. DTMs: CalculateCardManufacturing (not_covered) + "
                            "ExecuteCardManufacturingRequest (partial). Solicitud manual nativa (R4-05 + R4-06). "
                            "GAP-3 operativo: OCG y Cargen manuales en R4 (tickets #13830642 y #13830651 pendientes). "
                            "2 User Stories nativas (R4-05/06) + 5 parciales + 1 not_covered (R4-03 calculo automatico).",
    },
    # â"€â"€ AUTORIZADOR â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-AUTHORIZATION",
        "name":             "Autorizacion de Transacciones",
        "domain":           "autorizador",
        "bian_domain":      "Credit Card Authorization",
        "description":      "Autorizar transacciones en tiempo real via E-Global  ->  SmartVista (88 reglas BPC): "
                            "Modulo 1 rechazo ISO y Modulo 2 evaluacion de riesgo con PayTrue.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Autorizador base nativo; integracion completa con PayTrue como delta de R4. "
                            "SVFM no licenciado; PayTrue sustituye la funcion de fraude.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Story R4-11. DTM: ValidateBPCAuthorization. Flujo: Comercio -> E-Global -> SV -> PayTrue. "
                            "SVFM NO licenciado por BanCoppel — PayTrue sustituye SVFM como motor antifraude. "
                            "Sin integracion PayTrue completa no hay capa de fraude en el autorizador.",
    },
    #â"€â"€ CICLO DE VIDA DE LA TARJETA â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-CARD-LIFECYCLE",
        "name":             "Gestion del Ciclo de Vida de la Tarjeta",
        "domain":           "cartera",
        "bian_domain":      "Card Case",
        "description":      "Gestionar estados CSTS de tarjeta fisica y digital (bloqueo, desbloqueo, "
                            "reposicion, reemplazo, cancelacion definitiva). Campo Classification F/D.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Transiciones especificas de estado y limite de reposiciones como delta. "
                            "Cancelacion definitiva con aviso de impactos a definir.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "cat"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories R4-17, R4-18, APP-R4-02/04/05/11/12/13, CAT-R4-05/06/07/11/12. "
                            "DTM: ManageCardCancellationReport.",
    },
    # â"€â"€ SALDO A FAVOR â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-OVERPAYMENT",
        "name":             "Gestion de Saldo a Favor",
        "domain":           "cartera",
        "bian_domain":      "Consumer Loan / Credit Facility",
        "description":      "Parametrizar, validar y comunicar el limite de saldo a favor por tramo de "
                            "linea de credito. Rechazo completo cuando abono excede el limite (sin poliza parcial). "
                            "Excluir abonos SPEI hasta clearing.",
        "mandatory_r4":     1,
        "coverage_status":  "tbd",
        "gap_type":         "dependency",
        "gap_description":  "Comportamiento exacto no determinado hasta cierre del ticket BYU0039 en ValueEdge "
                            "('Opened, in investigation'). Afecta SmartVista (R4-13) y SIWEB (SIWEB-R4-05).",
        "blocker_id":       "BYU0039",
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "siweb"]),
        "lifecycle_stage":  "designed",
        "notes":            "User Stories R4-12/13/14, APP-R4-18/19/20, SIWEB-R4-05. "
                            "DTMs: ManageOverpaymentLimit + ValidateOverpaymentLimit (ambos tbd). "
                            "Parametrizacion (R4-12) es configurable; validacion en runtime es el gap. "
                            "APP-R4-18/19/20 = NOT COVERED (validacion middleware + homologacion mensajes "
                            "entre canales — build independiente del ticket BYU0039).",
    },
    #â"€â"€ COMPRAS DIFERIDAS â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-DEFERRED-PURCHASE",
        "name":             "Compras Diferidas MSI/MCI y CrediSoluciones",
        "domain":           "cartera",
        "bian_domain":      "Installment Plan / Credit Card",
        "description":      "Gestionar planes de pago diferido: MSI (via E-Global, sin intereses) y MCI "
                            "(CrediSoluciones, con intereses). Incluye contabilizacion (TRNT 623, Grupo contable 13), "
                            "liquidacion anticipada y cancelacion de planes activos.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_licensed",
        "gap_description":  "GAP CRITICO: modulo DPP (Deferred Payment Plan) de BPC no contratado para R4. "
                            "Cancelacion de CrediSoluciones no posible. MCI App diferido a R4.5.",
        "blocker_id":       "DPP-GAP",
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "siweb", "app"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories R4-16/19/20/21, APP-R4-09/14/15/16, SIWEB-R4-02/03/04. "
                            "DTMs: CancelDeferredPurchasePlan (not_covered) + SettleDeferredPurchasePlan (partial) "
                            "+ ManageDeferredPurchase (partial) + RegisterDeferredPurchaseAccountingEffects (partial). "
                            "Cuenta 2402/Eglobal NO aplica a MCI; solo MSI interchange. "
                            "Gap dual: DPP not_licensed solo para cancelacion (HDU-R4-21, SIWEB-R4-03); "
                            "User Stories parciales (SIWEB-R4-02, SMART-R4-20, todos los App) = not_built integraciones.",
    },
    #â"€â"€ SALDOS Y ESTADO DE CUENTA â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-BALANCE-STATEMENT",
        "name":             "Consulta de Saldos y Estado de Cuenta",
        "domain":           "cartera",
        "bian_domain":      "Credit Card Position Keeping",
        "description":      "Consultar saldos (disponible, limite, PPNGI, MAD), movimientos del periodo "
                            "(incluyendo pre-autorizaciones amountHoldPlaced), y estado de cuenta completo "
                            "desde App, SIWEB, CAT e IVR.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Integracion IVR-SVIP completa a construir (CAT-R4-02 y R4-08). "
                            "App y SIWEB parciales via getInstantCreditStatement + getTransactions v22.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "cat", "siweb"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories APP-R4-01/07/08, CAT-R4-02/08, SIWEB-R4-01. "
                            "DTM: RetrieveCreditCardBalanceAndMovements (not_covered para IVR). "
                            "APIs: getInstantCreditStatement, getTransactions v22, campo agingPeriod.",
    },
    # â"€â"€ PAGOS â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-PAYMENT",
        "name":             "Procesamiento de Pagos",
        "domain":           "pagos",
        "bian_domain":      "Payment Order",
        "description":      "Procesar pagos a TDC desde App: MAD, PPNGI, total o monto libre. "
                            "Validaciones preventivas de inputs y restricciones por nivel de mora.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Validaciones preventivas de inputs en frontend (APP-R4-20) como delta. "
                            "PPNGI y MAD calculados en SmartVista; exposicion correcta via API como delta.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories APP-R4-10, SMART-R4-19. PPNGI != MAD; ambos en getInstantCreditStatement.",
    },
    # â"€â"€ PERFIL DEL CLIENTE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-CUSTOMER-PROFILE",
        "name":             "Perfil del Cliente y Tarjeta",
        "domain":           "cartera",
        "bian_domain":      "Party Reference Data / Customer Agreement",
        "description":      "Consultar y gestionar el perfil del cliente y su TDC en canales digitales y CAT. "
                            "Incluye detalle de tarjeta, CVV dinamico y datos de cuenta (credito 18 digitos).",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "APIs SVIP disponibles; integracion completa ICCAT para CAT a construir. "
                            "CVV dinamico con timer de visibilidad como delta en App.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "cat"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories APP-R4-04/05/06, CAT-R4-03/07. DTM: RetrieveCustomerCreditCardProfile. "
                            "APIs: getAccountCards, getCardInfo. Credito 18 digitos != PAN 16 digitos.",
    },
    # â"€â"€ AUTOSERVICIO EN CANALES â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-CHANNEL-SELFSERVICE",
        "name":             "Autoservicio en Canales (App / CAT / SIWEB / IVR)",
        "domain":           "canales",
        "bian_domain":      "Contact Handler / Interactive Help",
        "description":      "Habilitar autoservicio de TDC en los 4 canales: App movil, Contact Center (CAT), "
                            "Banca por Internet (SIWEB) e IVR (800 BanCoppel). Consultas, bloqueos, "
                            "reportes y operaciones sin agente humano.",
        "mandatory_r4":     1,
        "coverage_status":  "not_covered",
        "gap_type":         "not_built",
        "gap_description":  "Proveedor CAT no contratado (RISK-UNITY-R27, due 2026-08-31). "
                            "IVR menu dinamico por mora (CAT-R4-10) y autenticacion DTMF (CAT-R4-09) sin definir.",
        "blocker_id":       "RISK-UNITY-R27",
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["app", "cat", "siweb"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories CAT-R4-01, SIWEB general. RISK-UNITY-R27 es el riesgo de mayor urgencia del programa. "
                            "IVR requiere integracion completa SVIP (92 comandos disponibles).",
    },
    # â"€â"€ AUTENTICACION Y SEGURIDAD â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-AUTHENTICATION",
        "name":             "Autenticacion y Seguridad de Canal",
        "domain":           "seguridad",
        "bian_domain":      "Security Administration",
        "description":      "Autenticar al cliente en canales digitales y telefonicos: OTP SMS 4 digitos, "
                            "ANI, DTMF, intentos maximos. Templates SMS para bloqueo/desbloqueo (MAI_BDT_IC, SMS_BDT_IC).",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Flujos de autenticacion en CAT (R4-04 hasta R4-09) dependen de proveedor no contratado. "
                            "OTP y ANI especificados; implementacion pendiente del proveedor.",
        "blocker_id":       "RISK-UNITY-R27",
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["app", "cat"]),
        "lifecycle_stage":  "designed",
        "notes":            "User Stories CAT-R4-03/04/06/09, APP-R4-06. Max 3 intentos IVR antes de transferir agente. "
                            "OTP 4 digitos para desbloqueo (no SMS largo).",
    },
    # â"€â"€ COBRANZA Y MORA â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-COLLECTIONS-AGING",
        "name":             "Cobranza y Restricciones por Mora",
        "domain":           "cobranza",
        "bian_domain":      "Debt Recovery / Credit Card Collections",
        "description":      "Gestionar restricciones y comunicaciones segun nivel de mora: "
                            "E1 (0-1 meses, sin restriccion), E2 (2-3, parcial), E3 (4+, bloqueo mayoritario). "
                            "Bloquear botones de accion y adaptar menus IVR dinamicamente.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Logica de restriccion visual en App (botones por agingPeriod) y menu dinamico "
                            "IVR (CAT-R4-10) como delta. SmartVista calcula agingPeriod nativamente.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "cat"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories APP-R4-03/17, CAT-R4-10. Campo agingPeriod en getInstantCreditStatement. "
                            "Componente Cobranza Direccionada (37-50 User Stories) es el motor subyacente.",
    },
    # â"€â"€ COMISIONES Y CATALOGOS â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-FEE-COMMISSION",
        "name":             "Comisiones, Anualidades y Catalogos BANXICO",
        "domain":           "catalogo",
        "bian_domain":      "Service Fees and Charges",
        "description":      "Parametrizar comisiones y anualidades de la TDC en catalogo centralizado SmartVista "
                            "homologado con BANXICO. Incluye mensajes de error estandarizados.",
        "mandatory_r4":     1,
        "coverage_status":  "configurable",
        "gap_type":         None,
        "gap_description":  None,
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Story R4-09. Solo requiere parametrizacion de valores BanCoppel en catalogo SV existente.",
    },
    # â"€â"€ CONTABILIDAD â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-ACCOUNTING-INTEGRATION",
        "name":             "Integracion Contable (TRNT / PISA)",
        "domain":           "contabilidad",
        "bian_domain":      "Financial Accounting",
        "description":      "Registrar efectos contables de operaciones TDC en PISA via TRNT: "
                            "compras diferidas MCI (Grupo contable 13), pagos CrediSoluciones (TRNT 623). "
                            "Flujo: SmartVista  ->  TRNT  ->  PISA.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Guia contable formal para TDC pendiente de entrega. Afecta SIWEB-R4-04. "
                            "MCI: Grupo contable 13 (capital no corriente); NO recircular por cuenta 2402/Eglobal.",
        "blocker_id":       None,
        "confidence":       "inferred",
        "component_ids":    json.dumps(["smartvista", "siweb"]),
        "lifecycle_stage":  "designed",
        "notes":            "User Story SIWEB-R4-04. DTM: RegisterDeferredPurchaseAccountingEffects. "
                            "TRNT 623 = 'PAGO CGO A CTA DE CREDISOLUCIONES'. RAID-D01 dependencia.",
    },
    # â"€â"€ CATALOGO DE ERRORES â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "CAP-ERROR-CATALOG",
        "name":             "Catalogo de Errores y Mensajes",
        "domain":           "catalogo",
        "bian_domain":      "Reference Data Management",
        "description":      "Gestionar catalogo centralizado de mensajes de error y nombre de producto "
                            "en SmartVista. Los 3 canales (App, SIWEB, CAT) consumen el catalogo en "
                            "lugar de hardcodear valores.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "Catalogo SV existe y funciona; App, SIWEB y CAT deben modificarse para "
                            "consumirlo dinamicamente en lugar de tener valores hardcodeados.",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["smartvista", "app", "siweb", "cat"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "User Stories SMART-R4-10 (nombre producto) y SMART-R4-15 (mensajes error, 3 canales). "
                            "Homologacion BANXICO para mensajes de rechazo.",
    },
    # ── ORIGINACION DIGITAL (APOLO) ──────────────────────────────────────────
    # Agregada v1.3.0: 37 User Stories documentados, integración crítica con SV (HDU-20)
    {
        "id":               "CAP-ONBOARDING-DIGITAL",
        "name":             "Originacion Digital (Apolo)",
        "domain":           "originacion",
        "bian_domain":      "Party Life Cycle Management / Product Directory",
        "description":      "Onboarding digital de la TDC desde solicitud hasta activacion. "
                            "37 User Stories: 22 VoBo AppWhere (MVP1) + 3 Taggeo Modyo + 10 MVP2 + 2 Desestimadas. "
                            "Flow Engineering: 4 semanas de diseno. Integracion critica con SmartVista (HDU-20).",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "22 DTMs REC_* identificados (6 Atomico, 9 Orquestado, 2 Regla de Negocio, 5 No Aplica). "
                            "8 Critical Breakers identificados. Latencia P95 actual = 9,000ms vs SLO 5,000ms (out-of-SLO).",
        "blocker_id":       None,
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["apolo", "smartvista"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "37 User Stories Apolo R4. MVP1: 25 total (22 VoBo + 3 Taggeo). MVP2: 10 (fuera scope ene-2027). "
                            "Integracion critica SV HDU-20 (firma electronica + expediente digital OnBase BB16). "
                            "Tech stack R3: Spring Boot 3.4.5 + Java 21 + EKS + Istio + Apigee + YugabyteDB + Redis. "
                            "Identity: Entra ID (Azure AD). Edge: Cloudflare + Cloud Armor. 17 DTMs totales.",
    },
    # ── MOTOR DE COBRANZA DIRECCIONADA ───────────────────────────────────────
    # Agregada v1.3.0: componente cross-canal con 37-50 User Stories, habilita CAP-COLLECTIONS-AGING
    {
        "id":               "CAP-COLLECTIONS-ENGINE",
        "name":             "Motor de Cobranza Direccionada",
        "domain":           "cobranza",
        "bian_domain":      "Collections / Delinquent Account Handling",
        "description":      "Motor subyacente que habilita restricciones por mora en canales digitales "
                            "y Contact Center. Incluye evolucion del modelo de datos BPC, adecuaciones "
                            "SmartVista y construccion de componentes de cobranza direccionada.",
        "mandatory_r4":     1,
        "coverage_status":  "partial",
        "gap_type":         "not_built",
        "gap_description":  "37-50 User Stories pendientes de incorporar al inventario unificado. "
                            "Plan de trabajo aun sin formalizar (RISK-UNITY-R06). "
                            "Conflict pentest 15-20 nov vs inicio SIT 15-oct.",
        "blocker_id":       "RISK-UNITY-R06",
        "confidence":       "confirmed",
        "component_ids":    json.dumps(["cobranza", "smartvista", "app", "cat"]),
        "lifecycle_stage":  "in_dev",
        "notes":            "37-50 User Stories (rango pendiente de confirmar). Build planificado: "
                            "construccion/UT fin agosto - mediados septiembre. Motor de CAP-COLLECTIONS-AGING. "
                            "Campo agingPeriod en getInstantCreditStatement = superficie visible para canales.",
    },
]

# â"€â"€ Mapeo User Story  ->  Capability â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
HDU_CAPABILITY_MAP = {
    # SmartVista  --  maquila
    "HDU-SMART-R4-01": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-02": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-03": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-04": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-05": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-06": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-07": "CAP-CARD-MANUFACTURING",
    "HDU-SMART-R4-08": "CAP-CARD-MANUFACTURING",
    # SmartVista  --  otros dominios
    "HDU-SMART-R4-09": "CAP-FEE-COMMISSION",
    "HDU-SMART-R4-10": "CAP-ERROR-CATALOG",
    "HDU-SMART-R4-11": "CAP-AUTHORIZATION",
    "HDU-SMART-R4-12": "CAP-OVERPAYMENT",
    "HDU-SMART-R4-13": "CAP-OVERPAYMENT",
    "HDU-SMART-R4-14": "CAP-OVERPAYMENT",
    "HDU-SMART-R4-15": "CAP-ERROR-CATALOG",
    "HDU-SMART-R4-16": "CAP-DEFERRED-PURCHASE",
    "HDU-SMART-R4-17": "CAP-CARD-LIFECYCLE",
    "HDU-SMART-R4-18": "CAP-CARD-LIFECYCLE",
    "HDU-SMART-R4-19": "CAP-PAYMENT",
    "HDU-SMART-R4-20": "CAP-DEFERRED-PURCHASE",
    "HDU-SMART-R4-21": "CAP-DEFERRED-PURCHASE",
    # App
    "HDU-APP-R4-01": "CAP-BALANCE-STATEMENT",
    "HDU-APP-R4-02": "CAP-CARD-LIFECYCLE",
    "HDU-APP-R4-03": "CAP-COLLECTIONS-AGING",
    "HDU-APP-R4-04": "CAP-CUSTOMER-PROFILE",
    "HDU-APP-R4-05": "CAP-CUSTOMER-PROFILE",
    "HDU-APP-R4-06": "CAP-AUTHENTICATION",
    "HDU-APP-R4-07": "CAP-BALANCE-STATEMENT",
    "HDU-APP-R4-08": "CAP-BALANCE-STATEMENT",
    "HDU-APP-R4-09": "CAP-DEFERRED-PURCHASE",
    "HDU-APP-R4-10": "CAP-PAYMENT",
    "HDU-APP-R4-11": "CAP-CARD-LIFECYCLE",
    "HDU-APP-R4-12": "CAP-CARD-LIFECYCLE",
    "HDU-APP-R4-13": "CAP-CARD-LIFECYCLE",
    "HDU-APP-R4-14": "CAP-DEFERRED-PURCHASE",
    "HDU-APP-R4-15": "CAP-DEFERRED-PURCHASE",
    "HDU-APP-R4-16": "CAP-DEFERRED-PURCHASE",
    "HDU-APP-R4-17": "CAP-COLLECTIONS-AGING",
    "HDU-APP-R4-18": "CAP-OVERPAYMENT",
    "HDU-APP-R4-19": "CAP-OVERPAYMENT",
    "HDU-APP-R4-20": "CAP-OVERPAYMENT",
    # CAT
    "HDU-CAT-R4-01": "CAP-CHANNEL-SELFSERVICE",
    "HDU-CAT-R4-02": "CAP-BALANCE-STATEMENT",
    "HDU-CAT-R4-03": "CAP-CUSTOMER-PROFILE",
    "HDU-CAT-R4-04": "CAP-AUTHENTICATION",
    "HDU-CAT-R4-05": "CAP-CARD-LIFECYCLE",
    "HDU-CAT-R4-06": "CAP-CARD-LIFECYCLE",
    "HDU-CAT-R4-07": "CAP-CARD-LIFECYCLE",
    "HDU-CAT-R4-08": "CAP-BALANCE-STATEMENT",
    "HDU-CAT-R4-09": "CAP-AUTHENTICATION",
    "HDU-CAT-R4-10": "CAP-COLLECTIONS-AGING",
    "HDU-CAT-R4-11": "CAP-CARD-LIFECYCLE",
    "HDU-CAT-R4-12": "CAP-CARD-LIFECYCLE",
    # SIWEB
    "HDU-SIWEB-R4-01": "CAP-BALANCE-STATEMENT",
    "HDU-SIWEB-R4-02": "CAP-DEFERRED-PURCHASE",
    "HDU-SIWEB-R4-03": "CAP-DEFERRED-PURCHASE",
    "HDU-SIWEB-R4-04": "CAP-ACCOUNTING-INTEGRATION",
    "HDU-SIWEB-R4-05": "CAP-OVERPAYMENT",
}

# â"€â"€ Mapeo DTM  ->  Capability â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
DTM_CAPABILITY_MAP = {
    "DTM_CalculateCardManufacturing":               "CAP-CARD-MANUFACTURING",
    "DTM_ExecuteCardManufacturingRequest":           "CAP-CARD-MANUFACTURING",
    "DTM_CancelDeferredPurchasePlan":               "CAP-DEFERRED-PURCHASE",
    "DTM_SettleDeferredPurchasePlan":               "CAP-DEFERRED-PURCHASE",
    "DTM_ManageOverpaymentLimit":                   "CAP-OVERPAYMENT",
    "DTM_ValidateOverpaymentLimit":                 "CAP-OVERPAYMENT",
    "DTM_ValidateBPCAuthorization":                 "CAP-AUTHORIZATION",
    "DTM_ManageDeferredPurchase":                   "CAP-DEFERRED-PURCHASE",
    "DTM_RegisterDeferredPurchaseAccountingEffects":"CAP-ACCOUNTING-INTEGRATION",
    "DTM_RetrieveCreditCardBalanceAndMovements":    "CAP-BALANCE-STATEMENT",
    "DTM_RetrieveCustomerCreditCardProfile":        "CAP-CUSTOMER-PROFILE",
    "DTM_ManageCardCancellationReport":             "CAP-CARD-LIFECYCLE",
    "NO-DTM-SMART-R4-10":                          "CAP-ERROR-CATALOG",
    "NO-DTM-SMART-R4-15":                          "CAP-ERROR-CATALOG",
}

INITIAL_PRODUCTS = [
    # â"€â"€ Productos ya en produccion (PRESENTE) â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "UNITY-R1-P-CE-N2",
        "name":             "Cuenta Efectiva N2",
        "description":      "Cuenta de deposito a la vista Nivel 2, primer producto lanzado en Unity. "
                            "Opera sobre Temenos Transact. Cumple KYC simplificado nivel 2 CNBV.",
        "status":           "live",
        "launch_date":      None,
        "temenos_module":   "Temenos Transact",
        "etb_capabilities": json.dumps(["demand-deposit","basic-account-management"]),
        "informix_domains": json.dumps(["Cuentas","Depositos"]),
        "coexistence_mode": "complements",
        "scope":            "prior-scope",
        "notes":            "FUERA del alcance formal de DOS productos. Producto de captacion en produccion sobre Temenos Transact, NO listado entre los dos productos del documento CNBV. DATO-REQUERIDO: confirmar si fue entregado por releases anteriores de Unity o si nunca pertenecio al programa; el Roadmap Unity 2025 etiqueta el bloque como 'CUENTAS - N2/N4 (Legado)'. El numero de release TAMPOCO tiene fuente: el Design Authority declara que Transact tiene 'Releases R1-R4' y que R4 es Prestamo Simple, pero nunca dice que R1, R2 y R3 sean estos productos; la unica fuente con granularidad (de EY) mapea los releases de Transact a GRUPOS DE CAPACIDAD, no a productos, y no contiene R3. El ID conserva el numero por compatibilidad, pero no debe presentarse como dato verificado. Pendiente relacionado L-07: discrepancia declarada entre EY y el roadmap maestro sobre las fechas de Transact R1 y R2.",
    },
    {
        "id":               "UNITY-R2-P-CED-N4",
        "name":             "Cuenta Efectiva Digital N4",
        "description":      "Cuenta de deposito a la vista Nivel 4, producto 100% digital con apertura remota. "
                            "Opera sobre Temenos Transact con canal AppMovil.",
        "status":           "live",
        "launch_date":      None,
        "temenos_module":   "Temenos Transact",
        "etb_capabilities": json.dumps(["demand-deposit","digital-channel","digital-onboarding"]),
        "informix_domains": json.dumps(["Cuentas","Depositos","CanalDigital"]),
        "coexistence_mode": "complements",
        "scope":            "prior-scope",
        "notes":            "FUERA del alcance formal de DOS productos. Producto de captacion en produccion sobre Temenos Transact, NO listado entre los dos productos del documento CNBV. DATO-REQUERIDO: confirmar si fue entregado por releases anteriores de Unity o si nunca pertenecio al programa; el Roadmap Unity 2025 etiqueta el bloque como 'CUENTAS - N2/N4 (Legado)'. El numero de release TAMPOCO tiene fuente: el Design Authority declara que Transact tiene 'Releases R1-R4' y que R4 es Prestamo Simple, pero nunca dice que R1, R2 y R3 sean estos productos; la unica fuente con granularidad (de EY) mapea los releases de Transact a GRUPOS DE CAPACIDAD, no a productos, y no contiene R3. El ID conserva el numero por compatibilidad, pero no debe presentarse como dato verificado. Pendiente relacionado L-07: discrepancia declarada entre EY y el roadmap maestro sobre las fechas de Transact R1 y R2.",
    },
    {
        "id":               "UNITY-R3-P-NOM-N4",
        "name":             "Nomina N4",
        "description":      "Cuenta de nomina Nivel 4 para empleados de empresas convenio. "
                            "Opera sobre Temenos Transact con beneficios de nomina configurados.",
        "status":           "live",
        "launch_date":      None,
        "temenos_module":   "Temenos Transact",
        "etb_capabilities": json.dumps(["payroll-account","demand-deposit","benefit-management"]),
        "informix_domains": json.dumps(["Nomina","Cuentas","Empresas"]),
        "coexistence_mode": "complements",
        "scope":            "prior-scope",
        "notes":            "FUERA del alcance formal de DOS productos. Producto de captacion en produccion sobre Temenos Transact, NO listado entre los dos productos del documento CNBV. DATO-REQUERIDO: confirmar si fue entregado por releases anteriores de Unity o si nunca pertenecio al programa; el Roadmap Unity 2025 etiqueta el bloque como 'CUENTAS - N2/N4 (Legado)'. El numero de release TAMPOCO tiene fuente: el Design Authority declara que Transact tiene 'Releases R1-R4' y que R4 es Prestamo Simple, pero nunca dice que R1, R2 y R3 sean estos productos; la unica fuente con granularidad (de EY) mapea los releases de Transact a GRUPOS DE CAPACIDAD, no a productos, y no contiene R3. El ID conserva el numero por compatibilidad, pero no debe presentarse como dato verificado. Pendiente relacionado L-07: discrepancia declarada entre EY y el roadmap maestro sobre las fechas de Transact R1 y R2.",
    },
    {
        "id":               "UNITY-RX-P-PS",
        "name":             "Credito Simple Empresarial",
        "description":      "Credito simple para PERSONA MORAL (empresarial). El promotor crea la solicitud, "
                            "integra el Expediente (INE, RFC, CURP, comprobante de domicilio), hace analisis "
                            "basico y genera la carpeta empresarial con datos generales, representante legal, "
                            "direccion, identificacion oficial, escritura constitutiva, poderes notariales, "
                            "cedula y CURP del representante. El analista centralizador asigna la solicitud, "
                            "valida y solicita el alta de cliente, beneficiario y cuenta. Soportado por OnBase, "
                            "PISA y Temenos Transact. Modulos Transact: garantias colaterales, prestamos de "
                            "modelo, prestamos y montos dispuestos de lineas.",
        "status":           "live",
        "launch_date":      None,
        "temenos_module":   "Temenos Transact (CBS)",
        "etb_capabilities": json.dumps(["corporate-lending","credit-origination",
                                        "collateral-management","regulatory-reporting"]),
        "informix_domains": json.dumps(["Credito","Garantias","CobranzaDireccionada"]),
        "coexistence_mode": "complements",
        "scope":            "cnbv-scope",
        "notes":            "PRODUCTO 2 de los DOS del alcance formal segun el Documento de Arquitectura "
                            "UNITY v1.0 (para revision y autorizacion de CNBV). "
                            "ESTADO: R1 del producto EN PRODUCTIVO, confirmado por el equipo 2026-08-19; "
                            "coherente con el Roadmap Unity 2025 que lo muestra en Pruebas, Transicion y "
                            "Estabilizacion. Antes estuvo registrado como 'planned' y como 'live' sin fuente. "
                            "RELEASE, DOS NUMERACIONES QUE NO SE CONTRADICEN: el producto esta en su R1, que "
                            "corre sobre TRANSACT R4 (release de plataforma que habilita el ciclo de vida de "
                            "credito). El Design Authority dice 'Releases R1-R4. Prestamo Simple es Transact "
                            "R4, no Apolo' refiriendose al tren de PLATAFORMA. Segun la fuente de EY, Transact "
                            "R4 habilita originaciones, pago de creditos y amortizaciones, reestructuracion y "
                            "procesamiento de cheques. El Roadmap NO le asigna numero: etiqueta sus barras "
                            "como 'CSE' en paralelo a las R1, R2 y R3 del carril de TDC. "
                            "L-02 REINTERPRETADA: como el producto YA opera, la decision abierta "
                            "'Estrategia Prestamo Simple: F&F vs migracion de cartera' NO es sobre el arranque "
                            "sino sobre que se hace con la CARTERA EMPRESARIAL del legado, que vive en Orion "
                            "SFI (proveedor TASF) con destino declarado 'Migrar a Temenos Transact'. "
                            "Consistente con sus entregables E-MG-03 (decision paper) y E-MG-06 (plan de "
                            "migracion, condicionado a que el paper resulte en migracion). "
                            "VARIANTES FUTURAS: el roadmap registra 'Analisis - Nuevos Productos (CSE "
                            "Variantes | Cuenta Corriente | Factoraje)'. "
                            "DATO-REQUERIDO: el Design Authority lo llama 'Prestamo Simple' y el documento "
                            "CNBV 'Credito Simple Empresarial'. Ningun documento equipara ambos nombres.",
    },
    # â"€â"€ Producto en construccion (FUTURO) â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {
        "id":               "UNITY-R4-P4900",
        "name":             "Tarjeta de Credito",
        "description":      "TDC de BanCoppel sobre SmartVista (BPC), documentada como 'Administrador de "
                            "Tarjetas' y 'CMS (Card Management System)'. Numero de credito de 18 digitos "
                            "(cuenta clave = clave interbancaria). Reemplaza CMS/Intercard/Macweb. "
                            "Portafolio mas amplio que la Clasica: Oro (8100), Platinum (7000), Clasica "
                            "(6001), Clasica Apolo (4900), Grupo Coppel e Infinite; parametrico para nuevos.",
        "status":           "building",
        "launch_date":      "2027-01-15",
        "temenos_module":   "SmartVista (BPC Banking Technologies)",
        "etb_capabilities": json.dumps(["card-issuance","credit-origination","collections","digital-channel"]),
        "informix_domains": json.dumps(["TDC","Credito","Cobranza","CMS"]),
        "coexistence_mode": "replaces",
        "scope":            "cnbv-scope",
        "notes":            "PRODUCTO 1 de los DOS del alcance formal segun el Documento de Arquitectura "
                            "UNITY v1.0 (para revision y autorizacion de CNBV). "
                            "EL PRODUCTO NO NACE EN R4: opera en produccion desde dic-2024. R4 es el cuarto "
                            "release y lo que agrega es la TDC Clasica completa. Ver product_releases. "
                            "R1 (dic-2024, 38 func, SIN canales) = configuracion del gestor de TDC. "
                            "R2 (jul-2025, 33 func) = integracion a App y onboarding. "
                            "R3 (sep-2025, 15 func) = TARJETA FISICA liberada en modo Friends & Family. "
                            "R4 (ene-2027, 13 func) = TDC Clasica, Producto 4900, release ancla, SIT 15-oct "
                            "a 15-dic-2026. R4.5 = MCI en App. R5 y R6 sin alcance definido. "
                            "R1, R2 y R3 EN PRODUCTIVO (equipo 2026-08-19). "
                            "F&F es el MODO de liberacion, no el alcance: no es excluyente con 'tarjeta "
                            "fisica'. Una lectura previa lo planteo como dicotomia y era falso. "
                            "PROPOSITO DE R3: cerrar la brecha de valor entre el producto que Apolo origina "
                            "(4900) y el legado (6001) para habilitar la MIGRACION DE 3 MILLONES DE TARJETAS; "
                            "estimacion de 122,000 clientes nuevos 2025-2026. "
                            "OJO: el 'R4' de este producto es SmartVista R4 y coexiste con un Transact R4 "
                            "distinto, que es el Credito Simple Empresarial. Dos R4 simultaneos en "
                            "plataformas distintas; igual colision en R3. "
                            "L-01 ABIERTA: escenario de despliegue R4 sin decidir, Esc.1 (4 despliegues en "
                            "Q4-2026) contra Esc.2 (unico en dic-2026). "
                            "BIN 42680711 = BIN 426807 mas subproducto 11. Parcializaciones MSI/MCI. "
                            "Origen y maquila de tarjetas via Connect-Direct.",
    },
]

# ── Tren de releases por producto (v1.1.0) ───────────────────────────────────
# Dos numeraciones que no se contradicen: la del PRODUCTO y la de la PLATAFORMA.
# En SmartVista coinciden (solo hospeda la TDC); en Transact difieren.
# La columna provenance distingue lo que es cita literal de lo que confirmo el equipo.
PRODUCT_RELEASES = [
    ("TDC-R1", "UNITY-R4-P4900", "R1", "SmartVista R1",
     "Configuracion del gestor de TDC (SmartVista como CMS)", "productivo", "2024-12", 38,
     None,
     "Equipo 2026-08-19. Sustento: 38 funcionalidades y ningun canal listado = configuracion de "
     "plataforma, no producto cliente. Senial estructural fuerte: canal-less + 38 funcionalidades "
     "= configuracion del gestor. 'CMS Administrador de Tarjetas' es el termino del roadmap."),
    ("TDC-R2", "UNITY-R4-P4900", "R2", "SmartVista R2",
     "Tarjeta de Crédito Digital / Onboarding", "productivo", "2025-07", 33,
     "App, Promotoria, Sucursal, SPEI",
     "Equipo 2026-08-19. Sustento: las cadenas 'CMS Administrador de Tarjetas - Apolo Onboarding' y "
     "'CMS Administrador de Tarjetas - App Bancoppel', mas el encabezado del roadmap ('todo su ciclo "
     "de vida: Onboarding, Operacion y Post-Venta')."),
    ("TDC-R3", "UNITY-R4-P4900", "R3", "SmartVista R3",
     "Tarjeta de Crédito Física", "productivo", "2025-09", 15,
     "App, Promotoria, Sucursal, Aclaraciones",
     "Equipo 2026-08-19 MAS cita literal: el DEF se titula 'DEF Tarjeta fisica R3 desglozado Historia "
     "de Usuario'. F&F es el MODO de liberacion, no el alcance: no son excluyentes. Su proposito real "
     "es cerrar la brecha de valor entre el 4900 de Apolo y el legado 6001 para habilitar la migracion "
     "de 3 millones de tarjetas. Dependencia critica de ATLAS a sep-2026 (decision L-03)."),
    ("TDC-R4", "UNITY-R4-P4900", "R4", "SmartVista R4",
     "Tarjeta de Crédito Clásica P4900", "building", "2027-01", 13,
     "App, Promotoria, Sucursal, CAT",
     "RAID v2.0, plan de trabajo y minutas de ago-2026. SIT 15-oct a 15-dic-2026, go-live a mediados "
     "de enero 2027 (las minutas dicen 'mediados', no un dia concreto). L-01 abierta: escenario de "
     "despliegue sin decidir entre 4 despliegues en Q4-2026 o uno unico en dic-2026."),
    ("TDC-R4.5", "UNITY-R4-P4900", "R4.5", "SmartVista R4.5",
     "Meses con intereses (MCI) en App", "backlog", None, None, "App",
     "El Design Authority nombra R4.5 pero no declara su alcance; el alcance viene del PreGame via "
     "dt-smartvista. TENSION SIN CERRAR: las fuentes de julio dicen R4.5 y las de agosto (06-ago y "
     "11-ago) dicen R5 para la integracion con canal. El backend de MCI si va en R4."),
    ("TDC-R5", "UNITY-R4-P4900", "R5", None,
     "Sin alcance definido", "sin-definir", None, None, None,
     "Roadmap Unity 2025 y Gestion_Track 06-jul-2026 ('TDC Clasica R2, R3, R4, R5'). El agrupamiento "
     "'ATM + tarjetas adicionales + corresponsales -> R5' que se uso antes NO existe en la "
     "documentacion, y para corresponsales la evidencia apunta a que estan DENTRO de R4."),
    ("TDC-R6", "UNITY-R4-P4900", "R6", None,
     "Sin alcance definido. RETRACTADO: era valor lista validacion RAID v2.0 (Excel)", "retracted", None, None, None,
     "Una sola mencion en todo el corpus: Minuta_CAT_27072026, 'los releases siguientes (R4.5, R5, "
     "R6)'. Es tambien el unico lugar donde R4.5 y R5 conviven como releases secuenciales distintos."),
    ("CSE-R1", "UNITY-RX-P-PS", "R1", "Transact R4",
     "Credito simple a persona moral", "productivo", None, None,
     "Sucursales, Banca Empresarial, CAT, Sistema de Aclaraciones",
     "Release del producto y estado productivo confirmados por el equipo 2026-08-19. Corre sobre "
     "Transact R4 (plataforma). La decision L-02 sigue abierta pero es sobre la migracion de la "
     "cartera empresarial del legado, no sobre el arranque del producto."),
]

INITIAL_COMPONENTS = [
    {
        "id":              "smartvista",
        "name":            "SmartVista (BPC Banking Technologies)",
        "type":            "core",
        "hus_total":       22,
        "provider":        "BPC Banking Technologies",
        "provider_status": "contracted",
        "status":          "development",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Nuevo core de gestion de tarjetas de credito. "
                           "Reemplaza CMS/Intercard/Macweb. "
                           "Responsable tecnico: Appwhere (DTMs/DTCs).",
    },
    {
        "id":              "apolo",
        "name":            "APOLO  --  Originacion Digital",
        "type":            "core",
        "hus_total":       22,
        "provider":        "Appwhere",
        "provider_status": "contracted",
        "status":          "development",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Plataforma de originacion/onboarding digital de la TDC. "
                           "Latencia conocida: 9 seg PROD / 30 seg QA  --  mejoras pendientes de confirmar. "
                           "Metodologia Flow Engineering (4 semanas de diseno). "
                           "Herramienta de gestion: Mind Master.",
    },
    {
        "id":              "app",
        "name":            "APP / AppMovil  --  Canal Digital",
        "type":            "channel",
        "hus_total":       18,
        "provider":        "Nova Solution Systems",
        "provider_status": "contracted",
        "status":          "development",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Canal movil del cliente. 6 User Stories Must Have cierran noviembre "
                           " --  conflicto con inicio de SIT en octubre (riesgo critico). "
                           "Interfaz con los 49 SPs del brain AppMovil (Informix).",
    },
    {
        "id":              "cat",
        "name":            "CAT  --  Contact Center (IBR + ICAT)",
        "type":            "channel",
        "hus_total":       12,
        "provider":        "Por contratar",
        "provider_status": "pending",
        "status":          "at_risk",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "RIESGO CRITICO: proveedor no contratado al momento de las minutas. "
                           "Inicio optimista de implementacion: mediados de octubre 2026. "
                           "IBR: ambiente bloqueado por infraestructura (requiere nube). "
                           "ICAT: herramienta de gestion de llamadas.",
    },
    {
        "id":              "siweb",
        "name":            "SIWEB  --  Sistema de Sucursales",
        "type":            "channel",
        "hus_total":       5,
        "provider":        "Interno BanCoppel",
        "provider_status": "internal",
        "status":          "blocked",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Bloqueado por falta de APIs de Apificacion. "
                           "Responsable de DTMs sin confirmar formalmente (se asume Appwhere). "
                           "Menor alcance  --  priorizacion pendiente.",
    },
    {
        "id":              "cobranza",
        "name":            "Cobranza Direccionada",
        "type":            "enabler",
        "hus_total":       45,
        "provider":        "Interno BanCoppel",
        "provider_status": "internal",
        "status":          "development",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Sistema preexistente a Unity R4  --  se adapta para Producto 4900. "
                           "Rango User Stories: 37-50 (en consolidacion). "
                           "Pentest programado 15-20 nov 2026  --  conflicto con SIT (riesgo). "
                           "37-50 User Stories en consolidacion.",
    },
    {
        "id":              "apificacion",
        "name":            "Apificacion  --  Equipo de Integraciones",
        "type":            "transversal",
        "hus_total":       None,
        "provider":        "Accenture (Jose Villena, Oscar Melo)",
        "provider_status": "contracted",
        "status":          "development",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "Equipo transversal  --  disena e implementa TODAS las integraciones. "
                           "Valida DTMs y DTCs (gov: Play Digital). "
                           "Inventario de integraciones sin consolidar  --  riesgo de gaps. "
                           "Responsables: Jose Villena + Oscar Melo.",
    },
    # v1.2.0  --  Reportes Regulatorios: 4to componente del alcance formal CNBV
    # Fuente: Documento de Arquitectura UNITY_v1.0.docx, barrido documental 2026-08-19
    {
        "id":              "reportes-regulatorios",
        "name":            "Reportes Regulatorios  --  CNBV y Banxico",
        "type":            "transversal",
        "hus_total":       None,
        "provider":        "Multi-fuente (Bajaware, RiskLogic, DataStage)",
        "provider_status": "internal",
        "status":          "at_risk",
        "product_id":      "UNITY-R4-P4900",
        "notes":           "4to componente del alcance formal CNBV (junto con Apolo, TDC y CSE). "
                           "No tiene stream propio en R4  --  anidado bajo '5 CONTABILIDAD'. "
                           "Cadena: Transact/SmartVista/Apolo -> DataStage -> DWH -> RiskLogic/Bajaware -> reportes CNBV. "
                           "CRITICO: Bajaware en decomiso Q1-2027 mientras el doc CNBV lo declara como motor de generacion. "
                           "Hallazgo APO_F01 y SMA_F01: documentacion CNBV desactualizada, severidad Alta. "
                           "Owner Gustavo Martinez Martinez (Reporte Autoridades); Selene Esparza (arq cadena). "
                           "~100 reportes estimados (por confirmar); serie R-04-C + calificacion cartera + 18 SV + ~20 SPL legacy. "
                           "Retencion WORM 5-10 anios conforme CUB CNBV.",
    },
]

# Fuente autoritativa: RAID_Log_Programa_Unity_R4_v2.0.xlsx (03/08/2026)
# Responsable del log: Ma. Fernanda Barbosa
INITIAL_RISKS = [
    {
        "id": "RISK-UNITY-R01", "raid_id": "R01",
        "description": "Retraso en DTMs de Appware bloquea inicio de construccion en SmartVista, SIWEB y CAT  --  54% User Stories sin delta tecnico cerrado",
        "component_id": "smartvista", "category": "Capacidad", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Mesas de trabajo lun-jue para cerrar delta tecnico. Alfredo Aguilar define fechas DTMs offline. Gate formal 10/08/2026.",
        "due_date": "2026-08-10", "owner": "Program Lead / Ma. Fernanda Barbosa; Appware Alfredo Aguilar", "source": "Weekly",
        "notes": "SmartVista, SIWEB y CAT no pueden iniciar implementacion hasta cerrar DTMs. Gate critico ya vencido (10/ago).",
    },
    {
        "id": "RISK-UNITY-R02", "raid_id": "R02",
        "description": "Modulos SmartVista no contemplados de inicio: Inventario de Tarjetas y Campanas de meses con/sin intereses requieren desarrollo a medida",
        "component_id": "smartvista", "category": "Planning", "impact": "high", "probability": "medium",
        "status": "open",
        "mitigation": "Demo con BPC para dimensionar alcance y costo vs requerimiento original. Construir plan de trabajo especifico.",
        "due_date": "2026-07-30", "owner": "PM SmartVista / Armando Garcia", "source": "Weekly",
        "notes": "Surgieron en mesas de entendimiento. Impactan alcance, costo y cronograma SmartVista R4.",
    },
    {
        "id": "RISK-UNITY-R03", "raid_id": "R03",
        "description": "Confirmacion de refuerzo equipo Appware pendiente",
        "component_id": "apolo", "category": "Capacidad", "impact": "high", "probability": "low",
        "status": "closed",
        "mitigation": "Obtener confirmacion formal de Appware con perfiles, numero de recursos y fechas de incorporacion.",
        "due_date": "2026-07-22", "owner": "Appware / PMO Brenda Pichardo", "source": "Weekly",
        "notes": "CERRADO. Refuerzo confirmado.",
    },
    {
        "id": "RISK-UNITY-R04", "raid_id": "R04",
        "description": "Fragmentacion de capa de APIs impacta tiempos de entrega y latencia  --  sin estandar de servicio unico por funcion, latencia ya encima de 10 seg en app",
        "component_id": "apificacion", "category": "Arquitectura", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Mapear procesos core R4 afectados por fragmentacion y cuantificar esfuerzo adicional de modificacion.",
        "due_date": None, "owner": "Arquitectura BCPL", "source": "Entrevista SmartVista",
        "notes": "Cambios regulatorios o de negocio en core requieren modificar multiples APIs en paralelo por canal.",
    },
    {
        "id": "RISK-UNITY-R05", "raid_id": "R05",
        "description": "Latencia en Apolo persiste en produccion  --  mejoras de Apificacion no confirmadas como desplegadas",
        "component_id": "apolo", "category": "Performance", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Oscar Melo confirma mejoras en PROD con mediciones reales. Edgar Mejia lidera revision orquestacion en WebMethods y diagnostico cuello de botella GCP/AWS a Informix con infraestructura.",
        "due_date": "2026-08-08", "owner": "API / Edgar Mejia; Arq. / Edgar Mejia", "source": "Due Diligence",
        "notes": "P95 actual = 9,000ms vs SLO objetivo = 5,000ms (out-of-SLO pre go-live R4). Impacta experiencia de onboarding. Puede bloquear salida a mercado abierto. Cuello de botella: GCP/AWS a Informix via WebMethods IS.",
    },
    {
        "id": "RISK-UNITY-R06", "raid_id": "R06",
        "description": "Plan de trabajo Cobranza sin formalizar  --  estatus desconocido, impacta planificacion de integraciones con canales",
        "component_id": "cobranza", "category": "Planning", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Validar estatus y obtener plan de trabajo detallado con Marksey Sanvicente. Incorporar al plan maestro R4.",
        "due_date": "2026-07-30", "owner": "Program Lead / Ma. Fernanda Barbosa", "source": "Plan Unity R4 - PM",
        "notes": "Sin plan formalizado no es posible integrar Cobranza al cronograma de integraciones.",
    },
    {
        "id": "RISK-UNITY-R07", "raid_id": "R07",
        "description": "QA sin capacidad coordinada entre canales  --  SIWEB, CAT y SmartVista convergen en pruebas sep-nov sin calendario integrado",
        "component_id": None, "category": "Testing", "impact": "medium", "probability": "high",
        "status": "open",
        "mitigation": "Definir calendario integrado de ambientes QA para Q3-Q4.",
        "due_date": "2026-07-26", "owner": "Testing R4", "source": "Plan Unity R4 - PM",
        "notes": "Colision de demanda sobre ambientes y equipo de QA entre tracks que coinciden en Q4.",
    },
    {
        "id": "RISK-UNITY-R08", "raid_id": "R08",
        "description": "Entregables de Contabilidad pendientes bloquean inicio de QA SmartVista  --  guia contable, reportes regulatorios y matriz de casos de prueba con retraso",
        "component_id": "smartvista", "category": "Calidad", "impact": "medium", "probability": "high",
        "status": "open",
        "mitigation": "Obtener fecha de compromiso firmada para los tres entregables de Contabilidad.",
        "due_date": "2026-07-26", "owner": "Contabilidad / J.A. Valverde, G. Martinez y S. Melo", "source": "Plan Unity R4 - PM",
        "notes": "Sin estos entregables no se pueden definir criterios de aceptacion ni iniciar pruebas SmartVista.",
    },
    {
        "id": "RISK-UNITY-R09", "raid_id": "R09",
        "description": "Dependencia de ATLAS Fase 2 (MDM/Golden Record) sin confirmar  --  puede bloquear migracion TDC a SmartVista en R3/R4",
        "component_id": "smartvista", "category": "Planning", "impact": "high", "probability": "medium",
        "status": "open",
        "mitigation": "Documentar decision ATLAS-SmartVista: alcance, interfaces y plan de pruebas.",
        "due_date": None, "owner": "Leader Programa ATLAS BCPL", "source": "Due Diligence",
        "notes": "Si ATLAS Fase 2 no confirma alcance/fecha/criterios antes del hito requerido, R3/R4 se bloquean.",
    },
    {
        "id": "RISK-UNITY-R10", "raid_id": "R10",
        "description": "Inestabilidad o retraso por escenario de despliegue  --  4 despliegues por canal en Q4-26 con capacidad limitada y pruebas paralelas",
        "component_id": None, "category": "Despliegue", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Evaluar escenarios alternativos de despliegue con analisis cuantificado de capacidad, ambientes, defectos y freeze. Si se mantiene el escenario actual, reforzar regresion automatizada y capacidad vendor.",
        "due_date": None, "owner": "PM SmartVista / Armando Garcia", "source": "Due Diligence",
        "notes": "Concentracion de 4 despliegues en Q4 compromete estabilidad productiva y go-live Dic'26.",
    },
    {
        "id": "RISK-UNITY-R11", "raid_id": "R11",
        "description": "Guia contable de diferimientos y pagos anticipados incompleta  --  User Stories R418-R420 no pueden cerrar criterios de aceptacion",
        "component_id": "smartvista", "category": "Planning", "impact": "medium", "probability": "high",
        "status": "open",
        "mitigation": "Sesion con normatividad contable para cerrar definicion de comportamiento contable de diferimientos, liquidaciones y pagos anticipados. Actualizar criterios aceptacion R418-R420.",
        "due_date": "2026-07-24", "owner": "SmartVista / Armando Garcia", "source": "Sesiones de cierre de Analisis MT",
        "notes": "Agrava riesgo R08 de arranque de QA SmartVista.",
    },
    {
        "id": "RISK-UNITY-R12", "raid_id": "R12",
        "description": "Retraso en disenos CX/Figma bloquea inicio de desarrollo Bloque 2 App  --  CX desde sep-2025 sin cerrar alcance completo",
        "component_id": "app", "category": "Capacidad", "impact": "high", "probability": "medium",
        "status": "open",
        "mitigation": "Confirmar entrega Figma el 29 de julio con CX.",
        "due_date": "2026-07-29", "owner": "CX / Benjamin Herrera", "source": "Entrevista App",
        "notes": "Segunda entrega Figma comprometida. Sin disenos, desarrollo Bloque 2 App no puede iniciar.",
    },
    {
        "id": "RISK-UNITY-R13", "raid_id": "R13",
        "description": "Disponibilidad limitada de SmartVista y Apificacion para pruebas de App  --  recursos clave con responsabilidades en multiples frentes",
        "component_id": "app", "category": "Capacidad", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Definir ventanas de disponibilidad comprometidas para soporte a pruebas. Escalar a PMO si hay conflicto de capacidad.",
        "due_date": "2026-08-10", "owner": "SmartVista / Armando Garcia", "source": "Entrevista App",
        "notes": "JJ, Armando y Oscar tienen responsabilidades activas en otros frentes R4. Sin disponibilidad garantizada.",
    },
    {
        "id": "RISK-UNITY-R14", "raid_id": "R14",
        "description": "Inestabilidad del ambiente de integracion Unity en pruebas R4  --  ya ocurrio en R3",
        "component_id": None, "category": "Entornos", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Validar ambiente Unity con Miguel Bucio antes de iniciar pruebas R4. Establecer criterios de estabilidad minimos como gate de entrada.",
        "due_date": "2026-09-28", "owner": "Testing / Miguel Burcio", "source": "Entrevista App",
        "notes": "En R3 el ambiente Unity ya perdio semanas por inestabilidad. El nuevo ambiente aun no ha sido validado.",
    },
    {
        "id": "RISK-UNITY-R15", "raid_id": "R15",
        "description": "Ambientes DEV y TEST SmartVista sin infraestructura para componente SVFM  --  88 reglas del autorizador no pueden probarse",
        "component_id": "smartvista", "category": "Entornos", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Obtener aprobacion para escalamiento de ambientes (tickets #13830642 y #13830651). Visto bueno de Miguel Castillo.",
        "due_date": "2026-08-03", "owner": "Infra BCPL / Miguel Castillo", "source": "Matriz RAID",
        "notes": "SVFM es el componente del autorizador. Sin infraestructura adecuada no inicia el ciclo de pruebas SmartVista R4.",
    },
    {
        "id": "RISK-UNITY-R16", "raid_id": "R16",
        "description": "Incompatibilidad entre SmartVista y legado detectada tarde en pruebas  --  gaps con comportamiento del sistema antiguo descubiertos durante QA",
        "component_id": "siweb", "category": "Calidad", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Sesiones de validacion funcional con negocio contra SmartVista antes de pruebas. Documentar gaps y definir criterios de aceptacion claros.",
        "due_date": None, "owner": "PM Lead SmartVista / Armando Garcia", "source": "Entrevista SIWEB",
        "notes": "Costo de remediacion alto cuando se detecta en pruebas. Aplica especialmente a SIWEB.",
    },
    {
        "id": "RISK-UNITY-R17", "raid_id": "R17",
        "description": "Frameworks obsoletos en canales CAT generan riesgo tecnico y de cronograma  --  sin soporte, vulnerabilidades, o cambio de framework inviable en R4",
        "component_id": "cat", "category": "Arquitectura", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Sesion con Mercedes Espinosa Cortes (arquitectura) para definir postura. Si cambio no es viable en R4, documentar para release posterior.",
        "due_date": "2026-08-03", "owner": "CAT Ramses Santos / Arquitectura Mercedes Espinosa", "source": "Entrevista CAT",
        "notes": "Si se mantiene framework obsoleto, aumenta deuda tecnica y vulnerabilidades. Si se cambia, impacta cronograma.",
    },
    {
        "id": "RISK-UNITY-R18", "raid_id": "R18",
        "description": "Habilitacion de ambientes de prueba CAT bloqueada  --  arquitectura rechazo habilitar servidor IBR por requisito de nube; proceso involucra multiples areas con SLAs independientes",
        "component_id": "cat", "category": "Entornos", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Escalar a nivel con autoridad sobre infraestructura y arquitectura para destrabar IBR. Definir owner unico del proceso con fecha limite.",
        "due_date": None, "owner": "CAT Ramses Santos", "source": "Entrevista CAT",
        "notes": "Sin ambiente IBR no puede iniciar pruebas CAT. Proceso lleva semanas estancado.",
    },
    # v1.2.0  --  Reportes Regulatorios: 8 riesgos identificados en barrido documental 2026-08-19
    {
        "id": "RISK-UNITY-R19", "raid_id": "REG-01",
        "description": "Documentacion CNBV desactualizada con hallazgo formal de severidad Alta (APO_F01 y SMA_F01): arquitectura aprobada no refleja herramientas adicionales reales",
        "component_id": "reportes-regulatorios", "category": "Regulatorio", "impact": "critical", "probability": "high",
        "status": "open",
        "mitigation": "Plan de actualizacion y regularizacion de documentacion ante CNBV. Owner: Mercedes Espinosa Cortes.",
        "due_date": None, "owner": "Mercedes Espinosa Cortes", "source": "Barrido documental 2026-08-19",
        "notes": "Hallazgos APO_F01 y SMA_F01 documentados. CNBV puede objetar el programa si no se regulariza.",
    },
    {
        "id": "RISK-UNITY-R20", "raid_id": "REG-02",
        "description": "Bajaware en decomiso 1er Bimestre 2027 (Ene-Feb) mientras el documento CNBV lo declara como motor de generacion de reportes regulatorios",
        "component_id": "reportes-regulatorios", "category": "Arquitectura", "impact": "critical", "probability": "high",
        "status": "open",
        "mitigation": "Definir motor de reemplazo (RiskLogic u otro) antes del decomiso. Actualizar documentacion CNBV.",
        "due_date": "2027-01-01", "owner": "Por asignar", "source": "Barrido documental 2026-08-19",
        "notes": "'En proceso de Baja - Decomiso Fecha 1er Bimestre 2027'. El doc CNBV lo requiere activo.",
    },
    {
        "id": "RISK-UNITY-R21", "raid_id": "REG-03",
        "description": "IC-83: los pipelines DataStage se rompen al decomisar Informix (Exodus Ola 6); T-17 y T-19 en Confianza Baja sin definicion documentada",
        "component_id": "reportes-regulatorios", "category": "Dependencia", "impact": "high", "probability": "high",
        "status": "open",
        "mitigation": "Quinta decision critica del Design Authority, estado Gap. Asignar owner.",
        "due_date": None, "owner": "Por asignar", "source": "Design Authority v1.2",
        "notes": "Sin owner al corte del barrido. Bloquea la Ola 6 de Exodus y los reportes CNBV post-decomiso.",
    },
    {
        "id": "RISK-UNITY-R22", "raid_id": "REG-04",
        "description": "Cobertura de Apolo y SmartVista en reportes regulatorios nunca evaluada: columnas de gap dicen literalmente 'completar'",
        "component_id": "reportes-regulatorios", "category": "Alcance", "impact": "high", "probability": "medium",
        "status": "open",
        "mitigation": "Completar evaluacion de gap por plataforma antes de SIT.",
        "due_date": "2026-10-15", "owner": "Selene Esparza", "source": "Mapa de capacidades Unity",
        "notes": "Las columnas de gap para Apolo y SmartVista en el mapa de capacidades estan vacias.",
    },
    {
        "id": "RISK-UNITY-R23", "raid_id": "REG-05",
        "description": "Reportes Regulatorios no tiene stream propio en R4  --  anidado bajo '5 CONTABILIDAD'; capacidad 2.4.2 Reporteria es P1 con alcance no confirmado",
        "component_id": "reportes-regulatorios", "category": "Alcance", "impact": "medium", "probability": "high",
        "status": "open",
        "mitigation": "Confirmar alcance de la capacidad 2.4.2 con PMO. Considerar crear stream propio si hay entregables especificos.",
        "due_date": "2026-09-15", "owner": "PMO Unity", "source": "Plan de trabajo R4",
        "notes": "El componente es CNBV-scope pero no tiene visibilidad en el plan de trabajo.",
    },
    {
        "id": "RISK-UNITY-R24", "raid_id": "REG-06",
        "description": "Descuadre por codigos compartidos: el codigo 43 de SmartVista agrupa motivos de baja distintos, alterando veracidad de reportes a autoridades",
        "component_id": "reportes-regulatorios", "category": "Calidad de Datos", "impact": "high", "probability": "medium",
        "status": "open",
        "mitigation": "Revisar con BPC la desambiguacion del codigo 43. Confirmar con CNBV si afecta reportes R-04-C.",
        "due_date": None, "owner": "BPC / Armando Garcia", "source": "Barrido documental 2026-08-19",
        "notes": "Documentado en minutas. Puede producir errores en series regulatorias CNBV.",
    },
    {
        "id": "RISK-UNITY-R25", "raid_id": "REG-07",
        "description": "Homologacion de comisiones bloqueada por normatividad  --  2 User Stories Must regulatorias sin avance hasta confirmar aprobacion Banxico/RECO",
        "component_id": "reportes-regulatorios", "category": "Regulatorio", "impact": "medium", "probability": "medium",
        "status": "open",
        "mitigation": "Dar seguimiento al proceso RECO. No iniciar desarrollo hasta tener aprobacion.",
        "due_date": None, "owner": "Por definir con PMO BanCoppel", "source": "Barrido documental 2026-08-19",
        "notes": "DTMs sin fecha bloqueados por normatividad. 2 User Stories Must en riesgo.",
    },
    {
        "id": "RISK-UNITY-R26", "raid_id": "REG-08",
        "description": "Exodus Ola 6 declara migrar Reportes Regulatorios CNBV pero no los inventaria; apps 96, 97 y 100 no aparecen en ninguna ola",
        "component_id": "reportes-regulatorios", "category": "Dependencia", "impact": "medium", "probability": "high",
        "status": "open",
        "mitigation": "Coordinar con equipo Exodus para confirmar cubrimiento de apps regulatorias.",
        "due_date": None, "owner": "Edgar Mejia (Exodus) / PMO Unity", "source": "Barrido documental 2026-08-19",
        "notes": "Potencial gap de migracion para los reportes al cierre del datacenter (Exodus Ola 6, 2029-H2).",
    },
    {"id": "RISK-UNITY-R27", "raid_id": None, "description": "Proveedor CAT no contratado  --  Contact Center sin equipo tecnico responsable de 12 User Stories y 6 integraciones nuevas hacia SmartVista",
     "component_id": "cat", "category": "vendor", "impact": "high", "probability": "high",
     "status": "open",
     "mitigation": "Contratar proveedor antes del 2026-08-31; si no hay firma, escalar a PMO para decision de scope out",
     "due_date": "2026-08-31", "owner": "PMO Unity",
     "source": "dt-vendors.md + dt-integraciones.md",
     "notes": "Deadline critico: si no hay firma antes de 2026-08-31, las 6 integraciones nuevas CAT->SmartVista "
              "(ICAT01/02/04/05/06/07) no tendran responsable tecnico para SIT oct-nov 2026. "
              "Alias historico en build-brain.py: RISK-001. ID canonico: RISK-UNITY-R27."},
]

# -- Sistemas del legado y ecosistema Unity (v1.2.0) --------------------------
# Descubiertos en barrido documental 2026-08-19 (257 documentos del corpus).
# core_path=1 indica que es una de las 3 unicas vias validas al core Informix.
LEGACY_SYSTEMS = [
    {
        "id": "SIF", "name": "Sistema Integral Financiero", "acronym": "SIF",
        "type": "core-app", "provider": "Grupo PISA", "platform": "IBM Informix IDS 14.10 / AIX",
        "description": "Aplicacion core real que corre sobre Informix. Informix es el motor; SIF es la "
                       "aplicacion bancaria. No son sinonimos. 10,144 stored procedures confirmados por "
                       "parseo de codigo fuente (unica cifra empirica disponible).",
        "unity_relation": "to-replace", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Golden Record del cliente vive en SIF/Informix (cita doc CNBV). "
                 "El decomiso de PISA es de Exodus Ola 6 (2029-H2), no de Unity.",
    },
    {
        "id": "SOC", "name": "Sistema Operativo Central", "acronym": "SOC",
        "type": "core-app", "provider": "TASF", "platform": "Linux RedHat 7.2 / JBoss EAP 7.0 / Postgres 9.4.11 / ZK8",
        "description": "Mini-core bancario con 15 modulos y 710 funcionalidades. "
                       "Destino de migracion de modulos del SIF. "
                       "Desambiguacion: 'Sistema Operativo Central' (uso mayoritario) vs "
                       "'Sistema de Operacion Central' (uso minoritario).",
        "unity_relation": "complementary", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Tiempo de migracion estimado por app core: 10-12 meses (informe ejecutivo Exodus).",
    },
    {
        "id": "TDH", "name": "Temenos Data Hub", "acronym": "TDH",
        "type": "middleware", "provider": "Temenos", "platform": "On-premise",
        "description": "Extraccion near-realtime de Temenos Transact. Alimenta el ODS y los reportes "
                       "regulatorios. Forma parte de la cadena: Transact -> TDH -> DataStage -> DWH -> reportes.",
        "unity_relation": "data-source", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Relevante para la cadena de Reportes Regulatorios. Sin TDH no hay datos Transact en el DWH.",
    },
    {
        "id": "INTERACT", "name": "InterAct Router / Switch", "acronym": "InterAct",
        "type": "middleware", "provider": "Syndein", "platform": "On-premise",
        "description": "Middleware transaccional. Una de las 3 unicas vias validas al core Informix/SIF. "
                       "Informix NO recibe REST, SOAP, ISO 8583 ni SFTP directo.",
        "unity_relation": "coexists", "core_path": 1,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Las 3 vias al core: (1) conexion directa ODBC/JDBC/SPL, (2) InterAct, (3) IBM BUS. ASIS registra 2 apps separadas: Interact Router (row 15, middleware app-Informix) e Interact SW Autorizador (row 11, switch POS/ATM, schema intercard). SUDs distintos para cada uno.",
    },
    {
        "id": "IBM-BUS", "name": "IBM Integration Bus (IIB/ACE)", "acronym": "IBM BUS",
        "type": "middleware", "provider": "IBM", "platform": "On-premise",
        "description": "ESB corporativo. Una de las 3 unicas vias validas al core Informix/SIF. "
                       "Alternativa: IBM App Connect Enterprise (ACE).",
        "unity_relation": "coexists", "core_path": 1,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Una de las 2 migraciones de middleware: IBM BUS/InterAct a MuleSoft (ESB) "
                 "y Apigee a MuleSoft (gateway). Son migraciones distintas, no una sola.",
    },
    {
        "id": "ATLAS", "name": "ATLAS  --  Master Data Management", "acronym": "ATLAS",
        "type": "mdm", "provider": "Por confirmar", "platform": "GCP (AlloyDB + Cloud Run + Vertex AI)",
        "description": "MDM de grupo (retail Coppel + banco + Afore), no solo bancario. "
                       "Usa AlloyDB para el Golden Record, Cloud Run, Vertex AI Vector Search para "
                       "fuzzy matching y Apigee como gateway. ATLAS esta en GCP, NO en AWS. "
                       "La carga inicial de Informix hacia ATLAS no aparece en ningun documento.",
        "unity_relation": "complementary", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Candidato receptor del Golden Record post-Informix. Decision critica L-03 (TDC-R3 dependency). MDM de nivel Grupo (retail Coppel + banco + Afore) -- no exclusivo de BanCoppel. Proveedor no confirmado en corpus BanCoppel.",
    },
    {
        "id": "DATASTAGE", "name": "IBM InfoSphere DataStage", "acronym": "DataStage",
        "type": "middleware", "provider": "IBM", "platform": "On-premise",
        "description": "Plataforma ETL corporativa. Alimenta el DWH para reportes regulatorios. "
                       "Carpeta UTR-UNITY_TRANSACT ya existente en produccion (hallazgo CTM brain). "
                       "Exodus Ola 6 migra DataStage hacia Snowflake o Databricks.",
        "unity_relation": "data-source", "core_path": 0,
        "discovered_via": "ctm-brain + barrido-documental-2026-08-19",
        "notes": "IC-83 (riesgo abierto): los pipelines DataStage se rompen al decomisar Informix.",
    },
    {
        "id": "BAJAWARE", "name": "Bajaware  --  Motor de Reportes", "acronym": "Bajaware",
        "type": "regulatory-reporting", "provider": "Por confirmar", "platform": "On-premise",
        "description": "Motor de generacion de reportes regulatorios CNBV. "
                       "Declarado en el documento CNBV como motor de generacion junto con RiskLogic. "
                       "En proceso de Baja - Decomiso Fecha 1er Bimestre 2027.",
        "unity_relation": "to-decommission", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "RIESGO CRITICO: el doc CNBV lo requiere activo mientras el banco lo esta decommisionando.",
    },
    {
        "id": "RISKLOGIC", "name": "RiskLogic  --  Gestion de Riesgos y Reportes Regulatorios", "acronym": "RiskLogic",
        "type": "risk-management", "provider": "Unilogic", "platform": "On-premise",
        "description": "Motor de generacion de reportes regulatorios CNBV. "
                       "Par de Bajaware en la cadena de reportes. "
                       "Candidato natural a reemplazar Bajaware en decomiso.",
        "unity_relation": "coexists", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Candidato a reemplazar Bajaware en decomiso. Sistema de administracion de riesgos (Mercado, Liquidez, Reservas, Consumo). LIDE migro reporteria regulatoria hacia RiskLogic. Definir si absorbe scope completo de Bajaware post-decomiso.",
    },
    {
        "id": "BRM-WEBMETHODS", "name": "WebMethods BRM (Software AG)", "acronym": "BRM",
        "type": "rules-engine", "provider": "Software AG", "platform": "On-premise",
        "description": "Uno de los 3 referentes distintos del acronimo BRM en el corpus. "
                       "No confundir con Experian BRM ni con BRM Coppel.",
        "unity_relation": "unknown", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Ambiguedad documentada: BRM tiene 3 referentes diferentes en la documentacion de Unity. Identificacion como Software AG/webMethods es analisis interno ACN -- no citado en corpus BanCoppel. Requiere confirmacion con cliente.",
    },
    {
        "id": "BRM-EXPERIAN", "name": "Experian BRM  --  Motor de Evaluacion", "acronym": "BRM",
        "type": "rules-engine", "provider": "Experian", "platform": "Por confirmar",
        "description": "Motor de evaluacion crediticia. Segundo de los 3 referentes del acronimo BRM.",
        "unity_relation": "unknown", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "No confundir con WebMethods BRM ni con BRM Coppel. Identificacion como Experian no citada en corpus de SUDs -- el SUD Motor de Evaluacion indica que el WS BRM es responsabilidad de Coppel. Requiere confirmacion con cliente.",
    },
    {
        "id": "BRM-COPPEL", "name": "BRM Coppel  --  Web Service Red Coppel", "acronym": "BRM",
        "type": "other", "provider": "Grupo Coppel", "platform": "Por confirmar",
        "description": "Web service de la Red Coppel. Tercero de los 3 referentes del acronimo BRM.",
        "unity_relation": "unknown", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "No confundir con los motores de reglas BRM externos.",
    },
    {
        "id": "ONBASE-PROMETEO", "name": "OnBase / Prometeo  --  Gestion Documental", "acronym": None,
        "type": "document-mgmt", "provider": "Hyland (OnBase) / Por confirmar (Prometeo)",
        "platform": "Por confirmar",
        "description": "Sistema de gestion documental. Aparecen fusionados en un inventario y "
                       "separados en otro, con stacks incompatibles.",
        "unity_relation": "unknown", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Ambiguedad: inventarios inconsistentes. Confirmar si son un solo sistema o dos distintos. OnBase confirmado activo en R4: APOLO BB16 (HDU-TDC-R4-20, firma electronica + expediente digital). Aclarar si Prometeo es capa propietaria sobre OnBase o sistema independiente.",
    },
    {
        "id": "BLUE-PRISM", "name": "Blue Prism  --  RPA (bots EY)", "acronym": "BluePrism",
        "type": "rpa", "provider": "Blue Prism / EY", "platform": "On-premise",
        "description": "Bots RPA operados por EY. Hostnames: BluePrismEYR1Mty, BluePrismEYR2Cul, "
                       "BluePrismEYR4Cul. NO son releases de EY  --  son bots de automatizacion.",
        "unity_relation": "unknown", "core_path": 0,
        "discovered_via": "barrido-documental-2026-08-19",
        "notes": "Falso positivo a evitar: los hostnames parecen releases EY pero son bots Blue Prism.",
    },
]

# -- Hallazgos del barrido documental 2026-08-19 (v1.2.0) --------------------
# 257 documentos del corpus de Unity revisados. Hallazgos que cambian el analisis.
AUDIT_FINDINGS = [
    # Cifras huerfanas  --  NO usar sin calificar su procedencia
    {
        "id": "AUD-CF-001", "category": "cifra-huerfana",
        "title": "128 aplicaciones de PISA",
        "description": "Cifra sin fuente primaria verificable y sobre-atribuida. La version previa del mismo "
                       "deck decia 114, sin que cambiara ninguna fuente. Inventarios reales dicen 116, 124, "
                       "125 y 129, y son totales del legado del banco, no de PISA.",
        "impact": "high", "status": "open",
        "source_doc": "multiples decks Unity, sin fuente primaria",
        "notes": "No usar. Derivar del inventario canonico si es necesaria la cifra.",
    },
    {
        "id": "AUD-CF-002", "category": "cifra-huerfana",
        "title": "13,000-14,000 SPLs sin mapear",
        "description": "Cifra huerfana. Solo aparece en 4 documentos de Accenture que se citan entre si. "
                       "El inventario del banco (Inventario_bdanalisis, ago-2026) suma 17,380 SPs declarados. "
                       "Exodus dice 7,480 y tambien '10,000+'. Nuestro parseo de codigo fuente: 10,144.",
        "impact": "high", "status": "open",
        "source_doc": "Design Authority v1.2 (sin fuente primaria)",
        "notes": "La unica cifra con base empirica es 10,144 (parseo codigo fuente). Defender esa.",
    },
    {
        "id": "AUD-CF-003", "category": "cifra-huerfana",
        "title": "80 SUDs ejecutan SPL",
        "description": "Error de categoria. El dato real es: 80 de 88 System Understanding Documents "
                       "(documentos de Accenture) referencian Informix, OLTP o SPL. "
                       "Un SUD es un documento, no un sistema del banco.",
        "impact": "medium", "status": "resolved",
        "source_doc": "Design Authority v1.2",
        "notes": "Corregido en la redaccion del Plan Director. No usar la formulacion original.",
    },
    # Correcciones aplicadas
    {
        "id": "AUD-COR-001", "category": "correccion",
        "title": "TDC Clasica Digital -> Tarjeta de Credito",
        "description": "El nombre oficial del producto es 'Tarjeta de Credito', no 'TDC Clasica Digital'. "
                       "Aplicado en todos los DTs, CLAUDE.md, portal y brain el 2026-08-19.",
        "impact": "medium", "status": "resolved",
        "source_doc": "Equipo BanCoppel confirmado 2026-08-19",
        "notes": "Todos los artefactos actualizados.",
    },
    {
        "id": "AUD-COR-002", "category": "correccion",
        "title": "MCI = Meses Con Intereses (no Motor de Credito Institucional)",
        "description": "MCI en el contexto de Unity R4 significa Meses Con Intereses (funcionalidad de "
                       "financiamiento). No es el Motor de Credito Institucional.",
        "impact": "medium", "status": "resolved",
        "source_doc": "dt-cronograma.md, plan de julio",
        "notes": "Backend MCI en R4; App en R4.5 (o R5, fuentes contradictorias).",
    },
    {
        "id": "AUD-COR-003", "category": "correccion",
        "title": "TRNT es tipo de transaccion SmartVista, Temenos Transact NO participa en P4900",
        "description": "TRNT en el contexto del ciclo contable del Producto 4900 es el tipo de transaccion "
                       "contable interno de SmartVista (ej. T623 es una transaccion SIWEB, no de SmartVista). "
                       "Temenos Transact no participa en el ciclo del Producto 4900 (TDC). "
                       "La cadena contable real es: SVBO -> SVXP (XML) -> PISA.",
        "impact": "high", "status": "resolved",
        "source_doc": "Conciliacion automatica PISA - SmartVista (SV).docx, 16-nov-2023",
        "notes": "Actualizado en dt-smartvista.md y capability_routing del brain.",
    },
    {
        "id": "AUD-COR-004", "category": "correccion",
        "title": "Informix v14.10 (documentacion Unity dice v12)",
        "description": "El corpus de Unity dice 'Informix 12' y 'Informix 12.10'. "
                       "El log de la instancia productiva dice: IBM Informix Dynamic Server Version "
                       "14.10.FC10W2 -- On-Line (Prim) -- Up. La instancia prevalece.",
        "impact": "medium", "status": "resolved",
        "source_doc": "systems/core/Informix/source/logs/ifmx_stats_coppel_shm_*.txt",
        "notes": "Siempre citar v14.10 en artefactos. La documentacion del programa esta desactualizada.",
    },
    {
        "id": "AUD-COR-005", "category": "correccion",
        "title": "EY tiene alcance R4 y no sale del programa",
        "description": "La palabra 'incumbente' no existe en el corpus. EY tiene alcance declarado en R4 "
                       "('R4 - Originaciones de procesos', 'R4 - Pago de Creditos/Amortizaciones'). "
                       "Figura como colaborador del Master Test Plan. "
                       "Redaccion defendible: EY es responsable de la arquitectura objetivo de Transact "
                       "(ARQ-10, E-AQ-EY) y su alcance contractual en R4 no esta documentado.",
        "impact": "high", "status": "resolved",
        "source_doc": "Documento de arquitectura EY, Master Test Plan",
        "notes": "Actualizado en CLAUDE.md Unity. Mantener alerta de competidor pero sin sobrepresentar.",
    },
    # Hallazgos nuevos
    {
        "id": "AUD-HAL-001", "category": "hallazgo",
        "title": "Golden Record vive en Informix/SIF, no en ATLAS ni Transact",
        "description": "Cita del documento CNBV: 'El cliente se generara en la base de datos de Informix "
                       "(PISA) donde BanCoppel utilizara esta base de datos para almacenar el Golden Record "
                       "del cliente'. ATLAS (AlloyDB/GCP) es candidato receptor en Fase 2 (sep-2026, sin "
                       "diseno). La carga inicial de Informix hacia ATLAS no aparece en ningun documento.",
        "impact": "critical", "status": "open",
        "source_doc": "Documento de Arquitectura UNITY_v1.0.docx",
        "notes": "El decomiso de PISA esta bloqueado por la propiedad del Golden Record, al mismo nivel "
                 "que por los stored procedures. Anadir al analisis de desacoplamiento.",
    },
    {
        "id": "AUD-HAL-002", "category": "hallazgo",
        "title": "Exodus es un programa separado de Unity",
        "description": "Exodus = migracion de datacenters Mexico a la nube 2026-2030, 6 olas. "
                       "El apagado de Informix esta en Exodus Ola 6 (2029-H2), no en Unity. "
                       "Ningun documento de Exodus menciona Unity. "
                       "IMPLICACION: el business case de Unity que incluye 'el decomiso de PISA' "
                       "descansa sobre el roadmap de otro programa sin dueno compartido.",
        "impact": "critical", "status": "watchlist",
        "source_doc": "Informe Ejecutivo Exodus BanCoppel",
        "notes": "Brain de Exodus en projects/exodus/. 30 apps, 6 olas, 7 preguntas abiertas.",
    },
    {
        "id": "AUD-HAL-003", "category": "hallazgo",
        "title": "Contradiccion API gateway: Apigee EOL 2027 (Unity) vs mantener Apigee (Exodus Ola 1)",
        "description": "Plan Director Unity: Apigee EOL 2027, migracion a MuleSoft 'en curso' sin plan ni "
                       "inventario. Exodus Ola 1: 'Mantener y migrar su gateway a Apigee'. "
                       "Lineamientos StackTech 11-ago-2026: 'Apigee / WSO2 API Manager' (sin MuleSoft). "
                       "Son ademas 2 migraciones distintas: Apigee->MuleSoft (gateway) e IBM BUS->MuleSoft (ESB).",
        "impact": "high", "status": "open",
        "source_doc": "Plan Director Unity + Exodus Informe + StackTech Guidelines 2026-08-11",
        "notes": "Escalar al arquitecto principal. Decisiones incompatibles entre programas.",
    },
    {
        "id": "AUD-HAL-004", "category": "hallazgo",
        "title": "Autorreferencia en entregables Accenture: 4 de 5 banderas rojas del legado sin sustento independiente",
        "description": "Cuatro banderas rojas del legado se sostienen solo en entregables Accenture "
                       "(Design_Authority_v1.2 + Catalogo Interoperabilidad v0.1) que se citan mutuamente. "
                       "La unica con respaldo independiente es el decomiso de PISA (pptx BanCoppel 6-jul-2026). "
                       "Riesgo: si el cliente audita el Plan Director, 4 de 5 banderas resultan autorreferenciales.",
        "impact": "high", "status": "watchlist",
        "source_doc": "Design_Authority_v1.2.pptx, Catalogo Interoperabilidad v0.1",
        "notes": "Regla derivada: antes de presentar una cifra del legado al cliente, verificar si "
                 "su unica fuente somos nosotros. Ver CLAUDE.md Unity seccion Barrido.",
    },
    {
        "id": "AUD-HAL-005", "category": "hallazgo",
        "title": "Numeracion de releases es por plataforma, no del programa",
        "description": "No existe un tren unico R1->R5 del programa. Transact tiene R1-R4, "
                       "SmartVista tiene R3/R4/R4.5. Coexisten dos 'R4' simultaneos en plataformas distintas. "
                       "El Credito Simple Empresarial esta en R1 del producto corriendo sobre Transact R4.",
        "impact": "medium", "status": "resolved",
        "source_doc": "Design_Authority_v1.2 slide 7, equipo 2026-08-19",
        "notes": "Aplicar al interpretar cualquier hito o entregable: siempre especificar plataforma.",
    },
    # Ambiguedades
    {
        "id": "AUD-AMB-001", "category": "ambiguedad",
        "title": "BRM tiene 3 referentes distintos",
        "description": "BRM puede ser: (1) WebMethods BRM de Software AG, (2) Experian BRM motor de "
                       "evaluacion, (3) BRM Coppel web service de Red Coppel. Nunca asumir cual sin contexto.",
        "impact": "medium", "status": "watchlist",
        "source_doc": "multiples documentos del corpus",
        "notes": "Desambiguar en cada mencion. Ver legacy_systems: BRM-WEBMETHODS, BRM-EXPERIAN, BRM-COPPEL.",
    },
    {
        "id": "AUD-AMB-002", "category": "ambiguedad",
        "title": "SOC tiene 2 expansiones incompatibles",
        "description": "'Sistema Operativo Central' (uso mayoritario) vs 'Sistema de Operacion Central'.",
        "impact": "low", "status": "watchlist",
        "source_doc": "multiples documentos del corpus",
        "notes": "Usar 'Sistema Operativo Central' como expansion canonica.",
    },
    {
        "id": "AUD-AMB-003", "category": "ambiguedad",
        "title": "BPC se expande mal como 'Banking Payments Context'",
        "description": "El documento de arquitectura usa 'Banking Payments Context' para BPC. "
                       "La razon social correcta es BPC Banking Technologies.",
        "impact": "low", "status": "resolved",
        "source_doc": "Documento de Arquitectura UNITY_v1.0.docx",
        "notes": "Usar siempre 'BPC Banking Technologies'.",
    },
    # Datos requeridos
    {
        "id": "AUD-DR-001", "category": "dato-requerido",
        "title": "Credito Simple Empresarial = Prestamo Simple?",
        "description": "El Design Authority lo llama 'Prestamo Simple'; el documento CNBV lo llama "
                       "'Credito Simple Empresarial'. Podrian ser el mismo producto o dos distintos.",
        "impact": "high", "status": "open",
        "source_doc": "Design Authority v1.2 + Documento de Arquitectura UNITY_v1.0.docx",
        "notes": "Confirmar con PMO antes de tratar como sinonimos en cualquier artefacto.",
    },
    {
        "id": "AUD-DR-002", "category": "dato-requerido",
        "title": "L-07: discrepancia EY vs roadmap en fechas Transact R1 y R2",
        "description": "Discrepancia declarada entre el documento de EY y el roadmap maestro sobre "
                       "las fechas de Transact R1 y R2.",
        "impact": "medium", "status": "open",
        "source_doc": "Design Authority v1.2 (L-07)",
        "notes": "Confirmar con equipo EY / PMO Unity.",
    },
    {
        "id": "AUD-DR-003", "category": "dato-requerido",
        "title": "Releases R1-R3 de captacion: pertenecen a Unity o al legado?",
        "description": "Cuenta Efectiva N2, CED N4 y Nomina N4 estan en produccion sobre Transact pero "
                       "no aparecen en el documento formal de alcance CNBV. El Roadmap 2025 los etiqueta "
                       "como 'CUENTAS - N2/N4 (Legado)'. Confirmar si son releases de Unity o producciones "
                       "independientes de Transact.",
        "impact": "medium", "status": "open",
        "source_doc": "Roadmap Unity 2025.pptx",
        "notes": "Impacta la presentacion publica del programa y los conteos de productos en produccion.",
    },
]

INITIAL_ASSUMPTIONS = [
    {
        "id": "ASMP-UNITY-H01", "raid_id": "H01",
        "description": "Modulo de exclusion de abonos bancarios del limite de saldo a favor queda fuera del alcance de R4",
        "component_id": "smartvista",
        "relevance": "high", "status": "pending",
        "validator": "SmartVista / Armando Garcia", "validation_date": "2026-07-22",
        "source": "Sesiones de cierre de Analisis MT",
        "notes": "De no confirmarse: 1.5 meses adicionales de esfuerzo en pruebas, personalizacion BPC y participacion equipo aclaraciones no disponible en R4.",
    },
    {
        "id": "ASMP-UNITY-H02", "raid_id": "H02",
        "description": "Restriccion de liquidacion en ultima mensualidad (no mostrar compras con una sola mensualidad restante para pago anticipado) queda fuera de alcance R4",
        "component_id": "siweb",
        "relevance": "medium", "status": "pending",
        "validator": "SmartVista / Armando Garcia", "validation_date": None,
        "source": "Sesiones de cierre de Analisis MT",
        "notes": "De no confirmarse: desarrollo adicional con BPC que impacta cronograma SIWEB.",
    },
    {
        "id": "ASMP-UNITY-H03", "raid_id": "H03",
        "description": "Cargos recurrentes y domiciliaciones en relacion con bloqueo de tarjeta quedan fuera del alcance de R4",
        "component_id": "app",
        "relevance": "high", "status": "pending",
        "validator": "PM App / Eduardo Guzman", "validation_date": None,
        "source": "Sesiones de cierre de Analisis MT",
        "notes": "De incorporarse: criterios adicionales en multiples historias y esfuerzo de desarrollo no dimensionado.",
    },
    {
        "id": "ASMP-UNITY-H04", "raid_id": "H04",
        "description": "Pagos anticipados y cancelacion de compras diferidas corresponden a SIWEB y no a App en R4",
        "component_id": "app",
        "relevance": "high", "status": "pending",
        "validator": "PM App / Eduardo Guzman", "validation_date": None,
        "source": "Sesiones de cierre de Analisis MT",
        "notes": "De no confirmarse: reincorporar historias al backlog de App con impacto en cronograma y capacidad.",
    },
]

INITIAL_ISSUES = [
    {
        "id": "ISSUE-UNITY-I01", "raid_id": "I01",
        "description": "CAT sin equipo de desarrollo  --  inicio de construccion estimado a mediados de octubre, freeze en diciembre deja margen critico",
        "component_id": "cat", "category": "Capacidad", "severity": "high",
        "current_impact": "Sin equipo asignado, CAT no puede iniciar construccion en R4. Cronograma oct-nov deja margen critico hacia freeze Dic'26.",
        "remediation": "Confirmar fechas DTMs con Appware en paralelo a contratacion. Confirmar nombre, fechas y SLA del nuevo proveedor. Explorar capacidad interna como contingencia.",
        "status": "open", "owner": "CAT / Ramses Santos", "due_date": "2026-08-07",
        "tracks": "CAT", "breach": 1,
        "source": "Sesion de trabajo SmartVista",
        "notes": "Incorporacion estimada proveedor: mediados de septiembre + 1 mes onboarding = construccion inicia mediados de octubre.",
    },
    {
        "id": "ISSUE-UNITY-I02", "raid_id": "I02",
        "description": "Unico entorno homologado disponible para SIT, UAT, NFT y Seguridad  --  colision de demanda entre ciclos de prueba activa desde R3",
        "component_id": None, "category": "Entornos", "severity": "high",
        "current_impact": "Bloqueos efectivos entre equipos durante ventanas de prueba. Riesgo de contaminacion de datos por superposicion de ciclos. Compromete calidad y fechas de SIT/UAT R4.",
        "remediation": "Provisionar entorno ETL E2E adicional y entorno pre-productivo para Dress Rehearsals. Publicar calendario centralizado de uso de entornos con SLA y responsables.",
        "status": "open", "owner": "Infra BCPL", "due_date": None,
        "tracks": None, "breach": 0,
        "source": "Due Diligence",
        "notes": "Problema activo desde 19/05/2026. Critico bajo escenario R4 con multiples despliegues en Q4-26.",
    },
    {
        "id": "ISSUE-UNITY-I03", "raid_id": "I03",
        "description": "Celula Apolo App BanCoppel sin contratar  --  sin capacidad para arrancar sprints en tiempo",
        "component_id": "app", "category": "Capacidad", "severity": "high",
        "current_impact": "Sin capacidad asignada, canal App no puede completar integracion antes de SIT. Bloquea hitos R4 en Dic'26.",
        "remediation": "Contratacion inmediata de la celula App Apolo con fechas, SLA y plan de onboarding. Definir cierre de canales como gate formal de SIT. Preparar plan alterno con mocks si hay retraso.",
        "status": "open", "owner": "Apolo Lead / Leonardo Hernandez", "due_date": None,
        "tracks": "App", "breach": 0,
        "source": "Due Diligence",
        "notes": "Abierto desde 19/05/2026. Sin celula contratada, la integracion App-Apolo no se completa antes de SIT.",
    },
    # ── 8 Acciones del Plan Director (corte 14-ago-2026) ────────────────────
    {
        "id": "ISSUE-R4-001", "raid_id": "ACT-001",
        "description": "Confirmar fechas de dise\u00f1o t\u00e9cnico e implementaci\u00f3n de integraciones por track (Apolo\u2192SIWEB\u2192CAT\u2192SV, 2 HUs pendientes)",
        "component_id": None, "category": "integration", "severity": "critical",
        "current_impact": "Sin fechas confirmadas el plan SIT cross-track es inv\u00e1lido \u2014 ning\u00fan track puede arrancar pruebas de integraci\u00f3n",
        "remediation": "Sesi\u00f3n t\u00e9cnica urgente con leads de cada track para cerrar calendario de integraciones antes de arrancar SIT",
        "status": "open", "owner": "Oscar Melo", "due_date": "2026-08-18",
        "tracks": "Apolo, SIWEB, CAT, SmartVista", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-18.",
    },
    {
        "id": "ISSUE-R4-002", "raid_id": "ACT-002",
        "description": "Mitigar desfase de 6 HUs Must APP con implementaci\u00f3n planificada en noviembre \u2014 posterior al inicio de SIT",
        "component_id": None, "category": "scope", "severity": "critical",
        "current_impact": "6 HUs Must del canal App cierran despu\u00e9s del inicio de SIT; comprometiendo UAT y go-live 15-ene-2027",
        "remediation": "(1) Incorporar en 2do tramo SIT, (2) agilizar entregas de dise\u00f1o e incremento de capacidad de desarrollo, (3) revisar prioridad de estas HUs",
        "status": "open", "owner": "Diana Estrada", "due_date": "2026-08-14",
        "tracks": "App", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14.",
    },
    {
        "id": "ISSUE-R4-003", "raid_id": "ACT-003",
        "description": "Formalizar la contrataci\u00f3n del proveedor CAT \u2014 on-boarding agosto, implementaci\u00f3n 15-sep, margen cero al 15-oct",
        "component_id": None, "category": "vendor", "severity": "critical",
        "current_impact": "Sin proveedor CAT contratado: 12 HUs Must y 6 integraciones sin owner t\u00e9cnico; bloquea SIT completo del canal Contact Center",
        "remediation": "Contrataci\u00f3n inmediata para garantizar on-boarding en agosto e inicio de implementaci\u00f3n al 15-sep",
        "status": "open", "owner": "Ramses Santos / Fernanda Barbosa", "due_date": "2026-08-14",
        "tracks": "CAT", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14. Vinculado a RISK-UNITY-R27. Deadline duro: proveedor operativo al 15-oct.",
    },
    {
        "id": "ISSUE-R4-004", "raid_id": "ACT-004",
        "description": "Completar inventario de integraciones R4 y trazabilidad con Historias de Usuario para validar viabilidad del plan integrado",
        "component_id": None, "category": "planning", "severity": "critical",
        "current_impact": "Sin inventario de integraciones el an\u00e1lisis de prioridad y el plan SIT cross-track son parciales e inv\u00e1lidos",
        "remediation": "Completar mapeo HU\u2194integraci\u00f3n\u2194sistema por track; confirmar que el plan integrado es viable",
        "status": "open", "owner": "Oscar Melo / Pablo Lorenzo (Accenture)", "due_date": "2026-08-21",
        "tracks": "Apolo, SIWEB, CAT, SmartVista", "breach": 0,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "Accenture co-owner del an\u00e1lisis. Base indispensable para el SIT cross-track.",
    },
    {
        "id": "ISSUE-R4-005", "raid_id": "ACT-005",
        "description": "Compartir y completar an\u00e1lisis del Track de Cobranza \u2014 HUs, integraciones y dependencias con canales",
        "component_id": None, "category": "scope", "severity": "critical",
        "current_impact": "Track Cobranza completamente opaco: 30-50 HUs estimadas sin compartir, dependencias hacia canales desconocidas \u2014 bloquea an\u00e1lisis de prioridad del programa",
        "remediation": "Compartir backlog Cobranza completo: HUs, integraciones, dependencias y plan de entrega",
        "status": "open", "owner": "Marksey Sanvicente", "due_date": "2026-08-07",
        "tracks": "Cobranza", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-07 \u2014 13 d\u00edas en breach. Sin este an\u00e1lisis el SIT integral es inviable.",
    },
    {
        "id": "ISSUE-R4-006", "raid_id": "ACT-006",
        "description": "Habilitar v\u00eda ejecutiva de decisiones en 24-48h para decisiones cr\u00edticas R4 y seguimiento a hitos cr\u00edticos",
        "component_id": None, "category": "governance", "severity": "critical",
        "current_impact": "Sin mecanismo ejecutivo de decisi\u00f3n r\u00e1pida las decisiones de alcance, prioridad y recursos se escalan sin SLA",
        "remediation": "Definir autoridad ejecutiva con capacidad de decidir sobre alcance y prioridades; incluir l\u00edderes de track, APIficaci\u00f3n, ambientes, pruebas, despliegue y Director de Transformaci\u00f3n",
        "status": "open", "owner": "Pablo Madinaveitia", "due_date": "2026-08-17",
        "tracks": "Todos los tracks", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-17 \u2014 3 d\u00edas en breach.",
    },
    {
        "id": "ISSUE-R4-007", "raid_id": "ACT-007",
        "description": "Confirmar escenarios de mitigaci\u00f3n para Maquila Automatizada SmartVista \u2014 5 DTMs con gap cr\u00edtico sin plan de cierre",
        "component_id": None, "category": "delivery", "severity": "high",
        "current_impact": "DPP, BYU0039 y OCG sin plan de cierre; riesgo de no completar SIT SmartVista a tiempo para el go-live",
        "remediation": "(1) Reducir alcance a 1 proveedor, (2) optimizar proceso de certificaci\u00f3n y gobierno de APIs, (3) excluir HUs Should, (4) ejecutar pruebas SIT en segundo ciclo",
        "status": "open", "owner": "Armando Garc\u00eda", "due_date": "2026-08-14",
        "tracks": "SmartVista", "breach": 1,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "BREACH: due_date vencida 2026-08-14. 4 opciones de mitigaci\u00f3n a confirmar.",
    },
    {
        "id": "ISSUE-R4-008", "raid_id": "ACT-008",
        "description": "Definir e implementar estrategia de despliegue R4: runbook de actividades, simulacros DR completos incluyendo rollback",
        "component_id": None, "category": "release", "severity": "high",
        "current_impact": "Sin runbook de despliegue ni simulacros DR, el go-live bancario 15-ene-2027 tiene riesgo operativo alto ante incidentes en producci\u00f3n",
        "remediation": "Runbook de actividades + planificaci\u00f3n de simulacros de despliegue completos (DRs) incluyendo rollback probado en STG",
        "status": "open", "owner": "Christian Zazueta", "due_date": "2026-08-28",
        "tracks": "Despliegue", "breach": 0,
        "source": "Plan Director \u2014 slide acciones cr\u00edticas 14-ago-2026",
        "notes": "Prerequisito para SIT y UAT seguros.",
    },
]

INITIAL_DEPENDENCIES = [
    {
        "id": "DEP-UNITY-D01", "raid_id": "D01",
        "description": "Normatividad Contable debe entregar guia de diferimientos para que SmartVista cierre criterios de aceptacion R418-R420",
        "successor": "PM SmartVista / Armando Garcia",
        "predecessor": "Normatividad Contable / J.A. Valverde",
        "severity": "severe", "status": "active",
        "due_date": "2026-07-24",
        "source": "Sesiones de cierre de Analisis MT",
        "notes": "Sin guia contable, R418-R420 no pueden cerrar refinamiento ni iniciar construccion. Fecha objetivo ya vencida.",
    },
    {
        "id": "DEP-UNITY-D02", "raid_id": "D02",
        "description": "Infra BCPL debe estabilizar entorno homologado para que todos los streams puedan iniciar SIT",
        "successor": "QA Lead / PMO",
        "predecessor": "Infra BCPL",
        "severity": "severe", "status": "active",
        "due_date": None,
        "source": "Due Diligence",
        "notes": "Sin entorno homologado estabilizado (aplicativos, comunicaciones, arquitectura), ningun stream puede iniciar SIT. Bloquea en cascada UAT, NFT y go-live.",
    },
]

INITIAL_MILESTONES = [
    {
        "id":           "MS-UNITY-001",
        "name":         "Cierre de analisis  --  ultimo track (SmartVista/Apolo)",
        "target_date":  "2026-10-16",
        "status":       "pending",
        "component_id": "smartvista",
        "notes":        "Analisis y diseno debe cerrarse antes de iniciar SIT.",
    },
    {
        "id":           "MS-UNITY-002",
        "name":         "Cierre de desarrollo y Unit Testing (todos los componentes)",
        "target_date":  "2026-10-15",
        "status":       "pending",
        "component_id": None,
        "notes":        "Codigo freeze de componentes para entrada a SIT.",
    },
    {
        "id":           "MS-UNITY-003",
        "name":         "Inicio SIT  --  System Integration Testing",
        "target_date":  "2026-10-15",
        "status":       "at_risk",
        "component_id": None,
        "notes":        "Riesgo: CAT no contratado, 6 User Stories App cierran en noviembre.",
    },
    {
        "id":           "MS-UNITY-004",
        "name":         "Pentest Cobranza (conflicto con SIT)",
        "target_date":  "2026-11-15",
        "status":       "at_risk",
        "component_id": "cobranza",
        "notes":        "Pentest 15-20 nov 2026. Puede congelar ambiente de Cobranza en pleno SIT.",
    },
    {
        "id":           "MS-UNITY-005",
        "name":         "Fin SIT / Code Freeze definitivo",
        "target_date":  "2026-12-15",
        "status":       "pending",
        "component_id": None,
        "notes":        "Ningun cambio de codigo despues de esta fecha.",
    },
    {
        "id":           "MS-UNITY-006",
        "name":         "Go-Live Producto 4900  --  Tarjeta de Credito",
        "target_date":  "2027-01-15",
        "status":       "pending",
        "component_id": None,
        "notes":        "Mediados de enero 2027. Fecha sujeta a exito de SIT.",
    },
]

INITIAL_VOCABULARY = [
    # Negocio
    ("Producto 4900",   "Tarjeta de Credito de BanCoppel. Numero de credito de 18 digitos (cuenta clave = clave interbancaria).", "negocio", "minutas"),
    ("Parcializaciones","Meses Con Intereses (MSI) y Meses Con Intereses variables (MCI)  --  esquemas de pago en parcialidades.", "negocio", "minutas"),
    ("Maquila",         "Fabricacion de tarjetas plasticas. Proveedores: Forza, TGS, Tales. Archivo de maquila se envia via Connect Direct.", "negocio", "minutas"),
    ("Cuenta clave",    "Clave interbancaria de 18 digitos que identifica unicamente la Tarjeta de Credito.", "negocio", "minutas"),
    ("eGlobal",         "Equipo de BanCoppel que prueba las 88 reglas del autorizador ISO 8583 (validacion de transacciones en SmartVista).", "negocio", "minutas"),
    # Proceso
    ("DTM",             "Diseno Tecnico de Microservicio. Documento que define flujo, componentes involucrados y contratos de un microservicio.", "proceso", "minutas"),
    ("DTC",             "Diseno Tecnico de Componente. Documento que define parametros, archivos de configuracion y contratos de un componente.", "proceso", "minutas"),
    ("DEF",             "Documento de Especificacion Funcional. Fuente de las Historias de Usuario (User Stories) del programa.", "proceso", "minutas"),
    ("Pre-game",        "Sesion de refinamiento de criterios de aceptacion que se realiza antes del inicio del desarrollo de una User Story.", "proceso", "minutas"),
    ("Flow Engineering","Metodologia de diseno de Appwhere. Ciclos de 4 semanas para especificar flujos de usuario antes del desarrollo.", "proceso", "minutas"),
    ("Mind Master",     "Herramienta de gestion y documentacion de User Stories utilizada por Appwhere en el componente APOLO.", "proceso", "minutas"),
    ("Play Digital",    "Gobierno de APIs y diseno tecnico. Valida DTMs y DTCs de todos los componentes del programa.", "proceso", "minutas"),
    ("HU",              "Historia de Usuario. Unidad de trabajo del backlog. Clasificadas como Must Have, Should Have o Nice To Have.", "proceso", "minutas"),
    ("Must Have",       "User Stories de entrega obligatoria para Go-Live. Tienen prioridad maxima en SIT.", "proceso", "minutas"),
    ("SIT",             "System Integration Testing. Fase de pruebas de integracion del programa. Fechas: 15 oct  --  15 dic 2026.", "proceso", "minutas"),
    ("UT",              "Unit Testing. Pruebas unitarias que cada proveedor ejecuta antes de entregar al SIT.", "proceso", "minutas"),
    # Tecnico
    ("SmartVista",      "Plataforma de gestion de tarjetas de credito de BPC Banking Technologies. Reemplaza CMS/Intercard/Macweb en Unity R4.", "tecnico", "minutas"),
    ("CMS",             "Card Management System. Sistema legado de gestion de tarjetas que SmartVista reemplaza.", "tecnico", "minutas"),
    ("Intercard",       "Componente del sistema legado CMS que SmartVista sustituye.", "tecnico", "minutas"),
    ("Macweb",          "Interfaz web del sistema CMS legado que SmartVista reemplaza.", "tecnico", "minutas"),
    ("Connect Direct",  "Protocolo de transferencia de archivos usado para enviar el archivo de maquila de tarjetas a los proveedores.", "tecnico", "minutas"),
    ("IBR",             "Sistema de Contact Center  --  canal de atencion telefonica. Parte del componente CAT.", "tecnico", "minutas"),
    ("ICAT",            "Herramienta de gestion de llamadas del Contact Center. Parte del componente CAT.", "tecnico", "minutas"),
    ("ISO 8583",        "Estandar internacional de mensajeria para transacciones con tarjeta de credito/debito. 88 reglas probadas por eGlobal.", "tecnico", "minutas"),
    # Proveedores
    ("BPC",             "BPC Banking Technologies. Proveedor de SmartVista  --  core de gestion de tarjetas en Unity R4.", "proveedor", "minutas"),
    ("Appwhere",        "Proveedor externo responsable del diseno tecnico (DTMs/DTCs) y del componente APOLO.", "proveedor", "minutas"),
    ("Nova Solution Systems", "Proveedor externo responsable del desarrollo del canal APP / AppMovil en Unity R4.", "proveedor", "minutas"),
    # Participantes clave (referencia)
    ("Pablo Lorenzo",   "Lider Accenture en Unity R4. Coordina con BanCoppel y proveedores.", "proceso", "minutas"),
    ("Ana Cervantes",   "Integrante Accenture en Unity R4. Gestiona seguimiento de User Stories y riesgos.", "proceso", "minutas"),
    ("Fernanda Barbosa","Responsable BanCoppel en Unity R4. Aprueba alcance funcional.", "proceso", "minutas"),
    ("Jose Jaimes Ortiz","Responsable tecnico BanCoppel en Unity R4.", "proceso", "minutas"),
    # â"€â"€ SmartVista / Canales  --  terminologia tecnica (fuente: HDU_R4 + PreGame) â"€
    # Modulos SmartVista
    ("SVBO",            "SmartVista Back Office: contratos, contabilidad, liquidacion y parametrizacion de productos.", "tecnico", "sv-canales"),
    ("SVFE",            "SmartVista Front End: consola de usuarios operativos y de atencion al cliente.", "tecnico", "sv-canales"),
    ("SVFM",            "SmartVista Fraud Management: modulo de fraude NO licenciado por BanCoppel. Se usa PayTrue en su lugar.", "tecnico", "sv-canales"),
    ("SVCG",            "SmartVista Card Generation (Cargen): genera archivos y layouts de maquila de tarjetas.", "tecnico", "sv-canales"),
    ("SVIP",            "SmartVista Integration Platform: middleware oficial de BPC entre todos los canales y SVBO. Catalogo de 92 comandos.", "tecnico", "sv-canales"),
    ("SmartVista OCG",  "Outgoing Card Generation: modulo BPC que genera el archivo de solicitudes aprobadas de maquila (entre SVBO y Cargen).", "tecnico", "sv-canales"),
    ("PayTrue",         "Motor externo de evaluacion de riesgo y fraude. Reemplaza a SVFM (no licenciado). Modulo 2 del autorizador.", "proveedor", "sv-canales"),
    # Modelo de datos SmartVista
    ("agingPeriod",     "Campo SmartVista que indica nivel de mora: E1=0-1 (sin restriccion), E2=2-3 (parcial), E3>=4 (bloqueo mayoritario).", "tecnico", "sv-canales"),
    ("E1",              "agingPeriod 0 o 1  --  sin restricciones funcionales; solo indicador visual de atraso.", "negocio", "sv-canales"),
    ("E2",              "agingPeriod 2 o 3  --  restricciones parciales: disposiciones bloqueadas; consulta y pago habilitados.", "negocio", "sv-canales"),
    ("E3",              "agingPeriod >= 4  --  bloqueo de la mayoria de funciones; solo pago disponible.", "negocio", "sv-canales"),
    ("amountHoldPlaced","Campo boolean en getTransactions v22: true = compra e-commerce en pre-autorizacion sin liquidar ('En Proceso').", "tecnico", "sv-canales"),
    ("Classification",  "Campo SmartVista: F = tarjeta fisica, D = tarjeta digital. NO se determina por rango de BIN sino por este campo.", "tecnico", "sv-canales"),
    ("CSTS",            "Prefijo del catalogo de estatus de tarjeta en SmartVista (ej. CSTS_ACTIVE, CSTS_BLOCKED).", "tecnico", "sv-canales"),
    ("BLTP",            "Balance Type: subcuenta o cajon de saldo dentro del contrato de tarjeta en SmartVista.", "tecnico", "sv-canales"),
    ("PPNGI",           "Pago Para No Generar Intereses: monto minimo que evita cargos de interes al periodo siguiente.", "negocio", "sv-canales"),
    ("MAD",             "Monto minimo a pagar del periodo. Distinto del PPNGI; si se paga solo el MAD se generan intereses.", "negocio", "sv-canales"),
    ("Credito 18 digitos","Numero interno de SmartVista que identifica el contrato de TDC. Diferente al PAN de 16 digitos del plastico.", "tecnico", "sv-canales"),
    ("BIN 4268 0711",   "BIN del Producto 4900  --  Tarjeta de Credito R4. BIN 426807, producto 11.", "negocio", "sv-canales"),
    ("subBIN R4",       "BIN 426807 producto 11: digito 8vo posicion 0-4 = tarjeta digital; posicion 5-9 = tarjeta fisica.", "tecnico", "sv-canales"),
    # APIs SVIP
    ("getInstantCreditStatement","API SVIP: estado de cuenta en tiempo real (saldo, limite, disponible, PPNGI, MAD, fechas de corte/pago).", "tecnico", "sv-canales"),
    ("getTransactions", "API SVIP v22: listado de movimientos de la TDC. Incluye campo amountHoldPlaced.", "tecnico", "sv-canales"),
    ("getAccountCards", "API SVIP: listado de tarjetas por cuenta (fisica y digital, con campo Classification F/D).", "tecnico", "sv-canales"),
    ("updateCardStatus","API SVIP: cambia estatus de una tarjeta usando el catalogo CSTS (bloquear/desbloquear/cancelar).", "tecnico", "sv-canales"),
    ("getCardInfo",     "API SVIP: informacion detallada de una tarjeta individual.", "tecnico", "sv-canales"),
    ("CVV dinamico",    "Codigo de verificacion temporal generado por SVIP para transacciones de tarjeta digital en linea.", "tecnico", "sv-canales"),
    # Flujos y seguridad
    ("PGP",             "Pretty Good Privacy: cifrado del archivo de maquila con la llave publica del proveedor. Uno por maquilador.", "tecnico", "sv-canales"),
    ("HSM",             "Hardware Security Module: modulo de seguridad fisica Thales payShield10K. Cifrado individual por tarjeta.", "tecnico", "sv-canales"),
    ("OTP",             "One-Time Password: codigo de un solo uso enviado por SMS para autenticacion en operaciones sensibles.", "proceso", "sv-canales"),
    ("MAI_BDT_IC",      "Template de SMS de BanCoppel para notificacion de bloqueo de tarjeta al cliente.", "proceso", "sv-canales"),
    ("SMS_BDT_IC",      "Template de SMS de BanCoppel para notificacion de desbloqueo de tarjeta al cliente.", "proceso", "sv-canales"),
    # Canales
    ("SIWEB",           "Canal de atencion en sucursal y ventanilla. 5 User Stories en R4. Bloqueado por falta de APIs de Apificacion.", "canal", "sv-canales"),
    ("CAT",             "Centro de Atencion Telefonica: canal de agentes y autoservicio IVR. 12 User Stories en R4.", "canal", "sv-canales"),
    ("ICCAT",           "Consola de atencion del CAT: herramienta de los agentes que integra con SVIP.", "tecnico", "sv-canales"),
    ("IVR",             "Interactive Voice Response: canal telefonico de autoservicio (800 BanCoppel). 6 User Stories NO CUBIERTOS en R4.", "canal", "sv-canales"),
    ("ANI",             "Automatic Number Identification: identifica el numero telefonico que origina la llamada para autenticar al cliente.", "tecnico", "sv-canales"),
    ("DTMF",            "Dual-Tone Multi-Frequency: tonos de teclado que el IVR usa para capturar datos sin que el agente escuche.", "tecnico", "sv-canales"),
    # Productos y planes
    ("MSI",             "Meses Sin Intereses: plan de compras diferidas procesado via E-Global en R4. Pruebas de integracion en scope.", "negocio", "sv-canales"),
    ("MCI",             "Meses Con Intereses: plan de compras diferidas (CrediSoluciones/Pagos Fijos) procesado en SmartVista. Backend R4; App en R4.5.", "negocio", "sv-canales"),
    ("DPP",             "Deferred Payment Plan: modulo de SmartVista para planes de pagos diferidos (MCI). NO contratado por BanCoppel en R4  --  gap critico.", "tecnico", "sv-canales"),
    ("CrediSoluciones", "Producto de BanCoppel para compras a plazos con interes (MCI). Genera planes de pagos fijos en SmartVista.", "negocio", "sv-canales"),
    # Contabilidad
    ("TRNT",            "Transaccion contable de reclasificacion en SmartVista (ej. T623 = pago a cuenta CrediSoluciones).", "proceso", "sv-canales"),
    ("Grupo contable 13","Grupo contable SmartVista para capital no corriente en reclasificacion de MCI. La reclasificacion NO debe pasar por cuenta 2402.", "negocio", "sv-canales"),
    ("Cuenta 2402",     "Cuenta contable de compensacion de interchange Eglobal. La reclasificacion MCI NO debe recircular por esta cuenta.", "negocio", "sv-canales"),
    ("Transaccion 623", "Codigo de transaccion SIWEB: 'Pago a cuenta de CrediSoluciones'. Relevante para contabilidad de MCI.", "negocio", "sv-canales"),
    ("PISA",            "Core bancario legado donde permanecen la contabilidad general y el expediente del cliente en coexistencia con Unity.", "tecnico", "sv-canales"),
    # Maquila
    ("GID",             "Giesecke & Devrient (GyD): maquilador de tarjetas. Primer proveedor certificado con layout R4.", "proveedor", "sv-canales"),
    ("Forza",           "Maquilador de tarjetas. Certificacion de layout R4 pendiente.", "proveedor", "sv-canales"),
    ("TGS",             "Thomas Greg & Sons: maquilador de tarjetas con mayor cantidad de tarjetas asignadas.", "proveedor", "sv-canales"),
    ("Maquila",         "Fabricacion fisica de tarjetas de credito. Flujo: SVBO -> OCG -> Cargen -> PGP -> Connect Direct -> Maquilador.", "proceso", "sv-canales"),
    ("Maquilador",      "Proveedor que fabrica (emboza y personaliza) las tarjetas fisicas. R4: GID, Forza y TGS.", "proveedor", "sv-canales"),
    # Bloqueantes
    ("BYU0039",         "Ticket ValueEdge sobre 'Limite Maximo de Saldo a Favor'. Estado: Opened, in investigation. Bloquea HDU-SMART-R4-13 y HDU-SIWEB-R4-05.", "proceso", "sv-canales"),
    ("E-Global",        "Switch transaccional de BanCoppel que enruta autorizaciones hacia SmartVista. Canal de entrada del autorizador de 88 reglas.", "tecnico", "sv-canales"),
    ("Autorizador 88-reglas","Modulo de SmartVista: Modulo 1 rechaza por codigo ISO; Modulo 2 evalua riesgo via PayTrue.", "tecnico", "sv-canales"),
    ("PreGame",         "Fase de pre-analisis que dictamina cada User Story contra la documentacion de la plataforma SmartVista. Responsable: Appwhere.", "proceso", "sv-canales"),
    ("HDU",             "Historia de Usuario Detallada: unidad de trabajo de SmartVista y Canales. R4 tiene 59 User Stories en 4 canales.", "proceso", "sv-canales"),
    ("Producto 4900",   "Tarjeta de Credito de BanCoppel, unico producto en scope de R4. BIN 4268 0711.", "negocio", "sv-canales"),
    ("Producto 11",     "Codigo de producto SmartVista para el Producto 4900 (Tarjeta de Credito). BIN 426807 producto 11.", "tecnico", "sv-canales"),
    # v1.1.0  --  siglas de release. F&F y F&D NO son la misma sigla y confundirlas
    # produjo un error real: leer "TDC R3 F&F" como si R3 fuera un piloto y no la tarjeta fisica.
    ("F&F",              "Friends & Family: MODO DE LIBERACION acotado a empleados y allegados antes de la disponibilidad general, opuesto a 'Manos del Cliente'. Es el COMO se libera, no el QUE. 'TDC R3 F&F' = el release de tarjeta FISICA liberado en modo Friends & Family: las dos cosas a la vez. No confundir con F&D.", "proceso", "roadmap-unity-2025 + design-authority-v1.2"),
    ("Friends & Family", "Ver F&F. El Roadmap Unity 2025 contrapone 'Onboarding TDC Digital (Friends & Family)' con 'Onboarding TDC Digital (Manos del Cliente)' y 'TDC Digital y Fisica + Autorizador (Manos del Cliente)'. Aplica sobre un release, no lo sustituye.", "proceso", "roadmap-unity-2025"),
    ("Manos del Cliente","Modo de liberacion con disponibilidad general al cliente final, opuesto al piloto Friends & Family.", "proceso", "roadmap-unity-2025"),
    ("F&D",              "Fisica y Digital: convivencia de la tarjeta fisica y la digital en el mismo producto. Denota la FORMA del plastico, no un modo de liberacion. Los User Stories de Jira del canal App etiquetados 'Convivencia TDC F&D' se refieren a esto. No confundir con F&F.", "negocio", "respaldo-app-jira"),
]

# â"€â"€ User Story Catalog  --  Fuente: HDU_R4_CANALES APP_SIWEB_CATT_SMARTVISTA.xlsx â"€â"€â"€â"€â"€â"€
# Distribucion: SV=22, APP=20, CAT=12, SIWEB=5 (59 total; HDU-SMARTVISTA-R4-16 = alias de SMART-R4-16)
# pregame_status: native=total nativo, configurable=total parametrizable, partial=parcial,
#                 not_covered=no cubierto, tbd=por determinar
HDU_CATALOG = [
    # SmartVista  --  SV-MF-01: Solicitud de Maquila Automatizada
    {"id": "HDU-SMART-R4-01", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Certificar layouts de maquila con proveedores GID/Forza/TGS", "pregame_status": "partial",
     "dtm_id": "DTM_ExecuteCardManufacturingRequest",
     "notes": "Cifrado PGP+HSM; certificacion Forza/TGS pendiente; rechazo de caracteres no embosables"},
    {"id": "HDU-SMART-R4-02", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Consultar inventario de tarjetas por sucursal", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Consulta distingue existencia vs en-ruta vs por-fabricar; filtro por tipo de sucursal a construir"},
    {"id": "HDU-SMART-R4-03", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Calcular maquila con parametros de abasto (piso, semanas, redondeo 250)", "pregame_status": "not_covered",
     "dtm_id": "DTM_CalculateCardManufacturing",
     "notes": "GAP: logica de calculo parametrico no nativa en SmartVista; requiere desarrollo. Batch 6AM."},
    {"id": "HDU-SMART-R4-04", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Ejecutar solicitud automatizada de maquila", "pregame_status": "partial",
     "dtm_id": "DTM_ExecuteCardManufacturingRequest",
     "notes": "SVBO->SVCG automatizado via NFS+Cron; OCG y Connect Direct manuales en R4"},
    {"id": "HDU-SMART-R4-05", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Ejecutar solicitud manual de maquila", "pregame_status": "native",
     "dtm_id": None,
     "notes": "Demo confirmo funcionamiento punta a punta para debito y credito"},
    {"id": "HDU-SMART-R4-06", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Generar archivos seguros de maquila (PGP+HSM+Connect Direct)", "pregame_status": "native",
     "dtm_id": None,
     "notes": "Flujo SVBO->OCG->Cargen->PGP->ConnectDirect confirmado"},
    {"id": "HDU-SMART-R4-07", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Dar seguimiento a estatus de lotes de maquila", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Reporteria de existencia existe; integracion paqueteria pendiente"},
    {"id": "HDU-SMART-R4-08", "canal": "smartvista", "funcionalidad_macro": "SV-MF-01",
     "narrativa_corta": "Controlar recepcion y cancelacion de lotes", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Procesos en SmartVista; parametrizacion de estados pendiente"},
    # SmartVista  --  SV-MF-02: Comisiones y Catalogos
    {"id": "HDU-SMART-R4-09", "canal": "smartvista", "funcionalidad_macro": "SV-MF-02",
     "narrativa_corta": "Gestion de comisiones por catalogo centralizado (homologacion BANXICO)", "pregame_status": "configurable",
     "dtm_id": None,
     "notes": "Catalogo existe en SmartVista; solo requiere configuracion de valores BanCoppel"},
    # SmartVista  --  SV-MF-03: Autorizador 88-reglas
    {"id": "HDU-SMART-R4-10", "canal": "smartvista", "funcionalidad_macro": "SV-MF-03",
     "narrativa_corta": "Actualizar nombre del producto en pantallas de canales desde catalogo SV", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Catalogo existe; modificar App y SIWEB para consumirlo en lugar de hardcode"},
    {"id": "HDU-SMART-R4-11", "canal": "smartvista", "funcionalidad_macro": "SV-MF-03",
     "narrativa_corta": "Configurar criterios del autorizador (88 reglas BPC: Modulo1 ISO + Modulo2 PayTrue)", "pregame_status": "partial",
     "dtm_id": "DTM_ValidateBPCAuthorization",
     "notes": "Autorizador base nativo; integracion PayTrue como delta. E-Global->SV->PayTrue"},
    # SmartVista  --  SV-MF-04: Saldo a Favor / Overpayment
    {"id": "HDU-SMART-R4-12", "canal": "smartvista", "funcionalidad_macro": "SV-MF-04",
     "narrativa_corta": "Parametrizar limite de saldo a favor por tramo de linea de credito", "pregame_status": "configurable",
     "dtm_id": None,
     "notes": "Parametro existe en SmartVista; configurar valores BanCoppel"},
    {"id": "HDU-SMART-R4-13", "canal": "smartvista", "funcionalidad_macro": "SV-MF-04",
     "narrativa_corta": "Validar limite de saldo a favor en transacciones (rechazo completo, sin poliza parcial)", "pregame_status": "tbd",
     "dtm_id": "DTM_ManageOverpaymentLimit",
     "notes": "BLOQUEANTE: ticket BYU0039 en ValueEdge 'Opened, in investigation'. Dictamen depende del cierre."},
    {"id": "HDU-SMART-R4-14", "canal": "smartvista", "funcionalidad_macro": "SV-MF-04",
     "narrativa_corta": "Excluir abonos bancarios SPEI del limite de credito hasta confirmacion", "pregame_status": "tbd",
     "dtm_id": None,
     "notes": "Supuesto abierto sobre comportamiento del clearing interbancario en SmartVista"},
    # SmartVista  --  SV-MF-05: Catalogo / Gestion de Tarjetas
    {"id": "HDU-SMART-R4-15", "canal": "smartvista", "funcionalidad_macro": "SV-MF-05",
     "narrativa_corta": "Actualizar mensajes de error desde catalogo centralizado (homologacion BANXICO, 3 canales)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Catalogo de mensajes existe; App, SIWEB y CAT deben modificarse para consumirlo"},
    {"id": "HDU-SMART-R4-16", "canal": "smartvista", "funcionalidad_macro": "SV-MF-05",
     "narrativa_corta": "Gestionar campanas de compras diferidas MSI/MCI (parametrizacion)", "pregame_status": "configurable",
     "dtm_id": None,
     "notes": "MSI via E-Global R4; MCI backend R4 (App en R4.5). Grupo contable 13; NO cuenta 2402/Eglobal"},
    {"id": "HDU-SMART-R4-17", "canal": "smartvista", "funcionalidad_macro": "SV-MF-05",
     "narrativa_corta": "Gestionar estatus de tarjeta CSTS (fisica y digital)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Gestion CSTS nativa; clasificacion F/D por campo Classification (no BIN); transiciones como delta"},
    {"id": "HDU-SMART-R4-18", "canal": "smartvista", "funcionalidad_macro": "SV-MF-05",
     "narrativa_corta": "Reposicion y reemplazo de tarjeta (robo, extravÃ­o, dano, vencimiento)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Proceso de reemplazo existe; limite y tipos especificos como delta; credito 18 digitos se mantiene"},
    # SmartVista  --  SV-MF-06: Compras Diferidas / Liquidacion
    {"id": "HDU-SMART-R4-19", "canal": "smartvista", "funcionalidad_macro": "SV-MF-06",
     "narrativa_corta": "Gestionar PPNGI y MAD en estado de cuenta", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "PPNGI calculado en SmartVista; exposicion correcta en APIs como delta"},
    {"id": "HDU-SMART-R4-20", "canal": "smartvista", "funcionalidad_macro": "SV-MF-06",
     "narrativa_corta": "Liquidar plan de pagos diferidos anticipadamente", "pregame_status": "partial",
     "dtm_id": "DTM_SettleDeferredPurchasePlan",
     "notes": "Liquidacion anticipada existe; validaciones especificas (capital+intereses devengados) como delta"},
    {"id": "HDU-SMART-R4-21", "canal": "smartvista", "funcionalidad_macro": "SV-MF-06",
     "narrativa_corta": "Cancelar plan de pagos diferidos desde canales digitales", "pregame_status": "not_covered",
     "dtm_id": "DTM_CancelDeferredPurchasePlan",
     "notes": "GAP CRITICO: modulo DPP no contratado por BanCoppel. Requiere contratacion o desarrollo alternativo."},
    # APP  --  APP-MF-01: Consulta y Estado de Cuenta
    {"id": "HDU-APP-R4-01", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Visualizar estado de cuenta de TDC en App (getInstantCreditStatement)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Modulo TDC a construir; APIs SVIP disponibles. agingPeriod E1/E2/E3 visual."},
    {"id": "HDU-APP-R4-02", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Gestionar convivencia de tarjeta fisica y digital en App", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "SmartVista expone ambas; App debe construir diferenciacion visual y estados individuales"},
    {"id": "HDU-APP-R4-03", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Operar botones de accion por estatus CSTS de tarjeta", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "CSTS de SmartVista disponible; logica de habilitacion/bloqueo por agingPeriod a construir en App"},
    {"id": "HDU-APP-R4-04", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Visualizar detalle de tarjeta fisica y digital (getAccountCards)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "APIs disponibles; pantalla con distincion fisica/digital a construir"},
    {"id": "HDU-APP-R4-05", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Visualizar detalle de tarjeta en pantalla dedicada", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Pantalla dedicada con cancelacion inmediata irreversible"},
    {"id": "HDU-APP-R4-06", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Gestionar CVV dinamico de tarjeta digital con timer de visibilidad", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Servicio CVV dinamico en SmartVista; componente de timer a construir en App"},
    {"id": "HDU-APP-R4-07", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Etiquetar transacciones 'En Proceso' (amountHoldPlaced=true)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Campo amountHoldPlaced en getTransactions v22; etiqueta visual a construir"},
    {"id": "HDU-APP-R4-08", "canal": "app", "funcionalidad_macro": "APP-MF-01",
     "narrativa_corta": "Consultar movimientos del periodo (getTransactions v22)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Movimientos en SVIP; filtros y UI a construir; distincion MSI/MCI vs normal"},
    {"id": "HDU-APP-R4-09", "canal": "app", "funcionalidad_macro": "APP-MF-02",
     "narrativa_corta": "Consultar estado de planes de compras diferidas (CrediSoluciones)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Planes en SmartVista; visualizacion de CrediSoluciones a construir"},
    # APP  --  APP-MF-02/03: Pagos y Restricciones
    {"id": "HDU-APP-R4-10", "canal": "app", "funcionalidad_macro": "APP-MF-02",
     "narrativa_corta": "Procesar pago de TDC desde App (MAD/PPNGI/total/libre)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "APIs de pago disponibles; flujo completo con validacion saldo a favor a construir"},
    {"id": "HDU-APP-R4-11", "canal": "app", "funcionalidad_macro": "APP-MF-02",
     "narrativa_corta": "Gestionar eliminacion de tarjeta digital (cancelacion definitiva en SmartVista)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Cancelacion en SmartVista; flujo de eliminacion desde App a construir; irreversible"},
    {"id": "HDU-APP-R4-12", "canal": "app", "funcionalidad_macro": "APP-MF-02",
     "narrativa_corta": "Gestionar limite de reposiciones de tarjeta por periodo", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Limite en SmartVista; UI con bloqueo cuando se alcanza a construir"},
    {"id": "HDU-APP-R4-13", "canal": "app", "funcionalidad_macro": "APP-MF-03",
     "narrativa_corta": "Notificar impactos al eliminar tarjeta digital (aviso previo)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: logica de aviso de impactos es del canal; SmartVista no la gestiona"},
    # APP  --  APP-MF-04: Montos Diferidos
    {"id": "HDU-APP-R4-14", "canal": "app", "funcionalidad_macro": "APP-MF-04",
     "narrativa_corta": "Visualizar desglose de compras diferidas MCI en App", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Desglose MCI en SmartVista; UI a construir"},
    {"id": "HDU-APP-R4-15", "canal": "app", "funcionalidad_macro": "APP-MF-04",
     "narrativa_corta": "Visualizar desglose de compras diferidas MSI en App (via E-Global)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "MSI procesado en E-Global; App debe integrar con E-Global, no solo SVIP"},
    {"id": "HDU-APP-R4-16", "canal": "app", "funcionalidad_macro": "APP-MF-04",
     "narrativa_corta": "Visualizar montos diferidos en estado de cuenta App", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "Montos diferidos separados de compras normales en estado de cuenta"},
    # APP  --  APP-MF-05: Validaciones y Restricciones
    {"id": "HDU-APP-R4-17", "canal": "app", "funcionalidad_macro": "APP-MF-05",
     "narrativa_corta": "Mostrar restricciones por mora (agingPeriod E1/E2/E3) en App", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "agingPeriod disponible en SVIP; restricciones visuales y mensajes a construir"},
    {"id": "HDU-APP-R4-18", "canal": "app", "funcionalidad_macro": "APP-MF-05",
     "narrativa_corta": "Validar limite de saldo a favor en middleware de App", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: validacion en middleware App adicional a la de SVIP; construccion completa en capa App"},
    {"id": "HDU-APP-R4-19", "canal": "app", "funcionalidad_macro": "APP-MF-05",
     "narrativa_corta": "Mostrar mensaje de restriccion por saldo a favor (homologado entre canales)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: mensaje de presentacion del canal; construccion completa en App"},
    {"id": "HDU-APP-R4-20", "canal": "app", "funcionalidad_macro": "APP-MF-05",
     "narrativa_corta": "Validacion preventiva de inputs de pago en App (formato, minimo, maximo)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: validacion frontend del canal; construccion completa en App"},
    # CAT  --  CAT-MF-01: IVR Autoservicio
    {"id": "HDU-CAT-R4-01", "canal": "cat", "funcionalidad_macro": "CAT-MF-01",
     "narrativa_corta": "Acceso al menu IVR con ANI (identificacion automatica del numero)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: IVR es canal externo; integracion ANI+SmartVista requiere construccion completa"},
    {"id": "HDU-CAT-R4-02", "canal": "cat", "funcionalidad_macro": "CAT-MF-01",
     "narrativa_corta": "Consultar saldos y movimientos desde IVR (getInstantCreditStatement)", "pregame_status": "not_covered",
     "dtm_id": "DTM_RetrieveCreditCardBalanceAndMovements",
     "notes": "GAP: locucionesy menu IVR son del canal; SmartVista solo expone APIs"},
    # CAT  --  CAT-MF-02: Autenticacion y Perfil
    {"id": "HDU-CAT-R4-03", "canal": "cat", "funcionalidad_macro": "CAT-MF-02",
     "narrativa_corta": "Identificar cliente y perfil TDC en ICCAT (credito 18 digitos)", "pregame_status": "partial",
     "dtm_id": "DTM_RetrieveCustomerCreditCardProfile",
     "notes": "APIs SVIP disponibles; integracion ICCAT con SmartVista a construir"},
    {"id": "HDU-CAT-R4-04", "canal": "cat", "funcionalidad_macro": "CAT-MF-02",
     "narrativa_corta": "Gestionar intentos de autenticacion en CAT (3 intentos max, bloqueo)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: logica de intentos es del canal IVR; SmartVista no gestiona contador"},
    # CAT  --  Bloqueo y Desbloqueo
    {"id": "HDU-CAT-R4-05", "canal": "cat", "funcionalidad_macro": "CAT-MF-02",
     "narrativa_corta": "Bloquear tarjeta desde CAT via ICCAT (updateCardStatus + SMS MAI_BDT_IC)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "API updateCardStatus en SVIP; integracion ICCAT + envio SMS a construir"},
    {"id": "HDU-CAT-R4-06", "canal": "cat", "funcionalidad_macro": "CAT-MF-02",
     "narrativa_corta": "Desbloquear tarjeta desde CAT con OTP SMS de 4 digitos", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "API en SVIP; flujo OTP SMS e ICCAT a construir; solo bloqueos por cliente, no fraude"},
    {"id": "HDU-CAT-R4-07", "canal": "cat", "funcionalidad_macro": "CAT-MF-02",
     "narrativa_corta": "Consultar estatus de tarjeta desde CAT (getAccountCards/getCardInfo)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "API en SVIP; modificacion pantalla ICCAT; estatus actualizado en tiempo real"},
    # CAT  --  Saldos y Movimientos IVR
    {"id": "HDU-CAT-R4-08", "canal": "cat", "funcionalidad_macro": "CAT-MF-01",
     "narrativa_corta": "Completar integracion saldo/movimientos IVR con SVIP", "pregame_status": "not_covered",
     "dtm_id": "DTM_RetrieveCreditCardBalanceAndMovements",
     "notes": "GAP: integracion IVR-SVIP completa a construir; locuciones en espanol mexicano"},
    {"id": "HDU-CAT-R4-09", "canal": "cat", "funcionalidad_macro": "CAT-MF-01",
     "narrativa_corta": "Gestionar autenticacion reforzada en IVR (DTMF)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: logica de autenticacion IVR con DTMF; SmartVista no gestiona el flujo"},
    {"id": "HDU-CAT-R4-10", "canal": "cat", "funcionalidad_macro": "CAT-MF-01",
     "narrativa_corta": "Gestionar opciones de autoservicio IVR por nivel de mora (agingPeriod)", "pregame_status": "not_covered",
     "dtm_id": None,
     "notes": "GAP: menu dinamico IVR es del canal; SmartVista expone agingPeriod via SVIP"},
    # CAT  --  Reporte de Cancelacion
    {"id": "HDU-CAT-R4-11", "canal": "cat", "funcionalidad_macro": "CAT-MF-03",
     "narrativa_corta": "Registrar reporte de robo/extravio desde CAT (bloqueo + folio + SMS)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "API en SVIP; flujo ICCAT + SMS con folio a construir"},
    {"id": "HDU-CAT-R4-12", "canal": "cat", "funcionalidad_macro": "CAT-MF-03",
     "narrativa_corta": "Gestionar cancelacion definitiva de tarjeta desde CAT", "pregame_status": "partial",
     "dtm_id": "DTM_ManageCardCancellationReport",
     "notes": "Cubre robo/extravio/cambio estatus; dano/destruccion/cancelacion dependen de parametrizacion CSTS"},
    # SIWEB
    {"id": "HDU-SIWEB-R4-01", "canal": "siweb", "funcionalidad_macro": "SIWEB-MF-01",
     "narrativa_corta": "Consultar saldos y movimientos de TDC en SIWEB (getInstantCreditStatement)", "pregame_status": "partial",
     "dtm_id": None,
     "notes": "APIs SVIP disponibles; UI SIWEB a construir; distincion amountHoldPlaced"},
    {"id": "HDU-SIWEB-R4-02", "canal": "siweb", "funcionalidad_macro": "SIWEB-MF-01",
     "narrativa_corta": "Procesar compras diferidas MCI/MSI en SIWEB (Transaccion 623)", "pregame_status": "partial",
     "dtm_id": "DTM_ManageDeferredPurchase",
     "notes": "MCI via SmartVista (DPP); MSI via E-Global; cierre automatico DPP depende de modulo no contratado"},
    {"id": "HDU-SIWEB-R4-03", "canal": "siweb", "funcionalidad_macro": "SIWEB-MF-01",
     "narrativa_corta": "Cancelar plan de compras diferidas desde SIWEB", "pregame_status": "not_covered",
     "dtm_id": "DTM_ManageDeferredPurchase",
     "notes": "GAP CRITICO: modulo DPP no contratado; cierre automatico del pago fijo no disponible en R4"},
    {"id": "HDU-SIWEB-R4-04", "canal": "siweb", "funcionalidad_macro": "SIWEB-MF-01",
     "narrativa_corta": "Registrar efectos contables de compras diferidas (TRNT SmartVista-SIWEB-PISA)", "pregame_status": "partial",
     "dtm_id": "DTM_RegisterDeferredPurchaseAccountingEffects",
     "notes": "Guia contable formal pendiente (dependencia abierta). Grupo 13; NO cuenta 2402/Eglobal"},
    {"id": "HDU-SIWEB-R4-05", "canal": "siweb", "funcionalidad_macro": "SIWEB-MF-02",
     "narrativa_corta": "Validar limite de saldo a favor en transacciones de caja (ventanilla)", "pregame_status": "tbd",
     "dtm_id": "DTM_ValidateOverpaymentLimit",
     "notes": "BLOQUEANTE: misma dependencia BYU0039 que SMART-R4-13. Reutiliza validacion centralizada en SVIP."},
]

# â"€â"€ DTM Catalog  --  Fuente: TDC_R4_SV_Canales_PreGame + HDU_R4 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
DTM_CATALOG = [
    {
        "id": "DTM_CalculateCardManufacturing",
        "funcionalidad_macro": "SV-MF-01",
        "hdus_asociadas": "HDU-SMART-R4-03",
        "funcion": "Calcula reabastecimiento por sucursal con inventario minimo, semanas de cobertura y redondeo a multiplos de 250 plasticos",
        "status": "not_covered",
        "gap_description": "Logica de calculo parametrico (piso, semanas a dotar, redondeo 250, mes calendario) no nativa en SmartVista. Requiere desarrollo.",
        "canal": "smartvista",
        "notes": "Batch 6AM; consumo promedio sobre mes calendario (no ventana fija)",
    },
    {
        "id": "DTM_ExecuteCardManufacturingRequest",
        "funcionalidad_macro": "SV-MF-01",
        "hdus_asociadas": "HDU-SMART-R4-01,HDU-SMART-R4-04",
        "funcion": "Orquesta solicitud de maquila a partir del reorden calculado, valida duplicidad y coordina notificacion a Suministros",
        "status": "partial",
        "gap_description": "SVBO->SVCG automatizado via NFS+Cron. GAP: OCG y entrega a Connect Direct son 2 pasos manuales en R4.",
        "canal": "smartvista",
        "notes": "RPA de reordenes: correo diario a ~30 destinatarios con numero de lote",
    },
    {
        "id": "DTM_CancelDeferredPurchasePlan",
        "funcionalidad_macro": "SV-MF-06",
        "hdus_asociadas": "HDU-SMART-R4-21",
        "funcion": "Finaliza anticipadamente el financiamiento de un plan de CrediSoluciones desde canales digitales; recalcula saldo y refleja cambio de limite",
        "status": "not_covered",
        "gap_description": "GAP CRITICO: modulo DPP no contratado por BanCoppel. Requiere contratacion adicional de modulo BPC o desarrollo alternativo.",
        "canal": "smartvista",
        "notes": "Bloquea tambien cancelacion de planes CrediSoluciones desde SIWEB (HDU-SIWEB-R4-03)",
    },
    {
        "id": "DTM_SettleDeferredPurchasePlan",
        "funcionalidad_macro": "SV-MF-06",
        "hdus_asociadas": "HDU-SMART-R4-20",
        "funcion": "Calcula saldo con capital e intereses devengados a la fecha; ejecuta liquidacion anticipada y actualiza estado del plan a 'Liquidado'",
        "status": "partial",
        "gap_description": "Liquidacion anticipada existe en SmartVista; validaciones especificas (TRNT 623, contabilidad) como delta.",
        "canal": "smartvista",
        "notes": "TRNT: Pago CGO a CTA de CrediSoluciones",
    },
    {
        "id": "DTM_ManageOverpaymentLimit",
        "funcionalidad_macro": "SV-MF-04",
        "hdus_asociadas": "HDU-SMART-R4-13",
        "funcion": "Determina monto maximo de saldo a favor segun tramo de linea de credito vigente; rechaza operacion completa si se excede (sin poliza parcial)",
        "status": "tbd",
        "gap_description": "BLOQUEANTE: ticket BYU0039 en ValueEdge 'Opened, in investigation'. Dictamen no puede cerrarse hasta resolucion del ticket.",
        "canal": "smartvista",
        "notes": "Regla centralizada en SVIP reutilizable en todos los canales (App, SIWEB, ventanilla)",
    },
    {
        "id": "DTM_ValidateOverpaymentLimit",
        "funcionalidad_macro": "SIWEB-MF-02",
        "hdus_asociadas": "HDU-SIWEB-R4-05",
        "funcion": "Valida pago o deposito en ventanilla contra el limite centralizado de saldo a favor; rechaza sin generar poliza parcial",
        "status": "tbd",
        "gap_description": "BLOQUEANTE: misma dependencia BYU0039 que DTM_ManageOverpaymentLimit.",
        "canal": "siweb",
        "notes": "Reutiliza la validacion centralizada en SVIP; no se duplica logica en el canal",
    },
    {
        "id": "DTM_ValidateBPCAuthorization",
        "funcionalidad_macro": "SV-MF-03",
        "hdus_asociadas": "HDU-SMART-R4-11",
        "funcion": "Administra criterios del autorizador de 88 reglas: Modulo 1 rechaza por codigo ISO; Modulo 2 evalua riesgo via PayTrue",
        "status": "partial",
        "gap_description": "Autorizador base nativo en SmartVista. GAP: integracion con PayTrue (reemplaza SVFM no licenciado) como delta a construir.",
        "canal": "smartvista",
        "notes": "Flujo: E-Global -> SmartVista -> PayTrue -> respuesta ISO",
    },
    {
        "id": "DTM_ManageDeferredPurchase",
        "funcionalidad_macro": "SIWEB-MF-01",
        "hdus_asociadas": "HDU-SIWEB-R4-02,HDU-SIWEB-R4-03",
        "funcion": "Calcula liquidacion de plan MCI apoyandose en aceleracion existente; gestiona cierre del pago fijo",
        "status": "partial",
        "gap_description": "GAP: cierre automatico del pago fijo depende del modulo DPP no contratado. Cancelacion de plan (HDU-SIWEB-R4-03) NO CUBIERTA.",
        "canal": "siweb",
        "notes": "MSI procesado via E-Global; MCI via SmartVista. Transaccion SIWEB 623.",
    },
    {
        "id": "DTM_RegisterDeferredPurchaseAccountingEffects",
        "funcionalidad_macro": "SIWEB-MF-01",
        "hdus_asociadas": "HDU-SIWEB-R4-04",
        "funcion": "Construye la frontera contable SmartVista-SIWEB-PISA, las TRNT, las cuentas contables y las reglas de reverso",
        "status": "partial",
        "gap_description": "Guia contable formal pendiente de cierre (dependencia abierta D01 en RAID). Sin ella no se pueden definir criterios de aceptacion.",
        "canal": "siweb",
        "notes": "Grupo contable 13 para MCI; NO reclasificar por cuenta 2402/Eglobal",
    },
    {
        "id": "DTM_RetrieveCreditCardBalanceAndMovements",
        "funcionalidad_macro": "CAT-MF-01",
        "hdus_asociadas": "HDU-CAT-R4-02,HDU-CAT-R4-08",
        "funcion": "Integra saldo, cuenta y movimientos de TDC con el IVR; gestiona locuciones, rango de consulta y contingencia de fallo SVIP",
        "status": "not_covered",
        "gap_description": "GAP: integracion IVR-SVIP completa a construir. El IVR es un canal externo; SmartVista solo expone las APIs. Incluye locuciones en espanol MX.",
        "canal": "cat",
        "notes": "API: getInstantCreditStatement + getTransactions v22 de SVIP",
    },
    {
        "id": "DTM_RetrieveCustomerCreditCardProfile",
        "funcionalidad_macro": "CAT-MF-02",
        "hdus_asociadas": "HDU-CAT-R4-03",
        "funcion": "Integra consultas nativas de cliente, productos y tarjetas con ICCAT; enmascaramiento de datos sensibles; credito 18 digitos",
        "status": "partial",
        "gap_description": "APIs SVIP disponibles. GAP: integracion con ICCAT (consola de agentes) a construir. Autenticacion cliente APOLO como delta.",
        "canal": "cat",
        "notes": "Credito 18 digitos (numero interno SV) distinto al PAN de 16 del plastico",
    },
    {
        "id": "DTM_ManageCardCancellationReport",
        "funcionalidad_macro": "CAT-MF-03",
        "hdus_asociadas": "HDU-CAT-R4-12",
        "funcion": "Cubre cancelacion por robo, extravio y cambio de estatus desde ICCAT; genera folio y notifica al cliente",
        "status": "partial",
        "gap_description": "Cancelacion por dano, destruccion y voluntaria dependen de parametrizacion de estatus CSTS y transiciones pendientes.",
        "canal": "cat",
        "notes": "Estado final irreversible; folio generado por ICCAT",
    },
    {
        "id": "NO-DTM-SMART-R4-10",
        "funcionalidad_macro": "SV-MF-03",
        "hdus_asociadas": "HDU-SMART-R4-10",
        "funcion": "Actualizar fuente de nombre del producto al catalogo SmartVista en pantallas de App y SIWEB (sustituir hardcode)",
        "status": "partial",
        "gap_description": "Sin DTM asignado. El catalogo existe en SmartVista; App y SIWEB deben modificar sus pantallas para consumirlo.",
        "canal": "smartvista",
        "notes": "Cambio de fuente de datos; no es pantalla nueva",
    },
    {
        "id": "NO-DTM-SMART-R4-15",
        "funcionalidad_macro": "SV-MF-05",
        "hdus_asociadas": "HDU-SMART-R4-15",
        "funcion": "Actualizar fuente de mensajes de error al catalogo SmartVista en App, SIWEB y CAT (homologacion BANXICO)",
        "status": "partial",
        "gap_description": "Sin DTM asignado. Catalogo de mensajes existe; 3 canales deben modificarse para consumirlo.",
        "canal": "smartvista",
        "notes": "Mismo codigo de error = mismo mensaje en todos los canales; sin deploy al cambiar catalogo",
    },
]

INITIAL_DECISIONS = [
    {
        "id":          "ADR-UNITY-001",
        "title":       "Plataforma: Temenos Transact como nuevo core bancario",
        "status":      "accepted",
        "context":     "BanCoppel requiere modernizar su core bancario IBM Informix para soportar nuevos productos y escalar digitalmente.",
        "decision":    "Adoptar Temenos Transact como plataforma de nuevo core bancario. Lanzar primero con productos nuevos sin migracion inmediata del portfolio Informix.",
        "consequences": "Operacion dual de ambos sistemas durante el periodo transicional. Requiere estrategia de coexistencia por canal y producto.",
        "date":        "2024-01-01",
    },
    {
        "id":          "ADR-UNITY-002",
        "title":       "Estrategia de coexistencia Informix - Unity (pendiente)",
        "status":      "proposed",
        "context":     "Con Unity R4 en construccion y el resto del portfolio en Informix, se necesita definir el patron de coexistencia definitivo.",
        "decision":    "PENDIENTE  --  posibles escenarios: sustitucion total, coexistencia permanente, o hibrido por dominio.",
        "consequences": "Define el roadmap de migracion de SPs Informix y la arquitectura de integracion de canales.",
        "date":        "2026-08-14",
    },
    {
        "id":          "ADR-UNITY-003",
        "title":       "Routing de canales digitales por producto (pendiente)",
        "status":      "proposed",
        "context":     "AppMovil y otros canales necesitan saber a que sistema llamar segun el producto del cliente.",
        "decision":    "PENDIENTE  --  definir la capa de enrutamiento (API Gateway, ESB, logica en canal).",
        "consequences": "Impacta la arquitectura de AppMovil (49 SPs Informix actuales) y los nuevos canales de Unity.",
        "date":        "2026-08-14",
    },
    {
        "id":          "ADR-UNITY-004",
        "title":       "SmartVista (BPC) como plataforma de gestion de tarjetas en R4",
        "status":      "accepted",
        "context":     "Unity R4 entrega Producto 4900 (Tarjeta de Credito). Se requiere un sistema de gestion de tarjetas que reemplace CMS/Intercard.",
        "decision":    "Adoptar SmartVista de BPC Banking Technologies como el motor de gestion de tarjetas para el Producto 4900.",
        "consequences": "CMS/Intercard/Macweb quedan como sistemas a retirar post-Go-Live. eGlobal valida 88 reglas ISO 8583 contra SmartVista.",
        "date":        "2026-01-01",
    },
]


# â"€â"€ Funciones de carga â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€


# ── v1.5.0 Marco 3D SISTEMA ──────────────────────────────────────────────────

PROGRAM_SYSTEMS = [
    {"id": "smartvista",     "name": "SmartVista",          "vendor": "BPC Banking Technologies",  "togaf_type": "processors",  "togaf_state": "transitional", "togaf_abb": "SV",  "role_in_r4": "Motor de gestion de tarjetas TDC P4900 (autorizacion, ciclo de vida, MDM)",  "status": "active",  "notes": "Reemplaza CMS/Intercard/Macweb post-GoLive"},
    {"id": "transact",       "name": "Temenos Transact",    "vendor": "Temenos",                   "togaf_type": "core",        "togaf_state": "target",       "togaf_abb": "TRN", "role_in_r4": "Core bancario destino: cuentas, originacion, contabilidad GL",               "status": "active",  "notes": "Plataforma target del programa Unity R4"},
    {"id": "informix",       "name": "Informix IDS",        "vendor": "IBM (PISA)",                "togaf_type": "core",        "togaf_state": "baseline",     "togaf_abb": "INF", "role_in_r4": "Core bancario actual; fuente de reglas y logica de negocio a migrar",        "status": "active",  "notes": "10,144 SPs; 11,391 reglas; sistema de registro hasta cutover"},
    {"id": "apolo",          "name": "Apolo",               "vendor": "Appwhere",                  "togaf_type": "channels",    "togaf_state": "transitional", "togaf_abb": "APO", "role_in_r4": "Canal digital para oferta y originacion de TDC",                            "status": "active",  "notes": "37 User Stories catalogados; bridge hacia Transact"},
    {"id": "app-movil",      "name": "App Movil BanCoppel", "vendor": "Nova",                      "togaf_type": "channels",    "togaf_state": "transitional", "togaf_abb": "APP", "role_in_r4": "Canal movil: activacion, autorizacion TDC, pagos, consultas",               "status": "active",  "notes": "79 User Stories inventariadas; canal principal cliente digital"},
    {"id": "siweb",          "name": "SIWEB",               "vendor": "Interno BanCoppel",         "togaf_type": "channels",    "togaf_state": "baseline",     "togaf_abb": "SIW", "role_in_r4": "Canal web sucursal para operaciones de ventanilla y soporte",               "status": "active",  "notes": "Canal legacy; candidato a refactor post-R4"},
    {"id": "cat",            "name": "CAT",                 "vendor": "Por contratar",             "togaf_type": "channels",    "togaf_state": "transitional", "togaf_abb": "CAT", "role_in_r4": "Canales alternativos de pago (TPV, corresponsales, kioscos)",               "status": "at_risk", "notes": "Proveedor sin contrato al 2026-08-31; riesgo RISK-UNITY-R27"},
    {"id": "atlas",          "name": "Atlas (GCP)",         "vendor": "Google Cloud Platform",     "togaf_type": "data",        "togaf_state": "target",       "togaf_abb": "ATL", "role_in_r4": "Plataforma de datos analiticos y reportes regulatorios en la nube",         "status": "active",  "notes": "BigQuery + Dataflow; feeds desde Informix/Transact"},
    {"id": "controlm",       "name": "Control-M",           "vendor": "BMC Software",              "togaf_type": "integration", "togaf_state": "baseline",     "togaf_abb": "CTM", "role_in_r4": "Orquestador de batch: cierre de dia, integraciones, reportes nocturnos",    "status": "active",  "notes": "Jobs criticos: estados de cuenta, comisiones, cobranza"},
    {"id": "eglobal",        "name": "eGlobal",             "vendor": "Interno BanCoppel",         "togaf_type": "processors",  "togaf_state": "baseline",     "togaf_abb": "EGL", "role_in_r4": "Switch ISO 8583: 88 reglas de validacion de transacciones TDC",             "status": "active",  "notes": "Valida contra SmartVista en produccion; frontera critica"},
    {"id": "connect-direct", "name": "Connect:Direct",      "vendor": "IBM Sterling",              "togaf_type": "integration", "togaf_state": "baseline",     "togaf_abb": "CDR", "role_in_r4": "Transferencia segura de archivos batch entre sistemas y VISA/MC",           "status": "at_risk", "notes": "Licencia a revisar; alternativa MFT en evaluacion"},
    {"id": "cobranza",      "name": "Cobranza Direccionada","vendor": "Interno BanCoppel",         "togaf_type": "channels",    "togaf_state": "transitional", "togaf_abb": "COB", "role_in_r4": "Gestion de cartera vencida TDC P4900: aging, contacto y recuperacion",       "status": "at_risk", "notes": "37-50 USs pendientes de incorporar al inventario R4; pentest nov congela SIT"},
]

IT_CAPABILITIES = [
    {"id": "ITC-QE",      "name": "Quality Engineering",       "description": "Testing shift-left: pruebas unitarias, integracion, regresion, performance y UAT en todos los tracks", "category": "delivery",       "owner_component": "QE",
     "owner_name": "BanCoppel QA Lead",              "maturity_current": 2, "maturity_target": 4, "next_action": "Resolver conflicto ventana pentest vs SIT",              "next_action_due": "2026-09-05", "next_action_owner": "Mercedes Espinosa"},
    {"id": "ITC-DEVOPS",  "name": "DevOps & CI/CD",            "description": "Pipelines de integracion y despliegue continuo; automatizacion de builds y releases por track",         "category": "delivery",       "owner_component": "DevOps",
     "owner_name": "ACN DevOps Lead",                "maturity_current": 2, "maturity_target": 4, "next_action": "Confirmar ambientacion SIT con BanCoppel Infra",           "next_action_due": "2026-09-15", "next_action_owner": "BanCoppel Infra"},
    {"id": "ITC-ENV",     "name": "Environment Management",    "description": "Gestion de ambientes DEV/QA/UAT/STG/PROD; aprovisionamiento IaC y configuracion parametrizada",          "category": "infrastructure", "owner_component": "Infra",
     "owner_name": "BanCoppel Infra",                "maturity_current": 2, "maturity_target": 4, "next_action": "Confirmar entorno SIT listo al 15-oct",                    "next_action_due": "2026-09-15", "next_action_owner": "BanCoppel Infra"},
    {"id": "ITC-SEC",     "name": "Cybersecurity",             "description": "DevSecOps: SAST, SCA, secrets scan, DAST; cumplimiento CNBV/Banxico e ISO 27001",                        "category": "cross-cutting",  "owner_component": "Security",
     "owner_name": "Mercedes Espinosa",              "maturity_current": 2, "maturity_target": 4, "next_action": "Definir ventana pentest no conflictiva con SIT",            "next_action_due": "2026-09-05", "next_action_owner": "BanCoppel CISO"},
    {"id": "ITC-INTEROP", "name": "Interoperability & APIs",   "description": "Diseno y gestion de APIs REST/AsyncAPI; patrones de integracion entre sistemas del ecosistema",          "category": "architecture",   "owner_component": "Interop",
     "owner_name": "J.A. Valverde / BPC",            "maturity_current": 1, "maturity_target": 4, "next_action": "Obtener fecha entrega APIs SmartVista de BPC",              "next_action_due": "2026-08-29", "next_action_owner": "ACN Interop Lead"},
    {"id": "ITC-DATA",    "name": "Data Management",           "description": "Calidad de datos, contratos de datos, migracion Informix a Transact y feeds analiticos a Atlas",         "category": "data",           "owner_component": "Data",
     "owner_name": "BanCoppel Data / ACN MDP",       "maturity_current": 1, "maturity_target": 3, "next_action": "Definir plan carga inicial Golden Record a ATLAS",          "next_action_due": "2026-09-30", "next_action_owner": "BanCoppel Data"},
    {"id": "ITC-ARCH",    "name": "Architecture & Design",     "description": "Toma de decisiones arquitectonicas (ADRs), blueprint de sistemas, gobernanza tecnica del programa",      "category": "architecture",   "owner_component": "Arch",
     "owner_name": "Ramses Santos",                  "maturity_current": 2, "maturity_target": 4, "next_action": "Completar inventario APIs e integraciones R4",              "next_action_due": "2026-09-15", "next_action_owner": "Ramses Santos"},
    {"id": "ITC-CHG",     "name": "Change Management",         "description": "Gestion del cambio organizacional: capacitacion, comunicacion, adopcion de Transact por usuarios",       "category": "people",         "owner_component": "PMO",
     "owner_name": "BanCoppel PMO",                  "maturity_current": 1, "maturity_target": 3, "next_action": "Ejecutar plan comunicacion 3M tarjetahabientes",            "next_action_due": "2026-10-31", "next_action_owner": "BanCoppel PMO"},
    {"id": "ITC-AI",      "name": "AI/GenAI Engineering",      "description": "IA generativa para aceleracion: transpilacion SPL a Java, generacion de tests, analisis de codigo",     "category": "innovation",     "owner_component": "AI",
     "owner_name": "ACN AI Lead",                    "maturity_current": 2, "maturity_target": 3, "next_action": "Validar outputs transpilacion SPL a Java en brain",         "next_action_due": "2026-09-30", "next_action_owner": "ACN AI Lead"},
    {"id": "ITC-REL",     "name": "Release Management",        "description": "Coordinacion de releases por wave: CAB, ventanas de cambio, rollback plans y comunicacion",              "category": "delivery",       "owner_component": "Release",
     "owner_name": "BanCoppel PMO / ACN",            "maturity_current": 2, "maturity_target": 4, "next_action": "Confirmar fecha cierre SIT 15-dic en CAB",                 "next_action_due": "2026-09-01", "next_action_owner": "BanCoppel PMO"},
    {"id": "ITC-VND",     "name": "Vendor & ITSM",             "description": "Gestion de contratos y SLAs con Temenos, BPC, Appwhere, BMC; ITSM para incidentes y cambios",           "category": "governance",     "owner_component": "ITSM",
     "owner_name": "BanCoppel Adquisiciones",        "maturity_current": 1, "maturity_target": 4, "next_action": "Contratar proveedor CAT - RISK-001 critico",                "next_action_due": "2026-08-31", "next_action_owner": "BanCoppel Adquisiciones"},
    {"id": "ITC-OBS",     "name": "Observability & SRE",       "description": "Monitoreo RED metrics, tracing OTEL, alertas y SLOs del programa; Dynatrace/GCP Monitoring",             "category": "operations",     "owner_component": "SRE",
     "owner_name": "ACN SRE Lead",                   "maturity_current": 2, "maturity_target": 4, "next_action": "Activar alerting y dashboards en Dynatrace",                "next_action_due": "2026-10-15", "next_action_owner": "ACN SRE Lead"},
    {"id": "ITC-COMP",    "name": "Compliance & Regulatory",   "description": "Reportes CNBV (Anexos 33-36), cumplimiento Banxico, auditorias internas; trazabilidad reg.",             "category": "governance",     "owner_component": "Compliance",
     "owner_name": "Mercedes Espinosa / BanCoppel Legal", "maturity_current": 2, "maturity_target": 4, "next_action": "Cerrar hallazgos APO_F01 y SMA_F01 CNBV",             "next_action_due": "2026-09-30", "next_action_owner": "Mercedes Espinosa"},
]


def init_db(con: sqlite3.Connection) -> None:
    con.executescript(DDL)
    con.commit()
    for _sql in [
        "ALTER TABLE risks ADD COLUMN system_id TEXT REFERENCES program_systems(id)",
        "ALTER TABLE user_stories_inventory ADD COLUMN system_id TEXT REFERENCES program_systems(id)",
        "ALTER TABLE user_stories_inventory ADD COLUMN itcapability_ids TEXT",
    ]:
        try:
            con.execute(_sql)
        except Exception:
            pass
    con.commit()


def load_project_info(con: sqlite3.Connection) -> None:
    con.executemany(
        "INSERT OR REPLACE INTO project_info (key, value) VALUES (?, ?)",
        PROJECT_INFO.items(),
    )
    con.commit()
    print(f"  project_info      : {len(PROJECT_INFO)} entradas")


def load_products(con: sqlite3.Connection) -> None:
    for p in INITIAL_PRODUCTS:
        con.execute("""
            INSERT OR REPLACE INTO products
                (id, name, description, status, launch_date, temenos_module,
                 etb_capabilities, informix_domains, coexistence_mode, scope, notes)
            VALUES (:id, :name, :description, :status, :launch_date, :temenos_module,
                    :etb_capabilities, :informix_domains, :coexistence_mode,
                    :scope, :notes)
        """, p)
    con.commit()
    n_cnbv = sum(1 for p in INITIAL_PRODUCTS if p.get("scope") == "cnbv-scope")
    print(f"  products          : {len(INITIAL_PRODUCTS)} productos  |  alcance formal CNBV: {n_cnbv}")


def load_product_releases(con: sqlite3.Connection) -> None:
    """v1.1.0  --  tren de releases por producto, con procedencia por fila."""
    con.executemany(
        "INSERT OR REPLACE INTO product_releases "
        "(id, product_id, release_label, platform_release, scope, status, "
        " release_date, functionalities, channels, provenance) "
        "VALUES (?,?,?,?,?,?,?,?,?,?)",
        PRODUCT_RELEASES)
    con.commit()
    prod = sum(1 for r in PRODUCT_RELEASES if r[5] == "productivo")
    print(f"  product_releases  : {len(PRODUCT_RELEASES)} releases  |  en productivo: {prod}")


def load_components(con: sqlite3.Connection) -> None:
    for c in INITIAL_COMPONENTS:
        con.execute("""
            INSERT OR REPLACE INTO program_components
                (id, name, type, hus_total, provider, provider_status,
                 status, product_id, notes)
            VALUES (:id, :name, :type, :hus_total, :provider, :provider_status,
                    :status, :product_id, :notes)
        """, c)
    con.commit()
    print(f"  program_components: {len(INITIAL_COMPONENTS)} componentes")


def load_risks(con: sqlite3.Connection) -> None:
    for r in INITIAL_RISKS:
        con.execute("""
            INSERT OR REPLACE INTO risks
                (id, raid_id, description, component_id, category, impact, probability,
                 status, mitigation, due_date, owner, source, notes)
            VALUES (:id, :raid_id, :description, :component_id, :category, :impact, :probability,
                    :status, :mitigation, :due_date, :owner, :source, :notes)
        """, r)
    con.commit()
    high = sum(1 for r in INITIAL_RISKS if r["impact"] == "high" and r["status"] != "closed")
    closed = sum(1 for r in INITIAL_RISKS if r["status"] == "closed")
    print(f"  risks             : {len(INITIAL_RISKS)} ({high} high, {closed} closed)")


def load_assumptions(con: sqlite3.Connection) -> None:
    for a in INITIAL_ASSUMPTIONS:
        con.execute("""
            INSERT OR REPLACE INTO raid_assumptions
                (id, raid_id, description, component_id, relevance,
                 status, validator, validation_date, source, notes)
            VALUES (:id, :raid_id, :description, :component_id, :relevance,
                    :status, :validator, :validation_date, :source, :notes)
        """, a)
    con.commit()
    pending = sum(1 for a in INITIAL_ASSUMPTIONS if a["status"] == "pending")
    print(f"  raid_assumptions  : {len(INITIAL_ASSUMPTIONS)} ({pending} sin validar)")


def load_issues(con: sqlite3.Connection) -> None:
    for i in INITIAL_ISSUES:
        con.execute("""
            INSERT OR REPLACE INTO raid_issues
                (id, raid_id, description, component_id, category, severity,
                 current_impact, remediation, status, owner, due_date, source, notes,
                 tracks, breach)
            VALUES (:id, :raid_id, :description, :component_id, :category, :severity,
                    :current_impact, :remediation, :status, :owner, :due_date, :source, :notes,
                    :tracks, :breach)
        """, i)
    con.commit()
    print(f"  raid_issues       : {len(INITIAL_ISSUES)} (todos alta severidad)")


def load_dependencies(con: sqlite3.Connection) -> None:
    for d in INITIAL_DEPENDENCIES:
        con.execute("""
            INSERT OR REPLACE INTO raid_dependencies
                (id, raid_id, description, successor, predecessor,
                 severity, status, due_date, source, notes)
            VALUES (:id, :raid_id, :description, :successor, :predecessor,
                    :severity, :status, :due_date, :source, :notes)
        """, d)
    con.commit()
    print(f"  raid_dependencies : {len(INITIAL_DEPENDENCIES)} (ambas severas)")


def load_milestones(con: sqlite3.Connection) -> None:
    for m in INITIAL_MILESTONES:
        con.execute("""
            INSERT OR REPLACE INTO milestones
                (id, name, target_date, status, component_id, notes)
            VALUES (:id, :name, :target_date, :status, :component_id, :notes)
        """, m)
    con.commit()
    print(f"  milestones        : {len(INITIAL_MILESTONES)} hitos")


def load_vocabulary(con: sqlite3.Connection) -> None:
    con.executemany("""
        INSERT OR REPLACE INTO vocabulary (term, definition, category, source)
        VALUES (?, ?, ?, ?)
    """, INITIAL_VOCABULARY)
    con.commit()
    print(f"  vocabulary        : {len(INITIAL_VOCABULARY)} terminos")


def load_decisions(con: sqlite3.Connection) -> None:
    for d in INITIAL_DECISIONS:
        con.execute("""
            INSERT OR REPLACE INTO decisions
                (id, title, status, context, decision, consequences, date)
            VALUES (:id, :title, :status, :context, :decision, :consequences, :date)
        """, d)
    con.commit()
    print(f"  decisions (ADRs)  : {len(INITIAL_DECISIONS)} registros")


def load_capabilities(con: sqlite3.Connection) -> None:
    for c in PROGRAM_CAPABILITIES:
        con.execute("""
            INSERT OR REPLACE INTO program_capabilities
                (id, name, domain, bian_domain, description, mandatory_r4,
                 coverage_status, gap_type, gap_description, blocker_id,
                 confidence, component_ids, lifecycle_stage, notes)
            VALUES (:id, :name, :domain, :bian_domain, :description, :mandatory_r4,
                    :coverage_status, :gap_type, :gap_description, :blocker_id,
                    :confidence, :component_ids, :lifecycle_stage, :notes)
        """, c)
    con.commit()
    by_status = {}
    for c in PROGRAM_CAPABILITIES:
        s = c["coverage_status"]
        by_status[s] = by_status.get(s, 0) + 1
    blocked = sum(1 for c in PROGRAM_CAPABILITIES if c["blocker_id"])
    print(f"  program_capabilities: {len(PROGRAM_CAPABILITIES)} capabilities"
          f" (not_covered={by_status.get('not_covered',0)}"
          f" tbd={by_status.get('tbd',0)}"
          f" partial={by_status.get('partial',0)}"
          f" configurable={by_status.get('configurable',0)}"
          f" bloqueadas={blocked})")


def load_hdus(con: sqlite3.Connection) -> None:
    for h in HDU_CATALOG:
        con.execute("""
            INSERT OR REPLACE INTO hdu_catalog
                (id, canal, funcionalidad_macro, narrativa_corta, pregame_status, dtm_id, notes)
            VALUES (:id, :canal, :funcionalidad_macro, :narrativa_corta, :pregame_status, :dtm_id, :notes)
        """, h)
    con.commit()
    # aplicar mapeo capability_id
    for hdu_id, cap_id in HDU_CAPABILITY_MAP.items():
        con.execute("UPDATE hdu_catalog SET capability_id=? WHERE id=?", (cap_id, hdu_id))
    con.commit()
    by_status = {}
    for h in HDU_CATALOG:
        s = h["pregame_status"]
        by_status[s] = by_status.get(s, 0) + 1
    print(f"  hdu_catalog       : {len(HDU_CATALOG)} User Stories"
          f" (nativo={by_status.get('native',0)}"
          f" configurable={by_status.get('configurable',0)}"
          f" parcial={by_status.get('partial',0)}"
          f" no-cubierto={by_status.get('not_covered',0)}"
          f" tbd={by_status.get('tbd',0)})")


def load_dtms(con: sqlite3.Connection) -> None:
    for d in DTM_CATALOG:
        con.execute("""
            INSERT OR REPLACE INTO dtm_catalog
                (id, funcionalidad_macro, hdus_asociadas, funcion, status, gap_description, canal, notes)
            VALUES (:id, :funcionalidad_macro, :hdus_asociadas, :funcion, :status, :gap_description, :canal, :notes)
        """, d)
    con.commit()
    # aplicar mapeo capability_id
    for dtm_id, cap_id in DTM_CAPABILITY_MAP.items():
        con.execute("UPDATE dtm_catalog SET capability_id=? WHERE id=?", (cap_id, dtm_id))
    con.commit()
    gaps = sum(1 for d in DTM_CATALOG if d["status"] in ("not_covered", "tbd"))
    print(f"  dtm_catalog       : {len(DTM_CATALOG)} DTMs ({gaps} con gap critico)")


def load_apolo_hdus(con: sqlite3.Connection) -> None:
    for h in APOLO_HDU_CATALOG:
        con.execute("""
            INSERT OR REPLACE INTO apolo_hdu_catalog
                (id, descripcion, building_blocks, epica, mvp_scope, status, capability_id, criterios_count, notes)
            VALUES (:id, :descripcion, :building_blocks, :epica, :mvp_scope, :status, :capability_id, :criterios_count, :notes)
        """, h)
    con.commit()
    mvp1 = sum(1 for h in APOLO_HDU_CATALOG if h["mvp_scope"] == "mvp1")
    mvp2 = sum(1 for h in APOLO_HDU_CATALOG if h["mvp_scope"] == "mvp2")
    tag  = sum(1 for h in APOLO_HDU_CATALOG if h["mvp_scope"] == "taggeo")
    des  = sum(1 for h in APOLO_HDU_CATALOG if h["mvp_scope"] == "desestimada")
    print(f"  apolo_hdu_catalog : {len(APOLO_HDU_CATALOG)} User Stories (mvp1={mvp1} mvp2={mvp2} taggeo={tag} desestimada={des})")


def rebuild_fts(con: sqlite3.Connection) -> None:
    for tbl in ("products_fts", "program_capabilities_fts", "components_fts", "risks_fts",
                "issues_fts", "hdu_fts", "dtm_fts", "program_stakeholders_fts",
                "functional_duplicity_fts"):
        try:
            con.execute(f"INSERT INTO {tbl}({tbl}) VALUES('rebuild')")
        except Exception:
            pass
    con.commit()


def coverage_summary(con: sqlite3.Connection) -> None:
    live      = con.execute("SELECT COUNT(*) FROM products WHERE status='live'").fetchone()[0]
    building  = con.execute("SELECT COUNT(*) FROM products WHERE status='building'").fetchone()[0]
    comp_tot  = con.execute("SELECT COUNT(*) FROM program_components").fetchone()[0]
    at_risk_c = con.execute("SELECT COUNT(*) FROM program_components WHERE status='at_risk'").fetchone()[0]
    blocked_c = con.execute("SELECT COUNT(*) FROM program_components WHERE status='blocked'").fetchone()[0]
    r_open    = con.execute("SELECT COUNT(*) FROM risks WHERE status='open'").fetchone()[0]
    r_high    = con.execute("SELECT COUNT(*) FROM risks WHERE status='open' AND impact='high'").fetchone()[0]
    r_closed  = con.execute("SELECT COUNT(*) FROM risks WHERE status='closed'").fetchone()[0]
    a_pending = con.execute("SELECT COUNT(*) FROM raid_assumptions WHERE status='pending'").fetchone()[0]
    i_open    = con.execute("SELECT COUNT(*) FROM raid_issues WHERE status='open'").fetchone()[0]
    d_active  = con.execute("SELECT COUNT(*) FROM raid_dependencies WHERE status='active'").fetchone()[0]
    ms_tot    = con.execute("SELECT COUNT(*) FROM milestones").fetchone()[0]
    vocab_tot = con.execute("SELECT COUNT(*) FROM vocabulary").fetchone()[0]
    adrs      = con.execute("SELECT COUNT(*) FROM decisions").fetchone()[0]
    hdu_tot   = con.execute("SELECT COUNT(*) FROM hdu_catalog").fetchone()[0]
    hdu_gap   = con.execute("SELECT COUNT(*) FROM hdu_catalog WHERE pregame_status='not_covered'").fetchone()[0]
    hdu_tbd   = con.execute("SELECT COUNT(*) FROM hdu_catalog WHERE pregame_status='tbd'").fetchone()[0]
    dtm_tot   = con.execute("SELECT COUNT(*) FROM dtm_catalog").fetchone()[0]
    dtm_gap   = con.execute("SELECT COUNT(*) FROM dtm_catalog WHERE status IN ('not_covered','tbd')").fetchone()[0]
    cap_tot   = con.execute("SELECT COUNT(*) FROM program_capabilities").fetchone()[0]
    cap_nc    = con.execute("SELECT COUNT(*) FROM program_capabilities WHERE coverage_status='not_covered'").fetchone()[0]
    cap_tbd   = con.execute("SELECT COUNT(*) FROM program_capabilities WHERE coverage_status='tbd'").fetchone()[0]
    cap_blk   = con.execute("SELECT COUNT(*) FROM program_capabilities WHERE blocker_id IS NOT NULL").fetchone()[0]
    cap_ok    = con.execute(
        "SELECT COUNT(*) FROM program_capabilities WHERE coverage_status IN ('native','configurable')"
    ).fetchone()[0]

    print("\n  Unity Brain v1.2.0  --  resumen:")
    print(f"    Productos live (R1-R3+Rx) : {live}")
    print(f"    En construccion (R4)      : {building}")
    print(f"    Componentes R4            : {comp_tot} ({at_risk_c} en riesgo, {blocked_c} bloqueados)")
    print(f"    Capabilities de negocio   : {cap_tot} total  |  {cap_ok} full-coverage  |  {cap_nc} no-cubierto  |  {cap_tbd} tbd  |  {cap_blk} bloqueadas")
    print(f"    User Stories SmartVista/Canales   : {hdu_tot} ({hdu_gap} no cubiertos, {hdu_tbd} por determinar)")
    print(f"    DTMs catalogados          : {dtm_tot} ({dtm_gap} con gap critico)")
    print(f"    Risks RAID (abiertos)     : {r_open} ({r_high} alta, {r_closed} cerrados)")
    print(f"    Assumptions (sin val.)    : {a_pending}")
    print(f"    Issues (abiertos)         : {i_open}")
    print(f"    Dependencies (activas)    : {d_active}")
    print(f"    Hitos de cronograma       : {ms_tot}")
    print(f"    Vocabulario               : {vocab_tot} terminos")
    print(f"    ADRs                      : {adrs}")


# â"€â"€ Datos semÃ¡nticos v0.6.1 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
# Fuente: dt-vendors, dt-slo-observabilidad, dt-sit-uat, dt-compliance,
#         dt-ops-readiness, dt-coexistencia

CAPABILITY_VENDORS = [
    # CAP-CARD-MANUFACTURING: SmartVista (BPC) primary, maquiladores support
    {"id": "CV-MANUF-BPC",  "capability_id": "CAP-CARD-MANUFACTURING",  "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": json.dumps(["#13830642","#13830651"]), "risk_note": "OCG/Connect Direct manuales en R4"},
    {"id": "CV-MANUF-GID",  "capability_id": "CAP-CARD-MANUFACTURING",  "vendor_id": "gid",     "vendor_name": "GID (Giesecke & Devrient)", "role": "support",    "contract_status": "tbd",        "open_tickets": None, "risk_note": "Certificacion layout R4 pendiente"},
    {"id": "CV-MANUF-FRZ",  "capability_id": "CAP-CARD-MANUFACTURING",  "vendor_id": "forza",   "vendor_name": "Forza",                    "role": "support",    "contract_status": "tbd",        "open_tickets": None, "risk_note": "Certificacion layout R4 pendiente"},
    {"id": "CV-MANUF-TGS",  "capability_id": "CAP-CARD-MANUFACTURING",  "vendor_id": "tgs",     "vendor_name": "TGS (Thomas Greg & Sons)", "role": "support",    "contract_status": "tbd",        "open_tickets": None, "risk_note": "Certificacion layout R4 pendiente"},
    # CAP-AUTHORIZATION
    {"id": "CV-AUTH-BPC",   "capability_id": "CAP-AUTHORIZATION",        "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": json.dumps(["BYU0039"]), "risk_note": "PayTrue (fraud) no es BPC  --  es externo"},
    {"id": "CV-AUTH-AWH",   "capability_id": "CAP-AUTHORIZATION",        "vendor_id": "appwhere","vendor_name": "Appwhere",                  "role": "support",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    # CAP-CARD-LIFECYCLE
    {"id": "CV-LIFE-BPC",   "capability_id": "CAP-CARD-LIFECYCLE",       "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    {"id": "CV-LIFE-AWH",   "capability_id": "CAP-CARD-LIFECYCLE",       "vendor_id": "appwhere","vendor_name": "Appwhere",                  "role": "support",    "contract_status": "contracted", "open_tickets": None, "risk_note": "6 User Stories Must Have App cierran noviembre"},
    # CAP-OVERPAYMENT
    {"id": "CV-OVP-BPC",    "capability_id": "CAP-OVERPAYMENT",          "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": json.dumps(["BYU0039"]), "risk_note": "BYU0039 abierto  --  bloquea SIT"},
    # CAP-DEFERRED-PURCHASE
    {"id": "CV-DPP-BPC",    "capability_id": "CAP-DEFERRED-PURCHASE",    "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "pending",    "open_tickets": json.dumps(["DPP-GAP"]), "risk_note": "MÃ³dulo DPP no contratado  --  decision urgente"},
    # CAP-BALANCE-STATEMENT
    {"id": "CV-BAL-BPC",    "capability_id": "CAP-BALANCE-STATEMENT",    "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    {"id": "CV-BAL-AWH",    "capability_id": "CAP-BALANCE-STATEMENT",    "vendor_id": "appwhere","vendor_name": "Appwhere",                  "role": "support",    "contract_status": "contracted", "open_tickets": None, "risk_note": "Latencia APOLO 9s PROD  --  fuera de SLO"},
    # CAP-PAYMENT
    {"id": "CV-PAY-BPC",    "capability_id": "CAP-PAYMENT",              "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    {"id": "CV-PAY-AWH",    "capability_id": "CAP-PAYMENT",              "vendor_id": "appwhere","vendor_name": "Appwhere",                  "role": "support",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    # CAP-CUSTOMER-PROFILE
    {"id": "CV-CUST-AWH",   "capability_id": "CAP-CUSTOMER-PROFILE",     "vendor_id": "appwhere","vendor_name": "Appwhere",                  "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": "ICCAT integration con CAT aun sin proveedor"},
    # CAP-CHANNEL-SELFSERVICE
    {"id": "CV-CHAN-CAT",   "capability_id": "CAP-CHANNEL-SELFSERVICE",  "vendor_id": "cat_tbd", "vendor_name": "Proveedor CAT [SIN CONTRATAR]", "role": "primary", "contract_status": "pending",   "open_tickets": json.dumps(["RISK-UNITY-R27"]), "risk_note": "CRITICO: deadline contratacion 31-ago-2026"},
    # CAP-AUTHENTICATION
    {"id": "CV-AUTHN-CAT",  "capability_id": "CAP-AUTHENTICATION",       "vendor_id": "cat_tbd", "vendor_name": "Proveedor CAT [SIN CONTRATAR]", "role": "primary", "contract_status": "pending",   "open_tickets": json.dumps(["RISK-UNITY-R27"]), "risk_note": "Flujos IVR/OTP dependen del proveedor CAT"},
    # CAP-COLLECTIONS-AGING
    {"id": "CV-COL-INT",    "capability_id": "CAP-COLLECTIONS-AGING",    "vendor_id": "interno", "vendor_name": "BanCoppel Interno (Cobranza Direccionada)", "role": "primary", "contract_status": "contracted", "open_tickets": None, "risk_note": "Pentest conflicto nov 15-20"},
    {"id": "CV-COL-BPC",    "capability_id": "CAP-COLLECTIONS-AGING",    "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "support",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
    # CAP-FEE-COMMISSION
    {"id": "CV-FEE-BPC",    "capability_id": "CAP-FEE-COMMISSION",       "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": "Solo parametrizacion  --  no desarrollo"},
    # CAP-ACCOUNTING-INTEGRATION
    {"id": "CV-ACC-ACN",    "capability_id": "CAP-ACCOUNTING-INTEGRATION","vendor_id": "acn",    "vendor_name": "Accenture (Apificacion)",   "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": "Guia contable pendiente de entrega BanCoppel"},
    # CAP-ERROR-CATALOG
    {"id": "CV-ERR-BPC",    "capability_id": "CAP-ERROR-CATALOG",        "vendor_id": "bpc",     "vendor_name": "BPC Banking Technologies", "role": "primary",    "contract_status": "contracted", "open_tickets": None, "risk_note": None},
]

# SLOs por capability  --  fuente: dt-slo-observabilidad
# Nota: muchos valores son DATO-REQUERIDO en esta version del brain
CAPABILITY_SLOS = [
    {"id": "SLO-MANUF",  "capability_id": "CAP-CARD-MANUFACTURING",   "slo_availability_pct": 99.5,  "slo_latency_p95_ms": None,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.5,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "pending", "notes": "OCG/Connect Direct batch  --  no transaccional"},
    {"id": "SLO-AUTH",   "capability_id": "CAP-AUTHORIZATION",         "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 800,   "slo_latency_p99_ms": 2000,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": "SLO critico  --  autorizacion en tiempo real"},
    {"id": "SLO-LIFE",   "capability_id": "CAP-CARD-LIFECYCLE",        "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 3000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.5,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "pending", "notes": None},
    {"id": "SLO-OVP",    "capability_id": "CAP-OVERPAYMENT",           "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 800,   "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "blocked", "notes": "Bloqueado por BYU0039"},
    {"id": "SLO-DPP",    "capability_id": "CAP-DEFERRED-PURCHASE",     "slo_availability_pct": None,  "slo_latency_p95_ms": None,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": None, "slo_tps_min": None, "measurement_window": None,           "status": "blocked", "notes": "No en scope R4  --  DPP no contratado"},
    {"id": "SLO-BAL",    "capability_id": "CAP-BALANCE-STATEMENT",     "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 3000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": "APOLO latencia hoy 9s  --  requiere mejora pre-SIT"},
    {"id": "SLO-PAY",    "capability_id": "CAP-PAYMENT",               "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 3000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": None},
    {"id": "SLO-CUST",   "capability_id": "CAP-CUSTOMER-PROFILE",      "slo_availability_pct": 99.5,  "slo_latency_p95_ms": 3000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.5,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": None},
    {"id": "SLO-CHAN",   "capability_id": "CAP-CHANNEL-SELFSERVICE",   "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 3000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "blocked", "notes": "Bloqueado hasta contratar proveedor CAT"},
    {"id": "SLO-AUTHN",  "capability_id": "CAP-AUTHENTICATION",        "slo_availability_pct": 99.9,  "slo_latency_p95_ms": None,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "blocked", "notes": "Bloqueado hasta contratar proveedor CAT"},
    {"id": "SLO-COL",    "capability_id": "CAP-COLLECTIONS-AGING",     "slo_availability_pct": 99.5,  "slo_latency_p95_ms": 5000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.5,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "pending", "notes": None},
    {"id": "SLO-FEE",    "capability_id": "CAP-FEE-COMMISSION",        "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 800,   "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": "Configuracion parametrica  --  no transaccional"},
    {"id": "SLO-ACC",    "capability_id": "CAP-ACCOUNTING-INTEGRATION","slo_availability_pct": 99.9,  "slo_latency_p95_ms": 5000,  "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "mensual",      "status": "pending", "notes": "Guia contable pendiente"},
    {"id": "SLO-ERR",    "capability_id": "CAP-ERROR-CATALOG",         "slo_availability_pct": 99.9,  "slo_latency_p95_ms": 500,   "slo_latency_p99_ms": None,  "slo_error_rate_pct": 0.1,  "slo_tps_min": None, "measurement_window": "5min",         "status": "pending", "notes": "Catalogo read-only  --  alta disponibilidad"},
]

# Plan SIT/UAT por capability  --  fuente: dt-sit-uat
CAPABILITY_TEST_PLAN = [
    {"id": "TP-MANUF",  "capability_id": "CAP-CARD-MANUFACTURING",   "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+e2e", "notes": "Flujo manual en R4  --  automatico post-R4"},
    {"id": "TP-AUTH",   "capability_id": "CAP-AUTHORIZATION",         "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+performance", "notes": "88 reglas BPC a validar"},
    {"id": "TP-LIFE",   "capability_id": "CAP-CARD-LIFECYCLE",        "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+uat", "notes": None},
    {"id": "TP-OVP",    "capability_id": "CAP-OVERPAYMENT",           "sit_included": 1, "sit_status": "blocked",         "sit_blocker": "BYU0039",      "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration",     "notes": "BYU0039 debe cerrarse antes del inicio SIT"},
    {"id": "TP-DPP",    "capability_id": "CAP-DEFERRED-PURCHASE",     "sit_included": 0, "sit_status": "not_applicable",  "sit_blocker": "DPP-GAP",      "uat_included": 0, "uat_signer": None, "test_cases_planned": 0,    "test_type": None,              "notes": "Fuera de scope R4  --  DPP no contratado"},
    {"id": "TP-BAL",    "capability_id": "CAP-BALANCE-STATEMENT",     "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+uat", "notes": "IVR/CAT parcialmente bloqueado"},
    {"id": "TP-PAY",    "capability_id": "CAP-PAYMENT",               "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+uat", "notes": None},
    {"id": "TP-CUST",   "capability_id": "CAP-CUSTOMER-PROFILE",      "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration",     "notes": "ICCAT parcialmente bloqueado por CAT sin contratar"},
    {"id": "TP-CHAN",   "capability_id": "CAP-CHANNEL-SELFSERVICE",   "sit_included": 1, "sit_status": "blocked",         "sit_blocker": "RISK-UNITY-R27", "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+uat", "notes": "Bloqueado hasta contratar proveedor CAT"},
    {"id": "TP-AUTHN",  "capability_id": "CAP-AUTHENTICATION",        "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+security", "notes": "OTP/ANI  --  parcialmente bloqueado por CAT"},
    {"id": "TP-COL",    "capability_id": "CAP-COLLECTIONS-AGING",     "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration+pentest", "notes": "Pentest Cobranza 15-20 nov  --  conflicto con SIT activo"},
    {"id": "TP-FEE",    "capability_id": "CAP-FEE-COMMISSION",        "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration",     "notes": None},
    {"id": "TP-ACC",    "capability_id": "CAP-ACCOUNTING-INTEGRATION","sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration",     "notes": "Guia contable pendiente  --  puede bloquear SIT"},
    {"id": "TP-ERR",    "capability_id": "CAP-ERROR-CATALOG",         "sit_included": 1, "sit_status": "planned",         "sit_blocker": None,           "uat_included": 1, "uat_signer": None, "test_cases_planned": None, "test_type": "integration",     "notes": None},
]

# Compliance por capability  --  fuente: dt-compliance
CAPABILITY_COMPLIANCE = [
    {"id": "CC-MANUF",  "capability_id": "CAP-CARD-MANUFACTURING",   "cnbv_art76": 1, "pci_dss_scope": 1, "condusef_scope": 0, "regulation_note": "Maquila de tarjetas en scope PCI-DSS (datos de embosado + PGP+HSM)", "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-AUTH",   "capability_id": "CAP-AUTHORIZATION",         "cnbv_art76": 1, "pci_dss_scope": 1, "condusef_scope": 0, "regulation_note": "Autorizacion en tiempo real  --  core del scope PCI-DSS; requiere TLS 1.2+",     "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-LIFE",   "capability_id": "CAP-CARD-LIFECYCLE",        "cnbv_art76": 1, "pci_dss_scope": 1, "condusef_scope": 1, "regulation_note": "Cancelacion de tarjeta  --  CONDUSEF requiere proceso de aclaracion documentado",  "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-OVP",    "capability_id": "CAP-OVERPAYMENT",           "cnbv_art76": 0, "pci_dss_scope": 0, "condusef_scope": 1, "regulation_note": "Saldo a favor  --  CONDUSEF: reglas de devoluciÃ³n de saldo a favor TDC",         "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-DPP",    "capability_id": "CAP-DEFERRED-PURCHASE",     "cnbv_art76": 0, "pci_dss_scope": 0, "condusef_scope": 1, "regulation_note": "MSI/MCI  --  CONDUSEF: tabla de mensualidades en estado de cuenta",              "deadline": None,         "status": "not_applicable"},
    {"id": "CC-BAL",    "capability_id": "CAP-BALANCE-STATEMENT",     "cnbv_art76": 0, "pci_dss_scope": 1, "condusef_scope": 1, "regulation_note": "Estado de cuenta  --  CONDUSEF: formato regulatorio obligatorio",               "deadline": "2027-02-15", "status": "pending"},
    {"id": "CC-PAY",    "capability_id": "CAP-PAYMENT",               "cnbv_art76": 0, "pci_dss_scope": 1, "condusef_scope": 1, "regulation_note": "Pagos TDC  --  CONDUSEF: acuse de pago obligatorio; PCI datos en trÃ¡nsito",      "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-CUST",   "capability_id": "CAP-CUSTOMER-PROFILE",      "cnbv_art76": 0, "pci_dss_scope": 1, "condusef_scope": 1, "regulation_note": "Perfil cliente  --  PCI: PANs en scope; CONDUSEF: datos del contrato",           "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-CHAN",   "capability_id": "CAP-CHANNEL-SELFSERVICE",   "cnbv_art76": 1, "pci_dss_scope": 1, "condusef_scope": 0, "regulation_note": "IVR/CAT  --  PCI: si captura PAN en IVR, en scope PCI-DSS",                    "deadline": "2027-01-15", "status": "blocked"},
    {"id": "CC-AUTHN",  "capability_id": "CAP-AUTHENTICATION",        "cnbv_art76": 0, "pci_dss_scope": 1, "condusef_scope": 0, "regulation_note": "OTP/ANI  --  PCI control 8.6: MFA para acceso a datos de tarjeta",               "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-COL",    "capability_id": "CAP-COLLECTIONS-AGING",     "cnbv_art76": 0, "pci_dss_scope": 0, "condusef_scope": 1, "regulation_note": "Cobranza  --  CONDUSEF: restricciones en prÃ¡cticas de cobranza",               "deadline": "2027-01-15", "status": "pending"},
    {"id": "CC-FEE",    "capability_id": "CAP-FEE-COMMISSION",        "cnbv_art76": 0, "pci_dss_scope": 0, "condusef_scope": 1, "regulation_note": "Comisiones  --  CONDUSEF: tabla de comisiones registrada en RECA",              "deadline": "2026-12-15", "status": "pending"},
    {"id": "CC-ACC",    "capability_id": "CAP-ACCOUNTING-INTEGRATION","cnbv_art76": 1, "pci_dss_scope": 0, "condusef_scope": 0, "regulation_note": "Contabilidad  --  CNBV: reporterÃ­a regulatoria desde SmartVista desde mes 1",   "deadline": "2027-02-15", "status": "pending"},
    {"id": "CC-ERR",    "capability_id": "CAP-ERROR-CATALOG",         "cnbv_art76": 0, "pci_dss_scope": 0, "condusef_scope": 1, "regulation_note": "Mensajes de error  --  homologados con catÃ¡logo BANXICO",                       "deadline": "2027-01-15", "status": "pending"},
]

# PRR (Production Readiness Review) por capability  --  fuente: dt-ops-readiness
# Estado inicial: todo pendiente (PRR no iniciado al 2026-08-16)
CAPABILITY_PRR = [
    {"id": "PRR-MANUF",  "capability_id": "CAP-CARD-MANUFACTURING",   "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-AUTH",   "capability_id": "CAP-AUTHORIZATION",         "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-LIFE",   "capability_id": "CAP-CARD-LIFECYCLE",        "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-OVP",    "capability_id": "CAP-OVERPAYMENT",           "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": "BYU0039 abierto"},
    {"id": "PRR-DPP",    "capability_id": "CAP-DEFERRED-PURCHASE",     "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": "No en scope R4"},
    {"id": "PRR-BAL",    "capability_id": "CAP-BALANCE-STATEMENT",     "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-PAY",    "capability_id": "CAP-PAYMENT",               "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-CUST",   "capability_id": "CAP-CUSTOMER-PROFILE",      "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-CHAN",   "capability_id": "CAP-CHANNEL-SELFSERVICE",   "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": "CAT sin contratar"},
    {"id": "PRR-AUTHN",  "capability_id": "CAP-AUTHENTICATION",        "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": "CAT sin contratar"},
    {"id": "PRR-COL",    "capability_id": "CAP-COLLECTIONS-AGING",     "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-FEE",    "capability_id": "CAP-FEE-COMMISSION",        "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
    {"id": "PRR-ACC",    "capability_id": "CAP-ACCOUNTING-INTEGRATION","runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": "Guia contable pendiente"},
    {"id": "PRR-ERR",    "capability_id": "CAP-ERROR-CATALOG",         "runbook_done": 0, "oncall_assigned": 0, "slo_configured": 0, "rollback_tested": 0, "drp_covered": 0, "prr_approved": 0, "prr_blocker": None},
]

# User Stories de APOLO  --  37 historias (fuente: APOLO_R4_HDU_TDC.xlsm Â· 2026-08-05)
# mvp_scope: mvp1=en scope ene-2027 Â· mvp2=fuera de alcance Â· taggeo=solo mediciÃ³n digital Â· desestimada
APOLO_HDU_CATALOG = [
    # â"€â"€ MVP1  --  VoBo â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id":"HDU-TDC-R4-01","descripcion":"Actualizar la tasa ordinaria (69.4%) y el CAT en la oferta de producto","building_blocks":"Oferta de Producto","epica":"Cambio de tasas y contrato en APOLO","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-BALANCE-STATEMENT","criterios_count":4,"notes":"Tasa parametrizable en BD; CAT calculado proporcionalmente"},
    {"id":"HDU-TDC-R4-03","descripcion":"Enviar por correo el contrato vigente al finalizar la firma","building_blocks":"Bienvenida,Correo contractual","epica":"Cambio de tasas y contrato en APOLO","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CARD-LIFECYCLE","criterios_count":4,"notes":"Welcome Kit: contrato+tabla comisiones+carÃ¡tula+portada+contrato servicios digitales; RECA 1654-999-037863/09-01070-0526"},
    {"id":"HDU-TDC-R4-04","descripcion":"Aplicar Coltrane en bloques iniciales y validaciÃ³n temprana (BB1-BB4)","building_blocks":"PreparaciÃ³n,TyC,ValidaciÃ³n de TelÃ©fono,ValidaciÃ³n del Cliente","epica":"Cambio de marca Fase 2","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Coltrane = design system BanCoppel; solo cambio visual, sin modificar lÃ³gica"},
    {"id":"HDU-TDC-R4-05","descripcion":"Aplicar Coltrane en bloques perfilamiento, riesgo y decisiÃ³n (BB5-BB11)","building_blocks":"Perfilamiento,ValidaciÃ³n de Domicilio,KYC-PEP,PLD,Persona Vulnerable,ValidaciÃ³n SIC,ParamÃ©trico","epica":"Cambio de marca Fase 2","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-06","descripcion":"Aplicar Coltrane en oferta, autenticaciÃ³n, expediente y cierre (BB12-BB17)","building_blocks":"Oferta de Producto,Prueba de Vida,Servicios Digitales,ValidaciÃ³n de Correo,Expediente Digital,Bienvenida","epica":"Cambio de marca Fase 2","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-07","descripcion":"Capturar la declaraciÃ³n inicial de persona vulnerable","building_blocks":"Persona Vulnerable","epica":"Incluir Persona Vulnerable","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"BB9; CNBV  --  grupos prioritarios"},
    {"id":"HDU-TDC-R4-08","descripcion":"Desplegar y guardar opciones de grupo prioritario cuando el prospecto responde SÃ­","building_blocks":"Persona Vulnerable","epica":"Incluir Persona Vulnerable","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-10","descripcion":"Actualizar imagen de tarjeta y textos legales en pantallas clave","building_blocks":"Inicio,Oferta de Producto,Bienvenida","epica":"ActualizaciÃ³n visual","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"BIN 4268 0711 Visa  --  imagen tarjeta nueva TDC Digital"},
    {"id":"HDU-TDC-R4-13","descripcion":"Validar al solicitante contra listas negras en Perfilamiento","building_blocks":"Perfilamiento,Name Matching","epica":"Listas negras","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"IntegraciÃ³n con servicio de Name Matching (existente)"},
    {"id":"HDU-TDC-R4-14","descripcion":"Validar al familiar con cargo pÃºblico contra listas negras","building_blocks":"KYC,PEP,Name Matching","epica":"Listas negras","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"PEP = Persona Expuesta PolÃ­ticamente"},
    {"id":"HDU-TDC-R4-16","descripcion":"Validar la referencia contra listas negras en ParamÃ©trico","building_blocks":"ParamÃ©trico,Referencia,Name Matching","epica":"Listas negras","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-17","descripcion":"Presentar la pantalla de tÃ©rminos con Contrato MÃºltiple y Servicios Digitales","building_blocks":"FormalizaciÃ³n y Firma,Solicitud de Servicios Digitales","epica":"Contrato servicios digitales","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"RECA 1654-999-037863/09-01070-0526"},
    {"id":"HDU-TDC-R4-18","descripcion":"Permitir lectura de documentos y avance a firma electrÃ³nica","building_blocks":"Lectura de Documentos,Firma ElectrÃ³nica","epica":"Contrato servicios digitales","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-19","descripcion":"Mostrar informaciÃ³n de activaciÃ³n de servicios digitales mediante popup","building_blocks":"Solicitud de Servicios Digitales,Popup informativo","epica":"Contrato servicios digitales","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-20","descripcion":"Integrar firma, alta de crÃ©dito, expediente digital y marcaje de visualizaciÃ³n","building_blocks":"Firma ElectrÃ³nica,SmartVista,OnBase,Expediente Digital","epica":"Contrato servicios digitales","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CARD-LIFECYCLE","criterios_count":4,"notes":"INTEGRACIÓN CRÃTICA: APOLO -> SmartVista (alta crÃ©dito) + APOLO -> OnBase (expediente); Sprint 10-12"},
    {"id":"HDU-TDC-R4-21","descripcion":"Aplicar KO automÃ¡tico cuando el prospecto usarÃ¡ dinero de otra persona","building_blocks":"PLD,Proveedor de Recursos,TYP Rechazo","epica":"Listas negras","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"KO = Knock Out; PLD compliance"},
    {"id":"HDU-TDC-R4-23","descripcion":"Validar formato del nÃºmero celular en preparaciÃ³n y validaciÃ³n de telÃ©fono","building_blocks":"PreparaciÃ³n,ValidaciÃ³n del Cliente,ValidaciÃ³n de TelÃ©fono","epica":"Reglas de telÃ©fono","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-AUTHENTICATION","criterios_count":5,"notes":"Sprint 1"},
    {"id":"HDU-TDC-R4-24","descripcion":"Validar titularidad del celular y disponibilidad por regla de 30 dÃ­as","building_blocks":"ValidaciÃ³n del Cliente,Titularidad TelÃ©fono","epica":"Reglas de telÃ©fono","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-AUTHENTICATION","criterios_count":4,"notes":"Sprint 1; regla negocio: 30 dÃ­as entre asignaciones del mismo nÃºmero"},
    {"id":"HDU-TDC-R4-25","descripcion":"Cancelar vÃ­nculo previo del nÃºmero cuando la originaciÃ³n concluye exitosamente","building_blocks":"ValidaciÃ³n del Cliente,ReasignaciÃ³n TelÃ©fono","epica":"Reglas de telÃ©fono","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-AUTHENTICATION","criterios_count":4,"notes":"Sprint 11; libera el nÃºmero para asignaciÃ³n futura"},
    {"id":"HDU-TDC-R4-26","descripcion":"Gestionar reglas del OTP para validaciÃ³n telefÃ³nica","building_blocks":"PreparaciÃ³n,ValidaciÃ³n del Cliente,OTP","epica":"Reglas de telÃ©fono","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-AUTHENTICATION","criterios_count":5,"notes":"Sprint 2; reglas: intentos, expiraciÃ³n, reenvÃ­o"},
    {"id":"HDU-TDC-R4-27","descripcion":"Asegurar mÃ¡scara de SMS BanCoppel en mensajes OTP","building_blocks":"SMS,OTP,ComunicaciÃ³n","epica":"Reglas de telÃ©fono","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-AUTHENTICATION","criterios_count":4,"notes":"Sprint 3; sender ID de BanCoppel en SMS"},
    {"id":"HDU-TDC-R4-34","descripcion":"Asignar sucursal corporativa parametrizable a la TDC BanCoppel","building_blocks":"SucursalizaciÃ³n,ParametrizaciÃ³n","epica":"SucursalizaciÃ³n","mvp_scope":"mvp1","status":"VoBo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Sprint 6; sucursal corporativa parametrizable en BD"},
    # â"€â"€ MVP1  --  Taggeo por Modyo â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id":"HDU-TDC-R4-09","descripcion":"Mostrar informaciÃ³n legal de persona vulnerable y medir eventos del bloque","building_blocks":"Persona Vulnerable,MediciÃ³n digital","epica":"Incluir Persona Vulnerable","mvp_scope":"taggeo","status":"Taggeo por Modyo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Depende de Modyo (CMS BanCoppel)"},
    {"id":"HDU-TDC-R4-22","descripcion":"Medir la Thank You Page de rechazo por proveedor de recursos","building_blocks":"PLD,MediciÃ³n digital,TYP Rechazo","epica":"MediciÃ³n digital","mvp_scope":"taggeo","status":"Taggeo por Modyo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Depende de Modyo"},
    {"id":"HDU-TDC-R4-37","descripcion":"Implementar mediciÃ³n digital faltante por grupos de Building Blocks APOLO","building_blocks":"MediciÃ³n digital,10 BBs","epica":"MediciÃ³n digital","mvp_scope":"taggeo","status":"Taggeo por Modyo","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":5,"notes":"Depende de Modyo; 10 BBs con taggeo faltante"},
    # â"€â"€ MVP2  --  Fuera de alcance enero 2027 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id":"HDU-TDC-R4-02","descripcion":"Mostrar el contrato legal vigente durante la formalizaciÃ³n","building_blocks":"FormalizaciÃ³n y Firma,TÃ©rminos y Condiciones","epica":"Cambio de tasas y contrato","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-12","descripcion":"Guardar la referencia capturada sin convertirla en cliente prospecto","building_blocks":"Referencia,Persistencia de datos","epica":"Observaciones legal","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-28","descripcion":"Iniciar recuperaciÃ³n de solicitud mediante captura de telÃ©fono y envÃ­o de OTP","building_blocks":"RecuperaciÃ³n de Solicitud,PreparaciÃ³n,OTP","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Retoma de solicitud abandonada"},
    {"id":"HDU-TDC-R4-29","descripcion":"Validar OTP de recuperaciÃ³n y controlar errores de captura","building_blocks":"RecuperaciÃ³n de Solicitud,OTP","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-30","descripcion":"Resolver retoma segÃºn vigencia del prospecto y Ãºltima etapa alcanzada","building_blocks":"RecuperaciÃ³n de Solicitud,Vigencia Prospecto","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Vigencia solicitud: 60 dÃ­as"},
    {"id":"HDU-TDC-R4-31","descripcion":"Gestionar solicitudes vigentes de otros canales y estatus CN","building_blocks":"RecuperaciÃ³n de Solicitud,Estatus CN,Solicitudes de otros canales","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-32","descripcion":"Gestionar retoma en estatus BC y CC con consultas crediticias","building_blocks":"RecuperaciÃ³n de Solicitud,ValidaciÃ³n SIC,BurÃ³,CÃ­rculo","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":5,"notes":None},
    {"id":"HDU-TDC-R4-33","descripcion":"Resolver retoma de estatus RT, CP, TC y AT segÃºn vigencias","building_blocks":"RecuperaciÃ³n de Solicitud,Estatus RT-CP-TC-AT","epica":"RecuperaciÃ³n de solicitud","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":5,"notes":None},
    {"id":"HDU-TDC-R4-35","descripcion":"Identificar clientes titulares, prospectos y nuevos en validaciÃ³n del cliente","building_blocks":"ValidaciÃ³n del Cliente","epica":"SucursalizaciÃ³n clientes","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"IntegraciÃ³n onboarding cliente prospecto tipo 02"},
    {"id":"HDU-TDC-R4-36","descripcion":"Actualizar registro de prospecto tipo 02 y aplicar alcance a onboarding","building_blocks":"ValidaciÃ³n de Domicilio,Prospecto tipo 02,RecuperaciÃ³n de Solicitud","epica":"Onboarding cliente prospecto","mvp_scope":"mvp2","status":"MVP2 (Fuera de alcance)","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":5,"notes":None},
    # â"€â"€ Desestimadas â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id":"HDU-TDC-R4-11","descripcion":"Reordenar documentos en IntegraciÃ³n de Expediente conforme a observaciones legales","building_blocks":"IntegraciÃ³n de Expediente Digital","epica":"Observaciones legal","mvp_scope":"desestimada","status":"Desestimada","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":None},
    {"id":"HDU-TDC-R4-15","descripcion":"Validar al proveedor de recursos contra listas negras en PLD","building_blocks":"PLD,Name Matching","epica":"Listas negras","mvp_scope":"desestimada","status":"Desestimada","capability_id":"CAP-CUSTOMER-PROFILE","criterios_count":4,"notes":"Desestimada  --  validaciÃ³n de proveedor de recursos no aplica"},
]

# Stakeholders por capability  --  fuente: dt-gobierno, dt-equipo, RAID, roster SMEs BanCoppel
# Tipos: acn_sme (SME ecosistema ACN) Â· program_architect (arquitecto del programa)
#        bancoppel_owner (responsable BanCoppel) Â· vendor_contact (contacto tÃ©cnico del vendor)
# RACI: responsible Â· accountable Â· consulted Â· informed
#
# SME paths apuntan a Delivery - SME/ del ecosistema Solutioning.
# Fuente roster: project-bancoppel-sme-roster.md (creados 2026-08-01, 7 SMEs en Delivery-SME/)

SME_BASE = "c:\\...\\Solutioning\\Delivery - SME\\"

CAPABILITY_STAKEHOLDERS = [
    # â"€â"€ CAP-CARD-MANUFACTURING â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-MANUF-SME1",  "capability_id": "CAP-CARD-MANUFACTURING",    "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "Card management, SmartVista lifecycle"},
    {"id": "STK-MANUF-SME2",  "capability_id": "CAP-CARD-MANUFACTURING",    "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "Observabilidad del proceso de maquila batch"},
    {"id": "STK-MANUF-ARCH1", "capability_id": "CAP-CARD-MANUFACTURING",    "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "responsible",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista  --  owner de los tickets #13830642/#13830651"},
    {"id": "STK-MANUF-ARCH2", "capability_id": "CAP-CARD-MANUFACTURING",    "name": "Alfredo Aguilar",               "stakeholder_type": "vendor_contact",     "raci_role": "responsible",  "organization": "Appwhere",    "sme_path": None, "contact_note": "Define fechas DTMs offline (gate 10/08)"},

    # â"€â"€ CAP-AUTHORIZATION â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-AUTH-SME1",   "capability_id": "CAP-AUTHORIZATION",          "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "88 reglas autorizador BPC  --  E-Global  ->  SmartVista"},
    {"id": "STK-AUTH-SME2",   "capability_id": "CAP-AUTHORIZATION",          "name": "Cybersecurity",                 "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Cybersecurity/",                 "contact_note": "PayTrue como motor de fraude  --  no SVFM"},
    {"id": "STK-AUTH-SME3",   "capability_id": "CAP-AUTHORIZATION",          "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "SLO latencia P95 â‰¤ 800ms  --  alerta en tiempo real"},
    {"id": "STK-AUTH-ARCH1",  "capability_id": "CAP-AUTHORIZATION",          "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista  --  owner del autorizador"},

    # â"€â"€ CAP-CARD-LIFECYCLE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-LIFE-SME1",   "capability_id": "CAP-CARD-LIFECYCLE",         "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "CSTS states, F/D classification, reposiciÃ³n"},
    {"id": "STK-LIFE-SME2",   "capability_id": "CAP-CARD-LIFECYCLE",         "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "Reglas de negocio de cancelaciÃ³n definitiva  --  CONDUSEF"},
    {"id": "STK-LIFE-ARCH1",  "capability_id": "CAP-CARD-LIFECYCLE",         "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista"},
    {"id": "STK-LIFE-ARCH2",  "capability_id": "CAP-CARD-LIFECYCLE",         "name": "Eduardo Guzman",                "stakeholder_type": "program_architect",  "raci_role": "responsible",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM App  --  6 User Stories Must Have app lifecycle"},

    # â"€â"€ CAP-OVERPAYMENT â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-OVP-SME1",    "capability_id": "CAP-OVERPAYMENT",            "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "BYU0039  --  lÃ­mite saldo a favor; dictar workaround si no cierra"},
    {"id": "STK-OVP-SME2",    "capability_id": "CAP-OVERPAYMENT",            "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "Reglas de negocio: rechazo completo sin poliza parcial"},
    {"id": "STK-OVP-ARCH1",   "capability_id": "CAP-OVERPAYMENT",            "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista  --  escalar BYU0039 a account manager BPC"},

    # â"€â"€ CAP-DEFERRED-PURCHASE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-DPP-SME1",    "capability_id": "CAP-DEFERRED-PURCHASE",      "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "DPP no contratado  --  asesorar alternativa o contratar mÃ³dulo"},
    {"id": "STK-DPP-SME2",    "capability_id": "CAP-DEFERRED-PURCHASE",      "name": "Industry Banking Accounting",   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking Accounting/",  "contact_note": "TRNT 623, Grupo contable 13 MCI  --  contabilizaciÃ³n diferidos"},
    {"id": "STK-DPP-BCO",     "capability_id": "CAP-DEFERRED-PURCHASE",      "name": "PMO BanCoppel",                 "stakeholder_type": "bancoppel_owner",    "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "DecisiÃ³n de contratar DPP o desarrollar alternativa  --  urgente"},

    # â"€â"€ CAP-BALANCE-STATEMENT â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-BAL-SME1",    "capability_id": "CAP-BALANCE-STATEMENT",      "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "getInstantCreditStatement, getTransactions v22, agingPeriod"},
    {"id": "STK-BAL-SME2",    "capability_id": "CAP-BALANCE-STATEMENT",      "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "SLO consulta saldo  --  KPI de negocio TDC mÃ¡s frecuente"},
    {"id": "STK-BAL-ARCH1",   "capability_id": "CAP-BALANCE-STATEMENT",      "name": "Oscar Melo",                    "stakeholder_type": "program_architect",  "raci_role": "responsible",  "organization": "Accenture",   "sme_path": None, "contact_note": "ApificaciÃ³n  --  integraciÃ³n SVIP + latencia APOLO"},
    {"id": "STK-BAL-ARCH2",   "capability_id": "CAP-BALANCE-STATEMENT",      "name": "Jose Villena",                  "stakeholder_type": "program_architect",  "raci_role": "consulted",    "organization": "Accenture",   "sme_path": None, "contact_note": "ApificaciÃ³n  --  arquitectura de APIs"},

    # â"€â"€ CAP-PAYMENT â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-PAY-SME1",    "capability_id": "CAP-PAYMENT",                "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "MAD, PPNGI, total/libre  --  validaciones en SmartVista"},
    {"id": "STK-PAY-SME2",    "capability_id": "CAP-PAYMENT",                "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "KPI pagos procesados correctamente  --  alerta < 99% P2"},
    {"id": "STK-PAY-ARCH1",   "capability_id": "CAP-PAYMENT",                "name": "Oscar Melo",                    "stakeholder_type": "program_architect",  "raci_role": "responsible",  "organization": "Accenture",   "sme_path": None, "contact_note": "ApificaciÃ³n  --  orchestaciÃ³n de pago"},

    # â"€â"€ CAP-CUSTOMER-PROFILE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-CUST-SME1",   "capability_id": "CAP-CUSTOMER-PROFILE",       "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "getAccountCards, getCardInfo  --  crÃ©dito 18 dÃ­gitos"},
    {"id": "STK-CUST-SME2",   "capability_id": "CAP-CUSTOMER-PROFILE",       "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "KYC, datos del cliente  --  CNBV"},
    {"id": "STK-CUST-ARCH1",  "capability_id": "CAP-CUSTOMER-PROFILE",       "name": "Alfredo Aguilar",               "stakeholder_type": "vendor_contact",     "raci_role": "responsible",  "organization": "Appwhere",    "sme_path": None, "contact_note": "APOLO  --  onboarding y perfil  --  ICCAT para CAT pendiente"},

    # â"€â"€ CAP-CHANNEL-SELFSERVICE â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-CHAN-SME1",   "capability_id": "CAP-CHANNEL-SELFSERVICE",    "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "SVIP 92 comandos  --  diseÃ±o de IVR con SmartVista"},
    {"id": "STK-CHAN-SME2",   "capability_id": "CAP-CHANNEL-SELFSERVICE",    "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "SLO IVR availability â‰¥ 99.9%"},
    {"id": "STK-CHAN-ARCH1",  "capability_id": "CAP-CHANNEL-SELFSERVICE",    "name": "Ramses Santos",                 "stakeholder_type": "bancoppel_owner",    "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM CAT  --  contrataciÃ³n proveedor BLOQUEADA"},

    # â"€â"€ CAP-AUTHENTICATION â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-AUTHN-SME1",  "capability_id": "CAP-AUTHENTICATION",         "name": "Cybersecurity",                 "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Cybersecurity/",                 "contact_note": "OTP 4 dÃ­gitos, ANI, DTMF  --  PCI-DSS control 8.6 MFA"},
    {"id": "STK-AUTHN-SME2",  "capability_id": "CAP-AUTHENTICATION",         "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "Templates SMS MAI_BDT_IC/SMS_BDT_IC  --  integraciÃ³n SmartVista"},
    {"id": "STK-AUTHN-ARCH1", "capability_id": "CAP-AUTHENTICATION",         "name": "Mercedes Espinosa",             "stakeholder_type": "bancoppel_owner",    "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "Arquitectura CAT  --  postura frameworks obsoletos"},

    # â"€â"€ CAP-COLLECTIONS-AGING â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-COL-SME1",    "capability_id": "CAP-COLLECTIONS-AGING",      "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "E1/E2/E3  --  reglas de restricciÃ³n por mora y colecciÃ³n"},
    {"id": "STK-COL-SME2",    "capability_id": "CAP-COLLECTIONS-AGING",      "name": "SRE & AIOps",                   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "SRE & AIOps/",                  "contact_note": "Observabilidad cobranza  --  pentest conflicto nov 15-20"},
    {"id": "STK-COL-ARCH1",   "capability_id": "CAP-COLLECTIONS-AGING",      "name": "Marksey Sanvicente",            "stakeholder_type": "bancoppel_owner",    "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "Cobranza Direccionada  --  plan de trabajo sin formalizar (RISK-006)"},

    # â"€â"€ CAP-FEE-COMMISSION â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-FEE-SME1",    "capability_id": "CAP-FEE-COMMISSION",         "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "CatÃ¡logo BANXICO homologado  --  anualidades y comisiones TDC"},
    {"id": "STK-FEE-SME2",    "capability_id": "CAP-FEE-COMMISSION",         "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "ParametrizaciÃ³n en SmartVista SVBO"},
    {"id": "STK-FEE-ARCH1",   "capability_id": "CAP-FEE-COMMISSION",         "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista  --  parametrizaciÃ³n solo"},

    # â"€â"€ CAP-ACCOUNTING-INTEGRATION â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-ACC-SME1",    "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "Industry Banking Accounting",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking Accounting/",  "contact_note": "TRNT 623, Grupo contable 13  --  guÃ­a contable TDC pendiente BanCoppel"},
    {"id": "STK-ACC-SME2",    "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "DBA IBM Informix",              "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "DBA IBM Informix/",              "contact_note": "PISA/Informix  --  flujo SmartVista -> TRNT -> PISA"},
    {"id": "STK-ACC-ARCH1",   "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "J.A. Valverde",                 "stakeholder_type": "bancoppel_owner",    "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "Contabilidad  --  entregables guÃ­a contable RISK-008"},
    {"id": "STK-ACC-ARCH2",   "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "G. Martinez",                   "stakeholder_type": "bancoppel_owner",    "raci_role": "responsible",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "Contabilidad  --  entregables guÃ­a contable RISK-008"},
    {"id": "STK-ACC-ARCH3",   "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "S. Melo",                       "stakeholder_type": "bancoppel_owner",    "raci_role": "informed",     "organization": "BanCoppel",   "sme_path": None, "contact_note": "Contabilidad  --  entregables guÃ­a contable RISK-008"},
    {"id": "STK-ACC-ARCH4",   "capability_id": "CAP-ACCOUNTING-INTEGRATION", "name": "Oscar Melo",                    "stakeholder_type": "program_architect",  "raci_role": "responsible",  "organization": "Accenture",   "sme_path": None, "contact_note": "ApificaciÃ³n  --  integraciÃ³n SmartVista <-> TRNT"},

    # â"€â"€ CAP-ERROR-CATALOG â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "STK-ERR-SME1",    "capability_id": "CAP-ERROR-CATALOG",          "name": "Core Banking Transformation",   "stakeholder_type": "acn_sme",            "raci_role": "responsible",  "organization": "Accenture",   "sme_path": SME_BASE + "Core Banking Transformation/",  "contact_note": "CatÃ¡logo SV existente  --  homologaciÃ³n BANXICO mensajes de rechazo"},
    {"id": "STK-ERR-SME2",    "capability_id": "CAP-ERROR-CATALOG",          "name": "Industry Banking",              "stakeholder_type": "acn_sme",            "raci_role": "consulted",    "organization": "Accenture",   "sme_path": SME_BASE + "Industry Banking/",              "contact_note": "Mensajes BANXICO  --  significado regulatorio de cada cÃ³digo"},
    {"id": "STK-ERR-ARCH1",   "capability_id": "CAP-ERROR-CATALOG",          "name": "Armando Garcia",                "stakeholder_type": "program_architect",  "raci_role": "accountable",  "organization": "BanCoppel",   "sme_path": None, "contact_note": "PM SmartVista  --  consumo dinÃ¡mico en App/SIWEB/CAT"},
]

# Routing por capability  --  fuente: dt-coexistencia
CAPABILITY_ROUTING = [
    {"id": "RT-MANUF-SV",   "capability_id": "CAP-CARD-MANUFACTURING",   "channel": "apificacion", "pre_r4_route": "CMS/Cargen",     "post_r4_route": "SmartVista OCG/Cargen", "switch_mechanism": "feature_flag_producto", "parallel_run": 1, "notes": "Maquila batch  --  no tiempo real"},
    {"id": "RT-AUTH-SV",    "capability_id": "CAP-AUTHORIZATION",         "channel": "all",         "pre_r4_route": "E-Global -> CMS",   "post_r4_route": "E-Global -> SmartVista SVIP", "switch_mechanism": "feature_flag_producto", "parallel_run": 1, "notes": None},
    {"id": "RT-LIFE-APP",   "capability_id": "CAP-CARD-LIFECYCLE",        "channel": "app",         "pre_r4_route": "Informix/CMS",   "post_r4_route": "SmartVista SVIP",       "switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": None},
    {"id": "RT-LIFE-CAT",   "capability_id": "CAP-CARD-LIFECYCLE",        "channel": "cat",         "pre_r4_route": "Informix/CMS",   "post_r4_route": "SmartVista SVIP via CAT","switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": "Bloqueado hasta contratar CAT"},
    {"id": "RT-OVP-APP",    "capability_id": "CAP-OVERPAYMENT",           "channel": "app",         "pre_r4_route": "Informix",       "post_r4_route": "SmartVista SVIP",       "switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": "BYU0039 bloquea routing"},
    {"id": "RT-BAL-APP",    "capability_id": "CAP-BALANCE-STATEMENT",     "channel": "app",         "pre_r4_route": "Informix",       "post_r4_route": "SmartVista SVIP",       "switch_mechanism": "feature_flag_producto", "parallel_run": 1, "notes": None},
    {"id": "RT-BAL-CAT",    "capability_id": "CAP-BALANCE-STATEMENT",     "channel": "cat",         "pre_r4_route": "Informix/IVR",   "post_r4_route": "SmartVista SVIP via IVR","switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": "CAT sin contratar"},
    {"id": "RT-PAY-APP",    "capability_id": "CAP-PAYMENT",               "channel": "app",         "pre_r4_route": "Informix",       "post_r4_route": "SmartVista SVIP",       "switch_mechanism": "feature_flag_producto", "parallel_run": 1, "notes": None},
    {"id": "RT-CHAN-CAT",   "capability_id": "CAP-CHANNEL-SELFSERVICE",   "channel": "cat",         "pre_r4_route": "N/A",            "post_r4_route": "SmartVista SVIP via IVR","switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": "CAT sin contratar  --  bloqueado"},
    {"id": "RT-COL-INT",    "capability_id": "CAP-COLLECTIONS-AGING",     "channel": "cobranza",    "pre_r4_route": "Informix",       "post_r4_route": "SmartVista agingPeriod", "switch_mechanism": "feature_flag_producto", "parallel_run": 0, "notes": None},
    {"id": "RT-ACC-SV",     "capability_id": "CAP-ACCOUNTING-INTEGRATION","channel": "apificacion", "pre_r4_route": "Informix -> PISA",  "post_r4_route": "SmartVista SVBO libro de saldos; SVXP archivo XML contable; PISA marca conciliado sin cargo ni abono; SOC", "switch_mechanism": "feature_flag_producto", "parallel_run": 1, "notes": "CORREGIDO 2026-08-19. La cadena previa 'SmartVista -> TRNT -> PISA' se leyo mal como si TRNT fuera Temenos Transact. TRNT es el tipo de transaccion contable de reclasificacion DENTRO de SmartVista; el ejemplo T623 que se uso antes es falso, el 623 es una transaccion de SIWEB (PAGO CGO A CTA DE CREDISOLUCIONES). Temenos Transact NO participa en el ciclo del Producto 4900. La frontera contable real es SVBO -> SVXP (archivo XML) -> PISA: la contabilidad PERMANECE en PISA. Para el BIN 42680711 la conciliacion es solo informativa: PISA registra y marca conciliado pero NO genera cargo ni abono, porque credito, saldos y asignacion de tarjeta viven en SmartVista; tampoco genera archivo ni reporte posterior. El BCPLPNC SI contiene los 4 bines; lo excluido es la AFECTACION de cuentas del subproducto 11. Guia contable pendiente; PP-TRNT-PAGOS al 0%. Fuente: Conciliacion automatica PISA - SmartVista (SV).docx, 16-nov-2023: revalidar vigencia contra el diseno R4."},
]


# â"€â"€ AnÃ¡lisis por track  --  fuente: minutas sesiones User Stories 3-7 agosto 2026 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€

TRACK_ANALYSIS = [
    {
        "id": "TA-SMARTVISTA", "track": "smartvista", "session_date": "2026-08-03/06",
        "hu_total": 22, "hu_must": 11, "hu_should": 10, "hu_could": 0, "hu_wont": 1,
        "hu_tipo_solucion": 15, "hu_tipo_integracion": 1, "hu_tipo_mixta": 6,
        "complexity_low": 2, "complexity_mid": 16, "complexity_high": 4, "complexity_pending": 0,
        "integrations_total": 7, "integrations_api": 5, "integrations_event": 0,
        "apificacion_scope": "2 integraciones omnicanal (SV->SIWEB y SV->APP). Nota: 2 Batch (ISV01 AWS→Informix y ISV02 AFT Connect Direct) contabilizadas en total pero no en api",
        "key_risk": "Won't: 'Excluir abonos bancarios del lÃ­mite' descartada formalmente por Negocio",
        "key_decision": "18 User Stories resueltas por combinaciÃ³n desarrollo+configuraciÃ³n; 3 por desarrollo puro",
        "source_doc": "20260806 - R4 SMARTVISTA - Analisis detallado HDUs e Integraciones.docx",
        "notes": "3 sesiones (3-6 ago). Complejidad: 72% media. Requiere config intensiva BPC."
    },
    {
        "id": "TA-APOLO", "track": "apolo", "session_date": "2026-08-07",
        "hu_total": 22, "hu_must": 11, "hu_should": 10, "hu_could": 1, "hu_wont": 0,
        "hu_tipo_solucion": 10, "hu_tipo_integracion": 7, "hu_tipo_mixta": 5,
        "complexity_low": 5, "complexity_mid": 11, "complexity_high": 6, "complexity_pending": 0,
        "integrations_total": 17, "integrations_api": 12, "integrations_event": 0,
        "apificacion_scope": "100% del Ã¡mbito de integraciÃ³n en APOLO",
        "key_risk": "ComplejidaD pendiente de ajuste al confirmar pantallas y APIs; esfuerzo real puede ser menor (evoluciÃ³n, no build nuevo)",
        "key_decision": "7 User Stories solo integraciones = responsabilidad de ApificaciÃ³n; esfuerzo de desarrollo puede reducirse significativamente",
        "source_doc": "20260806 - R4 APOLO - Analisis detallado HDUs e Integraciones.docx",
        "notes": "Originacion digital Appwhere. IntegracioneS pendientes de confirmar. Semanana 10-ago = anÃ¡lisis APIs."
    },
    {
        "id": "TA-APP", "track": "app", "session_date": "2026-08-04/06",
        "hu_total": 18, "hu_must": 15, "hu_should": 0, "hu_could": 1, "hu_wont": 2,
        "hu_tipo_solucion": 10, "hu_tipo_integracion": 4, "hu_tipo_mixta": 4,
        "complexity_low": 5, "complexity_mid": 6, "complexity_high": 7, "complexity_pending": 0,
        "integrations_total": 4, "integrations_api": 4, "integrations_event": 0,
        "apificacion_scope": "100% del Ã¡mbito de integraciÃ³n en APP",
        "key_risk": "2 Won't diferidas a R4.5: 'Detalle de Movimientos Convivencia TDC F&D' y 'EliminaciÃ³n de TDC Digital'",
        "key_decision": "Todas las User Stories de soluciÃ³n por desarrollo (consistente con naturaleza canal digital)",
        "source_doc": "20260806 - R4 APP - Analisis detallado HDUs e Integraciones.docx",
        "notes": "2 sesiones. Complejidad alta (7 User Stories). Stakeholders: Nova Solution Systems."
    },
    {
        "id": "TA-CAT", "track": "cat", "session_date": "2026-08-03",
        "hu_total": 12, "hu_must": 9, "hu_should": 3, "hu_could": 0, "hu_wont": 0,
        "hu_tipo_solucion": 5, "hu_tipo_integracion": 0, "hu_tipo_mixta": 7,
        "complexity_low": 4, "complexity_mid": 4, "complexity_high": 4, "complexity_pending": 0,
        "integrations_total": 7, "integrations_api": 6, "integrations_event": 1,
        "apificacion_scope": "100% del Ã¡mbito de integraciÃ³n en CAT",
        "key_risk": "Proveedor CAT no contratado (RISK-UNITY-R27, due 2026-08-31)  --  bloquea implementaciÃ³n",
        "key_decision": "Responsabilidad de integraciones: nuevo proveedor CAT + equipo ApificaciÃ³n. Alcance cerrado al 20-Jul-26.",
        "source_doc": "20260803 - R4 CAT - Analisis detallado HDUs e Integraciones.docx",
        "notes": "7 de las 12 User Stories requieren integraciones. 6 APIs + 1 evento."
    },
    {
        "id": "TA-SIWEB", "track": "siweb", "session_date": "2026-08-05",
        "hu_total": 5, "hu_must": 0, "hu_should": 5, "hu_could": 0, "hu_wont": 0,
        "hu_tipo_solucion": 0, "hu_tipo_integracion": 0, "hu_tipo_mixta": 5,
        "complexity_low": 0, "complexity_mid": 5, "complexity_high": 0, "complexity_pending": 0,
        "integrations_total": None, "integrations_api": None, "integrations_event": None,
        "apificacion_scope": "100% del Ã¡mbito de integraciÃ³n en SIWEB (pendiente sesiÃ³n tÃ©cnica)",
        "key_risk": "Sin confirmaciÃ³n formal de que Appwhere elabore DTMs/DTCs para SIWEB en R4",
        "key_decision": "Todas User Stories requieren soluciÃ³n e integraciÃ³n; sin posibilidad de reutilizar cÃ³digo legacy SV",
        "source_doc": "20260805 - R4 SIWEB - Analisis detallado HDUs e Integraciones.docx",
        "notes": "Solo Should Have. Pendiente sesiÃ³n tÃ©cnica con APIs y SmartVista. Semana 10-ago = anÃ¡lisis."
    },
    {
        "id": "TA-COBRANZA", "track": "cobranza", "session_date": "2026-08-06",
        "hu_total": None, "hu_must": None, "hu_should": None, "hu_could": None, "hu_wont": None,
        "hu_tipo_solucion": None, "hu_tipo_integracion": None, "hu_tipo_mixta": None,
        "complexity_low": None, "complexity_mid": None, "complexity_high": None, "complexity_pending": None,
        "integrations_total": None, "integrations_api": None, "integrations_event": None,
        "apificacion_scope": "Integraciones son cargas de datos (data ingestion), no microservicios tradicionales",
        "key_risk": "Pentest Cobranza 15-20 nov 2026 (freeze) vs SIT desde 15-oct: RIESGO DE DESALINEACIÃšN calendarios",
        "key_decision": "Alcance Cobranza: 37-50 User Stories (pendiente incorporar al inventario unificado). EvoluciÃ³n del modelo de datos + adecuaciones BPC + construcciÃ³n componentes SV",
        "source_doc": "20260806 - Unity R4 - Cobranza - Resumen Detallado.docx",
        "notes": "ConstrucciÃ³n/UT: fin agosto - mediados septiembre. No es solo integraciones  --  incluye build en BPC."
    },
    {
        "id": "TA-APIFICACION", "track": "apificacion", "session_date": "2026-08-07",
        "hu_total": None, "hu_must": None, "hu_should": None, "hu_could": None, "hu_wont": None,
        "hu_tipo_solucion": None, "hu_tipo_integracion": None, "hu_tipo_mixta": None,
        "complexity_low": None, "complexity_mid": None, "complexity_high": None, "complexity_pending": None,
        "integrations_total": None, "integrations_api": None, "integrations_event": None,
        "apificacion_scope": "APOLO+SIWEB+CAT=100%; SmartVista=2 integraciones omnicanal (SV->SIWEB, SV->APP)",
        "key_risk": "Sin inventario consolidado de integraciones R4. User Stories con baja calidad de definiciÃ³n requieren refinamiento",
        "key_decision": "Secuencia anÃ¡lisis: Apolo (sem 10-ago) -> SIWEB (sem 10-ago) -> CAT y APP. Trazabilidad User Story-IntegracionRACIÃ³n obligatoria",
        "source_doc": "20260807 - R4 Integraciones - Equipo APIificaciÃ³n - Resumen Detallado.docx",
        "notes": "Coordinadores: Jose Villena, Oscar Melo, Juan Carlos Valenzuela. Esfuerzo APOLO puede ser menor (evoluciÃ³n)."
    },
]

# â"€â"€ Plan de Trabajo UNITY R4  --  corte 16-ago-2026 â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€

PLAN_PROGRESS = [
    # â"€â"€ Resumen global â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "PP-GLOBAL", "track": "all", "activity_id": "0",
     "activity": "Avance Real Global Unity R4",
     "responsible": "Maria Fernanda Barbosa (LÃ­der de Control)",
     "start_date": None, "end_date": None,
     # CORREGIDO 2026-08-20. Se usaba 20.66% vs 34.0% con corte 2026-08-16: las tres cifras
     # estaban mal. El 34% no existe en ningun documento; el esperado del corte 12-ago era
     # 31.72%; y existe un corte POSTERIOR, el del 17-ago, que es el que se carga aqui.
     "pct_real": 21.19, "pct_expected": 60.58, "deviation": -39.39,
     "status": "delayed",
     "blocker_note": "Retrasado 39.39pp al corte 17-ago-2026. SERIE: corte 12-ago = 20.66% real vs "
                     "31.72% esperado; corte 17-ago = 21.19% real vs 60.58% esperado. El salto del "
                     "esperado de 31.72% a 60.58% en 5 dias indica que se RECALCULARON LAS LINEAS "
                     "BASE, no que el programa avanzara. TRAMPA DE ARCHIVO: el corte 17-ago vive en "
                     "'Plan de Trabajo UNITY R4_200726.xlsx', cuyo nombre sugiere 20-jul; hay que leer "
                     "el campo 'Corte de Informacion', nunca el nombre del archivo. Ese mismo archivo "
                     "reporta en otra hoja un par distinto para el mismo corte (10.27% vs 67.07%), "
                     "inconsistencia interna sin resolver.",
     "as_of_date": "2026-08-17"},

    # â"€â"€ CANAL: SMARTVISTA â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "PP-SV", "track": "smartvista", "activity_id": "1",
     "activity": "CANAL: SMARTVISTA",
     "responsible": "BPC / Armando Garcia Ortiz",
     "start_date": None, "end_date": None,
     "pct_real": 32.6, "pct_expected": 32.5, "deviation": 0.1,
     "status": "on_time", "blocker_note": None, "as_of_date": "2026-08-16"},

    {"id": "PP-SV-1-1", "track": "smartvista", "activity_id": "1.1",
     "activity": "PAGOS ANTICIPADOS Y LIQUIDACIONES DE COMPRAS DIFERIDAS",
     "responsible": "BPC",
     "start_date": "2026-07-06", "end_date": "2026-12-12",
     "pct_real": 25.5, "pct_expected": 26.1, "deviation": -0.6,
     "status": "delayed",
     "blocker_note": "DefiniciÃ³n TRNTs Pagos: 0% vs 100% esperado. DTMs Appwhere: 0% vs 57.7%.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-SV-1-2", "track": "smartvista", "activity_id": "1.2",
     "activity": "SOLICITUD DE MAQUILA AUTOMATIZADA",
     "responsible": "BPC / Armando Garcia Ortiz",
     "start_date": "2026-07-06", "end_date": "2026-12-11",
     "pct_real": 7.0, "pct_expected": 26.1, "deviation": -19.1,
     "status": "delayed",
     "blocker_note": "AprobaciÃ³n propuesta CR: 0% vs 100%. Llaves PGP Thales: RETRASADO. Interfaces Shell Maquila: 0% vs 9.4%.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-SV-1-4", "track": "smartvista", "activity_id": "1.4",
     "activity": "DISPOSICIÓN DE EFECTIVO - APP",
     "responsible": "CMS / Contabilidad",
     "start_date": "2026-07-13", "end_date": "2026-12-18",
     "pct_real": 35.5, "pct_expected": 21.7, "deviation": 13.8,
     "status": "on_time",
     "blocker_note": "Adelantado. ValidaciÃ³n guÃ­a contable CMS: 20% vs 56% esperado (bloqueado).",
     "as_of_date": "2026-08-16"},

    {"id": "PP-SV-1-5", "track": "smartvista", "activity_id": "1.5",
     "activity": "HOMOLOGACIÃšN DE CONCEPTOS DE COMISIONES",
     "responsible": "Armando Riveros (ApificaciÃ³n)",
     "start_date": "2026-07-01", "end_date": "2026-11-13",
     "pct_real": 16.0, "pct_expected": 33.7, "deviation": -17.7,
     "status": "delayed",
     "blocker_note": "Mesa de Trabajo SV-ApificaciÃ³n: 0% vs 26.7%. Documento de Descripciones: 0% vs 26.7%.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-SV-1-7", "track": "smartvista", "activity_id": "1.7",
     "activity": "88 REGLAS AUTORIZADOR SMARTVISTA",
     "responsible": "BPC / Sonny Benavides",
     "start_date": "2026-06-06", "end_date": "2026-10-09",
     "pct_real": 76.4, "pct_expected": 78.2, "deviation": -1.8,
     "status": "delayed",
     "blocker_note": "InstalaciÃ³n SVFM en QA: 10% vs 100% esperado (-90%). ARQC InvÃ¡lido tests: -50%.",
     "as_of_date": "2026-08-16"},

    # â"€â"€ Actividades crÃ­ticas transversales â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€
    {"id": "PP-TRNT-PAGOS", "track": "smartvista", "activity_id": "trnt-pagos",
     "activity": "DefiniciÃ³n de TRNTs Pagos",
     "responsible": "BPC",
     "start_date": "2026-07-27", "end_date": "2026-08-13",
     "pct_real": 0.0, "pct_expected": 92.86, "deviation": -92.86,
     # CORREGIDO 2026-08-19: 13 de 14 dias habiles al corte 12-ago, no 100%.
     # Fecha limite REAL 2026-08-13, ya vencida. En el plan con corte 17-ago la actividad
     # ya no existe: la estructura del subtrack cambio, asi que no hay dato de cierre.
     "status": "delayed",
     "blocker_note": "CRÃTICO: 0% vs 100% esperado. Bloquea configuraciÃ³n contable de pagos.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-DTM-APPWHERE", "track": "smartvista", "activity_id": "dtm-appwhere",
     "activity": "ElaboraciÃ³n de los DTMs (Appwhere)",
     "responsible": "AppWhere",
     "start_date": "2026-07-27", "end_date": "2026-08-31",
     "pct_real": 0.0, "pct_expected": 57.7, "deviation": -57.7,
     "status": "delayed",
     "blocker_note": "CRÃTICO: 0% vs 57.7% esperado. DTMs son documentaciÃ³n tÃ©cnica mandatoria pre-desarrollo.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-SVFM-QA", "track": "smartvista", "activity_id": "svfm-qa",
     "activity": "InstalaciÃ³n SmartVista Fraud Management en QA",
     "responsible": "BPC",
     "start_date": "2026-08-04", "end_date": "2026-08-15",
     "pct_real": 10.0, "pct_expected": 100.0, "deviation": -90.0,
     "status": "delayed",
     "blocker_note": "CRÃTICO: SVFM no instalado en QA bloquea pruebas de fraude del autorizador.",
     "as_of_date": "2026-08-16"},

    {"id": "PP-PGP-THALES", "track": "smartvista", "activity_id": "pgp-thales",
     "activity": "Solicitud Llaves PGP DEV - Thales (maquilador Gemalto/Thales)",
     "responsible": "Armando Garcia Ortiz",
     "start_date": "2026-07-27", "end_date": "2026-07-31",
     "pct_real": 50.0, "pct_expected": 100.0, "deviation": -50.0,
     "status": "delayed",
     "blocker_note": "Llaves PGP para ambiente DEV sin completar. Bloquea certificaciÃ³n de layout Thales.",
     "as_of_date": "2026-08-16"},
]

PV_REQUIREMENTS = [
    # RF-001 a RF-028: Product Vision R4 - DEF PV 1006626 Mercado Abierto (R4 ).docx
    # PM: Sergio Arellano Payan | Gerente: Juan Carlos Huertero | Subdirector: Miguel Castillo Espinosa
    # v1 15/08/2025, actualizada 31/12/2025. Scope inicial: solo producto 4900.
    {"id": "RF-001", "rf_num": 1,
     "name": "Convivencia de tarjeta Fisica y Digital",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Dashboard Home muestra tarjeta fisica y digital del producto 4900 simultáneamente.",
     "business_rules": "Solo aplica producto 4900. Tarjeta digital puede existir sin fisica. Ambas muestran estatus.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-002", "rf_num": 2,
     "name": "Submodulo de Tarjetas Fisica y Digital",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Gestion independiente y consolidada de movimientos de tarjeta fisica y digital desde la App.",
     "business_rules": "Movimientos de cada tarjeta consultables individualmente y en forma consolidada.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-003", "rf_num": 3,
     "name": "Visualizacion de transacciones tarjeta fisica y digital en seccion detalle",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-BALANCE-STATEMENT",
     "description": "Detalle de transacciones accesible desde la seccion de movimientos. Identifica si es fisica o digital.",
     "business_rules": "Identificar en la visualizacion si la transaccion corresponde a tarjeta fisica o digital.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-004", "rf_num": 4,
     "name": "Diferimiento de transacciones a MCI por campanas",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-DEFERRED-PURCHASE",
     "description": "Cliente puede diferir compras a MCI desde la App por campanas. Plazos: 3, 6, 9, 12, 18, 24 meses.",
     "business_rules": "Plazos disponibles: 3/6/9/12/18/24 meses. Solo compras elegibles segun campana activa.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, APOLO, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-005", "rf_num": 5,
     "name": "Diferimiento de transacciones a MCI desde punto de venta",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-DEFERRED-PURCHASE",
     "description": "Cliente puede diferir compras de TPV a MCI desde la App.",
     "business_rules": "Compra debe haberse realizado en TPV compatible. El diferimiento se aplica desde la App.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista, SIWEB", "scope_product": "4900", "notes": None},
    {"id": "RF-006", "rf_num": 6,
     "name": "Pagos anticipados y Liquidaciones de Compras diferidas",
     "priority": "alta", "moscow": "must", "channel": "multi", "capability_id": "CAP-PAYMENT",
     "description": "Cliente puede liquidar o realizar pagos anticipados de compras diferidas. SIWEB usa transaccion 623.",
     "business_rules": "Transaccion 623 en SIWEB. Calcula saldo pendiente con descuento de intereses futuros.",
     "actors": "Cliente BanCoppel, Ejecutivo SIWEB", "systems_involved": "APP, SIWEB, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-007", "rf_num": 7,
     "name": "Cancelacion de Compras Diferidas desde SIWEB y APP",
     "priority": "alta", "moscow": "must", "channel": "multi", "capability_id": "CAP-DEFERRED-PURCHASE",
     "description": "Cliente o ejecutivo puede cancelar compras diferidas desde SIWEB o APP (CrediSoluciones).",
     "business_rules": "Cancelacion revierte el diferimiento y aplica cargo completo. Disponible en APP y SIWEB.",
     "actors": "Cliente BanCoppel, Ejecutivo Sucursal", "systems_involved": "APP, SIWEB, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-008", "rf_num": 8,
     "name": "Acumulacion de puntos Coppel Max",
     "priority": "alta", "moscow": "must", "channel": "smartvista", "capability_id": "CAP-AUTHORIZATION",
     "description": "Por cada compra con TDC 4900 el cliente acumula Dinero Electronico automaticamente.",
     "business_rules": "Clasica 1% DE, Oro 2% DE, Infinite 3% DE. Bonus cumpleanos: Clasica 0.2%, Oro 0.4%, Infinite 0.6%. 1 DE Clasica=$0.10 MXN | Oro=$0.50 MXN | Infinite=$1.00 MXN.",
     "actors": "Cliente BanCoppel", "systems_involved": "SmartVista, APOLO, APP", "scope_product": "4900, 6001, 7000, 8100, Infinite", "notes": None},
    {"id": "RF-009", "rf_num": 9,
     "name": "Redencion de puntos Coppel Max",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-AUTHORIZATION",
     "description": "El cliente puede canjear Dinero Electronico desde la App para abonar a TDC o en cuentas captacion Reworth.",
     "business_rules": "Conversion captacion 1:1 ($1.00 MXN por DE). 10 productos captacion elegibles: 1300,1400,1500,1700,1900,2000,2100,2400,2500,2900.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista, APOLO", "scope_product": "4900, 6001, 7000, 8100, Infinite", "notes": None},
    {"id": "RF-010", "rf_num": 10,
     "name": "Eliminacion y generacion de tarjeta digital",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Cliente puede eliminar tarjeta digital actual y generar una nueva con CVV dinamico desde la App.",
     "business_rules": "CVV dinamico. Al eliminar tarjeta digital, CVV previo queda invalido. Nueva tarjeta generada inmediatamente.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-011", "rf_num": 11,
     "name": "Domiciliacion de tarjeta de credito a cuenta BanCoppel",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-PAYMENT",
     "description": "Cliente puede domiciliar pago de TDC a su cuenta BanCoppel desde App. Modalidades: pago minimo, sin intereses, o fijo.",
     "business_rules": "3 modalidades: minimo, sin intereses, fijo. Cuenta BanCoppel del mismo titular. Cargo automatico en fecha de pago.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista, APOLO", "scope_product": "4900", "notes": None},
    {"id": "RF-012", "rf_num": 12,
     "name": "Disposicion de efectivo en App BanCoppel",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-AUTHORIZATION",
     "description": "Cliente puede solicitar disposicion de efectivo con TDC 4900 desde la App. Minimo $50 MXN sin centavos.",
     "business_rules": "Monto minimo: $50.00 MXN. Sin centavos (pesos enteros). Sujeto a linea de credito disponible.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista, APOLO", "scope_product": "4900", "notes": None},
    {"id": "RF-013", "rf_num": 13,
     "name": "Alta del producto 4900 en el IVR / CAT",
     "priority": "alta", "moscow": "must", "channel": "cat", "capability_id": "CAP-CHANNEL-SELFSERVICE",
     "description": "CAT (Contact Center / IVR) debe reconocer y operar el producto 4900. Ejecutivos y IVR atienden clientes con este producto.",
     "business_rules": "Producto 4900 configurado en sistemas CAT. IVR enruta correctamente solicitudes del producto 4900.",
     "actors": "Ejecutivo CAT, Cliente BanCoppel", "systems_involved": "CAT, IVR, SmartVista, APOLO", "scope_product": "4900", "notes": "RISK-UNITY-R27: proveedor CAT no contratado (deadline 31-ago-2026)"},
    {"id": "RF-014", "rf_num": 14,
     "name": "Identificacion de clientes Apolo en CAT",
     "priority": "alta", "moscow": "must", "channel": "cat", "capability_id": "CAP-AUTHENTICATION",
     "description": "CAT puede identificar y autenticar clientes con productos en APOLO (incluido 4900). 2FA con max 3 intentos.",
     "business_rules": "Factor 1 + Factor 2. Max 3 intentos fallidos antes de bloqueo temporal. Distingue clientes Apolo de legacy.",
     "actors": "Ejecutivo CAT, Cliente BanCoppel", "systems_involved": "CAT, APOLO, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-015", "rf_num": 15,
     "name": "Bloqueo de tarjeta fisica y digital desde CAT por robo o extravio",
     "priority": "alta", "moscow": "must", "channel": "cat", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Ejecutivo CAT puede bloquear definitivamente tarjeta fisica y/o digital por robo o extravio.",
     "business_rules": "Bloqueo definitivo. Notificacion al cliente por SMS y correo. Registro en historial de cuenta.",
     "actors": "Ejecutivo CAT, Cliente BanCoppel", "systems_involved": "CAT, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-016", "rf_num": 16,
     "name": "Bloqueo de tarjeta fisica y digital desde CAT por prevencion",
     "priority": "alta", "moscow": "must", "channel": "cat", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Ejecutivo CAT puede bloquear y desbloquear temporalmente tarjeta por prevencion (sin robo/extravio).",
     "business_rules": "Mismo mecanismo de bloqueo que APP y Sucursal. Desbloqueo en CAT/APP/sucursales. Codigo SMS para desbloqueo.",
     "actors": "Ejecutivo CAT, Cliente BanCoppel", "systems_involved": "CAT, SmartVista, APP, SIWEB", "scope_product": "4900", "notes": "ANEXO RQM Bloqueo/Desbloqueo TDC Migracion.docx"},
    {"id": "RF-017", "rf_num": 17,
     "name": "Bloqueo de tarjeta fisica y digital desde SIWEB por robo o extravio",
     "priority": "alta", "moscow": "must", "channel": "siweb", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Ejecutivo de sucursal reporta tarjeta por robo/extravio/vencimiento/dano/aclaracion/fraude desde SIWEB. Modulo de reposiciones.",
     "business_rules": "Autenticacion con huella digital. Costo de reposicion (exento en aclaracion/fraude). Numero cuenta 18 digitos. Datos enmascarados. Notificacion por mensaje y e-mail.",
     "actors": "Ejecutivo Sucursal, Cliente BanCoppel", "systems_involved": "SIWEB, SmartVista", "scope_product": "4900 (todos TDC)", "notes": None},
    {"id": "RF-018", "rf_num": 18,
     "name": "Bloqueo temporal y Desbloqueo de tarjeta fisica desde la APP",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Cliente puede bloquear y desbloquear temporalmente su tarjeta fisica desde la App.",
     "business_rules": "Bloqueo temporal APP es el mismo mecanismo que CAT y sucursal. Desbloqueo en APP/CAT/sucursales.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-019", "rf_num": 19,
     "name": "Desbloqueo de TDC en Sucursal (SIWEB)",
     "priority": "alta", "moscow": "must", "channel": "siweb", "capability_id": "CAP-CARD-LIFECYCLE",
     "description": "Ejecutivo de sucursal desbloquea TDC del cliente desde SIWEB. Requiere autenticacion biometrica.",
     "business_rules": "Tarjeta bloqueada por cualquier canal. Autenticacion con huella digital obligatoria. Notificacion al cliente. Si NIP invalido, se invita a cambiar NIP.",
     "actors": "Ejecutivo Sucursal, Cliente BanCoppel", "systems_involved": "SIWEB, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-020", "rf_num": 20,
     "name": "Identificacion del canal de consulta del Estado de Cuenta",
     "priority": "alta", "moscow": "must", "channel": "multi", "capability_id": "CAP-BALANCE-STATEMENT",
     "description": "El sistema identifica y registra por que canal consulta el cliente su estado de cuenta.",
     "business_rules": "Canal de consulta (APP/IVR/SIWEB/web) identificado y registrado en cada consulta.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, CAT, SIWEB, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-021", "rf_num": 21,
     "name": "Homologacion de conceptos de comisiones",
     "priority": "alta", "moscow": "must", "channel": "smartvista", "capability_id": "CAP-FEE-COMMISSION",
     "description": "Homologar nombres de comisiones TDC al catalogo BANXICO para producto 4900.",
     "business_rules": "Catalogo de mapeo disponible en Google Sheets. Todos los productos TDC deben cumplir nomenclatura BANXICO.",
     "actors": "Area Regulatoria, TI BanCoppel", "systems_involved": "SmartVista, APOLO", "scope_product": "4900", "notes": "Referencia: Mapeo de comisiones BANXICO 4900 en Google Sheets"},
    {"id": "RF-022", "rf_num": 22,
     "name": "Reglas de Cargos Recurrentes",
     "priority": "alta", "moscow": "must", "channel": "smartvista", "capability_id": "CAP-FEE-COMMISSION",
     "description": "Implementacion de reglas para el procesamiento de cargos recurrentes en TDC 4900 en SmartVista.",
     "business_rules": "Los cargos recurrentes deben seguir reglas del banco y normativa aplicable.",
     "actors": "Area de Operaciones", "systems_involved": "SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-023", "rf_num": 23,
     "name": "Visualizacion dinamica de saldo y fechas importantes desde la APP",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-BALANCE-STATEMENT",
     "description": "La App muestra dinamicamente saldo disponible, saldo actual, fecha de corte, fecha limite de pago y datos clave TDC.",
     "business_rules": "Informacion actualizada en tiempo real o con latencia minima. Incluye saldo a favor si aplica.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": None},
    {"id": "RF-024", "rf_num": 24,
     "name": "Mostrar en app etiqueta en proceso en compras no conciliadas",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-BALANCE-STATEMENT",
     "description": "Compras autorizadas pero no liquidadas se muestran con etiqueta en proceso. Consulta por hoy/7 dias/30 dias.",
     "business_rules": "Compra no conciliada = autorizada pero no liquidada. Etiqueta visible hasta conciliacion. Filtros: dia actual, 7 dias, 30 dias.",
     "actors": "Cliente BanCoppel", "systems_involved": "APP, SmartVista", "scope_product": "4900", "notes": "Miro board: uXjVP8XIy_E"},
    {"id": "RF-025", "rf_num": 25,
     "name": "Nueva regla de limitar saldo a favor (Auditoria)",
     "priority": "alta", "moscow": "must", "channel": "multi", "capability_id": "CAP-OVERPAYMENT",
     "description": "Limite parametrizable de saldo a favor mensual. Credito <= $24,999.99: limite $15,000 MXN/mes. Credito >= $25,000: limite 20% de linea vigente.",
     "business_rules": "Solo productos 6001 y 4900. Depositos del banco no suman al limite. Parametrizable (monto o %). Aplica en todos los canales. Reporteria en SmartVista.",
     "actors": "Area de Negocio, Auditoria", "systems_involved": "SmartVista, APP, SIWEB, CAT", "scope_product": "4900, 6001", "notes": "ANEXO DEF RQM Limite Maximo de Saldos a Favor"},
    {"id": "RF-026", "rf_num": 26,
     "name": "Informar al BRM sobre compromisos de pago de la TdC SmartVista",
     "priority": "alta", "moscow": "must", "channel": "smartvista", "capability_id": "CAP-PAYMENT",
     "description": "SmartVista informa al sistema BRM (Behavior Risk Management) sobre compromisos de pago del cliente TDC.",
     "business_rules": "Informacion de compromisos de pago fluye de SmartVista a BRM en tiempo real o batch segun acuerdo.",
     "actors": "Area de Riesgo, BRM", "systems_involved": "SmartVista, BRM", "scope_product": "4900", "notes": None},
    {"id": "RF-027", "rf_num": 27,
     "name": "Pago de Tarjeta de Credito con cuenta Bancoppel de terceros",
     "priority": "alta", "moscow": "must", "channel": "app", "capability_id": "CAP-PAYMENT",
     "description": "Cliente paga TDC desde App usando tarjeta/cuenta BanCoppel de un tercero. Se guarda la cuenta del tercero para pagos futuros.",
     "business_rules": "Cuenta del tercero debe ser BanCoppel. Si pago exitoso, se guarda cuenta del tercero. Genera comprobante descargable. Si falla, se muestra alerta de rechazo.",
     "actors": "Cliente BanCoppel, Tercero BanCoppel", "systems_involved": "APP, SmartVista, APOLO", "scope_product": "4900", "notes": None},
    {"id": "RF-028", "rf_num": 28,
     "name": "Automatizacion de Maquila",
     "priority": "alta", "moscow": "must", "channel": "cross", "capability_id": "CAP-CARD-MANUFACTURING",
     "description": "Proceso automatizado para solicitar y gestionar emision de tarjetas fisicas BIN 4268 0711. Aplicativo de inventario por sucursal.",
     "business_rules": "Solo producto 4900 inicialmente. BIN: 4268 0711. Proveedores: FORZA (prioritario), TGS, TALES/Gemalto. Proceso automatico periodico + solicitud manual por sucursal. Inventario por sucursal: no. sucursal, tipo tarjeta, BIN, total no asignadas, no. lotes.",
     "actors": "Area de Suministros, Maquiladores (FORZA/TGS/TALES)", "systems_involved": "SmartVista, SIWEB", "scope_product": "4900", "notes": "Requiere certificacion layouts con maquiladores. Paqueteria para entrega en sucursales."},
]

# v0.9.0  --  App User Stories: 13 tickets Jira SMART-XXXX (canal App, TDC F&D)
# Fuente: Respaldo US-20260805T010347Z-1-001.zip
APP_USER_STORIES = [
    {"smart_id": "SMART-3962", "title": "Detalle de Credito Convivencia TDC F&D",
     "estado": "removed", "resolucion": "declined", "canal": "app",
     "capability_id": "CAP-BALANCE-STATEMENT", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 5,
     "nota": "Pantalla detalle credito: corte, disponible, pagos; Declined -- reemplazada por SMART-4176"},
    {"smart_id": "SMART-3963", "title": "Tarjetas asociadas Fisica y Digital",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 7,
     "nota": "Pantalla Mis tarjetas: visualizacion TDC Fisica y Digital con estado; blocks SMART-4196,4197,4212"},
    {"smart_id": "SMART-3964", "title": "Gestion de Tarjeta de Credito Fisica (Originacion Canal Apolo)",
     "estado": "release", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 4,
     "nota": "Gestion TDC Fisica desde APOLO; bloqueo temporal/operativo; 7 subtareas Finalizadas"},
    {"smart_id": "SMART-3965", "title": "Encendido y apagado de TDC Fisica y Digital",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 4,
     "nota": "Switch on/off TDC Fisica y Digital; dialogo confirmacion; bloqueado por SMART-4361, 4530"},
    {"smart_id": "SMART-3966", "title": "Activacion de TDC Digital",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 2,
     "nota": "Flujo activacion TDC Digital via Token Digital; toaster + email notificacion; blocks SMART-4211"},
    {"smart_id": "SMART-4105", "title": "Notificacion activacion o eliminacion de Tarjeta Digital BanCoppel",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 2,
     "nota": "Email transaccional: activacion TDC Digital (asunto Activacion App BanCoppel) + eliminacion"},
    {"smart_id": "SMART-4176", "title": "Movimientos Convivencia TDC F&D",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-BALANCE-STATEMENT", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 3,
     "nota": "Historial movimientos ultimos 30 dias en pantalla Detalle TDC; bloqueado por SMART-4202, 4203"},
    {"smart_id": "SMART-4180", "title": "Detalle de Movimientos Convivencia TDC F&D",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-BALANCE-STATEMENT", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 2,
     "nota": "Pantalla detalle movimiento: monto, concepto, fecha, referencia, saldo, boton compartir"},
    {"smart_id": "SMART-4182", "title": "Visualizacion y aplicacion de montos de pago en Linea TDC",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-PAYMENT", "has_unity_r4_label": 0,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 3,
     "nota": "Calculo tiempo real: pago minimo, pago para no generar intereses, saldo a fecha; tablas antes/despues"},
    {"smart_id": "SMART-4219", "title": "Gestion de Tarjeta de Credito Digital (Originacion Canal Apolo)",
     "estado": "release", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 1,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 9,
     "nota": "Gestion TDC Digital desde APOLO; 8 semanas estimadas; bloquea multiples SMART; muchas subtareas"},
    {"smart_id": "SMART-4426", "title": "Gestion de Tarjeta de Credito Fisica (Originacion Legado)",
     "estado": "release", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 0,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 6,
     "nota": "Gestion TDC Fisica desde canal legado (dashboard); bloqueo temporal/operativo; 6 subtareas"},
    {"smart_id": "SMART-4478", "title": "Eliminacion de TDC Digital",
     "estado": "removed", "resolucion": "declined", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 0,
     "assignee": "Osvaldo Eduardo Espino Maldonado", "pages": 3,
     "nota": "Eliminacion TDC Digital (max 2/mes, Token Digital, email comprobante); Declined"},
    {"smart_id": "SMART-4531", "title": "Convivencia en Home de Cuentas TDC F&D",
     "estado": "backlog", "resolucion": "sin_resolver", "canal": "app",
     "capability_id": "CAP-CARD-LIFECYCLE", "has_unity_r4_label": 0,
     "assignee": None, "pages": 7,
     "nota": "Home de Cuentas: card TDC F&D con convivencia fisica/digital; botoneras dinamicas por banderas"},
]



# v1.0.0  --  Roadmap Accenture: HU_INVENTORY (76) + R4_INTEGRATIONS (18) + TRACK_RAG (5)
# Fuentes: Consolidacion y priorizacion_HUs_R4_v2.xlsx + Inventario de Integraciones_HUs_ R4_v1.0.xlsx + BCPL_R4 Roadmap_Remediaciones_v1_11082026.pptx

HU_INVENTORY = [  # 76 User Stories con scoring completo
    {
        "id": "HDU-SMART-R4-01",
        "track": "smartvista",
        "title": "Certificar layouts de maquila con proveedores.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 5,
        "num_pantallas": 0,
        "score_ponderado": 1.8,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-02",
        "track": "smartvista",
        "title": "Consultar inventario de tarjetas por sucursal.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 1,
        "score_ponderado": 2.3,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-03",
        "track": "smartvista",
        "title": "Calcular maquila con parámetros de abasto.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 2.2,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-04",
        "track": "smartvista",
        "title": "Ejecutar solicitud automatizada de maquila.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-05",
        "track": "smartvista",
        "title": "Ejecutar solicitud manual de maquila.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 1,
        "score_ponderado": 1.95,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-06",
        "track": "smartvista",
        "title": "Generar archivos seguros de maquila.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 2,
        "num_criterios": 3,
        "num_pantallas": 1,
        "score_ponderado": 2.25,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-07",
        "track": "smartvista",
        "title": "Dar seguimiento a estatus de lotes.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 2,
        "num_pantallas": 1,
        "score_ponderado": 2.15,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-08",
        "track": "smartvista",
        "title": "Controlar recepción y cancelación de lotes.",
        "producto": "TDC",
        "funcionalidad": "Automatización de Maquila",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 3,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.35,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-09",
        "track": "smartvista",
        "title": "Homologar conceptos de comisiones TDC.",
        "producto": "TDC",
        "funcionalidad": "Homologación omnicanal de comisiones",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.65,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-10",
        "track": "smartvista",
        "title": "Sincronizar nombres de comisiones en canales.",
        "producto": "TDC",
        "funcionalidad": "Homologación omnicanal de comisiones",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 2,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.15,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-11",
        "track": "smartvista",
        "title": "Incorporar reglas del autorizador BPC.",
        "producto": "TDC",
        "funcionalidad": "Reglas del autorizador (88 reglas)",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 1,
        "num_pantallas": 0,
        "score_ponderado": 1.9,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-12",
        "track": "smartvista",
        "title": "Parametrizar límite de saldo a favor.",
        "producto": "TDC",
        "funcionalidad": "Control de saldo a favor",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.85,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-13",
        "track": "smartvista",
        "title": "Validar límite  por línea de crédito.",
        "producto": "TDC",
        "funcionalidad": "Control de saldo a favor",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 2,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-14",
        "track": "smartvista",
        "title": "Excluir abonos bancarios del límite.",
        "producto": "TDC",
        "funcionalidad": "Control de saldo a favor",
        "moscow": "wont",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.9,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-15",
        "track": "smartvista",
        "title": "Mostrar mensaje por límite alcanzado.",
        "producto": "TDC",
        "funcionalidad": "Control de saldo a favor",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 1,
        "num_pantallas": 0,
        "score_ponderado": 1.7,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMARTVISTA-R4-16",
        "track": "smartvista",
        "title": "Configurar campañas de compras diferidas.",
        "producto": "TDC",
        "funcionalidad": "Diferemiento de compra a MCI",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-17",
        "track": "smartvista",
        "title": "Calcular oferta de compra diferida.",
        "producto": "TDC",
        "funcionalidad": "Diferemiento de compra a MCI",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.85,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-18",
        "track": "smartvista",
        "title": "Aplicar plan MCI/MSI a compra.",
        "producto": "TDC",
        "funcionalidad": "Diferemiento de compra a MCI",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.85,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-19",
        "track": "smartvista",
        "title": "Aplicar pagos anticipados a pagos fijos.",
        "producto": "TDC",
        "funcionalidad": "Pagos anticipados y Liquidaciones de compras diferidas",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 2,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.35,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-20",
        "track": "smartvista",
        "title": "Liquidar totalmente compras diferidas.",
        "producto": "TDC",
        "funcionalidad": "Pagos anticipados y Liquidaciones de compras diferidas",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 2,
        "num_criterios": 2,
        "num_pantallas": 0,
        "score_ponderado": 2.35,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-21",
        "track": "smartvista",
        "title": "Cancelar compras diferidas en línea.",
        "producto": "TDC",
        "funcionalidad": "Pagos anticipados y Liquidaciones de compras diferidas",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 2,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.35,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-01",
        "track": "cat",
        "title": "Alta producto 4900 en menú IVR.",
        "producto": "TDC",
        "funcionalidad": "Autoservicio TDC en IVR",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 2,
        "num_criterios": 3,
        "num_pantallas": 3,
        "score_ponderado": 2.35,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-02",
        "track": "cat",
        "title": "Rutar opciones IVR de atención TDC.",
        "producto": "TDC",
        "funcionalidad": "Autoservicio TDC en IVR",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 1,
        "num_criterios": 3,
        "num_pantallas": 3,
        "score_ponderado": 2.15,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-03",
        "track": "cat",
        "title": "Identificar cliente Apolo en CAT.",
        "producto": "TDC",
        "funcionalidad": "Identificación y autenticación en ICCAT",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Configuración",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 2,
        "score_ponderado": 1.5,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-04",
        "track": "cat",
        "title": "Mantener autenticación en misma llamada.",
        "producto": "TDC",
        "funcionalidad": "Identificación y autenticación en ICCAT",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Configuración",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.4,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-05",
        "track": "cat",
        "title": "Bloquear tarjeta por CAT.",
        "producto": "TDC",
        "funcionalidad": "Gestión de tarjetas desde CAT",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.35,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-06",
        "track": "cat",
        "title": "Desbloquear tarjeta por CAT.",
        "producto": "TDC",
        "funcionalidad": "Gestión de tarjetas desde CAT",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 3,
        "num_pantallas": 2,
        "score_ponderado": 2.45,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-07",
        "track": "cat",
        "title": "Actualizar históricos CAT por cambio de estatus.",
        "producto": "TDC",
        "funcionalidad": "Gestión de tarjetas desde CAT",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 2,
        "score_ponderado": 1.75,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-08",
        "track": "cat",
        "title": "Consultar saldos y movimientos del producto 4900 por IVR.",
        "producto": "TDC",
        "funcionalidad": "Autoservicio TDC en IVR",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 5,
        "num_pantallas": 3,
        "score_ponderado": 2.7,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-09",
        "track": "cat",
        "title": "Controlar datos inválidos e intentos fallidos en el IVR.",
        "producto": "TDC",
        "funcionalidad": "Autoservicio TDC en IVR",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Configuración",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 1.4,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-10",
        "track": "cat",
        "title": "Gestionar intentos fallidos de autenticación en ICCAT.",
        "producto": "TDC",
        "funcionalidad": "Identificación y autenticación en ICCAT",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Configuración",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 1,
        "score_ponderado": 1.5,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-11",
        "track": "cat",
        "title": "Consultar en CAT los productos y estatus de tarjetas del cliente.",
        "producto": "TDC",
        "funcionalidad": "Gestión de tarjetas desde CAT",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 1,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.15,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-CAT-R4-12",
        "track": "cat",
        "title": "Reportar robo, extravío, daño o vencimiento y cancelar el plástico desde CAT.",
        "producto": "TDC",
        "funcionalidad": "Gestión de tarjetas desde CAT",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 1,
        "num_criterios": 3,
        "num_pantallas": 2,
        "score_ponderado": 2.25,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SIWEB-R4-01",
        "track": "siweb",
        "title": "Adelantar pago parcial en SIWEB.",
        "producto": "TDC",
        "funcionalidad": "Operación de compras diferidas en sucursal",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SIWEB-R4-02",
        "track": "siweb",
        "title": "Liquidar compra diferida en SIWEB.",
        "producto": "TDC",
        "funcionalidad": "Operación de compras diferidas en sucursal",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SIWEB-R4-03",
        "track": "siweb",
        "title": "Cancelar compra diferida en SIWEB.",
        "producto": "TDC",
        "funcionalidad": "Operación de compras diferidas en sucursal",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SIWEB-R4-04",
        "track": "siweb",
        "title": "Registrar efectos contables de pagos fijos.",
        "producto": "TDC",
        "funcionalidad": "Operación de compras diferidas en sucursal",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SIWEB-R4-05",
        "track": "siweb",
        "title": "Validar el límite de saldo a favor en transacciones de caja.",
        "producto": "TDC",
        "funcionalidad": "Control de saldo a favor en caja",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 0,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-01",
        "track": "apolo",
        "title": "Actualizar la tasa ordinaria y el CAT en la oferta de producto.",
        "producto": "TDC",
        "funcionalidad": "Oferta de Producto",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 3,
        "score_ponderado": 2.45,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-03",
        "track": "apolo",
        "title": "Enviar por correo el contrato vigente al finalizar la firma.",
        "producto": "TDC",
        "funcionalidad": "Bienvenida",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 4,
        "score_ponderado": 1.7,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-04",
        "track": "apolo",
        "title": "Aplicar Coltrane en bloques iniciales y validación temprana (BB1-BB4).",
        "producto": "TDC",
        "funcionalidad": "Preparación / TyC / Validación de Teléfono / Validación del Cliente",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.8,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-05",
        "track": "apolo",
        "title": "Aplicar Coltrane en bloques de perfilamiento, riesgo y decisión (BB5-BB11).",
        "producto": "TDC",
        "funcionalidad": "Perfilamiento / Validación de Domicilio / KYC-PEP / PLD / Persona Vulnerable / Validación SIC / Paramétrico",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.8,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-06",
        "track": "apolo",
        "title": "Aplicar Coltrane en oferta, autenticación, expediente y cierre (BB12-BB17).",
        "producto": "TDC",
        "funcionalidad": "Oferta de Producto / Prueba de Vida / Solicitud de Servicios Digitales / Validación de Correo / Integración de Expediente Digital / Bienvenida",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.8,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-07",
        "track": "apolo",
        "title": "Capturar la declaración inicial de persona vulnerable.",
        "producto": "TDC",
        "funcionalidad": "Persona Vulnerable",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 9,
        "num_pantallas": 1,
        "score_ponderado": 2.9,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-08",
        "track": "apolo",
        "title": "Desplegar y guardar opciones de grupo prioritario cuando el prospecto responde Sí.",
        "producto": "TDC",
        "funcionalidad": "Persona Vulnerable",
        "moscow": "should",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 1,
        "score_ponderado": 2.9,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-10",
        "track": "apolo",
        "title": "Actualizar imagen de tarjeta y textos legales en pantallas clave.",
        "producto": "TDC",
        "funcionalidad": "Preparación/ Oferta de Producto / Bienvenida",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.8,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-13",
        "track": "apolo",
        "title": "Validar al solicitante contra listas negras en Perfilamiento / PLD.",
        "producto": "TDC",
        "funcionalidad": "Perfilamiento LISTAS NEGRAS PLD / Name Matching",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.35,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-14",
        "track": "apolo",
        "title": "Validar al familiar con cargo público contra listas negras (PEP).",
        "producto": "TDC",
        "funcionalidad": "KYC / PEP / Name Matching",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 4,
        "num_pantallas": 6,
        "score_ponderado": 1.55,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-16",
        "track": "apolo",
        "title": "Validar la referencia contra listas negras en Paramétrico.",
        "producto": "TDC",
        "funcionalidad": "PLD / PEP/ Name Matching/parametrico",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.35,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-17",
        "track": "apolo",
        "title": "Presentar la pantalla de términos con Contrato Múltiple y Servicios Digitales.",
        "producto": "TDC",
        "funcionalidad": "Integración Expediente digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 6,
        "num_pantallas": 8,
        "score_ponderado": 2.0,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-18",
        "track": "apolo",
        "title": "Permitir lectura de documentos y avance a firma electrónica.",
        "producto": "TDC",
        "funcionalidad": "Integración de Expediente Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 8,
        "score_ponderado": 1.85,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-19",
        "track": "apolo",
        "title": "Mostrar información de activación de servicios digitales mediante popup.",
        "producto": "TDC",
        "funcionalidad": "Integración de Expediente Digital",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 5,
        "num_pantallas": 8,
        "score_ponderado": 2.4,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-20",
        "track": "apolo",
        "title": "Integrar firma, alta de crédito, expediente digital y marcaje de visualización.",
        "producto": "TDC",
        "funcionalidad": "Integración Expediente Digital",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 8,
        "score_ponderado": 2.8,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-21",
        "track": "apolo",
        "title": "Aplicar KO automático cuando el prospecto usará dinero de otra persona.",
        "producto": "TDC",
        "funcionalidad": "PLD",
        "moscow": "could",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 3,
        "num_pantallas": 4,
        "score_ponderado": 2.65,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-23",
        "track": "apolo",
        "title": "Validar formato del número celular en Preparación y Validación de Teléfono.",
        "producto": "TDC",
        "funcionalidad": "Preparación / Validación de Teléfono",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 5,
        "num_pantallas": 0,
        "score_ponderado": 2.0,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-24",
        "track": "apolo",
        "title": "Validar titularidad del celular y disponibilidad por regla de 30 días.",
        "producto": "TDC",
        "funcionalidad": "Validación del teléfono",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 1.65,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-25",
        "track": "apolo",
        "title": "Cancelar vínculo previo del número cuando la originación concluye exitosamente.",
        "producto": "TDC",
        "funcionalidad": "Integracion de Expediente digital",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 8,
        "score_ponderado": 1.85,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-26",
        "track": "apolo",
        "title": "Gestionar reglas del OTP para validación telefónica.",
        "producto": "TDC",
        "funcionalidad": "Validación de telefono/ Validación SIC/Retomar solicitud",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 5,
        "num_pantallas": 0,
        "score_ponderado": 2.0,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-27",
        "track": "apolo",
        "title": "Asegurar máscara de SMS BanCoppel en mensajes OTP.",
        "producto": "TDC",
        "funcionalidad": "Validación de telefono/ Validación SIC/Retomar solicitud",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 0,
        "score_ponderado": 2.0,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-TDC-R4-34",
        "track": "apolo",
        "title": "Asignar sucursal corporativa parametrizable a la TDC BanCoppel.",
        "producto": "TDC",
        "funcionalidad": "Validación de domicilio / Intengración de expediente digital",
        "moscow": "should",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 0,
        "num_criterios": 2,
        "num_pantallas": 0,
        "score_ponderado": 1.5,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    # ── v1.1.0: 3 User Stories Must de "Encendido y Apagado TDC Física y Digital".
    # Estas filas existen en el xlsx pero SIN valor en la columna "ID HU": el cargador
    # anterior las descartaba. ID sintético APP-ENC-nn. Sin ticket Jira en la fuente.
    # El deck del 11-ago-2026 confirma que APP tiene 18 User Stories (15 Must, 1 Could, 2 Won't) y
    # su cronograma las agrupa como "Encendido y Apagado TDC F&D (3HUs 100% M)".
    # Las 3 no tienen fecha de implementación confirmada por el impacto en cascada del
    # retraso de las 3 primeras User Stories del track (dependencia de diseño UX, ambientes y
    # enrolamiento del equipo).
    {
        "id": "APP-ENC-01",
        "track": "app",
        "title": "Encendido, Apagado y Bloqueo Operativo - Tarjeta de Crédito Digital (Originación Apolo)",
        "producto": "TDC",
        "funcionalidad": "Encendido y Apagado TDC Física y Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 7,
        "num_pantallas": 2,
        "score_ponderado": 1.9,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx (fila sin ID HU; sin ticket Jira)"
    },
    {
        "id": "APP-ENC-02",
        "track": "app",
        "title": "Encendido, Apagado y Bloqueo Operativo - Tarjeta de Crédito Física (Originación Apolo)",
        "producto": "TDC",
        "funcionalidad": "Encendido y Apagado TDC Física y Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 6,
        "num_pantallas": 2,
        "score_ponderado": 1.9,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx (fila sin ID HU; sin ticket Jira)"
    },
    {
        "id": "APP-ENC-03",
        "track": "app",
        "title": "Encendido, Apagado y Bloqueo Operativo - Tarjeta de Crédito Física (Originación Legado)",
        "producto": "TDC",
        "funcionalidad": "Encendido y Apagado TDC Física y Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": None,   # la fila del xlsx no trae criterios para esta User Story
        "num_pantallas": 2,
        "score_ponderado": 1.45,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx (fila sin ID HU; sin ticket Jira)"
    },
    {
        "id": "SMART-4219",
        "track": "app",
        "title": "Gestión de Tarjeta de Crédito Digital - Canal Apolo",
        "producto": "TDC",
        "funcionalidad": "Gestión de Tarjeta de Crédito Digital - Canal Apolo",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 12,
        "num_pantallas": 1,
        "score_ponderado": 2.3,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-3964",
        "track": "app",
        "title": "Gestión de Tarjeta de Crédito Física - Canal Apolo",
        "producto": "TDC",
        "funcionalidad": "Gestión de Tarjeta de Crédito Física - Canal Apolo",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 1,
        "score_ponderado": 2.3,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4226",
        "track": "app",
        "title": "Gestión de Tarjeta de Crédito Física - Modelo Legado",
        "producto": "TDC",
        "funcionalidad": "Gestión de Tarjeta de Crédito Física - Modelo Legado",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 10,
        "num_pantallas": 1,
        "score_ponderado": 2.3,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-3963",
        "track": "app",
        "title": "Tarjetas Asociadas Física y Digital",
        "producto": "TDC",
        "funcionalidad": "Tarjetas Asociadas Física y Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 24,
        "num_pantallas": 1,
        "score_ponderado": 2.3,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-3966",
        "track": "app",
        "title": "Activación de TDC Digital",
        "producto": "TDC",
        "funcionalidad": "Activación de TDC Digital",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 0,
        "num_criterios": 4,
        "num_pantallas": 3,
        "score_ponderado": 2.0,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4531",
        "track": "app",
        "title": "Convivencia en Home de Cuentas TDC F&D",
        "producto": "TDC",
        "funcionalidad": "Convivencia en Home de Cuentas TDC F&D",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 2,
        "num_pantallas": 1,
        "score_ponderado": 2.15,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-3962",
        "track": "app",
        "title": "Detalle de crédito convivencia TDC F&D",
        "producto": "TDC",
        "funcionalidad": "Detalle de crédito convivencia TDC F&D",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 7,
        "num_pantallas": 1,
        "score_ponderado": 2.6,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "PTCSF-6267",
        "track": "app",
        "title": "Actualizar operaciones TDC Digital en una misma sesión",
        "producto": "TDC",
        "funcionalidad": "Actualizar operaciones TDC Digital en una misma sesión",
        "moscow": "must",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 0,
        "num_criterios": 1,
        "num_pantallas": 0,
        "score_ponderado": 1.9,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4182",
        "track": "app",
        "title": "Visualización y aplicación de montos de pago en Línea TDC",
        "producto": "TDC",
        "funcionalidad": "Visualización y aplicación de montos de pago en Línea TDC",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.05,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4280",
        "track": "app",
        "title": "Gestión del campo \"Otra cantidad\" basado en el límite de saldo a favor",
        "producto": "TDC",
        "funcionalidad": "Gestión del campo \"Otra cantidad\" basado en el límite de saldo a favor",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.05,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4183",
        "track": "app",
        "title": "Límite de saldo a favor para pago de TDC en la aplicación móvil",
        "producto": "TDC",
        "funcionalidad": "Límite de saldo a favor para pago de TDC en la aplicación móvil",
        "moscow": "must",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.05,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4176",
        "track": "app",
        "title": "Movimientos Convivencia TDC F&D",
        "producto": "TDC",
        "funcionalidad": "Movimientos Convivencia TDC F&D",
        "moscow": "must",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Componentes existentes reutilizables >80%",
        "num_integraciones": 1,
        "num_criterios": 2,
        "num_pantallas": 1,
        "score_ponderado": 2.05,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4180",
        "track": "app",
        "title": "Detalle de Movimientos Convivencia TDC F&D",
        "producto": "TDC",
        "funcionalidad": "Detalle de Movimientos Convivencia TDC F&D",
        "moscow": "wont",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 7,
        "num_pantallas": 1,
        "score_ponderado": 2.6,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4278",
        "track": "app",
        "title": "Eliminación de TDC Digital",
        "producto": "TDC",
        "funcionalidad": "Eliminación de TDC Digital",
        "moscow": "wont",
        "tipo_solucion": "Solución e Integración",
        "impacto_solucion": "Desarrollo",
        "reusabilidad": "Nuevo Desarrollo <20%",
        "num_integraciones": 1,
        "num_criterios": 7,
        "num_pantallas": 2,
        "score_ponderado": 2.6,
        "complejidad": "Alta",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "SMART-4105",
        "track": "app",
        "title": "Notificación de activación Tarjeta Digital BanCoppel",
        "producto": "TDC",
        "funcionalidad": "Notificación activación o elimnación de Tarjeta Digital BanCoppel",
        "moscow": "could",
        "tipo_solucion": "Integración",
        "impacto_solucion": "No Aplica",
        "reusabilidad": "No Aplica",
        "num_integraciones": 1,
        "num_criterios": 0,
        "num_pantallas": 0,
        "score_ponderado": 1.05,
        "complejidad": "Baja",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
    {
        "id": "HDU-SMART-R4-22",
        "track": "smartvista",
        "title": "Disposición de efectivo - APP",
        "producto": "TDC",
        "funcionalidad": "Disposición de efectivo - APP",
        "moscow": "should",
        "tipo_solucion": "Solución",
        "impacto_solucion": "Desarrollo + Configuración",
        "reusabilidad": "Reutilización parcial 30-70%",
        "num_integraciones": 0,
        "num_criterios": 1,
        "num_pantallas": 0,
        "score_ponderado": 1.7,
        "complejidad": "Media",
        "source_doc": "Consolidacion y priorizacion_HUs_R4_v2.xlsx"
    },
]

R4_INTEGRATIONS = [  # 18 integraciones R4
    {
        "id": "ISV01",
        "hu_id": "HDU-SMART-R4-06",
        "track": "smartvista",
        "hu_title": "Generar archivos seguros de maquila.",
        "nombre": "Interfaz temporal de maquila #6",
        "descripcion": "Descarga de archivo de la nube a on premise",
        "sistema_origen": "AWS",
        "sistema_destino": "OLTP-Informix",
        "tipo": "Batch",
        "formato": "PGP",
        "frecuencia": "Diaria/EOD",
        "complejidad": "Baja",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV02",
        "hu_id": "HDU-SMART-R4-06",
        "track": "smartvista",
        "hu_title": "Generar archivos seguros de maquila.",
        "nombre": "AFT",
        "descripcion": "Transferencia de archivo de maquila",
        "sistema_origen": "OLTP-Informix",
        "sistema_destino": "Connect Direct",
        "tipo": "Batch",
        "formato": "PGP",
        "frecuencia": "Diaria/EOD",
        "complejidad": "Baja",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV03",
        "hu_id": "HDU-SMART-R4-08",
        "track": "smartvista",
        "hu_title": "Controlar recepción y cancelación de lotes.",
        "nombre": "Consulta de lotes",
        "descripcion": "Consulta de tarjetas mediante número de sucursal y lote generado",
        "sistema_origen": "SIWEB",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Diaria/EOD",
        "complejidad": "Baja",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV04",
        "hu_id": "HDU-SMART-R4-10",
        "track": "smartvista",
        "hu_title": "Sincronizar nombres de comisiones en canales.",
        "nombre": "Visualización de nombres normativos - SIWEB",
        "descripcion": "Homologación de comisiones de SmartVista a SIWEB",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "SIWEB",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Diaria/EOD",
        "complejidad": "Media",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV05",
        "hu_id": "HDU-SMART-R4-10",
        "track": "smartvista",
        "hu_title": "Sincronizar nombres de comisiones en canales.",
        "nombre": "Visualización de nombres normativos - APP",
        "descripcion": "Homologación de comisiones de SmartVista a APP",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "APP",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Diaria/EOD",
        "complejidad": "Media",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT01",
        "hu_id": "HDU-CAT-R4-01",
        "track": "cat",
        "hu_title": "Alta producto 4900 en menú IVR.",
        "nombre": "Consulta de clientes SMARTVISTA",
        "descripcion": "Consultar el número de cliente capturado en el nuevo core de SMARTVISTA",
        "sistema_origen": "IVR",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT02",
        "hu_id": "HDU-CAT-R4-01",
        "track": "cat",
        "hu_title": "Alta producto 4900 en menú IVR.",
        "nombre": "Consulta de cliente por cuenta SMARTVISTA",
        "descripcion": "Consultar los datos del cliente por el número de cuenta en el nuevo core de SMARTVISTA",
        "sistema_origen": "IVR",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT03",
        "hu_id": "HDU-CAT-R4-02",
        "track": "cat",
        "hu_title": "Rutar opciones IVR de atención TDC.",
        "nombre": "Canalizar al cliente SMARTVISTA con un ejecutivo",
        "descripcion": "Canalizar al cliente SMARTVISTA con un ejecutivo",
        "sistema_origen": "IVR - Robot",
        "sistema_destino": "IVR - CC",
        "tipo": "Evento",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Baja",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT04",
        "hu_id": "HDU-CAT-R4-08",
        "track": "cat",
        "hu_title": "Consultar saldos y movimientos del producto 4900 por IVR.",
        "nombre": "Consulta de saldos y movimientos en SMARTVISTA",
        "descripcion": "Consulta de saldos y movimientos en SMARTVISTA a través  de IVR",
        "sistema_origen": "IVR",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Alta",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT05",
        "hu_id": "HDU-CAT-R4-05",
        "track": "cat",
        "hu_title": "Bloquear tarjeta por CAT.",
        "nombre": "Bloqueo de tarjeta SMARTVISTA",
        "descripcion": "Habilitación del bloqueo de tarjeta física y digital de SMARTVISTA a través de CAT",
        "sistema_origen": "ICCAT",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT06",
        "hu_id": "HDU-CAT-R4-06",
        "track": "cat",
        "hu_title": "Desbloquear tarjeta por CAT.",
        "nombre": "Desbloqueo de tarjeta SMARTVISTA",
        "descripcion": "Habilitación del desbloqueo de tarjeta física y digital de SMARTVISTA a través de CAT",
        "sistema_origen": "ICCAT",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ICAT07",
        "hu_id": "HDU-CAT-R4-11",
        "track": "cat",
        "hu_title": "Consultar en CAT los productos y estatus de tarjetas del cliente.",
        "nombre": "Consultar en CAT los productos y estatus de tarjetas del cliente SMARTVISTA",
        "descripcion": "Consultar la información de las tarjetas desde SMARTVISTA",
        "sistema_origen": "ICCAT",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "IAPP01",
        "hu_id": "SMART-3962",
        "track": "app",
        "hu_title": "Detalle de crédito convivencia TDC F&D",
        "nombre": "CAMBIOS en detalle de TDC Rec_retrieveCreditCardStatement",
        "descripcion": "Envío de detalle de TDC - cuenta, saldos, intereses",
        "sistema_origen": "APP",
        "sistema_destino": "SMARTVISTA",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV06",
        "hu_id": "HDU-SMART-R4-19",
        "track": "smartvista",
        "hu_title": "Aplicar pagos anticipados a pagos fijos.",
        "nombre": "GetDPP",
        "descripcion": "Selección de transacciones",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "SIWEB",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "ISV07",
        "hu_id": "HDU-SMART-R4-19",
        "track": "smartvista",
        "hu_title": "Aplicar pagos anticipados a pagos fijos.",
        "nombre": "Clearing Operation",
        "descripcion": "Envío de Pago Anticipado",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "SIWEB",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "IAPP02",
        "hu_id": "SMART-4183",
        "track": "app",
        "hu_title": "Límite de saldo a favor para pago de TDC en la aplicación móvil",
        "nombre": "Realiza el pago de TDC Rec_executeCardPaymentTransaction",
        "descripcion": "Realiza el pago de TDC en APP",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "APP",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Alta",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "IAPP03",
        "hu_id": "SMART-4176",
        "track": "app",
        "hu_title": "Movimientos Convivencia TDC F&D",
        "nombre": "Consulta de movimientos Rec_RetrieveAccountTransaction",
        "descripcion": "Consulta de movimientos en APP",
        "sistema_origen": "SMARTVISTA",
        "sistema_destino": "APP",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 1,
        "estado": "Modificar",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
    {
        "id": "IAPP05",
        "hu_id": "SMART-4105",
        "track": "app",
        "hu_title": "Notificación de activación Tarjeta Digital BanCoppel",
        "nombre": "Notificación activación de Tarjeta Digital BanCoppel",
        "descripcion": "Notificación activación de Tarjeta Digital BanCoppel por acción desde APP",
        "sistema_origen": "APP",
        "sistema_destino": "CES",
        "tipo": "API",
        "formato": "",
        "frecuencia": "Tiempo real",
        "complejidad": "Media",
        "existe_hoy": 0,
        "estado": "Nueva",
        "source_doc": "Inventario de Integraciones_HUs_ R4_v1.0.xlsx"
    },
]

TRACK_RAG = [  # 5 tracks RAG desde PPTX 11-ago-2026
    {
        "track": "smartvista",
        "rag_color": "yellow",
        "hu_total": 22,
        "hu_must": 11,
        "hu_should": 10,
        "hu_could": 0,
        "hu_wont": 1,
        "integraciones_count": 7,
        "rag_general": "CONFIRMADO 2026-08-19: amarillo en las tres dimensiones. Maquila y Homologacion de Comisiones omnicanal no cierran antes del 15-Oct.",
        "rag_solucion": "18 User Stories con fechas comprometidas. Diferimiento MCI al 27-Nov sin impacto en SIT.",
        "rag_integraciones": "Inventario pendiente de Validar y completar con APIficacion y SIWEB. DTMs Comisiones sin fecha.",
        "tipo_solucion_detail": "15 Solucion + 6 Solucion+Integracion + 1 Integracion",
        "impacto_solucion_detail": "3 Desarrollo + 18 Desarrollo+Config.",
        "complejidad_detail": "4 Alta + 16 Media + 2 Baja",
        "source_date": "2026-08-11"
    },
    {
        "track": "app",
        "rag_color": "yellow",
        "hu_total": 18,
        "hu_must": 15,
        "hu_should": 0,
        "hu_could": 1,
        "hu_wont": 2,
        "integraciones_count": 4,
        "rag_general": "CORREGIDO 2026-08-19: RAG GENERAL = AMARILLO, no rojo. El rojo aplica solo a la dimension INTEGRACIONES. El deck 11-ago tiene 3 semaforos por track y accent2 del tema = F0D224 (amarillo). 6 User Stories Must cierran implementacion 6-20 Nov — riesgo directo sobre SIT y Go-live enero.",
        "rag_solucion": "10 User Stories analisis completado. 8 cierran ago-sep. 2 User Stories sin fechas de implementacion confirmadas.",
        "rag_integraciones": "4 integraciones API identificadas. Inventario en consolidacion. Sin detalles tecnicos de volumenes/tiempos.",
        "tipo_solucion_detail": "10 Solucion + 4 Solucion+Integracion + 4 Integracion",
        "impacto_solucion_detail": "18 Desarrollo",
        "complejidad_detail": "7 Alta + 6 Media + 5 Baja",
        "source_date": "2026-08-11"
    },
    {
        "track": "cat",
        "rag_color": "red",
        "hu_total": 12,
        "hu_must": 9,
        "hu_should": 3,
        "hu_could": 0,
        "hu_wont": 0,
        "integraciones_count": 7,
        "rag_general": "CONFIRMADO 2026-08-19: unico track ROJO en las TRES dimensiones. Doble bloqueo: proveedor sin contratar y DTMs sin responsable confirmado.",
        "rag_solucion": "Cero fechas de implementacion. Proveedor entra ~mid-Sep con 1 mes onboarding — inicio real coincide con SIT.",
        "rag_integraciones": "Sin fechas ni responsable de DTMs confirmado. Pendiente trazabilidad completa de integraciones.",
        "tipo_solucion_detail": "5 Solucion + 7 Solucion+Integracion",
        "impacto_solucion_detail": "3 Desarrollo + 4 Configuracion + 5 Desarrollo+Config.",
        "complejidad_detail": "4 Alta + 4 Media + 4 Baja",
        "source_date": "2026-08-11"
    },
    {
        "track": "siweb",
        "rag_color": "yellow",
        "hu_total": 5,
        "hu_must": 0,
        "hu_should": 5,
        "hu_could": 0,
        "hu_wont": 0,
        "integraciones_count": None,
        "rag_general": "CORREGIDO 2026-08-19: GENERAL y SOLUCION amarillo; ROJO en INTEGRACIONES. Sin fechas de implementacion confirmadas. 10 semanas construccion desde 18-Ago llegan al 29-Oct — 2 sem. despues del cierre.",
        "rag_solucion": "Cero fechas de implementacion. APIficacion entrega DTMs el 18-Ago — a partir de ahi se confirman fechas.",
        "rag_integraciones": "Numero de integraciones pendiente de confirmar con APIficacion. Sesion tecnica acordada.",
        "tipo_solucion_detail": "5 Solucion+Integracion",
        "impacto_solucion_detail": "5 Desarrollo+Configuracion",
        "complejidad_detail": "Pendiente por numero de integraciones faltante",
        "source_date": "2026-08-11"
    },
    {
        "track": "apolo",
        "rag_color": "yellow",
        "hu_total": 22,
        "hu_must": 11,
        "hu_should": None,
        "hu_could": None,
        "hu_wont": None,
        "integraciones_count": None,
        "rag_general": "SIN FUENTE 2026-08-19: el deck 11-ago NO tiene lamina RAG de Apolo ni de Cobranza, solo SmartVista, APP, CAT y SIWEB. Este RAG es inferencia nuestra, sin respaldo documental. NO presentarlo como dato del programa. Track incluido en roadmap — detalle por User Story en Inventario User Stories (22 User Stories).",
        "rag_solucion": "9 User Stories candidatas a simplificacion segun PPTX slide 7 (diferir a R4.1).",
        "rag_integraciones": "Inventario en consolidacion con APIficacion.",
        "tipo_solucion_detail": None,
        "impacto_solucion_detail": None,
        "complejidad_detail": None,
        "source_date": "2026-08-11"
    },
    {
        "track": "cobranza",
        "rag_color": "red",
        "hu_total": 45,
        "hu_must": None,
        "hu_should": None,
        "hu_could": None,
        "hu_wont": None,
        "integraciones_count": 0,
        "rag_general": "ROJO por opacidad total 2026-08-20: track completamente opaco — sin backlog compartido, sin User Stories formalizadas, sin integraciones documentadas. RISK-UNITY-R06 VENCIDO. ACT-005 BREACH desde 07-ago (13 dias). Impacta 3 User Stories dependientes en App y CAT.",
        "rag_solucion": "Estimado 45 User Stories (rango 37-50, en consolidacion). Proveedor identificado pero backlog sin compartir con Accenture. Pentest nov 15-20 entra en conflicto con SIT.",
        "rag_integraciones": "Sin inventario de integraciones disponible. Solo cargas de datos identificadas (0 integraciones API formalizadas).",
        "tipo_solucion_detail": None,
        "impacto_solucion_detail": None,
        "complejidad_detail": None,
        "source_date": "2026-08-20"
    },
    {
        "track": "apificacion",
        "rag_color": "yellow",
        "hu_total": None,
        "hu_must": None,
        "hu_should": None,
        "hu_could": None,
        "hu_wont": None,
        "integraciones_count": None,
        "rag_general": "AMARILLO 2026-08-20: track transversal desbloqueador critico. DTMs entregados "
                       "18-Ago para SIWEB. APIs SmartVista BPC pendientes de certificacion — SIWEB "
                       "bloqueado hasta entrega. Sin inventario formal de integraciones publicado aun.",
        "rag_solucion": "Accenture interna — sin proveedor externo. Opera con DTMs y entregables "
                        "tecnicos. Sin User Stories formales en el inventario.",
        "rag_integraciones": "Inventario en consolidacion. Critico para SIWEB (bloqueado) y CAT "
                             "(sin contrato). Sesion tecnica acordada con equipo SIWEB 18-Ago.",
        "tipo_solucion_detail": None,
        "impacto_solucion_detail": None,
        "complejidad_detail": None,
        "source_date": "2026-08-20"
    },
    {
        "track": "programa",
        "rag_color": "red",
        "hu_total": 87,
        "hu_must": 46,
        "hu_should": 28,
        "hu_could": None,
        "hu_wont": None,
        "integraciones_count": 18,
        "rag_general": "ROJO 2026-08-20: avance global 21.19% vs 60.58% esperado (corte 17-ago). "
                       "9 de 11 actividades retrasadas. CAT sin proveedor, SIWEB bloqueado, "
                       "Cobranza opaco. Riesgo go-live enero 2027 elevado.",
        "rag_solucion": "Tres tracks criticos: CAT (rojo), Cobranza (rojo), SIWEB (bloqueado). "
                        "SmartVista R4 y App en amarillo. Apificacion como desbloqueador transversal.",
        "rag_integraciones": "18 integraciones R4: 9 nuevas, 9 modificar. Inventario en validacion "
                             "con APIficacion. Pendiente trazabilidad completa cross-track.",
        "tipo_solucion_detail": None,
        "impacto_solucion_detail": None,
        "complejidad_detail": None,
        "source_date": "2026-08-20"
    },
]

# â"€â"€ Funciones de carga semÃ¡ntica â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€

def load_semantic_layer(con: sqlite3.Connection) -> None:
    """Carga la capa semÃ¡ntica v0.6.1: conecta cada capability con sus dimensiones
    de vendor, SLOs, plan de pruebas, compliance, PRR, routing y stakeholders
    (SMEs ACN + arquitectos del programa + owners BanCoppel)."""

    def _upsert(table: str, rows: list[dict]) -> None:
        if not rows:
            return
        cols = list(rows[0].keys())
        ph   = ", ".join("?" * len(cols))
        sql  = (f"INSERT OR REPLACE INTO {table} ({', '.join(cols)}) VALUES ({ph})")
        con.executemany(sql, [tuple(r.get(c) for c in cols) for r in rows])

    _upsert("capability_vendors",       CAPABILITY_VENDORS)
    _upsert("capability_slos",          CAPABILITY_SLOS)
    _upsert("capability_test_plan",     CAPABILITY_TEST_PLAN)
    _upsert("capability_compliance",    CAPABILITY_COMPLIANCE)
    _upsert("capability_prr",           CAPABILITY_PRR)
    _upsert("capability_routing",       CAPABILITY_ROUTING)
    _upsert("capability_stakeholders",  CAPABILITY_STAKEHOLDERS)

    # Reconstruir FTS de stakeholders (tabla standalone, no content-based)
    con.execute("DELETE FROM stakeholders_fts")
    con.execute("""
        INSERT INTO stakeholders_fts(id, name, capability_id, stakeholder_type, organization, contact_note)
        SELECT id, name, capability_id, stakeholder_type, organization, contact_note
        FROM   capability_stakeholders
    """)
    con.commit()

    n_v  = len(CAPABILITY_VENDORS)
    n_s  = len(CAPABILITY_SLOS)
    n_t  = len(CAPABILITY_TEST_PLAN)
    n_c  = len(CAPABILITY_COMPLIANCE)
    n_p  = len(CAPABILITY_PRR)
    n_r  = len(CAPABILITY_ROUTING)
    n_st = len(CAPABILITY_STAKEHOLDERS)
    print(f"  Capa semÃ¡ntica: vendors={n_v} slos={n_s} testplan={n_t} "
          f"compliance={n_c} prr={n_p} routing={n_r} stakeholders={n_st}")


def semantic_summary(con: sqlite3.Connection) -> None:
    """Imprime un resumen de la vista capability_360  --  el estado completo del programa."""

    print("\n  === capability_360: estado cross-dimensional ===")
    rows = con.execute("""
        SELECT
            id,
            coverage_status,
            vendor_name,
            vendor_contract,
            slo_availability_pct,
            sit_status,
            cnbv_art76 || '/' || pci_dss_scope || '/' || condusef_scope AS compliance_flags,
            prr_approved,
            prr_blocker,
            acn_sme,
            program_architect
        FROM capability_360
        ORDER BY
            CASE coverage_status
                WHEN 'not_covered' THEN 0
                WHEN 'tbd'         THEN 1
                WHEN 'partial'     THEN 2
                WHEN 'configurable'THEN 3
                WHEN 'native'      THEN 4
                ELSE 5
            END,
            id
    """).fetchall()

    hdr = f"  {'Capability':32s}  {'Coverage':12s}  {'SIT':10s}  {'PRR':5s}  {'ACN SME':30s}  {'Architect'}"
    print(hdr)
    print("  " + "-" * 115)
    for r in rows:
        cov   = r[1] or "?"
        sit   = r[5] or "?"
        prr   = "ok" if r[7] else "âŒ"
        sme   = (r[9]  or " -- ")[:30]
        arch  = (r[10] or " -- ")[:25]
        line  = f"  {r[0]:32s}  {cov:12s}  {sit:10s}  {prr:5s}  {sme:30s}  {arch}"
        print(line)

    # Totales rÃ¡pidos
    blocked_sit   = sum(1 for r in rows if r[5] == "blocked")
    pending_prr   = sum(1 for r in rows if r[7] == 0)
    no_vendor     = sum(1 for r in rows if r[3] == "pending")
    pci_scope     = sum(1 for r in rows if r[6] and r[6].split("/")[1] == "1")
    with_sme      = sum(1 for r in rows if r[9])
    with_architect= sum(1 for r in rows if r[10])

    print(f"\n  SIT bloqueado: {blocked_sit}/14 capabilities")
    print(f"  PRR pendiente: {pending_prr}/14 capabilities")
    print(f"  Vendor sin contratar: {no_vendor} capabilities")
    print(f"  Scope PCI-DSS: {pci_scope} capabilities")
    print(f"  Con SME ACN asignado: {with_sme}/14 capabilities")
    print(f"  Con arquitecto asignado: {with_architect}/14 capabilities")

    # Resumen stakeholders por tipo
    stk_counts = con.execute("""
        SELECT stakeholder_type, raci_role, COUNT(*) AS n
        FROM   capability_stakeholders
        GROUP BY stakeholder_type, raci_role
        ORDER BY stakeholder_type, raci_role
    """).fetchall()
    if stk_counts:
        print("\n  === Stakeholders por tipo y RACI ===")
        for row in stk_counts:
            print(f"  {row[0]:20s}  {row[1]:12s}  {row[2]} registros")


def load_track_analysis(con: sqlite3.Connection) -> None:
    """Carga anÃ¡lisis por track desde sesiones de trabajo User Stories (3-7 agosto 2026)."""
    cols = list(TRACK_ANALYSIS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO track_analysis ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in TRACK_ANALYSIS])
    con.commit()
    hu_total = sum(r["hu_total"] or 0 for r in TRACK_ANALYSIS)
    print(f"  track_analysis    : {len(TRACK_ANALYSIS)} tracks  |  User Stories totales confirmados: {hu_total} (cobranza y apificacion = sin confirmar)")


def load_plan_progress(con: sqlite3.Connection) -> None:
    """Carga avance del Plan de Trabajo (corte 16-ago-2026)."""
    cols = list(PLAN_PROGRESS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO plan_progress ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in PLAN_PROGRESS])
    con.commit()
    delayed = sum(1 for r in PLAN_PROGRESS if r["status"] == "delayed")
    on_time = sum(1 for r in PLAN_PROGRESS if r["status"] == "on_time")
    global_row = next((r for r in PLAN_PROGRESS if r["id"] == "PP-GLOBAL"), None)
    if global_row:
        print(f"  plan_progress     : {len(PLAN_PROGRESS)} actividades  |  "
              f"Global: {global_row['pct_real']}% real vs {global_row['pct_expected']}% esperado  |  "
              f"Retrasadas: {delayed}  |  A tiempo: {on_time}")


# â"€â"€ Main â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€â"€


def load_program_systems(con) -> None:
    for s in PROGRAM_SYSTEMS:
        con.execute(
            """INSERT OR REPLACE INTO program_systems
                (id, name, vendor, togaf_type, togaf_state, togaf_abb, role_in_r4, status, notes)
                VALUES (:id, :name, :vendor, :togaf_type, :togaf_state, :togaf_abb, :role_in_r4, :status, :notes)""",
            s,
        )
    con.commit()
    print(f"  program_systems   : {len(PROGRAM_SYSTEMS)} sistemas TOGAF")


def load_it_capabilities(con) -> None:
    for cap in IT_CAPABILITIES:
        con.execute(
            """INSERT OR REPLACE INTO it_capabilities
                (id, name, description, category, owner_component,
                 owner_name, maturity_current, maturity_target,
                 next_action, next_action_due, next_action_owner)
               VALUES (:id, :name, :description, :category, :owner_component,
                 :owner_name, :maturity_current, :maturity_target,
                 :next_action, :next_action_due, :next_action_owner)""",
            cap,
        )
    con.commit()
    print(f"  it_capabilities   : {len(IT_CAPABILITIES)} capacidades IT")


# ── SDLC data por sistema (v1.5.0) ───────────────────────────────────────────
# Fuente canonica: bloque SYSTEM_SDLC en build-portal.py (ya corregido).
# Confirmaciones de DTs:
#   - GoLive todos los sistemas = 2027-01 (MS-UNITY-006 dt-cronograma.md)
#   - SIT SmartVista = 2026-10 (no 2026-09)
#   - sdlc_status red/yellow/green segun DTs: red=proveedor sin contratar o
#     riesgo critico; yellow=riesgo alto con workaround; green=sin riesgos activos
#   - exclude_from_portal=1 para sistemas sin User Stories en R4:
#     informix, controlm, eglobal, connect-direct
SYSTEM_SDLC_DATA = {
    "informix": {
        "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "sdlc_summary": "Core bancario actual (AIX/POWER). Sistema de registro hasta el cutover. Fuente de 10,144 SPs y 11,391 reglas de negocio a migrar a Transact.",
        "exclude_from_portal": 1,
        "milestones": [
            {"seq": 1, "label": "Sistema en produccion (baseline)",      "target_date": "< 2024",    "status": "done"},
            {"seq": 2, "label": "Extraccion reglas GemCog v1.5.0",       "target_date": "2026-08-20","status": "done"},
            {"seq": 3, "label": "Parallel-run Informix + Transact",      "target_date": "2026-Q4",   "status": "pending"},
            {"seq": 4, "label": "Cutover final — Informix a DEPRECATE",  "target_date": "2027-Q1",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-CARD-LIFECYCLE","CAP-CREDIT-LIMIT","CAP-PAYMENT","CAP-BALANCE-STATEMENT",
            "CAP-FEE-COMMISSION","CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE",
            "CAP-CUSTOMER-PROFILE","CAP-ONBOARDING-DIGITAL","CAP-DEFERRED-PURCHASE",
        ],
    },
    "transact": {
        "sdlc_phase": "BUILD", "sdlc_progress": 40, "sdlc_status": "yellow",
        "sdlc_summary": "Plataforma core bancario destino (Temenos Transact). Configuracion TDC P4900 completa. Pendiente SIT integrado con SmartVista y UAT de contabilidad GL.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "Contrato Temenos firmado",              "target_date": "2026-01",   "status": "done"},
            {"seq": 2, "label": "Configuracion productos TDC P4900",     "target_date": "2026-08",   "status": "done"},
            {"seq": 3, "label": "SIT Transact-SmartVista-eGlobal",       "target_date": "2026-10",   "status": "pending"},
            {"seq": 4, "label": "UAT contabilidad GL end-to-end",        "target_date": "2026-11",   "status": "pending"},
            {"seq": 5, "label": "GoLive R4",                             "target_date": "2027-01",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-ONBOARDING-DIGITAL","CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION",
            "CAP-ERROR-CATALOG","CAP-CUSTOMER-PROFILE","CAP-COLLECTIONS-ENGINE",
        ],
    },
    "smartvista": {
        "sdlc_phase": "BUILD", "sdlc_progress": 55, "sdlc_status": "red",
        "sdlc_summary": "Motor de gestion de tarjetas TDC P4900 (BPC Banking Technologies). 2 DTMs sin cobertura: DPP modulo no contratado (sin decision de remediacion) y BYU0039 abierto en investigacion.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "Contrato BPC firmado",                  "target_date": "2026-01",   "status": "done"},
            {"seq": 2, "label": "22 User Stories SmartVista catalogados", "target_date": "2026-08-01","status": "done"},
            {"seq": 3, "label": "Correccion macro APP-MF-02 (QA)",       "target_date": "2026-08-20","status": "done"},
            {"seq": 4, "label": "SIT SmartVista-Transact-eGlobal",       "target_date": "2026-10",   "status": "pending"},
            {"seq": 5, "label": "UAT tarjeta de credito end-to-end",     "target_date": "2026-11",   "status": "pending"},
            {"seq": 6, "label": "GoLive — CMS/Intercard a DEPRECATE",   "target_date": "2027-01",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-CARD-LIFECYCLE","CAP-PAYMENT","CAP-DEFERRED-PURCHASE","CAP-CARD-MANUFACTURING",
            "CAP-OVERPAYMENT","CAP-AUTHORIZATION","CAP-FEE-COMMISSION","CAP-ERROR-CATALOG",
        ],
    },
    "apolo": {
        "sdlc_phase": "BUILD", "sdlc_progress": 45, "sdlc_status": "red",
        "sdlc_summary": "Canal digital (Appwhere) para oferta y originacion de TDC. Issue I03: celula sin contratar (abierto 3+ meses, impacto sistemico critico). R05: latencia en PROD sin plan de mejora firmado.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "37 User Stories APOLO catalogadas",     "target_date": "2026-08-01","status": "done"},
            {"seq": 2, "label": "Integracion Apolo-Transact (API)",      "target_date": "2026-09",   "status": "pending"},
            {"seq": 3, "label": "SIT originacion TDC completa",          "target_date": "2026-10",   "status": "pending"},
            {"seq": 4, "label": "GoLive canal Apolo",                    "target_date": "2027-01",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-ONBOARDING-DIGITAL","CAP-DEFERRED-PURCHASE","CAP-CUSTOMER-PROFILE",
        ],
    },
    "app-movil": {
        "sdlc_phase": "BUILD", "sdlc_progress": 42, "sdlc_status": "yellow",
        "sdlc_summary": "Canal movil BanCoppel (Nova). Canal principal del cliente digital: activacion de tarjeta, autorizacion TDC, pagos, consultas de saldo y compras diferidas.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "18 User Stories canal App TDC R4",       "target_date": "2026-08-19","status": "done"},
            {"seq": 2, "label": "Encendido/Apagado TDC (+3 User Stories)","target_date": "2026-08-19","status": "done"},
            {"seq": 3, "label": "SIT App-SmartVista-Transact",           "target_date": "2026-10",   "status": "pending"},
            {"seq": 4, "label": "UAT cliente digital",                   "target_date": "2026-11",   "status": "pending"},
            {"seq": 5, "label": "GoLive App Movil TDC",                  "target_date": "2027-01",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-PAYMENT","CAP-BALANCE-STATEMENT","CAP-DEFERRED-PURCHASE",
            "CAP-COLLECTIONS-AGING","CAP-CARD-LIFECYCLE","CAP-ONBOARDING-DIGITAL",
        ],
    },
    "siweb": {
        "sdlc_phase": "DISCOVER", "sdlc_progress": 15, "sdlc_status": "red",
        "sdlc_summary": "Canal web de sucursal (ventanilla interna BanCoppel). 5 User Stories Must Have. Bloqueado: APIs SmartVista BPC sin fecha de entrega confirmada.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "5 User Stories definidas (requerimientos)","target_date": "2026-07","status": "done"},
            {"seq": 2, "label": "APIs SmartVista disponibles",           "target_date": "TBD",       "status": "pending"},
            {"seq": 3, "label": "Desarrollo e integracion SIWEB",        "target_date": "TBD",       "status": "planned"},
            {"seq": 4, "label": "SIT canal sucursal",                    "target_date": "TBD",       "status": "planned"},
        ],
        "capabilities": [
            "CAP-BALANCE-STATEMENT","CAP-DEFERRED-PURCHASE",
            "CAP-ACCOUNTING-INTEGRATION","CAP-OVERPAYMENT",
        ],
    },
    "cat": {
        "sdlc_phase": "DISCOVER", "sdlc_progress": 20, "sdlc_status": "red",
        "sdlc_summary": "Contact Center (IVR + agentes). 12 User Stories Must Have. Proveedor sin contratar al 2026-08-31 — sin owner tecnico ni plan de pruebas posible. RISK-001 activo.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "12 User Stories CAT definidas",         "target_date": "2026-07",   "status": "done"},
            {"seq": 2, "label": "RFP / seleccion de proveedor",          "target_date": "2026-08-31","status": "pending"},
            {"seq": 3, "label": "Contrato y kickoff proveedor",          "target_date": "2026-09",   "status": "planned"},
            {"seq": 4, "label": "SIT Contact Center (IVR-SVIP)",         "target_date": "TBD",       "status": "planned"},
            {"seq": 5, "label": "GoLive CAT",                            "target_date": "2027-01",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-CHANNEL-SELFSERVICE","CAP-AUTHENTICATION","CAP-BALANCE-STATEMENT",
            "CAP-CUSTOMER-PROFILE","CAP-CARD-LIFECYCLE","CAP-COLLECTIONS-AGING",
        ],
    },
    "atlas": {
        "sdlc_phase": "BUILD", "sdlc_progress": 25, "sdlc_status": "yellow",
        "sdlc_summary": "Plataforma de datos analiticos en GCP (BigQuery + Dataflow). Landing zone aprovisionada. Pendiente: pipelines Informix->Atlas y reportes CNBV. R09: Golden Record Fase 2 sin confirmar alcance.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "Landing zone GCP aprovisionada",        "target_date": "2026-07",   "status": "done"},
            {"seq": 2, "label": "Pipelines Informix a Atlas (Dataflow)", "target_date": "2026-09",   "status": "pending"},
            {"seq": 3, "label": "Integracion reportes CNBV Anexos",      "target_date": "2026-10",   "status": "pending"},
            {"seq": 4, "label": "GoLive Atlas (analitica + regulatorio)","target_date": "2026-11",   "status": "planned"},
        ],
        "capabilities": ["CAP-BALANCE-STATEMENT","CAP-COLLECTIONS-AGING","CAP-FEE-COMMISSION"],
    },
    "controlm": {
        "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "sdlc_summary": "Orquestador de batch BMC Control-M. Jobs criticos: cierre de dia, comisiones, cobranza, estados de cuenta nocturnos. Permanece como baseline en R4.",
        "exclude_from_portal": 1,
        "milestones": [
            {"seq": 1, "label": "Sistema en produccion (baseline)",      "target_date": "< 2024",    "status": "done"},
            {"seq": 2, "label": "Nuevos jobs TDC P4900 (cierre dia)",    "target_date": "2026-Q4",   "status": "pending"},
            {"seq": 3, "label": "Validacion SLA batch post-GoLive",      "target_date": "2027-Q1",   "status": "planned"},
        ],
        "capabilities": [
            "CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION",
            "CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE",
        ],
    },
    "eglobal": {
        "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "sdlc_summary": "Switch ISO 8583 interno BanCoppel. Valida 88 reglas de transacciones TDC contra SmartVista. Frontera critica de autorizacion en tiempo real.",
        "exclude_from_portal": 1,
        "milestones": [
            {"seq": 1, "label": "Sistema en produccion (baseline)",      "target_date": "< 2024",    "status": "done"},
            {"seq": 2, "label": "Validacion 88 reglas vs SmartVista",    "target_date": "2026-08",   "status": "done"},
            {"seq": 3, "label": "SIT eGlobal-SmartVista-Transact",       "target_date": "2026-09",   "status": "pending"},
            {"seq": 4, "label": "Pruebas de carga ISO 8583 P4900",       "target_date": "2026-10",   "status": "pending"},
        ],
        "capabilities": ["CAP-CARD-LIFECYCLE","CAP-PAYMENT"],
    },
    "cobranza": {
        "sdlc_phase": "BUILD", "sdlc_progress": 30, "sdlc_status": "yellow",
        "sdlc_summary": "Cobranza Direccionada — gestion de cartera vencida TDC P4900. 37-50 User Stories pendientes de incorporar al inventario R4. Riesgo: pentest nov 15-20 congela el unico ambiente de SIT.",
        "exclude_from_portal": 0,
        "milestones": [
            {"seq": 1, "label": "37-50 USs identificadas (Cobranza Dir.)", "target_date": "2026-07", "status": "done"},
            {"seq": 2, "label": "Incorporacion al inventario R4 formal",   "target_date": "2026-09", "status": "pending"},
            {"seq": 3, "label": "SIT Cobranza (fuera de ventana pentest)", "target_date": "2026-11", "status": "pending"},
            {"seq": 4, "label": "UAT cobranza + Buro de Credito",          "target_date": "2026-11", "status": "planned"},
            {"seq": 5, "label": "GoLive Cobranza Direccionada",            "target_date": "2027-01", "status": "planned"},
        ],
        "capabilities": ["CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE","CAP-PAYMENT"],
    },
    "connect-direct": {
        "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "yellow",
        "sdlc_summary": "Transferencia segura de archivos batch (IBM Sterling). Mueve archivos entre sistemas internos y redes VISA/MC. Licencia a revisar — alternativa MFT en evaluacion.",
        "exclude_from_portal": 1,
        "milestones": [
            {"seq": 1, "label": "Sistema en produccion (baseline)",      "target_date": "< 2024",    "status": "done"},
            {"seq": 2, "label": "Evaluacion alternativa MFT",            "target_date": "2026-09",   "status": "pending"},
            {"seq": 3, "label": "Decision de renovacion / migracion",    "target_date": "2026-10",   "status": "pending"},
            {"seq": 4, "label": "Resolucion de riesgo de licencia",      "target_date": "2026-11",   "status": "planned"},
        ],
        "capabilities": ["CAP-CARD-LIFECYCLE","CAP-CARD-MANUFACTURING"],
    },
}


def load_system_sdlc(con: sqlite3.Connection) -> None:
    """v1.5.0 — Carga fase SDLC, milestones y capabilities por sistema en brain.db.
    Idempotente: usa ALTER TABLE con try/except + DELETE+INSERT para milestones,
    e INSERT OR REPLACE para capabilities.
    Fuente: SYSTEM_SDLC_DATA arriba (mismo contenido que SYSTEM_SDLC en build-portal.py).
    """
    # Schema — idempotente
    for col_def in [
        "ALTER TABLE program_systems ADD COLUMN sdlc_phase TEXT",
        "ALTER TABLE program_systems ADD COLUMN sdlc_progress INTEGER DEFAULT 0",
        "ALTER TABLE program_systems ADD COLUMN sdlc_status TEXT DEFAULT 'gray'",
        "ALTER TABLE program_systems ADD COLUMN sdlc_summary TEXT",
        "ALTER TABLE program_systems ADD COLUMN exclude_from_portal INTEGER DEFAULT 0",
    ]:
        try:
            con.execute(col_def)
        except Exception:
            pass

    con.executescript("""
        CREATE TABLE IF NOT EXISTS program_system_milestones (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            system_id   TEXT NOT NULL REFERENCES program_systems(id),
            seq         INTEGER NOT NULL,
            label       TEXT NOT NULL,
            target_date TEXT,
            status      TEXT NOT NULL CHECK(status IN ('done','pending','planned'))
        );
        CREATE TABLE IF NOT EXISTS program_system_caps (
            system_id      TEXT NOT NULL REFERENCES program_systems(id),
            capability_id  TEXT NOT NULL,
            PRIMARY KEY (system_id, capability_id)
        );

        -- Lifecycle Validator Tables (Swarm v1.0)
        CREATE TABLE IF NOT EXISTS lifecycle_phases (
            phase_id    TEXT PRIMARY KEY,
            name        TEXT,
            num         TEXT,
            icon        TEXT,
            color       TEXT,
            description TEXT,
            coverage    TEXT,
            us_count    INTEGER,
            validated   INTEGER DEFAULT 0,
            updated_at  TEXT
        );

        CREATE TABLE IF NOT EXISTS lifecycle_flow_nodes (
            id            TEXT PRIMARY KEY,
            phase_id      TEXT,
            step_order    INTEGER,
            node_name     TEXT,
            system_id     TEXT,
            node_type     TEXT,
            pending       INTEGER DEFAULT 0,
            evidence_type TEXT,
            evidence_ref  TEXT
        );

        CREATE TABLE IF NOT EXISTS lifecycle_flow_arrows (
            id            TEXT PRIMARY KEY,
            phase_id      TEXT,
            step_order    INTEGER,
            label         TEXT,
            pending       INTEGER DEFAULT 0,
            evidence_ref  TEXT
        );

        CREATE TABLE IF NOT EXISTS lifecycle_steps (
            id           TEXT PRIMARY KEY,
            phase_id     TEXT,
            step_n       INTEGER,
            description  TEXT,
            sistema      TEXT,
            us_id        TEXT,
            us_title     TEXT,
            protocol     TEXT,
            exists_today INTEGER DEFAULT 0,
            gap_flag     INTEGER DEFAULT 0,
            gap_notes    TEXT
        );

        CREATE TABLE IF NOT EXISTS lifecycle_data_elements (
            id             TEXT PRIMARY KEY,
            phase_id       TEXT,
            entity_name    TEXT,
            field_name     TEXT,
            data_type      TEXT,
            description    TEXT,
            source_system  TEXT,
            regulation_ref TEXT,
            is_pii         INTEGER DEFAULT 0,
            is_financial   INTEGER DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS lifecycle_integrations (
            id              TEXT PRIMARY KEY,
            phase_id        TEXT,
            integration_ref TEXT,
            from_system     TEXT,
            to_system       TEXT,
            api_name        TEXT,
            protocol        TEXT,
            direction       TEXT,
            evidence_us     TEXT,
            scope_r4        INTEGER DEFAULT 0,
            gap_flag        INTEGER DEFAULT 0,
            gap_notes       TEXT
        );

        CREATE TABLE IF NOT EXISTS lifecycle_test_cases (
            id              TEXT PRIMARY KEY,
            phase_id        TEXT,
            tc_id           TEXT,
            tc_title        TEXT,
            precondition    TEXT,
            steps_summary   TEXT,
            expected_result TEXT,
            priority        TEXT,
            test_type       TEXT,
            regulation_ref  TEXT,
            linked_us_id    TEXT
        );
    """)
    con.commit()

    n_sys = n_ms = n_caps = 0
    for sid, d in SYSTEM_SDLC_DATA.items():
        con.execute("""
            UPDATE program_systems
               SET sdlc_phase          = ?,
                   sdlc_progress       = ?,
                   sdlc_status         = ?,
                   sdlc_summary        = ?,
                   exclude_from_portal = ?
             WHERE id = ?
        """, (d["sdlc_phase"], d["sdlc_progress"], d["sdlc_status"],
              d["sdlc_summary"], d.get("exclude_from_portal", 0), sid))
        n_sys += 1

        con.execute("DELETE FROM program_system_milestones WHERE system_id = ?", (sid,))
        for ms in d.get("milestones", []):
            con.execute(
                "INSERT INTO program_system_milestones (system_id, seq, label, target_date, status) VALUES (?,?,?,?,?)",
                (sid, ms["seq"], ms["label"], ms["target_date"], ms["status"]),
            )
            n_ms += 1

        for cap in d.get("capabilities", []):
            con.execute(
                "INSERT OR REPLACE INTO program_system_caps (system_id, capability_id) VALUES (?,?)",
                (sid, cap),
            )
            n_caps += 1

    con.commit()
    print(f"  system_sdlc       : {n_sys} sistemas | {n_ms} milestones | {n_caps} capabilities")


def main() -> None:
    parser = argparse.ArgumentParser(description="Unity Project Brain Builder v1.7.0")
    parser.add_argument("--reset", action="store_true", help="Borra y reconstruye brain.db")
    args = parser.parse_args()

    if args.reset and DB_PATH.exists():
        DB_PATH.unlink()
        print("  brain.db eliminado  --  reconstruyendo desde cero")

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(str(DB_PATH))
    con.execute("PRAGMA journal_mode=WAL")

    print("Construyendo Unity Project Brain v1.7.0...")
    init_db(con)
    load_project_info(con)
    load_products(con)
    load_product_releases(con)   # v1.1.0  --  tren de releases por producto
    load_components(con)
    load_capabilities(con)   # debe ir antes de hdus/dtms (FK)
    load_risks(con)
    load_assumptions(con)
    load_issues(con)
    load_dependencies(con)
    load_milestones(con)
    load_vocabulary(con)
    load_decisions(con)
    load_hdus(con)
    load_dtms(con)
    load_apolo_hdus(con)      # v0.6.1  --  APOLO 37 User Stories originacion digital
    load_semantic_layer(con)  # v0.6.1  --  capa semantica cross-DT
    load_track_analysis(con)  # v0.7.0  --  7 tracks: User Stories por sesion, complejidad, integraciones
    load_plan_progress(con)   # v0.7.0  --  Plan de Trabajo corte 16-ago: avance global 20.66%
    load_pv_requirements(con)  # v0.8.0  --  28 RFs Product Vision R4
    load_app_user_stories(con) # v0.9.0  --  13 User Stories App canal TDC F&D (Jira SMART-XXXX)
    load_user_stories_inventory(con)     # v1.1.0  --  79 User Stories scoring Accenture (Inventario User Stories Excel)
    load_r4_integrations(con)  # v1.0.0  --  18 integraciones R4 cross-track
    load_track_rag(con)        # v1.0.0  --  5 tracks RAG (PPTX Roadmap 11-ago-2026)
    load_legacy_systems(con)   # v1.2.0  --  14 sistemas legado/ecosistema (barrido documental 2026-08-19)
    load_audit_findings(con)   # v1.2.0  --  19 hallazgos del barrido (cifras, correcciones, ambiguedades)
    load_lifecycle_phase_steps(con)
    load_program_systems(con)
    load_system_sdlc(con)          # v1.5.0  --  fase/progreso/milestones/caps por sistema (desde brain.db)
    load_coexistence_rules(con)    # v1.6.0  --  9 reglas routing Informix<->Unity por tipo op / canal
    load_migration_map(con)        # v1.6.0  --  20 entries mapeo dominio Informix -> sistema Unity
    load_functional_duplicity(con) # v1.7.0  --  23 candidatos swarm DT-SWAP-01..08 duplicidad funcional
    load_system_id_mappings(con)   # v1.7.0  --  ALTER TABLE + system_id/risk_id/hdu_id en todas las tablas
    load_dtm_risks(con)            # v1.7.0  --  14 riesgos derivados de dtm_catalog (gaps SmartVista)
    load_cobranza_placeholders(con)
    load_pending_issues(con) # v1.7.0  --  8 USs placeholder Cobranza (pendiente-levantamiento)
    load_it_capabilities(con)      # v1.5.0  --  13 capacidades IT del programa
    load_stakeholders(con)         # v1.6.0  --  96 stakeholders (bancoppel/acn/ey/vendors)
    rebuild_fts(con)
    coverage_summary(con)
    semantic_summary(con)     # v0.6.1  --  vista capability_360

    con.close()
    print(f"\n  brain.db: {DB_PATH}")


def load_pv_requirements(con: sqlite3.Connection) -> None:
    """Carga 28 RFs del Product Vision R4 (DEF PV 1006626 Mercado Abierto)."""
    cols = list(PV_REQUIREMENTS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO product_vision_requirements ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in PV_REQUIREMENTS])
    con.commit()
    by_channel = {}
    for r in PV_REQUIREMENTS:
        ch = r.get("channel", "unknown")
        by_channel[ch] = by_channel.get(ch, 0) + 1
    summary = " | ".join(f"{ch}:{n}" for ch, n in sorted(by_channel.items()))
    print(f"  product_vision_req: {len(PV_REQUIREMENTS)} RFs  |  {summary}")


def load_app_user_stories(con: sqlite3.Connection) -> None:
    """Carga 13 User Stories del canal App (Respaldo US ZIP, Jira SMART-XXXX)."""
    cols = list(APP_USER_STORIES[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO app_user_stories ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in APP_USER_STORIES])
    con.commit()
    by_estado = {}
    for r in APP_USER_STORIES:
        e = r.get("estado", "unknown")
        by_estado[e] = by_estado.get(e, 0) + 1
    summary = " | ".join(f"{e}:{n}" for e, n in sorted(by_estado.items()))
    print(f"  app_user_stories  : {len(APP_USER_STORIES)} User Stories  |  {summary}")



def load_user_stories_inventory(con) -> None:
    """Carga 76 User Stories del Inventario Accenture (Roadmap Excel v2) con scoring MoSCoW."""
    cols = list(HU_INVENTORY[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO user_stories_inventory ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in HU_INVENTORY])
    con.commit()
    by_track = {}
    for r in HU_INVENTORY:
        t = r.get("track", "?")
        by_track[t] = by_track.get(t, 0) + 1
    summary = " | ".join(f"{t}:{n}" for t, n in sorted(by_track.items()))
    must_n = sum(1 for r in HU_INVENTORY if r.get("moscow") == "must")
    should_n = sum(1 for r in HU_INVENTORY if r.get("moscow") == "should")
    print(f"  user_stories_inventory      : {len(HU_INVENTORY)} User Stories  |  must={must_n} should={should_n}  |  {summary}")


def load_r4_integrations(con) -> None:
    """Carga 18 integraciones R4 (API/Batch/Evento, Nueva/Modificar) cross-track."""
    cols = list(R4_INTEGRATIONS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO r4_integrations ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in R4_INTEGRATIONS])
    con.commit()
    by_tipo = {}
    for r in R4_INTEGRATIONS:
        t = r.get("tipo", "?")
        by_tipo[t] = by_tipo.get(t, 0) + 1
    nueva_n   = sum(1 for r in R4_INTEGRATIONS if r.get("estado") == "Nueva")
    mod_n     = sum(1 for r in R4_INTEGRATIONS if r.get("estado") == "Modificar")
    tipo_str  = " | ".join(f"{t}:{n}" for t, n in sorted(by_tipo.items()))
    print(f"  r4_integrations   : {len(R4_INTEGRATIONS)} integraciones  |  nueva={nueva_n} mod={mod_n}  |  {tipo_str}")


def load_track_rag(con) -> None:
    """Carga RAG por track desde PPTX Roadmap 11-ago-2026 (5 tracks)."""
    cols = list(TRACK_RAG[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO track_rag ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in TRACK_RAG])
    con.commit()
    reds    = sum(1 for r in TRACK_RAG if r.get("rag_color") == "red")
    yellows = sum(1 for r in TRACK_RAG if r.get("rag_color") == "yellow")
    print(f"  track_rag         : {len(TRACK_RAG)} tracks  |  red={reds} yellow={yellows}")


def load_legacy_systems(con: sqlite3.Connection) -> None:
    """Carga inventario de sistemas del legado y ecosistema Unity (v1.2.0).
    Descubiertos en barrido documental 2026-08-19 (257 documentos del corpus).
    """
    cols = list(LEGACY_SYSTEMS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO legacy_systems ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in LEGACY_SYSTEMS])
    con.commit()
    core_paths = sum(1 for r in LEGACY_SYSTEMS if r.get("core_path"))
    types: dict[str, int] = {}
    for r in LEGACY_SYSTEMS:
        t = r.get("type", "?")
        types[t] = types.get(t, 0) + 1
    type_str = " | ".join(f"{t}:{n}" for t, n in sorted(types.items()))
    print(f"  legacy_systems    : {len(LEGACY_SYSTEMS)} sistemas  |  core_path={core_paths}  |  {type_str}")


def load_audit_findings(con: sqlite3.Connection) -> None:
    """Carga hallazgos del barrido documental 2026-08-19 (v1.2.0).
    Incluye cifras-huerfanas, correcciones, ambiguedades, hallazgos y datos-requeridos.
    """
    cols = list(AUDIT_FINDINGS[0].keys())
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO audit_findings ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in AUDIT_FINDINGS])
    con.commit()
    by_cat: dict[str, int] = {}
    for r in AUDIT_FINDINGS:
        c = r.get("category", "?")
        by_cat[c] = by_cat.get(c, 0) + 1
    open_n  = sum(1 for r in AUDIT_FINDINGS if r.get("status") == "open")
    cat_str = " | ".join(f"{c}:{n}" for c, n in sorted(by_cat.items()))
    print(f"  audit_findings    : {len(AUDIT_FINDINGS)} hallazgos  |  open={open_n}  |  {cat_str}")


# ── Cadena de valor TDC — pasos por fase (v1.3.0) ───────────────────────────
# Fuente: DT-Productos v1.2.0 + US reales del brain (user_stories_inventory,
# app_user_stories, hdu_catalog). Cada paso mapea sistema + US que lo cubre.
LIFECYCLE_PHASE_STEPS = [
    # ── ORIGINACIÓN ──────────────────────────────────────────────────────────
    {"phase_id":"originacion","step_n":1,"paso":"Presentación de oferta de producto y CAT",
     "sistema":"Apolo","us_id":"HDU-TDC-R4-01","us_title":"Actualizar tasa ordinaria y CAT en la oferta de producto","fuente":"brain"},
    {"phase_id":"originacion","step_n":2,"paso":"Validación de teléfono y OTP (titularidad celular)",
     "sistema":"Apolo","us_id":"HDU-TDC-R4-24","us_title":"Validar titularidad del celular y disponibilidad para OTP","fuente":"brain"},
    {"phase_id":"originacion","step_n":3,"paso":"Perfilamiento y validación de domicilio",
     "sistema":"Apolo + Informix","us_id":"HDU-TDC-R4-05","us_title":"Aplicar Coltrane en perfilamiento, riesgo y KYC","fuente":"brain"},
    {"phase_id":"originacion","step_n":4,"paso":"Declaración de Persona Vulnerable (grupos prioritarios)",
     "sistema":"Apolo + PLD","us_id":"HDU-TDC-R4-07","us_title":"Capturar declaración inicial de persona vulnerable","fuente":"brain"},
    {"phase_id":"originacion","step_n":5,"paso":"Consulta SIC / Buró de Crédito",
     "sistema":"Apolo + Buró de Crédito","us_id":"HDU-TDC-R4-05","us_title":"Validación SIC en bloque de perfilamiento","fuente":"brain"},
    {"phase_id":"originacion","step_n":6,"paso":"Validación listas negras PLD (solicitante, familiar, referencia)",
     "sistema":"Apolo + PLD","us_id":"HDU-TDC-R4-13","us_title":"Validar al solicitante contra listas negras PLD","fuente":"brain"},
    {"phase_id":"originacion","step_n":7,"paso":"Presentación y aceptación de Términos y Contrato (CONDUSEF)",
     "sistema":"Apolo","us_id":"HDU-TDC-R4-17","us_title":"Presentar pantalla de términos con Contrato Múltiple","fuente":"brain"},
    {"phase_id":"originacion","step_n":8,"paso":"Prueba de vida y lectura de documentos",
     "sistema":"Apolo","us_id":"HDU-TDC-R4-18","us_title":"Permitir lectura de documentos y avance a firma electrónica","fuente":"brain"},
    {"phase_id":"originacion","step_n":9,"paso":"Firma electrónica, alta de crédito e integración de expediente digital",
     "sistema":"Apolo + Informix + SmartVista","us_id":"HDU-TDC-R4-20","us_title":"Integrar firma, alta de crédito y expediente digital","fuente":"brain"},
    {"phase_id":"originacion","step_n":10,"paso":"Bienvenida: envío de contrato vigente por correo",
     "sistema":"Apolo + Notificaciones","us_id":"HDU-TDC-R4-03","us_title":"Enviar contrato vigente al finalizar la solicitud","fuente":"brain"},
    # ── EMISIÓN ──────────────────────────────────────────────────────────────
    {"phase_id":"emision","step_n":1,"paso":"Consulta de inventario de tarjetas por sucursal",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-02","us_title":"Consultar inventario de tarjetas por sucursal","fuente":"brain"},
    {"phase_id":"emision","step_n":2,"paso":"Cálculo de solicitud de maquila con parámetros de abasto",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-03","us_title":"Calcular maquila con parámetros de abasto","fuente":"brain"},
    {"phase_id":"emision","step_n":3,"paso":"Generación de solicitud automatizada de maquila",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-04","us_title":"Ejecutar solicitud automatizada de maquila","fuente":"brain"},
    {"phase_id":"emision","step_n":4,"paso":"Generación de archivos cifrados (PGP) para el maquilador",
     "sistema":"SmartVista BPC + HSM","us_id":"HDU-SMART-R4-06","us_title":"Generar archivos seguros de maquila","fuente":"brain"},
    {"phase_id":"emision","step_n":5,"paso":"Certificación de layouts de maquila con el proveedor",
     "sistema":"SmartVista BPC + Maquilador","us_id":"HDU-SMART-R4-01","us_title":"Certificar layouts de maquila con proveedores","fuente":"brain"},
    {"phase_id":"emision","step_n":6,"paso":"Seguimiento de estatus de lotes de producción",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-07","us_title":"Dar seguimiento a estatus de lotes","fuente":"brain"},
    {"phase_id":"emision","step_n":7,"paso":"Recepción y control de lotes (física y digital)",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-08","us_title":"Controlar recepción y cancelación de lotes","fuente":"brain"},
    # ── ACTIVACIÓN ───────────────────────────────────────────────────────────
    {"phase_id":"activacion","step_n":1,"paso":"Gestión de TDC Física desde canal Apolo",
     "sistema":"Apolo + SmartVista BPC","us_id":"SMART-3964","us_title":"Gestión de Tarjeta de Crédito Física - Canal Apolo","fuente":"brain"},
    {"phase_id":"activacion","step_n":2,"paso":"Activación de TDC Digital por AppMóvil",
     "sistema":"AppMóvil + SmartVista BPC","us_id":"SMART-3966","us_title":"Activación de TDC Digital","fuente":"brain"},
    {"phase_id":"activacion","step_n":3,"paso":"Gestión de TDC Digital desde canal Apolo",
     "sistema":"Apolo + SmartVista BPC","us_id":"SMART-4219","us_title":"Gestión de Tarjeta de Crédito Digital - Canal Apolo","fuente":"brain"},
    {"phase_id":"activacion","step_n":4,"paso":"Notificación de activación al portador (push + email)",
     "sistema":"AppMóvil + Notificaciones","us_id":"SMART-4105","us_title":"Notificación de activación Tarjeta Digital BanCoppel","fuente":"brain"},
    {"phase_id":"activacion","step_n":5,"paso":"Convivencia TDC Física y Digital en Home de la app",
     "sistema":"AppMóvil + Informix","us_id":"SMART-4531","us_title":"Convivencia en Home de Cuentas TDC F&D","fuente":"brain"},
    # ── AUTORIZACIÓN ─────────────────────────────────────────────────────────
    {"phase_id":"autorizacion","step_n":1,"paso":"Recepción de mensaje ISO 8583 del adquirente (POS / e-commerce)",
     "sistema":"SmartVista SVFE","us_id":"HDU-SMART-R4-11","us_title":"Incorporar 88 reglas del autorizador BPC","fuente":"brain"},
    {"phase_id":"autorizacion","step_n":2,"paso":"Validación del instrumento (límite, vigencia, CVV2)",
     "sistema":"SmartVista SVFE","us_id":"HDU-SMART-R4-11","us_title":"Incorporar 88 reglas del autorizador BPC","fuente":"brain"},
    {"phase_id":"autorizacion","step_n":3,"paso":"Aplicación de 88 reglas del autorizador BPC",
     "sistema":"SmartVista SVFE","us_id":"HDU-SMART-R4-11","us_title":"Incorporar 88 reglas del autorizador BPC","fuente":"brain"},
    {"phase_id":"autorizacion","step_n":4,"paso":"Control de saldo a favor y validación del límite",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-13","us_title":"Validar límite de saldo a favor por línea de crédito","fuente":"brain"},
    {"phase_id":"autorizacion","step_n":5,"paso":"Respuesta aprobación / rechazo en tiempo real",
     "sistema":"SmartVista SVFE","us_id":"HDU-SMART-R4-11","us_title":"Incorporar 88 reglas del autorizador BPC","fuente":"brain"},
    {"phase_id":"autorizacion","step_n":6,"paso":"Registro del movimiento y actualización de saldo disponible",
     "sistema":"SmartVista BPC + Informix","us_id":"—","us_title":"Sin User Story específica en R4","fuente":"manual"},
    # ── TRANSACCIONES ────────────────────────────────────────────────────────
    {"phase_id":"transacciones","step_n":1,"paso":"Consulta de movimientos convivencia TDC Física y Digital",
     "sistema":"AppMóvil + Informix + SmartVista","us_id":"SMART-4176","us_title":"Movimientos Convivencia TDC F&D","fuente":"brain"},
    {"phase_id":"transacciones","step_n":2,"paso":"Detalle de movimiento individual",
     "sistema":"AppMóvil + SmartVista BPC","us_id":"SMART-4180","us_title":"Detalle de Movimientos Convivencia TDC F&D","fuente":"brain"},
    {"phase_id":"transacciones","step_n":3,"paso":"Consulta de saldo y estado de cuenta",
     "sistema":"AppMóvil + Informix","us_id":"SMART-3962","us_title":"Detalle de Crédito Convivencia TDC F&D","fuente":"brain"},
    {"phase_id":"transacciones","step_n":4,"paso":"Actualización de operaciones en una misma sesión",
     "sistema":"AppMóvil + SmartVista","us_id":"PTCSF-6267","us_title":"Actualizar operaciones TDC Digital en una misma sesión","fuente":"brain"},
    {"phase_id":"transacciones","step_n":5,"paso":"Encendido / apagado operativo de TDC Física y Digital",
     "sistema":"AppMóvil + SmartVista","us_id":"APP-ENC-01","us_title":"Encendido, Apagado y Bloqueo Operativo - Tarjeta de Crédito","fuente":"brain"},
    {"phase_id":"transacciones","step_n":6,"paso":"Homologación omnicanal de nombres de comisiones",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-10","us_title":"Sincronizar nombres de comisiones en canales","fuente":"brain"},
    # ── PAGOS ────────────────────────────────────────────────────────────────
    {"phase_id":"pagos","step_n":1,"paso":"Visualización de montos de pago (mínimo, total, otra cantidad)",
     "sistema":"AppMóvil + SmartVista","us_id":"SMART-4182","us_title":"Visualización y aplicación de montos de pago en Línea TDC","fuente":"brain"},
    {"phase_id":"pagos","step_n":2,"paso":"Validación del límite de saldo a favor en pago",
     "sistema":"AppMóvil + SmartVista BPC","us_id":"SMART-4183","us_title":"Límite de saldo a favor para pago de TDC en la aplicación móvil","fuente":"brain"},
    {"phase_id":"pagos","step_n":3,"paso":"Gestión del campo 'Otra cantidad' por límite de SAF",
     "sistema":"AppMóvil + SmartVista","us_id":"SMART-4280","us_title":"Gestión del campo 'Otra cantidad' basado en el límite de SAF","fuente":"brain"},
    {"phase_id":"pagos","step_n":4,"paso":"Aplicación de pago anticipado a parcialidades activas",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-19","us_title":"Aplicar pagos anticipados a pagos fijos","fuente":"brain"},
    {"phase_id":"pagos","step_n":5,"paso":"Liquidación total de compra diferida",
     "sistema":"SmartVista BPC","us_id":"HDU-SMART-R4-20","us_title":"Liquidar totalmente compras diferidas","fuente":"brain"},
    {"phase_id":"pagos","step_n":6,"paso":"Acreditación SPEI al saldo disponible (< 5 min BANXICO)",
     "sistema":"Informix + SPEI / e-Global","us_id":"—","us_title":"Sin User Story específica en R4","fuente":"manual"},
    # ── CONTABILIDAD ─────────────────────────────────────────────────────────
    {"phase_id":"contabilidad","step_n":1,"paso":"Cierre de día operativo en SmartVista (EOD)",
     "sistema":"SmartVista BPC","us_id":"—","us_title":"Sin User Story — pendiente CAP-ACCOUNTING-INTEGRATION","fuente":"manual"},
    {"phase_id":"contabilidad","step_n":2,"paso":"Generación de archivo SVXP de posting contable",
     "sistema":"SmartVista BPC → Informix","us_id":"—","us_title":"Interfaz SVXP no construida — prioridad PreGame","fuente":"manual"},
    {"phase_id":"contabilidad","step_n":3,"paso":"Aplicación de asientos contables en core (Informix / PISA)",
     "sistema":"Informix (PISA)","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"contabilidad","step_n":4,"paso":"Conciliación: transacciones autorizadas vs. contabilizadas",
     "sistema":"Informix + SmartVista","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"contabilidad","step_n":5,"paso":"Generación de reportería CNBV (Anexos 33 y 36 CUB)",
     "sistema":"Informix + CNBV","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"contabilidad","step_n":6,"paso":"Cálculo mensual de provisión de cartera (NIF C-16)",
     "sistema":"Informix","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    # ── COBRANZA ─────────────────────────────────────────────────────────────
    {"phase_id":"cobranza","step_n":1,"paso":"Clasificación de cartera por tramos de aging (1-29, 30-60, 61-120, >120 días)",
     "sistema":"SmartVista BPC + Informix","us_id":"—","us_title":"Sin User Story — Cobranza Direccionada pendiente","fuente":"manual"},
    {"phase_id":"cobranza","step_n":2,"paso":"Bloqueo de cuenta y restricciones operativas por mora",
     "sistema":"SmartVista BPC + Informix","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"cobranza","step_n":3,"paso":"Gestión de cobranza preventiva (1-29 días de atraso)",
     "sistema":"Motor Cobranza Direccionada","us_id":"—","us_title":"37-50 USs de Cobranza Direccionada no incorporadas al R4","fuente":"manual"},
    {"phase_id":"cobranza","step_n":4,"paso":"Reporte al Buró de Crédito (día 30 de atraso — SISEC)",
     "sistema":"Informix + Buró de Crédito","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"cobranza","step_n":5,"paso":"Reporte de cartera vencida a CNBV (SISEC mensual)",
     "sistema":"Informix + CNBV","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
    {"phase_id":"cobranza","step_n":6,"paso":"Castigo de cartera y proceso de recuperación (> 120 días)",
     "sistema":"Informix + Motor Castigo","us_id":"—","us_title":"Sin User Story en R4","fuente":"manual"},
]


def load_lifecycle_phase_steps(con: sqlite3.Connection) -> None:
    """Carga pasos del proceso industria por fase de la cadena de valor TDC (v1.3.0).
    Fuente: DT-Productos v1.2.0 + USs reales del brain. Usado por build-portal.py
    para generar la tabla 'Proceso paso a paso' en lifecycle-p4900.html.
    """
    con.execute("DELETE FROM lifecycle_phase_steps")
    cols = ["phase_id", "step_n", "paso", "sistema", "us_id", "us_title", "fuente"]
    ph   = ", ".join("?" * len(cols))
    sql  = f"INSERT OR REPLACE INTO lifecycle_phase_steps ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(r.get(c) for c in cols) for r in LIFECYCLE_PHASE_STEPS])
    con.commit()
    by_phase = {}
    for r in LIFECYCLE_PHASE_STEPS:
        p = r["phase_id"]
        by_phase[p] = by_phase.get(p, 0) + 1
    brain_n = sum(1 for r in LIFECYCLE_PHASE_STEPS if r.get("fuente") == "brain")
    print(f"  lifecycle_phase_steps: {len(LIFECYCLE_PHASE_STEPS)} pasos  |  brain={brain_n}  |  fases={len(by_phase)}")


# -- v1.6.0 -- program_stakeholders ------------------------------------------
# Roster completo del programa Unity R4: ejecutivos, track owners, PMO,
# equipo ACN, vendors, EY (competidor). Fuente: minutas sesiones marzo 2026 +
# slide Plan Director 14-ago-2026.
STAKEHOLDERS = [
    # -- BanCoppel / Grupo Coppel -----------------------------------------------
    {"id":"STK-001","full_name":"Juan Manuel Fernández Islas","organization":"bancoppel",
     "role_title":"CIO de Servicios Financieros, Grupo Coppel","program_role":"executive_sponsor",
     "raci":"accountable","seniority":"executive","confidence":"confirmed","alert":None,
     "relevant_notes":"Sponsor ejecutivo del programa Unity. En BanCoppel desde noviembre 2022. "
       "Responsable del presupuesto y de la narrativa ante el Consejo de Administración "
       "(sesión crítica 24-abr-2026). También lleva el programa Carteras. "
       "Identificó los 16 productos, 3 tracks, horizonte 36 meses. "
       "Tomó decisiones de salidas de talento por performance. "
       "Principal punto de escalación ejecutiva. Quiere resultados, no presentaciones bonitas.",
     "source_docs":"19 Marzo - Minutas.docx; 23 Marzo - Minutas.docx; dt-gobierno.md","active":1},
    {"id":"STK-002","full_name":"Carlos López Moctezuma","organization":"grupo_coppel",
     "role_title":"Director de Servicios Financieros, Grupo Coppel","program_role":"executive_sponsor",
     "raci":"accountable","seniority":"executive","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable a nivel Grupo de todos los servicios financieros: banco, crédito Coppel "
       "y Personal Coppel. Involucró a Rodrigo Kennedy en Unity por instrucción propia. "
       "Scope estratégico más allá del banco.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-003","full_name":"Pablo Madinaveitia","organization":"bancoppel",
     "role_title":"Director de Transformación Unity","program_role":"program_director",
     "raci":"accountable","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Nuevo director; se incorpora el 6 de abril 2026. Luis Barragán le reportará. "
       "Debe contratar subdirectores (Apolo, Transact, SmartVista). "
       "17 posiciones evaluadas, 46 personas mapeadas a su estructura, 11 vacantes abiertas, "
       "universo de 117 personas. Requiere plan de onboarding de 60-90 días. "
       "También transcrito como Medinaveitia y Mandinaveidia (errores de transcripción).",
     "source_docs":"23 Marzo - Minutas.docx; dt-gobierno.md","active":1},
    {"id":"STK-004","full_name":"Teresa (Tere) González","organization":"bancoppel",
     "role_title":"Líder de Programa / Alineación Estratégica","program_role":"program_manager",
     "raci":"responsible","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"10 años en Coppel. En el proyecto formalmente desde diciembre 2025. "
       "Punto de contacto integral para negocio y tecnología durante el diagnóstico. "
       "Traduce planeación estratégica a nivel tecnológico. Coordina reuniones con Juan Manuel, "
       "dirección general y PMs. Le reportan PMs de Transact, SmartVista y Apolo. "
       "Trabaja junto a Rodrigo Kennedy (él en assessment; ella en apagar fuegos). "
       "Primer hallazgo al entrar: desastre en roles y responsabilidades.",
     "source_docs":"23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx","active":1},
    {"id":"STK-005","full_name":"Luis Barragán","organization":"bancoppel",
     "role_title":"Líder de Tecnología — Apolo y SmartVista / TDC","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Coordina relación entre arquitectura y proveedores. Reportará a Pablo Madinaveitia. "
       "Debe decidir si Leonardo Hernández continúa como responsable de Apolo. "
       "Estaba ausente por vacaciones en la primera semana de diagnóstico.",
     "source_docs":"19 Marzo - Minutas.docx; dt-gobierno.md; dt-cronograma.md","active":1},
    {"id":"STK-006","full_name":"Sergio del Valle","organization":"bancoppel",
     "role_title":"Líder de Negocio (sustituyendo a Stephany Ley)","program_role":"track_owner",
     "raci":"responsible","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Lidera la parte de negocio en ausencia de Stephany Ley (licencia de maternidad). "
       "Colaboró con Juan Manuel en el roadmap actualizado de 16 productos. "
       "Candidato para sesión de estrategia / North Star.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-007","full_name":"Stephany Ley","organization":"bancoppel",
     "role_title":"Responsable General de Productos y Canales","program_role":"track_owner",
     "raci":"accountable","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Actualmente en licencia de maternidad. Rol cubierto temporalmente por Sergio del Valle.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-008","full_name":"Brenda Abril Pichardo Ramírez","organization":"bancoppel",
     "role_title":"Subdirectora RMO (en transición)","program_role":"pmo_financial",
     "raci":"responsible","seniority":"director","confidence":"confirmed",
     "alert":"Nunca han aplicado penalizaciones a proveedores — riesgo de exigibilidad contractual.",
     "relevant_notes":"En transición para tomar la Subdirección de la RMO. Desde el nacimiento de Unity. "
       "Maneja 100% el control financiero (Excel + Dynamics). "
       "Gestiona contratos, contratación y pago de ~25-40 proveedores. "
       "Araceli Bárcenas le reporta. Conocimiento histórico invaluable. "
       "Debe alinear todas las áreas de seguridad e integrar requerimientos en desarrollos.",
     "source_docs":"23 Marzo - Minutas.docx; dt-gobierno.md","active":1},
    {"id":"STK-009","full_name":"Fernanda Barbosa","organization":"bancoppel",
     "role_title":"PMO — SmartVista y Apolo (reemplazo de Ana Rosa Cruz)","program_role":"pmo",
     "raci":"responsible","seniority":"manager","confidence":"confirmed",
     "alert":"No puede integrarse plenamente antes del 16 de abril 2026 por proceso de transferencia.",
     "relevant_notes":"Reemplazo de Ana Rosa Cruz. También identificada como Ma. Fernanda Barbosa. "
       "Owners del P4900 en el DT de gobierno.",
     "source_docs":"23 Marzo - Minutas.docx; dt-gobierno.md; dt-cronograma.md","active":1},
    {"id":"STK-010","full_name":"Araceli Bárcenas","organization":"bancoppel",
     "role_title":"PMO — Transact (Captación y Préstamo Personal)","program_role":"pmo",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"PMO para el track de Transact. Forma parte de la RMO y ya reporta a Brenda Pichardo. "
       "Referida como Ara en notas informales. Con ella el plan director tomó más forma.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-011","full_name":"Ana Rosa Cruz","organization":"bancoppel",
     "role_title":"PMO SmartVista y Apolo (saliente ~abril 2026)","program_role":"pmo",
     "raci":"informed","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"PMO hasta ~abril 2026. Visibilidad de roadmap hasta 2026. Reemplazada por Fernanda Barbosa.",
     "source_docs":"23 Marzo - Minutas.docx","active":0},
    {"id":"STK-012","full_name":"Armando Riveros","organization":"bancoppel",
     "role_title":"Owner Apificación","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Owner del equipo transversal de Apificación que habilita las integraciones de todos los tracks.",
     "source_docs":"dt-gobierno.md; capability_stakeholders","active":1},
    {"id":"STK-013","full_name":"Sergio Arellano","organization":"bancoppel",
     "role_title":"Product Manager — Tarjeta de Crédito","program_role":"product_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable del roadmap tecnológico de la Tarjeta de Crédito. "
       "Debe congelar la versión del estado de cuenta y entregar definiciones completas "
       "del alcance R3 para liberación oportuna.",
     "source_docs":"25 Marzo - Minutas.docx; dt-cronograma.md","active":1},
    {"id":"STK-014","full_name":"Arturo Valdivia / Luis Arturo Valdivieso Cruz","organization":"bancoppel",
     "role_title":"Product Manager — Onboarding / Apolo","program_role":"product_owner",
     "raci":"responsible","seniority":"manager","confidence":"inferred",
     "alert":"Nombre con variantes (Alfredo Valdivieso en una transcripción) — confirmar nombre exacto.",
     "relevant_notes":"Responsable del roadmap tecnológico del producto Onboarding/Apolo. "
       "Juan Manuel solicitó sesión con él para definir estrategia de originación (pantalla única).",
     "source_docs":"23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx","active":1},
    {"id":"STK-015","full_name":"Leonardo (Leo) Hernández","organization":"bancoppel",
     "role_title":"Delivery Lead — Apolo y SmartVista","program_role":"delivery_lead",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable de la ejecución/delivery de Apolo y TDC. "
       "Fue movido desde cobranza para ayudar en tarjetas. "
       "Luis Barragán debe decidir si Leo continúa como responsable de Apolo.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-016","full_name":"Sandra Figueroa","organization":"bancoppel",
     "role_title":"Tech Lead — Transact","program_role":"delivery_lead",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Equivalente de Leonardo Hernández para el track de Transact. "
       "Tiene fortaleza técnica pero faltaba complementar con capa funcional. "
       "Recibe solicitudes de negocio sin priorización clara.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-017","full_name":"Armando Garcia","organization":"bancoppel",
     "role_title":"PM SmartVista","program_role":"delivery_lead",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"PM de SmartVista en BanCoppel. Identificado en capability_stakeholders del brain.",
     "source_docs":"capability_stakeholders","active":1},
    {"id":"STK-018","full_name":"David Ruelas","organization":"bancoppel",
     "role_title":"Responsable de Crédito","program_role":"stakeholder",
     "raci":"consulted","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"La evaluación y administración del crédito pasará a ser su responsabilidad. Referido como Ruedas en algunas notas.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-019","full_name":"Iván de la O","organization":"bancoppel",
     "role_title":"Responsable de Cobranza","program_role":"stakeholder",
     "raci":"consulted","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable del frente de cobranza. Referenciado en la estructura del programa.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-020","full_name":"Alondra Bastidas","organization":"bancoppel",
     "role_title":"Responsable de Integración e Interoperabilidad","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed",
     "alert":"Diferente de Alondra Cárdenas (Change Management).",
     "relevant_notes":"Responsable del frente de integración e interoperabilidad. Referida como Londra Bastidas en una minuta.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-021","full_name":"Alondra Cárdenas","organization":"bancoppel",
     "role_title":"Responsable de Change Management","program_role":"stakeholder",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Organizativamente con Brenda Pichardo. Ha hecho capacitaciones de change management. "
       "Change Management actual es táctico (manuales, capacitación), no estratégico.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-022","full_name":"Arcadio","organization":"bancoppel",
     "role_title":"Arquitecto Empresarial de Grupo / Líder de Datos","program_role":"architect",
     "raci":"consulted","seniority":"director","confidence":"inferred",
     "alert":"Apellido no confirmado en fuentes.",
     "relevant_notes":"Responsable de arquitectura empresarial a nivel de grupo y del proyecto Atlas (Golden Record / MDM). "
       "Su scope impacta banco y tienda.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-023","full_name":"Mercedes Espinosa (María Mercedes)","organization":"bancoppel",
     "role_title":"Líder de Arquitectura — Grupo y Servicios Financieros","program_role":"architect",
     "raci":"consulted","seniority":"director","confidence":"inferred","alert":None,
     "relevant_notes":"Establece lineamientos arquitectónicos a nivel grupo. "
       "Rol más de validación/proceso arquitectónico (compliance/certificación) que de definición estratégica.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-024","full_name":"Miguel Bucio","organization":"bancoppel",
     "role_title":"Responsable Interno de Arquitectura / Proceso Arquitectónico Unity","program_role":"architect",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Lleva la gestión del proceso de arquitectura. Trabaja con Luis Barragán. "
       "Tiene conocimiento de la arquitectura documentada para las carpetas CNBV. "
       "Con él el track interno de arquitectura reemplaza a Rino Inside.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-025","full_name":"Raúl Goycolea","organization":"bancoppel",
     "role_title":"Arquitecto Senior","program_role":"architect",
     "raci":"consulted","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Referente técnico senior a mantener cercano. Mencionado junto con Alex como referentes técnicos clave.",
     "source_docs":"19 Marzo - Minutas.docx","active":1},
    {"id":"STK-026","full_name":"Erika Mata","organization":"bancoppel",
     "role_title":"CISO / Cabeza de OSI (Oficina de Seguridad de la Información)","program_role":"stakeholder",
     "raci":"consulted","seniority":"director","confidence":"confirmed",
     "alert":"Agenda muy saturada — conseguir 30 minutos ya sería un logro. Involucrar desde el inicio de decisiones de arquitectura.",
     "relevant_notes":"CISO del banco. Responsable del frente de seguridad transversal. Delegará parte del trabajo en Frank Eduardo Ortiz Iglesias.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-027","full_name":"Frank Eduardo Ortiz Iglesias","organization":"bancoppel",
     "role_title":"Gerente de Seguridad — OSI","program_role":"stakeholder",
     "raci":"consulted","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Contacto operativo de apoyo en temas de seguridad e integración con OSI. Reporta a Erika Mata.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-028","full_name":"Cristóbal Iturbe","organization":"bancoppel",
     "role_title":"Responsable de Estrategia 2030 — Servicios Financieros","program_role":"stakeholder",
     "raci":"informed","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Lleva la estrategia 2030 para servicios financieros. Frente de negocio más que tecnología. Interlocutor clave para el North Star.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-029","full_name":"Cristian Sasueta","organization":"bancoppel",
     "role_title":"Responsable de Datos, Migración y Atlas (temporal)","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Cubre temporalmente por Carolina. Responsable del track de datos/migración y del programa Atlas.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-030","full_name":"Daniel Ángeles Baltazar","organization":"bancoppel",
     "role_title":"Responsable de Infraestructura / IMS / Ambientes","program_role":"stakeholder",
     "raci":"informed","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Juan Manuel no lo ve como el perfil correcto para liderar la estrategia; "
       "lo ubica en un subtrack de infraestructura o IMS. Coordinó la entrega de la tabla de responsables de Legacy.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-031","full_name":"Arturo Pérez","organization":"bancoppel",
     "role_title":"Coordinador / Líder del Frente Legacy","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Coordina al grupo de responsables de sistemas legacy. Fungirá como referente principal del frente Legacy. Karina Zepeda lo conoce.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-032","full_name":"José Luis Bueno","organization":"bancoppel",
     "role_title":"Responsable del Programa Carteras","program_role":"stakeholder",
     "raci":"consulted","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Programa Carteras tiene dependencias relevantes con Unity. Al menos 3 proyectos: desacoplamiento de reglas, modernización de infraestructura, capacidades flexibles.",
     "source_docs":"23 Marzo - Minutas.docx; dt-cronograma.md","active":1},
    {"id":"STK-033","full_name":"Leticia Díaz","organization":"bancoppel",
     "role_title":"Portfolio Manager (demanda TI-Negocio)","program_role":"stakeholder",
     "raci":"informed","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Enlace entre negocio y TI para gestión de demanda, asignación de células y disponibilidad de equipos.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-034","full_name":"Itzel Vargas","organization":"bancoppel",
     "role_title":"Responsable de Priorización y Asignación de Recursos","program_role":"stakeholder",
     "raci":"informed","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Operación organizada en Value Streams / Portafolios.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-035","full_name":"Cinthia Ramírez","organization":"bancoppel",
     "role_title":"HRBP — Tecnología SSFF","program_role":"stakeholder",
     "raci":"informed","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"HRBP para todo el ámbito de tecnología de servicios financieros.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-036","full_name":"Octavio Vázquez","organization":"bancoppel",
     "role_title":"Director de Operaciones (Transact)","program_role":"stakeholder",
     "raci":"consulted","seniority":"director","confidence":"inferred","alert":None,
     "relevant_notes":"Firmó compromisos de validación funcional canal App el 12-jun-2026. Referido como Octavio en minutas.",
     "source_docs":"23 Marzo - Minutas.docx; dt-cronograma.md","active":1},
    {"id":"STK-037","full_name":"José Emiliano Palma","organization":"bancoppel",
     "role_title":"TBD — Gobierno o Negocio","program_role":"stakeholder",
     "raci":"tbd","seniority":"unknown","confidence":"assumed",
     "alert":"Rol no confirmado — preguntar a Tere para definir su ubicación.",
     "relevant_notes":"Aún no queda claro si se integrará del lado de gobierno o permanecerá del lado de negocio.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-038","full_name":"Rodrigo Kennedy","organization":"grupo_coppel",
     "role_title":"Especialista en Estrategia y Assessment — Change Management","program_role":"internal_consultant",
     "raci":"consulted","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Reporta a Gaby Lozada. Involucrado por instrucción de Carlos López-Moctezuma. "
       "3 años en BanCoppel, 20 años previos de consultor. "
       "Realizó diagnóstico de Unity (dic 2025 – ene 2026): 61-65 stakeholders entrevistados, "
       "200+ hallazgos. Conclusión: 75% de los problemas son de gobierno y personas, no tecnológicos. "
       "Identificó 60% de rotación del equipo.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-039","full_name":"Gabriela (Gaby) Lozada","organization":"grupo_coppel",
     "role_title":"Líder del Equipo de Estrategia Grupo (ex-Bain)","program_role":"stakeholder",
     "raci":"informed","seniority":"director","confidence":"inferred",
     "alert":"También referida como Daniela Lozada en una sección — confirmar.",
     "relevant_notes":"Lidera el área de Estrategia a nivel Grupo. Rodrigo Kennedy le reporta. Ex-Bain.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-040","full_name":"Carelli","organization":"bancoppel",
     "role_title":"Chief of Staff (Juan Manuel Fernández Islas)","program_role":"operations",
     "raci":"informed","seniority":"coordinator","confidence":"confirmed","alert":None,
     "relevant_notes":"Punto de contacto con stakeholders para Juan Manuel. Apoyo para coordinación de reuniones y agendas.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    {"id":"STK-041","full_name":"Lisbeth","organization":"bancoppel",
     "role_title":"Asistente Administrativa / Logística","program_role":"operations",
     "raci":"informed","seniority":"support","confidence":"confirmed","alert":None,
     "relevant_notes":"Gestión de espacios y logística de sesiones. Referida como Lis en algunas minutas.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-042","full_name":"Sharon","organization":"bancoppel",
     "role_title":"Directora de Talento","program_role":"stakeholder",
     "raci":"informed","seniority":"director","confidence":"inferred",
     "alert":"Apellido no confirmado.",
     "relevant_notes":"Comunicó la cifra de 60% de rotación del equipo Unity.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-043","full_name":"Ricardo","organization":"bancoppel",
     "role_title":"Control Financiero / Presupuestal","program_role":"stakeholder",
     "raci":"informed","seniority":"manager","confidence":"assumed",
     "alert":"Apellido no confirmado.",
     "relevant_notes":"Junto con Brenda Pichardo lleva las cifras de desviación presupuestal.",
     "source_docs":"23 Marzo - Minutas.docx","active":1},
    # -- Accenture ---------------------------------------------------------------
    {"id":"STK-050","full_name":"Pablo Lorenzo Díaz","organization":"accenture",
     "role_title":"Lead del Equipo ACN en el Engagement","program_role":"acn_lead",
     "raci":"responsible","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Lead visible del equipo Accenture. Vino de España para el engagement. Asignado al plan director y gobierno del programa.",
     "source_docs":"19 Marzo - Minutas.docx; 25 Marzo - Minutas.docx","active":1},
    {"id":"STK-051","full_name":"Karina Nayeli Zepeda Arroyo","organization":"accenture",
     "role_title":"Delivery Lead ACN","program_role":"acn_lead",
     "raci":"responsible","seniority":"director","confidence":"inferred","alert":None,
     "relevant_notes":"Participante en todas las sesiones clave. Conoce bien a Arturo Pérez — puede facilitar el contacto con el frente Legacy.",
     "source_docs":"dt-gobierno.md","active":1},
    {"id":"STK-052","full_name":"Salomón Monroy","organization":"accenture",
     "role_title":"Especialista ACN — Delivery","program_role":"acn_team",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Participante ACN en sesiones de diagnóstico. Debe alinearse con Pablo Madinaveitia en fase 0.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-053","full_name":"Joaquín Navajas Helguero","organization":"accenture",
     "role_title":"Especialista ACN — Delivery / Gobierno","program_role":"acn_team",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Gestiona la agenda de las 12 sesiones introductorias con stakeholders del cliente.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-054","full_name":"Alejandro Alonso García","organization":"accenture",
     "role_title":"Especialista ACN — Delivery","program_role":"acn_team",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Participante ACN en todas las sesiones principales.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-055","full_name":"Omar Patrón","organization":"accenture",
     "role_title":"Especialista ACN — Gobierno y Control Técnico","program_role":"acn_team",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Relevante por los temas de governance y control técnico.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-056","full_name":"Lukasz Pietrzyk","organization":"accenture",
     "role_title":"Especialista Global ACN — Core Banking","program_role":"acn_global_expert",
     "raci":"consulted","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Global specialist de Accenture con expertise en core banking. Refuerza el trabajo en sitio. Referido como Lucas Pietres en notas por transcripción.",
     "source_docs":"23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx","active":1},
    {"id":"STK-057","full_name":"José Luis Navas","organization":"accenture",
     "role_title":"Especialista Global ACN","program_role":"acn_global_expert",
     "raci":"consulted","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Apoya para armar el outline/board del readout del 24 de abril.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-058","full_name":"Pavel Vilosski","organization":"accenture",
     "role_title":"Especialista Global ACN","program_role":"acn_global_expert",
     "raci":"consulted","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Global specialist. Referenciado junto con Navas y Lukasz para el readout del 24 de abril.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-059","full_name":"Joaquín Pichardo","organization":"accenture",
     "role_title":"Especialista ACN — AMS / Operación","program_role":"acn_ams",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Expuso el enfoque de takeover formal desde el release 3 (junio 2026).",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-060","full_name":"Gabriela (Gaby) Maximiliano","organization":"accenture",
     "role_title":"AMS / Takeover Lead — ACN","program_role":"acn_ams",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Vinculada al frente de AMS/takeover/soporte. Tomó assets y plantillas para estructurar el pre y post del takeover.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-061","full_name":"Alfredo García","organization":"accenture",
     "role_title":"Responsable del Plan de Takeover / Soporte — ACN","program_role":"acn_ams",
     "raci":"responsible","seniority":"manager","confidence":"confirmed",
     "alert":"Juan Manuel expresó molestia porque llevaba 3 semanas en el plan sin avanzar suficientemente.",
     "relevant_notes":"Responsable de armar el plan de takeover/soporte postproducción.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    # -- EY (incumbente Transact -- COMPETIDOR) ----------------------------------
    {"id":"STK-070","full_name":"Angélica María Tolosa Bravo","organization":"ey",
     "role_title":"Líder del Track Core Bancario / Transact — EY","program_role":"vendor_lead",
     "raci":"responsible","seniority":"director","confidence":"confirmed",
     "alert":"COMPETIDOR: EY es incumbente en Transact. NUNCA compartir análisis de arquitectura con EY. Validaciones van a BanCoppel, no a EY.",
     "relevant_notes":"Líder de EY en el frente de Temenos Transact. Construye el plan director de Transact. "
       "Actúa como puente entre negocio y tecnología para Transact.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-071","full_name":"Gloria Cecilia Coll Peña","organization":"ey",
     "role_title":"Plan Director Transact — EY","program_role":"vendor_team",
     "raci":"informed","seniority":"specialist","confidence":"confirmed",
     "alert":"COMPETIDOR: EY.",
     "relevant_notes":"Levantamientos, riesgos, dependencias y armado del plan director de Transact. Equipo EY suma 4 personas total.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-072","full_name":"Miguel Medina","organization":"ey",
     "role_title":"Arquitectura Aplicativa e Integraciones — EY","program_role":"vendor_team",
     "raci":"informed","seniority":"specialist","confidence":"confirmed",
     "alert":"COMPETIDOR: EY.",
     "relevant_notes":"Concentrado en arquitectura aplicativa, integraciones y arquitectura transitoria/objetivo para Transact.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    {"id":"STK-073","full_name":"Miguel Romo","organization":"ey",
     "role_title":"Consolidación y Análisis — EY","program_role":"vendor_team",
     "raci":"informed","seniority":"specialist","confidence":"confirmed",
     "alert":"COMPETIDOR: EY.",
     "relevant_notes":"Apoya en consolidación y análisis dentro del equipo de EY para el plan director de Transact.",
     "source_docs":"25 Marzo - Minutas.docx","active":1},
    # -- BPC / AppWhere ----------------------------------------------------------
    {"id":"STK-080","full_name":"Alfredo Aguilar","organization":"appwhere",
     "role_title":"Lead Appwhere","program_role":"vendor_lead",
     "raci":"responsible","seniority":"director","confidence":"confirmed","alert":None,
     "relevant_notes":"Proveedor de App Móvil. Familiarizado con el DUD (Documento Único de Datos).",
     "source_docs":"capability_stakeholders; 23 Marzo - Minutas.docx","active":1},
    # -- Deloitte / Ex-vendors ---------------------------------------------------
    {"id":"STK-090","full_name":"Daniela (apellido no confirmado)","organization":"deloitte",
     "role_title":"Gobierno del Programa (ex-encargada)","program_role":"former_vendor",
     "raci":"informed","seniority":"unknown","confidence":"assumed","alert":None,
     "relevant_notes":"Anteriormente llevaba el gobierno del programa. Deloitte se enfocó en remediación de tarjeta de crédito (salió en marzo). Nombre exacto no confirmado.",
     "source_docs":"25 Marzo - Minutas.docx","active":0},
    {"id":"STK-091","full_name":"Rino (Rino Inside)","organization":"vendor",
     "role_title":"Consultor de Arquitectura — Apolo (saliente)","program_role":"former_vendor",
     "raci":"informed","seniority":"specialist","confidence":"confirmed","alert":None,
     "relevant_notes":"Consultoría de arquitectura para Apolo. Sale en abril 2026 porque Miguel Bucio trae un track interno de arquitectura.",
     "source_docs":"23 Marzo - Minutas.docx","active":0},
    # -- Nuevos: identificados en slide Plan Director acciones 14-ago-2026 -------
    {"id":"STK-092","full_name":"Oscar Melo","organization":"bancoppel",
     "role_title":"Líder Técnico de Integraciones R4","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Owner técnico de las integraciones cross-track: Apolo→SIWEB→CAT→SmartVista. "
       "Co-owner ISSUE-R4-001 (fechas diseño técnico) e ISSUE-R4-004 (inventario integraciones). "
       "Identificado en slide Plan Director 14-ago-2026.",
     "source_docs":"Plan Director — slide acciones críticas 14-ago-2026","active":1},
    {"id":"STK-093","full_name":"Diana Estrada","organization":"bancoppel",
     "role_title":"Track Owner — Canal App / AppMóvil","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable del track de canal digital (App / AppMóvil). "
       "Owner de ISSUE-R4-002: mitigar desfase de 6 HUs Must con implementación en noviembre. "
       "Identificada en slide Plan Director 14-ago-2026.",
     "source_docs":"Plan Director — slide acciones críticas 14-ago-2026","active":1},
    {"id":"STK-094","full_name":"Ramses Santos","organization":"bancoppel",
     "role_title":"Track Owner — CAT (Contact Center)","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Co-owner de ISSUE-R4-003: formalizar contratación del proveedor CAT. "
       "Comparte ownership con Fernanda Barbosa (STK-009). "
       "Identificado en slide Plan Director 14-ago-2026.",
     "source_docs":"Plan Director — slide acciones críticas 14-ago-2026","active":1},
    {"id":"STK-095","full_name":"Marksey Sanvicente","organization":"bancoppel",
     "role_title":"Track Owner — Cobranza","program_role":"track_owner",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Responsable del track de Cobranza, el más opaco del programa: "
       "30-50 HUs estimadas sin compartir al momento de identificación. "
       "Owner de ISSUE-R4-005 (en breach desde 2026-08-07). "
       "Identificado en slide Plan Director 14-ago-2026.",
     "source_docs":"Plan Director — slide acciones críticas 14-ago-2026","active":1},
    {"id":"STK-096","full_name":"Christian Zazueta","organization":"bancoppel",
     "role_title":"Responsable de Despliegue y Estrategia de Release R4","program_role":"delivery",
     "raci":"responsible","seniority":"manager","confidence":"confirmed","alert":None,
     "relevant_notes":"Owner de la estrategia de despliegue R4: runbook, simulacros DR y rollback. "
       "ISSUE-R4-008, due 2026-08-28. "
       "Identificado en slide Plan Director 14-ago-2026.",
     "source_docs":"Plan Director — slide acciones críticas 14-ago-2026","active":1},
]


def load_stakeholders(con: sqlite3.Connection) -> None:
    """Carga roster completo de stakeholders del programa Unity R4 (v1.6.0).
    96 personas: BanCoppel/Grupo Coppel + Accenture + EY (competidor) + AppWhere + Deloitte.
    """
    con.execute("DELETE FROM program_stakeholders")
    cols = ["id","full_name","organization","role_title","program_role",
            "raci","seniority","confidence","alert","relevant_notes","source_docs","active"]
    ph  = ", ".join("?" * len(cols))
    sql = f"INSERT OR REPLACE INTO program_stakeholders ({', '.join(cols)}) VALUES ({ph})"
    con.executemany(sql, [tuple(s.get(c) for c in cols) for s in STAKEHOLDERS])
    con.commit()
    from collections import Counter
    orgs = Counter(s["organization"] for s in STAKEHOLDERS)
    summary = " | ".join(f"{o}:{n}" for o, n in sorted(orgs.items(), key=lambda x: -x[1]))
    active_n = sum(1 for s in STAKEHOLDERS if s.get("active", 1))
    print(f"  program_stakeholders: {len(STAKEHOLDERS)} total ({active_n} activos)  |  {summary}")


# ── Coexistence rules — v1.6.0 ────────────────────────────────────────────────
# 9 reglas de routing Informix<->Unity por tipo de operacion, canal y producto.
# Fuente: dt-coexistencia.md + dt-productos.md + dt-smartvista.md (2026-08-20).
# Formato: (id, description, trigger_cond, channels, product_id, implemented, notes, updated_at)
COEXISTENCE_RULES = [
    ("COE-001",
     "TDC P4900 — nuevas altas van a SmartVista via Apolo (no Informix/CMS)",
     "tipo_operacion IN ('ALTA','ONBOARDING') AND producto_id = 'UNITY-R4-P4900'",
     "apolo", "UNITY-R4-P4900", 0,
     "Regla principal de switch: toda originacion nueva de TDC P4900 entra al sistema destino "
     "SmartVista via Apolo. CMS/Intercard quedan como baseline solo para cartera pre-GoLive. "
     "Confirmado en dt-coexistencia.md y dt-productos.md (Coexistencia: replaces CMS/Intercard/Macweb).",
     "2026-08-20"),
    ("COE-002",
     "TDC P4900 — cartera existente pre-GoLive permanece en Informix/CMS hasta cutover masivo",
     "producto_id = 'UNITY-R4-P4900' AND fecha_alta < '2027-01-15' AND migrado_smartvista IS NULL",
     "app-movil,siweb,cat", "UNITY-R4-P4900", 0,
     "Cartera legacy (~3M tarjetas producto 6001) sigue en Informix hasta migracion masiva de "
     "portafolio. Parallel run aplica solo a nuevas altas P4900. Tolerancia divergencia <=0.05% "
     "por dia. Confirmado dt-coexistencia.md seccion Parallel Run.",
     "2026-08-20"),
    ("COE-003",
     "TDC P4900 — pagos y consultas de saldo post-GoLive van a SmartVista via SVIP",
     "tipo_operacion IN ('PAGO','CONSULTA_SALDO','CONSULTA_MOVIMIENTOS') AND producto_id = 'UNITY-R4-P4900'",
     "app-movil,siweb,cat", "UNITY-R4-P4900", 0,
     "Feature flag por tipo de producto (ADR-UNITY-003 pendiente de firmar). App usa "
     "getInstantCreditStatement y getTransactions v22. CAT via ICCAT->SVIP "
     "(HDU-CAT-R4-02/08 NO CUBIERTO en PreGame). SIWEB via HDU-SIWEB-R4-01 PARCIAL.",
     "2026-08-20"),
    ("COE-004",
     "TDC P4900 — cobranza y gestion de mora van a Cobranza Direccionada + SmartVista (no Informix D40)",
     "tipo_operacion IN ('COBRANZA','GESTION_MORA','AGING','CONTACTO_DEUDOR') AND producto_id = 'UNITY-R4-P4900'",
     "cobranza,cat", "UNITY-R4-P4900", 0,
     "AgingPeriod E1/E2/E3 expuesto por SmartVista via getInstantCreditStatement. Cobranza "
     "Direccionada configura reglas en BPC Banking Technologies. Prerequisito para "
     "HDU-APP-R4-17 (mora visual App) y HDU-CAT-R4-10 (menu IVR por mora). "
     "Integracion via cargas de datos BPC, no microservicios.",
     "2026-08-20"),
    ("COE-005",
     "Reporteria regulatoria CNBV/Banxico TDC P4900 — pipeline DataStage/Atlas (no reporteria Informix)",
     "tipo_operacion = 'REPORTE_REGULATORIO' AND regulador IN ('CNBV','BANXICO','IPAB','CONDUSEF') AND producto_id = 'UNITY-R4-P4900'",
     "atlas", "UNITY-R4-P4900", 0,
     "Cadena: SmartVista BPC -> Temenos TDH -> DataStage -> DWH -> RiskLogic -> reportes CNBV "
     "(R-04-C, calificacion cartera). Aplica una vez pipeline productivo. Riesgo: Bajaware en "
     "decomiso 2027-H1 y alcance R4 no confirmado formalmente (8 riesgos RISK en brain.db). "
     "Fuente: CLAUDE.md Unity seccion Reportes Regulatorios.",
     "2026-08-20"),
    ("COE-006",
     "TDC P4900 — cierre de dia orquestado por Control-M sobre SmartVista (no solo batch Informix)",
     "tipo_operacion = 'CIERRE_DIA' AND producto_id = 'UNITY-R4-P4900'",
     "smartvista", "UNITY-R4-P4900", 0,
     "Control-M orquesta posting diario SmartVista SVBO. Asientos contables via interfaz "
     "SVXP->PISA (brecha critica: SVXP->PISA no construida segun dt-productos.md Fase 07). "
     "Doble batch durante parallel run oct-dic 2026: Informix legacy + SmartVista. "
     "TRNT (tipo transaccion contable) debe estar definido antes de SIT.",
     "2026-08-20"),
    ("COE-007",
     "Productos no P4900 legacy — permanecen en Informix sin cambio de routing",
     "producto_id NOT IN ('UNITY-R4-P4900','UNITY-RX-P-PS','UNITY-R1-P-CE-N2','UNITY-R2-P-CED-N4','UNITY-R3-P-NOM-N4')",
     "app-movil,siweb,cat", None, 1,
     "Regla de continuidad: todos los productos no migrados a Unity (Credito Coppel 6001, "
     "nomina legacy, ahorro legacy, credito automotriz, etc.) siguen en Informix. Sin cambio "
     "de routing. Antipatron a evitar: enrutar mismo cliente a ambos cores sin sesion atomica. "
     "Fuente: dt-coexistencia.md.",
     "2026-08-20"),
    ("COE-008",
     "TDC P4900 — autorizacion de compras via SmartVista SVFE (88 reglas ISO 8583 via E-Global)",
     "tipo_operacion = 'AUTORIZACION_COMPRA' AND producto_id = 'UNITY-R4-P4900'",
     "smartvista", "UNITY-R4-P4900", 0,
     "Flujo: Comercio->E-Global->SmartVista SVFE (88 reglas)->PayTrue (fraude, ciclos 3min "
     "desacoplados)->respuesta ISO. SVFM no licenciado por BanCoppel. Modulo 1: rechazo "
     "inmediato ISO (catalogo BPC). Modulo 2: PayTrue (no sincrono). BIN 42680711. "
     "Fuente: dt-smartvista.md Flujo Autorizacion.",
     "2026-08-20"),
    ("COE-009",
     "TDC P4900 — bloqueo, reposicion y cancelacion de tarjeta van a SmartVista updateCardStatus",
     "tipo_operacion IN ('BLOQUEO_TARJETA','REPOSICION','CANCELACION','REPORTE_ROBO_EXTRAVIO') AND producto_id = 'UNITY-R4-P4900'",
     "app-movil,cat,siweb", "UNITY-R4-P4900", 0,
     "App: HDU-APP-R4-11/12/13 (PARCIAL/NO CUBIERTO). CAT via ICCAT: HDU-CAT-R4-05/06/11/12 "
     "(OTP 4 digitos para desbloqueo; templates SMS MAI_BDT_IC bloqueo, SMS_BDT_IC desbloqueo; "
     "folio robo). Sistemas legacy CMS/Intercard estado DEPRECATED en go-live. "
     "Fuente: dt-smartvista.md + dt-coexistencia.md.",
     "2026-08-20"),
]


# ── Informix migration map — v1.6.0 ───────────────────────────────────────────
# 20 entries: mapeo de dominios Informix hacia sistema Unity de destino.
# Fuente: dt-coexistencia.md + dt-productos.md (2026-08-20).
# Formato: (id, informix_domain, informix_sp, unity_product, migration_fate,
#            migration_status, notes, updated_at)
INFORMIX_MIGRATION_MAP = [
    ("IMM-D07-SV", "D07", None, "smartvista", "replaces", "planned",
     "Emision y ciclo de vida de tarjetas TDC (CMS - Card Management System). SmartVista SVBO "
     "reemplaza nativamente (fate-informix: absorbed, 59%). BIN 42680711. Maquiladores: "
     "Forza/TGS/Tales via Connect-Direct. CMS pasa a STATE:DEPRECATED en go-live R4.",
     "2026-08-20"),
    ("IMM-D08-SV", "D08", None, "smartvista", "replaces", "planned",
     "Autorizador de transacciones TDC (Intercard). SmartVista SVFE con 88 reglas ISO 8583 via "
     "E-Global. fate-informix: absorbed (59% del total). PayTrue como motor de fraude externo. "
     "Intercard pasa a STATE:DEPRECATED en go-live R4.",
     "2026-08-20"),
    ("IMM-D06-SV", "D06", None, "smartvista", "replaces", "planned",
     "Saldos, pagos y estados de cuenta TDC (Macweb). SmartVista SVBO/SVFE gestiona saldos, "
     "PPNGI, MAD, agingPeriod via getInstantCreditStatement. fate-informix: absorbed para "
     "saldos; replicate para logica especifica BanCoppel. Macweb pasa a STATE:DEPRECATED en go-live R4.",
     "2026-08-20"),
    ("IMM-D05-SV", "D05", None, "smartvista", "replaces", "planned",
     "Maquila y personalizacion de plasticos TDC. SmartVista SVCG/Cargen coordina con "
     "OCG->PGP->Connect-Direct. fate-informix: replicate (24%). OCG y Cargen son manuales en R4 "
     "(tickets #13830642 y #13830651 pendientes de automatizar post go-live).",
     "2026-08-20"),
    ("IMM-D03-SV", "D03", None, "smartvista", "replaces", "in_progress",
     "Comisiones y catalogos de tarjeta de credito. SmartVista parametrizable "
     "(HDU-SMART-R4-09: catalogo centralizado homologado con BANXICO). fate-informix: absorbed. "
     "En configuracion PreGame por BPC Banking Technologies.",
     "2026-08-20"),
    ("IMM-D01-TX", "D01", None, "transact", "replaces", "done",
     "Contabilidad general y libro mayor (GL). Temenos Transact como core contable para "
     "productos R1-R3+Rx ya en produccion (done). fate-informix: absorbed para captacion y "
     "credito simple. Para TDC P4900: SVXP->PISA interfaz contable pendiente de construccion "
     "(brecha critica).",
     "2026-08-20"),
    ("IMM-D02-TX", "D02", None, "transact", "replaces", "done",
     "Intereses, cargos y tasas. Transact calcula intereses para Cuenta Efectiva N2/N4 y "
     "Nomina N4 (done). fate-informix: absorbed. Para TDC P4900: SmartVista calcula PPNGI y "
     "MAD; los reporta via SVXP a PISA.",
     "2026-08-20"),
    ("IMM-D04-TX", "D04", None, "transact", "replaces", "done",
     "Cuentas de deposito y captacion (Cuenta Efectiva N2/N4, Nomina N4). Temenos Transact en "
     "produccion desde R1-R3 (done). fate-informix: absorbed. Onboarding via Apolo para nuevas "
     "cuentas digitales.",
     "2026-08-20"),
    ("IMM-D40-COB", "D40", None, "cobranza", "replaces", "planned",
     "Cobranza, aging y cartera vencida TDC. Cobranza Direccionada + SmartVista agingPeriod "
     "E1/E2/E3. 37-50 User Stories pendientes de inventariar (RISK-UNITY-R06 vencido). "
     "fate-informix: replicate (24%). Pentest 15-20 nov conflicto con SIT.",
     "2026-08-20"),
    ("IMM-D41-COB", "D41", None, "cobranza", "replaces", "planned",
     "Contacto con deudor y gestion preventiva (1-29 dias mora). Cobranza Direccionada configura "
     "reglas BPC para restricciones por agingPeriod. fate-informix: replicate. Sin User Story "
     "identificada para gestion preventiva en R4 (brecha Fase 08 dt-productos.md).",
     "2026-08-20"),
    ("IMM-D42-COB", "D42", None, "cobranza", "unknown", "unknown",
     "Cartera en litigio y castigo contable (>120 dias). Politica de castigo requerida por CNBV. "
     "Sin evidencia de diseno en R4. fate: unknown. Fuente: dt-productos.md Fase 08 brechas "
     "regulatorias Cobranza.",
     "2026-08-20"),
    ("IMM-D09-AT", "D09", None, "atlas", "replaces", "planned",
     "Reporteria regulatoria CNBV/Banxico (R-04-C, calificacion cartera, Anexos 33/36). "
     "Cadena: SmartVista->TDH->DataStage->DWH->RiskLogic. fate-informix: replicate. "
     "Riesgo: Bajaware en decomiso 2027-H1; alcance R4 no confirmado formalmente "
     "(8 riesgos RISK en brain.db).",
     "2026-08-20"),
    ("IMM-D10-AT", "D10", None, "atlas", "replaces", "planned",
     "Reportes de portafolio TDC (18 reportes SmartVista: cartera, num tarjetas, apertura por "
     "mes). Atlas/GCP MDM de grupo (retail + banco + Afore). fate-informix: replicate. "
     "Golden Record del cliente hoy en Informix; migracion a Atlas/AlloyDB Fase 2 (pendiente).",
     "2026-08-20"),
    ("IMM-D12-RET", "D12", None, None, "out_of_scope", "unknown",
     "Nomina legacy (credito nomina Coppel sobre PISA/SIF). No en scope R4. Producto "
     "UNITY-R3-P-NOM-N4 en Transact para nuevas nominas; cartera legacy permanece en Informix. "
     "Sin decision de migracion documentada.",
     "2026-08-20"),
    ("IMM-D13-RET", "D13", None, None, "out_of_scope", "unknown",
     "Credito Coppel clasico (producto 6001 legacy, ~3M tarjetas). No en scope R4. "
     "CMS/Intercard legacy siguen activos para esta cartera hasta decision de migracion masiva "
     "de portafolio. Confirmado dt-coexistencia.md y dt-productos.md.",
     "2026-08-20"),
    ("IMM-D15-RET", "D15", None, None, "out_of_scope", "unknown",
     "ATM y cajeros automaticos. No en scope R4. Activacion por ATM es CJ_ATM_01 sin User "
     "Story en R4 (brecha Fase 03 dt-productos.md). Segundo autorizador InterAct Switch/Syndein "
     "para POS/ATM no en scope R4.",
     "2026-08-20"),
    ("IMM-D20-RET", "D20", None, None, "out_of_scope", "unknown",
     "Microseguros y beneficios (seguros vida, accidentes vinculados a TDC). No en scope R4. "
     "Sin evidencia de diseno de migracion. Regulacion CNSF no aplica al scope actual.",
     "2026-08-20"),
    ("IMM-D30-CMP", "D30", None, None, "complements", "planned",
     "Parametros del sistema, catalogos globales y configuracion operativa. fate-informix: "
     "complement (17% del total). Informix y Unity mantienen catalogos sincronizados durante "
     "coexistencia. Antipatron a evitar: IDs de cliente distintos en ambos sistemas.",
     "2026-08-20"),
    ("IMM-D05S-CMP", "D05-SPEI", None, None, "complements", "planned",
     "Pagos SPEI interbancarios. fate-informix: complement. SPEI recibido en Informix/PISA como "
     "core de liquidacion; SmartVista actualiza saldo TDC disponible. HDU-SMART-R4-14 POR "
     "DETERMINAR: exclusion abonos SPEI del limite de credito hasta confirmacion clearing.",
     "2026-08-20"),
    ("IMM-D49-TBD", "D49", None, None, "unknown", "unknown",
     "Administracion del sistema, seguridad operativa y bitacoras internas. Sin decision "
     "documentada en DTs. Prerequisito para decommission: bank-brain.capability_gap() = 0 "
     "(regla B7 CLAUDE.md AM). Fate: unknown hasta analisis completo de SPs.",
     "2026-08-20"),
]

# ── Duplicidad Funcional — Swarm DT-SWAP-01..08 (v1.7.0) ──────────────────────────────
# 23 candidatos. Cada entrada requiere analisis tecnico detallado antes de decidir.
# Agents: DT-SWAP-01 Core Bancario | 02 Tarjetas | 03 Originacion | 04 Canales |
#         DT-SWAP-05 MDM/GoldenRecord | 06 Integracion | 07 Reportes | 08 Cobranza
DUPLICITY_DATA = [
    # ── DT-SWAP-01: Core Bancario Transaccional  (Transact ↔ SIF/Informix) ─────────────
    {
        "id": "DUP-001", "dt_agent": "DT-SWAP-01",
        "capability_domain": "Captacion de cuentas",
        "etb_capability": '["3.2.1","3.2.2","3.2.3","3.2.4"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D04 Captacion (Cuenta N2/N4/Nomina) + D05 Saldos — >800 SPs, Golden Record en Informix",
        "legacy_evidence": "D04 fate=done (Transact en produccion). Golden Record en Informix segun doc CNBV.",
        "new_system": "transact",
        "new_capability": "Temenos Transact R1-R3: Cuenta Efectiva N2, CED N4, Nomina N4 en produccion",
        "overlap_type": "full",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Nuevos clientes en Transact; cartera existente en Informix hasta migracion Golden Record"},{"type":"absorb","prob":"medium","condition":"Cuando Atlas/AlloyDB active como Golden Record y carga inicial Informix->Atlas se realice"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 1,
        "blocker_description": "Golden Record del cliente vive en Informix hoy (doc CNBV). Carga inicial Informix->Atlas no aparece en ningun documento del programa.",
        "decision_dependency": "ADR pendiente: activacion Atlas como Golden Record (Fase 2 sep-2026 sin diseno documentado)",
        "evidence": "Doc CNBV UNITY_v1.0: 'El cliente se generara en la base de datos de Informix (PISA)...Golden Record'. IMM-D04-TX.",
        "status": "candidate",
        "notes": "Coexistencia activa: 3 productos en Transact + cartera legacy en Informix. La decision clave es cuando y como migrar el Golden Record.",
    },
    {
        "id": "DUP-002", "dt_agent": "DT-SWAP-01",
        "capability_domain": "Credito Simple Empresarial",
        "etb_capability": '["3.3.1","3.3.2","3.3.3","3.3.4"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D03 Creditos (priority-ranking #1 Quick Win) + Orion/SFI credito comercial (TASF)",
        "legacy_evidence": "D03 es dominio prioritario. Orion SFI en legacy_systems fate=migrar a Transact.",
        "new_system": "transact",
        "new_capability": "Temenos Transact R4: Credito Simple Empresarial (persona moral) en produccion desde R1-producto",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"Transact captura persona moral nueva; Informix mantiene cartera personal legacy"},{"type":"migrate","prob":"medium","condition":"Si E-MG-03 Decision Paper resulta en migracion de cartera Orion a Transact"}]',
        "recommended_scenario": "complemento", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "L-02 pendiente: Decision Paper Prestamo Simple (E-MG-03). Si migra, requiere plan E-MG-06.",
        "evidence": "CLAUDE.md Unity: dos numeraciones (R1-producto sobre Transact R4-plataforma). IMM-D03-CRE.",
        "status": "candidate",
        "notes": "Segmentos distintos: Transact=persona moral (CSE); Informix=credito personal legacy y cartera Orion. Overlap parcial por motor de credito compartido.",
    },
    {
        "id": "DUP-003", "dt_agent": "DT-SWAP-01",
        "capability_domain": "Saldos y movimientos de cuentas",
        "etb_capability": '["3.2.4","3.17.8"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D05 Saldos (563 SPs, ESB fan_in alto, RETURN WITH RESUME producer)",
        "legacy_evidence": "D05: 563 SPs, Quick Win priority-ranking, RETURN WITH RESUME pattern dominante (5,433 producers en todo Informix).",
        "new_system": "transact",
        "new_capability": "Transact: saldos y extracto cuentas captacion (N2/N4/Nomina) en produccion",
        "overlap_type": "full",
        "scenarios": '[{"type":"absorb","prob":"high","condition":"Transact absorbe D05 para productos migrados; parallel-run obligatorio"},{"type":"coexistence","prob":"medium","condition":"Durante ventana de migracion de portafolio completo"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "medium",
        "migration_blocker": 1,
        "blocker_description": "D05 usa RETURN WITH RESUME (producer pattern): patron no existe en SQL estandar — requiere refactorizacion en Transact. AppMovil consulta D05 via 49 SPs.",
        "decision_dependency": "Definir parallel-run strategy D05: shadow mode o feature flag por segmento de cliente",
        "evidence": "decoupling-cost: D05 hard_blocks altos. AppMovil brain: 49 SPs Informix incluyen D05.",
        "status": "candidate",
        "notes": "Duplicidad activa: App Movil consulta saldos Informix D05. Nueva App consulta Transact para cuentas nuevas e Informix para cartera legacy.",
    },
    # ── DT-SWAP-02: Gestion de Tarjetas  (SmartVista ↔ Intercard/Macweb + Informix D16) ─
    {
        "id": "DUP-004", "dt_agent": "DT-SWAP-02",
        "capability_domain": "CMS ciclo de vida TDC",
        "etb_capability": '["3.5.1","3.5.2"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "Intercard (CMS legacy, producto 6001/6100, ~3M tarjetas) + Informix D16 Tarjetas (311 SPs) + Macweb",
        "legacy_evidence": "~3M tarjetas activas en Intercard. IMM-D16-SV: SmartVista replaces, in_progress.",
        "new_system": "smartvista",
        "new_capability": "SmartVista R1-R3 produccion: CMS, integracion App, tarjeta fisica F&F. R4 = TDC Clasica 4900 (building, go-live ene-2027)",
        "overlap_type": "full",
        "scenarios": '[{"type":"decommission","prob":"high","condition":"Migracion masiva 3M tarjetas portafolio legacy a SmartVista. Sin fecha confirmada."},{"type":"coexistence","prob":"high","condition":"Durante periodo de migracion de portafolio (estimado >12 meses post go-live R4)"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "high",
        "migration_blocker": 1,
        "blocker_description": "3 millones de tarjetas activas en Intercard/legado (producto 6001). La migracion de portafolio no tiene fecha confirmada ni plan tecnico documentado.",
        "decision_dependency": "Decision de migracion de portafolio 3M tarjetas: timing, estrategia batch masiva vs. corte por segmento, rollback.",
        "evidence": "DEF R3: 'Migrara el portafolio actual de 3 millones de tarjetas a SmartVista'. Plan Director: SmartVista amarillo 3 dimensiones. RISK-UNITY-R07.",
        "status": "candidate",
        "notes": "Duplicidad de mayor impacto del programa. Dos CMS en paralelo hasta que la migracion de portafolio se ejecute.",
    },
    {
        "id": "DUP-005", "dt_agent": "DT-SWAP-02",
        "capability_domain": "Autorizacion de transacciones TDC",
        "etb_capability": '["3.5.2","3.4.3"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D16 Tarjetas (311 SPs — paths AIX string concat) + Intercard autorizador",
        "legacy_evidence": "D16 triaje: 311 SPs FORMULA string concat (paths AIX/dbaccess). Reg=100%, riesgo=0% (no aritmetica).",
        "new_system": "smartvista",
        "new_capability": "SmartVista: autorizacion TDC native BPC. HDU-SMART-R4-14 abonos SPEI TBD.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"absorb","prob":"high","condition":"SmartVista absorbe logica D16 cuando portafolio migre (post decommission Intercard)"},{"type":"coexistence","prob":"high","condition":"Mientras coexistan productos en Intercard y SmartVista"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Depende de DUP-004: hasta que el portafolio migre, autorizacion D16 permanece activa.",
        "evidence": "decoupling-cost: D16 low cost. triaje-d16: CNBV CUB Cap.XI + VISA/MC Issuer Rules.",
        "status": "candidate",
        "notes": "D16 tiene costo bajo de desacoplamiento (dominant pattern=string concat AIX paths). Decommission natural cuando portafolio migre a SmartVista.",
    },
    {
        "id": "DUP-006", "dt_agent": "DT-SWAP-02",
        "capability_domain": "Meses con intereses (MCI)",
        "etb_capability": '["3.15.2","3.16.1"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D03 Creditos + D07 Cobranza: logica MCI legacy (calculo cuotas, intereses diferidos)",
        "legacy_evidence": "D03 prioridad Quick Win #1. APP-MF-02 corregida en swarm2 QA v1.4.0.",
        "new_system": "smartvista",
        "new_capability": "SmartVista R4.5: MCI (Meses Con Intereses) en backlog. Design Authority nombra R4.5 sin declarar alcance.",
        "overlap_type": "potential",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Hasta R4.5: Informix legacy atiende MCI para portafolio 6001; SmartVista para nuevas TDC 4900"},{"type":"absorb","prob":"medium","condition":"Post R4.5 si MCI SmartVista cubre todo el portafolio"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Fecha y alcance SmartVista R4.5 no declarados en Design Authority.",
        "evidence": "build-brain.py v1.4.0: TA-SMARTVISTA integrations_api 7->5. dt-plan-director.md: R4.5 MCI backlog.",
        "status": "candidate",
        "notes": "Overlap potencial que se vuelve real cuando R4.5 arranque. Coexistencia natural por segmento de portafolio.",
    },
    # ── DT-SWAP-03: Originacion y Onboarding  (Apolo ↔ SIWEB legacy + Informix D26/D15) ─
    {
        "id": "DUP-007", "dt_agent": "DT-SWAP-03",
        "capability_domain": "Onboarding digital TDC",
        "etb_capability": '["7.1.1","3.1.4","3.2.1"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "SIWEB legacy (originacion en sucursal) + Informix D26 Prospectos (54 SPs, CNBV KYC)",
        "legacy_evidence": "D26: CNBV KYC + PLD. IMM-D01-APO: apolo replaces, in_progress.",
        "new_system": "apolo",
        "new_capability": "Apolo R4: 22 User Stories digitales originacion TDC (canal digital). ADP 17 DTMs REC_* con 8 Critical Breakers.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"Apolo=canal digital (App/Web); SIWEB=canal sucursal. Segmentos de canal distintos por defecto."},{"type":"absorb","prob":"low","condition":"Si SIWEB es eventualmente sustituido por interface Apolo para sucursales"}]',
        "recommended_scenario": "complemento", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Definir si SIWEB tendra onboarding digital propio o permanece como canal diferenciado.",
        "evidence": "track_analysis: Apolo=22 US; SIWEB=5 blocked. audit_findings: SIWEB 'Eliminar Deprecar' en APO pero activo Unity R4 (contradiccion).",
        "status": "candidate",
        "notes": "Overlap por canal: Apolo=digital-first; SIWEB=branch-first. Contradiccion APO vs Unity sobre SIWEB es decision pendiente.",
    },
    {
        "id": "DUP-008", "dt_agent": "DT-SWAP-03",
        "capability_domain": "Validacion KYC y PLD en originacion",
        "etb_capability": '["7.1.2","5.8.1","5.8.2"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D15 LIDE/PLD (CNBV PLD Circular 4/2019 + GAFI Rec.10/11) + D26 Prospectos KYC",
        "legacy_evidence": "D15: reg=100%, riesgo=19% (pld_* patterns). D26: CNBV KYC + CONDUSEF. D15=PLD/Minds AML sistema separado.",
        "new_system": "apolo",
        "new_capability": "Apolo orquesta KYC/PLD llamando a sistemas legacy via integraciones (no reimplementa logica)",
        "overlap_type": "potential",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Apolo orquesta D15/D26 legacy. No hay duplicidad real de logica regulatoria."},{"type":"complement","prob":"medium","condition":"Apolo agrega capa UX y orquestacion; legado provee logica regulatoria"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Confirmar que Apolo llama D15/D26 via integration y no reimplementa logica PLD/KYC.",
        "evidence": "r4_integrations: 15 APIs, 2 Batch. dt-compliance.md: CNBV Art.76 + KYC scope.",
        "status": "candidate",
        "notes": "Overlap de orquestacion, no de logica duplicada. Apolo NO reimplementa reglas PLD/KYC — las delega al legado.",
    },
    {
        "id": "DUP-009", "dt_agent": "DT-SWAP-03",
        "capability_domain": "Gestion documental y contratos",
        "etb_capability": None,
        "legacy_system": "sif-informix",
        "legacy_capability": "OnBase-Prometeo (gestion documental) + D14 Banca Electronica (CNBV Circ.22/2010, 319 SPs)",
        "legacy_evidence": "legacy_systems: OnBase-Prometeo en ecosistema. D14 BEI: 319 SPs.",
        "new_system": "apolo",
        "new_capability": "Apolo R4: generacion de contratos TDC (User Stories en alcance R4)",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"Apolo genera contrato digital; OnBase-Prometeo almacena y gestiona el documento generado"},{"type":"coexistence","prob":"medium","condition":"R4: Apolo genera, OnBase custodia. Post-R4: decision sobre plataforma documental unica."}]',
        "recommended_scenario": "complemento", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "DR-DIG-001: plataforma documental de Digitalizacion. Confirmar si OnBase-Prometeo es el repositorio final de contratos TDC.",
        "evidence": "legacy_systems: OnBase-Prometeo (ambiguedad fusion/separacion en inventario). D14 BEI regulacion CNBV Circ.22/2010.",
        "status": "candidate",
        "notes": "Complementariedad probable: Apolo genera el artefacto digital; OnBase/Digitalizacion lo custodia.",
    },
    # ── DT-SWAP-04: Canales Digitales y Sucursales  (App/SIWEB ↔ legacy + Informix D01) ─
    {
        "id": "DUP-010", "dt_agent": "DT-SWAP-04",
        "capability_domain": "App movil — consulta y operaciones cliente",
        "etb_capability": '["1.1.2","7.1.4"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "AppMovil legacy: 49 SPs en Informix (D01/D05/D03) via 216 Spring Boot microservicios",
        "legacy_evidence": "AppMovil brain: 49 SPs unicos, 11 BDs, 133 referencias (21 Java Constants + 112 properties). 98% cobertura.",
        "new_system": "app-movil",
        "new_capability": "App Movil nueva R4: 18 User Stories TDC F&D (AMARILLO RAG). 6 Must cierran implementacion nov-2026.",
        "overlap_type": "full",
        "scenarios": '[{"type":"absorb","prob":"high","condition":"Nueva App sustituye conexiones a Informix D01/D05 para TDC; legado se mantiene para captacion legacy"},{"type":"coexistence","prob":"high","condition":"Transicion: nueva App para TDC 4900; legado para cuentas captacion N2/N4/Nomina hasta que migren"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "medium",
        "migration_blocker": 1,
        "blocker_description": "49 SPs Informix llamados desde App Movil legacy. Nueva App necesita exponer mismos 49 endpoints (o equivalentes) antes de desconectar el legado.",
        "decision_dependency": "Inventario de feature-parity: nuevos endpoints App vs 49 SPs legacy. Cuales de los 49 SPs seran atendidos por Transact, SmartVista u otro?",
        "evidence": "AppMovil brain: 49 SPs verificados. TA-APP: 6 Must cierran nov. RISK-UNITY-R02: 6 US Must APP cierran posterior a inicio SIT.",
        "status": "candidate",
        "notes": "Duplicidad de canal mas impactante en el corto plazo. Nueva App convive con legado por producto: TDC 4900 en nuevo, captacion legacy en Informix.",
    },
    {
        "id": "DUP-011", "dt_agent": "DT-SWAP-04",
        "capability_domain": "Operaciones de sucursal",
        "etb_capability": '["1.2.1","1.1.1"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "SIWEB legacy (sistema actual sucursales) + Informix D01/D14 (Canal Digital Web + Banca Electronica)",
        "legacy_evidence": "TA-SIWEB: GENERAL/SOLUCION amarillo, ROJO en integraciones. 10 semanas construccion 18-ago=29-oct (2 sem. tarde).",
        "new_system": "siweb",
        "new_capability": "SIWEB nuevo R4: 5 User Stories, estado BLOQUEADO (esperando APIs de Apificacion)",
        "overlap_type": "partial",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"SIWEB nuevo reemplaza funciones R4 especificas; legado mantiene operaciones no migradas"},{"type":"migrate","prob":"medium","condition":"Si SIWEB legacy se decomisiona post-R4 en releases futuros"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Desbloquear SIWEB nuevo: APIs de Apificacion necesarias antes de arrancar desarrollo.",
        "evidence": "program_components: siweb status=blocked. audit_findings: SIWEB 'Eliminar Deprecar' APO vs activo Unity R4 (contradiccion).",
        "status": "candidate",
        "notes": "Contradiccion documentada: Exodus APO clasifica SIWEB como 'Deprecar' pero Unity R4 incluye 5 US activas. Debe resolverse antes del decommission.",
    },
    {
        "id": "DUP-012", "dt_agent": "DT-SWAP-04",
        "capability_domain": "Canal ATM y cajeros automaticos",
        "etb_capability": '["1.2.2"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D15 ATM (SPs legacy cajeros, out_of_scope R4) + InterAct como segundo autorizador POS/ATM",
        "legacy_evidence": "IMM-D15-RET: out_of_scope. 'Sin User Story en R4 (brecha Fase 03 dt-productos.md).'",
        "new_system": "smartvista",
        "new_capability": "SmartVista R5: ATM + tarjetas adicionales deferidos. Plan de trabajo R4_v1: 'disponible R5'.",
        "overlap_type": "potential",
        "scenarios": '[{"type":"tbd","prob":"high","condition":"ATM fuera de scope R4. Decision en R5 sobre si SmartVista maneja ATM o permanece en Informix/Intercard."}]',
        "recommended_scenario": "analizar", "scenario_confidence": "low",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Definir alcance R5: ATM en SmartVista vs. retain en legado vs. smart-passthrough hacia Informix.",
        "evidence": "IMM-D15-RET. Plan de trabajo R4_v1: R5 deferidos = ATM, tarjetas adicionales, incrementos, corresponsales.",
        "status": "candidate",
        "notes": "Out of scope R4. Registrado como candidato para analisis R5. InterAct/Syndein es segundo autorizador POS/ATM — su fate vinculado a esta decision.",
    },
    # ── DT-SWAP-05: MDM y Golden Record  (Atlas GCP ↔ Informix Golden Record + SOC) ──────
    {
        "id": "DUP-013", "dt_agent": "DT-SWAP-05",
        "capability_domain": "Golden Record del cliente (MDM)",
        "etb_capability": '["7.1.1","7.1.3"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "Informix/PISA (PRESENTE): Golden Record autoritativo del cliente segun doc CNBV v1.0",
        "legacy_evidence": "Tres candidatos simultaneos activos: Informix (autoridad hoy), Atlas (Fase 2 sin diseno), Transact (nunca activado para Golden Record).",
        "new_system": "atlas",
        "new_capability": "Atlas Fase 2 (sep-2026, sin diseno documentado): AlloyDB + Cloud Run + Vertex AI para MDM de GRUPO (retail+banco+Afore)",
        "overlap_type": "full",
        "scenarios": '[{"type":"absorb","prob":"medium","condition":"Atlas absorbe Golden Record cuando Fase 2 active y carga inicial Informix->Atlas se realice"},{"type":"coexistence","prob":"high","condition":"Informix sigue siendo Golden Record mientras Atlas Fase 2 no tiene diseno ni plan de carga inicial"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "low",
        "migration_blocker": 1,
        "blocker_description": "Carga inicial Informix->Atlas 'no aparece en ningun documento del programa'. Atlas Fase 2 sin diseno documentado. Sin decision formal sobre quien es el Golden Record autoritativo.",
        "decision_dependency": "ADR obligatorio: cual sistema es el Golden Record autoritativo y cuando ocurre la migracion. Prerequisito para decommission de Informix (Regla B7 AM).",
        "evidence": "audit_findings hallazgo Golden Record. CLAUDE.md Unity: 'Golden Record vive hoy en Informix, no en ATLAS ni en Transact'.",
        "status": "candidate",
        "notes": "ALTA CRITICIDAD. Mayor bloqueador arquitectonico del programa. Decommission de Informix (Exodus Ola 6, 2029-H2) depende de resolver esta duplicidad.",
    },
    {
        "id": "DUP-014", "dt_agent": "DT-SWAP-05",
        "capability_domain": "Deduplicacion de clientes",
        "etb_capability": '["7.1.1","7.1.2"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "sp_compara_nombres (D01, fine-mapping R26) — matching nombres para deduplication",
        "legacy_evidence": "sp_compara_nombres en Informix D01, fan_in no trivial, dominio Canal Digital Web.",
        "new_system": "atlas",
        "new_capability": "Atlas: Vertex AI Vector Search para fuzzy matching (confirmado en architecture notes)",
        "overlap_type": "partial",
        "scenarios": '[{"type":"absorb","prob":"high","condition":"Atlas/Vertex AI absorbe logica compara_nombres cuando Atlas active como Golden Record"},{"type":"coexistence","prob":"medium","condition":"Hasta que Informix se decomisione, ambas logicas coexisten sobre distintos portafolios"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Depende de DUP-013: una vez que Atlas sea Golden Record, la logica de deduplication de Informix se decomisiona.",
        "evidence": "Informix brain fine-mapping R26: sp_compara_nombres D01. CLAUDE.md Unity: 'Atlas usa Vertex AI Vector Search para fuzzy matching'.",
        "status": "candidate",
        "notes": "Overlap derivado de DUP-013. Cuando Atlas sea Golden Record autoritativo, absorbe sp_compara_nombres.",
    },
    {
        "id": "DUP-015", "dt_agent": "DT-SWAP-05",
        "capability_domain": "MDM Grupo — maestro de cliente cross-empresa",
        "etb_capability": None,
        "legacy_system": "sif-informix",
        "legacy_capability": "SOC/TASF (Sistema Operativo Central, 15 modulos, 710 funcionalidades) + Informix D04 maestro cliente",
        "legacy_evidence": "legacy_systems: SOC/TASF core-app, fate=migrar-a-Transact. core_path=0.",
        "new_system": "atlas",
        "new_capability": "Atlas GCP: MDM de GRUPO (retail Coppel, banco, Afore). Scope mas amplio que bancario.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"Atlas=MDM de GRUPO (entidad cliente). SOC=banking operations. Scopes distintos."},{"type":"coexistence","prob":"medium","condition":"Atlas provee Golden Record; SOC mantiene logica bancaria especifica hasta migracion a Transact"}]',
        "recommended_scenario": "complemento", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Confirmar que SOC/TASF migrara a Transact. Si migra, el overlap con Atlas se elimina.",
        "evidence": "legacy_systems: SOC/TASF fate=migrar-a-Transact. Atlas: 'MDM de grupo (retail Coppel, banco y Afore), no solo bancario'.",
        "status": "candidate",
        "notes": "Overlap acotado: Atlas=MDM de grupo (entidad cliente), SOC=mini-core bancario (cuentas y operaciones). Riesgo: datos cliente en SOC y Atlas divergen.",
    },
    # ── DT-SWAP-06: Capa de Integracion  (Apificacion/MuleSoft ↔ IBM BUS + InterAct) ────
    {
        "id": "DUP-016", "dt_agent": "DT-SWAP-06",
        "capability_domain": "ESB — routing y mediacion de mensajes",
        "etb_capability": None,
        "legacy_system": "sif-informix",
        "legacy_capability": "IBM BUS/ACE (IIB): una de las 3 vias validas al core Informix. Routing ESB corporativo.",
        "legacy_evidence": "legacy_systems: IBM BUS core_path=1 (una de las 3 vias). Plan Director: migracion IBM BUS/InterAct -> MuleSoft (contradiccion con Exodus que mantiene Apigee).",
        "new_system": "eglobal",
        "new_capability": "Apificacion transversal Accenture R4 + MuleSoft (objetivo de migracion). 18 integraciones R4 identificadas.",
        "overlap_type": "full",
        "scenarios": '[{"type":"decommission","prob":"medium","condition":"IBM BUS decomisionado cuando MuleSoft cubra todas sus rutas. Sin inventario de APIs documentado."},{"type":"coexistence","prob":"high","condition":"IBM BUS permanece como path critico al core mientras Apificacion cubre solo R4 endpoints"}]',
        "recommended_scenario": "sustituir", "scenario_confidence": "low",
        "migration_blocker": 1,
        "blocker_description": "IBM BUS es UNA DE LAS 3 UNICAS vias al core Informix. No se puede decomisionar hasta que todas sus rutas esten en MuleSoft. Plan Director: 'no tiene plan ni inventario de APIs documentado'.",
        "decision_dependency": "Inventario completo rutas IBM BUS. Confirmar roadmap MuleSoft. Resolver contradiccion Plan Director (MuleSoft) vs Exodus Ola 1 (Apigee).",
        "evidence": "audit_findings: contradiccion API gateway. legacy_systems: IBM BUS core_path=1. CLAUDE.md Unity: 3 unicas vias al core.",
        "status": "candidate",
        "notes": "CONTRADICCION CRITICA entre programas: Plan Director (MuleSoft) vs Exodus (Apigee). Hasta resolver, IBM BUS no puede decomisionarse de forma segura.",
    },
    {
        "id": "DUP-017", "dt_agent": "DT-SWAP-06",
        "capability_domain": "Middleware transaccional en tiempo real",
        "etb_capability": None,
        "legacy_system": "sif-informix",
        "legacy_capability": "InterAct/Syndein (Router/Switch): una de las 3 vias validas al core. Middleware real-time.",
        "legacy_evidence": "legacy_systems: InterAct core_path=1, type=middleware. 'Informix no recibe REST, SOAP, ISO 8583 ni SFTP directo.'",
        "new_system": "eglobal",
        "new_capability": "Apificacion R4: 15 integraciones API nuevas que eventualmente reemplazarian paths de InterAct",
        "overlap_type": "full",
        "scenarios": '[{"type":"decommission","prob":"low","condition":"InterAct decomisionado solo cuando Informix se decomisione (Exodus Ola 6, 2029-H2) o todas sus rutas esten en MuleSoft"},{"type":"coexistence","prob":"high","condition":"InterAct permanece como path critico al core durante toda la vida de Informix"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 1,
        "blocker_description": "InterAct es la via de middleware transaccional real-time al core Informix. Su fate esta acoplado al fate de Informix/PISA.",
        "decision_dependency": "El decommission de InterAct es consecuencia del decommission de Informix, no un prerequisito. Alinear con timeline Exodus Ola 6.",
        "evidence": "CLAUDE.md Unity: '3 unicas vias al core: ODBC/JDBC/SPL, InterAct, IBM BUS.' legacy_systems: InterAct core_path=1.",
        "status": "candidate",
        "notes": "No es un overlap a resolver en R4 — es una dependencia estructural. InterAct vive mientras Informix vive. Apificacion R4 crea un nuevo path; no elimina el existente.",
    },
    {
        "id": "DUP-018", "dt_agent": "DT-SWAP-06",
        "capability_domain": "Pagos SPEI / CoDi interbancarios",
        "etb_capability": '["3.4.3","3.4.1","3.4.2","3.4.4","3.4.5"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D13 TEF (628 SPs, Banxico SPEI/CECOBAN, reg=100%, riesgo=20%) — procesamiento SPEI en core",
        "legacy_evidence": "D13 triaje: Banxico SPEI + CECOBAN. IMM-D05S-CMP: SPEI recibido en Informix/PISA como core de liquidacion.",
        "new_system": "eglobal",
        "new_capability": "Apificacion R4 + SmartVista R4: SPEI abono a TDC. HDU-SMART-R4-14 TBD: exclusion abonos SPEI del limite de credito.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Apificacion orquesta SPEI sobre D13 legacy para nueva TDC. Informix D13 permanece como procesador de liquidacion."},{"type":"complement","prob":"medium","condition":"SmartVista maneja SPEI a nivel TDC; Informix D13 maneja SPEI a nivel cuenta de captacion"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Resolver HDU-SMART-R4-14 TBD: exclusion abonos SPEI del limite de credito. Confirmacion con Banxico/RECO.",
        "evidence": "triaje-d13: D13=Banxico SPEI, 628 SPs. coexistence_rules IMM-D05S-CMP. r4_integrations: SPEI como integracion R4.",
        "status": "candidate",
        "notes": "Apificacion NO reemplaza D13 en R4 — lo orquesta. El overlap es de capa de presentacion, no de procesamiento.",
    },
    # ── DT-SWAP-07: Reporteria Regulatoria  (Unity Reports ↔ legacy batch CTM + D16/D32) ─
    {
        "id": "DUP-019", "dt_agent": "DT-SWAP-07",
        "capability_domain": "Reportes regulatorios CNBV/Banxico",
        "etb_capability": '["5.10.6","4.5.1"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "~20 SPL batch jobs via CTM (D09/D13/D15/D16) + Bajaware (motor generacion, en decomiso Q1-2027)",
        "legacy_evidence": "audit_findings: ~100 reportes por confirmar. Cadena: Informix->DataStage->DWH->RiskLogic/Bajaware->CNBV. RISK-UNITY-R19..R26 (8 riesgos).",
        "new_system": "atlas",
        "new_capability": "Unity Reportes Regulatorios (4to componente CNBV): SmartVista+Transact->TDH->DataStage->DWH->RiskLogic->CNBV. Mismo DWH, diferente fuente.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Legacy batch genera reportes para portafolio Informix; Unity genera para portafolio SmartVista/Transact. Coexistencia por portafolio."},{"type":"decommission","prob":"medium","condition":"Legacy batch decomisionado cuando portafolio migre completamente a SmartVista/Transact"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 1,
        "blocker_description": "RIESGO CRITICO: Bajaware en decomiso Q1-2027 pero arquitectura CNBV lo declara como motor de generacion. IC-83: pipelines DataStage se rompen al decomisar Informix (owner por asignar).",
        "decision_dependency": "Plan de remplazo de Bajaware URGENTE (Q1-2027). Inventario completo reportes (~100 por confirmar). Actualizar documentacion CNBV (hallazgos APO_F01 + SMA_F01).",
        "evidence": "RISK-UNITY-R19 a R26. 'Bajaware en proceso de Baja Q1-2027'. Hallazgo CNBV APO_F01 + SMA_F01.",
        "status": "candidate",
        "notes": "Riesgo mas urgente del componente: Bajaware se decomisiona Q1-2027 sin sustituto definido. Coexistencia es el escenario seguro mientras tanto.",
    },
    {
        "id": "DUP-020", "dt_agent": "DT-SWAP-07",
        "capability_domain": "Reportes de portafolio TDC (SmartVista vs Informix)",
        "etb_capability": '["3.17.8","5.10.6"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D16 Tarjetas + D32 Reports (36 SPs, MC+VISA+CNBV TDC) — reportes emisora en batch CTM",
        "legacy_evidence": "D32: reg=MC+VISA+CNBV TDC. D16: 311 SPs string concat. IMM-D10-AT: atlas replaces portafolio TDC reportes.",
        "new_system": "smartvista",
        "new_capability": "SmartVista: 18 reportes (cartera, numero tarjetas, apertura por mes). Reportes regulatorios BPC nativos.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"SmartVista reporta su portafolio (TDC 4900); D16/D32 reportan portafolio legacy (6001) hasta migracion"},{"type":"decommission","prob":"medium","condition":"D32 decomisionado cuando portafolio 6001 migre completamente a SmartVista"}]',
        "recommended_scenario": "complemento", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Alineado con DUP-004 (migracion portafolio 3M tarjetas). Cuando 6001 migre, D32 se decommissiona.",
        "evidence": "triaje-d16: CNBV CUB Cap.XI + VISA/MC. D32=bdireports. SmartVista 18 reportes en dt-smartvista.md.",
        "status": "candidate",
        "notes": "Complementariedad natural durante migracion. SmartVista para portafolio nuevo 4900; D16/D32 para portafolio legacy 6001.",
    },
    {
        "id": "DUP-021", "dt_agent": "DT-SWAP-07",
        "capability_domain": "Contabilidad y asientos contables",
        "etb_capability": '["5.4.1","5.4.2","5.4.8"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D07 Gestion Deuda + D08 Pagos (asientos contables cobranza/pago) + legacy libro mayor",
        "legacy_evidence": "D07/D08: fate=replicate en IMM. Asientos contables vinculados a CNBV Anexo 33-36.",
        "new_system": "transact",
        "new_capability": "Temenos Transact: genera asientos contables para productos en produccion (captacion, CSE). Reportes Regulatorios incluye contabilidad.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Cada sistema genera asientos para sus propios productos durante migracion"},{"type":"absorb","prob":"medium","condition":"Cuando Informix se decomisione, Transact absorbe todos los asientos"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "high",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Reconciliacion de asientos entre Transact y Informix. Confirmar que el DWH consolida ambas fuentes para reportes CNBV.",
        "evidence": "SME Contabilidad Bancaria CNBV: CUB Anexo 33-36. IMM: D07/D08 fate=replicate. Reportes Regulatorios cadena documentada.",
        "status": "candidate",
        "notes": "Durante coexistencia la reconciliacion contable Transact/Informix es critica para reportes CNBV. El DWH de Reportes Reg. debe consolidar ambas fuentes.",
    },
    # ── DT-SWAP-08: Cobranza y Recuperacion  (Cobranza Direccionada ↔ Informix D07/D40) ─
    {
        "id": "DUP-022", "dt_agent": "DT-SWAP-08",
        "capability_domain": "Motor de cobranza y recuperacion",
        "etb_capability": '["3.3.4","3.3.6"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "D07 Gestion Deuda + D08 Pagos + D40 Cobranza + D41 Contacto Deudor + D42 Cartera Litigio",
        "legacy_evidence": "IMM: D40-D42 fate=replicate/unknown. D07/D08 fate=replicate. RISK-UNITY-R06: Cobranza Direccionada 30-50 HUs sin inventariar.",
        "new_system": "smartvista",
        "new_capability": "Cobranza Direccionada R4: 37-50 User Stories (estimadas, no inventariadas formalmente). SmartVista agingPeriod E1/E2/E3.",
        "overlap_type": "partial",
        "scenarios": '[{"type":"complement","prob":"high","condition":"Cobranza Direccionada cubre TDC 4900 (SmartVista); Informix cubre cartera legacy"},{"type":"migrate","prob":"medium","condition":"Cuando portafolio legacy TDC migre a SmartVista, Cobranza D. absorbe D40-D42"}]',
        "recommended_scenario": "complemento", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "URGENTE: inventariar 30-50 HUs de Cobranza Direccionada (ISSUE-R4-005, breach vencido 2026-08-07). Sin inventario no es posible confirmar el overlap real.",
        "evidence": "ISSUE-R4-005: 'Track Cobranza completamente opaco: 30-50 HUs estimadas sin compartir'. IMM-D40-COB fate=replaces. RISK-UNITY-R06.",
        "status": "candidate",
        "notes": "DATO-REQUERIDO: el overlap real depende del inventario de HUs de Cobranza Direccionada (aun no compartido).",
    },
    {
        "id": "DUP-023", "dt_agent": "DT-SWAP-08",
        "capability_domain": "Reglas de negocio y motor BRM cobranza",
        "etb_capability": '["3.3.4","5.9.2"]',
        "legacy_system": "sif-informix",
        "legacy_capability": "Experian BRM (scoring/elegibilidad) + WebMethods BRM (Software AG) + BRM Coppel (Red Coppel)",
        "legacy_evidence": "legacy_systems: BRM tiene 3 referentes distintos (ambiguedad documentada). Experian=scoring; WebMethods=orquestacion.",
        "new_system": "smartvista",
        "new_capability": "SmartVista R4 + Cobranza Direccionada: reglas cobranza (agingPeriod, restricciones). Sin mencion de reemplazar Experian BRM en R4.",
        "overlap_type": "potential",
        "scenarios": '[{"type":"coexistence","prob":"high","condition":"Experian BRM continua como motor scoring/elegibilidad. SmartVista usa sus propias reglas aging/cobranza."},{"type":"complement","prob":"medium","condition":"Experian alimenta datos a SmartVista; SmartVista actua sobre sus resultados"}]',
        "recommended_scenario": "convivir", "scenario_confidence": "medium",
        "migration_blocker": 0, "blocker_description": None,
        "decision_dependency": "Desambiguar los 3 BRM en la arquitectura. Confirmar si alguno tiene funciones que Cobranza Direccionada o SmartVista vayan a reemplazar en R4.",
        "evidence": "CLAUDE.md Unity desambiguacion: 'BRM tiene tres referentes distintos: WebMethods BRM, Experian BRM, BRM Coppel'. legacy_systems: BRM x3.",
        "status": "candidate",
        "notes": "Overlap potencial por ambiguedad arquitectonica. Hasta desambiguar los 3 BRM y mapear sus funciones, no es posible determinar el overlap real.",
    },
]


def load_coexistence_rules(con: sqlite3.Connection) -> None:
    """v1.6.0 — 9 reglas de coexistencia Informix<->Unity por tipo de operacion y canal.
    Idempotente via INSERT OR REPLACE.
    Fuente: dt-coexistencia.md + dt-productos.md + dt-smartvista.md (2026-08-20).
    """
    con.executemany(
        "INSERT OR REPLACE INTO coexistence_rules "
        "(id, description, trigger_cond, channels, product_id, implemented, notes, updated_at) "
        "VALUES (?,?,?,?,?,?,?,?)",
        COEXISTENCE_RULES,
    )
    con.commit()
    impl = sum(1 for r in COEXISTENCE_RULES if r[5])
    print(f"  coexistence_rules : {len(COEXISTENCE_RULES)} reglas  |  implementadas={impl}")


def load_migration_map(con: sqlite3.Connection) -> None:
    """v1.6.0 — 20 entries: mapeo dominio Informix -> sistema Unity destino.
    Idempotente via INSERT OR REPLACE.
    Fuente: dt-coexistencia.md + dt-productos.md (2026-08-20).
    """
    con.executemany(
        "INSERT OR REPLACE INTO informix_migration_map "
        "(id, informix_domain, informix_sp, unity_product, migration_fate, "
        " migration_status, notes, updated_at) "
        "VALUES (?,?,?,?,?,?,?,?)",
        INFORMIX_MIGRATION_MAP,
    )
    con.commit()
    done = sum(1 for r in INFORMIX_MIGRATION_MAP if r[5] == "done")
    planned = sum(1 for r in INFORMIX_MIGRATION_MAP if r[5] == "planned")
    out = sum(1 for r in INFORMIX_MIGRATION_MAP if r[4] == "out_of_scope")
    print(f"  migration_map     : {len(INFORMIX_MIGRATION_MAP)} entries  |  done={done} planned={planned} out_of_scope={out}")


def load_system_id_mappings(con: sqlite3.Connection) -> None:
    """v1.7.0 — Asigna system_id (y risk_id/hdu_id donde aplica) en tablas secundarias.
    Idempotente: ALTER TABLE con try/except + UPDATE WHERE IS NULL.
    Cubre todas las tablas que necesitan system_id tras --reset.
    """
    # ── ALTER TABLE idempotentes ──────────────────────────────────────────────
    # Garantiza que las columnas existen aunque el DDL de una tabla anterior
    # no las incluya (compatibilidad con DBs creadas antes de v1.7.0).
    for col_ddl in [
        "ALTER TABLE hdu_catalog          ADD COLUMN system_id   TEXT REFERENCES program_systems(id)",
        "ALTER TABLE dtm_catalog          ADD COLUMN system_id   TEXT REFERENCES program_systems(id)",
        "ALTER TABLE dtm_catalog          ADD COLUMN risk_id     TEXT REFERENCES risks(id)",
        "ALTER TABLE apolo_hdu_catalog    ADD COLUMN system_id   TEXT REFERENCES program_systems(id)",
        "ALTER TABLE audit_findings       ADD COLUMN system_id   TEXT REFERENCES program_systems(id)",
        "ALTER TABLE audit_findings       ADD COLUMN risk_id     TEXT REFERENCES risks(id)",
        "ALTER TABLE risks                ADD COLUMN system_id   TEXT REFERENCES program_systems(id)",
        "ALTER TABLE user_stories_inventory ADD COLUMN system_id TEXT REFERENCES program_systems(id)",
        "ALTER TABLE user_stories_inventory ADD COLUMN itcapability_ids TEXT",
        "ALTER TABLE user_stories_inventory ADD COLUMN hdu_id    TEXT REFERENCES hdu_catalog(id)",
    ]:
        try:
            con.execute(col_ddl)
        except Exception:
            pass  # columna ya existe — idempotente
    con.commit()

    # ── user_stories_inventory: track → system_id ────────────────────────────
    track_to_system = {
        "smartvista": "smartvista",
        "cat":        "smartvista",   # canal CAT opera sobre SmartVista APIs
        "siweb":      "smartvista",   # canal SIWEB opera sobre SmartVista APIs
        "apolo":      "apolo",
        "app":        "app-movil",
        "Cobranza":   "cobranza",
        "cobranza":   "cobranza",
    }
    for track, sid in track_to_system.items():
        con.execute(
            "UPDATE user_stories_inventory SET system_id = ? WHERE track = ? AND system_id IS NULL",
            (sid, track),
        )

    # ── risks: component_id → system_id ─────────────────────────────────────
    component_to_system = {
        "smartvista":           "smartvista",
        "apolo":                "apolo",
        "app":                  "app-movil",
        "cat":                  "cat",
        "siweb":                "siweb",
        "cobranza":             "cobranza",
        "apificacion":          "programa",
        "reportes-regulatorios": "atlas",
    }
    for comp_id, sid in component_to_system.items():
        con.execute(
            "UPDATE risks SET system_id = ? WHERE component_id = ? AND system_id IS NULL",
            (sid, comp_id),
        )
    # Riesgos sin component_id (riesgos de programa transversales) → programa
    con.execute(
        "UPDATE risks SET system_id = 'programa' WHERE component_id IS NULL AND system_id IS NULL"
    )

    # ── Tablas de catálogo ───────────────────────────────────────────────────
    con.execute("UPDATE hdu_catalog       SET system_id = 'smartvista' WHERE system_id IS NULL")
    con.execute("UPDATE apolo_hdu_catalog SET system_id = 'apolo'      WHERE system_id IS NULL")
    con.execute("UPDATE dtm_catalog       SET system_id = 'smartvista' WHERE system_id IS NULL")

    # ── audit_findings: hallazgos transversales → programa ───────────────────
    con.execute("UPDATE audit_findings SET system_id = 'programa' WHERE system_id IS NULL")

    con.commit()

    n_us   = con.execute("SELECT COUNT(*) FROM user_stories_inventory WHERE system_id IS NOT NULL").fetchone()[0]
    n_risk = con.execute("SELECT COUNT(*) FROM risks WHERE system_id IS NOT NULL").fetchone()[0]
    n_hdu  = con.execute("SELECT COUNT(*) FROM hdu_catalog WHERE system_id IS NOT NULL").fetchone()[0]
    n_ap   = con.execute("SELECT COUNT(*) FROM apolo_hdu_catalog WHERE system_id IS NOT NULL").fetchone()[0]
    n_dtm  = con.execute("SELECT COUNT(*) FROM dtm_catalog WHERE system_id IS NOT NULL").fetchone()[0]
    n_af   = con.execute("SELECT COUNT(*) FROM audit_findings WHERE system_id IS NOT NULL").fetchone()[0]
    print(f"  system_id_mappings: us={n_us} risks={n_risk} hdu={n_hdu} apolo_hdu={n_ap} dtm={n_dtm} audit={n_af}")


def load_dtm_risks(con: sqlite3.Connection) -> None:
    """v1.7.0 — Crea riesgos en risks desde dtm_catalog y vincula via risk_id.
    Idempotente: INSERT OR IGNORE + UPDATE dtm_catalog.risk_id solo si NULL.
    Genera un riesgo por cada DTM cuyo status no sea closed/mitigado/native.
    Fuente: dtm_catalog (14 DTMs — 5 not_covered, partial, tbd).
    """
    from datetime import date

    dtm_rows = con.execute("""
        SELECT id, funcionalidad_macro, funcion, status, capability_id, system_id
        FROM dtm_catalog
        WHERE status NOT IN ('closed', 'mitigado', 'native')
    """).fetchall()

    created = 0
    linked  = 0
    for dtm_id, func_macro, funcion, status, cap_id, sys_id in dtm_rows:
        raid_id = f"DTM-{dtm_id}"
        if status == "not_covered":
            impact = "critical"
        elif status == "partial":
            impact = "high"
        else:
            impact = "medium"  # tbd

        con.execute(
            """INSERT OR IGNORE INTO risks
               (id, raid_id, description, component_id, impact, probability,
                status, source, system_id, updated_at)
               VALUES (?,?,?,?,?,'medium','open','dtm_catalog',?,?)""",
            (
                raid_id, raid_id,
                f"DTM gap: {func_macro or ''} — {funcion or dtm_id}",
                "smartvista",
                impact,
                sys_id or "smartvista",
                str(date.today()),
            ),
        )
        if con.execute("SELECT changes()").fetchone()[0] > 0:
            created += 1

        # Vincular DTM → risk (solo si aun no tiene risk_id)
        con.execute(
            "UPDATE dtm_catalog SET risk_id = ? WHERE id = ? AND risk_id IS NULL",
            (raid_id, dtm_id),
        )
        if con.execute("SELECT changes()").fetchone()[0] > 0:
            linked += 1

    con.commit()
    total_dtm_risks = con.execute(
        "SELECT COUNT(*) FROM risks WHERE source = 'dtm_catalog'"
    ).fetchone()[0]
    print(f"  dtm_risks         : {total_dtm_risks} riesgos desde DTMs  |  new={created} linked={linked}")


def load_cobranza_placeholders(con: sqlite3.Connection) -> None:
    """v1.7.0 — Inserta 8 User Stories placeholder de Cobranza.
    Se usan hasta que Cobranza formalice su inventario en el Excel de scoring.
    Idempotente: INSERT OR IGNORE por ID sintetico US-COB-NNN.
    """
    placeholders = [
        ("US-COB-001", "cobranza", "Motor de reglas BPC para gestion de cobranza direccionada",
         "tdc-p4900", "Cobranza", "must", "Solucion+Integracion", "Desarrollo+Config",
         None, 3, 5, 2, 0.7, "Alta", "pendiente-levantamiento", "cobranza"),
        ("US-COB-002", "cobranza", "Exposicion aging E1 (0-30 dias) a canales CAT y App",
         "tdc-p4900", "Aging", "must", "Integracion", "Configuracion",
         None, 2, 3, 0, 0.5, "Media", "pendiente-levantamiento", "cobranza"),
        ("US-COB-003", "cobranza", "Exposicion aging E2 (31-60 dias) con restricciones de canal",
         "tdc-p4900", "Aging", "must", "Integracion", "Configuracion",
         None, 2, 3, 0, 0.5, "Media", "pendiente-levantamiento", "cobranza"),
        ("US-COB-004", "cobranza", "Exposicion aging E3 (60+ dias) a gestor y CAT",
         "tdc-p4900", "Aging", "must", "Integracion", "Configuracion",
         None, 2, 3, 0, 0.5, "Media", "pendiente-levantamiento", "cobranza"),
        ("US-COB-005", "cobranza", "Carga batch de datos de cartera vencida desde Informix a BPC",
         "tdc-p4900", "Batch", "must", "Integracion", "Desarrollo",
         None, 2, 4, 0, 0.6, "Alta", "pendiente-levantamiento", "cobranza"),
        ("US-COB-006", "cobranza", "Reporte a Buro de Credito (CNBV obligatorio dia 30)",
         "tdc-p4900", "Regulatorio", "must", "Solucion+Integracion", "Desarrollo+Config",
         None, 3, 5, 1, 0.8, "Alta", "pendiente-levantamiento", "cobranza"),
        ("US-COB-007", "cobranza", "Gestion preventiva digital — contacto previo al vencimiento",
         "tdc-p4900", "Digital", "must", "Solucion", "Desarrollo",
         None, 2, 4, 2, 0.5, "Media", "pendiente-levantamiento", "cobranza"),
        ("US-COB-008", "cobranza", "Restricciones de operacion por nivel de mora en canales",
         "tdc-p4900", "Reglas", "should", "Integracion", "Configuracion",
         None, 3, 4, 0, 0.6, "Media", "pendiente-levantamiento", "cobranza"),
    ]

    con.executemany(
        """INSERT OR IGNORE INTO user_stories_inventory
           (id, track, title, producto, funcionalidad, moscow,
            tipo_solucion, impacto_solucion, reusabilidad,
            num_integraciones, num_criterios, num_pantallas,
            score_ponderado, complejidad, source_doc, system_id)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)""",
        placeholders,
    )
    con.commit()

    total_cob = con.execute(
        "SELECT COUNT(*) FROM user_stories_inventory WHERE track = 'cobranza'"
    ).fetchone()[0]
    inserted = con.execute(
        "SELECT COUNT(*) FROM user_stories_inventory WHERE source_doc = 'pendiente-levantamiento'"
    ).fetchone()[0]
    print(f"  cobranza_ph       : {inserted} placeholders insertados  |  total cobranza={total_cob}")


def load_functional_duplicity(con: sqlite3.Connection) -> None:
    """v1.7.0 — Swarm de 8 DT agents (DT-SWAP-01..08).
    23 candidatos de duplicidad funcional entre sistemas Unity y sistemas legado.
    Cada entrada requiere analisis tecnico detallado para decidir escenario final.
    Idempotente via INSERT OR REPLACE.
    """
    cols = [
        "id", "dt_agent", "capability_domain", "etb_capability",
        "legacy_system", "legacy_capability", "legacy_evidence",
        "new_system", "new_capability", "overlap_type",
        "scenarios", "recommended_scenario", "scenario_confidence",
        "migration_blocker", "blocker_description", "decision_dependency",
        "evidence", "status", "notes",
    ]
    ph  = ", ".join("?" * len(cols))
    sql = f"INSERT OR REPLACE INTO functional_duplicity ({', '.join(cols)}) VALUES ({ph})"
    rows = [tuple(r.get(c) for c in cols) for r in DUPLICITY_DATA]
    con.executemany(sql, rows)
    con.commit()

    by_agent    = {}
    by_scenario = {}
    blockers    = 0
    for r in DUPLICITY_DATA:
        ag = r["dt_agent"]
        by_agent[ag] = by_agent.get(ag, 0) + 1
        sc = r.get("recommended_scenario", "tbd")
        by_scenario[sc] = by_scenario.get(sc, 0) + 1
        if r.get("migration_blocker"):
            blockers += 1

    agent_sum    = " ".join(f"{ag[-2:]}:{n}" for ag, n in sorted(by_agent.items()))
    scenario_sum = " ".join(f"{sc}:{n}" for sc, n in sorted(by_scenario.items()))
    print(f"  functional_dup    : {len(DUPLICITY_DATA)} candidatos  |  blockers={blockers}  |  agents={agent_sum}")
    print(f"                      scenarios: {scenario_sum}")



def load_pending_issues(con):
    """Issues de gestion del programa que no vienen de fuentes estructuradas."""
    con.execute("""
        INSERT OR IGNORE INTO raid_issues
        (id, raid_id, description, component_id, category, severity, current_impact,
         remediation, status, owner, due_date, source, notes, tracks, breach, updated_at)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, (
        "ISSUE-UNITY-I12", "I12",
        "USs de Cobranza Direccionada sin inventariar - 37-50 User Stories identificadas pero no formalizadas en inventario R4",
        "cobranza", "Requerimientos", "high",
        "Sin inventario formal, Cobranza no tiene USs reales en brain.db. RAG y progreso no calculables con precision.",
        "Sesion con Marksey Sanvicente (BanCoppel) para desglosar 37-50 USs antes de fin de agosto 2026.",
        "open", "Marksey Sanvicente / BanCoppel", "2026-08-31",
        "brain-audit-2026-08-20",
        "Brain tiene 8 USs placeholder (source_doc=pendiente-levantamiento). No son requerimientos validados.",
        "Cobranza", 0, "2026-08-20 00:00:00"
    ))
    con.commit()

if __name__ == "__main__":
    main()


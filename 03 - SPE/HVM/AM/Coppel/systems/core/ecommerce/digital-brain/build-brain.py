"""
build-brain.py  --  Coppel Retail eCommerce Digital Brain Builder v1.0.0
Construye brain.db con el conocimiento del ecosistema eCommerce de Coppel.
Fuente: Q&A MS N3 (134 preguntas, 2026-08-06), artefactos SME, memoria de sesión.

Uso:
    python build-brain.py                  # build completo (incremental)
    python build-brain.py --reset          # borra y reconstruye desde cero

Changelog:
    1.0.0  --  2026-09-15  Seed inicial: plataformas, GCP projects, stack tecnológico,
                           capacidades de negocio, riesgos, SLOs, integraciones,
                           vocabulario retail, decisiones de arquitectura, stakeholders.
                           Datos fuente: Q&A MS N3 (2026-08-06), DTs SME v2.0.
"""

import sqlite3
import json
import argparse
from pathlib import Path
from datetime import datetime

DB_PATH = Path(__file__).parent / "brain.db"
ROOT    = Path(__file__).parent.parent

# ── Schema ──────────────────────────────────────────────────────────────────

DDL = """
CREATE TABLE IF NOT EXISTS project_info (
    key   TEXT PRIMARY KEY,
    value TEXT
);

CREATE TABLE IF NOT EXISTS platforms (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    type         TEXT CHECK(type IN ('ecommerce','mobile','store','payments','data','integration')),
    status       TEXT CHECK(status IN ('legacy','active','migrating','planned','deprecated')),
    gcp_project  TEXT,
    service_count INTEGER,
    description  TEXT,
    notes        TEXT,
    updated_at   TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS gcp_projects (
    id            TEXT PRIMARY KEY,
    name          TEXT NOT NULL,
    env           TEXT CHECK(env IN ('prod','staging','dev')),
    purpose       TEXT NOT NULL,
    service_count INTEGER,
    status        TEXT CHECK(status IN ('active','migrating','deprecated')),
    pci_scope     INTEGER DEFAULT 0,
    notes         TEXT
);

CREATE TABLE IF NOT EXISTS technology_stack (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    category     TEXT CHECK(category IN (
                   'backend','frontend','database','infrastructure',
                   'integration','observability','cdn','search',
                   'payments','itsm','ai','ecommerce')),
    version      TEXT,
    gcp_projects TEXT,
    role         TEXT NOT NULL,
    status       TEXT CHECK(status IN ('active','migrating','deprecated','planned','unknown')),
    vendor       TEXT,
    notes        TEXT
);

CREATE TABLE IF NOT EXISTS platform_capabilities (
    id               TEXT PRIMARY KEY,
    name             TEXT NOT NULL,
    domain           TEXT CHECK(domain IN (
                       'ecommerce','omnichannel','fulfillment','payments',
                       'customer','platform','data','operations')),
    description      TEXT,
    current_platform TEXT REFERENCES platforms(id),
    target_platform  TEXT REFERENCES platforms(id),
    coverage_status  TEXT CHECK(coverage_status IN (
                       'native','partial','migrating','not_covered','deprecated')),
    migration_status TEXT CHECK(migration_status IN (
                       'as-is','in-progress','done','blocked','tbd')),
    criticality      TEXT CHECK(criticality IN ('critical','high','medium','low')),
    tech_stack       TEXT,
    notes            TEXT,
    updated_at       TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS risks (
    id          TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    category    TEXT CHECK(category IN (
                  'operational','technical','security','compliance',
                  'migration','commercial','performance')),
    impact      TEXT CHECK(impact IN ('critical','high','medium','low')),
    probability TEXT CHECK(probability IN ('high','medium','low')),
    description TEXT NOT NULL,
    mitigation  TEXT,
    owner       TEXT,
    status      TEXT CHECK(status IN ('open','mitigated','closed','monitoring')),
    source      TEXT,
    notes       TEXT
);

CREATE TABLE IF NOT EXISTS slos (
    id           TEXT PRIMARY KEY,
    name         TEXT NOT NULL,
    capability_id TEXT REFERENCES platform_capabilities(id),
    metric       TEXT NOT NULL,
    target       TEXT NOT NULL,
    current      TEXT,
    window       TEXT DEFAULT '30d',
    status       TEXT CHECK(status IN ('meeting','at_risk','breaching','unknown')),
    notes        TEXT
);

CREATE TABLE IF NOT EXISTS integrations (
    id          TEXT PRIMARY KEY,
    from_sys    TEXT NOT NULL,
    to_sys      TEXT NOT NULL,
    protocol    TEXT CHECK(protocol IN (
                  'REST','GraphQL','gRPC','Pub/Sub','Batch','Event','SFTP','TCP')),
    criticality TEXT CHECK(criticality IN ('critical','high','medium','low')),
    description TEXT,
    status      TEXT CHECK(status IN ('active','migrating','planned','deprecated')),
    notes       TEXT
);

CREATE TABLE IF NOT EXISTS stakeholders (
    id        TEXT PRIMARY KEY,
    name      TEXT NOT NULL,
    org       TEXT CHECK(org IN (
                'coppel','accenture','publicis-sapient','vendor','other')),
    role      TEXT,
    area      TEXT,
    influence TEXT CHECK(influence IN ('high','medium','low')),
    notes     TEXT
);

CREATE TABLE IF NOT EXISTS decisions (
    id        TEXT PRIMARY KEY,
    title     TEXT NOT NULL,
    date      TEXT,
    driver    TEXT,
    decision  TEXT NOT NULL,
    rationale TEXT,
    status    TEXT CHECK(status IN ('active','superseded','under-review')),
    notes     TEXT
);

CREATE TABLE IF NOT EXISTS incidents (
    id           TEXT PRIMARY KEY,
    title        TEXT NOT NULL,
    platform_id  TEXT REFERENCES platforms(id),
    severity     TEXT CHECK(severity IN ('P1','P2','P3','P4')),
    sla_target_bd INTEGER,
    mttr_actual_bd INTEGER,
    description  TEXT,
    root_cause   TEXT,
    date         TEXT,
    status       TEXT CHECK(status IN ('open','resolved','recurring')),
    notes        TEXT
);

CREATE TABLE IF NOT EXISTS vocabulary (
    term       TEXT PRIMARY KEY,
    definition TEXT NOT NULL,
    domain     TEXT,
    acronym    TEXT,
    source     TEXT
);

-- FTS5 -------------------------------------------------------------------------
CREATE VIRTUAL TABLE IF NOT EXISTS stack_fts USING fts5(
    id, name, role, category, notes,
    content='technology_stack', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS capabilities_fts USING fts5(
    id, name, description, domain, notes,
    content='platform_capabilities', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS vocabulary_fts USING fts5(
    term, definition, domain,
    content='vocabulary', content_rowid='rowid'
);
CREATE VIRTUAL TABLE IF NOT EXISTS risks_fts USING fts5(
    id, title, description, mitigation,
    content='risks', content_rowid='rowid'
);
"""

# ── Seed data ────────────────────────────────────────────────────────────────

def load_project_info(con):
    rows = [
        ("name",                       "Digital Brain — Coppel Retail eCommerce"),
        ("version",                    "1.0.0"),
        ("built_at",                   datetime.now().isoformat()),
        ("client",                     "Grupo Coppel — Retail (Tiendas Coppel)"),
        ("engagement",                 "Managed Services N3 + Composable Commerce Migration"),
        ("engagement_stage",           "S0 — propuesta entregada 2026-08-06"),
        ("incumbent",                  "Publicis Sapient (2+ años)"),
        ("platform_count",             "5"),
        ("gcp_project_count",          "5"),
        ("gke_cluster_count",          "14"),
        ("gke_zones",                  "3 zonas, auto-scaling"),
        ("service_count_hcl",          "150+ (cpl-ec-hcl-be-prod, deprecando)"),
        ("apollo_subgraph_count",      "6"),
        ("business_impact_mxn_per_min","180000"),
        ("ticket_volume_steady",       "15 tickets/mes"),
        ("ticket_volume_peak",         "20-25 tickets/mes (Hot Sale + Buen Fin)"),
        ("peak_seasons",               "Hot Sale (mayo) + Buen Fin (noviembre) ~ 6 semanas/año"),
        ("sla_p1_business_days",       "5"),
        ("sla_p2_business_days",       "10"),
        ("sla_p3_business_days",       "15"),
        ("sla_p4_business_days",       "20"),
        ("mttr_actual_business_days",  "20 (Publicis Sapient, no cumple SLA P1)"),
        ("model",                      "Pure N3 — Coppel absorbe N2; Accenture solo N3"),
        ("commercial_model",           "Mixto fijo+variable; NO T&M"),
        ("offices",                    "Culiacán GMT-7 + CDMX GMT-6; 100% remoto"),
        ("platform_strategy",          "HCL Commerce (monolito) → Composable Commerce (SFCC headless + Apollo Federation + Next.js)"),
        ("source",                     "Q&A MS N3 (134 preguntas, 2026-08-06)"),
        ("win_theme",                  "Accenture guardian de la migración composable — conoce el destino, no solo el origen"),
    ]
    con.executemany("INSERT OR REPLACE INTO project_info VALUES (?,?)", rows)


def load_platforms(con):
    rows = [
        # id, name, type, status, gcp_project, service_count, description, notes
        ("hcl-be",
         "HCL Commerce Backend (Legado)",
         "ecommerce", "migrating",
         "cpl-ec-hcl-be-prod", 150,
         "Plataforma eCommerce monolítica IBM/HCL — backend de Coppel.com legado. "
         "En proceso de deprecación mientras se construye la arquitectura Composable.",
         "150+ servicios activos; 15+ servicios marcados 'Deprecado' aún en producción. "
         "Scope N3 cambia durante migración."),

        ("composable",
         "Composable Commerce (Desacople)",
         "ecommerce", "active",
         "cpl-ec-dcplig-prod", None,
         "Arquitectura destino: SFCC headless + Apollo Federation (6 subgraphs) + Next.js. "
         "Proyecto 'Desacople' = migración de HCL a Composable.",
         "Frontends composables; subgraphs Apollo están en construcción incremental."),

        ("app-be",
         "App Backend (iOS/Android)",
         "mobile", "active",
         "cpl-ec-app-be-prod", None,
         "Backend de la aplicación móvil de Coppel (iOS + Android).",
         "Servicios separados del backend web."),

        ("sfcc-apis",
         "SFCC APIs (Salesforce Commerce Cloud)",
         "ecommerce", "active",
         "cpl-ec-sfcc-prod", None,
         "Salesforce Commerce Cloud — usado SOLO como APIs headless: "
         "Basket, Orders, Inventory, Pricing. NO implementado full Salesforce.",
         "Coppel NO usa SFCC como plataforma completa. N3 scope = ajustes sobre custom objects."),

        ("pci-tdc",
         "PCI / Pagos TDC",
         "payments", "active",
         "cpl-ec-pci-tdc-prod", None,
         "Proyecto GCP para procesamiento de pagos con tarjeta de crédito. Perimetro PCI-DSS.",
         "Contiene eGlobal (gateway de pagos). Acceso restringido."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO platforms(id,name,type,status,gcp_project,service_count,description,notes) VALUES (?,?,?,?,?,?,?,?)",
        rows)


def load_gcp_projects(con):
    rows = [
        # id, name, env, purpose, service_count, status, pci_scope, notes
        ("cpl-ec-hcl-be-prod",
         "cpl-ec-hcl-be-prod", "prod",
         "HCL Commerce legacy — backend monolítico de Coppel.com",
         150, "migrating", 0,
         "150+ servicios en GKEs; servicios 'Deprecado' aún en producción son riesgo técnico."),

        ("cpl-ec-dcplig-prod",
         "cpl-ec-dcplig-prod", "prod",
         "Desacople / Composable Commerce — destino de migración",
         None, "active", 0,
         "Frontends composables (Next.js) + subgraphs Apollo Federation. Crece con cada ola de desacople."),

        ("cpl-ec-app-be-prod",
         "cpl-ec-app-be-prod", "prod",
         "App móvil backend (iOS + Android)",
         None, "active", 0,
         "Servicios de backend de la app móvil de Coppel."),

        ("cpl-ec-sfcc-prod",
         "cpl-ec-sfcc-prod", "prod",
         "SFCC APIs — Basket, Orders, Inventory, Pricing",
         None, "active", 0,
         "Proyecto headless SFCC. Solo APIs, no plataforma completa."),

        ("cpl-ec-pci-tdc-prod",
         "cpl-ec-pci-tdc-prod", "prod",
         "Pagos / PCI-DSS perimeter — TDC processing via eGlobal",
         None, "active", 1,
         "Perimetro PCI-DSS. Acceso a proveedor restringido. Contiene eGlobal gateway."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO gcp_projects(id,name,env,purpose,service_count,status,pci_scope,notes) VALUES (?,?,?,?,?,?,?,?)",
        rows)


def load_technology_stack(con):
    rows = [
        # id, name, category, version, gcp_projects, role, status, vendor, notes
        ("nodejs", "Node.js", "backend", None,
         "hcl-be,composable,app-be",
         "Principal lenguaje backend — servicios API y workers",
         "active", "OpenJS Foundation", None),

        ("go", "Go (Golang)", "backend", None,
         "hcl-be,composable",
         "Servicios de alto throughput y microservicios de infraestructura",
         "active", "Google", None),

        ("java", "Java", "backend", None,
         "hcl-be",
         "Servicios legado HCL Commerce y servicios de negocio",
         "active", "Oracle/OpenJDK", None),

        ("python", "Python", "backend", None,
         "hcl-be,composable",
         "Scripts de automatización, ML y servicios de datos",
         "active", "Python Foundation", None),

        ("nextjs", "Next.js", "frontend", None,
         "composable",
         "Frontend composable — destino de migración desde templates HCL",
         "active", "Vercel", "Arquitectura headless/composable destino."),

        ("apollo-federation", "Apollo Federation", "integration", None,
         "composable",
         "GraphQL Federation con 6 subgraphs — API layer de Composable Commerce",
         "active", "Apollo GraphQL",
         "6 subgraphs componen la API. Orquesta llamadas a SFCC, HCL y servicios propios."),

        ("apigee", "Apigee", "integration", None,
         "hcl-be,composable,app-be",
         "API Gateway — gestión de APIs externas e internas",
         "active", "Google Cloud", None),

        ("mongodb", "MongoDB", "database", None,
         "hcl-be,composable",
         "Base de datos NoSQL — catálogo, sesiones, configuraciones",
         "active", "MongoDB Inc.", None),

        ("postgresql", "PostgreSQL", "database", None,
         "hcl-be,composable",
         "Base de datos relacional — transacciones, órdenes, cuentas",
         "active", "PostgreSQL", None),

        ("firestore", "Firestore", "database", None,
         "composable,app-be",
         "Base de datos NoSQL de Google — datos de tiempo real y sesiones app",
         "active", "Google Cloud", None),

        ("firebase", "Firebase", "infrastructure", None,
         "app-be",
         "Plataforma móvil — notificaciones push, auth, analytics",
         "active", "Google Cloud", None),

        ("redis-google", "Redis (Google Cloud)", "database", None,
         "hcl-be,composable",
         "Caches de servicios — sesiones, rate limiting, datos calientes",
         "active", "Google Cloud",
         "Google-managed Redis; NO es el CDN — el CDN es Akamai."),

        ("akamai", "Akamai", "cdn", None,
         "hcl-be,composable",
         "CDN principal de Coppel.com — cache de contenido web y protección DDoS",
         "active", "Akamai Technologies",
         "DATO CONFIRMADO Q&A: Akamai es el CDN, no Redis. Acceso N3 a config CDN por confirmar."),

        ("lucidworks", "LucidWorks", "search", None,
         "composable",
         "Plataforma de búsqueda y PIM — destino de migración de catálogo",
         "active", "LucidWorks Inc.",
         "Coppel migra su PIM a LucidWorks. Integración con Apollo Federation."),

        ("eglobal", "eGlobal", "payments", None,
         "pci-tdc",
         "Gateway de pagos — procesamiento de transacciones con tarjeta",
         "active", "eGlobal",
         "Mismo eGlobal que usa BanCoppel para autorizaciones interbancarias. PCI scope."),

        ("datadog", "Datadog", "observability", None,
         "hcl-be,composable,app-be,sfcc-apis,pci-tdc",
         "Plataforma de observabilidad — métricas, logs, trazas, APM",
         "active", "Datadog Inc.",
         "Nivel 4 — Accenture/proveedor tiene acceso de SOLO LECTURA. "
         "Dashboards, alertas y APM configurados por Coppel. "
         "No disponible configuración de alertas para N3."),

        ("gke", "Google Kubernetes Engine", "infrastructure", None,
         "hcl-be,composable,app-be,sfcc-apis,pci-tdc",
         "Orquestación de contenedores — 14 clusters, 3 zonas, auto-scaling",
         "active", "Google Cloud",
         "14 GKEs distribuidos en 3 zonas. Auto-scaling activo. "
         "Coppel gestiona internamente; proveedor N3 no tiene acceso a plano de control."),

        ("invgate", "InvGate", "itsm", None, None,
         "ITSM actual — gestión de tickets de soporte N3",
         "migrating", "InvGate",
         "Migrando a Salesforce. Coppel provee licencias y ambientes. "
         "Proveedor N3 usa InvGate para recibir y gestionar tickets."),

        ("salesforce-itsm", "Salesforce (ITSM destino)", "itsm", None, None,
         "ITSM destino — reemplaza InvGate para gestión de servicio",
         "planned", "Salesforce",
         "Migración en curso. Fecha no confirmada."),

        ("sfcc", "Salesforce Commerce Cloud (SFCC)", "ecommerce", None,
         "sfcc-apis",
         "APIs de comercio — Basket, Orders, Inventory, Pricing (headless)",
         "active", "Salesforce",
         "Coppel usa SFCC SOLO como APIs headless. NO implementado full Salesforce Commerce. "
         "N3 scope = ajustes sobre custom objects SFCC."),

        ("hcl-commerce", "HCL Commerce", "ecommerce", None,
         "hcl-be-prod",
         "Plataforma eCommerce monolítica legado — Coppel.com AS-IS",
         "migrating", "HCL Technologies",
         "En deprecación. 150+ servicios backend. Destino = Composable Commerce."),

        ("jira", "Jira", "integration", None, None,
         "Tracking de defectos y CI/CD — desarrollo interno Coppel",
         "active", "Atlassian", None),

        ("ado", "Azure DevOps (ADO)", "integration", None, None,
         "CI/CD pipelines — builds y deployments",
         "active", "Microsoft", None),

        ("confluence", "Confluence + CMDB", "integration", None, None,
         "Documentación técnica y CMDB — base de conocimiento Coppel",
         "active", "Atlassian",
         "Proveedor N3 tiene acceso a Confluence para documentación. CMDB disponible."),

        ("voltdb", "VoltDB", "database", None, None,
         "Base de datos en memoria de alta velocidad — uso por confirmar",
         "unknown", "VoltDB Inc.",
         "DATO-REQUERIDO: Rol de VoltDB en stack no documentado en RFP. "
         "Pregunta sin respuesta en Q&A. Puede ser para transacciones de alta frecuencia."),

        ("bits-ai", "BITs AI", "ai", None, None,
         "Plataforma de IA interna de Coppel — uso e integración con N3 por definir",
         "unknown", "Coppel",
         "DATO-REQUERIDO: ¿Qué hace BITs AI y puede N3 integrarse? Pendiente clarificación."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO technology_stack(id,name,category,version,gcp_projects,role,status,vendor,notes) VALUES (?,?,?,?,?,?,?,?,?)",
        rows)


def load_capabilities(con):
    rows = [
        # id, name, domain, description, current_platform, target_platform,
        # coverage_status, migration_status, criticality, tech_stack, notes
        ("CAP-CATALOG",
         "Catálogo de Productos y PIM",
         "ecommerce",
         "Gestión de productos, atributos, imágenes, precios y categorías.",
         "hcl-be", "composable",
         "migrating", "in-progress", "critical",
         "hcl-commerce,lucidworks,sfcc",
         "PIM destino = LucidWorks. Migración en curso."),

        ("CAP-SEARCH",
         "Búsqueda y Descubrimiento",
         "ecommerce",
         "Motor de búsqueda, filtros, relevancia y recomendaciones.",
         "hcl-be", "composable",
         "migrating", "in-progress", "critical",
         "lucidworks,apollo-federation",
         "LucidWorks como destino de búsqueda + PIM."),

        ("CAP-CART-CHECKOUT",
         "Carrito y Checkout",
         "ecommerce",
         "Gestión de carrito, promociones aplicadas, proceso de pago y confirmación.",
         "hcl-be", "composable",
         "migrating", "in-progress", "critical",
         "sfcc,apollo-federation,nextjs,eglobal",
         "Checkout conecta a eGlobal para pagos. KPI: Abandono de carrito."),

        ("CAP-OMS",
         "Gestión de Órdenes (OMS)",
         "fulfillment",
         "Ciclo de vida de la orden: creación, fulfillment, rastreo y devoluciones.",
         "hcl-be", "composable",
         "migrating", "in-progress", "critical",
         "sfcc,apollo-federation,postgresql",
         "SFCC Orders API como destino. Integración con logística."),

        ("CAP-INVENTORY",
         "Gestión de Inventario",
         "fulfillment",
         "Disponibilidad de producto en tiempo real, multi-almacén, reservas.",
         "hcl-be", "sfcc-apis",
         "migrating", "in-progress", "critical",
         "sfcc,apollo-federation",
         "SFCC Inventory API como destino."),

        ("CAP-PRICING",
         "Precios y Promociones",
         "ecommerce",
         "Motor de precios dinámicos, promociones, cupones y descuentos.",
         "hcl-be", "sfcc-apis",
         "migrating", "in-progress", "high",
         "sfcc,apollo-federation",
         "SFCC Pricing API como destino."),

        ("CAP-PAYMENTS",
         "Pagos y PCI",
         "payments",
         "Procesamiento de pagos con tarjeta, tokenización, 3DS, antifraude.",
         "pci-tdc", "pci-tdc",
         "native", "as-is", "critical",
         "eglobal",
         "eGlobal como gateway. Perimetro PCI-DSS. Scope N3 limitado."),

        ("CAP-CUSTOMER-ACCOUNT",
         "Cuenta de Cliente",
         "customer",
         "Registro, login, perfil, historial de compras, direcciones.",
         "hcl-be", "composable",
         "migrating", "in-progress", "high",
         "apollo-federation,postgresql,firebase",
         "Auth via Firebase. Datos en PostgreSQL."),

        ("CAP-LOYALTY",
         "Lealtad y Recompensas",
         "customer",
         "Puntos, recompensas, programa de lealtad Coppel.",
         "hcl-be", None,
         "partial", "tbd", "medium",
         "hcl-commerce",
         "DATO-REQUERIDO: Plataforma destino de loyalty no confirmada en scope Composable."),

        ("CAP-WEB",
         "Canal Web (Coppel.com)",
         "omnichannel",
         "Frontend web — experiencia de compra en desktop y mobile web.",
         "hcl-be", "composable",
         "migrating", "in-progress", "critical",
         "nextjs,akamai,apollo-federation",
         "Destino: Next.js composable. Akamai como CDN. "
         "ATC y Conversión como KPIs críticos."),

        ("CAP-APP",
         "Canal App (iOS/Android)",
         "omnichannel",
         "Aplicación móvil nativa de Coppel — compras, seguimiento, cuenta.",
         "app-be", "app-be",
         "native", "as-is", "critical",
         "firebase,nodejs,go",
         "Backend propio en cpl-ec-app-be-prod. KPI: NPS."),

        ("CAP-API-GATEWAY",
         "API Gateway (Apigee)",
         "platform",
         "Gestión centralizada de APIs — autenticación, throttling, routing, analytics.",
         "hcl-be", "composable",
         "native", "as-is", "high",
         "apigee",
         "Apigee gestiona APIs internas y externas."),

        ("CAP-CDN",
         "CDN y Performance",
         "platform",
         "Distribución de contenido estático, cache, protección DDoS, edge.",
         "hcl-be", "composable",
         "native", "as-is", "critical",
         "akamai",
         "Akamai como CDN principal (CONFIRMADO). Configuración a cargo de Coppel."),

        ("CAP-OBSERVABILITY",
         "Observabilidad y Monitoreo",
         "operations",
         "Métricas, logs, trazas, APM, alertas y dashboards operativos.",
         None, None,
         "partial", "as-is", "high",
         "datadog",
         "Datadog nivel 4 — solo lectura para proveedor N3. "
         "Sin acceso a configuración de alertas. "
         "MTTR actual 20 días con este nivel de visibilidad."),

        ("CAP-ITSM",
         "Gestión de Servicio (ITSM)",
         "operations",
         "Gestión de tickets, SLAs, escalaciones y knowledge base de soporte.",
         None, None,
         "partial", "in-progress", "high",
         "invgate,salesforce-itsm",
         "InvGate actual → Salesforce. Coppel provee licencias. "
         "Proveedor N3 opera desde herramienta de cliente."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO platform_capabilities("
        "id,name,domain,description,current_platform,target_platform,"
        "coverage_status,migration_status,criticality,tech_stack,notes) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        rows)


def load_risks(con):
    rows = [
        # id, title, category, impact, probability, description, mitigation, owner, status, source, notes
        ("RISK-MTTR-001",
         "MTTR actual 20 días vs SLA P1 de 5 días",
         "operational", "critical", "high",
         "Publicis Sapient (incumbente) no cumple el SLA P1 propio de Coppel (5 días hábiles). "
         "MTTR real = 20 días hábiles. Esto es el driver principal del RFP.",
         "Accenture debe demostrar plan creíble de reducción de MTTR con runbooks, "
         "automatización y escalación efectiva.",
         "Accenture", "open",
         "Q&A MS N3 2026-08-06 — Q confirma MTTR 20 días",
         "Win theme principal: reducción de MTTR demostrable."),

        ("RISK-DEPREC-001",
         "Servicios 'Deprecado' aún en producción",
         "technical", "high", "high",
         "15+ servicios marcados como 'Deprecado' en cpl-ec-hcl-be-prod están activos en producción. "
         "Riesgo de incidentes en código sin mantenimiento activo.",
         "Mapear dependencias de servicios deprecados antes del onboarding N3. "
         "Incluir en CMDB. Plan de deprecación real con Coppel.",
         "Coppel", "open",
         "Q&A MS N3 2026-08-06",
         "DATO-REQUERIDO: ¿Cuántos servicios deprecados son críticos? "
         "Sin respuesta completa en Q&A."),

        ("RISK-MIGR-001",
         "Scope N3 cambia durante migración HCL → Composable",
         "migration", "high", "high",
         "En los 12 meses del contrato, los 150+ servicios HCL se irán deprecando. "
         "Los servicios N3 desaparecen o cambian. El scope es dinámico.",
         "Cláusula contractual de revisión de scope trimestral. "
         "Modelo de precio variable cubre variación de tickets. "
         "Knowledge transfer proactivo de HCL a Composable.",
         "Accenture + Coppel", "open",
         "Q&A MS N3 2026-08-06",
         "Win theme: Accenture conoce el destino Composable (no solo HCL)."),

        ("RISK-VOLTDB-001",
         "Rol de VoltDB en stack no documentado",
         "technical", "medium", "medium",
         "VoltDB aparece en el stack pero no se documentó su rol en el RFP. "
         "Si VoltDB es crítico para pagos o inventario en tiempo real, "
         "N3 necesita habilidad específica.",
         "Clarificar rol de VoltDB en el kickoff técnico con Coppel.",
         "Coppel", "open",
         "Q&A MS N3 2026-08-06 — pregunta sin respuesta",
         "DATO-REQUERIDO activo."),

        ("RISK-BITS-001",
         "BITs AI — integración con N3 no definida",
         "technical", "medium", "medium",
         "Plataforma de IA interna de Coppel (BITs AI) mencionada en contexto. "
         "No se sabe si N3 debe integrar, soportar o ignorar BITs AI.",
         "Clarificar scope BITs AI en kickoff. Si es crítico, capacitar equipo N3.",
         "Coppel", "open",
         "Q&A MS N3 2026-08-06 — pregunta sin respuesta",
         "DATO-REQUERIDO activo."),

        ("RISK-N2-BOUNDARY-001",
         "Frontera N2/N2.5/N3 no documentada en RFP",
         "operational", "high", "medium",
         "RFP declara modelo Pure N3 pero existe un N2.5 no documentado. "
         "Sin frontera clara, el equipo N3 recibe tickets fuera de scope.",
         "Definir matriz de escalación N1/N2/N2.5/N3 como entregable de onboarding. "
         "Incluir en contrato.",
         "Accenture + Coppel", "open",
         "Q&A MS N3 2026-08-06 — contradicción Q88 vs Q124",
         "DATO-REQUERIDO: Confirmar si Rust está en scope (Q127 sin respuesta)."),

        ("RISK-SEASON-001",
         "Picos Hot Sale y Buen Fin sin SLAs específicos",
         "performance", "high", "high",
         "Hot Sale (mayo) y Buen Fin (noviembre) generan 20-25 tickets/mes vs 15 de steady state. "
         "Los SLAs actuales no distinguen temporada alta.",
         "Definir guardia semanal activable (~6 semanas/año) con fee adicional. "
         "SLAs diferenciados para temporada (respuesta, no resolución).",
         "Accenture + Coppel", "monitoring",
         "Q&A MS N3 2026-08-06",
         "Modelo comercial: guardias = fee semanal activable. "
         "Contradicción Q88 vs Q124 sobre guardias pendiente de confirmar."),

        ("RISK-KT-001",
         "Knowledge Transfer sin co-existencia con incumbente",
         "operational", "high", "medium",
         "Transición sin co-existencia con Publicis Sapient. "
         "KT solo con equipo interno Coppel (1 mes). "
         "Publicis Sapient lleva 2+ años — conocimiento no documentado.",
         "Plan de KT estructurado con Coppel: Confluence, CMDB, runbooks. "
         "Acceso a Datadog durante onboarding. Periodo shadowing con equipo Coppel.",
         "Accenture", "open",
         "Q&A MS N3 2026-08-06",
         "Onboarding: 2-3 semanas accesos + 1 mes KT = ~6 semanas de riesgo elevado."),

        ("RISK-DATADOG-READONLY-001",
         "Datadog nivel 4 — solo lectura limita diagnóstico N3",
         "operational", "medium", "high",
         "Proveedor N3 tiene acceso de SOLO LECTURA a Datadog. "
         "No puede crear alertas, modificar dashboards ni configurar APM. "
         "Diagnóstico dependiente de visibilidad que Coppel configure.",
         "Solicitar acceso de escritura para alertas N3 durante negociación. "
         "Alternativamente, protocolo de escalación a Coppel para crear alertas.",
         "Coppel", "open",
         "Q&A MS N3 2026-08-06",
         "MTTR de 20 días puede estar relacionado con esta limitación de visibilidad."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO risks("
        "id,title,category,impact,probability,description,mitigation,owner,status,source,notes) "
        "VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        rows)


def load_slos(con):
    rows = [
        # id, name, capability_id, metric, target, current, window, status, notes
        ("SLO-MTTR-P1",
         "MTTR Incidentes P1",
         None,
         "Mean Time to Resolve incidente Prioridad 1",
         "5 días hábiles",
         "20 días hábiles (incumbente Publicis Sapient)",
         "rolling",
         "breaching",
         "SLA contractual de Coppel. Publicis Sapient no cumple. Win theme Accenture."),

        ("SLO-MTTR-P2",
         "MTTR Incidentes P2",
         None,
         "Mean Time to Resolve incidente Prioridad 2",
         "10 días hábiles",
         "desconocido",
         "rolling",
         "unknown",
         "Sin dato de MTTR real para P2 del incumbente."),

        ("SLO-AVAILABILITY-WEB",
         "Disponibilidad Coppel.com",
         "CAP-WEB",
         "Uptime del canal web",
         "99.9%",
         "desconocido",
         "30d",
         "unknown",
         "DATO-REQUERIDO: No confirmado en Q&A. "
         "Impacto: $180,000 MXN/minuto de indisponibilidad."),

        ("SLO-AVAILABILITY-APP",
         "Disponibilidad App Móvil",
         "CAP-APP",
         "Uptime de la app iOS/Android",
         "99.9%",
         "desconocido",
         "30d",
         "unknown",
         "DATO-REQUERIDO: No confirmado en Q&A."),

        ("SLO-TICKET-VOLUME",
         "Volumen de Tickets N3",
         None,
         "Tickets N3 mensuales",
         "15/mes steady state; 20-25/mes temporada alta",
         "15/mes (dato confirmado)",
         "monthly",
         "meeting",
         "Modelo comercial fijo cubre baseline 15 tickets; variable para excedente."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO slos(id,name,capability_id,metric,target,current,window,status,notes) VALUES (?,?,?,?,?,?,?,?,?)",
        rows)


def load_integrations(con):
    rows = [
        # id, from_sys, to_sys, protocol, criticality, description, status, notes
        ("INT-001", "Next.js Frontend", "Apollo Federation",
         "GraphQL", "critical",
         "Frontend composable consulta API unificada via Apollo Federation",
         "active", "6 subgraphs componen la API GraphQL"),

        ("INT-002", "Apollo Federation", "SFCC APIs",
         "REST", "critical",
         "Subgraphs de Apollo consumen APIs SFCC: Basket, Orders, Inventory, Pricing",
         "active", None),

        ("INT-003", "Apollo Federation", "HCL Commerce",
         "REST", "high",
         "Durante coexistencia, Apollo llama a servicios HCL no migrados aún",
         "migrating",
         "Se depreca conforme avanza el desacople."),

        ("INT-004", "GKE Services", "eGlobal",
         "REST", "critical",
         "Servicios de checkout conectan a eGlobal para procesamiento de pagos",
         "active", "PCI scope. Tokenización y 3DS."),

        ("INT-005", "Apigee", "GKE Services",
         "REST", "high",
         "API Gateway Apigee enruta llamadas externas a servicios internos en GKE",
         "active", None),

        ("INT-006", "GKE Services", "MongoDB",
         "TCP", "high",
         "Servicios backend conectan a MongoDB para catálogo y configuraciones",
         "active", None),

        ("INT-007", "GKE Services", "PostgreSQL",
         "TCP", "critical",
         "Servicios de órdenes y cuentas usan PostgreSQL como store transaccional",
         "active", None),

        ("INT-008", "GKE Services", "Firestore",
         "REST", "medium",
         "Servicios app y composable usan Firestore para datos de tiempo real",
         "active", None),

        ("INT-009", "Akamai CDN", "GKE Services",
         "REST", "critical",
         "Akamai enruta tráfico de Coppel.com a servicios GKE (cache miss)",
         "active", "Akamai es el CDN principal, no Redis."),

        ("INT-010", "GKE Services", "LucidWorks",
         "REST", "high",
         "Servicios de búsqueda y catálogo consultan LucidWorks (PIM destino)",
         "migrating",
         "LucidWorks recibe migración de PIM desde HCL Commerce."),

        ("INT-011", "InvGate / Salesforce", "Datadog",
         "REST", "medium",
         "ITSM recibe alertas y métricas de Datadog para gestión de tickets N3",
         "active",
         "Solo lectura en Datadog para proveedor N3."),

        ("INT-012", "Apollo Federation", "Servicios propios GKE",
         "GraphQL", "high",
         "Subgraphs Apollo resuelven queries en servicios Node.js/Go/Java propios",
         "active", "100+ servicios en GKEs"),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO integrations(id,from_sys,to_sys,protocol,criticality,description,status,notes) VALUES (?,?,?,?,?,?,?,?)",
        rows)


def load_stakeholders(con):
    rows = [
        # id, name, org, role, area, influence, notes
        ("STK-ACCENTURE-01",
         "Accenture Engagement Team", "accenture",
         "Delivery Partner N3", "Digital Core / SPE",
         "high",
         "Equipo Accenture propuesto para MS N3 + advisory composable."),

        ("STK-PUBLICIS-01",
         "Publicis Sapient", "publicis-sapient",
         "Incumbente N3", "eCommerce Support",
         "high",
         "2+ años gestionando N3. Participa en el RFP. "
         "MTTR actual 20 días hábiles — no cumple SLA P1."),

        ("STK-COPPEL-TECH",
         "Equipo Tecnología Coppel", "coppel",
         "N2 interno + KT partner", "eCommerce Tech",
         "high",
         "Absorbe N2 internamente. Partner de KT en transición (1 mes). "
         "Provee licencias Datadog, InvGate, Confluence."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO stakeholders(id,name,org,role,area,influence,notes) VALUES (?,?,?,?,?,?,?)",
        rows)


def load_decisions(con):
    rows = [
        # id, title, date, driver, decision, rationale, status, notes
        ("ADR-COPPEL-001",
         "Arquitectura Headless / Composable Commerce",
         "2024", "Coppel Tech Strategy",
         "Adoptar SFCC headless + Apollo Federation + Next.js como destino de plataforma eCommerce, "
         "migrando desde HCL Commerce monolítico.",
         "HCL Commerce limita velocidad de innovación y time-to-market. "
         "Composable permite deploys independientes por capability. "
         "SFCC solo como APIs (Basket, Orders, Inventory, Pricing) — no full platform.",
         "active",
         "Proyecto 'Desacople' = ejecución de este ADR. "
         "En 12 meses del contrato N3, los 150+ servicios HCL se deprecarán."),

        ("ADR-COPPEL-002",
         "Modelo Pure N3 — Coppel absorbe N2",
         "2026", "Coppel Operaciones",
         "Coppel absorbe N1 y N2 internamente. Proveedor externo atiende exclusivamente N3.",
         "Reducir dependencia de proveedor en soporte de primer y segundo nivel. "
         "Concentrar proveedor externo en problemas técnicos complejos.",
         "active",
         "Impacta sizing: 4.5 FTE Año 1 / 4.0 FTE Año 2+. "
         "Modelo comercial mixto: fijo (baseline 15 tickets) + variable (excedente)."),

        ("ADR-COPPEL-003",
         "Akamai como CDN principal (no Redis)",
         "2026", "Q&A RFP MS N3",
         "Akamai es el CDN principal de Coppel.com. Redis se usa para caches de servicios, no CDN.",
         "Confirmado en Q&A de 134 preguntas. Corrige asunción anterior en artefactos.",
         "active",
         "DT-SME-GCP.md v1.0 requería corrección de este punto."),

        ("ADR-COPPEL-004",
         "SFCC = solo APIs headless (no full platform)",
         "2026", "Q&A RFP MS N3",
         "Salesforce Commerce Cloud se usa EXCLUSIVAMENTE como APIs: Basket, Orders, Inventory, Pricing. "
         "NO está implementado como plataforma full Salesforce.",
         "Confirmado en Q&A. Corrige asunción inicial de DT-SME-SFCC.md v1.0.",
         "active",
         "N3 scope SFCC = ajustes sobre custom objects. "
         "DT-SME-SFCC.md v2.0 corregido."),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO decisions(id,title,date,driver,decision,rationale,status,notes) VALUES (?,?,?,?,?,?,?,?)",
        rows)


def load_vocabulary(con):
    rows = [
        # term, definition, domain, acronym, source
        ("HCL Commerce",
         "Plataforma de eCommerce monolítica de IBM/HCL — legado de Coppel.com. "
         "En proceso de deprecación hacia Composable Commerce.",
         "ecommerce", None, "RFP"),

        ("Composable Commerce",
         "Arquitectura eCommerce modular: SFCC headless + Apollo Federation (6 subgraphs) + Next.js. "
         "Proyecto 'Desacople' = migración de HCL a esta arquitectura.",
         "ecommerce", None, "Q&A"),

        ("Desacople",
         "Proyecto de migración de HCL Commerce a arquitectura Composable Commerce. "
         "Cada ola migra un conjunto de capacidades.",
         "ecommerce", None, "Q&A"),

        ("SFCC",
         "Salesforce Commerce Cloud — usado por Coppel SOLO como APIs headless "
         "(Basket, Orders, Inventory, Pricing). NO implementación full Salesforce.",
         "ecommerce", "SFCC", "Q&A ADR-COPPEL-004"),

        ("Apollo Federation",
         "Capa de GraphQL Federation con 6 subgraphs que componen la API unificada "
         "de Composable Commerce. Orquesta llamadas a SFCC, servicios propios y (temporalmente) HCL.",
         "ecommerce", None, "Q&A"),

        ("GKE",
         "Google Kubernetes Engine — 14 clusters distribuidos en 3 zonas con auto-scaling. "
         "Infraestructura de contenedores de Coppel.com.",
         "infrastructure", "GKE", "Q&A"),

        ("eGlobal",
         "Gateway de pagos de Coppel para procesamiento de transacciones con tarjeta. "
         "Mismo eGlobal que usa BanCoppel para autorizaciones interbancarias. Perimetro PCI.",
         "payments", None, "Q&A + BanCoppel context"),

        ("Akamai",
         "CDN principal de Coppel.com. Distribuye contenido estático, cacha páginas "
         "y protege contra DDoS. Confirmado en Q&A (no Redis).",
         "infrastructure", None, "Q&A ADR-COPPEL-003"),

        ("LucidWorks",
         "Plataforma de búsqueda y PIM destino. Coppel migra su catálogo de productos "
         "desde HCL a LucidWorks. Integrado con Apollo Federation.",
         "ecommerce", None, "Q&A"),

        ("Datadog",
         "Plataforma de observabilidad de Coppel.com — métricas, logs, trazas y APM. "
         "Proveedor N3 tiene acceso SOLO LECTURA (nivel 4). "
         "Sin acceso a configuración de alertas.",
         "observability", None, "Q&A"),

        ("InvGate",
         "Herramienta ITSM actual de Coppel — gestión de tickets de soporte N3. "
         "En migración a Salesforce. Coppel provee licencias.",
         "operations", None, "Q&A"),

        ("ATC",
         "Add-to-Cart rate — KPI de conversión: porcentaje de usuarios que agregan "
         "al menos un producto al carrito.",
         "ecommerce", "ATC", "Q&A"),

        ("Conversión",
         "Tasa de compra completada vs. visitas totales. KPI primario de eCommerce.",
         "ecommerce", None, "Q&A"),

        ("Abandono",
         "Tasa de abandono de carrito — porcentaje de usuarios que añaden al carrito "
         "pero no completan la compra.",
         "ecommerce", None, "Q&A"),

        ("NPS",
         "Net Promoter Score — KPI de satisfacción del cliente de la app móvil.",
         "customer", "NPS", "Q&A"),

        ("Hot Sale",
         "Temporada de ventas de mayo en México — pico de tráfico y transacciones en Coppel.com. "
         "~15-20 días. Parte de las ~6 semanas de temporada alta al año.",
         "operations", None, "Q&A"),

        ("Buen Fin",
         "Temporada de ventas de noviembre en México (equivalente a Black Friday). "
         "Pico máximo de tráfico de Coppel.com. Parte de las ~6 semanas de temporada alta.",
         "operations", None, "Q&A"),

        ("N3",
         "Nivel 3 de soporte — resolución de problemas técnicos complejos que escalan "
         "desde N2. Coppel: solo tickets problema (problem tickets), no incidentes de N1.",
         "operations", "N3", "RFP"),

        ("Pure N3",
         "Modelo de soporte donde Coppel absorbe N1 y N2 internamente. "
         "El proveedor externo atiende exclusivamente N3.",
         "operations", None, "ADR-COPPEL-002"),

        ("Publicis Sapient",
         "Incumbente del contrato N3 de Coppel (2+ años). "
         "MTTR actual 20 días hábiles — no cumple SLA P1 de 5 días. "
         "Driver del RFP.",
         "operations", None, "Q&A"),

        ("MTTR",
         "Mean Time to Resolve — tiempo promedio de resolución de un incidente. "
         "SLA P1: 5 días hábiles. Actual (Publicis Sapient): 20 días hábiles.",
         "operations", "MTTR", "Q&A"),

        ("VoltDB",
         "Base de datos en memoria de alta velocidad presente en el stack de Coppel. "
         "DATO-REQUERIDO: Rol específico no documentado en RFP.",
         "data", None, "Q&A — pregunta sin respuesta"),

        ("BITs AI",
         "Plataforma de Inteligencia Artificial interna de Coppel. "
         "DATO-REQUERIDO: Uso e integración con soporte N3 no definidos.",
         "ai", None, "Q&A — pregunta sin respuesta"),

        ("ATLAS",
         "Sistema MDM (Master Data Management) de nivel Grupo Coppel. "
         "Sirve a Tiendas Coppel, BanCoppel y Afore Coppel como Golden Record unificado. "
         "Infraestructura GCP/AlloyDB.",
         "data", None, "BanCoppel context"),

        ("Impacto negocio",
         "$180,000 MXN por minuto de indisponibilidad de Coppel.com. "
         "Costo base para calcular el valor de mejoras en disponibilidad.",
         "operations", None, "Q&A"),
    ]
    con.executemany(
        "INSERT OR REPLACE INTO vocabulary(term,definition,domain,acronym,source) VALUES (?,?,?,?,?)",
        rows)


def rebuild_fts(con):
    for tbl in ("stack_fts", "capabilities_fts", "vocabulary_fts", "risks_fts"):
        try:
            con.execute(f"INSERT INTO {tbl}({tbl}) VALUES('rebuild')")
        except Exception:
            pass


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Build Coppel Retail eCommerce Digital Brain")
    parser.add_argument("--reset", action="store_true", help="Borra brain.db y reconstruye desde cero")
    args = parser.parse_args()

    if args.reset and DB_PATH.exists():
        DB_PATH.unlink()
        print(f"[reset] {DB_PATH.name} eliminado.")

    con = sqlite3.connect(DB_PATH)
    con.executescript(DDL)
    con.execute("PRAGMA journal_mode=WAL")
    con.execute("PRAGMA foreign_keys=ON")

    load_project_info(con)
    load_platforms(con)
    load_gcp_projects(con)
    load_technology_stack(con)
    load_capabilities(con)
    load_risks(con)
    load_slos(con)
    load_integrations(con)
    load_stakeholders(con)
    load_decisions(con)
    load_vocabulary(con)
    rebuild_fts(con)

    con.commit()
    con.close()

    # Summary
    con2 = sqlite3.connect(DB_PATH)
    tables = [r[0] for r in con2.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE '%_fts%'"
    ).fetchall()]
    print(f"\nBrain construido: {DB_PATH}")
    print(f"{'Tabla':<30} {'Filas':>6}")
    print("-" * 38)
    for t in sorted(tables):
        n = con2.execute(f"SELECT COUNT(*) FROM [{t}]").fetchone()[0]
        print(f"{t:<30} {n:>6}")
    con2.close()
    print("\nListo. Ejecuta build-portal.py para regenerar el portal HTML.")


if __name__ == "__main__":
    main()

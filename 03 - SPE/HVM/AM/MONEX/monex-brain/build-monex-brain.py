"""
build-monex-brain.py — ETL pipeline: construye monex-brain.db federado.
Registra todos los sistemas del landscape y (cuando existen) ATTACHa sus brain.db.

Usage:
    python build-monex-brain.py
"""
import sqlite3
import json
from pathlib import Path
import panorama_data as pdat

BASE = Path(__file__).parent
BRAIN_DB = BASE / "monex-brain.db"
SYSTEMS_BASE = BASE.parent / "systems"

SYSTEMS = [
    # slug, display_name, category, togaf_type, togaf_state, status, description
    ("fx-engine",           "FX Engine",              "core",        "core",        "baseline",    "SCAFFOLD",  "Motor FX: spot, forwards, opciones, NDF"),
    ("treasury",            "Treasury Management",    "core",        "core",        "baseline",    "SCAFFOLD",  "TMS — posiciones, límites y liquidez"),
    ("payments-legacy",     "Payments Legacy",        "core",        "core",        "baseline",    "SCAFFOLD",  "Motor de pagos legacy (será reemplazado por Motor de Pagos Apolo)"),
    ("mulesoft",            "MuleSoft Anypoint",      "integration", "integration", "baseline",    "CONFIRMED", "API Gateway Anypoint — backbone de integración MONEX"),
    ("swift",               "SWIFT Connectivity",     "integration", "integration", "baseline",    "SCAFFOLD",  "Mensajería SWIFT — pagos internacionales MT/MX"),
    ("spei",                "SPEI / DIOR",            "integration", "integration", "baseline",    "SCAFFOLD",  "Conectividad Banxico SPEI + DIOR reporting"),
    ("portal-clientes",     "Portal Clientes",        "channels",    "channels",    "baseline",    "SCAFFOLD",  "Portal web/app clientes — FX, pagos, estatus"),
    ("api-marketplace",     "API Marketplace",        "channels",    "channels",    "baseline",    "SCAFFOLD",  "API B2B — corporativos y corresponsales"),
    ("golden-record-target","Golden Record (TO-BE)",  "data",        "data",        "target",      "TARGET",    "MDM centralizado — primera vez que MONEX tendrá data model canónico"),
    ("cnbv-banxico",        "CNBV / Banxico Reporting","compliance",  "compliance",  "baseline",    "SCAFFOLD",  "Reporting regulatorio CNBV + DIOR/SPEI Banxico + AML/PLD"),
    ("dora",                "DORA Compliance",        "compliance",  "compliance",  "baseline",    "SCAFFOLD",  "Digital Operational Resilience Act — operaciones UK/EU"),
]

DIGITAL_TWINS = [
    ("dt-motor-pagos",         "Motor de Pagos",           "¿Qué sistemas tocan un pago desde instrucción hasta liquidación?"),
    ("dt-fx-next",             "FX Next",                  "¿Cómo fluye una operación FX desde cotización hasta settlement CLS?"),
    ("dt-golden-record",       "Golden Record",            "¿Qué sistemas son fuente de datos maestros y cómo se resuelven conflictos?"),
    ("dt-plataforma-apolo",    "Plataforma Apolo",         "¿Cómo es el path de decommission del legado capability por capability?"),
    ("dt-integracion-semantica","Integración Semántica",   "¿Qué APIs están gobernadas por la ontología OWL y cuáles quedan fuera?"),
    ("dt-regulatorio",         "Regulatorio",              "¿Qué sistemas alimentan qué reportes regulatorios (CNBV · Banxico · FCA)?"),
    ("dt-liquidacion-cls",     "Liquidación CLS",          "¿Cuál es la arquitectura de conectividad CLS y qué gaps bloquean el acceso?"),
    ("dt-itom",                "ITOM Overlay",             "¿Qué sistemas tienen cobertura operacional real y dónde están los gaps de operación?"),
    ("dt-inteligencia-negocio","Inteligencia de Negocio",  "¿Cuál es el contexto estratégico, competitivo y de mercado de MONEX — especialmente para la oportunidad de pagos?"),
    ("dt-productos",           "Portafolio de Productos",  "¿Qué vende MONEX hoy y cómo mueve dinero cada producto — correlación producto × tipo de pago?"),
]

# ETB Banking V5.0 — capacidades L3 relevantes para MONEX
# Fuente: Banking ETB V5.0 (261 L3 totales)
# Scope MONEX: Pagos (3.x), Datos (5.x), Riesgo/FX (6.x), Tecnología (7.x)
ETB_L3_MONEX = [
    # (l3_id, l1, l2, l3_name, domain_relevance, monex_status)
    # L1-3: Servicios de Pago
    ("3.1.1", 3, 1, "Instrucción pagos domésticos",          "pagos",     "PARTIAL"),
    ("3.1.2", 3, 1, "Instrucción pagos internacionales",     "pagos",     "PARTIAL"),
    ("3.1.3", 3, 1, "Pagos en tiempo real (SPEI/FPS/SCT)",   "pagos",     "PARTIAL"),
    ("3.2.1", 3, 2, "Mensajería ISO 20022",                  "mensajeria","NOT_COVERED"),
    ("3.2.2", 3, 2, "Mensajería SWIFT MT (legacy)",          "mensajeria","COVERED"),
    ("3.3.1", 3, 3, "Liquidación bruta (RTGS)",              "liquidacion","PARTIAL"),
    ("3.3.2", 3, 3, "Settlement PvP (CLS)",                  "liquidacion","COVERED"),
    ("3.4.1", 3, 4, "Conciliación de pagos",                 "operacion", "PARTIAL"),
    ("3.4.2", 3, 4, "Gestión de excepciones de pago",        "operacion", "PARTIAL"),
    ("3.5.1", 3, 5, "AML screening en tiempo real",          "compliance","PARTIAL"),
    ("3.5.2", 3, 5, "Reporting DIOR/regulatorio pagos",      "regulacion","COVERED"),
    # L1-5: Gestión de Datos
    ("5.1.1", 5, 1, "Master Data Management (MDM)",          "datos",     "NOT_COVERED"),
    ("5.1.2", 5, 1, "Golden Record / Single Source of Truth","datos",     "NOT_COVERED"),
    ("5.2.1", 5, 2, "Data Quality Management",               "datos",     "NOT_COVERED"),
    ("5.3.1", 5, 3, "Data Catalog",                          "datos",     "NOT_COVERED"),
    ("5.3.2", 5, 3, "Data Lineage",                          "datos",     "NOT_COVERED"),
    # L1-6: Riesgo y Finanzas / FX
    ("6.1.1", 6, 1, "FX Risk Management",                   "fx",        "COVERED"),
    ("6.1.2", 6, 1, "FX Pricing & Rates",                   "fx",        "COVERED"),
    ("6.2.1", 6, 2, "Treasury Management",                  "tesoreria", "COVERED"),
    ("6.2.2", 6, 2, "Position Management",                  "tesoreria", "COVERED"),
    ("6.2.3", 6, 2, "Límites y concentración de riesgo",    "tesoreria", "COVERED"),
    ("6.3.1", 6, 3, "Contraparte y KYC",                    "compliance","PARTIAL"),
    # L1-7: Tecnología e Infraestructura
    ("7.1.1", 7, 1, "API Gateway & Management",             "integracion","COVERED"),
    ("7.1.2", 7, 1, "Integration Platform (iPaaS)",         "integracion","COVERED"),
    ("7.2.1", 7, 2, "Developer Portal & API Catalog",       "integracion","PARTIAL"),
    ("7.3.1", 7, 3, "Cloud Infrastructure",                 "infraestructura","NOT_COVERED"),
    ("7.3.2", 7, 3, "Observabilidad y Monitoring",          "operacion", "PARTIAL"),
    ("7.4.1", 7, 4, "Security Operations (SecOps)",         "seguridad", "PARTIAL"),
    ("7.4.2", 7, 4, "Identity & Access Management (IAM)",   "seguridad", "PARTIAL"),
]


def build():
    print(f"Building {BRAIN_DB}...")
    if BRAIN_DB.exists():
        BRAIN_DB.unlink()

    conn = sqlite3.connect(BRAIN_DB)
    conn.row_factory = sqlite3.Row

    # Schema
    conn.executescript("""
        CREATE TABLE systems (
            system       TEXT PRIMARY KEY,
            display_name TEXT,
            category     TEXT,
            togaf_type   TEXT,
            togaf_state  TEXT,
            status       TEXT,
            description  TEXT,
            brain_path   TEXT,
            has_brain    INTEGER DEFAULT 0
        );

        CREATE TABLE components (
            id          TEXT,
            system      TEXT,
            name        TEXT,
            description TEXT,
            domain      TEXT,
            maturity    TEXT DEFAULT 'HOY',
            PRIMARY KEY (id, system)
        );

        CREATE TABLE digital_twins (
            slug        TEXT PRIMARY KEY,
            name        TEXT,
            question    TEXT,
            status      TEXT DEFAULT 'SCAFFOLD'
        );

        CREATE TABLE vocab (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            term        TEXT,
            domain      TEXT,
            scope       TEXT DEFAULT 'enterprise',
            en          TEXT,
            description TEXT,
            systems_json TEXT
        );

        CREATE TABLE owl_concepts (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            concept     TEXT,
            domain      TEXT,
            description TEXT,
            axiom       TEXT,
            systems_json TEXT
        );

        CREATE TABLE apolo_initiatives (
            slug        TEXT PRIMARY KEY,
            name        TEXT,
            status      TEXT,
            replaces    TEXT,
            description TEXT
        );

        CREATE TABLE etb_l3 (
            l3_id          TEXT PRIMARY KEY,
            l1             INTEGER,
            l2             INTEGER,
            l3_name        TEXT,
            domain         TEXT,
            monex_status   TEXT DEFAULT 'NOT_COVERED',
            etb_version    TEXT DEFAULT '5.0',
            notes          TEXT
        );

        CREATE TABLE itom_layer (
            system         TEXT,
            itom_domain    TEXT,
            coverage       TEXT DEFAULT 'DATO-REQUERIDO',
            notes          TEXT,
            PRIMARY KEY (system, itom_domain)
        );

        CREATE TABLE projects (
            slug           TEXT PRIMARY KEY,
            display_name   TEXT,
            project_type   TEXT,
            project_state  TEXT,
            apolo_initiative TEXT,
            brain_path     TEXT,
            has_brain      INTEGER DEFAULT 0
        );

        CREATE TABLE holdings (
            holding   TEXT PRIMARY KEY,
            name      TEXT,
            entities  TEXT,
            note      TEXT
        );

        CREATE TABLE company_facts (
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            metric TEXT,
            value  TEXT,
            year   TEXT,
            source TEXT
        );

        CREATE TABLE payment_rails (
            rail_id       TEXT PRIMARY KEY,
            name          TEXT,
            scope         TEXT,
            participation TEXT,
            note          TEXT,
            source        TEXT
        );

        CREATE TABLE product_families (
            family_id TEXT PRIMARY KEY,
            name      TEXT,
            block     TEXT
        );

        CREATE TABLE products (
            id          TEXT PRIMARY KEY,
            name_es     TEXT,
            name_en     TEXT,
            holding     TEXT,
            entity      TEXT,
            block       TEXT,
            family_id   TEXT,
            segment     TEXT,
            description TEXT,
            settlement  TEXT,
            evidence    TEXT
        );

        CREATE TABLE family_rail (
            family_id TEXT,
            rail_id   TEXT,
            PRIMARY KEY (family_id, rail_id)
        );

        CREATE TABLE asis_assessment (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            kind  TEXT,
            item  TEXT,
            detail TEXT
        );

        CREATE TABLE open_questions (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            topic TEXT,
            question TEXT
        );

        CREATE TABLE etb_payments_taxonomy (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            subdomain_id  TEXT,
            subdomain     TEXT,
            l3_id         TEXT,
            l3_capability TEXT,
            l4_process    TEXT,
            monex_map     TEXT
        );

        CREATE VIRTUAL TABLE products_fts USING fts5(id, name_es, name_en, description, settlement);
    """)

    # Insert systems
    for s in SYSTEMS:
        slug = s[0]
        brain_path = str(SYSTEMS_BASE / s[2] / slug / "digital-brain" / "brain.db")
        has_brain = 1 if Path(brain_path).exists() else 0
        conn.execute(
            "INSERT INTO systems VALUES (?,?,?,?,?,?,?,?,?)",
            (*s, brain_path, has_brain)
        )

    # Insert digital twins
    for dt in DIGITAL_TWINS:
        conn.execute("INSERT INTO digital_twins VALUES (?,?,?,'SCAFFOLD')", dt)

    # Insert Apolo initiatives
    initiatives = [
        ("motor-pagos",     "Motor de Pagos",         "DESIGN",       "payments-legacy", "Nuevo motor cloud-native ISO 20022 con conectividad CLS"),
        ("fx-next",         "FX Next",                "DESIGN",       None,              "Modernización plataforma FX — STP, pricing real-time, CLS"),
        ("golden-record",   "Golden Record / MDM",    "DESIGN",       None,              "Primer MDM canónico de MONEX — hoy no existe"),
        ("plataforma-apolo","Plataforma Apolo",        "DESIGN",       None,              "Plataforma destino + decommission legacy por capability"),
    ]
    for i in initiatives:
        conn.execute("INSERT INTO apolo_initiatives VALUES (?,?,?,?,?)", i)

    # Seed vocabulary
    vocab_seed = [
        ("Operación FX",    "fx",       "fx_transaction",   "Transacción de compraventa de divisas en cualquier modalidad (spot, forward, NDF, opción)"),
        ("Liquidación",     "pagos",    "settlement",       "Proceso de intercambio final de fondos entre contrapartes para cerrar una obligación"),
        ("Instrucción de pago", "pagos","payment_instruction","Mensaje formal que ordena la transferencia de fondos de una cuenta a otra"),
        ("Contraparte",     "fx",       "counterparty",     "Entidad con quien MONEX pacta una operación FX o de pago"),
        ("Tipo de Cambio",  "fx",       "exchange_rate",    "Precio de una divisa expresado en otra con timestamp y fuente"),
        ("DIOR",            "regulacion","dior",            "Disposiciones de Información sobre Operaciones Relevantes — reporte Banxico pagos internacionales > USD 10K"),
        ("Golden Record",   "datos",    "golden_record",    "Registro maestro canónico único por entidad — objetivo Apolo; hoy no existe"),
        ("API de Integración","integracion","integration_api","Interfaz programática expuesta o consumida por MuleSoft Anypoint"),
        ("ISO 20022",       "mensajeria","iso_20022",        "Estándar ISO de mensajería financiera — reemplaza SWIFT MT en pagos internacionales"),
        ("SPEI",            "pagos",    "spei",             "Sistema de Pagos Electrónicos Interbancarios — plataforma Banxico para pagos domésticos MXN"),
        ("CLS",             "liquidacion","cls",            "Continuous Linked Settlement — sistema global de liquidación PvP para FX"),
        ("Contraparte",     "fx",       "counterparty",     "Entidad con quien MONEX pacta una operación FX o de pago"),
    ]
    seen = set()
    for v in vocab_seed:
        if v[0] not in seen:
            conn.execute(
                "INSERT INTO vocab (term, domain, en, description) VALUES (?,?,?,?)",
                (v[0], v[1], v[2], v[3])
            )
            seen.add(v[0])

    # Seed OWL concepts
    owl_seed = [
        ("PaymentFlow",     "pagos",    "Flujo de pago end-to-end desde instrucción hasta liquidación",
         "PaymentFlow hasPart Instruction, Settlement, Confirmation"),
        ("FXTransaction",   "fx",       "Operación FX con todas sus dimensiones (precio, monto, plazo, contraparte)",
         "FXTransaction subClassOf FinancialTransaction; FXTransaction hasSettlement CLSSettlement"),
        ("IntegrationAPI",  "integracion","API expuesta o consumida por MuleSoft en el catálogo de MONEX",
         "IntegrationAPI hasGateway MuleSoftAnypoint; IntegrationAPI hasContract OpenAPISpec"),
        ("RegulatoryReport","regulacion","Reporte regulatorio con sus fuentes de datos y obligaciones",
         "RegulatoryReport requiredBy Regulator; RegulatoryReport hasSource System"),
        ("GoldenRecord",    "datos",    "Registro maestro canónico — primera instancia de verdad para una entidad",
         "GoldenRecord isSourceOf System; GoldenRecord hasMasterDataDomain Domain"),
    ]
    for o in owl_seed:
        conn.execute(
            "INSERT INTO owl_concepts (concept, domain, description, axiom) VALUES (?,?,?,?)",
            (o[0], o[1], o[2], o[3])
        )

    # Insert ETB L3 capabilities
    for etb in ETB_L3_MONEX:
        conn.execute(
            "INSERT INTO etb_l3 (l3_id, l1, l2, l3_name, domain, monex_status) VALUES (?,?,?,?,?,?)",
            etb
        )

    # Insert ITOM layer seed
    itom_domains = ["TechOps", "ITSM", "BPM", "SecOps", "DataOps", "PlatEng"]
    itom_critical = {
        "fx-engine":     {"TechOps": "CRITICAL", "BPM": "COVERED"},
        "treasury":      {"TechOps": "CRITICAL", "BPM": "COVERED"},
        "payments-legacy":{"TechOps": "CRITICAL","BPM": "COVERED"},
        "mulesoft":      {"TechOps": "HIGH",     "BPM": "COVERED", "PlatEng": "COVERED"},
        "swift":         {"TechOps": "HIGH",     "BPM": "COVERED"},
        "spei":          {"TechOps": "HIGH",     "BPM": "COVERED"},
        "golden-record-target": {d: "TARGET" for d in itom_domains},
    }
    for system, slug, *_ in SYSTEMS:
        overrides = itom_critical.get(system, {})
        for domain in itom_domains:
            coverage = overrides.get(domain, "DATO-REQUERIDO")
            conn.execute(
                "INSERT INTO itom_layer (system, itom_domain, coverage) VALUES (?,?,?)",
                (system, domain, coverage)
            )

    # Insert projects
    projects_brain = BASE.parent / "projects" / "payments-modernization" / "digital-brain" / "brain.db"
    conn.execute(
        "INSERT INTO projects VALUES (?,?,?,?,?,?,?)",
        ("payments-modernization", "Payments Modernization",
         "core-payments-modernization", "active", "motor-pagos",
         str(projects_brain), 1 if projects_brain.exists() else 0)
    )

    # --- Panorama AS-IS: holdings, facts, rieles, productos, correlacion ---
    for h in pdat.HOLDINGS:
        conn.execute("INSERT INTO holdings VALUES (?,?,?,?)", h)

    for f in pdat.COMPANY_FACTS:
        conn.execute("INSERT INTO company_facts (metric, value, year, source) VALUES (?,?,?,?)", f)

    for r in pdat.PAYMENT_RAILS:
        conn.execute("INSERT INTO payment_rails VALUES (?,?,?,?,?,?)", r)

    for fam in pdat.PRODUCT_FAMILIES:
        conn.execute("INSERT INTO product_families VALUES (?,?,?)", fam)

    for p in pdat.PRODUCTS:
        conn.execute("INSERT INTO products VALUES (?,?,?,?,?,?,?,?,?,?,?)", p)
        conn.execute("INSERT INTO products_fts VALUES (?,?,?,?,?)", (p[0], p[1], p[2], p[8], p[9]))

    for fam_id, rails in pdat.FAMILY_RAILS.items():
        for rail_id in rails:
            conn.execute("INSERT INTO family_rail VALUES (?,?)", (fam_id, rail_id))

    for s in pdat.ASIS_STRENGTHS:
        conn.execute("INSERT INTO asis_assessment (kind, item, detail) VALUES ('strength',?,?)", s)
    for g in pdat.ASIS_GAPS:
        conn.execute("INSERT INTO asis_assessment (kind, item, detail) VALUES ('gap',?,?)", g)

    for q in pdat.OPEN_QUESTIONS:
        conn.execute("INSERT INTO open_questions (topic, question) VALUES (?,?)", q)

    for t in pdat.ETB_PAYMENTS_TAXONOMY:
        conn.execute(
            "INSERT INTO etb_payments_taxonomy (subdomain_id, subdomain, l3_id, l3_capability, l4_process, monex_map) VALUES (?,?,?,?,?,?)",
            t
        )

    conn.commit()
    conn.close()

    # Summary
    print(f"  Holdings: {len(pdat.HOLDINGS)}")
    print(f"  Company facts: {len(pdat.COMPANY_FACTS)}")
    print(f"  Payment rails: {len(pdat.PAYMENT_RAILS)}")
    print(f"  Product families: {len(pdat.PRODUCT_FAMILIES)}")
    print(f"  Products: {len(pdat.PRODUCTS)}")
    print(f"  Correlation cells: {sum(len(v) for v in pdat.FAMILY_RAILS.values())}")
    print(f"  AS-IS strengths/gaps: {len(pdat.ASIS_STRENGTHS)}/{len(pdat.ASIS_GAPS)}")
    print(f"  ETB payments taxonomy (L4 rows): {len(pdat.ETB_PAYMENTS_TAXONOMY)}")
    print(f"  Systems registered: {len(SYSTEMS)}")
    print(f"  Digital Twins: {len(DIGITAL_TWINS)} (incl. dt-inteligencia-negocio)")
    print(f"  Apolo Initiatives: 4")
    print(f"  ETB L3 capabilities: {len(ETB_L3_MONEX)}")
    print(f"  ITOM entries: {len(SYSTEMS) * len(itom_domains)}")
    print(f"  Vocabulary seed: {len(seen)} terms")
    print(f"  OWL concepts seed: {len(owl_seed)} concepts")
    print(f"  Projects: 1 (payments-modernization)")
    print("Done. Run: python monex-brain.py systems")


if __name__ == "__main__":
    build()

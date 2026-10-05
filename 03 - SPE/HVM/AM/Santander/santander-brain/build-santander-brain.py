"""
build-santander-brain.py
Pipeline principal del Digital Brain Santander México.

Crea santander-brain.db con todas las tablas base, registra los sistemas
y adjunta (ATTACH) los system brains individuales cuando existen.

Uso:
    python build-santander-brain.py           # construye / reconstruye el brain
    python build-santander-brain.py --status  # muestra estado sin reconstruir
"""

import sqlite3
import os
import sys
import json
from datetime import datetime

BASE_DIR     = os.path.dirname(os.path.abspath(__file__))
DB_PATH      = os.path.join(BASE_DIR, "santander-brain.db")
SYSTEMS_ROOT = os.path.join(os.path.dirname(BASE_DIR), "systems")

VERSION  = "1.0.0"
BUILT_AT = datetime.now().strftime("%Y-%m-%d %H:%M")

# ──────────────────────────────────────────────────────────────────
# Registro canónico de sistemas
# Fuente: CLAUDE.md Santander v1.0 (2026-09-17) + fuentes públicas
# slug, display_name, real_name, category, togaf_type, segment, status, note
# ──────────────────────────────────────────────────────────────────
SYSTEMS = [
    # ── CORE ──────────────────────────────────────────────────────
    ("core-banking",        "Core Banking",           "Por confirmar",          "core",        "core",        "Enterprise",     "scaffold",           "Core bancario — cuentas, productos, clientes, saldos, transacciones. Sistema propietario no divulgado públicamente."),
    ("card-platform",       "Card Platform",          "Por confirmar",          "core",        "core",        "Retail + Pyme",  "scaffold",           "Plataforma de tarjetas débito y crédito — emisión, parametrización, ciclo de vida, bloqueos."),
    ("loans",               "Loans",                  "Por confirmar",          "core",        "core",        "Retail + Pyme",  "scaffold",           "Sistema de créditos — hipotecario, nómina, automotriz, personal, PyME."),
    ("treasury",            "Treasury",               "Por confirmar",          "core",        "core",        "Corporativo",    "scaffold",           "Tesorería y mercados — FX, derivados, renta fija, fondos de inversión."),

    # ── PROCESSORS ────────────────────────────────────────────────
    ("card-authorizer",     "Card Authorizer",        "Por confirmar",          "processors",  "processors",  "Enterprise",     "scaffold",           "Autorizador de tarjetas 24x7 — aprobación en tiempo real · VISA/MC · PROSA."),
    ("payments-engine",     "Payments Engine",        "Por confirmar",          "processors",  "processors",  "Enterprise",     "scaffold",           "Motor de pagos — SPEI, DiMo, CoDi, TEF, domiciliación CECOBAN, SWIFT."),
    ("pld-engine",          "PLD / AML Engine",       "Por confirmar",          "processors",  "processors",  "Compliance",     "scaffold",           "Motor PLD/AML — scoring de riesgo, monitoreo operaciones inusuales, reportes UIF."),
    ("fraud-detection",     "Fraud Detection",        "Por confirmar",          "processors",  "processors",  "Enterprise",     "scaffold",           "Detección de fraude ML — tarjetas y canales digitales. Posiblemente NICE Actimize o FICO."),

    # ── CHANNELS ──────────────────────────────────────────────────
    ("supermovil",          "SuperMóvil",             "SuperMóvil",             "channels",    "channels",    "Retail",         "confirmed-name",     "App móvil principal iOS + Android — consulta, pagos, transferencias, DiMo, depósitos de cheque."),
    ("santander-online",    "Santander Online",       "Santander Online",       "channels",    "channels",    "Retail + Pyme",  "confirmed-name",     "Banca en línea web — retail y pyme. Portal supernet.com.mx."),
    ("santander-empresas",  "Santander Empresas",     "Santander Cash",         "channels",    "channels",    "Corporativo",    "confirmed-name",     "Portal banca empresarial y tesorería corporativa — Santander Cash."),
    ("atm-network",         "Red ATM",                "Red cajeros ATM",        "channels",    "channels",    "Retail",         "confirmed-name",     "Red propia ~7K cajeros ATM + interoperabilidad PROSA/ATMRed nacional."),
    ("call-center",         "Call Center / IVR",      "Por confirmar",          "channels",    "channels",    "Retail",         "scaffold",           "Canal call center — IVR + agentes. Posiblemente Genesys o Avaya."),
    ("pos-acquiring",       "POS Adquirente",         "Terminal Santander",     "channels",    "channels",    "Pyme",           "scaffold",           "Terminal punto de venta — acquiring propio VISA/MC. Marca Terminal Santander."),

    # ── INTEGRATION ───────────────────────────────────────────────
    ("api-gateway",         "API Gateway",            "Por confirmar",          "integration", "integration", "Enterprise",     "scaffold",           "API Gateway — Azure APIM (probable por partnership Azure) · Open Banking APIs CNBV."),
    ("esb",                 "ESB / iPaaS",            "Por confirmar",          "integration", "integration", "Enterprise",     "scaffold",           "ESB o iPaaS — bus de integración entre sistemas legacy y digitales. MuleSoft probable."),
    ("swift-gateway",       "SWIFT Gateway",          "SWIFT Alliance",         "integration", "integration", "Corporativo",    "scaffold",           "Conectividad SWIFT — mensajería ISO 20022 / MT para pagos internacionales."),
    ("prosa-link",          "PROSA",                  "PROSA",                  "integration", "integration", "Retail",         "scaffold",           "Enlace con PROSA — cámara de compensación de tarjetas MX."),
    ("banxico-spei",        "Banxico SPEI/DiMo",      "Banxico (regulado)",     "integration", "integration", "Enterprise",     "confirmed-name",     "Conectividad Banxico — SPEI (liquidación bruta tiempo real) · DiMo · CoDi."),

    # ── DATA ──────────────────────────────────────────────────────
    ("datawarehouse",       "Datawarehouse",          "Por confirmar",          "data",        "data",        "Enterprise",     "scaffold",           "Datawarehouse corporativo — golden record clientes, transacciones históricas, OLAP."),
    ("analytics",           "Analytics / BI",         "Por confirmar",          "data",        "data",        "Enterprise",     "scaffold",           "Analytics y BI — Power BI o Qlik probable. Reportes gerenciales y siniestralidad."),
    ("data-platform",       "Data Platform",          "Azure Data Lake (prob)", "data",        "data",        "Enterprise",     "scaffold",           "Data platform moderna — Azure Data Lake + Databricks probable por partnership Azure."),

    # ── COMPLIANCE ────────────────────────────────────────────────
    ("cnbv-reporting",      "CNBV Reporting",         "Por confirmar",          "compliance",  "compliance",  "Regulatorio",    "scaffold",           "Reportería CNBV — catálogos R01-R29, ICAP, CCL, SIPRES."),
    ("iam",                 "IAM",                    "Azure AD / Entra ID",    "compliance",  "compliance",  "Enterprise",     "scaffold",           "IAM corporativo — Azure AD / Entra ID (global Santander) + MFA."),
    ("finance-erp",         "Finance ERP",            "SAP (probable)",         "compliance",  "compliance",  "Enterprise",     "scaffold",           "ERP finanzas y RRHH — SAP ECC o S/4HANA para consolidación al Grupo Santander España."),
    ("itsm",                "ITSM",                   "ServiceNow (probable)",  "compliance",  "compliance",  "Enterprise",     "scaffold",           "ITSM corporativo — incidentes, cambios, problemas. ServiceNow común en grupos bancarios globales."),
    ("crm",                 "CRM",                    "Salesforce (probable)",  "compliance",  "compliance",  "Enterprise",     "scaffold",           "CRM — gestión de clientes, oportunidades, campañas. Santander grupo usa Salesforce globalmente."),
    ("azure-backbone",      "Azure Backbone",         "Microsoft Azure",        "compliance",  "compliance",  "Enterprise",     "confirmed-name",     "Azure backbone — AD/Entra ID · APIM · Service Bus · Key Vault · Monitor · Sentinel · AI Foundry (OpenAI)."),
]

# ──────────────────────────────────────────────────────────────────
# DDL — tablas base del brain federado
# ──────────────────────────────────────────────────────────────────
DDL = """
CREATE TABLE IF NOT EXISTS brain_meta (
    key     TEXT PRIMARY KEY,
    value   TEXT
);

CREATE TABLE IF NOT EXISTS systems (
    slug            TEXT PRIMARY KEY,
    display_name    TEXT,
    real_name       TEXT,
    category        TEXT,
    togaf_type      TEXT,
    segment         TEXT,
    status          TEXT,
    note            TEXT,
    brain_path      TEXT,
    brain_attached  INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS components (
    id              TEXT PRIMARY KEY,
    system          TEXT,
    name            TEXT,
    type            TEXT,
    status          TEXT,
    etb_domain_l1   TEXT,
    etb_domain_label TEXT,
    maturity        TEXT DEFAULT 'HOY',
    FOREIGN KEY (system) REFERENCES systems(slug)
);

CREATE TABLE IF NOT EXISTS etb_capabilities (
    id              TEXT PRIMARY KEY,
    domain_l1       TEXT,
    domain_l1_name  TEXT,
    domain_l2       TEXT,
    domain_l2_name  TEXT,
    capability_l3   TEXT,
    system          TEXT,
    priority        TEXT,
    note            TEXT
);

CREATE TABLE IF NOT EXISTS vocab (
    term            TEXT PRIMARY KEY,
    domain          TEXT,
    scope           TEXT,
    en              TEXT,
    etb_cap         TEXT,
    cnbv_term       TEXT,
    systems_json    TEXT
);

CREATE TABLE IF NOT EXISTS market_intel (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    category    TEXT,
    date        TEXT,
    title       TEXT,
    body        TEXT,
    source      TEXT,
    maturity    TEXT DEFAULT 'HOY'
);

CREATE TABLE IF NOT EXISTS process_steps (
    id              TEXT PRIMARY KEY,
    id_padre        TEXT,
    rama            TEXT,
    nombre          TEXT,
    descripcion     TEXT,
    system_slug     TEXT,
    regulacion      TEXT,
    maturity        TEXT DEFAULT 'HOY'
);

CREATE TABLE IF NOT EXISTS pain_points (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    system      TEXT,
    category    TEXT,
    severity    TEXT,
    title       TEXT,
    description TEXT,
    source      TEXT,
    maturity    TEXT DEFAULT 'HOY',
    FOREIGN KEY (system) REFERENCES systems(slug)
);

CREATE TABLE IF NOT EXISTS system_dependencies (
    id                  TEXT PRIMARY KEY,
    source_system       TEXT,
    target_system       TEXT,
    dependency_type     TEXT,
    direction           TEXT,
    description         TEXT,
    evidence            TEXT,
    criticality         TEXT,
    notes               TEXT,
    FOREIGN KEY (source_system) REFERENCES systems(slug)
);

CREATE TABLE IF NOT EXISTS releases (
    id              TEXT PRIMARY KEY,
    name            TEXT,
    target_date     TEXT,
    status          TEXT,
    scope           TEXT,
    milestones      TEXT,
    notes           TEXT
);

CREATE TABLE IF NOT EXISTS opportunities (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    area            TEXT,
    title           TEXT,
    description     TEXT,
    accenture_angle TEXT,
    priority        TEXT,
    effort          TEXT,
    maturity        TEXT DEFAULT 'MAÑANA'
);

CREATE INDEX IF NOT EXISTS idx_comp_system ON components(system);
CREATE INDEX IF NOT EXISTS idx_comp_etb    ON components(etb_domain_l1);
CREATE INDEX IF NOT EXISTS idx_dep_source  ON system_dependencies(source_system);
CREATE INDEX IF NOT EXISTS idx_dep_target  ON system_dependencies(target_system);
CREATE INDEX IF NOT EXISTS idx_vocab_dom   ON vocab(domain);
CREATE INDEX IF NOT EXISTS idx_mi_cat      ON market_intel(category);
CREATE INDEX IF NOT EXISTS idx_pain_sys    ON pain_points(system);
"""

# ──────────────────────────────────────────────────────────────────
# Vocabulario inicial (Rosetta Stone semilla)
# ──────────────────────────────────────────────────────────────────
VOCAB_SEED = [
    # term, domain, scope, en, etb_cap, cnbv_term, systems_json
    ("Cuenta de depósito",      "productos",   "enterprise", "deposit_account",     "Deposit Management",        "Cuenta de depósito a la vista", "{}"),
    ("Tarjeta de débito",       "pagos",       "enterprise", "debit_card",          "Card Management",           "Tarjeta de débito",             "{}"),
    ("Tarjeta de crédito",      "productos",   "enterprise", "credit_card",         "Credit Card Management",    "Tarjeta de crédito",            "{}"),
    ("Crédito hipotecario",     "crédito",     "enterprise", "mortgage_loan",       "Mortgage Management",       "Crédito hipotecario",           "{}"),
    ("Crédito de nómina",       "crédito",     "enterprise", "payroll_loan",        "Consumer Credit",           "Crédito de nómina",             "{}"),
    ("Transferencia SPEI",      "pagos",       "enterprise", "spei_transfer",       "Payment Processing",        "Transferencia electrónica",     "{}"),
    ("Domiciliación",           "pagos",       "enterprise", "direct_debit",        "Direct Debit",              "Domiciliación",                 "{}"),
    ("Operación inusual",       "compliance",  "enterprise", "unusual_transaction",  "AML Monitoring",            "Operación inusual",             "{}"),
    ("Índice de Capitalización","riesgo",      "enterprise", "capital_adequacy_ratio","Capital Management",       "ICAP",                          "{}"),
    ("Cartera vencida",         "crédito",     "enterprise", "non_performing_loans", "Credit Risk",               "Cartera vencida",               "{}"),
    ("Cliente",                 "clientes",    "enterprise", "customer",            "Customer Management",       "Cliente",                       "{}"),
    ("Contrato",                "productos",   "enterprise", "account_contract",    "Product Management",        "Contrato de adhesión",          "{}"),
    ("Sucursal",                "canales",     "enterprise", "branch",              "Branch Operations",         "Sucursal",                      "{}"),
    ("Cajero automático",       "canales",     "enterprise", "atm",                 "ATM Management",            "Cajero automático",             "{}"),
    ("Crédito disponible",      "crédito",     "enterprise", "available_credit",    "Credit Management",         "Saldo disponible",              "{}"),
    ("Tasa de interés",         "productos",   "enterprise", "interest_rate",       "Rate Management",           "Tasa de interés",               "{}"),
    ("Saldo",                   "productos",   "enterprise", "balance",             "Account Management",        "Saldo",                         "{}"),
    ("Número de cuenta",        "clientes",    "enterprise", "account_number",      "Account Management",        "Número de cuenta",              "{}"),
    ("CLABE",                   "pagos",       "enterprise", "clabe",               "Payment Routing",           "CLABE interbancaria",           "{}"),
    ("DiMo",                    "pagos",       "enterprise", "dimo",                "Digital Payments",          "Dinero Móvil",                  "{}"),
]

# ──────────────────────────────────────────────────────────────────
# Inteligencia de mercado inicial
# ──────────────────────────────────────────────────────────────────
MARKET_INTEL_SEED = [
    ("competitive",  "2026-01", "BBVA México lidera experiencia digital",
     "BBVA México obtuvo el primer lugar en satisfacción de banca digital (J.D. Power 2024). Su app Bancomer/BBVA supera en NPS a todos los bancos tradicionales. Nayón (plataforma cloud-native) aceleró el time-to-market.",
     "J.D. Power 2024 · Reportes anuales BBVA", "HOY"),
    ("competitive",  "2026-01", "Nu México crece aceleradamente",
     "Nu México supera 8M de clientes con modelo app-only. Sin sucursales, costos 80% menores que banca tradicional. Amenaza en crédito personal y tarjeta de crédito para segmento joven.",
     "Comunicados Nu México · CNBV datos", "HOY"),
    ("competitive",  "2026-01", "Banorte — fortaleza en banca nacional",
     "Banorte mantiene liderazgo en banca de nómina gobierno y pyme. Alianza con Rappi (RappCard) captura segmento digital. Primer banco 100% mexicano en el Top 5.",
     "Reportes anuales Banorte", "HOY"),
    ("regulatory",   "2026-06", "Open Banking CNBV — APIs obligatorias",
     "CNBV exige APIs abiertas para información de cuentas y pagos. Deadline escalonado 2025-2026. Santander debe exponer APIs bajo estándar CNBV con autenticación OAuth 2.0.",
     "DOF · Circulares CNBV Open Finance", "HOY"),
    ("regulatory",   "2026-01", "DORA — resiliencia operativa digital (grupo)",
     "El grupo Santander ES debe cumplir DORA (Digital Operational Resilience Act UE) desde enero 2025. Aplica a todas las subsidiarias globales incluyendo México en la capa de gestión de riesgos TIC y proveedores críticos.",
     "Reglamento UE 2022/2554 · Comunicados grupo", "HOY"),
    ("technology",   "2026-03", "Microsoft + Santander — Azure AI Foundry",
     "Banco Santander S.A. anuncia acuerdo estratégico con Microsoft para usar Azure OpenAI Service y AI Foundry en toda la organización global. Aplica a Santander México. Caso de uso: asistentes de clientes, detección de fraude, análisis crediticio.",
     "Comunicado oficial Microsoft + Santander 2024", "HOY"),
    ("technology",   "2026-01", "Openbank México — neobanco del grupo",
     "Santander lanzó Openbank en México (2023) como oferta digital first. Compite directamente con Nu y otras fintechs. Desvinculado de la marca Santander tradicional.",
     "Sitio openbank.mx · Comunicados grupo", "HOY"),
]

# ──────────────────────────────────────────────────────────────────
# Oportunidades Accenture (hipótesis iniciales)
# ──────────────────────────────────────────────────────────────────
OPPORTUNITIES_SEED = [
    ("Digital Banking",      "Modernización Core Banking",
     "El core bancario legacy es el principal bloqueador de time-to-market para nuevos productos. Evaluación 7Rs y roadmap de modernización incremental (Strangler-Fig).",
     "High Velocity Modernization — Application Modernization · Accenture tiene referencia BanCoppel (Informix), Banamex (Unisys), BBVA (Altamira).",
     "ALTA", "ALTA"),
    ("Digital Banking",      "Open Banking APIs CNBV",
     "CNBV exige APIs abiertas. Oportunidad de construir una capa API moderna sobre sistemas legacy con Azure APIM + MuleSoft.",
     "Software & Platform Engineering — API-First + Azure APIM + OpenAPI 3.1.",
     "ALTA", "MEDIA"),
    ("AI & Analytics",       "AI Foundry — Casos de uso bancarios",
     "Partnership Azure + Santander global habilita Azure AI Foundry. Oportunidad de implementar: asistente conversacional (SuperMóvil), scoring crediticio ML, detección de fraude en tiempo real.",
     "AI Enabled Enterprise — GenAI + MLOps. Accenture tiene marco AI RAG Banking.",
     "ALTA", "MEDIA"),
    ("Compliance",           "PLD/AML modernización",
     "Motores PLD legacy no escalan para volumen transaccional creciente y nuevos canales digitales (DiMo, Open Banking). Modernización con graph analytics y ML en tiempo real.",
     "Intelligent Infrastructure + AI Enabled Enterprise — AML modernization.",
     "MEDIA", "ALTA"),
    ("Data Platform",        "Unificación de datos de cliente",
     "MDM centralizado para golden record de cliente: hoy probablemente fragmentado en core banking, CRM, tarjetas. Habilita hiperpersonalización y CNBV reporting limpio.",
     "Modern Data Platform — MDM + Azure Data Lake + Databricks.",
     "MEDIA", "ALTA"),
    ("DevOps",               "Developer Platform (IDP)",
     "Banco de escala global requiere Developer Platform para acelerar delivery. Backstage + GitHub Actions + GitOps sobre Azure AKS.",
     "Software & Platform Engineering — Frictionless SDLC.",
     "BAJA", "MEDIA"),
]


def build_brain():
    print(f"[santander-brain] v{VERSION} — {BUILT_AT}")
    print(f"[santander-brain] DB: {DB_PATH}")

    # Borrar y recrear
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
        print("[santander-brain] DB anterior eliminada")

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(DDL)

    # Meta
    meta = {
        "version":          VERSION,
        "built_at":         BUILT_AT,
        "client":           "Banco Santander México",
        "etb_reference":    "Banking — Retail + Commercial + Digital",
        "regulators":       "CNBV · Banxico · UIF · CONDUSEF · PCI-DSS",
        "systems_count":    str(len(SYSTEMS)),
        "brain_type":       "federated",
    }
    conn.executemany("INSERT OR REPLACE INTO brain_meta VALUES (?,?)", meta.items())

    # Sistemas
    for s in SYSTEMS:
        slug, display, real, cat, togaf, segment, status, note = s
        brain_path = os.path.join(
            SYSTEMS_ROOT, togaf, slug, "digital-brain", "brain.db"
        )
        attached = 1 if os.path.exists(brain_path) else 0
        conn.execute(
            """INSERT OR REPLACE INTO systems
               (slug, display_name, real_name, category, togaf_type, segment, status, note, brain_path, brain_attached)
               VALUES (?,?,?,?,?,?,?,?,?,?)""",
            (slug, display, real, cat, togaf, segment, status, note, brain_path, attached),
        )

    # Vocabulario semilla
    for v in VOCAB_SEED:
        conn.execute(
            """INSERT OR IGNORE INTO vocab
               (term, domain, scope, en, etb_cap, cnbv_term, systems_json)
               VALUES (?,?,?,?,?,?,?)""", v
        )

    # Inteligencia de mercado semilla
    for m in MARKET_INTEL_SEED:
        conn.execute(
            """INSERT INTO market_intel (category, date, title, body, source, maturity)
               VALUES (?,?,?,?,?,?)""", m
        )

    # Oportunidades semilla
    for o in OPPORTUNITIES_SEED:
        conn.execute(
            """INSERT INTO opportunities (area, title, description, accenture_angle, priority, effort, maturity)
               VALUES (?,?,?,?,?,?,'MAÑANA')""", o
        )

    conn.commit()

    # Adjuntar system brains existentes
    attached_count = 0
    for row in conn.execute("SELECT slug, brain_path FROM systems WHERE brain_attached=1"):
        slug, path = row
        try:
            conn.execute(f"ATTACH DATABASE '{path}' AS [{slug}]")
            print(f"  [ATTACHED] {slug}")
            attached_count += 1
        except Exception as e:
            print(f"  [WARN] No se pudo adjuntar {slug}: {e}")

    conn.close()

    # Resumen
    print(f"\n[santander-brain] Build completado")
    print(f"  Sistemas registrados : {len(SYSTEMS)}")
    print(f"  Sistemas con brain   : {attached_count}")
    print(f"  Vocab semilla        : {len(VOCAB_SEED)} términos")
    print(f"  Market intel         : {len(MARKET_INTEL_SEED)} registros")
    print(f"  Oportunidades        : {len(OPPORTUNITIES_SEED)} items")


def show_status():
    if not os.path.exists(DB_PATH):
        print("[santander-brain] DB no existe — ejecuta: python build-santander-brain.py")
        return
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    print("\n=== santander-brain — Estado ===")
    for row in conn.execute("SELECT key, value FROM brain_meta ORDER BY key"):
        print(f"  {row['key']:25s}: {row['value']}")
    print("\nSistemas:")
    for row in conn.execute(
        "SELECT slug, category, status, brain_attached FROM systems ORDER BY category, slug"
    ):
        brain_icon = "✓" if row["brain_attached"] else "○"
        print(f"  [{brain_icon}] {row['slug']:30s} [{row['category']:12s}] {row['status']}")
    conn.close()


if __name__ == "__main__":
    if "--status" in sys.argv:
        show_status()
    else:
        build_brain()
        show_status()

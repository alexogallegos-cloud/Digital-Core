"""
build-brain.py — Construye brain.db para Payments Modernization
MONEX Grupo Financiero — RFP-PAG v2.6

Usage:
    python build-brain.py
"""
import sqlite3
from pathlib import Path
from datetime import date

BRAIN_DB = Path(__file__).parent / "brain.db"
SOURCE_RFP = Path(__file__).parent.parent / "source" / "rfp"


def build():
    print(f"Building {BRAIN_DB}...")
    if BRAIN_DB.exists():
        BRAIN_DB.unlink()

    conn = sqlite3.connect(BRAIN_DB)
    conn.executescript("""
        CREATE TABLE project_info (
            slug TEXT PRIMARY KEY,
            display_name TEXT,
            project_type TEXT,
            project_state TEXT,
            replaces TEXT,
            rfp_code TEXT,
            rfp_version TEXT,
            rfp_date TEXT,
            sponsor TEXT,
            seeded_at TEXT
        );

        CREATE TABLE capabilities (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            domain TEXT,
            source TEXT,
            migration_target TEXT,
            migration_priority TEXT,
            status TEXT DEFAULT 'SCAFFOLD'
        );

        CREATE TABLE pag_macrocapabilities (
            code TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            status TEXT DEFAULT 'SCOPE'
        );

        CREATE TABLE requirements (
            req_id TEXT PRIMARY KEY,
            type TEXT,
            category TEXT,
            description TEXT,
            source TEXT,
            priority TEXT,
            capability_id TEXT,
            evidence_required TEXT,
            status TEXT DEFAULT 'OPEN'
        );

        CREATE TABLE arch_principles (
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT
        );

        CREATE TABLE candidates (
            slug TEXT PRIMARY KEY,
            name TEXT,
            vendor TEXT,
            iso20022_native INTEGER DEFAULT 0,
            cls_support INTEGER DEFAULT 0,
            spei_support INTEGER DEFAULT 0,
            cloud_native INTEGER DEFAULT 0,
            evaluation_status TEXT DEFAULT 'PENDING'
        );

        CREATE TABLE vendor_rail_fit (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            rail     TEXT,
            vendor   TEXT,
            coverage TEXT,
            note     TEXT
        );

        CREATE TABLE geographies (
            code TEXT PRIMARY KEY,
            name TEXT,
            rails TEXT,
            regulators TEXT,
            priority INTEGER DEFAULT 1
        );

        CREATE TABLE timeline (
            milestone TEXT PRIMARY KEY,
            date TEXT,
            status TEXT DEFAULT 'PENDING'
        );

        CREATE TABLE integrations (
            system TEXT PRIMARY KEY,
            primary_interactions TEXT,
            priority TEXT DEFAULT 'HIGH'
        );

        CREATE TABLE ai_requirements (
            id TEXT PRIMARY KEY,
            capability TEXT,
            description TEXT,
            status TEXT DEFAULT 'OPEN'
        );

        CREATE VIRTUAL TABLE capabilities_fts USING fts5(id, name, description, domain);
        CREATE VIRTUAL TABLE requirements_fts USING fts5(req_id, category, description, type);
    """)

    # Project info
    conn.execute(
        "INSERT INTO project_info VALUES (?,?,?,?,?,?,?,?,?,?)",
        ("payments-modernization", "Payments Modernization",
         "core-payments-modernization", "active", "payments-legacy",
         "RFP-PAG", "2.6", "2026-08-27", "Rafael Pereda", str(date.today()))
    )

    # PAG macro-capabilities (from RFP Section 6)
    pag_caps = [
        ("PAG-1",  "Products and Schemes",         "Catalogs, payment rails, participants, calendars, fees, parameters and reference data."),
        ("PAG-2",  "Initiation and Capture",        "Multi-channel initiation, common model, single/bulk payments, scheduling, authorizations and beneficiaries."),
        ("PAG-3",  "Validation and Enrichment",     "Structure, customer/account, beneficiary/bank, funds, value date, ISO 20022 and reason codes."),
        ("PAG-4",  "Pre-processing Controls",       "Sanctions, AML/CFT, fraud, limits, SoD, duplicates, local rules and evidence."),
        ("PAG-5",  "Orchestration and Routing",     "Workflow, priorities, queues, routing, fallback, cut-offs, parallelism and external services."),
        ("PAG-6",  "Clearing and Settlement",       "Messages, transmission, ACK/NACK, statuses, settlement, liquidity, intraday processing and close."),
        ("PAG-7",  "Cross-border and FX",           "Correspondent banking, SWIFT/UETR, parties, charges, FX, tracking and repair."),
        ("PAG-8",  "Exceptions and Investigations", "Queues, repair, returns, recalls, unknown status, cases and communications."),
        ("PAG-9",  "Reconciliation and Accounting", "Reconciliation, nostro/vostro, accounting events, GL, breaks, adjustments and close."),
        ("PAG-10", "Monitoring and Analytics",      "End-to-end view, dashboards, payment rails, alerts, reporting, audit, data and costs."),
    ]
    for p in pag_caps:
        conn.execute("INSERT INTO pag_macrocapabilities VALUES (?,?,?,'SCOPE')", p)

    # Architecture principles (from RFP Section 5)
    principles = [
        ("P-01", "Fit-to-Standard First",        "Adopt standard functionality before extending or customizing."),
        ("P-02", "Global with Governed Variants", "Common core with justified, isolated and reviewable local differences."),
        ("P-03", "API-first and Contract-first",  "Capabilities exposed through governed and versioned contracts."),
        ("P-04", "Event-driven",                  "Relevant states published as reliable and reconcilable events."),
        ("P-05", "Canonical Model",               "Corporate semantics aligned with ISO 20022 without coupling consumers to internal model."),
        ("P-06", "Cloud-first, Not Cloud-only",   "Use cloud where viable, taking account of regulation, data residency, criticality and operations."),
        ("P-07", "Zero Trust",                    "Identity, least privilege, mTLS, segregation, secrets protection and evidence."),
        ("P-08", "Resilience by Design",          "Idempotency, replay, recovery, graceful degradation, DR and reconciliation."),
        ("P-09", "End-to-End Observability",      "Business and technology metrics, traces, logs, SLOs, alerts and runbooks."),
        ("P-10", "AI-ready and Responsible AI",   "AI integrated under governance, explainability, security, human oversight and traceability."),
        ("P-11", "Portability",                   "Exportable data, contracts and operations; explicit lock-in and exit strategy."),
        ("P-12", "Secure Automation",             "CI/CD, IaC, automated testing, controls and rollback."),
        ("P-13", "Component-based Architecture",  "No monolithic, siloed or fragmented architecture."),
    ]
    for p in principles:
        conn.execute("INSERT INTO arch_principles VALUES (?,?,?)", p)

    # Critical functional requirements (from RFP Section 7.1)
    func_reqs = [
        ("R-F01", "functional",    "Configuration",          "Administer products, currencies, entities, rails, calendars, cut-offs, charges and rules through version-controlled configuration without duplicating the core.", "RFP-PAG §7.1", "CRÍTICO", None, "Demo + global/local configuration"),
        ("R-F02", "functional",    "Multi-channel Initiation","Receive instructions through APIs, H2H, files, channels, assisted operations, Treasury and FX, normalizing to a common model.", "RFP-PAG §7.1", "CRÍTICO", "PAG-2", "Demo end-to-end"),
        ("R-F03", "functional",    "Bulk and Real-Time",      "Process individual payments, batches and immediate payments with volume control, priority and idempotency.", "RFP-PAG §7.1", "CRÍTICO", "PAG-2", "Demo + load test"),
        ("R-F04", "functional",    "Authorizations",          "Multi-level maker-checker controls, authorities, signatures, limits and SoD by entity, amount, product, channel and risk.", "RFP-PAG §7.1", "CRÍTICO", "PAG-4", "Demo + positive/negative test scenarios"),
        ("R-F05", "functional",    "Validation and Enrichment","Validate syntax, semantics, customer, account, beneficiary, bank, funds, value date, ISO 20022 and regulatory data.", "RFP-PAG §7.1", "CRÍTICO", "PAG-3", "Demo + Rules Catalog"),
        ("R-F06", "functional",    "External Controls",       "Orchestrate sanctions, PLD/FT, fraud and limits withhold/release/reject, reason code and evidence.", "RFP-PAG §7.1", "CRÍTICO", "PAG-4", "Demo"),
        ("R-F07", "functional",    "Routing",                 "Select payment rail and correspondent based on cost, urgency, risk, liquidity, availability and SLA, preserving rationale.", "RFP-PAG §7.1", "CRÍTICO", "PAG-5", "Demo + Policy"),
        ("R-F08", "functional",    "Safe fallback",           "Change route only when previous outcome is controlled, maintaining idempotency, non-duplication and evidence.", "RFP-PAG §7.1", "CRÍTICO", "PAG-5", "Failure scenario"),
        ("R-F09", "functional",    "Clearing and Settlement", "Generate native messages, validate and transmit, capture ACK/NACK, statuses and identifiers, maintain linkage to settlement accounts.", "RFP-PAG §7.1", "CRÍTICO", "PAG-6", "Demo using simulator or live rail"),
        ("R-F10", "functional",    "Cross-border",            "Support SWIFT/CBPR+, UETR, correspondent banking networks, parties, charges OUR/SHA/BEN and tracking.", "RFP-PAG §7.1", "CRÍTICO", "PAG-7", "International Demo"),
        ("R-F11", "functional",    "FX Integration",          "Receive trade ID, currencies, amounts and value dates without recalculating economics; request conversion/delivery.", "RFP-PAG §7.1", "CRÍTICO", "PAG-7", "Demo FX-to-payment"),
    ]
    for r in func_reqs:
        conn.execute("INSERT INTO requirements VALUES (?,?,?,?,?,?,?,?,'OPEN')", r)
        conn.execute("INSERT INTO requirements_fts VALUES (?,?,?,?)", (r[0], r[2], r[3], "functional"))

    # Critical non-functional requirements (from RFP Section 7.2)
    nfr_reqs = [
        ("R-N01", "non-functional", "Capability",      "Demonstrate sustained throughput, peaks and batch processing with controls and traceability enabled.", "RFP-PAG §7.2", "CRÍTICO", None, "Load test"),
        ("R-N02", "non-functional", "Latency",         "Measure p95/p99 for receipt, validation and routing under reproducible conditions.", "RFP-PAG §7.2", "CRÍTICO", None, "Performance test"),
        ("R-N03", "non-functional", "Availability",    "Classes of service and architecture for reaching agreed availability by relevance.", "RFP-PAG §7.2", "CRÍTICO", None, "Architecture + evidence"),
        ("R-N04", "non-functional", "RTO/RPO",         "Meet and test RTO<2h and RPO<5min by service without loss of integrity or duplication.", "RFP-PAG §7.2", "CRÍTICO", None, "DR test evidence"),
        ("R-N05", "non-functional", "Fault tolerance", "Continue or degrade in a controlled manner in event of failure of component, zone, dependency or payment rail.", "RFP-PAG §7.2", "CRÍTICO", None, "Failover demo"),
        ("R-N06", "non-functional", "Security",        "Integrate IAM/MFA, RBAC/ABAC, mTLS, encryption, vault, hardening and privileged sessions.", "RFP-PAG §7.2", "CRÍTICO", None, "Security evidence"),
        ("R-N07", "non-functional", "Privacy",         "Classify, minimize, mask, retain and delete data by purpose and jurisdiction.", "RFP-PAG §7.2", "CRÍTICO", None, "Data flows"),
        ("R-N08", "non-functional", "APIs/events",     "Support OpenAPI/AsyncAPI, versioned, compatibility, idempotency, replay and schema governance.", "RFP-PAG §7.2", "CRÍTICO", None, "API catalog"),
        ("R-N09", "non-functional", "Observability",   "Provide structured logs, metrics, traces, correlation IDs, health checks, alerts and runbooks.", "RFP-PAG §7.2", "CRÍTICO", None, "Dashboard demo"),
        ("R-N10", "non-functional", "DevSecOps",       "Support CI/CD, IaC, automated testing, environment segregation and rollback.", "RFP-PAG §7.2", "CRÍTICO", None, "Pipeline evidence"),
        ("R-N12", "non-functional", "Auditability",    "Generate exportable and immutable record of each transaction, control, message, access, decision and resolution.", "RFP-PAG §7.2", "CRÍTICO", None, "Audit trail demo"),
        ("R-N13", "non-functional", "Observability+",  "Logs, metrics, traces, SIEM compatibility, 24x7 monitoring, active-active, OWASP secure coding.", "RFP-PAG §7.2", "CRÍTICO", None, "Architecture evidence"),
    ]
    for r in nfr_reqs:
        conn.execute("INSERT INTO requirements VALUES (?,?,?,?,?,?,?,?,'OPEN')", r)
        conn.execute("INSERT INTO requirements_fts VALUES (?,?,?,?)", (r[0], r[2], r[3], "non-functional"))

    # Regulatory requirements (from RFP Section 7.3)
    reg_reqs = [
        ("R-R01", "compliance", "Applicability",          "Maintain obligations matrix by legal entity, country, product, payment rail and payment type.", "RFP-PAG §7.3", "CRÍTICO", None, "Matrix"),
        ("R-R02", "compliance", "Parties and traceability","Stream and retain ordering customers, beneficiaries, institutions, intermediaries and authorizations.", "RFP-PAG §7.3", "CRÍTICO", None, "UETR trace demo"),
        ("R-R03", "compliance", "Sanctions and PLD/FT",   "Execute controls prior to release, retain lists/versions and manage decisions and cases.", "RFP-PAG §7.3", "CRÍTICO", "PAG-4", "D-04 scenario"),
        ("R-R04", "compliance", "Records and audit",      "Retain instructions, messages, decisions, access records and evidence with verifiable integrity.", "RFP-PAG §7.3", "CRÍTICO", None, "Audit records"),
        ("R-R05", "compliance", "Data protection",        "Control data minimization, residency, cross-border access, sub processors and applicable rights.", "RFP-PAG §7.3", "CRÍTICO", None, "Privacy evidence"),
        ("R-R06", "compliance", "Local Payment Rails",    "Comply rules, messages, schedules and reporting for each rail per geography.", "RFP-PAG §7.3", "CRÍTICO", None, "Rail certifications"),
    ]
    for r in reg_reqs:
        conn.execute("INSERT INTO requirements VALUES (?,?,?,?,?,?,?,?,'OPEN')", r)
        conn.execute("INSERT INTO requirements_fts VALUES (?,?,?,?)", (r[0], r[2], r[3], "compliance"))

    # AI requirements (from RFP Section 10)
    ai_reqs = [
        ("AI-01", "Anomaly detection",             "Explainable and versioned models with features, thresholds, decisions, reason codes and monitoring."),
        ("AI-02", "Operational Copilot",            "Payment status enquiry, evidence, procedures and next actions using cited sources and without unauthorized execution."),
        ("AI-03", "Reconciliation and Investigation","Detection of breaks, correlation of evidence and proposed cause/action for human approval."),
        ("AI-04", "Liquidity and capacity",         "Forecasts by currency, entity, account and payment rail; prediction of peaks, queues and degradation."),
        ("AI-05", "Intelligent routing",            "Recommendations based on cost, liquidity, availability, risk and SLA, subject to mandatory rules."),
        ("AI-06", "RAG and knowledge",              "Semantic search across policies, manuals, contracts and knowledge, with citations, permissions and isolation."),
        ("AI-07", "AI Gateway and multi-model",     "Central control of models, access, quotas, policies, observability, costs and portability."),
        ("AI-08", "MLOps / LLMOps",                "Registration, evaluation, approval, deployment, monitoring, drift, rollback and withdrawal of models/prompts."),
        ("AI-09", "Responsible AI",                 "Impact assessment, explainability, bias, Human-in-the-Loop, auditability and autonomy limits."),
        ("AI-10", "AI Security",                    "Prompt injection protection, data leakage, tool abuse and insecure outputs."),
        ("AI-11", "Fallback",                       "Fallback to rules, alternative model or human process where availability or confidence is insufficient."),
        ("AI-12", "AI in Delivery",                 "Controlled acceleration of design, development, testing and documentation with IP controls."),
    ]
    for a in ai_reqs:
        conn.execute("INSERT INTO ai_requirements VALUES (?,?,?,'OPEN')", a)

    # Geographies (from RFP Section 4.1)
    geos = [
        ("MX",  "México",        "SPEI, SPID, CoDi, DIMO",           "Banxico, CNBV, CONDUSEF, UIF", 1),
        ("US",  "United States", "ACH, Fedwire",                      "FinCEN, Federal Reserve",      2),
        ("UK",  "United Kingdom","Faster Payments, CHAPS",            "FCA, DORA",                    3),
        ("EU",  "Spain/EU",      "SEPA, ISO 20022",                   "CNMV, Banco de España, ECB",   4),
        ("XB",  "Cross-border",  "SWIFT, CBPR+, UETR, correspondent", "SWIFT, CLS",                   1),
    ]
    for g in geos:
        conn.execute("INSERT INTO geographies VALUES (?,?,?,?,?)", g)

    # Indicative timeline (from RFP Section 18.2)
    timeline = [
        ("RFP Issuance",                         "2026-08-27", "DONE"),
        ("Confirmation of Participation and NDA", "2026-09-01", "DONE"),
        ("Q&A",                                  "2026-09-04", "DONE"),
        ("Answers",                              "2026-09-11", "DONE"),
        ("Proposal delivery",                    "2026-09-18", "DONE"),
        ("Initial evaluation and shortlist",     "2026-09-24", "IN_PROGRESS"),
        ("Demonstrations",                       "2026-09-28", "PENDING"),
        ("Due Diligence and Negotiation",        "2026-10-05", "PENDING"),
        ("Decision and Notification",            "2026-10-09", "PENDING"),
    ]
    for t in timeline:
        conn.execute("INSERT INTO timeline VALUES (?,?,?)", t)

    # Priority integrations (from RFP Section 8.2)
    integrations = [
        ("new-platform-channels", "Initiate, validate, authorize, status, fees, notifications and workbench.", "HIGH"),
        ("core-accounts",         "Account, balance, locks, availability, charge/deposit and references.", "HIGH"),
        ("fx",                    "Trade/payment instruction, conversion request, status and settlement linkage.", "HIGH"),
        ("pld-sanctions-fraud",   "Screening, scoring, decision, hold/release/reject, case and evidence.", "HIGH"),
        ("treasury",              "Liquidity, funding, account availability, limits and intraday position.", "HIGH"),
        ("accounting-gl",         "Accounting events, posting acknowledgement, adjustments and reconciliation.", "HIGH"),
        ("swift-rails",           "Messages, acknowledgements, statuses, returns, recalls, reports and connectivity.", "HIGH"),
        ("data-platform",         "Certified events, data products, lineage, quality and reconciliation.", "MEDIUM"),
        ("iam-siem",              "Identity, privileged access, logs, metrics, traces, alerts and incidents.", "HIGH"),
        ("credit-trusts",         "Credit and Trust ecosystems.", "MEDIUM"),
        ("mulesoft",              "API Gateway and integration orchestration — backbone MONEX confirmado.", "HIGH"),
    ]
    for i in integrations:
        conn.execute("INSERT INTO integrations VALUES (?,?,?)", i)

    # Platform candidates
    # Valores = nativo o evidenciado hoy (segun investigacion SME Payments Transformation).
    # (slug, nombre, vendor, iso20022_native, cls_support, spei_support, cloud_native)
    candidates = [
        ("temenos-payments", "Temenos Payments Hub",  "Temenos",  1, 0, 0, 1),
        ("form3",            "Form3 Cloud Payments",  "Form3",    1, 0, 0, 1),
        ("volante",          "Volante VolPay",        "Volante",  1, 0, 1, 1),
        ("finastra",         "Finastra Global PAYplus","Finastra", 1, 1, 0, 0),
        ("2innovate",        "2innovate Frame Banking","2innovate",1, 0, 1, 1),
    ]
    for c in candidates:
        conn.execute("INSERT INTO candidates VALUES (?,?,?,?,?,?,?,'PENDING')", c)

    # Fit-gap por tipo de pago (riel) x vendor. Factor de cobertura segun investigacion SME.
    # coverage: Standard | Configurable | Integration | Bespoke | Not covered | A confirmar
    # (rail, vendor, coverage, note)
    vendor_rail_fit = [
        ("SPEI (MXN)", "Temenos", "Bespoke", "Sin SPEI nativo; net-new"),
        ("SPEI (MXN)", "Form3", "Bespoke", "Sin rieles MX; net-new"),
        ("SPEI (MXN)", "Volante", "Standard", "Banco BASE en vivo desde 2016"),
        ("SPEI (MXN)", "Finastra", "Bespoke", "Sin SPEI publico; net-new"),
        ("SPEI (MXN)", "2innovate", "Standard", "SPEI via APIs; clientes MX"),
        ("SPID (USD)", "Temenos", "Bespoke", ""),
        ("SPID (USD)", "Form3", "Bespoke", ""),
        ("SPID (USD)", "Volante", "Standard", "Banco BASE SPID desde 2016"),
        ("SPID (USD)", "Finastra", "Bespoke", ""),
        ("SPID (USD)", "2innovate", "A confirmar", "SPEI/CECOBAN si; SPID sin confirmar"),
        ("CoDi", "Temenos", "A confirmar", ""),
        ("CoDi", "Form3", "Not covered", ""),
        ("CoDi", "Volante", "Configurable", "Listado en pagina LATAM"),
        ("CoDi", "Finastra", "Bespoke", ""),
        ("CoDi", "2innovate", "A confirmar", ""),
        ("SWIFT / Cross-border", "Temenos", "Standard", "SWIFT GPI"),
        ("SWIFT / Cross-border", "Form3", "Standard", "SWIFT-as-a-Service"),
        ("SWIFT / Cross-border", "Volante", "Standard", "SWIFT / gpi"),
        ("SWIFT / Cross-border", "Finastra", "Standard", "CBPR+, gpi/UETR"),
        ("SWIFT / Cross-border", "2innovate", "Configurable", "SWIFT via APIs"),
        ("CLS (PvP FX)", "Temenos", "Integration", "Via socios Temenos Exchange"),
        ("CLS (PvP FX)", "Form3", "Not covered", ""),
        ("CLS (PvP FX)", "Volante", "Integration", "Orquesta; junto a CLS existente de MONEX"),
        ("CLS (PvP FX)", "Finastra", "Standard", "PAYplus for CLS nativo"),
        ("CLS (PvP FX)", "2innovate", "Not covered", ""),
        ("SEPA (EU)", "Temenos", "Standard", ""),
        ("SEPA (EU)", "Form3", "Standard", ""),
        ("SEPA (EU)", "Volante", "Standard", ""),
        ("SEPA (EU)", "Finastra", "Standard", ""),
        ("SEPA (EU)", "2innovate", "Not covered", "Foco LATAM"),
        ("UK (FPS/Bacs/CHAPS)", "Temenos", "Configurable", "FPS nombrado"),
        ("UK (FPS/Bacs/CHAPS)", "Form3", "Standard", "FPS/Bacs/CHAPS/CoP"),
        ("UK (FPS/Bacs/CHAPS)", "Volante", "Configurable", "Declarado, menos refs"),
        ("UK (FPS/Bacs/CHAPS)", "Finastra", "Configurable", "FPS; Bacs/CHAPS sin confirmar"),
        ("UK (FPS/Bacs/CHAPS)", "2innovate", "Not covered", ""),
        ("US (ACH/Fedwire)", "Temenos", "Configurable", "FedNow certificado"),
        ("US (ACH/Fedwire)", "Form3", "Configurable", "RTP/FedNow/ACH; Fedwire proximo"),
        ("US (ACH/Fedwire)", "Volante", "Standard", "ACH/Fedwire/CHIPS/FedNow/RTP"),
        ("US (ACH/Fedwire)", "Finastra", "Standard", "Fedwire/CHIPS/ACH/RTP/FedNow"),
        ("US (ACH/Fedwire)", "2innovate", "A confirmar", ""),
        ("ISO 20022", "Temenos", "Standard", "CBPR+ nativo"),
        ("ISO 20022", "Form3", "Standard", "Canonico agnostico de esquema"),
        ("ISO 20022", "Volante", "Standard", "Heredad de transformacion"),
        ("ISO 20022", "Finastra", "Standard", "Nativo, MT/MX"),
        ("ISO 20022", "2innovate", "Configurable", "ISO 8583/20022"),
    ]
    for f in vendor_rail_fit:
        conn.execute("INSERT INTO vendor_rail_fit (rail, vendor, coverage, note) VALUES (?,?,?,?)", f)

    conn.commit()
    conn.close()

    rfp_files = list(SOURCE_RFP.glob("*")) if SOURCE_RFP.exists() else []
    print(f"  PAG macro-capabilities: {len(pag_caps)}")
    print(f"  Architecture principles: {len(principles)}")
    print(f"  Requirements: {len(func_reqs)} functional + {len(nfr_reqs)} NFR + {len(reg_reqs)} regulatory")
    print(f"  AI requirements: {len(ai_reqs)}")
    print(f"  Geographies: {len(geos)}")
    print(f"  Timeline milestones: {len(timeline)}")
    print(f"  Priority integrations: {len(integrations)}")
    print(f"  Platform candidates: {len(candidates)}")
    print(f"  RFP files in source/rfp/: {len(rfp_files)}")
    print("Done. Run: python brain.py coverage")


if __name__ == "__main__":
    build()

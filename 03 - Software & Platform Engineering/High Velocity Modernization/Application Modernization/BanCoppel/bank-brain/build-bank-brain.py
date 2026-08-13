"""
build-bank-brain.py — Federated Bank Brain para BanCoppel Unity
Crea bank-brain.db que integra:
  - Informix Core legacy (via ATTACH brain.db — systems/core/Informix/)
  - Minutas Plan Director (56 .docx)
  - Mapa de migración: dominio → sistema destino
  - Interfaces entre sistemas
  - Roadmap de releases Unity
"""

import sqlite3, os, re, sys
from pathlib import Path
from datetime import datetime

# ── Rutas ──────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent.parent
LEGACY_DB  = BASE / "systems/core/Informix/digital-brain/brain.db"
MINUTAS_DIR = BASE / "systems/core/Informix/source/minutas/pd"
OUT_DB = Path(__file__).parent / "bank-brain.db"

assert LEGACY_DB.exists(), f"No se encuentra brain.db en {LEGACY_DB}"

# ── Mapping: dominio Informix → sistema destino Unity ─────────────────────
DOMAIN_TARGET = {
    # Canal Digital Web → entrada API; reparto entre todos los targets
    "D01": "multi",
    # Integración y Auth → middleware → reemplazado por MuleSoft/APG
    "D02": "multi",
    # Créditos → Apolo
    "D03": "apolo",
    # Cheques / Cuentas → Transact
    "D04": "transact",
    # Saldos y Cuentas → Transact
    "D05": "transact",
    # Solicitudes (origination) → Apolo
    "D06": "apolo",
    # Aclaraciones → Transact (gestión de cuentas)
    "D07": "transact",
    # SPEI → Transact
    "D08": "transact",
    # Mensajería (1 SP) → cross
    "D09": "cross",
    # Sucursales → Transact
    "D10": "transact",
    # Cobranza → Apolo (lifecycle de crédito)
    "D11": "apolo",
    # Contabilidad → cross (GL transversal)
    "D12": "cross",
    # TEF → Transact
    "D13": "transact",
    # BEI (Banca Electrónica Institucional) → Transact
    "D14": "transact",
    # LIDE / PLD → cross (compliance)
    "D15": "cross",
    # Tarjetas → SmartVista
    "D16": "smartvista",
    # D17-D22 (sin nombre conocido) → unknown
    "D17": "unknown", "D18": "unknown", "D19": "unknown",
    "D20": "unknown", "D21": "unknown", "D22": "unknown",
    # MIS Sucursales → Transact
    "D23": "transact",
    "D24": "unknown", "D25": "unknown",
    # Prospectos → Apolo (origination)
    "D26": "apolo",
    "D27": "unknown", "D28": "unknown", "D29": "unknown",
    "D30": "unknown", "D31": "unknown",
    # Reportes Visa/MC → SmartVista
    "D32": "smartvista",
    "D33": "unknown",
    # Respaldos DBA → decommission (sólo infraestructura)
    "D34": "decommission",
    # Digitalización → multi (canal digital)
    "D35": "multi",
    # Reportería CNBV → cross (regulatorio)
    "D36": "cross",
    # Nómina BPI → Transact
    "D37": "transact",
    "D38": "unknown", "D39": "unknown",
    # Banca Internet → multi (canal digital)
    "D40": "multi",
    "D41": "unknown", "D42": "unknown", "D43": "unknown",
    # Conciliación Operativa → cross
    "D44": "cross",
    # Premios → multi
    "D45": "multi",
    # Oficinas de Cobro → Apolo
    "D46": "apolo",
    # Garantías → Apolo
    "D47": "apolo",
    # Riesgos de Crédito → Apolo
    "D48": "apolo",
    # Retiro sin Tarjeta → Transact (cajero/operación)
    "D49": "transact",
}

# Confidence: cómo de seguro estamos del mapping
DOMAIN_CONFIDENCE = {
    "D03": "high", "D04": "high", "D05": "high", "D06": "high",
    "D08": "high", "D11": "high", "D12": "high", "D13": "high",
    "D14": "high", "D15": "high", "D16": "high",
    "D01": "medium", "D02": "medium", "D07": "medium", "D10": "medium",
    "D09": "low",  "D23": "medium", "D26": "high",
    "D32": "high", "D36": "high", "D37": "medium",
    "D40": "medium", "D44": "high", "D45": "low",
    "D46": "high", "D47": "high", "D48": "high", "D49": "high",
    "D34": "high", "D35": "medium",
}

# ── Helpers minutas ────────────────────────────────────────────────────────
SYSTEM_KEYWORDS = {
    "apolo":       r"\bapolo\b",
    "smartvista":  r"\bsmartvista\b|\bsmart\s*vista\b|\bbpc\b",
    "transact":    r"\btransact\b",
    "atlas":       r"\batlas\b",
    "pisa":        r"\bpisa\b|\blegacy\b|\binformix\b|\bspl\b",
    "unity":       r"\bunity\b|\bplan director\b",
}

def detect_systems(text: str) -> list[str]:
    text_low = text.lower()
    return [s for s, pat in SYSTEM_KEYWORDS.items() if re.search(pat, text_low)]

def extract_date_from_filename(fname: str) -> str | None:
    """Extrae YYYY-MM-DD de patrones como '17 Marzo 2026', '9 Abril', '28 Abr', '20-23 Abr', 'April 15', etc."""
    months = {
        # Español completo
        "enero": "01", "febrero": "02", "marzo": "03", "abril": "04",
        "mayo": "05", "junio": "06", "julio": "07", "agosto": "08",
        "septiembre": "09", "octubre": "10", "noviembre": "11", "diciembre": "12",
        # Español abreviado
        "ene": "01", "feb": "02", "mar": "03", "abr": "04",
        "may": "05", "jun": "06", "jul": "07", "ago": "08",
        "sep": "09", "oct": "10", "nov": "11", "dic": "12",
        # Inglés completo
        "january": "01", "february": "02", "march": "03", "april": "04",
        "june": "06", "july": "07", "august": "08",
        "september": "09", "october": "10", "november": "11", "december": "12",
        # Inglés abreviado
        "jan": "01", "feb": "02", "jun": "06", "jul": "07", "aug": "08",
        "sep": "09", "oct": "10", "nov": "11", "dec": "12",
    }
    # Patrón ISO
    m = re.search(r'(\d{4}-\d{2}-\d{2})', fname)
    if m:
        return m.group(1)
    # "DD-DD Mes" o "DD Mes" (con año opcional). El primer número = primer día del rango.
    m = re.search(r'(\d{1,2})(?:-\d{1,2})?\s+([A-Za-z]+)(?:\s+(\d{4}))?', fname)
    if m:
        day, month_str = m.group(1), m.group(2).lower()
        year = m.group(3) or "2026"
        month = months.get(month_str)
        if month:
            return f"{year}-{month}-{int(day):02d}"
    # "Mes DD" (inglés: "April 15")
    m = re.search(r'([A-Za-z]+)\s+(\d{1,2})(?:\s+(\d{4}))?', fname)
    if m:
        month_str, day = m.group(1).lower(), m.group(2)
        year = m.group(3) or "2026"
        month = months.get(month_str)
        if month:
            return f"{year}-{month}-{int(day):02d}"
    return None

def parse_minuta(path: Path) -> dict:
    """Extrae metadatos de un .docx de minuta."""
    result = {
        "path": str(path),
        "filename": path.name,
        "date": extract_date_from_filename(path.name),
        "title": path.stem,
        "paragraphs": 0,
        "systems_mentioned": [],
        "key_topics": [],
        "word_count": 0,
        "error": None,
    }
    try:
        import docx
        doc = docx.Document(str(path))
        paragraphs = [p.text.strip() for p in doc.paragraphs if p.text.strip()]
        result["paragraphs"] = len(paragraphs)
        full_text = "\n".join(paragraphs)
        result["word_count"] = len(full_text.split())
        result["systems_mentioned"] = detect_systems(full_text)

        # Extraer temas clave: párrafos que contengan palabras clave de arquitectura
        topic_keywords = [
            r"\bdecisi[oó]n\b", r"\bacord[oó]\b", r"\bpendiente\b",
            r"\barquitectura\b", r"\bintegraci[oó]n\b", r"\bmigraci[oó]n\b",
            r"\bapi\b", r"\bbase de datos\b", r"\bflujo\b", r"\bseguridad\b",
        ]
        key_paras = []
        for p in paragraphs[:80]:  # primeros 80 párrafos
            if any(re.search(kw, p, re.IGNORECASE) for kw in topic_keywords):
                key_paras.append(p[:200])
        result["key_topics"] = key_paras[:10]

        # Título real: primera línea no vacía
        if paragraphs:
            result["title"] = paragraphs[0][:200]
    except Exception as e:
        result["error"] = str(e)
    return result


def build():
    print(f"=== build-bank-brain.py ===")
    print(f"Origen legacy:  {LEGACY_DB}")
    print(f"Minutas dir:    {MINUTAS_DIR}")
    print(f"Output:         {OUT_DB}")
    print()

    # Eliminar DB previa
    if OUT_DB.exists():
        OUT_DB.unlink()
        print("Eliminada bank-brain.db anterior")

    db = sqlite3.connect(str(OUT_DB))
    db.execute("PRAGMA journal_mode=WAL")
    db.execute("PRAGMA foreign_keys=ON")

    # ── 1. ATTACH legacy brain.db ─────────────────────────────────────────
    db.execute(f"ATTACH DATABASE '{str(LEGACY_DB).replace(chr(92), '/')}' AS legacy")
    print("Attached brain.db as 'legacy'")

    # ── 2. DDL ───────────────────────────────────────────────────────────
    db.executescript("""
    -- Sistemas participantes en el ecosistema BanCoppel Unity
    CREATE TABLE IF NOT EXISTS systems (
        id                TEXT PRIMARY KEY,      -- apolo, smartvista, transact, pisa, atlas, mulesoft
        name              TEXT NOT NULL,
        type              TEXT NOT NULL,         -- legacy | target | migration | middleware
        status            TEXT NOT NULL,         -- active | in-dev | planned | decommission
        tech_stack        TEXT,
        description       TEXT,
        notes             TEXT,
        togaf_type        TEXT,   -- core | processors | channels | data | integration | compliance
        togaf_state       TEXT,   -- baseline | transitional | target
        production_status TEXT,   -- live | partial | in_flight | planned
        production_since  TEXT    -- primera fecha en producción (YYYY-QN o YYYY-MM)
    );

    -- Documentos indexados (minutas + futuros ADRs, specs)
    CREATE TABLE IF NOT EXISTS documents (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        type        TEXT NOT NULL DEFAULT 'minuta',
        date        TEXT,
        title       TEXT,
        filename    TEXT UNIQUE,
        word_count  INTEGER,
        paragraphs  INTEGER,
        systems_mentioned TEXT,  -- JSON array
        key_topics  TEXT,        -- JSON array
        file_path   TEXT,
        error       TEXT
    );

    -- Interfaces entre sistemas (capa de integración)
    CREATE TABLE IF NOT EXISTS interfaces (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        from_sys    TEXT NOT NULL REFERENCES systems(id),
        to_sys      TEXT NOT NULL REFERENCES systems(id),
        name        TEXT,
        protocol    TEXT,         -- REST, MQ, DB-link, file, SPEI, ISO20022
        direction   TEXT,         -- sync | async | batch
        status      TEXT,         -- defined | in-dev | production | deprecated
        source_doc  TEXT,         -- nombre de minuta de origen
        notes       TEXT
    );

    -- Mapa de migración: SP legacy → sistema destino
    CREATE TABLE IF NOT EXISTS migrations (
        sp          TEXT NOT NULL,          -- nombre del SP
        db          TEXT NOT NULL,          -- BD Informix de origen
        domain_id   TEXT,                   -- D01..D49
        domain_name TEXT,
        target_sys  TEXT NOT NULL,          -- apolo | transact | smartvista | cross | multi | decommission | unknown
        confidence  TEXT DEFAULT 'medium',  -- high | medium | low
        sp_count    INTEGER DEFAULT 1,      -- SPs en este grupo
        rule_count  INTEGER DEFAULT 0,      -- reglas de negocio en el SP
        etb_l3      TEXT,                   -- capacidad ETB L3 principal
        PRIMARY KEY (sp, db)
    );

    -- Resumen de migración por dominio
    CREATE VIEW IF NOT EXISTS migration_summary AS
        SELECT
            domain_id,
            domain_name,
            target_sys,
            confidence,
            COUNT(*)        AS sp_count,
            SUM(rule_count) AS rule_count
        FROM migrations
        GROUP BY domain_id, target_sys
        ORDER BY domain_id;

    -- Releases Unity (roadmap)
    CREATE TABLE IF NOT EXISTS releases (
        id          TEXT PRIMARY KEY,        -- U1, U2, ...
        name        TEXT,
        target_date TEXT,
        status      TEXT,                    -- planned | in-dev | released
        scope       TEXT,                    -- JSON array de systems
        milestones  TEXT,                    -- texto libre
        notes       TEXT
    );

    CREATE INDEX IF NOT EXISTS idx_mig_target  ON migrations(target_sys);
    CREATE INDEX IF NOT EXISTS idx_mig_domain  ON migrations(domain_id);
    CREATE INDEX IF NOT EXISTS idx_doc_date    ON documents(date);
    CREATE INDEX IF NOT EXISTS idx_doc_systems ON documents(systems_mentioned);

    -- Vendors tecnológicos (Temenos, BPC, etc.)
    CREATE TABLE IF NOT EXISTS vendors (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        system_id   TEXT REFERENCES systems(id),
        category    TEXT,
        modules     TEXT,   -- JSON array
        notes       TEXT
    );

    -- Productos bancarios (puente producto → plataforma → legacy)
    CREATE TABLE IF NOT EXISTS products (
        id                TEXT PRIMARY KEY,
        name              TEXT NOT NULL,
        platform_id       TEXT REFERENCES systems(id),
        vendor_id         TEXT REFERENCES vendors(id),
        segment           TEXT,                -- 'retail', 'empresarial', 'colaboradores'
        status            TEXT,                -- 'live' | 'partial' | 'in_flight' | 'planned'
        launch_wave       TEXT,                -- release wave en curso (R4, U1, etc.)
        target_date       TEXT,
        notes             TEXT,
        went_live_release TEXT REFERENCES releases(id)  -- release en que salió a producción (null si aún no)
    );

    CREATE INDEX IF NOT EXISTS idx_products_platform ON products(platform_id);
    CREATE INDEX IF NOT EXISTS idx_products_status   ON products(status);

    -- Dependencias cross-sistema (documentadas desde perspectiva de bank-brain)
    -- Regla AM: cada cerebro declara su lado; bank-brain agrega la vista global.
    -- direction: 'outbound' = source_system depende de target_system
    --            'inbound'  = source_system es proveedor de target_system
    -- En este contexto la FK es entre sistemas del ecosistema; target_system puede ser
    -- externo (ej. controlm, banxico, visa) — no FK constraint en target_system.
    CREATE TABLE IF NOT EXISTS system_dependencies (
        id               TEXT PRIMARY KEY,
        source_system    TEXT NOT NULL REFERENCES systems(id),
        target_system    TEXT NOT NULL,    -- puede ser externo (no FK)
        dependency_type  TEXT NOT NULL,    -- orchestrates | calls | reads | writes | feeds | notifies
        direction        TEXT NOT NULL,    -- outbound (source necesita target) | inbound (target necesita source)
        description      TEXT,
        evidence         TEXT,             -- cuantificación: "3,847 SPs batch invocados desde malla CTM"
        criticality      TEXT,             -- critical | high | medium | low
        notes            TEXT
    );

    CREATE INDEX IF NOT EXISTS idx_sysdep_source ON system_dependencies(source_system);
    CREATE INDEX IF NOT EXISTS idx_sysdep_target ON system_dependencies(target_system);
    """)
    db.commit()
    print("DDL aplicado")

    # ── 3. Sistemas ───────────────────────────────────────────────────────
    systems = [
        #  id            name                   type       status     tech_stack
        #  description   notes
        #  togaf_type    togaf_state            production_status  production_since
        ("pisa",       "PISA / BCOPCore",      "legacy",  "active",
         "IBM Informix IDS 14.10 / POWER-AIX / SPL",
         "Core bancario legado BanCoppel. 10,144 SPs, 60 TB, 8,005 reglas de negocio catalogadas.",
         "En proceso de decommission dentro del programa Unity.",
         "core", "baseline", "live", "~2000"),
        ("apolo",      "Apolo",                "target",  "in-dev",
         "Java / microservicios / Kubernetes / PostgreSQL",
         "Sistema destino para crédito, origination, cobranza, garantías y riesgos de crédito.",
         "Desarrollo activo. Dominios D03, D06, D11, D26, D46, D47, D48.",
         "channels", "target", "in_flight", None),
        ("smartvista", "SmartVista / BPC",     "target",  "in-dev",
         "SmartVista (BPC) / Java",
         "Sistema destino para tarjetas TDC y TDD.",
         "Dominios D16, D32. Procesador de tarjetas certificado Visa/MC.",
         "processors", "transitional", "partial", "2026-Q1"),
        ("transact",   "Transact",             "target",  "in-dev",
         "Temenos Transact / Java",
         "Sistema destino para cuentas, depósitos, SPEI, TEF, sucursales.",
         "Dominios D04, D05, D07, D08, D10, D13, D14, D23, D37, D49.",
         "core", "transitional", "partial", "2026-Q1"),
        ("atlas",      "Atlas",                "migration", "in-dev",
         "Talend / Python / Spark",
         "Plataforma de migración de datos PISA → sistemas destino.",
         "No es sistema operativo. Gobierna la extracción, transformación y carga de datos históricos.",
         "data", "transitional", "in_flight", None),
        ("mulesoft",   "MuleSoft / API Gateway","middleware","in-dev",
         "MuleSoft Anypoint Platform",
         "Capa de integración y orquestación entre sistemas (reemplaza bdicnweb + bdinteg).",
         "Dominios D01, D02 migran a APIs publicadas en MuleSoft.",
         "integration", "transitional", "in_flight", None),
        ("controlm",   "Control-M / Malla Batch", "middleware", "active",
         "BMC Control-M",
         "Orquestador de trabajos batch del ecosistema BanCoppel. Ejecuta la malla de SPs "
         "Informix en ventanas horarias programadas (noche, fin de semana). Gestiona cadenas "
         "de dependencia entre jobs, calendarios, alertas de SLA batch y retry automático.",
         "Sistema en producción desde operación legacy. 5,052 jobs confirmados en inventario "
         "2026-08-12: 3,859 Informix, 32 Unity/SmartVista, 65 flujos batch identificados.",
         "integration", "baseline", "live", "~2000"),
        # ── Sistemas descubiertos vía inventario CTM 2026-08-12 (Regla B8 AM) ──
        ("pld",        "PLD / Minds AML",          "compliance", "active",
         "Minds (vendor pendiente confirmar)",
         "Sistema de Prevención de Lavado de Dinero de BanCoppel. Gestiona la carga de "
         "información de transacciones, detección de patrones sospechosos y generación de "
         "reportes regulatorios para CNBV/UIF (LFPIORPI R17/R35).",
         "Descubierto: inventario CTM 2026-08-12. 208 jobs en servidores PLD dedicados "
         "(dccpld01/dcmpld01/dccpld02/dcmpld02). DR-PLD-001 pendiente: vendor/versión Minds.",
         "compliance", "baseline", "live", "unknown"),
        ("datastage",  "IBM InfoSphere DataStage",  "data",      "active",
         "IBM InfoSphere DataStage (ETL)",
         "Motor ETL de BanCoppel. Gestiona flujos de integración de datos: extracción desde "
         "Informix, transformación y carga hacia Data Warehouse y sistemas destino. "
         "HALLAZGO CRÍTICO: carpeta UTR-UNITY_TRANSACT confirma que DataStage ya está "
         "integrado en la malla de migración Unity/Transact.",
         "Descubierto: inventario CTM 2026-08-12. Hosts: dccinfsph2/dccinfsphe2/dccinfsph1. "
         "UTR-UNITY_TRANSACT activo en producción — DataStage ES parte de la migración.",
         "data", "transitional", "live", "unknown"),
        ("digitalizacion", "Digitalización / Expediente Digital", "data", "active",
         "Sistema de gestión documental (vendor pendiente confirmar)",
         "Sistema de gestión documental de BanCoppel. Gestiona el expediente digital de "
         "clientes: imágenes de identificaciones, contratos firmados, comprobantes, "
         "estados de cuenta y archivos de intercambio entre áreas.",
         "Descubierto: inventario CTM 2026-08-12. 156 jobs en servidores imagen "
         "(dccimg01/dcmimg01). DR-DIG-001 pendiente: vendor/plataforma documental.",
         "data", "baseline", "live", "unknown"),
        ("paytrue",    "PayTrue / Prevención de Fraudes", "channels", "active",
         "PayTrue (vendor/interno pendiente confirmar) + Python",
         "Sistema de prevención de fraude transaccional. Corre sobre servidores Python. "
         "Aplica modelos de scoring para detección de fraude sobre transacciones y "
         "señales de comportamiento de clientes (transacciones NO financieras).",
         "Descubierto: inventario CTM 2026-08-12. 56 jobs en servidores Python "
         "(dccpyt01/dcmpyt01). DR-PT-001 pendiente: vendor vs desarrollo interno.",
         "channels", "baseline", "live", "unknown"),
    ]
    db.executemany(
        "INSERT OR REPLACE INTO systems VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        systems
    )
    print(f"Sistemas insertados: {len(systems)}")

    # ── 4. Minutas ────────────────────────────────────────────────────────
    import json
    minutas_files = sorted(MINUTAS_DIR.glob("*.docx")) if MINUTAS_DIR.exists() else []
    minutas_data = []
    errors = 0
    for mf in minutas_files:
        m = parse_minuta(mf)
        minutas_data.append(m)
        if m["error"]:
            errors += 1

    db.executemany(
        """INSERT OR IGNORE INTO documents
           (type, date, title, filename, word_count, paragraphs,
            systems_mentioned, key_topics, file_path, error)
           VALUES ('minuta',?,?,?,?,?,?,?,?,?)""",
        [
            (
                m["date"], m["title"], m["filename"],
                m["word_count"], m["paragraphs"],
                json.dumps(m["systems_mentioned"], ensure_ascii=False),
                json.dumps(m["key_topics"], ensure_ascii=False),
                m["path"], m["error"],
            )
            for m in minutas_data
        ]
    )
    print(f"Minutas indexadas: {len(minutas_data)} ({errors} con error)")

    # ── 5. Interfaces (seeded desde minutas y arquitectura conocida) ───────
    interfaces = [
        # PISA → MuleSoft (durante coexistencia)
        ("pisa", "mulesoft", "PISA→ESB adapt", "REST/SOAP", "sync",
         "in-dev", "arquitectura-unity.docx",
         "Adaptadores para exponer SPs legacy via API durante la transición"),
        # MuleSoft → Apolo
        ("mulesoft", "apolo", "ESB→Apolo crédito", "REST", "sync",
         "in-dev", None, "Orquestación de operaciones de crédito"),
        # MuleSoft → SmartVista
        ("mulesoft", "smartvista", "ESB→SmartVista TDC", "REST", "sync",
         "in-dev", None, "Procesamiento de transacciones de tarjeta"),
        # MuleSoft → Transact
        ("mulesoft", "transact", "ESB→Transact depósitos", "REST", "sync",
         "planned", None, "Cuentas, depósitos y TEF"),
        # Atlas ← PISA (extracción)
        ("pisa", "atlas", "PISA→Atlas extracción", "JDBC/file", "batch",
         "in-dev", None, "Extracción de datos históricos para migración"),
        # Atlas → Apolo (carga)
        ("atlas", "apolo", "Atlas→Apolo carga", "API/SQL", "batch",
         "in-dev", None, "Carga de saldos y cartera de crédito histórica"),
        # Atlas → Transact (carga)
        ("atlas", "transact", "Atlas→Transact carga", "API/SQL", "batch",
         "planned", None, "Carga de cuentas y depósitos históricos"),
        # Atlas → SmartVista (carga)
        ("atlas", "smartvista", "Atlas→SmartVista carga", "API/SQL", "batch",
         "planned", None, "Carga de portafolio de tarjetas histórico"),
        # SPEI: Transact → Banxico
        ("transact", "mulesoft", "Transact→SPEI", "ISO20022", "async",
         "planned", None, "Liquidación SPEI vía red Banxico"),
    ]
    db.executemany(
        """INSERT INTO interfaces
           (from_sys, to_sys, name, protocol, direction, status, source_doc, notes)
           VALUES (?,?,?,?,?,?,?,?)""",
        interfaces
    )
    print(f"Interfaces insertadas: {len(interfaces)}")

    # ── 6. Migrations: PISA SPs → target system ───────────────────────────
    # Leer todos los SPs de legacy brain.db con su dominio
    sp_rows = db.execute("""
        SELECT
            s.name        AS sp,
            s.db          AS db,
            d.id          AS domain_id,
            d.name        AS domain_name,
            COUNT(r.id)   AS rule_count
        FROM legacy.sps s
        LEFT JOIN legacy.domains d ON s.domain = d.id
        LEFT JOIN legacy.rules r ON r.sp = (s.db || ':' || s.name)
        GROUP BY s.name, s.db
    """).fetchall()

    migration_rows = []
    for sp, db_name, domain_id, domain_name, rule_count in sp_rows:
        target = DOMAIN_TARGET.get(domain_id or "", "unknown")
        confidence = DOMAIN_CONFIDENCE.get(domain_id or "", "low")
        migration_rows.append((
            sp, db_name, domain_id, domain_name,
            target, confidence, 1, rule_count or 0, None
        ))

    db.executemany(
        """INSERT OR REPLACE INTO migrations
           (sp, db, domain_id, domain_name, target_sys, confidence, sp_count, rule_count, etb_l3)
           VALUES (?,?,?,?,?,?,?,?,?)""",
        migration_rows
    )
    print(f"SPs migrados a tabla migrations: {len(migration_rows)}")

    # ── 7. Releases Unity ─────────────────────────────────────────────────
    releases = [
        # ── Hitos internos BanCoppel (R-series) ────────────────────────────
        ("R1", "Release 1 — Infraestructura y Aprobaciones Regulatorias",
         "2025-12", "completed",
         json.dumps(["transact", "smartvista", "atlas"], ensure_ascii=False),
         "Setup de ambientes cloud (AWS). Aprobación CNBV para operación cloud-native.",
         "Hito regulatorio clave: CNBV autoriza operación sobre AWS antes del primer go-live"),
        ("R2", "Release 2 — Friends & Family",
         "2026-Q1", "completed",
         json.dumps(["transact", "smartvista"], ensure_ascii=False),
         "Crédito simple empresarial (Transact) + Tarjeta de crédito BanCoppel (SmartVista). "
         "Usuarios internos y amigos/familia.",
         "Primer go-live real con productos bancarios en plataformas target"),
        ("R3", "Release 3 — POC Colaboradores",
         "2026-Q2", "completed",
         json.dumps(["smartvista", "atlas"], ensure_ascii=False),
         "SmartVista: POC con colaboradores BanCoppel. Atlas: primera fase de migración de datos históricos.",
         "Cerrado — confirmado 2026-08-12"),
        ("R4", "Release 4 — Go-Live Masivo",
         "2026-12", "in_flight",
         json.dumps(["smartvista", "apolo", "transact", "atlas"], ensure_ascii=False),
         "Rollout masivo cartera TDC (17 funcionalidades críticas SmartVista). Apollo App a mercado abierto. "
         "Depósitos/cuentas Transact inician.",
         "Deadline de negocio: diciembre 2026. Hito de cierre del primer bloque Unity"),
        # ── Waves del Plan Director Accenture (U-series) ───────────────────
        ("U1", "Unity Wave 1 — Crédito Digital",
         "2026-09", "in_flight",
         json.dumps(["apolo", "mulesoft"], ensure_ascii=False),
         "Migración de origination y crédito personal (D03, D06). Apolo go-live parcial.",
         "Plan Director semanas 1-6 (mar-abr 2026)"),
        ("U2", "Unity Wave 2 — Cuentas y Depósitos",
         "2026-12", "planned",
         json.dumps(["transact", "mulesoft"], ensure_ascii=False),
         "Migración de cuentas, SPEI y TEF (D04, D05, D08, D13). Transact go-live parcial.",
         "Pendiente arquitectura detallada Transact"),
        ("U3", "Unity Wave 3 — Tarjetas",
         "2027-03", "planned",
         json.dumps(["smartvista", "mulesoft"], ensure_ascii=False),
         "Migración de portafolio TDC/TDD (D16). SmartVista go-live.",
         "Sujeto a certificación Visa/MC"),
        ("U4", "Unity Wave 4 — Cobranza y Riesgos",
         "2027-06", "planned",
         json.dumps(["apolo"], ensure_ascii=False),
         "Migración de cobranza, garantías y riesgos (D11, D47, D48). Cierre Apolo.",
         ""),
        ("U5", "Unity Final — PISA Decommission",
         "2027-12", "planned",
         json.dumps(["pisa"], ensure_ascii=False),
         "Apagado de PISA/BCOPCore. Cierre de Atlas. Migración de datos históricos completa.",
         "Hito regulatorio: notificación CNBV mínimo 6 meses antes"),
    ]
    db.executemany(
        "INSERT OR REPLACE INTO releases VALUES (?,?,?,?,?,?,?)",
        releases
    )
    print(f"Releases insertados: {len(releases)}")

    # ── 8. Vendors ────────────────────────────────────────────────────────
    vendors_data = [
        (
            "temenos", "Temenos", "transact", "core-banking",
            json.dumps([
                "Retail Banking", "Corporate Banking / Crédito Empresarial",
                "Depósitos y Cuentas", "Pagos (SPEI/TEF/ACH)", "Sucursales",
                "Gestión de Límites", "Cumplimiento Regulatorio"
            ], ensure_ascii=False),
            "Vendor del core bancario Transact. EY consultor responsable de implementación. "
            "Productivo: crédito simple empresarial (CNBV aprobado sobre AWS). "
            "Roadmap: cuentas/depósitos 1T-2028, crédito retail 4T-2028."
        ),
        (
            "bpc", "BPC (Budget Pro Consulting) — SmartVista", "smartvista", "card-processing",
            json.dumps([
                "Emisión de Tarjetas (TDC/TDD)", "Autorización en tiempo real",
                "Liquidación y Compensación", "Gestión de Límites de Crédito",
                "Recompensas y Beneficios", "Reportería Visa/Mastercard",
                "Gestión de Disputas y Aclaraciones"
            ], ensure_ascii=False),
            "Vendor del procesador de tarjetas SmartVista. Certificado Visa/Mastercard. "
            "Productivo: tarjeta de crédito BanCoppel (friends & family, R2). "
            "Rollout masivo cartera completa R4 (dic-2026)."
        ),
    ]
    db.executemany("INSERT OR REPLACE INTO vendors VALUES (?,?,?,?,?,?)", vendors_data)
    print(f"Vendors insertados: {len(vendors_data)}")

    # ── 9. Products ───────────────────────────────────────────────────────
    products_data = [
        # id, name, platform_id, vendor_id, segment, status, launch_wave, target_date, notes, went_live_release
        ("tarjeta-credito-sv",
         "Tarjeta de Crédito BanCoppel (SmartVista)",
         "smartvista", "bpc", "retail", "partial", "R4", "2026-Q1",
         "Primer producto nativo en SmartVista/BPC. Fase friends & family (R2). "
         "Rollout masivo cartera completa en R4 (dic-2026).",
         "R2"),     # went_live_release
        ("credito-simple-emp",
         "Crédito Simple Empresarial (Transact)",
         "transact", "temenos", "empresarial", "partial", "R4", "2026-Q1",
         "Primer producto nativo en Temenos Transact. CNBV aprobó operación sobre AWS (R2). "
         "Escenario minorista y cuentas requieren aprobaciones adicionales.",
         "R2"),     # went_live_release
        ("tarjeta-credito-full",
         "Cartera Completa TDC (migración masiva a SmartVista)",
         "smartvista", "bpc", "retail", "in_flight", "R4", "2026-12",
         "Migración de toda la cartera TDC al procesador SmartVista. "
         "POC en R3 con colaboradores. 17 funcionalidades críticas en R4.",
         None),    # went_live_release = null (no está en producción aún)
        ("apollo-app",
         "Apollo App (experiencia móvil)",
         "apolo", None, "retail", "in_flight", "R4", "2026-12",
         "Experiencia móvil para lanzamiento a mercado abierto. Deadline de negocio: R4.",
         None),
        ("depositos-cuentas",
         "Depósitos y Cuentas (Transact)",
         "transact", "temenos", "retail", "planned", None, "2028-Q1",
         "Cuentas y depósitos retail en Temenos Transact. "
         "Depende de Atlas Fase 2 (Golden Record MDM productivo). Dominios legacy: D04, D05.",
         None),
        ("credito-retail",
         "Crédito Retail (Transact)",
         "transact", "temenos", "retail", "planned", None, "2028-Q4",
         "Crédito retail completo en Temenos Transact. Hito de cierre del negocio core Coppel. "
         "Dominios legacy: D03, D06.",
         None),
    ]
    db.executemany("INSERT OR REPLACE INTO products VALUES (?,?,?,?,?,?,?,?,?,?)", products_data)
    print(f"Productos insertados: {len(products_data)}")

    # ── 10. System Dependencies ───────────────────────────────────────────────
    # Regla: cada cerebro declara su lado; bank-brain agrega la vista global.
    # Perspectiva: outbound = el source_system NECESITA al target_system.
    sys_deps = [
        # PISA (Informix) ← Control-M: CTM orquesta los SPs batch de PISA.
        # Desde perspectiva de PISA = inbound (recibe orquestación).
        # Desde perspectiva de CTM  = outbound (llama a PISA).
        ("pisa-controlm-batch",
         "pisa", "controlm", "orchestrates", "inbound",
         "Control-M invoca los SPs batch de Informix en ventanas programadas. "
         "La lógica de negocio (SPs) vive en PISA; el cuándo y en qué orden vive en Control-M.",
         "Dato pendiente: N° de jobs activos en malla CTM → SP Informix",
         "critical",
         "Relación bidireccional documentada en ambos brains. "
         "PISA brain: cross_dependencies → outbound a CTM (batch-callable SPs). "
         "CTM brain (futuro): cross_dependencies → inbound a PISA (jobs que invocan SPs)."),
        # Informix → Banxico (SPEI batch liquidaciones nocturnas)
        ("pisa-banxico-spei-batch",
         "pisa", "banxico", "feeds", "outbound",
         "Informix genera los archivos de liquidación SPEI que se envían a Banxico en batch nocturno.",
         "Dominio D08 — SPs de SPEI generan archivos CECOBAN/SPEI para cierre de día.",
         "critical",
         "Externo — Banxico no tiene brain. Dependencia documentada desde perspectiva PISA."),
        # Informix → VISA/MC reportería
        ("pisa-visa-reporteria",
         "pisa", "smartvista", "feeds", "outbound",
         "Informix genera reportería de tarjetas (D32) que alimenta reconciliación en SmartVista.",
         "Dominio D32 — SPs de reportería Visa/MC. SmartVista los consume.",
         "high", None),
        # Atlas extrae de PISA (ya en interfaces, se documenta también como dependencia)
        ("pisa-atlas-extraccion",
         "pisa", "atlas", "reads", "inbound",
         "Atlas extrae datos históricos de PISA vía JDBC y archivos flat para migración.",
         "Extracción nocturna por ventana batch. Impacta performance en ventana activa.",
         "high", None),
        # ── Dependencias de sistemas descubiertos CTM 2026-08-12 (Regla B8 + B10 AM) ──
        # PLD recibe señales AML de PISA (D15) orquestadas por Control-M.
        ("pisa-pld-feeds",
         "pisa", "pld", "feeds", "outbound",
         "PISA (D15 bdilide/bdiauditor/bdisitesp) genera señales AML batch que PLD/Minds "
         "consume para análisis de lavado de dinero y reportes CNBV/UIF.",
         "208 jobs CTM en servidores PLD. Inventario 2026-08-12. "
         "Knowledge interlock: Informix brain declaró pisa-pld-aml-signals el mismo día.",
         "high",
         "Regla B10 AM — knowledge interlock: hallado en inventario CTM, propagado a "
         "Informix brain (pisa-pld-aml-signals) y a bank-brain (este registro)."),
        # DataStage lee de PISA para Unity Transact (UTR-UNITY_TRANSACT).
        ("pisa-datastage-unity",
         "pisa", "datastage", "reads", "inbound",
         "DataStage extrae datos de PISA para la integración Unity/Transact "
         "(carpeta UTR-UNITY_TRANSACT activa en producción). DataStage es capa ETL "
         "entre el core Informix y el sistema Transact destino.",
         "Hallazgo crítico CTM 2026-08-12: UTR-UNITY_TRANSACT en host datastage. "
         "Knowledge interlock: Informix brain declaró pisa-datastage-transact el mismo día.",
         "high",
         "Regla B10 AM — knowledge interlock: hallado en inventario CTM, propagado a "
         "Informix brain (pisa-datastage-transact) y a bank-brain (este registro). "
         "IMPLICACIÓN: DataStage IS parte de la migración Unity, no solo del legacy."),
        # Control-M orquesta a DataStage, PLD, Digitalización y PayTrue.
        ("controlm-datastage-batch",
         "controlm", "datastage", "orchestrates", "outbound",
         "Control-M orquesta los jobs de DataStage via PRO_DATA_WAREHOUSE_001 y "
         "carpeta UTR-UNITY_TRANSACT. CTM gestiona el scheduling y dependencias.",
         "Inventario CTM 2026-08-12: jobs en hosts dccinfsph2/dccinfsphe2.",
         "high", None),
        ("controlm-pld-batch",
         "controlm", "pld", "orchestrates", "outbound",
         "Control-M orquesta los jobs de PLD/Minds (208 jobs en PRO_PLD_MINDS_001).",
         "Inventario CTM 2026-08-12: hosts dccpld01/dcmpld01.",
         "high", None),
        ("controlm-digitalizacion-batch",
         "controlm", "digitalizacion", "orchestrates", "outbound",
         "Control-M orquesta los jobs de Digitalización (156 jobs en PRO_DIGITALIZACION_001).",
         "Inventario CTM 2026-08-12: hosts dccimg01/dcmimg01.",
         "medium", None),
        ("controlm-paytrue-batch",
         "controlm", "paytrue", "orchestrates", "outbound",
         "Control-M orquesta los jobs de PayTrue/Prevención de Fraudes (56 jobs en "
         "PRO_PAYTRUE_001 + PFR-PREVENCION_FRAUDES).",
         "Inventario CTM 2026-08-12: hosts dccpyt01/dcmpyt01.",
         "high", None),
    ]
    db.executemany(
        """INSERT OR REPLACE INTO system_dependencies
           (id, source_system, target_system, dependency_type, direction, description, evidence, criticality, notes)
           VALUES (?,?,?,?,?,?,?,?,?)""",
        sys_deps
    )
    print(f"System dependencies insertadas: {len(sys_deps)}")

    db.commit()

    # ── 10. Resumen ───────────────────────────────────────────────────────
    print()
    print("=== RESUMEN bank-brain.db ===")
    for table in ["systems", "documents", "interfaces", "migrations", "releases",
                  "vendors", "products", "system_dependencies"]:
        n, = db.execute(f"SELECT COUNT(*) FROM {table}").fetchone()
        print(f"  {table:<15}: {n:>6}")

    print()
    print("--- Migrations por target_sys ---")
    for target, cnt, rules in db.execute(
        "SELECT target_sys, COUNT(*), SUM(rule_count) FROM migrations GROUP BY target_sys ORDER BY 2 DESC"
    ):
        print(f"  {target:<15}: {cnt:>5} SPs   {rules or 0:>6} reglas")

    print()
    print("--- Documentos por sistema mencionado ---")
    all_docs = db.execute("SELECT systems_mentioned FROM documents WHERE systems_mentioned IS NOT NULL").fetchall()
    sys_counts: dict[str, int] = {}
    import json as _json
    for (smj,) in all_docs:
        for s in _json.loads(smj):
            sys_counts[s] = sys_counts.get(s, 0) + 1
    for s, c in sorted(sys_counts.items(), key=lambda x: -x[1]):
        print(f"  {s:<15}: {c:>3} minutas")

    db.close()
    print()
    print(f"bank-brain.db listo en: {OUT_DB}")


if __name__ == "__main__":
    build()

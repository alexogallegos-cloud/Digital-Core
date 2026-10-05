"""
build-axa-brain.py
Pipeline principal del Digital Brain AXA México.

Crea axa-brain.db con todas las tablas base, registra los 16 sistemas
y adjunta (ATTACH) los system brains individuales cuando existen.

Uso:
    python build-axa-brain.py           # construye / reconstruye el brain
    python build-axa-brain.py --status  # muestra estado sin reconstruir
"""

import sqlite3
import os
import sys
import json
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH  = os.path.join(BASE_DIR, "axa-brain.db")
SYSTEMS_ROOT = os.path.join(os.path.dirname(BASE_DIR), "systems")

VERSION = "1.0.0"
BUILT_AT = datetime.now().strftime("%Y-%m-%d %H:%M")

# ──────────────────────────────────────────────
# Registro canónico de sistemas
# Fuente: CLAUDE.md AXA v1.1 + Competitive Discovery Suscripción Daños
# ──────────────────────────────────────────────
SYSTEMS = [
    # slug, display_name, real_name, category, togaf_type, lob, status, note
    ("policy-admin",     "Policy Admin",          "General Daños",   "core",        "core",        "P&C Daños",            "confirmed-name", "Sistema de emisión de pólizas de daños"),
    ("claims",           "Claims",                "Por confirmar",   "core",        "core",        "P&C Daños",            "scaffold",       "Gestión de siniestros"),
    ("billing",          "Billing",               "Por confirmar",   "core",        "core",        "P&C Daños",            "scaffold",       "Facturación y cobranza de primas"),
    ("underwriting-engine","Underwriting Engine", "Vector + HSD",    "processors",  "processors",  "P&C Daños",            "confirmed-name", "Vector: workflow de suscripción. HSD: Excel de cálculo técnico (gap crítico)"),
    ("reinsurance",      "Reinsurance",           "SAFAC",           "processors",  "processors",  "P&C Daños",            "confirmed-name", "Sistema de Reaseguro Facultativo"),
    ("actuarial",        "Actuarial",             "ERN + Por conf.", "processors",  "processors",  "P&C Daños",            "partial",        "ERN: modelación catastrófica. Reservas/pricing: por confirmar"),
    ("portal-agentes",   "Portal Agentes",        "Por confirmar",   "channels",    "channels",    "P&C Daños",            "scaffold",       "Portal web para agentes, corredores y conductos"),
    ("crm",              "CRM / Cuentas",         "SINCO",           "channels",    "channels",    "P&C Daños",            "confirmed-name", "Base de datos de cuentas, antecedentes y conductos"),
    ("digital",          "Digital",               "Por confirmar",   "channels",    "channels",    "P&C Daños",            "scaffold",       "Canales digitales, web y app móvil"),
    ("api-gateway",      "API Gateway",           "Por confirmar",   "integration", "integration", "P&C Daños",            "scaffold",       "API Gateway y exposición de capacidades"),
    ("event-bus",        "Event Bus",             "Por confirmar",   "integration", "integration", "P&C Daños",            "scaffold",       "Bus de eventos y mensajería async"),
    ("datawarehouse",    "Datawarehouse",         "Por confirmar",   "data",        "data",        "P&C Daños",            "scaffold",       "Datawarehouse corporativo"),
    ("analytics",        "Analytics / BI",        "Power BI",        "data",        "data",        "P&C Daños",            "confirmed-name", "Analytics, BI y reportes de gestión; siniestralidad histórica"),
    ("reporting-cnsf",   "Reporting CNSF",        "Monitor (tent.)", "data",        "data",        "Regulatorio",          "partial",        "Reportes CNSF, Solvencia C, IFRS 17. Monitor como probable herramienta"),
    ("cnsf",             "CNSF Compliance",       "Por confirmar",   "compliance",  "compliance",  "Regulatorio",          "scaffold",       "Cumplimiento CNSF, notas técnicas, reportes periódicos"),
    ("solvency",         "Solvency C",            "Por confirmar",   "compliance",  "compliance",  "Regulatorio",          "scaffold",       "Solvencia C, reservas técnicas, capital mínimo garantizado"),
]


# ──────────────────────────────────────────────
# DDL — tablas base del brain federado
# ──────────────────────────────────────────────
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
    lob             TEXT,
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
    cnsf_term       TEXT,
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
    lob             TEXT,
    proceso_l1      TEXT,
    fase_l2         TEXT,
    etapa_l3        TEXT,
    paso_l4         TEXT,
    sistemas_raw    TEXT,
    sistemas_slugs  TEXT,
    roles           TEXT,
    documentos      TEXT,
    regla_negocio   TEXT,
    tiempos         TEXT,
    etb_capability  TEXT
);

CREATE TABLE IF NOT EXISTS pain_points (
    id                  TEXT PRIMARY KEY,
    cat_c1              TEXT,
    cat_c2              TEXT,
    descripcion         TEXT,
    lob_suscripcion     INTEGER DEFAULT 0,
    lob_reasfac         INTEGER DEFAULT 0,
    lob_emision         INTEGER DEFAULT 0,
    lob_property        INTEGER DEFAULT 0,
    lob_ramos_tecnicos  INTEGER DEFAULT 0,
    lob_rc              INTEGER DEFAULT 0,
    lob_maritimo        INTEGER DEFAULT 0,
    lob_aviacion        INTEGER DEFAULT 0,
    lob_obras_arte      INTEGER DEFAULT 0,
    lob_lineas_fin      INTEGER DEFAULT 0,
    manualidad          INTEGER DEFAULT 0,
    causa_proceso       TEXT,
    mejora_proceso      TEXT,
    patron_proceso      TEXT,
    causa_tecnologia    TEXT,
    mejora_tecnologia   TEXT,
    patron_tecnologia   TEXT,
    causa_negocio       TEXT,
    mejora_negocio      TEXT,
    patron_negocio      TEXT,
    causa_datos         TEXT,
    mejora_datos        TEXT,
    patron_datos        TEXT,
    causa_org           TEXT,
    mejora_org          TEXT,
    patron_org          TEXT
);

CREATE TABLE IF NOT EXISTS cross_dependencies (
    id              TEXT PRIMARY KEY,
    system_a        TEXT,
    system_b        TEXT,
    dependency_type TEXT,
    direction       TEXT,
    evidence        TEXT,
    criticality     TEXT DEFAULT 'medium'
);
"""


def create_db(conn: sqlite3.Connection):
    conn.executescript(DDL)
    conn.commit()
    print("[OK] Tablas base creadas / verificadas.")


def set_meta(conn: sqlite3.Connection):
    meta = [
        ("version",      VERSION),
        ("built_at",     BUILT_AT),
        ("client",       "AXA Seguros S.A. de C.V."),
        ("scope",        "P&C Commercial Lines — AXA Seguros (no AXA Partners, no AXA XL, no AXA Salud)"),
        ("regulator",    "CNSF"),
        ("etb_ref",      "Insurance P&C Commercial Lines v3.0"),
        ("systems_count", str(len(SYSTEMS))),
        ("source_excel", "2608_Suscripción_Entregable_Anexo Competitive Discovery Suscripción Daños.xlsx"),
    ]
    conn.executemany(
        "INSERT OR REPLACE INTO brain_meta (key, value) VALUES (?,?)", meta
    )
    conn.commit()


def register_systems(conn: sqlite3.Connection):
    registered = 0
    for s in SYSTEMS:
        slug = s[0]
        brain_path = os.path.join(SYSTEMS_ROOT, s[3], slug, "digital-brain", "brain.db")
        brain_path_rel = os.path.relpath(brain_path, BASE_DIR)
        conn.execute("""
            INSERT OR REPLACE INTO systems
              (slug, display_name, real_name, category, togaf_type,
               lob, status, note, brain_path, brain_attached)
            VALUES (?,?,?,?,?,?,?,?,?,0)
        """, (*s, brain_path_rel))
        registered += 1
    conn.commit()
    print(f"[OK] {registered} sistemas registrados.")


def attach_system_brains(conn: sqlite3.Connection):
    attached = 0
    missing  = 0
    rows = conn.execute("SELECT slug, brain_path FROM systems").fetchall()
    for slug, brain_path_rel in rows:
        brain_path = os.path.join(BASE_DIR, brain_path_rel)
        if os.path.exists(brain_path):
            try:
                alias = slug.replace("-", "_")
                conn.execute(f"ATTACH DATABASE '{brain_path}' AS {alias}")
                conn.execute("UPDATE systems SET brain_attached=1 WHERE slug=?", (slug,))
                attached += 1
                print(f"  [ATTACH] {slug} → {alias}")
            except Exception as e:
                print(f"  [WARN]   {slug}: {e}")
        else:
            missing += 1

    conn.commit()
    if attached:
        print(f"[OK] {attached} system brains adjuntados.")
    if missing:
        print(f"[INFO] {missing} sistemas sin brain.db aún (scaffold) — se agregarán cuando se cargue el código fuente.")


def print_status(conn: sqlite3.Connection):
    print("\n" + "═" * 56)
    print("  AXA DIGITAL BRAIN — STATUS")
    print("═" * 56)

    meta = dict(conn.execute("SELECT key, value FROM brain_meta").fetchall())
    print(f"  Versión     : {meta.get('version','?')}")
    print(f"  Construido  : {meta.get('built_at','?')}")
    print(f"  Cliente     : {meta.get('client','?')}")
    print(f"  Scope       : {meta.get('scope','?')}")
    print()

    rows = conn.execute("""
        SELECT category, COUNT(*) total,
               SUM(brain_attached) attached
        FROM systems
        GROUP BY category
        ORDER BY category
    """).fetchall()
    print(f"  {'Categoría':<16} {'Sistemas':>8} {'Brains activos':>14}")
    print(f"  {'-'*16} {'-'*8} {'-'*14}")
    for cat, total, att in rows:
        bar = "●" * (att or 0) + "○" * (total - (att or 0))
        print(f"  {cat:<16} {total:>8}   {bar}")

    counts = {
        "process_steps":  conn.execute("SELECT COUNT(*) FROM process_steps").fetchone()[0],
        "pain_points":    conn.execute("SELECT COUNT(*) FROM pain_points").fetchone()[0],
        "vocab":          conn.execute("SELECT COUNT(*) FROM vocab").fetchone()[0],
        "etb_capabilities": conn.execute("SELECT COUNT(*) FROM etb_capabilities").fetchone()[0],
        "market_intel":   conn.execute("SELECT COUNT(*) FROM market_intel").fetchone()[0],
    }
    print()
    print(f"  {'Tabla':<22} {'Registros':>10}")
    print(f"  {'-'*22} {'-'*10}")
    for table, n in counts.items():
        status = "✓" if n > 0 else "○ vacío"
        print(f"  {table:<22} {n:>6}   {status}")
    print("═" * 56)


def main():
    mode_status = "--status" in sys.argv

    if mode_status and os.path.exists(DB_PATH):
        conn = sqlite3.connect(DB_PATH)
        print_status(conn)
        conn.close()
        return

    print(f"[BUILD] axa-brain.db v{VERSION} — {BUILT_AT}")
    print(f"[PATH]  {DB_PATH}")

    conn = sqlite3.connect(DB_PATH)
    create_db(conn)
    set_meta(conn)
    register_systems(conn)
    attach_system_brains(conn)
    print_status(conn)
    conn.close()

    print(f"\n[NEXT] Ejecuta los generadores para poblar el brain:")
    print(f"  python generators/extract-strategic.py   # ETB capabilities")
    print(f"  python generators/build-vocab-v1.py      # Rosetta Stone vocab")
    print(f"  python generators/load-process-steps.py  # Proceso suscripción")
    print(f"  python generators/load-pain-points.py    # Pain points")
    print(f"  python generators/seed-market-intel.py   # Inteligencia de mercado")


if __name__ == "__main__":
    main()
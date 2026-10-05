"""
build-brain.py — Construye brain.db para golden-record-target
MONEX Grupo Financiero — Digital Brain
NOTE: Sistema TO-BE — brain contiene diseño target, no AS-IS.
"""
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"
SYSTEM = "golden-record-target"
DISPLAY_NAME = "Golden Record (TO-BE)"
TOGAF_TYPE = "data"
DESCRIPTION = "MDM centralizado — primera vez que MONEX tendrá data model canónico"


def build():
    print(f"Building {BRAIN_DB}...")
    if BRAIN_DB.exists():
        BRAIN_DB.unlink()

    conn = sqlite3.connect(BRAIN_DB)
    conn.executescript("""
        CREATE TABLE system_info (
            slug TEXT PRIMARY KEY, display_name TEXT, togaf_type TEXT,
            togaf_state TEXT, status TEXT, description TEXT,
            seeded_by TEXT, seeded_at TEXT
        );
        CREATE TABLE components (
            id TEXT PRIMARY KEY, name TEXT, description TEXT,
            domain TEXT, type TEXT, maturity TEXT DEFAULT 'MAÑANA'
        );
        CREATE TABLE rules (
            rule_id TEXT PRIMARY KEY, component_id TEXT,
            description TEXT, domain TEXT, regulation TEXT
        );
        CREATE TABLE cross_dependencies (
            id TEXT PRIMARY KEY, other_system TEXT, relationship TEXT,
            direction TEXT, description TEXT, criticality TEXT
        );
        CREATE TABLE master_data_domains (
            domain_name TEXT PRIMARY KEY, description TEXT,
            sources_today TEXT, target_owner TEXT, priority TEXT
        );
    """)

    conn.execute(
        "INSERT INTO system_info VALUES (?,?,?,?,?,?,?,?)",
        (SYSTEM, DISPLAY_NAME, TOGAF_TYPE, "target", "TARGET",
         DESCRIPTION, None, "2026-09-22")
    )

    # Seed master data domains
    mdm_domains = [
        ("cliente",     "Datos del cliente MONEX (persona física o moral)", "portal-clientes, payments-legacy, fx-engine", "golden-record-target", "Alta"),
        ("contraparte", "Bancos corresponsales, brokers, instituciones financieras", "fx-engine, treasury", "golden-record-target", "Alta"),
        ("instrumento", "Divisas, pares FX, instrumentos derivados", "fx-engine", "golden-record-target", "Media"),
        ("cuenta",      "Cuentas bancarias propias y de clientes", "payments-legacy, spei", "golden-record-target", "Alta"),
    ]
    for d in mdm_domains:
        conn.execute(
            "INSERT INTO master_data_domains VALUES (?,?,?,?,?)", d
        )

    conn.commit()
    conn.close()
    print(f"  Brain scaffold created for {SYSTEM} ({DISPLAY_NAME})")
    print(f"  MDM domains seeded: {len(mdm_domains)}")
    print("  Status: TARGET — sistema a construir en Apolo Iniciativa 3")


if __name__ == "__main__":
    build()

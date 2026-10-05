"""
build-brain.py — Construye brain.db para mulesoft
MONEX Grupo Financiero — Digital Brain
"""
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"
SYSTEM = "mulesoft"
DISPLAY_NAME = "MuleSoft Anypoint"
TOGAF_TYPE = "integration"
DESCRIPTION = "API Gateway Anypoint — backbone de integración MONEX"


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
            domain TEXT, type TEXT, maturity TEXT DEFAULT 'HOY'
        );
        CREATE TABLE rules (
            rule_id TEXT PRIMARY KEY, component_id TEXT,
            description TEXT, domain TEXT, regulation TEXT
        );
        CREATE TABLE cross_dependencies (
            id TEXT PRIMARY KEY, other_system TEXT, relationship TEXT,
            direction TEXT, description TEXT, criticality TEXT
        );
    """)

    conn.execute(
        "INSERT INTO system_info VALUES (?,?,?,?,?,?,?,?)",
        (SYSTEM, DISPLAY_NAME, TOGAF_TYPE, "baseline", "CONFIRMED",
         DESCRIPTION, None, "2026-09-22")
    )

    conn.commit()
    conn.close()
    print(f"  Brain scaffold created for {SYSTEM} ({DISPLAY_NAME})")
    print("  Status: CONFIRMED — backbone de integración verificado en Q&A Plan Apolo")


if __name__ == "__main__":
    build()

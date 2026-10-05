"""
build-brain.py — Construye brain.db para dora
MONEX Grupo Financiero — Digital Brain
"""
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"
SYSTEM = "dora"
DISPLAY_NAME = "DORA Compliance"
TOGAF_TYPE = "compliance"
DESCRIPTION = "Digital Operational Resilience Act — operaciones UK/EU"


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
        CREATE TABLE dora_pillars (
            pillar_id TEXT PRIMARY KEY, name TEXT,
            description TEXT, status_monex TEXT, gap TEXT
        );
    """)

    conn.execute(
        "INSERT INTO system_info VALUES (?,?,?,?,?,?,?,?)",
        (SYSTEM, DISPLAY_NAME, TOGAF_TYPE, "baseline", "SCAFFOLD",
         DESCRIPTION, None, "2026-09-22")
    )

    # Seed DORA pillars
    pillars = [
        ("P1", "ICT Risk Management",            "Marco de gestión de riesgo TI",                              "DATO-REQUERIDO", "Self-assessment pendiente"),
        ("P2", "Incident Reporting",              "Reporte de incidentes ICT significativos a FCA",             "DATO-REQUERIDO", "Proceso actual desconocido"),
        ("P3", "Digital Operational Resilience Testing", "Pruebas TLPT obligatorias",                          "DATO-REQUERIDO", "TLPT no realizado confirmado"),
        ("P4", "Third-party Risk Management",     "Gestión de riesgo de proveedores TI críticos (MuleSoft, SWIFT, etc.)", "DATO-REQUERIDO", "Inventario de proveedores críticos pendiente"),
        ("P5", "Information Sharing",             "Intercambio de información de amenazas con el sector",      "DATO-REQUERIDO", "Participación en ISACs por confirmar"),
    ]
    for p in pillars:
        conn.execute("INSERT INTO dora_pillars VALUES (?,?,?,?,?)", p)

    conn.commit()
    conn.close()
    print(f"  Brain scaffold created for {SYSTEM} ({DISPLAY_NAME})")
    print(f"  DORA pillars seeded: {len(pillars)}")
    print("  Status: SCAFFOLD — DORA aplica desde ene-2025; evaluación pendiente")


if __name__ == "__main__":
    build()

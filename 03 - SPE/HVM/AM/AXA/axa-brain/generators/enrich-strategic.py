"""
enrich-strategic.py — Enriquece componentes en axa-brain.db con perspectiva ETB.
Para cada componente registrado, asigna el dominio ETB L1 que corresponde
según el sistema de origen y la tabla de cobertura en etb-capabilities-pc.json.

Ejecutar desde: AXA/axa-brain/
    python generators/enrich-strategic.py
"""
import json
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent.parent / "axa-brain.db"
ETB_JSON = Path(__file__).parent.parent / "knowledge-base" / "etb" / "etb-capabilities-pc.json"


SYSTEM_TO_L1 = {
    "portal-agentes":      ["D1", "D2", "D4"],
    "crm":                 ["D2", "D3", "D4", "D5"],
    "digital":             ["D1", "D5", "D11"],
    "policy-admin":        ["D6"],
    "claims":              ["D6"],
    "billing":             ["D6"],
    "underwriting-engine": ["D6", "D11"],
    "reinsurance":         ["D6"],
    "actuarial":           ["D6", "D10"],
    "api-gateway":         ["D8"],
    "event-bus":           ["D8"],
    "datawarehouse":       ["D9", "D10"],
    "analytics":           ["D10", "D11"],
    "reporting-cnsf":      ["D7"],
    "cnsf":                ["D7"],
    "solvency":            ["D7"],
}

L1_LABELS = {
    "D1": "Channel Mgmt.",
    "D2": "Distribution Mgmt.",
    "D3": "Marketing Mgmt.",
    "D4": "Sales Mgmt.",
    "D5": "Service Mgmt.",
    "D6": "Product & Operations",
    "D7": "Enterprise Functions",
    "D8": "Business Integration",
    "D9": "Information Foundation",
    "D10": "Business Insights & Analytics",
    "D11": "Artificial Intelligence",
}


def add_etb_columns(conn: sqlite3.Connection) -> None:
    cols = {row[1] for row in conn.execute("PRAGMA table_info(components)")}
    if "etb_domain_l1" not in cols:
        conn.execute("ALTER TABLE components ADD COLUMN etb_domain_l1 TEXT")
    if "etb_domain_label" not in cols:
        conn.execute("ALTER TABLE components ADD COLUMN etb_domain_label TEXT")
    conn.commit()


def enrich(conn: sqlite3.Connection) -> dict[str, int]:
    stats: dict[str, int] = {}
    for system, l1_list in SYSTEM_TO_L1.items():
        l1_ids = json.dumps(l1_list)
        l1_labels = json.dumps([L1_LABELS[d] for d in l1_list])
        result = conn.execute("""
            UPDATE components
            SET etb_domain_l1    = ?,
                etb_domain_label = ?
            WHERE system = ?
        """, (l1_ids, l1_labels, system))
        stats[system] = result.rowcount
    conn.commit()
    return stats


def report(stats: dict[str, int]) -> None:
    total = sum(stats.values())
    print(f"\nEnriquecimiento ETB completado — {total} componentes actualizados")
    print(f"{'Sistema':<25} {'Componentes':>12}")
    print("-" * 38)
    for system, count in sorted(stats.items()):
        print(f"  {system:<23} {count:>12}")


def main() -> None:
    if not BRAIN_DB.exists():
        print("axa-brain.db not found. Run build-axa-brain.py first.")
        return

    conn = sqlite3.connect(BRAIN_DB)

    cols = {row[1] for row in conn.execute("PRAGMA table_info(components)")}
    if "component_name" not in cols and "name" not in cols:
        print("Tabla 'components' no tiene estructura esperada. Ejecuta build-axa-brain.py primero.")
        conn.close()
        return

    add_etb_columns(conn)
    stats = enrich(conn)
    conn.close()
    report(stats)


if __name__ == "__main__":
    main()
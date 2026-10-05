"""
extract-strategic.py — Extrae capacidades ETB P&C e inserta en axa-brain.db
como componentes de tipo 'capability' con maturity='HOY' (estado actual del blueprint).

Las capacidades ETB son la referencia de LO QUE DEBERÍA existir;
contrastarlas con los componentes reales de cada system brain revela gaps.

Ejecutar desde: AXA/axa-brain/
    python generators/extract-strategic.py
"""
import json
import sqlite3
from pathlib import Path

BRAIN_DB  = Path(__file__).parent.parent / "axa-brain.db"
ETB_JSON  = Path(__file__).parent.parent / "knowledge-base" / "etb" / "etb-capabilities-pc.json"


def ensure_etb_table(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        DROP TABLE IF EXISTS etb_capabilities;
        CREATE TABLE etb_capabilities (
            id          INTEGER PRIMARY KEY,
            cap_id      TEXT UNIQUE,
            domain_l1   TEXT,
            domain_l2   TEXT,
            name        TEXT,
            systems     TEXT,
            priority    TEXT,
            note        TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_etb_domain ON etb_capabilities(domain_l1);
        CREATE INDEX IF NOT EXISTS idx_etb_cap    ON etb_capabilities(cap_id);
    """)
    conn.commit()


def insert_l1_domains(conn: sqlite3.Connection, domains: dict) -> int:
    count = 0
    for d_id, domain in domains.items():
        l1_name = domain["name"]
        systems = json.dumps(domain.get("axa_systems", []))
        l2 = domain.get("l2", {})
        for l2_id, l2_data in l2.items():
            l2_name = l2_data.get("name", "")
            l2_systems = json.dumps(l2_data.get("axa_systems", domain.get("axa_systems", [])))
            l3_list = l2_data.get("l3", [])
            if l3_list:
                for l3_id in l3_list:
                    conn.execute("""
                        INSERT INTO etb_capabilities (cap_id, domain_l1, domain_l2, name, systems, priority, note)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                        ON CONFLICT(cap_id) DO UPDATE SET
                            domain_l1 = excluded.domain_l1,
                            domain_l2 = excluded.domain_l2,
                            name      = excluded.name,
                            systems   = excluded.systems
                    """, (l3_id, l1_name, l2_name, f"{l2_name} — L3:{l3_id}", l2_systems, None, None))
                    count += 1
            else:
                conn.execute("""
                    INSERT INTO etb_capabilities (cap_id, domain_l1, domain_l2, name, systems, priority, note)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    ON CONFLICT(cap_id) DO UPDATE SET
                        domain_l1 = excluded.domain_l1,
                        domain_l2 = excluded.domain_l2,
                        name      = excluded.name,
                        systems   = excluded.systems
                """, (l2_id, l1_name, l2_name, l2_name, l2_systems, None, None))
                count += 1
    return count


def insert_l3_catalog(conn: sqlite3.Connection, catalog: dict) -> int:
    count = 0
    for cap_id, cap in catalog.items():
        conn.execute("""
            UPDATE etb_capabilities
            SET name     = ?,
                systems  = ?,
                priority = ?,
                note     = ?
            WHERE cap_id = ?
        """, (
            cap.get("name"),
            json.dumps([cap.get("system")] if cap.get("system") else []),
            cap.get("priority"),
            cap.get("note"),
            cap_id,
        ))
        if conn.execute("SELECT changes()").fetchone()[0] == 0:
            conn.execute("""
                INSERT OR IGNORE INTO etb_capabilities (cap_id, name, systems, priority, note)
                VALUES (?, ?, ?, ?, ?)
            """, (
                cap_id,
                cap.get("name"),
                json.dumps([cap.get("system")] if cap.get("system") else []),
                cap.get("priority"),
                cap.get("note"),
            ))
        count += 1
    return count


def main() -> None:
    if not BRAIN_DB.exists():
        print("axa-brain.db not found. Run build-axa-brain.py first.")
        return
    if not ETB_JSON.exists():
        print(f"ETB JSON not found: {ETB_JSON}")
        return

    data = json.loads(ETB_JSON.read_text(encoding="utf-8"))
    conn = sqlite3.connect(BRAIN_DB)
    ensure_etb_table(conn)

    n_l2 = insert_l1_domains(conn, data.get("domains", {}))
    n_l3 = insert_l3_catalog(conn, data.get("l3_catalog", {}))
    conn.commit()
    conn.close()

    print(f"ETB P&C extraído al brain:")
    print(f"  L2 capabilities insertadas : {n_l2}")
    print(f"  L3 catalog enriquecido     : {n_l3}")
    print(f"  Base de datos              : {BRAIN_DB.name}")


if __name__ == "__main__":
    main()
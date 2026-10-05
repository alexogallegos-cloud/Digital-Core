"""
build-brain.py — Digital Brain Builder: claims
State: SCAFFOLD — add extraction logic after source access.
Run: python build-brain.py
"""
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"


def init_schema(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS components (
            id          INTEGER PRIMARY KEY,
            domain      TEXT,
            name        TEXT,
            type        TEXT,
            description TEXT,
            maturity    TEXT DEFAULT 'HOY'
        );
        CREATE INDEX IF NOT EXISTS idx_comp_name   ON components(name);
        CREATE INDEX IF NOT EXISTS idx_comp_domain ON components(domain);
    """)
    conn.commit()


def build() -> None:
    system = Path(__file__).parent.parent.name
    print(f"Building brain.db for: {system}")
    conn = sqlite3.connect(BRAIN_DB)
    init_schema(conn)
    conn.close()
    print(f"Schema initialized → {BRAIN_DB}")
    print("TODO: add extraction logic after source access.")


if __name__ == "__main__":
    build()
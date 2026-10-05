"""
build-vocab-v1.py — Carga el vocabulario Rosetta Stone AXA al axa-brain.db.
Lee vocab-axa-v1.json e inserta/actualiza la tabla vocab en axa-brain.db.

Ejecutar desde: AXA/axa-brain/
    python generators/build-vocab-v1.py
"""
import json
import sqlite3
from pathlib import Path

BRAIN_DB = Path(__file__).parent.parent / "axa-brain.db"
VOCAB_FILE = Path(__file__).parent.parent / "knowledge-base" / "vocab" / "vocab-axa-v1.json"


def ensure_table(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS vocab (
            id          INTEGER PRIMARY KEY,
            term        TEXT UNIQUE,
            domain      TEXT,
            scope       TEXT DEFAULT 'enterprise',
            en          TEXT,
            etb_cap     TEXT,
            cnsf_term   TEXT,
            systems_json TEXT
        );
        CREATE INDEX IF NOT EXISTS idx_vocab_term   ON vocab(term);
        CREATE INDEX IF NOT EXISTS idx_vocab_domain ON vocab(domain);
        CREATE INDEX IF NOT EXISTS idx_vocab_en     ON vocab(en);
    """)
    conn.commit()


def load_vocab(conn: sqlite3.Connection, vocab_path: Path) -> int:
    data = json.loads(vocab_path.read_text(encoding="utf-8"))
    terms = data.get("terms", [])
    loaded = 0
    for t in terms:
        conn.execute("""
            INSERT INTO vocab (term, domain, scope, en, etb_cap, cnsf_term, systems_json)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(term) DO UPDATE SET
                domain       = excluded.domain,
                scope        = excluded.scope,
                en           = excluded.en,
                etb_cap      = excluded.etb_cap,
                cnsf_term    = excluded.cnsf_term,
                systems_json = excluded.systems_json
        """, (
            t.get("term"),
            t.get("domain"),
            t.get("scope", "enterprise"),
            t.get("en"),
            t.get("etb_capability"),
            t.get("cnsf_term"),
            json.dumps(t.get("systems", {}), ensure_ascii=False),
        ))
        loaded += 1
    conn.commit()
    return loaded


def main() -> None:
    if not BRAIN_DB.exists():
        print("axa-brain.db not found. Run build-axa-brain.py first.")
        return
    if not VOCAB_FILE.exists():
        print(f"Vocab file not found: {VOCAB_FILE}")
        return

    conn = sqlite3.connect(BRAIN_DB)
    ensure_table(conn)
    n = load_vocab(conn, VOCAB_FILE)
    conn.close()

    print(f"Rosetta Stone cargado: {n} términos → {BRAIN_DB.name}")


if __name__ == "__main__":
    main()
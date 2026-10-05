"""
build-vocab-v1.py — Construye/actualiza vocab-monex-v1.json desde el brain.
Extrae términos del brain.db y los cruza/enriquece con el vocabulario canónico.

Usage:
    python build-vocab-v1.py
"""
import sqlite3
import json
from pathlib import Path

BRAIN_DB = Path(__file__).parent.parent / "monex-brain.db"
VOCAB_FILE = Path(__file__).parent.parent / "knowledge-base" / "vocab" / "vocab-monex-v1.json"


def export_vocab():
    if not BRAIN_DB.exists():
        print("monex-brain.db not found. Run build-monex-brain.py first.")
        return

    conn = sqlite3.connect(BRAIN_DB)
    conn.row_factory = sqlite3.Row

    rows = conn.execute(
        "SELECT term, domain, scope, en, description, systems_json FROM vocab ORDER BY domain, term"
    ).fetchall()

    terms = []
    for r in rows:
        entry = {
            "term": r["term"],
            "domain": r["domain"],
            "scope": r["scope"] or "enterprise",
            "en": r["en"],
            "description": r["description"],
        }
        if r["systems_json"]:
            entry["systems"] = json.loads(r["systems_json"])
        terms.append(entry)

    output = {
        "version": "1.0.0",
        "updated": "2026-09-22",
        "description": "Vocabulario empresarial canónico MONEX — Rosetta Stone cross-sistema",
        "terms": terms,
    }

    VOCAB_FILE.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Exported {len(terms)} terms to {VOCAB_FILE}")
    conn.close()


if __name__ == "__main__":
    export_vocab()

"""
monex-brain.py — GemCogBrain API: MONEX Grupo Financiero Digital Brain (Federated)
Aggregates all system-level brains for cross-system queries.

Usage:
    python monex-brain.py "FX"          # query across all systems
    python monex-brain.py systems        # list registered systems
    python monex-brain.py dt             # list digital twins
    python monex-brain.py vocab "pago"  # vocabulary lookup
"""
import sqlite3
import sys
import json
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "monex-brain.db"


class MONEXBrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError(
                "monex-brain.db not found. Run: python build-monex-brain.py"
            )
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    def query(self, q: str, limit: int = 30) -> list:
        cur = self.conn.execute(
            """
            SELECT * FROM components
            WHERE name LIKE ? OR description LIKE ? OR domain LIKE ?
            ORDER BY system, domain, name
            LIMIT ?
            """,
            (f"%{q}%", f"%{q}%", f"%{q}%", limit),
        )
        return [dict(r) for r in cur.fetchall()]

    def systems(self) -> list:
        cur = self.conn.execute(
            """
            SELECT s.system, s.category, s.togaf_type, s.status,
                   COUNT(c.id) as component_count
            FROM systems s
            LEFT JOIN components c ON s.system = c.system
            GROUP BY s.system
            ORDER BY s.category, s.system
            """
        )
        return [dict(r) for r in cur.fetchall()]

    def by_domain(self, domain: str) -> list:
        cur = self.conn.execute(
            "SELECT * FROM components WHERE domain LIKE ? ORDER BY system, name",
            (f"%{domain}%",),
        )
        return [dict(r) for r in cur.fetchall()]

    def vocab(self, term: str) -> list:
        cur = self.conn.execute(
            """
            SELECT * FROM vocab
            WHERE term LIKE ? OR en LIKE ? OR description LIKE ?
            ORDER BY domain, term
            LIMIT 10
            """,
            (f"%{term}%", f"%{term}%", f"%{term}%"),
        )
        return [dict(r) for r in cur.fetchall()]

    def digital_twins(self) -> list:
        cur = self.conn.execute(
            "SELECT * FROM digital_twins ORDER BY name"
        )
        return [dict(r) for r in cur.fetchall()]

    def owl_query(self, q: str) -> list:
        """Query OWL ontology concepts."""
        cur = self.conn.execute(
            """
            SELECT * FROM owl_concepts
            WHERE concept LIKE ? OR description LIKE ? OR axiom LIKE ?
            ORDER BY domain, concept
            LIMIT 20
            """,
            (f"%{q}%", f"%{q}%", f"%{q}%"),
        )
        return [dict(r) for r in cur.fetchall()]


def main():
    brain = MONEXBrain()
    args = sys.argv[1:]

    if not args or args[0] == "systems":
        result = brain.systems()
    elif args[0] == "dt":
        result = brain.digital_twins()
    elif args[0] == "domain" and len(args) > 1:
        result = brain.by_domain(" ".join(args[1:]))
    elif args[0] == "vocab" and len(args) > 1:
        result = brain.vocab(" ".join(args[1:]))
    elif args[0] == "owl" and len(args) > 1:
        result = brain.owl_query(" ".join(args[1:]))
    else:
        result = brain.query(" ".join(args))

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

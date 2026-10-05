"""
axa-brain.py — GemCogBrain API: AXA México Digital Brain (Federated)
Aggregates all system-level brains for cross-system queries.

Usage:
    python axa-brain.py "prima neta"   # query across all systems
    python axa-brain.py systems        # list registered systems
    python axa-brain.py dt             # list digital twins
"""
import sqlite3
import sys
import json
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "axa-brain.db"


class AXABrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError(
                "axa-brain.db not found. Run: python build-axa-brain.py"
            )
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    def query(self, q: str, limit: int = 30) -> list[dict]:
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

    def systems(self) -> list[dict]:
        cur = self.conn.execute(
            """
            SELECT system, category, maturity, COUNT(*) as component_count
            FROM systems
            LEFT JOIN components USING(system)
            GROUP BY system
            ORDER BY category, system
            """
        )
        return [dict(r) for r in cur.fetchall()]

    def by_domain(self, domain: str) -> list[dict]:
        cur = self.conn.execute(
            "SELECT * FROM components WHERE domain LIKE ? ORDER BY system, name",
            (f"%{domain}%",),
        )
        return [dict(r) for r in cur.fetchall()]

    def vocab(self, term: str) -> list[dict]:
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


def main():
    brain = AXABrain()
    args = sys.argv[1:]

    if not args or args[0] == "systems":
        result = brain.systems()
    elif args[0] == "domain" and len(args) > 1:
        result = brain.by_domain(" ".join(args[1:]))
    elif args[0] == "vocab" and len(args) > 1:
        result = brain.vocab(" ".join(args[1:]))
    else:
        result = brain.query(" ".join(args))

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
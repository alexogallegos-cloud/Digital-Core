"""
brain.py — MuleSoft Anypoint Brain API
Sistema: mulesoft
MONEX Grupo Financiero — Digital Brain
"""
import sqlite3
import sys
import json
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"
SYSTEM = "mulesoft"


class MulesoftBrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError(
                f"brain.db not found for {SYSTEM}. Run: python build-brain.py"
            )
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    def coverage(self) -> dict:
        try:
            n = self.conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
            nd = self.conn.execute("SELECT COUNT(DISTINCT domain) FROM components").fetchone()[0]
            return {"system": SYSTEM, "components": n, "domains": nd}
        except Exception:
            return {"system": SYSTEM, "components": 0, "domains": 0, "status": "empty"}

    def components(self, domain: str = None, limit: int = 50) -> list:
        if domain:
            cur = self.conn.execute(
                "SELECT * FROM components WHERE domain LIKE ? ORDER BY name LIMIT ?",
                (f"%{domain}%", limit)
            )
        else:
            cur = self.conn.execute(
                "SELECT * FROM components ORDER BY domain, name LIMIT ?", (limit,)
            )
        return [dict(r) for r in cur.fetchall()]

    def search(self, query: str, limit: int = 20) -> list:
        cur = self.conn.execute(
            "SELECT * FROM components WHERE name LIKE ? OR description LIKE ? LIMIT ?",
            (f"%{query}%", f"%{query}%", limit)
        )
        return [dict(r) for r in cur.fetchall()]

    def domains(self) -> list:
        cur = self.conn.execute(
            "SELECT domain, COUNT(*) as count FROM components GROUP BY domain ORDER BY domain"
        )
        return [dict(r) for r in cur.fetchall()]


def main():
    brain = MulesoftBrain()
    args = sys.argv[1:]
    if not args or args[0] == "coverage":
        result = brain.coverage()
    elif args[0] == "domains":
        result = brain.domains()
    elif args[0] == "domain" and len(args) > 1:
        result = brain.components(domain=" ".join(args[1:]))
    else:
        result = brain.search(" ".join(args))
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

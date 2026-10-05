"""
brain.py — Digital Brain: digital
State: SCAFFOLD — populate after source extraction.
Run: python brain.py "term"
"""
import sqlite3, sys, json
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"


class SystemBrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError("brain.db not found. Run: python build-brain.py")
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    def query(self, q: str, limit: int = 20) -> list[dict]:
        cur = self.conn.execute(
            "SELECT * FROM components WHERE name LIKE ? OR description LIKE ? LIMIT ?",
            (f"%{q}%", f"%{q}%", limit),
        )
        return [dict(r) for r in cur.fetchall()]

    def domains(self) -> list[dict]:
        cur = self.conn.execute(
            "SELECT DISTINCT domain, COUNT(*) as count FROM components GROUP BY domain ORDER BY domain"
        )
        return [dict(r) for r in cur.fetchall()]


if __name__ == "__main__":
    brain = SystemBrain()
    args = sys.argv[1:]
    if not args or args[0] == "domains":
        result = brain.domains()
    else:
        result = brain.query(" ".join(args))
    print(json.dumps(result, ensure_ascii=False, indent=2))
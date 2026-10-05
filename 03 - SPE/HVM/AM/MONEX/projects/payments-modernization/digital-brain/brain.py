"""
brain.py — Payments Modernization Brain API
MONEX Grupo Financiero — RFP-PAG v2.6
"""
import sqlite3
import json
import sys
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "brain.db"


class PaymentsBrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError("brain.db not found. Run: python build-brain.py")
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    def coverage(self) -> dict:
        try:
            reqs = self.conn.execute("SELECT COUNT(*) FROM requirements").fetchone()[0]
            caps = self.conn.execute("SELECT COUNT(*) FROM pag_macrocapabilities").fetchone()[0]
            principles = self.conn.execute("SELECT COUNT(*) FROM arch_principles").fetchone()[0]
            ai_reqs = self.conn.execute("SELECT COUNT(*) FROM ai_requirements").fetchone()[0]
            geos = self.conn.execute("SELECT COUNT(*) FROM geographies").fetchone()[0]
            milestones = self.conn.execute("SELECT COUNT(*) FROM timeline").fetchone()[0]
            next_milestone = self.conn.execute(
                "SELECT milestone, date FROM timeline WHERE status='PENDING' ORDER BY date LIMIT 1"
            ).fetchone()
            return {
                "project": "payments-modernization",
                "rfp": "RFP-PAG v2.6",
                "requirements": reqs,
                "pag_macrocapabilities": caps,
                "arch_principles": principles,
                "ai_requirements": ai_reqs,
                "geographies": geos,
                "timeline_milestones": milestones,
                "next_milestone": dict(next_milestone) if next_milestone else None
            }
        except Exception as e:
            return {"project": "payments-modernization", "error": str(e)}

    def components(self, domain: str = None, limit: int = 50) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM pag_macrocapabilities ORDER BY code LIMIT ?", (limit,))
        return [dict(r) for r in cur.fetchall()]

    def search(self, query: str, limit: int = 20) -> list[dict]:
        results = []
        for table in ["requirements", "pag_macrocapabilities", "arch_principles", "ai_requirements"]:
            try:
                cur = self.conn.execute(
                    f"SELECT *, '{table}' as source_table FROM {table} WHERE "
                    f"description LIKE ? OR name LIKE ? LIMIT ?",
                    (f"%{query}%", f"%{query}%", limit)
                )
                results.extend([dict(r) for r in cur.fetchall()])
            except Exception:
                pass
        return results[:limit]

    def rules(self, component_id: str = None) -> list[dict]:
        if component_id:
            cur = self.conn.execute(
                "SELECT * FROM requirements WHERE capability_id = ? OR req_id LIKE ?",
                (component_id, f"%{component_id}%")
            )
        else:
            cur = self.conn.execute("SELECT * FROM requirements ORDER BY type, priority")
        return [dict(r) for r in cur.fetchall()]

    def domains(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM geographies ORDER BY priority")
        return [dict(r) for r in cur.fetchall()]

    def requirements(self, req_type: str = None) -> list[dict]:
        if req_type:
            cur = self.conn.execute(
                "SELECT * FROM requirements WHERE type = ? ORDER BY req_id", (req_type,)
            )
        else:
            cur = self.conn.execute("SELECT * FROM requirements ORDER BY type, req_id")
        return [dict(r) for r in cur.fetchall()]

    def candidates(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM candidates ORDER BY name")
        return [dict(r) for r in cur.fetchall()]

    def timeline(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM timeline ORDER BY date")
        return [dict(r) for r in cur.fetchall()]

    def macrocapabilities(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM pag_macrocapabilities ORDER BY code")
        return [dict(r) for r in cur.fetchall()]

    def ai_requirements(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM ai_requirements ORDER BY id")
        return [dict(r) for r in cur.fetchall()]

    def integrations(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM integrations ORDER BY priority, system")
        return [dict(r) for r in cur.fetchall()]

    def principles(self) -> list[dict]:
        cur = self.conn.execute("SELECT * FROM arch_principles ORDER BY id")
        return [dict(r) for r in cur.fetchall()]


def main():
    brain = PaymentsBrain()
    args = sys.argv[1:]
    if not args or args[0] == "coverage":
        result = brain.coverage()
    elif args[0] == "macrocaps":
        result = brain.macrocapabilities()
    elif args[0] == "req":
        result = brain.requirements(args[1] if len(args) > 1 else None)
    elif args[0] == "ai":
        result = brain.ai_requirements()
    elif args[0] == "timeline":
        result = brain.timeline()
    elif args[0] == "candidates":
        result = brain.candidates()
    elif args[0] == "integrations":
        result = brain.integrations()
    elif args[0] == "principles":
        result = brain.principles()
    else:
        result = brain.search(" ".join(args))
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

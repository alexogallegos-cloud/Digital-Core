"""
santander-brain.py — GemCogBrain API: Santander México Digital Brain (Federated)
Aggregates all system-level brains for cross-system queries.

Usage:
    python santander-brain.py "crédito"         # query across all systems
    python santander-brain.py systems            # list registered systems
    python santander-brain.py vocab "pago"       # search vocabulary
    python santander-brain.py market             # list market intel
    python santander-brain.py opportunities      # list Accenture opportunities
    python santander-brain.py status             # brain coverage status
"""
import sqlite3
import sys
import json
from pathlib import Path

BRAIN_DB = Path(__file__).parent / "santander-brain.db"


class SantanderBrain:
    def __init__(self):
        if not BRAIN_DB.exists():
            raise FileNotFoundError(
                "santander-brain.db not found. Run: python build-santander-brain.py"
            )
        self.conn = sqlite3.connect(BRAIN_DB)
        self.conn.row_factory = sqlite3.Row

    # ── Interfaz estándar (Regla B1 — 5 métodos) ──────────────────

    def coverage(self) -> dict:
        cur = self.conn.execute("SELECT key, value FROM brain_meta")
        meta = {r["key"]: r["value"] for r in cur.fetchall()}
        total  = self.conn.execute("SELECT COUNT(*) FROM systems").fetchone()[0]
        active = self.conn.execute("SELECT COUNT(*) FROM systems WHERE brain_attached=1").fetchone()[0]
        vocab  = self.conn.execute("SELECT COUNT(*) FROM vocab").fetchone()[0]
        return {**meta, "systems_total": total, "systems_with_brain": active, "vocab_terms": vocab}

    def components(self, system: str = None, limit: int = 50) -> list[dict]:
        if system:
            cur = self.conn.execute(
                "SELECT * FROM components WHERE system=? ORDER BY name LIMIT ?",
                (system, limit)
            )
        else:
            cur = self.conn.execute(
                "SELECT * FROM components ORDER BY system, name LIMIT ?", (limit,)
            )
        return [dict(r) for r in cur.fetchall()]

    def search(self, query: str, limit: int = 30) -> list[dict]:
        like = f"%{query}%"
        cur = self.conn.execute(
            """
            SELECT * FROM components
            WHERE name LIKE ? OR description LIKE ? OR etb_domain_label LIKE ?
            ORDER BY system, name LIMIT ?
            """,
            (like, like, like, limit),
        )
        return [dict(r) for r in cur.fetchall()]

    def rules(self, component_id: str) -> list[dict]:
        # Placeholder — se poblará cuando los system brains tengan reglas extraídas
        return []

    def domains(self) -> list[dict]:
        cur = self.conn.execute(
            """
            SELECT DISTINCT etb_domain_l1, etb_domain_label, COUNT(*) as count
            FROM components GROUP BY etb_domain_l1 ORDER BY count DESC
            """
        )
        return [dict(r) for r in cur.fetchall()]

    # ── Métodos extendidos ─────────────────────────────────────────

    def systems(self) -> list[dict]:
        cur = self.conn.execute(
            """
            SELECT slug, display_name, real_name, category, status, brain_attached, note
            FROM systems ORDER BY category, slug
            """
        )
        return [dict(r) for r in cur.fetchall()]

    def vocab(self, term: str = None, limit: int = 20) -> list[dict]:
        if term:
            like = f"%{term}%"
            cur = self.conn.execute(
                """
                SELECT * FROM vocab
                WHERE term LIKE ? OR en LIKE ? OR domain LIKE ?
                ORDER BY domain, term LIMIT ?
                """,
                (like, like, like, limit),
            )
        else:
            cur = self.conn.execute("SELECT * FROM vocab ORDER BY domain, term LIMIT ?", (limit,))
        return [dict(r) for r in cur.fetchall()]

    def market_intel(self, category: str = None) -> list[dict]:
        if category:
            cur = self.conn.execute(
                "SELECT * FROM market_intel WHERE category=? ORDER BY date DESC",
                (category,)
            )
        else:
            cur = self.conn.execute("SELECT * FROM market_intel ORDER BY category, date DESC")
        return [dict(r) for r in cur.fetchall()]

    def opportunities(self, area: str = None) -> list[dict]:
        if area:
            cur = self.conn.execute(
                "SELECT * FROM opportunities WHERE area LIKE ? ORDER BY priority, effort",
                (f"%{area}%",)
            )
        else:
            cur = self.conn.execute("SELECT * FROM opportunities ORDER BY priority, effort")
        return [dict(r) for r in cur.fetchall()]

    def gap_analysis(self) -> dict:
        scaffold = self.conn.execute(
            "SELECT COUNT(*) FROM systems WHERE status='scaffold'"
        ).fetchone()[0]
        confirmed = self.conn.execute(
            "SELECT COUNT(*) FROM systems WHERE status LIKE 'confirmed%'"
        ).fetchone()[0]
        with_brain = self.conn.execute(
            "SELECT COUNT(*) FROM systems WHERE brain_attached=1"
        ).fetchone()[0]
        total = self.conn.execute("SELECT COUNT(*) FROM systems").fetchone()[0]
        return {
            "total_systems": total,
            "confirmed": confirmed,
            "scaffold_to_fill": scaffold,
            "with_active_brain": with_brain,
            "discovery_progress_pct": round(confirmed / total * 100, 1) if total else 0,
            "brain_coverage_pct": round(with_brain / total * 100, 1) if total else 0,
        }


def main():
    brain = SantanderBrain()
    args  = sys.argv[1:]

    if not args or args[0] == "systems":
        result = brain.systems()
    elif args[0] == "status":
        result = brain.coverage()
    elif args[0] == "vocab":
        term = " ".join(args[1:]) if len(args) > 1 else None
        result = brain.vocab(term)
    elif args[0] == "market":
        cat = args[1] if len(args) > 1 else None
        result = brain.market_intel(cat)
    elif args[0] == "opportunities":
        area = " ".join(args[1:]) if len(args) > 1 else None
        result = brain.opportunities(area)
    elif args[0] == "gap":
        result = brain.gap_analysis()
    elif args[0] == "domains":
        result = brain.domains()
    else:
        result = brain.search(" ".join(args))

    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

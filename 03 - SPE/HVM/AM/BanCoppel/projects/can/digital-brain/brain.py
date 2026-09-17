#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
brain.py — CANBrain · Créditos Asociados a Nómina
API de consulta sobre el Digital Brain del proyecto CAN.
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).resolve().parent / "brain.db"


class CANBrain:

    def _db(self) -> sqlite3.Connection:
        if not DB.exists():
            raise FileNotFoundError(f"brain.db no existe — ejecutar build-brain.py primero: {DB}")
        con = sqlite3.connect(DB)
        con.row_factory = sqlite3.Row
        return con

    def _rows(self, rows) -> list[dict]:
        return [dict(r) for r in rows]

    def coverage(self) -> dict:
        """Estado del brain: métricas clave."""
        con = self._db()
        meta = {r["key"]: r["value"] for r in con.execute("SELECT key, value FROM brain_meta").fetchall()}
        stats = {}
        for t in ("regulatory_obligations","compliance_gaps","user_stories","systems_in_scope"):
            stats[t] = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
        con.close()
        return {"meta": meta, "stats": stats}

    def obligations(self, obligation_type: str = None) -> list[dict]:
        """Obligaciones regulatorias CAN. Filtra por tipo si se especifica."""
        con = self._db()
        if obligation_type:
            rows = con.execute(
                "SELECT * FROM regulatory_obligations WHERE obligation_type=?",
                (obligation_type,)
            ).fetchall()
        else:
            rows = con.execute("SELECT * FROM regulatory_obligations ORDER BY penalty_risk").fetchall()
        con.close()
        return self._rows(rows)

    def gaps(self, status: str = None) -> list[dict]:
        """Brechas de compliance. Filtra por status (CUMPLE|PARCIAL|NO-CUMPLE)."""
        con = self._db()
        if status:
            rows = con.execute(
                "SELECT * FROM compliance_gaps WHERE status=? ORDER BY criticality",
                (status,)
            ).fetchall()
        else:
            rows = con.execute("SELECT * FROM compliance_gaps ORDER BY criticality").fetchall()
        con.close()
        return self._rows(rows)

    def user_stories(self, priority: str = None) -> list[dict]:
        """User Stories de implementación CAN."""
        con = self._db()
        if priority:
            rows = con.execute(
                "SELECT * FROM user_stories WHERE priority=? ORDER BY us_id",
                (priority,)
            ).fetchall()
        else:
            rows = con.execute("SELECT * FROM user_stories ORDER BY priority, us_id").fetchall()
        con.close()
        return self._rows(rows)

    def dashboard(self) -> list[dict]:
        """Vista de cumplimiento por obligación."""
        con = self._db()
        rows = con.execute("SELECT * FROM compliance_dashboard").fetchall()
        con.close()
        return self._rows(rows)

    # Alias estándar (interfaz canónica de 5 métodos)
    def stats(self) -> dict:
        return self.coverage()

    def components(self, domain: str = None, limit: int = 200) -> list[dict]:
        return self.obligations()

    def search(self, query: str) -> list[dict]:
        con = self._db()
        q = f"%{query}%"
        rows = con.execute(
            "SELECT * FROM regulatory_obligations WHERE description LIKE ? OR notes LIKE ?",
            (q, q)
        ).fetchall()
        con.close()
        return self._rows(rows)

    def rules(self, component_id: str) -> list[dict]:
        return self.gaps(status=None)

    def domains(self) -> list[dict]:
        con = self._db()
        rows = con.execute(
            "SELECT obligation_type AS domain, COUNT(*) AS count "
            "FROM regulatory_obligations GROUP BY obligation_type"
        ).fetchall()
        con.close()
        return self._rows(rows)


if __name__ == "__main__":
    b = CANBrain()
    import json
    print(json.dumps(b.coverage(), indent=2, ensure_ascii=False))

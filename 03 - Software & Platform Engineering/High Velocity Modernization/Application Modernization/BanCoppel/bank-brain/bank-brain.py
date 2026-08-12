"""
bank-brain.py — API de consulta del Federated Bank Brain BanCoppel
Uso:
    from bank_brain import BankBrain
    bb = BankBrain()
    bb.coverage()
    bb.migrations(target='apolo')
    bb.search_docs('SPEI arquitectura')
"""

import sqlite3, json
from pathlib import Path
from typing import Optional

DB_PATH = Path(__file__).parent / "bank-brain.db"
LEGACY_DB = Path(__file__).parent.parent / "BCOPCore/digital-brain/brain.db"


class BankBrain:
    def __init__(self, db_path: Path = DB_PATH):
        assert db_path.exists(), f"No existe {db_path}. Ejecuta build-bank-brain.py primero."
        self._db = sqlite3.connect(str(db_path))
        self._db.row_factory = sqlite3.Row
        if LEGACY_DB.exists():
            self._db.execute(
                f"ATTACH DATABASE '{str(LEGACY_DB).replace(chr(92), '/')}' AS legacy"
            )

    # ── Sistemas ──────────────────────────────────────────────────────────
    def systems(self) -> list[dict]:
        rows = self._db.execute("SELECT * FROM systems ORDER BY type, id").fetchall()
        return [dict(r) for r in rows]

    def system(self, sys_id: str) -> Optional[dict]:
        r = self._db.execute("SELECT * FROM systems WHERE id = ?", (sys_id,)).fetchone()
        return dict(r) if r else None

    # ── Migración ────────────────────────────────────────────────────────
    def coverage(self) -> dict:
        """Resumen de cobertura de migración por sistema destino."""
        rows = self._db.execute("""
            SELECT target_sys, COUNT(*) sp_count, SUM(rule_count) rule_count
            FROM migrations
            GROUP BY target_sys
            ORDER BY sp_count DESC
        """).fetchall()
        total_sp = sum(r["sp_count"] for r in rows)
        total_rules = sum(r["rule_count"] or 0 for r in rows)
        result = {
            "total_sps": total_sp,
            "total_rules": total_rules,
            "by_target": [],
        }
        for r in rows:
            result["by_target"].append({
                "target": r["target_sys"],
                "sps": r["sp_count"],
                "rules": r["rule_count"] or 0,
                "sp_pct": round(r["sp_count"] / total_sp * 100, 1) if total_sp else 0,
            })
        return result

    def migrations(
        self,
        target: Optional[str] = None,
        domain: Optional[str] = None,
        confidence: Optional[str] = None,
        limit: int = 100,
    ) -> list[dict]:
        """Lista SPs por sistema destino, dominio o nivel de confianza."""
        where, params = [], []
        if target:
            where.append("target_sys = ?"); params.append(target)
        if domain:
            where.append("domain_id = ?"); params.append(domain)
        if confidence:
            where.append("confidence = ?"); params.append(confidence)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"SELECT * FROM migrations {clause} ORDER BY domain_id, sp LIMIT ?",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def domains(self) -> list[dict]:
        """Lista dominios Informix con su sistema destino asignado."""
        rows = self._db.execute("""
            SELECT
                m.domain_id,
                m.domain_name,
                m.target_sys,
                m.confidence,
                COUNT(*)        AS sp_count,
                SUM(m.rule_count) AS rule_count
            FROM migrations m
            WHERE m.domain_id IS NOT NULL
            GROUP BY m.domain_id, m.target_sys
            ORDER BY m.domain_id
        """).fetchall()
        return [dict(r) for r in rows]

    # ── Documentos ────────────────────────────────────────────────────────
    def documents(
        self,
        system: Optional[str] = None,
        doc_type: str = "minuta",
        limit: int = 50,
    ) -> list[dict]:
        """Minutas (o docs) indexados, filtrable por sistema mencionado."""
        if system:
            rows = self._db.execute(
                """SELECT * FROM documents
                   WHERE type = ? AND systems_mentioned LIKE ?
                   ORDER BY date DESC LIMIT ?""",
                (doc_type, f'%{system}%', limit),
            ).fetchall()
        else:
            rows = self._db.execute(
                "SELECT * FROM documents WHERE type = ? ORDER BY date DESC LIMIT ?",
                (doc_type, limit),
            ).fetchall()
        return [dict(r) for r in rows]

    def search_docs(self, query: str, limit: int = 20) -> list[dict]:
        """Busca en títulos y temas de minutas (simple substring)."""
        q = f"%{query.lower()}%"
        rows = self._db.execute(
            """SELECT id, date, title, filename, systems_mentioned, word_count
               FROM documents
               WHERE lower(title) LIKE ? OR lower(key_topics) LIKE ?
               ORDER BY date DESC LIMIT ?""",
            (q, q, limit),
        ).fetchall()
        return [dict(r) for r in rows]

    # ── Interfaces ────────────────────────────────────────────────────────
    def interfaces(
        self,
        from_sys: Optional[str] = None,
        to_sys: Optional[str] = None,
    ) -> list[dict]:
        where, params = [], []
        if from_sys:
            where.append("from_sys = ?"); params.append(from_sys)
        if to_sys:
            where.append("to_sys = ?"); params.append(to_sys)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"SELECT * FROM interfaces {clause} ORDER BY from_sys, to_sys",
            params,
        ).fetchall()
        return [dict(r) for r in rows]

    # ── Releases ──────────────────────────────────────────────────────────
    def releases(self) -> list[dict]:
        rows = self._db.execute(
            "SELECT * FROM releases ORDER BY target_date"
        ).fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["scope"] = json.loads(d["scope"] or "[]")
            result.append(d)
        return result

    # ── Capa estratégica ─────────────────────────────────────────────────
    def stakeholders(self, org: Optional[str] = None, level: Optional[str] = None) -> list[dict]:
        """Lista actores estratégicos, opcionalmente filtrado por org o nivel."""
        where, params = [], []
        if org:
            where.append("org = ?"); params.append(org)
        if level:
            where.append("level = ?"); params.append(level)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"SELECT * FROM stakeholders {clause} ORDER BY appearance_count DESC",
            params,
        ).fetchall()
        return [dict(r) for r in rows]

    def stakeholder_brief(self, stakeholder_id: str) -> dict:
        """Resumen completo de un actor: perfil + decisiones + posturas + ítems abiertos."""
        sh = self._db.execute(
            "SELECT * FROM stakeholders WHERE id = ?", (stakeholder_id,)
        ).fetchone()
        if not sh:
            return {}
        result = dict(sh)
        result["decisions"] = [
            dict(r) for r in self._db.execute(
                "SELECT * FROM decisions WHERE driver_id = ? ORDER BY date", (stakeholder_id,)
            ).fetchall()
        ]
        result["positions"] = [
            dict(r) for r in self._db.execute(
                "SELECT * FROM positions WHERE stakeholder_id = ? ORDER BY date", (stakeholder_id,)
            ).fetchall()
        ]
        result["open_items"] = [
            dict(r) for r in self._db.execute(
                "SELECT * FROM open_items WHERE owner_id = ? AND status = 'open' ORDER BY priority DESC, date",
                (stakeholder_id,)
            ).fetchall()
        ]
        return result

    def decisions(
        self,
        topic: Optional[str] = None,
        driver: Optional[str] = None,
        limit: int = 50,
    ) -> list[dict]:
        """Decisiones estratégicas, filtrable por tema o quién la impulsó."""
        where, params = [], []
        if topic:
            where.append("topic LIKE ?"); params.append(f"%{topic}%")
        if driver:
            where.append("driver_id = ?"); params.append(driver)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"SELECT * FROM decisions {clause} ORDER BY date LIMIT ?",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def positions(
        self,
        stakeholder_id: Optional[str] = None,
        topic: Optional[str] = None,
        sentiment: Optional[str] = None,
        client_only: bool = False,
        limit: int = 50,
    ) -> list[dict]:
        """Posturas de actores sobre temas.
        client_only=True filtra solo posturas de actores BanCoppel/Grupo Coppel
        (excluye proveedores: Accenture, AWS, etc.).
        """
        base = "client_positions" if client_only else (
            "positions p LEFT JOIN stakeholders s ON s.id = p.stakeholder_id"
        )
        if client_only:
            base_query = f"SELECT * FROM client_positions"
        else:
            base_query = (
                "SELECT p.*, s.name AS stakeholder_name, s.org FROM positions p "
                "LEFT JOIN stakeholders s ON s.id = p.stakeholder_id"
            )
        where, params = [], []
        if stakeholder_id:
            where.append("stakeholder_id = ?"); params.append(stakeholder_id)
        if topic:
            where.append("topic LIKE ?"); params.append(f"%{topic}%")
        if sentiment:
            where.append("sentiment = ?"); params.append(sentiment)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"{base_query} {clause} ORDER BY date LIMIT ?",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def open_items(
        self,
        owner: Optional[str] = None,
        priority: Optional[str] = None,
        status: str = "open",
        limit: int = 50,
    ) -> list[dict]:
        """Ítems estratégicos abiertos."""
        where, params = ["status = ?"], [status]
        if owner:
            where.append("owner_id = ?"); params.append(owner)
        if priority:
            where.append("priority = ?"); params.append(priority)
        clause = "WHERE " + " AND ".join(where)
        rows = self._db.execute(
            f"SELECT oi.*, s.name AS owner_name FROM open_items oi "
            f"LEFT JOIN stakeholders s ON s.id = oi.owner_id "
            f"{clause} ORDER BY priority DESC, date LIMIT ?",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def topic_brief(self, topic: str) -> dict:
        """Todo lo que el brain sabe sobre un tema: decisiones + posturas + minutas."""
        return {
            "topic": topic,
            "decisions": self.decisions(topic=topic),
            "positions": self.positions(topic=topic),
            "documents": self.search_docs(topic),
            "open_items": self.open_items(status="open"),
        }

    # ── Legacy passthrough ────────────────────────────────────────────────
    def legacy_sp(self, sp_name: str, db_name: Optional[str] = None) -> Optional[dict]:
        """Consulta un SP directamente de brain.db legacy."""
        where = "name = ?"
        params: list = [sp_name]
        if db_name:
            where += " AND db = ?"
            params.append(db_name)
        r = self._db.execute(
            f"SELECT * FROM legacy.sps WHERE {where} LIMIT 1", params
        ).fetchone()
        return dict(r) if r else None

    def legacy_rules(self, sp_name: str, db_name: Optional[str] = None) -> list[dict]:
        """Reglas de negocio de un SP legacy."""
        where = "sp = ?"
        params: list = [sp_name]
        if db_name:
            where += " AND db = ?"
            params.append(db_name)
        rows = self._db.execute(
            f"SELECT * FROM legacy.rules WHERE {where} ORDER BY id", params
        ).fetchall()
        return [dict(r) for r in rows]

    def close(self):
        self._db.close()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()


# ── CLI rápido ─────────────────────────────────────────────────────────────
def _cli():
    bb = BankBrain()
    print("=== BankBrain CLI ===")

    print("\n-- Sistemas --")
    for s in bb.systems():
        print(f"  [{s['id']:<12}] {s['name']:<35} {s['type']:<12} {s['status']}")

    print("\n-- Cobertura de migración --")
    cov = bb.coverage()
    print(f"  Total SPs : {cov['total_sps']:,}")
    print(f"  Total reglas: {cov['total_rules']:,}")
    for t in cov["by_target"]:
        bar = "█" * int(t["sp_pct"] / 2)
        print(f"  {t['target']:<15}: {t['sps']:>5} SPs  {t['rules']:>6} reglas  {t['sp_pct']:>5.1f}%  {bar}")

    print("\n-- Dominios → target --")
    for d in bb.domains():
        print(f"  {d['domain_id']:<4}  {d['target_sys']:<14} {d['confidence']:<8}  "
              f"{d['sp_count']:>5} SPs  {d['domain_name'] or '—'}")

    print("\n-- Releases Unity --")
    for r in bb.releases():
        scope = ", ".join(r["scope"])
        print(f"  {r['id']}  {r['target_date']}  {r['status']:<10}  [{scope}]  {r['name']}")

    print("\n-- Minutas (últimas 10) --")
    for d in bb.documents(limit=10):
        sys_m = json.loads(d["systems_mentioned"] or "[]")
        print(f"  {d['date'] or '?':<12}  {d['filename'][:55]:<55}  {sys_m}")

    print("\n-- Actores estratégicos (por apariciones) --")
    for s in bb.stakeholders():
        if s["appearance_count"] == 0:
            continue
        print(f"  {s['name']:<30} {s['org']:<12} {s['level']:<12} {s['influence']:<16} {s['appearance_count']:>3} aparic")

    print("\n-- Posturas de preocupación (concerned) --")
    for p in bb.positions(sentiment="concerned", limit=10):
        name = p.get("stakeholder_name") or p["stakeholder_id"]
        print(f"  {name:<28} [{p['topic']:<14}] {p['stance'][:90]}")

    print("\n-- Decisiones estratégicas recientes --")
    for d in bb.decisions(limit=8):
        drv = d["driver_id"] or "—"
        print(f"  {d['id']} {d['date'] or '?':12} [{d['topic']:<14}] drv={drv:<20} {d['decision'][:70]}")

    print("\n-- Open items HIGH priority --")
    for oi in bb.open_items(priority="high", limit=10):
        owner = oi.get("owner_name") or oi["owner_id"] or "—"
        print(f"  {oi['id']} {oi['date'] or '?':12} {owner:<28} {oi['item'][:70]}")

    bb.close()


if __name__ == "__main__":
    _cli()

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
LEGACY_DB = Path(__file__).parent.parent / "systems/core/Informix/digital-brain/brain.db"


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

    def release_status(self, release_id: str) -> dict:
        """Detalle de un release: productos que salieron a producción y productos en esa wave."""
        r = self._db.execute(
            "SELECT * FROM releases WHERE id = ?", (release_id,)
        ).fetchone()
        if not r:
            return {}
        result = dict(r)
        result["scope"] = json.loads(result["scope"] or "[]")
        result["products_live"] = [
            dict(p) for p in self._db.execute(
                """SELECT id, name, platform_id, status, segment
                   FROM products WHERE went_live_release = ?""",
                (release_id,),
            ).fetchall()
        ]
        result["products_in_wave"] = [
            dict(p) for p in self._db.execute(
                """SELECT id, name, platform_id, status, segment
                   FROM products WHERE launch_wave = ? AND went_live_release IS NULL""",
                (release_id,),
            ).fetchall()
        ]
        return result

    # ── Vista TOGAF de sistemas ────────────────────────────────────────────
    def systems_status(self) -> list[dict]:
        """Todos los sistemas con clasificación TOGAF (togaf_type, togaf_state, production_status)."""
        rows = self._db.execute(
            """SELECT id, name, togaf_type, togaf_state, production_status, production_since,
                      type, status
               FROM systems ORDER BY togaf_type NULLS LAST, togaf_state, id"""
        ).fetchall()
        return [dict(r) for r in rows]

    def production_systems(self) -> list[dict]:
        """Sistemas con al menos algo en producción (production_status = live o partial)."""
        rows = self._db.execute(
            """SELECT id, name, togaf_type, togaf_state, production_status, production_since
               FROM systems WHERE production_status IN ('live', 'partial')
               ORDER BY production_since NULLS LAST"""
        ).fetchall()
        return [dict(r) for r in rows]

    def in_flight_systems(self) -> list[dict]:
        """Sistemas en desarrollo activo (production_status = in_flight)."""
        rows = self._db.execute(
            """SELECT id, name, togaf_type, togaf_state, production_status
               FROM systems WHERE production_status = 'in_flight'
               ORDER BY togaf_type, id"""
        ).fetchall()
        return [dict(r) for r in rows]

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

    # ── Vendors ──────────────────────────────────────────────────────────
    def vendors(self) -> list[dict]:
        """Vendors tecnológicos y sus plataformas en Unity."""
        import json as _json
        rows = self._db.execute(
            "SELECT * FROM vendors ORDER BY category, id"
        ).fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d["modules"] = _json.loads(d["modules"] or "[]")
            result.append(d)
        return result

    # ── Productos bancarios ───────────────────────────────────────────────
    def products(
        self,
        platform: Optional[str] = None,
        status: Optional[str] = None,
        segment: Optional[str] = None,
    ) -> list[dict]:
        """Productos bancarios, filtrable por plataforma, estado o segmento."""
        where, params = [], []
        if platform:
            where.append("p.platform_id = ?"); params.append(platform)
        if status:
            where.append("p.status = ?"); params.append(status)
        if segment:
            where.append("p.segment = ?"); params.append(segment)
        clause = ("WHERE " + " AND ".join(where)) if where else ""
        rows = self._db.execute(
            f"""SELECT p.*, v.name AS vendor_name, s.name AS platform_name
                FROM products p
                LEFT JOIN vendors v ON v.id = p.vendor_id
                LEFT JOIN systems s ON s.id = p.platform_id
                {clause}
                ORDER BY p.target_date NULLS LAST, p.status""",
            params,
        ).fetchall()
        return [dict(r) for r in rows]

    def product_detail(self, product_id: str) -> dict:
        """Detalle completo: plataforma + vendor + SPs legacy + estado."""
        r = self._db.execute(
            """SELECT p.*, v.name AS vendor_name, v.category AS vendor_category,
                      v.modules AS vendor_modules,
                      s.name AS platform_name, s.tech_stack
               FROM products p
               LEFT JOIN vendors v ON v.id = p.vendor_id
               LEFT JOIN systems s ON s.id = p.platform_id
               WHERE p.id = ?""",
            (product_id,),
        ).fetchone()
        if not r:
            return {}
        import json as _json
        result = dict(r)
        result["vendor_modules"] = _json.loads(result["vendor_modules"] or "[]")
        result["legacy_scope"] = self.migration_gap(product_id)
        return result

    def product_legacy_sps(
        self, product_id: str, domain: Optional[str] = None, limit: int = 50
    ) -> list[dict]:
        """SPs del legado que mapean a la plataforma de este producto."""
        prod = self._db.execute(
            "SELECT platform_id FROM products WHERE id = ?", (product_id,)
        ).fetchone()
        if not prod:
            return []
        where = ["m.target_sys = ?"]
        params: list = [prod["platform_id"]]
        if domain:
            where.append("m.domain_id = ?"); params.append(domain)
        rows = self._db.execute(
            f"""SELECT m.sp, m.db, m.domain_id, m.domain_name,
                       m.target_sys, m.confidence, m.rule_count
                FROM migrations m
                WHERE {' AND '.join(where)}
                ORDER BY m.rule_count DESC, m.domain_id, m.sp
                LIMIT ?""",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def fate_summary(self, target: Optional[str] = None) -> dict:
        """Resumen de migration_fate global o por sistema destino."""
        where = "WHERE target_sys = ?" if target else ""
        params = [target] if target else []
        rows = self._db.execute(
            f"""SELECT migration_fate, fate_confidence,
                       COUNT(*) sp_count, SUM(rule_count) rule_count
                FROM migrations {where}
                GROUP BY migration_fate, fate_confidence
                ORDER BY sp_count DESC""",
            params,
        ).fetchall()
        total = sum(r["sp_count"] for r in rows)
        by_fate: dict = {}
        for r in rows:
            fate = r["migration_fate"]
            if fate not in by_fate:
                by_fate[fate] = {"sps": 0, "rules": 0, "by_confidence": {}}
            by_fate[fate]["sps"]   += r["sp_count"]
            by_fate[fate]["rules"] += r["rule_count"] or 0
            by_fate[fate]["by_confidence"][r["fate_confidence"]] = r["sp_count"]
        return {"target": target or "all", "total_sps": total, "by_fate": by_fate}

    def critical_replicate(
        self,
        target: Optional[str] = None,
        min_rules: int = 10,
        limit: int = 50,
    ) -> list[dict]:
        """SPs clasificados como replicate con alta carga de reglas — los más críticos."""
        where = ["migration_fate = 'replicate'", "rule_count >= ?"]
        params: list = [min_rules]
        if target:
            where.append("target_sys = ?"); params.append(target)
        rows = self._db.execute(
            f"""SELECT sp, db, target_sys, domain_id, domain_name,
                       rule_count, fate_confidence
                FROM migrations
                WHERE {' AND '.join(where)}
                ORDER BY rule_count DESC
                LIMIT ?""",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def fated_migrations(
        self,
        fate: str,
        target: Optional[str] = None,
        limit: int = 100,
    ) -> list[dict]:
        """Lista SPs filtrados por fate y opcionalmente por sistema destino."""
        where = ["migration_fate = ?"]
        params: list = [fate]
        if target:
            where.append("target_sys = ?"); params.append(target)
        rows = self._db.execute(
            f"""SELECT sp, db, target_sys, domain_id, domain_name,
                       rule_count, migration_fate, fate_confidence
                FROM migrations
                WHERE {' AND '.join(where)}
                ORDER BY rule_count DESC, domain_id, sp
                LIMIT ?""",
            params + [limit],
        ).fetchall()
        return [dict(r) for r in rows]

    def migration_gap(self, product_id: str) -> dict:
        """Cuántos SPs legacy quedan en scope para este producto, por dominio."""
        prod = self._db.execute(
            "SELECT platform_id FROM products WHERE id = ?", (product_id,)
        ).fetchone()
        if not prod:
            return {}
        platform = prod["platform_id"]
        rows = self._db.execute(
            """SELECT domain_id, domain_name, confidence,
                      COUNT(*) AS sp_count, SUM(rule_count) AS rule_count
               FROM migrations
               WHERE target_sys = ?
               GROUP BY domain_id
               ORDER BY rule_count DESC""",
            (platform,),
        ).fetchall()
        totals = self._db.execute(
            """SELECT COUNT(*) sp_count, SUM(rule_count) rule_count
               FROM migrations WHERE target_sys = ?""",
            (platform,),
        ).fetchone()
        return {
            "product_id": product_id,
            "platform": platform,
            "total_sps": totals["sp_count"],
            "total_rules": totals["rule_count"] or 0,
            "by_domain": [dict(r) for r in rows],
        }

    # ── ETB federado ─────────────────────────────────────────────────────
    def capabilities_consolidated(self) -> list[dict]:
        """Capacidades ETB cubiertas en algún sistema ATTACHED (COVERED o CROSS_CUTTING).
        Cada fila incluye el sistema que la cubre y su etb_version local.
        Permite a bank-brain responder "¿quién cubre L3-ID-X?" sin conocer el sistema de antemano.
        """
        # Construir UNION sobre todos los brains ATTACHed que tengan etb_l3
        # Hoy solo 'legacy' (Informix); cuando Transact tenga brain.db se añade otro UNION.
        try:
            rows = self._db.execute("""
                SELECT 'informix' AS system_id,
                       id AS l3_id, l1_id, l2_id, name,
                       bcop_status, etb_version
                FROM legacy.etb_l3
                WHERE bcop_status IN ('COVERED', 'CROSS_CUTTING')
                ORDER BY l1_id, l2_id, id
            """).fetchall()
        except Exception:
            return []
        return [dict(r) for r in rows]

    def capability_gap(self) -> list[dict]:
        """Capacidades ETB L3 que ningún sistema cubre (NOT_COVERED en todos los brains).
        Responde: ¿qué capacidades del modelo ETB quedan sin sistema después de la migración?
        Es la validación de decommission de PISA: si una capability solo existe en legacy
        y no hay sistema target que la cubra, es un riesgo de cutover.
        """
        try:
            rows = self._db.execute("""
                SELECT id AS l3_id, l1_id, l2_id, name, bcop_status, etb_version
                FROM legacy.etb_l3
                WHERE bcop_status = 'NOT_COVERED'
                ORDER BY l1_id, l2_id, id
            """).fetchall()
        except Exception:
            return []
        return [dict(r) for r in rows]

    def capability_alignment(self) -> list[dict]:
        """Versión ETB por sistema attached — detecta desalineación cuando el catálogo evoluciona.
        bank-brain es el custodio del modelo ETB; cuando ETB sube de versión, esta función
        identifica qué brains todavía usan una versión anterior y necesitan rebuild.
        """
        systems_checked = [("informix", "legacy")]
        result = []
        for sys_id, schema in systems_checked:
            try:
                row = self._db.execute(
                    f"SELECT DISTINCT etb_version FROM {schema}.etb_l3 LIMIT 1"
                ).fetchone()
                version = row["etb_version"] if row else "unknown"
            except Exception:
                version = "not_loaded"
            result.append({"system_id": sys_id, "etb_version": version})
        return result

    def system_dependencies(
        self, system_id: Optional[str] = None, direction: Optional[str] = None
    ) -> list[dict]:
        """Dependencias cross-sistema declaradas en bank-brain.
        direction: 'inbound' | 'outbound' (perspectiva de source_system).
        Refleja la regla: cada cerebro declara SU LADO de la relación — banco-brain agrega la vista global.
        """
        try:
            where, params = [], []
            if system_id:
                where.append("(source_system = ? OR target_system = ?)")
                params.extend([system_id, system_id])
            if direction:
                where.append("direction = ?"); params.append(direction)
            clause = ("WHERE " + " AND ".join(where)) if where else ""
            rows = self._db.execute(
                f"SELECT * FROM system_dependencies {clause} ORDER BY source_system, dependency_type",
                params,
            ).fetchall()
            return [dict(r) for r in rows]
        except Exception:
            return []

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

    print("\n-- Sistemas (TOGAF) --")
    for s in bb.systems_status():
        print(f"  [{s['id']:<12}] {s['togaf_type'] or '?':<12} {s['togaf_state'] or '?':<14} "
              f"{s['production_status'] or '?':<12} since={s['production_since'] or '—'}")

    print("\n-- Sistemas en producción --")
    for s in bb.production_systems():
        print(f"  [{s['id']:<12}] {s['name']:<35} {s['production_status']:<10} since={s['production_since'] or '—'}")

    print("\n-- Releases BanCoppel (R-series) + Waves Accenture (U-series) --")
    for r in bb.releases():
        scope = ", ".join(r["scope"])
        print(f"  {r['id']:<3}  {r['target_date'] or '?':<9}  {r['status']:<12}  [{scope}]  {r['name']}")

    print("\n-- Release R2 (products live) --")
    rs = bb.release_status("R2")
    for p in rs.get("products_live", []):
        print(f"  LIVE  [{p['platform_id']:<12}] {p['name']}")

    print("\n-- Release R4 (products in wave) --")
    rs4 = bb.release_status("R4")
    for p in rs4.get("products_in_wave", []):
        print(f"  IN WAVE  [{p['platform_id']:<12}] {p['name']}")

    print("\n-- Alineación ETB por sistema --")
    for a in bb.capability_alignment():
        print(f"  {a['system_id']:<15} etb_version={a['etb_version']}")

    print("\n-- Capacidades ETB cubiertas (consolidado) --")
    covered = bb.capabilities_consolidated()
    by_sys: dict = {}
    for c in covered:
        by_sys.setdefault(c["system_id"], 0)
        by_sys[c["system_id"]] += 1
    for sys_id, cnt in by_sys.items():
        print(f"  {sys_id:<15} {cnt:>3} L3 cubiertas")

    print("\n-- Gap ETB (sin sistema que cubra) --")
    gap = bb.capability_gap()
    print(f"  {len(gap)} L3 sin cobertura en ningún sistema")

    print("\n-- Dependencias cross-sistema --")
    deps = bb.system_dependencies()
    if deps:
        for d in deps:
            print(f"  {d['source_system']:<12} --[{d['dependency_type']}]--> {d['target_system']:<12}  {d['criticality'] or '?'}  {d['description'] or ''[:60]}")
    else:
        print("  (tabla system_dependencies vacía — sin dependencias declaradas aún)")

    print("\n-- Minutas (últimas 10) --")
    for d in bb.documents(limit=10):
        sys_m = json.loads(d["systems_mentioned"] or "[]")
        print(f"  {d['date'] or '?':<12}  {d['filename'][:55]:<55}  {sys_m}")

    print("\n-- Vendors y plataformas --")
    for v in bb.vendors():
        mods = ", ".join(v["modules"][:3])
        print(f"  [{v['id']:<10}] → {v['system_id']:<12} ({v['category']})  módulos: {mods}...")

    print("\n-- Productos bancarios --")
    for p in bb.products():
        print(f"  [{p['platform_id']:<12}] {p['name']:<50} {p['status']:<12} {p['target_date'] or '?'}")

    print("\n-- Gap de migración legacy por producto --")
    for p in bb.products():
        gap = bb.migration_gap(p["id"])
        print(f"  {p['id']:<28} → {gap['platform']:<12}: "
              f"{gap['total_sps']:>5} SPs  {gap['total_rules']:>6} reglas")

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

"""
brain.py — GemCog Brain v2 · Agent API
Interfaz de consulta semántica sobre brain.db de Banamex GemCog S500+S151.

Uso:
    from digital_brain.brain import GemCogBrain
    brain = GemCogBrain()
    brain.stats()
    brain.rules_by_capacity("BC-13")
    brain.critical_risks()
    brain.search_rules("centinela EOF")
"""

import sqlite3
from pathlib import Path
from typing import Any

_DB = Path(__file__).parent / "brain.db"


class GemCogBrain:
    def __init__(self, db_path: str | Path = _DB):
        self._db = Path(db_path)
        if not self._db.exists():
            raise FileNotFoundError(
                f"brain.db no encontrado en {self._db}. "
                "Ejecuta: python digital-brain/build-brain.py"
            )
        self._conn = sqlite3.connect(self._db)
        self._conn.row_factory = sqlite3.Row

    def close(self):
        self._conn.close()

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ── Helpers ───────────────────────────────────────────────────────────────
    def _q(self, sql: str, params=()) -> list[sqlite3.Row]:
        return self._conn.execute(sql, params).fetchall()

    def _one(self, sql: str, params=()) -> sqlite3.Row | None:
        return self._conn.execute(sql, params).fetchone()

    def _stat(self, key: str) -> int:
        row = self._one("SELECT value FROM stats WHERE key=?", (key,))
        return int(row["value"]) if row else 0

    # ── Overview ──────────────────────────────────────────────────────────────
    def stats(self) -> dict[str, Any]:
        """Métricas de cobertura del brain."""
        keys = [
            "capacidades", "programs", "tasks", "rules", "risks",
            "rule_vocab", "vocab_terms", "rules_sin_sbvr", "rules_con_regulador",
            "risks_defecto_prod", "risks_crítico",
        ]
        out = {k: self._stat(k) for k in keys}
        # Distribución por capacidad
        out["rules_por_cap"] = {
            row["bc_id"]: row["n"]
            for row in self._q("SELECT bc_id, COUNT(*) n FROM rules GROUP BY bc_id ORDER BY n DESC")
        }
        return out

    def capacity_summary(self) -> list[dict]:
        """Resumen por capacidad: reglas, riesgos, programas."""
        rows = self._q("""
            SELECT
                c.bc_id, c.slug, c.nombre, c.sistema,
                COUNT(DISTINCT r.rule_id) rule_count,
                COUNT(DISTINCT p.prog_id) prog_count,
                SUM(CASE WHEN ri.sev_rank >= 4 THEN 1 ELSE 0 END) crit_risks,
                SUM(CASE WHEN ri.sev_rank = 5 THEN 1 ELSE 0 END) defecto_prod
            FROM capacidades c
            LEFT JOIN rules r ON r.bc_id = c.bc_id
            LEFT JOIN programs p ON p.bc_id = c.bc_id
            LEFT JOIN risks ri ON ri.cap_slug = c.slug
            GROUP BY c.bc_id
            ORDER BY rule_count DESC
        """)
        return [dict(r) for r in rows]

    # ── Capacidades ───────────────────────────────────────────────────────────
    def capacidad(self, bc_id_or_slug: str) -> dict | None:
        """Detalle de una capacidad por BC-ID o slug."""
        row = self._one(
            "SELECT * FROM capacidades WHERE bc_id=? OR slug=?",
            (bc_id_or_slug, bc_id_or_slug.lower())
        )
        return dict(row) if row else None

    # ── Programs ──────────────────────────────────────────────────────────────
    def programs_by_capacity(self, bc_id: str) -> list[dict]:
        rows = self._q("SELECT * FROM programs WHERE bc_id=? ORDER BY prog_id", (bc_id,))
        return [dict(r) for r in rows]

    def program(self, prog_id: str) -> dict | None:
        row = self._one("SELECT * FROM programs WHERE prog_id=?", (prog_id.upper(),))
        return dict(row) if row else None

    # ── Tasks ─────────────────────────────────────────────────────────────────
    def tasks_by_capacity(self, bc_id: str) -> list[dict]:
        rows = self._q(
            "SELECT * FROM tasks WHERE bc_id=? ORDER BY task_id", (bc_id,)
        )
        return [dict(r) for r in rows]

    def task(self, task_id: str) -> dict | None:
        row = self._one("SELECT * FROM tasks WHERE task_id=?", (task_id,))
        return dict(row) if row else None

    # ── Rules ─────────────────────────────────────────────────────────────────
    def rules_by_capacity(self, bc_id: str, sistema: str | None = None) -> list[dict]:
        """Reglas de una capacidad, opcionalmente filtradas por sistema S500/S151."""
        sql = "SELECT * FROM rules WHERE bc_id=?"
        params: list = [bc_id]
        if sistema:
            sql += " AND sistema=?"
            params.append(sistema.upper())
        sql += " ORDER BY rule_id"
        return [dict(r) for r in self._q(sql, params)]

    def rules_by_program(self, prog_id: str) -> list[dict]:
        rows = self._q(
            "SELECT * FROM rules WHERE programa LIKE ? ORDER BY rule_id",
            (f"%{prog_id.upper()}%",)
        )
        return [dict(r) for r in rows]

    def rule_detail(self, rule_id: str) -> dict | None:
        row = self._one("SELECT * FROM rules WHERE rule_id=?", (rule_id,))
        if not row:
            return None
        result = dict(row)
        result["vocab"] = self.vocab_for_rule(rule_id)
        return result

    def rules_by_clase(self, clase: str) -> list[dict]:
        """Reglas por clase: NEGOCIO · CONTABLE · CONTROL_FLUJO · VALIDACION."""
        rows = self._q(
            "SELECT * FROM rules WHERE clase=? ORDER BY rule_id", (clase.upper(),)
        )
        return [dict(r) for r in rows]

    def clase_distribution(self) -> dict[str, int]:
        """Conteo de reglas por clase."""
        rows = self._q(
            "SELECT clase, COUNT(*) n FROM rules GROUP BY clase ORDER BY n DESC"
        )
        return {r["clase"] or "SIN_CLASE": r["n"] for r in rows}

    def rules_without_type(self) -> list[dict]:
        """Reglas que aún no tienen tipo_regla (pendientes SBVR)."""
        rows = self._q(
            "SELECT rule_id, nombre, bc_id, programa FROM rules "
            "WHERE tipo_regla IS NULL OR tipo_regla='' ORDER BY rule_id"
        )
        return [dict(r) for r in rows]

    def rules_with_regulator(self, sistema: str | None = None) -> list[dict]:
        """Reglas con norma regulatoria explícita (no N/A)."""
        sql = (
            "SELECT rule_id, nombre, bc_id, programa, regulador FROM rules "
            "WHERE regulador NOT IN ('N/A', 'N/A — control de integridad', '') "
            "AND regulador IS NOT NULL"
        )
        params: list = []
        if sistema:
            sql += " AND sistema=?"
            params.append(sistema.upper())
        sql += " ORDER BY rule_id"
        return [dict(r) for r in self._q(sql, params)]

    # ── Risks ─────────────────────────────────────────────────────────────────
    def risks_by_cap(self, slug: str) -> list[dict]:
        """Riesgos de una capacidad, ordenados de mayor a menor severidad."""
        rows = self._q(
            "SELECT * FROM risks WHERE cap_slug=? ORDER BY sev_rank DESC, risk_id",
            (slug.lower(),)
        )
        return [dict(r) for r in rows]

    def critical_risks(self, min_rank: int = 4) -> list[dict]:
        """Riesgos CRÍTICO + DEFECTO-PROD (rank ≥ 4)."""
        rows = self._q(
            "SELECT * FROM risks WHERE sev_rank >= ? ORDER BY sev_rank DESC, risk_id",
            (min_rank,)
        )
        return [dict(r) for r in rows]

    def risks_by_pattern(self, pattern: str) -> list[dict]:
        """Riesgos por patrón: HARDCODE, SILENCIOSO, EQUIVALENCIA, etc."""
        rows = self._q(
            "SELECT * FROM risks WHERE patron LIKE ? ORDER BY sev_rank DESC",
            (f"%{pattern.upper()}%",)
        )
        return [dict(r) for r in rows]

    # ── Vocab ─────────────────────────────────────────────────────────────────
    def vocab_for_rule(self, rule_id: str) -> list[dict]:
        rows = self._q(
            "SELECT * FROM rule_vocab WHERE rule_id=? ORDER BY term", (rule_id,)
        )
        return [dict(r) for r in rows]

    def vocab_lookup(self, term: str) -> dict | None:
        row = self._one("SELECT * FROM vocab_terms WHERE term=?", (term,))
        if not row:
            # Búsqueda parcial
            row = self._one("SELECT * FROM vocab_terms WHERE term LIKE ?", (f"%{term}%",))
        return dict(row) if row else None

    # ── FTS5 Search ───────────────────────────────────────────────────────────
    def search_rules(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda full-text sobre rules (nombre + descripcion + riesgos)."""
        try:
            fts_rows = self._q(
                "SELECT rule_id FROM rules_fts WHERE rules_fts MATCH ? ORDER BY rank LIMIT ?",
                (query, limit)
            )
            ids = [r["rule_id"] for r in fts_rows]
            if not ids:
                return []
            placeholders = ",".join("?" * len(ids))
            rows = self._q(
                f"SELECT * FROM rules WHERE rule_id IN ({placeholders})", ids
            )
            return [dict(r) for r in rows]
        except sqlite3.OperationalError:
            return []

    def search_risks(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda full-text sobre risks (descripcion + accion)."""
        try:
            fts_rows = self._q(
                "SELECT risk_id FROM risks_fts WHERE risks_fts MATCH ? ORDER BY rank LIMIT ?",
                (query, limit)
            )
            ids = [r["risk_id"] for r in fts_rows]
            if not ids:
                return []
            placeholders = ",".join("?" * len(ids))
            rows = self._q(
                f"SELECT * FROM risks WHERE risk_id IN ({placeholders})", ids
            )
            return [dict(r) for r in rows]
        except sqlite3.OperationalError:
            return []

    def search_vocab(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda full-text sobre términos de vocabulario."""
        try:
            fts_rows = self._q(
                "SELECT term FROM vocab_fts WHERE vocab_fts MATCH ? ORDER BY rank LIMIT ?",
                (query, limit)
            )
            terms = [r["term"] for r in fts_rows]
            if not terms:
                return []
            placeholders = ",".join("?" * len(terms))
            rows = self._q(
                f"SELECT * FROM vocab_terms WHERE term IN ({placeholders})", terms
            )
            return [dict(r) for r in rows]
        except sqlite3.OperationalError:
            return []

    # ── Cross-dependencies ────────────────────────────────────────────────────
    def cross_dependencies(self, direction: str | None = None,
                           dep_type: str | None = None) -> list[dict]:
        """Sistemas externos ordenados por rule_count desc. Filtra por direction y/o dep_type."""
        sql = "SELECT * FROM cross_dependencies WHERE 1=1"
        params: list = []
        if direction:
            sql += " AND direction=?"
            params.append(direction)
        if dep_type:
            sql += " AND dep_type=?"
            params.append(dep_type.upper())
        sql += " ORDER BY rule_count DESC"
        return [dict(r) for r in self._q(sql, params)]

    def regulatory_exposure(self) -> list[dict]:
        """Solo dependencias regulatorias, con detalle de criticidad y cobertura."""
        return self.cross_dependencies(dep_type="REGULATORIO")

    # ── Cross-queries ─────────────────────────────────────────────────────────
    def capacity_risk_matrix(self) -> list[dict]:
        """Matriz capacidad × severidad de riesgos (para dashboard)."""
        rows = self._q("""
            SELECT
                cap_slug, bc_id,
                SUM(CASE WHEN sev_rank=5 THEN 1 ELSE 0 END) defecto_prod,
                SUM(CASE WHEN sev_rank=4 THEN 1 ELSE 0 END) critico,
                SUM(CASE WHEN sev_rank=3 THEN 1 ELSE 0 END) alto,
                SUM(CASE WHEN sev_rank=2 THEN 1 ELSE 0 END) medio,
                SUM(CASE WHEN sev_rank=1 THEN 1 ELSE 0 END) bajo,
                COUNT(*) total
            FROM risks
            GROUP BY cap_slug
            ORDER BY defecto_prod DESC, critico DESC
        """)
        return [dict(r) for r in rows]

    def top_programs_by_rules(self, n: int = 15) -> list[dict]:
        """Programas con más reglas documentadas."""
        rows = self._q("""
            SELECT programa, COUNT(*) rule_count, bc_id, sistema
            FROM rules
            WHERE programa IS NOT NULL AND programa != ''
            GROUP BY programa
            ORDER BY rule_count DESC
            LIMIT ?
        """, (n,))
        return [dict(r) for r in rows]

    def regulatory_rules_by_cap(self) -> list[dict]:
        """Reglas con norma regulatoria, agrupadas por capacidad."""
        rows = self._q("""
            SELECT bc_id, COUNT(*) n, GROUP_CONCAT(DISTINCT regulador) normas
            FROM rules
            WHERE regulador NOT IN ('N/A', 'N/A — control de integridad', '')
              AND regulador IS NOT NULL
            GROUP BY bc_id
            ORDER BY n DESC
        """)
        return [dict(r) for r in rows]
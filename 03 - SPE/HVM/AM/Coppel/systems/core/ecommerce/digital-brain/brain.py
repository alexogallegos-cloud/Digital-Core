"""
brain.py — Coppel Retail eCommerce Digital Brain · Agent API
Interfaz Python que cualquier agente puede importar para interrogar el sistema.

Uso básico:
    from digital_brain.brain import CoppelRetailBrain
    brain = CoppelRetailBrain()
    print(brain.capabilities())
    print(brain.search('apollo federation'))

O como context manager:
    with CoppelRetailBrain() as brain:
        print(brain.risks('critical'))
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).parent / "brain.db"


class CoppelRetailBrain:
    """
    Agent-facing interface al Digital Brain de Coppel Retail eCommerce.
    Todos los métodos devuelven dicts/listas Python planos — serializables
    y listos para consumir por cualquier agente o LLM.
    """

    def __init__(self, db_path: Path = DB_PATH):
        if not Path(db_path).exists():
            raise FileNotFoundError(
                f"brain.db no encontrado en {db_path}. "
                "Ejecuta primero: python digital-brain/build-brain.py"
            )
        self._path = db_path
        self._conn: sqlite3.Connection | None = None

    # ── Conexión ──────────────────────────────────────────────────────────────

    def _db(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(self._path)
            self._conn.row_factory = sqlite3.Row
            self._conn.execute("PRAGMA query_only=1")
        return self._conn

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ── Helpers ───────────────────────────────────────────────────────────────

    @staticmethod
    def _rows(rows) -> list[dict]:
        return [dict(r) for r in rows]

    @staticmethod
    def _one(row) -> dict | None:
        return dict(row) if row else None

    # ── Metadata ──────────────────────────────────────────────────────────────

    def info(self) -> dict:
        """Metadata del brain (nombre, versión, engagement, KPIs clave)."""
        rows = self._db().execute("SELECT key, value FROM project_info").fetchall()
        return {r["key"]: r["value"] for r in rows}

    # ── Plataformas ───────────────────────────────────────────────────────────

    def platforms(self, status: str | None = None) -> list[dict]:
        """
        Lista todas las plataformas.
        status: filtra por 'legacy' | 'active' | 'migrating' | 'planned' | 'deprecated'
        """
        if status:
            rows = self._db().execute(
                "SELECT * FROM platforms WHERE status=? ORDER BY id", (status,)
            ).fetchall()
        else:
            rows = self._db().execute("SELECT * FROM platforms ORDER BY id").fetchall()
        return self._rows(rows)

    def platform(self, platform_id: str) -> dict | None:
        """Perfil completo de una plataforma por ID."""
        row = self._db().execute(
            "SELECT * FROM platforms WHERE id=?", (platform_id,)
        ).fetchone()
        return self._one(row)

    # ── GCP Projects ─────────────────────────────────────────────────────────

    def gcp_projects(self, env: str | None = None) -> list[dict]:
        """Lista proyectos GCP. env: 'prod' | 'staging' | 'dev'"""
        if env:
            rows = self._db().execute(
                "SELECT * FROM gcp_projects WHERE env=? ORDER BY id", (env,)
            ).fetchall()
        else:
            rows = self._db().execute("SELECT * FROM gcp_projects ORDER BY id").fetchall()
        return self._rows(rows)

    # ── Stack tecnológico ─────────────────────────────────────────────────────

    def stack(self, category: str | None = None, status: str | None = None) -> list[dict]:
        """
        Inventario del stack tecnológico.
        category: 'backend'|'frontend'|'database'|'infrastructure'|
                  'integration'|'observability'|'cdn'|'search'|'payments'|'itsm'|'ai'
        status: 'active'|'migrating'|'deprecated'|'planned'|'unknown'
        """
        clauses, params = [], []
        if category:
            clauses.append("category=?"); params.append(category)
        if status:
            clauses.append("status=?"); params.append(status)
        where = ("WHERE " + " AND ".join(clauses)) if clauses else ""
        rows = self._db().execute(
            f"SELECT * FROM technology_stack {where} ORDER BY category, name", params
        ).fetchall()
        return self._rows(rows)

    def tech(self, tech_id: str) -> dict | None:
        """Perfil de una tecnología por ID."""
        row = self._db().execute(
            "SELECT * FROM technology_stack WHERE id=?", (tech_id,)
        ).fetchone()
        return self._one(row)

    # ── Capacidades de negocio ────────────────────────────────────────────────

    def capabilities(
        self,
        domain: str | None = None,
        criticality: str | None = None,
        migration_status: str | None = None,
    ) -> list[dict]:
        """
        Capacidades de negocio retail.
        domain: 'ecommerce'|'omnichannel'|'fulfillment'|'payments'|
                'customer'|'platform'|'data'|'operations'
        criticality: 'critical'|'high'|'medium'|'low'
        migration_status: 'as-is'|'in-progress'|'done'|'blocked'|'tbd'
        """
        clauses, params = [], []
        if domain:
            clauses.append("domain=?"); params.append(domain)
        if criticality:
            clauses.append("criticality=?"); params.append(criticality)
        if migration_status:
            clauses.append("migration_status=?"); params.append(migration_status)
        where = ("WHERE " + " AND ".join(clauses)) if clauses else ""
        rows = self._db().execute(
            f"SELECT * FROM platform_capabilities {where} ORDER BY criticality, domain, name",
            params,
        ).fetchall()
        return self._rows(rows)

    def capability(self, cap_id: str) -> dict | None:
        """Perfil completo de una capacidad por ID."""
        row = self._db().execute(
            "SELECT * FROM platform_capabilities WHERE id=?", (cap_id,)
        ).fetchone()
        return self._one(row)

    # ── Riesgos ───────────────────────────────────────────────────────────────

    def risks(
        self,
        impact: str | None = None,
        category: str | None = None,
        status: str | None = None,
    ) -> list[dict]:
        """
        Riesgos identificados.
        impact: 'critical'|'high'|'medium'|'low'
        category: 'operational'|'technical'|'security'|'compliance'|
                  'migration'|'commercial'|'performance'
        status: 'open'|'mitigated'|'closed'|'monitoring'
        """
        impact_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
        clauses, params = [], []
        if impact:
            clauses.append("impact=?"); params.append(impact)
        if category:
            clauses.append("category=?"); params.append(category)
        if status:
            clauses.append("status=?"); params.append(status)
        where = ("WHERE " + " AND ".join(clauses)) if clauses else ""
        rows = self._db().execute(
            f"SELECT * FROM risks {where} ORDER BY "
            "CASE impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END",
            params,
        ).fetchall()
        return self._rows(rows)

    def open_risks(self) -> list[dict]:
        """Riesgos abiertos ordenados por impacto."""
        return self.risks(status="open")

    # ── SLOs ──────────────────────────────────────────────────────────────────

    def slos(self, status: str | None = None) -> list[dict]:
        """
        SLOs del ecosistema.
        status: 'meeting'|'at_risk'|'breaching'|'unknown'
        """
        if status:
            rows = self._db().execute(
                "SELECT * FROM slos WHERE status=?", (status,)
            ).fetchall()
        else:
            rows = self._db().execute("SELECT * FROM slos").fetchall()
        return self._rows(rows)

    # ── Integraciones ─────────────────────────────────────────────────────────

    def integrations(
        self,
        criticality: str | None = None,
        status: str | None = None,
    ) -> list[dict]:
        """
        Mapa de integraciones.
        criticality: 'critical'|'high'|'medium'|'low'
        status: 'active'|'migrating'|'planned'|'deprecated'
        """
        clauses, params = [], []
        if criticality:
            clauses.append("criticality=?"); params.append(criticality)
        if status:
            clauses.append("status=?"); params.append(status)
        where = ("WHERE " + " AND ".join(clauses)) if clauses else ""
        rows = self._db().execute(
            f"SELECT * FROM integrations {where} ORDER BY criticality, from_sys", params
        ).fetchall()
        return self._rows(rows)

    # ── Vocabulario ───────────────────────────────────────────────────────────

    def term(self, term: str) -> dict | None:
        """Busca un término exacto en el vocabulario."""
        row = self._db().execute(
            "SELECT * FROM vocabulary WHERE LOWER(term)=LOWER(?)", (term,)
        ).fetchone()
        return self._one(row)

    def vocabulary(self, domain: str | None = None) -> list[dict]:
        """Lista términos del vocabulario, opcionalmente filtrados por dominio."""
        if domain:
            rows = self._db().execute(
                "SELECT * FROM vocabulary WHERE domain=? ORDER BY term", (domain,)
            ).fetchall()
        else:
            rows = self._db().execute("SELECT * FROM vocabulary ORDER BY term").fetchall()
        return self._rows(rows)

    # ── Decisiones ────────────────────────────────────────────────────────────

    def decisions(self) -> list[dict]:
        """Architectural Decision Records del ecosistema Coppel retail."""
        rows = self._db().execute("SELECT * FROM decisions ORDER BY id").fetchall()
        return self._rows(rows)

    # ── Stakeholders ──────────────────────────────────────────────────────────

    def stakeholders(self, org: str | None = None) -> list[dict]:
        """
        Stakeholders clave.
        org: 'coppel'|'accenture'|'publicis-sapient'|'vendor'|'other'
        """
        if org:
            rows = self._db().execute(
                "SELECT * FROM stakeholders WHERE org=?", (org,)
            ).fetchall()
        else:
            rows = self._db().execute("SELECT * FROM stakeholders ORDER BY org, name").fetchall()
        return self._rows(rows)

    # ── Búsqueda full-text ────────────────────────────────────────────────────

    def search(self, query: str, limit: int = 20) -> dict:
        """
        Búsqueda full-text en stack, capacidades, vocabulario y riesgos.
        Devuelve dict con sección por tabla.
        """
        results: dict = {}
        searches = [
            ("stack",        "SELECT id, name, role, category FROM stack_fts WHERE stack_fts MATCH ? LIMIT ?"),
            ("capabilities", "SELECT id, name, description, domain FROM capabilities_fts WHERE capabilities_fts MATCH ? LIMIT ?"),
            ("vocabulary",   "SELECT term, definition, domain FROM vocabulary_fts WHERE vocabulary_fts MATCH ? LIMIT ?"),
            ("risks",        "SELECT id, title, description FROM risks_fts WHERE risks_fts MATCH ? LIMIT ?"),
        ]
        for section, sql in searches:
            try:
                rows = self._db().execute(sql, (query, limit)).fetchall()
                if rows:
                    results[section] = self._rows(rows)
            except Exception:
                pass
        return results

    # ── Resumen ejecutivo ─────────────────────────────────────────────────────

    def summary(self) -> dict:
        """Resumen ejecutivo del ecosistema: conteos, riesgos críticos, SLOs en breach."""
        db = self._db()
        return {
            "platforms":            db.execute("SELECT COUNT(*) FROM platforms").fetchone()[0],
            "gcp_projects":         db.execute("SELECT COUNT(*) FROM gcp_projects").fetchone()[0],
            "stack_technologies":   db.execute("SELECT COUNT(*) FROM technology_stack").fetchone()[0],
            "capabilities_total":   db.execute("SELECT COUNT(*) FROM platform_capabilities").fetchone()[0],
            "capabilities_migrating": db.execute(
                "SELECT COUNT(*) FROM platform_capabilities WHERE migration_status='in-progress'"
            ).fetchone()[0],
            "risks_open":           db.execute(
                "SELECT COUNT(*) FROM risks WHERE status='open'"
            ).fetchone()[0],
            "risks_critical_open":  db.execute(
                "SELECT COUNT(*) FROM risks WHERE impact='critical' AND status='open'"
            ).fetchone()[0],
            "slos_breaching":       db.execute(
                "SELECT COUNT(*) FROM slos WHERE status='breaching'"
            ).fetchone()[0],
            "vocabulary_terms":     db.execute("SELECT COUNT(*) FROM vocabulary").fetchone()[0],
            "business_impact_mxn_per_min": db.execute(
                "SELECT value FROM project_info WHERE key='business_impact_mxn_per_min'"
            ).fetchone()[0],
        }

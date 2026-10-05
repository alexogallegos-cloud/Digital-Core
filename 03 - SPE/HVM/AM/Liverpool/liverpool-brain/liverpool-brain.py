#!/usr/bin/env python3
"""
liverpool-brain.py — Liverpool Federated Brain Agent API
SPE-AM-003 · High Velocity Modernization · Application Modernization

Interfaz estándar de 5 métodos (Regla B5 AM L4):
  coverage()       → estado del brain
  components(...)  → inventario de componentes
  search(query)    → búsqueda fulltext
  rules(comp_id)   → reglas asociadas a un componente
  domains()        → dominios retail R01-R10

Métodos adicionales:
  rtb_capabilities(l1=None)  → capacidades RTB por L1 o todas
  rtb_gap()                  → capacidades sin cobertura
  system_dependencies()      → dependencias cruzadas entre 4 sistemas
  capability_alignment()     → alineación RTB entre brains de sistemas

Uso:
  from liverpool_brain import LiverpoolBrain
  brain = LiverpoolBrain()
  print(brain.coverage())
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).parent / "liverpool-brain.db"

SYSTEM_BRAINS = {
    "SAP": Path(__file__).parent / "../systems/core/SAP/digital-brain/brain.db",
    "Mainframe": Path(__file__).parent / "../systems/core/Mainframe/digital-brain/brain.db",
    "Oracle": Path(__file__).parent / "../systems/processors/Oracle-PL-SQL/digital-brain/brain.db",
    "Digital-Platform": Path(__file__).parent / "../systems/channels/Digital-Platform/digital-brain/brain.db",
}


class LiverpoolBrain:
    """Federated brain for Liverpool Application Modernization (SPE-AM-003)."""

    def __init__(self, db_path=DB_PATH):
        self.db_path = Path(db_path)
        if not self.db_path.exists():
            raise FileNotFoundError(
                f"Brain not built: {self.db_path}\n"
                "Run: python build-liverpool-brain.py"
            )
        self._conn = None

    def _get_conn(self):
        if self._conn is None:
            self._conn = sqlite3.connect(self.db_path)
            self._conn.row_factory = sqlite3.Row
        return self._conn

    def _q(self, sql, params=()):
        cur = self._get_conn().execute(sql, params)
        return [dict(r) for r in cur.fetchall()]

    def _q1(self, sql, params=()):
        cur = self._get_conn().execute(sql, params)
        row = cur.fetchone()
        return dict(row) if row else None

    # ------------------------------------------------------------------ #
    # Standard 5-method interface (Regla B5)
    # ------------------------------------------------------------------ #

    def coverage(self):
        """Estado del brain: totales, sistemas, RTB coverage, fecha build."""
        meta = {r["key"]: r["value"] for r in self._q("SELECT key, value FROM brain_meta")}
        rtb_total = self._get_conn().execute("SELECT COUNT(*) FROM rtb_l3").fetchone()[0]
        rtb_covered = self._get_conn().execute(
            "SELECT COUNT(*) FROM rtb_l3 WHERE liverpool_status IN ('COVERED','CROSS_CUTTING')"
        ).fetchone()[0]
        comp_total = self._get_conn().execute("SELECT COUNT(*) FROM components").fetchone()[0]
        dom_total = self._get_conn().execute("SELECT COUNT(*) FROM retail_domains").fetchone()[0]

        return {
            "project_id": meta.get("project_id", "SPE-AM-003"),
            "client": meta.get("client", "El Puerto de Liverpool S.A.B. de C.V."),
            "brain_version": meta.get("brain_version", "0.1.0"),
            "built_at": meta.get("built_at"),
            "status": meta.get("status", "SCAFFOLD"),
            "rtb": {
                "version": meta.get("rtb_version", "5.0"),
                "total_l3": rtb_total,
                "covered": rtb_covered,
                "uncovered": rtb_total - rtb_covered,
                "coverage_pct": round(rtb_covered / rtb_total * 100, 1) if rtb_total else 0,
            },
            "components": {"total": comp_total},
            "domains": {"total": dom_total, "ids": "R01-R10"},
            "systems": meta.get("systems", "SAP,Mainframe,Oracle,Digital-Platform").split(","),
            "togaf_states": {
                "SAP": meta.get("togaf_state_SAP", "baseline"),
                "Mainframe": meta.get("togaf_state_Mainframe", "baseline"),
                "Oracle": meta.get("togaf_state_Oracle", "baseline"),
                "Digital-Platform": meta.get("togaf_state_Digital_Platform", "transitional"),
            },
        }

    def components(self, source_system=None, domain_id=None,
                   togaf_type=None, status="active", limit=100):
        """Lista componentes con filtros opcionales."""
        sql = "SELECT * FROM components WHERE 1=1"
        params = []
        if source_system:
            sql += " AND source_system = ?"
            params.append(source_system)
        if domain_id:
            sql += " AND (domain_id = ? OR domain_id LIKE ?)"
            params.extend([domain_id, f"%{domain_id}%"])
        if togaf_type:
            sql += " AND togaf_type = ?"
            params.append(togaf_type)
        if status:
            sql += " AND status = ?"
            params.append(status)
        sql += f" LIMIT {int(limit)}"
        return self._q(sql, params)

    def search(self, query, limit=20):
        """Búsqueda fulltext en componentes y capacidades RTB."""
        results = []

        # Search components FTS
        try:
            comp_results = self._q(
                "SELECT c.* FROM components c "
                "JOIN components_fts f ON c.rowid = f.rowid "
                "WHERE components_fts MATCH ? LIMIT ?",
                (query, limit)
            )
            for r in comp_results:
                r["_source"] = "components"
            results.extend(comp_results)
        except Exception:
            pass

        # Search RTB FTS
        try:
            rtb_results = self._q(
                "SELECT r.* FROM rtb_l3 r "
                "JOIN rtb_fts f ON r.rowid = f.rowid "
                "WHERE rtb_fts MATCH ? LIMIT ?",
                (query, limit)
            )
            for r in rtb_results:
                r["_source"] = "rtb_l3"
            results.extend(rtb_results)
        except Exception:
            pass

        return results[:limit]

    def rules(self, component_id):
        """Reglas asociadas a un componente (vacío hasta que los system brains estén poblados)."""
        return self._q(
            "SELECT * FROM components WHERE id = ?",
            (component_id,)
        )

    def domains(self):
        """Dominios retail R01-R10 con conteo de componentes."""
        return self._q("""
            SELECT d.*,
                   COUNT(c.id) as component_count_live
            FROM retail_domains d
            LEFT JOIN components c ON c.domain_id LIKE '%' || d.id || '%'
            GROUP BY d.id
            ORDER BY d.id
        """)

    # ------------------------------------------------------------------ #
    # Extended methods
    # ------------------------------------------------------------------ #

    def rtb_capabilities(self, l1_name=None, status=None):
        """Capacidades RTB (Retail Technology Blueprint), filtradas por L1 o status."""
        sql = "SELECT * FROM rtb_l3 WHERE 1=1"
        params = []
        if l1_name:
            sql += " AND l1_name LIKE ?"
            params.append(f"%{l1_name}%")
        if status:
            sql += " AND liverpool_status = ?"
            params.append(status)
        sql += " ORDER BY id"
        return self._q(sql, params)

    def rtb_gap(self):
        """Capacidades RTB sin cobertura conocida en Liverpool."""
        return self._q(
            "SELECT * FROM rtb_l3 WHERE liverpool_status = 'UNKNOWN' ORDER BY l1_name, l2_name, id"
        )

    def rtb_by_domain(self, domain_id):
        """Capacidades RTB asociadas a un dominio retail."""
        return self._q(
            "SELECT * FROM rtb_l3 WHERE domain_id = ? OR domain_id LIKE ? ORDER BY id",
            (domain_id, f"%{domain_id}%")
        )

    def system_dependencies(self):
        """Dependencias cruzadas entre los 4 sistemas."""
        return self._q(
            "SELECT * FROM cross_dependencies ORDER BY criticality DESC, from_system, to_system"
        )

    def capability_alignment(self):
        """Estado de alineación RTB por sistema (cuáles brains de sistema están construidos)."""
        built = []
        missing = []
        for name, path in SYSTEM_BRAINS.items():
            if path.resolve().exists():
                built.append(name)
            else:
                missing.append(name)
        return {
            "rtb_version": "5.0",
            "total_capabilities": self._get_conn().execute(
                "SELECT COUNT(*) FROM rtb_l3"
            ).fetchone()[0],
            "system_brains_built": built,
            "system_brains_pending": missing,
            "note": (
                "System brains are pending until Etapa 0 RE analysis completes "
                "per system (SAP ABAP / Oracle PL-SQL / Mainframe RE / SW Engineering)."
            ),
        }

    def meta(self):
        """Todos los metadatos del brain."""
        return {r["key"]: r["value"] for r in self._q("SELECT key, value FROM brain_meta")}

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None


# ------------------------------------------------------------------ #
# CLI quick-check
# ------------------------------------------------------------------ #
if __name__ == "__main__":
    brain = LiverpoolBrain()

    print("=== Liverpool Brain — Coverage ===")
    cov = brain.coverage()
    print(json.dumps(cov, indent=2, ensure_ascii=False))

    print("\n=== Retail Domains (R01-R10) ===")
    for d in brain.domains():
        print(f"  {d['id']} {d['name']}: {d['component_count_live']} components")

    print("\n=== RTB Sample (first 5 caps) ===")
    for cap in brain.rtb_capabilities()[:5]:
        print(f"  {cap['id']} | {cap['l1_name']} > {cap['l3_name']}")

    print("\n=== Cross-System Dependencies ===")
    for dep in brain.system_dependencies():
        print(f"  {dep['from_system']} → {dep['to_system']}: {dep['dependency_type']} [{dep['criticality']}]")

    print("\n=== Capability Alignment ===")
    align = brain.capability_alignment()
    print(f"  Built  : {align['system_brains_built']}")
    print(f"  Pending: {align['system_brains_pending']}")

    brain.close()
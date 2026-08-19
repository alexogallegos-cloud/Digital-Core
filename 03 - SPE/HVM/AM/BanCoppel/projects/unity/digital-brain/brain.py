"""
brain.py — Unity Project Brain API
Interfaz de consulta al knowledge incubado del programa Unity.

Uso:
    from brain import UnityBrain
    b = UnityBrain()
    b.coverage()
    b.products(status='live')
    b.search('crédito')
"""

import sqlite3
import json
from pathlib import Path

DB_PATH = Path(__file__).parent / "brain.db"


class UnityBrain:
    def __init__(self, db_path: Path = DB_PATH):
        self._db = str(db_path)

    def _con(self) -> sqlite3.Connection:
        con = sqlite3.connect(self._db)
        con.row_factory = sqlite3.Row
        return con

    # ── Interfaz estándar (5 métodos canónicos AM) ────────────────────────────

    def coverage(self) -> dict:
        """Estado del brain: conteos por dimensión."""
        con = self._con()
        result = {
            "project":   con.execute("SELECT value FROM project_info WHERE key='project_name'").fetchone()[0],
            "platform":  con.execute("SELECT value FROM project_info WHERE key='platform'").fetchone()[0],
            "brain_version": con.execute("SELECT value FROM project_info WHERE key='brain_version'").fetchone()[0],
            "products": {
                "live":     con.execute("SELECT COUNT(*) FROM products WHERE status='live'").fetchone()[0],
                "building": con.execute("SELECT COUNT(*) FROM products WHERE status='building'").fetchone()[0],
                "planned":  con.execute("SELECT COUNT(*) FROM products WHERE status='planned'").fetchone()[0],
            },
            "capabilities": {
                "covered_prod":   con.execute("SELECT COUNT(*) FROM capabilities WHERE status='covered_prod'").fetchone()[0],
                "in_development": con.execute("SELECT COUNT(*) FROM capabilities WHERE status='in_development'").fetchone()[0],
                "planned":        con.execute("SELECT COUNT(*) FROM capabilities WHERE status='planned'").fetchone()[0],
            },
            "decisions": con.execute("SELECT COUNT(*) FROM decisions").fetchone()[0],
            "coexistence_rules": con.execute("SELECT COUNT(*) FROM coexistence_rules").fetchone()[0],
        }
        con.close()
        return result

    def components(self, status: str = None) -> list[dict]:
        """Productos Unity (equivalente a 'components' en la interfaz estándar)."""
        return self.products(status=status)

    def search(self, query: str) -> list[dict]:
        """Búsqueda fulltext sobre productos y capabilities."""
        con = self._con()
        results = []
        for row in con.execute(
            "SELECT p.* FROM products p JOIN products_fts f ON p.rowid = f.rowid WHERE products_fts MATCH ? ORDER BY rank LIMIT 20",
            (query,)
        ):
            r = dict(row)
            r["_source"] = "products"
            results.append(r)
        for row in con.execute(
            "SELECT c.* FROM capabilities c JOIN capabilities_fts f ON c.rowid = f.rowid WHERE capabilities_fts MATCH ? ORDER BY rank LIMIT 20",
            (query,)
        ):
            r = dict(row)
            r["_source"] = "capabilities"
            results.append(r)
        con.close()
        return results

    def rules(self, component_id: str) -> list[dict]:
        """Coexistence rules y migration map para un producto."""
        con = self._con()
        rules = [dict(r) for r in con.execute(
            "SELECT * FROM coexistence_rules WHERE product_id = ?", (component_id,)
        )]
        migrations = [dict(r) for r in con.execute(
            "SELECT * FROM informix_migration_map WHERE unity_product = ?", (component_id,)
        )]
        con.close()
        return rules + migrations

    def domains(self) -> list[dict]:
        """Capabilities ETB agrupadas por status."""
        con = self._con()
        result = [dict(r) for r in con.execute(
            "SELECT status, COUNT(*) as count FROM capabilities GROUP BY status"
        )]
        con.close()
        return result

    # ── Métodos específicos de Unity ──────────────────────────────────────────

    def products(self, status: str = None) -> list[dict]:
        """Lista de productos Unity. status: 'live' | 'building' | 'planned'"""
        con = self._con()
        if status:
            rows = con.execute("SELECT * FROM products WHERE status = ? ORDER BY name", (status,)).fetchall()
        else:
            rows = con.execute("SELECT * FROM products ORDER BY status, name").fetchall()
        con.close()
        return [dict(r) for r in rows]

    def decisions(self, status: str = None) -> list[dict]:
        """ADRs del programa. status: 'proposed' | 'accepted'"""
        con = self._con()
        if status:
            rows = con.execute("SELECT * FROM decisions WHERE status = ? ORDER BY id", (status,)).fetchall()
        else:
            rows = con.execute("SELECT * FROM decisions ORDER BY id").fetchall()
        con.close()
        return [dict(r) for r in rows]

    def migration_gap(self) -> dict:
        """Cuántas capabilities Informix no tienen mapping a Unity aún."""
        con = self._con()
        total    = con.execute("SELECT COUNT(*) FROM informix_migration_map").fetchone()[0]
        done     = con.execute("SELECT COUNT(*) FROM informix_migration_map WHERE migration_status='done'").fetchone()[0]
        unknown  = con.execute("SELECT COUNT(*) FROM informix_migration_map WHERE migration_fate='unknown'").fetchone()[0]
        con.close()
        return {"total_mapped": total, "done": done, "unknown": unknown, "gap": total - done}

    def add_product(self, id: str, name: str, description: str,
                    status: str, temenos_module: str = None,
                    launch_date: str = None, coexistence_mode: str = "unknown",
                    informix_domains: list = None, notes: str = None) -> None:
        """Registra un producto Unity en el brain."""
        con = self._con()
        con.execute("""
            INSERT OR REPLACE INTO products
                (id, name, description, status, launch_date, temenos_module,
                 informix_domains, coexistence_mode, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (id, name, description, status, launch_date, temenos_module,
              json.dumps(informix_domains or []), coexistence_mode, notes))
        con.commit()
        con.close()
        print(f"  Producto '{name}' [{status}] registrado en brain.db")


if __name__ == "__main__":
    b = UnityBrain()
    print(json.dumps(b.coverage(), indent=2, ensure_ascii=False))

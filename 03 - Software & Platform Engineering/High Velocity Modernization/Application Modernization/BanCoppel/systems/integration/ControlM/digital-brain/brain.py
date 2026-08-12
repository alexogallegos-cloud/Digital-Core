"""
brain.py — Control-M Brain · Agent API
Interfaz Python para interrogar el brain de Control-M/Malla Batch de BanCoppel.

Uso:
    from brain import CTMBrain
    with CTMBrain() as b:
        print(b.coverage())
        print(b.flows())
        print(b.jobs_by_domain('D11'))
"""

import sqlite3, json
from pathlib import Path
from typing import Optional

DB_PATH = Path(__file__).parent / 'brain.db'


class CTMBrain:
    """Agent-facing interface al Digital Brain de Control-M BanCoppel."""

    def __init__(self, db_path: Path = DB_PATH):
        if not Path(db_path).exists():
            raise FileNotFoundError(
                f"brain.db no encontrado en {db_path}. "
                "Ejecuta: python digital-brain/build-brain.py"
            )
        self._path = db_path
        self._conn: Optional[sqlite3.Connection] = None

    def _db(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(self._path)
            self._conn.row_factory = sqlite3.Row
        return self._conn

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None

    def __enter__(self): return self
    def __exit__(self, *_): self.close()

    @staticmethod
    def _rows(rows) -> list[dict]:
        return [dict(r) for r in rows]

    # ── Interfaz estándar (Regla AM B1) ──────────────────────────────────────

    def coverage(self) -> dict:
        """Estado del brain — N entidades, desglose por tipo y sitio."""
        db = self._db()
        total   = db.execute('SELECT COUNT(*) FROM jobs').fetchone()[0]
        ifx     = db.execute('SELECT COUNT(*) FROM jobs WHERE is_informix=1').fetchone()[0]
        unity   = db.execute('SELECT COUNT(*) FROM jobs WHERE is_unity=1').fetchone()[0]
        sp_hints= db.execute('SELECT COUNT(*) FROM sp_hints').fetchone()[0]
        flows   = db.execute('SELECT COUNT(*) FROM flows').fetchone()[0]
        by_type = self._rows(db.execute(
            'SELECT job_type, COUNT(*) n FROM jobs GROUP BY job_type ORDER BY n DESC'
        ).fetchall())
        by_site = self._rows(db.execute(
            'SELECT site, COUNT(*) n FROM jobs GROUP BY site ORDER BY n DESC'
        ).fetchall())
        return {
            'total_jobs': total,
            'informix_jobs': ifx,
            'unity_jobs': unity,
            'sp_hints': sp_hints,
            'flows': flows,
            'by_type': by_type,
            'by_site': by_site,
        }

    def components(self, job_type: str = None, folder: str = None,
                   informix_only: bool = False, limit: int = 200) -> list[dict]:
        """Catálogo de jobs, filtrable."""
        where, params = [], []
        if job_type:
            where.append('job_type=?'); params.append(job_type)
        if folder:
            where.append('folder=?'); params.append(folder)
        if informix_only:
            where.append('is_informix=1')
        clause = ('WHERE ' + ' AND '.join(where)) if where else ''
        rows = self._db().execute(
            f'SELECT * FROM jobs {clause} ORDER BY folder, job_name LIMIT ?',
            params + [limit]
        ).fetchall()
        return self._rows(rows)

    def search(self, query: str, limit: int = 50) -> list[dict]:
        """Búsqueda por texto en nombre, descripción y script de jobs."""
        q = f'%{query}%'
        rows = self._db().execute(
            '''SELECT * FROM jobs
               WHERE job_name LIKE ? OR description LIKE ? OR mem_name LIKE ?
               ORDER BY is_informix DESC, job_name
               LIMIT ?''',
            (q, q, q, limit)
        ).fetchall()
        return self._rows(rows)

    def rules(self, component_id: str) -> list[dict]:
        """Reglas/SPs referenciados por un job (SP hints)."""
        rows = self._db().execute(
            'SELECT * FROM sp_hints WHERE job_id=? ORDER BY source, sp_name_hint',
            (component_id,)
        ).fetchall()
        return self._rows(rows)

    def domains(self) -> list[dict]:
        """Dominios de Informix cubiertos por la malla batch, con conteo de jobs."""
        rows = self._db().execute(
            '''SELECT domain_id, COUNT(*) n
               FROM jobs WHERE is_informix=1 AND domain_id IS NOT NULL
               GROUP BY domain_id ORDER BY n DESC'''
        ).fetchall()
        return self._rows(rows)

    # ── Métodos específicos de Control-M ────────────────────────────────────

    def flows(self, unity_only: bool = False) -> list[dict]:
        """Procesos batch (folders CTM) con estadísticas agregadas."""
        clause = 'WHERE unity=1' if unity_only else ''
        rows = self._db().execute(
            f'SELECT * FROM flows {clause} ORDER BY informix_count DESC, job_count DESC'
        ).fetchall()
        return self._rows(rows)

    def jobs_by_domain(self, domain_id: str, site: str = 'CLN',
                       limit: int = 200) -> list[dict]:
        """Jobs de la malla batch que corresponden a un dominio Informix."""
        rows = self._db().execute(
            '''SELECT job_name, job_type, folder, host, description, mem_name, has_sp_hint
               FROM jobs
               WHERE domain_id=? AND site=? AND is_informix=1
               ORDER BY folder, job_name
               LIMIT ?''',
            (domain_id.upper(), site.upper(), limit)
        ).fetchall()
        return self._rows(rows)

    def sp_hints(self, sp_name: str = None, limit: int = 200) -> list[dict]:
        """Jobs que referencian SPs de Informix por nombre.
        Si sp_name=None, retorna todos. Útil para cruzar con BCOPBrain.
        """
        if sp_name:
            rows = self._db().execute(
                '''SELECT j.job_name, j.folder, j.description, j.mem_name, h.source
                   FROM sp_hints h JOIN jobs j ON h.job_id=j.id
                   WHERE h.sp_name_hint LIKE ?
                   ORDER BY j.folder, j.job_name LIMIT ?''',
                (f'%{sp_name.lower()}%', limit)
            ).fetchall()
        else:
            rows = self._db().execute(
                '''SELECT h.sp_name_hint, COUNT(*) n
                   FROM sp_hints h GROUP BY h.sp_name_hint ORDER BY n DESC LIMIT ?''',
                (limit,)
            ).fetchall()
        return self._rows(rows)

    def unity_jobs(self) -> list[dict]:
        """Jobs de la nueva malla Unity (SmartVista, etc.)."""
        rows = self._db().execute(
            '''SELECT job_name, job_type, folder, host, description, mem_name
               FROM jobs WHERE is_unity=1 ORDER BY folder, job_name'''
        ).fetchall()
        return self._rows(rows)

    def etb_version(self) -> str:
        """Control-M no implementa ETB (no es sistema bancario core).
        Retorna 'n/a' — bank-brain no requiere alineación ETB de este brain.
        """
        return 'n/a'

    def cross_dependencies(self, direction: str = None) -> list[dict]:
        """Dependencias cross-sistema desde la perspectiva de Control-M (Regla B5 AM)."""
        sel = 'SELECT * FROM cross_dependencies'
        if direction:
            rows = self._db().execute(
                f'{sel} WHERE direction=? ORDER BY criticality, other_system',
                (direction,)
            ).fetchall()
        else:
            rows = self._db().execute(
                f'{sel} ORDER BY direction, criticality, other_system'
            ).fetchall()
        return self._rows(rows)


# ── CLI rápido ────────────────────────────────────────────────────────────────
def _cli():
    b = CTMBrain()
    print('=== CTM Brain CLI ===')

    cov = b.coverage()
    print(f'\n-- Cobertura --')
    print(f'  Total jobs     : {cov["total_jobs"]:,}')
    print(f'  En Informix    : {cov["informix_jobs"]:,}')
    print(f'  Unity (nueva)  : {cov["unity_jobs"]:,}')
    print(f'  SP hints       : {cov["sp_hints"]:,}')
    print(f'  Flows/carpetas : {cov["flows"]:,}')

    print(f'\n-- Por tipo de job --')
    for t in cov['by_type']:
        print(f'  {t["job_type"] or "(vacío)":<30} {t["n"]:>5,}')

    print(f'\n-- Flows principales --')
    for f in b.flows()[:15]:
        unity_tag = ' [UNITY]' if f['unity'] else ''
        print(f'  {f["folder"]:<40} {f["job_count"]:>4} jobs  '
              f'({f["informix_count"]} Informix){unity_tag}')

    print(f'\n-- Jobs Unity (nueva malla) --')
    for j in b.unity_jobs():
        print(f'  {j["job_name"]:<45} {j["host"]}')

    print(f'\n-- Dominio D11 (Cobranza) — muestra --')
    for j in b.jobs_by_domain('D11')[:10]:
        print(f'  {j["job_name"]:<45} {j["description"][:60]}')

    print(f'\n-- SP Hints más frecuentes --')
    for h in b.sp_hints()[:15]:
        print(f'  {h["sp_name_hint"]:<45} {h["n"]:>4} referencias')

    print(f'\n-- Dependencias cross-sistema --')
    for d in b.cross_dependencies():
        print(f'  {d["direction"]:<10} --[{d["dependency_type"]}]--> '
              f'{d["other_system"]:<12} ({d["criticality"]})')
        print(f'    {d["description"][:80]}')

    b.close()


if __name__ == '__main__':
    _cli()

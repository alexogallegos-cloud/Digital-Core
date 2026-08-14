#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
brain.py — GENCore Digital Brain · Agent API
Expone el conocimiento de brain.db mediante GENCOREBrain.

Uso:
    from digital_brain.brain import GENCOREBrain
    brain = GENCOREBrain()
    print(brain.stats())
    print(brain.rules_of('CL_DB_TVARVC'))
    print(brain.search_rules('crédito'))

GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""

import json
import re
import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / 'brain.db'


class GENCOREBrain:
    """API semántica sobre brain.db de Gentera SAP ABAP."""

    def __init__(self, db_path: Path | str = DB_PATH):
        self._path = Path(db_path)
        self._conn: sqlite3.Connection | None = None

    # ── Conexión lazy ─────────────────────────────────────────────────────────

    def _db(self) -> sqlite3.Connection:
        if self._conn is None:
            if not self._path.exists():
                raise FileNotFoundError(
                    f'brain.db no encontrado en {self._path}.\n'
                    'Corre: python digital-brain/build-brain.py'
                )
            self._conn = sqlite3.connect(self._path)
            self._conn.row_factory = sqlite3.Row
        return self._conn

    def close(self) -> None:
        if self._conn:
            self._conn.close()
            self._conn = None

    # ── Helpers ──────────────────────────────────────────────────────────────

    @staticmethod
    def _rows(rows) -> list[dict]:
        return [dict(r) for r in rows]

    def _resolve_obj(self, name: str) -> str:
        """Convierte nombre corto → ID canónico (mayor fan_in si hay duplicados)."""
        # Exact match first
        row = self._db().execute('SELECT id FROM objects WHERE id=?', (name,)).fetchone()
        if row:
            return row['id']
        # Case-insensitive partial match (nombre short)
        rows = self._db().execute(
            'SELECT id, fan_in FROM objects WHERE nombre=? OR id LIKE ? ORDER BY fan_in DESC',
            (name, f'%/{name}')
        ).fetchall()
        if rows:
            return rows[0]['id']
        # Try with namespace strip
        rows = self._db().execute(
            "SELECT id, fan_in FROM objects WHERE nombre LIKE ? ORDER BY fan_in DESC LIMIT 1",
            (f'%{name}%',)
        ).fetchall()
        return rows[0]['id'] if rows else name

    @staticmethod
    def _parse_json(d: dict, field: str):
        val = d.get(field)
        if isinstance(val, str):
            try:
                return json.loads(val)
            except Exception:
                return val
        return val

    # ── Estadísticas globales ─────────────────────────────────────────────────

    def stats(self) -> dict:
        """Resumen del brain.db: conteos por entidad y distribución de reglas."""
        db = self._db()
        by_tipo   = {r[0]: r[1] for r in db.execute(
            "SELECT tipo, COUNT(*) FROM rules GROUP BY tipo ORDER BY COUNT(*) DESC"
        ).fetchall()}
        by_riesgo = {r[0]: r[1] for r in db.execute(
            "SELECT riesgo, COUNT(*) FROM rules GROUP BY riesgo ORDER BY COUNT(*) DESC"
        ).fetchall()}
        by_reg = {r[0]: r[1] for r in db.execute(
            "SELECT reg, COUNT(*) FROM rules WHERE reg IS NOT NULL GROUP BY reg ORDER BY COUNT(*) DESC"
        ).fetchall()}
        by_domain = {r[0]: r[1] for r in db.execute(
            "SELECT dominio, COUNT(*) FROM objects GROUP BY dominio ORDER BY COUNT(*) DESC"
        ).fetchall()}
        return {
            'objects':        db.execute('SELECT COUNT(*) FROM objects').fetchone()[0],
            'object_calls':   db.execute('SELECT COUNT(*) FROM object_calls').fetchone()[0],
            'sql_access':     db.execute('SELECT COUNT(*) FROM sql_access').fetchone()[0],
            'rules':          db.execute('SELECT COUNT(*) FROM rules').fetchone()[0],
            'terms':          db.execute('SELECT COUNT(*) FROM terms').fetchone()[0],
            'domains':        db.execute('SELECT COUNT(*) FROM domains').fetchone()[0],
            'authors':        db.execute('SELECT COUNT(*) FROM authors').fetchone()[0],
            'rules_by_tipo':  by_tipo,
            'rules_by_riesgo':by_riesgo,
            'rules_by_reg':   by_reg,
            'objects_by_domain': by_domain,
        }

    # ── Objetos ───────────────────────────────────────────────────────────────

    def objects(self, domain: str | None = None, tipo: str | None = None,
                limit: int = 200) -> list[dict]:
        """Lista objetos ABAP con filtro opcional por dominio BIAN o tipo."""
        filters = []
        params: list = []
        if domain:
            filters.append('o.dominio=?')
            params.append(domain.upper())
        if tipo:
            filters.append('o.tipo=?')
            params.append(tipo.lower())
        where = ('WHERE ' + ' AND '.join(filters)) if filters else ''
        rows = self._db().execute(f'''
            SELECT o.id, o.nombre, o.tipo, o.loc, o.dominio, o.sap_module,
                   o.fan_in, o.fan_out, o.n_metodos, o.n_tipos, o.biz,
                   o.autor, o.usuario_sap, o.fecha_creacion, o.is_singleton,
                   (SELECT COUNT(*) FROM rules r WHERE r.obj_id = o.id) AS n_rules
            FROM objects o
            {where}
            ORDER BY o.fan_in DESC, o.n_metodos DESC
            LIMIT ?
        ''', params + [limit]).fetchall()
        return self._rows(rows)

    def object_detail(self, obj_name: str) -> dict | None:
        """Detalle completo de un objeto: métodos, reglas, SQL, llamadas."""
        oid  = self._resolve_obj(obj_name)
        row  = self._db().execute('SELECT * FROM objects WHERE id=?', (oid,)).fetchone()
        if not row:
            return None
        detail = dict(row)
        detail['rules']      = self.rules_of(oid)
        detail['callees']    = self.callees_of(oid)
        detail['callers']    = self.callers_of(oid)
        detail['sql_access'] = self._rows(
            self._db().execute('SELECT * FROM sql_access WHERE obj_id=?', (oid,)).fetchall()
        )
        return detail

    # ── Grafo de llamadas ─────────────────────────────────────────────────────

    def callers_of(self, obj_name: str, limit: int = 50) -> list[dict]:
        """Objetos que llaman a este objeto (fan_in)."""
        oid  = self._resolve_obj(obj_name)
        rows = self._db().execute('''
            SELECT o.id, o.nombre, o.tipo, o.fan_in, o.fan_out, o.dominio,
                   oc.call_type
            FROM object_calls oc
            JOIN objects o ON oc.from_obj = o.id
            WHERE oc.to_obj = ?
            ORDER BY o.fan_in DESC
            LIMIT ?
        ''', (oid, limit)).fetchall()
        return self._rows(rows)

    def callees_of(self, obj_name: str, limit: int = 50) -> list[dict]:
        """Objetos que este objeto llama (fan_out)."""
        oid  = self._resolve_obj(obj_name)
        rows = self._db().execute('''
            SELECT o.id, o.nombre, o.tipo, o.fan_in, o.fan_out, o.dominio,
                   oc.call_type
            FROM object_calls oc
            LEFT JOIN objects o ON oc.to_obj = o.id
            WHERE oc.from_obj = ?
            ORDER BY o.fan_in DESC NULLS LAST
            LIMIT ?
        ''', (oid, limit)).fetchall()
        return self._rows(rows)

    # ── Reglas de negocio ─────────────────────────────────────────────────────

    def rules_of(self, obj_name: str, tipo: str | None = None,
                 riesgo: str | None = None) -> list[dict]:
        """Reglas de negocio de un objeto, opcionalmente filtradas por tipo o riesgo."""
        oid     = self._resolve_obj(obj_name)
        filters = ['obj_id=?']
        params: list = [oid]
        if tipo:
            filters.append('tipo=?')
            params.append(tipo.upper())
        if riesgo:
            filters.append('riesgo=?')
            params.append(riesgo.upper())
        rows = self._db().execute(f'''
            SELECT * FROM rules
            WHERE {' AND '.join(filters)}
            ORDER BY linea
        ''', params).fetchall()
        return self._rows(rows)

    def rules_by_type(self, tipo: str, limit: int = 100) -> list[dict]:
        """Todas las reglas de un tipo (VALIDACION, FLUJO, MANEJO_ERROR, etc.)."""
        rows = self._db().execute('''
            SELECT r.*, o.nombre as obj_nombre, o.dominio
            FROM rules r
            JOIN objects o ON r.obj_id = o.id
            WHERE r.tipo=?
            ORDER BY o.fan_in DESC, r.linea
            LIMIT ?
        ''', (tipo.upper(), limit)).fetchall()
        return self._rows(rows)

    def regulatory_rules(self, reg_tag: str | None = None, limit: int = 100) -> list[dict]:
        """Reglas con etiqueta regulatoria (CNBV, IFRS, SAT, PLD, BANXICO...)."""
        if reg_tag:
            rows = self._db().execute('''
                SELECT r.*, o.nombre as obj_nombre, o.dominio
                FROM rules r JOIN objects o ON r.obj_id = o.id
                WHERE r.reg=?
                ORDER BY r.riesgo DESC, o.fan_in DESC
                LIMIT ?
            ''', (reg_tag.upper(), limit)).fetchall()
        else:
            rows = self._db().execute('''
                SELECT r.*, o.nombre as obj_nombre, o.dominio
                FROM rules r JOIN objects o ON r.obj_id = o.id
                WHERE r.reg IS NOT NULL
                ORDER BY r.reg, r.riesgo DESC, o.fan_in DESC
                LIMIT ?
            ''', (limit,)).fetchall()
        return self._rows(rows)

    def high_risk_rules(self, limit: int = 50) -> list[dict]:
        """Reglas con riesgo de equivalencia ALTO — críticas para migración."""
        rows = self._db().execute('''
            SELECT r.*, o.nombre as obj_nombre, o.dominio, o.fan_in
            FROM rules r
            JOIN objects o ON r.obj_id = o.id
            WHERE r.riesgo = 'ALTO'
            ORDER BY o.fan_in DESC, r.linea
            LIMIT ?
        ''', (limit,)).fetchall()
        return self._rows(rows)

    # ── Búsqueda FTS ──────────────────────────────────────────────────────────

    def search_rules(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda full-text sobre reglas (condicion + business_name + metodo)."""
        try:
            rows = self._db().execute('''
                SELECT r.*, o.nombre as obj_nombre, o.dominio,
                       highlight(rules_fts, 2, '<b>', '</b>') as condicion_hl,
                       highlight(rules_fts, 3, '<b>', '</b>') as business_name_hl
                FROM rules_fts
                JOIN rules r ON rules_fts.rowid = r.rowid
                JOIN objects o ON r.obj_id = o.id
                WHERE rules_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            ''', (query, limit)).fetchall()
        except sqlite3.OperationalError:
            # Fallback LIKE si FTS no disponible
            rows = self._db().execute('''
                SELECT r.*, o.nombre as obj_nombre, o.dominio
                FROM rules r JOIN objects o ON r.obj_id = o.id
                WHERE r.condicion LIKE ? OR r.business_name LIKE ? OR r.metodo LIKE ?
                ORDER BY o.fan_in DESC
                LIMIT ?
            ''', (f'%{query}%', f'%{query}%', f'%{query}%', limit)).fetchall()
        return self._rows(rows)

    def search_objects(self, query: str, limit: int = 20) -> list[dict]:
        """Búsqueda full-text sobre objetos ABAP (nombre + biz + dominio)."""
        try:
            rows = self._db().execute('''
                SELECT o.*,
                       (SELECT COUNT(*) FROM rules r WHERE r.obj_id = o.id) AS n_rules,
                       highlight(objects_fts, 1, '<b>', '</b>') as nombre_hl
                FROM objects_fts
                JOIN objects o ON objects_fts.rowid = o.rowid
                WHERE objects_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            ''', (query, limit)).fetchall()
        except sqlite3.OperationalError:
            rows = self._db().execute('''
                SELECT o.*, (SELECT COUNT(*) FROM rules r WHERE r.obj_id = o.id) AS n_rules
                FROM objects o
                WHERE o.nombre LIKE ? OR o.id LIKE ? OR o.biz LIKE ?
                ORDER BY o.fan_in DESC
                LIMIT ?
            ''', (f'%{query}%', f'%{query}%', f'%{query}%', limit)).fetchall()
        return self._rows(rows)

    def search_terms(self, query: str, limit: int = 30) -> list[dict]:
        """Búsqueda full-text en el vocabulario de negocio."""
        try:
            rows = self._db().execute('''
                SELECT t.*
                FROM terms_fts
                JOIN terms t ON terms_fts.rowid = t.rowid
                WHERE terms_fts MATCH ?
                ORDER BY rank
                LIMIT ?
            ''', (query, limit)).fetchall()
        except sqlite3.OperationalError:
            rows = self._db().execute('''
                SELECT * FROM terms
                WHERE term LIKE ? OR mean LIKE ?
                ORDER BY fn DESC
                LIMIT ?
            ''', (f'%{query}%', f'%{query}%', limit)).fetchall()
        return self._rows(rows)

    # ── Dominios ──────────────────────────────────────────────────────────────

    def domain_objects(self, domain: str, limit: int = 100) -> list[dict]:
        """Objetos que pertenecen a un dominio BIAN."""
        rows = self._db().execute('''
            SELECT o.id, o.nombre, o.tipo, o.sap_module, o.fan_in, o.fan_out,
                   o.n_metodos, o.biz, o.is_singleton,
                   (SELECT COUNT(*) FROM rules r WHERE r.obj_id = o.id) AS n_rules
            FROM objects o
            WHERE o.dominio = ?
            ORDER BY o.fan_in DESC, o.n_metodos DESC
            LIMIT ?
        ''', (domain.upper(), limit)).fetchall()
        return self._rows(rows)

    def domains(self) -> list[dict]:
        """Lista de dominios BIAN con conteo de objetos y reglas."""
        rows = self._db().execute('''
            SELECT d.id, d.nombre, d.bian_ref, d.descripcion,
                   COUNT(DISTINCT o.id)   AS n_objects,
                   COUNT(DISTINCT r.id)   AS n_rules
            FROM domains d
            LEFT JOIN objects o ON o.dominio = d.id
            LEFT JOIN rules   r ON r.obj_id  = o.id
            GROUP BY d.id
            ORDER BY n_objects DESC, n_rules DESC
        ''').fetchall()
        return self._rows(rows)

    # ── Autores ───────────────────────────────────────────────────────────────

    def authors(self) -> list[dict]:
        """Lista de autores identificados con sus métricas."""
        rows = self._db().execute('''
            SELECT a.uid, a.nombre, a.n_objetos,
                   a.fecha_primera, a.fecha_ultima, a.tickets,
                   GROUP_CONCAT(DISTINCT o.dominio) AS dominios
            FROM authors a
            LEFT JOIN object_authors oa ON oa.uid = a.uid
            LEFT JOIN objects        o  ON o.id   = oa.obj_id
            GROUP BY a.uid
            ORDER BY a.n_objetos DESC
        ''').fetchall()
        result = []
        for r in rows:
            d = dict(r)
            d['tickets'] = self._parse_json(d, 'tickets') or []
            result.append(d)
        return result

    # ── Flujo de un objeto ────────────────────────────────────────────────────

    def flow_diagram(self, obj_name: str, depth: int = 2) -> dict:
        """
        Árbol de llamadas recursivo para un objeto ABAP.
        Retorna: root (árbol), mermaid (flowchart TD), stats.
        """
        oid = self._resolve_obj(obj_name)
        db  = self._db()

        nodes: dict[str, dict] = {}
        edges: list[tuple[str, str, str]] = []
        queue  = [(oid, 0)]
        visited: set[str] = set()

        while queue:
            cur_id, cur_depth = queue.pop(0)
            if cur_id in visited:
                continue
            visited.add(cur_id)

            row = db.execute('SELECT * FROM objects WHERE id=?', (cur_id,)).fetchone()
            if row:
                d = dict(row)
                d['rules'] = self.rules_of(cur_id)
            else:
                d = {'id': cur_id, 'nombre': cur_id, 'tipo': 'external',
                     'dominio': 'EXTERNO', 'biz': None, 'rules': []}
            nodes[cur_id] = d

            if cur_depth < depth:
                callee_rows = db.execute('''
                    SELECT to_obj, call_type FROM object_calls WHERE from_obj=?
                ''', (cur_id,)).fetchall()
                for cr in callee_rows:
                    child_id  = cr['to_obj']
                    call_type = cr['call_type']
                    if child_id != cur_id:
                        edges.append((cur_id, child_id, call_type))
                        if child_id not in visited:
                            queue.append((child_id, cur_depth + 1))

        if oid not in nodes:
            return {'error': f'Objeto no encontrado: {obj_name}'}

        # Árbol desde raíz
        children_index: dict[str, list[str]] = {}
        for from_id, to_id, _ in edges:
            children_index.setdefault(from_id, []).append(to_id)

        def build_tree(nid: str, seen: set) -> dict:
            node = dict(nodes[nid])
            node['children'] = []
            if nid in seen:
                node['_ref'] = True
                return node
            seen.add(nid)
            for child_id in children_index.get(nid, []):
                if child_id in nodes:
                    node['children'].append(build_tree(child_id, seen))
            return node

        root = build_tree(oid, set())

        # Mermaid
        def _mid(nid: str) -> str:
            return re.sub(r'[^a-zA-Z0-9]', '_', nid)

        def _lbl(n: dict) -> str:
            name = n.get('nombre', n.get('id', ''))
            biz  = (n.get('biz') or '').replace('"', "'")[:45]
            typ  = n.get('tipo', '')
            if biz:
                return f'"{name}<br/>{biz}"'
            return f'"{name} [{typ}]"'

        lines = ['flowchart TD',
                 '  classDef singleton fill:#6A1B9A,color:#fff',
                 '  classDef external  fill:#546E7A,color:#fff',
                 '  classDef class_    fill:#1565C0,color:#fff',
                 '  classDef prog      fill:#2E7D32,color:#fff',
                 '  classDef fugr      fill:#E65100,color:#fff']

        rendered: set[str] = set()
        for nid, n in nodes.items():
            mid = _mid(nid)
            if mid not in rendered:
                lbl  = _lbl(n)
                tipo = n.get('tipo', '')
                if n.get('is_singleton'):
                    shape = f'{mid}(({lbl}))'
                    cls   = 'singleton'
                elif tipo in ('', 'external'):
                    shape = f'{mid}[/{lbl}/]'
                    cls   = 'external'
                elif tipo == 'class':
                    shape = f'{mid}({lbl})'
                    cls   = 'class_'
                elif tipo == 'prog':
                    shape = f'{mid}[{lbl}]'
                    cls   = 'prog'
                elif tipo == 'fugr':
                    shape = f'{mid}[[{lbl}]]'
                    cls   = 'fugr'
                else:
                    shape = f'{mid}[{lbl}]'
                    cls   = 'class_'
                lines.append(f'  {shape}')
                lines.append(f'  class {mid} {cls}')
                rendered.add(mid)

        seen_edges: set[tuple[str, str]] = set()
        for from_id, to_id, call_type in edges:
            if from_id in nodes and to_id in nodes:
                e = (_mid(from_id), _mid(to_id))
                if e not in seen_edges:
                    arrow = '-->' if call_type in ('call_function', 'instantiate', '') else '-.->'
                    lines.append(f'  {e[0]} {arrow} {e[1]}')
                    seen_edges.add(e)

        total_rules   = sum(len(n.get('rules', [])) for n in nodes.values())
        unique_domains = sorted({n.get('dominio', '') for n in nodes.values() if n.get('dominio')})

        return {
            'root':    root,
            'mermaid': '\n'.join(lines),
            'stats': {
                'total_nodes':    len(nodes),
                'total_edges':    len(edges),
                'total_rules':    total_rules,
                'unique_domains': unique_domains,
                'depth':          depth,
            },
        }

    # ── Análisis de migración ─────────────────────────────────────────────────

    def migration_candidates(self, domain: str | None = None,
                              min_rules: int = 1,
                              limit: int = 50) -> list[dict]:
        """
        Objetos candidatos para análisis de migración:
        ordenados por cantidad de reglas de negocio y fan_in.
        """
        dom_filter = 'AND o.dominio=?' if domain else ''
        params: list = []
        if domain:
            params.append(domain.upper())
        rows = self._db().execute(f'''
            SELECT * FROM (
                SELECT o.id, o.nombre, o.tipo, o.dominio, o.sap_module,
                       o.fan_in, o.fan_out, o.loc, o.n_metodos, o.biz,
                       COUNT(r.id)                                          AS n_rules,
                       SUM(CASE WHEN r.riesgo='ALTO'  THEN 1 ELSE 0 END)   AS n_alto,
                       SUM(CASE WHEN r.riesgo='MEDIO' THEN 1 ELSE 0 END)   AS n_medio,
                       SUM(CASE WHEN r.reg IS NOT NULL THEN 1 ELSE 0 END)  AS n_reg,
                       GROUP_CONCAT(DISTINCT r.reg) AS regulaciones
                FROM objects o
                JOIN rules r ON r.obj_id = o.id
                WHERE 1=1 {dom_filter}
                GROUP BY o.id
            )
            WHERE n_rules >= ?
            ORDER BY n_rules DESC, n_alto DESC, fan_in DESC
            LIMIT ?
        ''', params + [min_rules, limit]).fetchall()
        return self._rows(rows)

    def risk_summary(self) -> dict:
        """
        Resumen de riesgo de equivalencia para la migración:
        qué objetos concentran mayor riesgo.
        """
        db = self._db()
        top_risk = self._rows(db.execute('''
            SELECT o.id, o.nombre, o.dominio, o.fan_in,
                   COUNT(r.id) AS n_rules,
                   SUM(CASE WHEN r.riesgo='ALTO'  THEN 1 ELSE 0 END) AS n_alto,
                   SUM(CASE WHEN r.riesgo='MEDIO' THEN 1 ELSE 0 END) AS n_medio,
                   SUM(CASE WHEN r.reg IS NOT NULL THEN 1 ELSE 0 END) AS n_reg
            FROM objects o
            JOIN rules r ON r.obj_id = o.id
            GROUP BY o.id
            ORDER BY n_alto DESC, n_medio DESC, n_rules DESC
            LIMIT 10
        ''').fetchall())

        reg_dist = {r[0]: r[1] for r in db.execute(
            "SELECT reg, COUNT(*) FROM rules WHERE reg IS NOT NULL GROUP BY reg ORDER BY COUNT(*) DESC"
        ).fetchall()}

        return {
            'top_risk_objects':  top_risk,
            'regulatory_dist':   reg_dist,
            'total_alto':        db.execute("SELECT COUNT(*) FROM rules WHERE riesgo='ALTO'").fetchone()[0],
            'total_medio':       db.execute("SELECT COUNT(*) FROM rules WHERE riesgo='MEDIO'").fetchone()[0],
            'total_bajo':        db.execute("SELECT COUNT(*) FROM rules WHERE riesgo='BAJO'").fetchone()[0],
            'total_regulatory':  db.execute("SELECT COUNT(*) FROM rules WHERE reg IS NOT NULL").fetchone()[0],
        }
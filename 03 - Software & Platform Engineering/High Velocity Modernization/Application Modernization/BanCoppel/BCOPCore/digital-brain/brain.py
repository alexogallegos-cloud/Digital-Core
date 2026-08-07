"""
brain.py — BCOPCore Digital Brain · Agent API
Interfaz Python que cualquier agente puede importar para interrogar el sistema.

Uso básico:
    from digital_brain.brain import BCOPBrain
    brain = BCOPBrain()
    print(brain.sp('cargo_ref'))
    print(brain.search('scoring crediticio'))

O como context manager:
    with BCOPBrain() as brain:
        print(brain.souls())
"""

import sqlite3, json, re
from pathlib import Path

DB_PATH = Path(__file__).parent / 'brain.db'


class BCOPBrain:
    """
    Agent-facing interface al Digital Brain de BCOPCore.
    Todos los métodos devuelven dicts/listas Python planos — serializables y
    listos para consumir por cualquier agente o LLM.
    """

    def __init__(self, db_path: Path = DB_PATH):
        if not Path(db_path).exists():
            raise FileNotFoundError(
                f"brain.db no encontrado en {db_path}. "
                "Ejecuta primero: python digital-brain/build-brain.py"
            )
        self._path = db_path
        self._conn: sqlite3.Connection | None = None

    # ── Conexión ───────────────────────────────────────────────────────────────

    def _db(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(self._path)
            self._conn.row_factory = sqlite3.Row
            self._conn.execute('PRAGMA query_only=1')
        return self._conn

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.close()

    # ── Helpers ────────────────────────────────────────────────────────────────

    @staticmethod
    def _rows(rows) -> list[dict]:
        return [dict(r) for r in rows]

    @staticmethod
    def _one(row) -> dict | None:
        return dict(row) if row else None

    def _resolve_id(self, name: str) -> str:
        """Resolve short sp_name or canonical db:sp_name to canonical full ID."""
        if ':' in name:
            return name
        row = self._db().execute(
            'SELECT id FROM sps WHERE name=? ORDER BY fan_in DESC LIMIT 1', (name,)
        ).fetchone()
        return row['id'] if row else name

    @staticmethod
    def _json_field(d: dict, key: str):
        val = d.get(key)
        if isinstance(val, str):
            try:
                return json.loads(val)
            except Exception:
                return val
        return val

    def _parse_json_fields(self, d: dict, keys: list[str]) -> dict:
        for k in keys:
            d[k] = self._json_field(d, k)
        return d

    # ── Lookup de entidades ────────────────────────────────────────────────────

    def sp(self, name: str) -> dict | None:
        """
        Perfil completo de un Stored Procedure.
        Acepta ID canónico (db:sp_name) o nombre corto (sp_name).
        Si hay múltiples SPs con el mismo nombre corto, devuelve el de mayor fan_in.
        """
        row = self._db().execute('SELECT * FROM sps WHERE id=?', (name,)).fetchone()
        if not row:
            # Buscar por nombre corto
            row = self._db().execute(
                'SELECT * FROM sps WHERE name=? ORDER BY fan_in DESC LIMIT 1', (name,)
            ).fetchone()
        return self._one(row)

    def sp_by_name(self, name: str) -> list[dict]:
        """Todos los SPs con un nombre corto dado (puede haber varios en distintas DBs)."""
        rows = self._db().execute(
            'SELECT * FROM sps WHERE name=? ORDER BY fan_in DESC', (name,)
        ).fetchall()
        return self._rows(rows)

    def domain(self, domain_id: str) -> dict | None:
        """Perfil completo de un dominio (D01–D12)."""
        row = self._db().execute(
            'SELECT * FROM domains WHERE id=?', (domain_id.upper(),)
        ).fetchone()
        if not row:
            return None
        return self._parse_json_fields(dict(row), ['reg'])

    def all_domains(self) -> list[dict]:
        """Los 12 dominios con sus metadatos."""
        rows = self._db().execute('SELECT * FROM domains ORDER BY id').fetchall()
        return [self._parse_json_fields(dict(r), ['reg']) for r in rows]

    def term(self, token: str) -> dict | None:
        """Definición de un término del vocabulario controlado."""
        row = self._db().execute('SELECT * FROM terms WHERE term=?', (token,)).fetchone()
        return self._one(row)

    # ── Traversal de dependencias ──────────────────────────────────────────────

    def callers_of(self, sp_name: str, limit: int = 100) -> list[dict]:
        """SPs que llaman a este SP (vista fan_in), ordenados por fan_in desc."""
        full_id = self._resolve_id(sp_name)
        rows = self._db().execute('''
            SELECT s.id, s.name, s.db, s.domain, s.fan_in, s.fan_out, s.loc,
                   s.biz, s.is_soul, sc.cross_db
            FROM sp_calls sc
            JOIN sps s ON sc.from_sp = s.id
            WHERE sc.to_sp = ?
            ORDER BY s.fan_in DESC LIMIT ?
        ''', (full_id, limit)).fetchall()
        return self._rows(rows)

    def callees_of(self, sp_name: str, limit: int = 100) -> list[dict]:
        """SPs que llama este SP (vista fan_out)."""
        full_id = self._resolve_id(sp_name)
        rows = self._db().execute('''
            SELECT s.id, s.name, s.db, s.domain, s.fan_in, s.fan_out, s.loc,
                   s.biz, s.is_soul, sc.cross_db
            FROM sp_calls sc
            JOIN sps s ON sc.to_sp = s.id
            WHERE sc.from_sp = ?
            ORDER BY s.fan_in DESC LIMIT ?
        ''', (full_id, limit)).fetchall()
        return self._rows(rows)

    def sps_in_domain(self, domain_id: str, min_fanin: int = 0,
                      only_souls: bool = False, limit: int = 200) -> list[dict]:
        """SPs de un dominio, filtrados y ordenados por fan_in desc."""
        did = domain_id.upper()
        soul_filter = 'AND is_soul=1' if only_souls else ''
        rows = self._db().execute(f'''
            SELECT id, label, db, fan_in, fan_out, loc, biz, biz_estado,
                   verdict, is_soul, soul_rank, soul_pattern, weaknesses, complexity,
                   prod_p50_s, prod_p95_s, flow_p50_s, flow_p95_s, flow_n
            FROM sps
            WHERE domain=? AND fan_in>=? {soul_filter}
            ORDER BY fan_in DESC LIMIT ?
        ''', (did, min_fanin, limit)).fetchall()
        return self._rows(rows)

    # ── Las 12 Almas ───────────────────────────────────────────────────────────

    def souls(self) -> list[dict]:
        """Las 12 almas — SPs arquitectónicamente críticos de BCOPCore."""
        rows = self._db().execute('''
            SELECT s.id, s.name, s.label, s.db, s.domain, s.fan_in, s.fan_out, s.loc, s.biz,
                   s.soul_rank, s.soul_pattern, s.weaknesses, s.verdict
            FROM sps s
            WHERE s.is_soul=1
              AND s.fan_in = (
                SELECT MAX(s2.fan_in) FROM sps s2
                WHERE s2.is_soul=1 AND s2.name=s.name
              )
            ORDER BY s.soul_rank
        ''').fetchall()
        return self._rows(rows)

    # ── Reglas de negocio ──────────────────────────────────────────────────────

    def rules_of_sp(self, sp_name: str) -> list[dict]:
        """Reglas de negocio (validaciones + fórmulas) de un SP."""
        rows = self._db().execute(
            'SELECT * FROM rules WHERE sp=? ORDER BY line',
            (sp_name,)
        ).fetchall()
        return self._rows(rows)

    def rules_of_domain(self, domain_id: str,
                        reg: str = None, tipo: str = None) -> list[dict]:
        """Reglas de un dominio, filtradas opcionalmente por regulador o tipo."""
        did = domain_id.upper()
        filters, params = ['domain=?'], [did]
        if reg:
            filters.append('reg LIKE ?')
            params.append(f'%{reg}%')
        if tipo:
            filters.append('tipo=?')
            params.append(tipo)
        rows = self._db().execute(
            f'SELECT * FROM rules WHERE {" AND ".join(filters)} ORDER BY sp, line',
            params
        ).fetchall()
        return self._rows(rows)

    def regulatory_risk(self, domain_id: str = None) -> list[dict]:
        """
        Resumen de riesgo regulatorio: reglas agrupadas por regulador.
        Filtra opcionalmente por dominio.
        """
        if domain_id:
            rows = self._db().execute('''
                SELECT reg, riesgo, tipo, COUNT(*) as n,
                       GROUP_CONCAT(DISTINCT sp) as sps
                FROM rules
                WHERE domain=? AND riesgo IS NOT NULL AND riesgo != ''
                GROUP BY reg, riesgo, tipo
                ORDER BY n DESC
            ''', (domain_id.upper(),)).fetchall()
        else:
            rows = self._db().execute('''
                SELECT reg, riesgo, tipo, domain, COUNT(*) as n,
                       GROUP_CONCAT(DISTINCT sp) as sps
                FROM rules
                WHERE riesgo IS NOT NULL AND riesgo != ''
                GROUP BY reg, riesgo, tipo, domain
                ORDER BY n DESC
            ''').fetchall()
        return self._rows(rows)

    # ── Vocabulario ────────────────────────────────────────────────────────────

    def terms_in_sp(self, sp_name: str) -> list[dict]:
        """Términos del vocabulario controlado extraídos de un SP."""
        rows = self._db().execute('''
            SELECT t.term, t.cat, t.meaning, t.est, t.scope, st.source
            FROM sp_terms st
            LEFT JOIN terms t ON st.term = t.term
            WHERE st.sp = ?
            ORDER BY t.nivel DESC
        ''', (sp_name,)).fetchall()
        return self._rows(rows)

    def sps_with_term(self, token: str) -> list[dict]:
        """SPs que contienen un término de vocabulario específico."""
        rows = self._db().execute('''
            SELECT s.id, s.domain, s.fan_in, s.biz, st.source
            FROM sp_terms st
            JOIN sps s ON st.sp = s.id
            WHERE st.term = ?
            ORDER BY s.fan_in DESC
        ''', (token,)).fetchall()
        return self._rows(rows)

    # ── Journeys ───────────────────────────────────────────────────────────────

    def journeys(self, domain_id: str = None,
                 journey_type: str = None) -> list[dict]:
        """
        Journeys de negocio (orquestadores + expuestos).
        Filtra opcionalmente por dominio o tipo ('orchestrator'/'exposed').
        """
        filters, params = [], []
        if domain_id:
            filters.append('domain=?')
            params.append(domain_id.upper())
        if journey_type:
            filters.append('journey_type=?')
            params.append(journey_type)
        where = ('WHERE ' + ' AND '.join(filters)) if filters else ''
        rows = self._db().execute(
            f'SELECT * FROM journeys {where} '
            f'ORDER BY domain, journey_type, fan_out DESC',
            params
        ).fetchall()
        return [self._parse_json_fields(dict(r), ['reg', 'steps']) for r in rows]

    # ── Sistemas externos ──────────────────────────────────────────────────────

    def integrations(self) -> list[dict]:
        """Sistemas externos integrados con BCOPCore, ordenados por endpoints desc."""
        rows = self._db().execute(
            'SELECT * FROM external_systems ORDER BY total_endpoints DESC'
        ).fetchall()
        return self._rows(rows)

    # ── Análisis de impacto ────────────────────────────────────────────────────

    def impact_of(self, sp_name: str) -> dict:
        """
        Análisis de impacto: quién llama a este SP, en cuántos dominios,
        y qué reglas de negocio lleva.

        Útil para evaluar el riesgo de modificar o reemplazar un SP.
        """
        sp_data = self.sp(sp_name)
        if not sp_data:
            return {'error': f'SP no encontrado: {sp_name}'}

        callers  = self.callers_of(sp_name, limit=500)
        callees  = self.callees_of(sp_name, limit=100)
        rules    = self.rules_of_sp(sp_name)

        domains_affected  = sorted({c['domain'] for c in callers if c.get('domain')})
        cross_db_callers  = [c for c in callers if c.get('cross_db')]
        regulatory_rules  = [r for r in rules if r.get('riesgo')]

        risk = (
            'CRÍTICO' if sp_data.get('is_soul') or len(domains_affected) >= 4 else
            'ALTO'    if len(domains_affected) >= 2 or len(regulatory_rules) >= 3 else
            'MEDIO'   if len(callers) >= 50 else
            'BAJO'
        )

        return {
            'sp':                 sp_data,
            'caller_count':       len(callers),
            'callee_count':       len(callees),
            'domains_affected':   domains_affected,
            'cross_db_callers':   len(cross_db_callers),
            'business_rules':     len(rules),
            'regulatory_rules':   len(regulatory_rules),
            'risk_level':         risk,
            'top_callers':        callers[:15],
            'top_callees':        callees[:10],
            'rules':              rules,
        }

    # ── Scope de migración ────────────────────────────────────────────────────

    def migration_scope(self, domain_id: str) -> dict:
        """
        Todo lo que un agente necesita para generar el spec de migración de un dominio:
        dominio, SPs, journeys, almas, reglas, riesgo regulatorio, dependencias cross-domain.
        """
        did = domain_id.upper()
        domain  = self.domain(did)
        if not domain:
            return {'error': f'Dominio no encontrado: {did}'}

        sps     = self.sps_in_domain(did, limit=500)
        jrns    = self.journeys(did)
        rules   = self.rules_of_domain(did)
        reg_risk = self.regulatory_risk(did)
        souls_here = [s for s in sps if s.get('is_soul')]

        # Dominios que llaman SPs de este dominio
        cross_in = self._db().execute('''
            SELECT s.domain as other_domain, COUNT(*) as n
            FROM sp_calls sc
            JOIN sps s ON sc.from_sp = s.id
            WHERE sc.to_sp IN (SELECT id FROM sps WHERE domain=?)
              AND s.domain != ?
            GROUP BY s.domain ORDER BY n DESC
        ''', (did, did)).fetchall()

        # Dominios a los que llaman SPs de este dominio
        cross_out = self._db().execute('''
            SELECT s.domain as other_domain, COUNT(*) as n
            FROM sp_calls sc
            JOIN sps s ON sc.to_sp = s.id
            WHERE sc.from_sp IN (SELECT id FROM sps WHERE domain=?)
              AND s.domain != ?
            GROUP BY s.domain ORDER BY n DESC
        ''', (did, did)).fetchall()

        return {
            'domain':                 domain,
            'sp_total':               len(sps),
            'journeys_total':         len(jrns),
            'souls':                  souls_here,
            'rules_total':            len(rules),
            'formulas':               [r for r in rules if r.get('tipo') == 'formula'],
            'validations':            [r for r in rules if r.get('tipo') == 'validation'],
            'regulatory_risk_summary': reg_risk,
            'cross_domain_in':        self._rows(cross_in),
            'cross_domain_out':       self._rows(cross_out),
            'top_sps':                sps[:30],
            'journeys':               jrns,
        }

    # ── Búsqueda full-text ─────────────────────────────────────────────────────

    def search(self, query: str, limit: int = 20) -> dict:
        """
        Búsqueda full-text sobre SPs, reglas, términos y journeys.
        Devuelve resultados agrupados por tipo de entidad.

        Ejemplo:
            brain.search('scoring crediticio CNBV')
            brain.search('portabilidad nómina Banxico')
        """
        safe = re.sub(r'[^\w\sáéíóúüñÁÉÍÓÚÜÑ]', ' ', query).strip()
        if not safe:
            return {'sps': [], 'rules': [], 'terms': [], 'journeys': []}

        # FTS5: cada palabra como término independiente (OR implícito)
        fts_q = ' OR '.join(safe.split())

        def fts(table_fts, join_table, join_col, select_cols):
            try:
                return self._db().execute(f'''
                    SELECT {select_cols}, bm25({table_fts}) as _score
                    FROM {table_fts} f
                    JOIN {join_table} t ON f.rowid = t.rowid
                    WHERE {table_fts} MATCH ?
                    ORDER BY _score LIMIT ?
                ''', (fts_q, limit)).fetchall()
            except sqlite3.OperationalError:
                return []

        sp_rows = fts('sps_fts', 'sps', 'id',
                      't.id, t.domain, t.biz, t.fan_in, t.is_soul, t.soul_pattern')
        rule_rows = fts('rules_fts', 'rules', 'id',
                        't.id, t.sp, t.domain, t.tipo, t.reg, t.riesgo, t.code, t.business_name')
        term_rows = fts('terms_fts', 'terms', 'term',
                        't.term, t.cat, t.meaning, t.scope')
        jrn_rows  = fts('journeys_fts', 'journeys', 'id',
                        't.id, t.sp, t.domain, t.biz, t.journey_type')

        return {
            'sps':      self._rows(sp_rows),
            'rules':    self._rows(rule_rows),
            'terms':    self._rows(term_rows),
            'journeys': self._rows(jrn_rows),
        }

    # ── Stats generales ────────────────────────────────────────────────────────

    def stats(self) -> dict:
        """Conteos de alto nivel del Digital Brain."""
        db = self._db()
        l3_n = db.execute('SELECT COUNT(*) FROM etb_l3').fetchone()[0]
        cov  = db.execute("SELECT COUNT(*) FROM etb_l3 WHERE bcop_status='COVERED'").fetchone()[0]
        cc   = db.execute("SELECT COUNT(*) FROM etb_l3 WHERE bcop_status='CROSS_CUTTING'").fetchone()[0]
        return {
            'sps':             db.execute('SELECT COUNT(*) FROM sps').fetchone()[0],
            'sp_calls':        db.execute('SELECT COUNT(*) FROM sp_calls').fetchone()[0],
            'domains':         db.execute('SELECT COUNT(*) FROM domains').fetchone()[0],
            'souls':           db.execute('SELECT COUNT(*) FROM sps WHERE is_soul=1').fetchone()[0],
            'journeys':        db.execute('SELECT COUNT(*) FROM journeys').fetchone()[0],
            'rules':           db.execute('SELECT COUNT(*) FROM rules').fetchone()[0],
            'terms':           db.execute('SELECT COUNT(*) FROM terms').fetchone()[0],
            'external_systems':db.execute('SELECT COUNT(*) FROM external_systems').fetchone()[0],
            'sp_terms_links':  db.execute('SELECT COUNT(*) FROM sp_terms').fetchone()[0],
            'authors':         db.execute('SELECT COUNT(*) FROM authors').fetchone()[0],
            'etb_l1':          db.execute('SELECT COUNT(*) FROM etb_l1').fetchone()[0],
            'etb_l2':          db.execute('SELECT COUNT(*) FROM etb_l2').fetchone()[0],
            'etb_l3':          l3_n,
            'etb_covered':     cov,
            'etb_cross_cutting': cc,
            'etb_coverage_pct': round(100 * (cov + cc) / l3_n, 1) if l3_n else 0,
        }

    # ── ETB Ontology ───────────────────────────────────────────────────────────

    def capabilities(self, status: str = None) -> list[dict]:
        """
        Capacidades ETB L3.
        status: 'COVERED' | 'CROSS_CUTTING' | 'NOT_COVERED' | None (todas)
        Cada dict incluye campo 'l3_id' (alias de 'id').
        """
        sel = 'SELECT id as l3_id, l1_id, l2_id, name, definition, bcop_status, bcop_cross_sps FROM etb_l3'
        if status:
            rows = self._db().execute(
                f'{sel} WHERE bcop_status=? ORDER BY l1_id, l2_id, id',
                (status.upper(),)
            ).fetchall()
        else:
            rows = self._db().execute(f'{sel} ORDER BY l1_id, l2_id, id').fetchall()
        result = self._rows(rows)
        for r in result:
            r['bcop_cross_sps'] = self._json_field(r, 'bcop_cross_sps')
        return result

    def capability(self, l3_id: str) -> dict | None:
        """Perfil completo de una capacidad ETB L3 (e.g., '3.4.1')."""
        row = self._db().execute(
            'SELECT id as l3_id, l1_id, l2_id, name, definition, bcop_status, bcop_cross_sps '
            'FROM etb_l3 WHERE id=?', (l3_id,)
        ).fetchone()
        if not row:
            return None
        d = dict(row)
        d['bcop_cross_sps'] = self._json_field(d, 'bcop_cross_sps')
        dc_rows = self._db().execute(
            'SELECT domain_id, mapping_type FROM domain_capabilities WHERE l3_id=? ORDER BY mapping_type',
            (l3_id,)
        ).fetchall()
        d['domains'] = self._rows(dc_rows)
        return d

    def domain_capabilities(self, domain_id: str) -> dict:
        """
        Capacidades ETB L3 que implementa un dominio (primary + secondary).
        Devuelve dict con claves 'primary' y 'secondary'.
        """
        did = domain_id.upper()
        rows = self._db().execute('''
            SELECT e.id as l3_id, e.l1_id, e.l2_id, e.name, e.definition,
                   e.bcop_status, e.bcop_cross_sps, dc.mapping_type
            FROM domain_capabilities dc
            JOIN etb_l3 e ON dc.l3_id = e.id
            WHERE dc.domain_id = ?
            ORDER BY dc.mapping_type, e.l1_id, e.l2_id, e.id
        ''', (did,)).fetchall()
        primary, secondary = [], []
        for r in rows:
            d = dict(r)
            d['bcop_cross_sps'] = self._json_field(d, 'bcop_cross_sps')
            if d.pop('mapping_type') == 'primary':
                primary.append(d)
            else:
                secondary.append(d)
        return {'domain': did, 'primary': primary, 'secondary': secondary}

    def capability_sps(self, l3_id: str, limit: int = 200) -> list[dict]:
        """
        SPs que implementan una capacidad ETB L3, ordenados por fan_in desc.
        La relación es: L3 -> dominios -> SPs del dominio.
        """
        rows = self._db().execute('''
            SELECT DISTINCT s.id, s.name, s.db, s.domain, s.fan_in, s.fan_out,
                            s.biz, s.is_soul, dc.mapping_type
            FROM domain_capabilities dc
            JOIN sps s ON s.domain = dc.domain_id
            WHERE dc.l3_id = ?
            ORDER BY dc.mapping_type, s.fan_in DESC
            LIMIT ?
        ''', (l3_id, limit)).fetchall()
        return self._rows(rows)

    def capability_coverage(self) -> list[dict]:
        """
        Resumen de cobertura ETB: L1 + L2 con conteos por status.
        Útil para el gap analysis de migración.
        """
        rows = self._db().execute('''
            SELECT e.l1_id, l1.name as l1_name, e.l2_id, l2.name as l2_name,
                   COUNT(*) as l3_total,
                   SUM(CASE WHEN e.bcop_status='COVERED' THEN 1 ELSE 0 END) as covered,
                   SUM(CASE WHEN e.bcop_status='CROSS_CUTTING' THEN 1 ELSE 0 END) as cross_cutting,
                   SUM(CASE WHEN e.bcop_status='NOT_COVERED' THEN 1 ELSE 0 END) as not_covered
            FROM etb_l3 e
            LEFT JOIN etb_l1 l1 ON e.l1_id = l1.id
            LEFT JOIN etb_l2 l2 ON e.l2_id = l2.id
            GROUP BY e.l1_id, e.l2_id
            ORDER BY e.l1_id, e.l2_id
        ''').fetchall()
        return self._rows(rows)
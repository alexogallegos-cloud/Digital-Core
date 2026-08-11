#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
sp_pseudocode.py — Convierte SPL Informix a pseudocódigo en español.
Genera HTML para embeber en las cards del portal BCOPCore.
"""
import re
import html as html_lib
from pathlib import Path


# ── Limpieza de texto ──────────────────────────────────────────────────────

_DB_PREFIX = re.compile(
    r'(?:bdicnweb|bdicheq|bdicred|bdinteg|bdisac|bdimis|bdiprospectos|bdireports|'
    r'bdiresp|bdidigital|bdirepaut|bdiadminnomina|bdibi|bdirech|bdiprem|bdiofi|'
    r'bdigaran|bdiriesgos|bdirst|bdispei|bdicat|bdipag|bdinot|bdiseg|bdicomp|'
    r'bdiaud|bdifin|bdiop|bdifal|bdinom|bdicil|bdisuc|bdints):',
    re.IGNORECASE
)
_INFORMIX_SCHEMA = re.compile(r'"informix"\.|informix\.', re.IGNORECASE)
_MULTI_SPACE     = re.compile(r'\s{2,}')
_TRAILING_SEMI   = re.compile(r';+\s*$')


def _clean(s: str) -> str:
    s = _DB_PREFIX.sub('', s)
    s = _INFORMIX_SCHEMA.sub('', s)
    s = _MULTI_SPACE.sub(' ', s)
    s = _TRAILING_SEMI.sub('', s)
    return s.strip()


def _short(s: str, n: int = 90) -> str:
    s = _clean(s)
    return s[:n] + '…' if len(s) > n else s


# ── Token kinds ───────────────────────────────────────────────────────────

KIND_CSS = {
    'meta':    'pc-meta',
    'section': 'pc-section',
    'param':   'pc-param',
    'define':  'pc-define',
    'comment': 'pc-comment',
    'keyword': 'pc-kw',
    'loop':    'pc-loop',
    'call':    'pc-call',
    'return_': 'pc-return',
    'error':   'pc-error',
    'tx':      'pc-tx',
    'assign':  'pc-assign',
    'dml':     'pc-dml',
    'query':   'pc-query',
    'raw':     'pc-raw',
}


# ── Patterns ──────────────────────────────────────────────────────────────

_ON_EXCEPTION   = re.compile(r'^ON\s+EXCEPTION\s*(?:SET\s+(\w+))?', re.I)
_END_EXCEPTION  = re.compile(r'^END\s+EXCEPTION', re.I)
_IF_THEN        = re.compile(r'^IF\s+(.+?)\s+THEN\s*$', re.I)
_ELIF_THEN      = re.compile(r'^ELSE\s+IF\s+(.+?)\s+THEN\s*$', re.I)
_ELSE           = re.compile(r'^ELSE\s*$', re.I)
_END_IF         = re.compile(r'^END\s+IF', re.I)
_FOREACH        = re.compile(r'^FOREACH\s*(.*)', re.I)
_END_FOREACH    = re.compile(r'^END\s+FOREACH', re.I)
_FOR_LOOP       = re.compile(r'^FOR\s+(\w+)\s*=\s*(.+?)\s+TO\s+(.+?)(?:\s+STEP\s+\S+)?\s*$', re.I)
_END_FOR        = re.compile(r'^END\s+FOR', re.I)
_WHILE          = re.compile(r'^WHILE\s+(.+)$', re.I)
_END_WHILE      = re.compile(r'^END\s+WHILE', re.I)
_EXECUTE        = re.compile(
    r'^EXECUTE\s+(?:PROCEDURE|FUNCTION)\s+'
    r'(?:(?:\w+):)?(?:"informix"\.)?(\w+)\s*\(([^)]*)\)'
    r'(?:\s+(?:INTO|RETURNING)\s+(.+?))?$', re.I)
_LET            = re.compile(r'^LET\s+(\w+)\s*=\s*(.+)$', re.I)
_LET_TRIVIAL    = re.compile(r"^LET\s+\w+\s*=\s*(?:0|''|\"\"|NULL|''\s*)\s*$", re.I)
_RETURN         = re.compile(r'^RETURN\s*(.*?)$', re.I)
_RAISE          = re.compile(r'RAISE\s+EXCEPTION\s*\(([^)]+)\)', re.I)
_COMMIT         = re.compile(r'^COMMIT\s+WORK', re.I)
_ROLLBACK       = re.compile(r'^ROLLBACK\s+WORK', re.I)
_BEGIN_WORK     = re.compile(r'^BEGIN\s+WORK', re.I)
_DELETE         = re.compile(r'^DELETE\s+FROM\s+(?:[^.]+\.)?(\w+)(?:\s+WHERE\s+(.+))?$', re.I)
_INSERT         = re.compile(
    r'^INSERT\s+INTO\s+(?:[^.]+\.)?(\w+)\s*(?:\(([^)]+)\))?\s*VALUES\s*\((.+?)\)$', re.I)
_UPDATE_START   = re.compile(r'^UPDATE\s+', re.I)
_SELECT_INTO    = re.compile(r'^SELECT\s+', re.I)
_COMMENT_LINE   = re.compile(r'^\s*--\s*(.+)$')
_DEFINE         = re.compile(r'^DEFINE\s+(.+?)$', re.I)
_SKIP_NOISE     = re.compile(
    r'^(?:SET\s+(?:DEBUG|ISOLATION|LOCK)|TRACE\s+(?:ON|OFF)|BEGIN\s*$|END\s*$|'
    r'END\s+PROCEDURE|CREATE\s+(?:PROCEDURE|FUNCTION)|RETURNING\s+|DOCUMENT\s)',
    re.I)

_SELECT_INTO_FULL = re.compile(
    r'^SELECT\s+(.+?)\s+INTO\s+(.+?)\s+FROM\s+(.+?)(?:\s+WHERE\s+(.+?))?$', re.I)
_SELECT_PLAIN = re.compile(
    r'^SELECT\s+(.+?)\s+FROM\s+(.+?)(?:\s+WHERE\s+(.+?))?$', re.I)
_FROM_TABLE = re.compile(r'\bFROM\s+(?:[^.\s]+\.)?(\w+)', re.I)
_WHERE_CLAUSE = re.compile(r'\bWHERE\s+(.+?)(?:\s+ORDER\s+BY|\s+LIMIT|$)', re.I)


# ── Collect multi-line statement ──────────────────────────────────────────

def _collect_stmt(lines: list, start: int) -> tuple[str, int]:
    """Collect lines until ';' found. Returns (joined_text, next_index)."""
    buf = []
    i = start
    while i < len(lines):
        line = lines[i].strip()
        buf.append(line)
        i += 1
        if line.endswith(';') or (buf and buf[-1].endswith(';')):
            break
        # Safety: stop if we hit a control keyword on a new line
        if i > start + 1 and _is_control_start(line):
            i -= 1  # back up
            break
    return ' '.join(buf).rstrip(';').strip(), i


def _is_control_start(line: str) -> bool:
    u = line.upper().strip()
    return any(u.startswith(k) for k in (
        'IF ', 'ELSE', 'END ', 'FOREACH', 'FOR ', 'WHILE ', 'ON EXCEPTION',
        'EXECUTE ', 'RETURN', 'COMMIT', 'ROLLBACK', 'BEGIN', 'RAISE'
    ))


# ── Parser ────────────────────────────────────────────────────────────────

class SPLParser:

    def __init__(self, sql: str, sp_name: str, callee_biz: dict):
        self.sql       = sql
        self.sp_name   = sp_name
        self.callee_biz = callee_biz
        self.lines     = sql.splitlines()
        self.indent    = 0
        self.tokens: list[dict] = []

    # ── Emit helpers ──────────────────────────────────────────────────────

    def emit(self, kind: str, text: str, di: int = 0):
        self.tokens.append({'kind': kind, 'text': text, 'indent': self.indent + di})

    def push(self):  self.indent = min(self.indent + 1, 10)
    def pop(self):   self.indent = max(self.indent - 1, 0)

    # ── Extract metadata from signature & DOCUMENT block ─────────────────

    def _extract_meta(self) -> tuple[list, list, list, dict]:
        params, returns, defines, doc = [], [], [], {}
        text = self.sql
        # Params from CREATE PROCEDURE (...)
        m = re.search(r'CREATE\s+(?:PROCEDURE|FUNCTION)\s+\S+\s*\(([^)]*)\)', text, re.I | re.S)
        if m:
            for p in m.group(1).split(','):
                p = p.strip()
                if p:
                    params.append(_clean(p))
        # RETURNING
        m = re.search(r'\)\s*RETURNING\s+(.+?);', text, re.I | re.S)
        if m:
            for r in m.group(1).split(','):
                r = r.strip().rstrip(';')
                if r:
                    returns.append(_clean(r))
        # DEFINE
        for m in re.finditer(r'DEFINE\s+([^\n;]+)', text, re.I):
            defines.append(_clean(m.group(1)))
        # DOCUMENT
        for m in re.finditer(r"'([A-Z]+):\s*([^']+)'", text, re.I):
            key = m.group(1).upper()
            if key in ('DESCRIPCION', 'FUNCIONALIDAD', 'MODULO', 'BD') and key not in doc:
                doc[key] = m.group(2).strip()
        return params, returns, defines, doc

    # ── Main parse ────────────────────────────────────────────────────────

    def parse(self) -> list[dict]:
        params, returns, defines, doc = self._extract_meta()

        # Header
        desc = doc.get('DESCRIPCION') or doc.get('FUNCIONALIDAD', '')
        if desc:
            self.emit('meta', f'Descripción: {desc}')
        if doc.get('MODULO'):
            self.emit('meta', f'Módulo: {doc["MODULO"]}')

        if params:
            self.emit('section', 'PARÁMETROS:')
            for p in params:
                self.emit('param', p, di=1)
        if returns:
            self.emit('section', 'RETORNA:')
            for r in returns:
                self.emit('param', r, di=1)
        if defines:
            self.emit('section', 'VARIABLES:')
            for d in defines[:12]:  # cap at 12 to avoid noise
                self.emit('define', d, di=1)
            if len(defines) > 12:
                self.emit('define', f'… y {len(defines)-12} más', di=1)

        self.emit('section', 'LÓGICA:')
        self.push()

        # ── Find body boundaries ──────────────────────────────────────────
        body_start = 0
        for idx, line in enumerate(self.lines):
            u = line.strip().upper()
            if u == 'BEGIN':
                body_start = idx + 1
                break

        self._parse_lines(body_start)
        return self.tokens

    # ── Line-by-line body parser ──────────────────────────────────────────

    def _parse_lines(self, start: int):
        lines = self.lines
        i = start
        while i < len(lines):
            raw  = lines[i]
            s    = raw.strip()
            sc   = _clean(s.rstrip(';'))  # cleaned, no semicolon
            i += 1

            if not s or s == ';':
                continue

            # ── Skip noise ──
            if _SKIP_NOISE.match(s):
                continue
            if _DEFINE.match(s):
                continue
            if s.upper().startswith('RETURNING'):
                continue
            if s.upper().startswith('DOCUMENT') or s.startswith("'"):
                continue
            if s.upper() in ('BEGIN', 'END;', 'END', 'END PROCEDURE;', 'END PROCEDURE'):
                continue
            if re.match(r"^'", s):  # doc string continuation
                continue

            # ── Comments ──
            m = _COMMENT_LINE.match(raw)
            if m:
                text = m.group(1).strip()
                if not re.search(r'DEBUG|TRACE|SET\s+DEBUG', text, re.I):
                    self.emit('comment', f'// {text}')
                continue

            # ── ON EXCEPTION ──
            m = _ON_EXCEPTION.match(sc)
            if m:
                var = m.group(1)
                self.emit('error', f'cuando error{"  →  " + var if var else ""}:')
                self.push()
                continue

            if _END_EXCEPTION.match(sc):
                self.pop()
                continue

            # ── ELSE IF ──
            m = _ELIF_THEN.match(sc)
            if m:
                self.pop()
                self.emit('keyword', f'si no, si {_short(m.group(1))} entonces:')
                self.push()
                continue

            # ── IF THEN ──
            m = _IF_THEN.match(sc)
            if m:
                self.emit('keyword', f'si {_short(m.group(1))} entonces:')
                self.push()
                continue

            # ── ELSE ──
            if _ELSE.match(sc):
                self.pop()
                self.emit('keyword', 'si no:')
                self.push()
                continue

            # ── END IF ──
            if _END_IF.match(sc):
                self.pop()
                continue

            # ── FOREACH ──
            m = _FOREACH.match(sc)
            if m:
                inline = m.group(1).strip()
                # Collect the SELECT query (may span lines)
                foreach_buf = inline
                j = i
                while j < len(lines) and not _END_FOREACH.match(lines[j].strip()):
                    nxt = lines[j].strip()
                    if nxt and not nxt.startswith('--'):
                        # Stop at non-SELECT body statements
                        if _is_control_start(nxt) or _LET.match(_clean(nxt)) or \
                           _EXECUTE.match(_clean(nxt)) or _DELETE.match(_clean(nxt)) or \
                           _INSERT.match(_clean(nxt)) or _RETURN.match(_clean(nxt)) or \
                           _UPDATE_START.match(nxt):
                            break
                        foreach_buf += ' ' + nxt
                    j += 1

                foreach_buf = _clean(foreach_buf)
                tm = _FROM_TABLE.search(foreach_buf)
                table = tm.group(1) if tm else '…'
                wm = _WHERE_CLAUSE.search(foreach_buf)
                where = _short(wm.group(1), 60) if wm else ''
                label = f'para cada fila de {table}'
                if where:
                    label += f' donde {where}'
                label += ':'
                self.emit('loop', label)
                self.push()
                # Continue from where SELECT body ends (j already points there)
                # Don't advance i — let the loop naturally process remaining lines
                continue

            if _END_FOREACH.match(sc):
                self.pop()
                continue

            # ── FOR loop ──
            m = _FOR_LOOP.match(sc)
            if m:
                self.emit('loop', f'para {m.group(1)} de {_clean(m.group(2))} hasta {_clean(m.group(3))}:')
                self.push()
                continue

            if _END_FOR.match(sc):
                self.pop()
                continue

            # ── WHILE ──
            m = _WHILE.match(sc)
            if m:
                self.emit('loop', f'mientras {_short(m.group(1))}:')
                self.push()
                continue

            if _END_WHILE.match(sc):
                self.pop()
                continue

            # ── EXECUTE PROCEDURE (collect multi-line) ──
            if re.match(r'^EXECUTE\s+(?:PROCEDURE|FUNCTION)\s+', sc, re.I):
                stmt = sc
                while not stmt.endswith(')') and not stmt.rstrip().endswith(';'):
                    if i >= len(lines): break
                    stmt += ' ' + _clean(lines[i])
                    i += 1
                stmt = _clean(stmt)
                m = _EXECUTE.match(stmt)
                if m:
                    sp_name = m.group(1)
                    args    = _clean(m.group(2)) if m.group(2) else ''
                    into    = _clean(m.group(3)) if m.group(3) else ''
                    biz     = self.callee_biz.get(sp_name, '')
                    call_txt = f'llamar {sp_name}({_short(args, 60)})'
                    if into:
                        call_txt += f'  →  {_short(into, 40)}'
                    if biz:
                        call_txt += f'  // {biz}'
                    self.emit('call', call_txt)
                else:
                    self.emit('call', f'llamar {_short(stmt, 80)}')
                continue

            # ── RETURN ──
            m = _RETURN.match(sc)
            if m:
                val = _clean(m.group(1))
                self.emit('return_', f'retornar {val}' if val else 'retornar')
                continue

            # ── RAISE EXCEPTION ──
            m = _RAISE.search(sc)
            if m:
                self.emit('error', f'lanzar error ({_short(m.group(1), 60)})')
                continue

            # ── Transactions ──
            if _COMMIT.match(sc):
                self.emit('tx', 'confirmar transacción')
                continue
            if _ROLLBACK.match(sc):
                self.emit('tx', 'revertir transacción')
                continue
            if _BEGIN_WORK.match(sc):
                self.emit('tx', 'iniciar transacción')
                continue

            # ── LET (skip trivial initializations) ──
            if _LET_TRIVIAL.match(s):
                continue
            m = _LET.match(sc)
            if m:
                self.emit('assign', f'{m.group(1)} ← {_short(m.group(2), 70)}')
                continue

            # ── DELETE ──
            m = _DELETE.match(sc)
            if m:
                table = m.group(1)
                where = _short(m.group(2), 60) if m.group(2) else ''
                self.emit('dml', f'eliminar de {table}' + (f' donde {where}' if where else ''))
                continue

            # ── INSERT (collect multi-line) ──
            if re.match(r'^INSERT\s+INTO\s+', sc, re.I):
                stmt = sc
                while ';' not in stmt and i < len(lines):
                    stmt += ' ' + _clean(lines[i])
                    i += 1
                stmt = _clean(stmt.rstrip(';'))
                m = _INSERT.match(stmt)
                if m:
                    table = m.group(1)
                    cols  = [c.strip() for c in (m.group(2) or '').split(',') if c.strip()]
                    vals  = [v.strip() for v in (m.group(3) or '').split(',') if v.strip()]
                    if cols and len(cols) == len(vals):
                        pairs = ', '.join(f'{c}={v}' for c, v in zip(cols[:5], vals[:5]))
                        if len(cols) > 5:
                            pairs += f', …+{len(cols)-5}'
                        self.emit('dml', f'insertar en {table}: {pairs}')
                    else:
                        self.emit('dml', f'insertar en {table}')
                else:
                    self.emit('dml', f'insertar: {_short(stmt, 70)}')
                continue

            # ── UPDATE (collect multi-line) ──
            if _UPDATE_START.match(sc):
                stmt = sc
                while ';' not in stmt and i < len(lines):
                    stmt += ' ' + _clean(lines[i])
                    i += 1
                stmt = _clean(stmt.rstrip(';'))
                m = re.match(r'UPDATE\s+(?:[^.\s]+\.)?(\w+)\s+SET\s+(.+?)(?:\s+WHERE\s+(.+?))?$', stmt, re.I)
                if m:
                    table = m.group(1)
                    sets  = _short(m.group(2), 60)
                    where = _short(m.group(3), 50) if m.group(3) else ''
                    self.emit('dml', f'actualizar {table}: {sets}' + (f' donde {where}' if where else ''))
                else:
                    self.emit('dml', f'actualizar: {_short(stmt, 70)}')
                continue

            # ── SELECT INTO (collect multi-line) ──
            if _SELECT_INTO.match(sc) and 'INTO' in sc.upper():
                stmt = sc
                while ';' not in stmt and i < len(lines):
                    nxt = _clean(lines[i])
                    if nxt:
                        stmt += ' ' + nxt
                    i += 1
                stmt = _clean(stmt.rstrip(';'))
                m = _SELECT_INTO_FULL.match(stmt)
                if m:
                    cols  = _short(m.group(1), 50)
                    into  = _short(m.group(2), 40)
                    table = _short(m.group(3), 40)
                    where = _short(m.group(4), 50) if m.group(4) else ''
                    self.emit('query', f'consultar {cols} de {table}' +
                              (f' donde {where}' if where else '') + f'  →  {into}')
                else:
                    self.emit('query', f'consultar: {_short(stmt, 80)}')
                continue

            # ── SELECT plain (inside FOREACH body, no INTO) ──
            if _SELECT_INTO.match(sc):
                stmt = sc
                while ';' not in stmt and i < len(lines):
                    nxt = lines[i].strip()
                    if nxt and not nxt.startswith('--'):
                        stmt += ' ' + _clean(nxt)
                    i += 1
                stmt = _clean(stmt.rstrip(';'))
                tm = _FROM_TABLE.search(stmt)
                table = tm.group(1) if tm else '?'
                wm = _WHERE_CLAUSE.search(stmt)
                where = _short(wm.group(1), 50) if wm else ''
                im = re.search(r'\bINTO\s+(.+?)\s+FROM', stmt, re.I)
                into = _short(im.group(1), 40) if im else ''
                label = f'consultar de {table}' + (f' donde {where}' if where else '')
                if into:
                    label += f'  →  {into}'
                self.emit('query', label)
                continue

            # ── Unrecognized — show cleaned ──
            if sc and len(sc) > 3:
                self.emit('raw', _short(sc, 100))


# ── HTML renderer ─────────────────────────────────────────────────────────

def render_html(tokens: list[dict]) -> str:
    parts = []
    for tok in tokens:
        kind   = tok['kind']
        text   = html_lib.escape(tok['text'])
        indent = tok['indent']
        css    = KIND_CSS.get(kind, 'pc-raw')
        pad    = indent * 18
        parts.append(f'<div class="{css}" style="padding-left:{pad}px">{text}</div>')
    return '\n'.join(parts)


# ── Public API ────────────────────────────────────────────────────────────

def generate(sql_path: Path, sp_name: str, callee_biz: dict = None) -> str:
    """
    Read SQL file, parse, return HTML string.
    Returns '' if file not found or parse error.
    """
    if not sql_path or not sql_path.exists():
        return ''
    try:
        sql = sql_path.read_text(encoding='utf-8', errors='replace')
    except Exception:
        return ''
    try:
        parser = SPLParser(sql, sp_name, callee_biz or {})
        tokens = parser.parse()
        return render_html(tokens)
    except Exception as exc:
        return f'<div class="pc-error">Error al parsear: {html_lib.escape(str(exc))}</div>'


# ── CSS para embeber en el portal ─────────────────────────────────────────

PSEUDOCODE_CSS = """
    /* ── Pseudocódigo ── */
    .pseudo-wrap {
      margin-top: 12px;
      border-top: 1px solid var(--border);
      padding-top: 10px;
    }
    .pseudo-btn {
      background: none;
      border: 1px solid var(--border2);
      border-radius: 6px;
      color: var(--muted);
      cursor: pointer;
      font-size: 11px;
      padding: 3px 10px;
      margin-bottom: 8px;
      transition: color .15s, border-color .15s;
    }
    .pseudo-btn:hover { color: var(--text); border-color: var(--accent); }
    .pseudo-btn.open  { color: var(--accent); border-color: var(--accent); }
    .pseudo-block {
      font-family: 'SF Mono', 'Cascadia Code', 'Consolas', monospace;
      font-size: 11.5px;
      line-height: 1.65;
      background: #0a0f1a;
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 12px 16px;
      overflow-x: auto;
      max-height: 460px;
      overflow-y: auto;
    }
    .pc-meta    { color: #6e7681; font-style: italic; margin-bottom: 4px; }
    .pc-section { color: #79c0ff; font-weight: 700; margin-top: 10px; margin-bottom: 3px; font-size: 10px; letter-spacing: .06em; }
    .pc-param   { color: #a5d6ff; }
    .pc-define  { color: #8b949e; }
    .pc-comment { color: #5a6a7a; font-style: italic; }
    .pc-kw      { color: #ff7b72; font-weight: 600; }
    .pc-loop    { color: #d2a8ff; font-weight: 600; }
    .pc-call    { color: #ffa657; }
    .pc-return  { color: #3fb950; font-weight: 600; }
    .pc-error   { color: #f85149; }
    .pc-tx      { color: #e3b341; font-weight: 600; }
    .pc-assign  { color: #c9d1d9; }
    .pc-dml     { color: #79c0ff; }
    .pc-query   { color: #56d364; }
    .pc-raw     { color: #6e7681; }
"""
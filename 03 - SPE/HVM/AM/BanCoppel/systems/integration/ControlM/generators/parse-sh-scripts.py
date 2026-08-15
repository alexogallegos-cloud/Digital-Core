"""
parse-sh-scripts.py — Generator: parsea scripts .sh de ControlM y enriquece brain.db

Fuente: source/code/*.sh (solo archivos .sh reales, no backups .sh_FECHA)
Output: nuevas tablas sh_scripts + sh_sp_refs en brain.db
        actualización de sp_hints con source='sh_content'

Cierra: DR-CTM-004 — SP hints desde contenido real de los scripts

Uso:  python generators/parse-sh-scripts.py
      python generators/parse-sh-scripts.py --dry-run
"""

import re, json, sqlite3, sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

SCRIPT_DIR = Path(__file__).resolve().parent
BASE       = SCRIPT_DIR.parent                       # ControlM/
SH_DIR     = BASE / 'source' / 'code'
DB_PATH    = BASE / 'digital-brain' / 'brain.db'
DRY_RUN    = '--dry-run' in sys.argv

# ── Schema incremental (no borra tablas existentes) ──────────────────────────
SCHEMA = '''
CREATE TABLE IF NOT EXISTS sh_scripts (
    script_name     TEXT PRIMARY KEY,
    db_names        TEXT,   -- JSON array: DBs usadas en dbaccess
    sp_names        TEXT,   -- JSON array: SPs encontrados (execute procedure + echo + filename)
    sql_files_ref   TEXT,   -- JSON array: archivos .sql referenciados por dbaccess
    sh_calls        TEXT,   -- JSON array: otros .sh llamados localmente
    ssh_calls       TEXT,   -- JSON array: {host, script} llamados via SSH
    mail_recipients TEXT,   -- JSON array: emails de notificación
    retcode_vars    TEXT,   -- JSON array: variables de código de retorno (RESULTADO_1...)
    success_codes   TEXT,   -- JSON array: códigos de éxito ("000", "00000", "OK")
    has_finderr     INTEGER DEFAULT 0,  -- 1 si usa finderr (lookup error Informix)
    author          TEXT,
    version         TEXT,
    script_comment  TEXT,
    rational_id     TEXT,   -- Id Rational del cambio
    line_count      INTEGER
);

CREATE TABLE IF NOT EXISTS sh_sp_refs (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    script_name TEXT NOT NULL,
    sp_name     TEXT NOT NULL,
    db_name     TEXT,
    source      TEXT,   -- 'execute_procedure' | 'echo_message' | 'filename' | 'sp_pattern'
    confidence  TEXT,   -- 'high' | 'medium' | 'low'
    UNIQUE(script_name, sp_name, source)
);

CREATE INDEX IF NOT EXISTS idx_sh_scripts_name  ON sh_scripts(script_name);
CREATE INDEX IF NOT EXISTS idx_sh_sp_refs_sp    ON sh_sp_refs(sp_name);
CREATE INDEX IF NOT EXISTS idx_sh_sp_refs_db    ON sh_sp_refs(db_name);
CREATE INDEX IF NOT EXISTS idx_sh_sp_refs_script ON sh_sp_refs(script_name);
'''

# ── Patterns ─────────────────────────────────────────────────────────────────
# dbaccess {db} {sql_file|path} — extrae db y archivo SQL
DBACCESS_RE = re.compile(
    r'dbaccess\s+([a-zA-Z0-9_]+)\s+(?!-\b)([^\s#|>&]+)',
    re.IGNORECASE
)
# execute procedure "informix".sp_xxx() — alta confianza
EXEC_PROC_RE = re.compile(
    r'execute\s+procedure\s+(?:"?informix"?\."?)?([a-zA-Z0-9_]+)\s*\(',
    re.IGNORECASE
)
# call sp_xxx() — alta confianza (alternativa)
CALL_SP_RE = re.compile(r'\bcall\s+(sp_[a-zA-Z0-9_]+)\s*\(', re.IGNORECASE)
# sp_xxx en líneas echo + Bd opcional — media confianza
# Captura: sp_name (directo) + opcionalmente db_name después de "Bd:"
ECHO_LINE_RE = re.compile(r'^[^#]*echo\b', re.IGNORECASE)
SP_IN_LINE_RE = re.compile(r'\b(sp_[a-zA-Z0-9_]+)\b', re.IGNORECASE)
BD_IN_LINE_RE = re.compile(r'\b[Bb][Dd][:\s]+([a-zA-Z0-9_]+)', re.IGNORECASE)
# sp_xxx en nombres de archivos SQL referenciados por dbaccess
SQL_SP_RE    = re.compile(r'\b(sp_[a-zA-Z0-9_]+)\b', re.IGNORECASE)
# sp_xxx en cualquier línea no-comentario — baja confianza, solo fallback
SP_GENERIC_RE = re.compile(r'\b(sp_[a-zA-Z0-9_]+)\b', re.IGNORECASE)
# scripts .sh llamados localmente (paths absolutos)
SH_CALL_RE = re.compile(r'(?:nice\s+-n\s+-\d+\s+)?(/[^\s]+\.sh)\b', re.IGNORECASE)
# SSH calls: ssh ... user@host /path/script.sh
SSH_RE = re.compile(
    r'ssh\s+(?:-o\s+\S+\s+)*(?:[a-zA-Z0-9_]+@)([\d.a-zA-Z.]+)\s+(/[^\s]+\.sh)',
    re.IGNORECASE
)
# mail recipients de mailx
MAIL_RE = re.compile(r'mailx\b(.+?)(?=\n|$)', re.IGNORECASE)
MAIL_ADDR_RE = re.compile(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
# header comments
AUTHOR_RE  = re.compile(r'#\s*[Aa]utor[:\s]+(.+)')
VERSION_RE = re.compile(r'#\s*[Vv]ersi[oó]n[:\s]+(.+)')
COMMENT_RE = re.compile(r'#\s*[Cc]omentario[:\s]+(.+)')
RATIONAL_RE= re.compile(r'#\s*[Ii]d\s+[Rr]ational[:\s]+(.+)')
# return code vars
RETCODE_RE = re.compile(r'\b(RESULTADO[_A-Z0-9]*)\b')
SUCCESS_RE = re.compile(r'=\s*["\']?(0{3,5}|OK)["\']?')
FINDERR_RE = re.compile(r'\bfinderr\b', re.IGNORECASE)


def is_real_sh(p: Path) -> bool:
    """Solo archivos que terminan exactamente en .sh (no .sh_FECHA)."""
    return p.suffix == '.sh'


def read_sh(path: Path) -> str:
    """Lee el script intentando UTF-8 y luego latin-1."""
    for enc in ('utf-8', 'latin-1', 'cp1252'):
        try:
            return path.read_text(encoding=enc, errors='replace')
        except Exception:
            continue
    return ''


def extract_sp_name_from_filename(filename: str) -> list[str]:
    """Extrae sp_xxx del nombre del archivo (baja confianza)."""
    return [m.lower() for m in SP_GENERIC_RE.findall(filename)]


def parse_script(path: Path) -> dict:
    text = read_sh(path)
    lines = text.splitlines()
    name = path.name

    db_set, sql_set, sp_exec, sp_echo, sh_set, ssh_list = set(), set(), [], [], set(), []
    mail_set, retcode_set, success_set = set(), set(), set()
    author = version = comment = rational = None
    has_finderr = 0

    for line in lines:
        stripped = line.strip()
        if stripped.startswith('#'):
            m = AUTHOR_RE.match(stripped); author = author or (m.group(1).strip() if m else None)
            m = VERSION_RE.match(stripped); version = version or (m.group(1).strip() if m else None)
            m = COMMENT_RE.match(stripped); comment = comment or (m.group(1).strip() if m else None)
            m = RATIONAL_RE.match(stripped); rational = rational or (m.group(1).strip() if m else None)
            continue

        # dbaccess {db} {file}
        for m in DBACCESS_RE.finditer(line):
            db = m.group(1).lower()
            fref = Path(m.group(2)).name
            db_set.add(db)
            if fref.endswith('.sql'):
                sql_set.add(fref)
                # extraer sp_xxx del nombre del sql file (media confianza)
                for sm in SQL_SP_RE.finditer(fref):
                    sp_echo.append((sm.group(1).lower(), db))

        # execute procedure
        for m in EXEC_PROC_RE.finditer(line):
            sp_exec.append(m.group(1).lower())

        # call sp_xxx
        for m in CALL_SP_RE.finditer(line):
            sp_exec.append(m.group(1).lower())

        # echo lines: buscar sp_xxx directamente en el texto del echo
        if ECHO_LINE_RE.match(line):
            bd_m = BD_IN_LINE_RE.search(line)
            db_n = bd_m.group(1).lower() if bd_m else None
            if db_n:
                db_set.add(db_n)
            for sm in SP_IN_LINE_RE.finditer(line):
                sp_echo.append((sm.group(1).lower(), db_n))

        # .sh calls locales
        for m in SH_CALL_RE.finditer(line):
            sh_set.add(Path(m.group(1)).name)

        # SSH calls
        for m in SSH_RE.finditer(line):
            ssh_list.append({'host': m.group(1), 'script': Path(m.group(2)).name})

        # mail recipients
        for m in MAIL_RE.finditer(line):
            for addr in MAIL_ADDR_RE.findall(m.group(1)):
                mail_set.add(addr.lower())

        # return code
        for m in RETCODE_RE.finditer(line):
            retcode_set.add(m.group(1))
        for m in SUCCESS_RE.finditer(line):
            success_set.add(m.group(1))

        if FINDERR_RE.search(line):
            has_finderr = 1

    # SP names from filename (lowest confidence, only novel ones)
    sp_filename = extract_sp_name_from_filename(name)

    return {
        'script_name':     name,
        'db_names':        sorted(db_set),
        'sp_exec':         list(dict.fromkeys(sp_exec)),   # dedup preserving order
        'sp_echo':         sp_echo,                        # [(sp, db), ...]
        'sp_filename':     sp_filename,
        'sql_files_ref':   sorted(sql_set),
        'sh_calls':        sorted(sh_set - {name}),        # no auto-ref
        'ssh_calls':       ssh_list,
        'mail_recipients': sorted(mail_set),
        'retcode_vars':    sorted(retcode_set),
        'success_codes':   sorted(success_set),
        'has_finderr':     has_finderr,
        'author':          author,
        'version':         version,
        'script_comment':  comment,
        'rational_id':     rational,
        'line_count':      len(lines),
    }


def build_sp_refs(parsed: dict) -> list[dict]:
    """Construye la lista de (sp_name, db_name, source, confidence) para sh_sp_refs."""
    refs = []
    seen = set()

    def add(sp, db, source, confidence):
        sp = sp.lower().strip()
        key = (sp, source)
        if key not in seen and sp:
            seen.add(key)
            refs.append({'sp': sp, 'db': db, 'source': source, 'confidence': confidence})

    # Alta confianza: execute procedure / call
    db_list = parsed['db_names']
    primary_db = db_list[0] if len(db_list) == 1 else None
    for sp in parsed['sp_exec']:
        add(sp, primary_db, 'execute_procedure', 'high')

    # Media confianza: echo messages
    for sp, db in parsed['sp_echo']:
        add(sp, db or primary_db, 'echo_message', 'medium')

    # Baja confianza: nombre de archivo (solo si no hay fuentes mejores)
    if not refs:
        for sp in parsed['sp_filename']:
            add(sp, primary_db, 'filename', 'low')

    return refs


def save_to_db(conn, parsed: dict, refs: list[dict]) -> None:
    p = parsed
    conn.execute(
        '''INSERT OR REPLACE INTO sh_scripts
           (script_name, db_names, sp_names, sql_files_ref, sh_calls, ssh_calls,
            mail_recipients, retcode_vars, success_codes, has_finderr,
            author, version, script_comment, rational_id, line_count)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''',
        (
            p['script_name'],
            json.dumps(p['db_names'],        ensure_ascii=False),
            json.dumps([r['sp'] for r in refs], ensure_ascii=False),
            json.dumps(p['sql_files_ref'],   ensure_ascii=False),
            json.dumps(p['sh_calls'],        ensure_ascii=False),
            json.dumps(p['ssh_calls'],       ensure_ascii=False),
            json.dumps(p['mail_recipients'], ensure_ascii=False),
            json.dumps(p['retcode_vars'],    ensure_ascii=False),
            json.dumps(p['success_codes'],   ensure_ascii=False),
            p['has_finderr'],
            p['author'], p['version'], p['script_comment'], p['rational_id'],
            p['line_count'],
        )
    )
    for r in refs:
        conn.execute(
            '''INSERT OR IGNORE INTO sh_sp_refs
               (script_name, sp_name, db_name, source, confidence)
               VALUES (?,?,?,?,?)''',
            (p['script_name'], r['sp'], r['db'], r['source'], r['confidence'])
        )


def print_summary(conn) -> None:
    n_scripts = conn.execute('SELECT COUNT(*) FROM sh_scripts').fetchone()[0]
    n_refs    = conn.execute('SELECT COUNT(*) FROM sh_sp_refs').fetchone()[0]
    n_high    = conn.execute("SELECT COUNT(*) FROM sh_sp_refs WHERE confidence='high'").fetchone()[0]
    n_medium  = conn.execute("SELECT COUNT(*) FROM sh_sp_refs WHERE confidence='medium'").fetchone()[0]
    n_low     = conn.execute("SELECT COUNT(*) FROM sh_sp_refs WHERE confidence='low'").fetchone()[0]
    n_ssh     = conn.execute("SELECT SUM(json_array_length(ssh_calls)) FROM sh_scripts WHERE ssh_calls != '[]'").fetchone()[0] or 0
    n_finderr = conn.execute('SELECT COUNT(*) FROM sh_scripts WHERE has_finderr=1').fetchone()[0]

    print(f'\n── sh_scripts ─────────────────────────────────────────')
    print(f'  Scripts .sh analizados   {n_scripts:>6,}')
    print(f'  sh_sp_refs total         {n_refs:>6,}  '
          f'[high={n_high} / medium={n_medium} / low={n_low}]')
    print(f'  Scripts con SSH calls    {n_ssh:>6,}')
    print(f'  Scripts con finderr      {n_finderr:>6,}')

    print('\n── Top 20 SPs (execute_procedure) ─────────────────────')
    rows = conn.execute(
        '''SELECT sp_name, db_name, COUNT(*) n
           FROM sh_sp_refs WHERE source='execute_procedure'
           GROUP BY sp_name ORDER BY n DESC LIMIT 20'''
    ).fetchall()
    for r in rows:
        print(f'  {r[0]:<45} db={r[1] or "?":<15} x{r[2]}')

    print('\n── DBs más frecuentes en dbaccess ──────────────────────')
    rows = conn.execute(
        '''SELECT db_name, COUNT(*) n
           FROM sh_sp_refs WHERE db_name IS NOT NULL
           GROUP BY db_name ORDER BY n DESC LIMIT 15'''
    ).fetchall()
    for r in rows:
        print(f'  {r[0]:<25} {r[1]:>5,} refs')

    print('\n── Scripts con SSH calls (servidores externos) ─────────')
    rows = conn.execute(
        "SELECT script_name, ssh_calls FROM sh_scripts WHERE ssh_calls != '[]' LIMIT 10"
    ).fetchall()
    for r in rows:
        calls = json.loads(r[1])
        for c in calls:
            print(f'  {r[0]:<45} → {c["host"]} {c["script"]}')


# ── Main ─────────────────────────────────────────────────────────────────────
def main():
    print(f'parse-sh-scripts.py — ControlM SH Parser')
    print(f'SH_DIR:  {SH_DIR}')
    print(f'DB:      {DB_PATH}')
    if DRY_RUN:
        print('[DRY-RUN] No se escribe en DB\n')

    if not SH_DIR.exists():
        print(f'[ERROR] No existe {SH_DIR}'); sys.exit(1)
    if not DB_PATH.exists():
        print(f'[ERROR] No existe {DB_PATH} — corre build-brain.py primero'); sys.exit(1)

    sh_files = [f for f in sorted(SH_DIR.iterdir()) if is_real_sh(f)]
    print(f'Scripts .sh encontrados: {len(sh_files):,}\n')

    all_parsed, all_refs = [], []
    stats = {'high': 0, 'medium': 0, 'low': 0, 'no_sp': 0}

    for sh in sh_files:
        parsed = parse_script(sh)
        refs   = build_sp_refs(parsed)
        all_parsed.append(parsed)
        all_refs.append(refs)
        if refs:
            conf = refs[0]['confidence']
            stats[conf] += 1
        else:
            stats['no_sp'] += 1

    print(f'Parse completo:')
    print(f'  execute_procedure (high)   {stats["high"]:>5,}')
    print(f'  echo_message (medium)      {stats["medium"]:>5,}')
    print(f'  filename only (low)        {stats["low"]:>5,}')
    print(f'  sin SP detectado           {stats["no_sp"]:>5,}')

    if DRY_RUN:
        print('\n[DRY-RUN] Muestra (primeros 5 con SPs):')
        shown = 0
        for p, refs in zip(all_parsed, all_refs):
            if refs and shown < 5:
                print(f'\n  {p["script_name"]}')
                print(f'    DBs: {p["db_names"]}')
                for r in refs[:3]:
                    print(f'    SP: {r["sp"]} [{r["source"]} / {r["confidence"]}] db={r["db"]}')
                shown += 1
        return

    conn = sqlite3.connect(DB_PATH)
    conn.executescript(SCHEMA)

    # Limpiar para idempotencia
    conn.execute('DELETE FROM sh_scripts')
    conn.execute('DELETE FROM sh_sp_refs')
    conn.commit()

    for parsed, refs in zip(all_parsed, all_refs):
        save_to_db(conn, parsed, refs)

    # Actualizar sp_hints: agregar refs de alta confianza que no estén ya
    rows_added = 0
    for parsed, refs in zip(all_parsed, all_refs):
        script_name = parsed['script_name']
        # Buscar job_id cuyo mem_name coincida con el script
        job_id = conn.execute(
            "SELECT id FROM jobs WHERE mem_name = ? OR mem_name LIKE ? LIMIT 1",
            (script_name, f'%{script_name}')
        ).fetchone()
        if not job_id:
            continue
        jid = job_id[0]
        for r in refs:
            if r['confidence'] in ('high', 'medium'):
                try:
                    conn.execute(
                        'INSERT OR IGNORE INTO sp_hints (job_id, sp_name_hint, source) VALUES (?,?,?)',
                        (jid, r['sp'], 'sh_content')
                    )
                    rows_added += 1
                except Exception:
                    pass

    conn.commit()
    print(f'\n  sp_hints actualizados: +{rows_added} desde contenido real')
    print_summary(conn)
    conn.close()
    print('\n✓ parse-sh-scripts.py completado')


if __name__ == '__main__':
    main()

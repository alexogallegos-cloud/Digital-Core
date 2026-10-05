"""
extract-table-refs.py — Extractor de dependencias SP → tabla de base de datos
Corpus: source/informix/*.sql  (12,883 archivos, todos los dominios D01-D49)

Produce la tabla sp_table_refs en brain.db:
    sp_id       — ID canónico  db:sp_name
    sp_name     — nombre corto del SP
    sp_db       — base de datos del SP
    ref_table   — nombre de la tabla (sin alias, sin schema)
    ref_db      — base de datos de la tabla (puede diferir de sp_db si es cross-DB)
    access_type — 'R' | 'W' | 'RW'
    operations  — JSON array, e.g. ["SELECT","UPDATE"]
    is_cross_db — 1 si ref_db != sp_db
    line_first  — primera línea donde aparece la referencia

Patrones DML reconocidos en Informix SPL:
    SELECT  ...  FROM  [db[@srv]:[schema.]table | table]  [alias] [JOIN ...]
    INSERT INTO  [db[@srv]:[schema.]table]
    UPDATE       [db[@srv]:[schema.]table]  SET
    DELETE FROM  [db[@srv]:[schema.]table]
    FOREACH  ...  SELECT  ...  FROM  ...
    [INNER|LEFT|RIGHT|FULL] [OUTER] JOIN  [db[@srv]:[schema.]table]
"""

import os, re, json, sqlite3
from pathlib import Path
from collections import defaultdict

# ── Rutas ────────────────────────────────────────────────────────────────────
BASE = Path(__file__).parent.parent
SRC  = BASE / "source" / "informix"
DB   = BASE / "digital-brain" / "brain.db"

# ── Palabras reservadas SPL que jamás son nombres de tabla ───────────────────
SPL_KEYWORDS = {
    'set','isolation','dirty','read','lock','mode','wait','exception','procedure',
    'end','begin','define','integer','char','decimal','money','date','datetime',
    'interval','smallint','float','real','boolean','byte','text','serial',
    'varchar','nchar','nvarchar','lvarchar','bigint','int8','float','smallfloat',
    'returning','return','with','resume','if','then','else','end','while','for',
    'foreach','into','let','call','execute','on','not','null','is','and','or',
    'in','exists','between','like','matches','first','skip','union','all',
    'having','group','by','order','asc','desc','where','values','select',
    'insert','update','delete','create','drop','alter','index','table','view',
    'outer','inner','left','right','full','join','cross','natural','using','on',
    'from','as','distinct','unique','case','when','cast','nvl','today','current',
    'year','month','day','extend','trim','upper','lower','length','substr',
    'count','sum','avg','min','max','mod','abs','round','trunc','to','trace',
    'debug','file','put','flush','close','open','cursor','with','hold',
    'free','fetch','next','prior','current','last','relative','absolute',
    'prior','at','isolation','level','buffered','unbuffered','committed',
    'repeatable','serializable','dirty','degree','all','none','informix',
    'document','grant','revoke','synonym','sequence','function','aggregate',
    'row','type','reference','constraints','check','default','primary','key',
    'foreign','references','unique','not','null','cascade','restrict',
    'no','action','deferred','immediate','schema','database','connect',
    'disconnect','commit','rollback','savepoint','whenever','sqlerror',
    'go','continue','stop','raise','new','old','referencing','each',
    'statement','before','after','instead','of','enabled','disabled',
    'some','any','every','matches','like','glob','regexp',
    # tipos de datos adicionales
    'char', 'int', 'float', 'double', 'precision', 'numeric', 'number',
    # otros comunes en este corpus
    'cte', 'sv', 'a', 'b', 'c', 't', 'x', 'y', 'z', 'tmp', 'aux',
}

# ── Regex para referencia de tabla cross-DB o local ──────────────────────────
# Grupo 1: db (si cross-DB), Grupo 2: tabla
# Soporta:  tabla,  db:tabla,  db:"schema".tabla,  db@server:tabla,  db@server:"schema".tabla
_TREF = (
    r'([a-zA-Z_][a-zA-Z0-9_]*)(?:@[a-zA-Z0-9_]+)?'    # db[@server] opcional
    r':(?:"[^"]*"\s*\.\s*)?'                            # :"schema". opcional
    r'([a-zA-Z_][a-zA-Z0-9_]*)'                        # nombre tabla
    r'|'
    r'([a-zA-Z_][a-zA-Z0-9_]*)'                        # tabla local (solo un nombre)
)
RE_TREF = re.compile(_TREF, re.IGNORECASE)

# ── DML patterns – capturan la porción de texto que sigue a la palabra clave ──
_DML = [
    # (operación, patrón, modo)
    ('SELECT', re.compile(
        r'\bFROM\b\s+(.+?)(?=\bWHERE\b|\bGROUP\b|\bHAVING\b|\bORDER\b|\bINTO\b'
        r'|\bON\b(?!\s+EXCEPTION)|\bFOREACH\b|\bEND\b|\bRETURN\b|;|\Z)',
        re.IGNORECASE | re.DOTALL), 'multi'),
    ('JOIN',   re.compile(
        r'\b(?:INNER|LEFT|RIGHT|FULL|CROSS)?\s*(?:OUTER\s+)?JOIN\b\s+'
        r'([a-zA-Z_][a-zA-Z0-9_]*(?:@[a-zA-Z0-9_]+)?(?::(?:"[^"]*"\s*\.\s*)?[a-zA-Z_][a-zA-Z0-9_]*)?)',
        re.IGNORECASE), 'single'),
    ('INSERT',  re.compile(
        r'\bINSERT\s+INTO\b\s+'
        r'([a-zA-Z_][a-zA-Z0-9_]*(?:@[a-zA-Z0-9_]+)?(?::(?:"[^"]*"\s*\.\s*)?[a-zA-Z_][a-zA-Z0-9_]*)?)',
        re.IGNORECASE), 'single'),
    ('UPDATE',  re.compile(
        r'\bUPDATE\b\s+'
        r'([a-zA-Z_][a-zA-Z0-9_]*(?:@[a-zA-Z0-9_]+)?(?::(?:"[^"]*"\s*\.\s*)?[a-zA-Z_][a-zA-Z0-9_]*)?)'
        r'\s+SET\b',
        re.IGNORECASE), 'single'),
    ('DELETE',  re.compile(
        r'\bDELETE\s+FROM\b\s+'
        r'([a-zA-Z_][a-zA-Z0-9_]*(?:@[a-zA-Z0-9_]+)?(?::(?:"[^"]*"\s*\.\s*)?[a-zA-Z_][a-zA-Z0-9_]*)?)',
        re.IGNORECASE), 'single'),
]

# Operaciones de escritura
WRITE_OPS = {'INSERT', 'UPDATE', 'DELETE'}
READ_OPS  = {'SELECT', 'JOIN'}


def strip_comments(text: str) -> str:
    """Elimina comentarios SPL: -- linea  y  { bloque }"""
    # Bloques { }
    text = re.sub(r'\{[^}]*\}', ' ', text, flags=re.DOTALL)
    # Línea --
    text = re.sub(r'--[^\n]*', ' ', text)
    return text


def strip_strings(text: str) -> str:
    """Reemplaza literales de cadena ' ... ' con un marcador neutro."""
    return re.sub(r"'[^']*'", "''", text)


def parse_tref(token: str, sp_db: str) -> tuple[str, str] | None:
    """
    Dado un token de referencia de tabla, retorna (ref_db, ref_table).
    Retorna None si el token es una keyword SPL o muy corto.
    """
    token = token.strip()
    m = RE_TREF.match(token)
    if not m:
        return None

    if m.group(1) and m.group(2):           # cross-DB
        db  = m.group(1).lower()
        tbl = m.group(2).lower()
    elif m.group(3):                         # local
        db  = sp_db
        tbl = m.group(3).lower()
    else:
        return None

    if tbl in SPL_KEYWORDS or len(tbl) < 2:
        return None
    if db in SPL_KEYWORDS or len(db) < 3:
        # si 'db' parece keyword, tratar como tabla local
        if m.group(1):                       # era cross-db pero db-part es keyword
            return None
        db = sp_db

    return db, tbl


def extract_refs(content: str, sp_db: str) -> dict[tuple, dict]:
    """
    Extrae referencias de tablas del contenido SPL.
    Retorna {(ref_db, ref_table): {'ops': set, 'line_first': int}}
    """
    clean = strip_strings(strip_comments(content))
    refs: dict[tuple, dict] = {}

    # Reconstruir mapa línea → posición para line_first
    line_starts = [0]
    for ch in content:
        if ch == '\n':
            line_starts.append(line_starts[-1] + 1)
        else:
            line_starts[-1] += 1

    # Mejor: usar enumerate para encontrar la línea de un offset
    newlines = [i for i, c in enumerate(content) if c == '\n']

    def offset_to_line(off: int) -> int:
        lo, hi = 0, len(newlines)
        while lo < hi:
            mid = (lo + hi) // 2
            if newlines[mid] < off:
                lo = mid + 1
            else:
                hi = mid
        return lo + 1

    for op, pattern, mode in _DML:
        is_write = op in WRITE_OPS

        if mode == 'single':
            for m in pattern.finditer(clean):
                token = m.group(1)
                parsed = parse_tref(token, sp_db)
                if not parsed:
                    continue
                ref_db, ref_table = parsed
                key = (ref_db, ref_table)
                line = offset_to_line(m.start())
                if key not in refs:
                    refs[key] = {'ops': set(), 'line_first': line}
                refs[key]['ops'].add(op)

        else:  # mode == 'multi' — FROM clause puede tener N tablas + JOINs implícitos
            for m in pattern.finditer(clean):
                clause = m.group(1)
                start_off = m.start()
                line = offset_to_line(start_off)

                # Dividir por comas (múltiples tablas en FROM)
                # pero cuidar subconsultas (paréntesis) — omitirlas
                depth = 0
                parts = []
                cur = []
                for ch in clause:
                    if ch == '(':
                        depth += 1
                    elif ch == ')':
                        depth -= 1
                    elif ch == ',' and depth == 0:
                        parts.append(''.join(cur).strip())
                        cur = []
                        continue
                    if depth == 0:
                        cur.append(ch)
                parts.append(''.join(cur).strip())

                for part in parts:
                    # Tomar solo el primer token (tabla + posible alias)
                    # e.g. "bdinteg:si_credito_sv sv" → "bdinteg:si_credito_sv"
                    first_token = re.split(r'\s+|\bAS\b', part.strip(), maxsplit=1,
                                           flags=re.IGNORECASE)[0]
                    parsed = parse_tref(first_token, sp_db)
                    if not parsed:
                        continue
                    ref_db, ref_table = parsed
                    key = (ref_db, ref_table)
                    if key not in refs:
                        refs[key] = {'ops': set(), 'line_first': line}
                    refs[key]['ops'].add('SELECT' if op == 'SELECT' else op)

    return refs


def read_file(path: Path) -> str:
    for enc in ('utf-8', 'latin-1', 'cp1252'):
        try:
            return path.read_text(encoding=enc, errors='strict')
        except (UnicodeDecodeError, ValueError):
            continue
    return path.read_text(encoding='latin-1', errors='replace')


def main():
    print("=== extract-table-refs.py ===")
    print(f"Corpus  : {SRC}")
    print(f"Brain   : {DB}")

    # ── Abrir brain.db ────────────────────────────────────────────────────────
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row

    # ── Crear tabla sp_table_refs ─────────────────────────────────────────────
    conn.executescript("""
        DROP TABLE IF EXISTS sp_table_refs;
        CREATE TABLE sp_table_refs (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            sp_id       TEXT NOT NULL,
            sp_name     TEXT NOT NULL,
            sp_db       TEXT NOT NULL,
            ref_table   TEXT NOT NULL,
            ref_db      TEXT NOT NULL,
            access_type TEXT NOT NULL,
            operations  TEXT NOT NULL,
            is_cross_db INTEGER NOT NULL DEFAULT 0,
            line_first  INTEGER
        );
        CREATE INDEX idx_sptr_sp_id   ON sp_table_refs(sp_id);
        CREATE INDEX idx_sptr_table   ON sp_table_refs(ref_table);
        CREATE INDEX idx_sptr_ref_db  ON sp_table_refs(ref_db);
    """)
    conn.commit()
    print("Tabla sp_table_refs creada.")

    # ── Cargar IDs canónicos desde brain.db ───────────────────────────────────
    sp_ids: dict[tuple, str] = {}
    for row in conn.execute("SELECT id, name, db FROM sps"):
        sp_ids[(row['db'], row['name'])] = row['id']

    # ── Procesar archivos ─────────────────────────────────────────────────────
    sql_files = sorted(p for p in SRC.iterdir() if p.suffix == '.sql')
    total = len(sql_files)
    print(f"Archivos: {total:,}")

    inserted = 0
    skipped  = 0
    no_id    = 0

    batch: list[tuple] = []
    BATCH_SIZE = 500

    for idx, path in enumerate(sql_files, 1):
        # Parsear filename → sp_db, sp_name
        stem = path.stem                # e.g. "bdiaclaracion_sp_acl_actualizaempaclaracion"
        underscore_pos = stem.find('_')
        if underscore_pos < 0:
            skipped += 1
            continue
        sp_db   = stem[:underscore_pos].lower()
        sp_name = stem[underscore_pos + 1:].lower()

        canonical_id = sp_ids.get((sp_db, sp_name))
        if not canonical_id:
            # Intentar con variantes (algunos nombres tienen prefijo de db repetido)
            canonical_id = f"{sp_db}:{sp_name}"
            no_id += 1

        content = read_file(path)
        refs = extract_refs(content, sp_db)

        for (ref_db, ref_table), info in refs.items():
            ops = sorted(info['ops'])
            r_ops = set(ops) & READ_OPS
            w_ops = set(ops) & WRITE_OPS
            if r_ops and w_ops:
                access = 'RW'
            elif w_ops:
                access = 'W'
            else:
                access = 'R'

            batch.append((
                canonical_id,
                sp_name,
                sp_db,
                ref_table,
                ref_db,
                access,
                json.dumps(ops),
                1 if ref_db != sp_db else 0,
                info['line_first'],
            ))
            inserted += 1

        if len(batch) >= BATCH_SIZE:
            conn.executemany("""
                INSERT INTO sp_table_refs
                    (sp_id, sp_name, sp_db, ref_table, ref_db,
                     access_type, operations, is_cross_db, line_first)
                VALUES (?,?,?,?,?,?,?,?,?)
            """, batch)
            conn.commit()
            batch.clear()

        if idx % 1000 == 0:
            print(f"  {idx:,}/{total:,} procesados — refs acumuladas: {inserted:,}")

    if batch:
        conn.executemany("""
            INSERT INTO sp_table_refs
                (sp_id, sp_name, sp_db, ref_table, ref_db,
                 access_type, operations, is_cross_db, line_first)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, batch)
        conn.commit()

    # ── Resumen ───────────────────────────────────────────────────────────────
    total_refs  = conn.execute("SELECT COUNT(*) FROM sp_table_refs").fetchone()[0]
    total_sps   = conn.execute("SELECT COUNT(DISTINCT sp_id) FROM sp_table_refs").fetchone()[0]
    total_tbls  = conn.execute("SELECT COUNT(DISTINCT ref_table||':'||ref_db) FROM sp_table_refs").fetchone()[0]
    cross_db    = conn.execute("SELECT COUNT(*) FROM sp_table_refs WHERE is_cross_db=1").fetchone()[0]
    rw_refs     = conn.execute("SELECT COUNT(*) FROM sp_table_refs WHERE access_type='RW'").fetchone()[0]
    write_refs  = conn.execute("SELECT COUNT(*) FROM sp_table_refs WHERE access_type='W'").fetchone()[0]
    read_refs   = conn.execute("SELECT COUNT(*) FROM sp_table_refs WHERE access_type='R'").fetchone()[0]

    print("\n── Resultado ──────────────────────────────────────────────")
    print(f"  Refs totales insertas : {total_refs:,}")
    print(f"  SPs con al menos 1 ref: {total_sps:,}")
    print(f"  Tablas únicas         : {total_tbls:,}")
    print(f"  Cross-DB refs         : {cross_db:,}")
    print(f"  R (solo lectura)      : {read_refs:,}")
    print(f"  W (solo escritura)    : {write_refs:,}")
    print(f"  RW (lectura+escritura): {rw_refs:,}")
    print(f"  Archivos sin ID brain : {no_id:,}")
    print(f"  Archivos saltados     : {skipped:,}")

    # ── Top 10 tablas más referenciadas ───────────────────────────────────────
    print("\n── Top 10 tablas más referenciadas ────────────────────────")
    rows = conn.execute("""
        SELECT ref_db, ref_table, COUNT(DISTINCT sp_id) as n_sps
        FROM sp_table_refs
        GROUP BY ref_db, ref_table
        ORDER BY n_sps DESC
        LIMIT 10
    """).fetchall()
    for r in rows:
        print(f"  {r['ref_db']:20s} . {r['ref_table']:40s}  {r['n_sps']:,} SPs")

    conn.close()
    print("\nDone.")


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""enrich-d17-d49.py — Extrae biz + reglas de los 415 SPs de D17-D49
Parsea los archivos SQL fuente en source/BCOPCore/informix/{db}_{sp}.sql
y actualiza brain.db directamente con:
  - sps.biz (descripción de negocio inferida del código)
  - rules (reglas de negocio extraídas: IF/WHEN/ON EXCEPTION)
  - sps.rules_n (conteo actualizado)

Uso:
  cd BCOPCore/
  python generators/enrich-d17-d49.py
"""

import re
import sqlite3
import sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE       = Path(__file__).resolve().parent.parent
SOURCE_DIR = BASE / "source" / "BCOPCore" / "informix"
DB_PATH    = BASE / "digital-brain" / "brain.db"

# D17-D49 databases con sus dominios
D17_DATABASES = {
    'bdmis':          'D23',
    'bdiprospectos':  'D26',
    'bdireports':     'D32',
    'bdiresp':        'D34',
    'bdidigital':     'D35',
    'bdirepaut':      'D36',
    'bdiadminnomina': 'D37',
    'bdibi':          'D40',
    'bdirech':        'D44',
    'bdiprem':        'D45',
    'bdiofi':         'D46',
    'bdigaran':       'D47',
    'bdiriesgos':     'D48',
    'bdirst':         'D49',
}

# ── Abreviaturas de prefijos en nombres de SPs ─────────────────────────────
ABBREV = {
    'sp': '', 'ins': 'inserta', 'upd': 'actualiza', 'del': 'elimina',
    'cons': 'consulta', 'val': 'valida', 'gen': 'genera', 'obt': 'obtiene',
    'calc': 'calcula', 'reg': 'registra', 'env': 'envía', 'rec': 'recibe',
    'proc': 'procesa', 'carga': 'carga', 'act': 'actualiza', 'alta': 'alta',
    'baja': 'baja', 'mod': 'modifica', 'obtiene': 'obtiene', 'reporta': 'reporta',
    'crea': 'crea', 'abre': 'abre', 'cierra': 'cierra', 'verif': 'verifica',
    'autent': 'autentica', 'autoriza': 'autoriza', 'cancela': 'cancela',
    'reversa': 'reversa', 'concilia': 'concilia', 'repor': 'reporta',
    'agrupa': 'agrupa', 'calcula': 'calcula', 'migra': 'migra',
    'cargasp': 'carga SPs', 'rpts': 'reportes',
}


def deverbalize(sp_name: str) -> str:
    """Convierte nombre de SP a descripción legible."""
    name = sp_name.lower()
    # Quitar prefijos db_ si los hay (ej. sp_rech_)
    for db_prefix in D17_DATABASES:
        name = name.replace(f'{db_prefix}_', '')
    parts = re.split(r'[_\-]', name)
    out = []
    for p in parts:
        if p == 'sp' or p == '':
            continue
        out.append(ABBREV.get(p, p))
    return ' '.join(out) if out else sp_name


def extract_biz_from_sql(sql_text: str, sp_name: str) -> str:
    """Extrae descripción de negocio del SQL:
    1. Primer comentario significativo (-- descripcion)
    2. Deverbalization del nombre del SP
    """
    lines = sql_text.splitlines()
    # Buscar comentarios descriptivos cerca del inicio (primeras 25 líneas)
    comment_re = re.compile(r'^\s*--+\s*(.+)$')
    found_proc = False
    for line in lines[:40]:
        upper = line.upper().strip()
        if 'CREATE PROCEDURE' in upper or 'CREATE FUNCTION' in upper:
            found_proc = True
            continue
        if found_proc:
            m = comment_re.match(line)
            if m:
                text = m.group(1).strip()
                # Filtrar comentarios puramente técnicos o de debug
                if len(text) > 5 and not any(k in text.lower() for k in
                   ['debug', 'trace', 'set debug', 'trace on', '====', '----',
                    'created by', 'modified', 'fecha', 'autor', 'version',
                    'copyright', 'revision', '-----']):
                    return text.lower()
    # Fallback: deverbalize
    return deverbalize(sp_name)


# ── Patrones de extracción de reglas ───────────────────────────────────────

# IF <cond> THEN (multi-línea hasta END IF)
_IF_BLOCK = re.compile(
    r'\bIF\s+(.+?)\s+THEN\b',
    re.IGNORECASE | re.DOTALL
)

# ON EXCEPTION [SET var] — captura la condición
_EXCEPT = re.compile(
    r'\bON\s+EXCEPTION\b(?:\s+(?:SET\s+\w+|IN\s*\([^)]+\)))?',
    re.IGNORECASE
)

# RAISE EXCEPTION (code, ...)
_RAISE = re.compile(
    r'\bRAISE\s+EXCEPTION\s*\(([^)]+)\)',
    re.IGNORECASE
)

# RETURN <code> — validación de salida
_RETURN_CODE = re.compile(
    r'\bRETURN\s+(["\'-]?\w+["\'-]?)\s*;',
    re.IGNORECASE
)

# WHENEVER ERROR — manejador de errores
_WHENEVER = re.compile(
    r'\bWHENEVER\s+ERROR\b(.{0,80})',
    re.IGNORECASE
)

# INSERT / UPDATE / DELETE — identifica operaciones DML (tipo LOGICA)
_DML = re.compile(
    r'\b(INSERT\s+INTO|UPDATE\s+\w+\s+SET|DELETE\s+FROM)\b',
    re.IGNORECASE
)


def classify_condition(cond: str) -> str:
    """Clasifica la condición de un IF para determinar tipo de regla."""
    c = cond.upper()
    if any(k in c for k in ['IS NULL', 'IS NOT NULL', '= ""', "= ''"]):
        return 'VALIDACION'
    if any(k in c for k in ['SQLCODE', 'SQLERR', 'ISAM', 'STATUS']):
        return 'EXCEPCION'
    if any(k in c for k in ['<', '>', '<=', '>=', '<>', '!=']):
        return 'VALIDACION'
    return 'LOGICA'


def clean_cond(cond: str) -> str:
    """Limpia y trunca la condición para almacenar."""
    cond = re.sub(r'\s+', ' ', cond).strip()
    return cond[:200] if len(cond) > 200 else cond


def extract_rules(sql_text: str, sp_name: str, db: str, domain: str) -> list[dict]:
    """Extrae reglas de negocio del SQL fuente.
    Retorna lista de dicts con: tipo, code, domain, riesgo, line.
    """
    rules = []
    lines = sql_text.splitlines()
    seen_codes = set()

    # 1. IF conditions → VALIDACION / LOGICA
    for m in _IF_BLOCK.finditer(sql_text):
        cond = clean_cond(m.group(1))
        if len(cond) < 5:
            continue
        tipo = classify_condition(cond)
        code_key = f'IF:{cond[:80]}'
        if code_key in seen_codes:
            continue
        seen_codes.add(code_key)
        # Estimar línea (posición del match en el texto)
        lineno = sql_text[:m.start()].count('\n') + 1
        # Riesgo: ALTO si involucra dinero o control de flujo crítico
        riesgo = 'ALTO' if any(k in cond.upper() for k in
                               ['MONEY', 'MONTO', 'SALDO', 'IMPORTE',
                                'COMMIT', 'ROLLBACK', 'DEADLOCK']) else 'BAJO'
        rules.append({
            'tipo': tipo,
            'code': f'IF {cond}',
            'domain': domain,
            'riesgo': riesgo,
            'line': lineno,
        })

    # 2. ON EXCEPTION → EXCEPCION
    for m in _EXCEPT.finditer(sql_text):
        code_key = f'EXCEPT:{m.group(0)[:60]}'
        if code_key in seen_codes:
            continue
        seen_codes.add(code_key)
        lineno = sql_text[:m.start()].count('\n') + 1
        rules.append({
            'tipo': 'EXCEPCION',
            'code': clean_cond(m.group(0)),
            'domain': domain,
            'riesgo': 'MEDIO',
            'line': lineno,
        })

    # 3. RAISE EXCEPTION → EXCEPCION con código
    for m in _RAISE.finditer(sql_text):
        args = clean_cond(m.group(1))
        code_key = f'RAISE:{args[:60]}'
        if code_key in seen_codes:
            continue
        seen_codes.add(code_key)
        lineno = sql_text[:m.start()].count('\n') + 1
        rules.append({
            'tipo': 'EXCEPCION',
            'code': f'RAISE EXCEPTION ({args})',
            'domain': domain,
            'riesgo': 'ALTO',
            'line': lineno,
        })

    return rules


# ── Parser principal por archivo SQL ───────────────────────────────────────

def parse_sql_file(path: Path, db: str, domain: str) -> dict:
    """Parsea un archivo SQL y retorna {sp_name, biz, rules, loc}."""
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
    except Exception as e:
        return {'error': str(e)}

    lines = text.splitlines()
    loc = len(lines)

    # Extraer nombre del SP del filename: {db}_{sp_name}.sql
    fname = path.stem  # sin .sql
    sp_name = fname[len(db) + 1:]  # quitar prefijo "db_"

    biz = extract_biz_from_sql(text, sp_name)
    rules = extract_rules(text, sp_name, db, domain)

    return {
        'sp_name': sp_name,
        'db': db,
        'domain': domain,
        'biz': biz,
        'loc': loc,
        'rules': rules,
    }


# ── Actualizar brain.db ────────────────────────────────────────────────────

def update_brain(con: sqlite3.Connection, parsed: list[dict]) -> dict:
    """Inserta biz y reglas en brain.db para los SPs D17-D49."""
    biz_updated = 0
    rules_inserted = 0
    sps_not_found = 0

    for sp in parsed:
        if 'error' in sp:
            continue

        sp_id = f"{sp['db']}:{sp['sp_name']}"
        db = sp['db']
        biz = sp['biz']
        rules = sp['rules']
        domain = sp['domain']

        # Verificar que el SP existe en brain.db
        row = con.execute('SELECT id, biz FROM sps WHERE id=?', (sp_id,)).fetchone()
        if not row:
            # Intentar buscar por nombre corto
            row = con.execute(
                'SELECT id, biz FROM sps WHERE name=? AND db=?',
                (sp['sp_name'], db)
            ).fetchone()
            if not row:
                sps_not_found += 1
                continue
            sp_id = row[0]

        current_biz = row[1]

        # Actualizar biz si está vacío
        if not current_biz or current_biz.strip() == '':
            con.execute('UPDATE sps SET biz=?, biz_estado=? WHERE id=?',
                        (biz, 'infer', sp_id))
            biz_updated += 1

        # Insertar reglas
        for r in rules:
            try:
                con.execute('''
                    INSERT OR IGNORE INTO rules
                    (tipo, sp, db, domain, line, code, reg, riesgo)
                    VALUES (?,?,?,?,?,?,?,?)
                ''', (r['tipo'], sp['sp_name'], db, domain,
                      r['line'], r['code'], '[]', r['riesgo']))
                rules_inserted += 1
            except Exception:
                pass

        # Actualizar rules_n
        n_rules = con.execute(
            'SELECT COUNT(*) FROM rules WHERE sp=? AND db=?',
            (sp['sp_name'], db)
        ).fetchone()[0]
        con.execute('UPDATE sps SET rules_n=? WHERE id=?', (n_rules, sp_id))

    con.commit()
    return {'biz_updated': biz_updated, 'rules_inserted': rules_inserted,
            'sps_not_found': sps_not_found}


# ── Main ───────────────────────────────────────────────────────────────────

def main():
    print("=" * 60)
    print("BCOPCore — enrich-d17-d49.py")
    print(f"Source: {SOURCE_DIR}")
    print(f"Brain:  {DB_PATH}")
    print("=" * 60)

    if not DB_PATH.exists():
        print("ERROR: brain.db no existe. Ejecutar build-brain.py primero.")
        sys.exit(1)

    all_parsed: list[dict] = []
    file_count = 0

    for db, domain in D17_DATABASES.items():
        sql_files = sorted(SOURCE_DIR.glob(f"{db}_*.sql"))
        if not sql_files:
            print(f"  {db} ({domain}): 0 archivos SQL — skipped")
            continue

        parsed_db: list[dict] = []
        for sql_path in sql_files:
            result = parse_sql_file(sql_path, db, domain)
            parsed_db.append(result)
            file_count += 1

        rules_total = sum(len(p.get('rules', [])) for p in parsed_db if 'error' not in p)
        print(f"  {db} ({domain}): {len(sql_files):3d} SPs · {rules_total:4d} reglas extraídas")
        all_parsed.extend(parsed_db)

    print(f"\nTotal archivos procesados : {file_count}")
    total_rules = sum(len(p.get('rules', [])) for p in all_parsed if 'error' not in p)
    print(f"Total reglas extraídas    : {total_rules}")

    print("\nActualizando brain.db...")
    con = sqlite3.connect(DB_PATH)
    stats = update_brain(con, all_parsed)
    con.close()

    print(f"  biz actualizados  : {stats['biz_updated']}")
    print(f"  reglas insertadas : {stats['rules_inserted']}")
    print(f"  SPs no encontrados: {stats['sps_not_found']}")
    print("\nDone. Ejecutar build-sp-fine-mapping.py para actualizar ETB L3.")


if __name__ == '__main__':
    main()
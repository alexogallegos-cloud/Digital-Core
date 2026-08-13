#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
load-missing-domains.py — Carga los 19 dominios D17-D49 ausentes en brain.db

Inserta en brain.db los SPs que existen en source/ pero no están en sps:
  D17 bdibpi · D18 intercardbpi · D19 bditarjeta · D20 bdiprog
  D21 bdidomi · D22 bditransfer · D24 bdiburo · D25 bdisitesp
  D27 bdiauditor · D28 bdinvers · D29 bdiedoelec · D30 bditarjcop
  D31 bdicntchq · D33 bdimonitorcob · D38 bdicplbot · D39 bdiservicios
  D41 bdicorresp · D42 bdivr · D43 bditrapres

Qué hace:
  1. Parsea SQL fuente → extrae biz, loc, reglas
  2. INSERT OR IGNORE into sps (id=db:sp_name)
  3. INSERT rules
  4. Reconstruye índice FTS sps_fts

SPE-AM-001 · BCOPBrain · 2026-08-12
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

# ── 19 dominios ausentes en brain.db ──────────────────────────────────────────
MISSING_DOMAINS: dict[str, tuple[str, str]] = {
    # db_name        : (domain_id, domain_label)
    'bdibpi':         ('D17', 'BPI'),
    'intercardbpi':   ('D18', 'Intercard BPI'),
    'bditarjeta':     ('D19', 'Tarjetas'),
    'bdiprog':        ('D20', 'Programas'),
    'bdidomi':        ('D21', 'Domiciliación'),
    'bditransfer':    ('D22', 'Transferencias'),
    'bdiburo':        ('D24', 'Buró de Crédito'),
    'bdisitesp':      ('D25', 'Sitio Especial'),
    'bdiauditor':     ('D27', 'Auditoría'),
    'bdinvers':       ('D28', 'Inversiones'),
    'bdiedoelec':     ('D29', 'Estados de Cuenta Electrónicos'),
    'bditarjcop':     ('D30', 'Tarjetas Coppel'),
    'bdicntchq':      ('D31', 'Control de Cheques'),
    'bdimonitorcob':  ('D33', 'Monitor de Cobranza'),
    'bdicplbot':      ('D38', 'CPL Bot'),
    'bdiservicios':   ('D39', 'Servicios'),
    'bdicorresp':     ('D41', 'Corresponsalía'),
    'bdivr':          ('D42', 'IVR'),
    'bditrapres':     ('D43', 'Transferencias Presenciales'),
}

# ── Abreviaturas de deverbalizacion ───────────────────────────────────────────
ABBREV = {
    'sp': '', 'ins': 'inserta', 'upd': 'actualiza', 'del': 'elimina',
    'cons': 'consulta', 'val': 'valida', 'gen': 'genera', 'obt': 'obtiene',
    'calc': 'calcula', 'reg': 'registra', 'env': 'envía', 'rec': 'recibe',
    'proc': 'procesa', 'carga': 'carga', 'act': 'actualiza', 'alta': 'alta',
    'baja': 'baja', 'mod': 'modifica', 'obtiene': 'obtiene', 'reporta': 'reporta',
    'crea': 'crea', 'abre': 'abre', 'cierra': 'cierra', 'verif': 'verifica',
    'autent': 'autentica', 'autoriza': 'autoriza', 'cancela': 'cancela',
    'reversa': 'reversa', 'concilia': 'concilia', 'repor': 'reporta',
}

_COMMENT_RE  = re.compile(r'^\s*--\s*(.+)$')
_IF_BLOCK    = re.compile(r'\bIF\s+(.+?)\s+THEN\b', re.IGNORECASE | re.DOTALL)
_EXCEPT      = re.compile(r'\bON\s+EXCEPTION\b(?:\s+(?:SET\s+\w+|IN\s*\([^)]+\)))?', re.IGNORECASE)
_RAISE       = re.compile(r'\bRAISE\s+EXCEPTION\s*\(([^)]+)\)', re.IGNORECASE)


def deverbalize(sp_name: str) -> str:
    parts = re.split(r'[_\-]', sp_name.lower())
    out = []
    for p in parts:
        if p in ('sp', ''):
            continue
        out.append(ABBREV.get(p, p))
    return ' '.join(out) if out else sp_name


def extract_biz(sql_text: str, sp_name: str) -> str:
    found_proc = False
    for line in sql_text.splitlines():
        upper = line.upper().strip()
        if 'CREATE PROCEDURE' in upper or 'CREATE FUNCTION' in upper:
            found_proc = True
            continue
        if found_proc:
            m = _COMMENT_RE.match(line)
            if m:
                text = m.group(1).strip()
                if len(text) > 5 and not any(k in text.lower() for k in
                   ['debug', 'trace', '====', '----', 'created by', 'modified',
                    'fecha', 'autor', 'version', 'copyright', 'revision', '-----']):
                    return text.lower()
    return deverbalize(sp_name)


def clean_cond(cond: str) -> str:
    cond = re.sub(r'\s+', ' ', cond).strip()
    return cond[:200]


def classify_condition(cond: str) -> str:
    c = cond.upper()
    if any(k in c for k in ['IS NULL', 'IS NOT NULL', '= ""', "= ''"]):
        return 'VALIDACION'
    if any(k in c for k in ['SQLCODE', 'SQLERR', 'ISAM', 'STATUS']):
        return 'EXCEPCION'
    if any(k in c for k in ['<', '>', '<=', '>=', '<>', '!=']):
        return 'VALIDACION'
    return 'LOGICA'


def extract_rules(sql_text: str, db: str, domain: str) -> list[dict]:
    rules = []
    seen = set()

    for m in _IF_BLOCK.finditer(sql_text):
        cond = clean_cond(m.group(1))
        if len(cond) < 5:
            continue
        key = f'IF:{cond[:80]}'
        if key in seen:
            continue
        seen.add(key)
        lineno = sql_text[:m.start()].count('\n') + 1
        riesgo_val = 'ALTO' if any(k in cond.upper() for k in
                                   ['MONEY', 'MONTO', 'SALDO', 'IMPORTE',
                                    'COMMIT', 'ROLLBACK', 'DEADLOCK']) else 'BAJO'
        rules.append({'tipo': classify_condition(cond), 'code': f'IF {cond}',
                      'domain': domain, 'riesgo': riesgo_val, 'line': lineno})

    for m in _EXCEPT.finditer(sql_text):
        key = f'EXCEPT:{m.group(0)[:60]}'
        if key in seen:
            continue
        seen.add(key)
        lineno = sql_text[:m.start()].count('\n') + 1
        rules.append({'tipo': 'EXCEPCION', 'code': clean_cond(m.group(0)),
                      'domain': domain, 'riesgo': 'MEDIO', 'line': lineno})

    for m in _RAISE.finditer(sql_text):
        args = clean_cond(m.group(1))
        key = f'RAISE:{args[:60]}'
        if key in seen:
            continue
        seen.add(key)
        lineno = sql_text[:m.start()].count('\n') + 1
        rules.append({'tipo': 'EXCEPCION', 'code': f'RAISE EXCEPTION ({args})',
                      'domain': domain, 'riesgo': 'ALTO', 'line': lineno})

    return rules


def parse_file(path: Path, db: str, domain: str) -> dict:
    try:
        text = path.read_text(encoding='utf-8', errors='replace')
    except Exception as e:
        return {'error': str(e)}
    sp_name = path.stem[len(db) + 1:]  # quitar prefijo "db_"
    return {
        'sp_name': sp_name,
        'sp_id':   f'{db}:{sp_name}',
        'db':      db,
        'domain':  domain,
        'biz':     extract_biz(text, sp_name),
        'loc':     len(text.splitlines()),
        'rules':   extract_rules(text, db, domain),
    }


def load_into_brain(con: sqlite3.Connection, parsed: list[dict]) -> dict:
    inserted = skipped = rules_ins = 0
    for sp in parsed:
        if 'error' in sp:
            continue
        # Verificar si ya existe
        exists = con.execute('SELECT 1 FROM sps WHERE id=?', (sp['sp_id'],)).fetchone()
        if exists:
            skipped += 1
            continue
        # INSERT nuevo SP
        con.execute('''
            INSERT OR IGNORE INTO sps
              (id, name, label, db, domain, loc, biz, biz_estado,
               fan_in, fan_out, rules_n, is_soul, complexity, weaknesses,
               params_n, tables_n, calls_n, authors_n)
            VALUES (?,?,?,?,?,?,?,?,0,0,0,0,0,0,0,0,0,0)
        ''', (sp['sp_id'], sp['sp_name'], sp['sp_name'].replace('_', ' '),
              sp['db'], sp['domain'], sp['loc'], sp['biz'], 'infer'))
        inserted += 1
        # INSERT rules
        for r in sp['rules']:
            try:
                con.execute('''
                    INSERT OR IGNORE INTO rules
                      (tipo, sp, db, domain, line, code, reg, riesgo, business_name)
                    VALUES (?,?,?,?,?,?,?,?,?)
                ''', (r['tipo'], sp['sp_name'], sp['db'], r['domain'],
                      r['line'], r['code'], '[]', r['riesgo'],
                      f"{r['tipo'].lower()}: {r['code'][:60]}"))
                rules_ins += 1
            except Exception:
                pass
        # Actualizar rules_n
        n = con.execute('SELECT COUNT(*) FROM rules WHERE sp=? AND db=?',
                        (sp['sp_name'], sp['db'])).fetchone()[0]
        con.execute('UPDATE sps SET rules_n=? WHERE id=?', (n, sp['sp_id']))

    con.commit()
    return {'inserted': inserted, 'skipped': skipped, 'rules': rules_ins}


def rebuild_fts(con: sqlite3.Connection):
    """Reconstruye índice FTS para sps_fts."""
    try:
        con.execute("INSERT INTO sps_fts(sps_fts) VALUES('rebuild')")
        con.commit()
        print("  FTS sps_fts reconstruido")
    except Exception as e:
        print(f"  FTS rebuild: {e} (no crítico)")


def main():
    print("=" * 60)
    print("BCOPCore — load-missing-domains.py")
    print(f"Source: {SOURCE_DIR}")
    print(f"Brain:  {DB_PATH}")
    print("=" * 60)

    if not DB_PATH.exists():
        print("ERROR: brain.db no encontrado.")
        sys.exit(1)

    all_parsed: list[dict] = []
    for db, (domain, label) in sorted(MISSING_DOMAINS.items()):
        sql_files = sorted(SOURCE_DIR.glob(f"{db}_*.sql"))
        if not sql_files:
            print(f"  {db} ({domain} {label}): sin archivos SQL — skip")
            continue
        parsed = [parse_file(f, db, domain) for f in sql_files]
        all_parsed.extend(parsed)
        n_rules = sum(len(p.get('rules', [])) for p in parsed if 'error' not in p)
        print(f"  {db:<18} ({domain} {label}): {len(sql_files):>4} SPs · {n_rules:>5} reglas")

    total_sps   = len(all_parsed)
    total_rules = sum(len(p.get('rules', [])) for p in all_parsed if 'error' not in p)
    print(f"\nTotal a cargar: {total_sps:,} SPs · {total_rules:,} reglas")

    con = sqlite3.connect(DB_PATH)
    stats = load_into_brain(con, all_parsed)

    print(f"\n── Resultado ─────────────────────────────────────────────")
    print(f"  Insertados  : {stats['inserted']:,} SPs")
    print(f"  Ya existían : {stats['skipped']:,} SPs")
    print(f"  Reglas ins. : {stats['rules']:,}")

    rebuild_fts(con)
    con.close()

    print(f"\nSiguiente paso: python generators/build-sp-fine-mapping.py")
    print("Done.")


if __name__ == '__main__':
    main()
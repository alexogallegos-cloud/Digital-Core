"""
enrich-return-codes.py — Enriquecer CÓDIGO_RETORNO con la condición IF que los dispara

Para cada regla CÓDIGO_RETORNO con business_name genérico:
  1. Lee el archivo fuente (.sql)
  2. Busca hacia atrás desde rule.line el IF/ELIF/ELSE más cercano
  3. Extrae la condición limpia
  4. Actualiza business_name en brain.db

También produce:
  - portal/data/return-code-catalog.json   ← catálogo code_value → {semántica, SPs, count}
  - reporte de consola con los enriquecimientos

Uso:
  python generators/enrich-return-codes.py            # dry-run (solo imprime)
  python generators/enrich-return-codes.py --apply    # escribe en brain.db
"""

import sqlite3, re, json, sys, unicodedata
from pathlib import Path
from collections import defaultdict

BASE    = Path(__file__).resolve().parent.parent
BRAIN   = BASE / 'digital-brain' / 'brain.db'
SRC_DIR = BASE / 'source' / 'informix' / 'informix'
OUT_DIR = BASE / 'portal' / 'data'

APPLY   = '--apply' in sys.argv
LOOKBACK = 30   # lines to search backward for IF condition

# Generic patterns that signal "no useful semantics yet"
_GENERIC_RE = re.compile(
    r'^(retorna c[oó]digo de error|calcular c[oó]digo|retorna c[oó]digo)',
    re.I
)

# ── Source file resolution ────────────────────────────────────────────────────

_src_cache: dict[str, list[str] | None] = {}

def load_source(db: str, sp: str) -> list[str] | None:
    key = f'{db}_{sp}'
    if key in _src_cache:
        return _src_cache[key]
    # sp column in brain.db is "db:sp_name"
    sp_name = sp.split(':')[-1] if ':' in sp else sp
    path = SRC_DIR / f'{db}_{sp_name}.sql'
    if not path.exists():
        _src_cache[key] = None
        return None
    try:
        lines = path.read_text(encoding='latin-1').splitlines()
    except Exception:
        lines = None
    _src_cache[key] = lines
    return lines


# ── Condition extraction ─────────────────────────────────────────────────────

_IF_RE   = re.compile(r'^(IF|ELIF)\s+(.+?)\s+THEN\s*$', re.I)
_IF2_RE  = re.compile(r'^(IF|ELIF)\s+(.+)', re.I)     # no THEN on same line
_ELSE_RE = re.compile(r'^ELSE\b', re.I)
_WHEN_RE = re.compile(r'^WHEN\s+(OTHERS|EXCEPTION|ERROR)\b', re.I)

def get_indent(line: str) -> int:
    return len(line) - len(line.lstrip())


def find_trigger_condition(lines: list[str], rule_idx: int) -> str | None:
    """
    Search backward from rule_idx for the nearest IF/ELIF/ELSE that contains
    the LET statement.  Returns cleaned condition text or None.
    """
    rule_indent = get_indent(lines[rule_idx])

    for i in range(rule_idx - 1, max(-1, rule_idx - LOOKBACK), -1):
        line = lines[i]
        stripped = line.strip()
        if not stripped or stripped.startswith('--'):
            continue

        indent = get_indent(line)

        # Must be at a lower indent level (enclosing block)
        if indent >= rule_indent:
            continue

        up = stripped.upper()

        # WHEN OTHERS / WHEN EXCEPTION in EXCEPTION block
        if _WHEN_RE.match(up):
            return "EXCEPTION (error inesperado del sistema)"

        # ELSE
        if _ELSE_RE.match(up):
            return _resolve_else(lines, i, indent)

        # IF / ELIF with THEN on same line
        m = _IF_RE.match(stripped)
        if m:
            cond = m.group(2).strip()
            return _clean_condition(cond)

        # IF / ELIF without THEN (multiline condition)
        m2 = _IF2_RE.match(stripped)
        if m2:
            cond = m2.group(2).strip()
            # collect continuation lines
            for j in range(i + 1, min(len(lines), i + 5)):
                cont = lines[j].strip()
                if re.match(r'THEN\s*$', cont, re.I):
                    break
                cond += ' ' + cont
            return _clean_condition(cond)

    return None


def _resolve_else(lines: list[str], else_idx: int, else_indent: int) -> str:
    """For ELSE, find the preceding IF condition to frame it as 'not(condition)'."""
    for i in range(else_idx - 1, max(-1, else_idx - LOOKBACK), -1):
        line = lines[i]
        stripped = line.strip()
        if not stripped or stripped.startswith('--'):
            continue
        indent = get_indent(line)
        if indent > else_indent:
            continue

        m = _IF_RE.match(stripped) or _IF2_RE.match(stripped)
        if m:
            cond = m.group(2).strip()
            cond = re.sub(r'\s+THEN\s*$', '', cond, flags=re.I).strip()
            return f"ELSE (ninguna condición anterior: {_clean_condition(cond)})"

    return "ELSE (complemento de condición previa)"


def _clean_condition(cond: str) -> str:
    """Remove trailing THEN, excess whitespace, inline comments."""
    cond = re.sub(r'\s*--.*$', '', cond)        # strip inline comment first
    cond = re.sub(r'\s+THEN\s*$', '', cond, flags=re.I)
    cond = re.sub(r'\s+', ' ', cond).strip()
    return cond[:200]                            # cap at 200 chars


# ── Inline comment extraction ─────────────────────────────────────────────────

_INLINE_CMT_RE = re.compile(r'--\s*(.+)$')

def extract_inline_comment(code: str) -> str | None:
    m = _INLINE_CMT_RE.search(code)
    if m:
        return m.group(1).strip()
    return None


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    conn = sqlite3.connect(BRAIN)
    conn.row_factory = sqlite3.Row

    rows = conn.execute('''
        SELECT id, sp, db, line, code, business_name
        FROM rules
        WHERE sub_tipo = "CÓDIGO_RETORNO"
        ORDER BY db, sp, line
    ''').fetchall()

    total       = len(rows)
    enriched    = 0
    from_comment= 0
    from_if     = 0
    not_found   = 0
    already_ok  = 0

    # code_value → {semantics: set, sps: set, count: int}
    catalog: dict[str, dict] = defaultdict(lambda: {
        'semantics': set(), 'sps': set(), 'count': 0
    })

    updates: list[tuple[str, str]] = []   # (new_biz, rule_id)

    for row in rows:
        rule_id  = row['id']
        sp       = row['sp']
        db       = row['db']
        line_no  = row['line']      # 1-based
        code     = row['code']
        biz      = row['business_name'] or ''

        # Extract code value
        m = re.search(r"['\"]([^'\"]+)['\"]", code)
        code_val = m.group(1) if m else '?'

        # Determine if enrichment needed
        needs_enrich = bool(_GENERIC_RE.match(biz.strip()))

        lines = load_source(db, sp)
        new_biz = biz

        if needs_enrich and lines:
            idx = line_no - 1   # 0-based

            # Priority 1: inline comment on the LET line
            comment = extract_inline_comment(code)
            if comment and not _GENERIC_RE.match(comment):
                new_biz = comment.strip()
                from_comment += 1
            else:
                # Priority 2: IF/ELIF condition above the LET
                condition = find_trigger_condition(lines, idx) if 0 <= idx < len(lines) else None
                if condition:
                    new_biz = f"[{code_val}] {condition}"
                    from_if += 1
                else:
                    not_found += 1

            if new_biz != biz:
                enriched += 1
                updates.append((new_biz, rule_id))
                def _p(s): return s.encode('ascii', 'replace').decode()
                print(f"  {rule_id}  {sp}  '{code_val}'")
                print(f"    was: {_p(biz)}")
                print(f"    now: {_p(new_biz)}")
        else:
            already_ok += 1

        # Build catalog entry
        cat = catalog[code_val]
        cat['count'] += 1
        cat['sps'].add(sp)
        sem = new_biz if new_biz != biz or not needs_enrich else biz
        if sem and not _GENERIC_RE.match(sem):
            cat['semantics'].add(sem[:120])

    # ── Apply to brain.db ────────────────────────────────────────────────────
    if APPLY and updates:
        print(f"\nApplying {len(updates)} updates to brain.db …")
        for new_biz, rule_id in updates:
            conn.execute(
                'UPDATE rules SET business_name = ? WHERE id = ?',
                (new_biz, rule_id)
            )
        conn.commit()
        print("Done.")
    elif updates:
        print(f"\n[DRY-RUN] Would update {len(updates)} rules. Run with --apply to persist.")

    # ── Catalog JSON ─────────────────────────────────────────────────────────
    catalog_out = []
    for code_val, entry in sorted(catalog.items(), key=lambda x: -x[1]['count']):
        catalog_out.append({
            'code':      code_val,
            'count':     entry['count'],
            'sp_count':  len(entry['sps']),
            'semantics': sorted(entry['semantics']),
            'sps':       sorted(entry['sps'])[:20],   # cap at 20 for JSON size
        })

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / 'return-code-catalog.json'
    out_path.write_text(
        json.dumps({'generated': '2026-08-13', 'codes': catalog_out}, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )
    print(f"\nCatalog saved: {out_path}")

    # ── Summary ──────────────────────────────────────────────────────────────
    print("\n=== RETURN CODE ENRICHMENT SUMMARY ===")
    print(f"Total CODIGO_RETORNO rules : {total:>5}")
    print(f"Already had semantics      : {already_ok:>5}")
    print(f"Needed enrichment          : {total - already_ok:>5}")
    print(f"  from inline comment      : {from_comment:>5}")
    print(f"  from IF condition        : {from_if:>5}")
    print(f"  not found (no IF ctx)   : {not_found:>5}")
    print(f"Net enriched               : {enriched:>5}")
    print(f"Catalog codes written      : {len(catalog_out):>5}")

    conn.close()


if __name__ == '__main__':
    main()

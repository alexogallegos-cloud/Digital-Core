"""
validate-consistency.py — Consistency check: vocabulary + rules vs. source code
Generates portal/data/consistency-report.json

3 checks:
  1. Rule code presence  — each NEGOCIO rule's SPL fragment exists in its source file
  2. business_name quality — detect generic names that weren't meaningfully enriched
  3. Vocabulary gaps     — frequent SP-name tokens not formally defined in terms table
"""

import sqlite3, os, re, json
from pathlib import Path
from collections import defaultdict

BASE    = Path(__file__).resolve().parent.parent
BRAIN   = BASE / 'digital-brain' / 'brain.db'
SRC_DIR = BASE / 'source' / 'informix' / 'informix'
OUT_DIR = BASE / 'portal' / 'data'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_src_cache: dict[str, str | None] = {}

def fix_encoding(s: str) -> str:
    """Repair double-encoded UTF-8 (latin-1 bytes re-encoded as UTF-8)."""
    try:
        return s.encode('latin-1').decode('utf-8')
    except Exception:
        return s


def load_source(db: str, sp_name: str) -> str | None:
    key = f'{db}_{sp_name}'
    if key in _src_cache:
        return _src_cache[key]
    path = SRC_DIR / f'{key}.sql'
    if not path.exists():
        _src_cache[key] = None
        return None
    raw = path.read_bytes()
    content = None
    # Strategy 1: raw bytes → UTF-8 → fix_encoding (handles double-encoded latin-1/UTF-8 files)
    try:
        decoded = raw.decode('utf-8')
        content  = decoded.encode('latin-1').decode('utf-8')
    except (UnicodeDecodeError, UnicodeEncodeError):
        pass
    # Strategy 2: plain UTF-8
    if content is None:
        try:
            content = raw.decode('utf-8')
        except UnicodeDecodeError:
            pass
    # Strategy 3: latin-1 fallback
    if content is None:
        content = raw.decode('latin-1', errors='replace')
    _src_cache[key] = content
    return content


def norm(s: str) -> str:
    """Normalize whitespace for fuzzy matching."""
    return ' '.join(s.split())


def spl_expr(code: str) -> str:
    """Extract SPL expression before any inline comment, stripped."""
    if not code:
        return ''
    # Remove enrichment comments added by pipeline (after --)
    part = code.split('--')[0].strip().rstrip(';').strip()
    return part


def is_generic_name(biz: str) -> bool:
    """True if business_name follows a generic unparsed template."""
    if not biz:
        return True
    # Patterns from enrich pipeline that signal the name wasn't improved
    generic_re = re.compile(
        r'^(umbral|validaci[oó]n|f[oó]rmula|c[aá]lculo|regla|control)\s+(de|del?)\s*:\s*\w',
        re.IGNORECASE,
    )
    return bool(generic_re.match(biz.strip()))


# ---------------------------------------------------------------------------
# Check 1 — Rule code presence in source files
# ---------------------------------------------------------------------------

def check_rule_code(conn: sqlite3.Connection) -> dict:
    cur = conn.cursor()
    cur.execute(
        '''SELECT id, sp, db, line, code, business_name, tipo
           FROM rules WHERE clase = "NEGOCIO" ORDER BY db, sp'''
    )
    rows = cur.fetchall()

    confirmed = 0
    not_found = 0
    no_source = 0
    mismatches: list[dict] = []

    by_tipo: dict[str, dict] = defaultdict(lambda: {'ok': 0, 'miss': 0})

    for rule_id, sp_id, db, line, code, biz, tipo in rows:
        sp_name = sp_id.split(':')[-1] if ':' in sp_id else sp_id
        src = load_source(db, sp_name)
        if src is None:
            no_source += 1
            by_tipo[tipo]['miss'] += 1
            continue

        expr = spl_expr(code or '')
        if not expr:
            # Empty code — count as not found
            not_found += 1
            by_tipo[tipo]['miss'] += 1
            mismatches.append({
                'id': rule_id, 'sp': sp_id, 'line': line,
                'code': '', 'business_name': biz, 'tipo': tipo,
                'reason': 'empty_code',
            })
            continue

        # Level 1: exact match
        if expr and expr in src:
            confirmed += 1
            by_tipo[tipo]['ok'] += 1
            continue
        # Level 2: normalize whitespace (handles tab/space and extra spaces)
        expr_n = norm(expr)
        src_n  = norm(src)
        if expr_n and expr_n in src_n:
            confirmed += 1
            by_tipo[tipo]['ok'] += 1
            continue
        # Level 3: collapse all whitespace + prepend LET (pipeline strips LET on extraction)
        expr_c = expr_n.replace(' ', '')
        src_c  = src_n.replace(' ', '')
        let_expr_c = ('LET' + expr_c)
        if (expr_c and expr_c in src_c) or (let_expr_c and let_expr_c in src_c):
            confirmed += 1
            by_tipo[tipo]['ok'] += 1
            continue
        # Level 4: latin-1 re-read for mixed-encoding files (some bdicnweb/bdicnweb)
        src_lat = _src_cache.get(f'{db}_{sp_name}_latin1')
        if src_lat is None:
            try:
                path = SRC_DIR / f'{db}_{sp_name}.sql'
                src_lat = path.read_bytes().decode('latin-1')
                _src_cache[f'{db}_{sp_name}_latin1'] = src_lat
            except Exception:
                src_lat = ''
        src_lat_n = norm(src_lat).replace(' ', '')
        if expr_c and expr_c in src_lat_n:
            confirmed += 1
            by_tipo[tipo]['ok'] += 1
            continue

        not_found += 1
        by_tipo[tipo]['miss'] += 1
        # Classify artifact type for reporting
        has_nonascii_expr = any(ord(c) > 127 for c in expr)
        reason = 'encoding_artifact' if has_nonascii_expr else 'formatting_artifact'
        mismatches.append({
            'id': rule_id, 'sp': sp_id, 'line': line,
            'code': (code or '')[:120], 'expr_used': expr[:80],
            'business_name': biz, 'tipo': tipo,
            'reason': reason,
        })

    total = len(rows)
    pct   = round(confirmed / total * 100, 2) if total else 0
    return {
        'total':      total,
        'confirmed':  confirmed,
        'not_found':  not_found,
        'no_source':  no_source,
        'pct_confirmed': pct,
        'by_tipo':    {k: v for k, v in sorted(by_tipo.items())},
        'mismatches': mismatches,
    }


# ---------------------------------------------------------------------------
# Check 2 — business_name quality
# ---------------------------------------------------------------------------

def check_biz_name(conn: sqlite3.Connection) -> dict:
    cur = conn.cursor()
    cur.execute('SELECT id, business_name, tipo, sp FROM rules WHERE clase = "NEGOCIO"')
    rows = cur.fetchall()

    total = len(rows)
    generic_list: list[dict] = []
    empty_list: list[dict] = []

    by_tipo_generic: dict[str, int] = defaultdict(int)

    for rule_id, biz, tipo, sp in rows:
        if not biz or biz.strip() == '':
            empty_list.append({'id': rule_id, 'sp': sp, 'tipo': tipo})
        elif is_generic_name(biz):
            generic_list.append({'id': rule_id, 'sp': sp, 'tipo': tipo, 'business_name': biz})
            by_tipo_generic[tipo] += 1

    n_generic = len(generic_list)
    n_empty   = len(empty_list)
    good      = total - n_generic - n_empty

    return {
        'total':       total,
        'good':        good,
        'generic':     n_generic,
        'empty':       n_empty,
        'pct_good':    round(good / total * 100, 2) if total else 0,
        'pct_generic': round(n_generic / total * 100, 2) if total else 0,
        'by_tipo_generic': dict(sorted(by_tipo_generic.items(), key=lambda x: -x[1])),
        'generic_samples': generic_list[:40],
    }


# ---------------------------------------------------------------------------
# Check 3 — Vocabulary gap analysis
# ---------------------------------------------------------------------------

_STOP = {
    'sp', 'bdi', 'aux', 'tmp', 'var', 'val', 'get', 'set', 'new', 'old',
    'num', 'idx', 'cnt', 'row', 'err', 'ret', 'out', 'str', 'the',
}

def check_vocab_gap(conn: sqlite3.Connection) -> dict:
    cur = conn.cursor()

    # All SP names in the brain
    cur.execute('SELECT DISTINCT sp FROM rules')
    sp_ids = [r[0] for r in cur.fetchall()]

    token_freq: dict[str, int] = defaultdict(int)
    token_sps:  dict[str, set] = defaultdict(set)

    for sp_id in sp_ids:
        sp_name = sp_id.split(':')[-1] if ':' in sp_id else sp_id
        name = re.sub(r'^sp_', '', sp_name)
        tokens = [t for t in name.split('_') if len(t) >= 3 and t not in _STOP]
        for t in tokens:
            token_freq[t] += 1
            token_sps[t].add(sp_id)

    # Defined terms
    cur.execute('SELECT term FROM terms')
    defined = {r[0] for r in cur.fetchall()}

    gaps = [
        {
            'token': t,
            'freq':  f,
            'sp_count': len(token_sps[t]),
            'sample_sp': sorted(token_sps[t])[:3],
        }
        for t, f in sorted(token_freq.items(), key=lambda x: -x[1])
        if t not in defined
    ]

    covered = [t for t in token_freq if t in defined]

    return {
        'unique_tokens':  len(token_freq),
        'defined_tokens': len(covered),
        'gap_tokens':     len(gaps),
        'pct_covered':    round(len(covered) / len(token_freq) * 100, 2) if token_freq else 0,
        'top_gaps':       gaps[:60],
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print('BanCoppel Informix — Consistency Check')
    print('=' * 50)

    conn = sqlite3.connect(BRAIN)

    print('\n[1/3] Checking rule code presence in source files...')
    r1 = check_rule_code(conn)
    print(f'      {r1["confirmed"]}/{r1["total"]} confirmed ({r1["pct_confirmed"]}%)')
    print(f'      Mismatches: {r1["not_found"]}  No-source: {r1["no_source"]}')
    if r1['mismatches']:
        print(f'      Top mismatches:')
        for m in r1['mismatches'][:5]:
            print(f'        {m["id"]} {m["sp"]} L{m["line"]} [{m["tipo"]}] — {m["reason"]}')

    print('\n[2/3] Checking business_name quality...')
    r2 = check_biz_name(conn)
    print(f'      Good: {r2["good"]} ({r2["pct_good"]}%)  Generic: {r2["generic"]} ({r2["pct_generic"]}%)')
    print(f'      Empty: {r2["empty"]}')
    if r2['by_tipo_generic']:
        print(f'      Generic by tipo: {dict(list(r2["by_tipo_generic"].items())[:5])}')

    print('\n[3/3] Checking vocabulary gaps...')
    r3 = check_vocab_gap(conn)
    print(f'      Unique tokens: {r3["unique_tokens"]}  Defined: {r3["defined_tokens"]} ({r3["pct_covered"]}%)')
    print(f'      Gap tokens: {r3["gap_tokens"]}')
    if r3['top_gaps']:
        top = [(g['token'], g['freq']) for g in r3['top_gaps'][:10]]
        print(f'      Top undefined: {top}')

    conn.close()

    report = {
        'generated': '2026-08-13',
        'rule_code':  r1,
        'biz_name':   r2,
        'vocab_gap':  r3,
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / 'consistency-report.json'
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f'\nReport saved: {out_path}')


if __name__ == '__main__':
    main()

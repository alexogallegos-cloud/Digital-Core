"""
validate-rules-vs-code.py — Semantic coherence: business_name vs. source code context

For each NEGOCIO rule:
  1. Reads ±8 lines around rule.line in the source .sql file
  2. Extracts identifiers from the SPL code (split camelCase, split by _)
  3. Normalizes both business_name and code tokens (strip accents, lowercase)
  4. Computes overlap score and classifies: HIGH / MEDIUM / LOW / GENERIC

Output: portal/data/rules-coherence.json
"""

import sqlite3, re, json, unicodedata
from pathlib import Path
from collections import defaultdict

BASE    = Path(__file__).resolve().parent.parent
BRAIN   = BASE / 'digital-brain' / 'brain.db'
SRC_DIR = BASE / 'source' / 'informix' / 'informix'
OUT_DIR = BASE / 'portal' / 'data'

CONTEXT_LINES = 8  # lines before and after rule.line

# SPL / SQL keywords to ignore — they're structural, not semantic
_SPL_STOP = {
    'let','if','then','else','end','return','raise','exception','foreach','with',
    'resume','define','call','execute','procedure','select','from','where','and',
    'or','not','in','between','like','null','is','as','into','on','values',
    'insert','update','delete','set','begin','commit','rollback','work','continue',
    'when','for','while','do','case','each','row','of','type','default',
    'integer','decimal','money','varchar','char','date','datetime','interval',
    'smallint','float','real','double','precision','lvarchar','boolean',
    'cast','nvl','round','floor','ceil','abs','mod','current','today',
    'trim','upper','lower','length','substring','extend','to','year','month',
    'day','hour','minute','second','fraction','first','skip',
    'dirty','read','wait','lock','found','notfound','sqlcode','sqlerrmessage',
    'sp','bdi','aux','tmp','var','get','new','old','num','idx','cnt',
    'row','err','ret','out','str','the','val','cod','cod',
}

# Spanish stopwords for business_name
_ES_STOP = {
    'de','del','la','el','los','las','un','una','unos','unas',
    'en','con','por','para','que','se','su','al','le','lo',
    'es','son','fue','han','ha','hay','ser','estar','tener',
    'como','mas','o','y','a','si','no','cuando','donde','cada',
    'entre','hasta','desde','sobre','bajo','sin','tras','ante',
}


def strip_accents(s: str) -> str:
    return ''.join(c for c in unicodedata.normalize('NFD', s)
                   if unicodedata.category(c) != 'Mn')


def split_camel(name: str) -> list[str]:
    """Split camelCase and PascalCase into parts."""
    parts = re.sub(r'([a-z])([A-Z])', r'\1 \2', name).split()
    return parts


def tokenize_code(ctx: str) -> set[str]:
    """Extract meaningful identifier tokens from SPL code context."""
    tokens: set[str] = set()
    # Normalize accents so comment text like "encontró" → "encontro" matches business_name tokens
    ctx_norm = strip_accents(ctx)
    # Find all identifiers (sequences of letters+digits, no leading digit)
    idents = re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', ctx_norm)
    for ident in idents:
        # Split by underscore first
        parts = [p for p in ident.split('_') if len(p) >= 2]
        for part in parts:
            # Then split camelCase
            sub = split_camel(part)
            for s in sub:
                t = s.lower()
                if len(t) >= 3 and t not in _SPL_STOP:
                    tokens.add(t)
        # Also try the whole identifier (lowercase)
        whole = ident.lower()
        if whole not in _SPL_STOP:
            tokens.add(whole)
    # Also extract numeric literals (thresholds)
    nums = re.findall(r'\b\d+(?:\.\d+)?\b', ctx_norm)
    tokens.update(nums)
    return tokens


def tokenize_name(biz: str) -> list[str]:
    """Extract meaningful tokens from a business_name string."""
    if not biz:
        return []
    clean = strip_accents(biz.lower())
    words = re.split(r'[\s\-_:/·,\.]+', clean)
    result = []
    for w in words:
        if w in _ES_STOP or w in _SPL_STOP:
            continue
        # Keep numeric tokens even if short (16 = IVA, 10 = PLD threshold, etc.)
        if re.match(r'^\d+$', w):
            result.append(w)
        elif len(w) >= 3:
            result.append(w)
    return result


def is_generic_name(biz: str) -> bool:
    generic_re = re.compile(
        r'^(umbral|validaci[oó]n|f[oó]rmula|c[aá]lculo|regla|control)\s+(de|del?)\s*:\s*\w',
        re.IGNORECASE,
    )
    return bool(generic_re.match((biz or '').strip()))


# LET <var> = <numeric_or_string_literal>
_CONST_RE = re.compile(
    r'\bLET\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*'
    r"(['\"][\d\.\,]+['\"]|\d+(?:\.\d+)?)",
    re.IGNORECASE,
)

_src_cache:   dict[str, list[str] | None] = {}
_const_cache: dict[str, dict[str, str]]   = {}

def build_const_map(lines: list[str]) -> dict[str, str]:
    """Scan full SP source for LET var = literal — returns {var_lower: value}."""
    const_map: dict[str, str] = {}
    for line in lines:
        m = _CONST_RE.search(line)
        if m:
            var = m.group(1).lower()
            val = m.group(2).strip("'\"")
            const_map[var] = val
    return const_map


def load_lines(db: str, sp_name: str) -> list[str] | None:
    key = f'{db}_{sp_name}'
    if key in _src_cache:
        return _src_cache[key]
    # const_cache is populated lazily inside load_lines so one pass reads both
    path = SRC_DIR / f'{key}.sql'
    if not path.exists():
        _src_cache[key] = None
        return None
    raw = path.read_bytes()
    try:
        text = raw.decode('utf-8')
        try:
            text = text.encode('latin-1').decode('utf-8')
        except Exception:
            pass
    except UnicodeDecodeError:
        text = raw.decode('latin-1', errors='replace')
    lines = text.splitlines()
    _src_cache[key]   = lines
    _const_cache[key] = build_const_map(lines)
    return lines


def get_context(lines: list[str], line_no: int, window: int = CONTEXT_LINES) -> str:
    """Return ±window lines around line_no (1-indexed)."""
    lo = max(0, line_no - 1 - window)
    hi = min(len(lines), line_no + window)
    return '\n'.join(lines[lo:hi])


def tokenize_sp_name(sp_id: str) -> set[str]:
    """Tokens from the SP name itself — always valid context."""
    sp_name = sp_id.split(':')[-1] if ':' in sp_id else sp_id
    name = re.sub(r'^sp_', '', sp_name)
    parts = [p.lower() for p in name.split('_') if len(p) >= 3]
    return set(parts)


def normalize_nums(tokens: set[str]) -> set[str]:
    """Add integer form of decimal tokens (0.16 → '16', 365.25 → '365')."""
    extra = set()
    for t in tokens:
        m = re.match(r'^0?\.?(\d+)', t)
        if m:
            extra.add(m.group(1))
    return tokens | extra


def is_reg_ref(biz: str) -> bool:
    """True if business_name contains external regulatory references."""
    reg_re = re.compile(
        r'\b(cnbv|banxico|condusef|sat|gafi|cecoban|consar|lrsic|suac|reca'
        r'|ltosf|lic\b|lsf|cub\b|art\.\s*\d|cap\.\s*[ivx]|anexo)',
        re.IGNORECASE,
    )
    return bool(reg_re.search(biz or ''))


def score_rule(biz: str, code: str, lines: list[str], line_no: int, sp_id: str = '',
               const_map: dict[str, str] | None = None) -> dict:
    """Compute coherence score between business_name and code context."""
    if is_generic_name(biz):
        return {'score': 0.0, 'level': 'GENERIC', 'reg_ref': False,
                'name_tokens': tokenize_name(biz), 'matched': [], 'code_tokens_sample': []}

    reg = is_reg_ref(biz)

    ctx = get_context(lines, line_no)
    # Augment code tokens with SP name tokens (always valid context)
    sp_tokens   = tokenize_sp_name(sp_id)
    code_tokens = normalize_nums(tokenize_code(ctx) | sp_tokens)

    # Constant propagation: expand tokens for variables that are assigned
    # a numeric/string literal anywhere in the SP  (e.g. vValIva = 0.16 → adds '16', 'iva')
    if const_map:
        ctx_idents = {i.lower() for i in re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b', ctx)}
        for ident in ctx_idents:
            if ident in const_map:
                val = const_map[ident]
                code_tokens.add(val)
                # also add integer form (0.16 → 16)
                m = re.match(r'^0?\.?(\d+)', val)
                if m:
                    code_tokens.add(m.group(1))
                # also tokenize variable name itself for semantic meaning
                # (vValIva → 'val', 'iva' already handled by tokenize_code above)
    name_tokens = tokenize_name(biz)

    if not name_tokens:
        return {'score': 0.0, 'level': 'LOW', 'reg_ref': reg,
                'name_tokens': [], 'matched': [], 'code_tokens_sample': []}

    matched = []
    for nt in name_tokens:
        nt_norm = strip_accents(nt.lower())
        # Exact match
        if nt_norm in code_tokens:
            matched.append(nt)
            continue
        # Substring match: nt appears in any code token or vice versa
        if any(nt_norm in ct or ct in nt_norm for ct in code_tokens if len(ct) >= 3):
            matched.append(nt)

    overlap = len(matched) / len(name_tokens)
    if overlap >= 0.35:
        level = 'HIGH'
    elif overlap >= 0.12:
        level = 'MEDIUM'
    else:
        level = 'LOW'

    sample_code = sorted(code_tokens - sp_tokens)[:10]
    return {
        'score': round(overlap, 3),
        'level': level,
        'reg_ref': reg,
        'name_tokens': name_tokens,
        'matched': matched,
        'code_tokens_sample': sample_code,
    }


def load_compound_groups(conn) -> dict[str, list[tuple]]:
    """Returns {compound_group_id: [(rule_id, sp, db, line, code), ...]}"""
    cur = conn.cursor()
    cur.execute("""
        SELECT compound_group_id, id, sp, db, line, code
        FROM rules
        WHERE clase = 'NEGOCIO' AND compound_group_id IS NOT NULL
        ORDER BY compound_group_id, CAST(line AS INTEGER)
    """)
    groups: dict[str, list] = defaultdict(list)
    for gid, rid, sp, db, line, code in cur.fetchall():
        groups[gid].append((rid, sp, db, line, code))
    return dict(groups)


def main():
    print('BanCoppel Informix — Rules vs. Code Semantic Coherence Check')
    print('=' * 60)

    conn = sqlite3.connect(BRAIN)
    cur  = conn.cursor()
    cur.execute(
        '''SELECT id, sp, db, line, code, business_name, tipo,
                  COALESCE(sub_tipo, tipo), COALESCE(compound_group_id, '')
           FROM rules WHERE clase = "NEGOCIO" ORDER BY db, sp'''
    )
    rows = cur.fetchall()

    # Pre-load compound groups for merged-context scoring
    compound_groups = load_compound_groups(conn)
    # Map rule_id → group_id
    rule_to_group: dict[str, str] = {}
    for gid, members in compound_groups.items():
        for (rid, *_) in members:
            rule_to_group[rid] = gid

    conn.close()

    total = len(rows)
    print(f'Rules to check: {total}  '
          f'(compound rules: {len(rule_to_group)}, groups: {len(compound_groups)})')

    by_level  = defaultdict(int)
    by_tipo   = defaultdict(lambda: defaultdict(int))
    low_rules = []
    all_scores = []

    for i, (rule_id, sp_id, db, line, code, biz, tipo, sub_tipo, cg_id) in enumerate(rows):
        if i % 1000 == 0:
            print(f'  {i}/{total}…', flush=True)

        sp_name   = sp_id.split(':')[-1] if ':' in sp_id else sp_id
        lines     = load_lines(db, sp_name)
        cache_key = f'{db}_{sp_name}'
        cmap      = _const_cache.get(cache_key, {})

        if lines is None:
            result = {'score': 0.0, 'level': 'NO_SOURCE', 'reg_ref': False,
                      'name_tokens': [], 'matched': [], 'code_tokens_sample': []}
        else:
            line_no = int(line) if line and str(line).isdigit() else 0

            # For compound rules: augment context with all sibling fragments
            if rule_id in rule_to_group:
                gid     = rule_to_group[rule_id]
                members = compound_groups[gid]
                # Merge all code fragments (ordered by line)
                extra_code = ' '.join(
                    c for (rid, sp, db2, ln, c) in members
                    if c and rid != rule_id
                )
                # Merge contexts from all sibling lines
                sibling_ctx = '\n'.join(
                    get_context(
                        load_lines(db2, (sp.split(':')[-1] if ':' in sp else sp)) or [],
                        int(ln) if ln and str(ln).isdigit() else 0
                    )
                    for (rid, sp, db2, ln, c) in members
                    if rid != rule_id and load_lines(db2, (sp.split(':')[-1] if ':' in sp else sp))
                )
                # Score using main context + sibling context appended
                aug_lines = lines + (sibling_ctx + '\n' + extra_code).splitlines()
                result = score_rule(biz or '', code or '', aug_lines, line_no, sp_id,
                                    const_map=cmap)
            else:
                result = score_rule(biz or '', code or '', lines, line_no, sp_id,
                                    const_map=cmap)

        level = result['level']
        by_level[level] += 1
        by_tipo[sub_tipo][level] += 1
        all_scores.append(result['score'])

        entry = {
            'id': rule_id, 'sp': sp_id, 'db': db, 'line': line,
            'tipo': tipo, 'sub_tipo': sub_tipo,
            'compound_group': cg_id or None,
            'business_name': biz or '',
            'code_fragment': (code or '')[:100],
            'reg_ref': result.get('reg_ref', False),
            **{k: v for k, v in result.items() if k != 'reg_ref'},
        }
        if level == 'LOW':
            low_rules.append(entry)

    # Summary
    avg_score = sum(all_scores) / len(all_scores) if all_scores else 0
    print(f'\nResults:')
    print(f'  HIGH   : {by_level["HIGH"]:5d}  ({by_level["HIGH"]/total*100:.1f}%)')
    print(f'  MEDIUM : {by_level["MEDIUM"]:5d}  ({by_level["MEDIUM"]/total*100:.1f}%)')
    print(f'  LOW    : {by_level["LOW"]:5d}  ({by_level["LOW"]/total*100:.1f}%)')
    print(f'  GENERIC: {by_level["GENERIC"]:5d}  ({by_level["GENERIC"]/total*100:.1f}%)')
    print(f'  Avg score: {avg_score:.3f}')
    print(f'\n  Low-coherence rules: {len(low_rules)} (candidates for review)')
    print(f'  Top 5 low-coherence:')
    low_rules_sorted = sorted(low_rules, key=lambda r: r['score'])
    for r in low_rules_sorted[:5]:
        print(f'    {r["id"]} {r["sp"]} [{r["tipo"]}] score={r["score"]} biz="{r["business_name"][:50]}"')
        print(f'      name_tokens={r["name_tokens"]} matched={r["matched"]}')

    report = {
        'generated': '2026-08-13',
        'total': total,
        'avg_score': round(avg_score, 3),
        'by_level': dict(by_level),
        'by_tipo':  {t: dict(v) for t, v in by_tipo.items()},
        'low_rules': low_rules_sorted[:200],
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / 'rules-coherence.json'
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f'\nReport saved: {out_path}')


if __name__ == '__main__':
    main()

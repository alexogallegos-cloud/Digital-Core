"""
group-compound-rules.py — Detección de reglas de negocio compuestas (multi-fragmento)

Una regla de negocio SPL puede expresarse en N sentencias LET consecutivas que comparten
variables. Cada sentencia es capturada por brain-builder como una regla independiente, pero
semánticamente forman UNA sola regla con sub-pasos ordenados.

Criterios de agrupamiento:
  1. Mismo SP y mismo business_name (condición necesaria)
  2. Dispersión de líneas <= LINE_SPREAD_MAX (los pasos están cerca en el código)
  3. Comparten al menos 1 variable no-trivial entre fragmentos (dependencia de datos)

Salida:
  - Columna compound_group_id en tabla rules (e.g. CG-bdicheq-ajusteprovision-001)
  - portal/data/compound-groups.json — resumen para el portal

Run: python generators/group-compound-rules.py
"""

import sqlite3, re, json
from pathlib import Path
from collections import defaultdict

BASE  = Path(__file__).resolve().parent.parent
BRAIN = BASE / 'digital-brain' / 'brain.db'
OUT   = BASE / 'portal' / 'data' / 'compound-groups.json'

LINE_SPREAD_MAX = 80   # líneas máx entre el primer y último fragmento del grupo
MIN_SHARED_VARS = 1    # variables compartidas mínimas entre ≥2 fragmentos

# SPL / SQL keywords and trivial vars that do NOT confirm shared business dependency
_TRIVIAL_VARS = {
    # SPL keywords that look like identifiers
    'then', 'else', 'when', 'case', 'each', 'found', 'work',
    'smallint', 'integer', 'decimal', 'varchar', 'datetime',
    'money', 'boolean', 'interval', 'lvarchar', 'char',
    # Very common control vars
    'vcod', 'vcodret', 'vcret', 'vret', 'vsql', 'vsqlcode', 'verr',
    'vres', 'vresult', 'vresultado', 'vstatus', 'vok', 'vflag',
    'vcont', 'vcount', 'vidx', 'vnum', 'vi', 'vj', 'vk',
    'sqlcode', 'sqlerr', 'found', 'notfound',
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def extract_lhs_vars(code: str) -> set[str]:
    """Variables asignadas en LHS: LET var = ..."""
    return {m.lower() for m in re.findall(r'\bLET\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=', code, re.I)}


def extract_all_vars(code: str) -> set[str]:
    """Todos los identificadores ≥4 chars (LHS + RHS)."""
    return {t.lower() for t in re.findall(r'\b[a-zA-Z_][a-zA-Z0-9_]{3,}\b', code)
            if t.lower() not in _TRIVIAL_VARS}


def shared_vars(fragments: list[str]) -> set[str]:
    """Variables que aparecen en ≥2 fragmentos."""
    if len(fragments) < 2:
        return set()
    var_sets = [extract_all_vars(f) for f in fragments]
    all_vars  = set().union(*var_sets)
    return {v for v in all_vars
            if sum(1 for s in var_sets if v in s) >= 2
            and v not in _TRIVIAL_VARS}


def is_compound(fragments: list[str], lines: list[int]) -> tuple[bool, set[str]]:
    """True si el grupo cumple criterios de regla compuesta."""
    spread = max(lines) - min(lines) if lines else 0
    if spread > LINE_SPREAD_MAX:
        return False, set()
    sv = shared_vars(fragments)
    if len(sv) < MIN_SHARED_VARS:
        return False, set()
    return True, sv


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    conn = sqlite3.connect(BRAIN)
    cur  = conn.cursor()

    # Add column if absent
    try:
        cur.execute('ALTER TABLE rules ADD COLUMN compound_group_id TEXT')
        conn.commit()
    except sqlite3.OperationalError:
        pass  # already exists

    # Reset all compound_group_id
    cur.execute('UPDATE rules SET compound_group_id = NULL')

    # Candidates: same (sp, db, business_name) with >1 NEGOCIO rule
    cur.execute("""
        SELECT sp, db, business_name,
               COUNT(*)                                    AS cnt,
               GROUP_CONCAT(id,         '|')               AS ids,
               GROUP_CONCAT(COALESCE(code,''), '|||')       AS codes,
               GROUP_CONCAT(COALESCE(line,'0'), '|')        AS lines
        FROM rules
        WHERE clase = 'NEGOCIO'
          AND business_name IS NOT NULL AND business_name != ''
        GROUP BY sp, db, business_name
        HAVING cnt > 1
        ORDER BY db, sp, business_name
    """)
    candidates = cur.fetchall()

    groups   = []
    gid_ctr  = defaultdict(int)
    confirmed = 0
    dismissed = 0

    for sp, db, biz, cnt, ids_str, codes_str, lines_str in candidates:
        ids      = ids_str.split('|')
        fragments = codes_str.split('|||')
        try:
            line_nos = [int(x) for x in lines_str.split('|')]
        except ValueError:
            line_nos = [0] * len(ids)

        ok, sv = is_compound(fragments, line_nos)
        if not ok:
            dismissed += 1
            continue

        # Build group ID
        sp_slug = sp.split(':')[-1] if ':' in sp else sp
        gid_ctr[(db, sp_slug)] += 1
        gid = f'CG-{db}-{sp_slug}-{gid_ctr[(db,sp_slug)]:03d}'

        # Tag all rules in this group
        for rule_id in ids:
            cur.execute('UPDATE rules SET compound_group_id = ? WHERE id = ?', (gid, rule_id))

        groups.append({
            'id':           gid,
            'sp':           sp,
            'db':           db,
            'business_name': biz,
            'fragment_count': cnt,
            'line_spread':  max(line_nos) - min(line_nos) if line_nos else 0,
            'shared_vars':  sorted(sv),
            'rule_ids':     ids,
            'fragments':    [f[:120] for f in fragments],
        })
        confirmed += 1

    conn.commit()
    conn.close()

    # Summary stats
    total_tagged = sum(g['fragment_count'] for g in groups)
    print(f'Candidates evaluated : {confirmed + dismissed}')
    print(f'Compound groups found: {confirmed}')
    print(f'  (dismissed — spread too wide or no shared vars: {dismissed})')
    print(f'Total rules tagged   : {total_tagged}')
    print()
    print('Top 10 groups by fragment count:')
    for g in sorted(groups, key=lambda x: -x['fragment_count'])[:10]:
        print(f'  {g["id"]:40s}  {g["fragment_count"]} frags  '
              f'spread={g["line_spread"]}  shared={g["shared_vars"][:3]}')

    OUT.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump({
            'generated':      '2026-08-13',
            'total_groups':   confirmed,
            'total_dismissed': dismissed,
            'total_rules_tagged': total_tagged,
            'groups': sorted(groups, key=lambda x: -x['fragment_count']),
        }, f, ensure_ascii=False, indent=2)
    print(f'\nSaved: {OUT}')


if __name__ == '__main__':
    main()

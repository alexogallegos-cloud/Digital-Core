"""
build-rules-coherence.py — Genera portal/data/rules-coherence.json con métricas de calidad
de business names en el catálogo de reglas de BanCoppel.

Scoring por regla:
  name_tokens = palabras del business_name (sin stopwords)
  code_tokens = palabras del código fuente
  matched     = tokens del nombre que aparecen en el código (síntoma de copy-paste)
  score       = 1 - len(matched) / len(name_tokens)  [0.0 = todo es código, 1.0 = todo es negocio]

Niveles:
  HIGH    score >= 0.75 (nombre es mayormente terminología de negocio)
  MEDIUM  0.4 <= score < 0.75
  GENERIC nombre demasiado corto (<3 tokens no-triviales) o genérico
  LOW     score < 0.4 (nombre repite el código)

Cross-SP deduplication:
  Grupos de reglas con mismo (business_name, code) en múltiples SPs — copy-paste de capacidad.
  Reglas únicas reales = total - duplicados (N-1 por grupo).
"""

import sqlite3, json, re, sys
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
from pathlib import Path
from datetime import date
from collections import defaultdict, Counter

BASE  = Path(__file__).resolve().parent.parent
BRAIN = BASE / 'digital-brain' / 'brain.db'
OUT   = BASE / 'portal' / 'data' / 'rules-coherence.json'

# ---------------------------------------------------------------------------
# Stop words
# ---------------------------------------------------------------------------
STOP = {
    'de', 'la', 'el', 'en', 'y', 'a', 'por', 'que', 'con', 'del',
    'los', 'las', 'un', 'una', 'es', 'se', 'no', 'si', 'para',
    'al', 'lo', 'su', 'o', 'como', 'más', 'pero', 'this', 'the',
    'and', 'or', 'not', 'of', 'in', 'to', 'is', 'it',
    # Technical generic tokens
    'id', 'cod', 'num', 'val', 'var', 'ret', 'err', 'ok',
    'tipo', 'status', 'code', 'dato', 'result',
}

GENERIC_NAMES = re.compile(
    r'^(error|manejo de excepcion|excepcion|control de flujo|'
    r'bifurcacion|asignacion|declaracion|inicializacion|'
    r'codret|codigo retorno|codigo de retorno)$',
    re.I)


def tokenize_name(text):
    if not text:
        return []
    # Remove everything in parentheses (vocabulary definitions, not core tokens)
    t = re.sub(r'\([^)]*\)', '', text)
    t = re.sub(r'[^a-záéíóúüñA-ZÁÉÍÓÚÜÑ0-9\s]', ' ', t)
    return [w.lower() for w in t.split() if len(w) >= 3 and w.lower() not in STOP]


def tokenize_code(code):
    if not code:
        return []
    tokens = re.findall(r'\b[a-záéíóúüñA-ZÁÉÍÓÚÜÑ][a-záéíóúüñA-ZÁÉÍÓÚÜÑ0-9_]{2,}\b', code)
    return list({t.lower() for t in tokens if t.lower() not in STOP})[:20]


def score_rule(name_tokens, code_tokens):
    if not name_tokens:
        return 0.0, []
    code_set = set(code_tokens)
    matched = [t for t in name_tokens if t in code_set]
    score = 1.0 - len(matched) / len(name_tokens)
    return round(score, 3), matched


def classify(name_tokens, score, business_name):
    if not name_tokens or len(name_tokens) < 3:
        return 'GENERIC'
    if GENERIC_NAMES.match((business_name or '').strip()):
        return 'GENERIC'
    if score >= 0.75:
        return 'HIGH'
    if score >= 0.40:
        return 'MEDIUM'
    return 'LOW'


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    conn = sqlite3.connect(BRAIN)
    cur  = conn.cursor()

    cur.execute("""
        SELECT id, sp, db, line, tipo, sub_tipo, business_name, code, reg
        FROM rules
        WHERE clase = 'NEGOCIO'
          AND business_name IS NOT NULL AND business_name != ''
        ORDER BY id
    """)
    rows = cur.fetchall()
    print(f"Reglas NEGOCIO con business_name: {len(rows)}")

    results = []
    by_level = Counter()
    by_tipo  = defaultdict(Counter)
    low_rules    = []
    medium_rules = []
    scores = []

    for id, sp, db, line, tipo, sub_tipo, bn, code, reg in rows:
        name_tokens = tokenize_name(bn)
        code_tokens = tokenize_code(code)
        score, matched = score_rule(name_tokens, code_tokens)
        level = classify(name_tokens, score, bn)

        has_reg = bool(reg and reg.strip() and reg != '[]')

        record = {
            'id': id, 'sp': f"{db}:{sp}", 'db': db, 'line': line,
            'tipo': tipo, 'sub_tipo': sub_tipo,
            'compound_group': None,
            'business_name': bn,
            'code_fragment': (code or '')[:100],
            'reg_ref': has_reg,
            'score': score, 'level': level,
            'name_tokens': name_tokens[:10],
            'matched': matched[:10],
            'code_tokens_sample': code_tokens[:10],
        }
        results.append(record)
        by_level[level] += 1
        by_tipo[sub_tipo or tipo][level] += 1
        scores.append(score)

        if level == 'LOW':
            low_rules.append(record)
        elif level == 'MEDIUM':
            medium_rules.append(record)

    # Cross-SP deduplication
    dup_groups = defaultdict(list)
    for r in results:
        key = (r['business_name'].lower().strip(), (r['code_fragment'] or '').lower().strip())
        dup_groups[key].append(r['id'])

    n_dup_groups = sum(1 for ids in dup_groups.values() if len(ids) > 1)
    n_redundant  = sum(len(ids)-1 for ids in dup_groups.values() if len(ids) > 1)
    unique_real  = len(results) - n_redundant
    dup_index    = round(len(results) / unique_real, 2) if unique_real > 0 else 1.0

    avg_score = round(sum(scores) / len(scores), 3) if scores else 0

    out = {
        'generated': str(date.today()),
        'total': len(results),
        'unique_real': unique_real,
        'n_dup_groups': n_dup_groups,
        'dup_index': dup_index,
        'avg_score': avg_score,
        'by_level': dict(by_level),
        'by_tipo': {k: dict(v) for k, v in by_tipo.items()},
        'low_rules': low_rules,
        'medium_rules': medium_rules[:500],  # cap para no inflar el JSON
    }

    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f"\n✓ rules-coherence.json generado")
    print(f"  Total NEGOCIO:    {len(results)}")
    print(f"  Únicas reales:    {unique_real}  (factor {dup_index}×)")
    print(f"  Grupos cross-SP:  {n_dup_groups}")
    print(f"  avg_score:        {avg_score}")
    print(f"  by_level:         {dict(by_level)}")
    print(f"  LOW rules:        {len(low_rules)}")
    print(f"  MEDIUM rules:     {len(medium_rules)}")


if __name__ == '__main__':
    main()

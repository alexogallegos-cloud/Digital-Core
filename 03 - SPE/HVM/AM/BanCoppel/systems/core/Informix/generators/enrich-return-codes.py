"""
enrich-return-codes.py — Catálogo de códigos de retorno (CÓDIGO_RETORNO)

Genera portal/data/return-code-catalog.json con:
  code      — valor del código de retorno (string)
  count     — número de reglas que lo emiten
  sp_count  — número de SPs distintos
  semantics — nombres descriptivos asociados (vacío hasta que la síntesis LLM los genere)
  sps       — lista de SPs representativos (máx 20)

ADR-SPE-AM-010: el enriquecimiento heurístico de business_name fue eliminado.
Las funciones de extracción de condición IF (find_trigger_condition, enrich_exceptions)
y el bloque --apply se eliminaron porque violaban el principio fundamental:
  el extractor NUNCA genera business_name; la síntesis LLM es la única fuente.

Ver: AM/adr/ADR-SPE-AM-010-llm-synthesis-as-generation.md
"""
import sqlite3, re, json, sys
from pathlib import Path
from collections import defaultdict

BASE    = Path(__file__).resolve().parent.parent
BRAIN   = BASE / 'digital-brain' / 'brain.db'
OUT_DIR = BASE / 'portal' / 'data'

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# Patrón para detectar nombres aún genéricos (no incluir en semantics)
_GENERIC_RE = re.compile(
    r'^(retorna c[oó]digo de error|calcular c[oó]digo|retorna c[oó]digo|lanzar error|raise exception)',
    re.I
)


def main():
    conn = sqlite3.connect(BRAIN)
    conn.row_factory = sqlite3.Row

    rows = conn.execute('''
        SELECT id, sp, db, line, code, business_name
        FROM rules
        WHERE sub_tipo IN ("CÓDIGO_RETORNO", "EXCEPCIÓN")
        ORDER BY db, sp, line
    ''').fetchall()

    print(f"Reglas CÓDIGO_RETORNO + EXCEPCIÓN: {len(rows)}")

    catalog: dict[str, dict] = defaultdict(lambda: {
        'semantics': set(), 'sps': set(), 'count': 0
    })

    for row in rows:
        sp   = row['sp']
        code = row['code'] or ''
        biz  = row['business_name'] or ''

        m = re.search(r"['\"]([^'\"]+)['\"]", code)
        code_val = m.group(1) if m else '?'

        cat = catalog[code_val]
        cat['count'] += 1
        cat['sps'].add(sp)
        if biz and not _GENERIC_RE.match(biz.strip()):
            cat['semantics'].add(biz[:120])

    catalog_out = []
    for code_val, entry in sorted(catalog.items(), key=lambda x: -x[1]['count']):
        catalog_out.append({
            'code':      code_val,
            'count':     entry['count'],
            'sp_count':  len(entry['sps']),
            'semantics': sorted(entry['semantics']),
            'sps':       sorted(entry['sps'])[:20],
        })

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / 'return-code-catalog.json'
    out_path.write_text(
        json.dumps({'generated': '2026-08-14', 'codes': catalog_out}, ensure_ascii=False, indent=2),
        encoding='utf-8'
    )
    print(f"Catalog: {out_path} — {len(catalog_out)} códigos, {len(rows)} reglas")
    conn.close()


if __name__ == '__main__':
    main()

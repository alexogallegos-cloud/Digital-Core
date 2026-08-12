#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-rule-terms.py — Tabla rule_terms: trazabilidad regla ↔ vocabulario

Crea la tabla rule_terms en brain.db con dos fuentes:
  vocab_ref — términos extraídos por infer-rule-names.py (LHS/RHS match)
  name      — términos encontrados en el business_name de la regla

SPE-AM-001 · DT-Reglas · Trazabilidad v1.0 · 2026-08-07
"""
import json, re, sqlite3, sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE     = Path(__file__).resolve().parent.parent
BRAIN_DB = BASE / "digital-brain" / "brain.db"
V3_JSON  = BASE / "portal" / "data" / "business-rules-v3.json"

# ── 1. Conectar (escritura) ────────────────────────────────────────────────────
conn = sqlite3.connect(BRAIN_DB)
cur  = conn.cursor()

# ── 2. Crear tabla rule_terms ──────────────────────────────────────────────────
cur.execute('''
    CREATE TABLE IF NOT EXISTS rule_terms (
        rule_id  TEXT NOT NULL,
        term     TEXT NOT NULL,
        source   TEXT NOT NULL,
        PRIMARY KEY (rule_id, term)
    )
''')
conn.commit()
print("── Tabla rule_terms lista ────────────────────────────────────────────────")

# ── 3. Limpiar tabla para re-ejecución idempotente ────────────────────────────
cur.execute('DELETE FROM rule_terms')
conn.commit()
print("   Tabla limpiada — listo para poblar")

# ── 4. Cargar conjunto de términos válidos ─────────────────────────────────────
terms_set = {row[0] for row in cur.execute('SELECT term FROM terms').fetchall()}
print(f"\n── Términos en vocabulario: {len(terms_set):,}")

# ── 5. Construir índice v3: {(sp_canonical, line): vocab_refs_list} ─────────────
print("\n── Cargando business-rules-v3.json …")
_v3_raw  = json.load(open(V3_JSON, encoding='utf-8'))
# El JSON puede ser un dict con clave 'rules' o directamente una lista
v3_rules = _v3_raw['rules'] if isinstance(_v3_raw, dict) else _v3_raw
print(f"   {len(v3_rules):,} reglas en v3.json")

v3_idx: dict[tuple, list[str]] = {}
for rule in v3_rules:
    db_val = rule.get('db', '')
    sp_val = rule.get('sp', '')
    if not db_val or not sp_val:
        continue
    canonical = f"{db_val}:{sp_val}"
    line      = rule.get('line')
    vrefs     = rule.get('vocab_refs')
    if vrefs:
        v3_idx[(canonical, line)] = vrefs

print(f"   {len(v3_idx):,} entradas con vocab_refs en el índice")

# ── 6. Cargar reglas de brain.db ───────────────────────────────────────────────
brain_rules = cur.execute(
    'SELECT id, sp, line, business_name FROM rules'
).fetchall()
print(f"\n── Reglas en brain.db: {len(brain_rules):,}")

# ── 7. Poblar rule_terms ───────────────────────────────────────────────────────
_TOKEN_RE = re.compile(r'\b[a-záéíóúüñ]{3,}\b', re.IGNORECASE)

inserts       = 0
rules_covered = set()
per_rule_terms: dict[str, set] = {}  # rule_id → set(term)

batch: list[tuple[str, str, str]] = []

for rule_id, sp, line, business_name in brain_rules:
    linked: set[str] = set()

    # 7a. Source 'vocab_ref': buscar en v3_idx
    key = (sp, line)
    vrefs = v3_idx.get(key, [])
    for term in vrefs:
        if term in terms_set:
            linked.add(term)
            batch.append((rule_id, term, 'vocab_ref'))

    # 7b. Source 'name': tokenizar business_name
    if business_name:
        tokens = _TOKEN_RE.findall(business_name.lower())
        for token in tokens:
            if token in terms_set and token not in linked:
                linked.add(token)
                batch.append((rule_id, token, 'name'))

    if linked:
        rules_covered.add(rule_id)

    per_rule_terms[rule_id] = linked

# Insertar en lotes
cur.executemany(
    'INSERT OR IGNORE INTO rule_terms (rule_id, term, source) VALUES (?, ?, ?)',
    batch
)
conn.commit()
inserts = len(batch)

# ── 8. Stats ───────────────────────────────────────────────────────────────────
total_rules  = len(brain_rules)
covered      = len(rules_covered)
pct_covered  = 100 * covered / total_rules if total_rules else 0

# Top 10 términos más referenciados
term_count: dict[str, int] = {}
for _, term, _ in batch:
    term_count[term] = term_count.get(term, 0) + 1

top10 = sorted(term_count.items(), key=lambda x: -x[1])[:10]

print("\n" + "=" * 60)
print("  STATS — rule_terms")
print("=" * 60)
print(f"  Total links insertados  : {inserts:,}")
print(f"  Reglas con ≥1 link      : {covered:,} / {total_rules:,}  ({pct_covered:.1f}%)")
print(f"  Reglas sin cobertura    : {total_rules - covered:,}")
print()
print("  Top 10 términos más referenciados:")
for i, (term, cnt) in enumerate(top10, 1):
    print(f"    {i:2}. {term:<30} {cnt:>5} reglas")

# Desglose por source
src_vref = sum(1 for _, _, s in batch if s == 'vocab_ref')
src_name = sum(1 for _, _, s in batch if s == 'name')
print()
print(f"  Por fuente:")
print(f"    vocab_ref  : {src_vref:,}")
print(f"    name       : {src_name:,}")
print("=" * 60)

conn.close()
print("\nDone — brain.db actualizado con tabla rule_terms.")

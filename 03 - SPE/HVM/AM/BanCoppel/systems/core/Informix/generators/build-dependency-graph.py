"""
build-dependency-graph.py — genera portal/data/dependency-graph.json
Lee brain.db + decoupling-cost.json y emite el grafo de dependencias entre dominios.

Uso: python generators/build-dependency-graph.py  (desde Informix/)
"""
import sqlite3, json, sys
from pathlib import Path
from datetime import date

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

SCRIPT_DIR = Path(__file__).resolve().parent
BASE = SCRIPT_DIR.parent
DB_PATH = BASE / 'digital-brain' / 'brain.db'
DECOUPLING_PATH = BASE / 'portal' / 'data' / 'decoupling-cost.json'
OUT_PATH = BASE / 'portal' / 'data' / 'dependency-graph.json'


def fix_enc(s):
    if not isinstance(s, str):
        return s
    try:
        return s.encode('latin-1').decode('utf-8')
    except Exception:
        return s


conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()

# ── Cargar scores de decoupling por dominio ──────────────────────────────────
decouple = {}
if DECOUPLING_PATH.exists():
    with open(DECOUPLING_PATH, encoding='utf-8') as f:
        dc_data = json.load(f)
    for d in dc_data.get('domains', []):
        decouple[d['id']] = d

# ── Nodos: dominios canónicos de brain.db ────────────────────────────────────
cur.execute('''
    SELECT d.id, d.name, d.color,
           COUNT(s.id) as sp_count
    FROM domains d
    LEFT JOIN sps s ON s.domain = d.id
    GROUP BY d.id
    ORDER BY d.id
''')
nodes = []
for row in cur.fetchall():
    did = row['id']
    dc = decouple.get(did, {})
    nodes.append({
        'id': did,
        'name': fix_enc(row['name']),
        'sp_count': row['sp_count'] or 0,
        'avg_cost': dc.get('avg_cost', 0),
        'cost_level': dc.get('cost_level', 'low'),
        'hard_blocks': dc.get('hard_blocks', 0),
        'api_candidates': dc.get('api_candidates', 0),
        'dominant_signal': dc.get('dominant_signal', ''),
        'dist': dc.get('dist', {}),
        'signals': dc.get('signals', {}),
        'color_base': row['color'] or '#3D5FCD',
    })

# ── Edges: llamadas cross-dominio ────────────────────────────────────────────
cur.execute('''
    SELECT s1.domain AS src, s2.domain AS tgt,
           COUNT(*) AS weight,
           SUM(sc.cross_db) AS cross_db_count
    FROM sp_calls sc
    JOIN sps s1 ON sc.from_sp = s1.id
    JOIN sps s2 ON sc.to_sp   = s2.id
    WHERE s1.domain != s2.domain
      AND s1.domain IS NOT NULL AND s1.domain != ''
      AND s2.domain IS NOT NULL AND s2.domain != ''
    GROUP BY src, tgt
''')

domain_ids = {n['id'] for n in nodes}
links = []
for row in cur.fetchall():
    src, tgt = row['src'], row['tgt']
    if src in domain_ids and tgt in domain_ids:
        links.append({
            'source': src,
            'target': tgt,
            'weight': row['weight'],
            'cross_db': row['cross_db_count'] or 0,
        })

conn.close()

# ── Metadatos de resumen ─────────────────────────────────────────────────────
max_weight = max((l['weight'] for l in links), default=1)
total_sp = sum(n['sp_count'] for n in nodes)

# Dominio hub = mayor suma de pesos salientes + entrantes
from collections import defaultdict
degree = defaultdict(int)
for l in links:
    degree[l['source']] += l['weight']
    degree[l['target']] += l['weight']
hub = max(degree, key=degree.get) if degree else ''

out = {
    'nodes': nodes,
    'links': links,
    'meta': {
        'total_domains': len(nodes),
        'total_links': len(links),
        'total_sp': total_sp,
        'max_weight': max_weight,
        'hub_domain': hub,
        'generated_at': date.today().isoformat(),
    }
}

with open(OUT_PATH, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

print(f'dependency-graph.json generado:')
print(f'  {len(nodes)} nodos · {len(links)} edges · max_weight={max_weight:,}')
print(f'  Hub: {hub} ({degree.get(hub, 0):,} peso acumulado)')
print(f'  Output: {OUT_PATH}')
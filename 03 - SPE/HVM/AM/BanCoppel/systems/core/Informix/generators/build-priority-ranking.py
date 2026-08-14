"""
build-priority-ranking.py — genera portal/data/priority-ranking.json
Cruza decoupling-cost + migration-complexity + cobertura regulatoria para rankear
dominios por prioridad de migración: valor alto + esfuerzo bajo = migrar primero.

Uso: python generators/build-priority-ranking.py  (desde BCOPCore/Informix/)
"""
import sqlite3, json, sys
from pathlib import Path
from datetime import date
from collections import defaultdict

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

SCRIPT_DIR = Path(__file__).resolve().parent
BASE = SCRIPT_DIR.parent
DB_PATH = BASE / 'digital-brain' / 'brain.db'
DECOUPLING_PATH = BASE / 'portal' / 'data' / 'decoupling-cost.json'
MC_PATH = BASE / 'portal' / 'data' / 'migration-complexity.json'
OUT_PATH = BASE / 'portal' / 'data' / 'priority-ranking.json'


def fix_enc(s):
    if not isinstance(s, str):
        return s
    try:
        return s.encode('latin-1').decode('utf-8')
    except Exception:
        return s


# ── Cargar fuentes ────────────────────────────────────────────────────────────

with open(DECOUPLING_PATH, encoding='utf-8') as f:
    dc_raw = json.load(f)
decouple = {d['id']: d for d in dc_raw.get('domains', [])}

with open(MC_PATH, encoding='utf-8') as f:
    mc_raw = json.load(f)

# Construir mapa: domain_id → target system + sp_count_in_target
domain_target = {}  # id → target label
domain_sp_replicate = defaultdict(int)  # id → SPs que necesitan replicarse
TARGET_COLORS = {
    'apolo': '#4fde8a',
    'transact': '#5fc5f5',
    'smartvista': '#f5c842',
    'cross': '#c084fc',
    'multi': '#f57f42',
}
for target, items in mc_raw.get('domain_summary', {}).items():
    for item in items:
        did = item['id']
        domain_target[did] = target
        # SPs que van a este target = replicar para los targets no-multi
        domain_sp_replicate[did] = item['n']

# ── Consultar brain.db ────────────────────────────────────────────────────────

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()

# Dominios canónicos
cur.execute('SELECT id, name FROM domains ORDER BY id')
domain_names = {row['id']: fix_enc(row['name']) for row in cur.fetchall()}

# Fan-in por dominio (impacto de negocio — cuántos callers dependen de este dominio)
cur.execute('''
    SELECT domain, SUM(fan_in) as total_fan_in, COUNT(id) as sp_count
    FROM sps
    WHERE domain IS NOT NULL AND domain != ""
    GROUP BY domain
''')
fan_in_map = {}
sp_count_map = {}
for row in cur.fetchall():
    fan_in_map[row['domain']] = row['total_fan_in'] or 0
    sp_count_map[row['domain']] = row['sp_count'] or 0

# Cobertura regulatoria por dominio (% de reglas con referencia regulatoria)
cur.execute('''
    SELECT domain,
           COUNT(id) as rule_count,
           SUM(CASE WHEN reg IS NOT NULL AND reg != "" AND reg != "[]"
               THEN 1 ELSE 0 END) as reg_count,
           SUM(CASE WHEN riesgo IS NOT NULL AND riesgo != "" AND riesgo != "[]"
               THEN 1 ELSE 0 END) as risk_count,
           SUM(CASE WHEN clase = "NEGOCIO" THEN 1 ELSE 0 END) as negocio_count
    FROM rules
    WHERE domain IS NOT NULL AND domain != ""
    GROUP BY domain
''')
reg_map = {}
for row in cur.fetchall():
    reg_map[row['domain']] = {
        'rule_count': row['rule_count'] or 0,
        'reg_count': row['reg_count'] or 0,
        'risk_count': row['risk_count'] or 0,
        'negocio_count': row['negocio_count'] or 0,
    }

# Refs regulatorias únicas por dominio (top 3 para display)
cur.execute('''
    SELECT domain, reg FROM rules
    WHERE reg IS NOT NULL AND reg != "" AND reg != "[]"
      AND domain IS NOT NULL AND domain != ""
''')
reg_refs_raw = defaultdict(set)
for row in cur.fetchall():
    try:
        refs = json.loads(row['reg'])
        if isinstance(refs, list):
            for r in refs:
                if r:
                    reg_refs_raw[row['domain']].add(str(r).strip())
    except Exception:
        pass
reg_refs = {k: sorted(v)[:4] for k, v in reg_refs_raw.items()}

conn.close()

# ── Calcular scores ───────────────────────────────────────────────────────────

all_domains = list(domain_names.keys())
max_fan_in = max((fan_in_map.get(d, 0) for d in all_domains), default=1) or 1
max_rules = max((reg_map.get(d, {}).get('rule_count', 0) for d in all_domains), default=1) or 1

domains_out = []
for did in all_domains:
    dc = decouple.get(did, {})
    rm = reg_map.get(did, {'rule_count': 0, 'reg_count': 0, 'risk_count': 0, 'negocio_count': 0})

    rule_count = rm['rule_count']
    reg_count = rm['reg_count']
    risk_count = rm['risk_count']
    fan_in = fan_in_map.get(did, 0)
    sp_count = sp_count_map.get(did, 0)
    avg_cost = dc.get('avg_cost', 0)

    # Componentes del Value Score
    reg_pct = reg_count / max(rule_count, 1)
    fan_in_norm = fan_in / max_fan_in
    rule_density = rule_count / max_rules

    # Value: regulatoria (45%) + impacto negocio (40%) + densidad de reglas (15%)
    value_score = round(0.45 * reg_pct + 0.40 * fan_in_norm + 0.15 * rule_density, 4)

    # Effort: decoupling cost normalizado a [0-1]
    effort_score = round(avg_cost / 100, 4)

    # Priority: value / (esfuerzo + bias)
    priority_score = round(value_score / (0.25 + effort_score), 4)

    # Tier (cuadrante)
    v_mid, e_mid = 0.35, 0.35
    if value_score >= v_mid and effort_score <= e_mid:
        tier = 1; tier_label = 'Quick Win'
    elif value_score >= v_mid and effort_score > e_mid:
        tier = 2; tier_label = 'Planificar'
    elif value_score < v_mid and effort_score <= e_mid:
        tier = 3; tier_label = 'Backlog'
    else:
        tier = 4; tier_label = 'Diferir'

    # Acción recomendada
    ACTIONS = {
        1: 'Iniciar migración inmediatamente — bajo riesgo, alto valor regulatorio',
        2: 'Iniciar planning detallado — requiere parallel-run extendido por lock-in',
        3: 'Programar en Wave 2 — bajo impacto, completar después de Tier 1-2',
        4: 'Revisar si es candidato a absorción COTS o retire — ROI cuestionable',
    }

    domains_out.append({
        'id': did,
        'name': domain_names.get(did, did),
        'target': domain_target.get(did, 'unknown'),
        'target_color': TARGET_COLORS.get(domain_target.get(did, ''), '#888'),
        'sp_count': sp_count,
        'sp_in_target': domain_sp_replicate.get(did, sp_count),
        'fan_in': fan_in,
        'rule_count': rule_count,
        'reg_count': reg_count,
        'risk_count': risk_count,
        'negocio_count': rm['negocio_count'],
        'reg_pct': round(reg_pct, 3),
        'risk_pct': round(risk_count / max(rule_count, 1), 3),
        'reg_refs': reg_refs.get(did, []),
        'avg_cost': avg_cost,
        'cost_level': dc.get('cost_level', 'low'),
        'hard_blocks': dc.get('hard_blocks', 0),
        'api_candidates': dc.get('api_candidates', 0),
        'dominant_signal': dc.get('dominant_signal', ''),
        'value_score': value_score,
        'effort_score': effort_score,
        'priority_score': priority_score,
        'tier': tier,
        'tier_label': tier_label,
        'action': ACTIONS[tier],
    })

# Ordenar por priority_score desc
domains_out.sort(key=lambda x: (-x['priority_score'], x['id']))
for i, d in enumerate(domains_out):
    d['rank'] = i + 1

# ── Conteos por tier ─────────────────────────────────────────────────────────

tier_counts = defaultdict(int)
tier_sp = defaultdict(int)
for d in domains_out:
    tier_counts[d['tier']] += 1
    tier_sp[d['tier']] += d['sp_in_target']

# ── Output ───────────────────────────────────────────────────────────────────

out = {
    'domains': domains_out,
    'tiers': {
        '1': {'label': 'Quick Win',  'color': '#4fde8a', 'count': tier_counts[1], 'sp': tier_sp[1]},
        '2': {'label': 'Planificar', 'color': '#f5c842', 'count': tier_counts[2], 'sp': tier_sp[2]},
        '3': {'label': 'Backlog',    'color': '#aab3d4', 'count': tier_counts[3], 'sp': tier_sp[3]},
        '4': {'label': 'Diferir',    'color': '#f55f5f', 'count': tier_counts[4], 'sp': tier_sp[4]},
    },
    'targets': list(TARGET_COLORS.keys()),
    'target_colors': TARGET_COLORS,
    'meta': {
        'total_domains': len(domains_out),
        'formula': 'value=0.45×reg_pct + 0.40×fan_in_norm + 0.15×rule_density; priority=value/(0.25+effort)',
        'value_midpoint': 0.35,
        'effort_midpoint': 0.35,
        'max_fan_in': max_fan_in,
        'max_rules': max_rules,
        'generated_at': date.today().isoformat(),
    }
}

with open(OUT_PATH, 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

print('priority-ranking.json generado:')
print(f'  {len(domains_out)} dominios · Tier 1={tier_counts[1]} · Tier 2={tier_counts[2]} · Tier 3={tier_counts[3]} · Tier 4={tier_counts[4]}')
print(f'  Output: {OUT_PATH}')
print()
print('Top 10 por priority_score:')
for d in domains_out[:10]:
    print(f'  #{d["rank"]:2d} [{d["tier_label"]:10s}] {d["id"]} {d["name"][:20]:20s} | value={d["value_score"]:.3f} effort={d["effort_score"]:.2f} → priority={d["priority_score"]:.3f}')
#!/usr/bin/env python3
"""
build-decoupling-cost.py — BCOPCore Decoupling Cost Generator v1.1
Calcula el costo de desacoplamiento de Informix por SP y dominio.
Tecnología-agnóstico: no asume destino (Unity / AWS / nativo).

Señales de lock-in (5 señales reales de acoplamiento a Informix/AIX):
  CTM_ENTRY/HINT  → depende de Control-M AIX — no puede salir sin reemplazar scheduler
  n_cross_db      → accede a múltiples BDs Informix (ATTACH pattern — no existe en SQL estándar)
  has_contproc    → ON EXCEPTION + CONTINUE PROCEDURE = manejo de errores SPL-específico
  n_commit        → gestión de transacciones multi-paso compleja en SPL
  infra_rules     → DBACCESS / paths AIX / shell calls (clase=INFRAESTRUCTURA en rules)

NOTA: n_foreach NO se usa como señal — en SPL todo loop de cursor usa FOREACH
(equivalente a ResultSet/ORM en Java). El lock-in real de FOREACH es WITH RESUME
(streaming de filas al caller), señal no disponible en batch_analysis actual.

Portabilidad:
  sp_role=entry_point/esb_exposed  → ya tiene contrato ESB → candidato API wrapper
  clase=NEGOCIO puro               → lógica portable sin lock-in Informix

Salida: portal/data/decoupling-cost.json
"""

import json, sqlite3, sys
from collections import defaultdict
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE   = Path(__file__).parent.parent
DB     = BASE / "digital-brain" / "brain.db"
OUT    = BASE / "portal" / "data" / "decoupling-cost.json"

assert DB.exists(), f"brain.db no encontrado: {DB}"

# ── Pesos del scoring ─────────────────────────────────────────────────────────
# Diseño: suma teórica máxima ~100 → cap en 100
W_CTM        = 35   # Control-M AIX scheduler — hard dependency (no sale sin reemplazar)
W_CROSS_DB_H = 25   # n_cross_db >= 3 — acoplamiento horizontal profundo (ATTACH multi-DB)
W_CROSS_DB_M = 15   # n_cross_db == 2 — acoplamiento moderado
W_CONTPROC   = 20   # ON EXCEPTION CONTINUE PROCEDURE — patrón SPL-específico sin equiv SQL
W_COMMIT_H   = 15   # n_commit > 5 — transacciones complejas multi-paso
W_COMMIT_M   = 10   # n_commit 4-5
W_INFRA_H    = 15   # >50% reglas INFRAESTRUCTURA — shell/DBACCESS dominante
W_INFRA_M    =  8   # 25-50% reglas INFRAESTRUCTURA

COST_LEVELS = {
    'low':      (0,  20),
    'medium':   (21, 49),
    'high':     (50, 74),
    'critical': (75, 100),
}

LEVEL_LABELS = {
    'low':      'Bajo — lógica portable',
    'medium':   'Medio — constructs traducibles',
    'high':     'Alto — acoplamiento Informix significativo',
    'critical': 'Crítico — lock-in estructural',
}


def cost_level(score: int) -> str:
    for lvl, (lo, hi) in COST_LEVELS.items():
        if lo <= score <= hi:
            return lvl
    return 'critical'


def dominant_signal(signals: dict) -> str:
    candidates = [
        ('CTM',       signals['ctm']        * W_CTM),
        ('CROSS_DB',  signals['cross_db']   * W_CROSS_DB_H),
        ('CONTPROC',  signals['contproc']   * W_CONTPROC),
        ('COMMIT',    signals['commit']     * W_COMMIT_H),
        ('INFRA',     signals['infra_rules'] * W_INFRA_H),
    ]
    best = max(candidates, key=lambda x: x[1])
    return best[0] if best[1] > 0 else 'NONE'


def fix_encoding(s: str) -> str:
    if not s:
        return s
    try:
        return s.encode('latin-1').decode('utf-8')
    except Exception:
        return s


def main():
    print("=== build-decoupling-cost.py v1.0 ===")
    conn = sqlite3.connect(str(DB))
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    # ── 1. Cargar SPs base ────────────────────────────────────────────────────
    sps_rows = cur.execute("""
        SELECT id, name, db, domain, fan_in, fan_out,
               sp_role, batch_archetype, sp_archetype, rules_n, biz
        FROM sps
    """).fetchall()
    print(f"SPs cargados: {len(sps_rows):,}")

    sp_index = {}  # id → row dict
    for r in sps_rows:
        sp_index[r['id']] = dict(r)

    # ── 2. Señales de batch_analysis (FOREACH, cross_db, commit, contproc) ──
    ba_map = {}   # (db, sp_name) → signals
    for r in cur.execute("""
        SELECT db, sp_name, n_foreach, n_cross_db, n_commit, has_contproc
        FROM batch_analysis
    """):
        ba_map[(r['db'], r['sp_name'])] = {
            'n_foreach':   r['n_foreach'] or 0,
            'n_cross_db':  r['n_cross_db'] or 0,
            'n_commit':    r['n_commit'] or 0,
            'has_contproc': r['has_contproc'] or 0,
        }

    # ── 3. Señales de rules (INFRAESTRUCTURA ratio) ───────────────────────────
    # Agrupar por (sp, db) → {NEGOCIO: n, INFRAESTRUCTURA: n, ...}
    rule_clase = defaultdict(lambda: defaultdict(int))
    for sp, db, clase in cur.execute("SELECT sp, db, clase FROM rules"):
        rule_clase[(sp, db)][clase] += 1

    # ── 4. Cargar dominios para nombres (fix doble-encoding en brain.db) ───────
    dom_names = {}
    for r in cur.execute("SELECT id, name FROM domains"):
        dom_names[r['id']] = fix_encoding(r['name'])

    conn.close()

    # ── 5. Score por SP ───────────────────────────────────────────────────────
    scored = []
    for sp_id, sp in sp_index.items():
        sp_name = sp['name']
        db      = sp['db']
        domain  = sp['domain'] or ''

        # Batch analysis signals
        ba  = ba_map.get((db, sp_name), {})
        ncd = ba.get('n_cross_db', 0)
        nco = ba.get('n_commit', 0)
        hcp = ba.get('has_contproc', 0)

        # Infra rules ratio
        rc = rule_clase.get((sp_name, db), {})
        total_r = sum(rc.values())
        infra_r = rc.get('INFRAESTRUCTURA', 0)
        negocio_r = rc.get('NEGOCIO', 0)
        infra_ratio = infra_r / total_r if total_r > 0 else 0

        # CTM
        is_ctm = 1 if sp['batch_archetype'] in ('CTM_ENTRY', 'CTM_HINT') else 0

        # ─ Scoring — 5 señales reales de lock-in ─
        score = 0
        score += W_CTM        if is_ctm else 0
        score += W_CONTPROC   if hcp else 0
        score += W_CROSS_DB_H if ncd >= 3 else (W_CROSS_DB_M if ncd == 2 else 0)
        score += W_COMMIT_H   if nco > 5  else (W_COMMIT_M   if nco >= 4 else 0)
        score += W_INFRA_H    if infra_ratio > 0.5 else (W_INFRA_M if infra_ratio > 0.25 else 0)
        score = min(100, score)

        level = cost_level(score)

        # ESB / portability
        is_esb = 1 if sp['sp_role'] in ('entry_point', 'esb_exposed') else 0
        is_pure_negocio = 1 if (total_r > 0 and negocio_r == total_r) else 0

        scored.append({
            'id':         sp_id,
            'name':       sp_name,
            'db':         db,
            'domain':     domain,
            'score':      score,
            'level':      level,
            'fan_in':     sp['fan_in'] or 0,
            'fan_out':    sp['fan_out'] or 0,
            'rules_n':    sp['rules_n'] or 0,
            'biz':        fix_encoding(sp['biz'] or ''),
            'is_ctm':     is_ctm,
            'is_esb':     is_esb,
            'is_pure_negocio': is_pure_negocio,
            'signals': {
                'ctm':        is_ctm,
                'cross_db':   1 if ncd >= 2 else 0,
                'commit':     1 if nco > 3 else 0,
                'infra_rules': 1 if infra_ratio > 0.25 else 0,
                'contproc':   hcp,
            },
        })

    # ── 6. Agregar por dominio ────────────────────────────────────────────────
    dom_agg = defaultdict(lambda: {
        'sp_count': 0, 'score_sum': 0, 'rules_sum': 0,
        'dist': {'low': 0, 'medium': 0, 'high': 0, 'critical': 0},
        'signals': {'ctm': 0, 'cross_db': 0,
                    'commit': 0, 'infra_rules': 0, 'contproc': 0},
        'api_candidates': 0, 'hard_blocks': 0, 'pure_negocio': 0,
    })

    for sp in scored:
        d = sp['domain'] or 'NONE'
        agg = dom_agg[d]
        agg['sp_count']  += 1
        agg['score_sum'] += sp['score']
        agg['rules_sum'] += sp['rules_n']
        agg['dist'][sp['level']] += 1
        for sig in agg['signals']:
            agg['signals'][sig] += sp['signals'].get(sig, 0)
        if sp['is_esb'] and sp['level'] in ('low', 'medium'):
            agg['api_candidates'] += 1
        if sp['level'] in ('high', 'critical'):
            agg['hard_blocks'] += 1
        if sp['is_pure_negocio']:
            agg['pure_negocio'] += 1

    domains_out = []
    for dom_id, agg in sorted(dom_agg.items()):
        n   = agg['sp_count']
        avg = round(agg['score_sum'] / n) if n > 0 else 0
        sigs = agg['signals']
        dom_sig_scores = {
            'ctm':        sigs['ctm'],
            'cross_db':   sigs['cross_db'],
            'commit':     sigs['commit'],
            'infra_rules': sigs['infra_rules'],
            'contproc':   sigs['contproc'],
        }
        domains_out.append({
            'id':              dom_id,
            'name':            dom_names.get(dom_id, dom_id),
            'sp_count':        n,
            'avg_cost':        avg,
            'cost_level':      cost_level(avg),
            'dist':            agg['dist'],
            'signals':         dom_sig_scores,
            'api_candidates':  agg['api_candidates'],
            'hard_blocks':     agg['hard_blocks'],
            'pure_negocio':    agg['pure_negocio'],
            'dominant_signal': dominant_signal(dom_sig_scores),
        })
    domains_out.sort(key=lambda x: x['avg_cost'], reverse=True)

    # ── 7. Top SPs ───────────────────────────────────────────────────────────
    top_hard = sorted(
        [s for s in scored if s['level'] in ('high', 'critical')],
        key=lambda x: (-x['score'], -x['fan_in'])
    )[:60]

    top_easy = sorted(
        [s for s in scored if s['level'] == 'low' and s['rules_n'] > 0],
        key=lambda x: (-x['rules_n'], -x['fan_in'])
    )[:60]

    api_candidates = sorted(
        [s for s in scored if s['is_esb'] and s['level'] in ('low', 'medium')],
        key=lambda x: (-x['fan_in'], x['score'])
    )[:40]

    # ── 8. Summary global ─────────────────────────────────────────────────────
    summary = {'low': 0, 'medium': 0, 'high': 0, 'critical': 0}
    for sp in scored:
        summary[sp['level']] += 1

    # ── 9. Escribir JSON ──────────────────────────────────────────────────────
    OUT.parent.mkdir(parents=True, exist_ok=True)
    out = {
        'domains':       domains_out,
        'top_hard':      top_hard,
        'top_easy':      top_easy,
        'api_candidates': api_candidates,
        'summary':       summary,
        'weights': {
            'CTM_ENTRY_HINT': W_CTM,
            'CONTPROC':       W_CONTPROC,
            'CROSS_DB_H':     W_CROSS_DB_H,
            'CROSS_DB_M':     W_CROSS_DB_M,
            'COMMIT_H':       W_COMMIT_H,
            'COMMIT_M':       W_COMMIT_M,
            'INFRA_RULES_H':  W_INFRA_H,
            'INFRA_RULES_M':  W_INFRA_M,
        },
    }
    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False)

    print(f"\n✓ {OUT.name} generado — {len(scored):,} SPs · {len(domains_out)} dominios")
    print(f"\nDistribución global:")
    total = len(scored)
    for lvl in ('low', 'medium', 'high', 'critical'):
        n = summary[lvl]
        bar = '█' * int(n / total * 30)
        print(f"  {lvl:<10}: {n:>6,}  ({n/total*100:5.1f}%)  {bar}")

    print(f"\nTop 10 dominios por costo promedio:")
    for d in domains_out[:10]:
        print(f"  {d['id']} {d['name'][:22]:<22} avg={d['avg_cost']:>3}  "
              f"hard={d['hard_blocks']:>4}  dominant={d['dominant_signal']}")

    print(f"\nAPI candidates (ESB + low/medium cost): {len(api_candidates)}")
    print(f"Hard blocks (high/critical): {sum(1 for s in scored if s['level'] in ('high','critical')):,}")


if __name__ == '__main__':
    main()

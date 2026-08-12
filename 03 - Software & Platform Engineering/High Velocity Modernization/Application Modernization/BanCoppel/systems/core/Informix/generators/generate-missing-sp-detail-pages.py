#!/usr/bin/env python3
# generate-missing-sp-detail-pages.py
# Genera las páginas HTML de detalle de SP faltantes para el portal BCOPCore
# Usage: python generators/generate-missing-sp-detail-pages.py

import sys, io, re, os, json, html as html_mod
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# ──────────────────────────────────────────────────────────────────────────────
# PATHS
# ──────────────────────────────────────────────────────────────────────────────
BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + os.sep
PORTAL = BASE + "portal" + os.sep
SP_DETAIL_DIR = PORTAL + "sp-detail" + os.sep
DATA_DIR = PORTAL + "data" + os.sep

# ──────────────────────────────────────────────────────────────────────────────
# DOMAIN LABEL MAPPING (db → (domain_id, label))
# Source: existing SP detail pages + journeys-data.json
# ──────────────────────────────────────────────────────────────────────────────
DB_DOMAIN_MAP = {
    "bdicnweb":      ("D01", "Canal Digital Web"),
    "bdinteg":       ("D02", "Integracion Core"),
    "bdicred":       ("D03", "Credito"),
    "bdicheq":       ("D04", "Chequera / Debito"),
    "bdisac":        ("D05", "SAC / Transferencias"),
    "bdisolic":      ("D06", "Solicitudes de Credito"),
    "bdiaclaracion": ("D07", "Aclaraciones"),
    "bdispei":       ("D08", "SPEI / CoDi"),
    "bdimnsj":       ("D09", "Mensajeria"),
    "bdisuc":        ("D10", "Sucursales"),
    "bdicobranza":   ("D11", "Cobranza"),
    "bdicont":       ("D12", "Contabilidad"),
    "bditef":        ("D13", "TEF"),
    "bdibei":        ("D14", "BEI"),
    "bdilide":       ("D15", "LIDE / PLD"),
    "intercard":     ("D16", "Tarjetas"),
}

# ──────────────────────────────────────────────────────────────────────────────
# STEP 1: Find missing SPs
# ──────────────────────────────────────────────────────────────────────────────
print("=== BCOPCore SP Detail Page Generator ===")
print()

cap_path = PORTAL + "capability-model-bcop-v2.html"
print(f"Reading capability model: {cap_path}")
cap_html = open(cap_path, encoding='utf-8', errors='replace').read()
sp_refs = set(re.findall(r'"sp"\s*:\s*"([^"]+)"', cap_html))
print(f"  Total SP refs in capability model: {len(sp_refs)}")

existing = {f[len('sp-detail-'):-len('.html')]
            for f in os.listdir(SP_DETAIL_DIR)
            if f.startswith('sp-detail-') and f.endswith('.html')}
print(f"  Existing pages: {len(existing)}")

missing = sorted(sp_refs - existing)
print(f"  Missing pages to generate: {len(missing)}")
print()

# ──────────────────────────────────────────────────────────────────────────────
# STEP 2: Load data sources
# ──────────────────────────────────────────────────────────────────────────────
print("Loading data sources...")

# sp-inventory.json
print("  sp-inventory.json...", end=" ", flush=True)
with open(DATA_DIR + "sp-inventory.json", encoding='utf-8', errors='replace') as f:
    inv_raw = json.load(f)
# Build lookup: both exact name and stripped sp_ prefix
inv_by_name = {}
for entry in inv_raw:
    n = entry['name']
    inv_by_name[n] = entry
    if n.startswith('sp_'):
        inv_by_name[n[3:]] = entry
print(f"{len(inv_raw)} entries")

# business-rules-v2.json
print("  business-rules-v2.json...", end=" ", flush=True)
with open(DATA_DIR + "business-rules-v2.json", encoding='utf-8', errors='replace') as f:
    br_data = json.load(f)
rules_all = br_data.get('rules', [])
# Index by SP name (both forms)
rules_by_sp = {}
for r in rules_all:
    sp = r.get('sp', '')
    if sp not in rules_by_sp:
        rules_by_sp[sp] = []
    rules_by_sp[sp].append(r)
    # Also index without sp_ prefix
    if sp.startswith('sp_'):
        bare = sp[3:]
        if bare not in rules_by_sp:
            rules_by_sp[bare] = []
        rules_by_sp[bare].append(r)
print(f"{len(rules_all)} rules")

# callgraph-data.json — extract edges for callers/callees
print("  callgraph-data.json...", end=" ", flush=True)
with open(DATA_DIR + "callgraph-data.json", encoding='utf-8', errors='replace') as f:
    cg_data = json.load(f)
cg_edges = cg_data.get('graph', {}).get('edges', [])
# Build lookup: sp_id (db:name) -> list of callee IDs and caller IDs
callees_map = {}   # sp_id -> [callee_name, ...]
callers_map = {}   # sp_id -> [caller_name, ...]
for edge in cg_edges:
    src = edge.get('from', '')
    dst = edge.get('to', '')
    # from -> to means src calls dst
    src_name = src.split(':')[-1] if ':' in src else src
    dst_name = dst.split(':')[-1] if ':' in dst else dst
    if src not in callees_map:
        callees_map[src] = []
    callees_map[src].append(dst_name)
    if dst not in callers_map:
        callers_map[dst] = []
    callers_map[dst].append(src_name)
print(f"{len(cg_edges)} edges")

# capability-sp-mapping.json
print("  capability-sp-mapping.json...", end=" ", flush=True)
with open(DATA_DIR + "capability-sp-mapping.json", encoding='utf-8', errors='replace') as f:
    cap_map_data = json.load(f)
# Build reverse index: sp_name -> capability info
sp_to_capability = {}
for cap_id, cap_info in cap_map_data.get('capabilities', {}).items():
    for ksp in cap_info.get('key_sps', []) + cap_info.get('key_sps_fine', []):
        sp_name = ksp.get('name', '')
        if sp_name and sp_name not in sp_to_capability:
            sp_to_capability[sp_name] = {
                'cap_id': cap_id,
                'cap_name': cap_info.get('name', ''),
            }
        # Also without sp_ prefix
        if sp_name.startswith('sp_'):
            bare = sp_name[3:]
            if bare not in sp_to_capability:
                sp_to_capability[bare] = {
                    'cap_id': cap_id,
                    'cap_name': cap_info.get('name', ''),
                }
print(f"{len(sp_to_capability)} SP→capability mappings")
print()

# ──────────────────────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────────────────────
def h(s):
    """HTML-escape a string."""
    return html_mod.escape(str(s) if s is not None else '')

def fmt_num(val, decimals=0):
    """Format number with commas, or '—' if None/0."""
    if val is None:
        return '—'
    try:
        v = float(val)
        if v == 0:
            return '0'
        if decimals == 0:
            return f"{int(v):,}"
        return f"{v:,.{decimals}f}"
    except Exception:
        return '—'

def fmt_pct(val):
    if val is None:
        return '—'
    try:
        return f"{float(val)*100:.2f}%"
    except Exception:
        return '—'

def fmt_latency(val_s):
    """Format latency in seconds → ms or s."""
    if val_s is None:
        return '—'
    try:
        v = float(val_s)
        if v < 1.0:
            return f"{v*1000:.0f}ms"
        return f"{v:.2f}s"
    except Exception:
        return '—'

CATEGORY_BADGE_CLASS = {
    "CALCULO_FINANCIERO": "calc",
    "Calculo Financiero":  "calc",
    "REGULATORIO":         "reg",
    "VALIDACION":          "muted",
    "VALIDACIÓN":          "muted",
    "OPERACIONAL":         "muted",
    "ATENCION_CLIENTE":    "muted",
    "ATENCIÓN_CLIENTE":    "muted",
}

def badge_class_for_category(cat):
    if not cat:
        return "muted"
    cat_u = cat.upper().replace('Á','A').replace('É','E').replace('Ó','O').replace('Ú','U').replace('Ñ','N')
    if 'CALC' in cat_u or 'FINANC' in cat_u:
        return 'calc'
    if 'REG' in cat_u or 'CNBV' in cat_u:
        return 'reg'
    if 'RIESGO' in cat_u or 'RISK' in cat_u:
        return 'risk'
    return 'muted'

# ──────────────────────────────────────────────────────────────────────────────
# HTML TEMPLATE
# ──────────────────────────────────────────────────────────────────────────────
CSS = """
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#122FB1;--blueb:#3D5FCD;--yellow:#F0D224;--ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);--bg:#060d1f}
html{scroll-behavior:smooth}
body{background:var(--bg);color:var(--ink);font-family:'SF Pro Display',-apple-system,'Inter','Segoe UI',sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;line-height:1.6}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;width:55vw;height:55vw;left:-10vw;top:-10vw;border-radius:50%;
  background:radial-gradient(circle,rgba(18,47,177,.45),transparent 70%);filter:blur(80px);animation:f1 20s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:40vw;height:40vw;right:-8vw;bottom:-8vw;border-radius:50%;
  background:radial-gradient(circle,rgba(240,210,36,.12),transparent 70%);filter:blur(80px);animation:f2 26s ease-in-out infinite}
@keyframes f1{50%{transform:translate(5vw,8vh) scale(1.1)}}
@keyframes f2{50%{transform:translate(-5vw,-6vh) scale(1.15)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
nav{position:sticky;top:0;z-index:50;display:flex;align-items:center;gap:12px;padding:13px 28px;
  backdrop-filter:blur(18px) saturate(150%);background:rgba(6,13,31,.7);border-bottom:1px solid rgba(255,255,255,.07)}
nav img{height:20px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
nav .sep{color:rgba(255,255,255,.2);font-size:14px}
nav .bc{font-size:12px;color:var(--muted);font-weight:500}
nav .sp{flex:1}
nav a.back{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:18px;border:1px solid rgba(255,255,255,.09);transition:.2s;text-decoration:none}
nav a.back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.glass{background:var(--glass);backdrop-filter:blur(20px) saturate(150%);border:1px solid var(--glassb);
  border-radius:20px;box-shadow:0 10px 40px rgba(0,0,0,.35),inset 0 1px 0 rgba(255,255,255,.09)}
.wrap{max-width:1040px;margin:0 auto;padding:0 28px}
section{padding:52px 0}
.sp-hero{padding:52px 0 32px}
.sp-domain-tag{display:inline-flex;align-items:center;gap:8px;padding:5px 14px;border-radius:20px;
  font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:#dfe6ff;margin-bottom:20px;
  background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.10)}
.sp-domain-tag .dot{width:6px;height:6px;border-radius:50%;background:var(--yellow);box-shadow:0 0 8px var(--yellow);animation:pulse 2s infinite}
@keyframes pulse{50%{opacity:.3}}
.sp-name{font-size:14px;color:var(--muted2);font-family:'SF Mono',ui-monospace,monospace;letter-spacing:.03em;margin-bottom:8px}
.sp-desc{font-size:clamp(22px,3.5vw,38px);font-weight:800;letter-spacing:-.03em;line-height:1.1;color:#e0ecff;margin-bottom:14px;max-width:68ch}
.metrics{display:flex;gap:12px;flex-wrap:wrap;margin-top:28px}
.metric{padding:14px 22px;text-align:center;min-width:110px}
.metric-n{font-size:28px;font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;
  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.metric-l{font-size:10px;color:var(--muted2);margin-top:5px;text-transform:uppercase;letter-spacing:.07em;font-weight:600}
.metric.warn .metric-n{background:linear-gradient(180deg,var(--yellow),#c8a800);-webkit-background-clip:text;background-clip:text;color:transparent}
.sec-num{font-size:10px;font-weight:800;letter-spacing:.2em;color:var(--yellow);text-transform:uppercase;margin-bottom:10px}
.sec-title{font-size:clamp(22px,3vw,32px);font-weight:800;letter-spacing:-.025em;margin-bottom:8px}
.sec-sub{font-size:14px;color:var(--muted);max-width:72ch;line-height:1.6;margin-bottom:28px}
.divider{height:1px;background:linear-gradient(90deg,rgba(240,210,36,.3),transparent);margin:52px 0 0}
.story-body{font-size:15.5px;color:#d0daf4;line-height:1.75;max-width:78ch}
.story-body p{margin-bottom:18px}
.story-body b{color:#e8f0ff;font-weight:700}
.story-body code{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.22);border-radius:5px;
  padding:1px 6px;font-size:11.5px;color:var(--yellow);font-family:'SF Mono',ui-monospace,monospace}
.call-pills{display:flex;flex-wrap:wrap;gap:8px;margin-top:16px}
.pill{padding:5px 12px;border-radius:20px;font-size:12px;font-weight:600;font-family:monospace}
.pill.callee{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
.pill.caller{background:rgba(61,95,205,.15);border:1px solid rgba(61,95,205,.4);color:#9ab0ff}
.rules-grid{display:flex;flex-direction:column;gap:10px}
.rule-row{display:grid;grid-template-columns:90px 1fr auto;gap:16px;align-items:start;padding:14px 18px;border-radius:14px;
  background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07)}
.rule-row:hover{background:rgba(255,255,255,.055);border-color:rgba(240,210,36,.2)}
.rule-id{font-size:10px;color:var(--muted2);font-family:monospace;font-weight:600;padding-top:2px}
.rule-code{font-family:'SF Mono',ui-monospace,monospace;font-size:12px;color:#a0d0ff;background:rgba(0,0,0,.3);
  border-radius:6px;padding:5px 10px;margin-bottom:6px;word-break:break-all}
.rule-expl{font-size:13px;color:var(--muted);line-height:1.5}
.rule-badges{display:flex;flex-direction:column;align-items:flex-end;gap:5px}
.badge{font-size:10px;font-weight:700;padding:2px 8px;border-radius:8px;white-space:nowrap;letter-spacing:.04em}
.badge.calc{background:rgba(46,123,88,.25);border:1px solid rgba(46,123,88,.5);color:#5de8a0}
.badge.reg{background:rgba(122,58,154,.25);border:1px solid rgba(122,58,154,.5);color:#cc88ff}
.badge.risk{background:rgba(240,100,36,.2);border:1px solid rgba(240,100,36,.4);color:#ff9966;font-size:9px}
.badge.cnbv{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
.badge.muted{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:var(--muted)}
.no-data{font-size:14px;color:var(--muted2);font-style:italic;padding:24px 0}
.chips{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px}
.chip{padding:4px 12px;border-radius:14px;font-size:11px;font-weight:700;letter-spacing:.05em}
.chip.blue{background:rgba(18,47,177,.3);border:1px solid rgba(61,95,205,.5);color:#9ab0ff}
.chip.muted{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.12);color:var(--muted)}
.chip.yellow{background:rgba(240,210,36,.12);border:1px solid rgba(240,210,36,.3);color:var(--yellow)}
.reveal{opacity:0;transform:translateY(24px);transition:opacity .8s cubic-bezier(.16,1,.3,1),transform .8s cubic-bezier(.16,1,.3,1)}
.reveal.in{opacity:1;transform:none}
footer{padding:36px 28px 56px;text-align:center;color:var(--muted2);font-size:11.5px;
  border-top:1px solid rgba(255,255,255,.06);margin-top:40px;line-height:1.8}
code{background:rgba(240,210,36,.1);border:1px solid rgba(240,210,36,.22);border-radius:5px;
  padding:1px 6px;font-size:11.5px;color:var(--yellow);font-family:'SF Mono',ui-monospace,monospace}
"""

REVEAL_JS = """
const io = new IntersectionObserver(es => es.forEach(e => {
  if(e.isIntersecting){ e.target.classList.add('in'); io.unobserve(e.target); }
}), {threshold:.1, rootMargin:'0px 0px -5% 0px'});
document.querySelectorAll('.reveal').forEach(el => {
  const sibs = [...el.parentElement.children].filter(c => c.classList.contains('reveal'));
  el.style.transitionDelay = (Math.min(sibs.indexOf(el), 6) * 80) + 'ms';
  io.observe(el);
});
"""

def build_html(sp_name, inv_entry, rules, callees, callers):
    """Build the full HTML for a SP detail page."""
    db = inv_entry['db']
    domain_id, domain_label = DB_DOMAIN_MAP.get(db, ("D??", db))
    biz = inv_entry.get('biz', '') or sp_name
    # Clean BOM/replacement characters from biz
    biz = biz.replace('�', '').replace('ï¿½', '').strip()
    if not biz:
        biz = sp_name

    sp_role = inv_entry.get('sp_role', 'internal') or 'internal'
    complexity = inv_entry.get('complexity') or 0
    loc = inv_entry.get('loc') or 0
    fan_in = inv_entry.get('fan_in') or 0
    fan_out = inv_entry.get('fan_out') or 0
    prod_calls_day = inv_entry.get('prod_calls_day')
    prod_error_rate = inv_entry.get('prod_error_rate')
    prod_p95_s = inv_entry.get('prod_p95_s')

    has_prod = (prod_calls_day is not None or prod_error_rate is not None or prod_p95_s is not None)
    is_soul = inv_entry.get('is_soul', 0)

    # ── Capability context
    cap_info = sp_to_capability.get(sp_name) or sp_to_capability.get('sp_' + sp_name, {})
    cap_name = cap_info.get('cap_name', '')
    cap_id = cap_info.get('cap_id', '')

    # ── Metrics (warn if fan_in high)
    fan_in_warn = 'warn' if fan_in > 100 else ''

    # ── Role chip label
    role_map = {
        'entry_point':  'entry',
        'internal':     'internal',
        'utility':      'utility',
        'esb_exposed':  'ESB',
        'proc':         'proc',
        'batch':        'batch',
    }
    role_chip = role_map.get(sp_role, sp_role[:8])

    # ── Callee pills (limit 20)
    callees_limited = callees[:20]
    callers_limited = callers[:20]

    # ── Rules HTML
    rules_html_parts = []
    for r in rules[:30]:  # cap at 30 rules per page
        rid = h(r.get('id', ''))
        line = r.get('line', '')
        code = h(r.get('code', '') or '')
        expl = h(r.get('explicacion', '') or '')
        cat = r.get('categoria', '') or r.get('tipo', '')
        bc = badge_class_for_category(cat)
        cat_label = h(cat.replace('_', ' ').title() if cat else 'Operacional')
        rules_html_parts.append(f"""
      <div class="rule-row reveal">
        <div class="rule-id">{rid}<br/>linea {h(str(line))}</div>
        <div class="rule-main">
          <div class="rule-code">{code}</div>
          <div class="rule-expl">{expl}</div>
        </div>
        <div class="rule-badges"><span class="badge {bc}">{cat_label}</span></div>
      </div>""")

    if not rules_html_parts:
        rules_html = '<p class="no-data">Sin reglas de negocio documentadas para este procedimiento.</p>'
    else:
        rules_html = '<div class="rules-grid">' + ''.join(rules_html_parts) + '\n      </div>'

    # ── Call pills HTML
    callee_pills = ''.join(
        f'<span class="pill callee">{h(c)}</span>' for c in callees_limited
    )
    caller_pills = ''.join(
        f'<span class="pill caller">{h(c)}</span>' for c in callers_limited
    )

    calls_html = ''
    if callees_limited:
        calls_html += f'''
      <div style="font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-top:16px;margin-bottom:10px">Llama a</div>
      <div class="call-pills">{callee_pills}</div>'''
    if callers_limited:
        calls_html += f'''
      <div style="font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-top:24px;margin-bottom:10px">Llamado por</div>
      <div class="call-pills">{caller_pills}</div>'''
    if not calls_html:
        calls_html = '<p class="no-data">Sin datos de llamadas disponibles para este procedimiento.</p>'

    # ── Historia funcional narrative
    caller_count = len(callers)
    callee_count = len(callees)
    callees_str = ', '.join(f'<code>{h(c)}</code>' for c in callees[:5])
    if callee_count > 5:
        callees_str += f' y {callee_count - 5} más'

    if caller_count > 0:
        caller_note = f'Recibe llamadas de {caller_count} procedimiento{"s" if caller_count != 1 else ""} en producción.'
    else:
        caller_note = 'Sin callers registrados en el call graph de producción.'

    if callee_count > 0:
        callee_note = f'En su cuerpo principal, delega a {callees_str}.'
    else:
        callee_note = 'No realiza llamadas a otros procedimientos almacenados.'

    cap_note = ''
    if cap_name:
        cap_note = f' Mapeado a la capacidad de negocio <b>{h(cap_name)}</b> ({h(cap_id)}).'

    soul_note = ' <b>Es un alma del sistema</b> — nodo crítico de alta centralidad.' if is_soul else ''

    loc_note = f'{loc:,} líneas de código.' if loc else ''
    complexity_note = f' Complejidad ciclomática: {complexity}.' if complexity else ''

    # ── Domain flow label
    flow_label = "FLUJO OPERATIVO" if sp_role in ('entry_point', 'esb_exposed') else "COMPONENTE INTERNO"

    # ── Production metrics note
    if has_prod:
        prod_note = f'Evidencia de producción disponible: {fmt_num(prod_calls_day)} llamadas/día.'
    else:
        prod_note = 'Sin datos de producción disponibles en la evidencia ESB actual.'

    title = h(sp_name)
    biz_h = h(biz.capitalize())
    domain_id_h = h(domain_id)
    domain_label_h = h(domain_label)
    db_h = h(db)
    flow_label_h = h(flow_label)
    role_chip_h = h(role_chip)

    n_rules = len(rules)

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{title} · BCOPCore</title>
<style>
{CSS}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<nav>
  <img src="../../bancoppel-logo.png" alt="BanCoppel">
  <span class="sep">/</span>
  <span class="bc">BCOPCore · {domain_id_h} · {domain_label_h}</span>
  <span class="sp"></span>
  <a class="back" href="../capability-model-bcop-v2.html">← Modelo de Capacidades</a>
</nav>

<div class="wrap">

  <!-- Hero -->
  <header class="sp-hero">
    <div class="sp-domain-tag"><span class="dot"></span> {domain_id_h} · {domain_label_h} · {db_h} · {flow_label_h}</div>
    <p class="sp-desc">{biz_h}</p>
    <div class="sp-name">{title}</div>
    <div class="chips">
      <span class="chip blue">{domain_label_h}</span>
      <span class="chip muted">{db_h}</span>
      <span class="chip yellow">{role_chip_h}</span>
    </div>
    <div class="metrics">
      <div class="metric glass {fan_in_warn}"><div class="metric-n">{fmt_num(fan_in)}</div><div class="metric-l">Fan-in</div></div>
      <div class="metric glass"><div class="metric-n">{fmt_num(fan_out)}</div><div class="metric-l">Fan-out</div></div>
      <div class="metric glass"><div class="metric-n">{fmt_num(loc)}</div><div class="metric-l">Lineas de codigo</div></div>
      <div class="metric glass"><div class="metric-n">{n_rules}</div><div class="metric-l">Reglas</div></div>
      <div class="metric glass"><div class="metric-n">{fmt_num(prod_calls_day) if prod_calls_day else '—'}</div><div class="metric-l">Llamadas/dia</div></div>
      <div class="metric glass"><div class="metric-n">{fmt_latency(prod_p95_s)}</div><div class="metric-l">Latencia P95</div></div>
    </div>
  </header>

  <div class="divider"></div>

  <!-- 01 Historia Funcional -->
  <section>
    <div class="sec-num reveal">01 · Historia Funcional</div>
    <h2 class="sec-title reveal">{title}</h2>
    <p class="sec-sub reveal">Narrativa reconstruida a partir del call graph y el vocabulario del dominio.</p>
    <div class="story-body reveal">
      <p>El procedimiento <b>{title}</b> implementa la lógica de <em>{biz_h.lower()}</em> en el dominio {domain_label_h} (<code>{db_h}</code>).{soul_note}{cap_note}</p>
      <p>{loc_note}{complexity_note}</p>
      <p>{callee_note}</p>
      <p>{caller_note} {prod_note}</p>
    </div>
    {calls_html}
  </section>

  <div class="divider"></div>

  <!-- 02 Reglas de Negocio -->
  <section>
    <div class="sec-num reveal">02 · Reglas de Negocio</div>
    <h2 class="sec-title reveal">Reglas de Negocio</h2>
    <p class="sec-sub reveal">{n_rules} regla{"s" if n_rules != 1 else ""} extraida{"s" if n_rules != 1 else ""} del codigo fuente.</p>
    {rules_html}
  </section>

</div>

<footer>
  BCOPCore · {domain_id_h} {domain_label_h} · <code>{title}</code> · SPE-AM-001 · Fase DISCOVER<br>
  Datos extraidos desde <code>sp-inventory.json</code> · <code>business-rules-v2.json</code> · <code>callgraph-data.json</code>
</footer>

<script>
{REVEAL_JS}
</script>
</body></html>"""
    return html


def build_stub_html(sp_name):
    """Build a minimal stub page for SPs with no inventory data."""
    title = html_mod.escape(sp_name)
    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{title} · BCOPCore</title>
<style>
{CSS}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<nav>
  <img src="../../bancoppel-logo.png" alt="BanCoppel">
  <span class="sep">/</span>
  <span class="bc">BCOPCore</span>
  <span class="sp"></span>
  <a class="back" href="../capability-model-bcop-v2.html">← Modelo de Capacidades</a>
</nav>

<div class="wrap">
  <header class="sp-hero">
    <div class="sp-domain-tag"><span class="dot"></span> SP · DOMINIO DESCONOCIDO</div>
    <p class="sp-desc">{title}</p>
    <div class="sp-name">{title}</div>
  </header>
  <div class="divider"></div>
  <section>
    <div class="sec-num reveal">01 · Historia Funcional</div>
    <h2 class="sec-title reveal">{title}</h2>
    <p class="sec-sub reveal">Sin datos de produccion disponibles para este procedimiento.</p>
    <p class="no-data">Este SP fue referenciado en el modelo de capacidades pero no cuenta con metadatos en el inventario actual. Puede tratarse de un SP de prueba, un alias, o un procedimiento de un dominio no analizado en la Etapa 1.</p>
  </section>
</div>

<footer>
  BCOPCore · <code>{title}</code> · SPE-AM-001 · Fase DISCOVER<br>
  Stub generado automaticamente — sin datos en sp-inventory.json
</footer>

<script>
{REVEAL_JS}
</script>
</body></html>"""


# ──────────────────────────────────────────────────────────────────────────────
# STEP 3: Generate pages
# ──────────────────────────────────────────────────────────────────────────────
generated = 0
had_data = 0
stubs = 0
no_rules = 0
no_calls = 0

print("Generating HTML pages...")
print()

for sp_name in missing:
    out_path = SP_DETAIL_DIR + f"sp-detail-{sp_name}.html"

    # Get inventory entry
    inv_entry = inv_by_name.get(sp_name) or inv_by_name.get('sp_' + sp_name)

    if not inv_entry:
        # Stub page
        page_html = build_stub_html(sp_name)
        stubs += 1
    else:
        had_data += 1
        # Get rules for this SP (try both name forms)
        rules = rules_by_sp.get(sp_name, [])
        if not rules:
            rules = rules_by_sp.get('sp_' + sp_name, [])
        # Deduplicate rules by id
        seen_ids = set()
        deduped_rules = []
        for r in rules:
            rid = r.get('id', '')
            if rid not in seen_ids:
                seen_ids.add(rid)
                deduped_rules.append(r)
        rules = deduped_rules

        if not rules:
            no_rules += 1

        # Get callers/callees from callgraph
        # The callgraph uses db:sp_name format
        db = inv_entry['db']
        sp_id = f"{db}:{sp_name}"
        # Also try with sp_ prefix
        sp_id_prefixed = f"{db}:sp_{sp_name}" if not sp_name.startswith('sp_') else sp_id

        callees = callees_map.get(sp_id, []) or callees_map.get(sp_id_prefixed, [])
        callers = callers_map.get(sp_id, []) or callers_map.get(sp_id_prefixed, [])

        if not callees and not callers:
            no_calls += 1

        page_html = build_html(sp_name, inv_entry, rules, callees, callers)

    # Write page
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(page_html)
    generated += 1

    if generated % 25 == 0 or generated == len(missing):
        print(f"  [{generated}/{len(missing)}] Generated: {sp_name}")

# ──────────────────────────────────────────────────────────────────────────────
# REPORT
# ──────────────────────────────────────────────────────────────────────────────
print()
print("=" * 50)
print("GENERATION COMPLETE")
print("=" * 50)
print(f"  Total generated:          {generated}")
print(f"  With inventory data:      {had_data}")
print(f"  Stub pages (no data):     {stubs}")
print(f"  With rules:               {had_data - no_rules} / {had_data}")
print(f"  With call graph data:     {had_data - no_calls} / {had_data}")
print()
print(f"Output directory: {SP_DETAIL_DIR}")

# Verify final count
new_existing = {f[len('sp-detail-'):-len('.html')]
                for f in os.listdir(SP_DETAIL_DIR)
                if f.startswith('sp-detail-') and f.endswith('.html')}
print(f"Total pages now in sp-detail/: {len(new_existing)}")
still_missing = sorted(sp_refs - new_existing)
if still_missing:
    print(f"WARNING: Still missing {len(still_missing)} pages: {still_missing[:10]}")
else:
    print("All SP refs in capability model now have detail pages.")
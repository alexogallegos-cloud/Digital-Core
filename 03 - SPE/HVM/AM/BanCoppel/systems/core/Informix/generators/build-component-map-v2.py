#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-component-map-v2.py — Mapa de componentes Informix v2 con D3 force graph.

Fuentes : callgraph-data.json · business-rules-v2.json · vocabulary-inventory.json
Genera  : component-map-bcop-v2.html · SPE-AM-001 · Etapa 3

Vista inicial : hexágonos por dominio (pre-calc force layout, sin tick loop en DOM)
Drill-down    : click en dominio → top-60 SPs del dominio (reglas+fan_in desc)
Info panel    : click en SP → reglas, vocab, callers/callees, métricas
"""
import json, base64
from collections import defaultdict, Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")

# ── Logo ──────────────────────────────────────────────────────────────────────
with open(BASE + "bancoppel-logo.png", "rb") as _f:
    LOGO_B64 = base64.b64encode(_f.read()).decode()

# ── Load ──────────────────────────────────────────────────────────────────────
cg   = json.load(open(BASE + "portal/data/callgraph-data.json",       encoding="utf-8"))
brd  = json.load(open(BASE + "portal/data/business-rules-v2.json",    encoding="utf-8"))
vi   = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))

CG_NODES  = cg["graph"]["nodes"]
CG_EDGES  = cg["graph"]["edges"]
BR_RULES  = brd["rules"]
BR_META   = brd["meta"]
BR_STATS  = brd["stats"]
ALL_TERMS = vi["atomos"] + vi["compuestos"]

# ── Domain map ────────────────────────────────────────────────────────────────
DOMN = {
    # D01-D12 core
    "bdicnweb":"D01","bdinteg":"D02","bdicred":"D03","bdicheq":"D04",
    "bdisac":"D05","bdisolic":"D06","bdiaclaracion":"D07","bdispei":"D08",
    "bdimnsj":"D09","bdisuc":"D10","bdicobranza":"D11","bdicont":"D12",
    # D13-D16 extended (KB knowledge-base confirmed)
    "bditef":"D13","bdibei":"D14","bdilide":"D15","intercard":"D16",
}
# Friendly names for all known DBs (mapped + unmapped)
DOMN_LABELS = {
    "D01":"Canal Web",    "D02":"Integración",  "D03":"Créditos",
    "D04":"Cheques",      "D05":"Saldos/SAC",   "D06":"Solicitudes",
    "D07":"Aclaraciones", "D08":"SPEI",         "D09":"Mensajería",
    "D10":"Sucursales",   "D11":"Cobranza",     "D12":"Contabilidad",
    "D13":"TEF",          "D14":"BEI",          "D15":"PLD/LIDE",
    "D16":"Tarjetas",
    # Unmapped DBs — labels por convención del dominio bancario
    "bdiburo":      "Buró Crédito",
    "bdisitesp":    "Sitio Especial",
    "bditarjeta":   "Tarjeta (tja)",
    "bdidomi":      "Domiciliación",
    "bdiprog":      "Programas",
    "bditransfer":  "Transfer",
    "bdiauditor":   "Auditoría",
    "bditarjcop":   "Tarjeta Coppel",
    "bdivr":        "Voice Response",
    "bdinvers":     "Inversiones",
    "bdicorresp":   "Corresponsalía",
    "bdibpi":       "BPI",
    "bdiedoelec":   "Edo. Elec.",
    "bdimonitorcob":"Monitor Cob.",
    "bditrans":     "Transacciones",
    "bditrapres":   "Trámites Pres.",
    "intercardbpi": "Intercard BPI",
    "bdicplbot":    "Compliance Bot",
    "bdicntchq":    "Cnt. Cheques",
    "bdicat":       "Catálogos",
}

def get_dom(db):
    return DOMN.get(db, db)   # unmapped DBs use their raw db name as key

def get_label(dom_or_db):
    """Label for canonical domains (Dxx) and raw-db unmapped domains alike."""
    return DOMN_LABELS.get(dom_or_db, dom_or_db)

# ── Vocabulary lookup ─────────────────────────────────────────────────────────
VOCAB_MEAN = {}
for t in ALL_TERMS:
    m = t.get("mean", "")
    if m:
        VOCAB_MEAN[t["term"]] = m[:60]

# ── Callgraph adjacency ───────────────────────────────────────────────────────
node_id_to_info   = {n["id"]: n  for n in CG_NODES}
node_label_to_id  = {n["label"]: n["id"] for n in CG_NODES}

callers_of = defaultdict(Counter)  # node_id → {caller_id: count}
callees_of = defaultdict(Counter)  # node_id → {callee_id: count}
for e in CG_EDGES:
    callers_of[e["to"]][e["from"]]   += 1
    callees_of[e["from"]][e["to"]]   += 1

# ── Aggregate rules per SP ────────────────────────────────────────────────────
PRIO = {"literal": 4, "formula": 3, "norma": 2, "infer": 1, "": 0}

sp_agg = defaultdict(lambda: {
    "rc": 0, "cats": Counter(), "hr": False, "regs": set(),
    "expl": "", "econf": "", "vt": set(), "db": ""
})
sp_rules_raw = defaultdict(list)

for r in BR_RULES:
    sp  = r["sp"]
    db  = r.get("db", "")
    cat = r.get("categoria", "OPERACIONAL")

    sp_agg[sp]["rc"]        += 1
    sp_agg[sp]["db"]         = db
    sp_agg[sp]["cats"][cat] += 1
    if r.get("riesgo"):
        sp_agg[sp]["hr"] = True
    for rp in r.get("reg", []):
        sp_agg[sp]["regs"].add(rp[0])

    ec = r.get("expl_conf", "")
    ex = r.get("explicacion", "")
    if ex and PRIO.get(ec, 0) > PRIO.get(sp_agg[sp]["econf"], 0):
        sp_agg[sp]["expl"]  = ex[:120]
        sp_agg[sp]["econf"] = ec

    for vt in r.get("vocab_refs", []):
        sp_agg[sp]["vt"].add(vt)

    if len(sp_rules_raw[sp]) < 5:
        sp_rules_raw[sp].append({
            "tp":   r["tipo"][:2],
            "cat":  cat,
            "code": r.get("code", "")[:60],
            "expl": ex[:85],
            "ec":   ec[:1],
            "ri":   bool(r.get("riesgo")),
            "vd":   [[v["term"], v.get("mean", "")[:35]]
                     for v in r.get("vocab_detail", [])[:2]],
        })

# ── Build SP_ENRICHED ─────────────────────────────────────────────────────────
SP_ENRICHED = {}
for sp, d in sp_agg.items():
    top_cat = d["cats"].most_common(1)[0][0] if d["cats"] else "OPERACIONAL"
    nid = node_label_to_id.get(sp)
    ni  = node_id_to_info.get(nid, {}) if nid else {}
    callers_ids = [k for k, _ in callers_of.get(nid, Counter()).most_common(6)] if nid else []
    callees_ids = [k for k, _ in callees_of.get(nid, Counter()).most_common(6)] if nid else []

    SP_ENRICHED[sp] = {
        "rc":   d["rc"],
        "tc":   top_cat,
        "hr":   d["hr"],
        "regs": sorted(d["regs"]),
        "expl": d["expl"],
        "vt":   sorted(d["vt"])[:8],
        "fi":   ni.get("fan_in",  0),
        "fo":   ni.get("fan_out", 0),
        "loc":  ni.get("loc",     0),
        "db":   d["db"],
        "dom":  get_dom(d["db"]),
        "callers": [cid.split(":", 1)[1] if ":" in cid else cid for cid in callers_ids],
        "callees": [cid.split(":", 1)[1] if ":" in cid else cid for cid in callees_ids],
    }

SP_RULES = dict(sp_rules_raw)

# ── Domain aggregations ───────────────────────────────────────────────────────
dom_agg = defaultdict(lambda: {"sc": 0, "rc": 0, "hr": 0, "sps": [], "db": ""})

for n in CG_NODES:
    db  = n["db"]
    dom = get_dom(db)
    enr = SP_ENRICHED.get(n["label"], {})
    dom_agg[dom]["sc"] += 1
    dom_agg[dom]["rc"] += enr.get("rc", 0)
    dom_agg[dom]["hr"] += 1 if enr.get("hr") else 0
    dom_agg[dom]["db"]  = db
    dom_agg[dom]["sps"].append({
        "sp":  n["label"],
        "rc":  enr.get("rc",  0),
        "fi":  n["fan_in"],
        "fo":  n["fan_out"],
        "tc":  enr.get("tc",  "OPERACIONAL"),
        "hr":  enr.get("hr",  False),
        "loc": n["loc"],
    })

for dom in dom_agg:
    # Sort by dependency density: fan_in + fan_out + rules — most architecturally relevant first
    dom_agg[dom]["sps"].sort(key=lambda s: -(s["fi"] + s["fo"] + s["rc"]))

DOMAINS = {
    dom: {
        "sc":   d["sc"],
        "rc":   d["rc"],
        "hr":   d["hr"],
        "db":   d["db"],
        "name": get_label(dom),
        "sps":  [s["sp"] for s in d["sps"][:50]],  # top-50 by density
    }
    for dom, d in dom_agg.items()
}

# ── Cross-domain aggregated edges ─────────────────────────────────────────────
dom_ecnt = Counter()
for e in CG_EDGES:
    if e.get("cross_db"):
        sd = e["from"].split(":")[0] if ":" in e["from"] else ""
        td = e["to"].split(":")[0]   if ":" in e["to"]   else ""
        if sd and td and sd != td:
            s, t = get_dom(sd), get_dom(td)
            if s != t:
                dom_ecnt[f"{min(s,t)}||{max(s,t)}"] += 1

DOMAIN_EDGES = [
    {"s": k.split("||")[0], "t": k.split("||")[1], "w": v}
    for k, v in dom_ecnt.most_common(80)
]

# ── Per-domain SP-level edges (for drill-down view) ───────────────────────────
# Uses SP_ENRICHED callers/callees (top-6 each) — captures cross-domain edges.
# Satellite SPs: called-by or calling primary SPs but from other domains.
DOMAIN_SP_EDGES = {}
for dom, d in dom_agg.items():
    primary     = [s["sp"] for s in d["sps"][:50]]
    primary_set = set(primary)
    edges       = []
    sat_counts  = Counter()
    seen        = set()

    for sp in primary:
        enr = SP_ENRICHED.get(sp, {})
        for callee in enr.get("callees", [])[:6]:
            if callee != sp:
                k = f"{sp}||{callee}"
                if k not in seen:
                    seen.add(k)
                    edges.append({"s": sp, "t": callee})
                    if callee not in primary_set:
                        sat_counts[callee] += 1
        for caller in enr.get("callers", [])[:6]:
            if caller != sp:
                k = f"{caller}||{sp}"
                if k not in seen:
                    seen.add(k)
                    edges.append({"s": caller, "t": sp})
                    if caller not in primary_set:
                        sat_counts[caller] += 1

    sat = [sp for sp, _ in sat_counts.most_common(30)]
    DOMAIN_SP_EDGES[dom] = {"edges": edges, "sat": sat}

# ── Tile stats ────────────────────────────────────────────────────────────────
n_riesgo_sps = sum(1 for e in SP_ENRICHED.values() if e["hr"])
TILE_META = {
    "cg":   len(CG_NODES),
    "rules": len(BR_RULES),
    "spr":  len(SP_ENRICHED),
    "ri":   n_riesgo_sps,
    "reg":  BR_STATS.get("n_reg", 0),
    "sp_sc": BR_META.get("sp_scanned", 12832),
}

# ── Serialize ─────────────────────────────────────────────────────────────────
def jd(o):
    return json.dumps(o, ensure_ascii=False, separators=(",", ":"))

J_ENRICHED = jd(SP_ENRICHED)
J_RULES    = jd(SP_RULES)
J_VOCAB    = jd(VOCAB_MEAN)
J_DOMAINS  = jd(DOMAINS)
J_DEDGES   = jd(DOMAIN_EDGES)
J_SPEDGES  = jd(DOMAIN_SP_EDGES)
J_TILE     = jd(TILE_META)

# ── HTML Template ─────────────────────────────────────────────────────────────
HTML = r"""<!DOCTYPE html><html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Mapa de Componentes v2</title>
<style>
:root{
  --bg:#060d1f;--bg2:#0a1535;--panel:#0e1e45;--line:#122FB1;
  --brand:#122FB1;--acc:#F0D224;--txt:#EAEDF7;--muted:#8a9cc4;
  --glass:rgba(18,47,177,.12);--glass-b:rgba(18,47,177,.25)
}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;
     height:100vh;display:flex;flex-direction:column;overflow:hidden}
header{background:linear-gradient(135deg,#060d1f 0%,#0d1e50 60%,#112680 100%);
       border-bottom:3px solid var(--brand);padding:10px 20px;flex-shrink:0;
       display:flex;justify-content:space-between;align-items:center;gap:16px}
header .logo{height:28px;object-fit:contain;flex-shrink:0}
header .hinfo{flex:1}
header h1{font-size:14px;font-weight:800;letter-spacing:.02em}
header .sub{font-size:9px;color:var(--muted);margin-top:2px}
header .badge{font-size:10px;color:var(--acc);font-weight:700;
              background:rgba(240,210,36,.12);padding:3px 9px;border-radius:4px;
              border:1px solid rgba(240,210,36,.35);white-space:nowrap;flex-shrink:0}
#tiles{display:flex;gap:6px;padding:7px 20px;flex-wrap:wrap;flex-shrink:0}
.tile{background:var(--glass);backdrop-filter:blur(14px) saturate(140%);
      border-radius:8px;padding:6px 13px;border:1px solid var(--glass-b);
      border-left:3px solid var(--brand)}
.tile .n{font-size:16px;font-weight:800}
.tile .l{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
.tile.t-reg{border-left-color:#7c3aed}
.tile.t-ri{border-left-color:#dc2626}
#main{flex:1;display:flex;overflow:hidden;min-height:0}
/* ── Sidebar ── */
#sidebar{width:250px;flex-shrink:0;display:flex;flex-direction:column;
         border-right:1px solid rgba(18,47,177,.4);background:var(--bg2);overflow:hidden}
#sb-top{padding:8px 10px;border-bottom:1px solid rgba(18,47,177,.3);flex-shrink:0}
#q{width:100%;background:var(--panel);border:1px solid rgba(18,47,177,.5);
   border-radius:6px;color:var(--txt);padding:6px 9px;font-size:11px;outline:none}
#q:focus{border-color:var(--acc)}
#chips{display:flex;gap:3px;flex-wrap:wrap;margin-top:6px}
.chip{background:var(--panel);border:1px solid rgba(18,47,177,.4);border-radius:10px;
      padding:2px 7px;font-size:9px;color:var(--muted);cursor:pointer;user-select:none;
      transition:all .12s}
.chip:hover{border-color:var(--brand);color:var(--txt)}
.chip.on{border-color:var(--acc);color:var(--acc);background:rgba(240,210,36,.08)}
.chip-ri{border-color:rgba(220,38,38,.4);color:#f87171}
.chip-ri.on{border-color:#dc2626;color:#fca5a5;background:rgba(220,38,38,.08)}
#dom-nav{flex:1;overflow-y:auto;padding:4px 0}
.dom-nav-item{display:flex;align-items:center;gap:6px;padding:5px 10px;
              cursor:pointer;user-select:none;font-size:11px;
              border-left:2px solid transparent;transition:all .12s}
.dom-nav-item:hover{background:rgba(18,47,177,.15);border-left-color:var(--brand)}
.dom-nav-item.active{background:rgba(18,47,177,.25);border-left-color:var(--acc);
                     color:var(--acc)}
.dom-dot{width:8px;height:8px;border-radius:2px;flex-shrink:0}
.dom-name{flex:1;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-size:10px}
.dom-cnt{font-size:9px;color:var(--muted);flex-shrink:0;white-space:nowrap}
.dom-cnt .rc{color:var(--acc);font-weight:700}
/* ── Info panel — floating overlay on canvas ── */
#info-panel{position:absolute;top:50px;right:10px;width:350px;
            max-height:calc(100% - 70px);background:rgba(6,12,32,.97);
            border:1px solid rgba(18,47,177,.7);border-radius:10px;
            overflow:hidden;display:none;z-index:20;flex-direction:column;
            box-shadow:0 8px 40px rgba(0,0,0,.7)}
#info-panel.visible{display:flex}
.ip-hd{display:flex;justify-content:space-between;align-items:flex-start;
        padding:12px 14px 9px;border-bottom:1px solid rgba(18,47,177,.4);flex-shrink:0;
        background:rgba(18,47,177,.12)}
.ip-name{font-family:'Cascadia Code',monospace;font-size:13px;font-weight:700;
         color:var(--acc);word-break:break-all;flex:1;line-height:1.25}
.ip-close{width:24px;height:24px;border:none;background:rgba(18,47,177,.3);
          border-radius:5px;color:var(--muted);cursor:pointer;font-size:15px;
          display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-left:8px}
.ip-close:hover{background:rgba(220,38,38,.5);color:#fff}
.ip-body{overflow-y:auto;padding:10px 14px;flex:1}
.ip-meta{font-size:9px;color:var(--muted);margin-bottom:7px}
.ip-stats{display:flex;gap:14px;margin-bottom:8px;padding:7px 10px;
          background:rgba(18,47,177,.1);border-radius:6px}
.ip-stat .v{font-size:15px;font-weight:800}
.ip-stat .k{font-size:7px;color:var(--muted);text-transform:uppercase;letter-spacing:.04em}
.ip-expl-block{font-size:10px;color:#c8e4f8;line-height:1.45;padding:7px 9px;
               background:rgba(10,30,70,.55);border-radius:6px;margin-bottom:7px;
               border-left:2px solid rgba(18,47,177,.7)}
.ip-sec{font-size:8px;text-transform:uppercase;letter-spacing:.06em;
        color:var(--muted);margin:8px 0 4px;padding-bottom:2px;
        border-bottom:1px solid rgba(18,47,177,.2)}
.ip-rel-row{display:flex;flex-wrap:wrap;gap:3px;margin-bottom:4px}
.ip-caller{font-family:'Cascadia Code',monospace;font-size:9px;padding:2px 6px;
           border-radius:3px;cursor:pointer;user-select:none;
           background:rgba(100,181,232,.1);border:1px solid rgba(100,181,232,.35);color:#64b5e8}
.ip-caller:hover{background:rgba(100,181,232,.25)}
.ip-callee{font-family:'Cascadia Code',monospace;font-size:9px;padding:2px 6px;
           border-radius:3px;cursor:pointer;user-select:none;
           background:rgba(240,210,36,.09);border:1px solid rgba(240,210,36,.35);color:#F0D224}
.ip-callee:hover{background:rgba(240,210,36,.22)}
.ip-rule{font-size:9px;padding:5px 7px;background:rgba(18,47,177,.1);
         border-radius:4px;margin-bottom:3px;border-left:2px solid transparent}
.ip-tp{font-size:8px;font-weight:700;padding:1px 5px;border-radius:3px;
       display:inline-block;margin-right:4px;vertical-align:middle}
.ip-cat{font-size:8px;padding:1px 4px;border-radius:3px;display:inline-block;
        margin-right:4px;vertical-align:middle;border:1px solid transparent}
.ip-expl{color:#c8d8f0;font-size:9px;margin-top:3px;line-height:1.3}
.ip-ri{font-size:8px;color:#f87171;display:inline-block;margin-left:4px}
.ip-vd{font-size:8px;margin-top:2px}
.ip-vd .vt{color:#e6ca40}
.ip-vd .vm{color:#8ab0c8}
.vt-tag{font-size:8px;background:rgba(240,210,36,.08);border:1px solid rgba(240,210,36,.2);
        color:#e6ca40;padding:1px 5px;border-radius:3px;display:inline-block;margin:1px 2px}
.rg-tag{font-size:8px;font-weight:700;padding:1px 5px;border-radius:8px;
        display:inline-block;margin:1px 2px;color:#fff}
.ip-detail-link{display:block;margin:10px 14px 14px;padding:8px 12px;border-radius:8px;
  text-align:center;font-size:11px;font-weight:700;color:#060d1f;
  background:var(--yellow);text-decoration:none;transition:.2s;letter-spacing:.01em}
.ip-detail-link:hover{background:#fff;color:#0d1a40}
/* selected node glow */
.sp-node.selected circle{filter:drop-shadow(0 0 5px rgba(240,210,36,.8))}
/* ── Canvas ── */
#canvas-wrap{flex:1;position:relative;overflow:hidden;background:var(--bg);min-width:0}
#svg{width:100%;height:100%;display:block}
#back-btn{position:absolute;top:10px;left:10px;background:rgba(14,30,69,.92);
          border:1px solid var(--brand);border-radius:6px;padding:5px 12px;
          font-size:11px;cursor:pointer;color:var(--txt);display:none;
          align-items:center;gap:5px;z-index:10;user-select:none}
#back-btn:hover{border-color:var(--acc);color:var(--acc)}
#dom-label{position:absolute;top:10px;left:50%;transform:translateX(-50%);
           background:rgba(14,30,69,.88);border:1px solid rgba(18,47,177,.5);
           border-radius:6px;padding:4px 14px;font-size:11px;font-weight:700;
           color:var(--acc);pointer-events:none;display:none;z-index:10;white-space:nowrap}
#hint{position:absolute;bottom:8px;right:12px;font-size:9px;color:var(--muted);
      pointer-events:none;z-index:10}
::-webkit-scrollbar{width:4px}
::-webkit-scrollbar-track{background:var(--bg)}
::-webkit-scrollbar-thumb{background:rgba(18,47,177,.4);border-radius:2px}
</style></head><body>

<header>
  <img class="logo" src="data:image/png;base64,__LOGO__" alt="BanCoppel">
  <div class="hinfo">
    <h1>Mapa de Componentes · Informix v2</h1>
    <div class="sub">SPE-AM-001 · Etapa 3 · D3 Force Graph · callgraph + reglas de negocio + vocabulario · 2026-08-02</div>
  </div>
  <div class="badge" id="hbadge"></div>
</header>

<div id="tiles"></div>

<div id="main">
  <div id="sidebar">
    <div id="sb-top">
      <input id="q" placeholder="SP, vocab, explicación…" autocomplete="off">
      <div id="chips"></div>
    </div>
    <div id="dom-nav"></div>
  </div>
  <div id="canvas-wrap">
    <button id="back-btn" onclick="renderDomains()">← Dominios</button>
    <div id="dom-label"></div>
    <svg id="svg"></svg>
    <div id="info-panel"></div>
    <div id="hint">scroll=zoom · drag=pan · click dominio=drill-down · click SP=detalle</div>
  </div>
</div>

<script src="https://d3js.org/d3.v7.min.js"></script>
<script>
// === Embedded data ============================================================
const SP_ENRICHED    = __SP_ENRICHED__;
const SP_RULES       = __SP_RULES__;
const VOCAB_MEAN     = __VOCAB_MEAN__;
const DOMAINS        = __DOMAINS__;
const DOMAIN_EDGES   = __DOMAIN_EDGES__;
const DOMAIN_SP_EDGES= __DOMAIN_SP_EDGES__;
const TILE_META      = __TILE_META__;

// === Constants ================================================================
const CAT_META = {
  'REGULATORIO':          {col:'#7a3a9a',bg:'#2a0a3a',lbl:'Regulatorio'},
  'CALCULO_FINANCIERO':   {col:'#2e7b58',bg:'#052e16',lbl:'Cálculo Financiero'},
  'CONTABILIDAD_REPORTES':{col:'#2060aa',bg:'#091e40',lbl:'Contabilidad / Reportes'},
  'PAGOS_TRANSFERENCIAS': {col:'#9c6010',bg:'#3d1a00',lbl:'Pagos y Transferencias'},
  'ATENCION_CLIENTE':     {col:'#1a7070',bg:'#0a2020',lbl:'Atención al Cliente'},
  'RIESGO_CREDITO':       {col:'#ab7020',bg:'#3d2a00',lbl:'Riesgo de Crédito'},
  'FLUJO_OPERATIVO':      {col:'#6a3a9a',bg:'#1a0a3a',lbl:'Flujo Operativo'},
  'PARAMETRIA':           {col:'#4a5a8a',bg:'#0a1a30',lbl:'Parametría'},
  'OPERACIONAL':          {col:'#5a6080',bg:'#1a1a2a',lbl:'Operacional'},
};
const DOM_COLOR = {
  // D01-D12 core
  'D01':'#1e4a8a','D02':'#1a6b3a','D03':'#7a1a1a','D04':'#6b5a00',
  'D05':'#1a5a5a','D06':'#3a1a7a','D07':'#6b3a10','D08':'#0a5a7a',
  'D09':'#4a5a1a','D10':'#7a3a1a','D11':'#1a1a7a','D12':'#2a6b2a',
  // D13-D16 extended
  'D13':'#1a3a60','D14':'#3a2060','D15':'#601a1a','D16':'#204060',
  // Unmapped DBs — neutral palette, distinguishable
  'bdiburo':      '#3a4020','bdisitesp':   '#203a3a','bditarjeta':  '#402040',
  'bdidomi':      '#2a3a20','bdiprog':     '#1a2040','bditransfer': '#3a2010',
  'bdiauditor':   '#3a1a30','bditarjcop':  '#402010','bdivr':       '#1a3040',
  'bdinvers':     '#203020','bdicorresp':  '#2a2a3a','bdibpi':      '#302040',
  'bdiedoelec':   '#1a3030','bdimonitorcob':'#303010','bditrans':   '#1a2a30',
  'bditrapres':   '#2a1a30','intercardbpi':'#1a3a30','bdicplbot':   '#2a2010',
  'bdicntchq':    '#1a2020','bdicat':      '#101a30',
};
const REGCOL = {
  CNBV:'#2e6b48',Banxico:'#1e5a8a',CONDUSEF:'#6b3080',
  SAT:'#8b6b20',TESOFE:'#7a2020',IPAB:'#5a2a6b'
};
const TIPO_STYLE = {
  'FÓ':{bg:'#052e16',col:'#86efac'},'VA':{bg:'#1e2a3f',col:'#93c5fd'},
  'UM':{bg:'#3d1a00',col:'#fdba74'},'ES':{bg:'#0a2a2a',col:'#5eead4'},
};

function catColor(cat){ return (CAT_META[cat]||CAT_META['OPERACIONAL']).col; }
function domColor(dom){ return DOM_COLOR[dom]||'#2a3a5a'; }
function hexPath(r){
  const p=[];
  for(let i=0;i<6;i++){
    const a=(Math.PI/3)*i - Math.PI/6;
    p.push(r*Math.cos(a)+','+r*Math.sin(a));
  }
  return 'M'+p.join('L')+'Z';
}
function esc(s){ return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

// === State ====================================================================
let currentDom = null;
let activeFilter = { q:'', cats:new Set(), ri:false };

// === SVG & zoom setup =========================================================
const canvasWrap = document.getElementById('canvas-wrap');
let W = canvasWrap.clientWidth  || 800;
let H = canvasWrap.clientHeight || 600;

const svg = d3.select('#svg');
const g   = svg.append('g');

const zoom = d3.zoom()
  .scaleExtent([0.05, 12])
  .on('zoom', e => g.attr('transform', e.transform));
svg.call(zoom);

svg.on('click', () => { if(currentDom) deselectSP(); });

window.addEventListener('resize', () => {
  W = canvasWrap.clientWidth  || 800;
  H = canvasWrap.clientHeight || 600;
});

// === Tiles ====================================================================
document.getElementById('hbadge').textContent =
  TILE_META.cg.toLocaleString()+' SPs · '+TILE_META.rules.toLocaleString()+' reglas';

document.getElementById('tiles').innerHTML = [
  ['',      TILE_META.cg,    'SPs callgraph'],
  ['',      TILE_META.spr,   'SPs con reglas'],
  ['',      TILE_META.rules, 'Reglas totales'],
  ['t-ri',  TILE_META.ri,    '⚠ SPs riesgo equiv.'],
  ['t-reg', TILE_META.reg,   'Reglas regulatorias'],
].map(([c,n,l])=>
  '<div class="tile '+c+'"><div class="n">'+n.toLocaleString()+'</div><div class="l">'+l+'</div></div>'
).join('');

// === Filter chips =============================================================
const catChips = [
  ['REGULATORIO','Regulatorio'],['CALCULO_FINANCIERO','Cálculo Financiero'],
  ['CONTABILIDAD_REPORTES','Contabilidad / Reportes'],['PAGOS_TRANSFERENCIAS','Pagos y Transferencias'],
  ['ATENCION_CLIENTE','Atención al Cliente'],['RIESGO_CREDITO','Riesgo de Crédito'],
  ['FLUJO_OPERATIVO','Flujo Operativo'],['PARAMETRIA','Parametría'],['OPERACIONAL','Operacional'],
];
const chipsEl = document.getElementById('chips');
catChips.forEach(([cat,lbl]) => {
  const c = document.createElement('span');
  c.className = 'chip'; c.dataset.cat = cat; c.textContent = lbl;
  const m = CAT_META[cat];
  if(m){ c.style.borderColor = m.col+'55'; c.style.color = m.col; }
  c.onclick = () => {
    if(activeFilter.cats.has(cat)){ activeFilter.cats.delete(cat); c.classList.remove('on'); }
    else { activeFilter.cats.add(cat); c.classList.add('on'); }
    applyFilter();
  };
  chipsEl.appendChild(c);
});
const riChip = document.createElement('span');
riChip.className='chip chip-ri'; riChip.textContent='⚠ equiv.';
riChip.onclick=()=>{ activeFilter.ri=!activeFilter.ri; riChip.classList.toggle('on',activeFilter.ri); applyFilter(); };
chipsEl.appendChild(riChip);

// === Search ===================================================================
document.getElementById('q').oninput = e => {
  activeFilter.q = e.target.value.toLowerCase();
  applyFilter();
};

function matchesSP(sp){
  const e = SP_ENRICHED[sp]||{};
  if(activeFilter.ri && !e.hr) return false;
  if(activeFilter.cats.size && !activeFilter.cats.has(e.tc)) return false;
  if(!activeFilter.q) return true;
  const q = activeFilter.q;
  return sp.toLowerCase().includes(q) ||
         (e.expl||'').toLowerCase().includes(q) ||
         (e.vt||[]).some(v=>v.toLowerCase().includes(q));
}

// === Domain nav ===============================================================
function buildDomNav(){
  const nav = document.getElementById('dom-nav');
  nav.innerHTML = '';
  const keys = Object.keys(DOMAINS).sort((a,b)=>{
    const ca=/^D\d+$/.test(a), cb=/^D\d+$/.test(b);
    if(ca!==cb) return ca?-1:1;
    return (DOMAINS[b].rc||0)-(DOMAINS[a].rc||0);
  });
  keys.forEach(dom=>{
    const d  = DOMAINS[dom];
    const el = document.createElement('div');
    el.className='dom-nav-item'; el.dataset.dom=dom;
    const mc = (activeFilter.q||activeFilter.cats.size||activeFilter.ri)
      ? d.sps.filter(sp=>matchesSP(sp)).length : d.sc;
    el.innerHTML =
      '<span class="dom-dot" style="background:'+domColor(dom)+'"></span>'+
      '<span class="dom-name">'+esc(dom+' '+(d.name||''))+'</span>'+
      '<span class="dom-cnt"><span class="rc">'+mc+'</span>/'+d.sc+'</span>';
    el.onclick = () => renderDomainSPs(dom);
    nav.appendChild(el);
  });
}

function updateDomNav(){
  document.querySelectorAll('.dom-nav-item').forEach(el=>{
    const dom=el.dataset.dom, d=DOMAINS[dom]||{};
    const mc=(activeFilter.q||activeFilter.cats.size||activeFilter.ri)
      ?(d.sps||[]).filter(sp=>matchesSP(sp)).length : d.sc;
    const rc=el.querySelector('.rc');
    if(rc) rc.textContent=mc;
    el.classList.toggle('active', dom===currentDom);
  });
}

// === Apply filter =============================================================
function applyFilter(){ updateDomNav(); if(currentDom) applySpFilter(); else applyDomainFilter(); }

function applyDomainFilter(){
  if(!activeFilter.q && !activeFilter.cats.size && !activeFilter.ri){
    g.selectAll('.dom-node').attr('opacity',1); return;
  }
  g.selectAll('.dom-node').attr('opacity', function(d){
    return (DOMAINS[d.id]?.sps||[]).some(sp=>matchesSP(sp)) ? 1 : 0.18;
  });
}

function applySpFilter(){
  if(!activeFilter.q && !activeFilter.cats.size && !activeFilter.ri){
    g.selectAll('.sp-node').attr('opacity',1); return;
  }
  g.selectAll('.sp-node').attr('opacity', d => matchesSP(d.id) ? 1 : 0.14);
}

// === Info panel ===============================================================
function deselectSP(){
  document.getElementById('info-panel').classList.remove('visible');
  g.selectAll('.sp-node').classed('selected',false).attr('opacity', d => {
    if(!activeFilter.q && !activeFilter.cats.size && !activeFilter.ri) return 1;
    return matchesSP(d.id) ? 1 : 0.14;
  });
  // Restore edge styles
  g.selectAll('.sp-link')
    .attr('stroke', l=>{
      const tSat = satSet.has(typeof l.target==='object'?l.target.id:l.target);
      const sSat = satSet.has(typeof l.source==='object'?l.source.id:l.source);
      return (sSat||tSat) ? '#3a6080' : '#4a7fff';
    })
    .attr('stroke-opacity', l=>{
      const tSat = satSet.has(typeof l.target==='object'?l.target.id:l.target);
      const sSat = satSet.has(typeof l.source==='object'?l.source.id:l.source);
      return (sSat||tSat) ? 0.25 : 0.5;
    })
    .attr('stroke-width', 1);
}

// satSet accessible from deselectSP — set during renderDomainSPs
let satSet = new Set();

function showSPPanel(sp){
  const enr   = SP_ENRICHED[sp]||{};
  const rules = SP_RULES[sp]||[];

  // ── Highlight dependencies in graph ──────────────────────────────────────────
  const connectedIds = new Set([sp]);
  const callerVis    = new Set();
  const calleeVis    = new Set();

  g.selectAll('.sp-link').each(function(l){
    const sid = typeof l.source==='object' ? l.source.id : l.source;
    const tid = typeof l.target==='object' ? l.target.id : l.target;
    if(sid===sp){ connectedIds.add(tid); calleeVis.add(tid); }
    if(tid===sp){ connectedIds.add(sid); callerVis.add(sid); }
  });

  g.selectAll('.sp-node')
    .classed('selected', d=>d.id===sp)
    .attr('opacity', d=>connectedIds.has(d.id) ? 1 : 0.07);

  g.selectAll('.sp-link')
    .attr('stroke', l=>{
      const sid = typeof l.source==='object' ? l.source.id : l.source;
      const tid = typeof l.target==='object' ? l.target.id : l.target;
      if(sid===sp) return '#F0D224';
      if(tid===sp) return '#64b5e8';
      return '#0d1a35';
    })
    .attr('stroke-opacity', l=>{
      const sid = typeof l.source==='object' ? l.source.id : l.source;
      const tid = typeof l.target==='object' ? l.target.id : l.target;
      return (sid===sp||tid===sp) ? 0.9 : 0.04;
    })
    .attr('stroke-width', l=>{
      const sid = typeof l.source==='object' ? l.source.id : l.source;
      const tid = typeof l.target==='object' ? l.target.id : l.target;
      return (sid===sp||tid===sp) ? 2.5 : 1;
    });

  // ── Build popup HTML ──────────────────────────────────────────────────────────
  const confBg  = {literal:'#1a3a1a',formula:'#2a2500',norma:'#25103a',infer:'#1e2535'};
  const confCol = {literal:'#6ee87a',formula:'#f0d224',norma:'#c084fc',infer:'#8a9cc4'};
  const statCol = {fi:'#64b5e8',fo:'#F0D224',loc:'#8ab0c8',rc:'#a07ae8'};

  // Merge visible callers/callees with enriched data
  const allCallers = [...new Set([...callerVis, ...(enr.callers||[])])].filter(x=>x!==sp).slice(0,10);
  const allCallees = [...new Set([...calleeVis, ...(enr.callees||[])])].filter(x=>x!==sp).slice(0,10);

  let html = '<div class="ip-hd">'+
    '<div class="ip-name">'+esc(sp)+'</div>'+
    '<button class="ip-close" onclick="deselectSP()">✕</button>'+
    '</div>'+
    '<div class="ip-body">'+
    '<div class="ip-meta">'+esc(enr.db||'')+'&nbsp;·&nbsp;'+esc(enr.dom||'')+
    '&nbsp;·&nbsp;<span style="color:'+catColor(enr.tc||'OPERACIONAL')+'">'+(enr.tc||'OPERACIONAL')+'</span>'+
    (enr.hr?'&nbsp;<span style="color:#fca5a5">⚠ riesgo equiv.</span>':'')+'</div>';

  // Stats bar
  html+='<div class="ip-stats">'+
    ['fi','fo','loc','rc'].map(k=>{
      const labels={fi:'fan_in',fo:'fan_out',loc:'LOC',rc:'reglas'};
      return '<div class="ip-stat"><div class="v" style="color:'+statCol[k]+'">'+(enr[k]||0)+
             '</div><div class="k">'+labels[k]+'</div></div>';
    }).join('')+'</div>';

  // Explanation block
  if(enr.expl){
    const ec = enr.expc||'';
    html+='<div class="ip-expl-block">'+esc(enr.expl)+
      (ec?'<span style="font-size:7px;font-weight:700;padding:1px 4px;border-radius:2px;'+
        'background:'+(confBg[ec]||'#1e2535')+';color:'+(confCol[ec]||'#8a9cc4')+
        ';margin-left:7px;vertical-align:middle">'+esc(ec)+'</span>':'')+
      '</div>';
  }

  // Dependencies
  if(allCallers.length||allCallees.length){
    html+='<div class="ip-sec">Dependencias · callgraph</div>';
    if(allCallers.length){
      html+='<div style="font-size:8px;color:#64b5e8;margin:2px 0 3px">Llamado por ('+allCallers.length+'):</div>'+
        '<div class="ip-rel-row">'+
        allCallers.map(s=>'<span class="ip-caller" onclick="jumpToSP(\''+esc(s)+'\')" title="'+esc(s)+'">↓&nbsp;'+esc(s)+'</span>').join('')+
        '</div>';
    }
    if(allCallees.length){
      html+='<div style="font-size:8px;color:#F0D224;margin:5px 0 3px">Llama a ('+allCallees.length+'):</div>'+
        '<div class="ip-rel-row">'+
        allCallees.map(s=>'<span class="ip-callee" onclick="jumpToSP(\''+esc(s)+'\')" title="'+esc(s)+'">↑&nbsp;'+esc(s)+'</span>').join('')+
        '</div>';
    }
  }

  // Regulators
  if(enr.regs && enr.regs.length){
    html+='<div class="ip-sec">Reguladores</div>'+
      enr.regs.map(r=>'<span class="rg-tag" style="background:'+(REGCOL[r]||'#2a2a4a')+'">'+esc(r)+'</span>').join('');
  }

  // Rules
  if(rules.length){
    html+='<div class="ip-sec">Reglas ('+rules.length+(rules.length===5?'+':'')+')</div>';
    rules.forEach(r=>{
      const cm=CAT_META[r.cat]||CAT_META['OPERACIONAL'];
      const ts=TIPO_STYLE[r.tp]||TIPO_STYLE['VA'];
      html+='<div class="ip-rule" style="border-left-color:'+cm.col+'">'+
        '<span class="ip-tp" style="background:'+ts.bg+';color:'+ts.col+'">'+esc(r.tp)+'</span>'+
        '<span class="ip-cat" style="background:'+cm.bg+';color:'+cm.col+';border-color:'+cm.col+'44">'+cm.lbl+'</span>'+
        (r.ri?'<span class="ip-ri">⚠</span>':'')+
        (r.expl?'<div class="ip-expl">'+esc(r.expl)+'</div>':'')+
        (r.vd||[]).filter(v=>v[1]).map(v=>
          '<div class="ip-vd"><span class="vt">'+esc(v[0])+'</span>: <span class="vm">'+esc(v[1])+'</span></div>'
        ).join('')+'</div>';
    });
  }

  // Vocabulary
  if(enr.vt && enr.vt.length){
    html+='<div class="ip-sec">Vocabulario</div>'+
      enr.vt.map(t=>'<span class="vt-tag" title="'+esc(VOCAB_MEAN[t]||'')+'">'+esc(t)+'</span>').join('');
  }

  // Detail page link
  html+='<a class="ip-detail-link" href="sp-detail-'+sp+'.html" target="_blank">'+
    'Ver historia funcional completa →</a>';

  html+='</div>';  // close ip-body

  const panel = document.getElementById('info-panel');
  panel.innerHTML = html;
  panel.classList.add('visible');
}

function jumpToSP(sp){
  const hit = g.selectAll('.sp-node').filter(d=>d.id===sp);
  if(!hit.empty()) showSPPanel(sp);
  else {
    // SP not in current view — show data only (no graph highlight)
    showSPPanel(sp);
  }
}

// === Domain view ==============================================================
function renderDomains(){
  currentDom = null;
  satSet = new Set();
  document.getElementById('back-btn').style.display  = 'none';
  document.getElementById('dom-label').style.display = 'none';
  document.getElementById('info-panel').classList.remove('visible');
  updateDomNav();

  // Only keep domains that appear in at least one edge OR are canonical (D01-D16)
  const linkedDoms = new Set();
  DOMAIN_EDGES.forEach(e=>{ linkedDoms.add(e.s); linkedDoms.add(e.t); });
  const keys  = Object.keys(DOMAINS).filter(k=>/^D\d+$/.test(k)||linkedDoms.has(k));
  const nodes = keys.map(k=>({
    id:k, label:DOMAINS[k].name||k,
    sc:DOMAINS[k].sc||0, rc:DOMAINS[k].rc||0, hr:DOMAINS[k].hr||0,
  }));
  const nodeSet = new Set(keys);
  const links   = DOMAIN_EDGES
    .filter(e=>nodeSet.has(e.s)&&nodeSet.has(e.t))
    .slice(0,80)
    .map(e=>({source:e.s, target:e.t, w:e.w}));

  const hexR = d => Math.max(18, Math.min(50, Math.sqrt(Math.max(d.rc,1))*1.9+11));

  // PRE-CALCULATE layout — never run tick loop against the DOM
  const sim = d3.forceSimulation(nodes)
    .force('link',      d3.forceLink(links).id(d=>d.id).distance(145).strength(0.18))
    .force('charge',    d3.forceManyBody().strength(-700))
    .force('center',    d3.forceCenter(W/2, H/2))
    .force('collision', d3.forceCollide().radius(d=>hexR(d)+14))
    .stop();
  for(let i=0; i<500; ++i) sim.tick();

  // Render once — DOM touched only after simulation is complete
  g.selectAll('*').remove();

  const linkSel = g.append('g').attr('class','links')
    .selectAll('line').data(links).enter().append('line')
    .attr('class','dom-link')
    .attr('x1',l=>l.source.x).attr('y1',l=>l.source.y)
    .attr('x2',l=>l.target.x).attr('y2',l=>l.target.y)
    .attr('stroke','#122FB1')
    .attr('stroke-opacity', l=>Math.min(0.55, Math.log(l.w+1)/9+0.06))
    .attr('stroke-width',   l=>Math.max(1, Math.min(5, Math.log(l.w+1)/1.8)));

  const nodeGs = g.append('g').attr('class','dom-nodes')
    .selectAll('g').data(nodes).enter().append('g')
    .attr('class','dom-node')
    .attr('transform', d=>'translate('+d.x+','+d.y+')')
    .style('cursor','pointer')
    .on('click', function(e,d){ e.stopPropagation(); renderDomainSPs(d.id); });

  // Hexagon fill
  nodeGs.append('path')
    .attr('d', d=>hexPath(hexR(d)))
    .attr('fill', d=>domColor(d.id)).attr('fill-opacity',0.82)
    .attr('stroke','#122FB1').attr('stroke-width',1.5).attr('stroke-opacity',0.5);

  // Inner lighter hex for canonical domains
  nodeGs.filter(d=>/^D\d+$/.test(d.id)).append('path')
    .attr('d', d=>hexPath(hexR(d)*0.62))
    .attr('fill', d=>domColor(d.id)).attr('fill-opacity',0.5)
    .attr('stroke','rgba(255,255,255,.12)').attr('stroke-width',1);

  // Riesgo equiv badge (yellow dot)
  nodeGs.filter(d=>d.hr>0).append('circle')
    .attr('cx', d=>hexR(d)*0.6).attr('cy', d=>-hexR(d)*0.6)
    .attr('r',5).attr('fill','#F0D224').attr('fill-opacity',0.85);

  nodeGs.append('title')
    .text(d=>d.id+': '+(DOMAINS[d.id]?.name||d.id)+'\n'+
          d.sc+' SPs · '+d.rc.toLocaleString()+' reglas · '+d.hr+' ⚠ riesgo');

  // ID label
  nodeGs.append('text')
    .attr('text-anchor','middle').attr('dy','0.1em')
    .attr('font-size', d=>Math.max(8,Math.min(12,hexR(d)*0.44))+'px')
    .attr('fill','#fff').attr('font-weight','800').attr('pointer-events','none')
    .text(d=>d.id);

  // Name below
  nodeGs.append('text')
    .attr('text-anchor','middle')
    .attr('dy', d=>hexR(d)+13)
    .attr('font-size','8px').attr('fill','#8a9cc4').attr('pointer-events','none')
    .text(d=>DOMAINS[d.id]?.name||d.id);

  // SP count above
  nodeGs.append('text')
    .attr('text-anchor','middle')
    .attr('dy', d=>-hexR(d)-5)
    .attr('font-size','7px').attr('fill','#F0D224').attr('pointer-events','none')
    .text(d=>d.sc+' SPs');

  // Drag — no sim restart, only update dragged node + its direct edges
  nodeGs.call(d3.drag()
    .on('start', function(event, d){
      d.__el = d3.select(this);
    })
    .on('drag', function(event, d){
      d.x = event.x; d.y = event.y;
      d.__el.attr('transform','translate('+d.x+','+d.y+')');
      linkSel.filter(l=>l.source===d||l.target===d)
        .attr('x1',l=>l.source.x).attr('y1',l=>l.source.y)
        .attr('x2',l=>l.target.x).attr('y2',l=>l.target.y);
    })
  );

  // Auto-fit using node positions (trim 5% outliers each side)
  const dxs = nodes.map(d=>d.x).filter(isFinite).sort((a,b)=>a-b);
  const dys = nodes.map(d=>d.y).filter(isFinite).sort((a,b)=>a-b);
  if(dxs.length>0){
    const trim = Math.max(1, Math.floor(dxs.length*0.05));
    const x0=dxs[trim]-70, x1=dxs[dxs.length-1-trim]+70;
    const y0=dys[trim]-70, y1=dys[dys.length-1-trim]+70;
    const w=x1-x0, h=y1-y0;
    if(w>10&&h>10){
      const sc = Math.min(W/w, H/h)*0.9;
      const tx = W/2 - sc*(x0+w/2);
      const ty = H/2 - sc*(y0+h/2);
      svg.call(zoom.transform, d3.zoomIdentity.translate(tx,ty).scale(sc));
    }
  }

  applyDomainFilter();
}

// === SP drill-down view =======================================================
function renderDomainSPs(domId){
  currentDom = domId;

  const backBtn = document.getElementById('back-btn');
  backBtn.style.display = 'flex';

  const domLbl = document.getElementById('dom-label');
  domLbl.textContent = domId+' · '+(DOMAINS[domId]?.name||domId);
  domLbl.style.display = 'block';

  updateDomNav();
  document.getElementById('info-panel').classList.remove('visible');

  const dom = DOMAINS[domId];
  if(!dom) return;

  const topSPs    = dom.sps;
  const domEdData = DOMAIN_SP_EDGES[domId] || {edges:[], sat:[]};
  const satSPs    = domEdData.sat || [];
  satSet          = new Set(satSPs);   // module-level, used by deselectSP
  const allSPs    = [...topSPs, ...satSPs];
  const allSet    = new Set(allSPs);

  // Build raw nodes + links
  const rawNodes = allSPs.map(sp=>{
    const enr = SP_ENRICHED[sp]||{};
    return { id:sp, fi:enr.fi||0, fo:enr.fo||0, loc:enr.loc||0,
             rc:enr.rc||0, tc:enr.tc||'OPERACIONAL', hr:enr.hr||false,
             sat: satSet.has(sp) };
  });
  const rawLinks = (domEdData.edges||[])
    .filter(e=>allSet.has(e.s)&&allSet.has(e.t))
    .map(e=>({source:e.s, target:e.t}));

  // ── Filter isolated nodes: only keep those with ≥1 edge in this view ─────────
  const linkedIds = new Set();
  rawLinks.forEach(l=>{ linkedIds.add(l.source); linkedIds.add(l.target); });
  // Phantom SP = zero on all signals (no edges, no code, no rules anywhere)
  const hasData = d => d.fi>0 || d.fo>0 || d.loc>0 || d.rc>0;
  // Fallback: if very few connected primaries, show primary nodes that have data
  const connPrimary = topSPs.filter(sp=>linkedIds.has(sp)).length;
  const nodes = rawNodes.filter(d=>
    linkedIds.has(d.id) || (!d.sat && connPrimary < 5 && hasData(d))
  );
  const nodeIds = new Set(nodes.map(d=>d.id));
  const links   = rawLinks.filter(l=>nodeIds.has(l.source)&&nodeIds.has(l.target));

  const nodeR = d => d.sat ? 6 : Math.max(9, 9 + Math.min((d.fi||0)/12, 13));

  // PRE-CALCULATE layout — never run tick loop against the DOM
  // forceX/Y pull disconnected subgraphs toward center (forceCenter alone doesn't do this)
  const sim = d3.forceSimulation(nodes)
    .force('link',      d3.forceLink(links).id(d=>d.id).distance(65).strength(0.35))
    .force('charge',    d3.forceManyBody().strength(d=>d.sat ? -80 : -280))
    .force('x',         d3.forceX(W/2).strength(0.05))
    .force('y',         d3.forceY(H/2).strength(0.05))
    .force('collision', d3.forceCollide().radius(d=>nodeR(d)+11))
    .stop();
  for(let i=0; i<500; ++i) sim.tick();

  // Render once — DOM touched only after simulation is complete
  g.selectAll('*').remove();

  const linkSel = g.append('g').attr('class','links')
    .selectAll('line').data(links).enter().append('line')
    .attr('class','sp-link')
    .attr('x1',l=>l.source.x).attr('y1',l=>l.source.y)
    .attr('x2',l=>l.target.x).attr('y2',l=>l.target.y)
    .attr('stroke', l=>{
      const tSat = satSet.has(typeof l.target==='object'?l.target.id:l.target);
      const sSat = satSet.has(typeof l.source==='object'?l.source.id:l.source);
      return (sSat||tSat) ? '#3a6080' : '#4a7fff';
    })
    .attr('stroke-opacity', l=>{
      const tSat = satSet.has(typeof l.target==='object'?l.target.id:l.target);
      const sSat = satSet.has(typeof l.source==='object'?l.source.id:l.source);
      return (sSat||tSat) ? 0.3 : 0.55;
    })
    .attr('stroke-width',1.2);

  const nodeGs = g.append('g').attr('class','sp-nodes')
    .selectAll('g').data(nodes).enter().append('g')
    .attr('class','sp-node')
    .attr('transform', d=>'translate('+d.x+','+d.y+')')
    .style('cursor','pointer')
    .on('click', function(e,d){ e.stopPropagation(); showSPPanel(d.id); });

  nodeGs.append('title')
    .text(d=>d.id+(d.sat?' [satélite]':'')+'\n'+d.rc+' reglas · fi='+d.fi+' · fo='+d.fo+' · LOC='+d.loc);

  // Yellow ring for riesgo equiv (primary only)
  nodeGs.filter(d=>d.hr&&!d.sat).append('circle')
    .attr('r', d=>nodeR(d)+4)
    .attr('fill','none').attr('stroke','#F0D224')
    .attr('stroke-width',2).attr('stroke-opacity',0.8);

  // Main circle — satellites dimmed and gray-blue
  nodeGs.append('circle')
    .attr('r', d=>nodeR(d))
    .attr('fill', d=>d.sat ? '#1e3050' : catColor(d.tc))
    .attr('fill-opacity', d=>d.sat ? 0.5 : 0.88)
    .attr('stroke', d=>d.sat ? '#3a5070' : catColor(d.tc))
    .attr('stroke-width',1.5).attr('stroke-opacity',0.5);

  // Rule count dot for high-rule primary SPs
  nodeGs.filter(d=>d.rc>20&&!d.sat).append('circle')
    .attr('cx', d=>nodeR(d)*0.65).attr('cy', d=>-nodeR(d)*0.65)
    .attr('r',4).attr('fill','#F0D224').attr('opacity',0.75);

  // ── Labels: full name, no truncation ─────────────────────────────────────────
  nodeGs.filter(d=>!d.sat).append('text')
    .attr('y', d=>nodeR(d)+12)
    .attr('text-anchor','middle')
    .attr('font-size','8px')
    .attr('fill','#c8ddf0')
    .attr('pointer-events','none')
    .attr('paint-order','stroke')
    .attr('stroke','#060d1f').attr('stroke-width','3.5px')
    .text(d=>d.id.replace(/^sp_/,''));

  // Satellite label (full name, slightly dimmer)
  nodeGs.filter(d=>d.sat).append('text')
    .attr('y', d=>nodeR(d)+10)
    .attr('text-anchor','middle')
    .attr('font-size','7px')
    .attr('fill','#5a7a9a')
    .attr('pointer-events','none')
    .attr('paint-order','stroke')
    .attr('stroke','#060d1f').attr('stroke-width','3px')
    .text(d=>d.id.replace(/^sp_/,''));

  // Drag — no sim restart, only update dragged node + its direct edges
  nodeGs.call(d3.drag()
    .on('start', function(event, d){
      d.__el = d3.select(this);
    })
    .on('drag', function(event, d){
      d.x = event.x; d.y = event.y;
      d.__el.attr('transform','translate('+d.x+','+d.y+')');
      linkSel.filter(l=>l.source===d||l.target===d)
        .attr('x1',l=>l.source.x).attr('y1',l=>l.source.y)
        .attr('x2',l=>l.target.x).attr('y2',l=>l.target.y);
    })
  );

  // Auto-fit based on actual node positions (ignores text overflow artifacts)
  const xs = nodes.map(d=>d.x).filter(isFinite);
  const ys = nodes.map(d=>d.y).filter(isFinite);
  if(xs.length>0){
    const pad = 80;
    const x0=Math.min(...xs)-pad, x1=Math.max(...xs)+pad;
    const y0=Math.min(...ys)-pad, y1=Math.max(...ys)+pad;
    const w=x1-x0, h=y1-y0;
    if(w>10&&h>10){
      const sc = Math.min(W/w, H/h)*0.88;
      const tx = W/2 - sc*(x0+w/2);
      const ty = H/2 - sc*(y0+h/2);
      svg.call(zoom.transform, d3.zoomIdentity.translate(tx,ty).scale(sc));
    }
  }

  applySpFilter();
}

// === Legend ===================================================================
// Inject a small floating legend into the canvas
(function buildLegend(){
  const cats = Object.entries(CAT_META);
  let h = '<div style="position:absolute;bottom:8px;left:8px;background:rgba(10,21,53,.88);'+
    'border:1px solid rgba(18,47,177,.4);border-radius:6px;padding:6px 10px;'+
    'font-size:8px;z-index:10;pointer-events:none;max-width:140px">';
  h += '<div style="font-size:7px;text-transform:uppercase;letter-spacing:.05em;'+
    'color:#8a9cc4;margin-bottom:4px">Categoría (color nodo)</div>';
  cats.forEach(([cat,m])=>{
    h += '<div style="display:flex;align-items:center;gap:4px;margin:2px 0">'+
      '<span style="width:8px;height:8px;border-radius:50%;background:'+m.col+';flex-shrink:0"></span>'+
      '<span style="color:#a0b4d0">'+m.lbl+'</span></div>';
  });
  h += '<div style="margin-top:4px;padding-top:4px;border-top:1px solid rgba(18,47,177,.3)">'+
    '<span style="display:inline-flex;align-items:center;gap:3px;color:#e6ca40;font-size:8px">'+
    '<span style="width:10px;height:10px;border-radius:50%;border:2px solid #F0D224;display:inline-block"></span>'+
    ' ⚠ riesgo equiv.</span></div></div>';
  canvasWrap.insertAdjacentHTML('beforeend', h);
})();

// === Init =====================================================================
buildDomNav();
renderDomains();
</script></body></html>"""

HTML = (HTML
        .replace("__LOGO__",        LOGO_B64)
        .replace("__SP_ENRICHED__",  J_ENRICHED)
        .replace("__SP_RULES__",     J_RULES)
        .replace("__VOCAB_MEAN__",   J_VOCAB)
        .replace("__DOMAINS__",      J_DOMAINS)
        .replace("__DOMAIN_EDGES__", J_DEDGES)
        .replace("__DOMAIN_SP_EDGES__", J_SPEDGES)
        .replace("__TILE_META__",    J_TILE))

out_path = BASE + "portal/component-map-bcop-v2.html"
open(out_path, "w", encoding="utf-8").write(HTML)

n_with_rules = len(SP_ENRICHED)
print(f"component-map-bcop-v2.html escrito · {len(CG_NODES)} SPs enriquecidos · {n_with_rules} con reglas")

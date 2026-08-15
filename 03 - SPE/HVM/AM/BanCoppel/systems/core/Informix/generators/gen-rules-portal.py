#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen-rules-portal.py — Portal de reglas de negocio Informix v3.

Genera:
  · portal/data/rules-portal-data.json  (~1.2 MB — slim display data)
  · portal/rules-catalog-bcop.html      (~20 KB — HTML shell con fetch)

Arquitectura:
  - HTML carga rules-portal-data.json vía fetch() al servidor local
  - Paginación 100 grupos/página
  - Reglas con mismo business_name → un grupo colapsable con sus variantes
  - Filtros: búsqueda libre · tipo · dominio · regulador · riesgo equivalencia
  - Fila expandible: code SPL + explicacion + vocab_refs + norma

SPE-AM-001 · DT-Reglas v1.4.0 · Layer A+
"""
import json, os, base64, io, sys
from collections import Counter
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = str(
    __import__("pathlib").Path(__file__).resolve().parent.parent
) + "/"

# ── Logo ──────────────────────────────────────────────────────────────────────
with open(BASE + "portal/bancoppel-logo.png", "rb") as _f:
    LOGO_B64 = base64.b64encode(_f.read()).decode()

# ── Load v3 rules ─────────────────────────────────────────────────────────────
v3 = json.load(open(BASE + "portal/data/business-rules-v3.json", encoding="utf-8"))
rules = v3["rules"]

# brain.db es la fuente autoritativa de business_name (síntesis LLM source_read).
# Se sobrepone a v3.json para que el portal SIEMPRE refleje los nombres del cerebro,
# aunque enrich-rules-v3 haya regenerado v3.json con business_name vacío.
import sqlite3 as _sqlite
_brain = BASE + "digital-brain/brain.db"
try:
    _con = _sqlite.connect(_brain)
    _bn = {rid: name for rid, name in _con.execute(
        "SELECT id, business_name FROM rules WHERE business_name IS NOT NULL AND business_name != ''")}
    _con.close()
    _overlaid = 0
    for _r in rules:
        _n = _bn.get(_r.get("id"))
        if _n and _n != _r.get("business_name", ""):
            _r["business_name"] = _n
            _overlaid += 1
    print(f"brain.db overlay: {_overlaid} business_name autoritativos desde el cerebro")
except Exception as _e:
    print(f"brain.db overlay omitido ({_e}) — usando business_name de v3.json")

RIESGO_KEYS = {"360": "360", "365": "365", "TRUNC": "TRUNC", "ROUND": "ROUND",
               "MONEY": "MONEY", "DIV": "DIV", "IVA": "IVA", "DBACCESS": "DBACCESS"}

def reg_codes(reg_field):
    codes = []
    for item in (reg_field or []):
        if isinstance(item, list) and item:
            codes.append(item[0])
        elif isinstance(item, str) and item:
            codes.append(item)
    return list(dict.fromkeys(codes))

def reg_norma(reg_field):
    for item in (reg_field or []):
        if isinstance(item, list) and len(item) >= 2:
            return item[1]
    return ""

def _normalize_riesgo(field):
    """Normaliza riesgo a lista de strings (maneja lista real o string-repr legacy)."""
    import ast
    if field is None:
        return []
    if isinstance(field, list):
        return field
    s = str(field).strip()
    if s.startswith("["):
        try:
            return ast.literal_eval(s)
        except (ValueError, SyntaxError):
            pass
    return [s] if s else []

def riesgo_tags(riesgo_field):
    tags = []
    for rv in _normalize_riesgo(riesgo_field):
        if not isinstance(rv, str):
            continue
        for k in RIESGO_KEYS:
            if k in rv and k not in tags:
                tags.append(k)
    return tags

# ── Build slim portal data ────────────────────────────────────────────────────
slim_rules = []
for r in rules:
    slim_rules.append({
        "i":  r["id"],
        "n":  r.get("business_name", ""),
        "t":  r.get("tipo", ""),
        "s":  r.get("sp", "").split(":")[-1] if ":" in r.get("sp","") else r.get("sp",""),
        "db": r.get("db", ""),
        "ln": r.get("line", 0),
        "d":  r.get("dominio", ""),
        "r":  reg_codes(r.get("reg", [])),
        "rn": reg_norma(r.get("reg", [])),
        "k":  riesgo_tags(r.get("riesgo", [])),
        "e":  (r.get("explicacion", "") or "")[:180],
        "ex": (r.get("expl_negocio", "") or "")[:130],
        "c":  (r.get("code", "") or "")[:220],
        "he": (r.get("human_expr", "") or "")[:280],
        "vr": r.get("vocab_refs", [])[:6],
        "bc": r.get("bc_name", "") or r.get("bc", ""),
        "cl": r.get("clase", "NEGOCIO"),
    })

# ── Group IDs — reglas con mismo business_name forman un grupo ────────────────
_name_count = Counter(r['n'] for r in slim_rules)
_name_to_gi: dict = {}
_gi_ctr = 0
for r in slim_rules:
    nm = r['n']
    if nm not in _name_to_gi:
        _name_to_gi[nm] = _gi_ctr
        _gi_ctr += 1
    r['gi'] = _name_to_gi[nm]   # group id (mismo nombre → mismo gi)
    r['gc'] = _name_count[nm]   # cuántas reglas comparten este nombre

# ── Stats for meta ────────────────────────────────────────────────────────────
by_tipo = Counter(r["t"] for r in slim_rules)
by_clase = Counter(r["cl"] for r in slim_rules)
all_doms = sorted({r["d"] for r in slim_rules if r["d"]})
all_regs = ["CNBV","SAT","CONDUSEF","IPAB","Banxico","TESOFE"]
reg_counts = {reg: sum(1 for r in slim_rules if reg in r["r"]) for reg in all_regs}
n_riesgo = sum(1 for r in slim_rules if r["k"])
n_negocio = by_clase.get("NEGOCIO", 0)
n_groups = len(_name_to_gi)

portal_data = {
    "meta": {
        "total":     len(slim_rules),
        "n_negocio": n_negocio,
        "n_groups":  n_groups,
        "by_tipo":   dict(by_tipo),
        "by_clase":  dict(by_clase),
        "domains":   all_doms,
        "regs":      {k: v for k, v in reg_counts.items() if v > 0},
        "n_riesgo":  n_riesgo,
    },
    "rules": slim_rules,
}

out_data = BASE + "portal/data/rules-portal-data.json"
json.dump(portal_data, open(out_data, "w", encoding="utf-8"), ensure_ascii=False, separators=(",",":"))
print(f"Portal data: {out_data}  ({os.path.getsize(out_data):,} bytes, {len(slim_rules):,} rules, {n_groups:,} grupos)")

# ── Generate HTML ─────────────────────────────────────────────────────────────
M = portal_data["meta"]

# Valores derivados (pre-calculados para evitar {{}} anidado en el f-string HTML)
_bc = M.get("by_clase", {})
N_NEGOCIO   = M.get("n_negocio", M["total"])
N_NONEG     = M["total"] - N_NEGOCIO
N_FORM_NEG  = M["by_tipo"].get("FÓRMULA", 0) - _bc.get("INFRAESTRUCTURA", 0) \
              - _bc.get("ENSAMBLAJE_REPORTE", 0) - _bc.get("PRESENTACION", 0)
CL_NEG   = _bc.get("NEGOCIO", 0)
CL_INFRA = _bc.get("INFRAESTRUCTURA", 0)
CL_ENS   = _bc.get("ENSAMBLAJE_REPORTE", 0)
CL_PRES  = _bc.get("PRESENTACION", 0)

REG_COLOR = {
    "CNBV":     ("rgba(37,99,235,.15)",  "#93c5fd"),
    "SAT":      ("rgba(234,179,8,.15)",  "#fde047"),
    "CONDUSEF": ("rgba(168,85,247,.15)", "#d8b4fe"),
    "IPAB":     ("rgba(239,68,68,.15)",  "#fca5a5"),
    "Banxico":  ("rgba(34,197,94,.15)",  "#86efac"),
    "TESOFE":   ("rgba(148,163,184,.15)","#94a3b8"),
}

def reg_chip_css():
    css = ""
    for reg, (bg, col) in REG_COLOR.items():
        css += f'.rc-{reg}{{background:{bg};color:{col};border-color:{col}40;}}\n'
    return css

html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Reglas de Negocio</title>
<style>
:root{{
  --blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --bg:#060a1a;--bg2:#0a1535;--panel:#0e1e45;
  --brand:#122FB1;--acc:#F0D224;--txt:#EAEDF7;
  --line:rgba(38,49,124,.5);
}}
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{height:100%}}
body{{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}}

/* Hero */
.hero{{position:relative;overflow:hidden;background:linear-gradient(135deg,#040c1e 0%,#061a4a 40%,#0a2170 65%,#061a4a 100%);flex-shrink:0}}
.hero-grid{{position:absolute;inset:0;background-image:linear-gradient(rgba(61,95,205,.12) 1px,transparent 1px),linear-gradient(90deg,rgba(61,95,205,.12) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.6) 30%,rgba(0,0,0,.4) 70%,transparent)}}
.hero-glow{{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(61,95,205,.35) 0%,transparent 70%);pointer-events:none}}
.hero-bar{{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(255,255,255,.06)}}
.hero-bar img{{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}}
.hero-bar .sep{{width:1px;height:28px;background:rgba(255,255,255,.15)}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--yellow);font-style:normal}}
.hero-bar .badge{{font-size:9px;font-weight:800;letter-spacing:.1em;color:#060a1a;background:var(--yellow);padding:2px 8px;border-radius:20px}}
.hero-bar .sp{{flex:1}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);transition:.2s;text-decoration:none}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
.hero-body{{position:relative;z-index:1;padding:20px 28px 24px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}}
.hero-title{{flex:1;min-width:240px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:8px}}
.hero-h1{{font-size:clamp(22px,4vw,34px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(200,220,255,.7));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.hero-sub{{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:640px}}
.hero-stats{{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}}
.stat-block{{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:12px;padding:12px 18px;min-width:88px;position:relative;overflow:hidden}}
.stat-block::before{{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.04),transparent)}}
.stat-block .sn{{font-size:26px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--yellow),#f6e27a);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;line-height:1}}
.stat-block .sl{{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}}
.stat-block.blue .sn{{background:linear-gradient(135deg,#93c5fd,#6f8ce6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.stat-block.red .sn{{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}

/* Toolbar */
#fbar{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:20;box-shadow:0 2px 12px rgba(0,0,0,.4);flex-shrink:0}}
#q{{background:var(--panel);border:1px solid rgba(61,95,205,.5);border-radius:7px;
  color:var(--txt);padding:5px 10px;font-size:12px;width:200px;outline:none;
  transition:.2s border-color}}
#q:focus{{border-color:var(--acc)}}
.sep{{width:1px;height:18px;background:rgba(255,255,255,.08);flex-shrink:0}}
.pill{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;
  user-select:none;border:1px solid rgba(61,95,205,.35);color:#a0b4e0;
  background:rgba(61,95,205,.1);transition:all .15s;white-space:nowrap}}
.pill:hover{{border-color:var(--blue);color:var(--txt)}}
.pill.on{{border-color:var(--acc)!important;color:var(--acc);background:rgba(240,210,36,.08)!important}}
.pill.cl-pill{{border-color:rgba(120,200,160,.35);color:#8fd4b0;background:rgba(80,180,130,.08)}}
.pill.cl-pill:hover{{border-color:#5cc98f;color:#c7f0dd}}
.pill.cl-pill.on{{border-color:#4dd598!important;color:#4dd598!important;background:rgba(77,213,152,.12)!important}}
.pill .cnt{{font-size:8px;opacity:.7;margin-left:3px}}
#dom-sel{{background:var(--panel);border:1px solid rgba(61,95,205,.45);border-radius:7px;
  color:var(--txt);padding:4px 8px;font-size:11px;outline:none;cursor:pointer}}
#dom-sel option{{background:#0a1535}}
.rc{{border-radius:4px;padding:2px 7px;font-size:9px;font-weight:700;cursor:pointer;
  user-select:none;border:1px solid;transition:.15s;white-space:nowrap}}
{reg_chip_css()}
.pill-risk{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;
  user-select:none;border:1px solid rgba(248,113,113,.35);color:#fca5a5;
  background:rgba(239,68,68,.08);transition:all .15s;white-space:nowrap}}
.pill-risk.on{{border-color:#f87171;color:#f87171;background:rgba(239,68,68,.15)}}
#info{{margin-left:auto;font-size:9.5px;color:var(--muted);white-space:nowrap}}

/* Table */
#tbl-wrap{{flex:1;overflow-y:auto;padding:0 24px 16px;min-height:0}}
table{{width:100%;border-collapse:collapse;font-size:12px;table-layout:fixed}}
thead th{{position:sticky;top:0;background:var(--bg2);text-align:left;padding:6px 8px;
  font-size:8.5px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);
  border-bottom:1px solid var(--line);z-index:5;white-space:nowrap;cursor:pointer;user-select:none}}
thead th:hover{{color:var(--txt)}}
thead th.sort-asc::after{{content:" ↑"}}
thead th.sort-desc::after{{content:" ↓"}}
col.c-id{{width:100px}}col.c-name{{width:auto}}col.c-expr{{width:200px}}col.c-tipo{{width:88px}}
col.c-dom{{width:150px}}col.c-reg{{width:120px}}col.c-risk{{width:36px}}
tbody td{{padding:5px 8px;border-bottom:1px solid rgba(38,49,124,.35);vertical-align:middle}}
tbody tr.data-row{{cursor:pointer;transition:background .12s}}
tbody tr.data-row:hover{{background:rgba(61,95,205,.12)}}
tbody tr.data-row.open{{background:rgba(61,95,205,.18)}}
tbody tr.detail-row td{{padding:0;border-bottom:1px solid rgba(61,95,205,.4)}}

/* Grouped rows */
tbody tr.group-hdr{{cursor:pointer;transition:background .12s}}
tbody tr.group-hdr:hover{{background:rgba(61,95,205,.12)}}
tbody tr.group-hdr.exp{{background:rgba(61,95,205,.08)}}
tbody tr.sub-row{{cursor:pointer;display:none;transition:background .12s}}
tbody tr.sub-row.vis{{display:table-row;background:rgba(0,0,0,.2)}}
tbody tr.sub-row.vis:hover{{background:rgba(61,95,205,.1)}}
tbody tr.sub-row.vis.open{{background:rgba(61,95,205,.16)}}
.gc-badge{{font-size:8px;font-weight:800;background:rgba(240,210,36,.1);color:#f0d224;
  border:1px solid rgba(240,210,36,.3);border-radius:10px;padding:1px 7px;
  margin-left:8px;vertical-align:middle;white-space:nowrap}}
.grp-arrow{{display:inline-block;font-size:9px;color:var(--muted);
  transition:transform .15s;transform-origin:50% 50%;margin-right:4px;vertical-align:middle}}
tr.exp .grp-arrow{{transform:rotate(90deg)}}
.sub-id{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#4a5a8a;
  padding-left:16px;white-space:nowrap;display:block}}
.sub-sp-lbl{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#6a7aaa}}

/* Cell styles */
.c-id-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#5a6a9a;white-space:nowrap}}
.c-name-val{{font-size:12px;color:var(--txt);font-weight:500;line-height:1.3}}
.c-sp-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#8090c0;display:block;margin-top:2px}}
.c-expl-val{{font-size:10px;color:#93a0c8;line-height:1.35;margin-top:3px;font-style:italic;max-width:99%}}
.c-expr-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#8aabe0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:196px;display:block;line-height:1.4}}
.tp{{display:inline-block;font-size:8.5px;font-weight:800;padding:2px 6px;border-radius:3px;white-space:nowrap;letter-spacing:.04em}}
.tp-F{{background:#052e16;color:#6ee7b7}}.tp-V{{background:#1e3a5f;color:#93c5fd}}
.tp-U{{background:#431407;color:#fdba74}}.tp-E{{background:#0a2a2a;color:#5eead4}}
.dom-val{{font-size:10px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.reg-cell{{display:flex;gap:3px;flex-wrap:wrap;align-items:center}}
.rc-inline{{border-radius:3px;padding:1px 5px;font-size:8px;font-weight:700;border:1px solid;white-space:nowrap}}
.risk-cell{{text-align:center}}
.risk-icon{{font-size:12px;cursor:default}}

/* Detail row */
.det{{padding:10px 14px 12px;background:rgba(6,10,26,.5);border-top:1px solid rgba(61,95,205,.3)}}
.det-sp{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#7090c8;margin-bottom:6px}}
.det-expl{{font-size:11px;color:#bcc8f0;margin-bottom:8px;line-height:1.5}}
.det-code{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px;color:#a8b8e0;
  background:rgba(0,0,0,.35);border:1px solid rgba(61,95,205,.3);border-radius:6px;
  padding:8px 12px;white-space:pre-wrap;word-break:break-all;margin-bottom:8px;line-height:1.6}}
.det-risk{{margin-bottom:6px}}
.det-risk-item{{display:inline-block;font-size:9px;color:#fca5a5;background:rgba(239,68,68,.1);
  border:1px solid rgba(248,113,113,.3);border-radius:4px;padding:2px 8px;margin:2px 2px 2px 0}}
.det-norma{{font-size:10px;color:#8896c8;font-style:italic;line-height:1.4;margin-bottom:6px}}
.det-vr{{display:flex;gap:4px;flex-wrap:wrap}}
.vr-tag{{font-size:9px;background:rgba(61,95,205,.18);border:1px solid rgba(61,95,205,.35);
  border-radius:3px;padding:1px 6px;color:#a0b4f0}}

/* Pagination */
#pgbar{{display:flex;align-items:center;gap:8px;padding:8px 24px;border-top:1px solid var(--line);
  flex-shrink:0;background:rgba(6,10,26,.6)}}
#pgbar .pginfo{{font-size:10px;color:var(--muted)}}
.pgbtn{{background:var(--panel);border:1px solid rgba(61,95,205,.4);border-radius:5px;
  color:var(--muted);padding:4px 12px;font-size:11px;cursor:pointer;transition:.15s}}
.pgbtn:hover:not(:disabled){{border-color:var(--blue);color:var(--txt)}}
.pgbtn:disabled{{opacity:.35;cursor:default}}
#pgbar .pgsp{{flex:1}}

/* Loading */
#loading{{display:none;align-items:center;justify-content:center;flex:1;flex-direction:column;gap:12px}}
#loading .spin{{width:36px;height:36px;border:3px solid rgba(61,95,205,.3);border-top-color:#93c5fd;
  border-radius:50%;animation:spin .7s linear infinite}}
@keyframes spin{{to{{transform:rotate(360deg)}}}}
#loading .lt{{font-size:12px;color:var(--muted)}}
#err-msg{{display:none;align-items:center;justify-content:center;flex:1;color:#fca5a5;font-size:12px}}
/* Tooltip oscuro (reemplaza el title= nativo del SO que se veía como caja blanca) */
#tip{{position:fixed;z-index:9999;max-width:600px;pointer-events:none;display:none;
  background:#0d1526;color:#e2e9f7;border:1px solid rgba(120,150,220,.4);border-radius:7px;
  padding:8px 12px;font-family:'Cascadia Code','Consolas',monospace;font-size:11px;
  line-height:1.55;white-space:pre-wrap;word-break:break-word;box-shadow:0 12px 34px rgba(0,0,0,.6)}}
</style>
</head>
<body>
<div class="hero">
  <div class="hero-grid"></div>
  <div class="hero-glow"></div>
  <div class="hero-bar">
    <img src="data:image/png;base64,{LOGO_B64}" alt="BanCoppel">
    <div class="sep"></div>
    <span class="crumb">SPE-AM-001 <em>›</em> Reglas de Negocio</span>
    <span class="sp"></span>
    <a class="back" href="index-bcop-v2.html">← Inicio</a>
  </div>
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">Informix · DT-Reglas v1.6.0</div>
      <h1 class="hero-h1">Reglas de Negocio</h1>
      <div class="hero-sub">{M["total"]:,} reglas de negocio destiladas de los stored procedures del core BanCoppel en IBM Informix IDS 14.10.<br>La lógica que gobierna cada cálculo, validación y umbral — inferida del código y hecha legible.</div>
    </div>
    <div class="hero-stats">
      <div class="stat-block"><div class="sn" id="h-total">{N_NEGOCIO:,}</div><div class="sl">Reglas de negocio</div></div>
      <div class="stat-block"><div class="sn">{M["n_groups"]:,}</div><div class="sl">Nombres únicos</div></div>
      <div class="stat-block blue"><div class="sn">{N_FORM_NEG:,}</div><div class="sl">Fórmulas</div></div>
      <div class="stat-block blue"><div class="sn">{M["by_tipo"].get("VALIDACIÓN",0):,}</div><div class="sl">Validaciones</div></div>
      <div class="stat-block blue"><div class="sn">{M["by_tipo"].get("UMBRAL",0):,}</div><div class="sl">Umbrales</div></div>
      <div class="stat-block red"><div class="sn">{M["n_riesgo"]:,}</div><div class="sl">Riesgo equiv.</div></div>
      <div class="stat-block" style="opacity:.72"><div class="sn" style="background:linear-gradient(135deg,#9aa4bf,#c7cede);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text">{N_NONEG:,}</div><div class="sl">Ensamblaje/infra</div></div>
    </div>
  </div>
</div>

<div id="fbar">
  <input id="q" type="search" placeholder="&#128269; buscar nombre, SP, regulador…" autocomplete="off">
  <div class="sep"></div>
  <span class="pill on" data-f="tipo" data-v="">Todos</span>
  <span class="pill" data-f="tipo" data-v="FÓRMULA">Fórmula<span class="cnt">{M["by_tipo"].get("FÓRMULA",0):,}</span></span>
  <span class="pill" data-f="tipo" data-v="VALIDACIÓN">Validación<span class="cnt">{M["by_tipo"].get("VALIDACIÓN",0):,}</span></span>
  <span class="pill" data-f="tipo" data-v="UMBRAL">Umbral<span class="cnt">{M["by_tipo"].get("UMBRAL",0):,}</span></span>
  <span class="pill" data-f="tipo" data-v="ESTADO">Estado<span class="cnt">{M["by_tipo"].get("ESTADO",0):,}</span></span>
  <div class="sep"></div>
  <span class="pill cl-pill on" data-f="clase" data-v="">Toda naturaleza</span>
  <span class="pill cl-pill" data-f="clase" data-v="NEGOCIO">Negocio<span class="cnt">{CL_NEG:,}</span></span>
  <span class="pill cl-pill" data-f="clase" data-v="INFRAESTRUCTURA" title="Shell, dbaccess, paths AIX — plumbing, no negocio">Infra<span class="cnt">{CL_INFRA:,}</span></span>
  <span class="pill cl-pill" data-f="clase" data-v="ENSAMBLAJE_REPORTE" title="Construcción de SQL dinámico para reportes">Ensamblaje<span class="cnt">{CL_ENS:,}</span></span>
  <span class="pill cl-pill" data-f="clase" data-v="PRESENTACION" title="Formato de strings, padding, mensajes">Presentación<span class="cnt">{CL_PRES:,}</span></span>
  <div class="sep"></div>
  <select id="dom-sel"><option value="">Todos los dominios</option></select>
  <div class="sep"></div>
  {"".join(f'<span class="rc rc-{r}" data-reg="{r}">{r} <span class="cnt">{c:,}</span></span>' for r,c in M["regs"].items() if c > 0)}
  <div class="sep"></div>
  <span class="pill-risk" id="btn-risk">⚠ Riesgo equiv.</span>
  <span id="info">cargando…</span>
</div>

<div id="loading" style="display:flex"><div class="spin"></div><div class="lt">Cargando reglas…</div></div>
<div id="err-msg"></div>

<div id="tbl-wrap" style="display:none">
  <table id="tbl">
    <colgroup><col class="c-id"><col class="c-name"><col class="c-expr"><col class="c-tipo"><col class="c-dom"><col class="c-reg"><col class="c-risk"></colgroup>
    <thead>
      <tr>
        <th data-col="i">ID / Variantes</th>
        <th data-col="n">Nombre de negocio</th>
        <th data-col="e">Expresión / Condición</th>
        <th data-col="t">Tipo</th>
        <th data-col="d">Dominio</th>
        <th>Regulador</th>
        <th title="Riesgo de equivalencia">⚠</th>
      </tr>
    </thead>
    <tbody id="tbody"></tbody>
  </table>
</div>

<div id="pgbar" style="display:none">
  <button class="pgbtn" id="pg-prev">&#8592; Ant.</button>
  <span class="pginfo" id="pginfo"></span>
  <span class="pgsp"></span>
  <button class="pgbtn" id="pg-next">Sig. &#8594;</button>
</div>

<script>
const PAGE = 100;
let ALL = [], filteredGroups = [], expandedGroups = new Set();
let page = 0, openId = null;
let fTipo='', fClase='', fDom='', fReg='', fRisk=false, fQ='', sortCol='n', sortDir=1;

const REG_COLORS = {{
  CNBV:     ['rgba(37,99,235,.15)','#93c5fd'],
  SAT:      ['rgba(234,179,8,.15)','#fde047'],
  CONDUSEF: ['rgba(168,85,247,.15)','#d8b4fe'],
  IPAB:     ['rgba(239,68,68,.15)','#fca5a5'],
  Banxico:  ['rgba(34,197,94,.15)','#86efac'],
  TESOFE:   ['rgba(148,163,184,.15)','#94a3b8'],
}};
const TIPO_MAP = {{'FÓRMULA':'F','VALIDACIÓN':'V','UMBRAL':'U','ESTADO':'E'}};

function esc(s){{
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}}
function regChip(code){{
  const [bg,col] = REG_COLORS[code]||['rgba(100,100,100,.15)','#aaa'];
  return `<span class="rc-inline" style="background:${{bg}};color:${{col}};border-color:${{col}}40">${{esc(code)}}</span>`;
}}
function tipoBadge(t){{
  const k = TIPO_MAP[t]||'?';
  const short = {{F:'FOR',V:'VAL',U:'UMB',E:'EST'}}[k]||k;
  return `<span class="tp tp-${{k}}">${{esc(short)}}</span>`;
}}
function riskIcon(keys){{
  if(!keys||!keys.length) return '';
  return `<span class="risk-icon" data-tip="${{esc(keys.join(' · '))}}">⚠</span>`;
}}
function domShort(d){{
  if(!d) return '';
  const m = d.match(/^(D\\d+)/);
  return m ? m[1] : d.split(' ')[0];
}}
function domLabel(d){{
  if(!d) return '—';
  return d.replace(/^D\\d+\\s*/,'');
}}
function exprShort(e){{
  if(!e) return '';
  const s = e.replace(/\\s+/g,' ').trim();
  return s.length > 80 ? s.slice(0,80)+'…' : s;
}}

// ── Rendering ─────────────────────────────────────────────────────────────────

function renderDetail(r){{
  let html = `<tr class="detail-row"><td colspan="7"><div class="det">`;
  html += `<div class="det-sp">${{esc(r.db)}}:${{esc(r.s)}} &nbsp;·&nbsp; línea ${{r.ln||'?'}}</div>`;
  if(r.rn) html += `<div class="det-norma">${{esc(r.rn)}}</div>`;
  if(r.e)  html += `<div class="det-expl">${{esc(r.e)}}</div>`;
  if(r.he && r.he !== r.c) {{
    html += `<div class="det-code det-expr-human">${{esc(r.he)}}</div>`;
    html += `<div class="det-code det-code-raw" style="opacity:.55;font-size:.8em;margin-top:2px">${{esc(r.c)}}</div>`;
  }} else if(r.c) {{
    html += `<div class="det-code">${{esc(r.c)}}</div>`;
  }}
  if(r.k&&r.k.length){{
    html += '<div class="det-risk">';
    r.k.forEach(k=>{{html+=`<span class="det-risk-item">⚠ ${{esc(k)}}</span>`}});
    html += '</div>';
  }}
  if(r.vr&&r.vr.length){{
    html += '<div class="det-vr">';
    r.vr.forEach(v=>{{html+=`<span class="vr-tag">${{esc(v)}}</span>`}});
    html += '</div>';
  }}
  html += '</div></td></tr>';
  return html;
}}

// Single-rule row (gc == 1 after filtering)
function renderSingleRow(r){{
  return `<tr class="data-row${{openId===r.i?' open':''}}" data-id="${{esc(r.i)}}">
    <td><span class="c-id-val">${{esc(r.i)}}</span></td>
    <td>
      <div class="c-name-val">${{esc(r.n||'—')}}</div>
      ${{r.ex?`<div class="c-expl-val">${{esc(r.ex)}}</div>`:''}}
      <span class="c-sp-val">${{esc(r.s)}}</span>
    </td>
    <td data-tip="${{esc(r.he||r.c||'')}}"><span class="c-expr-val">${{esc(exprShort(r.he||r.c))}}</span></td>
    <td>${{tipoBadge(r.t)}}</td>
    <td class="dom-val" data-tip="${{esc(r.d)}}">${{esc(domShort(r.d))}} ${{esc(domLabel(r.d))}}</td>
    <td><div class="reg-cell">${{(r.r||[]).map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{riskIcon(r.k)}}</td>
  </tr>`;
}}

// Group header row (gc > 1)
function renderGroupHeader(grp){{
  const r0 = grp[0];
  const gi = r0.gi;
  const isExp = expandedGroups.has(gi);
  const allRegs = [...new Set(grp.flatMap(r=>(r.r||[])))];
  const hasRisk = grp.some(r=>r.k&&r.k.length);
  return `<tr class="group-hdr${{isExp?' exp':''}}" data-gi="${{gi}}">
    <td><span class="c-id-val"><span class="grp-arrow">▶</span></span></td>
    <td>
      <div class="c-name-val">${{esc(r0.n||'—')}}<span class="gc-badge">${{grp.length}} variantes</span></div>
      ${{r0.ex?`<div class="c-expl-val">${{esc(r0.ex)}}</div>`:''}}
    </td>
    <td data-tip="${{esc(r0.he||r0.c||'')}}"><span class="c-expr-val">${{esc(exprShort(r0.he||r0.c))}}</span></td>
    <td></td>
    <td class="dom-val" data-tip="${{esc(r0.d)}}">${{esc(domShort(r0.d))}} ${{esc(domLabel(r0.d))}}</td>
    <td><div class="reg-cell">${{allRegs.map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{hasRisk?'<span class="risk-icon">⚠</span>':''}}</td>
  </tr>`;
}}

// Sub-row within a group
function renderSubRow(r, gi){{
  const isVis = expandedGroups.has(gi);
  const isDet = isVis && openId===r.i;
  let html = `<tr class="sub-row${{isVis?' vis':''}}${{isDet?' open':''}}" data-id="${{esc(r.i)}}" data-gi="${{gi}}">
    <td><span class="sub-id">${{esc(r.i)}}</span></td>
    <td><span class="sub-sp-lbl">${{esc(r.s)}}</span></td>
    <td data-tip="${{esc(r.he||r.c||'')}}"><span class="c-expr-val">${{esc(exprShort(r.he||r.c))}}</span></td>
    <td>${{tipoBadge(r.t)}}</td>
    <td></td>
    <td><div class="reg-cell">${{(r.r||[]).map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{riskIcon(r.k)}}</td>
  </tr>`;
  if(isDet) html += renderDetail(r);
  return html;
}}

// ── Build groups from filtered rules ──────────────────────────────────────────
function buildGroups(rules){{
  const gmap = new Map();
  rules.forEach(r=>{{
    if(!gmap.has(r.gi)) gmap.set(r.gi,[]);
    gmap.get(r.gi).push(r);
  }});
  return [...gmap.values()];
}}

// ── Filter + group + sort ─────────────────────────────────────────────────────
function applyFilters(){{
  const q = fQ.toLowerCase().trim();
  const matched = ALL.filter(r=>{{
    if(fTipo && r.t !== fTipo) return false;
    if(fClase && (r.cl||'NEGOCIO') !== fClase) return false;
    if(fDom  && r.d !== fDom)  return false;
    if(fReg  && !(r.r||[]).includes(fReg)) return false;
    if(fRisk && !(r.k&&r.k.length)) return false;
    if(q){{
      const hay = ((r.n||'')+(r.s||'')+(r.e||'')+(r.r||[]).join('')).toLowerCase();
      if(!hay.includes(q)) return false;
    }}
    return true;
  }});

  filteredGroups = buildGroups(matched);
  filteredGroups.sort((ga,gb)=>{{
    let av=ga[0][sortCol]||'', bv=gb[0][sortCol]||'';
    if(Array.isArray(av)) av=av[0]||'';
    if(Array.isArray(bv)) bv=bv[0]||'';
    return sortDir*String(av).localeCompare(String(bv),'es');
  }});
  page=0; openId=null;
  renderPage();
}}

function renderPage(){{
  const start=page*PAGE, end=Math.min(start+PAGE,filteredGroups.length);
  const slice=filteredGroups.slice(start,end);
  let html='';
  slice.forEach(grp=>{{
    if(grp.length===1){{
      const r=grp[0];
      html+=renderSingleRow(r);
      if(openId===r.i) html+=renderDetail(r);
    }} else {{
      html+=renderGroupHeader(grp);
      grp.forEach(r=>{{ html+=renderSubRow(r,grp[0].gi); }});
    }}
  }});
  document.getElementById('tbody').innerHTML=html;
  const totalG=filteredGroups.length;
  const totalR=filteredGroups.reduce((s,g)=>s+g.length,0);
  const pages=Math.max(1,Math.ceil(totalG/PAGE));
  document.getElementById('info').textContent=
    `${{totalR.toLocaleString('es-MX')}} reglas · ${{totalG.toLocaleString('es-MX')}} nombres`;
  document.getElementById('pginfo').textContent=
    `Página ${{page+1}} / ${{pages}}  (nombres ${{start+1}}–${{end}} de ${{totalG.toLocaleString('es-MX')}})`;
  document.getElementById('pg-prev').disabled=page<=0;
  document.getElementById('pg-next').disabled=page>=pages-1;
}}

function init(data){{
  ALL=data.rules;
  const sel=document.getElementById('dom-sel');
  data.meta.domains.forEach(d=>{{
    const o=document.createElement('option');
    o.value=d; o.textContent=d;
    sel.appendChild(o);
  }});
  applyFilters();
  document.getElementById('loading').style.display='none';
  document.getElementById('tbl-wrap').style.display='';
  document.getElementById('pgbar').style.display='';
}}

// ── Events ────────────────────────────────────────────────────────────────────
let qTimer;
document.getElementById('q').addEventListener('input',e=>{{
  clearTimeout(qTimer);
  qTimer=setTimeout(()=>{{fQ=e.target.value; applyFilters();}},180);
}});

document.querySelectorAll('.pill[data-f="tipo"]').forEach(p=>{{
  p.addEventListener('click',()=>{{
    document.querySelectorAll('.pill[data-f="tipo"]').forEach(x=>x.classList.remove('on'));
    p.classList.add('on');
    fTipo=p.dataset.v; applyFilters();
  }});
}});

document.querySelectorAll('.pill[data-f="clase"]').forEach(p=>{{
  p.addEventListener('click',()=>{{
    document.querySelectorAll('.pill[data-f="clase"]').forEach(x=>x.classList.remove('on'));
    p.classList.add('on');
    fClase=p.dataset.v; applyFilters();
  }});
}});

document.getElementById('dom-sel').addEventListener('change',e=>{{
  fDom=e.target.value; applyFilters();
}});

document.querySelectorAll('.rc[data-reg]').forEach(c=>{{
  c.addEventListener('click',()=>{{
    const reg=c.dataset.reg;
    if(fReg===reg){{fReg=''; c.style.opacity='';}}
    else{{
      document.querySelectorAll('.rc[data-reg]').forEach(x=>x.style.opacity='0.45');
      c.style.opacity=''; fReg=reg;
    }}
    applyFilters();
  }});
}});

document.getElementById('btn-risk').addEventListener('click',()=>{{
  fRisk=!fRisk;
  document.getElementById('btn-risk').classList.toggle('on',fRisk);
  applyFilters();
}});

document.querySelectorAll('thead th[data-col]').forEach(th=>{{
  th.addEventListener('click',()=>{{
    const col=th.dataset.col;
    if(sortCol===col) sortDir*=-1;
    else{{sortCol=col; sortDir=1;}}
    document.querySelectorAll('thead th').forEach(h=>h.classList.remove('sort-asc','sort-desc'));
    th.classList.add(sortDir===1?'sort-asc':'sort-desc');
    applyFilters();
  }});
}});

document.getElementById('tbody').addEventListener('click',e=>{{
  // Group header → expand/collapse
  const hdr=e.target.closest('tr.group-hdr');
  if(hdr){{
    const gi=parseInt(hdr.dataset.gi);
    if(expandedGroups.has(gi)){{ expandedGroups.delete(gi); openId=null; }}
    else expandedGroups.add(gi);
    renderPage(); return;
  }}
  // Sub-row → toggle detail
  const sub=e.target.closest('tr.sub-row');
  if(sub){{
    const id=sub.dataset.id;
    openId=(openId===id)?null:id;
    renderPage(); return;
  }}
  // Single-rule row → toggle detail
  const row=e.target.closest('tr.data-row');
  if(row){{
    const id=row.dataset.id;
    openId=(openId===id)?null:id;
    renderPage(); return;
  }}
}});

document.getElementById('pg-prev').addEventListener('click',()=>{{page--; openId=null; renderPage();}});
document.getElementById('pg-next').addEventListener('click',()=>{{page++; openId=null; renderPage();}});

// ── Fetch data ────────────────────────────────────────────────────────────────
fetch('data/rules-portal-data.json')
  .then(r=>{{if(!r.ok) throw new Error(r.status+' '+r.statusText); return r.json();}})
  .then(init)
  .catch(err=>{{
    document.getElementById('loading').style.display='none';
    const errDiv=document.getElementById('err-msg');
    errDiv.style.display='flex';
    errDiv.textContent='Error cargando datos: '+err.message+' — asegúrate de servir desde http://localhost:8080';
  }});

// ── Tooltip oscuro (delegación; sustituye title= nativo) ───────────────────────
// Se crea por JS para garantizar que exista al registrar los handlers.
const _tip=document.createElement('div'); _tip.id='tip'; document.body.appendChild(_tip);
document.addEventListener('mouseover',e=>{{
  const el=e.target.closest('[data-tip]');
  if(!el) return;
  const txt=el.getAttribute('data-tip');
  if(!txt){{_tip.style.display='none';return;}}
  _tip.textContent=txt; _tip.style.display='block';
}});
document.addEventListener('mousemove',e=>{{
  if(_tip.style.display!=='block') return;
  const pad=14; let x=e.clientX+pad, y=e.clientY+pad;
  const r=_tip.getBoundingClientRect();
  if(x+r.width>innerWidth-8) x=e.clientX-r.width-pad;
  if(y+r.height>innerHeight-8) y=e.clientY-r.height-pad;
  _tip.style.left=Math.max(6,x)+'px'; _tip.style.top=Math.max(6,y)+'px';
}});
document.addEventListener('mouseout',e=>{{
  if(e.target.closest('[data-tip]')) _tip.style.display='none';
}});
</script>
</body>
</html>"""

out_html = BASE + "portal/rules-catalog-bcop.html"
open(out_html, "w", encoding="utf-8").write(html)
print(f"HTML:         {out_html}  ({os.path.getsize(out_html):,} bytes)")
print(f"\nDone. Open: http://localhost:8080/portal/rules-catalog-bcop.html")

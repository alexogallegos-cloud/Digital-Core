#!/usr/bin/env python3
"""
Liverpool — Rules Catalog HTML Generator
-----------------------------------------
Reads  portal/data/rules-bronze-liv.json
Output portal/rules-catalog-liv.html

Formato: idéntico a BanCoppel rules-catalog-bcop.html
         con paleta Liverpool (cerise #E00198 · sky #87C3D3 · rose #DA7AB0).
Datos:   embebidos como const JS (169 reglas — no requiere fetch).
"""
import json, re
from pathlib import Path
from datetime import date

HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRC_J = BRAIN / "portal" / "data" / "rules-bronze-liv.json"
OUT   = BRAIN / "portal" / "rules-catalog-liv.html"

# ── Load Bronze data ──────────────────────────────────────────────────────────
raw   = json.loads(SRC_J.read_text(encoding="utf-8"))
rules = raw["rules"]
meta  = raw["meta"]

n_total   = meta["total"]
n_formula = meta["by_tipo"].get("FÓRMULA", 0)
n_valid   = meta["by_tipo"].get("VALIDACIÓN", 0)
n_umbral  = meta["by_tipo"].get("UMBRAL", 0)
n_estado  = meta["by_tipo"].get("ESTADO", 0)
n_reg     = sum(1 for r in rules if r["reg"])
n_riesgo  = sum(1 for r in rules if r["riesgo"])

# Domain labels
DOM_LABELS = {
    "R01": "R01 Gestión Comercial",
    "R02": "R02 Clientes y Lealtad",
    "R03": "R03 Servicios Financieros",
    "R04": "R04 Cadena de Suministro",
    "R05": "R05 Canales Digitales",
    "R06": "R06 Operaciones de Tienda",
    "R07": "R07 Finanzas y Contabilidad",
    "R08": "R08 Recursos Humanos",
    "R09": "R09 Analítica",
    "R10": "R10 Infraestructura",
}

# Build compact portal payload (follows BanCoppel schema keys)
portal_rules = []
for r in rules:
    dom_full = DOM_LABELS.get(r["dom_code"], r["dom_code"] + " " + r["dominio"])
    portal_rules.append({
        "i":  r["id"],
        "t":  r["tipo"],
        "c":  r["code"],
        "s":  r["prog"],
        "ln": r["line"],
        "d":  dom_full,
        "r":  [reg for reg, _ in r["reg"]],
        "rn": "; ".join(norma for _, norma in r["reg"]),
        "k":  r["riesgo"],
        "vr": r["vocab_refs"],
        "cl": r.get("clase", ""),
        "n":  r.get("business_name", ""),
        "gi": r["prog"],       # group by program
    })

# Domains present
domains_present = sorted({r["d"] for r in portal_rules})

# Regulatory counts
reg_counts: dict[str, int] = {}
for r in portal_rules:
    for reg in r["r"]:
        reg_counts[reg] = reg_counts.get(reg, 0) + 1

# Program counts
prog_counts: dict[str, int] = {}
for r in portal_rules:
    prog_counts[r["s"]] = prog_counts.get(r["s"], 0) + 1

generated = str(date.today())

data_js = json.dumps(
    {"meta": {"total": n_total, "domains": domains_present}, "rules": portal_rules},
    ensure_ascii=False, separators=(",", ":"),
)

# ── Regulatory chip definitions ───────────────────────────────────────────────
REG_DEF = {
    "SAT":      ("rgba(234,179,8,.15)",  "#fde047"),
    "Banxico":  ("rgba(34,197,94,.15)",  "#86efac"),
    "BMV":      ("rgba(96,165,250,.15)", "#93c5fd"),
    "CONDUSEF": ("rgba(168,85,247,.15)", "#d8b4fe"),
    "IMSS":     ("rgba(34,211,238,.15)", "#67e8f9"),
}

def rc_css(reg):
    bg, col = REG_DEF.get(reg, ("rgba(100,100,100,.15)", "#aaa"))
    return f".rc-{reg}{{background:{bg};color:{col};border-color:{col}40;}}"

rc_pills_html = "".join(
    f'<span class="rc rc-{reg}" data-reg="{reg}">'
    f'{reg} <span class="cnt">{cnt}</span></span>'
    for reg, cnt in sorted(reg_counts.items(), key=lambda x: -x[1])
)

tipo_counts = {}
for r in portal_rules:
    tipo_counts[r["t"]] = tipo_counts.get(r["t"], 0) + 1

HTML = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Liverpool · Reglas de Negocio — Módulo Importaciones</title>
<style>
:root{{
  --pink:#E00198;--sky:#87C3D3;--rose:#DA7AB0;
  --ink:#FFF0F8;--muted:#c09ab8;--muted2:#9070a0;
  --bg:#0d0408;--bg2:#130610;--panel:#1a0814;
  --brand:#E00198;--acc:#87C3D3;--txt:#f0e6ef;
  --line:rgba(224,1,152,.18);
}}
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{height:100%}}
body{{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}}

/* Hero */
.hero{{position:relative;overflow:hidden;background:linear-gradient(135deg,#0d0408 0%,#200412 40%,#360820 65%,#200412 100%);flex-shrink:0}}
.hero-grid{{position:absolute;inset:0;background-image:linear-gradient(rgba(224,1,152,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(224,1,152,.10) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.5) 30%,rgba(0,0,0,.3) 70%,transparent)}}
.hero-glow{{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(224,1,152,.28) 0%,transparent 70%);pointer-events:none}}
.hero-bar{{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(224,1,152,.12)}}
.hero-logo{{height:30px;width:auto;flex-shrink:0}}
.hero-bar .sep{{width:1px;height:28px;background:rgba(255,255,255,.12)}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--sky);font-style:normal}}
.hero-bar .badge{{font-size:9px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);padding:2px 8px;border-radius:20px}}
.hero-bar .sp{{flex:1}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);transition:.2s;text-decoration:none}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
.hero-body{{position:relative;z-index:1;padding:20px 28px 24px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}}
.hero-title{{flex:1;min-width:240px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--sky);margin-bottom:8px}}
.hero-h1{{font-size:clamp(22px,4vw,34px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(224,1,152,.8));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.hero-sub{{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:640px}}
.hero-stats{{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}}
.stat-block{{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:12px 18px;min-width:88px;position:relative;overflow:hidden}}
.stat-block::before{{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.04),transparent)}}
.stat-block .sn{{font-size:26px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--sky),#b8e0ea);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;line-height:1}}
.stat-block .sl{{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}}
.stat-block.pink .sn{{background:linear-gradient(135deg,var(--pink),var(--rose));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.stat-block.red .sn{{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}

/* Toolbar */
#fbar{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:20;box-shadow:0 2px 12px rgba(0,0,0,.4);flex-shrink:0}}
#q{{background:var(--panel);border:1px solid rgba(224,1,152,.4);border-radius:7px;color:var(--txt);padding:5px 10px;font-size:12px;width:200px;outline:none;transition:.2s border-color}}
#q:focus{{border-color:var(--sky)}}
.sep{{width:1px;height:18px;background:rgba(255,255,255,.08);flex-shrink:0}}
.pill{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(224,1,152,.25);color:var(--muted);background:rgba(224,1,152,.06);transition:all .15s;white-space:nowrap}}
.pill:hover{{border-color:var(--pink);color:var(--txt)}}
.pill.on{{border-color:var(--sky)!important;color:var(--sky);background:rgba(135,195,211,.10)!important}}
.pill .cnt{{font-size:8px;opacity:.7;margin-left:3px}}
#dom-sel{{background:var(--panel);border:1px solid rgba(224,1,152,.35);border-radius:7px;color:var(--txt);padding:4px 8px;font-size:11px;outline:none;cursor:pointer}}
#dom-sel option{{background:#130610}}
.rc{{border-radius:4px;padding:2px 7px;font-size:9px;font-weight:700;cursor:pointer;user-select:none;border:1px solid;transition:.15s;white-space:nowrap}}
{chr(10).join(rc_css(reg) for reg in REG_DEF)}
.pill-risk{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(248,113,113,.35);color:#fca5a5;background:rgba(239,68,68,.08);transition:all .15s;white-space:nowrap}}
.pill-risk.on{{border-color:#f87171;color:#f87171;background:rgba(239,68,68,.15)}}
#info{{margin-left:auto;font-size:9.5px;color:var(--muted);white-space:nowrap}}

/* Table */
#tbl-wrap{{flex:1;overflow-y:auto;padding:0 24px 16px;min-height:0}}
table{{width:100%;border-collapse:collapse;font-size:12px;table-layout:fixed}}
thead th{{position:sticky;top:0;background:var(--bg2);text-align:left;padding:6px 8px;font-size:8.5px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);border-bottom:1px solid var(--line);z-index:5;white-space:nowrap;cursor:pointer;user-select:none}}
thead th:hover{{color:var(--txt)}}
thead th.sort-asc::after{{content:" ↑"}}
thead th.sort-desc::after{{content:" ↓"}}
col.c-id{{width:100px}}col.c-name{{width:250px}}col.c-code{{width:auto}}col.c-tipo{{width:66px}}
col.c-dom{{width:170px}}col.c-reg{{width:120px}}col.c-risk{{width:30px}}
tbody td{{padding:5px 8px;border-bottom:1px solid rgba(224,1,152,.12);vertical-align:middle}}
tbody tr.data-row{{cursor:pointer;transition:background .12s}}
tbody tr.data-row:hover{{background:rgba(224,1,152,.08)}}
tbody tr.data-row.open{{background:rgba(224,1,152,.14)}}
tbody tr.detail-row td{{padding:0;border-bottom:1px solid rgba(224,1,152,.2)}}

/* Grouped rows */
tbody tr.group-hdr{{cursor:pointer;transition:background .12s}}
tbody tr.group-hdr:hover{{background:rgba(224,1,152,.08)}}
tbody tr.group-hdr.exp{{background:rgba(224,1,152,.06)}}
tbody tr.sub-row{{cursor:pointer;display:none;transition:background .12s}}
tbody tr.sub-row.vis{{display:table-row;background:rgba(0,0,0,.2)}}
tbody tr.sub-row.vis:hover{{background:rgba(224,1,152,.07)}}
tbody tr.sub-row.vis.open{{background:rgba(224,1,152,.13)}}
.gc-badge{{font-size:8px;font-weight:800;background:rgba(135,195,211,.12);color:var(--sky);border:1px solid rgba(135,195,211,.3);border-radius:10px;padding:1px 7px;margin-left:8px;vertical-align:middle;white-space:nowrap}}
.grp-arrow{{display:inline-block;font-size:9px;color:var(--muted);transition:transform .15s;transform-origin:50% 50%;margin-right:4px;vertical-align:middle}}
tr.exp .grp-arrow{{transform:rotate(90deg)}}
.sub-id{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#6a3055;padding-left:16px;white-space:nowrap;display:block}}

/* Cell styles */
.c-id-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#7a3070;white-space:nowrap}}
.c-code-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#c8b0c8;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:100%;display:block;line-height:1.4}}
.c-prog-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:var(--sky);display:block}}
.c-name-val{{font-size:11.5px;color:var(--ink);font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;display:block}}
.c-name-src{{font-size:8px;color:#6a3a6a;font-style:italic}}
.c-line-val{{font-size:9px;color:var(--muted2);margin-left:4px}}
.dom-val{{font-size:10px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.reg-cell{{display:flex;gap:3px;flex-wrap:wrap;align-items:center}}
.rc-inline{{border-radius:3px;padding:1px 5px;font-size:8px;font-weight:700;border:1px solid;white-space:nowrap}}
.risk-cell{{text-align:center}}
.risk-icon{{font-size:12px;cursor:default}}
.tp{{display:inline-block;font-size:8.5px;font-weight:800;padding:2px 6px;border-radius:3px;white-space:nowrap;letter-spacing:.04em}}
.tp-F{{background:#0a2614;color:#6ee7b7}}
.tp-V{{background:#1f0a1a;color:var(--rose)}}
.tp-U{{background:#1a1000;color:#fde68a}}
.tp-E{{background:#031018;color:var(--sky)}}

/* Detail row */
.det{{padding:10px 14px 12px;background:rgba(13,4,8,.6);border-top:1px solid rgba(224,1,152,.2)}}
.det-name{{font-size:14px;font-weight:700;color:var(--ink);margin-bottom:4px}}
.det-name-src{{font-size:9px;font-weight:400;color:#6a3a6a;font-style:italic}}
.det-sp{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:var(--rose);margin-bottom:6px}}
.det-code{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px;color:#d4b8d4;background:rgba(0,0,0,.4);border:1px solid rgba(224,1,152,.2);border-radius:6px;padding:8px 12px;white-space:pre-wrap;word-break:break-all;margin-bottom:8px;line-height:1.6}}
.det-risk{{margin-bottom:6px}}
.det-risk-item{{display:inline-block;font-size:9px;color:#fca5a5;background:rgba(239,68,68,.10);border:1px solid rgba(248,113,113,.3);border-radius:4px;padding:2px 8px;margin:2px 2px 2px 0}}
.det-norma{{font-size:10px;color:var(--muted2);font-style:italic;line-height:1.4;margin-bottom:6px}}
.det-vr{{display:flex;gap:4px;flex-wrap:wrap}}
.vr-tag{{font-size:9px;background:rgba(224,1,152,.12);border:1px solid rgba(224,1,152,.3);border-radius:3px;padding:1px 6px;color:var(--rose)}}

/* Pagination */
#pgbar{{display:flex;align-items:center;gap:8px;padding:8px 24px;border-top:1px solid var(--line);flex-shrink:0;background:rgba(13,4,8,.7)}}
#pgbar .pginfo{{font-size:10px;color:var(--muted)}}
.pgbtn{{background:var(--panel);border:1px solid rgba(224,1,152,.3);border-radius:5px;color:var(--muted);padding:4px 12px;font-size:11px;cursor:pointer;transition:.15s}}
.pgbtn:hover:not(:disabled){{border-color:var(--pink);color:var(--txt)}}
.pgbtn:disabled{{opacity:.35;cursor:default}}
#pgbar .pgsp{{flex:1}}

/* Loading */
#loading{{display:none;align-items:center;justify-content:center;flex:1;flex-direction:column;gap:12px}}
#loading .spin{{width:36px;height:36px;border:3px solid rgba(224,1,152,.2);border-top-color:var(--pink);border-radius:50%;animation:spin .7s linear infinite}}
@keyframes spin{{to{{transform:rotate(360deg)}}}}
#loading .lt{{font-size:12px;color:var(--muted)}}

/* Tooltip */
#tip{{position:fixed;z-index:9999;max-width:600px;pointer-events:none;display:none;background:#0d0408;color:#e2d0df;border:1px solid rgba(224,1,152,.3);border-radius:7px;padding:8px 12px;font-family:'Cascadia Code','Consolas',monospace;font-size:11px;line-height:1.55;white-space:pre-wrap;word-break:break-word;box-shadow:0 12px 34px rgba(0,0,0,.6)}}
</style>
</head>
<body>

<div class="hero">
  <div class="hero-grid"></div>
  <div class="hero-glow"></div>
  <div class="hero-bar">
    <img class="hero-logo" src="Liverpool_logo.png" alt="Liverpool">

    <div class="sep"></div>
    <span class="crumb">SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Reglas de Negocio</span>
    <span class="sp"></span>
    <span class="badge">Bronze Layer</span>
    <a class="back" href="index.html">← Inicio</a>
  </div>
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">Liverpool · SAP ABAP · Módulo Importaciones ZIM/ZRT</div>
      <h1 class="hero-h1">Reglas de Negocio</h1>
      <div class="hero-sub">{n_total} reglas extraídas de 12 programas ABAP del Módulo de Importaciones Liverpool.<br>
        Lógica de pedimentos SAP, cálculos arancelarios, validaciones de estado y umbrales de negocio — inferidas del código y presentadas como conocimiento navegable.</div>
    </div>
    <div class="hero-stats">
      <div class="stat-block"><div class="sn">{n_total}</div><div class="sl">Reglas totales</div></div>
      <div class="stat-block pink"><div class="sn">{n_formula}</div><div class="sl">Fórmulas</div></div>
      <div class="stat-block pink"><div class="sn">{n_valid}</div><div class="sl">Validaciones</div></div>
      <div class="stat-block pink"><div class="sn">{n_umbral}</div><div class="sl">Umbrales</div></div>
      <div class="stat-block red"><div class="sn">{n_riesgo}</div><div class="sl">Riesgo equiv.</div></div>
      <div class="stat-block"><div class="sn">{n_reg}</div><div class="sl">Con regulación</div></div>
    </div>
  </div>
</div>

<div id="fbar">
  <input id="q" type="search" placeholder="🔍 buscar código, programa, regulador…" autocomplete="off">
  <div class="sep"></div>
  <span class="pill on" data-f="tipo" data-v="">Todos</span>
  <span class="pill" data-f="tipo" data-v="FÓRMULA">Fórmula<span class="cnt">{n_formula}</span></span>
  <span class="pill" data-f="tipo" data-v="VALIDACIÓN">Validación<span class="cnt">{n_valid}</span></span>
  <span class="pill" data-f="tipo" data-v="UMBRAL">Umbral<span class="cnt">{n_umbral}</span></span>
  <span class="pill" data-f="tipo" data-v="ESTADO">Estado<span class="cnt">{n_estado}</span></span>
  <div class="sep"></div>
  <select id="dom-sel"><option value="">Todos los dominios</option></select>
  <div class="sep"></div>
  {rc_pills_html}
  <div class="sep"></div>
  <span class="pill-risk" id="btn-risk">⚠ Riesgo equiv.</span>
  <span id="info">cargando…</span>
</div>

<div id="loading" style="display:flex"><div class="spin"></div><div class="lt">Cargando reglas…</div></div>

<div id="tbl-wrap" style="display:none">
  <table id="tbl">
    <colgroup><col class="c-id"><col class="c-name"><col class="c-code"><col class="c-tipo"><col class="c-dom"><col class="c-reg"><col class="c-risk"></colgroup>
    <thead>
      <tr>
        <th data-col="i">ID</th>
        <th data-col="n">Nombre de negocio</th>
        <th data-col="c">Expresión / Condición ABAP</th>
        <th data-col="t">Tipo</th>
        <th data-col="d">Dominio</th>
        <th>Regulación</th>
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
let fTipo='', fDom='', fReg='', fRisk=false, fQ='', sortCol='s', sortDir=1;

const REG_COLORS = {{
  SAT:      ['rgba(234,179,8,.15)','#fde047'],
  Banxico:  ['rgba(34,197,94,.15)','#86efac'],
  BMV:      ['rgba(96,165,250,.15)','#93c5fd'],
  CONDUSEF: ['rgba(168,85,247,.15)','#d8b4fe'],
  IMSS:     ['rgba(34,211,238,.15)','#67e8f9'],
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
  return `<span class="risk-icon" data-tip="${{esc(keys.join(' | '))}}">⚠</span>`;
}}
function codeShort(e){{
  if(!e) return '';
  const s = e.replace(/\\s+/g,' ').trim();
  return s.length > 90 ? s.slice(0,90)+'…' : s;
}}
function domShort(d){{
  if(!d) return '';
  const m = d.match(/^(R\\d+)/);
  return m ? m[1] : d.split(' ')[0];
}}

// ── Detail panel ──────────────────────────────────────────────────────────────
function renderDetail(r){{
  let html = `<tr class="detail-row"><td colspan="7"><div class="det">`;
  if(r.n) html += `<div class="det-name">${{esc(r.n)}} <span class="det-name-src">· nombre inferido (Bronze)</span></div>`;
  html += `<div class="det-sp">${{esc(r.s)}} &nbsp;·&nbsp; línea ${{r.ln||'?'}}</div>`;
  if(r.rn) html += `<div class="det-norma">${{esc(r.rn)}}</div>`;
  html += `<div class="det-code">${{esc(r.c||'')}}</div>`;
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

// ── Single row ────────────────────────────────────────────────────────────────
function renderSingleRow(r){{
  return `<tr class="data-row${{openId===r.i?' open':''}}" data-id="${{esc(r.i)}}">
    <td><span class="c-id-val">${{esc(r.i)}}</span></td>
    <td><span class="c-name-val" data-tip="${{esc(r.n||'')}}">${{esc(r.n||'—')}}</span></td>
    <td data-tip="${{esc(r.c||'')}}"><span class="c-code-val">${{esc(codeShort(r.c))}}</span></td>
    <td>${{tipoBadge(r.t)}}</td>
    <td class="dom-val" data-tip="${{esc(r.d)}}">${{esc(domShort(r.d))}} <span style="color:#6a3a6a;font-size:9px">${{esc(r.d.replace(/^R\\d+\\s*/,''))}}</span></td>
    <td><div class="reg-cell">${{(r.r||[]).map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{riskIcon(r.k)}}</td>
  </tr>`;
}}

// ── Group header ──────────────────────────────────────────────────────────────
function renderGroupHeader(grp){{
  const r0 = grp[0];
  const gi = r0.gi;
  const isExp = expandedGroups.has(gi);
  const allRegs = [...new Set(grp.flatMap(r=>(r.r||[])))];
  const hasRisk = grp.some(r=>r.k&&r.k.length);
  const tipos   = [...new Set(grp.map(r=>r.t))].map(tipoBadge).join(' ');
  return `<tr class="group-hdr${{isExp?' exp':''}}" data-gi="${{esc(gi)}}">
    <td><span class="c-id-val"><span class="grp-arrow">▶</span></span></td>
    <td colspan="2"><span class="c-prog-val" style="display:inline">${{esc(r0.s)}}</span><span class="gc-badge">${{grp.length}} reglas</span></td>
    <td>${{tipos}}</td>
    <td class="dom-val" data-tip="${{esc(r0.d)}}">${{esc(domShort(r0.d))}} <span style="color:#6a3a6a;font-size:9px">${{esc(r0.d.replace(/^R\\d+\\s*/,''))}}</span></td>
    <td><div class="reg-cell">${{allRegs.map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{hasRisk?'<span class="risk-icon">⚠</span>':''}}</td>
  </tr>`;
}}

// ── Sub-row ───────────────────────────────────────────────────────────────────
function renderSubRow(r, gi){{
  const isVis = expandedGroups.has(gi);
  const isDet = isVis && openId===r.i;
  let html = `<tr class="sub-row${{isVis?' vis':''}}${{isDet?' open':''}}" data-id="${{esc(r.i)}}" data-gi="${{esc(gi)}}">
    <td><span class="sub-id">${{esc(r.i)}}<span class="c-line-val">L${{r.ln||'?'}}</span></span></td>
    <td><span class="c-name-val" data-tip="${{esc(r.n||'')}}">${{esc(r.n||'—')}}</span></td>
    <td data-tip="${{esc(r.c||'')}}"><span class="c-code-val">${{esc(codeShort(r.c))}}</span></td>
    <td>${{tipoBadge(r.t)}}</td>
    <td></td>
    <td><div class="reg-cell">${{(r.r||[]).map(regChip).join('')}}</div></td>
    <td class="risk-cell">${{riskIcon(r.k)}}</td>
  </tr>`;
  if(isDet) html += renderDetail(r);
  return html;
}}

// ── Group + filter ────────────────────────────────────────────────────────────
function buildGroups(rules){{
  const gmap = new Map();
  rules.forEach(r=>{{
    if(!gmap.has(r.gi)) gmap.set(r.gi,[]);
    gmap.get(r.gi).push(r);
  }});
  return [...gmap.values()];
}}

function applyFilters(){{
  const q = fQ.toLowerCase().trim();
  const matched = ALL.filter(r=>{{
    if(fTipo && r.t !== fTipo) return false;
    if(fDom  && r.d !== fDom)  return false;
    if(fReg  && !(r.r||[]).includes(fReg)) return false;
    if(fRisk && !(r.k&&r.k.length)) return false;
    if(q){{
      const hay = ((r.n||'')+(r.c||'')+(r.s||'')+(r.r||[]).join('')+(r.vr||[]).join('')).toLowerCase();
      if(!hay.includes(q)) return false;
    }}
    return true;
  }});
  filteredGroups = buildGroups(matched);
  filteredGroups.sort((ga,gb)=>{{
    let av=ga[0][sortCol]||'', bv=gb[0][sortCol]||'';
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
    `${{totalR.toLocaleString('es-MX')}} reglas · ${{totalG.toLocaleString('es-MX')}} programas`;
  document.getElementById('pginfo').textContent=
    `Página ${{page+1}} / ${{pages}}  (programas ${{start+1}}–${{end}} de ${{totalG.toLocaleString('es-MX')}})`;
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
  const hdr=e.target.closest('tr.group-hdr');
  if(hdr){{
    const gi=hdr.dataset.gi;
    if(expandedGroups.has(gi)){{ expandedGroups.delete(gi); openId=null; }}
    else expandedGroups.add(gi);
    renderPage(); return;
  }}
  const sub=e.target.closest('tr.sub-row');
  if(sub){{
    const id=sub.dataset.id;
    openId=(openId===id)?null:id;
    renderPage(); return;
  }}
  const row=e.target.closest('tr.data-row');
  if(row){{
    const id=row.dataset.id;
    openId=(openId===id)?null:id;
    renderPage(); return;
  }}
}});

document.getElementById('pg-prev').addEventListener('click',()=>{{page--; openId=null; renderPage();}});
document.getElementById('pg-next').addEventListener('click',()=>{{page++; openId=null; renderPage();}});

// ── Tooltip ───────────────────────────────────────────────────────────────────
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

// ── Load embedded data ────────────────────────────────────────────────────────
const RULES_DATA = {data_js};
init(RULES_DATA);
</script>
</body>
</html>"""

OUT.write_text(HTML, encoding="utf-8")
size_kb = round(OUT.stat().st_size / 1024, 1)
print(f"Generated {OUT}")
print(f"  {n_total} rules  |  {size_kb} KB  |  {len(prog_counts)} programs  |  {n_reg} with reg")

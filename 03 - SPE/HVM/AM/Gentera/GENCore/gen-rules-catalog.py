#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen-rules-catalog.py — Portal de reglas de negocio GENCore · Paleta Accenture.

Genera: portal/rules-catalog.html  (HTML standalone, datos embebidos)

Fuente de ejemplo: portal/data/rules-portal-data.json de BCOPCore
(datos de Informix SPL como volumen representativo hasta que GENCore
 tenga su propio corpus completo — reemplazar RULES_F cuando esté listo)

GENCore · SPE-AM-002 · Gemelo Cognitivo
"""
import json, os, sys, io, base64
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# ── Rutas ──────────────────────────────────────────────────────────────────────
GEN_BASE  = Path(__file__).parent
BCOP_BASE = (GEN_BASE.parents[1]                              # Application Modernization/
             / "BanCoppel" / "systems" / "core" / "Informix" / "portal" / "data")
RULES_F   = BCOP_BASE / "rules-portal-data.json"             # slim ya procesado
OUT_F     = GEN_BASE / "portal" / "rules-catalog.html"
LOGO_F    = (Path(r"c:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Solutioning")
             / "Design - Studio" / "logos" / "Accenture_logo_white_letters.png")

if not RULES_F.exists():
    print(f"WARN: no se encontró {RULES_F}")
    print("      Corre primero: python BCOPCore/generators/gen-rules-portal.py")
    sys.exit(1)

portal    = json.loads(RULES_F.read_text(encoding='utf-8'))
LOGO_B64  = base64.b64encode(LOGO_F.read_bytes()).decode() if LOGO_F.exists() else ""
LOGO_URI  = f"data:image/png;base64,{LOGO_B64}" if LOGO_B64 else ""
M      = portal["meta"]
rules  = portal["rules"]

DATA_JSON = json.dumps(portal, ensure_ascii=False, separators=(',', ':'))

# ── Paleta Accenture ───────────────────────────────────────────────────────────
# --ac:#A100FF (signal) · --dk:#1C0032 (anchor dark)
# Hero: dark radial Accenture gradient

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

tipo_pills = ""
for t, cnt in sorted(M["by_tipo"].items(), key=lambda x: -x[1]):
    short = {"FÓRMULA":"Fórmula","VALIDACIÓN":"Validación","UMBRAL":"Umbral","ESTADO":"Estado"}.get(t, t)
    tipo_pills += (
        f'<span class="pill" data-f="tipo" data-v="{t}">'
        f'{short}<span class="cnt">{cnt:,}</span></span>\n  '
    )

reg_chips = " ".join(
    f'<span class="rc rc-{r}" data-reg="{r}">{r} <span class="cnt">{c:,}</span></span>'
    for r, c in M["regs"].items() if c > 0
)

html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>GENCore · Catálogo de Reglas de Negocio · Accenture</title>
<style>
:root{{
  --ac:#A100FF;--dk:#1C0032;
  --txt:#F0EBF8;--muted:#9B8AB5;--muted2:#6D5090;
  --bg:#0A0118;--bg2:#10022A;--panel:#18052E;
  --line:rgba(161,0,255,.28);
}}
*{{box-sizing:border-box;margin:0;padding:0}}
html,body{{height:100%}}
body{{background:var(--bg);color:var(--txt);font-family:'Segoe UI',Calibri,Arial,sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}}

/* ── Hero ─────────────────────────────────────────────────────────────────── */
.hero{{position:relative;overflow:hidden;background:linear-gradient(135deg,#050010 0%,#1c0032 40%,#2a005a 60%,#1c0032 100%);flex-shrink:0}}
.hero-grid{{position:absolute;inset:0;background-image:linear-gradient(rgba(161,0,255,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(161,0,255,.10) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.6) 30%,rgba(0,0,0,.4) 70%,transparent)}}
.hero-glow{{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(161,0,255,.28) 0%,transparent 70%);pointer-events:none}}
.hero-bar{{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(255,255,255,.06)}}
.hero-logo{{height:24px;object-fit:contain;flex-shrink:0}}
.hero-bar .sep{{width:1px;height:28px;background:rgba(255,255,255,.15)}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--ac);font-style:normal}}
.hero-bar .badge{{font-size:9px;font-weight:800;letter-spacing:.1em;color:#fff;background:var(--ac);padding:2px 8px;border-radius:20px}}
.hero-bar .sp{{flex:1}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);transition:.2s;text-decoration:none}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
.hero-body{{position:relative;z-index:1;padding:20px 28px 24px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}}
.hero-title{{flex:1;min-width:240px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--ac);margin-bottom:8px}}
.hero-h1{{font-size:clamp(22px,4vw,34px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(200,160,255,.7));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.hero-sub{{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:640px}}
.hero-stats{{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}}
.stat-block{{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:12px;padding:12px 18px;min-width:88px;position:relative;overflow:hidden}}
.stat-block::before{{content:'';position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.04),transparent)}}
.stat-block .sn{{font-size:26px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--ac),#c84fff);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;line-height:1}}
.stat-block .sl{{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}}
.stat-block.pu .sn{{background:linear-gradient(135deg,#c084fc,#a855f7);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}
.stat-block.or .sn{{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}}

/* ── Toolbar ─────────────────────────────────────────────────────────────── */
#fbar{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:20;box-shadow:0 2px 12px rgba(0,0,0,.4);flex-shrink:0}}
#q{{background:var(--panel);border:1px solid rgba(161,0,255,.4);border-radius:7px;color:var(--txt);padding:5px 10px;font-size:12px;width:200px;outline:none;transition:.2s border-color}}
#q:focus{{border-color:var(--ac)}}
.fsep{{width:1px;height:18px;background:rgba(255,255,255,.08);flex-shrink:0}}
.pill{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(161,0,255,.28);color:var(--muted);background:rgba(161,0,255,.08);transition:all .15s;white-space:nowrap}}
.pill:hover{{border-color:var(--ac);color:var(--txt)}}
.pill.on{{border-color:var(--ac)!important;color:var(--ac);background:rgba(161,0,255,.12)!important}}
.pill .cnt{{font-size:8px;opacity:.7;margin-left:3px}}
#dom-sel{{background:var(--panel);border:1px solid rgba(161,0,255,.35);border-radius:7px;color:var(--txt);padding:4px 8px;font-size:11px;outline:none;cursor:pointer}}
#dom-sel option{{background:#10022A}}
.rc{{border-radius:4px;padding:2px 7px;font-size:9px;font-weight:700;cursor:pointer;user-select:none;border:1px solid;transition:.15s;white-space:nowrap}}
{reg_chip_css()}
.pill-risk{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(248,113,113,.35);color:#fca5a5;background:rgba(239,68,68,.08);transition:all .15s;white-space:nowrap}}
.pill-risk.on{{border-color:#f87171;color:#f87171;background:rgba(239,68,68,.15)}}
#info{{margin-left:auto;font-size:9.5px;color:var(--muted);white-space:nowrap}}

/* ── Table ───────────────────────────────────────────────────────────────── */
#tbl-wrap{{flex:1;overflow-y:auto;padding:0 24px 16px;min-height:0}}
table{{width:100%;border-collapse:collapse;font-size:12px;table-layout:fixed}}
thead th{{position:sticky;top:0;background:var(--bg2);text-align:left;padding:6px 8px;font-size:8.5px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);border-bottom:1px solid var(--line);z-index:5;white-space:nowrap;cursor:pointer;user-select:none}}
thead th:hover{{color:var(--txt)}}
thead th.sort-asc::after{{content:" ↑"}}thead th.sort-desc::after{{content:" ↓"}}
col.c-id{{width:100px}}col.c-name{{width:auto}}col.c-expr{{width:200px}}col.c-tipo{{width:88px}}col.c-dom{{width:150px}}col.c-reg{{width:120px}}col.c-risk{{width:36px}}
tbody td{{padding:5px 8px;border-bottom:1px solid rgba(161,0,255,.18);vertical-align:middle}}
tbody tr.data-row{{cursor:pointer;transition:background .12s}}
tbody tr.data-row:hover{{background:rgba(161,0,255,.10)}}
tbody tr.data-row.open{{background:rgba(161,0,255,.15)}}
tbody tr.detail-row td{{padding:0;border-bottom:1px solid rgba(161,0,255,.35)}}

/* Grouped rows */
tbody tr.group-hdr{{cursor:pointer;transition:background .12s}}
tbody tr.group-hdr:hover{{background:rgba(161,0,255,.10)}}
tbody tr.group-hdr.exp{{background:rgba(161,0,255,.07)}}
tbody tr.sub-row{{cursor:pointer;display:none;transition:background .12s}}
tbody tr.sub-row.vis{{display:table-row;background:rgba(0,0,0,.2)}}
tbody tr.sub-row.vis:hover{{background:rgba(161,0,255,.08)}}
tbody tr.sub-row.vis.open{{background:rgba(161,0,255,.13)}}
.gc-badge{{font-size:8px;font-weight:800;background:rgba(161,0,255,.12);color:var(--ac);border:1px solid rgba(161,0,255,.28);border-radius:10px;padding:1px 7px;margin-left:8px;vertical-align:middle;white-space:nowrap}}
.grp-arrow{{display:inline-block;font-size:9px;color:var(--muted);transition:transform .15s;transform-origin:50% 50%;margin-right:4px;vertical-align:middle}}
tr.exp .grp-arrow{{transform:rotate(90deg)}}
.sub-id{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#5a2a7a;padding-left:16px;white-space:nowrap;display:block}}
.sub-sp-lbl{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#8040b0}}

/* Cell styles */
.c-id-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#7030a0;white-space:nowrap}}
.c-name-val{{font-size:12px;color:var(--txt);font-weight:500;line-height:1.3}}
.c-sp-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:#8040b0;display:block;margin-top:2px}}
.c-expl-val{{font-size:10px;color:#9080b0;line-height:1.35;margin-top:3px;font-style:italic;max-width:99%}}
.c-expr-val{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:#a090c0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:196px;display:block;line-height:1.4}}
.tp{{display:inline-block;font-size:8.5px;font-weight:800;padding:2px 6px;border-radius:3px;white-space:nowrap;letter-spacing:.04em}}
.tp-F{{background:#052e16;color:#6ee7b7}}.tp-V{{background:#1e3a5f;color:#93c5fd}}
.tp-U{{background:#431407;color:#fdba74}}.tp-E{{background:#0a2a2a;color:#5eead4}}
.dom-val{{font-size:10px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.reg-cell{{display:flex;gap:3px;flex-wrap:wrap;align-items:center}}
.rc-inline{{border-radius:3px;padding:1px 5px;font-size:8px;font-weight:700;border:1px solid;white-space:nowrap}}
.risk-cell{{text-align:center}}
.risk-icon{{font-size:12px;cursor:default}}

/* Detail panel */
.det{{padding:10px 14px 12px;background:rgba(5,0,18,.65);border-top:1px solid rgba(161,0,255,.25)}}
.det-sp{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:#8040b0;margin-bottom:6px}}
.det-expl{{font-size:11px;color:#c0b0e0;margin-bottom:8px;line-height:1.5}}
.det-code{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px;color:#b8a8d8;background:rgba(0,0,0,.4);border:1px solid rgba(161,0,255,.25);border-radius:6px;padding:8px 12px;white-space:pre-wrap;word-break:break-all;margin-bottom:8px;line-height:1.6}}
.det-risk{{margin-bottom:6px}}
.det-risk-item{{display:inline-block;font-size:9px;color:#fca5a5;background:rgba(239,68,68,.1);border:1px solid rgba(248,113,113,.3);border-radius:4px;padding:2px 8px;margin:2px 2px 2px 0}}
.det-norma{{font-size:10px;color:#9080b0;font-style:italic;line-height:1.4;margin-bottom:6px}}
.det-vr{{display:flex;gap:4px;flex-wrap:wrap}}
.vr-tag{{font-size:9px;background:rgba(161,0,255,.15);border:1px solid rgba(161,0,255,.28);border-radius:3px;padding:1px 6px;color:#c084fc}}

/* Pagination */
#pgbar{{display:flex;align-items:center;gap:8px;padding:8px 24px;border-top:1px solid var(--line);flex-shrink:0;background:rgba(5,0,18,.65)}}
#pgbar .pginfo{{font-size:10px;color:var(--muted)}}
.pgbtn{{background:var(--panel);border:1px solid rgba(161,0,255,.32);border-radius:5px;color:var(--muted);padding:4px 12px;font-size:11px;cursor:pointer;transition:.15s}}
.pgbtn:hover:not(:disabled){{border-color:var(--ac);color:var(--txt)}}
.pgbtn:disabled{{opacity:.35;cursor:default}}
#pgbar .pgsp{{flex:1}}

/* Tooltip */
#tip{{position:fixed;z-index:9999;max-width:600px;pointer-events:none;display:none;background:#0d0125;color:#e2d8f7;border:1px solid rgba(161,0,255,.4);border-radius:7px;padding:8px 12px;font-family:'Cascadia Code','Consolas',monospace;font-size:11px;line-height:1.55;white-space:pre-wrap;word-break:break-word;box-shadow:0 12px 34px rgba(0,0,0,.7)}}
</style>
</head>
<body>

<div class="hero">
  <div class="hero-grid"></div>
  <div class="hero-glow"></div>
  <div class="hero-bar">
    <img class="hero-logo" src="{LOGO_URI}" alt="Accenture">
    <div class="sep"></div>
    <span class="crumb">SPE-AM-002 <em>›</em> Reglas de Negocio</span>
    <span class="sp"></span>
    <a class="back" href="index.html">← Inicio</a>
  </div>
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">GENCore · Gemelo Cognitivo del Sistema</div>
      <h1 class="hero-h1">Reglas de Negocio</h1>
      <div class="hero-sub">{M["total"]:,} reglas de negocio destiladas del código fuente del core bancario.<br>La lógica que gobierna cada cálculo, validación y umbral — inferida del código y hecha legible para el negocio.</div>
    </div>
    <div class="hero-stats">
      <div class="stat-block"><div class="sn" id="h-total">{M["total"]:,}</div><div class="sl">Total reglas</div></div>
      <div class="stat-block"><div class="sn">{M["n_groups"]:,}</div><div class="sl">Nombres únicos</div></div>
      <div class="stat-block pu"><div class="sn">{M["by_tipo"].get("FÓRMULA",0):,}</div><div class="sl">Fórmulas</div></div>
      <div class="stat-block pu"><div class="sn">{M["by_tipo"].get("VALIDACIÓN",0):,}</div><div class="sl">Validaciones</div></div>
      <div class="stat-block pu"><div class="sn">{M["by_tipo"].get("UMBRAL",0):,}</div><div class="sl">Umbrales</div></div>
      <div class="stat-block pu"><div class="sn">{M["by_tipo"].get("ESTADO",0):,}</div><div class="sl">Estados</div></div>
      <div class="stat-block or"><div class="sn">{M["n_riesgo"]:,}</div><div class="sl">Riesgo equiv.</div></div>
    </div>
  </div>
</div>

<div id="fbar">
  <input id="q" type="search" placeholder="&#128269; buscar nombre, SP, regulador…" autocomplete="off">
  <div class="fsep"></div>
  <span class="pill on" data-f="tipo" data-v="">Todos</span>
  {tipo_pills}
  <div class="fsep"></div>
  <select id="dom-sel"><option value="">Todos los dominios</option></select>
  <div class="fsep"></div>
  {reg_chips}
  <div class="fsep"></div>
  <span class="pill-risk" id="btn-risk">⚠ Riesgo equiv.</span>
  <span id="info">cargando…</span>
</div>

<div id="tbl-wrap">
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

<div id="pgbar">
  <button class="pgbtn" id="pg-prev">&#8592; Ant.</button>
  <span class="pginfo" id="pginfo"></span>
  <span class="pgsp"></span>
  <button class="pgbtn" id="pg-next">Sig. &#8594;</button>
</div>

<script>
const PORTAL_DATA = {DATA_JSON};
const PAGE = 100;
let ALL = PORTAL_DATA.rules;
let filteredGroups = [], expandedGroups = new Set();
let page = 0, openId = null;
let fTipo='', fDom='', fReg='', fRisk=false, fQ='', sortCol='n', sortDir=1;

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

function renderDetail(r){{
  let html = `<tr class="detail-row"><td colspan="7"><div class="det">`;
  html += `<div class="det-sp">${{esc(r.db)}}:${{esc(r.s)}} &nbsp;·&nbsp; línea ${{r.ln||'?'}}</div>`;
  if(r.rn) html += `<div class="det-norma">${{esc(r.rn)}}</div>`;
  if(r.e)  html += `<div class="det-expl">${{esc(r.e)}}</div>`;
  if(r.he && r.he !== r.c){{
    html += `<div class="det-code det-expr-human">${{esc(r.he)}}</div>`;
    html += `<div class="det-code" style="opacity:.55;font-size:.8em;margin-top:2px">${{esc(r.c)}}</div>`;
  }} else if(r.c){{
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

function renderGroupHeader(grp){{
  const r0 = grp[0], gi = r0.gi, isExp = expandedGroups.has(gi);
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

function renderSubRow(r, gi){{
  const isVis = expandedGroups.has(gi), isDet = isVis && openId===r.i;
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

function buildGroups(rules){{
  const gmap = new Map();
  rules.forEach(r=>{{ if(!gmap.has(r.gi)) gmap.set(r.gi,[]); gmap.get(r.gi).push(r); }});
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
  let html='';
  filteredGroups.slice(start,end).forEach(grp=>{{
    if(grp.length===1){{
      html+=renderSingleRow(grp[0]);
      if(openId===grp[0].i) html+=renderDetail(grp[0]);
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

// ── Init ──────────────────────────────────────────────────────────────────────
const sel=document.getElementById('dom-sel');
PORTAL_DATA.meta.domains.forEach(d=>{{
  const o=document.createElement('option'); o.value=d; o.textContent=d; sel.appendChild(o);
}});
applyFilters();

// ── Events ────────────────────────────────────────────────────────────────────
let qTimer;
document.getElementById('q').addEventListener('input',e=>{{
  clearTimeout(qTimer);
  qTimer=setTimeout(()=>{{fQ=e.target.value; applyFilters();}},180);
}});
document.querySelectorAll('.pill[data-f="tipo"]').forEach(p=>{{
  p.addEventListener('click',()=>{{
    document.querySelectorAll('.pill[data-f="tipo"]').forEach(x=>x.classList.remove('on'));
    p.classList.add('on'); fTipo=p.dataset.v; applyFilters();
  }});
}});
document.getElementById('dom-sel').addEventListener('change',e=>{{ fDom=e.target.value; applyFilters(); }});
document.querySelectorAll('.rc[data-reg]').forEach(c=>{{
  c.addEventListener('click',()=>{{
    const reg=c.dataset.reg;
    if(fReg===reg){{fReg=''; c.style.opacity='';}}
    else{{ document.querySelectorAll('.rc[data-reg]').forEach(x=>x.style.opacity='0.45'); c.style.opacity=''; fReg=reg; }}
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
    if(sortCol===col) sortDir*=-1; else{{sortCol=col; sortDir=1;}}
    document.querySelectorAll('thead th').forEach(h=>h.classList.remove('sort-asc','sort-desc'));
    th.classList.add(sortDir===1?'sort-asc':'sort-desc');
    applyFilters();
  }});
}});
document.getElementById('tbody').addEventListener('click',e=>{{
  const hdr=e.target.closest('tr.group-hdr');
  if(hdr){{
    const gi=parseInt(hdr.dataset.gi);
    if(expandedGroups.has(gi)){{ expandedGroups.delete(gi); openId=null; }}
    else expandedGroups.add(gi);
    renderPage(); return;
  }}
  const sub=e.target.closest('tr.sub-row');
  if(sub){{ const id=sub.dataset.id; openId=(openId===id)?null:id; renderPage(); return; }}
  const row=e.target.closest('tr.data-row');
  if(row){{ const id=row.dataset.id; openId=(openId===id)?null:id; renderPage(); }}
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
</script>
</body>
</html>"""

OUT_F.write_text(html, encoding='utf-8')
size = os.path.getsize(OUT_F)
print(f"OK  portal/rules-catalog.html  ({size:,} bytes)")
print(f"    {M['total']:,} reglas · {M['n_groups']:,} grupos · {len(M['domains'])} dominios")
print(f"\nOpen: http://localhost:3003/rules-catalog.html")

#!/usr/bin/env python3
"""
Liverpool — Mapa de Interfaces RFC/BAPI (Módulo Importaciones)
--------------------------------------------------------------
Extrae CALL FUNCTION de los 12 programas ABAP, clasifica cada interfaz
y genera un mapa programa × interfaz para el S/4HANA Simplification Assessment.

Reads  source/Source Code SAP/<programas>
Writes portal/data/interfaces-liv.json
       portal/interfaces-map-liv.html
"""
import re, json, glob, os
from pathlib import Path
from datetime import date

HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRC   = BRAIN / "source" / "Source Code SAP"
OUTJ  = BRAIN / "portal" / "data" / "interfaces-liv.json"
OUTH  = BRAIN / "portal" / "interfaces-map-liv.html"

PROG_DOMAIN = {
    "ZIMFIC002": "R07", "ZIMPOB010B": "R04", "ZIMPOC001": "R04",
    "ZIMPOC002": "R01", "ZIMPOC003": "R01", "ZIMPOC005": "R04",
    "ZIMPOC007": "R04", "ZIMPOC023": "R04", "ZIMPOC024": "R04",
    "ZRTPOC079": "R04", "ZRTPOC079N": "R04", "ZRT_PO_REP_EPI_BD": "R07",
}

# ── Clasificación de interfaces ───────────────────────────────────────────────
def classify(fn: str) -> str:
    if fn.startswith("BAPI_"):                                   return "BAPI"
    if fn.startswith("RFC_") or ("RFC" in fn and fn[0] in "ZY"): return "RFC"
    if fn[0] in "ZY" or fn.startswith("W_FRM"):                  return "Z-CUSTOM"
    if fn.startswith(("ENQUEUE_", "DEQUEUE_")) or fn == "VIEW_ENQUEUE": return "LOCK"
    if fn.startswith(("REUSE_ALV", "LVC_", "ALV_", "F4IF_", "HELP_VALUES",
                      "POPUP_", "DD_POPUP", "DYNP_", "COPO_POPUP")) or fn == "SCROLLING_IN_TABLE":
        return "UI/ALV"
    if fn in ("READ_TEXT", "SAVE_TEXT", "GOS_EXECUTE_SERVICE") or fn.startswith("SSF_"): return "TEXT/FORM"
    if fn.startswith("BAL_"):                                    return "APP-LOG"
    if fn.startswith("SUSR_") or fn.startswith("AGR"):           return "USER/AUTH"
    if fn in ("JOB_OPEN", "JOB_CLOSE", "BP_JOB_SELECT", "SXPG_COMMAND_EXECUTE"): return "JOB/OS"
    return "UTIL"

# interfaces que exigen revisión en la migración a S/4HANA
S4_RISK = {"BAPI", "Z-CUSTOM", "RFC"}

CAT_META = {  # categoría → (color, glosa)
    "BAPI":      ("#f87171", "BAPI transaccional — revisar deprecación / API release en S/4HANA"),
    "Z-CUSTOM":  ("#E00198", "Función Z de Liverpool — migración obligatoria, riesgo alto"),
    "RFC":       ("#DA7AB0", "Interfaz remota (RFC) — frontera de integración"),
    "LOCK":      ("#87C3D3", "Objeto de bloqueo (enqueue/dequeue) — estándar"),
    "UI/ALV":    ("#6b8cce", "Presentación ALV / diálogo dynpro — estándar UI"),
    "TEXT/FORM": ("#5eb0a8", "Textos / SmartForms / servicios de objeto — estándar"),
    "APP-LOG":   ("#9070a0", "Application Log (BAL) — estándar"),
    "USER/AUTH": ("#b18cd0", "Usuario / autorizaciones — estándar"),
    "JOB/OS":    ("#e0a83a", "Batch / comando de sistema operativo"),
    "UTIL":      ("#8a7090", "Utilería / conversión — estándar"),
}

# ── Extracción ────────────────────────────────────────────────────────────────
RE_CALL = re.compile(r"call\s+function\s+'([^']+)'", re.I)

def scan(path):
    calls = []
    for i, raw in enumerate(open(path, encoding="latin-1"), 1):
        s = raw.strip()
        if not s or s.startswith("*"):
            continue
        s = re.sub(r'".*$', "", s)          # quita comentario en línea
        for m in RE_CALL.finditer(s):
            calls.append((m.group(1).upper(), i))
    return calls

progs = sorted(f for f in glob.glob(str(SRC / "*")) if os.path.isfile(f) and not f.endswith(".xlsx"))

edges = []                                   # (prog, fn, cat, count, lines)
fn_meta = {}                                 # fn → {cat, progs:set, total}
prog_list = []
for p in progs:
    name = os.path.basename(p)
    prog_list.append(name)
    calls = scan(p)
    agg = {}
    for fn, ln in calls:
        agg.setdefault(fn, []).append(ln)
    for fn, lns in agg.items():
        cat = classify(fn)
        edges.append({"prog": name, "fn": fn, "cat": cat, "n": len(lns), "lines": lns[:6]})
        m = fn_meta.setdefault(fn, {"cat": cat, "progs": set(), "total": 0})
        m["progs"].add(name); m["total"] += len(lns)

# hotspots = interfaces compartidas por ≥2 programas
for fn, m in fn_meta.items():
    m["shared"] = len(m["progs"]) >= 2

# ── Stats ─────────────────────────────────────────────────────────────────────
by_cat = {}
for fn, m in fn_meta.items():
    by_cat[m["cat"]] = by_cat.get(m["cat"], 0) + 1
n_s4 = sum(1 for m in fn_meta.values() if m["cat"] in S4_RISK)
n_shared = sum(1 for m in fn_meta.values() if m["shared"])
total_calls = sum(e["n"] for e in edges)

payload = {
    "meta": {
        "generated": str(date.today()), "programs": len(prog_list),
        "interfaces": len(fn_meta), "calls": total_calls,
        "s4_risk": n_s4, "shared": n_shared, "by_cat": by_cat,
    },
    "programs": prog_list,
    "functions": [
        {"fn": fn, "cat": m["cat"], "total": m["total"],
         "progs": sorted(m["progs"]), "shared": m["shared"],
         "s4": m["cat"] in S4_RISK}
        for fn, m in sorted(fn_meta.items(), key=lambda x: (-x[1]["total"], x[0]))
    ],
    "edges": edges,
}
OUTJ.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

# ── HTML ──────────────────────────────────────────────────────────────────────
data_js = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
cat_css = "".join(
    f'.cb-{c.replace("/","").replace("-","")}{{background:{col}22;color:{col};border-color:{col}55}}'
    for c, (col, _) in CAT_META.items()
)
cat_meta_js = json.dumps({c: {"color": col, "gloss": g} for c, (col, g) in CAT_META.items()}, ensure_ascii=False)
s4_js = json.dumps(sorted(S4_RISK))

HTML = f"""<!DOCTYPE html>
<html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Liverpool · Mapa de Interfaces RFC/BAPI</title>
<style>
:root{{--pink:#E00198;--sky:#87C3D3;--rose:#DA7AB0;--ink:#FFF0F8;--muted:#c09ab8;--muted2:#9070a0;
--bg:#0d0408;--bg2:#130610;--panel:#1a0814;--txt:#f0e6ef;--line:rgba(224,1,152,.18)}}
*{{box-sizing:border-box;margin:0;padding:0}}html,body{{height:100%}}
body{{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,'Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}}
.hero{{position:relative;overflow:hidden;background:linear-gradient(135deg,#0d0408,#200412 40%,#360820 65%,#200412);flex-shrink:0}}
.hero-grid{{position:absolute;inset:0;background-image:linear-gradient(rgba(224,1,152,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(224,1,152,.10) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.5) 30%,rgba(0,0,0,.3) 70%,transparent)}}
.hero-glow{{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(224,1,152,.28),transparent 70%)}}
.hero-bar{{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(224,1,152,.12)}}
.hero-logo{{height:30px;width:auto;flex-shrink:0}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--sky);font-style:normal}}.hero-bar .sp{{flex:1}}
.hero-bar .badge{{font-size:9px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);padding:2px 8px;border-radius:20px}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
.hero-body{{position:relative;z-index:1;padding:18px 28px 22px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}}
.hero-title{{flex:1;min-width:240px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--sky);margin-bottom:8px}}
.hero-h1{{font-size:clamp(22px,4vw,32px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(224,1,152,.8));-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.hero-sub{{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:680px}}
.hero-stats{{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end}}
.stat-block{{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:11px 16px;min-width:84px}}
.stat-block .sn{{font-size:24px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--sky),#b8e0ea);-webkit-background-clip:text;-webkit-text-fill-color:transparent;line-height:1}}
.stat-block.pink .sn{{background:linear-gradient(135deg,var(--pink),var(--rose));-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.stat-block.red .sn{{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent}}
.stat-block .sl{{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}}
#fbar{{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);flex-shrink:0}}
#q{{background:var(--panel);border:1px solid rgba(224,1,152,.4);border-radius:7px;color:var(--txt);padding:5px 10px;font-size:12px;width:210px;outline:none}}
#q:focus{{border-color:var(--sky)}}
.sep{{width:1px;height:18px;background:rgba(255,255,255,.08)}}
.pill{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid;transition:.15s;white-space:nowrap;opacity:.55}}
.pill.on{{opacity:1}}
.pill-s4{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;border:1px solid rgba(248,113,113,.4);color:#fca5a5;background:rgba(239,68,68,.08);white-space:nowrap}}
.pill-s4.on{{border-color:#f87171;background:rgba(239,68,68,.18)}}
.pill-sh{{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;border:1px solid rgba(135,195,211,.4);color:var(--sky);background:rgba(135,195,211,.08);white-space:nowrap}}
.pill-sh.on{{border-color:var(--sky);background:rgba(135,195,211,.18)}}
#info{{margin-left:auto;font-size:9.5px;color:var(--muted)}}
#wrap{{flex:1;overflow:auto;padding:0 24px 20px;min-height:0}}
table{{border-collapse:separate;border-spacing:0;font-size:11px;width:100%}}
thead th{{position:sticky;top:0;z-index:6;background:var(--bg2);border-bottom:1px solid var(--line)}}
th.rot{{height:118px;padding:0;width:34px;vertical-align:bottom}}
th.rot>div{{transform:translateX(15px) rotate(-90deg);transform-origin:center;width:34px}}
th.rot span{{font-family:'Cascadia Code','Consolas',monospace;font-size:9px;color:var(--sky);white-space:nowrap;padding:4px 0}}
th.corner{{text-align:left;padding:6px 8px;font-size:9px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);min-width:280px}}
tbody td{{border-bottom:1px solid rgba(224,1,152,.08)}}
td.fn{{padding:4px 8px;white-space:nowrap;max-width:300px}}
.fn-name{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px;color:var(--ink)}}
.fn-cat{{display:inline-block;font-size:8px;font-weight:800;padding:1px 5px;border-radius:3px;border:1px solid;margin-left:6px;vertical-align:middle}}
{cat_css}
.badge-s4{{font-size:8px;color:#fca5a5;margin-left:5px}}
.badge-sh{{font-size:8px;color:var(--sky);margin-left:4px}}
td.cell{{text-align:center;width:34px;height:26px;border-left:1px solid rgba(224,1,152,.05)}}
.dot{{display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:5px;font-size:9px;font-weight:800;font-family:'Cascadia Code',monospace}}
tr.grp td{{background:rgba(224,1,152,.06);padding:7px 8px;font-size:9px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--rose);border-top:1px solid var(--line)}}
tr.frow:hover td{{background:rgba(224,1,152,.05)}}
tr.frow.hi td.fn{{background:rgba(248,113,113,.08)}}
#tip{{position:fixed;z-index:99;max-width:340px;pointer-events:none;display:none;background:#0d0408;color:#e2d0df;border:1px solid rgba(224,1,152,.3);border-radius:7px;padding:8px 12px;font-size:11px;line-height:1.5;box-shadow:0 12px 34px rgba(0,0,0,.6)}}
.legend{{display:flex;gap:10px;flex-wrap:wrap;padding:8px 24px;background:rgba(13,4,8,.6);border-top:1px solid var(--line);flex-shrink:0;font-size:9.5px;color:var(--muted)}}
.legend b{{display:inline-block;width:9px;height:9px;border-radius:2px;margin-right:3px;vertical-align:middle}}
</style></head><body>
<div class="hero"><div class="hero-grid"></div><div class="hero-glow"></div>
  <div class="hero-bar"><img class="hero-logo" src="Liverpool_logo.png" alt="Liverpool">
    <span class="crumb">SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Interfaces RFC/BAPI</span>
    <span class="sp"></span><span class="badge">Corpus ABAP</span><a class="back" href="index.html">← Inicio</a></div>
  <div class="hero-body"><div class="hero-title">
    <div class="hero-label">Liverpool · SAP ECC → S/4HANA · Simplification Assessment</div>
    <h1 class="hero-h1">Mapa de Interfaces RFC/BAPI</h1>
    <div class="hero-sub">Cada llamada <code>CALL FUNCTION</code> de los 12 programas ABAP del Módulo de Importaciones, clasificada y cruzada por programa. Las interfaces <b style="color:#fca5a5">BAPI</b>, <b style="color:var(--pink)">Z-custom</b> y <b style="color:var(--rose)">RFC</b> son la frontera que debe revisarse antes de migrar a S/4HANA.</div>
  </div>
  <div class="hero-stats">
    <div class="stat-block"><div class="sn">{len(fn_meta)}</div><div class="sl">Interfaces</div></div>
    <div class="stat-block"><div class="sn">{total_calls}</div><div class="sl">Llamadas</div></div>
    <div class="stat-block red"><div class="sn">{n_s4}</div><div class="sl">Riesgo S/4</div></div>
    <div class="stat-block pink"><div class="sn">{by_cat.get('Z-CUSTOM',0)}</div><div class="sl">Z-custom</div></div>
    <div class="stat-block"><div class="sn">{n_shared}</div><div class="sl">Compartidas</div></div>
  </div></div></div>
<div id="fbar">
  <input id="q" type="search" placeholder="🔍 función o programa…" autocomplete="off">
  <div class="sep"></div><span id="cats"></span>
  <div class="sep"></div><span class="pill-s4" id="btn-s4">⚠ Riesgo S/4HANA</span>
  <span class="pill-sh" id="btn-sh">↔ Compartidas</span>
  <span id="info"></span>
</div>
<div id="wrap"><table id="tbl"><thead id="thead"></thead><tbody id="tbody"></tbody></table></div>
<div class="legend" id="legend"></div>
<script>
const D={data_js};
const CAT={cat_meta_js};
const S4={s4_js};
let fCat=new Set(Object.keys(CAT)), fS4=false, fSh=false, fQ='';
const esc=s=>String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
const catCls=c=>'cb-'+c.replace(/[/-]/g,'');

// cat pills
document.getElementById('cats').innerHTML=Object.entries(CAT).map(([c,m])=>
  `<span class="pill on ${{catCls(c)}}" data-cat="${{c}}" style="border-color:${{m.color}}55;color:${{m.color}}">${{c}}</span>`).join('');
document.getElementById('legend').innerHTML=Object.entries(CAT).map(([c,m])=>
  `<span><b style="background:${{m.color}}"></b>${{c}} — ${{esc(m.gloss)}}</span>`).join('');

// header row: corner + rotated program columns
document.getElementById('thead').innerHTML=
  `<tr><th class="corner">Interfaz (${{D.functions.length}})</th>`+
  D.programs.map(p=>`<th class="rot"><div><span>${{esc(p)}}</span></div></th>`).join('')+`</tr>`;

function render(){{
  const q=fQ.toLowerCase().trim();
  let rows=D.functions.filter(f=>{{
    if(!fCat.has(f.cat)) return false;
    if(fS4&&!f.s4) return false;
    if(fSh&&!f.shared) return false;
    if(q&&!(f.fn.toLowerCase().includes(q)||f.progs.some(p=>p.toLowerCase().includes(q)))) return false;
    return true;
  }});
  // group by category, ordered by CAT key order
  const order=Object.keys(CAT);
  rows.sort((a,b)=> order.indexOf(a.cat)-order.indexOf(b.cat) || b.total-a.total || a.fn.localeCompare(b.fn));
  // edge lookup
  const emap={{}};
  D.edges.forEach(e=>{{emap[e.fn+'|'+e.prog]=e;}});
  let html='',lastCat=null;
  rows.forEach(f=>{{
    if(f.cat!==lastCat){{
      lastCat=f.cat;
      html+=`<tr class="grp"><td colspan="${{D.programs.length+1}}" style="color:${{CAT[f.cat].color}}">${{f.cat}} — ${{esc(CAT[f.cat].gloss)}}</td></tr>`;
    }}
    html+=`<tr class="frow${{f.s4?' hi':''}}"><td class="fn"><span class="fn-name">${{esc(f.fn)}}</span>`+
      `<span class="fn-cat ${{catCls(f.cat)}}">${{f.cat}}</span>`+
      (f.s4?`<span class="badge-s4">⚠</span>`:'')+
      (f.shared?`<span class="badge-sh">↔${{f.progs.length}}</span>`:'')+`</td>`;
    D.programs.forEach(p=>{{
      const e=emap[f.fn+'|'+p];
      if(e){{
        const col=CAT[f.cat].color;
        html+=`<td class="cell"><span class="dot" style="background:${{col}}28;color:${{col}};border:1px solid ${{col}}55" data-tip="${{esc(f.fn)}} en ${{esc(p)}}\\n${{e.n}} llamada(s) · líneas ${{e.lines.join(', ')}}">${{e.n}}</span></td>`;
      }} else html+=`<td class="cell"></td>`;
    }});
    html+=`</tr>`;
  }});
  document.getElementById('tbody').innerHTML=html;
  document.getElementById('info').textContent=`${{rows.length}} interfaces visibles`;
}}
document.querySelectorAll('.pill[data-cat]').forEach(p=>p.addEventListener('click',()=>{{
  const c=p.dataset.cat;
  if(fCat.has(c)&&fCat.size===Object.keys(CAT).length){{fCat=new Set([c]);}}
  else if(fCat.has(c)){{fCat.delete(c);}} else fCat.add(c);
  if(fCat.size===0) fCat=new Set(Object.keys(CAT));
  document.querySelectorAll('.pill[data-cat]').forEach(x=>x.classList.toggle('on',fCat.has(x.dataset.cat)));
  render();
}}));
document.getElementById('btn-s4').addEventListener('click',e=>{{fS4=!fS4;e.target.classList.toggle('on',fS4);render();}});
document.getElementById('btn-sh').addEventListener('click',e=>{{fSh=!fSh;e.target.classList.toggle('on',fSh);render();}});
let qt;document.getElementById('q').addEventListener('input',e=>{{clearTimeout(qt);qt=setTimeout(()=>{{fQ=e.target.value;render();}},160);}});
const tip=document.createElement('div');tip.id='tip';document.body.appendChild(tip);
document.addEventListener('mouseover',e=>{{const el=e.target.closest('[data-tip]');if(el){{tip.textContent=el.getAttribute('data-tip');tip.style.display='block';}}}});
document.addEventListener('mousemove',e=>{{if(tip.style.display==='block'){{let x=e.clientX+14,y=e.clientY+14;const r=tip.getBoundingClientRect();if(x+r.width>innerWidth-8)x=e.clientX-r.width-14;if(y+r.height>innerHeight-8)y=e.clientY-r.height-14;tip.style.left=x+'px';tip.style.top=y+'px';}}}});
document.addEventListener('mouseout',e=>{{if(e.target.closest('[data-tip]'))tip.style.display='none';}});
render();
</script></body></html>"""

OUTH.write_text(HTML, encoding="utf-8")
print(f"interfaces  -> {OUTJ.name}: {len(fn_meta)} interfaces / {total_calls} calls / {n_s4} S4-risk / {n_shared} shared")
print(f"            -> {OUTH.name}  ({round(OUTH.stat().st_size/1024,1)} KB)")

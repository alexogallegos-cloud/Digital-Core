#!/usr/bin/env python3
"""Liverpool — Complejidad de Migración por Programa.
Reads portal/data/program-metrics-liv.json → portal/migration-complexity-liv.html"""
import json
from pathlib import Path
import _liv_shared as S

HERE = Path(__file__).parent
DATA = HERE.parent / "portal" / "data" / "program-metrics-liv.json"
OUT  = HERE.parent / "portal" / "migration-complexity-liv.html"

d = json.loads(DATA.read_text(encoding="utf-8"))
P = d["programs"]
avg = round(sum(p["complexity"] for p in P) / len(P), 1)
mxc = max(p["complexity"] for p in P)
n_ref = sum(1 for p in P if p["r7"] == "Refactor")

stats = (S.stat(len(P), "Programas") + S.stat(avg, "Complejidad media") +
         S.stat(mxc, "Máxima", "red") + S.stat(n_ref, "Refactor", "pink"))
hero = S.hero(
    "Liverpool · SAP ECC → S/4HANA · Assessment 7R",
    "Complejidad de Migración",
    "Score compuesto por programa a partir de tamaño (LOC), estructura (FORM/PERFORM), "
    "UI dynpro, superficie de validación (MESSAGE), acoplamiento de datos (#tablas) e "
    "integración (RFC/BAPI/Z). Cada barra descompone el peso de cada factor; la hipótesis "
    "7R se deriva del perfil del programa.",
    "SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Complejidad", "Assessment 7R", stats)

R7C = {"Refactor":"#f87171","Replatform":"#e0a83a","Retain+Remediate":"#6ee7b7","Retire":"#9070a0"}
data_js = json.dumps({"programs": P, "r7c": R7C}, ensure_ascii=False, separators=(",", ":"))

extra = """
#wrap{flex:1;overflow:auto;padding:14px 24px 20px;min-height:0}
.row{display:grid;grid-template-columns:210px 1fr 54px;gap:12px;align-items:center;padding:7px 0;border-bottom:1px solid rgba(224,1,152,.08)}
.row:hover{background:rgba(224,1,152,.04)}
.pl{display:flex;flex-direction:column;gap:2px;min-width:0}
.pn{font-family:'Cascadia Code','Consolas',monospace;font-size:12px;color:var(--ink);font-weight:700}
.pm{font-size:9px;color:var(--muted2)}
.r7{display:inline-block;font-size:8px;font-weight:800;padding:1px 6px;border-radius:3px;border:1px solid;margin-left:6px;vertical-align:middle}
.bar{height:22px;background:rgba(255,255,255,.03);border-radius:5px;overflow:hidden;display:flex;border:1px solid rgba(224,1,152,.1)}
.seg{height:100%}
.sc{font-family:'Cascadia Code',monospace;font-size:15px;font-weight:900;text-align:right;color:var(--sky)}
.legend{display:flex;gap:12px;flex-wrap:wrap;padding:8px 24px;background:rgba(13,4,8,.6);border-top:1px solid var(--line);flex-shrink:0;font-size:9.5px;color:var(--muted)}
.legend b{display:inline-block;width:9px;height:9px;border-radius:2px;margin-right:3px;vertical-align:middle}
"""

body = """
<div id="fbar">
  <span class="pill on" data-s="complexity">▼ Complejidad</span>
  <span class="pill" data-s="loc">LOC</span>
  <span class="pill" data-s="tables">Tablas</span>
  <span class="pill" data-s="rfc">Integración</span>
  <span class="sep"></span>
  <span class="pill on" data-r7="">Todos 7R</span>
  <span class="pill" data-r7="Refactor">Refactor</span>
  <span class="pill" data-r7="Replatform">Replatform</span>
  <span class="pill" data-r7="Retain+Remediate">Retain</span>
  <span class="pill" data-r7="Retire">Retire</span>
  <span id="info"></span>
</div>
<div id="wrap"><div id="list"></div></div>
<div class="legend" id="legend"></div>
"""

SEG = {"loc":["#87C3D3","Tamaño (LOC)"],"forms":["#DA7AB0","Estructura (FORM)"],
       "performs":["#E00198","Control (PERFORM)"],"screens":["#e0a83a","UI (pantallas)"],
       "messages":["#f0a3d0","Validación (MESSAGE)"],"tables":["#6ee7b7","Datos (#tablas)"],
       "rfc":["#f87171","Integración (RFC/BAPI/Z)"]}
seg_js = json.dumps(SEG, ensure_ascii=False)

script = f"""
const D={data_js}, SEG={seg_js};
let sortK='complexity', f7='';
document.getElementById('legend').innerHTML=Object.entries(SEG).map(([k,v])=>`<span><b style="background:${{v[0]}}"></b>${{v[1]}}</span>`).join('');
const esc=s=>String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
function render(){{
  let rows=D.programs.filter(p=>!f7||p.r7===f7).slice().sort((a,b)=>b[sortK]-a[sortK]);
  let h='';
  rows.forEach(p=>{{
    const segs=Object.keys(SEG).map(k=>{{const w=p.breakdown[k]||0;return w>0?`<div class="seg" style="width:${{w}}%;background:${{SEG[k][0]}}" data-tip="${{SEG[k][1]}}: ${{w}} pts"></div>`:'';}}).join('');
    const c=D.r7c[p.r7]||'#888';
    h+=`<div class="row"><div class="pl"><div class="pn">${{esc(p.prog)}}<span class="r7" style="border-color:${{c}}55;color:${{c}};background:${{c}}18">${{p.r7}}</span></div>`+
       `<div class="pm">${{p.dom}} · ${{esc(p.dom_label)}} · ${{p.loc}} LOC · ${{p.tables}} tablas · ${{p.rfc}} interfaces · ${{p.rules}} reglas — ${{esc(p.r7_why)}}</div></div>`+
       `<div class="bar" data-tip="Complejidad ${{p.complexity}}/100">${{segs}}</div><div class="sc">${{p.complexity}}</div></div>`;
  }});
  document.getElementById('list').innerHTML=h;
  document.getElementById('info').textContent=`${{rows.length}} programas`;
}}
document.querySelectorAll('.pill[data-s]').forEach(p=>p.addEventListener('click',()=>{{document.querySelectorAll('.pill[data-s]').forEach(x=>x.classList.remove('on'));p.classList.add('on');sortK=p.dataset.s;render();}}));
document.querySelectorAll('.pill[data-r7]').forEach(p=>p.addEventListener('click',()=>{{document.querySelectorAll('.pill[data-r7]').forEach(x=>x.classList.remove('on'));p.classList.add('on');f7=p.dataset.r7;render();}}));
render();
"""

OUT.write_text(S.page("Liverpool · Complejidad de Migración", hero, body, extra, script), encoding="utf-8")
print(f"complexity -> {OUT.name} ({round(OUT.stat().st_size/1024,1)} KB)")

#!/usr/bin/env python3
"""Liverpool — Ranking de Prioridad de Migración.
Reads portal/data/program-metrics-liv.json → portal/priority-ranking-liv.html"""
import json
from pathlib import Path
import _liv_shared as S

HERE = Path(__file__).parent
DATA = HERE.parent / "portal" / "data" / "program-metrics-liv.json"
OUT  = HERE.parent / "portal" / "priority-ranking-liv.html"

d = json.loads(DATA.read_text(encoding="utf-8"))
P = d["programs"]                                   # ya viene ordenado por prioridad
n_reg = sum(1 for p in P if p["reg"])
n_hub = sum(1 for p in P if p["fan_in"] >= 2)

stats = (S.stat(len(P), "Programas") + S.stat(f'{P[0]["priority"]}', "Máx. prioridad", "pink") +
         S.stat(n_reg, "Con regulación", "red") + S.stat(n_hub, "Hubs (fan-in≥2)"))
hero = S.hero(
    "Liverpool · SAP ECC → S/4HANA · Backlog de Migración",
    "Ranking de Prioridad",
    "Orden de ataque para la migración: prioridad = complejidad (50%) + señal regulatoria (20%) "
    "+ acoplamiento entrante / fan-in (20%) + Simplification Items S/4 (10%). Los programas de arriba "
    "son los que más gobiernan el riesgo y la secuencia del cutover.",
    "SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Prioridad", "Backlog 7R", stats)

R7C = {"Refactor":"#f87171","Replatform":"#e0a83a","Retain+Remediate":"#6ee7b7","Retire":"#9070a0"}
data_js = json.dumps({"programs": P, "r7c": R7C}, ensure_ascii=False, separators=(",", ":"))

extra = """
#wrap{flex:1;overflow:auto;padding:0 24px 20px;min-height:0}
table{width:100%;border-collapse:collapse;font-size:12px}
thead th{position:sticky;top:0;background:var(--bg2);text-align:left;padding:8px;font-size:9px;text-transform:uppercase;letter-spacing:.05em;color:var(--muted2);border-bottom:1px solid var(--line);z-index:5}
tbody td{padding:8px;border-bottom:1px solid rgba(224,1,152,.08);vertical-align:middle}
tbody tr:hover{background:rgba(224,1,152,.04)}
.rk{font-family:'Cascadia Code',monospace;font-size:16px;font-weight:900;color:var(--rose);width:34px;text-align:center}
.pn{font-family:'Cascadia Code','Consolas',monospace;font-size:12.5px;color:var(--ink);font-weight:700}
.pm{font-size:9px;color:var(--muted2);margin-top:2px}
.pbar{height:9px;background:rgba(255,255,255,.05);border-radius:5px;overflow:hidden;min-width:90px}
.pbar>i{display:block;height:100%;background:linear-gradient(90deg,var(--pink),var(--rose))}
.pv{font-family:'Cascadia Code',monospace;font-size:13px;font-weight:800;color:var(--pink)}
.drv{display:inline-block;font-size:8.5px;font-weight:700;padding:1px 6px;border-radius:3px;margin:1px 2px 1px 0;border:1px solid}
.d-reg{color:#fca5a5;border-color:#f8717155;background:rgba(248,113,113,.1)}
.d-hub{color:var(--sky);border-color:#87C3D355;background:rgba(135,195,211,.1)}
.d-s4{color:#fde047;border-color:#eab30855;background:rgba(234,179,8,.1)}
.d-cx{color:var(--rose);border-color:#DA7AB055;background:rgba(218,122,176,.1)}
.r7{display:inline-block;font-size:9px;font-weight:800;padding:2px 8px;border-radius:4px;border:1px solid}
.r7why{font-size:9px;color:var(--muted2);margin-top:3px;max-width:280px;line-height:1.4}
"""

body = """
<div id="fbar">
  <span class="pill on" data-r7="">Todos</span>
  <span class="pill" data-r7="Refactor">Refactor</span>
  <span class="pill" data-r7="Replatform">Replatform</span>
  <span class="pill" data-r7="Retain+Remediate">Retain</span>
  <span class="pill" data-r7="Retire">Retire</span>
  <span id="info"></span>
</div>
<div id="wrap"><table><thead><tr>
  <th>#</th><th>Programa</th><th>Prioridad</th><th>Drivers</th><th>7R + fundamento</th>
</tr></thead><tbody id="tb"></tbody></table></div>
"""

script = f"""
const D={data_js};
let f7='';
const esc=s=>String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
function render(){{
  let rows=D.programs.filter(p=>!f7||p.r7===f7);
  let h='';
  rows.forEach(p=>{{
    let drv='';
    if(p.reg) drv+=`<span class="drv d-reg" data-tip="${{p.reg}} regla(s) con señal regulatoria">⚖ Regulatorio</span>`;
    if(p.fan_in>=2) drv+=`<span class="drv d-hub" data-tip="${{p.fan_in}} programas leen tablas Z que este escribe">↔ Hub (${{p.fan_in}})</span>`;
    if(p.s4_tables) drv+=`<span class="drv d-s4" data-tip="${{p.s4_tables}} tablas con Simplification Item S/4">S/4 ×${{p.s4_tables}}</span>`;
    drv+=`<span class="drv d-cx" data-tip="Score de complejidad">Cx ${{p.complexity}}</span>`;
    const c=D.r7c[p.r7]||'#888';
    h+=`<tr><td class="rk">${{p.rank}}</td>`+
       `<td><div class="pn">${{esc(p.prog)}}</div><div class="pm">${{p.dom}} · ${{esc(p.dom_label)}} · ${{p.loc}} LOC · ${{p.tables}} tablas · ${{p.rules}} reglas</div></td>`+
       `<td><div style="display:flex;align-items:center;gap:8px"><div class="pbar"><i style="width:${{p.priority}}%"></i></div><span class="pv">${{p.priority}}</span></div></td>`+
       `<td>${{drv}}</td>`+
       `<td><span class="r7" style="border-color:${{c}}66;color:${{c}};background:${{c}}18">${{p.r7}}</span><div class="r7why">${{esc(p.r7_why)}}</div></td></tr>`;
  }});
  document.getElementById('tb').innerHTML=h;
  document.getElementById('info').textContent=`${{rows.length}} programas`;
}}
document.querySelectorAll('.pill[data-r7]').forEach(p=>p.addEventListener('click',()=>{{document.querySelectorAll('.pill[data-r7]').forEach(x=>x.classList.remove('on'));p.classList.add('on');f7=p.dataset.r7;render();}}));
render();
"""

OUT.write_text(S.page("Liverpool · Ranking de Prioridad", hero, body, extra, script), encoding="utf-8")
print(f"priority -> {OUT.name} ({round(OUT.stat().st_size/1024,1)} KB)")

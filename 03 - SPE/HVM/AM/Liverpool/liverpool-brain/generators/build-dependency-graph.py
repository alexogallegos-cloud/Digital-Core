#!/usr/bin/env python3
"""Liverpool — Grafo de Dependencias entre Programas (vía tablas Z compartidas).
Reads portal/data/program-metrics-liv.json → portal/dependency-graph-liv.html"""
import json
from pathlib import Path
import _liv_shared as S

HERE = Path(__file__).parent
DATA = HERE.parent / "portal" / "data" / "program-metrics-liv.json"
OUT  = HERE.parent / "portal" / "dependency-graph-liv.html"

d = json.loads(DATA.read_text(encoding="utf-8"))
P = d["programs"]
E = d["dependencies"]
progs = [p["prog"] for p in sorted(P, key=lambda x: x["prog"])]
n_coupled = len({e["from"] for e in E} | {e["to"] for e in E})
max_edge = max((e["n"] for e in E), default=1)

stats = (S.stat(len(progs), "Programas") + S.stat(len(E), "Dependencias", "pink") +
         S.stat(n_coupled, "Acoplados") + S.stat(max_edge, "Máx. tablas compartidas", "red"))
hero = S.hero(
    "Liverpool · SAP ECC → S/4HANA · Acoplamiento",
    "Grafo de Dependencias",
    "Dependencias programa→programa detectadas cuando un programa <b>escribe</b> una tabla Z "
    "que otro <b>lee</b> (flujo de datos write→read). La matriz revela los clústeres que deben "
    "migrar juntos: cortar una arista sin coordinar rompe el flujo del proceso de importaciones.",
    "SPE-AM-003 <em>›</em> Módulo Importaciones <em>›</em> Dependencias", "Acoplamiento", stats)

fan = {p["prog"]: (p["fan_in"], p["fan_out"]) for p in P}
data_js = json.dumps({"progs": progs, "edges": E, "fan": fan, "max": max_edge},
                     ensure_ascii=False, separators=(",", ":"))

extra = """
#wrap{flex:1;overflow:auto;padding:14px 24px 20px;min-height:0;display:flex;gap:24px;flex-wrap:wrap}
.mx{flex:1;min-width:520px}
table{border-collapse:separate;border-spacing:0;font-size:10px}
th.corner{text-align:right;padding:6px 8px;font-size:8.5px;text-transform:uppercase;color:var(--muted2);vertical-align:bottom}
th.rot{height:120px;width:30px;padding:0;vertical-align:bottom}
th.rot>div{transform:translateX(13px) rotate(-90deg);transform-origin:center;width:30px}
th.rot span{font-family:'Cascadia Code',monospace;font-size:8.5px;color:var(--sky);white-space:nowrap}
td.rl{font-family:'Cascadia Code',monospace;font-size:9.5px;color:var(--ink);white-space:nowrap;padding:3px 8px;text-align:right}
td.rl .fo{font-size:8px;color:var(--muted2);margin-left:4px}
td.c{width:30px;height:26px;text-align:center;border:1px solid rgba(224,1,152,.06)}
td.diag{background:rgba(255,255,255,.03)}
.cell{display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:4px;font-size:9px;font-weight:800;font-family:'Cascadia Code',monospace;color:#0d0408;cursor:default}
.caption{font-size:9.5px;color:var(--muted);margin-bottom:8px}
.side{width:320px;flex-shrink:0}
.side h3{font-size:10px;text-transform:uppercase;letter-spacing:.1em;color:var(--sky);margin-bottom:8px}
.ce{padding:7px 10px;border:1px solid var(--line);border-radius:8px;margin-bottom:6px;background:rgba(255,255,255,.02)}
.ce .ln{font-family:'Cascadia Code',monospace;font-size:10.5px;color:var(--ink)}
.ce .ln b{color:var(--pink)}
.ce .tl{font-size:8.5px;color:var(--muted2);margin-top:3px;line-height:1.4}
"""

body = '<div id="wrap"><div class="mx"><div class="caption">Fila = programa que <b>escribe</b> · Columna = programa que <b>lee</b> · celda = # tablas Z compartidas</div><div id="matrix"></div></div><div class="side"><h3>Acoplamientos más fuertes</h3><div id="edges"></div></div></div>'

script = f"""
const D={data_js};
const esc=s=>String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
const em={{}};
D.edges.forEach(e=>{{em[e.from+'|'+e.to]=e;}});
function heat(n){{const t=n/D.max;const r=Math.round(135+(224-135)*t),g=Math.round(195+(1-195)*t),b=Math.round(211+(152-211)*t);return `rgb(${{r}},${{g}},${{b}})`;}}
// matrix
let h='<table><thead><tr><th class="corner">escribe ↓ / lee →</th>';
D.progs.forEach(p=>h+=`<th class="rot"><div><span>${{esc(p)}}</span></div></th>`);
h+='</tr></thead><tbody>';
D.progs.forEach(rp=>{{
  const f=D.fan[rp]||[0,0];
  h+=`<tr><td class="rl">${{esc(rp)}}<span class="fo" data-tip="fan-out ${{f[1]}} · fan-in ${{f[0]}}">→${{f[1]}}</span></td>`;
  D.progs.forEach(cp=>{{
    if(rp===cp){{h+='<td class="c diag"></td>';return;}}
    const e=em[rp+'|'+cp];
    if(e){{h+=`<td class="c"><span class="cell" style="background:${{heat(e.n)}}" data-tip="${{esc(rp)}} → ${{esc(cp)}}\\n${{e.n}} tabla(s) Z: ${{esc(e.tables.join(', '))}}">${{e.n}}</span></td>`;}}
    else h+='<td class="c"></td>';
  }});
  h+='</tr>';
}});
h+='</tbody></table>';
document.getElementById('matrix').innerHTML=h;
// strongest edges
document.getElementById('edges').innerHTML=D.edges.slice(0,14).map(e=>
  `<div class="ce"><div class="ln"><b>${{esc(e.from)}}</b> → <b>${{esc(e.to)}}</b> · ${{e.n}} tabla(s)</div><div class="tl">${{esc(e.tables.join(', ').toUpperCase())}}</div></div>`).join('');
"""

OUT.write_text(S.page("Liverpool · Grafo de Dependencias", hero, body, extra, script), encoding="utf-8")
print(f"dependency -> {OUT.name} ({round(OUT.stat().st_size/1024,1)} KB)")

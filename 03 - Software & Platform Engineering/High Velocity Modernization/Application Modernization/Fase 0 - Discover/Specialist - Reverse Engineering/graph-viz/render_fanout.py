#!/usr/bin/env python3
"""
render_fanout.py — Application Modernization · visualizador de fanout-graph.

Wrapper sobre render_graph.py para el schema fanout-graph-schema.json.
Convierte fanout-graph.json al formato DATA del visualizador D3 y genera
el HTML self-contained.

Uso:
    python render_fanout.py --fanout <ruta/fanout-graph.json> [--out <salida.html>]

El HTML resultante funciona OFFLINE (D3 + logo Accenture embebidos).
Paleta: enabler=purple, PCI=blue, monolith-component=dark-gray, candidate-future=gray.
"""
import argparse, json, os, base64
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))

def load_asset(path, mode="r", encoding="utf-8"):
    if os.path.exists(path):
        if mode == "rb":
            with open(path, "rb") as f: return f.read()
        else:
            with open(path, encoding=encoding) as f: return f.read()
    return None

def get_logo_uri():
    paths = [
        os.path.join(HERE, "vendor", "Accenture_logo_white_letters.png"),
        os.path.join(HERE, "..", "..", "..", "..", "..", "..",
                     "Design - Studio", "logos", "Accenture_logo_white_letters.png"),
    ]
    for p in paths:
        data = load_asset(p, "rb")
        if data:
            return "data:image/png;base64," + base64.b64encode(data).decode()
    return ""

def get_d3():
    p = os.path.join(HERE, "vendor", "d3.v7.min.js")
    src = load_asset(p)
    if src: return src
    return 'document.write(\'<scr\'+\'ipt src="https://cdn.jsdelivr.net/npm/d3@7"></scr\'+\'ipt>\')'

# ── Paleta completa por tipo de servicio ──────────────────────────────────
TYPE_COLOR = {
    "monolith-component": "#374151",  # dark gray
    "migrated":           "#059669",  # green  — ya migrado
    "enabler":            "#A100FF",  # purple — en scope Wave 1-4
    "candidate":          "#9aa0ad",  # gray   — wave futura
    "bff":                "#0891b2",  # teal   — Backend for Frontend
    "saga":               "#d97706",  # amber  — Process Manager / Saga
    "event":              "#7c2d12",  # dark orange — Event Bus
    "cqrs":               "#059669",  # emerald — Read Models
    "cross-cutting":      "#6366f1",  # indigo — Cross-cutting obligatorios
    "connector":          "#db2777",  # pink   — Rail connectors
    "platform":           "#0891b2",  # teal   — Platform Engineering
}
PCI_COLOR   = "#175cd3"   # blue override for PCI nodes
SCOPE_COLOR = "#6B21A8"   # dark purple for enabler in-scope non-PCI
CRITICAL_COLOR = "#dc2626" # red for BIAN gap critical nodes

LAYER_DESC = {
    "infrastructure":  "Habilitadores — Infraestructura Aplicativa",
    "security":        "Habilitadores — Seguridad (PCI DSS)",
    "business":        "Dominios de Negocio",
    "presentation":    "Canales / BFF / Componentes fisicos",
    "orchestration":   "Sagas / Process Managers",
    "platform":        "Platform Engineering",
}

TYPE_LABEL = {
    "monolith-component": "Componente fisico del monolito",
    "migrated":           "Ya migrado a ECS Fargate",
    "enabler":            "Habilitador en scope (Wave 1-4)",
    "candidate":          "Candidato (Wave 5-6)",
    "bff":                "BFF / API Composition",
    "saga":               "Saga / Process Manager",
    "event":              "Event Bus / Domain Events",
    "cqrs":               "CQRS Read Model / Query Service",
    "cross-cutting":      "Cross-cutting (PCI, Audit, Rate Limiting)",
    "connector":          "Conector a Rail Regulado",
    "platform":           "Platform Engineering",
}

# ── HTML template ──────────────────────────────────────────────────────────
HTML = r"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Fanout Graph — Application Modernization</title>
<script>/*__D3__*/</script>
<style>
:root{--bg:#14142b;--bg2:#1A1A2E;--panel:#1f1f3a;--line:#2c2c50;
  --purple:#6B21A8;--magenta:#A100FF;--txt:#E8E8F0;--muted:#9a9ab5;
  --pci:#175cd3;--gray:#374151;--future:#9aa0ad;
  --scope-glow:rgba(161,0,255,.35);}
*{box-sizing:border-box}
html,body{margin:0;height:100%;background:var(--bg);color:var(--txt);
  font-family:"Segoe UI",system-ui,sans-serif;overflow:hidden}
header{display:flex;align-items:center;gap:18px;padding:10px 18px;
  background:linear-gradient(90deg,#1A1A2E,#241a3a);border-bottom:1px solid var(--line)}
header img{height:22px}
header .mark{font-weight:700;font-size:14px}
header .mark b{color:var(--magenta)}
header .sub{font-size:11px;color:var(--muted)}
.scope-pill{display:inline-block;background:linear-gradient(90deg,var(--magenta),var(--purple));
  color:#fff;font-size:10px;font-weight:800;padding:3px 12px;border-radius:20px;
  margin-left:10px;letter-spacing:.5px;box-shadow:0 0 12px var(--scope-glow)}
.badge{font-size:10px;font-weight:700;padding:2px 7px;border-radius:20px;margin-left:4px;display:inline-block}
.badge.a{background:rgba(161,0,255,.2);color:var(--magenta);border:1px solid var(--magenta)}
.badge.b{background:rgba(23,92,211,.2);color:var(--pci);border:1px solid var(--pci)}
.badge.c{background:rgba(154,160,173,.15);color:var(--future);border:1px solid var(--future)}
.badge.bff{background:rgba(8,145,178,.2);color:#0891b2;border:1px solid #0891b2}
.badge.saga{background:rgba(217,119,6,.2);color:#d97706;border:1px solid #d97706}
.badge.ev{background:rgba(124,45,18,.2);color:#9a3412;border:1px solid #7c2d12}
.badge.cqrs{background:rgba(5,150,105,.2);color:#059669;border:1px solid #059669}
.badge.cc{background:rgba(99,102,241,.2);color:#6366f1;border:1px solid #6366f1}
.badge.conn{background:rgba(219,39,119,.2);color:#db2777;border:1px solid #db2777}
.layout{display:flex;height:calc(100% - 49px)}
aside{width:290px;flex:0 0 290px;background:var(--panel);border-right:1px solid var(--line);
  padding:14px;overflow-y:auto;font-size:12px}
aside h3{margin:12px 0 6px;font-size:10px;text-transform:uppercase;letter-spacing:.6px;
  color:var(--muted);font-weight:600}
aside h3:first-child{margin-top:0}
.scope-banner{background:linear-gradient(135deg,rgba(161,0,255,.15),rgba(107,33,168,.2));
  border:1px solid var(--magenta);border-radius:8px;padding:10px 12px;margin-bottom:12px}
.scope-banner .t{font-weight:800;color:var(--magenta);font-size:12px;margin-bottom:4px}
.scope-banner .s{font-size:10.5px;color:#c4b5fd;line-height:1.5}
.out-banner{background:rgba(154,160,173,.07);border:1px solid #374151;
  border-radius:8px;padding:8px 12px;margin-bottom:8px;font-size:10.5px;color:var(--muted)}
.legend-row{display:flex;align-items:center;gap:8px;margin:3px 0}
.dot{width:10px;height:10px;border-radius:50%;flex:0 0 10px}
.node-info{background:var(--bg2);border-radius:8px;padding:10px;margin-top:8px;font-size:11px;display:none}
.node-info.vis{display:block}
.ni-title{font-weight:700;font-size:12.5px;color:var(--txt);margin-bottom:5px}
.ni-badge{display:inline-block;font-size:9px;font-weight:700;padding:1px 7px;border-radius:20px;margin-bottom:6px}
.ni-in{background:rgba(161,0,255,.25);color:var(--magenta);border:1px solid var(--magenta)}
.ni-out{background:rgba(55,65,81,.4);color:#9ca3af;border:1px solid #374151}
.ni-row{display:flex;justify-content:space-between;margin:3px 0;color:var(--muted)}
.ni-row b{color:var(--txt)}
.wave-card{background:var(--bg2);border-radius:6px;padding:8px;margin:5px 0;
  border-left:3px solid var(--magenta);font-size:10.5px}
.wave-card.pci{border-left-color:var(--pci)}
.wave-card.w1{border-left-color:#A100FF}.wave-card.w2{border-left-color:#7c3aed}
.wave-card.w3{border-left-color:#175cd3}.wave-card.w4{border-left-color:#6B21A8}
.wave-card.w5,.wave-card.w6{border-left-color:#374151}
.wave-title{font-weight:700;color:var(--txt);margin-bottom:2px}
svg{flex:1;overflow:hidden}
.node circle{cursor:pointer}
.node.in-scope circle{stroke-width:3;filter:drop-shadow(0 0 6px var(--scope-glow))}
.node.out-scope circle{stroke-width:1;opacity:.45}
.node.out-scope text{opacity:.4}
.node.monolith circle{stroke-width:2;opacity:.7}
.node text{font-size:9.5px;fill:var(--txt);pointer-events:none;text-anchor:middle}
.node.in-scope text{font-size:10.5px;font-weight:700;fill:#e9d5ff;opacity:1}
.link{stroke-opacity:.3;fill:none}
.link.in-scope-link{stroke-opacity:.7}
.link.consumes{stroke:#A100FF;stroke-width:1.5}
.link.contains{stroke:#4ade80;stroke-width:1;stroke-dasharray:4}
.link.depends-on{stroke:#facc15;stroke-width:1;stroke-dasharray:2}
.scope-label{font-size:11px;font-weight:800;fill:var(--magenta);text-anchor:middle;
  letter-spacing:1px;text-transform:uppercase}
.tooltip{position:absolute;background:var(--panel);border:1px solid var(--line);
  border-radius:6px;padding:8px 12px;font-size:11px;pointer-events:none;
  color:var(--txt);max-width:280px;display:none}
.scope-ring{fill:none;stroke:var(--magenta);stroke-width:2;stroke-dasharray:8 4;opacity:.3}
</style>
</head>
<body>
<header>
  <img src="/*__LOGO__*/" alt="Accenture">
  <div>
    <div class="mark">accenture<b>&gt;</b> Application Modernization &mdash; Descomposicion de Monolito
      <span class="scope-pill">&#x25CF; ALCANCE: 9 habilitadores</span>
    </div>
    <div class="sub" id="subtitle"></div>
  </div>
</header>
<div class="layout">
<aside id="sidebar">
  <div class="scope-banner">
    <div class="t">&#x25B6; ALCANCE DE ESTE PROYECTO</div>
    <div class="s">9 sistemas habilitadores (capa horizontal). El resto son waves futuras o ya migrados &mdash; NO forman parte del contrato actual.</div>
  </div>
  <h3>EN SCOPE &mdash; Wave 1 a 4</h3>
  <div class="legend-row"><div class="dot" style="background:#A100FF;box-shadow:0 0 5px #A100FF"></div><b>Enabler Infra Aplicativa</b></div>
  <div class="legend-row"><div class="dot" style="background:#175cd3;box-shadow:0 0 5px #175cd3"></div><b>Enabler Seguridad / PCI</b></div>
  <div class="out-banner">Todo lo demas = fuera de scope</div>
  <h3>FUERA DE SCOPE (referencia)</h3>
  <div class="legend-row"><div class="dot" style="background:#374151;opacity:.6"></div>Componente fisico monolito</div>
  <div class="legend-row"><div class="dot" style="background:#059669;opacity:.6"></div>Ya migrado</div>
  <div class="legend-row"><div class="dot" style="background:#dc2626;opacity:.6"></div>BIAN gap critico (wave futura)</div>
  <div class="legend-row"><div class="dot" style="background:#7c3aed;opacity:.6"></div>Candidato W5-6</div>
  <div class="legend-row"><div class="dot" style="background:#0891b2;opacity:.6"></div>BFF / Platform Eng.</div>
  <div class="legend-row"><div class="dot" style="background:#d97706;opacity:.6"></div>Saga / Process Mgr</div>
  <div class="legend-row"><div class="dot" style="background:#7c2d12;opacity:.6"></div>Event Bus</div>
  <div class="legend-row"><div class="dot" style="background:#059669;opacity:.6"></div>CQRS Read Model</div>
  <div class="legend-row"><div class="dot" style="background:#6366f1;opacity:.6"></div>Cross-cutting</div>
  <div class="legend-row"><div class="dot" style="background:#db2777;opacity:.6"></div>Rail Connector</div>
  <h3>Edges</h3>
  <div class="legend-row"><div style="width:20px;height:2px;background:#A100FF"></div>consumes</div>
  <div class="legend-row"><div style="width:20px;height:2px;background:#4ade80;opacity:.6"></div>contains</div>
  <div class="legend-row"><div style="width:20px;height:2px;background:#facc15"></div>depends-on</div>
  <h3>Waves de extraccion</h3>
  <div id="wave-cards"></div>
  <h3>Nodos totales <span id="total-count" style="color:var(--magenta)"></span></h3>
  <div id="type-counts"></div>
  <h3>Nodo seleccionado</h3>
  <div class="node-info" id="node-info"></div>
</aside>
<svg id="svg"></svg>
</div>
<div class="tooltip" id="tip"></div>

<script>
const D=/*__DATA__*/;
const nodes=D.nodes.map(d=>({...d}));
const edges=D.edges.map(d=>({...d}));
const waves=D.waves||[];
const reg=D.regression_scope||{};
const meta=D.meta||{};
const IN_SCOPE_IDS=new Set(nodes.filter(n=>n.in_scope).map(n=>n.id));

// subtitle
const sub=document.getElementById('subtitle');
sub.textContent=`${meta.monolith_name||'monolito'} · ${meta.stack||''} · ${meta.total_tables||'?'} tablas · ${meta.peak_tps||'?'} TPS pico (${meta.peak_tps_location||''})`;
// total count
const tc=document.getElementById('total-count');
if(tc) tc.textContent=`${nodes.length} nodos · ${IN_SCOPE_IDS.size} en scope`;

// wave cards
const wc=document.getElementById('wave-cards');
waves.forEach(w=>{
  const div=document.createElement('div');
  const wnum=w.id<=4?'w'+w.id:'w5';
  div.className='wave-card '+wnum+(w.pci_infra_ready?' pci':'');
  const inScope=w.nodes.filter(n=>IN_SCOPE_IDS.has(n));
  const tag=inScope.length>0?` <span style="color:#A100FF;font-weight:800">[EN SCOPE]</span>`:'';
  div.innerHTML=`<div class="wave-title">Wave ${w.id}: ${w.name.split('—')[1]||w.name}${tag}</div><div style="color:#9a9ab5;font-size:10px">${w.quarter||''}</div><div style="margin-top:3px;font-size:10px">${w.nodes.slice(0,4).join(' · ')}${w.nodes.length>4?` +${w.nodes.length-4}`:''}</div>`;
  wc.appendChild(div);
});

// type counts
const typeCounts={};nodes.forEach(n=>{typeCounts[n.type]=(typeCounts[n.type]||0)+1;});
const tcDiv=document.getElementById('type-counts');
if(tcDiv){
  const TL={'monolith-component':'Monolito (fisico)','migrated':'Ya migrados','enabler':'Enablers (SCOPE)','candidate':'Candidatos','bff':'BFF','saga':'Sagas','event':'Events','cqrs':'CQRS','cross-cutting':'Cross-cutting','connector':'Connectors','platform':'Platform'};
  const TC={'monolith-component':'#374151','migrated':'#059669','enabler':'#A100FF','candidate':'#9aa0ad','bff':'#0891b2','saga':'#d97706','event':'#7c2d12','cqrs':'#059669','cross-cutting':'#6366f1','connector':'#db2777','platform':'#0891b2'};
  Object.entries(typeCounts).sort((a,b)=>b[1]-a[1]).forEach(([t,c])=>{
    const isScope=t==='enabler';
    const row=document.createElement('div');
    row.style.cssText=`display:flex;justify-content:space-between;margin:2px 0;color:${isScope?'#e9d5ff':'#9a9ab5'};${isScope?'font-weight:700':''}`;
    row.innerHTML=`<span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:${TC[t]||'#9aa0ad'};margin-right:5px${isScope?';box-shadow:0 0 4px '+TC[t]:''}"></span>${TL[t]||t}${isScope?' ★':''}</span><b style="color:${isScope?'#A100FF':'#E8E8F0'}">${c}</b>`;
    tcDiv.appendChild(row);
  });
  const total=document.createElement('div');
  total.style.cssText='display:flex;justify-content:space-between;margin:6px 0 0;border-top:1px solid #2c2c50;padding-top:4px;font-weight:700;color:#E8E8F0';
  total.innerHTML=`<span>TOTAL</span><b style="color:#A100FF">${nodes.length}</b>`;
  tcDiv.appendChild(total);
}

// D3 force simulation
const svg=d3.select('#svg');
const W=document.getElementById('svg').clientWidth||900;
const H=document.getElementById('svg').clientHeight||600;
svg.attr('viewBox',`0 0 ${W} ${H}`);

const g=svg.append('g');
svg.call(d3.zoom().scaleExtent([.15,5]).on('zoom',e=>g.attr('transform',e.transform)));

// Scope ring (drawn before nodes so it's behind)
const scopeRing=g.append('circle')
  .attr('class','scope-ring')
  .attr('cx',W/2).attr('cy',H/2).attr('r',140);

// Scope label
const scopeLabelEl=g.append('text')
  .attr('class','scope-label')
  .attr('x',W/2).attr('y',H/2-150)
  .text('ALCANCE DEL PROYECTO');

// Node radius: in-scope nodes larger, out-scope smaller
const maxBR=d3.max(nodes,d=>d.fan_in||0)||1;
const r=d=>{
  if(d.in_scope) return 8+Math.sqrt((d.fan_in||0)/maxBR)*26;
  if(d.type==='monolith-component') return 10;
  return 4+Math.sqrt((d.fan_in||0)/maxBR)*10;
};

// Charge stronger for in-scope to keep them central
const charge=d=>{
  if(d.in_scope) return -300;
  if(d.type==='monolith-component') return -250;
  return -80;
};

const sim=d3.forceSimulation(nodes)
  .force('link',d3.forceLink(edges).id(d=>d.id).distance(d=>{
    const sIn=IN_SCOPE_IDS.has(d.source.id||d.source);
    const tIn=IN_SCOPE_IDS.has(d.target.id||d.target);
    if(sIn&&tIn) return 60;
    if(sIn||tIn) return 100;
    return 130+d.weight*.3;
  }))
  .force('charge',d3.forceManyBody().strength(charge))
  .force('center',d3.forceCenter(W/2,H/2))
  .force('radial-in',d3.forceRadial(0,W/2,H/2).strength(d=>d.in_scope?0.15:0))
  .force('radial-out',d3.forceRadial(280,W/2,H/2).strength(d=>(!d.in_scope&&d.type!=='monolith-component')?0.03:0))
  .force('collision',d3.forceCollide(d=>r(d)+4));

const link=g.append('g')
  .selectAll('line')
  .data(edges)
  .join('line')
  .attr('class',d=>{
    const sIn=IN_SCOPE_IDS.has(d.source.id||d.source);
    const tIn=IN_SCOPE_IDS.has(d.target.id||d.target);
    return `link ${d.type||'consumes'} ${(sIn||tIn)?'in-scope-link':''}`;
  });

const node=g.append('g')
  .selectAll('g')
  .data(nodes)
  .join('g')
  .attr('class',d=>{
    if(d.in_scope) return 'node in-scope';
    if(d.type==='monolith-component') return 'node monolith';
    return 'node out-scope';
  })
  .call(d3.drag()
    .on('start',(e,d)=>{if(!e.active)sim.alphaTarget(.3).restart();d.fx=d.x;d.fy=d.y})
    .on('drag',(e,d)=>{d.fx=e.x;d.fy=e.y})
    .on('end',(e,d)=>{if(!e.active)sim.alphaTarget(0);d.fx=null;d.fy=null}));

node.append('circle')
  .attr('r',r)
  .attr('fill',d=>d.color||'#9aa0ad')
  .attr('stroke',d=>d.in_scope?'rgba(255,255,255,.9)':d.type==='monolith-component'?'#6b7280':'rgba(255,255,255,.2)')
  .on('click',(e,d)=>showInfo(d))
  .on('mouseover',(e,d)=>showTip(e,d))
  .on('mouseout',()=>document.getElementById('tip').style.display='none');

node.append('text')
  .attr('dy',d=>r(d)+11)
  .text(d=>{
    const max=d.in_scope?22:16;
    return d.label.length>max?d.label.slice(0,max-1)+'…':d.label;
  });

sim.on('tick',()=>{
  link.attr('x1',d=>d.source.x).attr('y1',d=>d.source.y)
      .attr('x2',d=>d.target.x).attr('y2',d=>d.target.y);
  node.attr('transform',d=>`translate(${d.x},${d.y})`);
  // update scope ring to center of in-scope nodes
  const ins=nodes.filter(n=>n.in_scope);
  if(ins.length){
    const cx=ins.reduce((s,n)=>s+n.x,0)/ins.length;
    const cy=ins.reduce((s,n)=>s+n.y,0)/ins.length;
    const maxD=d3.max(ins,n=>Math.sqrt((n.x-cx)**2+(n.y-cy)**2))+30;
    scopeRing.attr('cx',cx).attr('cy',cy).attr('r',maxD);
    scopeLabelEl.attr('x',cx).attr('y',cy-maxD-8);
  }
});

const tip=document.getElementById('tip');
function showTip(e,d){
  tip.style.display='block';
  tip.style.left=(e.pageX+12)+'px';
  tip.style.top=(e.pageY-10)+'px';
  const br=reg[d.id]||{};
  tip.innerHTML=`<b>${d.label}</b><br>Tipo: ${d.type}<br>Blast radius: ${d.fan_in||0} procesos<br>Fan-out repos: ${d.fan_out||0}<br>${br.total_processes?`Regresión: ${br.total_processes} procesos`:''}`;
}

function showInfo(d){
  const ni=document.getElementById('node-info');
  ni.classList.add('vis');
  const br=reg[d.id]||{};
  const scopeBadge=d.in_scope
    ?'<span class="ni-badge ni-in">&#x25CF; EN SCOPE — Wave '+d.wave+'</span>'
    :'<span class="ni-badge ni-out">&#x25CB; FUERA DE SCOPE'+(d.wave?' — Wave '+d.wave:'')+' </span>';
  ni.innerHTML=`<div class="ni-title">${d.label}</div>${scopeBadge}
    <div class="ni-row"><span>Tipo</span><b>${d.type}</b></div>
    <div class="ni-row"><span>Dominio</span><b>${d.domain||'—'}</b></div>
    <div class="ni-row"><span>Complejidad</span><b>${d.complexity||'—'}</b></div>
    ${d.fan_in?`<div class="ni-row"><span>Blast radius</span><b>${d.fan_in} procesos</b></div>`:''}
    ${d.fan_out?`<div class="ni-row"><span>Fan-out repos</span><b>${d.fan_out}</b></div>`:''}
    ${d.pci?'<div class="ni-row"><span>PCI/CDE</span><b style="color:#175cd3">🔒 Requiere CDE</b></div>':''}
    ${d.seam?`<div class="ni-row"><span>Costura</span><b>${d.seam}</b></div>`:''}
    ${br.total_processes?`<div class="ni-row"><span>Regresion</span><b>${br.total_processes} procesos (prioridad ${br.priority})</b></div>`:''}
    ${d.notes?`<div style="margin-top:6px;font-size:10px;color:#9a9ab5;line-height:1.4">${d.notes}</div>`:''}`;
}
</script>
</body>
</html>"""

def main():
    ap = argparse.ArgumentParser(description="render_fanout.py — Application Modernization fanout graph visualizer")
    ap.add_argument("--fanout", required=True, help="Path to fanout-graph.json")
    ap.add_argument("--out", default=None, help="Output HTML path (default: same dir as input)")
    args = ap.parse_args()

    fanout_path = args.fanout
    out_path = args.out or fanout_path.replace(".json", "-view.html")

    with open(fanout_path, encoding="utf-8") as f:
        FG = json.load(f)

    nodes = []
    for n in FG["nodes"]:
        # Priority: explicit color > PCI override > scope override > type default
        explicit = n.get("color")
        ntype    = n.get("type", "candidate")
        if explicit and explicit != TYPE_COLOR.get(ntype, "#9aa0ad"):
            col = explicit  # node has a specific override (e.g. BIAN critical red)
        elif n.get("pci_in_scope"):
            col = PCI_COLOR
        elif ntype == "enabler" and n.get("in_scope"):
            col = SCOPE_COLOR
        else:
            col = TYPE_COLOR.get(ntype, "#9aa0ad")
        nodes.append({
            "id":        n["id"],
            "label":     n.get("label", n["id"]),
            "type":      n.get("type", "candidate"),
            "domain":    n.get("layer", "business"),
            "color":     col,
            "in_scope":  n.get("in_scope", False),
            "pci":       n.get("pci_in_scope", False),
            "fan_in":    n.get("blast_radius", 0),
            "fan_out":   n.get("fan_out_repos", 0),
            "complexity": n.get("complexity", ""),
            "seam":      n.get("seam_strategy", ""),
            "wave":      n.get("extraction_wave", 0),
        })

    edges = []
    for e in FG["edges"]:
        edges.append({
            "source":     e["source"],
            "target":     e["target"],
            "weight":     e.get("weight", 1),
            "type":       e.get("type", "consumes"),
            "confidence": e.get("confidence", "inferred"),
        })

    DATA = {
        "nodes": nodes,
        "edges": edges,
        "waves": FG.get("waves", []),
        "regression_scope": FG.get("regression_scope", {}),
        "meta": FG.get("meta", {}),
    }

    logo  = get_logo_uri()
    d3src = get_d3()
    html  = (HTML
             .replace("/*__DATA__*/", json.dumps(DATA, ensure_ascii=False))
             .replace("/*__LOGO__*/", logo)
             .replace("/*__D3__*/", d3src))

    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)

    n_en  = sum(1 for n in nodes if n["type"] == "enabler")
    n_can = sum(1 for n in nodes if n["type"] == "candidate")
    n_mon = sum(1 for n in nodes if n["type"] == "monolith-component")
    top   = max(nodes, key=lambda n: n["fan_in"])
    print(f"OK · {out_path}")
    print(f"   nodos={len(nodes)} (monolito={n_mon} enablers={n_en} candidatos={n_can})")
    print(f"   edges={len(edges)}")
    print(f"   top blast_radius: {top['label']} ({top['fan_in']} procesos)")

if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
render_graph.py — Application Modernization · visualizador de grafo de dependencias.

Adaptado de Mainframe Modernization / Specialist - Reverse Engineering.
Renderiza DOS tipos de grafo:

  1. dependency-graph.json  (esquema Mainframe RE — nodos = modulos, edges = llamadas)
     Uso: python render_graph.py --graph <dependency-graph.json> [--out <salida.html>]

  2. fanout-graph.json  (esquema Application Modernization — nodos = monolith-components
     + candidates + enablers, edges = consumes / contains / depends-on)
     Uso: python render_graph.py --fanout <fanout-graph.json> [--out <salida.html>]

OFFLINE: D3 inline + logo Accenture base64. Sin CDN.
Paleta Accenture (chrome). Enablers en purpura, PCI en azul, candidatos futuros en gris.

Ademas del schema de Mainframe RE, soporta el fanout-graph-schema.json definido en:
  schemas/fanout-graph-schema.json

Producido por: Digital Core · 03 S&PE · High Velocity Modernization · Application Modernization
"""
import json
import os
from collections import defaultdict

HTML_TEMPLATE = r"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Dependency graph</title>
<script>/*__D3__*/</script>
<style>
  :root{
    --bg:#14142b; --bg2:#1A1A2E; --panel:#1f1f3a; --line:#2c2c50;
    --purple:#6B21A8; --magenta:#A100FF; --txt:#E8E8F0; --muted:#9a9ab5;
    --cycle:#FF7A45; --hl:#FFD166; --dead:#FF5C7A;
  }
  *{box-sizing:border-box}
  html,body{margin:0;height:100%;background:var(--bg);color:var(--txt);
    font-family:"Segoe UI",system-ui,sans-serif;overflow:hidden}
  header{display:flex;align-items:center;gap:18px;padding:10px 18px;
    background:linear-gradient(90deg,#1A1A2E,#241a3a);border-bottom:1px solid var(--line)}
  header .mark{font-weight:700;font-size:15px;letter-spacing:.3px}
  header .mark b{color:var(--magenta)}
  header .stat{font-size:12px;color:var(--muted)}
  header .stat b{color:var(--txt);font-weight:600}
  .layout{display:flex;height:calc(100% - 49px)}
  aside{width:268px;flex:0 0 268px;background:var(--panel);border-right:1px solid var(--line);
    padding:14px;overflow-y:auto;font-size:12.5px}
  aside h3{margin:14px 0 7px;font-size:11px;text-transform:uppercase;letter-spacing:.6px;
    color:var(--muted);font-weight:600}
  aside h3:first-child{margin-top:0}
  .row{display:flex;align-items:center;gap:8px;margin:5px 0;cursor:pointer}
  .row input{accent-color:var(--magenta)}
  select,input[type=text]{width:100%;background:var(--bg2);color:var(--txt);
    border:1px solid var(--line);border-radius:6px;padding:6px 8px;font-size:12.5px}
  .legend .row{cursor:default}
  .layer-row{align-items:flex-start;margin:7px 0}
  .layer-txt{display:flex;flex-direction:column;line-height:1.25}
  .layer-code{font-weight:600}
  .ldesc{font-size:10.5px;color:var(--muted)}
  .dot{width:11px;height:11px;border-radius:50%;flex:0 0 11px}
  .sq{width:11px;height:11px;flex:0 0 11px;transform:rotate(45deg)}
  main{flex:1;position:relative;background:#000}
  svg{width:100%;height:100%;display:block;background:#000}
  .detail{position:absolute;right:14px;top:14px;width:250px;background:rgba(31,31,58,.96);
    border:1px solid var(--line);border-radius:9px;padding:13px;font-size:12.5px;
    box-shadow:0 8px 28px rgba(0,0,0,.4);display:none}
  .detail h4{margin:0 0 8px;font-size:14px;color:var(--magenta);word-break:break-all}
  .detail .k{color:var(--muted)}
  .srclink{display:inline-block;margin:2px 0 8px;font-size:12px;color:var(--magenta);text-decoration:none;border:1px solid rgba(161,0,255,.4);border-radius:6px;padding:3px 9px}
  .srclink:hover{background:rgba(161,0,255,.15)}
  .detail table{width:100%;border-collapse:collapse}
  .detail td{padding:2px 0;vertical-align:top}
  .chip{display:inline-block;background:var(--bg2);border:1px solid var(--line);
    border-radius:5px;padding:1px 6px;margin:2px 3px 0 0;font-size:11px}
  .note{font-size:11px;color:var(--muted);line-height:1.5;margin-top:6px}
  .pill{display:inline-block;padding:1px 7px;border-radius:10px;font-size:11px;
    background:rgba(161,0,255,.16);color:#d8b6ff;border:1px solid rgba(161,0,255,.35)}
  node{cursor:pointer}
  .lbl{font-size:9px;fill:var(--txt);pointer-events:none;text-shadow:0 1px 3px #000}
  header .logo{height:26px;width:auto;display:block;flex:0 0 auto}
  header .sep{width:1px;height:26px;background:var(--line);flex:0 0 auto}
  #help{margin-left:6px;width:24px;height:24px;border-radius:50%;border:1px solid var(--line);
    background:var(--bg2);color:var(--txt);cursor:pointer;font-weight:700;font-size:13px}
  #help:hover{border-color:var(--magenta);color:var(--magenta)}
  .backdrop{position:absolute;inset:0;background:rgba(8,8,20,.74);display:flex;
    align-items:center;justify-content:center;z-index:30}
  .modal{width:min(660px,92%);max-height:88%;overflow-y:auto;background:var(--panel);
    border:1px solid var(--line);border-radius:14px;padding:24px 28px;
    box-shadow:0 20px 60px rgba(0,0,0,.6)}
  .modal .logo{height:24px;margin-bottom:14px}
  .modal h2{margin:0 0 4px;font-size:19px}
  .modal h2 .accent{color:var(--magenta)}
  .modal .sub{color:var(--muted);font-size:12.5px;margin-bottom:14px}
  .modal p{font-size:13px;line-height:1.62;margin:9px 0}
  .modal .grid{display:grid;grid-template-columns:auto 1fr;gap:6px 14px;font-size:12.5px;
    margin:14px 0;background:var(--bg2);border:1px solid var(--line);border-radius:9px;padding:12px 14px}
  .modal .grid b{color:var(--magenta);text-align:right}
  .modal ul{margin:8px 0;padding-left:18px;font-size:12.5px;line-height:1.6}
  .modal kbd{background:var(--bg2);border:1px solid var(--line);border-radius:4px;padding:0 5px;
    color:var(--hl)}
  .modal .close{margin-top:18px;background:var(--magenta);color:#fff;border:none;
    border-radius:8px;padding:10px 20px;font-size:13px;cursor:pointer;font-weight:600}
  .modal .close:hover{background:#b733ff}
  .modal.code{width:min(920px,95%);text-align:left}
  pre.src{background:#0b0b16;border:1px solid var(--line);border-radius:8px;padding:14px 16px;
          overflow:auto;max-height:68vh;font-family:'Cascadia Code',Consolas,monospace;
          font-size:12px;line-height:1.45;color:#cfe3ff;white-space:pre;margin:8px 0 0}
  .srcbtn{display:inline-block;margin:2px 0 8px;font-size:12px;color:var(--magenta);cursor:pointer;
          border:1px solid rgba(161,0,255,.4);border-radius:6px;padding:3px 9px;background:none;font-family:inherit}
  .srcbtn:hover{background:rgba(161,0,255,.15)}
</style>
</head>
<body>
<header>
  <img class="logo" src="/*__LOGO__*/" alt="Accenture">
  <div class="sep"></div>
  <div class="mark" id="m-mark">dependency graph</div>
  <button id="help" title="About this case">?</button>
  <div class="stat">Nodes <b id="s-n"></b></div>
  <div class="stat">Edges <b id="s-e"></b></div>
  <div class="stat">Top hub <b id="s-h"></b></div>
  <div class="stat">SCCs <b id="s-c"></b></div>
  <div class="stat">Dead <b id="s-d"></b></div>
</header>
<div class="layout">
  <aside>
    <h3>Layers</h3>
    <div id="layers"></div>
    <h3>Highlight</h3>
    <label class="row"><input type="checkbox" id="t-hubs" checked> Hubs (high fan-in)</label>
    <div class="ldesc" style="margin:-3px 0 5px 24px">white border = utility hub · <span style="color:#FFD166">gold = business hub</span></div>
    <label class="row"><input type="checkbox" id="t-cyc"> Cycles (SCCs)</label>
    <label class="row"><input type="checkbox" id="t-dead"> Dead clusters</label>
    <label class="row"><input type="checkbox" id="t-lbl" checked> Hub labels</label>
    <h3>Color by</h3>
    <select id="cmode">
      <option value="domain">Domain (community)</option>
      <option value="access">Access: inquiry vs update</option>
    </select>
    <h3>Shared-DTO coupling layer</h3>
    <select id="cpy"><option value="">— none —</option></select>
    <div class="note" id="cpy-note">The hidden hairball: classes that share a
      mutable DTO/entity are coupled by data even if they never call each other.</div>
    <h3>Search class</h3>
    <input type="text" id="search" placeholder="e.g. TokenizationService / JsonUtils">
    <h3>Domains</h3>
    <div class="legend" id="legend"></div>
    <h3>Data access</h3>
    <div class="legend" id="legend-access"></div>
  </aside>
  <main>
    <svg></svg>
    <div class="detail" id="detail"></div>
  </main>
</div>

<div class="backdrop" id="backdrop">
  <div class="modal">
    <img class="logo" src="/*__LOGO__*/" alt="Accenture">
    <h2><span class="accent">&gt;</span> <span id="m-title"></span> — what are you looking at?</h2>
    <div class="sub">Dependency graph of a Java monolith · <b>each node is a class</b>, each edge a call</div>
    <p><b>Why does it look like a cloud?</b> A real Java EE / Spring monolith is <b>not</b> a clean tree of boxes and arrows. It's a <i>hairball</i>: hundreds of classes where everything touches everything through shared static utilities and common mutable DTOs. That density is exactly where the pain —and the risk— of a modernization project lives. This view exposes the real topology: hubs, cycles, communities and couplings.</p>
    <div class="grid">
      <b id="m-nodes"></b><span>classes (graph nodes)</span>
      <b id="m-edges"></b><span>call dependencies (edges)</span>
      <b id="m-hub"></b><span>highest fan-in hub (called by hundreds)</span>
      <b id="m-cyc"></b><span>cycles — circular dependencies between @Service beans</span>
      <b id="m-dead"></b><span>unreachable nodes — likely dead code</span>
      <b id="m-cpy"></b><span>shared DTOs/entities — data coupling</span>
      <b id="m-acc"></b><span>read-only / update classes (CQRS)</span>
    </div>
    <p><b>What each control on the left panel shows:</b></p>
    <ul>
      <li><b>Hubs</b> — the few classes called by hundreds. Changing one impacts half the system: maximum <i>blast radius</i>. White border = static utility; gold = business hub (the 9 enablers).</li>
      <li><b>Cycles (SCCs)</b> — circular <code>@Service</code> dependencies (often patched with <code>@Lazy</code>). With cycles there is no topological order, so <b>there is no obvious "extraction order"</b>.</li>
      <li><b>Dead clusters</b> — subsystems nobody calls anymore but still packaged in the WAR: candidates to retire (and a risk if migrated by mistake).</li>
      <li><b>Color by access</b> — distinguishes <b>read-only</b> classes (teal) from <b>update</b> ones (writes, amber). Derived from the call closure: a read-only class never reaches a write. Read-only ones migrate <b>early and low-risk</b> (CQRS, read replica, cache); update ones are the hard transactional core (ACID, regulatory).</li>
      <li><b>Shared-DTO coupling layer</b> — the <b>hidden hairball</b>. Select a shared DTO (e.g. <kbd id="m-topcpy">—</kbd>): you'll see classes coupled by data <u>without a single call arrow</u> between them, sometimes across domains.</li>
      <li><b>Click a node</b> — highlights and <b>names its neighbors</b> (who it calls in amber, who calls it in teal); click the background to clear.</li>
    </ul>
    <p style="color:var(--muted);font-size:12px"><b>Takeaway:</b> planning a Strangler Fig by looking only at the call graph <b>fails</b>, because data coupling (shared DTOs / tables) is invisible there. Navigate with <kbd>scroll</kbd> to zoom and drag to pan.</p>
    <button class="close" id="closeModal">Explore the graph</button>
  </div>
</div>
<div class="backdrop" id="srcback" style="display:none">
  <div class="modal code">
    <h2><span class="accent">&gt;</span> <span id="src-title"></span> — source code</h2>
    <div class="sub" id="src-sub">generated skeleton · COPY = copybook coupling · CALL = graph edges</div>
    <pre class="src" id="src-pre"></pre>
    <button class="close" id="closeSrc">Close</button>
  </div>
</div>
<script>
const DATA = /*__DATA__*/;
const COLOR = DATA.color;                 // dominio -> color (derivado de los datos)
const DOMS = Object.keys(COLOR);
const LAYERS = DATA.layers;               // capas presentes en orden canónico
const ACCESS_COLOR = {read:"#4EC2C0", update:"#E0A458", none:"#555570"};
const ACCESS_LABEL = {read:"inquiry (read-only)", update:"update (writes)", none:"no data access"};
let colorMode = "domain";
function nodeFill(d){
  return colorMode==="access" ? (ACCESS_COLOR[d.access]||"#888") : (COLOR[d.domain]||"#888");
}

DATA.stats && (()=> {
  document.getElementById("s-n").textContent = DATA.stats.nodes;
  document.getElementById("s-e").textContent = DATA.stats.edges;
  document.getElementById("s-h").textContent = DATA.stats.top_hub+" ("+DATA.stats.top_hub_fanin+")";
  document.getElementById("s-c").textContent = DATA.stats.sccs;
  document.getElementById("s-d").textContent = DATA.stats.dead;
})();

// controles de capa — con descripción de qué es cada pelotita (nodo)
const LAYER_DESC = DATA.layer_desc;       // derivado de los datos
const layersDiv = d3.select("#layers");
layersDiv.append("div").attr("class","ldesc").style("margin-bottom","6px")
  .text("Each node is a program. Its layer:");
LAYERS.forEach(L=>{
  const r = layersDiv.append("label").attr("class","row layer-row");
  r.append("input").attr("type","checkbox").attr("checked",true).attr("data-layer",L)
   .on("change",applyFilter);
  const t = r.append("span").attr("class","layer-txt");
  t.append("span").attr("class","layer-code").text(L);
  t.append("span").attr("class","ldesc").text(LAYER_DESC[L]);
});
// leyenda dominios (derivada de los datos; excluye shared/obsolete que van aparte)
const legend = d3.select("#legend");
DOMS.filter(d=>d!=="shared"&&d!=="obsolete").forEach(d=>{
  const r=legend.append("div").attr("class","row");
  r.append("span").attr("class","dot").style("background",COLOR[d]);
  r.append("span").text(d);
});
legend.append("div").attr("class","row")
  .call(r=>{r.append("span").attr("class","dot").style("background",COLOR.shared);
    r.append("span").text("UTIL / hub (shared)");});
legend.append("div").attr("class","row")
  .call(r=>{r.append("span").attr("class","dot").style("background",COLOR.obsolete)
    .style("outline","1.5px dashed var(--dead)");r.append("span").text("dead / obsolete");});

// leyenda de acceso a datos
const legA = d3.select("#legend-access");
[["read","inquiry (read-only)"],["update","update (writes)"],["none","no access"]].forEach(([k,t])=>{
  const r=legA.append("div").attr("class","row");
  r.append("span").attr("class","dot").style("background",ACCESS_COLOR[k]);
  r.append("span").text(t);
});

// modo de color
document.getElementById("cmode").addEventListener("change",e=>{colorMode=e.target.value;restyle();});

// copybook selector
const sel = d3.select("#cpy");
const CPYDESC = DATA.copybook_desc || {};
Object.keys(DATA.copybooks).forEach(c=>{
  const d = CPYDESC[c] ? " — "+CPYDESC[c] : "";
  sel.append("option").attr("value",c).text(c + d + "  ("+DATA.copybooks[c].length+" progs)");
});

// ---- D3 force ----
const svg = d3.select("svg");
const W = ()=>svg.node().clientWidth, H = ()=>svg.node().clientHeight;
const g = svg.append("g");
svg.call(d3.zoom().scaleExtent([0.15,5]).on("zoom",e=>g.attr("transform",e.transform)));

const nodes = DATA.nodes.map(d=>Object.assign({},d));
const id2node = new Map(nodes.map(n=>[n.id,n]));
const links = DATA.edges.map(e=>({source:e.source,target:e.target}));

// vecinos: a quién llama (out) y quién lo llama (in)
const outN = new Map(), inN = new Map();
DATA.edges.forEach(e=>{
  if(!outN.has(e.source)) outN.set(e.source, new Set());
  if(!inN.has(e.target)) inN.set(e.target, new Set());
  outN.get(e.source).add(e.target);
  inN.get(e.target).add(e.source);
});

const radius = d=> d.layer==="UTIL" ? Math.max(8, 5+Math.sqrt(d.indeg)*1.3)
                                    : Math.max(2.5, 2.5+Math.sqrt(d.indeg)*1.1);

const link = g.append("g").attr("stroke","#b4b4d2").attr("stroke-opacity",0.10)
  .selectAll("line").data(links).join("line").attr("stroke-width",0.6);

const cpyLayer = g.append("g");  // aristas de copybook (punteadas)

const node = g.append("g").selectAll("circle").data(nodes).join("circle")
  .attr("r",radius).attr("fill",d=>COLOR[d.domain]||"#888")
  .attr("stroke","#0c0c1c").attr("stroke-width",0.6)
  .call(drag()).on("click",(e,d)=>{ e.stopPropagation(); selectNode(d); })
  .on("mouseover",(e,d)=>{ tip.text(d.id+"  ["+d.layer+"/"+d.domain+"]")
       .attr("x",d.x).attr("y",d.y-radius(d)-4).style("display",null);})
  .on("mouseout",()=>{ tip.style("display","none");});
node.append("title").text(d=>d.id+"  ["+d.layer+"/"+d.domain+"]  fan-in "+d.indeg);

const labels = g.append("g").selectAll("text").data(nodes.filter(d=>d.hub))
  .join("text").attr("class","lbl").text(d=>d.id).style("display",null);
const nbr = g.append("g");                 // etiquetas de vecinos del nodo seleccionado
let selData = [];
const tip = g.append("text").attr("class","lbl").style("display","none");
// clic en fondo vacío = limpiar selección
svg.on("click", clearSelection);

// centros de cluster por dominio (derivados de los datos: anillo + shared al centro)
const CLUSTER = DATA.cluster;
function cgx(d){return (CLUSTER[d.domain]||[0,0])[0];}
function cgy(d){return (CLUSTER[d.domain]||[0,0])[1];}

const sim = d3.forceSimulation(nodes)
  .force("link", d3.forceLink(links).id(d=>d.id).distance(32))
  .force("collide", d3.forceCollide(d=>radius(d)+1).strength(0.6))
  .velocityDecay(0.45).on("tick",ticked);

// Disposición fija: hairball orgánico (mixed) — única vista
function applyLayout(){
  sim.force("center", d3.forceCenter(0,0))
     .force("charge", d3.forceManyBody().strength(-30))
     .force("x", d3.forceX(0).strength(0.015))
     .force("y", d3.forceY(0).strength(0.015));
  sim.force("link").strength(0.22);
  sim.alpha(0.9).restart();
}
applyLayout();

function ticked(){
  link.attr("x1",d=>d.source.x).attr("y1",d=>d.source.y)
      .attr("x2",d=>d.target.x).attr("y2",d=>d.target.y);
  node.attr("cx",d=>d.x).attr("cy",d=>d.y);
  labels.attr("x",d=>d.x+radius(d)+2).attr("y",d=>d.y+3);
  cpyLayer.selectAll("line").attr("x1",d=>d.sx.x).attr("y1",d=>d.sx.y)
      .attr("x2",d=>d.tx.x).attr("y2",d=>d.tx.y);
  cpyLayer.selectAll("path").attr("transform",d=>`translate(${d.x},${d.y})`);
  if(selData.length) nbr.selectAll("text").attr("x",d=>d.x+radius(d)+2).attr("y",d=>d.y+3);
}

// ---- selección de nodo: resalta y nombra a sus vecinos (dependencias) ----
function selectNode(d){
  const outs = outN.get(d.id) || new Set();
  const ins  = inN.get(d.id)  || new Set();
  const keep = new Set([d.id, ...outs, ...ins]);
  node.attr("opacity", n=> keep.has(n.id) ? 1 : 0.06);
  link.attr("stroke-opacity", l=> (l.source.id===d.id || l.target.id===d.id) ? 0.8 : 0.03)
      .attr("stroke", l=> l.source.id===d.id ? "#E0A458"      // sale: a quién llama (ámbar)
                        : l.target.id===d.id ? "#4EC2C0"      // entra: quién lo llama (teal)
                        : "#b4b4d2");
  selData = [...keep].map(id=>id2node.get(id)).filter(Boolean);
  const s = nbr.selectAll("text").data(selData, n=>n.id);
  s.exit().remove();
  s.enter().append("text").attr("class","lbl")
    .merge(s).text(n=>n.id)
    .attr("x",n=>n.x+radius(n)+2).attr("y",n=>n.y+3);
  showDetail(d);
}
function clearSelection(){
  selData = []; nbr.selectAll("text").remove();
  node.attr("opacity",1);
  link.attr("stroke",null).attr("stroke-opacity",null);
}
// centrar al estabilizar
sim.on("end",()=>{ const t=d3.zoomIdentity.translate(W()/2,H()/2).scale(0.40);
  svg.transition().duration(400).call(d3.zoom().on("zoom",e=>g.attr("transform",e.transform)).transform,t);});
setTimeout(()=>{ const t=d3.zoomIdentity.translate(W()/2,H()/2).scale(0.40); g.attr("transform",t); },50);

function drag(){
  return d3.drag()
   .on("start",(e,d)=>{if(!e.active)sim.alphaTarget(0.2).restart();d.fx=d.x;d.fy=d.y;})
   .on("drag",(e,d)=>{d.fx=e.x;d.fy=e.y;})
   .on("end",(e,d)=>{if(!e.active)sim.alphaTarget(0);d.fx=null;d.fy=null;});
}

// ---- toggles ----
let labelsOn=true;
function restyle(){
  const hubsOn=document.getElementById("t-hubs").checked;
  const cycOn=document.getElementById("t-cyc").checked;
  const deadOn=document.getElementById("t-dead").checked;
  node.attr("fill",d=>{
      if(deadOn && d.dead) return COLOR.obsolete;
      return nodeFill(d);
    })
    .attr("stroke",d=>{
      if(deadOn && d.dead) return "var(--dead)";
      if(cycOn && d.scc>=0) return "var(--cycle)";
      // hub UTIL = borde blanco · hub de negocio (BL/DA) = borde dorado
      if(hubsOn && d.hub) return d.layer==="UTIL" ? "#fff" : "#FFD166";
      return "#0c0c1c";
    })
    .attr("stroke-width",d=>{
      if(deadOn && d.dead) return 1.6;
      if(cycOn && d.scc>=0) return 1.8;
      if(hubsOn && d.hub) return d.layer==="UTIL" ? 1.6 : 2.4;
      return 0.6;
    })
    .attr("stroke-dasharray",d=> (deadOn && d.dead) ? "2,2" : null)
    .attr("r",d=> (hubsOn && d.hub) ? radius(d)*1.25 : radius(d));
}
["t-hubs","t-cyc","t-dead"].forEach(id=>document.getElementById(id).addEventListener("change",restyle));
document.getElementById("t-lbl").addEventListener("change",e=>{
  labelsOn=e.target.checked; labels.style("display",labelsOn?null:"none");});

function applyFilter(){
  const on=new Set();
  layersDiv.selectAll("input").each(function(){ if(this.checked) on.add(this.getAttribute("data-layer"));});
  node.style("display",d=>on.has(d.layer)?null:"none");
  link.style("display",d=>(on.has(id2node.get(d.source.id||d.source).layer)&&
                           on.has(id2node.get(d.target.id||d.target).layer))?null:"none");
}

// ---- capa copybook ----
sel.on("change",function(){
  cpyLayer.selectAll("*").remove();
  node.attr("opacity",1);
  const c=this.value;
  document.getElementById("cpy-note").innerHTML = c
    ? "<b>"+c+"</b>"+(CPYDESC[c]?" — "+CPYDESC[c]:"")+". Used by <b>"+
      DATA.copybooks[c].length+"</b> programs. Dotted edges = data coupling "+
      "(no CALL). Dimmed nodes do not use it."
    : "The hidden hairball: programs sharing a copybook are coupled by "+
      "data even if they never call each other.";
  if(!c) return;
  const members=new Set(DATA.copybooks[c]);
  node.attr("opacity",d=>members.has(d.id)?1:0.08);
  // nodo diamante del copybook + aristas punteadas (muestra hasta 250)
  const cx=0, cy=0;
  const cnode={id:c,x:cx,y:cy};
  cpyLayer.append("path").datum(cnode)
    .attr("d",d3.symbol(d3.symbolDiamond,180)())
    .attr("fill","var(--hl)").attr("stroke","#000").attr("stroke-width",1)
    .attr("transform",`translate(${cx},${cy})`);
  const memArr=DATA.copybooks[c].map(id=>id2node.get(id)).filter(Boolean);
  const sample = memArr.length>250 ? d3.shuffle(memArr.slice()).slice(0,250) : memArr;
  cpyLayer.selectAll("line").data(sample.map(m=>({sx:cnode,tx:m}))).join("line")
    .attr("stroke","var(--hl)").attr("stroke-opacity",0.5)
    .attr("stroke-width",0.5).attr("stroke-dasharray","3,3");
  cpyLayer.raise();
});

// ---- buscar ----
document.getElementById("search").addEventListener("input",function(){
  const q=this.value.trim().toUpperCase();
  node.attr("opacity",d=> !q || d.id.includes(q) ? 1 : 0.08);
  if(q){ const hit=nodes.find(d=>d.id===q); if(hit) showDetail(hit);}
});

function showDetail(d){
  const hasSrc=(DATA.source_code||{})[d.id]!=null;
  const outs=[...(outN.get(d.id)||[])].sort();
  const ins =[...(inN.get(d.id)||[])].sort();
  const el=document.getElementById("detail");
  el.style.display="block";
  el.innerHTML=`<h4>${d.id}</h4>`+(hasSrc?`<button class="srcbtn" onclick="showSrc('${d.id}')">View source code</button>`:`<div class="note">source not available (graph node)</div>`)+`<table>`+`
    <tr><td class="k">Layer</td><td>${d.layer}</td></tr>
    <tr><td class="k">Domain</td><td>${d.domain}</td></tr>
    <tr><td class="k">Access</td><td><span style="color:${ACCESS_COLOR[d.access]||'#888'};font-weight:600">${ACCESS_LABEL[d.access]||d.access}</span></td></tr>
    <tr><td class="k">Fan-in</td><td>${d.indeg}${d.hub?' <span class="pill">HUB</span>':''}</td></tr>
    <tr><td class="k">Fan-out</td><td>${d.outdeg}</td></tr>
    <tr><td class="k">LOC</td><td>${d.loc}</td></tr>
    <tr><td class="k">Reachable</td><td>${d.dead?'<span style="color:var(--dead)">no (dead)</span>':'yes'}</td></tr>
    <tr><td class="k">Cycle</td><td>${d.scc>=0?('SCC #'+d.scc):'—'}</td></tr>
    </table>
    <div style="margin-top:8px" class="k">Copybooks (${d.cpys.length})</div>
    <div>${d.cpys.map(c=>'<span class="chip">'+c+'</span>').join('')||'<span class="note">none</span>'}</div>
    <div style="margin-top:8px" class="k" title="amber in the graph">Calls (${outs.length})</div>
    <div>${chipList(outs)}</div>
    <div style="margin-top:8px" class="k" title="teal in the graph">Called by (${ins.length})</div>
    <div>${chipList(ins)}</div>`;
}
function chipList(arr){
  if(!arr.length) return '<span class="note">—</span>';
  const cap=24, head=arr.slice(0,cap).map(x=>'<span class="chip">'+x+'</span>').join('');
  return head + (arr.length>cap ? ' <span class="note">+'+(arr.length-cap)+' more</span>' : '');
}

// ---- modal "acerca del caso" ----
(()=>{const S=DATA.stats,$=id=>document.getElementById(id);
  const sys=S.system||"SISTEMA";
  document.title=sys+" · dependency graph";
  $("m-mark").textContent=sys+" · dependency graph";
  $("m-title").textContent=sys;
  $("m-topcpy").textContent=(S.shared_cpys&&S.shared_cpys[0])||"—";
  $("m-nodes").textContent=S.nodes;
  $("m-edges").textContent=S.edges.toLocaleString();
  $("m-hub").textContent=S.top_hub+" ("+S.top_hub_fanin+")";
  $("m-cyc").textContent=S.sccs;
  $("m-dead").textContent=S.dead;
  $("m-cpy").textContent=S.copybooks_total;
  $("m-acc").textContent=S.acc_read+" / "+S.acc_update;
})();
const backdrop=document.getElementById("backdrop");
document.getElementById("closeModal").onclick=()=>backdrop.style.display="none";
document.getElementById("help").onclick=()=>backdrop.style.display="flex";
backdrop.addEventListener("click",e=>{if(e.target===backdrop)backdrop.style.display="none";});
document.addEventListener("keydown",e=>{if(e.key==="Escape")backdrop.style.display="none";});
const srcback=document.getElementById("srcback");
window.showSrc=function(id){
  const code=(DATA.source_code||{})[id]; if(code==null) return;
  document.getElementById("src-title").textContent=id;
  document.getElementById("src-pre").textContent=code;
  srcback.style.display="flex";
};
document.getElementById("closeSrc").onclick=()=>srcback.style.display="none";
srcback.addEventListener("click",e=>{if(e.target===srcback)srcback.style.display="none";});
document.addEventListener("keydown",e=>{if(e.key==="Escape")srcback.style.display="none";});

restyle();
</script>
</body>
</html>"""

import argparse, math
HERE = os.path.dirname(os.path.abspath(__file__))

ap = argparse.ArgumentParser(
    description="Renderiza un dependency-graph.json (esquema compartido) como HTML "
                "force-directed OFFLINE. Sirve para grafos sintéticos o reconstruidos por RE.")
ap.add_argument("--graph", required=True, help="ruta a dependency-graph.json")
ap.add_argument("--out", default=None, help="ruta .html de salida (default: junto al grafo)")
ap.add_argument("--source-dir", default=None, help="carpeta raiz del codigo fuente a embeber (default: autodetecta ../source junto al grafo)")
args = ap.parse_args()

GPATH = os.path.abspath(args.graph)
GDIR = os.path.dirname(GPATH)
OUT = os.path.abspath(args.out) if args.out else os.path.join(GDIR, "graph-view.html")

G = json.load(open(GPATH, encoding="utf-8"))
def _load(name):
    p = os.path.join(GDIR, name)
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else {}
# Capa de acoplamiento por datos: en Java son DTOs/entidades compartidas
# (dto-coupling.json); en mainframe son copybooks (copybook-usage.json). Soporta ambos.
CPY = _load("dto-coupling.json") or _load("copybook-usage.json")
GLO = _load("dto-glossary.json") or _load("copybook-glossary.json")
SRCMAP = _load("source-map.json")          # opcional: id -> ruta a codigo fuente

nodes = {n["id"]: n for n in G["nodes"]}
edges = [(e["from"], e["to"]) for e in G["edges"]]

# --- codigo fuente embebido para el visor in-graph ---
def _find_src_dir():
    if args.source_dir:
        return os.path.abspath(args.source_dir)
    cand = os.path.abspath(os.path.join(GDIR, "..", "source"))
    return cand if os.path.isdir(cand) else None
SRC_CODE = {}
_sdir = _find_src_dir()
if _sdir and os.path.isdir(_sdir):
    _idx = {}
    for _root, _, _files in os.walk(_sdir):
        for _fn in _files:
            _idx.setdefault(os.path.splitext(_fn)[0], os.path.join(_root, _fn))
    for _nid in nodes:
        _p = _idx.get(_nid)
        if _p:
            try:
                _txt = open(_p, encoding="utf-8", errors="replace").read()
                SRC_CODE[_nid] = _txt if len(_txt) < 200000 else _txt[:200000] + "\n... [truncated]"
            except Exception:
                pass
for _nid, _rel in (SRCMAP or {}).items():
    if _nid not in SRC_CODE:
        _p = os.path.join(GDIR, _rel)
        if os.path.isfile(_p):
            try:
                SRC_CODE[_nid] = open(_p, encoding="utf-8", errors="replace").read()
            except Exception:
                pass

indeg = defaultdict(int)
outdeg = defaultdict(int)
adj = defaultdict(list)
for s, d in edges:
    outdeg[s] += 1
    indeg[d] += 1
    adj[s].append(d)

# alcanzabilidad desde entry points: Java = WEB(controllers)/JOB(scheduled);
# mainframe = WFL/ONLINE. Si no existen, raíces sin fan-in.
roots = [n for n in nodes if nodes[n].get("layer") in ("WEB", "JOB", "WFL", "ONLINE")]
if not roots:
    roots = [n for n in nodes if indeg[n] == 0] or list(nodes)
seen, stack = set(), list(roots)
while stack:
    v = stack.pop()
    if v in seen:
        continue
    seen.add(v)
    for w in adj[v]:
        if w not in seen:
            stack.append(w)

# Tarjan SCC -> id de SCC no trivial por nodo
idx = {}
low = {}
onst = set()
st = []
cnt = [0]
scc_of = {}
sccs = []
import sys
sys.setrecursionlimit(20000)
def sc(v):
    idx[v] = low[v] = cnt[0]; cnt[0] += 1
    st.append(v); onst.add(v)
    for w in adj[v]:
        if w not in idx:
            sc(w); low[v] = min(low[v], low[w])
        elif w in onst:
            low[v] = min(low[v], idx[w])
    if low[v] == idx[v]:
        comp = []
        while True:
            w = st.pop(); onst.discard(w); comp.append(w)
            if w == v:
                break
        sccs.append(comp)
for v in list(nodes):
    if v not in idx:
        sc(v)
scc_id = 0
for comp in sccs:
    if len(comp) > 1:
        for n in comp:
            scc_of[n] = scc_id
        scc_id += 1

# copybooks por programa (invertir)
prog_cpys = defaultdict(list)
for cpy, progs in CPY.items():
    for p in progs:
        prog_cpys[p].append(cpy)

# top hubs
hubs = set(sorted(nodes, key=lambda n: indeg[n], reverse=True)[:20])

# top-6 copybooks compartidos (los que cruzan mas dominios / mas programas)
shared = sorted(CPY.items(), key=lambda kv: -len(set(kv[1])))[:6]
shared_names = [k for k, _ in shared]

out_nodes = []
for nid, nd in nodes.items():
    out_nodes.append({
        "id": nid,
        "layer": nd.get("layer", "?"),
        "domain": nd.get("domain", "?"),
        "loc": nd.get("loc", 0),
        "indeg": indeg[nid],
        "outdeg": outdeg[nid],
        "dead": nid not in seen,
        "scc": scc_of.get(nid, -1),
        "hub": nid in hubs,
        "access": nd.get("access", "none"),
        "cpys": sorted(prog_cpys.get(nid, [])),
    })
out_edges = [{"source": s, "target": d} for s, d in edges]
copybook_members = {k: sorted(set(v)) for k, v in shared}

# --- Config data-driven: sirve con CUALQUIER sistema, no solo el seed corebank ---
# Paleta categorica APAGADA (muted/desaturada) — enterprise, sin neon "GenAI"
PALETTE = ["#8FA6C0","#9DBE8A","#D0A85C","#B79ACB","#6FB1A8","#CE8F86",
           "#C7B45E","#C58FB0","#7E94B8","#A8B0BC","#9FB07A","#CBA98F"]
doms = []
for nd in nodes.values():
    if nd.get("domain","?") not in doms:
        doms.append(nd.get("domain","?"))
ring = [d for d in doms if d not in ("shared", "obsolete")]
color, ci = {}, 0
for d in doms:
    if d == "shared":      color[d] = "#8C8CA8"      # utilerías/hubs (gris-lavanda apagado)
    elif d == "obsolete":  color[d] = "#555570"      # código muerto
    else:                  color[d] = PALETTE[ci % len(PALETTE)]; ci += 1
# centros de cluster: anillo para dominios, shared al centro, obsolete abajo
cluster = {"shared": [0, 0], "obsolete": [160, 840]}
Rr = max(420, 150 * max(1, len(ring)))
for i, d in enumerate(ring):
    a = -math.pi/2 + 2*math.pi*i/max(1, len(ring))
    cluster[d] = [round(Rr*math.cos(a)), round(Rr*math.sin(a))]
LAYER_ORDER = ["WEB", "JOB", "SERVICE", "REPO", "UTIL", "WFL", "ONLINE", "BL", "DA"]
_present = {n.get("layer","?") for n in nodes.values()}
layers = [L for L in LAYER_ORDER if L in _present] + sorted(_present - set(LAYER_ORDER))
LAYER_DESC = {
    # Java / Spring (default para Application Modernization)
    "WEB": "Spring MVC controller — HTTP endpoint (entry point)",
    "JOB": "scheduled / batch job — @Scheduled, Quartz (entry point)",
    "SERVICE": "business logic — @Service",
    "REPO": "data access — @Repository / DAO / MyBatis",
    "UTIL": "shared static utility — the hubs",
    # Mainframe (compatibilidad con grafos del lab COBOL)
    "WFL": "batch job — orchestrates nightly runs",
    "ONLINE": "user transaction (COMS/3270)",
    "BL": "business logic (COBOL)",
    "DA": "data access (DMSII)",
}
layer_desc = {L: LAYER_DESC.get(L, L) for L in layers}

from collections import Counter as _Counter
_acc = _Counter(n["access"] for n in out_nodes)
stats = {
    "nodes": len(nodes), "edges": len(edges),
    "top_hub": max(nodes, key=lambda n: indeg[n]) if nodes else "—",
    "top_hub_fanin": max(indeg.values()) if indeg else 0,
    "sccs": scc_id, "dead": sum(1 for n in nodes if n not in seen),
    "shared_cpys": shared_names, "copybooks_total": len(CPY),
    "acc_read": _acc["read"], "acc_update": _acc["update"], "acc_none": _acc["none"],
    "system": G.get("system", "SISTEMA"),
}

DATA = {
    "nodes": out_nodes, "edges": out_edges,
    "copybooks": copybook_members,
    "copybook_desc": {k: GLO.get(k, "") for k in copybook_members},
    "color": color, "cluster": cluster, "layers": layers, "layer_desc": layer_desc,
    "source_map": SRCMAP,
    "source_code": SRC_CODE,
    "stats": stats,
}

import base64

# --- Logo Accenture (white letters) base64. Portable: 1º vendor local junto al script
#     (incluido para que el renderer no dependa de la ubicación), luego Design-Studio/logos.
def find_logo():
    local = os.path.join(HERE, "vendor", "Accenture_logo_white_letters.png")
    if os.path.exists(local):
        return local
    for base in (GDIR, HERE):
        d = base
        for _ in range(10):
            cand = os.path.join(d, "Design - Studio", "logos",
                                "Accenture_logo_white_letters.png")
            if os.path.exists(cand):
                return cand
            nd = os.path.dirname(d)
            if nd == d:
                break
            d = nd
    return None
lp = find_logo()
if lp:
    logo_uri = "data:image/png;base64," + base64.b64encode(open(lp, "rb").read()).decode("ascii")
    logo_mode = "embebido"
else:
    logo_uri = "data:image/svg+xml;base64," + base64.b64encode(
        b'<svg xmlns="http://www.w3.org/2000/svg" width="120" height="26">'
        b'<text x="0" y="19" fill="#fff" font-family="sans-serif" font-size="17" '
        b'font-weight="700">&gt; accenture</text></svg>').decode()
    logo_mode = "fallback SVG"

# --- D3 inline (offline) desde el vendor junto al script; CDN solo como fallback
d3_path = os.path.join(HERE, "vendor", "d3.v7.min.js")
if os.path.exists(d3_path):
    d3_src = open(d3_path, encoding="utf-8").read()
    d3_mode = "inline (offline)"
else:
    d3_src = 'document.write(\'<scr\'+\'ipt src="https://cdn.jsdelivr.net/npm/d3@7"></scr\'+\'ipt>\')'
    d3_mode = "CDN fallback"

html = (HTML_TEMPLATE
        .replace("/*__DATA__*/", json.dumps(DATA))
        .replace("/*__LOGO__*/", logo_uri)
        .replace("/*__D3__*/", d3_src))
with open(OUT, "w", encoding="utf-8") as f:
    f.write(html)
print(f"OK · {OUT} · logo={logo_mode} · D3={d3_mode} · "
      f"nodos={stats['nodes']} aristas={stats['edges']} "
      f"hub={stats['top_hub']}({stats['top_hub_fanin']}) sccs={stats['sccs']}")

# ─────────────────────────────────────────────────────────────────────────
# MODO --fanout  (Application Modernization · fanout-graph-schema.json)
# Transforma el schema fanout-graph al formato DATA del visualizador D3.
# Uso: python render_graph.py --fanout <fanout-graph.json> [--out out.html]
# ─────────────────────────────────────────────────────────────────────────
import sys as _sys
if "--fanout" in _sys.argv:
    _fi = _sys.argv[_sys.argv.index("--fanout") + 1]
    _fo = _sys.argv[_sys.argv.index("--out") + 1] if "--out" in _sys.argv else _fi.replace(".json", "-view.html")
    with open(_fi, encoding="utf-8") as f:
        FG = json.load(f)

    # --- Paleta por tipo de nodo
    _TYPE_COLOR = {
        "monolith-component": "#374151",   # gris oscuro
        "enabler":            "#A100FF",   # Accenture purple
        "candidate":          "#9aa0ad",   # gris medio (futura wave)
    }
    _PCI_COLOR  = "#175cd3"  # azul PCI
    _INSCOPE_COLOR = "#6B21A8"  # purple oscuro = enabler in_scope no PCI

    fn_nodes = []
    fn_edges = []
    fn_color  = {}
    fn_cluster = {}
    fn_layers  = {}

    for n in FG["nodes"]:
        nid = n["id"]
        # color: PCI override, luego tipo
        if n.get("pci_in_scope"):
            col = _PCI_COLOR
        elif n.get("type") == "enabler" and n.get("in_scope"):
            col = _INSCOPE_COLOR
        else:
            col = n.get("color") or _TYPE_COLOR.get(n.get("type","candidate"), "#9aa0ad")

        fn_color[nid]   = col
        fn_cluster[nid] = n.get("layer", "business")
        fn_layers[nid]  = n.get("monolith_component", "unknown")

        fn_nodes.append({
            "id":       nid,
            "label":    n.get("label", nid),
            "domain":   n.get("layer", "business"),
            "access":   "update" if n.get("in_scope") else "read",
            "fan_in":   n.get("blast_radius", 0),
            "fan_out":  n.get("fan_out_repos", 0),
            "cycle":    False,
            "dead":     False,
            "color":    col,
            "wave":     n.get("extraction_wave", 0),
            "type":     n.get("type", "candidate"),
            "in_scope": n.get("in_scope", False),
            "pci":      n.get("pci_in_scope", False),
            "complexity": n.get("complexity", ""),
            "seam":     n.get("seam_strategy", "pending"),
        })

    for e in FG["edges"]:
        fn_edges.append({
            "source":     e["source"],
            "target":     e["target"],
            "weight":     e.get("weight", 1),
            "type":       e.get("type", "consumes"),
            "confidence": e.get("confidence", "inferred"),
            "seam":       e.get("seam_type", ""),
        })

    meta = FG.get("meta", {})
    fn_stats = {
        "nodes": len(fn_nodes),
        "edges": len(fn_edges),
        "top_hub": max(fn_nodes, key=lambda n: n["fan_in"])["id"] if fn_nodes else "—",
        "top_hub_fanin": max((n["fan_in"] for n in fn_nodes), default=0),
        "sccs": 0,
        "dead": 0,
        "shared_cpys": [],
        "copybooks_total": 0,
        "acc_read": sum(1 for n in fn_nodes if not n["in_scope"]),
        "acc_update": sum(1 for n in fn_nodes if n["in_scope"]),
        "acc_none": 0,
        "system": meta.get("monolith_name", "monolito"),
    }

    layer_desc = {
        "infrastructure": "Habilitadores — Infraestructura Aplicativa",
        "security":       "Habilitadores — Seguridad (PCI DSS)",
        "business":       "Dominios de Negocio (wave futura)",
        "presentation":   "Componentes físicos del monolito",
    }

    FN_DATA = {
        "nodes": fn_nodes, "edges": fn_edges,
        "copybooks": {}, "copybook_desc": {},
        "color": fn_color, "cluster": fn_cluster,
        "layers": fn_layers, "layer_desc": layer_desc,
        "source_map": {}, "source_code": {},
        "stats": fn_stats,
        "mode": "fanout",
        "waves": FG.get("waves", []),
        "regression_scope": FG.get("regression_scope", {}),
    }

    fn_html = (HTML_TEMPLATE
               .replace("/*__DATA__*/", json.dumps(FN_DATA))
               .replace("/*__LOGO__*/", logo_uri)
               .replace("/*__D3__*/", d3_src))
    with open(_fo, "w", encoding="utf-8") as f:
        f.write(fn_html)
    print(f"FANOUT OK · {_fo} · nodos={fn_stats['nodes']} aristas={fn_stats['edges']} "
          f"top_blast={fn_stats['top_hub']}({fn_stats['top_hub_fanin']})")
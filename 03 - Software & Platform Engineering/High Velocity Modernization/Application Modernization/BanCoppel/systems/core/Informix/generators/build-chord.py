#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-chord.py — Genera chord-bcop.html: diagrama de acordes (D3 v7) de las
integraciones del core BanCoppel. Dominios del core ↔ 18 sistemas externos;
ancho de cinta = nº de ENDPOINTS (SPs entry-point, fan_in=0) que conectan.
Consume: integrations-data.json (de _chord_data.py).
"""
import json
BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
D = json.load(open(BASE + "portal/data/integrations-data.json", encoding="utf-8"))

total_conn = sum(sum(v.values()) for v in D["matrix"].values())
top_sys = max(D["systems"], key=lambda s: s["total"])
n_sys = len(D["systems"]); n_dom = len(D["domains"])
DATA = json.dumps(D, ensure_ascii=False, separators=(",", ":"))

HTML = """<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Integraciones del core (chord)</title>
<style>
:root{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--gold:#F0D224;--blue:#3D5FCD;--txt:#EAEDF7;--muted:#9aa4c4}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh}
header{background:linear-gradient(135deg,#122FB1,#0d2185);border-bottom:3px solid var(--gold);
  padding:13px 24px;display:flex;align-items:center;gap:14px}
header img{height:22px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.55))}
header h1{font-size:16px;font-weight:800}
header .sub{font-size:10px;color:#c9d3f5;margin-top:2px}
.stats{display:flex;gap:12px;padding:16px 24px 4px;flex-wrap:wrap}
.tile{background:var(--panel);border-radius:8px;padding:9px 15px;min-width:110px;border-left:3px solid var(--gold)}
.tile .n{font-size:21px;font-weight:800}
.tile .l{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-top:2px}
.wrap{display:flex;gap:8px;align-items:flex-start;padding:6px 20px 26px;flex-wrap:wrap;justify-content:center}
#chart{flex:1;min-width:640px;display:flex;justify-content:center}
.legend{background:var(--panel);border-radius:8px;padding:12px 14px;min-width:220px;max-width:260px}
.legend h4{font-size:11px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);margin-bottom:8px}
.lrow{display:flex;align-items:center;gap:8px;font-size:11px;margin:5px 0}
.sw{width:11px;height:11px;border-radius:3px;flex-shrink:0}
.legend .hint{font-size:10px;color:var(--muted);margin-top:10px;line-height:1.5}
.arclbl{font-size:9.5px;fill:var(--txt);font-family:'Inter',system-ui,sans-serif}
.arclbl.sys{font-weight:700}
#tip{position:fixed;pointer-events:none;background:#0b1226;border:1px solid var(--gold);border-radius:6px;
  padding:7px 10px;font-size:11px;opacity:0;transition:opacity .1s;max-width:260px;box-shadow:0 4px 14px rgba(0,0,0,.5);z-index:9}
#tip b{color:var(--gold)}
.lead{padding:18px 24px 0}.lead .h{font-size:13px;font-weight:800}.lead .s{font-size:11px;color:var(--muted);margin-top:3px;max-width:96ch}
</style>
</head>
<body>
<header>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div><h1>Integraciones del core · Informix</h1>
  <div class="sub">SPE-AM-001 · a qué sistemas externos se integra el core · cintas ponderadas por endpoints (SPs entry-point)</div></div>
</header>

<div class="stats">
  <div class="tile"><div class="n">__NSYS__</div><div class="l">Sistemas externos</div></div>
  <div class="tile"><div class="n">__NDOM__</div><div class="l">Dominios del core</div></div>
  <div class="tile"><div class="n">__TOTAL__</div><div class="l">Conexiones (endpoints)</div></div>
  <div class="tile" style="border-left-color:var(--blue)"><div class="n" style="font-size:15px;padding-top:4px">__TOP__</div><div class="l">Integración #1 por endpoints</div></div>
</div>

<div class="lead">
  <div class="h">Cómo leerlo</div>
  <div class="s">Los <b>12 dominios del core</b> (azul, mitad interior) y los <b>18 sistemas externos</b> (por categoría) en un anillo. Cada <b>cinta</b> une un dominio con un sistema; su grosor = nº de <b>endpoints</b> (SPs invocados desde fuera del core) que conectan a ese sistema. Pasa el mouse sobre un arco para aislar sus conexiones, o sobre una cinta para el detalle.</div>
</div>

<div class="wrap">
  <div id="chart"></div>
  <div class="legend" id="legend"></div>
</div>
<div id="tip"></div>

<script src="https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js"></script>
<script>
const D = __DATA__;
const DOMCOL = "#3D5FCD";
const doms = D.domains, syss = D.systems, CATS = D.cats;
const names = doms.map(d=>d.key).concat(syss.map(s=>s.key));
const nDom = doms.length, N = names.length;
const color = doms.map(()=>DOMCOL).concat(syss.map(s=>CATS[s.cat]));
const isSys = i => i >= nDom;
const sysIdx = {}; syss.forEach((s,i)=>sysIdx[s.key]=nDom+i);
const domIdx = {}; doms.forEach((d,i)=>domIdx[d.key]=i);

// matriz cuadrada simétrica (bipartita: dominio↔sistema)
const M = Array.from({length:N},()=>new Array(N).fill(0));
for(const dn in D.matrix){ const di=domIdx[dn]; if(di==null) continue;
  for(const sy in D.matrix[dn]){ const si=sysIdx[sy]; if(si==null) continue;
    const v=D.matrix[dn][sy]; M[di][si]=v; M[si][di]=v; } }

const W=Math.min(760, (window.innerWidth||1000)-320), H=W;
const outer=W/2-118, inner=outer-14;
const svg=d3.select("#chart").append("svg").attr("width",W).attr("height",H)
  .attr("viewBox",[-W/2,-H/2,W,H]);
const chord=d3.chord().padAngle(0.028).sortSubgroups(d3.descending).sortChords(d3.descending);
const chords=chord(M);
const arc=d3.arc().innerRadius(inner).outerRadius(outer);
const ribbon=d3.ribbon().radius(inner);

// cintas
const rib=svg.append("g").attr("fill-opacity",0.72).selectAll("path").data(chords).join("path")
  .attr("d",ribbon)
  .attr("fill",d=>color[isSys(d.source.index)?d.source.index:d.target.index])
  .attr("stroke",d=>d3.rgb(color[isSys(d.source.index)?d.source.index:d.target.index]).darker(0.6))
  .attr("stroke-width",0.4)
  .on("mousemove",(e,d)=>{ const si=isSys(d.source.index)?d.source.index:d.target.index;
    const di=isSys(d.source.index)?d.target.index:d.source.index;
    tip(e,`<b>${names[di]}</b> ↔ <b>${names[si]}</b><br>${d.source.value} endpoints`); })
  .on("mouseleave",hide);

// arcos
const g=svg.append("g").selectAll("g").data(chords.groups).join("g");
g.append("path").attr("d",arc).attr("fill",d=>color[d.index])
  .attr("stroke","#0a1330").attr("stroke-width",1)
  .style("cursor","pointer")
  .on("mouseover",(e,d)=>{ rib.style("opacity",r=>(r.source.index===d.index||r.target.index===d.index)?1:0.05);
    const tot=isSys(d.index)?syss[d.index-nDom].total:doms[d.index].total;
    tip(e,`<b>${names[d.index]}</b><br>${tot} endpoints · ${isSys(d.index)?syss[d.index-nDom].cat:'dominio del core'}`); })
  .on("mousemove",moveTip).on("mouseout",(e,d)=>{ rib.style("opacity",1); hide(); });

// etiquetas
g.append("text").each(d=>{d.a=(d.startAngle+d.endAngle)/2;})
  .attr("class",d=>"arclbl"+(isSys(d.index)?" sys":""))
  .attr("dy","0.35em")
  .attr("transform",d=>`rotate(${d.a*180/Math.PI-90}) translate(${outer+7}) ${d.a>Math.PI?"rotate(180)":""}`)
  .attr("text-anchor",d=>d.a>Math.PI?"end":null)
  .text(d=>names[d.index]);

// leyenda
const legcats=[["Dominios del core",DOMCOL]].concat(Object.entries(CATS));
d3.select("#legend").html("<h4>Categorías</h4>"+
  legcats.map(([k,c])=>`<div class="lrow"><span class="sw" style="background:${c}"></span>${k}</div>`).join("")+
  `<div class="hint">Cinta = endpoints que conectan un dominio con un sistema. Total ${__TOTAL__} conexiones sobre ${__NSYS__} sistemas.</div>`);

const tipEl=document.getElementById("tip");
function tip(e,html){ tipEl.innerHTML=html; tipEl.style.opacity=1; moveTip(e); }
function moveTip(e){ tipEl.style.left=(e.clientX+14)+"px"; tipEl.style.top=(e.clientY+14)+"px"; }
function hide(){ tipEl.style.opacity=0; }
</script>
</body>
</html>"""

HTML = (HTML.replace("__DATA__", DATA).replace("__NSYS__", str(n_sys))
        .replace("__NDOM__", str(n_dom)).replace("__TOTAL__", str(total_conn))
        .replace("__TOP__", top_sys["key"]))
open(BASE + "old/chord-bcop.html", "w", encoding="utf-8").write(HTML)
print(f"chord-bcop.html escrito · {n_sys} sistemas · {n_dom} dominios · {total_conn} conexiones · top: {top_sys['key']} ({top_sys['total']})")
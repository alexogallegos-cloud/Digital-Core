#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
inject_waves.py (Mainframe) — agrega un FILTRO POR WAVE DE MIGRACION al graph-view.
Mismo patron que el de datos: NO edita el renderer; post-procesa el HTML renderizado e
inyecta (1) wave por nodo computada DEL GRAFO, (2) panel de control, (3) JS de filtro.
Idempotente (marcador WAVE-INJECT).

Wave (derivada de la topologia del CODIGO, NO por modulo):
  retire : codigo muerto / inalcanzable (cluster obsolete + huerfanos) -> no migrar
  W0     : utilerias hub (logger, fechas, wrappers DMSII) -> Encapsulate PRIMERO (max blast radius)
  W1     : programas de solo-consulta (read) -> bajo riesgo, CQRS read-model en paralelo
  W2     : nucleo transaccional (update: cuentas/asientos/posteos) -> ACID core, parallel-run (incl. ciclos SCC)
  W3     : canales/reporting que dependen del core -> migran al final

Uso:  python inject_waves.py <dependency-graph.json> <graph-view.html>
"""
import json, sys, re
from collections import defaultdict, deque

ENTRY_LAYERS = {"WFL", "ONLINE"}            # puntos de entrada para alcanzabilidad
SATELLITE = {"channels", "reporting"}        # dependen del core -> wave tardia

WORDER = ["W0", "W1", "W2", "W3", "retire"]
WLABEL = {"W0": "W0 · Fundación", "W1": "W1 · Consulta", "W2": "W2 · Core transaccional",
          "W3": "W3 · Canales/satélite", "retire": "Retire"}
WCOLOR = {"W0": "#A100FF", "W1": "#4EC2C0", "W2": "#E0A458", "W3": "#6B9BD1", "retire": "#FF5C7A"}
WRAT = {
    "all": "Todos los programas. Selecciona una wave para ver qué migra y por qué.",
    "W0": "Fundación: utilerías hub (logger, conversión de fechas, wrappers DMSII de lectura/escritura) referenciadas por cientos de programas. Migran PRIMERO (Encapsulate) o cualquier wave se rompe. Máximo blast radius.",
    "W1": "Programas de SOLO-CONSULTA (read-only): su cierre de llamadas nunca alcanza una escritura al sistema de registro. Bajo riesgo, migran en paralelo (CQRS read-model, réplica de lectura, API facade).",
    "W2": "Núcleo TRANSACCIONAL (update): escriben cuentas, asientos, posteos. El ACID core. Refactor + parallel-run ≥ 3 meses + reconciliación diaria. Incluye los programas en ciclos (SCC): migran como unidad indivisible.",
    "W3": "CANALES y REPORTING que dependen del core transaccional y del cliente mastereado. Migran al final.",
    "retire": "Código MUERTO / inalcanzable desde entry points (cluster obsolete + huérfanos sin caller). Validar en logs de producción y excluir del alcance — no migrar.",
}


def compute_waves(gpath):
    g = json.load(open(gpath, encoding="utf-8"))
    nodes = {n["id"]: n for n in g["nodes"]}
    adj = defaultdict(list)
    for e in g["edges"]:
        adj[e["from"]].append(e["to"])
    # alcanzabilidad desde WFL + ONLINE
    roots = [nid for nid, nd in nodes.items() if nd.get("layer") in ENTRY_LAYERS]
    seen = set(roots); dq = deque(roots)
    while dq:
        x = dq.popleft()
        for y in adj.get(x, []):
            if y not in seen:
                seen.add(y); dq.append(y)
    wave = {}
    for nid, nd in nodes.items():
        dom = nd.get("domain", "?")
        acc = nd.get("access", "update")
        lay = nd.get("layer", "?")
        if dom == "obsolete" or nid not in seen:
            wave[nid] = "retire"
        elif lay == "UTIL":
            wave[nid] = "W0"
        elif acc == "read":
            wave[nid] = "W1"
        elif dom in SATELLITE:
            wave[nid] = "W3"
        else:
            wave[nid] = "W2"
    return wave


def inject(gpath, hpath):
    wave = compute_waves(gpath)
    counts = defaultdict(int)
    for w in wave.values():
        counts[w] += 1
    block = (
        "<!--WAVE-INJECT-START-->\n"
        "<div id='wavep' style=\"position:fixed;top:64px;right:14px;z-index:9999;"
        "background:rgba(10,10,20,.95);border:1px solid #2c2c50;border-radius:10px;"
        "padding:12px 13px;width:262px;color:#E8E8F0;font:12.5px 'Segoe UI',Arial;"
        "box-shadow:0 8px 24px rgba(0,0,0,.5)\">"
        "<div style='font-weight:600;color:#A100FF;margin-bottom:8px'>Filtrar por Wave de migración</div>"
        "<div id='wavebtns' style='display:flex;flex-wrap:wrap;gap:5px'></div>"
        "<div id='wave-rat' style='margin-top:9px;font-size:11.5px;color:#cfcfe0;line-height:1.45;min-height:48px'></div>"
        "<div style='margin-top:7px;font-size:10.5px;color:#9a9ab5'>Orden derivado del grafo: "
        "utilerías hub → consulta → core transaccional → canales → retire.</div></div>\n"
        "<script>\n"
        "var WAVE=" + json.dumps(wave) + ";\n"
        "var WCNT=" + json.dumps(dict(counts)) + ";\n"
        "var WLAB=" + json.dumps(WLABEL) + ";\n"
        "var WCOL=" + json.dumps(WCOLOR) + ";\n"
        "var WRAT=" + json.dumps(WRAT) + ";\n"
        "var WORDER=" + json.dumps(WORDER) + ";\n"
        "(function(){\n"
        "  function apply(w){\n"
        "    try{\n"
        "      d3.select('svg').selectAll('circle').attr('opacity',function(d){\n"
        "        if(!d||!d.id) return 1; return (w==='all'||WAVE[d.id]===w)?1:0.05;});\n"
        "      d3.select('svg').selectAll('text').attr('opacity',function(d){\n"
        "        if(!d||!d.id) return 1; return (w==='all'||WAVE[d.id]===w)?1:0.05;});\n"
        "    }catch(e){}\n"
        "    document.getElementById('wave-rat').innerHTML=WRAT[w]||'';\n"
        "    var bs=document.querySelectorAll('#wavebtns button');\n"
        "    bs.forEach(function(b){b.style.outline=(b.getAttribute('data-w')===w)?'2px solid #fff':'none';});\n"
        "  }\n"
        "  var c=document.getElementById('wavebtns');\n"
        "  function mk(key,label,color){var b=document.createElement('button');b.setAttribute('data-w',key);\n"
        "    b.innerHTML=label+(WCNT[key]?(' <b>'+WCNT[key]+'</b>'):'');\n"
        "    b.style.cssText='cursor:pointer;border:none;border-radius:12px;padding:3px 9px;font-size:11px;color:#fff;background:'+color+';';\n"
        "    b.onclick=function(){apply(key);};c.appendChild(b);}\n"
        "  mk('all','Todas','#3a3a5e');\n"
        "  WORDER.forEach(function(k){if(WCNT[k])mk(k,WLAB[k],WCOL[k]);});\n"
        "  apply('all');\n"
        "})();\n"
        "</script>\n"
        "<!--WAVE-INJECT-END-->\n")
    html = open(hpath, encoding="utf-8").read()
    html = re.sub(r"<!--WAVE-INJECT-START-->.*?<!--WAVE-INJECT-END-->\n?", "", html, flags=re.S)
    html = html.replace("</body>", block + "</body>", 1)
    open(hpath, "w", encoding="utf-8").write(html)
    return counts


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("uso: python inject_waves.py <dependency-graph.json> <graph-view.html>"); sys.exit(1)
    cnt = inject(sys.argv[1], sys.argv[2])
    print("OK - wave filter inyectado en", sys.argv[2], "| counts:", dict(cnt))
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
inject_waves.py - agrega un FILTRO POR WAVE DE MIGRACION (con rationale) al graph-view.

No edita el renderer compartido de RE: post-procesa el HTML ya renderizado (+adaptado)
e inyecta (1) la asignacion de wave por nodo computada DEL GRAFO, (2) un panel de control
y (3) el JS que resalta/atenua nodos por wave. Idempotente (marcador WAVE-INJECT).

Wave (derivada de la topologia, NO por modulo):
  retire : modulo legacy (obsolete) o tabla aislada (sin FK) -> no migrar
  W0     : hubs de acoplamiento cross-modulo (>=3 modulos) + cliente mastereado (fundacion)
  W1     : referencia read-mostly (customizing/text/totals) -> bajo riesgo, en paralelo
  W2     : nucleo transaccional/master con escritura (cuentas/postings/creditos/pagos) -> CDC
  W3     : comercial/satelites (CRM, canales, DMEE) -> dependen de lo anterior

Uso:  python inject_waves.py <dependency-graph.json> <graph-view.html>
"""
import json
import sys
from collections import defaultdict

FOUND = {"BUT000", "CRM_ACCOUNT", "T001", "TCURC", "TCURX", "TCURR",
         "SKA1", "SKB1", "BNKA", "T880", "TBSL", "T005", "T012"}
COMMERCIAL = {"crm", "commercial", "channels", "dmee"}

WORDER = ["W0", "W1", "W2", "W3", "retire"]
WLABEL = {"W0": "W0 · Fundación", "W1": "W1 · Referencia", "W2": "W2 · Core transaccional",
          "W3": "W3 · Comercial/satélite", "retire": "Retire"}
WCOLOR = {"W0": "#A100FF", "W1": "#4EC2C0", "W2": "#E0A458", "W3": "#6B9BD1", "retire": "#FF5C7A"}
WRAT = {
    "all": "Todas las tablas. Selecciona una wave para ver qué migra y por qué.",
    "W0": "Fundación: hubs referenciados por casi todos los módulos (company code, monedas, GL) + cliente mastereado (BUT000/CRM). Migran PRIMERO o cualquier módulo se rompe. Mayormente read-mostly, bajo riesgo.",
    "W1": "Referencia read-mostly (customizing/text/totals): dependen solo de la fundación. Bajo riesgo, migran en paralelo (replicables, CQRS/caché).",
    "W2": "Núcleo transaccional/master con escritura (cuentas, movimientos, postings, créditos, pagos): el ACID core. Carga inicial + CDC + parallel run + reconciliación por moneda.",
    "W3": "Comercial y satélites (CRM, canales, DMEE): dependen de cuentas/cliente mastereado. Migran al final.",
    "retire": "Módulo legacy decomisionado + tablas aisladas: candidatas a RETIRE. Validar con negocio y excluir del alcance — no migrar.",
}


def compute_waves(gpath):
    g = json.load(open(gpath, encoding="utf-8"))
    nodes = {n["id"]: n for n in g["nodes"]}
    indeg, outdeg = defaultdict(int), defaultdict(int)
    tgt_doms = defaultdict(set)
    for e in g["edges"]:
        s, d, t = e["from"], e["to"], e.get("type", "fk")
        outdeg[s] += 1
        indeg[d] += 1
        if t == "fk" and nodes[s]["domain"] != nodes[d]["domain"]:
            tgt_doms[d].add(nodes[s]["domain"])
    shared = {t for t, ds in tgt_doms.items() if len(ds) >= 3}
    wave = {}
    for nid, nd in nodes.items():
        dom = nd["domain"]
        acc = nd.get("access", "update")
        if dom == "obsolete":
            wave[nid] = "retire"
        elif nid in shared or nid.upper() in FOUND:
            wave[nid] = "W0"                       # fundación tiene precedencia sobre 'aislada'
        elif indeg[nid] == 0 and outdeg[nid] == 0:
            wave[nid] = "retire"
        elif acc == "read":
            wave[nid] = "W1"
        elif dom in COMMERCIAL:
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
        "background:rgba(20,20,43,.95);border:1px solid #2c2c50;border-radius:10px;"
        "padding:12px 13px;width:258px;color:#E8E8F0;font:12.5px 'Segoe UI',Arial;"
        "box-shadow:0 8px 24px rgba(0,0,0,.45)\">"
        "<div style='font-weight:600;color:#A100FF;margin-bottom:8px'>Filtrar por Wave de migración</div>"
        "<div id='wavebtns' style='display:flex;flex-wrap:wrap;gap:5px'></div>"
        "<div id='wave-rat' style='margin-top:9px;font-size:11.5px;color:#cfcfe0;line-height:1.45;min-height:48px'></div>"
        "<div style='margin-top:7px;font-size:10.5px;color:#9a9ab5'>Orden derivado del grafo: "
        "hubs/acoplamiento → referencia → core transaccional → satélites → retire.</div></div>\n"
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
    # idempotente: quitar bloque previo
    import re
    html = re.sub(r"<!--WAVE-INJECT-START-->.*?<!--WAVE-INJECT-END-->\n?", "", html, flags=re.S)
    html = html.replace("</body>", block + "</body>", 1)
    open(hpath, "w", encoding="utf-8").write(html)
    return counts


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("uso: python inject_waves.py <dependency-graph.json> <graph-view.html>")
        sys.exit(1)
    cnt = inject(sys.argv[1], sys.argv[2])
    print("OK - wave filter inyectado en", sys.argv[2])
    print("   counts:", dict(cnt))
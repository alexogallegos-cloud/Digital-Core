#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-vocab-catalog.py — Reconstruye vocabulary-catalog-bcop.html DESDE EL KB.

Modelo (visión del brain): la fuente de verdad es el KB; el HTML se regenera ante
cualquier enriquecimiento. La data del catálogo vive en:
    knowledge-base/vocabulary/vocabulary-catalog-data.json   (fuente)
y el diseño (CSS/JS/estructura) en:
    generators/vocab-catalog.tmpl.html                        (plantilla, marcador %%DATA%%)

BOOTSTRAP (una vez): la lógica de enriquecimiento original (trasciende, is_root,
máscara, unidades, familia) se perdió con el generador viejo y solo quedó en el HTML.
Si la fuente KB no existe, se COSECHA del HTML actual + inventario, quedando el KB
como fuente completa. En adelante, el HTML se reconstruye 100% desde el KB.

Input:  knowledge-base/vocabulary/vocabulary-catalog-data.json (o bootstrap desde HTML+inventario)
        generators/vocab-catalog.tmpl.html
Output: portal/vocabulary-catalog-bcop.CANDIDATE.html  (se promueve tras validar)
SPE-AM-001 · DT-Vocabulario
"""
import json, io, sys, re, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
HTML_SRC = BASE + "portal/vocabulary-catalog-bcop.html"
TMPL     = BASE + "generators/vocab-catalog.tmpl.html"
KB_DATA  = BASE + "knowledge-base/vocabulary/vocabulary-catalog-data.json"
OUT      = BASE + "portal/vocabulary-catalog-bcop.CANDIDATE.html"

# ── Plantilla: si no existe, extraerla del HTML actual (preserva el diseño en repo) ──
if not os.path.exists(TMPL):
    html = open(HTML_SRC, encoding="utf-8").read()
    m = re.search(r'const DATA=(\[.*?\]);', html, re.S)
    open(TMPL, "w", encoding="utf-8").write(html[:m.start(1)] + "%%DATA%%" + html[m.end(1):])
    print(f"Plantilla extraída → {TMPL}")

# ── Fuente KB: si no existe, BOOTSTRAP (cosecha el enriquecimiento curado del HTML) ──
# Solo se cosechan los términos CURADOS del catálogo (con trasciende/is_root/máscara/
# unidades que calculó el pipeline perdido). Las abreviaciones mecánicas de ABBREV NO
# entran aquí — son léxico del namer, no vocabulario curado. Enriquecer el catálogo con
# términos nuevos es una curaduría deliberada sobre este JSON del KB, no un volcado.
if not os.path.exists(KB_DATA):
    html = open(HTML_SRC, encoding="utf-8").read()
    harvested = json.loads(re.search(r'const DATA=(\[.*?\]);', html, re.S).group(1))
    json.dump({"terms": harvested}, open(KB_DATA, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"KB bootstrap → {KB_DATA}  ({len(harvested)} términos curados cosechados del HTML)")

# ── Render: KB data + plantilla → HTML ──
DATA = json.load(open(KB_DATA, encoding="utf-8"))["terms"]
template = open(TMPL, encoding="utf-8").read()

# Stats del hero (misma semántica que el render por defecto).
# OJO: "Dominios D01-D53" es ALCANCE REAL (53 BDs del core), NO se deriva del vocab
# actual (que cubre D01-D16) — se deja como está en la plantilla.
trasc = sum(1 for d in DATA if d.get('trasciende') and not d.get('es_variante_de') and d.get('cat') != 'ACCION')
bcs   = len({d.get('bc_name') for d in DATA if d.get('bc_name') and d['bc_name'] != 'Transversal'})
roots = sum(1 for d in DATA if d.get('is_root'))

out_html = template.replace("%%DATA%%", json.dumps(DATA, ensure_ascii=False, separators=(",", ":")))

def setstat(h, label, val):
    return re.sub(r'(<div class="sn">)[\d,]+(</div>\s*<div class="sl">' + re.escape(label) + ')',
                  lambda mm: mm.group(1) + f"{val:,}" + mm.group(2), h)
out_html = setstat(out_html, "Trascienden", trasc)
out_html = setstat(out_html, "Bounded contexts", bcs)
out_html = setstat(out_html, "Aggregate roots", roots)
out_html = re.sub(r'[\d,]+ términos que trascienden', f"{trasc:,} términos que trascienden", out_html)

open(OUT, "w", encoding="utf-8").write(out_html)
print(f"Reconstruido desde KB : {len(DATA):,} términos")
print(f"Stats hero            : trascienden={trasc:,} · BCs={bcs} · roots={roots} · (dominios D01-D53 = alcance real)")
print(f"Candidato             : {OUT}  (validar y promover)")

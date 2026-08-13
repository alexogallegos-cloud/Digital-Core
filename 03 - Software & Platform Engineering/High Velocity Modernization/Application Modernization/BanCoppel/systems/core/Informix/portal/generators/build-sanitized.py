#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-sanitized.py — Genera una versión SANITIZADA del showcase del Gemelo Cognitivo,
apta para pitch a cualquier cliente:
  · anonimiza al cliente:  BanCoppel/Informix/Coppel → LegacyCore / "el grupo"
  · marca Accenture:        logo BanCoppel → logo Accenture · paleta azul+dorado → morado
  · renombra archivos:      *-bcop.html → *-legacy.html (y sus hrefs internos)

NO toca los originales: lee de Informix/ y escribe a Informix/sanitized/.
Preserva los colores SEMÁNTICOS (severidad, dominios, reguladores) — solo cambia el
chrome de marca, por hex exacto.
"""
import sys, os, re, glob, shutil
sys.stdout.reconfigure(encoding="utf-8")
BASE = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))
# (chdir removed — using absolute paths via BASE)
OUT = os.path.join(BASE, "sanitized")
os.makedirs(OUT, exist_ok=True)

# ── 1) reemplazos de texto (orden: compuestos largos primero) ────────────────
TEXT = [
  ("Nómina Coppel", "Nómina / dispersión"),
  ("nómina Coppel", "nómina / dispersión"),
  ("Nómina/dispersión", "Nómina / dispersión"),
  ("Coppel/BanCoppel", "el grupo"),
  ("Coppel y BanCoppel", "el grupo"),
  ("BanCoppel/Informix", "LegacyCore"),
  ("clientes de crédito de Coppel", "clientes de crédito del grupo"),
  ("base de clientes de BanCoppel", "base de clientes del banco"),
  ("historia de Coppel", "historia del grupo"),
  ("BanCoppel", "LegacyCore"),
  ("Informix", "LegacyCore"),
  ("knowledge-base-coppel-bancoppel", "knowledge-base-cliente"),
  ("bancoppel", "legacycore"),   # minúscula explícita (evita 'bangrupo')
  ("BANCOPPEL", "LEGACYCORE"),
  ("Coppel", "el grupo retail"),
  ("COPPEL", "GRUPO"),
  ("coppel", "grupo"),
  # descriptor del cliente (donde aparezca genéricamente)
  ("SPE-AM-001", "SPE-AM-001"),   # ID de engagement interno: se conserva (no delata banco)
]

# ── 2) paleta: chrome BanCoppel (azul+dorado) → Accenture (morado) ────────────
# solo hex de CHROME; los semánticos (severidad #F0446C/#F59E0B/#3FB98A, dominios,
# reguladores) tienen otros hex y NO se tocan.
HEX = {
  "122FB1": "6B21A8",  # header grad inicio → morado oscuro
  "0d2185": "4A1670",  # header grad fin
  "0a1330": "14142b",  # fondo
  "0d1a3d": "1a1a2e",  # fondo 2
  "132152": "241a3d",  # panel
  "1f1f3a": "241a3d",  # panel (rules)
  "26317c": "3a2a5c",  # línea
  "2c2c50": "3a2a5c",  # línea (rules)
  "F0D224": "A100FF",  # dorado → morado Accenture brillante (acento primario)
  "3D5FCD": "7C4DCF",  # azul → violeta medio (acento secundario)
  "EAEDF7": "F4F0FA",  # texto casi blanco
  "E8E8F0": "F4F0FA",
  "c9d3f5": "dccff2",  # texto azulado claro
  "9aa4c4": "a99fc4",  # muted
  "9a9ab5": "a99fc4",
  "6b7a9c": "8a7fa8",  # muted 2
  "5b6ba8": "7a6f9c",  # dot quality
  "0b1226": "140f1f",  # tooltip bg (chord)
}

# ── 3) mapeo de nombres de archivo -bcop → -legacy ───────────────────────────
def outname(fn):
    return fn.replace("-bcop", "-legacy")

def sanitize_text(s):
    for a, b in TEXT:
        s = s.replace(a, b)
    return s

def sanitize_hex(s):
    for a, b in HEX.items():
        s = re.sub(re.escape("#" + a), "#" + b, s, flags=re.IGNORECASE)
    return s

def sanitize_data(s):
    """texto + abreviatura residual bcop→lgc (para html/json/md)."""
    s = sanitize_text(s)
    s = re.sub(r'bcop', 'lgc', s, flags=re.IGNORECASE)   # abreviatura BanCoppel residual
    return s

def sanitize_html(s):
    s = s.replace("bancoppel-logo.png", "accenture-logo.png")   # PRIMERO (antes de coppel→grupo)
    s = s.replace("-bcop.html", "-legacy.html")                  # hrefs internos del landing
    s = sanitize_data(s)                                          # texto + bcop→lgc
    s = sanitize_hex(s)                                           # paleta Accenture
    return s

# ── procesar HTML ────────────────────────────────────────────────────────────
htmls = ([f for f in glob.glob(os.path.join(BASE, "old", "*.html")) if "-bcop" in f]
        + [f for f in glob.glob(os.path.join(BASE, "portal", "*.html")) if "-bcop" in f])
for f in htmls:
    src = open(f, encoding="utf-8").read()
    out = sanitize_html(src)
    open(os.path.join(OUT, outname(f)), "w", encoding="utf-8").write(out)
print(f"HTML sanitizados: {len(htmls)}")

# ── procesar JSON fetcheados (solo texto; no tienen -bcop en el nombre) ───────
jsons = [os.path.join(BASE, "portal", "data", f) for f in
         ["callgraph-data.json", "evolution-data.json", "flow-data.json", "journeys-data.json"]]
for f in jsons:
    if os.path.exists(f):
        src = open(f, encoding="utf-8").read()
        open(os.path.join(OUT, os.path.basename(f)), "w", encoding="utf-8").write(sanitize_data(src))
print(f"JSON sanitizados: {sum(1 for f in jsons if os.path.exists(f))}")

# ── procesar knowledge-base (MD) para el drill-down del component-map ─────────
kb_src = "knowledge-base"
n_kb = 0
if os.path.isdir(kb_src):
    for root, _, files in os.walk(kb_src):
        for fn in files:
            sp = os.path.join(root, fn)
            rel = os.path.relpath(sp, BASE)
            dst = os.path.join(OUT, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            if fn.lower().endswith((".md", ".txt", ".json")):
                open(dst, "w", encoding="utf-8").write(sanitize_data(open(sp, encoding="utf-8", errors="replace").read()))
                n_kb += 1
            else:
                shutil.copy2(sp, dst)
print(f"knowledge-base sanitizados: {n_kb} archivos")

# ── logo Accenture (ya decodificado) ─────────────────────────────────────────
if os.path.exists(os.path.join(OUT, "accenture-logo.png")):
    print("logo Accenture: presente")

print(f"\n→ salida en {OUT}")
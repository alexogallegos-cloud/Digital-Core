#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen-portal-batch.py — Migra HTMLs de BCOPCore/portal/ a GENCore/portal/.

Cambios por archivo:
  1. CSS vars :root — paleta BanCoppel → Accenture
  2. rgba BanCoppel blue/yellow → rgba Accenture signal/dark
  3. Logo bancoppel-logo.png/.svg → Accenture logo base64
  4. Título/texto "BCOPCore" → "GEMCog"
  5. Badge v2 fondo oscuro sobre amarillo → texto blanco sobre violeta
  6. Font-family → prioriza Segoe UI

GENCore · SPE-AM-002 · Gemelo Cognitivo
"""
import re, base64, sys, io
from pathlib import Path

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# ── Rutas ──────────────────────────────────────────────────────────────────────
GEN_BASE   = Path(__file__).parent
BCOP_PORT  = (GEN_BASE.parents[1]
              / "BanCoppel" / "systems" / "core" / "Informix" / "portal")
OUT_DIR    = GEN_BASE / "portal"
LOGO_F     = (Path(r"c:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Solutioning")
              / "Design - Studio" / "logos" / "Accenture_logo_white_letters.png")

LOGO_URI = ""
if LOGO_F.exists():
    b64      = base64.b64encode(LOGO_F.read_bytes()).decode()
    LOGO_URI = f"data:image/png;base64,{b64}"
else:
    print(f"WARN: logo no encontrado en {LOGO_F}")

# ── Mapa: archivo fuente → nombre destino (skip = None) ───────────────────────
FILE_MAP = {
    "index-bcop-v2.html":                        "portal-index.html",
    "capability-model-bcop-v2.html":             "capability-model.html",
    "chord-bcop-v2.html":                        "chord.html",
    "component-map-bcop-v2.html":                "component-map.html",
    "evolution-bcop-v2.html":                    "evolution.html",
    "flow-bcop-v2.html":                         "flow.html",
    "generations-bcop-v2.html":                  "generations.html",
    "journeys-bcop-v2.html":                     "journeys.html",
    "sp-inventory-bcop-v2.html":                 "sp-inventory.html",
    "sp-architecture-bcop.html":                 "sp-architecture.html",
    "vocabulary-catalog-bcop.html":              "vocabulary-catalog.html",
    "calendario-riesgo.html":                    "calendario-riesgo.html",
    "curvas-intradia-navegable.html":            "curvas-intradia.html",
    "growth-forecast-autorizador-spei.html":     "growth-forecast.html",
    "percentiles-correlacionados-evolucion.html":"percentiles-correlacionados.html",
    "taxonomia-creacion-perfil.html":            "taxonomia-creacion-perfil.html",
    "domain-d16-intercard.html":                 "domain-d16.html",
    # rules-catalog-bcop.html → ya tenemos nuestro propio rules-catalog.html
}

def patch(html: str) -> str:
    # 1. Paleta CSS vars en :root — reemplazar valores hex directamente
    html = html.replace('--blue:#3D5FCD', '--blue:#A100FF')
    html = html.replace('--blued:#122FB1', '--blued:#1C0032')
    html = html.replace('--bluedd:#0d2185', '--bluedd:#0d0020')
    html = html.replace('--yellow:#F0D224', '--yellow:#A100FF')
    # variantes con espacios
    html = html.replace('--blue: #3D5FCD', '--blue: #A100FF')
    html = html.replace('--blued: #122FB1', '--blued: #1C0032')
    html = html.replace('--yellow: #F0D224', '--yellow: #A100FF')

    # 2. Hex sueltos (fuera de vars)
    html = html.replace('#3D5FCD', '#A100FF').replace('#3d5fcd', '#A100FF')
    html = html.replace('#122FB1', '#1C0032').replace('#122fb1', '#1C0032')
    html = html.replace('#0d2185', '#0d0020')
    html = html.replace('#F0D224', '#A100FF').replace('#f0d224', '#A100FF')

    # 3. rgba BanCoppel blue → Accenture dark
    html = re.sub(r'rgba\(27,\s*63,\s*208,',   'rgba(28,0,50,',  html)
    html = re.sub(r'rgba\(13,\s*33,\s*133,',   'rgba(28,0,50,',  html)
    html = re.sub(r'rgba\(61,\s*95,\s*205,',   'rgba(161,0,255,', html)
    html = re.sub(r'rgba\(18,\s*47,\s*177,',   'rgba(28,0,50,',  html)

    # 4. rgba BanCoppel yellow → Accenture signal
    html = re.sub(r'rgba\(240,\s*210,\s*36,',  'rgba(161,0,255,', html)

    # 5. Logo BanCoppel → Accenture base64
    if LOGO_URI:
        html = re.sub(r'src=["\'][^"\']*bancoppel[^"\']*\.(png|svg)["\']',
                      f'src="{LOGO_URI}"', html, flags=re.IGNORECASE)
        # por si acaso viene como href de favicon o similar
        html = re.sub(r'href=["\'][^"\']*bancoppel[^"\']*\.(png|svg)["\']',
                      f'href="{LOGO_URI}"', html, flags=re.IGNORECASE)

    # 6. Badge oscuro-sobre-amarillo → texto blanco sobre violeta
    html = html.replace('color:#060a1a;background:var(--yellow)',
                        'color:#fff;background:var(--yellow)')
    html = html.replace("color:#060a1a;background:var(--yellow)",
                        "color:#fff;background:var(--yellow)")

    # 7. Títulos y textos de marca
    html = html.replace('BCOPCore', 'GEMCog')
    html = html.replace('bcop-core', 'gemcog')

    # 8. Reescribir hrefs internos (nombres bcop-v2 → nombres GENCore)
    LINK_MAP = {
        'capability-model-bcop-v2.html': 'capability-model.html',
        'chord-bcop-v2.html':            'chord.html',
        'component-map-bcop-v2.html':    'component-map.html',
        'evolution-bcop-v2.html':        'evolution.html',
        'flow-bcop-v2.html':             'flow.html',
        'generations-bcop-v2.html':      'generations.html',
        'journeys-bcop-v2.html':         'journeys.html',
        'sp-inventory-bcop-v2.html':     'sp-inventory.html',
        'sp-architecture-bcop.html':     'sp-architecture.html',
        'vocabulary-catalog-bcop.html':  'vocabulary-catalog.html',
        'rules-catalog-bcop.html':       'rules-catalog.html',
        'calendario-riesgo.html':        'calendario-riesgo.html',
        'curvas-intradia-navegable.html':'curvas-intradia.html',
        'growth-forecast-autorizador-spei.html': 'growth-forecast.html',
        'percentiles-correlacionados-evolucion.html': 'percentiles-correlacionados.html',
        'taxonomia-creacion-perfil.html':'taxonomia-creacion-perfil.html',
        'domain-d16-intercard.html':     'domain-d16.html',
    }
    for old, new in LINK_MAP.items():
        html = html.replace(f'href="{old}"', f'href="{new}"')
        html = html.replace(f"href='{old}'", f"href='{new}'")

    # 10. Font-family → Segoe UI first
    html = re.sub(
        r"font-family:'SF Pro Display'[^;]+;",
        "font-family:'Segoe UI',Calibri,Arial,sans-serif;",
        html
    )
    html = re.sub(
        r"font-family:'Inter'[^;']+(?:sans-serif)?;",
        "font-family:'Segoe UI',Calibri,Arial,sans-serif;",
        html
    )

    return html

# ── Proceso ────────────────────────────────────────────────────────────────────
OUT_DIR.mkdir(parents=True, exist_ok=True)
ok, skip = 0, 0

for src_name, dst_name in FILE_MAP.items():
    src = BCOP_PORT / src_name
    dst = OUT_DIR / dst_name

    if not src.exists():
        print(f"SKIP  {src_name:<46}  (no encontrado)")
        skip += 1
        continue

    html = src.read_text(encoding='utf-8', errors='replace')
    html = patch(html)
    dst.write_text(html, encoding='utf-8')
    size = dst.stat().st_size
    print(f"OK    {dst_name:<40}  {size:>9,} bytes")
    ok += 1

print(f"\n{ok} archivos generados · {skip} omitidos")
print(f"Open: http://localhost:3003/portal-index.html")

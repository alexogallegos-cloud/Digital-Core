#!/usr/bin/env python3
"""
Liverpool — Evolución del Código (EJEMPLO con datos de BanCoppel Informix).
Streamgraph "vetas del árbol" de crecimiento por año y dominio, modelado sobre
el evolution-bcop-v2 de BanCoppel, pero SIN dependencias externas: el SVG se
genera en Python y se embebe (portable file://, sin D3/CDN/fetch).

Datos: portal/data/evolution-liv.json = copia del evolution real de BanCoppel
Informix (SPE-AM-001) usado como EJEMPLO ilustrativo. Cuando exista change
history de Liverpool, reemplazar ese JSON por los datos reales.

Reads  portal/data/evolution-liv.json
Writes portal/evolution-liv.html
"""
import json, math
from pathlib import Path
import _liv_shared as S

HERE  = Path(__file__).parent
BRAIN = HERE.parent
SRCJ  = BRAIN / "portal" / "data" / "evolution-liv.json"
OUTH  = BRAIN / "portal" / "evolution-liv.html"

data       = json.loads(SRCJ.read_text(encoding="utf-8"))
YEARS      = data["years"]
DOM_META   = data["domains"]                 # {d01:{name,color}, ...}
STREAM     = data["stream"]                  # [{year, d01:n, ...}]
Y0, Y1     = YEARS[0], YEARS[-1]
order      = sorted(DOM_META.keys())

# ── anonimiza al cliente (regla: sin nombres de clientes en artefactos) ────────
import re as _re
SCRUB = [
    (r"Agust[íi]n Coppel Luken", "la dirección del grupo"),
    (r"BanCoppel", "el banco"),
    (r"Coppel", "el grupo"),
]
def scrub(txt):
    for pat, rep in SCRUB:
        txt = _re.sub(pat, rep, txt)
    return txt
MILESTONES = [(m["year"], scrub(m["label"])) for m in data["milestones"]]
# reescribe el JSON local ya anonimizado (para que la carpeta portable no lleve el nombre)
data["milestones"] = [{"year": y, "label": l} for y, l in MILESTONES]
data.setdefault("meta", {})["source"] = "core Informix de un cliente bancario real (ejemplo)"
SRCJ.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")

# paleta Liverpool (vívida) sobre los dominios del ejemplo
LIV_RAMP = ["#E00198", "#DA7AB0", "#87C3D3", "#b5007a", "#96CCEE", "#f0a3d0",
            "#6b8cce", "#9070a0", "#5eb0a8", "#e0a83a", "#c05fd0", "#f87171",
            "#67e8f9", "#fca5a5"]
COLOR = {d: LIV_RAMP[i % len(LIV_RAMP)] for i, d in enumerate(order)}
NAME  = {d: DOM_META[d].get("name", d) for d in order}

# ── layout streamgraph (silhouette / centrado) ─────────────────────────────────
W, H = 1160, 520
PADL, PADR, PADT, PADB = 24, 24, 30, 46
plotW = W - PADL - PADR
plotH = H - PADT - PADB
cy = PADT + plotH / 2

max_total = max(sum(row.get(d, 0) for d in order) for row in STREAM) or 1
yscale = (plotH * 0.86) / max_total

def xof(year):
    return PADL + (year - Y0) / (Y1 - Y0) * plotW

bands = {d: {"top": [], "bot": []} for d in order}
for row in STREAM:
    total = sum(row.get(d, 0) for d in order)
    y = cy - (total * yscale) / 2
    x = xof(row["year"])
    for d in order:
        v = row.get(d, 0) * yscale
        bands[d]["top"].append((x, y))
        bands[d]["bot"].append((x, y + v))
        y += v

def smooth_seg(points):
    n = len(points)
    if n < 2:
        return ""
    out = []
    for i in range(n - 1):
        p0 = points[max(i - 1, 0)]; p1 = points[i]; p2 = points[i + 1]; p3 = points[min(i + 2, n - 1)]
        c1x = p1[0] + (p2[0] - p0[0]) / 6; c1y = p1[1] + (p2[1] - p0[1]) / 6
        c2x = p2[0] - (p3[0] - p1[0]) / 6; c2y = p2[1] - (p3[1] - p1[1]) / 6
        out.append(f"C{c1x:.1f},{c1y:.1f} {c2x:.1f},{c2y:.1f} {p2[0]:.1f},{p2[1]:.1f}")
    return " ".join(out)

def band_path(d):
    top = bands[d]["top"]; bot = bands[d]["bot"]
    return (f"M{top[0][0]:.1f},{top[0][1]:.1f} " + smooth_seg(top) +
            f" L{bot[-1][0]:.1f},{bot[-1][1]:.1f} " + smooth_seg(list(reversed(bot))) + " Z")

# ── SVG ────────────────────────────────────────────────────────────────────────
paths = []
for d in order:
    peak_year = max(STREAM, key=lambda r: r.get(d, 0))["year"]
    total = sum(r.get(d, 0) for r in STREAM)
    paths.append(
        f'<path class="band" data-dom="{d}" data-name="{NAME[d]}" data-peak="{peak_year}" '
        f'data-total="{total}" d="{band_path(d)}" fill="{COLOR[d]}" fill-opacity="0.82" '
        f'stroke="{COLOR[d]}" stroke-width="0.6" stroke-opacity="0.5"></path>'
    )

ticks = []
for y in YEARS:
    x = xof(y)
    if y % 2 == 0:
        ticks.append(f'<line x1="{x:.1f}" y1="{PADT}" x2="{x:.1f}" y2="{H-PADB}" stroke="rgba(255,255,255,.04)"/>')
        ticks.append(f'<text x="{x:.1f}" y="{H-PADB+16}" text-anchor="middle" class="ytick">{y}</text>')

def esc_attr(s):
    return s.replace("&", "&amp;").replace('"', "&quot;").replace("<", "&lt;").replace(">", "&gt;")

ms = []
for y, label in MILESTONES:
    if y < Y0 or y > Y1:
        continue
    x = xof(y)
    ms.append(f'<line x1="{x:.1f}" y1="{PADT}" x2="{x:.1f}" y2="{H-PADB}" stroke="rgba(224,1,152,.18)" stroke-dasharray="3 4"/>')
    ms.append(f'<path class="mile-dot" d="M{x:.1f},{PADT-11:.1f} L{x+4:.1f},{PADT-7:.1f} L{x:.1f},{PADT-3:.1f} L{x-4:.1f},{PADT-7:.1f} Z"/>')
    ms.append(f'<text class="mile-yr" x="{x+3:.1f}" y="{PADT+2:.1f}" transform="rotate(90 {x+3:.1f} {PADT+2:.1f})">{y}</text>')
    ms.append(f'<rect class="mile-hit" x="{x-8:.1f}" y="{PADT-16:.1f}" width="16" height="{plotH+16:.1f}" data-year="{y}" data-label="{esc_attr(label)}"/>')

svg = (f'<svg viewBox="0 0 {W} {H}" width="100%" height="auto" preserveAspectRatio="xMidYMid meet" id="stream">'
       + "".join(ticks) + "".join(paths) + "".join(ms) + "</svg>")

legend = "".join(
    f'<span class="lg" data-dom="{d}"><b style="background:{COLOR[d]}"></b>{NAME[d]}</span>'
    for d in order
)

# ── HTML (sin f-string sobre el JS) ────────────────────────────────────────────
n_sp = data.get("meta", {}).get("n_sp", "")
n_dated = data.get("meta", {}).get("n_dated", "")
stats = (S.stat(f"{Y0}–{Y1}", "Años") + S.stat(len(order), "Dominios") +
         S.stat(len([m for m in MILESTONES if Y0 <= m[0] <= Y1]), "Hitos") + S.stat("Ejemplo", "Datos", "red"))
hero = S.hero(
    "Liverpool · Biografía del sistema · Crecimiento del código",
    "Evolución del Código",
    "Las <b>vetas del árbol</b>: cómo crece un core año por año, por dominio de negocio. Cada banda es un "
    "dominio; su grosor, la actividad de ese año; los hitos marcan eventos clave. "
    f"<b>Vista de ejemplo</b> con datos reales del core Informix de un cliente bancario real ({n_dated} SPs fechados de {n_sp}) "
    "&mdash; se reemplaza por el change history de Liverpool cuando esté disponible.",
    "SPE-AM-003 <em>›</em> Biografía <em>›</em> Evolución", "Ejemplo", stats)

extra_css = """
.evo-note{margin:10px 24px 0;font-size:11px;color:#fca5a5;background:rgba(248,113,113,.08);border:1px solid rgba(248,113,113,.25);border-radius:8px;padding:7px 12px}
.evo-note code{color:var(--sky)}
#wrap{flex:1;overflow:auto;padding:8px 24px 16px;min-height:0}
#stream{display:block}
.band{cursor:pointer;transition:fill-opacity .18s}
#stream.dim .band{fill-opacity:.13}
#stream.dim .band.hi{fill-opacity:.96}
.ytick{fill:#9070a0;font-size:9px;font-family:'SF Pro Display',sans-serif}
.mile-dot{fill:#fff;opacity:.65}
.mile-yr{fill:rgba(255,255,255,.5);font-size:8.5px;font-family:'SF Pro Display',sans-serif;letter-spacing:.02em}
.mile-hit{fill:transparent;cursor:pointer}
.mile-hit:hover{fill:rgba(224,1,152,.07)}
.mile-hit:hover + text,.mgrp:hover .mile-yr{fill:var(--sky)}
.legend{display:flex;gap:12px;flex-wrap:wrap;padding:10px 24px;background:rgba(13,4,8,.6);border-top:1px solid var(--line);flex-shrink:0;font-size:10px;color:var(--muted)}
.lg{cursor:default}.lg b{display:inline-block;width:10px;height:10px;border-radius:3px;margin-right:5px;vertical-align:middle}
"""

body = (
    '<div class="evo-note">⚠ Vista de ejemplo: datos reales del core <b>Informix de un cliente bancario real</b>, '
    'usados como demostración de la técnica. Reemplazar <code>portal/data/evolution-liv.json</code> por el change '
    'history de Liverpool cuando esté disponible &mdash; el render (layout, hitos, hover) no cambia.</div>'
    '<div id="wrap">' + svg + '</div>'
    '<div class="legend">' + legend + '</div>'
)

script = r"""
var svg=document.getElementById('stream');
var bands=svg.querySelectorAll('.band');
var tip=document.createElement('div');tip.id='tip';document.body.appendChild(tip);
function show(e,el){
  svg.classList.add('dim');bands.forEach(function(b){b.classList.remove('hi');});el.classList.add('hi');
  tip.style.display='block';
  tip.innerHTML='<b>'+el.dataset.name+'</b><br>pico '+el.dataset.peak+' · '+el.dataset.total+' componentes fechados';
}
function hide(){svg.classList.remove('dim');bands.forEach(function(b){b.classList.remove('hi');});tip.style.display='none';}
bands.forEach(function(el){
  el.addEventListener('mouseenter',function(e){show(e,el);});
  el.addEventListener('mousemove',function(e){var x=e.clientX+14,y=e.clientY+14;var r=tip.getBoundingClientRect();
    if(x+r.width>innerWidth-8)x=e.clientX-r.width-14;if(y+r.height>innerHeight-8)y=e.clientY-r.height-14;
    tip.style.left=x+'px';tip.style.top=y+'px';});
  el.addEventListener('mouseleave',hide);
});
document.querySelectorAll('.lg').forEach(function(l){
  l.addEventListener('mouseenter',function(){var el=svg.querySelector('.band[data-dom="'+l.dataset.dom+'"]');if(el)show(null,el);});
  l.addEventListener('mouseleave',hide);
});
svg.querySelectorAll('.mile-hit').forEach(function(el){
  el.addEventListener('mouseenter',function(){tip.style.display='block';
    tip.innerHTML='<b style="color:var(--sky)">&#9670; '+el.dataset.year+'</b><br>'+el.dataset.label;});
  el.addEventListener('mousemove',function(e){var x=e.clientX+14,y=e.clientY+14;var r=tip.getBoundingClientRect();
    if(x+r.width>innerWidth-8)x=e.clientX-r.width-14;if(y+r.height>innerHeight-8)y=e.clientY-r.height-14;
    tip.style.left=x+'px';tip.style.top=y+'px';});
  el.addEventListener('mouseleave',function(){tip.style.display='none';});
});
"""

html = (
    '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">'
    '<meta name="viewport" content="width=device-width,initial-scale=1.0">'
    '<title>Liverpool · Evolución del Código</title><style>'
    + S.BASE_CSS + extra_css +
    '</style></head><body>' + hero + body +
    '<script>' + script + '</script></body></html>'
)

OUTH.write_text(html, encoding="utf-8")
print(f"evolution -> {OUTH.name} ({round(OUTH.stat().st_size/1024,1)} KB) · {Y0}-{Y1} · {len(order)} dominios · datos de un cliente bancario real ({n_sp} SPs)")

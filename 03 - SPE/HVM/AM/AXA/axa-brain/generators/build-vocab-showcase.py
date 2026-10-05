"""
build-vocab-showcase.py — Genera portal/showcase-vocabulario.html
DEMOSTRACIÓN del potencial del Digital Brain — Capa 1 · Lenguaje (Vocabulario).
Toma el catálogo de vocabulario de un engagement de modernización real,
lo ANONIMIZA (cliente y sistemas) y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra qué produce el brain cuando hay discovery de código fuente.
"""
import re, pathlib, shutil

ROOT    = pathlib.Path(__file__).parent.parent
SRC_HTML = (ROOT.parent.parent
            / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
            / "vocabulary-catalog-bcop.html")
OUT_HTML = ROOT / "portal" / "showcase-vocabulario.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

html = SRC_HTML.read_text(encoding="utf-8")

# ── Paleta BanCoppel → AXA ─────────────────────────────────────────────────
html = (html
    .replace("--yellow:#F0D224", "--yellow:#FF1721")
    .replace("--blue:#122FB1",   "--blue:#00008F")
    .replace("--blue2:#3D5FCD",  "--blue2:#2255CC")
    .replace("color:var(--yellow)", "color:var(--yellow)")   # keeps semantic references
)

# ── Logo ───────────────────────────────────────────────────────────────────
html = re.sub(
    r'src="[^"]*bancoppel[^"]*"\s*alt="[^"]*"',
    'src="logos/Axa_logo.png" alt="AXA"',
    html, flags=re.IGNORECASE
)

# ── Título de pestaña ──────────────────────────────────────────────────────
html = html.replace(
    "<title>Informix · Vocabulario SPL</title>",
    "<title>Digital Brain · Vocabulario (demo) — AXA</title>"
)

# ── Crumb / breadcrumb ─────────────────────────────────────────────────────
html = html.replace(
    "Informix &middot; <em>SPE-AM-001</em> &middot; Gemelo Cognitivo &middot; Capa 1",
    "DEMOSTRACIÓN &middot; <em>Capa 1 · Lenguaje</em> &middot; Vocabulario"
)

# ── Hero label + h1 ────────────────────────────────────────────────────────
html = html.replace(
    '<div class="hero-label">Vocabulario SPL</div>',
    '<div class="hero-label">Vocabulario de negocio</div>'
)
html = html.replace(
    "El lenguaje del<br>core bancario",
    "El lenguaje del<br>negocio asegurador"
)

# ── Hero sub ───────────────────────────────────────────────────────────────
html = re.sub(
    r'<div class="hero-sub">.*?</div>',
    '<div class="hero-sub">Vocabulario destilado de los stored procedures de un core legacy '
    '&mdash; ejemplo real de un engagement de modernizaci&oacute;n, con <b>cliente y sistemas '
    'anonimizados</b>.<br>Ilustra lo que el Digital Brain produce cuando existe discovery de '
    'c&oacute;digo fuente: los t&eacute;rminos que gobiernan cada c&aacute;lculo, entidad y '
    'acci&oacute;n del negocio, extra&iacute;dos del c&oacute;digo y hechos legibles.</div>',
    html, count=1, flags=re.S
)

# ── Footer ─────────────────────────────────────────────────────────────────
html = html.replace(
    "Informix · IBM Informix IDS 14.10 · 4,184 SPs · Gemelo Cognitivo Capa 1",
    "Digital Brain · Vocabulario (demo) · AXA Insurance P&amp;C · datos anonimizados"
)

# ── Nav links (back to index) ──────────────────────────────────────────────
html = html.replace('href="index-bcop-v2.html"', 'href="index.html"')
html = html.replace("href='index-bcop-v2.html'", "href='index.html'")

# ── Banner de demostración (justo antes del buscador / filtros) ────────────
banner = (
    '<div style="background:rgba(255,23,33,.08);border:1px solid rgba(255,23,33,.32);'
    'border-radius:9px;margin:8px 28px 10px;padding:11px 16px;font-size:12px;'
    'color:#ffc0c0;line-height:1.55">'
    '<b style="color:#ff5566">DEMOSTRACIÓN &middot; datos anonimizados</b> &mdash; '
    'No es informaci&oacute;n de AXA. Es un vocabulario real de otro proyecto de '
    'modernizaci&oacute;n, con cliente y sistemas removidos, que muestra el '
    '<b>potencial del Digital Brain</b> (Capa 1 &middot; Lenguaje) cuando hay '
    'extracci&oacute;n de c&oacute;digo fuente.'
    '</div>'
)
# Insert before the first filter/search bar div (id with "fbar" or class "controls")
if '<div id="fbar">' in html:
    html = html.replace('<div id="fbar">', banner + '\n<div id="fbar">', 1)
elif 'id="controls"' in html:
    html = re.sub(r'(<div[^>]+id="controls"[^>]*>)', banner + r'\n\1', html, count=1)
else:
    # Fallback: insert after </header> or after hero section
    html = re.sub(r'(</(?:header|section)>)', r'\1\n' + banner, html, count=1)

# ── Barrido final de referencias de cliente ────────────────────────────────
REPL = [
    (r"bancoppel", "el banco"),
    (r"bcopcore",  "core"),
    (r"\bbcop\b",  "core"),
    (r"coppel",    ""),
    (r"informix",  "el core"),
    (r"\bibm\b",   ""),
    (r"ids ?14\.?10", ""),
    (r"spe-am-001", "demo"),
]
for pattern, rep in REPL:
    html = re.sub(pattern, rep, html, flags=re.IGNORECASE)

# ── Output ─────────────────────────────────────────────────────────────────
OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
OUT_HTML.write_text(html, encoding="utf-8")

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes)")
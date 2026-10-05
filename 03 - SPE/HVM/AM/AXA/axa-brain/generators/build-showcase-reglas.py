"""
build-showcase-reglas.py — Genera portal/showcase-reglas.html
DEMOSTRACIÓN del potencial del Digital Brain — Capa 4 · Intención (Reglas de Negocio).
Toma el catálogo de reglas SBVR de un engagement real (BanCoppel Informix),
lo ANONIMIZA y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra qué produce el brain cuando extrae reglas de negocio del código fuente.
"""
import re, pathlib, shutil

ROOT     = pathlib.Path(__file__).parent.parent
SRC_HTML = (ROOT.parent.parent
            / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
            / "rules-catalog-bcop.html")
OUT_HTML = ROOT / "portal" / "showcase-reglas.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

html = SRC_HTML.read_text(encoding="utf-8")

# ── Paleta BanCoppel → AXA ─────────────────────────────────────────────────
html = (html
    .replace("--yellow:#F0D224",   "--yellow:#FF1721")
    .replace("--blue:#3D5FCD",     "--blue:#2255CC")
    .replace("--blued:#122FB1",    "--blued:#00008F")
    .replace("--brand:#122FB1",    "--brand:#00008F")
    .replace("--acc:#F0D224",      "--acc:#FF1721")
    .replace("rgba(240,210,36,.22)", "rgba(255,23,33,.18)")
    .replace("rgba(240,210,36,",     "rgba(255,23,33,")
    .replace("#F0D224",            "#FF1721")
    .replace("#f0d224",            "#FF1721")
)
html = html.replace(
    "color:#060a1a;background:var(--yellow)",
    "color:#fff;background:#FF1721"
)

# ── Logo (src puede ser data URI o ruta) ───────────────────────────────────
html = re.sub(
    r'<img\s+src="[^"]*"\s+alt="BanCoppel"',
    '<img src="logos/Axa_logo.png" alt="AXA"',
    html, flags=re.IGNORECASE
)

# ── Título de pestaña ──────────────────────────────────────────────────────
html = re.sub(r'<title>.*?</title>',
    '<title>Digital Brain · Reglas de Negocio (demo) — AXA</title>', html)

# ── Nav / encabezado ────────────────────────────────────────────────────────
html = re.sub(r'Informix\s*[·•]\s*Reglas de Negocio',
    'Digital Brain · Reglas de Negocio', html)
html = re.sub(r'Informix\s*·\s*Reglas',
    'Digital Brain · Reglas', html, flags=re.IGNORECASE)
html = re.sub(r'SPE-AM-001\s*<em>.*?</em>\s*Reglas de Negocio',
    'Digital Brain <em>›</em> Reglas de Negocio', html)
html = html.replace('href="index-bcop-v2.html"', 'href="index.html"')
html = html.replace("href='index-bcop-v2.html'", "href='index.html'")

# ── Badge v2 → DEMO ─────────────────────────────────────────────────────────
html = html.replace('<span class="v2badge">v2</span>',
    '<span class="v2badge">DEMO</span>')
html = html.replace('<span class="v2badge">v3</span>',
    '<span class="v2badge">DEMO</span>')

# ── Hero / títulos ─────────────────────────────────────────────────────────
html = html.replace("Reglas del Core Bancario", "Reglas del Core de Negocio")
html = html.replace("core bancario", "core de negocio")
html = html.replace("Core Bancario", "Core de Negocio")

# ── Footer ─────────────────────────────────────────────────────────────────
html = re.sub(
    r'<footer>.*?</footer>',
    '<footer>Digital Brain &middot; Reglas de Negocio (demo) &middot; '
    'AXA Insurance P&amp;C &middot; datos anonimizados</footer>',
    html, flags=re.S
)

# ── Barrido final de referencias de cliente ─────────────────────────────────
REPL = [
    (r"bancoppel",    "el banco"),
    (r"bcopcore",     "core"),
    (r"\bbcop\b",     "core"),
    (r"coppel\b",     ""),
    (r"\binformix\b", "el core"),
    (r"\bibm\b",      ""),
    (r"ids ?14\.?10", ""),
    (r"spe-am-001",   "demo"),
    (r"\bpisa\b",     "core"),
    (r"SPL\b",        "SQL"),
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
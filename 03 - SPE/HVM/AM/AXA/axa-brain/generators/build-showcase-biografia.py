"""
build-showcase-biografia.py — Genera portal/showcase-biografia.html
DEMOSTRACIÓN del potencial del Digital Brain — Capa 3 · Biografía.
Toma la vista de Evolución del Código de un engagement real (BanCoppel Informix),
lo ANONIMIZA y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra cómo creció el código año por año, las vetas del árbol.
"""
import re, pathlib, shutil

ROOT     = pathlib.Path(__file__).parent.parent
BCOP_DIR = ROOT.parent.parent / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
SRC_HTML = BCOP_DIR / "evolution-bcop-v2.html"
SRC_DATA = BCOP_DIR / "data" / "evolution-data.json"
OUT_HTML = ROOT / "portal" / "showcase-biografia.html"
OUT_DATA = ROOT / "portal" / "data" / "evolution-data.json"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

html = SRC_HTML.read_text(encoding="utf-8")

# ── Paleta BanCoppel → AXA ─────────────────────────────────────────────────
html = (html
    .replace("--yellow:#F0D224",     "--yellow:#FF1721")
    .replace("--blue:#3D5FCD",       "--blue:#2255CC")
    .replace("--blued:#122FB1",      "--blued:#00008F")
    .replace("rgba(240,210,36,.22)", "rgba(255,23,33,.18)")
    .replace("rgba(240,210,36,",     "rgba(255,23,33,")
)
html = html.replace(
    "color:#060a1a;background:var(--yellow)",
    "color:#fff;background:#FF1721"
)

# ── Logo ───────────────────────────────────────────────────────────────────
html = re.sub(
    r'src="[^"]*bancoppel[^"]*"\s*alt="[^"]*"',
    'src="logos/Axa_logo.png" alt="AXA"',
    html, flags=re.IGNORECASE
)

# ── Título de pestaña ──────────────────────────────────────────────────────
html = html.replace(
    '<title>Informix · Evolución del Código v2 — "las vetas del árbol"</title>',
    '<title>Digital Brain · Biografía del Sistema (demo) — AXA</title>'
)

# ── Nav ────────────────────────────────────────────────────────────────────
html = html.replace(
    "Informix · Evolución del Código",
    "Digital Brain · Biografía del Sistema"
)
html = html.replace(
    '<span class="v2badge">v2</span>',
    '<span class="v2badge">DEMO</span>'
)
html = html.replace('href="index-bcop-v2.html"', 'href="index.html"')
html = html.replace("href='index-bcop-v2.html'", "href='index.html'")

# ── Hero strip ─────────────────────────────────────────────────────────────
html = html.replace(
    "Evolución del Código",
    "Evolución del Sistema"
)

# ── Footer ─────────────────────────────────────────────────────────────────
html = re.sub(
    r'<footer>.*?</footer>',
    '<footer>Cada franja = un dominio funcional &middot; grosor = componentes creados ese a&ntilde;o &middot; '
    'Digital Brain &middot; Biograf&iacute;a del Sistema (demo) &middot; '
    'AXA Insurance P&amp;C &middot; datos anonimizados</footer>',
    html, flags=re.S
)

# ── Barrido final de referencias de cliente ────────────────────────────────
REPL = [
    (r"bancoppel",   "el banco"),
    (r"bcopcore",    "core"),
    (r"\bbcop\b",    "core"),
    (r"coppel",      ""),
    (r"\binformix\b","el core"),
    (r"\bibm\b",     ""),
    (r"ids ?14\.?10",""),
    (r"spe-am-001",  "demo"),
    (r"\bpisa\b",    "core"),
]
for pattern, rep in REPL:
    html = re.sub(pattern, rep, html, flags=re.IGNORECASE)

# ── Sanitizar y copiar data JSON ──────────────────────────────────────────
DATA_REPL = [
    (r"BanCoppel inicia operaciones[^\"]*",
     "El banco inicia operaciones — banca sobre la base de crédito del grupo retail"),
    (r"BanCoppel\b", "el banco"),
    (r"\bBanxico\b", "Banco Central"),
    (r"Coppel\b", "el grupo"),
    (r"App BanCoppel[^\"]*", "App móvil del banco — banca móvil"),
    (r"López-Moctezuma[^\"]*", "nueva dirección general (foco inclusión financiera)"),
]
data_text = SRC_DATA.read_text(encoding="utf-8")
for pattern, rep in DATA_REPL:
    data_text = re.sub(pattern, rep, data_text, flags=re.IGNORECASE)
OUT_DATA.parent.mkdir(parents=True, exist_ok=True)
OUT_DATA.write_text(data_text, encoding="utf-8")

# ── Output HTML ─────────────────────────────────────────────────────────────
OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
OUT_HTML.write_text(html, encoding="utf-8")

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes)")
print(f"[ok] {OUT_DATA.name}  ({OUT_DATA.stat().st_size:,} bytes)")

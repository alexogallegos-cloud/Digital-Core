"""
build-showcase-dependencias.py — Genera portal/showcase-dependencias.html
DEMOSTRACIÓN del potencial del Digital Brain — Capa 4 · Intención (Grafo de Dependencias).
Toma el grafo de dependencias cross-dominio de un engagement real (BanCoppel Informix),
lo ANONIMIZA y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra qué produce el brain al analizar las dependencias entre dominios.
"""
import re, pathlib, shutil

ROOT     = pathlib.Path(__file__).parent.parent
SRC_HTML = (ROOT.parent.parent
            / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
            / "dependency-graph-bcop.html")
OUT_HTML = ROOT / "portal" / "showcase-dependencias.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

html = SRC_HTML.read_text(encoding="utf-8")

# ── Paleta BanCoppel → AXA ─────────────────────────────────────────────────
html = (html
    .replace("--yellow:#F0D224",    "--yellow:#FF1721")
    .replace("--blue:#3D5FCD",      "--blue:#2255CC")
    .replace("--blued:#122FB1",     "--blued:#00008F")
    .replace("--bluedd:#0d2185",    "--bluedd:#00006A")
    .replace("rgba(240,210,36,.22)", "rgba(255,23,33,.18)")
    .replace("rgba(240,210,36,",     "rgba(255,23,33,")
    .replace("#F0D224",             "#FF1721")
    .replace("#f0d224",             "#FF1721")
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

# ── Título ─────────────────────────────────────────────────────────────────
html = re.sub(r'<title>.*?</title>',
    '<title>Digital Brain · Grafo de Dependencias (demo) — AXA</title>', html)

# ── Nav ────────────────────────────────────────────────────────────────────
html = re.sub(r'Informix\s*[·•â€¢]\s*Grafo[^<]*',
    'Digital Brain · Grafo de Dependencias', html)
html = re.sub(r'Informix\s*[·•]\s*Dependencias[^<]*',
    'Digital Brain · Grafo de Dependencias', html)
html = html.replace('href="index-bcop-v2.html"', 'href="index.html"')
html = html.replace("href='index-bcop-v2.html'", "href='index.html'")
html = html.replace('<span class="v2badge">v2</span>',
    '<span class="v2badge">DEMO</span>')

# ── Footer ─────────────────────────────────────────────────────────────────
html = re.sub(
    r'<footer>.*?</footer>',
    '<footer>Digital Brain &middot; Grafo de Dependencias (demo) &middot; '
    'AXA Insurance P&amp;C &middot; datos anonimizados</footer>',
    html, flags=re.S
)

# ── Barrido final ──────────────────────────────────────────────────────────
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
]
for pattern, rep in REPL:
    html = re.sub(pattern, rep, html, flags=re.IGNORECASE)

OUT_HTML.parent.mkdir(parents=True, exist_ok=True)
OUT_HTML.write_text(html, encoding="utf-8")

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes)")
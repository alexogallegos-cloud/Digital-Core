"""
build-showcase-almas.py — Genera portal/showcase-almas.html
DEMOSTRACIÓN del potencial del Digital Brain — Capa 2 · Almas.
Toma el Relevo Generacional de un engagement real (BanCoppel Informix),
lo ANONIMIZA y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra qué produce el brain sobre las generaciones de
desarrolladores, la deuda acumulada y el vocabulario heredado.
"""
import re, pathlib, shutil

ROOT     = pathlib.Path(__file__).parent.parent
SRC_HTML = (ROOT.parent.parent
            / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
            / "generations-bcop-v2.html")
OUT_HTML = ROOT / "portal" / "showcase-almas.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

html = SRC_HTML.read_text(encoding="utf-8")

# ── Paleta BanCoppel → AXA ─────────────────────────────────────────────────
html = (html
    .replace("--yellow:#F0D224",   "--yellow:#FF1721")
    .replace("--blue:#3D5FCD",     "--blue:#2255CC")
    .replace("--blued:#122FB1",    "--blued:#00008F")
    .replace("rgba(240,210,36,.22)", "rgba(255,23,33,.18)")  # aurora blob
    .replace("rgba(240,210,36,",     "rgba(255,23,33,")      # any remaining yellow refs
)
# nav badge: dark text on yellow → light text on AXA red
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
    "<title>Informix · Relevo Generacional v2</title>",
    "<title>Digital Brain · Almas del Sistema (demo) — AXA</title>"
)

# ── Nav: texto central + badge + back link ─────────────────────────────────
html = html.replace(
    "Informix · Relevo Generacional y Deuda",
    "Digital Brain · Almas del Sistema"
)
html = html.replace(
    '<span class="v2badge">v2</span>',
    '<span class="v2badge">DEMO</span>'
)
html = html.replace('href="index-bcop-v2.html"', 'href="index.html"')
html = html.replace("href='index-bcop-v2.html'", "href='index.html'")

# ── Footer ─────────────────────────────────────────────────────────────────
html = re.sub(
    r'<footer>.*?</footer>',
    '<footer>Digital Brain &middot; Almas del Sistema (demo) &middot; '
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
    (r"pisa\b",      "core"),
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

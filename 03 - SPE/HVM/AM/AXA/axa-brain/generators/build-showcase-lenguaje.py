"""
build-showcase-lenguaje.py — Genera portal/showcase-lenguaje.html (+ data/showcase-reglas.json)
DEMOSTRACIÓN del potencial del Digital Brain — Capa 1 · Lenguaje.
Toma el catálogo de reglas de negocio de un engagement de modernización real,
lo ANONIMIZA (cliente y sistemas) y lo rebrandea con AXA, como showcase.
NO es data de AXA — ilustra qué produce el brain cuando hay discovery de código fuente.
"""
import json, re, pathlib, shutil

ROOT = pathlib.Path(__file__).parent.parent
SRC  = ROOT.parent.parent / "BanCoppel" / "systems" / "core" / "Informix" / "portal"
SRC_DATA = SRC / "data" / "rules-portal-data.json"
SRC_HTML = SRC / "rules-catalog-bcop.html"
OUT_DATA = ROOT / "portal" / "data" / "showcase-reglas.json"
OUT_HTML = ROOT / "portal" / "showcase-lenguaje.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

# ── Blocklist de identificadores de cliente/vendor (se eliminan de TODOS los campos) ──
REPL = [
    (r"bancoppel", "el banco"),
    (r"bcopcore", "core"),
    (r"bcop", "core"),
    (r"coppel", ""),
    (r"informix", "el core"),
    (r"\bibm\b", ""),
    (r"ids ?14\.?10", ""),
    (r"smartvista", "procesador de tarjetas"),
    (r"\bbpc\b", ""),
    (r"temenos", ""),
    (r"transact", ""),
    (r"\bunity\b", ""),
    (r"\bapolo\b", ""),
    (r"intercard", "tarjetas"),
    (r"\blide\b", "PLD"),
    (r"cuenta efectiva digital", "cuenta digital"),
    (r"\bced\b", "cuenta digital"),
]
RX = [(re.compile(p, re.IGNORECASE), r) for p, r in REPL]


def clean(s):
    if not isinstance(s, str):
        return s
    for rx, rep in RX:
        s = rx.sub(rep, s)
    return re.sub(r"\s{2,}", " ", s).strip()


data = json.loads(SRC_DATA.read_text(encoding="utf-8"))

# Genericizar nombres de base de datos (db) a etiquetas neutrales estables
db_map = {}
for r in data.get("rules", []):
    db = r.get("db")
    if db and db not in db_map:
        db_map[db] = f"db-{len(db_map)+1:02d}"

# genericizar db primero
for r in data.get("rules", []):
    if r.get("db") in db_map:
        r["db"] = db_map[r["db"]]


def scrub(o):
    """Limpia recursivamente TODOS los strings (valores) de la estructura."""
    if isinstance(o, str):
        return clean(o)
    if isinstance(o, list):
        return [scrub(x) for x in o]
    if isinstance(o, dict):
        return {k: scrub(v) for k, v in o.items()}
    return o


data = scrub(data)

OUT_DATA.parent.mkdir(parents=True, exist_ok=True)
OUT_DATA.write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")

# ── Rebranding del shell HTML ─────────────────────────────────────────────────
html = SRC_HTML.read_text(encoding="utf-8")

# Logo: reemplaza el data-URI base64 por el PNG de AXA
html = re.sub(r'src="data:image/png;base64,[^"]*"\s*alt="[^"]*"', 'src="logos/Axa_logo.png" alt="AXA"', html)

# Paleta BanCoppel -> AXA (azul #00008F, rojo #FF1721)
html = (html
    .replace("--blue:#3D5FCD", "--blue:#2E4FD8")
    .replace("--blued:#122FB1", "--blued:#00008F")
    .replace("--yellow:#F0D224", "--yellow:#FF1721")
    .replace("--acc:#F0D224", "--acc:#FF1721"))

# Textos / branding / rutas
html = (html
    .replace("<title>el core · Reglas de Negocio</title>", "<title>Digital Brain · Extracción de Lenguaje (demo) — AXA</title>")
    .replace("<title>Informix · Reglas de Negocio</title>", "<title>Digital Brain · Extracción de Lenguaje (demo) — AXA</title>")
    .replace("SPE-AM-001 <em>›</em> Reglas de Negocio", "DEMOSTRACIÓN <em>›</em> Capa 1 · Lenguaje")
    .replace("Informix · DT-Reglas v1.6.0", "Digital Brain · Capacidad de extracción de reglas")
    .replace('href="index-bcop-v2.html"', 'href="index.html"')
    .replace("fetch('data/rules-portal-data.json')", "fetch('data/showcase-reglas.json')")
    .replace('fetch("data/rules-portal-data.json")', "fetch('data/showcase-reglas.json')"))

# Sub del hero: reemplazar la frase que menciona cliente/tecnología por marco demo
html = re.sub(
    r'<div class="hero-sub">.*?</div>',
    '<div class="hero-sub">Reglas de negocio destiladas de los stored procedures de un core bancario legacy '
    '&mdash; ejemplo real de un engagement de modernizaci&oacute;n, con <b>cliente y sistemas anonimizados</b>.<br>'
    'Ilustra lo que el Digital Brain produce cuando existe discovery de c&oacute;digo fuente: la l&oacute;gica que '
    'gobierna cada c&aacute;lculo, validaci&oacute;n y umbral, inferida del c&oacute;digo y hecha legible.</div>',
    html, count=1, flags=re.S)


# barrido final de tokens de cliente que hayan quedado en el shell
for rx, rep in RX:
    html = rx.sub(rep, html)

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

OUT_HTML.write_text(html, encoding="utf-8")
n = len(data.get("rules", []))
print(f"[ok] {OUT_HTML.name}  ({OUT_HTML.stat().st_size:,} bytes) · {n} reglas anonimizadas · {len(db_map)} DBs genericizadas")
print(f"[ok] {OUT_DATA.name}  ({OUT_DATA.stat().st_size:,} bytes)")
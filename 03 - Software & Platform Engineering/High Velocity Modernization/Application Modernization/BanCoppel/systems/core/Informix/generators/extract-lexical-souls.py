#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-lexical-souls.py — Cruce profundo Almas × Evolución × Vocabulario.
Un solo barrido del código relaciona, por SP: año de creación (comentarios) +
autor(es) (headers) + términos de vocabulario (nombre). Produce:
 · Curva de crecimiento del lenguaje (vocabulario acumulado por año + términos nuevos/año)
 · Generaciones de almas (span activo de cada autor en el tiempo)
 · Huella léxica por alma (términos característicos de cada autor)

Gemelo Cognitivo — capas 1 (Lenguaje) × 2 (Almas) × 3 (Biografía).
Genera: lexical-evolution-bcop.html + lexical-souls-data.json
"""
import os, re, glob, json, unicodedata
from collections import Counter, defaultdict
import sp_vocab

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
CAT = sp_vocab.CAT

DOM = {"bdicnweb","bdinteg","bdicred","bdicheq","bdisac","bdisolic",
       "bdiaclaracion","bdispei","bdimnsj","bdisuc","bdicobranza","bdicont"}
YMIN, YMAX = 2007, 2026
RE_YEAR = re.compile(r'\b(199[89]|20[0-2]\d)\b')

# ── autoría (mismo criterio que build-souls) ──
STOP = re.compile(r'(la consulta|correctamente|los datos|el proceso|la operaci|el registro|la tabla|'
                  r'se realiz|ninguno|n/?a\b|pendiente|xxx|nombre|aqui|autoriz|usuario|sistema|'
                  r'actualiz|se agrega|valida|obtiene|inserta|el sp\b|este |para el|nueva )', re.I)
RE_A1 = re.compile(r'\bautor(?:es)?\b\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A2 = re.compile(r'\b(?:realiz|elabor|program|desarroll|modific|dise[ñn]|cre|hech)\w*\s+por\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A3 = re.compile(r'\b(?:realiz[oó]|elabor[oó]|program[oó]|modific[oó]|dise[ñn][oó])\s*[:=]\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
AUTH = [RE_A1, RE_A2, RE_A3]
NONPERSON = {"root","admin","administrador","informix","dba","test","soporte","sistema","usuario","autor","programa","na","none"}
def clean_name(s):
    s = s.strip().strip(" .-:*=/\t\"'")
    s = re.split(r'\s{2,}|\bfecha\b|\brqm\b|\bproyecto\b|\bversion\b|\bmodific\w*\b|\d{1,2}[/-]\d|\(|,|;', s, flags=re.I)[0].strip()
    s = re.sub(r'\s+', ' ', s).strip(" .-'\"")
    if len(s) < 4 or any(c.isdigit() for c in s): return None
    if STOP.search(s) or not (1 <= len(s.split()) <= 5): return None
    if not re.match(r"^[A-Za-zÁÉÍÓÚÑñáéíóú][A-Za-zÁÉÍÓÚÑñáéíóú.\- ]+$", s): return None
    return s.title()
def canon(name):
    k = "".join(c for c in unicodedata.normalize("NFD", name.lower()) if unicodedata.category(c) != "Mn")
    return re.sub(r"\s+", " ", re.sub(r"[^a-z ]", "", k)).strip()
def score(n): return (sum(c in "áéíóúÁÉÍÓÚñÑ" for c in n), len(n))
def authors(head):
    out = set()
    for rx in AUTH:
        for m in rx.findall(head):
            nm = clean_name(m)
            if nm: out.add(nm)
    return out

# ── barrido único ──
term_first = {}                       # término -> primer año visto (en SP con fecha)
gterm = Counter()                     # frecuencia global del término (todos los SP)
term_seen = set()
author_terms = defaultdict(Counter)   # alma -> Counter(término)
author_years = defaultdict(set)       # alma -> {años}
author_sp = Counter()                 # alma -> #SP firmados
disp = {}
n_files = n_dated = n_auth_dated = 0

for fp in glob.glob(SRC + "*.sql"):
    fn = os.path.basename(fp)
    db = next((k for k in DOM if fn.startswith(k + "_")), None)
    if not db: continue
    sp = fn[len(db) + 1:-4]
    n_files += 1
    try: head = open(fp, encoding="utf-8", errors="replace").read()[:4500]
    except Exception: continue
    # año de creación (mínimo año en líneas de comentario del header)
    yrs = set()
    for ln in head.split("\n")[:80]:
        s = ln.strip()
        if s.startswith("--") or s.startswith("{"):
            for y in RE_YEAR.findall(s):
                yi = int(y)
                if YMIN <= yi <= YMAX: yrs.add(yi)
    ycre = min(yrs) if yrs else None
    if ycre: n_dated += 1
    # términos del nombre (reconocidos en el vocabulario)
    toks = [t for t in sp_vocab.tokenize(sp) if t in CAT and len(t) >= 3]
    tset = set(toks)
    for t in tset:
        gterm[t] += 1; term_seen.add(t)
        if ycre and (t not in term_first or ycre < term_first[t]): term_first[t] = ycre
    # autoría
    ks = set()
    for nm in authors(head):
        k = canon(nm)
        if not k or k in NONPERSON: continue
        if k not in disp or score(nm) > score(disp[k]): disp[k] = nm
        ks.add(k)
    for k in ks:
        author_sp[k] += 1
        for t in tset: author_terms[k][t] += 1
        if ycre: author_years[k].add(ycre)
    if ks and ycre: n_auth_dated += 1

# ── crecimiento del lenguaje ──
years = list(range(YMIN, YMAX + 1))
newby = {y: 0 for y in years}
for t, y in term_first.items():
    if YMIN <= y <= YMAX: newby[y] += 1
cum, run = [], 0
for y in years:
    run += newby[y]; cum.append(run)
n_terms_dated = len(term_first)
peak_year = max(years, key=lambda y: newby[y])

# ── generaciones de almas (span activo) ──
top_auth = [a for a, _ in author_sp.most_common(40)]
gens = []
for a in top_auth:
    ys = author_years.get(a, set())
    if not ys: continue
    gens.append({"name": disp.get(a, a), "first": min(ys), "last": max(ys),
                 "sps": author_sp[a], "active": len(ys)})
gens.sort(key=lambda g: (g["first"], -g["sps"]))
gens = gens[:16]

# ── huella léxica por alma (términos característicos) ──
def meaning(t): return CAT[t][1] if t in CAT else t
fingerprints = []
for a in author_sp.most_common(10):
    ak = a[0]; at = author_terms[ak]
    scored = [(t, at[t] * at[t] / gterm[t]) for t in at if gterm[t] > 0 and at[t] >= 3]
    sig = [t for t, _ in sorted(scored, key=lambda x: -x[1])[:9]]
    if sig:
        fingerprints.append({"name": disp.get(ak, ak), "sps": author_sp[ak],
                             "terms": [{"t": t, "m": meaning(t)[:40]} for t in sig]})

DATA = {"years": years, "cum": cum, "newby": [newby[y] for y in years],
        "n_files": n_files, "n_dated": n_dated, "n_terms_dated": n_terms_dated,
        "n_terms_all": len(term_seen), "peak_year": peak_year, "peak_new": newby[peak_year],
        "n_souls_dated": len(gens), "gens": gens, "fingerprints": fingerprints}
json.dump(DATA, open(BASE + "portal/data/lexical-souls-data.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

# ── SVG curva de crecimiento (server-side) ──
W, H = 900, 260; PL, PR, PT, PB = 46, 16, 22, 30
xmax = len(years) - 1; ymax = max(cum[-1], 1); nmax = max(max(DATA["newby"]), 1)
X = lambda i: PL + (W - PL - PR) * i / max(xmax, 1)
Y = lambda v: (H - PB) - (H - PT - PB) * v / ymax
line = " ".join(f"{X(i):.1f},{Y(cum[i]):.1f}" for i in range(len(years)))
area = f"{PL},{H-PB} " + line + f" {W-PR},{H-PB}"
bars = ""
bw = (W - PL - PR) / len(years) * .5
for i, y in enumerate(years):
    h = (H - PT - PB) * DATA["newby"][i] / nmax * .5
    bars += f'<rect x="{X(i)-bw/2:.1f}" y="{H-PB-h:.1f}" width="{bw:.1f}" height="{h:.1f}" fill="#F0D224" opacity=".30"/>'
xlabels = "".join(f'<text x="{X(i):.1f}" y="{H-PB+16}" class="ax" text-anchor="middle">{y if y%2==1 else ""}</text>' for i, y in enumerate(years))
yticks = ""
for f in (0, .25, .5, .75, 1):
    v = ymax * f
    yticks += (f'<line x1="{PL}" y1="{Y(v):.1f}" x2="{W-PR}" y2="{Y(v):.1f}" class="grid"/>'
               f'<text x="{PL-6}" y="{Y(v)+3:.1f}" class="ax" text-anchor="end">{int(v)}</text>')
dots = "".join(f'<circle cx="{X(i):.1f}" cy="{Y(cum[i]):.1f}" r="2.4" fill="#6f8ce6"/>' for i in range(len(years)))
svg = (f'<svg viewBox="0 0 {W} {H}" class="chart">{yticks}{bars}'
       f'<polygon points="{area}" fill="url(#g)" opacity=".33"/>'
       f'<polyline points="{line}" fill="none" stroke="#6f8ce6" stroke-width="2.5"/>{dots}{xlabels}'
       f'<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1">'
       f'<stop offset="0" stop-color="#6f8ce6"/><stop offset="1" stop-color="#6f8ce6" stop-opacity="0"/></linearGradient></defs></svg>')

# generaciones (barras CSS por span de años)
span = YMAX - YMIN
gen_rows = ""
for g in DATA["gens"]:
    left = 100 * (g["first"] - YMIN) / span
    width = max(100 * (g["last"] - g["first"] + 1) / span, 2)
    gen_rows += (f'<div class="grow"><div class="gn">{g["name"]}</div>'
                 f'<div class="gtrack"><div class="gbar" style="left:{left:.1f}%;width:{width:.1f}%" '
                 f'title="{g["first"]}–{g["last"]} · {g["sps"]} SPs">{g["first"]}–{g["last"]}</div></div>'
                 f'<div class="gv">{g["sps"]}<span> SPs</span></div></div>')

fp_cards = ""
for f in DATA["fingerprints"]:
    chips = "".join(f'<span class="chip" title="{t["m"]}">{t["t"]}</span>' for t in f["terms"])
    fp_cards += (f'<div class="fp"><div class="fpn">{f["name"]}<span> · {f["sps"]} SPs</span></div>'
                 f'<div class="fpc">{chips}</div></div>')

CSS = """
:root{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;--txt:#EAEDF7;--muted:#9aa4c4;--muted2:#818ab0}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,Calibri,sans-serif;line-height:1.5}
header{background:linear-gradient(135deg,var(--blued),#0d2185);border-bottom:3px solid var(--yellow);padding:15px 30px;display:flex;align-items:center;gap:14px;position:sticky;top:0;z-index:10}
header img{height:24px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
header h1{font-size:16px;font-weight:800} header .sub{font-size:10.5px;color:#c9d3f5;margin-top:1px}
.wrap{max-width:1000px;margin:0 auto;padding:26px 30px 60px}
.tiles{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:30px}
@media(max-width:760px){.tiles{grid-template-columns:repeat(2,1fr)}}
.tile{background:var(--panel);border:1px solid var(--line);border-top:3px solid var(--yellow);border-radius:11px;padding:15px 13px;text-align:center}
.tile .n{font-size:25px;font-weight:800;color:#fff} .tile .l{font-size:9.5px;color:var(--muted2);margin-top:6px;text-transform:uppercase;letter-spacing:.05em}
section{margin-top:30px}
h2{font-size:17px;font-weight:800;margin-bottom:3px} h2 .k{display:block;font-size:11px;font-weight:700;color:var(--yellow);letter-spacing:.14em;text-transform:uppercase;margin-bottom:5px}
.sd{font-size:12.5px;color:var(--muted);margin-bottom:14px;max-width:82ch}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:18px 20px}
.chart{width:100%;height:auto} .ax{fill:#818ab0;font-size:10px} .grid{stroke:#1d2a55;stroke-width:1}
.leg2{font-size:11px;color:var(--muted2);margin-top:8px} .leg2 i{display:inline-block;width:16px;height:0;border-top:2.5px solid #6f8ce6;vertical-align:middle;margin:0 5px 0 12px} .leg2 b{display:inline-block;width:11px;height:11px;background:#F0D224;opacity:.4;border-radius:2px;vertical-align:middle;margin:0 5px 0 12px}
.grow{display:grid;grid-template-columns:220px 1fr auto;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}
@media(max-width:640px){.grow{grid-template-columns:1fr}}
.gn{color:#dfe6ff;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.gtrack{position:relative;height:19px;background:#0c1747;border-radius:6px}
.gbar{position:absolute;top:0;height:100%;background:linear-gradient(90deg,var(--blue),#6f8ce6);border-radius:6px;font-size:9.5px;color:#eaf0ff;display:flex;align-items:center;justify-content:center;font-weight:700;min-width:44px;white-space:nowrap;overflow:hidden}
.gv{color:var(--muted);text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap} .gv span{font-size:10px;color:var(--muted2)}
.fpgrid{display:grid;grid-template-columns:1fr 1fr;gap:14px}
@media(max-width:720px){.fpgrid{grid-template-columns:1fr}}
.fp{background:var(--panel);border:1px solid var(--line);border-radius:13px;padding:16px 18px}
.fpn{font-size:14px;font-weight:800;color:#fff;margin-bottom:10px} .fpn span{font-size:11px;color:var(--muted2);font-weight:500}
.chip{display:inline-block;background:#0c1747;border:1px solid var(--line);border-radius:20px;padding:4px 11px;font-size:11.5px;color:var(--muted);margin:0 5px 7px 0;cursor:help} .chip:hover{border-color:var(--yellow);color:#fff}
.note{margin-top:24px;padding:15px 18px;font-size:12.5px;color:var(--muted);border-radius:14px;background:rgba(255,255,255,.055);backdrop-filter:blur(15px) saturate(140%);-webkit-backdrop-filter:blur(15px) saturate(140%);box-shadow:0 8px 28px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(240,210,36,.16)} .note b{color:#e4eaff}
footer{margin-top:34px;font-size:11px;color:var(--muted2);text-align:center;border-top:1px solid var(--line);padding-top:16px}
"""

# ── deuda de nombrado: sinónimos/alias que producen los dialectos ──
_terms = {t: c for t, (c, m, e) in sp_vocab.CAT.items() if c not in ("AMBIGUO", "PREFIJO") and e != "gap"}
_meanof = {t: m for t, (c, m, e) in sp_vocab.CAT.items()}
_par = {t: t for t in _terms}
def _f(x):
    while _par[x] != x: _par[x] = _par[_par[x]]; x = _par[x]
    return x
def _u(a, b):
    ra, rb = _f(a), _f(b)
    if ra != rb: _par[ra] = rb
_mg = {}
for _t in _terms:
    _k = re.sub(r"[^a-z0-9 ]", "", _meanof[_t].lower().split("(")[0].split(" / ")[0]).strip()
    if _k: _mg.setdefault(_k, []).append(_t)
for _ts in _mg.values():
    for _x in _ts[1:]: _u(_ts[0], _x)
for _t in _terms:
    for _pl in (_t + "s", _t + "es"):
        if _pl in _terms and _terms[_pl] == _terms[_t]: _u(_t, _pl)
_cmp = {}
for _t in _par: _cmp.setdefault(_f(_t), []).append(_t)
_syn = {r: ts for r, ts in _cmp.items() if len(ts) > 1}
n_syn_c = len(_syn); n_syn_a = sum(len(v) for v in _syn.values())
from vocab_dedup import counts as _vc; _C = _vc()  # fuente única de conteos de vocabulario
n_syn_c = _C['conceptos']; n_syn_a = _C['alias']  # 86 conceptos · 196 términos-alias (idéntico en todas las vistas)
pct_dated = round(100 * n_dated / n_files) if n_files else 0
HTML = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Evolución del Lenguaje y las Almas</title><style>{CSS}</style></head><body>
<header><img src="bancoppel-logo.png" alt="BanCoppel">
 <div><h1>Evolución del Lenguaje y las Almas</h1><div class="sub">Gemelo Cognitivo · capas 1×2×3 (lenguaje × almas × tiempo) · SPE-AM-001</div></div></header>
<div class="wrap">
 <div class="tiles">
  <div class="tile"><div class="n">{DATA['n_terms_all']}</div><div class="l">Términos del vocabulario</div></div>
  <div class="tile"><div class="n">{DATA['n_terms_dated']}</div><div class="l">Términos con año conocido</div></div>
  <div class="tile"><div class="n">{DATA['peak_year']}</div><div class="l">Año pico de nuevos términos</div></div>
  <div class="tile"><div class="n">{DATA['n_souls_dated']}</div><div class="l">Almas con línea de tiempo</div></div>
  <div class="tile"><div class="n">{pct_dated}%</div><div class="l">SPs con fecha</div></div>
 </div>

 <section><h2><span class="k">Capa 1 × 3</span>Crecimiento del lenguaje en el tiempo</h2>
  <div class="sd">Vocabulario de negocio <b>acumulado</b> año por año (línea) y <b>términos nuevos</b> que aparecen cada año (barras amarillas). Muestra cómo el idioma del sistema se fue expandiendo — cada término nuevo suele acompañar un producto o cambio regulatorio.</div>
  <div class="panel">{svg}
   <div class="leg2"><i></i>vocabulario acumulado<b></b>términos nuevos por año</div></div></section>

 <section><h2><span class="k">Capa 2 × 3</span>Generaciones de almas</h2>
  <div class="sd">Periodo activo de cada alma (del primer al último año en que dejó huella fechada). Revela las <b>generaciones</b> de desarrolladores que se relevaron sobre el core.</div>
  <div class="panel">{gen_rows or '<span class="gv">sin spans fechados</span>'}</div></section>

 <section><h2><span class="k">Capa 1 × 2</span>Huella léxica de cada alma</h2>
  <div class="sd">Los términos <b>característicos</b> de cada alma — el vocabulario que usó de forma desproporcionada frente al resto. Es el "dialecto" de cada quien (pasa el mouse para ver el significado).</div>
  <div class="fpgrid">{fp_cards}</div></section>

 <div class="note" style="border-left:3px solid var(--yellow)"><b>Los dialectos generan sinónimos — deuda de nombrado.</b> Como cada autor y época nombró los mismos conceptos a su manera, el vocabulario acumuló <b>{n_syn_c} conceptos</b> escritos bajo <b>{n_syn_a} términos-alias</b> (cliente/cte, movimiento/mov/movto). Esa divergencia entre dialectos es <b>deuda técnica</b>: el mismo negocio con muchos nombres. El término canónico y todos los alias están en el <b>Reporte de Vocabulario</b>.</div>
 <div class="note"><b>Honestidad del cruce.</b> El eje temporal usa las fechas de los comentarios (~{pct_dated}% de {n_files:,} SPs), así que la curva muestra la <b>forma</b> del crecimiento, no el censo exacto. La huella léxica usa los {DATA['n_terms_all']} términos reconocidos del vocabulario controlado (Capa 1). La atribución de autoría es la declarada en headers (Capa 2). Donde falta fecha o autor, el SP no entra al cruce — por eso esto es una <b>muestra representativa</b>, no el 100%.</div>
 <footer>Gemelo Cognitivo · capas 1×2×3 · generado por <code>extract-lexical-souls.py</code></footer>
</div></body></html>"""
open(BASE + "old/lexical-evolution-bcop.html", "w", encoding="utf-8").write(HTML)
print("lexical-evolution-bcop.html + lexical-souls-data.json escritos")
print(f"  {n_files:,} SPs · {n_dated:,} con fecha ({pct_dated}%) · {len(term_seen)} términos ({n_terms_dated} con año)")
print(f"  año pico de nuevos términos: {peak_year} ({newby[peak_year]} nuevos) · almas con timeline: {len(gens)}")
print("  crecimiento acumulado del vocabulario:")
for i, y in enumerate(years):
    if y % 2 == 1: print(f"     {y}  {'#'*int(38*cum[i]/max(cum[-1],1))} {cum[i]}")
print("  huella léxica (top 3 almas):")
for f in fingerprints[:3]: print(f"     {f['name']:28} {', '.join(t['t'] for t in f['terms'][:6])}")
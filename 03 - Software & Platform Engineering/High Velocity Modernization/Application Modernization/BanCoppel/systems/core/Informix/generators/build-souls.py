#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-souls.py — Capa 2 del Gemelo Cognitivo: "Mapa de las Almas".
Recupera los vestigios de autoría (Autor/Realizó/Modificó/Proyecto/RQM) de los
headers de los SPs y reconstruye: censo de almas, concentración de conocimiento
(bus factor) por dominio, huella de terceros, código huérfano y proyectos.

Fuente: headers de comentarios (~27% cobertura declarada). Estilometría = v2.
Genera: souls-data.json + souls-bcop.html · SPE-AM-001 · Gemelo Cognitivo Capa 2
"""
import os, re, glob, json, unicodedata
from collections import Counter, defaultdict

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"

DOM = {"bdicnweb":("d01","Canal Digital"),"bdinteg":("d02","Integración/Auth"),
 "bdicred":("d03","Créditos"),"bdicheq":("d04","Cheques/Cuentas"),"bdisac":("d05","Saldos"),
 "bdisolic":("d06","Solicitudes"),"bdiaclaracion":("d07","Aclaraciones"),"bdispei":("d08","SPEI"),
 "bdimnsj":("d09","Mensajería"),"bdisuc":("d10","Sucursales"),"bdicobranza":("d11","Cobranza"),
 "bdicont":("d12","Contabilidad")}

# autoría: la palabra debe ir seguida de ':' o '=' (campo de header), no en prosa.
RE_PROY = re.compile(r'\bproyecto\s*[:=]\s*([^\n\r]{2,40})', re.I)
RE_RQM  = re.compile(r'\b(?:RQM|requerimiento)\b', re.I)
STOP = re.compile(r'(la consulta|correctamente|los datos|el proceso|la operaci|el registro|la tabla|'
                  r'se realiz|ninguno|n/?a\b|pendiente|xxx|nombre|aqui|autoriz|usuario|sistema|'
                  r'actualiz|se agrega|valida|obtiene|inserta|el sp\b|este |para el|nueva )', re.I)

# 'autor' es sustantivo → \b lo aísla de "autorización"; delimitador opcional.
# los verbos (realizó…) requieren 'por' o ':' para no capturar prosa.
RE_A1 = re.compile(r'\bautor(?:es)?\b\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A2 = re.compile(r'\b(?:realiz|elabor|program|desarroll|modific|dise[ñn]|cre|hech)\w*\s+por\s*[:=\-]?\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
RE_A3 = re.compile(r'\b(?:realiz[oó]|elabor[oó]|program[oó]|modific[oó]|dise[ñn][oó])\s*[:=]\s*([A-Za-zÁÉÍÓÚÑñ][^\n\r]{2,45})', re.I)
AUTH = [RE_A1, RE_A2, RE_A3]

def clean_name(s):
    s = s.strip().strip('.-:*=/ \t"\'')
    s = re.split(r'\s{2,}|\bfecha\b|\brqm\b|\bproyecto\b|\bversion\b|\bmodific\w*\b|\d{1,2}[/-]\d|\(|,|;', s, flags=re.I)[0].strip()
    s = re.sub(r'\s+', ' ', s).strip(" .-'\"")
    if len(s) < 4 or any(c.isdigit() for c in s): return None
    if STOP.search(s): return None
    if not (1 <= len(s.split()) <= 5): return None
    if not re.match(r"^[A-Za-zÁÉÍÓÚÑñáéíóú][A-Za-zÁÉÍÓÚÑñáéíóú.\- ]+$", s): return None
    return s.title()

def authors(head):
    out = set()
    for rx in AUTH:
        for m in rx.findall(head):
            nm = clean_name(m)
            if nm: out.add(nm)
    return out

NONPERSON = {"root","admin","administrador","informix","dba","test","soporte","sistema","usuario","autor","programa","na","none"}
def canon(name):  # clave normalizada sin acentos → dedup de variantes del mismo autor
    k = "".join(c for c in unicodedata.normalize("NFD", name.lower()) if unicodedata.category(c) != "Mn")
    return re.sub(r"\s+", " ", re.sub(r"[^a-z ]", "", k)).strip()
def score(n):  # preferimos la variante con más acentos, luego la más larga, como display
    return (sum(c in "áéíóúÁÉÍÓÚñÑ" for c in n), len(n))

souls = Counter(); soul_dom = defaultdict(Counter); dom_soul = defaultdict(Counter)
projects = Counter(); n_files = n_authored = n_orphan = rqm_files = 0
dom_files = Counter(); dom_authored = Counter(); disp = {}

for fp in glob.glob(SRC + "*.sql"):
    fn = os.path.basename(fp)
    db = next((k for k in DOM if fn.startswith(k + "_")), None)
    if not db: continue
    dom = DOM[db][0]; n_files += 1; dom_files[dom] += 1
    try: head = open(fp, encoding="utf-8", errors="replace").read()[:5000]
    except Exception: continue
    keys = set()
    for nm in authors(head):
        k = canon(nm)
        if not k or k in NONPERSON: continue
        if k not in disp or score(nm) > score(disp[k]): disp[k] = nm
        keys.add(k)
    if keys:
        n_authored += 1; dom_authored[dom] += 1
        for k in keys:
            souls[k] += 1; soul_dom[k][dom] += 1; dom_soul[dom][k] += 1
    else:
        n_orphan += 1
    for p in RE_PROY.findall(head):
        pc = clean_name(p) or re.sub(r'\s+', ' ', p).strip()[:30]
        if pc and len(pc) > 2: projects[pc] += 1
    if RE_RQM.search(head): rqm_files += 1

n_souls = len(souls)
pct_auth = round(100 * n_authored / n_files) if n_files else 0
pct_orph = round(100 * n_orphan / n_files) if n_files else 0
# terceros/equipos (heurística: token único no-personal frecuente)
VENDORS = {"solser", "hildebrando", "softtek", "neoris", "gbm", "praxis", "quarksoft", "tcs", "indra"}
top = souls.most_common(24)
# bus factor por dominio: share del autor #1 sobre los SP con autor de ese dominio
busf = []
for db,(did,name) in DOM.items():
    a = dom_authored.get(did, 0); tot = dom_files.get(did, 0)
    if not a: busf.append((did, name, 0, "—", 0, tot, 0)); continue
    wk, cnt = dom_soul[did].most_common(1)[0]
    share = round(100 * cnt / a)
    busf.append((did, name, share, disp.get(wk, wk), cnt, tot, len(dom_soul[did])))
busf.sort(key=lambda r: -r[2])

DATA = {"n_files": n_files, "n_souls": n_souls, "pct_auth": pct_auth, "pct_orph": pct_orph,
        "rqm_files": rqm_files, "n_projects": len(projects),
        "top_souls": [{"name": disp.get(k, k), "n": c, "doms": len(soul_dom[k])} for k, c in top],
        "busfactor": [{"dom": d, "name": nm, "share": s, "cnt": c, "tot": t, "authors": na, "who": w}
                      for d, nm, s, w, c, t, na in busf],
        "projects": projects.most_common(12)}
json.dump(DATA, open(BASE + "portal/data/souls-data.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

# ── HTML ──
mx = max((s["n"] for s in DATA["top_souls"]), default=1)
def is_vendor(n, c): return n.lower().split()[0] in VENDORS or (len(n.split()) == 1 and c >= 15)
souls_rows = ""
for s in DATA["top_souls"]:
    w = round(100 * s["n"] / mx)
    tag = ' <span class="vend">tercero/equipo</span>' if is_vendor(s["name"], s["n"]) else ""
    souls_rows += (f'<div class="row"><div class="rn">{s["name"]}{tag}</div>'
                   f'<div class="bar"><i style="width:{w}%"></i></div>'
                   f'<div class="rv">{s["n"]}<span> SPs · {s["doms"]} dom</span></div></div>')
bus_rows = ""
for b in DATA["busfactor"]:
    risk = "alta" if b["share"] >= 60 else ("media" if b["share"] >= 40 else "baja")
    bus_rows += (f'<div class="row"><div class="rn">{b["dom"].upper()} · {b["name"]}</div>'
                 f'<div class="bar"><i class="r-{risk}" style="width:{b["share"]}%"></i></div>'
                 f'<div class="rv">{b["share"]}%<span> · {b["who"][:22]} ({b["cnt"]}/{b["authors"]} almas)</span></div></div>')
proj_rows = "".join(f'<span class="chip">{p} <b>{c}</b></span>' for p, c in DATA["projects"])

HTML = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BCOPCore · Mapa de las Almas (Gemelo Cognitivo · Capa 2)</title>
<style>
:root{{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;--txt:#EAEDF7;--muted:#9aa4c4;--muted2:#818ab0}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,Calibri,sans-serif;line-height:1.5}}
header{{background:linear-gradient(135deg,var(--blued),#0d2185);border-bottom:3px solid var(--yellow);padding:15px 30px;display:flex;align-items:center;gap:14px;position:sticky;top:0;z-index:10}}
header img{{height:24px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
header h1{{font-size:16px;font-weight:800}} header .sub{{font-size:10.5px;color:#c9d3f5;margin-top:1px}}
.wrap{{max-width:1080px;margin:0 auto;padding:26px 30px 60px}}
.tiles{{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:30px}}
@media(max-width:760px){{.tiles{{grid-template-columns:repeat(2,1fr)}}}}
.tile{{background:var(--panel);border:1px solid var(--line);border-top:3px solid var(--yellow);border-radius:11px;padding:15px 14px;text-align:center;position:relative}}
.tile[data-tip]{{cursor:help}}
.tile[data-tip]:hover::after{{content:attr(data-tip);position:absolute;left:50%;top:calc(100% + 9px);transform:translateX(-50%);width:240px;background:rgba(8,12,32,.98);border:1px solid var(--line);border-radius:10px;padding:11px 13px;font-size:11px;color:var(--muted);line-height:1.5;z-index:30;box-shadow:0 10px 30px rgba(0,0,0,.6);text-transform:none;letter-spacing:normal;font-weight:400}}
.tile .n{{font-size:26px;font-weight:800;color:#fff}} .tile .l{{font-size:9.5px;color:var(--muted2);margin-top:6px;text-transform:uppercase;letter-spacing:.05em}}
section{{margin-top:28px}}
h2{{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:4px}}
h2 .k{{font-size:11px;font-weight:700;color:var(--yellow);letter-spacing:.14em;text-transform:uppercase;display:block;margin-bottom:5px}}
.sd{{font-size:12.5px;color:var(--muted);margin-bottom:14px;max-width:80ch}}
.panel{{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:18px 20px}}
.row{{display:grid;grid-template-columns:230px 1fr auto;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}}
@media(max-width:640px){{.row{{grid-template-columns:1fr}}}}
.rn{{color:#dfe6ff;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.bar{{background:#0c1747;border-radius:6px;height:15px;overflow:hidden}}
.bar i{{display:block;height:100%;background:linear-gradient(90deg,var(--blue),#6f8ce6);border-radius:6px}}
.bar i.r-alta{{background:linear-gradient(90deg,var(--yellow),#f6e27a)}}
.bar i.r-media{{background:linear-gradient(90deg,#8e79d6,#b7a6ea)}}
.bar i.r-baja{{background:linear-gradient(90deg,var(--blue),#6f8ce6)}}
.rv{{color:var(--muted);font-variant-numeric:tabular-nums;text-align:right;white-space:nowrap}} .rv span{{font-size:10px;color:var(--muted2)}}
.vend{{font-size:9px;background:rgba(240,210,36,.15);border:1px solid rgba(240,210,36,.35);color:var(--yellow);border-radius:10px;padding:1px 7px;margin-left:6px;font-weight:700}}
.chip{{display:inline-block;background:#0c1747;border:1px solid var(--line);border-radius:20px;padding:5px 12px;font-size:12px;color:var(--muted);margin:0 6px 8px 0}} .chip b{{color:var(--yellow)}}
.note{{margin-top:22px;padding:15px 18px;font-size:12.5px;color:var(--muted);border-radius:14px;background:rgba(255,255,255,.055);backdrop-filter:blur(15px) saturate(140%);-webkit-backdrop-filter:blur(15px) saturate(140%);box-shadow:0 8px 28px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(240,210,36,.16)}} .note b{{color:#e4eaff}}
.leg{{font-size:11px;color:var(--muted2);margin-top:10px}} .leg i{{display:inline-block;width:10px;height:10px;border-radius:3px;vertical-align:middle;margin:0 4px 0 10px}}
footer{{margin-top:36px;font-size:11px;color:var(--muted2);text-align:center;border-top:1px solid var(--line);padding-top:16px}}
</style></head><body>
<header><img src="bancoppel-logo.png" alt="BanCoppel">
 <div><h1>Mapa de las Almas</h1><div class="sub">Gemelo Cognitivo · Capa 2 (memoria social) · SPE-AM-001 · quién pensó el código</div></div></header>
<div class="wrap">
 <div class="tiles">
  <div class="tile" data-tip="Personas y equipos cuyo nombre aparece como autor en los headers del código, deduplicados por acentos y variantes de escritura."><div class="n">{n_souls}</div><div class="l">Almas identificadas</div></div>
  <div class="tile" data-tip="% de SPs cuyo header dice quién lo escribió (campo Autor/Realizó). El resto es código huérfano — no lo declara."><div class="n">{pct_auth}%</div><div class="l">Autoría declarada</div></div>
  <div class="tile" data-tip="Iniciativas con nombre propio detectadas en el campo Proyecto de los headers."><div class="n">{DATA['n_projects']}</div><div class="l">Proyectos con nombre</div></div>
  <div class="tile" data-tip="SPs con folio de Requerimiento (RQM) en el header — rastro del proceso de cambio formal / gobernanza. No valida que el folio exista en el sistema de tickets."><div class="n">{rqm_files:,}</div><div class="l">SPs con folio RQM</div></div>
  <div class="tile" data-tip="% de SPs SIN autor declarado. No es 'sin dueño' — es 'sin dueño declarado': máximo riesgo de pérdida de conocimiento."><div class="n">{pct_orph}%</div><div class="l">SPs huérfanos</div></div>
 </div>

 <section><h2><span class="k">Censo</span>Las almas que tocaron el código</h2>
  <div class="sd">Personas (y terceros) con más SPs firmados en los headers. Cada barra = número de SPs que llevan su huella; a la derecha, en cuántos dominios dejó rastro.</div>
  <div class="panel">{souls_rows}</div></section>

 <section><h2><span class="k">Bus factor</span>Concentración de conocimiento por dominio</h2>
  <div class="sd">Qué tan concentrado está el conocimiento: % de los SP con autoría de cada dominio que llevan la huella de <b>una sola alma</b>. Amarillo = alta concentración (riesgo si esa persona ya no está).</div>
  <div class="panel">{bus_rows}
   <div class="leg"><i style="background:#F6E27A"></i>alta (≥60%)<i style="background:#b7a6ea"></i>media (40-59%)<i style="background:#6f8ce6"></i>baja (&lt;40%)</div></div></section>

 <section><h2><span class="k">Vestigios</span>Proyectos y requerimientos</h2>
  <div class="sd">Iniciativas que dejaron su nombre en el código.</div>
  <div class="panel">{proj_rows or '<span class="rv">sin proyectos detectados en headers</span>'}</div></section>

 <div class="note"><b>Honestidad de la capa.</b> Reconstruida de <b>autoría declarada</b> en headers (~{pct_auth}% de {n_files:,} SPs) — no de historia de Git. Los nombres se limpian heurísticamente; algunos son terceros o equipos, no personas. La <b>estilometría</b> (dialectos de nombrado como huella indirecta para el {pct_orph}% huérfano) es la fase v2 de esta capa. El código huérfano no significa "sin dueño": significa <b>sin dueño declarado</b> — máximo riesgo de pérdida de conocimiento.</div>
 <footer>Gemelo Cognitivo · Capa 2 · Mapa de las Almas · generado por <code>build-souls.py</code> desde {n_files:,} archivos .sql</footer>
</div></body></html>"""
open(BASE + "old/souls-bcop.html", "w", encoding="utf-8").write(HTML)
print(f"souls-bcop.html + souls-data.json escritos")
print(f"  {n_files:,} SPs · {n_souls} almas · {pct_auth}% autoría declarada · {pct_orph}% huérfanos · {len(projects)} proyectos")
print("  top 8 almas:")
for s in DATA["top_souls"][:8]: print(f"     {s['n']:4}  {s['name']}  ({s['doms']} dom)")
print("  bus factor (top 4 dominios más concentrados):")
for b in DATA["busfactor"][:4]: print(f"     {b['share']:3}%  {b['dom']} {b['name'][:16]:16}  {b['who'][:22]}")
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-landing.py — Landing page (index) del análisis de modernización Informix.
Diseño premium: aurora animada + glassmorphism + scroll-reveal + count-up + timeline.
Contenido: summary de hallazgos (cifras EN VIVO) + metodología + inventario de vistas.
Identidad BanCoppel (Design Studio). Genera: index-bcop.html · SPE-AM-001 · Etapa 3
"""
import json, os, re
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix/")

def load(f):
    try: return json.load(open(BASE + f, encoding="utf-8"))
    except Exception: return None

cg = load("portal/data/callgraph-data.json"); J = load("portal/data/journeys-data.json")
BR = load("portal/data/business-rules.json"); VI = load("knowledge-base/vocabulary-inventory.json")
EV = load("portal/data/evolution-data.json")
try:
    import sp_vocab; CAT = sp_vocab.CAT
except Exception:
    CAT = {}

# ── cifras en vivo ──
n_nodes = len(cg["graph"]["nodes"]) if cg else 0
n_edges = len(cg["graph"].get("edges", cg["graph"].get("links", []))) if cg else 0
n_dom = len(J) if J else 0
n_jour = sum(len(d.get("journeys", [])) for d in J.values()) if J else 0
n_expo = sum(len(d.get("exposed", [])) for d in J.values()) if J else 0
rules = BR["rules"] if BR else []
n_rules = len(rules)
tipos = Counter(r.get("tipo", "?") for r in rules)
n_form = tipos.get("FÓRMULA", 0); n_val = tipos.get("VALIDACIÓN", 0)
regc = Counter()
for r in rules:
    rg = r.get("reg")
    for x in (rg if isinstance(rg, list) else [rg]):
        name = x[0] if isinstance(x, (list, tuple)) else (x if isinstance(x, str) else None)
        if name: regc[name] += 1
n_mapped = sum(regc.values())
n_terms = len(CAT)  # override abajo con la fuente única
est = Counter(v[2] for v in CAT.values()) if CAT else Counter()
conf, inf, gap = est.get("conf", 0), est.get("inf", 0), est.get("gap", 0)
pct = lambda a: round(100 * a / n_terms) if n_terms else 0
yr0 = EV["years"][0] if EV else 2007
yr1 = EV["years"][-1] if EV else 2026
n_prod = len(EV["products"]) if EV else 0
n_mile = len(EV["milestones"]) if EV else 0
n_dated = EV["meta"]["n_dated"] if EV else 0
n_evsp = EV["meta"]["n_sp"] if EV else 0
regs_txt = " · ".join(f"{k} {v}" for k, v in regc.most_common())
_terms = {t: c for t, (c, m, e) in CAT.items() if c not in ("AMBIGUO", "PREFIJO") and e != "gap"}
_meanof = {t: m for t, (c, m, e) in CAT.items()}
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
n_syn_c = _C['conceptos']; n_syn_a = _C['alias']; n_terms = _C['total']  # 590 términos · 86 conceptos · 196 alias (idéntico en todas las vistas)

# ── inventario de vistas ──
GROUPS = [
 ("Punto de partida · Modelo de negocio", "Se empieza por aquí: el modelo de capacidades bancarias que enmarca todo el análisis — qué hace el banco, antes de ver cómo lo hace el código.", [
   ("capability-model-bcop.html", "🧩", "Modelo de Capacidades",
    "Modelo de capacidades bancarias de referencia con la cobertura identificada en el core; drill-down a procesos por capacidad."),
 ]),
 ("Capa 1 · Lenguaje", "El idioma del gemelo: el vocabulario del negocio fosilizado en los identificadores.", [
   ("vocabulary-report-bcop.html", "📖", "Reporte de Vocabulario",
    f"Vocabulario controlado de {n_terms} términos del dominio, con significado y nivel de confiabilidad (código / SME / inferido)."),
 ]),
 ("Capa 2 · Almas", "La memoria social: quién escribió cada parte del código, cómo se relevaron las generaciones de autores y qué deuda heredaron.", [
   ("souls-bcop.html", "👥", "Mapa de las Almas",
    "Quién tocó cada dominio — censo de autores, concentración de conocimiento (bus factor), código huérfano y huella de terceros."),
   ("generations-bcop.html", "🧬", "Relevo Generacional y Deuda",
    "¿Cada generación heredó o reinventó el vocabulario? ¿Cada relevo dejó nueva deuda? Deuda (huérfano, complejidad, duplicación) por era."),
 ]),
 ("Capa 3 · Biografía", "La evolución en el tiempo: cómo crecieron el código, el lenguaje y las generaciones.", [
   ("evolution-bcop.html", "🌳", "Evolución del Código",
    f"Crecimiento año por año, por dominio y producto — 'las vetas del árbol' — con {n_mile} hitos de Coppel, BanCoppel y regulación ({yr0}–{yr1-1})."),
   ("lexical-evolution-bcop.html", "📈", "Evolución del Lenguaje y las Almas",
    "Cómo creció el vocabulario año por año, las generaciones de almas (spans activos) y la huella léxica —el dialecto— de cada autor."),
   ("quality-report-bcop.html", "🩺", "Calidad del Código (ISO 5055)",
    "La salud estructural que dejó esa evolución: los 4 factores de ISO/IEC 5055:2021 (confiabilidad, seguridad, performance, mantenibilidad) como weaknesses CWE sobre los SPs del core; densidad por dominio y top SPs de mayor riesgo. Reglas calibradas al dialecto SPL. Input de la decisión 7R, del pricing y de la priorización de equivalencia."),
 ]),
 ("Capa 4 · Intención", "El modelo mental reconstruido: la estructura de componentes que lo soporta, sus integraciones externas, los journeys, el flujo de control y las reglas de negocio.", [
   ("component-map-bcop.html", "🗺️", "Mapa de Componentes",
    "Grafo de dependencias entre los SPs del core Informix, con drill-down por dominio. La estructura real del sistema."),
   ("chord-bcop.html", "🔗", "Integraciones del Core",
    "Diagrama de acordes: los 18 sistemas externos a los que se integra el core (Banxico SPEI/CoDi, buró, nómina Coppel, remesas, reguladores, canales) ↔ los 12 dominios, ponderado por endpoints."),
   ("journeys-bcop.html", "🧭", "Journeys de Negocio",
    f"{n_jour} orquestadores y {n_expo} servicios expuestos, con su objetivo de negocio inferido del nombre + evidencia del código."),
   ("flow-bcop.html", "🔀", "Flujo de Control",
    "Secuencia real de ejecución (IF/FOREACH) de los journeys — el flujo de control extraído del código, no del nombre."),
   ("rules-report-bcop.html", "⚖️", "Reglas de Negocio y Fórmulas",
    f"{n_rules:,} reglas ({n_val} validaciones + {n_form} fórmulas financieras) mapeadas a los reguladores; marca riesgos de equivalencia."),
 ]),
 ("HVM · Modernización COBOL → Java", "Contexto del sub-offering: los retos técnicos de migrar batch COBOL a Java y el enfoque Accenture.", [
   ("deck-cobol-java-bcop.html", "🏛️", "Deck: Modernización COBOL → Java",
    "Los 8 retos comunes al migrar batch COBOL a Java (N+1, packed decimal, REDEFINES, SORT/JOINKEYS, aritmética financiera) y el enfoque Accenture — Spring Batch chunk-oriented, BigDecimal obligatorio, revisión humana sobre lógica regulatoria."),
 ]),
]

# ── hallazgos clave ──
FINDINGS = [
 f"El core es una <b>base de datos como aplicación</b>: la lógica de negocio vive en Stored Procedures Informix. "
 f"Se analizaron <b>{n_nodes:,} SPs conectados</b> que forman un grafo de <b>{n_edges:,} llamadas</b> en <b>{n_dom} dominios</b> técnicos.",
 f"<b>{n_jour} orquestadores</b> de negocio + <b>{n_expo} servicios expuestos</b> estructuran el sistema "
 f"(canal digital, crédito, SPEI, contabilidad, saldos, cobranza, aclaraciones…).",
 f"Se extrajeron <b>{n_rules:,} reglas de negocio</b> ({n_val} validaciones + {n_form} fórmulas), "
 f"<b>{n_mapped}</b> mapeadas a 6 reguladores: {regs_txt}.",
 "Fórmulas financieras con <b>riesgo de equivalencia</b> identificado: ISR, GAT, CAT e interés — "
 "diferencias de <code>TRUNC</code> vs <code>ROUND</code>, base 360 vs 365, y redondeo <code>MONEY</code> del target.",
 f"Vocabulario controlado de <b>{n_terms} términos</b>: {pct(conf)}% confirmado (código + SME + convención), "
 f"{pct(inf)}% inferido, {pct(gap)}% ambiguo por validar. La evidencia <i>dura</i> de código es menor — la confiabilidad se declara por fuente, sin inflar.",
 f"<b>Deuda de nombrado:</b> el mismo concepto se escribe bajo múltiples alias — <b>{n_syn_c} conceptos</b> en <b>{n_syn_a} términos</b> (cliente/cte, movimiento/mov/movto). Inconsistencia acumulada entre dialectos y generaciones que el target debe normalizar a un término canónico.",
 f"Evolución <b>{yr0}–{yr1-1}</b>: el núcleo se construyó ~2008–2014; se detectaron <b>{n_prod} productos bancarios</b> "
 f"y {n_mile} hitos que correlacionan los picos de código con la historia de Coppel/BanCoppel y la regulación.",
 "La <b>base de clientes de BanCoppel = los clientes de crédito de Coppel</b> — explica el peso del core en "
 "captación, crédito al consumo, nómina, remesas y dispersión (ver base de conocimiento del cliente).",
]

# ── las 8 capas del Gemelo Cognitivo — (título, sub) ──
PIPE = [
 ("1 · Lenguaje", "El vocabulario del negocio fosilizado en los identificadores del código — aprender a hablar el sistema antes de entenderlo."),
 ("2 · Almas", "Quién escribió cada parte: los autores, sus dialectos de nombrado y dónde se concentra el conocimiento (bus factor)."),
 ("3 · Biografía", "Cómo creció el código año por año — las vetas del árbol — y qué productos e hitos acompañaron cada etapa."),
 ("4 · Intención", "El propósito reconstruido: los journeys de negocio, las reglas y fórmulas, y las capacidades que cubre el core."),
 ("5 · Fronteras", "Los bounded contexts del sistema objetivo y la decisión 7R por capability — sin heredar el corte por base de datos."),
 ("6 · Siembra", "El gemelo se vuelve la especificación y el contexto que siembra la construcción AI-assisted del target."),
 ("7 · Equivalencia", "Golden-master y parallel-run: probar que el nuevo sistema produce los mismos resultados que el legacy."),
 ("8 · Continuidad", "El gemelo persiste en operación como documentación viva y guía el decommission del legacy, capability por capability.")]

# ── hilos transversales (atraviesan las 8 capas) — (icono, título, descripción) ──
TRANSVERSAL = [
 ("Calidad", "Quality Engineering",
  "Empieza midiendo la <b>salud estructural del código AS-IS</b> contra <b>ISO/IEC 5055:2021</b> (weaknesses CWE en confiabilidad, seguridad, performance y mantenibilidad) — input de la decisión 7R y del pricing. Sigue con quality gates en CI (test automation, SAST/lint, code review) y culmina en la <b>equivalencia funcional</b> — golden-master + parallel-run ≥ 99.95% — que prueba que el nuevo sistema se comporta como el legacy."),
 ("Seguridad", "DevSecOps",
  "Seguridad integrada de extremo a extremo (shift-left). En el sistema actual: <b>arqueología de postura</b> — autenticación, controles PLD/antilavado, datos PII, secretos hardcodeados y SQL dinámico. Hacia el target: <b>threat modeling</b> de los bounded contexts, escaneo SAST/SCA/secretos en CI y datos enmascarados en el parallel-run."),
]

METHOD = [
 ("Enfoque", "Reverse-engineering asistido: el nombre de cada SP se descompone en vocabulario para inferir su objetivo, y se <b>confirma contra el código</b> (parámetros, tablas, documentación). Estructura real + semántica inferida."),
 ("Confiabilidad honesta", "Cada término y regla declara su nivel de evidencia (código · SME · convención · inferido). No se infla la certeza: lo confirmado por código se distingue de lo que <b>requiere validación del SME</b>."),
 ("Validación iterativa", "Caza sistemática de falsos positivos de segmentación (p. ej. CoDi vs «código», «piezas», Art. 61) verificados en el código, con 6 SME reguladores presentes (CNBV, Banxico, CONDUSEF, SAT, TESOFE, IPAB)."),
 ("Objetivo", "Insumo para la decisión <b>7R por capability</b> y la <b>equivalencia funcional</b> hacia el target — con foco en los riesgos financieros/regulatorios de la migración."),
]

TILES = [(yr1 - 1 - yr0, "Años de historia · su ADN"), (n_dom, "Dominios técnicos"),
         (n_terms, f"Términos ({_C['unicos']} únicos) · su cultura y vocabulario"), (n_jour, "Journeys de negocio"),
         (n_rules, "Reglas de negocio"), (n_edges, "Dependencias entre SPs")]

# ── render de fragmentos ──
tiles_h = "".join(f'<div class="stat glass reveal"><div class="statn" data-target="{n}">0</div><div class="statl">{l}</div></div>' for n, l in TILES)
feat_h = f'<div class="feat glass reveal">{FINDINGS[0]}</div>'
fgrid_h = "".join(f'<div class="fcard glass reveal"><div class="idx">{i+2:02d}</div><p>{f}</p></div>' for i, f in enumerate(FINDINGS[1:]))
tl_h = "".join(f'<div class="node reveal"><h4>{t}</h4><span>{s}</span></div>' for t, s in PIPE)
method_h = "".join(f'<div class="mcard glass reveal"><h4>{h}</h4><p>{b}</p></div>' for h, b in METHOD)
xcards_h = "".join(f'<div class="xcard glass reveal"><div class="xkick">Transversal · atraviesa las 8 capas</div><div class="xt">{t} <span>· {sub}</span></div><div class="xd">{d}</div></div>' for t, sub, d in TRANSVERSAL)
groups_h = ""
for gname, gsub, views in GROUPS:
    cards = ""
    for f, ic, t, d in views:
        exists = os.path.exists(BASE + f)
        dis = "" if exists else ' style="opacity:.45;pointer-events:none"'
        cards += (f'<a class="vcard glass reveal" href="{f}"{dis}><div class="ico">{ic}</div>'
                  f'<div><div class="vt">{t}</div><div class="vd">{d}</div>'
                  f'<div class="go">Abrir la vista <span class="arr">→</span></div></div></a>')
    groups_h += (f'<div class="group"><div class="ghead reveal"><h3>{gname}</h3><span>{gsub}</span></div>'
                 f'<div class="cardgrid">{cards}</div></div>')
n_views = sum(len(v) for _, _, v in GROUPS)

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}
html{scroll-behavior:smooth}
body{background:#060a1a;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
 -webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before,.aurora::after,.aurora .blob{content:"";position:absolute;border-radius:50%;filter:blur(90px)}
.aurora::before{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(27,63,208,.65),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(13,33,133,.7),transparent 70%);animation:f2 28s ease-in-out infinite}
.aurora .blob{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(240,210,36,.22),transparent 70%);animation:f3 32s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.15)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.12)}}
@keyframes f3{50%{transform:translate(-9vw,-9vh) scale(1.22)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;
 background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}
nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:15px 30px;
 backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);background:rgba(6,10,26,.55);border-bottom:1px solid rgba(255,255,255,.06)}
nav img{height:21px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
nav .nt{font-size:12.5px;font-weight:600;color:var(--muted);letter-spacing:.01em}
nav .sp{flex:1}
nav a.jump{font-size:12.5px;color:var(--muted);padding:7px 13px;border-radius:20px;transition:.22s}
nav a.jump:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.glass{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);
 border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}
.wrap{max-width:1160px;margin:0 auto;padding:0 30px}
section{padding:76px 0;scroll-margin-top:70px}
.hero{min-height:100vh;display:flex;flex-direction:column;justify-content:center;position:relative;padding:100px 0 40px}
.eyebrow{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;padding:8px 16px;border-radius:30px;font-size:12px;
 font-weight:600;letter-spacing:.03em;color:#dfe6ff;margin-bottom:28px;background:rgba(255,255,255,.05);border:1px solid var(--glassb);
 backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}
.eyebrow .dot{width:7px;height:7px;border-radius:50%;background:var(--yellow);box-shadow:0 0 12px var(--yellow);animation:pulse 2.4s infinite}
@keyframes pulse{50%{opacity:.4}}
.hero h1{font-size:clamp(42px,7.4vw,92px);font-weight:800;line-height:1.0;letter-spacing:-.035em;max-width:16ch;
 background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero .sub{font-size:clamp(16px,1.9vw,21px);color:var(--muted);margin-top:26px;max-width:62ch;line-height:1.55}
.hero .sub b{color:#e4eaff;font-weight:600}
.scrollcue{position:absolute;bottom:30px;left:50%;transform:translateX(-50%);color:var(--muted2);font-size:10.5px;letter-spacing:.24em;text-transform:uppercase;text-align:center}
.scrollcue .chev{display:block;margin:10px auto 0;width:15px;height:15px;border-right:2px solid var(--muted2);border-bottom:2px solid var(--muted2);transform:rotate(45deg);animation:bob 1.9s infinite}
@keyframes bob{0%,100%{transform:translateY(0) rotate(45deg);opacity:.5}50%{transform:translateY(7px) rotate(45deg);opacity:1}}
.stats{display:grid;grid-template-columns:repeat(6,1fr);gap:13px;margin-top:14px}
.stat{padding:22px 14px;text-align:center}
.statn{font-size:clamp(23px,2.9vw,35px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;
 background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.statl{font-size:10px;color:var(--muted2);margin-top:9px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}
.shead{margin-bottom:36px}
.kick{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:14px}
.shead h2{font-size:clamp(29px,4.2vw,46px);font-weight:800;letter-spacing:-.025em;line-height:1.04}
.shead p{color:var(--muted);font-size:15px;margin-top:14px;max-width:72ch;line-height:1.55}
.feat{padding:36px 40px;font-size:clamp(18px,2.3vw,26px);font-weight:500;line-height:1.42;color:#eaf0ff;margin-bottom:16px}
.feat b{background:linear-gradient(90deg,#fff,#bcd0ff);-webkit-background-clip:text;background-clip:text;color:transparent;font-weight:800}
.fgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:16px}
.fcard{padding:26px 26px}
.fcard .idx{font-size:12px;font-weight:800;color:var(--yellow);margin-bottom:12px;letter-spacing:.08em;font-variant-numeric:tabular-nums}
.fcard p{font-size:14px;color:var(--muted);line-height:1.6}
.fcard b{color:#fff;font-weight:700}
code{background:rgba(240,210,36,.10);border:1px solid rgba(240,210,36,.25);border-radius:5px;padding:1px 6px;font-size:12px;color:var(--yellow);font-family:'SF Mono',ui-monospace,monospace}
.tlwrap{display:grid;grid-template-columns:1.05fr .95fr;gap:44px;align-items:start}
@media(max-width:860px){.tlwrap{grid-template-columns:1fr;gap:30px}}
.tl{position:relative;padding-left:38px}
.tl::before{content:"";position:absolute;left:6px;top:8px;bottom:8px;width:2px;background:linear-gradient(180deg,var(--yellow),var(--blue) 60%,transparent)}
.node{position:relative;padding-bottom:24px}
.node:last-child{padding-bottom:0}
.node::before{content:"";position:absolute;left:-38px;top:2px;width:13px;height:13px;border-radius:50%;background:var(--yellow);
 border:3px solid #0a1230;box-shadow:0 0 0 2px rgba(240,210,36,.55),0 0 14px rgba(240,210,36,.5)}
.node h4{font-size:15.5px;font-weight:700;letter-spacing:-.01em}
.node span{font-size:12.5px;color:var(--muted2)}
.mgrid{display:grid;grid-template-columns:1fr 1fr;gap:15px}
@media(max-width:860px){.mgrid{grid-template-columns:1fr}}
.mcard{padding:24px 26px}
.mcard h4{font-size:12px;color:var(--yellow);text-transform:uppercase;letter-spacing:.09em;margin-bottom:10px;font-weight:700}
.mcard p{font-size:13.5px;color:var(--muted);line-height:1.6}.mcard b{color:#fff;font-weight:600}
.mnote{margin-top:22px;padding:16px 20px;font-size:13px;color:var(--muted);border-radius:16px;
 background:rgba(255,255,255,.055);backdrop-filter:blur(15px) saturate(140%);-webkit-backdrop-filter:blur(15px) saturate(140%);box-shadow:0 8px 28px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.1);border:1px solid rgba(240,210,36,.16)}.mnote b{color:#e4eaff}
.xhead{font-size:12px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--muted);margin:28px 0 13px;display:flex;align-items:center;gap:14px}
.xhead::after{content:"";flex:1;height:1px;background:linear-gradient(90deg,rgba(240,210,36,.5),transparent)}
.xrow{display:grid;grid-template-columns:1fr 1fr;gap:15px}
@media(max-width:760px){.xrow{grid-template-columns:1fr}}
.xcard{padding:20px 24px;border-left:3px solid var(--yellow)}
.xkick{font-size:10px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;color:var(--yellow);margin-bottom:10px}
.xt{font-size:16px;font-weight:800} .xt span{font-size:13px;font-weight:600;color:var(--muted)}
.xd{font-size:12.5px;color:var(--muted);margin-top:7px;line-height:1.6} .xd b{color:#e4eaff;font-weight:600}
.group{margin-top:46px}
.ghead{display:flex;align-items:baseline;gap:14px;margin-bottom:18px}
.ghead h3{font-size:20px;font-weight:800;letter-spacing:-.02em}
.ghead span{font-size:13px;color:var(--muted2)}
.cardgrid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
@media(max-width:960px){.cardgrid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:600px){.cardgrid{grid-template-columns:1fr}}
.vcard{display:flex;gap:17px;padding:23px;color:inherit;transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s}
.vcard:hover{transform:translateY(-6px);border-color:rgba(240,210,36,.42);box-shadow:0 22px 56px rgba(0,0,0,.5)}
.vcard .ico{font-size:25px;width:54px;height:54px;display:flex;align-items:center;justify-content:center;border-radius:16px;flex-shrink:0;
 background:linear-gradient(150deg,rgba(255,255,255,.13),rgba(255,255,255,.02));border:1px solid rgba(255,255,255,.11);transition:transform .34s}
.vcard:hover .ico{transform:scale(1.09) rotate(-4deg)}
.vcard .vt{font-size:16.5px;font-weight:800;letter-spacing:-.01em}
.vcard .vd{font-size:13px;color:var(--muted);margin:6px 0 13px;line-height:1.55}
.vcard .go{font-size:12px;font-weight:700;color:var(--yellow);display:inline-flex;align-items:center;gap:7px}
.vcard .arr{transition:transform .3s}.vcard:hover .arr{transform:translateX(5px)}
.reveal{opacity:0;transform:translateY(32px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}
.reveal.in{opacity:1;transform:none}
footer{padding:44px 30px 64px;text-align:center;color:var(--muted2);font-size:12px;border-top:1px solid rgba(255,255,255,.06);margin-top:50px;line-height:1.7}
footer code{color:var(--muted)}
@media(max-width:920px){.stats{grid-template-columns:repeat(3,1fr)}}
@media(max-width:560px){.stats{grid-template-columns:repeat(2,1fr)}nav .nt{display:none}}
@media(prefers-reduced-motion:reduce){.reveal{transition:none;opacity:1;transform:none}.aurora *{animation:none}}
"""

JS = """
const prog=document.getElementById('prog'),doc=document.documentElement;
addEventListener('scroll',()=>{prog.style.width=(doc.scrollTop/(doc.scrollHeight-doc.clientHeight)*100)+'%';},{passive:true});
const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting){e.target.classList.add('in');io.unobserve(e.target);}}),{threshold:.12,rootMargin:'0px 0px -8% 0px'});
document.querySelectorAll('.reveal').forEach(el=>{const sibs=[...el.parentElement.children].filter(c=>c.classList.contains('reveal'));
 el.style.transitionDelay=(Math.min(sibs.indexOf(el),8)*70)+'ms';io.observe(el);});
const cu=new IntersectionObserver(es=>es.forEach(e=>{if(!e.isIntersecting)return;const el=e.target,t=+el.dataset.target,d=1250,s=performance.now();
 (function tick(now){let p=Math.min((now-s)/d,1);p=1-Math.pow(1-p,3);el.textContent=Math.round(t*p).toLocaleString('es-MX');if(p<1)requestAnimationFrame(tick);})(s);
 cu.unobserve(el);}),{threshold:.6});
document.querySelectorAll('[data-target]').forEach(el=>cu.observe(el));
"""

HTML = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Portal de Análisis de Modernización</title>
<style>{CSS}</style></head><body>
<div class="aurora"><div class="blob"></div></div><div class="grain"></div>
<div id="prog"></div>
<nav>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <span class="nt">Informix · Análisis de Modernización</span><span class="sp"></span>
  <a class="jump" href="#resumen">Resumen</a><a class="jump" href="#metodo">Metodología</a><a class="jump" href="#vistas">Vistas</a>
</nav>

<div class="wrap">
  <header class="hero">
    <div class="eyebrow reveal"><span class="dot"></span> SPE-AM-001 · High Velocity Modernization · Fase DISCOVER</div>
    <h1 class="reveal">Análisis de Modernización del Core Informix</h1>
    <p class="sub reveal">Ingeniería inversa del core bancario de BanCoppel — un sistema <b>"base de datos como aplicación"</b>
      donde la lógica de negocio vive en miles de Stored Procedures Informix. Application Modernization.</p>
    <div class="scrollcue">desliza<span class="chev"></span></div>
  </header>

  <section id="resumen">
    <div class="shead reveal"><div class="kick">Resumen ejecutivo</div>
      <h2>Los hallazgos que estructuran<br>la decisión de modernización</h2></div>
    <div class="stats">{tiles_h}</div>
    <div style="margin-top:40px">{feat_h}<div class="fgrid">{fgrid_h}</div></div>
  </section>

  <section id="metodo">
    <div class="shead reveal"><div class="kick">Metodología</div>
      <h2>Gemelo Cognitivo del Sistema</h2>
      <p>Un modelo vivo del conocimiento del legacy en <b>8 capas</b> — las 4 primeras <b>entienden</b> el sistema tal como es, las 4 siguientes <b>engendran el futuro</b> — más <b>2 hilos transversales</b> que las atraviesan.</p></div>
    <div class="tlwrap">
      <div class="tl">{tl_h}</div>
      <div class="mgrid">{method_h}</div>
    </div>
    <div class="xhead reveal">Dos hilos que atraviesan las 8 capas</div>
    <div class="xrow">{xcards_h}</div>
    <div class="mnote reveal">Todo con <b>una sola fuente de verdad</b> (<code>sp_vocab.py</code>): cada vista y reporte se regenera de los mismos datos, así las correcciones — falsos positivos, semántica — se propagan a todo el portal.</div>
  </section>

  <section id="vistas">
    <div class="shead reveal"><div class="kick">Explora</div>
      <h2>Inventario de áreas de análisis</h2>
      <p>{n_views} vistas interactivas, organizadas por las <b>capas del Gemelo Cognitivo</b>. Clic para abrir cada una.</p></div>
    {groups_h}
  </section>
</div>

<footer>
  BanCoppel · Informix · SPE-AM-001 · Portal generado por <code>build-landing.py</code> con cifras en vivo desde los datos del análisis.<br>
  Confiabilidad del vocabulario: {pct(conf)}% confirmado · {pct(inf)}% inferido · {pct(gap)}% por validar · cobertura de fechas {n_dated:,}/{n_evsp:,} SPs.
</footer>
<script>{JS}</script>
</body></html>"""

open(BASE + "old/index-bcop.html", "w", encoding="utf-8").write(HTML)
print(f"index-bcop.html escrito · {len(HTML):,} bytes")
print(f"  tiles: {n_dom} dom · {n_nodes:,} SPs · {n_edges:,} llamadas · {n_jour} journeys · {n_rules:,} reglas · {n_terms} términos")
print(f"  vocab: conf {pct(conf)}% · inf {pct(inf)}% · gap {pct(gap)}%  |  reguladores: {regs_txt}")
print(f"  vistas enlazadas: {n_views}")
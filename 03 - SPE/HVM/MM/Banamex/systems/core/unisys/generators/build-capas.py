#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-capas.py — Rinde desde brain.db las tres capas del Gemelo Cognitivo que el
portal no cubria:

    almas.html         Capa 2 · Almas         quien escribio el core
    biografia.html     Capa 3 · Biografia     cuando muto
    equivalencia.html  Capa 7 · Equivalencia  que hay que probar antes del cutover

Todo el contenido viene del brain. El shell de presentacion es
templates/capa_shell.css, cosechado del portal validado (metodologia 4.1).

SALIDA: generators/_staging/, NO portal/. El portal interno es un entregable
validado y no se modifica; build-sanitized.py recoge estas paginas desde
_staging y las saca saneadas a sanitized/.

NUMERACION DE CAPAS: el portal ya rotula Capa 4 Intencion, Capa 5 Fronteras y
Capa 6 Siembra, que es la numeracion de HVM/metodologia-gemelo-cognitivo.md. Se
sigue esa. El canon del Enterprise Brain nombra distinto las capas 2 y 3; esa
contradiccion esta abierta y se resuelve fuera de este generador.

PRIVACIDAD: almas.html nombra personal real del cliente. Es un artefacto interno
de delivery, donde el bus factor sin nombres no sirve para actuar. El showcase
sanitizado los seudonimiza; ver build-sanitized.py.

USO:
    PYTHONUTF8=1 python generators/build-capas.py            # las tres
    PYTHONUTF8=1 python generators/build-capas.py almas
"""

from __future__ import annotations

import base64
from collections import Counter
import html
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
TPL = Path(__file__).resolve().parent / "templates"
PORTAL = BASE / "portal"
# El portal interno NO se toca: es un artefacto entregado y validado. Las capas
# nuevas se escriben en un area de preparacion y build-sanitized.py las sanea
# hacia sanitized/ junto con el resto.
OUT = Path(__file__).resolve().parent / "_staging"
LOGO = PORTAL / "assets" / "logos" / "banamex.png"

NAV = [("index.html", "← Hub"), ("rules-report.html", "Reglas"), ("vocab.html", "Vocabulario"),
       ("almas.html", "Almas"), ("biografia.html", "Biografía"),
       ("traceability.html", "Trazabilidad"), ("integration.html", "Integración"),
       ("equivalencia.html", "Equivalencia")]

CSS_EXTRA = """
h2{font-size:clamp(22px,2.6vw,34px);font-weight:700;letter-spacing:-.02em;margin-bottom:10px}
.sec-intro{color:var(--muted);max-width:76ch;line-height:1.6;margin-bottom:26px;font-size:14.5px}
.rows{display:flex;flex-direction:column;gap:8px}
.row{display:grid;grid-template-columns:minmax(190px,1.4fr) 1fr 74px;gap:14px;align-items:center;padding:12px 16px;border-radius:12px}
.row .nm{font-weight:600;font-size:13.5px}
.row .meta{font-size:11px;color:var(--muted2);margin-top:3px}
.barw{height:8px;border-radius:5px;background:rgba(255,255,255,.07);overflow:hidden}
.bari{height:100%;border-radius:5px;background:linear-gradient(90deg,var(--gold),#fff);width:0;transition:width 1.1s cubic-bezier(.16,1,.3,1)}
.num{text-align:right;font-variant-numeric:tabular-nums;font-weight:700;font-size:15px}
.tag{display:inline-block;padding:3px 9px;border-radius:20px;font-size:10px;font-weight:700;letter-spacing:.04em;text-transform:uppercase}
.t-pers{background:rgba(108,197,216,.16);color:var(--gold)}
.t-orga{background:rgba(245,166,35,.16);color:#f5a623}
.t-cred{background:rgba(255,255,255,.08);color:var(--muted)}
.grid2{display:grid;grid-template-columns:repeat(auto-fit,minmax(290px,1fr));gap:13px}
.card{padding:20px 22px;border-radius:14px}
.card h3{font-size:14px;font-weight:700;margin-bottom:7px}
.card p{font-size:12.5px;color:var(--muted);line-height:1.6}
.tl{position:relative;padding-left:26px}
.tl::before{content:"";position:absolute;left:7px;top:6px;bottom:6px;width:2px;background:linear-gradient(180deg,var(--gold),rgba(108,197,216,.1))}
.tlrow{position:relative;padding:13px 0 13px 14px}
.tlrow::before{content:"";position:absolute;left:-24px;top:19px;width:10px;height:10px;border-radius:50%;background:var(--gold);box-shadow:0 0 10px var(--gold)}
.tly{font-size:21px;font-weight:800;letter-spacing:-.02em;color:var(--gold)}
.tlt{font-size:13.5px;margin-top:3px}
.tlm{font-size:11px;color:var(--muted2);margin-top:4px}
table{width:100%;border-collapse:collapse;font-size:12.5px}
th{text-align:left;padding:10px 12px;color:var(--muted2);font-size:10px;text-transform:uppercase;letter-spacing:.06em;border-bottom:1px solid rgba(255,255,255,.1)}
td{padding:11px 12px;border-bottom:1px solid rgba(255,255,255,.05);vertical-align:top;line-height:1.5}
td.mono{font-family:'SF Mono',Consolas,monospace;font-size:11.5px;color:var(--gold);white-space:nowrap}
.sev{font-weight:700;white-space:nowrap}
.s-def{color:#f87171}.s-cri{color:#e8883a}.s-alt{color:#f0d080}.s-med{color:var(--muted)}.s-baj{color:#6ee89f}
.nota{border-left:3px solid var(--gold);padding:14px 18px;border-radius:0 10px 10px 0;font-size:13px;color:var(--muted);line-height:1.65}
.nota b{color:var(--ink)}
"""

JS = """
const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting){e.target.classList.add('in');io.unobserve(e.target);}}),{threshold:.12});
document.querySelectorAll('.reveal').forEach(e=>io.observe(e));
addEventListener('scroll',()=>{const h=document.documentElement;
  document.getElementById('prog').style.width=(h.scrollTop/(h.scrollHeight-h.clientHeight)*100)+'%';});
setTimeout(()=>document.querySelectorAll('.bari').forEach(b=>b.style.width=b.dataset.w+'%'),380);
document.querySelectorAll('.statn[data-target]').forEach(el=>{
  const t=+el.dataset.target;let n=0;const step=Math.max(1,Math.round(t/46));
  const id=setInterval(()=>{n+=step;if(n>=t){n=t;clearInterval(id);}el.textContent=n.toLocaleString('es-MX');},22);});
"""


def db():
    c = sqlite3.connect(DB)
    c.row_factory = sqlite3.Row
    return c


def e(s) -> str:
    return html.escape(str(s if s is not None else ""), quote=True)


def logo_uri() -> str:
    return "data:image/png;base64," + base64.b64encode(LOGO.read_bytes()).decode()


def nav(activa: str) -> str:
    links = "".join(
        f'\n  <a class="jump{" active" if h == activa else ""}" href="{h}">{e(t)}</a>'
        for h, t in NAV)
    return (f'<nav>\n  <img src="{logo_uri()}" alt="Banamex" '
            f'style="height:26px;width:auto;display:inline-block;vertical-align:middle">\n'
            f'  <span class="nt">Enterprise Digital Brain · Banamex Mainframe</span>'
            f'<span class="sp"></span>{links}\n</nav>')


def stat(n, label) -> str:
    val = f'data-target="{n}">0' if isinstance(n, int) else f'>{e(n)}'
    return (f'<div class="stat glass reveal"><div class="statn"{val}</div>'
            f'<div class="statl">{e(label)}</div></div>')


def hero(eyebrow, h1, sub, stats) -> str:
    return (f'<div class="wrap">\n  <header class="hero">\n'
            f'    <div class="eyebrow reveal"><span class="dot"></span> {e(eyebrow)}</div>\n'
            f'    <h1 class="reveal">{h1}</h1>\n'
            f'    <p class="sub reveal">{sub}</p>\n'
            f'    <div class="stats">{"".join(stats)}</div>\n  </header>')


def seccion(titulo, intro, cuerpo) -> str:
    return (f'\n<section class="reveal">\n  <h2>{e(titulo)}</h2>\n'
            f'  <p class="sec-intro">{intro}</p>\n{cuerpo}\n</section>')


def pagina(titulo, activa, cuerpo, pie) -> str:
    css = (TPL / "capa_shell.css").read_text(encoding="utf-8") + CSS_EXTRA
    return (f'<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">\n'
            f'<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
            f'<title>{e(titulo)}</title>\n<style>{css}</style></head><body>\n'
            f'<div class="aurora"><div class="blob"></div></div>\n<div class="grain"></div>\n'
            f'<div id="prog"></div>\n\n{nav(activa)}\n\n{cuerpo}\n</div>\n'
            f'<footer>{pie}</footer>\n<script>{JS}</script>\n</body>\n</html>')


PIE = ('&#8592; <a href="index.html">Volver al Hub</a> &ensp;&middot;&ensp; '
       'Enterprise Digital Brain Banamex &ensp;&middot;&ensp; POC AIRE 2026 &ensp;&middot;&ensp; '
       'Generado desde brain.db por generators/build-capas.py')


# ── Capa 2 · Almas ───────────────────────────────────────────────────────────

def build_almas() -> str:
    con = db()
    autores = con.execute("SELECT * FROM autores ORDER BY n_programas DESC, display").fetchall()
    firmas = con.execute("SELECT COUNT(*) n FROM autoria").fetchone()["n"]
    con_autor = con.execute("SELECT COUNT(DISTINCT sistema||archivo) n FROM autoria").fetchone()["n"]
    firmados = {r["k"] for r in con.execute(
        "SELECT sistema||':'||programa k FROM autoria").fetchall()}
    inventario = con.execute("SELECT sistema, programa, tipo FROM inventario").fetchall()
    con.close()

    total_fuentes = 218
    personas = [a for a in autores if a["tipo"] == "persona"]
    orgs = [a for a in autores if a["tipo"] == "organizacion"]
    creds = [a for a in autores if a["tipo"] == "credencial"]
    huerfanos = [r for r in inventario if f'{r["sistema"]}:{r["programa"]}' not in firmados]
    top = autores[0] if autores else None
    maxp = top["n_programas"] if top else 1

    h = hero("Capa 2 · Almas · La memoria social del core",
             "Quién escribió el core",
             f'La división <b>AUTHOR.</b> de COBOL conserva la firma de quien escribió cada programa, '
             f'y en ALGOL algunos autores la dejaron en un comentario de cabecera. '
             f'De los {total_fuentes} fuentes del corpus, <b>{con_autor}</b> declaran autor '
             f'({con_autor * 100 // total_fuentes}%), y de ahí salen <b>{len(personas)} personas</b>, '
             f'<b>{len(orgs)} organizaciones</b> y <b>{len(creds)} credenciales</b> sin nombre. '
             f'La Ley de Conway fosilizada: la organización que construyó el sistema, legible en el código.',
             [stat(len(personas), "Personas"), stat(len(orgs), "Organizaciones"),
              stat(len(creds), "Credenciales"), stat(firmas, "Firmas"),
              stat(f"{con_autor * 100 // total_fuentes}%", "Cobertura")])

    filas = []
    for a in autores[:26]:
        cls = {"persona": "t-pers", "organizacion": "t-orga"}.get(a["tipo"], "t-cred")
        formas = a["formas"].split(" | ")
        meta = f'{e(a["sistemas"])}'
        if len(formas) > 1:
            meta += f' &middot; {len(formas)} variantes del nombre en el código'
        filas.append(
            f'<div class="row glass"><div><div class="nm">{e(a["display"])} '
            f'<span class="tag {cls}">{e(a["tipo"][:4])}</span></div>'
            f'<div class="meta">{meta}</div></div>'
            f'<div class="barw"><div class="bari" data-w="{a["n_programas"] * 100 // maxp}"></div></div>'
            f'<div class="num">{a["n_programas"]}</div></div>')

    s1 = seccion(
        "Concentración de conocimiento",
        f'Programas firmados por cada autor. <b>{e(top["display"])}</b> firma '
        f'<b>{top["n_programas"]}</b>, el {top["n_programas"] * 100 // max(con_autor, 1)}% de los '
        f'archivos que declaran autor: es la mayor concentración de conocimiento del core y el primer '
        f'riesgo de pérdida si esa persona ya no está en la organización.',
        f'<div class="rows">{"".join(filas)}</div>')

    tarjetas = "".join(
        f'<div class="card glass"><h3>{e(o["display"])}</h3>'
        f'<p>Firma {o["n_programas"]} programa(s) en {e(o["sistemas"])}. '
        f'Variantes registradas: {e(o["formas"])}.</p></div>' for o in orgs)
    s2 = seccion(
        "Huella de terceros",
        'No todo el core lo escribió personal interno. Estas firmas corresponden a fábricas de '
        'software y proveedores externos. Cada una es una dependencia de conocimiento fuera de la '
        'nómina, y conviene saber cuál sigue vigente como proveedor antes de modernizar su código.',
        f'<div class="grid2">{tarjetas}</div>')

    por_tipo = Counter(r["tipo"] for r in huerfanos)
    cobol_hu = por_tipo.get("COBOL", 0)
    otros_hu = sum(v for k, v in por_tipo.items() if k != "COBOL")
    chips = "".join(
        f'<div class="card glass"><h3>{e(k)}</h3><p><b>{v}</b> sin autor declarado</p></div>'
        for k, v in por_tipo.most_common())
    s3 = seccion(
        "Código sin autoría declarada",
        f'<b>{len(huerfanos)}</b> de los {len(inventario)} programas del inventario no traen firma. '
        f'Conviene separarlos: solo COBOL tiene una división <b>AUTHOR.</b> donde declararla, así que '
        f'los <b>{otros_hu}</b> de ALGOL, DASDL, WFL e INC no perdieron el registro, nunca tuvieron '
        f'dónde ponerlo. La memoria realmente perdida son los <b>{cobol_hu} programas COBOL</b> que '
        f'pudieron declarar autor y no lo hicieron.',
        f'<div class="grid2">{chips}</div>'
        '<div class="nota glass" style="margin-top:14px">Esos programas elevan el valor de las capas '
        'de Intención y Equivalencia: sin autor vivo que valide el comportamiento, la única red de '
        'seguridad es la regla de negocio extraída y el golden-master.</div>')

    s4 = seccion(
        "Método y honestidad de la fuente",
        'Qué sostiene esta capa y qué no.',
        '<div class="nota glass">'
        f'La autoría se lee únicamente de la división <b>AUTHOR.</b> declarada en el fuente, nunca '
        f'se infiere. Las variantes del mismo nombre se funden cuando sus tokens son subconjunto y '
        f'comparten al menos dos, de modo que <b>RICARDO MORENO A</b> y <b>RICARDO MORENO ARZAVE</b> '
        f'son una persona, mientras que dos homónimos de pila siguen separados. '
        f'La cobertura es del {con_autor * 100 // total_fuentes}%: el resto del corpus no declara autor, '
        f'y esta capa no inventa uno. Las credenciales tipo <b>CD38494</b> se cuentan aparte porque '
        f'identifican una cuenta, no a una persona nombrada.'
        '</div>')

    return pagina("Banamex · Capa 2 Almas · Enterprise Digital Brain",
                  "almas.html", h + s1 + s2 + s3 + s4, PIE)


# ── Capa 3 · Biografia ───────────────────────────────────────────────────────

def build_biografia() -> str:
    con = db()
    ev = con.execute("SELECT * FROM cronologia_eventos ORDER BY anio, n_programas DESC").fetchall()
    cambios = con.execute("SELECT COUNT(*) n FROM cronologia").fetchone()["n"]
    marcas = con.execute("SELECT SUM(repeticiones) n FROM cronologia").fetchone()["n"] or 0
    arch = con.execute("SELECT COUNT(DISTINCT sistema||archivo) n FROM cronologia").fetchone()["n"]
    con.close()

    total_fuentes = 218
    anios = sorted({x["anio"] for x in ev})
    mayor = max(ev, key=lambda x: x["n_programas"]) if ev else None

    h = hero("Capa 3 · Biografía · La evolución en el tiempo",
             "Las vetas del árbol: %d–%d" % (anios[0], anios[-1]) if anios else "Biografía",
             f'Los comentarios de cabecera guardan la bitácora de cambios del core. '
             f'<b>{marcas}</b> marcas fechadas se consolidan en <b>{cambios}</b> cambios y '
             f'<b>{len(ev)}</b> eventos, repartidos en <b>{len(anios)}</b> años. '
             f'El evento de mayor huella es <b>{e(mayor["proyecto"])}</b> de {mayor["anio"]}, '
             f'que tocó {mayor["n_programas"]} programas a la vez.' if mayor else "",
             [stat(len(ev), "Eventos"), stat(cambios, "Cambios"), stat(marcas, "Marcas"),
              stat(len(anios), "Años"), stat(f"{arch * 100 // total_fuentes}%", "Cobertura")])

    filas = []
    for x in ev:
        v = f' &middot; proveedor <b>{e(x["vendor"])}</b>' if x["vendor"] else ""
        filas.append(
            f'<div class="tlrow reveal"><div class="tly">{x["anio"]}</div>'
            f'<div class="tlt">{e(x["proyecto"])}</div>'
            f'<div class="tlm">{x["n_programas"]} programa(s) &middot; {x["marcas"]} marca(s) '
            f'en el fuente &middot; {e(x["sistemas"])}{v}</div></div>')

    s1 = seccion(
        "Línea de tiempo del core",
        'Cada evento es un cambio fechado en los comentarios, no una suposición. Las marcas '
        '<b>INI</b> y <b>FIN</b> que el equipo dejaba alrededor de cada bloque tocado se consolidan: '
        'veinticuatro marcas en un programa son un cambio, no veinticuatro.',
        f'<div class="tl">{"".join(filas)}</div>')

    s2 = seccion(
        "Método y honestidad de la fuente",
        'Por qué esta capa es la más delgada de las cuatro del AS-IS.',
        '<div class="nota glass">'
        f'Solo <b>{arch}</b> de los {total_fuentes} fuentes ({arch * 100 // total_fuentes}%) traen '
        f'una bitácora fechada legible. Es la cobertura más baja del gemelo y conviene decirlo: '
        f'esta línea de tiempo es un muestreo de la historia del core, no su historia completa. '
        f'Se excluyen además las menciones al año 2000, que no son fechas de cambio sino marcas de '
        f'la remediación Y2K, visibles en el propio código como '
        f'<b>INICIA CODIGO DE RENOVACION CRONOS 2000</b>: contarlas habría inventado un pico de '
        f'1,382 eventos que nunca ocurrió. Las líneas que parecen código comentado se descartan, '
        f'salvo cuando arrancan con fecha, que es la firma inequívoca de una entrada de bitácora.'
        '</div>')

    return pagina("Banamex · Capa 3 Biografía · Enterprise Digital Brain",
                  "biografia.html", h + s1 + s2, PIE)


# ── Capa 7 · Equivalencia ────────────────────────────────────────────────────

SEV_CLS = {"DEFECTO-PROD": "s-def", "CRÍTICO": "s-cri", "ALTO": "s-alt",
           "MEDIO": "s-med", "BAJO": "s-baj"}


def build_equivalencia() -> str:
    con = db()
    riesgos = con.execute("SELECT * FROM riesgos_migracion").fetchall()
    sev = con.execute("SELECT severidad, COUNT(*) n FROM riesgos_migracion "
                      "GROUP BY severidad").fetchall()
    pat = con.execute("SELECT patron_principal p, COUNT(*) n FROM riesgos_migracion "
                      "WHERE patron_principal<>'' GROUP BY p ORDER BY n DESC").fetchall()
    bcs = con.execute("SELECT * FROM equivalencia_bc ORDER BY campos_comp3 DESC").fetchall()
    hall = con.execute("SELECT COUNT(*) n FROM hallazgos").fetchone()["n"]
    hall_sin = con.execute("SELECT COUNT(*) n FROM hallazgos WHERE TRIM(COALESCE(severidad,''))=''"
                           ).fetchone()["n"]
    con.close()

    por_sev = {r["severidad"]: r["n"] for r in sev}
    defectos = [r for r in riesgos if r["severidad"] == "DEFECTO-PROD"]
    comp3 = sum(b["campos_comp3"] for b in bcs)
    tier1 = sum(b["tier1"] for b in bcs)

    h = hero("Capa 7 · Equivalencia · El juicio de la verdad",
             "%d riesgos entre el legacy y el target" % len(riesgos),
             f'La pregunta que decide un cutover bancario no es si el código nuevo funciona, sino si '
             f'se comporta <b>igual</b>. Este es el catálogo de lo que puede divergir: '
             f'<b>{por_sev.get("DEFECTO-PROD", 0)} defectos activos en producción</b>, '
             f'<b>{por_sev.get("CRÍTICO", 0)} críticos</b> y <b>{comp3} campos COMP-3</b> '
             f'de aritmética empaquetada, de los cuales <b>{tier1}</b> son tier-1, que es donde el '
             f'redondeo decide si el asiento contable cuadra.',
             [stat(len(riesgos), "Riesgos"), stat(por_sev.get("DEFECTO-PROD", 0), "Defecto prod"),
              stat(por_sev.get("CRÍTICO", 0), "Críticos"), stat(comp3, "Campos COMP-3"),
              stat(tier1, "Tier-1")])

    maxs = max(por_sev.values()) if por_sev else 1
    fs = "".join(
        f'<div class="row glass"><div><div class="nm sev {SEV_CLS.get(s, "")}">{e(s)}</div></div>'
        f'<div class="barw"><div class="bari" data-w="{por_sev[s] * 100 // maxs}"></div></div>'
        f'<div class="num">{por_sev[s]}</div></div>'
        for s in ["DEFECTO-PROD", "CRÍTICO", "ALTO", "MEDIO", "BAJO"] if s in por_sev)
    s1 = seccion("Severidad", 'Un <b>defecto en producción</b> es código que ya se ejecuta mal hoy; '
                 'corregirlo en el target produce una divergencia intencional contra el legacy, que '
                 'no debe clasificarse como fallo de equivalencia sino documentarse como decisión.',
                 f'<div class="rows">{fs}</div>')

    maxp = pat[0]["n"] if pat else 1
    fp = "".join(
        f'<div class="row glass"><div><div class="nm">{e(p["p"])}</div></div>'
        f'<div class="barw"><div class="bari" data-w="{p["n"] * 100 // maxp}"></div></div>'
        f'<div class="num">{p["n"]}</div></div>' for p in pat)
    s2 = seccion("Patrones de riesgo",
                 'Cómo falla, no dónde. El patrón dice qué técnica de prueba aplica: '
                 '<b>EQUIVALENCIA</b> pide golden-master, <b>PROPIETARIO-MCP</b> pide un sustituto '
                 'de arquitectura, <b>SILENCIOSO</b> pide instrumentación antes de migrar.',
                 f'<div class="rows">{fp}</div>')

    fd = "".join(
        f'<tr><td class="mono">{e(r["riesgo_id"])}</td><td>{e(r["n4"] or r["n2"])}</td>'
        f'<td>{e(r["descripcion"])}</td><td>{e(r["accion"])}</td></tr>' for r in defectos)
    s3 = seccion("Los defectos que ya corren en producción",
                 'Estos no son riesgos de migración: son fallas activas que el legacy ejecuta hoy. '
                 'Cada uno obliga a una decisión humana antes del cutover, porque arreglarlo cambia '
                 'el resultado respecto del sistema que está en producción.',
                 '<table><thead><tr><th>ID</th><th>Proceso</th><th>Defecto</th>'
                 f'<th>Acción requerida</th></tr></thead><tbody>{fd}</tbody></table>')

    fb = "".join(
        f'<tr><td class="mono">{e(b["bc_id"])}</td><td>{e(b["nombre"])}</td>'
        f'<td>{e(b["sistema"])}</td><td>Ola {b["wave"]}</td>'
        f'<td class="num">{b["campos_comp3"]}</td><td class="num">{b["tier1"]}</td></tr>'
        for b in bcs)
    s4 = seccion("Alcance del golden-master",
                 'Los campos COMP-3 son decimal empaquetado: importes monetarios donde el modo de '
                 'redondeo del target decide si el asiento cuadra al centavo. Este es el reparto por '
                 'contexto delimitado, y por lo tanto el tamaño real del esfuerzo de equivalencia.',
                 '<table><thead><tr><th>BC</th><th>Nombre</th><th>Sistema</th><th>Ola</th>'
                 f'<th>COMP-3</th><th>Tier-1</th></tr></thead><tbody>{fb}</tbody></table>')

    s5 = seccion("Dos registros de riesgo, no uno",
                 'Lo que el brain sabe de sus propias contradicciones.',
                 '<div class="nota glass">'
                 f'El brain contiene además una tabla <b>hallazgos</b> con <b>{hall}</b> filas, que '
                 f'es un registro distinto de este catálogo: comparando el texto, solo <b>37</b> de '
                 f'los {len(riesgos)} riesgos tienen equivalente ahí. Además <b>{hall_sin}</b> de '
                 f'esos hallazgos no declaran severidad y el campo usa doce valores distintos para lo '
                 f'que deberían ser seis. Esta vista se construye sobre el catálogo de riesgos de '
                 f'migración, que sí es consistente, y deja el hecho anotado en lugar de elegir uno '
                 f'callando el otro: consolidarlos es trabajo pendiente, no un detalle de formato.'
                 '</div>')

    return pagina("Banamex · Capa 7 Equivalencia · Enterprise Digital Brain",
                  "equivalencia.html", h + s1 + s2 + s3 + s4 + s5, PIE)


# ── main ─────────────────────────────────────────────────────────────────────

PAGINAS = {"almas": ("almas.html", build_almas),
           "biografia": ("biografia.html", build_biografia),
           "equivalencia": ("equivalencia.html", build_equivalencia)}


def write(nombre: str, html_txt: str):
    OUT.mkdir(parents=True, exist_ok=True)
    p = OUT / nombre
    data = html_txt.replace("\r\n", "\n").replace("\n", "\r\n")
    p.write_bytes(data.encode("utf-8"))
    print(f"wrote _staging/{nombre} {len(data):,}")


def main():
    pedidas = [a for a in sys.argv[1:] if not a.startswith("-")] or list(PAGINAS)
    for k in pedidas:
        if k not in PAGINAS:
            sys.exit(f"ERROR: pagina desconocida '{k}'. Opciones: {', '.join(PAGINAS)}")
        nombre, fn = PAGINAS[k]
        write(nombre, fn())
    return 0


if __name__ == "__main__":
    sys.exit(main())

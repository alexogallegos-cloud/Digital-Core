# -*- coding: utf-8 -*-
"""
build-panorama.py — Genera portal/panorama.html desde monex-brain.db.
Panorama AS-IS de MONEX + TO-BE estrategico (Apolo) + alcance del RFP-PAG.
ATTACHa el brain de payments-modernization para la seccion del RFP.
El brain es la fuente de verdad. Nunca editar el HTML a mano.

Usage:
    python generators/build-panorama.py
"""
import sqlite3
import html
import base64
import mimetypes
from pathlib import Path
from datetime import date

BASE = Path(__file__).parent.parent            # monex-brain/
BRAIN = BASE / "monex-brain.db"
RFP_BRAIN = BASE.parent / "projects" / "payments-modernization" / "digital-brain" / "brain.db"
DESIGN = BASE.parent / "design-studio"
THEME = DESIGN / "templates" / "monex-theme.css"
LOGO_DIR = DESIGN / "logos"
LOGO_CANDIDATES = ["monex-logo-white.png", "monex-logo.svg", "monex-logo.png", "Monex_logo.png"]
OUT = BASE / "portal" / "panorama.html"

# --- Constantes de presentacion (RFP / DT, no estructuradas en tabla) ---
AMBITION = ("Duplicar el ingreso del grupo hacia 2030 (de ~1,000 a ~2,000 millones USD) y subir la "
            "mezcla internacional de 20% a 30%. Fuente: dt-inteligencia-negocio/strategic-plan.")
REQ_BREAKDOWN = [("Funcionales", 91), ("Regulatorios y de cumplimiento", 36),
                 ("No funcionales", 61), ("Inteligencia artificial", 40)]
DEMOS = [
    ("D-01", "Configuracion: alta de producto, calendario y cut-off en entorno multi-entidad"),
    ("D-02", "Pago SPEI: flujo completo desde iniciacion multicanal hasta confirmacion"),
    ("D-03", "Pago SWIFT: cross-border con UETR, cargos OUR/SHA/BEN y trazabilidad"),
    ("D-04", "Sanciones: bloqueo, escalamiento, caso y liberacion con evidencia"),
    ("D-05", "Enrutamiento inteligente: seleccion de riel por costo, liquidez y SLA"),
    ("D-06", "Fallback seguro: cambio de ruta con idempotencia garantizada"),
    ("D-07", "Batch/Bulk: procesamiento masivo con prioridad y control de colas"),
    ("D-08", "Conciliacion: deteccion de diferencia y propuesta de ajuste con IA"),
    ("D-09", "Dashboards: monitoreo end-to-end en tiempo real por geografia y riel"),
    ("D-10", "Copiloto IA: consulta de estatus de pago con RAG y sin ejecucion no autorizada"),
]
ACN_DIFF = [
    ("Digital Brain como activo entregado", "El gemelo cognitivo del landscape MONEX ya esta construido; no es un entregable futuro sino un activo que reduce el riesgo de migracion."),
    ("Practica LATAM certificada", "Implementaciones bancarias SPEI y SWIFT en Mexico (Banamex, BanCoppel, Santander)."),
    ("DORA specialist", "Regulacion activa en Monex Europe UK; Accenture tiene practica DORA."),
    ("Ecosistema MuleSoft", "Partner Premier de MuleSoft, el backbone de integracion confirmado de MONEX."),
    ("Fit-to-Standard first", "Accenture no recomienda bespoke sin justificacion; alinea con el principio P-01 del RFP."),
]


def esc(s):
    return html.escape(str(s)) if s is not None else ""


def logo_html():
    """Busca el logo en design-studio/logos/, lo embebe en base64. Fallback: wordmark."""
    for name in LOGO_CANDIDATES:
        f = LOGO_DIR / name
        if f.exists():
            mime = mimetypes.guess_type(str(f))[0] or "image/png"
            b64 = base64.b64encode(f.read_bytes()).decode("ascii")
            return f'<img class="brand-logo" src="data:{mime};base64,{b64}" alt="MONEX">', True
    return '<div class="brand-word">MONEX</div>', False


def rows(conn, sql, params=()):
    try:
        return conn.execute(sql, params).fetchall()
    except sqlite3.Error:
        return []


def badge(status):
    m = {
        "CONFIRMED": "badge-confirmed", "COVERED": "badge-confirmed", "Directo": "badge-confirmed",
        "DONE": "badge-confirmed", "ACTIVE": "badge-confirmed",
        "SCAFFOLD": "badge-scaffold", "PARTIAL": "badge-scaffold", "IN_PROGRESS": "badge-scaffold",
        "Indirecto": "badge-scaffold", "PENDING": "badge-scaffold",
        "TARGET": "badge-target", "N/A": "badge-target",
        "NOT_COVERED": "badge-gap", "gap": "badge-gap",
    }
    cls = m.get(status, "badge-target")
    return f'<span class="badge {cls}">{esc(status)}</span>'


def cov_class(cov):
    return {
        "Standard": "cov-standard",
        "Configurable": "cov-config",
        "Integration": "cov-integration",
        "Bespoke": "cov-bespoke",
        "Not covered": "cov-none",
        "A confirmar": "cov-tbd",
    }.get(cov, "cov-tbd")


def build():
    conn = sqlite3.connect(BRAIN)
    conn.row_factory = sqlite3.Row
    has_rfp = RFP_BRAIN.exists()
    if has_rfp:
        conn.execute("ATTACH DATABASE ? AS rfp", (str(RFP_BRAIN),))

    theme_css = THEME.read_text(encoding="utf-8") if THEME.exists() else ""
    logo_markup, logo_found = logo_html()

    # ---- Read data ----
    holdings = rows(conn, "SELECT * FROM holdings")
    facts = rows(conn, "SELECT * FROM company_facts")
    rails = rows(conn, "SELECT * FROM payment_rails")
    families = rows(conn, "SELECT * FROM product_families")
    products = rows(conn, "SELECT * FROM products ORDER BY family_id, id")
    fam_rail = rows(conn, "SELECT * FROM family_rail")
    strengths = rows(conn, "SELECT * FROM asis_assessment WHERE kind='strength'")
    gaps = rows(conn, "SELECT * FROM asis_assessment WHERE kind='gap'")
    open_q = rows(conn, "SELECT * FROM open_questions")
    etb_tax = rows(conn, "SELECT * FROM etb_payments_taxonomy ORDER BY id")
    initiatives = rows(conn, "SELECT * FROM apolo_initiatives")
    etb = rows(conn, "SELECT * FROM etb_l3 ORDER BY l3_id")

    # RFP brain
    principles = rows(conn, "SELECT * FROM rfp.arch_principles ORDER BY id") if has_rfp else []
    pag = rows(conn, "SELECT * FROM rfp.pag_macrocapabilities ORDER BY code") if has_rfp else []
    reqs = rows(conn, "SELECT * FROM rfp.requirements ORDER BY type, req_id") if has_rfp else []
    ai = rows(conn, "SELECT * FROM rfp.ai_requirements ORDER BY id") if has_rfp else []
    geos = rows(conn, "SELECT * FROM rfp.geographies ORDER BY priority") if has_rfp else []
    cands = rows(conn, "SELECT * FROM rfp.candidates ORDER BY name") if has_rfp else []
    fit = rows(conn, "SELECT * FROM rfp.vendor_rail_fit ORDER BY id") if has_rfp else []
    timeline = rows(conn, "SELECT * FROM rfp.timeline ORDER BY date") if has_rfp else []
    integrations = rows(conn, "SELECT * FROM rfp.integrations ORDER BY priority, system") if has_rfp else []

    # correlation lookup
    fam_rail_set = {(r["family_id"], r["rail_id"]) for r in fam_rail}
    rail_ids = [r["rail_id"] for r in rails]
    rail_names = {r["rail_id"]: r["name"] for r in rails}

    n_prod = len(products)
    n_prod_nm = sum(1 for p in products if p["block"] == "no-mercados")
    n_prod_mk = n_prod - n_prod_nm

    P = []  # html parts
    a = P.append

    # ================= HEAD =================
    a(f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>MONEX — Panorama AS-IS, TO-BE y alcance del RFP</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono&display=swap" rel="stylesheet">
<style>
{theme_css}
/* --- portal panorama --- */
html {{ scroll-behavior: smooth; }}
.wrap {{ max-width: 1180px; margin: 0 auto; padding: 0 1.5rem; }}
.topnav {{ position: sticky; top: 0; z-index: 50; background: rgba(11,29,70,0.97); backdrop-filter: blur(6px); display: flex; flex-wrap: wrap; gap: 0.35rem; padding: 0.6rem 1.5rem; border-bottom: 2px solid var(--s); }}
.topnav a {{ color: #cdd8ee; text-decoration: none; font-size: 0.8rem; font-weight: 600; padding: 0.3rem 0.7rem; border-radius: 6px; }}
.topnav a:hover {{ background: rgba(0,174,239,0.2); color: #fff; }}
.hero {{ background: linear-gradient(135deg, #0B1D46 0%, #12295c 60%, #003a63 100%); color: #fff; padding: 3rem 0 2.2rem; }}
.hero h1 {{ font-size: 2rem; margin: 0 0 0.5rem; }}
.hero .lede {{ color: #b9c6e2; font-size: 1.05rem; max-width: 60ch; line-height: 1.5; }}
.hero .kicker {{ color: var(--s); font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; font-size: 0.78rem; }}
.brand-logo {{ height: 46px; width: auto; margin-bottom: 1.2rem; display: block; filter: brightness(0) invert(1); }}
.brand-word {{ font-size: 1.6rem; font-weight: 800; letter-spacing: 0.14em; color: #fff; margin-bottom: 1.2rem; }}
.brand-word::after {{ content: ""; display: block; width: 46px; height: 4px; background: var(--s); margin-top: 0.4rem; }}
.tl {{ display: flex; flex-wrap: wrap; gap: 0.5rem; margin-top: 1.6rem; }}
.tl .step {{ background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.14); border-radius: 8px; padding: 0.5rem 0.8rem; font-size: 0.78rem; }}
.tl .step b {{ display: block; color: #fff; font-size: 0.85rem; }}
.tl .step span {{ color: #9fb0d0; }}
.tl .step.done {{ border-color: var(--success); }}
.tl .step.now {{ border-color: var(--warning); background: rgba(245,158,11,0.12); }}
.tl .step.next {{ border-color: var(--s); background: rgba(0,174,239,0.12); }}
section {{ padding: 2.6rem 0 1rem; border-top: 1px solid var(--border); }}
section.act {{ background: #fff; }}
h2.sec {{ font-size: 1.5rem; color: var(--a); margin: 0 0 0.3rem; }}
h2.sec .num {{ color: var(--s); font-weight: 800; margin-right: 0.5rem; }}
.sub {{ color: var(--muted); margin: 0 0 1.4rem; max-width: 75ch; line-height: 1.5; }}
h3.blk {{ font-size: 1.1rem; color: var(--a); margin: 1.8rem 0 0.7rem; border-left: 4px solid var(--s); padding-left: 0.6rem; }}
.grid {{ display: grid; gap: 1rem; }}
.g2 {{ grid-template-columns: repeat(2, 1fr); }}
.g3 {{ grid-template-columns: repeat(3, 1fr); }}
.g4 {{ grid-template-columns: repeat(4, 1fr); }}
@media (max-width: 820px) {{ .g2, .g3, .g4 {{ grid-template-columns: 1fr; }} }}
.stat {{ background: var(--bg); border: 1px solid var(--border); border-radius: 8px; padding: 0.9rem 1rem; }}
.stat b {{ display: block; font-size: 1.25rem; color: var(--a); }}
.stat span {{ color: var(--muted); font-size: 0.8rem; }}
.stat small {{ color: var(--s); font-size: 0.7rem; }}
.callout {{ border-left: 4px solid var(--warning); background: #FFFBEB; padding: 1rem 1.2rem; border-radius: 0 8px 8px 0; margin: 1.2rem 0; }}
.callout.win {{ border-color: var(--success); background: #ECFDF5; }}
.callout.info {{ border-color: var(--s); background: #EFF9FE; }}
.callout h4 {{ margin: 0 0 0.3rem; color: var(--a); }}
.tbl-wrap {{ overflow-x: auto; border-radius: 8px; border: 1px solid var(--border); margin: 0.8rem 0; }}
.matrix td, .matrix th {{ text-align: center; padding: 0.4rem 0.5rem; font-size: 0.78rem; }}
.matrix td.fam {{ text-align: left; font-weight: 600; color: var(--a); white-space: nowrap; }}
.matrix th.rot {{ font-size: 0.72rem; }}
.dot {{ display: inline-block; width: 11px; height: 11px; border-radius: 50%; background: var(--s); }}
.matrix tr:hover td {{ background: rgba(0,174,239,0.06); }}
.matrix td.mk {{ background: rgba(0,174,239,0.04); }}
.pill {{ display: inline-block; font-size: 0.68rem; font-weight: 700; padding: 0.1rem 0.45rem; border-radius: 4px; background: #EEF2F7; color: var(--muted); }}
.pill.mk {{ background: #E7F5FB; color: #0369a1; }}
.ev {{ font-family: var(--mono); font-size: 0.7rem; color: var(--muted); }}
.l3head {{ margin: 1rem 0 0.3rem; }}
.fitmx td, .fitmx th {{ text-align: center; font-size: 0.78rem; padding: 0.45rem 0.5rem; }}
.fitmx td.fam {{ text-align: left; font-weight: 600; color: var(--a); white-space: nowrap; }}
.cov-standard {{ background: #D1FAE5; color: #065F46; font-weight: 600; }}
.cov-config {{ background: #E7F5FB; color: #0369A1; }}
.cov-integration {{ background: #DBEAFE; color: #1E40AF; }}
.cov-bespoke {{ background: #FEF3C7; color: #92400E; }}
.cov-none {{ background: #FEE2E2; color: #991B1B; }}
.cov-tbd {{ background: #F1F5F9; color: #6B7280; }}
.legend {{ display: flex; flex-wrap: wrap; gap: 0.5rem; margin: 0.6rem 0; }}
.legend span {{ font-size: 0.72rem; padding: 0.15rem 0.5rem; border-radius: 4px; }}
.foot {{ background: var(--a); color: #9fb0d0; padding: 1.5rem; text-align: center; font-size: 0.78rem; margin-top: 2rem; }}
.qa {{ background: var(--bg); border: 1px solid var(--border); border-left: 4px solid var(--a); border-radius: 0 8px 8px 0; padding: 0.8rem 1rem; margin-bottom: 0.7rem; }}
.qa b {{ color: var(--a); }}
</style></head><body>""")

    # ================= HERO =================
    a(f"""<header class="hero" id="hero"><div class="wrap">
{logo_markup}
<div class="kicker">MONEX Grupo Financiero, Digital Brain, uso interno Accenture</div>
<h1>Panorama AS-IS, TO-BE estratégico y alcance del RFP</h1>
<p class="lede">MONEX moderniza su motor de pagos vía el RFP-PAG. Accenture concurre como integrador (SI) en propuesta conjunta con una plataforma. Este documento consolida el estado actual, la ambición y lo que el RFP exige, con la información recabada por investigación pública.</p>
</div></header>""")

    # ================= PART 1 AS-IS =================
    a('<section class="act" id="as-is"><div class="wrap">')
    a('<h2 class="sec"><span class="num">1</span>Panorama AS-IS de MONEX</h2>')
    a('<p class="sub">Quién es MONEX hoy, cómo está estructurado, qué vende y cómo mueve el dinero. Datos de investigación pública (monex.com.mx, monexglobal.com, HR Ratings 2024, Monex S.A.P.I. 4T24, BMV, Banxico, CLS, SWIFT).</p>')

    # facts
    a('<h3 class="blk">Escala</h3><div class="grid g4">')
    for f in facts[:8]:
        a(f'<div class="stat"><b>{esc(f["value"].split(";")[0])}</b><span>{esc(f["metric"])}</span> <small>{esc(f["year"])}</small></div>')
    a('</div>')

    # holdings — the MNI finding
    a('<h3 class="blk">Estructura de holdings</h3>')
    a('<div class="callout info"><h4>Hallazgo estructural: dos holdings</h4>Los brazos internacionales de FX y pagos se separaron del Grupo Financiero Monex en 2017 y hoy cuelgan de un holding distinto. El alcance del RFP cruza ambos.</div>')
    a('<div class="grid g2">')
    for h in holdings:
        a(f'<div class="card"><h4>{esc(h["name"])} <span class="pill">{esc(h["holding"])}</span></h4><p class="ev">{esc(h["entities"])}</p><p>{esc(h["note"])}</p></div>')
    a('</div>')

    a('</div></section>')

    # ---- Productos (exhaustivo) ----
    a('<section id="productos"><div class="wrap">')
    a(f'<h2 class="sec">Catálogo de productos</h2>')
    a(f'<p class="sub">Aproximadamente {n_prod} productos comerciales en {len(families)} familias, dos bloques: no-mercados ({n_prod_nm}) y mercados ({n_prod_mk}). Detalle exhaustivo por familia, con la liquidación que dispara cada producto.</p>')
    fam_by_block = {"no-mercados": [], "mercados": []}
    for fam in families:
        fam_by_block.setdefault(fam["block"], []).append(fam)
    for block_key, block_label in [("no-mercados", "Bloque no-mercados"), ("mercados", "Bloque mercados / FX")]:
        a(f'<h3 class="blk">{esc(block_label)}</h3>')
        for fam in fam_by_block.get(block_key, []):
            fam_products = [p for p in products if p["family_id"] == fam["family_id"]]
            if not fam_products:
                continue
            rail_tags = " ".join(f'<span class="pill mk">{esc(rail_names.get(rid, rid))}</span>'
                                 for rid in rail_ids if (fam["family_id"], rid) in fam_rail_set)
            a(f'<p style="margin:1rem 0 0.3rem"><b>{esc(fam["name"])}</b> &nbsp; {rail_tags}</p>')
            a('<div class="tbl-wrap"><table><thead><tr><th>Producto</th><th>Entidad</th><th>Holding</th><th>Segmento</th><th>Descripción</th><th>Liquidación</th><th>Ev.</th></tr></thead><tbody>')
            for p in fam_products:
                a(f'<tr><td><b>{esc(p["name_es"])}</b><br><span class="ev">{esc(p["id"])} —{esc(p["name_en"])}</span></td>'
                  f'<td>{esc(p["entity"])}</td><td><span class="pill">{esc(p["holding"])}</span></td>'
                  f'<td>{esc(p["segment"])}</td><td>{esc(p["description"])}</td><td>{esc(p["settlement"])}</td>'
                  f'<td class="ev">{esc(p["evidence"])}</td></tr>')
            a('</tbody></table></div>')
    a('</div></section>')

    # ---- Tipos de pago / rieles ----
    a('<section class="act" id="pagos"><div class="wrap">')
    a('<h2 class="sec">Tipos de pago y rieles</h2>')
    a(f'<p class="sub">MONEX mueve dinero por {len(rails)} rieles. Participación directa en los rieles core de México y en SWIFT y CLS; los rieles internacionales se alcanzan de forma indirecta vía bancos patrocinadores.</p>')
    a('<div class="tbl-wrap"><table><thead><tr><th>Riel</th><th>Alcance</th><th>Participación</th><th>Nota</th><th>Fuente</th></tr></thead><tbody>')
    for r in rails:
        a(f'<tr><td><b>{esc(r["name"])}</b></td><td>{esc(r["scope"])}</td><td>{badge(r["participation"])}</td><td>{esc(r["note"])}</td><td class="ev">{esc(r["source"])}</td></tr>')
    a('</tbody></table></div>')
    a('</div></section>')

    # ---- Matriz ejecutiva producto x pago ----
    a('<section id="matriz"><div class="wrap">')
    a('<h2 class="sec">Matriz producto × tipo de pago</h2>')
    a('<p class="sub">Vista ejecutiva del blast-radius: qué familia de producto dispara qué riel. Es el mapa para ordenar las olas de migración y evaluar el riesgo por capability.</p>')
    a('<div class="tbl-wrap"><table class="matrix"><thead><tr><th class="fam">Familia</th>')
    for rid in rail_ids:
        a(f'<th class="rot">{esc(rail_names[rid])}</th>')
    a('</tr></thead><tbody>')
    for fam in families:
        a(f'<tr><td class="fam">{esc(fam["name"])} <span class="pill">{esc(fam["block"])}</span></td>')
        for rid in rail_ids:
            if (fam["family_id"], rid) in fam_rail_set:
                a('<td class="mk"><span class="dot"></span></td>')
            else:
                a('<td></td>')
        a('</tr>')
    a('</tbody></table></div>')
    a('<div class="callout info"><h4>Señal de scope</h4>El bloque de inversión (casa de bolsa, fondos, wealth) liquida por Indeval, no por el motor de pagos. El motor nuevo es relevante sobre todo para cash management, dispersión de crédito, comercio exterior y liquidación de FX.</div>')
    a('</div></section>')

    # ---- AS-IS strengths / gaps ----
    a('<section class="act" id="assessment"><div class="wrap">')
    a('<h2 class="sec">Fortalezas y gaps del AS-IS</h2>')
    a('<div class="grid g2"><div>')
    a('<h3 class="blk">Fortalezas</h3>')
    for s in strengths:
        a(f'<div class="callout win"><h4>{esc(s["item"])}</h4>{esc(s["detail"])}</div>')
    a('</div><div>')
    a('<h3 class="blk">Gaps reales</h3>')
    for g in gaps:
        a(f'<div class="callout"><h4>{esc(g["item"])}</h4>{esc(g["detail"])}</div>')
    a('</div></div>')
    a('</div></section>')

    # ================= PART 2 TO-BE =================
    a('<section id="to-be"><div class="wrap">')
    a('<h2 class="sec"><span class="num">2</span>TO-BE estratégico</h2>')
    a(f'<p class="sub">A dónde quiere ir MONEX. {esc(AMBITION)}</p>')
    a('<h3 class="blk">Programa Apolo — 4 iniciativas</h3><div class="grid g2">')
    for i in initiatives:
        a(f'<div class="card"><h4>{esc(i["name"])} {badge(i["status"])}</h4><p>{esc(i["description"])}</p>'
          + (f'<p class="ev">Reemplaza: {esc(i["replaces"])}</p>' if i["replaces"] else '') + '</div>')
    a('</div>')
    if principles:
        a('<h3 class="blk">Principios de arquitectura objetivo (RFP)</h3><div class="grid g3">')
        for p in principles:
            a(f'<div class="stat"><b style="font-size:0.95rem">{esc(p["id"])} —{esc(p["name"])}</b><span>{esc(p["description"])}</span></div>')
        a('</div>')
    a('<div class="callout info"><h4>Motor de pagos objetivo</h4>Cloud-native, ISO 20022 nativo, CLS nativo, multi-riel, STP igual o mayor a 99% y disponibilidad 24/7. Patrón de modernización Strangler-Fig por capability con parallel-run obligatorio.</div>')
    a('</div></section>')

    # ================= ETB PAYMENTS TAXONOMY =================
    if etb_tax:
        subdomains = []
        tree = {}
        l3names = {}
        for r in etb_tax:
            sd = (r["subdomain_id"], r["subdomain"])
            if sd not in tree:
                tree[sd] = {}
                subdomains.append(sd)
            l3key = r["l3_id"]
            l3names[l3key] = r["l3_capability"]
            tree[sd].setdefault(l3key, []).append((r["l4_process"], r["monex_map"]))
        n_l3 = len(l3names)
        n_l4 = len(etb_tax)
        a('<section class="act" id="etb-pagos"><div class="wrap">')
        a('<h2 class="sec">Taxonomía de procesos de pago (ETB Banking)</h2>')
        a(f'<p class="sub">Descomposición de los procesos de pago derivada del ETB Banking V5.0 en cuatro niveles: L1 Dominio, L2 Subdominio, L3 Capacidad y L4 Proceso. {len(subdomains)} subdominios, {n_l3} capacidades y {n_l4} procesos. El ETB nativo llega hasta L3 Capacidad; el L4 Proceso se deriva de las macro-capabilities PAG del RFP y de la arquitectura de referencia de pagos.</p>')
        a('<div class="callout info"><h4>L1 Dominio 3 — Product &amp; Service</h4>En el ETB, Pagos es el subdominio 3.4 dentro del dominio Product &amp; Service. Se incluye también 3.6 Trade Finance por relevancia para MONEX (cartas de crédito y cobranza documentaria). El mapeo MONEX apunta cada proceso a su macro-capability PAG, requisito del RFP o riel.</div>')
        for sd_id, sd_name in subdomains:
            a(f'<h3 class="blk">L2 {esc(sd_id)} — {esc(sd_name)}</h3>')
            for l3key, procs in tree[(sd_id, sd_name)].items():
                a(f'<p class="l3head"><b>{esc(l3key)} — {esc(l3names[l3key])}</b> <span class="pill">L3 Capacidad</span></p>')
                a('<div class="tbl-wrap"><table><thead><tr><th>L4 Proceso</th><th>Mapeo MONEX</th></tr></thead><tbody>')
                for proc, mp in procs:
                    a(f'<tr><td>{esc(proc)}</td><td class="ev">{esc(mp)}</td></tr>')
                a('</tbody></table></div>')
        a('</div></section>')

    # ================= PART 3 RFP =================
    a('<section class="act" id="rfp"><div class="wrap">')
    a('<h2 class="sec"><span class="num">3</span>Alcance del RFP-PAG</h2>')
    a('<p class="sub">Qué pide MONEX para llegar al TO-BE. Propuesta conjunta Vendor y SI; Accenture como integrador responsable de implementación, Fit-to-Standard, diseño, configuración, integración, migración, pruebas, cutover, adopción, seguridad y estabilización.</p>')

    # req breakdown
    a('<h3 class="blk">Requisitos del apéndice PAG-D07</h3><div class="grid g4">')
    total = 0
    for label, n in REQ_BREAKDOWN:
        total += n
        a(f'<div class="stat"><b>{n}</b><span>{esc(label)}</span></div>')
    a(f'<div class="stat"><b>{total}</b><span>Total de requisitos</span></div>')
    a('</div>')

    # geographies
    if geos:
        a('<h3 class="blk">Alcance geográfico</h3><div class="tbl-wrap"><table><thead><tr><th>Geografía</th><th>Rieles</th><th>Reguladores</th></tr></thead><tbody>')
        for g in geos:
            a(f'<tr><td><b>{esc(g["name"])}</b></td><td>{esc(g["rails"])}</td><td>{esc(g["regulators"])}</td></tr>')
        a('</tbody></table></div>')

    # PAG macrocaps
    if pag:
        a('<h3 class="blk">10 macro-capabilities PAG</h3><div class="grid g2">')
        for p in pag:
            a(f'<div class="stat"><b style="font-size:0.95rem">{esc(p["code"])} —{esc(p["name"])}</b><span>{esc(p["description"])}</span></div>')
        a('</div>')

    # requirements exhaustive
    if reqs:
        by_type = {}
        for r in reqs:
            by_type.setdefault(r["type"], []).append(r)
        labels = {"functional": "Requisitos funcionales críticos", "non-functional": "Requisitos no funcionales críticos", "compliance": "Requisitos regulatorios críticos"}
        for t, label in labels.items():
            group = by_type.get(t, [])
            if not group:
                continue
            a(f'<h3 class="blk">{esc(label)}</h3><div class="tbl-wrap"><table><thead><tr><th>ID</th><th>Categoría</th><th>Descripción</th><th>Evidencia requerida</th></tr></thead><tbody>')
            for r in group:
                a(f'<tr><td><b>{esc(r["req_id"])}</b></td><td>{esc(r["category"])}</td><td>{esc(r["description"])}</td><td class="ev">{esc(r["evidence_required"])}</td></tr>')
            a('</tbody></table></div>')

    # AI reqs
    if ai:
        a('<h3 class="blk">12 requisitos de inteligencia artificial</h3><div class="tbl-wrap"><table><thead><tr><th>ID</th><th>Capability</th><th>Descripción</th></tr></thead><tbody>')
        for r in ai:
            a(f'<tr><td><b>{esc(r["id"])}</b></td><td>{esc(r["capability"])}</td><td>{esc(r["description"])}</td></tr>')
        a('</tbody></table></div>')

    # candidates
    if cands:
        a('<h3 class="blk">Candidatos de plataforma</h3><div class="tbl-wrap"><table><thead><tr><th>Plataforma</th><th>Vendor</th><th>ISO 20022</th><th>CLS</th><th>SPEI</th><th>Cloud-native</th></tr></thead><tbody>')
        for c in cands:
            yn = lambda v: "Sí" if v else "No"
            a(f'<tr><td><b>{esc(c["name"])}</b></td><td>{esc(c["vendor"])}</td><td>{yn(c["iso20022_native"])}</td><td>{yn(c["cls_support"])}</td><td>{yn(c["spei_support"])}</td><td>{yn(c["cloud_native"])}</td></tr>')
        a('</tbody></table></div>')
        a('<p class="ev">Sí = nativo o evidenciado hoy; No = no evidenciado públicamente (posible build). El detalle por vendor vive en los SMEs de Payments Transformation.</p>')

    # fit-gap por tipo de pago x vendor
    if fit:
        vendors_order = []
        railmap = {}
        rails_order = []
        for r in fit:
            v = r["vendor"]
            if v not in vendors_order:
                vendors_order.append(v)
            rl = r["rail"]
            if rl not in railmap:
                railmap[rl] = {}
                rails_order.append(rl)
            railmap[rl][v] = (r["coverage"], r["note"])
        a('<h3 class="blk">Fit-gap por tipo de pago y vendor</h3>')
        a('<p class="sub">Cobertura de cada riel por plataforma, según la investigación de los SMEs. El valor es el factor de cobertura, no un sí/no: Standard nativo, Configurable, Integration, Bespoke net-new, Not covered, o A confirmar. Las celdas A confirmar son la lista de preguntas duras para el RFP y las llamadas de referencia.</p>')
        a('<div class="legend">'
          '<span class="cov-standard">Standard</span>'
          '<span class="cov-config">Configurable</span>'
          '<span class="cov-integration">Integration</span>'
          '<span class="cov-bespoke">Bespoke</span>'
          '<span class="cov-none">Not covered</span>'
          '<span class="cov-tbd">A confirmar</span>'
          '</div>')
        a('<div class="tbl-wrap"><table class="fitmx"><thead><tr><th class="fam">Riel / tipo de pago</th>')
        for v in vendors_order:
            a(f'<th>{esc(v)}</th>')
        a('</tr></thead><tbody>')
        for rl in rails_order:
            a(f'<tr><td class="fam">{esc(rl)}</td>')
            for v in vendors_order:
                cov, note = railmap[rl].get(v, ("A confirmar", ""))
                title = f' title="{esc(note)}"' if note else ''
                a(f'<td class="{cov_class(cov)}"{title}>{esc(cov)}</td>')
            a('</tr>')
        a('</tbody></table></div>')
        a('<div class="callout win"><h4>Lectura del fit-gap</h4>En CLS solo Finastra es Standard (producto nativo PAYplus for CLS); en SPEI/SPID solo Volante y 2innovate están evidenciados hoy. Ningún vendor cubre de forma nativa a la vez CLS y los rieles mexicanos: esa es la tensión central de la decisión para MONEX.</div>')

    # demos
    a('<h3 class="blk">10 escenarios de demostración (28-Sep)</h3><div class="tbl-wrap"><table><thead><tr><th>ID</th><th>Escenario</th></tr></thead><tbody>')
    for d in DEMOS:
        a(f'<tr><td><b>{esc(d[0])}</b></td><td>{esc(d[1])}</td></tr>')
    a('</tbody></table></div>')
    a('</div></section>')

    # ================= CIERRE =================
    a('<section id="cierre"><div class="wrap">')
    a('<h2 class="sec">Posición Accenture y preguntas abiertas</h2>')
    a('<h3 class="blk">Diferenciadores</h3><div class="grid g2">')
    for t, d in ACN_DIFF:
        a(f'<div class="callout win"><h4>{esc(t)}</h4>{esc(d)}</div>')
    a('</div>')
    a('<h3 class="blk">Preguntas abiertas para Rafa (Design Authority)</h3>')
    for q in open_q:
        a(f'<div class="qa"><b>{esc(q["topic"])}.</b> {esc(q["question"])}</div>')
    a('</div></section>')

    a(f'<div class="foot">Generado desde monex-brain.db por generators/build-panorama.py —{date.today().isoformat()} —Uso interno Accenture —No editar el HTML a mano</div>')
    a('</body></html>')

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("".join(P), encoding="utf-8")
    conn.close()
    print(f"OK: {OUT}")
    print(f"  Productos: {n_prod} —Familias: {len(families)} —Rieles: {len(rails)}")
    print(f"  RFP: {len(reqs)} req criticos —{len(pag)} PAG —{len(ai)} IA —{len(cands)} candidatos —{len(timeline)} hitos")
    if logo_found:
        print("  Logo: embebido desde design-studio/logos/")
    else:
        print("  Logo: NO encontrado — usando wordmark. Deja el archivo en design-studio/logos/ y regenera.")


if __name__ == "__main__":
    build()

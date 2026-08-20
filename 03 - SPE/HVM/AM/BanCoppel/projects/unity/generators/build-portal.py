#!/usr/bin/env python3
"""
Unity R4 — Portal Generator
Genera portal/index.html desde digital-brain/brain.db
SPE-AM-001 · BanCoppel · Regla AM-8: portal/*.html siempre generado, nunca hand-authored

Uso:
    python generators/build-portal.py
    python generators/build-portal.py --brain path/to/brain.db --out portal/index.html
"""

import sqlite3, json, argparse, html, math
from datetime import date, datetime
from pathlib import Path

# Orientaciones del cubo hero para cada vista (face hacia la cámara)
CUBE_ORIENTATIONS = [
    ("productos",   "rotateX(-70deg) rotateY(-20deg)"),
    ("sistemas",    "rotateX(-10deg) rotateY(-5deg)"),
    ("capacidades", "rotateX(-10deg) rotateY(-80deg)"),
]

ROOT   = Path(__file__).parent.parent
BRAIN  = ROOT / "digital-brain" / "brain.db"
OUTPUT = ROOT / "portal" / "index.html"

GOLIVE = date(2027, 1, 15)

KNOWN_STATUSES = {"productivo", "live", "building", "backlog", "planned", "retired", "sin-definir", "retracted"}

# ── Vista Producto — Capabilities de Negocio (DT-Productos v1.1.0 · 2026-08-20) ─
# Fuente autoritativa: dt/dt-productos.md § "Capacidades de Negocio (ETB)"
# sem: "crit" = 🔴 crítico, "warn" = 🟡 at risk, "ok" = 🟢
CAPABILITIES_VP = [
    {"label": "Emisión TDC",        "system": "SmartVista",            "sem": "warn", "note": "Gaps DPP, BYU0039, OCG manual"},
    {"label": "Originación Digital","system": "APOLO",                 "sem": "warn", "note": "Latencia 9s en PROD sin plan"},
    {"label": "Canal Digital",      "system": "App / SIWEB / CAT",     "sem": "crit", "note": "CAT sin contratar; SIWEB bloqueado"},
    {"label": "Cobranza",           "system": "Cobranza Direccionada",  "sem": "warn", "note": "Pentest nov 15-20 vs SIT"},
    {"label": "Integración",        "system": "Apificación",           "sem": "warn", "note": "Inventario no consolidado"},
    {"label": "Reg. Reporting",     "system": "Reportes Regulatorios", "sem": "warn", "note": "Alcance R4 sin confirmar"},
]

# KPIs de la Vista Producto — disponibles ahora desde brain.db o DT; gaps marcados
KPIS_VP = [
    {"label": "User Stories R4",  "value": "~116-129",  "sub": "Total comprometidas",         "gap": False},
    {"label": "Must Have",        "value": "46",         "sub": "Must Have en inventario",     "gap": False},
    {"label": "Tracks en Riesgo", "value": "5 / 6",      "sub": "1 crítico · 4 at risk",       "gap": False},
    {"label": "Avance R4",        "value": "21.19%",     "sub": "vs 60.58% esp. (17-ago)",     "gap": False},
    {"label": "Clientes Obj.",    "value": "GAP",        "sub": "GAP-VP-001 sin dato",         "gap": True},
    {"label": "SLA Autorización", "value": "GAP",        "sub": "GAP-VP-002 sin dato",         "gap": True},
]

# Bloqueos de negocio activos — perspectiva de valor al cliente, no técnica
BLOCKERS_VP = [
    {"text": "CAT (Contact Center) sin proveedor contratado",         "cap": "Canal Digital",       "owner": "BanCoppel",         "level": "crit"},
    {"text": "SIWEB bloqueado — esperando contratos API de Apific.",  "cap": "Canal Digital",       "owner": "Apificación (ACN)", "level": "warn"},
    {"text": "Latencia APOLO 9s en PROD sin plan de mejora firmado",  "cap": "Originación Digital", "owner": "Appwhere",          "level": "warn"},
    {"text": "Inventario de integraciones sin consolidar",            "cap": "Integración",         "owner": "Apificación (ACN)", "level": "warn"},
    {"text": "Pentest nov 15-20 puede congelar ambiente SIT",         "cap": "Cobranza",            "owner": "BanCoppel / Infra", "level": "warn"},
]

# ── IT Capabilities (cara verde del cubo) ─────────────────────────────────────
# No hay tabla dedicada en el brain aún → config estática en el generador.
# Cuando se agregue la tabla `it_capabilities` al brain, leer de ahí.
IT_CAPS = {
    "Engineering": ["QE", "DevOps"],
    "Delivery":    ["Arquitectura", "Interoperabilidad", "Ambientación", "Seguridad"],
    "Operations":  ["Observabilidad", "Change", "Release", "Vendor Mgmt", "Compliance"],
    "Data":        ["Data / Migración"],
}

# ── Digital Twins config (no hay tabla en el brain aún) ───────────────────────
DT_GROUPS = [
    {
        "label": "Programa y Gestión",
        "twins": [
            {"ico": "📋", "ver": "v1.0.0", "name": "Plan Director",
             "desc": "Visión transversal del programa, KPI framework, dashboard RAG cruzado, 8 acciones críticas, anti-silos.",
             "chips": [("yellow","KPIs"),("blue","RAG"),("blue","76 User Stories")],
             "link": "plan-director.html", "warn": True},
            {"ico": "🏛️", "ver": "v1.0.0", "name": "Gobierno",
             "desc": "Estructura de comités, RACI del programa, protocolo de escalación, RAID owners y frecuencias.",
             "chips": [("blue","Comités"),("blue","RACI"),("blue","RAID")]},
            {"ico": "👥", "ver": "v2.0.0", "name": "Equipo",
             "desc": "Roster por componente, rotación crítica dic-ene, capacidad vs demanda, plan de Change Management.",
             "chips": [("yellow","Change Mgmt"),("red","Vacante Lead")], "warn": True},
            {"ico": "⚠️", "ver": "v1.0.0", "name": "Riesgos",
             "desc": "18 riesgos RAID, 9 alta prioridad, mitigaciones y owners, RISK-001 CAT sin contrato.",
             "chips": [("red","9 Alta"),("yellow","8 Media"),("blue","RAID")], "crit": True},
            {"ico": "📅", "ver": "v1.1.0", "name": "Cronograma",
             "desc": "Hitos R4 con semáforo, SIT oct, Code Freeze dic, Go-Live 15-ene-2027, fechas en riesgo.",
             "chips": [("yellow","At Risk"),("blue","Go-Live ene-2027")], "warn": True},
            {"ico": "🏪", "ver": "v1.0.0", "name": "Vendors",
             "desc": "8 vendors, modelo SIAM, CAT sin contratar, BYU0039, DPP, maquiladores AppWhere.",
             "chips": [("red","CAT urgente"),("blue","SIAM"),("blue","8 vendors")], "crit": True},
        ],
    },
    {
        "label": "Delivery Técnico",
        "twins": [
            {"ico": "💳", "ver": "v1.0.0", "name": "SmartVista BPC",
             "desc": "58 HDUs, 14 DTMs, cobertura PreGame, gaps críticos DPP, BYU0039 y OCG manual.",
             "chips": [("blue","58 HDUs"),("red","5 gaps críticos")], "warn": True},
            {"ico": "🚀", "ver": "v1.1.0", "name": "APOLO",
             "desc": "37 HDUs originación digital, 10 fases, 13 sprints backend, integración crítica con SmartVista (HDU-20).",
             "chips": [("blue","37 HDUs"),("yellow","Tensión fechas")], "warn": True},
            {"ico": "🧪", "ver": "v1.0.0", "name": "SIT / UAT",
             "desc": "Plan de pruebas por capability, conflicto pentest nov 15-20, triage, criterios entrada y salida.",
             "chips": [("yellow","Conflicto pentest"),("blue","14 caps")]},
            {"ico": "📦", "ver": "v1.0.0", "name": "Productos",
             "desc": "Catálogo P4900, componentes R4 por track, alcance confirmado, User Stories por canal.",
             "chips": [("blue","P4900"),("blue","5 tracks"),("blue","76 USs")]},
        ],
    },
    {
        "label": "Arquitectura y Operación",
        "twins": [
            {"ico": "🔀", "ver": "v1.0.0", "name": "Coexistencia",
             "desc": "Routing Informix ↔ Unity por canal y producto, tipos MONEY, migration fate, parallel run.",
             "chips": [("blue","Informix"),("blue","Transact"),("blue","11 rutas")]},
            {"ico": "📊", "ver": "v1.0.0", "name": "SLO y Observabilidad",
             "desc": "SLIs y SLOs por capability, criterios cuantitativos de cutover, business observability, trazabilidad.",
             "chips": [("blue","SLOs"),("blue","Cutover criteria")]},
            {"ico": "⚖️", "ver": "v1.0.0", "name": "Compliance",
             "desc": "CNBV Art.76 LIC, PCI-DSS v4.0 scope SmartVista, CONDUSEF, timeline regulatorio R4.",
             "chips": [("blue","CNBV"),("blue","PCI-DSS v4.0"),("blue","CONDUSEF")]},
            {"ico": "🛡️", "ver": "v1.0.0", "name": "Ops Readiness",
             "desc": "PRR por capability, runbooks, modelo on-call, DRP, rollback plan, handoff AMS Reinvention.",
             "chips": [("blue","PRR"),("blue","Runbooks"),("blue","DRP")]},
        ],
    },
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def h(s):
    return html.escape(str(s)) if s else ""

def days_to_golive():
    return (GOLIVE - date.today()).days

def badge_status(status):
    map_ = {
        "productivo": ("b-tg", "prod"),
        "live":       ("b-tg", "prod"),
        "building":   ("b-tr", "build"),
        "backlog":    ("b-bl", "backlog"),
        "planned":    ("b-bl", "backlog"),
        "retired":    ("b-vc", "ret"),
    }
    cls, label = map_.get(status, ("b-bl", status or ""))
    return f'<span class="cfbadge {cls}">{label}</span>'

def rag_dot(color):
    return {"red": "🔴", "yellow": "🟡", "green": "🟢"}.get(color, "⚪")

def rag_css(color):
    return {"red": "r", "yellow": "y", "green": "g"}.get(color, "")

def risk_severity_css(impact, probability):
    if impact in ("critical", "high") and probability == "high":
        return ""          # rcard default (rojo)
    return "med"           # rcard med (amarillo)

def milestone_tag(status):
    map_ = {
        "pending":  ("pend", "Pendiente"),
        "at_risk":  ("risk", "At Risk"),
        "achieved": ("ok",   "Logrado"),
        "missed":   ("risk", "Vencido"),
    }
    cls, label = map_.get(status, ("pend", status or ""))
    return f'<span class="ntag {cls}">{label}</span>'

# ── Queries ───────────────────────────────────────────────────────────────────

def load_data(db_path):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    # Productos + releases
    products = con.execute(
        "SELECT * FROM products ORDER BY id"
    ).fetchall()
    releases = con.execute(
        "SELECT * FROM product_releases ORDER BY product_id, id"
    ).fetchall()

    # Sistemas (program_components)
    components = con.execute(
        "SELECT * FROM program_components ORDER BY type, name"
    ).fetchall()

    # RAG por track
    track_rags = con.execute(
        "SELECT * FROM track_rag ORDER BY rag_color, track"
    ).fetchall()

    # KPIs dinámicos
    total_hus = con.execute(
        "SELECT COALESCE(SUM(hu_total),0) FROM track_rag"
    ).fetchone()[0]
    high_risks = con.execute(
        "SELECT COUNT(*) FROM risks WHERE probability='high' AND status='open'"
    ).fetchone()[0]

    # Riesgos (alta prioridad abiertos primero)
    risks = con.execute("""
        SELECT r.*, pc.name AS component_name
        FROM risks r
        LEFT JOIN program_components pc ON r.component_id = pc.id
        WHERE r.status IN ('open','escalated')
        ORDER BY
            CASE r.probability WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END,
            CASE r.impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END
        LIMIT 9
    """).fetchall()

    # Milestones
    milestones = con.execute(
        "SELECT * FROM milestones ORDER BY target_date"
    ).fetchall()

    con.close()
    return {
        "products":    products,
        "releases":    releases,
        "components":  components,
        "track_rags":  track_rags,
        "total_hus":   total_hus,
        "high_risks":  high_risks,
        "risks":       risks,
        "milestones":  milestones,
    }

# ── Render parciales ──────────────────────────────────────────────────────────

EXCLUDED_STATUSES = {"sin-definir", "undefined", "tbd", "backlog", "planned"}

def _static_cube(variant, top="", front="", right=""):
    """Cubo decorativo estático con contenido real en la cara destacada (p=top, s=front, c=right)."""
    return f"""<div class="vw-scene">
          <div class="cube3d vw-static vw-static-{variant}">
            <div class="cf cf-top"><div class="cf-title">Productos</div>{top}</div>
            <div class="cf cf-front"><div class="cf-title">Sistemas</div>{front}</div>
            <div class="cf cf-right"><div class="cf-title">Capacidades IT</div>{right}</div>
            <div class="cf cf-back"><div class="cf-title">Unity R4</div></div>
            <div class="cf cf-left"></div>
            <div class="cf cf-bot"></div>
          </div>
        </div>"""


def render_view_productos(products, releases, cube_top_content="", cube_img=None):
    """Vista Productos: capabilities de negocio con semáforo, KPIs y bloqueos activos. Fuente: DT-Productos."""
    # Capabilities semáforo
    sem_icon = {"crit": "🔴", "warn": "🟡", "ok": "🟢"}
    caps_html = ""
    for cap in CAPABILITIES_VP:
        icon = sem_icon.get(cap["sem"], "⚪")
        caps_html += (
            f'<div class="vp-cap {cap["sem"]}">'
            f'<div class="vp-caplabel">{icon} {h(cap["label"])}</div>'
            f'<div class="vp-capsys">{h(cap["system"])}</div>'
            f'<div class="vp-capnote">{h(cap["note"])}</div>'
            f'</div>'
        )

    # KPIs
    kpis_html = ""
    for kpi in KPIS_VP:
        gap_cls = " gap" if kpi["gap"] else ""
        kpis_html += (
            f'<div class="vp-kpi{gap_cls}">'
            f'<div class="vp-kval">{h(kpi["value"])}</div>'
            f'<div class="vp-klabel">{h(kpi["label"])}</div>'
            f'<div class="vp-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # Bloqueos
    blocks_html = ""
    for blk in BLOCKERS_VP:
        blocks_html += (
            f'<div class="vp-block {blk["level"]}">'
            f'<div style="flex:1">'
            f'<div class="vp-btext">{h(blk["text"])}</div>'
            f'<div class="vp-bsub">{h(blk["cap"])} · {h(blk["owner"])}</div>'
            f'</div>'
            f'</div>'
        )

    cube_el = (f'<img src="{cube_img}" alt="Productos" class="vw-cube-img">'
               if cube_img else _static_cube("p", top=cube_top_content))
    return f"""
        <div class="wrap">
        <div class="vw-grid reveal">
          <div class="vw-cube-wrap">
            {cube_el}
          </div>
          <div class="vw-body">
            <div class="kick">Vista · Productos</div>
            <h2 class="vw-h2 vwc-p">Eje Rector del Programa</h2>
            <p class="vw-desc">Visión end-to-end desde el negocio — Producto P4900, Tarjeta de Crédito. Gobierna el valor liberado a través de capacidades de negocio, User Stories y SLAs. Fuente autoritativa: DT-Productos v1.1.0.</p>
            <div class="vp-section-label">Capacidades de Negocio</div>
            <div class="vp-caps">{caps_html}</div>
            <div class="vp-section-label">KPIs del Programa</div>
            <div class="vp-kpis">{kpis_html}</div>
            <div class="vp-section-label">Bloqueos Activos al Valor</div>
            <div class="vp-blocks">{blocks_html}</div>
          </div>
        </div>
        </div>"""


def render_view_sistemas(components, cube_front_content="", cube_img=None):
    """Sección Vista Sistemas: contenido izquierda, cubo derecha orientado a cara frontal (azul)."""
    groups = {"channel": ("Channels", []), "core": ("Core", []),
              "enabler": ("Processors", []), "transversal": ("Data, Integration", [])}
    order  = ["channel", "core", "enabler", "transversal"]
    for c in components:
        t = c["type"] if c["type"] in groups else "transversal"
        groups[t][1].append(c)

    lines = []
    for key in order:
        label, items = groups[key]
        if not items:
            continue
        lines.append(f'<div class="fgl">{label}</div>')
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="fpair">')
                for it in pair:
                    badge = ""
                    if it["provider_status"] == "live":
                        badge = '<span class="fbadge tg">target</span>'
                    elif it["provider_status"] == "legacy":
                        badge = '<span class="fbadge bl">base</span>'
                    elif it["provider_status"] == "transitional":
                        badge = '<span class="fbadge tr">trans</span>'
                    lines.append(
                        f'  <div class="frow"><span class="fname">{h(it["name"])}</span>{badge}</div>'
                    )
                lines.append('</div>')
            else:
                it = pair[0]
                badge = ""
                if it["provider_status"] == "live":
                    badge = '<span class="fbadge tg">target</span>'
                elif it["provider_status"] == "legacy":
                    badge = '<span class="fbadge bl">base</span>'
                lines.append(
                    f'<div class="frow"><span class="fname">{h(it["name"])}</span>{badge}</div>'
                )
    content = "\n          ".join(lines)

    return f"""
        <div class="wrap">
        <div class="vw-grid vw-rev reveal">
          <div class="vw-body">
            <div class="kick">Vista · Sistemas</div>
            <h2 class="vw-h2 vwc-s">Habilitadores del Proceso</h2>
            <p class="vw-desc">Vista de los habilitadores tecnológicos que ejecutan el producto end-to-end. Cada sistema tiene su propio SDLC dado que son tecnologías distintas. Esta vista permite identificar y gobernar los planes individuales de entrega por stack — SmartVista, Apolo, canales digitales, integración — y los alimenta al gobierno de la Vista de Producto.</p>
          </div>
          <div class="vw-cube-wrap">
            {(f'<img src="{cube_img}" alt="Sistemas" class="vw-cube-img">' if cube_img else _static_cube("s", front=cube_front_content))}
          </div>
        </div>
        </div>"""


def render_view_capacidades(cube_right_content="", cube_img=None):
    """Sección Vista Capacidades IT: cubo izquierda orientado a cara derecha (verde), contenido derecha."""
    lines = []
    for group, items in IT_CAPS.items():
        lines.append(f'<div class="fgl">{group}</div>')
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="fpair">')
                for it in pair:
                    lines.append(f'  <div class="frow"><span class="fname">{h(it)}</span></div>')
                lines.append('</div>')
            else:
                lines.append(f'<div class="frow"><span class="fname">{h(pair[0])}</span></div>')
    content = "\n          ".join(lines)

    return f"""
        <div class="wrap">
        <div class="vw-grid reveal">
          <div class="vw-cube-wrap">
            {(f'<img src="{cube_img}" alt="Capacidades IT" class="vw-cube-img">' if cube_img else _static_cube("c", right=cube_right_content))}
          </div>
          <div class="vw-body">
            <div class="kick">Vista · Capacidades IT</div>
            <h2 class="vw-h2 vwc-c">Capacidades Transversales de TI</h2>
            <p class="vw-desc">Capacidades institucionales del banco — no exclusivas de este proyecto. Proveen servicios de implementación y operación a cualquier iniciativa, midiendo su capacidad y madurez de entrega. Gestionan la demanda, los proveedores y la evolución del SDLC, estableciendo las bases fundacionales de operación y resiliencia operativa que soportan a la Vista de Sistemas y la Vista de Producto.</p>
          </div>
        </div>
        </div>"""


def render_cube_productos(products, releases):
    lines = []
    rel_by_product = {}
    for r in releases:
        rel_by_product.setdefault(r["product_id"], []).append(r)

    for prod in products:
        prod_lines = []
        for rel in rel_by_product.get(prod["id"], []):
            if rel["status"] in EXCLUDED_STATUSES:
                continue
            hl = ' hl' if rel["status"] == "building" else ""
            scope = rel["scope"] or ""
            scope_line = f'<div class="pcs">{h(scope)}</div>' if scope else ""
            prod_lines.append(
                f'<div class="pcard{hl}">'
                f'<div class="pcn">{h(rel["release_label"])} {badge_status(rel["status"])}</div>'
                f'{scope_line}'
                f'</div>'
            )
        if prod_lines:
            lines.append(f'<div class="cf-gl">{h(prod["name"])}</div>')
            lines.extend(prod_lines)

    if not lines:
        lines.append('<div class="cf-gl">Sin datos en brain.db</div>')
    return "\n            ".join(lines)


def render_cube_sistemas(components):
    groups = {"channel": ("Channels", []), "core": ("Core", []),
              "enabler": ("Processors", []), "transversal": ("Data, Integration", [])}
    order  = ["channel", "core", "enabler", "transversal"]

    for c in components:
        t = c["type"] if c["type"] in groups else "transversal"
        groups[t][1].append(c)

    lines = []
    for key in order:
        label, items = groups[key]
        if not items:
            continue
        lines.append(f'<div class="cf-gl">{label}</div>')
        # pares de items
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="cfc-pair">')
                for it in pair:
                    badge = ""
                    if it["provider_status"] == "live":
                        badge = '<span class="cfbadge b-tg">target</span>'
                    elif it["provider_status"] == "legacy":
                        badge = '<span class="cfbadge b-bl">base</span>'
                    elif it["provider_status"] == "transitional":
                        badge = '<span class="cfbadge b-tr">trans</span>'
                    lines.append(
                        f'  <div class="cfc"><span class="cfcn">{h(it["name"])}</span>{badge}</div>'
                    )
                lines.append('</div>')
            else:
                it = pair[0]
                lines.append(
                    f'<div class="cfc"><span class="cfcn">{h(it["name"])}</span></div>'
                )
    return "\n            ".join(lines)


def render_cube_capacidades():
    lines = []
    for group, items in IT_CAPS.items():
        lines.append(f'<div class="cf-gl">{group}</div>')
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="cfc-pair">')
                for it in pair:
                    lines.append(f'  <div class="cfc"><span class="cfcn">{h(it)}</span></div>')
                lines.append('</div>')
            else:
                lines.append(f'<div class="cfc"><span class="cfcn">{h(pair[0])}</span></div>')
    return "\n            ".join(lines)


def render_rag(track_rags):
    lines = []
    for tr in track_rags:
        color   = tr["rag_color"] or "yellow"
        css     = rag_css(color)
        dot     = rag_dot(color)
        label   = {"red":"Rojo, bloqueado","yellow":"Amarillo","green":"Verde"}.get(color, color)
        summary = h(tr["rag_general"] or "")
        reasons = []
        if tr["tipo_solucion_detail"]:
            reasons.append(f'<b>Tipo de solución.</b> {h(tr["tipo_solucion_detail"])}')
        if tr["impacto_solucion_detail"]:
            reasons.append(f'<b>Impacto.</b> {h(tr["impacto_solucion_detail"])}')
        if tr["complejidad_detail"]:
            reasons.append(f'<b>Complejidad.</b> {h(tr["complejidad_detail"])}')
        if tr["rag_integraciones"]:
            reasons.append(f'<b>Integraciones.</b> {h(tr["rag_integraciones"])}')

        bullets = "".join(f'<li>{r}</li>' for r in reasons)
        rag_why = f'<ul class="rag-why">{bullets}</ul>' if bullets else ""

        lines.append(f"""
        <div class="rag-card {css}">
          <div class="rag-dot">{dot}</div>
          <div class="rag-name">{h(tr["track"].upper() if tr["track"] else "")}</div>
          <div class="rag-sub">{summary}</div>
          {rag_why}
          <div class="rag-label {css}">{label}</div>
        </div>""")
    return "".join(lines)


def render_risks(risks):
    lines = []
    for r in risks:
        med_cls  = risk_severity_css(r["impact"], r["probability"])
        comp     = h(r["component_name"] or r["component_id"] or "")
        prob_lbl = {"high":"Alta","medium":"Media","low":"Baja"}.get(r["probability"],"")
        imp_lbl  = {"critical":"Impacto Crítico","high":"Impacto Alto","medium":"Impacto Medio","low":"Impacto Bajo"}.get(r["impact"],"")
        kick     = f'{h(r["raid_id"])}, {prob_lbl} e {imp_lbl}, {comp}'.strip(", ")
        desc     = h(r["description"])
        mitigation = f' <b>{h(r["mitigation"])}</b>' if r["mitigation"] else ""
        due = f' <b>Fecha objetivo {h(r["due_date"])}.</b>' if r["due_date"] else ""

        lines.append(f"""
      <div class="rcard {med_cls} glass">
        <div class="rkick">{kick}</div>
        <div class="rtitle">{desc}</div>
        <div class="rdesc">{h(r["notes"] or "")}{mitigation}{due}</div>
      </div>""")
    return "".join(lines)


def render_milestones(milestones):
    lines = []
    for m in milestones:
        risk_cls = ' risk' if m["status"] == "at_risk" else ""
        tag      = milestone_tag(m["status"])
        note     = f'<p>{h(m["notes"])}</p>' if m["notes"] else ""
        date_str = h(m["target_date"] or "")
        lines.append(f"""
        <div class="node{risk_cls}">
          <h4>{h(m["name"])}</h4>
          <div class="ndate">{date_str}</div>
          {note}
          {tag}
        </div>""")
    return "".join(lines)


def render_dt_groups():
    lines = []
    for group in DT_GROUPS:
        lines.append(f"""
    <div class="dt-group reveal">
      <div class="dt-group-label">{h(group["label"])}</div>
      <div class="dt-grid">""")
        for dt in group["twins"]:
            border = ""
            if dt.get("crit"):  border = " crit"
            elif dt.get("warn"): border = " warn"
            link_cls = " link" if dt.get("link") else ""
            onclick  = f' onclick="window.location=\'{dt["link"]}\'"' if dt.get("link") else ""
            chips    = "".join(
                f'<span class="chip {c}">{h(t)}</span>'
                for c, t in dt.get("chips", [])
            )
            go = f'<div class="dt-go">Abrir portal <span class="arr">→</span></div>' if dt.get("link") else ""
            lines.append(f"""
        <div class="dtcard glass{border}{link_cls}"{onclick}>
          <div class="dt-top">
            <div class="dt-ico">{dt["ico"]}</div>
            <span class="dt-ver">{h(dt["ver"])}</span>
          </div>
          <div class="dt-name">{h(dt["name"])}</div>
          <div class="dt-desc">{h(dt["desc"])}</div>
          <div class="dt-chips">{chips}</div>
          {go}
        </div>""")
        lines.append("\n      </div>\n    </div>")
    return "".join(lines)


# ── Template principal ────────────────────────────────────────────────────────

def capture_cube_screenshots(html_path, img_dir):
    """Abre el HTML con Playwright, rota el cubo a cada orientación canónica y guarda PNGs."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("[build-portal] playwright no instalado — cubos CSS como fallback")
        print("               pip install playwright && playwright install chromium")
        return {}

    img_dir.mkdir(parents=True, exist_ok=True)
    imgs = {}

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": 1400, "height": 900})
        page.goto(html_path.resolve().as_uri())
        page.wait_for_timeout(900)  # aurora + fonts + primer frame

        # Detener el loop requestAnimationFrame para que no sobreescriba el transform
        page.evaluate("window.requestAnimationFrame = function() { return 0; };")
        page.wait_for_timeout(100)

        for name, transform in CUBE_ORIENTATIONS:
            page.evaluate(f"""
                var c = document.getElementById('cube3d');
                c.style.setProperty('transform', '{transform}', 'important');
                c.style.setProperty('transition', 'none', 'important');
            """)
            page.wait_for_timeout(200)
            out = img_dir / f"cube-{name}.png"
            page.query_selector('#scene3d').screenshot(path=str(out))
            imgs[name] = f"img/cube-{name}.png"
            print(f"[build-portal]   screenshot cube-{name}.png ✓")

        browser.close()

    return imgs


def render(data, cube_imgs=None):
    days   = days_to_golive()
    hus    = data["total_hus"] or 79
    risks_n = data["high_risks"] or 9

    cube_imgs  = cube_imgs or {}
    cube_prod  = render_cube_productos(data["products"], data["releases"])
    cube_sis   = render_cube_sistemas(data["components"])
    cube_cap   = render_cube_capacidades()
    view_prod  = render_view_productos(data["products"], data["releases"], cube_prod,
                                       cube_img=cube_imgs.get("productos"))
    view_sis   = render_view_sistemas(data["components"], cube_sis,
                                      cube_img=cube_imgs.get("sistemas"))
    view_cap   = render_view_capacidades(cube_cap,
                                         cube_img=cube_imgs.get("capacidades"))
    rag_html   = render_rag(data["track_rags"])
    risk_html  = render_risks(data["risks"])
    mile_html  = render_milestones(data["milestones"])
    dt_html    = render_dt_groups()
    generated  = datetime.now().strftime("%Y-%m-%d %H:%M")

    return f"""<!DOCTYPE html>
<!-- Unity R4 — Plan Director · Portal de Programa · BanCoppel
     SPE-AM-001 · Generado por generators/build-portal.py · {generated} -->
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Unity R4 — Plan Director — BanCoppel</title>
<style>
/* ─── Reset y tokens ─── */
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
  --red:#E8400A;--green:#22c55e}}
html{{scroll-behavior:smooth}}
body{{background:#060a1a;color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
.aurora::before,.aurora::after,.aurora .blob{{content:"";position:absolute;border-radius:50%;filter:blur(90px)}}
.aurora::before{{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(27,63,208,.65),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(13,33,133,.7),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(240,210,36,.22),transparent 70%);animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
#prog{{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;
  background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}}
nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:14px 30px;
  backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);
  background:rgba(6,10,26,.55);border-bottom:1px solid rgba(255,255,255,.06)}}
nav img{{height:20px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
nav .nt{{font-size:12px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
nav .sp{{flex:1}}
nav a.jump{{font-size:12px;color:var(--muted);padding:6px 12px;border-radius:20px;transition:.22s;text-decoration:none}}
nav a.jump:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
nav a.jump.ext{{color:var(--yellow)}}
nav a.jump.ext:hover{{color:#fff}}
@media(max-width:700px){{nav .nt,.nav-links{{display:none}}}}
.glass{{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);
  border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}}
.wrap{{max-width:1200px;margin:0 auto;padding:0 30px}}
section{{padding:72px 0;scroll-margin-top:70px}}
#view-productos,#view-sistemas,#view-capacidades{{padding:44px 0}}
.hero{{min-height:100vh;display:grid;grid-template-columns:1fr 1fr;gap:40px;align-items:center;padding:110px 0 60px}}
@media(max-width:900px){{.hero{{grid-template-columns:1fr;min-height:auto;padding-top:90px}}}}
.eyebrow{{display:inline-flex;align-items:center;gap:9px;padding:8px 16px;border-radius:30px;
  font-size:12px;font-weight:600;letter-spacing:.03em;color:#dfe6ff;margin-bottom:24px;
  background:rgba(255,255,255,.05);border:1px solid var(--glassb);
  backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}}
.eyebrow .dot{{width:7px;height:7px;border-radius:50%;background:var(--yellow);
  box-shadow:0 0 12px var(--yellow);animation:pulse 2.4s infinite}}
@keyframes pulse{{50%{{opacity:.4}}}}
.hero h1{{font-size:clamp(40px,5.5vw,72px);font-weight:800;line-height:1.0;letter-spacing:-.035em;
  background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.hero .sub{{font-size:16px;color:var(--muted);margin-top:18px;max-width:50ch;line-height:1.6}}
.hero .sub b{{color:#e4eaff;font-weight:600}}
.countdown{{display:inline-flex;flex-direction:column;align-items:center;padding:20px 36px;
  border-radius:18px;margin-top:28px;gap:4px}}
.cdays{{font-size:48px;font-weight:900;letter-spacing:-.04em;
  background:linear-gradient(170deg,#fff 40%,var(--yellow));-webkit-background-clip:text;background-clip:text;color:transparent;
  font-variant-numeric:tabular-nums}}
.clabel{{font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2)}}
.hero-cube-zone{{display:flex;flex-direction:column;align-items:center;gap:18px;position:relative}}
.cube-hint{{font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);font-weight:600}}
.scene3d{{width:380px;height:380px;perspective:840px;cursor:grab;user-select:none}}
.scene3d:active{{cursor:grabbing}}
.cube3d{{width:280px;height:280px;position:relative;transform-style:preserve-3d;
  transform:rotateX(-30deg) rotateY(-30deg);
  transition:transform .65s cubic-bezier(.25,.46,.45,.94);margin:50px auto}}
.cube3d.dragging{{transition:none}}
.cf{{position:absolute;width:280px;height:280px;border:1px solid rgba(255,255,255,.18);
  overflow-y:auto;padding:8px;border-radius:4px}}
.cf::-webkit-scrollbar{{width:3px}}
.cf::-webkit-scrollbar-thumb{{background:rgba(255,255,255,.25);border-radius:2px}}
.cf-top   {{transform:rotateX(90deg) translateZ(140px);background:linear-gradient(135deg,#AB47BC,#4A148C)}}
.cf-front {{transform:translateZ(140px);background:linear-gradient(135deg,#1976D2,#0D47A1)}}
.cf-right {{transform:rotateY(90deg) translateZ(140px);background:linear-gradient(135deg,#43A047,#1B5E20)}}
.cf-back  {{transform:translateZ(-140px) rotateY(180deg);background:linear-gradient(135deg,#1a237e,#0d1421)}}
.cf-left  {{transform:rotateY(-90deg) translateZ(140px);background:linear-gradient(135deg,#AB47BC,#4A148C)}}
.cf-bot   {{transform:rotateX(-90deg) translateZ(140px);background:linear-gradient(135deg,#1a237e,#0d1421)}}
.cf-title{{font-size:9px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#fff;
  margin-bottom:9px;padding-bottom:5px;border-bottom:1px solid rgba(255,255,255,.22)}}
.cf-gl{{font-size:7px;font-weight:600;letter-spacing:2px;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-top:8px;margin-bottom:3px}}
.cfc{{background:rgba(255,255,255,.11);border:1px solid rgba(255,255,255,.14);border-radius:4px;
  padding:2px 6px;margin-bottom:2px;display:flex;align-items:center;justify-content:flex-start;
  gap:5px;min-height:18px}}
.cfcn{{font-size:10px;color:rgba(255,255,255,.9);font-weight:500;flex:1}}
.cfbadge{{font-size:7.5px;font-weight:700;padding:1px 4px;border-radius:6px;white-space:nowrap;flex-shrink:0}}
.b-bl{{background:rgba(21,101,192,.65);color:#90CAF9}}
.b-tg{{background:rgba(46,125,50,.65);color:#A5D6A7}}
.b-vc{{background:rgba(183,28,28,.55);color:#EF9A9A}}
.b-tr{{background:rgba(245,124,0,.55);color:#FFCC80}}
.pcard{{background:rgba(255,255,255,.10);border:1px solid rgba(255,255,255,.16);border-radius:5px;padding:6px 9px;margin-bottom:4px}}
.pcard.hl{{background:rgba(255,255,255,.20);border-color:rgba(255,255,255,.50)}}
.pcn{{font-size:9.5px;font-weight:700;color:#fff;display:flex;align-items:center;justify-content:flex-start;gap:5px;line-height:1}}
.pcs{{font-size:8.5px;color:rgba(255,255,255,.65);line-height:1.3;margin-top:3px}}
.cfc-pair{{display:flex;gap:3px;margin-bottom:3px}}
.cfc-pair .cfc{{flex:1;margin-bottom:0}}
.vw-grid{{display:grid;grid-template-columns:260px 1fr;gap:36px;align-items:start}}
.vw-rev{{grid-template-columns:1fr 260px}}
.vw-rev .vw-cube-wrap{{order:2}}
.vw-rev .vw-body{{order:1}}
@media(max-width:900px){{.vw-grid{{grid-template-columns:1fr}}.vw-rev .vw-cube-wrap,.vw-rev .vw-body{{order:unset}}}}
.vw-scene{{width:260px;height:260px;perspective:600px;margin:0 auto}}
.vw-cube-img{{width:100%;max-width:380px;border-radius:16px;box-shadow:0 12px 48px rgba(0,0,0,.55);display:block;margin:0 auto}}
.vw-static{{width:220px;height:220px;position:relative;transform-style:preserve-3d;margin:20px auto;transition:none!important}}
.vw-static-p{{transform:rotateX(-70deg) rotateY(-20deg)!important}}
.vw-static-s{{transform:rotateX(-15deg) rotateY(-5deg)!important}}
.vw-static-c{{transform:rotateX(-15deg) rotateY(-80deg)!important}}
.vw-static .cf{{width:220px;height:220px;font-size:8.5px}}
.vw-static .cf-top{{transform:rotateX(90deg) translateZ(110px)!important}}
.vw-static .cf-front{{transform:translateZ(110px)!important}}
.vw-static .cf-right{{transform:rotateY(90deg) translateZ(110px)!important}}
.vw-static .cf-back{{transform:translateZ(-110px) rotateY(180deg)!important}}
.vw-static .cf-left{{transform:rotateY(-90deg) translateZ(110px)!important}}
.vw-static .cf-bot{{transform:rotateX(-90deg) translateZ(110px)!important}}
.vw-h2{{font-size:clamp(22px,2.8vw,34px);font-weight:800;letter-spacing:-.025em;line-height:1.06;margin:14px 0 10px}}
.vwc-p{{color:#CE93D8}}
.vwc-s{{color:#90CAF9}}
.vwc-c{{color:#A5D6A7}}
.vw-desc{{font-size:14px;color:var(--muted);line-height:1.6;max-width:60ch;margin-bottom:14px}}
#view-productos{{border-top:2px solid rgba(171,71,188,.25)}}
#view-sistemas{{border-top:2px solid rgba(25,118,210,.25)}}
#view-capacidades{{border-top:2px solid rgba(67,160,71,.25)}}
.fgl{{font-size:9px;font-weight:700;letter-spacing:.15em;text-transform:uppercase;
  color:rgba(255,255,255,.35);margin:12px 0 6px}}
.frow{{display:flex;align-items:center;justify-content:space-between;gap:8px;
  padding:5px 9px;border-radius:6px;margin-bottom:4px;background:rgba(255,255,255,.055)}}
.fname{{font-size:11px;font-weight:600;color:rgba(255,255,255,.88);flex:1}}
.fpair{{display:flex;gap:6px;margin-bottom:4px}}
.fpair .frow{{flex:1;margin-bottom:0}}
.fbadge{{font-size:8px;font-weight:700;padding:1px 6px;border-radius:8px;white-space:nowrap}}
.fbadge.tg{{background:rgba(46,125,50,.65);color:#A5D6A7}}
.fbadge.bl{{background:rgba(21,101,192,.65);color:#90CAF9}}
.fbadge.tr{{background:rgba(245,124,0,.55);color:#FFCC80}}
.fpcard{{padding:7px 10px;border-radius:8px;margin-bottom:5px;
  background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12)}}
.fpcard.hl{{background:rgba(255,255,255,.15);border-color:rgba(255,255,255,.35)}}
.fpcn{{font-size:11px;font-weight:600;color:#fff;display:flex;align-items:flex-start;justify-content:space-between;gap:8px;flex-wrap:wrap;line-height:1.45}}
.stats{{display:grid;grid-template-columns:repeat(5,1fr);gap:13px;margin-top:0}}
@media(max-width:1000px){{.stats{{grid-template-columns:repeat(3,1fr)}}}}
@media(max-width:600px){{.stats{{grid-template-columns:repeat(2,1fr)}}}}
.stat{{padding:20px 14px;text-align:center}}
.statn{{font-size:clamp(20px,2.5vw,30px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;
  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.statl{{font-size:10px;color:var(--muted2);margin-top:8px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}}
.stat.danger .statn{{background:linear-gradient(180deg,#fca5a5,#ef4444);-webkit-background-clip:text;background-clip:text}}
.stat.warn .statn{{background:linear-gradient(180deg,#fde68a,var(--yellow));-webkit-background-clip:text;background-clip:text}}
.shead{{margin-bottom:36px}}
.kick{{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:14px}}
.shead h2{{font-size:clamp(26px,3.5vw,40px);font-weight:800;letter-spacing:-.025em;line-height:1.06}}
.shead p{{color:var(--muted);font-size:15px;margin-top:12px;max-width:72ch;line-height:1.55}}
.rag-grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(310px,1fr));gap:14px;align-items:start}}
@media(max-width:900px){{.rag-grid{{grid-template-columns:repeat(3,1fr)}}}}
@media(max-width:560px){{.rag-grid{{grid-template-columns:1fr 1fr}}}}
.rag-card{{padding:20px 18px;border-radius:18px;border-left:4px solid transparent}}
.rag-card.r{{border-left-color:#ef4444;background:rgba(239,68,68,.07);border:1px solid rgba(239,68,68,.18);border-left:4px solid #ef4444}}
.rag-card.y{{border-left-color:var(--yellow);background:rgba(240,210,36,.05);border:1px solid rgba(240,210,36,.18);border-left:4px solid var(--yellow)}}
.rag-card.g{{border-left-color:var(--green);background:rgba(34,197,94,.05);border:1px solid rgba(34,197,94,.18);border-left:4px solid var(--green)}}
.rag-dot{{font-size:20px;margin-bottom:8px}}
.rag-name{{font-size:13.5px;font-weight:700;margin-bottom:4px}}
.rag-sub{{font-size:11px;color:var(--muted2);line-height:1.4}}
.rag-why{{list-style:none;margin:12px 0 0;padding:0;display:flex;flex-direction:column;gap:8px}}
.rag-why li{{font-size:10.5px;line-height:1.5;color:var(--muted);padding-left:12px;position:relative}}
.rag-why li::before{{content:"";position:absolute;left:0;top:6px;width:4px;height:4px;border-radius:50%;
  background:currentColor;opacity:.5}}
.rag-why li b{{color:#e4eaff;font-weight:600}}
.rag-card.r .rag-why li::before{{background:#ef4444;opacity:.85}}
.rag-card.y .rag-why li::before{{background:var(--yellow);opacity:.85}}
.rag-label{{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;
  padding:2px 7px;border-radius:8px;margin-top:8px}}
.rag-label.r{{background:rgba(239,68,68,.15);color:#fca5a5;border:1px solid rgba(239,68,68,.3)}}
.rag-label.y{{background:rgba(240,210,36,.1);color:var(--yellow);border:1px solid rgba(240,210,36,.3)}}
.dt-grid{{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}}
@media(max-width:960px){{.dt-grid{{grid-template-columns:repeat(2,1fr)}}}}
@media(max-width:560px){{.dt-grid{{grid-template-columns:1fr}}}}
.dt-group{{margin-bottom:44px}}
.dt-group-label{{font-size:11px;font-weight:700;letter-spacing:.15em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:16px;padding-bottom:8px;border-bottom:1px solid rgba(255,255,255,.07)}}
.dtcard{{display:flex;flex-direction:column;gap:10px;padding:22px;color:inherit;text-decoration:none;
  border-radius:20px;transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s;cursor:default}}
.dtcard.link{{cursor:pointer}}
.dtcard.link:hover{{transform:translateY(-5px);border-color:rgba(240,210,36,.42);box-shadow:0 20px 52px rgba(0,0,0,.5)}}
.dtcard.crit{{border-left:3px solid var(--red)!important}}
.dtcard.warn{{border-left:3px solid var(--yellow)!important}}
.dt-top{{display:flex;align-items:flex-start;justify-content:space-between;gap:8px}}
.dt-ico{{font-size:22px;width:46px;height:46px;display:flex;align-items:center;justify-content:center;
  border-radius:14px;flex-shrink:0;background:linear-gradient(150deg,rgba(255,255,255,.13),rgba(255,255,255,.02));
  border:1px solid rgba(255,255,255,.11)}}
.dt-ver{{font-size:9px;font-weight:700;color:var(--muted2);letter-spacing:.06em;padding:2px 7px;
  border-radius:8px;border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.05);white-space:nowrap}}
.dt-name{{font-size:15px;font-weight:800;letter-spacing:-.01em;margin-top:4px}}
.dt-desc{{font-size:12.5px;color:var(--muted);line-height:1.55;flex:1}}
.dt-chips{{display:flex;flex-wrap:wrap;gap:4px}}
.chip{{display:inline-block;font-size:9.5px;font-weight:700;padding:2px 8px;border-radius:10px;letter-spacing:.04em}}
.chip.blue{{border:1px solid rgba(100,140,255,.35);color:#9db8ff;background:rgba(61,95,205,.15)}}
.chip.yellow{{border:1px solid rgba(240,210,36,.35);color:var(--yellow);background:rgba(240,210,36,.09)}}
.chip.red{{border:1px solid rgba(232,64,10,.35);color:#f87171;background:rgba(232,64,10,.10)}}
.chip.green{{border:1px solid rgba(34,197,94,.35);color:#86efac;background:rgba(34,197,94,.09)}}
.dt-go{{font-size:11px;font-weight:700;color:var(--yellow);display:inline-flex;align-items:center;gap:5px;margin-top:4px}}
.arr{{transition:transform .3s}}.dtcard.link:hover .arr{{transform:translateX(5px)}}
.risk-grid{{display:grid;grid-template-columns:1fr 1fr;gap:14px}}
@media(max-width:760px){{.risk-grid{{grid-template-columns:1fr}}}}
.rcard{{padding:22px 24px;border-left:3px solid var(--red);border-radius:0 14px 14px 0}}
.rcard.med{{border-left-color:var(--yellow)}}
.rkick{{font-size:9.5px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:#f87171;margin-bottom:6px}}
.rcard.med .rkick{{color:var(--yellow)}}
.rtitle{{font-size:15px;font-weight:700;margin-bottom:8px;letter-spacing:-.01em}}
.rdesc{{font-size:12.5px;color:var(--muted);line-height:1.55}}
.rdesc b{{color:#e4eaff}}
.tl{{position:relative;padding-left:36px;max-width:680px}}
.tl::before{{content:"";position:absolute;left:5px;top:8px;bottom:8px;width:2px;
  background:linear-gradient(180deg,var(--yellow),var(--blue) 60%,transparent)}}
.node{{position:relative;padding-bottom:22px}}
.node:last-child{{padding-bottom:0}}
.node::before{{content:"";position:absolute;left:-36px;top:3px;width:12px;height:12px;border-radius:50%;
  background:var(--yellow);border:3px solid #060a1a;box-shadow:0 0 0 2px rgba(240,210,36,.55),0 0 14px rgba(240,210,36,.5)}}
.node.risk::before{{background:var(--red);box-shadow:0 0 0 2px rgba(232,64,10,.55),0 0 14px rgba(232,64,10,.5)}}
.node h4{{font-size:14.5px;font-weight:700;letter-spacing:-.01em}}
.node .ndate{{font-size:11.5px;color:var(--muted2);margin-top:2px}}
.node p{{font-size:12.5px;color:var(--muted);margin-top:5px;line-height:1.5}}
.node .ntag{{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;
  padding:2px 7px;border-radius:8px;margin-top:5px}}
.ntag.ok{{background:rgba(34,197,94,.12);color:#86efac;border:1px solid rgba(34,197,94,.25)}}
.ntag.risk{{background:rgba(239,68,68,.12);color:#fca5a5;border:1px solid rgba(239,68,68,.25)}}
.ntag.pend{{background:rgba(170,179,212,.1);color:var(--muted);border:1px solid rgba(255,255,255,.12)}}
.reveal{{opacity:0;transform:translateY(28px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}}
.reveal.in{{opacity:1;transform:none}}
footer{{padding:40px 30px 60px;text-align:center;color:var(--muted2);font-size:12px;
  border-top:1px solid rgba(255,255,255,.06);margin-top:50px;line-height:1.8}}
footer code{{color:var(--muted);background:rgba(240,210,36,.10);border:1px solid rgba(240,210,36,.25);
  border-radius:5px;padding:1px 6px;font-size:11px;font-family:'SF Mono',ui-monospace,monospace}}
@media(prefers-reduced-motion:reduce){{.reveal{{transition:none;opacity:1;transform:none}}.aurora *{{animation:none}}}}
/* ── Vista Producto — Capabilities, KPIs, Bloqueadores ── */
.vp-section-label{{font-size:9px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:rgba(255,255,255,.35);margin:14px 0 6px}}
.vp-caps{{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}}
@media(max-width:700px){{.vp-caps{{grid-template-columns:repeat(2,1fr)}}}}
.vp-cap{{padding:9px 11px;border-radius:9px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-left:3px solid rgba(255,255,255,.15)}}
.vp-cap.warn{{border-left-color:var(--yellow)}}
.vp-cap.crit{{border-left-color:var(--red)}}
.vp-cap.ok{{border-left-color:var(--green)}}
.vp-caplabel{{font-size:10.5px;font-weight:700;color:#e4eaff;margin-bottom:2px;line-height:1.3}}
.vp-capsys{{font-size:8.5px;color:var(--muted2)}}
.vp-capnote{{font-size:8px;color:var(--muted);margin-top:3px;line-height:1.35}}
.vp-kpis{{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}}
@media(max-width:700px){{.vp-kpis{{grid-template-columns:repeat(2,1fr)}}}}
.vp-kpi{{padding:10px 11px;border-radius:9px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.09);text-align:center}}
.vp-kpi.gap{{background:rgba(255,255,255,.02);border-style:dashed;opacity:.55}}
.vp-kval{{font-size:15px;font-weight:800;letter-spacing:-.02em;color:#fff}}
.vp-kpi.gap .vp-kval{{font-size:11px;color:var(--muted2)}}
.vp-klabel{{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--muted2);margin-top:3px}}
.vp-ksub{{font-size:7.5px;color:var(--muted2);margin-top:1px;opacity:.7}}
.vp-blocks{{display:flex;flex-direction:column;gap:5px}}
.vp-block{{display:flex;align-items:flex-start;gap:10px;padding:8px 10px;border-radius:8px;
  background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);border-left:3px solid rgba(255,255,255,.15)}}
.vp-block.crit{{border-left-color:var(--red)}}
.vp-block.warn{{border-left-color:var(--yellow)}}
.vp-btext{{font-size:11px;font-weight:600;color:#e4eaff;line-height:1.4}}
.vp-bsub{{font-size:8.5px;color:var(--muted2);margin-top:2px}}
</style></head>
<body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div id="prog"></div>

<nav>
  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display='none'">
  <span class="nt">Unity R4 — Plan Director</span>
  <span class="sp"></span>
  <span class="nav-links" style="display:contents">
    <a class="jump" href="#view-productos">Alcance</a>
    <a class="jump" href="#estado">Estado</a>
    <a class="jump" href="#twins">Digital Twins</a>
    <a class="jump" href="#cronograma">Cronograma</a>
    <a class="jump" href="#riesgos">Riesgos</a>
    <a class="jump ext" href="lifecycle-p4900.html">Lifecycle P4900 ↗</a>
    <a class="jump ext" href="apolo-itcaps.html">APOLO IT Caps ↗</a>
    <a class="jump ext" href="duplicidad-informix-unity.html">Duplicidad ↗</a>
    <a class="jump ext" href="plan-director.html">Plan Director ↗</a>
  </span>
</nav>

<div class="wrap">

  <header class="hero">
    <div>
      <div class="eyebrow reveal">
        <span class="dot"></span>&nbsp; SPE-AM-001, Unity R4, BUILD, ago 2026
      </div>
      <h1 class="reveal">Plan Director<br>Unity R4</h1>
      <p class="sub reveal">
        Programa de modernización del core bancario BanCoppel.<br>
        <b>Tarjeta de Crédito — Producto P4900.</b><br>
        SmartVista BPC, APOLO, Temenos Transact.
      </p>
      <div class="countdown glass reveal">
        <div class="cdays" id="cdays">{days}</div>
        <div class="clabel">días al Go-Live — 15 enero 2027</div>
      </div>
    </div>

    <div class="hero-cube-zone reveal">
      <div class="cube-hint">Marco de referencia 3D — Arrastra para explorar</div>
      <div class="scene3d" id="scene3d">
        <div class="cube3d" id="cube3d">
          <div class="cf cf-top">
            <div class="cf-title">Productos</div>
            {cube_prod}
          </div>
          <div class="cf cf-front">
            <div class="cf-title">Sistemas</div>
            {cube_sis}
          </div>
          <div class="cf cf-right">
            <div class="cf-title">Capacidades IT</div>
            {cube_cap}
          </div>
          <div class="cf cf-back"><div class="cf-title">Unity R4</div></div>
          <div class="cf cf-left"></div>
          <div class="cf cf-bot"></div>
        </div>
      </div>
    </div>
  </header>

  <section id="view-productos">
    {view_prod}
  </section>

  <section id="view-sistemas">
    {view_sis}
  </section>

  <section id="view-capacidades">
    {view_cap}
  </section>

  <section id="estado">
    <div class="stats reveal">
      <div class="stat glass">
        <div class="statn" id="s-days">{days}</div>
        <div class="statl">Días al Go-Live</div>
      </div>
      <div class="stat glass warn">
        <div class="statn">21.19%</div>
        <div class="statl">Avance R4 TDC, 60.58% esperado al 17-ago</div>
      </div>
      <div class="stat glass">
        <div class="statn" data-target="{hus}">0</div>
        <div class="statl">User Stories, 46 Must</div>
      </div>
      <div class="stat glass danger">
        <div class="statn" data-target="{risks_n}">0</div>
        <div class="statl">Riesgos Alta Prioridad</div>
      </div>
      <div class="stat glass danger">
        <div class="statn" data-target="10">0</div>
        <div class="statl">Decisiones pendientes del Design Authority</div>
      </div>
    </div>

    <div style="margin-top:52px">
      <div class="shead reveal">
        <div class="kick">Semáforo del Programa</div>
        <h2>Estado por Track</h2>
        <p>Fuente: Roadmap Accenture 11-ago-2026 y Plan de Trabajo con corte 17-ago-2026</p>
      </div>
      <div class="rag-grid reveal">
        {rag_html}
      </div>
    </div>
  </section>

  <section id="twins">
    <div class="shead reveal">
      <div class="kick">Gemelos Digitales</div>
      <h2>Plan Director — 14 Digital Twins</h2>
      <p>Cobertura end-to-end del programa Unity R4 — desde gobernanza hasta operaciones.</p>
    </div>
    {dt_html}
  </section>

  <section id="riesgos">
    <div class="shead reveal">
      <div class="kick">Registro de Riesgos</div>
      <h2>Riesgos de Alta Prioridad</h2>
      <p>9 riesgos de probabilidad alta, RAID v2.0 con corte 03-ago-2026, responsable Ma. Fernanda Barbosa</p>
    </div>
    <div class="risk-grid reveal">
      {risk_html}
    </div>
  </section>

  <section id="cronograma">
    <div class="shead reveal">
      <div class="kick">Hitos R4</div>
      <h2>Cronograma al Go-Live</h2>
      <p>Fechas clave, Inicio SIT octubre, Code Freeze diciembre, Go-Live 15-ene-2027</p>
    </div>
    <div class="reveal">
      <div class="tl">
        {mile_html}
      </div>
    </div>
  </section>

</div>

<footer>
  <code>Unity R4, Plan Director, SPE-AM-001</code>, BanCoppel, Accenture México<br>
  Generado desde brain.db el {generated} · Gemelo Cognitivo — Capa Estratégica
</footer>

<script>
  document.querySelectorAll('nav a.jump[href^="#"]').forEach(a=>{{
    a.addEventListener('click',e=>{{
      e.preventDefault();
      const el=document.querySelector(a.getAttribute('href'));
      if(el)el.scrollIntoView({{behavior:'smooth'}});
    }});
  }});
  window.addEventListener('scroll',()=>{{
    const p=(window.scrollY/(document.body.scrollHeight-window.innerHeight))*100;
    document.getElementById('prog').style.width=p+'%';
  }});
  (function(){{
    const goLive=new Date('2027-01-15');
    const today=new Date();today.setHours(0,0,0,0);
    const days=Math.ceil((goLive-today)/(1000*60*60*24));
    ['cdays','s-days'].forEach(id=>{{const el=document.getElementById(id);if(el)el.textContent=days;}});
  }})();
  function animateCounter(el){{
    const target=parseInt(el.getAttribute('data-target'));
    if(!target)return;
    let start=0;const duration=1200;const step=target/duration*16;
    const tick=()=>{{start=Math.min(start+step,target);el.textContent=Math.round(start);if(start<target)requestAnimationFrame(tick);}};
    requestAnimationFrame(tick);
  }}
  const ro=new IntersectionObserver(entries=>{{
    entries.forEach(e=>{{
      if(e.isIntersecting){{
        e.target.classList.add('in');
        if(e.target.classList.contains('stats'))
          e.target.querySelectorAll('[data-target]').forEach(animateCounter);
      }}
    }});
  }},{{threshold:.12}});
  document.querySelectorAll('.reveal').forEach(el=>ro.observe(el));

  const cube=document.getElementById('cube3d');
  const scene=document.getElementById('scene3d');
  let rotX=-30,rotY=-30,isDragging=false,startX=0,startY=0;
  let isAuto=true,lastT=0,autoDir=1;
  function clamp(){{rotX=Math.max(-90,Math.min(5,rotX));rotY=Math.max(-90,Math.min(5,rotY));}}
  function apply(){{cube.style.transform=`rotateX(${{rotX}}deg) rotateY(${{rotY}}deg)`;}}
  (function loop(now){{
    if(isAuto&&!isDragging){{
      const dt=Math.min((now-lastT)/1000,.05);
      rotY+=dt*12*autoDir;
      if(rotY>5){{rotY=5;autoDir=-1;}}
      if(rotY<-90){{rotY=-90;autoDir=1;}}
      apply();
    }}
    lastT=now;requestAnimationFrame(loop);
  }})(0);
  scene.addEventListener('mouseenter',()=>{{isAuto=false;}});
  scene.addEventListener('mouseleave',()=>{{if(!isDragging)isAuto=true;}});
  scene.addEventListener('mousedown',e=>{{
    isDragging=true;startX=e.clientX;startY=e.clientY;
    cube.classList.add('dragging');isAuto=false;
  }});
  window.addEventListener('mousemove',e=>{{
    if(!isDragging)return;
    rotY+=(e.clientX-startX)*.4;rotX-=(e.clientY-startY)*.4;
    clamp();startX=e.clientX;startY=e.clientY;apply();
  }});
  window.addEventListener('mouseup',()=>{{isDragging=false;cube.classList.remove('dragging');}});
  let tx=0,ty=0;
  scene.addEventListener('touchstart',e=>{{e.preventDefault();tx=e.touches[0].clientX;ty=e.touches[0].clientY;cube.classList.add('dragging');isAuto=false;}},{{passive:false}});
  scene.addEventListener('touchmove',e=>{{
    e.preventDefault();
    rotY+=(e.touches[0].clientX-tx)*.4;rotX-=(e.touches[0].clientY-ty)*.4;
    clamp();tx=e.touches[0].clientX;ty=e.touches[0].clientY;apply();
  }},{{passive:false}});
  scene.addEventListener('touchend',()=>cube.classList.remove('dragging'));
</script>
</body></html>
"""


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Genera portal/index.html desde brain.db")
    parser.add_argument("--brain", default=str(BRAIN), help="Ruta al brain.db")
    parser.add_argument("--out",   default=str(OUTPUT), help="Ruta de salida del HTML")
    args = parser.parse_args()

    brain_path = Path(args.brain)
    out_path   = Path(args.out)

    if not brain_path.exists():
        print(f"[ERROR] brain.db no encontrado: {brain_path}")
        raise SystemExit(1)

    print(f"[build-portal] Leyendo {brain_path} ...")
    data = load_data(str(brain_path))

    print(f"[build-portal] Generando {out_path} ...")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Pasada 1 — HTML con cubos CSS (necesario para que Playwright lo abra)
    out_path.write_text(render(data), encoding="utf-8")

    # Pasada 2 — Screenshots con Playwright → reemplaza cubos CSS por imágenes
    img_dir = out_path.parent / "img"
    cube_imgs = capture_cube_screenshots(out_path, img_dir)
    if cube_imgs:
        out_path.write_text(render(data, cube_imgs=cube_imgs), encoding="utf-8")
        print(f"[build-portal] Screenshots embebidos ✓")

    print(f"[build-portal] OK — {out_path}")
    print(f"  Productos : {len(data['products'])} | Releases: {len(data['releases'])}")
    print(f"  Sistemas  : {len(data['components'])}")
    print(f"  RAG tracks: {len(data['track_rags'])}")
    print(f"  Riesgos   : {len(data['risks'])}")
    print(f"  Hitos     : {len(data['milestones'])}")
    print(f"  Días al Go-Live: {days_to_golive()}")


if __name__ == "__main__":
    main()

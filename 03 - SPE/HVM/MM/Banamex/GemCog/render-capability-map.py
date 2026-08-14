#!/usr/bin/env python3
"""
render-capability-map.py
Regenera el bloque de tiles de portal/modelo-capacidades.html desde los MDs.
Fuentes: capability-map.md (estructura) + capacidades/cap-*.md (conteo tareas).
Preserva: CSS, JS, DOMDATA, header, footer — look & feel intacto.
Correcciones:
  - Holdings 4.1.2: s500 → s151 (bug: Sistema incorrecto)
  - CFR T.4.1: añade tile en Transversal (capacidad faltante)
  - KPI: 20/104 → 21/104  |  19% → 20.2%
"""
import re, os

BASE      = os.path.dirname(os.path.abspath(__file__))
CAPS_DIR  = os.path.join(BASE, "capacidades")
HTML_PATH = os.path.join(BASE, "portal", "modelo-capacidades.html")

# ── Metadata por capacidad cubierta ─────────────────────────────────────────
# cls/did/b/r/s: valores del tile (preservados del HTML original, corregidos donde aplica)
# n: data-n (tooltip), dom: data-dom (HTML-encoded), cn: texto visible en tile
# cap_file: archivo cap-*.md donde contar tareas
# task_slug: prefijo T-SLUG-NNN a buscar en cap_file
# count: True = contar del MD  |  False = usar EXISTING_J (merged caps / archivos compartidos)
CAP_META = {
    "2.1.1":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Teller",
                   dom="S500 &middot; Procesamiento Core",
                   cn="Teller",
                   cap_file="cap-tel.md", task_slug="TEL", count=True),
    "2.2.6":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="ATM",
                   dom="S500 &middot; Procesamiento Core",
                   cn="ATM",
                   cap_file="cap-tar.md", task_slug="TAR", count=True),
    "2.2.7":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="PoS",
                   dom="S500 &middot; Procesamiento Core",
                   cn="PoS",
                   # comparte archivo con ATM; T-TAR cuenta ambos → usar j existente
                   cap_file="cap-tar.md", task_slug="TAR", count=False),
    "4.1.2":  dict(cls="s151", did="s151",  b="S151",  r="444992",  s="104",
                   n="Holdings",
                   dom="S151 &middot; Saldos &amp; Holdings",
                   cn="Holdings",
                   cap_file="cap-hld.md", task_slug="HLD", count=True),
    "5.1.1":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Deposits",
                   dom="S500 &middot; Cuentas de Cheque",
                   cn="Deposits",
                   cap_file="cap-dep.md", task_slug="DEP", count=True),
    "6.1.3":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Payments",
                   dom="S500 &middot; Cargos &amp; Abonos",
                   cn="Payments",
                   cap_file="cap-pay.md", task_slug="PAY", count=True),
    "6.1.4":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Statements",
                   dom="S500 &middot; Saldos &amp; Cuentas",
                   cn="Statements",
                   cap_file="cap-sta.md", task_slug="STA", count=True),
    "6.1.5":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Interest &amp; Fees",
                   dom="S500 &middot; Intereses &amp; Comisiones",
                   cn="Interest &amp; Fees",
                   cap_file="cap-int.md", task_slug="INT", count=True),
    "6.5.2":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Compliance &amp; Regulation",
                   dom="S500+S151 &middot; CNBV",
                   cn="Compliance &amp; Regulation",
                   cap_file="cap-cmp.md", task_slug="CMP", count=True),
    "6.6.1":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Financial Servicing",
                   dom="S500 &middot; Servicio de Cuenta",
                   cn="Financial Servicing",
                   # FSV mergeado en cap-int.md; usar j existente
                   cap_file="cap-int.md", task_slug="FSV", count=False),
    "6.7.1":  dict(cls="s151", did="s151",  b="S151",  r="444992",  s="104",
                   n="Financial Reconciliation",
                   dom="S151 &middot; Conciliaci&oacute;n GL",
                   cn="Financial Reconciliation",
                   cap_file="cap-rec.md", task_slug="REC", count=True),
    "6.7.2":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Operational Reconciliation",
                   dom="S500+S151 &middot; Cuadre Operativo-Contable",
                   cn="Operational Reconciliation",
                   cap_file="cap-orc.md", task_slug="ORC", count=True),
    "7.1.1":  dict(cls="s151", did="s151",  b="S151",  r="444992",  s="104",
                   n="Finance (GL)",
                   dom="S151 &middot; Libro Mayor General",
                   cn="Finance",
                   cap_file="cap-gl.md", task_slug="GL", count=True),
    "8.1.1":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Scheduling (WFL)",
                   dom="S500+S151 &middot; Batch Scheduler MCP",
                   cn="Scheduling",
                   cap_file="cap-sch.md", task_slug="SCH", count=True),
    "9.1.1":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Operational Data Stores (DMSII)",
                   dom="S500+S151 &middot; DMSII Bases de Datos",
                   cn="Operational Data Stores",
                   cap_file="cap-ods.md", task_slug="ODS", count=True),
    "10.1.1": dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Access Control",
                   dom="S500 &middot; Control de Acceso",
                   cn="Access Control",
                   # ACC mergeado en cap-sec.md; usar j existente
                   cap_file="cap-sec.md", task_slug="ACC", count=False),
    "T.1.3":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="Payment Schemes (SPEI/CLABE)",
                   dom="S500 &middot; SPEI &amp; Banxico",
                   cn="Payment Schemes",
                   # SPI mergeado en cap-pay.md; usar j existente
                   cap_file="cap-pay.md", task_slug="SPI", count=False),
    "T.2.3":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="MQ / Async (L091-L093)",
                   dom="S500 &middot; As&iacute;ncrona MCP",
                   cn="MQ / Async",
                   cap_file="cap-mq.md", task_slug="MQ", count=True),
    "T.3.4":  dict(cls="s151", did="s151",  b="S151",  r="444992",  s="104",
                   n="Analytics / Reporting",
                   dom="S151 &middot; Reportes Contables",
                   cn="Analytics / Reporting",
                   cap_file="cap-rpt.md", task_slug="RPT", count=True),
    "T.3.5":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Security",
                   dom="S500+S151 &middot; Seguridad MCP",
                   cn="Security",
                   cap_file="cap-sec.md", task_slug="SEC", count=True),
    "T.4.1":  dict(cls="s151", did="s151",  b="S151",  r="444992",  s="104",
                   n="CFR Regulatory Reporting Pipeline",
                   dom="S151 &middot; CFR Regulatorio CNBV",
                   cn="CFR Reporting",
                   cap_file="cap-cfr.md", task_slug="CFR", count=True),
    "T.5.1":  dict(cls="ambos", did="ambos", b="AMBOS", r="1343588", s="218",
                   n="Batch Orchestration (WFL)",
                   dom="S500+S151 &middot; Orquestador Batch MCP",
                   cn="Batch Orch.",
                   cap_file="cap-wfl.md", task_slug="WFL", count=True),
    "T.6.1":  dict(cls="s500", did="s500",  b="S500",  r="898596",  s="114",
                   n="CPE Captación Productiva Especial",
                   dom="S500 &middot; CPE Mensual RMENSUALCPE",
                   cn="CPE",
                   cap_file="cap-cpe.md", task_slug="CPE", count=True),
}

# j fallback para capacidades con count=False (valores del HTML original)
EXISTING_J = {
    "2.2.7": 22, "6.6.1": 38, "10.1.1": 8, "T.1.3": 28,
}

# ── Estructura de dominios y subgrupos (capability-model-taxonomy.md) ────────
STRUCTURE = [
    {"title": "1 &middot; Ecosystem Management", "groups": [
        {"label": "Ecosystem Partner Management", "caps": [
            ("1.1.1","Onboarding"), ("1.1.2","Partnering means"),
            ("1.1.3","Agreements &amp; SLA"), ("1.1.4","Review"),
        ]},
    ]},
    {"title": "2 &middot; Channels", "groups": [
        {"label": "Assisted Touchpoints", "caps": [
            ("2.1.1","Teller"), ("2.1.2","Retail Salesforce"),
            ("2.1.3","Contact Centre (Phone)"), ("2.1.4","Contact Centre (Web)"),
            ("2.1.5","Relationship Manager"), ("2.1.6","Mail"), ("2.1.7","Social Media"),
        ]},
        {"label": "Un-Assisted Touchpoints", "caps": [
            ("2.2.1","IVR"), ("2.2.2","Kiosk / SST"), ("2.2.3","Web (BPI)"),
            ("2.2.4","Mobile"), ("2.2.5","SMS"), ("2.2.6","ATM"), ("2.2.7","PoS"),
        ]},
        {"label": "", "caps": [
            ("2.3.1","Affiliate &amp; Partner Channels"), ("2.3.2","Device Management"),
        ]},
    ]},
    {"title": "3 &middot; Marketing &amp; Distribution", "groups": [
        {"label": "", "caps": [
            ("3.1.1","Marketing"), ("3.1.2","Digital Marketing"), ("3.1.3","Sales Management"),
            ("3.1.4","Contract Management"), ("3.1.5","Illustration Management"),
            ("3.1.6","Customer Finance Mgmt."), ("3.1.7","Brand Management"),
        ]},
    ]},
    {"title": "4 &middot; Common Customer View", "groups": [
        {"label": "Customer View", "caps": [
            ("4.1.1","Demographics"), ("4.1.2","Holdings"), ("4.1.3","Roles &amp; Relationships"),
            ("4.1.4","Ref. Satellite"), ("4.1.5","Segmentation"),
        ]},
        {"label": "", "caps": [
            ("4.2.1","Registration"), ("4.2.2","Authentication"),
        ]},
        {"label": "Preferences", "caps": [
            ("4.3.1","Needs and offer"), ("4.3.2","Goals"), ("4.3.3","Communication"),
        ]},
        {"label": "", "caps": [
            ("4.4.1","Sentiment &amp; Feedback"), ("4.4.2","Personalisation"),
        ]},
        {"label": "Authorisations", "caps": [
            ("4.5.1","Operations author."), ("4.5.2","Delegations, PoA"), ("4.5.3","Signatures"),
        ]},
        {"label": "", "caps": [
            ("4.6.1","Prospect Management"),
        ]},
    ]},
    {"title": "5 &middot; Product Processing", "groups": [
        {"label": "Product Catalogue", "caps": [
            ("5.1.1","Deposits"), ("5.1.2","Lending"), ("5.1.3","Corp Finance"),
            ("5.1.4","Asset Mgmt."), ("5.1.5","Insurance"), ("5.1.6","FX"),
            ("5.1.7","Cards"), ("5.1.8","Non Financial Products"), ("5.1.9","Custody &amp; Funded Adm."),
        ]},
    ]},
    {"title": "6 &middot; Common Services", "groups": [
        {"label": "", "caps": [
            ("6.1.1","Master Contract Mgmt."), ("6.1.2","Cash Mgmt."),
            ("6.1.3","Payments"), ("6.1.4","Statements"), ("6.1.5","Interest &amp; Fees"),
        ]},
        {"label": "Risk", "caps": [
            ("6.2.1","Operational"), ("6.2.2","Financial"),
        ]},
        {"label": "", "caps": [
            ("6.3.1","AML"), ("6.3.2","Fraud"),
        ]},
        {"label": "Complaints", "caps": [
            ("6.4.1","Analysis"), ("6.4.2","Follow up"), ("6.4.3","Closing"),
        ]},
        {"label": "", "caps": [
            ("6.5.1","Collections &amp; Recovery"), ("6.5.2","Compliance &amp; Regulation"),
            ("6.5.3","Pricing Management"), ("6.5.4","Treasury"),
        ]},
        {"label": "Customer Services", "caps": [
            ("6.6.1","Financial Servicing"), ("6.6.2","Non Financial Servicing"),
            ("6.6.3","Intelligent Servicing (RPA)"),
        ]},
        {"label": "Reconciliations", "caps": [
            ("6.7.1","Financial Reconciliation"), ("6.7.2","Operational Reconciliation"),
        ]},
    ]},
    {"title": "7 &middot; Enterprise Support Functions", "groups": [
        {"label": "", "caps": [
            ("7.1.1","Finance (GL)"), ("7.1.2","Talent &amp; Organisation"),
            ("7.1.3","IT"), ("7.1.4","Corporate Services"),
        ]},
    ]},
    {"title": "8 &middot; Technology Tools", "groups": [
        {"label": "", "caps": [
            ("8.1.1","Scheduling"), ("8.1.2","Business Process Mgmt."), ("8.1.3","AI Tools"),
            ("8.1.4","EA Tools"), ("8.1.5","Document Management"),
            ("8.1.6","Collaboration &amp; Productivity"), ("8.1.7","Project Management"),
            ("8.1.8","RPA Tools"),
        ]},
    ]},
    {"title": "9 &middot; Insights &amp; Information", "groups": [
        {"label": "", "caps": [
            ("9.1.1","Operational Data Stores"), ("9.1.2","Event Streams"), ("9.1.3","Data Lakes"),
        ]},
    ]},
    {"title": "10 &middot; Integration &amp; Interfaces", "groups": [
        {"label": "Interface Management", "caps": [
            ("10.1.1","Access Control"), ("10.1.2","Traffic Management"), ("10.1.3","API Catalogue"),
        ]},
    ]},
    {"title": "Transversal &middot; Interfaces &amp; Seguridad", "groups": [
        {"label": "External Interfaces", "caps": [
            ("T.1.1","API"), ("T.1.2","EDI"),
            ("T.1.3","Payment Schemes"), ("T.1.4","Cloud Integration"),
        ]},
        {"label": "Internal Interfaces", "caps": [
            ("T.2.1","API"), ("T.2.2","ESB"),
            ("T.2.3","MQ / Async"), ("T.2.4","Others"),
        ]},
        {"label": "Datos &amp; Seguridad", "caps": [
            ("T.3.1","Master Data Mgmt."), ("T.3.2","Metadata Mgmt."),
            ("T.3.3","Content Mgmt."), ("T.3.4","Analytics / Reporting"), ("T.3.5","Security"),
        ]},
        {"label": "CFR Regulatorio", "caps": [
            ("T.4.1","CFR Reporting"),
        ]},
        {"label": "Extensiones GemCog", "caps": [
            ("T.5.1","Batch Orch."), ("T.6.1","CPE"),
        ]},
    ]},
]

# ── Funciones ────────────────────────────────────────────────────────────────

def count_tasks_in_file(cap_file: str, slug: str) -> int:
    path = os.path.join(CAPS_DIR, cap_file)
    if not os.path.exists(path):
        return 0
    with open(path, encoding="utf-8") as f:
        txt = f.read()
    ids = set(re.findall(rf'\bT-{re.escape(slug)}-\d+\b', txt))
    return len(ids)


def build_task_counts() -> dict:
    counts = {}
    for cap_id, m in CAP_META.items():
        if not m["count"]:
            counts[cap_id] = EXISTING_J.get(cap_id, 0)
            continue
        n = count_tasks_in_file(m["cap_file"], m["task_slug"])
        # fall back to existing HTML value if the cap file doesn't have the slug pattern
        counts[cap_id] = n if n > 0 else EXISTING_J.get(cap_id, 0)
    return counts


def render_tile(cap_id: str, default_name: str, jmap: dict) -> str:
    if cap_id not in CAP_META:
        return f'  <div class="cap off"><span class="cn">{default_name}</span></div>'
    m = CAP_META[cap_id]
    j = jmap.get(cap_id, 0)
    return (
        f'  <div class="cap {m["cls"]}" data-did="{m["did"]}" data-id="{cap_id}" data-n="{m["n"]}" '
        f'data-dom="{m["dom"]}" data-b="{m["b"]}" data-j="{j}" '
        f'data-r="{m["r"]}" data-s="{m["s"]}">'
        f'<span class="cn">{m["cn"]}</span><span class="cb">{m["b"]}</span></div>'
    )


def render_wrap(jmap: dict) -> str:
    parts = ['<div id="wrap">', '']
    for domain in STRUCTURE:
        parts.append(f'<div class="area"><div class="atitle">{domain["title"]}</div>'
                     f'<div class="agroups">')
        for grp in domain["groups"]:
            parts.append('<div class="grp">')
            if grp["label"]:
                parts.append(f'<div class="gl">{grp["label"]}</div>')
            parts.append('<div class="caps">')
            for cap_id, cap_name in grp["caps"]:
                parts.append(render_tile(cap_id, cap_name, jmap))
            parts.append('</div>')   # caps
            parts.append('</div>')   # grp
        parts.append('</div></div>') # agroups + area
        parts.append('')
    parts.append('</div>')  # wrap
    return '\n'.join(parts)


def main():
    print("render-capability-map.py - Banamex GemCog")
    print("=" * 50)

    # 1. Contar tareas desde cap files
    print("\nContando tareas en cap-*.md …")
    jmap = build_task_counts()
    covered = sorted(jmap.keys())
    for cap_id in covered:
        m = CAP_META[cap_id]
        src = "contado" if m["count"] else "existing_html"
        print(f"  {cap_id:8s}  j={jmap[cap_id]:>4d}  ({src})  {m['cap_file']}")

    # 2. Generar HTML del wrap
    new_wrap = render_wrap(jmap)

    # 3. Leer HTML existente
    if not os.path.exists(HTML_PATH):
        print(f"\n❌ No encontrado: {HTML_PATH}")
        return
    with open(HTML_PATH, encoding="utf-8") as f:
        html = f.read()

    # 4. Reemplazar bloque <div id="wrap"> … </div>  (el </div> antes de <footer>)
    html_new = re.sub(
        r'<div id="wrap">.*?</div>(?=\s*\n<footer)',
        new_wrap,
        html,
        flags=re.DOTALL,
    )
    wrap_changed = (html_new != html)
    if not wrap_changed:
        print("\nINFO: bloque wrap sin cambios (idempotente) — verificando KPIs...")

    # 5. Actualizar KPI tiles (siempre, independiente del wrap)
    covered_count = len(CAP_META)
    total_model   = 107  # 104 BIAN estándar + 3 extensiones GemCog (T.4.1 CFR · T.5.1 WFL · T.6.1 CPE)
    pct           = f"{covered_count/total_model*100:.1f}%"
    html_new = re.sub(
        r'(<div class="tile"><div class="n">)[^<]+(</div><div class="l">Capacidades cubiertas</div></div>)',
        rf'\g<1>{covered_count}/{total_model}\g<2>',
        html_new,
    )
    html_new = re.sub(
        r'(<div class="tile"><div class="n">)[^<]+(</div><div class="l">Cobertura del modelo</div></div>)',
        rf'\g<1>{pct}\g<2>',
        html_new,
    )

    if html_new == html:
        print("INFO: KPIs también sin cambios — HTML ya estaba actualizado (idempotente)")
        return

    # 6. Escribir resultado
    with open(HTML_PATH, "w", encoding="utf-8") as f:
        f.write(html_new)

    print(f"\nOK  {HTML_PATH}")
    print(f"    {covered_count}/{total_model} capacidades · {pct} cobertura")


if __name__ == "__main__":
    main()

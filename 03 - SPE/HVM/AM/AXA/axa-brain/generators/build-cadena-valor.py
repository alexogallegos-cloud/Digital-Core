#!/usr/bin/env python3
"""
build-cadena-valor.py — Genera portal/cadena-de-valor.html
Template: Liverpool cadena-valor.html · Adaptado para AXA México P&C Commercial Lines.
Fuente: axa-brain.db + knowledge-base/value-chain/cadena-de-valor-axa-pc.md
"""
import sqlite3, json, pathlib, datetime, shutil

ROOT     = pathlib.Path(__file__).parent.parent
DB       = ROOT / "axa-brain.db"
OUT      = ROOT / "portal" / "cadena-de-valor.html"
TODAY    = datetime.date.today().isoformat()
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

# ── Actividades Primarias ────────────────────────────────────────────────────
PRIMARY = [
    dict(id="C1", name="Diseño Producto",    flex=14, color="blue",  blk_bg="#08083A",
         subtitle="Notas técnicas, tarifas y catálogos de producto por ramo",
         etb="D6.2", status="partial", priority=9, cls0="P",
         sistemas=["Nota Técnica", "ERN", "General Daños"],
         gap="Sin sistema de product lifecycle management; notas técnicas son documentos manuales",
         l2=[("D6.2.1 Desarrollo de Productos",3),("D6.2.2 Gestión de Tarifas",4),
             ("D6.2.3 Catálogo de Coberturas",2),("D6.2.4 Registro CNSF",3)]),
    dict(id="C2", name="Distribución",       flex=18, color="blue",  blk_bg="#0A0A45",
         subtitle="Red de agentes, corredores y gestión de intermediarios",
         etb="D1+D2+D4", status="partial", priority=4, cls0="P",
         sistemas=["SINCO"],
         gap="Sin portal de agentes — coordinación por correo y WhatsApp sin trazabilidad",
         l2=[("D1 Gestión de Canales",5),("D2 Gestión de Distribución",6),
             ("D4.1 Gestión de Agentes",4),("D4.2 Comisiones y Liquidaciones",3)]),
    dict(id="C3", name="Suscripción",        flex=42, color="red",   blk_bg="#250010",
         subtitle="Evaluación del riesgo, cotización técnica y aceptación — 541 pasos documentados",
         etb="D6.3", status="partial-critical", priority=1, cls0="P",
         sistemas=["Vector","HSD-Excel ⚠","SINCO","ERN","SAFAC","Power BI"],
         gap="HSD no es un sistema: cálculo técnico en Excel sin integración con Vector, ERN ni SAFAC",
         l2=[("D6.3.1 Risk Information Mgmt",8),("D6.3.2 Risk Assessment & Rating",12),
             ("D6.3.3 Catastrophe Modelling",5),("D6.3.4 Quote Management",7),
             ("D6.3.5 Negotiation & Placement",6),("D6.3.6 Policy Binding",4)]),
    dict(id="C4", name="Emisión Póliza",     flex=18, color="blue",  blk_bg="#060650",
         subtitle="Captura, emisión, endosos, renovaciones y cancelaciones",
         etb="D6.4", status="partial", priority=3, cls0="P",
         sistemas=["General Daños"],
         gap="Recaptura manual: condiciones de suscripción (Vector+HSD) se reteclean en General Daños",
         l2=[("D6.4.1 Emisión de Póliza",6),("D6.4.2 Gestión de Endosos",5),
             ("D6.4.3 Renovaciones",4),("D6.4.4 Cancelaciones y Rescisión",3)]),
    dict(id="C5", name="Reaseguro",          flex=14, color="blue",  blk_bg="#0A0A35",
         subtitle="Cesión facultativa y tratados de cartera",
         etb="D6.1", status="partial", priority=5, cls0="H",
         sistemas=["SAFAC","ERN"],
         gap="SAFAC solo estructura lineal; sin carga masiva de capas ni múltiples reaseguradores por capa",
         l2=[("D6.1.1 Facultativo (riesgo a riesgo)",5),("D6.1.2 Tratados Proporcionales",4),
             ("D6.1.3 Tratados No Proporcionales XL",3),("D6.1.4 Reporting Cedentes",2)]),
    dict(id="C6", name="Siniestros",         flex=12, color="gap",   blk_bg="#141428",
         subtitle="FNOL, ajuste, autorización de pago y cierre de expediente",
         etb="D6.5", status="scaffold", priority=2, cls0="P",
         sistemas=["DATO REQUERIDO"],
         gap="Punto ciego completo — ningún sistema de siniestros fue identificado en el Discovery",
         l2=[("D6.5.1 FNOL & Intake",0),("D6.5.2 Claims Adjudication",0),
             ("D6.5.3 Payment & Settlement",0),("D6.5.4 Claims Closure",0)]),
    dict(id="C7", name="Cobranza",           flex=10, color="gap",   blk_bg="#141428",
         subtitle="Recaudación de primas, morosidad y fraccionamiento",
         etb="D6.1-Billing", status="scaffold", priority=8, cls0="H",
         sistemas=["DATO REQUERIDO"],
         gap="Sin sistema de billing identificado en el Discovery",
         l2=[("D6.1.B1 Facturación de Primas",0),("D6.1.B2 Recaudación",0),
             ("D6.1.B3 Gestión de Morosidad",0)]),
]

# ── Actividades de Soporte ───────────────────────────────────────────────────
SUPPORT = [
    dict(id="S1", name="Actuaría y Reservas",      color="blue",  badge="c-blue",
         subtitle="Pricing técnico, reservas IBNR y solvencia regulatoria",
         etb="D6.3+D7.1", sistemas=["ERN","DATO REQUERIDO (reservas)"],
         l2=[("Modelación Catastrófica",4),("Reservas IBNR",3),("Solvencia C",2)]),
    dict(id="S2", name="Reaseguro Tratados",       color="blue",  badge="c-blue",
         subtitle="Tratados XL, stop-loss y protección de cartera global",
         etb="D6.1", sistemas=["SAFAC","ERN"],
         l2=[("Tratados XL Excess of Loss",3),("Stop-Loss Cartera",2),("Reporting Cedentes",2)]),
    dict(id="S3", name="Analytics y BI",           color="muted", badge="c-muted",
         subtitle="Siniestralidad histórica, primas y reporting gerencial",
         etb="D8", sistemas=["Power BI","DATO REQUERIDO (DW)"],
         l2=[("Siniestralidad por Ramo",4),("Reporting Gerencial",3),("Data Warehouse",0)]),
    dict(id="S4", name="Regulatorio CNSF",         color="muted", badge="c-muted",
         subtitle="Reportes CNSF, Solvencia C e IFRS 17",
         etb="D7.2+D9", sistemas=["Monitor (tentativo)","DATO REQUERIDO (IFRS 17)"],
         l2=[("Circular Única CNSF",3),("Solvencia C",2),("IFRS 17 pendiente",0)]),
    dict(id="S5", name="Finanzas",                 color="muted", badge="c-muted",
         subtitle="Resultado técnico y consolidación al Grupo AXA",
         etb="D7.1", sistemas=["DATO REQUERIDO"],
         l2=[("Resultado Técnico",2),("Reporting AXA Group",2),("IFRS 17 Contabilidad",0)]),
    dict(id="S6", name="Tecnología e Integración", color="gap",   badge="c-gap",
         subtitle="API gateway, event bus y arquitectura de integración",
         etb="D10+D11", sistemas=["Sin API Gateway","Sin Event Bus"],
         l2=[("API Gateway",0),("Event Bus / ESB",0),("Data Warehouse",0)]),
]


def get_stats(conn):
    stats = {"systems": 8, "pain_points": 33, "process_steps": 541, "etb_caps": 14}
    queries = [
        ("systems",       "SELECT COUNT(*) FROM systems"),
        ("pain_points",   "SELECT COUNT(*) FROM pain_points"),
        ("process_steps", "SELECT COUNT(*) FROM process_steps"),
        ("etb_caps",      "SELECT COUNT(*) FROM etb_capabilities"),
    ]
    for key, sql in queries:
        try:
            r = conn.execute(sql).fetchone()
            if r and r[0]:
                stats[key] = r[0]
        except Exception:
            pass
    return stats


def build_data_dict():
    data = {}
    for b in PRIMARY:
        total = sum(c for _, c in b["l2"])
        data[b["id"]] = {
            "name": b["name"], "subtitle": b["subtitle"],
            "cap_count": total, "color": b["color"],
            "etb_domains": [b["etb"]], "sistemas": b["sistemas"],
            "gap": b["gap"], "status": b["status"], "priority": b["priority"],
            "l2": [{"name": n, "count": c} for n, c in b["l2"]],
        }
    for s in SUPPORT:
        total = sum(c for _, c in s["l2"])
        data[s["id"]] = {
            "name": s["name"], "subtitle": s["subtitle"],
            "cap_count": total, "color": s["color"],
            "etb_domains": [s["etb"]], "sistemas": s["sistemas"],
            "l2": [{"name": n, "count": c} for n, c in s["l2"]],
        }
    return data


def col_labels_html():
    parts = []
    for b in PRIMARY:
        lc = "c-red" if b["color"] == "red" else ("c-gap" if b["color"] == "gap" else "c-blue")
        inner = ""
        for name, count in b["l2"][:3]:
            inner += (
                f'<div class="col-label">'
                f'<span class="col-lid {lc}">{b["id"]}</span>'
                f'<span class="col-lname">{name}</span></div>'
            )
        parts.append(f'<div class="col-labels" style="flex:{b["flex"]}">{inner}</div>')
    return "\n".join(parts)


def primary_blocks_html():
    cls_map = {"P": ("cls-prim", "Primario"), "H": ("cls-hab", "Habilitador"), "S": ("cls-sop", "Soporte")}
    parts = []
    for b in PRIMARY:
        cc = f"c-{b['color']}"
        total = sum(c for _, c in b["l2"])
        cnt_str = str(total) if total else "—"
        c0 = b["cls0"]
        cls_css, cls_label = cls_map[c0]
        bid = b["id"]
        blk_bg = b["blk_bg"]
        flex = b["flex"]
        name = b["name"]
        parts.append(
            f'<div class="prim-block {cc}" id="{bid}" '
            f'style="flex:{flex};--blk-bg:{blk_bg}" '
            f'onclick="selectBlock(\'{bid}\')" data-cls="{c0}">'
            f'<div class="pb-num">{bid}</div>'
            f'<div class="pb-name">{name}</div>'
            f'<div class="pb-foot">'
            f'<span class="pb-cnt">{cnt_str} cap.</span>'
            f'</div></div>'
        )
    return "\n".join(parts)


def support_band_html():
    cls_map = {"blue": ("H", "cls-hab", "Habilitador"),
               "muted": ("S", "cls-sop", "Soporte"),
               "gap":   ("S", "cls-sop", "Soporte")}
    parts = []
    for s in SUPPORT:
        cc = f"c-{s['color']}"
        bc = s["badge"]
        total = sum(c for _, c in s["l2"])
        cnt_str = str(total) if total else "—"
        c0, cls_css, cls_label = cls_map[s["color"]]
        sid = s["id"]
        l2_parts = "".join(
            f'<div class="sp-l2">'
            f'<span class="sp-l2n">{name}</span>'
            f'<span class="sp-l2c">{"—" if count == 0 else count}</span>'
            f'</div>'
            for name, count in s["l2"]
        )
        parts.append(
            f'<div class="sup-card {cc}" id="{sid}" '
            f'onclick="selectBlock(\'{sid}\')" data-cls="{c0}">'
            f'<div class="sup-top">'
            f'<span class="sup-badge {bc}">{sid} · {s["etb"]}</span>'
            f'</div>'
            f'<div class="sup-name">{s["name"]}</div>'
            f'<div class="sup-sub">{s["subtitle"]}</div>'
            f'<div class="sup-cnt"><span class="cnt-n">{cnt_str}</span> capacidades</div>'
            f'<div class="sup-l2s">{l2_parts}</div>'
            f'</div>'
        )
    return "\n".join(parts)


CSS = """
*{box-sizing:border-box;margin:0;padding:0}
:root{
  --blue:#4D4DFF;--blue-dim:#2A2AAF;--blue-bright:#8888FF;
  --red:#FF1721;--red-soft:#FF5566;
  --amber:#FFA726;
  --ink:#EDF0FF;--muted:#9090C8;--muted2:#6060A0;
  --bg:#030318;--glass:rgba(0,0,60,.55);--glassb:rgba(0,0,80,.75)
}
html{scroll-behavior:smooth}
body{background:var(--bg);color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
  -webkit-font-smoothing:antialiased;padding-bottom:80px}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before{content:"";position:absolute;width:55vw;height:55vw;left:-10vw;top:-14vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(0,0,143,.32),transparent 70%);
  animation:f1 28s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:42vw;height:42vw;right:-6vw;top:4vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(255,23,33,.15),transparent 70%);
  animation:f2 34s ease-in-out infinite}
@keyframes f1{50%{transform:translate(4vw,6vh) scale(1.1)}}
@keyframes f2{50%{transform:translate(-5vw,8vh) scale(1.08)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.035;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
nav{position:sticky;top:0;z-index:50;display:flex;align-items:center;gap:14px;padding:12px 24px;
  backdrop-filter:blur(20px) saturate(160%);-webkit-backdrop-filter:blur(20px) saturate(160%);
  background:rgba(3,3,24,.85);border-bottom:1px solid rgba(255,255,255,.07)}
.axa-logo-mark{display:flex;align-items:center;gap:8px}
.axa-logo-text{font-size:19px;font-weight:900;color:#fff;letter-spacing:.05em;
  font-family:'Arial Black','Helvetica Neue',Arial,sans-serif;line-height:1}
.axa-accent-bar{width:3px;height:20px;background:var(--red);border-radius:1px;margin:0 2px}
nav .nt{font-size:12px;font-weight:600;color:var(--muted)}
.edot{width:6px;height:6px;border-radius:50%;background:var(--red);
  box-shadow:0 0 8px var(--red);animation:epulse 2.4s infinite;
  display:inline-block;margin-right:6px}
@keyframes epulse{50%{opacity:.4}}
nav .sp{flex:1}
nav a{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:20px;
  transition:.2s;text-decoration:none}
nav a:hover{color:var(--ink);background:rgba(255,255,255,.07)}
nav a.back{border:1px solid rgba(255,255,255,.09)}
nav a.ext{color:var(--blue)}
.wrap{max-width:1480px;margin:0 auto;padding:0 22px}
.page-header{padding:24px 0 18px}
.eyebrow{font-size:11px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;
  color:var(--red);margin-bottom:6px}
h1{font-size:clamp(20px,2.8vw,34px);font-weight:900;letter-spacing:-.03em;
  background:linear-gradient(175deg,#fff 30%,#bbbbff);-webkit-background-clip:text;
  background-clip:text;color:transparent;margin-bottom:5px}
.page-sub{font-size:12.5px;color:var(--muted);line-height:1.6;max-width:720px;margin-bottom:18px}
.kpi-bar{display:flex;flex-wrap:wrap;gap:0;margin-bottom:18px;
  background:rgba(3,3,40,.78);border:1px solid rgba(255,255,255,.07);
  border-radius:12px;backdrop-filter:blur(14px);overflow:hidden}
.kpi-item{display:flex;flex-direction:column;gap:3px;padding:14px 20px;
  border-right:1px solid rgba(255,255,255,.06)}
.kpi-item:last-child{border-right:none}
.kv{font-size:1.55rem;font-weight:900;letter-spacing:-.03em;line-height:1}
.kv.kblue{color:var(--blue)}.kv.kred{color:var(--red)}
.kv.kamber{color:var(--amber)}.kv.kwh{color:#fff}
.kl{font-size:8.5px;font-weight:700;letter-spacing:.10em;text-transform:uppercase;color:var(--muted2)}
.legend-row{display:flex;flex-wrap:wrap;gap:8px 18px;align-items:center;
  font-size:11px;color:var(--muted);margin-bottom:20px;padding:9px 14px;
  background:rgba(3,3,35,.5);border:1px solid rgba(255,255,255,.05);border-radius:9px}
.cls-pill{font-size:9px;font-weight:800;letter-spacing:.07em;text-transform:uppercase;
  padding:3px 9px;border-radius:6px;cursor:pointer;border:none;font-family:inherit;transition:.18s}
.cls-prim{background:rgba(77,77,255,.18);border:1px solid rgba(77,77,255,.40);color:var(--blue)}
.cls-hab{background:rgba(255,167,38,.15);border:1px solid rgba(255,167,38,.35);color:var(--amber)}
.cls-sop{background:rgba(144,144,200,.14);border:1px solid rgba(144,144,200,.28);color:var(--muted)}
.cls-pill:hover{filter:brightness(1.25)}
.leg-item{display:flex;align-items:center;gap:7px}
.tip{font-size:10px;color:var(--muted2);margin-left:auto}
.sec-label{font-size:8.5px;font-weight:800;letter-spacing:.18em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:8px;padding-left:2px}
.support-band{display:flex;flex-wrap:wrap;gap:10px;margin-bottom:22px}
.sup-card{flex:1;min-width:calc(30% - 10px);
  background:rgba(6,6,40,.72);border:1px solid rgba(255,255,255,.07);
  border-radius:12px;padding:13px 14px 12px;cursor:pointer;transition:.2s;
  backdrop-filter:blur(14px)}
.sup-card:hover{border-color:rgba(255,255,255,.14);background:rgba(10,10,55,.85)}
.sup-card.active{border-color:rgba(77,77,255,.35);background:rgba(8,8,50,.9)}
.sup-card.c-gap{background:rgba(10,10,22,.72)}
.sup-card.c-gap.active{border-color:rgba(255,167,38,.35)}
.sup-card.c-muted{background:rgba(8,8,30,.72)}
.sup-top{display:flex;align-items:center;justify-content:space-between;gap:6px;margin-bottom:7px}
.sup-badge{font-size:8px;font-weight:800;padding:2px 7px;border-radius:5px;font-family:inherit}
.sup-badge.c-blue{background:rgba(77,77,255,.15);border:1px solid rgba(77,77,255,.28);color:var(--blue)}
.sup-badge.c-muted{background:rgba(144,144,200,.12);border:1px solid rgba(144,144,200,.22);color:var(--muted)}
.sup-badge.c-gap{background:rgba(255,167,38,.12);border:1px solid rgba(255,167,38,.25);color:var(--amber)}
.sup-name{font-size:13px;font-weight:800;line-height:1.3;margin-bottom:3px}
.sup-card.c-blue .sup-name{color:var(--blue)}
.sup-card.c-muted .sup-name{color:var(--muted)}
.sup-card.c-gap .sup-name{color:var(--amber)}
.sup-sub{font-size:10px;color:var(--muted2);line-height:1.45;margin-bottom:8px}
.sup-cnt{font-size:9.5px;color:var(--muted2);margin-bottom:8px}
.cnt-n{font-weight:800;color:var(--muted)}
.sup-l2s{display:flex;flex-direction:column;gap:3px}
.sp-l2{display:flex;justify-content:space-between;align-items:baseline;gap:6px;
  padding:3px 6px;border-radius:5px;background:rgba(255,255,255,.03)}
.sp-l2n{font-size:9.5px;color:var(--muted2);flex:1;line-height:1.35}
.sp-l2c{font-size:9px;font-weight:700;color:var(--muted2);flex:none}
.col-labels-row{display:flex;gap:0;margin-bottom:0;min-height:90px;align-items:flex-end}
.col-labels{display:flex;flex-direction:column;justify-content:flex-end;gap:3px;
  padding:0 6px 6px;margin-left:-22px}
.col-labels:first-child{margin-left:0}
.col-label{display:flex;align-items:baseline;gap:5px}
.col-lid{font-size:8.5px;font-weight:800;letter-spacing:.04em;flex:none}
.col-lid.c-blue{color:var(--blue)}.col-lid.c-red{color:var(--red)}
.col-lid.c-gap{color:var(--amber)}.col-lid.c-muted{color:var(--muted2)}
.col-lname{font-size:9px;color:var(--muted2);line-height:1.3;white-space:nowrap;
  overflow:hidden;text-overflow:ellipsis;max-width:180px}
.primary-wrap{display:flex;gap:0;position:relative}
.primary-flow{display:flex;flex:1;height:100px;overflow:visible}
.prim-block{min-width:0;flex:1;height:100%;position:relative;
  padding:14px 48px 12px 44px;cursor:pointer;transition:filter .15s;
  display:flex;flex-direction:column;justify-content:space-between;
  background:var(--blk-bg,#08083A);overflow:visible}
.prim-block:first-child{padding-left:18px}
.prim-block::before{content:'';position:absolute;top:-1px;right:-35px;width:0;height:0;
  border-top:51px solid transparent;border-bottom:51px solid transparent;
  border-left:35px solid rgba(255,255,255,.10);z-index:1;pointer-events:none}
.prim-block::after{content:'';position:absolute;top:0;right:-32px;width:0;height:0;
  border-top:50px solid transparent;border-bottom:50px solid transparent;
  border-left:32px solid var(--blk-bg,#08083A);z-index:2;pointer-events:none}
.prim-block:last-child::after,.prim-block:last-child::before{display:none}
.primary-flow .prim-block:nth-child(1){z-index:7}
.primary-flow .prim-block:nth-child(2){z-index:6}
.primary-flow .prim-block:nth-child(3){z-index:5}
.primary-flow .prim-block:nth-child(4){z-index:4}
.primary-flow .prim-block:nth-child(5){z-index:3}
.primary-flow .prim-block:nth-child(6){z-index:2}
.primary-flow .prim-block:nth-child(7){z-index:1}
.prim-block:hover,.prim-block.active{z-index:9!important;filter:brightness(1.18)}
.pb-num{font-size:10px;font-weight:900;letter-spacing:.08em;line-height:1}
.prim-block.c-blue .pb-num{color:rgba(77,77,255,.55)}
.prim-block.c-red .pb-num{color:rgba(255,23,33,.65)}
.prim-block.c-gap .pb-num{color:rgba(255,167,38,.55)}
.pb-name{font-size:14px;font-weight:800;line-height:1.25;color:var(--ink)}
.prim-block.c-blue.active .pb-name{color:var(--blue)}
.prim-block.c-red.active .pb-name{color:var(--red)}
.prim-block.c-gap.active .pb-name{color:var(--amber)}
.pb-foot{display:flex;align-items:center;justify-content:space-between;gap:6px;flex-wrap:wrap}
.pb-cnt{font-size:9.5px;font-weight:700;color:var(--muted2);white-space:nowrap}
.detail-panel{margin-top:10px;background:rgba(4,4,28,.85);
  border:1px solid rgba(255,255,255,.09);border-radius:12px;padding:18px 20px;
  backdrop-filter:blur(16px);display:none}
.detail-panel.open{display:block}
.dp-header{display:flex;align-items:baseline;gap:12px;margin-bottom:14px;flex-wrap:wrap}
.dp-title{font-size:16px;font-weight:900}
.dp-sub{font-size:11.5px;color:var(--muted);flex:1}
.dp-tags{display:flex;gap:6px;flex-wrap:wrap}
.dom-tag{font-size:8.5px;font-weight:800;padding:2px 6px;border-radius:5px;
  background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.1);color:var(--muted)}
.rtg-tag{font-size:8px;font-weight:800;padding:2px 6px;border-radius:5px}
.rtg-tag.c-blue{background:rgba(77,77,255,.15);border:1px solid rgba(77,77,255,.28);color:var(--blue)}
.rtg-tag.c-red{background:rgba(255,23,33,.15);border:1px solid rgba(255,23,33,.28);color:var(--red)}
.rtg-tag.c-gap{background:rgba(255,167,38,.15);border:1px solid rgba(255,167,38,.28);color:var(--amber)}
.rtg-tag.c-muted{background:rgba(144,144,200,.12);border:1px solid rgba(144,144,200,.22);color:var(--muted)}
.gap-alert{font-size:11px;color:var(--amber);background:rgba(255,167,38,.09);
  border:1px solid rgba(255,167,38,.24);border-radius:8px;padding:8px 12px;
  margin-bottom:12px;line-height:1.5}
.gap-alert.critical{color:var(--red-soft);background:rgba(255,23,33,.07);
  border-color:rgba(255,23,33,.22)}
.sistemas-row{font-size:10px;color:var(--muted2);margin-bottom:12px;
  display:flex;flex-wrap:wrap;align-items:center;gap:4px}
.sistemas-row strong{color:var(--muted);font-size:9px;text-transform:uppercase;
  letter-spacing:.07em;margin-right:4px}
.sis-tag{display:inline-block;font-size:9px;font-weight:700;padding:2px 7px;border-radius:5px;
  background:rgba(77,77,255,.10);border:1px solid rgba(77,77,255,.20);color:var(--blue)}
.sis-tag.unknown{background:rgba(255,167,38,.09);border-color:rgba(255,167,38,.22);color:var(--amber)}
.dp-l2-grid{display:flex;flex-wrap:wrap;gap:8px}
.dp-l2-card{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);
  border-radius:9px;padding:10px 12px;min-width:190px;flex:1}
.dp-l2-name{font-size:11px;font-weight:700;color:var(--ink);margin-bottom:4px;line-height:1.35}
.dp-l2-cnt{font-size:9px;font-weight:700;color:var(--muted2)}
footer{padding:32px 0 16px;text-align:center;color:var(--muted2);font-size:11.5px;line-height:1.8}
footer code{color:var(--muted);background:rgba(77,77,255,.09);border:1px solid rgba(77,77,255,.18);
  border-radius:5px;padding:1px 6px;font-family:'SF Mono',ui-monospace,monospace}
.axa-foot{color:var(--red);font-weight:900;
  font-family:'Arial Black','Helvetica Neue',Arial,sans-serif;letter-spacing:.05em}
/* ── Hero ── */
.hero{position:relative;padding:72px 0 56px;overflow:hidden;
  background:radial-gradient(ellipse 90% 70% at 50% -10%,rgba(0,0,143,.22) 0%,transparent 65%)}
.hero::before{content:'';position:absolute;inset:0;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%230000ff' fill-opacity='0.025'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/svg%3E")}
.hero-inner{max-width:1480px;margin:0 auto;padding:0 22px}
.hero-logo{height:36px;object-fit:contain;margin-bottom:28px;opacity:.92}
.hero-eyebrow{font-size:11px;font-weight:700;letter-spacing:.2em;color:var(--red);
  text-transform:uppercase;margin-bottom:14px}
.hero-title{font-size:clamp(32px,4.5vw,60px);font-weight:900;line-height:1.06;letter-spacing:-.025em;
  max-width:820px;margin-bottom:18px;
  background:linear-gradient(135deg,#fff 50%,rgba(255,255,255,.35));
  -webkit-background-clip:text;background-clip:text;color:transparent}
.hero-sub{font-size:15px;color:var(--muted);max-width:620px;line-height:1.7;margin-bottom:40px}
.hero-kpis{display:flex;flex-wrap:wrap;gap:0;
  background:rgba(3,3,35,.75);border:1px solid rgba(255,255,255,.08);
  border-radius:12px;backdrop-filter:blur(16px);overflow:hidden;max-width:860px}
.hkpi{display:flex;flex-direction:column;gap:3px;padding:18px 26px;
  border-right:1px solid rgba(255,255,255,.06);flex:1;min-width:120px}
.hkpi:last-child{border-right:none}
.hkpi-n{font-size:1.75rem;font-weight:900;letter-spacing:-.03em;line-height:1}
.hkpi-l{font-size:8px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);margin-top:3px}
"""


def build_html(stats, today):
    data_dict = build_data_dict()
    data_json = json.dumps(data_dict, ensure_ascii=False, separators=(',', ':'))

    total_prim = sum(sum(c for _, c in b["l2"]) for b in PRIMARY)

    col_lbl  = col_labels_html()
    prim_blk = primary_blocks_html()
    sup_band = support_band_html()

    logo_tag = '<img src="logos/Axa_logo.png" alt="AXA" class="nav-logo-img" style="height:28px;object-fit:contain">'

    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Cadena de Valor — AXA Brain</title>
<style>
{CSS}
.nav-logo-img{{height:28px;object-fit:contain}}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<nav>
  <div class="axa-logo-mark" style="display:flex;align-items:center;gap:10px">
    {logo_tag}
    <div class="axa-accent-bar"></div>
  </div>
  <span class="nt"><span class="edot"></span>Cadena de Valor &mdash; AXA P&amp;C Commercial Lines</span>
  <span class="sp"></span>
  <a href="index.html" class="back">&#8592; Portal</a>
  <a href="#" class="ext">Mapa ETB</a>
</nav>

<!-- HERO -->
<section class="hero">
  <div class="hero-inner">
    <img src="logos/Axa_logo.png" alt="AXA" class="hero-logo">
    <div class="hero-eyebrow">AXA Seguros M&eacute;xico &middot; P&amp;C Commercial Lines &middot; ETB Insurance v3.0</div>
    <h1 class="hero-title">Cadena de Valor &mdash; AXA P&amp;C</h1>
    <p class="hero-sub">
      Modelo de cadena de valor P&amp;C Commercial Lines basado en ETB Insurance v3.0.
      Clasifica los procesos como Primario (valor directo al asegurado), Habilitador (soporte estrat&eacute;gico)
      o Soporte (infraestructura organizacional). Haz clic en cualquier bloque para ver el detalle L2.
    </p>
    <div class="hero-kpis">
      <div class="hkpi"><div class="hkpi-n" style="color:#fff">{stats['process_steps']}</div><div class="hkpi-l">Pasos documentados</div></div>
      <div class="hkpi"><div class="hkpi-n" style="color:var(--red)">{stats['pain_points']}</div><div class="hkpi-l">Pain points</div></div>
      <div class="hkpi"><div class="hkpi-n" style="color:var(--blue-bright)">{stats['systems']}</div><div class="hkpi-l">Sistemas identificados</div></div>
      <div class="hkpi"><div class="hkpi-n" style="color:#fff">7</div><div class="hkpi-l">Actividades primarias</div></div>
      <div class="hkpi"><div class="hkpi-n" style="color:#fff">6</div><div class="hkpi-l">Act. de soporte</div></div>
      <div class="hkpi"><div class="hkpi-n" style="color:var(--amber)">{total_prim}</div><div class="hkpi-l">Caps. ETB mapeadas</div></div>
    </div>
  </div>
</section>

<div class="wrap">

<!-- LABELS L2 -->
<div class="col-labels-row">
{col_lbl}
</div>

<!-- FLUJO PRIMARIO -->
<div class="sec-label">Actividades Primarias &mdash; Flujo de Valor al Asegurado &#9654;</div>
<div class="primary-wrap">
  <div class="primary-flow">
{prim_blk}
  </div>
</div>

<!-- PANEL DE DETALLE -->
<div class="detail-panel" id="detail-panel">
  <div id="gap-alert-container"></div>
  <div id="sistemas-container"></div>
  <div class="dp-header">
    <span class="dp-title" id="dp-title"></span>
    <span class="dp-sub" id="dp-sub"></span>
    <div class="dp-tags" id="dp-tags"></div>
  </div>
  <div class="dp-l2-grid" id="dp-l2-grid"></div>
</div>

<!-- SOPORTE -->
<div class="sec-label" style="margin-top:24px">Actividades de Soporte y Habilitaci&oacute;n</div>
<div class="support-band">
{sup_band}
</div>

<footer>
  <p><span class="axa-foot">AXA</span> Seguros S.A. de C.V. &middot; P&amp;C Commercial Lines &middot; SPE-AM-AXA &middot; Generado el {today}</p>
  <p>Accenture Technology &middot; Software &amp; Platform Engineering &middot; High Velocity Modernization</p>
  <p>Generado desde <code>generators/build-cadena-valor.py</code> &mdash; fuente: <code>axa-brain.db &middot; value_chain</code></p>
</footer>
</div>

<script>
var DATA = {data_json};
var CLS_CYCLE  = ['P','H','S'];
var CLS_LABELS = {{P:'Primario',H:'Habilitador',S:'Soporte'}};
var CLS_CSS    = {{P:'cls-prim',H:'cls-hab',S:'cls-sop'}};
var COLOR_CSS  = {{blue:'c-blue',red:'c-red',gap:'c-gap',muted:'c-muted'}};
var activeId   = null;

function selectBlock(id) {{
  if (activeId === id) {{
    document.querySelectorAll('.prim-block,.sup-card').forEach(function(el){{el.classList.remove('active')}});
    document.getElementById('detail-panel').classList.remove('open');
    activeId = null;
    return;
  }}
  document.querySelectorAll('.prim-block,.sup-card').forEach(function(el){{el.classList.remove('active')}});
  var el = document.getElementById(id);
  if (el) el.classList.add('active');
  activeId = id;
  renderDetail(id);
  document.getElementById('detail-panel').classList.add('open');
  document.getElementById('detail-panel').scrollIntoView({{behavior:'smooth',block:'nearest'}});
}}

function renderDetail(id) {{
  var d = DATA[id];
  if (!d) return;
  document.getElementById('dp-title').textContent = d.name;
  document.getElementById('dp-sub').textContent   = d.subtitle || '';

  var cc  = COLOR_CSS[d.color] || 'c-blue';
  var tags = '';
  (d.etb_domains||[]).forEach(function(dm){{tags += '<span class="dom-tag">'+dm+'</span>';}});
  if (d.status) tags += '<span class="rtg-tag '+cc+'">'+statusLabel(d.status)+'</span>';
  if (d.priority) tags += '<span class="rtg-tag c-muted">Prioridad #'+d.priority+'</span>';
  document.getElementById('dp-tags').innerHTML = tags;

  var gapHtml = '';
  if (d.gap) {{
    var gcls = d.status === 'partial-critical' ? 'gap-alert critical' : 'gap-alert';
    gapHtml = '<div class="'+gcls+'">&#9888; '+d.gap+'</div>';
  }}
  document.getElementById('gap-alert-container').innerHTML = gapHtml;

  var sisHtml = '';
  if (d.sistemas && d.sistemas.length > 0) {{
    var sisTags = d.sistemas.map(function(s){{
      var scls = (s.indexOf('???')>=0 || s.indexOf('DATO')>=0) ? 'sis-tag unknown' : 'sis-tag';
      return '<span class="'+scls+'">'+s+'</span>';
    }}).join('');
    sisHtml = '<div class="sistemas-row"><strong>Sistemas</strong>'+sisTags+'</div>';
  }}
  document.getElementById('sistemas-container').innerHTML = sisHtml;

  var grid = '';
  (d.l2||[]).forEach(function(l2){{
    var cntStr = l2.count > 0 ? l2.count+' cap.' : '&mdash;';
    grid += '<div class="dp-l2-card">'
          + '<div class="dp-l2-name">'+l2.name+'</div>'
          + '<div class="dp-l2-cnt">'+cntStr+'</div>'
          + '</div>';
  }});
  document.getElementById('dp-l2-grid').innerHTML = grid;
}}

function statusLabel(s) {{
  var m = {{
    'partial':'PARTIAL',
    'partial-critical':'PARTIAL &mdash; &#9888; GAP CR&Iacute;TICO',
    'scaffold':'DATO REQUERIDO',
    'confirmed':'CONFIRMED'
  }};
  return m[s] || s;
}}

function cycleClass(e, id) {{
  e.stopPropagation();
  var blk = document.getElementById(id);
  var cur  = blk.dataset.cls || 'P';
  var next = CLS_CYCLE[(CLS_CYCLE.indexOf(cur)+1) % CLS_CYCLE.length];
  blk.dataset.cls = next;
  var btn = e.currentTarget;
  btn.textContent = CLS_LABELS[next];
  btn.className   = 'cls-pill ' + CLS_CSS[next];
}}
</script>
</body></html>"""


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    stats = {"systems": 8, "pain_points": 33, "process_steps": 541, "etb_caps": 14}
    if DB.exists():
        try:
            conn = sqlite3.connect(DB)
            stats = get_stats(conn)
            conn.close()
        except Exception as e:
            print(f"[warn] DB read error: {e} — using defaults")

    html = build_html(stats, TODAY)
    OUT.write_text(html, encoding="utf-8")
    size = OUT.stat().st_size // 1024
    print(f"[ok] {OUT} ({size} KB)")
    print(f"     KPIs: {stats['process_steps']} pasos · {stats['pain_points']} pain points · {stats['systems']} sistemas")


if __name__ == "__main__":
    main()
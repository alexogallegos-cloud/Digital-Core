#!/usr/bin/env python3
"""
build-portal.py — Liverpool Brain Portal Generator
SPE-AM-003 · High Velocity Modernization

Lee liverpool-brain.db y genera liverpool-brain/portal/index.html.
Fuente de verdad = DB. Nunca editar el HTML generado a mano.

Ejecutar desde liverpool-brain/:
    python generators/build-portal.py
"""

import sqlite3
import json
import base64
from pathlib import Path
from datetime import date
import _brain_context

BASE_DIR  = Path(__file__).parent.parent
DB_PATH   = BASE_DIR / "liverpool-brain.db"
OUT_PATH  = BASE_DIR / "portal" / "index.html"
LOGO_PATH = "Liverpool_logo.png"

DOMAIN_ICONS = {
    "R01": "🏷️", "R02": "👤", "R03": "💳", "R04": "📦",
    "R05": "🌐", "R06": "🏪", "R07": "📊", "R08": "👥",
    "R09": "🔍", "R10": "⚙️",
}

DOMAIN_NAMES = {
    "R01": "Gestión Comercial",
    "R02": "Clientes y Lealtad",
    "R03": "Servicios Financieros",
    "R04": "Supply Chain",
    "R05": "Canales Digitales",
    "R06": "Operaciones Tienda",
    "R07": "Finanzas",
    "R08": "Recursos Humanos",
    "R09": "Analítica e BI",
    "R10": "Infraestructura",
}

# Mapeo L1 RTL → dominios de cobertura (inferido del ETB)
RTL_DOMAIN_MAP = {
    1: ["R05"],           # Interaction Channels
    2: ["R02"],           # Engagement & Marketing  (GAP — 0 comps inventariados)
    3: ["R01", "R05", "R06"],  # Unified Commerce
    4: ["R01"],           # Market & Product Development
    5: ["R01"],           # Merchandizing
    6: ["R04"],           # Supply Chain
    7: ["R07", "R08"],    # Enterprise Foundation
    8: ["R09", "R10"],    # Information Foundation
    9: ["R09"],           # Insights & Analytics
}

# Todos los grupos FSV cubren R03
FSV_DOMAIN_MAP = {i: ["R03"] for i in range(1, 7)}

DOMAIN_COMPLEXITY = {
    "R01": "ok", "R02": "ok", "R03": "warn", "R04": "warn",
    "R05": "warn", "R06": "ok", "R07": "ok", "R08": "ok",
    "R09": "ok", "R10": "ok",
}

DT_DATA = [
    {
        "id": "dt-inteligencia-cliente",
        "name": "Inteligencia de Cliente",
        "desc": "Customer 360, CDP-GCP, Liverpool Premia y segmentación predictiva. Estado activo con datos reales.",
        "domain": "R02",
        "state": "ACTIVO",
        "icon": "🧠",
        "cls": "ok",
    },
    {
        "id": "dt-liverpoolcard",
        "name": "LiverpoolCard",
        "desc": "Servicios financieros: crédito, autorización Base24, cobranza, FICO TRIAD y regulación Banxico/CONDUSEF.",
        "domain": "R03",
        "state": "SCAFFOLD",
        "icon": "💳",
        "cls": "warn",
    },
    {
        "id": "dt-pedido-omnicanal",
        "name": "Pedido Omnicanal",
        "desc": "Sterling OMS con 96.69% de órdenes pendientes. Click and Deliver, Click and Collect y Ship from Store.",
        "domain": "R04",
        "state": "SCAFFOLD",
        "icon": "📦",
        "cls": "crit",
    },
    {
        "id": "dt-catalogo-producto",
        "name": "Catálogo de Producto",
        "desc": "PIM-STEP como master. Prerequisito crítico para la migración a commercetools.",
        "domain": "R01",
        "state": "SCAFFOLD",
        "icon": "🏷️",
        "cls": "warn",
    },
    {
        "id": "dt-bus-integracion",
        "name": "Bus de Integración",
        "desc": "IBM IIB y Tumbleweed como espina dorsal. Mapa de riesgo: cualquier migración pasa por aquí.",
        "domain": "R10",
        "state": "SCAFFOLD",
        "icon": "🔗",
        "cls": "crit",
    },
    {
        "id": "dt-sap-doble-landscape",
        "name": "SAP Doble Landscape",
        "desc": "ECC LIV on-prem vs S/4HANA SBB en Azure. 56 servicios, el DT más complejo del programa.",
        "domain": "R01",
        "state": "SCAFFOLD",
        "icon": "🏗️",
        "cls": "warn",
    },
    {
        "id": "dt-ecommerce-transicion",
        "name": "eCommerce Transición",
        "desc": "ATG más Endeca hacia commercetools. Señal: selección anunciada el 5 de noviembre de 2025.",
        "domain": "R05",
        "state": "SCAFFOLD",
        "icon": "🛒",
        "cls": "warn",
    },
]

SISTEMAS_DATA = [
    {
        "name": "SAP (ECC LIV / S/4 SBB)",
        "desc": "56 servicios en dos landscapes paralelos: SAP ECC on-prem para Liverpool y S/4HANA en Azure para Suburbia.",
        "icon": "🏗️",
        "tags": ["SAP ECC", "S/4HANA", "EWM", "HCM", "BW"],
        "cls": "warn",
        "state": "BASELINE",
    },
    {
        "name": "Oracle PL-SQL / Mainframe",
        "desc": "Backend de LiverpoolCard: VPL Vision Plus, FICO TRIAD, Base24 y procesos batch de cobranza.",
        "icon": "💾",
        "tags": ["Oracle", "Mainframe", "FICO TRIAD", "Base24"],
        "cls": "crit",
        "state": "BASELINE",
    },
    {
        "name": "Sterling OMS",
        "desc": "Orquestador de pedidos omnicanal. Señal de deuda: 96.69% de órdenes en estado pendiente.",
        "icon": "📦",
        "tags": ["OMS", "Click&Collect", "Ship from Store"],
        "cls": "crit",
        "state": "BASELINE",
    },
    {
        "name": "ATG-Endeca (eCommerce)",
        "desc": "Motor eCommerce AS-IS de liverpool.com.mx y suburbia.com. Destino 7R: Repurchase hacia commercetools.",
        "icon": "🌐",
        "tags": ["ATG", "Endeca", "Oracle Commerce"],
        "cls": "warn",
        "state": "TRANSITIONAL",
    },
    {
        "name": "IBM IIB / Tumbleweed",
        "desc": "Bus de integración central. Espina dorsal de las integraciones ATG, SAP y OMS. Riesgo blast-radius alto.",
        "icon": "🔗",
        "tags": ["IIB", "Tumbleweed", "ESB"],
        "cls": "crit",
        "state": "BASELINE",
    },
    {
        "name": "Digital-Platform (GCP)",
        "desc": "Plataforma cloud-native en GCP. Landing zone futura de commercetools y CDP para agentic commerce.",
        "icon": "☁️",
        "tags": ["GCP", "CDP", "Apigee", "commercetools"],
        "cls": "ok",
        "state": "TRANSITIONAL",
    },
]

SENALES_DATA = [
    {
        "kick": "Señal estratégica — nov 2025",
        "title": "commercetools seleccionado",
        "sub": "Liverpool anuncia migración del eCommerce",
        "desc": "El <b>5 de noviembre de 2025</b> Liverpool anunció la selección de commercetools para habilitar agentic commerce con AI Hub y Agent Gateway. La migración desde ATG está en etapas iniciales.",
    },
    {
        "kick": "Deuda operativa — OMS",
        "title": "96.69% órdenes pendientes",
        "sub": "Sterling OMS — riesgo omnicanal crítico",
        "desc": "El <b>96.69%</b> de las órdenes en Sterling OMS están en estado pendiente. Este bloqueador afecta directamente el timeline de la migración a commercetools y la experiencia omnicanal.",
    },
    {
        "kick": "Señal regulatoria — Banxico",
        "title": "Migración Cyberfinancial v8.4 → v9C",
        "sub": "LiverpoolCard — Servicios Financieros",
        "desc": "El sistema de conciliación de pagos <b>Cyberfinancial</b> está en proceso de migración de versión, con implicaciones regulatorias para los acuerdos de pago y la reportería Banxico.",
    },
    {
        "kick": "Arquitectura ERP — SAP",
        "title": "Doble landscape SAP",
        "sub": "ECC LIV on-prem vs S/4HANA SBB Azure",
        "desc": "<b>56 servicios SAP</b> distribuidos en dos landscapes paralelos. SBB ya migró a S/4HANA en Azure; LIV sigue en ECC on-prem. La estrategia brownfield vs greenfield está pendiente de definir.",
    },
]


def css() -> str:
    return """*{box-sizing:border-box;margin:0;padding:0}
:root{
  --cerise:#E00198;--cerise-d:#b5007a;--cerise-dd:#850059;
  --sky:#87C3D3;--sky-l:#96CCEE;--rose:#DA7AB0;
  --ink:#F8F0F5;--muted:#c4a8bc;--muted2:#9a7d92;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)
}
html{scroll-behavior:smooth}
body{background:#0d0408;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before,.aurora::after,.aurora .blob{content:"";position:absolute;border-radius:50%;filter:blur(90px)}
.aurora::before{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(224,1,152,.55),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(135,195,211,.38),transparent 70%);animation:f2 28s ease-in-out infinite}
.aurora .blob{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(218,122,176,.18),transparent 70%);animation:f3 32s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.15)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.12)}}
@keyframes f3{50%{transform:translate(-9vw,-9vh) scale(1.22)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;background:linear-gradient(90deg,var(--cerise),#fff);box-shadow:0 0 12px rgba(224,1,152,.6)}
nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:15px 30px;backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);background:rgba(13,4,8,.55);border-bottom:1px solid rgba(255,255,255,.06)}
nav img{height:21px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
nav .nt{font-size:12.5px;font-weight:600;color:var(--muted);letter-spacing:.01em}
nav .sp{flex:1}
nav a.jump{font-size:12.5px;color:var(--muted);padding:7px 13px;border-radius:20px;transition:.22s;text-decoration:none}
nav a.jump:hover{color:var(--ink);background:rgba(255,255,255,.07)}
nav a.jump.ext{color:var(--cerise)}
nav a.jump.ext:hover{color:#fff}
.glass{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}
.wrap{max-width:1160px;margin:0 auto;padding:0 30px}
section{padding:76px 0;scroll-margin-top:70px}
.hero{min-height:56vh;display:flex;flex-direction:column;justify-content:center;position:relative;padding:110px 0 20px}
.eyebrow{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;padding:8px 16px;border-radius:30px;font-size:12px;font-weight:600;letter-spacing:.03em;color:#f0dce8;margin-bottom:28px;background:rgba(255,255,255,.05);border:1px solid var(--glassb);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}
.eyebrow .dot{width:7px;height:7px;border-radius:50%;background:var(--cerise);box-shadow:0 0 12px var(--cerise);animation:pulse 2.4s infinite}
@keyframes pulse{50%{opacity:.4}}
.hero h1{font-size:clamp(38px,6vw,76px);font-weight:800;line-height:1.0;letter-spacing:-.035em;max-width:20ch;background:linear-gradient(176deg,#fff 34%,#e8b0d4);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero .sub{font-size:clamp(15px,1.7vw,19px);color:var(--muted);margin-top:22px;max-width:66ch;line-height:1.55}
.hero .sub b{color:#f0dce8;font-weight:600}
.stats{display:grid;grid-template-columns:repeat(5,1fr);gap:13px;margin-top:36px}
.stat{padding:20px 14px;text-align:center}
.statn{font-size:clamp(22px,2.7vw,32px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;background:linear-gradient(180deg,#fff,#e8b0d4);-webkit-background-clip:text;background-clip:text;color:transparent}
.statl{font-size:10px;color:var(--muted2);margin-top:8px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}
.shead{margin-bottom:36px}
.kick{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--cerise);margin-bottom:14px}
.shead h2{font-size:clamp(26px,3.8vw,42px);font-weight:800;letter-spacing:-.025em;line-height:1.06}
.shead p{color:var(--muted);font-size:15px;margin-top:14px;max-width:72ch;line-height:1.55}
.cardgrid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
@media(max-width:960px){.cardgrid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:600px){.cardgrid{grid-template-columns:1fr}}
.group{margin-top:44px}
.ghead{display:flex;align-items:baseline;gap:14px;margin-bottom:18px}
.ghead h3{font-size:19px;font-weight:800;letter-spacing:-.02em}
.ghead .gn{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--cerise);background:rgba(224,1,152,.1);border:1px solid rgba(224,1,152,.28);border-radius:20px;padding:3px 10px}
.ghead span{font-size:13px;color:var(--muted2)}
.vcard{display:flex;gap:17px;padding:23px;color:inherit;text-decoration:none;transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s}
.vcard:hover{transform:translateY(-6px);border-color:rgba(224,1,152,.42);box-shadow:0 22px 56px rgba(0,0,0,.5)}
.vcard .ico{font-size:25px;width:54px;height:54px;display:flex;align-items:center;justify-content:center;border-radius:16px;flex-shrink:0;background:linear-gradient(150deg,rgba(255,255,255,.13),rgba(255,255,255,.02));border:1px solid rgba(255,255,255,.11);transition:transform .34s}
.vcard:hover .ico{transform:scale(1.09) rotate(-4deg)}
.vcard .vt{font-size:16.5px;font-weight:800;letter-spacing:-.01em}
.vcard .vd{font-size:13px;color:var(--muted);margin:6px 0 13px;line-height:1.55}
.vcard .go{font-size:12px;font-weight:700;color:var(--cerise);display:inline-flex;align-items:center;gap:7px}
.vcard .arr{transition:transform .3s}.vcard:hover .arr{transform:translateX(5px)}
.vcard .vtag{display:inline-block;font-size:9.5px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;padding:2px 7px;border-radius:10px;background:rgba(224,1,152,.12);border:1px solid rgba(224,1,152,.25);color:var(--cerise);margin-bottom:8px}
.vcard.crit{border-left:3px solid #E8400A}.vcard.crit .ico{background:rgba(232,64,10,.15);border-color:rgba(232,64,10,.3)}
.vcard.warn{border-left:3px solid var(--cerise)}.vcard.warn .ico{background:rgba(224,1,152,.12);border-color:rgba(224,1,152,.3)}
.vcard.ok{border-left:3px solid var(--sky)}.vcard.ok .ico{background:rgba(135,195,211,.12);border-color:rgba(135,195,211,.3)}
.vtag.crit{color:#E8400A;background:rgba(232,64,10,.12);border-color:rgba(232,64,10,.3)}
.vtag.warn{color:var(--cerise);background:rgba(224,1,152,.08);border-color:rgba(224,1,152,.25)}
.vtag.sky{color:var(--sky);background:rgba(135,195,211,.08);border-color:rgba(135,195,211,.25)}
.mgrid{display:grid;grid-template-columns:1fr 1fr;gap:15px}
@media(max-width:860px){.mgrid{grid-template-columns:1fr}}
.mcard{padding:24px 26px}
.mcard h4{font-size:12px;color:var(--cerise);text-transform:uppercase;letter-spacing:.09em;margin-bottom:10px;font-weight:700}
.mcard p{font-size:13.5px;color:var(--muted);line-height:1.6}.mcard b{color:#fff;font-weight:600}
.mcard .big{font-size:28px;font-weight:800;color:#fff;margin:8px 0 4px;letter-spacing:-.02em}
.xrow{display:grid;grid-template-columns:1fr 1fr;gap:15px}
@media(max-width:760px){.xrow{grid-template-columns:1fr}}
.xcard{padding:20px 24px;border-left:3px solid var(--cerise)}
.xkick{font-size:10px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;color:var(--cerise);margin-bottom:10px}
.xt{font-size:16px;font-weight:800}.xt span{font-size:13px;font-weight:600;color:var(--muted)}
.xd{font-size:12.5px;color:var(--muted);margin-top:7px;line-height:1.6}.xd b{color:#f0dce8;font-weight:600}
.chip{display:inline-block;font-size:10px;font-weight:700;padding:3px 9px;border-radius:12px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.06);color:var(--muted);margin:3px 3px 0 0;letter-spacing:.04em}
.chip.cerise{border-color:rgba(224,1,152,.35);color:var(--cerise);background:rgba(224,1,152,.09)}
.chip.sky{border-color:rgba(135,195,211,.35);color:var(--sky);background:rgba(135,195,211,.09)}
.chip.red{border-color:rgba(232,64,10,.35);color:#f87171;background:rgba(232,64,10,.10)}
.divider{border:none;border-top:1px solid rgba(255,255,255,.06);margin:0}
/* ── ETB Coverage Strip ── */
.etb-strip-section{margin:28px 0}
.etb-strip-label{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;margin-bottom:8px;display:flex;align-items:center;gap:10px}
.etb-strip-label.rtl-lbl{color:var(--sky)}
.etb-strip-label.fsv-lbl{color:var(--cerise)}
.etb-strip-label span{font-size:10px;color:var(--muted2);font-weight:400;letter-spacing:0;text-transform:none}
.etb-strip-row{display:flex;height:52px;border-radius:12px;overflow:hidden;gap:2px;margin-bottom:6px}
.etb-strip-seg{display:flex;align-items:center;justify-content:center;font-size:9px;font-weight:800;letter-spacing:.04em;color:rgba(255,255,255,.85);min-width:22px;cursor:default;transition:filter .22s,transform .22s;position:relative;overflow:hidden}
.etb-strip-seg:hover{filter:brightness(1.3);z-index:2}
.etb-strip-seg .seg-label{writing-mode:horizontal-tb;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;padding:0 5px;max-width:100%}
.rtl-seg{background:linear-gradient(180deg,rgba(150,204,238,.60),rgba(135,195,211,.38))}
.rtl-seg.hi{background:linear-gradient(180deg,rgba(150,204,238,.90),rgba(135,195,211,.70))}
.fsv-seg{background:linear-gradient(180deg,rgba(224,1,152,.65),rgba(181,0,122,.45))}
.gap-seg{background:rgba(232,64,10,.22);border:1px dashed rgba(232,64,10,.35)}
/* ── ETB Summary boxes ── */
.etb-sum-row{display:flex;gap:12px;flex-wrap:wrap;margin-top:24px}
.etb-sum-box{flex:1;min-width:130px;padding:16px 18px;text-align:center}
.etb-sum-n{font-size:24px;font-weight:800;letter-spacing:-.02em}
.etb-sum-l{font-size:10px;color:var(--muted2);text-transform:uppercase;letter-spacing:.06em;margin-top:4px}
/* ── ETB Capacity cards ── */
.etb-cap-section{margin-top:32px}
.etb-cap-section-head{display:flex;align-items:center;gap:12px;margin-bottom:18px;padding-bottom:14px;border-bottom:1px solid rgba(255,255,255,.06)}
.etb-badge{font-size:10px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;padding:4px 12px;border-radius:20px}
.etb-badge.rtl{background:rgba(135,195,211,.15);border:1px solid rgba(135,195,211,.3);color:var(--sky)}
.etb-badge.fsv{background:rgba(224,1,152,.12);border:1px solid rgba(224,1,152,.3);color:var(--cerise)}
.etb-cap-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
@media(max-width:900px){.etb-cap-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:560px){.etb-cap-grid{grid-template-columns:1fr}}
.etb-cap-card{padding:22px 18px 18px;text-align:center;transition:transform .3s,border-color .3s}
.etb-cap-card:hover{transform:translateY(-5px)}
.etb-cap-card.rtl-card:hover{border-color:rgba(135,195,211,.4)}
.etb-cap-card.fsv-card:hover{border-color:rgba(224,1,152,.4)}
.etb-cap-card.gap-card{border-color:rgba(232,64,10,.22)}
.etb-donut-wrap{position:relative;width:96px;height:96px;margin:0 auto 14px}
.etb-donut-inner{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;pointer-events:none}
.etb-donut-num{font-size:22px;font-weight:800;letter-spacing:-.03em;line-height:1}
.etb-donut-sub{font-size:9px;color:var(--muted2);margin-top:2px;letter-spacing:.04em;text-transform:uppercase}
.etb-cap-code{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;margin-bottom:5px}
.etb-cap-code.rtl-c{color:var(--sky)}
.etb-cap-code.fsv-c{color:var(--cerise)}
.etb-cap-code.gap-c{color:#f87171}
.etb-cap-name{font-size:13px;font-weight:700;line-height:1.3;margin-bottom:9px}
.etb-cap-doms{display:flex;flex-wrap:wrap;gap:4px;justify-content:center;margin-bottom:9px}
.etb-dom-chip{font-size:9px;font-weight:700;padding:2px 7px;border-radius:8px;letter-spacing:.04em}
.etb-dom-chip.rtl-dom{background:rgba(135,195,211,.10);border:1px solid rgba(135,195,211,.22);color:var(--sky)}
.etb-dom-chip.fsv-dom{background:rgba(224,1,152,.08);border:1px solid rgba(224,1,152,.22);color:var(--cerise)}
.etb-dom-chip.gap-dom{background:rgba(232,64,10,.08);border:1px solid rgba(232,64,10,.22);color:#f87171}
.etb-cap-comps{font-size:10px;color:var(--muted2)}
.etb-cap-comps.gap-comps{color:#f87171;font-weight:700}
.reveal{opacity:0;transform:translateY(32px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}
.reveal.in{opacity:1;transform:none}
.dom-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px}
@media(max-width:960px){.dom-grid{grid-template-columns:repeat(3,1fr)}}
@media(max-width:600px){.dom-grid{grid-template-columns:repeat(2,1fr)}}
.dom-card{padding:16px 14px;text-align:center;cursor:default;transition:transform .3s,border-color .3s}
.dom-card:hover{transform:translateY(-4px);border-color:rgba(224,1,152,.35)}
.dom-card .dom-ico{font-size:22px;margin-bottom:10px}
.dom-card .dom-id{font-size:9px;font-weight:700;letter-spacing:.14em;text-transform:uppercase;color:var(--cerise);margin-bottom:6px}
.dom-card .dom-name{font-size:13px;font-weight:700;line-height:1.3}
.dom-card .dom-n{font-size:11px;color:var(--muted2);margin-top:5px}
.dom-card.warn-dom{border-color:rgba(224,1,152,.3)}
.dom-card.crit-dom{border-color:rgba(232,64,10,.3)}
footer{padding:44px 30px 64px;text-align:center;color:var(--muted2);font-size:12px;border-top:1px solid rgba(255,255,255,.06);margin-top:50px;line-height:1.7}
footer code{color:var(--muted);background:rgba(224,1,152,.10);border:1px solid rgba(224,1,152,.25);border-radius:5px;padding:1px 6px;font-size:11px;font-family:'SF Mono',ui-monospace,monospace}
@media(max-width:1100px){.stats{grid-template-columns:repeat(3,1fr)}}
@media(max-width:680px){.stats{grid-template-columns:repeat(2,1fr)}}
@media(max-width:560px){nav .nt{display:none}}
@media(prefers-reduced-motion:reduce){.reveal{transition:none;opacity:1;transform:none}.aurora *{animation:none}}"""


def _meta(fname: str) -> dict:
    """Lee el bloque meta de un JSON en portal/data/ (best-effort)."""
    p = BASE_DIR / "portal" / "data" / fname
    if not p.exists():
        return {}
    try:
        return json.loads(p.read_text(encoding="utf-8")).get("meta", {})
    except Exception:
        return {}


def _coverage_stats(conn) -> dict:
    """Cifras de cobertura ETB y carga operativa AMS, si ya fueron cargadas."""
    d = {}
    try:
        d["cov_pct"] = conn.execute("""SELECT CAST(ROUND(100.0*(
                SUM(CASE WHEN liverpool_status='COVERED' THEN 1 ELSE 0 END)
              + SUM(CASE WHEN liverpool_status='PARTIAL' THEN 1 ELSE 0 END)*0.5
            )/COUNT(*)) AS INT) FROM rtb_l3""").fetchone()[0]
        d["cov_gap"] = conn.execute(
            "SELECT COUNT(*) FROM rtb_l3 WHERE liverpool_status='NOT_COVERED'").fetchone()[0]
    except sqlite3.OperationalError:
        pass
    try:
        d["tickets"] = conn.execute("SELECT COUNT(*) FROM ticket_corpus").fetchone()[0]
        d["ams_gaps"] = conn.execute(
            "SELECT COUNT(*) FROM ams_group_component WHERE mapping='gap'").fetchone()[0]
        d["ams_apps"] = conn.execute("SELECT COUNT(*) FROM app_operational_load").fetchone()[0]
    except sqlite3.OperationalError:
        pass
    try:
        d["critical_processes"] = conn.execute("SELECT COUNT(*) FROM critical_processes").fetchone()[0]
        d["ams_yearly_groups"]  = conn.execute("SELECT COUNT(DISTINCT group_name) FROM ams_yearly").fetchone()[0]
    except sqlite3.OperationalError:
        pass
    try:
        d["ams_applications"]   = conn.execute("SELECT COUNT(*) FROM ams_applications").fetchone()[0]
        d["ams_in_scope"]       = conn.execute("SELECT COUNT(*) FROM ams_applications WHERE in_scope_apigee=1").fetchone()[0]
        d["ams_new"]            = conn.execute("SELECT COUNT(*) FROM ams_applications WHERE is_new=1").fetchone()[0]
    except sqlite3.OperationalError:
        pass
    return d


def views_section(conn) -> str:
    """Sección 'Vistas disponibles' — catálogo navegable de todas las vistas
    generadas del portal, agrupadas por propósito (modelo BanCoppel index-v2)."""
    cs = _coverage_stats(conn)
    r  = _meta("rules-bronze-liv.json")
    i  = _meta("interfaces-liv.json")
    t  = _meta("table-lineage-liv.json")
    m  = _meta("program-metrics-liv.json")
    su = _meta("sud-catalog-liv.json")
    su_sys, su_srv, su_if = su.get("systems", 54), su.get("servers", 170), su.get("interfaces", 209)

    n_rules = r.get("total", 169)
    bt      = r.get("by_tipo", {})
    n_for, n_val = bt.get("FÓRMULA", 66), bt.get("VALIDACIÓN", 87)
    n_if    = i.get("interfaces", 80)
    if_call = i.get("calls", 150)
    if_s4   = i.get("s4_risk", 34)
    n_tab   = t.get("tables", 80)
    tab_z   = t.get("z", 41)
    tab_s4  = t.get("s4", 12)
    n_prog  = m.get("programs", 12)
    n_dep   = m.get("dep_edges", 23)

    GROUPS = [
        ("01", "Landscape aplicativo · Sistemas",
         "El inventario real de aplicaciones del landscape Liverpool, destilado de los SUDs (documentos de toma de control AMS) con un agent swarm.", [
            ("systems-catalog-liv.html", "🗂️", f"{su_sys} sistemas · SUD",
             "Catálogo de Sistemas",
             f"{su_sys} aplicaciones con propósito, {su_srv} servidores, bases de datos, {su_if} interfaces, dependencias y riesgos reales. Agrupadas por dominio, con filtros y drill-down por sistema."),
            ("mapa-capacidades.html", "🧩", "Retail + FS ETB",
             "Mapa de Capacidades",
             "282 capacidades L3 (232 RTL + 50 FSV) mapeadas a los dominios R01–R10, con cobertura del inventario Liverpool. Drill-down por grupo L1."),
            ("cadena-valor.html", "🔗", "Value Chain",
             "Cadena de Valor",
             "9 bloques de cadena de valor (VC-01…09) con clasificación S/E/P y el conteo de capacidades que cubre cada eslabón del negocio retail."),
            ("capability-coverage-liv.html", "🎚️", f"{cs.get('cov_pct', 46)}% cobertura",
             "Cobertura ETB",
             f"Las 282 capacidades del blueprint contrastadas una a una contra las aplicaciones reales, con estado, sistema dueño, confianza y sustento. {cs.get('cov_gap', 97)} capacidades no tienen aplicación que las soporte."),
        ]),
        ("02", "Arquitectura del landscape SAP",
         "La estructura del stack SAP AS-IS del Módulo de Importaciones — de la arquitectura de sistemas a la descomposición modular R/3.", [
            ("sap-architecture.html", "🏛️", "AS-IS · ZIM Imports",
             "Arquitectura SAP",
             "Arquitectura AS-IS del Módulo de Importaciones ZIM/ZRT — sistemas, flujos y touchpoints de los 12 programas ABAP en el landscape SAP ECC."),
            ("sap-modular.html", "🧱", "R/3 Modular",
             "Estructura Modular SAP",
             "Descomposición modular estilo R/3 de los 12 programas ABAP del Módulo de Importaciones, con vendors y dependencias de módulo."),
        ]),
        ("03", "Corpus ABAP · Conocimiento extraído",
         "El lenguaje y las reglas del sistema, destilados directamente del código fuente de los 12 programas ABAP.", [
            ("rules-catalog-liv.html", "⚖️", "Bronze · 169 reglas",
             "Reglas de Negocio",
             f"{n_rules} reglas extraídas del código ABAP ({n_for} fórmulas · {n_val} validaciones) con nombre de negocio inferido, dominio, regulación y tipo. Agrupadas por programa."),
            ("vocabulary-catalog-liv.html", "📖", "155 términos",
             "Vocabulario Empresarial",
             "Léxico canónico del corpus AS-IS — 155 términos de 13 DTs y 12 programas ABAP, con significado, nivel de confianza y dominio. Fuente de verdad del business_name."),
            ("evolution-liv.html", "🌳", "Ejemplo · Biografía",
             "Evolución del Código",
             "Las 'vetas del árbol': streamgraph del crecimiento año por año y por dominio, con hitos. Vista de ejemplo con datos reales del core Informix de BanCoppel — se reemplaza por el change history de Liverpool cuando esté disponible."),
        ]),
        ("04", "Interfaces y datos · Simplification S/4HANA",
         "Las dos fronteras que gobiernan la migración SAP ECC → S/4HANA: las interfaces que rompe y las tablas cuyo modelo de datos cambia.", [
            ("interfaces-map-liv.html", "🔌", "RFC/BAPI · Chord",
             "Mapa de Interfaces RFC/BAPI",
             f"{n_if} interfaces / {if_call} llamadas CALL FUNCTION clasificadas por categoría, cruzadas por programa. {if_s4} con riesgo S/4HANA (BAPI · Z-custom · RFC)."),
            ("table-lineage-liv.html", "🗃️", "Data-Lineage",
             "Data-Lineage de Tablas SAP",
             f"{n_tab} tablas ({tab_z} Z-custom) con accesos R/W por programa. {tab_s4} con Simplification Item S/4HANA (ACDOCA · MATDOC · Business Partner)."),
        ]),
        ("05", "Assessment de Migración 7R",
         "El insumo de la decisión 7R por programa: complejidad objetiva, orden de ataque y acoplamiento entre programas.", [
            ("migration-complexity-liv.html", "🎯", "Score compuesto",
             "Complejidad de Migración",
             f"Score por programa desde tamaño, estructura, UI, validación, datos e integración, con hipótesis 7R. {n_prog} programas del Módulo de Importaciones."),
            ("priority-ranking-liv.html", "🥇", "Backlog 7R",
             "Ranking de Prioridad",
             "Orden de ataque: prioridad = complejidad + regulatorio + fan-in + Simplification S/4. Backlog con drivers y fundamento 7R por programa."),
            ("dependency-graph-liv.html", "🕸️", "Acoplamiento",
             "Grafo de Dependencias",
             f"Matriz programa×programa con {n_dep} dependencias vía tablas Z compartidas (write→read). Revela los clústeres que deben migrar juntos."),
        ]),
        ("06", "Operación real · Tickets AMS",
         "La evidencia de cómo se comporta el landscape en producción, tomada del análisis de tickets de GenWizard y cruzada contra el catálogo de aplicaciones y la cadena de valor ETB.", [
            ("ams-tickets-liv.html", "🎫", f"{cs.get('tickets', 40056):,} tickets".replace(",", ","),
             "Carga Operativa AMS",
             f"Volumen de incidentes y requerimientos por aplicación, con recurrentes, prioridad y percentil noventa de atención. {cs.get('ams_apps', 50)} aplicaciones con carga medida y {cs.get('ams_gaps', 14)} grupos de soporte que operan sobre sistemas ausentes del inventario."),
            ("cadena-valor-tickets-liv.html", "📊", f"{cs.get('ams_yearly_groups', 87)} grupos · 2024-2026",
             "Cadena de Valor y Tickets",
             "Carga operativa cruzada con los eslabones ETB. Tendencia anual 2024-2026, SLA real por eslabón (mediana y P90 ponderado), alertas de grupos con P90 superior a 500h y tabla completa filtrable por eslabón."),
            ("procesos-criticos-liv.html", "🔄", f"{cs.get('critical_processes', 43)} flujos documentados",
             "Procesos Críticos",
             "43 procesos de negocio levantados (Mural) mapeados al ETB y a sistemas del landscape. Incluye sistemas nuevos descubiertos por Regla B8: VCM, SIBO, Exstream, VAS, App Pocket."),
            ("ams-applications-liv.html", "📋", f"{cs.get('ams_applications', 78)} apps · {cs.get('ams_in_scope', 7)} Apigee/BTP",
             "Catálogo AMS",
             f"Catálogo oficial de las {cs.get('ams_applications', 78)} aplicaciones bajo soporte AMS de Liverpool, mapeadas a los 7 dominios de negocio y a los eslabones ETB. Incluye flag de integración Apigee/BTP y renombramientos oficiales (ACC←CXEC, PEGA←FICO APM)."),
        ]),
    ]

    groups_html = []
    for gn, title, desc, cards in GROUPS:
        cards_html = "\n".join(
            f"""<a class="vcard glass reveal" href="{href}">
  <div class="ico">{ico}</div>
  <div>
    <div class="vtag">{tag}</div>
    <div class="vt">{vt}</div>
    <div class="vd">{vd}</div>
    <div class="go">Abrir la vista <span class="arr">→</span></div>
  </div>
</a>"""
            for href, ico, tag, vt, vd in cards
        )
        groups_html.append(f"""<div class="group">
  <div class="ghead reveal"><span class="gn">{gn}</span><h3>{title}</h3></div>
  <p style="color:var(--muted);font-size:13.5px;margin:-8px 0 4px;max-width:78ch;line-height:1.55">{desc}</p>
  <div class="cardgrid" style="margin-top:16px">
{cards_html}
  </div>
</div>""")

    return f"""<section id="vistas">
    <div class="shead reveal">
      <div class="kick">Vistas disponibles</div>
      <h2>Dieciocho vistas del Gemelo Cognitivo</h2>
      <p>Cada vista se genera directamente desde el brain, los SUDs, el corpus ABAP y el análisis de tickets — sistemas, capacidades, cobertura del blueprint, reglas, vocabulario, interfaces, lineage de datos, assessment de migración y carga operativa real cruzada con la cadena de valor ETB. Todas comparten el hero con la marca Liverpool.</p>
    </div>
{chr(10).join(groups_html)}
  </section>"""


def domain_cards(conn) -> str:
    rows = conn.execute("""
        SELECT d.id, d.name, d.description,
               COUNT(c.id) n_comp
        FROM retail_domains d
        LEFT JOIN components c ON c.domain_id = d.id
        GROUP BY d.id
        ORDER BY d.id
    """).fetchall()
    parts = []
    for r in rows:
        did, dname, ddesc, n = r
        icon = DOMAIN_ICONS.get(did, "📌")
        cls_d = DOMAIN_COMPLEXITY.get(did, "")
        cls_suffix = f" {cls_d}-dom" if cls_d in ("warn", "crit") else ""
        parts.append(f"""<div class="dom-card glass{cls_suffix}">
  <div class="dom-ico">{icon}</div>
  <div class="dom-id">{did}</div>
  <div class="dom-name">{dname}</div>
  <div class="dom-n">{n} componentes</div>
</div>""")
    return "\n".join(parts)


def dt_cards() -> str:
    parts = []
    for dt in DT_DATA:
        tag_cls = "ok" if dt["state"] == "ACTIVO" else "warn"
        parts.append(f"""<div class="vcard glass {dt['cls']}">
  <div class="ico">{dt['icon']}</div>
  <div>
    <div class="vtag {tag_cls}">{dt['state']}</div>
    <div class="vt">{dt['name']}</div>
    <div class="vd">{dt['desc']}</div>
    <div class="go">Explorar <span class="arr">→</span></div>
  </div>
</div>""")
    return "\n".join(parts)


def cap_cards(conn) -> str:
    rtl_count = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='retail'").fetchone()[0]
    fsv_count = conn.execute("SELECT COUNT(*) FROM rtb_l3 WHERE source_etb='financial_services'").fetchone()[0]

    rtl_groups = conn.execute("""
        SELECT l1_num, l1_name, COUNT(*) n
        FROM rtb_l3 WHERE source_etb='retail'
        GROUP BY l1_num ORDER BY l1_num
    """).fetchall()
    fsv_groups = conn.execute("""
        SELECT l1_num, l1_name, COUNT(*) n
        FROM rtb_l3 WHERE source_etb='financial_services'
        GROUP BY l1_num ORDER BY l1_num
    """).fetchall()

    rtl_rows = "".join(
        f"<p><b>RTL.{g[0]}</b> {g[1]} <span style='float:right;color:var(--sky)'>{g[2]}</span></p>"
        for g in rtl_groups
    )
    fsv_rows = "".join(
        f"<p><b>FSV.{g[0]}</b> {g[1]} <span style='float:right;color:var(--cerise)'>{g[2]}</span></p>"
        for g in fsv_groups
    )

    return f"""<div class="mcard glass">
  <h4>Retail ETB — RTL.x.xx</h4>
  <div class="big">{rtl_count}</div>
  <p style="margin-bottom:14px;font-size:12px">9 grupos L1 · Nomenclatura canónica RTL.{{L1}}.{{seq}}</p>
  <div style="display:flex;flex-direction:column;gap:6px;font-size:12px;color:var(--muted)">{rtl_rows}</div>
</div>
<div class="mcard glass">
  <h4>Financial Services ETB — FSV.x.xx</h4>
  <div class="big">{fsv_count}</div>
  <p style="margin-bottom:14px;font-size:12px">6 grupos L1 · Overlay R03 LiverpoolCard · Banxico, CONDUSEF, PCI-DSS</p>
  <div style="display:flex;flex-direction:column;gap:6px;font-size:12px;color:var(--muted)">{fsv_rows}</div>
</div>"""


def sistema_cards() -> str:
    parts = []
    for s in SISTEMAS_DATA:
        chips = "".join(f'<span class="chip">{t}</span>' for t in s["tags"])
        parts.append(f"""<div class="vcard glass {s['cls']}">
  <div class="ico">{s['icon']}</div>
  <div>
    <div class="vtag">{s['state']}</div>
    <div class="vt">{s['name']}</div>
    <div class="vd">{s['desc']}</div>
    <div>{chips}</div>
  </div>
</div>""")
    return "\n".join(parts)


def senal_cards() -> str:
    parts = []
    for s in SENALES_DATA:
        parts.append(f"""<div class="xcard glass">
  <div class="xkick">{s['kick']}</div>
  <div class="xt">{s['title']} <span>— {s['sub']}</span></div>
  <div class="xd">{s['desc']}</div>
</div>""")
    return "\n".join(parts)


def etb_section(conn) -> str:
    import re
    CIRC = 213.63  # 2*pi*34

    comp_by_dom = {r[0]: r[1] for r in conn.execute(
        "SELECT domain_id, COUNT(*) FROM components GROUP BY domain_id"
    )}
    total_comps = sum(comp_by_dom.values()) or 1

    rtl_groups = {r[0]: (r[1], r[2]) for r in conn.execute(
        "SELECT l1_num, l1_name, COUNT(*) FROM rtb_l3 WHERE source_etb='retail' GROUP BY l1_num ORDER BY l1_num"
    )}
    fsv_groups = {r[0]: (r[1], r[2]) for r in conn.execute(
        "SELECT l1_num, l1_name, COUNT(*) FROM rtb_l3 WHERE source_etb='financial_services' GROUP BY l1_num ORDER BY l1_num"
    )}

    rtl_cap_total = sum(v[1] for v in rtl_groups.values())
    fsv_cap_total = sum(v[1] for v in fsv_groups.values())
    grand_total   = rtl_cap_total + fsv_cap_total
    gap_domains   = [d for d in ["R01","R02","R03","R04","R05","R06","R07","R08","R09","R10"]
                     if comp_by_dom.get(d, 0) == 0]
    covered_domains = 10 - len(gap_domains)

    def clean(name):
        return re.sub(r"^\d+\.\s*", "", name).strip()

    def dom_chips(domains, kind):
        return "".join(
            f'<span class="etb-dom-chip {"gap-dom" if comp_by_dom.get(d,0)==0 else kind+"-dom"}">{d}</span>'
            for d in domains
        )

    def donut_svg(ncaps, comps, color, gap=False):
        pct = comps / total_comps * 100
        fill = round(pct / 100 * CIRC, 2)
        stroke = "#f87171" if gap else color
        track = "rgba(232,64,10,.18)" if gap else "rgba(255,255,255,.07)"
        return (
            f'<svg viewBox="0 0 96 96" width="96" height="96" style="position:absolute;inset:0">'
            f'<circle cx="48" cy="48" r="34" fill="none" stroke="{track}" stroke-width="7"/>'
            f'<circle cx="48" cy="48" r="34" fill="none" stroke="{stroke}" stroke-width="7"'
            f' transform="rotate(-90 48 48)"'
            f' stroke-dasharray="{fill} {CIRC}"'
            f' stroke-linecap="round"/>'
            f'</svg>'
        )

    def cap_card(prefix, l1n, name, ncaps, domains, kind):
        comps = sum(comp_by_dom.get(d, 0) for d in domains)
        pct   = round(comps / total_comps * 100, 1)
        gap   = comps == 0
        color = "var(--sky)" if kind == "rtl" else "var(--cerise)"
        code_cls = "gap-c" if gap else f"{kind}-c"
        card_cls = "gap-card" if gap else f"{kind}-card"
        comps_cls = "gap-comps" if gap else ""
        comps_txt = "Sin inventario" if gap else f"{comps} comp · {pct}%"
        svg = donut_svg(ncaps, comps, color, gap)
        return f"""<div class="etb-cap-card glass {card_cls}">
  <div class="etb-donut-wrap">
    {svg}
    <div class="etb-donut-inner">
      <div class="etb-donut-num" style="color:{color}">{ncaps}</div>
      <div class="etb-donut-sub">caps</div>
    </div>
  </div>
  <div class="etb-cap-code {code_cls}">{prefix}.{l1n}</div>
  <div class="etb-cap-name">{clean(name)}</div>
  <div class="etb-cap-doms">{dom_chips(domains, kind)}</div>
  <div class="etb-cap-comps {comps_cls}">{comps_txt}</div>
</div>"""

    # Coverage strips — each segment flex = cap count (proportional)
    def strip_seg(prefix, l1n, ncaps, domains, kind, cap_total):
        comps = sum(comp_by_dom.get(d, 0) for d in domains)
        gap   = comps == 0
        seg_cls = "gap-seg" if gap else (f"{kind}-seg hi" if ncaps >= 35 else f"{kind}-seg")
        tooltip = f"{prefix}.{l1n} · {ncaps} caps · {comps} comp"
        return (f'<div class="etb-strip-seg {seg_cls}" style="flex:{ncaps}" title="{tooltip}">'
                f'<span class="seg-label">{prefix}.{l1n}</span></div>')

    rtl_strip = "".join(
        strip_seg("RTL", n, v[1], RTL_DOMAIN_MAP.get(n,[]), "rtl", rtl_cap_total)
        for n, v in rtl_groups.items()
    )
    fsv_strip = "".join(
        strip_seg("FSV", n, v[1], FSV_DOMAIN_MAP.get(n,[]), "fsv", fsv_cap_total)
        for n, v in fsv_groups.items()
    )

    rtl_cards = "".join(
        cap_card("RTL", n, v[0], v[1], RTL_DOMAIN_MAP.get(n,[]), "rtl")
        for n, v in rtl_groups.items()
    )
    fsv_cards = "".join(
        cap_card("FSV", n, v[0], v[1], FSV_DOMAIN_MAP.get(n,[]), "fsv")
        for n, v in fsv_groups.items()
    )

    return f"""<section id="etb">
    <div class="shead reveal">
      <div class="kick">Modelo de Capacidades Compuesto</div>
      <h2>ETB Retail + Financial Services — Cobertura Aplicativa</h2>
      <p>Cada grupo L1 del ETB se mapea a los dominios del ecosistema Liverpool. El anillo muestra qué fracción del inventario de {total_comps} componentes cubre ese grupo. {"Los "+str(len(gap_domains))+" dominios sin inventario propio se resaltan en rojo." if gap_domains else "Todos los dominios R01–R10 ya tienen inventario tras la incorporación de los SUDs."}</p>
    </div>

    <div class="etb-sum-row reveal">
      <div class="etb-sum-box glass">
        <div class="etb-sum-n" style="color:var(--sky)">{rtl_cap_total}</div>
        <div class="etb-sum-l">Caps Retail RTL</div>
      </div>
      <div class="etb-sum-box glass">
        <div class="etb-sum-n" style="color:var(--cerise)">{fsv_cap_total}</div>
        <div class="etb-sum-l">Caps FS FSV</div>
      </div>
      <div class="etb-sum-box glass">
        <div class="etb-sum-n" style="color:#fff">{grand_total}</div>
        <div class="etb-sum-l">Total Capacidades</div>
      </div>
      <div class="etb-sum-box glass">
        <div class="etb-sum-n" style="color:var(--sky)">{covered_domains}/10</div>
        <div class="etb-sum-l">Dominios con Datos</div>
      </div>
      <div class="etb-sum-box glass">
        <div class="etb-sum-n" style="color:#f87171">{len(gap_domains)}</div>
        <div class="etb-sum-l">Brechas de Inventario</div>
      </div>
    </div>

    <div class="etb-strip-section reveal" style="margin-top:28px">
      <div class="etb-strip-label rtl-lbl">Retail ETB — RTL <span>{rtl_cap_total} capacidades · 9 grupos L1 · cada segmento proporcional al número de capacidades</span></div>
      <div class="etb-strip-row">{rtl_strip}</div>
      <div class="etb-strip-label fsv-lbl" style="margin-top:10px">Financial Services — FSV <span>{fsv_cap_total} capacidades · 6 grupos L1 · todos cubren R03 LiverpoolCard</span></div>
      <div class="etb-strip-row">{fsv_strip}</div>
    </div>

    <div class="etb-cap-section reveal">
      <div class="etb-cap-section-head">
        <span class="etb-badge rtl">Retail ETB</span>
        <span style="font-size:14px;font-weight:700">RTL — 9 grupos L1</span>
        <span style="margin-left:auto;font-size:11px;color:var(--muted2)">El anillo muestra % del inventario cubierto</span>
      </div>
      <div class="etb-cap-grid">{rtl_cards}</div>
    </div>

    <div class="etb-cap-section reveal" style="margin-top:32px">
      <div class="etb-cap-section-head">
        <span class="etb-badge fsv">Financial Services</span>
        <span style="font-size:14px;font-weight:700">FSV — 6 grupos L1 · Overlay R03 LiverpoolCard</span>
        <span style="margin-left:auto;font-size:11px;color:var(--muted2)">Banxico · CONDUSEF · PCI-DSS</span>
      </div>
      <div class="etb-cap-grid">{fsv_cards}</div>
    </div>
  </section>"""


def build(conn) -> str:
    today = str(date.today())

    meta = {r[0]: r[1] for r in conn.execute("SELECT key, value FROM brain_meta")}
    total_caps  = int(meta.get("rtl_total_l3", 0)) + int(meta.get("fsv_total_l3", 0))
    total_comps = conn.execute("SELECT COUNT(*) FROM components").fetchone()[0]
    active_comps = conn.execute("SELECT COUNT(*) FROM components WHERE status='active'").fetchone()[0]
    high_comps  = conn.execute("SELECT COUNT(*) FROM components WHERE complexity IN ('high','very-high')").fetchone()[0]
    n_domains   = conn.execute("SELECT COUNT(*) FROM retail_domains").fetchone()[0]
    n_dts       = len(DT_DATA)
    n_sud_sys   = _meta("sud-catalog-liv.json").get("systems", 0) or \
                  conn.execute("SELECT COUNT(*) FROM components WHERE seeded_by='SUD'").fetchone()[0]

    # Embebe brain.glb como base64 → el cerebro 3D funciona sobre file:// (carpeta portable)
    glb_path = BASE_DIR / "portal" / "brain.glb"
    glb_b64 = base64.b64encode(glb_path.read_bytes()).decode() if glb_path.exists() else ""
    brain_html = _brain_context.BRAIN_HTML.replace("__BRAIN_GLB_B64__", glb_b64)

    views_html      = views_section(conn)
    dom_cards_html  = domain_cards(conn)
    dt_cards_html   = dt_cards()
    cap_cards_html  = cap_cards(conn)
    sis_cards_html  = sistema_cards()
    sen_cards_html  = senal_cards()
    etb_html        = etb_section(conn)

    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Liverpool Brain · Portal de Análisis</title>
<style>
{css()}
{_brain_context.BRAIN_CSS}
</style></head><body>
<div class="aurora"><div class="blob"></div></div><div class="grain"></div>
<div id="prog"></div>

<nav>
  <img src="{LOGO_PATH}" alt="Liverpool" onerror="this.style.display='none'">
  <span class="nt">Liverpool Brain · Portal de Análisis</span>
  <span class="sp"></span>
  <a class="jump" href="#brain">Concepto</a>
  <a class="jump" href="#vistas">Vistas</a>
  <a class="jump" href="#dominios">Dominios</a>
  <a class="jump" href="#twins">Digital Twins</a>
  <a class="jump" href="#etb">ETB</a>
  <a class="jump" href="#sistemas">Sistemas</a>
  <a class="jump" href="#senales">Señales</a>
</nav>

<div class="wrap">

  <header class="hero">
    <div class="eyebrow reveal"><span class="dot"></span> SPE-AM-003 · Liverpool Brain · DISCOVER · {today}</div>
    <h1 class="reveal">Liverpool<br>Digital Brain</h1>
    <p class="sub reveal"><b>El Puerto de Liverpool S.A.B. de C.V.</b> — Application Modernization L4.<br>
    {n_sud_sys} aplicaciones inventariadas desde los SUDs. Federated brain con {total_caps} capacidades RTL/FSV, {total_comps} componentes y {n_dts} Digital Twins activos.</p>

    <div class="stats reveal">
      <div class="stat glass">
        <div class="statn" data-target="{total_caps}">0</div>
        <div class="statl">Capacidades</div>
      </div>
      <div class="stat glass">
        <div class="statn" data-target="{total_comps}">0</div>
        <div class="statl">Componentes</div>
      </div>
      <div class="stat glass">
        <div class="statn" data-target="{active_comps}">0</div>
        <div class="statl">En Scope AMS</div>
      </div>
      <div class="stat glass">
        <div class="statn" data-target="{high_comps}">0</div>
        <div class="statl">Alta Complejidad</div>
      </div>
      <div class="stat glass">
        <div class="statn" data-target="{n_domains}">0</div>
        <div class="statl">Dominios Retail</div>
      </div>
    </div>
  </header>

  <hr class="divider">

  {brain_html}

  <hr class="divider">

  {views_html}

  <hr class="divider">

  <section id="dominios">
    <div class="shead reveal">
      <div class="kick">Arquitectura de Dominio</div>
      <h2>Dominios Retail R01 – R10</h2>
      <p>El programa cubre los 10 dominios del Retail ETB. El dominio R03 (LiverpoolCard — Servicios Financieros) tiene overlay FSV adicional por regulación Banxico y CONDUSEF.</p>
    </div>
    <div class="dom-grid reveal">
{dom_cards_html}
    </div>
  </section>

  <hr class="divider">

  <section id="twins">
    <div class="shead reveal">
      <div class="kick">Digital Twins</div>
      <h2>7 Gemelos Digitales del Ecosistema</h2>
      <p>Cada Digital Twin modela un dominio crítico del programa. Un DT está activo con datos reales; seis están en estado SCAFFOLD listos para activarse cuando se provean las fuentes de datos necesarias.</p>
    </div>
    <div class="cardgrid reveal">
{dt_cards_html}
    </div>
  </section>

  <hr class="divider">

  {etb_html}

  <hr class="divider">

  <section id="capacidades">
    <div class="shead reveal">
      <div class="kick">Modelo de Capacidades</div>
      <h2>Retail ETB + Financial Services Overlay</h2>
      <p>Nomenclatura dual: RTL.{{L1}}.{{seq}} para las {int(meta.get("rtl_total_l3",0))} capacidades Retail y FSV.{{L1}}.{{seq}} para las {int(meta.get("fsv_total_l3",0))} capacidades del overlay financiero de R03. Opción A aprobada en sesión de diseño.</p>
    </div>
    <div class="mgrid reveal">
{cap_cards_html}
    </div>
  </section>

  <hr class="divider">

  <section id="sistemas">
    <div class="shead reveal">
      <div class="kick">Sistemas Clave</div>
      <h2>Stack Tecnológico AS-IS</h2>
      <p>Los sistemas principales del programa con su estado TOGAF y rol en el ecosistema. SAP y Oracle son los sistemas más complejos; commercetools representa el horizonte TO-BE del canal digital.</p>
    </div>
    <div class="cardgrid reveal">
{sis_cards_html}
    </div>
  </section>

  <hr class="divider">

  <section id="senales">
    <div class="shead reveal">
      <div class="kick">Señales Estratégicas</div>
      <h2>Eventos que Dirigen el Programa</h2>
      <p>Cuatro señales de alta relevancia que deben guiar el diseño de la arquitectura TO-BE y las decisiones de modernización en el programa.</p>
    </div>
    <div class="xrow reveal">
{sen_cards_html}
    </div>
  </section>

</div>

<footer>
  <p>Liverpool Brain · SPE-AM-003 · Generado el {today}</p>
  <p style="margin-top:8px">Accenture Technology · Software &amp; Platform Engineering · High Velocity Modernization</p>
  <p style="margin-top:8px;font-size:11px">Generado desde <code>generators/build-portal.py</code> — fuente de verdad: <code>liverpool-brain.db</code></p>
</footer>

<script>
window.addEventListener('scroll',()=>{{
  const d=document.documentElement;
  document.getElementById('prog').style.width=(d.scrollTop/(d.scrollHeight-d.clientHeight)*100)+'%';
}});
const revs=document.querySelectorAll('.reveal');
const rObs=new IntersectionObserver(entries=>{{
  entries.forEach(e=>{{if(e.isIntersecting){{e.target.classList.add('in');rObs.unobserve(e.target);}}}});
}},{{threshold:.08}});
revs.forEach(r=>rObs.observe(r));
const statEls=document.querySelectorAll('.statn[data-target]');
const sObs=new IntersectionObserver(entries=>{{
  entries.forEach(e=>{{
    if(e.isIntersecting){{
      const el=e.target,target=+el.dataset.target,dur=1400,start=performance.now();
      const step=t=>{{const p=Math.min((t-start)/dur,1),v=Math.round(p*target);el.textContent=v.toLocaleString('es-MX');if(p<1)requestAnimationFrame(step);}};
      requestAnimationFrame(step);sObs.unobserve(el);
    }}
  }});
}},{{threshold:.3}});
statEls.forEach(s=>sObs.observe(s));
</script>
</body></html>"""


def main():
    if not DB_PATH.exists():
        print(f"ERROR: {DB_PATH} no encontrado. Ejecutar build-liverpool-brain.py primero.")
        return

    conn = sqlite3.connect(DB_PATH)
    html = build(conn)
    conn.close()

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(html, encoding="utf-8")
    print(f"Portal generado: {OUT_PATH}")
    print(f"  Tamaño: {len(html):,} caracteres")
    print()
    print("Servidor local:")
    print("  cd liverpool-brain")
    print("  python -m http.server 8001 --directory portal")
    print("  http://localhost:8001/")


if __name__ == "__main__":
    main()
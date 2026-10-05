#!/usr/bin/env python3
"""
build-portal.py — Santander CAN Portal Generator
Reconstruido para leer del brain.db. Genera projects/can/portal/index.html
con el design system Santander (paleta oficial, self-contained, sin CDNs).
Logo incrustado como data URI. Arquitectura en SVG nativo.
"""
import os
import base64
import json as _json
import sqlite3
from datetime import datetime

BASE_DIR  = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))   # projects/can/
DB_PATH   = os.path.join(BASE_DIR, "digital-brain", "brain.db")
OUT_PATH  = os.path.join(BASE_DIR, "portal", "index.html")
LOGO_FILE = os.path.join(BASE_DIR, "..", "..", "design-studio", "logos", "Banco_Santander_Logotipo.svg.webp")

try:
    with open(LOGO_FILE, "rb") as _lf:
        LOGO_SRC = "data:image/webp;base64," + base64.b64encode(_lf.read()).decode("ascii")
except Exception:
    LOGO_SRC = ""


# ── CSS base Santander (del design-studio/template.html) ──────────────────────
STYLE = r"""
*{box-sizing:border-box;margin:0;padding:0}
:root{--red:#EC0000;--redd:#CC0000;--reddd:#9A0000;--redglow:rgba(236,0,0,.55);
--ink:#FFF5F5;--muted:#d4aaaa;--muted2:#a07878;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.09)}
html{scroll-behavior:smooth}
body{background:#0d0202;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before,.aurora::after,.aurora .blob{content:"";position:absolute;border-radius:50%;filter:blur(90px)}
.aurora::before{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(200,0,0,.50),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(130,0,0,.55),transparent 70%);animation:f2 28s ease-in-out infinite}
.aurora .blob{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(236,0,0,.18),transparent 70%);animation:f3 32s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.15)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.12)}}
@keyframes f3{50%{transform:translate(-9vw,-9vh) scale(1.22)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;background:linear-gradient(90deg,var(--red),#ff8888);box-shadow:0 0 12px var(--redglow)}
nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:12px;padding:13px 26px;flex-wrap:wrap;backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);background:rgba(13,2,2,.72);border-bottom:1px solid rgba(255,255,255,.06)}
nav img.brand{height:24px;display:block;filter:drop-shadow(0 1px 3px rgba(0,0,0,.5))}
nav .nt{font-size:12px;font-weight:600;color:var(--muted);letter-spacing:.01em}
nav .sp{flex:1}
nav a{font-size:12px;color:var(--muted);padding:6px 11px;border-radius:20px;transition:.22s;text-decoration:none}
nav a:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.glass{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.40),inset 0 1px 0 rgba(255,255,255,.08)}
.wrap{max-width:1160px;margin:0 auto;padding:0 30px}
section{padding:70px 0;scroll-margin-top:76px}
.hero{min-height:52vh;display:flex;flex-direction:column;justify-content:center;position:relative;padding:120px 0 20px}
.eyebrow{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;padding:8px 16px;border-radius:30px;font-size:12px;font-weight:600;letter-spacing:.03em;color:#ffd5d5;margin-bottom:28px;background:rgba(236,0,0,.08);border:1px solid rgba(236,0,0,.20)}
.eyebrow .dot{width:7px;height:7px;border-radius:50%;background:var(--red);box-shadow:0 0 12px var(--redglow);animation:pulse 2.4s infinite}
@keyframes pulse{50%{opacity:.4}}
.hero h1{font-size:clamp(38px,6vw,76px);font-weight:800;line-height:1.0;letter-spacing:-.035em;max-width:20ch;background:linear-gradient(176deg,#fff 34%,#ff9999);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero .sub{font-size:clamp(15px,1.7vw,19px);color:var(--muted);margin-top:22px;max-width:70ch;line-height:1.55}
.hero .sub b{color:#ffe0e0;font-weight:600}
.stats{display:grid;grid-template-columns:repeat(6,1fr);gap:12px;margin-top:36px}
.stat{padding:18px 12px;text-align:center}
.statn{font-size:clamp(20px,2.6vw,30px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;background:linear-gradient(180deg,#fff,#ffb0b0);-webkit-background-clip:text;background-clip:text;color:transparent}
.statl{font-size:9.5px;color:var(--muted2);margin-top:7px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}
.shead{margin-bottom:32px}
.kick{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--red);margin-bottom:14px}
.shead h2{font-size:clamp(26px,3.8vw,42px);font-weight:800;letter-spacing:-.025em;line-height:1.06}
.shead p{color:var(--muted);font-size:15px;margin-top:14px;max-width:76ch;line-height:1.55}
.shead p b{color:#ffe0e0;font-weight:600}
.group{margin-top:34px}
.ghead{display:flex;align-items:baseline;gap:14px;margin-bottom:16px}
.ghead h3{font-size:19px;font-weight:800;letter-spacing:-.02em}
.ghead span{font-size:13px;color:var(--muted2)}
.cardgrid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}
@media(max-width:960px){.cardgrid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:600px){.cardgrid{grid-template-columns:1fr}}
.vcard{display:flex;gap:17px;padding:23px;color:inherit;text-decoration:none;transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s}
.vcard:hover{transform:translateY(-5px);border-color:rgba(236,0,0,.42);box-shadow:0 22px 56px rgba(0,0,0,.5)}
.vcard .ico{font-size:20px;width:46px;height:46px;display:flex;align-items:center;justify-content:center;border-radius:14px;flex-shrink:0;background:linear-gradient(150deg,rgba(255,255,255,.10),rgba(255,255,255,.02));border:1px solid rgba(255,255,255,.10)}
.vcard .vt{font-size:15px;font-weight:800;letter-spacing:-.01em}
.vcard .vd{font-size:12.5px;color:var(--muted);margin:6px 0 0;line-height:1.55}
.vtag{display:inline-block;font-size:9.5px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;padding:2px 7px;border-radius:10px;background:rgba(236,0,0,.12);border:1px solid rgba(236,0,0,.28);color:var(--red);margin-bottom:6px}
.vtag.ok{color:#22c55e;background:rgba(34,197,94,.12);border-color:rgba(34,197,94,.3)}
.vcard.crit{border-left:3px solid #E8400A}.vcard.warn{border-left:3px solid var(--red)}.vcard.ok{border-left:3px solid #22c55e}
.mgrid{display:grid;grid-template-columns:1fr 1fr;gap:15px}
@media(max-width:860px){.mgrid{grid-template-columns:1fr}}
.mcard{padding:22px 24px}
.mcard h4{font-size:12px;color:var(--red);text-transform:uppercase;letter-spacing:.09em;margin-bottom:10px;font-weight:700}
.mcard p{font-size:13px;color:var(--muted);line-height:1.6}.mcard b{color:#fff;font-weight:600}
.chip{display:inline-block;font-size:10px;font-weight:700;padding:3px 9px;border-radius:12px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.06);color:var(--muted);margin:3px 3px 0 0;letter-spacing:.04em}
.chip.red{border-color:rgba(236,0,0,.35);color:#ff8888;background:rgba(236,0,0,.10)}
.chip.yellow{border-color:rgba(255,180,0,.35);color:#ffd666;background:rgba(255,180,0,.09)}
.chip.green{border-color:rgba(34,197,94,.35);color:#86efac;background:rgba(34,197,94,.09)}
.tbl{width:100%;border-collapse:collapse;font-size:13px}
.tbl th{text-align:left;font-size:10px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);padding:10px 14px;border-bottom:1px solid rgba(255,255,255,.08)}
.tbl td{padding:12px 14px;border-bottom:1px solid rgba(255,255,255,.04);color:var(--muted);vertical-align:top;line-height:1.5}
.tbl td:first-child{color:var(--ink);font-weight:600}
.tbl tr:hover td{background:rgba(255,255,255,.025)}
.reveal{opacity:0;transform:translateY(28px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}
.reveal.in{opacity:1;transform:none}
footer{padding:44px 30px 64px;text-align:center;color:var(--muted2);font-size:12px;border-top:1px solid rgba(255,255,255,.06);margin-top:40px;line-height:1.7}
footer code{color:var(--muted);background:rgba(236,0,0,.10);border:1px solid rgba(236,0,0,.22);border-radius:5px;padding:1px 6px;font-size:11px}
/* chevrones */
.chevrow{display:flex;width:100%}
.chev{flex:1;position:relative;padding:20px 10px 20px 34px;background:rgba(140,0,0,.30);margin-left:-20px;clip-path:polygon(0 0,calc(100% - 20px) 0,100% 50%,calc(100% - 20px) 100%,0 100%,20px 50%);transition:filter .25s;min-width:0}
.chev:hover{filter:brightness(1.2)}
.chev-f{margin-left:0;clip-path:polygon(0 0,calc(100% - 20px) 0,100% 50%,calc(100% - 20px) 100%,0 100%);padding-left:18px}
.chev-l{clip-path:polygon(0 0,100% 0,100% 100%,0 100%,20px 50%);padding-right:18px}
.chev-n{font-size:9px;font-weight:800;color:var(--red);letter-spacing:.14em;text-transform:uppercase;margin-bottom:6px}
.chev-t{font-size:12.5px;font-weight:800;color:#fff;margin-bottom:4px;letter-spacing:-.01em}
.chev-d{font-size:10px;color:var(--muted);line-height:1.4}
@media(max-width:820px){.chevrow{flex-direction:column}.chev,.chev-f,.chev-l{margin-left:0;margin-bottom:6px;clip-path:none;border-radius:10px}}
/* flujos */
.flow-block{margin-bottom:32px}
.flow-head{display:flex;align-items:center;gap:12px;margin-bottom:6px;flex-wrap:wrap}
.flow-num{font-size:10px;font-weight:800;color:var(--red);letter-spacing:.14em;text-transform:uppercase}
.flow-title{font-size:16px;font-weight:800;color:#fff;letter-spacing:-.01em}
.flow-rol{font-size:9px;font-weight:700;letter-spacing:.08em;padding:3px 10px;border-radius:20px}
.flow-sla{font-size:10px;color:var(--muted2);margin-left:auto;font-weight:600}
.flow-desc{font-size:12.5px;color:var(--muted);margin-bottom:14px;line-height:1.5;max-width:900px}
.flow-us{margin-top:12px;font-size:10px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--muted2);display:flex;align-items:center;gap:6px;flex-wrap:wrap}
/* ETB map */
.etb-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;align-items:start;margin-top:4px}
.etb-domain{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:16px;overflow:hidden}
.etb-dhead{padding:14px 16px 12px;font-size:12px;font-weight:800;letter-spacing:.04em;color:#fff;border-bottom:1px solid rgba(255,255,255,.07)}
.etb-sub{padding:10px 12px 6px}
.etb-sub-lbl{font-size:8.5px;font-weight:700;letter-spacing:.14em;text-transform:uppercase;color:var(--muted2);margin:10px 0 6px}
.etb-sub-lbl:first-child{margin-top:4px}
.etb-cap{font-size:10.5px;padding:5px 8px;border-radius:7px;margin-bottom:4px;line-height:1.3;font-weight:500;cursor:pointer;transition:filter .2s,transform .15s}
.etb-cap:hover{filter:brightness(1.35);transform:scale(1.02)}
.etb-none{background:rgba(255,255,255,.04);color:rgba(255,255,255,.28);border:1px solid rgba(255,255,255,.05)}
.etb-CUBIERTO{background:rgba(34,197,94,.16);color:#86efac;border:1px solid rgba(34,197,94,.28)}
.etb-PARCIAL{background:rgba(255,180,0,.13);color:#ffd666;border:1px solid rgba(255,180,0,.26)}
.etb-BRECHA{background:rgba(236,0,0,.18);color:#fca5a5;border:1px solid rgba(236,0,0,.34)}
.etb-legend{display:flex;gap:20px;flex-wrap:wrap;margin-bottom:20px;padding:16px 20px;border-radius:12px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.06)}
.etb-leg{display:flex;align-items:center;gap:7px;font-size:12px;color:var(--muted)}
.etb-leg-dot{width:10px;height:10px;border-radius:3px;flex-shrink:0}
@media(max-width:1100px){.etb-grid{grid-template-columns:repeat(3,1fr)}}
@media(max-width:660px){.etb-grid{grid-template-columns:1fr 1fr}}
"""

# ── ETB capability model (dominios → subdominios → L3) ────────────────────────
ETB_DOMAINS = [
    ("Retail Banking", [
        ("Lending", ["Loan Origination", "Credit Assessment & Underwriting", "Payroll Credit Management", "Loan Servicing", "Collections & Recovery"]),
        ("Deposits & Accounts", ["Account Opening", "Account Management", "Account Domiciliation", "Term Deposits"]),
        ("Customer Management", ["KYC & Identity Verification", "Customer Onboarding", "Customer Data Management"]),
        ("Cards", ["Card Issuance", "Card Authorization", "Rewards & Benefits"]),
    ]),
    ("Payments", [
        ("Domestic Payments", ["SPEI Processing", "CoDi / DiMo", "ACH & TEF", "Direct Debit"]),
        ("Interbank Messaging", ["Interbank Messaging (CECOBAN CAN)", "PROSA Clearing"]),
        ("Payroll & Mass Payments", ["Payroll Disbursement Integration", "Mass Payments"]),
        ("International", ["SWIFT / ISO 20022", "FX Processing", "Remittances"]),
    ]),
    ("Digital Banking", [
        ("Digital Channels", ["Mobile Banking", "Internet Banking", "Open Banking APIs"]),
        ("Digital Engagement", ["Digital Signature & Consent Management", "Digital Onboarding", "Notifications & Alerts"]),
    ]),
    ("Risk & Compliance", [
        ("Credit Risk", ["Credit Risk Governance", "Credit Scoring Models", "Loan Loss Provisioning"]),
        ("Regulatory", ["Regulatory Reporting", "AML / PLD Engine", "Audit & Compliance Logging"]),
        ("Operational Risk", ["Fraud Detection", "Cybersecurity Controls", "Business Continuity"]),
    ]),
    ("Operations", [
        ("IT Operations", ["Configuration Management", "Infrastructure & Cloud", "Observability & Monitoring"]),
        ("Service Operations", ["Core Banking Operations", "Branch Operations", "Contact Center"]),
    ]),
]


def esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")) if s is not None else ""


def load_data():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    d = {}
    d["meta"] = dict(cur.execute("SELECT key,value FROM brain_meta").fetchall())
    d["obligations"] = cur.execute("SELECT id,descripcion,tipo,riesgo_sancion,plazo_dhb,rol_aplicable FROM obligations ORDER BY id").fetchall()
    d["brechas"] = cur.execute("SELECT id,criticidad,descripcion,sistema_afectado,capacidad_faltante FROM brechas ORDER BY CASE criticidad WHEN 'CRITICA' THEN 1 WHEN 'ALTA' THEN 2 WHEN 'MEDIA' THEN 3 ELSE 4 END").fetchall()
    d["stories"] = cur.execute("SELECT id,titulo,obligation_id,sistema_slug,como,quiero,para,estimacion,brecha_id,estado FROM user_stories ORDER BY id").fetchall()
    d["adrs"] = cur.execute("SELECT id,titulo,decision,estado FROM adrs ORDER BY id").fetchall()
    d["sla"] = cur.execute("SELECT id,descripcion,plazo_dhb,riesgo_sancion FROM obligations WHERE plazo_dhb IS NOT NULL ORDER BY plazo_dhb").fetchall()
    d["cecoban"] = cur.execute("SELECT categoria,nombre,valor,descripcion FROM cecoban_integration ORDER BY categoria,id").fetchall()
    d["micros"] = cur.execute("SELECT id,nombre,version,java_version,spring_boot,rol,descripcion,responsabilidad,sistemas_llama,endpoints_count,bd FROM microservices ORDER BY rol DESC,id").fetchall()
    d["etb"] = cur.execute("SELECT id,etb_l1,etb_l2,descripcion,estado_can,microservicios,obligaciones,nota_gap FROM etb_capabilities ORDER BY CASE estado_can WHEN 'BRECHA' THEN 1 WHEN 'PARCIAL' THEN 2 ELSE 3 END,etb_l1").fetchall()
    d["coverage"] = cur.execute("SELECT o.id,o.riesgo_sancion,oc.microservicio_id,oc.cobertura,oc.gap_detectado FROM obligation_coverage oc JOIN obligations o ON o.id=oc.obligation_id ORDER BY o.id,oc.cobertura").fetchall()
    d["flows"] = cur.execute("SELECT id,numero,nombre,descripcion,rol,sla,pasos,user_stories FROM can_flows ORDER BY numero").fetchall()
    d["arch_comp"] = cur.execute("SELECT id,nombre,tipo,capa,pos_x,descripcion FROM arch_components ORDER BY pos_x").fetchall()
    d["arch_integ"] = cur.execute("SELECT origen,destino,etiqueta,tipo FROM arch_integrations ORDER BY id").fetchall()
    d["phases"] = cur.execute("SELECT id,numero,nombre,objetivo,duracion,user_stories,entregable,gate,escenario FROM roadmap_phases ORDER BY numero").fetchall()
    d["team"] = cur.execute("SELECT id,squad,rol,career_level,fte,responsabilidad,sme_fuente,owner FROM team_roles ORDER BY id").fetchall()
    d["levers"] = cur.execute("SELECT palanca,activo_brain,impacto FROM optimization_levers ORDER BY id").fetchall()
    d["stats"] = {
        "total": cur.execute("SELECT COUNT(*) FROM obligations").fetchone()[0],
        "brechas": cur.execute("SELECT COUNT(*) FROM brechas WHERE estado='ABIERTA'").fetchone()[0],
        "criticas": cur.execute("SELECT COUNT(*) FROM brechas WHERE criticidad='CRITICA' AND estado='ABIERTA'").fetchone()[0],
        "us": cur.execute("SELECT COUNT(*) FROM user_stories").fetchone()[0],
        "flujos": cur.execute("SELECT COUNT(*) FROM can_flows").fetchone()[0],
        "fte": int(cur.execute("SELECT COALESCE(SUM(fte),0) FROM team_roles").fetchone()[0]),
    }
    con.close()
    return d


def risk_chip(r):
    cls = {"critico": "red", "alto": "yellow", "medio": "yellow", "bajo": "green"}.get((r or "").lower(), "")
    return f'<span class="chip {cls}">{esc((r or "").upper())}</span>'


def est_chip(e):
    cls = {"XL": "red", "L": "yellow", "M": "yellow", "S": "green"}.get(e, "")
    return f'<span class="chip {cls}">{esc(e)}</span>'


def crit_info(c):
    return {"CRITICA": ("crit", "Crítica"), "ALTA": ("warn", "Alta"), "MEDIA": ("", "Media"), "BAJA": ("ok", "Baja")}.get(c, ("", c))


def cov_chip(c):
    m = {"CUBIERTO": "green", "PARCIAL": "yellow", "NO_CUBIERTO": "red"}
    return f'<span class="chip {m.get(c,"")}">{esc((c or "").replace("_"," "))}</span>'


def etb_chip(e):
    m = {"CUBIERTO": "green", "PARCIAL": "yellow", "BRECHA": "red"}
    return f'<span class="chip {m.get(e,"")}">{esc(e)}</span>'


def cat_label(c):
    return {"auth": "Autenticación", "api_rest": "API REST", "kafka": "Kafka", "simulador": "Simulador CAN",
            "timeouts": "Timeouts", "errores": "Catálogo de Errores"}.get(c, c)


OWNER_COLOR = {"Accenture": "#A100FF", "Banco": "#EC0000", "Mixto": "#ffd666"}


def owner_badge(o):
    c = OWNER_COLOR.get(o, "#888888")
    return f'<span class="chip" style="font-size:9px;background:{c}22;color:{c};border:1px solid {c}66">{esc(o)}</span>'


def build_arch_svg(d):
    LAYER_Y = {"canal": 60, "onefinancial": 192, "gateway": 336, "core": 484, "externo": 652}
    LAYER_LABEL = {"canal": "CANALES", "onefinancial": "ONEFINANCIAL — ORIGINACIÓN (ACREEDORA)",
                   "gateway": "SOLUCIÓN CAN — PERÍMETRO SANTANDER", "core": "CORE SANTANDER", "externo": "EXTERNOS / REGULATORIO"}
    TYPE_STROKE = {"canal": "#ff9999", "onefinancial": "#A100FF", "gateway": "#EC0000", "core": "#d4aaaa", "externo": "#a07878"}
    ORDER = ["canal", "onefinancial", "gateway", "core", "externo"]
    EDGE = {"sync": "#EC0000", "async": "#ffd666", "internal": "#b78f8f"}
    BW, BH, LEFT, RIGHT = 168, 46, 130, 1110
    by_layer = {}
    for cid, nombre, tipo, capa, px, descr in d["arch_comp"]:
        by_layer.setdefault(capa, []).append((px, cid, nombre, tipo))
    posx, posy, ptype, pname = {}, {}, {}, {}
    for capa, comps in by_layer.items():
        comps.sort()
        n = len(comps)
        for i, (px, cid, nombre, tipo) in enumerate(comps):
            posx[cid] = (LEFT + RIGHT) / 2 if n == 1 else LEFT + i * (RIGHT - LEFT) / (n - 1)
            posy[cid] = LAYER_Y[capa]; ptype[cid] = tipo; pname[cid] = nombre
    defs = ""
    for t, c in EDGE.items():
        defs += f'<marker id="ar_{t}" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0,0L10,5L0,10z" fill="{c}"/></marker>'
    bands = ""
    for capa in ORDER:
        if capa in by_layer:
            bands += f'<text x="22" y="{LAYER_Y[capa]-BH/2-9:.0f}" font-size="9.5" font-weight="700" letter-spacing="1.4" fill="#a07878">{LAYER_LABEL[capa]}</text>'
    edges, labels = "", ""
    for origen, destino, etiqueta, tipo in d["arch_integ"]:
        if origen not in posx or destino not in posx:
            continue
        sx, sy, tx, ty = posx[origen], posy[origen], posx[destino], posy[destino]
        col = EDGE.get(tipo, "#888"); dash = 'stroke-dasharray="5 4"' if tipo == "async" else ''
        if abs(ty - sy) < 20:
            if tx >= sx: x1, y1, x2, y2 = sx + BW / 2, sy, tx - BW / 2, ty
            else: x1, y1, x2, y2 = sx - BW / 2, sy, tx + BW / 2, ty
            path = f"M{x1:.0f},{y1:.0f} L{x2:.0f},{y2:.0f}"
        elif ty > sy:
            x1, y1, x2, y2 = sx, sy + BH / 2, tx, ty - BH / 2; dd = (y2 - y1) / 2
            path = f"M{x1:.0f},{y1:.0f} C{x1:.0f},{y1+dd:.0f} {x2:.0f},{y2-dd:.0f} {x2:.0f},{y2:.0f}"
        else:
            x1, y1, x2, y2 = sx, sy - BH / 2, tx, ty + BH / 2; dd = (y1 - y2) / 2
            path = f"M{x1:.0f},{y1:.0f} C{x1:.0f},{y1-dd:.0f} {x2:.0f},{y2+dd:.0f} {x2:.0f},{y2:.0f}"
        edges += f'<path d="{path}" fill="none" stroke="{col}" stroke-width="1.5" {dash} marker-end="url(#ar_{tipo})" opacity=".72"/>'
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2; lw = len(etiqueta) * 5.0 + 8
        labels += f'<rect x="{mx-lw/2:.0f}" y="{my-8:.0f}" width="{lw:.0f}" height="15" rx="4" fill="#160707" opacity=".92"/><text x="{mx:.0f}" y="{my+3:.0f}" text-anchor="middle" font-size="8.5" fill="#d4aaaa">{esc(etiqueta)}</text>'
    boxes = ""
    for cid in posx:
        x, y, c = posx[cid], posy[cid], TYPE_STROKE.get(ptype[cid], "#888")
        boxes += (f'<g><rect x="{x-BW/2:.0f}" y="{y-BH/2:.0f}" width="{BW}" height="{BH}" rx="10" fill="#160707" stroke="{c}" stroke-width="1.5"/>'
                  f'<rect x="{x-BW/2:.0f}" y="{y-BH/2:.0f}" width="4" height="{BH}" rx="2" fill="{c}"/>'
                  f'<text x="{x:.0f}" y="{y+4:.0f}" text-anchor="middle" font-size="9.5" font-weight="700" fill="#FFF5F5">{esc(pname[cid])}</text></g>')
    return (f'<svg viewBox="0 0 1240 720" style="width:100%;height:auto;min-width:920px" xmlns="http://www.w3.org/2000/svg">'
            f'<defs>{defs}</defs>{bands}{edges}{labels}{boxes}</svg>')


def generate(d):
    now = datetime.now().strftime("%Y-%m-%d")
    s = d["stats"]; meta = d["meta"]; ver = meta.get("version", "0.4.0")
    us_titulo = {r[0]: r[1] for r in d["stories"]}

    # ETB popup data
    stories_by_obl = {}
    for sid, tit, obl, sis, como, quiero, para, est, br, estado in d["stories"]:
        stories_by_obl.setdefault(obl, []).append({"id": sid, "titulo": tit, "sistema": sis, "quiero": quiero, "estimacion": est})
    etb_popup = {}
    etb_lookup = {}
    for eid, l1, l2, desc, estado, ms, obl_raw, nota in d["etb"]:
        etb_lookup[l2] = estado
        try: obls = _json.loads(obl_raw) if obl_raw else []
        except Exception: obls = []
        rel = []
        for o in obls:
            rel.extend(stories_by_obl.get(o, []))
        etb_popup[l2] = {"estado": estado, "desc": desc, "nota": nota, "obligaciones": obls, "stories": rel}

    # ETB map html
    etb_map = ""
    for dname, subs in ETB_DOMAINS:
        caps = '<div class="etb-sub">'
        for sname, cs in subs:
            caps += f'<div class="etb-sub-lbl">{esc(sname)}</div>'
            for cap in cs:
                css = "etb-" + etb_lookup.get(cap, "none")
                ce = cap.replace("'", "\\'")
                caps += f'<div class="etb-cap {css}" onclick="showEtb(\'{esc(ce)}\')" title="Ver User Stories">{esc(cap)}</div>'
        caps += '</div>'
        etb_map += f'<div class="etb-domain"><div class="etb-dhead">{esc(dname)}</div>{caps}</div>'

    # Flujos chevrones
    rol_color = {"ACREEDORA": "#EC0000", "DEPOSITARIA": "#ff9999", "AMBAS": "#ffd666"}
    flows_html = ""
    for fid, num, nombre, desc, rol, sla, pasos_raw, us_raw in d["flows"]:
        try: pasos = _json.loads(pasos_raw) if pasos_raw else []
        except Exception: pasos = []
        try: us_list = _json.loads(us_raw) if us_raw else []
        except Exception: us_list = []
        n = len(pasos); chevs = ""
        for i, p in enumerate(pasos):
            red = int(100 + 120 * i / max(n - 1, 1))
            cls = "chev" + (" chev-f" if i == 0 else " chev-l" if i == n - 1 else "")
            chevs += (f'<div class="{cls}" style="background:rgba({red},0,0,.42);z-index:{n-i}">'
                      f'<div class="chev-n">{esc(p.get("code",""))}</div><div class="chev-t">{esc(p.get("path",""))}</div>'
                      f'<div class="chev-d">{esc(p.get("desc",""))}</div></div>')
        us_chips = "".join(f'<span class="chip" style="font-size:9px">{esc(u.replace("US-SANT-",""))}</span>' for u in us_list)
        rc = rol_color.get(rol, "#888")
        sla_html = f'<span class="flow-sla">SLA: {esc(sla)}</span>' if sla and sla != "—" else ''
        us_html = f'<div class="flow-us">User Stories: {us_chips}</div>' if us_chips else ''
        flows_html += (f'<div class="flow-block reveal"><div class="flow-head"><div class="flow-num">Flujo {num}</div>'
                       f'<div class="flow-title">{esc(nombre)}</div><span class="flow-rol" style="background:{rc}22;color:{rc};border:1px solid {rc}66">{esc(rol)}</span>{sla_html}</div>'
                       f'<div class="flow-desc">{esc(desc)}</div><div class="chevrow">{chevs}</div>{us_html}</div>')

    arch_svg = build_arch_svg(d)

    # Roadmap
    def roadmap_chevs(phases):
        n = len(phases); out = ""
        for i, (pid, num, nom, obj, dur, us_raw, ent, gate, esc_) in enumerate(phases):
            red = int(100 + 120 * i / max(n - 1, 1))
            cls = "chev" + (" chev-f" if i == 0 else " chev-l" if i == n - 1 else "")
            out += (f'<div class="{cls}" style="background:rgba({red},0,0,.42);z-index:{n-i}">'
                    f'<div class="chev-n">Fase {num}</div><div class="chev-t">{esc(nom)}</div><div class="chev-d">{esc(dur)}</div></div>')
        return out

    def roadmap_cards(phases):
        out = ""
        for pid, num, nom, obj, dur, us_raw, ent, gate, esc_ in phases:
            try: us_list = _json.loads(us_raw) if us_raw else []
            except Exception: us_list = []
            items = "".join(f'<li><code style="font-size:10px">{esc(u.replace("US-SANT-",""))}</code> {esc(us_titulo.get(u,""))}</li>' for u in us_list) \
                or '<li style="color:var(--muted2);list-style:none">Certificación y cutover de los flujos ya construidos</li>'
            out += (f'<div class="vcard glass reveal" style="display:block;padding:24px">'
                    f'<div style="display:flex;align-items:center;gap:12px;margin-bottom:8px"><div class="vtag">Fase {num}</div>'
                    f'<div class="vt" style="font-size:15px">{esc(nom)}</div><div style="margin-left:auto;font-size:11px;color:var(--muted2);font-weight:700">{esc(dur)}</div></div>'
                    f'<div class="vd" style="margin-bottom:14px">{esc(obj)}</div>'
                    f'<ul style="margin:0 0 14px 18px;padding:0;font-size:12px;color:var(--muted);line-height:1.9">{items}</ul>'
                    f'<div style="display:flex;gap:10px;flex-wrap:wrap">'
                    f'<div style="flex:1;min-width:220px;background:rgba(255,255,255,.03);border:1px solid var(--glassb);border-radius:10px;padding:12px 14px"><div style="font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-bottom:5px">Entregable</div><div style="font-size:12px;color:var(--muted)">{esc(ent)}</div></div>'
                    f'<div style="flex:1;min-width:220px;background:rgba(236,0,0,.07);border:1px solid rgba(236,0,0,.2);border-radius:10px;padding:12px 14px"><div style="font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:#fca5a5;margin-bottom:5px">Gate de salida</div><div style="font-size:12px;color:var(--muted)">{esc(gate)}</div></div>'
                    f'</div></div>')
        return out

    phases = list(d["phases"])
    roadmap_chev_html = roadmap_chevs(phases)
    roadmap_card_html = roadmap_cards(phases)

    # Equipo — org split + squads
    team_by_owner = {}
    for tid, squad, rol, cl, fte, resp, sme, owner in d["team"]:
        team_by_owner.setdefault(owner, []).append((rol, fte, squad))
    org_cards = ""
    for org, color in [("Accenture", "#A100FF"), ("Banco", "#EC0000"), ("Mixto", "#ffd666")]:
        roles = team_by_owner.get(org, [])
        if not roles: continue
        ofte = sum(r[1] for r in roles)
        items = ""
        for rol, fte, squad in roles:
            fs = f'{fte:.0f}' if float(fte).is_integer() else f'{fte}'
            items += (f'<div style="display:flex;align-items:baseline;gap:8px;padding:6px 0;border-bottom:1px solid rgba(255,255,255,.05)">'
                      f'<span style="font-size:12.5px;color:#fff;font-weight:600">{esc(rol)}</span>'
                      f'<span style="font-size:9px;color:var(--muted2);margin-left:auto">{esc(squad)}</span>'
                      f'<span class="chip yellow" style="font-size:9px">{fs}</span></div>')
        org_cards += (f'<div class="vcard glass" style="display:block;padding:22px 24px;border-top:3px solid {color}">'
                      f'<div style="display:flex;align-items:center;gap:10px;margin-bottom:10px"><div class="vt" style="font-size:15px;color:{color}">{esc(org)}</div>'
                      f'<span class="chip" style="font-size:10px;margin-left:auto;background:{color}22;color:{color};border:1px solid {color}66">{ofte:.0f} FTE</span></div>{items}</div>')

    team_by_squad = {}
    squad_owner = {}
    for tid, squad, rol, cl, fte, resp, sme, owner in d["team"]:
        team_by_squad.setdefault(squad, []).append((rol, cl, fte, resp, sme, owner))
        ow = {r[5] for r in team_by_squad[squad]}
        squad_owner[squad] = list(ow)[0] if len(ow) == 1 else "Mixto"
    team_html = ""
    for squad, roles in team_by_squad.items():
        sfte = sum(r[2] for r in roles); rows = ""
        for rol, cl, fte, resp, sme, owner in roles:
            fs = f'{fte:.0f}' if float(fte).is_integer() else f'{fte}'
            rows += (f'<div style="padding:13px 0;border-bottom:1px solid rgba(255,255,255,.06)">'
                     f'<div style="display:flex;align-items:center;gap:10px;margin-bottom:4px"><div style="font-size:13px;font-weight:700;color:#fff">{esc(rol)}</div>'
                     f'<span class="chip" style="font-size:9px;margin-left:auto">{esc(cl)}</span><span class="chip yellow" style="font-size:9px">{fs} FTE</span></div>'
                     f'<div style="font-size:11.5px;color:var(--muted);line-height:1.5;margin-bottom:4px">{esc(resp)}</div>'
                     f'<div style="display:flex;gap:8px;align-items:center"><span style="font-size:10px;color:var(--muted2)">SME: {esc(sme)}</span>{owner_badge(owner)}</div></div>')
        team_html += (f'<div class="vcard glass reveal" style="display:block;padding:22px 24px">'
                      f'<div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;flex-wrap:wrap"><div class="vt" style="font-size:14px">{esc(squad)}</div>'
                      f'{owner_badge(squad_owner.get(squad,"Mixto"))}<span class="chip" style="font-size:9px;margin-left:auto">{sfte:.0f} FTE</span></div>{rows}</div>')

    lever_rows = "".join(f'<tr><td style="font-weight:700;color:#fff;font-size:12.5px">{esc(p)}</td><td style="font-size:11.5px;color:var(--muted)">{esc(a)}</td><td style="font-size:11.5px;color:#86efac">{esc(i)}</td></tr>' for p, a, i in d["levers"])

    # Micros OneFinancial
    def micro_card(m):
        mid, nom, vers, java, sb, rol, desc, resp, sis_raw, eps, bd = m
        try: sis = _json.loads(sis_raw) if sis_raw else []
        except Exception: sis = []
        chips = "".join(f'<span class="chip">{esc(str(x)[:40])}</span>' for x in sis[:5])
        return (f'<div class="vcard glass" style="padding:22px;display:block">'
                f'<div style="display:flex;align-items:center;gap:12px;margin-bottom:12px"><div class="ico">{"⚙" if rol=="INFRAESTRUCTURA" else "◈"}</div>'
                f'<div><div class="vtag {"ok" if rol=="INFRAESTRUCTURA" else ""}">{esc(rol)}</div><div class="vt" style="font-size:15px">{esc(nom)}</div></div>'
                f'<div style="margin-left:auto;text-align:right"><div style="font-size:10px;color:var(--muted2)">{esc(java)} · {esc(sb)}</div><div style="font-size:10px;color:var(--muted2)">{esc(vers)}</div></div></div>'
                f'<div class="vd">{esc(resp)}</div>{f"<div style=margintop:10px>{chips}</div>" if chips else ""}</div>')
    micros_neg = "".join(micro_card(m) for m in d["micros"] if m[5] == "NEGOCIO")
    micros_inf = "".join(micro_card(m) for m in d["micros"] if m[5] == "INFRAESTRUCTURA")

    # ETB gap table
    etb_rows = ""
    for eid, l1, l2, desc, estado, ms_raw, obl_raw, nota in d["etb"]:
        etb_rows += (f'<tr><td><span style="font-size:10px;color:var(--muted2)">{esc(l1)}</span><br><b style="font-size:13px">{esc(l2)}</b></td>'
                     f'<td>{etb_chip(estado)}</td><td style="font-size:11.5px">{esc(nota[:120])}{"…" if nota and len(nota)>120 else ""}</td></tr>')

    # Coverage
    cov_by = {}
    for oid, riesgo, sis, cov, gap in d["coverage"]:
        cov_by.setdefault(oid, {"riesgo": riesgo, "rows": []})["rows"].append((sis, cov, gap))
    cov_rows = ""
    for oid, info in sorted(cov_by.items()):
        for sis, cov, gap in info["rows"]:
            cov_rows += (f'<tr><td><code style="font-size:10px">{esc(oid)}</code></td><td>{risk_chip(info["riesgo"])}</td>'
                         f'<td><span class="chip" style="font-size:10px">{esc(sis or "—")}</span></td><td>{cov_chip(cov)}</td>'
                         f'<td style="font-size:11px;color:var(--muted2)">{esc((gap or "")[:90])}{"…" if gap and len(gap)>90 else ""}</td></tr>')

    # Brechas
    brecha_cards = ""
    for bid, crit, desc, sis, cap in d["brechas"]:
        css, label = crit_info(crit)
        brecha_cards += (f'<div class="vcard glass {css}" style="display:block;padding:22px"><div class="vtag {css}">{esc(label)}</div>'
                         f'<div class="vt" style="font-size:14px">{esc(bid)}</div><div class="vd">{esc(desc)}</div>'
                         f'<div style="margin-top:8px"><span class="chip">Sistema: {esc(sis)}</span></div></div>')

    # SLAs
    sla_rows = "".join(f'<tr><td><code>{esc(sid)}</code></td><td>{esc(desc[:80])}{"…" if len(desc)>80 else ""}</td><td style="text-align:center;font-weight:800;color:#EC0000">{plazo} DHB</td><td>{risk_chip(riesgo)}</td></tr>' for sid, desc, plazo, riesgo in d["sla"])

    # CECOBAN
    cec_by = {}
    for cat, nom, val, desc in d["cecoban"]:
        cec_by.setdefault(cat, []).append((nom, val, desc))
    cec_html = ""
    for cat in ["auth", "api_rest", "kafka", "timeouts", "simulador", "errores"]:
        rows = cec_by.get(cat, [])
        if not rows: continue
        rh = "".join(f'<tr><td>{esc(n)}</td><td><code style="font-size:11px;word-break:break-all">{esc(v)}</code></td><td style="font-size:12px">{esc(dsc)}</td></tr>' for n, v, dsc in rows)
        cec_html += (f'<div class="group"><div class="ghead"><h3>{esc(cat_label(cat))}</h3><span>{len(rows)} parámetros</span></div>'
                     f'<div class="glass" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>Parámetro</th><th>Valor</th><th>Descripción</th></tr></thead><tbody>{rh}</tbody></table></div></div>')

    # Obligaciones
    obl_rows = "".join(f'<tr><td><code>{esc(oid)}</code></td><td style="font-size:12px">{esc(desc[:90])}{"…" if len(desc)>90 else ""}</td><td><span class="chip">{esc(tipo)}</span></td><td>{risk_chip(riesgo)}</td><td style="text-align:center;font-weight:700">{str(plazo)+" DHB" if plazo else "—"}</td><td><span style="font-size:11px;color:var(--muted2)">{esc(rol)}</span></td></tr>' for oid, desc, tipo, riesgo, plazo, rol in d["obligations"])

    # Stories
    story_rows = "".join(f'<tr><td><code>{esc(sid)}</code></td><td style="font-size:12px">{esc(tit)}</td><td><span class="chip" style="font-size:10px">{esc(sis)}</span></td><td>{est_chip(est)}</td></tr>' for sid, tit, obl, sis, como, quiero, para, est, br, estado in d["stories"])

    # ADRs
    adr_rows = "".join(f'<tr><td><code>{esc(aid)}</code></td><td style="font-size:12.5px;color:#fff;font-weight:600">{esc(tit)}</td><td style="font-size:12px">{esc((dec or "")[:160])}{"…" if dec and len(dec)>160 else ""}</td><td><span class="chip">{esc(estado)}</span></td></tr>' for aid, tit, dec, estado in d["adrs"])

    etb_popup_js = _json.dumps(etb_popup, ensure_ascii=False)

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>CAN · Cumplimiento · Santander Digital Brain</title>
<style>{STYLE}</style></head><body>
<div class="aurora"><div class="blob"></div></div><div class="grain"></div><div id="prog"></div>
<nav>
  <img class="brand" src="{LOGO_SRC}" alt="Santander" onerror="this.style.display='none'">
  <span class="nt">CAN · Cumplimiento Regulatorio</span>
  <span class="sp"></span>
  <a href="#historia">Historia</a><a href="#funcional">Qué es el CAN</a><a href="#etb-map">ETB Map</a>
  <a href="#flujos">Flujos</a><a href="#arquitectura">Arquitectura</a><a href="#roadmap">Roadmap</a>
  <a href="#equipo">Equipo</a><a href="#optimizacion">Aceleración IA</a><a href="#micros">OneFinancial</a>
  <a href="#brechas">Brechas</a><a href="#cecoban">CECOBAN</a>
</nav>
<div class="wrap">
  <header class="hero">
    <div class="eyebrow reveal"><span class="dot"></span> Santander México · CAN · Fase DISCOVER + DESIGN · {now}</div>
    <h1 class="reveal">Créditos Asociados a Nómina</h1>
    <p class="sub reveal">Dashboard de cumplimiento regulatorio <b>Banxico Circular 3/2012</b> compilado 6/2025. Mecanismo Art. 63 Bis 3 (CECOBAN) con <b>REST + Kafka dual-canal</b>. Orquestador CAN sobre OneFinancial + core Santander. CAN Brain v{esc(ver)}.</p>
    <div class="stats reveal">
      <div class="stat glass"><div class="statn" data-target="{s['total']}">0</div><div class="statl">Obligaciones</div></div>
      <div class="stat glass"><div class="statn" data-target="{s['brechas']}">0</div><div class="statl">Brechas abiertas</div></div>
      <div class="stat glass"><div class="statn" data-target="{s['criticas']}">0</div><div class="statl">Brechas críticas</div></div>
      <div class="stat glass"><div class="statn" data-target="{s['us']}">0</div><div class="statl">User Stories</div></div>
      <div class="stat glass"><div class="statn" data-target="{s['flujos']}">0</div><div class="statl">Flujos CAN</div></div>
      <div class="stat glass"><div class="statn" data-target="{s['fte']}">0</div><div class="statl">FTE equipo</div></div>
    </div>
  </header>

  <section id="historia">
    <div class="shead reveal"><div class="kick">Contexto regulatorio</div><h2>Por qué existe el CAN</h2>
      <p>Banxico regula los Créditos Asociados a Nómina para dar portabilidad e transparencia al crédito de nómina interbancario. Santander participa como institución <b>ACREEDORA</b> (otorga el crédito) y <b>DEPOSITARIA</b> (recibe la nómina).</p></div>
    <div class="mgrid reveal">
      <div class="mcard glass"><h4>El problema</h4><p>Antes, un crédito de nómina ataba al acreditado a un solo banco. Si cambiaba de empleador o de banco, el descuento se rompía.</p></div>
      <div class="mcard glass"><h4>Mecanismo Art. 63 Bis 3</h4><p>Un hub interbancario operado por <b>CECOBAN</b> — único intermediario — permite consultar, otorgar y portar CANs entre instituciones con mensajes C-50 a C-58.</p></div>
      <div class="mcard glass"><h4>Circular 6/2025</h4><p>Compila y actualiza el marco; define 23 obligaciones para acreedoras y depositarias, con SLAs estrictos (1, 2, 5 DHB y corte 17:00).</p></div>
      <div class="mcard glass"><h4>Impacto Santander</h4><p>Requiere conectarse al hub, generar la Clave Básica Estandarizada, aplicar prelación de cargos y reportar a Banxico y buró.</p></div>
    </div>
  </section>

  <section id="funcional">
    <div class="shead reveal"><div class="kick">Resumen funcional</div><h2>Cómo funciona el CAN</h2>
      <p>Dos roles, un hub central. La prelación la calcula Cecoban; el banco la aplica.</p></div>
    <div class="mgrid reveal">
      <div class="mcard glass"><h4>Institución Acreedora</h4><p>Otorga el CAN. Consulta la cuenta ordenante vía CECOBAN, evalúa capacidad de pago, formaliza con mandato y liquida refinanciamientos por SPEI.</p></div>
      <div class="mcard glass"><h4>Institución Depositaria</h4><p>Lleva la cuenta de nómina. Identifica cuentas ordenantes, comunica saldos en 1 DHB, aplica la prelación y transfiere las prestaciones antes de las 17:00.</p></div>
    </div>
  </section>

  <section id="etb-map">
    <div class="shead reveal"><div class="kick">Banking ETB · Fit &amp; Gap</div><h2>Modelo de capacidades — 3 niveles</h2>
      <p>Capacidades del banco (dominio → subdominio → L3) evaluadas contra CAN. La mayoría están cubiertas; la única brecha real es el Mecanismo CECOBAN. Haz clic en cualquier capacidad para ver los User Stories relacionados.</p></div>
    <div class="etb-legend reveal">
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#86efac;border:1px solid rgba(34,197,94,.4)"></div>Cubierto</div>
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#ffd666;border:1px solid rgba(255,180,0,.4)"></div>Parcial — gaps identificados</div>
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#fca5a5;border:1px solid rgba(236,0,0,.4)"></div>Brecha — capacidad ausente</div>
      <div class="etb-leg"><div class="etb-leg-dot" style="background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1)"></div>No impactada por CAN</div>
    </div>
    <div class="etb-grid reveal">{etb_map}</div>
  </section>

  <section id="flujos">
    <div class="shead reveal"><div class="kick">Mecanismo Art. 63 Bis 3 · Cecoban</div><h2>7 flujos end-to-end del Mecanismo CAN</h2>
      <p>Flujos del Documento de Entendimiento CAN v4.2. Cecoban es el único intermediario; el UUID del C-50 es la llave del ciclo. Cada chevrón es un mensaje (C-50 a C-58).</p></div>
    {flows_html}
  </section>

  <section id="arquitectura">
    <div class="shead reveal"><div class="kick">Arquitectura de la solución CAN</div><h2>Componentes funcionales e integraciones</h2>
      <p>Vista lógica. Los nombres son funcionales — los oficiales están por confirmar. El CECOBAN Gateway es la puerta única al hub; el Motor de Reglas centraliza las reglas de decisión; la prelación la calcula Cecoban y el core la aplica.</p></div>
    <div class="glass reveal" style="padding:24px;overflow-x:auto">{arch_svg}</div>
    <div class="etb-legend reveal" style="margin-top:20px;margin-bottom:0">
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#EC0000;height:3px;width:18px;border-radius:0"></div>Síncrono (REST/HTTPS)</div>
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#ffd666;height:3px;width:18px;border-radius:0"></div>Asíncrono (Kafka)</div>
      <div class="etb-leg"><div class="etb-leg-dot" style="background:#b78f8f;height:3px;width:18px;border-radius:0"></div>Interno</div>
    </div>
  </section>

  <section id="roadmap">
    <div class="shead reveal"><div class="kick">Plan de entrega</div><h2>Roadmap de implementación — {len(phases)} fases · ~17 sprints</h2>
      <p>Escenario optimizado con IA / Digital Brain: fundaciones aceleradas, ACREEDORA y DEPOSITARIA <b>en paralelo</b>, portabilidad, certificación con Cecoban y hypercare. ~17 sprints (~34 semanas · ~8 meses). Fecha límite: <b>[DATO-REQUERIDO]</b>.</p></div>
    <div class="chevrow reveal">{roadmap_chev_html}</div>
    <div class="cardgrid reveal" style="margin-top:26px">{roadmap_card_html}</div>
  </section>

  <section id="equipo">
    <div class="shead reveal"><div class="kick">Equipo de trabajo</div><h2>Squad de delivery CAN — {s['fte']} FTE</h2>
      <p>Equipo en squads alineados a la arquitectura. Cada rol respaldado por un SME de Solutioning. Niveles Accenture México. Las tarifas se modelan en Pricing &amp; Commercial Modeler (<b>[PLACEHOLDER]</b>).</p></div>
    <div class="group reveal"><div class="ghead"><h3>Reparto por organización</h3><span>Quién aporta cada rol</span></div><div class="cardgrid" style="margin-top:14px">{org_cards}</div></div>
    <div class="group reveal" style="margin-top:34px"><div class="ghead"><h3>Detalle por squad</h3><span>Alineados a la arquitectura</span></div><div class="cardgrid" style="margin-top:14px">{team_html}</div></div>
  </section>

  <section id="optimizacion">
    <div class="shead reveal"><div class="kick">Aceleración con IA / Digital Brain</div><h2>Por qué el plan es de ~17 sprints y {s['fte']} FTE</h2>
      <p>El Digital Brain es el output de DISCOVER ya resuelto, lo que convierte al equipo de autor en validador, habilita scaffolding y generación de pruebas, y permite correr squads en paralelo. Piso fijo: la certificación con Cecoban y el sign-off CNBV/Banxico no se comprimen.</p></div>
    <div class="group reveal"><div class="ghead"><h3>Palancas del brain</h3><span>Mecanismos de aceleración</span></div>
      <div class="glass" style="overflow-x:auto;padding:8px;margin-top:12px"><table class="tbl"><thead><tr><th>Palanca</th><th>Activo en el brain</th><th>Impacto</th></tr></thead><tbody>{lever_rows}</tbody></table></div></div>
    <div class="glass reveal" style="margin-top:28px;padding:22px 26px;border-left:3px solid #ffd666">
      <div style="font-size:11px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:#ffd666;margin-bottom:10px">El piso honesto del plan</div>
      <div style="font-size:13px;color:var(--muted);line-height:1.6">El plan ya está en su forma acelerada. Hay un piso fijo: el parallel-run y la certificación con Cecoban dependen del calendario externo de Cecoban y del sign-off CNBV/Banxico. El brain acelera lo analítico y el scaffolding (~30-50%, principio HVM), no las dependencias externas ni la validación regulatoria.</div>
    </div>
  </section>

  <section id="micros">
    <div class="shead reveal"><div class="kick">OneFinancial · Plataforma SaaS Accenture</div><h2>Stack de OneFinancial — donde vivirá el orquestador CAN</h2>
      <p><b>OneFinancial</b> es la plataforma SaaS de Accenture para originación de crédito de nómina. Los 7 microservicios son componentes de esta plataforma — <b>no son sistemas de Santander</b>. El adaptador al Mecanismo Art. 63 Bis 3 se construirá aquí.</p></div>
    <div class="group reveal"><div class="ghead"><h3>Servicios de Negocio</h3><span>Flujo de originación CAN</span></div><div class="cardgrid">{micros_neg}</div></div>
    <div class="group reveal" style="margin-top:32px"><div class="ghead"><h3>Servicios de Infraestructura</h3><span>Soporte transversal</span></div><div class="cardgrid">{micros_inf}</div></div>
  </section>

  <section id="etb">
    <div class="shead reveal"><div class="kick">Banking ETB · Gap analysis</div><h2>Capacidades ETB vs. CAN</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>Capability ETB</th><th>Estado</th><th>Observación</th></tr></thead><tbody>{etb_rows}</tbody></table></div>
    <div class="shead reveal" style="margin-top:48px"><h2>Cobertura por obligación</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>Obligación</th><th>Riesgo</th><th>Sistema</th><th>Cobertura</th><th>Gap</th></tr></thead><tbody>{cov_rows}</tbody></table></div>
  </section>

  <section id="brechas">
    <div class="shead reveal"><div class="kick">Gap analysis</div><h2>Brechas de cumplimiento</h2><p>{s['brechas']} brechas abiertas, {s['criticas']} críticas.</p></div>
    <div class="cardgrid reveal">{brecha_cards}</div>
  </section>

  <section id="slas">
    <div class="shead reveal"><div class="kick">SLAs regulatorios</div><h2>Obligaciones con plazo</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>ID</th><th>Obligación</th><th>Plazo</th><th>Riesgo</th></tr></thead><tbody>{sla_rows}</tbody></table></div>
  </section>

  <section id="cecoban">
    <div class="shead reveal"><div class="kick">Especificación técnica</div><h2>Integración CECOBAN</h2><p>Mecanismo Art. 63 Bis 3 (DE CAN v4.2 + Guía Simulador). REST + Kafka, TLS 1.3, JWT.</p></div>
    {cec_html}
  </section>

  <section id="obligaciones">
    <div class="shead reveal"><div class="kick">Catálogo regulatorio</div><h2>Las 23 obligaciones CAN</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>ID</th><th>Descripción</th><th>Tipo</th><th>Riesgo</th><th>Plazo</th><th>Rol</th></tr></thead><tbody>{obl_rows}</tbody></table></div>
  </section>

  <section id="stories">
    <div class="shead reveal"><div class="kick">Roadmap técnico</div><h2>User Stories y ADRs</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>ID</th><th>Título</th><th>Dónde vive</th><th>Estimación</th></tr></thead><tbody>{story_rows}</tbody></table></div>
    <div class="shead reveal" style="margin-top:48px"><h2>Decisiones de arquitectura (ADRs)</h2></div>
    <div class="glass reveal" style="overflow-x:auto;padding:8px"><table class="tbl"><thead><tr><th>ID</th><th>Título</th><th>Decisión</th><th>Estado</th></tr></thead><tbody>{adr_rows}</tbody></table></div>
  </section>

  <footer>
    Portal generado desde el CAN Brain · <code>SANT-CAN</code> · Santander México · {now}<br>
    Fase <code>DISCOVER + DESIGN</code> · CAN Brain v{esc(ver)} · Design Studio Santander
  </footer>
</div>

<div id="etb-popup" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.72);z-index:9999;align-items:center;justify-content:center;padding:24px">
  <div style="background:#1a0a0a;border:1px solid rgba(255,255,255,.1);border-radius:20px;max-width:560px;width:100%;max-height:80vh;overflow-y:auto;padding:30px 32px">
    <div style="display:flex;align-items:flex-start;gap:14px;margin-bottom:18px">
      <div style="flex:1"><div style="font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);margin-bottom:6px">ETB Capability</div><div style="font-size:17px;font-weight:800;color:#fff" id="pp-title"></div></div>
      <span id="pp-estado" class="chip"></span>
      <button onclick="closeEtb()" style="background:none;border:none;color:var(--muted2);font-size:20px;cursor:pointer;padding:0 4px;line-height:1">✕</button>
    </div>
    <div style="font-size:12.5px;color:var(--muted);margin-bottom:10px" id="pp-desc"></div>
    <div style="font-size:11.5px;color:rgba(255,180,0,.85);background:rgba(255,180,0,.07);border:1px solid rgba(255,180,0,.18);border-radius:8px;padding:10px 14px;margin-bottom:14px" id="pp-nota"></div>
    <div style="margin-bottom:16px"><div style="font-size:9.5px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-bottom:6px">Obligaciones CAN relacionadas</div><div id="pp-obls"></div></div>
    <div><div style="font-size:10px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-bottom:4px">User Stories</div><div id="pp-stories"></div></div>
  </div>
</div>

<script>
window.addEventListener('scroll',function(){{var d=document.documentElement;document.getElementById('prog').style.width=(d.scrollTop/(d.scrollHeight-d.clientHeight)*100)+'%';}});
var sObs=new IntersectionObserver(function(es){{es.forEach(function(e){{if(!e.isIntersecting)return;var el=e.target,t=+el.dataset.target,v=0,st=Math.max(1,t/60);var iv=setInterval(function(){{v=Math.min(v+st,t);el.textContent=Math.floor(v).toLocaleString('es-MX');if(v>=t)clearInterval(iv);}},16);sObs.unobserve(el);}});}},{{threshold:.3}});
document.querySelectorAll('.statn[data-target]').forEach(function(s){{sObs.observe(s);}});
var rObs=new IntersectionObserver(function(es){{es.forEach(function(e){{if(e.isIntersecting){{e.target.classList.add('in');rObs.unobserve(e.target);}}}});}},{{threshold:.08}});
document.querySelectorAll('.reveal').forEach(function(r){{rObs.observe(r);}});
var ETB_DATA={etb_popup_js};
function showEtb(name){{var d=ETB_DATA[name],el=document.getElementById('etb-popup');if(!d||!el)return;
var sh='';if(d.stories&&d.stories.length){{sh=d.stories.map(function(s){{var ec=s.estimacion==='XL'?'red':(s.estimacion==='L'||s.estimacion==='M')?'yellow':'green';
return '<div style="padding:14px 0;border-bottom:1px solid rgba(255,255,255,.07)"><div style="display:flex;align-items:center;gap:8px;margin-bottom:6px"><code style="font-size:10px;color:var(--muted2)">'+s.id+'</code><span class="chip '+ec+'" style="font-size:9px">'+s.estimacion+'</span><span style="font-size:10px;color:var(--muted2)">'+s.sistema+'</span></div><div style="font-size:13px;font-weight:700;color:#fff;margin-bottom:4px">'+s.titulo+'</div><div style="font-size:11.5px;color:var(--muted);line-height:1.5">Quiero '+s.quiero+'</div></div>';}}).join('');}}
else{{sh='<div style="padding:18px 0;color:var(--muted2);font-size:13px;text-align:center">Sin User Stories directamente asociados</div>';}}
document.getElementById('pp-title').textContent=name;
var pe=document.getElementById('pp-estado');pe.className='chip '+(d.estado==='CUBIERTO'?'green':d.estado==='PARCIAL'?'yellow':'red');pe.textContent=d.estado;
document.getElementById('pp-desc').textContent=d.desc||'';document.getElementById('pp-nota').textContent=d.nota||'';
document.getElementById('pp-obls').innerHTML=(d.obligaciones||[]).map(function(o){{return '<span class="chip" style="font-size:9px">'+o+'</span>';}}).join(' ');
document.getElementById('pp-stories').innerHTML=sh;el.style.display='flex';}}
function closeEtb(){{document.getElementById('etb-popup').style.display='none';}}
document.getElementById('etb-popup').addEventListener('click',function(e){{if(e.target===this)closeEtb();}});
</script>
</body></html>"""
    os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"Portal generado: {OUT_PATH}")


if __name__ == "__main__":
    generate(load_data())

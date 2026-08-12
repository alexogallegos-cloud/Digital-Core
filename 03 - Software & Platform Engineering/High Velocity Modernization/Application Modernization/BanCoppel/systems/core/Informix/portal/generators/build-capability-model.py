#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-capability-model.py — Modelo de capacidades bancarias de REFERENCIA
(agnóstico, 10 áreas estilo Accenture Banking) con las capacidades IDENTIFICADAS
en los dominios técnicos de BanCoppel resaltadas (heat de cobertura).
Genera: capability-model-bcop.html · SME Modelo Operativo Bancario"""
import json
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
J = json.load(open(BASE + "portal/data/journeys-data.json", encoding="utf-8"))
BR = json.load(open(BASE + "portal/data/business-rules.json", encoding="utf-8"))
DBOF = {"d01":"bdicnweb","d02":"bdinteg","d03":"bdicred","d04":"bdicheq","d05":"bdisac",
        "d06":"bdisolic","d07":"bdiaclaracion","d08":"bdispei","d09":"bdimnsj","d10":"bdisuc",
        "d11":"bdicobranza","d12":"bdicont","d13":"bditef","d14":"bdibei",
        "d15":"bdilide","d16":"intercard"}
NAME = {"d01":"Canal Digital","d02":"Integración/Auth","d03":"Créditos","d04":"Cheques/Cuentas",
        "d05":"Saldos","d06":"Solicitudes","d07":"Aclaraciones","d08":"SPEI","d09":"Mensajería",
        "d10":"Sucursales","d11":"Cobranza","d12":"Contabilidad","ext":"Externo","reg":"Reguladores",
        "d13":"TEF","d14":"BEI","d15":"LIDE / PLD","d16":"Tarjetas"}
rules_by_db = Counter(r["db"] for r in BR["rules"])

# ── tier de lógica de negocio (sp-validation JSONs) y riesgos del risk register ──
import glob as _g
_DOM_SCORE = {}
for _vf in sorted(_g.glob(BASE + "knowledge-base/sp-validation-*.json")):
    _vdata = json.load(open(_vf, encoding="utf-8"))
    if not _vdata: continue
    _db = _vf.split("sp-validation-")[-1].replace(".json","")
    _dk = next((k for k,v in DBOF.items() if v == _db), None)
    if not _dk: continue
    _n = len(_vdata)
    _DOM_SCORE[_dk] = (sum(sp["rules_n"] for sp in _vdata) + sum(sp["tables_n"] for sp in _vdata)) / _n
# h=núcleo (≥12), m=mixto (≥8), l=conector (<8)
DOM_TIER = {dk: ("h" if sc >= 12 else "m" if sc >= 8 else "l") for dk, sc in _DOM_SCORE.items()}
# Riesgos operativos del risk register activos N5/N4/N3
DOM_RISK = {
    "d01": "critical",  # P655-R001/R002 — 2×N5 DEFECTO-PROD activos
    "d11": "critical",  # P655-R009/R010/R011 — N4+2×N3
    "d05": "warn",      # P655-R003/R008 — N3+N2 (remesas/integración)
    "d08": "warn",      # P655-R005 — ESB integraciones externas N3
    "d13": "warn",      # P655-R005 — ESB integraciones externas N3
    "d14": "warn",      # P655-R005 — ESB integraciones externas N3
    "d02": "warn",      # P655-R006 — N2 autenticación
}
def m(d):
    if d in DBOF:
        return {"j": len(J[d]["journeys"])+len(J[d].get("exposed",[])), "r": rules_by_db.get(DBOF[d],0), "s": J[d]["sp_count"], "n": NAME[d]}
    return {"j":0,"r":0,"s":0,"n":NAME.get(d,d)}

# ── drill-down: procesos (journeys) por dominio con objetivo de negocio + flujo ejecutivo ──
import json as _json, re as _re, os as _os
# ── failures-registry.json → incidentes activos por dominio ──
_fail_path = _os.path.join(BASE, 'knowledge-base/failures-registry.json')
if _os.path.exists(_fail_path):
    _FAILS_RAW = _json.loads(open(_fail_path, encoding='utf-8-sig').read())
    FAILURES_BY_DOM = {}
    for _inc in _FAILS_RAW.get('incidents', []):
        _d = _inc['domain'].lower()
        FAILURES_BY_DOM.setdefault(_d, []).append(_inc)
else:
    FAILURES_BY_DOM = {}
FAILURES_JSON = _json.dumps(FAILURES_BY_DOM, ensure_ascii=False)
NAME_LARGO = {"d01":"Canal Digital Web","d02":"Integración y Autenticación","d03":"Créditos",
  "d04":"Cheques y Cuentas","d05":"Saldos y Cuentas","d06":"Solicitudes","d07":"Aclaraciones",
  "d08":"Pagos SPEI","d09":"Mensajería","d10":"Sucursales","d11":"Cobranza","d12":"Contabilidad"}

# prosa regulatoria explícita — define el negocio del concepto normativo, sin taquigrafía
REG_PROSA = {
 "art61": ("En el plano regulatorio, el Artículo 61 de la Ley de Instituciones de Crédito obliga al banco "
           "a identificar las cuentas sin movimiento durante tres años: sus saldos se concentran en una "
           "cuenta global y, si permanecen inactivas seis años y no superan el umbral que marca la ley, "
           "prescriben a favor del patrimonio de la beneficencia pública."),
 "spei":  ("En el plano regulatorio, SPEI es el sistema de pagos electrónicos interbancarios operado por "
           "Banxico para transferencias entre instituciones en tiempo casi real."),
 "codi":  ("En el plano regulatorio, CoDi es la plataforma de cobros digitales de Banxico (vigente desde "
           "2019) que usa códigos QR y mensajes de cobro sobre la infraestructura de SPEI."),
}
def _reg_prosa(sp):
    low = sp.lower()
    if "art61" in low:                              return REG_PROSA["art61"]
    if _re.search(r"\bspei", low):                  return REG_PROSA["spei"]
    if _re.search(r"(?<!de)codi(?![gf])", low):     return REG_PROSA["codi"]
    return ""

def _flow_prosa(flow):
    """Convierte los pasos del flujo en prosa con conectores, no en flechas."""
    conect = ["primero", "luego", "después", "y finalmente"]
    pasos = [f"{conect[min(i, 3)]} {p}" for i, p in enumerate(flow[:4])]
    return ", ".join(pasos)

def biz_desc(jj, d, trig, flow):
    """Descripción de negocio EJECUTIVA: objetivo + contexto + disparador + regulatorio + doc del código."""
    biz = jj.get("biz") or jj["sp"]
    dom = NAME_LARGO.get(d, d)
    s = f"Proceso del dominio <b>{dom}</b> cuyo objetivo es <b>{biz}</b>. "
    if trig and trig != "App/Batch/Canal":
        s += f"Se invoca desde {trig}. "
    elif trig:
        s += "Se ejecuta por invocación directa de la aplicación/canal o por proceso batch. "
    if flow:
        s += f"A alto nivel: {_flow_prosa(flow)}. "
    reg_txt = _reg_prosa(jj.get("sp", ""))
    if reg_txt:
        s += reg_txt + " "
    elif jj.get("reg"):
        s += "Tiene implicación regulatoria: debe validarse el cumplimiento con el SME correspondiente. "
    # documentación real del código (headers que dejó el desarrollador)
    doc = (jj.get("src") or {}).get("doc") or []
    doc_utiles = [d0 for d0 in doc if not _re.match(r"(Fecha|Autor|Realiz|Modific)\s*:", d0, _re.I)]
    if doc_utiles:
        s += f"Según el código: «{doc_utiles[0][:120]}». "
    elif doc:
        s += f"(Bitácora del código: {doc[0][:60]}) "
    return s.strip()

DOMDATA = {}
for d, dd in J.items():
    procs = []
    for jj in dd["journeys"]:
        flow = [(s.get("biz") or s["name"]) for s in jj.get("steps", [])][:6]
        trig = ", ".join("App/Batch/Canal" if t["dom"] == "app" else t["dom"].upper()
                         for t in jj.get("triggered_by", []))
        procs.append({"biz": jj.get("biz") or jj["sp"], "sp": jj["sp"], "fo": jj["fan_out"],
                      "trig": trig, "flow": flow, "reg": jj.get("reg", False),
                      "desc": biz_desc(jj, d, trig, flow)})
    exposed = [{"biz": jj.get("biz") or jj["sp"], "sp": jj["sp"], "ext": jj["ext_callers"]}
               for jj in dd.get("exposed", [])]
    DOMDATA[d] = {"name": NAME[d], "procs": procs, "exposed": exposed,
                  "reglas": rules_by_db.get(DBOF[d], 0), "sps": dd["sp_count"]}
DOMDATA_JSON = _json.dumps(DOMDATA, ensure_ascii=False)

# ── MODELO DE REFERENCIA (10 áreas). cada capacidad: (nombre, dominio|None) ──
# dominio => identificada en BanCoppel (se resalta) · None => referencia no identificada en el core
N=None
MODEL = [
 ("1 · Ecosystem Management", [("Ecosystem Partner Management",
    [("Onboarding",N),("Partnering means",N),("Agreements & SLA",N),("Review",N)])]),
 ("2 · Channels", [
   ("Assisted Touchpoints",[("Teller","d10"),("Retail Salesforce",N),("Contact Centre (Phone)","d01"),
     ("Contact Centre (Web)","d01"),("Relationship Manager",N),("Mail",N),("Social Media",N)]),
   ("Un-Assisted Touchpoints",[("IVR","d01"),("Kiosk / SST","d10"),("Web (BPI)","d01"),("Mobile","d01"),
     ("SMS","d09"),("ATM","d10"),("PoS","d10")]),
   ("",[("Affiliate & Partner Channels",N),("Device Management",N)])]),
 ("3 · Marketing & Distribution", [("",
    [("Marketing",N),("Digital Marketing",N),("Sales Management",N),("Contract Management","d03"),
     ("Illustration Management",N),("Customer Finance Management","d03"),("Brand Management",N)])]),
 ("4 · Common Customer View", [
   ("Customer View",[("Demographics","d06"),("Holdings","d05"),("Roles & Relationships",N),
     ("Ref. Satellite",N),("Segmentation",N)]),
   ("",[("Registration","d06"),("Authentication","d02")]),
   ("Preferences",[("Needs and offer",N),("Goals",N),("Communication","d09")]),
   ("",[("Sentiment & Feedback",N),("Personalisation",N)]),
   ("Authorisations",[("Operations author","d02"),("Delegations, PoA",N),("Signatures","d10")]),
   ("",[("Prospect Management",N)])]),
 ("5 · Product Processing", [("Product Catalogue",
    [("Deposits","d04"),("Lending","d03"),("Corp Finance",N),("Asset Mgmt.","ext"),("Insurance",N),
     ("FX",N),("Cards","d03"),("Non Financial Products & Services",N),("Custody & Funded Adm.",N)])]),
 ("6 · Common Services", [
   ("",[("Master Contract Mgmt.","d03"),("Cash Mgmt.",N),("Payments","d08"),("Statements","d05"),("Interest & Fees","d04")]),
   ("Risk",[("Operational",N),("Financial","d03")]),
   ("",[("AML",N),("Fraud",N)]),
   ("Complaints",[("Analysis","d07"),("Follow up","d07"),("Closing","d07")]),
   ("",[("Collections & Recovery","d11"),("Compliance & Regulation","reg"),("Pricing Management",N),("Treasury",N)]),
   ("Customer Services",[("Financial Servicing","d04"),("Non Financial Servicing","d09"),("Intelligent Servicing (RPA)",N)]),
   ("Reconciliations",[("Financial Reconciliation","d12"),("Operational Reconciliation","d12")])]),
 ("7 · Enterprise Support Functions", [("",
    [("Finance",N),("Talent & Organisation",N),("IT",N),("Corporate Services",N)])]),
 ("8 · Technology Tools", [("",
    [("Scheduling",N),("Business Process Mgmt.",N),("AI Tools",N),("EA Tools",N),
     ("Document Management",N),("Collaboration & Productivity",N),("Project Management",N),("RPA Tools",N)])]),
 ("9 · Insights & Information", [("",
    [("Operational Data Stores",N),("Event Streams",N),("Data Lakes",N)])]),
 ("10 · Integration & Interfaces", [("Interface Management",
    [("Access Control","d02"),("Traffic Management",N),("API Catalogue",N)])]),
 ("Transversal · Interfaces & Seguridad", [
   ("External Interfaces",[("API",N),("EDI",N),("Payment Schemes","d08"),("Cloud Integration",N)]),
   ("Internal Interfaces",[("API",N),("ESB",N),("MQ","d09"),("Others",N)]),
   ("Datos & Seguridad",[("Master Data Mgmt.",N),("Metadata Mgmt.",N),("Content Mgmt.",N),
     ("Analytics / Reporting",N),("Security","d02")])]),
]

# contar cobertura
allcaps=[(c,d) for _,groups in MODEL for _,caps in groups for c,d in caps]
cov=sum(1 for _,d in allcaps if d); tot=len(allcaps)
doms_cubiertos=sorted({d for _,d in allcaps if d and d in DBOF})

def render_cap(c,d):
    if d:
        mm=m(d); badge="EXT" if d=="ext" else ("REG" if d=="reg" else d.upper())
        return (f'<div class="cap on" data-did="{d}" data-n="{c}" data-dom="{mm["n"]}" data-b="{badge}" '
                f'data-j="{mm["j"]}" data-r="{mm["r"]}" data-s="{mm["s"]}">'
                f'<span class="cn">{c}</span><span class="cb">{badge}</span></div>')
    return f'<div class="cap off"><span class="cn">{c}</span></div>'

areas=""
for title,groups in MODEL:
    gh=""
    for gname,caps in groups:
        caps_html="".join(render_cap(c,d) for c,d in caps)
        gh+=(f'<div class="grp">{f"<div class=gl>{gname}</div>" if gname else ""}'
             f'<div class="caps">{caps_html}</div></div>')
    areas+=f'<div class="area"><div class="atitle">{title}</div><div class="agroups">{gh}</div></div>'

HTML=f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BanCoppel · Modelo de Capacidades Bancarias (referencia + cobertura)</title>
<style>
:root{{--bg:#14142b;--bg2:#1A1A2E;--panel:#1f1f3a;--line:#2c2c50;--txt:#E8E8F0;--muted:#9a9ab5;
  /* tema REFERENCIA (rojo, como el modelo de referencia) */
  --on:#c8102e;--on-sh:rgba(200,16,46,.4);--acc:#c8102e;--head1:#001a4d;--head2:#1a004d;--hbar:#A100FF}}
/* BanCoppel — colores oficiales Design Studio (Ancla #122FB1 · Señal #F0D224); en fondo oscuro el fill usa el tinte #2E52C8 del Ancla para que las cajas resalten */
body[data-theme=bcop]{{--bg:#0a1024;--bg2:#0d1533;--panel:#111c47;--line:#26317c;
  --on:#2E52C8;--on-sh:rgba(46,82,200,.55);--acc:#F0D224;--head1:#0d2185;--head2:#122FB1;--hbar:#F0D224}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh;transition:background .3s}}
header{{background:linear-gradient(135deg,var(--head1),var(--head2));border-bottom:2px solid var(--hbar);padding:12px 24px;position:sticky;top:0;z-index:10}}
.brand{{display:flex;align-items:center;gap:13px}}
.logo{{height:24px;flex-shrink:0;filter:drop-shadow(0 1px 2px rgba(0,0,0,.45))}}
header h1{{font-size:16px;font-weight:800}}header .sub{{font-size:10px;color:var(--muted);margin-top:2px}}
#bar{{padding:10px 24px;display:flex;gap:10px;align-items:center;flex-wrap:wrap}}
.tile{{background:var(--panel);border-radius:8px;padding:6px 13px;border-left:3px solid var(--acc)}}
.tile .n{{font-size:17px;font-weight:800}}.tile .l{{font-size:8px;color:var(--muted);text-transform:uppercase}}
#leg{{font-size:10px;color:var(--muted);display:flex;gap:16px;flex-wrap:wrap;align-items:center;margin-left:auto}}
#leg .sw{{display:inline-block;width:12px;height:12px;border-radius:2px;vertical-align:middle;margin-right:4px}}
#wrap{{padding:6px 24px 24px;max-width:1500px;margin:0 auto}}
.area{{display:flex;gap:12px;background:var(--bg2);border:1px solid var(--line);border-radius:8px;margin-bottom:8px;padding:10px 12px}}
.atitle{{min-width:150px;max-width:150px;font-size:12px;font-weight:800;color:#c4b5fd;padding-top:2px}}
.agroups{{flex:1;display:flex;flex-wrap:wrap;gap:10px}}
.grp{{background:rgba(0,0,0,.15);border-radius:6px;padding:6px}}
.gl{{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:4px;padding-left:2px}}
.caps{{display:flex;flex-wrap:wrap;gap:5px}}
.cap{{border-radius:5px;padding:6px 9px;font-size:10px;min-width:96px;display:flex;flex-direction:column;gap:3px}}
.cap.on{{background:var(--on);color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 4px var(--on-sh)}}
.cap.on:hover{{filter:brightness(1.15)}}
.cap.off{{background:#33334d;color:#8a8aa5}}
.cap .cn{{line-height:1.2}}
.cap .cb{{font-size:7px;font-weight:800;opacity:.85;letter-spacing:.05em}}
/* panel de drill-down ejecutivo */
#dpanel{{position:fixed;top:0;right:-52%;width:50%;max-width:760px;height:100vh;background:var(--bg2);
  border-left:2px solid var(--acc);z-index:200;transition:right .3s cubic-bezier(.4,0,.2,1);
  box-shadow:-12px 0 40px rgba(0,0,0,.6);display:flex;flex-direction:column}}
#dpanel.open{{right:0}}
#dhead{{padding:16px 22px;border-bottom:1px solid var(--line);background:linear-gradient(135deg,var(--head1),var(--head2));flex-shrink:0}}
#dhead .dcap{{font-size:19px;font-weight:800;color:#fff}}
#dhead .dsub{{font-size:11px;color:#c9d6e8;margin-top:3px}}
#dhead .dstat{{display:flex;gap:14px;margin-top:8px;font-size:10px;color:#c9d6e8}}
#dhead .dstat b{{color:#fff;font-size:14px}}
#dclose{{position:absolute;top:14px;right:18px;cursor:pointer;color:#fff;font-size:20px;background:none;border:none;opacity:.8}}
#dclose:hover{{opacity:1}}
#dbody{{flex:1;overflow-y:auto;padding:16px 22px}}
.proc{{background:var(--panel);border-radius:9px;border-left:4px solid var(--on);padding:13px 15px;margin-bottom:11px}}
.proc .pbiz{{font-size:14px;font-weight:800;color:var(--txt);line-height:1.25}}
.proc .pdesc{{font-size:11.5px;color:#c9d2e0;line-height:1.5;margin-top:6px}}
.proc .pdesc b{{color:#fff}}
.proc .psp{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:var(--muted);margin-top:6px}}
.proc .ptrig{{font-size:10px;color:var(--muted);margin-top:6px}}.proc .ptrig b{{color:#9ab0d0}}
.proc .flabel{{font-size:8px;font-weight:700;letter-spacing:.08em;color:var(--muted);text-transform:uppercase;margin:9px 0 5px}}
.flow{{display:flex;flex-wrap:wrap;align-items:center;gap:4px}}
.step{{background:rgba(30,123,224,.14);border:1px solid var(--on);color:var(--txt);border-radius:6px;padding:3px 9px;font-size:10px}}
.arr{{color:var(--acc);font-weight:800;font-size:12px}}
.proc.regp{{border-left-color:var(--acc)}}.regtag{{font-size:8px;font-weight:800;background:var(--acc);color:#1a1a19;padding:1px 6px;border-radius:8px;margin-left:6px}}
.dsec{{font-size:10px;font-weight:700;letter-spacing:.08em;color:var(--acc);text-transform:uppercase;margin:14px 0 8px}}
.expo{{display:inline-flex;flex-direction:column;background:var(--panel);border-radius:7px;padding:8px 11px;margin:0 6px 6px 0;border-left:3px solid var(--muted)}}
.expo .eb{{font-size:11px;font-weight:700}}.expo .es{{font-family:monospace;font-size:9px;color:var(--muted)}}
#dscrim{{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:150;display:none}}
#tip{{position:fixed;background:rgba(22,22,44,.98);border:1px solid var(--line);border-radius:8px;padding:10px 13px;font-size:11px;pointer-events:none;display:none;z-index:99;max-width:250px;box-shadow:0 4px 20px rgba(0,0,0,.7)}}
#tip .tt{{font-weight:700;font-size:12px;margin-bottom:4px}}#tip .tr{{font-size:10px;color:var(--muted);margin:2px 0}}#tip .tr b{{color:var(--txt)}}
footer{{font-size:9px;color:var(--muted);padding:10px 24px;border-top:1px solid var(--line);line-height:1.5}}
</style></head><body data-theme="bcop">
<header><div class="brand"><img class="logo" src="bancoppel-logo.png" alt="BanCoppel"><div><h1>Modelo de Capacidades Bancarias · Referencia (agnóstico) — Cobertura BanCoppel BCOPCore</h1>
<div class="sub">SME — Modelo Operativo Bancario · 10 áreas de referencia · ● = identificado en los dominios técnicos · ⬜ = capacidad de referencia no vista en el core</div></div></div></header>
<div id="bar">
  <div class="tile"><div class="n">{cov}/{tot}</div><div class="l">Capacidades cubiertas</div></div>
  <div class="tile"><div class="n">{100*cov//tot}%</div><div class="l">Cobertura del modelo</div></div>
  <div class="tile"><div class="n">{len(doms_cubiertos)}/12</div><div class="l">Dominios mapeados</div></div>
  <div id="leg"><span><span class="sw" style="background:var(--on)"></span>Identificado en BanCoppel (hover = dominio)</span>
    <span><span class="sw" style="background:#33334d"></span>Modelo de referencia (gap / soporte)</span></div>
</div>
<div id="wrap">{areas}</div>
<footer>Modelo de capacidades bancarias de <b>referencia</b> (agnóstico, ~L0-L2). Las cajas <b style="color:var(--on)">resaltadas</b> son capacidades <b>identificadas en el core Informix de BanCoppel</b> (mapeadas a los 12 dominios técnicos); las grises son parte del modelo de referencia pero <b>no observadas en el core</b> — típicamente capas de ecosistema, marketing, insights, plataforma de integración y soporte que la modernización debe <b>incorporar</b>. Mapeo curado por el SME de Modelo Operativo Bancario · <code>[SME-PENDING]</code> validación con Domain Expert.</footer>
<div id="tip"></div>
<div id="dscrim" onclick="closeDrill()"></div>
<div id="dpanel">
  <div id="dhead"><button id="dclose" onclick="closeDrill()">&#x2715;</button>
    <div class="dcap" id="d-cap">—</div><div class="dsub" id="d-sub"></div>
    <div class="dstat" id="d-stat"></div></div>
  <div id="dbody"></div>
</div>
<script>
const DOMDATA={DOMDATA_JSON};
function closeDrill(){{document.getElementById('dpanel').classList.remove('open');document.getElementById('dscrim').style.display='none';}}
function openDrill(did,capName){{
  const d=DOMDATA[did];
  const body=document.getElementById('dbody');
  document.getElementById('d-cap').textContent=capName;
  if(!d){{
    document.getElementById('d-sub').textContent='Capacidad sin dominio técnico en el core (externo / plataforma / gap)';
    document.getElementById('d-stat').innerHTML='';
    body.innerHTML='<div style="color:var(--muted);font-size:12px;padding:20px 0">Esta capacidad es parte del modelo de referencia pero <b>no se implementa en el core Informix</b> — vive en un sistema externo, es plataforma transversal, o es un gap que la modernización debe incorporar.</div>';
  }} else {{
    document.getElementById('d-sub').innerHTML=`Capacidad implementada por el dominio <b>${{d.name}}</b> · procesos identificados en el código`;
    document.getElementById('d-stat').innerHTML=`<span><b>${{d.procs.length}}</b> procesos orquestados</span><span><b>${{d.exposed.length}}</b> servicios expuestos</span><span><b>${{d.reglas}}</b> reglas de negocio</span><span><b>${{Number(d.sps).toLocaleString('es-MX')}}</b> SPs</span>`;
    let h='';
    if(d.procs.length){{
      h+='<div class="dsec">Procesos de negocio (flujo a alto nivel)</div>';
      d.procs.forEach(p=>{{
        const flow=p.flow.length? '<div class="flabel">Flujo</div><div class="flow">'+
          p.flow.map((s,i)=>`${{i?'<span class=arr>&rarr;</span>':''}}<span class="step">${{s}}</span>`).join('')+'</div>':'';
        h+=`<div class="proc ${{p.reg?'regp':''}}">
          <div class="pbiz">${{p.biz}}${{p.reg?'<span class="regtag">REGULATORIO</span>':''}}</div>
          <div class="pdesc">${{p.desc}}</div>
          <div class="psp">${{p.sp}} · fan_out ${{p.fo}}</div>
          <div class="ptrig">Disparado por: <b>${{p.trig||'—'}}</b></div>${{flow}}</div>`;
      }});
    }}
    if(d.exposed.length){{
      h+='<div class="dsec">Servicios expuestos (endpoints)</div>';
      d.exposed.forEach(e=>{{h+=`<div class="expo"><span class="eb">${{e.biz}}</span><span class="es">${{e.sp}} · ${{e.ext}} callers</span></div>`;}});
    }}
    body.innerHTML=h;
  }}
  document.getElementById('dpanel').classList.add('open');
  document.getElementById('dscrim').style.display='block';
}}
const tip=document.getElementById('tip');
document.querySelectorAll('.cap.on').forEach(c=>{{
 c.onmousemove=e=>{{tip.innerHTML=`<div class="tt">${{c.dataset.n}}</div>
   <div class="tr">Dominio: <b>${{c.dataset.b}} · ${{c.dataset.dom}}</b></div>
   <div class="tr">Journeys: <b>${{c.dataset.j}}</b> · Reglas: <b>${{c.dataset.r}}</b> · SPs: <b>${{Number(c.dataset.s).toLocaleString('es-MX')}}</b></div>
   <div class="tr" style="color:#c4b5fd">▸ Click para ver procesos y flujo</div>`;
   tip.style.display='block';tip.style.left=Math.min(e.clientX+14,innerWidth-265)+'px';tip.style.top=(e.clientY+12)+'px';}};
 c.onmouseleave=()=>tip.style.display='none';
 c.onclick=()=>{{tip.style.display='none';openDrill(c.dataset.did,c.dataset.n);}};
}});
document.addEventListener('keydown',e=>{{if(e.key==='Escape')closeDrill();}});
</script></body></html>"""
open(BASE+"old/capability-model-bcop.html","w",encoding="utf-8").write(HTML)
print(f"capability-model-bcop.html escrito · {cov}/{tot} capacidades cubiertas ({100*cov//tot}%) · {len(doms_cubiertos)}/12 dominios")
print("  áreas del modelo de referencia:", len(MODEL))

# ══════════════════════════════════════════════════════════════════════════════
# V2 — Taxonomía BanCoppel AS-IS · 7 dominios · 27 subdominios · 67 capacidades
# ══════════════════════════════════════════════════════════════════════════════
# D01-D16: todos analizados en BCOPBrain (azul Ancla #2E52C8)

PENDING_DBS = set()  # vacío — D13-D16 grounding pass completado

def m2(d):
    if d in DBOF:
        return {"j": len(J[d]["journeys"])+len(J[d].get("exposed",[])),
                "r": rules_by_db.get(DBOF[d],0), "s": J[d]["sp_count"],
                "n": NAME[d]}
    return {"j":0,"r":0,"s":0,"n":NAME.get(d,d)}

N2 = None  # gap ETB — capacidad de referencia no implementada en BCOPCore Informix

MODEL_V2 = [
  ("1 · Cliente y Onboarding", [
    ("Perfil del Cliente", [
      ("Creación del Perfil","d06"),("Actualización del Perfil","d06"),
      ("Consulta del Perfil","d06")]),
    ("Onboarding y KYC", [
      ("Solicitud de Producto","d06"),("Verificación de Identidad","d06"),
      ("Lista Negra / LIDE","d15"),
      ("eKYC / Verificación Biométrica",N2),
      ("Screening PEP / OFAC / ONU",N2)]),
    ("Autenticación e Identidad Digital", [
      ("Autenticación por Canal","d02"),("Gestión de Sesión","d02"),
      ("Biometría / MFA Avanzado",N2),
      ("Open ID / Federated SSO",N2)]),
    ("Mantenimiento y Cancelación", [
      ("Modificación de Datos","d06"),("Cancelación de Relación","d06"),
      ("Gestión de Consentimientos LFPDPPP",N2)]),
  ]),
  ("2 · Captación y Saldos", [
    ("Cuenta de Ahorro", [
      ("Apertura Cuenta de Ahorro","d05"),("Consulta de Saldo","d05"),
      ("Registro de Movimientos","d05"),("Estado de Cuenta","d05"),
      ("Cancelación Cuenta Ahorro","d05")]),
    ("Cuenta de Cheques", [
      ("Apertura Cuenta de Cheques","d04"),("Emisión y Gestión de Cheques","d04"),
      ("Consulta y Movimientos Cheques","d04"),("Cancelación Cuenta Cheques","d04")]),
    ("Saldos y Posición Financiera", [
      ("Saldo Consolidado por Cliente","d05"),("Posición de Caja","d10")]),
    ("Productos de Inversión", [
      ("Depósito a Plazo / Pagaré",N2),
      ("Ahorro Programado / Metas",N2),
      ("CETES Directo / Fondeo de Inversión",N2)]),
  ]),
  ("3 · Crédito al Consumo", [
    ("Originación de Crédito", [
      ("Solicitud de Crédito","d06"),("Autorización de Crédito","d03"),
      ("Disposición del Crédito","d03"),
      ("Scoring Buró de Crédito Externo",N2)]),
    ("Administración de Cartera", [
      ("Cálculo de Intereses","d04"),("Ciclo de Corte","d03"),
      ("Registro de Pagos de Crédito","d03")]),
    ("Cobranza y Recuperación", [
      ("Gestión de Mora Temprana","d11"),("Gestión de Mora Tardía","d11"),
      ("Castigo de Cartera","d11"),("Recuperación Post-Castigo","d11"),
      ("Reestructuras y Quitas","d11")]),
    ("Otros Productos de Crédito", [
      ("Crédito Hipotecario",N2),
      ("Crédito Automotriz",N2),
      ("Crédito PYME / Empresarial",N2),
      ("BNPL / Compra a Plazos Digital",N2)]),
  ]),
  ("4 · Tarjetas BanCoppel", [
    ("Gestión del Plástico", [
      ("Emisión de Tarjeta","d16"),("Activación de Tarjeta","d16"),
      ("Bloqueo y Desbloqueo","d16"),("Reposición de Tarjeta","d16"),
      ("Tarjeta Virtual",N2)]),
    ("Operación de Tarjeta", [
      ("Autorización de Compra","d16"),("Control de Límites","d04"),
      ("3D Secure v2",N2),
      ("Apple Pay / Google Pay",N2)]),
    ("Beneficios y Fidelización", [
      ("Gestión de Recompensas / Puntos",N2),
      ("Cashback",N2),
      ("Vinculación de Seguros",N2)]),
  ]),
  ("5 · Pagos y Transferencias", [
    ("Pagos Interbancarios SPEI", [
      ("Transferencia SPEI Saliente","d08"),("Transferencia SPEI Entrante","d08"),
      ("CoDi — Cobro Digital","d08")]),
    ("Transferencias TEF", [
      ("TEF entre Cuentas Propias","d13"),("TEF a Terceros BanCoppel","d13")]),
    ("Pagos de Servicios", [
      ("Pago de Servicio (Convenio)","d08"),("Gestión de Convenios","d08"),
      ("Domiciliación / Débito Automático",N2)]),
    ("Remesas Internacionales", [
      ("Recepción de Remesa APPRIZA","d05"),("Envío de Remesa","d05"),
      ("Transferencia Internacional SWIFT",N2)]),
    ("Pagos Emergentes", [
      ("DiMo — Dinero Móvil",N2),
      ("Open Banking — Pagos API",N2),
      ("QR Interoperable (no CoDi)",N2)]),
  ]),
  ("6 · Canales y Distribución", [
    ("Canal Digital", [
      ("Banca en Línea Web","d01"),("Banca Móvil","d01"),
      ("Atención Telefónica / IVR","d01"),
      ("Chat Banking (WhatsApp / Bot)",N2)]),
    ("Canal Físico", [
      ("Sucursales BanCoppel","d10"),("Cajeros ATM","d10"),
      ("Videoconferencia con Asesor",N2)]),
    ("Corresponsalía — Tiendas Coppel", [
      ("Operaciones de Caja en Tienda","d10"),("Gestión de Caja BTS","d10")]),
    ("Banca Electrónica Institucional", [
      ("Acceso Empresarial BEI","d14"),("Pagos y Dispersiones Masivas","d14")]),
    ("Open Banking / APIs", [
      ("Open Banking API (PSD2-like)",N2),
      ("Agregación de Cuentas Externas",N2)]),
  ]),
  ("7 · Finanzas y Cumplimiento", [
    ("Contabilidad y Libro Mayor", [
      ("Libro Mayor (GL)","d12"),("Cierre Contable Diario","d12"),
      ("Reportes Serie R (CNBV)","d12"),
      ("Reportería Regulatoria Automatizada",N2)]),
    ("PLD / AML", [
      ("Monitoreo de Transacciones","d15"),("Lista LIDE","d15"),
      ("Reportes PLD a UIF","d15"),
      ("Análisis de Red / ML AML",N2)]),
    ("Cumplimiento Regulatorio", [
      ("Obligaciones CNBV","d12"),("Obligaciones Banxico — SPEI","d08"),
      ("Obligaciones CONDUSEF","d07"),
      ("IFRS 9 / Pérdida Esperada",N2)]),
    ("Gestión de Riesgo Financiero", [
      ("ICAP / Capital Regulatorio Basilea III",N2),
      ("Gestión de Liquidez / LCR",N2),
      ("Stress Testing CNBV",N2)]),
    ("Aclaraciones y Disputas", [
      ("Recepción de Aclaración","d07"),("Resolución de Aclaración","d07")]),
  ]),
]

DOMDATA_V2 = dict(DOMDATA)
DOMDATA_V2_JSON = _json.dumps(DOMDATA_V2, ensure_ascii=False)

allcaps2 = [(c,d) for _,groups in MODEL_V2 for _,caps in groups for c,d in caps]
tot2    = len(allcaps2)
cov2    = sum(1 for _,d in allcaps2 if d is not None)   # en código (azul + amarillo)
gap2    = tot2 - cov2                                    # gaps ETB (gris)
pend2   = sum(1 for _,d in allcaps2 if d in PENDING_DBS) # D13-D16 amarillo
analized2 = cov2 - pend2                                 # D01-D12 azul

def render_cap_v2(c, d):
    if d is None:
        return f'<div class="cap off"><span class="cn">{c}</span></div>'
    mm = m2(d)
    badge = d.upper()
    tier = DOM_TIER.get(d, "m")
    risk = DOM_RISK.get(d, "")
    css_cls = "cross" if d in PENDING_DBS else f"on-{tier}"
    risk_html = ('<span class="wb wc">!</span>' if risk == "critical"
                 else '<span class="wb ww">!</span>' if risk == "warn"
                 else "")
    return (f'<div class="cap {css_cls}" data-did="{d}" data-n="{c}" data-dom="{mm["n"]}" data-b="{badge}" '
            f'data-j="{mm["j"]}" data-r="{mm["r"]}" data-s="{mm["s"]}" data-risk="{risk}">'
            f'<span class="cn">{c}</span><span class="cb">{badge}</span>{risk_html}</div>')

areas2 = ""
for title, groups in MODEL_V2:
    gh = ""
    for gname, caps in groups:
        caps_html = "".join(render_cap_v2(c,d) for c,d in caps)
        gh += (f'<div class="grp">{f"<div class=gl>{gname}</div>" if gname else ""}'
               f'<div class="caps">{caps_html}</div></div>')
    areas2 += f'<div class="area"><div class="atitle">{title}</div><div class="agroups">{gh}</div></div>'

HTML_V2=f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BanCoppel · Gemelo Cognitivo · Taxonomía de Negocio AS-IS</title>
<style>
:root{{--bg:#14142b;--bg2:#1A1A2E;--panel:#1f1f3a;--line:#2c2c50;--txt:#E8E8F0;--muted:#9a9ab5;
  --on:#c8102e;--on-sh:rgba(200,16,46,.4);--acc:#c8102e;--head1:#001a4d;--head2:#1a004d;--hbar:#A100FF}}
body[data-theme=bcop]{{--bg:#0a1024;--bg2:#0d1533;--panel:#111c47;--line:#26317c;
  --on:#2E52C8;--on-sh:rgba(46,82,200,.55);--acc:#F0D224;--head1:#0d2185;--head2:#122FB1;--hbar:#F0D224}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh;transition:background .3s}}
header{{background:linear-gradient(135deg,var(--head1),var(--head2));border-bottom:2px solid var(--hbar);padding:12px 24px;position:sticky;top:0;z-index:10}}
.brand{{display:flex;align-items:center;gap:13px}}
.logo{{height:24px;flex-shrink:0;filter:drop-shadow(0 1px 2px rgba(0,0,0,.45))}}
header h1{{font-size:16px;font-weight:800}}header .sub{{font-size:10px;color:var(--muted);margin-top:2px}}
#bar{{padding:10px 24px;display:flex;gap:10px;align-items:center;flex-wrap:wrap}}
.tile{{background:var(--panel);border-radius:8px;padding:6px 13px;border-left:3px solid var(--acc)}}
.tile .n{{font-size:17px;font-weight:800}}.tile .l{{font-size:8px;color:var(--muted);text-transform:uppercase}}
#leg{{font-size:10px;color:var(--muted);display:flex;gap:16px;flex-wrap:wrap;align-items:center;margin-left:auto}}
#leg .sw{{display:inline-block;width:12px;height:12px;border-radius:2px;vertical-align:middle;margin-right:4px}}
#wrap{{padding:6px 24px 24px;max-width:1500px;margin:0 auto}}
.area{{display:flex;gap:12px;background:var(--bg2);border:1px solid var(--line);border-radius:8px;margin-bottom:8px;padding:10px 12px}}
.atitle{{min-width:158px;max-width:158px;font-size:12px;font-weight:800;color:#c4b5fd;padding-top:2px}}
.agroups{{flex:1;display:flex;flex-wrap:wrap;gap:10px}}
.grp{{background:rgba(0,0,0,.15);border-radius:6px;padding:6px}}
.gl{{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:4px;padding-left:2px}}
.caps{{display:flex;flex-wrap:wrap;gap:5px}}
.cap{{border-radius:5px;padding:6px 9px;font-size:10px;min-width:100px;display:flex;flex-direction:column;gap:3px;position:relative}}
.cap.on-h{{background:#0C1F90;color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 5px rgba(12,31,144,.65)}}
.cap.on-h:hover{{filter:brightness(1.22)}}
.cap.on-m{{background:#3068C4;color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 4px rgba(48,104,196,.55)}}
.cap.on-m:hover{{filter:brightness(1.18)}}
.cap.on-l{{background:#6882AA;color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 4px rgba(104,130,170,.45)}}
.cap.on-l:hover{{filter:brightness(1.12)}}
.cap.on{{background:var(--on);color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 4px var(--on-sh)}}
.cap.on:hover{{filter:brightness(1.15)}}
.cap.cross{{background:var(--acc);color:#1a1a19;cursor:pointer;font-weight:700;box-shadow:0 1px 4px rgba(240,210,36,.45)}}
.cap.cross:hover{{filter:brightness(1.08)}}
.cap.off{{background:#33334d;color:#8a8aa5}}
.cap .cn{{line-height:1.2}}.cap .cb{{font-size:7px;font-weight:800;opacity:.85;letter-spacing:.05em}}
.wb{{position:absolute;top:3px;right:4px;font-size:8px;font-weight:900;border-radius:3px;padding:0 3px;line-height:13px;pointer-events:none}}
.wb.wc{{background:#E8400A;color:#fff}}
.wb.ww{{background:#F0D224;color:#1a1a19}}
#dpanel{{position:fixed;top:0;right:-52%;width:50%;max-width:760px;height:100vh;background:var(--bg2);
  border-left:2px solid var(--acc);z-index:200;transition:right .3s cubic-bezier(.4,0,.2,1);
  box-shadow:-12px 0 40px rgba(0,0,0,.6);display:flex;flex-direction:column}}
#dpanel.open{{right:0}}
#dhead{{padding:16px 22px;border-bottom:1px solid var(--line);background:linear-gradient(135deg,var(--head1),var(--head2));flex-shrink:0}}
#dhead .dcap{{font-size:19px;font-weight:800;color:#fff}}
#dhead .dsub{{font-size:11px;color:#c9d6e8;margin-top:3px}}
#dhead .dstat{{display:flex;gap:14px;margin-top:8px;font-size:10px;color:#c9d6e8}}
#dhead .dstat b{{color:#fff;font-size:14px}}
#dclose{{position:absolute;top:14px;right:18px;cursor:pointer;color:#fff;font-size:20px;background:none;border:none;opacity:.8}}
#dclose:hover{{opacity:1}}
#dbody{{flex:1;overflow-y:auto;padding:16px 22px}}
.proc{{background:var(--panel);border-radius:9px;border-left:4px solid var(--on);padding:13px 15px;margin-bottom:11px}}
.proc .pbiz{{font-size:14px;font-weight:800;color:var(--txt);line-height:1.25}}
.proc .pdesc{{font-size:11.5px;color:#c9d2e0;line-height:1.5;margin-top:6px}}
.proc .pdesc b{{color:#fff}}
.proc .psp{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;color:var(--muted);margin-top:6px}}
.proc .ptrig{{font-size:10px;color:var(--muted);margin-top:6px}}.proc .ptrig b{{color:#9ab0d0}}
.proc .flabel{{font-size:8px;font-weight:700;letter-spacing:.08em;color:var(--muted);text-transform:uppercase;margin:9px 0 5px}}
.flow{{display:flex;flex-wrap:wrap;align-items:center;gap:4px}}
.step{{background:rgba(30,123,224,.14);border:1px solid var(--on);color:var(--txt);border-radius:6px;padding:3px 9px;font-size:10px}}
.arr{{color:var(--acc);font-weight:800;font-size:12px}}
.proc.regp{{border-left-color:var(--acc)}}.regtag{{font-size:8px;font-weight:800;background:var(--acc);color:#1a1a19;padding:1px 6px;border-radius:8px;margin-left:6px}}
.dsec{{font-size:10px;font-weight:700;letter-spacing:.08em;color:var(--acc);text-transform:uppercase;margin:14px 0 8px}}
.expo{{display:inline-flex;flex-direction:column;background:var(--panel);border-radius:7px;padding:8px 11px;margin:0 6px 6px 0;border-left:3px solid var(--muted)}}
.expo .eb{{font-size:11px;font-weight:700}}.expo .es{{font-family:monospace;font-size:9px;color:var(--muted)}}
.sp-detail-btn{{display:inline-block;margin-top:10px;padding:5px 11px;border-radius:7px;font-size:11px;font-weight:700;
  color:#060d1f;background:#F0D224;text-decoration:none;transition:.18s;letter-spacing:.01em}}
.sp-detail-btn:hover{{background:#fff;color:#0d1a40}}
.sp-detail-sm{{padding:3px 8px;font-size:10px;margin-top:5px;align-self:flex-start}}
.inc-card{{background:rgba(232,64,10,.08);border:1px solid rgba(232,64,10,.3);border-radius:9px;padding:13px 15px;margin-bottom:11px;border-left:4px solid #E8400A}}
.inc-card.n2{{background:rgba(240,210,36,.06);border-color:rgba(240,210,36,.3);border-left-color:#F0D224}}
.inc-sev{{font-size:9px;font-weight:900;letter-spacing:.1em;color:#E8400A;text-transform:uppercase;margin-bottom:6px}}
.inc-card.n2 .inc-sev{{color:#F0D224}}
.inc-title{{font-size:14px;font-weight:800;color:#fff;margin-bottom:4px}}
.inc-desc{{font-size:11.5px;color:#c9d2e0;line-height:1.5;margin:6px 0}}
.inc-sps{{font-family:'Cascadia Code','Consolas',monospace;font-size:9.5px;color:var(--muted);margin-top:4px}}
.inc-risks{{font-size:9px;color:#f87171;margin-top:4px}}
#dscrim{{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:150;display:none}}
#tip{{position:fixed;background:rgba(22,22,44,.98);border:1px solid var(--line);border-radius:8px;padding:10px 13px;font-size:11px;pointer-events:none;display:none;z-index:99;max-width:250px;box-shadow:0 4px 20px rgba(0,0,0,.7)}}
#tip .tt{{font-weight:700;font-size:12px;margin-bottom:4px}}#tip .tr{{font-size:10px;color:var(--muted);margin:2px 0}}#tip .tr b{{color:var(--txt)}}
footer{{font-size:9px;color:var(--muted);padding:10px 24px;border-top:1px solid var(--line);line-height:1.5}}
</style></head><body data-theme="bcop">
<header><div class="brand"><img class="logo" src="bancoppel-logo.png" alt="BanCoppel"><div>
<h1>BanCoppel BCOPCore · Gemelo Cognitivo · Modelo de Capacidades Completo</h1>
<div class="sub">7 dominios · {tot2} capacidades · tono azul = densidad de lógica propia · ! = riesgo operativo del risk register · ⬜ gap</div>
</div></div></header>
<div id="bar">
  <div class="tile"><div class="n">{cov2}/{tot2}</div><div class="l">Capacidades en código</div></div>
  <div class="tile"><div class="n">{100*cov2//tot2}%</div><div class="l">Cobertura core actual</div></div>
  <div class="tile"><div class="n">{analized2}</div><div class="l">Analizadas BCOPBrain</div></div>
  <div class="tile"><div class="n">{gap2}</div><div class="l">Gaps — modernización</div></div>
  <div id="leg">
    <span><span class="sw" style="background:#0C1F90"></span>Núcleo de lógica (D03/D04/D05/D06/D09/D11)</span>
    <span><span class="sw" style="background:#3068C4"></span>Lógica + integración</span>
    <span><span class="sw" style="background:#6882AA"></span>Conector / Portal (D01/D10/D14)</span>
    <span><span class="sw" style="background:#33334d"></span>Gap — capacidad de referencia</span>
    <span><span style="background:#E8400A;color:#fff;padding:1px 5px;border-radius:3px;font-size:9px;font-weight:900">!</span>&nbsp;Riesgo crítico activo N5/N4</span>
    <span><span style="background:#F0D224;color:#1a1a19;padding:1px 5px;border-radius:3px;font-size:9px;font-weight:900">!</span>&nbsp;Riesgo operativo N3</span>
  </div>
</div>
<div id="wrap">{areas2}</div>
<footer>Modelo de capacidades <b>BanCoppel BCOPCore</b> — Taxonomía de Negocio AS-IS (7 dominios) enriquecida con referencia ETB Banking v5.0. <b style="color:#0C1F90">Azul oscuro</b> = núcleo de lógica de negocio (avg rules+tables ≥ 12/SP). <b style="color:#4872D6">Azul claro</b> = conector/portal (&lt;8). <b style="color:#8a8aa5">Gris</b> = gap ETB — objetivo de la modernización. Tono calculado de los sp-validation JSONs (16 dominios, {analized2} capacidades). <b style="color:#E8400A">!</b> rojo = riesgo crítico activo · <b style="color:#F0D224">!</b> amarillo = riesgo operativo (risk register SPE-AM-001). <code>DISCOVER Etapa 1</code></footer>
<div id="tip"></div>
<div id="dscrim" onclick="closeDrill()"></div>
<div id="dpanel">
  <div id="dhead"><button id="dclose" onclick="closeDrill()">&#x2715;</button>
    <div class="dcap" id="d-cap">—</div><div class="dsub" id="d-sub"></div>
    <div class="dstat" id="d-stat"></div></div>
  <div id="dbody"></div>
</div>
<script>
const DOMDATA={DOMDATA_V2_JSON};
const FAILURES={FAILURES_JSON};
function closeDrill(){{document.getElementById('dpanel').classList.remove('open');document.getElementById('dscrim').style.display='none';}}
function openDrill(did,capName){{
  const d=DOMDATA[did];
  const body=document.getElementById('dbody');
  document.getElementById('d-cap').textContent=capName;
  if(d && d.pending){{
    document.getElementById('d-sub').innerHTML=`Dominio <b>${{d.name}}</b> — existe en el core Informix pero análisis BCOPBrain pendiente`;
    document.getElementById('d-stat').innerHTML='<span style="color:var(--acc)">◆ BCOPBrain: análisis pendiente</span>';
    body.innerHTML=`<div style="padding:20px 0;font-size:13px;line-height:1.6;color:#c9d2e0">
      <p>Este dominio existe en la base de datos Informix <b style="color:#fff">${{did.toUpperCase()}}</b> pero aún no ha sido procesado por BCOPBrain.</p>
      <p style="margin-top:12px">Para incluirlo en el análisis se debe agregar <code>${{did}}</code> al script <code>build-brain.py</code> y ejecutar el scatter-gather de extracción.</p>
      <p style="margin-top:12px;color:var(--acc)">Prioridad recomendada: D16 (Tarjetas) → D15 (LIDE/PLD) → D13 (TEF) → D14 (BEI)</p>
    </div>`;
  }} else if(d){{
    const incs=(typeof FAILURES!=='undefined'&&FAILURES[did])?FAILURES[did]:[];
    document.getElementById('d-sub').innerHTML=`Capacidad implementada por el dominio <b>${{d.name}}</b> · procesos identificados en BCOPBrain`;
    document.getElementById('d-stat').innerHTML=`<span><b>${{d.procs.length}}</b> procesos</span><span><b>${{d.exposed.length}}</b> servicios expuestos</span><span><b>${{d.reglas}}</b> reglas</span><span><b>${{Number(d.sps).toLocaleString('es-MX')}}</b> SPs</span>`;
    if(incs.length){{const mx=incs[0];const sc=mx.severity_label==='CRÍTICO'?'color:#E8400A':'color:#F0D224';document.getElementById('d-stat').innerHTML+=`<span style="${{sc}};font-weight:900">! ${{incs.length}} incidente${{incs.length>1?'s':''}} activo${{incs.length>1?'s':''}}</span>`;}}
    let h='';
    if(incs.length){{
      h+='<div class="dsec" style="color:#E8400A">Incidentes activos en producción</div>';
      incs.forEach(f=>{{
        const isCrit=f.severity_label==='CRÍTICO';
        const risks=f.risk_ids&&f.risk_ids.length?`<div class="inc-risks">Risk IDs: ${{f.risk_ids.join(' · ')}}</div>`:'';
        h+=`<div class="inc-card${{isCrit?'':' n2'}}">
          <div class="inc-sev">${{f.severity}} · ${{f.severity_label}} · ${{f.date}}</div>
          <div class="inc-title">${{f.title}}</div>
          <div class="inc-desc">${{f.description}}</div>
          <div class="inc-sps">SPs afectados: ${{f.affected_sps.join(' · ')}}</div>
          ${{risks}}
          ${{f.url?`<a class="sp-detail-btn" href="${{f.url}}" target="_blank">Ver diagnóstico completo →</a>`:''}}
        </div>`;
      }});
    }}
    if(d.procs.length){{
      h+='<div class="dsec">Procesos de negocio (flujo a alto nivel)</div>';
      d.procs.forEach(p=>{{
        const flow=p.flow.length?'<div class="flabel">Flujo</div><div class="flow">'+
          p.flow.map((s,i)=>`${{i?'<span class=arr>&rarr;</span>':''}}<span class="step">${{s}}</span>`).join('')+'</div>':'';
        h+=`<div class="proc ${{p.reg?'regp':''}}">
          <div class="pbiz">${{p.biz}}${{p.reg?'<span class="regtag">REGULATORIO</span>':''}}</div>
          <div class="pdesc">${{p.desc}}</div>
          <div class="psp">${{p.sp}} · fan_out ${{p.fo}}</div>
          <div class="ptrig">Disparado por: <b>${{p.trig||'—'}}</b></div>${{flow}}
          <a class="sp-detail-btn" href="sp-detail-${{p.sp}}.html" target="_blank">Ver historia funcional →</a></div>`;
      }});
    }}
    if(d.exposed.length){{
      h+='<div class="dsec">Servicios expuestos (endpoints)</div>';
      d.exposed.forEach(e=>{{h+=`<div class="expo"><span class="eb">${{e.biz}}</span><span class="es">${{e.sp}} · ${{e.ext}} callers</span><a class="sp-detail-btn sp-detail-sm" href="sp-detail-${{e.sp}}.html" target="_blank">→</a></div>`;}});
    }}
    body.innerHTML=h;
  }}
  document.getElementById('dpanel').classList.add('open');
  document.getElementById('dscrim').style.display='block';
}}
const tip=document.getElementById('tip');
document.querySelectorAll('.cap.on-h,.cap.on-m,.cap.on-l,.cap.on,.cap.cross').forEach(c=>{{
 c.onmousemove=e=>{{
   const risk=c.dataset.risk||'';
   const riskLine=risk==='critical'
     ?'<div class="tr" style="color:#FF6B35;font-weight:700">! Riesgo crítico activo (N5/N4) — risk register</div>'
     :risk==='warn'
     ?'<div class="tr" style="color:#F0D224;font-weight:700">! Riesgo operativo documentado (N3) — risk register</div>'
     :'';
   const tierLabel={{h:'Núcleo de lógica',m:'Lógica + integración',l:'Conector / Portal'}};
   const tier=c.classList.contains('on-h')?'h':c.classList.contains('on-l')?'l':'m';
   tip.innerHTML=`<div class="tt">${{c.dataset.n}}</div>
     <div class="tr">Dominio: <b>${{c.dataset.b}} · ${{c.dataset.dom}}</b></div>
     <div class="tr">Carácter: <b>${{tierLabel[tier]||'—'}}</b></div>
     <div class="tr">Journeys: <b>${{c.dataset.j}}</b> · Reglas: <b>${{c.dataset.r}}</b> · SPs: <b>${{Number(c.dataset.s).toLocaleString('es-MX')}}</b></div>
     ${{riskLine}}
     <div class="tr" style="color:#c4b5fd">▸ Click para ver detalle</div>`;
   tip.style.display='block';
   tip.style.left=Math.min(e.clientX+14,innerWidth-265)+'px';
   tip.style.top=(e.clientY+12)+'px';}};
 c.onmouseleave=()=>tip.style.display='none';
 c.onclick=()=>{{tip.style.display='none';openDrill(c.dataset.did,c.dataset.n);}};
}});
document.addEventListener('keydown',e=>{{if(e.key==='Escape')closeDrill();}});
</script></body></html>"""
open(BASE+"portal/capability-model-bcop-v2.html","w",encoding="utf-8").write(HTML_V2)
print(f"capability-model-bcop-v2.html escrito · {cov2}/{tot2} en código ({100*cov2//tot2}%) · {gap2} gaps modernización · {analized2} analizadas D01-D16")
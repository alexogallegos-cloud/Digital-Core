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
J = json.load(open(BASE + "journeys-data.json", encoding="utf-8"))
BR = json.load(open(BASE + "business-rules.json", encoding="utf-8"))
DBOF = {"d01":"bdicnweb","d02":"bdinteg","d03":"bdicred","d04":"bdicheq","d05":"bdisac",
        "d06":"bdisolic","d07":"bdiaclaracion","d08":"bdispei","d09":"bdimnsj","d10":"bdisuc",
        "d11":"bdicobranza","d12":"bdicont"}
NAME = {"d01":"Canal Digital","d02":"Integración/Auth","d03":"Créditos","d04":"Cheques/Cuentas",
        "d05":"Saldos","d06":"Solicitudes","d07":"Aclaraciones","d08":"SPEI","d09":"Mensajería",
        "d10":"Sucursales","d11":"Cobranza","d12":"Contabilidad","ext":"Externo","reg":"Reguladores"}
rules_by_db = Counter(r["db"] for r in BR["rules"])
def m(d):
    if d in DBOF:
        return {"j": len(J[d]["journeys"])+len(J[d].get("exposed",[])), "r": rules_by_db.get(DBOF[d],0), "s": J[d]["sp_count"], "n": NAME[d]}
    return {"j":0,"r":0,"s":0,"n":NAME.get(d,d)}

# ── drill-down: procesos (journeys) por dominio con objetivo de negocio + flujo ejecutivo ──
import json as _json, re as _re
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
open(BASE+"capability-model-bcop.html","w",encoding="utf-8").write(HTML)
print(f"capability-model-bcop.html escrito · {cov}/{tot} capacidades cubiertas ({100*cov//tot}%) · {len(doms_cubiertos)}/12 dominios")
print("  áreas del modelo de referencia:", len(MODEL))
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-capability-model.py — Modelo de capacidades bancarias de REFERENCIA
(agnóstico, 10 áreas estilo Accenture Banking) con las capacidades IDENTIFICADAS
en los dominios técnicos de BanCoppel resaltadas (heat de cobertura).
Genera: capability-model-bcop.html · SME Modelo Operativo Bancario"""
import json, sqlite3
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

# ── Riesgos del risk register (estructurales, siempre visibles aunque no haya logs) ──
DOM_RISK_REGISTER = {
    "d01": "critical",  # P655-R001/R002 — 2×N5 DEFECTO-PROD activos
    "d11": "critical",  # P655-R009/R010/R011 — N4+2×N3
    "d05": "warn",      # P655-R003/R008 — N3+N2 (remesas/integración)
    "d08": "warn",      # P655-R005 — ESB integraciones externas N3
    "d13": "warn",      # P655-R005 — ESB integraciones externas N3
    "d14": "warn",      # P655-R005 — ESB integraciones externas N3
    "d02": "warn",      # P655-R006 — N2 autenticación
}

# ── Riesgos dinámicos desde brain.db (sp_metrics_daily) ──────────────────────
_BRAIN_DB = BASE + "digital-brain/brain.db"
# dom_daily: {dk: {date: {calls, errors, error_rate}}}
dom_daily: dict = {}
_log_dates: list = []
try:
    _bc = sqlite3.connect(_BRAIN_DB)
    _log_dates = [r[0] for r in _bc.execute(
        "SELECT DISTINCT date FROM sp_metrics_daily ORDER BY date"
    ).fetchall()]
    for _row in _bc.execute("""
        SELECT lower(s.domain), m.date, SUM(m.calls), SUM(m.errors)
        FROM sp_metrics_daily m
        JOIN sps s ON s.id = m.sp_id
        WHERE s.domain IS NOT NULL AND m.calls > 0
        GROUP BY s.domain, m.date
        ORDER BY s.domain, m.date
    """):
        _dk, _date, _calls, _errors = _row
        if _dk not in dom_daily:
            dom_daily[_dk] = {}
        dom_daily[_dk][_date] = {
            "calls": _calls,
            "errors": _errors,
            "error_rate": round(_errors / _calls * 100, 2) if _calls else 0.0,
        }
    sp_role_map = {}
    for _r in _bc.execute("SELECT name, sp_role FROM sps WHERE sp_role IS NOT NULL").fetchall():
        if _r[0] not in sp_role_map:  # first occurrence wins (same name can appear in multiple DBs)
            sp_role_map[_r[0]] = _r[1]
    # Journeys con sus L3 ETB (desde sp_capabilities, puede ser multiple)
    _jrows = _bc.execute("""
        SELECT j.id, lower(j.domain) as dom, j.biz, j.sp, j.fan_out, j.reg,
               GROUP_CONCAT(DISTINCT sc.l3_id) as l3_set
        FROM journeys j
        LEFT JOIN sp_capabilities sc ON sc.sp_id = j.id
        GROUP BY j.id, j.domain
        ORDER BY j.domain, j.id
    """).fetchall()
    JOURNEYS_BY_DOM: dict = {}
    for _jr in _jrows:
        _jd = _jr[1]
        JOURNEYS_BY_DOM.setdefault(_jd, []).append({
            "id": _jr[0], "biz": _jr[2] or _jr[3], "sp": _jr[3],
            "fo": _jr[4] or 0, "reg": bool(_jr[5]),
            "l3": set(_jr[6].split(",")) if _jr[6] else set(),
        })
    _bc.close()
except Exception as _exc:
    sp_role_map = {}
    JOURNEYS_BY_DOM = {}
    print(f"[WARN] No se pudo cargar sp_metrics_daily: {_exc}")

# Umbrales: error_rate ≥25% → critical; ≥8% → warn
DOM_RISK_LOGS: dict = {}
for _dk, _dates in dom_daily.items():
    _max_rate = max(v["error_rate"] for v in _dates.values()) if _dates else 0
    if _max_rate >= 25:
        DOM_RISK_LOGS[_dk] = "critical"
    elif _max_rate >= 8:
        DOM_RISK_LOGS[_dk] = "warn"

# Fusión: max(register, logs) — se muestra la señal más severa
def _sev(s): return {"critical": 2, "warn": 1}.get(s, 0)
DOM_RISK = {}
for _dk in set(list(DOM_RISK_REGISTER.keys()) + list(DOM_RISK_LOGS.keys())):
    _r = DOM_RISK_REGISTER.get(_dk, "")
    _l = DOM_RISK_LOGS.get(_dk, "")
    DOM_RISK[_dk] = _r if _sev(_r) >= _sev(_l) else _l

# JSON para inyectar en HTML (drill-down timeline)
_dom_daily_json = json.dumps(dom_daily, ensure_ascii=False)
_log_dates_json = json.dumps(_log_dates, ensure_ascii=False)

_n_dates = len(_log_dates)
_date_range = (f"{_log_dates[0]} → {_log_dates[-1]}" if _n_dates > 1
               else (_log_dates[0] if _log_dates else "sin datos"))
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
                      "role": sp_role_map.get(jj["sp"]) or "",
                      "desc": biz_desc(jj, d, trig, flow)})
    exposed = [{"biz": jj.get("biz") or jj["sp"], "sp": jj["sp"], "ext": jj["ext_callers"],
                "role": sp_role_map.get(jj["sp"]) or ""}
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

# ── CAPDATA: SPs específicos por capacidad BanCoppel ─────────────────────────
# Cada entrada: (db, [fragmentos de nombre SP]) → filtra brain.db por LIKE
# Resuelve el problema de múltiples capacidades en el mismo dominio mostrando
# la misma lista de procesos (e.g., Creación/Actualización/Consulta del Perfil → d06)
CAP_SP_FILTER = {
    # D06 · bdisolic — Solicitudes
    "Creación del Perfil":       ("bdisolic", ["alta_sol", "altaclientehuellatitular"]),
    "Actualización del Perfil":  ("bdisolic", ["sp_actualiza_status_sol", "sp_actualiza_monto", "actualiza_solicitud", "sp_envia_sms_actualiza_sol"]),
    "Consulta del Perfil":       ("bdisolic", ["sp_obtienegrupo", "sp_cons_empleado", "sp_obtienecompingresos", "sp_obtensolicitud"]),
    "Solicitud de Producto":     ("bdisolic", ["sp_obtiene_productos", "sp_getprodcte", "sp_consulta_productos"]),
    "Verificación de Identidad": ("bdisolic", ["sp_valida_cliente", "sp_prepara_buro", "sp_verifica_pre_aprobados"]),
    "Solicitud de Crédito":      ("bdisolic", ["califica_scoring", "determina_lincred", "sp_conssolic_cred", "sp_apercredcoppel", "sp_consulta_status_solic"]),
    "Modificación de Datos":     ("bdisolic", ["sp_actualiza_status_sol", "sp_guarda_sol", "sp_modifica_sol"]),
    "Cancelación de Relación":   ("bdisolic", ["sp_cancela_sol", "sp_baja_sol", "sp_cierra_sol"]),
    # D05 · bdisac — Saldos
    "Apertura Cuenta de Ahorro": ("bdisac",   ["sp_apertura", "sp_abre_cta", "sp_alta_cta", "sp_crea_cuenta", "sp_crea_cta"]),
    "Consulta de Saldo":         ("bdisac",   ["sp_cons_saldo", "sp_obtiene_saldo", "sp_consulta_saldo", "sp_obtiens"]),
    "Estado de Cuenta":          ("bdisac",   ["edocta", "estado_cta", "sp_obtentipoedocta", "sp_genera_edo"]),
    "Registro de Movimientos":   ("bdisac",   ["cargo_ref", "abono_ref", "sp_movimiento", "sp_registra_mov"]),
    "Cancelación Cuenta Ahorro": ("bdisac",   ["sp_cancela_cta", "sp_cierra_cta", "sp_baja_cta"]),
    "Saldo Consolidado por Cliente": ("bdisac", ["sp_saldo_consolid", "sp_posicion", "sp_obtiene_saldos"]),
    "Recepción de Remesa APPRIZA": ("bdisac", ["appriza", "remesa", "sp_wu_", "sp_recibe_remesa"]),
    "Envío de Remesa":           ("bdisac",   ["sp_envia_remesa", "sp_wu_envia", "sp_wu_paga"]),
    # D03 · bdicred — Créditos
    "Autorización de Crédito":   ("bdicred",  ["sp_autoriza", "sp_aprueba", "autoriza_cred"]),
    "Disposición del Crédito":   ("bdicred",  ["disposi", "sp_disposi", "sp_crea_movimiento_disp"]),
    "Ciclo de Corte":            ("bdicred",  ["sp_cierre", "sp_corte", "ciclo_corte", "sp_proceso_corte"]),
    "Registro de Pagos de Crédito": ("bdicred", ["sp_pago_cred", "sp_aplica_pago", "sp_registra_pago", "pago_cred"]),
    # D04 · bdicheq — Cheques/Cuentas
    "Apertura Cuenta de Cheques": ("bdicheq", ["sp_abre_cta", "sp_alta_cta", "sp_apertura_chq", "sp_crea_cta"]),
    "Emisión y Gestión de Cheques": ("bdicheq", ["sp_emite_chq", "cheque", "sp_genera_chq", "sp_talonario"]),
    "Consulta y Movimientos Cheques": ("bdicheq", ["sp_cons_chq", "sp_cons_mov", "sp_obtiene_chq", "cargo", "abono"]),
    "Cancelación Cuenta Cheques": ("bdicheq", ["sp_cancela_cta", "sp_cierra_cta", "sp_baja_cta"]),
    "Cálculo de Intereses":      ("bdicheq",  ["sp_calculo_int", "sp_interes", "sp_calcula_int", "interes_"]),
}

CAPDATA: dict = {}
try:
    _bc2 = sqlite3.connect(_BRAIN_DB)
    for _cap_name, (_db_name, _patterns) in CAP_SP_FILTER.items():
        _cond = " OR ".join([f"name LIKE '%{p}%'" for p in _patterns])
        _rows = _bc2.execute(
            f"SELECT name, biz, sp_role, fan_in FROM sps WHERE db=? AND ({_cond}) ORDER BY fan_in DESC LIMIT 15",
            (_db_name,)
        ).fetchall()
        if _rows:
            CAPDATA[_cap_name] = [
                {"sp": r[0], "biz": r[1] or r[0], "role": r[2] or "", "fi": r[3] or 0}
                for r in _rows
            ]
    _bc2.close()
except Exception as _exc2:
    print(f"[WARN] No se pudo construir CAPDATA: {_exc2}")
CAPDATA_JSON = _json.dumps(CAPDATA, ensure_ascii=False)

# ── Remapeo capacidad → journeys específicos (scoring de keywords) ──────────
_STOP = {
    "por","del","los","las","una","con","que","para","como","este","esta",
    "entre","desde","hacia","sobre","bajo","ante","tras","sin","cada",
    "tipo","nivel","via","modo","caso","base","dato","datos",
    "servicio","servicios","sistema","sistemas",
}

import unicodedata as _ud
def _norm(s):
    return _ud.normalize("NFD", s.lower()).encode("ascii","ignore").decode()

def _score_journey(biz, sp, cap_name):
    """Cuenta cuántas keywords significativas (≥4 chars, sin stopwords, sin tilde)
    del nombre de la capacidad aparecen en biz+sp del journey."""
    words = [w for w in _re.findall(r'\w{4,}', _norm(cap_name)) if w not in _STOP]
    text  = _norm(f"{biz} {sp}")
    return sum(1 for w in words if w in text)

# CAP_L3_MAP: cap MODEL_V2 → ETB L3 IDs esperados (Tier 1 antes de keyword scoring)
# Fuente: domain_capabilities + primary_l3 de journeys (brain.db explorado 2026-08-10)
CAP_L3_MAP: dict = {
    # D08 SPEI — discriminación exacta saliente / entrante / CoDi
    "Transferencia SPEI Saliente":    ["3.4.3"],          # Core Payment Processing
    "Transferencia SPEI Entrante":    ["3.4.2"],          # Payment Acquisition Management
    "CoDi — Cobro Digital":           ["7.4.1"],          # Embedded Finance
    "Pago de Servicio (Convenio)":    ["3.4.8"],          # Payments Operations Management
    "Gestión de Convenios":           ["3.4.7"],          # Payment Support Services
    "Obligaciones Banxico — SPEI":    ["3.4.1","3.4.4","3.4.5"],
    # D13 TEF
    "TEF entre Cuentas Propias":      ["3.4.3"],
    "TEF a Terceros BanCoppel":       ["3.4.4"],
    # D07 Aclaraciones
    "Recepción de Aclaración":        ["3.18.1"],         # Dispute Management
    "Resolución de Aclaración":       ["3.18.1"],
    "Obligaciones CONDUSEF":          ["4.5.1"],          # Regulatory Compliance Advisement
    # D11 Cobranza
    "Gestión de Mora Temprana":       ["5.9.4"],          # Risk Control Management
    "Gestión de Mora Tardía":         ["5.9.5"],          # Risk Event Management
    "Castigo de Cartera":             ["5.9.5"],
    "Recuperación Post-Castigo":      ["3.3.4"],          # Credit Servicing Management
    "Reestructuras y Quitas":         ["3.3.4"],
    # D12 Contabilidad
    "Libro Mayor (GL)":               ["5.4.1"],          # Finance Account Management
    "Cierre Contable Diario":         ["5.4.8"],          # Financial Position Management
    "Reportes Serie R (CNBV)":        ["3.17.8"],         # Balance & transaction reporting
    "Obligaciones CNBV":              ["5.10.4"],         # Compliance Monitoring & Auditing
    # D15 LIDE / PLD
    "Monitoreo de Transacciones":     ["5.8.1","5.8.2"],  # Fraud & AML Prevention + Detection
    "Lista LIDE":                     ["5.8.1"],
    "Reportes PLD a UIF":             ["5.10.6"],         # Regulatory Engagement & Reporting
    # D16 Tarjetas
    "Emisión de Tarjeta":             ["3.5.1"],          # Cards Issuance & Servicing
    "Activación de Tarjeta":          ["3.5.1"],
    "Bloqueo y Desbloqueo":           ["7.1.4"],          # Customer Access Management
    "Reposición de Tarjeta":          ["3.5.1"],
    "Autorización de Compra":         ["3.5.2"],          # Cards Authorization
    "Control de Límites":             ["3.16.1"],         # Limits Management
    # D02 Autenticación
    "Autenticación por Canal":        ["7.1.2"],          # Customer Authentication & Identification
    "Gestión de Sesión":              ["7.1.4"],          # Customer Access Management
    # D14 BEI
    "Acceso Empresarial BEI":         ["7.1.2"],
    "Pagos y Dispersiones Masivas":   ["7.1.4"],
    # D06 Solicitudes
    "Verificación de Identidad":      ["5.9.2"],          # Risk Assessment
    "Solicitud de Crédito":           ["3.3.1"],          # Credit structuring & Approval
    "Creación del Perfil":            ["7.1.1"],          # Customer Establishment
    "Modificación de Datos":          ["7.1.3"],          # Customer Preference Management
    # D03 Créditos
    "Autorización de Crédito":        ["3.3.1","3.3.2"],
    "Disposición del Crédito":        ["3.3.2"],          # Credit Underwriting & Disbursement
    "Ciclo de Corte":                 ["3.3.4"],
    "Registro de Pagos de Crédito":   ["3.3.4"],
    # D04 Cheques
    "Apertura Cuenta de Cheques":     ["3.2.1","3.2.2","3.2.3"],
    "Emisión y Gestión de Cheques":   ["3.2.4"],          # Deposit Account Servicing Management
    "Consulta y Movimientos Cheques": ["3.2.4"],
    "Cálculo de Intereses":           ["3.15.2"],         # Interest & Fees Calculation
    # D05 Saldos
    "Consulta de Saldo":              ["3.17.8"],
    "Estado de Cuenta":               ["3.17.8"],
    "Registro de Movimientos":        ["3.2.4"],
    # D01 Canal Digital
    "Banca en Línea Web":             ["1.1.1"],          # Internet Banking
    "Banca Móvil":                    ["1.1.2"],          # Mobile Banking
    "Atención Telefónica / IVR":      ["1.1.5"],          # Call Centre and IVR
    # D10 Sucursales
    "Sucursales BanCoppel":           ["1.2.1"],          # Branch
    "Cajeros ATM":                    ["1.2.2"],          # ATM, POS and Kiosk
    "Operaciones de Caja en Tienda":  ["1.2.1"],
}

JOURNEY_CAP_MAP: dict = {}  # solo capacidades con match real (sin domain-fallback)
for _a, _groups in MODEL_V2:
    for _gn, _caps in _groups:
        for _cn, _dom in _caps:
            if _dom is None:
                continue
            dom_j = JOURNEYS_BY_DOM.get(_dom, [])
            if not dom_j:
                continue
            # Tier 1: L3 directo — L3 set del journey (sp_capabilities) vs CAP_L3_MAP
            _l3_ids = CAP_L3_MAP.get(_cn)
            if _l3_ids:
                _l3_set = set(_l3_ids)
                _l3_matched = [_j for _j in dom_j if _j.get("l3") & _l3_set]
                if _l3_matched:
                    JOURNEY_CAP_MAP[_cn] = _l3_matched
                    continue
            # Tier 2: keyword scoring (fallback para caps sin L3 asignado o sin journeys con ese L3)
            if len(dom_j) <= 3:
                JOURNEY_CAP_MAP[_cn] = dom_j
            else:
                scored = [(_j, _score_journey(_j["biz"], _j["sp"], _cn)) for _j in dom_j]
                matched = sorted([(_j, _s) for _j, _s in scored if _s > 0], key=lambda x: -x[1])
                if matched:
                    JOURNEY_CAP_MAP[_cn] = [_j for _j, _ in matched[:8]]
JOURNEY_CAP_JSON = _json.dumps(JOURNEY_CAP_MAP, ensure_ascii=False,
                              default=lambda x: list(x) if isinstance(x, set) else x)

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
    # Error rate del último día disponible (para tooltip / sparkline)
    _dk_dates = dom_daily.get(d, {})
    _last_rate = list(_dk_dates.values())[-1]["error_rate"] if _dk_dates else -1
    _risk_src  = ("log+register" if (DOM_RISK_LOGS.get(d) and DOM_RISK_REGISTER.get(d))
                  else "log" if DOM_RISK_LOGS.get(d)
                  else "register" if DOM_RISK_REGISTER.get(d)
                  else "")
    n_jcap = len(JOURNEY_CAP_MAP.get(c, []))
    jbadge = f'<span class="cj">{n_jcap}j</span>' if n_jcap else ""
    return (f'<div class="cap {css_cls}" data-did="{d}" data-n="{c}" data-dom="{mm["n"]}" data-b="{badge}" '
            f'data-j="{mm["j"]}" data-r="{mm["r"]}" data-s="{mm["s"]}" data-risk="{risk}" '
            f'data-erate="{_last_rate}" data-rsrc="{_risk_src}" data-jcap="{n_jcap}">'
            f'<span class="cn">{c}</span>'
            f'<div class="cbrow"><span class="cb">{badge}</span>{jbadge}</div>'
            f'{risk_html}</div>')

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
:root{{--bg:#060a1a;--bg2:#0d1533;--panel:#111c47;--line:#26317c;--txt:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --on:#2E52C8;--on-sh:rgba(46,82,200,.55);--acc:#F0D224;--yellow:#F0D224;--head1:#0d2185;--head2:#122FB1;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}}
.aurora::before{{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.65),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:56vw;height:56vw;right:-14vw;top:6vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.7),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{position:absolute;width:40vw;height:40vw;left:34vw;bottom:-14vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(240,210,36,.20),transparent 70%);animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
.hero-bar{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:18px;
 padding:14px 32px;-webkit-backdrop-filter:blur(20px) saturate(150%);backdrop-filter:blur(20px) saturate(150%);
 background:rgba(6,10,26,.6);border-bottom:1px solid rgba(255,255,255,.06)}}
.hero-bar img{{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}}
.hero-bar .hb-sep{{width:1px;height:28px;background:rgba(255,255,255,.15);flex-shrink:0}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--yellow);font-style:normal}}
.hero-bar .hb-sp{{flex:1}}
.hero-bar a.back{{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}
#intro{{padding:76px 24px 0;max-width:1500px;margin:0 auto}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}}
.hero-h1{{font-size:clamp(24px,3.5vw,42px);font-weight:900;letter-spacing:-.035em;line-height:1.0;
 background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent;margin-bottom:10px}}
.hero-sub{{font-size:12px;color:var(--muted);line-height:1.5;max-width:90ch;margin-bottom:14px}}
#bar{{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:10px}}
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
.cap.on-h{{background:#1D4ED8;color:#fff;cursor:pointer;font-weight:700;box-shadow:0 2px 8px rgba(29,78,216,.7)}}
.cap.on-h:hover{{filter:brightness(1.2)}}
.cap.on-m{{background:#0369A1;color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 5px rgba(3,105,161,.6)}}
.cap.on-m:hover{{filter:brightness(1.18)}}
.cap.on-l{{background:#1E3A5F;color:#93C5FD;cursor:pointer;font-weight:700;box-shadow:0 1px 4px rgba(30,58,95,.5)}}
.cap.on-l:hover{{filter:brightness(1.15)}}
.cap.on{{background:var(--on);color:#fff;cursor:pointer;font-weight:700;box-shadow:0 1px 4px var(--on-sh)}}
.cap.on:hover{{filter:brightness(1.15)}}
.cap.cross{{background:var(--acc);color:#1a1a19;cursor:pointer;font-weight:700;box-shadow:0 1px 4px rgba(240,210,36,.45)}}
.cap.cross:hover{{filter:brightness(1.08)}}
.cap.off{{background:#33334d;color:#8a8aa5}}
.cap .cn{{line-height:1.2}}
.cbrow{{display:flex;align-items:center;gap:4px;flex-wrap:wrap}}
.cap .cb{{font-size:7px;font-weight:800;opacity:.85;letter-spacing:.05em}}
.cap .cj{{font-size:7px;font-weight:800;background:rgba(240,210,36,.22);color:#F0D224;border-radius:3px;padding:0 4px;letter-spacing:.03em}}
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
.proc-role-tag{{font-size:8px;font-weight:700;background:rgba(99,179,237,.18);color:#7dd3fc;padding:1px 7px;border-radius:8px;margin-left:6px;letter-spacing:.03em;vertical-align:middle}}
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
footer{{text-align:center;padding:36px 0 8px;font-size:11px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);margin-top:30px}}
</style></head><body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div class="hero-bar">
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div class="hb-sep"></div>
  <span class="crumb">BCOPCORE &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>MODELO DE CAPACIDADES</em></span>
  <span class="hb-sp"></span>
  <a href="index-bcop-v2.html" class="back">← Portal</a>
</div>
<div id="intro">
  <div class="hero-label">Gemelo Cognitivo · Modelo de Capacidades</div>
  <h1 class="hero-h1">Modelo de Capacidades Completo</h1>
  <p class="hero-sub">7 dominios · {tot2} capacidades de referencia · tono azul = densidad de lógica de negocio · <b style="color:#E8400A">!</b> = riesgo dinámico ({_n_dates} {'días' if _n_dates != 1 else 'día'}: {_date_range}) · ⬜ gap</p>
  <div id="bar">
    <div class="tile"><div class="n">{cov2}/{tot2}</div><div class="l">Capacidades en código</div></div>
    <div class="tile"><div class="n">{100*cov2//tot2}%</div><div class="l">Cobertura core actual</div></div>
    <div class="tile"><div class="n">{analized2}</div><div class="l">Analizadas BCOPBrain</div></div>
    <div class="tile"><div class="n">{gap2}</div><div class="l">Gaps — modernización</div></div>
    <div id="leg">
      <span><span class="sw" style="background:#1D4ED8"></span>Núcleo de lógica (D03/D04/D05/D06/D09/D11)</span>
      <span><span class="sw" style="background:#0369A1"></span>Lógica + integración</span>
      <span><span class="sw" style="background:#1E3A5F;border:1px solid #93C5FD"></span>Conector / Portal (D01/D10/D14)</span>
      <span><span class="sw" style="background:#33334d"></span>Gap — capacidad de referencia</span>
      <span><span style="background:#E8400A;color:#fff;padding:1px 5px;border-radius:3px;font-size:9px;font-weight:900">!</span>&nbsp;Riesgo crítico activo N5/N4</span>
      <span><span style="background:#F0D224;color:#1a1a19;padding:1px 5px;border-radius:3px;font-size:9px;font-weight:900">!</span>&nbsp;Riesgo operativo N3</span>
    </div>
  </div>
</div>
<div id="wrap">{areas2}</div>
<footer>Modelo de capacidades <b>BanCoppel BCOPCore</b> — Taxonomía de Negocio AS-IS (7 dominios). Tono azul = densidad de lógica (sp-validation JSONs, 16 dominios). <b style="color:#E8400A">!</b> rojo = riesgo crítico · <b style="color:#F0D224">!</b> amarillo = riesgo operativo — derivados de logs ESB ({_n_dates} fechas: {_date_range}) fusionados con risk register SPE-AM-001. <code>DISCOVER Etapa 1</code></footer>
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
const CAPDATA={CAPDATA_JSON};
const JOURNEYDATA={JOURNEY_CAP_JSON};
const FAILURES={FAILURES_JSON};
const DOM_DAILY={_dom_daily_json};
const LOG_DATES={_log_dates_json};

function _trend(dates){{
  if(!dates||Object.keys(dates).length<2)return'';
  const vals=Object.keys(dates).sort().map(d=>dates[d].error_rate);
  const delta=vals[vals.length-1]-vals[0];
  if(delta>2)return'<span style="color:#f87171;font-weight:900">↑</span>';
  if(delta<-2)return'<span style="color:#4ade80;font-weight:900">↓</span>';
  return'<span style="color:#94a3b8">→</span>';
}}

function _rateColor(r){{
  if(r>=25)return'#f87171';
  if(r>=8)return'#fbbf24';
  return'#4ade80';
}}

function _prodTimeline(did){{
  const dates=DOM_DAILY[did];
  if(!dates||!Object.keys(dates).length)return'';
  const sorted=Object.keys(dates).sort();
  let rows=sorted.map(dt=>{{
    const m=dates[dt];
    const rc=_rateColor(m.error_rate);
    const bar=Math.min(Math.round(m.error_rate*2),100);
    return`<tr>
      <td style="font-family:monospace;font-size:10px;color:#94a3b8">${{dt}}</td>
      <td style="text-align:right;font-size:10px">${{m.calls.toLocaleString('es-MX')}}</td>
      <td style="text-align:right;font-size:10px;color:${{rc}}">${{m.errors.toLocaleString('es-MX')}}</td>
      <td style="text-align:right;min-width:48px">
        <div style="display:inline-flex;align-items:center;gap:5px">
          <div style="width:${{bar}}px;max-width:80px;height:6px;background:${{rc}};border-radius:3px;min-width:2px"></div>
          <span style="font-size:10px;color:${{rc}};font-weight:700">${{m.error_rate}}%</span>
        </div>
      </td>
    </tr>`;
  }}).join('');
  const trend=_trend(dates);
  return`<div class="dsec">Métricas de producción ESB ${{trend}}</div>
  <div style="background:rgba(0,0,0,.2);border-radius:8px;padding:10px 12px;margin-bottom:12px;overflow-x:auto">
    <table style="width:100%;border-collapse:collapse">
      <thead><tr>
        <th style="text-align:left;font-size:9px;color:var(--muted);padding-bottom:5px;font-weight:700;letter-spacing:.06em">FECHA</th>
        <th style="text-align:right;font-size:9px;color:var(--muted);padding-bottom:5px;font-weight:700">LLAMADAS</th>
        <th style="text-align:right;font-size:9px;color:var(--muted);padding-bottom:5px;font-weight:700">ERRORES</th>
        <th style="text-align:right;font-size:9px;color:var(--muted);padding-bottom:5px;font-weight:700">% ERROR</th>
      </tr></thead>
      <tbody>${{rows}}</tbody>
    </table>
  </div>`;
}}

function closeDrill(){{document.getElementById('dpanel').classList.remove('open');document.getElementById('dscrim').style.display='none';}}
function _jDetailUrl(jid){{
  const p=jid.split(':');
  return p.length===2?`sp-detail/sp-detail-${{p[1]}}.html`:`sp-detail/sp-detail-${{jid}}.html`;
}}

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
    </div>`;
  }} else if(d){{
    const incs=(typeof FAILURES!=='undefined'&&FAILURES[did])?FAILURES[did]:[];
    const capSps=CAPDATA[capName]||null;
    const capJs=JOURNEYDATA[capName]||null;
    const PROC_ROLE_LABELS={{'esb_exposed':'ESB Exposed','entry_point':'Entry Point','super_orchestrator':'Super Orchestrador','orchestrator':'Orchestrador','batch_orchestrator':'Batch Orchestrador','cross_domain_primitive':'Cross-Domain','shared_service':'Shared Service','implementation':'Implementación','leaf':'Leaf','batch':'Batch'}};

    const nJcap=capJs?capJs.length:0;
    const nSps =d.procs.length;
    document.getElementById('d-sub').innerHTML=`Capacidad del dominio <b>${{d.name}}</b> · ${{nJcap}} journey${{nJcap!==1?'s':''}} específico${{nJcap!==1?'s':''}}`;
    document.getElementById('d-stat').innerHTML=`<span><b>${{nJcap}}</b> journeys esta cap</span><span><b>${{nSps}}</b> journeys dominio</span><span><b>${{d.reglas}}</b> reglas</span><span><b>${{Number(d.sps).toLocaleString('es-MX')}}</b> SPs</span>`;
    if(incs.length){{const mx=incs[0];const sc=mx.severity_label==='CRÍTICO'?'color:#E8400A':'color:#F0D224';document.getElementById('d-stat').innerHTML+=`<span style="${{sc}};font-weight:900">! ${{incs.length}} incidente${{incs.length>1?'s':''}} activo${{incs.length>1?'s':''}}</span>`;}}

    let h=_prodTimeline(did);

    // ── Incidentes ─────────────────────────────────────────────────────────
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

    // ── Journeys específicos de esta capacidad (JOURNEYDATA) ───────────────
    const procMap=Object.fromEntries(d.procs.map(p=>[p.sp,p]));
    if(capJs&&capJs.length){{
      h+=`<div class="dsec">Journeys de esta capacidad (${{capJs.length}})</div>`;
      capJs.forEach(j=>{{
        const proc=procMap[j.sp]||{{}};
        const biz=j.biz?j.biz.charAt(0).toUpperCase()+j.biz.slice(1):j.sp;
        const reg=j.reg?'<span class="regtag">REGULATORIO</span>':'';
        const roleTag=proc.role?`<span class="proc-role-tag">${{PROC_ROLE_LABELS[proc.role]||proc.role}}</span>`:'';
        const desc=proc.desc?`<div class="pdesc">${{proc.desc}}</div>`:'';
        const trig=proc.trig?`<div class="ptrig">Disparado por: <b>${{proc.trig}}</b></div>`:'';
        const flow=(proc.flow||[]).length?'<div class="flabel">Flujo</div><div class="flow">'+
          proc.flow.map((s,i)=>`${{i?'<span class=arr>&rarr;</span>':''}}<span class="step">${{s}}</span>`).join('')+'</div>':'';
        const url=_jDetailUrl(j.id);
        h+=`<div class="proc${{j.reg?' regp':''}}">
          <div class="pbiz">${{biz}}${{reg}}</div>
          ${{desc}}
          <div class="psp">${{j.sp}}${{roleTag}} · fan_out ${{j.fo}}</div>
          ${{trig}}${{flow}}
          <a class="sp-detail-btn" href="${{url}}" target="_blank">Ver historia funcional →</a>
        </div>`;
      }});
    }}

    // ── Todos los journeys del dominio ────────────────────────────────────
    if(d.procs.length){{
      const enrichedBiz={{}}; Object.values(JOURNEYDATA||{{}}).forEach(jl=>jl.forEach(j=>{{if(!enrichedBiz[j.sp])enrichedBiz[j.sp]=j.biz;}}));
      const allLabel=capJs&&capJs.length&&capJs.length<d.procs.length
        ?'Otros journeys del dominio':'Todos los journeys del dominio';
      h+=`<div class="dsec" style="margin-top:18px;opacity:.65">${{allLabel}} (${{d.procs.length}})</div>`;
      const capJids=new Set((capJs||[]).map(j=>j.sp));
      d.procs.forEach(p=>{{
        if(capJids.has(p.sp))return;  // ya mostrado arriba
        const rawBiz=enrichedBiz[p.sp]||p.biz||p.sp;
        const ptitle=rawBiz.charAt(0).toUpperCase()+rawBiz.slice(1);
        const roleTag=p.role?`<span class="proc-role-tag">${{PROC_ROLE_LABELS[p.role]||p.role}}</span>`:'';
        const flow=p.flow.length?'<div class="flabel">Flujo</div><div class="flow">'+
          p.flow.map((s,i)=>`${{i?'<span class=arr>&rarr;</span>':''}}<span class="step">${{s}}</span>`).join('')+'</div>':'';
        const url=`sp-detail/sp-detail-${{p.sp}}.html`;
        h+=`<div class="proc${{p.reg?' regp':''}}" style="opacity:.6">
          <div class="pbiz">${{ptitle}}${{p.reg?'<span class="regtag">REGULATORIO</span>':''}}</div>
          <div class="pdesc">${{p.desc}}</div>
          <div class="psp">${{p.sp}}${{roleTag}} · fan_out ${{p.fo}}</div>
          <div class="ptrig">Disparado por: <b>${{p.trig||'—'}}</b></div>${{flow}}
          <a class="sp-detail-btn" href="${{url}}" target="_blank">Ver historia funcional →</a>
        </div>`;
      }});
    }}

    if(d.exposed.length){{
      h+='<div class="dsec">Servicios expuestos (endpoints)</div>';
      d.exposed.forEach(e=>{{
        const eroleTag=e.role?`<span class="proc-role-tag">${{PROC_ROLE_LABELS[e.role]||e.role}}</span>`:'';
        h+=`<div class="expo"><span class="eb">${{e.biz.charAt(0).toUpperCase()+e.biz.slice(1)}}</span><span class="es">${{e.sp}} · ${{e.ext}} callers${{eroleTag}}</span></div>`;
      }});
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
   const rsrc=c.dataset.rsrc||'';
   const erate=parseFloat(c.dataset.erate);
   const riskSrc=rsrc==='log+register'?'logs+register':rsrc==='log'?'logs ESB':rsrc==='register'?'risk register':'';
   const rateStr=erate>=0?`<div class="tr">Error rate (ESB): <b style="color:${{erate>=25?'#f87171':erate>=8?'#fbbf24':'#4ade80'}}">${{erate}}%</b></div>`:'';
   const riskLine=risk==='critical'
     ?`<div class="tr" style="color:#FF6B35;font-weight:700">! Riesgo crítico [${{riskSrc}}]</div>`
     :risk==='warn'
     ?`<div class="tr" style="color:#F0D224;font-weight:700">! Riesgo operativo [${{riskSrc}}]</div>`
     :'';
   const tierLabel={{h:'Núcleo de lógica',m:'Lógica + integración',l:'Conector / Portal'}};
   const tier=c.classList.contains('on-h')?'h':c.classList.contains('on-l')?'l':'m';
   const nJcap=parseInt(c.dataset.jcap||'0');
   const jcapLine=nJcap>0?`<div class="tr">Journeys esta cap: <b style="color:#F0D224">${{nJcap}}</b> · total dominio: <b>${{c.dataset.j}}</b></div>`
     :`<div class="tr">Journeys dominio: <b>${{c.dataset.j}}</b></div>`;
   tip.innerHTML=`<div class="tt">${{c.dataset.n}}</div>
     <div class="tr">Dominio: <b>${{c.dataset.b}} · ${{c.dataset.dom}}</b></div>
     <div class="tr">Carácter: <b>${{tierLabel[tier]||'—'}}</b></div>
     ${{jcapLine}}
     <div class="tr">Reglas: <b>${{c.dataset.r}}</b> · SPs: <b>${{Number(c.dataset.s).toLocaleString('es-MX')}}</b></div>
     ${{rateStr}}${{riskLine}}
     <div class="tr" style="color:#c4b5fd">▸ Click para ver journeys de esta capacidad</div>`;
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
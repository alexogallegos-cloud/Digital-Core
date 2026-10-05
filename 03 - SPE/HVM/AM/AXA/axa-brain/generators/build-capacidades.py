"""
build-capacidades.py — Genera portal/capacidades.html
Modelo de capacidades ETB Insurance P&C completo hasta L3, con drill-down a L4.
Fuentes: knowledge-base/etb/etb-capabilities-pc.json + axa-brain.db (process_steps).
Formato: filas por dominio L1 -> grupos L2 -> chips L3 (estilo BanCoppel).
Click en capacidad con procesos mapeados -> panel deslizante con pasos L4.
"""
import json, pathlib, shutil, datetime, sqlite3, collections

ROOT = pathlib.Path(__file__).parent.parent
ETB  = ROOT / "knowledge-base" / "etb" / "etb-capabilities-pc.json"
DB   = ROOT / "axa-brain.db"
OUT  = ROOT / "portal" / "capacidades.html"
LOGO_SRC = ROOT.parent / "design-studio" / "logos" / "Axa_logo.png"
LOGO_DST = ROOT / "portal" / "logos" / "Axa_logo.png"
TODAY = datetime.date.today().isoformat()

if LOGO_SRC.exists():
    LOGO_DST.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(LOGO_SRC, LOGO_DST)

data = json.loads(ETB.read_text(encoding="utf-8"))
domains = data["domains"]
l3cat = data.get("l3_catalog", {})

TIER = {"D1":"engage","D2":"engage","D3":"engage","D4":"engage","D5":"engage",
        "D6":"core","D7":"ent","D8":"found","D9":"found","D10":"found","D11":"found"}
TIER_LABEL = {"engage":"Engagement","core":"Core Insurance","ent":"Enterprise Functions","found":"Foundation"}


def esc(s):
    return (str(s) if s is not None else "").replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def l2_name(code):
    for did, dom in domains.items():
        if code in dom.get("l2", {}):
            return dom["l2"][code].get("name", code)
    return code


def cap_name(code):
    if code in l3cat:
        return l3cat[code].get("name", code)
    return l2_name(code)


def idkey(s):
    return tuple(int(x) for x in str(s).split(".") if x.isdigit())


# ── Procesos L4 desde el brain ────────────────────────────────────────────────
conn = sqlite3.connect(DB)
prows = conn.execute(
    "SELECT id, etb_capability, fase_l2, etapa_l3, paso_l4, sistemas_raw, roles, regla_negocio, lob "
    "FROM process_steps"
).fetchall()
conn.close()

proc = {}
for pid, cap, f2, e3, p4, sysr, roles, rule, lob in prows:
    cap = (cap or "").strip()
    if not cap:
        continue
    proc.setdefault(cap, []).append((pid, f2, e3, p4, sysr, roles, rule, lob))

PROC = {}
for cap, steps in proc.items():
    steps.sort(key=lambda r: idkey(r[0]))
    PROC[cap] = {
        "name": cap_name(cap),
        "steps": [
            {"l2": s[1], "l3": s[2], "l4": s[3], "sys": s[4], "roles": s[5], "rule": s[6], "lob": s[7]}
            for s in steps
        ],
    }
PROC_JSON = json.dumps(PROC, ensure_ascii=False, separators=(",", ":"))
proc_keys = set(PROC.keys())

# ── Pasos PROPUESTOS desde el ETB (no verificados) ────────────────────────────
# Fusiona todos los archivos etb-reference-*.json (Core + swarm por dominio).
REF = {}
for rp in sorted((ROOT / "knowledge-base" / "etb").glob("etb-reference-*.json")):
    try:
        caps = json.loads(rp.read_text(encoding="utf-8")).get("capabilities", {})
        for code, v in caps.items():
            REF[code] = v
    except Exception:
        pass
ref_keys = set(REF.keys())


def name_of(code):
    if code in l3cat:
        return l3cat[code].get("name", code)
    if code in REF and REF[code].get("name"):
        return REF[code]["name"]
    return None


REF2 = {code: {"name": name_of(code) or code, "steps": v.get("steps", [])} for code, v in REF.items()}
REF_JSON = json.dumps(REF2, ensure_ascii=False, separators=(",", ":"))

# ── Sistema que atiende cada capacidad ────────────────────────────────────────
# Nombres reales AXA por slug (los "por confirmar" quedan con slug prettified).
SYS_NAME = {
    "underwriting-engine": "Vector", "policy-admin": "General Daños", "reinsurance": "SAFAC",
    "actuarial": "ERN", "crm": "SINCO", "analytics": "Power BI", "reporting-cnsf": "Monitor",
    "claims": "Claims", "billing": "Billing", "portal-agentes": "Portal Agentes", "digital": "Digital",
    "datawarehouse": "Datawarehouse", "api-gateway": "API Gateway", "event-bus": "Event Bus",
    "cnsf": "CNSF", "solvency": "Solvency",
}


def disp_sys(slug):
    if not slug:
        return ""
    return SYS_NAME.get(slug, slug.replace("-", " ").title())


def primary_sys(code):
    # Core: sistema explícito del catálogo ETB. No-Core: sistema más frecuente en los pasos propuestos.
    if code in l3cat and l3cat[code].get("system"):
        return l3cat[code]["system"]
    if code in REF:
        cnt = collections.Counter(s.get("sistema") for s in REF[code].get("steps", []) if s.get("sistema"))
        if cnt:
            return cnt.most_common(1)[0][0]
    return None


SYSOF = {}
for _did, _dom in domains.items():
    for _l2id, _l2 in _dom.get("l2", {}).items():
        for _code in _l2.get("l3", []):
            _ps = primary_sys(_code)
            if _ps:
                SYSOF[_code] = disp_sys(_ps)
SYSOF_JSON = json.dumps(SYSOF, ensure_ascii=False, separators=(",", ":"))


# ── Filas L1 -> L2 -> L3 ──────────────────────────────────────────────────────
rows = []
n_l2 = n_l3 = n_named = 0
for did, dom in domains.items():
    tier = TIER.get(did, "found")
    l2s = dom.get("l2", {})
    n_l2 += len(l2s)
    dl3 = sum(len(l2.get("l3", [])) for l2 in l2s.values())
    n_l3 += dl3
    groups = []
    for l2id, l2 in l2s.items():
        l2name = esc(l2.get("name", l2id))
        codes = l2.get("l3", [])
        if l2id in proc_keys:
            gl_attr = f' class="gl clickable" onclick="openCap(\'{l2id}\')" title="Ver {len(PROC[l2id]["steps"])} pasos L4"'
        else:
            gl_attr = ' class="gl"'
        chips = []
        for code in codes:
            cat = l3cat.get(code)
            nm = name_of(code)
            has_v = code in proc_keys
            has_r = code in ref_keys
            clickable = has_v or has_r
            click_attr = f' onclick="openCap(\'{code}\')"' if clickable else ""
            cls_click = " clickable" if clickable else ""
            if has_v:
                l4b = f'<span class="l4badge">{len(PROC[code]["steps"])} L4</span>'
            elif has_r:
                l4b = f'<span class="etbbadge">{len(REF[code]["steps"])} ETB</span>'
            else:
                l4b = ""
            if nm:
                n_named += 1
                nm_e = esc(nm)
                sysn = esc(SYSOF.get(code, ""))
                pri = cat.get("priority", "") if cat else ""
                pcls = "pri-high" if pri == "high" else ("pri-med" if pri == "medium" else "")
                badge = f'<span class="cb">{sysn}</span>' if sysn else ''
                dot = '<span class="pdot"></span>' if pri == "high" else ''
                chips.append(
                    f'<div class="cap named {pcls}{cls_click}"{click_attr}><span class="cn">{nm_e}{dot}</span>'
                    f'<div class="cbrow"><span class="ccode">{esc(code)}</span>{badge}{l4b}</div></div>'
                )
            else:
                chips.append(
                    f'<div class="cap pending{cls_click}"{click_attr}><span class="cn">L3 {esc(code)}</span>'
                    f'<span class="ccode">por detallar</span>{l4b}</div>'
                )
        groups.append(
            f'<div class="grp"><div{gl_attr}>{l2name} <em>{len(codes)}</em></div>'
            f'<div class="caps">{"".join(chips)}</div></div>'
        )
    rows.append(
        f'<div class="area t-{tier}" id="area-{did}"><div class="atitle">'
        f'<div class="an">{esc(dom["name"])}</div>'
        f'<div class="ac">{dl3} L3 &middot; {len(l2s)} L2 &middot; {TIER_LABEL[tier]}</div></div>'
        f'<div class="agroups">{"".join(groups)}</div></div>'
    )

ROWS = "\n".join(rows)
n_pending = n_l3 - n_named
n_with_l4 = sum(len(v["steps"]) for v in PROC.values())
n_ref_caps = len(ref_keys)
n_ref_steps = sum(len(v.get("steps", [])) for v in REF.values())
pending_legend = ('<span class="lg"><span class="sw" style="background:rgba(255,255,255,.03);'
                  'border:1px dashed rgba(255,255,255,.3)"></span>L3 por detallar</span>') if n_pending else ''

CSS = """
*{margin:0;padding:0;box-sizing:border-box}
:root{--axa-red:#FF1721;--bg:#04040F;--bg2:#080820;--muted:rgba(255,255,255,.45);
  --card-bg:rgba(255,255,255,.04);--card-border:rgba(255,255,255,.08)}
body{background:var(--bg);color:#fff;font-family:'Inter','Segoe UI',sans-serif;min-height:100vh}
nav{display:flex;align-items:center;justify-content:space-between;padding:0 40px;height:64px;
  border-bottom:1px solid rgba(255,255,255,.06);background:rgba(4,4,15,.95);
  -webkit-backdrop-filter:blur(8px);backdrop-filter:blur(8px);position:sticky;top:0;z-index:100}
.nav-logo{display:flex;align-items:center;gap:14px}
.nav-logo .red-bar{width:4px;height:36px;background:var(--axa-red);border-radius:2px}
.nav-logo img{height:28px;object-fit:contain}
.nav-tagline{display:flex;flex-direction:column;gap:1px;border-left:1px solid rgba(255,255,255,.12);padding-left:14px;margin-left:2px}
.nav-tagline-eyebrow{font-size:8px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--muted)}
.nav-tagline-text{font-size:12px;font-weight:600;color:rgba(255,255,255,.8);letter-spacing:-.01em;white-space:nowrap}
.nav-links a{font-size:12px;font-weight:600;letter-spacing:.06em;color:var(--muted);
  text-decoration:none;margin-left:22px;transition:color .2s}
.nav-links a:hover{color:#fff}
.wrap{max-width:1560px;margin:0 auto;padding:40px}
.eyebrow{font-size:11px;font-weight:700;letter-spacing:.2em;color:var(--axa-red);text-transform:uppercase;margin-bottom:12px}
h1{font-size:clamp(26px,3.4vw,42px);font-weight:900;letter-spacing:-.02em;margin-bottom:12px;
  background:linear-gradient(135deg,#fff 55%,rgba(255,255,255,.4));-webkit-background-clip:text;background-clip:text;color:transparent}
.sub{font-size:14px;color:var(--muted);max-width:800px;line-height:1.7;margin-bottom:24px}
.tiles{display:flex;flex-wrap:wrap;gap:0;background:rgba(3,3,40,.7);border:1px solid var(--card-border);
  border-radius:12px;overflow:hidden;margin-bottom:18px;max-width:1000px}
.tile{flex:1;min-width:110px;padding:16px 22px;border-right:1px solid rgba(255,255,255,.06)}
.tile:last-child{border-right:none}
.tile .n{font-size:1.7rem;font-weight:900;letter-spacing:-.03em;line-height:1}
.tile .l{font-size:8.5px;font-weight:700;letter-spacing:.1em;color:rgba(255,255,255,.4);text-transform:uppercase;margin-top:4px}
.legend{display:flex;flex-wrap:wrap;gap:16px;margin-bottom:20px;font-size:10.5px;color:var(--muted)}
.legend .lg{display:flex;align-items:center;gap:7px}
.legend .sw{width:13px;height:13px;border-radius:3px}
.capmap{border:1px solid var(--card-border);border-radius:12px;overflow:hidden;background:rgba(3,3,24,.4)}
.area{display:flex;gap:16px;padding:14px 18px;border-bottom:1px solid rgba(255,255,255,.06)}
.area:last-child{border-bottom:none}
.atitle{min-width:196px;max-width:196px;padding-left:12px;border-left:3px solid rgba(255,255,255,.2)}
.atitle .an{font-size:13px;font-weight:800;color:#fff;line-height:1.25}
.atitle .ac{font-size:9px;font-weight:700;color:var(--muted);margin-top:4px}
.agroups{flex:1;display:flex;flex-wrap:wrap;gap:12px;align-content:flex-start}
.grp{background:rgba(0,0,0,.18);border-radius:8px;padding:8px 9px}
.gl{font-size:8px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:6px;padding-left:2px}
.gl em{font-style:normal;opacity:.6}
.gl.clickable{cursor:pointer;color:#ff8866}
.gl.clickable:hover{color:#ffab99}
.caps{display:flex;flex-wrap:wrap;gap:5px}
.cap{border-radius:6px;padding:6px 9px;min-width:118px;display:flex;flex-direction:column;gap:3px}
.cap .cn{font-size:10px;font-weight:700;line-height:1.2;display:flex;align-items:center;gap:5px}
.cbrow{display:flex;align-items:center;gap:5px;flex-wrap:wrap}
.cap .ccode{font-size:7.5px;font-weight:700;opacity:.55;font-family:'Cascadia Code',Consolas,monospace}
.cap .cb{font-size:7.5px;font-weight:800;background:rgba(255,255,255,.1);padding:1px 5px;border-radius:3px;letter-spacing:.02em}
.cap .l4badge{font-size:7.5px;font-weight:800;background:var(--axa-red);color:#fff;padding:1px 5px;border-radius:3px}
.cap .etbbadge{font-size:7.5px;font-weight:800;background:rgba(255,167,38,.9);color:#1a1200;padding:1px 5px;border-radius:3px}
.dbanner{border-radius:8px;padding:10px 14px;font-size:11.5px;line-height:1.5;margin:8px 0 14px}
.dbanner b{font-weight:800}
.dbanner.verif{background:rgba(68,170,255,.12);border:1px solid rgba(68,170,255,.32);color:#bfe0ff}
.dbanner.prop{background:rgba(255,167,38,.1);border:1px dashed rgba(255,167,38,.5);color:#ffe0b0}
.dstep.prop{border-left-color:rgba(255,167,38,.6);border-left-style:dashed;background:rgba(255,167,38,.03)}
.pdot{width:6px;height:6px;border-radius:50%;background:var(--axa-red);box-shadow:0 0 6px rgba(255,23,33,.8);flex-shrink:0}
.cap.pending{background:rgba(255,255,255,.03);border:1px dashed rgba(255,255,255,.12);color:rgba(255,255,255,.4);min-width:96px}
.cap.pending .cn{font-weight:600}
.cap:not(.clickable){cursor:default}
.cap.clickable{cursor:pointer;transition:filter .15s,transform .15s,box-shadow .15s}
.cap.clickable:hover{filter:brightness(1.3);transform:translateY(-2px);box-shadow:0 5px 16px rgba(255,23,33,.32)}
.cap .l4badge{animation:l4pulse 1.9s ease-in-out infinite}
@keyframes l4pulse{50%{opacity:.5}}
.l4-callout{display:flex;align-items:center;gap:16px;
  background:linear-gradient(135deg,rgba(255,23,33,.1),rgba(0,0,143,.12));
  border:1px solid rgba(255,90,60,.3);border-radius:12px;padding:14px 20px;margin-bottom:20px}
.l4-callout .lc-txt{font-size:13px;color:rgba(255,255,255,.85);flex:1;line-height:1.55}
.l4-callout .lc-txt b{color:#ff7a5c}
.l4-callout a{background:var(--axa-red);color:#fff;font-size:12px;font-weight:700;padding:10px 20px;
  border-radius:8px;text-decoration:none;white-space:nowrap;transition:opacity .2s}
.l4-callout a:hover{opacity:.85}
.t-engage .atitle{border-left-color:#44aaff}
.t-engage .cap.named{background:rgba(68,170,255,.14);border:1px solid rgba(68,170,255,.3);color:#d6ecff}
.t-core .atitle{border-left-color:#ff5a3c}
.t-core .cap.named{background:rgba(255,80,50,.15);border:1px solid rgba(255,90,60,.38);color:#ffdccf}
.t-ent .atitle{border-left-color:#ffa726}
.t-ent .cap.named{background:rgba(255,167,38,.13);border:1px solid rgba(255,167,38,.34);color:#ffe6c2}
.t-found .atitle{border-left-color:#4dd0e1}
.t-found .cap.named{background:rgba(77,208,225,.12);border:1px solid rgba(77,208,225,.32);color:#cef4f9}
.cap.named.pri-high{box-shadow:inset 3px 0 0 var(--axa-red)}
footer{text-align:center;padding:36px 0 16px;font-size:11px;color:rgba(255,255,255,.25);
  border-top:1px solid rgba(255,255,255,.06);margin-top:30px}
/* ── Drill-down panel L4 ── */
#dscrim{position:fixed;inset:0;background:rgba(0,0,0,.55);z-index:150;display:none}
#dpanel{position:fixed;top:0;right:-58%;width:56%;max-width:840px;height:100vh;background:#080820;
  border-left:2px solid var(--axa-red);z-index:200;transition:right .32s cubic-bezier(.4,0,.2,1);
  box-shadow:-14px 0 44px rgba(0,0,0,.6);display:flex;flex-direction:column}
#dpanel.open{right:0}
#dhead{padding:20px 26px;border-bottom:1px solid rgba(255,255,255,.08);
  background:linear-gradient(135deg,#0a0a42,#2a0a1e);flex-shrink:0;position:relative}
#dhead .dcode{font-size:10px;font-weight:800;letter-spacing:.12em;color:var(--axa-red)}
#dhead .dcap{font-size:20px;font-weight:800;color:#fff;margin-top:5px}
#dhead .dsys{font-size:12px;color:#e8ecff;margin-top:8px}
#dhead .dsys b{color:#66b3ff;font-weight:800}
#dhead .dsys-est{color:rgba(255,255,255,.4);font-size:10px}
#dhead .dstat{font-size:11px;color:rgba(255,255,255,.6);margin-top:5px}
#dclose{position:absolute;top:18px;right:22px;cursor:pointer;color:#fff;font-size:24px;background:none;border:none;opacity:.75;line-height:1}
#dclose:hover{opacity:1}
#dbody{flex:1;overflow-y:auto;padding:18px 26px 40px}
.dphase{font-size:11px;font-weight:800;letter-spacing:.06em;color:#66b3ff;text-transform:uppercase;
  margin:18px 0 8px;padding-bottom:5px;border-bottom:1px solid rgba(68,170,255,.2)}
.dstage{font-size:12.5px;font-weight:700;color:#ffb347;margin:13px 0 7px}
.dstep{background:var(--card-bg);border:1px solid var(--card-border);border-left:3px solid rgba(68,170,255,.5);
  border-radius:8px;padding:11px 14px;margin-bottom:8px}
.dstep .dl4{font-size:12.5px;color:#e8ecff;line-height:1.5}
.dstep .dmeta{font-size:10px;color:var(--muted);margin-top:8px;display:flex;flex-wrap:wrap;gap:12px}
.dstep .dmeta b{color:#9ab0d0;font-weight:700}
.dstep .drule{font-size:10.5px;color:#c8b06a;margin-top:6px;font-style:italic}
@media(max-width:820px){.area{flex-direction:column;gap:10px}.atitle{max-width:none;min-width:0}#dpanel{width:92%;right:-96%}}
"""

HTML = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Capacidades ETB L3/L4 — AXA Digital Brain</title>
<style>{CSS}</style></head><body>
<nav>
  <div class="nav-logo"><div class="red-bar"></div>
    <img src="logos/Axa_logo.png" alt="AXA"></div>
  <div class="nav-links">
    <a href="index.html">&#8592; Portal</a>
    <a href="index.html#capacidades">Modelo L1/L2</a>
    <a href="cadena-de-valor.html">Cadena de Valor</a>
  </div>
</nav>
<div class="wrap">
  <div class="eyebrow">Modelo de capacidades &middot; ETB Insurance P&amp;C &middot; Nivel L3 &rarr; L4</div>
  <h1>Capacidades de Negocio &mdash; Detalle L3</h1>
  <p class="sub">Las {n_l3} capacidades hoja (L3) del ETB, agrupadas por sus {n_l2} L2 y {len(domains)} dominios L1.
  Clic en un chip con insignia para ver sus pasos: <span style="color:#ff7a5c;font-weight:700">"L4"</span> = AS-IS verificado (discovery de suscripci&oacute;n); <span style="color:#ffc266;font-weight:700">"ETB"</span> = propuesta de referencia derivada del marco (no verificada).</p>
  <div class="tiles">
    <div class="tile"><div class="n">{len(domains)}</div><div class="l">Dominios L1</div></div>
    <div class="tile"><div class="n">{n_l2}</div><div class="l">Capacidades L2</div></div>
    <div class="tile"><div class="n">{n_l3}</div><div class="l">Capacidades L3</div></div>
    <div class="tile"><div class="n" style="color:var(--axa-red)">{n_with_l4}</div><div class="l">Pasos L4 verificados</div></div>
    <div class="tile"><div class="n" style="color:#ffb347">{n_ref_steps}</div><div class="l">Pasos propuestos ETB</div></div>
  </div>
  <div class="legend">
    <span class="lg"><span class="sw" style="background:#44aaff"></span>Engagement</span>
    <span class="lg"><span class="sw" style="background:#ff5a3c"></span>Core Insurance</span>
    <span class="lg"><span class="sw" style="background:#ffa726"></span>Enterprise Functions</span>
    <span class="lg"><span class="sw" style="background:#4dd0e1"></span>Foundation</span>
    <span class="lg"><span class="l4badge">L4</span>&nbsp;AS-IS verificado (discovery)</span>
    <span class="lg"><span class="etbbadge">ETB</span>&nbsp;Propuesta ETB (no verificado)</span>
    {pending_legend}
  </div>
  <div class="l4-callout">
    <div class="lc-txt"><b>{n_with_l4} pasos verificados</b> en Underwriting (insignia roja <span class="l4badge" style="animation:none">L4</span>) &nbsp;+&nbsp; <b>{n_ref_steps} pasos de referencia propuestos</b> en {n_ref_caps} capacidades (insignia &aacute;mbar <span class="etbbadge">ETB</span>), derivados del marco ETB, DTs y criterio regulatorio. Clic en cualquier chip con insignia para ver sus pasos.</div>
    <a href="#area-D6">Ir a Product &amp; Operations &rarr;</a>
  </div>
  <div class="capmap">
{ROWS}
  </div>
  <footer>AXA Seguros M&eacute;xico &middot; Digital Brain &middot; ETB Insurance P&amp;C v{data.get("meta",{}).get("version","3.0")} &middot; {n_with_l4} pasos L4 &middot; Generado {TODAY} desde <code>build-capacidades.py</code></footer>
</div>

<div id="dscrim" onclick="closeCap()"></div>
<div id="dpanel">
  <div id="dhead">
    <div class="dcode" id="dcode"></div>
    <div class="dcap" id="dcap"></div>
    <div class="dsys" id="dsys"></div>
    <div class="dstat" id="dstat"></div>
    <button id="dclose" onclick="closeCap()">&times;</button>
  </div>
  <div id="dbody"></div>
</div>

<script>
var PROC = {PROC_JSON};
var REF = {REF_JSON};
var SYSOF = {SYSOF_JSON};
function esc(s){{return (s==null?'':String(s)).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}}
function openCap(code){{
  var v=PROC[code], r=REF[code];
  if(!v&&!r)return;
  var name=(v&&v.name)||(r&&r.name)||code;
  document.getElementById('dcode').textContent='ETB '+code;
  document.getElementById('dcap').textContent=name;
  var sy=SYSOF[code];
  document.getElementById('dsys').innerHTML=sy?('Sistema que atiende: <b>'+esc(sy)+'</b>'+(v?'':' <span class="dsys-est">(estimado de los pasos)</span>')):'';
  var stat=[];
  if(v)stat.push(v.steps.length+' pasos verificados');
  if(r)stat.push(r.steps.length+' pasos propuestos ETB');
  document.getElementById('dstat').textContent=stat.join('  ·  ');
  var body=document.getElementById('dbody'); body.innerHTML='';
  if(v){{
    var bn=document.createElement('div');bn.className='dbanner verif';
    bn.innerHTML='<b>AS-IS verificado</b> &mdash; pasos del discovery de campo de suscripción';
    body.appendChild(bn);
    var curL2=null,curL3=null;
    v.steps.forEach(function(s){{
      if(s.l2!==curL2){{curL2=s.l2;curL3=null;var h=document.createElement('div');h.className='dphase';h.textContent=s.l2||'Proceso';body.appendChild(h);}}
      if(s.l3!==curL3){{curL3=s.l3;var h=document.createElement('div');h.className='dstage';h.textContent=s.l3||'';body.appendChild(h);}}
      var el=document.createElement('div');el.className='dstep';
      var html='<div class="dl4">'+esc(s.l4)+'</div>';
      var meta=[];
      if(s.sys)meta.push('<span><b>Sistemas:</b> '+esc(s.sys)+'</span>');
      if(s.roles)meta.push('<span><b>Rol:</b> '+esc(s.roles)+'</span>');
      if(s.lob)meta.push('<span><b>LoB:</b> '+esc(s.lob)+'</span>');
      if(meta.length)html+='<div class="dmeta">'+meta.join('')+'</div>';
      if(s.rule)html+='<div class="drule">Regla: '+esc(s.rule)+'</div>';
      el.innerHTML=html;body.appendChild(el);
    }});
  }}
  if(r){{
    var bn=document.createElement('div');bn.className='dbanner prop';
    bn.innerHTML='<b>Propuesta ETB &middot; No verificado</b> &mdash; pasos de referencia derivados del marco, pendientes de discovery en campo';
    body.appendChild(bn);
    r.steps.forEach(function(s){{
      var el=document.createElement('div');el.className='dstep prop';
      var html='<div class="dl4">'+esc(s.paso)+'</div>';
      var meta=[];
      if(s.sistema)meta.push('<span><b>Sistema:</b> '+esc(s.sistema)+'</span>');
      if(s.rol)meta.push('<span><b>Rol:</b> '+esc(s.rol)+'</span>');
      if(meta.length)html+='<div class="dmeta">'+meta.join('')+'</div>';
      el.innerHTML=html;body.appendChild(el);
    }});
  }}
  body.scrollTop=0;
  document.getElementById('dpanel').classList.add('open');
  document.getElementById('dscrim').style.display='block';
}}
function closeCap(){{document.getElementById('dpanel').classList.remove('open');document.getElementById('dscrim').style.display='none';}}
document.addEventListener('keydown',function(e){{if(e.key==='Escape')closeCap();}});
</script>
</body></html>"""

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(HTML, encoding="utf-8")
print(f"[ok] {OUT}  ({OUT.stat().st_size:,} bytes)")
print(f"     {len(domains)} L1 · {n_l2} L2 · {n_l3} L3 · {len(PROC)} caps con L4 ({n_with_l4} pasos)")
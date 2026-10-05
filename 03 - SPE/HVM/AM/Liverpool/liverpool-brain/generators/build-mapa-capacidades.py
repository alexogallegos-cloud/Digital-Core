#!/usr/bin/env python3
"""
build-mapa-capacidades.py — Liverpool Brain Capability Map Generator
SPE-AM-003 · High Velocity Modernization

Genera portal/mapa-capacidades.html:
  Grilla visual L1 → L2 → L3 al estilo BanCoppel.
  Cada sección = un grupo L1. Sub-secciones = grupos L2. Tarjetas = capacidades L3.
  Cobertura calculada por componentes en el dominio retail asociado al L1.

Ejecutar desde liverpool-brain/:
    python generators/build-mapa-capacidades.py
"""

import json
import re
import html as html_mod
from pathlib import Path
from datetime import date
from collections import OrderedDict

BASE_DIR  = Path(__file__).parent.parent
RTL_PATH  = BASE_DIR / "rtl-capabilities.json"
FSV_PATH  = BASE_DIR / "fsv-capabilities.json"
OUT_PATH  = BASE_DIR / "portal" / "mapa-capacidades.html"
LOGO_PATH = "Liverpool_logo.png"

# ── Mapas de dominio ────────────────────────────────────────────────────────
RTL_DOMAIN_MAP = {
    1: ["R05"],
    2: ["R02"],
    3: ["R01", "R05", "R06"],
    4: ["R01"],
    5: ["R01"],
    6: ["R04"],
    7: ["R07", "R08"],
    8: ["R09", "R10"],
    9: ["R09"],
}
FSV_DOMAIN_MAP = {k: ["R03"] for k in range(1, 7)}

DOMAIN_COMPS = {
    "R01": 17, "R02": 0, "R03": 19, "R04": 26,
    "R05": 15, "R06": 10, "R07": 19, "R08": 6,
    "R09": 5,  "R10": 0,
}
DOMAIN_SHORT = {
    "R01": "Comercial", "R02": "Clientes", "R03": "FinServ",
    "R04": "Supply",    "R05": "Digital",  "R06": "Tienda",
    "R07": "Finanzas",  "R08": "RRHH",     "R09": "Analytics", "R10": "Infra",
}
# Sistemas principales por dominio (fuente: retail_domains primary_systems)
DOMAIN_SYSTEMS = {
    "R01": ["SAP", "Mainframe"],
    "R02": ["Oracle", "Digital Platform"],
    "R03": ["Oracle", "Mainframe"],
    "R04": ["SAP", "Digital Platform"],
    "R05": ["Digital Platform"],
    "R06": ["SAP", "Mainframe"],
    "R07": ["SAP", "Oracle"],
    "R08": ["SAP"],
    "R09": ["Digital Platform", "SAP"],
    "R10": ["Digital Platform"],
}
SYS_FULLNAME = {
    "SAP": "SAP ECC (on-prem)", "Mainframe": "Mainframe", "Oracle": "Oracle PL-SQL", "Digital Platform": "Digital Platform",
}
SYS_ABBR = {
    "SAP": "SAP", "Mainframe": "Mainframe", "Oracle": "Oracle", "Digital-Platform": "Digital Platform",
}


def esc(s: str) -> str:
    return html_mod.escape(str(s or ""), quote=True)


def clean_l1(name: str) -> str:
    return re.sub(r"^\d+\.\s*", "", name).strip()


def coverage(domains: list) -> str:
    """gap | partial | covered"""
    comps = [DOMAIN_COMPS.get(d, 0) for d in domains]
    if all(c == 0 for c in comps):
        return "gap"
    if any(c == 0 for c in comps):
        return "partial"
    return "covered"


def sys_depth(primary_system: str) -> str:
    """core | integration | (empty)"""
    if not primary_system:
        return ""
    ps = primary_system.lower()
    if "digital" in ps:
        return "integration"
    return "core"


def derived_systems(domains: list) -> list:
    """Unique ordered system abbreviations inferred from domain map."""
    seen, result = set(), []
    for d in domains:
        for s in DOMAIN_SYSTEMS.get(d, []):
            if s not in seen:
                seen.add(s)
                result.append(s)
    return result


def dom_chips(domains: list) -> str:
    chips = []
    for d in domains:
        is_gap = DOMAIN_COMPS.get(d, 0) == 0
        cls = "dom-chip gap-dom" if is_gap else "dom-chip"
        chips.append(f'<span class="{cls}" title="{DOMAIN_SHORT.get(d, d)}">{d}</span>')
    return "".join(chips)


def render_card(cap: dict, domains: list, origin: str) -> str:
    cov   = coverage(domains)
    depth = sys_depth(cap.get("primary_system") or "")
    name  = esc(cap.get("l3_name") or cap["id"])
    chips = dom_chips(domains)

    # Direct system from capability record (confirmed mapping) — full name lookup
    direct_raw  = (cap.get("primary_system") or "").split("/")[0].strip()
    direct_name = SYS_ABBR.get(direct_raw, direct_raw if direct_raw else "")

    # Systems inferred from domain map (already full names)
    inferred = derived_systems(domains)
    all_gap  = cov == "gap"

    # Build system chips
    sys_parts = []
    if not all_gap:
        if direct_name:
            # confirmed direct mapping → "Total" for this system
            sys_parts.append(f'<span class="sys-chip confirmed" title="{esc(direct_name)} — cobertura total confirmada">{esc(direct_name)}</span>')
            # remaining inferred systems → "Parcial"
            for s in inferred:
                if s != direct_name:
                    sys_parts.append(f'<span class="sys-chip inferred" title="{esc(s)} — cobertura parcial, inferida del dominio">{esc(s)}</span>')
            cov_badge = '<span class="cov-badge total">Total</span>'
        else:
            # only domain-inferred → "Parcial"
            for s in inferred:
                sys_parts.append(f'<span class="sys-chip inferred" title="{esc(s)} — cobertura parcial, inferida del dominio">{esc(s)}</span>')
            cov_badge = '<span class="cov-badge parcial">Parcial</span>'
    else:
        cov_badge = ""

    sys_html = "".join(sys_parts)

    reg_html = ""
    if origin == "fsv":
        reg = cap.get("regulation") or []
        if isinstance(reg, list) and reg:
            reg_html = f'<span class="reg-chip">{esc(", ".join(reg[:2]))}</span>'

    classes = f"cap-card {origin} {cov}" + (f" {depth}" if depth else "")

    return (
        f'<div class="{classes}">'
        f'<div class="cap-name">{name}</div>'
        f'<div class="cap-meta">{chips}{sys_html}{cov_badge}{reg_html}</div>'
        f'</div>'
    )


def build_section(l1_num: int, l1_name: str, caps: list, origin: str) -> str:
    dom_map = RTL_DOMAIN_MAP if origin == "rtl" else FSV_DOMAIN_MAP
    domains = dom_map.get(l1_num, [])
    prefix  = "RTL" if origin == "rtl" else "FSV"
    cov     = coverage(domains)

    l2_groups: OrderedDict = OrderedDict()
    for cap in caps:
        key = cap.get("l2_name") or "General"
        l2_groups.setdefault(key, []).append(cap)

    sec_cls = f"l1-section {origin}" + (" is-gap" if cov == "gap" else "")
    dom_html = dom_chips(domains)
    gap_badge = '<span class="gap-badge">GAP</span>' if cov == "gap" else ""

    inner = []
    for l2_name, l2_caps in l2_groups.items():
        cards_html = "".join(render_card(c, domains, origin) for c in l2_caps)
        inner.append(
            f'<div class="l2-group">'
            f'<div class="l2-label">{esc(l2_name.upper())}</div>'
            f'<div class="l2-cards">{cards_html}</div>'
            f'</div>'
        )

    return (
        f'<section class="{sec_cls}" data-prefix="{prefix}" data-l1="{l1_num}" data-cov="{cov}">'
        f'<div class="l1-header">'
        f'<span class="l1-badge {origin}">{prefix}.{l1_num}</span>'
        f'<span class="l1-title">{esc(clean_l1(l1_name))}</span>'
        f'{gap_badge}'
        f'<span class="l1-count">{len(caps)} cap.</span>'
        f'<span class="l1-doms">{dom_html}</span>'
        f'</div>'
        f'<div class="l2-wrapper">{"".join(inner)}</div>'
        f'</section>'
    )


def render(rtl_caps: list, fsv_caps: list, today: str) -> str:
    # Group RTL by L1
    rtl_l1: OrderedDict = OrderedDict()
    for cap in rtl_caps:
        key = (cap.get("l1_num", 0), cap.get("l1_name", ""))
        rtl_l1.setdefault(key, []).append(cap)

    # Group FSV by L1
    fsv_l1: OrderedDict = OrderedDict()
    for cap in fsv_caps:
        key = (cap.get("l1_num", 0), cap.get("l1_name", ""))
        fsv_l1.setdefault(key, []).append(cap)

    n_rtl  = len(rtl_caps)
    n_fsv  = len(fsv_caps)
    n_tot  = n_rtl + n_fsv

    # Gap calc: caps whose L1 maps ONLY to zero-component domains
    gap_caps = sum(
        len(caps) for (num, _), caps in rtl_l1.items()
        if all(DOMAIN_COMPS.get(d, 0) == 0 for d in RTL_DOMAIN_MAP.get(num, []))
    )
    covered_caps = n_tot - gap_caps

    rtl_sections = "".join(
        build_section(num, name, caps, "rtl")
        for (num, name), caps in rtl_l1.items()
    )
    fsv_sections = "".join(
        build_section(num, name, caps, "fsv")
        for (num, name), caps in fsv_l1.items()
    )

    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Mapa de Capacidades — Liverpool Brain</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{
  --cerise:#E00198;--cerise-d:#b5007a;
  --sky:#87C3D3;--sky-l:#96CCEE;--rose:#DA7AB0;
  --ink:#F8F0F5;--muted:#c4a8bc;--muted2:#9a7d92;
  --bg:#0d0408;--bg2:#140610;
  --glass:rgba(255,255,255,.05);--glassb:rgba(255,255,255,.09)
}}
html{{scroll-behavior:smooth}}
body{{background:var(--bg);color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;-webkit-font-smoothing:antialiased;padding-bottom:64px}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
.aurora::before{{content:"";position:absolute;width:55vw;height:55vw;left:-10vw;top:-14vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(224,1,152,.32),transparent 70%);animation:f1 28s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:45vw;height:45vw;right:-8vw;top:6vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(135,195,211,.22),transparent 70%);animation:f2 34s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(4vw,6vh) scale(1.1)}}}}
@keyframes f2{{50%{{transform:translate(-5vw,8vh) scale(1.08)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}

nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;
  padding:15px 30px;backdrop-filter:blur(18px) saturate(150%);
  -webkit-backdrop-filter:blur(18px) saturate(150%);
  background:rgba(13,4,8,.55);border-bottom:1px solid rgba(255,255,255,.06)}}
nav img{{height:21px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
nav .nt{{font-size:12.5px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
.edot{{width:6px;height:6px;border-radius:50%;background:var(--cerise);box-shadow:0 0 8px var(--cerise);animation:epulse 2.4s infinite;display:inline-block;margin-right:6px}}
@keyframes epulse{{50%{{opacity:.4}}}}
nav .sp{{flex:1}}
nav a.jump{{font-size:12.5px;color:var(--muted);padding:7px 13px;border-radius:20px;transition:.22s;text-decoration:none}}
nav a.jump:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
nav a.jump.ext{{color:var(--cerise)}}
nav a.jump.ext:hover{{color:#fff}}

.wrap{{max-width:1280px;margin:0 auto;padding:0 30px}}

.page-header{{padding:110px 0 10px;display:flex;flex-direction:column}}
.page-header .eyebrow{{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;
  padding:8px 16px;border-radius:30px;font-size:12px;font-weight:600;letter-spacing:.03em;
  color:#f0dce8;margin-bottom:28px;background:rgba(255,255,255,.05);
  border:1px solid rgba(255,255,255,.09);backdrop-filter:blur(10px)}}
.page-header .eyebrow .dot{{width:7px;height:7px;border-radius:50%;background:var(--cerise);
  box-shadow:0 0 12px var(--cerise);animation:pulse 2.4s infinite}}
@keyframes pulse{{50%{{opacity:.4}}}}
.page-header h1{{font-size:clamp(38px,5vw,68px);font-weight:800;line-height:1.0;letter-spacing:-.035em;
  background:linear-gradient(176deg,#fff 34%,#e8b0d4);-webkit-background-clip:text;
  background-clip:text;color:transparent;margin-bottom:18px}}
.page-eyebrow{{font-size:11px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--cerise);margin-bottom:8px}}
h1{{font-size:clamp(22px,3vw,36px);font-weight:900;letter-spacing:-.03em;background:linear-gradient(175deg,#fff 30%,#e8b0d4);-webkit-background-clip:text;background-clip:text;color:transparent;margin-bottom:6px}}
.page-sub{{font-size:13px;color:var(--muted);line-height:1.6;margin-bottom:20px;max-width:700px}}

.kpi-bar{{display:flex;flex-wrap:wrap;gap:10px;margin-bottom:20px;padding:16px 20px;background:rgba(20,6,16,.7);border:1px solid rgba(255,255,255,.07);border-radius:14px;backdrop-filter:blur(14px)}}
.kpi-item{{display:flex;flex-direction:column;gap:3px;padding-right:20px;border-right:1px solid rgba(255,255,255,.06)}}
.kpi-item:last-child{{border-right:none}}
.kv{{font-size:1.7rem;font-weight:900;letter-spacing:-.03em;line-height:1}}
.kv.sky{{color:var(--sky)}} .kv.cerise{{color:var(--cerise)}} .kv.white{{color:#fff}} .kv.gap{{color:#f87171}}
.kl{{font-size:9px;font-weight:700;letter-spacing:.10em;text-transform:uppercase;color:var(--muted2)}}

.legend{{display:flex;flex-wrap:wrap;gap:14px 20px;align-items:center;font-size:11.5px;color:var(--muted);margin-bottom:18px;padding:10px 16px;background:rgba(20,6,16,.5);border:1px solid rgba(255,255,255,.05);border-radius:10px}}
.lswatch{{width:26px;height:13px;border-radius:4px;flex:none}}
.lswatch.rtl-core{{background:linear-gradient(135deg,rgba(87,165,185,.9),rgba(135,195,211,.7))}}
.lswatch.rtl-int{{background:linear-gradient(135deg,rgba(135,195,211,.5),rgba(150,204,238,.3))}}
.lswatch.fsv-c{{background:linear-gradient(135deg,rgba(224,1,152,.65),rgba(218,122,176,.5))}}
.lswatch.gap-sw{{background:rgba(255,255,255,.04);border:1px dashed rgba(255,255,255,.15)}}
.legend-item{{display:flex;align-items:center;gap:7px}}

.toolbar{{display:flex;flex-wrap:wrap;gap:10px;align-items:center;margin-bottom:20px}}
.filter-grp{{display:flex;gap:6px;flex-wrap:wrap;align-items:center}}
.filter-lbl{{font-size:10px;font-weight:700;color:var(--muted2);text-transform:uppercase;letter-spacing:.07em;min-width:46px}}
.pill{{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.09);border-radius:20px;color:var(--muted);padding:5px 12px;font-size:11.5px;cursor:pointer;transition:.18s;user-select:none;font-family:inherit}}
.pill:hover{{background:rgba(255,255,255,.09);color:var(--ink)}}
.pill.a-all{{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.2);color:var(--ink)}}
.pill.a-rtl{{background:rgba(135,195,211,.2);border-color:rgba(135,195,211,.45);color:var(--sky)}}
.pill.a-fsv{{background:rgba(224,1,152,.18);border-color:rgba(224,1,152,.4);color:var(--cerise)}}
.pill.a-gap{{background:rgba(248,113,113,.15);border-color:rgba(248,113,113,.35);color:#f87171}}
.search{{border:1px solid rgba(255,255,255,.10);border-radius:20px;padding:6px 14px;font-size:12.5px;font-family:inherit;color:var(--ink);background:rgba(255,255,255,.04);min-width:200px}}
.search::placeholder{{color:var(--muted2)}}
.search:focus{{outline:none;border-color:rgba(224,1,152,.5)}}
#stat{{font-size:11px;color:var(--muted2);margin-left:auto;font-variant-numeric:tabular-nums}}

.l1-section{{margin-bottom:24px;background:rgba(20,6,16,.65);border:1px solid rgba(255,255,255,.07);border-radius:16px;overflow:hidden;backdrop-filter:blur(14px)}}
.l1-section.hidden{{display:none}}
.l1-section.is-gap{{border-color:rgba(248,113,113,.18)}}

.l1-header{{display:flex;align-items:center;gap:10px;padding:14px 18px;background:linear-gradient(90deg,rgba(255,255,255,.035),transparent);border-bottom:1px solid rgba(255,255,255,.06);cursor:pointer;user-select:none}}
.l1-header:hover{{background:linear-gradient(90deg,rgba(255,255,255,.055),transparent)}}
.l1-badge{{font-size:11px;font-weight:800;letter-spacing:.04em;padding:4px 9px;border-radius:7px;flex:none}}
.l1-badge.rtl{{background:rgba(135,195,211,.18);border:1px solid rgba(135,195,211,.35);color:var(--sky)}}
.l1-badge.fsv{{background:rgba(224,1,152,.18);border:1px solid rgba(224,1,152,.35);color:var(--cerise)}}
.l1-title{{font-size:15px;font-weight:800;flex:1}}
.l1-section.rtl .l1-title{{color:var(--sky)}}
.l1-section.fsv .l1-title{{color:var(--cerise)}}
.l1-count{{font-size:11px;color:var(--muted2);flex:none}}
.l1-doms{{display:flex;gap:5px;flex:none}}
.gap-badge{{font-size:9px;font-weight:900;letter-spacing:.12em;text-transform:uppercase;padding:3px 8px;border-radius:6px;background:rgba(248,113,113,.15);border:1px solid rgba(248,113,113,.3);color:#f87171;flex:none}}
.chev{{transition:transform .2s;color:var(--muted2);font-size:10px;flex:none;margin-left:6px}}
.l1-section.collapsed .chev{{transform:rotate(-90deg)}}
.l1-section.collapsed .l2-wrapper{{display:none}}

.l2-wrapper{{padding:14px 18px 18px;display:flex;flex-direction:column;gap:18px}}
.l2-label{{font-size:9.5px;font-weight:800;letter-spacing:.16em;text-transform:uppercase;color:var(--muted2);margin-bottom:9px;padding-left:2px}}
.l2-cards{{display:flex;flex-wrap:wrap;gap:8px}}

.cap-card{{width:210px;min-height:68px;border-radius:10px;padding:9px 11px 8px;display:flex;flex-direction:column;gap:6px;transition:.15s;cursor:default}}
.cap-card.hidden{{display:none}}

.cap-card.rtl.covered{{background:linear-gradient(135deg,rgba(135,195,211,.7),rgba(150,204,238,.45));border:1px solid rgba(135,195,211,.45)}}
.cap-card.rtl.covered.core{{background:linear-gradient(135deg,rgba(70,145,165,.9),rgba(135,195,211,.7));border-color:rgba(70,145,165,.65)}}
.cap-card.rtl.covered.integration{{background:linear-gradient(135deg,rgba(135,195,211,.5),rgba(150,204,238,.3));border-color:rgba(135,195,211,.3)}}
.cap-card.rtl.covered .cap-name{{color:#071418}}
.cap-card.rtl.partial{{background:linear-gradient(135deg,rgba(135,195,211,.35),rgba(150,204,238,.2));border:1px solid rgba(135,195,211,.25)}}
.cap-card.rtl.partial .cap-name{{color:var(--ink)}}

.cap-card.fsv.covered{{background:linear-gradient(135deg,rgba(224,1,152,.65),rgba(218,122,176,.45));border:1px solid rgba(224,1,152,.4)}}
.cap-card.fsv.covered .cap-name{{color:#fff}}
.cap-card.fsv.partial{{background:linear-gradient(135deg,rgba(224,1,152,.3),rgba(218,122,176,.2));border:1px solid rgba(224,1,152,.25)}}
.cap-card.fsv.partial .cap-name{{color:var(--ink)}}

.cap-card.gap{{background:rgba(255,255,255,.03);border:1px dashed rgba(255,255,255,.12)}}
.cap-card.gap .cap-name{{color:var(--muted)}}

.cap-card:hover{{transform:translateY(-2px);box-shadow:0 8px 24px rgba(0,0,0,.35)}}
.cap-card.rtl.covered:hover{{box-shadow:0 8px 24px rgba(135,195,211,.22)}}
.cap-card.fsv.covered:hover{{box-shadow:0 8px 24px rgba(224,1,152,.22)}}

.cap-name{{font-size:11.5px;font-weight:700;line-height:1.35;flex:1}}
.cap-meta{{display:flex;flex-wrap:wrap;gap:4px;align-items:center}}

.dom-chip{{font-size:8.5px;font-weight:800;letter-spacing:.04em;padding:2px 5px;border-radius:5px;background:rgba(0,0,0,.22);color:rgba(255,255,255,.88);flex:none}}
.cap-card.gap .dom-chip{{background:rgba(255,255,255,.06);color:var(--muted2)}}
.dom-chip.gap-dom{{background:rgba(248,113,113,.18);color:#f87171;border:1px solid rgba(248,113,113,.3)}}

.sys-chip{{font-size:8px;font-weight:700;letter-spacing:.03em;padding:2px 6px;border-radius:5px;background:rgba(255,255,255,.10);color:rgba(255,255,255,.65);white-space:nowrap}}
.sys-chip.confirmed{{background:rgba(135,195,211,.28);border:1px solid rgba(135,195,211,.55);color:var(--sky)}}
.sys-chip.inferred{{background:rgba(255,255,255,.06);border:1px dashed rgba(255,255,255,.18);color:var(--muted)}}
.cap-card.fsv .sys-chip.confirmed{{background:rgba(218,122,176,.28);border-color:rgba(218,122,176,.55);color:var(--rose)}}
.cap-card.covered .sys-chip.inferred{{background:rgba(0,0,0,.15);border-color:rgba(255,255,255,.2);color:rgba(255,255,255,.55)}}
.cov-badge{{font-size:7.5px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;padding:2px 6px;border-radius:5px;flex:none}}
.cov-badge.total{{background:rgba(135,195,211,.2);border:1px solid rgba(135,195,211,.4);color:var(--sky)}}
.cov-badge.parcial{{background:rgba(255,200,100,.12);border:1px solid rgba(255,200,100,.3);color:#f5c842}}
.cap-card.fsv .cov-badge.total{{background:rgba(224,1,152,.2);border-color:rgba(224,1,152,.4);color:var(--cerise)}}

.reg-chip{{font-size:7.5px;font-weight:700;letter-spacing:.04em;padding:2px 6px;border-radius:5px;background:rgba(218,122,176,.18);border:1px solid rgba(218,122,176,.3);color:var(--rose);flex:none;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}}

.cap-card.hit{{outline:2px solid var(--cerise);outline-offset:2px}}

.etb-divider{{display:flex;align-items:center;gap:12px;margin:28px 0;color:var(--muted2);font-size:11px;font-weight:700;letter-spacing:.12em;text-transform:uppercase}}
.etb-divider::before,.etb-divider::after{{content:"";flex:1;height:1px;background:rgba(224,1,152,.2)}}

footer{{padding:32px 0 16px;text-align:center;color:var(--muted2);font-size:11.5px;line-height:1.8}}
footer code{{color:var(--muted);background:rgba(224,1,152,.10);border:1px solid rgba(224,1,152,.2);border-radius:5px;padding:1px 6px;font-family:'SF Mono',ui-monospace,monospace}}
</style></head><body>
<div class="aurora"></div><div class="grain"></div>

<nav>
  <img src="{LOGO_PATH}" alt="Liverpool" onerror="this.style.display='none'">
  <span class="nt">Liverpool Brain · Capacidades RTL</span>
  <div class="sp"></div>
  <a href="index.html" class="jump">Brain</a>
  <a href="cadena-valor.html" class="jump">Cadena de Valor</a>
  <a href="mapa-capacidades.html" class="jump ext">Capacidades RTL</a>
  <a href="sap-architecture.html" class="jump">Arquitectura SAP</a>
  <a href="sap-modular.html" class="jump">Estructura Modular</a>
</nav>

<div class="wrap">
<div class="page-header">
  <div class="eyebrow"><span class="dot"></span> SPE-AM-003 · Arquitectura Empresarial · Modelo de Capacidades ETB</div>
  <h1>Mapa de Capacidades<br>Compuesto</h1>
  <div class="page-sub">Retail ETB (RTL) + Financial Services overlay (FSV) · {today} · Capacidades L3 agrupadas por dominio L2. Cobertura calculada a partir de componentes inventariados por dominio retail.</div>

  <div class="kpi-bar">
    <div class="kpi-item"><div class="kv white">{n_tot}</div><div class="kl">Capacidades ETB</div></div>
    <div class="kpi-item"><div class="kv sky">{n_rtl}</div><div class="kl">Retail (RTL)</div></div>
    <div class="kpi-item"><div class="kv cerise">{n_fsv}</div><div class="kl">Financiero (FSV)</div></div>
    <div class="kpi-item"><div class="kv white">{covered_caps}</div><div class="kl">Con cobertura</div></div>
    <div class="kpi-item"><div class="kv gap">{gap_caps}</div><div class="kl">Sin cobertura (GAP)</div></div>
    <div class="kpi-item"><div class="kv white">117</div><div class="kl">Componentes</div></div>
  </div>

  <div class="legend">
    <div class="legend-item"><div class="lswatch rtl-core"></div><span>RTL — Lógica core (SAP / Oracle / Mainframe)</span></div>
    <div class="legend-item"><div class="lswatch rtl-int"></div><span>RTL — Integración / Digital Platform</span></div>
    <div class="legend-item"><div class="lswatch fsv-c"></div><span>FSV — Financial Services (R03 LiverpoolCard)</span></div>
    <div class="legend-item"><div class="lswatch gap-sw"></div><span>GAP — dominio sin componentes inventariados</span></div>
    <div class="legend-item"><span class="cov-badge total" style="font-size:9px">Total</span><span>Sistema identificado directamente en la capacidad</span></div>
    <div class="legend-item"><span class="cov-badge parcial" style="font-size:9px">Parcial</span><span>Sistema inferido del dominio retail (pendiente confirmación en Etapa 0)</span></div>
  </div>
</div>

<div class="toolbar">
  <div class="filter-grp">
    <span class="filter-lbl">Filtro</span>
    <button class="pill a-all" id="f-all" onclick="setFilter('all')">Todo</button>
    <button class="pill"       id="f-rtl" onclick="setFilter('rtl')">Solo RTL</button>
    <button class="pill"       id="f-fsv" onclick="setFilter('fsv')">Solo FSV</button>
    <button class="pill"       id="f-gap" onclick="setFilter('gap')">Gaps</button>
  </div>
  <input class="search" id="q" type="search" placeholder="Buscar capacidad…">
  <span id="stat"></span>
</div>

<div id="sections">
{rtl_sections}
<div class="etb-divider" id="fsv-divider">Financial Services Overlay &mdash; FSV &middot; LiverpoolCard &middot; R03</div>
{fsv_sections}
</div>

<footer>
  <p>Liverpool Brain &middot; SPE-AM-003 &middot; Generado el {today}</p>
  <p>Accenture Technology &middot; Software &amp; Platform Engineering &middot; High Velocity Modernization</p>
  <p>Generado desde <code>generators/build-mapa-capacidades.py</code></p>
</footer>
</div>

<script>
(function() {{
  var activeFilter = 'all';

  document.querySelectorAll('.l1-header').forEach(function(h) {{
    var c = document.createElement('span');
    c.className = 'chev'; c.textContent = '▼';
    h.appendChild(c);
    h.addEventListener('click', function() {{
      h.closest('.l1-section').classList.toggle('collapsed');
    }});
  }});

  function updateStat() {{
    var secs  = document.querySelectorAll('.l1-section:not(.hidden)').length;
    var cards = document.querySelectorAll('.cap-card:not(.hidden)').length;
    document.getElementById('stat').textContent = secs + ' secciones · ' + cards + ' capacidades';
  }}

  function setFilter(f) {{
    activeFilter = f;
    ['all','rtl','fsv','gap'].forEach(function(k) {{
      document.getElementById('f-'+k).className = 'pill' + (k===f ? ' a-'+k : '');
    }});
    document.querySelectorAll('.l1-section').forEach(function(s) {{
      if (f === 'all') {{ s.classList.remove('hidden'); return; }}
      if (f === 'gap') {{ s.classList.toggle('hidden', !s.classList.contains('is-gap')); return; }}
      s.classList.toggle('hidden', s.dataset.prefix.toLowerCase() !== f);
    }});
    var div = document.getElementById('fsv-divider');
    if (div) div.style.display = (f==='rtl') ? 'none' : '';
    document.querySelectorAll('.cap-card').forEach(function(c) {{ c.classList.remove('hidden'); }});
    updateStat();
  }}
  window.setFilter = setFilter;

  document.getElementById('q').addEventListener('input', function() {{
    var q = this.value.trim().toLowerCase();
    if (!q) {{
      document.querySelectorAll('.cap-card').forEach(function(c) {{ c.classList.remove('hidden','hit'); }});
      document.querySelectorAll('.l1-section').forEach(function(s) {{ s.classList.remove('hidden'); }});
      setFilter(activeFilter);
      return;
    }}
    document.querySelectorAll('.l1-section').forEach(function(s) {{ s.classList.remove('hidden'); }});
    document.getElementById('fsv-divider').style.display = '';
    document.querySelectorAll('.l1-section').forEach(function(sec) {{
      var hit = 0;
      sec.querySelectorAll('.cap-card').forEach(function(card) {{
        var nm = card.querySelector('.cap-name').textContent.toLowerCase();
        if (nm.includes(q)) {{
          card.classList.remove('hidden'); card.classList.add('hit'); hit++;
        }} else {{
          card.classList.add('hidden'); card.classList.remove('hit');
        }}
      }});
      sec.classList.toggle('hidden', hit === 0);
      if (hit > 0) sec.classList.remove('collapsed');
    }});
    updateStat();
  }});

  updateStat();
}})();
</script>
</body></html>"""


def main():
    missing = [p for p in [RTL_PATH, FSV_PATH] if not p.exists()]
    if missing:
        print("ERROR: archivo(s) no encontrado(s):", ", ".join(p.name for p in missing))
        return

    with open(RTL_PATH, encoding="utf-8-sig") as f:
        rtl_caps = json.loads(f.read(), strict=False)["capabilities"]
    with open(FSV_PATH, encoding="utf-8-sig") as f:
        fsv_caps = json.loads(f.read(), strict=False)["capabilities"]

    today = str(date.today())
    html  = render(rtl_caps, fsv_caps, today)

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(html, encoding="utf-8")

    print(f"Mapa generado: {OUT_PATH}")
    print(f"  RTL: {len(rtl_caps)} capacidades en 9 grupos L1")
    print(f"  FSV: {len(fsv_caps)} capacidades en 6 grupos L1")
    print(f"  Total: {len(rtl_caps) + len(fsv_caps)}")
    print()
    print("Servidor (desde carpeta Liverpool/):")
    print("  python -m http.server 8001")
    print("URL:")
    print("  http://localhost:8001/liverpool-brain/portal/mapa-capacidades.html")


if __name__ == "__main__":
    main()
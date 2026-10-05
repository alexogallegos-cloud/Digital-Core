"""build-onboarding-map.py — genera portal/onboarding-map.html desde brain.db.

Uso:
    python generators/build-onboarding-map.py
    URL: http://localhost:8000/projects/unity/portal/onboarding-map.html
"""

import sqlite3, json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DB   = ROOT / "projects/unity/digital-brain/brain.db"
OUT  = ROOT / "projects/unity/portal/onboarding-map.html"

SEV_COLOR  = {"critico": "#E05252", "alto": "#D4813A", "medio": "#C9A227"}
SEV_BG     = {"critico": "rgba(224,82,82,.15)", "alto": "rgba(212,129,58,.15)", "medio": "rgba(201,162,39,.12)"}
GATE_COLOR = {"sit": "#8B5CF6", "ff-escala": "#3B82F6",
              "mercado-abierto": "#10B981", "go-live": "#E05252"}
GATE_LABEL = {"sit": "SIT", "ff-escala": "F&F Escala",
              "mercado-abierto": "Mercado Abierto", "go-live": "Go-Live"}

# 16 secciones del flujo Apolo (num, nombre corto, steps)
ALL_SECTIONS = [
    ("01", "Preparación",          "Steps 1, 1A, 2"),
    ("02", "T&C y Aviso",          "Step 3"),
    ("03", "OTP / Teléfono",       "Steps 3A-3B"),
    ("04", "INE / RENAPO",         "Steps 3D, 5A-7A"),
    ("05", "Correo",               "Steps 4-5"),
    ("06", "Perfilamiento",        "Steps 8, 10"),
    ("07", "Domicilio",            "Steps 12-17A"),
    ("08", "PEP / KYC",            "Step 17C"),
    ("09", "PLD",                  "Steps 17D-17F"),
    ("10", "SICs / Buró",          "Steps 18-23"),
    ("11", "Paramétrico",          "Steps 24-31"),
    ("12", "Oferta Producto",      "Steps 32-34"),
    ("13", "Video Selfie",         "Step 37"),
    ("14", "Servicios Digitales",  "Steps 39-40"),
    ("15", "Expediente / Alta SV", "Steps 41-45"),
    ("16", "Bienvenida",           "Steps 46-47"),
]

# Secciones que aparecen en la matriz (tienen hallazgos)
MATRIX_SECTIONS = [
    ("00", "Transversal\n(todo el flujo)"),
    ("03", "Sección 03\nOTP / Teléfono"),
    ("04", "Sección 04\nINE / RENAPO"),
    ("10", "Sección 10\nSICs / Buró"),
    ("15", "Sección 15\nExpediente / Alta SV"),
]

SYSTEMS_ORDER = [
    ("apolo",      "Apolo"),
    ("ofi",        "OFI Tradicional"),
    ("yuga",       "YUGA"),
    ("informix",   "Informix"),
    ("smartvista", "SmartVista"),
    ("otp",        "OTP"),
    ("renapo",     "RENAPO"),
    ("ine",        "INE"),
    ("buro",       "Buró / SICs"),
    ("morpho",     "Morpho"),
    ("os-digital", "OS Digital"),
]

AGENT_NAMES = {
    "DT-ONB-01": "Canal OFI — Fricción y Obsolescencia",
    "DT-ONB-02": "Canal Apolo — Arquitectura del Flujo",
    "DT-ONB-03": "Integraciones Críticas",
    "DT-ONB-04": "Brechas Regulatorias y KYC",
    "DT-ONB-05": "Calidad y Testing",
}


def sev_rank(s):
    return {"critico": 0, "alto": 1, "medio": 2}.get(s or "medio", 3)


def load(db):
    con = sqlite3.connect(db)
    con.row_factory = sqlite3.Row
    findings = [dict(r) for r in con.execute(
        "SELECT * FROM onboarding_finding_map ORDER BY dt_agent, id")]
    hyps = [dict(r) for r in con.execute(
        "SELECT * FROM onboarding_hypotheses ORDER BY id")]
    desc_map = {}
    for r in con.execute("SELECT id, description FROM audit_findings"):
        desc_map[r["id"]] = r["description"]
    for r in con.execute("SELECT raid_id, description FROM risks"):
        desc_map[r["raid_id"]] = r["description"]
    con.close()
    return findings, hyps, desc_map


def build_matrix(findings):
    sec_nums = [s[0] for s in MATRIX_SECTIONS]
    matrix = {s[0]: {sec: [] for sec in sec_nums} for s in SYSTEMS_ORDER}
    for f in findings:
        sys_id = (f.get("system_primary") or "").lower()
        sec    = f.get("flow_section_num") or "00"
        if sec not in sec_nums:
            sec = "00"
        if sys_id in matrix:
            matrix[sys_id][sec].append(f)
        else:
            try:
                involved = json.loads(f.get("systems_involved") or "[]")
            except Exception:
                involved = []
            placed = False
            for inv in involved:
                if inv.lower() in matrix:
                    matrix[inv.lower()][sec].append(f)
                    placed = True
            if not placed:
                matrix["apolo"][sec].append(f)
    return matrix


def cell_html(entries):
    if not entries:
        return '<td class="mc mc-empty"></td>'
    worst = min(entries, key=lambda e: sev_rank(e.get("severity")))
    sev   = worst.get("severity") or "medio"
    color = SEV_COLOR[sev]
    bg    = SEV_BG[sev]
    cnt   = len(entries)
    tip_lines = []
    for e in entries:
        tip_lines.append("{} · {} · {}".format(
            e["id"], e.get("finding_id", "?"),
            (e.get("current_state") or "")[:70]))
    tip = "&#10;".join(tip_lines)
    dots = "".join(
        '<span class="dot dot-{}"></span>'.format(e.get("severity", "medio"))
        for e in sorted(entries, key=lambda e: sev_rank(e.get("severity"))))
    count_badge = f'<div class="mc-count">{cnt} hallazgo{"s" if cnt>1 else ""}</div>'
    return (f'<td class="mc" style="background:{bg};border-left:4px solid {color}" '
            f'title="{tip}">'
            f'<div class="dot-row">{dots}</div>'
            f'{count_badge}</td>')


def render(findings, hyps, desc_map):
    matrix = build_matrix(findings)

    total    = len(findings)
    criticos = sum(1 for f in findings if f.get("severity") == "critico")
    altos    = sum(1 for f in findings if f.get("severity") == "alto")
    medios   = sum(1 for f in findings if f.get("severity") == "medio")
    by_gate  = {}
    for f in findings:
        g = f.get("blocker_for") or "sin-gate"
        by_gate[g] = by_gate.get(g, 0) + 1

    # ── sección data por número (para highlight en el flujo)
    sec_data = {}
    for f in findings:
        sec = f.get("flow_section_num") or "00"
        sec_data.setdefault(sec, []).append(f)

    # ── flujo Apolo: 16 secciones + transversal
    flow_items = []
    for num, name, steps in ALL_SECTIONS:
        items = sec_data.get(num, [])
        cnt   = len(items)
        worst = min(items, key=lambda e: sev_rank(e.get("severity"))) if items else None
        sev   = worst.get("severity") if worst else None
        # con findings: color de severidad suavizado; sin findings: gris neutro
        bg    = {"critico":"rgba(224,82,82,.22)","alto":"rgba(212,129,58,.22)","medio":"rgba(201,162,39,.18)"}.get(sev,"rgb(18,30,68)") if sev else "rgb(18,30,68)"
        text_color = "#F4F6FF" if cnt else "#818ab0"
        tip   = "&#10;".join("{} ({}) — {}".format(
            e["id"], e.get("severity","?").upper(),
            (e.get("current_state") or "")[:60]) for e in items) or "Sin hallazgos en esta sección"
        badge = ('<span class="flow-badge" style="background:{}">{}</span>'.format(
            SEV_COLOR.get(sev,"#A0AEC0"), cnt) if cnt else "")
        flow_items.append(
            '<div class="flow-node" style="background:{bg};color:{tc}" title="{tip}">'
            '<div class="flow-num" style="color:{mc}">§{num}</div>'
            '<div class="flow-name">{name}</div>'
            '<div class="flow-steps" style="color:{mc}">{steps}</div>'
            '{badge}'
            '</div>'.format(
                bg=bg, tc=text_color,
                mc="#aab3d4" if not cnt else "#F4F6FF",
                tip=tip, num=num, name=name, steps=steps, badge=badge))

    # transversal (sec 00) — rectángulo punteado a la izquierda
    t_items = sec_data.get("00", [])
    t_cnt   = len(t_items)
    t_worst = min(t_items, key=lambda e: sev_rank(e.get("severity"))) if t_items else None
    t_sev   = t_worst.get("severity") if t_worst else None
    t_bg    = {"critico":"rgba(224,82,82,.22)","alto":"rgba(212,129,58,.22)","medio":"rgba(201,162,39,.18)"}.get(t_sev,"rgba(255,255,255,.04)") if t_sev else "rgba(255,255,255,.04)"
    t_tip   = "&#10;".join("{} ({}) — {}".format(
        e["id"], e.get("severity","?").upper(),
        (e.get("current_state") or "")[:60]) for e in t_items) or "Sin hallazgos transversales"
    t_badge = ('<span class="flow-badge" style="background:{};right:8px">{}</span>'.format(
        SEV_COLOR.get(t_sev,"#A0AEC0"), t_cnt) if t_cnt else "")
    transversal_node = (
        '<div class="flow-node flow-node-transversal" '
        'style="background:{}" title="{}">'
        '<div class="flow-num" style="color:#aab3d4">§00</div>'
        '<div class="flow-name" style="color:#F4F6FF">Transversal</div>'
        '<div class="flow-steps" style="color:#818ab0">Todo el flujo</div>'
        '{}'
        '</div>'.format(t_bg, t_tip, t_badge))

    flow_html = "".join(flow_items)

    # ── matrix
    sec_headers = "".join(
        '<th class="sec-th"><span class="sec-num-th">§{}</span><span class="sec-name-th">{}</span></th>'.format(
            s[0], s[1].replace("\n", "<br>"))
        for s in MATRIX_SECTIONS)

    matrix_rows = []
    for sys_id, sys_label in SYSTEMS_ORDER:
        cells = "".join(cell_html(matrix[sys_id][s[0]]) for s in MATRIX_SECTIONS)
        matrix_rows.append(f'<tr><th class="sys-label">{sys_label}</th>{cells}</tr>')
    matrix_html = "\n".join(matrix_rows)

    # ── gate summary
    gate_order = ["sit", "ff-escala", "mercado-abierto", "go-live"]
    gate_badges = "".join(
        '<div class="gate-stat" style="border-color:{c}">'
        '<span class="gate-stat-n" style="color:{c}">{n}</span>'
        '<span class="gate-stat-label">{l}</span>'
        '</div>'.format(c=GATE_COLOR[g], n=by_gate.get(g, 0), l=GATE_LABEL[g])
        for g in gate_order)

    # ── cards por agente
    agents = {}
    for f in findings:
        agents.setdefault(f.get("dt_agent", "?"), []).append(f)

    cards_parts = []
    for ag_id in sorted(agents):
        cards = []
        for f in sorted(agents[ag_id], key=lambda x: sev_rank(x.get("severity"))):
            sev   = f.get("severity") or "medio"
            gate  = f.get("blocker_for") or ""
            gc    = GATE_COLOR.get(gate, "#718096")
            gl    = GATE_LABEL.get(gate, gate)
            fid   = f.get("finding_id") or ""
            sec_n = f.get("flow_section_num") or "00"
            sec_nm = next((s[1] for s in ALL_SECTIONS if s[0] == sec_n), "Transversal")
            steps = f.get("flow_step_range") or ""
            state = f.get("current_state") or ""
            try:
                sys_list = json.loads(f.get("systems_involved") or "[]")
            except Exception:
                sys_list = [f.get("system_primary") or ""]
            sys_pills = "".join('<span class="sys-pill">{}</span>'.format(s) for s in sys_list)
            hyp_ref  = f.get("hypothesis_ref") or ""
            hyp_pills = "".join(
                '<span class="hyp-pill">{}</span>'.format(h.strip())
                for h in hyp_ref.split(",") if h.strip()) if hyp_ref else ""

            cards.append(
                '<div class="card card-{sev}">'
                '<div class="card-header">'
                '<span class="card-id">{id}</span>'
                '<span class="sev-badge sev-{sev}">{sev_u}</span>'
                '<span class="gate-badge" style="background:{gc}">{gl}</span>'
                '</div>'
                '<div class="card-finding-id">{fid}</div>'
                '<div class="card-section">§{sec_n} {sec_nm}{step_part}</div>'
                '<div class="card-state">{state}</div>'
                '<div class="card-systems">{sys_pills}</div>'
                '{hyp_part}'
                '</div>'.format(
                    sev=sev, id=f["id"], sev_u=sev.upper(),
                    gc=gc, gl=gl, fid=fid,
                    sec_n=sec_n, sec_nm=sec_nm,
                    step_part=(" · " + steps) if steps else "",
                    state=state, sys_pills=sys_pills,
                    hyp_part=('<div class="card-hyps">' + hyp_pills + '</div>') if hyp_pills else ""))

        cards_parts.append(
            '<div class="agent-group">'
            '<h3 class="agent-title">'
            '<span class="agent-id">{}</span> {}</h3>'
            '<div class="cards-grid">{}</div>'
            '</div>'.format(ag_id, AGENT_NAMES.get(ag_id, ag_id), "".join(cards)))

    cards_html = "\n".join(cards_parts)

    # ── hypotheses
    hyp_rows = "".join(
        '<tr><td class="hyp-id">{}</td><td class="hyp-title">{}</td></tr>'.format(
            h["id"], h["title"])
        for h in hyps)

    # ── leyenda
    legend_html = "".join(
        '<span class="legend-item">'
        '<span class="dot dot-{s}" style="width:12px;height:12px;display:inline-block;border-radius:50%;margin-right:4px"></span>'
        '{l}</span>'.format(s=s, l=l)
        for s, l in [("critico","Crítico"),("alto","Alto"),("medio","Medio")])

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Onboarding Map — BanCoppel Unity TDC</title>
<style>
/* BASE */
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{
  --blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
  --critico:#E05252;--alto:#D4813A;--medio:#C9A227;
  --sit:#8B5CF6;--ff:#3B82F6;--mab:#10B981;--golive:#E05252;
}}
html{{scroll-behavior:smooth}}
body{{background:#060a1a;color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;min-height:100vh}}

/* AURORA */
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
.aurora::before{{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(27,63,208,.55),transparent 70%);
  animation:f1 24s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:50vw;height:50vw;right:-10vw;top:10vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(13,33,133,.65),transparent 70%);
  animation:f2 28s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.12)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.10)}}}}

/* GRAIN */
.grain{{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}

/* PROGRESS BAR */
#prog{{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;
  background:linear-gradient(90deg,var(--yellow),#fff);
  box-shadow:0 0 12px rgba(240,210,36,.6)}}

/* NAV */
nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;
  gap:0;padding:0 28px;height:52px;
  backdrop-filter:blur(20px) saturate(160%);-webkit-backdrop-filter:blur(20px) saturate(160%);
  background:rgba(6,10,26,.72);border-bottom:1px solid rgba(255,255,255,.08)}}
.nav-logo-wrap{{display:flex;align-items:center;gap:10px;padding-right:20px;
  border-right:1px solid rgba(255,255,255,.1);margin-right:16px}}
nav img.nav-logo{{height:30px;filter:brightness(1.1) drop-shadow(0 0 8px rgba(240,210,36,.25))}}
.nav-wordmark{{font-size:15px;font-weight:800;letter-spacing:-.02em;color:#fff;display:none}}
nav .nt{{font-size:12px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
nav .sp{{flex:1}}
nav a{{font-size:12px;color:var(--muted);padding:6px 14px;border-radius:20px;
  transition:.2s;text-decoration:none;border:1px solid transparent}}
nav a:hover{{color:var(--ink);background:rgba(255,255,255,.08)}}
nav a.hl{{color:var(--yellow);border-color:rgba(240,210,36,.3)}}

/* WRAP & HERO */
.wrap{{max-width:1280px;margin:0 auto;padding:0 32px}}
.hero{{padding:96px 0 36px}}
.eyebrow{{display:inline-flex;align-items:center;gap:8px;padding:6px 14px;
  border-radius:30px;font-size:11px;font-weight:700;letter-spacing:.06em;
  color:#dfe6ff;margin-bottom:20px;background:rgba(255,255,255,.05);
  border:1px solid rgba(255,255,255,.12);backdrop-filter:blur(10px)}}
.eyebrow .edot{{width:7px;height:7px;border-radius:50%;background:var(--yellow);
  box-shadow:0 0 10px var(--yellow);animation:pulse 2.4s infinite;display:inline-block}}
@keyframes pulse{{50%{{opacity:.3}}}}
h1{{font-size:clamp(32px,4.5vw,58px);font-weight:800;line-height:1.05;letter-spacing:-.03em;
  background:linear-gradient(160deg,#fff 25%,#8ba4ff 75%);
  -webkit-background-clip:text;background-clip:text;color:transparent}}
.hero-rule{{width:48px;height:3px;background:var(--yellow);border-radius:2px;margin:16px 0 14px}}
.sub{{font-size:15px;color:var(--muted);max-width:68ch;line-height:1.65}}
.sub b{{color:#e4eaff;font-weight:600}}
.stats{{display:flex;gap:14px;margin-top:28px;flex-wrap:wrap}}
.stat{{padding:16px 22px;border-radius:16px;background:var(--glass);border:1px solid var(--glassb);
  backdrop-filter:blur(16px);display:flex;flex-direction:column;gap:5px;min-width:130px;
  transition:border-color .2s,transform .2s}}
.stat:hover{{border-color:rgba(255,255,255,.2);transform:translateY(-2px)}}
.stn{{font-size:24px;font-weight:800;letter-spacing:-.025em;
  background:linear-gradient(180deg,#fff 20%,#b0c4ff);
  -webkit-background-clip:text;background-clip:text;color:transparent}}
.stl{{font-size:10px;font-weight:600;letter-spacing:.09em;text-transform:uppercase;color:var(--muted2)}}
.stat.warn{{border-color:rgba(240,210,36,.4);background:rgba(240,210,36,.07)}}
.stat.warn .stn{{background:linear-gradient(180deg,var(--yellow),#d4a800);
  -webkit-background-clip:text;background-clip:text}}

/* SECTIONS */
.sec-wrap{{padding:28px 0}}
.sec-hdr{{font-size:11px;font-weight:800;color:var(--yellow);text-transform:uppercase;
  letter-spacing:.1em;margin-bottom:16px;padding-bottom:8px;
  border-bottom:1px solid rgba(255,255,255,.08);
  display:flex;align-items:center;gap:12px}}
.sec-hdr small{{font-size:10px;font-weight:400;color:var(--muted);
  text-transform:none;letter-spacing:0}}

/* GATE CARDS */
.gate-row{{display:flex;gap:14px;flex-wrap:wrap}}
.gate-stat{{border:1px solid;border-radius:16px;padding:16px 22px;
  text-align:center;background:var(--glass);backdrop-filter:blur(16px);min-width:120px;
  transition:transform .2s,border-color .2s}}
.gate-stat:hover{{transform:translateY(-2px)}}
.gate-stat-n{{font-size:28px;font-weight:800;display:block;letter-spacing:-.02em}}
.gate-stat-label{{font-size:10px;font-weight:700;text-transform:uppercase;
  letter-spacing:.08em;color:var(--muted2);margin-top:3px;display:block}}

/* FLUJO — CHEVRONES */
.flow-label{{font-size:11px;color:var(--muted);margin-bottom:10px}}
.flow-container{{overflow-x:auto;padding-bottom:12px}}
.flow-container::-webkit-scrollbar{{height:4px}}
.flow-container::-webkit-scrollbar-track{{background:rgba(255,255,255,.04);border-radius:2px}}
.flow-container::-webkit-scrollbar-thumb{{background:rgba(255,255,255,.15);border-radius:2px}}
.flow-pipeline{{display:flex;align-items:center;gap:0;min-width:max-content;padding:4px 4px 4px 0}}
.flow-node{{
  position:relative;width:114px;height:72px;flex-shrink:0;
  clip-path:polygon(0% 0%,calc(100% - 18px) 0%,100% 50%,calc(100% - 18px) 100%,0% 100%,18px 50%);
  background:rgb(18,30,68);
  padding:0 22px 0 32px;
  display:flex;flex-direction:column;justify-content:center;
  cursor:default;transition:filter .15s;margin-right:-16px;z-index:1}}
.flow-node:first-child{{
  clip-path:polygon(0% 0%,calc(100% - 18px) 0%,100% 50%,calc(100% - 18px) 100%,0% 100%);
  padding-left:14px;border-radius:4px 0 0 4px}}
.flow-node:hover{{filter:brightness(1.35);z-index:20}}
.flow-num{{font-size:9px;font-weight:800;line-height:1;margin-bottom:3px}}
.flow-name{{font-size:11px;font-weight:700;line-height:1.25;margin-bottom:3px}}
.flow-steps{{font-size:9px;line-height:1.2}}
.flow-badge{{position:absolute;top:8px;right:22px;border-radius:50%;
  width:20px;height:20px;display:flex;align-items:center;justify-content:center;
  font-size:10px;font-weight:800;color:#fff;box-shadow:0 1px 4px rgba(0,0,0,.4)}}
.flow-node-transversal{{
  clip-path:none !important;padding:0 14px;
  border:1px dashed rgba(255,255,255,.2) !important;border-radius:8px;
  background:rgba(255,255,255,.04) !important;width:104px;z-index:25}}
.transversal-sep{{font-size:14px;color:rgba(255,255,255,.25);
  padding:0 4px;flex-shrink:0;font-weight:700;z-index:26}}

/* MATRIX */
.matrix-intro{{font-size:11px;color:var(--muted);margin-bottom:12px}}
.matrix-wrap{{overflow-x:auto}}
.matrix-wrap::-webkit-scrollbar{{height:4px}}
.matrix-wrap::-webkit-scrollbar-track{{background:rgba(255,255,255,.04)}}
.matrix-wrap::-webkit-scrollbar-thumb{{background:rgba(255,255,255,.15)}}
table.matrix{{border-collapse:collapse;width:100%;
  background:rgba(255,255,255,.03);border-radius:12px;overflow:hidden}}
table.matrix th,table.matrix td{{border:1px solid rgba(255,255,255,.07)}}
.sys-label-hdr{{background:rgba(18,47,177,.6);color:#fff;padding:10px 14px;
  font-size:10px;font-weight:700;text-align:left;backdrop-filter:blur(8px)}}
.sec-th{{background:rgba(18,47,177,.5);color:#fff;padding:10px 8px;
  text-align:center;min-width:120px;backdrop-filter:blur(8px)}}
.sec-num-th{{display:block;font-size:9px;opacity:.6;margin-bottom:2px}}
.sec-name-th{{display:block;font-size:11px;font-weight:700;line-height:1.3}}
.sys-label{{background:rgba(255,255,255,.04);font-weight:700;font-size:11px;
  padding:9px 14px;white-space:nowrap;color:#90a8ff;min-width:130px}}
td.mc{{padding:8px 6px;text-align:center;vertical-align:middle;
  min-width:120px;min-height:56px;cursor:default;transition:filter .15s}}
td.mc:hover{{filter:brightness(1.4)}}
td.mc-empty{{background:rgba(255,255,255,.015)}}
.dot-row{{display:flex;gap:4px;justify-content:center;flex-wrap:wrap;margin-bottom:5px}}
.dot{{width:16px;height:16px;border-radius:50%;box-shadow:0 0 8px rgba(0,0,0,.4)}}
.dot-critico{{background:#E05252;box-shadow:0 0 10px rgba(224,82,82,.5)}}
.dot-alto{{background:#D4813A;box-shadow:0 0 8px rgba(212,129,58,.4)}}
.dot-medio{{background:#C9A227;box-shadow:0 0 8px rgba(201,162,39,.3)}}
.mc-count{{font-size:10px;font-weight:600;color:var(--muted)}}

/* LEGEND */
.legend{{display:flex;gap:16px;font-size:11px;color:var(--muted);margin-top:10px;flex-wrap:wrap}}
.legend-item{{display:flex;align-items:center;gap:5px}}

/* AGENT GROUPS */
.agent-group{{margin-bottom:32px}}
.agent-title{{font-size:14px;font-weight:700;color:var(--ink);
  margin-bottom:12px;display:flex;align-items:center;gap:10px}}
.agent-id{{background:rgba(61,95,205,.5);border:1px solid rgba(61,95,205,.8);
  color:#c0d0ff;border-radius:6px;padding:3px 10px;font-size:11px;font-weight:800}}
.cards-grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:12px}}
.card{{background:var(--glass);border:1px solid var(--glassb);
  border-radius:14px;padding:14px 16px;border-top:3px solid transparent;
  backdrop-filter:blur(12px);transition:border-color .2s,transform .2s}}
.card:hover{{transform:translateY(-2px)}}
.card-critico{{border-top-color:#E05252}}
.card-alto{{border-top-color:#D4813A}}
.card-medio{{border-top-color:#C9A227}}
.card-header{{display:flex;align-items:center;gap:6px;margin-bottom:6px}}
.card-id{{font-weight:800;font-size:12px;
  background:linear-gradient(90deg,#fff,#90a8ff);
  -webkit-background-clip:text;background-clip:text;color:transparent}}
.sev-badge{{border-radius:10px;padding:1px 8px;font-size:10px;font-weight:700;color:#fff}}
.sev-critico{{background:#C53030}}
.sev-alto{{background:#C05621}}
.sev-medio{{background:#B7791F}}
.gate-badge{{border-radius:10px;padding:1px 8px;font-size:10px;font-weight:700;
  color:#fff;margin-left:auto}}
.card-finding-id{{font-size:10px;font-weight:700;color:var(--muted);margin-bottom:3px}}
.card-section{{font-size:11px;color:#90a8ff;font-weight:600;margin-bottom:5px}}
.card-state{{font-size:11px;color:var(--muted);margin-bottom:8px;line-height:1.4}}
.card-systems{{display:flex;flex-wrap:wrap;gap:4px}}
.sys-pill{{background:rgba(61,95,205,.25);border:1px solid rgba(61,95,205,.4);
  color:#90b8ff;border-radius:10px;padding:1px 8px;font-size:10px;font-weight:600}}
.card-hyps{{margin-top:5px;display:flex;flex-wrap:wrap;gap:4px}}
.hyp-pill{{background:rgba(139,92,246,.2);border:1px solid rgba(139,92,246,.35);
  color:#c4b5fd;border-radius:10px;padding:1px 8px;font-size:10px;font-weight:600}}

/* HYPOTHESES */
.hyp-table{{width:100%;border-collapse:collapse;background:rgba(255,255,255,.03);
  border-radius:12px;overflow:hidden}}
.hyp-table tr{{border-bottom:1px solid rgba(255,255,255,.07)}}
.hyp-table tr:last-child{{border-bottom:none}}
.hyp-id{{width:52px;padding:10px 14px;font-weight:800;font-size:13px;
  color:var(--yellow);background:rgba(240,210,36,.07);text-align:center}}
.hyp-title{{padding:10px 14px;font-size:12px;color:var(--ink)}}

/* ROADMAP */
.roadmap-timeline{{display:flex;align-items:center;gap:0;margin-bottom:28px;overflow-x:auto;padding:4px 0}}
.rtl-node{{text-align:center;padding:0 12px}}
.rtl-dot{{width:14px;height:14px;border-radius:50%;margin:0 auto 8px;border:2px solid}}
.rtl-weeks{{font-size:10px;font-weight:800;color:var(--ink);display:block;margin-bottom:2px}}
.rtl-label{{font-size:9px;color:var(--muted2);text-transform:uppercase;letter-spacing:.06em}}
.rtl-line{{flex:1;height:1px;background:rgba(255,255,255,.12);min-width:32px}}
.roadmap-grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:16px}}
.ola{{background:var(--glass);border:1px solid var(--glassb);border-radius:16px;
      padding:22px 24px;backdrop-filter:blur(12px);border-top:4px solid transparent;
      transition:transform .2s,border-color .2s}}
.ola:hover{{transform:translateY(-3px)}}
.ola-0{{border-top-color:#E05252}}
.ola-1{{border-top-color:#D4813A}}
.ola-2{{border-top-color:#3B82F6}}
.ola-3{{border-top-color:#10B981}}
.ola-label{{font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.12em;
  color:var(--muted2);margin-bottom:6px}}
.ola-title{{font-size:17px;font-weight:800;color:var(--ink);line-height:1.2;margin-bottom:4px}}
.ola-timeframe{{font-size:11px;color:var(--muted);margin-bottom:10px}}
.ola-gate{{display:inline-flex;align-items:center;gap:5px;border-radius:10px;
  padding:3px 10px;font-size:10px;font-weight:700;color:#fff;margin-bottom:14px;
  border:1px solid rgba(255,255,255,.15)}}
.ola-hits{{list-style:none;padding:0;margin-bottom:16px}}
.ola-hits li{{font-size:12px;color:var(--muted);padding:7px 0;
  border-bottom:1px solid rgba(255,255,255,.06);
  display:flex;align-items:flex-start;gap:8px;line-height:1.45}}
.ola-hits li:last-child{{border-bottom:none}}
.ola-hits li b{{color:var(--ink);font-weight:600}}
.hit-bullet{{width:7px;height:7px;border-radius:50%;flex-shrink:0;margin-top:4px}}
.hit-hyp{{font-size:10px;background:rgba(139,92,246,.18);border:1px solid rgba(139,92,246,.3);
  color:#c4b5fd;border-radius:8px;padding:0 6px;margin-left:auto;flex-shrink:0;white-space:nowrap}}
.ola-kpis{{display:flex;gap:10px;flex-wrap:wrap;margin-top:2px;padding-top:14px;
  border-top:1px solid rgba(255,255,255,.07)}}
.ola-kpi{{text-align:center;background:rgba(255,255,255,.04);border-radius:10px;
  padding:9px 12px;flex:1;min-width:80px}}
.ola-kpi-n{{font-size:20px;font-weight:800;display:block;letter-spacing:-.02em;
  background:linear-gradient(180deg,#fff,#90a8ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.ola-0 .ola-kpi-n{{background:linear-gradient(180deg,#FC8181,#E05252);-webkit-background-clip:text;background-clip:text}}
.ola-3 .ola-kpi-n{{background:linear-gradient(180deg,#6EE7B7,#10B981);-webkit-background-clip:text;background-clip:text}}
.ola-kpi-l{{font-size:9px;color:var(--muted2);text-transform:uppercase;letter-spacing:.07em;margin-top:3px;display:block}}
.impact-table{{width:100%;border-collapse:collapse;background:rgba(255,255,255,.03);
  border-radius:12px;overflow:hidden;margin-top:24px}}
.impact-table th{{background:rgba(18,47,177,.5);color:#fff;padding:10px 14px;
  font-size:11px;font-weight:700;text-align:left}}
.impact-table th:not(:first-child){{text-align:center}}
.impact-table td{{padding:10px 14px;font-size:12px;color:var(--muted);
  border-bottom:1px solid rgba(255,255,255,.06)}}
.impact-table tr:last-child td{{border-bottom:none}}
.impact-table td:first-child{{color:#90a8ff;font-weight:700}}
.impact-table td:not(:first-child){{text-align:center}}
.impact-hoy{{color:#E05252 !important;font-weight:700}}
.impact-ola3{{color:#10B981 !important;font-weight:700}}
.impact-mid{{color:#F4F6FF !important}}
.impact-new{{color:#8B5CF6 !important;font-style:italic}}

/* FOOTER */
footer{{padding:20px 32px;color:var(--muted);font-size:11px;
  border-top:1px solid rgba(255,255,255,.06);margin-top:16px;text-align:center}}
footer code{{font-family:ui-monospace,'SF Mono',monospace;
  background:rgba(255,255,255,.07);border-radius:4px;padding:1px 6px;font-size:10px}}
</style>
</head>
<body>

<div class="aurora"></div>
<div class="grain"></div>
<div id="prog"></div>

<nav>
  <div class="nav-logo-wrap">
    <img class="nav-logo"
         src="../../../design-studio/logos/BanCoppel_logo.svg"
         alt="BanCoppel"
         onerror="this.src='../../../design-studio/logos/BanCoppel_logo.png';this.onerror=function(){{this.style.display='none';document.querySelector('.nav-wordmark').style.display='block'}}">
    <span class="nav-wordmark">BanCoppel</span>
  </div>
  <span class="nt">Unity TDC · Onboarding Map</span>
  <span class="sp"></span>
  <a class="hl" href="index.html">← Plan Director</a>
</nav>

<div class="wrap">
  <div class="hero">
    <div class="eyebrow"><span class="edot"></span> Swarm DT-ONB · v2.0.0 · 2026-09-03</div>
    <h1>Hallazgos × Pasos<br>Apolo × Sistemas</h1>
    <div class="hero-rule"></div>
    <p class="sub">Mapa de los <b>20 hallazgos</b> del Plan Director Aceleración Onboarding (ago-2026)
      contra las 16 secciones del flujo Apolo y los sistemas involucrados.</p>
    <div class="stats">
      <div class="stat warn"><div class="stn">{criticos}</div><div class="stl">Críticos</div></div>
      <div class="stat"><div class="stn">{altos}</div><div class="stl">Altos</div></div>
      <div class="stat"><div class="stn">{medios}</div><div class="stl">Medios</div></div>
      <div class="stat"><div class="stn">{total}</div><div class="stl">Hallazgos totales</div></div>
    </div>
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Bloqueantes por Gate <small>— ¿qué impide pasar al siguiente hito?</small></div>
    <div class="gate-row">{gate_badges}</div>
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Flujo Onboarding Apolo <small>— 16 secciones · los nodos con número tienen hallazgos activos (hover para ver cuáles)</small></div>
    <div class="flow-label">Secciones del proceso de onboarding TDC en canal digital (AppWhere)</div>
    <div class="flow-container">
      <div class="flow-pipeline">
        <div class="transversal-sep" title="Hallazgos que afectan todo el flujo, no una sección específica">
          {transversal_node}
        </div>
        <div class="transversal-sep">+</div>
        {flow_html}
      </div>
    </div>
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Matriz: Sistema × Sección del Flujo <small>— cada celda = hallazgos en ese cruce · hover para detalles</small></div>
    <p class="matrix-intro">
      Filas = sistemas involucrados · Columnas = secciones del flujo Apolo con hallazgos activos ·
      Color del borde izquierdo = severidad más alta en esa celda
    </p>
    <div class="matrix-wrap">
      <table class="matrix">
        <thead>
          <tr>
            <th class="sys-label-hdr">Sistema</th>
            {sec_headers}
          </tr>
        </thead>
        <tbody>{matrix_html}</tbody>
      </table>
    </div>
    <div class="legend">
      {legend_html}
      <span style="color:var(--muted);font-size:11px">· Hover sobre cualquier celda para ver los IDs y descripción del hallazgo</span>
    </div>
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Hallazgos por Agente DT <small>— ordenados de mayor a menor severidad</small></div>
    {cards_html}
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Hipótesis de Trabajo <small>— Plan Director Aceleración Onboarding, agosto 2026</small></div>
    <table class="hyp-table">{hyp_rows}</table>
  </div>

  <div class="sec-wrap">
    <div class="sec-hdr">Hoja de Ruta — Quick Hits de Originación
      <small>— olas de valor para reducir el tiempo de alta y flexibilizar el proceso</small>
    </div>

    <!-- Timeline visual -->
    <div class="roadmap-timeline">
      <div class="rtl-node">
        <div class="rtl-dot" style="border-color:#E05252;background:rgba(224,82,82,.25)"></div>
        <span class="rtl-weeks">0-2 sem</span>
        <span class="rtl-label">Ola 0 · Hotfix</span>
      </div>
      <div class="rtl-line"></div>
      <div class="rtl-node">
        <div class="rtl-dot" style="border-color:#D4813A;background:rgba(212,129,58,.25)"></div>
        <span class="rtl-weeks">2-6 sem</span>
        <span class="rtl-label">Ola 1 · Fluidez</span>
      </div>
      <div class="rtl-line"></div>
      <div class="rtl-node">
        <div class="rtl-dot" style="border-color:#3B82F6;background:rgba(59,130,246,.25)"></div>
        <span class="rtl-weeks">6-14 sem</span>
        <span class="rtl-label">Ola 2 · Velocidad</span>
      </div>
      <div class="rtl-line"></div>
      <div class="rtl-node">
        <div class="rtl-dot" style="border-color:#10B981;background:rgba(16,185,129,.25)"></div>
        <span class="rtl-weeks">14-26 sem</span>
        <span class="rtl-label">Ola 3 · Escala</span>
      </div>
    </div>

    <!-- Tarjetas de ola -->
    <div class="roadmap-grid">

      <!-- OLA 0 -->
      <div class="ola ola-0">
        <div class="ola-label">Ola 0</div>
        <div class="ola-title">Estabilización Crítica</div>
        <div class="ola-timeframe">0 – 2 semanas · prerequisito de calidad</div>
        <span class="ola-gate" style="background:#7C3AED">Libera → SIT</span>
        <ul class="ola-hits">
          <li>
            <span class="hit-bullet" style="background:#E05252"></span>
            <div><b>Desactivar 4 mocks activos</b> en QA: OTP, RENAPO, INE y fallback Buró para habilitar E2E real con proveedores. (ONB-009..011, ONB-018)</div>
            <span class="hit-hyp">H1</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#E05252"></span>
            <div><b>Reponer foliador OS</b> antes del límite de 10M folios para evitar pausa operativa no planeada. (ONB-013)</div>
            <span class="hit-hyp">H1</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#E05252"></span>
            <div><b>Idempotencia y compensación</b> en steps 42-43 (Alta SmartVista) para eliminar altas parciales sin rollback. (ONB-012, ONB-019)</div>
            <span class="hit-hyp">H2</span>
          </li>
        </ul>
        <div class="ola-kpis">
          <div class="ola-kpi"><span class="ola-kpi-n">3</span><span class="ola-kpi-l">Riesgos críticos cerrados</span></div>
          <div class="ola-kpi"><span class="ola-kpi-n">SIT</span><span class="ola-kpi-l">Gate desbloqueado</span></div>
        </div>
      </div>

      <!-- OLA 1 -->
      <div class="ola ola-1">
        <div class="ola-label">Ola 1</div>
        <div class="ola-title">Fluidez del Proceso</div>
        <div class="ola-timeframe">2 – 6 semanas · reduce fricción operativa</div>
        <span class="ola-gate" style="background:#2563EB">Libera → F&amp;F Escala</span>
        <ul class="ola-hits">
          <li>
            <span class="hit-bullet" style="background:#D4813A"></span>
            <div><b>Retoma de proceso</b> desde cualquier step ante caída. Elimina el reinicio completo actual (45 min → 33 min en OFI). (ONB-002)</div>
            <span class="hit-hyp">H2</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#D4813A"></span>
            <div><b>Alternativa biométrica</b> cuando Morpho falla (flujo de autorización gerente con ID). Sin bloqueo en sucursal. (ONB-003, ONB-016)</div>
            <span class="hit-hyp">H5</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#D4813A"></span>
            <div><b>Estabilizar integración Coppel-BanCoppel</b> post-hackeo para eliminar caídas recurrentes en OFI. (ONB-004)</div>
            <span class="hit-hyp">H1</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#D4813A"></span>
            <div><b>Reducir checkpoints</b> de 105 a &lt;60: consolidar retrieve/initiate duplicados y simplificar el árbol de estado. (ONB-007)</div>
            <span class="hit-hyp">H3</span>
          </li>
        </ul>
        <div class="ola-kpis">
          <div class="ola-kpi"><span class="ola-kpi-n">-12min</span><span class="ola-kpi-l">OFI: 45→33 min</span></div>
          <div class="ola-kpi"><span class="ola-kpi-n">-40%</span><span class="ola-kpi-l">Sesiones abandonadas</span></div>
        </div>
      </div>

      <!-- OLA 2 -->
      <div class="ola ola-2">
        <div class="ola-label">Ola 2</div>
        <div class="ola-title">Velocidad en Apolo</div>
        <div class="ola-timeframe">6 – 14 semanas · acelera el canal digital</div>
        <span class="ola-gate" style="background:#059669">Libera → Mercado Abierto</span>
        <ul class="ola-hits">
          <li>
            <span class="hit-bullet" style="background:#3B82F6"></span>
            <div><b>Latencia Apolo &lt;3 s/step</b>: caché de perfilamiento, conexión pool y queries optimizadas en YUGA/Informix. (ONB-006)</div>
            <span class="hit-hyp">H4</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#3B82F6"></span>
            <div><b>Validaciones no críticas a batch nocturno</b>: SICs no bloqueantes y scoring secundario fuera del flujo en línea. (ONB-017)</div>
            <span class="hit-hyp">H3</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#3B82F6"></span>
            <div><b>INE en canal DUD</b>: habilitar consulta INE en autosolicitudes digitales para cumplir KYC sin ejecutivo. (ONB-014, ONB-015)</div>
            <span class="hit-hyp">H1</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#3B82F6"></span>
            <div><b>Proceso ejecutivo documentado en tienda</b>: levantamiento de fricciones reales y rediseño de UX para el rol del ejecutivo en Apolo. (ONB-008)</div>
            <span class="hit-hyp">H5 · H6</span>
          </li>
        </ul>
        <div class="ola-kpis">
          <div class="ola-kpi"><span class="ola-kpi-n">-8min</span><span class="ola-kpi-l">Apolo: 20→12 min</span></div>
          <div class="ola-kpi"><span class="ola-kpi-n">+DUD</span><span class="ola-kpi-l">Canal digital activo</span></div>
        </div>
      </div>

      <!-- OLA 3 -->
      <div class="ola ola-3">
        <div class="ola-label">Ola 3</div>
        <div class="ola-title">Desacoplamiento del Legado</div>
        <div class="ola-timeframe">14 – 26 semanas · escala y autonomía digital</div>
        <span class="ola-gate" style="background:#C53030">Libera → Go-Live</span>
        <ul class="ola-hits">
          <li>
            <span class="hit-bullet" style="background:#10B981"></span>
            <div><b>Microservicios de perfilamiento</b> desacoplados de YUGA (46 steps) e Informix (27 steps). Elimina la dependencia de legado del 73% del flujo. (ONB-005)</div>
            <span class="hit-hyp">H7</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#10B981"></span>
            <div><b>Flujo ejecutivo &lt;15 min en Apolo</b>: combinación de latencia resuelta + validaciones batch + UX rediseñado para el ejecutivo. (ONB-006, ONB-007)</div>
            <span class="hit-hyp">H4 · H6</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#10B981"></span>
            <div><b>Canal DUD autónomo &lt;10 min</b>: onboarding digital completo sin ejecutivo, con INE + OTP + biométrico facial.</div>
            <span class="hit-hyp">H1 · H7</span>
          </li>
          <li>
            <span class="hit-bullet" style="background:#10B981"></span>
            <div><b>Roadmap de modernización OFI</b>: plan de migración de VB6+Win7 hacia AppWhere o equivalente como canal unificado. (ONB-001)</div>
            <span class="hit-hyp">H5</span>
          </li>
        </ul>
        <div class="ola-kpis">
          <div class="ola-kpi"><span class="ola-kpi-n">-30min</span><span class="ola-kpi-l">OFI: 45→15 min*</span></div>
          <div class="ola-kpi"><span class="ola-kpi-n">&lt;10min</span><span class="ola-kpi-l">DUD sin ejecutivo</span></div>
        </div>
      </div>

    </div><!-- /roadmap-grid -->

    <!-- Tabla de impacto acumulado -->
    <table class="impact-table">
      <thead>
        <tr>
          <th>Canal</th>
          <th>Hoy</th>
          <th>Post Ola 0-1</th>
          <th>Post Ola 2</th>
          <th>Post Ola 3</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>OFI Sucursal</td>
          <td class="impact-hoy">~45 min</td>
          <td class="impact-mid">~33 min</td>
          <td class="impact-mid">~25 min</td>
          <td class="impact-ola3">~15 min*</td>
        </tr>
        <tr>
          <td>Apolo (F&amp;F piloto)</td>
          <td class="impact-hoy">~20 min</td>
          <td class="impact-mid">~18 min</td>
          <td class="impact-mid">~12 min</td>
          <td class="impact-ola3">~10 min*</td>
        </tr>
        <tr>
          <td>DUD Digital</td>
          <td class="impact-hoy">No disponible (brecha KYC)</td>
          <td class="impact-mid">No disponible</td>
          <td class="impact-new">Habilitado (INE + OTP)</td>
          <td class="impact-ola3">&lt;10 min autónomo</td>
        </tr>
      </tbody>
    </table>
    <p style="font-size:10px;color:var(--muted2);margin-top:8px">
      * Proyección con desacoplamiento de YUGA/Informix completo (Ola 3).
      Tiempos OFI asumen modernización de plataforma VB6.
      Columnas Apolo asumen latencia resuelta a &lt;3 s/step.
    </p>

  </div><!-- /roadmap sec-wrap -->

</div>

<footer>
  Fuente: BanCoppel_Plan_Director_Aceleracion_Onboarding_ago-2026 ·
  Brain: <code>projects/unity/digital-brain/brain.db</code> (tabla onboarding_finding_map, 20 entradas) ·
  Generado por <code>generators/build-onboarding-map.py</code>
</footer>

<script>
window.addEventListener('scroll',()=>{{
  const p=document.getElementById('prog');
  if(p)p.style.width=(window.scrollY/(document.body.scrollHeight-window.innerHeight)*100)+'%';
}});
</script>

</body>
</html>"""


def main():
    print("build-onboarding-map.py ...")
    findings, hyps, desc_map = load(DB)
    print(f"  {len(findings)} hallazgos · {len(hyps)} hipótesis")
    html = render(findings, hyps, desc_map)
    OUT.write_text(html, encoding="utf-8")
    print(f"  → {OUT}")
    print("  URL: http://localhost:8000/projects/unity/portal/onboarding-map.html")


if __name__ == "__main__":
    main()
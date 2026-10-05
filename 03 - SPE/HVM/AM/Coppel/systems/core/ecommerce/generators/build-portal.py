"""
build-portal.py  --  Coppel Retail eCommerce Portal Generator v1.0.0
Genera portal/index.html a partir de brain.db.
NUNCA editar el HTML directamente — siempre regenerar con este script.

Uso:
    python generators/build-portal.py
"""

import sqlite3
import json
from pathlib import Path
from datetime import datetime

DB_PATH     = Path(__file__).parent.parent / "digital-brain" / "brain.db"
PORTAL_DIR  = Path(__file__).parent.parent / "portal"
OUTPUT_HTML = PORTAL_DIR / "index.html"

PORTAL_DIR.mkdir(parents=True, exist_ok=True)

# ── Paleta de marca Coppel (rojo-guinda + gris) ──────────────────────────────
# Coppel retail usa colores distintos a BanCoppel (azul/amarillo)
PALETTE = {
    "primary":    "#C8102E",   # rojo Coppel (retail)
    "primary_dk": "#8C0B1F",
    "accent":     "#F5A623",   # naranja/amber acento
    "bg":         "#F8F8F8",
    "card_bg":    "#FFFFFF",
    "text":       "#1A1A1A",
    "text_muted": "#666666",
    "border":     "#E0E0E0",
    "rag_green":  "#27AE60",
    "rag_yellow": "#F39C12",
    "rag_red":    "#E74C3C",
    "rag_grey":   "#95A5A6",
}

MIGRATION_BADGE = {
    "as-is":       ("AS-IS",       "#95A5A6"),
    "in-progress": ("MIGRANDO",    "#F39C12"),
    "done":        ("LISTO",       "#27AE60"),
    "blocked":     ("BLOQUEADO",   "#E74C3C"),
    "tbd":         ("POR DEFINIR", "#7F8C8D"),
}

COVERAGE_BADGE = {
    "native":      ("#27AE60", "Native"),
    "partial":     ("#F39C12", "Parcial"),
    "migrating":   ("#3498DB", "Migrando"),
    "not_covered": ("#E74C3C", "No cubierto"),
    "deprecated":  ("#95A5A6", "Deprecado"),
}

RISK_COLOR = {
    "critical": "#E74C3C",
    "high":     "#E67E22",
    "medium":   "#F39C12",
    "low":      "#27AE60",
}

CATEGORY_ICON = {
    "backend":        "⚙️",
    "frontend":       "🖥️",
    "database":       "🗄️",
    "infrastructure": "☁️",
    "integration":    "🔗",
    "observability":  "📊",
    "cdn":            "🌐",
    "search":         "🔍",
    "payments":       "💳",
    "itsm":           "🎫",
    "ai":             "🤖",
    "ecommerce":      "🛒",
}

DOMAIN_ICON = {
    "ecommerce":   "🛒",
    "omnichannel": "📱",
    "fulfillment": "📦",
    "payments":    "💳",
    "customer":    "👤",
    "platform":    "⚙️",
    "data":        "📊",
    "operations":  "🔧",
}


def load_brain(db_path: Path):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    info         = {r["key"]: r["value"] for r in con.execute("SELECT key,value FROM project_info").fetchall()}
    platforms    = [dict(r) for r in con.execute("SELECT * FROM platforms ORDER BY status,id").fetchall()]
    gcp_projects = [dict(r) for r in con.execute("SELECT * FROM gcp_projects ORDER BY id").fetchall()]
    stack        = [dict(r) for r in con.execute("SELECT * FROM technology_stack ORDER BY category,name").fetchall()]
    caps         = [dict(r) for r in con.execute(
        "SELECT * FROM platform_capabilities ORDER BY criticality,domain,name"
    ).fetchall()]
    risks        = [dict(r) for r in con.execute(
        "SELECT * FROM risks WHERE status='open' ORDER BY "
        "CASE impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END"
    ).fetchall()]
    slos         = [dict(r) for r in con.execute("SELECT * FROM slos").fetchall()]
    integrations = [dict(r) for r in con.execute(
        "SELECT * FROM integrations ORDER BY criticality,id"
    ).fetchall()]
    decisions    = [dict(r) for r in con.execute("SELECT * FROM decisions ORDER BY id").fetchall()]
    vocab        = [dict(r) for r in con.execute("SELECT * FROM vocabulary ORDER BY term").fetchall()]

    con.close()
    return info, platforms, gcp_projects, stack, caps, risks, slos, integrations, decisions, vocab


def kpi_cards(info, risks, slos):
    mttr_color   = PALETTE["rag_red"]   # siempre rojo hasta que mejore
    impact_mxn   = f"${int(info.get('business_impact_mxn_per_min','0')):,}"
    risk_count   = sum(1 for r in risks if r["status"] == "open")
    crit_risks   = sum(1 for r in risks if r["impact"] == "critical")
    breach_slos  = sum(1 for s in slos if s["status"] == "breaching")

    cards = [
        {
            "title": "MTTR Actual (P1)",
            "value": "20 días hábiles",
            "target": "SLA: 5 días hábiles",
            "color": mttr_color,
            "icon": "⏱️",
        },
        {
            "title": "Impacto por Minuto",
            "value": impact_mxn + " MXN",
            "target": "de indisponibilidad",
            "color": PALETTE["rag_red"],
            "icon": "💰",
        },
        {
            "title": "Riesgos Abiertos",
            "value": str(risk_count),
            "target": f"{crit_risks} críticos",
            "color": PALETTE["rag_red"] if crit_risks > 0 else PALETTE["rag_yellow"],
            "icon": "⚠️",
        },
        {
            "title": "SLOs en Breach",
            "value": str(breach_slos),
            "target": f"de {len(slos)} SLOs definidos",
            "color": PALETTE["rag_red"] if breach_slos > 0 else PALETTE["rag_green"],
            "icon": "🎯",
        },
        {
            "title": "Volumen Tickets N3",
            "value": "15 / mes",
            "target": "20-25 en temporada alta",
            "color": PALETTE["rag_yellow"],
            "icon": "🎫",
        },
        {
            "title": "Plataformas Activas",
            "value": "5 plataformas",
            "target": "HCL → Composable en curso",
            "color": PALETTE["rag_yellow"],
            "icon": "🛒",
        },
    ]
    return cards


def render_kpi_section(cards):
    items = ""
    for c in cards:
        items += f"""
        <div class="kpi-card" style="border-top:4px solid {c['color']}">
          <div class="kpi-icon">{c['icon']}</div>
          <div class="kpi-value" style="color:{c['color']}">{c['value']}</div>
          <div class="kpi-title">{c['title']}</div>
          <div class="kpi-target">{c['target']}</div>
        </div>"""
    return f'<div class="kpi-grid">{items}</div>'


def render_platform_cards(platforms):
    STATUS_COLOR = {
        "legacy":      ("#95A5A6", "Legado"),
        "active":      ("#27AE60", "Activo"),
        "migrating":   ("#F39C12", "Migrando"),
        "planned":     ("#3498DB", "Planeado"),
        "deprecated":  ("#E74C3C", "Deprecado"),
    }
    cards = ""
    for p in platforms:
        color, label = STATUS_COLOR.get(p["status"], ("#95A5A6", p["status"]))
        svc = f"~{p['service_count']} servicios" if p.get("service_count") else ""
        gcp = f'<span class="tag">{p["gcp_project"]}</span>' if p.get("gcp_project") else ""
        notes_html = f'<p class="card-notes">{p["notes"]}</p>' if p.get("notes") else ""
        cards += f"""
      <div class="platform-card">
        <div class="card-header" style="border-left:4px solid {color}">
          <div>
            <span class="card-title">{p['name']}</span>
            {gcp}
          </div>
          <span class="badge" style="background:{color}">{label}</span>
        </div>
        <p class="card-desc">{p['description'] or ''}</p>
        {notes_html}
        {'<span class="svc-count">'+svc+'</span>' if svc else ''}
      </div>"""
    return f'<div class="card-grid">{cards}</div>'


def render_capabilities_table(caps):
    rows = ""
    for c in caps:
        mig_label, mig_color = MIGRATION_BADGE.get(
            c.get("migration_status", "tbd"), ("?", "#95A5A6")
        )
        cov_color, cov_label = COVERAGE_BADGE.get(
            c.get("coverage_status", "partial"), ("#95A5A6", "?")
        )
        crit_color = RISK_COLOR.get(c.get("criticality", "low"), "#95A5A6")
        icon = DOMAIN_ICON.get(c.get("domain", ""), "")
        rows += f"""
      <tr>
        <td><span class="domain-icon">{icon}</span>{c['name']}</td>
        <td><span class="badge-sm" style="background:{cov_color}">{cov_label}</span></td>
        <td><span class="badge-sm" style="background:{mig_color}">{mig_label}</span></td>
        <td><span class="crit-dot" style="background:{crit_color}" title="{c.get('criticality','')}"></span></td>
        <td class="notes-cell">{c.get('notes','') or ''}</td>
      </tr>"""
    return f"""
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr>
            <th>Capacidad</th>
            <th>Cobertura</th>
            <th>Migración</th>
            <th>Crit.</th>
            <th>Notas</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </div>"""


def render_risks_table(risks):
    rows = ""
    for r in risks:
        ic = RISK_COLOR.get(r["impact"], "#95A5A6")
        rows += f"""
      <tr>
        <td><span class="badge-sm" style="background:{ic}">{r['impact'].upper()}</span></td>
        <td><strong>{r['id']}</strong></td>
        <td>{r['title']}</td>
        <td class="notes-cell">{r.get('mitigation','') or ''}</td>
      </tr>"""
    return f"""
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr><th>Impacto</th><th>ID</th><th>Riesgo</th><th>Mitigación</th></tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </div>"""


def render_stack_grid(stack):
    # Group by category
    by_cat: dict = {}
    for t in stack:
        cat = t["category"]
        by_cat.setdefault(cat, []).append(t)

    STATUS_BADGE = {
        "active":      ("#27AE60", ""),
        "migrating":   ("#F39C12", "→"),
        "deprecated":  ("#E74C3C", "×"),
        "planned":     ("#3498DB", "+"),
        "unknown":     ("#95A5A6", "?"),
    }

    sections = ""
    for cat in sorted(by_cat.keys()):
        icon = CATEGORY_ICON.get(cat, "📦")
        items = ""
        for t in by_cat[cat]:
            sc, sym = STATUS_BADGE.get(t["status"], ("#95A5A6", ""))
            vendor = f'<span class="vendor">{t["vendor"]}</span>' if t.get("vendor") else ""
            items += f"""
          <div class="stack-item" style="border-left:3px solid {sc}">
            <div class="stack-name">{sym and f'<span style="color:{sc}">{sym}</span> '}{t['name']}</div>
            {vendor}
            <div class="stack-role">{t['role']}</div>
          </div>"""
        sections += f"""
      <div class="stack-cat">
        <div class="stack-cat-title">{icon} {cat.upper()}</div>
        <div class="stack-items">{items}</div>
      </div>"""
    return f'<div class="stack-grid">{sections}</div>'


def render_integrations(integrations):
    CRIT_COLOR = {"critical": "#E74C3C", "high": "#E67E22", "medium": "#F39C12", "low": "#27AE60"}
    PROTO_BADGE = {
        "GraphQL": "#E10098", "REST": "#3498DB", "gRPC": "#7D3C98",
        "Pub/Sub": "#27AE60", "Batch": "#7F8C8D", "Event": "#F39C12",
        "SFTP": "#95A5A6", "TCP": "#2C3E50",
    }
    rows = ""
    for i in integrations:
        cc = CRIT_COLOR.get(i["criticality"], "#95A5A6")
        pc = PROTO_BADGE.get(i["protocol"], "#95A5A6")
        stat_icon = "✅" if i["status"] == "active" else ("🔄" if i["status"] == "migrating" else "📋")
        rows += f"""
      <tr>
        <td>{stat_icon}</td>
        <td>{i['from_sys']}</td>
        <td style="color:{pc};font-weight:bold">{i['protocol']}</td>
        <td>{i['to_sys']}</td>
        <td><span class="badge-sm" style="background:{cc}">{i['criticality']}</span></td>
        <td class="notes-cell">{i.get('description','') or ''}</td>
      </tr>"""
    return f"""
    <div class="table-wrap">
      <table class="data-table">
        <thead>
          <tr><th></th><th>Origen</th><th>Protocolo</th><th>Destino</th><th>Criticidad</th><th>Descripción</th></tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    </div>"""


def render_adr_cards(decisions):
    cards = ""
    for d in decisions:
        color = PALETTE["primary"] if d["status"] == "active" else "#95A5A6"
        cards += f"""
      <div class="adr-card">
        <div class="adr-header">
          <strong style="color:{color}">{d['id']}</strong>
          <span class="badge-sm" style="background:{color}">{d['status']}</span>
        </div>
        <div class="adr-title">{d['title']}</div>
        <div class="adr-decision">{d['decision']}</div>
        {f'<div class="adr-rationale"><em>{d["rationale"]}</em></div>' if d.get('rationale') else ''}
      </div>"""
    return f'<div class="adr-grid">{cards}</div>'


def build_html(info, platforms, gcp_projects, stack, caps, risks, slos, integrations, decisions, vocab):
    cards     = kpi_cards(info, risks, slos)
    ts        = datetime.now().strftime("%Y-%m-%d %H:%M")
    ver       = info.get("version", "1.0.0")
    engagement = info.get("engagement", "")
    client     = info.get("client", "Grupo Coppel")

    # Navigation tabs
    tabs = ["Resumen", "Capacidades", "Plataformas", "Stack", "Riesgos", "Integraciones", "Decisiones"]
    tab_nav = "".join(
        f'<button class="tab-btn{" active" if i==0 else ""}" onclick="showTab({i})">{t}</button>'
        for i, t in enumerate(tabs)
    )

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Coppel Retail — Digital Brain</title>
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: {PALETTE['bg']}; color: {PALETTE['text']}; font-size: 14px;
    }}
    /* ── Header ── */
    .header {{
      background: {PALETTE['primary']}; color: #fff; padding: 20px 32px;
      display: flex; align-items: center; justify-content: space-between;
      box-shadow: 0 2px 8px rgba(0,0,0,.2);
    }}
    .header-left h1 {{ font-size: 22px; font-weight: 700; letter-spacing: -.3px; }}
    .header-left p  {{ font-size: 12px; opacity: .8; margin-top: 2px; }}
    .header-right   {{ font-size: 11px; opacity: .7; text-align: right; }}
    .header-badge   {{
      display: inline-block; background: rgba(255,255,255,.2);
      border-radius: 4px; padding: 2px 8px; margin-top: 4px; font-size: 11px;
    }}
    /* ── Nav tabs ── */
    .tab-nav {{
      background: #fff; border-bottom: 1px solid {PALETTE['border']};
      padding: 0 32px; display: flex; gap: 0; overflow-x: auto;
    }}
    .tab-btn {{
      background: none; border: none; padding: 14px 18px; cursor: pointer;
      font-size: 13px; font-weight: 500; color: {PALETTE['text_muted']};
      border-bottom: 3px solid transparent; transition: all .15s; white-space: nowrap;
    }}
    .tab-btn:hover  {{ color: {PALETTE['primary']}; }}
    .tab-btn.active {{ color: {PALETTE['primary']}; border-bottom-color: {PALETTE['primary']}; }}
    /* ── Content ── */
    .tab-panel {{ display: none; padding: 28px 32px; }}
    .tab-panel.active {{ display: block; }}
    .section-title {{
      font-size: 16px; font-weight: 600; color: {PALETTE['primary']};
      margin-bottom: 16px; padding-bottom: 8px;
      border-bottom: 2px solid {PALETTE['border']};
    }}
    /* ── KPI grid ── */
    .kpi-grid {{
      display: grid; grid-template-columns: repeat(auto-fill, minmax(180px,1fr));
      gap: 16px; margin-bottom: 28px;
    }}
    .kpi-card {{
      background: #fff; border-radius: 8px; padding: 16px 18px;
      box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }}
    .kpi-icon  {{ font-size: 20px; margin-bottom: 8px; }}
    .kpi-value {{ font-size: 22px; font-weight: 700; margin-bottom: 2px; }}
    .kpi-title {{ font-size: 11px; font-weight: 600; color: {PALETTE['text_muted']}; text-transform: uppercase; letter-spacing: .5px; }}
    .kpi-target {{ font-size: 11px; color: {PALETTE['text_muted']}; margin-top: 4px; }}
    /* ── Cards grid ── */
    .card-grid {{
      display: grid; grid-template-columns: repeat(auto-fill, minmax(300px,1fr)); gap: 16px;
    }}
    .platform-card {{
      background: #fff; border-radius: 8px; padding: 16px;
      box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }}
    .card-header {{
      display: flex; align-items: flex-start; justify-content: space-between;
      margin-bottom: 10px; padding-left: 10px; gap: 8px;
    }}
    .card-title {{ font-weight: 600; font-size: 14px; display: block; margin-bottom: 4px; }}
    .card-desc  {{ font-size: 12px; color: {PALETTE['text_muted']}; line-height: 1.5; }}
    .card-notes {{ font-size: 11px; color: #888; margin-top: 8px; line-height: 1.4; }}
    .svc-count  {{ font-size: 11px; background: #f0f0f0; border-radius: 4px; padding: 2px 6px; display: inline-block; margin-top: 8px; }}
    /* ── Tables ── */
    .table-wrap {{ overflow-x: auto; }}
    .data-table {{
      width: 100%; border-collapse: collapse; font-size: 12px; background: #fff;
      border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }}
    .data-table thead tr {{ background: {PALETTE['primary']}; color: #fff; }}
    .data-table th {{ padding: 10px 12px; text-align: left; font-weight: 600; font-size: 11px; }}
    .data-table td {{ padding: 9px 12px; border-bottom: 1px solid {PALETTE['border']}; vertical-align: top; }}
    .data-table tr:last-child td {{ border-bottom: none; }}
    .data-table tr:hover td {{ background: #fafafa; }}
    .notes-cell {{ font-size: 11px; color: {PALETTE['text_muted']}; max-width: 260px; }}
    .domain-icon {{ margin-right: 6px; }}
    .crit-dot {{ display: inline-block; width: 10px; height: 10px; border-radius: 50%; }}
    /* ── Stack ── */
    .stack-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(260px,1fr)); gap: 20px; }}
    .stack-cat  {{ background: #fff; border-radius: 8px; padding: 16px; box-shadow: 0 1px 4px rgba(0,0,0,.06); }}
    .stack-cat-title {{ font-size: 11px; font-weight: 700; color: {PALETTE['text_muted']}; margin-bottom: 12px; letter-spacing: .5px; }}
    .stack-items {{ display: flex; flex-direction: column; gap: 8px; }}
    .stack-item  {{ padding: 8px 10px; background: #fafafa; border-radius: 4px; }}
    .stack-name  {{ font-weight: 600; font-size: 13px; }}
    .stack-role  {{ font-size: 11px; color: {PALETTE['text_muted']}; margin-top: 2px; }}
    .vendor      {{ font-size: 10px; color: #aaa; }}
    /* ── ADR cards ── */
    .adr-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(360px,1fr)); gap: 16px; }}
    .adr-card {{
      background: #fff; border-radius: 8px; padding: 16px;
      box-shadow: 0 1px 4px rgba(0,0,0,.06);
    }}
    .adr-header {{ display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }}
    .adr-title     {{ font-size: 13px; font-weight: 600; margin-bottom: 8px; }}
    .adr-decision  {{ font-size: 12px; color: {PALETTE['text_muted']}; line-height: 1.5; margin-bottom: 6px; }}
    .adr-rationale {{ font-size: 11px; color: #aaa; line-height: 1.4; }}
    /* ── Badges ── */
    .badge    {{ color: #fff; border-radius: 4px; padding: 3px 8px; font-size: 11px; font-weight: 600; white-space: nowrap; }}
    .badge-sm {{ color: #fff; border-radius: 3px; padding: 2px 6px; font-size: 10px; font-weight: 600; white-space: nowrap; }}
    .tag      {{ background: #f0f0f0; border-radius: 3px; padding: 1px 6px; font-size: 10px; color: #555; }}
    /* ── Win theme banner ── */
    .win-banner {{
      background: linear-gradient(135deg, {PALETTE['primary']}, {PALETTE['primary_dk']});
      color: #fff; border-radius: 8px; padding: 16px 20px; margin-bottom: 24px;
      font-size: 13px; line-height: 1.6;
    }}
    .win-banner strong {{ font-size: 15px; display: block; margin-bottom: 4px; }}
    /* ── GCP grid ── */
    .gcp-grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(260px,1fr)); gap: 12px; margin-top: 20px; }}
    .gcp-card {{
      background: #fff; border-radius: 8px; padding: 14px;
      box-shadow: 0 1px 4px rgba(0,0,0,.06); border-left: 4px solid {PALETTE['primary']};
    }}
    .gcp-id   {{ font-family: monospace; font-size: 11px; color: {PALETTE['text_muted']}; margin-bottom: 4px; }}
    .gcp-purp {{ font-size: 12px; color: {PALETTE['text']}; margin-bottom: 6px; }}
    .gcp-note {{ font-size: 11px; color: #888; line-height: 1.4; }}
  </style>
</head>
<body>

<div class="header">
  <div class="header-left">
    <h1>🛒 Coppel Retail — Digital Brain</h1>
    <p>{client} · {engagement}</p>
  </div>
  <div class="header-right">
    <div>v{ver} · {ts}</div>
    <div class="header-badge">eCommerce · GCP · Composable Commerce</div>
  </div>
</div>

<nav class="tab-nav">{tab_nav}</nav>

<!-- TAB 0: Resumen -->
<div class="tab-panel active" id="tab-0">
  <div class="win-banner">
    <strong>🏆 Win Theme: Accenture como guardian de la migración Composable</strong>
    Publicis Sapient conoce el origen (HCL Commerce). Accenture conoce el destino
    (SFCC headless + Apollo Federation + Next.js) — y puede reducir el MTTR de 20 días hábiles a SLA P1 (5 días).
    Impacto en negocio: <strong>$180,000 MXN/minuto</strong> de indisponibilidad.
  </div>

  <p class="section-title">KPIs Operativos</p>
  {render_kpi_section(cards)}

  <p class="section-title">Proyectos GCP</p>
  <div class="gcp-grid">
    {"".join(f'''
    <div class="gcp-card">
      <div class="gcp-id">{g['id']}</div>
      <div class="gcp-purp">{g['purpose']}</div>
      {f'<div class="gcp-note">{g["notes"]}</div>' if g.get('notes') else ''}
      {'<span class="badge" style="background:#E74C3C">PCI</span>' if g.get('pci_scope') else ''}
    </div>''' for g in gcp_projects)}
  </div>
</div>

<!-- TAB 1: Capacidades -->
<div class="tab-panel" id="tab-1">
  <p class="section-title">Capacidades de Negocio Retail</p>
  {render_capabilities_table(caps)}
</div>

<!-- TAB 2: Plataformas -->
<div class="tab-panel" id="tab-2">
  <p class="section-title">Plataformas eCommerce</p>
  {render_platform_cards(platforms)}
</div>

<!-- TAB 3: Stack -->
<div class="tab-panel" id="tab-3">
  <p class="section-title">Stack Tecnológico Confirmado</p>
  {render_stack_grid(stack)}
</div>

<!-- TAB 4: Riesgos -->
<div class="tab-panel" id="tab-4">
  <p class="section-title">Riesgos Abiertos ({len(risks)})</p>
  {render_risks_table(risks)}
</div>

<!-- TAB 5: Integraciones -->
<div class="tab-panel" id="tab-5">
  <p class="section-title">Mapa de Integraciones</p>
  {render_integrations(integrations)}
</div>

<!-- TAB 6: Decisiones -->
<div class="tab-panel" id="tab-6">
  <p class="section-title">Architectural Decision Records</p>
  {render_adr_cards(decisions)}
</div>

<script>
function showTab(n) {{
  document.querySelectorAll('.tab-panel').forEach((p,i) => p.classList.toggle('active', i===n));
  document.querySelectorAll('.tab-btn').forEach((b,i)  => b.classList.toggle('active', i===n));
}}
</script>
</body>
</html>"""


def main():
    if not DB_PATH.exists():
        print(f"ERROR: brain.db no encontrado en {DB_PATH}")
        print("Ejecuta primero: python digital-brain/build-brain.py")
        return

    print(f"Leyendo {DB_PATH}...")
    data = load_brain(DB_PATH)
    html = build_html(*data)

    OUTPUT_HTML.write_text(html, encoding="utf-8")
    print(f"Portal generado: {OUTPUT_HTML}")
    print(f"Tamaño: {len(html):,} bytes")


if __name__ == "__main__":
    main()

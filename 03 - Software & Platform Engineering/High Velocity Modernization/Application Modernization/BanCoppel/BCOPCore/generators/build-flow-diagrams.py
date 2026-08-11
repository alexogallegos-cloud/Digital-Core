#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-flow-diagrams.py — BCOPCore Flow Diagrams Portal Page
Proyecto: BanCoppel BCOPCore · SPE-AM-001

Genera portal/flow-diagrams-bcop.html con un catálogo de diagramas Mermaid
para los SPs orquestadores del Digital Brain (BCOPBrain).

Uso:
  cd BCOPCore/
  python generators/build-flow-diagrams.py
"""

import sys
import os
import html as html_lib
from pathlib import Path
from datetime import date

# ── Encoding robusto en Windows ────────────────────────────────────────────
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ── Rutas ──────────────────────────────────────────────────────────────────
BCOP_BASE = (
    "c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
    "03 - Software & Platform Engineering/High Velocity Modernization/"
    "Application Modernization/BanCoppel/BCOPCore"
)
BASE = Path(BCOP_BASE)
BRAIN_DIR = BASE / "digital-brain"
OUT_PATH = BASE / "portal" / "flow-diagrams-bcop.html"

# ── Importar BCOPBrain ─────────────────────────────────────────────────────
sys.path.insert(0, str(BRAIN_DIR))
from brain import BCOPBrain  # noqa: E402

TODAY = date.today().isoformat()

# ── Mapa de dominios (D01–D16 conocidos + genérico para el resto) ──────────
DOMAIN_NAMES = {
    # ── D01–D16: dominios analizados ─────────────────────────────────────────
    "D01": "Canal Digital Web",
    "D02": "Integración Core",
    "D03": "Crédito",
    "D04": "Chequera / Débito",
    "D05": "SAC / Transferencias",
    "D06": "Solicitudes de Crédito",
    "D07": "Aclaraciones",
    "D08": "SPEI / CoDi",
    "D09": "Mensajería",
    "D10": "Sucursales",
    "D11": "Cobranza",
    "D12": "Contabilidad",
    "D13": "TEF / Nómina",
    "D14": "BEI / Banca Empresarial",
    "D15": "LIDE / Dispersión",
    "D16": "Intercard",
    # ── D23–D49: dominios pendientes de análisis de grafo ────────────────────
    "D23": "MIS Sucursales",
    "D26": "Prospectos",
    "D32": "Reportes Visa/MC",
    "D34": "Respaldos DBA",
    "D35": "Digitalización",
    "D36": "Reportería CNBV",
    "D37": "Nómina BPI",
    "D40": "Banca Internet",
    "D44": "Conciliación Operativa",
    "D45": "Premios",
    "D46": "Oficinas de Cobro",
    "D47": "Garantías",
    "D48": "Riesgos de Crédito",
    "D49": "Retiro sin Tarjeta",
}

# Dominios con grafo de llamadas analizado (D01-D16)
ANALYZED_DOMAINS = {f"D{i:02d}" for i in range(1, 17)}

# ── Colores de badge por rol de SP ─────────────────────────────────────────
ROLE_COLORS = {
    "entry_point":              ("#2E7D32", "#ffffff"),
    "esb_exposed":              ("#1565C0", "#ffffff"),
    "cross_domain_primitive":   ("#E65100", "#ffffff"),
    "shared_service":           ("#00695C", "#ffffff"),
    "internal":                 ("#455A64", "#ffffff"),
}


def esc(text: str) -> str:
    """HTML-escape a value."""
    if text is None:
        return ""
    return html_lib.escape(str(text))


def domain_label(domain_id: str) -> str:
    """Return a human-readable label for a domain ID."""
    if not domain_id:
        return "Sin dominio"
    did = domain_id.upper()
    return DOMAIN_NAMES.get(did, did)


def role_badge(role: str) -> str:
    bg, fg = ROLE_COLORS.get(role, ("#546E7A", "#fff"))
    label = (role or "internal").replace("_", " ").title()
    return (
        f'<span class="badge-role" '
        f'style="background:{bg};color:{fg}">{esc(label)}</span>'
    )


def soul_badge() -> str:
    return '<span class="badge-soul">⬡ Alma</span>'


def domain_badge(domain_id: str) -> str:
    did = (domain_id or "").upper()
    name = DOMAIN_NAMES.get(did, did)
    return f'<span class="badge-domain">{esc(did)} · {esc(name)}</span>'


def render_card(sp: dict, flow: dict) -> str:
    """Render a single SP card with its Mermaid diagram."""
    name = esc(sp.get("name", ""))
    biz = esc(sp.get("biz") or "")
    domain_id = (sp.get("domain") or "").upper()
    sp_role = sp.get("sp_role") or "internal"
    fan_in = sp.get("fan_in", 0) or 0
    fan_out = sp.get("fan_out", 0) or 0
    rules_n = sp.get("rules_n", 0) or 0
    is_soul = bool(sp.get("is_soul"))
    primary_l3 = sp.get("primary_l3") or ""
    primary_l3_conf = sp.get("primary_l3_confidence")

    # Mermaid + stats
    mermaid_code_attr = ""   # HTML-escaped for data-code attribute (raw code returned by .getAttribute)
    stats_html = ""
    if flow and "error" not in flow:
        mermaid_code_attr = html_lib.escape(flow.get("mermaid", ""), quote=True)
        stats = flow.get("stats", {})
        total_nodes = stats.get("total_nodes", 0)
        total_edges = stats.get("total_edges", 0)
        total_rules = stats.get("total_rules", 0)
        unique_doms = stats.get("unique_domains", [])
        doms_str = esc(", ".join(unique_doms)) if unique_doms else "—"
        stats_html = f"""
            <div class="card-stats">
              <span><b>{total_nodes}</b> nodos</span>
              <span><b>{total_edges}</b> aristas</span>
              <span><b>{total_rules}</b> reglas en flujo</span>
              <span>Dominios: {doms_str}</span>
            </div>"""
    elif flow and "error" in flow:
        stats_html = f'<p class="card-error">Error al generar diagrama: {esc(flow["error"])}</p>'

    # ETB L3 line
    l3_html = ""
    if primary_l3:
        conf_str = ""
        if primary_l3_conf is not None:
            conf_str = f' <span class="l3-conf">({primary_l3_conf:.0%})</span>'
        l3_html = f'<div class="card-l3">ETB L3: <code>{esc(primary_l3)}</code>{conf_str}</div>'

    # Description
    biz_html = f'<div class="card-biz">{biz}</div>' if biz else ""

    # Unique card ID for expand/collapse
    card_id = f"card-{esc(sp.get('id', name)).replace(':', '-').replace(' ', '_')}"
    diagram_id = f"diag-{card_id}"

    soul_html = soul_badge() if is_soul else ""

    return f"""
    <div class="sp-card" data-domain="{esc(domain_id)}" id="{card_id}">
      <div class="card-header">
        <div class="card-title-row">
          <span class="card-name">{name}</span>
          {soul_html}
          {role_badge(sp_role)}
          {domain_badge(domain_id)}
        </div>
        <div class="card-meta">
          <span class="meta-item">fan_in <b>{fan_in}</b></span>
          <span class="meta-item">fan_out <b>{fan_out}</b></span>
          <span class="meta-item">reglas <b>{rules_n}</b></span>
        </div>
        {l3_html}
        {biz_html}
        <button class="btn-toggle" onclick="toggleDiagram('{diagram_id}', this)">
          Mostrar diagrama
        </button>
      </div>
      <div class="card-diagram" id="{diagram_id}" style="display:none">
        {stats_html}
        <div class="mermaid-wrap">
          <div class="mermaid" data-code="{mermaid_code_attr}"></div>
        </div>
      </div>
    </div>"""


def render_pending_card(sp: dict) -> str:
    """Card para SPs de D17-D49 donde el grafo de llamadas no fue analizado."""
    name      = esc(sp.get("name", ""))
    biz       = esc(sp.get("biz") or "")
    domain_id = (sp.get("domain") or "").upper()
    sp_role   = sp.get("sp_role") or "internal"
    fan_in    = sp.get("fan_in", 0) or 0
    loc       = sp.get("loc", 0) or 0
    primary_l3 = sp.get("primary_l3") or ""
    primary_l3_conf = sp.get("primary_l3_confidence")

    biz_html = f'<div class="card-biz">{biz}</div>' if biz else ""
    l3_html  = ""
    if primary_l3:
        conf_str = f' <span class="l3-conf">({primary_l3_conf:.0%})</span>' if primary_l3_conf else ""
        l3_html = f'<div class="card-l3">ETB L3: <code>{esc(primary_l3)}</code>{conf_str}</div>'

    safe_id = esc(name).replace(":", "-").replace(" ", "_")
    return f"""
    <div class="sp-card pending-card" data-domain="{esc(domain_id)}" id="pend-{esc(domain_id)}-{safe_id}">
      <div class="card-header">
        <div class="card-title-row">
          <span class="card-name">{name}</span>
          {role_badge(sp_role)}
          {domain_badge(domain_id)}
        </div>
        <div class="card-meta">
          <span class="meta-item">fan_in <b>{fan_in}</b></span>
          <span class="meta-item">loc <b>{loc}</b></span>
        </div>
        {l3_html}
        {biz_html}
        <div class="pending-notice">SP hoja — no llama a otros procedimientos (fan_out = 0)</div>
      </div>
    </div>"""


def build_html(cards_by_domain: dict, all_domains: list,
               analyzed_domains: set, pending_domains: list) -> str:
    """Build the complete HTML page."""

    # Sidebar: domain filter buttons
    sidebar_items = ['<button class="dom-btn active" onclick="filterDomain(\'ALL\', this)">Todos</button>']
    has_analyzed = [d for d in all_domains if d in analyzed_domains]
    has_pending  = [d for d in all_domains if d not in analyzed_domains]

    if has_analyzed:
        sidebar_items.append('<div class="sidebar-sep">Con grafo analizado</div>')
    for did in has_analyzed:
        name = domain_label(did)
        sidebar_items.append(
            f'<button class="dom-btn" onclick="filterDomain(\'{did}\', this)">'
            f'{esc(did)}<span class="dom-name">{esc(name)}</span>'
            f'</button>'
        )
    if has_pending:
        sidebar_items.append('<div class="sidebar-sep">SP Hojas (sin grafo)</div>')
    for did in has_pending:
        name = domain_label(did)
        sidebar_items.append(
            f'<button class="dom-btn pending-btn" onclick="filterDomain(\'{did}\', this)">'
            f'{esc(did)}<span class="dom-name">{esc(name)}</span>'
            f'</button>'
        )
    sidebar_html = "\n".join(sidebar_items)

    # Cards
    all_cards_html = []
    for did in all_domains:
        cards = cards_by_domain.get(did, [])
        for card_html in cards:
            all_cards_html.append(card_html)

    cards_html = "\n".join(all_cards_html)

    total_sp      = sum(len(v) for v in cards_by_domain.values())
    total_dom     = len(all_domains)
    total_analyzed = len(has_analyzed)
    total_pending  = len(has_pending)

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <title>BCOPCore — Diagramas de Flujo de Tareas</title>
  <style>
    /* Reset */
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}

    /* Design tokens */
    :root {{
      --bg:          #0d1117;
      --bg-card:     #161b22;
      --bg-card2:    #21262d;
      --border:      rgba(255,255,255,.08);
      --border2:     rgba(255,255,255,.13);
      --accent:      #58a6ff;
      --accent2:     #79c0ff;
      --muted:       #8b949e;
      --muted2:      #6e7681;
      --text:        #c9d1d9;
      --text-strong: #f0f6fc;
      --soul:        #7c3aed;
      --soul-border: #a78bfa;
      --green:       #3fb950;
      --orange:      #d29922;
      --red:         #f85149;
      --sidebar-w:   240px;
    }}

    html {{ scroll-behavior: smooth; }}

    body {{
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, 'Segoe UI', 'Inter', sans-serif;
      font-size: 14px;
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
    }}

    /* ── Nav ── */
    nav {{
      position: sticky;
      top: 0;
      z-index: 100;
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 24px;
      background: rgba(13,17,23,.92);
      backdrop-filter: blur(12px);
      border-bottom: 1px solid var(--border);
    }}
    nav img {{ height: 22px; }}
    nav .sep {{ color: var(--muted2); }}
    nav .nav-title {{ color: var(--text-strong); font-weight: 600; font-size: 15px; }}
    nav .nav-sub {{ color: var(--muted); font-size: 12px; margin-left: auto; }}

    /* ── Layout ── */
    .layout {{
      display: flex;
      min-height: calc(100vh - 52px);
    }}

    /* ── Sidebar ── */
    .sidebar {{
      width: var(--sidebar-w);
      flex-shrink: 0;
      position: sticky;
      top: 52px;
      height: calc(100vh - 52px);
      overflow-y: auto;
      border-right: 1px solid var(--border);
      padding: 16px 12px;
      background: var(--bg);
    }}
    .sidebar-title {{
      font-size: 11px;
      font-weight: 700;
      letter-spacing: .08em;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 10px;
      padding: 0 6px;
    }}
    .dom-btn {{
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      width: 100%;
      padding: 8px 10px;
      border-radius: 8px;
      background: transparent;
      border: 1px solid transparent;
      color: var(--text);
      cursor: pointer;
      font-size: 13px;
      font-weight: 600;
      margin-bottom: 4px;
      text-align: left;
      transition: background .15s, border-color .15s, color .15s;
    }}
    .dom-btn:hover {{
      background: var(--bg-card2);
      border-color: var(--border);
      color: var(--text-strong);
    }}
    .dom-btn.active {{
      background: rgba(88,166,255,.12);
      border-color: rgba(88,166,255,.35);
      color: var(--accent2);
    }}
    .dom-name {{
      display: block;
      font-size: 10px;
      font-weight: 400;
      color: var(--muted);
      margin-top: 2px;
    }}
    .dom-btn.active .dom-name {{ color: rgba(121,192,255,.7); }}

    /* ── Main content ── */
    .main {{
      flex: 1;
      min-width: 0;
      padding: 28px 32px;
    }}

    /* ── Page header ── */
    .page-header {{
      margin-bottom: 28px;
      padding-bottom: 20px;
      border-bottom: 1px solid var(--border);
    }}
    .page-title {{
      font-size: 26px;
      font-weight: 800;
      color: var(--text-strong);
      letter-spacing: -.02em;
      margin-bottom: 6px;
    }}
    .page-sub {{
      font-size: 13px;
      color: var(--muted);
      max-width: 70ch;
    }}
    .page-stats {{
      display: flex;
      gap: 20px;
      margin-top: 14px;
      flex-wrap: wrap;
    }}
    .page-stat {{
      font-size: 13px;
      color: var(--muted);
    }}
    .page-stat b {{ color: var(--accent); }}

    /* ── Cards ── */
    .sp-card {{
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 12px;
      margin-bottom: 16px;
      overflow: hidden;
      transition: border-color .2s;
    }}
    .sp-card:hover {{
      border-color: var(--border2);
    }}

    .card-header {{
      padding: 18px 20px;
    }}
    .card-title-row {{
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
    }}
    .card-name {{
      font-family: 'SF Mono', ui-monospace, 'Cascadia Code', monospace;
      font-size: 15px;
      font-weight: 700;
      color: var(--text-strong);
    }}

    /* Badges */
    .badge-role {{
      padding: 2px 9px;
      border-radius: 20px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: .04em;
      text-transform: uppercase;
    }}
    .badge-soul {{
      padding: 2px 10px;
      border-radius: 20px;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: .04em;
      background: rgba(124,58,237,.2);
      border: 1px solid rgba(167,139,250,.5);
      color: #a78bfa;
    }}
    .badge-domain {{
      padding: 2px 9px;
      border-radius: 20px;
      font-size: 10px;
      font-weight: 600;
      background: rgba(255,255,255,.06);
      border: 1px solid var(--border2);
      color: var(--muted);
    }}

    .card-meta {{
      display: flex;
      gap: 16px;
      flex-wrap: wrap;
      margin-bottom: 8px;
    }}
    .meta-item {{
      font-size: 12px;
      color: var(--muted);
    }}
    .meta-item b {{ color: var(--text-strong); }}

    .card-l3 {{
      font-size: 12px;
      color: var(--muted);
      margin-bottom: 6px;
    }}
    .card-l3 code {{
      background: rgba(88,166,255,.1);
      border: 1px solid rgba(88,166,255,.25);
      border-radius: 4px;
      padding: 0 5px;
      font-size: 11px;
      color: var(--accent);
      font-family: 'SF Mono', ui-monospace, monospace;
    }}
    .l3-conf {{ color: var(--muted2); font-size: 11px; }}

    .card-biz {{
      font-size: 13px;
      color: var(--muted);
      font-style: italic;
      margin-bottom: 10px;
      max-width: 80ch;
    }}

    .card-error {{
      font-size: 12px;
      color: var(--red);
      padding: 8px 20px;
    }}

    /* Toggle button */
    .btn-toggle {{
      padding: 6px 14px;
      border-radius: 8px;
      background: rgba(88,166,255,.1);
      border: 1px solid rgba(88,166,255,.3);
      color: var(--accent);
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: background .15s;
    }}
    .btn-toggle:hover {{
      background: rgba(88,166,255,.18);
    }}
    .btn-toggle.open {{
      background: rgba(88,166,255,.18);
    }}

    /* Diagram section */
    .card-diagram {{
      border-top: 1px solid var(--border);
      background: var(--bg-card2);
    }}

    .card-stats {{
      display: flex;
      gap: 20px;
      flex-wrap: wrap;
      padding: 12px 20px 8px;
      font-size: 12px;
      color: var(--muted);
      border-bottom: 1px solid var(--border);
    }}
    .card-stats b {{ color: var(--text-strong); }}

    .mermaid-wrap {{
      padding: 20px;
      overflow-x: auto;
    }}
    .mermaid-wrap .mermaid {{
      display: flex;
      justify-content: center;
    }}

    /* ── Footer ── */
    footer {{
      padding: 28px 32px 48px;
      border-top: 1px solid var(--border);
      color: var(--muted2);
      font-size: 11px;
      text-align: center;
      line-height: 1.9;
    }}
    footer code {{
      background: rgba(255,255,255,.06);
      border-radius: 4px;
      padding: 1px 5px;
      font-family: monospace;
      font-size: 10px;
    }}

    /* ── SP Hoja cards (D23-D49, fan_out=0) ── */
    .pending-card {{
      border-color: var(--border);
    }}
    .pending-card:hover {{
      border-color: var(--border2);
    }}
    .pending-notice {{
      margin-top: 8px;
      padding: 5px 10px;
      background: rgba(88,166,255,.06);
      border: 1px solid rgba(88,166,255,.18);
      border-radius: 6px;
      font-size: 11px;
      color: var(--muted);
      font-style: italic;
    }}

    /* Sidebar separador y botón SP hojas */
    .sidebar-sep {{
      font-size: 9px;
      font-weight: 700;
      letter-spacing: .08em;
      text-transform: uppercase;
      color: var(--muted2);
      margin: 12px 0 6px 6px;
    }}
    .pending-btn {{
      opacity: .85;
    }}
    .pending-btn .dom-name {{
      color: var(--muted);
    }}
    .pending-btn.active {{
      background: rgba(88,166,255,.08);
      border-color: rgba(88,166,255,.25);
    }}
  </style>
</head>
<body>

<nav>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <span class="sep">/</span>
  <span class="nav-title">BCOPCore — Diagramas de Flujo de Tareas</span>
  <span class="nav-sub">SPE-AM-001 · DISCOVER · {TODAY}</span>
</nav>

<div class="layout">

  <!-- Sidebar: filtro por dominio -->
  <aside class="sidebar">
    <div class="sidebar-title">Filtrar por dominio</div>
    {sidebar_html}
  </aside>

  <!-- Main -->
  <main class="main">
    <div class="page-header">
      <h1 class="page-title">Diagramas de Flujo de Tareas</h1>
      <p class="page-sub">
        SPs orquestadores del Digital Brain de BCOPCore — entry points, ESB-exposed y
        cross-domain primitives con mayor lógica de negocio (rules_n ≥ 3, fan_out ≥ 3).
        Cada diagrama refleja el árbol de callees a profundidad 1 con hasta 8 hijos.
      </p>
      <div class="page-stats">
        <span class="page-stat"><b>{total_sp}</b> SPs en catálogo</span>
        <span class="page-stat"><b>{total_analyzed}</b> dominios con grafo analizado</span>
        <span class="page-stat"><b>{total_pending}</b> dominios pendientes</span>
        <span class="page-stat">Fuente: <b>BCOPBrain</b> · <code>brain.db</code></span>
      </div>
    </div>

    <div id="cards-container">
{cards_html}
    </div>

  </main>
</div>

<footer>
  BCOPCore · BanCoppel Application Modernization · SPE-AM-001 · DISCOVER<br>
  Generado desde <code>brain.db</code> con <code>generators/build-flow-diagrams.py</code> · {TODAY}<br>
  <code>BCOPBrain.orchestrators(min_rules=3, min_fan_out=3, limit=60)</code> +
  <code>BCOPBrain.flow_diagram(depth=1, max_children=8)</code>
</footer>

<script>
// ── Domain filter ──────────────────────────────────────────────────────────
function filterDomain(domain, btn) {{
  // Update active button
  document.querySelectorAll('.dom-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');

  // Show/hide cards
  document.querySelectorAll('.sp-card').forEach(card => {{
    if (domain === 'ALL') {{
      card.style.display = '';
    }} else {{
      card.style.display = card.dataset.domain === domain ? '' : 'none';
    }}
  }});
}}

// ── Expand / collapse diagram ──────────────────────────────────────────────
async function toggleDiagram(diagId, btn) {{
  const diag = document.getElementById(diagId);
  if (!diag) return;

  const isHidden = diag.style.display === 'none';

  if (isHidden) {{
    diag.style.display = '';
    btn.textContent = 'Ocultar diagrama';
    btn.classList.add('open');

    if (!diag.dataset.rendered) {{
      diag.dataset.rendered = '1';
      const mermaidEl = diag.querySelector('.mermaid');
      if (mermaidEl) {{
        const code = mermaidEl.getAttribute('data-code');
        if (code) {{
          const uid = diagId.replace(/[^a-z0-9]/gi, '-') + '-' + Date.now();
          try {{
            const {{ svg }} = await mermaid.render('svg-' + uid, code);
            mermaidEl.innerHTML = svg;
          }} catch (e) {{
            mermaidEl.textContent = 'Error al renderizar: ' + e.message;
            mermaidEl.style.color = '#f85149';
            mermaidEl.style.fontSize = '11px';
          }}
        }}
      }}
    }}
  }} else {{
    diag.style.display = 'none';
    btn.textContent = 'Mostrar diagrama';
    btn.classList.remove('open');
  }}
}}
</script>

<script src="mermaid.min.js"></script>
<script>
  mermaid.initialize({{
    startOnLoad: false,
    theme: 'dark',
    htmlLabels: true,
    themeVariables: {{
      primaryColor:        '#1a3080',
      primaryTextColor:    '#e8f0ff',
      primaryBorderColor:  '#3D5FCD',
      secondaryColor:      '#0d1a40',
      tertiaryColor:       '#1a2a5a',
      lineColor:           '#5a8fff',
      edgeLabelBackground: '#0a1230',
      fontFamily:          "'SF Pro Display', -apple-system, 'Inter', sans-serif",
      fontSize:            '13px',
    }}
  }});
</script>

</body>
</html>"""


def main() -> None:
    print("=" * 60)
    print("BCOPCore — build-flow-diagrams.py")
    print(f"Brain DB:  {BRAIN_DIR / 'brain.db'}")
    print(f"Output:    {OUT_PATH}")
    print("=" * 60)

    with BCOPBrain() as brain:
        # 1. Candidatos orquestadores D01-D16 (fan_out >= 3, cualquier nivel de reglas)
        print("\n[1] Consultando orchestrators(min_rules=0, min_fan_out=3, limit=300)...")
        orchestrators = brain.orchestrators(min_rules=0, min_fan_out=3, limit=300)
        print(f"    → {len(orchestrators)} SPs candidatos encontrados")

        if not orchestrators:
            print("AVISO: No se encontraron orquestadores con los filtros dados.")
            return

        # 2. Para cada SP orquestador obtener el flow_diagram
        print("\n[2] Generando diagramas de flujo (depth=1, max_children=8)...")
        cards_by_domain: dict[str, list] = {}
        processed = 0
        errors = []

        for sp in orchestrators:
            sp_name = sp.get("name", "")
            sp_id   = sp.get("id", sp_name)
            domain  = (sp.get("domain") or "").upper()

            try:
                flow = brain.flow_diagram(sp_id, depth=1, max_children=8)
            except Exception as exc:
                print(f"    [ERROR] {sp_name}: {exc}")
                errors.append((sp_name, str(exc)))
                flow = {"error": str(exc)}

            card_html = render_card(sp, flow)
            cards_by_domain.setdefault(domain, []).append(card_html)
            processed += 1

            status = "⬡" if sp.get("is_soul") else "·"
            node_count = flow.get("stats", {}).get("total_nodes", 0) if "error" not in flow else "-"
            print(f"    {status} [{domain}] {sp_name}  ({node_count} nodos)")

        print(f"\n    Procesados: {processed}  |  Errores: {len(errors)}")

        # 3. D17-D49: SPs sin grafo analizado — top 15 por dominio ordenados por loc DESC
        import sqlite3 as _sqlite3
        print("\n[3] Consultando D17-D49 (sin grafo, top 15 por dominio por loc)...")
        con_raw = _sqlite3.connect(str(BRAIN_DIR / "brain.db"))
        con_raw.row_factory = _sqlite3.Row
        rows_pend = con_raw.execute("""
            WITH ranked AS (
                SELECT id, name, biz, domain, sp_role, fan_in, fan_out, rules_n,
                       is_soul, primary_l3, primary_l3_confidence, loc,
                       ROW_NUMBER() OVER (PARTITION BY domain ORDER BY loc DESC) AS rn
                FROM sps
                WHERE CAST(SUBSTR(domain,2) AS INT) >= 17
            )
            SELECT * FROM ranked WHERE rn <= 15
            ORDER BY CAST(SUBSTR(domain,2) AS INT), rn
        """).fetchall()
        con_raw.close()

        pending_count = 0
        for row in rows_pend:
            sp = dict(row)
            domain = (sp.get("domain") or "").upper()
            cards_by_domain.setdefault(domain, []).append(render_pending_card(sp))
            pending_count += 1

        print(f"    → {pending_count} SPs pendientes en {len([d for d in cards_by_domain if d not in ANALYZED_DOMAINS])} dominios")

        # 4. Ordenar dominios canónicamente
        def dom_sort_key(d: str) -> tuple:
            try:
                return (int(d[1:]),)
            except (ValueError, IndexError):
                return (9999,)

        all_domains = sorted(cards_by_domain.keys(), key=dom_sort_key)
        pending_domains = [d for d in all_domains if d not in ANALYZED_DOMAINS]

        # 5. Generar HTML
        print("\n[4] Generando HTML...")
        html_content = build_html(cards_by_domain, all_domains,
                                  ANALYZED_DOMAINS, pending_domains)

        OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
        OUT_PATH.write_text(html_content, encoding="utf-8")

        # 6. Resumen
        total_cards = processed + pending_count
        print("\n" + "=" * 60)
        print(f"SPs con diagrama  : {processed}")
        print(f"SPs pendientes    : {pending_count}")
        print(f"Total cards       : {total_cards}")
        print(f"Dominios totales  : {len(all_domains)}  ({', '.join(all_domains)})")
        print(f"Errores           : {len(errors)}")
        if errors:
            for sp_name, err in errors:
                print(f"  - {sp_name}: {err}")
        print(f"Archivo generado  : {OUT_PATH}")
        print("=" * 60)
        print(f"\nURL local: http://localhost:8080/flow-diagrams-bcop.html")


if __name__ == "__main__":
    main()
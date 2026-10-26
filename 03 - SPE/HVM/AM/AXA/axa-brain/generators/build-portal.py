"""
build-portal.py
Genera portal/index.html — visualización web del AXA Digital Brain P&C.
Lee axa-brain.db y embebe los datos como constantes JS en el HTML.

Ejecutar desde: AXA/axa-brain/
    python generators/build-portal.py
"""
import sys

# ─────────────────────────────────────────────────────────────────────────
# SUPERADO — este generador escribe el mismo portal/index.html que
# build-index.py, que es el generador vigente desde 2026-09-07.
# Ejecutarlo pisa el portal bueno con una version mas vieja y sin las
# cifras vivas del brain. Se deja por referencia, no por uso.
# Para generar el portal:  python generators/build-index.py
# ─────────────────────────────────────────────────────────────────────────
if "--force" not in sys.argv:
    raise SystemExit(
        "[SUPERADO] build-portal.py quedo sustituido por build-index.py." "\n"
        "           Ejecuta: python generators/build-index.py" "\n"
        "           Si de verdad quieres correr este, pasa --force."
    )



import sqlite3
import os
import json
from datetime import datetime

BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH    = os.path.join(BASE_DIR, "axa-brain.db")
PORTAL_DIR = os.path.join(BASE_DIR, "portal")
OUT_HTML   = os.path.join(PORTAL_DIR, "index.html")
TODAY      = datetime.now().strftime("%Y-%m-%d")


# ─── Value chain definition (static, based on discovery) ────────────────────
VALUE_CHAIN = [
    {
        "id": "C1", "name": "Diseño de Producto",
        "desc": "Notas técnicas, tarifas, condicionados y reglas de suscripción por ramo.",
        "etb": "D6.2 Product Mgmt.", "sistemas": "Nota Técnica · ERN (cat.)",
        "status": "partial", "dts": []
    },
    {
        "id": "C2", "name": "Distribución",
        "desc": "Gestión de agentes, corredores y conductos. Recepción de solicitudes.",
        "etb": "D1/D2/D4", "sistemas": "SINCO · Sin portal",
        "status": "partial", "dts": ["dt-distribution-network"]
    },
    {
        "id": "C3", "name": "Suscripción",
        "desc": "Evaluación del riesgo, tarificación técnica, negociación y decisión.",
        "etb": "D6.3 Underwriting", "sistemas": "Vector · HSD ⚠️ · SINCO · ERN · SAFAC",
        "status": "gap", "dts": ["dt-underwriting-intelligence"]
    },
    {
        "id": "C4", "name": "Emisión de Póliza",
        "desc": "Captura condiciones aprobadas, emite póliza, gestiona endosos y renovaciones.",
        "etb": "D6.4 Policy Admin", "sistemas": "General Daños",
        "status": "partial", "dts": ["dt-policy-lifecycle"]
    },
    {
        "id": "C5", "name": "Reaseguro",
        "desc": "Cesión facultativa de riesgos comerciales de gran tamaño.",
        "etb": "D6.1 Reinsurance", "sistemas": "SAFAC · ERN",
        "status": "partial", "dts": ["dt-reinsurance-program"]
    },
    {
        "id": "C6", "name": "Siniestros",
        "desc": "FNOL, ajuste, autorización de pago y cierre del expediente.",
        "etb": "D6.5 Claims", "sistemas": "Sin confirmar",
        "status": "scaffold", "dts": ["dt-claims-lifecycle"]
    },
    {
        "id": "C7", "name": "Cobranza",
        "desc": "Cobro de primas, gestión de morosidad y fraccionamiento.",
        "etb": "D6.1 Billing", "sistemas": "Sin confirmar",
        "status": "scaffold", "dts": []
    },
]

SUPPORT = [
    {"name": "Actuaría y Reservas",   "sistemas": "ERN · Por confirmar",          "status": "partial"},
    {"name": "Analytics / BI",        "sistemas": "Power BI",                     "status": "partial"},
    {"name": "Regulatorio (CNSF)",    "sistemas": "Monitor (tentativo)",           "status": "partial"},
    {"name": "Finanzas / IFRS 17",    "sistemas": "Por confirmar",                "status": "scaffold"},
    {"name": "Integración",           "sistemas": "Sin API gateway",              "status": "scaffold"},
]

STATUS_LABEL = {
    "confirmed": "Confirmado",
    "confirmed-name": "Confirmado",
    "partial": "Parcial",
    "scaffold": "Scaffold",
    "gap": "Gap crítico",
}

STATUS_COLOR = {
    "confirmed": "#2d7d46",
    "confirmed-name": "#2d7d46",
    "partial": "#c8a000",
    "scaffold": "#888888",
    "gap": "#c0392b",
}


# ─── DB queries ──────────────────────────────────────────────────────────────
def load_data(conn):
    meta = dict(conn.execute("SELECT key, value FROM brain_meta").fetchall())

    systems = [dict(zip(
        ["slug","display_name","real_name","category","togaf_type","lob","status","note"],
        r
    )) for r in conn.execute(
        "SELECT slug,display_name,real_name,category,togaf_type,lob,status,note FROM systems ORDER BY category,slug"
    ).fetchall()]

    stats = {
        "process_steps":    conn.execute("SELECT COUNT(*) FROM process_steps").fetchone()[0],
        "pain_points":      conn.execute("SELECT COUNT(*) FROM pain_points").fetchone()[0],
        "etb_capabilities": conn.execute("SELECT COUNT(*) FROM etb_capabilities").fetchone()[0],
        "vocab":            conn.execute("SELECT COUNT(*) FROM vocab").fetchone()[0],
        "market_intel":     conn.execute("SELECT COUNT(*) FROM market_intel").fetchone()[0],
        "systems":          len(systems),
    }

    pp_by_cat = conn.execute("""
        SELECT cat_c1, COUNT(*) n,
               SUM(manualidad) manual,
               SUM(lob_property) prop,
               SUM(lob_suscripcion) susc
        FROM pain_points
        WHERE cat_c1 IS NOT NULL AND cat_c1 != ''
        GROUP BY cat_c1 ORDER BY n DESC
    """).fetchall()

    lob_impact = conn.execute("""
        SELECT
          SUM(lob_property)       prop,
          SUM(lob_suscripcion)    susc,
          SUM(lob_ramos_tecnicos) rt,
          SUM(lob_rc)             rc,
          SUM(lob_maritimo)       mar,
          SUM(lob_aviacion)       avi,
          SUM(lob_obras_arte)     oa,
          SUM(lob_lineas_fin)     lf
        FROM pain_points
    """).fetchone()

    process_by_lob = conn.execute("""
        SELECT lob, COUNT(*) n FROM process_steps
        WHERE lob IS NOT NULL AND lob != ''
        GROUP BY lob ORDER BY n DESC
    """).fetchall()

    process_by_fase = conn.execute("""
        SELECT fase_l2, COUNT(*) n,
               SUM(CASE WHEN sistemas_slugs='' OR sistemas_slugs IS NULL THEN 1 ELSE 0 END) manual
        FROM process_steps
        WHERE fase_l2 IS NOT NULL AND fase_l2 != ''
        GROUP BY fase_l2 ORDER BY n DESC LIMIT 10
    """).fetchall()

    return meta, systems, stats, pp_by_cat, lob_impact, process_by_lob, process_by_fase


# ─── HTML generation ─────────────────────────────────────────────────────────
def render_html(meta, systems, stats, pp_by_cat, lob_impact, process_by_lob, process_by_fase):
    built_at = meta.get("built_at", TODAY)

    # Serialize data for JS
    js_systems    = json.dumps(systems, ensure_ascii=False)
    js_vc         = json.dumps(VALUE_CHAIN, ensure_ascii=False)
    js_support    = json.dumps(SUPPORT, ensure_ascii=False)
    js_stats      = json.dumps(stats, ensure_ascii=False)
    js_pp_cat     = json.dumps([{"cat": r[0], "n": r[1], "manual": r[2], "prop": r[3], "susc": r[4]}
                                 for r in pp_by_cat], ensure_ascii=False)
    js_lob_impact = json.dumps({
        "labels": ["Property","Suscripción","Ramos Técnicos","RC","Marítimo","Aviación","Obras Arte","Líneas Fin."],
        "values": list(lob_impact)
    }, ensure_ascii=False)
    js_proc_lob   = json.dumps([{"lob": r[0], "n": r[1]} for r in process_by_lob], ensure_ascii=False)
    js_proc_fase  = json.dumps([{"fase": r[0], "n": r[1], "manual": r[2]} for r in process_by_fase],
                                ensure_ascii=False)

    status_colors_js = json.dumps(STATUS_COLOR)
    status_labels_js = json.dumps(STATUS_LABEL)

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AXA Digital Brain · P&C Commercial Lines</title>
<style>
  :root {{
    --axa-blue: #00008F;
    --axa-red: #FF1721;
    --axa-bg: #F5F5F5;
    --axa-white: #FFFFFF;
    --text: #1a1a2e;
    --text-light: #555577;
    --confirmed: #2d7d46;
    --partial: #c8a000;
    --scaffold: #888888;
    --gap: #c0392b;
    --border: #e0e0f0;
    --shadow: 0 2px 12px rgba(0,0,72,0.08);
    --radius: 10px;
  }}
  * {{ box-sizing: border-box; margin: 0; padding: 0; }}
  body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
         background: var(--axa-bg); color: var(--text); font-size: 14px; }}

  /* ── Header ── */
  header {{
    background: var(--axa-blue); color: white;
    padding: 16px 32px; display: flex; align-items: center; gap: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  }}
  .axa-logo {{
    font-size: 26px; font-weight: 900; letter-spacing: -1px; color: white;
    background: var(--axa-red); padding: 2px 10px; border-radius: 4px;
  }}
  .header-title {{ flex: 1; }}
  .header-title h1 {{ font-size: 18px; font-weight: 600; }}
  .header-title p  {{ font-size: 12px; opacity: 0.7; margin-top: 2px; }}
  .header-meta {{ font-size: 11px; opacity: 0.6; text-align: right; line-height: 1.6; }}

  /* ── Tabs ── */
  .tab-bar {{
    background: var(--axa-white); border-bottom: 1px solid var(--border);
    display: flex; padding: 0 32px; gap: 4px; overflow-x: auto;
  }}
  .tab-btn {{
    padding: 14px 20px; border: none; background: none; cursor: pointer;
    font-size: 13px; font-weight: 500; color: var(--text-light);
    border-bottom: 3px solid transparent; white-space: nowrap;
    transition: all 0.2s;
  }}
  .tab-btn:hover {{ color: var(--axa-blue); }}
  .tab-btn.active {{ color: var(--axa-blue); border-bottom-color: var(--axa-blue); }}

  /* ── Main ── */
  main {{ padding: 28px 32px; max-width: 1400px; margin: 0 auto; }}
  .tab-panel {{ display: none; }}
  .tab-panel.active {{ display: block; }}

  /* ── Stat cards ── */
  .stats-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(150px,1fr)); gap: 16px; margin-bottom: 28px; }}
  .stat-card {{
    background: white; border-radius: var(--radius); padding: 20px 16px;
    text-align: center; box-shadow: var(--shadow); border-top: 4px solid var(--axa-blue);
  }}
  .stat-num {{ font-size: 36px; font-weight: 700; color: var(--axa-blue); line-height: 1; }}
  .stat-label {{ font-size: 11px; color: var(--text-light); margin-top: 6px; text-transform: uppercase; letter-spacing: 0.5px; }}

  /* ── Section headers ── */
  .section-title {{ font-size: 16px; font-weight: 600; color: var(--axa-blue);
                    margin: 28px 0 14px; padding-bottom: 8px; border-bottom: 2px solid var(--border); }}
  .section-title:first-child {{ margin-top: 0; }}

  /* ── Value chain ── */
  .chain-wrapper {{ overflow-x: auto; padding-bottom: 8px; }}
  .chain-flow {{
    display: flex; align-items: stretch; gap: 0; min-width: 900px;
  }}
  .chain-activity {{
    flex: 1; background: white; border-radius: var(--radius);
    padding: 16px 12px; margin: 0 4px;
    box-shadow: var(--shadow); border-top: 5px solid;
    display: flex; flex-direction: column; gap: 6px;
    position: relative; cursor: pointer; transition: transform 0.15s;
  }}
  .chain-activity:hover {{ transform: translateY(-2px); }}
  .chain-id {{ font-size: 10px; font-weight: 700; color: var(--text-light); letter-spacing: 1px; }}
  .chain-name {{ font-size: 12px; font-weight: 700; color: var(--text); line-height: 1.3; }}
  .chain-system {{ font-size: 10px; color: var(--text-light); margin-top: 4px; }}
  .chain-etb {{ font-size: 9px; color: var(--text-light); opacity: 0.7; }}
  .chain-badge {{
    display: inline-block; font-size: 9px; font-weight: 600;
    padding: 2px 7px; border-radius: 20px; margin-top: 6px;
    color: white; text-transform: uppercase; letter-spacing: 0.5px;
  }}
  .chain-arrow {{
    display: flex; align-items: center; color: var(--border);
    font-size: 20px; margin: 0 -4px; z-index: 1;
    align-self: center; flex-shrink: 0;
  }}

  .support-row {{
    display: flex; gap: 8px; margin-top: 12px; flex-wrap: wrap;
  }}
  .support-pill {{
    background: white; border-radius: 20px; padding: 6px 14px;
    font-size: 11px; box-shadow: var(--shadow); border-left: 3px solid;
    display: flex; align-items: center; gap: 8px;
  }}
  .support-pill .s-name {{ font-weight: 600; }}
  .support-pill .s-sys {{ color: var(--text-light); }}

  /* ── Systems grid ── */
  .systems-grid {{
    display: grid; grid-template-columns: repeat(auto-fill, minmax(280px,1fr)); gap: 14px;
  }}
  .system-card {{
    background: white; border-radius: var(--radius); padding: 16px;
    box-shadow: var(--shadow); border-left: 4px solid;
  }}
  .system-card .s-header {{ display: flex; justify-content: space-between; align-items: flex-start; }}
  .system-card .s-name {{ font-weight: 700; font-size: 13px; color: var(--text); }}
  .system-card .s-real {{ font-size: 12px; color: var(--text-light); margin-top: 3px; }}
  .system-card .s-lob  {{ font-size: 10px; color: var(--text-light); margin-top: 2px; }}
  .system-card .s-note {{ font-size: 11px; color: var(--text-light); margin-top: 10px;
                          border-top: 1px solid var(--border); padding-top: 8px; }}
  .badge {{
    display: inline-block; font-size: 9px; font-weight: 700; padding: 2px 8px;
    border-radius: 20px; color: white; text-transform: uppercase; white-space: nowrap;
  }}
  .cat-header {{
    font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px;
    color: var(--text-light); margin: 20px 0 10px; padding: 6px 0;
    border-bottom: 1px solid var(--border);
  }}

  /* ── Bar chart ── */
  .bar-chart {{ display: flex; flex-direction: column; gap: 10px; }}
  .bar-row {{ display: flex; align-items: center; gap: 10px; }}
  .bar-label {{ width: 280px; font-size: 11px; color: var(--text); flex-shrink: 0; text-align: right; }}
  .bar-track {{ flex: 1; background: var(--border); border-radius: 4px; height: 22px; overflow: hidden; }}
  .bar-fill {{
    height: 100%; border-radius: 4px; display: flex; align-items: center;
    padding: 0 8px; font-size: 11px; font-weight: 600; color: white;
    transition: width 0.6s ease;
  }}
  .bar-sub {{ font-size: 10px; color: var(--text-light); width: 60px; flex-shrink: 0; }}

  /* ── Grid 2col ── */
  .grid-2 {{ display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }}
  @media (max-width: 800px) {{ .grid-2 {{ grid-template-columns: 1fr; }} }}

  /* ── Gap table ── */
  .gap-table {{ width: 100%; border-collapse: collapse; font-size: 12px; }}
  .gap-table th {{ background: var(--axa-blue); color: white; padding: 10px 12px; text-align: left; font-weight: 600; }}
  .gap-table td {{ padding: 9px 12px; border-bottom: 1px solid var(--border); vertical-align: middle; }}
  .gap-table tr:hover td {{ background: #f0f0ff; }}

  /* ── Quick wins ── */
  .qw-grid {{ display: flex; flex-direction: column; gap: 14px; }}
  .qw-card {{
    background: white; border-radius: var(--radius); padding: 18px 20px;
    box-shadow: var(--shadow); display: flex; gap: 16px; align-items: flex-start;
    border-left: 5px solid var(--axa-blue);
  }}
  .qw-num {{
    background: var(--axa-blue); color: white; border-radius: 50%;
    width: 32px; height: 32px; display: flex; align-items: center; justify-content: center;
    font-weight: 700; font-size: 14px; flex-shrink: 0;
  }}
  .qw-body h4 {{ font-size: 14px; font-weight: 700; margin-bottom: 6px; }}
  .qw-body p  {{ font-size: 12px; color: var(--text-light); line-height: 1.6; }}
  .qw-meta {{ display: flex; gap: 8px; margin-top: 10px; flex-wrap: wrap; }}
  .qw-tag {{
    font-size: 10px; background: var(--axa-bg); border-radius: 20px;
    padding: 3px 10px; color: var(--text-light); font-weight: 500;
  }}

  /* ── Waves ── */
  .waves-grid {{ display: grid; grid-template-columns: repeat(3,1fr); gap: 16px; }}
  .wave-card {{
    background: white; border-radius: var(--radius); padding: 20px;
    box-shadow: var(--shadow);
  }}
  .wave-card h3 {{ font-size: 14px; font-weight: 700; margin-bottom: 4px; }}
  .wave-card .wave-period {{ font-size: 11px; color: var(--text-light); margin-bottom: 14px; }}
  .wave-card ul {{ padding-left: 16px; display: flex; flex-direction: column; gap: 8px; }}
  .wave-card li {{ font-size: 12px; color: var(--text); line-height: 1.5; }}
  .wave-1 {{ border-top: 4px solid var(--confirmed); }}
  .wave-2 {{ border-top: 4px solid var(--partial); }}
  .wave-3 {{ border-top: 4px solid var(--axa-blue); }}

  /* ── Legend ── */
  .legend {{ display: flex; gap: 16px; flex-wrap: wrap; margin-top: 12px; }}
  .legend-item {{ display: flex; align-items: center; gap: 6px; font-size: 11px; }}
  .legend-dot {{ width: 12px; height: 12px; border-radius: 50%; }}

  /* ── Process table ── */
  .proc-table {{ width: 100%; border-collapse: collapse; font-size: 12px; }}
  .proc-table th {{ background: var(--axa-blue); color: white; padding: 8px 12px; text-align: left; }}
  .proc-table td {{ padding: 8px 12px; border-bottom: 1px solid var(--border); }}
  .proc-table tr:hover td {{ background: #f0f0ff; }}
  .pct-bar {{
    display: inline-block; background: var(--axa-blue); height: 8px;
    border-radius: 4px; margin-left: 8px; vertical-align: middle;
  }}
</style>
</head>
<body>

<header>
  <div class="axa-logo">AXA</div>
  <div class="header-title">
    <h1>Digital Brain · P&C Commercial Lines</h1>
    <p>AXA Seguros S.A. de C.V. · Líneas Comerciales de Daños · México</p>
  </div>
  <div class="header-meta">
    v{meta.get("version","1.0.0")}<br>
    Construido: {built_at}<br>
    {TODAY}
  </div>
</header>

<div class="tab-bar">
  <button class="tab-btn active" onclick="showTab('dashboard')">Dashboard</button>
  <button class="tab-btn" onclick="showTab('value-chain')">Cadena de Valor</button>
  <button class="tab-btn" onclick="showTab('sistemas')">Sistemas</button>
  <button class="tab-btn" onclick="showTab('gaps')">Análisis de Brechas</button>
  <button class="tab-btn" onclick="showTab('transformacion')">Ruta de Transformación</button>
</div>

<main>

<!-- ══════════════════════════════════ DASHBOARD ══════════════════════════════════ -->
<div class="tab-panel active" id="tab-dashboard">

  <div class="stats-grid" id="stats-grid"></div>

  <div class="section-title">Cadena de Valor — Cobertura por Actividad</div>
  <div class="chain-wrapper"><div class="chain-flow" id="dash-chain"></div></div>
  <div class="legend">
    <div class="legend-item"><div class="legend-dot" style="background:var(--confirmed)"></div>Confirmado</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--partial)"></div>Parcial</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--gap)"></div>Gap crítico</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--scaffold)"></div>Por confirmar</div>
  </div>

  <div class="grid-2" style="margin-top:28px">
    <div>
      <div class="section-title">Pain Points por Categoría</div>
      <div class="bar-chart" id="dash-pp-chart"></div>
    </div>
    <div>
      <div class="section-title">Pasos de Proceso por Línea de Negocio</div>
      <div class="bar-chart" id="dash-lob-chart"></div>
    </div>
  </div>

</div>

<!-- ══════════════════════════════ CADENA DE VALOR ══════════════════════════════ -->
<div class="tab-panel" id="tab-value-chain">

  <div class="section-title">Cadena de Valor Primaria — AXA P&C Commercial Lines</div>
  <div class="chain-wrapper"><div class="chain-flow" id="vc-chain"></div></div>
  <div class="legend" style="margin-top:12px">
    <div class="legend-item"><div class="legend-dot" style="background:var(--confirmed)"></div>Confirmado</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--partial)"></div>Parcial</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--gap)"></div>Gap crítico</div>
    <div class="legend-item"><div class="legend-dot" style="background:var(--scaffold)"></div>Por confirmar</div>
  </div>

  <div class="section-title" style="margin-top:28px">Actividades de Soporte</div>
  <div class="support-row" id="vc-support"></div>

  <div class="section-title" style="margin-top:28px">Fases del Proceso de Suscripción (C3 · 541 pasos)</div>
  <table class="proc-table">
    <thead><tr><th>Fase (L2)</th><th>Pasos</th><th>Pasos manuales (sin sistema)</th><th>Distribución</th></tr></thead>
    <tbody id="fase-table-body"></tbody>
  </table>

</div>

<!-- ══════════════════════════════════ SISTEMAS ══════════════════════════════════ -->
<div class="tab-panel" id="tab-sistemas">
  <div class="section-title">Landscape de Sistemas — 16 Sistemas Registrados</div>
  <div id="systems-container"></div>
</div>

<!-- ══════════════════════════════════ GAPS ══════════════════════════════════ -->
<div class="tab-panel" id="tab-gaps">

  <div class="grid-2">
    <div>
      <div class="section-title">Pain Points por Categoría (33 total)</div>
      <div class="bar-chart" id="gaps-pp-chart"></div>
    </div>
    <div>
      <div class="section-title">Impacto por Línea de Negocio</div>
      <div class="bar-chart" id="gaps-lob-chart"></div>
    </div>
  </div>

  <div class="section-title" style="margin-top:28px">Cobertura ETB — Capacidades Clave de Suscripción</div>
  <table class="gap-table">
    <thead>
      <tr>
        <th>ETB ID</th><th>Capacidad</th><th>Sistema AXA</th><th>Estado</th>
      </tr>
    </thead>
    <tbody id="etb-table-body"></tbody>
  </table>

</div>

<!-- ══════════════════════════════ TRANSFORMACIÓN ══════════════════════════════ -->
<div class="tab-panel" id="tab-transformacion">

  <div class="section-title">Quick Wins — Ola 1 (0–12 meses)</div>
  <div class="qw-grid" id="qw-container"></div>

  <div class="section-title" style="margin-top:32px">Olas de Transformación</div>
  <div class="waves-grid">
    <div class="wave-card wave-1">
      <h3>Ola 1 · Quick Wins</h3>
      <div class="wave-period">0–12 meses</div>
      <ul>
        <li>API ERN → cotización (eliminar copia manual de PML)</li>
        <li>SAFAC carga masiva de capas</li>
        <li>Confirmar rol de Monitor (desbloqueador regulatorio)</li>
        <li>Visibilidad de folios Vector para agentes</li>
        <li>Diagnóstico completo de la HSD por LoB</li>
      </ul>
    </div>
    <div class="wave-card wave-2">
      <h3>Ola 2 · Decisiones Estratégicas</h3>
      <div class="wave-period">12–24 meses</div>
      <ul>
        <li>Digitalizar HSD: herramienta web integrada con Vector</li>
        <li>Integración Vector → General Daños (eliminar recaptura)</li>
        <li>Portal de agentes básico con pipeline de cotizaciones</li>
        <li>Datawarehouse consolidado (single source of truth)</li>
        <li>Decisión SAFAC: extender vs. reemplazar</li>
      </ul>
    </div>
    <div class="wave-card wave-3">
      <h3>Ola 3 · Transformación Profunda</h3>
      <div class="wave-period">24–48 meses</div>
      <ul>
        <li>Plataforma de suscripción digital end-to-end</li>
        <li>Portal agentes self-service con underwriting automático</li>
        <li>API gateway para exposición de capacidades a brokers</li>
        <li>Reporting regulatorio automatizado (CNSF + IFRS 17)</li>
        <li>AI-assisted risk scoring con datos históricos</li>
      </ul>
    </div>
  </div>

</div>

</main>

<script>
// ── Data ──────────────────────────────────────────────────────────────────
const SYSTEMS      = {js_systems};
const VALUE_CHAIN  = {js_vc};
const SUPPORT      = {js_support};
const STATS        = {js_stats};
const PP_CAT       = {js_pp_cat};
const LOB_IMPACT   = {js_lob_impact};
const PROC_LOB     = {js_proc_lob};
const PROC_FASE    = {js_proc_fase};
const STATUS_COLORS = {status_colors_js};
const STATUS_LABELS = {status_labels_js};

const ETB_GAPS = [
  {{"id":"6.3.1","cap":"Gestión de información del riesgo","sistema":"SINCO (búsqueda limitada)","status":"partial"}},
  {{"id":"6.3.2","cap":"Evaluación y tarificación del riesgo","sistema":"HSD — Excel sin sistema","status":"gap"}},
  {{"id":"6.3.3","cap":"Modelación catastrófica","sistema":"ERN (sin integración automática)","status":"partial"}},
  {{"id":"6.3.4","cap":"Gestión de cotización","sistema":"HSD + correo — sin sistema","status":"gap"}},
  {{"id":"6.3.5","cap":"Negociación y colocación","sistema":"Correo / WhatsApp","status":"gap"}},
  {{"id":"6.4",  "cap":"Administración de pólizas","sistema":"General Daños (recaptura manual)","status":"partial"}},
  {{"id":"6.5",  "cap":"Gestión de reaseguro","sistema":"SAFAC (solo lineal)","status":"partial"}},
  {{"id":"D1/D2","cap":"Canales y distribución","sistema":"Sin portal confirmado","status":"scaffold"}},
  {{"id":"D6.5", "cap":"Gestión de siniestros","sistema":"Sin confirmar","status":"scaffold"}},
  {{"id":"D7.2", "cap":"Reporting regulatorio CNSF","sistema":"Monitor (tentativo)","status":"partial"}},
];

const QUICK_WINS = [
  {{
    "num": "QW-1", "title": "API ERN → sistema de cotización",
    "desc": "Exponer los resultados de modelación catastrófica de ERN como API para eliminar la copia manual de PML y cúmulos al Excel de suscripción.",
    "esfuerzo": "Bajo", "tiempo": "1–2 meses", "lobs": "Property, Ramos Técnicos"
  }},
  {{
    "num": "QW-2", "title": "SAFAC — carga masiva de capas",
    "desc": "Evaluar si SAFAC soporta carga masiva de reaseguradores; si no, implementar importación desde Excel de capas y participaciones por colocación.",
    "esfuerzo": "Bajo", "tiempo": "1–3 meses", "lobs": "Property, RT, RC"
  }},
  {{
    "num": "QW-3", "title": "Confirmar rol de Monitor",
    "desc": "Entrevista con el equipo de reporting para determinar si Monitor es la herramienta de reporting CNSF, monitoreo de cartera o ambas. Desbloquea dos DTs.",
    "esfuerzo": "Muy bajo", "tiempo": "2–4 semanas", "lobs": "Regulatorio (todos)"
  }},
  {{
    "num": "QW-4", "title": "Visibilidad de folios para agentes",
    "desc": "Exponer una vista de solo lectura del estado de folios en Vector por conducto. Elimina llamadas/correos de seguimiento sin necesitar un portal completo.",
    "esfuerzo": "Medio", "tiempo": "3–6 meses", "lobs": "Todos"
  }},
  {{
    "num": "QW-5", "title": "Diagnóstico HSD — decisión de inversión",
    "desc": "Taller con suscriptores para mapear todas las variantes del Excel por LoB. Define la decisión de transformación más importante del programa.",
    "esfuerzo": "Bajo", "tiempo": "4–8 semanas", "lobs": "Todos (Property, RT, RC mínimo)"
  }},
];

// ── Tab switching ─────────────────────────────────────────────────────────
function showTab(id) {{
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + id).classList.add('active');
  event.target.classList.add('active');
}}

// ── Helpers ───────────────────────────────────────────────────────────────
function statusColor(s) {{ return STATUS_COLORS[s] || '#888'; }}
function statusLabel(s) {{ return STATUS_LABELS[s] || s; }}

function badge(status, text) {{
  text = text || statusLabel(status);
  return `<span class="badge" style="background:${{statusColor(status)}}">${{text}}</span>`;
}}

function chainCard(act) {{
  const c = statusColor(act.status);
  return `
    <div class="chain-activity" style="border-top-color:${{c}}">
      <div class="chain-id">${{act.id}}</div>
      <div class="chain-name">${{act.name}}</div>
      <div class="chain-system">${{act.sistemas}}</div>
      <div class="chain-etb">${{act.etb}}</div>
      ${{badge(act.status)}}
    </div>`;
}}

function buildChain(containerId) {{
  const el = document.getElementById(containerId);
  if (!el) return;
  let html = '';
  VALUE_CHAIN.forEach((act, i) => {{
    html += chainCard(act);
    if (i < VALUE_CHAIN.length - 1) html += '<div class="chain-arrow">›</div>';
  }});
  el.innerHTML = html;
}}

function buildSupport(containerId) {{
  const el = document.getElementById(containerId);
  if (!el) return;
  el.innerHTML = SUPPORT.map(s => `
    <div class="support-pill" style="border-left-color:${{statusColor(s.status)}}">
      <span class="s-name">${{s.name}}</span>
      <span class="s-sys">${{s.sistemas}}</span>
      ${{badge(s.status)}}
    </div>
  `).join('');
}}

function buildBarChart(containerId, data, labelKey, valueKey, maxVal, color, subKey) {{
  const el = document.getElementById(containerId);
  if (!el) return;
  el.innerHTML = data.map(d => {{
    const pct = Math.round((d[valueKey] / maxVal) * 100);
    const sub = subKey ? `<div class="bar-sub">${{d[subKey]}} manual</div>` : '';
    return `
      <div class="bar-row">
        <div class="bar-label" title="${{d[labelKey]}}">${{d[labelKey].length > 36 ? d[labelKey].slice(0,34)+'…' : d[labelKey]}}</div>
        <div class="bar-track">
          <div class="bar-fill" style="width:${{pct}}%;background:${{color}}">${{d[valueKey]}}</div>
        </div>
        ${{sub}}
      </div>`;
  }}).join('');
}}

// ── Dashboard ─────────────────────────────────────────────────────────────
function buildDashboard() {{
  const statDefs = [
    {{label: 'Pasos de proceso',    val: STATS.process_steps,    icon: '📋'}},
    {{label: 'Pain Points',         val: STATS.pain_points,       icon: '⚠️'}},
    {{label: 'Capacidades ETB',     val: STATS.etb_capabilities,  icon: '🗂️'}},
    {{label: 'Términos Rosetta',    val: STATS.vocab,             icon: '📖'}},
    {{label: 'Sistemas',            val: STATS.systems,           icon: '🖥️'}},
    {{label: 'Intel. mercado',      val: STATS.market_intel,      icon: '📊'}},
  ];
  document.getElementById('stats-grid').innerHTML = statDefs.map(s =>
    `<div class="stat-card">
       <div class="stat-num">${{s.val}}</div>
       <div class="stat-label">${{s.label}}</div>
     </div>`
  ).join('');

  buildChain('dash-chain');

  const maxPP = Math.max(...PP_CAT.map(p => p.n));
  buildBarChart('dash-pp-chart', PP_CAT, 'cat', 'n', maxPP, 'var(--axa-red)', 'manual');

  const maxLOB = Math.max(...PROC_LOB.map(p => p.n));
  buildBarChart('dash-lob-chart', PROC_LOB, 'lob', 'n', maxLOB, 'var(--axa-blue)');
}}

// ── Value Chain tab ───────────────────────────────────────────────────────
function buildValueChain() {{
  buildChain('vc-chain');
  buildSupport('vc-support');

  const maxFase = Math.max(...PROC_FASE.map(f => f.n));
  const tbody = document.getElementById('fase-table-body');
  if (tbody) {{
    tbody.innerHTML = PROC_FASE.map(f => {{
      const manPct = f.n > 0 ? Math.round((f.manual / f.n) * 100) : 0;
      const barW = Math.round((f.n / maxFase) * 160);
      return `<tr>
        <td>${{f.fase.charAt(0).toUpperCase() + f.fase.slice(1)}}</td>
        <td>${{f.n}}</td>
        <td>${{f.manual}} (${{manPct}}%)</td>
        <td><span class="pct-bar" style="width:${{barW}}px"></span></td>
      </tr>`;
    }}).join('');
  }}
}}

// ── Systems tab ───────────────────────────────────────────────────────────
function buildSystems() {{
  const bycat = {{}};
  SYSTEMS.forEach(s => {{
    if (!bycat[s.category]) bycat[s.category] = [];
    bycat[s.category].push(s);
  }});

  const catOrder = ['core','processors','channels','integration','data','compliance'];
  const catLabel = {{
    core: 'Core — Sistemas de Negocio',
    processors: 'Processors — Motores de Procesamiento',
    channels: 'Channels — Canales de Distribución',
    integration: 'Integration — Capa de Integración',
    data: 'Data — Datos y Analítica',
    compliance: 'Compliance — Regulatorio'
  }};

  let html = '';
  catOrder.forEach(cat => {{
    if (!bycat[cat]) return;
    html += `<div class="cat-header">${{catLabel[cat] || cat}}</div>`;
    html += '<div class="systems-grid">';
    bycat[cat].forEach(s => {{
      const c = statusColor(s.status);
      html += `
        <div class="system-card" style="border-left-color:${{c}}">
          <div class="s-header">
            <div>
              <div class="s-name">${{s.display_name}}</div>
              <div class="s-real">Sistema real: <strong>${{s.real_name}}</strong></div>
              <div class="s-lob">${{s.lob}}</div>
            </div>
            ${{badge(s.status)}}
          </div>
          <div class="s-note">${{s.note}}</div>
        </div>`;
    }});
    html += '</div>';
  }});
  document.getElementById('systems-container').innerHTML = html;
}}

// ── Gaps tab ──────────────────────────────────────────────────────────────
function buildGaps() {{
  const maxPP = Math.max(...PP_CAT.map(p => p.n));
  buildBarChart('gaps-pp-chart', PP_CAT, 'cat', 'n', maxPP, 'var(--axa-red)', 'manual');

  const lobData = LOB_IMPACT.labels.map((l, i) => ({{lob: l, n: LOB_IMPACT.values[i]}}));
  const maxLob = Math.max(...LOB_IMPACT.values);
  buildBarChart('gaps-lob-chart', lobData, 'lob', 'n', maxLob, 'var(--axa-red)');

  const tbody = document.getElementById('etb-table-body');
  if (tbody) {{
    tbody.innerHTML = ETB_GAPS.map(g => {{
      const c = statusColor(g.status);
      return `<tr>
        <td><strong>${{g.id}}</strong></td>
        <td>${{g.cap}}</td>
        <td>${{g.sistema}}</td>
        <td>${{badge(g.status)}}</td>
      </tr>`;
    }}).join('');
  }}
}}

// ── Transformación tab ───────────────────────────────────────────────────
function buildTransformacion() {{
  document.getElementById('qw-container').innerHTML = QUICK_WINS.map(qw => `
    <div class="qw-card">
      <div class="qw-num">${{qw.num.replace('QW-','')}}</div>
      <div class="qw-body">
        <h4>${{qw.title}}</h4>
        <p>${{qw.desc}}</p>
        <div class="qw-meta">
          <span class="qw-tag">Esfuerzo: ${{qw.esfuerzo}}</span>
          <span class="qw-tag">Tiempo: ${{qw.tiempo}}</span>
          <span class="qw-tag">LoBs: ${{qw.lobs}}</span>
        </div>
      </div>
    </div>
  `).join('');
}}

// ── Init ──────────────────────────────────────────────────────────────────
buildDashboard();
buildValueChain();
buildSystems();
buildGaps();
buildTransformacion();
</script>
</body>
</html>"""


# ─── Main ────────────────────────────────────────────────────────────────────
def main():
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] axa-brain.db no encontrado en {DB_PATH}")
        return

    os.makedirs(PORTAL_DIR, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    meta, systems, stats, pp_by_cat, lob_impact, process_by_lob, process_by_fase = load_data(conn)
    conn.close()

    html = render_html(meta, systems, stats, pp_by_cat, lob_impact, process_by_lob, process_by_fase)
    with open(OUT_HTML, "w", encoding="utf-8") as f:
        f.write(html)

    kb = os.path.getsize(OUT_HTML) // 1024
    print(f"[OK] portal/index.html generado ({kb} KB)")
    print(f"     {OUT_HTML}")


if __name__ == "__main__":
    main()
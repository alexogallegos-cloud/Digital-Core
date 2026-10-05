"""
build-cadena-valor-tickets.py
Genera portal/cadena-valor-tickets-liv.html

Vista: carga operativa real (tickets AMS) cruzada contra la cadena de valor ETB,
con desglose año a año (2024/2025/2026) y métricas de SLA (mediana, P90, P1/P2).

Secciones:
  Hero  — KPIs globales
  S0    — Alcance Accenture vs. fuera de alcance por eslabón (En alcance AMS N2)
  S1    — Barras por eslabón (carga relativa + P90 ponderado + criticidad)
  S2    — Tendencia anual por eslabón (2024 / 2025 / 2026)
  S3    — Tabla de grupos (filtro por eslabón + búsqueda + ordenable)
  S4    — Alertas SLA: grupos con P90 > 500h en algún año
"""

import json
import sqlite3
from pathlib import Path

from _liv_shared import hero, page, stat

# ---------------------------------------------------------------------------
# Clasificación de alcance Accenture ("En alcance AMS N2")
# Fuente: Liverpool_ValueLed_Expansion_Approach 2.html — recuadros rosas
# ---------------------------------------------------------------------------
IN_SCOPE_GROUPS = {
    # VC-01 Desarrollo de Oferta
    "AMS PDM", "AMS SAP PMR", "AMS SAP PLM", "AMS PLM", "AMS PA&A",
    # VC-02 Cadena de Suministro
    "AMS SAP EWM (LIV Y SBB)", "AMS STERLING OMS (LIV/SBB)", "AMS GESTOR",
    "AMS RUTEADOR", "AMS SIBO", "AMS PDTA", "AMS TMS", "AMS SAP MM", "AMS ITR",
    "AMS VOICE LINK/VOICE PICKING",
    # VC-03 Comercio Unificado
    "AMS XD APPSURTIDO", "AMS FACTURACION", "AMS SAP ECC RETAIL", "AMS PAO",
    "AMS ENTRADA UNICA", "AMS VCM", "AMS EU SAP", "AMS HUB DE PAGOS",
    "AMS XSTREAM", "AMS FACTURACION EXTENDIDO", "AMS ICM",
    # VC-04 Canales de Interacción
    "AMS OPTICA", "AMS SIEBEL SIS", "AMS PORTAL DE CITAS SL", "AMS SASTRERIA",
    "AMS PORTAL DE CITAS BT", "AMS VAS REPARACION DE RELOJES Y JOYERIA FINA",
    "AMS PANTALLA UNICA", "AMS SIEBEL CRM", "AMS MI PUERTO",
    "AMS MIPUERTO/AUTOSERVICIO", "AMS SIEBEL MDM", "AMS TASK MANAGER",
    "AMS PORTAL REPARACIONES N5", "AMS VAS MADE TO ORDER",
    "AMS BROKER",   # Datos, analítica e integración · 10 en alcance · 0 candidatas
    # VC-05 Engagement y Marketing
    "AMS CDP", "AMS WORK FRONT Y WFS SBB",
    # VC-06 Servicios Financieros
    "AMS CYBER", "AMS FICO DMPS",
    "AMS FICO TRIAD", "AMS PRESTAMOS/DISP EFECTIVO",
    # VC-07 Fundación Empresarial
    "AMS ACC", "AMS SAP S4H SBB", "AMS SAP FIORI", "AMS SAP ECC FI",
    "AMS RH NOMINA", "AMS RH PORTALES", "AMS BTP", "AMS APIGEE",
    "AMS SAP ECC INMOBILIARIA", "AMS UKG", "AMS SAP ECC PM MTTO",
    "AMS BSM COUPA", "AMS SSFF LIV Y SBB", "AMS CHERWELL",
    # VC-08 Fundación de Información
    "AMS DWH/DATA", "AMS SAP BW LIV/ SAP BW PDM", "AMS SAP BW4 SBB/BO HIBRIDO",
    "AMS SAP BW PMR SAP BO", "AMS SAP BPC", "AMS POWER BI",
    # VC-09 Analítica e Inteligencia
    "AMS SAS",
}

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"
OUT   = BRAIN / "portal" / "cadena-valor-tickets-liv.html"

# Paleta por eslabón — consistent con build-cadena-valor.py
VC_COLORS = {
    "VC-01": "#f59e0b",
    "VC-02": "#10b981",
    "VC-03": "#3b82f6",
    "VC-04": "#8b5cf6",
    "VC-05": "#ec4899",
    "VC-06": "#ef4444",
    "VC-07": "#6366f1",
    "VC-08": "#14b8a6",
    "VC-09": "#f97316",
}

YR_COLORS = {"2024": "#60a5fa", "2025": "#10b981", "2026": "#f59e0b"}


# ---------------------------------------------------------------------------
# Datos del brain
# ---------------------------------------------------------------------------

def load_data(conn):
    c = conn.cursor()

    vc_rows = c.execute("""
        SELECT
            vc.id, vc.name,
            COUNT(DISTINCT agc.group_name)                               AS grupos,
            SUM(ay.tickets)                                              AS total_tickets,
            SUM(ay.mediana_h * ay.tickets) / NULLIF(SUM(ay.tickets),0)  AS med_h,
            SUM(ay.p90_h    * ay.tickets) / NULLIF(SUM(ay.tickets),0)   AS p90_h,
            SUM(ay.p1_count)                                             AS p1,
            SUM(ay.p2_count)                                             AS p2,
            SUM(ay.p1_count + ay.p2_count) * 1.0 /
                NULLIF(SUM(ay.tickets),0) * 100                          AS crit_pct
        FROM value_chain vc
        LEFT JOIN ams_group_component agc ON agc.vc_id = vc.id
        LEFT JOIN ams_yearly ay ON ay.group_name = agc.group_name
        GROUP BY vc.id
        ORDER BY vc.id
    """).fetchall()

    yearly_vc = c.execute("""
        SELECT agc.vc_id, ay.year, SUM(ay.tickets)
        FROM ams_group_component agc
        JOIN ams_yearly ay ON ay.group_name = agc.group_name
        WHERE agc.vc_id IS NOT NULL
        GROUP BY agc.vc_id, ay.year
        ORDER BY agc.vc_id, ay.year
    """).fetchall()

    groups = c.execute("""
        SELECT
            agc.group_name, agc.vc_id, vc.name AS vc_name,
            agc.mapping,
            SUM(ay.tickets)                           AS total,
            SUM(ay.p1_count)                          AS p1,
            SUM(ay.p2_count)                          AS p2,
            MAX(ay.p90_h)                             AS p90_max,
            AVG(ay.p90_h)                             AS p90_avg,
            AVG(ay.mediana_h)                         AS med_avg,
            AVG(ay.criticality_pct) * 100             AS crit_pct,
            GROUP_CONCAT(ay.year || ':' || ay.tickets, '|') AS by_year
        FROM ams_group_component agc
        LEFT JOIN value_chain vc ON vc.id = agc.vc_id
        LEFT JOIN ams_yearly ay ON ay.group_name = agc.group_name
        WHERE COALESCE(
            (SELECT is_noise FROM ams_groups WHERE group_name = agc.group_name), 0
        ) = 0
          AND ay.tickets IS NOT NULL
        GROUP BY agc.group_name
        ORDER BY total DESC
    """).fetchall()

    kpi = c.execute("""
        SELECT SUM(tickets), SUM(p1_count), SUM(p2_count),
               AVG(p90_h), COUNT(DISTINCT group_name)
        FROM ams_yearly
    """).fetchone()

    alerts = c.execute("""
        SELECT ay.group_name, agc.vc_id, ay.year,
               ay.tickets, ay.p90_h, ay.p1_count, ay.p2_count
        FROM ams_yearly ay
        JOIN ams_group_component agc ON agc.group_name = ay.group_name
        WHERE ay.p90_h > 500
        ORDER BY ay.p90_h DESC
    """).fetchall()

    # Procesos críticos por VC (nueva fuente: critical_processes)
    proc_by_vc_rows = []
    try:
        proc_by_vc_rows = c.execute("""
            SELECT vc_id,
                   COUNT(*) as n_proc,
                   SUM(COALESCE(activities_count,0)) as total_act,
                   SUM(COALESCE(incidents_count,0)) as total_inc
            FROM critical_processes
            GROUP BY vc_id
        """).fetchall()
    except Exception:
        pass

    return vc_rows, yearly_vc, groups, kpi, alerts, proc_by_vc_rows


def load_scope_data(conn):
    """Per-VC split: tickets en alcance Accenture vs fuera de alcance AMS N2."""
    rows = conn.execute("""
        SELECT agc.vc_id, agc.group_name, SUM(ay.tickets) AS tix
        FROM ams_group_component agc
        JOIN ams_yearly ay ON ay.group_name = agc.group_name
        WHERE agc.vc_id IS NOT NULL
          AND COALESCE(
              (SELECT is_noise FROM ams_groups WHERE group_name = agc.group_name), 0
          ) = 0
        GROUP BY agc.vc_id, agc.group_name
        ORDER BY agc.vc_id
    """).fetchall()

    result = {}
    for vc_id, group_name, tix in rows:
        if vc_id not in result:
            result[vc_id] = {"in": 0, "out": 0, "out_groups": []}
        tix_i = int(tix or 0)
        if group_name in IN_SCOPE_GROUPS:
            result[vc_id]["in"] += tix_i
        else:
            result[vc_id]["out"] += tix_i
            result[vc_id]["out_groups"].append({"g": group_name, "t": tix_i})
    return result


# ---------------------------------------------------------------------------
# HTML
# ---------------------------------------------------------------------------

CSS = """
#wrap{flex:1;overflow-y:auto;padding:22px 26px 60px}
.sec{margin-bottom:32px}
.sec-h{display:flex;align-items:baseline;gap:12px;margin-bottom:14px}
.sec-h h2{font-size:17px;font-weight:800;letter-spacing:-.02em}
.sec-h small{font-size:11px;color:var(--muted)}

/* eslabón bars */
.vc-grid{display:flex;flex-direction:column;gap:10px}
.vc-row{display:grid;grid-template-columns:220px 1fr 80px 100px 80px 70px 70px;align-items:center;gap:10px}
.vc-lbl{font-size:12px;font-weight:700;cursor:pointer;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.vc-lbl:hover{text-decoration:underline}
.bar-track{background:rgba(255,255,255,.07);border-radius:4px;height:14px;overflow:hidden}
.bar-fill{height:100%;border-radius:4px}
.num{font-size:12px;text-align:right;font-weight:600}
.num-sub{font-size:11px;text-align:right;color:var(--muted)}
.num-sub.warn{color:#f59e0b}
.num-sub.danger{color:#ef4444}

/* yearly */
.yr-grid{display:flex;flex-direction:column;gap:9px}
.yr-row{display:grid;grid-template-columns:220px 1fr 90px;align-items:center;gap:10px}
.yr-bars{display:flex;gap:3px;height:20px}
.yr-bar{border-radius:3px;min-width:3px}
.yr-legend{display:flex;gap:16px;margin-bottom:14px}
.yr-dot{width:10px;height:10px;border-radius:2px}
.yr-lbl{font-size:11px;color:var(--muted)}

/* tabla */
.tbl-toolbar{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-bottom:12px}
#q2{background:var(--panel);border:1px solid rgba(224,1,152,.4);border-radius:7px;color:var(--txt);
    padding:5px 10px;font-size:12px;width:220px;outline:none}
#q2:focus{border-color:var(--sky)}
.filt-pills{display:flex;gap:6px;flex-wrap:wrap}
.fpill{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;
       border:1px solid rgba(224,1,152,.25);color:var(--muted);background:rgba(224,1,152,.06);
       white-space:nowrap;transition:.15s}
.fpill.on{border-color:var(--sky);color:var(--sky);background:rgba(135,195,211,.12)}
.ov{overflow-x:auto}
table{width:100%;border-collapse:collapse;font-size:12px}
th{background:rgba(0,0,0,.3);color:var(--muted);padding:8px 9px;text-align:left;
   border-bottom:1px solid rgba(255,255,255,.08);cursor:pointer;user-select:none;white-space:nowrap}
th:hover{color:var(--txt)}
td{padding:7px 9px;border-bottom:1px solid rgba(255,255,255,.04)}
tr:hover td{background:rgba(255,255,255,.03)}
.ok{color:#10b981}.warn{color:#f59e0b}.danger{color:#ef4444}
.badge{font-size:9.5px;padding:2px 6px;border-radius:10px;font-weight:700}
.badge-gap{background:rgba(239,68,68,.2);color:#ef4444}
.badge-comp{background:rgba(16,185,129,.2);color:#10b981}
.badge-sys{background:rgba(96,165,250,.2);color:#60a5fa}
.yr-mini{display:flex;gap:3px;align-items:center}
.yr-mini-b{height:14px;border-radius:2px;min-width:4px}

/* scope split */
.scope-legend{display:flex;align-items:center;gap:6px;margin-bottom:14px}
.scope-dot{width:10px;height:10px;border-radius:2px;flex:none}
.scope-lbl{font-size:11px;color:var(--muted)}
#scope-grid{display:flex;flex-direction:column;gap:0}
.scope-row{display:grid;grid-template-columns:220px 1fr 140px 140px;align-items:center;
  gap:10px;padding:9px 12px;border-radius:8px;cursor:pointer;transition:.15s;margin-bottom:2px}
.scope-row:hover{background:rgba(255,255,255,.04)}
.scope-row.active{background:rgba(224,1,152,.07);border:1px solid rgba(224,1,152,.2)}
.scope-track{height:18px;border-radius:5px;overflow:hidden;display:flex}
.scope-in{background:#E00198;height:100%}
.scope-out{background:#475569;height:100%}
.scope-num{font-size:11.5px;font-weight:700}
.scope-num.acn{color:#E00198}
.scope-num.out{color:#94a3b8}
.scope-out-detail{font-size:9px;color:var(--muted2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
/* detail panel */
.scope-detail{background:rgba(0,0,0,.25);border:1px solid rgba(224,1,152,.15);
  border-radius:10px;padding:18px 20px;margin:2px 0 10px;animation:fadeIn .18s ease}
@keyframes fadeIn{from{opacity:0;transform:translateY(-4px)}to{opacity:1;transform:translateY(0)}}
.sd-cols{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px}
.sd-col-h{font-size:10px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;
  margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid rgba(255,255,255,.08)}
.sd-col-h.acn{color:#E00198}
.sd-col-h.out{color:#94a3b8}
.sd-app-row{display:flex;justify-content:space-between;align-items:center;
  padding:5px 0;border-bottom:1px solid rgba(255,255,255,.04);font-size:11.5px}
.sd-app-name{color:var(--ink);font-weight:600}
.sd-app-name.out{color:#94a3b8;font-weight:400}
.sd-app-tix{font-size:11px;font-weight:700;color:var(--muted)}
/* tendencia in-scope */
.sd-trend-h{font-size:10px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:12px;padding-bottom:6px;border-bottom:1px solid rgba(255,255,255,.08)}
.sd-trend-grid{display:flex;flex-direction:column;gap:8px}
.sd-trend-row{display:grid;grid-template-columns:200px 1fr 70px;align-items:center;gap:10px}
.sd-yr-bars{display:flex;gap:4px;height:22px}
.sd-yr-bar{border-radius:3px;min-width:4px;transition:.2s}

/* alertas */
.al-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:12px}
.al-card{background:rgba(239,68,68,.07);border:1px solid rgba(239,68,68,.22);border-radius:9px;padding:14px}
.al-card h4{font-size:13px;font-weight:700;color:#fca5a5;margin-bottom:6px}
.al-tags{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px}
.al-tag{font-size:10px;background:rgba(255,255,255,.07);padding:2px 7px;border-radius:10px;color:var(--muted)}
.al-p90{font-size:22px;font-weight:900;color:#ef4444;line-height:1}
.al-p90 small{font-size:11px;color:var(--muted)}
"""


def build_html(conn):
    vc_rows, yearly_vc, groups, kpi, alerts, proc_by_vc_rows = load_data(conn)
    scope_by_vc = load_scope_data(conn)

    total_tks = int(kpi[0] or 0)
    total_p12 = int((kpi[1] or 0) + (kpi[2] or 0))
    p90_avg   = float(kpi[3] or 0)
    n_grupos  = int(kpi[4] or 0)

    # Mapa procesos por VC
    proc_map = {r[0]: {"n": r[1], "act": r[2], "inc": r[3]} for r in proc_by_vc_rows}
    vc_ids_with_tickets = {r[0] for r in vc_rows if r[3] and int(r[3]) > 0}
    n_sin_proc = sum(1 for vc in vc_ids_with_tickets if proc_map.get(vc, {}).get("n", 0) == 0)

    # KPIs de alcance
    total_in  = sum(v["in"]  for v in scope_by_vc.values())
    total_out = sum(v["out"] for v in scope_by_vc.values())

    stats_html = (
        stat(f"{total_tks:,}", "Tickets 2024-2026") +
        stat(f"{total_in:,}", "Tickets en alcance Accenture", "cerise") +
        stat(f"{total_out:,}", "Tickets fuera de alcance") +
        stat(f"{total_p12}", "Tickets P1+P2", "red") +
        stat(f"{p90_avg:.0f}h", "P90 promedio") +
        stat(f"{n_sin_proc}", "Eslabones sin proceso documentado", "red")
    )

    hero_html = hero(
        "Cadena de Valor · Tickets AMS",
        "Carga operativa por eslabón ETB",
        "Análisis de tickets AMS de GenWizard 2024-2026 mapeados a la cadena de valor retail. "
        "Identifica dónde vive la presión operativa real y dónde los SLAs están en riesgo.",
        "Liverpool Digital Brain · Tickets AMS",
        "OPERACIÓN",
        stats_html,
    )

    # JSON
    vc_chart = []
    for r in vc_rows:
        vc_id, vc_name, grupos, tickets, med_h, p90_h, p1, p2, crit = r
        vc_chart.append({
            "id": vc_id, "name": vc_name,
            "grupos": int(grupos or 0), "tickets": int(tickets or 0),
            "med_h": round(med_h or 0, 1), "p90_h": round(p90_h or 0, 1),
            "p1": int(p1 or 0), "p2": int(p2 or 0),
            "crit_pct": round(crit or 0, 1),
        })

    yearly = {}
    for vc_id, year, tks in yearly_vc:
        if vc_id not in yearly:
            yearly[vc_id] = {}
        yearly[vc_id][str(year)] = int(tks or 0)

    groups_json = []
    for r in groups:
        gname, vc_id, vc_name, mapping, total, p1, p2, p90_max, p90_avg_g, med_avg, crit, by_year = r
        by_year_dict = {}
        if by_year:
            for item in by_year.split("|"):
                parts = item.split(":")
                if len(parts) == 2:
                    by_year_dict[parts[0]] = int(parts[1])
        groups_json.append({
            "group": gname or "", "vc_id": vc_id or "", "vc_name": vc_name or "Sin clasificar",
            "mapping": mapping or "gap",
            "total": int(total or 0), "p1": int(p1 or 0), "p2": int(p2 or 0),
            "p90_max": round(p90_max or 0, 0), "p90_avg": round(p90_avg_g or 0, 0),
            "med": round(med_avg or 0, 1), "crit_pct": round(crit or 0, 1),
            "by_year": by_year_dict,
            "in_scope": (gname or "") in IN_SCOPE_GROUPS,
        })

    alerts_json = []
    for a in alerts:
        alerts_json.append({
            "group": a[0], "vc_id": a[1] or "",
            "year": a[2], "tickets": int(a[3] or 0),
            "p90_h": round(a[4] or 0, 0),
            "p1": int(a[5] or 0), "p2": int(a[6] or 0),
        })

    # Enriquecer vc_chart con datos de procesos críticos
    for vc in vc_chart:
        pm = proc_map.get(vc["id"], {})
        vc["n_proc"] = pm.get("n", 0)
        vc["proc_act"] = pm.get("act", 0)
        vc["proc_inc"] = pm.get("inc", 0)

    # Datos de brechas documentales (eslabones con tickets pero sin procesos)
    brechas = [
        {"id": vc["id"], "name": vc["name"], "tickets": vc["tickets"],
         "grupos": vc["grupos"], "p90_h": vc["p90_h"]}
        for vc in vc_chart
        if vc["tickets"] > 0 and vc["n_proc"] == 0
    ]
    brechas.sort(key=lambda x: -x["tickets"])

    # Scope JSON
    scope_list = []
    vc_name_map = {r[0]: r[1] for r in vc_rows}
    for vc in sorted(scope_by_vc.keys()):
        s = scope_by_vc[vc]
        total_vc = s["in"] + s["out"]
        if total_vc == 0:
            continue
        scope_list.append({
            "id": vc,
            "name": vc_name_map.get(vc, vc),
            "in": s["in"],
            "out": s["out"],
            "total": total_vc,
            "in_pct": round(s["in"] / total_vc * 100, 1),
            "out_groups": sorted(s["out_groups"], key=lambda x: -x["t"]),
        })

    vc_colors_js = json.dumps(VC_COLORS)
    vc_chart_js  = json.dumps(vc_chart, ensure_ascii=False)
    yearly_js    = json.dumps(yearly,   ensure_ascii=False)
    groups_js    = json.dumps(groups_json, ensure_ascii=False)
    alerts_js    = json.dumps(alerts_json, ensure_ascii=False)
    brechas_js   = json.dumps(brechas, ensure_ascii=False)
    scope_js     = json.dumps(scope_list, ensure_ascii=False)

    body = f"""
<div id="wrap">

<!-- S0: Alcance Accenture vs fuera de alcance -->
<div class="sec">
<div class="sec-h">
  <h2>Distribución de tickets por alcance Accenture AMS N2</h2>
  <small>En alcance (cerise) vs fuera de alcance (gris) · Clic en un eslabón para ver detalle y tendencia</small>
</div>
<div class="scope-legend">
  <div class="scope-dot" style="background:#E00198"></div>
  <span class="scope-lbl">En alcance Accenture AMS N2</span>
  <div class="scope-dot" style="background:#475569;margin-left:18px"></div>
  <span class="scope-lbl">Fuera de alcance (candidatas, otro vendor, infraestructura)</span>
</div>
<div id="scope-grid"></div>
</div>

<!-- S1: Barras por eslabón -->
<div class="sec">
<div class="sec-h">
  <h2>Carga por eslabón ETB</h2>
  <small>Tickets acumulados 2024-2026 · P90 promedio ponderado · % P1+P2 · Procesos críticos documentados</small>
</div>
<div class="vc-grid">
  <div class="vc-row" style="font-size:10px;color:var(--muted)">
    <span>Eslabón</span><span>Volumen relativo</span>
    <span style="text-align:right">Tickets</span>
    <span style="text-align:right">P90 prom.</span>
    <span style="text-align:right">Grupos</span>
    <span style="text-align:right">Crit %</span>
    <span style="text-align:right">Procesos</span>
  </div>
  <div id="vc-bars"></div>
</div>
</div>

<!-- S2: Tendencia anual -->
<div class="sec">
<div class="sec-h">
  <h2>Tendencia anual por eslabón</h2>
  <small>Distribución relativa de tickets 2024 / 2025 / 2026</small>
</div>
<div class="yr-legend">
  <div style="display:flex;align-items:center;gap:5px">
    <div class="yr-dot" style="background:#60a5fa"></div><span class="yr-lbl">2024</span>
  </div>
  <div style="display:flex;align-items:center;gap:5px">
    <div class="yr-dot" style="background:#10b981"></div><span class="yr-lbl">2025</span>
  </div>
  <div style="display:flex;align-items:center;gap:5px">
    <div class="yr-dot" style="background:#f59e0b"></div><span class="yr-lbl">2026</span>
  </div>
</div>
<div class="yr-grid" id="yr-rows"></div>
</div>

<!-- S3: Tabla de grupos -->
<div class="sec">
<div class="sec-h">
  <h2>Grupos AMS por eslabón</h2>
  <small>Filtro por eslabón · búsqueda · ordenable por columna</small>
</div>
<div class="tbl-toolbar">
  <input id="q2" type="text" placeholder="Buscar grupo AMS...">
  <div class="filt-pills" id="fpills"></div>
</div>
<div class="ov">
<table>
<thead>
<tr>
  <th onclick="sortTbl(0)">Grupo AMS</th>
  <th onclick="sortTbl(1)">Eslabón</th>
  <th onclick="sortTbl(2)">Mapeo</th>
  <th onclick="sortTbl(3)" style="text-align:right">Total</th>
  <th onclick="sortTbl(4)" style="text-align:right">P1</th>
  <th onclick="sortTbl(5)" style="text-align:right">P2</th>
  <th onclick="sortTbl(6)" style="text-align:right">P90 max (h)</th>
  <th onclick="sortTbl(7)" style="text-align:right">Med. (h)</th>
  <th onclick="sortTbl(8)" style="text-align:right">Crit %</th>
  <th>Año a año</th>
</tr>
</thead>
<tbody id="grp-tbody"></tbody>
</table>
</div>
</div>

<!-- S4: Alertas SLA -->
<div class="sec">
<div class="sec-h">
  <h2>Alertas de SLA — P90 &gt; 500h (&gt;20 días)</h2>
  <small>Grupos con tiempo de resolución en el percentil 90 superior a 20 días en algún año</small>
</div>
<div class="al-grid" id="al-grid"></div>
</div>

<!-- S5: Brechas documentales -->
<div class="sec">
<div class="sec-h">
  <h2>Brechas de cobertura documental</h2>
  <small>Eslabones con volumen de tickets operativos pero sin procesos críticos documentados — riesgo de conocimiento no capturado</small>
</div>
<div class="al-grid" id="br-grid"></div>
</div>

</div><!-- /wrap -->

<script>
const VC_COLORS = {vc_colors_js};
const VC_DATA   = {vc_chart_js};
const YEARLY    = {yearly_js};
const GROUPS    = {groups_js};
const ALERTS    = {alerts_js};
const BRECHAS   = {brechas_js};
const SCOPE     = {scope_js};
const YRC       = {{"2024":"#60a5fa","2025":"#10b981","2026":"#f59e0b"}};
const YEARS     = ["2024","2025","2026"];

// S0 — alcance Accenture vs fuera de alcance (con detalle expandible)
(function() {{
  const grid = document.getElementById("scope-grid");
  if (!grid) return;
  let activeVC = null;

  // header
  grid.innerHTML = `<div style="display:grid;grid-template-columns:220px 1fr 140px 140px;
    gap:10px;padding:4px 12px;font-size:9.5px;color:var(--muted2);margin-bottom:4px">
    <span>Eslabón</span><span>Distribución (clic para detalle)</span>
    <span>En alcance ACN</span><span>Fuera de alcance</span>
  </div>`;

  SCOPE.forEach(s => {{
    const col    = VC_COLORS[s.id] || "#64748b";
    const outPct = 100 - s.in_pct;

    // row
    const row = document.createElement("div");
    row.className = "scope-row";
    row.dataset.vc = s.id;
    row.innerHTML = `
      <span style="font-size:12px;font-weight:700;color:${{col}};white-space:nowrap;overflow:hidden;text-overflow:ellipsis"
            title="${{s.id}} ${{s.name}}">${{s.id}} ${{s.name}}</span>
      <div class="scope-track" title="ACN: ${{s.in.toLocaleString()}} · Fuera: ${{s.out.toLocaleString()}}">
        <div class="scope-in"  style="flex:${{s.in ||0.1}}"></div>
        <div class="scope-out" style="flex:${{s.out||0.1}}"></div>
      </div>
      <div>
        <div class="scope-num acn">${{s.in.toLocaleString()}}
          <span style="font-size:9px;opacity:.7">(${{s.in_pct.toFixed(0)}}%)</span></div>
      </div>
      <div>
        <div class="scope-num out">${{s.out > 0 ? s.out.toLocaleString() : "—"}}
          <span style="font-size:9px;opacity:.7">${{s.out > 0 ? "("+outPct.toFixed(0)+"%)" : ""}}</span></div>
      </div>`;

    // detail panel (initially hidden)
    const detail = document.createElement("div");
    detail.className = "scope-detail";
    detail.style.display = "none";
    detail.dataset.vc = s.id;

    row.addEventListener("click", () => {{
      const isOpen = detail.style.display !== "none";
      // close all
      grid.querySelectorAll(".scope-detail").forEach(d => d.style.display="none");
      grid.querySelectorAll(".scope-row").forEach(r => r.classList.remove("active"));
      if (!isOpen) {{
        detail.style.display = "block";
        row.classList.add("active");
        if (!detail.dataset.rendered) {{
          renderDetail(s, detail);
          detail.dataset.rendered = "1";
        }}
      }}
    }});

    grid.appendChild(row);
    grid.appendChild(detail);
  }});

  function renderDetail(s, el) {{
    const col = VC_COLORS[s.id] || "#64748b";
    // get groups for this VC
    const vcGroups = GROUPS.filter(g => g.vc_id === s.id);
    const inGroups  = vcGroups.filter(g => g.in_scope).sort((a,b) => b.total - a.total);
    const outGroups = vcGroups.filter(g => !g.in_scope).sort((a,b) => b.total - a.total);

    // build in-scope list
    const inRows = inGroups.map(g => {{
      const label = g.group.replace(/^AMS /,"");
      return `<div class="sd-app-row">
        <span class="sd-app-name">${{label}}</span>
        <span class="sd-app-tix">${{g.total.toLocaleString()}}</span>
      </div>`;
    }}).join("") || '<div style="font-size:11px;color:var(--muted)">—</div>';

    const outRows = outGroups.map(g => {{
      const label = g.group.replace(/^AMS /,"");
      return `<div class="sd-app-row">
        <span class="sd-app-name out">${{label}}</span>
        <span class="sd-app-tix">${{g.total.toLocaleString()}}</span>
      </div>`;
    }}).join("") || '<div style="font-size:11px;color:var(--muted)">—</div>';

    // trend builder (shared for in-scope and out-of-scope)
    function buildTrendRows(grpList, nameColor) {{
      return grpList.map(g => {{
        const maxY = Math.max(...YEARS.map(y => g.by_year[y]||0), 1);
        const bars = YEARS.map(y => {{
          const flex = Math.max(0.01, (g.by_year[y]||0)/maxY);
          const val  = g.by_year[y]||0;
          return `<div class="sd-yr-bar"
            title="${{y}}: ${{val.toLocaleString()}} tickets"
            style="flex:${{flex}};background:${{YRC[y]}}"></div>`;
        }}).join("");
        const label = g.group.replace(/^AMS /,"");
        return `<div class="sd-trend-row">
          <span style="font-size:11px;font-weight:600;color:${{nameColor}};white-space:nowrap;overflow:hidden;text-overflow:ellipsis"
                title="${{g.group}}">${{label}}</span>
          <div class="sd-yr-bars">${{bars}}</div>
          <span style="font-size:10px;color:var(--muted);text-align:right">${{g.total.toLocaleString()}}</span>
        </div>`;
      }}).join("");
    }}

    function buildSummaryBars(grpList, label) {{
      const totals = {{}};
      YEARS.forEach(y => {{ totals[y] = grpList.reduce((sum, g) => sum + (g.by_year[y]||0), 0); }});
      const maxT = Math.max(...Object.values(totals), 1);
      return YEARS.map(y => {{
        const w = Math.max(0.01, totals[y]/maxT);
        return `<div style="display:flex;align-items:center;gap:8px;margin-bottom:6px">
          <div class="sd-yr-bar" style="flex:none;width:${{Math.round(w*180)}}px;height:20px;
            background:${{YRC[y]}};border-radius:4px"></div>
          <span style="font-size:11px;font-weight:700;color:${{YRC[y]}}">${{y}}</span>
          <span style="font-size:11px;color:var(--muted)">${{totals[y].toLocaleString()}} tickets ${{label}}</span>
        </div>`;
      }}).join("");
    }}

    const trendRows    = buildTrendRows(inGroups, "var(--ink)");
    const summaryBars  = buildSummaryBars(inGroups, "ACN");
    const trendRowsOut = buildTrendRows(outGroups, "#94a3b8");
    const summaryBarsOut = buildSummaryBars(outGroups, "fuera alcance");

    const outTrendBlock = outGroups.length > 0 ? `
      <div class="sd-trend-h" style="color:#94a3b8;margin-top:24px">Tendencia anual — fuera de alcance</div>
      <div style="margin-bottom:18px">${{summaryBarsOut}}</div>
      <div style="font-size:10px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;
        color:#475569;margin-bottom:10px">Por aplicativo</div>
      <div class="sd-trend-grid">${{trendRowsOut}}</div>` : "";

    el.innerHTML = `
      <div style="font-size:13px;font-weight:800;color:${{col}};margin-bottom:14px">
        ${{s.id}} — ${{s.name}}
        <span style="font-size:10px;font-weight:400;color:var(--muted);margin-left:10px">
          ${{inGroups.length}} apps en alcance · ${{outGroups.length}} fuera · ${{(s.in+s.out).toLocaleString()}} tickets totales
        </span>
      </div>
      <div class="sd-cols">
        <div>
          <div class="sd-col-h acn">En alcance Accenture AMS N2 — ${{s.in.toLocaleString()}} tickets</div>
          ${{inRows}}
        </div>
        <div>
          <div class="sd-col-h out">Fuera de alcance — ${{s.out > 0 ? s.out.toLocaleString()+" tickets" : "ninguno"}}</div>
          ${{outRows}}
        </div>
      </div>
      <div class="sd-trend-h">Tendencia anual — apps en alcance Accenture</div>
      <div style="margin-bottom:18px">${{summaryBars}}</div>
      <div style="font-size:10px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;
        color:var(--muted2);margin-bottom:10px">Por aplicativo</div>
      <div class="sd-trend-grid">${{trendRows}}</div>
      ${{outTrendBlock}}`;
  }}
}})();

// S1 — barras eslabón
const maxTks = Math.max(...VC_DATA.map(v=>v.tickets), 1);
const barsEl = document.getElementById("vc-bars");
VC_DATA.forEach(v => {{
  if (!v.tickets) return;
  const pct = (v.tickets / maxTks * 100).toFixed(1);
  const col = VC_COLORS[v.id] || "#64748b";
  const p90cls = v.p90_h > 1000 ? "danger" : v.p90_h > 400 ? "warn" : "";
  const critcol = v.crit_pct > 5 ? "#ef4444" : v.crit_pct > 2 ? "#f59e0b" : "#10b981";
  const procTxt = v.n_proc > 0
    ? `<span style="color:#10b981;font-weight:700">${{v.n_proc}}</span>`
    : `<span style="color:#ef4444;font-weight:700" title="Sin procesos críticos documentados">0 ⚠</span>`;
  barsEl.innerHTML += `<div class="vc-row" style="margin-bottom:6px">
    <span class="vc-lbl" style="color:${{col}}" onclick="filterVC('${{v.id}}')"
          data-tip="${{v.id}} ${{v.name}}&#10;${{v.grupos}} grupos · ${{v.tickets.toLocaleString()}} tickets"
    >${{v.id}} ${{v.name}}</span>
    <div class="bar-track"><div class="bar-fill" style="width:${{pct}}%;background:${{col}}"></div></div>
    <span class="num">${{v.tickets.toLocaleString()}}</span>
    <span class="num-sub ${{p90cls}}">${{v.p90_h>0?v.p90_h.toFixed(0)+"h":"—"}}</span>
    <span class="num-sub">${{v.grupos}} gr.</span>
    <span class="num-sub" style="color:${{critcol}}">${{v.crit_pct.toFixed(1)}}%</span>
    <span class="num-sub" style="text-align:right">${{procTxt}}</span>
  </div>`;
}});

// S2 — tendencia anual
const yrEl = document.getElementById("yr-rows");
VC_DATA.forEach(v => {{
  if (!v.tickets) return;
  const col  = VC_COLORS[v.id] || "#64748b";
  const yr   = YEARLY[v.id] || {{}};
  const maxY = Math.max(...YEARS.map(y => yr[y]||0), 1);
  const bars = YEARS.map(y => {{
    const w = Math.max(3, ((yr[y]||0)/maxY*100));
    return `<div class="yr-bar" title="${{y}}: ${{(yr[y]||0).toLocaleString()}} tickets"
              style="flex:${{w}};background:${{YRC[y]}}"></div>`;
  }}).join("");
  const total = YEARS.reduce((s,y)=>s+(yr[y]||0),0);
  yrEl.innerHTML += `<div class="yr-row">
    <span style="font-size:12px;font-weight:700;color:${{col}};white-space:nowrap;overflow:hidden;text-overflow:ellipsis"
          data-tip="${{v.id}} ${{v.name}}">${{v.id}} ${{v.name}}</span>
    <div class="yr-bars">${{bars}}</div>
    <span style="font-size:11px;color:var(--muted);text-align:right">${{total.toLocaleString()}}</span>
  </div>`;
}});

// S3 — tabla grupos
let activeVC = null, sortCol = 3, sortAsc = false;

const fpills = document.getElementById("fpills");
function makePill(label, id) {{
  const p = document.createElement("div");
  p.className = "fpill" + (!id && !activeVC ? " on" : "");
  p.textContent = label;
  if (id) p.style.borderColor = VC_COLORS[id]||"";
  p.onclick = () => filterVC(id||null);
  fpills.appendChild(p);
}}
makePill("Todos", null);
VC_DATA.filter(v=>v.tickets).forEach(v => makePill(v.id, v.id));

function filterVC(vc) {{
  activeVC = vc;
  document.querySelectorAll(".fpill").forEach(p => p.classList.remove("on"));
  const target = vc
    ? [...document.querySelectorAll(".fpill")].find(p=>p.textContent===vc)
    : document.querySelector(".fpill");
  if (target) target.classList.add("on");
  renderTbl();
}}

function slaClass(h) {{ return h>1000?"danger":h>400?"warn":"ok"; }}
function badge(m) {{
  if (m==="gap")       return '<span class="badge badge-gap">GAP</span>';
  if (m==="component") return '<span class="badge badge-comp">SUD</span>';
  return '<span class="badge badge-sys">SYS</span>';
}}

function renderTbl() {{
  const q = document.getElementById("q2").value.toLowerCase();
  let data = GROUPS.filter(g =>
    (!activeVC || g.vc_id===activeVC) &&
    (!q || g.group.toLowerCase().includes(q) || g.vc_name.toLowerCase().includes(q))
  );
  data.sort((a,b) => {{
    const pairs = [
      [a.group,b.group],[a.vc_id,b.vc_id],[a.mapping,b.mapping],
      [a.total,b.total],[a.p1,b.p1],[a.p2,b.p2],
      [a.p90_max,b.p90_max],[a.med,b.med],[a.crit_pct,b.crit_pct]
    ];
    const [av,bv] = pairs[sortCol];
    const cmp = typeof av==="string" ? av.localeCompare(bv) : av-bv;
    return sortAsc ? cmp : -cmp;
  }});
  const tbody = document.getElementById("grp-tbody");
  tbody.innerHTML = data.map(g => {{
    const col = VC_COLORS[g.vc_id]||"#64748b";
    const p90c = slaClass(g.p90_max);
    const critcol = g.crit_pct>5?"#ef4444":g.crit_pct>2?"#f59e0b":"#10b981";
    const maxY = Math.max(...YEARS.map(y=>g.by_year[y]||0),1);
    const minibars = YEARS.map(y => {{
      const w = Math.max(5, ((g.by_year[y]||0)/maxY*40));
      return `<div class="yr-mini-b" title="${{y}}: ${{(g.by_year[y]||0).toLocaleString()}}"
                style="width:${{w}}px;background:${{YRC[y]}}"></div>`;
    }}).join("");
    return `<tr>
      <td data-tip="${{g.group}}">${{g.group}}</td>
      <td><span style="font-size:11px;font-weight:700;color:${{col}}">${{g.vc_id}}</span>
          <br><span style="font-size:9.5px;color:var(--muted)">${{g.vc_name}}</span></td>
      <td>${{badge(g.mapping)}}</td>
      <td style="text-align:right;font-weight:700">${{g.total.toLocaleString()}}</td>
      <td style="text-align:right;color:${{g.p1>0?"#ef4444":"var(--muted)"}}">${{g.p1}}</td>
      <td style="text-align:right;color:${{g.p2>0?"#f59e0b":"var(--muted)"}}">${{g.p2}}</td>
      <td style="text-align:right" class="${{p90c}}">${{g.p90_max>0?g.p90_max.toFixed(0):"—"}}</td>
      <td style="text-align:right;color:var(--muted)">${{g.med>0?g.med.toFixed(1):"—"}}</td>
      <td style="text-align:right;color:${{critcol}}">${{g.crit_pct.toFixed(1)}}%</td>
      <td><div class="yr-mini">${{minibars}}</div></td>
    </tr>`;
  }}).join("");
}}

function sortTbl(col) {{
  if (sortCol===col) sortAsc=!sortAsc; else {{ sortCol=col; sortAsc=col===0; }}
  renderTbl();
}}
document.getElementById("q2").addEventListener("input", renderTbl);
renderTbl();

// S4 — alertas SLA
const alGrid = document.getElementById("al-grid");
// S5 — brechas documentales
const brGrid = document.getElementById("br-grid");
BRECHAS.forEach(b => {{
  const col = VC_COLORS[b.id] || "#64748b";
  const dias = b.p90_h > 0 ? `P90 prom. ${{b.p90_h.toFixed(0)}}h` : "";
  brGrid.innerHTML += `<div class="al-card" style="border-color:rgba(251,191,36,.35);background:rgba(251,191,36,.06)">
    <h4 style="color:#fbbf24">${{b.id}} ${{b.name}}</h4>
    <div class="al-tags">
      <span class="al-tag">${{b.tickets.toLocaleString()}} tickets</span>
      <span class="al-tag">${{b.grupos}} grupos AMS</span>
      ${{dias?'<span class="al-tag">'+dias+'</span>':""}}
    </div>
    <div style="font-size:13px;color:#fbbf24;font-weight:700;line-height:1.4">Sin procesos críticos documentados</div>
    <div style="font-size:11px;color:var(--muted);margin-top:6px">Este eslabón acumula carga operativa real sin respaldo de proceso documentado. Riesgo: conocimiento tácito no capturado, incidentes sin runbook.</div>
  </div>`;
}});
ALERTS.forEach(a => {{
  const dias = (a.p90_h/24).toFixed(0);
  const vc   = VC_DATA.find(v=>v.id===a.vc_id);
  const vcName = vc ? vc.name : a.vc_id;
  alGrid.innerHTML += `<div class="al-card">
    <h4>${{a.group}}</h4>
    <div class="al-tags">
      <span class="al-tag">${{a.vc_id}} ${{vcName}}</span>
      <span class="al-tag">Año ${{a.year}}</span>
      <span class="al-tag">${{a.tickets.toLocaleString()}} tickets</span>
      ${{a.p1>0?'<span class="al-tag" style="color:#ef4444">P1: '+a.p1+'</span>':""}}
      ${{a.p2>0?'<span class="al-tag" style="color:#f59e0b">P2: '+a.p2+'</span>':""}}
    </div>
    <div class="al-p90">${{a.p90_h.toFixed(0)}}h <small>= ${{dias}} días al P90</small></div>
  </div>`;
}});
</script>
"""

    return page(
        "Cadena de Valor y Tickets — Liverpool Digital Brain",
        hero_html,
        body,
        extra_css=CSS,
    )


def main():
    conn = sqlite3.connect(str(DB))
    try:
        html = build_html(conn)
        OUT.write_text(html, encoding="utf-8")
        print(f"OK  {OUT}  ({OUT.stat().st_size // 1024} KB)")
    finally:
        conn.close()


if __name__ == "__main__":
    main()

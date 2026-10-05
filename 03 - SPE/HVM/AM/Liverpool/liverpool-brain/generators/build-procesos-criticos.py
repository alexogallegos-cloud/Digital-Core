#!/usr/bin/env python3
"""
Liverpool Brain — Portal: Procesos Críticos.
Genera portal/procesos-criticos-liv.html desde critical_processes + process_systems.
"""
import sqlite3
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from _liv_shared import hero, page, stat, BASE_CSS

BRAIN_PATH = Path(__file__).parent.parent / "liverpool-brain.db"
OUT = Path(__file__).parent.parent / "portal" / "procesos-criticos-liv.html"

VC_COLORS = {
    "VC-01": "#f59e0b", "VC-02": "#10b981", "VC-03": "#3b82f6",
    "VC-04": "#8b5cf6", "VC-05": "#ec4899", "VC-06": "#ef4444",
    "VC-07": "#6366f1", "VC-08": "#14b8a6", "VC-09": "#f97316",
}
VC_LABELS = {
    "VC-01": "Desarrollo de Oferta",
    "VC-02": "Cadena de Suministro",
    "VC-03": "Comercio Unificado",
    "VC-04": "Canales de Interacción",
    "VC-05": "Engagement y Marketing",
    "VC-06": "Servicios Financieros",
    "VC-07": "Fundación Empresarial",
    "VC-08": "Fundación de Información",
    "VC-09": "Analítica e Inteligencia",
}
CAT_ICONS = {
    "Back Office": "🏢",
    "Finanzas": "💳",
    "Retail": "🛍️",
    "Ola de Apps": "📱",
    "Supply Chain": "🚚",
    "Tiendas Omnicanal": "🏪",
    "Individual": "📄",
}


def _vc_buttons():
    parts = []
    for vc, c in VC_COLORS.items():
        parts.append(
            f'<button class="pill-btn" onclick="filterVC(\'{vc}\')" style="--c:{c}">{vc}</button>'
        )
    return "".join(parts)


def build():
    conn = sqlite3.connect(BRAIN_PATH)
    conn.row_factory = sqlite3.Row

    # ── KPIs ──────────────────────────────────────────────────────────────────
    total_proc = conn.execute("SELECT COUNT(*) FROM critical_processes").fetchone()[0]
    total_sys  = conn.execute("SELECT COUNT(DISTINCT system_name) FROM process_systems").fetchone()[0]
    new_disc   = conn.execute(
        "SELECT COUNT(*) FROM components WHERE seeded_by LIKE '%Procesos Críticos%'"
    ).fetchone()[0]
    total_act  = conn.execute(
        "SELECT COALESCE(SUM(activities_count),0) FROM critical_processes"
    ).fetchone()[0]
    total_inc  = conn.execute(
        "SELECT COALESCE(SUM(incidents_count),0) FROM critical_processes"
    ).fetchone()[0]

    hero_html = hero(
        label="Liverpool · Procesos Críticos",
        h1="Procesos Críticos",
        sub="43 flujos de negocio levantados — mapeados al ETB y a sistemas del landscape",
        crumb="Portal → Procesos Críticos",
        badge="PROCESOS",
        stats_html=(
            stat(str(total_proc), "Flujos documentados", "blue") +
            stat(str(total_sys), "Sistemas involucrados", "teal") +
            stat(str(new_disc), "Sistemas nuevos (Regla B8)", "red") +
            stat(str(total_act), "Actividades mapeadas", "amber") +
            stat(str(total_inc), "Incidentes documentados", "purple")
        ),
    )

    # ── S1: Tabla de procesos por categoría ───────────────────────────────────
    cats = conn.execute("""
        SELECT category, COUNT(*) as n,
               GROUP_CONCAT(DISTINCT vc_id) as vcs
        FROM critical_processes
        GROUP BY category ORDER BY n DESC
    """).fetchall()

    s1_cards = ""
    for cat in cats:
        icon = CAT_ICONS.get(cat["category"], "📋")
        vcs_html = ""
        for vc in (cat["vcs"] or "").split(","):
            vc = vc.strip()
            color = VC_COLORS.get(vc, "#94a3b8")
            label = VC_LABELS.get(vc, vc)
            vcs_html += f'<span class="vc-badge" style="background:{color}">{vc} {label}</span>'

        procs = conn.execute("""
            SELECT process_id, process_name, business_group, description,
                   vc_id, brand, activities_count, incidents_count
            FROM critical_processes WHERE category = ? ORDER BY process_id
        """, (cat["category"],)).fetchall()

        rows = ""
        for p in procs:
            vc_color = VC_COLORS.get(p["vc_id"], "#94a3b8")
            vc_label = VC_LABELS.get(p["vc_id"], p["vc_id"])
            act_badge = f'<span class="act-badge">{p["activities_count"]} act.</span>' if p["activities_count"] else ""
            inc_badge = f'<span class="inc-badge">{p["incidents_count"]} inc.</span>' if p["incidents_count"] else ""

            # Sistemas del proceso
            sys_names = conn.execute(
                "SELECT system_name, component_id, is_cataloged FROM process_systems WHERE process_id = ?",
                (p["process_id"],)
            ).fetchall()
            sys_pills = ""
            for s in sys_names:
                cls = "sys-cat" if s["is_cataloged"] else "sys-new"
                sys_pills += f'<span class="{cls}">{s["system_name"]}</span>'

            rows += f"""
            <tr data-vc="{p['vc_id']}" data-brand="{p['brand']}">
              <td class="pid">{p['process_id']}</td>
              <td>
                <div class="proc-name">{p['process_name']}</div>
                <div class="proc-group">{p['business_group']}</div>
              </td>
              <td><div class="proc-desc">{p['description']}</div></td>
              <td><span class="vc-chip" style="background:{vc_color}">{p['vc_id']}</span><div class="vc-name">{vc_label}</div></td>
              <td><span class="brand-chip brand-{p['brand'].lower()}">{p['brand']}</span></td>
              <td>{act_badge}{inc_badge}</td>
              <td class="sys-cell">{sys_pills}</td>
            </tr>"""

        s1_cards += f"""
        <div class="cat-card">
          <div class="cat-header">
            <span class="cat-icon">{icon}</span>
            <span class="cat-title">{cat['category']}</span>
            <span class="cat-count">{cat['n']} procesos</span>
          </div>
          <div class="cat-vcs">{vcs_html}</div>
          <div class="table-wrap">
          <table class="proc-table" id="tbl-{cat['category'].replace(' ','-')}">
            <thead><tr>
              <th>ID</th><th>Proceso</th><th>Descripción</th>
              <th>ETB</th><th>Marca</th><th>Vol.</th><th>Sistemas</th>
            </tr></thead>
            <tbody>{rows}</tbody>
          </table>
          </div>
        </div>"""

    s1 = f"""
    <section>
      <h2>Procesos críticos por categoría</h2>
      <div class="filter-bar">
        <span>Filtrar por ETB:</span>
        {_vc_buttons()}
        <button class="pill-btn" onclick="filterVC(null)">Todo</button>
      </div>
      {s1_cards}
    </section>"""

    # ── S2: Sistemas nuevos descubiertos (Regla B8) ───────────────────────────
    new_systems = conn.execute("""
        SELECT c.id, c.name, c.togaf_type, c.domain_id, c.description,
               COUNT(ps.id) as process_count
        FROM components c
        LEFT JOIN process_systems ps ON ps.system_name LIKE '%' || SUBSTR(c.id,5) || '%'
        WHERE c.seeded_by LIKE '%Procesos Críticos%'
        GROUP BY c.id ORDER BY process_count DESC
    """).fetchall()

    new_rows = ""
    for ns in new_systems:
        procs_using = conn.execute("""
            SELECT cp.process_name FROM process_systems ps
            JOIN critical_processes cp ON cp.process_id = ps.process_id
            WHERE ps.component_id = ? OR ps.system_name LIKE ?
        """, (ns["id"], f"%{ns['name'].split('—')[0].strip()}%")).fetchall()
        proc_list = ", ".join(p["process_name"] for p in procs_using) or "—"

        new_rows += f"""
        <tr>
          <td class="sys-id">{ns['id']}</td>
          <td><strong>{ns['name']}</strong></td>
          <td><span class="togaf-badge">{ns['togaf_type']}</span></td>
          <td>{ns['description']}</td>
          <td class="proc-refs">{proc_list}</td>
        </tr>"""

    s2 = f"""
    <section>
      <h2>Sistemas nuevos descubiertos — Regla B8</h2>
      <p class="section-desc">Sistemas que aparecen en procesos críticos documentados pero no estaban en el catálogo de componentes. Por Regla B8, la evidencia operativa prueba su existencia en producción.</p>
      <div class="table-wrap">
      <table class="sys-table">
        <thead><tr><th>ID</th><th>Sistema</th><th>TOGAF</th><th>Descripción</th><th>Procesos que lo usan</th></tr></thead>
        <tbody>{new_rows}</tbody>
      </table>
      </div>
    </section>"""

    # ── S3: Cobertura ETB por cadena de valor ─────────────────────────────────
    vc_coverage = conn.execute("""
        SELECT vc_id,
               COUNT(*) as process_count,
               SUM(COALESCE(activities_count,0)) as total_activities,
               SUM(COALESCE(incidents_count,0)) as total_incidents,
               GROUP_CONCAT(DISTINCT brand) as brands,
               GROUP_CONCAT(DISTINCT category) as cats
        FROM critical_processes
        GROUP BY vc_id ORDER BY vc_id
    """).fetchall()

    vc_bars = ""
    max_n = max(r["process_count"] for r in vc_coverage) if vc_coverage else 1
    for vc in vc_coverage:
        color = VC_COLORS.get(vc["vc_id"], "#94a3b8")
        label = VC_LABELS.get(vc["vc_id"], vc["vc_id"])
        pct = int(vc["process_count"] / max_n * 100)
        act_txt = f' · {vc["total_activities"]} actividades' if vc["total_activities"] else ""
        inc_txt = f' · {vc["total_incidents"]} incidentes' if vc["total_incidents"] else ""
        vc_bars += f"""
        <div class="vc-row">
          <div class="vc-label">
            <span class="vc-chip" style="background:{color}">{vc['vc_id']}</span>
            <span class="vc-lname">{label}</span>
          </div>
          <div class="bar-track">
            <div class="bar-fill" style="width:{pct}%;background:{color}"></div>
          </div>
          <div class="vc-meta">
            <strong>{vc['process_count']}</strong> procesos{act_txt}{inc_txt}
          </div>
        </div>"""

    s3 = f"""
    <section>
      <h2>Distribución de procesos por eslabón ETB</h2>
      <p class="section-desc">Cada proceso crítico refuerza la evidencia de cobertura del eslabón ETB correspondiente.</p>
      <div class="vc-bars">{vc_bars}</div>
    </section>"""

    CSS = BASE_CSS + """
    .filter-bar { display:flex; gap:.5rem; align-items:center; flex-wrap:wrap; margin-bottom:1.5rem; }
    .pill-btn {
        border:none; padding:.3rem .8rem; border-radius:999px; cursor:pointer;
        background:color-mix(in srgb, var(--c) 20%, white);
        color:color-mix(in srgb, var(--c) 80%, black);
        font-size:.8rem; font-weight:600;
    }
    .pill-btn:hover { background:var(--c); color:white; }
    .cat-card { background:white; border-radius:.75rem; padding:1.5rem; margin-bottom:2rem; box-shadow:0 1px 4px rgba(0,0,0,.08); }
    .cat-header { display:flex; align-items:center; gap:.75rem; margin-bottom:.75rem; }
    .cat-icon { font-size:1.5rem; }
    .cat-title { font-size:1.1rem; font-weight:700; color:#1e293b; }
    .cat-count { margin-left:auto; background:#f1f5f9; padding:.2rem .6rem; border-radius:999px; font-size:.8rem; color:#64748b; }
    .cat-vcs { display:flex; gap:.5rem; flex-wrap:wrap; margin-bottom:1rem; }
    .vc-badge { padding:.2rem .6rem; border-radius:999px; color:white; font-size:.75rem; font-weight:600; }
    .proc-table { width:100%; border-collapse:collapse; font-size:.82rem; }
    .proc-table th { background:#f8fafc; color:#64748b; font-weight:600; text-align:left; padding:.5rem .75rem; border-bottom:2px solid #e2e8f0; }
    .proc-table td { padding:.5rem .75rem; border-bottom:1px solid #f1f5f9; vertical-align:top; }
    .proc-table tr:hover td { background:#f8fafc; }
    .proc-table tr.hidden { display:none; }
    .pid { font-family:monospace; font-size:.75rem; color:#64748b; white-space:nowrap; }
    .proc-name { font-weight:600; color:#1e293b; }
    .proc-group { font-size:.75rem; color:#94a3b8; margin-top:.15rem; }
    .proc-desc { font-size:.78rem; color:#475569; max-width:280px; }
    .vc-chip { color:white; font-size:.72rem; font-weight:700; padding:.2rem .4rem; border-radius:.25rem; }
    .vc-name { font-size:.7rem; color:#64748b; margin-top:.2rem; }
    .brand-chip { font-size:.72rem; font-weight:700; padding:.2rem .4rem; border-radius:.25rem; }
    .brand-liv { background:#e0f2fe; color:#0369a1; }
    .brand-sbb { background:#fce7f3; color:#9d174d; }
    .brand-both { background:#dcfce7; color:#166534; }
    .act-badge { background:#fef3c7; color:#92400e; font-size:.7rem; padding:.1rem .35rem; border-radius:.25rem; margin-right:.2rem; }
    .inc-badge { background:#fee2e2; color:#991b1b; font-size:.7rem; padding:.1rem .35rem; border-radius:.25rem; }
    .sys-cell { max-width:200px; }
    .sys-cat { display:inline-block; background:#dbeafe; color:#1d4ed8; font-size:.68rem; padding:.1rem .3rem; border-radius:.2rem; margin:.1rem .1rem 0 0; }
    .sys-new { display:inline-block; background:#fef9c3; color:#a16207; font-size:.68rem; padding:.1rem .3rem; border-radius:.2rem; margin:.1rem .1rem 0 0; border:1px dashed #a16207; }
    .table-wrap { overflow-x:auto; }
    /* S2 */
    .sys-table { width:100%; border-collapse:collapse; font-size:.82rem; }
    .sys-table th { background:#f8fafc; color:#64748b; font-weight:600; text-align:left; padding:.5rem .75rem; border-bottom:2px solid #e2e8f0; }
    .sys-table td { padding:.5rem .75rem; border-bottom:1px solid #f1f5f9; vertical-align:top; }
    .sys-id { font-family:monospace; font-size:.75rem; color:#64748b; }
    .togaf-badge { background:#ede9fe; color:#5b21b6; font-size:.72rem; padding:.2rem .4rem; border-radius:.25rem; }
    .proc-refs { font-size:.75rem; color:#475569; }
    /* S3 */
    .vc-bars { display:flex; flex-direction:column; gap:.75rem; }
    .vc-row { display:grid; grid-template-columns:14rem 1fr 16rem; align-items:center; gap:1rem; }
    .vc-label { display:flex; align-items:center; gap:.5rem; }
    .vc-lname { font-size:.82rem; color:#475569; }
    .bar-track { background:#f1f5f9; border-radius:999px; height:.75rem; overflow:hidden; }
    .bar-fill { height:100%; border-radius:999px; transition:width .3s; }
    .vc-meta { font-size:.8rem; color:#64748b; }
    section { margin-bottom:3rem; }
    section h2 { font-size:1.1rem; font-weight:700; color:#1e293b; margin-bottom:.5rem; }
    .section-desc { color:#64748b; font-size:.85rem; margin-bottom:1.25rem; }
    """

    JS = """
    function filterVC(vc) {
        document.querySelectorAll('.proc-table tbody tr').forEach(tr => {
            if (!vc || tr.dataset.vc === vc) tr.classList.remove('hidden');
            else tr.classList.add('hidden');
        });
        // Hide cat-cards that become empty
        document.querySelectorAll('.cat-card').forEach(card => {
            const visible = card.querySelectorAll('tbody tr:not(.hidden)').length;
            card.style.display = visible === 0 ? 'none' : '';
        });
    }
    """

    body = s1 + s2 + s3
    html = page(
        title="Procesos Críticos — Liverpool Brain",
        hero_html=hero_html,
        body_html=body,
        extra_css=CSS,
        script=JS,
    )

    OUT.parent.mkdir(exist_ok=True)
    OUT.write_text(html, encoding="utf-8")
    conn.close()
    print(f"generado: {OUT.name}  ({OUT.stat().st_size:,} bytes)")


if __name__ == "__main__":
    build()

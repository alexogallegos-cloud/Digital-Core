#!/usr/bin/env python3
"""
build-ams-applications.py — Genera portal/ams-applications-liv.html
SPE-AM-003 · Catálogo oficial de aplicaciones bajo soporte AMS de Liverpool.

78 apps · 7 dominios de negocio · mapeo a eslabones ETB · flag Apigee/BTP

Ejecutar desde liverpool-brain/:
    python generators/build-ams-applications.py
"""

import sqlite3
import html as html_mod
from pathlib import Path
from datetime import date
from _liv_shared import hero, page, stat, BASE_CSS

BASE_DIR = Path(__file__).parent.parent
DB_PATH  = BASE_DIR / "liverpool-brain.db"
OUT_PATH = BASE_DIR / "portal" / "ams-applications-liv.html"

VC_COLORS = {
    "VC-01": "#87C3D3", "VC-02": "#96CCEE", "VC-03": "#DA7AB0",
    "VC-04": "#E00198", "VC-05": "#c084fc", "VC-06": "#fbbf24",
    "VC-07": "#9a7d92", "VC-08": "#64748b", "VC-09": "#6ee7b7",
}
VC_NAMES = {
    "VC-01": "Desarrollo de Oferta",     "VC-02": "Cadena de Suministro",
    "VC-03": "Comercio Unificado",        "VC-04": "Canales de Interacción",
    "VC-05": "Engagement y Marketing",   "VC-06": "Servicios Financieros",
    "VC-07": "Fundación Empresarial",    "VC-08": "Fundación de Información",
    "VC-09": "Analítica e Inteligencia",
}


def esc(s):
    return html_mod.escape(str(s or ""), quote=True)


def load_data(conn):
    apps = conn.execute("""
        SELECT app_id, app_name, ams_domain, domain_id, vc_id,
               in_scope_apigee, nombre_anterior, matched_sources, is_new
        FROM ams_applications ORDER BY vc_id, ams_domain, app_name
    """).fetchall()

    by_vc = {}
    for row in apps:
        vc = row[4] or "VC-07"
        by_vc.setdefault(vc, []).append(row)

    totals = conn.execute("""
        SELECT COUNT(*), SUM(in_scope_apigee), SUM(is_new)
        FROM ams_applications
    """).fetchone()

    by_domain = conn.execute("""
        SELECT ams_domain, COUNT(*) n FROM ams_applications
        GROUP BY ams_domain ORDER BY n DESC
    """).fetchall()

    return apps, by_vc, totals, by_domain


def _vc_pills(by_vc):
    parts = []
    for vc, c in VC_COLORS.items():
        n = len(by_vc.get(vc, []))
        if n == 0:
            continue
        parts.append(
            f'<button class="vc-pill" onclick="filterVC(\'{vc}\')" style="--c:{c}">'
            f'{vc} <span class="vc-n">{n}</span></button>'
        )
    return "".join(parts)


def build_html(apps, by_vc, totals, by_domain):
    today     = str(date.today())
    n_total   = totals[0] or 0
    n_scope   = totals[1] or 0
    n_new     = totals[2] or 0
    n_matched = n_total - n_new

    # ── Stats hero ───────────────────────────────────────────────────────────
    stats = (
        stat(str(n_total),   "Apps en catálogo AMS") +
        stat(str(n_scope),   "In scope Apigee/BTP", "cerise") +
        stat(str(n_matched), "Confirmadas en brain", "sky") +
        stat(str(n_new),     "Nuevas (Regla B8)", "rose")
    )

    # ── VC filter pills ───────────────────────────────────────────────────────
    vc_pills = _vc_pills(by_vc)

    # ── Tabla de apps ────────────────────────────────────────────────────────
    rows_html = ""
    for row in apps:
        app_id, app_name, ams_domain, domain_id, vc_id, in_scope, nombre_ant, matched, is_new = row
        vc = vc_id or "VC-07"
        color = VC_COLORS.get(vc, "#9a7d92")
        scope_badge = (
            '<span class="scope-badge">◈ Apigee/BTP</span>' if in_scope else ""
        )
        new_badge = (
            '<span class="new-badge">+ Nuevo</span>' if is_new else ""
        )
        ant_badge = (
            f'<span class="ant-badge">← {esc(nombre_ant)}</span>' if nombre_ant else ""
        )
        rows_html += f"""
        <tr class="app-row" data-vc="{esc(vc)}">
          <td><span class="app-name">{esc(app_name)}</span>{ant_badge}{new_badge}</td>
          <td><span class="domain-tag">{esc(ams_domain)}</span></td>
          <td><span class="did-tag">{esc(domain_id or "")}</span></td>
          <td><span class="vc-tag" style="--c:{color}">{esc(vc)}</span>
              <span class="vc-name">{esc(VC_NAMES.get(vc,''))}</span></td>
          <td>{scope_badge}</td>
        </tr>"""

    # ── Distribución por dominio ──────────────────────────────────────────────
    dom_bars = ""
    max_n = max(r[1] for r in by_domain) if by_domain else 1
    for dom, n in by_domain:
        pct = int(n * 100 / max_n)
        dom_bars += f"""
        <div class="dom-bar-row">
          <div class="dom-label">{esc(dom)}</div>
          <div class="dom-bar"><div class="dom-fill" style="width:{pct}%"></div></div>
          <div class="dom-n">{n}</div>
        </div>"""

    # ── Scope Apigee/BTP list ─────────────────────────────────────────────────
    scope_rows = ""
    for row in apps:
        if row[5]:
            vc = row[4] or "VC-07"
            color = VC_COLORS.get(vc, "#9a7d92")
            scope_rows += f"""
            <div class="scope-card">
              <div class="sc-name">{esc(row[1])}</div>
              <div class="sc-meta"><span class="vc-tag" style="--c:{color}">{esc(vc)}</span>
              <span style="color:var(--muted2);font-size:9px">{esc(row[2])}</span></div>
            </div>"""

    content = page("S1", "Catálogo de Aplicaciones AMS", f"""
      <div class="filter-bar">
        <button class="vc-pill all-btn active" onclick="filterVC('ALL')">Todos</button>
        {vc_pills}
      </div>
      <table class="app-table" id="app-table">
        <thead>
          <tr>
            <th>Aplicación</th><th>Dominio AMS</th><th>Dom. Retail</th>
            <th>Eslabón ETB</th><th>Apigee/BTP</th>
          </tr>
        </thead>
        <tbody>{rows_html}</tbody>
      </table>
    """) + page("S2", "Distribución por Dominio de Negocio", f"""
      <div class="dom-bars">{dom_bars}</div>
    """) + page("S3", "In Scope — Integración Apigee / SAP BTP", f"""
      <p style="font-size:11px;color:var(--muted);margin-bottom:14px">
        {n_scope} aplicaciones identificadas como candidatas a integración vía Apigee API Management o SAP BTP.
      </p>
      <div class="scope-grid">{scope_rows}</div>
    """)

    css_extra = """
.filter-bar{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:18px}
.vc-pill{font-size:9px;font-weight:800;padding:5px 12px;border-radius:20px;cursor:pointer;border:none;
  font-family:inherit;background:rgba(255,255,255,.06);color:var(--c,#87C3D3);
  border:1px solid color-mix(in srgb,var(--c,#87C3D3) 35%,transparent);transition:.18s}
.vc-pill:hover,.vc-pill.active{background:color-mix(in srgb,var(--c,#87C3D3) 18%,transparent);
  border-color:color-mix(in srgb,var(--c,#87C3D3) 55%,transparent)}
.vc-pill .vc-n{font-size:8px;opacity:.7;margin-left:4px}
.all-btn{--c:#E00198}

.app-table{width:100%;border-collapse:collapse;font-size:11px}
.app-table th{font-size:8.5px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;
  color:var(--muted2);border-bottom:1px solid rgba(255,255,255,.07);padding:8px 10px;text-align:left}
.app-table td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,.04);vertical-align:middle}
.app-row:hover td{background:rgba(255,255,255,.025)}
.app-row.hidden{display:none}
.app-name{font-weight:700;color:var(--ink)}
.scope-badge{font-size:8px;font-weight:800;color:#E00198;background:rgba(224,1,152,.12);
  border:1px solid rgba(224,1,152,.25);padding:2px 7px;border-radius:5px;margin-left:6px}
.new-badge{font-size:8px;font-weight:800;color:#4ade80;background:rgba(74,222,128,.1);
  border:1px solid rgba(74,222,128,.2);padding:2px 7px;border-radius:5px;margin-left:6px}
.ant-badge{font-size:8px;color:var(--muted2);margin-left:6px}
.domain-tag{font-size:9px;color:var(--muted2)}
.did-tag{font-size:9px;font-weight:700;color:var(--muted);background:rgba(255,255,255,.05);
  padding:2px 6px;border-radius:4px}
.vc-tag{font-size:8.5px;font-weight:800;padding:2px 7px;border-radius:5px;
  background:color-mix(in srgb,var(--c,#87C3D3) 12%,transparent);
  border:1px solid color-mix(in srgb,var(--c,#87C3D3) 30%,transparent);
  color:var(--c,#87C3D3)}
.vc-name{font-size:9px;color:var(--muted2);margin-left:5px}

.dom-bars{display:flex;flex-direction:column;gap:10px}
.dom-bar-row{display:flex;align-items:center;gap:12px}
.dom-label{font-size:10.5px;color:var(--muted);width:220px;flex:none;text-align:right}
.dom-bar{flex:1;height:14px;background:rgba(255,255,255,.05);border-radius:7px;overflow:hidden}
.dom-fill{height:100%;background:linear-gradient(90deg,rgba(135,195,211,.6),rgba(224,1,152,.5));border-radius:7px}
.dom-n{font-size:10.5px;font-weight:800;color:var(--muted);width:24px}

.scope-grid{display:flex;flex-wrap:wrap;gap:10px}
.scope-card{background:rgba(224,1,152,.07);border:1px solid rgba(224,1,152,.18);
  border-radius:10px;padding:12px 15px;min-width:200px;flex:1}
.sc-name{font-size:12px;font-weight:800;color:var(--ink);margin-bottom:5px}
.sc-meta{display:flex;align-items:center;gap:8px}
"""

    tip_js = """
<script>
function filterVC(vc) {
  document.querySelectorAll('.vc-pill').forEach(function(b){b.classList.remove('active')});
  var btn = vc==='ALL'
    ? document.querySelector('.all-btn')
    : document.querySelector('.vc-pill[onclick*="'+vc+'"]');
  if(btn) btn.classList.add('active');
  document.querySelectorAll('.app-row').forEach(function(r){
    r.classList.toggle('hidden', vc!=='ALL' && r.dataset.vc !== vc);
  });
}
</script>"""

    return hero(
        label="SPE-AM-003 · Catálogo AMS",
        h1="Aplicaciones AMS<br>Liverpool",
        sub=f"Catálogo oficial de las {n_total} aplicaciones bajo soporte AMS de Liverpool. "
            f"Mapeadas a 7 dominios de negocio y a los eslabones ETB. "
            f"{n_scope} apps candidatas a integración Apigee / SAP BTP.",
        crumb="Brain · Catálogo AMS",
        badge=f"{n_total} apps",
        stats_html=stats,
    ) + f"""
<style>{css_extra}</style>
{content}
{tip_js}
<footer style="padding:32px 0 16px;text-align:center;color:#9a7d92;font-size:11.5px;line-height:1.8">
  <p>Liverpool Brain · SPE-AM-003 · Generado el {today}</p>
  <p>Fuente: <code style="color:#c4a8bc;background:rgba(224,1,152,.10);border:1px solid rgba(224,1,152,.2);border-radius:5px;padding:1px 6px">source/AMS Info/AMS_Applications 1.xlsx</code></p>
</footer>
</div></body></html>"""


def main():
    if not DB_PATH.exists():
        print(f"ERROR: {DB_PATH.name} no encontrado.")
        return

    conn = sqlite3.connect(DB_PATH)
    try:
        apps, by_vc, totals, by_domain = load_data(conn)
    except Exception as e:
        print(f"ERROR al leer ams_applications: {e}")
        conn.close()
        return

    html = build_html(apps, by_vc, totals, by_domain)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(html, encoding="utf-8")

    sz = OUT_PATH.stat().st_size
    print(f"generado: ams-applications-liv.html  ({sz:,} bytes)")
    print(f"  {totals[0]} apps · {totals[1]} Apigee/BTP · {totals[2]} nuevas (Regla B8)")
    print(f"  http://localhost:8002/ams-applications-liv.html")

    conn.close()


if __name__ == "__main__":
    main()

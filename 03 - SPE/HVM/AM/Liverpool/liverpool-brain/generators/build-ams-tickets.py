#!/usr/bin/env python3
"""
Liverpool — Vista de carga operativa AMS: portal/ams-tickets-liv.html

Lee liverpool-brain.db (tablas ams_groups, ams_group_component, app_operational_load,
ticket_recurrence, ticket_monthly) y genera la vista que cruza el volumen real de
tickets contra las aplicaciones catalogadas del brain.

Correr después de load-tickets-to-brain.py y build-etb-coverage.py.
"""
import html as H
import json
import sqlite3
from pathlib import Path

from _liv_shared import hero, page, stat

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"
OUT   = BRAIN / "portal" / "ams-tickets-liv.html"

CSS = """
#wrap{flex:1;overflow-y:auto;padding:22px 26px 60px}
.sec{margin-bottom:34px}
.sec-h{display:flex;align-items:baseline;gap:12px;margin-bottom:6px}
.sec-h h2{font-size:17px;font-weight:800;letter-spacing:-.02em}
.sec-h .n{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;
  color:var(--pink);background:rgba(224,1,152,.1);border:1px solid rgba(224,1,152,.28);
  border-radius:20px;padding:2px 9px}
.sec-p{font-size:12.5px;color:var(--muted);line-height:1.6;max-width:96ch;margin-bottom:16px}
table{width:100%;border-collapse:collapse;font-size:12px}
th{text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.09em;text-transform:uppercase;
  color:var(--muted2);padding:8px 10px;border-bottom:1px solid var(--line);position:sticky;top:0;
  background:var(--bg);z-index:2}
th.num,td.num{text-align:right;font-variant-numeric:tabular-nums}
td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,.045);vertical-align:middle}
tr:hover td{background:rgba(224,1,152,.05)}
.app{font-weight:700;color:var(--ink)}
.sys{font-size:10.5px;color:var(--muted2)}
.bar{height:6px;border-radius:4px;background:linear-gradient(90deg,var(--pink),var(--rose));min-width:2px}
.barw{background:rgba(255,255,255,.05);border-radius:4px;overflow:hidden;width:150px}
.tag{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;
  padding:2px 7px;border-radius:10px;border:1px solid}
.t-core{color:#fca5a5;border-color:rgba(252,165,165,.3);background:rgba(252,165,165,.1)}
.t-processors{color:var(--pink);border-color:rgba(224,1,152,.3);background:rgba(224,1,152,.1)}
.t-channels{color:var(--sky);border-color:rgba(135,195,211,.3);background:rgba(135,195,211,.1)}
.t-data{color:#c4b5fd;border-color:rgba(196,181,253,.3);background:rgba(196,181,253,.1)}
.t-integration{color:#fcd34d;border-color:rgba(252,211,77,.3);background:rgba(252,211,77,.1)}
.t-gap{color:#f87171;border-color:rgba(248,113,113,.4);background:rgba(248,113,113,.12)}
.gapcard{background:rgba(248,113,113,.06);border:1px solid rgba(248,113,113,.22);border-radius:12px;
  padding:14px 16px;margin-bottom:10px;display:flex;align-items:center;gap:16px}
.gapcard .gn{font-size:21px;font-weight:900;color:#f87171;font-variant-numeric:tabular-nums;min-width:74px}
.gapcard .gt{font-weight:700;font-size:13px}
.gapcard .gd{font-size:11.5px;color:var(--muted);margin-top:3px;line-height:1.5}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
@media(max-width:1000px){.grid2{grid-template-columns:1fr}}
.rec{padding:9px 12px;border-bottom:1px solid rgba(255,255,255,.045);display:flex;gap:12px;align-items:baseline}
.rec .rn{font-size:13px;font-weight:800;color:var(--pink);font-variant-numeric:tabular-nums;min-width:48px;text-align:right}
.rec .rk{flex:1;font-size:11.5px;color:var(--txt);line-height:1.45}
.rec .rg{font-size:9.5px;color:var(--muted2);white-space:nowrap}
.hidden{display:none}
"""

JS = """
const q=document.getElementById('q');
q.addEventListener('input',()=>{
  const v=q.value.toLowerCase().trim();
  let shown=0;
  document.querySelectorAll('#apptbl tbody tr').forEach(tr=>{
    const hit=!v||tr.dataset.k.includes(v);
    tr.classList.toggle('hidden',!hit); if(hit)shown++;
  });
  document.getElementById('info').textContent=shown+' aplicaciones visibles';
});
"""


def fnum(n):
    return f"{n:,}".replace(",", ",") if n is not None else "0"


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    apps = c.execute("""SELECT app_key, app_name, domain_id, togaf_type, ams_groups,
                               tickets, recurrent, prio_critica, prio_alta, worst_p90_hours
                        FROM app_operational_load ORDER BY tickets DESC""").fetchall()
    gaps = c.execute("""SELECT group_name, tickets FROM ams_group_component
                        WHERE mapping='gap' ORDER BY tickets DESC""").fetchall()
    recs = c.execute("""SELECT recurrence_key, group_name, occurrences, first_date, last_date
                        FROM ticket_recurrence ORDER BY occurrences DESC LIMIT 25""").fetchall()

    total_corpus = c.execute("SELECT COUNT(*) FROM ticket_corpus").fetchone()[0]
    n_groups     = c.execute("SELECT COUNT(*) FROM ams_groups WHERE is_noise=0").fetchone()[0]
    n_rec        = c.execute("SELECT COUNT(*) FROM ticket_recurrence").fetchone()[0]
    tot_t        = c.execute("SELECT SUM(tickets) FROM ams_group_component").fetchone()[0] or 0
    map_t        = c.execute("SELECT SUM(tickets) FROM ams_group_component WHERE mapping!='gap'").fetchone()[0] or 0
    gap_t        = tot_t - map_t
    pct          = round(100 * map_t / tot_t, 1) if tot_t else 0

    maxt = max((a["tickets"] or 0) for a in apps) if apps else 1

    # ── tabla de aplicaciones ─────────────────────────────────────────────
    rows = []
    for a in apps:
        tt = a["togaf_type"] or "gap"
        w = int(100 * (a["tickets"] or 0) / maxt)
        crit = (a["prio_critica"] or 0) + (a["prio_alta"] or 0)
        p90 = a["worst_p90_hours"]
        p90s = f"{p90:,.0f}" if p90 else "—"
        key = f'{a["app_name"]} {a["app_key"]} {tt} {a["domain_id"] or ""}'.lower()
        rows.append(f"""<tr data-k="{H.escape(key)}">
  <td><div class="app">{H.escape(a['app_name'] or a['app_key'])}</div>
      <div class="sys">{H.escape(a['app_key'])}</div></td>
  <td><span class="tag t-{tt}">{tt}</span></td>
  <td>{a['domain_id'] or '—'}</td>
  <td class="num">{fnum(a['tickets'])}</td>
  <td><div class="barw"><div class="bar" style="width:{w}%"></div></div></td>
  <td class="num">{fnum(a['recurrent'])}</td>
  <td class="num">{crit or '—'}</td>
  <td class="num">{p90s}</td>
  <td class="num">{a['ams_groups']}</td></tr>""")

    # ── brechas de inventario ─────────────────────────────────────────────
    gap_html = []
    for g in gaps:
        gap_html.append(f"""<div class="gapcard"><div class="gn">{fnum(g['tickets'])}</div>
  <div><div class="gt">{H.escape(g['group_name'])}</div>
  <div class="gd">Este grupo de soporte atiende tickets de forma continua, pero no existe
  una aplicación catalogada en el brain que le corresponda.</div></div></div>""")

    # ── recurrencias ──────────────────────────────────────────────────────
    rec_html = []
    for r in recs:
        ventana = ""
        if r["first_date"] and r["last_date"]:
            ventana = f"{r['first_date'][:7]} a {r['last_date'][:7]}"
        rec_html.append(f"""<div class="rec"><div class="rn">{fnum(r['occurrences'])}</div>
  <div class="rk">{H.escape((r['recurrence_key'] or '')[:110])}</div>
  <div class="rg">{H.escape(r['group_name'] or '')}<br>{ventana}</div></div>""")

    stats = (stat(fnum(total_corpus), "Tickets") + stat(n_groups, "Grupos AMS") +
             stat(f"{pct}%", "Volumen mapeado", "pink") +
             stat(fnum(gap_t), "Sin aplicación", "red") +
             stat(fnum(n_rec), "Patrones"))

    hero_html = hero(
        label="Carga operativa",
        h1="Tickets AMS contra el mapa de aplicaciones",
        sub=("Volumen real de incidentes y requerimientos atendidos por los grupos de soporte, "
             "cruzado contra las aplicaciones catalogadas en el brain. La sección de brechas "
             "muestra los grupos que sostienen operación sobre sistemas que todavía no existen "
             "en el inventario, evidencia de que el catálogo está incompleto."),
        crumb="SPE-AM-003 › Liverpool Brain › <em>Carga operativa AMS</em>",
        badge="GenWizard",
        stats_html=stats)

    body = f"""<div id="fbar">
  <input id="q" placeholder="Buscar aplicación o dominio…">
  <div class="sep"></div>
  <span id="info">{len(apps)} aplicaciones visibles</span></div>
<div id="wrap">

<div class="sec">
  <div class="sec-h"><h2>Carga por aplicación</h2><span class="n">{len(apps)} aplicaciones</span></div>
  <p class="sec-p">Cada renglón concentra los grupos de soporte que operan sobre la misma aplicación.
  La columna de recurrentes indica cuántos de esos tickets repiten un patrón ya visto, que es la
  señal más directa de deuda técnica no resuelta. El percentil noventa de atención expone dónde
  la cola de espera se dispara aunque la mediana se vea sana.</p>
  <table id="apptbl"><thead><tr>
    <th>Aplicación</th><th>Tipo</th><th>Dominio</th><th class="num">Tickets</th><th></th>
    <th class="num">Recurrentes</th><th class="num">Crítica y alta</th>
    <th class="num">P90 horas</th><th class="num">Grupos</th></tr></thead>
    <tbody>{''.join(rows)}</tbody></table>
</div>

<div class="sec">
  <div class="sec-h"><h2>Brechas de inventario</h2><span class="n">{len(gaps)} grupos</span></div>
  <p class="sec-p">Estos grupos de soporte generan trabajo real todos los meses, de modo que los
  sistemas que atienden existen en la operación de Liverpool aunque no estén documentados.
  Concentran {fnum(gap_t)} tickets, equivalentes al {round(100-pct,1)} por ciento del volumen total,
  y cada uno es candidato a incorporarse al catálogo de aplicaciones.</p>
  {''.join(gap_html)}
</div>

<div class="sec">
  <div class="sec-h"><h2>Patrones recurrentes dominantes</h2><span class="n">Top 25 de {fnum(n_rec)}</span></div>
  <p class="sec-p">Un patrón recurrente es un texto de ticket que se repite con mínimas variaciones.
  Cuando un mismo patrón acumula cientos de ocurrencias durante meses, deja de ser un incidente y
  se convierte en un defecto estructural que nadie ha cerrado, o en un proceso manual que debería
  estar automatizado.</p>
  <div class="grid2"><div>{''.join(rec_html[:13])}</div><div>{''.join(rec_html[13:])}</div></div>
</div>

</div>"""

    OUT.write_text(page("Liverpool · Carga operativa AMS", hero_html, body, CSS, JS),
                   encoding="utf-8")
    conn.close()
    print(f"escrito: {OUT.relative_to(BRAIN)}")
    print(f"  {len(apps)} aplicaciones con carga · {len(gaps)} brechas · {fnum(total_corpus)} tickets")


if __name__ == "__main__":
    main()

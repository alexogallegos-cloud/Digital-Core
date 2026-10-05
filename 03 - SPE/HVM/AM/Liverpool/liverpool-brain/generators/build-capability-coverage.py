#!/usr/bin/env python3
"""
Liverpool — Vista de cobertura ETB: portal/capability-coverage-liv.html

Cruza las 282 capacidades del blueprint contra las aplicaciones catalogadas,
organizadas por eslabón de cadena de valor. Responde dos preguntas: qué parte
del negocio tiene soporte aplicativo real y dónde están las brechas.

Correr después de build-capability-mapping.py.
"""
import html as H
import sqlite3
from pathlib import Path

from _liv_shared import hero, page, stat

HERE  = Path(__file__).parent
BRAIN = HERE.parent
DB    = BRAIN / "liverpool-brain.db"
OUT   = BRAIN / "portal" / "capability-coverage-liv.html"

ST_LABEL = {"COVERED": "Cubierta", "PARTIAL": "Parcial",
            "NOT_COVERED": "Sin cobertura", "CROSS_CUTTING": "Transversal"}
ST_CLS = {"COVERED": "ok", "PARTIAL": "warn", "NOT_COVERED": "bad", "CROSS_CUTTING": "cx"}

CSS = """
#wrap{flex:1;overflow-y:auto;padding:22px 26px 60px}
.sec{margin-bottom:32px}
.sec-h{display:flex;align-items:baseline;gap:12px;margin-bottom:6px}
.sec-h h2{font-size:17px;font-weight:800;letter-spacing:-.02em}
.sec-h .n{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;
  color:var(--pink);background:rgba(224,1,152,.1);border:1px solid rgba(224,1,152,.28);
  border-radius:20px;padding:2px 9px}
.sec-p{font-size:12.5px;color:var(--muted);line-height:1.6;max-width:96ch;margin-bottom:16px}
.vc{display:flex;align-items:center;gap:14px;padding:11px 14px;border-radius:11px;
  background:rgba(255,255,255,.028);border:1px solid rgba(255,255,255,.055);margin-bottom:8px;
  cursor:pointer;transition:.18s}
.vc:hover{border-color:rgba(224,1,152,.4);background:rgba(224,1,152,.055)}
.vc.on{border-color:var(--sky);background:rgba(135,195,211,.09)}
.vc .vid{font-size:10px;font-weight:800;color:var(--muted2);min-width:42px;letter-spacing:.06em}
.vc .vn{font-weight:700;font-size:13px;min-width:190px}
.vc .vs{font-size:11px;color:var(--muted);min-width:250px}
.stack{flex:1;display:flex;height:16px;border-radius:5px;overflow:hidden;min-width:150px;
  background:rgba(255,255,255,.05)}
.stack i{display:block;height:100%}
.s-ok{background:linear-gradient(90deg,#4ade80,#22c55e)}
.s-warn{background:linear-gradient(90deg,#fbbf24,#f59e0b)}
.s-bad{background:linear-gradient(90deg,#f87171,#ef4444)}
.s-cx{background:linear-gradient(90deg,#c4b5fd,#a78bfa)}
.vc .pctn{font-size:17px;font-weight:900;font-variant-numeric:tabular-nums;min-width:52px;
  text-align:right;background:linear-gradient(135deg,var(--sky),#b8e0ea);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent}
table{width:100%;border-collapse:collapse;font-size:12px}
th{text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.09em;text-transform:uppercase;
  color:var(--muted2);padding:8px 10px;border-bottom:1px solid var(--line);position:sticky;top:0;
  background:var(--bg);z-index:2}
td{padding:8px 10px;border-bottom:1px solid rgba(255,255,255,.045);vertical-align:top}
tr:hover td{background:rgba(224,1,152,.05)}
.cid{font-family:ui-monospace,Menlo,monospace;font-size:10.5px;color:var(--muted2);white-space:nowrap}
.l3{font-weight:700;color:var(--ink)}
.l2{font-size:10.5px;color:var(--muted2);margin-top:2px}
.why{font-size:11px;color:var(--muted);line-height:1.5;max-width:52ch}
.badge2{display:inline-block;font-size:9px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;
  padding:2px 8px;border-radius:10px;border:1px solid;white-space:nowrap}
.ok{color:#4ade80;border-color:rgba(74,222,128,.32);background:rgba(74,222,128,.1)}
.warn{color:#fbbf24;border-color:rgba(251,191,36,.32);background:rgba(251,191,36,.1)}
.bad{color:#f87171;border-color:rgba(248,113,113,.36);background:rgba(248,113,113,.12)}
.cx{color:#c4b5fd;border-color:rgba(196,181,253,.32);background:rgba(196,181,253,.1)}
.sysn{font-size:11.5px;font-weight:600;color:var(--sky)}
.supp{font-size:10px;color:var(--muted2);margin-top:2px}
.conf{font-size:9px;color:var(--muted2);text-transform:uppercase;letter-spacing:.06em}
.hidden{display:none}
"""

JS = """
let fVC=null,fST=null;
const q=document.getElementById('q');
function apply(){
  const v=q.value.toLowerCase().trim();let n=0;
  document.querySelectorAll('#captbl tbody tr').forEach(tr=>{
    const ok=(!v||tr.dataset.k.includes(v))&&(!fVC||tr.dataset.vc===fVC)&&(!fST||tr.dataset.st===fST);
    tr.classList.toggle('hidden',!ok);if(ok)n++;
  });
  document.getElementById('info').textContent=n+' capacidades visibles';
}
q.addEventListener('input',apply);
document.querySelectorAll('.vc').forEach(el=>el.addEventListener('click',()=>{
  const id=el.dataset.vc;fVC=(fVC===id)?null:id;
  document.querySelectorAll('.vc').forEach(x=>x.classList.toggle('on',x.dataset.vc===fVC));
  apply();document.getElementById('tablesec').scrollIntoView({behavior:'smooth'});
}));
document.querySelectorAll('.pill[data-st]').forEach(el=>el.addEventListener('click',()=>{
  const s=el.dataset.st;fST=(fST===s)?null:s;
  document.querySelectorAll('.pill[data-st]').forEach(x=>x.classList.toggle('on',x.dataset.st===fST));
  apply();
}));
"""


def main():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    c = conn.cursor()

    vcs = c.execute("""SELECT v.id, v.name, v.subtitle,
           SUM(CASE WHEN r.liverpool_status='COVERED' THEN 1 ELSE 0 END) ok,
           SUM(CASE WHEN r.liverpool_status='PARTIAL' THEN 1 ELSE 0 END) pa,
           SUM(CASE WHEN r.liverpool_status='NOT_COVERED' THEN 1 ELSE 0 END) no,
           SUM(CASE WHEN r.liverpool_status='CROSS_CUTTING' THEN 1 ELSE 0 END) cx,
           COUNT(*) tot
        FROM value_chain v JOIN rtb_l3 r ON r.vc_id=v.id
        GROUP BY v.id ORDER BY v.seq""").fetchall()

    caps = c.execute("""SELECT r.id, r.l2_name, r.l3_name, r.vc_id, r.liverpool_status,
                               r.primary_system, r.coverage_confidence, r.coverage_note,
                               v.name vc_name
                        FROM rtb_l3 r LEFT JOIN value_chain v ON v.id=r.vc_id
                        ORDER BY r.vc_id, r.id""").fetchall()

    supp = {}
    for cap_id, keys in c.execute("""SELECT cap_id, GROUP_CONCAT(app_key, ', ')
                                     FROM capability_coverage WHERE role='supporting'
                                     GROUP BY cap_id"""):
        supp[cap_id] = keys

    tot = len(caps)
    n_ok = sum(1 for x in caps if x["liverpool_status"] == "COVERED")
    n_pa = sum(1 for x in caps if x["liverpool_status"] == "PARTIAL")
    n_no = sum(1 for x in caps if x["liverpool_status"] == "NOT_COVERED")
    n_apps = c.execute("SELECT COUNT(DISTINCT app_key) FROM capability_coverage").fetchone()[0]
    glob = round(100 * (n_ok + 0.5 * n_pa) / tot) if tot else 0

    # ── barras por eslabón ────────────────────────────────────────────────
    vc_html = []
    for v in vcs:
        t = v["tot"] or 1
        pct = round(100 * (v["ok"] + 0.5 * v["pa"]) / t)
        segs = "".join([
            f'<i class="s-ok" style="width:{100*v["ok"]/t}%"></i>',
            f'<i class="s-warn" style="width:{100*v["pa"]/t}%"></i>',
            f'<i class="s-cx" style="width:{100*v["cx"]/t}%"></i>',
            f'<i class="s-bad" style="width:{100*v["no"]/t}%"></i>'])
        tip = (f'{v["name"]}: {v["ok"]} cubiertas, {v["pa"]} parciales, '
               f'{v["cx"]} transversales y {v["no"]} sin cobertura de {t} capacidades')
        vc_html.append(f"""<div class="vc" data-vc="{v['id']}" data-tip="{H.escape(tip)}">
  <div class="vid">{v['id']}</div><div class="vn">{H.escape(v['name'])}</div>
  <div class="vs">{H.escape(v['subtitle'] or '')}</div>
  <div class="stack">{segs}</div><div class="pctn">{pct}%</div></div>""")

    # ── tabla de capacidades ──────────────────────────────────────────────
    rows = []
    for x in caps:
        st = x["liverpool_status"] or "NOT_COVERED"
        cls = ST_CLS.get(st, "bad")
        prim = x["primary_system"] or "—"
        sp = supp.get(x["id"])
        key = f'{x["id"]} {x["l3_name"]} {x["l2_name"]} {prim} {sp or ""}'.lower()
        rows.append(f"""<tr data-k="{H.escape(key)}" data-vc="{x['vc_id']}" data-st="{st}">
  <td class="cid">{x['id']}</td>
  <td><div class="l3">{H.escape(x['l3_name'] or '')}</div>
      <div class="l2">{H.escape(x['l2_name'] or '')}</div></td>
  <td><span class="badge2 {cls}">{ST_LABEL.get(st, st)}</span></td>
  <td><div class="sysn">{H.escape(prim)}</div>
      {f'<div class="supp">Apoyan: {H.escape(sp)}</div>' if sp else ''}</td>
  <td class="conf">{H.escape(x['coverage_confidence'] or '')}</td>
  <td class="why">{H.escape(x['coverage_note'] or '')}</td></tr>""")

    stats = (stat(tot, "Capacidades") + stat(f"{glob}%", "Cobertura", "pink") +
             stat(n_ok, "Cubiertas") + stat(n_no, "Sin cobertura", "red") +
             stat(n_apps, "Aplicaciones"))

    hero_html = hero(
        label="Cobertura del blueprint",
        h1="Capacidades de negocio contra aplicaciones reales",
        sub=("Las 282 capacidades del Enterprise Technology Blueprint retail, contrastadas una a una "
             "con las aplicaciones que Liverpool tiene documentadas. El porcentaje de cobertura pondera "
             "las capacidades parciales a la mitad. Cada renglón declara con qué evidencia se tomó la "
             "decisión, de modo que una cobertura discutible se pueda rebatir con datos."),
        crumb="SPE-AM-003 › Liverpool Brain › <em>Cobertura ETB</em>",
        badge="ETB v5",
        stats_html=stats)

    body = f"""<div id="fbar">
  <input id="q" placeholder="Buscar capacidad o aplicación…">
  <div class="sep"></div>
  <span class="pill" data-st="COVERED">Cubiertas</span>
  <span class="pill" data-st="PARTIAL">Parciales</span>
  <span class="pill" data-st="NOT_COVERED">Sin cobertura</span>
  <span class="pill" data-st="CROSS_CUTTING">Transversales</span>
  <span id="info">{tot} capacidades visibles</span></div>
<div id="wrap">

<div class="sec">
  <div class="sec-h"><h2>Cadena de valor</h2><span class="n">9 eslabones</span></div>
  <p class="sec-p">Cada barra descompone las capacidades del eslabón en cubiertas, parciales,
  transversales y sin cobertura. Haz clic en un eslabón para filtrar el detalle de abajo.
  La lectura útil no es el promedio sino el contraste: los eslabones que sostienen la operación
  diaria están mejor servidos que los que habilitan crecimiento y control.</p>
  {''.join(vc_html)}
</div>

<div class="sec" id="tablesec">
  <div class="sec-h"><h2>Detalle por capacidad</h2><span class="n">{tot} capacidades</span></div>
  <p class="sec-p">El sistema primario es el dueño funcional de la capacidad y los que apoyan
  participan sin ser responsables. La columna de confianza indica qué tan firme es la evidencia
  documental detrás del mapeo, y conviene tratar como hipótesis todo lo marcado como bajo.</p>
  <table id="captbl"><thead><tr>
    <th>ID</th><th>Capacidad</th><th>Estado</th><th>Sistema</th><th>Confianza</th><th>Sustento</th>
  </tr></thead><tbody>{''.join(rows)}</tbody></table>
</div>

</div>"""

    OUT.write_text(page("Liverpool · Cobertura ETB", hero_html, body, CSS, JS), encoding="utf-8")
    conn.close()
    print(f"escrito: {OUT.relative_to(BRAIN)}")
    print(f"  {tot} capacidades · {glob}% cobertura ponderada · {n_apps} aplicaciones referidas")


if __name__ == "__main__":
    main()

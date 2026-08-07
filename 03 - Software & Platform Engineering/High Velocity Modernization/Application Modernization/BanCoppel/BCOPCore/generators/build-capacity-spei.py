#!/usr/bin/env python3
"""
build-capacity-spei.py — BCOPCore · Percentiles de carga SPEI (txn/min) mes a mes + rafagas.

Deriva de los datos minuto-a-minuto la carga por minuto (P70/P90/P99/Max) en la ventana
operativa inferida, la agrega mes a mes, y detecta rafagas (minutos >> P99). Escribe HTML,
Markdown y JSON en knowledge-base/cross-reference/.

Uso: python generators/build-capacity-spei.py   (ejecutar desde BCOPCore/)

Foco actual: SPEI. Para agregar E-Global, correr con CHANNELS=['spei','eglobal'].
"""
import sys, json
from pathlib import Path
from datetime import date

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))

from forecast import capacity as C
from forecast.calendar_mx import MxCalendar
from forecast import atypical_days as A

OUT = ROOT / "knowledge-base" / "cross-reference"
OUT.mkdir(parents=True, exist_ok=True)

CHANNELS = ["spei"]                      # foco actual
LABELS = {"spei": "SPEI Entradas", "eglobal": "E-Global / Autorizador"}
# hitos de mejora por canal (para marcar en el chart)
HITOS = {
    "spei":    {"2026-02": "balanceo colas", "2026-03": "firma SPEI"},
    "eglobal": {"2026-03": "leak fix", "2026-06": "Power 10"},
}


def growth(rows, key):
    """% de cambio del primer al ultimo mes completo."""
    a, b = rows[0][key], rows[-1][key]
    months = len(rows) - 1
    return (b / a - 1) * 100, (( (b / a) ** (12 / months) ) - 1) * 100  # total, anualizado


def render_md(ch, rows, bursts, win_rng, out_path):
    lbl = LABELS[ch]
    tot70, ann70 = growth(rows, "p70")
    tot90, ann90 = growth(rows, "p90")
    hdr = "| Mes | días | P70 | P90 | P99 | Máx diario (med) | Pico del mes |\n|---|---|---|---|---|---|---|"
    body = "\n".join(
        f"| {r['m']} | {r['days']} | {r['p70']:,} | {r['p90']:,} | {r['p99']:,} | {r['max_med']:,} | {r['pico']:,} |"
        for r in rows)
    brows = "\n".join(
        f"| {b['date']} {b['dow']} {b['time']} | {b['val']:,} | {b['x_over_p99']}× | "
        f"{'sí' if b['recovery'] else 'no'} | {'sí' if b['near_incident'] else 'no'} | {', '.join(b['calendar']) or '-'} |"
        for b in bursts)
    md = f"""# Capacidad de Carga — {lbl} (txn/min, mes a mes)
> **Fuente**: pipeline `generators/forecast/capacity.py` sobre datos minuto-a-minuto
> **Versión**: 1.0.0 · 2026-08-07 · regenerable con datos nuevos
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

## Método

Percentiles de txn/min sobre la **ventana operativa inferida** ({win_rng[0]:02d}:00–{win_rng[1]:02d}:59,
donde el promedio por minuto supera el 25% del pico). No se usa la convención del cliente
(percentil sobre 1440 min) porque la madrugada muerta subvalúa el P70. Cada celda mensual es
la **mediana de los valores diarios** del mes; el "Pico del mes" es el minuto más alto observado.

## Carga mes a mes

{hdr}
{body}

**Crecimiento:** P70 {tot70:+.0f}% total (~{ann70:+.0f}%/año) · P90 {tot90:+.0f}% total (~{ann90:+.0f}%/año).

## Lectura

- La **carga típica (P70) y el pico típico (P90)** crecen ~+20%/año, en línea con el
  crecimiento orgánico de volumen — es **demanda**, no capacidad liberada por las mejoras.
- El **pico máximo diario típico** se mantiene plano (~3,300–3,900 txn/min): el día normal no
  demanda más en su pico. Como sí hay ráfagas muy por encima, **no hay techo duro** — hay headroom.
- Las **ráfagas** (abajo) son minutos aislados muy por encima del P99. El análisis muestra que
  son mayoritariamente **dispersiones masivas de entrada** (lotes de nómina/pagos que un
  originador envía en 1-2 minutos), no recuperación de colas: solo una minoría tiene valle
  previo. Son carga real instantánea que el target debe absorber, no artefactos.

## Ráfagas detectadas (minutos > 2.5× P99 del día)

| Fecha / hora | txn/min | × P99 | ¿recuperación? | ¿cerca de incidente? | calendario |
|---|---|---|---|---|---|
{brows}

## Implicación para la migración

Dimensionar el target por el **pico/min de día normal proyectado** (hoy ~{rows[-1]['max_med']:,},
~+20%/año → H2-2027) **más** capacidad de absorber ráfagas de **entrada masiva** (dispersiones
de nómina/lotes, hasta ~{max(b['val'] for b in bursts):,} txn/min observado ≈ 10× el P99). Las
mejoras del sistema se reflejan en *fiabilidad* (menos minutos en caída), no en el pico/min.

---

*v1.0.0 · 2026-08-07 · Generado por generators/build-capacity-spei.py.*
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(md)
    print(f"  MD: {out_path}")


def render_html(ch, rows, bursts, win_rng, hitos, out_path):
    lbl = LABELS[ch]
    data = json.dumps({"rows": rows, "bursts": bursts, "hitos": hitos,
                       "win": f"{win_rng[0]:02d}:00-{win_rng[1]:02d}:59", "label": lbl},
                      ensure_ascii=False)
    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>BanCoppel — Capacidad de carga {lbl}</title><script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#0f1117;color:#e2e8f0;padding:24px}}
h1{{font-size:18px;font-weight:600;color:#fff;margin-bottom:4px}}
.sub{{font-size:11px;color:#64748b;margin-bottom:20px}}
.kpi-row{{display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap}}
.kpi{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:12px 18px;min-width:150px}}
.kpi .val{{font-size:22px;font-weight:700;color:#10b981}} .kpi .lbl{{font-size:10px;color:#64748b;margin-top:3px}}
.section{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:16px;margin-bottom:16px}}
.section-title{{font-size:12px;font-weight:600;color:#94a3b8;margin-bottom:10px}}
svg text{{fill:#94a3b8}} .axis line,.axis path{{stroke:#2d3548}}
.legend{{display:flex;gap:14px;margin-top:6px;font-size:10px;color:#64748b;flex-wrap:wrap}}
.legend span{{display:inline-flex;align-items:center;gap:5px}} .sw{{width:18px;height:2px;display:inline-block}}
table{{width:100%;border-collapse:collapse;font-size:10px}} th,td{{text-align:left;padding:4px 8px;border-bottom:1px solid #2d3548}}
th{{color:#64748b;font-weight:600}} .rec{{color:#f59e0b}}
.note{{font-size:9px;color:#475569;margin-top:12px;border-top:1px solid #2d3548;padding-top:10px}}
</style></head><body>
<h1>BanCoppel · Capacidad de carga — {lbl} (txn/min)</h1>
<div class="sub">BCOPCore SPE-AM-001 · percentiles de carga en ventana operativa · mes a mes · generators/forecast/capacity.py</div>
<div class="kpi-row" id="kpis"></div>
<div class="section"><div class="section-title">Carga por minuto — mediana de diarios por mes</div><div id="chart"></div>
<div class="legend">
<span><span class="sw" style="background:#64748b"></span>P70 (típico)</span>
<span><span class="sw" style="background:#10b981"></span>P90 (pico típico)</span>
<span><span class="sw" style="background:#38bdf8"></span>P99</span>
<span><span class="sw" style="background:#f472b6"></span>Máx diario (med)</span>
</div></div>
<div class="section"><div class="section-title">Ráfagas (minutos > 2.5× P99 del día) — dispersiones masivas de entrada, no carga sostenida</div>
<table id="bt"><thead><tr><th>Fecha/hora</th><th>txn/min</th><th>× P99</th><th>recuperación</th><th>cerca incidente</th><th>calendario</th></tr></thead><tbody></tbody></table></div>
<div class="note" id="note"></div>
<script>
const DATA={data};const R=DATA.rows;const pM=d3.timeParse("%Y-%m");
R.forEach(r=>r.D=pM(r.m));
const g70=(R[R.length-1].p70/R[0].p70-1)*100, g90=(R[R.length-1].p90/R[0].p90-1)*100;
const ann=(t)=>((Math.pow(R[R.length-1][t]/R[0][t],12/(R.length-1))-1)*100);
document.getElementById("kpis").innerHTML=`
<div class="kpi"><div class="val">${{R[R.length-1].p70.toLocaleString()}}</div><div class="lbl">P70 último mes (carga típica)</div></div>
<div class="kpi"><div class="val">${{R[R.length-1].p90.toLocaleString()}}</div><div class="lbl">P90 último mes (pico típico)</div></div>
<div class="kpi"><div class="val">+${{ann('p70').toFixed(0)}}%</div><div class="lbl">Crecimiento P70 anualizado</div></div>
<div class="kpi"><div class="val">${{R[R.length-1].max_med.toLocaleString()}}</div><div class="lbl">Máx diario típico (plano = headroom)</div></div>
<div class="kpi"><div class="val">${{Math.max(...R.map(r=>r.pico)).toLocaleString()}}</div><div class="lbl">Ráfaga máxima observada (txn/min)</div></div>`;

const W=document.getElementById("chart").offsetWidth||900,H=280,M={{top:10,right:16,bottom:30,left:56}};
const w=W-M.left-M.right,h=H-M.top-M.bottom;
const x=d3.scaleTime().domain(d3.extent(R,r=>r.D)).range([0,w]);
const y=d3.scaleLinear().domain([0,d3.max(R,r=>r.max_med)*1.1]).range([h,0]);
const svg=d3.select("#chart").append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{M.left}},${{M.top}})`);
svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(5).tickFormat(d=>(d/1000).toFixed(1)+"k"))
 .call(gg=>gg.select(".domain").remove()).call(gg=>gg.selectAll(".tick line").clone().attr("x2",w).attr("stroke","#2d3548").attr("stroke-dasharray","3,3"));
svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).ticks(10).tickFormat(d3.timeFormat("%b'%y")));
for(const[mk,txt] of Object.entries(DATA.hitos)){{
  const dx=pM(mk); if(!dx)continue;
  svg.append("line").attr("x1",x(dx)).attr("x2",x(dx)).attr("y1",0).attr("y2",h).attr("stroke","#f59e0b").attr("stroke-dasharray","3,3").attr("opacity",.6);
  svg.append("text").attr("x",x(dx)+3).attr("y",11).attr("font-size",8).attr("fill","#f59e0b").text(txt);
}}
const mk=(key,col,wd)=>svg.append("path").datum(R).attr("fill","none").attr("stroke",col).attr("stroke-width",wd)
 .attr("d",d3.line().x(r=>x(r.D)).y(r=>y(r[key])));
mk("max_med","#f472b6",1); mk("p99","#38bdf8",1); mk("p90","#10b981",2); mk("p70","#64748b",1.5);

const tb=d3.select("#bt tbody");
DATA.bursts.forEach(b=>{{const tr=tb.append("tr");
 tr.append("td").text(`${{b.date}} ${{b.dow}} ${{b.time}}`);
 tr.append("td").text(b.val.toLocaleString());
 tr.append("td").text(b.x_over_p99+"×");
 tr.append("td").attr("class",b.recovery?"rec":"").text(b.recovery?"sí":"no");
 tr.append("td").text(b.near_incident?"sí":"no");
 tr.append("td").text(b.calendar.join(", ")||"-");}});
document.getElementById("note").innerHTML=`Ventana operativa ${{DATA.win}} &middot; percentil sobre carga de negocio (no sobre 1440 min) &middot; P70/P90 crecen ~+20%/año (demanda) &middot; Máx diario plano = headroom &middot; ráfagas = dispersiones masivas de entrada (nómina/lotes) &middot; BCOPCore SPE-AM-001`;
</script></body></html>"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"  HTML: {out_path}")


def main():
    cal = MxCalendar(range(2023, 2031))
    atypical = A.to_set()
    report = {}
    for ch in CHANNELS:
        print(f"\nCargando minxmin de {ch} (pesado)...")
        by_day = C.load_minute_channel(ROOT, ch)
        prof = C.intraday_profile(by_day)
        win, rng = C.operating_window(prof)
        print(f"  ventana operativa: {rng[0]:02d}:00-{rng[1]:02d}:59 ({len(win)} min)")
        daily = C.daily_metrics(by_day, win)
        rows = C.monthly(daily)
        bursts = C.detect_bursts(by_day, daily, win, cal=cal, atypical=atypical, top=20)
        hitos = HITOS.get(ch, {})
        render_md(ch, rows, bursts, rng, str(OUT / f"capacity-percentiles-{ch}.md"))
        render_html(ch, rows, bursts, rng, hitos, str(OUT / f"capacity-percentiles-{ch}.html"))
        report[ch] = {"window": f"{rng[0]:02d}:00-{rng[1]:02d}:59", "monthly": rows, "bursts": bursts}
        print(f"  {ch}: P70 {rows[0]['p70']}->{rows[-1]['p70']} · P90 {rows[0]['p90']}->{rows[-1]['p90']} · rafaga max {max(b['val'] for b in bursts):,}")
    with open(OUT / "capacity-percentiles.json", "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
    print(f"\n  JSON: {OUT / 'capacity-percentiles.json'}")
    print("[OK] Capacidad completa.")


if __name__ == "__main__":
    main()

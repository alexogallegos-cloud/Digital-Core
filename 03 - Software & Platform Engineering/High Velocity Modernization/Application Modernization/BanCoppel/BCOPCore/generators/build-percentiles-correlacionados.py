#!/usr/bin/env python3
"""
build-percentiles-correlacionados.py — BCOPCore · Percentiles CORRELACIONADOS SPEI+Autorizador.

Calculo de percentiles correlacionados: carga que SPEI y el Autorizador ejercen SIMULTANEAMENTE
sobre Informix (recurso compartido), en ventanas de 5 min (carga sostenida, no rafagas de 1 min).
 - P70 por canal = umbral de alerta;  zona de riesgo = AMBOS >= P70;  incidencia = AMBOS >= P90.
 - top-N de concurrencia sostenida sin caida = capacidad demostrada.
Genera la evolucion mes a mes (2025-2026) + los umbrales del ultimo mes, en HTML/MD/JSON.

DT dueño: dt-autorizador-pagos (interfaz con el core Informix / capacidad de la capa media),
co-referencia dt-spei (canal SPEI) y dt-riesgos (riesgo de capacidad de migracion).

Uso: python generators/build-percentiles-correlacionados.py   (ejecutar desde BCOPCore/)
"""
import sys, json
from pathlib import Path
from datetime import date
from calendar import monthrange

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from forecast import capacity as C
from forecast.calendar_mx import MxCalendar

OUT = ROOT / "knowledge-base" / "cross-reference"
HITOS = {"2026-03": "leak-fix", "2026-06": "Power 10"}


def main():
    cal = MxCalendar(range(2023, 2031))
    print("Cargando minxmin de ambos canales (una vez)...")
    egm = {(d, m): v for d, mm in C.load_minute_channel(ROOT, "eglobal").items()
           if len(mm) >= 1400 for m, v in mm}
    spm = {(d, m): v for d, mm in C.load_minute_channel(ROOT, "spei").items()
           if len(mm) >= 1400 for m, v in mm}

    # evolucion mes a mes (2025-01 .. 2026-07)
    meses = []
    y, mo = 2025, 1
    while (y, mo) <= (2026, 7):
        d0 = date(y, mo, 1); d1 = date(y, mo, monthrange(y, mo)[1])
        r = C.correlated_percentiles(ROOT, cal, d0, d1, _egm=egm, _spm=spm)
        r["mes"] = f"{y}-{mo:02d}"
        meses.append(r)
        print(f"  {r['mes']}: P70c={r['p70']['suma']:>5,} P90c={r['p90']['suma']:>5,} "
              f"riesgo={r['pct_zona_riesgo']:>4}% top5c={r['top_promedio']['combinada']:>6,} r={r['correlacion']}")
        mo += 1
        if mo == 13:
            y, mo = y + 1, 1

    actual = meses[-1]
    report = {"metodologia": "percentiles correlacionados (ventana 5 min, dias habiles 07-23h)",
              "actual": actual, "evolucion": meses}
    (OUT / "percentiles-correlacionados.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    _render_md(meses, actual, OUT / "percentiles-correlacionados.md")
    _render_html(meses, actual, OUT / "percentiles-correlacionados-evolucion.html")
    print("\n[OK] Percentiles correlacionados generados.")


def _render_md(meses, a, path):
    filas = "\n".join(
        f"| {m['mes']} | {m['p70']['suma']:,} | {m['p90']['suma']:,} | {m['pct_zona_riesgo']}% | "
        f"{m['top_promedio']['combinada']:,} | {m['correlacion']} |" for m in meses)
    md = f"""# Percentiles Correlacionados — SPEI + Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.0.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 5 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). Días
hábiles, horario operativo 07–23h.

- **P70 por canal** = umbral de alerta.
- **Zona de riesgo** = ambos canales ≥ su P70 a la vez.
- **Incidencia inminente** = ambos ≥ su P90.
- **Top-N de concurrencia sin caída** = capacidad sostenida demostrada.

A diferencia de sumar percentiles individuales (que asume independencia), esto respeta la
**correlación temporal**: los picos de ambos canales coinciden (mismo perfil intradía), por lo
que no se diversifican y la carga se apila sobre Informix.

## Umbrales actuales ({a['mes']})

| Canal | P70 (alerta) | P90 (incidencia) |
|-------|-------------|------------------|
| Autorizador | {a['p70']['eglobal']:,} | {a['p90']['eglobal']:,} |
| SPEI | {a['p70']['spei']:,} | {a['p90']['spei']:,} |
| **Combinado (Informix)** | **{a['p70']['suma']:,}** | **{a['p90']['suma']:,}** |

- Zona de riesgo (ambos ≥ P70): **{a['pct_zona_riesgo']}%** del tiempo operativo.
- Correlación intra-ventana: **r = {a['correlacion']}**.
- Capacidad sostenida demostrada (top-5 concurrencia): **{a['top_promedio']['combinada']:,} txn/min**
  (Autorizador {a['top_promedio']['eglobal']:,} + SPEI {a['top_promedio']['spei']:,}).

## Evolución mensual (txn/min)

| Mes | P70 comb | P90 comb | Zona riesgo | Top-5 comb | Correl. |
|-----|----------|----------|-------------|------------|---------|
{filas}

> Los umbrales suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador ~+9%/año): la
> carga combinada cruza el P70/P90 cada vez más seguido, comiéndose el margen del Informix
> actual. Es el argumento cuantitativo de capacidad para la migración.

---

*v1.0.0 · Generado por generators/build-percentiles-correlacionados.py · gráfica de evolución en
`percentiles-correlacionados-evolucion.html`.*
"""
    path.write_text(md, encoding="utf-8")
    print(f"  MD: {path}")


def _render_html(meses, a, path):
    data = json.dumps({"meses": meses, "hitos": HITOS}, ensure_ascii=False)
    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<title>Percentiles correlacionados — evolucion</title><script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#0f1117;color:#e2e8f0;padding:24px}}
h1{{font-size:18px;font-weight:600;color:#fff;margin-bottom:4px}} .sub{{font-size:11px;color:#64748b;margin-bottom:18px}}
.kpi-row{{display:flex;gap:12px;margin-bottom:18px;flex-wrap:wrap}}
.kpi{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:10px 16px;min-width:150px}}
.kpi .val{{font-size:22px;font-weight:700}} .kpi .lbl{{font-size:10px;color:#64748b;margin-top:3px}}
.section{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:16px;margin-bottom:14px}}
.section-title{{font-size:12px;font-weight:600;color:#94a3b8;margin-bottom:10px}}
svg text{{fill:#94a3b8}} .axis line,.axis path{{stroke:#2d3548}}
.legend{{display:flex;gap:14px;margin-top:8px;font-size:10px;color:#94a3b8;flex-wrap:wrap}}
.legend span{{display:inline-flex;align-items:center;gap:5px}} .sw{{width:18px;height:3px;display:inline-block}}
.note{{font-size:9px;color:#475569;margin-top:12px;border-top:1px solid #2d3548;padding-top:10px}}
</style></head><body>
<h1>Percentiles correlacionados — SPEI + Autorizador sobre Informix</h1>
<div class="sub">BCOPCore SPE-AM-001 · carga combinada sostenida (ventana 5 min) · evolucion 2025-2026 · DT dt-autorizador-pagos</div>
<div class="kpi-row" id="kpis"></div>
<div class="section"><div class="section-title">Evolucion mensual — carga combinada (txn/min)</div><div id="chart"></div>
<div class="legend">
<span><span class="sw" style="background:#64748b"></span>P70 combinado (alerta)</span>
<span><span class="sw" style="background:#f59e0b"></span>P90 combinado (incidencia)</span>
<span><span class="sw" style="background:#ef4444"></span>Top-5 concurrencia (capacidad demostrada)</span>
</div></div>
<div class="section"><div class="section-title">Zona de riesgo — % del tiempo con ambos &ge; P70</div><div id="chart2"></div></div>
<div class="note" id="note"></div>
<script>
const DATA={data};const M=DATA.meses;const pM=d3.timeParse("%Y-%m");
M.forEach(m=>{{m.D=pM(m.mes);m.p70=m.p70.suma;m.p90=m.p90.suma;m.top5=m.top_promedio.combinada;m.riesgo=m.pct_zona_riesgo;}});
const a=M[M.length-1];
document.getElementById("kpis").innerHTML=`
<div class="kpi"><div class="val" style="color:#64748b">${{a.p70.toLocaleString()}}</div><div class="lbl">P70 combinado actual (alerta)</div></div>
<div class="kpi"><div class="val" style="color:#f59e0b">${{a.p90.toLocaleString()}}</div><div class="lbl">P90 combinado actual (incidencia)</div></div>
<div class="kpi"><div class="val" style="color:#ef4444">${{a.top5.toLocaleString()}}</div><div class="lbl">Capacidad demostrada (top-5)</div></div>
<div class="kpi"><div class="val">${{a.riesgo}}%</div><div class="lbl">Tiempo en zona de riesgo</div></div>`;

function chart(id,keys,cols,fmt){{
 const W=document.getElementById(id).offsetWidth||1000,H=id==="chart"?300:170,Mg={{top:10,right:16,bottom:26,left:60}};
 const w=W-Mg.left-Mg.right,h=H-Mg.top-Mg.bottom;
 const x=d3.scaleTime().domain(d3.extent(M,m=>m.D)).range([0,w]);
 const y=d3.scaleLinear().domain([0,d3.max(M,m=>d3.max(keys,k=>m[k]))*1.12]).range([h,0]);
 const svg=d3.select("#"+id).append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{Mg.left}},${{Mg.top}})`);
 svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(5).tickFormat(fmt)).call(g=>g.select(".domain").remove())
  .call(g=>g.selectAll(".tick line").clone().attr("x2",w).attr("stroke","#2d3548").attr("stroke-dasharray","3,3"));
 svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).ticks(9).tickFormat(d3.timeFormat("%b'%y")));
 for(const[mk,txt] of Object.entries(DATA.hitos)){{const dx=pM(mk);if(!dx)continue;
  svg.append("line").attr("x1",x(dx)).attr("x2",x(dx)).attr("y1",0).attr("y2",h).attr("stroke","#38bdf8").attr("stroke-dasharray","3,3").attr("opacity",.5);
  svg.append("text").attr("x",x(dx)+3).attr("y",10).attr("font-size",8).attr("fill","#38bdf8").text(txt);}}
 keys.forEach((k,i)=>{{svg.append("path").datum(M).attr("fill","none").attr("stroke",cols[i]).attr("stroke-width",2)
  .attr("d",d3.line().x(m=>x(m.D)).y(m=>y(m[k])));
  svg.selectAll(".d"+i).data(M).join("circle").attr("cx",m=>x(m.D)).attr("cy",m=>y(m[k])).attr("r",2.5).attr("fill",cols[i]);}});
}}
chart("chart",["p70","p90","top5"],["#64748b","#f59e0b","#ef4444"],d=>(d/1000).toFixed(1)+"k");
chart("chart2",["riesgo"],["#10b981"],d=>d+"%");
document.getElementById("note").innerHTML=`Percentiles correlacionados (ventana 5 min, habil 07-23h) &middot; P70/P90 = suma de umbrales por canal en concurrencia &middot; top-5 = capacidad sostenida demostrada sin caida &middot; los umbrales suben con el crecimiento organico &middot; generado por generators/build-percentiles-correlacionados.py`;
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

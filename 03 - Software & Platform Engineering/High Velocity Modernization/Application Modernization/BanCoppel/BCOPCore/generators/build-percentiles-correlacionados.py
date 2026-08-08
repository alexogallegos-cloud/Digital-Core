#!/usr/bin/env python3
"""
build-percentiles-correlacionados.py — BCOPCore · Percentiles CORRELACIONADOS SPEI+Autorizador.

Calculo de percentiles correlacionados: carga que SPEI y el Autorizador ejercen SIMULTANEAMENTE
sobre Informix (recurso compartido), en ventanas PROMEDIO de 5 min (carga sostenida). Todas las curvas (P70/P90 y capacidad) usan la misma ventana de 5 min.
 - P70 por canal = umbral de alerta;  zona de riesgo = AMBOS >= P70;  incidencia = AMBOS >= P90.
 - top-N de mayor carga combinada (sin gate de percentil, sin dedup) = capacidad demostrada.
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

    # evolucion MENSUAL 2025-01 .. 2026-07 (P70/P90 = percentil sobre TODAS las ventanas de 5 min del mes)
    meses = []
    y, mo = 2025, 1
    while (y, mo) <= (2026, 7):
        d0 = date(y, mo, 1); d1 = date(y, mo, monthrange(y, mo)[1])
        r = C.correlated_percentiles(ROOT, cal, d0, d1, w=5, _egm=egm, _spm=spm)   # P70/P90 sobre ventanas de 5 min
        r["mes"] = f"{y}-{mo:02d}"
        r["x"] = str(date(y, mo, 15))             # fecha representativa (mitad de mes) para el eje temporal
        meses.append(r)
        print(f"  {r['mes']}: SPEI P70={r['p70']['spei']:>5,} P90={r['p90']['spei']:>5,} | "
              f"Aut P70={r['p70']['eglobal']:>5,} P90={r['p90']['eglobal']:>5,} | "
              f"riesgo={r['pct_zona_riesgo']:>4}% r={r['correlacion']}")
        mo += 1
        if mo == 13:
            y, mo = y + 1, 1

    actual = meses[-1]
    report = {"metodologia": "percentiles correlacionados (P70/P90 en ventanas PROMEDIO de 5 min, TODOS los dias 13-22h); "
              "P70/P90 por canal por separado (SPEI y Autorizador), sin combinado; "
              "capacidad demostrada = top-10 de MAYOR carga combinada en ventanas de 5 min sobre toda la data (sin gate de percentil, sin dedup); "
              "zona de riesgo = ambos canales >= su P70 a la vez (lente correlacionada)",
              "actual": actual, "evolucion": meses}
    (OUT / "percentiles-correlacionados.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    _render_md(meses, actual, OUT / "percentiles-correlacionados.md")
    _render_html(meses, actual, OUT / "percentiles-correlacionados-evolucion.html")
    print("\n[OK] Percentiles correlacionados generados.")


def _render_md(meses, a, path):
    filas = "\n".join(
        f"| {m['mes']} | {m['p70']['spei']:,} | {m['p90']['spei']:,} | "
        f"{m['p70']['eglobal']:,} | {m['p90']['eglobal']:,} | {m['pct_zona_riesgo']}% | {m['correlacion']} |"
        for m in meses)
    md = f"""# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.3.0 (evolución mensual) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), sobre **ventanas promedio de 5 minutos**
(carga sostenida, no el pico de 1 min del que el sistema se restablece). Tanto los **umbrales
P70/P90** como la **capacidad demostrada** (top-10) usan esa misma ventana de 5 min. **Todos los
días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 13–22h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés. (Ventana prom. 5 min.)
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-10 de mayor carga combinada, en ventanas promedio de 5 min** = capacidad demostrada por canal
  (el nivel de cada canal en las 10 ventanas de 5 min de mayor carga total; **SIN gate de percentil**
  — no exige ambos ≥ P70 — y **SIN dedup por día**; toda la data, 13–22h).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (último mes {a['mes']}) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-10, ventana prom. 5 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | {a['p70']['spei']:,} | {a['p90']['spei']:,} | {a['top_promedio']['spei']:,} |
| Autorizador | {a['p70']['eglobal']:,} | {a['p90']['eglobal']:,} | {a['top_promedio']['eglobal']:,} |

- Zona de riesgo (ambos ≥ su P70 a la vez): **{a['pct_zona_riesgo']}%** del tiempo operativo.
- Correlación intra-ventana: **r = {a['correlacion']}**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
{filas}

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución mensual · gráfica en
`percentiles-correlacionados-evolucion.html`.*
"""
    path.write_text(md, encoding="utf-8")
    print(f"  MD: {path}")


def _render_html(meses, a, path):
    data = json.dumps({"meses": meses, "hitos": HITOS}, ensure_ascii=False)
    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BCOPCore · Percentiles Correlacionados por Canal</title>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
 --p70:#818ab0;--p90:#F0D224;--cap:#ff6b6b;--riesgo:#34d399}}
html{{scroll-behavior:smooth}}
body{{background:#060a1a;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}}
.aurora::before{{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.65),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:56vw;height:56vw;right:-14vw;top:6vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.7),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{position:absolute;width:40vw;height:40vw;left:34vw;bottom:-14vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(240,210,36,.20),transparent 70%);animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
.hero-bar{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:18px;
 padding:14px 32px;backdrop-filter:blur(20px) saturate(150%);-webkit-backdrop-filter:blur(20px) saturate(150%);
 background:rgba(6,10,26,.6);border-bottom:1px solid rgba(255,255,255,.06)}}
.hero-bar img{{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}}
.hero-bar .hb-sep{{width:1px;height:28px;background:rgba(255,255,255,.15);flex-shrink:0}}
.hero-bar .crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.hero-bar .crumb em{{color:var(--yellow);font-style:normal}}
.hero-bar .hb-sp{{flex:1}}
.hero-bar .badge{{font-size:10px;font-weight:800;letter-spacing:.1em;color:#060a1a;background:var(--yellow);padding:3px 9px;border-radius:20px}}
.hero-bar a.back{{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s}}
.hero-bar a.back:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
.glass{{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}}
.wrap{{max-width:1280px;margin:0 auto;padding:96px 30px 40px}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}}
.hero-h1{{font-size:clamp(28px,4.4vw,48px);font-weight:900;letter-spacing:-.035em;line-height:1.0;
 background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.hero-sub{{margin-top:14px;font-size:13px;color:var(--muted);line-height:1.6;max-width:82ch}}
.kpi-row{{display:flex;gap:12px;margin:26px 0 8px;flex-wrap:wrap}}
.kpi{{padding:14px 20px;min-width:150px}}
.kpi .val{{font-size:26px;font-weight:900;letter-spacing:-.02em;font-variant-numeric:tabular-nums}}
.kpi .lbl{{font-size:9.5px;color:var(--muted2);letter-spacing:.05em;text-transform:uppercase;margin-top:4px}}
.panels{{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:8px}}
.panel{{padding:20px 22px}}
.panel-head{{display:flex;align-items:center;gap:10px;margin-bottom:10px}}
.panel-dot{{width:11px;height:11px;border-radius:3px;flex-shrink:0}}
.panel-name{{font-size:15px;font-weight:800;letter-spacing:-.01em}}
.panel-tag{{font-size:10px;color:var(--muted2);margin-left:auto;letter-spacing:.05em}}
.section{{padding:20px 22px;margin-top:20px}}
.section-title{{font-size:12px;font-weight:700;color:var(--ink);margin-bottom:12px;letter-spacing:-.01em}}
svg text{{fill:var(--muted2);font-size:10px}} .axis path{{stroke:none}} .axis line{{stroke:rgba(255,255,255,.10)}}
.legend{{display:flex;gap:16px;margin-top:12px;font-size:11px;color:var(--muted);flex-wrap:wrap}}
.legend span{{display:inline-flex;align-items:center;gap:6px}} .sw{{width:18px;height:3px;display:inline-block;border-radius:2px}}
.note{{font-size:10px;color:var(--muted2);margin-top:18px;line-height:1.6}}
footer{{text-align:center;padding:36px 0 8px;font-size:11px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);margin-top:30px}}
#tt{{position:fixed;z-index:100;pointer-events:none;opacity:0;transition:opacity .12s;
 background:rgba(6,10,26,.97);border:1px solid var(--glassb);border-radius:12px;padding:9px 12px;
 box-shadow:0 16px 44px rgba(0,0,0,.6);font-size:12px;color:var(--ink)}}
#tt .tm{{font-size:10px;color:var(--muted2);letter-spacing:.08em;text-transform:uppercase;margin-bottom:5px}}
#tt .tr{{display:flex;align-items:center;gap:7px;white-space:nowrap}}
#tt .tdot{{width:9px;height:9px;border-radius:2px;flex-shrink:0}}
#tt .tv{{font-weight:800;font-variant-numeric:tabular-nums;margin-left:16px}}
svg circle.pt{{transition:r .1s}}
@media(max-width:920px){{.panels{{grid-template-columns:1fr}}}}
</style></head><body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div id="tt"></div>
<div class="hero-bar">
  <img src="../../portal/bancoppel-logo.png" alt="BanCoppel">
  <div class="hb-sep"></div>
  <span class="crumb">BCOPCORE &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>PERCENTILES CORRELACIONADOS</em></span>
  <span class="hb-sp"></span>
  <a href="curvas-intradia-navegable.html" class="back">← Curvas intradía</a>
</div>
<div class="wrap">
  <div class="hero-label">Capacidad · Percentiles Correlacionados</div>
  <h1 class="hero-h1">Percentiles Correlacionados por Canal</h1>
  <p class="hero-sub">P70 (alerta) y P90 (incidencia) de <b style="color:var(--riesgo)">SPEI</b> y del <b style="color:#9fb4ff">Autorizador</b>, <b>cada canal por separado</b>, sobre <b>ventanas promedio de 5 min</b> (carga sostenida — la misma base que la capacidad/línea roja; todos los dias 13–22h). La lente correlacionada es la <b>zona de riesgo</b>: el % del tiempo con ambos canales &ge; su P70 a la vez.</p>
  <div class="kpi-row" id="kpis"></div>
  <div class="panels">
    <div class="panel glass">
      <div class="panel-head"><span class="panel-dot" style="background:var(--riesgo)"></span>
        <span class="panel-name">SPEI Entradas</span><span class="panel-tag">D08 · txn/min</span></div>
      <div id="chartSP"></div>
    </div>
    <div class="panel glass">
      <div class="panel-head"><span class="panel-dot" style="background:#9fb4ff"></span>
        <span class="panel-name">Autorizador / E-Global</span><span class="panel-tag">capa de autorizacion · txn/min</span></div>
      <div id="chartEG"></div>
    </div>
  </div>
  <div class="legend">
    <span><span class="sw" style="background:var(--p70)"></span>P70 (alerta)</span>
    <span><span class="sw" style="background:var(--p90)"></span>P90 (incidencia)</span>
    <span><span class="sw" style="background:var(--cap)"></span>Capacidad demostrada — top-10 mayor carga (ventanas prom. 5 min)</span>
  </div>
  <div class="note" id="note"></div>
</div>
<footer>BCOPCore · Gemelo Cognitivo del Sistema · SPE-AM-001 · Accenture México · 2026</footer>
<script>
const DATA={data};const M=DATA.meses;const pD=d3.timeParse("%Y-%m-%d");
M.forEach(m=>{{m.D=pD(m.x);
  m.sp70=m.p70.spei;   m.sp90=m.p90.spei;   m.spCap=m.top_promedio.spei;
  m.eg70=m.p70.eglobal;m.eg90=m.p90.eglobal;m.egCap=m.top_promedio.eglobal;}});
const a=M[M.length-1];
const mxSp70=d3.max(M,m=>m.sp70), mxSp90=d3.max(M,m=>m.sp90);
const mxEg70=d3.max(M,m=>m.eg70), mxEg90=d3.max(M,m=>m.eg90);
const mxSpCap=d3.max(M,m=>m.spCap), mxEgCap=d3.max(M,m=>m.egCap);
document.getElementById("kpis").innerHTML=`
<div class="kpi glass"><div class="val" style="color:var(--riesgo)">${{mxSp70.toLocaleString()}} / ${{mxSp90.toLocaleString()}}</div><div class="lbl">SPEI — umbral P70 / P90 máx histórico</div></div>
<div class="kpi glass"><div class="val" style="color:#9fb4ff">${{mxEg70.toLocaleString()}} / ${{mxEg90.toLocaleString()}}</div><div class="lbl">Autorizador — umbral P70 / P90 máx histórico</div></div>
<div class="kpi glass"><div class="val" style="color:var(--cap)">${{mxSpCap.toLocaleString()}} / ${{mxEgCap.toLocaleString()}}</div><div class="lbl">Capacidad demostrada máx (SPEI / Aut · top-10, 5 min)</div></div>
<div class="kpi glass"><div class="val" style="color:var(--yellow)">${{a.pct_zona_riesgo}}%</div><div class="lbl">Tiempo en zona de riesgo (último mes)</div></div>
<div class="kpi glass"><div class="val">r = ${{a.correlacion}}</div><div class="lbl">Correlacion intra-ventana (último mes)</div></div>`;
const yMaxCh=d3.max(M,m=>d3.max([m.sp70,m.sp90,m.spCap,m.eg70,m.eg90,m.egCap]))*1.12;

const tip=document.getElementById("tt");
function showTip(ev,mes,color,label,valStr){{
 tip.style.opacity=1;
 tip.style.left=Math.min(ev.clientX+14,window.innerWidth-190)+"px";
 tip.style.top=(ev.clientY-14)+"px";
 tip.innerHTML=`<div class="tm">${{mes}}</div><div class="tr"><span class="tdot" style="background:${{color}}"></span><span>${{label}}</span><span class="tv">${{valStr}}</span></div>`;
}}
function hideTip(){{tip.style.opacity=0;}}

function chart(id,keys,cols,labels,ymaxVal,fmt,tf,H){{
 d3.select("#"+id+" svg").remove();
 const W=document.getElementById(id).offsetWidth||560,Mg={{top:12,right:16,bottom:26,left:52}};
 const w=W-Mg.left-Mg.right,h=H-Mg.top-Mg.bottom;
 const x=d3.scaleTime().domain(d3.extent(M,m=>m.D)).range([0,w]);
 const y=d3.scaleLinear().domain([0,ymaxVal]).range([h,0]);
 const svg=d3.select("#"+id).append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{Mg.left}},${{Mg.top}})`);
 svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(5).tickFormat(fmt)).call(g=>g.select(".domain").remove())
  .call(g=>g.selectAll(".tick line").clone().attr("x2",w).attr("stroke","rgba(255,255,255,.06)"));
 svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).ticks(8).tickFormat(d3.timeFormat("%b'%y"))).call(g=>g.select(".domain").remove());
 for(const[mk,txt] of Object.entries(DATA.hitos)){{const dx=pD(mk+"-15");if(!dx)continue;
  svg.append("line").attr("x1",x(dx)).attr("x2",x(dx)).attr("y1",0).attr("y2",h).attr("stroke","var(--yellow)").attr("stroke-dasharray","3,3").attr("opacity",.4);
  svg.append("text").attr("x",x(dx)+3).attr("y",10).attr("font-size",8).attr("fill","var(--yellow)").attr("opacity",.7).text(txt);}}
 keys.forEach((k,i)=>{{
  svg.append("path").datum(M).attr("fill","none").attr("stroke",cols[i]).attr("stroke-width",2.2)
   .attr("d",d3.line().x(m=>x(m.D)).y(m=>y(m[k])));
  svg.selectAll(".pt"+id+i).data(M).join("circle").attr("class","pt").attr("cx",m=>x(m.D)).attr("cy",m=>y(m[k]))
   .attr("r",2.8).attr("fill",cols[i]).attr("stroke","#060a1a").attr("stroke-width",1);
  svg.selectAll(".ht"+id+i).data(M).join("circle").attr("cx",m=>x(m.D)).attr("cy",m=>y(m[k]))
   .attr("r",9).attr("fill","transparent").style("cursor","pointer")
   .on("mouseenter",function(ev,m){{d3.select(this).attr("r",6).attr("fill",cols[i]).attr("fill-opacity",.22);}})
   .on("mousemove",(ev,m)=>showTip(ev,m.mes,cols[i],labels[i],tf(m[k])))
   .on("mouseleave",function(){{d3.select(this).attr("r",9).attr("fill","transparent");hideTip();}});
 }});
}}
function draw(){{
 const kf=d=>(d/1000).toFixed(1)+"k", kt=v=>v.toLocaleString()+" txn/min";
 const L=["P70 (alerta)","P90 (incidencia)","Capacidad top-10 (prom. 5 min)"];
 chart("chartSP",["sp70","sp90","spCap"],["#818ab0","#F0D224","#ff6b6b"],L,yMaxCh,kf,kt,280);
 chart("chartEG",["eg70","eg90","egCap"],["#818ab0","#F0D224","#ff6b6b"],L,yMaxCh,kf,kt,280);
}}
draw();window.addEventListener("resize",draw);
document.getElementById("note").innerHTML=`P70/P90 <b>por canal</b>, percentil sobre <b>todas las ventanas de 5 min</b> (13–22h, todos los días) &middot; capacidad demostrada = <b>top-10 de mayor carga combinada</b> (5 min) sobre toda la data, <b>sin gate de percentil ni dedup</b> (pueden repetirse días) &middot; generado por <code>generators/build-percentiles-correlacionados.py</code>`;
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

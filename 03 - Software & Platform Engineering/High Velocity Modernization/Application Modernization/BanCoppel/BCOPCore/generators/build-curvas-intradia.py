#!/usr/bin/env python3
"""
build-curvas-intradia.py — BCOPCore · Dashboard navegable de curvas intradia (txn/min).

Reconstruye la curva intradia (00:00-23:59) de CUALQUIER dia de 2025-2026 para SPEI y el
Autorizador: perfil intradia promedio (por tipo de dia) x volumen diario. Usa VOLUMEN REAL
donde existe (2025-01-01 a 2026-08-04) y PROYECTADO donde no (2026-08-05 a 2026-12-31).
HTML interactivo con selector de fecha y filtros por canal.

Uso: python generators/build-curvas-intradia.py   (ejecutar desde BCOPCore/)
Regenerable con datos nuevos (extiende el tramo real, recorta el proyectado).
"""
import sys, json
from pathlib import Path
from datetime import date

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from forecast import capacity as C, data_sources as DS, factors as F, atypical_days as A, model as M
from forecast.calendar_mx import MxCalendar
import numpy as np, pandas as pd, statsmodels.api as sm

OUT = ROOT / "knowledge-base" / "cross-reference"
LAST_REAL = date(2026, 8, 4)
END_PROJ = date(2026, 12, 31)


def main():
    cal = MxCalendar(range(2023, 2031))
    print("Perfiles intradia (por tipo de dia)...")
    perfiles = C.intraday_profiles(ROOT, cal)   # {canal: {habil:[288], finde:[288]}}

    print("Volumen diario real + proyectado...")
    df = F.build_features(DS.load_all(ROOT), cal)
    df["is_atypical"] = df["d"].apply(lambda x: int(x in A.to_set()))
    vol = {}
    for _, r in df.iterrows():
        d = r["d"]
        if date(2025, 1, 1) <= d <= LAST_REAL:
            vol[str(d)] = {"eg": int(r["eglobal"]), "sp": int(r["spei"]),
                           "tipo": "habil" if cal.is_business_day(d) else "finde", "origen": "real"}
    # proyectado 2026-08-05 .. 2026-12-31
    models = {}
    for ch in ("eglobal", "spei"):
        cfg = F.CHANNELS[ch]
        models[ch], _, _ = M.fit_channel(df, ch, F.FEATURE_SETS[ch], cfg["include_weekends"], cfg["min_vol"], verbose=False)
    fut = F.build_features(pd.DataFrame({"date": pd.date_range(date(2026,8,5), END_PROJ)}), cal)
    pred = {}
    for ch in ("eglobal", "spei"):
        feats = [c for c in models[ch].model.exog_names if c != "const"]
        X = sm.add_constant(fut[feats].astype(float), has_constant="add")
        pred[ch] = np.exp(models[ch].predict(X)).values
    for i, (_, r) in enumerate(fut.iterrows()):
        d = r["d"]
        # E-Global no opera fin de semana en su modelo (L-V-> pero es 7 dias ahora); usamos ambos
        vol[str(d)] = {"eg": int(pred["eglobal"][i]), "sp": int(pred["spei"][i]),
                       "tipo": "habil" if cal.is_business_day(d) else "finde", "origen": "proyectado"}

    data = json.dumps({"perfiles": perfiles, "vol": vol,
                       "last_real": str(LAST_REAL), "step": 1440 // 288}, ensure_ascii=False)
    _render(data, OUT / "curvas-intradia-navegable.html")
    print(f"  dias: {len(vol)} ({min(vol)} a {max(vol)})")
    print("[OK] Dashboard de curvas intradia generado.")


def _render(data_js, path):
    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BCOPCore · Curvas Intradia por Canal</title>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
 --sp:#34d399;--eg:#6f8ce6}}
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
.hero-sub{{margin-top:14px;font-size:13px;color:var(--muted);line-height:1.6;max-width:74ch}}
.navbar{{display:flex;gap:14px;align-items:center;flex-wrap:wrap;padding:14px 18px;margin:26px 0 8px}}
.navbar label{{font-size:11px;color:var(--muted)}}
.navbar input[type=date],.navbar button{{background:rgba(255,255,255,.05);color:var(--ink);border:1px solid var(--glassb);border-radius:8px;padding:7px 12px;font-size:12px;font-family:inherit}}
.navbar button{{cursor:pointer;transition:.2s}} .navbar button:hover{{border-color:var(--yellow);color:#fff}}
.origen{{font-size:10px;font-weight:800;letter-spacing:.08em;padding:4px 11px;border-radius:20px}}
.o-real{{background:rgba(52,211,153,.14);color:var(--sp);border:1px solid rgba(52,211,153,.3)}}
.o-proj{{background:rgba(240,210,36,.12);color:var(--yellow);border:1px solid rgba(240,210,36,.3)}}
.tipo{{font-size:11px;color:var(--muted2)}}
.toggle{{display:inline-flex;align-items:center;gap:6px;font-size:11px;color:var(--muted);cursor:pointer;user-select:none}}
.panels{{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:8px}}
.panels.solo{{grid-template-columns:1fr}}
.panel{{padding:20px 22px}} .panel.hidden{{display:none}}
.panel-head{{display:flex;align-items:center;gap:10px;margin-bottom:6px}}
.panel-dot{{width:11px;height:11px;border-radius:3px;flex-shrink:0}}
.panel-name{{font-size:15px;font-weight:800;letter-spacing:-.01em}}
.panel-tag{{font-size:10px;color:var(--muted2);margin-left:auto;letter-spacing:.05em}}
.panel-kpis{{display:flex;gap:26px;margin:8px 0 4px}}
.pk .pv{{font-size:22px;font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums}}
.pk .pl{{font-size:9px;color:var(--muted2);letter-spacing:.06em;text-transform:uppercase;margin-top:3px}}
svg text{{fill:var(--muted2);font-size:10px}} .axis path{{stroke:none}} .axis line{{stroke:rgba(255,255,255,.10)}}
.note{{font-size:10px;color:var(--muted2);margin-top:18px;line-height:1.6}}
footer{{text-align:center;padding:36px 0 8px;font-size:11px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);margin-top:30px}}
@media(max-width:920px){{.panels{{grid-template-columns:1fr}}}}
</style></head><body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div class="hero-bar">
  <img src="../../portal/bancoppel-logo.png" alt="BanCoppel">
  <div class="hb-sep"></div>
  <span class="crumb">BCOPCORE &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>CURVAS INTRADIA</em></span>
  <span class="hb-sp"></span>
  <span class="badge">DISCOVER</span>
  <a href="../../portal/index-bcop-v2.html" class="back">← Portal</a>
</div>
<div class="wrap">
  <div class="hero-label">Capacidad · Curvas Intradia</div>
  <h1 class="hero-h1">Curvas Intradia por Canal</h1>
  <p class="hero-sub">Reconstruccion de la carga intradia (txn/min, 00:00–23:59) de SPEI y el Autorizador para cualquier dia de 2025–2026. Perfil intradia promedio (por tipo de dia) &times; volumen diario. <b style="color:var(--sp)">Real</b> hasta el ultimo dato observado, <b style="color:var(--yellow)">proyectado</b> despues.</p>
  <div class="navbar glass">
    <button id="prev7">◀◀ 7d</button><button id="prev">◀ 1d</button>
    <label>Fecha <input type="date" id="fecha"></label>
    <button id="next">1d ▶</button><button id="next7">7d ▶▶</button>
    <span id="origen" class="origen"></span><span id="tipo" class="tipo"></span>
    <span style="flex:1"></span>
    <label class="toggle"><input type="checkbox" id="cSP" checked> SPEI</label>
    <label class="toggle"><input type="checkbox" id="cEG" checked> Autorizador</label>
  </div>
  <div class="panels" id="panels">
    <div class="panel glass" id="panelSP">
      <div class="panel-head"><span class="panel-dot" style="background:var(--sp)"></span>
        <span class="panel-name">SPEI Entradas</span><span class="panel-tag">D08 · riel 24/7</span></div>
      <div class="panel-kpis">
        <div class="pk"><div class="pv" id="spTot" style="color:var(--sp)"></div><div class="pl">Total del dia</div></div>
        <div class="pk"><div class="pv" id="spPk" style="color:var(--sp)"></div><div class="pl" id="spPkH">Pico txn/min</div></div>
      </div><div id="chartSP"></div>
    </div>
    <div class="panel glass" id="panelEG">
      <div class="panel-head"><span class="panel-dot" style="background:var(--eg)"></span>
        <span class="panel-name">Autorizador / E-Global</span><span class="panel-tag">capa de autorizacion</span></div>
      <div class="panel-kpis">
        <div class="pk"><div class="pv" id="egTot" style="color:var(--eg)"></div><div class="pl">Total del dia</div></div>
        <div class="pk"><div class="pv" id="egPk" style="color:var(--eg)"></div><div class="pl" id="egPkH">Pico txn/min</div></div>
      </div><div id="chartEG"></div>
    </div>
  </div>
  <div class="note" id="note"></div>
</div>
<footer>BCOPCore · Gemelo Cognitivo del Sistema · SPE-AM-001 · Accenture México · 2026</footer>
<script>
const DATA={data_js};const P=DATA.perfiles;const V=DATA.vol;const STEP=DATA.step;
const CSP="#34d399",CEG="#6f8ce6";
const fechas=Object.keys(V).sort();
const inp=document.getElementById("fecha");
inp.min=fechas[0];inp.max=fechas[fechas.length-1];inp.value=DATA.last_real;
const hh=m=>`${{String(m/60|0).padStart(2,"0")}}:${{String(m%60).padStart(2,"0")}}`;

function curva(canal,tipo,volumen){{
  const pf=P[canal][tipo];
  return pf.map((f,i)=>({{min:i*STEP, y: f*volumen/STEP}}));  // txn/min por bin
}}
function drawPanel(sel,color,cur,ymax){{
  d3.select(sel+" svg").remove();
  const cont=document.querySelector(sel);
  const W=cont.offsetWidth||520,H=320,Mg={{top:12,right:14,bottom:30,left:52}};
  const w=W-Mg.left-Mg.right,h=H-Mg.top-Mg.bottom;
  const x=d3.scaleLinear().domain([0,1439]).range([0,w]);
  const y=d3.scaleLinear().domain([0,ymax]).range([h,0]);
  const svg=d3.select(sel).append("svg").attr("width",W).attr("height",H)
    .append("g").attr("transform",`translate(${{Mg.left}},${{Mg.top}})`);
  svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(6).tickFormat(d=>(d/1000).toFixed(1)+"k"))
    .call(g=>g.select(".domain").remove())
    .call(g=>g.selectAll(".tick line").clone().attr("x2",w).attr("stroke","rgba(255,255,255,.06)"));
  svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`)
    .call(d3.axisBottom(x).tickValues(d3.range(0,1440,180)).tickFormat(m=>`${{String(m/60|0).padStart(2,"0")}}:00`))
    .call(g=>g.select(".domain").remove());
  svg.append("rect").attr("x",x(13*60)).attr("width",x(20*60)-x(13*60)).attr("y",0).attr("height",h)
    .attr("fill","var(--yellow)").attr("opacity",.05);
  const grad=svg.append("defs").append("linearGradient").attr("id","g"+sel.slice(1)).attr("x1",0).attr("y1",0).attr("x2",0).attr("y2",1);
  grad.append("stop").attr("offset","0%").attr("stop-color",color).attr("stop-opacity",.32);
  grad.append("stop").attr("offset","100%").attr("stop-color",color).attr("stop-opacity",.02);
  svg.append("path").datum(cur).attr("fill",`url(#g${{sel.slice(1)}})`)
    .attr("d",d3.area().x(p=>x(p.min)).y0(h).y1(p=>y(p.y)).curve(d3.curveBasis));
  svg.append("path").datum(cur).attr("fill","none").attr("stroke",color).attr("stroke-width",2.2)
    .attr("d",d3.line().x(p=>x(p.min)).y(p=>y(p.y)).curve(d3.curveBasis));
}}
function render(){{
  const f=inp.value, v=V[f];
  const oel=document.getElementById("origen"), tel=document.getElementById("tipo");
  const showSP=document.getElementById("cSP").checked, showEG=document.getElementById("cEG").checked;
  const panels=document.getElementById("panels");
  document.getElementById("panelSP").classList.toggle("hidden",!showSP);
  document.getElementById("panelEG").classList.toggle("hidden",!showEG);
  panels.classList.toggle("solo",!(showSP&&showEG));
  if(!v){{oel.className="origen";oel.textContent="";tel.textContent="(sin dato para esta fecha)";
    d3.select("#chartSP svg").remove();d3.select("#chartEG svg").remove();return;}}
  oel.className="origen "+(v.origen==="real"?"o-real":"o-proj");oel.textContent=v.origen.toUpperCase();
  tel.textContent=v.tipo==="habil"?"día hábil":"fin de semana / no hábil";
  const cvSP=curva("spei",v.tipo,v.sp), cvEG=curva("eglobal",v.tipo,v.eg);
  const ymax=d3.max([...cvSP,...cvEG],p=>p.y)*1.12||1;   // escala compartida
  const pkSP=cvSP.reduce((a,b)=>b.y>a.y?b:a), pkEG=cvEG.reduce((a,b)=>b.y>a.y?b:a);
  document.getElementById("spTot").textContent=(v.sp/1e6).toFixed(2)+"M";
  document.getElementById("egTot").textContent=(v.eg/1e6).toFixed(2)+"M";
  document.getElementById("spPk").textContent=Math.round(pkSP.y).toLocaleString();
  document.getElementById("egPk").textContent=Math.round(pkEG.y).toLocaleString();
  document.getElementById("spPkH").textContent=`Pico txn/min (~${{hh(pkSP.min)}})`;
  document.getElementById("egPkH").textContent=`Pico txn/min (~${{hh(pkEG.min)}})`;
  if(showSP)drawPanel("#chartSP",CSP,cvSP,ymax);else d3.select("#chartSP svg").remove();
  if(showEG)drawPanel("#chartEG",CEG,cvEG,ymax);else d3.select("#chartEG svg").remove();
  document.getElementById("note").innerHTML=`Curva = perfil intradia promedio (${{v.tipo}}) &times; volumen diario <b>${{v.origen}}</b> &middot; forma compartida entre canales (r=0.99), niveles propios de cada uno &middot; meseta 13–20h sombreada &middot; escala Y compartida entre paneles &middot; generado por <code>generators/build-curvas-intradia.py</code>`;
}}
function shift(days){{const d=new Date(inp.value);d.setUTCDate(d.getUTCDate()+days);const s=d.toISOString().slice(0,10);if(V[s])inp.value=s;render();}}
document.getElementById("prev").onclick=()=>shift(-1);document.getElementById("next").onclick=()=>shift(1);
document.getElementById("prev7").onclick=()=>shift(-7);document.getElementById("next7").onclick=()=>shift(7);
inp.onchange=render;document.getElementById("cSP").onchange=render;document.getElementById("cEG").onchange=render;
window.addEventListener("resize",render);
render();
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

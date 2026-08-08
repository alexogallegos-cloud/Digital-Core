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
<title>Curvas intradia navegable — BCOPCore</title><script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
body{{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#0f1117;color:#e2e8f0;padding:24px}}
h1{{font-size:18px;font-weight:600;color:#fff;margin-bottom:4px}} .sub{{font-size:11px;color:#64748b;margin-bottom:16px}}
.controls{{display:flex;gap:14px;align-items:center;flex-wrap:wrap;margin-bottom:16px;background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:12px 16px}}
.controls label{{font-size:11px;color:#94a3b8}} input,button{{background:#0f1117;color:#e2e8f0;border:1px solid #2d3548;border-radius:6px;padding:6px 10px;font-size:12px}}
button{{cursor:pointer}} button:hover{{border-color:#3b82f6}}
.badge{{font-size:10px;padding:3px 8px;border-radius:10px;font-weight:600}}
.real{{background:#10331f;color:#4ade80}} .proj{{background:#33280f;color:#f59e0b}}
.kpi-row{{display:flex;gap:12px;margin-bottom:16px;flex-wrap:wrap}}
.kpi{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:10px 16px;min-width:140px}}
.kpi .val{{font-size:20px;font-weight:700}} .kpi .lbl{{font-size:10px;color:#64748b;margin-top:3px}}
.section{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:16px}}
svg text{{fill:#94a3b8}} .axis line,.axis path{{stroke:#2d3548}}
.legend{{display:flex;gap:16px;margin-top:8px;font-size:11px;color:#94a3b8}}
.legend span{{display:inline-flex;align-items:center;gap:6px}} .sw{{width:20px;height:3px;display:inline-block}}
.note{{font-size:9px;color:#475569;margin-top:12px}}
</style></head><body>
<h1>Curvas intradia navegable — SPEI + Autorizador (txn/min)</h1>
<div class="sub">BCOPCore SPE-AM-001 · selecciona cualquier dia de 2025-2026 · <b>real</b> hasta el ultimo dato, <b>proyectado</b> despues</div>
<div class="controls">
  <button id="prev7">◀◀ 7d</button><button id="prev">◀ 1d</button>
  <label>Fecha: <input type="date" id="fecha"></label>
  <button id="next">1d ▶</button><button id="next7">7d ▶▶</button>
  <span id="origen" class="badge"></span><span id="tipo" style="font-size:11px;color:#94a3b8"></span>
  <label style="margin-left:10px"><input type="checkbox" id="cEG" checked> Autorizador</label>
  <label><input type="checkbox" id="cSP" checked> SPEI</label>
</div>
<div class="kpi-row" id="kpis"></div>
<div class="section"><div id="chart"></div>
<div class="legend"><span><span class="sw" style="background:#3b82f6"></span>Autorizador / E-Global</span>
<span><span class="sw" style="background:#10b981"></span>SPEI Entradas</span></div></div>
<div class="note" id="note"></div>
<script>
const DATA={data_js};const P=DATA.perfiles;const V=DATA.vol;const STEP=DATA.step;const BINS=288;
const fechas=Object.keys(V).sort();
const inp=document.getElementById("fecha");
inp.min=fechas[0];inp.max=fechas[fechas.length-1];inp.value=DATA.last_real;

function curva(canal,tipo,volumen){{
  const pf=P[canal][tipo];
  return pf.map((f,i)=>({{min:i*STEP, y: f*volumen/STEP}}));  // txn/min por bin
}}
function render(){{
  const f=inp.value; const v=V[f];
  const oel=document.getElementById("origen"), tel=document.getElementById("tipo");
  d3.select("#chart svg").remove();
  if(!v){{document.getElementById("kpis").innerHTML="";oel.textContent="";tel.textContent="(sin dato para esta fecha)";return;}}
  oel.className="badge "+(v.origen==="real"?"real":"proj");oel.textContent=v.origen.toUpperCase();
  tel.textContent=v.tipo==="habil"?"dia habil":"fin de semana / no habil";
  const showEG=document.getElementById("cEG").checked, showSP=document.getElementById("cSP").checked;
  const cEG=curva("eglobal",v.tipo,v.eg), cSP=curva("spei",v.tipo,v.sp);
  const series=[];if(showEG)series.push(["#3b82f6",cEG]);if(showSP)series.push(["#10b981",cSP]);
  const W=document.getElementById("chart").offsetWidth||1000,H=380,Mg={{top:12,right:20,bottom:34,left:64}};
  const w=W-Mg.left-Mg.right,h=H-Mg.top-Mg.bottom;
  const x=d3.scaleLinear().domain([0,1439]).range([0,w]);
  const ymax=d3.max(series.flatMap(([,c])=>c.map(p=>p.y)))*1.1||1;
  const y=d3.scaleLinear().domain([0,ymax]).range([h,0]);
  const svg=d3.select("#chart").append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{Mg.left}},${{Mg.top}})`);
  svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(6).tickFormat(d=>(d/1000).toFixed(1)+"k"))
   .call(g=>g.select(".domain").remove()).call(g=>g.selectAll(".tick line").clone().attr("x2",w).attr("stroke","#2d3548").attr("stroke-dasharray","3,3"));
  svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).tickValues(d3.range(0,1440,120)).tickFormat(m=>`${{String(m/60|0).padStart(2,"0")}}:00`));
  svg.append("rect").attr("x",x(13*60)).attr("width",x(20*60)-x(13*60)).attr("y",0).attr("height",h).attr("fill","#f59e0b").attr("opacity",.04);
  series.forEach(([c,cur])=>{{
    svg.append("path").datum(cur).attr("fill",c).attr("opacity",.12).attr("d",d3.area().x(p=>x(p.min)).y0(h).y1(p=>y(p.y)).curve(d3.curveBasis));
    svg.append("path").datum(cur).attr("fill","none").attr("stroke",c).attr("stroke-width",2).attr("d",d3.line().x(p=>x(p.min)).y(p=>y(p.y)).curve(d3.curveBasis));
  }});
  const pkEG=cEG.reduce((a,b)=>b.y>a.y?b:a), pkSP=cSP.reduce((a,b)=>b.y>a.y?b:a);
  const hh=m=>`${{String(m/60|0).padStart(2,"0")}}:${{String(m%60).padStart(2,"0")}}`;
  document.getElementById("kpis").innerHTML=`
  <div class="kpi"><div class="val" style="color:#3b82f6">${{(v.eg/1e6).toFixed(2)}}M</div><div class="lbl">E-Global total dia</div></div>
  <div class="kpi"><div class="val" style="color:#10b981">${{(v.sp/1e6).toFixed(2)}}M</div><div class="lbl">SPEI total dia</div></div>
  <div class="kpi"><div class="val" style="color:#3b82f6">${{Math.round(pkEG.y).toLocaleString()}}</div><div class="lbl">Pico E-Global (~${{hh(pkEG.min)}})</div></div>
  <div class="kpi"><div class="val" style="color:#10b981">${{Math.round(pkSP.y).toLocaleString()}}</div><div class="lbl">Pico SPEI (~${{hh(pkSP.min)}})</div></div>`;
  document.getElementById("note").innerHTML=`Curva = perfil intradia promedio (${{v.tipo}}) x volumen diario ${{v.origen}} &middot; forma compartida (r=0.99), niveles ${{v.origen}} &middot; meseta 13-20h sombreada &middot; generado por generators/build-curvas-intradia.py`;
}}
function shift(days){{const d=new Date(inp.value);d.setUTCDate(d.getUTCDate()+days);const s=d.toISOString().slice(0,10);if(V[s])inp.value=s;render();}}
document.getElementById("prev").onclick=()=>shift(-1);document.getElementById("next").onclick=()=>shift(1);
document.getElementById("prev7").onclick=()=>shift(-7);document.getElementById("next7").onclick=()=>shift(7);
inp.onchange=render;document.getElementById("cEG").onchange=render;document.getElementById("cSP").onchange=render;
render();
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

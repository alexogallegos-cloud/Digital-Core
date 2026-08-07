"""
render — Salida del pipeline a HTML (D3) y Markdown en knowledge-base/cross-reference/.
"""

import json
import numpy as np
from datetime import date

from . import model as M
from .factors import FACTOR_LABELS


def _hist_series(df_all, df_clean, channel, model, outlier_dates):
    fit_map = dict(zip(df_clean["d"], np.exp(model.fittedvalues.values)))
    rows = []
    for _, r in df_all.iterrows():
        d = r["d"]
        rows.append({
            "d": str(d),
            "a": int(r[channel]) if r[channel] > 200_000 else None,
            "f": int(fit_map[d]) if d in fit_map else None,
            "out": int(str(d) in outlier_dates),
        })
    return rows


def render_html(df_hist, cal, models, cleans, outliers, results, out_path):
    feats = {c: [x for x in models[c].model.exog_names if x != "const"] for c in models}
    # Solo se marcan en el grafico los dias efectivamente removidos (inexplicables).
    out_dates = {c: {o["date"] for o in outliers[c] if o.get("action") == "removed"} for c in outliers}

    hist_eg = _hist_series(df_hist, cleans["eglobal"], "eglobal", models["eglobal"], out_dates["eglobal"])
    hist_sp = _hist_series(df_hist, cleans["spei"], "spei", models["spei"], out_dates["spei"])

    df_fut = M.build_future(cal, date(2026, 8, 5), date(2027, 8, 4))
    fut_eg = df_fut[(df_fut["is_holiday"] == 0) & (df_fut["dow"] < 5)].reset_index(drop=True)
    fut_sp = df_fut[(df_fut["is_holiday"] == 0)].reset_index(drop=True)
    fc_eg = M.forecast_points(models["eglobal"], fut_eg, feats["eglobal"])
    fc_sp = M.forecast_points(models["spei"], fut_sp, feats["spei"])

    g, gs = results["eglobal"], results["spei"]
    data_js = json.dumps({
        "hist_eg": hist_eg, "hist_sp": hist_sp, "fc_eg": fc_eg, "fc_sp": fc_sp,
        "labels": FACTOR_LABELS,
        "growth": {
            "eg_monthly": g["monthly_growth_pct"], "sp_monthly": gs["monthly_growth_pct"],
            "eg_annual": g["annual_growth_pct"], "sp_annual": gs["annual_growth_pct"],
            "eg_r2": g["r2"], "sp_r2": gs["r2"], "eg_r2_adj": g["r2_adj"], "sp_r2_adj": gs["r2_adj"],
            "eg_nobs": g["n_obs"], "sp_nobs": gs["n_obs"],
        },
        "factors_eg": g["factors"], "factors_sp": gs["factors"],
    }, ensure_ascii=False)

    html = f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8">
<title>BanCoppel — Proyeccion Organica SPEI + E-Global</title>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
  *{{box-sizing:border-box;margin:0;padding:0}}
  body{{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;background:#0f1117;color:#e2e8f0;padding:24px}}
  h1{{font-size:18px;font-weight:600;color:#fff;margin-bottom:4px}}
  .sub{{font-size:11px;color:#64748b;margin-bottom:20px}}
  .kpi-row{{display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap}}
  .kpi{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:12px 18px;min-width:150px}}
  .kpi .val{{font-size:24px;font-weight:700;color:#3b82f6}} .kpi.sp .val{{color:#10b981}}
  .kpi .lbl{{font-size:10px;color:#64748b;margin-top:3px}}
  .section{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:16px;margin-bottom:16px}}
  .section-title{{font-size:12px;font-weight:600;color:#94a3b8;margin-bottom:10px}}
  svg text{{fill:#94a3b8}} .axis line,.axis path{{stroke:#2d3548}}
  .legend{{display:flex;gap:14px;margin-top:6px;font-size:10px;color:#64748b;flex-wrap:wrap}}
  .legend span{{display:inline-flex;align-items:center;gap:5px}}
  .sw{{width:18px;height:2px;display:inline-block}}
  .factors-row{{display:flex;gap:12px;flex-wrap:wrap}}
  .factors{{background:#1e2330;border:1px solid #2d3548;border-radius:8px;padding:14px;flex:1;min-width:300px}}
  .factors h3{{font-size:11px;font-weight:600;color:#94a3b8;margin-bottom:10px}}
  .fb{{display:flex;align-items:center;margin-bottom:5px;gap:6px;font-size:10px}}
  .fn{{width:230px;color:#94a3b8;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
  .bc{{flex:1;height:12px;background:#0f1117;border-radius:2px;position:relative}}
  .bf{{height:100%;border-radius:2px;position:absolute}}
  .fv{{width:56px;text-align:right;font-weight:600}}
  .note{{font-size:9px;color:#475569;margin-top:16px;border-top:1px solid #2d3548;padding-top:10px}}
</style></head><body>
<h1>BanCoppel · Proyeccion Organica SPEI + E-Global</h1>
<div class="sub">BCOPCore SPE-AM-001 · OLS log-lineal · SPEI modelado 7 dias (riel 24/7) con ventana de quincena asimetrica · pipeline generators/forecast · datos 2025-01-01 a 2026-08-04</div>
<div class="kpi-row" id="kpis"></div>
<div class="section"><div class="section-title">E-Global / Autorizador — Volumen dias habiles L-V (txn)</div><div id="ceg"></div>
<div class="legend"><span><span class="sw" style="background:#3b82f6;opacity:.4"></span>Real</span>
<span><span class="sw" style="background:#3b82f6"></span>Tendencia ajustada</span>
<span><span class="sw" style="background:#93c5fd"></span>Proyeccion</span>
<span><span class="sw" style="background:#f59e0b"></span>Outlier removido</span></div></div>
<div class="section"><div class="section-title">SPEI Entradas — Volumen 7 dias incluye fin de semana (txn)</div><div id="csp"></div>
<div class="legend"><span><span class="sw" style="background:#10b981;opacity:.4"></span>Real</span>
<span><span class="sw" style="background:#10b981"></span>Tendencia ajustada</span>
<span><span class="sw" style="background:#6ee7b7"></span>Proyeccion</span>
<span><span class="sw" style="background:#f59e0b"></span>Outlier removido</span></div></div>
<div class="factors-row">
<div class="factors" id="feg"><h3>Factores — E-Global (dias habiles L-V)</h3></div>
<div class="factors" id="fsp"><h3>Factores — SPEI Entradas (7 dias)</h3></div></div>
<div class="note" id="note"></div>
<script>
const DATA={data_js};const g=DATA.growth;
document.getElementById("kpis").innerHTML=`
<div class="kpi"><div class="val">${{g.eg_monthly>0?"+":""}}${{g.eg_monthly.toFixed(2)}}%</div><div class="lbl">Crecimiento mensual E-Global</div></div>
<div class="kpi"><div class="val">${{g.eg_annual>0?"+":""}}${{g.eg_annual.toFixed(1)}}%</div><div class="lbl">Crecimiento anual E-Global</div></div>
<div class="kpi sp"><div class="val">${{g.sp_monthly>0?"+":""}}${{g.sp_monthly.toFixed(2)}}%</div><div class="lbl">Crecimiento mensual SPEI</div></div>
<div class="kpi sp"><div class="val">${{g.sp_annual>0?"+":""}}${{g.sp_annual.toFixed(1)}}%</div><div class="lbl">Crecimiento anual SPEI</div></div>
<div class="kpi"><div class="val">${{g.eg_r2.toFixed(3)}}</div><div class="lbl">R&sup2; E-Global (adj ${{g.eg_r2_adj.toFixed(3)}})</div></div>
<div class="kpi sp"><div class="val">${{g.sp_r2.toFixed(3)}}</div><div class="lbl">R&sup2; SPEI (adj ${{g.sp_r2_adj.toFixed(3)}})</div></div>
<div class="kpi"><div class="val">${{g.eg_nobs}}</div><div class="lbl">Obs E-Global</div></div>
<div class="kpi sp"><div class="val">${{g.sp_nobs}}</div><div class="lbl">Obs SPEI (7 dias)</div></div>`;

function drawChart(id,hist,fc,color,colorFc){{
  const W=document.getElementById(id).offsetWidth||900;const H=250,M={{top:8,right:16,bottom:28,left:68}};
  const w=W-M.left-M.right,h=H-M.top-M.bottom;const pD=d3.timeParse("%Y-%m-%d");
  const hp=hist.map(r=>({{...r,D:pD(r.d)}}));const fp=fc.map(r=>({{...r,D:pD(r.date)}}));
  const allV=[...hp.filter(r=>r.a).map(r=>r.a),...fp.map(r=>r.ci_high)];
  const x=d3.scaleTime().domain([d3.min(hp,r=>r.D),d3.max(fp,r=>r.D)]).range([0,w]);
  const y=d3.scaleLinear().domain([0,d3.max(allV)*1.08]).range([h,0]);
  const fmt=d=>(d/1e6).toFixed(1)+"M";
  const svg=d3.select(`#${{id}}`).append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{M.left}},${{M.top}})`);
  svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(4).tickFormat(fmt)).call(gg=>gg.select(".domain").remove())
    .call(gg=>gg.selectAll(".tick line").clone().attr("x2",w).attr("stroke","#2d3548").attr("stroke-dasharray","3,3"));
  svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).ticks(12).tickFormat(d3.timeFormat("%b '%y"))).call(gg=>gg.select(".domain").attr("stroke","#2d3548"));
  const cut=pD("2026-08-05");
  svg.append("line").attr("x1",x(cut)).attr("x2",x(cut)).attr("y1",0).attr("y2",h).attr("stroke","#475569").attr("stroke-dasharray","4,3");
  svg.append("text").attr("x",x(cut)+3).attr("y",13).attr("font-size",8).attr("fill","#475569").text("Proyeccion");
  svg.append("path").datum(fp).attr("d",d3.area().x(r=>x(r.D)).y0(r=>y(r.ci_low)).y1(r=>y(r.ci_high))).attr("fill",colorFc).attr("opacity",.12);
  svg.append("path").datum(hp.filter(r=>r.a!==null)).attr("d",d3.line().defined(r=>r.a!==null).x(r=>x(r.D)).y(r=>y(r.a))).attr("fill","none").attr("stroke",color).attr("stroke-width",1).attr("opacity",.35);
  const fitted=hp.filter(r=>r.f!==null);
  if(fitted.length)svg.append("path").datum(fitted).attr("d",d3.line().defined(r=>r.f!==null).x(r=>x(r.D)).y(r=>y(r.f))).attr("fill","none").attr("stroke",color).attr("stroke-width",2);
  svg.append("path").datum(fp).attr("d",d3.line().x(r=>x(r.D)).y(r=>y(r.mean))).attr("fill","none").attr("stroke",colorFc).attr("stroke-width",2).attr("stroke-dasharray","6,3");
  svg.selectAll(".out").data(hp.filter(r=>r.out&&r.a)).join("circle").attr("cx",r=>x(r.D)).attr("cy",r=>y(r.a)).attr("r",3.5).attr("fill","#f59e0b").attr("opacity",.85);
}}
drawChart("ceg",DATA.hist_eg,DATA.fc_eg,"#3b82f6","#93c5fd");
drawChart("csp",DATA.hist_sp,DATA.fc_sp,"#10b981","#6ee7b7");

function drawFactors(id,factors,color){{
  const el=document.getElementById(id);const L=DATA.labels;
  const entries=Object.entries(factors).sort((a,b)=>b[1].pct_effect-a[1].pct_effect);
  const mx=Math.max(...entries.map(([,v])=>Math.abs(v.pct_effect)));
  let html="";
  for(const[k,v]of entries){{
    const nm=L[k]||k;const pct=v.pct_effect;const bw=Math.abs(pct)/mx*100;
    const bc=pct>0?(k.startsWith("dow")?color:"#4ade80"):"#f87171";
    const bl=pct<0?`${{100-bw}}%`:"0%";const vc=pct>0?"#4ade80":"#f87171";
    const sv=v.pvalue<0.001?"***":(v.pvalue<0.01?"**":(v.pvalue<0.05?"*":""));
    html+=`<div class="fb"><div class="fn" title="${{nm}}">${{nm}}</div><div class="bc"><div class="bf" style="width:${{bw}}%;left:${{bl}};background:${{bc}};opacity:.75"></div></div><div class="fv" style="color:${{vc}}">${{pct>0?"+":""}}${{pct.toFixed(1)}}%${{sv}}</div></div>`;
  }}
  el.insertAdjacentHTML("beforeend",html);
}}
drawFactors("feg",DATA.factors_eg,"#3b82f6");drawFactors("fsp",DATA.factors_sp,"#10b981");
document.getElementById("note").innerHTML=`OLS log-lineal &middot; SPEI 7 dias (riel 24/7; Sab=112%, Dom=79% del volumen habil) con ventana de quincena Q-1..Q+2 &middot; E-Global solo dias habiles L-V &middot; outliers |t*|>2.5 &middot; R&sup2; E-Global ${{g.eg_r2}} / SPEI ${{g.sp_r2}} &middot; generado por generators/forecast &middot; BCOPCore SPE-AM-001`;
</script></body></html>"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(html)
    print(f"\n  HTML: {out_path}")


def render_markdown(results, models, out_path):
    re_, rs = results["eglobal"], results["spei"]

    def ftable(model):
        rows = []
        for k, lbl in FACTOR_LABELS.items():
            if k not in model.params:
                continue
            b, pv = model.params[k], model.pvalues[k]
            pct = (np.exp(b) - 1) * 100
            sig = "***" if pv < 0.001 else ("**" if pv < 0.01 else ("*" if pv < 0.05 else ""))
            rows.append(f"| {lbl} | {pct:+.1f}% | {pv:.4f} {sig} |")
        return "\n".join(rows)

    md = f"""# Proyeccion de Crecimiento Organico — SPEI Entradas + E-Global
> **Fuente**: pipeline `generators/forecast/` (OLS log-lineal, SPEI 7 dias con ventana de quincena)
> **Version**: 3.1.0 · 2026-08-07 · regenerable con datos nuevos
> **Proyecto**: BanCoppel BCOPCore · SPE-AM-001

---

## Pipeline reproducible

Este documento y su HTML se regeneran ejecutando, desde `BCOPCore/`:

```
python generators/build-forecast-spei.py
```

Los generadores de factores viven en `generators/forecast/factors.py` (un generador por
factor, registrado con `@factor`). Al llegar datos reales nuevos: agregar la fuente en
`generators/forecast/data_sources.py`, registrar cualquier dia atipico en
`generators/forecast/atypical_days.py`, y re-ejecutar.

---

## SPEI es un riel 24/7

El EDA mostro volumen alto todos los dias (Sabado 112%, Domingo 79% del volumen habil L-V);
por eso SPEI se modela sobre los 7 dias. La ventana de quincena se ancla al dia habil de
deposito y es asimetrica: Q+1 pesa mas que Q-1, y el fin de semana absorbe el flujo cuando
el deposito cae en viernes.

---

## Resultados: Crecimiento Organico

| Metrica | E-Global / Autorizador | SPEI Entradas |
|---------|------------------------|---------------|
| **Crecimiento mensual** | **{re_["monthly_growth_pct"]:+.2f}%** | **{rs["monthly_growth_pct"]:+.2f}%** |
| IC 95% mensual | [{re_["monthly_ci_low"]:+.2f}%, {re_["monthly_ci_high"]:+.2f}%] | [{rs["monthly_ci_low"]:+.2f}%, {rs["monthly_ci_high"]:+.2f}%] |
| **Crecimiento anual** | **{re_["annual_growth_pct"]:+.1f}%** | **{rs["annual_growth_pct"]:+.1f}%** |
| R² | {re_["r2"]:.4f} | {rs["r2"]:.4f} |
| R² ajustado | {re_["r2_adj"]:.4f} | {rs["r2_adj"]:.4f} |
| Observaciones | {re_["n_obs"]} dias habiles | {rs["n_obs"]} dias (7-dia) |

---

## Factores Estacionales: E-Global / Autorizador (dias habiles L-V)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
{ftable(models["eglobal"])}

---

## Factores Estacionales: SPEI Entradas (7 dias)

| Factor | Efecto vs lunes base | p-valor |
|--------|----------------------|---------|
{ftable(models["spei"])}

---

*v3.1.0 · 2026-08-07 · Pipeline versionado en generators/forecast/. El analisis de dias
atipicos y su racional viven en `growth-forecast-dias-atipicos.md`.*
"""
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(md)
    print(f"  KB: {out_path}")

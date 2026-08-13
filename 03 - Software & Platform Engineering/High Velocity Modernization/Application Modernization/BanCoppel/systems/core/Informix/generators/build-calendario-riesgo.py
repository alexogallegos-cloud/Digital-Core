#!/usr/bin/env python3
"""
build-calendario-riesgo.py — Informix · Calendario de riesgo de capacidad 2025-2026.

Para cada dia con datos minuto a minuto REALES (2025-01-01..LAST_REAL) mide el RIESGO CORRELACIONADO
= numero de minutos donde SPEI y el Autorizador estan SIMULTANEAMENTE >= su P70 (co-ocurrencia = zona
de riesgo, minuto a minuto de los datos observados). Colorea el dia por nivel (minutos), marca los dias
donde un canal alcanza su P90 (triangulos) y la temporalidad (uplift estacional del modelo SPEI). Los
dias proyectados (sin datos minuto, > LAST_REAL) se marcan aparte y NO calculan riesgo.

Umbrales P70/P90: los del pipeline de percentiles pero en su forma CRUDA (sin holgura) — para DETECTAR
riesgo se compara demanda real vs. umbral observado; la holgura es margen de dimensionamiento, no de
deteccion. Regenerable con datos nuevos.

Uso: python generators/build-calendario-riesgo.py   (ejecutar desde Informix/)
"""
import sys, json, warnings
from pathlib import Path
from datetime import date
warnings.filterwarnings("ignore")

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
from forecast import capacity as C, data_sources as DS, factors as F, atypical_days as A, model as M
from forecast.calendar_mx import MxCalendar
import numpy as np, pandas as pd, statsmodels.api as sm

OUT = ROOT / "portal"
LAST_REAL = date(2026, 8, 4)
END_PROJ = date(2026, 12, 31)
# Taxonomia de riesgo por MINUTOS DE CO-OCURRENCIA REAL (ambos canales >= su P70 crudo, minuto a minuto).
# Fronteras calibradas al rango observado de co-ocurrencia (max ~33 min/dia):
CORTES = [5, 15, 30, 60]   # Bajo <5 / Medio 5-15 / Alto 15-30 / Muy alto 30-60 / Critico >=60
UPLIFT_SUBE = 0.02   # uplift estacional (modelo SPEI) >= +2% marca el dia como "sube por temporalidad"

# Factores de temporalidad -> etiqueta corta para el popup (columna de factors.build_features -> nombre humano).
# Solo eventos con nombre (no dia-de-semana ni interacciones); se muestran los activos de cada dia.
EVENT_LABELS = {
    "is_q15_exact": "Quincena (día 15)", "is_qlast_exact": "Quincena (fin de mes)",
    "is_q1st_exact": "Primer día del mes", "is_d17_exact": "Día 17 (SAT/IMSS)",
    "is_precierre_mes": "Precierre de mes",
    "is_q_dm1": "Víspera de quincena", "is_q_dm2": "Pre-quincena", "is_q_dm3": "Pre-quincena",
    "is_q_dp1": "Post-quincena", "is_q_dp2": "Post-quincena", "is_q_dp3": "Post-quincena", "is_q_dp4": "Post-quincena",
    "is_holiday": "Festivo", "is_holiday_eve": "Víspera de festivo", "is_post_holiday": "Post-festivo",
    "is_semana_santa": "Semana Santa", "is_pre_semana_santa": "Pre-Semana Santa", "is_sabado_gloria": "Sábado de Gloria",
    "is_buen_fin": "Buen Fin", "is_black_cyber": "Black Friday / Cyber",
    "is_aguinaldo": "Aguinaldo", "is_temporada_dic": "Temporada decembrina",
    "is_pre_navidad": "Pre-Navidad", "is_navidad": "Navidad", "is_post_navidad": "Post-Navidad",
    "is_ano_nuevo": "Año Nuevo", "is_cuesta_enero": "Cuesta de enero", "is_reyes": "Día de Reyes",
    "is_pre_dia_nino": "Día del Niño", "is_dia_muertos": "Día de Muertos",
    "is_vispera_guadalupe": "Víspera de Guadalupe", "is_guadalupe": "Día de la Guadalupe",
    "is_10_mayo": "Día de las Madres", "is_pre_dia_madres": "Pre-Día de las Madres", "is_dia_padre": "Día del Padre",
    "is_san_valentin": "San Valentín", "is_dia_maestro": "Día del Maestro", "is_fiestas_patrias": "Fiestas Patrias",
    "is_ptu": "PTU (utilidades)", "is_sat_reembolso": "Reembolso SAT", "is_regreso_clases": "Regreso a clases",
    "is_reyes_compras": "Compras de Reyes",
}


def nivel(rm):
    if rm <= 0: return 0
    for i, c in enumerate(CORTES):
        if rm < c: return i + 1
    return 5


def main():
    cal = MxCalendar(range(2023, 2031))
    print("Volumen diario (real + proyectado) + minuto a minuto (co-ocurrencia real)...")
    df = F.build_features(DS.load_all(ROOT), cal)
    df["is_atypical"] = df["d"].apply(lambda x: int(x in A.to_set()))

    vol = {}
    for _, r in df.iterrows():
        d = r["d"]
        if date(2025, 1, 1) <= d <= LAST_REAL:
            vol[d] = {"sp": int(r["spei"]), "eg": int(r["eglobal"]), "wd": d.weekday(), "o": "real"}

    print("Ajuste de modelos (proyeccion + uplift de temporalidad)...")
    models = {}
    for ch in ("eglobal", "spei"):
        cfg = F.CHANNELS[ch]
        models[ch] = M.fit_channel(df, ch, F.FEATURE_SETS[ch], cfg["include_weekends"], cfg["min_vol"], verbose=False)[0]
    fut = F.build_features(pd.DataFrame({"date": pd.date_range(date(2026, 8, 5), END_PROJ)}), cal)
    for ch in ("eglobal", "spei"):
        feats = [c for c in models[ch].model.exog_names if c != "const"]
        X = sm.add_constant(fut[feats].astype(float), has_constant="add")
        fut[ch + "_p"] = np.exp(models[ch].predict(X)).values
    for _, r in fut.iterrows():
        vol[r["d"]] = {"sp": int(r["spei_p"]), "eg": int(r["eglobal_p"]), "wd": r["d"].weekday(), "o": "proyectado"}

    # uplift estacional del SPEI = prediccion completa / prediccion solo-tendencia - 1 (efecto de todos los factores no-tendencia)
    allf = F.build_features(pd.DataFrame({"date": pd.date_range(date(2025, 1, 1), END_PROJ)}), cal)
    feats = [c for c in models["spei"].model.exog_names if c != "const"]
    Xf = sm.add_constant(allf[feats].astype(float), has_constant="add")
    full = np.exp(models["spei"].predict(Xf)).values
    Xt = Xf.copy()
    for c in feats:
        if c != "t": Xt[c] = 0.0
    trend = np.exp(models["spei"].predict(Xt)).values
    uplift = {allf.iloc[i]["d"]: float(full[i] / trend[i] - 1) for i in range(len(allf))}

    # Temporalidad: etiquetas de EVENTOS activos por dia (columnas de factors en allf que valen >=1)
    from collections import defaultdict as _dd
    _evcols = [c for c in EVENT_LABELS if c in allf.columns]
    temp_by_day = _dd(list)
    for c in _evcols:
        for d in allf.loc[allf[c].astype(float) >= 1, "d"]:
            lab = EVENT_LABELS[c]
            if lab not in temp_by_day[d]:
                temp_by_day[d].append(lab)

    # Umbrales del pipeline de percentiles. Para DETECTAR riesgo (no dimensionar) se usa el P70/P90 CRUDO
    # (sin holgura): demanda real vs. umbral observado. La holgura es margen de dimensionamiento, no de deteccion.
    # Dos conjuntos: OFICIALES (post-fix, mar-2026+) y CONFIRMADOS (pre-fix, 2025+ene/feb 2026).
    pdata = json.loads((OUT / "percentiles-correlacionados.json").read_text(encoding="utf-8"))
    ofi, hol = pdata["oficiales"], pdata["holgura"]
    PICO_CONFIABLE_DESDE = pdata.get("pico_confiable_desde", "2026-03")
    # Oficiales: quitar holgura para obtener el umbral crudo de deteccion
    P70sp = round(ofi["spei"]["p70"] / hol["spei"]);   P90sp = round(ofi["spei"]["p90"] / hol["spei"])
    P70eg = round(ofi["eglobal"]["p70"] / hol["eglobal"]); P90eg = round(ofi["eglobal"]["p90"] / hol["eglobal"])
    # Confirmados: valores directos del cliente (ya son crudos, sin holgura)
    conf = pdata.get("confirmados", {})
    P70sp_c = conf.get("spei",    {}).get("p70", P70sp);  P90sp_c = conf.get("spei",    {}).get("p90", P90sp)
    P70eg_c = conf.get("eglobal", {}).get("p70", P70eg);  P90eg_c = conf.get("eglobal", {}).get("p90", P90eg)
    print(f"  umbrales oficiales  (post-fix): SPEI P70/P90={P70sp:,}/{P90sp:,} | Aut P70/P90={P70eg:,}/{P90eg:,}")
    print(f"  umbrales confirmados (pre-fix): SPEI P70/P90={P70sp_c:,}/{P90sp_c:,} | Aut P70/P90={P70eg_c:,}/{P90eg_c:,}")
    # minuto a minuto REAL para la co-ocurrencia (dias con >=1400 min de dato)
    minSP = {d: dict(mm) for d, mm in C.load_minute_channel(ROOT, "spei").items() if len(mm) >= 1400}
    minEG = {d: dict(mm) for d, mm in C.load_minute_channel(ROOT, "eglobal").items() if len(mm) >= 1400}
    OP = range(13 * 60, 22 * 60)

    dias = {}
    for d, vv in vol.items():
        up = uplift.get(d, 0.0)
        base = {"up": round(up * 100, 1), "sube": int(up >= UPLIFT_SUBE), "o": vv["o"], "temp": temp_by_day.get(d, [])}
        # Seleccionar umbrales segun el periodo del dia
        pre = str(d)[:7] < PICO_CONFIABLE_DESDE
        t70sp, t90sp = (P70sp_c, P90sp_c) if pre else (P70sp, P90sp)
        t70eg, t90eg = (P70eg_c, P90eg_c) if pre else (P70eg, P90eg)
        if d in minSP and d in minEG:            # dia con datos minuto -> CO-OCURRENCIA REAL (minutos ambos >= P70)
            sp, eg = minSP[d], minEG[d]
            rm = sum(1 for m in OP if sp.get(m, 0) >= t70sp and eg.get(m, 0) >= t70eg)
            sp90 = int(max((sp.get(m, 0) for m in OP), default=0) >= t90sp)
            eg90 = int(max((eg.get(m, 0) for m in OP), default=0) >= t90eg)
            dias[str(d)] = {**base, "rm": rm, "lvl": nivel(rm), "sp90": sp90, "eg90": eg90, "proj": 0}
        else:                                    # proyectado: sin datos minuto, no se calcula riesgo real
            dias[str(d)] = {**base, "rm": None, "lvl": 0, "sp90": 0, "eg90": 0, "proj": 1}

    # resumen por año (dias con riesgo, total min de co-ocurrencia real)
    for yr in (2025, 2026):
        dd = [v for k, v in dias.items() if k.startswith(str(yr)) and v["rm"] is not None]
        nr = sum(1 for v in dd if v["rm"] > 0); tot = sum(v["rm"] for v in dd if v["rm"] > 0)
        print(f"  {yr}: dias con riesgo={nr} · total={tot:,} min · dias con dato real={len(dd)}")

    data = json.dumps({"dias": dias, "last_real": str(LAST_REAL),
                       "umbrales": {"spei": {"p70": P70sp, "p90": P90sp},
                                    "eglobal": {"p70": P70eg, "p90": P90eg}},
                       "cortes": CORTES}, ensure_ascii=False)
    _render(data, OUT / "calendario-riesgo.html")
    print("[OK] Calendario de riesgo generado.")


def _render(data_js, path):
    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Informix · Calendario de Riesgo de Capacidad</title>
<script src="https://d3js.org/d3.v7.min.js"></script>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}}
html{{scroll-behavior:smooth}}
body{{background:#060a1a;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}}
.aurora::before{{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.6),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:56vw;height:56vw;right:-14vw;top:6vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.66),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{position:absolute;width:40vw;height:40vw;left:34vw;bottom:-14vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(240,210,36,.16),transparent 70%);animation:f3 32s ease-in-out infinite}}
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
.hero-bar a.back{{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s}}
.hero-bar a.back:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
.glass{{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}}
.wrap{{max-width:1500px;margin:0 auto;padding:92px 26px 40px}}
.topbar{{display:flex;align-items:center;gap:14px;flex-wrap:wrap;padding:14px 18px;margin-bottom:12px}}
.yb{{display:inline-flex;gap:8px}}
.yb button{{background:rgba(255,255,255,.05);color:var(--muted);border:1px solid var(--glassb);border-radius:12px;padding:9px 18px;font-size:15px;font-weight:800;font-family:inherit;cursor:pointer;transition:.2s;letter-spacing:-.01em}}
.yb button.on{{color:#7ee0ff;border-color:#38bdf8;background:rgba(56,189,248,.10)}}
.yb button .proy{{font-size:9px;font-weight:700;letter-spacing:.1em;color:var(--yellow);margin-left:6px;vertical-align:middle}}
.stat{{margin-left:auto;font-size:12px;color:var(--muted)}} .stat b{{color:var(--ink);font-variant-numeric:tabular-nums}}
.legend{{display:flex;gap:16px;align-items:center;flex-wrap:wrap;padding:12px 18px;margin-bottom:16px;font-size:11px;color:var(--muted)}}
.legend .lt{{font-size:10px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-right:2px}}
.legend .li{{display:inline-flex;align-items:center;gap:6px}}
.legend .sw{{width:15px;height:15px;border-radius:4px;flex-shrink:0;border:1px solid rgba(255,255,255,.14)}}
.legend .sep{{width:1px;height:18px;background:rgba(255,255,255,.12);margin:0 4px}}
.legend .tri{{width:0;height:0;border-style:solid}}
.months{{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}}
@media(max-width:1200px){{.months{{grid-template-columns:repeat(2,1fr)}}}}
@media(max-width:760px){{.months{{grid-template-columns:1fr}}}}
.month{{padding:16px 16px 18px}}
.mh{{display:flex;align-items:baseline;gap:8px;margin-bottom:10px}}
.mh .mn{{font-size:13px;font-weight:800;letter-spacing:.08em;text-transform:uppercase}}
.mh .ms{{margin-left:auto;font-size:10px;color:var(--muted2);letter-spacing:.04em}}
.mh .ms.r{{color:#ffb4a2}}
.dow{{display:grid;grid-template-columns:repeat(7,1fr);gap:5px;margin-bottom:5px}}
.dow span{{font-size:9px;color:var(--muted2);text-align:center;letter-spacing:.05em}}
.grid{{display:grid;grid-template-columns:repeat(7,1fr);gap:5px}}
.cell{{position:relative;aspect-ratio:1;border-radius:7px;border:1px solid rgba(255,255,255,.06);
 display:flex;align-items:flex-start;justify-content:flex-start;padding:5px 6px;font-size:11px;color:var(--muted);overflow:hidden;transition:.15s}}
.cell.has{{cursor:pointer}}
.cell.has:hover{{transform:translateY(-2px);border-color:rgba(255,255,255,.28);z-index:5}}
.cell.empty{{border-color:transparent;background:transparent}}
.cell.sube{{border:1.5px dashed var(--yellow)}}
.cell.proj{{opacity:.5;background-image:repeating-linear-gradient(45deg,transparent,transparent 4px,rgba(255,255,255,.05) 4px,rgba(255,255,255,.05) 8px)}}
.cell .tri{{position:absolute;width:0;height:0;border-style:solid}}
.cell .t-eg{{top:0;right:0;border-width:0 11px 11px 0;border-color:transparent #38bdf8 transparent transparent}}
.cell .t-sp{{bottom:0;left:0;border-width:11px 0 0 11px;border-color:transparent transparent transparent #2dd4bf}}
#tt{{position:fixed;z-index:80;pointer-events:none;opacity:0;transition:opacity .12s;background:rgba(8,12,28,.97);
 border:1px solid var(--glassb);border-radius:12px;padding:10px 13px;font-size:11px;color:var(--ink);max-width:230px;box-shadow:0 14px 40px rgba(0,0,0,.55)}}
#tt .tm{{font-weight:800;margin-bottom:4px}} #tt .tl{{color:var(--muted);line-height:1.7}}
footer{{text-align:center;padding:34px 0 8px;font-size:11px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);margin-top:28px}}
</style></head><body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div id="tt"></div>
<div class="hero-bar">
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div class="hb-sep"></div>
  <span class="crumb">BCOPCORE &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>CALENDARIO DE RIESGO</em></span>
  <span class="hb-sp"></span>
  <a href="curvas-intradia-navegable.html" class="back">Curvas intradía →</a>
  <a href="percentiles-correlacionados-evolucion.html" class="back">Percentiles →</a>
</div>
<div class="wrap">
  <div class="hero-label" style="font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:10px">Capacidad · Calendario de Riesgo</div>
  <h1 style="font-size:clamp(26px,4vw,42px);font-weight:900;letter-spacing:-.035em;line-height:1;background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent">Calendario de Riesgo de Capacidad</h1>
  <p style="margin-top:12px;font-size:13px;color:var(--muted);line-height:1.6;max-width:88ch">Riesgo diario = <b>minutos reales donde SPEI y el Autorizador están simultáneamente ≥ su P70</b> (co-ocurrencia = zona de riesgo, minuto a minuto de los datos observados; umbral crudo de detección, sin holgura). Cada día se colorea por nivel; los triángulos marcan si un canal alcanzó su <b>P90</b> ese día; el borde punteado marca días que <b>suben por temporalidad</b> (uplift estacional). Los días <b>proyectados</b> (sin datos minuto) no calculan riesgo.</p>
  <div class="topbar glass">
    <div class="yb"><button id="y2025">2025</button><button id="y2026" class="on">2026 <span class="proy">PROY</span></button></div>
    <span class="stat" id="stat"></span>
  </div>
  <div class="legend glass">
    <span class="lt">Riesgo:</span>
    <span class="li"><span class="sw" style="background:#0a0e1f"></span>Ninguno</span>
    <span class="li"><span class="sw" style="background:#2b2550"></span>Solo temporalidad</span>
    <span class="li"><span class="sw" style="background:#1a5e3a"></span>Bajo &lt;5</span>
    <span class="li"><span class="sw" style="background:#7a7320"></span>Medio 5–15</span>
    <span class="li"><span class="sw" style="background:#b45309"></span>Alto 15–30</span>
    <span class="li"><span class="sw" style="background:#c0392b"></span>Muy alto 30–60</span>
    <span class="li"><span class="sw" style="background:#d61f69"></span>Crítico &gt;60</span>
    <span class="li"><span class="sw" style="border:1.5px dashed var(--yellow);background:transparent"></span>Sube por temporalidad</span>
    <span class="sep"></span>
    <span class="li"><span class="tri" style="border-width:0 12px 12px 0;border-color:transparent #38bdf8 transparent transparent"></span>Auth ≥ P90</span>
    <span class="li"><span class="tri" style="border-width:12px 0 0 12px;border-color:transparent transparent transparent #2dd4bf"></span>SPEI ≥ P90</span>
  </div>
  <div class="months" id="months"></div>
  <div style="font-size:10px;color:var(--muted2);margin-top:18px;line-height:1.6" id="note"></div>
</div>
<footer>Informix · Gemelo Cognitivo del Sistema · SPE-AM-001 · Accenture México · 2026</footer>
<script>
const DATA={data_js};const D=DATA.dias;const U=DATA.umbrales;
const MESES=["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
const DOW=["Do","Lu","Ma","Mi","Ju","Vi","Sa"];
const LVL=["#0a0e1f","#1a5e3a","#7a7320","#b45309","#c0392b","#d61f69"];   // 0 Ninguno .. 5 Critico
const TEMPORAL="#2b2550";
const NLBL=["Ninguno","Bajo","Medio","Alto","Muy alto","Crítico"];
let YEAR=2026;
const tip=document.getElementById("tt");
const pad=n=>String(n).padStart(2,"0");
function color(info){{
  if(!info) return "#0a0e1f";
  if(info.proj) return "#111830";                 // proyectado: sin calculo de riesgo
  if(info.rm>0) return LVL[info.lvl];
  return info.sube ? TEMPORAL : "#0a0e1f";
}}
function showTip(ev,key,info){{
  const [y,m,d]=key.split("-").map(Number);
  let body="";
  if(!info){{body=`<div class="tl">Sin dato para esta fecha (hueco en la fuente).</div>`;}}
  else{{
    const niv = info.proj ? `<span style="color:var(--muted2)">Proyectado — sin datos minuto, riesgo no calculado</span>`
                          : (info.rm>0 ? `<b style="color:${{LVL[info.lvl]}}">${{NLBL[info.lvl]}}</b> · ${{info.rm}} min de co-ocurrencia real (ambos ≥ P70)`
                          : (info.sube ? `Solo temporalidad (sin riesgo)` : `Sin riesgo`));
    let extra="";
    if(info.temp && info.temp.length) extra+=`<div class="tl"><b style="color:var(--yellow)">Temporalidad:</b> ${{info.temp.join(" &middot; ")}}</div>`;
    if(info.eg90) extra+=`<div class="tl">▲ Autorizador alcanzó su P90 (${{U.eglobal.p90.toLocaleString()}})</div>`;
    if(info.sp90) extra+=`<div class="tl">▲ SPEI alcanzó su P90 (${{U.spei.p90.toLocaleString()}})</div>`;
    if(info.sube) extra+=`<div class="tl">Uplift estacional SPEI: <b style="color:var(--yellow)">+${{info.up}}%</b> sobre tendencia</div>`;
    body=`<div class="tl">${{niv}}</div>${{extra}}<div class="tl" style="color:var(--muted2)">${{info.o}}</div>`;
  }}
  tip.innerHTML=`<div class="tm">${{d}} ${{MESES[m-1]}} ${{y}}</div>${{body}}`;
  tip.style.opacity=1;
  tip.style.left=Math.min(ev.clientX+14,window.innerWidth-244)+"px";
  tip.style.top=Math.min(ev.clientY+14,window.innerHeight-120)+"px";
}}
function render(){{
  const cont=document.getElementById("months");cont.innerHTML="";
  let yr=0, ytot=0;
  for(let m=0;m<12;m++){{
    const first=new Date(Date.UTC(YEAR,m,1)).getUTCDay();      // 0=Do
    const ndays=new Date(Date.UTC(YEAR,m+1,0)).getUTCDate();
    let mr=0, mmin=0, cells="";
    for(let i=0;i<first;i++) cells+=`<div class="cell empty"></div>`;
    for(let dnum=1;dnum<=ndays;dnum++){{
      const key=`${{YEAR}}-${{pad(m+1)}}-${{pad(dnum)}}`;
      const info=D[key];
      const has=info!==undefined;
      if(has&&info.rm>0){{mr++;mmin+=info.rm;}}
      const cls="cell "+(has?"has":"empty2")+(has&&info.sube?" sube":"")+(has&&info.proj?" proj":"");
      const bg=color(info);
      let tri="";
      if(has&&info.eg90) tri+=`<span class="tri t-eg"></span>`;
      if(has&&info.sp90) tri+=`<span class="tri t-sp"></span>`;
      const txtcol = (has&&info.rm>=30)?"#fff":"var(--muted)";
      cells+=`<div class="${{cls}}" style="background:${{bg}};color:${{txtcol}}" data-k="${{key}}">${{dnum}}${{tri}}</div>`;
    }}
    yr+=mr; ytot+=mmin;
    const hdr = mr>0 ? `<span class="ms r">${{mr}}d · ${{mmin.toLocaleString()}} min</span>` : `<span class="ms">sin riesgo</span>`;
    cont.innerHTML+=`<div class="month glass"><div class="mh"><span class="mn">${{MESES[m]}}</span>${{hdr}}</div>`
      +`<div class="dow">${{DOW.map(x=>`<span>${{x}}</span>`).join("")}}</div><div class="grid">${{cells}}</div></div>`;
  }}
  document.getElementById("stat").innerHTML=`Días con riesgo: <b>${{yr}}</b> &nbsp;|&nbsp; Total: <b>${{ytot.toLocaleString()}} min</b>`;
  // hover binding (delegado)
  cont.querySelectorAll(".cell.has").forEach(el=>{{
    el.addEventListener("mousemove",ev=>showTip(ev,el.dataset.k,D[el.dataset.k]));
    el.addEventListener("mouseleave",()=>tip.style.opacity=0);
    el.addEventListener("click",()=>{{location.href="curvas-intradia-navegable.html?d="+el.dataset.k;}});
  }});
  document.getElementById("note").innerHTML=`Riesgo = <b>minutos reales de co-ocurrencia</b> (SPEI y Autorizador ≥ su P70 a la vez, minuto a minuto de los datos observados; P70 crudo de detección: SPEI ${{U.spei.p70.toLocaleString()}}, Aut ${{U.eglobal.p70.toLocaleString()}}) &middot; niveles &lt;5 / 5–15 / 15–30 / 30–60 / &gt;60 min &middot; ▲ = el canal alcanzó su P90 (SPEI ${{U.spei.p90.toLocaleString()}}, Aut ${{U.eglobal.p90.toLocaleString()}}) ese día &middot; borde punteado = uplift estacional SPEI ≥ +2% &middot; celdas rayadas = <b>proyectado</b> (sin datos minuto, riesgo no calculado; real hasta ${{DATA.last_real}}) &middot; generado por <code>generators/build-calendario-riesgo.py</code>`;
}}
document.getElementById("y2025").onclick=()=>{{YEAR=2025;document.getElementById("y2025").classList.add("on");document.getElementById("y2026").classList.remove("on");render();}};
document.getElementById("y2026").onclick=()=>{{YEAR=2026;document.getElementById("y2026").classList.add("on");document.getElementById("y2025").classList.remove("on");render();}};
render();
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

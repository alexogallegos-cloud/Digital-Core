#!/usr/bin/env python3
"""
build-percentiles-correlacionados.py — BCOPCore · Percentiles CORRELACIONADOS SPEI+Autorizador.

Calculo de percentiles: P70 y P90 por canal (SPEI y Autorizador) sobre TODAS las ventanas PROMEDIO
de 10 min dentro del horario operativo, mes a mes.
 - P70 por canal = umbral de alerta;  P90 = incidencia.
 - zona de riesgo (KPI) = % de ventanas con AMBOS >= su P70.
Genera la evolucion mensual (2025-2026) + los umbrales del ultimo mes, en HTML/MD/JSON.
(La capacidad top-N que devuelve capacity.py se conserva en el JSON pero ya NO se grafica.)

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
# El pico maximo procesado (linea cian) solo es CONFIABLE a partir del primer fix: antes conviven los
# 7 encolamientos + el connection leak (INC-20251223), que distorsionan el throughput medido (colas
# atascadas -> pico artificialmente bajo, o drenados de cola -> pico artificialmente alto). Se limpia
# (null) todo mes anterior al primer fix. Se deriva del primer hito para quedar consistente con la grafica.
PICO_CONFIABLE_DESDE = min(HITOS)  # "2026-03" (leak-fix)
# Holgura de dimensionamiento POR CANAL, aplicada a TODOS los umbrales P70/P90/P99 (el max observado
# max_1h va SIN holgura como referencia de la realidad).
# REGLA (2026-08-08): solo se asigna holgura a un canal con MARGEN REAL. Un canal que YA TOPA su techo
# NO recibe holgura hasta que haya acciones de REMEDIACION que suban el techo — provisionar 10% sobre
# un techo duro que ya se alcanza es fabricar capacidad inexistente. El Autorizador topa su techo de
# throughput (~4,300 txn/min, cuello = pool de conexiones/BD/HSM; ver growth-forecast-autorizador-spei.md)
# => holgura 1.00 hasta remediar. SPEI tiene margen (ráfagas, no topa) => 1.10.
HOLGURA = {"spei": 1.10, "eglobal": 1.00}
# Evidencia de mejora MEDIDA (no derivada de un factor) — ver knowledge-base/autorizador/mejoras-2026.md.
# Encolamientos: 7 incidentes nov-2025→ene-2026 -> 0 después (feb-2026 = primer mes limpio, balanceo 15-feb).
# Duración de incidente: 1.5-7.5 h (nov-dic 2025) -> ~18.5 min post-Power10 (~-93% impacto por evento).
INCIDENTES = {"periodo": ["2025-11-15", "2026-01-31"], "pre": 7, "post": 0,
              "dur_pre": "1.5–7.5 h", "dur_post": "18.5 min", "impacto": "−93%"}


def main():
    cal = MxCalendar(range(2023, 2031))
    print("Cargando minxmin de ambos canales (una vez)...")
    egm = {(d, m): v for d, mm in C.load_minute_channel(ROOT, "eglobal").items()
           if len(mm) >= 1400 for m, v in mm}
    spm = {(d, m): v for d, mm in C.load_minute_channel(ROOT, "spei").items()
           if len(mm) >= 1400 for m, v in mm}

    # Percentiles del PICO DIARIO por mes/canal. Para cada dia se toma su hora de mayor carga sostenida
    # (mayor ventana de 1 h, promedio txn/min sobre 60 min, 13-22h); P70/P90/P99 son percentiles sobre
    # esos picos diarios del mes. Asi los tres umbrales viven en el regimen de CARGA ALTA (no diluidos
    # por las horas medias del dia). Interpretacion de capacidad:
    #   P99 = el pico diario se supera solo 1% de los dias (dia peor = techo, no llegar nominalmente),
    #   P90 = 10% de los dias (incidente), P70 = 30% de los dias (alerta).
    # El max absoluto del mes es un outlier por encima del P99; se guarda como max_1h pero NO se grafica.
    from collections import defaultdict as _dd
    _WPICO = 60
    def _pct(a, p):
        if not a: return 0.0
        a = sorted(a); k = (len(a) - 1) * p / 100.0; f = int(k); c = min(f + 1, len(a) - 1)
        return a[f] + (a[c] - a[f]) * (k - f)
    def _pctls1h_mes(dic):
        perhr = _dd(list)
        for (d, m), v in dic.items():
            if 13*60 <= m < 22*60:
                perhr[(d, m // _WPICO)].append(v)
        byday = {}                                       # pico diario = mayor hora sostenida del dia
        for (d, _hb), vs in perhr.items():
            if len(vs) == _WPICO:                        # solo horas completas (60 min)
                h = sum(vs) / _WPICO
                if h > byday.get(d, 0.0): byday[d] = h
        bym = _dd(list)
        for d, h in byday.items():
            bym[(d.year, d.month)].append(h)             # un pico por dia -> distribucion de picos diarios
        return {ym: {"p70": round(_pct(ms, 70)), "p90": round(_pct(ms, 90)),
                     "p99": round(_pct(ms, 99)), "max": round(max(ms))}
                for ym, ms in bym.items()}
    _q_sp, _q_eg = _pctls1h_mes(spm), _pctls1h_mes(egm)

    # evolucion MENSUAL — rango AUTO-DETECTADO de los datos: meses con >=15 dias completos (evita meses
    # a medias). Se EXTIENDE SOLO al cargar datos nuevos.
    #   P70/P90 (todos los meses) = percentiles del PICO DIARIO (regimen de carga alta).
    #   P99 (techo) SOLO post-fix (>= PICO_CONFIABLE_DESDE): pre-fix el pico diario esta contaminado por
    #   los encolamientos + connection leak (queue-flush), asi que su cola alta no es confiable.
    _dias_mes = _dd(set)
    for (d, _m) in egm:
        _dias_mes[(d.year, d.month)].add(d)
    meses_validos = sorted(ym for ym, ds in _dias_mes.items() if len(ds) >= 15)
    print(f"  meses con datos (>=15 dias): {meses_validos[0][0]}-{meses_validos[0][1]:02d} .. "
          f"{meses_validos[-1][0]}-{meses_validos[-1][1]:02d} ({len(meses_validos)} meses)")
    meses = []
    for (y, mo) in meses_validos:
        d0 = date(y, mo, 1); d1 = date(y, mo, monthrange(y, mo)[1])
        r = C.correlated_percentiles(ROOT, cal, d0, d1, w=10, _egm=egm, _spm=spm)   # solo para zona de riesgo + correlacion
        r["mes"] = f"{y}-{mo:02d}"
        r["x"] = str(date(y, mo, 15))             # fecha representativa (mitad de mes) para el eje temporal
        qs, qe = _q_sp.get((y, mo)), _q_eg.get((y, mo))
        _h = lambda v, ch: round(v * HOLGURA[ch])   # holgura de dimensionamiento POR CANAL
        # P70/P90 = percentiles del PICO DIARIO (todos los meses, regimen de carga alta) + holgura por canal
        r["p70"] = {"spei": _h(qs["p70"], "spei"), "eglobal": _h(qe["p70"], "eglobal")}
        r["p90"] = {"spei": _h(qs["p90"], "spei"), "eglobal": _h(qe["p90"], "eglobal")}
        if r["mes"] >= PICO_CONFIABLE_DESDE:
            # techo P99 solo en regimen confiable (pre-fix contaminado por queue-flush)
            r["p99"] = {"spei": _h(qs["p99"], "spei"), "eglobal": _h(qe["p99"], "eglobal")}
            r["max_1h"] = {"spei": qs["max"], "eglobal": qe["max"]}   # observado, SIN holgura
        else:
            r["p99"] = {"spei": None, "eglobal": None}
            r["max_1h"] = {"spei": None, "eglobal": None}
        meses.append(r)
        print(f"  {r['mes']}: SPEI P70={r['p70']['spei']:>5,} P90={r['p90']['spei']:>5,} | "
              f"Aut P70={r['p70']['eglobal']:>5,} P90={r['p90']['eglobal']:>5,} | "
              f"riesgo={r['pct_zona_riesgo']:>4}% r={r['correlacion']}")

    actual = meses[-1]
    # PERCENTILES OFICIALES por canal = maximo historico de cada umbral sobre la evolucion (mismo criterio
    # que las lineas de referencia de curvas intradia). Son la cifra de referencia del canal: P70 alerta,
    # P90 incidente. (P99 techo se incluye para dimensionamiento.)
    def _maxhist(ch, k):
        vals = [m[k][ch] for m in meses if m[k][ch] is not None]
        return max(vals) if vals else None
    oficiales = {ch: {"p70": _maxhist(ch, "p70"), "p90": _maxhist(ch, "p90"), "p99": _maxhist(ch, "p99")}
                 for ch in ("spei", "eglobal")}
    _hp = {c: f"+{round((HOLGURA[c]-1)*100)}%" for c in HOLGURA}
    print(f"  percentiles OFICIALES (max hist; holgura SPEI {_hp['spei']}, Aut {_hp['eglobal']}): "
          f"SPEI P70/P90={oficiales['spei']['p70']:,}/{oficiales['spei']['p90']:,} | "
          f"Aut P70/P90={oficiales['eglobal']['p70']:,}/{oficiales['eglobal']['p90']:,}")
    report = {"metodologia": "percentiles correlacionados por canal (SPEI y Autorizador), sin combinado, todos los dias 13-22h; "
              "P70/P90/P99 sobre el PICO DIARIO (hora de mayor carga sostenida de cada dia, ventana de 1 h; percentil sobre los dias del mes): "
              "P99=techo (pico diario superado 1% de los dias=dia peor), P90=incidente (10% de dias), P70=alerta (30% de dias); "
              "P99 solo desde el leak-fix (mes>=2026-03); pre-fix el pico diario esta contaminado por encolamientos + connection leak; "
              "zona de riesgo = ambos canales >= su P70 a la vez. "
              "HOLGURA de dimensionamiento POR CANAL sobre P70/P90/P99 (max_1h va SIN holgura). REGLA: solo se asigna holgura a un canal "
              "con margen real; un canal que topa su techo NO recibe holgura hasta REMEDIAR. SPEI +10% (tiene margen); "
              "Autorizador +0% (topa su techo ~4,300 txn/min, cuello pool de conexiones/BD/HSM). "
              "PERCENTILES OFICIALES del canal = maximo historico de P70/P90 (bloque 'oficiales'), = lineas de referencia de curvas intradia",
              "pico_confiable_desde": PICO_CONFIABLE_DESDE,
              "holgura": HOLGURA,
              "oficiales": oficiales,
              "actual": actual, "evolucion": meses}
    (OUT / "percentiles-correlacionados.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")

    _render_md(meses, actual, oficiales, OUT / "percentiles-correlacionados.md")
    _render_html(meses, actual, OUT / "percentiles-correlacionados-evolucion.html")
    print("\n[OK] Percentiles correlacionados generados.")


def _render_md(meses, a, oficiales, path):
    def _f99(m, ch):
        v = m.get("p99", {}).get(ch)
        return f"{v:,}" if v else "—"
    def _of(ch, k):
        v = oficiales[ch][k]
        return f"{v:,}" if v is not None else "—"
    filas = "\n".join(
        f"| {m['mes']} | {m['p70']['spei']:,} | {m['p90']['spei']:,} | {_f99(m,'spei')} | "
        f"{m['p70']['eglobal']:,} | {m['p90']['eglobal']:,} | {_f99(m,'eglobal')} |"
        for m in meses)
    md = f"""# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.5.0 (holgura de dimensionamiento POR CANAL: SPEI +10%, Autorizador +0% por topar su techo) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman (la suma combinada no es la métrica de
interés). **Todos los días** (SPEI y el Autorizador operan también el fin de semana), horario
operativo **13–22h**. Evolución **mensual**; el rango de meses se **auto-detecta** de los datos
(meses con ≥15 días completos), así que se extiende solo al cargar datos nuevos.

Los tres umbrales se calculan sobre el **pico diario**: para cada día se toma su **hora de mayor
carga sostenida** (mayor ventana de 1 h, promedio txn/min sobre 60 min, 13–22h), y los percentiles
se sacan sobre esos picos diarios del mes. Así los tres viven en el **régimen de carga alta** (no
diluidos por las horas medias del día):

- **P99 — techo**: el pico diario se supera solo **1% de los días** (el día peor); no se debe
  alcanzar de forma nominal. Es el ancla de dimensionamiento del target.
- **P90 — incidente**: superado **10% de los días**. **P70 — alerta**: superado **30% de los días**.

El **P99 solo se muestra desde el leak-fix de mar-2026** (régimen confiable): antes, el pico diario
está contaminado por los encolamientos y el connection leak (INC-20251223), así que su cola alta no
es confiable. Los P70/P90 (más robustos) se muestran en toda la serie.

> La **correlación** es lo que hace correlacionado al método: los picos de ambos canales coinciden
> en el tiempo (mismo perfil intradía, r≈0.99), no se diversifican y la carga se apila sobre Informix.
> **Zona de riesgo** = ambos canales ≥ su P70 a la vez.

## Percentiles OFICIALES por canal (máx histórico) — umbrales de referencia

Son la cifra oficial del canal: el **máximo histórico** de cada umbral sobre la evolución (el mismo
valor que dibuja curvas intradía como líneas de referencia). El P70 (alerta) y el P90 (incidente)
son los **percentiles oficiales** para operación; el P99 es el techo de dimensionamiento.
**Holgura de dimensionamiento por canal** — REGLA: solo se asigna holgura a un canal con margen real;
un canal que **topa su techo** NO recibe holgura hasta que haya remediación. **SPEI: +10%** (tiene
margen). **Autorizador: +0%** (topa su techo ~4,300 txn/min; cuello = pool de conexiones/BD/HSM).

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | {_of('spei','p70')} | {_of('spei','p90')} | {_of('spei','p99')} |
| Autorizador | {_of('eglobal','p70')} | {_of('eglobal','p90')} | {_of('eglobal','p99')} |

> Autorizador: su P90 y P99 quedan al mismo nivel (~3,600) porque **topa un techo real** y su carga
> está censurada en los picos (ver DT-Autorizador y `growth-forecast-autorizador-spei.md`).

Último mes ({a['mes']}), como referencia de la tendencia: SPEI P70/P90 {a['p70']['spei']:,}/{a['p90']['spei']:,},
Autorizador {a['p70']['eglobal']:,}/{a['p90']['eglobal']:,}.

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
{filas}

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal
sobre el **pico diario** (hora de mayor carga sostenida de cada día; P99 = techo del día peor) ·
evolución mensual · gráfica en `percentiles-correlacionados-evolucion.html`.*
"""
    path.write_text(md, encoding="utf-8")
    print(f"  MD: {path}")


def _render_html(meses, a, path):
    data = json.dumps({"meses": meses, "hitos": HITOS, "inc": INCIDENTES}, ensure_ascii=False)
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
  <a href="calendario-riesgo.html" class="back">Calendario →</a>
</div>
<div class="wrap">
  <div class="hero-label">Capacidad · Percentiles Correlacionados</div>
  <h1 class="hero-h1">Percentiles Correlacionados por Canal</h1>
  <p class="hero-sub"><b>P99</b> (techo — no llegar nominalmente), <b>P90</b> (incidente) y <b>P70</b> (alerta) por canal, calculados sobre el <b>pico diario</b>: la hora de mayor carga sostenida de cada día (ventana de 1 h, 13–22h) y su percentil sobre los días del mes. Así el P99 es el pico del <b>día peor</b> (superado 1% de los días), el P90 el de un día alto (10%) y el P70 el de un día por encima de lo típico (30%). El P99 se muestra desde el <b>leak-fix de mar-2026</b>; antes, el pico diario está distorsionado por los encolamientos y el connection leak. <b>SPEI</b> incluye un <b>10% de holgura</b> de dimensionamiento; el <b>Autorizador NO</b> — ya topa su techo, y la regla es no asignar holgura a un canal saturado hasta que haya acciones de remediación.</p>
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
    <span><span class="sw" style="background:var(--p90)"></span>P90 (incidente)</span>
    <span><span class="sw" style="background:#38bdf8"></span>P99 (techo — no nominal)</span>
    <span><span class="sw" style="background:#ff6b6b;opacity:.4"></span>periodo no confiable (nov'25–ene'26)</span>
  </div>
  <div class="note" id="note"></div>
</div>
<footer>BCOPCore · Gemelo Cognitivo del Sistema · SPE-AM-001 · Accenture México · 2026</footer>
<script>
const DATA={data};const M=DATA.meses;const pD=d3.timeParse("%Y-%m-%d");const INC=DATA.inc;
M.forEach(m=>{{m.D=pD(m.x);
  m.sp70=m.p70.spei;   m.sp90=m.p90.spei;   m.sp99=m.p99.spei;
  m.eg70=m.p70.eglobal;m.eg90=m.p90.eglobal;m.eg99=m.p99.eglobal;}});
const a=M[M.length-1];
// PERCENTILES OFICIALES por canal = MAXIMO HISTORICO de P70/P90 (mismo calculo que las lineas de referencia de curvas intradia)
const mxSp70=d3.max(M,m=>m.sp70), mxSp90=d3.max(M,m=>m.sp90);
const mxEg70=d3.max(M,m=>m.eg70), mxEg90=d3.max(M,m=>m.eg90);
document.getElementById("kpis").innerHTML=`
<div class="kpi glass"><div class="val" style="color:#38bdf8">${{mxSp70.toLocaleString()}} / ${{mxSp90.toLocaleString()}}</div><div class="lbl">SPEI — P70 / P90 oficiales (máx histórico +10% holgura · txn/min)</div></div>
<div class="kpi glass"><div class="val" style="color:#38bdf8">${{mxEg70.toLocaleString()}} / ${{mxEg90.toLocaleString()}}</div><div class="lbl">Autorizador — P70 / P90 oficiales (máx histórico · <b style="color:#ff5c5c">SIN holgura: topa techo</b> · txn/min)</div></div>`;

const tip=document.getElementById("tt");
function showTip(ev,mes,color,label,valStr){{
 tip.style.opacity=1;
 tip.style.left=Math.min(ev.clientX+14,window.innerWidth-190)+"px";
 tip.style.top=(ev.clientY-14)+"px";
 tip.innerHTML=`<div class="tm">${{mes}}</div><div class="tr"><span class="tdot" style="background:${{color}}"></span><span>${{label}}</span><span class="tv">${{valStr}}</span></div>`;
}}
function hideTip(){{tip.style.opacity=0;}}

function chart(id,keys,cols,labels,ymaxVal,fmt,tf,H,dashes){{
 d3.select("#"+id+" svg").remove();
 const W=document.getElementById(id).offsetWidth||560,Mg={{top:12,right:16,bottom:26,left:52}};
 const w=W-Mg.left-Mg.right,h=H-Mg.top-Mg.bottom;
 const x=d3.scaleTime().domain(d3.extent(M,m=>m.D)).range([0,w]);
 const y=d3.scaleLinear().domain([0,ymaxVal]).range([h,0]);
 const svg=d3.select("#"+id).append("svg").attr("width",W).attr("height",H).append("g").attr("transform",`translate(${{Mg.left}},${{Mg.top}})`);
 svg.append("g").attr("class","axis").call(d3.axisLeft(y).ticks(5).tickFormat(fmt)).call(g=>g.select(".domain").remove())
  .call(g=>g.selectAll(".tick line").clone().attr("x2",w).attr("stroke","rgba(255,255,255,.06)"));
 svg.append("g").attr("class","axis").attr("transform",`translate(0,${{h}})`).call(d3.axisBottom(x).ticks(8).tickFormat(d3.timeFormat("%b'%y"))).call(g=>g.select(".domain").remove());
 const iA=pD(INC.periodo[0]), iB=pD(INC.periodo[1]);
 if(iA&&iB){{svg.append("rect").attr("x",x(iA)).attr("width",x(iB)-x(iA)).attr("y",0).attr("height",h)
   .attr("fill","#ff6b6b").attr("opacity",.10);
   svg.append("text").attr("x",(x(iA)+x(iB))/2).attr("y",10).attr("text-anchor","middle").attr("font-size",8).attr("fill","#ff6b6b").attr("opacity",.85).text("periodo no confiable");}}
 for(const[mk,txt] of Object.entries(DATA.hitos)){{const dx=pD(mk+"-15");if(!dx)continue;
  svg.append("line").attr("x1",x(dx)).attr("x2",x(dx)).attr("y1",0).attr("y2",h).attr("stroke","var(--yellow)").attr("stroke-dasharray","3,3").attr("opacity",.4);
  svg.append("text").attr("x",x(dx)+3).attr("y",10).attr("font-size",8).attr("fill","var(--yellow)").attr("opacity",.7).text(txt);}}
 keys.forEach((k,i)=>{{
  const dash=(dashes&&dashes[i])?dashes[i]:null;
  const P=M.filter(m=>m[k]!=null);   // meses con dato para esta serie (pico se limpia pre-fix)
  svg.append("path").datum(M).attr("fill","none").attr("stroke",cols[i]).attr("stroke-width",dash?1.8:2.2)
   .attr("stroke-dasharray",dash).attr("opacity",dash?.9:1)
   .attr("d",d3.line().defined(m=>m[k]!=null).x(m=>x(m.D)).y(m=>y(m[k])));
  svg.selectAll(".pt"+id+i).data(P).join("circle").attr("class","pt").attr("cx",m=>x(m.D)).attr("cy",m=>y(m[k]))
   .attr("r",dash?2:2.8).attr("fill",cols[i]).attr("stroke","#060a1a").attr("stroke-width",1);
  svg.selectAll(".ht"+id+i).data(P).join("circle").attr("cx",m=>x(m.D)).attr("cy",m=>y(m[k]))
   .attr("r",9).attr("fill","transparent").style("cursor","pointer")
   .on("mouseenter",function(ev,m){{d3.select(this).attr("r",6).attr("fill",cols[i]).attr("fill-opacity",.22);}})
   .on("mousemove",(ev,m)=>showTip(ev,m.mes,cols[i],labels[i],tf(m[k])))
   .on("mouseleave",function(){{d3.select(this).attr("r",9).attr("fill","transparent");hideTip();}});
 }});
}}
function draw(){{
 const kf=d=>(d/1000).toFixed(1)+"k", kt=v=>v.toLocaleString()+" txn/min";
 const L=["P70 (alerta)","P90 (incidente)","P99 (techo — no nominal)"];
 const C=["#818ab0","#F0D224","#38bdf8"];
 const yMaxSP=d3.max(M,m=>d3.max([m.sp70,m.sp90,m.sp99]))*1.10;
 const yMaxEG=d3.max(M,m=>d3.max([m.eg70,m.eg90,m.eg99]))*1.10;
 chart("chartSP",["sp70","sp90","sp99"],C,L,yMaxSP,kf,kt,300);
 chart("chartEG",["eg70","eg90","eg99"],C,L,yMaxEG,kf,kt,300);
}}
draw();window.addEventListener("resize",draw);
document.getElementById("note").innerHTML=`Percentiles sobre el <b>pico diario</b> (la hora de mayor carga sostenida de cada día — ventana de 1 h, 13–22h — y su percentil sobre los días del mes) &middot; <b>P99</b> (cian) = pico diario superado solo <b>1% de los días</b> (día peor = techo, no llegar nominalmente); <b>P90</b> = 10% de los días (incidente); <b>P70</b> = 30% (alerta) &middot; holgura de dimensionamiento por canal: <b>SPEI +10%</b>, <b>Autorizador +0%</b> (topa su techo — regla: sin holgura hasta remediar) &middot; escala Y independiente por panel &middot; el <b>P99 solo desde mar-2026</b> (régimen confiable; antes el pico diario está contaminado por encolamientos + connection leak) &middot; banda = periodo no confiable (nov'25–ene'26); leak-fix (mar) y Power 10 (jun) marcados &middot; generado por <code>generators/build-percentiles-correlacionados.py</code>`;
</script></body></html>"""
    path.write_text(html, encoding="utf-8")
    print(f"  HTML: {path}")


if __name__ == "__main__":
    main()

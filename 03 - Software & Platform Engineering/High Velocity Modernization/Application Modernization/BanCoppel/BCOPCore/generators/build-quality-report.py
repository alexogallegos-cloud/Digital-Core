#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-quality-report.py — RENDERER de la Capa Transversal · Calidad del Gemelo
Cognitivo. Lee quality-data.json (de build-quality-data.py) y genera
quality-report-bcop.html: salud estructural del core AS-IS contra ISO/IEC 5055:2021.

Estética BanCoppel (azul #122FB1 + dorado #F0D224 + logo). dataviz: el COLOR porta
la SEVERIDAD (status palette good/warning/serious/critical, siempre con etiqueta —
nunca color solo); los 4 factores ISO 5055 van por etiqueta/posición; densidad por
dominio en rampa secuencial de un solo hue.
"""
import sys, json, os, re, math, datetime
sys.stdout.reconfigure(encoding="utf-8")
BASE = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..')) + '/'
# (chdir removed — using absolute paths via BASE)
D = json.load(open(BASE + "portal/data/quality-data.json", encoding="utf-8"))
M = D["meta"]; U = D["umbrales"]

# status palette (severidad) — reservada, con etiqueta obligatoria
SEV = {'critico':('#F0446C','Crítico'), 'serio':('#F59E0B','Serio'),
       'warning':('#E0B341','Warning'), 'ok':('#3FB98A','OK')}
FACT_ABBR = {'reliability':'Confiabilidad','security':'Seguridad',
             'performance':'Performance','maintainability':'Mantenibilidad'}

def esc(s): return str(s).replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')

# ── radar / spider: los 4 factores ISO 5055 ──────────────────────────────────
# health(factor) = % de SPs LIBRES de weaknesses de ese factor (afuera = más sano).
# Una serie (el core AS-IS). Usa el dato EXACTO de SPs únicos afectados (factores[].sps).
_T = M['sps_analizados']
RDIMS = [(FACT_ABBR[f['key']], 100*(1 - f['sps']/_T)) for f in D['factores']]

def radar_svg(dims):
    N = len(dims); R = 140; cx, cy = 210, 200
    def pt(i, r):
        a = -math.pi/2 + 2*math.pi*i/N
        return (cx + r*math.cos(a), cy + r*math.sin(a))
    grid = ""
    for lvl in (20, 40, 60, 80, 100):
        pts = " ".join(f"{pt(i,R*lvl/100)[0]:.1f},{pt(i,R*lvl/100)[1]:.1f}" for i in range(N))
        grid += f'<polygon points="{pts}" fill="none" stroke="#26317c" stroke-width="0.8" opacity="0.55"/>'
    for i in range(N):
        x, y = pt(i, R)
        grid += f'<line x1="{cx}" y1="{cy}" x2="{x:.1f}" y2="{y:.1f}" stroke="#26317c" stroke-width="0.8" opacity="0.55"/>'
    dpts = " ".join(f"{pt(i,R*s/100)[0]:.1f},{pt(i,R*s/100)[1]:.1f}" for i,(_,s) in enumerate(dims))
    poly = (f'<polygon points="{dpts}" fill="#F0D224" fill-opacity="0.15" '
            f'stroke="#F0D224" stroke-width="2" stroke-linejoin="round"/>')
    dots = "".join(f'<circle cx="{pt(i,R*s/100)[0]:.1f}" cy="{pt(i,R*s/100)[1]:.1f}" r="3.2" '
                   f'fill="#0a1330" stroke="#F0D224" stroke-width="1.8"/>' for i,(_,s) in enumerate(dims))
    labels = ""
    for i,(lab,s) in enumerate(dims):
        lx, ly = pt(i, R+24)
        anc = "middle" if abs(lx-cx) < 12 else ("end" if lx < cx else "start")
        weak = s < 60
        col = "#F0446C" if weak else "#c9d3f5"
        labels += (f'<text x="{lx:.1f}" y="{ly:.1f}" text-anchor="{anc}" class="rlab">{esc(lab)}</text>'
                   f'<text x="{lx:.1f}" y="{ly+13:.1f}" text-anchor="{anc}" class="rval" fill="{col}">{s:.0f}</text>')
    axlbl = ('<text x="210" y="196" class="raxi" text-anchor="middle">100</text>'
             '<text x="210" y="140" class="raxi" text-anchor="middle">salud</text>')
    return (f'<svg viewBox="0 0 420 400" width="100%" style="max-width:440px">'
            f'{grid}{poly}{dots}{labels}{axlbl}</svg>')

radar_html = radar_svg(RDIMS)
_worst = min(RDIMS, key=lambda x: x[1])

# ── tiles KPI ────────────────────────────────────────────────────────────────
crit_total = sum(1 for h in D["hallazgos"] if h["sev"] == "critico")
tiles = [
  (f"{M['sps_analizados']:,}".replace(',','&#8202;'), "SPs analizados", "gold"),
  (f"{M['weaknesses_total']:,}".replace(',','&#8202;'), "Weaknesses ISO 5055", "gold"),
  (f"{D['salud']['pct_con_error_handling']}%", "SPs con manejo de error", "ok"),
  (str(sum(f['crit'] for f in D['factores'])), "Weaknesses críticas", "crit"),
]
tiles_html = "".join(
  f'<div class="tile {c}"><div class="n">{n}</div><div class="l">{esc(l)}</div></div>'
  for n,l,c in tiles)

# ── factores ISO 5055: barra apilada por severidad ───────────────────────────
# construimos, por factor, el desglose de severidad a partir de las reglas
sev_by_factor = {f['key']:{'critico':0,'serio':0,'warning':0} for f in D['factores']}
for r in D['reglas']:
    if r['count']:
        sev_by_factor.setdefault(r['factor'],{}).setdefault(r['sev'],0)
        sev_by_factor[r['factor']][r['sev']] = sev_by_factor[r['factor']].get(r['sev'],0)+r['count']
maxw = max((f['weak'] for f in D['factores']), default=1) or 1
fact_rows = ""
for f in D['factores']:
    segs = ""
    for sv in ['critico','serio','warning']:
        v = sev_by_factor.get(f['key'],{}).get(sv,0)
        if v:
            w = 100*v/maxw
            segs += f'<span class="seg" style="width:{w:.1f}%;background:{SEV[sv][0]}" title="{SEV[sv][1]}: {v}"></span>'
    fact_rows += (f'<div class="frow"><div class="fname">{esc(FACT_ABBR.get(f["key"],f["nombre"]))}'
                  f'<span class="fen">{esc(f["nombre"])}</span></div>'
                  f'<div class="fbar">{segs}</div>'
                  f'<div class="fnum">{f["weak"]}<span>{f["sps"]} SPs</span></div></div>')

# ── reglas: tabla con CWE ────────────────────────────────────────────────────
# dataviz: el COLOR hace un solo trabajo = severidad (status). El factor se lee por
# su etiqueta de texto + un dot neutro (no un hue categórico que competiría con la severidad).
DOT = "#5B6BA8"   # neutro azulado — marca "factor" sin portar encoding de color
reglas_sorted = sorted(D['reglas'], key=lambda r:(-{'critico':4,'serio':3,'warning':2}.get(r['sev'],0), -r['count']))
reglas_html = ""
for r in reglas_sorted:
    sc, sl = SEV[r['sev']]
    reglas_html += (f'<tr><td><span class="fdot" style="background:{DOT}"></span>{esc(FACT_ABBR[r["factor"]])}</td>'
                    f'<td class="mono">{esc(r["cwe"])}</td><td>{esc(r["titulo"])}<div class="ev">{esc(r["evidencia"])}</div></td>'
                    f'<td><span class="pill" style="color:{sc};border-color:{sc}">{sl}</span></td>'
                    f'<td class="num">{r["count"]:,}</td></tr>'.replace(',','&#8202;'))

# ── por dominio: densidad (rampa secuencial dorada) ──────────────────────────
# solo los 12 dominios de negocio (D01–D12); el resto (dbs técnicos/temporales:
# borra, sentinel, bdirst…) se agrega en "Otros" para no ensuciar la vista con ruido.
_all = D['por_dominio']
_known = [d for d in _all if re.match(r'D\d', d['dom'])]
_otros = [d for d in _all if not re.match(r'D\d', d['dom'])]
if _otros:
    ow = sum(o['weak'] for o in _otros); osps = sum(o['sps'] for o in _otros); ol = sum(o['loc'] for o in _otros)
    _known.append({'dom':'Otros (técnico / temporal)','sps':osps,'weak':ow,'loc':ol,
                   'densidad': round(1000*ow/ol,2) if ol else 0,'critico':0,'serio':0,'warning':0})
doms = sorted(_known, key=lambda x:-x['densidad'])
maxd = max((d['densidad'] for d in doms), default=1) or 1
dom_html = ""
for d in doms:
    w = 100*d['densidad']/maxd
    crit = f'<span class="dchip crit">{d["critico"]}</span>' if d.get('critico') else ''
    ser = f'<span class="dchip ser">{d["serio"]}</span>' if d.get('serio') else ''
    dom_html += (f'<tr><td>{esc(d["dom"])}</td><td class="num">{d["sps"]}</td>'
                 f'<td class="num">{d["weak"]}</td>'
                 f'<td class="dbar"><span style="width:{w:.1f}%"></span><b>{d["densidad"]}</b></td>'
                 f'<td>{crit}{ser}</td></tr>')

# ── histograma complejidad ───────────────────────────────────────────────────
hc = D['hist_complejidad']; maxh = max((b['n'] for b in hc), default=1) or 1
hist_html = ""
for b in hc:
    w = 100*b['n']/maxh
    hi = 'over' if b['rango'] in ('51–100','100+') else ''
    hist_html += (f'<div class="hrow"><div class="hlbl">{esc(b["rango"])}</div>'
                  f'<div class="htrack"><span class="{hi}" style="width:{w:.1f}%"></span></div>'
                  f'<div class="hn">{b["n"]:,}</div></div>'.replace(',','&#8202;'))

# ── top hallazgos ────────────────────────────────────────────────────────────
hall_html = ""
for h in D['hallazgos']:
    sc, sl = SEV[h['sev']]
    chips = "".join(f'<span class="rchip" style="border-color:{SEV[r["sev"]][0]}" title="{esc(r["tit"])} · {esc(FACT_ABBR[r["factor"]])}">{esc(r["cwe"])}</span>'
                    for r in h['reglas'])
    io = f'{h["fanin"]}/{h["fanout"]}' if h.get("fanin") is not None else '—'
    hall_html += (f'<tr><td><span class="pill" style="color:{sc};border-color:{sc}">{sl}</span></td>'
                  f'<td class="mono spn">{esc(h["sp"])}<div class="ev">{esc(h["dom"])}</div></td>'
                  f'<td class="num">{h["loc"]:,}</td><td class="num">{h["cc"]}</td>'
                  f'<td class="num">{io}</td>'
                  f'<td class="chips">{chips}</td></tr>'.replace(',','&#8202;'))

fecha = datetime.date.today().isoformat()
LEGSEV = "".join(f'<span class="lg"><i style="background:{c}"></i>{l}</span>' for c,l in SEV.values())

HTML = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BanCoppel · Calidad del Código (ISO 5055) · BCOPCore</title>
<style>
:root{{--bg:#0a1330;--bg2:#0d1a3d;--panel:#132152;--line:#26317c;--gold:#F0D224;--blue:#3D5FCD;--txt:#EAEDF7;--muted:#9aa4c4}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;padding-bottom:60px}}
header{{background:linear-gradient(135deg,#122FB1,#0d2185);border-bottom:3px solid var(--gold);padding:13px 24px;display:flex;align-items:center;gap:13px;position:sticky;top:0;z-index:5}}
header img{{height:21px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.55))}}
header h1{{font-size:15px;font-weight:800}} header .sub{{font-size:10px;color:#c9d3f5;margin-top:2px}}
.iso{{margin-left:auto;font-size:10px;color:#0a1330;background:var(--gold);font-weight:800;padding:5px 11px;border-radius:5px;letter-spacing:.03em}}
.wrap{{max-width:1180px;margin:0 auto;padding:18px 24px}}
h2{{font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--gold);margin:26px 0 12px;font-weight:800}}
h2 .q{{color:var(--muted);text-transform:none;letter-spacing:0;font-weight:500;font-size:11px;margin-left:8px}}
.stats{{display:flex;gap:11px;flex-wrap:wrap;margin-top:4px}}
.tile{{background:var(--panel);border-radius:9px;padding:11px 16px;min-width:150px;border-left:3px solid var(--line);flex:1}}
.tile.gold{{border-left-color:var(--gold)}} .tile.ok{{border-left-color:#3FB98A}} .tile.crit{{border-left-color:#F0446C}}
.tile .n{{font-size:24px;font-weight:800}} .tile .l{{font-size:10px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-top:3px}}
.card{{background:var(--panel);border-radius:10px;padding:16px 18px;border:1px solid var(--line)}}
.lead{{font-size:12px;color:var(--muted);line-height:1.55;max-width:100ch;margin-bottom:4px}}
.lead b{{color:var(--txt)}}
/* factores */
.frow{{display:flex;align-items:center;gap:14px;padding:9px 0;border-bottom:1px solid var(--line)}}
.frow:last-child{{border:0}}
.fname{{width:150px;font-size:13px;font-weight:700;flex-shrink:0}} .fname .fen{{display:block;font-size:9px;color:var(--muted);font-weight:400}}
.fbar{{flex:1;height:15px;background:#0a1330;border-radius:4px;overflow:hidden;display:flex;gap:2px}}
.fbar .seg{{height:100%;border-radius:2px}}
.fnum{{width:70px;text-align:right;font-size:17px;font-weight:800}} .fnum span{{display:block;font-size:9px;color:var(--muted);font-weight:400}}
/* radar / spider */
.radar-wrap{{display:flex;gap:24px;align-items:center;flex-wrap:wrap}}
.radar{{flex:0 0 auto;display:flex;justify-content:center}}
.radar-read{{flex:1;min-width:260px}}
.radar-read p{{font-size:12px;color:var(--muted);line-height:1.55;margin-bottom:14px}}
.radar-read .hi{{color:var(--txt);font-weight:700}}
.rlab{{font-size:10.5px;fill:#c9d3f5;font-family:'Inter',system-ui,sans-serif;font-weight:600}}
.rval{{font-size:12px;font-weight:800;font-family:'Inter',system-ui,sans-serif}}
.raxi{{font-size:8px;fill:#5b6ba8}}
.rrow{{display:flex;align-items:center;gap:9px;padding:3.5px 0}}
.rlbl2{{flex:0 0 132px;font-size:11px;color:var(--txt)}}
.rrow .rb{{flex:1;height:7px;background:#0a1330;border-radius:4px;overflow:hidden}}
.rrow .rb span{{display:block;height:100%;border-radius:4px}}
.rrow .rs{{width:26px;text-align:right;font-size:11px;font-weight:800;font-variant-numeric:tabular-nums}}
.leg{{display:flex;gap:16px;margin-top:12px;font-size:10px;color:var(--muted);flex-wrap:wrap}}
.lg{{display:flex;align-items:center;gap:5px}} .lg i{{width:11px;height:11px;border-radius:3px;display:inline-block}}
/* tablas */
table{{width:100%;border-collapse:collapse;font-size:12px}}
th{{text-align:left;font-size:9px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);padding:7px 9px;border-bottom:1px solid var(--line)}}
td{{padding:8px 9px;border-bottom:1px solid rgba(38,49,124,.4);vertical-align:top}}
td.num{{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}}
.mono{{font-family:'SF Mono',Menlo,Consolas,monospace;font-size:11px}}
.ev{{font-size:9.5px;color:var(--muted);margin-top:2px}}
.spn{{max-width:270px;word-break:break-all}}
.pill{{display:inline-block;font-size:9px;font-weight:800;padding:2px 8px;border-radius:10px;border:1.4px solid;text-transform:uppercase;letter-spacing:.03em;white-space:nowrap}}
.fdot{{display:inline-block;width:8px;height:8px;border-radius:2px;margin-right:6px;vertical-align:middle}}
.dbar{{position:relative;min-width:120px}} .dbar span{{display:inline-block;height:8px;background:linear-gradient(90deg,#F0D224,#c9a800);border-radius:3px;vertical-align:middle}}
.dbar b{{font-size:10px;margin-left:7px;color:var(--muted)}}
.dchip{{display:inline-block;font-size:9px;font-weight:800;padding:1px 6px;border-radius:8px;margin-right:3px}}
.dchip.crit{{background:#F0446C;color:#0a1330}} .dchip.ser{{background:#F59E0B;color:#0a1330}}
.rchip{{display:inline-block;font-size:8.5px;font-family:monospace;padding:1px 5px;border:1px solid;border-radius:4px;margin:1px 2px 1px 0;color:var(--txt)}}
.chips{{max-width:230px}}
.hrow{{display:flex;align-items:center;gap:12px;padding:5px 0}}
.hlbl{{width:70px;font-size:11px;color:var(--muted);text-align:right}}
.htrack{{flex:1;height:13px;background:#0a1330;border-radius:4px;overflow:hidden}}
.htrack span{{display:block;height:100%;background:var(--blue);border-radius:4px}} .htrack span.over{{background:#F59E0B}}
.hn{{width:60px;font-size:12px;font-weight:700;text-align:right;font-variant-numeric:tabular-nums}}
.note{{font-size:10.5px;color:var(--muted);margin-top:10px;line-height:1.5}}
.note code{{background:#0a1330;padding:1px 5px;border-radius:3px;color:var(--gold)}}
/* next step */
#next{{background:linear-gradient(90deg,#0a1330,#0d1a3d 60%,#0a1330);border-top:2px solid var(--gold);margin-top:30px;padding:14px 24px;display:flex;align-items:center;gap:18px;border-radius:10px}}
#next .t{{font-size:11px;font-weight:800;color:var(--gold);text-transform:uppercase;letter-spacing:.06em}}
#next .d{{font-size:11px;color:#c9d3f5;line-height:1.45;max-width:92ch;margin-top:2px}}
#next .d b{{color:#fff}}
</style></head><body>
<header>
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div><h1>Calidad del código del core · BCOPCore</h1>
  <div class="sub">SPE-AM-001 · Gemelo Cognitivo · Capa Transversal · Calidad AS-IS · evidencia del código SPL · {fecha}</div></div>
  <span class="iso">ISO/IEC 5055:2021</span>
</header>
<div class="wrap">

  <p class="lead" style="margin-top:6px">Salud <b>estructural</b> del core medida contra <b>ISO/IEC 5055:2021</b> (CISQ) — los 4 factores de calidad como conteo de <b>weaknesses</b> del catálogo CWE, detectadas sobre el código SPL real. No existe herramienta de mercado para Informix SPL; se implementa el <b>estándar</b> con reglas <b>calibradas al dialecto</b> (percentil del propio sistema, no umbral greenfield) para evitar falsos positivos. Es el input de la <b>decisión 7R</b>, del <b>pricing</b> (deuda técnica) y de la priorización de <b>equivalence testing</b>.</p>

  <div class="stats">{tiles_html}</div>

  <h2>Los 4 factores ISO 5055 <span class="q">salud del core (spider) + severidad de la deuda</span></h2>
  <div class="card radar-wrap">
    <div class="radar">{radar_html}</div>
    <div class="radar-read">
      <p>El spider muestra la <span class="hi">salud por factor</span> — % de SPs libres de weaknesses de ese factor (afuera = más sano). El core es sólido en <span class="hi">confiabilidad, seguridad y performance</span> (~90/100); la <span class="hi">{esc(_worst[0])} ({_worst[1]:.0f})</span> concentra la deuda, dominada por la documentación ausente y la complejidad. Las barras desglosan esa deuda por severidad.</p>
      {fact_rows}
      <div class="leg"><span style="color:var(--muted)">Severidad:</span>{LEGSEV}</div>
    </div>
  </div>

  <h2>Reglas evaluadas <span class="q">cada weakness anclada a un CWE</span></h2>
  <div class="card"><table>
    <thead><tr><th>Factor</th><th>CWE</th><th>Weakness · señal en SPL</th><th>Severidad</th><th class="num">SPs</th></tr></thead>
    <tbody>{reglas_html}</tbody>
  </table></div>

  <h2>Densidad por dominio <span class="q">weaknesses por KLoC — dónde priorizar</span></h2>
  <div class="card"><table>
    <thead><tr><th>Dominio</th><th class="num">SPs</th><th class="num">Weak.</th><th>Densidad (w/KLoC)</th><th>Críticas/Serias</th></tr></thead>
    <tbody>{dom_html}</tbody>
  </table></div>

  <h2>Distribución de complejidad ciclomática <span class="q">umbral calibrado: CC &gt; {U['complejidad']}</span></h2>
  <div class="card">{hist_html}
    <div class="note">Umbrales <b>calibrados al percentil 90 del propio sistema</b> (no greenfield): complejidad <code>&gt;{U['complejidad']}</code> · LoC <code>&gt;{U['loc']}</code> · fan-out <code>&gt;{U['fanout']}</code>. Un core bancario legacy es naturalmente más denso que un microservicio nuevo — aplicar un umbral greenfield marcaría todo como crítico y haría el reporte inservible.</div>
  </div>

  <h2>Top 60 SPs de mayor riesgo <span class="q">priorizados por severidad → nº de weaknesses → tamaño</span></h2>
  <div class="card"><table>
    <thead><tr><th>Sev.</th><th>Stored Procedure · dominio</th><th class="num">LoC</th><th class="num">CC</th><th class="num">in/out</th><th>Weaknesses (CWE)</th></tr></thead>
    <tbody>{hall_html}</tbody>
  </table>
  <div class="note">CC = complejidad ciclomática · in/out = fan-in / fan-out (del call graph). El SP más enredado es el más riesgoso de probar equivalencia → prioriza dónde poner golden-masters.</div>
  </div>

  <div id="next">
    <div>
      <div class="t">Cómo alimenta la decisión</div>
      <div class="d">Este assessment no refactoriza: produce el <b>insumo estructural</b>. Baja mantenibilidad + alto acoplamiento → candidato a <b>Rewrite/Retire</b> (no Refactor); la deuda cuantificada → <b>días de remediación</b> para el pricing; el mapa de riesgo → <b>prioridad de golden-masters</b> para equivalencia. Ejecutado por el <b>Specialist · Code Quality Assessment</b> (HVM-wide).</div>
    </div>
  </div>

</div></body></html>"""

open(BASE + "old/quality-report-bcop.html","w",encoding="utf-8").write(HTML)
print(f"quality-report-bcop.html escrito · {M['sps_analizados']} SPs · {M['weaknesses_total']} weaknesses · {len(D['hallazgos'])} en top-riesgo")
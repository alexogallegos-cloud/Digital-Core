#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-souls-report.py — Genera souls-report-gentera.html: Capa 2 del Gemelo Cognitivo.
Muestra el Mapa de las Almas — autores, fechas, objetos atribuidos vs. sin atribución.

Consume: objects-inventory.json (de parse-abap.py)
Produce: souls-report-gentera.html

Capa 2 — Mapa de las Almas · GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""
import json
import sys
import re
from collections import defaultdict, Counter
from pathlib import Path

BASE    = Path(__file__).parent
INV_F   = BASE / "objects-inventory.json"
OUT_F   = BASE / "souls-report-gentera.html"

if not INV_F.exists():
    print("WARN: objects-inventory.json no encontrado. Corre primero: python3 parse-abap.py")
    sys.exit(1)

inv     = json.loads(INV_F.read_text(encoding='utf-8'))
objects = inv.get('objetos', [])
headers = inv.get('headers', [])
meta    = inv.get('meta', {})

# ── análisis de autoría ────────────────────────────────────────────────────────

# Índice obj_id → header
header_by_obj = {h['objeto']: h for h in headers}

# Autores únicos
authors = {}  # usuario_sap → { nombre, objetos, fechas, tickets, modulos }
for h in headers:
    uid = h.get('usuario_sap', '') or h.get('autor', 'DESCONOCIDO')[:20]
    if not uid:
        uid = 'DESCONOCIDO'
    uid = uid.upper().strip()
    if uid not in authors:
        authors[uid] = {
            'nombre'  : h.get('autor', '').strip(),
            'uid'     : uid,
            'objetos' : [],
            'fechas'  : [],
            'tickets' : [],
            'modulos' : set(),
        }
    authors[uid]['objetos'].append(h['objeto'])
    if h.get('fecha'):
        authors[uid]['fechas'].append(h['fecha'])
    if h.get('ticket'):
        authors[uid]['tickets'].append(h['ticket'])

# Objetos SIN header de autoría
obj_ids_with_header = {h['objeto'] for h in headers}
unattributed = [o for o in objects if o['id'] not in obj_ids_with_header]

# Timeline: fechas detectadas (formato DD.MM.YYYY)
def parse_date(d):
    m = re.match(r'(\d{2})\.(\d{2})\.(\d{4})', d.strip() if d else '')
    if m:
        return f"{m.group(3)}-{m.group(2)}-{m.group(1)}"
    return None

all_dates = []
for h in headers:
    pd = parse_date(h.get('fecha', ''))
    if pd:
        all_dates.append({'fecha': pd, 'objeto': h['objeto'], 'uid': h.get('usuario_sap', '?')})
all_dates.sort(key=lambda x: x['fecha'])

# Estadísticas
n_total    = len(objects)
n_auth     = len(obj_ids_with_header)
n_unauth   = len(unattributed)
pct_auth   = round(100 * n_auth / n_total) if n_total else 0
n_authors  = len(authors)
n_tipos    = Counter(o['tipo'] for o in objects)

# ── serializar para JavaScript ────────────────────────────────────────────────

authors_serial = []
for uid, a in authors.items():
    authors_serial.append({
        'uid'          : uid,
        'nombre'       : a['nombre'],
        'n_objetos'    : len(a['objetos']),
        'objetos'      : a['objetos'],
        'fechas'       : sorted(set(a['fechas'])),
        'tickets'      : list(dict.fromkeys(a['tickets'])),   # dedup preserving order
        'fecha_primera': sorted(a['fechas'])[0] if a['fechas'] else '—',
        'fecha_ultima' : sorted(a['fechas'])[-1] if a['fechas'] else '—',
    })

unattrib_serial = [
    {'id': o['id'], 'tipo': o['tipo'], 'loc': o['loc'], 'params': o['params']}
    for o in unattributed
]

obj_serial = [
    {'id': o['id'], 'tipo': o['tipo'], 'loc': o['loc'], 'params': o['params'],
     'autor': header_by_obj.get(o['id'], {}).get('usuario_sap', ''),
     'fecha': header_by_obj.get(o['id'], {}).get('fecha', ''),
     'ticket': header_by_obj.get(o['id'], {}).get('ticket', '')}
    for o in objects
]

AUTHORS_JSON  = json.dumps(authors_serial,  ensure_ascii=False)
UNATTRIB_JSON = json.dumps(unattrib_serial, ensure_ascii=False)
OBJS_JSON     = json.dumps(obj_serial,      ensure_ascii=False)
META_JSON     = json.dumps({
    'sistema': meta.get('sistema', 'gentera-sap'),
    'objetos': n_total,
    'con_autoria': n_auth,
    'sin_autoria': n_unauth,
    'pct_autoria': pct_auth,
    'n_autores': n_authors,
}, ensure_ascii=False)

# ── hallazgos HTML ────────────────────────────────────────────────────────────

if headers:
    autor_example = headers[0]
    HALLAZGO_AUTORIA = (
        f"Autoría confirmada en <b>{n_auth}</b> de {n_total} objeto(s) ({pct_auth}%). "
        f"Autor identificado: <b>{autor_example.get('autor', '?')}</b> "
        f"({autor_example.get('usuario_sap', '?')}) — "
        f"{autor_example.get('fecha', '?')} — ticket {autor_example.get('ticket', '?')}."
    )
else:
    HALLAZGO_AUTORIA = f"Sin headers de autoría detectados en {n_total} objeto(s). Verificar formato de comentarios ABAP."

HALLAZGO_UNAUTH = (
    f"<b>{n_unauth} objeto(s) sin atribución</b> — el código base fue escrito por "
    f"desarrolladores que no dejaron header, o pertenece a capas de infraestructura "
    f"anteriores al estándar de documentación del equipo."
) if n_unauth > 0 else "Todos los objetos tienen autoría registrada."

HALLAZGO_INSIGHT = (
    "El patrón <b>base DAO sin autor + métodos de negocio con autor</b> indica "
    "que la infraestructura técnica fue creada primero (sin estándar de documentación) "
    "y la lógica de negocio específica fue añadida después, por desarrolladores que sí "
    "aplicaron el estándar. "
    "Esto es común en codebases SAP que evolucionaron de soporte a customización activa."
) if (n_auth > 0 and n_unauth > 0) else "Corpus insuficiente para detectar patrones de evolución de autoría."

# ── HTML ──────────────────────────────────────────────────────────────────────
HTML = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>GENCore · Mapa de las Almas · SAP ABAP</title>
<style>
:root{{--bg:#06111f;--bg2:#091929;--panel:#0d2235;--line:#1a3a5c;--naranja:#E8521A;--blue:#2B5CA8;--txt:#EBF0F7;--muted:#8aa4c4;--gold:#E8C51A;--green:#22c55e;--red:#ef4444}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,sans-serif;min-height:100vh}}
header{{background:linear-gradient(135deg,#0a1e38 0%,#1B3A8C 55%,#2045a8 100%);
  border-bottom:3px solid var(--naranja);padding:18px 28px;
  display:flex;align-items:center;gap:20px;box-shadow:0 4px 24px rgba(0,0,0,.5)}}
header .logo{{width:44px;height:44px;border-radius:8px;background:linear-gradient(135deg,var(--naranja),#c44010);
  display:flex;align-items:center;justify-content:center;font-weight:900;font-size:16px;color:#fff;flex-shrink:0}}
header .divider{{width:1px;height:40px;background:rgba(255,255,255,.2);flex-shrink:0}}
header .meta{{flex:1}}
header .breadcrumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-bottom:5px}}
header .breadcrumb span{{color:var(--naranja)}}
header h1{{font-size:18px;font-weight:800;line-height:1.2}}
header .sub{{font-size:11px;color:#a0c4e8;margin-top:4px}}
header .badge-wrap{{display:flex;gap:8px;align-items:center;margin-left:auto;flex-shrink:0}}
header .hbadge{{font-size:10px;font-weight:700;padding:4px 12px;border-radius:20px;letter-spacing:.04em;white-space:nowrap}}
header .hbadge.capa{{background:rgba(232,82,26,.15);border:1px solid rgba(232,82,26,.4);color:var(--naranja)}}
header .hbadge.tech{{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.14);color:#c9d3f5}}
/* stats row */
.stats{{display:flex;gap:10px;padding:16px 24px;flex-wrap:wrap;border-bottom:1px solid var(--line)}}
.stat{{background:var(--panel);border-radius:10px;padding:12px 18px;min-width:110px;
  border-left:3px solid var(--line);flex-shrink:0}}
.stat .n{{font-size:24px;font-weight:800}}
.stat .l{{font-size:9px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-top:2px}}
.stat.auth{{border-left-color:var(--green)}}.stat.unauth{{border-left-color:var(--red)}}
.stat.tot{{border-left-color:var(--naranja)}}.stat.aut{{border-left-color:var(--gold)}}
/* sections */
.section{{padding:22px 24px}}
.sec-title{{font-size:15px;font-weight:800;margin-bottom:4px;letter-spacing:-.01em}}
.sec-sub{{font-size:12px;color:var(--muted);margin-bottom:16px;max-width:80ch;line-height:1.5}}
/* insight cards */
.insight-grid{{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:20px}}
@media(max-width:900px){{.insight-grid{{grid-template-columns:1fr}}}}
.icard{{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);
  border-left:3px solid var(--naranja);border-radius:12px;padding:14px 16px;
  font-size:12.5px;color:var(--muted);line-height:1.55}}
.icard b{{color:#fff}}.icard .itag{{font-size:10px;font-weight:800;color:var(--naranja);
  text-transform:uppercase;letter-spacing:.06em;margin-bottom:6px}}
/* author cards */
.author-grid{{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:14px}}
.acard{{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:16px 20px;
  border-top:3px solid var(--blue)}}
.acard .aname{{font-size:15px;font-weight:800;margin-bottom:2px}}
.acard .auid{{font-family:'Cascadia Code','Consolas',monospace;font-size:12px;color:var(--naranja);
  letter-spacing:.04em;margin-bottom:10px}}
.acard .arow{{display:flex;gap:8px;align-items:flex-start;margin-bottom:6px;font-size:12px}}
.acard .albl{{font-size:9px;font-weight:700;color:var(--muted);text-transform:uppercase;
  letter-spacing:.06em;min-width:72px;padding-top:1px}}
.acard .aval{{color:var(--txt);line-height:1.5;flex:1}}
.acard .aobj{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px;
  background:#071424;border-radius:5px;padding:2px 8px;display:inline-block;
  border:1px solid var(--line);margin:2px 3px 2px 0}}
.acard .aticket{{font-family:'Cascadia Code','Consolas',monospace;font-size:10px;
  background:rgba(43,92,168,.2);border:1px solid rgba(43,92,168,.4);
  border-radius:4px;padding:1px 7px;color:#93c5fd}}
/* unattributed table */
.utable{{width:100%;border-collapse:collapse;font-size:12px}}
.uthead th{{background:var(--bg2);padding:8px 12px;text-align:left;font-size:9px;
  text-transform:uppercase;letter-spacing:.06em;color:var(--muted);border-bottom:1px solid var(--line)}}
.utbody td{{padding:7px 12px;border-bottom:1px solid rgba(26,58,92,.4)}}
.utbody tr:hover{{background:rgba(232,82,26,.05)}}
.uterm{{font-family:'Cascadia Code','Consolas',monospace;color:#d0d8f0;font-weight:700}}
.utipo{{font-size:9px;padding:1px 7px;border-radius:3px;font-weight:600;background:#1e3a5c;color:#a0c4e8}}
.uwarn{{font-size:10px;color:var(--red);font-style:italic}}
/* progress bar */
.progwrap{{background:var(--bg2);border:1px solid var(--line);border-radius:10px;
  padding:16px 20px;margin-bottom:20px}}
.progbar-outer{{background:#071424;border-radius:8px;height:24px;overflow:hidden;
  display:flex;margin-top:8px}}
.progbar-auth{{background:linear-gradient(90deg,var(--green),#4ade80);height:100%;
  display:flex;align-items:center;padding:0 10px;font-size:11px;font-weight:700;color:#052e16;
  white-space:nowrap;overflow:hidden;min-width:2px}}
.progbar-unauth{{background:#1a2a3a;height:100%;display:flex;align-items:center;
  padding:0 10px;font-size:11px;color:var(--muted);white-space:nowrap}}
.prog-lbl{{font-size:11px;color:var(--muted);margin-top:8px}}
/* timeline */
.timeline{{padding:4px 0}}
.trow{{display:grid;grid-template-columns:110px 1fr;gap:12px;align-items:baseline;
  padding:6px 0;border-left:2px solid var(--line);margin-left:8px;padding-left:14px;position:relative}}
.trow::before{{content:'';position:absolute;left:-5px;top:50%;transform:translateY(-50%);
  width:8px;height:8px;border-radius:50%;background:var(--naranja);border:2px solid var(--bg)}}
.tdate{{font-size:10px;font-weight:700;color:var(--naranja);font-family:'Cascadia Code',monospace}}
.tobj{{font-size:12px;color:var(--txt)}}
.tuid{{font-size:10px;color:var(--muted);margin-top:2px;font-family:'Cascadia Code',monospace}}
footer{{font-size:9px;color:var(--muted);padding:8px 24px;border-top:1px solid var(--line)}}
</style>
</head>
<body>
<header>
  <div class="logo">GEN</div>
  <div class="divider"></div>
  <div class="meta">
    <div class="breadcrumb">GENCore · <span>SPE-AM-002</span> · Gemelo Cognitivo del Sistema · <span>Capa 2 — Mapa de las Almas</span></div>
    <h1>Mapa de las Almas — Autoría SAP ABAP</h1>
    <div class="sub">Namespace /CBB/ · {n_total} objeto(s) analizado(s) · Quién escribió cada pieza del sistema</div>
  </div>
  <div class="badge-wrap">
    <span class="hbadge capa">Capa 2</span>
    <span class="hbadge tech">SAP ABAP · /CBB/</span>
  </div>
</header>

<div class="stats">
  <div class="stat tot"><div class="n">{n_total}</div><div class="l">Objetos totales</div></div>
  <div class="stat auth"><div class="n">{n_auth}</div><div class="l">Con autoría ({pct_auth}%)</div></div>
  <div class="stat unauth"><div class="n">{n_unauth}</div><div class="l">Sin atribución ({100 - pct_auth}%)</div></div>
  <div class="stat aut"><div class="n">{n_authors}</div><div class="l">Autor(es) identificado(s)</div></div>
</div>

<div class="section">
  <div class="sec-title">Cobertura de autoría</div>
  <div class="sec-sub">Porcentaje de objetos con header de autoría explícito en el código ABAP.</div>
  <div class="progwrap">
    <div style="font-size:12px;color:var(--muted)">Objetos con autoría identificada vs. sin atribución</div>
    <div class="progbar-outer">
      <div class="progbar-auth" style="width:{pct_auth}%">{pct_auth}% atribuidos</div>
      <div class="progbar-unauth" style="width:{100 - pct_auth}%">{100 - pct_auth}% sin header</div>
    </div>
    <div class="prog-lbl">A medida que se cargan más archivos ABAP, esta barra refleja la cobertura real del corpus.</div>
  </div>

  <div class="insight-grid">
    <div class="icard"><div class="itag">Autoría detectada</div>{HALLAZGO_AUTORIA}</div>
    <div class="icard"><div class="itag">Sin atribución</div>{HALLAZGO_UNAUTH}</div>
    <div class="icard"><div class="itag">Insight de evolución</div>{HALLAZGO_INSIGHT}</div>
  </div>
</div>

<div class="section" style="border-top:1px solid var(--line)">
  <div class="sec-title">Autores identificados</div>
  <div class="sec-sub">Desarrolladores con header de autoría explícito en el código ABAP. Cada "alma" representa un autor real con sus objetos, fechas y tickets de trabajo.</div>
  <div id="author-grid" class="author-grid"></div>
</div>

<div class="section" style="border-top:1px solid var(--line)">
  <div class="sec-title">Timeline de modificaciones</div>
  <div class="sec-sub">Eventos de autoría ordenados cronológicamente — cuándo se trabajó en cada objeto.</div>
  <div id="timeline" class="timeline"></div>
</div>

<div class="section" style="border-top:1px solid var(--line)">
  <div class="sec-title">Objetos sin atribución ({n_unauth})</div>
  <div class="sec-sub">Objetos sin header de autoría en el código fuente. Puede indicar: código legado sin estándar de documentación, código generado, o código base de infraestructura escrito antes de aplicar el estándar.</div>
  <table class="utable">
    <thead class="uthead"><tr>
      <th>Objeto</th><th>Tipo</th><th>LOC</th><th>Métodos</th><th>Nota</th>
    </tr></thead>
    <tbody id="unattr-body" class="utbody"></tbody>
  </table>
</div>

<div class="section" style="border-top:1px solid var(--line)">
  <div class="sec-title">Todos los objetos</div>
  <div class="sec-sub">Vista consolidada: objetos con y sin autoría.</div>
  <table class="utable">
    <thead class="uthead"><tr>
      <th>Objeto</th><th>Tipo</th><th>LOC</th><th>Métodos</th><th>Autor</th><th>Fecha</th><th>Ticket</th>
    </tr></thead>
    <tbody id="all-body" class="utbody"></tbody>
  </table>
</div>

<footer>Gemelo Cognitivo SAP ABAP · Capa 2 — Mapa de las Almas · GENCore SPE-AM-002 · Fuente: objects-inventory.json</footer>

<script>
const AUTHORS  = {AUTHORS_JSON};
const UNATTRIB = {UNATTRIB_JSON};
const OBJS     = {OBJS_JSON};
const META     = {META_JSON};

// Render author cards
const ag = document.getElementById('author-grid');
if (AUTHORS.length === 0) {{
  ag.innerHTML = '<div style="color:var(--muted);font-size:13px;padding:10px 0">No se detectaron autores con header explícito en el corpus actual.</div>';
}} else {{
  ag.innerHTML = AUTHORS.map(a => `
    <div class="acard">
      <div class="aname">${{a.nombre || '(sin nombre)'}}</div>
      <div class="auid">${{a.uid}}</div>
      <div class="arow"><span class="albl">Objetos</span><span class="aval">
        ${{a.objetos.map(o=>'<span class="aobj">'+o+'</span>').join('')}}
      </span></div>
      <div class="arow"><span class="albl">Fechas</span>
        <span class="aval">${{a.fechas.join(' · ') || '—'}}</span>
      </div>
      <div class="arow"><span class="albl">Tickets</span>
        <span class="aval">${{a.tickets.map(t=>'<span class="aticket">'+t+'</span>').join(' ') || '—'}}</span>
      </div>
    </div>
  `).join('');
}}

// Render timeline
const tl = document.getElementById('timeline');
const events = OBJS.filter(o => o.fecha).map(o => ({{...o}}))
  .sort((a,b) => {{
    const da = a.fecha.split('.').reverse().join(''), db = b.fecha.split('.').reverse().join('');
    return da.localeCompare(db);
  }});
if (events.length === 0) {{
  tl.innerHTML = '<div style="color:var(--muted);font-size:12px;padding:8px 0 8px 22px">Sin eventos de fecha detectados aún.</div>';
}} else {{
  tl.innerHTML = events.map(e => `
    <div class="trow">
      <div><div class="tdate">${{e.fecha}}</div></div>
      <div><div class="tobj">${{e.id}}</div>
        ${{e.autor ? '<div class="tuid">'+e.autor+'</div>' : ''}}
        ${{e.ticket ? '<div class="tuid" style="color:#93c5fd">'+e.ticket+'</div>' : ''}}
      </div>
    </div>
  `).join('');
}}

// Render unattributed table
document.getElementById('unattr-body').innerHTML = UNATTRIB.map(o => `
  <tr>
    <td><span class="uterm">${{o.id}}</span></td>
    <td><span class="utipo">${{o.tipo}}</span></td>
    <td style="color:var(--muted);text-align:right">${{o.loc}}</td>
    <td style="color:var(--muted);text-align:right">${{o.params}}</td>
    <td><span class="uwarn">Sin header de autoría</span></td>
  </tr>
`).join('') || '<tr><td colspan="5" style="color:var(--muted);padding:12px">Todos los objetos tienen autoría registrada.</td></tr>';

// Render all objects table
document.getElementById('all-body').innerHTML = OBJS.map(o => `
  <tr>
    <td><span class="uterm">${{o.id}}</span></td>
    <td><span class="utipo">${{o.tipo}}</span></td>
    <td style="color:var(--muted);text-align:right">${{o.loc}}</td>
    <td style="color:var(--muted);text-align:right">${{o.params}}</td>
    <td style="color:${{o.autor ? '#E8C51A' : 'var(--red)'}}">
      ${{o.autor || '<span style="font-style:italic;opacity:.6">sin atribución</span>'}}
    </td>
    <td style="color:var(--muted);font-family:monospace;font-size:11px">${{o.fecha || '—'}}</td>
    <td style="color:#93c5fd;font-family:monospace;font-size:10px">${{o.ticket || '—'}}</td>
  </tr>
`).join('');
</script>
</body>
</html>"""

OUT_F.write_text(HTML, encoding='utf-8')
print(f"OK  souls-report-gentera.html  =>  {n_total} objetos | {n_auth} con autoria | {n_authors} autor(es)")
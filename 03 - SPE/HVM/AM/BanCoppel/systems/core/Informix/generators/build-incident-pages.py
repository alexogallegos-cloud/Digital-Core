#!/usr/bin/env python3
"""
build-incident-pages.py — Informix · Páginas de incidente en formato rico

Genera páginas standalone en portal/incidents/{fecha}/ replicando el formato
canónico establecido por inc-010-bdicred-scoring-commit-comentado.html:
signal bar, header con métricas, impacto al negocio, contexto funcional,
tabla de hallazgos, evidencia raw, simulación interactiva, timeline y
panel doble con animación de secuencia.

El CSS compartido vive en generators/incident-page.css y el logo en
generators/_bcop-logo-datauri.txt — ambos extraídos del formato de referencia.

Uso: python generators/build-incident-pages.py
     (ejecutar desde Informix/)
"""

import json
import sys
from datetime import date
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = Path(__file__).resolve().parent.parent
GEN  = ROOT / 'generators'
CSS  = (GEN / 'incident-page.css').read_text(encoding='utf-8')
LOGO = (GEN / '_bcop-logo-datauri.txt').read_text(encoding='utf-8').strip()


# ═════════════════════════════════════════════════════════════════════════════
# Render helpers
# ═════════════════════════════════════════════════════════════════════════════

def esc(t):
    return (t or '').replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')


def metrics_html(mets):
    out = []
    for value, label, cls in mets:
        c = f' {cls}' if cls else ''
        out.append(
            f'    <div class="met"><div class="met-v{c}">{value}</div>'
            f'<div class="met-l">{label}</div></div>'
        )
    return '\n'.join(out)


def impact_html(imp):
    items = []
    last = len(imp['items']) - 1
    for i, it in enumerate(imp['items']):
        style = ' style="border-right:none"' if i == last else ''
        vcls = ' ' + it['val_cls'] if it.get('val_cls') else ''
        items.append(f'''      <div class="impact-item"{style}>
        <div class="impact-lbl">{it['lbl']}</div>
        <div class="impact-val{vcls}">{it['val']}</div>
        <div class="impact-sub">{it['sub']}</div>
      </div>''')
    return f'''<div class="impact-section">
  <div class="impact-severity">
    <div>
      <div class="impact-badge impact-critical">{imp['badge']}</div>
      <div class="impact-sev-lbl">Severidad<br>de impacto</div>
    </div>
  </div>
  <div class="impact-items">
{chr(10).join(items)}
  </div>
</div>'''


def ctx_html(sec):
    cards = []
    for c in sec['cards']:
        reg = ' ctx-card-reg' if c.get('reg') else ''
        nreg = ' ctx-reg' if c.get('reg') else ''
        cards.append(f'''    <div class="ctx-card{reg}">
      <div class="ctx-card-num{nreg}">{c['num']}</div>
      <div class="ctx-card-title">{c['title']}</div>
      <div class="ctx-card-body">{c['body']}</div>
    </div>''')
    style = f' style="{sec["style"]}"' if sec.get('style') else ''
    tstyle = f' style="color:{sec["title_color"]};"' if sec.get('title_color') else ''
    foot = (f'\n  <div style="font-size:10px;color:var(--dim);margin-top:8px;">{sec["foot"]}</div>'
            if sec.get('foot') else '')
    return f'''<div class="ctx-section"{style}>
  <div class="ctx-title"{tstyle}>{sec['title']}</div>
  <div class="ctx-grid">
{chr(10).join(cards)}
  </div>{foot}
</div>'''


def findings_html(fnd):
    rows = []
    for r in fnd['rows']:
        rows.append(f'''      <tr>
        <td><span class="d05-badge {r['badge_cls']}">{r['badge']}</span></td>
        <td>
          <div class="d05-sp">{r['artifact']}</div>
          <div class="d05-src">{r['source']}</div>
        </td>
        <td><span class="d05-rate {r.get('loc_cls', '')}">{r['loc']}</span></td>
        <td class="d05-type">{r['desc']}</td>
      </tr>''')
    return f'''<div class="d05-section">
  <div class="d05-hdr">
    <div class="d05-hdr-title">{fnd['title']}</div>
    <div class="d05-hdr-sub">{fnd['sub']}</div>
  </div>
  <table class="d05-table">
    <thead>
      <tr><th>Clase</th><th>Artefacto</th><th>Ubicación</th><th>Descripción del hallazgo</th></tr>
    </thead>
    <tbody>
{chr(10).join(rows)}
    </tbody>
  </table>
  <div class="d05-note">{fnd['note']}</div>
</div>'''


def timeline_html(tl):
    rows = []
    for i, r in enumerate(tl['rows']):
        rows.append(f'''    <div class="tl-row">
      <div class="tl-lbl">{r['lbl']}</div>
      <div class="tl-bg"><div class="tl-fill {r['cls']}" id="tlF{i}" style="width:0%"></div></div>
      <div class="tl-dur" style="color:{r['color']}" id="tlD{i}">&mdash;</div>
    </div>''')
    marks = ''.join(f'<span>{m}</span>' for m in tl['markers'])
    return f'''<div class="tl-section">
  <div class="tl-title">{tl['title']}</div>
  <div class="tl-rows">
{chr(10).join(rows)}
  </div>
  <div class="tl-markers">{marks}</div>
</div>'''


def svg_flow(side, nodes):
    """Diagrama vertical de nodos con flechas. side = 'L' | 'R'."""
    h = 14 + len(nodes) * 78
    p = [f'<svg id="svg{side}" viewBox="0 0 380 {h}" width="100%">',
         '  <defs>',
         f'    <filter id="glow{side}" x="-80%" y="-80%" width="260%" height="260%">',
         '      <feGaussianBlur stdDeviation="4" result="b"/>',
         '      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>',
         '    </filter>',
         '  </defs>']
    for i, n in enumerate(nodes):
        y = 10 + i * 78
        if i:
            ay = y - 24
            p.append(f'  <line x1="190" y1="{ay}" x2="190" y2="{y}" stroke="#C5CCE8" '
                     f'stroke-width="1.5" stroke-dasharray="4,3"/>')
            p.append(f'  <polygon points="190,{y} 184,{y-12} 196,{y-12}" fill="#A0AEDC"/>')
        fill, stroke, sw = '#ffffff', '#122FB1', '1.5'
        if n.get('style') == 'accent':
            fill, sw = '#f0f2fe', '2'
        elif n.get('style') == 'danger':
            fill, stroke, sw = '#fff5f5', '#ef4444', '2'
        elif n.get('style') == 'good':
            fill, stroke, sw = '#f0fdf4', '#22c55e', '2'
        p.append(f'  <rect id="{side}n{i}" x="60" y="{y}" width="260" height="50" rx="8" '
                 f'fill="{fill}" stroke="{stroke}" stroke-width="{sw}"/>')
        p.append(f'  <text x="190" y="{y+19}" text-anchor="middle" fill="#4a5a8a" '
                 f'font-size="10">{esc(n["top"])}</text>')
        p.append(f'  <text x="190" y="{y+36}" text-anchor="middle" fill="#0d1a3a" '
                 f'font-size="11" font-weight="700">{esc(n["main"])}</text>')
        if n.get('note'):
            col = n.get('note_color', '#f59e0b')
            p.append(f'  <text x="8" y="{y+22}" fill="{col}" font-size="9" '
                     f'font-weight="700">{esc(n["note"])}</text>')
            if n.get('note2'):
                p.append(f'  <text x="8" y="{y+34}" fill="#64748b" font-size="8.5">'
                         f'{esc(n["note2"])}</text>')
    p.append('</svg>')
    return '\n'.join(p)


def panel_html(side, pn):
    hud = ''.join(
        f'<div class="hud-item"><div class="hud-v{" " + h[2] if h[2] else ""}" '
        f'id="{side}h{i}">{h[0]}</div><div class="hud-l">{h[1]}</div></div>'
        for i, h in enumerate(pn['hud'])
    )
    fixes = ''
    if pn['rc'].get('fixes'):
        li = ''.join(f'<li data-n="{i+1}">{f}</li>' for i, f in enumerate(pn['rc']['fixes']))
        fixes = f'<ul class="fix-list">{li}</ul>'
    return f'''  <div class="panel">
    <div class="panel-hdr">
      <span class="ph-badge {pn['badge_cls']}">{pn['badge']}</span>
      <div>
        <div class="ph-title">{pn['title']}</div>
        <div class="ph-sub">{pn['sub']}</div>
      </div>
    </div>
    <div class="flow-wrap">
{svg_flow(side, pn['nodes'])}
    </div>
    <div class="hud">{hud}</div>
    <div class="log-stream" id="log{side}"></div>
    <div class="root-cause">
      <div class="rc-title">{pn['rc']['title']}</div>
      <div class="rc-body">{pn['rc']['body']}</div>
      {fixes}
    </div>
  </div>'''


# ═════════════════════════════════════════════════════════════════════════════
# Shell
# ═════════════════════════════════════════════════════════════════════════════

SHELL = '''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{TITLE}}</title>
<style>
{{CSS}}
</style>
</head>
<body>

<div class="signal-top"></div>

<header>
  <div class="hdr-row1">
    <div class="bc-logo-wrap">
      <img class="bc-logo" src="{{LOGO}}" alt="BanCoppel">
      <div class="bc-wordmark-sub">Modernización Core Bancario</div>
    </div>
    <div>
      <div class="hdr-title">{{INC}} <span style="background:rgba(240,210,36,.20);color:#F0D224;padding:2px 8px;border-radius:4px;font-size:13px;font-weight:800;letter-spacing:.3px;">{{DATEPILL}}</span> {{HEADLINE}}</div>
      <div class="hdr-sub">{{SUBTITLE}}</div>
    </div>
  </div>
  <div class="metrics">
{{METRICS}}
  </div>
</header>

{{IMPACT}}

{{CTX}}

{{FINDINGS}}

{{SIM}}

{{TIMELINE}}

<div class="controls">
  <button class="btn btn-reset" onclick="resetAnim()">&#8635; Reiniciar</button>
  <button class="btn btn-primary" id="btnPlay" onclick="onPlay()">&#9654; Reproducir</button>
</div>

<div class="panels">
{{PANEL_L}}
{{PANEL_R}}
</div>

<script>
var STEPS = {{STEPS}};
var TLROWS = {{TLROWS}};
var playing = false, cancelled = false;

function wait(ms){ return new Promise(function(r){ setTimeout(r, ms); }); }
function el(id){ return document.getElementById(id); }

function hilite(id, color, w){
  var n = el(id); if(!n) return;
  n.setAttribute('stroke', color);
  n.setAttribute('stroke-width', w || 3);
  n.setAttribute('filter', 'url(#glow' + id.charAt(0) + ')');
}
function unhilite(id, color, w){
  var n = el(id); if(!n) return;
  n.setAttribute('stroke', color);
  n.setAttribute('stroke-width', w);
  n.removeAttribute('filter');
}
function addLog(side, t, type, msg){
  var box = el('log' + side); if(!box) return;
  var d = document.createElement('div');
  d.className = 'le';
  d.innerHTML = '<span class="le-t">' + t + '</span>' +
                '<span class="le-' + type + '">' + (type === 'ok' ? 'OK ' : 'ERR') + '</span>' +
                '<span class="le-m">' + msg + '</span>';
  box.appendChild(d);
  requestAnimationFrame(function(){ d.classList.add('show'); });
  box.scrollTop = box.scrollHeight;
}
function setHud(side, i, v){ var n = el(side + 'h' + i); if(n) n.textContent = v; }

function resetAnim(){
  cancelled = true; playing = false;
  ['L','R'].forEach(function(s){
    var box = el('log' + s); if(box) box.innerHTML = '';
    document.querySelectorAll('#svg' + s + ' rect').forEach(function(r){
      r.removeAttribute('filter');
      r.setAttribute('stroke-width', r.getAttribute('data-sw') || '1.5');
      r.setAttribute('stroke', r.getAttribute('data-st') || '#122FB1');
    });
  });
  STEPS.forEach(function(st){
    (st.hud || []).forEach(function(h){ setHud(h[0], h[1], h[3]); });
  });
  TLROWS.forEach(function(_, i){
    var f = el('tlF' + i), d = el('tlD' + i);
    if(f) f.style.width = '0%';
    if(d) d.innerHTML = '&mdash;';
  });
  var b = el('btnPlay');
  if(b){ b.disabled = false; b.innerHTML = '&#9654; Reproducir'; }
}

async function onPlay(){
  if(playing) return;
  playing = true; cancelled = false;
  var b = el('btnPlay');
  if(b){ b.disabled = true; b.innerHTML = 'Reproduciendo...'; }
  ['L','R'].forEach(function(s){ var x = el('log' + s); if(x) x.innerHTML = ''; });

  for(var i = 0; i < STEPS.length; i++){
    if(cancelled) return;
    var st = STEPS[i];
    if(st.node) hilite(st.node, st.color || '#ef4444', st.w || 3);
    (st.log || []).forEach(function(l){ addLog(l[0], l[1], l[2], l[3]); });
    (st.hud || []).forEach(function(h){ setHud(h[0], h[1], h[2]); });
    if(st.tl != null){
      var f = el('tlF' + st.tl), d = el('tlD' + st.tl);
      if(f) f.style.width = st.tlw + '%';
      if(d) d.textContent = st.tld;
    }
    await wait(st.ms || 700);
  }
  playing = false;
  if(b){ b.disabled = false; b.innerHTML = '&#9654; Reproducir'; }
}

document.querySelectorAll('#svgL rect, #svgR rect').forEach(function(r){
  r.setAttribute('data-sw', r.getAttribute('stroke-width'));
  r.setAttribute('data-st', r.getAttribute('stroke'));
});
</script>

<footer style="text-align:center;font-size:11px;color:var(--dim);padding:16px;border-top:1px solid var(--border);background:#EEF0FA;">
  Informix Digital Brain, BanCoppel Application Modernization, SPE-AM-001, Accenture &mdash; generado {{TODAY}}
</footer>
</body>
</html>
'''


def build(spec):
    ctx = '\n\n'.join(ctx_html(s) for s in spec['ctx'])
    html = SHELL
    repl = {
        '{{TITLE}}':    spec['title'],
        '{{CSS}}':      CSS,
        '{{LOGO}}':     LOGO,
        '{{INC}}':      spec['inc'],
        '{{DATEPILL}}': spec['date_pill'],
        '{{HEADLINE}}': spec['headline'],
        '{{SUBTITLE}}': spec['subtitle'],
        '{{METRICS}}':  metrics_html(spec['metrics']),
        '{{IMPACT}}':   impact_html(spec['impact']),
        '{{CTX}}':      ctx,
        '{{FINDINGS}}': findings_html(spec['findings']),
        '{{SIM}}':      spec['sim'],
        '{{TIMELINE}}': timeline_html(spec['timeline']),
        '{{PANEL_L}}':  panel_html('L', spec['panel_l']),
        '{{PANEL_R}}':  panel_html('R', spec['panel_r']),
        '{{STEPS}}':    json.dumps(spec['steps'], ensure_ascii=False),
        '{{TLROWS}}':   json.dumps([r['lbl'] for r in spec['timeline']['rows']], ensure_ascii=False),
        '{{TODAY}}':    date.today().strftime('%Y-%m-%d'),
    }
    for k, v in repl.items():
        html = html.replace(k, v)

    out_dir = ROOT / 'portal' / 'incidents' / spec['folder']
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / (spec['slug'] + '.html')
    out.write_text(html, encoding='utf-8')
    print(f'  OK   incidents/{spec["folder"]}/{out.name}  ({len(html):,} bytes)')
    return out


def main():
    from incident_specs import INCIDENTS
    print('Informix Incident Pages (formato rico) — build')
    print(f'Output: {ROOT / "portal" / "incidents"}\n')
    for spec in INCIDENTS:
        build(spec)
    print(f'\nOK  {len(INCIDENTS)} páginas generadas')


if __name__ == '__main__':
    sys.path.insert(0, str(GEN))
    main()

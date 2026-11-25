#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-endpoints-portal.py — Las URLs del canal SIWEB.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

`UrlConstantes` es el catálogo de URLs del canal y los controladores Spring
dicen cuáles están realmente publicadas. La diferencia entre ambas cifras es el
primer indicio de catálogo muerto, así que la vista la muestra en vez de
esconderla.

Escribe:
  portal/data/endpoints-siweb.json
  portal/data/endpoints-siweb.csv
  portal/endpoints-siweb.html
"""
import csv
import importlib.util
import json
import sqlite3
import sys
from collections import Counter
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SALIDA_HTML = canon.PORTAL / "endpoints-siweb.html"
SALIDA_JSON = canon.DATA / "endpoints-siweb.json"
SALIDA_CSV = canon.DATA / "endpoints-siweb.csv"


def datos(con):
    filas = []
    for const, url, metodo, controlador, archivo, consumidores in con.execute(
            "SELECT constant, url, http_method, controller, file, consumed_by "
            "FROM endpoints ORDER BY constant"):
        cons = json.loads(consumidores or "[]")
        filas.append({
            "nombre": const, "url": url or "",
            "metodo": metodo or "",
            "controlador": (controlador or "").split(".")[-1],
            "paquete": ".".join((controlador or "").split(".")[:-1]),
            "archivo": archivo or "",
            "consumidores": [c.split(".")[-1] for c in cons],
            "publicado": bool(controlador),
        })
    return filas


CSS_EXTRA = r"""
.nota{background:rgba(240,210,36,.06);border:1px solid rgba(240,210,36,.18);border-radius:13px;
 padding:14px 18px;font-size:12.5px;color:#f1e9c8;line-height:1.7;margin:16px 0 4px}
.nota b{color:#fff;font-weight:600}
.url{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:12px;color:#c9d3f5;
 flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.ctrl{font-size:11.5px;color:var(--muted2);flex-shrink:0;max-width:260px;overflow:hidden;
 text-overflow:ellipsis;white-space:nowrap}
.t-post{color:#8ce99a;background:rgba(140,233,154,.1);border:1px solid rgba(140,233,154,.26)}
.t-get{color:#74c0fc;background:rgba(116,192,252,.1);border:1px solid rgba(116,192,252,.26)}
.t-any{color:var(--muted2);background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.1)}
.cons{display:flex;flex-wrap:wrap;gap:6px;margin-top:10px}
.cons span{font-size:11px;color:#c9d3f5;background:rgba(0,0,0,.28);border:1px solid rgba(255,255,255,.07);
 border-radius:8px;padding:3px 9px;font-family:'SF Mono',ui-monospace,monospace}
"""

JS = r"""
let EP = [], pag = 0, soloSin = false, metodo = '';
const POR = 70;
const $ = s => document.querySelector(s);
const esc = s => (s==null?'':String(s)).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function filtrados(){
  const q = $('#q').value.trim().toLowerCase();
  const ctrl = $('#f-ctrl').value;
  return EP.filter(e=>{
    if (ctrl && e.controlador !== ctrl) return false;
    if (soloSin && e.publicado) return false;
    if (metodo && e.metodo !== metodo) return false;
    if (!q) return true;
    return (e.nombre+' '+e.url+' '+e.controlador).toLowerCase().includes(q);
  });
}

function clase(m){ return m==='POST'?'t-post':(m==='GET'?'t-get':'t-any'); }

function tarjeta(e){
  const tags = (e.metodo ? `<span class="tag ${clase(e.metodo)}">${esc(e.metodo)}</span>` : '')
    + (e.publicado ? '' : '<span class="tag t-risk">Sin publicar</span>');
  const cons = e.consumidores.length
    ? `<div class="gw"><div class="gk">Consume</div><div class="gv"><div class="cons">${
        e.consumidores.map(c=>`<span>${esc(c)}</span>`).join('')}</div></div></div>`
    : '';
  const ctrl = e.publicado
    ? `<div class="gw"><div class="gk">Publica</div><div class="gv">${esc(e.paquete)}.<b style="color:#e4eaff">${esc(e.controlador)}</b></div></div>`
    : '<div class="gv">Ningún controlador publica esta URL. Está declarada en <code>UrlConstantes</code> y nadie la expone.</div>';
  return `<div class="tc ${e.publicado?'p2':'p3'}">
    <div class="tch" onclick="this.nextElementSibling.style.display=this.nextElementSibling.style.display==='block'?'none':'block'">
      <span class="tcid">${esc(e.nombre)}</span>
      <span class="url">${esc(e.url)}</span>
      <span class="ctrl">${esc(e.controlador)}</span>
      <span class="tags">${tags}</span>
    </div>
    <div class="det" style="display:none">
      ${ctrl}
      ${cons}
      ${e.archivo ? `<div class="ev"><div class="evk">Archivo</div><div class="evv">${esc(e.archivo)}</div></div>` : ''}
    </div>
  </div>`;
}

function pintar(){
  const fs = filtrados();
  const total = Math.max(1, Math.ceil(fs.length/POR));
  if (pag >= total) pag = total-1;
  const trozo = fs.slice(pag*POR,(pag+1)*POR);
  $('#count').innerHTML = `<b>${fs.length.toLocaleString('es-MX')}</b> URLs`
    + (fs.length!==EP.length ? ` de ${EP.length.toLocaleString('es-MX')}` : '');
  $('#list').innerHTML = trozo.length ? trozo.map(tarjeta).join('')
    : '<div class="empty">Ninguna URL coincide con el filtro.</div>';
  $('#pg').textContent = `Página ${pag+1} de ${total}`;
  $('#prev').disabled = pag===0; $('#next').disabled = pag>=total-1;
}

fetch('data/endpoints-siweb.json').then(r=>r.json()).then(d=>{
  EP = d;
  const ctrls = [...new Set(EP.filter(e=>e.controlador).map(e=>e.controlador))].sort();
  $('#f-ctrl').innerHTML += ctrls.map(c=>`<option value="${esc(c)}">${esc(c)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/endpoints-siweb.json</code>. '
    + 'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = ()=>{ pag=0; pintar(); };
$('#f-ctrl').onchange = ()=>{ pag=0; pintar(); };
$('#c-sin').onclick = function(){ this.classList.toggle('on'); soloSin=!soloSin; pag=0; pintar(); };
document.querySelectorAll('.chip[data-m]').forEach(c=>{
  c.onclick = ()=>{
    document.querySelectorAll('.chip[data-m]').forEach(o=>{ if(o!==c) o.classList.remove('on'); });
    c.classList.toggle('on');
    metodo = c.classList.contains('on') ? c.dataset.m : '';
    pag=0; pintar();
  };
});
$('#prev').onclick = ()=>{ if(pag>0){pag--; scrollTo(0,0); pintar();} };
$('#next').onclick = ()=>{ pag++; scrollTo(0,0); pintar(); };
"""


def main():
    con = sqlite3.connect(canon.DB)
    eps = datos(con)
    controladores = con.execute(
        "SELECT COUNT(DISTINCT controller) FROM endpoints WHERE controller IS NOT NULL"
    ).fetchone()[0]
    con.close()

    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(json.dumps(eps, ensure_ascii=False), encoding="utf-8")

    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh, delimiter=";")
        w.writerow(["constante", "url", "metodo", "controlador", "publicada", "archivo"])
        for e in eps:
            w.writerow([e["nombre"], e["url"], e["metodo"], e["controlador"],
                        "si" if e["publicado"] else "no", e["archivo"]])

    publicadas = sum(1 for e in eps if e["publicado"])
    metodos = Counter(e["metodo"] for e in eps if e["metodo"])

    metricas = "".join([
        canon.sb(len(eps), "URLs declaradas"),
        canon.sb(publicadas, "Publicadas", azul=True),
        canon.sb(len(eps) - publicadas, "Sin publicar"),
        canon.sb(controladores, "Controladores", azul=True),
    ])
    leyenda = "".join(canon.item_leyenda(m, n) for m, n in metodos.most_common())

    chips = "".join(f'<span class="chip" data-m="{m}">{m}</span>'
                    for m, _ in metodos.most_common(3))

    cuerpo = f"""
  <div class="nota">
    El canal declara sus URLs en una sola clase, <code>UrlConstantes</code>, y los controladores
    Spring del módulo <code>CPlaSuService</code> deciden cuáles se publican. Hay
    <b>{len(eps) - publicadas}</b> constantes que nadie expone: son candidatas a catálogo muerto y
    están marcadas como tales en vez de quedar mezcladas con las vivas.
  </div>

  <div class="bar">
    <input type="search" id="q" placeholder="Buscar constante, URL o controlador…">
    <select id="f-ctrl"><option value="">Todo controlador</option></select>
    {chips}
    <span class="chip" id="c-sin">Solo las que nadie publica</span>
    <a class="dl" href="data/endpoints-siweb.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando las URLs…</div>
  <div id="list"></div>
  <div class="pager">
    <button id="prev">Anterior</button>
    <span class="pg" id="pg"></span>
    <button id="next">Siguiente</button>
  </div>"""

    intro = (f"La superficie de servicio del canal de sucursal. <b>{len(eps):,}</b> URLs declaradas, "
             f"de las cuales <b>{publicadas:,}</b> están publicadas por alguno de los "
             f"<b>{controladores}</b> controladores del backend. Casi todo el tráfico es POST con "
             f"cuerpo JSON, porque el cliente JavaFX habla con su backend y no con un navegador.")

    salida = canon.pagina(
        titulo="SIWEB · Endpoints del Canal",
        vista="ENDPOINTS DEL CANAL",
        kick="Gemelo Cognitivo del canal de sucursal",
        h1=f"{len(eps):,} URLs declaradas<br>{publicadas:,} publicadas",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="core-siweb.html" class="back">Puente al core</a>'
                '<a href="pantallas-siweb.html" class="back">Pantallas</a>',
        cuerpo=cuerpo,
        pie=("SIWEB, canal de sucursal, ventanilla y caja. Vista generada por "
             "<code>build-endpoints-portal.py</code> con datos de <code>brain.db</code>.<br>"
             "El brain se reconstruye con <code>build-brain.py --reset</code> sobre el fuente "
             "<code>CPlaSu</code> en <code>source/code/</code>."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"urls  : {len(eps)} ({publicadas} publicadas en {controladores} controladores)")
    print(f"HTML  : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-portal.py — Vocabulario del canal AppMovil.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

El vocabulario tiene dos capas y la vista las muestra como lo que son:
  curada  — knowledge-base/vocabulario-curado.json, 196 términos con su
            significado escrito por el equipo, agrupados por concern
  minada  — brain.db::terms, 4,291 términos extraídos de los *Constants.java
            del canal; es materia prima, no glosario

La capa curada se lee primero. La minada se consulta cuando se busca algo que
no está curado todavía, y es la cantera de la que sale la siguiente curaduría.

Escribe:
  portal/data/vocab-curado.json
  portal/data/vocab-minado.json
  portal/data/vocabulario.csv
  portal/vocabulario.html
"""
import csv
import html
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

CURADO = canon.KB / "vocabulario-curado.json"
SALIDA_HTML = canon.PORTAL / "vocabulario.html"
JSON_CURADO = canon.DATA / "vocab-curado.json"
JSON_MINADO = canon.DATA / "vocab-minado.json"
SALIDA_CSV = canon.DATA / "vocabulario.csv"


def minado(con):
    """Términos que el brain extrae del código, con su categoría y procedencia."""
    filas = []
    for term, cat, meaning, source in con.execute(
            "SELECT term, cat, meaning, source FROM terms"):
        filas.append({"termino": term, "cat": cat or "ENTIDAD",
                      "significado": meaning or "", "origen": source or ""})
    filas.sort(key=lambda x: x["termino"].lower())
    return filas


CSS_EXTRA = r"""
.sec{margin:34px 0 0}
.sech{display:flex;align-items:baseline;gap:13px;margin:0 0 15px;padding-bottom:11px;
 border-bottom:1px solid rgba(255,255,255,.07)}
.sech h2{font-size:19px;font-weight:800;letter-spacing:-.02em}
.sech span{font-size:12.5px;color:var(--muted2)}
.tgrid{display:grid;gap:8px}
.tr{display:grid;grid-template-columns:230px 1fr 160px;gap:16px;align-items:start;
 background:rgba(255,255,255,.028);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:13px 17px}
.tr:hover{background:rgba(255,255,255,.05)}
@media(max-width:880px){.tr{grid-template-columns:1fr}}
.tnom{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:13px;font-weight:700;color:#e9edff;
 word-break:break-word}
.tcat{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;
 padding:2px 7px;border-radius:7px;margin-top:6px;background:rgba(255,255,255,.07);color:var(--muted2)}
.tcat.ENTIDAD{background:rgba(116,192,252,.14);color:#74c0fc}
.tcat.ACCION{background:rgba(140,233,154,.14);color:#8ce99a}
.tcat.PREFIJO{background:rgba(240,210,36,.14);color:var(--yellow)}
.tcat.ERROR{background:rgba(255,135,135,.14);color:#ff8787}
.tcat.CONFIGURACION{background:rgba(161,120,255,.14);color:#c4a7ff}
.tsig{font-size:13px;color:var(--muted);line-height:1.65}
.tsig code{font-family:'SF Mono',ui-monospace,monospace;font-size:11.5px;color:#c9d3f5;
 background:rgba(0,0,0,.3);padding:1px 5px;border-radius:5px}
.tamb{font-size:11.5px;color:var(--muted2);text-align:right}
@media(max-width:880px){.tamb{text-align:left}}
.tmin{border-left:3px solid rgba(161,120,255,.5)}
.tmin .tnom{color:#d9c9ff}
.origen{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;
 padding:2px 7px;border-radius:7px;margin-left:6px;background:rgba(161,120,255,.14);color:#c4a7ff}
.aviso{background:rgba(161,120,255,.07);border:1px solid rgba(161,120,255,.2);border-radius:13px;
 padding:14px 18px;font-size:12.5px;color:#ded2ff;line-height:1.65;margin-bottom:16px}
"""

JS = r"""
let CUR = [], SEC = [], MIN = [], incluirMinado = false, cargandoMin = false;
let cats = new Set();
const $ = s => document.querySelector(s);
const esc = s => (s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function filaCurada(t){
  return `<div class="tr">
    <div><div class="tnom">${esc(t.termino)}</div>
      <span class="tcat ${esc(t.cat)}">${esc(t.cat_label||t.cat)}</span></div>
    <div class="tsig">${t.significado}</div>
    <div class="tamb">${esc(t.ambito||'')}</div>
  </div>`;
}

function filaMinada(t){
  return `<div class="tr tmin">
    <div><div class="tnom">${esc(t.termino)}</div>
      <span class="tcat ${esc(t.cat)}">${esc(t.cat)}</span><span class="origen">Minado</span></div>
    <div class="tsig">${esc(t.significado) || '<i>Sin significado curado todavía</i>'}</div>
    <div class="tamb">${esc((t.origen||'').split(';')[0])}</div>
  </div>`;
}

function pintar(){
  const q = $('#q').value.trim().toLowerCase();
  const sec = $('#f-sec').value;
  let n = 0;
  const bloques = SEC.map(s=>{
    if (sec && s.id !== sec) return '';
    const ts = CUR.filter(t=>{
      if (t.seccion !== s.id) return false;
      if (cats.size && !cats.has(t.cat)) return false;
      if (!q) return true;
      return (t.termino+' '+t.busqueda+' '+t.significado).toLowerCase().includes(q);
    });
    if (!ts.length) return '';
    n += ts.length;
    return `<div class="sec"><div class="sech"><h2>${esc(s.titulo)}</h2>
      <span>${ts.length} de ${esc(s.nota)}</span></div>
      <div class="tgrid">${ts.map(filaCurada).join('')}</div></div>`;
  }).join('');

  let extra = '';
  if (incluirMinado && q){
    const vistos = new Set(CUR.map(t=>t.termino.toLowerCase()));
    const ms = MIN.filter(t=>!vistos.has(t.termino.toLowerCase())
                             && (t.termino+' '+t.significado).toLowerCase().includes(q)).slice(0,300);
    if (ms.length) extra = `<div class="sec"><div class="sech"><h2>Vocabulario minado</h2>
      <span>${ms.length} coincidencias sin curar${ms.length===300?', se muestran las primeras 300':''}</span></div>
      <div class="aviso">Estos términos salen directo de los <code>Constants.java</code> del canal.
        Son materia prima: no tienen significado escrito por el equipo todavía.</div>
      <div class="tgrid">${ms.map(filaMinada).join('')}</div></div>`;
  }

  $('#count').innerHTML = '<b>'+n+'</b> términos curados'+
    (n!==CUR.length ? ' de '+CUR.length : '') +
    (incluirMinado ? ' · '+MIN.length.toLocaleString('es-MX')+' minados disponibles' : '');
  $('#list').innerHTML = (bloques || (extra ? '' : '<div class="empty">Ningún término coincide con la búsqueda.</div>')) + extra;
}

function cargarMinado(){
  if (MIN.length || cargandoMin) return pintar();
  cargandoMin = true;
  fetch('data/vocab-minado.json').then(r=>r.json()).then(d=>{ MIN = d; cargandoMin = false; pintar(); });
}

fetch('data/vocab-curado.json').then(r=>r.json()).then(d=>{
  CUR = d.terminos; SEC = d.secciones;
  $('#f-sec').innerHTML += SEC.map(s=>`<option value="${s.id}">${esc(s.titulo)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/vocab-curado.json</code>. '+
    'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = ()=>{ incluirMinado ? cargarMinado() : pintar(); };
$('#f-sec').onchange = pintar;
document.querySelectorAll('.chip[data-cat]').forEach(c=>{
  c.onclick = ()=>{ c.classList.toggle('on');
    const v = c.dataset.cat; cats.has(v) ? cats.delete(v) : cats.add(v); pintar(); };
});
$('#c-min').onclick = function(){
  this.classList.toggle('on'); incluirMinado = !incluirMinado;
  incluirMinado ? cargarMinado() : pintar();
};
"""


def main():
    cur = json.loads(CURADO.read_text(encoding="utf-8"))
    con = sqlite3.connect(canon.DB)
    min_terms = minado(con)
    con.close()

    canon.DATA.mkdir(parents=True, exist_ok=True)
    JSON_CURADO.write_text(json.dumps(cur, ensure_ascii=False), encoding="utf-8")
    JSON_MINADO.write_text(json.dumps(min_terms, ensure_ascii=False), encoding="utf-8")

    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh, delimiter=";")
        w.writerow(["capa", "termino", "categoria", "significado", "ambito_u_origen"])
        for t in cur["terminos"]:
            w.writerow(["curado", t["termino"], t["cat"],
                        html.unescape(t["significado"]), t["ambito"]])
        for t in min_terms:
            w.writerow(["minado", t["termino"], t["cat"], t["significado"], t["origen"]])

    por_cat = Counter(t["cat"] for t in cur["terminos"])
    cats_min = Counter(t["cat"] for t in min_terms)

    metricas = "".join([
        canon.sb(len(cur["terminos"]), "Términos curados"),
        canon.sb(len(min_terms), "Términos minados", azul=True),
        canon.sb(len(cur["secciones"]), "Concerns"),
        canon.sb(cats_min.get("ENTIDAD", 0), "Entidades minadas", azul=True),
        canon.sb(cats_min.get("ERROR", 0), "Errores minados", azul=True),
    ])
    leyenda = "".join(canon.item_leyenda(c, n) for c, n in por_cat.most_common())

    chips = "".join(f'<span class="chip" data-cat="{c}">{c.capitalize()}</span>'
                    for c, _ in por_cat.most_common(6))

    cuerpo = f"""
  <div class="bar">
    <input type="search" id="q" placeholder="Buscar término, significado o sinónimo…">
    <select id="f-sec"><option value="">Todo concern</option></select>
    {chips}
    <span class="chip" id="c-min">Buscar también en lo minado</span>
    <a class="dl" href="data/vocabulario.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando el vocabulario…</div>
  <div id="list"></div>"""

    intro = (f"El glosario que traduce entre el código y el negocio del canal móvil. "
             f"<b>{len(cur['terminos'])}</b> términos curados, con su significado escrito por el equipo y "
             f"agrupados por concern. Debajo hay una cantera de <b>{len(min_terms):,}</b> términos que el "
             f"brain extrae de todos los <code>Constants.java</code> del canal: materia prima sin curar, "
             f"consultable desde la búsqueda.")

    salida = canon.pagina(
        titulo="AppMovil · Vocabulario del Canal",
        vista="VOCABULARIO DEL CANAL",
        kick="DT-Vocabulario · Gemelo Cognitivo",
        h1=f"{len(cur['terminos'])} términos curados<br>sobre {len(min_terms):,} minados",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="rules-appmovil.html" class="back">Reglas</a>'
                '<a href="sp-dependencies.html" class="back">Dependencias SP</a>',
        cuerpo=cuerpo,
        pie=("APPMOVIL · SPE-AM-001 · Vocabulario generado por <code>build-vocab-portal.py</code>.<br>"
             "La capa curada vive en <code>knowledge-base/vocabulario-curado.json</code>; "
             "la minada sale de <code>brain.db::terms</code> y se reconstruye con "
             "<code>build-brain.py</code>."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"curados : {len(cur['terminos'])} en {len(cur['secciones'])} concerns")
    print(f"minados : {len(min_terms):,}  {dict(cats_min)}")
    print(f"HTML    : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

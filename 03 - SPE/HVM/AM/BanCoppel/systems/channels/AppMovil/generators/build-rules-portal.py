#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-rules-portal.py — Catálogo de reglas de negocio del canal AppMovil.

Sigue el canon del portal Informix: `hero-bar` con logo y migaja, encabezado con
métricas, barra de filtros pegajosa, lista paginada y pie con procedencia. El
chrome vive en `_canon.py`.

Lee `brain.db::rules` y escribe:
  portal/data/rules-data.json   — los datos que consume la página
  portal/data/rules.csv         — el mismo catálogo, para importar a un ALM
  portal/rules-appmovil.html    — la vista

Uso:
  python generators/build-rules-portal.py

El HTML carga el JSON con fetch(), así que hay que servirlo por HTTP.
"""
import csv
import html
import json
import sqlite3
import sys
from collections import Counter

import importlib.util
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SALIDA_HTML = canon.PORTAL / "rules-appmovil.html"
SALIDA_JSON = canon.DATA / "rules-data.json"
SALIDA_CSV = canon.DATA / "rules.csv"

# Orden de presentación: primero lo que decide una migración, al final el ruido.
ORDEN_TIPO = ["VALIDACIÓN", "UMBRAL", "CÓDIGO_ERROR", "CONFIGURACIÓN", "ANOTACIÓN"]


def leer(con):
    con.row_factory = sqlite3.Row
    filas = []
    for r in con.execute("""
        SELECT id, tipo, sp, db, domain, line, code, reg, riesgo,
               business_name, clase, sub_tipo, source_file, descripcion_regla
        FROM rules
    """):
        d = dict(r)
        # El microservicio es el primer tramo de `sp`: "msaxx-...:Clase"
        d["msa"] = (d["sp"] or "").split(":")[0]
        d["origen"] = (d["sp"] or "").split(":")[-1]
        filas.append(d)
    filas.sort(key=lambda x: (ORDEN_TIPO.index(x["tipo"]) if x["tipo"] in ORDEN_TIPO else 9,
                              x["domain"] or "", x["msa"], x["line"] or 0))
    return filas


def escribir_datos(filas):
    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(json.dumps(filas, ensure_ascii=False), encoding="utf-8")
    campos = ["id", "tipo", "clase", "sub_tipo", "domain", "msa", "origen",
              "line", "descripcion_regla", "code", "reg", "riesgo", "source_file"]
    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=campos, delimiter=";", extrasaction="ignore")
        w.writeheader()
        w.writerows(filas)


CSS_EXTRA = r"""
.rc{border:1px solid rgba(255,255,255,.07);border-left-width:3px;border-radius:13px;background:rgba(255,255,255,.028);
 margin-bottom:9px;transition:.18s}
.rc:hover{background:rgba(255,255,255,.055)}
.rc.t-val{border-left-color:#74c0fc}.rc.t-umb{border-left-color:#ffd43b}
.rc.t-err{border-left-color:#ff8787}.rc.t-cfg{border-left-color:#8ce99a}
.rc.t-ano{border-left-color:rgba(255,255,255,.14)}
.rch{display:flex;gap:14px;align-items:center;padding:14px 18px;cursor:pointer}
.rcid{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:10.5px;color:var(--muted2);min-width:168px;flex-shrink:0}
.rct{flex:1;font-size:13.5px;line-height:1.5;color:#e9edff}
.rcd{padding:0 18px 16px;display:none}
.rc.open .rcd{display:block}
.riesgo{margin-top:11px;border-left:3px solid #ff8787;padding:9px 13px;background:rgba(255,135,135,.07);
 border-radius:0 10px 10px 0;font-size:12px;color:#ffd7d7;line-height:1.55}
.tag.v{background:rgba(116,192,252,.14);color:#74c0fc}
.tag.u{background:rgba(255,212,59,.14);color:#ffd43b}
.tag.e{background:rgba(255,135,135,.14);color:#ff8787}
.tag.c{background:rgba(140,233,154,.14);color:#8ce99a}
.tag.a{background:rgba(255,255,255,.07);color:var(--muted2)}
.tag.reg{background:rgba(240,210,36,.13);color:var(--yellow)}
.tag.neg{background:rgba(161,120,255,.14);color:#c4a7ff}
"""

JS = r"""
const TAM = 60;
let TODO = [], VIS = [], pag = 0, abierta = null;
let tipos = new Set(), soloNegocio = false, soloRiesgo = false;
const $ = s => document.querySelector(s);
const esc = s => (s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

const CLASE_TIPO = {'VALIDACIÓN':'t-val','UMBRAL':'t-umb','CÓDIGO_ERROR':'t-err',
                    'CONFIGURACIÓN':'t-cfg','ANOTACIÓN':'t-ano'};
const TAG_TIPO = {'VALIDACIÓN':'v','UMBRAL':'u','CÓDIGO_ERROR':'e',
                  'CONFIGURACIÓN':'c','ANOTACIÓN':'a'};

function fila(r){
  const ab = r.id === abierta;
  const regs = (r.reg||'').split(';').map(x=>x.trim()).filter(Boolean)
      .map(x=>`<span class="tag reg">${esc(x.split('—')[0].trim())}</span>`).join('');
  return `<div class="rc ${CLASE_TIPO[r.tipo]||''} ${ab?'open':''}" data-id="${esc(r.id)}">
    <div class="rch">
      <span class="rcid">${esc(r.id)}</span>
      <span class="rct">${esc(r.descripcion_regla || r.business_name || r.code)}</span>
      <span class="tags">
        ${r.clase==='NEGOCIO'?'<span class="tag neg">Negocio</span>':''}
        ${regs}
        <span class="tag ${TAG_TIPO[r.tipo]||'a'}">${esc(r.tipo)}</span>
      </span>
    </div>
    <div class="rcd">
      <div class="ev">
        <div class="evk">Código fuente</div>
        <div class="evv">${esc(r.code)}</div>
        <div class="evm">
          <span>Microservicio <b>${esc(r.msa)}</b></span>
          ${r.line?`<span>Línea <b>${r.line}</b></span>`:''}
          <span>Dominio <b>${esc(r.domain||'sin dominio')}</b></span>
          ${r.sub_tipo?`<span>Naturaleza <b>${esc(r.sub_tipo)}</b></span>`:''}
          <span>Archivo <b>${esc(r.source_file)}</b></span>
        </div>
      </div>
      ${r.riesgo?`<div class="riesgo"><b>Riesgo de equivalencia:</b> ${esc(r.riesgo)}</div>`:''}
    </div>
  </div>`;
}

function filtrar(){
  const q = $('#q').value.trim().toLowerCase();
  const dom = $('#f-dom').value, msa = $('#f-msa').value;
  VIS = TODO.filter(r=>{
    if (tipos.size && !tipos.has(r.tipo)) return false;
    if (soloNegocio && r.clase !== 'NEGOCIO') return false;
    if (soloRiesgo && !r.riesgo) return false;
    if (dom && r.domain !== dom) return false;
    if (msa && r.msa !== msa) return false;
    if (!q) return true;
    return (r.id+' '+(r.descripcion_regla||'')+' '+(r.code||'')+' '+r.msa+' '+(r.sub_tipo||''))
             .toLowerCase().includes(q);
  });
  pag = 0; pintar();
}

function pintar(){
  const total = VIS.length, paginas = Math.ceil(total/TAM);
  const trozo = VIS.slice(pag*TAM, pag*TAM+TAM);
  $('#count').innerHTML = '<b>'+total.toLocaleString('es-MX')+'</b> reglas'+
    (total!==TODO.length ? ' de '+TODO.length.toLocaleString('es-MX') : '');
  $('#list').innerHTML = trozo.length ? trozo.map(fila).join('')
    : '<div class="empty">Ninguna regla coincide con el filtro.</div>';
  $('#pager').innerHTML = paginas > 1
    ? `<button id="prev" ${pag===0?'disabled':''}>Anterior</button>
       <span class="pg">${pag+1} de ${paginas}</span>
       <button id="next" ${pag>=paginas-1?'disabled':''}>Siguiente</button>` : '';
  const p = $('#prev'), n = $('#next');
  if (p) p.onclick = ()=>{pag--;pintar();window.scrollTo({top:420,behavior:'smooth'});};
  if (n) n.onclick = ()=>{pag++;pintar();window.scrollTo({top:420,behavior:'smooth'});};
  document.querySelectorAll('.rc').forEach(el=>{
    el.querySelector('.rch').onclick = ()=>{
      abierta = (abierta === el.dataset.id) ? null : el.dataset.id; pintar();
    };
  });
}

fetch('data/rules-data.json').then(r=>r.json()).then(d=>{
  TODO = d; VIS = d;
  const doms = [...new Set(d.map(r=>r.domain).filter(Boolean))].sort();
  $('#f-dom').innerHTML += doms.map(x=>`<option value="${esc(x)}">${esc(x)}</option>`).join('');
  const msas = [...new Set(d.map(r=>r.msa).filter(Boolean))].sort();
  $('#f-msa').innerHTML += msas.map(x=>`<option value="${esc(x)}">${esc(x)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/rules-data.json</code>. '+
    'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = filtrar;
$('#f-dom').onchange = filtrar;
$('#f-msa').onchange = filtrar;
document.querySelectorAll('.chip[data-t]').forEach(c=>{
  c.onclick = ()=>{ c.classList.toggle('on');
    const t = c.dataset.t; tipos.has(t) ? tipos.delete(t) : tipos.add(t); filtrar(); };
});
$('#c-neg').onclick = function(){ this.classList.toggle('on'); soloNegocio = !soloNegocio; filtrar(); };
$('#c-rsg').onclick = function(){ this.classList.toggle('on'); soloRiesgo = !soloRiesgo; filtrar(); };
"""


def main():
    con = sqlite3.connect(canon.DB)
    filas = leer(con)
    con.close()

    escribir_datos(filas)

    por_tipo = Counter(f["tipo"] for f in filas)
    negocio = sum(1 for f in filas if f["clase"] == "NEGOCIO")
    con_riesgo = sum(1 for f in filas if f["riesgo"])
    con_reg = sum(1 for f in filas if f["reg"])
    msas = len({f["msa"] for f in filas if f["msa"]})

    metricas = "".join([
        canon.sb(len(filas), "Reglas"),
        canon.sb(negocio, "De negocio"),
        canon.sb(por_tipo.get("VALIDACIÓN", 0), "Validaciones", azul=True),
        canon.sb(por_tipo.get("UMBRAL", 0), "Umbrales", azul=True),
        canon.sb(por_tipo.get("CONFIGURACIÓN", 0), "Configuración", azul=True),
        canon.sb(con_reg, "Con regulador"),
        canon.sb(con_riesgo, "Con riesgo de equivalencia"),
    ])
    leyenda = "".join(canon.item_leyenda(t, por_tipo[t])
                      for t in ORDEN_TIPO if por_tipo.get(t))

    chips = "".join(f'<span class="chip" data-t="{t}">{t.capitalize()}</span>'
                    for t in ORDEN_TIPO if por_tipo.get(t))

    cuerpo = f"""
  <div class="bar">
    <input type="search" id="q" placeholder="Buscar por descripción, código, identificador o microservicio…">
    <select id="f-dom"><option value="">Todo dominio</option></select>
    <select id="f-msa"><option value="">Todo microservicio</option></select>
    {chips}
    <span class="chip" id="c-neg">Solo negocio</span>
    <span class="chip" id="c-rsg">Con riesgo</span>
    <a class="dl" href="data/rules.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando el catálogo…</div>
  <div id="list"></div>
  <div class="pager" id="pager"></div>"""

    intro = (f"Las reglas que gobiernan el canal móvil, destiladas del código Java de los "
             f"<b>215 microservicios</b>. Cada una trae su trazabilidad: el archivo, la línea y el "
             f"fragmento que la sustenta. <b>{negocio:,}</b> son de negocio y el resto describe "
             f"infraestructura del canal. Clic en cualquier regla para ver su evidencia.")

    salida = canon.pagina(
        titulo="AppMovil · Catálogo de Reglas de Negocio",
        vista="CATÁLOGO DE REGLAS DE NEGOCIO",
        kick="DT-Reglas · Gemelo Cognitivo",
        h1=f"{len(filas):,} reglas de negocio<br>extraídas del canal",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="vocabulario.html" class="back">Vocabulario</a>'
                '<a href="sp-dependencies.html" class="back">Dependencias SP</a>',
        cuerpo=cuerpo,
        pie=(f"APPMOVIL · SPE-AM-001 · Catálogo generado por <code>build-rules-portal.py</code> "
             f"desde <code>brain.db</code>, sobre {msas} microservicios.<br>"
             f"El CSV usa punto y coma como separador y UTF-8 con BOM, listo para importar a un ALM."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"reglas      : {len(filas):,}")
    print(f"  de negocio: {negocio:,}   con riesgo: {con_riesgo}   con regulador: {con_reg}")
    print(f"  por tipo  : {dict(por_tipo)}")
    print(f"JSON  : {SALIDA_JSON}")
    print(f"CSV   : {SALIDA_CSV}")
    print(f"HTML  : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

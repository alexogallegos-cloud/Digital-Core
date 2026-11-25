#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-core-portal.py — El puente de SIWEB hacia el core.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

Esta es la vista que importa para modernizar el canal. SIWEB no abre JDBC
contra Informix: cada operación de core se pide al BUS por un identificador
numérico, desde un DAO dedicado por base de datos. El contrato a preservar es
ese catálogo de identificadores, no un inventario de stored procedures.

La página muestra dos capas:
  puentes   — un DAO por base de datos alcanzada, con su volumen
  servicios — los identificadores del catálogo, con dónde se invoca cada uno

Escribe:
  portal/data/core-siweb.json
  portal/data/core-siweb.csv
  portal/core-siweb.html
"""
import csv
import html
import importlib.util
import json
import sqlite3
import sys
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SALIDA_HTML = canon.PORTAL / "core-siweb.html"
SALIDA_JSON = canon.DATA / "core-siweb.json"
SALIDA_CSV = canon.DATA / "core-siweb.csv"

# Bases que el DAO alcanza pero que no son bases Informix del core bancario.
# Se marcan para que el conteo de puentes no se lea como bases del core.
NO_CORE = {"AIDABAN", "COPPEL", "INTERAPI"}


def datos(con):
    puentes = []
    for dom, dao, bean, archivo, ws, met in con.execute(
            "SELECT db_domain, dao_class, bean_name, file, ws_ids_used, methods "
            "FROM core_bridges ORDER BY ws_ids_used DESC"):
        puentes.append({
            "base": dom, "dao": dao.split(".")[-1], "bean": bean or "",
            "archivo": archivo, "servicios": ws, "metodos": met,
            "core": dom not in NO_CORE,
        })

    usos = {}
    for const, base, dao, metodo in con.execute(
            "SELECT constant, db_domain, dao_class, method FROM ws_usages"):
        usos.setdefault(const, []).append(
            {"base": base, "dao": dao.split(".")[-1], "metodo": metodo or ""})

    servicios = []
    for const, wsid, grupo, usados in con.execute(
            "SELECT constant, ws_id, functional_group, usages FROM ws_services "
            "ORDER BY constant"):
        propios = usos.get(const, [])
        servicios.append({
            "nombre": const, "id": wsid, "grupo": grupo or "Sin sección declarada",
            "usos": usados, "bases": sorted({u["base"] for u in propios}),
            "donde": propios[:12],
        })

    compartidos = {wid for (wid,) in con.execute(
        "SELECT ws_id FROM ws_services GROUP BY ws_id HAVING COUNT(*) > 1")}
    for s in servicios:
        s["compartido"] = s["id"] in compartidos

    return puentes, servicios


CSS_EXTRA = r"""
.sec{margin:30px 0 0}
.sech{display:flex;align-items:baseline;gap:13px;margin:0 0 15px;padding-bottom:11px;
 border-bottom:1px solid rgba(255,255,255,.07)}
.sech h2{font-size:19px;font-weight:800;letter-spacing:-.02em}
.sech span{font-size:12.5px;color:var(--muted2)}
.bgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(224px,1fr));gap:11px}
.bcard{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.08);
 border-left:3px solid var(--blue);border-radius:13px;padding:15px 17px;cursor:pointer;transition:.2s}
.bcard:hover{background:rgba(255,255,255,.06)}
.bcard.on{border-color:var(--yellow);border-left-color:var(--yellow);background:rgba(240,210,36,.07)}
.bcard.nocore{border-left-color:#ffa94d}
.bcard .bn{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:13.5px;font-weight:700;color:#e9edff}
.bcard .bd{font-size:11.5px;color:var(--muted2);margin-top:5px}
.bcard .bm{display:flex;gap:14px;margin-top:11px;font-size:11.5px;color:var(--muted)}
.bcard .bm b{color:var(--yellow);font-weight:700;font-variant-numeric:tabular-nums}
.wsid{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11px;color:var(--muted2);
 min-width:62px;flex-shrink:0;text-align:right}
.grp{font-size:11.5px;color:var(--muted2);flex-shrink:0;max-width:220px;overflow:hidden;
 text-overflow:ellipsis;white-space:nowrap}
.t-base{color:#93c5fd;background:rgba(147,197,253,.1);border:1px solid rgba(147,197,253,.26);
 font-family:'SF Mono',ui-monospace,monospace}
.nota{background:rgba(240,210,36,.06);border:1px solid rgba(240,210,36,.18);border-radius:13px;
 padding:14px 18px;font-size:12.5px;color:#f1e9c8;line-height:1.7;margin:16px 0 4px}
.nota b{color:#fff;font-weight:600}
"""

JS = r"""
let PUENTES = [], SERV = [], base = '', pag = 0, soloSin = false, soloComp = false;
const POR = 60;
const $ = s => document.querySelector(s);
const esc = s => (s==null?'':String(s)).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function pintarPuentes(){
  $('#puentes').innerHTML = PUENTES.map(p=>`
    <div class="bcard${p.base===base?' on':''}${p.core?'':' nocore'}" data-base="${esc(p.base)}">
      <div class="bn">${esc(p.base)}</div>
      <div class="bd">${esc(p.dao)}${p.core?'':' — fuera del core bancario'}</div>
      <div class="bm"><span>Servicios <b>${p.servicios}</b></span><span>Métodos <b>${p.metodos}</b></span></div>
    </div>`).join('');
  document.querySelectorAll('.bcard').forEach(c=>{
    c.onclick = ()=>{ base = (base===c.dataset.base) ? '' : c.dataset.base; pag=0; pintar(); };
  });
}

function filtrados(){
  const q = $('#q').value.trim().toLowerCase();
  const grupo = $('#f-grupo').value;
  return SERV.filter(s=>{
    if (base && !s.bases.includes(base)) return false;
    if (grupo && s.grupo !== grupo) return false;
    if (soloSin && s.usos > 0) return false;
    if (soloComp && !s.compartido) return false;
    if (!q) return true;
    return (s.nombre+' '+s.id+' '+s.grupo+' '+s.bases.join(' ')).toLowerCase().includes(q);
  });
}

function tarjeta(s){
  const tags = s.bases.map(b=>`<span class="tag t-base">${esc(b)}</span>`).join('')
    + (s.usos===0 ? '<span class="tag t-risk">Sin invocar</span>' : '')
    + (s.compartido ? '<span class="tag t-p1">Número compartido</span>' : '');
  const filas = s.donde.map(d=>`<tr><td class="mono">${esc(d.base)}</td><td class="mono">${esc(d.dao)}</td><td>${esc(d.metodo)}</td></tr>`).join('');
  const det = s.donde.length
    ? `<table class="dt"><tr><th>Base</th><th>DAO</th><th>Método</th></tr>${filas}</table>`
    : '<div class="gv">Ningún DAO lo invoca. Está declarado en el catálogo y nunca se pide.</div>';
  return `<div class="tc ${s.usos===0?'p3':(s.compartido?'p1':'p2')}">
    <div class="tch" onclick="this.nextElementSibling.style.display=this.nextElementSibling.style.display==='block'?'none':'block'">
      <span class="wsid">${s.id}</span>
      <span class="tct">${esc(s.nombre)}</span>
      <span class="grp">${esc(s.grupo)}</span>
      <span class="tags">${tags}</span>
    </div>
    <div class="det" style="display:none">
      <div class="gw"><div class="gk">Sección</div><div class="gv">${esc(s.grupo)}</div></div>
      ${det}
    </div>
  </div>`;
}

function pintar(){
  pintarPuentes();
  const fs = filtrados();
  const total = Math.max(1, Math.ceil(fs.length/POR));
  if (pag >= total) pag = total-1;
  const trozo = fs.slice(pag*POR,(pag+1)*POR);
  $('#count').innerHTML = `<b>${fs.length.toLocaleString('es-MX')}</b> servicios de core`
    + (fs.length!==SERV.length ? ` de ${SERV.length.toLocaleString('es-MX')}` : '')
    + (base ? ` que atienden a ${esc(base)}` : '');
  $('#list').innerHTML = trozo.length ? trozo.map(tarjeta).join('')
    : '<div class="empty">Ningún servicio coincide con el filtro.</div>';
  $('#pg').textContent = `Página ${pag+1} de ${total}`;
  $('#prev').disabled = pag===0; $('#next').disabled = pag>=total-1;
}

fetch('data/core-siweb.json').then(r=>r.json()).then(d=>{
  PUENTES = d.puentes; SERV = d.servicios;
  const grupos = [...new Set(SERV.map(s=>s.grupo))].sort();
  $('#f-grupo').innerHTML += grupos.map(g=>`<option value="${esc(g)}">${esc(g)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/core-siweb.json</code>. '
    + 'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = ()=>{ pag=0; pintar(); };
$('#f-grupo').onchange = ()=>{ pag=0; pintar(); };
$('#c-sin').onclick = function(){ this.classList.toggle('on'); soloSin=!soloSin; pag=0; pintar(); };
$('#c-comp').onclick = function(){ this.classList.toggle('on'); soloComp=!soloComp; pag=0; pintar(); };
$('#prev').onclick = ()=>{ if(pag>0){pag--; scrollTo(0,0); pintar();} };
$('#next').onclick = ()=>{ pag++; scrollTo(0,0); pintar(); };
"""


def main():
    con = sqlite3.connect(canon.DB)
    puentes, servicios = datos(con)
    con.close()

    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(
        json.dumps({"puentes": puentes, "servicios": servicios}, ensure_ascii=False),
        encoding="utf-8")

    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh, delimiter=";")
        w.writerow(["identificador", "numero", "seccion", "invocaciones",
                    "bases", "numero_compartido"])
        for s in servicios:
            w.writerow([s["nombre"], s["id"], s["grupo"], s["usos"],
                        ", ".join(s["bases"]), "si" if s["compartido"] else "no"])

    usados = sum(1 for s in servicios if s["usos"] > 0)
    compartidos = len({s["id"] for s in servicios if s["compartido"]})
    core = sum(1 for p in puentes if p["core"])

    metricas = "".join([
        canon.sb(len(servicios), "Servicios de core"),
        canon.sb(usados, "Invocados", azul=True),
        canon.sb(len(servicios) - usados, "Sin invocar"),
        canon.sb(len(puentes), "Puentes de datos", azul=True),
        canon.sb(compartidos, "Números compartidos"),
    ])
    leyenda = "".join([
        canon.item_leyenda("Bases del core bancario", core),
        canon.item_leyenda("Fuera del core", len(puentes) - core),
        canon.item_leyenda("Secciones funcionales",
                           len({s["grupo"] for s in servicios})),
        canon.item_leyenda("Invocaciones totales", sum(s["usos"] for s in servicios)),
    ])

    cuerpo = f"""
  <div class="nota">
    SIWEB no abre conexiones JDBC contra Informix. Cada operación de core se pide al
    <b>BUS</b> por un identificador numérico, desde un DAO dedicado por base de datos, con XML
    armado a mano sobre Apache HttpClient y leído de vuelta con Jsoup. Lo que hay que preservar al
    modernizar es este catálogo de <b>{len(servicios)}</b> identificadores, no un inventario de
    stored procedures: los 240 <code>EXECUTE PROCEDURE</code> que quedan en el código son un fósil
    del acceso directo anterior y ninguno está en uso.
  </div>

  <div class="sec">
    <div class="sech"><h2>Puentes de datos</h2>
      <span>{len(puentes)} destinos, {core} de ellos bases del core bancario. Haz clic para filtrar el catálogo</span></div>
    <div class="bgrid" id="puentes"></div>
  </div>

  <div class="sec">
    <div class="sech"><h2>Catálogo de servicios</h2>
      <span>Haz clic en un servicio para ver desde qué DAO y método se pide</span></div>
  </div>
  <div class="bar">
    <input type="search" id="q" placeholder="Buscar identificador, número, sección o base…">
    <select id="f-grupo"><option value="">Toda sección</option></select>
    <span class="chip" id="c-sin">Solo los que nunca se invocan</span>
    <span class="chip" id="c-comp">Solo números compartidos</span>
    <a class="dl" href="data/core-siweb.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando el catálogo…</div>
  <div id="list"></div>
  <div class="pager">
    <button id="prev">Anterior</button>
    <span class="pg" id="pg"></span>
    <button id="next">Siguiente</button>
  </div>"""

    intro = (f"El contrato real entre el canal de sucursal y el core bancario. "
             f"<b>{len(servicios)}</b> identificadores de servicio declarados, de los cuales "
             f"<b>{usados}</b> se invocan desde alguno de los <b>{len(puentes)}</b> DAOs del canal. "
             f"Cada identificador es una operación que el BUS resuelve contra Informix, así que esta "
             f"lista es la superficie que cualquier reemplazo del core tiene que seguir atendiendo.")

    salida = canon.pagina(
        titulo="SIWEB · Puente al Core",
        vista="PUENTE AL CORE",
        kick="Gemelo Cognitivo del canal de sucursal",
        h1=f"{len(servicios)} servicios de core<br>en {len(puentes)} puentes de datos",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="endpoints-siweb.html" class="back">Endpoints</a>'
                '<a href="pantallas-siweb.html" class="back">Pantallas</a>',
        cuerpo=cuerpo,
        pie=("SIWEB, canal de sucursal, ventanilla y caja. Vista generada por "
             "<code>build-core-portal.py</code> con datos de <code>brain.db</code>.<br>"
             "El brain se reconstruye con <code>build-brain.py --reset</code> sobre el fuente "
             "<code>CPlaSu</code> en <code>source/code/</code>."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"puentes   : {len(puentes)} ({core} del core bancario)")
    print(f"servicios : {len(servicios)} ({usados} invocados, {compartidos} con número compartido)")
    print(f"HTML      : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

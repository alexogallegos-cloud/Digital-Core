#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-sp-portal.py — Puente JDBC del canal AppMovil hacia los SPs de Informix.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

Cruza dos fuentes y deja ver la costura:
  brain.db::sp_calls + sp_properties — lo que el análisis estático detecta
  knowledge-base/sp-curado.json      — función, criticidad, evidencia y olas,
                                       que son conocimiento curado por el equipo

Un SP puede estar en una fuente y no en la otra, y eso importa: los que solo
están en el catálogo curado son los que la inferencia estática no alcanza,
porque su nombre viaja sin prefijo de base.

Escribe:
  portal/data/sp-data.json        — el inventario cruzado
  portal/data/sp-dependencies.csv — el mismo inventario, plano
  portal/sp-dependencies.html     — la vista
"""
import csv
import html
import importlib.util
import json
import sqlite3
import sys
from collections import Counter, defaultdict
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

CURADO = canon.KB / "sp-curado.json"
SALIDA_HTML = canon.PORTAL / "sp-dependencies.html"
SALIDA_JSON = canon.DATA / "sp-data.json"
SALIDA_CSV = canon.DATA / "sp-dependencies.csv"

# Los cuatro SPs verificados a mano en el código que la inferencia estática no
# puede ubicar: su nombre va sin prefijo y el repo declara más de un datasource.
# Ver la sección "Gap Residual" del CLAUDE.md del sistema.
HUECOS = {
    "sp_proyecta_prest_credisol": "bdicred",
    "sp_registro_cte_cvv2din": "intercard",
    "sp_activatarjeta_iccat": "intercard",
    "sp_valida_celular_cancelado": "bdinteg",
}


def del_brain(con):
    """Pares base y SP detectados, con los microservicios que los consumen."""
    consumidores = defaultdict(set)
    pares = set()
    for tabla in ("sp_calls", "sp_properties"):
        for svc, db, sp in con.execute(
                f"SELECT service_id, db_name, sp_name FROM {tabla}"):
            if not sp:
                continue
            clave = ((db or "").lower(), sp.lower())
            pares.add(clave)
            consumidores[clave].add(svc)
    return pares, consumidores


def construir(con, curado):
    """
    Una fila por par base y SP, no por nombre.

    `sp_confpgserv_dina` vive en bdicheq y en bdisac: son dos dependencias
    distintas del canal y cada base tiene que mostrarla. Deduplicar por nombre
    la escondía de una de las dos.
    """
    pares, consumidores = del_brain(con)
    meta = {c["sp"].lower(): c for c in curado["sps"]}

    todos = set(pares) | {(db, sp) for sp, db in HUECOS.items()}
    filas = []
    for db, sp in sorted(todos, key=lambda x: (x[1], x[0])):
        c = meta.get(sp, {})
        filas.append({
            "sp": sp,
            "db": db,
            "funcion": c.get("funcion", ""),
            "criticidad": c.get("criticidad", "") or "SIN CLASIFICAR",
            "evidencia": c.get("evidencia", ""),
            "grupo": c.get("grupo", ""),
            "detectado": (db, sp) in pares,
            "consumidores": sorted(consumidores.get((db, sp), [])),
            "curado": sp in meta,
            "multibase": sum(1 for d, n in todos if n == sp) > 1,
        })
    return filas


def escribir_datos(filas, olas, bases):
    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(json.dumps(
        {"sps": filas, "olas": olas, "bases": bases}, ensure_ascii=False),
        encoding="utf-8")
    campos = ["sp", "db", "funcion", "criticidad", "grupo", "detectado",
              "curado", "evidencia"]
    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=campos, delimiter=";", extrasaction="ignore")
        w.writeheader()
        for f in filas:
            w.writerow(f)


CSS_EXTRA = r"""
.sc{border:1px solid rgba(255,255,255,.07);border-left-width:3px;border-radius:13px;background:rgba(255,255,255,.028);
 margin-bottom:9px;transition:.18s}
.sc:hover{background:rgba(255,255,255,.055)}
.sc.c-crit{border-left-color:#ff8787}.sc.c-alto{border-left-color:#ffd43b}
.sc.c-medio{border-left-color:#74c0fc}.sc.c-bajo{border-left-color:rgba(255,255,255,.14)}
.sch{display:flex;gap:14px;align-items:center;padding:14px 18px;cursor:pointer}
.scn{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:12.5px;color:#e9edff;min-width:270px;flex-shrink:0}
.scf{flex:1;font-size:13px;line-height:1.5;color:var(--muted)}
.scd{padding:0 18px 16px;display:none}
.sc.open .scd{display:block}
.tag.db{background:rgba(61,95,205,.2);color:#9fb4ff}
.tag.crit{background:rgba(255,135,135,.14);color:#ff8787}
.tag.alto{background:rgba(255,212,59,.14);color:#ffd43b}
.tag.medio{background:rgba(116,192,252,.14);color:#74c0fc}
.tag.manual{background:rgba(161,120,255,.16);color:#c4a7ff}
.nota{margin-top:11px;border-left:3px solid #c4a7ff;padding:9px 13px;background:rgba(161,120,255,.07);
 border-radius:0 10px 10px 0;font-size:12px;color:#e2d7ff;line-height:1.55}
.sec{margin:46px 0 0}
.sec h2{font-size:clamp(20px,2.6vw,27px);font-weight:900;letter-spacing:-.025em;margin-bottom:8px}
.sec p.sd{color:var(--muted);font-size:13.5px;line-height:1.7;max-width:84ch;margin-bottom:20px}
.dbgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(276px,1fr));gap:13px}
.dbc{background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.08);border-radius:15px;padding:17px 19px}
.dbn{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:14px;font-weight:700;color:var(--yellow)}
.dbd{font-size:12.5px;color:var(--muted);margin:7px 0 11px;line-height:1.55}
.dbm{font-size:11.5px;color:var(--muted2);line-height:1.7}
.dbm b{color:#c9d3f5}
.ola{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:20px 22px;margin-bottom:13px}
.olah{display:flex;gap:15px;align-items:center;margin-bottom:13px}
.olan{width:52px;height:52px;flex-shrink:0;border-radius:14px;display:flex;align-items:center;justify-content:center;
 font-family:'SF Mono',ui-monospace,monospace;font-size:14px;font-weight:800;background:rgba(255,255,255,.06);
 border:1px solid rgba(255,255,255,.12);color:var(--yellow)}
.olan.crit{background:rgba(255,135,135,.13);border-color:rgba(255,135,135,.3);color:#ff8787}
.olan.warn{background:rgba(255,212,59,.12);border-color:rgba(255,212,59,.28);color:#ffd43b}
.olan.info{background:rgba(116,192,252,.12);border-color:rgba(116,192,252,.28);color:#74c0fc}
.olat h3{font-size:17px;font-weight:800;letter-spacing:-.015em}
.olas{font-size:12.5px;color:var(--muted2);margin-top:4px}
.chips{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:11px}
.spchip{font-family:'SF Mono',ui-monospace,monospace;font-size:10.5px;background:rgba(255,255,255,.05);
 border:1px solid rgba(255,255,255,.1);border-radius:8px;padding:4px 9px;color:#c9d3f5}
.olar{border-left:3px solid var(--yellow);padding:10px 14px;background:rgba(240,210,36,.06);
 border-radius:0 10px 10px 0;font-size:12.5px;color:#eee6c4;line-height:1.6}
"""

JS = r"""
let TODO = [], VIS = [], abierto = null;
let crits = new Set(), soloManual = false;
const $ = s => document.querySelector(s);
const esc = s => (s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const CL = {'CRÍTICO':'c-crit','ALTO':'c-alto','MEDIO':'c-medio'};
const TG = {'CRÍTICO':'crit','ALTO':'alto','MEDIO':'medio'};

function fila(s){
  const ab = s.sp === abierto;
  return `<div class="sc ${CL[s.criticidad]||'c-bajo'} ${ab?'open':''}" data-sp="${esc(s.sp)}">
    <div class="sch">
      <span class="scn">${esc(s.sp)}</span>
      <span class="scf">${esc(s.funcion || 'Sin descripción curada')}</span>
      <span class="tags">
        ${!s.detectado?'<span class="tag manual">Verificado a mano</span>':''}
        ${s.multibase?'<span class="tag manual">En dos bases</span>':''}
        <span class="tag db">${esc(s.db||'?')}</span>
        <span class="tag ${TG[s.criticidad]||'a'}">${esc(s.criticidad)}</span>
      </span>
    </div>
    <div class="scd">
      <div class="ev">
        <div class="evk">Evidencia en código</div>
        <div class="evv">${esc(s.evidencia || 'Sin evidencia curada registrada')}</div>
        <div class="evm"><div class="evk">Microservicios consumidores (${s.consumidores.length})</div>
          <div class="evv">${s.consumidores.length ? esc(s.consumidores.join('\n')) : 'Ninguno detectado por el análisis estático'}</div></div>
        ${s.grupo?`<div class="evm"><div class="evk">Dominio funcional</div><div class="evv">${esc(s.grupo)}</div></div>`:''}
      </div>
      ${!s.detectado?`<div class="nota"><b>Fuera del alcance de la inferencia:</b> este SP está confirmado en el código, pero su nombre viaja sin prefijo de base y el microservicio declara más de un datasource. Ubicarlo automáticamente arriesgaría asignarlo a la base equivocada, así que su base viene del catálogo curado.</div>`:''}
    </div>
  </div>`;
}

function filtrar(){
  const q = $('#q').value.trim().toLowerCase();
  const db = $('#f-db').value;
  VIS = TODO.filter(s=>{
    if (crits.size && !crits.has(s.criticidad)) return false;
    if (soloManual && s.detectado) return false;
    if (db && s.db !== db) return false;
    if (!q) return true;
    return (s.sp+' '+(s.funcion||'')+' '+(s.evidencia||'')+' '+s.consumidores.join(' '))
             .toLowerCase().includes(q);
  });
  pintar();
}

function pintar(){
  $('#count').innerHTML = '<b>'+VIS.length+'</b> stored procedures'+
    (VIS.length!==TODO.length ? ' de '+TODO.length : '');
  $('#list').innerHTML = VIS.length ? VIS.map(fila).join('')
    : '<div class="empty">Ningún SP coincide con el filtro.</div>';
  document.querySelectorAll('.sc').forEach(el=>{
    el.querySelector('.sch').onclick = ()=>{
      abierto = (abierto === el.dataset.sp) ? null : el.dataset.sp; pintar();
    };
  });
}

fetch('data/sp-data.json').then(r=>r.json()).then(d=>{
  TODO = d.sps; VIS = d.sps;
  const dbs = [...new Set(d.sps.map(s=>s.db).filter(Boolean))].sort();
  $('#f-db').innerHTML += dbs.map(x=>`<option value="${esc(x)}">${esc(x)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/sp-data.json</code>. '+
    'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = filtrar;
$('#f-db').onchange = filtrar;
document.querySelectorAll('.chip[data-c]').forEach(c=>{
  c.onclick = ()=>{ c.classList.toggle('on');
    const v = c.dataset.c; crits.has(v) ? crits.delete(v) : crits.add(v); filtrar(); };
});
$('#c-man').onclick = function(){ this.classList.toggle('on'); soloManual = !soloManual; filtrar(); };
"""


def main():
    curado = json.loads(CURADO.read_text(encoding="utf-8"))
    con = sqlite3.connect(canon.DB)
    filas = construir(con, curado)
    con.close()

    bases = curado["bases"]
    olas = curado["olas"]
    escribir_datos(filas, olas, bases)

    por_db = Counter(f["db"] for f in filas)
    nombres = {f["sp"] for f in filas}
    detectados = {f["sp"] for f in filas if f["detectado"]}
    criticos = len({f["sp"] for f in filas if f["criticidad"] == "CRÍTICO"})
    msas = len({c for f in filas for c in f["consumidores"]})

    metricas = "".join([
        canon.sb(len(nombres), "SPs confirmados"),
        canon.sb(len(filas), "Pares base y SP", azul=True),
        canon.sb(len(nombres) - len(detectados), "Verificados a mano", azul=True),
        canon.sb(len(por_db), "Bases de datos"),
        canon.sb(criticos, "Críticos"),
    ])
    leyenda = "".join(canon.item_leyenda(db, n)
                      for db, n in por_db.most_common())

    tarjetas_db = "".join(
        f'<div class="dbc"><div class="dbn">{html.escape(db)}</div>'
        f'<div class="dbd">{html.escape(bases.get(db, "Base Informix del canal"))}</div>'
        f'<div class="dbm">SPs: <b>{n}</b> — '
        + ", ".join(html.escape(f["sp"]) for f in filas if f["db"] == db)
        + '</div></div>'
        for db, n in por_db.most_common())

    bloques_ola = "".join(
        f'<div class="ola"><div class="olah">'
        f'<div class="olan {o["tono"]}">{html.escape(o["clave"])}</div>'
        f'<div class="olat"><h3>{html.escape(o["titulo"])}</h3>'
        f'<div class="olas">{html.escape(o["sub"])}</div></div></div>'
        f'<div class="chips">'
        + "".join(f'<span class="spchip">{html.escape(s)}</span>' for s in o["sps"])
        + '</div><div class="chips">'
        + "".join(f'<span class="spchip">{html.escape(d)}</span>' for d in o["dbs"])
        + f'</div><div class="olar"><b>Hallazgo:</b> {o["hallazgo"]}</div></div>'
        for o in olas)

    cuerpo = f"""
  <div class="bar">
    <input type="search" id="q" placeholder="Buscar por nombre de SP, función, evidencia o microservicio…">
    <select id="f-db"><option value="">Toda base de datos</option></select>
    <span class="chip" data-c="CRÍTICO">Crítico</span>
    <span class="chip" data-c="ALTO">Alto</span>
    <span class="chip" data-c="MEDIO">Medio</span>
    <span class="chip" id="c-man">Verificados a mano</span>
    <a class="dl" href="data/sp-dependencies.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando el inventario…</div>
  <div id="list"></div>

  <div class="sec">
    <h2>{len(por_db)} bases de datos en alcance</h2>
    <p class="sd">Cada base agrupa los procedimientos que el canal invoca sobre ella. La descripción
      es conocimiento curado del equipo; el reparto de SPs sale del brain.</p>
    <div class="dbgrid">{tarjetas_db}</div>
  </div>

  <div class="sec">
    <h2>Dominios funcionales y sus hallazgos</h2>
    <p class="sd">Los procedimientos agrupados por la capacidad de negocio que sostienen, con lo que
      la ingeniería inversa encontró en cada grupo.</p>
    {bloques_ola}
  </div>"""

    intro = (f"El puente JDBC entre el canal móvil y el core bancario en Informix. "
             f"<b>{len(nombres)}</b> procedimientos confirmados en código: <b>{len(detectados)}</b> los detecta "
             f"el análisis estático del brain y <b>{len(nombres) - len(detectados)}</b> están verificados a mano, "
             f"porque su nombre viaja sin prefijo de base y su microservicio declara más de un datasource. "
             f"Clic en cualquiera para ver su evidencia y quién lo consume.")

    salida = canon.pagina(
        titulo="AppMovil · Dependencias de Stored Procedures",
        vista="DEPENDENCIAS SP · PUENTE JDBC",
        kick="DT-SP-Dependencies · Gemelo Cognitivo",
        h1=f"{len(nombres)} Stored Procedures<br>entre el canal y el core",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="rules-appmovil.html" class="back">Reglas</a>'
                '<a href="vocabulario.html" class="back">Vocabulario</a>',
        cuerpo=cuerpo,
        pie=("APPMOVIL · SPE-AM-001 · Inventario generado por <code>build-sp-portal.py</code> "
             "cruzando <code>brain.db</code> con <code>knowledge-base/sp-curado.json</code>.<br>"
             "La función, la criticidad y los hallazgos por dominio son conocimiento curado; "
             "el reparto por base y los consumidores salen del análisis del código."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"SPs            : {len(nombres)} nombres en {len(filas)} pares base-SP "
          f"({len(detectados)} del brain, {len(nombres)-len(detectados)} verificados a mano)")
    print(f"bases          : {len(por_db)}  {dict(por_db)}")
    print(f"olas curadas   : {len(olas)}")
    print(f"JSON : {SALIDA_JSON}")
    print(f"HTML : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

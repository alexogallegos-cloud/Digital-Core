#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-incidents-portal.py — Incidentes originados por Controles de Cambio.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

Lee `brain.db::incidents`, que carga load-incidents.py desde los dos reportes
corporativos de `source/docs/`. La vista separa lo que toca al canal móvil de
lo que ocurrió en otros servicios, porque el corpus es de todo BanCoppel y la
mitad de los incidentes no son de App.

Escribe:
  portal/data/incidents-data.json
  portal/data/incidentes-cc.csv
  portal/incidentes-cc.html
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

SALIDA_HTML = canon.PORTAL / "incidentes-cc.html"
SALIDA_JSON = canon.DATA / "incidents-data.json"
SALIDA_CSV = canon.DATA / "incidentes-cc.csv"

# Los mecanismos de falla que los propios reportes enumeran, con la lectura que
# cada uno deja para la modernización del canal.
PATRONES = {
    "configuracion": (
        "Configuración y sintaxis",
        "Saltos de línea al codificar en base64, selectores escritos a mano en lugar "
        "de la variable de secreto, y propiedades mal formadas en ConfigMaps. Es el "
        "mecanismo más frecuente y el más automatizable."),
    "cuota_openshift": (
        "Cuota de pods en OpenShift",
        "Ventanas que no validaron el límite de recursos del clúster antes de ejecutar. "
        "El despliegue se bloquea y hay que levantar la restricción en vivo."),
    "cambio_estructural_bd": (
        "Cambio estructural de base de datos",
        "Modificaciones de esquema cuyo costo de consulta no se midió contra el volumen "
        "real de producción. La degradación aparece del lado del canal, no del de la base."),
    "feature_flag": (
        "Bandera activada en caliente",
        "Parámetros encendidos en producción sin prueba de estrés previa. La contención "
        "exige diques de tráfico hasta poder apagarlos."),
    "actualizacion_so": (
        "Actualización de sistema operativo",
        "Afectación posterior a la implementación, resuelta revirtiendo la actualización."),
    "reinicio_rollback": (
        "Reinicio o rollback con dependencias no previstas",
        "Reinicios programados que activan defectos latentes, o rollbacks que no "
        "contemplaron todas las dependencias del servicio."),
    "sin_clasificar": (
        "Sin mecanismo declarado",
        "El reporte registra el síntoma (códigos de rechazo, bloqueos) y la clasificación "
        "de causa, pero no el mecanismo técnico. No se infiere aquí."),
}

CSS_EXTRA = r"""
.ic{border:1px solid rgba(255,255,255,.07);border-left-width:3px;border-radius:13px;background:rgba(255,255,255,.028);
 margin-bottom:9px;transition:.18s}
.ic:hover{background:rgba(255,255,255,.055)}
.ic.app{border-left-color:#ffd43b}.ic.otro{border-left-color:rgba(255,255,255,.14)}
.ich{display:flex;gap:14px;align-items:center;padding:14px 18px;cursor:pointer}
.icf{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11.5px;color:var(--muted2);min-width:92px;flex-shrink:0}
.ica{font-size:12.5px;color:#e9edff;min-width:210px;flex-shrink:0;font-weight:600}
.ict{flex:1;font-size:13px;line-height:1.5;color:var(--muted)}
.icd{padding:0 18px 16px;display:none}
.ic.open .icd{display:block}
.tag.app{background:rgba(255,212,59,.14);color:#ffd43b}
.tag.pat{background:rgba(116,192,252,.14);color:#74c0fc}
.tag.cc{background:rgba(140,233,154,.14);color:#8ce99a}
.tag.sincc{background:rgba(255,255,255,.07);color:var(--muted2)}
.sec{margin:46px 0 0}
.sec h2{font-size:clamp(20px,2.6vw,27px);font-weight:900;letter-spacing:-.025em;margin-bottom:8px}
.sec p.sd{color:var(--muted);font-size:13.5px;line-height:1.7;max-width:84ch;margin-bottom:20px}
.pgrid{display:grid;grid-template-columns:repeat(auto-fit,minmax(310px,1fr));gap:13px}
.pc{background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.08);border-radius:15px;padding:18px 20px}
.pcn{display:flex;align-items:baseline;gap:10px;margin-bottom:9px}
.pcn h3{font-size:15px;font-weight:800;letter-spacing:-.015em}
.pcn span{font-size:20px;font-weight:900;color:var(--yellow);font-variant-numeric:tabular-nums}
.pcd{font-size:12.5px;color:var(--muted);line-height:1.65}
.fuentes{font-size:12px;color:var(--muted2);line-height:1.9;margin-top:14px}
.fuentes code{font-family:'SF Mono',ui-monospace,monospace;font-size:11px;color:#c9d3f5}
"""

JS = r"""
let TODO = [], VIS = [], abierto = null;
let pats = new Set(), soloApp = false, soloCC = false;
const $ = s => document.querySelector(s);
const esc = s => (s||'').replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));
const PAT = __PATLABELS__;

function fila(i){
  const ab = i.id === abierto;
  const folios = i.incidentes ? i.incidentes.split(',').join(', ') : 'sin folio';
  return `<div class="ic ${i.afecta_appmovil?'app':'otro'} ${ab?'open':''}" data-id="${esc(i.id)}">
    <div class="ich">
      <span class="icf">${esc(i.fecha)}</span>
      <span class="ica">${esc(i.aplicacion)}</span>
      <span class="ict">${esc(i.afectacion_canal || i.afectacion)}</span>
      <span class="tags">
        ${i.afecta_appmovil?'<span class="tag app">App</span>':''}
        <span class="tag pat">${esc(PAT[i.patron]||i.patron)}</span>
        ${i.ccs?`<span class="tag cc">CC ${esc(i.ccs)}</span>`:'<span class="tag sincc">CC no visible</span>'}
      </span>
    </div>
    <div class="icd">
      <div class="ev">
        <div class="evk">Afectación registrada</div>
        <div class="evv">${esc(i.afectacion)}</div>
        <div class="evm">
          <span>Folios <b>${esc(folios)}</b></span>
          <span>Servicios <b>${esc(i.servicios||i.aplicacion)}</b></span>
          <span>Evidencia <b>${esc(i.nivel_evidencia)}</b></span>
          <span>Reporte <b>${i.en_reporte_canal?'consolidado y de canal':'consolidado'}</b></span>
        </div>
      </div>
      ${i.cronologia?`<div class="ev"><div class="evk">Cronología documentada</div>
        <div class="evv">${esc(i.cronologia)}</div></div>`:''}
    </div>
  </div>`;
}

function filtrar(){
  const q = $('#q').value.trim().toLowerCase();
  const pat = $('#f-pat').value;
  VIS = TODO.filter(i=>{
    if (soloApp && !i.afecta_appmovil) return false;
    if (soloCC && !i.ccs) return false;
    if (pat && i.patron !== pat) return false;
    if (!q) return true;
    return (i.fecha+' '+i.aplicacion+' '+i.afectacion+' '+(i.cronologia||'')+' '+
            (i.incidentes||'')+' '+(i.ccs||'')).toLowerCase().includes(q);
  });
  pintar();
}

function pintar(){
  $('#count').innerHTML = '<b>'+VIS.length+'</b> incidentes'+
    (VIS.length!==TODO.length ? ' de '+TODO.length : '');
  $('#list').innerHTML = VIS.length ? VIS.map(fila).join('')
    : '<div class="empty">Ningún incidente coincide con el filtro.</div>';
  document.querySelectorAll('.ic').forEach(el=>{
    el.querySelector('.ich').onclick = ()=>{
      abierto = (abierto === el.dataset.id) ? null : el.dataset.id; pintar();
    };
  });
}

fetch('data/incidents-data.json').then(r=>r.json()).then(d=>{
  TODO = d; VIS = d; pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/incidents-data.json</code>. '+
    'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = filtrar;
$('#f-pat').onchange = filtrar;
$('#c-app').onclick = function(){ this.classList.toggle('on'); soloApp = !soloApp; filtrar(); };
$('#c-cc').onclick  = function(){ this.classList.toggle('on'); soloCC = !soloCC; filtrar(); };
"""


def main():
    con = sqlite3.connect(canon.DB)
    con.row_factory = sqlite3.Row
    try:
        filas = [dict(r) for r in con.execute(
            "SELECT * FROM incidents ORDER BY fecha, aplicacion")]
    except sqlite3.OperationalError:
        print("ERROR: no hay tabla incidents. Corre antes load-incidents.py")
        return 1
    con.close()

    if not filas:
        print("ERROR: la tabla incidents está vacía")
        return 1

    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(json.dumps(filas, ensure_ascii=False), encoding="utf-8")
    campos = ["id", "fecha", "incidentes", "ccs", "aplicacion", "patron",
              "afectacion", "nivel_evidencia", "afecta_appmovil", "fuentes"]
    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=campos, delimiter=";", extrasaction="ignore")
        w.writeheader()
        w.writerows(filas)

    app = sum(1 for f in filas if f["afecta_appmovil"])
    con_cc = sum(1 for f in filas if f["ccs"])
    con_cron = sum(1 for f in filas if f["cronologia"])
    por_patron = Counter(f["patron"] for f in filas)

    metricas = "".join([
        canon.sb(len(filas), "Incidentes"),
        canon.sb(app, "Tocan el canal móvil"),
        canon.sb(con_cc, "Con CC identificado", azul=True),
        canon.sb(len(filas) - con_cc, "Sin CC visible", azul=True),
        canon.sb(con_cron, "Con cronología"),
    ])
    leyenda = "".join(canon.item_leyenda(PATRONES[p][0], n)
                      for p, n in por_patron.most_common() if p in PATRONES)

    opciones = "".join(
        f'<option value="{p}">{html.escape(PATRONES[p][0])}</option>'
        for p, _ in por_patron.most_common() if p in PATRONES)

    tarjetas = "".join(
        f'<div class="pc"><div class="pcn"><span>{por_patron[p]}</span>'
        f'<h3>{html.escape(PATRONES[p][0])}</h3></div>'
        f'<div class="pcd">{html.escape(PATRONES[p][1])}</div></div>'
        for p, _ in por_patron.most_common() if p in PATRONES)

    cuerpo = f"""
  <div class="bar">
    <input type="search" id="q" placeholder="Buscar por fecha, servicio, folio, CC o descripción…">
    <select id="f-pat"><option value="">Todo mecanismo</option>{opciones}</select>
    <span class="chip" id="c-app">Solo el canal móvil</span>
    <span class="chip" id="c-cc">Con CC identificado</span>
    <a class="dl" href="data/incidentes-cc.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando los incidentes…</div>
  <div id="list"></div>

  <div class="sec">
    <h2>Mecanismos de falla</h2>
    <p class="sd">Los patrones que los propios reportes identifican en su sección de causas,
      con el número de incidentes que cada uno explica.</p>
    <div class="pgrid">{tarjetas}</div>
  </div>

  <div class="sec">
    <h2>Procedencia</h2>
    <p class="sd">Los dos reportes corporativos que alimentan esta vista, y lo que cada uno aporta.</p>
    <div class="pgrid">
      <div class="pc"><div class="pcn"><span>{len(filas)}</span><h3>Reporte consolidado</h3></div>
        <div class="pcd"><code>Reporte_Incidentes_originados_por_CC_2026.docx</code><br>
          Enero al 2 de noviembre de 2026, todo BanCoppel: canal móvil, Cardif, Remesas Appriza,
          cajeros propios, eGlobal, base OLTP y servicios transversales.</div></div>
      <div class="pc"><div class="pcn"><span>{sum(1 for f in filas if f['en_reporte_canal'])}</span>
        <h3>Reporte del canal</h3></div>
        <div class="pcd"><code>Reporte_Incidentes_CC_App_BanCoppel.docx</code><br>
          Mayo a noviembre de 2026, acotado a App BanCoppel. Aporta la redacción operativa
          de la afectación y la cronología de cada caso.</div></div>
    </div>
    <div class="fuentes">
      Ambos reportes se construyeron sobre <code>202606_VRO_Track Incidentes_Mayores_v2.xlsx</code>,
      los RCA de los casos (separación de tablas de movimientos, cajeros propios, eGlobal,
      incidente 3997149), los comités operativos AMS-IMS de septiembre y octubre, y las bitácoras
      de Command Center.
    </div>
  </div>"""

    intro = (f"Los incidentes cuya causa documentada fue un Control de Cambios, una liberación "
             f"fallida o un rollback. <b>{len(filas)}</b> casos entre enero y el 2 de noviembre de 2026, "
             f"de los que <b>{app}</b> tocan el canal móvil. En <b>{len(filas) - con_cc}</b> la evidencia "
             f"registra la causalidad pero el folio del CC no quedó visible, y eso se muestra tal cual: "
             f"no se infiere. Clic en cualquiera para ver su cronología.")

    salida = canon.pagina(
        titulo="AppMovil · Incidentes por Control de Cambios",
        vista="INCIDENTES POR CONTROL DE CAMBIOS",
        kick="DT-Riesgos · Evidencia operativa",
        h1=f"{len(filas)} incidentes originados<br>por Controles de Cambio",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="rules-appmovil.html" class="back">Reglas</a>'
                '<a href="sp-dependencies.html" class="back">Dependencias SP</a>',
        cuerpo=cuerpo,
        pie=("APPMOVIL · SPE-AM-001 · Vista generada por <code>build-incidents-portal.py</code> "
             "desde <code>brain.db::incidents</code>.<br>"
             "Los incidentes se normalizan con <code>extract-incidents.py</code> desde los dos "
             "reportes corporativos de <code>source/docs/</code> y se cargan con "
             "<code>load-incidents.py</code>."),
        script=JS.replace("__PATLABELS__", json.dumps(
            {k: v[0] for k, v in PATRONES.items()}, ensure_ascii=False)),
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"incidentes      : {len(filas)}  ({app} tocan el canal móvil)")
    print(f"  con CC visible: {con_cc}   con cronología: {con_cron}")
    print(f"  por mecanismo : {dict(por_patron)}")
    print(f"HTML : {SALIDA_HTML}  ({len(salida):,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

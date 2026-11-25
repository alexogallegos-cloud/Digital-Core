#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-views-portal.py — Las pantallas de ventanilla de SIWEB.

Sigue el canon del portal Informix. El chrome vive en `_canon.py`.

Cada archivo FXML es una pantalla del cliente JavaFX que usa el cajero. La ruta
dentro de `CPlaSuFX/resources/view` codifica el área funcional, así que el mapa
de pantallas es también el mapa de lo que la sucursal puede hacer.

Escribe:
  portal/data/pantallas-siweb.json
  portal/data/pantallas-siweb.csv
  portal/pantallas-siweb.html
"""
import csv
import importlib.util
import json
import re
import sqlite3
import sys
from collections import Counter
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "_canon", Path(__file__).resolve().parent / "_canon.py")
canon = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(canon)

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SALIDA_HTML = canon.PORTAL / "pantallas-siweb.html"
SALIDA_JSON = canon.DATA / "pantallas-siweb.json"
SALIDA_CSV = canon.DATA / "pantallas-siweb.csv"

# Nombre legible de cada área. Lo que no esté aquí se muestra tal cual sale de
# la ruta, que es preferible a inventarle un nombre.
AREAS = {
    "mantoservicios": "Mantenimiento de servicios al cliente",
    "altaunica": "Alta única de clientes y productos",
    "consulta": "Consultas de cliente, cuenta y expediente",
    "genericos": "Componentes genéricos de la interfaz",
    "servicios": "Servicios de banca en ventanilla",
    "procesosEspeciales": "Procesos especiales y reversos",
    "oficina": "Operación de oficina y sucursal",
    "admin": "Administración y parámetros",
    "procesosAtm": "Procesos de cajero automático",
    "mantenimiento": "Mantenimientos de catálogo",
    "procesosFinDia": "Procesos de fin de día",
    "cuenta": "Cuentas de captación",
    "prospecto": "Prospectación",
    "digitalizacion": "Digitalización de expediente",
    "login": "Acceso y autenticación",
    "caja": "Caja, depósitos y retiros",
    "tarjetas": "Tarjetas",
    "security": "Seguridad",
    "reportes": "Reportes",
}


def camel_a_prosa(nombre: str) -> str:
    """AltaCuentaView se lee mejor como 'Alta cuenta view' que como nada."""
    texto = re.sub(r'(?<!^)(?=[A-Z])', ' ', nombre).replace("_", " ").strip()
    return texto[:1].upper() + texto[1:] if texto else nombre


def datos(con):
    filas = []
    for nombre, area, ruta, modulo in con.execute(
            "SELECT name, area, path, module FROM views ORDER BY area, name"):
        filas.append({
            "nombre": nombre,
            "legible": camel_a_prosa(nombre),
            "area": area,
            "area_legible": AREAS.get(area, camel_a_prosa(area)),
            "ruta": ruta,
            "modulo": modulo,
            "carpeta": "/".join(ruta.split("/")[:-1]),
        })
    return filas


CSS_EXTRA = r"""
.nota{background:rgba(240,210,36,.06);border:1px solid rgba(240,210,36,.18);border-radius:13px;
 padding:14px 18px;font-size:12.5px;color:#f1e9c8;line-height:1.7;margin:16px 0 4px}
.nota b{color:#fff;font-weight:600}
.sec{margin:30px 0 0}
.sech{display:flex;align-items:baseline;gap:13px;margin:0 0 15px;padding-bottom:11px;
 border-bottom:1px solid rgba(255,255,255,.07)}
.sech h2{font-size:19px;font-weight:800;letter-spacing:-.02em}
.sech span{font-size:12.5px;color:var(--muted2)}
.pgrid{display:grid;grid-template-columns:repeat(auto-fill,minmax(268px,1fr));gap:9px}
.pc{background:rgba(255,255,255,.028);border:1px solid rgba(255,255,255,.07);
 border-left:3px solid var(--blue);border-radius:12px;padding:13px 16px;transition:.18s}
.pc:hover{background:rgba(255,255,255,.055)}
.pc .pn{font-size:13.5px;font-weight:700;color:#e9edff;line-height:1.4}
.pc .pf{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:10.5px;color:var(--muted2);
 margin-top:7px;word-break:break-all;line-height:1.5}
"""

JS = r"""
let V = [], AR = [];
const $ = s => document.querySelector(s);
const esc = s => (s==null?'':String(s)).replace(/[&<>"]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

function pintar(){
  const q = $('#q').value.trim().toLowerCase();
  const area = $('#f-area').value;
  let n = 0;
  const bloques = AR.map(a=>{
    if (area && a.id !== area) return '';
    const vs = V.filter(v=>{
      if (v.area !== a.id) return false;
      if (!q) return true;
      return (v.nombre+' '+v.legible+' '+v.ruta).toLowerCase().includes(q);
    });
    if (!vs.length) return '';
    n += vs.length;
    return `<div class="sec"><div class="sech"><h2>${esc(a.titulo)}</h2>
      <span>${vs.length} pantalla${vs.length===1?'':'s'}</span></div>
      <div class="pgrid">${vs.map(v=>`<div class="pc">
        <div class="pn">${esc(v.legible)}</div>
        <div class="pf">${esc(v.carpeta)}</div></div>`).join('')}</div></div>`;
  }).join('');
  $('#count').innerHTML = `<b>${n}</b> pantallas` + (n!==V.length ? ` de ${V.length}` : '');
  $('#list').innerHTML = bloques || '<div class="empty">Ninguna pantalla coincide con la búsqueda.</div>';
}

fetch('data/pantallas-siweb.json').then(r=>r.json()).then(d=>{
  V = d.pantallas; AR = d.areas;
  $('#f-area').innerHTML += AR.map(a=>`<option value="${esc(a.id)}">${esc(a.titulo)}</option>`).join('');
  pintar();
}).catch(()=>{
  $('#count').innerHTML = 'No se pudo cargar <code>data/pantallas-siweb.json</code>. '
    + 'Esta página necesita servirse por HTTP, no abrirse como archivo local.';
});

$('#q').oninput = pintar;
$('#f-area').onchange = pintar;
"""


def main():
    con = sqlite3.connect(canon.DB)
    pantallas = datos(con)
    con.close()

    por_area = Counter(v["area"] for v in pantallas)
    areas = [{"id": a, "titulo": AREAS.get(a, camel_a_prosa(a)), "n": n}
             for a, n in por_area.most_common()]

    canon.DATA.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.write_text(
        json.dumps({"pantallas": pantallas, "areas": areas}, ensure_ascii=False),
        encoding="utf-8")

    with open(SALIDA_CSV, "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.writer(fh, delimiter=";")
        w.writerow(["pantalla", "nombre_legible", "area", "area_legible", "ruta"])
        for v in pantallas:
            w.writerow([v["nombre"], v["legible"], v["area"], v["area_legible"], v["ruta"]])

    sin_nombre = sum(1 for a in areas if a["id"] not in AREAS)

    metricas = "".join([
        canon.sb(len(pantallas), "Pantallas FXML"),
        canon.sb(len(areas), "Áreas funcionales", azul=True),
        canon.sb(por_area.most_common(1)[0][1], "La mayor área"),
        canon.sb(len({v["carpeta"] for v in pantallas}), "Carpetas de vista", azul=True),
    ])
    leyenda = "".join(canon.item_leyenda(a["titulo"], a["n"]) for a in areas[:8])

    cuerpo = f"""
  <div class="nota">
    El cliente de ventanilla es una aplicación de escritorio <b>JavaFX</b>, repartida a las
    sucursales por Java Web Start, no una aplicación Angular como dice el inventario As-Is. Cada
    archivo FXML del módulo <code>CPlaSuFX</code> es una pantalla real de caja, así que este mapa
    de <b>{len(pantallas)}</b> pantallas en <b>{len(areas)}</b> áreas es también el mapa de lo que
    una sucursal puede hacer hoy.
  </div>

  <div class="bar">
    <input type="search" id="q" placeholder="Buscar pantalla o ruta…">
    <select id="f-area"><option value="">Toda área</option></select>
    <a class="dl" href="data/pantallas-siweb.csv" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando las pantallas…</div>
  <div id="list"></div>"""

    intro = (f"La superficie de operación del cajero. <b>{len(pantallas)}</b> pantallas FXML "
             f"agrupadas en <b>{len(areas)}</b> áreas funcionales, desde alta única de clientes "
             f"hasta procesos de fin de día. El nombre legible se deriva del nombre del archivo, "
             f"así que sirve para navegar pero no sustituye la validación funcional con el equipo "
             f"de sucursales.")

    salida = canon.pagina(
        titulo="SIWEB · Pantallas de Ventanilla",
        vista="PANTALLAS DE VENTANILLA",
        kick="Gemelo Cognitivo del canal de sucursal",
        h1=f"{len(pantallas)} pantallas<br>en {len(areas)} áreas funcionales",
        intro=intro,
        metricas=metricas,
        leyenda=leyenda,
        enlaces='<a href="core-siweb.html" class="back">Puente al core</a>'
                '<a href="endpoints-siweb.html" class="back">Endpoints</a>',
        cuerpo=cuerpo,
        pie=("SIWEB, canal de sucursal, ventanilla y caja. Vista generada por "
             "<code>build-views-portal.py</code> con datos de <code>brain.db</code>.<br>"
             f"Quedan {sin_nombre} áreas sin nombre legible en el generador: se muestran con el "
             "nombre que trae la ruta hasta que el equipo las bautice."),
        script=JS,
        css_extra=CSS_EXTRA,
    )
    SALIDA_HTML.write_text(salida, encoding="utf-8", newline="\n")

    print(f"pantallas : {len(pantallas)} en {len(areas)} áreas ({sin_nombre} sin nombre legible)")
    print(f"HTML      : {SALIDA_HTML}  ({len(salida):,} bytes)")


if __name__ == "__main__":
    main()

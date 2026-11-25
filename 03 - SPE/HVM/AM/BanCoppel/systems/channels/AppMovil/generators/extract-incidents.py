#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-incidents.py — Incidentes originados por Controles de Cambio.

Lee los dos reportes corporativos de `source/docs/` y los normaliza a
`knowledge-base/incidentes-cc.json`, que a partir de ahí es la fuente:

  Reporte_Incidentes_originados_por_CC_2026.docx   consolidado de todo BanCoppel,
                                                   enero a 2-nov-2026, 15 incidentes
  Reporte_Incidentes_CC_App_BanCoppel.docx         acotado a App BanCoppel,
                                                   mayo a noviembre, 6 incidentes

El acotado es un subconjunto del consolidado, con la redacción de la afectación
algo distinta. Se fusionan por la llave natural (fecha, id de incidente, id de
CC) y se marca cuáles aparecen en el reporte específico del canal.

No se teclea nada: si los documentos se actualizan, se vuelve a correr.

Uso:
  python generators/extract-incidents.py
"""
import json
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DOCS = BASE / "source" / "docs"
SALIDA = BASE / "knowledge-base" / "incidentes-cc.json"

CONSOLIDADO = "Reporte_Incidentes_originados_por_CC_2026.docx"
CANAL = "Reporte_Incidentes_CC_App_BanCoppel.docx"

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"

MESES = {"ene": "01", "feb": "02", "mar": "03", "abr": "04", "may": "05", "jun": "06",
         "jul": "07", "ago": "08", "sep": "09", "oct": "10", "nov": "11", "dic": "12"}

# Los patrones de causa que los propios reportes enumeran en su sección 4.
# El orden importa: se asigna el primero que coincide.
PATRONES = [
    ("configuracion", r"configmap|secreto|base64|sintaxis|properties|configuraci[óo]n"),
    ("cuota_openshift", r"cuota|openshift|pods?\b"),
    ("feature_flag", r"flag|bandera"),
    ("cambio_estructural_bd", r"estructural|tabla de movimientos|consultas"),
    ("pruebas_desempeno", r"desempe[ñn]o|volumen|preproduct"),
    ("actualizacion_so", r"actualizaci[óo]n de (?:so|sistema operativo)"),
    ("reinicio_rollback", r"reinicio|rollback|zombie|broker"),
]


def _texto(p):
    return "".join(t.text or "" for t in p.iter(f"{W}t"))


def documento(nombre):
    ruta = DOCS / nombre
    if not ruta.exists():
        raise SystemExit(f"ERROR: no se encontró {ruta}")
    return ET.fromstring(zipfile.ZipFile(ruta).read("word/document.xml"))


def concentrado(root):
    """La tabla de 6 columnas con el concentrado de incidentes."""
    for tbl in root.iter(f"{W}tbl"):
        filas = []
        for tr in tbl.findall(f"{W}tr"):
            filas.append([" ".join(_texto(p).strip() for p in tc.findall(f"{W}p")).strip()
                          for tc in tr.findall(f"{W}tc")])
        if len(filas) > 3 and len(filas[0]) == 6 and "Fecha" in filas[0][0]:
            return filas[1:]
    return []


def narrativas(root):
    """
    Los párrafos de la sección 3, donde cada caso trae su cronología.

    Se indexan por los identificadores que mencionan (CC o incidente), que es
    como se amarran a la fila del concentrado.
    """
    textos = [_texto(p).strip() for p in root.iter(f"{W}p")]
    textos = [t for t in textos if len(t) > 80]
    por_id = {}
    for t in textos:
        nums = set(re.findall(r"\b(\d{6,7})\b", t))
        # Un parrafo que cita tres o mas folios no narra un caso: es la lista
        # de fuentes de la seccion 7. Si se deja, se pega a cada incidente
        # cuyo folio menciona y ensucia la cronologia de todos.
        if len(nums) > 2:
            continue
        for num in nums:
            por_id.setdefault(num, [])
            if t not in por_id[num]:
                por_id[num].append(t)
    return por_id


def iso(fecha):
    m = re.match(r"(\d{1,2})-([a-z]{3})-(\d{4})", fecha.strip(), re.I)
    if not m:
        return fecha.strip()
    d, mes, a = m.groups()
    return f"{a}-{MESES.get(mes.lower(), '01')}-{int(d):02d}"


def ids(celda):
    """'4062561 / 3925637' -> ['4062561','3925637'];  'N/D' -> []"""
    if not celda or celda.strip().upper() in ("N/D", "ND", "-"):
        return []
    return [x.strip(" *") for x in re.split(r"[/,]", celda) if x.strip(" *")]


def patron_de(texto):
    bajo = texto.lower()
    for nombre, rx in PATRONES:
        if re.search(rx, bajo):
            return nombre
    return "sin_clasificar"


def normaliza(fila, fuente):
    fecha, inc, cc, app, afect, evid = (c.strip() for c in fila[:6])
    return {
        "fecha": iso(fecha),
        "incidentes": ids(inc),
        "ccs": ids(cc),
        "servicios": [s.strip() for s in app.split("/") if s.strip()],
        "aplicacion": app,
        "afectacion": afect,
        "nivel_evidencia": evid.rstrip("."),
        "patron": patron_de(afect),
        "afecta_appmovil": bool(re.search(r"app\b|app banco?ppel|one click|ppc|tdc",
                                          app, re.I)),
        "fuentes": [fuente],
        "cronologia": "",
    }


def llave(r):
    """
    Llave natural del incidente.

    Cuando no hay folio ni CC la fecha no basta: el 14-ene-2026 hay dos
    incidentes distintos sin folio, y con la fecha sola uno pisaba al otro.
    En ese caso entra la aplicación afectada para desempatar.
    """
    base = (r["fecha"], tuple(r["incidentes"]), tuple(r["ccs"]))
    if not r["incidentes"] and not r["ccs"]:
        return base + (r["aplicacion"],)
    return base


def main():
    rc = documento(CONSOLIDADO)
    rcan = documento(CANAL)

    registros = {}
    for fila in concentrado(rc):
        r = normaliza(fila, CONSOLIDADO)
        registros[llave(r)] = r

    solo_canal = 0
    for fila in concentrado(rcan):
        r = normaliza(fila, CANAL)
        k = llave(r)
        if k in registros:
            registros[k]["fuentes"].append(CANAL)
            registros[k]["en_reporte_canal"] = True
            # El reporte del canal describe la afectación con más detalle operativo
            if len(r["afectacion"]) > len(registros[k]["afectacion"]):
                registros[k]["afectacion_canal"] = r["afectacion"]
        else:
            r["en_reporte_canal"] = True
            registros[k] = r
            solo_canal += 1

    # La cronología de la sección 3 se amarra por los identificadores citados
    narr = {}
    for root in (rc, rcan):
        for num, textos in narrativas(root).items():
            narr.setdefault(num, [])
            for t in textos:
                if t not in narr[num]:
                    narr[num].append(t)

    for r in registros.values():
        trozos = []
        for num in r["incidentes"] + r["ccs"]:
            for t in narr.get(num, []):
                if t not in trozos:
                    trozos.append(t)
        r["cronologia"] = " ".join(trozos)
        r.setdefault("en_reporte_canal", False)

    filas = sorted(registros.values(), key=lambda x: (x["fecha"], x["aplicacion"]))

    meta = {
        "generado_por": "generators/extract-incidents.py",
        "documentos": [CONSOLIDADO, CANAL],
        "periodo": "2026-01-14 a 2026-10-22",
        "total": len(filas),
        "de_appmovil": sum(1 for r in filas if r["afecta_appmovil"]),
        "en_reporte_canal": sum(1 for r in filas if r["en_reporte_canal"]),
        "con_cronologia": sum(1 for r in filas if r["cronologia"]),
    }
    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    SALIDA.write_text(json.dumps({"meta": meta, "incidentes": filas},
                                 ensure_ascii=False, indent=2), encoding="utf-8")

    print(f"incidentes normalizados : {meta['total']}")
    print(f"  que tocan AppMovil    : {meta['de_appmovil']}")
    print(f"  en el reporte de canal: {meta['en_reporte_canal']}  (solo en él: {solo_canal})")
    print(f"  con cronología        : {meta['con_cronologia']}")
    from collections import Counter
    print(f"  por patrón            : {dict(Counter(r['patron'] for r in filas))}")
    print(f"JSON : {SALIDA}")


if __name__ == "__main__":
    main()

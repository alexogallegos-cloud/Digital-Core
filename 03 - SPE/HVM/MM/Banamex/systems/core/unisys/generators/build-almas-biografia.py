#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-almas-biografia.py — Extrae del corpus fuente las dos dimensiones que el
portal no cubria: QUIEN escribio el codigo y CUANDO mutO.

  Almas      autoria declarada (division AUTHOR. de COBOL/ALGOL), resuelta a
             identidades canonicas y clasificada en persona / organizacion /
             credencial. Alimenta bus factor, huella de terceros y codigo huerfano.
  Biografia  entradas de bitacora fechadas en comentarios de cabecera, mas la
             metadata de release de los DASDL. Alimenta la linea de tiempo.

Cadena canonica: fuente -> JSON en knowledge-base/ -> brain.db -> portal.
Este script cubre los dos primeros saltos y la carga; el portal lo rinde
generators/build-portal.py desde brain.db. Es idempotente: reescribe sus
propias tablas en cada corrida y no toca ninguna otra.

NOTA DE PRIVACIDAD: brain.db guarda los nombres reales porque la resolucion de
identidad y el bus factor los necesitan. El showcase sanitizado los seudonimiza
(build-sanitized.py los lee de la tabla autores, no de una lista fija).

USO:
    PYTHONUTF8=1 python generators/build-almas-biografia.py
    PYTHONUTF8=1 python generators/build-almas-biografia.py --dry-run
"""

from __future__ import annotations

import json
import re
import sqlite3
import sys
import unicodedata
from collections import defaultdict
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

BASE = Path(__file__).resolve().parent.parent
SRC = BASE / "source"
DB = BASE / "digital-brain" / "brain.db"
KB = BASE / "knowledge-base" / "almas"

CORPUS = [("S151", SRC / "S151"), ("S500", SRC / "S500" / "extracted_source")]

# ── corpus ───────────────────────────────────────────────────────────────────

# El sufijo descriptivo va tras guion bajo (P629_CARGABD06): \b no sirve de corte
# porque el guion bajo es caracter de palabra.
RE_PROG = re.compile(r"(?:^|_)(P\d{3}|L\d{3}[A-Z0-9]*?)(?=_|$)", re.I)


LENGUAJES = ("COBOL", "ALGOL", "DASDL", "WFL")


def pieza(path: Path, sistema: str) -> tuple[str, str]:
    """Devuelve (programa, lenguaje) a partir del nombre de archivo."""
    nom = path.stem.strip()
    up = nom.upper()
    leng = next((l for l in LENGUAJES if l in up), "FUENTE")
    m = RE_PROG.search(nom)
    return (m.group(1).upper() if m else nom), leng


# ── Almas: autoria declarada ─────────────────────────────────────────────────

RE_AUTHOR = re.compile(r"^\d{0,6}\s*AUTHOR\.(.{0,80})", re.M)
# ALGOL y DASDL no tienen division AUTHOR.; cuando hay autor, va en comentario.
RE_AUTOR_CMT = re.compile(
    r"^[%*][^\n]{0,8}\b(?:AUTOR|ELABORO|REALIZO|PROGRAMADOR|HECHO POR)\b\s*:?\s*(.{3,55})",
    re.I | re.M)
RE_COLA = re.compile(r"\s*\d{6}\s*$")
TITULOS = re.compile(r"^(ING\.?|LIC\.?|LSC\.?|C\.?P\.?|SR\.?|SRA\.?)\s+", re.I)
RE_CREDENCIAL = re.compile(r"^[A-Z]{2}\d{5}$")
ORGS = ("FABRICA DE SOFTWARE", "FSW", "INFOWARE", "ISI", "STEFANINI", "BANAMEX",
        "INGENIERIA DE SISTEMAS", "GRUPO DE", "IBM", "ZUMA", "SOLSER")


def limpia_nombre(s: str) -> str:
    s = RE_COLA.sub("", " ".join(s.split())).strip()
    s = s.rstrip(". ").strip()
    s = s.replace("&A", "ÑA").replace("&O", "ÑO")   # EBCDIC: & quedo por Ñ
    s = TITULOS.sub("", s).strip()
    return s


def parte_autores(bruto: str) -> list[str]:
    """Un AUTHOR. puede traer varios: separa por / & , y descarta vacios."""
    piezas = re.split(r"\s*[/&,]\s*", bruto)
    return [limpia_nombre(p) for p in piezas if limpia_nombre(p)]


def clasifica(nombre: str) -> str:
    up = nombre.upper()
    if RE_CREDENCIAL.match(up.replace(" ", "")):
        return "credencial"
    if any(o in up for o in ORGS):
        return "organizacion"
    if len(up.split()) == 1 and len(up) <= 4:
        return "credencial"          # iniciales sueltas: FT, CD, VMLM, MPD
    return "persona"


def tokens_nombre(nombre: str) -> set[str]:
    base = unicodedata.normalize("NFKD", nombre.upper())
    base = "".join(c for c in base if not unicodedata.combining(c))
    return {t for t in re.split(r"[^A-Z]+", base) if len(t) > 1}


def resuelve_identidades(formas: list[str]) -> dict[str, str]:
    """Agrupa variantes del mismo nombre. Una forma corta se funde en una larga
    si sus tokens son subconjunto y comparten al menos dos (evita unir a dos
    personas que solo coinciden en el nombre de pila)."""
    unicas = sorted(set(formas), key=lambda s: (-len(s), s))
    canon: dict[str, str] = {}
    grupos: list[tuple[set[str], str]] = []
    for f in unicas:
        tf = tokens_nombre(f)
        destino = None
        if tf:
            for tg, rep in grupos:
                if (tf <= tg or tg <= tf) and len(tf & tg) >= 2:
                    destino = rep
                    break
        if destino is None:
            grupos.append((tf, f))
            destino = f
        canon[f] = destino
    return canon


# ── Biografia: bitacora fechada ──────────────────────────────────────────────

RE_CMT = re.compile(r"^\d{0,6}\s*[*%](.*?)\s*\d{6,12}\s*$", re.M)
MES = "ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC"
RE_FECHAS = [
    re.compile(r"\b(?P<a>19[89]\d|20[0-2]\d)[/\-](?P<m>\d{1,2})[/\-](?P<d>\d{1,2})\b"),
    re.compile(r"\b(?P<d>\d{1,2})[/\-.](?P<m>\d{1,2})[/\-.](?P<a>19[89]\d|20[0-2]\d)\b"),
    re.compile(r"\b(?P<d>\d{1,2})[/\-.](?P<m>\d{1,2})[/\-.](?P<a>\d{2})\b"),
    re.compile(r"\b(?P<mes>" + MES + r")[A-ZÁÉÍÓÚ]*\s*\.?\s*(?P<d>\d{1,2})[.\-/](?P<a>\d{2,4})\b", re.I),
]
MESES = {m: i + 1 for i, m in enumerate(MES.split("|"))}

# Lo que delata codigo comentado, no bitacora.
RE_CODIGO = re.compile(
    r"\b(PERFORM|MOVE|DISPLAY|PIC|COMPUTE|GO\s+TO|SECTION|EXIT|READ|WRITE|OPEN|CLOSE|"
    r"VALUE|FILLER|OCCURS|REDEFINES|CALL|IF|ELSE|END-IF|FROM|THRU|VARYING|SORT)\b|:=|\"")
RE_INICIALES = re.compile(r"^[*%\s]*([A-Z]{2,5})[\s\-]")
VENDORS = ("IBM", "ZUMA", "STEFANINI", "INFOWARE", "SOLSER", "FSW", "INDRA", "ACCENTURE")


def anio_de(texto: str):
    for rx in RE_FECHAS:
        m = rx.search(texto)
        if not m:
            continue
        g = m.groupdict()
        a = g.get("a") or ""
        if len(a) == 2:
            a = ("19" if int(a) > 50 else "20") + a
        if not a.isdigit() or not (1980 <= int(a) <= 2026):
            continue
        return int(a), m.group(0)
    return None, None


RE_EMPIEZA_FECHA = re.compile(r"^[*%\s]*\d{1,4}[/\-.]\d{1,2}[/\-.]\d{2,4}\b")
RE_MARCA = re.compile(r"\b(INI|FIN|INICIA|TERMINA|INICIO|FINAL)\b", re.I)


def proyecto_de(linea: str, iniciales: str | None, fecha: str | None) -> str | None:
    """El nombre del proyecto es lo que queda al quitar iniciales, marca INI/FIN
    y la fecha. Es lo que permite agrupar 24 marcas inline en un solo evento."""
    t = linea
    if iniciales:
        t = re.sub(r"^[*%\s]*" + re.escape(iniciales) + r"[\s\-]+", "", t)
    if fecha:
        t = t.replace(fecha, " ")
    t = RE_MARCA.sub(" ", t)
    t = re.sub(r"[*%\-_]+", " ", t)
    t = re.sub(r"\b\d{3,}\b", " ", t)        # residuo de numero de secuencia
    t = " ".join(t.split()).strip(" .:-")
    # Sin descripcion, INI y FIN quedarian como dos eventos distintos del mismo cambio.
    return t if len(t) >= 4 else "Cambio sin nota"


def mina_bitacora(texto: str):
    """Entradas de bitacora: comentario fechado que no parece codigo.
    Una linea que ARRANCA con fecha se acepta aunque traiga palabras que el
    filtro de codigo veta (FILLER, VALUE): el orden delata la bitacora."""
    out = []
    for crudo in RE_CMT.findall(texto):
        linea = " ".join(crudo.split())
        if not (12 <= len(linea) <= 110):
            continue
        if not re.search(r"[A-Za-zÁÉÍÓÚÑ]{4,}", linea):
            continue
        empieza_fecha = bool(RE_EMPIEZA_FECHA.match(linea))
        if RE_CODIGO.search(linea.upper()) and not empieza_fecha:
            continue
        anio, fecha = anio_de(linea)
        if anio is None:
            continue
        up = linea.upper()
        vendor = next((v for v in VENDORS if v in up), None)
        mi = RE_INICIALES.match(linea)
        iniciales = mi.group(1) if mi and mi.group(1) not in ("SE", "EL", "LA", "DE", "AL") else None
        out.append({
            "anio": anio, "fecha_raw": fecha, "iniciales": iniciales,
            "vendor": vendor, "texto": linea,
            "proyecto": proyecto_de(linea, iniciales, fecha),
            "fuente": "bitacora" if (iniciales or vendor) else "comentario_fechado",
        })
    return out


RE_DASDL = re.compile(r"^%\s{1,4}(RELEASE|OWNER|DESCRIPTION|CAMBIO|PHYSICAL DATABASE)\s{2,}(\S.*?)\s*%", re.M)


def mina_dasdl(texto: str):
    campos = {k.strip(): " ".join(v.split()) for k, v in RE_DASDL.findall(texto)}
    if not campos:
        return []
    rel = campos.get("RELEASE", "")
    m = re.match(r"(20\d{2})\.(\d{2})", rel)
    if not m:
        return []
    return [{
        "anio": int(m.group(1)), "fecha_raw": rel, "iniciales": None, "vendor": None,
        "texto": "Release %s de la base %s. Cambio: %s" % (
            rel, campos.get("PHYSICAL DATABASE", "?"), campos.get("CAMBIO", "sin nota")),
        "proyecto": campos.get("CAMBIO") or "Release de base de datos",
        "fuente": "dasdl",
    }]


# ── recorrido ────────────────────────────────────────────────────────────────

def recorre():
    autoria, cronologia = [], []
    archivos = 0
    for sistema, carpeta in CORPUS:
        if not carpeta.is_dir():
            print(f"AVISO: no existe {carpeta}")
            continue
        for f in sorted(carpeta.glob("*.txt")):
            archivos += 1
            texto = f.read_text(encoding="utf-8", errors="replace")
            prog, leng = pieza(f, sistema)
            brutos = [(b, "division") for b in RE_AUTHOR.findall(texto)]
            if not brutos:
                brutos = [(b, "comentario") for b in RE_AUTOR_CMT.findall(texto)[:1]]
            for bruto, origen in brutos:
                for nombre in parte_autores(bruto):
                    autoria.append({"programa": prog, "sistema": sistema,
                                    "archivo": f.name, "lenguaje": leng, "origen": origen,
                                    "autor_raw": nombre, "tipo": clasifica(nombre)})
            for ev in mina_bitacora(texto) + mina_dasdl(texto):
                ev |= {"programa": prog, "sistema": sistema, "archivo": f.name}
                cronologia.append(ev)
    return archivos, autoria, cronologia


def consolida(autoria):
    canon = resuelve_identidades([a["autor_raw"] for a in autoria])
    for a in autoria:
        a["autor_id"] = canon[a["autor_raw"]]
    agg = defaultdict(lambda: {"programas": set(), "sistemas": set(), "formas": set()})
    for a in autoria:
        d = agg[a["autor_id"]]
        d["programas"].add(f'{a["sistema"]}:{a["programa"]}')
        d["sistemas"].add(a["sistema"])
        d["formas"].add(a["autor_raw"])
    autores = [{
        "autor_id": k, "display": k, "tipo": clasifica(k),
        "n_programas": len(v["programas"]),
        "sistemas": " ".join(sorted(v["sistemas"])),
        "formas": " | ".join(sorted(v["formas"])),
    } for k, v in agg.items()]
    autores.sort(key=lambda x: (-x["n_programas"], x["display"]))
    return autoria, autores


def consolida_cronologia(cronologia):
    """Las marcas INI/FIN se repiten inline por cada bloque tocado: 24 lineas en
    un programa son UN cambio, no 24. Se colapsa a una fila por programa y se
    agrega una vista de evento, que es la huella del proyecto en el sistema."""
    por_prog = {}
    for c in cronologia:
        k = (c["sistema"], c["programa"], c["anio"], (c["proyecto"] or c["texto"]).upper()[:70])
        if k in por_prog:
            por_prog[k]["repeticiones"] += 1
        else:
            por_prog[k] = dict(c, repeticiones=1)
    filas = sorted(por_prog.values(), key=lambda x: (x["anio"], x["sistema"], x["programa"]))

    agg = defaultdict(lambda: {"programas": set(), "sistemas": set(), "marcas": 0,
                               "vendor": None, "fechas": set(), "fuentes": set()})
    for f in filas:
        k = (f["anio"], (f["proyecto"] or f["texto"]).upper()[:70])
        d = agg[k]
        d["programas"].add(f'{f["sistema"]}:{f["programa"]}')
        d["sistemas"].add(f["sistema"])
        d["marcas"] += f["repeticiones"]
        d["vendor"] = d["vendor"] or f["vendor"]
        d["fechas"].add(f["fecha_raw"])
        d["fuentes"].add(f["fuente"])
    eventos = [{
        "anio": a, "proyecto": p.title(), "vendor": v["vendor"],
        "n_programas": len(v["programas"]), "marcas": v["marcas"],
        "sistemas": " ".join(sorted(v["sistemas"])),
        "fecha_raw": sorted(v["fechas"])[0] if v["fechas"] else "",
        "fuente": " ".join(sorted(v["fuentes"])),
        "programas": " ".join(sorted(v["programas"])),
    } for (a, p), v in agg.items()]
    eventos.sort(key=lambda x: (x["anio"], -x["n_programas"]))
    return filas, eventos


# ── carga ────────────────────────────────────────────────────────────────────

DDL = """
DROP TABLE IF EXISTS autoria;
CREATE TABLE autoria (
  id INTEGER PRIMARY KEY, programa TEXT, sistema TEXT, archivo TEXT,
  lenguaje TEXT, origen TEXT, autor_raw TEXT, autor_id TEXT, tipo TEXT);
DROP TABLE IF EXISTS autores;
CREATE TABLE autores (
  autor_id TEXT PRIMARY KEY, display TEXT, tipo TEXT,
  n_programas INTEGER, sistemas TEXT, formas TEXT);
DROP TABLE IF EXISTS cronologia;
CREATE TABLE cronologia (
  id INTEGER PRIMARY KEY, programa TEXT, sistema TEXT, archivo TEXT,
  anio INTEGER, fecha_raw TEXT, iniciales TEXT, vendor TEXT, texto TEXT,
  proyecto TEXT, repeticiones INTEGER, fuente TEXT);
DROP TABLE IF EXISTS cronologia_eventos;
CREATE TABLE cronologia_eventos (
  id INTEGER PRIMARY KEY, anio INTEGER, proyecto TEXT, vendor TEXT,
  n_programas INTEGER, marcas INTEGER, sistemas TEXT, fecha_raw TEXT,
  fuente TEXT, programas TEXT);
CREATE INDEX IF NOT EXISTS ix_autoria_prog ON autoria(sistema, programa);
CREATE INDEX IF NOT EXISTS ix_crono_anio ON cronologia(anio);
"""


def carga(autoria, autores, cronologia, eventos):
    con = sqlite3.connect(DB)
    con.executescript(DDL)   # DROP + CREATE: el script es dueno de estas cuatro tablas
    con.executemany(
        "INSERT INTO autoria (programa,sistema,archivo,lenguaje,origen,autor_raw,autor_id,tipo)"
        " VALUES (:programa,:sistema,:archivo,:lenguaje,:origen,:autor_raw,:autor_id,:tipo)", autoria)
    con.executemany(
        "INSERT INTO autores (autor_id,display,tipo,n_programas,sistemas,formas)"
        " VALUES (:autor_id,:display,:tipo,:n_programas,:sistemas,:formas)", autores)
    con.executemany(
        "INSERT INTO cronologia (programa,sistema,archivo,anio,fecha_raw,iniciales,vendor,"
        "texto,proyecto,repeticiones,fuente) VALUES (:programa,:sistema,:archivo,:anio,"
        ":fecha_raw,:iniciales,:vendor,:texto,:proyecto,:repeticiones,:fuente)", cronologia)
    con.executemany(
        "INSERT INTO cronologia_eventos (anio,proyecto,vendor,n_programas,marcas,sistemas,"
        "fecha_raw,fuente,programas) VALUES (:anio,:proyecto,:vendor,:n_programas,:marcas,"
        ":sistemas,:fecha_raw,:fuente,:programas)", eventos)
    con.commit()
    con.close()


def main():
    seco = "--dry-run" in sys.argv
    archivos, autoria, crudas = recorre()
    autoria, autores = consolida(autoria)
    cronologia, eventos = consolida_cronologia(crudas)

    con_autor = len({(a["sistema"], a["archivo"]) for a in autoria})
    con_fecha = len({(c["sistema"], c["archivo"]) for c in cronologia})
    personas = [a for a in autores if a["tipo"] == "persona"]
    orgs = [a for a in autores if a["tipo"] == "organizacion"]
    creds = [a for a in autores if a["tipo"] == "credencial"]

    print(f"ALMAS Y BIOGRAFIA — corpus de {archivos} fuentes")
    print("=" * 66)
    print(f"  autoria declarada   : {con_autor}/{archivos} archivos ({con_autor*100//archivos}%)"
          f" · {len(autoria)} firmas")
    print(f"  identidades         : {len(personas)} personas · {len(orgs)} organizaciones"
          f" · {len(creds)} credenciales")
    print(f"  cronologia          : {con_fecha}/{archivos} archivos ({con_fecha*100//archivos}%)"
          f" · {len(crudas)} marcas -> {len(cronologia)} cambios -> {len(eventos)} eventos")
    bit = sum(1 for c in cronologia if c["fuente"] == "bitacora")
    print(f"     de los cuales bitacora con autor/vendor: {bit}")

    print("\n  CONCENTRACION (top 10 por programas firmados)")
    for a in autores[:10]:
        print(f"     {a['n_programas']:3d}  [{a['tipo'][:4]}] {a['display'][:46]:46s} {a['sistemas']}")

    print("\n  EVENTOS DE MAYOR HUELLA")
    for e in sorted(eventos, key=lambda x: -x["n_programas"])[:8]:
        v = f"[{e['vendor']}] " if e["vendor"] else ""
        print(f"     {e['anio']}  {e['n_programas']:3d} prog  {v}{e['proyecto'][:52]}")

    anios = defaultdict(int)
    for c in cronologia:
        anios[c["anio"]] += 1
    print("\n  LINEA DE TIEMPO (cambios, ya deduplicados)")
    for y in sorted(anios):
        print(f"     {y}  {'#' * min(anios[y], 46)} {anios[y]}")

    if seco:
        print("\n--dry-run: no se escribio nada")
        return 0

    KB.mkdir(parents=True, exist_ok=True)
    (KB / "autoria.json").write_text(json.dumps(autoria, ensure_ascii=False, indent=1), encoding="utf-8")
    (KB / "autores.json").write_text(json.dumps(autores, ensure_ascii=False, indent=1), encoding="utf-8")
    (KB / "cronologia.json").write_text(json.dumps(cronologia, ensure_ascii=False, indent=1), encoding="utf-8")
    (KB / "cronologia-eventos.json").write_text(json.dumps(eventos, ensure_ascii=False, indent=1), encoding="utf-8")
    carga(autoria, autores, cronologia, eventos)
    print(f"\n  JSON en {KB}")
    print(f"  cargado en {DB.name}: autoria, autores, cronologia, cronologia_eventos")
    return 0


if __name__ == "__main__":
    sys.exit(main())

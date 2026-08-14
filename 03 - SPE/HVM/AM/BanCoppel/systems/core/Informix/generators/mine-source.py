#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
mine-source.py — Enriquece journeys-data.json con EVIDENCIA del código fuente:
documentación (header autor/proyecto/descripción), parámetros y tablas cross-DB.
Es el puente de "inferencia por nombre" a "propósito confirmado por código".

Pipeline:  extract-journeys.py  →  mine-source.py  →  build-catalog.py
Etapa 3 — Business Logic Extraction · Specialist Informix SPL · SPE-AM-001
"""
import json, re, os

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
SRC = BASE + "source/informix/"
J = json.load(open(BASE + "portal/data/journeys-data.json", encoding="utf-8"))

# ── comentarios: filtramos plantillas de ruido, quedamos con documentación real ──
RE_LINE  = re.compile(r"--\s*([^\r\n]+)")
RE_BRACE = re.compile(r"\{([^}]{4,400})\}", re.S)
RE_SIG   = re.compile(r"CREATE\s+(?:PROCEDURE|FUNCTION)\s+[^\(]*\(([^;]*?)\)\s*RETURNING", re.I | re.S)
# tablas: prefijo de DB explícito (bdixxx:) o esquema informix. — evita capturar variables
RE_TABLE = re.compile(r"(?:FROM|INTO|UPDATE|JOIN)\s+(?:(bdi[a-z]+)\s*:)?\s*(?:\"?informix\"?\.)?([a-z][a-z0-9_]{3,})", re.I)

NOISE = re.compile(r"(TRACE\s+ON|VALIDACION DE ACCESO|VALIDACION DE LA PAGINAC|"
                   r"VALIDACION DE LOS DATOS|VALIDACION PARAMETROS|VALIDACIÓN|"
                   r"definicion de variables|inicializacion|GENERACION DE ARCHIVO|"
                   r"Eliminamos el|RETURNING|INSERT INTO|VALUES|SELECT|DEFINE)", re.I)
# líneas de header con etiqueta descriptiva (alto valor)
HEADER = re.compile(r"\b(Autor|Realiz[oó]|Proyecto|Objetivo|Descripci[oó]n|Prop[oó]sito|"
                    r"Modificaci[oó]n|Requerimiento|RQM|Funci[oó]n|Prop|Fecha)\b", re.I)
CODEY = re.compile(r"[=;()]|:=|\bIF\b|\bLET\b|\bEND\b")  # descarta código comentado

def fix_moji(s):
    # revierte doble/triple codificación latin-1↔utf-8 típica de fuentes legacy AIX
    for _ in range(3):
        if "Ã" in s or "Â" in s:
            try:
                s = s.encode("latin-1").decode("utf-8")
            except (UnicodeEncodeError, UnicodeDecodeError):
                break
        else:
            break
    return s

def clean(s): return fix_moji(re.sub(r"\s+", " ", s).strip(" -=*\t"))

def dehungarian(p):
    core = re.sub(r"^(p|c|v|w|i|m|d|n|b|f|dt|arr|o|s|l)([A-Z_])", r"\2", p)
    return core.lstrip("_").lower()

def analyze(jid, own_db):
    db, sp = jid.split(":", 1)
    fp = SRC + f"{db}_{sp}.sql"
    if not os.path.exists(fp):
        return None
    txt = open(fp, encoding="utf-8", errors="replace").read()
    head = txt[:5000]

    # comentarios candidatos
    raw = []
    for rx in (RE_LINE, RE_BRACE):
        raw += [clean(m) for m in rx.findall(head)]
    # notas de flag/parámetro/debug — NO son descripción de negocio
    JUNK = re.compile(r'^["\']|char\s*\(|\binteger\b|\bsmallint\b|\bdecimal\b|money\s*\(|'
                      r'debug\s+file|set\s+debug|ult\s+renglon|^\d', re.I)
    # comentarios de sección boilerplate (no describen el propósito del SP)
    BOILER = re.compile(r'inicializa\s+variables|inicializaci[oó]n|declaraci[oó]n\s+de\s+variables|'
                        r'define\s+variables|valida\s+(los\s+)?(par[aá]metros|datos)(\s+de\s+entrada)?$|'
                        r'variables\s+globales|se\s+anexan|se\s+colocan|fin\s+de', re.I)
    # descripción explícita del propósito (máxima prioridad)
    DESC = re.compile(r'\b(descripci|objetivo|prop[oó]sito|funcionalidad)\b', re.I)
    # comentario que empieza con verbo de acción = descripción real del proceso
    VERBO = re.compile(r'^(valida|verifica|consulta|registra|genera|calcula|obtiene|aplica|'
                       r'realiza|inserta|actualiza|inicializa|procesa|recupera|elimina|busca|'
                       r'ejecuta|reversa|abona|carga|construye|arma|determina)', re.I)
    prio, headers, docs = [], [], []
    seen = set()
    for c in raw:
        if len(c) < 8 or not re.search(r"[A-Za-zÁÉÍÓÚáéíóúÑñ]{4,}", c):
            continue
        key = c.lower()[:40]
        if key in seen:
            continue
        seen.add(key)
        if JUNK.search(c) or BOILER.search(c) or CODEY.search(c):
            continue
        if DESC.search(c):
            prio.insert(0, c[:130])          # "DESCRIPCION:" → lo mejor, primero
        elif VERBO.search(c):
            prio.append(c[:130])             # empieza con verbo → descripción real
        elif HEADER.search(c) and not CODEY.search(c[:3]):
            headers.append(c[:110])          # autor/proyecto/fecha (metadata)
        elif not NOISE.search(c):
            docs.append(c[:110])
    # orden: descripción/verbo primero, luego docs libres, luego metadata
    doc = (prio[:3] + docs[:2] + headers[:2])[:4]

    # parámetros
    sig = RE_SIG.search(txt)
    pars = []
    if sig:
        for chunk in sig.group(1).split(","):
            m = re.match(r"\s*([a-zA-Z][a-zA-Z0-9_]*)\s+\w", chunk)
            if m:
                pars.append(m.group(1))

    # tablas de negocio: solo con prefijo DB o patrón de tabla real (sc_/tbl/acl_/mnsj_/sw_/_p)
    tbls, xdb = [], set()
    for pref, name in RE_TABLE.findall(txt):
        nm = name.lower()
        if nm in ("select","where","values","dual","table","set","order","group","from"):
            continue
        looks_table = pref or re.match(r"(sc_|tbl|acl_|mnsj_|sw_|cnsif|spei_|tb_)", nm) or nm.endswith("_p")
        if looks_table:
            full = f"{pref}:{nm}" if pref else nm
            if full not in tbls:
                tbls.append(full)
            if pref and pref != own_db:
                xdb.add(pref)
    return dict(doc=doc, params=[dehungarian(p) for p in pars][:12],
                params_raw=pars[:12], tables=tbls[:15], xdb=sorted(xdb))

# ── enriquecer ──
found = wdoc = wpar = 0
DOM2DB = {d: J[d].get("db") for d in J}
for dom, dd in J.items():
    db = dd.get("db")
    for j in dd["journeys"] + dd.get("exposed", []):
        a = analyze(j["id"], db)
        if not a:
            j["src"] = None
            continue
        found += 1
        if a["doc"]: wdoc += 1
        if a["params"]: wpar += 1
        j["src"] = {"doc": a["doc"], "params": a["params"],
                    "tables": a["tables"], "xdb": a["xdb"]}

json.dump(J, open(BASE + "portal/data/journeys-data.json", "w", encoding="utf-8"),
          ensure_ascii=False, separators=(",", ":"))
n = sum(len(dd["journeys"]) + len(dd.get("exposed", [])) for dd in J.values())
print(f"journeys-data.json enriquecido con evidencia de código:")
print(f"  {found}/{n} con archivo fuente · {wdoc} con documentación · {wpar} con parámetros")
print(f"  tamaño: {os.path.getsize(BASE+'portal/data/journeys-data.json'):,} bytes")
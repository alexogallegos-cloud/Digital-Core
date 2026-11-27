#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules-decision.py — Bronze Layer: logica de DECISION D01-D49.

Complementa, no sustituye, a extract-rules.py. El extractor vigente produce
cuatro tipos (FORMULA con * o /, VALIDACION por RAISE o codret de error, UMBRAL
y ESTADO) y deja fuera las cascadas IF/ELIF que asignan el resultado de una
decision de negocio: motivo de rechazo, elegibilidad, segmento, nivel, limite,
o el ruteo condicional hacia otro procedure.

Hallazgo que lo motiva: de los 13,741 procedures del corpus, solo 3,211 tienen
al menos una regla. Procedures como bdisolic:califica_scoring2_cjunk (3,068
lineas, 253 bifurcaciones, calificacion crediticia) quedaban con cero reglas
porque su logica es IF/THEN sobre variables de decision, sin multiplicacion ni
RAISE.

Principio de diseno — el ancla es la CONSECUENCIA, no el IF:
    Una extraccion ingenua de IF/THEN ya se intento en este proyecto (v1.7.0) y
    produjo 25,165 reglas de ruido de control de flujo. Aqui solo se emite regla
    cuando la rama produce un efecto de negocio verificable, y las condiciones
    de plomeria SQL quedan excluidas por construccion.

Sub-tipos emitidos:
    DECISION  — la rama asigna una variable cuyo nombre denota resultado de
                negocio (motivo, estatus, segmento, limite, bandera...)
    EFECTO    — la rama ejecuta DML condicionado por una regla de negocio
    INVOCA    — la rama delega en otro procedure (ruteo condicional)
    RETORNO   — la rama devuelve un codigo de salida

Sub-tipo deliberadamente NO emitido:
    EXCEPCION — medido en 88% de duplicacion con las reglas VALIDACION que ya
                produce extract-rules.py; emitirlo solo infla el catalogo.

ADR-SPE-AM-010: business_name = "" siempre. La sintesis LLM por lectura de
fuente es la unica fuente del campo; este extractor nunca lo puebla.

Salida: portal/data/rules-decision-bronze.json

SPE-AM-001 · Specialist Informix SPL · 2026-11-25
"""
import json, os, re, sys, time
from collections import Counter
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
SRC = BASE / "source" / "informix"
VOCAB_F = BASE / "knowledge-base" / "vocabulary-inventory.json"
OUT = BASE / "portal" / "data" / "rules-decision-bronze.json"

LIMIT = 0
for a in sys.argv[1:]:
    if a.startswith("--limit="):
        LIMIT = int(a.split("=", 1)[1])
    elif a.startswith("--out="):
        OUT = Path(a.split("=", 1)[1])

# ── Vocabulario certificado del proyecto ──────────────────────────────────────
VOCAB = set()
try:
    inv = json.loads(VOCAB_F.read_text(encoding="utf-8"))
    for section in ("atomos", "compuestos"):
        for item in inv.get(section, []):
            t = (item.get("term") or "").lower()
            if len(t) >= 4:
                VOCAB.add(t)
    print(f"Vocabulario cargado: {len(VOCAB)} terminos")
except Exception as e:
    print(f"AVISO: no se pudo leer {VOCAB_F.name}: {e}")

# ── Semantica de decision: variables cuya asignacion ES el resultado ──────────
# codret / cod_err quedan FUERA a proposito: son territorio del sub_tipo
# CODIGO_RETORNO de extract-rules.py. Incluirlos inflaba la extraccion al mismo
# ruido de control de flujo rechazado en v1.7.0 (medido: 25,642 vs 5,069).
DECISION_VAR = re.compile(
    r"(motivo|rechaz|acept|autoriz|aprueb|deneg|eleg|aplica|proced|valid|"
    r"estatus|status|estado|resultado|respuesta|dictamen|clasific|califica|"
    r"observacion|"
    r"score|puntaje|nivel|grado|segmento|perfil|riesgo|"
    r"limite|linea|cupo|tope|maximo|minimo|"
    r"bandera|flag|marca|indicador|bloque|suspend|cancel|vigen|activo)",
    re.I)

RE_IF = re.compile(r"^\s*(if|elif)\b\s*(.+?)\s*then\b(.*)$", re.I)
RE_ASSIGN = re.compile(r"\b(?:let|set)\s+([a-z_][a-z0-9_]*)\s*=\s*(.+)", re.I)
RE_RETURN = re.compile(r"\breturn\b\s*(.+)", re.I)
RE_DML = re.compile(
    r"\b(insert\s+into|update|delete\s+from)\s+([a-z0-9_.\":]+)", re.I)
RE_EXEC = re.compile(r"execute\s+(?:procedure|function)\s+([a-z0-9_.\":]+)", re.I)
RE_RAISE = re.compile(r"raise\s+exception", re.I)
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
RE_CREATE_NAME = re.compile(
    r"create\s+(?:procedure|function)\s+(?:\"[a-z0-9_]+\"\s*\.\s*)?([a-z0-9_]+)", re.I)
RE_ENDIF = re.compile(r"^\s*end\s+if\b", re.I)
RE_ELSE = re.compile(r"^\s*(else|elif)\b", re.I)

# Condiciones de plomeria SQL — nunca son regla de negocio
RUIDO_COND = re.compile(
    r"^\s*\(?\s*(verror|v_error|ierror|status|v_status)\s*(!=|<>|=)\s*0?\s*\)?\s*$",
    re.I)
RE_SOLO_NULL = re.compile(
    r"^\s*\(?\s*\(?\s*[a-z0-9_.]+\s*\)?\s+is\s+(not\s+)?null\s*\)?\s*$", re.I)
RE_SQLERR = re.compile(r"\b[a-z_]*sql_?err[a-z_]*\b|\bsqlcode\b|\bsqlerrd\b|\bsqlca\b",
                       re.I)
RE_VARS = re.compile(r"[a-z_][a-z0-9_]{2,}", re.I)
_STOP = {"and", "or", "not", "null", "nvl", "trim", "date", "select", "from",
         "where", "count", "exists", "then", "else", "informix", "sum", "max",
         "min", "upper", "lower", "substr", "today", "current", "year", "month",
         "day", "cast", "int", "char", "decimal", "case", "when", "end", "val"}

RE_COMENTARIO = re.compile(r"--.*$", re.M)
RE_BLOQUE_COM = re.compile(r"\{[^}]*\}", re.S)

# ── Mapa de dominios (alineado a extract-rules.py) ────────────────────────────
DOMN = {
    "bdicnweb": "D01 Canal Digital Web", "bdinteg": "D02 Integración y Auth",
    "bdicred": "D03 Créditos", "bdicheq": "D04 Cheques / Cuentas",
    "bdisac": "D05 Saldos y Cuentas", "bdisolic": "D06 Solicitudes",
    "bdiaclaracion": "D07 Aclaraciones", "bdispei": "D08 SPEI",
    "bdimnsj": "D09 Mensajería", "bdisuc": "D10 Sucursales",
    "bdicobranza": "D11 Cobranza", "bdicont": "D12 Contabilidad",
    "bditef": "D13 TEF", "bdibei": "D14 BEI", "bdilide": "D15 LIDE / PLD",
    "intercard": "D16 Tarjetas", "bdibpi": "D17 BPI",
    "intercardbpi": "D18 Intercard BPI", "bditarjeta": "D19 Tarjetas",
    "bdiprog": "D20 Programas", "bdidomi": "D21 Domiciliación",
    "bditransfer": "D22 Transferencias", "bdmis": "D23 MIS Sucursales",
    "bdiburo": "D24 Buró de Crédito", "bdisitesp": "D25 Sitio Especial",
    "bdiprospectos": "D26 Prospectos", "bdiauditor": "D27 Auditoría",
    "bdinvers": "D28 Inversiones", "bdiedoelec": "D29 Estados de Cuenta Electrónicos",
    "bditarjcop": "D30 Tarjetas Coppel", "bdicntchq": "D31 Control de Cheques",
    "bdireports": "D32 Reportes Visa/MC", "bdimonitorcob": "D33 Monitor de Cobranza",
    "bdiresp": "D34 RESP", "bdidigital": "D35 Digitalización",
    "bdirepaut": "D36 Reportería CNBV", "bdiadminnomina": "D37 Administración Nómina",
    "bdicplbot": "D38 CPL Bot", "bdiservicios": "D39 Servicios", "bdibi": "D40 BI",
    "bdicorresp": "D41 Corresponsalía", "bdivr": "D42 IVR",
    "bditrapres": "D43 Transferencias Presenciales", "bdirech": "D44 Conciliación Operativa",
    "bdiprem": "D45 PREM", "bdiofi": "D46 Oficinas de Cobro", "bdigaran": "D47 Garantías",
    "bdiriesgos": "D48 Riesgos de Crédito", "bdirst": "D49 RST",
}
DOMN_CODE = {db: lbl.split()[0] for db, lbl in DOMN.items()}


def sin_comentarios(s):
    return RE_COMENTARIO.sub("", RE_BLOQUE_COM.sub(" ", s))


def norm(s, n=240):
    return re.sub(r"\s+", " ", sin_comentarios(s)).strip().rstrip(";")[:n]


def cond_es_negocio(cond):
    """La condicion habla de negocio, no de plomeria SQL."""
    c = sin_comentarios(cond).lower().strip()
    if not c or RUIDO_COND.match(c) or RE_SOLO_NULL.match(c) or RE_SQLERR.search(c):
        return False
    if DECISION_VAR.search(c):
        return True
    if any(t in c for t in VOCAB):
        return True
    # comparacion contra literal, con al menos un identificador con sentido
    if re.search(r"[<>]=?\s*-?\d", c) or re.search(r"\bin\s*\(", c):
        return bool(re.search(r"[a-z]{4,}", c))
    return False


def consecuencia(lineas, i, inline):
    """(sub_tipo, texto) del efecto de la rama, o None si no hay efecto de negocio."""
    inline = sin_comentarios(inline)
    cuerpo = [inline] if inline.strip() else []
    j = i
    while j < len(lineas) and len(cuerpo) < 6:
        l = sin_comentarios(lineas[j])
        if RE_ENDIF.match(l) or RE_ELSE.match(l):
            break
        if l.strip():
            cuerpo.append(l)
        j += 1
    txt = " ".join(cuerpo)
    if not txt.strip():
        return None
    # EXCEPCION se omite a proposito: 88% de duplicacion con VALIDACION vigente
    if RE_RAISE.search(txt):
        return None
    m = RE_ASSIGN.search(txt)
    if m and DECISION_VAR.search(m.group(1)):
        return ("DECISION", norm(m.group(1) + " = " + m.group(2)))
    m = RE_RETURN.search(txt)
    if m and re.search(r"['\"]?\d", m.group(1)):
        return ("RETORNO", norm("return " + m.group(1), 120))
    m = RE_DML.search(txt)
    if m:
        return ("EFECTO", norm(m.group(1).strip() + " " + m.group(2)))
    me = RE_EXEC.search(txt)
    if me and me.start() <= 40:
        return ("INVOCA", norm("execute procedure " + me.group(1)))
    return None


def isolate_body(fp):
    """Primer procedure del archivo. Cada .sql es su procedure seguido de la cola
    del dump de su base; sin aislar se extraeria logica ajena al SP nombrado."""
    with fp.open("rb") as f:
        buf = f.read(262144)
        txt = buf.decode("utf-8", errors="replace")
        ms = list(RE_CREATE.finditer(txt))
        if len(ms) >= 2:
            return txt[ms[0].start():ms[1].start()]
        rest = f.read()
    txt += rest.decode("utf-8", errors="replace")
    ms = list(RE_CREATE.finditer(txt))
    if len(ms) >= 2:
        return txt[ms[0].start():ms[1].start()]
    return txt[ms[0].start():] if ms else txt


def main():
    t0 = time.time()
    reglas, stats, seq = [], Counter(), 0
    archivos = sorted(f for f in os.listdir(SRC) if f.endswith(".sql"))
    if LIMIT:
        archivos = archivos[:LIMIT]
    print(f"Archivos .sql a procesar: {len(archivos)}")

    for n, fn in enumerate(archivos, 1):
        try:
            cuerpo = isolate_body(SRC / fn)
        except Exception:
            stats["error_lectura"] += 1
            continue

        m = RE_CREATE_NAME.search(cuerpo)
        sp = m.group(1).lower() if m else fn[:-4].partition("_")[2].lower()
        stem = fn[:-4]
        # el nombre de base puede llevar guion bajo (bdicorresp_mc), asi que se
        # deriva quitando el nombre real del procedure, no partiendo por el primer _
        db = (stem[:-(len(sp) + 1)].lower()
              if stem.lower().endswith("_" + sp) else stem.partition("_")[0].lower())

        lineas = cuerpo.split("\n")
        vistos = set()
        for i, raw in enumerate(lineas):
            s = raw.strip()
            if not s or s.startswith("--"):
                continue
            mi = RE_IF.match(s)
            if not mi:
                continue
            stats["if_vistos"] += 1
            cond = mi.group(2)
            if not cond_es_negocio(cond):
                stats["descartado_condicion"] += 1
                continue
            cons = consecuencia(lineas, i + 1, mi.group(3) or "")
            if not cons:
                stats["sin_consecuencia"] += 1
                continue
            sub_tipo, texto = cons

            if sub_tipo == "DECISION":
                asignada = texto.split("=")[0].strip().lower()
                vars_cond = {v.lower() for v in RE_VARS.findall(cond)} - _STOP
                # la rama asigna la misma variable que interroga la condicion y no
                # hay otra variable en juego: es valor por omision, no decision
                if (asignada in vars_cond and len(vars_cond) <= 1) \
                        or RE_SOLO_NULL.match(cond.strip()):
                    stats["valor_por_omision"] += 1
                    continue

            clave = (re.sub(r"\d", "#", norm(cond)), sub_tipo)
            if clave in vistos:
                stats["dedup"] += 1
                continue
            vistos.add(clave)
            seq += 1
            stats["emitidas"] += 1
            stats["sub_" + sub_tipo] += 1
            reglas.append({
                "id": f"BR-DEC-{seq:06d}",
                "tipo": "DECISIÓN", "sub_tipo": sub_tipo,
                "sp": f"{db}:{sp}", "db": db, "line": i + 1,
                "code": norm("IF " + cond + " THEN " + texto, 300),
                "condicion": norm(cond, 200), "consecuencia": texto,
                "dominio": DOMN.get(db, db), "dom_code": DOMN_CODE.get(db, ""),
                "business_name": "",          # ADR-SPE-AM-010
                "source_file": f"source/informix/{fn}",
            })

        if n % 3000 == 0:
            print(f"  {n}/{len(archivos)} · {stats['emitidas']} reglas · "
                  f"{time.time()-t0:.0f}s", flush=True)

    sps = {r["sp"] for r in reglas}
    salida = {
        "meta": {
            "generado": time.strftime("%Y-%m-%d"),
            "generador": "extract-rules-decision.py",
            "capa": "Bronze",
            "archivos_procesados": len(archivos),
            "procedures_con_regla": len(sps),
            "segundos": round(time.time() - t0, 1),
            "nota": "Complementa extract-rules.py; no lo sustituye. "
                    "business_name vacio por ADR-SPE-AM-010.",
        },
        "stats": dict(stats),
        "rules": reglas,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(salida, ensure_ascii=False, indent=1), encoding="utf-8")

    print()
    print(f"IF/ELIF vistos                : {stats['if_vistos']}")
    print(f"  descartados por condicion   : {stats['descartado_condicion']}")
    print(f"  sin consecuencia de negocio : {stats['sin_consecuencia']}")
    print(f"  valor por omision           : {stats['valor_por_omision']}")
    print(f"  deduplicados                : {stats['dedup']}")
    print(f"REGLAS emitidas               : {stats['emitidas']}")
    for k in sorted(k for k in stats if k.startswith("sub_")):
        print(f"    {k[4:]:<10} {stats[k]}")
    print(f"procedures cubiertos          : {len(sps)}")
    print(f"salida                        : {OUT}")


if __name__ == "__main__":
    main()

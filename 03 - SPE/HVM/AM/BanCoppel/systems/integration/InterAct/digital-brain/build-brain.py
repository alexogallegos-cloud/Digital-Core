#!/usr/bin/env python3
"""
build-brain.py — InterAct Digital Brain
BanCoppel Application Modernization · SPE-AM-001

InterAct es el front-end ISO 8583 de la plataforma de tarjetas de BanCoppel.
Este pipeline construye su brain desde el conocimiento destilado por
`generators/parse-interact.py`.

Reglas AM aplicadas: B1 (autosuficiente), B2 (ETB embebido), B5 y B10
(dependencias declaradas en ambos lados), B11 (emite seeds), B12 (preserva seed).

Uso:
  python build-brain.py [--reset]
"""

import argparse
import json
import sqlite3
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).resolve().parent
SYSTEM_DIR = SCRIPT_DIR.parent
DATA_DIR = SCRIPT_DIR / "data"
SEEDS_DIR = SCRIPT_DIR / "seeds"
DB_PATH = SCRIPT_DIR / "brain.db"
ETB_PATH = SYSTEM_DIR / "knowledge-base" / "ontology" / "etb-capabilities.json"

SYSTEM_ID = "interact"
VERSION = "1.0.0"
TS_NOW = datetime.now(timezone.utc).isoformat()

# Cobertura ETB propia, solo lo que la evidencia demuestra
ETB_COBERTURA = {
    "3.5.6": ("COVERED", "Conmuta el trafico ISO 8583 entre la red de marca y el autorizador"),
    "3.5.2": ("CROSS_CUTTING", "Participa en la autorizacion aplicando la validacion criptografica previa, pero la decision de autorizar la toma e-global"),
    "1.2.2": ("CROSS_CUTTING", "Transporta el trafico de ATM y POS sin ser el canal en si"),
    "5.8.2": ("CROSS_CUTTING", "Valida PIN, CVV, CVV2 y 3D Secure como barrera antifraude de entrada"),
}

# Semantica de los indicadores observados
PRODUCT_DESC = {
    "01": "Cajero automatico",
    "02": "Punto de venta",
}

CVV_IND_DESC = {
    "0": "Sin CVV2 en el mensaje",
    "1 (CVV2 Present)": "CVV2 presente, se valida",
    "(vacio)": "Indicador ausente en el mensaje",
}

MTI_DESC = {
    "0200": "Solicitud de transaccion financiera",
    "0210": "Respuesta a solicitud de transaccion financiera",
    "0220": "Aviso de transaccion financiera",
    "0221": "Repeticion de aviso de transaccion financiera",
    "0420": "Aviso de reverso",
    "0421": "Repeticion de aviso de reverso",
    "0430": "Respuesta a aviso de reverso",
    "0800": "Mensaje administrativo de red",
    "0810": "Respuesta a mensaje administrativo de red",
}

# Tokens propietarios del campo 63 con el significado deducible de la evidencia
TOKEN_DESC = {
    "Q1": "Control de estado del token, el autorizador lo emite en 9 y InterAct lo reescribe a 0",
    "Q2": "Codigo de operacion del grupo de tokens",
    "C0": "Datos de la terminal y su configuracion",
    "C4": "Identificador de la afiliacion del comercio",
    "B4": "Datos de la transaccion con tarjeta en archivo",
    "B5": "Datos criptograficos EMV",
    "PJ": "Marca de transaccion iniciada por el comercio",
    "17": "Identificador de transaccion de la marca VISA",
    "PY": "Datos de pago recurrente",
    "PC": "Datos complementarios del comercio",
    "TV": "Datos de validacion de token",
    "R4": "Datos de respuesta de la red",
}


def preserve_seed(db_path):
    if not db_path.exists():
        return {"cross_dependencies": [], "signals": [], "system_info": None}
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    r = {"cross_dependencies": [], "signals": [], "system_info": None}
    consultas = {
        "cross_dependencies": "SELECT * FROM cross_dependencies WHERE evidence_batch IS NULL",
        "signals": f"SELECT * FROM signals WHERE source_system != '{SYSTEM_ID}'",
    }
    for tabla, sql in consultas.items():
        try:
            r[tabla] = [dict(x) for x in con.execute(sql)]
        except sqlite3.OperationalError:
            try:
                r[tabla] = [dict(x) for x in con.execute(f"SELECT * FROM {tabla}")]
            except sqlite3.OperationalError:
                pass
    try:
        f = con.execute("SELECT * FROM system_info").fetchone()
        r["system_info"] = dict(f) if f else None
    except sqlite3.OperationalError:
        pass
    con.close()
    return r


SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    slug TEXT PRIMARY KEY, display_name TEXT, togaf_type TEXT, togaf_state TEXT,
    togaf_abb TEXT, vendor_version TEXT, install_path TEXT,
    brain_version TEXT, built_at TEXT
);
CREATE TABLE IF NOT EXISTS cross_dependencies (
    id TEXT PRIMARY KEY, other_system TEXT NOT NULL, relationship TEXT NOT NULL,
    direction TEXT NOT NULL, volume INTEGER DEFAULT 0, domains TEXT DEFAULT '[]',
    regulation TEXT DEFAULT '[]', description TEXT, criticality TEXT DEFAULT 'unknown',
    origin_artifact TEXT, seeded_at TEXT, evidence_batch TEXT
);
CREATE TABLE IF NOT EXISTS signals (
    id INTEGER PRIMARY KEY AUTOINCREMENT, signal_type TEXT NOT NULL,
    source_system TEXT NOT NULL, value INTEGER DEFAULT 0,
    metadata TEXT DEFAULT '{}', seeded_at TEXT
);
CREATE TABLE IF NOT EXISTS etb_l1 (id TEXT PRIMARY KEY, name TEXT);
CREATE TABLE IF NOT EXISTS etb_l2 (id TEXT PRIMARY KEY, l1_id TEXT, name TEXT);
CREATE TABLE IF NOT EXISTS etb_l3 (
    id TEXT PRIMARY KEY, l2_id TEXT, l1_id TEXT, name TEXT, definition TEXT,
    bcop_status TEXT, coverage_rationale TEXT, etb_version TEXT
);

CREATE TABLE IF NOT EXISTS log_batches (
    batch TEXT PRIMARY KEY, extractor TEXT, extractor_version TEXT, extracted_at TEXT,
    files INTEGER, lines INTEGER, messages INTEGER,
    window_start TEXT, window_end TEXT, source_folder TEXT
);
CREATE TABLE IF NOT EXISTS log_files (
    batch TEXT, filename TEXT, process TEXT, instance TEXT, bytes INTEGER,
    lines INTEGER, messages INTEGER, sha256_prefix TEXT,
    PRIMARY KEY (batch, filename)
);

-- Inventario de la suite
CREATE TABLE IF NOT EXISTS processes (
    process TEXT, role TEXT, description TEXT, files INTEGER, instances TEXT,
    instance_count INTEGER, lines INTEGER, messages INTEGER, evidence_batch TEXT,
    PRIMARY KEY (process, evidence_batch)
);

-- Politica de validacion criptografica, declarada en prosa por el modulo de seguridad
CREATE TABLE IF NOT EXISTS security_policies (
    policy TEXT, channel TEXT, message_types TEXT, validates TEXT,
    occurrences INTEGER, evidence_batch TEXT,
    PRIMARY KEY (policy, evidence_batch)
);

CREATE TABLE IF NOT EXISTS message_types (
    mti TEXT, direction TEXT, description TEXT, occurrences INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (mti, direction, evidence_batch)
);

CREATE TABLE IF NOT EXISTS de63_tokens (
    token TEXT, occurrences INTEGER, description TEXT, evidence_batch TEXT,
    PRIMARY KEY (token, evidence_batch)
);

CREATE TABLE IF NOT EXISTS token_errors (
    token TEXT, error_code TEXT, occurrences INTEGER, evidence_batch TEXT,
    PRIMARY KEY (token, error_code, evidence_batch)
);

CREATE TABLE IF NOT EXISTS risk_indicators (
    family TEXT, value TEXT, description TEXT, occurrences INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (family, value, evidence_batch)
);

CREATE TABLE IF NOT EXISTS header_return_codes (
    code TEXT, occurrences INTEGER, evidence_batch TEXT,
    PRIMARY KEY (code, evidence_batch)
);
"""

FTS = """
DROP TABLE IF EXISTS knowledge_fts;
CREATE VIRTUAL TABLE knowledge_fts USING fts5(kind, key, text);
"""

TABLAS = ["system_info", "cross_dependencies", "signals", "etb_l1", "etb_l2", "etb_l3",
          "log_batches", "log_files", "processes", "security_policies", "message_types",
          "de63_tokens", "token_errors", "risk_indicators", "header_return_codes"]


def create_schema(con, reset):
    if reset:
        for t in TABLAS:
            con.execute(f"DROP TABLE IF EXISTS {t}")
    con.executescript(SCHEMA)


def load_etb(con):
    if not ETB_PATH.exists():
        return 0
    data = json.loads(ETB_PATH.read_text(encoding="utf-8"))
    version = data.get("meta", {}).get("version", "1.0")
    l1, l2, filas = {}, {}, []
    for cap in data["capabilities"]:
        l1[cap["l1_id"]] = cap["l1"]
        l2[cap["l2_id"]] = (cap["l1_id"], cap["l2"])
        estado, razon = ETB_COBERTURA.get(cap["l3_id"], ("NOT_ASSESSED", None))
        filas.append((cap["l3_id"], cap["l2_id"], cap["l1_id"], cap["l3"],
                      cap.get("definition"), estado, razon, version))
    con.executemany("INSERT OR REPLACE INTO etb_l1 VALUES (?,?)", list(l1.items()))
    con.executemany("INSERT OR REPLACE INTO etb_l2 VALUES (?,?,?)",
                    [(k, v[0], v[1]) for k, v in l2.items()])
    con.executemany("INSERT OR REPLACE INTO etb_l3 VALUES (?,?,?,?,?,?,?,?)", filas)
    return len(filas)


def clasificar_politica(texto):
    """Deduce canal, tipos de mensaje y que valida, desde la prosa del modulo."""
    t = texto.lower()
    if "pin and cvv" in t:
        canal, valida = "Cajero automatico", "PIN y CVV"
    elif "cvv when card was slide" in t:
        canal, valida = "Punto de venta", "CVV obligatorio en banda o chip, CVV2 condicional"
    elif "no validations performed" in t or "fallback" in t:
        canal, valida = "Punto de venta", "Ninguna"
    elif "no validations" in t:
        canal, valida = "Indistinto", "Ninguna"
    elif "without make" in t:
        canal, valida = "Indistinto", "Marca del BIN, la transaccion se invalida si no resuelve"
    else:
        canal, valida = "Indistinto", "Sin clasificar"
    mtis = sorted(set(m for m in ("200", "220", "221", "420", "421") if m in texto))
    return canal, json.dumps([f"0{m}" for m in mtis], ensure_ascii=False), valida


def load_knowledge(con, lotes):
    for d in lotes:
        lote = d["lote"]
        a = d["agregados"]

        ini = a.get("ts_min")
        fin = a.get("ts_max")
        con.execute("INSERT OR REPLACE INTO log_batches VALUES (?,?,?,?,?,?,?,?,?,?)",
                    (lote, d["extractor"], d["extractor_version"], d["generado"],
                     len(d["fuentes"]), sum(f["lineas"] for f in d["fuentes"]),
                     a.get("mensajes", 0), ini, fin, d.get("source_folder")))
        con.executemany("INSERT OR REPLACE INTO log_files VALUES (?,?,?,?,?,?,?,?)",
                        [(lote, f["archivo"], f["proceso"], f["instancia"], f["bytes"],
                          f["lineas"], f["mensajes"], f["sha256_prefijo"])
                         for f in d["fuentes"]])

        con.executemany("INSERT OR REPLACE INTO processes VALUES (?,?,?,?,?,?,?,?,?)",
                        [(nombre, p["rol"], p["descripcion"], p["archivos"],
                          json.dumps(p["instancias"]), len(p["instancias"]),
                          p["lineas"], p["mensajes"], lote)
                         for nombre, p in d["procesos"].items()])

        con.executemany("INSERT OR REPLACE INTO security_policies VALUES (?,?,?,?,?,?)",
                        [(texto, *clasificar_politica(texto)[:2],
                          clasificar_politica(texto)[2], n, lote)
                         for texto, n in a.get("politicas", {}).items()])

        filas = [(mti, "entrada", MTI_DESC.get(mti, "Sin catalogar"), n, lote)
                 for mti, n in a.get("msg_type", {}).items()]
        filas += [(mti, "salida", MTI_DESC.get(mti, "Sin catalogar"), n, lote)
                  for mti, n in a.get("mti_out", {}).items()]
        con.executemany("INSERT OR REPLACE INTO message_types VALUES (?,?,?,?,?)", filas)

        con.executemany("INSERT OR REPLACE INTO de63_tokens VALUES (?,?,?,?)",
                        [(t, n, TOKEN_DESC.get(t), lote)
                         for t, n in a.get("tokens", {}).items()])
        con.executemany("INSERT OR REPLACE INTO token_errors VALUES (?,?,?,?)",
                        [(*k.split("|"), n, lote)
                         for k, n in a.get("token_err", {}).items()])

        riesgo = []
        for v, n in a.get("product", {}).items():
            riesgo.append(("Indicador de producto", v, PRODUCT_DESC.get(v, "Sin catalogar"), n, lote))
        for v, n in a.get("cvv_ind", {}).items():
            riesgo.append(("Indicador de CVV", v, CVV_IND_DESC.get(v, "Sin catalogar"), n, lote))
        for v, n in a.get("tds", {}).items():
            riesgo.append(("3D Secure", v, "Valor del indicador de comercio electronico", n, lote))
        for v, n in a.get("cvn", {}).items():
            etiqueta = ("Transaccion EMV completa" if v == "full_emv"
                        else "Numero de version del criptograma EMV")
            riesgo.append(("EMV", v, etiqueta, n, lote))
        for v, n in a.get("pem", {}).items():
            riesgo.append(("Modo de entrada DE22", v, "Modo de entrada reportado por la terminal", n, lote))
        con.executemany("INSERT OR REPLACE INTO risk_indicators VALUES (?,?,?,?,?)", riesgo)

        con.executemany("INSERT OR REPLACE INTO header_return_codes VALUES (?,?,?)",
                        [(c, n, lote) for c, n in a.get("return_code", {}).items()])


def load_dependencies(con, rescate, lotes):
    for dep in rescate["cross_dependencies"]:
        con.execute("INSERT OR REPLACE INTO cross_dependencies "
                    "(id,other_system,relationship,direction,volume,domains,regulation,"
                    " description,criticality,origin_artifact,seeded_at,evidence_batch) "
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                    (dep["id"], dep["other_system"], dep["relationship"], dep["direction"],
                     dep.get("volume", 0), dep.get("domains", "[]"), dep.get("regulation", "[]"),
                     dep.get("description"), dep.get("criticality", "unknown"),
                     dep.get("origin_artifact"), dep.get("seeded_at"), None))

    lote = lotes[-1]["lote"]
    mensajes = sum(l["agregados"].get("mensajes", 0) for l in lotes)
    con.execute("INSERT OR REPLACE INTO cross_dependencies "
                "(id,other_system,relationship,direction,volume,domains,regulation,"
                " description,criticality,origin_artifact,seeded_at,evidence_batch) "
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                ("interact-eglobal", "e-global", "calls", "outbound", mensajes,
                 json.dumps(["D16"]), json.dumps(["PCI-DSS"]),
                 "InterAct entrega al autorizador e-global cada solicitud de la red y recibe "
                 "su respuesta para armar el mensaje ISO de salida. El log nombra al "
                 "autorizador como icard. Volumen pareado uno a uno con el del autorizador "
                 "en la misma ventana.",
                 "critical", f"source/logs/{lote}", TS_NOW, lote))


def build_fts(con):
    con.executescript(FTS)
    filas = []
    for p, rol, desc in con.execute(
            "SELECT process, role, description FROM processes GROUP BY process"):
        filas.append(("proceso", p, f"{p} {rol} {desc}"))
    for pol, canal, valida in con.execute(
            "SELECT policy, channel, validates FROM security_policies GROUP BY policy"):
        filas.append(("politica-seguridad", pol[:60], f"{pol} {canal} {valida}"))
    for mti, desc in con.execute(
            "SELECT mti, MAX(description) FROM message_types GROUP BY mti"):
        filas.append(("mensaje-iso", mti, f"{mti} {desc}"))
    for t, desc in con.execute(
            "SELECT token, MAX(COALESCE(description,'')) FROM de63_tokens GROUP BY token"):
        filas.append(("token-de63", t, f"token {t} DE63 {desc}"))
    for l3, nombre, defi in con.execute(
            "SELECT id, name, COALESCE(definition,'') FROM etb_l3 "
            "WHERE bcop_status != 'NOT_ASSESSED'"):
        filas.append(("capability", l3, f"{l3} {nombre} {defi}"))
    con.executemany("INSERT INTO knowledge_fts (kind,key,text) VALUES (?,?,?)", filas)
    return len(filas)


def emit_signals(con, rescate):
    con.execute("DELETE FROM signals WHERE source_system = ?", (SYSTEM_ID,))
    for s in rescate["signals"]:
        con.execute("INSERT INTO signals (signal_type,source_system,value,metadata,seeded_at) "
                    "VALUES (?,?,?,?,?)",
                    (s["signal_type"], s["source_system"], s.get("value", 0),
                     s.get("metadata", "{}"), s.get("seeded_at")))

    def n(sql):
        return con.execute(sql).fetchone()[0] or 0

    for tipo, valor, meta in [
        ("mensajes_observados", n("SELECT SUM(messages) FROM log_batches"), {}),
        ("politicas_de_validacion", n("SELECT COUNT(DISTINCT policy) FROM security_policies"), {}),
        ("procesos_de_la_suite", n("SELECT COUNT(DISTINCT process) FROM processes"), {}),
        ("instancias_de_aplicacion",
         n("SELECT MAX(instance_count) FROM processes WHERE process='interapp'"), {}),
        ("tokens_de63", n("SELECT COUNT(DISTINCT token) FROM de63_tokens"), {}),
        ("tipos_mensaje_iso", n("SELECT COUNT(DISTINCT mti) FROM message_types"), {}),
    ]:
        con.execute("INSERT INTO signals (signal_type,source_system,value,metadata,seeded_at) "
                    "VALUES (?,?,?,?,?)",
                    (tipo, SYSTEM_ID, int(valor), json.dumps(meta, ensure_ascii=False), TS_NOW))


def emit_seeds(con):
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    lote = con.execute("SELECT batch FROM log_batches ORDER BY batch DESC LIMIT 1").fetchone()
    lote = lote[0] if lote else None
    politicas = [{"id": p[:70], "name": p[:70], "channel": c, "validates": v, "volume": n}
                 for p, c, v, n in con.execute(
                     "SELECT policy, channel, validates, SUM(occurrences) FROM security_policies "
                     "GROUP BY policy ORDER BY 4 DESC")]
    seed = {
        "source_system": SYSTEM_ID,
        "source_togaf_type": "integration",
        "target_system": "e-global",
        "target_togaf_type": "integration",
        "generated_at": TS_NOW[:10],
        "source_version": f"InterAct brain v{VERSION}",
        "relationship": "calls",
        "evidence": {
            "component_count": len(politicas),
            "components": politicas,
            "volume": con.execute("SELECT SUM(messages) FROM log_batches").fetchone()[0] or 0,
            "domains": ["D16"],
            "regulation": ["PCI-DSS"],
            "origin_artifact": f"source/logs/{lote}",
            "note": "InterAct aplica la validacion criptografica ANTES de que el autorizador "
                    "ejecute sus validaciones de negocio. Las politicas listadas acotan que "
                    "se valida por canal y tipo de mensaje.",
        },
    }
    (SEEDS_DIR / "e-global-seed.json").write_text(
        json.dumps(seed, ensure_ascii=False, indent=1), encoding="utf-8")
    (SEEDS_DIR / "manifest.json").write_text(json.dumps({
        "emitter": SYSTEM_ID, "generated_at": TS_NOW,
        "source_version": f"InterAct brain v{VERSION}",
        "seeds": [{"target": "e-global", "file": "e-global-seed.json",
                   "evidence_count": len(politicas)}],
    }, ensure_ascii=False, indent=1), encoding="utf-8")
    return len(politicas)


def main():
    ap = argparse.ArgumentParser(description="Construye el brain de InterAct")
    ap.add_argument("--reset", action="store_true")
    args = ap.parse_args()

    lotes = [json.loads(p.read_text(encoding="utf-8")) for p in sorted(DATA_DIR.glob("*.json"))]
    if not lotes:
        print(f"[!] sin datos en {DATA_DIR} — ejecuta antes generators/parse-interact.py")
        return 1

    print(f"InterAct brain v{VERSION}")
    rescate = preserve_seed(DB_PATH)
    con = sqlite3.connect(DB_PATH)
    con.execute("PRAGMA journal_mode=WAL")
    create_schema(con, args.reset)

    con.execute("INSERT OR REPLACE INTO system_info VALUES (?,?,?,?,?,?,?,?,?)",
                (SYSTEM_ID, "InterAct — Front-end ISO 8583 de tarjetas", "integration",
                 "baseline", "payment-switching", "031300",
                 "/pisa/pisabanco/pisa_ftes/syndein/coppel/InterAct", VERSION, TS_NOW))

    print(f"  ETB embebido: {load_etb(con)} capacidades L3")
    load_knowledge(con, lotes)
    load_dependencies(con, rescate, lotes)
    n_fts = build_fts(con)
    emit_signals(con, rescate)
    con.commit()
    n_seed = emit_seeds(con)

    print("\n  conocimiento cargado:")
    for t in ("log_batches", "log_files", "processes", "security_policies", "message_types",
              "de63_tokens", "token_errors", "risk_indicators", "header_return_codes",
              "cross_dependencies", "signals"):
        print(f"    {t:24s} {con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>7,}")
    print(f"    {'knowledge_fts':24s} {n_fts:>7,}")
    print(f"\n  seeds emitidos (B11): e-global-seed.json con {n_seed} politicas")
    con.close()
    print(f"  -> {DB_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

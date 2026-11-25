#!/usr/bin/env python3
"""
build-brain.py — e-global Digital Brain
BanCoppel Application Modernization · SPE-AM-001

Construye el brain del autorizador de pagos e-global a partir del conocimiento
destilado de sus logs de produccion por `generators/parse-authorizerj.py`.

Pipeline:
  1. preserve_seed()      — Regla B12: rescata cross_dependencies y signals del seed
  2. create_schema()      — tablas del brain
  3. load_etb()           — Regla B2: catalogo ETB embebido con cobertura propia
  4. load_batches()       — lotes de log procesados (trazabilidad de evidencia)
  5. load_knowledge()     — validaciones, funciones, tipos de transaccion, codigos
  6. load_dependencies()  — Regla B10: SPs de Informix invocados -> cross_dependencies
  7. build_fts()          — indices FTS5
  8. emit_signals()       — señales cuantitativas del sistema
  9. emit_seeds()         — Regla B11: siembra evidencia hacia Informix

Uso:
  python build-brain.py [--reset] [--verbose]

Regla de trazabilidad (Informix CLAUDE.md): todo dato proveniente de logs declara
su lote de evidencia y su fecha. Nada se mezcla con analisis estatico.
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

SYSTEM_ID = "e-global"
VERSION = "1.0.0"
TS_NOW = datetime.now(timezone.utc).isoformat()

# ─────────────────────────────────────────────────────────────────
# Cobertura ETB propia de e-global (Regla B2)
# Solo se marca COVERED lo que la evidencia del log demuestra directamente.
# ─────────────────────────────────────────────────────────────────
ETB_COBERTURA = {
    "3.5.2": ("COVERED", "Autoriza o rechaza cada transaccion de tarjeta: es la funcion central del sistema"),
    "3.5.6": ("COVERED", "Conmuta entre la red de marca (ISO 8583) y el core Informix via stored procedures"),
    "1.2.2": ("COVERED", "Atiende transacciones originadas en ATM y POS (RETIRO_ATM, COMPRA_POS, CONSULTA_ATM)"),
    "5.8.2": ("CROSS_CUTTING", "Ejecuta validaciones antifraude en linea (comercio dudoso, giro de negocio, codigo 59); la deteccion especializada vive en otro sistema"),
}

# ─────────────────────────────────────────────────────────────────
# Significado de los codigos de respuesta ISO 8583 observados
# ─────────────────────────────────────────────────────────────────
ISO_RC_DESC = {
    "00": "Aprobada",
    "03": "Comercio inválido",
    "14": "Número de tarjeta inválido",
    "41": "Tarjeta reportada como extraviada",
    "43": "Tarjeta reportada como robada",
    "51": "Fondos insuficientes",
    "54": "Tarjeta vencida",
    "55": "NIP incorrecto",
    "57": "Transacción no permitida para la tarjeta",
    "59": "Sospecha de fraude",
    "61": "Excede el límite de monto",
    "62": "Tarjeta restringida",
    "65": "Excede el límite de frecuencia de uso",
    "75": "Excedido el número de intentos de NIP",
    "78": "Tarjeta bloqueada o sin activar en su primer uso",
    "82": "CVV incorrecto",
    "96": "Falla del sistema",
}

# Semantica de las funciones mas relevantes del autorizador
FUNCION_DESC = {
    "Autoriza": "Orquestador principal del ciclo de autorizacion",
    "RxAutorizaTransaccion": "Ejecuta la secuencia de validaciones de negocio de la transaccion",
    "GetTypeOfTransaction": "Clasifica la transaccion por producto, tipo de mensaje ISO y monto",
    "ExecuteSP": "Invoca el stored procedure del core Informix que aplica el movimiento",
    "BuildHostMessage": "Arma la llamada al core con los parametros de la transaccion",
    "BuiltClientMessage": "Arma el mensaje ISO 8583 de respuesta hacia la red",
    "dbGetandValidateHostResponse": "Traduce el codigo de retorno del core al codigo de respuesta ISO",
    "dbGetStatusTarjeta": "Consulta el estatus vigente de la tarjeta",
    "dbGetProductoTarjeta": "Resuelve el producto comercial al que pertenece la tarjeta",
    "dbGetTipoTarjeta": "Determina si el BIN es propio de BanCoppel o de otro emisor",
    "dbValidaComercioDudoso": "Verifica si el comercio esta marcado como dudoso",
    "dbValidateGiroDeNegocio": "Valida el giro de negocio (MCC) del comercio",
    "dbAfiliacionCOF_NO_Permitida": "Verifica si la afiliacion tiene prohibido el cargo con tarjeta en archivo",
    "dbGetPermiteTransaccionesDigitadas": "Verifica si la tarjeta admite transacciones digitadas",
    "ValidateServiceCode": "Valida el codigo de servicio de la banda de la tarjeta",
    "ValidateDigitoVerificador": "Valida el digito verificador del numero de tarjeta (Luhn)",
    "bTarjetaVIP": "Determina si la tarjeta pertenece a un cliente VIP",
    "dbGetDataHsmCard": "Obtiene del HSM los datos criptograficos de la tarjeta",
    "dbInsertMovimiento": "Registra el movimiento en el core antes de autorizar",
    "dbUpdateMovimientoSeAutorizo": "Marca el resultado de la autorizacion sobre el movimiento",
    "dbRegistraTarjeta_Rechazos": "Registra el rechazo en la bitacora de la tarjeta",
    "dbCobroComisionEnLinea": "Aplica el cobro de comision en linea cuando corresponde",
    "dbGetMontoParametros": "Recupera los parametros de monto aplicables a la transaccion",
    "dbGetCuentaTarjeta": "Resuelve la cuenta asociada a la tarjeta",
    "dbEsTarjetaAdicional": "Determina si la tarjeta es adicional de un titular",
    "dbGetSoportaCVV2Dinamico": "Verifica si la tarjeta soporta CVV2 dinamico",
    "dbGetDescriptionPEM": "Resuelve la descripcion del modo de entrada en el punto de venta",
    "dbRegistraMovimientoCOF": "Registra el movimiento de tarjeta en archivo (card on file)",
    "dbTransformaTransaccion": "Transforma el tipo de transaccion para la respuesta al cliente",
}

# Que valida cada resultado del HSM y que significa su codigo
HSM_CAMPO_DESC = {
    "PINRc": "Verificacion del NIP",
    "CVCRc": "Verificacion del CVV de banda o chip",
    "CVC2Rc": "Verificacion del CVV2 impreso en la tarjeta",
    "ARQCRc": "Verificacion del criptograma EMV de la tarjeta",
    "CAVVRc": "Verificacion del valor de autenticacion 3D Secure",
    "EMVScriptRc": "Resultado del script EMV enviado a la tarjeta",
}

HSM_VALOR_DESC = {
    "FF": "No aplica a esta transaccion",
    "00": "Valido",
    "01": "Invalido",
    "A2": "Error en la verificacion",
    "(vacio)": "Sin valor en el mensaje",
}

CATEGORIA_DESC = {
    "orquestacion": "Orquestacion del ciclo de autorizacion",
    "validacion": "Validacion de negocio sobre tarjeta, comercio o transaccion",
    "acceso-datos": "Acceso a datos del core y catalogos",
    "construccion-mensaje": "Construccion de mensajes ISO 8583 y de host",
    "invocacion-core": "Invocacion de stored procedures del core Informix",
    "otro": "Soporte y utilidades",
}


# ─────────────────────────────────────────────────────────────────
# 1. Regla B12 — preservar el seed
# ─────────────────────────────────────────────────────────────────

def preserve_seed(db_path):
    """
    Rescata cross_dependencies y signals sembrados por OTROS brains.

    Solo se preserva lo ajeno: las dependencias y señales que este mismo pipeline
    produjo se recalculan en cada build. Sin ese filtro, cada rebuild acumularia
    copias de su propia salida.
    """
    if not db_path.exists():
        return {"cross_dependencies": [], "signals": [], "system_info": None}
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    rescate = {"cross_dependencies": [], "signals": [], "system_info": None}
    consultas = {
        # evidence_batch poblado = lo genero este pipeline desde los logs
        "cross_dependencies": "SELECT * FROM cross_dependencies WHERE evidence_batch IS NULL",
        "signals": f"SELECT * FROM signals WHERE source_system != '{SYSTEM_ID}'",
    }
    for tabla, sql in consultas.items():
        try:
            rescate[tabla] = [dict(r) for r in con.execute(sql)]
        except sqlite3.OperationalError:
            # brain seed original: sin la columna evidence_batch
            try:
                rescate[tabla] = [dict(r) for r in con.execute(f"SELECT * FROM {tabla}")]
            except sqlite3.OperationalError:
                pass
    try:
        fila = con.execute("SELECT * FROM system_info").fetchone()
        rescate["system_info"] = dict(fila) if fila else None
    except sqlite3.OperationalError:
        pass
    con.close()
    return rescate


# ─────────────────────────────────────────────────────────────────
# 2. Schema
# ─────────────────────────────────────────────────────────────────

SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    slug TEXT PRIMARY KEY, display_name TEXT, togaf_type TEXT, togaf_state TEXT,
    togaf_abb TEXT, seeded_by TEXT, seeded_at TEXT, seed_version TEXT,
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

-- Catalogo ETB embebido (Regla B2)
CREATE TABLE IF NOT EXISTS etb_l1 (id TEXT PRIMARY KEY, name TEXT);
CREATE TABLE IF NOT EXISTS etb_l2 (id TEXT PRIMARY KEY, l1_id TEXT, name TEXT);
CREATE TABLE IF NOT EXISTS etb_l3 (
    id TEXT PRIMARY KEY, l2_id TEXT, l1_id TEXT, name TEXT, definition TEXT,
    bcop_status TEXT, coverage_rationale TEXT, etb_version TEXT
);

-- Trazabilidad de la evidencia
CREATE TABLE IF NOT EXISTS log_batches (
    batch TEXT PRIMARY KEY, extractor TEXT, extractor_version TEXT, extracted_at TEXT,
    files INTEGER, lines INTEGER, transactions INTEGER,
    window_start TEXT, window_end TEXT, window_minutes REAL
);
CREATE TABLE IF NOT EXISTS log_files (
    batch TEXT, filename TEXT, bytes INTEGER, lines INTEGER, transactions INTEGER,
    sha256_prefix TEXT, PRIMARY KEY (batch, filename)
);

-- Conocimiento de negocio
--
-- Todas estas tablas llevan evidence_batch en la clave primaria: cada lote de
-- log es una observacion independiente y se conserva como tal. Agregarlas en
-- una sola fila mezclaria ventanas distintas en la misma celda, que es lo que
-- prohibe la regla de trazabilidad de Informix. La agregacion se hace al
-- consultar (brain.py), no al guardar.
CREATE TABLE IF NOT EXISTS validations (
    validation_id TEXT, executions INTEGER, coverage_pct REAL,
    avg_position REAL, in_declined INTEGER, declined_pct REAL,
    transaction_types TEXT, meaning TEXT, evidence_batch TEXT,
    PRIMARY KEY (validation_id, evidence_batch)
);

CREATE TABLE IF NOT EXISTS authorizer_functions (
    name TEXT, category TEXT, invocations INTEGER,
    calls_per_txn REAL, avg_ms REAL, max_ms INTEGER,
    transaction_types TEXT, description TEXT, evidence_batch TEXT,
    PRIMARY KEY (name, evidence_batch)
);

CREATE TABLE IF NOT EXISTS transaction_types (
    label TEXT, tipotran TEXT, messtype TEXT, product TEXT, volume INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (label, tipotran, messtype, product, evidence_batch)
);

CREATE TABLE IF NOT EXISTS transaction_outcomes (
    label TEXT, outcome TEXT, iso_rc TEXT, volume INTEGER, evidence_batch TEXT,
    PRIMARY KEY (label, outcome, iso_rc, evidence_batch)
);

CREATE TABLE IF NOT EXISTS response_codes (
    iso_rc TEXT, description TEXT, volume INTEGER, share_pct REAL,
    evidence_batch TEXT,
    PRIMARY KEY (iso_rc, evidence_batch)
);

-- La regla de traduccion core -> red de marca
CREATE TABLE IF NOT EXISTS host_response_map (
    host_code TEXT, iso_rc TEXT, volume INTEGER, evidence_batch TEXT,
    core_meaning TEXT, core_convention TEXT, core_confidence REAL,
    PRIMARY KEY (host_code, iso_rc, evidence_batch)
);

-- La base forma parte de la identidad del procedure: el mismo nombre existe
-- replicado en varias bases del core y el autorizador llama a mas de una.
-- Cadena vacia cuando el log invoca sin prefijo.
CREATE TABLE IF NOT EXISTS informix_sp_calls (
    sp_name TEXT, database TEXT NOT NULL DEFAULT '', invocations INTEGER,
    calls_per_txn REAL, transaction_types TEXT, evidence_batch TEXT,
    PRIMARY KEY (sp_name, database, evidence_batch)
);

CREATE TABLE IF NOT EXISTS pos_entry_modes (
    code TEXT, description TEXT, volume INTEGER, share_pct REAL,
    evidence_batch TEXT,
    PRIMARY KEY (code, evidence_batch)
);

CREATE TABLE IF NOT EXISTS merchant_categories (
    mcc TEXT, volume INTEGER, transaction_types TEXT, evidence_batch TEXT,
    PRIMARY KEY (mcc, evidence_batch)
);

CREATE TABLE IF NOT EXISTS iso_tokens (
    token TEXT, status TEXT, volume INTEGER, evidence_batch TEXT,
    PRIMARY KEY (token, status, evidence_batch)
);

CREATE TABLE IF NOT EXISTS context_flags (
    flag TEXT, volume INTEGER, share_pct REAL,
    transaction_types TEXT, evidence_batch TEXT,
    PRIMARY KEY (flag, evidence_batch)
);

CREATE TABLE IF NOT EXISTS card_bins (
    bin TEXT, volume INTEGER, evidence_batch TEXT,
    PRIMARY KEY (bin, evidence_batch)
);

-- Resultados criptograficos que el autorizador recibe YA CALCULADOS.
-- Quien los calcula es InterAct, el front-end ISO, segun su politica por canal.
-- El valor FF significa que esa validacion no aplica a la transaccion.
CREATE TABLE IF NOT EXISTS hsm_results (
    field TEXT, value TEXT, meaning TEXT, volume INTEGER, evidence_batch TEXT,
    PRIMARY KEY (field, value, evidence_batch)
);

-- Donde se aplica de verdad cada validacion criptografica, por tipo de transaccion
CREATE TABLE IF NOT EXISTS hsm_applied (
    field TEXT, transaction_type TEXT, volume INTEGER, evidence_batch TEXT,
    PRIMARY KEY (field, transaction_type, evidence_batch)
);

CREATE TABLE IF NOT EXISTS evidence_samples (
    id INTEGER PRIMARY KEY AUTOINCREMENT, iso_rc TEXT, sample TEXT, evidence_batch TEXT
);
"""

FTS = """
DROP TABLE IF EXISTS knowledge_fts;
CREATE VIRTUAL TABLE knowledge_fts USING fts5(kind, key, text);
"""


def create_schema(con, reset):
    if reset:
        for t in ("system_info", "cross_dependencies", "signals", "etb_l1", "etb_l2", "etb_l3",
                  "log_batches", "log_files", "validations", "authorizer_functions",
                  "transaction_types", "transaction_outcomes", "response_codes",
                  "host_response_map", "informix_sp_calls", "pos_entry_modes",
                  "merchant_categories", "iso_tokens", "context_flags", "card_bins",
                  "evidence_samples", "hsm_results", "hsm_applied"):
            con.execute(f"DROP TABLE IF EXISTS {t}")
    con.executescript(SCHEMA)


# ─────────────────────────────────────────────────────────────────
# 3. ETB (Regla B2)
# ─────────────────────────────────────────────────────────────────

def load_etb(con):
    if not ETB_PATH.exists():
        print("  [!] etb-capabilities.json ausente — se omite el catalogo ETB")
        return 0
    data = json.loads(ETB_PATH.read_text(encoding="utf-8"))
    version = data.get("meta", {}).get("version", "1.0")
    l1, l2 = {}, {}
    filas = []
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


# ─────────────────────────────────────────────────────────────────
# 4-5. Conocimiento desde los lotes de log
# ─────────────────────────────────────────────────────────────────

def ms_a_hora(ms):
    if ms is None:
        return None
    s, msr = divmod(int(ms), 1000)
    h, resto = divmod(s, 3600)
    m, s = divmod(resto, 60)
    return f"{h:02d}:{m:02d}:{s:02d}.{msr:03d}"


def load_batches(con, lotes):
    for d in lotes:
        fuentes = d["fuentes"]
        a = d["agregados"]
        ini = min((f["ts_min_ms"] for f in fuentes if f["ts_min_ms"] is not None), default=None)
        fin = max((f["ts_max_ms"] for f in fuentes if f["ts_max_ms"] is not None), default=None)
        minutos = round((fin - ini) / 60000, 2) if (ini is not None and fin is not None) else None
        con.execute(
            "INSERT OR REPLACE INTO log_batches VALUES (?,?,?,?,?,?,?,?,?,?)",
            (d["lote"], d["extractor"], d["extractor_version"], d["generado"],
             len(fuentes), sum(f["lineas"] for f in fuentes), a.get("n_tx", 0),
             ms_a_hora(ini), ms_a_hora(fin), minutos))
        con.executemany(
            "INSERT OR REPLACE INTO log_files VALUES (?,?,?,?,?,?)",
            [(d["lote"], f["archivo"], f["bytes"], f["lineas"], f["transacciones"],
              f["sha256_prefijo"]) for f in fuentes])


def top_json(contador, n=6):
    """Serializa los N valores mas frecuentes de un dict {clave: conteo}."""
    return json.dumps(dict(sorted(contador.items(), key=lambda x: -x[1])[:n]), ensure_ascii=False)


def load_knowledge(con, lotes):
    for d in lotes:
        lote = d["lote"]
        a = d["agregados"]
        n_tx = a.get("n_tx", 0) or 1

        # Idempotencia sin --reset: evidence_samples no tiene clave natural
        con.execute("DELETE FROM evidence_samples WHERE evidence_batch = ?", (lote,))

        # Validaciones de negocio
        orden = a.get("validacion_orden", {})
        rechazo = a.get("validacion_en_rechazo", {})
        por_tipo = a.get("validacion_por_tipo", {})
        con.executemany(
            "INSERT OR REPLACE INTO validations VALUES (?,?,?,?,?,?,?,?,?)",
            [(vid, n, round(100 * n / n_tx, 2),
              round(orden.get(vid, 0) / n, 1) if n else None,
              rechazo.get(vid, 0),
              round(100 * rechazo.get(vid, 0) / n, 2) if n else None,
              top_json(por_tipo.get(vid, {})), None, lote)
             for vid, n in a.get("validaciones", {}).items()])

        # Funciones del autorizador
        from_ms = a.get("funcion_ms", {})
        max_ms = a.get("funcion_max_ms", {})
        fpor_tipo = a.get("funcion_por_tipo", {})
        filas = []
        for nombre, n in a.get("funciones", {}).items():
            categoria = ("acceso-datos" if nombre.startswith("db") else
                         "validacion" if nombre.startswith(("Validate", "bTarjeta")) else
                         "construccion-mensaje" if nombre.startswith(("Build", "Built")) else
                         "invocacion-core" if nombre.startswith("Execute") else
                         "orquestacion" if nombre in ("Autoriza", "RxAutorizaTransaccion", "GetTypeOfTransaction")
                         else "otro")
            filas.append((nombre, categoria, n, round(n / n_tx, 2),
                          round(from_ms.get(nombre, 0) / n, 2) if n else None,
                          max_ms.get(nombre), top_json(fpor_tipo.get(nombre, {})),
                          FUNCION_DESC.get(nombre), lote))
        con.executemany("INSERT OR REPLACE INTO authorizer_functions VALUES (?,?,?,?,?,?,?,?,?)", filas)

        # Tipos de transaccion y resultados
        con.executemany(
            "INSERT OR REPLACE INTO transaction_types VALUES (?,?,?,?,?,?)",
            [(*k.split("|"), v, lote) for k, v in a.get("tx", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO transaction_outcomes VALUES (?,?,?,?,?)",
            [(*k.split("|"), v, lote) for k, v in a.get("tx_resultado", {}).items()])

        # Codigos de respuesta
        total_rc = sum(a.get("iso_rc", {}).values()) or 1
        con.executemany(
            "INSERT OR REPLACE INTO response_codes VALUES (?,?,?,?,?)",
            [(rc, ISO_RC_DESC.get(rc, "Sin catalogar"), n, round(100 * n / total_rc, 2), lote)
             for rc, n in a.get("iso_rc", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO host_response_map "
            "(host_code, iso_rc, volume, evidence_batch) VALUES (?,?,?,?)",
            [(*k.split("|"), v, lote) for k, v in a.get("mapeo_codigos", {}).items()])

        # Stored procedures del core
        spor_tipo = a.get("sp_por_tipo", {})
        filas = []
        for sp, n in a.get("sps", {}).items():
            base, _, nombre = sp.partition(":")
            db, sp_name = (base, nombre) if nombre else ("", base)
            filas.append((sp_name, db, n, round(n / n_tx, 2), top_json(spor_tipo.get(sp, {})), lote))
        con.executemany("INSERT OR REPLACE INTO informix_sp_calls VALUES (?,?,?,?,?,?)", filas)

        # Catalogos
        total_pem = sum(a.get("pem", {}).values()) or 1
        descs = a.get("pem_desc", {})
        con.executemany(
            "INSERT OR REPLACE INTO pos_entry_modes VALUES (?,?,?,?,?)",
            [(c, descs.get(c), n, round(100 * n / total_pem, 2), lote)
             for c, n in a.get("pem", {}).items()])
        mpor_tipo = a.get("mcc_por_tipo", {})
        con.executemany(
            "INSERT OR REPLACE INTO merchant_categories VALUES (?,?,?,?)",
            [(m, n, top_json(mpor_tipo.get(m, {})), lote) for m, n in a.get("mcc", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO iso_tokens VALUES (?,?,?,?)",
            [(*k.split("|"), v, lote) for k, v in a.get("tokens", {}).items()])
        fpor_tipo = a.get("flags_por_tipo", {})
        con.executemany(
            "INSERT OR REPLACE INTO context_flags VALUES (?,?,?,?,?)",
            [(f, n, round(100 * n / n_tx, 2), top_json(fpor_tipo.get(f, {})), lote)
             for f, n in a.get("flags", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO card_bins VALUES (?,?,?)",
            [(b, n, lote) for b, n in a.get("bins", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO hsm_results VALUES (?,?,?,?,?)",
            [(*k.split("|"), HSM_VALOR_DESC.get(k.split("|")[1], "Sin catalogar"), v, lote)
             for k, v in a.get("hsm", {}).items()])
        con.executemany(
            "INSERT OR REPLACE INTO hsm_applied VALUES (?,?,?,?)",
            [(campo, tipo, v, lote)
             for campo, dist in a.get("hsm_por_tipo", {}).items()
             for tipo, v in dist.items()])
        con.executemany(
            "INSERT INTO evidence_samples (iso_rc, sample, evidence_batch) VALUES (?,?,?)",
            [(rc, json.dumps(m, ensure_ascii=False), lote)
             for rc, muestras in a.get("evidencia", {}).items() for m in muestras])


# ─────────────────────────────────────────────────────────────────
# 5b. Enriquecimiento cross-brain del mapeo de codigos
# ─────────────────────────────────────────────────────────────────

INFORMIX_DB = (SYSTEM_DIR.parent.parent / "core" / "Informix" / "digital-brain" / "brain.db")


def enrich_host_codes(con):
    """
    Cruza los CodRet del core contra el codret_dictionary del brain de Informix
    (329 codigos) y guarda el significado localmente — el brain sigue siendo
    autosuficiente (Regla B1): se lee en build, no en runtime.

    El autorizador emite el codigo con relleno a 5 digitos ('00400'); el
    diccionario registra ambas convenciones ('400' y '00400'), asi que se
    busca primero el literal y despues el valor sin ceros a la izquierda.
    """
    if not INFORMIX_DB.exists():
        print("  [!] brain de Informix ausente — mapeo de codigos sin enriquecer")
        return 0
    src = sqlite3.connect(f"file:{INFORMIX_DB}?mode=ro", uri=True)
    enriquecidos = 0
    for (code,) in list(con.execute("SELECT DISTINCT host_code FROM host_response_map")):
        fila = None
        for candidato in (code, code.lstrip("0") or "0"):
            fila = src.execute(
                "SELECT description_es, convention, confidence FROM codret_dictionary WHERE code = ?",
                (candidato,)).fetchone()
            if fila:
                break
        if fila:
            con.execute(
                "UPDATE host_response_map SET core_meaning=?, core_convention=?, core_confidence=? "
                "WHERE host_code=?", (fila[0], fila[1], fila[2], code))
            enriquecidos += 1
    src.close()
    return enriquecidos


# ─────────────────────────────────────────────────────────────────
# 6. Regla B10 — dependencias con evidencia
# ─────────────────────────────────────────────────────────────────

def load_dependencies(con, rescate, lotes):
    # Primero se restituye el seed intacto (B12)
    for dep in rescate["cross_dependencies"]:
        con.execute(
            "INSERT OR REPLACE INTO cross_dependencies "
            "(id, other_system, relationship, direction, volume, domains, regulation, "
            " description, criticality, origin_artifact, seeded_at, evidence_batch) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (dep["id"], dep["other_system"], dep["relationship"], dep["direction"],
             dep.get("volume", 0), dep.get("domains", "[]"), dep.get("regulation", "[]"),
             dep.get("description"), dep.get("criticality", "unknown"),
             dep.get("origin_artifact"), dep.get("seeded_at"), None))

    # Ahora se enriquece con la evidencia del log
    total = {}
    lote_ref = None
    for d in lotes:
        lote_ref = d["lote"]
        for sp, n in d["agregados"].get("sps", {}).items():
            total[sp] = total.get(sp, 0) + n
    if not total:
        return

    sps = sorted(total.items(), key=lambda x: -x[1])
    detalle = ", ".join(f"{sp} ({n:,} llamadas)" for sp, n in sps)
    con.execute(
        "INSERT OR REPLACE INTO cross_dependencies "
        "(id, other_system, relationship, direction, volume, domains, regulation, "
        " description, criticality, origin_artifact, seeded_at, evidence_batch) "
        "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        ("eglobal-informix-sp", "informix", "calls", "outbound", sum(total.values()),
         json.dumps(["D16", "D08"]), json.dumps(["PCI-DSS"]),
         "El autorizador invoca stored procedures del core Informix para aplicar cada "
         f"movimiento de tarjeta. Evidencia de log de produccion: {detalle}.",
         "critical", f"source/logs/{lote_ref}", TS_NOW, lote_ref))

    # Regla B10: InterAct es quien entrega el mensaje y precalcula el HSM
    hsm = con.execute(
        "SELECT COUNT(*) FROM hsm_results WHERE value != 'FF'").fetchone()[0]
    if hsm:
        con.execute(
            "INSERT OR REPLACE INTO cross_dependencies "
            "(id, other_system, relationship, direction, volume, domains, regulation, "
            " description, criticality, origin_artifact, seeded_at, evidence_batch) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            ("eglobal-interact", "interact", "calls", "inbound", 0,
             json.dumps(["D16"]), json.dumps(["PCI-DSS"]),
             "InterAct entrega al autorizador cada solicitud de la red y, antes de hacerlo, "
             "ejecuta en el HSM la validacion criptografica que corresponde al canal. El "
             "autorizador no calcula PIN, CVV, CVV2 ni criptograma EMV: los recibe resueltos "
             "en PINRc, CVCRc, CVC2Rc, ARQCRc y CAVVRc, y sus propias validaciones son de "
             "negocio. Verificado contra la politica en prosa del modulo intersec.",
             "critical", f"source/logs/{lote_ref}", TS_NOW, lote_ref))


# ─────────────────────────────────────────────────────────────────
# 7-8. FTS y señales
# ─────────────────────────────────────────────────────────────────

def build_fts(con):
    """Indice de busqueda. Se agrupa por entidad: un lote mas no es un termino mas."""
    con.executescript(FTS)
    filas = []
    for nombre, cat, desc in con.execute(
            "SELECT name, category, COALESCE(MAX(description),'') FROM authorizer_functions "
            "GROUP BY name, category"):
        filas.append(("funcion", nombre, f"{nombre} {cat} {desc}"))
    for vid, tipos in con.execute(
            "SELECT validation_id, GROUP_CONCAT(transaction_types) FROM validations "
            "GROUP BY validation_id"):
        filas.append(("validacion", vid, f"validacion {vid} {tipos}"))
    for rc, desc in con.execute(
            "SELECT iso_rc, MAX(description) FROM response_codes GROUP BY iso_rc"):
        filas.append(("codigo-respuesta", rc, f"{rc} {desc}"))
    for sp, db in con.execute(
            "SELECT sp_name, database FROM informix_sp_calls GROUP BY sp_name, database"):
        filas.append(("stored-procedure", f"{db}:{sp}" if db else sp,
                      f"{sp} {db} informix core"))
    for l3, nombre, defi, estado in con.execute(
            "SELECT id, name, COALESCE(definition,''), bcop_status FROM etb_l3 WHERE bcop_status != 'NOT_ASSESSED'"):
        filas.append(("capability", l3, f"{l3} {nombre} {defi} {estado}"))
    con.executemany("INSERT INTO knowledge_fts (kind, key, text) VALUES (?,?,?)", filas)
    return len(filas)


def emit_signals(con, rescate):
    # Idempotencia sin --reset: se recalculan las propias, se respetan las ajenas
    con.execute("DELETE FROM signals WHERE source_system = ?", (SYSTEM_ID,))
    for s in rescate["signals"]:
        con.execute(
            "INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at) "
            "VALUES (?,?,?,?,?)",
            (s["signal_type"], s["source_system"], s.get("value", 0),
             s.get("metadata", "{}"), s.get("seeded_at")))

    def escalar(sql):
        return con.execute(sql).fetchone()[0] or 0

    n_tx = escalar("SELECT SUM(transactions) FROM log_batches")
    aprobadas = escalar("SELECT COALESCE(SUM(volume),0) FROM transaction_outcomes WHERE iso_rc='00'")
    lotes = escalar("SELECT COUNT(*) FROM log_batches")
    señales = [
        ("transacciones_observadas", n_tx, {"fuente": "logs de produccion", "lotes": lotes}),
        ("validaciones_de_negocio",
         escalar("SELECT COUNT(DISTINCT validation_id) FROM validations"), {}),
        ("funciones_autorizador",
         escalar("SELECT COUNT(DISTINCT name) FROM authorizer_functions"), {}),
        ("stored_procedures_core",
         escalar("SELECT COUNT(*) FROM (SELECT DISTINCT sp_name, database FROM informix_sp_calls)"),
         {}),
        ("codigos_respuesta_iso",
         escalar("SELECT COUNT(DISTINCT iso_rc) FROM response_codes"), {}),
        ("giros_de_negocio",
         escalar("SELECT COUNT(DISTINCT mcc) FROM merchant_categories"), {}),
        ("reglas_traduccion_codigo",
         escalar("SELECT COUNT(DISTINCT host_code || '>' || iso_rc) FROM host_response_map"), {}),
        ("tasa_aprobacion_pct", round(100 * aprobadas / n_tx, 2) if n_tx else 0,
         {"aprobadas": aprobadas, "total": n_tx}),
    ]
    for tipo, valor, meta in señales:
        con.execute(
            "INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at) "
            "VALUES (?,?,?,?,?)",
            (tipo, SYSTEM_ID, int(valor), json.dumps(meta, ensure_ascii=False), TS_NOW))


# ─────────────────────────────────────────────────────────────────
# 9. Regla B11 — emitir seeds
# ─────────────────────────────────────────────────────────────────

def emit_seeds(con):
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    sps = [{"id": f"{db}:{sp}" if db else sp, "name": sp, "database": db, "invocations": n}
           for sp, db, n in con.execute(
               "SELECT sp_name, database, SUM(invocations) AS n FROM informix_sp_calls "
               "GROUP BY sp_name, database ORDER BY n DESC")]
    lotes = [r[0] for r in con.execute("SELECT batch FROM log_batches ORDER BY batch")]
    lote = lotes[-1] if lotes else None
    seed = {
        "source_system": SYSTEM_ID,
        "source_togaf_type": "integration",
        "target_system": "informix",
        "target_togaf_type": "core",
        "generated_at": TS_NOW[:10],
        "source_version": f"e-global v{VERSION}",
        "relationship": "calls",
        "evidence": {
            "component_count": len(sps),
            "components": sps,
            "volume": sum(s["invocations"] for s in sps),
            "domains": ["D16", "D08"],
            "regulation": ["PCI-DSS"],
            "origin_artifact": ", ".join(f"source/logs/{x}" for x in lotes),
        },
    }
    (SEEDS_DIR / "informix-seed.json").write_text(
        json.dumps(seed, ensure_ascii=False, indent=1), encoding="utf-8")
    manifest = {
        "emitter": SYSTEM_ID,
        "generated_at": TS_NOW,
        "source_version": f"e-global v{VERSION}",
        "seeds": [{"target": "informix", "file": "informix-seed.json",
                   "evidence_count": len(sps)}],
    }
    (SEEDS_DIR / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1), encoding="utf-8")
    return len(sps)


# ─────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description="Construye el brain de e-global")
    ap.add_argument("--reset", action="store_true", help="reconstruye desde cero")
    args = ap.parse_args()

    lotes = []
    for p in sorted(DATA_DIR.glob("*.json")):
        lotes.append(json.loads(p.read_text(encoding="utf-8")))
    if not lotes:
        print(f"[!] sin datos en {DATA_DIR} — ejecuta antes generators/parse-authorizerj.py")
        return 1

    print(f"e-global brain v{VERSION}")
    rescate = preserve_seed(DB_PATH)
    print(f"  seed preservado: {len(rescate['cross_dependencies'])} dependencias · "
          f"{len(rescate['signals'])} señales")

    con = sqlite3.connect(DB_PATH)
    con.execute("PRAGMA journal_mode=WAL")
    create_schema(con, args.reset)

    info = rescate["system_info"] or {}
    con.execute(
        "INSERT OR REPLACE INTO system_info VALUES (?,?,?,?,?,?,?,?,?,?)",
        (SYSTEM_ID, "e-global — Autorizador de pagos", "integration", "baseline",
         "payment-authorization", info.get("seeded_by", '["informix"]'),
         info.get("seeded_at"), info.get("seed_version"), VERSION, TS_NOW))

    n_etb = load_etb(con)
    print(f"  ETB embebido: {n_etb} capacidades L3")
    load_batches(con, lotes)
    load_knowledge(con, lotes)
    n_cod = enrich_host_codes(con)
    print(f"  codigos del core enriquecidos contra Informix: {n_cod}")
    load_dependencies(con, rescate, lotes)
    n_fts = build_fts(con)
    emit_signals(con, rescate)
    con.commit()
    n_seed = emit_seeds(con)

    print("\n  conocimiento cargado:")
    for tabla in ("log_batches", "validations", "authorizer_functions", "transaction_types",
                  "transaction_outcomes", "response_codes", "host_response_map",
                  "informix_sp_calls", "pos_entry_modes", "merchant_categories",
                  "iso_tokens", "context_flags", "card_bins", "hsm_results",
                  "hsm_applied", "evidence_samples", "cross_dependencies", "signals"):
        n = con.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]
        print(f"    {tabla:24s} {n:>7,}")
    print(f"    {'knowledge_fts':24s} {n_fts:>7,}")
    print(f"\n  seeds emitidos (B11): informix-seed.json con {n_seed} stored procedures")
    con.close()
    print(f"  -> {DB_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

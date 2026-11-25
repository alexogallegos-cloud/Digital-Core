#!/usr/bin/env python3
"""
build-brain.py — BUS Digital Brain
BanCoppel Application Modernization · SPE-AM-001

El BUS (IBM Integration Bus) es el bus de servicios empresarial del banco.
Este pipeline construye su brain desde lo que destila `generators/parse-bus.py`.

Reglas AM aplicadas: B1 (autosuficiente), B2 (ETB embebido), B5 y B10
(dependencias en ambos lados), B11 (emite seeds), B12 (preserva seed).

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
INFORMIX_DB = SYSTEM_DIR.parent.parent / "core" / "Informix" / "digital-brain" / "brain.db"

SYSTEM_ID = "bus"
VERSION = "1.0.0"
TS_NOW = datetime.now(timezone.utc).isoformat()

# El catalogo ETB describe capacidades de NEGOCIO. Un bus de integracion no es
# una de ellas: es el habilitador tecnico por el que otros sistemas ejercen las
# suyas. Por eso no se marca ninguna L3 como propia; su aporte se ve en las
# capacidades de los sistemas que conecta. El catalogo se embebe igual, porque
# es el vocabulario compartido de la flota (Regla B2).
ETB_COBERTURA = {}

# Datasource del BUS -> base Informix
DATASOURCE_DESC = {
    "ifx_bdinteg": "Integracion, dominio D02",
    "ifx_bdicheq": "Captacion y cheques, dominio D04",
    "ifx_bdicred": "Credito, dominio D03",
    "ifx_bdisac_remesas": "Remesas",
    "ifx_bdicobranza": "Cobranza",
    "ifx_bdisolic": "Solicitudes",
    "ifx_bdicheq_sd": "Captacion, sobres digitales",
    "ifx_bdinteg_inyau": "Integracion, inscripcion y autorizacion",
    "ifx_bdisac": "Servicios al cliente",
    "ifx_intercard": "Tarjetas, dominio D16",
    "ifx_bdidigital": "Canales digitales",
    "ifx_bdiadminnomina": "Administracion de nomina",
    "ifx_bdidomi": "Domiciliacion",
    "": "Sin datasource declarado en el trama",
}


def preserve_seed(db_path):
    if not db_path.exists():
        return {"cross_dependencies": [], "signals": []}
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    r = {"cross_dependencies": [], "signals": []}
    for tabla, sql in {
        "cross_dependencies": "SELECT * FROM cross_dependencies WHERE evidence_batch IS NULL",
        "signals": f"SELECT * FROM signals WHERE source_system != '{SYSTEM_ID}'",
    }.items():
        try:
            r[tabla] = [dict(x) for x in con.execute(sql)]
        except sqlite3.OperationalError:
            pass
    con.close()
    return r


SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    slug TEXT PRIMARY KEY, display_name TEXT, togaf_type TEXT, togaf_state TEXT,
    togaf_abb TEXT, product TEXT, brain_version TEXT, built_at TEXT
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
    files INTEGER, lines INTEGER, traces INTEGER, errors INTEGER, error_pct REAL,
    window_start TEXT, window_end TEXT
);
CREATE TABLE IF NOT EXISTS log_files (
    batch TEXT, filename TEXT, kind TEXT, node TEXT, hour TEXT, bytes INTEGER,
    lines INTEGER, traces INTEGER, sha256_prefix TEXT,
    PRIMARY KEY (batch, filename, node)
);

CREATE TABLE IF NOT EXISTS services (
    service TEXT, calls INTEGER, errors INTEGER, error_pct REAL, evidence_batch TEXT,
    PRIMARY KEY (service, evidence_batch)
);

-- El campo sistemaOrigen no esta disciplinado: se conserva el valor crudo con
-- su clasificacion, para que nadie lo cuente como inventario de sistemas.
CREATE TABLE IF NOT EXISTS origin_systems (
    value TEXT, class TEXT, family TEXT, calls INTEGER, errors INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (value, evidence_batch)
);

-- La dependencia cuantificada con el core
CREATE TABLE IF NOT EXISTS informix_sp_calls (
    datasource TEXT NOT NULL DEFAULT '', sp_name TEXT, calls INTEGER, errors INTEGER,
    error_pct REAL, exists_in_core INTEGER, core_db TEXT, core_domain TEXT,
    core_fan_in INTEGER, core_biz TEXT, evidence_batch TEXT,
    PRIMARY KEY (datasource, sp_name, evidence_batch)
);

CREATE TABLE IF NOT EXISTS service_sp_map (
    service TEXT, datasource TEXT NOT NULL DEFAULT '', sp_name TEXT, calls INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (service, datasource, sp_name, evidence_batch)
);

CREATE TABLE IF NOT EXISTS operations (
    operation TEXT, calls INTEGER, evidence_batch TEXT,
    PRIMARY KEY (operation, evidence_batch)
);

CREATE TABLE IF NOT EXISTS error_signatures (
    signature TEXT, service TEXT, occurrences INTEGER, evidence_batch TEXT,
    PRIMARY KEY (signature, evidence_batch)
);

CREATE TABLE IF NOT EXISTS hourly_volume (
    hour TEXT, traces INTEGER, errors INTEGER, evidence_batch TEXT,
    PRIMARY KEY (hour, evidence_batch)
);

CREATE TABLE IF NOT EXISTS datasources (
    datasource TEXT, description TEXT, calls INTEGER, sp_count INTEGER,
    evidence_batch TEXT,
    PRIMARY KEY (datasource, evidence_batch)
);
"""

FTS = """
DROP TABLE IF EXISTS knowledge_fts;
CREATE VIRTUAL TABLE knowledge_fts USING fts5(kind, key, text);
"""

TABLAS = ["system_info", "cross_dependencies", "signals", "etb_l1", "etb_l2", "etb_l3",
          "log_batches", "log_files", "services", "origin_systems", "informix_sp_calls",
          "service_sp_map", "operations", "error_signatures", "hourly_volume", "datasources"]


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


def pct(parte, total):
    return round(100.0 * parte / total, 2) if total else 0.0


def load_knowledge(con, lotes):
    for d in lotes:
        lote = d["lote"]
        a = d["agregados"]
        trazas = a.get("trazas", 0)
        errores = sum(a.get("servicios_error", {}).values())
        horas = sorted(a.get("por_hora", {}))

        con.execute("INSERT OR REPLACE INTO log_batches VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                    (lote, d["extractor"], d["extractor_version"], d["generado"],
                     len(d["fuentes"]), sum(f["lineas"] for f in d["fuentes"]),
                     trazas, errores, pct(errores, trazas),
                     horas[0] if horas else None, horas[-1] if horas else None))

        con.execute("DELETE FROM log_files WHERE batch = ?", (lote,))
        con.executemany("INSERT OR REPLACE INTO log_files VALUES (?,?,?,?,?,?,?,?,?)",
                        [(lote, f["archivo"], f["tipo"], f.get("nodo", ""), f["hora"],
                          f["bytes"], f["lineas"], f["trazas"], f["sha256_prefijo"])
                         for f in d["fuentes"]])

        err_srv = a.get("servicios_error", {})
        con.executemany("INSERT OR REPLACE INTO services VALUES (?,?,?,?,?)",
                        [(s, n, err_srv.get(s, 0), pct(err_srv.get(s, 0), n), lote)
                         for s, n in a.get("servicios", {}).items()])

        clases = a.get("origen_clase", {})
        familias = a.get("origen_familia", {})
        err_org = a.get("origenes_error", {})
        con.executemany("INSERT OR REPLACE INTO origin_systems VALUES (?,?,?,?,?,?)",
                        [(v, clases.get(v, "desconocido"), familias.get(v, v), n,
                          err_org.get(v, 0), lote)
                         for v, n in a.get("origenes", {}).items()])

        err_sp = a.get("sp_error", {})
        filas = []
        for k, n in a.get("sp_calls", {}).items():
            ds, _, sp = k.partition("|")
            filas.append((ds, sp, n, err_sp.get(k, 0), pct(err_sp.get(k, 0), n),
                          None, None, None, None, None, lote))
        con.executemany("INSERT OR REPLACE INTO informix_sp_calls VALUES (?,?,?,?,?,?,?,?,?,?,?)",
                        filas)

        filas = []
        for k, n in a.get("servicio_sp", {}).items():
            partes = k.split("|")
            if len(partes) == 3:
                filas.append((partes[0], partes[1], partes[2], n, lote))
        con.executemany("INSERT OR REPLACE INTO service_sp_map VALUES (?,?,?,?,?)", filas)

        con.executemany("INSERT OR REPLACE INTO operations VALUES (?,?,?)",
                        [(o, n, lote) for o, n in a.get("operaciones", {}).items()])

        muestras = a.get("muestras", {})
        con.executemany("INSERT OR REPLACE INTO error_signatures VALUES (?,?,?,?)",
                        [(f, (muestras.get(f) or [{}])[0].get("servicio"), n, lote)
                         for f, n in a.get("firmas", {}).items()])

        err_hora = a.get("por_hora_error", {})
        con.executemany("INSERT OR REPLACE INTO hourly_volume VALUES (?,?,?,?)",
                        [(h, n, err_hora.get(h, 0), lote)
                         for h, n in a.get("por_hora", {}).items()])

        # datasources agregados
        ds_calls, ds_sps = {}, {}
        for k, n in a.get("sp_calls", {}).items():
            ds = k.partition("|")[0]
            ds_calls[ds] = ds_calls.get(ds, 0) + n
            ds_sps[ds] = ds_sps.get(ds, 0) + 1
        con.executemany("INSERT OR REPLACE INTO datasources VALUES (?,?,?,?,?)",
                        [(ds, DATASOURCE_DESC.get(ds, "Sin catalogar"), n,
                          ds_sps.get(ds, 0), lote) for ds, n in ds_calls.items()])


def enrich_against_core(con):
    """
    Cruza cada stored procedure observado contra el brain de Informix.
    Se lee en build y se guarda localmente: el brain sigue siendo
    autosuficiente (Regla B1).
    """
    if not INFORMIX_DB.exists():
        print("  [!] brain de Informix ausente — SPs sin cruzar")
        return 0, 0
    src = sqlite3.connect(f"file:{INFORMIX_DB}?mode=ro", uri=True)
    encontrados = 0
    filas = list(con.execute(
        "SELECT DISTINCT datasource, sp_name FROM informix_sp_calls"))
    for ds, sp in filas:
        # el datasource ifx_bdinteg apunta a la base bdinteg
        base = ds[4:] if ds.startswith("ifx_") else None
        fila = None
        if base:
            fila = src.execute(
                "SELECT db, domain, fan_in, biz FROM sps WHERE name = ? AND db = ?",
                (sp, base)).fetchone()
        if not fila:
            fila = src.execute(
                "SELECT db, domain, fan_in, biz FROM sps WHERE name = ? "
                "ORDER BY fan_in DESC LIMIT 1", (sp,)).fetchone()
        if fila:
            encontrados += 1
            con.execute(
                "UPDATE informix_sp_calls SET exists_in_core=1, core_db=?, core_domain=?, "
                "core_fan_in=?, core_biz=? WHERE datasource=? AND sp_name=?",
                (fila[0], fila[1], fila[2], fila[3], ds, sp))
        else:
            con.execute(
                "UPDATE informix_sp_calls SET exists_in_core=0 "
                "WHERE datasource=? AND sp_name=?", (ds, sp))
    src.close()
    return encontrados, len(filas)


def load_dependencies(con, rescate, lotes):
    for dep in rescate["cross_dependencies"]:
        con.execute("INSERT OR REPLACE INTO cross_dependencies "
                    "(id,other_system,relationship,direction,volume,domains,regulation,"
                    " description,criticality,origin_artifact,seeded_at,evidence_batch) "
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                    (dep["id"], dep["other_system"], dep["relationship"], dep["direction"],
                     dep.get("volume", 0), dep.get("domains", "[]"),
                     dep.get("regulation", "[]"), dep.get("description"),
                     dep.get("criticality", "unknown"), dep.get("origin_artifact"),
                     dep.get("seeded_at"), None))

    lote = lotes[-1]["lote"]
    # La identidad de un procedure aqui es el par (datasource, sp_name): el mismo
    # nombre vive en varias bases. La consulta anterior hacia DISTINCT sobre
    # (sp_name, calls), o sea contaba combinaciones de nombre y conteo, no
    # procedures, e inflaba 615 nombres a 1145 y perdia llamadas en el camino.
    n_sp, n_pares, n_calls = con.execute(
        "SELECT COUNT(DISTINCT sp_name), COUNT(*), SUM(calls) FROM ("
        "  SELECT datasource, sp_name, SUM(calls) AS calls"
        "    FROM informix_sp_calls GROUP BY datasource, sp_name)").fetchone()
    n_ds = con.execute(
        "SELECT COUNT(DISTINCT datasource) FROM informix_sp_calls"
        " WHERE datasource IS NOT NULL AND TRIM(datasource) <> ''").fetchone()[0]
    dominios = [d for (d,) in con.execute(
        "SELECT DISTINCT core_domain FROM informix_sp_calls WHERE core_domain IS NOT NULL "
        "ORDER BY core_domain")]
    con.execute("INSERT OR REPLACE INTO cross_dependencies "
                "(id,other_system,relationship,direction,volume,domains,regulation,"
                " description,criticality,origin_artifact,seeded_at,evidence_batch) "
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                ("bus-informix", "informix", "calls", "outbound", n_calls or 0,
                 json.dumps(dominios), json.dumps([]),
                 f"El BUS invoca {n_sp} stored procedures distintos del core, en "
                 f"{n_pares} pares de datasource y procedure sobre {n_ds} datasources "
                 "declarados. Es la via por la que los canales llegan a Informix sin "
                 "abrir conexiones propias.",
                 "critical", f"source/logs/{lote}", TS_NOW, lote))

    ofi = con.execute(
        "SELECT SUM(calls) FROM origin_systems WHERE family IN ('OFI_WEB','OFIWEB')"
    ).fetchone()[0] or 0
    if ofi:
        con.execute("INSERT OR REPLACE INTO cross_dependencies "
                    "(id,other_system,relationship,direction,volume,domains,regulation,"
                    " description,criticality,origin_artifact,seeded_at,evidence_batch) "
                    "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                    ("bus-siweb", "siweb", "calls", "inbound", ofi,
                     json.dumps([]), json.dumps([]),
                     f"El canal de sucursal origina {ofi:,} invocaciones, la carga principal "
                     "del bus. SIWEB no abre conexiones al core: todo su acceso a datos "
                     "pasa por aqui, contra 858 identificadores de servicio.",
                     "critical", f"source/logs/{lote}", TS_NOW, lote))


def build_fts(con):
    con.executescript(FTS)
    filas = []
    for s, in con.execute("SELECT DISTINCT service FROM services"):
        sps = [r[0] for r in con.execute(
            "SELECT DISTINCT sp_name FROM service_sp_map WHERE service = ? LIMIT 8", (s,))]
        filas.append(("servicio", s, f"{s} " + " ".join(sps)))
    for ds, sp, biz in con.execute(
            "SELECT datasource, sp_name, MAX(COALESCE(core_biz,'')) FROM informix_sp_calls "
            "GROUP BY datasource, sp_name"):
        filas.append(("stored-procedure", f"{ds}:{sp}" if ds else sp,
                      f"{sp} {ds} {biz} informix core"))
    for o, in con.execute("SELECT DISTINCT operation FROM operations"):
        filas.append(("operacion", o, o))
    for v, clase in con.execute(
            "SELECT DISTINCT value, class FROM origin_systems WHERE class = 'sistema'"):
        filas.append(("sistema-origen", v, f"{v} {clase}"))
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

    trazas = n("SELECT SUM(traces) FROM log_batches")
    errores = n("SELECT SUM(errors) FROM log_batches")
    for tipo, valor, meta in [
        ("trazas_observadas", trazas, {}),
        ("servicios", n("SELECT COUNT(DISTINCT service) FROM services"), {}),
        ("stored_procedures_core", n("SELECT COUNT(*) FROM (SELECT DISTINCT datasource, sp_name FROM informix_sp_calls)"), {}),
        ("stored_procedures_confirmados",
         n("SELECT COUNT(*) FROM (SELECT DISTINCT datasource, sp_name FROM informix_sp_calls WHERE exists_in_core=1)"), {}),
        ("pares_servicio_procedure", n("SELECT COUNT(*) FROM (SELECT DISTINCT service, datasource, sp_name FROM service_sp_map)"), {}),
        ("datasources", n("SELECT COUNT(DISTINCT datasource) FROM datasources"), {}),
        ("sistemas_origen_reales",
         n("SELECT COUNT(DISTINCT family) FROM origin_systems WHERE class='sistema'"), {}),
        ("tasa_estatus_error_pct", round(100.0 * errores / trazas) if trazas else 0,
         {"nota": "el campo estatus mezcla falla tecnica con ausencia de datos"}),
    ]:
        con.execute("INSERT INTO signals (signal_type,source_system,value,metadata,seeded_at) "
                    "VALUES (?,?,?,?,?)",
                    (tipo, SYSTEM_ID, int(valor), json.dumps(meta, ensure_ascii=False), TS_NOW))


def emit_seeds(con):
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    lote = con.execute("SELECT batch FROM log_batches ORDER BY batch DESC LIMIT 1").fetchone()
    lote = lote[0] if lote else None

    sps = [{"id": f"{ds}:{sp}" if ds else sp, "name": sp, "datasource": ds,
            "core_db": db, "domain": dom, "calls": c, "errors": e}
           for ds, sp, db, dom, c, e in con.execute(
               "SELECT datasource, sp_name, core_db, core_domain, SUM(calls), SUM(errors) "
               "FROM informix_sp_calls GROUP BY datasource, sp_name "
               "ORDER BY SUM(calls) DESC")]
    seed = {
        "source_system": SYSTEM_ID, "source_togaf_type": "integration",
        "target_system": "informix", "target_togaf_type": "core",
        "generated_at": TS_NOW[:10], "source_version": f"BUS brain v{VERSION}",
        "relationship": "calls",
        "evidence": {
            "component_count": len(sps), "components": sps,
            "volume": sum(s["calls"] for s in sps),
            "domains": sorted({s["domain"] for s in sps if s["domain"]}),
            "regulation": [],
            "origin_artifact": f"source/logs/{lote}",
            "note": "Volumetria de produccion por stored procedure, con el datasource "
                    "declarado en el trama del BUS. Los errores reflejan el campo estatus, "
                    "que mezcla falla tecnica con ausencia de datos.",
        },
    }
    (SEEDS_DIR / "informix-seed.json").write_text(
        json.dumps(seed, ensure_ascii=False, indent=1), encoding="utf-8")

    servicios = [{"id": s, "name": s, "calls": c, "errors": e}
                 for s, c, e in con.execute(
                     "SELECT service, SUM(calls), SUM(errors) FROM services "
                     "GROUP BY service ORDER BY SUM(calls) DESC")]
    seed_siweb = {
        "source_system": SYSTEM_ID, "source_togaf_type": "integration",
        "target_system": "siweb", "target_togaf_type": "channels",
        "generated_at": TS_NOW[:10], "source_version": f"BUS brain v{VERSION}",
        "relationship": "calls",
        "evidence": {
            "component_count": len(servicios), "components": servicios[:40],
            "volume": con.execute(
                "SELECT SUM(calls) FROM origin_systems WHERE family IN ('OFI_WEB','OFIWEB')"
            ).fetchone()[0] or 0,
            "domains": [], "regulation": [],
            "origin_artifact": f"source/logs/{lote}",
            "note": "Catalogo de servicios del bus con su volumen. El canal de sucursal es "
                    "el origen principal del trafico.",
        },
    }
    (SEEDS_DIR / "siweb-seed.json").write_text(
        json.dumps(seed_siweb, ensure_ascii=False, indent=1), encoding="utf-8")

    (SEEDS_DIR / "manifest.json").write_text(json.dumps({
        "emitter": SYSTEM_ID, "generated_at": TS_NOW,
        "source_version": f"BUS brain v{VERSION}",
        "seeds": [{"target": "informix", "file": "informix-seed.json",
                   "evidence_count": len(sps)},
                  {"target": "siweb", "file": "siweb-seed.json",
                   "evidence_count": len(servicios)}],
    }, ensure_ascii=False, indent=1), encoding="utf-8")
    return len(sps), len(servicios)


def main():
    ap = argparse.ArgumentParser(description="Construye el brain del BUS")
    ap.add_argument("--reset", action="store_true")
    args = ap.parse_args()

    lotes = [json.loads(p.read_text(encoding="utf-8")) for p in sorted(DATA_DIR.glob("*.json"))]
    if not lotes:
        print(f"[!] sin datos en {DATA_DIR} — ejecuta antes generators/parse-bus.py")
        return 1

    print(f"BUS brain v{VERSION}")
    rescate = preserve_seed(DB_PATH)
    con = sqlite3.connect(DB_PATH)
    con.execute("PRAGMA journal_mode=WAL")
    create_schema(con, args.reset)

    con.execute("INSERT OR REPLACE INTO system_info VALUES (?,?,?,?,?,?,?,?)",
                (SYSTEM_ID, "BUS — Bus de servicios empresarial", "integration",
                 "baseline", "enterprise-service-bus", "IBM Integration Bus",
                 VERSION, TS_NOW))

    print(f"  ETB embebido: {load_etb(con)} capacidades L3")
    load_knowledge(con, lotes)
    hallados, totales = enrich_against_core(con)
    print(f"  SPs cruzados contra el core: {hallados} de {totales} confirmados")
    load_dependencies(con, rescate, lotes)
    n_fts = build_fts(con)
    emit_signals(con, rescate)
    con.commit()
    n_sp, n_srv = emit_seeds(con)

    print("\n  conocimiento cargado:")
    for t in ("log_batches", "log_files", "services", "origin_systems", "informix_sp_calls",
              "service_sp_map", "operations", "error_signatures", "hourly_volume",
              "datasources", "cross_dependencies", "signals"):
        print(f"    {t:24s} {con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>7,}")
    print(f"    {'knowledge_fts':24s} {n_fts:>7,}")
    print(f"\n  seeds emitidos (B11): informix ({n_sp} SPs) y siweb ({n_srv} servicios)")
    con.close()
    print(f"  -> {DB_PATH}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-dependency-graph.py — El brain de dependencias de la flota BanCoppel.

Cada brain declara su lado de la relacion (Regla AM) y el bank-brain agrega la
vista global. Este pipeline construye esa vista: recorre los brains de sistema,
los seeds que se emiten entre ellos y lo que el propio bank-brain declara, y
deja un grafo unico de quien depende de quien, con la procedencia de cada
afirmacion.

El grafo vive dentro de `bank-brain.db`, con prefijo `dep_`, porque el
CLAUDE.md del bank-brain lo pide asi: sin bases separadas ni carpetas
alternativas. Como `build-bank-brain.py` borra y recrea su base en cada corrida,
este pipeline se invoca al final de esa reconstruccion y tambien puede correrse
solo cuando cambia un brain de sistema.

Cinco fuentes, con su confianza:
  1. cross_dependencies de cada brain de sistema   — lo que el sistema declara de si
  2. seeds emitidos entre brains                   — lo que un sistema afirma de otro
  3. system_dependencies del bank-brain            — lo declarado a nivel programa
  4. interfaces del bank-brain                     — topologia de integracion documentada
  5. Catalogo de Interfaces AS-IS (Anexo 5)        — 211 interfaces con sentido declarado

La quinta es la unica que declara el sentido de cada relacion fila por fila.
Con ella el grafo deja de inferir la direccion de los pares que nadie declaro:
ver `orientar()`.

Lo que el grafo responde y ninguna de esas fuentes responde sola:
  - quien depende de quien en todo el ecosistema, sin leer treinta bases
  - donde dos fuentes se contradicen sobre la misma relacion
  - que sistemas se citan pero no existen como carpeta (candidatos de Regla B9)
  - que brains declaran dependencias y cuales todavia no declaran ninguna

Uso:
  python bank-brain/generators/build-dependency-graph.py [--reset] [--verbose]
"""
import argparse
import json
import re
import sqlite3
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent.parent      # BanCoppel/
SYSTEMS = BASE / "systems"
BANK_DB = BASE / "bank-brain" / "digital-brain" / "bank-brain.db"
DB_PATH = BANK_DB
VERSION = "1.0.0"
TS_NOW = datetime.now(timezone.utc).isoformat()

# Un sistema, un nombre. La forma canonica es la que usa su carpeta en
# systems/; los alias son los nombres con que lo llaman las otras fuentes.
ALIAS = {
    "pisa": "informix",                 # el bank-brain llama pisa al core
    "eglobal": "e-global",
    "e_global": "e-global",
    "banca-internet": "banca-x-internet",
    "bancainternet": "banca-x-internet",
    "pld": "pld-minds",
    "appmovil": "app-movil",
    "app-móvil": "app-movil",
    # SIWEB y el catalogo llaman `bus-iib` al bus de integracion; su carpeta y
    # su brain se llaman `bus`. Sin este alias el ecosistema lo ve dos veces:
    # un nodo maduro con brain y un huerfano sin carpeta, que es como estuvo.
    "bus-iib": "bus",
    "ibm-bus": "bus",
    # Convencion del programa: el cliente servidor es OFI; el frente web se
    # llama SIWEB y nunca OFIWeb. Todas sus grafias resuelven a siweb.
    "ofi-tradicional": "ofi",
    "ofi-web": "siweb",
    "ofi_web": "siweb",
    "ofiweb": "siweb",
    "ofi_webc": "siweb",
    "ofi-webc": "siweb",
    # Tres huerfanos que SIWEB citaba por su nombre de uso y que resultaron ser
    # sistemas del inventario del banco, abiertos como nodos el 2026-11-27.
    # SIWEB habla de la banca empresarial, del JBoss de remesas de Monterrey y
    # del web service de huella; el inventario los llama Empresa Net, Motor de
    # Pago de Remesas BTS y Motor de Huellas.
    "banca-empresarial": "empresa-net",
    "bts-monterrey": "motor-remesas-bts",
    "gestor-central-huellas": "motor-huellas",
}

# Nombre de carpeta por slug, tomado del mapa que ya usa el ecosistema en
# bank-brain/generators/bootstrap-from-seeds.py.
FOLDER = {
    "app-movil": "AppMovil", "banca-x-internet": "BancaInternet",
    "bancoppel-clic": "BanCoppelClic", "cajero-atm": "CajeroATM",
    "ist-atm": "IST", "oxxo-corresponsal": "Corresponsales", "paytrue": "PayTrue",
    "siweb": "SIWEB", "buro-de-credito": "BuroCredito", "domiciliacion": "Domiciliacion",
    "grandata": "Grandata", "moneygram": "MoneyGram", "prosa-switch": "PROSA",
    "smartvista": "SmartVista", "western-union": "WesternUnion",
    "bus": "BUS", "ofi": "OFI",
    "codi-banxico": "CoDi", "controlm": "ControlM", "e-global": "EGlobal",
    "mulesoft": "MuleSoft", "nomina-coppel": "NominaCoppel", "spei-banxico": "SPEI",
    "spid-usd": "SPID", "atlas": "Atlas", "datastage": "DataStage",
    "digitalizacion": "Digitalizacion", "banxico": "Banxico", "cnbv": "CNBV",
    "ipab": "IPAB", "pld-minds": "PLD", "sat-fiscal": "SAT",
    "sistema-riesgos": "Riesgos", "uif-pld": "UIF", "informix": "Informix",
}
SLUG_DE_CARPETA = {v: k for k, v in FOLDER.items()}

# ── Fuente 5: el Catalogo de Interfaces AS-IS ────────────────────────────
# 211 interfaces documentadas entre las 129 aplicaciones del Anexo 5. Es la
# unica fuente de la flota que declara el sentido de cada relacion en vez de
# dejarlo implicito, y trae su propia confianza por fila.
CATALOGO = (BASE / "projects/unity/source/docs/DocumentosTrabajo"
                   "/ArquitecturaAplicativaAsIs"
                   "/BanCoppel_Unity_Catalogo_Interfaces_ASIS_2_jeap.xlsx")

# El catalogo habla de aplicaciones; el grafo habla de sistemas. Una no es la
# otra: el nodo `informix` cubre la base Informix, el SOC que corre sobre ella
# y los modulos SPL del core, que el Anexo 5 lista por separado. Solo se mapea
# lo que el inventario sostiene; lo que no mapea queda en dep_catalog y no
# inventa aristas.
CATALOGO_MAP = {
    # El core: la base, el SOC y los modulos SPL que viven dentro
    "Informix (Core OLTP)": "informix",
    "Sistema Operativo Central (SOC)": "informix",
    "Puntos Compromiso (SPLs)": "informix",
    "Ordenes de Pago Nacionales": "informix",
    "BD Usuarios de Remesas": "informix",
    "Cobranza (SPL)": "informix",
    "Créditos Revolventes (SPL Centrales)": "informix",
    "Créditos a Plazo  (SPL Centrales)": "informix",
    "Órdenes de Supervisión  (SPL Centrales)": "informix",
    "Contabilidad": "informix",
    "Conciliaciones Operativo / Contables (Java+SPL)": "informix",
    "Administración de Faltantes y Daños a Inmuebles (java+SPL)": "informix",
    "Captación": "informix",
    "Inversiones (SPL)": "informix",
    "Cheques (SPL)": "informix",
    "Reportes Autoridades (Reportes Manuales) (SPL)": "informix",
    "Reporte de VISA (SIF) (SPL)": "informix",
    "Caja General (SPL)": "informix",
    "Formato IPAB (SPL)": "informix",
    "Administración ATM's (SPL)": "informix",
    "Integral (modulo central) (SPL)": "informix",
    "LIDE (SPL)": "informix",
    "Reporte de MasterCard (SOC I)": "informix",
    # Canales y sistemas con nodo propio en el grafo
    "SIWEB": "siweb",
    "App BanCoppel Móvil": "app-movil",
    "Portal de Internet (Banca Por Internet)": "banca-x-internet",
    "Interact Switch (Autorizador)": "interact",
    "Interact Router (21)": "interact",
    "Bus IBM": "bus",
    "IST SW (swithc) ATM's Propios": "ist-atm",
    "Corresponsalía OXXO": "oxxo-corresponsal",
    "Domiciliacion (SPLs)": "domiciliacion",
    "Prevención de Fraudes (SPL)": "paytrue",
    "Prevención de Lavado de Dinero": "pld-minds",
    "SPEI Enlace Financiero": "spei-banxico",
    "Oficina Financiera Integral (OFI)": "ofi",
    "Banxico": "banxico",
    "Buró de Crédito": "buro-de-credito",
    "SmartVista (Unity)": "smartvista",
    "Transact (Unity)": "transact",

    # Nodos abiertos por Regla B9 desde el inventario de aplicaciones del banco
    # el 2026-11-27. La decision de cada aplicacion vive en
    # knowledge-base/ontology/app-to-node.json; aqui solo se traduce el nombre
    # con que el Anexo 5 la escribe al slug del nodo que la cubre.
    "Aclaraciones": "aclaraciones",
    "Aladdin": "aladdin",
    "Administrador de token (CAS)": "autenticacion-token",
    "Autentificación de Token RSA": "autenticacion-token",
    "Autentificación de token RSA/Gemalto": "autenticacion-token",
    "HSM/RSA/Gemalto (seguridad)": "autenticacion-token",
    "Autenticador BC/CC": "autenticador-bc-cc",
    "Monitor de Operaciones BPI": "banca-x-internet",
    "CAT (01-800) Centro de atencion Telefonica": "cat-telefonico",
    "CAT Predictivo": "cat-telefonico",
    "Facturación Electrónica CFDI  (Interfactura / Detecno)": "cfdi-facturacion",
    "Sistema de Cobranza iCS": "cobranza-ics",
    "Consulta Cuentas y clientes (Coppel/ Ecomerce/ Afore)": "consulta-cuentas-clientes",
    "Consulta INE": "consulta-ine",
    "Consulta INE (Bus INE 4.0)": "consulta-ine",
    "Motores de Consumo de WS(INE)": "consulta-ine",
    "Consulta Renapo": "consulta-renapo",
    "Motores de Consumo de WS (RENAPO)": "consulta-renapo",
    "Data WareHouse": "data-warehouse",
    "Dictamen Unificado": "dictamen-unificado",
    "Prometeo - OnBase (Gestor Documental)": "digitalizacion",
    "Empresa Net": "empresa-net",
    "Clientes": "gestor-central-clientes",
    "Homologación-Remesas": "homologacion-remesas",
    "Homologación-Servicios": "homologacion-servicios",
    "Indeval Enlace Financiero": "indeval",
    # Modulos SPL que el Anexo 5 lista aparte y viven dentro del core
    "Canal Corresponsales Tiendas Coppel": "informix",
    "Canal Transferencias Préstamos Coppel": "informix",
    "Motor de Evaluación de Crédito": "informix",
    "Pagos Programados": "informix",
    "Inets (servicios para Coppel)": "interfaces-coppel",
    "Replicadores Coppel / Bancoppel": "interfaces-coppel",
    "ION Trading": "ion-trading",
    "GUI": "ist-atm",
    "Netxms Monitor ATM": "ist-atm",
    "IVR": "ivr",
    "BancoppelSMS": "latinia",
    "Latinia": "latinia",
    "MAC WEB": "mac-web",
    "Motor de Huellas": "motor-huellas",
    "Motor de Rostros": "motor-huellas",
    "Motor de Pago de Servicios": "motor-pago-servicios",
    "Motor de Pago de Remesas BTS": "motor-remesas-bts",
    "OpenBanking": "open-banking",
    "Crédito Comercial (Orión)": "orion",
    "Pago de TDC de Otros Bancos": "pago-tdc-otros-bancos",
    "Pagos de la Afore": "pagos-afore",
    "Pago de Remesas Appriza": "remesas-appriza",
    "Pago de Remesas WU/Orlandi/Vigo": "remesas-wu-orlandi-vigo",
    "RPA (Robots)": "rpa-robots",
    "SICC´s": "siccs",
    "Transferencia Electrónica de Fondos (TEF)": "tef",
    "Ares - Veritran - Veribank": "veritran",
}

# El catalogo declara el tipo de interfaz, no la semantica de la relacion: dice
# que el canal entra por JDBC, no si lee o escribe. Y en este core entrar por
# JDBC o por SPL es ejecutar procedimientos, no consultar tablas: la entidad
# que viaja en esas filas es "Transaccion / movimiento de core". Traducirlo a
# `reads` seria inventar un matiz que la fuente no da, y ademas contradiria sin
# motivo a los brains, que ya declaran esas mismas relaciones como `calls`.
# Solo la entrega de archivos se separa, porque ahi no hay invocacion.
# El tipo exacto no se pierde: queda en dep_catalog.tipo y en la evidencia.
TIPO_A_RELACION = {
    "batch": "feeds",
}

# Relaciones equivalentes. El grafo guarda la forma declarada y ademas una
# normalizada, para poder comparar lo que dicen fuentes distintas.
RELACION = {
    "calls": "calls", "call": "calls", "invoca": "calls",
    "feeds": "feeds", "alimenta": "feeds",
    "reads": "reads", "lee": "reads",
    "writes": "writes",
    "orchestrates": "orchestrates", "orquesta": "orchestrates",
    "notifies": "notifies",
    "peer": "peer",
    # Voz pasiva. `initialize-seed-brains.py` escribe la relacion desde el lado
    # del receptor, asi que "called-by" y "calls" son el mismo hecho dicho al
    # reves. Sin esta tabla el grafo reporta decenas de conflictos que no lo son.
    "called-by": "calls", "receives-from": "feeds", "read-by": "reads",
    "written-by": "writes", "notified-by": "notifies",
    "orchestrated-by": "orchestrates",
}

RE_TOGAF = re.compile(r'^#\s*togaf_type:\s*(\w+)', re.MULTILINE)
RE_STATE = re.compile(r'^#\s*togaf_state:\s*(\w+)', re.MULTILINE)

SCHEMA = """
CREATE TABLE IF NOT EXISTS dep_nodes (
    id            TEXT PRIMARY KEY,   -- slug canonico
    display_name  TEXT,
    togaf_type    TEXT,
    togaf_state   TEXT,
    folder        TEXT,               -- carpeta en systems/, NULL si no existe
    has_brain     INTEGER DEFAULT 0,
    brain_version TEXT,
    brain_kind    TEXT,               -- maduro | seed | sin brain
    declara       INTEGER DEFAULT 0,  -- cuantas dependencias declara
    citado_por    INTEGER DEFAULT 0,  -- cuantas veces lo citan otros
    origen        TEXT                -- como entro al grafo
);

-- Una fila por afirmacion. La misma relacion declarada por dos fuentes son dos
-- filas: el grafo no borra evidencia, la contrasta.
CREATE TABLE IF NOT EXISTS dep_edges (
    id            TEXT PRIMARY KEY,
    source        TEXT NOT NULL,
    target        TEXT NOT NULL,
    relationship  TEXT,
    rel_norm      TEXT,
    criticality   TEXT,
    declared_by   TEXT NOT NULL,      -- que brain lo afirma
    origin        TEXT NOT NULL,      -- cross_dependencies | seed | bank-brain | interfaces
    evidence_kind TEXT,
    description   TEXT,
    evidence      TEXT,
    artifact      TEXT,
    dir_declarada INTEGER DEFAULT 0,   -- la fuente dijo el sentido, no se infirio
    primaria      INTEGER DEFAULT 1,   -- 0 si solo repite lo que otro brain sembro
    reorientada   INTEGER DEFAULT 0,   -- se le dio la vuelta: nadie habia declarado su sentido
    orientada_por TEXT                 -- que fuente declaro el sentido que se adopto
);

-- El grafo deduplicado: un par de sistemas, una fila.
CREATE TABLE IF NOT EXISTS dep_graph (
    id            TEXT PRIMARY KEY,
    source        TEXT NOT NULL,
    target        TEXT NOT NULL,
    rel_norm      TEXT,
    criticality   TEXT,
    fuentes       INTEGER DEFAULT 1,
    declarers     TEXT DEFAULT '[]',
    origins       TEXT DEFAULT '[]',
    bidireccional INTEGER DEFAULT 0,  -- los dos extremos la declaran
    conflicto     INTEGER DEFAULT 0,
    dir_confianza TEXT DEFAULT 'inferida'   -- declarada | inferida
);

CREATE TABLE IF NOT EXISTS dep_conflicts (
    id          TEXT PRIMARY KEY,
    source      TEXT,
    target      TEXT,
    tipo        TEXT,                 -- relacion | criticidad | direccion
    detalle     TEXT,
    declarantes TEXT
);

-- Sistemas que alguien cita y que no tienen carpeta: candidatos de Regla B9.
CREATE TABLE IF NOT EXISTS dep_orphans (
    id          TEXT PRIMARY KEY,
    citado_por  TEXT,
    veces       INTEGER,
    ejemplo     TEXT
);

CREATE TABLE IF NOT EXISTS dep_aliases (
    alias     TEXT PRIMARY KEY,
    canonical TEXT NOT NULL,
    razon     TEXT
);

-- Las 211 interfaces del Anexo 5 tal como estan, sin colapsar a sistemas. El
-- grafo habla de 43 sistemas y el catalogo de 129 aplicaciones: guardar solo
-- lo mapeado perderia la capa fina, que es donde vive el detalle de protocolo.
CREATE TABLE IF NOT EXISTS dep_catalog (
    id            INTEGER PRIMARY KEY,
    origen_id     TEXT,               -- ID de app en el Anexo 5
    origen_app    TEXT,
    origen_grupo  TEXT,               -- grupo N2 del mapeo de capacidades
    destino_id    TEXT,
    destino_app   TEXT,
    destino_grupo TEXT,
    tipo          TEXT,               -- API_Rest | Web_Service (SOAP) | acceso_directo_a_DB...
    sincronia     TEXT,
    entidad       TEXT,               -- que viaja por la interfaz
    confianza     TEXT,               -- Alta = Anexo 5 o diagrama; Media = ficha
    documento     TEXT,               -- documento de referencia
    source        TEXT,               -- nodo del grafo, NULL si la app no mapea
    target        TEXT,
    mapeada       INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS dep_signals (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_type   TEXT NOT NULL,
    source_system TEXT NOT NULL,
    value         INTEGER DEFAULT 0,
    metadata      TEXT DEFAULT '{}',
    seeded_at     TEXT
);
"""

FTS_SCHEMA = """
CREATE VIRTUAL TABLE dep_edges_fts
    USING fts5(id, source, target, relationship, description,
               content='dep_edges', content_rowid='rowid');
"""


# ── Utilidades ──────────────────────────────────────────────────────────

def canon(slug) -> str | None:
    if not slug:
        return None
    s = str(slug).strip().lower().replace(" ", "-")
    return ALIAS.get(s, s)


def norm_rel(rel) -> str:
    return RELACION.get((rel or "").strip().lower(), (rel or "unknown").lower())


def leer(path: Path) -> str:
    for enc in ("utf-8", "latin-1"):
        try:
            return path.read_text(encoding=enc)
        except (UnicodeDecodeError, OSError):
            continue
    return ""


def columnas(con, tabla) -> set:
    try:
        return {r[1] for r in con.execute(f"PRAGMA table_info({tabla})")}
    except sqlite3.OperationalError:
        return set()


def arista(source, target, direction):
    """Convierte (otro, direccion) en un par dirigido source -> target.

    En toda la flota `outbound` significa "yo dependo del otro" e `inbound`
    significa "el otro depende de mi". El grafo guarda siempre quien llama.
    """
    if (direction or "").lower() == "inbound":
        return target, source
    return source, target


# ── Fuente 1 y 2: los brains de sistema y sus seeds ──────────────────────

def slug_declarado(db: Path) -> str | None:
    """Como dice llamarse el propio brain, si lo dice."""
    try:
        con = sqlite3.connect(f"file:{db.as_posix()}?mode=ro", uri=True)
        try:
            if "slug" not in columnas(con, "system_info"):
                return None
            fila = con.execute("SELECT slug FROM system_info LIMIT 1").fetchone()
            return fila[0] if fila and fila[0] else None
        finally:
            con.close()
    except sqlite3.Error:
        return None


def leer_sistemas(verbose=False):
    """Un recorrido por systems/ que devuelve nodos, aristas y procedencia."""
    nodos, aristas = {}, []

    # El censo se hace por carpeta, no por CLAUDE.md: hay sistemas con brain
    # propio y sin CLAUDE.md, y si la clave fuera el archivo se perderian.
    for carpeta_path in sorted(d for d in SYSTEMS.glob("*/*") if d.is_dir()):
        carpeta = carpeta_path.name

        # El id lo declara el brain, no la carpeta. La carpeta dice
        # `MotorPagoServicios` y el sistema se llama `motor-pago-servicios`;
        # dice `EGlobal` y se llama `e-global`. Sin esto, la carpeta aplastada
        # a minusculas produce un nodo con brain al lado del nodo real que los
        # demas brains citan, y el mismo sistema aparece dos veces en el grafo.
        # Solo se cae al nombre de la carpeta cuando el brain no lo declara.
        declarado = slug_declarado(carpeta_path / "digital-brain" / "brain.db")
        slug = canon(declarado) or canon(SLUG_DE_CARPETA.get(carpeta, carpeta.lower()))
        claude = carpeta_path / "CLAUDE.md"
        texto = leer(claude) if claude.exists() else ""
        tipo = RE_TOGAF.search(texto)
        estado = RE_STATE.search(texto)
        nodos[slug] = {
            "id": slug, "display_name": carpeta,
            "togaf_type": tipo.group(1) if tipo else carpeta_path.parent.name,
            "togaf_state": estado.group(1) if estado else "unknown",
            "folder": f"systems/{carpeta_path.parent.name}/{carpeta}",
            "has_brain": 0, "brain_version": None, "brain_kind": "sin brain",
            "origen": "carpeta de sistema" if claude.exists()
                      else "carpeta de sistema sin CLAUDE.md",
        }

        db = carpeta_path / "digital-brain" / "brain.db"
        if not db.exists():
            continue
        con = sqlite3.connect(f"file:{db.as_posix()}?mode=ro", uri=True)
        con.row_factory = sqlite3.Row
        nodos[slug]["has_brain"] = 1

        cols_si = columnas(con, "system_info")
        if "brain_version" in cols_si:
            fila = con.execute("SELECT brain_version FROM system_info LIMIT 1").fetchone()
            if fila:
                nodos[slug]["brain_version"] = fila[0]
                nodos[slug]["brain_kind"] = ("seed" if str(fila[0]).startswith("seed-")
                                             else "maduro")
        else:
            nodos[slug]["brain_kind"] = "maduro"   # Informix: anterior a system_info

        cols = columnas(con, "cross_dependencies")
        if cols:
            for r in con.execute("SELECT * FROM cross_dependencies"):
                r = dict(r)
                # Tres formas conviven en la flota. Se leen las tres.
                if "other_system" in cols:
                    otro = canon(r.get("other_system"))
                    rel = r.get("relationship") or r.get("dependency_type")
                    src, tgt = arista(slug, otro, r.get("direction"))
                else:                                   # AppMovil
                    # El par viene explicito, pero `direction` sigue mandando:
                    # es la columna con que la flota declara el sentido. Al
                    # ignorarla, la fila sembrada por Informix entraba como
                    # informix -> app-movil mientras su propia evidencia decia
                    # "363 endpoints del canal invocan SPs del core".
                    src, tgt = arista(canon(r.get("source_system")) or slug,
                                      canon(r.get("target_system")),
                                      r.get("direction"))
                    rel = r.get("relationship") or r.get("dependency_type") or "calls"
                if not tgt or src == tgt:
                    continue
                # Un brain semilla no declara: repite, invertida, la afirmacion
                # del brain que lo sembro. No cuenta como fuente primaria.
                es_semilla = nodos[slug]["brain_kind"] == "seed"
                aristas.append({
                    "source": src, "target": tgt, "relationship": rel,
                    "criticality": r.get("criticality"),
                    "declared_by": r.get("emitter") or slug,
                    "origin": "cross_dependencies",
                    "evidence_kind": r.get("evidence_kind"),
                    "description": r.get("description"),
                    "evidence": r.get("evidence") or r.get("origin_artifact"),
                    "artifact": f"{nodos[slug]['folder']}/digital-brain/brain.db",
                    "dir_declarada": 0 if es_semilla else int(bool(r.get("direction"))),
                    "primaria": 0 if es_semilla else 1,
                })
        con.close()

    for seed_file in sorted(SYSTEMS.rglob("digital-brain/seeds/*-seed.json")):
        try:
            seed = json.loads(leer(seed_file))
        except json.JSONDecodeError:
            continue
        src, tgt = canon(seed.get("source_system")), canon(seed.get("target_system"))
        if not src or not tgt or src == tgt:
            continue
        ev = seed.get("evidence", {}) or {}
        a, b = arista(src, tgt, ev.get("direction"))
        aristas.append({
            "source": a, "target": b,
            "dir_declarada": int(bool(ev.get("direction"))),
            "primaria": 1,
            "relationship": seed.get("relationship"),
            "criticality": ev.get("criticality"),
            "declared_by": src, "origin": "seed", "evidence_kind": "seed",
            "description": ev.get("description") or ev.get("cross_dep_description")
                           or ev.get("nota"),
            "evidence": ev.get("raw_evidence") or (
                f"{ev.get('component_count', 0)} componentes, volumen {ev.get('volume', 0)}"),
            "artifact": str(seed_file.relative_to(BASE)).replace("\\", "/"),
        })

    if verbose:
        print(f"  systems/: {len(nodos)} carpetas, {len(aristas)} afirmaciones")
    return nodos, aristas


# ── Fuente 3 y 4: lo que declara el federador ────────────────────────────

def leer_bank_brain(verbose=False):
    nodos, aristas = {}, []
    if not BANK_DB.exists():
        return nodos, aristas
    con = sqlite3.connect(f"file:{BANK_DB.as_posix()}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row

    for r in con.execute("SELECT id, name, type, status, togaf_type, togaf_state FROM systems"):
        slug = canon(r["id"])
        nodos[slug] = {
            "id": slug, "display_name": r["name"], "togaf_type": r["togaf_type"],
            "togaf_state": r["togaf_state"] or r["status"], "folder": None,
            "has_brain": 0, "brain_version": None, "brain_kind": "sin brain",
            "origen": "bank-brain::systems",
        }

    for r in con.execute("SELECT * FROM system_dependencies"):
        r = dict(r)
        src, tgt = arista(canon(r["source_system"]), canon(r["target_system"]),
                          r.get("direction"))
        if not src or not tgt or src == tgt:
            continue
        aristas.append({
            "source": src, "target": tgt, "relationship": r.get("dependency_type"),
            "criticality": r.get("criticality"), "declared_by": "bank-brain",
            "origin": "bank-brain", "evidence_kind": "declarada",
            "description": r.get("description"), "evidence": r.get("evidence"),
            "artifact": "bank-brain/digital-brain/bank-brain.db::system_dependencies",
            "dir_declarada": int(bool(r.get("direction"))), "primaria": 1,
        })

    for r in con.execute("SELECT id, from_sys, to_sys, name, protocol, direction FROM interfaces"):
        src, tgt = canon(r["from_sys"]), canon(r["to_sys"])
        if not src or not tgt or src == tgt:
            continue
        aristas.append({
            "source": src, "target": tgt, "relationship": "calls",
            "criticality": None, "declared_by": "bank-brain",
            "origin": "interfaces", "evidence_kind": "topologia",
            "description": r["name"], "evidence": f"protocolo {r['protocol']}, {r['direction']}",
            "artifact": "bank-brain/digital-brain/bank-brain.db::interfaces",
            "dir_declarada": 1, "primaria": 1,
        })

    con.close()
    if verbose:
        print(f"  bank-brain: {len(nodos)} sistemas, {len(aristas)} afirmaciones")
    return nodos, aristas


# ── Fuente 5: el Catalogo de Interfaces AS-IS ────────────────────────────

def _celdas_xlsx(path: Path):
    """Lee la hoja `Interfaces AS-IS` sin dependencias externas.

    El xlsx guarda las cadenas en linea y escapadas como entidades HTML, asi
    que hay que desescaparlas o los nombres llegan con &#243; en vez de o.
    """
    import html
    import zipfile
    with zipfile.ZipFile(path) as z:
        nombres = z.namelist()
        compartidas = []
        if "xl/sharedStrings.xml" in nombres:
            ss = z.read("xl/sharedStrings.xml").decode("utf-8", errors="replace")
            compartidas = [html.unescape(re.sub(r"<[^>]+>", "", m))
                           for m in re.findall(r"<si>(.*?)</si>", ss, re.S)]
        libro = z.read("xl/workbook.xml").decode("utf-8", errors="replace")
        hojas = re.findall(r'<sheet [^>]*name="([^"]+)"', libro)
        indice = next((i for i, n in enumerate(hojas, 1)
                       if "Interfaces" in html.unescape(n)), 1)
        xml = z.read(f"xl/worksheets/sheet{indice}.xml").decode("utf-8", errors="replace")

    def columna(ref):
        m = re.match(r"([A-Z]+)", ref or "")
        if not m:
            return 0
        n = 0
        for ch in m.group(1):
            n = n * 26 + (ord(ch) - 64)
        return n - 1

    filas = []
    for fila in re.findall(r"<row[^>]*>(.*?)</row>", xml, re.S):
        celdas = {}
        for m in re.finditer(r"<c\b([^>]*?)(?:/>|>(.*?)</c>)", fila, re.S):
            attrs, cuerpo = m.group(1), m.group(2) or ""
            ref = re.search(r'r="([A-Z]+\d+)"', attrs)
            t = re.search(r't="([^"]+)"', attrs)
            tipo = t.group(1) if t else "n"
            if tipo == "inlineStr":
                valor = html.unescape(re.sub(r"<[^>]+>", "", cuerpo))
            else:
                v = re.search(r"<v>(.*?)</v>", cuerpo, re.S)
                valor = v.group(1) if v else ""
                if tipo == "s" and valor.isdigit():
                    valor = compartidas[int(valor)]
                else:
                    valor = html.unescape(re.sub(r"<[^>]+>", "", valor))
            celdas[columna(ref.group(1) if ref else "")] = valor.strip()
        if celdas:
            filas.append([celdas.get(i, "") for i in range(12)])
    return filas


def leer_catalogo(verbose=False):
    """El catalogo declara origen y destino, asi que toda arista suya tiene
    sentido declarado. Es la unica fuente de la flota que lo hace fila por fila.
    """
    crudas, aristas = [], []
    if not CATALOGO.exists():
        if verbose:
            print(f"  catalogo: no esta en {CATALOGO}")
        return crudas, aristas

    artefacto = str(CATALOGO.relative_to(BASE)).replace("\\", "/")
    for fila in _celdas_xlsx(CATALOGO)[1:]:
        num, grp_o, id_o, app_o, grp_d, id_d, app_d, tipo, sinc, entidad, conf, doc = fila
        if not num.isdigit() or not app_o or not app_d:
            continue
        # canon() tambien aqui: el mapeo nombra sistemas con el slug de uso
        # corriente y los alias son los que deciden cual es el canonico.
        src, tgt = canon(CATALOGO_MAP.get(app_o)), canon(CATALOGO_MAP.get(app_d))
        mapeada = int(bool(src and tgt and src != tgt))
        crudas.append((int(num), id_o, app_o, grp_o, id_d, app_d, grp_d,
                       tipo, sinc, entidad, conf, doc, src, tgt, mapeada))
        if not mapeada:
            continue
        familia = re.split(r"[ (]", (tipo or "").strip().lower())[0]
        aristas.append({
            "source": src, "target": tgt,
            "relationship": TIPO_A_RELACION.get(familia, "calls"),
            # El catalogo no gradua criticidad; graduar aqui seria inventarla.
            "criticality": None,
            "declared_by": "catalogo-interfaces",
            "origin": "catalogo-interfaces",
            "evidence_kind": f"catalogo-{(conf or 'sin confianza').lower()}",
            "description": f"{app_o} -> {app_d}: {entidad or 'sin entidad declarada'}",
            "evidence": f"Interfaz #{num} del Anexo 5, {tipo or 'tipo no declarado'}"
                        f"{', ' + sinc if sinc else ''}. Confianza {conf or 'no declarada'}."
                        f" Referencia: {doc or 'sin documento'}.",
            "artifact": artefacto,
            # El catalogo pone origen y destino en columnas distintas: el
            # sentido es dato, no lectura nuestra.
            "dir_declarada": 1,
            "primaria": 1,
        })

    if verbose:
        mapeadas = sum(1 for c in crudas if c[14])
        print(f"  catalogo: {len(crudas)} interfaces, {mapeadas} mapeadas a sistemas")
    return crudas, aristas


# ── Orientacion ──────────────────────────────────────────────────────────

def orientar(aristas, verbose=False):
    """Le da la vuelta a las afirmaciones cuyo sentido nadie declaro.

    `initialize-seed-brains.py` sembro 18 sistemas desde el `external_systems`
    de Informix, que cuenta endpoints y no dice quien llama a quien. Al no
    haber sentido, el seed quedo orientado desde el emisor: el core llamando
    al canal. El Catalogo de Interfaces AS-IS declara lo contrario en 211
    filas, y su metodologia lo dice sin rodeos: las bases de datos son siempre
    destino, nunca origen.

    Reorientar no es borrar evidencia. La afirmacion sigue siendo la misma y
    conserva su descripcion; lo que cambia es un sentido que su fuente nunca
    afirmo. Cuando dos fuentes si declaran sentidos opuestos, eso es un
    desacuerdo de verdad y aqui no se toca: lo marca `construir_grafo`.
    """
    por_par = defaultdict(list)
    for a in aristas:
        por_par[tuple(sorted((a["source"], a["target"])))].append(a)

    reorientadas = 0
    for par, grupo in por_par.items():
        declaradas = {(a["source"], a["target"]) for a in grupo
                      if a.get("dir_declarada") and a.get("primaria")}
        if len(declaradas) != 1:
            continue                      # nadie lo declara, o se contradicen
        src, tgt = declaradas.pop()
        fuente = next(a["declared_by"] for a in grupo
                      if (a["source"], a["target"]) == (src, tgt)
                      and a.get("dir_declarada") and a.get("primaria"))
        for a in grupo:
            if a.get("dir_declarada") and a.get("primaria"):
                continue                  # su fuente si dijo el sentido
            if (a["source"], a["target"]) == (src, tgt):
                continue                  # ya apunta donde debe
            a["source"], a["target"] = src, tgt
            a["reorientada"] = 1
            a["orientada_por"] = fuente
            reorientadas += 1

    if verbose:
        print(f"  orientacion: {reorientadas} afirmaciones reorientadas por una "
              f"fuente que si declara el sentido")
    return reorientadas


# ── Consolidacion ────────────────────────────────────────────────────────

def consolidar(conn, nodos_sys, nodos_bank, aristas):
    # Los nodos de systems/ mandan: tienen carpeta y, muchas veces, brain.
    nodos = dict(nodos_bank)
    for slug, n in nodos_sys.items():
        if slug in nodos:
            n["display_name"] = nodos[slug]["display_name"] or n["display_name"]
        nodos[slug] = n

    citados = defaultdict(list)
    declara = defaultdict(int)
    for a in aristas:
        declara[a["declared_by"]] += 1
        for extremo in (a["source"], a["target"]):
            if extremo not in nodos:
                citados[extremo].append(a)

    for slug, refs in citados.items():
        nodos[slug] = {
            "id": slug, "display_name": slug, "togaf_type": "unknown",
            "togaf_state": "citado", "folder": None, "has_brain": 0,
            "brain_version": None, "brain_kind": "sin brain",
            "origen": "citado por otro brain",
        }

    cita_count = defaultdict(int)
    for a in aristas:
        cita_count[a["target"]] += 1

    conn.executemany(
        "INSERT OR REPLACE INTO dep_nodes VALUES (?,?,?,?,?,?,?,?,?,?,?)",
        [(n["id"], n["display_name"], n["togaf_type"], n["togaf_state"], n["folder"],
          n["has_brain"], n["brain_version"], n["brain_kind"],
          declara.get(n["id"], 0), cita_count.get(n["id"], 0), n["origen"])
         for n in nodos.values()])

    filas = []
    for i, a in enumerate(aristas, 1):
        filas.append((
            f"E{i:04d}-{a['source']}-{a['target']}", a["source"], a["target"],
            a["relationship"], norm_rel(a["relationship"]), a["criticality"],
            a["declared_by"], a["origin"], a["evidence_kind"],
            a["description"], a["evidence"], a["artifact"],
            a.get("dir_declarada", 0), a.get("primaria", 1),
            a.get("reorientada", 0), a.get("orientada_por")))
    conn.executemany(
        "INSERT OR REPLACE INTO dep_edges VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", filas)

    conn.executemany("INSERT OR REPLACE INTO dep_aliases VALUES (?,?,?)",
                     [(a, c, "normalizado por build-dependency-graph.py")
                      for a, c in ALIAS.items() if a != c])
    return nodos, citados


def construir_grafo(conn):
    """Deduplica por par dirigido y marca donde las fuentes no coinciden."""
    pares = defaultdict(list)
    for r in conn.execute("SELECT * FROM dep_edges"):
        pares[(r[1], r[2])].append(r)

    orden = {"critical": 0, "high": 1, "medium": 2, "low": 3, None: 9}
    filas, conflictos = [], []
    for (src, tgt), rs in sorted(pares.items()):
        rels = {r[4] for r in rs if r[4] and r[4] != "unknown"}
        crits = {r[5] for r in rs if r[5] and r[5] != "unknown"}
        declarers = sorted({r[6] for r in rs})
        origins = sorted({r[7] for r in rs})
        hay_conflicto = len(rels) > 1 or len(crits) > 1
        inversa = (tgt, src) in pares

        if len(rels) > 1:
            conflictos.append((f"C-rel-{src}-{tgt}", src, tgt, "relacion",
                               "Se declara como " + " y como ".join(sorted(rels)),
                               json.dumps(declarers)))
        if len(crits) > 1:
            conflictos.append((f"C-crit-{src}-{tgt}", src, tgt, "criticidad",
                               "Criticidad declarada como " + " y como ".join(sorted(crits)),
                               json.dumps(declarers)))
        if inversa:
            rels_inv = {r[4] for r in pares[(tgt, src)] if r[4]}
            # Dos sistemas pueden llamarse mutuamente; lo sospechoso es que la
            # misma relacion aparezca en los dos sentidos.
            if rels & rels_inv:
                conflictos.append((f"C-dir-{min(src, tgt)}-{max(src, tgt)}", src, tgt, "direccion",
                                   "La misma relacion se declara en ambos sentidos: "
                                   + ", ".join(sorted(rels & rels_inv)),
                                   json.dumps(sorted(set(declarers)
                                                     | {r[6] for r in pares[(tgt, src)]}))))
        # La direccion vale si alguna fuente primaria la declaro. Un brain
        # semilla repite lo que le sembraron, asi que no confirma nada.
        declarada = any(r[12] and r[13] for r in rs)
        if not declarada:
            conflictos.append((f"C-dir-inferida-{src}-{tgt}", src, tgt, "direccion-inferida",
                               "Ninguna fuente primaria declara el sentido. Se tomo el del "
                               "emisor del seed, que no lo dice.",
                               json.dumps(declarers)))
        filas.append((
            f"G-{src}-{tgt}", src, tgt,
            sorted(rels)[0] if rels else "unknown",
            sorted(crits, key=lambda c: orden.get(c, 9))[0] if crits else None,
            len(rs), json.dumps(declarers), json.dumps(origins),
            1 if inversa else 0, 1 if hay_conflicto else 0,
            "declarada" if declarada else "inferida"))

    conn.executemany("INSERT OR REPLACE INTO dep_graph VALUES (?,?,?,?,?,?,?,?,?,?,?)", filas)
    conn.executemany("INSERT OR REPLACE INTO dep_conflicts VALUES (?,?,?,?,?,?)",
                     {c[0]: c for c in conflictos}.values())
    return len(filas), len({c[0] for c in conflictos})


def cargar_catalogo(conn, crudas):
    conn.executemany(
        "INSERT OR REPLACE INTO dep_catalog VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", crudas)
    return len(crudas)


def cargar_huerfanos(conn, citados):
    filas = []
    for slug, refs in sorted(citados.items()):
        declarantes = sorted({r["declared_by"] for r in refs})
        filas.append((slug, json.dumps(declarantes), len(refs),
                      (refs[0].get("description") or "")[:240]))
    conn.executemany("INSERT OR REPLACE INTO dep_orphans VALUES (?,?,?,?)", filas)
    return len(filas)


def build_fts(conn):
    conn.execute("DROP TABLE IF EXISTS dep_edges_fts")
    conn.executescript(FTS_SCHEMA)
    conn.execute("INSERT INTO dep_edges_fts(rowid, id, source, target, relationship, description) "
                 "SELECT rowid, id, source, target, relationship, description FROM dep_edges")


def emit_signals(conn, counts):
    conn.execute("DELETE FROM dep_signals")
    for tipo, valor in counts.items():
        conn.execute(
            "INSERT INTO dep_signals (signal_type, source_system, value, metadata, seeded_at) "
            "VALUES (?,?,?,?,?)",
            (tipo, "dependency-brain", valor,
             json.dumps({"brain_version": VERSION}), TS_NOW))


def main():
    ap = argparse.ArgumentParser(description="Construye el brain de dependencias de la flota")
    ap.add_argument("--reset", action="store_true")
    ap.add_argument("--db", type=Path, default=DB_PATH)
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()

    if args.reset and args.db.exists():
        args.db.unlink()
    conn = sqlite3.connect(args.db)
    # Las tablas dep_ se repueblan enteras en cada corrida, asi que cuando el
    # esquema crece basta con rehacerlas. CREATE IF NOT EXISTS por si solo
    # dejaria la tabla vieja y el INSERT fallaria por numero de columnas.
    esperado = {
        "dep_edges": {"reorientada", "orientada_por"},
        "dep_catalog": {"origen_app", "destino_app", "mapeada"},
    }
    for tabla, requeridas in esperado.items():
        try:
            actuales = {r[1] for r in conn.execute(f"PRAGMA table_info({tabla})")}
        except sqlite3.OperationalError:
            continue
        if actuales and not requeridas <= actuales:
            conn.execute(f"DROP TABLE {tabla}")
    conn.executescript(SCHEMA)
    for tabla in ("dep_nodes", "dep_edges", "dep_graph", "dep_conflicts",
                  "dep_orphans", "dep_aliases", "dep_catalog"):
        conn.execute(f"DELETE FROM {tabla}")

    nodos_sys, aristas_sys = leer_sistemas(args.verbose)
    nodos_bank, aristas_bank = leer_bank_brain(args.verbose)
    crudas_cat, aristas_cat = leer_catalogo(args.verbose)
    aristas = aristas_sys + aristas_bank + aristas_cat

    reorientadas = orientar(aristas, args.verbose)

    nodos, citados = consolidar(conn, nodos_sys, nodos_bank, aristas)
    pares, conflictos = construir_grafo(conn)
    huerfanos = cargar_huerfanos(conn, citados)
    interfaces = cargar_catalogo(conn, crudas_cat)
    build_fts(conn)

    q = lambda sql: conn.execute(sql).fetchone()[0]
    counts = {
        "nodes": len(nodos),
        "nodes_con_carpeta": q("SELECT COUNT(*) FROM dep_nodes WHERE folder IS NOT NULL"),
        "nodes_con_brain": q("SELECT COUNT(*) FROM dep_nodes WHERE has_brain = 1"),
        "nodes_brain_maduro": q("SELECT COUNT(*) FROM dep_nodes WHERE brain_kind = 'maduro'"),
        "nodes_sin_declarar": q("SELECT COUNT(*) FROM dep_nodes WHERE declara = 0"),
        "edges": len(aristas),
        "graph_pares": pares,
        "pares_bidireccionales": q("SELECT COUNT(*) FROM dep_graph WHERE bidireccional = 1"),
        "pares_multifuente": q("SELECT COUNT(*) FROM dep_graph WHERE fuentes > 1"),
        "conflictos": conflictos,
        "pares_direccion_inferida": q("SELECT COUNT(*) FROM dep_graph WHERE dir_confianza = 'inferida'"),
        "afirmaciones_reorientadas": reorientadas,
        "catalogo_interfaces": interfaces,
        "catalogo_mapeadas": q("SELECT COUNT(*) FROM dep_catalog WHERE mapeada = 1"),
        "huerfanos": huerfanos,
    }
    emit_signals(conn, counts)
    conn.commit()
    conn.close()

    print(f"grafo de dependencias escrito en {args.db}")
    for k, v in counts.items():
        print(f"  {k:24} {v}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

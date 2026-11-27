#!/usr/bin/env python3
"""
bootstrap-from-inventory.py — Regla B9 desde el inventario de aplicaciones.

El B9 que ya existia (bootstrap-from-seeds.py) se alimenta de los seeds que un
brain emite hacia sus vecinos, asi que solo descubre lo que algun brain ya vio.
Este corre sobre la otra fuente: el inventario de aplicaciones del propio banco,
Inventario_bdanalisis.xlsx, cargado en bank-brain.db como `applications`.

La clasificacion no vive aqui. Vive en knowledge-base/ontology/app-to-node.json,
que decide aplicacion por aplicacion si abre nodo nuevo, cae dentro de un nodo
que ya existe, o se queda registrada sin carpeta. Este script solo la ejecuta.

Sin argumentos reporta y carga la tabla `app_nodes` en bank-brain.db, que es lo
que necesita el pipeline. Con --apply crea ademas la estructura canonica de los
nodos nuevos (Regla B9) y su brain semilla (Regla B12).

Uso:
    python generators/bootstrap-from-inventory.py            # reporte y tabla
    python generators/bootstrap-from-inventory.py --apply    # crea carpetas y brains
"""

import json
import re
import sqlite3
import sys
import unicodedata
from datetime import date
from pathlib import Path

APPLY = "--apply" in sys.argv
REBUILD = "--rebuild-seeds" in sys.argv

BANK_BRAIN_ROOT = Path(__file__).resolve().parent.parent
CLIENT_ROOT = BANK_BRAIN_ROOT.parent
SYSTEMS_ROOT = CLIENT_ROOT / "systems"
DB_PATH = BANK_BRAIN_ROOT / "digital-brain" / "bank-brain.db"
ONTOLOGY = BANK_BRAIN_ROOT / "knowledge-base" / "ontology" / "app-to-node.json"

TODAY = date.today().isoformat()

SYSTEM_OF = {
    "core": "record",
    "processors": "record",
    "channels": "differentiation",
    "data": "innovation",
    "integration": "innovation",
    "compliance": "record",
}

CANONICAL_SUBDIRS = [
    "source/code", "source/docs", "source/ops",
    "digital-brain",
    "knowledge-base/rules", "knowledge-base/vocab",
    "knowledge-base/ontology", "knowledge-base/regulacion",
    "generators", "dt", "portal/data", "old",
]

SEED_BRAIN_SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    slug            TEXT PRIMARY KEY,
    display_name    TEXT,
    togaf_type      TEXT,
    togaf_state     TEXT,
    togaf_abb       TEXT,
    seeded_by       TEXT,
    seeded_at       TEXT,
    seed_version    TEXT,
    brain_version   TEXT DEFAULT 'seed-1.0'
);

CREATE TABLE IF NOT EXISTS cross_dependencies (
    id              TEXT PRIMARY KEY,
    other_system    TEXT NOT NULL,
    relationship    TEXT NOT NULL,
    direction       TEXT NOT NULL,
    volume          INTEGER DEFAULT 0,
    domains         TEXT DEFAULT '[]',
    regulation      TEXT DEFAULT '[]',
    description     TEXT,
    criticality     TEXT DEFAULT 'unknown',
    origin_artifact TEXT,
    seeded_at       TEXT
);

CREATE TABLE IF NOT EXISTS signals (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_type     TEXT NOT NULL,
    source_system   TEXT NOT NULL,
    value           INTEGER DEFAULT 0,
    metadata        TEXT DEFAULT '{}',
    seeded_at       TEXT
);

CREATE TABLE IF NOT EXISTS inventory_apps (
    app_id          TEXT PRIMARY KEY,
    nombre          TEXT,
    agrupacion      TEXT,
    criticidad      TEXT,
    complejidad     TEXT,
    spl_declared    INTEGER,
    hosts           INTEGER,
    ops_day         INTEGER,
    dbms            TEXT,
    middleware      TEXT,
    hosting         TEXT,
    source_doc      TEXT
);
"""

# Misma regla que build-dependency-graph.py, y a proposito la misma. El Anexo 5
# declara el tipo de interfaz, no la semantica de la relacion: dice que el canal
# entra por JDBC, no si lee o escribe. Separar `reads` o `notifies` por el tipo
# seria inventar un matiz que la fuente no da, y haria que el mismo hecho se
# contara como conflicto por venir del catalogo y del brain con verbos distintos.
# Solo la entrega de archivos se separa, porque ahi no hay invocacion.


def flat(s) -> str:
    return re.sub(r"\s+", " ", str(s or "").strip())


def norm(s) -> str:
    """Normaliza un nombre de aplicacion para cruzar inventario contra catalogo."""
    s = flat(s).lower()
    s = unicodedata.normalize("NFKD", s)
    s = "".join(ch for ch in s if not unicodedata.combining(ch))
    s = re.sub(r"[^a-z0-9]+", " ", s)
    return s.strip()


def slugify(s) -> str:
    return re.sub(r"[^a-z0-9]+", "-", norm(s)).strip("-") or "sin-nombre"


def relationship_for(tipo: str) -> str:
    return "feeds" if "batch" in flat(tipo).lower() else "calls"


# --------------------------------------------------------------------------- #
# Carga
# --------------------------------------------------------------------------- #

def load_everything():
    if not ONTOLOGY.exists():
        sys.exit(f"[FALTA] No existe la ontologia {ONTOLOGY}")
    if not DB_PATH.exists():
        sys.exit(f"[FALTA] No existe {DB_PATH}. Corre antes build-bank-brain.py")

    onto = json.loads(ONTOLOGY.read_text(encoding="utf-8"))
    db = sqlite3.connect(DB_PATH)
    db.row_factory = sqlite3.Row
    apps = {r["id"]: dict(r) for r in db.execute("SELECT * FROM applications")}
    dbms = {}
    for r in db.execute("SELECT app_id, dbms, role FROM app_dbms"):
        dbms.setdefault(r["app_id"], []).append(f"{r['dbms']}({r['role']})")
    catalog = [dict(r) for r in db.execute("SELECT * FROM dep_catalog")]
    return onto, db, apps, dbms, catalog


def validate(onto, apps) -> list[str]:
    """Quality gate. Una aplicacion sin decision es un hueco, no un default."""
    errs = []
    mapeo = onto["mapeo"]
    nuevos = onto["nodos_nuevos"]

    faltan = sorted(set(apps) - set(mapeo))
    if faltan:
        errs.append(f"{len(faltan)} aplicaciones del inventario sin decision en la "
                    f"ontologia: {', '.join(faltan)}")

    sobran = sorted(set(mapeo) - set(apps))
    if sobran:
        errs.append(f"{len(sobran)} decisiones apuntan a aplicaciones que el "
                    f"inventario no tiene: {', '.join(sobran)}")

    for app_id, m in mapeo.items():
        if m["d"] == "nueva" and m.get("node") not in nuevos:
            errs.append(f"La aplicacion {app_id} se declara nueva hacia "
                        f"'{m.get('node')}', que no esta en nodos_nuevos")
        if m["d"] in ("existente", "absorbida") and not m.get("node"):
            errs.append(f"La aplicacion {app_id} es '{m['d']}' y no dice hacia que nodo")

    usados = {m.get("node") for m in mapeo.values() if m["d"] == "nueva"}
    for slug in nuevos:
        if slug not in usados:
            errs.append(f"El nodo nuevo '{slug}' no tiene ninguna aplicacion asignada")

    return errs


# --------------------------------------------------------------------------- #
# Evidencia del Anexo 5 para un nodo
# --------------------------------------------------------------------------- #

def interfaces_for(node_slug, node_app_names, catalog):
    """Las interfaces del Anexo 5 donde participa alguna app del nodo.

    Quien traduce el nombre del catalogo al slug de un nodo es el grafo, en su
    CATALOGO_MAP, y lo deja escrito en dep_catalog.source y dep_catalog.target.
    Aqui se lee esa decision en vez de derivar una paralela: un segundo mapeo
    convertiria `Informix (Core OLTP)` en un nodo nuevo al lado del que ya hay.

    Una contraparte sin slug no se inventa. Queda con `resuelto` en falso, se
    muestra en el CLAUDE.md como contexto y no llega al brain semilla, porque
    el canon dice que lo que el catalogo no mapea se queda en dep_catalog sin
    inventar aristas.
    """
    wanted = {norm(n) for n in node_app_names}
    out = []
    for row in catalog:
        o, d = norm(row["origen_app"]), norm(row["destino_app"])
        if o in wanted:
            otro_raw, otro_node, direction = row["destino_app"], row["target"], "outbound"
        elif d in wanted:
            otro_raw, otro_node, direction = row["origen_app"], row["source"], "inbound"
        else:
            continue
        if norm(otro_raw) in wanted or (otro_node and otro_node == node_slug):
            continue  # interfaz interna del propio nodo
        out.append({
            "other_raw": flat(otro_raw),
            "other_system": otro_node,
            "resuelto": bool(otro_node),
            "relationship": relationship_for(row["tipo"]),
            "direction": direction,
            "tipo": flat(row["tipo"]),
            "sincronia": flat(row["sincronia"]),
            "entidad": flat(row["entidad"]),
            "confianza": flat(row["confianza"]),
            "documento": flat(row["documento"]),
        })
    return out


# --------------------------------------------------------------------------- #
# Escritura: Regla B9 (estructura) y Regla B12 (brain semilla)
# --------------------------------------------------------------------------- #

def node_path(spec) -> Path:
    return SYSTEMS_ROOT / spec["togaf_type"] / spec["folder"]


def make_claude_md(slug, spec, node_apps, dbms, ifaces) -> str:
    togaf_type = spec["togaf_type"]
    system_of = SYSTEM_OF.get(togaf_type, "record")

    total_ops = sum(int(a["ops_day"] or 0) for a in node_apps)
    total_spl = sum(int(a["spl_declared"] or 0) for a in node_apps)
    total_hosts = sum(int(a["hosts"] or 0) for a in node_apps)
    motores = sorted({m.split("(")[0] for a in node_apps for m in dbms.get(a["id"], [])})
    middleware = sorted({flat(a["middleware"]) for a in node_apps
                         if flat(a["middleware"]) not in ("", "N/A", "??")})

    filas = "\n".join(
        f"| `{a['id']}` | {flat(a['nombre'])} | {flat(a['agrupacion'])} | "
        f"{flat(a['criticidad']) or '—'} | {flat(a['complejidad']) or '—'} | "
        f"{a['spl_declared'] or 0} | {a['hosts'] or 0} | {a['ops_day'] or 0} |"
        for a in node_apps
    )

    def tabla_if(rows):
        vistas = {}
        for i in rows:
            vistas.setdefault((i["other_raw"], i["relationship"], i["direction"]), []).append(i)
        return (
            "| Contraparte | Relacion | Direccion | Interfaces | Tipo | Confianza |\n"
            "|-------------|----------|-----------|-----------:|------|-----------|\n"
            + "\n".join(
                f"| {k[0]} | `{k[1]}` | `{k[2]}` | {len(v)} | {v[0]['tipo']} | {v[0]['confianza']} |"
                for k, v in sorted(vistas.items(), key=lambda kv: -len(kv[1]))
            )
        )

    resueltas = [i for i in ifaces if i["resuelto"]]
    sueltas = [i for i in ifaces if not i["resuelto"]]

    if ifaces:
        nota_if = (
            f"El Catalogo de Interfaces AS-IS del Anexo 5 declara {len(ifaces)} interfaces "
            f"en las que participa este sistema. La direccion viene del propio catalogo, "
            f"que la declara fila por fila, y por eso no queda como inferida."
        )
        partes = []
        if resueltas:
            partes.append("### Con sistemas del ecosistema\n\n"
                          "Estas son las que el brain semilla registra como "
                          "`cross_dependencies`.\n\n" + tabla_if(resueltas))
        if sueltas:
            partes.append(
                "### Con contrapartes que el grafo todavia no modela\n\n"
                "Quedan en `dep_catalog` y no generan arista. Son proveedores de "
                "servicio, motores de base de datos o sistemas externos sin nodo "
                "propio; inventarles un nodo ensuciaria el grafo.\n\n" + tabla_if(sueltas))
        bloque_if = "\n\n".join(partes)
    else:
        bloque_if = "_El Anexo 5 no declara interfaces para este sistema._"
        nota_if = ("El Catalogo de Interfaces del Anexo 5 no lo menciona. Su existencia "
                   "la sostiene el inventario de aplicaciones, que es fuente suficiente "
                   "bajo la Regla B8.")

    pendientes = spec.get("pendientes", [])
    bloque_pend = ""
    if pendientes:
        bloque_pend = ("\n## Preguntas abiertas\n\n"
                       + "\n".join(f"- {p}" for p in pendientes) + "\n\n---\n")

    return f"""# {spec['display']} — Sistema Descubierto (Application Modernization)
# togaf_type: {togaf_type}
# togaf_state: {spec['togaf_state']}
# togaf_system_of: {system_of}
# togaf_abb: {spec['abb']}

> **Descubierto por:** inventario de aplicaciones del banco, `Inventario_bdanalisis.xlsx`, verificado el 2026-08-20.
> **Fecha de apertura:** {TODAY}
> **Estado:** `[STATE: DISCOVERED]` — estructura canonica abierta por **Regla B9**, brain semilla por **Regla B12**.
> **Clasificacion:** `bank-brain/knowledge-base/ontology/app-to-node.json`

---

## Por que existe este nodo

{spec['razon']}

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `{togaf_type}` |
| `togaf_state` | `{spec['togaf_state']}` |
| `togaf_system_of` | `{system_of}` |
| `togaf_abb` | `{spec['abb']}` |
| `bian_domains` | Pendiente de mapeo |

---

## Que cubre, segun el inventario del banco

| Id | Aplicacion | Agrupacion | Criticidad | Complejidad | SPL | Hosts | Ops/dia |
|----|-----------|------------|------------|-------------|----:|------:|--------:|
{filas}

Suma del nodo: {total_spl} Stored Procedures declarados, {total_hosts} hosts y {total_ops:,} operaciones diarias.
Motores de datos: {', '.join(motores) if motores else 'no declarado'}.
Middleware: {'; '.join(middleware) if middleware else 'no declarado'}.

---

## Dependencias conocidas — Anexo 5

{nota_if}

{bloque_if}

---
{bloque_pend}
## Proximos pasos para activar el brain

- [ ] Conseguir los artefactos fuente del sistema: codigo, configuracion, logs o export de su herramienta.
- [ ] Dejarlos en `source/` sin modificarlos.
- [ ] Escribir `digital-brain/build-brain.py`, preservando el `cross_dependencies` y los `signals` que este brain semilla ya trae.
- [ ] Validar las dependencias contra el equipo de BanCoppel.
- [ ] Emitir seeds propios por Regla B11 al cerrar el primer build.
- [ ] Reconstruir el grafo con `bank-brain/generators/build-dependency-graph.py`.

---

*Generado por `bank-brain/generators/bootstrap-from-inventory.py` el {TODAY}. Reglas B9 y B12 de Application Modernization.*
"""


SEEDED_BY = "inventario-aplicaciones"


def seed_brain_es_nuestro(db_file: Path) -> bool:
    """Solo se reescribe lo que este generador escribio. Un brain con fuente
    propia, o hecho a mano, no se toca aunque se pase --rebuild-seeds."""
    try:
        con = sqlite3.connect("file:" + str(db_file) + "?mode=ro", uri=True)
        row = con.execute("SELECT seeded_by FROM system_info LIMIT 1").fetchone()
        con.close()
        return bool(row) and row[0] == SEEDED_BY
    except sqlite3.Error:
        return False


def write_seed_brain(path: Path, slug, spec, node_apps, dbms, ifaces):
    db_file = path / "digital-brain" / "brain.db"
    if db_file.exists():
        if not (REBUILD and seed_brain_es_nuestro(db_file)):
            return False
        db_file.unlink()
    con = sqlite3.connect(db_file)
    con.executescript(SEED_BRAIN_SCHEMA)

    con.execute(
        "INSERT OR REPLACE INTO system_info "
        "(slug, display_name, togaf_type, togaf_state, togaf_abb, seeded_by, "
        " seeded_at, seed_version, brain_version) VALUES (?,?,?,?,?,?,?,?,?)",
        (slug, spec["display"], spec["togaf_type"], spec["togaf_state"], spec["abb"],
         SEEDED_BY, TODAY, "inventario-2026-08-20", "seed-1.0"),
    )

    for a in node_apps:
        con.execute(
            "INSERT OR REPLACE INTO inventory_apps "
            "(app_id, nombre, agrupacion, criticidad, complejidad, spl_declared, "
            " hosts, ops_day, dbms, middleware, hosting, source_doc) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
            (a["id"], flat(a["nombre"]), flat(a["agrupacion"]), flat(a["criticidad"]),
             flat(a["complejidad"]), a["spl_declared"] or 0, a["hosts"] or 0,
             a["ops_day"] or 0, ", ".join(dbms.get(a["id"], [])),
             flat(a["middleware"]), flat(a["hosting"]), flat(a["source_doc"])),
        )
        for tipo, val in (("ops_day", a["ops_day"]), ("hosts", a["hosts"]),
                          ("spl_declared", a["spl_declared"])):
            if val:
                con.execute(
                    "INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at) "
                    "VALUES (?,?,?,?,?)",
                    (tipo, "inventario-aplicaciones", int(val),
                     json.dumps({"app_id": a["id"], "nombre": flat(a["nombre"])},
                                ensure_ascii=False), TODAY),
                )

    agrupadas = {}
    for i in ifaces:
        if not i["resuelto"]:
            continue
        agrupadas.setdefault((i["other_system"], i["relationship"], i["direction"]), []).append(i)
    for (other, rel, direction), grupo in agrupadas.items():
        entidades = sorted({g["entidad"] for g in grupo if g["entidad"]})
        con.execute(
            "INSERT OR REPLACE INTO cross_dependencies "
            "(id, other_system, relationship, direction, volume, domains, regulation, "
            " description, criticality, origin_artifact, seeded_at) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            (f"{slug}-{other}-{rel}-{direction}", other, rel, direction, len(grupo),
             "[]", "[]",
             f"{grupo[0]['other_raw']} por {grupo[0]['tipo']} ({grupo[0]['sincronia']}). "
             + ("Entidades: " + "; ".join(entidades[:6]) if entidades else "Sin entidad declarada."),
             "unknown",
             "Catalogo de Interfaces AS-IS, Anexo 5", TODAY),
        )

    con.commit()
    con.close()
    return True


def create_node(slug, spec, node_apps, dbms, ifaces) -> tuple[str, Path]:
    path = node_path(spec)
    existed = path.exists()
    for sub in CANONICAL_SUBDIRS:
        (path / sub).mkdir(parents=True, exist_ok=True)
    claude = path / "CLAUDE.md"
    # Igual que con el brain semilla: solo se reescribe lo que este generador
    # escribio. Un CLAUDE.md que alguien ya edito a mano no se pisa.
    nuestro = claude.exists() and "bootstrap-from-inventory.py" in claude.read_text(
        encoding="utf-8", errors="replace")
    if not claude.exists() or (REBUILD and nuestro):
        claude.write_text(make_claude_md(slug, spec, node_apps, dbms, ifaces),
                          encoding="utf-8")
    seeded = write_seed_brain(path, slug, spec, node_apps, dbms, ifaces)
    if existed and not seeded:
        return "existia", path
    return ("completado" if existed else "creado"), path


# --------------------------------------------------------------------------- #
# Tabla app_nodes en bank-brain.db
# --------------------------------------------------------------------------- #

def load_app_nodes(db, onto, apps):
    db.executescript("""
    DROP TABLE IF EXISTS app_nodes;
    CREATE TABLE app_nodes (
        app_id      TEXT PRIMARY KEY REFERENCES applications(id),
        nombre      TEXT,
        decision    TEXT NOT NULL,
        node        TEXT,
        razon       TEXT,
        onto_version TEXT
    );
    CREATE INDEX idx_app_nodes_node     ON app_nodes(node);
    CREATE INDEX idx_app_nodes_decision ON app_nodes(decision);
    """)
    ver = onto.get("version", "?")
    nuevos = onto["nodos_nuevos"]
    rows = []
    for app_id, m in onto["mapeo"].items():
        if app_id not in apps:
            continue
        razon = m.get("razon") or (nuevos.get(m.get("node"), {}).get("razon")
                                   if m["d"] == "nueva" else None)
        rows.append((app_id, flat(apps[app_id]["nombre"]), m["d"], m.get("node"), razon, ver))
    db.executemany("INSERT INTO app_nodes VALUES (?,?,?,?,?,?)", rows)
    db.commit()
    return len(rows)


# --------------------------------------------------------------------------- #

def main():
    onto, db, apps, dbms, catalog = load_everything()

    errs = validate(onto, apps)
    if errs:
        print("La ontologia no cuadra con el inventario:")
        for e in errs:
            print(f"  [ERROR] {e}")
        sys.exit(1)

    mapeo = onto["mapeo"]
    nuevos = onto["nodos_nuevos"]

    n = load_app_nodes(db, onto, apps)
    print(f"app_nodes: {n} aplicaciones clasificadas (ontologia v{onto.get('version')})")

    conteo = {}
    for m in mapeo.values():
        conteo[m["d"]] = conteo.get(m["d"], 0) + 1
    print("  " + " | ".join(f"{k}={v}" for k, v in sorted(conteo.items())))
    print()

    por_nodo = {}
    for app_id, m in mapeo.items():
        if m["d"] == "nueva" and app_id in apps:
            por_nodo.setdefault(m["node"], []).append(apps[app_id])

    print(f"Nodos nuevos por Regla B9: {len(nuevos)}")
    print()
    hdr = (f"{'TIPO':<12} {'SLUG':<26} {'SPL':>6} {'HOSTS':>6} {'OPS/DIA':>10} "
           f"{'IF':>4} {'ARISTA':>7}  RUTA")
    print(hdr)
    print("=" * len(hdr))

    total_if = total_arista = 0
    resumen = {"creado": 0, "completado": 0, "existia": 0}
    for slug, spec in sorted(nuevos.items(), key=lambda kv: (kv[1]["togaf_type"], kv[0])):
        node_apps = por_nodo.get(slug, [])
        ifaces = interfaces_for(slug, [a["nombre"] for a in node_apps], catalog)
        n_arista = sum(1 for i in ifaces if i["resuelto"])
        total_if += len(ifaces)
        total_arista += n_arista
        spl = sum(int(a["spl_declared"] or 0) for a in node_apps)
        hosts = sum(int(a["hosts"] or 0) for a in node_apps)
        ops = sum(int(a["ops_day"] or 0) for a in node_apps)
        rel = f"systems/{spec['togaf_type']}/{spec['folder']}"

        if APPLY:
            estado, _ = create_node(slug, spec, node_apps, dbms, ifaces)
            resumen[estado] += 1
            marca = {"creado": "CREADO   ", "completado": "COMPLETADO", "existia": "EXISTIA  "}[estado]
        else:
            marca = "PENDIENTE" if not node_path(spec).exists() else "EXISTIA  "

        print(f"{spec['togaf_type']:<12} {slug:<26} {spl:>6} {hosts:>6} {ops:>10,} "
              f"{len(ifaces):>4} {n_arista:>7}  {rel}   {marca}")

    print()
    print(f"Interfaces del Anexo 5 sobre nodos nuevos: {total_if}. "
          f"De esas, {total_arista} resuelven contra un nodo del ecosistema y entran "
          f"al brain semilla; las otras {total_if - total_arista} se quedan en "
          f"dep_catalog sin inventar arista.")
    print()
    if APPLY:
        print(f"Resumen: {resumen['creado']} creados, {resumen['completado']} completados, "
              f"{resumen['existia']} ya estaban.")
        print("Siguiente paso: python generators/build-dependency-graph.py")
    else:
        print("Reporte sin escribir carpetas. Corre con --apply para crear la "
              "estructura canonica y los brains semilla, y agrega --rebuild-seeds "
              "para rehacer los que este mismo generador escribio.")

    db.close()


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
initialize-seed-brains.py — Regla B12: Seed Brain Initialization
Ningún brain arranca de cero si otro sistema ya tiene conocimiento sobre él.

Para cada sistema en systems/, lee los seeds que lo mencionan como receptor
y construye un brain.db mínimo con la "otra mitad del puente":
  - system_info: identidad TOGAF del sistema
  - cross_dependencies: relaciones conocidas desde el emisor, invertidas
  - signals: señales cuantitativas (endpoints, CTM jobs, error logs)

Dos ejes de evidencia (simbiosis lógica-operativa):
  * Lógica estática:  ATTACH, cross-DB calls, SP references → estructura
  * Operativa:        logs de error, métricas ESB, CTM runs → comportamiento

Uso:
    python bank-brain/initialize-seed-brains.py               # todos los sistemas
    python bank-brain/initialize-seed-brains.py --system SPEI # uno solo
"""

import json
import sqlite3
import sys
from datetime import date
from pathlib import Path

TARGET_SYSTEM = None
for arg in sys.argv[1:]:
    if not arg.startswith("--") :
        TARGET_SYSTEM = arg
    elif arg.startswith("--system="):
        TARGET_SYSTEM = arg.split("=", 1)[1]
    elif arg == "--system" and sys.argv.index(arg) + 1 < len(sys.argv):
        TARGET_SYSTEM = sys.argv[sys.argv.index(arg) + 1]

CLIENT_ROOT = Path(__file__).parent.parent
SYSTEMS_ROOT = CLIENT_ROOT / "systems"
TODAY = date.today().isoformat()

SEED_BRAIN_SCHEMA = """
CREATE TABLE IF NOT EXISTS system_info (
    slug                TEXT PRIMARY KEY,
    display_name        TEXT,
    togaf_type          TEXT,
    togaf_state         TEXT,
    togaf_abb           TEXT,
    seeded_by           TEXT,
    seeded_at           TEXT,
    seed_version        TEXT,
    brain_version       TEXT DEFAULT 'seed-1.0'
);

CREATE TABLE IF NOT EXISTS cross_dependencies (
    id                  TEXT PRIMARY KEY,
    other_system        TEXT NOT NULL,
    relationship        TEXT NOT NULL,
    direction           TEXT NOT NULL,
    volume              INTEGER DEFAULT 0,
    domains             TEXT DEFAULT '[]',
    regulation          TEXT DEFAULT '[]',
    description         TEXT,
    criticality         TEXT DEFAULT 'unknown',
    origin_artifact     TEXT,
    seeded_at           TEXT
);

CREATE TABLE IF NOT EXISTS signals (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    signal_type         TEXT NOT NULL,
    source_system       TEXT NOT NULL,
    value               INTEGER DEFAULT 0,
    metadata            TEXT DEFAULT '{}',
    seeded_at           TEXT
);

CREATE VIRTUAL TABLE IF NOT EXISTS cross_dependencies_fts
    USING fts5(id, other_system, relationship, description, content='cross_dependencies');
"""

# Invierte la dirección al pasar del emisor al receptor
def invert_direction(direction: str) -> str:
    return {"inbound": "outbound", "outbound": "inbound"}.get(direction, "unknown")

# Convierte el relationship a la perspectiva del receptor
# (la mayoría se mantiene simétrica; "orchestrates inbound" → receptor dice "orchestrates outbound")
def receptor_relationship(rel: str, direction: str) -> str:
    # direction es la del EMISOR; al invertir, describimos desde el RECEPTOR
    # Para hacer el brain del receptor human-readable
    if direction == "inbound":   # Informix recibía → el receptor envía
        return rel               # mantener (calls, orchestrates, reads)
    else:                        # Informix enviaba → el receptor recibe
        receive_map = {
            "feeds":       "receives-from",
            "writes":      "written-by",
            "calls":       "called-by",
            "reads":       "read-by",
            "notifies":    "notified-by",
            "orchestrates":"orchestrated-by",
        }
        return receive_map.get(rel, rel)


def collect_seeds_for(slug: str) -> list[dict]:
    """Busca todos los seeds donde target_system == slug."""
    found = []
    for seed_file in SYSTEMS_ROOT.rglob(f"digital-brain/seeds/{slug}-seed.json"):
        with open(seed_file, encoding="utf-8") as f:
            seed = json.load(f)
        found.append(seed)
    return found


def initialize_brain(system_path: Path, slug: str, seeds: list[dict]) -> bool:
    db_path = system_path / "digital-brain" / "brain.db"

    # Si ya existe un brain.db, detectar si es completo (build-brain.py) o seed
    if db_path.exists():
        conn = sqlite3.connect(db_path)
        try:
            tables = {r[0] for r in conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table'"
            ).fetchall()}

            if "system_info" not in tables:
                # brain.db con esquema de build-brain.py real → no tocar
                conn.close()
                return False

            version = conn.execute(
                "SELECT brain_version FROM system_info WHERE slug=?", (slug,)
            ).fetchone()
            # None = tabla existe pero no es este brain; non-seed = brain completo
            if version is None or not version[0].startswith("seed-"):
                conn.close()
                return False  # brain ajeno o completo — no tocar
        except Exception:
            conn.close()
            return False  # cualquier error → conservar
        conn.close()

    if not (system_path / "digital-brain").exists():
        (system_path / "digital-brain").mkdir(parents=True, exist_ok=True)

    conn = sqlite3.connect(db_path)
    conn.executescript(SEED_BRAIN_SCHEMA)

    # Limpiar datos previos de seed (idempotente)
    conn.execute("DELETE FROM signals")
    conn.execute("DELETE FROM cross_dependencies")

    # Tomar metadatos del primer seed disponible
    primary = seeds[0]
    emitters = list({s["source_system"] for s in seeds})

    conn.execute("""
        INSERT OR REPLACE INTO system_info
            (slug, display_name, togaf_type, togaf_state, togaf_abb,
             seeded_by, seeded_at, seed_version, brain_version)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, (
        slug,
        primary.get("target_system_display", slug),
        primary.get("target_togaf_type", "unknown"),
        primary.get("togaf_state", "discovered"),
        primary.get("target_togaf_abb", "—"),
        json.dumps(emitters),
        TODAY,
        primary.get("source_version", "unknown"),
        "seed-1.0",
    ))

    for seed in seeds:
        src = seed.get("source_system", "unknown")
        rel = seed.get("relationship", "unknown")
        src_direction = seed.get("evidence", {}).get("direction") or (
            "outbound" if rel in ("feeds", "writes", "calls", "notifies") else "inbound"
        )
        recv_direction = invert_direction(src_direction)
        recv_rel = receptor_relationship(rel, src_direction)
        ev = seed.get("evidence", {})
        volume = ev.get("volume_endpoints") or ev.get("ctm_job_count", 0)
        dep_id = ev.get("dep_id", f"{src}-{slug}-{rel}")

        conn.execute("""
            INSERT OR REPLACE INTO cross_dependencies
                (id, other_system, relationship, direction, volume,
                 domains, regulation, description, criticality, origin_artifact, seeded_at)
            VALUES (?,?,?,?,?,?,?,?,?,?,?)
        """, (
            dep_id,
            src,
            recv_rel,
            recv_direction,
            volume,
            json.dumps(ev.get("domains", [])),
            json.dumps(ev.get("regulation", [])),
            ev.get("cross_dep_description") or ev.get("description", ""),
            ev.get("criticality", "unknown"),
            ev.get("origin_artifact", ""),
            TODAY,
        ))

        # Señal: volumen de endpoints
        if volume > 0:
            sig_type = "ctm_job" if ev.get("ctm_job_count") else "endpoint"
            conn.execute("""
                INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at)
                VALUES (?,?,?,?,?)
            """, (
                sig_type, src, volume,
                json.dumps({"relationship": rel, "origin": ev.get("origin_artifact", "")}),
                TODAY,
            ))

        # Señal: dominios involucrados (señal de cobertura funcional)
        for domain in ev.get("domains", []):
            conn.execute("""
                INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at)
                VALUES (?,?,?,?,?)
            """, (
                "domain_coverage", src, 1,
                json.dumps({"domain": domain, "relationship": rel}),
                TODAY,
            ))

        # Señal: regulación aplicable (señal de riesgo regulatorio)
        for reg in ev.get("regulation", []):
            conn.execute("""
                INSERT INTO signals (signal_type, source_system, value, metadata, seeded_at)
                VALUES (?,?,?,?,?)
            """, (
                "regulatory_signal", src, 1,
                json.dumps({"regulation": reg, "relationship": rel}),
                TODAY,
            ))

    # Reconstruir FTS
    conn.execute("INSERT INTO cross_dependencies_fts(cross_dependencies_fts) VALUES('rebuild')")

    conn.commit()
    conn.close()
    return True


def find_system_path(slug: str) -> Path | None:
    """Busca la carpeta del sistema en systems/ por slug (busca el CLAUDE.md)."""
    for claude_md in SYSTEMS_ROOT.rglob("CLAUDE.md"):
        # leer primera línea del CLAUDE.md para buscar el slug
        text = claude_md.read_text(encoding="utf-8", errors="replace")
        if f"target_system: {slug}" in text or f'"{slug}"' in text:
            return claude_md.parent
        # también intentar por nombre de carpeta
        if claude_md.parent.name.lower().replace("-", "") == slug.replace("-", ""):
            return claude_md.parent
    return None


def all_system_slugs() -> list[tuple[str, Path]]:
    """Devuelve (slug, path) de todos los sistemas en systems/."""
    results = []
    for claude_md in SYSTEMS_ROOT.rglob("CLAUDE.md"):
        # excluir sub-agentes (dt/, agent-profiles/)
        parts = claude_md.parts
        if "dt" in parts or "agent-profiles" in parts:
            continue
        folder = claude_md.parent
        # derivar slug desde nombre de carpeta
        slug_candidate = folder.name.lower().replace("-", "-")
        results.append((slug_candidate, folder))
    return results


def slug_from_folder(folder_name: str) -> str:
    """Convierte nombre de carpeta a slug para buscar seeds."""
    mapping = {
        "AppMovil":       "app-movil",
        "BancaInternet":  "banca-x-internet",
        "BanCoppelClic":  "bancoppel-clic",
        "CajeroATM":      "cajero-atm",
        "Corresponsales": "oxxo-corresponsal",
        "IST":            "ist-atm",
        "PayTrue":        "paytrue",
        "BuroCredito":    "buro-de-credito",
        "Domiciliacion":  "domiciliacion",
        "Grandata":       "grandata",
        "MoneyGram":      "moneygram",
        "PROSA":          "prosa-switch",
        "SmartVista":     "smartvista",
        "WesternUnion":   "western-union",
        "CoDi":           "codi-banxico",
        "ControlM":       "controlm",
        "EGlobal":        "e-global",
        "MuleSoft":       "mulesoft",
        "NominaCoppel":   "nomina-coppel",
        "SPEI":           "spei-banxico",
        "SPID":           "spid-usd",
        "Atlas":          "atlas",
        "DataStage":      "datastage",
        "Digitalizacion": "digitalizacion",
        "Yellowbrick":    "yellowbrick",
        "Banxico":        "banxico",
        "CNBV":           "cnbv",
        "IPAB":           "ipab",
        "PLD":            "pld-minds",
        "Riesgos":        "sistema-riesgos",
        "SAT":            "sat-fiscal",
        "UIF":            "uif-pld",
        "Informix":       "informix",
    }
    return mapping.get(folder_name, folder_name.lower())


def main():
    print("Initialize Seed Brains — Regla B12 AM")
    print(f"Client root: {CLIENT_ROOT}")
    print()

    initialized = []
    skipped_complete = []
    skipped_no_seeds = []

    for claude_md in sorted(SYSTEMS_ROOT.rglob("CLAUDE.md")):
        # Excluir sub-agentes
        parts = claude_md.parts
        if "dt" in parts or "agent-profiles" in parts:
            continue

        system_dir = claude_md.parent
        folder_name = system_dir.name

        # Filtro por --system si se especificó
        if TARGET_SYSTEM and TARGET_SYSTEM.lower() not in folder_name.lower():
            continue

        slug = slug_from_folder(folder_name)

        seeds = collect_seeds_for(slug)
        if not seeds:
            skipped_no_seeds.append(folder_name)
            print(f"  NO SEEDS  {folder_name:30s} (slug={slug})")
            continue

        was_init = initialize_brain(system_dir, slug, seeds)
        if was_init:
            n_deps = sum(1 for _ in sqlite3.connect(
                system_dir / "digital-brain" / "brain.db"
            ).execute("SELECT id FROM cross_dependencies"))
            n_sigs = sum(1 for _ in sqlite3.connect(
                system_dir / "digital-brain" / "brain.db"
            ).execute("SELECT id FROM signals"))
            initialized.append(folder_name)
            print(f"  INIT      {folder_name:30s} {len(seeds)} seed(s) · {n_deps} deps · {n_sigs} signals")
        else:
            skipped_complete.append(folder_name)
            print(f"  SKIP      {folder_name:30s} (brain completo — no tocar)")

    print()
    print(f"Resumen: {len(initialized)} inicializados · {len(skipped_complete)} completos · {len(skipped_no_seeds)} sin seeds")


if __name__ == "__main__":
    main()
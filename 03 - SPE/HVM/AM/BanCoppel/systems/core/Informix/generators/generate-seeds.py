#!/usr/bin/env python3
"""
generate-seeds.py — Regla B11: Seed Generation (Cross-Brain Seeding)
Informix Informix — implementación de referencia AM.

Lee brain.db y emite digital-brain/seeds/{sistema}-seed.json para cada
sistema con evidencia de relación. Idempotente: refleja el estado actual del brain.

Fuentes de señal:
  1. external_systems  — 18 sistemas externos con volumetría de endpoints
  2. cross_dependencies — dependencias declaradas (ambas direcciones)
  3. ctm_jobs           — carpetas CTM que revelan sistemas con batch propio
"""

import json
import re
import sqlite3
from datetime import date
from pathlib import Path

# ---------------------------------------------------------------------------
BASE = Path(__file__).parent.parent
DB_PATH = BASE / "digital-brain" / "brain.db"
SEEDS_DIR = BASE / "digital-brain" / "seeds"

SOURCE_SYSTEM = "informix"
SOURCE_TOGAF_TYPE = "core"
SOURCE_VERSION = "Informix v1.8.0"

# ---------------------------------------------------------------------------
# TOGAF type mapping — slug → tipo canónico
TOGAF_TYPE = {
    # channels
    "app-movil":          "channels",
    "banca-internet":     "channels",
    "banca-x-internet":   "channels",
    "bancoppel-clic":     "channels",
    "cajero-atm":         "channels",
    "oxxo-corresponsal":  "channels",
    "paytrue":            "channels",
    "ist-atm":            "channels",
    # processors
    "buro-de-credito":    "processors",
    "prosa-switch":       "processors",
    "domiciliacion":      "processors",
    "western-union":      "processors",
    "moneygram":          "processors",
    "smartvista":         "processors",
    "grandata":           "processors",
    # integration
    "mulesoft":           "integration",
    "e-global":           "integration",
    "controlm":           "integration",
    "nomina-coppel":      "integration",
    "spei-banxico":       "integration",
    "codi-banxico":       "integration",
    "spid-usd":           "integration",
    # data
    "atlas":              "data",
    "datastage":          "data",
    "yellowbrick":        "data",
    "digitalizacion":     "data",
    # compliance
    "cnbv":               "compliance",
    "sat-fiscal":         "compliance",
    "uif-pld":            "compliance",
    "pld-minds":          "compliance",
    "ipab":               "compliance",
    "banxico":            "compliance",
    "sistema-riesgos":    "compliance",
}

# Dominios Informix relevantes por categoría de sistema externo
DOMAINS_BY_CATEGORY = {
    "Pagos Banxico":    ["D13", "D14", "D08"],
    "Crédito/Tarjetas": ["D03", "D16", "D05"],
    "Remesas":          ["D09", "D10"],
    "Red física":       ["D04", "D11"],
    "Canales propios":  ["D01", "D02"],
    "Grupo Coppel":     ["D03", "D05"],
    "Reguladores":      ["D15", "D13", "D16"],
}

REGULATION_BY_CATEGORY = {
    "Pagos Banxico":    ["Banxico SPEI", "CNBV CUB"],
    "Crédito/Tarjetas": ["CNBV CUB Cap.XI", "VISA/MC Issuer Rules"],
    "Remesas":          ["Banxico", "CNBV Remesas"],
    "Red física":       ["CNBV Corresponsales"],
    "Canales propios":  ["CNBV Banca Electrónica"],
    "Reguladores":      ["CNBV", "SAT", "CONDUSEF"],
    "Grupo Coppel":     [],
}

# CTM folders → (slug, display_name, togaf_type, domains)
CTM_SYSTEMS = {
    "PRO_ATM_IST_001":              ("ist-atm",         "IST/ATM",          "channels",    ["D04"]),
    "PRO_PLD_MINDS_001":            ("pld-minds",       "PLD/Minds",        "compliance",  ["D15"]),
    "USV-UNITY_SMARTVISTA_001":     ("smartvista",      "SmartVista/Unity", "processors",  ["D16"]),
    "PRO_GRANDATA_001":             ("grandata",        "Grandata (scoring)","processors", ["D03"]),
    "PRO_RIESGOS_001":              ("sistema-riesgos", "Sistema Riesgos",  "compliance",  ["D48"]),
    "PRO_DATA_WAREHOUSE_001":       ("yellowbrick",     "Yellowbrick DW",   "data",        []),
}


def fix_encoding(s: str) -> str:
    """Repara doble-encoding latin-1/utf-8 carácter a carácter por pares.
    Ej: 'NÃ³mina' → 'Nómina', 'SPEI Â· Banxico' → 'SPEI · Banxico'."""
    result = []
    chars = list(s)
    i = 0
    while i < len(chars):
        c = chars[i]
        if ord(c) > 127 and i + 1 < len(chars):
            try:
                pair = c.encode("latin-1") + chars[i + 1].encode("latin-1")
                result.append(pair.decode("utf-8"))
                i += 2
                continue
            except (UnicodeEncodeError, UnicodeDecodeError):
                pass
        result.append(c)
        i += 1
    return "".join(result)


def slugify(name: str) -> str:
    """Normaliza a slug ASCII, reparando doble-encoding del DB primero."""
    import unicodedata
    s = fix_encoding(name)
    s = unicodedata.normalize("NFD", s.lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    s = re.sub(r"[·/\\\s·]+", "-", s)
    s = re.sub(r"[^a-z0-9\-]", "", s)
    return re.sub(r"-+", "-", s).strip("-")


def write_seed(seed: dict) -> str:
    SEEDS_DIR.mkdir(parents=True, exist_ok=True)
    fname = f"{seed['target_system']}-seed.json"
    with open(SEEDS_DIR / fname, "w", encoding="utf-8") as f:
        json.dump(seed, f, ensure_ascii=False, indent=2)
    return fname


def make_seed(slug: str, display: str, togaf_type: str, relationship: str,
              evidence: dict) -> dict:
    return {
        "source_system": SOURCE_SYSTEM,
        "source_togaf_type": SOURCE_TOGAF_TYPE,
        "target_system": slug,
        "target_system_display": fix_encoding(display),
        "target_togaf_type": togaf_type,
        "generated_at": date.today().isoformat(),
        "source_version": SOURCE_VERSION,
        "relationship": relationship,
        "evidence": evidence,
    }


def main():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row

    seeds: dict[str, dict] = {}   # slug → seed
    manifest: list[dict] = []

    # -----------------------------------------------------------------------
    # SOURCE 1: external_systems
    print("SOURCE 1 — external_systems")
    for row in conn.execute(
        "SELECT id, category, total_endpoints FROM external_systems ORDER BY total_endpoints DESC"
    ):
        display = row["id"]
        slug = slugify(display)
        category = row["category"]
        n = row["total_endpoints"]

        rel = "feeds" if category in ("Reguladores", "Pagos Banxico", "Remesas") else "calls"

        seed = make_seed(
            slug, display,
            TOGAF_TYPE.get(slug, "unknown"),
            rel,
            {
                "component_count": n,
                "volume_endpoints": n,
                "domains": DOMAINS_BY_CATEGORY.get(category, []),
                "regulation": REGULATION_BY_CATEGORY.get(category, []),
                "category": category,
                "origin_artifact": "digital-brain/brain.db::external_systems",
            },
        )
        seeds[slug] = seed
        print(f"  {slug:30s}  {n:4d} endpoints  [{category}]")

    # -----------------------------------------------------------------------
    # SOURCE 2: cross_dependencies
    print("\nSOURCE 2 — cross_dependencies")
    for row in conn.execute(
        "SELECT id, other_system, dependency_type, direction, description, evidence, criticality "
        "FROM cross_dependencies"
    ):
        slug = slugify(row["other_system"])
        rel = row["dependency_type"]
        direction = row["direction"]
        crit = row["criticality"]

        dep_evidence = {
            "dep_id": row["id"],
            "direction": direction,
            "criticality": crit,
            "description": row["description"],
            "raw_evidence": row["evidence"],
            "domains": [],
            "regulation": [],
            "origin_artifact": "digital-brain/brain.db::cross_dependencies",
        }

        if slug in seeds:
            # Merge into existing seed from external_systems
            seeds[slug]["evidence"]["dep_id"] = row["id"]
            seeds[slug]["evidence"]["direction"] = direction
            seeds[slug]["evidence"]["criticality"] = crit
            seeds[slug]["evidence"]["cross_dep_description"] = row["description"]
            print(f"  {slug:30s}  merged (crit={crit}, {rel} {direction})")
        else:
            seeds[slug] = make_seed(
                slug, row["other_system"],
                TOGAF_TYPE.get(slug, "unknown"),
                rel,
                dep_evidence,
            )
            print(f"  {slug:30s}  new    (crit={crit}, {rel} {direction})")

    # -----------------------------------------------------------------------
    # SOURCE 3: CTM folders
    print("\nSOURCE 3 — ctm_jobs (carpetas cross-sistema)")
    for folder, (slug, display, togaf_type, domains) in CTM_SYSTEMS.items():
        cnt = conn.execute(
            "SELECT COUNT(*) FROM ctm_jobs WHERE folder=?", (folder,)
        ).fetchone()[0]
        if cnt == 0:
            continue

        ctm_evidence = {
            "ctm_folder": folder,
            "ctm_job_count": cnt,
            "domains": domains,
            "regulation": [],
            "origin_artifact": f"digital-brain/brain.db::ctm_jobs (folder={folder})",
        }

        if slug in seeds:
            seeds[slug]["evidence"]["ctm_folder"] = folder
            seeds[slug]["evidence"]["ctm_job_count"] = cnt
            if domains:
                seeds[slug]["evidence"].setdefault("domains", [])
                for d in domains:
                    if d not in seeds[slug]["evidence"]["domains"]:
                        seeds[slug]["evidence"]["domains"].append(d)
            print(f"  {slug:30s}  merged CTM {folder} ({cnt} jobs)")
        else:
            seeds[slug] = make_seed(slug, display, togaf_type, "feeds", ctm_evidence)
            print(f"  {slug:30s}  new CTM {folder} ({cnt} jobs)")

    conn.close()

    # -----------------------------------------------------------------------
    # Write seeds + manifest
    print(f"\nWriting {len(seeds)} seeds to {SEEDS_DIR}/")
    for slug, seed in seeds.items():
        fname = write_seed(seed)
        manifest.append({
            "file": fname,
            "target_system": slug,
            "target_togaf_type": seed["target_togaf_type"],
            "relationship": seed["relationship"],
            "volume": seed["evidence"].get("volume_endpoints") or seed["evidence"].get("ctm_job_count", 0),
        })
        print(f"  -> {fname}")

    manifest_doc = {
        "source_system": SOURCE_SYSTEM,
        "source_version": SOURCE_VERSION,
        "generated_at": date.today().isoformat(),
        "total_seeds": len(seeds),
        "seeds": sorted(manifest, key=lambda x: -x["volume"]),
    }
    with open(SEEDS_DIR / "manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest_doc, f, ensure_ascii=False, indent=2)

    print(f"\nManifest: {SEEDS_DIR / 'manifest.json'}")
    print(f"Total: {len(seeds)} seeds")


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
bootstrap-from-seeds.py — Regla B9 automatizada (AM global)
Lee todos los digital-brain/seeds/ en systems/ y crea la estructura canónica
para cada sistema descubierto que aún no tenga carpeta.

Regla: si el sistema existe en un seed, su estructura canónica debe existir HOY.
El brain se llena después; la estructura es el compromiso inmediato.

Uso:
    python bank-brain/bootstrap-from-seeds.py [--dry-run]
"""

import json
import sys
from datetime import date
from pathlib import Path

DRY_RUN = "--dry-run" in sys.argv

CLIENT_ROOT = Path(__file__).parent.parent   # BanCoppel/
SYSTEMS_ROOT = CLIENT_ROOT / "systems"

# Mapeo slug → nombre de carpeta (nombre del sistema como se conoce)
FOLDER_NAME: dict[str, str] = {
    # channels
    "app-movil":          "AppMovil",
    "banca-x-internet":   "BancaInternet",
    "bancoppel-clic":     "BanCoppelClic",
    "cajero-atm":         "CajeroATM",
    "ist-atm":            "IST",
    "oxxo-corresponsal":  "Corresponsales",
    "paytrue":            "PayTrue",
    # processors
    "buro-de-credito":    "BuroCredito",
    "domiciliacion":      "Domiciliacion",
    "grandata":           "Grandata",
    "moneygram":          "MoneyGram",
    "prosa-switch":       "PROSA",
    "smartvista":         "SmartVista",
    "western-union":      "WesternUnion",
    # integration
    "codi-banxico":       "CoDi",
    "controlm":           "ControlM",
    "e-global":           "EGlobal",
    "mulesoft":           "MuleSoft",
    "nomina-coppel":      "NominaCoppel",
    "spei-banxico":       "SPEI",
    "spid-usd":           "SPID",
    # data
    "atlas":              "Atlas",
    "datastage":          "DataStage",
    "digitalizacion":     "Digitalizacion",
    "yellowbrick":        "Yellowbrick",
    # compliance
    "banxico":            "Banxico",
    "cnbv":               "CNBV",
    "ipab":               "IPAB",
    "pld-minds":          "PLD",
    "sat-fiscal":         "SAT",
    "sistema-riesgos":    "Riesgos",
    "uif-pld":            "UIF",
}

# TOGAF system_of por tipo
SYSTEM_OF: dict[str, str] = {
    "core":        "record",
    "processors":  "record",
    "channels":    "differentiation",
    "data":        "innovation",
    "integration": "innovation",
    "compliance":  "record",
}

# ABB canónico por slug (Banking Enterprise capability)
ABB: dict[str, str] = {
    "app-movil":          "digital-banking-mobile",
    "banca-x-internet":   "digital-banking-web",
    "bancoppel-clic":     "digital-banking-web",
    "cajero-atm":         "atm-cash-management",
    "ist-atm":            "atm-cash-management",
    "oxxo-corresponsal":  "correspondent-banking",
    "paytrue":            "fraud-prevention",
    "buro-de-credito":    "credit-bureau",
    "domiciliacion":      "direct-debit",
    "grandata":           "credit-scoring",
    "moneygram":          "remittance",
    "prosa-switch":       "card-processing",
    "smartvista":         "card-processing",
    "western-union":      "remittance",
    "codi-banxico":       "instant-payments",
    "controlm":           "batch-orchestration",
    "e-global":           "payment-authorization",
    "mulesoft":           "api-integration",
    "nomina-coppel":      "payroll-integration",
    "spei-banxico":       "interbank-transfers",
    "spid-usd":           "fx-transfers",
    "atlas":              "data-platform",
    "datastage":          "etl-pipeline",
    "digitalizacion":     "document-management",
    "yellowbrick":        "data-warehouse",
    "banxico":            "central-bank-regulatory",
    "cnbv":               "banking-regulator",
    "ipab":               "deposit-insurance",
    "pld-minds":          "aml-compliance",
    "sat-fiscal":         "tax-authority",
    "sistema-riesgos":    "risk-management",
    "uif-pld":            "financial-intelligence",
}

# Sistemas externos/reguladores (no son propiedad de BanCoppel)
EXTERNAL_SYSTEMS = {
    "banxico", "cnbv", "ipab", "sat-fiscal", "uif-pld",
    "spei-banxico", "codi-banxico", "spid-usd",
    "western-union", "moneygram", "buro-de-credito",
    "grandata", "prosa-switch",
}

TODAY = date.today().isoformat()


def canonical_subdirs() -> list[str]:
    return ["source/code", "source/docs", "source/ops",
            "digital-brain", "knowledge-base/rules", "knowledge-base/vocab",
            "knowledge-base/ontology", "knowledge-base/regulacion",
            "generators", "dt", "portal/data", "old"]


def make_claude_md(slug: str, seed: dict) -> str:
    display = seed.get("target_system_display", slug)
    togaf_type = seed.get("target_togaf_type", "unknown")
    togaf_state = "external" if slug in EXTERNAL_SYSTEMS else "discovered"
    system_of = SYSTEM_OF.get(togaf_type, "record")
    abb = ABB.get(slug, f"{togaf_type}-{slug}")
    relationship = seed.get("relationship", "unknown")
    ev = seed.get("evidence", {})
    volume = ev.get("volume_endpoints") or ev.get("ctm_job_count", 0)
    criticality = ev.get("criticality", "unknown")
    direction = ev.get("direction", "unknown")
    domains = ev.get("domains", [])
    regulation = ev.get("regulation", [])
    origin = ev.get("origin_artifact", "digital-brain/seeds")
    source_version = seed.get("source_version", "Informix v1.8.0")

    rel_path_to_informix_seed = (
        "../../core/Informix/digital-brain/seeds/" + slug + "-seed.json"
    )

    cross_dep_desc = ev.get("cross_dep_description") or ev.get("description", "—")

    domains_str = ", ".join(domains) if domains else "—"
    reg_str = ", ".join(regulation) if regulation else "—"

    return f"""# {display} — Sistema Descubierto (Application Modernization)
# togaf_type: {togaf_type}
# togaf_state: {togaf_state}
# togaf_system_of: {system_of}
# togaf_abb: {abb}

> **Descubierto por:** Informix Informix seed — [{slug}-seed.json]({rel_path_to_informix_seed})
> **Fecha descubrimiento:** {TODAY}
> **Estado:** `[STATE: DISCOVERED]` — estructura canónica abierta por **Regla B9**. Brain pendiente.
> **Regla B10:** este CLAUDE.md es el registro del otro lado de la relación hasta que exista un brain propio.

---

## Metadata TOGAF

| Campo | Valor |
|-------|-------|
| `togaf_type` | `{togaf_type}` |
| `togaf_state` | `{togaf_state}` |
| `togaf_system_of` | `{system_of}` |
| `togaf_abb` | `{abb}` |
| `bian_domains` | — *(pendiente de mapeo)* |

---

## Relación con Informix PISA — desde seed

| Campo | Valor |
|-------|-------|
| Relación | `{relationship}` |
| Dirección | `{direction}` (Informix es el {("emisor" if direction == "outbound" else "receptor")}) |
| Volumen conocido | {volume} {"endpoints" if ev.get("volume_endpoints") else "jobs CTM"} |
| Criticidad | `{criticality}` |
| Dominios Informix involucrados | {domains_str} |
| Regulación aplicable | {reg_str} |
| Descripción | {cross_dep_desc} |

---

## Seeds Recibidos

| Emisor | Versión | Fecha | Artefacto origen |
|--------|---------|-------|-----------------|
| `informix` | `{source_version}` | {TODAY} | `{origin}` |

---

## Próximos Pasos (DoR para activar brain)

- [ ] Obtener artefactos fuente del sistema: código, config, logs, inventario
- [ ] Mover artefactos a `source/` (readonly — no modificar originales)
- [ ] Construir `digital-brain/build-brain.py` para este sistema
- [ ] Validar cross-dependencies con equipo BanCoppel
- [ ] Emitir seeds propios (Regla B11) al terminar el primer build del brain
- [ ] Actualizar `bank-brain/build-bank-brain.py` con ATTACH a este brain

---

*Generado automáticamente por `bank-brain/bootstrap-from-seeds.py` · {TODAY} · Regla B9 AM*
"""


def collect_all_seeds() -> dict[str, dict]:
    """Busca todos los seeds/manifest.json en el árbol de sistemas y los agrega."""
    all_seeds: dict[str, dict] = {}
    for manifest_path in SYSTEMS_ROOT.rglob("digital-brain/seeds/manifest.json"):
        with open(manifest_path, encoding="utf-8") as f:
            manifest = json.load(f)
        seeds_dir = manifest_path.parent
        for entry in manifest.get("seeds", []):
            slug = entry["target_system"]
            seed_file = seeds_dir / f"{slug}-seed.json"
            if seed_file.exists():
                with open(seed_file, encoding="utf-8") as f:
                    seed_data = json.load(f)
                if slug not in all_seeds:
                    all_seeds[slug] = seed_data
                # Merge multi-source seeds (enriquecer con más evidencia si hay)
    return all_seeds


def system_path(slug: str, togaf_type: str) -> Path:
    folder = FOLDER_NAME.get(slug, slug.title().replace("-", ""))
    return SYSTEMS_ROOT / togaf_type / folder


def system_exists(slug: str, togaf_type: str) -> bool:
    return system_path(slug, togaf_type).exists()


def create_system(slug: str, seed: dict) -> tuple[bool, Path]:
    togaf_type = seed.get("target_togaf_type", "unknown")
    path = system_path(slug, togaf_type)

    if path.exists():
        return False, path  # already exists

    if not DRY_RUN:
        # Create canonical subdirs
        for subdir in canonical_subdirs():
            (path / subdir).mkdir(parents=True, exist_ok=True)

        # Write CLAUDE.md
        claude_md = make_claude_md(slug, seed)
        with open(path / "CLAUDE.md", "w", encoding="utf-8") as f:
            f.write(claude_md)

    return True, path


def main():
    print(f"{'[DRY RUN] ' if DRY_RUN else ''}Bootstrap from seeds — Regla B9 AM")
    print(f"Client root: {CLIENT_ROOT}")
    print(f"Systems root: {SYSTEMS_ROOT}")
    print()

    seeds = collect_all_seeds()
    print(f"Seeds encontrados: {len(seeds)}")
    print()

    created = []
    skipped = []

    for slug, seed in sorted(seeds.items(), key=lambda x: (
        x[1].get("target_togaf_type", ""), -x[1].get("evidence", {}).get("volume_endpoints", 0)
    )):
        togaf_type = seed.get("target_togaf_type", "unknown")
        was_created, path = create_system(slug, seed)
        folder_name = FOLDER_NAME.get(slug, slug)
        rel_path = f"systems/{togaf_type}/{folder_name}"

        if was_created:
            created.append(rel_path)
            print(f"  {'[DRY] ' if DRY_RUN else ''}CREATED  {rel_path}")
        else:
            skipped.append(rel_path)
            print(f"           EXISTS   {rel_path}")

    print()
    print(f"Resumen: {len(created)} creados · {len(skipped)} ya existían")
    if created and not DRY_RUN:
        print()
        print("Sistemas nuevos:")
        for p in created:
            print(f"  + {p}/")


if __name__ == "__main__":
    main()
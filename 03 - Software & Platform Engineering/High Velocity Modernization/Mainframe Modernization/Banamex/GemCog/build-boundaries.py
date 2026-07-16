#!/usr/bin/env python3
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
"""
Banamex Gemelo Cognitivo — Capa 5: Fronteras
Lee gemelo-*.json + dependency-graph-*.json + (opcional) rules-flags.json
→ produce data/boundaries-s500s151.json

Para cada uno de los 218 programas emite:
  - bounded_context (BC-01 … BC-09)
  - decision_7r (RETAIN | ENCAPSULATE | REPLATFORM | REFACTOR | RETIRE_CANDIDATE | FOLLOWS_HOST)
  - wave (0 | 1 | 2 | 3 | 4 | RETAIN | FASE-6 | RETIRE-VERIFY)
  - rationale (string conciso)
  - regulatory_flags (list)
  - sme_executor (string)
  - blockers (list)

Reglas de decisión: ver kb-capa5-fronteras.md §3

Uso:
  python build-boundaries.py
  python build-boundaries.py --output data/boundaries-custom.json
"""

import json
import argparse
from pathlib import Path
from dataclasses import dataclass, asdict, field
from typing import Optional

DATA_DIR = Path(__file__).parent / "data"

# ─── Bounded Context catalog ───────────────────────────────────────────────────

BC_CATALOG = {
    # S500
    "BC-01": "S500 / Cuentas de Captación",
    "BC-02": "S500 / Control Operacional",
    "BC-03": "S500 / Tarjetas Débito",
    "BC-04": "ACL GL Interface (S500 → S151)",
    # S151
    "BC-05": "S151 / General Ledger",
    "BC-06": "S151 / Procesamiento de Movimientos",
    "BC-07": "S151 / Control GL",
    "BC-08": "S151 / Reportería GL",
    "BC-09": "S151 / Ajustes GL",
}

# Domain → BC mapping (from kb-capa5-fronteras.md §2)
DOMAIN_TO_BC = {
    # S500 domains
    "CAPTACION":  "BC-01",
    "CONTROL":    "BC-02",
    "TARJETAS":   "BC-03",
    "ASINCRONA":  "BC-02",
    "TELETON":    "BC-02",
    "MAPLI":      "BC-02",
    # S151 domains
    "CONTABILIDAD": "BC-05",
    "MOVIMIENTOS":  "BC-06",
    "CTRL-GL":      "BC-07",
    "REPORTES":     "BC-08",
    "AJUSTES":      "BC-09",
}

# S151REGISTRA programs (Wave 0 ACL — BC-04)
S151REGISTRA_IDS = {"L002R2", "L002R3", "L002R4", "L002R5"}

# SME executors per decision
SME_BY_DECISION = {
    "ENCAPSULATE":      "Specialist - Encapsulation",
    "REFACTOR":         "Specialist - Transpilation",
    "REPLATFORM":       "Specialist - Batch Architecture → Transpilation",
    "RETAIN":           "Unisys Banking SME (advisory) · AMS Reinvention",
    "RETIRE_CANDIDATE": "Specialist - Reverse Engineering (verificación WFL)",
    "FOLLOWS_HOST":     "— (migra con su programa host)",
}

# Regulatory flags that indicate high sensitivity
HIGH_REG_FLAGS = {"CNBV", "BANXICO"}


# ─── Data model ───────────────────────────────────────────────────────────────

@dataclass
class Boundary:
    sistema: str
    id: str
    nombre: str
    tipo: str
    loc: int
    dominio: str
    bounded_context: str
    bc_name: str
    decision_7r: str
    wave: str
    rationale: str
    regulatory_flags: list = field(default_factory=list)
    sme_executor: str = ""
    blockers: list = field(default_factory=list)
    collision_warning: Optional[str] = None


# ─── 7R decision engine ────────────────────────────────────────────────────────

def apply_7r(obj: dict, sistema: str, reg_flags: list, has_callgraph_edges: bool) -> dict:
    """
    Returns dict: decision_7r, wave, rationale, sme_executor, blockers
    """
    tipo = obj.get("tipo", "").lower()
    prog_id = obj.get("id", "")
    loc = obj.get("loc", 0)
    is_batch = tipo in ("wfl",)
    has_high_reg = bool(set(reg_flags) & HIGH_REG_FLAGS)

    # ── S151REGISTRA ACL (Wave 0) ──────────────────────────────────────────────
    if prog_id in S151REGISTRA_IDS:
        return {
            "decision_7r": "ENCAPSULATE",
            "wave": "0",
            "rationale": "S151REGISTRA: ACL crítico S500→S151. ALGOL sin transpiler; encapsular como GL-Posting-Service API REST/gRPC. Prerequisito bloqueante para todas las demás waves.",
            "sme_executor": SME_BY_DECISION["ENCAPSULATE"],
            "blockers": ["Wave 0 debe completarse antes de cualquier otra wave."],
        }

    # ── DASDL (data schema DMSII) ──────────────────────────────────────────────
    if tipo == "dasdl":
        return {
            "decision_7r": "RETAIN",
            "wave": "FASE-6",
            "rationale": "Schema DMSII: migración del modelo de datos es actividad separada (Fase 6 Data Migration). No refactorizar — migrar con CDC + dual-write.",
            "sme_executor": SME_BY_DECISION["RETAIN"],
            "blockers": ["Requiere Fase 6 Data Migration plan — fuera de scope de waves 0-4."],
        }

    # ── WFL (job scheduler) ────────────────────────────────────────────────────
    if tipo == "wfl":
        return {
            "decision_7r": "REPLATFORM",
            "wave": "4",
            "rationale": "Job scheduler WFL: no hay equivalente COBOL que transpilar. Reescribir como DAG en Argo Workflows / AWS Step Functions. Requiere Batch Architecture sign-off previo.",
            "sme_executor": SME_BY_DECISION["REPLATFORM"],
            "blockers": [
                "Requiere Batch Architecture sign-off antes de iniciar.",
                "Depende de que los COBOL que orquesta estén en Wave 2+.",
            ],
        }

    # ── INC / Copybook ─────────────────────────────────────────────────────────
    if tipo in ("inc", "copy", "copybook", "include"):
        return {
            "decision_7r": "FOLLOWS_HOST",
            "wave": "—",
            "rationale": "Copybook/include: migra junto con el programa que lo usa. Se convierte en clase/record compartido en el target.",
            "sme_executor": SME_BY_DECISION["FOLLOWS_HOST"],
            "blockers": [],
        }

    # ── ALGOL (L-prefix, no S151REGISTRA) ─────────────────────────────────────
    if tipo == "algol" or (tipo == "" and prog_id.startswith("L") and prog_id not in S151REGISTRA_IDS):
        return {
            "decision_7r": "RETAIN",
            "wave": "RETAIN",
            "rationale": "ALGOL Unisys MCP: no existe transpiler comercial. RETAIN en pool hasta disponibilidad de herramienta. Si expone funcionalidad necesaria en target, encapsular como fachada API.",
            "sme_executor": SME_BY_DECISION["RETAIN"],
            "blockers": ["Unisys Banking SME advisory obligatorio antes de confirmar decisión definitiva."],
        }

    # ── Dead code candidate (no edges in call graph, small LOC) ───────────────
    if not has_callgraph_edges and loc < 500:
        return {
            "decision_7r": "RETIRE_CANDIDATE",
            "wave": "RETIRE-VERIFY",
            "rationale": f"Sin aristas en call graph y LOC={loc} < 500. Candidato a RETIRE. ALERTA: verificar contra WFL que puedan llamarlo fuera del análisis estático.",
            "sme_executor": SME_BY_DECISION["RETIRE_CANDIDATE"],
            "blockers": ["RE Specialist debe verificar WFL antes de emitir RETIRE definitivo."],
        }

    # ── COBOL with high regulatory flags + large LOC → RETAIN/ENCAPSULATE ─────
    if has_high_reg and loc > 5000:
        return {
            "decision_7r": "ENCAPSULATE",
            "wave": "2",
            "rationale": f"COBOL regulatorio crítico (flags={reg_flags}, LOC={loc}>5K). Riesgo de regresión regulatoria supera velocidad. ENCAPSULATE primero → REFACTOR posterior en Wave 2.",
            "sme_executor": SME_BY_DECISION["ENCAPSULATE"],
            "blockers": [
                "BC-04 ACL debe estar estable antes de Wave 2.",
                "Wave 1 debe estar verde.",
                "Regulatory SME debe confirmar flags antes de ADR.",
            ],
        }

    # ── COBOL with high regulatory flags + small-medium LOC ───────────────────
    if has_high_reg and loc <= 5000:
        return {
            "decision_7r": "ENCAPSULATE",
            "wave": "1-2",
            "rationale": f"COBOL con flags regulatorios (flags={reg_flags}, LOC={loc}≤5K). ENCAPSULATE para crear fachada API estable; REFACTOR en Wave 2 una vez verificada la equivalencia.",
            "sme_executor": SME_BY_DECISION["ENCAPSULATE"],
            "blockers": [
                "BC-04 ACL debe estar estable.",
                "Regulatory SME debe confirmar flags antes de ADR.",
            ],
        }

    # ── COBOL limpio — Wave 1 (bajo LOC) ──────────────────────────────────────
    if loc < 3000:
        return {
            "decision_7r": "REFACTOR",
            "wave": "1",
            "rationale": f"COBOL sin flags regulatorios críticos, LOC={loc}<3K. Candidato a transpilación Wave 1.",
            "sme_executor": SME_BY_DECISION["REFACTOR"],
            "blockers": ["BC-04 ACL debe estar estable (Wave 0 completada)."],
        }

    # ── COBOL limpio — Wave 2 (LOC medio) ─────────────────────────────────────
    if loc < 8000:
        return {
            "decision_7r": "REFACTOR",
            "wave": "2",
            "rationale": f"COBOL sin flags críticos, LOC={loc} (3K-8K). Refactor Wave 2 con revisión ampliada.",
            "sme_executor": SME_BY_DECISION["REFACTOR"],
            "blockers": [
                "BC-04 ACL estable.",
                "Wave 1 verde.",
            ],
        }

    # ── COBOL limpio — Wave 2/3 (alto LOC) ────────────────────────────────────
    return {
        "decision_7r": "REFACTOR",
        "wave": "2-3",
        "rationale": f"COBOL, LOC={loc}>8K. Evaluar si es batch (→ Batch Architecture sign-off · Wave 3) o transaccional (→ Wave 2 con revisión humana ampliada).",
        "sme_executor": SME_BY_DECISION["REFACTOR"],
        "blockers": [
            "Si es batch: Specialist - Batch Architecture sign-off obligatorio.",
            "BC-04 ACL estable.",
            "Wave 1 verde.",
        ],
    }


# ─── Bounded Context assignment ────────────────────────────────────────────────

def assign_bc(obj: dict, sistema: str, decision_7r: str) -> tuple[str, str]:
    """Returns (bc_id, bc_name)."""
    prog_id = obj.get("id", "")
    dominio = obj.get("dominio", "").upper()

    # S151REGISTRA always BC-04
    if prog_id in S151REGISTRA_IDS:
        return "BC-04", BC_CATALOG["BC-04"]

    bc_id = DOMAIN_TO_BC.get(dominio)
    if bc_id:
        return bc_id, BC_CATALOG[bc_id]

    # Fallback by sistema
    fallback = "BC-01" if sistema == "S500" else "BC-05"
    return fallback, BC_CATALOG[fallback] + " [ASIGNACIÓN PROVISIONAL — sin dominio mapeado]"


# ─── Main builder ──────────────────────────────────────────────────────────────

def load_json(path: Path) -> dict | list | None:
    if not path.exists():
        return None
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def build_call_graph_index(dep_graph: dict | None) -> set[str]:
    """Returns set of node IDs that have at least one edge."""
    if not dep_graph:
        return set()
    connected = set()
    for edge in dep_graph.get("edges", []):
        connected.add(edge.get("source", ""))
        connected.add(edge.get("target", ""))
    return connected


def collision_check(boundaries: list[Boundary]) -> None:
    """Flag programs with the same ID across S500 and S151."""
    by_id: dict[str, list[str]] = {}
    for b in boundaries:
        by_id.setdefault(b.id, []).append(b.sistema)
    for prog_id, sistemas in by_id.items():
        if len(sistemas) > 1:
            for b in boundaries:
                if b.id == prog_id:
                    b.collision_warning = f"⚠ ID '{prog_id}' existe en {', '.join(sistemas)}. Usar prefijo sistema en nombres target."


def run(output_path: Path) -> None:
    boundaries: list[Boundary] = []

    for sistema in ("S500", "S151"):
        gemelo_path  = DATA_DIR / sistema / f"gemelo-{sistema.lower()}.json"
        depgraph_path = DATA_DIR / sistema / f"dependency-graph-{sistema.lower()}.json"
        # Optional: rules flags per program (future enrichment)
        rules_path   = DATA_DIR / sistema / f"rules-flags-{sistema.lower()}.json"

        gemelo   = load_json(gemelo_path)
        dep_graph = load_json(depgraph_path)
        rules_flags = load_json(rules_path) or {}  # {program_id: [flags]}

        if not gemelo:
            print(f"[WARN] No encontrado: {gemelo_path} — saltando {sistema}")
            continue

        connected_ids = build_call_graph_index(dep_graph)

        objetos = gemelo.get("objetos", [])
        print(f"[{sistema}] {len(objetos)} objetos encontrados")

        for obj in objetos:
            prog_id = obj.get("id", "?")
            reg_flags = rules_flags.get(prog_id, [])
            has_edges = prog_id in connected_ids

            decision = apply_7r(obj, sistema, reg_flags, has_edges)
            bc_id, bc_name = assign_bc(obj, sistema, decision["decision_7r"])

            b = Boundary(
                sistema=sistema,
                id=prog_id,
                nombre=obj.get("nombre", prog_id),
                tipo=obj.get("tipo", "?"),
                loc=obj.get("loc", 0),
                dominio=obj.get("dominio", ""),
                bounded_context=bc_id,
                bc_name=bc_name,
                decision_7r=decision["decision_7r"],
                wave=decision["wave"],
                rationale=decision["rationale"],
                regulatory_flags=reg_flags,
                sme_executor=decision["sme_executor"],
                blockers=decision["blockers"],
            )
            boundaries.append(b)

    collision_check(boundaries)

    # ── Summary stats ──────────────────────────────────────────────────────────
    from collections import Counter
    decisions = Counter(b.decision_7r for b in boundaries)
    waves = Counter(b.wave for b in boundaries)
    bcs = Counter(b.bounded_context for b in boundaries)
    collisions = sum(1 for b in boundaries if b.collision_warning)

    summary = {
        "meta": {
            "total_programas": len(boundaries),
            "sistemas": ["S500", "S151"],
            "generado": "build-boundaries.py · Capa 5 GemCog",
        },
        "decisions_7r": dict(decisions),
        "wave_distribution": dict(waves),
        "bounded_contexts": {
            k: {"name": BC_CATALOG.get(k, k), "count": v}
            for k, v in sorted(bcs.items())
        },
        "collision_count": collisions,
        "programs": [asdict(b) for b in boundaries],
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)

    print(f"\n[OK] {len(boundaries)} programas → {output_path}")
    print(f"     7R: {dict(decisions)}")
    print(f"     Waves: {dict(sorted(waves.items()))}")
    print(f"     BCs: {dict(sorted(bcs.items()))}")
    if collisions:
        print(f"     ⚠  Colisiones de ID: {collisions} (ver collision_warning en JSON)")


# ─── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="GemCog Capa 5 — Bounded Context + 7R Analysis")
    parser.add_argument(
        "--output",
        default=str(DATA_DIR / "boundaries-s500s151.json"),
        help="Ruta del JSON de salida (default: data/boundaries-s500s151.json)",
    )
    args = parser.parse_args()
    run(Path(args.output))

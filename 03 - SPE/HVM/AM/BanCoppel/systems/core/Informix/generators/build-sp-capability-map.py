#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""build-sp-capability-map.py — Baseline de mapeo SP → capacidad de negocio (ETB L3)

Algoritmo de dos fases:

  SEED  (hop 0) : SPs ya asignados a una capacidad ETB L3 vía sp_capabilities
                  (mapeo fino explícito del analista / build-sp-fine-mapping.py).

  PROP  (hop 1+): Propagación iterativa por el call graph (tabla sp_calls).
                  Para cada SP sin asignar, si ≥ THRESHOLD de sus callers
                  ya pertenecen a la misma capacidad L3 → heredar esa asignación.
                  SPs con fan_in > MAX_FAN_IN se marcan "shared" (utilidad
                  transversal) y no se asignan a ninguna capacidad específica.

Salida: tabla sp_capability_map en brain.db (DROP+CREATE en cada ejecución).

Schema sp_calls : from_sp TEXT (caller), to_sp TEXT (callee), cross_db INTEGER
Schema sps      : id TEXT (db:sp_name), name TEXT, db TEXT, fan_in INTEGER
Schema sp_capabilities: sp_id TEXT, l3_id TEXT, mapping_type TEXT

Columnas de salida:
  sp_id, sp_name, db, l3_id, source (seed|inferred|shared),
  confidence, hop, caller_cap_pct
"""
import sqlite3, sys
from collections import defaultdict, Counter

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
BRAIN_DB = BASE + "digital-brain/brain.db"

# ── Parámetros ─────────────────────────────────────────────────────────────────
THRESHOLD  = 0.75   # fracción mínima de callers en misma L3 para propagar
MAX_FAN_IN = 20     # fan_in sobre este umbral → candidato a "shared utility"
MAX_HOPS   = 8      # profundidad máxima de propagación


def main() -> None:
    conn = sqlite3.connect(BRAIN_DB)
    conn.row_factory = sqlite3.Row

    # ── Cargar SPs ─────────────────────────────────────────────────────────────
    sps: dict[str, dict] = {
        r["id"]: {"name": r["name"], "db": r["db"] or "", "fan_in": r["fan_in"] or 0}
        for r in conn.execute("SELECT id, name, db, fan_in FROM sps")
    }
    print(f"SPs cargados       : {len(sps):,}")

    # ── Cargar call graph bidireccional ───────────────────────────────────────
    # sp_calls.from_sp = quien llama (caller); sp_calls.to_sp = quien es llamado (callee)
    # Dos índices:
    #   callee_to_callers[B] = [A, ...] — "quién me llama"  (dirección DOWNWARD)
    #   caller_to_callees[A] = [B, ...] — "a quién llamo"   (dirección UPWARD)
    # La estructura de Informix es leaf→seed: los SPs de dominio específico
    # (bajo fan_in) llaman a seeds; los seeds llaman a utilidades compartidas
    # (alto fan_in). Ambas direcciones son necesarias para propagación completa.
    callee_to_callers: dict[str, list[str]] = defaultdict(list)
    caller_to_callees: dict[str, list[str]] = defaultdict(list)
    n_edges = 0
    for r in conn.execute("SELECT from_sp, to_sp FROM sp_calls"):
        callee_to_callers[r["to_sp"]].append(r["from_sp"])
        caller_to_callees[r["from_sp"]].append(r["to_sp"])
        n_edges += 1
    print(f"Edges cargados     : {n_edges:,}")

    # ── Fase SEED (hop 0) ──────────────────────────────────────────────────────
    # Fuente de seeds: sps.primary_l3 — mapeo FINO explícito (analista / patterns).
    # Solo 3,811 SPs (~34.7%) tienen este campo seteado.
    # Los 7,157 SPs restantes son los que queremos inferir via propagación.
    # (sp_capabilities tiene primary/secondary para TODOS pero es mapeo coarse/amplio)
    # sp_id (TEXT) → {"l3_id": str, "source": str, "confidence": float,
    #                  "hop": int, "caller_cap_pct": float}
    assigned: dict[str, dict] = {}
    seed_count = 0

    seed_rows = conn.execute(
        "SELECT id, primary_l3, primary_l3_confidence "
        "FROM sps WHERE primary_l3 IS NOT NULL"
    ).fetchall()

    for r in seed_rows:
        assigned[r["id"]] = {
            "l3_id": r["primary_l3"],
            "source": "seed",
            "confidence": r["primary_l3_confidence"] if r["primary_l3_confidence"] is not None else 1.0,
            "hop": 0,
            "caller_cap_pct": 1.0,
        }
        seed_count += 1

    print(f"\nSeed (hop 0)       : {seed_count:,}")

    # ── Fase PROPAGACIÓN bidireccional (hop 1..MAX_HOPS) ─────────────────────
    # Para cada SP sin asignar, se evalúan DOS señales independientes:
    #   A) Callers:  ¿quiénes me llaman? → predominancia entre callers asignados
    #   B) Callees:  ¿a quién llamo?     → predominancia entre callees asignados
    # Se toma la señal con mayor pct. Si alguna ≥ THRESHOLD → asignar.
    # Sin filtro por fan_in: la señal de pct determina si es specific o shared.
    total_inferred = 0
    for hop in range(1, MAX_HOPS + 1):
        new_this_hop = 0

        for sp_id in sps:
            if sp_id in assigned:
                continue

            best_l3: str | None = None
            best_pct: float = 0.0

            # Señal A — DOWNWARD: callers del SP
            callers = callee_to_callers.get(sp_id, [])
            caller_l3s = [
                assigned[c]["l3_id"]
                for c in callers
                if c in assigned and assigned[c]["source"] != "shared"
            ]
            if caller_l3s:
                cnt = Counter(caller_l3s)
                dom_l3, dom_n = cnt.most_common(1)[0]
                pct = dom_n / len(caller_l3s)
                if pct > best_pct:
                    best_pct = pct
                    best_l3 = dom_l3

            # Señal B — UPWARD: callees del SP
            callees = caller_to_callees.get(sp_id, [])
            callee_l3s = [
                assigned[c]["l3_id"]
                for c in callees
                if c in assigned and assigned[c]["source"] != "shared"
            ]
            if callee_l3s:
                cnt = Counter(callee_l3s)
                dom_l3, dom_n = cnt.most_common(1)[0]
                pct = dom_n / len(callee_l3s)
                if pct > best_pct:
                    best_pct = pct
                    best_l3 = dom_l3

            if best_l3 and best_pct >= THRESHOLD:
                assigned[sp_id] = {
                    "l3_id": best_l3,
                    "source": "inferred",
                    "confidence": round(best_pct, 4),
                    "hop": hop,
                    "caller_cap_pct": round(best_pct, 4),
                }
                new_this_hop += 1

        total_inferred += new_this_hop
        print(f"  Hop {hop:2d}           : +{new_this_hop:,} inferred  "
              f"(total asignados: {len(assigned):,})")
        if new_this_hop == 0:
            print("  Convergencia alcanzada.")
            break

    # ── Marcar shared utilities (alta ambigüedad entre múltiples caps) ────────
    # Un SP es "shared" si:
    #   - sigue sin asignar después de la propagación
    #   - tiene señal de al menos 2 caps distintas (evidencia de uso transversal)
    #   - el fan_in total es > MAX_FAN_IN (mucho uso externo)
    shared_count = 0
    for sp_id in sps:
        if sp_id in assigned:
            continue
        sp = sps[sp_id]
        if sp["fan_in"] <= MAX_FAN_IN:
            continue
        callers = callee_to_callers.get(sp_id, [])
        caller_l3s = [
            assigned[c]["l3_id"] for c in callers
            if c in assigned and assigned[c]["source"] != "shared"
        ]
        if len(set(caller_l3s)) >= 2:
            assigned[sp_id] = {
                "l3_id": "shared",
                "source": "shared",
                "confidence": 0.0,
                "hop": -1,
                "caller_cap_pct": 0.0,
            }
            shared_count += 1

    # ── Resumen ────────────────────────────────────────────────────────────────
    total_sp = len(sps)
    total_assigned = len(assigned)
    unassigned = total_sp - total_assigned
    pct_cov = total_assigned / total_sp * 100

    print(f"\n{'─'*50}")
    print(f"  Seed        : {seed_count:>7,}")
    print(f"  Inferred    : {total_inferred:>7,}")
    print(f"  Shared util : {shared_count:>7,}")
    print(f"  Sin asignar : {unassigned:>7,}")
    print(f"  TOTAL SPs   : {total_sp:>7,}")
    print(f"  Cobertura   : {pct_cov:.1f}%")
    print(f"{'─'*50}")

    # desglose por L3 (top 20, excluyendo shared)
    l3_counts: Counter = Counter(
        v["l3_id"] for v in assigned.values() if v["source"] != "shared"
    )
    # enriquecer con nombre de la ETB L3
    l3_names = {r["id"]: r["name"] for r in conn.execute("SELECT id, name FROM etb_l3")}

    print("\nTop 20 capacidades L3 por SPs asignados (seed + inferred):")
    for l3_id, n in l3_counts.most_common(20):
        l3_name = l3_names.get(l3_id, l3_id)
        src_seed     = sum(1 for v in assigned.values() if v["l3_id"] == l3_id and v["source"] == "seed")
        src_inferred = sum(1 for v in assigned.values() if v["l3_id"] == l3_id and v["source"] == "inferred")
        print(f"  {l3_id:<12} {l3_name:<40} {n:>5,}  (seed={src_seed}, inferred={src_inferred})")

    # ── Escribir tabla sp_capability_map ──────────────────────────────────────
    conn.execute("DROP TABLE IF EXISTS sp_capability_map")
    conn.execute("""
        CREATE TABLE sp_capability_map (
            sp_id          TEXT PRIMARY KEY,
            sp_name        TEXT NOT NULL,
            db             TEXT,
            l3_id          TEXT NOT NULL,
            source         TEXT NOT NULL,
            confidence     REAL,
            hop            INTEGER,
            caller_cap_pct REAL
        )
    """)

    rows_out = []
    for sp_id, info in assigned.items():
        sp = sps[sp_id]
        rows_out.append((
            sp_id, sp["name"], sp["db"],
            info["l3_id"], info["source"],
            info["confidence"], info["hop"], info["caller_cap_pct"],
        ))

    conn.executemany(
        "INSERT INTO sp_capability_map VALUES (?,?,?,?,?,?,?,?)",
        rows_out,
    )
    conn.commit()
    conn.close()

    print(f"\nTabla sp_capability_map  → {len(rows_out):,} filas en brain.db")
    print(f"Δ cobertura vs seed baseline: +{total_inferred + shared_count:,} SPs"
          f" ({(total_inferred + shared_count) / (total_sp or 1) * 100:.1f}pp)")


if __name__ == "__main__":
    main()

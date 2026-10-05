#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
define-test-universe.py — Universo de prueba estratificado del corpus Informix.

Selecciona ~300 SPs representativos del corpus completo (11,391) para iterar
rápido sobre el pipeline de extracción (reglas, procesos, vocabulario) sin
procesar los >12 K archivos en cada ciclo de refinamiento.

Estratificación en 4 tiers:
  T1  Señal especial   — is_soul + entry_point + cross_domain_primitive + shared_service
                         + esb_exposed (todos tienen prod_calls_day > 0 — producción completa)
  T2  Complejidad alta — top-N batch SPs por (LOC × rules_n) no ya en T1
                         (captura batch pesados sin tráfico ESB medido)
  T3  Cobertura dominio— 3 SPs por dominio D01–D16 (mayor LOC, rules_n > 0 primero)
  T4  Orquestación     — batch_orchestrators + super_orchestrators LOC≥500

Outputs:
  digital-brain/test-universe.json   — manifiesto completo con tier + rationale
  source/test-universe/              — copia de los .sql seleccionados
                                       (el pipeline puede apuntar aquí para refinamiento)

Uso:
  python generators/define-test-universe.py
  python generators/define-test-universe.py --no-copy   # solo genera JSON
  python generators/define-test-universe.py --t2-size 50 --t3-per-domain 5

SPE-AM-001 · Specialist Informix SPL · 2026-08-28
"""

import sys, json, shutil, argparse
from pathlib import Path
from collections import defaultdict

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import sqlite3

BASE = Path(__file__).resolve().parent.parent
DB   = BASE / "digital-brain" / "brain.db"
SRC  = BASE / "source" / "Informix"
OUT_JSON = BASE / "digital-brain" / "test-universe.json"
OUT_SRC  = BASE / "source" / "test-universe"

# ── Dominios activos con análisis maduro ───────────────────────────────────────
DOMAINS_D01_D16 = [f"D{i:02d}" for i in range(1, 17)]

# ── Roles de alta señal semántica ─────────────────────────────────────────────
HIGH_VALUE_ROLES = ("entry_point", "cross_domain_primitive", "shared_service", "esb_exposed")


def build_universe(con, t2_size: int, t3_per_domain: int, t4_batch: int, t4_super: int):
    selected: dict[str, dict] = {}   # key = "db:name"

    def add(row, tier: str, reason: str):
        key = f"{row['db']}:{row['name']}"
        if key not in selected:
            selected[key] = {
                "sp_key":       key,
                "db":           row["db"],
                "name":         row["name"],
                "domain":       row["domain"],
                "tier":         tier,
                "reason":       reason,
                "sp_role":      row["sp_role"],
                "sp_archetype": row["sp_archetype"],
                "loc":          row["loc"],
                "rules_n":      row["rules_n"],
                "biz":          row["biz"],
                "is_soul":      row["is_soul"],
                "prod_calls_day": row["prod_calls_day"],
                "verdict":      row["verdict"],
            }

    def qrows(sql, params=()):
        con.row_factory = sqlite3.Row
        return con.execute(sql, params).fetchall()

    # ── T1: Señal especial ────────────────────────────────────────────────────
    rows = qrows("""
        SELECT db, name, domain, sp_role, sp_archetype, loc, rules_n,
               biz, is_soul, prod_calls_day, verdict
        FROM sps
        WHERE is_soul = 1
           OR sp_role IN ('entry_point', 'cross_domain_primitive',
                          'shared_service', 'esb_exposed')
        ORDER BY is_soul DESC, sp_role, loc DESC
    """)
    for r in rows:
        reason = "is_soul=1" if r["is_soul"] else f"sp_role={r['sp_role']}"
        add(r, "T1", reason)

    t1_count = len(selected)
    print(f"T1 señal especial    : {t1_count:4d} SPs")

    # ── T2: Batch SPs de alta complejidad no cubiertos en T1 ─────────────────
    # Todos los esb_exposed tienen prod_calls_day>0 y están en T1.
    # T2 captura batch pesados con alta densidad de reglas fuera del radar ESB.
    rows = qrows("""
        SELECT db, name, domain, sp_role, sp_archetype, loc, rules_n,
               biz, is_soul, prod_calls_day, verdict,
               (COALESCE(loc,0) * COALESCE(rules_n,0)) AS complexity_score
        FROM sps
        WHERE sp_archetype = 'batch'
          AND COALESCE(rules_n, 0) > 0
        ORDER BY complexity_score DESC
        LIMIT ?
    """, (t2_size * 4,))
    added_t2 = 0
    for r in rows:
        if added_t2 >= t2_size:
            break
        key = f"{r['db']}:{r['name']}"
        if key not in selected:
            add(r, "T2", f"batch complejidad LOC={r['loc']} rules={r['rules_n']}")
            added_t2 += 1

    print(f"T2 complejidad batch : {added_t2:4d} SPs  (target={t2_size})")

    # ── T3: Cobertura de dominio D01-D16 ─────────────────────────────────────
    added_t3 = 0
    covered_before = set(selected.keys())
    for dom in DOMAINS_D01_D16:
        rows = qrows("""
            SELECT db, name, domain, sp_role, sp_archetype, loc, rules_n,
                   biz, is_soul, prod_calls_day, verdict
            FROM sps
            WHERE domain = ?
            ORDER BY
                CASE WHEN rules_n > 0 THEN 0 ELSE 1 END,   -- reglas primero
                loc DESC
        """, (dom,))
        picked = 0
        for r in rows:
            if picked >= t3_per_domain:
                break
            key = f"{r['db']}:{r['name']}"
            if key not in selected:
                add(r, "T3", f"domain_coverage domain={dom}")
                picked += 1
                added_t3 += 1

    print(f"T3 cobertura dominio : {added_t3:4d} SPs  ({t3_per_domain}/dominio D01-D16)")

    # ── T4: Diversidad de complejidad — orchestrators grandes ─────────────────
    rows_batch = qrows("""
        SELECT db, name, domain, sp_role, sp_archetype, loc, rules_n,
               biz, is_soul, prod_calls_day, verdict
        FROM sps
        WHERE sp_archetype = 'batch_orchestrator' AND loc >= 500
        ORDER BY loc DESC
        LIMIT ?
    """, (t4_batch * 3,))
    added_batch = 0
    for r in rows_batch:
        if added_batch >= t4_batch:
            break
        key = f"{r['db']}:{r['name']}"
        if key not in selected:
            add(r, "T4", f"batch_orchestrator loc={r['loc']}")
            added_batch += 1

    rows_super = qrows("""
        SELECT db, name, domain, sp_role, sp_archetype, loc, rules_n,
               biz, is_soul, prod_calls_day, verdict
        FROM sps
        WHERE sp_archetype = 'super_orchestrator' AND loc >= 500
        ORDER BY loc DESC
        LIMIT ?
    """, (t4_super * 3,))
    added_super = 0
    for r in rows_super:
        if added_super >= t4_super:
            break
        key = f"{r['db']}:{r['name']}"
        if key not in selected:
            add(r, "T4", f"super_orchestrator loc={r['loc']}")
            added_super += 1

    print(f"T4 orchestrators     : {added_batch + added_super:4d} SPs  (batch={added_batch} super={added_super})")

    return selected


def coverage_report(selected: dict) -> dict:
    tiers    = defaultdict(int)
    roles    = defaultdict(int)
    archs    = defaultdict(int)
    domains  = defaultdict(int)
    loc_bands = defaultdict(int)
    rules_dist = {"0": 0, "1-4": 0, "5-9": 0, "10+": 0}
    prod_active = 0
    souls = 0

    for s in selected.values():
        tiers[s["tier"]] += 1
        roles[s["sp_role"] or "—"] += 1
        archs[s["sp_archetype"] or "—"] += 1
        domains[s["domain"] or "—"] += 1
        loc = s["loc"] or 0
        if   loc < 50:    loc_bands["<50"] += 1
        elif loc < 200:   loc_bands["50-199"] += 1
        elif loc < 500:   loc_bands["200-499"] += 1
        elif loc < 1000:  loc_bands["500-999"] += 1
        else:             loc_bands[">=1000"] += 1

        r = s["rules_n"] or 0
        if   r == 0:  rules_dist["0"] += 1
        elif r < 5:   rules_dist["1-4"] += 1
        elif r < 10:  rules_dist["5-9"] += 1
        else:         rules_dist["10+"] += 1

        if (s["prod_calls_day"] or 0) > 0:
            prod_active += 1
        if s["is_soul"]:
            souls += 1

    return {
        "tiers":      dict(tiers),
        "roles":      dict(sorted(roles.items(), key=lambda x: -x[1])),
        "archetypes": dict(sorted(archs.items(), key=lambda x: -x[1])),
        "domains":    dict(sorted(domains.items())),
        "loc_bands":  dict(loc_bands),
        "rules_dist": rules_dist,
        "prod_active": prod_active,
        "souls":       souls,
    }


def copy_sources(selected: dict, dry_run: bool = False) -> tuple[int, int]:
    if not dry_run:
        OUT_SRC.mkdir(parents=True, exist_ok=True)
    copied, missing = 0, 0
    for sp in selected.values():
        fname = f"{sp['db']}_{sp['name']}.sql"
        src_path = SRC / fname
        if src_path.exists():
            if not dry_run:
                shutil.copy2(src_path, OUT_SRC / fname)
            copied += 1
        else:
            missing += 1
    return copied, missing


def main():
    parser = argparse.ArgumentParser(description="Universo de prueba estratificado — Informix SPL")
    parser.add_argument("--no-copy",         action="store_true", help="No copiar .sql, solo genera JSON")
    parser.add_argument("--t2-size",         type=int, default=30,  help="SPs top tráfico real (default 30)")
    parser.add_argument("--t3-per-domain",   type=int, default=3,   help="SPs por dominio D01-D16 (default 3)")
    parser.add_argument("--t4-batch",        type=int, default=10,  help="batch_orchestrators LOC≥500 (default 10)")
    parser.add_argument("--t4-super",        type=int, default=10,  help="super_orchestrators LOC≥500 (default 10)")
    args = parser.parse_args()

    print(f"Conectando a {DB}")
    con = sqlite3.connect(str(DB))

    print("\n── Selección estratificada ──────────────────────────────────────────")
    selected = build_universe(
        con,
        t2_size       = args.t2_size,
        t3_per_domain = args.t3_per_domain,
        t4_batch      = args.t4_batch,
        t4_super      = args.t4_super,
    )
    con.close()

    total = len(selected)
    print(f"\nTotal universo       : {total:4d} SPs")

    cov = coverage_report(selected)

    # ── Manifiesto JSON ───────────────────────────────────────────────────────
    manifest = {
        "meta": {
            "generated_at":   "2026-08-28",
            "total_corpus":   11391,
            "total_selected": total,
            "pct_corpus":     round(total / 11391 * 100, 2),
            "strategy":       "4-tier stratified sampling",
            "tiers": {
                "T1": "is_soul + entry_point + cross_domain_primitive + shared_service + esb_exposed",
                "T2": f"top-{args.t2_size} batch por LOC×rules_n (alta complejidad sin señal ESB)",
                "T3": f"{args.t3_per_domain} SPs por dominio D01-D16 (mayor LOC, rules_n > 0 primero)",
                "T4": f"{args.t4_batch} batch_orchestrators + {args.t4_super} super_orchestrators LOC≥500",
            },
        },
        "coverage": cov,
        "sps": list(selected.values()),
    }

    OUT_JSON.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nManifiesto escrito → {OUT_JSON.relative_to(BASE)}")

    # ── Resumen de cobertura ──────────────────────────────────────────────────
    print("\n── Cobertura del universo ───────────────────────────────────────────")
    print(f"  Corpus cubierto    : {total:,} / 11,391 ({cov.get('pct_corpus', round(total/11391*100,1))}%)")

    print("  Por tier:")
    for t, n in sorted(cov["tiers"].items()):
        print(f"    {t}: {n}")

    print("  Por archetype (top 6):")
    for a, n in list(cov["archetypes"].items())[:6]:
        print(f"    {a:35s} {n}")

    print("  Por LOC band:")
    for b, n in cov["loc_bands"].items():
        print(f"    {b:10s} {n}")

    print(f"  Prod-active (calls>0): {cov['prod_active']}")
    print(f"  Almas (is_soul):       {cov['souls']}")
    dom_covered = len([d for d in DOMAINS_D01_D16 if d in cov["domains"]])
    print(f"  Dominios D01-D16:      {dom_covered}/16")

    # ── Copia de fuentes ─────────────────────────────────────────────────────
    if not args.no_copy:
        print(f"\nCopiando .sql → {OUT_SRC.relative_to(BASE)} ...")
        copied, missing = copy_sources(selected)
        print(f"  Copiados : {copied}")
        if missing:
            print(f"  Sin fuente: {missing}  (SPs cargados sin .sql en source/)")
        print(f"\nUniverso listo — apunta el pipeline a source/test-universe/ para refinamiento rápido")
        print(f"  python generators/extract-rules.py          (edita SRC en el script)")
        print(f"  python generators/build-vocab-auto.py       (edita SRC en el script)")
    else:
        print("\n(--no-copy: sin copia de .sql)")


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
load-ctm-scripts-to-brain.py — Parsea scripts de /ifxsif01/Control-M/ v1.0

Fuentes esperadas (depositar en source/controlm/scripts/):
  *.sh  — shell scripts que el agente CTM ejecuta
  *.sql — archivos SQL que dbaccess corre dentro de los .sh

Pipeline:
  1. Lee .sh → extrae mapeos {script_name: [{db, sql_file}]}
  2. Lee .sql → extrae SPs invocados ({sql_file: [sp_name]})
  3. Cruza con ctm_jobs (tabla ya en brain.db) para asociar job→db:sp_name
  4. Actualiza sps.batch_archetype='CTM_ENTRY' en los nuevos matches
  5. Actualiza ctm_jobs.sp_id donde antes era NULL

Uso:
  python generators/load-ctm-scripts-to-brain.py
  python generators/load-ctm-scripts-to-brain.py --dry-run
  python generators/load-ctm-scripts-to-brain.py --scripts-dir /ruta/alternativa
"""

import re, sqlite3, sys, argparse, os
from pathlib import Path
from collections import defaultdict

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE        = Path(__file__).parent.parent
BRAIN_DB    = BASE / "digital-brain" / "brain.db"
SCRIPTS_DIR = BASE / "source" / "controlm" / "scripts"

# ── Regexes ──────────────────────────────────────────────────────────────────

# dbaccess {db} {sqlfile}  — dentro de los .sh
RE_DBACCESS = re.compile(
    r"dbaccess\s+(\S+)\s+(\S+\.sql)",
    re.IGNORECASE
)

# EXECUTE PROCEDURE [informix.]sp_name(  — dentro de los .sql
RE_EXEC_PROC = re.compile(
    r"EXECUTE\s+PROCEDURE\s+(?:\"?informix\"?\.)?(\w+)\s*\(",
    re.IGNORECASE
)

# CALL informix.sp_name(  — alternativa
RE_CALL_PROC = re.compile(
    r"\bCALL\s+(?:\"?informix\"?\.)?(\w+)\s*\(",
    re.IGNORECASE
)

# Nombre del script sin ruta: pro_cierrecap_invcrec_param.sh → pro_cierrecap_invcrec_param
def script_stem(path: str) -> str:
    return Path(path).stem


# ── 1. Parsear shell scripts ──────────────────────────────────────────────────

def parse_sh_files(scripts_dir: Path) -> dict[str, list[dict]]:
    """
    Devuelve {sh_stem: [{db, sql_stem}]}
    Ejemplo: {"pro_cierrecap_invcrec_param": [{"db": "bdicheq", "sql": "eje_cierrechqinvcrecparam"}]}
    """
    result: dict[str, list[dict]] = defaultdict(list)
    sh_files = list(scripts_dir.glob("*.sh")) + list(scripts_dir.glob("*.ksh")) + list(scripts_dir.glob("*.bash"))

    for fpath in sh_files:
        stem = script_stem(str(fpath))
        try:
            text = fpath.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for m in RE_DBACCESS.finditer(text):
            db       = m.group(1).lower().strip()
            sql_path = m.group(2).strip()
            sql_stem = script_stem(sql_path)
            entry    = {"db": db, "sql": sql_stem}
            if entry not in result[stem]:
                result[stem].append(entry)

    return dict(result)


# ── 2. Parsear archivos SQL ───────────────────────────────────────────────────

def parse_sql_files(scripts_dir: Path) -> dict[str, list[str]]:
    """
    Devuelve {sql_stem: [sp_name, ...]}
    Ejemplo: {"eje_cierrechqinvcrecparam": ["sp_cierre_invcrec_param"]}
    """
    result: dict[str, list[str]] = defaultdict(list)
    sql_files = list(scripts_dir.glob("*.sql"))

    for fpath in sql_files:
        stem = script_stem(str(fpath))
        try:
            text = fpath.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for pattern in (RE_EXEC_PROC, RE_CALL_PROC):
            for m in pattern.finditer(text):
                sp_name = m.group(1).lower()
                if sp_name not in result[stem]:
                    result[stem].append(sp_name)

    return dict(result)


# ── 3. Cruzar: job_name → sh_stem → sql_stem → sp_name ──────────────────────

def build_job_sp_map(
    sh_map:  dict[str, list[dict]],   # sh_stem → [{db, sql_stem}]
    sql_map: dict[str, list[str]],    # sql_stem → [sp_name]
    ctm_jobs: list[dict],             # [{job_name, folder, sp_id}]
) -> list[dict]:
    """
    Intenta asociar cada ctm_job (sin sp_id aún) a un sp_name via el .sh→.sql chain.
    Devuelve lista de {job_name, sh_stem, db, sp_name}.
    """

    # Construir: sh_stem → [{db, sp_name}]
    sh_to_sp: dict[str, list[dict]] = defaultdict(list)
    for sh_stem, dbsql_list in sh_map.items():
        for dbsql in dbsql_list:
            db       = dbsql["db"]
            sql_stem = dbsql["sql"]
            for sp_name in sql_map.get(sql_stem, []):
                entry = {"db": db, "sp": sp_name}
                if entry not in sh_to_sp[sh_stem]:
                    sh_to_sp[sh_stem].append(entry)

    # Mapear job_name → sh_stem
    # Heurística: CTM job CIERRECAP_INVCREC_PARAM_PRO → script pro_cierrecap_invcrec_param.sh
    # Pattern: quitar prefijo numérico + _PRO/EJE final, lowercase, normalizar
    RE_NUM_PREFIX = re.compile(r"^\d+_(?:\d+_)*")
    RE_ENV_SUFFIX = re.compile(r"_(?:PRO|EJE|PRE|CLN|CAN)$", re.I)

    results = []
    for job in ctm_jobs:
        if job.get("sp_id"):           # ya tiene match directo
            continue
        jname = job["job_name"]
        # Normalizar: quitar prefijo numérico y sufijo de ambiente
        normalized = RE_ENV_SUFFIX.sub("", RE_NUM_PREFIX.sub("", jname)).lower()

        # Buscar en sh_map: intentar coincidencias parciales
        best_sh = None
        best_score = 0
        for sh_stem in sh_map:
            # sh_stem ejemplo: pro_cierrecap_invcrec_param
            sh_clean = sh_stem.lower().lstrip("pro_").lstrip("eje_")
            # Puntuación: caracteres compartidos al inicio
            min_len = min(len(normalized), len(sh_clean))
            score = sum(1 for i in range(min_len) if normalized[i] == sh_clean[i])
            if score > best_score and score >= 6:
                best_score = score
                best_sh = sh_stem

        if best_sh:
            for dbsp in sh_to_sp.get(best_sh, []):
                results.append({
                    "job_name": jname,
                    "sh_stem":  best_sh,
                    "db":       dbsp["db"],
                    "sp_name":  dbsp["sp"],
                    "score":    best_score,
                })

    return results


# ── Main ─────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--scripts-dir", default=str(SCRIPTS_DIR),
                    help=f"Directorio con .sh y .sql (default: {SCRIPTS_DIR})")
    args = ap.parse_args()

    sdir = Path(args.scripts_dir)
    if not sdir.exists():
        sys.exit(f"Directorio no encontrado: {sdir}\n"
                 f"Deposita los .sh y .sql de /ifxsif01/Control-M/ ahí.")

    print(f"=== load-ctm-scripts-to-brain.py v1.0 ===")
    print(f"Scripts dir: {sdir}")

    sh_files  = list(sdir.glob("*.sh")) + list(sdir.glob("*.ksh")) + list(sdir.glob("*.bash"))
    sql_files = list(sdir.glob("*.sql"))
    print(f"Shell scripts : {len(sh_files)}")
    print(f"SQL files     : {len(sql_files)}")

    if not sh_files and not sql_files:
        print("\nNo se encontraron archivos. Depositarlos en:", sdir)
        return

    sh_map  = parse_sh_files(sdir)
    sql_map = parse_sql_files(sdir)

    print(f"\nShell scripts parseados: {len(sh_map)} (con dbaccess)")
    print(f"SQL files parseados    : {len(sql_map)} (con EXECUTE PROCEDURE)")

    # Stats
    total_dbaccess = sum(len(v) for v in sh_map.values())
    total_sp_refs  = sum(len(v) for v in sql_map.values())
    print(f"  Total dbaccess calls : {total_dbaccess}")
    print(f"  Total SP refs en SQL : {total_sp_refs}")

    # Cargar brain.db
    conn  = sqlite3.connect(BRAIN_DB)

    # SP lookup
    sp_rows = conn.execute("SELECT id, name, db FROM sps").fetchall()
    sp_by_name: dict[str, list[dict]] = defaultdict(list)
    for sid, sname, db in sp_rows:
        sp_by_name[(sname or "").lower()].append({"id": sid, "db": db})

    # CTM jobs sin sp_id
    ctm_jobs_raw = conn.execute(
        "SELECT job_name, folder, sp_id FROM ctm_jobs"
    ).fetchall()
    ctm_jobs = [{"job_name": r[0], "folder": r[1], "sp_id": r[2]} for r in ctm_jobs_raw]
    unmatched = [j for j in ctm_jobs if not j["sp_id"]]
    print(f"\nCTM jobs sin sp_id en brain.db: {len(unmatched)}")

    # Cruzar
    job_sp_map = build_job_sp_map(sh_map, sql_map, ctm_jobs)
    print(f"Nuevos matches via .sh→.sql: {len(job_sp_map)}")

    if not job_sp_map:
        print("\nSin nuevos matches — verificar nombres de archivos .sh/.sql.")
        conn.close()
        return

    # Resolver sp_id en brain.db para cada match
    confirmed: list[dict] = []
    for match in job_sp_map:
        sp_name = match["sp_name"]
        db      = match["db"]
        hits    = sp_by_name.get(sp_name, [])
        # Preferir el que coincide con la DB
        best = next((h for h in hits if h["db"] == db), None) or (hits[0] if hits else None)
        if best:
            confirmed.append({**match, "sp_id": best["id"]})

    print(f"Confirmados con sp_id en brain.db: {len(confirmed)}")

    # Muestra
    print("\nMuestra (primeros 20):")
    for m in confirmed[:20]:
        print(f"  [{m['job_name']}]")
        print(f"    → {m['sp_id']}  (via {m['sh_stem']} · score={m['score']})")

    if args.dry_run:
        print("\n[DRY-RUN] Sin cambios en brain.db.")
        conn.close()
        return

    # Actualizar batch_archetype
    updated_arch = 0
    updated_jobs = 0
    seen_sp_ids: set[str] = set()
    for m in confirmed:
        sp_id = m["sp_id"]
        if sp_id not in seen_sp_ids:
            seen_sp_ids.add(sp_id)
            r = conn.execute(
                "UPDATE sps SET batch_archetype='CTM_ENTRY' "
                "WHERE id=? AND (batch_archetype IS NULL OR batch_archetype='')",
                (sp_id,)
            )
            updated_arch += r.rowcount

        r = conn.execute(
            "UPDATE ctm_jobs SET sp_id=?, sp_name=? WHERE job_name=? AND sp_id IS NULL",
            (sp_id, m["sp_name"], m["job_name"])
        )
        updated_jobs += r.rowcount

    conn.commit()
    conn.close()

    print(f"\n✓ batch_archetype='CTM_ENTRY' aplicado: {updated_arch} SPs nuevos")
    print(f"✓ ctm_jobs.sp_id actualizado: {updated_jobs} jobs")
    total_ctm = 87 + updated_arch
    print(f"  Total CTM_ENTRY en brain.db: ~{total_ctm} SPs")


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
load-ctm-to-brain.py — Carga el universo de jobs Control-M a brain.db v1.0

Fuente: source/controlm/Universo Control-M *.xls
Acciones:
  1. Crea tabla ctm_jobs con todos los OS jobs en servidores sif01
  2. Extrae candidatos de SP de los nombres de job (patrón SP_<nombre>)
  3. Cruza con brain.db y actualiza batch_archetype='CTM_ENTRY' en SPs confirmados
  4. Mejora biz en SPs cuyo biz es débil (mismo que sp_name)

Uso:
  python generators/load-ctm-to-brain.py
  python generators/load-ctm-to-brain.py --dry-run    (sin escribir a DB)
"""

import re, sqlite3, sys, glob, os, argparse
from pathlib import Path
from collections import defaultdict

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

try:
    import xlrd
except ImportError:
    sys.exit("Instala xlrd: pip install xlrd")

BASE     = Path(__file__).parent.parent
BRAIN_DB = BASE / "digital-brain" / "brain.db"
CTM_DIR  = BASE / "source" / "controlm"

# ── Encuentra el Excel más reciente en source/controlm/ ─────────────────────
def find_ctm_xls() -> Path:
    patterns = [CTM_DIR / "*.xls", CTM_DIR / "*.xlsx"]
    files = []
    for pat in patterns:
        files.extend(glob.glob(str(pat)))
    if not files:
        sys.exit(f"No se encontró ningún archivo .xls/.xlsx en {CTM_DIR}")
    return Path(sorted(files)[-1])          # más reciente por nombre

# ── Parsea el Excel ──────────────────────────────────────────────────────────
# Extrae el token SP del nombre del job: "206_8_7_SP_DEPOSITOS_COBRANZA_PRO" → "sp_depositos_cobranza"
# Estrategia: quita sufijos finales conocidos, luego toma lo que va después de SP_
# Solo sufijos CTM de ambiente/entorno — NO temporales (_NOCTURNO, _DIARIO) que pueden ser parte del SP name
RE_SUFFIX    = re.compile(r"_(?:PRO|EJE|PRE|CLN|CAN)$", re.I)
RE_SP_MARKER = re.compile(r"(?:^|_)(?:EJECUTA_)?SP_([A-Z0-9_]{4,60})$", re.I)
RE_SP_IN_DESC = re.compile(r"\bsp_([a-z0-9_]{4,60})\b", re.I)

def parse_ctm_excel(path: Path) -> list[dict]:
    wb = xlrd.open_workbook(str(path))
    ws = wb.sheet_by_name("Sheet")

    headers = [ws.cell_value(0, j) for j in range(ws.ncols)]
    col = {h: i for i, h in enumerate(headers)}

    jobs = []
    for i in range(1, ws.nrows):
        t    = str(ws.cell_value(i, col["Type"]) or "").strip()
        host = str(ws.cell_value(i, col["Host/Host Group"]) or "").lower().strip()
        if t != "OS" or "sif01" not in host:
            continue
        name   = str(ws.cell_value(i, col["Job Name"]) or "").strip()
        cmd    = str(ws.cell_value(i, col["Command Line"]) or "").strip()
        desc   = str(ws.cell_value(i, col["Description"]) or "").strip()
        folder = str(ws.cell_value(i, col["Parent Folder"]) or "").strip()

        # Candidatos SP desde nombre del job
        # Quita sufijos finales iterativamente para exponer el nombre del SP
        sp_candidates = []
        stripped = name
        for _ in range(4):
            m = RE_SUFFIX.search(stripped)
            if not m:
                break
            stripped = stripped[:m.start()]
        m_sp = RE_SP_MARKER.search(stripped)
        if m_sp:
            sp_candidates.append("sp_" + m_sp.group(1).lower())
        # Candidatos SP desde descripción
        for m in RE_SP_IN_DESC.finditer(desc.lower()):
            candidate = "sp_" + m.group(1).rstrip("_")
            if candidate not in sp_candidates:
                sp_candidates.append(candidate)

        jobs.append({
            "job_name":      name,
            "folder":        folder,
            "host":          host,
            "cmd":           cmd,
            "description":   desc,
            "sp_candidates": sp_candidates,
        })

    return jobs

# ── Extrae descripción limpia del job (quita el prefijo de plantilla) ────────
RE_TEMPLATE = re.compile(
    r"Gerencia propietaria.*?-\s*(?:Propietarios del proceso:|Coordinaci[oó]n:)\s*.*?-\s*(?:Descripci[oó]n:|$)",
    re.IGNORECASE | re.DOTALL
)
RE_DESC_AFTER_COLON = re.compile(r"Descripci[oó]n:\s*(.+)", re.IGNORECASE | re.DOTALL)

def clean_desc(desc: str) -> str:
    """Extrae la parte útil de la descripción, quitando el template de Gerencia."""
    m = RE_DESC_AFTER_COLON.search(desc)
    if m:
        return m.group(1).strip()[:200]
    # Si tiene template pero sin Descripción:, intentar la última oración
    if "Gerencia propietaria" in desc:
        parts = desc.split(" - ")
        for p in reversed(parts):
            p = p.strip()
            if len(p) > 15 and "gerencia" not in p.lower() and "propietario" not in p.lower():
                return p[:200]
    return desc.strip()[:200]

# ── Main ─────────────────────────────────────────────────────────────────────
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true", help="No escribe a DB")
    args = ap.parse_args()

    ctm_path = find_ctm_xls()
    print(f"=== load-ctm-to-brain.py v1.0 ===")
    print(f"Fuente CTM: {ctm_path.name}")

    jobs = parse_ctm_excel(ctm_path)
    print(f"OS jobs en sif01: {len(jobs)}")
    sp_jobs = [j for j in jobs if j["sp_candidates"]]
    print(f"  Con candidatos SP: {len(sp_jobs)}")

    # ── Cargar brain.db ──────────────────────────────────────────────────────
    conn = sqlite3.connect(BRAIN_DB)

    # SP lookup: name → {id, db, fan_in, biz}
    rows = conn.execute("SELECT id, name, db, fan_in, biz FROM sps").fetchall()
    by_name: dict[str, list] = defaultdict(list)
    for sid, sname, db, fi, biz in rows:
        by_name[(sname or "").lower()].append({
            "id": sid, "db": db, "fan_in": fi, "biz": biz or ""
        })

    # ── Crear tabla ctm_jobs ─────────────────────────────────────────────────
    conn.execute("DROP TABLE IF EXISTS ctm_jobs")
    conn.execute("""
        CREATE TABLE ctm_jobs (
            job_name     TEXT NOT NULL,
            folder       TEXT,
            host         TEXT,
            cmd          TEXT,
            description  TEXT,
            sp_id        TEXT,            -- brain.db sp id si hay match
            sp_name      TEXT,            -- nombre SP extraído
            UNIQUE(job_name, folder)
        )
    """)

    # ── Deduplicación: PRO_JOBS_001 y PRO_JOBS_001_MTY son el mismo job ──────
    seen_jobs: set[str] = set()

    matched_sps: dict[str, dict] = {}    # sp_id → {sp, job_info}
    weak_biz_updates: dict[str, str] = {} # sp_id → new_biz

    for job in jobs:
        # Dedup: normaliza folder eliminando _MTY al final
        folder_norm = re.sub(r"_MTY$", "", job["folder"])
        key = f"{job['job_name']}::{folder_norm}"
        if key in seen_jobs:
            continue
        seen_jobs.add(key)

        matched_sp_id = None
        matched_sp_name = None

        for sp_cand in job["sp_candidates"]:
            hits = by_name.get(sp_cand, [])
            if hits:
                # Tomar el de mayor fan_in (canónico)
                best = max(hits, key=lambda x: x["fan_in"])
                matched_sp_id   = best["id"]
                matched_sp_name = sp_cand

                # Enrich biz si es débil (igual al sp_name)
                biz_now = (best["biz"] or "").strip()
                if biz_now.lower() in ("", sp_cand, sp_cand.replace("_", " ")):
                    desc_clean = clean_desc(job["description"])
                    # Derivar biz del nombre del job: sp_BONIFICA → bonificación
                    readable = sp_cand.replace("sp_", "").replace("_", " ").strip()
                    new_biz = desc_clean if desc_clean and len(desc_clean) > 10 else readable
                    if new_biz and new_biz != biz_now:
                        weak_biz_updates[matched_sp_id] = new_biz[:150]

                if matched_sp_id not in matched_sps:
                    matched_sps[matched_sp_id] = {
                        "sp": sp_cand,
                        "job": job["job_name"],
                        "desc": job["description"][:200],
                    }
                break   # primer candidato que matchea

        conn.execute(
            "INSERT OR IGNORE INTO ctm_jobs (job_name, folder, host, cmd, description, sp_id, sp_name) "
            "VALUES (?,?,?,?,?,?,?)",
            (job["job_name"], folder_norm, job["host"], job["cmd"],
             job["description"][:500], matched_sp_id, matched_sp_name)
        )

    conn.commit()
    print(f"\nTabla ctm_jobs creada: {conn.execute('SELECT COUNT(*) FROM ctm_jobs').fetchone()[0]} filas (dedup)")
    print(f"SPs únicos confirmados como CTM entry points: {len(matched_sps)}")
    print(f"SPs con biz débil a mejorar: {len(weak_biz_updates)}")

    # ── Muestra de matches ───────────────────────────────────────────────────
    print("\nMuestra de matches (primeros 15):")
    for sp_id, info in list(matched_sps.items())[:15]:
        print(f"  {sp_id}  ← job [{info['job']}]")
        print(f"    {info['desc'][:80]}")

    if args.dry_run:
        print("\n[DRY-RUN] No se escriben cambios a sps table.")
        conn.close()
        return

    # ── Actualizar batch_archetype='CTM_ENTRY' ───────────────────────────────
    updated_arch = 0
    for sp_id in matched_sps:
        r = conn.execute(
            "UPDATE sps SET batch_archetype='CTM_ENTRY' WHERE id=? AND (batch_archetype IS NULL OR batch_archetype='')",
            (sp_id,)
        )
        updated_arch += r.rowcount

    # ── Mejorar biz débil ────────────────────────────────────────────────────
    updated_biz = 0
    for sp_id, new_biz in weak_biz_updates.items():
        r = conn.execute(
            "UPDATE sps SET biz=? WHERE id=?",
            (new_biz, sp_id)
        )
        updated_biz += r.rowcount

    conn.commit()
    conn.close()

    print(f"\n✓ batch_archetype='CTM_ENTRY' aplicado: {updated_arch} SPs")
    print(f"✓ biz mejorado: {updated_biz} SPs")
    print(f"\nSiguiente: python digital-brain/build-brain.py   (si quieres reconstruir FTS5)")
    print(f"           python generators/build-sp-fine-mapping.py  (no impacta los CTM_ENTRY directamente)")


if __name__ == "__main__":
    main()
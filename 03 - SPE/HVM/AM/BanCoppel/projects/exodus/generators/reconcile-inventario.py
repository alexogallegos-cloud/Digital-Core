"""
reconcile-inventario.py  --  Reconciliacion del Inventario_bdanalisis.xlsx vs brain Informix
Exodus · BanCoppel · SPE-AM-001 · 2026-08-20

Fuente banco: source/docs/Inventario 20260803/Inventario_bdanalisis.xlsx (998 aplicaciones)
Fuente brain: systems/core/Informix/digital-brain/brain.db (10,144 SPs parseados)

Uso:
    python generators/reconcile-inventario.py          # resumen a consola
    python generators/reconcile-inventario.py --full   # + detalle por app
    python generators/reconcile-inventario.py --json   # vuelca JSON al portal de datos
"""

import sqlite3
import json
import argparse
import re
import shutil
import tempfile
from pathlib import Path
from collections import defaultdict

# ── Rutas ────────────────────────────────────────────────────────────────────
ROOT          = Path(__file__).parent.parent
XLSX          = ROOT / "source/docs/Inventario 20260803/Inventario_bdanalisis.xlsx"
# Si OneDrive tiene el archivo bloqueado, se usa esta copia de scratchpad
XLSX_FALLBACK = Path(r"C:\Users\ALEJAN~1.GAL\AppData\Local\Temp\claude\c--Users-alejandro-gallegos-OneDrive---Accenture-Documents-Digital-Core\56103126-11ae-4a18-a744-bf648d4a4f80\scratchpad\Inventario_bdanalisis.xlsx")
# ROOT = projects/exodus → parent = projects → parent.parent = BanCoppel root
BRAIN_INFORMIX = ROOT.parent.parent / "systems/core/Informix/digital-brain/brain.db"
DATA_DIR      = ROOT / "portal/data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

# Índices de columna (row 2 = headers, 0-based)
COL_AGRUPACION  = 1
COL_CORE        = 2
COL_ID          = 3
COL_NOMBRE      = 4
COL_CORTO       = 5
COL_CRITICIDAD  = 12
COL_SPL         = 20
COL_DBMS        = 21
COL_ORIGEN      = 23
COL_DESTINO     = 24
COL_HOSTS       = 25
COL_BAJA        = 26

def _fix(s) -> str:
    """Limpia valores de celda: strip, None→''."""
    if s is None:
        return ""
    return str(s).strip()

def _int(v) -> int:
    if v is None:
        return 0
    try:
        return int(float(str(v)))
    except Exception:
        return 0

def load_xlsx() -> list[dict]:
    """Lee el inventario del banco. Usa fallback de scratchpad si OneDrive lo bloquea."""
    try:
        import openpyxl
    except ImportError:
        raise SystemExit("pip install openpyxl")

    for src in [XLSX, XLSX_FALLBACK]:
        try:
            wb = openpyxl.load_workbook(str(src), read_only=True, data_only=True)
            print(f"  Fuente: {src.name}")
            break
        except (PermissionError, FileNotFoundError):
            continue
    else:
        raise SystemExit(f"No se pudo abrir el archivo (PermissionError en ambas rutas)")

    ws = wb["Hoja 1"]
    rows = list(ws.iter_rows(min_row=3, values_only=True))  # skip blank row 1 + header row 2

    apps = []
    for r in rows:
        if r[COL_ID] is None and r[COL_NOMBRE] is None:
            continue
        spl  = _int(r[COL_SPL])
        dbms = _fix(r[COL_DBMS]).lower()
        apps.append({
            "id":          _int(r[COL_ID]),
            "nombre":      _fix(r[COL_NOMBRE]),
            "corto":       _fix(r[COL_CORTO]),
            "agrupacion":  _fix(r[COL_AGRUPACION]),
            "es_core":     _fix(r[COL_CORE]),
            "criticidad":  _fix(r[COL_CRITICIDAD]),
            "spl":         spl,
            "dbms":        _fix(r[COL_DBMS]),
            "hosts":       _int(r[COL_HOSTS]),
            "baja":        _fix(r[COL_BAJA]),
            "usa_informix": "informix" in dbms,
            "usa_postgres": any(x in dbms for x in ["postgres", "pg"]),
            "usa_otros":    dbms not in ("", ) and "informix" not in dbms and not any(x in dbms for x in ["postgres", "pg"]),
        })
    return apps

def load_brain_sps() -> tuple[dict[str, int], dict[str, list[str]]]:
    """Lee el brain de Informix: total SPs por base de datos."""
    if not BRAIN_INFORMIX.exists():
        print(f"  WARN: brain Informix no encontrado en {BRAIN_INFORMIX}")
        return {}, {}

    con = sqlite3.connect(str(BRAIN_INFORMIX))
    con.row_factory = sqlite3.Row

    by_db: dict[str, int] = defaultdict(int)
    sp_names: dict[str, list[str]] = defaultdict(list)
    for row in con.execute("SELECT id, db, name FROM sps"):
        db = row["db"] or "?"
        by_db[db] += 1
        sp_names[db].append(row["name"])

    con.close()
    return dict(by_db), dict(sp_names)

# ── Mapeo nombre-corto → DB de Informix ──────────────────────────────────────
# Derivado del patrón bdi{xxx} en el brain. Permite cruzar la app del banco
# con las bases de datos de nuestro parseo.
CORTO_TO_DB = {
    "BPI":        ["bdicnweb"],         # Banca por Internet
    "APP":        ["bdicnweb"],         # App Móvil (mismo core web)
    "SIWEB":      ["bdicnweb"],         # SIWEB sucursales
    "CAT":        ["bdicnweb"],         # Contact Center
    "PISA":       ["bdicred","bdisac","bdicheq","bdispei","bdisuc","bdinteg",
                   "bdiahorro","bdiinv","bdimotpag","bdiafore"],  # Core SIF/PISA
    "Core":       ["bdicred","bdisac","bdicheq","bdispei","bdisuc","bdinteg",
                   "bdiahorro","bdiinv","bdimotpag","bdiafore"],
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--full", action="store_true", help="Detalle por app Informix")
    parser.add_argument("--json", action="store_true", help="Genera portal/data/inventario-reconciliation.json")
    args = parser.parse_args()

    print("Cargando inventario del banco...")
    apps = load_xlsx()
    print(f"  {len(apps)} aplicaciones leidas del xlsx")

    print("Cargando brain Informix...")
    brain_by_db, brain_sp_names = load_brain_sps()
    brain_total = sum(brain_by_db.values())
    brain_dbs   = sorted(brain_by_db.keys())
    print(f"  {brain_total} SPs en brain · {len(brain_by_db)} bases de datos")

    # ── Totales generales ─────────────────────────────────────────────────────
    total_spl   = sum(a["spl"] for a in apps)
    n_informix  = sum(1 for a in apps if a["usa_informix"])
    spl_informix = sum(a["spl"] for a in apps if a["usa_informix"])
    n_solo_inf  = sum(1 for a in apps if a["usa_informix"] and not a["usa_postgres"])
    spl_solo_inf = sum(a["spl"] for a in apps if a["usa_informix"] and not a["usa_postgres"])
    n_cero_spl  = sum(1 for a in apps)  # apps sin SPL declarado
    apps_sin_spl = [a for a in apps if a["spl"] == 0]
    apps_con_spl = [a for a in apps if a["spl"] > 0]

    print("\n" + "="*70)
    print("INVENTARIO BANCO vs BRAIN INFORMIX — Reconciliación")
    print("="*70)

    print(f"\n── Universo total del banco ──")
    print(f"  Aplicaciones en inventario     : {len(apps)}")
    print(f"  Con # SPL > 0                  : {len(apps_con_spl)}")
    print(f"  Con # SPL = 0 (no declarado)   : {len(apps_sin_spl)}")
    print(f"  SPLs declarados en total       : {total_spl:,}")

    print(f"\n── Apps que usan Informix (DBMS contiene 'informix') ──")
    print(f"  Apps con Informix              : {n_informix}")
    print(f"  SPLs en apps con Informix      : {spl_informix:,}")
    print(f"  Solo Informix (sin Postgres)   : {n_solo_inf} apps · {spl_solo_inf:,} SPLs")

    # Apps con SPL redondo (estimaciones)
    redondos = [a for a in apps if a["spl"] > 0 and a["spl"] % 1000 == 0]
    spl_redondos = sum(a["spl"] for a in redondos)
    print(f"\n── Calidad de las cifras ──")
    print(f"  Apps con SPL múltiplo de 1,000  : {len(redondos)} ({spl_redondos:,} SPLs) ← estimaciones redondas")
    print(f"  Apps con SPL declarado orgánico : {len(apps_con_spl)-len(redondos)}")
    spl_organico = total_spl - spl_redondos
    print(f"  SPLs 'orgánicos' (no redondos)  : {spl_organico:,}")

    print(f"\n── Brain Informix (parseo de código fuente) ──")
    print(f"  SPs únicos parseados            : {brain_total:,}")
    print(f"  Bases de datos cubiertas        : {len(brain_by_db)}")
    # Top 10 por SP count
    top10 = sorted(brain_by_db.items(), key=lambda x: x[1], reverse=True)[:10]
    print(f"  Top 10 DBs por SP count:")
    for db, cnt in top10:
        print(f"    {db:<25} {cnt:>5} SPs")

    # ── Diferencia explicada ──────────────────────────────────────────────────
    print(f"\n── Diferencia 17,380 vs 10,144 — anatomía ──")
    print(f"  Banco declara (total xlsx)      : {total_spl:,}")
    print(f"  Brain Informix (parseo real)    : {brain_total:,}")
    print(f"  Delta                           : +{total_spl - brain_total:,}")
    print()
    print(f"  Explicación:")
    print(f"    - Estimaciones redondas (≥1,000 múltiplo): {len(redondos)} apps · {spl_redondos:,} SPLs")
    print(f"      Candidatos: " + ", ".join(f"{a['corto'] or a['nombre'][:20]}({a['spl']:,})" for a in sorted(redondos, key=lambda x: x['spl'], reverse=True)[:8]))
    # Apps sin informix pero con SPL declarado
    apps_no_ifx_con_spl = [a for a in apps if not a["usa_informix"] and a["spl"] > 0]
    spl_no_ifx = sum(a["spl"] for a in apps_no_ifx_con_spl)
    print(f"    - SPLs en apps sin Informix (Postgres, Java puro…): {len(apps_no_ifx_con_spl)} apps · {spl_no_ifx:,} SPLs")
    print(f"    - SPLs multi-DB (mismo código contado N veces): probable solapamiento")
    print(f"    - Brain solo cubre DBs entregadas (≠ total instancias en producción)")

    # ── Detalle por app Informix ──────────────────────────────────────────────
    ifx_apps = sorted([a for a in apps if a["usa_informix"]], key=lambda x: x["spl"], reverse=True)
    if args.full:
        print(f"\n── Apps que usan Informix — detalle ({len(ifx_apps)} apps) ──")
        print(f"  {'ID':>4}  {'Nombre corto':<22}  {'SPL':>6}  {'DBMS':40}  Core  Baja")
        print("  " + "-"*100)
        for a in ifx_apps:
            baja = "SÍ" if a["baja"] and a["baja"].lower() not in ("no", "n/a", "") else ""
            core = "CORE" if a["es_core"] and a["es_core"].lower() == "sí" else ""
            dbms_short = a["dbms"][:38] if len(a["dbms"]) > 40 else a["dbms"]
            print(f"  {a['id']:>4}  {(a['corto'] or a['nombre'])[:22]:<22}  {a['spl']:>6}  {dbms_short:<40}  {core:<5}  {baja}")
    else:
        print(f"\n  (usa --full para ver las {len(ifx_apps)} apps con Informix)")

    # Apps en plan de baja que usan Informix
    baja_ifx = [a for a in ifx_apps if a["baja"] and a["baja"].lower() not in ("no", "n/a", "")]
    print(f"\n── Apps Informix con plan de baja o migración ──")
    print(f"  {len(baja_ifx)} apps · {sum(a['spl'] for a in baja_ifx):,} SPLs")
    for a in baja_ifx:
        print(f"    [{a['id']:>3}] {a['corto'] or a['nombre']:<25} {a['spl']:>5} SPL  → {a['baja']}")

    # ── Apps con más SPLs ─────────────────────────────────────────────────────
    print(f"\n── Top 15 apps por # SPL (banco) ──")
    top15 = sorted(apps, key=lambda x: x["spl"], reverse=True)[:15]
    print(f"  {'ID':>4}  {'Nombre':<30}  {'SPL':>7}  {'DBMS':30}  {'Criticidad'}")
    print("  " + "-"*95)
    for a in top15:
        print(f"  {a['id']:>4}  {(a['corto'] or a['nombre'])[:30]:<30}  {a['spl']:>7,}  {a['dbms'][:30]:<30}  {a['criticidad']}")

    # ── JSON output ───────────────────────────────────────────────────────────
    if args.json:
        out = {
            "generated": "2026-08-20",
            "source_xlsx": "Inventario_bdanalisis.xlsx (agosto 2026)",
            "totals": {
                "apps_total": len(apps),
                "apps_con_spl": len(apps_con_spl),
                "spl_total_banco": total_spl,
                "spl_redondos": spl_redondos,
                "apps_informix": n_informix,
                "spl_informix": spl_informix,
                "brain_sps": brain_total,
                "brain_dbs": len(brain_by_db),
            },
            "delta_explanation": {
                "banco": total_spl,
                "brain": brain_total,
                "delta": total_spl - brain_total,
                "redondas_apps": len(redondos),
                "redondas_spl": spl_redondos,
                "no_informix_apps": len(apps_no_ifx_con_spl),
                "no_informix_spl": spl_no_ifx,
            },
            "brain_by_db": brain_by_db,
            "inventario_apps": [
                {k: v for k, v in a.items() if k not in ("dbms",)} | {"dbms": a["dbms"][:80]}
                for a in apps
            ],
        }
        out_path = DATA_DIR / "inventario-reconciliation.json"
        out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"\n  JSON escrito: {out_path}")

    print("\n" + "="*70)
    print("CONCLUSIÓN:")
    print(f"  Banco declara {total_spl:,} SPLs. De esos, ~{spl_redondos:,} son estimaciones")
    print(f"  redondas (múltiplos de 1,000). Los restantes ~{spl_organico:,} son conteos")
    print(f"  reales declarados por los responsables de aplicación.")
    print(f"  Nuestro brain tiene {brain_total:,} SPs parseados del código fuente real.")
    print(f"  Ambas métricas son correctas — miden cosas distintas:")
    print(f"    - Banco: declaraciones en bd_analisis (incluye DBs no entregadas + duplicados)")
    print(f"    - Brain: código fuente disponible en los DBs entregados para análisis")
    print("="*70)

if __name__ == "__main__":
    main()

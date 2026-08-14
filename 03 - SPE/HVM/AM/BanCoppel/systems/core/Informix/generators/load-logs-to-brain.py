#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
load-logs-to-brain.py — Carga logs de producción ESB a brain.db (serie de tiempo)

Crea la tabla sp_metrics_daily y la alimenta desde:
  1. Migración de sps.prod_* (datos 2026-04-24 ya cargados)
  2. Carpetas source/logs/{YYYY-MM-DD}/ no procesadas aún

Esquema resultante:
  sp_metrics_daily(sp_id, date, calls, errors, error_rate, calling_systems)
    PK: (sp_id, date)

Uso:
  python generators/load-logs-to-brain.py
  python generators/load-logs-to-brain.py --only-date 2026-07-31
"""

import re, sqlite3, sys, json, argparse
from pathlib import Path
from collections import defaultdict
from datetime import datetime

sys.stdout.reconfigure(encoding="utf-8")

BASE     = Path(__file__).parent.parent
BRAIN_DB = BASE / "digital-brain" / "brain.db"
LOGS_DIR = BASE / "source" / "logs"

# ── DSN → dominio (mismo mapeo que analyze-logs.py) ─────────────────────────
DSN_TO_DB = {
    "ifx_bdicnweb":        "bdicnweb",
    "ifx_bdinteg":         "bdinteg",
    "ifx_bdinteg_inyau":   "bdinteg",
    "ifx_bdicred":         "bdicred",
    "ifx_bdicheq":         "bdicheq",
    "ifx_bdisac":          "bdisac",
    "ifx_bdisac_remesas":  "bdisac",
    "ifx_bdisolic":        "bdisolic",
    "ifx_bdiaclaracion":   "bdiaclaracion",
    "ifx_bdispei":         "bdispei",
    "ifx_bdimnsj":         "bdimnsj",
    "ifx_bdisuc":          "bdisuc",
    "ifx_bdicobranza":     "bdicobranza",
    "ifx_bdicont":         "bdicont",
    "ifx_bdibei":          "bdibei",
    "ifx_bditef":          "bditef",
    "ifx_bdilide":         "bdilide",
    "ifx_intercard":       "intercard",
    "postg_huellasemps":   "huellasemps",
}

RE_TRAMA_IFX = re.compile(
    r"(?:(ifx_\w+|postg_\w+)\s+)?call\s+(?:informix\.)?(\w+)\s*\(", re.IGNORECASE
)
RE_ESTATUS   = re.compile(r"<estatus>(.*?)</estatus>")
RE_SISTEMA   = re.compile(r"<sistemaOrigen>(.*?)</sistemaOrigen>")
RE_TRAMA     = re.compile(r"<trama>(.*?)</trama>", re.DOTALL)


def _ensure_table(conn):
    conn.execute("""
        CREATE TABLE IF NOT EXISTS sp_metrics_daily (
            sp_id          TEXT NOT NULL,
            date           TEXT NOT NULL,
            calls          INTEGER DEFAULT 0,
            errors         INTEGER DEFAULT 0,
            error_rate     REAL DEFAULT 0.0,
            calling_systems TEXT,
            PRIMARY KEY (sp_id, date)
        )
    """)
    conn.commit()


def migrate_from_sps(conn):
    """Migra los datos 2026-04-24 ya cargados en sps.prod_* a sp_metrics_daily."""
    cur = conn.cursor()
    # Fetch ALL rows first — evita el bug de cursor reuse con INSERT en el mismo cursor
    rows = cur.execute("""
        SELECT id, prod_evidence_date, prod_calls_day, prod_errors_day,
               prod_error_rate, prod_calling_systems
        FROM sps
        WHERE prod_calls_day > 0 AND prod_evidence_date IS NOT NULL
    """).fetchall()
    migrated = 0
    for row in rows:
        sp_id, date, calls, errors, error_rate, channels = row
        cur.execute("""
            INSERT OR IGNORE INTO sp_metrics_daily
            (sp_id, date, calls, errors, error_rate, calling_systems)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (sp_id, date, calls, errors, error_rate, channels))
        migrated += cur.rowcount
    conn.commit()
    return migrated


def _dates_already_loaded(conn) -> set:
    return {r[0] for r in conn.execute(
        "SELECT DISTINCT date FROM sp_metrics_daily"
    ).fetchall()}


def parse_log_folder(date_folder: Path) -> dict:
    """
    Lee todos los archivos .txt de una carpeta de fecha.
    Devuelve {sp_id: {calls, errors, sistemas}}.
    """
    sp_acc: dict[str, dict] = defaultdict(lambda: {
        "calls": 0, "errors": 0, "sistemas": set()
    })

    log_files = sorted(date_folder.glob("*.txt"))
    if not log_files:
        print(f"  [WARN] carpeta {date_folder.name} sin archivos .txt")
        return {}

    print(f"  {len(log_files)} archivos en {date_folder.name}...")
    for fpath in log_files:
        try:
            with open(fpath, encoding="utf-8", errors="replace") as fh:
                for line in fh:
                    line = line.strip()
                    if not line:
                        continue
                    cdata_m = re.search(r"<!\[CDATA\[(.*?)]]>", line, re.DOTALL)
                    raw = cdata_m.group(1) if cdata_m else line

                    estatus_m = RE_ESTATUS.search(raw)
                    estatus   = estatus_m.group(1) if estatus_m else "unknown"

                    trama_m = RE_TRAMA.search(raw)
                    trama   = trama_m.group(1) if trama_m else ""

                    ifx_m = RE_TRAMA_IFX.search(trama)
                    if not ifx_m:
                        continue

                    raw_dsn  = (ifx_m.group(1) or "").lower()
                    sp_name  = ifx_m.group(2)
                    db_name  = DSN_TO_DB.get(raw_dsn) if raw_dsn else None

                    if not sp_name or not db_name:
                        continue

                    sp_id = f"{db_name}:{sp_name}"
                    acc   = sp_acc[sp_id]
                    acc["calls"] += 1
                    if estatus == "error":
                        acc["errors"] += 1

                    sistem_m = RE_SISTEMA.search(raw)
                    if sistem_m:
                        acc["sistemas"].add(sistem_m.group(1))
        except Exception as exc:
            print(f"  [ERR] {fpath.name}: {exc}")

    return sp_acc


def load_date_folder(conn, date_str: str, sp_acc: dict):
    """Inserta los métricas de una fecha en sp_metrics_daily."""
    cur = conn.cursor()
    inserted = 0
    for sp_id, data in sp_acc.items():
        calls  = data["calls"]
        errors = data["errors"]
        rate   = round(errors / calls * 100, 2) if calls else 0.0
        channels = json.dumps(sorted(data["sistemas"])[:10])
        cur.execute("""
            INSERT OR REPLACE INTO sp_metrics_daily
            (sp_id, date, calls, errors, error_rate, calling_systems)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (sp_id, date_str, calls, errors, rate, channels))
        inserted += 1
    conn.commit()
    return inserted


def print_summary(conn):
    """Imprime resumen de la tabla sp_metrics_daily."""
    print("\n── Resumen sp_metrics_daily ──────────────────────────────")
    for row in conn.execute("""
        SELECT m.date, COUNT(DISTINCT m.sp_id) as sps,
               SUM(m.calls) as calls, SUM(m.errors) as errors,
               ROUND(SUM(m.errors)*100.0/MAX(SUM(m.calls),1), 2) as err_pct
        FROM sp_metrics_daily m
        GROUP BY m.date ORDER BY m.date
    """):
        print(f"  {row[0]}  {row[1]:>5} SPs  {row[2]:>9,} llamadas  "
              f"{row[3]:>7,} errores  {row[4]:>5.1f}%")

    print("\n── Error rate por dominio (todas las fechas) ─────────────")
    print(f"  {'DOM':<6} {'FECHA':<12} {'CALLS':>9} {'ERRORS':>8} {'ERR%':>7}")
    print("  " + "-"*48)
    for row in conn.execute("""
        SELECT s.domain, m.date, SUM(m.calls), SUM(m.errors),
               ROUND(SUM(m.errors)*100.0/MAX(SUM(m.calls),1), 2)
        FROM sp_metrics_daily m
        JOIN sps s ON s.id = m.sp_id
        WHERE s.domain IS NOT NULL
        GROUP BY s.domain, m.date
        ORDER BY s.domain, m.date
    """):
        print(f"  {row[0]:<6} {row[1]:<12} {row[2]:>9,} {row[3]:>8,} {row[4]:>7.1f}%")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--only-date", help="Procesar solo esta fecha (YYYY-MM-DD)")
    parser.add_argument("--force", action="store_true",
                        help="Reprocesar aunque ya exista en la tabla")
    args = parser.parse_args()

    conn = sqlite3.connect(BRAIN_DB)
    _ensure_table(conn)

    # Paso 1: migración datos existentes de sps.prod_*
    already = _dates_already_loaded(conn)
    if "2026-04-24" not in already:
        n = migrate_from_sps(conn)
        print(f"Migración sps.prod_* → sp_metrics_daily: {n} filas (2026-04-24)")
    else:
        print("2026-04-24 ya presente en sp_metrics_daily — skip migración")

    # Paso 2: carpetas de fechas en source/logs/
    if not LOGS_DIR.exists():
        print(f"[WARN] {LOGS_DIR} no existe — solo migración ejecutada")
        print_summary(conn)
        conn.close()
        return

    date_folders = sorted([
        d for d in LOGS_DIR.iterdir()
        if d.is_dir() and re.match(r"\d{4}-\d{2}-\d{2}$", d.name)
    ])

    already = _dates_already_loaded(conn)  # re-cargar después de migración

    for folder in date_folders:
        date_str = folder.name
        if args.only_date and date_str != args.only_date:
            continue
        if date_str in already and not args.force:
            print(f"{date_str} ya cargado — skip (usa --force para reprocesar)")
            continue
        print(f"\nProcesando {date_str}...")
        sp_acc = parse_log_folder(folder)
        if sp_acc:
            n = load_date_folder(conn, date_str, sp_acc)
            print(f"  → {n} SPs insertados en sp_metrics_daily para {date_str}")

    print_summary(conn)
    conn.close()
    print("\nload-logs-to-brain.py completado.")
    print("  Siguiente: python generators/build-capability-model.py")


if __name__ == "__main__":
    main()

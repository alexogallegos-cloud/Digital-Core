#!/usr/bin/env python3
"""
analyze-ctm-logs.py — Informix Control-M Batch Log Analyzer v1.0

Parsea archivos de salida de jobs Control-M (set -x) del servidor Informix
de BanCoppel. Detecta errores, extrae metadatos de ejecución y genera un
reporte KB con el historial de ejecución de los procesos batch.

Formato de archivo esperado:
  {JOBNAME}_output_{YYYYMMDDHHMMSS}_{NNNNN}.txt

Busca en:
  source/logs/{YYYY-MM-DD}/{JOBNAME}_output_*.txt
  source/logs/{JOBNAME}_output_*.txt   (sin subcarpeta de fecha)

Output:
  knowledge-base/cross-reference/ctm-batch-analysis-{DATE}.md
  knowledge-base/cross-reference/ctm-batch-jobs-{DATE}.json
"""
import re, os, sys, json, pathlib, glob
from collections import defaultdict, Counter
from datetime import datetime, timedelta

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix")
LOGS_ROOT = f"{BCOP}/source/logs"
KB_OUT    = f"{BCOP}/knowledge-base/cross-reference"

# Fecha por defecto: hoy
LOG_DATE = datetime.now().strftime('%Y-%m-%d')

# ── Regex ──────────────────────────────────────────────────────────────────────

# Nombre de archivo: JOBNAME_output_YYYYMMDDHHMMSS_NNNNN.txt
RE_FILENAME = re.compile(r'^(.+?)_output_(\d{14})_(\d+)\.txt$', re.IGNORECASE)

# Timestamp dentro del archivo: Thu Aug  6 23:20:20 CST 2026
RE_CTM_TS = re.compile(
    r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+'
    r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
    r'(\d{1,2})\s+(\d{2}:\d{2}:\d{2})\s+(\w+)\s+(\d{4})$'
)

# Línea de traza shell (set -x): comienza con +
RE_TRACE = re.compile(r'^\+')

# dbaccess invocación: + nice ... dbaccess {db} {sqlfile}
RE_DBACCESS = re.compile(r'dbaccess\s+(\S+)\s+(\S+)')

# Variable de entorno INFORMIXSERVER
RE_IFX_SERVER = re.compile(r'INFORMIXSERVER=(\S+)')

# RESLT variables: RESLT{N}_{M}=value
RE_RESLT = re.compile(r'(RESLT\w+)=(\S*)')

# Errores Informix en salida dbaccess:
#   -NNN: Error message  (error codes negativos)
#   NNN: Error message
RE_IFX_ERR = re.compile(r'^\s*(-\d+):\s*(.+)')
RE_ISAM    = re.compile(r'ISAM error[: ]+(-?\d+)', re.IGNORECASE)
RE_SQL_ERR = re.compile(r'SQL[:\s]+(-\d+)', re.IGNORECASE)

# "N row(s) retrieved" o "0 row(s) retrieved"
RE_ROWS = re.compile(r'(\d+)\s+row\(s\)\s+(retrieved|inserted|updated|deleted)', re.IGNORECASE)

# Error/warning genérico en líneas que NO son trace de shell
RE_ERR_WORD = re.compile(r'\berror\b', re.IGNORECASE)
RE_WARN_WORD = re.compile(r'\bwarning\b', re.IGNORECASE)

# Números negativos fuera de contexto de trace
RE_NEGATIVE = re.compile(r'\b(-\d+)\b')

MONTH_MAP = {
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
}


# ── Resultado de un job ────────────────────────────────────────────────────────

class JobResult:
    def __init__(self, filepath: str):
        self.filepath   = filepath
        self.filename   = os.path.basename(filepath)
        self.job_name   = ''
        self.file_ts    = ''      # timestamp del filename
        self.part       = ''
        self.start_ts   = None   # datetime
        self.end_ts     = None   # datetime
        self.duration_s = None   # int segundos
        self.ifx_server = ''
        self.databases  = []     # BDs accedidas
        self.sql_files  = []     # archivos SQL ejecutados
        self.results    = {}     # {RESLT_var: value}
        self.main_code  = ''     # RESLT2_1 o el primer RESLT disponible
        self.rows       = []     # [(n, operación)]  — filas afectadas
        self.errors     = []     # [(lineno, message)]
        self.warnings   = []     # [(lineno, message)]
        self.negatives  = []     # [(lineno, code, context)]
        self.isam_errors = []    # [(lineno, code)]
        self.ok         = False  # True si main_code == '000' y sin errores Informix


def _parse_ctm_ts(line: str) -> datetime | None:
    m = RE_CTM_TS.match(line.strip())
    if not m:
        return None
    _, month_s, day_s, time_s, _tz, year_s = m.groups()
    try:
        month = MONTH_MAP[month_s]
        day   = int(day_s)
        year  = int(year_s)
        h, mi, s = (int(x) for x in time_s.split(':'))
        return datetime(year, month, day, h, mi, s)
    except Exception:
        return None


def parse_ctm_file(filepath: str) -> JobResult:
    job = JobResult(filepath)

    # Extraer metadatos del nombre de archivo
    m = RE_FILENAME.match(job.filename)
    if m:
        job.job_name = m.group(1)
        job.file_ts  = m.group(2)   # YYYYMMDDHHMMSS
        job.part     = m.group(3)

    timestamps_found = []
    in_dbaccess_block = False

    try:
        with open(filepath, encoding='utf-8', errors='replace') as f:
            for lineno, raw in enumerate(f, 1):
                line = raw.rstrip('\r\n')

                # ── Timestamps de ejecución ──────────────────────────────
                ts = _parse_ctm_ts(line)
                if ts:
                    timestamps_found.append(ts)

                # ── INFORMIXSERVER ───────────────────────────────────────
                if not job.ifx_server:
                    m_srv = RE_IFX_SERVER.search(line)
                    if m_srv:
                        job.ifx_server = m_srv.group(1)

                # ── dbaccess invocación ──────────────────────────────────
                if RE_TRACE.match(line) and 'dbaccess' in line:
                    m_db = RE_DBACCESS.search(line)
                    if m_db:
                        db   = m_db.group(1)
                        sql  = m_db.group(2)
                        if db not in job.databases:
                            job.databases.append(db)
                        if sql not in job.sql_files:
                            job.sql_files.append(os.path.basename(sql))
                        in_dbaccess_block = True

                # ── Salida de dbaccess (líneas sin prefijo +) ────────────
                is_trace = RE_TRACE.match(line)

                if not is_trace:
                    # RESLT variables
                    for m_r in RE_RESLT.finditer(line):
                        var, val = m_r.group(1), m_r.group(2)
                        job.results[var] = val

                    # Filas afectadas
                    m_rows = RE_ROWS.search(line)
                    if m_rows:
                        job.rows.append((int(m_rows.group(1)), m_rows.group(2)))

                    # Error Informix (-NNN: mensaje)
                    m_ifx = RE_IFX_ERR.match(line)
                    if m_ifx:
                        job.errors.append((lineno, f"{m_ifx.group(1)}: {m_ifx.group(2).strip()}"))

                    # ISAM error
                    m_isam = RE_ISAM.search(line)
                    if m_isam:
                        job.isam_errors.append((lineno, m_isam.group(1)))

                    # SQL error
                    m_sqlerr = RE_SQL_ERR.search(line)
                    if m_sqlerr:
                        job.errors.append((lineno, f"SQL error {m_sqlerr.group(1)}"))

                    # Palabra "error" en contexto no-trace (excluyendo mailx y echo)
                    stripped = line.strip()
                    if (RE_ERR_WORD.search(stripped)
                            and 'mailx' not in stripped
                            and not stripped.startswith('+')):
                        # Evitar duplicados con errores Informix ya capturados
                        if not m_ifx and not m_sqlerr:
                            job.warnings.append((lineno, stripped[:120]))

                    # Palabra "warning"
                    if RE_WARN_WORD.search(stripped) and not stripped.startswith('+'):
                        job.warnings.append((lineno, stripped[:120]))

                    # Números negativos (posibles error codes Informix)
                    for m_neg in RE_NEGATIVE.finditer(stripped):
                        code = m_neg.group(1)
                        # Filtrar -n de opciones conocidas (-30 de nice, etc.)
                        if code not in ('-30', '-1', '-2', '-n'):
                            job.negatives.append((lineno, code, stripped[:80]))

    except OSError as e:
        job.errors.append((0, f"No se pudo leer el archivo: {e}"))

    # Determinar start/end
    if timestamps_found:
        job.start_ts = timestamps_found[0]
        job.end_ts   = timestamps_found[-1]
        if job.start_ts != job.end_ts:
            job.duration_s = int((job.end_ts - job.start_ts).total_seconds())

    # Código principal de resultado
    if 'RESLT2_1' in job.results:
        job.main_code = job.results['RESLT2_1']
    elif job.results:
        job.main_code = next(iter(job.results.values()))

    # OK = código 000 y sin errores Informix
    job.ok = (job.main_code == '000') and not job.errors and not job.isam_errors

    return job


# ── Búsqueda de archivos ───────────────────────────────────────────────────────

def find_ctm_files(log_date: str) -> list[str]:
    """
    Busca archivos *_output_*.txt en:
      1. source/logs/{date}/
      2. source/logs/  (sin subcarpeta)
    """
    found = []
    date_dir = os.path.join(LOGS_ROOT, log_date)
    patterns = [
        os.path.join(date_dir, '*_output_*.txt'),
        os.path.join(LOGS_ROOT, '*_output_*.txt'),
    ]
    seen = set()
    for pat in patterns:
        for p in sorted(glob.glob(pat)):
            if p not in seen and RE_FILENAME.match(os.path.basename(p)):
                found.append(p)
                seen.add(p)
    return found


# ── Generadores de salida ──────────────────────────────────────────────────────

def _status_icon(job: JobResult) -> str:
    if job.errors or job.isam_errors:
        return '❌'
    if job.warnings or (job.main_code and job.main_code != '000'):
        return '⚠'
    return '✅'


def generate_md(jobs: list[JobResult], log_date: str) -> str:
    now_str = datetime.now().strftime('%Y-%m-%d %H:%M')
    ok_n    = sum(1 for j in jobs if j.ok)
    err_n   = sum(1 for j in jobs if j.errors or j.isam_errors)
    warn_n  = len(jobs) - ok_n - err_n

    lines = []
    lines.append(f"# Análisis Batch Control-M — BanCoppel Informix · {log_date}")
    lines.append(f"> Generado: {now_str} · `generators/analyze-ctm-logs.py` v1.0")
    lines.append("")
    lines.append("## Contexto")
    lines.append("")
    lines.append("Jobs del scheduler **BMC Control-M** que se ejecutan sobre el servidor "
                 "Informix IDS 14.10 (`DCMSIF01` / `ifxsif01`). Los archivos de salida "
                 "capturan el trace completo del shell (`set -x`) más la salida de `dbaccess`.")
    lines.append("")

    # Resumen
    lines.append("## Resumen de ejecución")
    lines.append("")
    lines.append(f"| Métrica | Valor |")
    lines.append(f"|---------|-------|")
    lines.append(f"| Jobs analizados | {len(jobs)} |")
    lines.append(f"| Exitosos (código 000) | {ok_n} |")
    lines.append(f"| Con errores Informix | {err_n} |")
    lines.append(f"| Con advertencias | {warn_n} |")
    dbs = sorted({db for j in jobs for db in j.databases})
    lines.append(f"| Bases de datos accedidas | {len(dbs)} ({', '.join(f'`{d}`' for d in dbs)}) |")
    lines.append("")

    # Tabla de jobs
    lines.append("## Detalle por job")
    lines.append("")
    lines.append("| Estado | Job | BD | SQL | Inicio | Duración | Código | Filas |")
    lines.append("|--------|-----|----|-----|--------|----------|--------|-------|")
    for job in sorted(jobs, key=lambda j: j.start_ts or datetime.min):
        icon   = _status_icon(job)
        dbs_s  = ', '.join(f'`{d}`' for d in job.databases) or '—'
        sql_s  = ', '.join(f'`{s}`' for s in job.sql_files) or '—'
        start  = job.start_ts.strftime('%H:%M:%S') if job.start_ts else '—'
        dur    = f"{job.duration_s}s" if job.duration_s is not None else '—'
        code   = f"`{job.main_code}`" if job.main_code else '—'
        rows_s = '; '.join(f"{n} {op}" for n, op in job.rows) or '—'
        lines.append(f"| {icon} | `{job.job_name}` | {dbs_s} | {sql_s} | {start} | {dur} | {code} | {rows_s} |")
    lines.append("")

    # Errores
    err_jobs = [j for j in jobs if j.errors or j.isam_errors]
    if err_jobs:
        lines.append("## Errores detectados")
        lines.append("")
        for job in err_jobs:
            lines.append(f"### `{job.job_name}`")
            lines.append("")
            for ln, msg in job.errors:
                lines.append(f"- L{ln}: `{msg}`")
            for ln, code in job.isam_errors:
                lines.append(f"- L{ln}: ISAM error `{code}`")
            lines.append("")
    else:
        lines.append("## Errores detectados")
        lines.append("")
        lines.append("Ninguno — todos los jobs terminaron sin errores Informix.")
        lines.append("")

    # Advertencias
    warn_jobs = [j for j in jobs if j.warnings and not j.errors]
    if warn_jobs:
        lines.append("## Advertencias")
        lines.append("")
        for job in warn_jobs:
            lines.append(f"### `{job.job_name}`")
            lines.append("")
            for ln, msg in job.warnings[:5]:
                lines.append(f"- L{ln}: {msg}")
            if len(job.warnings) > 5:
                lines.append(f"- *(+{len(job.warnings) - 5} advertencias adicionales)*")
            lines.append("")

    # Números negativos (si no fueron ya clasificados como errores)
    neg_jobs = [j for j in jobs if j.negatives and not j.errors]
    if neg_jobs:
        lines.append("## Códigos negativos (sin clasificar)")
        lines.append("")
        lines.append("*Números negativos encontrados fuera del contexto de errores Informix. "
                     "Pueden ser valores de negocio o códigos de retorno no estándar.*")
        lines.append("")
        for job in neg_jobs:
            lines.append(f"### `{job.job_name}`")
            for ln, code, ctx in job.negatives[:5]:
                lines.append(f"- L{ln}: `{code}` — `{ctx}`")
            lines.append("")

    # Señales para la migración
    lines.append("## Señales para la migración Informix")
    lines.append("")
    all_dbs  = sorted({db for j in jobs for db in j.databases})
    all_sqls = sorted({sql for j in jobs for sql in j.sql_files})
    lines.append(f"- **BDs batch activas**: {', '.join(f'`{d}`' for d in all_dbs)} — "
                 "estas BDs tienen jobs de cierre diario que deben reproducirse en el target.")
    lines.append(f"- **Scripts SQL de cierre**: {', '.join(f'`{s}`' for s in all_sqls)} — "
                 "buscar en `source/informix/` para análisis de equivalencia funcional.")
    lines.append(f"- **Scheduler**: Control-M 9.0.22.x en `DCMSIF01` — "
                 "la migración debe incluir la replicación del calendar/schedule en el target "
                 "(preferentemente AWS EventBridge Scheduler o Step Functions).")
    if err_jobs:
        lines.append(f"- **{len(err_jobs)} job(s) con errores** — revisar antes del cutover: "
                     + ', '.join(f'`{j.job_name}`' for j in err_jobs))
    lines.append("")
    lines.append("---")
    lines.append(f"*Evidencia: `source/logs/{log_date}/` · Generado: {now_str}*")

    return '\n'.join(lines)


def generate_json(jobs: list[JobResult], log_date: str) -> dict:
    return {
        'log_date':  log_date,
        'generated': datetime.now().isoformat(),
        'summary': {
            'total': len(jobs),
            'ok':    sum(1 for j in jobs if j.ok),
            'error': sum(1 for j in jobs if j.errors or j.isam_errors),
        },
        'jobs': [{
            'job_name':   j.job_name,
            'file_ts':    j.file_ts,
            'part':       j.part,
            'ifx_server': j.ifx_server,
            'databases':  j.databases,
            'sql_files':  j.sql_files,
            'start':      j.start_ts.isoformat() if j.start_ts else None,
            'end':        j.end_ts.isoformat()   if j.end_ts   else None,
            'duration_s': j.duration_s,
            'results':    j.results,
            'main_code':  j.main_code,
            'ok':         j.ok,
            'rows':       j.rows,
            'errors':     j.errors,
            'isam_errors': j.isam_errors,
            'warnings':   [(ln, msg) for ln, msg in j.warnings[:10]],
            'negatives':  [(ln, code) for ln, code, _ in j.negatives[:10]],
        } for j in jobs]
    }


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    import argparse
    ap = argparse.ArgumentParser(description='Informix Control-M Log Analyzer')
    ap.add_argument('--date', default=LOG_DATE,
                    help=f'Fecha a analizar YYYY-MM-DD (default: {LOG_DATE})')
    ap.add_argument('--file', help='Analizar un archivo específico directamente')
    args = ap.parse_args()

    log_date = args.date

    if args.file:
        files = [args.file]
    else:
        files = find_ctm_files(log_date)

    if not files:
        print(f"No se encontraron archivos *_output_*.txt para la fecha {log_date}")
        print(f"  Buscado en: {LOGS_ROOT}/{log_date}/  y  {LOGS_ROOT}/")
        sys.exit(0)

    print(f"=== Informix Control-M Analyzer v1.0 ===")
    print(f"Fecha: {log_date}  |  Archivos: {len(files)}")
    print()

    jobs: list[JobResult] = []
    for fp in files:
        job = parse_ctm_file(fp)
        jobs.append(job)
        icon = _status_icon(job)
        dur  = f"{job.duration_s}s" if job.duration_s is not None else '?s'
        dbs  = ', '.join(job.databases) or '—'
        print(f"  {icon}  {job.job_name:<45}  {dbs:<12}  código={job.main_code or '?':>5}  {dur}")
        if job.errors:
            for ln, msg in job.errors:
                print(f"       ERROR L{ln}: {msg}")
        if job.isam_errors:
            for ln, code in job.isam_errors:
                print(f"       ISAM  L{ln}: {code}")

    # Outputs
    pathlib.Path(KB_OUT).mkdir(parents=True, exist_ok=True)
    md_path   = f"{KB_OUT}/ctm-batch-analysis-{log_date}.md"
    json_path = f"{KB_OUT}/ctm-batch-jobs-{log_date}.json"

    with open(md_path,   'w', encoding='utf-8') as f:
        f.write(generate_md(jobs, log_date))
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(generate_json(jobs, log_date), f, ensure_ascii=False, indent=2)

    print()
    print(f"✓ MD  → {md_path}")
    print(f"✓ JSON→ {json_path}")


if __name__ == '__main__':
    main()

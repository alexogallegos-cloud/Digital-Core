#!/usr/bin/env python3
"""
analyze-was-logs.py — Informix WAS Log Analyzer v1.0

Parsea logs WebSphere Application Server 9.0.5.15 de la capa Java/SOAP que
envuelve el core Informix de BanCoppel (nodos 10.27.31.20 y 10.27.31.32).

Inputs:
  source/logs/{DATE}/{NODE}/**/SystemOut*.log  — SOAP req/resp + errores app
  source/logs/{DATE}/{NODE}/**/SystemErr*.log  — excepciones Java
  source/logs/{DATE}/{NODE}/**/http_access.log — accesos HTTP Apache combined

Output:
  knowledge-base/cross-reference/was-log-analysis-{DATE}.md
  knowledge-base/cross-reference/was-services-{DATE}.json
"""
import re, os, sys, json, pathlib, glob
from collections import defaultdict, Counter
from datetime import datetime

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BCOP = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/Informix")
LOGS_ROOT = f"{BCOP}/source/logs"
KB_OUT    = f"{BCOP}/knowledge-base/cross-reference"

# Fecha de los logs a analizar (subcarpeta bajo LOGS_ROOT)
LOG_DATE = "2026-08-07"

# ── Regex ──────────────────────────────────────────────────────────────────────

# WAS log line prefix: [8/7/26 12:48:26:441 CST] THREAD STREAM TYPE ...
RE_WAS_PREFIX = re.compile(
    r'^\[(\d+/\d+/\d+\s+\d+:\d+:\d+:\d+\s+\w+)\]\s+\w+\s+\w+\s+[OR]\s+'
    r'(\d+:\d+:\d+\.\d+)\s+\[([^\]]+)\]\s+(\w+)\s+([\w.$]+)\s+-\s+(.*)', re.DOTALL
)

# Hora del timestamp WAS: [8/7/26 HH:MM:...
RE_WAS_HOUR = re.compile(r'^\[\d+/\d+/\d+\s+(\d+):')

# Hora del timestamp http_access: [DD/Mon/YYYY:HH:MM:SS ...]
RE_HTTP_HOUR = re.compile(r'\[\d+/\w+/\d+:(\d+):')

# Namespace URL SOAP: http://www.bancoppel.com/{Context}/{OpName}/
RE_SOAP_NS = re.compile(r'http://www\.bancoppel\.com/([A-Za-z0-9_]+)/([A-Za-z0-9_]+)/')

# Códigos de retorno (múltiples variantes de nombre)
RE_RETCODE = re.compile(
    r'<(?:CodRet|vCodRetorno|cCodRet|cCodret|codRetorno|vCodRet|CodRetorno'
    r'|statusCode|errorCode|codError|returnCode)>([^<]*)'
    r'</(?:CodRet|vCodRetorno|cCodRet|cCodret|codRetorno|vCodRet|CodRetorno'
    r'|statusCode|errorCode|codError|returnCode)>',
    re.IGNORECASE
)

# Primera línea de excepción Java: ClassName: mensaje
RE_EXC_FIRST = re.compile(
    r'^((?:mx\.com\.solser|java\.|javax\.|org\.|com\.ibm\.)[a-zA-Z0-9.$]+'
    r'(?:Exception|Error|Fault|Throwable)):\s*(.*)'
)

# Apache combined log format
RE_HTTP = re.compile(
    r'^(\S+)\s+-\s+-\s+\[([^\]]+)\]\s+"(\w+)\s+(\S+)\s+HTTP/[\d.]+"\s+(\d+)\s+(\d+)'
)

# SystemErr line: [ts] THREAD SystemErr R <message>
RE_SYSERR_MSG = re.compile(r'^\[[^\]]+\]\s+\w+\s+SystemErr\s+R\s+(.*)', re.DOTALL)

STATIC_EXTS = frozenset({'.png', '.jpg', '.gif', '.css', '.js', '.ico', '.svg',
                          '.woff', '.ttf', '.map', '.class', '.properties'})


# ── Acumuladores por nodo ──────────────────────────────────────────────────────

class NodeStats:
    def __init__(self, node_ip: str):
        self.node_ip = node_ip
        # SOAP (desde SystemOut)
        self.soap_resp     = Counter()           # op_name → respuestas totales
        self.soap_req      = Counter()           # op_name → requests totales
        self.soap_errors   = Counter()           # op_name → responses con retcode negativo
        self.soap_retcodes = defaultdict(Counter) # op_name → {retcode: n}
        self.soap_ctx      = Counter()           # context → llamadas
        self.soap_hourly   = defaultdict(Counter) # hora → {op_name: n}
        # Errores en SystemOut (nivel ERROR)
        self.sysout_err_cls = Counter()          # clase Java → n
        self.sysout_err_msg = defaultdict(Counter) # clase → {msg: n}
        # Excepciones (desde SystemErr)
        self.exc_cls       = Counter()           # clase → n
        self.exc_msg       = defaultdict(Counter) # clase → {msg: n}
        # HTTP access
        self.http_ctx      = Counter()           # /AppCtx → n
        self.http_op       = Counter()           # operación (.go) → n
        self.http_status   = Counter()           # código HTTP → n
        self.http_hourly   = defaultdict(Counter) # hora → {ctx: n}
        self.http_errors   = Counter()           # operación con status>=400 → n
        self.http_methods  = Counter()           # método HTTP → n
        # Metadata
        self.files = []
        self.lines_total = 0


def _is_error_retcode(code: str) -> bool:
    c = code.strip()
    if not c:
        return False
    try:
        return int(c) < 0
    except ValueError:
        return False


def parse_systemout(path: str, stats: NodeStats) -> int:
    """Parsea un SystemOut*.log línea a línea."""
    lines = 0
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            for raw in f:
                lines += 1
                line = raw.rstrip('\r\n')
                if not line.startswith('['):
                    continue  # línea de continuación (stack trace sin prefijo)

                m = RE_WAS_PREFIX.match(line)
                if not m:
                    continue
                ts_str, time_str, pool, level, cls, msg = m.groups()

                hour_m = RE_WAS_HOUR.match(line)
                hour = int(hour_m.group(1)) if hour_m else -1

                is_soap_resp = ('ClienteSoapService - response:' in line)
                is_soap_req  = ('ClienteSoapService - request:'  in line)

                if is_soap_resp or is_soap_req:
                    # Extraer op_name desde namespace URL
                    ns_matches = RE_SOAP_NS.findall(msg)
                    if ns_matches:
                        # Primer namespace — normalmente el principal
                        ctx, op_name = ns_matches[0]
                        stats.soap_ctx[ctx] += 1
                        if is_soap_resp:
                            stats.soap_resp[op_name] += 1
                            if hour >= 0:
                                stats.soap_hourly[hour][op_name] += 1
                            # Extraer retcodes
                            retcodes = RE_RETCODE.findall(msg)
                            for rc in retcodes:
                                rc = rc.strip()
                                if rc:
                                    stats.soap_retcodes[op_name][rc] += 1
                                    if _is_error_retcode(rc):
                                        stats.soap_errors[op_name] += 1
                        else:
                            stats.soap_req[op_name] += 1

                elif level == 'ERROR':
                    # Error en capa Java (no SOAP)
                    short_cls = cls.split('.')[-1]
                    stats.sysout_err_cls[short_cls] += 1
                    # Extraer mensaje corto (hasta fin o 120 chars)
                    short_msg = msg[:120].strip()
                    stats.sysout_err_msg[short_cls][short_msg] += 1

    except OSError as e:
        print(f"  WARN: no se pudo leer {path}: {e}")
    stats.files.append(os.path.basename(path))
    stats.lines_total += lines
    return lines


def parse_syserr(path: str, stats: NodeStats) -> int:
    """Parsea un SystemErr*.log — captura primera línea de cada excepción."""
    lines = 0
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            for raw in f:
                lines += 1
                line = raw.rstrip('\r\n')
                if not line.startswith('['):
                    continue
                m_prefix = RE_SYSERR_MSG.match(line)
                if not m_prefix:
                    continue
                msg = m_prefix.group(1).strip()
                # ¿Es primera línea de excepción?
                m_exc = RE_EXC_FIRST.match(msg)
                if m_exc:
                    exc_cls, exc_msg = m_exc.group(1), m_exc.group(2)
                    short_cls = exc_cls.split('.')[-1]
                    stats.exc_cls[short_cls] += 1
                    stats.exc_msg[short_cls][exc_msg[:100].strip()] += 1
    except OSError as e:
        print(f"  WARN: no se pudo leer {path}: {e}")
    return lines


def parse_http_access(path: str, stats: NodeStats) -> int:
    """Parsea http_access.log en formato Apache combined."""
    lines = 0
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            for raw in f:
                lines += 1
                line = raw.rstrip('\r\n')
                m = RE_HTTP.match(line)
                if not m:
                    continue
                _ip, ts_str, method, path_str, status, _bytes = m.groups()
                status = int(status)
                stats.http_status[status] += 1
                stats.http_methods[method] += 1

                # Extraer contexto de la primera parte del path: /CtxApp/...
                parts = path_str.split('/')
                ctx = parts[1] if len(parts) > 1 else 'unknown'

                # Separar activos estáticos de operaciones
                ext = os.path.splitext(path_str)[1].lower()
                if ext in STATIC_EXTS:
                    continue  # ignorar estáticos

                stats.http_ctx[ctx] += 1
                # Operación = último segmento del path
                op = parts[-1].split('?')[0] if parts else path_str
                stats.http_op[op] += 1
                if status >= 400:
                    stats.http_errors[op] += 1

                # Hora
                hour_m = RE_HTTP_HOUR.search(ts_str)
                if hour_m:
                    hour = int(hour_m.group(1))
                    stats.http_hourly[hour][ctx] += 1

    except OSError as e:
        print(f"  WARN: no se pudo leer {path}: {e}")
    return lines


def _find_node_dirs(date_dir: str) -> list[tuple[str, str]]:
    """
    Retorna lista de (node_ip, log_dir) para todos los nodos bajo date_dir.
    Maneja dos estructuras:
      date_dir/10.27.31.20/*.log       (un nivel)
      date_dir/10.27.31.32/10.27.31.32/*.log  (dos niveles — ZIP anidado)
    """
    result = []
    if not os.path.isdir(date_dir):
        return result
    for entry in sorted(os.listdir(date_dir)):
        node_path = os.path.join(date_dir, entry)
        if not os.path.isdir(node_path):
            continue
        node_ip = entry
        # ¿Hay logs directamente?
        if any(f.endswith('.log') for f in os.listdir(node_path) if os.path.isfile(os.path.join(node_path, f))):
            result.append((node_ip, node_path))
        else:
            # Buscar un nivel más abajo (ZIP doblemente anidado)
            for sub in os.listdir(node_path):
                sub_path = os.path.join(node_path, sub)
                if os.path.isdir(sub_path) and any(
                    f.endswith('.log') for f in os.listdir(sub_path)
                    if os.path.isfile(os.path.join(sub_path, f))
                ):
                    result.append((node_ip, sub_path))
    return result


def analyze_node(node_ip: str, log_dir: str) -> NodeStats:
    stats = NodeStats(node_ip)
    print(f"\n  Nodo {node_ip}  ({log_dir})")

    # SystemOut (todos los rotados, ordenados por nombre)
    sysout_files = sorted(glob.glob(os.path.join(log_dir, 'SystemOut*.log')))
    for p in sysout_files:
        n = parse_systemout(p, stats)
        print(f"    SystemOut  {os.path.basename(p):40s}  {n:>8,} líneas")

    # SystemErr (todos los rotados)
    syserr_files = sorted(glob.glob(os.path.join(log_dir, 'SystemErr*.log')))
    for p in syserr_files:
        n = parse_syserr(p, stats)
        print(f"    SystemErr  {os.path.basename(p):40s}  {n:>8,} líneas")

    # http_access (solo uno)
    http_file = os.path.join(log_dir, 'http_access.log')
    if os.path.isfile(http_file):
        n = parse_http_access(http_file, stats)
        print(f"    http_access  {'http_access.log':38s}  {n:>8,} líneas")

    print(f"    → SOAP responses: {sum(stats.soap_resp.values()):,} | "
          f"HTTP ops: {sum(stats.http_op.values()):,} | "
          f"Excepciones: {sum(stats.exc_cls.values()):,}")
    return stats


# ── Merge de nodos ─────────────────────────────────────────────────────────────

def merge_stats(all_stats: list[NodeStats]) -> NodeStats:
    merged = NodeStats("ALL")
    for s in all_stats:
        merged.soap_resp    += s.soap_resp
        merged.soap_req     += s.soap_req
        merged.soap_errors  += s.soap_errors
        merged.soap_ctx     += s.soap_ctx
        merged.sysout_err_cls += s.sysout_err_cls
        merged.exc_cls      += s.exc_cls
        merged.http_ctx     += s.http_ctx
        merged.http_op      += s.http_op
        merged.http_status  += s.http_status
        merged.http_errors  += s.http_errors
        merged.http_methods += s.http_methods
        merged.files        += s.files
        merged.lines_total  += s.lines_total
        for op, rc_ctr in s.soap_retcodes.items():
            merged.soap_retcodes[op] += rc_ctr
        for op, h_ctr in s.soap_hourly.items():
            merged.soap_hourly[op] += h_ctr
        for cls, msg_ctr in s.exc_msg.items():
            merged.exc_msg[cls] += msg_ctr
        for cls, msg_ctr in s.sysout_err_msg.items():
            merged.sysout_err_msg[cls] += msg_ctr
        for ctx, h_ctr in s.http_hourly.items():
            merged.http_hourly[ctx] += h_ctr
    return merged


# ── Generadores de salida ──────────────────────────────────────────────────────

def _retcode_summary(op_name: str, rc_ctr: Counter) -> str:
    """Formatea los retcodes más frecuentes para una operación."""
    top = rc_ctr.most_common(5)
    parts = []
    for rc, n in top:
        flag = ' ⚠' if _is_error_retcode(rc) else ''
        parts.append(f"`{rc}`×{n}{flag}")
    return ', '.join(parts)


def _hourly_heatmap(hourly_counter: Counter, width=24) -> str:
    """Tabla ASCII de distribución horaria."""
    total = sum(hourly_counter.values()) or 1
    max_val = max(hourly_counter.values(), default=1)
    bars = []
    for h in range(width):
        v = hourly_counter.get(h, 0)
        pct = v / total * 100
        bar_len = int(v / max_val * 20) if max_val > 0 else 0
        bars.append(f"  {h:02d}h  {'█' * bar_len:20s}  {v:>6,}  ({pct:4.1f}%)")
    return '\n'.join(bars)


def generate_md(all_nodes: list[NodeStats], merged: NodeStats, log_date: str) -> str:
    now_str = datetime.now().strftime('%Y-%m-%d %H:%M')
    total_soap = sum(merged.soap_resp.values())
    total_http = sum(merged.http_op.values())
    total_exc  = sum(merged.exc_cls.values())
    total_err  = sum(merged.soap_errors.values())
    error_rate = (total_err / total_soap * 100) if total_soap else 0

    lines = []
    lines.append(f"# Análisis WAS — BanCoppel Informix · {log_date}")
    lines.append(f"> Generado: {now_str} · `generators/analyze-was-logs.py` v1.0")
    lines.append("")
    lines.append("## Contexto")
    lines.append("")
    lines.append("Estos logs corresponden a la **capa Java/SOAP (IBM WebSphere 9.0.5.15 / AIX 7.2)** "
                 "que envuelve el core Informix IDS 14.10. No son logs del motor Informix directamente — "
                 "son del middleware Java que expone los Stored Procedures como SOAP web services.")
    lines.append("")
    lines.append("**Stack observado:**")
    lines.append("```")
    lines.append("Cliente (sucursal/caja)  →  WAS ClusterMember1_OfiWeb  →  SOAP  →  Informix SP")
    lines.append("  BcplSucApp / CajaNacionalApp        Spring MVC                  core bancario")
    lines.append("```")
    lines.append("")
    lines.append("**Nota de trazabilidad:** los nombres de operación SOAP (PascalCase, p. ej. "
                 "`SpgeneraReportePpWeb`) corresponden a contratos Java, no necesariamente 1:1 "
                 "con los nombres snake_case de los SPs en brain.db. La correspondencia requiere "
                 "inspección del código fuente Java.")
    lines.append("")

    # Servidores
    lines.append("## Servidores analizados")
    lines.append("")
    lines.append("| Nodo | Archivos | Líneas totales | SOAP resp | HTTP ops |")
    lines.append("|------|----------|---------------|-----------|----------|")
    for ns in all_nodes:
        sr = sum(ns.soap_resp.values())
        ho = sum(ns.http_op.values())
        lines.append(f"| `{ns.node_ip}` | {len(ns.files)} | {ns.lines_total:,} | {sr:,} | {ho:,} |")
    lines.append("")

    # Resumen ejecutivo
    lines.append("## Resumen ejecutivo")
    lines.append("")
    lines.append(f"| Métrica | Valor |")
    lines.append(f"|---------|-------|")
    lines.append(f"| Operaciones SOAP distintas | {len(merged.soap_resp):,} |")
    lines.append(f"| Llamadas SOAP totales (responses) | {total_soap:,} |")
    lines.append(f"| Llamadas con retcode negativo | {total_err:,} ({error_rate:.2f}%) |")
    lines.append(f"| Endpoints HTTP (business) | {len(merged.http_op):,} |")
    lines.append(f"| Llamadas HTTP (business) | {total_http:,} |")
    lines.append(f"| Excepciones Java distintas | {len(merged.exc_cls):,} |")
    lines.append(f"| Total excepciones capturadas | {total_exc:,} |")
    lines.append(f"| Contextos SOAP activos | {len(merged.soap_ctx):,} |")
    lines.append("")

    # SOAP contexts
    lines.append("### Contextos SOAP (grupos de aplicación)")
    lines.append("")
    lines.append("| Contexto | Llamadas | % |")
    lines.append("|----------|----------|---|")
    for ctx, n in merged.soap_ctx.most_common(20):
        pct = n / total_soap * 100 if total_soap else 0
        lines.append(f"| `{ctx}` | {n:,} | {pct:.1f}% |")
    lines.append("")

    # Top SOAP services
    lines.append("## Catálogo de servicios SOAP")
    lines.append("")
    lines.append("Ordenados por volumen de llamadas (solo operaciones con ≥5 respuestas).")
    lines.append("")
    lines.append("| # | Operación | Llamadas | Errores (ret<0) | Err% | Retcodes principales |")
    lines.append("|---|-----------|----------|----------------|------|----------------------|")
    ranked = [(op, n) for op, n in merged.soap_resp.most_common() if n >= 5]
    for i, (op, n) in enumerate(ranked[:60], 1):
        errs = merged.soap_errors.get(op, 0)
        ep   = errs / n * 100 if n else 0
        rc_s = _retcode_summary(op, merged.soap_retcodes.get(op, Counter()))
        flag = " ⚠" if ep > 5 else ""
        lines.append(f"| {i} | `{op}` | {n:,} | {errs:,} | {ep:.1f}%{flag} | {rc_s} |")
    if len(ranked) > 60:
        lines.append(f"| … | *(+{len(ranked)-60} operaciones con < llamadas)* | | | | |")
    lines.append("")

    # Error breakdown por servicio
    error_svcs = [(op, n) for op, n in merged.soap_errors.most_common() if n > 0]
    if error_svcs:
        lines.append("### Servicios con errores (retcode negativo)")
        lines.append("")
        lines.append("| Operación | Total calls | Errores | Err% | Retcodes de error |")
        lines.append("|-----------|-------------|---------|------|------------------|")
        for op, errs in error_svcs[:30]:
            total_op = merged.soap_resp.get(op, 0)
            ep = errs / total_op * 100 if total_op else 0
            err_rcs = {rc: n for rc, n in merged.soap_retcodes.get(op, {}).items()
                       if _is_error_retcode(rc)}
            rc_str = ', '.join(f'`{rc}`×{n}' for rc, n in
                               sorted(err_rcs.items(), key=lambda x: -x[1])[:4])
            lines.append(f"| `{op}` | {total_op:,} | {errs:,} | {ep:.1f}% | {rc_str} |")
        lines.append("")

    # Distribución horaria SOAP
    lines.append("### Distribución horaria — SOAP responses (hora CST)")
    lines.append("")
    # soap_hourly: hora(int) → Counter(op_name→n)
    hourly_total: Counter = Counter()
    for hour, op_ctr in merged.soap_hourly.items():
        hourly_total[hour] += sum(op_ctr.values())
    if hourly_total:
        lines.append("```")
        lines.append(_hourly_heatmap(hourly_total))
        lines.append("```")
    else:
        lines.append("*(no se capturó información de hora)*")
    lines.append("")

    # Excepciones Java
    lines.append("## Catálogo de excepciones Java")
    lines.append("")
    lines.append("*Extraído de SystemErr.log — primera línea de cada stack trace.*")
    lines.append("")
    lines.append("| Excepción | Ocurrencias | Mensaje más frecuente |")
    lines.append("|-----------|-------------|----------------------|")
    for cls, n in merged.exc_cls.most_common(25):
        top_msgs = merged.exc_msg.get(cls, Counter()).most_common(1)
        top_msg  = top_msgs[0][0] if top_msgs else ''
        lines.append(f"| `{cls}` | {n:,} | {top_msg[:80]} |")
    lines.append("")

    # Errores en capa Java (SystemOut ERROR)
    if merged.sysout_err_cls:
        lines.append("### Errores registrados en SystemOut (nivel ERROR)")
        lines.append("")
        lines.append("| Clase | Ocurrencias | Mensaje frecuente |")
        lines.append("|-------|-------------|------------------|")
        for cls, n in merged.sysout_err_cls.most_common(20):
            top_msgs = merged.sysout_err_msg.get(cls, Counter()).most_common(1)
            top_msg  = top_msgs[0][0] if top_msgs else ''
            lines.append(f"| `{cls}` | {n:,} | {top_msg[:80]} |")
        lines.append("")

    # HTTP endpoints
    lines.append("## Endpoints HTTP (frontend → WAS)")
    lines.append("")
    lines.append("*Solo operaciones de negocio (excluye activos estáticos).*")
    lines.append("")

    lines.append("### Por contexto de aplicación")
    lines.append("")
    lines.append("| Contexto | Llamadas | % |")
    lines.append("|----------|----------|---|")
    for ctx, n in merged.http_ctx.most_common():
        pct = n / total_http * 100 if total_http else 0
        lines.append(f"| `{ctx}` | {n:,} | {pct:.1f}% |")
    lines.append("")

    lines.append("### Top 50 operaciones HTTP")
    lines.append("")
    lines.append("| # | Operación | Llamadas | Errores HTTP (≥400) |")
    lines.append("|---|-----------|----------|---------------------|")
    for i, (op, n) in enumerate(merged.http_op.most_common(50), 1):
        errs = merged.http_errors.get(op, 0)
        lines.append(f"| {i} | `{op}` | {n:,} | {errs} |")
    lines.append("")

    lines.append("### Distribución de códigos HTTP")
    lines.append("")
    lines.append("| Status | Descripción | Llamadas |")
    lines.append("|--------|-------------|----------|")
    status_desc = {200: 'OK', 201: 'Created', 204: 'No Content',
                   301: 'Redirect', 302: 'Found', 304: 'Not Modified',
                   400: 'Bad Request', 401: 'Unauthorized', 403: 'Forbidden',
                   404: 'Not Found', 405: 'Method Not Allowed',
                   500: 'Internal Server Error', 503: 'Service Unavailable'}
    for status, n in sorted(merged.http_status.items()):
        desc = status_desc.get(status, '')
        lines.append(f"| {status} | {desc} | {n:,} |")
    lines.append("")

    # Riesgos de migración
    lines.append("## Señales para la migración Informix")
    lines.append("")
    lines.append("Observaciones directamente relevantes para `SPE-AM-001`:")
    lines.append("")

    risk_items = []

    # Error rate
    if error_rate > 1:
        risk_items.append(
            f"**Tasa de error SOAP {error_rate:.2f}%** — {total_err:,} respuestas con retcode "
            f"negativo sobre {total_soap:,} totales. Los servicios de mayor error rate requieren "
            f"golden master tests específicos en la fase de equivalencia."
        )
    else:
        risk_items.append(
            f"**Tasa de error SOAP baja ({error_rate:.2f}%)** — base sana para parallel-run; "
            f"threshold del SLO DoD-SPE-AM-01 es ≤0.05% de divergencia."
        )

    # Top error service
    if error_svcs:
        top_err_op, top_err_n = error_svcs[0]
        top_err_total = merged.soap_resp.get(top_err_op, 0)
        risk_items.append(
            f"**Servicio con más errores:** `{top_err_op}` — {top_err_n:,} errores / "
            f"{top_err_total:,} llamadas ({top_err_n/top_err_total*100:.1f}%). "
            f"Investigar causa raíz antes del cutover de esta operación."
        )

    # BusinessException
    be = merged.exc_cls.get('BusinessException', 0)
    if be:
        top_be = merged.exc_msg.get('BusinessException', Counter()).most_common(3)
        msgs_str = '; '.join(f'"{m}"×{n}' for m, n in top_be)
        risk_items.append(
            f"**BusinessException: {be:,} ocurrencias** — mensajes principales: {msgs_str}. "
            f"Estas excepciones son reglas de negocio en la capa Java que deberán mapearse "
            f"a equivalentes en la arquitectura target."
        )

    # NullPointerException
    npe = merged.exc_cls.get('NullPointerException', 0)
    if npe:
        risk_items.append(
            f"**NullPointerException: {npe:,} ocurrencias** — defectos en la capa Java actual. "
            f"Registrar como riesgos de equivalencia; el target no debería heredar estos defectos."
        )

    # Contextos activos
    risk_items.append(
        f"**{len(merged.soap_ctx)} contextos SOAP activos** — "
        + ', '.join(f'`{c}`' for c, _ in merged.soap_ctx.most_common(8))
        + ". Cada contexto es un WAR/módulo Java independiente que envuelve SPs de Informix; "
          "cada uno requiere un Anti-Corruption Layer propio en el target."
    )

    # Volumen
    top_ops = merged.soap_resp.most_common(3)
    top_ops_str = ', '.join(f'`{op}`×{n:,}' for op, n in top_ops)
    risk_items.append(
        f"**Operaciones de mayor volumen:** {top_ops_str}. "
        f"Estas operaciones son candidatas prioritarias para parallel-run desde el inicio de BUILD."
    )

    for ri in risk_items:
        lines.append(f"- {ri}")
        lines.append("")

    lines.append("---")
    lines.append(f"*Evidencia: `source/logs/{log_date}/` · Generado: {now_str}*")

    return '\n'.join(lines)


def generate_json(all_nodes: list[NodeStats], merged: NodeStats, log_date: str) -> dict:
    """JSON con catálogo de servicios SOAP para consumo programático."""
    services = []
    for op, calls in merged.soap_resp.most_common():
        errs  = merged.soap_errors.get(op, 0)
        rc_ctr = merged.soap_retcodes.get(op, Counter())
        services.append({
            'op_name':   op,
            'calls':     calls,
            'errors':    errs,
            'error_pct': round(errs / calls * 100, 2) if calls else 0,
            'retcodes':  dict(rc_ctr.most_common(10)),
        })
    nodes_meta = [{
        'node_ip':   ns.node_ip,
        'soap_ops':  sum(ns.soap_resp.values()),
        'http_ops':  sum(ns.http_op.values()),
        'exceptions': sum(ns.exc_cls.values()),
    } for ns in all_nodes]
    return {
        'log_date':     log_date,
        'generated':    datetime.now().isoformat(),
        'nodes':        nodes_meta,
        'soap_services': services,
        'exceptions':   dict(merged.exc_cls.most_common()),
        'http_contexts': dict(merged.http_ctx.most_common()),
        'http_status':  {str(k): v for k, v in merged.http_status.items()},
    }


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    date_dir = os.path.join(LOGS_ROOT, LOG_DATE)
    if not os.path.isdir(date_dir):
        print(f"ERROR: carpeta no encontrada: {date_dir}")
        sys.exit(1)

    node_dirs = _find_node_dirs(date_dir)
    if not node_dirs:
        print(f"ERROR: no se encontraron nodos en {date_dir}")
        sys.exit(1)

    print(f"=== Informix WAS Log Analyzer v1.0 ===")
    print(f"Fecha: {LOG_DATE}  |  Nodos: {len(node_dirs)}")

    all_stats = []
    for node_ip, log_dir in node_dirs:
        stats = analyze_node(node_ip, log_dir)
        all_stats.append(stats)

    merged = merge_stats(all_stats)
    total_soap = sum(merged.soap_resp.values())
    total_http = sum(merged.http_op.values())
    print(f"\n=== Totales consolidados ===")
    print(f"  SOAP operations distintas : {len(merged.soap_resp):,}")
    print(f"  SOAP responses totales    : {total_soap:,}")
    print(f"  SOAP errors (ret<0)       : {sum(merged.soap_errors.values()):,}")
    print(f"  HTTP ops (business)       : {total_http:,}")
    print(f"  Excepciones Java          : {sum(merged.exc_cls.values()):,}")

    # Generar outputs
    pathlib.Path(KB_OUT).mkdir(parents=True, exist_ok=True)

    md_path   = f"{KB_OUT}/was-log-analysis-{LOG_DATE}.md"
    json_path = f"{KB_OUT}/was-services-{LOG_DATE}.json"

    md_content = generate_md(all_stats, merged, LOG_DATE)
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write(md_content)
    print(f"\n✓ MD  → {md_path}")

    json_content = generate_json(all_stats, merged, LOG_DATE)
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(json_content, f, ensure_ascii=False, indent=2)
    print(f"✓ JSON→ {json_path}")


if __name__ == '__main__':
    main()

"""
analyze-logs.py — BCOPCore Bus Log Analyzer
Proyecto: BanCoppel BCOPCore · SPE-AM-001
Fuente: source/logs/ — 48 archivos (transacciones_bus + errores_bus, 2026-04-24)

Produce en output/:
  sp-frequency.json        — ranking de SPs por volumen de llamadas
  service-topology.json    — sistemaOrigen → servicio → [SPs]
  error-catalog.json       — errores agrupados por código + servicio + SP
  hourly-heatmap.json      — volumen por hora × dominio (D01-D12)
  known-issues.json        — errores recurrentes silenciosos detectados
  19-performance-baseline.md — plantilla poblada con datos reales de producción

Uso:
  python analyze-logs.py [--logs-dir source/logs] [--output-dir output/log-analysis]
"""

import re
import os
import sys
import json
import argparse
from pathlib import Path
from collections import defaultdict

# ---------------------------------------------------------------------------
# Configuración
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).parent

DSN_TO_DOMAIN = {
    "ifx_bdicnweb":        "D01-bdicnweb",
    "ifx_bdinteg":         "D02-bdinteg",
    "ifx_bdinteg_inyau":   "D02-bdinteg",
    "ifx_bdicred":         "D03-bdicred",
    "ifx_bdicheq":         "D04-bdicheq",
    "ifx_bdisac":          "D05-bdisac",
    "ifx_bdisac_remesas":  "D05-bdisac",
    "ifx_bdisolic":        "D06-bdisolic",
    "ifx_bdiaclaracion":   "D07-bdiaclaracion",
    "ifx_bdispei":         "D08-bdispei",
    "ifx_bdimnsj":         "D09-bdimnsj",
    "ifx_bdisuc":          "D10-bdisuc",
    "ifx_bdicobranza":     "D11-bdicobranza",
    "ifx_bdicont":         "D12-bdicont",
    "postg_huellasemps":   "PSQL-huellas",   # ya migrado a PostgreSQL
}

# Errores que son known issues — se registran pero se segregan
KNOWN_ISSUES = {
    "4395": "Huellas442 NullPointerException — postg_huellasemps (bug en target PostgreSQL)",
    "3381": "ACEPTPORTA SFTP auth failure — sysportabnominaapp credenciales inválidas",
}

# Regex para extraer campos del XML por línea (CDATA wrapping)
RE_ID_TRX        = re.compile(r"<idTrxGlobal>(.*?)</idTrxGlobal>")
RE_SISTEMA       = re.compile(r"<sistemaOrigen>(.*?)</sistemaOrigen>")
RE_REFERENCIA    = re.compile(r"<referencia>(.*?)</referencia>")
RE_SERVICIO      = re.compile(r"<servicio>(.*?)</servicio>")
RE_TRAMA         = re.compile(r"<trama>(.*?)</trama>", re.DOTALL)
RE_ESTATUS       = re.compile(r"<estatus>(.*?)</estatus>")
RE_ERROR_COD     = re.compile(r"<codigo>(.*?)</codigo>")
RE_ERROR_DESC    = re.compile(r"<descripcion>(.*?)</descripcion>")

# Extrae DSN y SP de la trama: "ifx_xxx call informix.sp_nombre(" o "call informix.sp_nombre("
RE_TRAMA_IFX     = re.compile(
    r"(?:(ifx_\w+|postg_\w+)\s+)?call\s+(?:informix\.)?(\w+)\s*\(", re.IGNORECASE
)
# Respuesta JSON tras el "||"
RE_RESP_CODE     = re.compile(
    r'"(?:codRetorno|codRespuesta|codRet|CodRetorno|cod_retorno)"\s*:\s*"(\d+)"',
    re.IGNORECASE,
)


# ---------------------------------------------------------------------------
# Parser de línea
# ---------------------------------------------------------------------------

def parse_line(line: str) -> dict | None:
    """Extrae todos los campos relevantes de una línea de log."""
    # Desnuda el CDATA si está presente
    cdata_m = re.search(r"<!\[CDATA\[(.*?)]]>", line, re.DOTALL)
    raw = cdata_m.group(1) if cdata_m else line

    sistema  = (RE_SISTEMA.search(raw)  or {}).group(1) if RE_SISTEMA.search(raw)  else None
    servicio = (RE_SERVICIO.search(raw) or {}).group(1) if RE_SERVICIO.search(raw) else None
    estatus  = (RE_ESTATUS.search(raw)  or {}).group(1) if RE_ESTATUS.search(raw)  else "unknown"
    trama_m  = RE_TRAMA.search(raw)
    trama    = trama_m.group(1) if trama_m else ""

    # SP y DSN desde la trama
    sp_name  = None
    dsn      = None
    domain   = None
    trama_m2 = RE_TRAMA_IFX.search(trama)
    if trama_m2:
        raw_dsn  = trama_m2.group(1) or ""
        sp_name  = trama_m2.group(2)
        dsn      = raw_dsn.lower() if raw_dsn else None
        domain   = DSN_TO_DOMAIN.get(dsn) if dsn else None

    # Código de respuesta desde JSON inline
    resp_code = None
    resp_m = RE_RESP_CODE.search(trama)
    if resp_m:
        resp_code = resp_m.group(1)

    # Error (solo en errores_bus)
    error_code = None
    error_desc = None
    ec_m = RE_ERROR_COD.search(raw)
    if ec_m:
        error_code = ec_m.group(1)
    ed_m = RE_ERROR_DESC.search(raw)
    if ed_m:
        error_desc = ed_m.group(1)[:120]   # trunca descripciones largas

    return {
        "sistema":    sistema,
        "servicio":   servicio,
        "estatus":    estatus,
        "sp_name":    sp_name,
        "dsn":        dsn,
        "domain":     domain,
        "resp_code":  resp_code,
        "error_code": error_code,
        "error_desc": error_desc,
        "trama_raw":  trama[:200],  # muestra solo primeros 200 chars
    }


# ---------------------------------------------------------------------------
# Acumuladores
# ---------------------------------------------------------------------------

def make_accumulators():
    return {
        # sp_name → {calls, errors, domains, sistemas, services, resp_codes}
        "sp_freq":       defaultdict(lambda: {
            "calls": 0, "errors": 0,
            "domains": set(), "sistemas": set(), "services": set(), "resp_codes": defaultdict(int)
        }),
        # (sistema, servicio) → sp_name → count
        "topology":      defaultdict(lambda: defaultdict(int)),
        # error_code → {count, services, sps, sample_desc}
        "error_cat":     defaultdict(lambda: {
            "count": 0, "services": set(), "sps": set(), "sample_desc": None
        }),
        # hour (int) → domain → calls
        "heatmap":       defaultdict(lambda: defaultdict(int)),
        # known issues: error_code → count
        "known_cnt":     defaultdict(int),
        # total lines processed
        "total_lines":   0,
        "parsed_lines":  0,
    }


# ---------------------------------------------------------------------------
# Procesamiento de archivos
# ---------------------------------------------------------------------------

def process_file(path: Path, acc: dict):
    hour = int(path.stem.split("_")[-1])
    is_error_file = "errores_bus" in path.name

    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            acc["total_lines"] += 1

            rec = parse_line(line)
            if not rec:
                continue
            acc["parsed_lines"] += 1

            sp   = rec["sp_name"]
            sys_ = rec["sistema"] or "UNKNOWN"
            svc  = rec["servicio"] or "UNKNOWN"
            dom  = rec["domain"]

            # — SP frequency —
            if sp:
                sf = acc["sp_freq"][sp]
                sf["calls"] += 1
                if rec["estatus"] == "error":
                    sf["errors"] += 1
                if dom:
                    sf["domains"].add(dom)
                sf["sistemas"].add(sys_)
                sf["services"].add(svc)
                if rec["resp_code"]:
                    sf["resp_codes"][rec["resp_code"]] += 1

            # — Service topology —
            if sp:
                acc["topology"][(sys_, svc)][sp] += 1

            # — Hourly heatmap —
            if dom:
                acc["heatmap"][hour][dom] += 1

            # — Error catalog —
            if is_error_file and rec["error_code"]:
                ec = rec["error_code"]
                cat = acc["error_cat"][ec]
                cat["count"] += 1
                if svc != "UNKNOWN":
                    cat["services"].add(svc)
                if sp:
                    cat["sps"].add(sp)
                if not cat["sample_desc"] and rec["error_desc"]:
                    cat["sample_desc"] = rec["error_desc"]
                # Known issues counter
                if ec in KNOWN_ISSUES:
                    acc["known_cnt"][ec] += 1


# ---------------------------------------------------------------------------
# Serialización (sets → lists para JSON)
# ---------------------------------------------------------------------------

def finalize(acc: dict) -> dict:
    # SP frequency: sort by calls desc
    sp_sorted = sorted(
        [
            {
                "sp": sp,
                "calls":      data["calls"],
                "errors":     data["errors"],
                "error_rate": round(data["errors"] / data["calls"] * 100, 2) if data["calls"] else 0,
                "domains":    sorted(data["domains"]),
                "sistemas":   sorted(data["sistemas"]),
                "services":   sorted(data["services"]),
                "top_resp_codes": dict(
                    sorted(data["resp_codes"].items(), key=lambda x: -x[1])[:5]
                ),
            }
            for sp, data in acc["sp_freq"].items()
        ],
        key=lambda x: -x["calls"],
    )

    # Topology: (sistema, servicio) → sp_list sorted by count
    topology_out = {}
    for (sys_, svc), sp_counts in acc["topology"].items():
        key = f"{sys_} → {svc}"
        topology_out[key] = [
            {"sp": sp, "calls": cnt}
            for sp, cnt in sorted(sp_counts.items(), key=lambda x: -x[1])
        ]

    # Error catalog: sort by count desc
    error_out = dict(
        sorted(
            {
                ec: {
                    "count":       data["count"],
                    "known_issue": KNOWN_ISSUES.get(ec),
                    "services":    sorted(data["services"]),
                    "sps":         sorted(data["sps"]),
                    "sample_desc": data["sample_desc"],
                }
                for ec, data in acc["error_cat"].items()
            }.items(),
            key=lambda x: -x[1]["count"],
        )
    )

    # Heatmap: hour (str) → domain → count, sorted by hour
    heatmap_out = {
        str(h): dict(sorted(domains.items()))
        for h, domains in sorted(acc["heatmap"].items())
    }

    # Known issues summary
    known_out = {
        ec: {"count": cnt, "description": KNOWN_ISSUES[ec]}
        for ec, cnt in sorted(acc["known_cnt"].items(), key=lambda x: -x[1])
    }

    return {
        "sp_frequency":     sp_sorted,
        "service_topology": topology_out,
        "error_catalog":    error_out,
        "hourly_heatmap":   heatmap_out,
        "known_issues":     known_out,
        "meta": {
            "total_lines":  acc["total_lines"],
            "parsed_lines": acc["parsed_lines"],
            "sp_count":     len(sp_sorted),
            "service_pairs": len(topology_out),
            "error_codes":  len(error_out),
        },
    }


# ---------------------------------------------------------------------------
# Generador del 19-performance-baseline.md
# ---------------------------------------------------------------------------

def generate_performance_baseline(results: dict, out_dir: Path):
    sp_freq   = results["sp_frequency"]
    heatmap   = results["hourly_heatmap"]
    meta      = results["meta"]

    # Volumen total por dominio
    domain_totals: dict[str, int] = defaultdict(int)
    for h_data in heatmap.values():
        for dom, cnt in h_data.items():
            domain_totals[dom] += cnt

    # Top 20 SPs
    top20 = sp_freq[:20]

    # Hora pico (mayor volumen total)
    peak_hour = max(
        heatmap.items(),
        key=lambda x: sum(x[1].values()),
        default=("??", {}),
    )

    lines = [
        "# 19 — Performance Baseline · BCOPCore",
        "> **Fuente**: logs de producción del Bus de Servicios — 2026-04-24 (24 horas)",
        "> **Generado por**: analyze-logs.py",
        "> **Nota**: métricas de latencia p50/p95/p99 requieren instrumentación APM — marcadas [APM-PENDING]",
        "",
        "---",
        "",
        "## Volumen de llamadas — 2026-04-24",
        "",
        f"| Métrica | Valor |",
        f"|---------|-------|",
        f"| Total transacciones parseadas | {meta['parsed_lines']:,} |",
        f"| SPs distintos observados en producción | {meta['sp_count']} |",
        f"| Pares sistema×servicio distintos | {meta['service_pairs']} |",
        f"| Hora pico | {peak_hour[0]}:00 CDMX ({sum(peak_hour[1].values()):,} llamadas a Informix) |",
        "",
        "---",
        "",
        "## Patrón horario (llamadas a Informix por hora)",
        "",
        "| Hora CDMX | Volumen total | Dominio más activo |",
        "|-----------|--------------|-------------------|",
    ]

    for h in sorted(heatmap.keys(), key=int):
        h_data = heatmap[h]
        total  = sum(h_data.values())
        if total == 0:
            continue
        top_dom = max(h_data, key=h_data.get)
        lines.append(f"| {int(h):02d}:00 | {total:,} | {top_dom} ({h_data[top_dom]:,}) |")

    lines += [
        "",
        "---",
        "",
        "## Volumen por dominio — total día",
        "",
        "| Dominio | Llamadas totales | % del total |",
        "|---------|-----------------|-------------|",
    ]
    grand_total = sum(domain_totals.values()) or 1
    for dom, cnt in sorted(domain_totals.items(), key=lambda x: -x[1]):
        pct = round(cnt / grand_total * 100, 1)
        lines.append(f"| {dom} | {cnt:,} | {pct}% |")

    lines += [
        "",
        "---",
        "",
        "## Top 20 SPs por volumen de llamadas",
        "",
        "| Rank | SP | Llamadas | Errores | Error% | Dominios |",
        "|------|----|----------|---------|--------|---------|",
    ]
    for i, sp in enumerate(top20, 1):
        doms = ", ".join(sp["domains"]) or "—"
        lines.append(
            f"| {i} | `{sp['sp']}` | {sp['calls']:,} | {sp['errors']:,} | {sp['error_rate']}% | {doms} |"
        )

    lines += [
        "",
        "---",
        "",
        "## Métricas de latencia",
        "",
        "> **[APM-PENDING]** — Los logs del Bus no contienen timestamps de inicio/fin por llamada.",
        "> Para poblar p50/p95/p99 se requiere instrumentación APM (Dynatrace, Datadog, o X-Ray).",
        "> Alternativa: activar `SET DEBUG FILE TO '/tmp/sp_timing.log'` en Informix para los SPs críticos.",
        "",
        "| SP | p50 | p95 | p99 | Umbral de alerta | Estado |",
        "|----|-----|-----|-----|-----------------|--------|",
    ]
    for sp in top20[:10]:
        lines.append(f"| `{sp['sp']}` | [APM-PENDING] | [APM-PENDING] | [APM-PENDING] | [SME-PENDING] | — |")

    lines += [
        "",
        "---",
        "",
        "## Errores silenciosos en producción",
        "",
        "Detectados en errores_bus_* con recurrencia sistemática:",
        "",
        "| Código | Descripción | Volumen/día |",
        "|--------|-------------|-------------|",
    ]
    for ec, data in results["error_catalog"].items():
        if data.get("known_issue"):
            lines.append(f"| {ec} | {data['known_issue']} | {data['count']:,} |")

    lines += [
        "",
        "---",
        "",
        "*Generado automáticamente por analyze-logs.py — 2026-07-31*",
        "*Validar contra código fuente: `source/BCOPCore/informix/{sp_name}.sql`*",
    ]

    out_path = out_dir / "19-performance-baseline-from-logs.md"
    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"  -> {out_path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="BCOPCore Bus Log Analyzer")
    parser.add_argument("--logs-dir",   default="source/logs",      help="Directorio de logs")
    parser.add_argument("--output-dir", default="output/log-analysis", help="Directorio de salida")
    args = parser.parse_args()

    logs_dir = BASE_DIR / args.logs_dir
    out_dir  = BASE_DIR / args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    if not logs_dir.exists():
        print(f"ERROR: logs_dir no encontrado: {logs_dir}")
        sys.exit(1)

    log_files = sorted(logs_dir.glob("*.txt"))
    print(f"Procesando {len(log_files)} archivos en {logs_dir} ...\n")

    acc = make_accumulators()

    for i, path in enumerate(log_files, 1):
        size_mb = path.stat().st_size / 1_048_576
        print(f"  [{i:02d}/{len(log_files)}] {path.name} ({size_mb:.1f} MB)")
        process_file(path, acc)

    print(f"\nTotal líneas: {acc['total_lines']:,} | Parseadas: {acc['parsed_lines']:,}\n")

    results = finalize(acc)

    # Escribe los 4 JSON
    outputs = {
        "sp-frequency.json":     results["sp_frequency"],
        "service-topology.json": results["service_topology"],
        "error-catalog.json":    results["error_catalog"],
        "hourly-heatmap.json":   results["hourly_heatmap"],
        "known-issues.json":     results["known_issues"],
    }
    for fname, data in outputs.items():
        p = out_dir / fname
        p.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"  -> {p}")

    # Genera el baseline de performance
    generate_performance_baseline(results, out_dir)

    # Resumen en consola
    print("\n=== RESUMEN ===")
    print(f"SPs distintos en producción : {results['meta']['sp_count']}")
    print(f"Pares sistema×servicio      : {results['meta']['service_pairs']}")
    print(f"Códigos de error distintos  : {results['meta']['error_codes']}")
    print()
    print("Top 10 SPs por volumen:")
    for sp in results["sp_frequency"][:10]:
        print(f"  {sp['calls']:>8,}  {sp['error_rate']:>5.1f}%  {sp['sp']}")
    print()
    print("Errores silenciosos conocidos:")
    for ec, data in results["known_issues"].items():
        print(f"  [{ec}] {data['count']:,}x  — {data['description']}")


if __name__ == "__main__":
    main()

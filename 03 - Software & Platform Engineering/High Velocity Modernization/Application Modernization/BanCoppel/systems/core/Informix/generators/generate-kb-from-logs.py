"""
generate-kb-from-logs.py — BCOPCore · Análisis exhaustivo de logs → Knowledge Base
Proyecto: BanCoppel BCOPCore · SPE-AM-001
Fuente:   source/logs/ — 48 archivos (transacciones_bus + errores_bus, 2026-04-24)

Para cada dominio con actividad, inserta/actualiza una sección
  <!-- LOG-DATA-BEGIN --> ... <!-- LOG-DATA-END -->
en los doc types: 06-exceptions · 11-batch-processes · 13-external-dependencies
                  19-performance-baseline · 21-observability-runbook

También escribe output/log-analysis/domain-insights.json con la estructura completa.

Uso:
  python generate-kb-from-logs.py [--logs-dir source/logs] [--kb-dir knowledge-base] [--dry-run]
"""

import re
import os
import sys
import json
import argparse
from pathlib import Path
from collections import defaultdict
from datetime import datetime

BASE_DIR = Path(__file__).parent
EVIDENCE_DATE = "2026-04-24"
GEN_DATE      = "2026-08-01"

# ---------------------------------------------------------------------------
# Mapa DSN → dominio
# ---------------------------------------------------------------------------
DSN_TO_DOMAIN = {
    "ifx_bdicnweb":        "D01-bdicnweb",
    "ifx_bdinteg":         "D02-bdinteg",
    "ifx_bdinteg_inyau":   "D02-bdinteg",
    "ifx_bdicred":         "D03-bdicred",
    "ifx_bdicheq":         "D04-bdicheq",
    "ifx_bdicheq_sd":      "D04-bdicheq",
    "ifx_bdisac":          "D05-bdisac",
    "ifx_bdisac_remesas":  "D05-bdisac",
    "ifx_bdisac_inyau":    "D05-bdisac",
    "ifx_bdisolic":        "D06-bdisolic",
    "ifx_bdiaclaracion":   "D07-bdiaclaracion",
    "ifx_bdispei":         "D08-bdispei",
    "ifx_bdimnsj":         "D09-bdimnsj",
    "ifx_bdisuc":          "D10-bdisuc",
    "ifx_bdicobranza":     "D11-bdicobranza",
    "ifx_bdicont":         "D12-bdicont",
    "postg_huellasemps":   "PSQL-huellas",
}

# Mapa de servicio → dominio (fallback cuando no hay DSN en la trama)
SERVICE_TO_DOMAIN = {
    # D02 - Integración
    "CuentaN2":           "D02-bdinteg",
    "CoppelCom":          "D02-bdinteg",
    "Cliente":            "D02-bdinteg",
    "Cliente2":           "D02-bdinteg",
    "Nip":                "D02-bdinteg",
    "CoppelBot":          "D02-bdinteg",
    "PrestamoNominaExpedienteDigital": "D02-bdinteg",  # SFTP portabilidad nómina
    # D03 - Crédito
    "SistemaCredito":     "D03-bdicred",
    "CreditoTDC":         "D03-bdicred",
    "PrestamoPersonal":   "D03-bdicred",
    # D04 - Cheques
    "Cheques":            "D04-bdicheq",
    "Tarjeta":            "D04-bdicheq",
    "SobresDigitales":    "D04-bdicheq",
    # D05 - SAC / Remesas
    "Caja":               "D05-bdisac",
    "Caja2":              "D05-bdisac",
    "Caja3":              "D05-bdisac",
    "CajaCliente":        "D05-bdisac",
    "FabricaPagoServicios": "D05-bdisac",
    "ProdCaptacion":      "D05-bdisac",
    "RetiroSinTarjeta":   "D05-bdisac",
    "ConsultaRemesas":    "D05-bdisac",
    "RemesasAPPRIZA":     "D05-bdisac",
    "RemesasAPPRIZAAutomaticas": "D05-bdisac",
    "RemesasAPPRIZACanalesExternos": "D05-bdisac",
    # D06 - Solicitudes
    "CambioDeInstruccion": "D07-bdiaclaracion",
    # D09 - Mensajería
    "SMSCoppel":          "D09-bdimnsj",
    # D10 - Sucursales
    "AdmonSuC":           "D10-bdisuc",
    # D11 - Cobranza
    "Cobranza":           "D11-bdicobranza",
    # PSQL migrado
    "Huellas442":         "PSQL-huellas",
    "HuellasHC":          "PSQL-huellas",
    # Varios — sin DSN claro
    "SERVICIO":           "UNMAPPED",
}

# Servicios identificados como EXTERNOS (no Informix)
EXTERNAL_SERVICES = {
    "RemesasAPPRIZA":     {"name": "APPRIZA — CFPA", "protocol": "SOAP/HTTPS", "domain": "D05-bdisac"},
    "RemesasAPPRIZAAutomaticas": {"name": "APPRIZA — CFPA (batch)", "protocol": "SOAP/HTTPS", "domain": "D05-bdisac"},
    "RemesasAPPRIZACanalesExternos": {"name": "APPRIZA — Canales Externos", "protocol": "SOAP/HTTPS", "domain": "D05-bdisac"},
    "SMSCoppel":          {"name": "Gateway SMS", "protocol": "HTTPS/SSL", "domain": "D09-bdimnsj"},
    "PrestamoNominaExpedienteDigital": {"name": "SFTP Portabilidad Nómina", "protocol": "SFTP", "domain": "D02-bdinteg"},
    "FabricaPagoServicios": {"name": "Fábrica de Pagos ESB", "protocol": "SOAP/JNI", "domain": "D05-bdisac"},
    "Huellas442":         {"name": "PostgreSQL Huellas (target migrado)", "protocol": "JDBC", "domain": "PSQL-huellas"},
}

# Descripción de códigos de error conocidos
ERROR_DESCRIPTIONS = {
    "4395": "Unhandled exception en plugin IIB — NullPointerException en código Java",
    "3381": "Fallo en lectura de imagen por SFTP — postActualizaImagen Portabilidad",
    "4394": "Unhandled exception en plugin IIB — MbUserException genérica",
    "3743": "Handle Timed-out — timeout en conexión SOAP/JNI con sistema destino",
    "3701": "Error en JNI Call — Axis2Invoker fallo de comunicación SOAP no-SOAP",
    "3165": "SSL socket operation error — fallo en handshake TLS con endpoint externo",
    "6233": "Error sin descripción capturada — revisar logs detallados del ESB",
    "5004": "XML parsing error — trama de respuesta malformada",
    "3170": "Can't find SOAP body — mensaje de entrada sin estructura SOAP válida",
    "3166": "SSL timeout — timeout durante operación TLS con endpoint externo",
    "5714": "No 'Data' element — respuesta sin elemento raíz esperado",
}

# Servicios que representan procesos batch (nombre o patrón en referencia)
BATCH_SERVICE_PATTERNS = [
    "automaticas", "automatico", "batch", "nocturno", "scheduler", "job",
]

# ---------------------------------------------------------------------------
# Regex parsers
# ---------------------------------------------------------------------------
RE_SISTEMA   = re.compile(r"<sistemaOrigen>(.*?)</sistemaOrigen>")
RE_REFERENCIA= re.compile(r"<referencia>(.*?)</referencia>")
RE_SERVICIO  = re.compile(r"<servicio>(.*?)</servicio>")
RE_TRAMA     = re.compile(r"<trama>(.*?)(?:</trama>|$)", re.DOTALL)
RE_ESTATUS   = re.compile(r"<estatus>(.*?)</estatus>")
RE_ERROR_COD = re.compile(r"<codigo>(.*?)</codigo>")
RE_ERROR_DESC= re.compile(r"<descripcion>(.*?)</descripcion>")
RE_HORA      = re.compile(r"Hora:\s*'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})")
RE_DSN_SP    = re.compile(r"(ifx_\w+|postg_\w+)\s+call\s+(?:informix\.)?(\w+)\s*\(", re.IGNORECASE)
RE_SP_NODSP  = re.compile(r"call\s+(?:informix\.)?(\w+)\s*\(", re.IGNORECASE)
RE_RESP_CODE = re.compile(
    r'"(?:codRetorno|codRespuesta|codRet|CodRetorno|cod_retorno)"\s*:\s*"(\d+)"',
    re.IGNORECASE,
)
RE_REF_TIMESTAMP = re.compile(r"_(\d{8}_\d{6})$")  # referencia batch: _20260424_000000


def parse_line(line: str) -> dict:
    m_cdata = re.search(r"<!\[CDATA\[(.*?)]]>", line, re.DOTALL)
    raw = m_cdata.group(1) if m_cdata else line

    sistema  = RE_SISTEMA.search(raw)
    servicio = RE_SERVICIO.search(raw)
    referencia = RE_REFERENCIA.search(raw)
    estatus  = RE_ESTATUS.search(raw)
    trama_m  = RE_TRAMA.search(raw)
    trama    = trama_m.group(1) if trama_m else ""

    sp_name = dsn = domain = None
    m_dsn = RE_DSN_SP.search(trama)
    if m_dsn:
        dsn     = m_dsn.group(1).lower()
        sp_name = m_dsn.group(2)
        domain  = DSN_TO_DOMAIN.get(dsn)
    else:
        m_sp = RE_SP_NODSP.search(trama)
        if m_sp:
            sp_name = m_sp.group(1)

    svc_str = servicio.group(1) if servicio else None
    # Fallback domain from service map
    if not domain and svc_str:
        domain = SERVICE_TO_DOMAIN.get(svc_str)

    hora_m = RE_HORA.search(trama)
    hora   = hora_m.group(1) if hora_m else None

    resp_m = RE_RESP_CODE.search(trama)
    resp_code = resp_m.group(1) if resp_m else None

    ec_m = RE_ERROR_COD.search(raw)
    ed_m = RE_ERROR_DESC.search(raw)
    ref_m = RE_REF_TIMESTAMP.search(referencia.group(1) if referencia else "")

    return {
        "sistema":       sistema.group(1) if sistema else None,
        "servicio":      svc_str,
        "referencia":    referencia.group(1) if referencia else None,
        "ref_ts":        ref_m.group(1) if ref_m else None,
        "estatus":       estatus.group(1) if estatus else "unknown",
        "sp_name":       sp_name,
        "dsn":           dsn,
        "domain":        domain or "UNMAPPED",
        "hora":          hora,
        "resp_code":     resp_code,
        "error_code":    ec_m.group(1) if ec_m else None,
        "error_desc":    ed_m.group(1)[:150] if ed_m else None,
        "trama_snippet": trama[:120],
    }


# ---------------------------------------------------------------------------
# Acumuladores por dominio
# ---------------------------------------------------------------------------

def make_domain_acc():
    return {
        "sp_freq":    defaultdict(lambda: {"calls": 0, "errors": 0, "resp_codes": defaultdict(int)}),
        "error_codes": defaultdict(lambda: {"count": 0, "services": set(), "sps": set(), "descs": []}),
        "services_seen": defaultdict(int),   # servicio → llamadas
        "batch_indicators": [],               # referencia con timestamp fijo
        "hourly": defaultdict(int),           # hora → calls
        "external_hits": defaultdict(int),    # external service name → count
    }


def process_files(logs_dir: Path) -> dict:
    """Procesa todos los archivos de log y devuelve acumuladores por dominio."""
    domain_acc  = defaultdict(make_domain_acc)
    global_meta = {"total_lines": 0, "parsed": 0, "errors_lines": 0}

    log_files = sorted(logs_dir.glob("*.txt"))
    print(f"Procesando {len(log_files)} archivos ...\n")

    for i, path in enumerate(log_files, 1):
        is_error = "errores_bus" in path.name
        size_mb  = path.stat().st_size / 1_048_576
        print(f"  [{i:02d}/{len(log_files)}] {path.name} ({size_mb:.1f} MB)")

        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                global_meta["total_lines"] += 1
                rec = parse_line(line)
                global_meta["parsed"] += 1

                dom  = rec["domain"]
                sp   = rec["sp_name"]
                svc  = rec["servicio"] or "UNKNOWN"
                hora = int(rec["hora"].split(" ")[1].split(":")[0]) if rec["hora"] else -1
                acc  = domain_acc[dom]

                # SP frequency
                if sp:
                    sf = acc["sp_freq"][sp]
                    sf["calls"] += 1
                    if rec["estatus"] == "error" or is_error:
                        sf["errors"] += 1
                    if rec["resp_code"]:
                        sf["resp_codes"][rec["resp_code"]] += 1

                # Services seen
                if svc != "UNKNOWN":
                    acc["services_seen"][svc] += 1

                # Hourly
                if hora >= 0:
                    acc["hourly"][hora] += 1

                # Error catalog (from errores_bus only)
                if is_error and rec["error_code"]:
                    ec = rec["error_code"]
                    ecat = acc["error_codes"][ec]
                    ecat["count"] += 1
                    if svc != "UNKNOWN":
                        ecat["services"].add(svc)
                    if sp:
                        ecat["sps"].add(sp)
                    if len(ecat["descs"]) < 3 and rec["error_desc"]:
                        ecat["descs"].append(rec["error_desc"])
                    if is_error:
                        global_meta["errors_lines"] += 1

                # External service tracking
                if svc in EXTERNAL_SERVICES:
                    acc["external_hits"][svc] += 1

                # Batch detection: referencia with fixed timestamp
                if rec["ref_ts"] and svc:
                    key = f"{svc}|{rec['ref_ts'][:8]}"
                    if key not in [b["key"] for b in acc["batch_indicators"][-50:]]:
                        acc["batch_indicators"].append({
                            "key": key,
                            "servicio": svc,
                            "referencia_sample": rec["referencia"],
                            "hora": hora,
                        })

    print(f"\nTotal: {global_meta['total_lines']:,} líneas | Parseadas: {global_meta['parsed']:,}")
    return domain_acc, global_meta


# ---------------------------------------------------------------------------
# Análisis y serialización
# ---------------------------------------------------------------------------

def analyze_domain(dom: str, acc: dict) -> dict:
    """Produce estadísticas finales por dominio."""
    sp_list = sorted(
        [
            {
                "sp": sp,
                "calls": d["calls"],
                "errors": d["errors"],
                "error_rate": round(d["errors"] / d["calls"] * 100, 2) if d["calls"] else 0,
                "top_resp_codes": dict(sorted(d["resp_codes"].items(), key=lambda x: -x[1])[:5]),
            }
            for sp, d in acc["sp_freq"].items()
        ],
        key=lambda x: -x["calls"],
    )

    total_calls  = sum(x["calls"] for x in sp_list)
    total_errors = sum(x["errors"] for x in sp_list)

    error_list = sorted(
        [
            {
                "code": ec,
                "count": d["count"],
                "description": ERROR_DESCRIPTIONS.get(ec, d["descs"][0][:80] if d["descs"] else "Sin descripción"),
                "services": sorted(d["services"]),
                "sps": sorted(d["sps"]),
            }
            for ec, d in acc["error_codes"].items()
        ],
        key=lambda x: -x["count"],
    )

    batch_jobs = {}
    for b in acc["batch_indicators"]:
        svc = b["servicio"]
        if svc.lower().find("automatica") >= 0 or any(p in svc.lower() for p in BATCH_SERVICE_PATTERNS):
            if svc not in batch_jobs:
                batch_jobs[svc] = {"servicio": svc, "sample_referencia": b["referencia_sample"], "first_hour": b["hora"]}

    # External systems active in this domain
    ext_active = {
        svc: {"info": EXTERNAL_SERVICES[svc], "calls": cnt}
        for svc, cnt in acc["external_hits"].items()
        if cnt > 0
    }

    # Peak hour
    hourly = dict(acc["hourly"])
    peak_hour = max(hourly, key=hourly.get) if hourly else None

    return {
        "domain": dom,
        "total_calls": total_calls,
        "total_errors": total_errors,
        "error_rate_pct": round(total_errors / total_calls * 100, 2) if total_calls else 0,
        "sp_count": len(sp_list),
        "top_sps": sp_list[:30],
        "error_catalog": error_list,
        "batch_jobs": batch_jobs,
        "external_systems": ext_active,
        "hourly": hourly,
        "peak_hour": peak_hour,
        "top_services": sorted(acc["services_seen"].items(), key=lambda x: -x[1])[:15],
    }


# ---------------------------------------------------------------------------
# Generadores de markdown por doc_type
# ---------------------------------------------------------------------------

MARKER_BEGIN = "<!-- LOG-DATA-BEGIN -->"
MARKER_END   = "<!-- LOG-DATA-END -->"


def upsert_section(md_path: Path, section_md: str):
    """Inserta o reemplaza el bloque LOG-DATA en el archivo MD existente."""
    if not md_path.exists():
        return  # solo opera sobre archivos existentes

    original = md_path.read_text(encoding="utf-8")
    new_block = f"\n{MARKER_BEGIN}\n{section_md}\n{MARKER_END}\n"

    if MARKER_BEGIN in original:
        # Reemplaza bloque existente
        pattern = re.compile(
            rf"{re.escape(MARKER_BEGIN)}.*?{re.escape(MARKER_END)}",
            re.DOTALL,
        )
        updated = pattern.sub(new_block.strip(), original)
    else:
        # Agrega al final
        updated = original.rstrip() + "\n" + new_block

    md_path.write_text(updated, encoding="utf-8")


def gen_06_exceptions(d: dict) -> str:
    lines = [
        f"## Hallazgos de producción — Logs {EVIDENCE_DATE}",
        f"> Fuente: `source/logs/errores_bus_{EVIDENCE_DATE}_*.txt` · Incorporado: {GEN_DATE}",
        "",
    ]
    if not d["error_catalog"]:
        lines.append("> Sin errores registrados para este dominio en el período analizado.")
        return "\n".join(lines)

    total_err = sum(e["count"] for e in d["error_catalog"])
    lines += [
        f"**Total errores del dominio:** {total_err:,} · **Códigos distintos:** {len(d['error_catalog'])}",
        "",
        "| Código | Descripción | Volumen/día | Servicios afectados |",
        "|--------|-------------|-------------|---------------------|",
    ]
    for e in d["error_catalog"]:
        svcs = ", ".join(e["services"][:3]) + ("…" if len(e["services"]) > 3 else "")
        lines.append(f"| `{e['code']}` | {e['description'][:60]} | {e['count']:,} | {svcs or '—'} |")

    # SPs con errores en este dominio
    sps_with_err = [sp for sp in d["top_sps"] if sp["errors"] > 0]
    if sps_with_err:
        lines += [
            "",
            "### SPs con mayor tasa de error",
            "",
            "| SP | Llamadas/día | Errores/día | Error% |",
            "|----|-------------|-------------|--------|",
        ]
        for sp in sorted(sps_with_err, key=lambda x: -x["error_rate"])[:10]:
            lines.append(f"| `{sp['sp']}` | {sp['calls']:,} | {sp['errors']:,} | {sp['error_rate']}% |")

    lines += ["", f"*Generado por generate-kb-from-logs.py · {GEN_DATE}*"]
    return "\n".join(lines)


def gen_19_performance(d: dict) -> str:
    lines = [
        f"## Volúmenes de producción confirmados — Logs {EVIDENCE_DATE}",
        f"> Fuente: `source/logs/transacciones_bus_{EVIDENCE_DATE}_*.txt` · Incorporado: {GEN_DATE}",
        "",
        f"**Total llamadas dominio:** {d['total_calls']:,} · "
        f"**Total errores:** {d['total_errors']:,} · "
        f"**Error rate global:** {d['error_rate_pct']}%",
    ]

    if d["peak_hour"] is not None:
        peak_vol = d["hourly"].get(d["peak_hour"], 0)
        lines.append(f"**Hora pico:** {d['peak_hour']:02d}:00 CDMX ({peak_vol:,} llamadas)")

    lines += [
        "",
        "### Top SPs por volumen",
        "",
        "| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |",
        "|----|-------------|-------------|--------|------------------------------|",
    ]
    for sp in d["top_sps"][:20]:
        top_codes = ", ".join(f"`{c}`={n}" for c, n in list(sp["top_resp_codes"].items())[:3]) or "—"
        lines.append(
            f"| `{sp['sp']}` | {sp['calls']:,} | {sp['errors']:,} | {sp['error_rate']}% | {top_codes} |"
        )

    lines += [
        "",
        "### Distribución horaria (llamadas con dominio mapeado)",
        "",
        "| Hora CDMX | Llamadas |",
        "|-----------|----------|",
    ]
    for h in sorted(d["hourly"].keys()):
        lines.append(f"| {h:02d}:00 | {d['hourly'][h]:,} |")

    lines += ["", f"*Generado por generate-kb-from-logs.py · {GEN_DATE}*"]
    return "\n".join(lines)


def gen_11_batch(d: dict) -> str:
    lines = [
        f"## Procesos batch detectados en logs — {EVIDENCE_DATE}",
        f"> Fuente: `source/logs/transacciones_bus_{EVIDENCE_DATE}_*.txt` · Incorporado: {GEN_DATE}",
        "",
    ]
    if not d["batch_jobs"]:
        lines.append("> Sin patrones batch identificados en los logs para este dominio.")
        lines.append("> Indicador: servicios con referencia de timestamp fijo (p. ej. `_20260424_000000`).")
        return "\n".join(lines)

    lines += [
        "| Servicio | Referencia muestra | Hora primer disparo |",
        "|----------|-------------------|---------------------|",
    ]
    for svc, b in d["batch_jobs"].items():
        hora_str = f"{b['first_hour']:02d}:00" if b["first_hour"] >= 0 else "—"
        lines.append(f"| `{svc}` | `{b['sample_referencia'][:60]}` | {hora_str} |")

    lines += ["", f"*Generado por generate-kb-from-logs.py · {GEN_DATE}*"]
    return "\n".join(lines)


def gen_13_external(d: dict) -> str:
    lines = [
        f"## Sistemas externos observados en logs — {EVIDENCE_DATE}",
        f"> Fuente: `source/logs/errores_bus_{EVIDENCE_DATE}_*.txt` · Incorporado: {GEN_DATE}",
        "",
    ]
    if not d["external_systems"]:
        lines.append("> Sin sistemas externos identificados en los logs para este dominio.")
        return "\n".join(lines)

    lines += [
        "| Sistema externo | Protocolo | Llamadas observadas | Notas |",
        "|-----------------|-----------|---------------------|-------|",
    ]
    for svc, info in d["external_systems"].items():
        ext = info["info"]
        lines.append(
            f"| {ext['name']} | {ext['protocol']} | {info['calls']:,} | Servicio ESB: `{svc}` |"
        )

    # Errores de SSL en este dominio — indicador de sistemas externos con problemas
    ssl_errors = [e for e in d["error_catalog"] if e["code"] in ("3165", "3166", "3701", "3743")]
    if ssl_errors:
        lines += [
            "",
            "### Errores de comunicación con externos (SSL / timeout / JNI)",
            "",
            "| Código | Descripción | Volumen/día | Servicios |",
            "|--------|-------------|-------------|-----------|",
        ]
        for e in ssl_errors:
            svcs = ", ".join(e["services"][:3])
            lines.append(f"| `{e['code']}` | {e['description'][:55]} | {e['count']:,} | {svcs or '—'} |")

    lines += ["", f"*Generado por generate-kb-from-logs.py · {GEN_DATE}*"]
    return "\n".join(lines)


def gen_21_runbook(d: dict) -> str:
    lines = [
        f"## Patrones de incidente observados — Logs {EVIDENCE_DATE}",
        f"> Fuente: `source/logs/errores_bus_{EVIDENCE_DATE}_*.txt` · Incorporado: {GEN_DATE}",
        "",
    ]
    if not d["error_catalog"] and d["error_rate_pct"] < 1.0:
        lines.append("> Sin patrones de incidente significativos en el período analizado.")
        return "\n".join(lines)

    # Resumen ejecutivo
    lines += [
        f"**Error rate del dominio:** {d['error_rate_pct']}% "
        f"({'CRÍTICO — revisar' if d['error_rate_pct'] > 10 else 'ELEVADO — monitorear' if d['error_rate_pct'] > 5 else 'Normal'})",
        "",
    ]

    # Top errores con acciones
    ACTION_MAP = {
        "4395": "Verificar NullPointerException en el plugin Java — revisar datos de entrada al SP invocado",
        "3381": "Verificar conectividad SFTP y credenciales del servidor de portabilidad nómina",
        "4394": "Revisar MbUserException en IIB — validar que el SP devuelve el tipo esperado",
        "3743": "Aumentar timeout en configuración del canal ESB — verificar disponibilidad del sistema destino",
        "3701": "Revisar endpoint SOAP — verificar que el WSDL sea accesible y la respuesta sea SOAP válida",
        "3165": "Verificar certificado TLS del endpoint externo — puede estar vencido o no confiable",
        "3166": "Aumentar SSL timeout — verificar latencia del endpoint externo",
        "6233": "Revisar logs detallados del ESB para identificar causa raíz — código sin descripción estándar",
        "5004": "Validar formato XML de la trama enviada — puede haber caracteres especiales no escapados",
    }

    if d["error_catalog"]:
        lines += [
            "### Acciones por código de error",
            "",
            "| Código | Vol/día | Prioridad | Acción inmediata |",
            "|--------|---------|-----------|-----------------|",
        ]
        for e in d["error_catalog"][:8]:
            vol = e["count"]
            prio = "ALTA" if vol > 1000 else "MEDIA" if vol > 100 else "BAJA"
            action = ACTION_MAP.get(e["code"], "Investigar con equipo ESB")
            lines.append(f"| `{e['code']}` | {vol:,} | {prio} | {action[:70]} |")

    # SPs críticos (>5% error rate con alto volumen)
    critical_sps = [sp for sp in d["top_sps"] if sp["error_rate"] > 5 and sp["calls"] > 100]
    if critical_sps:
        lines += [
            "",
            "### SPs críticos para monitoring",
            "",
            "| SP | Llamadas/día | Error% | Alerta sugerida |",
            "|----|-------------|--------|-----------------|",
        ]
        for sp in sorted(critical_sps, key=lambda x: -x["error_rate"])[:8]:
            threshold = max(1.0, sp["error_rate"] * 0.5)
            lines.append(
                f"| `{sp['sp']}` | {sp['calls']:,} | {sp['error_rate']}% "
                f"| Alerta si error_rate > {threshold:.1f}% en 5 min |"
            )

    lines += ["", f"*Generado por generate-kb-from-logs.py · {GEN_DATE}*"]
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------

DOC_TYPE_GENERATORS = {
    "06-exceptions.md":         gen_06_exceptions,
    "19-performance-baseline.md": gen_19_performance,
    "11-batch-processes.md":    gen_11_batch,
    "13-external-dependencies.md": gen_13_external,
    "21-observability-runbook.md": gen_21_runbook,
}

DOM_TO_DB = {
    "D01-bdicnweb":    "D01-bdicnweb",
    "D02-bdinteg":     "D02-bdinteg",
    "D03-bdicred":     "D03-bdicred",
    "D04-bdicheq":     "D04-bdicheq",
    "D05-bdisac":      "D05-bdisac",
    "D06-bdisolic":    "D06-bdisolic",
    "D07-bdiaclaracion": "D07-bdiaclaracion",
    "D08-bdispei":     "D08-bdispei",
    "D09-bdimnsj":     "D09-bdimnsj",
    "D10-bdisuc":      "D10-bdisuc",
    "D11-bdicobranza": "D11-bdicobranza",
    "D12-bdicont":     "D12-bdicont",
}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="BCOPCore KB generator from production logs")
    parser.add_argument("--logs-dir",   default="source/logs",     help="Directorio de logs")
    parser.add_argument("--kb-dir",     default="knowledge-base",  help="Directorio de knowledge-base")
    parser.add_argument("--output-dir", default="output/log-analysis", help="Directorio de salida JSON")
    parser.add_argument("--dry-run",    action="store_true",        help="No escribe archivos KB")
    args = parser.parse_args()

    logs_dir = BASE_DIR / args.logs_dir
    kb_dir   = BASE_DIR / args.kb_dir
    out_dir  = BASE_DIR / args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    if not logs_dir.exists():
        print(f"ERROR: logs_dir no encontrado: {logs_dir}")
        sys.exit(1)

    # 1. Procesar todos los logs
    domain_acc, meta = process_files(logs_dir)

    # 2. Analizar cada dominio
    insights = {}
    for dom, acc in domain_acc.items():
        insights[dom] = analyze_domain(dom, acc)

    # 3. Guardar JSON completo
    def serialize(obj):
        if isinstance(obj, set):
            return sorted(obj)
        raise TypeError(f"Not serializable: {type(obj)}")

    json_path = out_dir / "domain-insights.json"
    json_path.write_text(
        json.dumps(insights, default=serialize, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"\nJSON escrito: {json_path}")

    # 4. Actualizar KB docs
    print("\n=== Actualizando Knowledge Base ===\n")
    updated_count = 0

    for dom, data in sorted(insights.items()):
        if dom in ("UNMAPPED", "PSQL-huellas") or data["total_calls"] < 10:
            continue
        kb_folder_name = DOM_TO_DB.get(dom)
        if not kb_folder_name:
            continue
        kb_path = kb_dir / kb_folder_name
        if not kb_path.exists():
            print(f"  SKIP {dom} — carpeta KB no encontrada: {kb_path}")
            continue

        print(f"  {dom} — {data['total_calls']:,} llamadas · {data['error_rate_pct']}% error")
        for fname, gen_fn in DOC_TYPE_GENERATORS.items():
            md_path = kb_path / fname
            if not md_path.exists():
                print(f"    SKIP {fname} — no existe")
                continue
            section = gen_fn(data)
            if not args.dry_run:
                upsert_section(md_path, section)
                updated_count += 1
            print(f"    {'[DRY]' if args.dry_run else '[OK]'} {fname}")

    # 5. Imprimir resumen
    print(f"\n=== RESUMEN ===")
    print(f"Líneas totales procesadas : {meta['total_lines']:,}")
    print(f"Líneas parseadas          : {meta['parsed']:,}")
    print(f"Archivos KB actualizados  : {updated_count}")
    print()
    print(f"{'Dominio':<22} {'Calls':>10} {'Errors':>8} {'Err%':>6} {'SPs':>5} {'Error codes':>6}")
    print("-" * 68)
    for dom, d in sorted(insights.items(), key=lambda x: -x[1]["total_calls"]):
        if d["total_calls"] < 5:
            continue
        print(f"{dom:<22} {d['total_calls']:>10,} {d['total_errors']:>8,} "
              f"{d['error_rate_pct']:>5.1f}% {d['sp_count']:>5} {len(d['error_catalog']):>6}")

    print()
    print(f"JSON completo: {json_path}")
    print(f"KB actualizada en: {kb_dir}")


if __name__ == "__main__":
    main()

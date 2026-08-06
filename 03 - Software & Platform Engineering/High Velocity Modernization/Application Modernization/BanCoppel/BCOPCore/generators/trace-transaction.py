"""
trace-transaction.py — BCOPCore Transaction Tracer
Proyecto: BanCoppel BCOPCore · SPE-AM-001

Reconstruye el flujo completo de una transacción desde los logs del Bus,
enriquecido con contexto de brain.py.

Uso:
  # Trazar por idTrxGlobal específico:
  python trace-transaction.py --id 714221390566

  # Buscar y comparar una fallida vs exitosa de un servicio:
  python trace-transaction.py --service RemesasAPPRIZAAutomaticas --compare

  # Ver todas las fallidas de un SP:
  python trace-transaction.py --sp sp_app_confirmpayment --errors-only --limit 5

  # Trazar un patrón de error (busca primeras N transacciones que coincidan):
  python trace-transaction.py --service Huellas442 --errors-only --limit 3
"""

import re
import sys
import json
import glob
import argparse
from pathlib import Path
from collections import defaultdict

BASE_DIR = Path(__file__).parent
LOGS_DIR = BASE_DIR / "source" / "logs"

# ── Regex ──────────────────────────────────────────────────────────────────
RE_CDATA  = re.compile(r"<!\[CDATA\[(.*?)]]>", re.DOTALL)
RE_ID     = re.compile(r"<idTrxGlobal>(.*?)</idTrxGlobal>")
RE_SIS    = re.compile(r"<sistemaOrigen>(.*?)</sistemaOrigen>")
RE_REF    = re.compile(r"<referencia>(.*?)</referencia>")
RE_SVC    = re.compile(r"<servicio>(.*?)</servicio>")
RE_TRAMA  = re.compile(r"<trama>(.*?)</trama>", re.DOTALL)
RE_ESTAT  = re.compile(r"<estatus>(.*?)</estatus>")
RE_ECOD   = re.compile(r"<codigo>(.*?)</codigo>")
RE_EDESC  = re.compile(r"<descripcion>(.*?)</descripcion>")
RE_SP     = re.compile(r"call\s+(?:informix\.)?(\w+)\s*\(", re.IGNORECASE)
RE_DSN    = re.compile(r"^(ifx_\w+|postg_\w+)\s+call", re.IGNORECASE)
RE_RESP   = re.compile(
    r'"(?:CodRetorno|codRetorno|codRespuesta|codRet|CodRet)"\s*:\s*"([^"]+)"',
    re.IGNORECASE,
)

DSN_MAP = {
    "ifx_bdicnweb": "D01", "ifx_bdinteg": "D02", "ifx_bdinteg_inyau": "D02",
    "ifx_bdicred": "D03", "ifx_bdicheq": "D04", "ifx_bdisac": "D05",
    "ifx_bdisac_remesas": "D05", "ifx_bdisolic": "D06",
    "ifx_bdiaclaracion": "D07", "ifx_bdispei": "D08", "ifx_bdimnsj": "D09",
    "ifx_bdisuc": "D10", "ifx_bdicobranza": "D11", "ifx_bdicont": "D12",
    "postg_huellasemps": "PSQL",
}


# ── Parser ─────────────────────────────────────────────────────────────────

def parse_entry(line: str, source_file: str) -> dict | None:
    m = RE_CDATA.search(line)
    raw = m.group(1) if m else line

    trx_id  = RE_ID.search(raw)
    svc     = RE_SVC.search(raw)
    sis     = RE_SIS.search(raw)
    ref     = RE_REF.search(raw)
    trama_m = RE_TRAMA.search(raw)
    estat   = RE_ESTAT.search(raw)
    ecod    = RE_ECOD.search(raw)
    edesc   = RE_EDESC.search(raw)

    if not trx_id:
        return None

    trama = trama_m.group(1) if trama_m else ""
    sp_m  = RE_SP.search(trama)
    dsn_m = RE_DSN.search(trama)
    sp    = sp_m.group(1) if sp_m else None
    dsn   = dsn_m.group(1).lower() if dsn_m else None
    domain = DSN_MAP.get(dsn) if dsn else None

    resp_m = RE_RESP.search(trama)
    resp_code = resp_m.group(1) if resp_m else None

    # Extrae hora desde nombre de archivo
    parts = Path(source_file).stem.split("_")
    hour = int(parts[-1]) if parts[-1].isdigit() else -1
    is_error_file = "errores_bus" in source_file

    return {
        "id":          trx_id.group(1).strip(),
        "servicio":    svc.group(1) if svc else None,
        "sistema":     sis.group(1) if sis else None,
        "referencia":  ref.group(1) if ref else None,
        "sp":          sp,
        "dsn":         dsn,
        "domain":      domain,
        "estatus":     estat.group(1) if estat else "?",
        "resp_code":   resp_code,
        "error_code":  ecod.group(1) if ecod else None,
        "error_desc":  edesc.group(1)[:200] if edesc else None,
        "trama_full":  trama,
        "trama_short": trama[:300],
        "hour":        hour,
        "file":        Path(source_file).name,
        "is_error":    is_error_file,
    }


# ── Cargador de logs ────────────────────────────────────────────────────────

def load_logs(filter_fn=None, limit=None) -> list[dict]:
    """Carga todos los logs aplicando un filtro opcional. Retorna lista de entradas."""
    results = []
    for fpath in sorted(LOGS_DIR.glob("*.txt")):
        with open(fpath, encoding="utf-8", errors="replace") as f:
            for line in f:
                if not line.strip():
                    continue
                entry = parse_entry(line, str(fpath))
                if entry and (filter_fn is None or filter_fn(entry)):
                    results.append(entry)
                    if limit and len(results) >= limit:
                        return results
    return results


# ── Brain enrichment ────────────────────────────────────────────────────────

def enrich_with_brain(sp_name: str) -> dict:
    try:
        sys.path.insert(0, str(BASE_DIR / "digital-brain"))
        from brain import BCOPBrain
        b = BCOPBrain()
        sp = b.sp(sp_name) or {}
        callers  = b.callers_of(sp_name)  if sp_name else []
        callees  = b.callees_of(sp_name)  if sp_name else []
        impact   = b.impact_of(sp_name)   if sp_name else []
        journeys = b.journeys(sp_name)    if sp_name else []
        return {
            "db":      sp.get("db"),
            "loc":     sp.get("loc"),
            "fan_in":  sp.get("fan_in"),
            "fan_out": sp.get("fan_out"),
            "callers": [c.get("name") for c in (callers or [])[:5]],
            "callees": [c.get("name") for c in (callees or [])[:5]],
            "impact_count": len(impact) if impact else 0,
            "journeys": [j.get("biz") or j.get("name") for j in (journeys or [])[:3]],
        }
    except Exception as e:
        return {"error": str(e)}


# ── Formateador ─────────────────────────────────────────────────────────────

ESTATUS_ICON = {"success": "OK", "error": "ERR", "?": "???"}

def fmt_entry(e: dict, idx: int) -> str:
    icon   = ESTATUS_ICON.get(e["estatus"], "?")
    sp     = e["sp"] or "(sin SP)"
    domain = f"[{e['domain']}]" if e["domain"] else "[???]"
    svc    = e["servicio"] or "?"
    hour   = f"{e['hour']:02d}:xx" if e["hour"] >= 0 else "??"
    lines  = [f"  {idx:>2}. [{icon}] {hour}  {domain:12}  {sp}  (svc={svc})"]

    if e["resp_code"]:
        lines.append(f"       resp_code = {e['resp_code']}")
    if e["error_code"]:
        lines.append(f"       error_code= {e['error_code']}")
    if e["error_desc"]:
        lines.append(f"       error_desc= {e['error_desc'][:120]}")

    # Muestra trama relevante — omite parámetros intermedios si es muy larga
    trama = e["trama_short"]
    if len(trama) > 150:
        trama = trama[:150] + "..."
    lines.append(f"       trama     = {trama}")
    return "\n".join(lines)


# ── Modo: trace por idTrxGlobal ─────────────────────────────────────────────

def trace_by_id(trx_id: str):
    print(f"\n{'='*68}")
    print(f"TRAZA COMPLETA — idTrxGlobal: {trx_id}")
    print(f"{'='*68}")

    entries = load_logs(filter_fn=lambda e: e["id"] == trx_id)
    if not entries:
        print(f"  No se encontraron entradas para idTrxGlobal={trx_id}")
        return

    # Separa trace entries de error entries (mismo ID puede aparecer en ambos archivos)
    trace_entries  = [e for e in entries if not e["is_error"]]
    error_entries  = [e for e in entries if e["is_error"]]

    print(f"\n  Entradas de transaccion : {len(trace_entries)}")
    print(f"  Entradas de error        : {len(error_entries)}")

    print(f"\n--- FLUJO DE TRANSACCION ---")
    for i, e in enumerate(trace_entries, 1):
        print(fmt_entry(e, i))

    if error_entries:
        print(f"\n--- DETALLE DE ERROR ---")
        for i, e in enumerate(error_entries, 1):
            print(fmt_entry(e, i))

    # Brain enrichment del SP principal
    main_sp = next((e["sp"] for e in trace_entries if e["sp"]), None)
    if main_sp:
        print(f"\n--- CONTEXTO brain.py para '{main_sp}' ---")
        info = enrich_with_brain(main_sp)
        for k, v in info.items():
            print(f"  {k:15} = {v}")


# ── Modo: compare fallida vs exitosa ────────────────────────────────────────

def compare_service(service: str):
    print(f"\n{'='*68}")
    print(f"COMPARACION: fallo vs exito — servicio '{service}'")
    print(f"{'='*68}")

    failed  = load_logs(
        filter_fn=lambda e: (e["servicio"] or "").startswith(service) and e["estatus"] == "error",
        limit=1,
    )
    success = load_logs(
        filter_fn=lambda e: (e["servicio"] or "").startswith(service) and e["estatus"] == "success",
        limit=1,
    )

    def show_full(label: str, entries: list[dict]):
        if not entries:
            print(f"\n  {label}: sin ejemplos encontrados")
            return
        e = entries[0]
        print(f"\n{'_'*60}")
        print(f"  {label}")
        print(f"{'_'*60}")
        print(f"  idTrxGlobal = {e['id']}")
        print(f"  sistema     = {e['sistema']}")
        print(f"  servicio    = {e['servicio']}")
        print(f"  estatus     = {e['estatus']}")
        print(f"  sp          = {e['sp']}")
        print(f"  dominio     = {e['domain'] or '???'}")
        print(f"  hora        = {e['hour']:02d}:xx")
        if e["resp_code"]:
            print(f"  resp_code   = {e['resp_code']}")
        if e["error_code"]:
            print(f"  error_code  = {e['error_code']}")
        if e["error_desc"]:
            print(f"  error_desc  = {e['error_desc'][:150]}")
        print(f"\n  TRAMA COMPLETA:")
        # Muestra trama segmentada por ' || '
        trama = e["trama_full"]
        parts = trama.split(" || ")
        if len(parts) > 1:
            print(f"    LLAMADA  : {parts[0][:200]}")
            print(f"    RESPUESTA: {' || '.join(parts[1:])[:300]}")
        else:
            print(f"    {trama[:300]}")

        # Traza el idTrxGlobal para ver más entradas relacionadas
        related = load_logs(filter_fn=lambda x: x["id"] == e["id"])
        if len(related) > 1:
            print(f"\n  Entradas adicionales con mismo idTrxGlobal ({len(related)} total):")
            for i, r in enumerate(related, 1):
                print(fmt_entry(r, i))

    show_full("FALLO  (estatus=error)", failed)
    show_full("EXITO  (estatus=success)", success)

    # Diferencias clave
    if failed and success:
        f = failed[0]
        s = success[0]
        print(f"\n{'_'*60}")
        print("  DIFERENCIAS CLAVE")
        print(f"{'_'*60}")

        # Extrae parámetros del SP call
        sp_re = re.compile(r"call\s+\w+\s*\((.*)\)", re.DOTALL | re.IGNORECASE)
        f_params = sp_re.search(f["trama_full"])
        s_params = sp_re.search(s["trama_full"])

        if f_params and s_params:
            f_args = [a.strip().strip("'") for a in f_params.group(1).split(",")]
            s_args = [a.strip().strip("'") for a in s_params.group(1).split(",")]
            diffs = [(i, fv, sv) for i, (fv, sv) in enumerate(zip(f_args, s_args)) if fv != sv]
            if diffs:
                print(f"  Parámetros distintos entre fallo y exito:")
                for idx, fv, sv in diffs[:10]:
                    print(f"    param[{idx}]  fallo={fv!r}  exito={sv!r}")
            else:
                print("  Parámetros idénticos — la diferencia está en la respuesta de APPRIZA")

        resp_f = f.get("resp_code", "?")
        resp_s = s.get("resp_code", "?")
        print(f"\n  resp_code fallo={resp_f!r}  exito={resp_s!r}")

        # Brain enrichment
        sp = f["sp"] or s["sp"]
        if sp:
            print(f"\n--- CONTEXTO brain.py para '{sp}' ---")
            info = enrich_with_brain(sp)
            for k, v in info.items():
                print(f"  {k:15} = {v}")


# ── Modo: errores de un SP ──────────────────────────────────────────────────

def show_sp_errors(sp_name: str, limit: int = 5):
    print(f"\n{'='*68}")
    print(f"ERRORES — SP '{sp_name}'  (primeros {limit})")
    print(f"{'='*68}")

    entries = load_logs(
        filter_fn=lambda e: e["sp"] == sp_name and e["estatus"] == "error",
        limit=limit,
    )
    if not entries:
        print("  Sin errores encontrados para este SP")
        return

    for i, e in enumerate(entries, 1):
        print(fmt_entry(e, i))
        print()

    # Distribución horaria de errores para este SP
    hourly = defaultdict(int)
    all_errors = load_logs(
        filter_fn=lambda e: e["sp"] == sp_name and e["estatus"] == "error",
    )
    for e in all_errors:
        hourly[e["hour"]] += 1

    print(f"\n  Total errores en el día: {len(all_errors)}")
    print(f"  Distribución horaria:")
    for h in sorted(hourly):
        bar = "#" * (hourly[h] // 20)
        print(f"    {h:02d}:00  {hourly[h]:>5}  {bar}")

    if sp_name:
        print(f"\n--- CONTEXTO brain.py para '{sp_name}' ---")
        info = enrich_with_brain(sp_name)
        for k, v in info.items():
            print(f"  {k:15} = {v}")


# ── Main ────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description="BCOPCore Transaction Tracer")
    ap.add_argument("--id",          help="idTrxGlobal exacto a trazar")
    ap.add_argument("--service",     help="Nombre (o prefijo) del servicio")
    ap.add_argument("--sp",          help="Nombre del SP a analizar")
    ap.add_argument("--compare",     action="store_true", help="Comparar fallo vs exito")
    ap.add_argument("--errors-only", action="store_true", help="Solo mostrar errores")
    ap.add_argument("--limit",       type=int, default=5, help="Max entradas a mostrar")
    args = ap.parse_args()

    if args.id:
        trace_by_id(args.id)

    elif args.service and args.compare:
        compare_service(args.service)

    elif args.service and args.errors_only:
        entries = load_logs(
            filter_fn=lambda e: (e["servicio"] or "").startswith(args.service)
                                and e["estatus"] == "error",
            limit=args.limit,
        )
        for i, e in enumerate(entries, 1):
            print(fmt_entry(e, i))
            print()

    elif args.sp:
        show_sp_errors(args.sp, limit=args.limit)

    else:
        ap.print_help()


if __name__ == "__main__":
    main()
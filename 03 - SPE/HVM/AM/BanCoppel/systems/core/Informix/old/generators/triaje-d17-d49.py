#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
triaje-d17-d49.py — Triaje regulatorio + riesgo para D17-D49 v1.0
==================================================================
Eleva las reglas D17-D49 en brain.db al mismo nivel de triaje que D01-D16:
  1. Lee reglas D17-D49 desde brain.db (id=NULL, ~24,899 reglas)
  2. Aplica inferencia de reg (refs regulatorias por dominio + patrones de código)
  3. Aplica inferencia de riesgo (MONEY/ROUND/DIV/IVA/DBACCESS desde el código)
  4. Genera IDs BR-V3-NNNN y los escribe en brain.db
  5. Exporta las reglas a business-rules-v3.json con schema completo
  6. Actualiza brain.db con reg + riesgo + id definitivos
  7. Stats de cobertura final

SPE-AM-001 · BCOPBrain · 2026-08-12
"""

import json
import re
import sqlite3
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
V3   = BASE / "portal" / "data" / "business-rules-v3.json"
DB   = BASE / "digital-brain" / "brain.db"

# ── Dominio → label, categoria, refs regulatorias default ─────────────────────

_DOMINIO_LABEL: dict[str, str] = {
    'D17': 'D17 BPI',
    'D18': 'D18 Intercard BPI',
    'D19': 'D19 Tarjetas',
    'D20': 'D20 Programas',
    'D21': 'D21 Domiciliación',
    'D22': 'D22 Transferencias',
    'D23': 'D23 MIS',
    'D24': 'D24 Buró de Crédito',
    'D25': 'D25 Sitio Especial',
    'D26': 'D26 Prospectos',
    'D27': 'D27 Auditoría',
    'D28': 'D28 Inversiones',
    'D29': 'D29 Estados de Cuenta Electrónicos',
    'D30': 'D30 Tarjetas Coppel',
    'D31': 'D31 Control de Cheques',
    'D32': 'D32 Reports',
    'D33': 'D33 Monitor de Cobranza',
    'D34': 'D34 RESP',
    'D35': 'D35 Digital',
    'D36': 'D36 Repaut',
    'D37': 'D37 Administración Nómina',
    'D38': 'D38 CPL Bot',
    'D39': 'D39 Servicios',
    'D40': 'D40 BI',
    'D41': 'D41 Corresponsalía',
    'D42': 'D42 IVR',
    'D43': 'D43 Transferencias Presenciales',
    'D44': 'D44 RECH',
    'D45': 'D45 PREM',
    'D46': 'D46 OFI',
    'D47': 'D47 Garantías',
    'D48': 'D48 Riesgos',
    'D49': 'D49 RST',
}

_CATEGORIA: dict[str, str] = {
    'D17': 'BANCA_DIGITAL',   'D18': 'TARJETAS',
    'D19': 'TARJETAS',        'D20': 'OPERACIONAL',
    'D21': 'PAGOS_TRANSFERENCIAS', 'D22': 'PAGOS_TRANSFERENCIAS',
    'D23': 'REPORTERIA',      'D24': 'CREDITO',
    'D25': 'OPERACIONAL',     'D26': 'CREDITO',
    'D27': 'CUMPLIMIENTO',    'D28': 'INVERSIONES',
    'D29': 'ATENCION_CLIENTE','D30': 'TARJETAS',
    'D31': 'PAGOS_TRANSFERENCIAS', 'D32': 'REPORTERIA',
    'D33': 'COBRANZA',        'D34': 'OPERACIONAL',
    'D35': 'BANCA_DIGITAL',   'D36': 'OPERACIONAL',
    'D37': 'NOMINA',          'D38': 'BANCA_DIGITAL',
    'D39': 'OPERACIONAL',     'D40': 'REPORTERIA',
    'D41': 'OPERACIONAL',     'D42': 'ATENCION_CLIENTE',
    'D43': 'PAGOS_TRANSFERENCIAS', 'D44': 'COBRANZA',
    'D45': 'OPERACIONAL',     'D46': 'OPERACIONAL',
    'D47': 'CREDITO',         'D48': 'CUMPLIMIENTO',
    'D49': 'OPERACIONAL',
}

# Refs regulatorias default por dominio (se aplican a TODAS las reglas del dominio)
_REG_DOMAIN_DEFAULT: dict[str, list] = {
    'D17': [["CNBV", "Disposiciones Únicas de Bancos — banca electrónica institucional (BEI) y autenticación fuerte"]],
    'D18': [["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito/débito + banca electrónica"],
            ["VISA/MC", "Visa/Mastercard Issuer Rules — tarjeta bancaria BPI"]],
    'D19': [["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"]],
    'D20': [["LIC", "Art. 78 LIC — conservación de registros contables y operativos 5 años"]],
    'D21': [["BANXICO", "Circular 25/2014 Banxico — domiciliación y cargos automáticos a cuenta bancaria"]],
    'D22': [["BANXICO", "Reglas SPEI/CECOBAN — transferencias electrónicas de fondos (Art. 42 LSNSP)"]],
    'D23': [["LIC", "Art. 78 LIC — conservación de información de gestión (MIS/reporting)"]],
    'D24': [["CNBV", "LRSIC — consultas a Sociedad de Información Crediticia (Buró de Crédito)"],
            ["LFPDPPP", "LFPDPPP — tratamiento de datos personales crediticios con consentimiento"]],
    'D25': [["LIC", "Art. 78 LIC — conservación de información operativa especial"]],
    'D26': [["CNBV", "Disposiciones Únicas de Bancos — apertura y gestión de cuentas (prospectos de crédito)"]],
    'D27': [["CNBV", "Art. 78 LIC — conservación de bitácoras de auditoría interna 5 años"],
            ["GAFI", "FATF Rec. 10/11 — debida diligencia del cliente y monitoreo de transacciones"]],
    'D28': [["CNBV", "Disposiciones Únicas de Bancos — operaciones de inversión, reporto y mesa de dinero"]],
    'D29': [["CNBV", "Disposiciones Únicas de Bancos — estados de cuenta electrónicos y notificación (Art. 72 CUB)"]],
    'D30': [["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"],
            ["VISA/MC", "Visa/Mastercard Issuer Rules — Tarjetas Coppel"]],
    'D31': [["BANXICO", "Reglas Banxico — cheques, cámaras de compensación CECOBAN y sistema de pagos"]],
    'D32': [["LIC", "Art. 78 LIC — conservación de reportes regulatorios y operativos 5 años"]],
    'D33': [["CONDUSEF", "CONDUSEF — procedimientos de cobranza y protección al usuario de servicios financieros"]],
    'D34': [["LIC", "Art. 78 LIC — conservación de información de respaldo y recuperación operativa"]],
    'D35': [["CNBV", "Disposiciones Únicas de Bancos — banca digital, canales electrónicos y autenticación"]],
    'D36': [["LIC", "Art. 78 LIC — conservación de reportes automatizados de operaciones"]],
    'D37': [["IMSS", "IMSS/SAT — obligaciones patronales de nómina, CFDI nómina y SUA (cálculo correcto)"]],
    'D38': [["LIC", "Art. 78 LIC — conservación de logs de bots y comunicaciones automatizadas"]],
    'D39': [["LIC", "Art. 78 LIC — conservación de registros de servicios bancarios internos"]],
    'D40': [["LIC", "Art. 78 LIC — conservación de información de business intelligence y reporting"]],
    'D41': [["CNBV", "Disposiciones Únicas de Bancos — corresponsalías bancarias (Capítulo X CUB)"]],
    'D42': [["CNBV", "Disposiciones Únicas de Bancos — banca telefónica y canales de voz IVR (Art. 49 CUB)"]],
    'D43': [["BANXICO", "Reglas SPEI/CECOBAN — transferencias interbancarias presenciales (ventanilla)"]],
    'D44': [["CONDUSEF", "CONDUSEF — procedimientos de recuperación de cartera y cobranza extrajudicial"]],
    'D45': [["LIC", "Art. 78 LIC — conservación de información de premios, promociones y campañas"]],
    'D46': [["LIC", "Art. 78 LIC — conservación de registros de operaciones en oficina"]],
    'D47': [["CNBV", "Disposiciones Únicas de Bancos — garantías en operaciones de crédito (Circular B-6)"]],
    'D48': [["CNBV", "Disposiciones Únicas de Bancos — gestión integral de riesgos operativos y de mercado (Circular B-5)"]],
    'D49': [["LIC", "Art. 78 LIC — conservación de información de reportes y resúmenes de transacciones"]],
}

# ── Refs adicionales por patrón de código (cross-dominio) ─────────────────────

_SAT_IVA   = ["SAT", "LIVA Art. 1 — tasa IVA 16% aplicable a comisiones y servicios financieros"]
_CNBV_PLD  = ["CNBV", "CNBV PLD/FT — Disposiciones en materia de Prevención de Lavado de Dinero (Circular 4/2019)"]
_BANXICO_S = ["BANXICO", "Reglas SPEI/CECOBAN — transferencias electrónicas de fondos (Art. 42 LSNSP)"]
_CNBV_ART78= ["CNBV", "Art. 78 LIC — conservación de información 5 años (bitácoras y movimientos)"]
_CONDUSEF  = ["CONDUSEF", "CONDUSEF — protección al usuario de servicios financieros"]
_CNBV_TDC  = ["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"]

# ── Riesgos canónicos ─────────────────────────────────────────────────────────

_RIESGO_MONEY    = "MONEY — banker's rounding Informix; NUMERIC PostgreSQL diverge"
_RIESGO_ROUND    = "ROUND — validar modo (banker's vs half-up)"
_RIESGO_DIV      = "DIV — división monetaria puede perder centavos; usar DECIMAL(18,4)"
_RIESGO_IVA      = "IVA — cálculo 16% sobre base; verificar base imponible y redondeo"
_RIESGO_DBACCESS = "DBACCESS — ejecución SQL externa vía shell; paths AIX (/resplogifx/, /tmp/) muertos en target AWS/PostgreSQL"

# ── Mapa tipo brain.db → tipo v3.json ─────────────────────────────────────────

_TIPO_MAP = {
    'VALIDACION': 'VALIDACIÓN',
    'EXCEPCION':  'EXCEPCIÓN',
    'LOGICA':     'LÓGICA',
    'FORMULA':    'FÓRMULA',
    # ya correctos
    'VALIDACIÓN': 'VALIDACIÓN',
    'EXCEPCIÓN':  'EXCEPCIÓN',
    'LÓGICA':     'LÓGICA',
    'FÓRMULA':    'FÓRMULA',
}

# ── Inferencia de reg ─────────────────────────────────────────────────────────

def infer_reg(domain: str, sp: str, code: str) -> list[list[str]]:
    """Refs regulatorias para un dominio D17-D49."""
    refs: list[list[str]] = list(_REG_DOMAIN_DEFAULT.get(domain, []))
    already = {r[0] for r in refs}
    c = code.lower()
    s = sp.lower()

    # Patrones de código que añaden refs adicionales
    if any(t in c for t in ("viva", "miva", " iva", "iva_")):
        if "SAT" not in already:
            refs.append(_SAT_IVA)
            already.add("SAT")
    if any(t in c or t in s for t in ("pld", "lavado", "sospechosa", "inusual")):
        if "CNBV" not in already or not any("PLD" in r[1] for r in refs):
            refs.append(_CNBV_PLD)
    if any(t in c for t in ("spei", "cecoban", "clave_rastreo", "siac")):
        if "BANXICO" not in already:
            refs.append(_BANXICO_S)
            already.add("BANXICO")
    if any(t in c or t in s for t in ("bitacora", "logifx", "bdiauditor", "auditoria")):
        if not any("Art. 78" in r[1] for r in refs):
            refs.append(_CNBV_ART78)
    if any(t in s for t in ("tarjeta", "_tc_", "_td_", "tarjetah", "intercard")):
        if not any("CUB" in r[1] for r in refs):
            refs.append(_CNBV_TDC)
    if any(t in c or t in s for t in ("queja", "reclamacion", "aclaracion", "adeudo")):
        if "CONDUSEF" not in already:
            refs.append(_CONDUSEF)

    return refs


# ── Inferencia de riesgo ──────────────────────────────────────────────────────

def infer_riesgo(code: str, domain: str) -> list[str]:
    """Tags de riesgo para reglas de ANY tipo (no solo FÓRMULA)."""
    c = code.lower()
    tags: list[str] = []

    if "::money" in c or re.search(r'\bmoney\b', c):
        tags.append(_RIESGO_MONEY)
    if re.search(r'\b(round|trunc)\s*\(', c) and _RIESGO_MONEY not in tags:
        tags.append(_RIESGO_ROUND)
    if re.search(r'/\s*\(?\s*(1\s*\+|vmontotot|viva|miva|valorc|itiva)', c):
        tags.append(_RIESGO_DIV)
    if re.search(r'\*\s*(viva|miva|mivac|iva)', c):
        tags.append(_RIESGO_IVA)

    # DBACCESS — shell SQL execution con paths AIX
    if ("dbaccess" in c or "/resplogifx/" in code
            or "unload to" in c or re.search(r"vsql\s*=", c)):
        tags.append(_RIESGO_DBACCESS)

    # Patrones MONEY en condiciones IF (monto/saldo/importe/capital en comparaciones)
    if not tags and re.search(
        r'\b(monto|saldo|importe|capital|deuda|comision|interes|cargo|abono|pago)\s*(>|<|=|<>|!=)',
        c
    ):
        tags.append(_RIESGO_MONEY)

    return tags


# ── business_name mejorado para D17-D49 ───────────────────────────────────────

def build_business_name(tipo: str, sp: str, code: str) -> str:
    """Genera business_name más descriptivo que el original 'tipo: code[:60]'."""
    tipo_n = tipo.upper().replace('Ó', 'O').replace('É', 'E')
    c = code.strip()[:120]
    # Para EXCEPCION — mostrar código de error si existe
    if "EXCEP" in tipo_n:
        m = re.search(r'\((-?\d+)', code)
        if m:
            return f"Maneja excepción código {m.group(1)}"
        return f"Manejo de excepción: {c[:80]}"
    # Para VALIDACION — extraer la condición central
    if "VALID" in tipo_n or "LOGIC" in tipo_n:
        cond = re.sub(r'\bIF\b\s*', '', code, flags=re.I).strip()
        cond = re.sub(r'\s+THEN\s*$', '', cond, flags=re.I).strip()
        if cond:
            return f"Valida: {cond[:100]}"
    return f"{tipo.lower()}: {c[:80]}"


# ── Traducir tipo brain → tipo v3.json ────────────────────────────────────────

def map_tipo(t: str) -> str:
    return _TIPO_MAP.get(t.upper(), t)


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    print("=" * 64)
    print("triaje-d17-d49.py — Triaje regulatorio D17-D49 v1.0")
    print("=" * 64)

    # 1. Leer v3.json
    v3_data  = json.loads(V3.read_text(encoding="utf-8"))
    v3_rules = v3_data["rules"]
    max_seq  = 0
    for r in v3_rules:
        rid = r.get("id", "")
        m = re.search(r'V(\d+)-(\d+)$', rid)
        if m:
            max_seq = max(max_seq, int(m.group(2)))
    print(f"  v3.json actual: {len(v3_rules)} reglas (último seq={max_seq})")

    # 2. Leer D17-D49 de brain.db
    con = sqlite3.connect(DB)
    cur = con.cursor()
    rows = cur.execute("""
        SELECT rowid, tipo, sp, db, domain, line, code, reg, riesgo, business_name
        FROM rules
        WHERE id IS NULL
        ORDER BY domain, db, sp, line
    """).fetchall()
    print(f"  brain.db D17-D49 sin id: {len(rows)} reglas")

    # 3. Procesar y construir nuevas entradas v3
    new_v3_entries: list[dict] = []
    updates: list[tuple] = []   # (new_id, new_reg, new_riesgo, new_bn, rowid)
    seq = max_seq

    domain_stats: dict[str, dict] = {}

    for (rowid, tipo, sp, db, domain, line, code, reg_raw, riesgo_raw, bn_old) in rows:
        domain_key = domain or "UNK"
        if domain_key not in domain_stats:
            domain_stats[domain_key] = {'n': 0, 'reg': 0, 'riesgo': 0}

        seq += 1
        new_id = f"BR-V3-{seq:05d}"

        # Aplicar triaje
        new_reg    = infer_reg(domain_key, sp or "", code or "")
        new_riesgo = infer_riesgo(code or "", domain_key)
        new_bn     = build_business_name(tipo or "", sp or "", code or "")

        domain_stats[domain_key]['n'] += 1
        if new_reg:    domain_stats[domain_key]['reg'] += 1
        if new_riesgo: domain_stats[domain_key]['riesgo'] += 1

        # Formatear entrada v3.json
        dominio_label = _DOMINIO_LABEL.get(domain_key, domain_key)
        categoria     = _CATEGORIA.get(domain_key, 'OPERACIONAL')
        sp_clean      = sp or ""
        tipo_v3       = map_tipo(tipo or "LOGICA")

        entry = {
            "id":           new_id,
            "tipo":         tipo_v3,
            "sp":           sp_clean,
            "db":           db or "",
            "line":         line or 0,
            "code":         code or "",
            "reg":          new_reg,
            "riesgo":       new_riesgo,
            "bc":           "",
            "bc_name":      "",
            "business_name": new_bn,
            "categoria":    categoria,
            "explicacion":  new_bn,
            "expl_conf":    "infer-d17-d49",
            "dominio":      dominio_label,
            "sp_rel":       {"callees": [], "callers": []},
            "vocab_detail": [],
            "vocab_refs":   [],
        }
        new_v3_entries.append(entry)
        updates.append((new_id,
                        json.dumps(new_reg,    ensure_ascii=False),
                        json.dumps(new_riesgo, ensure_ascii=False),
                        new_bn,
                        rowid))

    print(f"\n  Nuevas entradas generadas: {len(new_v3_entries)}")

    # 4. Actualizar brain.db (id + reg + riesgo + business_name)
    print("\n-- Actualizando brain.db --")
    cur.executemany(
        "UPDATE rules SET id=?, reg=?, riesgo=?, business_name=? WHERE rowid=?",
        updates
    )
    con.commit()
    con.close()
    print(f"  {len(updates)} reglas actualizadas con id + reg + riesgo")

    # 5. Append a v3.json
    print("\n-- Actualizando v3.json --")
    v3_rules.extend(new_v3_entries)
    v3_data["meta"]["total_rules"] = len(v3_rules)
    V3.write_text(json.dumps(v3_data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"  v3.json: {len(v3_rules)} reglas (era {len(v3_rules)-len(new_v3_entries)})")

    # 6. Stats por dominio
    print("\n-- Cobertura por dominio --")
    total_n = total_r = total_ri = 0
    for dom in sorted(domain_stats):
        s = domain_stats[dom]
        pct_r  = s['reg']   * 100 // s['n'] if s['n'] else 0
        pct_ri = s['riesgo']* 100 // s['n'] if s['n'] else 0
        label  = _DOMINIO_LABEL.get(dom, dom)
        print(f"  {label:<40} {s['n']:>5} reglas | reg={s['reg']:>5} ({pct_r:>3}%) | riesgo={s['riesgo']:>5} ({pct_ri:>3}%)")
        total_n  += s['n'];  total_r += s['reg'];  total_ri += s['riesgo']

    print(f"\n  TOTAL D17-D49: {total_n} | reg={total_r} ({total_r*100//total_n if total_n else 0}%) | riesgo={total_ri} ({total_ri*100//total_n if total_n else 0}%)")
    print(f"\n  Siguiente paso: python generators/gen-rules-portal.py")
    print("Done.")


if __name__ == "__main__":
    main()
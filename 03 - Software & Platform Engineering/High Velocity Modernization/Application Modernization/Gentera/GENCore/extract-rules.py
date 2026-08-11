#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules.py — Extrae reglas de negocio desde fuentes ABAP en GENCore/source/
Emite rules-gentera.json (input para build-brain.py).

Tipos de reglas extraídas:
  VALIDACION    — IF/CHECK que validan inputs o estado del sistema
  FLUJO         — IF que bifurcan la lógica de negocio (cache vs BD, etc.)
  MANEJO_ERROR  — CATCH, MESSAGE tipo E/A, RAISE EXCEPTION
  CALCULO       — Asignaciones con operaciones financieras/matemáticas relevantes
  REGULATORIO   — Referencias a CNBV, IFRS, SAT, CONDUSEF, PLD, Banxico
  AUTORIZACION  — AUTHORITY-CHECK, control de acceso SAP

Uso: python GENCore/extract-rules.py
     (ejecutar desde GENCore/ o desde Gentera/)

Etapa 3 · GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""

import json
import re
import sys
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

BASE   = Path(__file__).parent
SOURCE = BASE / 'source'
OUT    = BASE / 'rules-gentera.json'

# ── Señales regulatorias ──────────────────────────────────────────────────────

REG_PATTERNS = [
    (re.compile(r'\b(cnbv|circular\s+\d+|portafolio|cartera\s+regulat)', re.I), 'CNBV'),
    (re.compile(r'\b(ifrs|niif|nif\b|niif_?[0-9])', re.I),                      'IFRS'),
    (re.compile(r'\b(sat\b|isr\b|iva\b|factura|cfdi|rfc\b)',    re.I),           'SAT'),
    (re.compile(r'\b(condusef|queja|reclamo|reclamacion)',       re.I),           'CONDUSEF'),
    (re.compile(r'\b(pld\b|lavado|delito|operacion_?sospechosa|lfpiorpi)', re.I),'PLD'),
    (re.compile(r'\b(banxico|spei|siac|codi\b)',                 re.I),           'BANXICO'),
    (re.compile(r'\b(ipab\b|seguro_?de_?deposito)',              re.I),           'IPAB'),
    (re.compile(r'\b(sofom|sofipo|cnbv|comision_?nacional)',     re.I),           'CNBV'),
]

# ── Señales de riesgo de equivalencia ─────────────────────────────────────────

RISK_HIGH = re.compile(
    r'\b(monto|saldo|importe|interes|tasa|comision|amortiza|pago|cargo|abono|'
    r'capital|deuda|mora|penaliz|cuota|plazo|interés|comisión|redondeo|'
    r'round|truncat|ceil|floor|decima|division|dividir|multiplic)',
    re.I
)
RISK_MED  = re.compile(
    r'\b(fecha|dia|mes|año|plazo|vencim|vigencia|ciclo|periodo|'
    r'estatus|estado|activo|inactivo|bloqueado|cancelado)',
    re.I
)

# ── Patrones de extracción ────────────────────────────────────────────────────

# IF condition
RE_IF   = re.compile(r'^\s{2,}IF\s+(.+?)(?:\s*\.\s*$|\s*$)', re.I | re.M)
# ELSEIF
RE_ELIF = re.compile(r'^\s{2,}ELSEIF\s+(.+?)(?:\s*\.\s*$|\s*$)', re.I | re.M)
# CHECK
RE_CHECK= re.compile(r'^\s{2,}CHECK\s+(.+?)(?:\s*\.\s*$|\s*$)', re.I | re.M)
# CASE / WHEN
RE_CASE = re.compile(r'^\s{2,}(?:CASE\s+(\S+))', re.I | re.M)
RE_WHEN = re.compile(r"^\s{4,}WHEN\s+(['\"/\w]+)", re.I | re.M)
# MESSAGE tipo E o A (errores de negocio)
RE_MSG_E= re.compile(r"^\s{2,}MESSAGE\s+(\S+)\s+(?:TYPE|INTO|RAISING)?\s*['\"]([EAX])['\"]", re.I | re.M)
# MESSAGE ...INTO sy-msgli (comunes en el codebase Gentera)
RE_MSG_SY= re.compile(r"^\s{2,}MESSAGE\s+(\S+)\s+(?:INTO|WITH)\s+", re.I | re.M)
# RAISE EXCEPTION TYPE
RE_RAISE= re.compile(r'^\s{2,}RAISE\s+EXCEPTION\s+TYPE\s+(\S+)', re.I | re.M)
# CATCH
RE_CATCH= re.compile(r'^\s{2,}CATCH\s+((?:/?\w+/?\w+\s*)+)', re.I | re.M)
# AUTHORITY-CHECK
RE_AUTH = re.compile(r'^\s{2,}AUTHORITY-CHECK\s+OBJECT\s+[\'"]?(\w+)[\'"]?', re.I | re.M)
# WHERE clause (SELECT filtros)
RE_WHERE= re.compile(r'^\s{4,}WHERE\s+(.+?)(?:\s*\.\s*$|\s*$)', re.I | re.M)
# UPDATE ... SET
RE_UPD  = re.compile(r'^\s{2,}UPDATE\s+(\w+)\s+SET\s+(.+?)(?:\s*$)', re.I | re.M)
# METHOD ... ENDMETHOD (para saber en qué método estamos)
RE_MTH  = re.compile(r'^\s*METHOD\s+(\S+)', re.I | re.M)
RE_EMTH = re.compile(r'^\s*ENDMETHOD', re.I | re.M)


def detect_reg(text: str) -> str | None:
    for pat, tag in REG_PATTERNS:
        if pat.search(text):
            return tag
    return None


def detect_risk(condicion: str) -> str:
    if RISK_HIGH.search(condicion):
        return 'ALTO'
    if RISK_MED.search(condicion):
        return 'MEDIO'
    return 'BAJO'


def humanize(cond: str, tipo: str, metodo: str) -> str:
    """Genera business_name legible desde la condición técnica."""
    c = cond.strip().rstrip('.')

    # Patrones comunes de ABAP
    if re.search(r'IS\s+INITIAL', c, re.I):
        var = re.sub(r'\s+IS\s+INITIAL.*', '', c, flags=re.I).strip()
        var = _clean_var(var)
        return f"{var} es requerido (no puede estar vacío)"
    if re.search(r'IS\s+NOT\s+INITIAL', c, re.I):
        var = re.sub(r'\s+IS\s+NOT\s+INITIAL.*', '', c, flags=re.I).strip()
        var = _clean_var(var)
        return f"Solo procesa si {var} tiene valor"
    if re.search(r'IS\s+BOUND', c, re.I):
        var = re.sub(r'\s+IS\s+(NOT\s+)?BOUND.*', '', c, flags=re.I).strip()
        return f"Patrón singleton: crea instancia de {_clean_var(var)} solo si no existe"
    if re.search(r'sy-subrc\s+(NE|<>)\s+0', c, re.I):
        return "Error si la operación anterior no encontró registros (sy-subrc ≠ 0)"
    if re.search(r'NOT\s+sy-subrc\s+IS\s+INITIAL', c, re.I):
        return "Error si la operación anterior no encontró registros"
    if re.search(r'sy-subrc\s+=\s+0', c, re.I):
        return "Éxito si la operación anterior encontró registros"
    if re.search(r'cx_sy_itab_line_not_found', c, re.I):
        return "Línea no encontrada en tabla interna — maneja búsqueda fallida"
    if re.search(r'cx_db_not_found|cx_\w*_not_found', c, re.I):
        return "Registro no encontrado en base de datos — excepción de negocio"

    # Fallback: usar el nombre del método como contexto
    m_clean = metodo.lower().replace('_', ' ')
    return f"Condición en {m_clean}: {c[:80]}"


def _clean_var(v: str) -> str:
    """Quita prefijos húngaros ABAP: lv_, gv_, lt_, gt_, ls_, gs_, iv_, rv_."""
    v = v.strip().lstrip('!')
    m = re.match(r'^[ilegrc][tvsorwcoxng]_(.+)', v.lower())
    if m:
        return m.group(1).replace('_', ' ')
    return v.lower().replace('_', ' ')


def _parse_methods(text: str) -> list[tuple[int, int, str]]:
    """Retorna lista de (start_line, end_line, method_name) dentro del texto."""
    lines = text.splitlines()
    methods: list[tuple[int, int, str]] = []
    current: tuple[int, str] | None = None

    for i, line in enumerate(lines, start=1):
        mth_m = RE_MTH.match(line)
        if mth_m:
            current = (i, mth_m.group(1).upper())
        elif RE_EMTH.match(line) and current:
            methods.append((current[0], i, current[1]))
            current = None

    return methods


def _method_at(lineno: int, method_ranges: list[tuple[int, int, str]]) -> str:
    for start, end, name in method_ranges:
        if start <= lineno <= end:
            return name
    return 'UNKNOWN'


def extract_rules_from_file(path: Path) -> list[dict]:
    """Extrae reglas de negocio de un archivo .abap."""
    text = path.read_text(encoding='utf-8', errors='replace')
    lines = text.splitlines()

    # Detectar objeto
    obj_id = _detect_obj_id(text, path.stem)
    method_ranges = _parse_methods(text)

    rules: list[dict] = []
    seq = [0]

    def add(lineno: int, tipo: str, condicion: str, fuente: str = 'CODE'):
        metodo = _method_at(lineno, method_ranges)
        reg    = detect_reg(condicion)
        riesgo = detect_risk(condicion)
        bname  = humanize(condicion, tipo, metodo)
        seq[0] += 1
        rules.append({
            'id'           : f'GENREG-{seq[0]:04d}',
            'obj_id'       : obj_id,
            'metodo'       : metodo,
            'linea'        : lineno,
            'tipo'         : tipo,
            'condicion'    : condicion.strip()[:300],
            'business_name': bname,
            'reg'          : reg,
            'riesgo'       : riesgo,
            'fuente'       : fuente,
        })

    seen: set[str] = set()

    def maybe_add(lineno: int, tipo: str, cond: str, fuente: str = 'CODE'):
        key = (lineno, cond[:60])
        if key not in seen:
            seen.add(key)
            add(lineno, tipo, cond, fuente)

    # Recorrer línea por línea para tener número de línea exacto
    for i, line in enumerate(lines, start=1):
        stripped = line.strip()
        upper    = stripped.upper()

        # IF / ELSEIF
        if m := re.match(r'^\s{1,}(?:ELSEIF|IF)\s+(.+?)\.?\s*$', line, re.I):
            cond = m.group(1).strip()
            tipo = 'FLUJO' if re.search(
                r'(gt_tvarvc_inst|cache|IS\s+BOUND|og_instance)', cond, re.I
            ) else 'VALIDACION'
            maybe_add(i, tipo, cond)

        # CHECK
        elif m := re.match(r'^\s{1,}CHECK\s+(.+?)\.?\s*$', line, re.I):
            maybe_add(i, 'VALIDACION', m.group(1).strip())

        # AUTHORITY-CHECK
        elif m := re.match(r"^\s{1,}AUTHORITY-CHECK\s+OBJECT\s+['\"]?(\w+)['\"]?", line, re.I):
            maybe_add(i, 'AUTORIZACION', f"AUTHORITY-CHECK OBJECT {m.group(1)}")

        # MESSAGE tipo E/A/X (errores bloqueantes)
        elif m := re.match(r"^\s{1,}MESSAGE\s+(\S+)(?:\s+(?:TYPE\s+)?['\"]([EAX])['\"])?", line, re.I):
            msg_id  = m.group(1)
            msg_typ = m.group(2) or 'E'
            cond    = f"MESSAGE {msg_id} TYPE '{msg_typ}'"
            # Solo capturar errores/abort (no info S)
            if msg_typ.upper() in ('E', 'A', 'X') or 'msg_ifrs' in msg_id.lower():
                maybe_add(i, 'MANEJO_ERROR', cond)

        # RAISE EXCEPTION TYPE
        elif m := re.match(r'^\s{1,}RAISE\s+EXCEPTION\s+TYPE\s+(\S+)', line, re.I):
            cx = m.group(1)
            maybe_add(i, 'MANEJO_ERROR', f"RAISE EXCEPTION TYPE {cx}")

        # CATCH cx_xxx
        elif m := re.match(r'^\s{1,}CATCH\s+(.+?)\.?\s*$', line, re.I):
            exceptions = m.group(1).strip()
            # Solo si referencia clases de excepción reales (no INTO)
            if not re.search(r'\bINTO\b', exceptions, re.I):
                maybe_add(i, 'MANEJO_ERROR', f"CATCH {exceptions}")

        # WHERE clause con condiciones de negocio
        elif m := re.match(r'^\s{3,}WHERE\s+(.+?)\.?\s*$', line, re.I):
            cond = m.group(1).strip()
            # Solo capturar si tiene lógica de negocio (no solo técnico)
            if len(cond) > 3 and not re.match(r'^(AND|OR|NOT)\s*$', cond, re.I):
                maybe_add(i, 'FLUJO', f"WHERE {cond}")

        # UPDATE SET (modificaciones de datos)
        elif m := re.match(r'^\s{1,}UPDATE\s+(\w+)\s+SET\s+(.+?)\.?\s*$', line, re.I):
            tbl  = m.group(1)
            vals = m.group(2).strip()
            maybe_add(i, 'CALCULO', f"UPDATE {tbl} SET {vals}")

    return rules


def _detect_obj_id(text: str, stem: str) -> str:
    """Detecta el ID del objeto ABAP desde el texto fuente."""
    m = re.search(r'^\s*class\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)\s+definition', text, re.I | re.M)
    if m:
        return m.group(1).upper()
    m = re.search(r'^\s*(?:PROGRAM|REPORT)\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)', text, re.I | re.M)
    if m:
        return m.group(1).upper()
    # Fallback desde nombre de archivo: _CBB_CL_DB_TVARVC → /CBB/CL_DB_TVARVC
    raw = stem.lstrip('_')
    parts = raw.split('_', 1)
    if len(parts) == 2:
        return f"/{parts[0]}/{parts[1]}"
    return raw.upper()


def _assign_global_ids(all_rules: list[dict]) -> None:
    """Re-numera todos los IDs globalmente (GENREG-0001..N)."""
    for i, r in enumerate(all_rules, start=1):
        r['id'] = f'GENREG-{i:04d}'


def main():
    abap_files = sorted(SOURCE.rglob('*.abap'))
    if not abap_files:
        print("WARN: No se encontraron archivos .abap en source/")
        print("      Carga los exports de SAP en source/CLASS/, source/PROG/, source/FUGR/")
        return

    print(f"Extrayendo reglas de {len(abap_files)} archivo(s) ABAP...\n")
    all_rules: list[dict] = []

    for path in abap_files:
        rel = path.relative_to(SOURCE)
        rules = extract_rules_from_file(path)
        print(f"  >> {rel}  →  {len(rules)} regla(s) extraída(s)")
        for r in rules:
            print(f"     [{r['tipo']:14}] L{r['linea']:4}  {r['metodo']}  {r['business_name'][:70]}")
        all_rules.extend(rules)

    _assign_global_ids(all_rules)

    # Estadísticas por tipo
    from collections import Counter
    by_tipo   = Counter(r['tipo']   for r in all_rules)
    by_riesgo = Counter(r['riesgo'] for r in all_rules)
    by_reg    = Counter(r['reg']    for r in all_rules if r['reg'])

    output = {
        'meta': {
            'sistema'          : 'gentera-sap',
            'tecnologia'       : 'sap-abap',
            'total_reglas'     : len(all_rules),
            'archivos_fuente'  : len(abap_files),
            'by_tipo'          : dict(by_tipo),
            'by_riesgo'        : dict(by_riesgo),
            'by_reg'           : dict(by_reg),
            'fecha_extraccion' : '2026-08-10',
            'version_extractor': '1.0.0',
        },
        'reglas': all_rules,
    }

    OUT.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding='utf-8')

    print(f"\n{'─'*60}")
    print(f"OK  rules-gentera.json  ⇒  {len(all_rules)} reglas")
    print(f"    Por tipo:   {dict(by_tipo)}")
    print(f"    Por riesgo: {dict(by_riesgo)}")
    if by_reg:
        print(f"    Regulatorio: {dict(by_reg)}")
    print(f"\nSiguiente paso: python digital-brain/build-brain.py")


if __name__ == '__main__':
    main()
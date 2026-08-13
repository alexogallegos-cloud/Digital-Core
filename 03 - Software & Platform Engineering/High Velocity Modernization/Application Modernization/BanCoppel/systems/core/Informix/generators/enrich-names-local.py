#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-names-local.py — Enriquecimiento local de business_name sin API.

Lee weak-names-export.json, analiza el código SPL de cada regla con
heurísticas específicas al dominio BanCoppel, y genera name-overrides-ai.json
en el formato que enrich-names-ai.py --apply espera.

Uso: python generators/enrich-names-local.py [--dry-run] [--domain D05]
"""
import re, json, sys, io, argparse
from pathlib import Path
from collections import defaultdict

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
            "03 - Software & Platform Engineering/High Velocity Modernization/"
            "Application Modernization/BanCoppel/Informix/")
WEAK_IN   = BASE / "knowledge-base/rules/weak-names-export.json"
OVERRIDES = BASE / "knowledge-base/rules/name-overrides-ai.json"

# ── Arg parsing ───────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser()
parser.add_argument("--dry-run", action="store_true")
parser.add_argument("--domain",  default=None, help="e.g. D05")
args = parser.parse_args()

# ── Vocabulario SPL — prefijos húngaros + abreviaturas de negocio BanCoppel ──

# Sustantivos de negocio por fragmento del nombre de variable (orden importa)
VAR_HINTS: list[tuple[str, str]] = [
    # Montos y finanzas
    (r'(?:monto|importe|amount)',              'monto'),
    (r'(?:saldo|balance)',                      'saldo'),
    (r'(?:pago|cobro)',                         'pago'),
    (r'(?:cargo|debito|deb[ito]*)',             'cargo'),
    (r'(?:abono|credito|cred[ito]*)',           'abono'),
    (r'(?:iva|impuesto|tax)',                   'IVA'),
    (r'(?:comision|fee)',                       'comisión'),
    (r'(?:interes|interest)',                   'interés'),
    (r'(?:moratorio|mora)',                     'interés moratorio'),
    (r'(?:capital|principal)',                  'capital'),
    (r'(?:total)',                              'total'),
    (r'(?:subtotal)',                           'subtotal'),
    (r'(?:morralla)',                           'morralla (monedas)'),
    (r'(?:billete)',                            'billetes'),
    (r'(?:denominacion|denomination)',          'denominación'),
    (r'(?:dotacion)',                           'dotación'),
    (r'(?:disponible)',                         'saldo disponible'),
    (r'(?:limite|limit)',                       'límite'),
    (r'(?:minimo|minimum)',                     'mínimo'),
    (r'(?:maximo|maximum)',                     'máximo'),
    (r'(?:plazo)',                              'plazo'),
    (r'(?:tasa|rate)',                          'tasa'),
    (r'(?:factor)',                             'factor'),
    (r'(?:porcentaje|pct|porcent)',             'porcentaje'),
    # Clientes y cuentas
    (r'(?:cliente|customer|cte)',               'cliente'),
    (r'(?:cuenta|account|cta)',                 'cuenta'),
    (r'(?:beneficiario|benef)',                 'beneficiario'),
    (r'(?:titular)',                            'titular'),
    (r'(?:firmante)',                           'firmante'),
    (r'(?:socio|partner)',                      'socio'),
    (r'(?:contrato)',                           'contrato'),
    (r'(?:credito|credit|cred)',                'crédito'),
    (r'(?:prestamo|loan)',                      'préstamo'),
    (r'(?:linea|line)',                         'línea de crédito'),
    # Transacciones
    (r'(?:transaccion|transaction|trans)',      'transacción'),
    (r'(?:movimiento|movement|mov)',            'movimiento'),
    (r'(?:operacion|operation|oper)',           'operación'),
    (r'(?:referencia|reference|ref)',           'referencia'),
    (r'(?:folio)',                              'folio'),
    (r'(?:lote|batch)',                         'lote'),
    (r'(?:secuencia|sequence|seq)',             'secuencia'),
    (r'(?:consecutivo|consec)',                 'consecutivo'),
    # Fechas y tiempo
    (r'(?:fecha|date|fec)',                     'fecha'),
    (r'(?:hora|time|hh)',                       'hora'),
    (r'(?:mes|month)',                          'mes'),
    (r'(?:anio|year|anyo)',                     'año'),
    (r'(?:periodo|period)',                     'período'),
    (r'(?:vencimiento|vence|expir)',            'vencimiento'),
    (r'(?:apertura)',                           'apertura'),
    (r'(?:cierre|close)',                       'cierre'),
    # Catálogos y códigos
    (r'(?:codigo|code|cod)',                    'código'),
    (r'(?:estado|status|estatus)',              'estado'),
    (r'(?:tipo|type)',                          'tipo'),
    (r'(?:clave|key)',                          'clave'),
    (r'(?:descripcion|desc)',                   'descripción'),
    (r'(?:concepto)',                           'concepto'),
    (r'(?:motivo|reason)',                      'motivo'),
    (r'(?:error|excepcion|exception)',          'error'),
    (r'(?:mensaje|message|msg)',                'mensaje'),
    # Canales y sistemas
    (r'(?:sucursal|branch)',                    'sucursal'),
    (r'(?:cajero|atm|teller)',                  'cajero / ATM'),
    (r'(?:canal)',                              'canal'),
    (r'(?:usuario|user)',                       'usuario'),
    (r'(?:sistema|system|sys)',                 'sistema'),
    (r'(?:archivo|file)',                       'archivo'),
    (r'(?:registro|record|reg)',                'registro'),
    (r'(?:ruta|path|dir)',                      'ruta'),
    # Contabilidad
    (r'(?:asiento|journal)',                    'asiento contable'),
    (r'(?:cuenta_contable|cta_cont)',           'cuenta contable'),
    (r'(?:partida)',                            'partida'),
    (r'(?:acumulado|acum)',                     'acumulado'),
    (r'(?:concentra)',                          'concentración'),
]

_VAR_COMPILED = [(re.compile(p, re.I), hint) for p, hint in VAR_HINTS]


def var_to_hint(var_name: str) -> str:
    """Extrae pista de negocio del nombre de una variable SPL."""
    # Quita prefijos húngaros: m_, d_, c_, v_, l_, p_, n_, i_, s_
    clean = re.sub(r'^[mMdDcCvVlLpPnNiIsS](?=[A-Z]|_[a-z])', '', var_name)
    clean = re.sub(r'^[a-z]{1,3}_', '', clean)   # cCmd → Cmd, vbill_det → bill_det
    clean = clean.lower().replace('_', ' ')
    # Buscar en vocabulario
    for pat, hint in _VAR_COMPILED:
        if pat.search(clean):
            return hint
    # Fallback: el nombre limpio en minúsculas (hasta 25 chars)
    return clean[:25].strip()


# ── Patrones de código SPL ────────────────────────────────────────────────────

_RAISE_EX   = re.compile(r'RAISE\s+EXCEPTION\s*\(([^)]+)\)', re.I)
_RAISE_SIMPLE = re.compile(r'RAISE\s+EXCEPTION\s+(\w+)', re.I)
_LET_FULL   = re.compile(r'^(?:LET\s+)?([a-z]\w+)\s*=\s*(.+)$', re.I)   # LET optional
_RETURN_CODE= re.compile(r'RETURN\s+"([^"]+)"', re.I)
_RETURN_VAR = re.compile(r'RETURN\s+(\w+)', re.I)
_INLINE_CMT = re.compile(r';\s*--\s*(.{8,})')    # ; -- comment (espacio opcional)
_INLINE_CMT2= re.compile(r'--\s*(.{8,})')        # comment anywhere in line
_DYNAMIC_SQL= re.compile(r'c(?:Cmd|Query|SQL|Sentence)\d*\s*=', re.I)
_LPAD_DATE  = re.compile(r'LPAD\s*\(\s*(?:MONTH|DAY|YEAR)', re.I)
_TO_CHAR    = re.compile(r'TO_CHAR\s*\(', re.I)
_DATE_FMT   = re.compile(r'(?:MONTH|DAY|YEAR|TO_CHAR|MDY|DATE)\s*\(', re.I)
_ARITH      = re.compile(r'(\w+)\s*[+\-\*\/]\s*(\w+)')
_ACCUM      = re.compile(r'^(\w+)\s*=\s*\1\s*[+\-]\s*(.+)$', re.I)   # var = var + expr
_DIVISION   = re.compile(r'(\w+)\s*/\s*(\w+)', re.I)
_LOAD_FROM  = re.compile(r'(?:LOAD|UNLOAD)\s+(?:FROM|TO)\s+(\S+)', re.I)
_EXECUTE    = re.compile(r'EXECUTE\s+(?:PROCEDURE|FUNCTION)\s+(\w+)', re.I)
_SELECT_INTO= re.compile(r'SELECT\s+.+\s+INTO\s+(\w+)', re.I)
_FROM_TABLE = re.compile(r'\bFROM\s+(?:[^.\s]+\.)?(\w+)', re.I)
_DELETE_FROM= re.compile(r'DELETE\s+FROM\s+(?:[^.\s]+\.)?(\w+)', re.I)
_INSERT_INTO= re.compile(r'INSERT\s+INTO\s+(?:[^.\s]+\.)?(\w+)', re.I)
_UPDATE_TBL = re.compile(r'UPDATE\s+(?:[^.\s]+\.)?(\w+)\s+SET', re.I)
_CHMOD      = re.compile(r'^chmod\s', re.I)
_SED_AWK    = re.compile(r'\b(sed|awk|grep)\s+', re.I)
_SHELL_CMD  = re.compile(r'(?:chmod|rm\s|mv\s|cp\s|mkdir|touch|ln\s)', re.I)

# Tablas con semántica conocida
TABLE_BIZ: dict[str, str] = {
    'clientes':          'clientes',
    'cliente':           'clientes',
    'cuentas':           'cuentas',
    'cuenta':            'cuentas',
    'movimientos':       'movimientos',
    'transacciones':     'transacciones',
    'transaccion':       'transacciones',
    'saldos':            'saldos',
    'saldo':             'saldos',
    'creditos':          'créditos',
    'prestamos':         'préstamos',
    'pagos':             'pagos',
    'facturas':          'facturas',
    'asientos':          'asientos contables',
    'bitacora':          'bitácora',
    'log':               'log',
    'errores':           'errores',
    'catalogos':         'catálogos',
    'parametros':        'parámetros',
    'sucursales':        'sucursales',
    'cajeros':           'cajeros',
    'atms':              'ATMs',
    'denominaciones':    'denominaciones',
    'billetes':          'billetes',
    'dotaciones':        'dotaciones',
    'transferencias':    'transferencias',
    'spei':              'SPEI',
    'cheques':           'cheques',
    'inversiones':       'inversiones',
    'cobranza':          'cobranza',
    'comisiones':        'comisiones',
    'intereses':         'intereses',
    'contratos':         'contratos',
}


def table_hint(tname: str) -> str:
    t = tname.lower()
    for k, v in TABLE_BIZ.items():
        if k in t:
            return v
    return tname[:20]


def clean_code(code: str) -> str:
    """Limpia prefijos de DB e informix del código."""
    s = re.sub(r'(?:bdi\w+|inter\w+):', '', code, flags=re.I)
    s = re.sub(r'"informix"\.', '', s, flags=re.I)
    return s.strip()


# ── Generador principal de business_name ─────────────────────────────────────

def infer_name(rule: dict) -> str:
    """Deriva un business_name de negocio a partir del código SPL."""
    tipo = (rule.get('tipo') or '').upper()
    code = clean_code(rule.get('code') or '')
    sp   = rule.get('sp', '')
    sc   = code.rstrip(';').strip()

    # 1. Comentario inline: expr; -- descripción  o  -- descripción al inicio
    for cmt_pat in (_INLINE_CMT, _INLINE_CMT2):
        m = cmt_pat.search(code)
        if m:
            hint = m.group(1).strip()
            # Filtrar si es código puro, ruta de archivo, o decorador puro
            if re.match(r'^(SELECT|INSERT|UPDATE|DELETE|LET|IF|FOR|EXEC|http|/|\\|---)', hint, re.I):
                break
            if re.match(r'^[/\\*=]{1,}', hint):
                break
            if len(hint) <= 6:
                break
            # Aceptar si es prosa (puede tener [ ] para aclaraciones como "[No. de ATM]")
            # Rechazar solo si son llaves de código: {}
            if re.search(r'[{}]', hint[:30]):
                break
            cleaned = hint[:65].rstrip('.,;')
            return (cleaned[0].upper() + cleaned[1:]) if cleaned else ''

    # 2. RAISE EXCEPTION — determinar motivo
    m = _RAISE_EX.search(sc)
    if m:
        args_txt = m.group(1)
        # Extraer código de error si es literal
        code_m = re.search(r'(-\d+)', args_txt)
        msg_m  = re.search(r"'([^']{4,})'", args_txt)
        if msg_m:
            return f"Rechazar: {msg_m.group(1)[:50]}"
        var_m  = re.search(r'\b([a-z]\w+)\b', args_txt, re.I)
        if var_m:
            v_hint = var_to_hint(var_m.group(1))
            return f"Lanzar error: {v_hint}"[:65]
        return "Lanzar error de retorno"

    m = _RAISE_SIMPLE.match(sc)
    if m:
        v_hint = var_to_hint(m.group(1))
        return f"Lanzar error: {v_hint}"[:65]

    # 3. RETURN "código"
    m = _RETURN_CODE.search(sc)
    if m:
        code_val = m.group(1)
        return f"Retornar código {code_val}"[:65]

    # 4. Comandos shell — generación de archivos de carga/reporte
    if _CHMOD.match(sc):
        return "Establecer permisos de archivo"
    if _SHELL_CMD.search(sc):
        if _SED_AWK.search(sc):
            return "Procesar archivo con herramienta Unix"
        return "Ejecutar comando de sistema"

    # 5. Construcción de SQL dinámico
    if _DYNAMIC_SQL.match(sc) or (re.match(r'cQuery', sc, re.I)):
        # Intentar extraer tabla o keyword del string
        t_m = re.search(r'\b(FROM|INTO|UPDATE)\s+(\w+)', sc, re.I)
        if t_m:
            th = table_hint(t_m.group(2))
            return f"Construir consulta sobre {th}"[:65]
        kw_m = re.search(r"WHEN\s+\w+\s*[=<>]\s*\d+\s+THEN\s+'([^']{4,})'", sc, re.I)
        if kw_m:
            return f"Construir condición: {kw_m.group(1)[:40]}"[:65]
        return "Construir consulta SQL dinámica"

    # 6. Formateo de fechas
    if _LPAD_DATE.search(sc) or _DATE_FMT.search(sc):
        # Detectar qué fecha
        for pat, label in [('inicial','inicial'), ('final','final'), ('vencimiento','vencimiento'),
                            ('corte','de corte'), ('proceso','de proceso')]:
            if pat.lower() in sc.lower():
                return f"Formato de fecha {label}"[:65]
        return "Formato de fecha"

    # 7. TO_CHAR (formato numérico o fecha)
    if _TO_CHAR.search(sc):
        return "Formatear valor para presentación"

    # 8. LOAD FROM / UNLOAD TO
    m = _LOAD_FROM.search(sc)
    if m:
        fpath = m.group(1)
        op = 'cargar' if 'LOAD' in sc.upper()[:10] else 'exportar'
        return f"{op.capitalize()} datos desde archivo"[:65]

    # 9. Acumulación: var = var + expr  OR  var += expr (pattern)
    m = _ACCUM.match(sc)
    if m:
        v_hint = var_to_hint(m.group(1))
        # Denominación × cantidad especial
        if re.search(r'(denominacion|denom|denomination)', m.group(2), re.I):
            return f"Acumular billetes: denominación × cantidad"[:65]
        return f"Acumular {v_hint}"[:65]

    # 10. LET var = expr  OR  var = expr (fórmulas diversas)
    m = _LET_FULL.match(sc)
    if m:
        lhs = m.group(1)
        rhs = m.group(2).strip()

        # 10a. División → promedio o ratio
        d_m = _DIVISION.search(rhs)
        if d_m and '/' in rhs:
            lhs_hint = var_to_hint(lhs)
            num_hint  = var_to_hint(d_m.group(1))
            den_hint  = var_to_hint(d_m.group(2))
            if num_hint and den_hint:
                return f"Calcular {lhs_hint}: {num_hint} ÷ {den_hint}"[:65]
            return f"Calcular promedio de {lhs_hint}"[:65]

        # 10b. Multiplicación
        if '*' in rhs:
            lhs_hint = var_to_hint(lhs)
            # Detectar denominación × cantidad
            if re.search(r'(denominacion|denom|cantidad|cant)', rhs, re.I):
                return f"Calcular {lhs_hint}: denominación × cantidad"[:65]
            return f"Calcular {lhs_hint} (multiplicación)"[:65]

        # 10c. Suma / resta
        if '+' in rhs or '-' in rhs:
            lhs_hint = var_to_hint(lhs)
            return f"Calcular {lhs_hint}"[:65]

        # 10d. Concatenación de cadenas
        if '||' in rhs:
            lhs_hint = var_to_hint(lhs)
            return f"Construir cadena: {lhs_hint}"[:65]

        # 10e. Cálculo de fecha
        if re.search(r'(?:MDY|DATE|YEAR|MONTH|DAY|EXTEND|INTERVAL)\s*\(', rhs, re.I):
            lhs_hint = var_to_hint(lhs)
            return f"Calcular {lhs_hint}"[:65]

        # 10f. Asignación simple con semántica real
        lhs_hint = var_to_hint(lhs)
        if lhs_hint and lhs_hint != lhs.lower() and lhs_hint != lhs.replace('_', ' ').lower():
            return f"Calcular {lhs_hint}"[:65]

        # 10g. Asignación desde SELECT / función
        if re.match(r'SELECT|TODAY|NOW|CURRENT', rhs, re.I):
            return f"Obtener {var_to_hint(lhs)}"[:65]

    # 11. INSERT / DELETE / UPDATE
    m = _INSERT_INTO.match(sc)
    if m:
        th = table_hint(m.group(1))
        return f"Insertar registro en {th}"[:65]

    m = _DELETE_FROM.match(sc)
    if m:
        th = table_hint(m.group(1))
        return f"Eliminar de {th}"[:65]

    m = _UPDATE_TBL.match(sc)
    if m:
        th = table_hint(m.group(1))
        return f"Actualizar {th}"[:65]

    # 12. SELECT INTO
    m = _SELECT_INTO.match(sc)
    if m:
        var_hint = var_to_hint(m.group(1))
        from_m = _FROM_TABLE.search(sc)
        if from_m:
            th = table_hint(from_m.group(1))
            return f"Consultar {var_hint} desde {th}"[:65]
        return f"Obtener {var_hint}"[:65]

    # 13. EXECUTE PROCEDURE
    m = _EXECUTE.search(sc)
    if m:
        called_sp = m.group(1)
        return f"Llamar {called_sp.replace('_',' ')}"[:65]

    # 14. Fallback: usar nombre del SP + tipo
    sp_clean = re.sub(r'^sp_', '', sp).replace('_', ' ')
    if tipo.startswith('F'):
        return f"Cálculo en {sp_clean}"[:65]
    elif tipo.startswith('V'):
        return f"Validar en {sp_clean}"[:65]
    elif tipo.startswith('U'):
        return f"Umbral en {sp_clean}"[:65]
    return f"Regla de {sp_clean}"[:65]


def capitalize(s: str) -> str:
    return (s[0].upper() + s[1:]) if s else ''


# ── Main ──────────────────────────────────────────────────────────────────────

with open(WEAK_IN, encoding='utf-8') as f:
    data = json.load(f)
rules = data['rules']

if args.domain:
    dom = args.domain.upper()
    rules = [r for r in rules if dom in (r.get('dominio') or '')]
    print(f"Domain filter {dom}: {len(rules)} rules")

print(f"Processing {len(rules)} weak rules...")

overrides: dict[str, str] = {}
processed_sps: set[str] = set()

# Cargar overrides existentes (sin sobreescribir)
if OVERRIDES.exists():
    with open(OVERRIDES, encoding='utf-8') as f:
        saved = json.load(f)
    overrides = saved.get('names', {})
    processed_sps = set(saved.get('processed_sps', []))
    print(f"Existing overrides: {len(overrides)} (will add/update local ones)")

improved = 0
same = 0
by_category: dict[str, int] = defaultdict(int)

for r in rules:
    rid    = r.get('id', '')
    sp_key = f"{r.get('db','')}:{r.get('sp','')}"
    old    = (r.get('business_name') or '').strip()

    new = capitalize(infer_name(r))
    if not new or len(new) < 4:
        same += 1
        continue

    # Solo guardar si es distinto al actual y más informativo
    if new != old and len(new) >= len(old) * 0.5:
        overrides[rid] = new
        improved += 1
        # Clasificar para stats
        code = (r.get('code') or '').strip()
        if re.match(r'RAISE', code, re.I):
            by_category['raise_exception'] += 1
        elif re.match(r'LET\s+\w+\s*=', code, re.I) and ('+' in code or '-' in code or '*' in code or '/' in code):
            by_category['arithmetic'] += 1
        elif re.match(r'cCmd', code, re.I):
            by_category['dynamic_sql'] += 1
        elif re.match(r'RETURN', code, re.I):
            by_category['return'] += 1
        elif 'LPAD' in code.upper() or 'MONTH(' in code.upper():
            by_category['date_format'] += 1
        elif re.match(r'INSERT|DELETE|UPDATE', code, re.I):
            by_category['dml'] += 1
        else:
            by_category['other'] += 1
    else:
        same += 1

print(f"\nResults: {improved} improved, {same} unchanged")
print("Categories:")
for cat, n in sorted(by_category.items(), key=lambda x: -x[1]):
    print(f"  {cat}: {n}")

if args.dry_run:
    print("\n=== DRY RUN — primeras 20 mejoras ===")
    shown = 0
    for r in rules:
        rid = r.get('id', '')
        if rid in overrides:
            old = (r.get('business_name') or '').strip()
            new = overrides[rid]
            print(f"  [{r['tipo']}] {r['sp']} L{r.get('line',0)}")
            print(f"    old: {repr(old[:60])}")
            print(f"    new: {repr(new[:60])}")
            print(f"    code: {repr((r.get('code') or '')[:70])}")
            print()
            shown += 1
            if shown >= 20:
                break
    sys.exit(0)

# Guardar overrides
OVERRIDES.parent.mkdir(parents=True, exist_ok=True)
with open(OVERRIDES, 'w', encoding='utf-8') as f:
    json.dump({'names': overrides, 'processed_sps': list(processed_sps)},
              f, ensure_ascii=False, indent=2)

print(f"\nSaved {len(overrides)} total overrides → {OVERRIDES}")
print(f"Run: python generators/enrich-names-ai.py --apply")

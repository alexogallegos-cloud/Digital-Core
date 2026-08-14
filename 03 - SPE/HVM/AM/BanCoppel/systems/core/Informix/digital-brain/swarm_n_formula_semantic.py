"""
Swarm N — Enriquecimiento semántico de reglas FÓRMULA.

Objetivo: reemplazar nombres que replican la expresión algebraica con nombres
que describen el CONCEPTO DE NEGOCIO que la fórmula representa.

Cubre 670 reglas donde business_name contiene '=' (indicador de replicación).

Estrategia por patrón de expresión:
  COUNT/SUM/AVG → conteo/acumulación de entidades de negocio
  A / 1.16      → extracción de base sin IVA
  A * 1.16      → cálculo de IVA
  A * mIva/pIva → importe de IVA sobre monto base
  (A * iva) + A → total con IVA incluido
  A / tipo_cambio / v_dolar → conversión de moneda
  A / B (vencido/mora sobre total) → índice de morosidad/vencimiento
  A / B (genérico) → proporción/índice de A sobre B
  A + B / A - B  → acumulación/diferencia de saldos
  VAR = constante → asignación de valor fijo o código estándar
"""
import sqlite3, re
from pathlib import Path
from datetime import datetime
import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ── Vocabulario del brain ─────────────────────────────────────────────────────
cur.execute("SELECT term, meaning FROM terms WHERE meaning IS NOT NULL AND meaning != ''")
VOCAB = {r[0].lower(): r[1] for r in cur.fetchall()}

# ── Vocabulario de dominio bancario BanCoppel (Capa 2 semántica) ──────────────
DOMAIN_VOCAB = {
    # Crédito y cartera
    'vencid':   'en mora',
    'vencido':  'en mora',
    'mora':     'en mora',
    'abono':    'pago de crédito',
    'cuota':    'cuota de crédito',
    'capital':  'capital del crédito',
    'interes':  'interés',
    'iva':      'IVA',
    'costo':    'costo',
    'saldo':    'saldo',
    'monto':    'monto',
    'importe':  'importe',
    'cargo':    'cargo',
    'abono':    'abono',
    'pago':     'pago',
    # Productos y segmentos
    'cjunk':    'segmento CJUNK (clientes con historial de crédito en tienda)',
    'precal':   'precalificación crediticia',
    'precal1':  'precalificación crediticia — variante 1',
    'calific':  'calificación de riesgo',
    'credito':  'crédito',
    'producto': 'producto financiero',
    # Operaciones
    'aclaracion': 'aclaración de crédito',
    'token':    'token de autenticación',
    'reversa':  'reversión de operación',
    'retiro':   'retiro',
    'deposito': 'depósito',
    'transfer': 'transferencia',
    'spei':     'SPEI',
    'codi':     'CoDi',
    # Canales
    'bei':      'Banca en Internet',
    'bpi':      'BanCoppel en Internet',
    'soe':      'Soporte Operativo EmpresaNet',
    'atm':      'cajero automático',
    # Indicadores
    'tasa':     'tasa',
    'indice':   'índice',
    'tipo_cambio': 'tipo de cambio',
    'dolar':    'dólar',
    'pesos':    'pesos MXN',
    'usd':      'dólares USD',
    # Contables
    'afectacion': 'afectación contable',
    'contable': 'registro contable',
    'disp':     'disponible',
    'sdodisp':  'saldo disponible',
    # Aclaraciones / operacional
    'interact': 'interacción con aclaración',
    'siniestro':'siniestro',
    'poliza':   'póliza',
    # Reportes regulatorios
    'minds':    'reporte MINDS (CNBV)',
    'r24':      'reporte R24 (Banxico)',
    'pld':      'PLD/AML',
    # Tiempo
    'dia':      'día',
    'mes':      'mes',
    'anio':     'año',
    'fecha':    'fecha',
    'plazo':    'plazo',
    'vencimiento': 'vencimiento',
}

def strip_hungarian(var):
    var = var.strip()
    SYSTEM_CONSTS = {'SQL_ERR','SQLCODE','SQLERRD','SQLSTATE','NULL','TRUE','FALSE','CURRENT'}
    if var.upper() in SYSTEM_CONSTS:
        return var.lower()
    if len(var) > 3 and var[0].lower() in 'vpismdct' and var[1].isalpha() and var[1].isupper():
        return var[1:]
    return var

def humanize_var(var):
    clean = strip_hungarian(var)
    cl = clean.lower()
    if cl in VOCAB:
        return VOCAB[cl]
    # Buscar en domain vocab por substring
    for key, meaning in DOMAIN_VOCAB.items():
        if key in cl:
            return meaning
    # Separar camelCase y underscores
    parts = re.sub(r'([A-Z])', r' \1', clean).replace('_', ' ').lower().split()
    translated = []
    for p in parts:
        found = False
        for key, meaning in DOMAIN_VOCAB.items():
            if key in p:
                translated.append(meaning)
                found = True
                break
        if not found:
            translated.append(p)
    return ' '.join(translated).strip() or cl

def sp_context(sp_name, biz):
    """Extrae contexto de negocio del SP para el nombre."""
    sp = re.sub(r'^sp_', '', (sp_name or '').split(':')[-1]).replace('_', ' ').lower()
    biz = (biz or '').lower().strip()
    # Aplicar domain vocab al SP name
    ctx_parts = []
    if biz and len(biz) >= 6:
        # Limpiar el biz del primer verbo
        biz_clean = re.sub(r'^(consulta|obtiene|actualiza|calcula|genera|valida|registra|procesa|carga|inserta|elimina)\s+', '', biz)
        biz_clean = re.split(r'[,;—–]', biz_clean)[0].strip()
        if biz_clean:
            ctx_parts.append(biz_clean[:60])
    return ' / '.join(ctx_parts) if ctx_parts else sp[:40]

# ── Detectores de patrón de fórmula ──────────────────────────────────────────

# Patrones de expresión (sobre el campo code)
RE_COUNT   = re.compile(r'COUNT\s*\(', re.I)
RE_SUM     = re.compile(r'SUM\s*\(', re.I)
RE_AVG     = re.compile(r'AVG\s*\(', re.I)
RE_DIV_116 = re.compile(r'/\s*1\.16\b', re.I)
RE_MUL_116 = re.compile(r'\*\s*1\.16\b', re.I)
RE_IVA_MUL = re.compile(r'\*\s*[mp]?[Ii]va\b', re.I)   # * mIva / * pIva
RE_IVA_TOT = re.compile(r'\(\w+\s*\*\s*\w*[Ii]va\w*\)\s*\+', re.I)  # (A * iva) + A
RE_FX      = re.compile(r'/\s*(v_dolar|tipo_cambio|p_tipo_cambio|dolar)\b', re.I)
RE_ASSIGN  = re.compile(r"""^\s*\w+\s*=\s*'[^']*'\s*$""", re.I)   # VAR = 'constante'
RE_ASSIGN0 = re.compile(r'^\s*\w+\s*=\s*0\s*$', re.I)             # VAR = 0
RE_DIV     = re.compile(r'\w+\s*/\s*\w+')
RE_MUL     = re.compile(r'\w+\s*\*\s*\w+')
RE_ADD     = re.compile(r'\w+\s*\+\s*\w+')
RE_SUB     = re.compile(r'\w+\s*-\s*\w+')
RE_SELECT  = re.compile(r'SELECT\b', re.I)

def var_contains(var, *keywords):
    v = var.lower()
    return any(k in v for k in keywords)

def classify_and_name(code, biz, sp_raw):
    """Genera business name semántico para una FÓRMULA."""
    code = (code or '').strip()
    ctx = sp_context(sp_raw, biz)

    # Extraer la parte derecha de la asignación (la expresión real)
    eq_idx = code.find('=')
    lhs = code[:eq_idx].strip() if eq_idx > 0 else ''
    rhs = code[eq_idx+1:].strip() if eq_idx > 0 else code

    lhs_human = humanize_var(lhs) if lhs else ''

    # ── 1. Agregaciones SQL ────────────────────────────────────────────────────
    if RE_SELECT.search(code):
        if RE_COUNT.search(code):
            return f"Conteo de registros — {ctx}: número total de ocurrencias que cumplen el criterio de selección"
        if RE_SUM.search(code):
            return f"Acumulación de montos — {ctx}: suma de valores que cumplen el criterio de selección"
        if RE_AVG.search(code):
            return f"Promedio de valores — {ctx}: media aritmética de los registros que cumplen el criterio"
        return f"Consulta agregada — {ctx}"

    # ── 2. IVA — (A * iva) + A = total con IVA ────────────────────────────────
    if RE_IVA_TOT.search(rhs):
        return f"Importe total con IVA incluido — monto base más impuesto al valor agregado (16%) en {ctx}"

    # ── 3. IVA — A * mIva = importe de IVA ───────────────────────────────────
    if RE_IVA_MUL.search(rhs):
        base_m = re.match(r'(\w+)\s*\*', rhs)
        base_human = humanize_var(base_m.group(1)) if base_m else 'monto base'
        return f"Importe de IVA (16%) sobre {base_human} — obligación fiscal en {ctx}"

    # ── 4. División por 1.16 = extracción de base sin IVA ────────────────────
    if RE_DIV_116.search(rhs):
        base_m = re.match(r'(\w+)\s*/', rhs.strip())
        base_human = humanize_var(base_m.group(1)) if base_m else 'importe bruto'
        return f"Base sin IVA — {base_human} desglosado del impuesto al valor agregado (16%) para {ctx}"

    # ── 5. Multiplicación por 1.16 = aplicar IVA ─────────────────────────────
    if RE_MUL_116.search(rhs):
        base_m = re.match(r'(\w+)\s*\*', rhs.strip())
        base_human = humanize_var(base_m.group(1)) if base_m else 'monto base'
        return f"Importe con IVA — {base_human} incrementado con impuesto al valor agregado (16%) en {ctx}"

    # ── 6. División por tipo de cambio = conversión FX ───────────────────────
    if RE_FX.search(rhs):
        num_m = re.match(r'(\w+)\s*/', rhs.strip())
        num_human = humanize_var(num_m.group(1)) if num_m else 'monto en pesos'
        return f"Conversión de {num_human} a dólares USD aplicando tipo de cambio vigente — {ctx}"

    # ── 7. Constante / valor fijo ─────────────────────────────────────────────
    if RE_ASSIGN.match(code) or RE_ASSIGN0.match(code):
        val = rhs.strip().strip("'")
        return f"Valor fijo asignado ({val}) — {ctx}: constante del proceso sin cálculo"

    # ── 8. División genérica — posible índice o tasa ──────────────────────────
    if RE_DIV.search(rhs):
        parts = re.split(r'\s*/\s*', rhs, maxsplit=1)
        if len(parts) == 2:
            num = re.search(r'(\w+)\s*$', parts[0])
            den = re.search(r'^\s*(\w+)', parts[1])
            num_h = humanize_var(num.group(1)) if num else 'numerador'
            den_h = humanize_var(den.group(1)) if den else 'denominador'

            # Patrón de morosidad: vencido / total
            if var_contains(num_h, 'mora', 'vencid', 'vencido'):
                return f"Índice de morosidad — proporción de cartera en mora sobre el total de compromisos de pago en {ctx}"
            # Patrón de cobertura
            if var_contains(den_h, 'total', 'cartera', 'abono') and var_contains(num_h, 'abono', 'pago', 'monto'):
                return f"Proporción de {num_h} sobre {den_h} — indicador de cobertura en {ctx}"
            return f"Índice de {num_h} relativo a {den_h} — indicador de desempeño en {ctx}"

    # ── 9. Multiplicación genérica ────────────────────────────────────────────
    if RE_MUL.search(rhs):
        parts = re.split(r'\s*\*\s*', rhs, maxsplit=1)
        if len(parts) == 2:
            a_h = humanize_var(re.search(r'(\w+)\s*$', parts[0]).group(1)) if re.search(r'(\w+)\s*$', parts[0]) else 'valor A'
            b_h = humanize_var(re.search(r'^\s*(\w+)', parts[1]).group(1)) if re.search(r'^\s*(\w+)', parts[1]) else 'valor B'
            return f"Cálculo de {lhs_human or 'resultado'} — producto de {a_h} aplicado a {b_h} en {ctx}"

    # ── 10. Suma / diferencia genérica ────────────────────────────────────────
    if RE_ADD.search(rhs):
        return f"Acumulación de {lhs_human or 'saldo'} — suma de componentes en {ctx}"
    if RE_SUB.search(rhs):
        return f"Diferencia de {lhs_human or 'saldo'} — resta de componentes para obtener el neto en {ctx}"

    # ── 11. Fallback ──────────────────────────────────────────────────────────
    return f"Cálculo de {lhs_human or 'resultado'} en {ctx}"

# ── Cargar reglas a enriquecer ────────────────────────────────────────────────
cur.execute("""
    SELECT r.id, r.business_name, r.code, r.sp, s.biz
    FROM rules r
    LEFT JOIN sps s ON s.id = r.sp
    WHERE r.tipo = 'FÓRMULA' AND r.business_name LIKE '%=%'
    ORDER BY r.sp, r.line
""")
rows = cur.fetchall()
print(f"Reglas FÓRMULA a enriquecer: {len(rows)}")

updates     = []
log_entries = []

for rid, old_bn, code, sp, biz in rows:
    sp_name = (sp or '').split(':')[-1]
    new_bn = classify_and_name(code, biz, sp_name)
    new_bn = new_bn[0].upper() + new_bn[1:] if new_bn else new_bn
    new_bn = re.sub(r'\s+', ' ', new_bn).strip()[:220]

    if new_bn and new_bn != old_bn:
        updates.append((new_bn, rid))
        log_entries.append((rid, 'swarm_n', 'business_name', old_bn or '', new_bn, NOW, 0.82, 'semantic_formula', ''))

print(f"Con cambio efectivo:         {len(updates)}")

# Preview 20 ejemplos
print("\nPREVIEW (20 ejemplos):")
for new_bn, rid in updates[:20]:
    old = next((r[1] for r in rows if r[0] == rid), '')
    print(f"\n  ID:  {rid}")
    print(f"  OLD: {(old or '')[:100]}")
    print(f"  NEW: {new_bn[:100]}")

# Aplicar
cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
cur.executemany("""
    INSERT INTO rule_enrichment_log (rule_id,swarm,field,old_value,new_value,timestamp,confidence,method,notes)
    VALUES (?,?,?,?,?,?,?,?,?)
""", log_entries)
cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
con.commit()

# Verificar cuántos quedan con =
cur.execute("SELECT COUNT(*) FROM rules WHERE tipo='FÓRMULA' AND business_name LIKE '%=%'")
restantes = cur.fetchone()[0]
print(f"\n✓ Actualizados: {len(updates)}")
print(f"  FÓRMULA con '=' restantes: {restantes}")

con.close()
print("\nCorre: python digital-brain/rebuild_from_brain.py")

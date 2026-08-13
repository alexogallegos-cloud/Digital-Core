"""
classify-rule-subtipo.py — Adds sub_tipo column to rules table in brain.db

Classifies each NEGOCIO rule into one of 12 sub-types based on code pattern + context.
Order of pattern matching matters — more specific first.

Run: python generators/classify-rule-subtipo.py
"""

import sqlite3, re
from pathlib import Path

BASE  = Path(__file__).resolve().parent.parent
BRAIN = BASE / 'digital-brain' / 'brain.db'


# ---------------------------------------------------------------------------
# Pattern definitions (evaluated in order — first match wins)
# ---------------------------------------------------------------------------

_RULES: list[tuple[str, re.Pattern]] = [

    # 1. EXCEPCIÓN — explicit error raising (most specific VALIDACIÓN)
    ('EXCEPCIÓN',
     re.compile(r'\bRAISE\s+EXCEPTION\b', re.I)),

    # 2. CÓDIGO_RETORNO — assigning a return/error code to a variable
    #    LET cCodRet = '207', LET vCodRetorno = '000', etc.
    ('CÓDIGO_RETORNO',
     re.compile(r'\bLET\s+[a-z_]*(?:cod|ret|retorno|resultado|res|status)[a-z_]*\s*=\s*[\'\"]\d', re.I)),

    # 3. RETORNO_CÓDIGO — RETURN with literal code string
    ('RETORNO_CÓDIGO',
     re.compile(r'\bRETURN\b[^;]{0,80}[\'\"]\d{3,}', re.I)),

    # 4. CÁLCULO_FISCAL — IVA, ISR, SAT, impuesto calculations
    ('CÁLCULO_FISCAL',
     re.compile(r'\b(IVA|ISR|SAT|IMPUEST|RETENCION|TASA_IVA|iva_suc|ivasuc)\b', re.I)),

    # 5. CÁLCULO_FECHA — date arithmetic
    ('CÁLCULO_FECHA',
     re.compile(r'\b(DATE\s*\(|EXTEND\s*\(|YEAR\s*\(|MONTH\s*\(|DAY\s*\(|TODAY|CURRENT\s+[A-Z]|365\.25|DAYS?\s*\()', re.I)),

    # 6. CÁLCULO_INTERÉS — interest/rate/mora calculations
    ('CÁLCULO_INTERÉS',
     re.compile(r'\b(MORA|INTERES|TASA_INT|SOBRETASA|TASA_MORA|TASA_NOMI|TASA_EFEC|GAT)\b', re.I)),

    # 7. CÁLCULO_MONETARIO — ROUND() = explicitly rounding a monetary value
    ('CÁLCULO_MONETARIO',
     re.compile(r'\bROUND\s*\(', re.I)),

    # 8. CÁLCULO_PORCENTUAL — percentage: /100 or multiply by 0.XX factor
    ('CÁLCULO_PORCENTUAL',
     re.compile(r'/\s*100\.?\b|\*\s*0\.\d+\b|/\s*100\s*\)', re.I)),

    # 9. UMBRAL_PLD — AML/PLD thresholds (regulatory hard limits)
    ('UMBRAL_PLD',
     re.compile(r'\b(10000|10,000|FATCA|UIF_|AML)\b', re.I)),

    # 10. CONCILIACIÓN — balance reconciliation
    ('CONCILIACIÓN',
     re.compile(r'\b(CONCILI|CUADRE|DIFERENCIA_SALDO|SALDO_CONCIL)\b', re.I)),

    # 11. INTEGRACIÓN_SP — calling external stored procedure
    ('INTEGRACIÓN_SP',
     re.compile(r'\bEXECUTE\s+PROCEDURE\b|\bCALL\s+\w+\s*\(', re.I)),

    # 12. UMBRAL_RANGO — range comparison (>= X AND <= Y or BETWEEN)
    ('UMBRAL_RANGO',
     re.compile(r'[<>=!]=?\s*[\d\.]+\s+AND\s+\w+\s*[<>=!]=?\s*[\d\.]+|\bBETWEEN\b', re.I)),

    # 13. UMBRAL_FECHA — date/time threshold comparison
    ('UMBRAL_FECHA',
     re.compile(r'\b(?:fecha|date|dia)\w*\s*[<>!=]=?\s*\d|\bIF\s+\w*(?:dia|fecha|day)\w*\s+[<>]', re.I)),

    # 14. UMBRAL_MONTO — money/amount threshold comparison
    ('UMBRAL_MONTO',
     re.compile(r'\bIF\s+\w*(?:monto|saldo|importe|amount|limit|cargo|abono)\w*\s*[<>!=]=?\s*[\d\.]', re.I)),

    # 15. UMBRAL_CONTEO — count/attempt threshold
    ('UMBRAL_CONTEO',
     re.compile(r'\bIF\s+\w*(?:cont|count|intent|reint|veces|num)\w*\s*[<>!=]=?\s*\d', re.I)),

    # 16. UMBRAL_SIMPLE — any remaining IF with numeric threshold
    ('UMBRAL_SIMPLE',
     re.compile(r'\bIF\s+\w.{0,60}[<>!=]=?\s*\d', re.I)),

    # 17. CONTROL_FLUJO — IF on return code / status code (flow decision)
    ('CONTROL_FLUJO',
     re.compile(r'\bIF\s+\w*(?:cod|ret|status|res|resultado)\w*\s*(?:<>|!=|=)', re.I)),

    # 18. CÁLCULO_INVERSIÓN — sign inversion pattern (negation)
    ('CÁLCULO_INVERSIÓN',
     re.compile(r'\*\s*\(?-1\)?\b|\*\s*\(-1\)', re.I)),

    # 19. CONSTRUCCIÓN_CADENA — string concatenation with || (not covered by ENSAMBLAJE_REPORTE)
    ('CONSTRUCCIÓN_CADENA',
     re.compile(r'\|\|', re.I)),

    # 20. ASIGNACIÓN_ESTADO — LET var = string/code (not a digit-only code)
    ('ASIGNACIÓN_ESTADO',
     re.compile(r'\bLET\s+\w+\s*=\s*[\'\"]\w+[\'\"]', re.I)),

    # 21. CÁLCULO_ARITMÉTICO — any remaining arithmetic expression
    ('CÁLCULO_ARITMÉTICO',
     re.compile(r'\bLET\s+\w+\s*=\s*.+[+\-\*/].+', re.I)),
]

_CONTROL_FLUJO_GENERIC = re.compile(r'\bIF\b|\bELSE\b|\bRETURN\b', re.I)


def classify(code: str, tipo: str) -> str:
    if not code:
        return 'SIN_CÓDIGO'
    for sub_tipo, pat in _RULES:
        if pat.search(code):
            return sub_tipo
    # Fallback by tipo
    if tipo == 'UMBRAL':
        return 'UMBRAL_SIMPLE'
    if tipo in ('VALIDACIÓN', 'ESTADO'):
        return 'CONTROL_FLUJO'
    if _CONTROL_FLUJO_GENERIC.search(code):
        return 'CONTROL_FLUJO'
    return 'CÁLCULO_ARITMÉTICO'  # FÓRMULA default


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    conn = sqlite3.connect(BRAIN)
    cur  = conn.cursor()

    # Add column if not exists
    try:
        cur.execute('ALTER TABLE rules ADD COLUMN sub_tipo TEXT')
        conn.commit()
        print('Column sub_tipo added to rules.')
    except sqlite3.OperationalError:
        print('Column sub_tipo already exists — updating.')

    # Load NEGOCIO rules
    cur.execute('SELECT id, tipo, code FROM rules WHERE clase = "NEGOCIO"')
    rows = cur.fetchall()
    total = len(rows)
    print(f'Classifying {total} NEGOCIO rules…')

    updates = []
    from collections import Counter
    dist = Counter()

    for rule_id, tipo, code in rows:
        st = classify(code or '', tipo or '')
        dist[st] += 1
        updates.append((st, rule_id))

    cur.executemany('UPDATE rules SET sub_tipo = ? WHERE id = ?', updates)
    conn.commit()
    conn.close()

    print(f'\nDistribution:')
    for k, v in sorted(dist.items(), key=lambda x: -x[1]):
        print(f'  {k:25s} {v:5d}  ({v/total*100:.1f}%)')


if __name__ == '__main__':
    main()

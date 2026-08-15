"""
S13 — Conversión centavos → pesos: complemento inverso de S8 (pesos × 100).
Detecta reglas donde un valor almacenado en centavos (INTEGER) se convierte
a pesos mediante división entre 100, patrón recurrente en procesamiento de
archivos de tarjeta (MasterCard, INTERCARD) y doméstica (bdidomi, bdicobranza).

Actualiza sub_tipo = 'CONVERSIÓN_UNIDAD' y enriquece business_name con
tokens 'centavos pesos' para mejorar coherencia semántica.

Metodología S13: /100 en contexto monetario ≠ aritmética genérica;
en migración el adapter de medio de pago debe declarar la unidad canónica
(pesos vs centavos) y aplicar la conversión en el boundary.
"""
import sqlite3, re, sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB = Path(__file__).parent.parent / "digital-brain" / "brain.db"

# Señales de contexto monetario en el nombre de la variable resultado
MONEY_PREFIXES = re.compile(r"^(m|d|v[a-z]*monto|v[a-z]*importe|v[a-z]*saldo|v[a-z]*precio)", re.I)
# Patrón de división entre 100 (con o sin espacios, con ::MONEY cast)
DIV_100_PAT = re.compile(r"(?:::MONEY|::DECIMAL\(\d+,\d+\))?\s*/\s*100\b")
# Patrón para extraer el nombre de la variable destino
LET_VAR_PAT = re.compile(r"(?:LET\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*=", re.I)

# Keywords de contexto monetario en business_name o code cercano
MONEY_KEYWORDS = re.compile(
    r"\b(tarjet|mastercard|intercard|importe|monto|saldo|centavo|pesos|dinero|cargo|abono|cob[a-z]*)\b",
    re.I,
)

# Sub-tipos elegibles (sólo conversión dentro de cálculos)
ELIGIBLE = (
    "CÁLCULO_ARITMÉTICO",
    "CÁLCULO_MONETARIO",
    "CÁLCULO_INVERSIÓN",
    None,
)


def is_div100_candidate(code: str, business_name: str) -> bool:
    """Determina si la regla es una conversión centavos→pesos."""
    if not code or not DIV_100_PAT.search(code):
        return False
    # Verificar contexto monetario: prefijo de variable O keyword en código/nombre
    m = LET_VAR_PAT.match(code.strip())
    if m and MONEY_PREFIXES.match(m.group(1)):
        return True
    if MONEY_KEYWORDS.search(code) or MONEY_KEYWORDS.search(business_name or ""):
        return True
    return False


def build_new_name(business_name: str, var_name: str | None) -> str:
    """Enriquece business_name con tokens centavos/pesos si no están."""
    bn = business_name or ""
    if "centavos" in bn.lower() and "pesos" in bn.lower():
        return bn  # ya tiene los tokens
    suffix = " — conversión centavos→pesos"
    if var_name and var_name.lower() not in bn.lower():
        suffix = f" ({var_name})" + suffix
    return bn + suffix


def main():
    con = sqlite3.connect(DB)
    cur = con.cursor()

    # Cargar reglas elegibles con división entre 100
    placeholders = ",".join("?" for _ in ELIGIBLE if _ is not None)
    none_clause = "OR sub_tipo IS NULL" if None in ELIGIBLE else ""
    cur.execute(
        f"SELECT id, sp, db, code, business_name, sub_tipo FROM rules "
        f"WHERE (sub_tipo IN ({placeholders}) {none_clause}) "
        f"AND (code LIKE '% / 100%' OR code LIKE '%/100%' OR code LIKE '%::MONEY%')",
        [t for t in ELIGIBLE if t is not None],
    )
    rows = cur.fetchall()
    print(f"Reglas con patrón /100 o ::MONEY encontradas: {len(rows)}")

    updates = 0
    for rid, sp, db, code, business_name, sub_tipo in rows:
        if not is_div100_candidate(code, business_name):
            continue

        # Extraer nombre de la variable resultado
        m = LET_VAR_PAT.match((code or "").strip())
        var_name = m.group(1) if m else None

        # ADR-SPE-AM-010: solo sub_tipo; business_name lo genera la síntesis LLM
        cur.execute(
            "UPDATE rules SET sub_tipo='CONVERSIÓN_UNIDAD' WHERE id=?",
            (rid,),
        )
        print(f"  [{sp}] {(code or '')[:70]}")
        updates += 1

    con.commit()
    con.close()
    print(f"\nActualizados {updates} reglas → sub_tipo='CONVERSIÓN_UNIDAD'")


if __name__ == "__main__":
    main()

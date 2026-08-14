"""
S12 — Fórmula Canónica Compartida: detector de capacidades de extracción.
Identifica fórmulas SPL idénticas que aparecen en ≥MIN_SPS stored procedures
distintos, señal de una capacidad de negocio implementada como copy-paste.

Salida: actualiza brain.db con sub_tipo='CAPACIDAD_COMPARTIDA' y anota
el número de SPs que comparten la fórmula en business_name.

Metodología S12: cuando el mismo fingerprint de fórmula aparece en ≥3 SPs,
en migración ese bloque debe extraerse a un servicio compartido, no duplicarse.
"""
import sqlite3, re, sys, collections
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB = Path(__file__).parent.parent / "digital-brain" / "brain.db"
MIN_SPS = 3  # umbral mínimo de SPs distintos

# Sub-tipos de cálculo candidatos para fórmula compartida
CALC_TIPOS = (
    "CÁLCULO_ARITMÉTICO",
    "CÁLCULO_MONETARIO",
    "CÁLCULO_PORCENTUAL",
    "CÁLCULO_INVERSIÓN",
    "CÁLCULO_FISCAL",
    "CÁLCULO_INTERÉS",
    "CÁLCULO_FECHA",
)

FUNCTIONS = {
    "ROUND", "TRUNC", "MOD", "ABS", "DECODE", "NVL", "EXTEND",
    "TODAY", "CURRENT", "INTERVAL", "DATE", "YEAR", "MONTH", "DAY",
    "CAST", "UNITS", "MONEY", "INTEGER", "FLOAT", "DECIMAL", "CHAR",
    "LENGTH", "SUBSTR", "TRIM", "UPPER", "LOWER", "IIF",
}


def normalize_formula(expr: str) -> str:
    """
    Normaliza la RHS de una asignación SPL:
    - Elimina literales de cadena
    - Reemplaza identificadores de variables (inicio minúscula, ≥2 chars) con VAR
    - Conserva operadores, paréntesis, constantes numéricas y funciones SPL
    """
    # Eliminar comentarios inline
    expr = re.sub(r"\s*--.*$", "", expr)
    # Eliminar literales de cadena
    expr = re.sub(r"'[^']*'", "STR", expr)
    # Reemplazar variables húngaras y nombres de columna (inicio minúscula, ≥2)
    # pero NO funciones conocidas (inicio mayúscula) ni keywords (TODO CAPS)
    def replace_id(m):
        token = m.group(0)
        if token.upper() in FUNCTIONS:
            return token.upper()
        if token[0].isupper():
            return token  # función o constante
        if len(token) >= 2:
            return "VAR"
        return token

    expr = re.sub(r"\b[a-zA-Z_][a-zA-Z0-9_]*\b", replace_id, expr)
    # Normalizar espacios
    expr = re.sub(r"\s+", " ", expr).strip()
    # Eliminar punto y coma al final
    expr = expr.rstrip(";").strip()
    return expr


def extract_rhs(code: str) -> str | None:
    """Extrae la parte derecha de una asignación LET o bare assignment."""
    m = re.match(
        r"(?:LET\s+)?[a-zA-Z_][a-zA-Z0-9_]*\s*=\s*(.+)",
        code.strip(),
        re.IGNORECASE,
    )
    if not m:
        return None
    rhs = m.group(1).strip().rstrip(";").strip()
    # Descartar asignaciones triviales: literales simples o una sola variable
    if re.fullmatch(r"['\"]?\w+['\"]?", rhs):
        return None
    return rhs


def main():
    con = sqlite3.connect(DB)
    cur = con.cursor()

    placeholders = ",".join("?" for _ in CALC_TIPOS)
    cur.execute(
        f"SELECT id, sp, db, code, business_name, sub_tipo FROM rules "
        f"WHERE sub_tipo IN ({placeholders})",
        CALC_TIPOS,
    )
    rows = cur.fetchall()
    print(f"Reglas de cálculo analizadas: {len(rows)}")

    # Agrupar por fórmula normalizada
    formula_groups: dict[str, list] = collections.defaultdict(list)
    skipped = 0
    for rid, sp, db, code, business_name, sub_tipo in rows:
        if not code:
            skipped += 1
            continue
        rhs = extract_rhs(code)
        if not rhs or len(rhs) < 8:
            skipped += 1
            continue
        norm = normalize_formula(rhs)
        # Requiere ≥3 tokens VAR: descarta fórmulas triviales (VAR*VAR, VAR/VAR)
        # que son demasiado genéricas para señalar una capacidad compartida real.
        var_count = norm.count("VAR")
        if var_count < 3:
            skipped += 1
            continue
        formula_groups[norm].append((rid, sp, db, business_name, sub_tipo, rhs))

    print(f"  Fórmulas normalizadas únicas: {len(formula_groups)}")
    print(f"  Descartadas (triviales/sin vars): {skipped}")

    # Filtrar por umbral de SPs distintos
    shared = {
        norm: entries
        for norm, entries in formula_groups.items()
        if len({e[1] for e in entries}) >= MIN_SPS
    }
    print(f"  Fórmulas compartidas (≥{MIN_SPS} SPs): {len(shared)}\n")

    updates = 0
    for norm, entries in sorted(
        shared.items(), key=lambda x: len({e[1] for e in x[1]}), reverse=True
    ):
        distinct_sps = sorted({e[1] for e in entries})
        n_sps = len(distinct_sps)
        sp_preview = ", ".join(distinct_sps[:4])
        if n_sps > 4:
            sp_preview += f" +{n_sps - 4}"
        # Muestra el RHS original del primer ejemplo
        example_rhs = entries[0][5][:70]
        print(f"  [{n_sps:2d} SPs] {norm[:65]}")
        print(f"          Ejemplo: {example_rhs}")
        print(f"          SPs: {sp_preview}")

        for rid, sp, db, bn, st, rhs in entries:
            # S12: NO cambia sub_tipo — sólo agrega el marcador de capacidad compartida
            # en business_name para mejorar coherencia semántica y señalar
            # candidatos de extracción en el plan de migración.
            tag = f" — capacidad compartida ({n_sps} SPs)"
            if "— capacidad compartida" not in (bn or ""):
                new_bn = (bn or "") + tag
            else:
                new_bn = re.sub(r"— capacidad compartida \(\d+ SPs\)", tag.lstrip(), bn)
            cur.execute(
                "UPDATE rules SET business_name=? WHERE id=?",
                (new_bn, rid),
            )
            updates += 1

    con.commit()
    con.close()
    print(f"\nActualizados {updates} business_names con marcador '— capacidad compartida (N SPs)'")


if __name__ == "__main__":
    main()

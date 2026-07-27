"""
enrich-rules.py — Ola 4: parcha campos por regla (Tipo regla SBVR + Veredicto)
sin tocar el resto del cuerpo. Reutilizable por capacidad.
Uso: python enrich-rules.py <archivo.md>   (el MAP es por-archivo, abajo)
"""
import re, sys, os

BASE = os.path.dirname(os.path.abspath(__file__))
RD = os.path.join(BASE, "rules-catalog")

# Clasificación SBVR + veredicto del analista para las 34 reglas de arquitectura/lógica de P109.
# SBVR: Restricción · Derivación · Cálculo · Habilitación · Clasificación / Mapeo · Definición
VAL = "VALIDADO (analista dt-mainframe-analyst)"
REG = "VALIDADO (analista) — dimensión regulatoria: ver SME (RN-026 partida doble / sector CNBV)"
P109_MAP = {
    "RN-S151-021": ("Restricción", VAL),
    "RN-S151-022": ("Derivación", VAL),
    "RN-S151-023": ("Restricción", VAL),
    "RN-S151-024": ("Derivación", VAL),
    "RN-S151-029": ("Clasificación / Mapeo", VAL),
    "RN-S151-030": ("Derivación", VAL),
    "RN-S151-031": ("Clasificación / Mapeo", VAL),
    "RN-S151-032": ("Clasificación / Mapeo", VAL),
    "RN-S151-033": ("Clasificación / Mapeo", VAL),
    "RN-S151-035": ("Habilitación", VAL),
    "RN-S151-036": ("Habilitación", VAL),
    "RN-S151-037": ("Habilitación", VAL),
    "RN-S151-039": ("Clasificación / Mapeo", VAL),
    "RN-S151-040": ("Restricción", VAL),
    "RN-S151-041": ("Clasificación / Mapeo", REG),
    "RN-S151-042": ("Clasificación / Mapeo", VAL),
    "RN-S151-043": ("Habilitación", VAL),
    "RN-S151-044": ("Derivación", VAL),
    "RN-S151-045": ("Clasificación / Mapeo", VAL),
    "RN-S151-046": ("Derivación", VAL),
    "RN-S151-047": ("Clasificación / Mapeo", VAL),
    "RN-S151-048": ("Habilitación", VAL),
    "RN-S151-049": ("Clasificación / Mapeo", VAL),
    "RN-S151-050": ("Habilitación", VAL),
    "RN-S151-051": ("Restricción", REG),
    "RN-S151-052": ("Derivación", VAL),
    "RN-S151-053": ("Clasificación / Mapeo", VAL),
    "RN-S151-054": ("Cálculo", VAL),
    "RN-S151-055": ("Derivación", VAL),
    "RN-S151-056": ("Habilitación", VAL),
    "RN-S151-057": ("Definición", VAL),
    "RN-S151-058": ("Derivación", VAL),
    "RN-S151-059": ("Clasificación / Mapeo", VAL),
    "RN-S151-060": ("Definición", VAL),
}

# BC-09 Ajustes GL (P312+P330+P360). CONT = requiere SME Contable (semántica contable/saldos).
CONT = "En validación — SME Contabilidad Bancaria (semántica contable/saldos)"
BC09_MAP = {
    "RN-S151-710": ("Definición", VAL),
    "RN-S151-711": ("Derivación", VAL),
    "RN-S151-712": ("Derivación", VAL),
    "RN-S151-713": ("Restricción", CONT),
    "RN-S151-714": ("Restricción", CONT),
    "RN-S151-715": ("Cálculo", CONT),
    "RN-S151-716": ("Definición", VAL),
    "RN-S151-717": ("Derivación", VAL),
    "RN-S151-718": ("Habilitación", VAL),
    "RN-S151-720": ("Derivación", VAL),
    "RN-S151-721": ("Restricción", VAL),
    "RN-S151-722": ("Derivación", VAL),
    "RN-S151-723": ("Restricción", CONT),
    "RN-S151-724": ("Restricción", CONT),
    "RN-S151-725": ("Definición", VAL),
    "RN-S151-726": ("Derivación", VAL),
    "RN-S151-727": ("Definición", CONT),
    "RN-S151-728": ("Cálculo", VAL),
    "RN-S151-729": ("Clasificación / Mapeo", VAL),
    "RN-S151-730": ("Restricción", VAL),
    "RN-S151-731": ("Derivación", VAL),
    "RN-S151-732": ("Restricción", VAL),
    "RN-S151-735": ("Derivación", VAL),
    "RN-S151-736": ("Derivación", VAL),
    "RN-S151-737": ("Restricción", VAL),
    "RN-S151-738": ("Restricción", VAL),
    "RN-S151-739": ("Derivación", VAL),
    "RN-S151-740": ("Clasificación / Mapeo", VAL),
    "RN-S151-741": ("Clasificación / Mapeo", VAL),
    "RN-S151-742": ("Clasificación / Mapeo", CONT),
    "RN-S151-743": ("Clasificación / Mapeo", VAL),
    "RN-S151-744": ("Cálculo", CONT),
    "RN-S151-745": ("Clasificación / Mapeo", VAL),
    "RN-S151-746": ("Restricción", VAL),
    "RN-S151-747": ("Cálculo", VAL),
    "RN-S151-748": ("Derivación", VAL),
    "RN-S151-749": ("Restricción", VAL),
}

FILE_MAPS = {
    "rules-s151.md": P109_MAP,
    "rules-s151-p312-p330-p360.md": BC09_MAP,
}

PLACEHOLDER = "Consulta análisis SBVR (dt-mainframe-analyst)"

def enrich(fname, mapping):
    fp = os.path.join(RD, fname)
    txt = open(fp, encoding="utf-8").read()
    parts = re.split(r'(?m)(?=^#{2,3} RN-S(?:151|500)-\d+)', txt)
    out = []; n = 0
    for part in parts:
        hm = re.match(r'#{2,3} (RN-S(?:151|500)-\d+)', part)
        if hm and hm.group(1) in mapping:
            sbvr, veredicto = mapping[hm.group(1)]
            # Solo parchea si sigue en placeholder (idempotente, no pisa lo ya enriquecido)
            if PLACEHOLDER in part:
                part = part.replace(
                    f"| **Tipo regla** | {PLACEHOLDER} |",
                    f"| **Tipo regla** | {sbvr} |")
                part = re.sub(r'\| \*\*Veredicto\*\* \| PENDIENTE SME \|',
                              f"| **Veredicto** | {veredicto} |", part, count=1)
                n += 1
        out.append(part)
    open(fp, "w", encoding="utf-8").write("".join(out))
    print(f"Enriquecidas {n} reglas en {fname}")

if __name__ == "__main__":
    fname = sys.argv[1] if len(sys.argv) > 1 else "rules-s151.md"
    if fname not in FILE_MAPS:
        print(f"Sin mapa para {fname}. Disponibles: {list(FILE_MAPS)}"); sys.exit(1)
    enrich(fname, FILE_MAPS[fname])

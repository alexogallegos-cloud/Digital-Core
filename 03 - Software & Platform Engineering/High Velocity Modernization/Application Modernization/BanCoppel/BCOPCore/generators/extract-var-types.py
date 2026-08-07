#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""extract-var-types.py — Extrae las declaraciones DEFINE del source SPL para construir
   el mapa autoritativo variable→tipo declarado (owner DT-Reglas + DBA IBM Informix).

Sirve para: (1) validar la notación húngara (¿el prefijo coincide con el tipo?),
(2) señal de lógica (MONEY→riesgo redondeo, DATE→temporal, SMALLINT/CHAR(1)→bandera),
(3) alimentar la columna expl_negocio.

Input:  source/BCOPCore/informix/*.sql   (12,882 SPs, ~1.2 GB)
Output: knowledge-base/vocabulary/variable-types.json  {sp: {var: tipo_normalizado}}
        + reporte de validación de prefijos húngaros (stdout)

SPE-AM-001 · DT-Reglas
"""
import re, os, io, sys, json, glob
from collections import Counter, defaultdict
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"

# DEFINE var TIPO;  |  DEFINE var LIKE tabla.col;  |  DEFINE a,b,c TIPO;
RE_DEFINE = re.compile(r'\bdefine\s+([a-z0-9_,\s]+?)\s+([a-z].*?);', re.I)

def norm_type(raw: str) -> str:
    t = raw.strip().lower()
    m = re.match(r'like\s+([a-z0-9_]+)\.([a-z0-9_]+)', t)
    if m: return 'LIKE:' + m.group(1) + '.' + m.group(2)
    if re.match(r'money|decimal|numeric|\bdec\b', t):        return 'MONEY'
    if re.match(r'datetime', t):                             return 'DATETIME'
    if re.match(r'date', t):                                 return 'DATE'
    if re.match(r'smallint|integer|\bint\b|serial|bigint|int8', t): return 'INT'
    if re.match(r'float|smallfloat|real|double', t):         return 'FLOAT'
    if re.match(r'char|varchar|nchar|nvarchar|lvarchar|text|character', t): return 'CHAR'
    if re.match(r'boolean|bool', t):                         return 'BOOL'
    return 'OTRO:' + t[:20]

def scope_body(var: str):
    """Quita prefijo de scope generado/estándar (x_, v_, w_...) y retorna (cuerpo, 1a-letra-tipo)."""
    v = var.lower()
    v = re.sub(r'^(x_|v_|w_|p_|g_|l_)', '', v)   # scope con underscore
    v = re.sub(r'^(v|w|p|g|l)(?=[a-z]{3})', '', v)  # scope sin underscore
    return v, (v[0] if v else '')

def main():
    files = glob.glob(SRC + "*.sql")
    sp_map = {}
    prefix_type = defaultdict(Counter)     # 1a letra del cuerpo → tipos declarados
    type_totals = Counter()
    n_vars = 0
    for i, fp in enumerate(files):
        try:
            txt = open(fp, encoding="utf-8", errors="replace").read()
        except Exception:
            continue
        sp = os.path.splitext(os.path.basename(fp))[0]
        vmap = {}
        for m in RE_DEFINE.finditer(txt):
            names, rawtype = m.group(1), m.group(2)
            typ = norm_type(rawtype)
            for nm in re.split(r'\s*,\s*', names.strip()):
                nm = nm.strip().lower()
                if not nm or ' ' in nm: continue
                vmap[nm] = typ
                body, first = scope_body(nm)
                if first.isalpha():
                    prefix_type[first][typ.split(':')[0]] += 1
                type_totals[typ.split(':')[0]] += 1
                n_vars += 1
        if vmap:
            sp_map[sp] = vmap
        if (i + 1) % 2000 == 0:
            print(f"  ...{i+1:,}/{len(files):,} archivos", flush=True)

    out = BASE + "knowledge-base/vocabulary/variable-types.json"
    json.dump(sp_map, open(out, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))

    print(f"\nArchivos SPL       : {len(files):,}")
    print(f"SPs con DEFINE     : {len(sp_map):,}")
    print(f"Variables tipadas  : {n_vars:,}")
    print(f"\nDistribución de tipos declarados:")
    for t, c in type_totals.most_common(12):
        print(f"  {t:12} {c:8,}  ({c/max(n_vars,1)*100:4.1f}%)")

    print(f"\nValidación de notación húngara — ¿el prefijo predice el tipo? (top 12 prefijos)")
    print(f"  {'pfx':3} {'total':>7}  tipo dominante (consistencia)")
    for pfx, cnt in sorted(prefix_type.items(), key=lambda x: -sum(x[1].values()))[:12]:
        tot = sum(cnt.values())
        top_t, top_c = cnt.most_common(1)[0]
        cons = top_c / tot * 100
        verdict = 'CONSISTENTE (tipo húngaro real)' if cons >= 70 else 'AMBIGUO (no es tipo, es semántica/ruido)'
        print(f"  {pfx:3} {tot:7,}  {top_t:8} {cons:4.0f}%  → {verdict}")

    print(f"\nSaved: {out}")

if __name__ == "__main__":
    main()

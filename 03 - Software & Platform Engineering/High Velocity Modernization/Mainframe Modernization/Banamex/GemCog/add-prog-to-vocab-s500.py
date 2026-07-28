#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
add-prog-to-vocab-s500.py
=========================
Agrega columna `Programas` a vocab-s500.md.

Para cada término del vocabulario S500, lista qué programas/librerías
del sistema lo usan o lo definen, combinando tres fuentes:

  Fuente A — Regex sobre columna Significado (menciones explícitas)
  Fuente B — Nodos del dependency-graph (matching exacto y por prefijo)
  Fuente C — Edges del dependency-graph (quién depende de cada nodo)

Idempotente: si la columna Programas ya existe, no la duplica.
"""

import re
import json
import os
from collections import defaultdict

# ── Rutas ─────────────────────────────────────────────────────────────────────
BASE = (
    r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
    r"\03 - Software & Platform Engineering\High Velocity Modernization"
    r"\Mainframe Modernization\Banamex\GemCog\data\S500"
)
VOCAB_PATH    = os.path.join(BASE, "vocab-s500.md")
SOULS_PATH    = os.path.join(BASE, "souls-s500.json")
DEPGRAPH_PATH = os.path.join(BASE, "dependency-graph-s500.json")

# ── Regex para extraer identificadores de programas/librerías ─────────────────
# Captura: P010, P010_PRO, P630-TARINTERCAM, L010_CONTROL, L039_ACCESOBD04,
#          S151REGISTRA, WFL LINEA, WFL LOTE, REORG_GARBAGE_S500*, L002R2-R5
PROG_RE = re.compile(
    r'\b('
    r'P\d{3}(?:[_-][A-Z0-9]+)*'       # P010, P010_PRO, P630-TARINTERCAM
    r'|L\d{3}(?:[_A-Z0-9]+)*'          # L010_CONTROL, L039_ACCESOBD04, L050
    r'|S151REGISTRA'                    # interfaz GL explícita
    r'|WFL[ _]+(?:LINEA|LOTE|REORG\w*)' # WFL LINEA, WFL_LOTE, WFL REORG...
    r'|REORG_GARBAGE_S500\w*'           # REORG_GARBAGE_S500BD04TARJETAS
    r'|L002R[2-5]'                      # L002R2..L002R5
    r')\b',
    re.IGNORECASE
)

# Prefijos de nodos que se consideran "programas" válidos para la columna
PROG_PREFIXES = re.compile(
    r'^(P\d{3}|L\d{3}|WFL|REORG|S151)',
    re.IGNORECASE
)

def normalize_prog(p: str) -> str:
    """Normaliza un identificador de programa a mayúsculas sin espacios."""
    return p.upper().strip().replace(' ', '_')


# ── Paso 1: Cargar dependency-graph-s500.json ─────────────────────────────────
print("► Cargando dependency-graph-s500.json …")
with open(DEPGRAPH_PATH, 'r', encoding='utf-8') as f:
    depgraph = json.load(f)

# Todos los node IDs (programas, librerías, data areas, includes)
all_node_ids: set = {n['id'] for n in depgraph.get('nodes', [])}

# Nodos que son programas/librerías reales (excluye data areas DASDL y ext. libs)
prog_node_ids: set = {
    n['id'] for n in depgraph.get('nodes', [])
    if PROG_PREFIXES.match(n['id'])
}

# dependents_of[X] = conjunto de nodos que dependen de X (X es usado por ellos)
dependents_of: dict = defaultdict(set)
# uses_of[X]       = conjunto de nodos de los que X depende
uses_of: dict = defaultdict(set)

for edge in depgraph.get('edges', []):
    frm = edge.get('from', '').strip()
    to  = edge.get('to',   '').strip()
    if frm and to:
        dependents_of[to].add(frm)
        uses_of[frm].add(to)

print(f"  Nodos totales: {len(all_node_ids)}")
print(f"  Nodos-programa (P*/L*): {len(prog_node_ids)}")
print(f"  Edges: {len(depgraph.get('edges', []))}")


# ── Paso 2: Cargar souls-s500.json (lista canónica de programas) ──────────────
print("► Cargando souls-s500.json …")
with open(SOULS_PATH, 'r', encoding='utf-8') as f:
    souls = json.load(f)

soul_programs: set = set()
for autor in souls.get('autores', []):
    for prog in autor.get('programas', []):
        soul_programs.add(prog.upper())
print(f"  Programas en souls: {len(soul_programs)}")


# ── Helpers ───────────────────────────────────────────────────────────────────
def extract_progs_from_text(text: str) -> set:
    """Extrae identificadores de programa desde texto libre (Fuente A)."""
    found = set()
    for m in PROG_RE.finditer(text):
        p = normalize_prog(m.group(0))
        found.add(p)
    return found


def is_valid_prog(p: str) -> bool:
    """Filtra solo identificadores que parecen programas/librerías reales."""
    return bool(PROG_PREFIXES.match(p))


# Regex para extraer "src-PNNN" o "src-LNNN" de la columna Evidencia
SRC_EVID_RE = re.compile(r'\bsrc-([PL]\d{3}(?:[_-][A-Z0-9]+)*)\b', re.IGNORECASE)

# Short-form prefix pattern (e.g. P010, L035)
SHORT_PROG_RE = re.compile(r'^[PL]\d{3}$')


def get_programs_for_row(term_raw: str, significado: str, evidencia: str = '') -> list:
    """
    Construye la lista de programas para una fila del vocabulario.

    term_raw  : contenido de la columna Termino (puede tener backticks)
    significado: contenido de la columna Significado
    evidencia : contenido de la columna Evidencia (opcional)
    """
    term = term_raw.strip('`').upper()
    progs: set = set()

    # ── Fuente A: regex sobre Significado ──────────────────────────────────────
    progs |= extract_progs_from_text(significado)

    # ── Fuente A2: el propio término puede ser un identificador de programa ─────
    #   (ej. término `P010` → agrega P010)
    progs |= extract_progs_from_text(term)

    # ── Fuente A3: columna Evidencia — patrón "src-PNNN" / "src-LNNN" ─────────
    #   Evidencia "src-p130" indica explícitamente qué programa define el campo
    for m in SRC_EVID_RE.finditer(evidencia):
        progs.add(normalize_prog(m.group(1)))

    # ── Fuente B: matching exacto del término con un nodo del dep-graph ─────────
    if term in all_node_ids:
        if is_valid_prog(term):
            progs.add(term)                  # el término ES un programa/librería
        # Agrega todos los nodos que dependen de este nodo (usuarios del término)
        for dep in dependents_of.get(term, set()):
            if is_valid_prog(dep):
                progs.add(dep)

    # ── Fuente B2: el término es prefijo de un nodo (ej. L035 → L035_MAPLI) ────
    #   Solo para identificadores cortos tipo P\d{3} o L\d{3}
    if SHORT_PROG_RE.match(term):
        for node_id in prog_node_ids:
            if node_id.startswith(term):     # L035 → L035_MAPLI, L035_SOMETHING
                progs.add(node_id)
                # Y los usuarios de ese nodo
                for dep in dependents_of.get(node_id, set()):
                    if is_valid_prog(dep):
                        progs.add(dep)

    # ── Fuente C: edge targets no declarados como nodos propios ────────────────
    #   (p.ej. LOCSUP, CTLVER aparecen como "to" en edges pero son libs externas)
    #   Si el término coincide con un edge target, sus dependents son usuarios S500
    dep_from_edges = dependents_of.get(term, set())
    for dep in dep_from_edges:
        if is_valid_prog(dep):
            progs.add(dep)

    # ── Filtro final: solo identificadores válidos ─────────────────────────────
    valid = {p for p in progs if is_valid_prog(p)}
    return sorted(valid)


# ── Paso 3: Leer vocab-s500.md ────────────────────────────────────────────────
print(f"► Leyendo {VOCAB_PATH} …")
with open(VOCAB_PATH, 'r', encoding='utf-8') as f:
    lines = f.readlines()
print(f"  Líneas totales: {len(lines)}")


# ── Paso 4: Idempotencia — verificar si ya existe la columna ──────────────────
header_line_idx = None
for i, line in enumerate(lines):
    if line.startswith('| #') and 'Termino' in line:
        header_line_idx = i
        break

if header_line_idx is None:
    raise RuntimeError("ERROR: No se encontró la línea de cabecera de la tabla.")

programas_already_exists = 'Programas' in lines[header_line_idx]

if programas_already_exists:
    print("⚠  La columna Programas ya existe — se regenerará con lógica actualizada.")
    # Strip the existing Programas column from every relevant line so the
    # main loop can re-add it cleanly (avoids duplicating the column).
    stripped_lines = []
    for line in lines:
        s = line.rstrip('\n').rstrip('\r')
        # Header: rebuild without Programas (handles accumulated | | artifacts)
        if s.startswith('| #') and 'Termino' in s and 'Programas' in s:
            col_names = [c.strip() for c in s.split('|')]
            col_names = [c for c in col_names if c and c != 'Programas']
            s = '| ' + ' | '.join(col_names) + ' |'
            stripped_lines.append(s + '\n')
        # Separator line: remove trailing |---|
        elif s.startswith('|---') and s.endswith('---|'):
            # Count existing separator segments
            s = s[:-4]  # drop the last ---|
            stripped_lines.append(s + '\n')
        # Data rows: remove last column value
        elif s.startswith('| ') and s.endswith('|') and '|' in s[2:]:
            # Find the last | before the Programas value
            parts = s.split('|')
            # Last part before final '' is the Programas value → drop it
            if len(parts) >= 10:
                # Rebuild without the last value column
                s = '|'.join(parts[:-2]) + '|'
            stripped_lines.append(s + '\n')
        else:
            stripped_lines.append(line)
    lines = stripped_lines
    print(f"  Columna preexistente eliminada para regeneración.")

separator_line_idx = header_line_idx + 1

print(f"  Cabecera en línea {header_line_idx + 1}, separador en {separator_line_idx + 1}")


# ── Paso 5: Procesar filas y construir nuevo MD ───────────────────────────────
print("► Procesando filas …")

new_lines = []
stats_total      = 0
stats_with_progs = 0
prog_freq        = defaultdict(int)
warnings         = []

for i, line in enumerate(lines):
    stripped = line.rstrip('\n').rstrip('\r')

    # ── Cabecera de tabla ──────────────────────────────────────────────────────
    if i == header_line_idx:
        new_lines.append(stripped + ' Programas |\n')
        continue

    # ── Línea separadora |---|...|--- ─────────────────────────────────────────
    if i == separator_line_idx:
        new_lines.append(stripped + '---|' + '\n')
        continue

    # ── Filas de datos ────────────────────────────────────────────────────────
    if i > separator_line_idx and stripped.startswith('|') and stripped.endswith('|'):
        parts = stripped.split('|')
        # Estructura esperada:
        # [0]=''  [1]=# [2]=Termino [3]=Freq [4]=Cat [5]=Conf [6]=Evid [7]=Sig [8]=''
        if len(parts) >= 9:
            term_raw    = parts[2].strip()
            evidencia   = parts[6].strip()
            significado = parts[7].strip()

            try:
                progs = get_programs_for_row(term_raw, significado, evidencia)
            except Exception as e:
                warnings.append(f"Línea {i+1}: error procesando '{term_raw}': {e}")
                progs = []

            stats_total += 1
            if progs:
                stats_with_progs += 1
                prog_str = ' · '.join(progs)
                for p in progs:
                    prog_freq[p] += 1
            else:
                prog_str = '—'

            new_lines.append(stripped + f' {prog_str} |\n')
        else:
            # Fila con estructura inesperada — agregar vacío para no romper tabla
            warnings.append(f"Línea {i+1}: estructura inesperada ({len(parts)} partes), se agrega '—'")
            new_lines.append(stripped + ' — |\n')
        continue

    # ── Cualquier otra línea (metadata, líneas en blanco, etc.) ──────────────
    new_lines.append(line)


# ── Paso 6: Escribir resultado ────────────────────────────────────────────────
print(f"► Escribiendo vocab-s500.md actualizado …")
with open(VOCAB_PATH, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print(f"  Escrito: {len(new_lines)} líneas")


# ── Reporte ───────────────────────────────────────────────────────────────────
print()
print("=" * 65)
print("  RESULTADO — Columna Programas agregada a vocab-s500.md")
print("=" * 65)
pct = 100.0 * stats_with_progs / max(1, stats_total)
print(f"  Total filas procesadas     : {stats_total:,}")
print(f"  Con ≥1 programa            : {stats_with_progs:,}  ({pct:.1f}%)")
print(f"  Sin programas (—)          : {stats_total - stats_with_progs:,}")

print()
print("  TOP 10 programas más frecuentes en el vocabulario:")
top10 = sorted(prog_freq.items(), key=lambda x: -x[1])[:10]
for rank, (prog, count) in enumerate(top10, 1):
    print(f"    {rank:2}. {prog:<30} {count:5} términos")

if warnings:
    print()
    print(f"  ADVERTENCIAS ({len(warnings)}):")
    for w in warnings[:20]:
        print(f"    • {w}")
    if len(warnings) > 20:
        print(f"    … y {len(warnings)-20} advertencias más")
else:
    print()
    print("  Sin advertencias.")

# ── Verificación: mostrar primeras 5 filas resultado ─────────────────────────
print()
print("  VERIFICACIÓN — primeras 5 filas del resultado:")
print("  " + "-" * 61)
count_shown = 0
for line in new_lines:
    stripped = line.rstrip()
    if stripped.startswith('| ') and count_shown < 5:
        if '| #' in stripped and 'Termino' in stripped:
            print("  " + stripped)
            continue
        if '|---|' in stripped:
            continue
        print("  " + stripped[:120] + ("…" if len(stripped) > 120 else ""))
        count_shown += 1
print("=" * 65)

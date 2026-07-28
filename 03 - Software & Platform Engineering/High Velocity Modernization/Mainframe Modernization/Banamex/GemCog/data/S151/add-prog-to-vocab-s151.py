#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
add-prog-to-vocab-s151.py
=========================
Agrega columna Programas a vocab-s151.md con tres fuentes:
  Fuente A - Regex sobre columna Significado de cada fila del vocab
  Fuente B - souls-s151.json (autores->programas; enriquece coverage de nombres de prog)
  Fuente C - rules-s151*.md  (tablas Vocabulario relacionado / campo COBOL -> programa)

Salida: sobreescribe vocab-s151.md (idempotente si ya existe columna Programas)
"""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

import re
import json
import os
import glob
from collections import defaultdict, Counter

# ── rutas ─────────────────────────────────────────────────────────────────────
BASE = os.path.dirname(os.path.abspath(__file__))
GEMCOG = os.path.join(BASE, "..", "..")          # …/GemCog/
RULES_DIR = os.path.join(GEMCOG, "rules-catalog")

VOCAB_PATH = os.path.join(BASE, "vocab-s151.md")
SOULS_PATH = os.path.join(BASE, "souls-s151.json")
DEP_PATH   = os.path.join(BASE, "dependency-graph-s151.json")

# ── regex de programas ─────────────────────────────────────────────────────────
PROG_RE = re.compile(
    r'\b('
    r'P\d{3}(?:[_-][A-Z0-9]+)*'   # P010, P010_S151, P199
    r'|L\d{3}(?:[_A-Z0-9]+)*'     # L030, L002R2, L002R5
    r'|S151REGISTRA'
    r'|L002R[2-5]'
    r')\b'
)

# regex de programa en línea de tabla de reglas
# soporta:  | **Programa(s)** | P010 |
#           | **Programa(s) fuente** | P130 · P131 |
#           | Programa(s) | P655 |
RULE_PROG_RE = re.compile(
    r'\|\s*\*{0,2}Programa\(s\)(?:\s+fuente)?\*{0,2}\s*\|\s*([^|]+)\s*\|',
    re.IGNORECASE
)

# ── índice principal term→set(programas) ──────────────────────────────────────
idx: dict[str, set[str]] = defaultdict(set)
rules_contrib: dict[str, set[str]] = defaultdict(set)  # solo Fuente C

# =============================================================================
# FUENTE B — souls-s151.json  (lista canónica de nombres de programas)
# Propósito: sólo usamos la lista de IDs de programas para validar matches
# =============================================================================
canonical_programs: set[str] = set()
try:
    with open(SOULS_PATH, encoding="utf-8") as f:
        souls = json.load(f)
    for node in souls.get("nodes", []):
        pid = node.get("id", "")
        if pid:
            canonical_programs.add(pid)
    # también desde autores (si aplica)
    for autor in souls.get("autores", []):
        for p in autor.get("programas", []):
            canonical_programs.add(p)
except Exception as e:
    print(f"  [WARN] souls-s151.json: {e}")

try:
    with open(DEP_PATH, encoding="utf-8") as f:
        dep = json.load(f)
    for node in dep.get("nodes", []):
        pid = node.get("id", "")
        if pid:
            canonical_programs.add(pid)
except Exception as e:
    print(f"  [WARN] dependency-graph-s151.json: {e}")

print(f"[B] {len(canonical_programs)} programas canónicos cargados desde souls+dependency")

# =============================================================================
# FUENTE C — rules-s151*.md
# Extrae par (programas_del_bloque, términos_vocab) de cada bloque de regla
# =============================================================================

def extract_backtick_terms(line: str) -> list[str]:
    """Extrae términos envueltos en backticks del inicio de una celda de tabla."""
    return re.findall(r'`([^`]+)`', line)

def parse_rules_file(path: str) -> list[tuple[set[str], str]]:
    """
    Retorna lista de (set_de_programas, término_vocab) para cada relación
    encontrada en el archivo de reglas.
    """
    relations: list[tuple[set[str], str]] = []

    with open(path, encoding="utf-8") as f:
        content = f.read()

    # Divide en bloques por '---' (separador de regla)
    blocks = re.split(r'\n---+\n', content)

    for block in blocks:
        # Extraer programas del bloque
        prog_matches = RULE_PROG_RE.findall(block)
        block_progs: set[str] = set()
        for pm in prog_matches:
            # puede ser "P130 · P131" o "P010" o "P021, P103"
            for tok in re.split(r'[·,/\s]+', pm):
                tok = tok.strip().strip('*').strip()
                if tok and PROG_RE.match(tok):
                    block_progs.add(tok)

        if not block_progs:
            # Intento alternativo: buscar en el header del bloque (línea con Rango)
            # p.ej. "Programas**: P108 · P150"
            hdr_match = re.search(
                r'\*{0,2}Programas?\*{0,2}[:\s]+([A-Z0-9_·,\s\+]+)',
                block,
                re.IGNORECASE
            )
            if hdr_match:
                for tok in re.split(r'[·,+\s]+', hdr_match.group(1)):
                    tok = tok.strip()
                    if tok and PROG_RE.match(tok):
                        block_progs.add(tok)

        if not block_progs:
            continue

        # Detectar secciones de vocabulario relacionado
        vocab_section = False
        for line in block.splitlines():
            line_low = line.lower()
            if re.search(r'vocabulario\s+relacionado|vocabulario\s+en\s+la|campos?\s+involucrados|campos?\s+cobol', line_low):
                vocab_section = True
                continue

            # Salir de sección vocab si encontramos otra cabecera
            if vocab_section and re.match(r'\*{2}[A-Z]', line.strip()):
                vocab_section = False

            if vocab_section and line.strip().startswith('|'):
                terms = extract_backtick_terms(line)
                if terms:
                    # El primer término en la celda es el término vocab
                    term = terms[0].strip()
                    if term and not re.match(r'^(Campo|Término|Termino|Field|PIC|Tipo|Descripcion)$', term, re.I):
                        relations.append((block_progs, term))

    return relations


rules_files = glob.glob(os.path.join(RULES_DIR, "rules-s151*.md"))
print(f"[C] {len(rules_files)} archivos de reglas encontrados")

total_rules_relations = 0
for rf in sorted(rules_files):
    rels = parse_rules_file(rf)
    for progs, term in rels:
        for p in progs:
            idx[term].add(p)
            rules_contrib[term].add(p)
    total_rules_relations += len(rels)

print(f"[C] {total_rules_relations} relaciones termino<->programa extraidas de rules-catalog")

# =============================================================================
# LEER vocab-s151.md
# =============================================================================
with open(VOCAB_PATH, encoding="utf-8") as f:
    raw_lines = f.readlines()

# Verificar idempotencia
header_idx = None
for i, line in enumerate(raw_lines):
    if line.startswith('| #') or line.startswith('|#'):
        header_idx = i
        break

if header_idx is None:
    print("[ERROR] No se encontró la fila de encabezado en vocab-s151.md")
    raise SystemExit(1)

header_line = raw_lines[header_idx]
if 'Programas' in header_line:
    print("[OK] La columna 'Programas' ya existe en vocab-s151.md — script idempotente, sin cambios.")
    raise SystemExit(0)

sep_idx = header_idx + 1  # la línea |---|...

# Identificar columnas en el encabezado
# | # | Termino | Frecuencia | Categoria | Confianza | Evidencia | Significado | Alcance |
header_cols = [c.strip() for c in header_line.split('|')]
# Índice (1-based dentro de split) de cada columna de interés
try:
    termino_col  = next(i for i,c in enumerate(header_cols) if 'Termino' in c or 'Término' in c)
    signif_col   = next(i for i,c in enumerate(header_cols) if 'Significado' in c)
except StopIteration:
    print("[ERROR] No se encontraron columnas Termino/Significado")
    raise SystemExit(1)

print(f"[INFO] Columna Termino: idx={termino_col}, Significado: idx={signif_col}")

# =============================================================================
# FUENTE A — Regex sobre columna Significado
# (se aplica después de leer el vocab, antes de reescribir)
# =============================================================================
fuente_a_count = 0
data_rows_parsed = 0

for line in raw_lines[sep_idx + 1:]:
    if not line.strip().startswith('|'):
        continue
    cells = line.split('|')
    if len(cells) < signif_col + 1:
        continue

    raw_term = cells[termino_col].strip() if termino_col < len(cells) else ''
    term = re.sub(r'`', '', raw_term).strip()
    if not term or term == '#':
        continue

    data_rows_parsed += 1
    signif = cells[signif_col].strip() if signif_col < len(cells) else ''

    matches = PROG_RE.findall(signif)
    for m in matches:
        idx[term].add(m)
        fuente_a_count += 1

print(f"[A] {data_rows_parsed} filas analizadas, {fuente_a_count} referencias de programa extraídas del Significado")

# =============================================================================
# ACTUALIZAR vocab-s151.md
# =============================================================================
new_lines = []
prog_counter: Counter = Counter()
rows_with_prog = 0
rows_total = 0

for i, line in enumerate(raw_lines):
    if i == header_idx:
        # Agregar columna Programas antes del | final
        new_lines.append(line.rstrip().rstrip('|').rstrip() + ' | Programas |\n')
        continue

    if i == sep_idx:
        # Ajustar separador
        new_lines.append(line.rstrip().rstrip('|').rstrip() + ' | --- |\n')
        continue

    if i > sep_idx and line.strip().startswith('|'):
        cells = line.split('|')
        if len(cells) < signif_col + 1:
            new_lines.append(line)
            continue

        raw_term = cells[termino_col].strip() if termino_col < len(cells) else ''
        term = re.sub(r'`', '', raw_term).strip()

        if not term or term == '#':
            new_lines.append(line)
            continue

        rows_total += 1
        progs = sorted(idx.get(term, set()))

        if progs:
            rows_with_prog += 1
            for p in progs:
                prog_counter[p] += 1
            prog_str = ' · '.join(progs)
        else:
            prog_str = '—'

        # Insertar nueva celda antes del \n final
        stripped = line.rstrip()
        # Quitar el | trailing si existe
        if stripped.endswith('|'):
            new_line = stripped + f' {prog_str} |\n'
        else:
            new_line = stripped + f' | {prog_str} |\n'

        new_lines.append(new_line)
    else:
        new_lines.append(line)

# Escribir resultado
with open(VOCAB_PATH, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

# =============================================================================
# REPORTE
# =============================================================================
print("\n" + "="*65)
print("REPORTE — add-prog-to-vocab-s151.py")
print("="*65)
print(f"  Filas totales de datos  : {rows_total:,}")
print(f"  Filas con ≥1 programa   : {rows_with_prog:,}  ({100*rows_with_prog/max(rows_total,1):.1f}%)")
print(f"  Filas sin programa (—)  : {rows_total - rows_with_prog:,}")
print()
print("  Fuente A (regex Significado) aportó referencias de programa en el vocab")
print(f"    → {fuente_a_count} matches totales")
print()
print(f"  Fuente C (rules-catalog) aportó {total_rules_relations} relaciones término↔programa")
print(f"    → {len(rules_contrib)} términos únicos enriquecidos desde reglas")
print()
print("  Top 10 programas más frecuentes en vocabulario S151:")
for prog, cnt in prog_counter.most_common(10):
    bar = '#' * min(cnt, 40)
    print(f"    {prog:<12} {cnt:4d}  {bar}")

print()
print("  Muestra de 5 filas (primeras con programa asignado):")
sample_count = 0
for line in new_lines[sep_idx + 1:]:
    if not line.strip().startswith('|'):
        continue
    cells = line.split('|')
    if len(cells) < 2:
        continue
    term_cell = cells[termino_col].strip() if termino_col < len(cells) else ''
    prog_cell = cells[-2].strip() if len(cells) >= 2 else '—'
    if prog_cell and prog_cell != '—':
        print(f"    {term_cell:<35} → {prog_cell}")
        sample_count += 1
        if sample_count >= 5:
            break

print()
print(f"  vocab-s151.md actualizado exitosamente: {VOCAB_PATH}")
print("="*65)

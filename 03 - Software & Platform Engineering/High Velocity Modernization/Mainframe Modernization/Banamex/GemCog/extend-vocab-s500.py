#!/usr/bin/env python3
"""
extend-vocab-s500.py
Extiende vocab-s500.md con los campos WORKING-STORAGE de los programas S500
aún no cubiertos.

Versión: 1.0  Fecha: 2026-07-17
Autor: Claude Code (Accenture México — Digital Core / HVM)
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

# Forzar UTF-8 en stdout/stderr para evitar UnicodeEncodeError en Windows CP1252
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# ---------------------------------------------------------------------------
# CONFIGURACIÓN
# ---------------------------------------------------------------------------
SOURCE_DIR = Path(
    r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
    r"\03 - Software & Platform Engineering\High Velocity Modernization"
    r"\Mainframe Modernization\Banamex\S500\source\S500\extracted_source"
)

VOCAB_PATH = Path(
    r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
    r"\03 - Software & Platform Engineering\High Velocity Modernization"
    r"\Mainframe Modernization\Banamex\GemCog\data\S500\vocab-s500.md"
)

# Programas ya cubiertos → SKIP
ALREADY_COVERED = {
    "P130", "WOR", "WOR_CAN", "PRO", "PRO_CAN",
    "L010", "L020", "MAPLI_WOR", "MAPLI_PRO",
    "P010_MAS", "WOR_DAS", "L019_SALDOS",
}

# ---------------------------------------------------------------------------
# UTILIDADES DE CLASIFICACIÓN
# ---------------------------------------------------------------------------

def classify_pic(pic: str) -> str:
    """Clasifica un campo COBOL/copybook por su PIC clause."""
    p = pic.upper()
    if re.search(r'COMP-?3|PACKED', p):
        return 'CAMPO-DECIMAL'
    if re.search(r'COMP-?[0-9]?|BINARY', p):
        return 'CAMPO-COMP'
    if 'X' in p or p.startswith('A'):
        return 'CAMPO-ALFA'
    if 'V' in p:
        return 'CAMPO-DECIMAL'
    if '9' in p or p.startswith('S'):
        return 'CAMPO-NUMERICO'
    return 'CAMPO-ALFA'


def classify_dasdl_type(tipo: str) -> str:
    t = tipo.upper()
    if t in ('ALPHA',):
        return 'CAMPO-ALFA'
    if t == 'BOOLEAN':
        return 'CAMPO-COMP'
    return 'CAMPO-NUMERICO'  # NUMBER, INTEGER, REAL


# ---------------------------------------------------------------------------
# PARSERS
# ---------------------------------------------------------------------------

def extract_cobol_ws(source_text: str, program_id: str) -> list[dict]:
    """
    Extrae campos del DATA DIVISION de COBOL Unisys MCP.
    Soporta tanto PIC/PICTURE como PC (abreviatura Unisys) y VALUE/VA.
    """
    fields = []
    lines = source_text.splitlines()
    in_data_div = False
    in_ws = False
    continued_content = ''

    def try_extract_field(content, ctx_program_id):
        """Intenta extraer un campo de una línea de contenido."""
        result = []
        # Match: nivel + nombre de campo  (nivel 1–49, 77)
        m = re.match(
            r'^\s{0,10}(\d{1,2})\s+([A-Z][A-Z0-9-]+)(.*)',
            content, re.I
        )
        if not m:
            return result

        level_str = m.group(1)
        try:
            level = int(level_str)
        except ValueError:
            return result

        name = m.group(2).upper()
        rest = m.group(3)

        # Ignorar FILLER, niveles 66 y 88
        if name == 'FILLER' or level in (66, 88):
            return result

        # Solo campos hoja: debe tener PIC o PC explícito en rest
        # Unisys MCP usa abreviaciones: PC = PIC, VA = VALUE, OC = OCCURS
        pic_m = re.search(
            r'\b(?:PIC(?:TURE)?|PC)\b\s*(?:IS\s*)?'
            r'([SXA9()\d/.,-]+(?:\s*(?:COMP-?[0-9]*|BINARY|PACKED))?)',
            rest, re.I
        )
        if not pic_m:
            return result

        pic = pic_m.group(1).strip()
        # Eliminar espacios internos extraños
        pic = re.sub(r'\s+', '', pic)
        categoria = classify_pic(pic)

        result.append({
            'termino': name,
            'categoria': categoria,
            'confianza': 'alta',
            'evidencia': f'src-{ctx_program_id.lower()}',
            'significado': f'Campo nivel {level:02d} en {ctx_program_id} · PIC {pic}',
            'programa': ctx_program_id,
        })
        return result

    for raw_line in lines:
        # Las fuentes Unisys MCP tienen números de línea en columnas 1-6
        # La columna 7 (índice 6) es el indicador
        # El contenido real comienza en columna 8 (índice 7)
        # PERO algunos copybooks (COPY_ADMWIN) usan formato compacto con
        # 6 dígitos de número de línea + espacio + contenido (sin indicador de col 7)

        if len(raw_line) < 2:
            continue

        # Detectar si es formato con número de línea 6-char
        if len(raw_line) >= 6 and raw_line[:6].isdigit():
            # Columna 7 = indicator (*, /, D, espacio)
            if len(raw_line) > 6:
                indicator = raw_line[6] if len(raw_line) > 6 else ' '
            else:
                continue
            if indicator in ('*', '/', 'D'):
                continue
            content = raw_line[7:].rstrip() if len(raw_line) > 7 else ''
        else:
            # Sin número de línea — tomar toda la línea
            line_stripped = raw_line.lstrip()
            if line_stripped.startswith('*'):
                continue
            content = raw_line.rstrip()

        # Detectar secciones
        if re.search(r'\bDATA\s+DIVISION\b', content, re.I):
            in_data_div = True
            continue
        if re.search(r'\bPROCEDURE\s+DIVISION\b', content, re.I):
            break  # fin del DATA DIVISION

        if not in_data_div:
            continue

        if re.search(r'\b(?:WORKING-STORAGE|FILE)\s+SECTION\b', content, re.I):
            in_ws = True
            continue
        if re.search(
            r'\b(?:LINKAGE|DATA-BASE|REPORT|COMMUNICATION|SCREEN)\s+SECTION\b',
            content, re.I
        ):
            in_ws = False
            continue

        if not in_ws:
            continue

        fields.extend(try_extract_field(content, program_id))

    return fields


def extract_cobol_copybook(source_text: str, program_id: str) -> list[dict]:
    """
    Extrae campos de un copybook COBOL Unisys (COPY_ADMWIN) donde todo el
    contenido se trata como WORKING-STORAGE (no hay sección explícita).
    """
    fields = []
    for raw_line in source_text.splitlines():
        if len(raw_line) < 2:
            continue
        # Formato: 6 dígitos de número de línea + indicador + contenido
        if len(raw_line) >= 6 and raw_line[:6].isdigit():
            indicator = raw_line[6] if len(raw_line) > 6 else ' '
            if indicator in ('*', '/', 'D'):
                continue
            content = raw_line[7:].rstrip() if len(raw_line) > 7 else ''
        else:
            line_stripped = raw_line.lstrip()
            if line_stripped.startswith('*'):
                continue
            content = raw_line.rstrip()

        m = re.match(r'^\s{0,10}(\d{1,2})\s+([A-Z][A-Z0-9-]+)(.*)', content, re.I)
        if not m:
            continue
        try:
            level = int(m.group(1))
        except ValueError:
            continue
        name = m.group(2).upper()
        rest = m.group(3)
        if name == 'FILLER' or level in (66, 88):
            continue
        pic_m = re.search(
            r'\b(?:PIC(?:TURE)?|PC)\b\s*(?:IS\s*)?'
            r'([SXA9()\d/.,-]+(?:\s*(?:COMP-?[0-9]*|BINARY|PACKED))?)',
            rest, re.I
        )
        if not pic_m:
            continue
        pic = re.sub(r'\s+', '', pic_m.group(1).strip())
        fields.append({
            'termino': name,
            'categoria': classify_pic(pic),
            'confianza': 'alta',
            'evidencia': f'src-{program_id.lower()}',
            'significado': f'Campo copybook {program_id} · PIC {pic}',
            'programa': program_id,
        })
    return fields


def extract_dasdl_fields(source_text: str, schema_name: str) -> list[dict]:
    """
    Extrae campos de archivos DASDL (Data Management Schema Definition Language).
    Formato Unisys DMSII — campos con tipo NUMBER, ALPHA, BOOLEAN, INTEGER, REAL.
    """
    fields = []
    # Patrón: NOMBRE  TYPE [(tamaño)][;]
    # Ejemplo: B00-NUM-PASO-01           NUMBER (03);
    # También: B01-NUM-COPIA   NUMBER (02) REQUIRED;
    field_pattern = re.compile(
        r'^\s{1,20}([A-Z][A-Z0-9-]+)\s+'
        r'(NUMBER|ALPHA|BOOLEAN|INTEGER|REAL)\b',
        re.I
    )
    for line in source_text.splitlines():
        # DASDL usa % como comentario
        stripped = line.strip()
        if stripped.startswith('%') or stripped.startswith('%%'):
            continue
        content = stripped

        m = field_pattern.match(line)  # usar la línea original para indent check
        if not m:
            continue
        name = m.group(1).upper()
        tipo = m.group(2).upper()

        # Filtrar nombres que son palabras reservadas o estructuras
        if name in ('GROUP', 'SET', 'DATA', 'ACCESS', 'KEY', 'PACK', 'FILE',
                    'AUDIT', 'CONTROL', 'UPDATE', 'OPTIONS', 'PARAMETERS',
                    'DEFAULTS', 'RECOVERY', 'RECONSTRUCT', 'TRAIL', 'AREAS',
                    'AREASIZE', 'BLOCKSIZE', 'CHECKSUM', 'POPULATION',
                    'REBLOCK', 'DUMPSTAMP', 'EXTENDED', 'MEMORY', 'RESIDENT',
                    'BUFFERS', 'ACCESSROUTINES', 'DMSUPPORT', 'STATISTICS',
                    'SYNCPOINT', 'CONTROLPOINT', 'OVERLAYGOAL', 'ALLOWEDCORE',
                    'INDEPENDENTTRANS', 'ADDRESSCHECK', 'KEYCOMPARE',
                    'REBLOCKFACTOR', 'LOCK', 'QUICKCOPY', 'APPEND',
                    'MAXFILESPERTAPE', 'TAPESET', 'REMOVE', 'JOB', 'GUARDFILE',
                    ):
            continue

        cat = classify_dasdl_type(tipo)
        fields.append({
            'termino': name,
            'categoria': cat,
            'confianza': 'alta',
            'evidencia': f'src-dasdl-{schema_name.lower()}',
            'significado': f'Campo DASDL {tipo} en schema {schema_name}',
            'programa': schema_name,
        })
    return fields


def extract_algol_fields(source_text: str, program_id: str) -> list[dict]:
    """
    Extrae variables globales de archivos ALGOL (librerías Lxxx).
    Solo extrae declaraciones a nivel de bloque principal (BEGIN), no locales.
    ALGOL Unisys usa % como comentario.

    Tipos reconocibles:
    - INTEGER var;
    - REAL var;
    - BOOLEAN var;
    - SHORT INTEGER var;
    - LONG REAL var;
    - ARRAY, LONG ARRAY (se captura el nombre del arreglo)
    - INTERLOCK nombre  (semáforos)
    """
    fields = []
    # Rastrear profundidad BEGIN/END para solo tomar nivel top-level (1)
    depth = 0
    in_begin = False

    # Patrón para declaraciones de tipo simple
    type_pattern = re.compile(
        r'^\s{0,6}(SHORT\s+INTEGER|LONG\s+REAL|INTEGER|REAL|BOOLEAN|'
        r'SHORT\s+REAL|LONG\s+INTEGER)\s+([A-Z][A-Z0-9_]+)',
        re.I
    )
    # Patrón para arrays
    array_pattern = re.compile(
        r'^\s{0,6}(?:LONG\s+)?ARRAY\s+([A-Z][A-Z0-9_]+)',
        re.I
    )
    # Patrón para INTERLOCK (semáforos)
    interlock_pattern = re.compile(
        r'^\s{0,6}INTERLOCK\s+([A-Z][A-Z0-9_]+)',
        re.I
    )
    # Procedure declarations (skip)
    proc_pattern = re.compile(r'\bPROCEDURE\b', re.I)

    for line in source_text.splitlines():
        raw = line.rstrip()
        # Quitar número de línea al final (formato Unisys: 8 dígitos al final)
        # La fuente Algol tiene formato: contenido + espacios + NNNNNNN al final
        # Eliminar sufijo de número de línea (hasta 20 chars al final)
        # Mejor: tomar hasta pos 72 si la línea es muy larga
        if len(raw) > 80:
            # El número de línea de compilación suele estar al final con espacios
            # Buscar el patrón de número al final
            cleaned = re.sub(r'\s+\d{8}\s*$', '', raw)
        else:
            cleaned = raw

        # Comentarios ALGOL: % hasta fin de línea
        comment_pos = cleaned.find('%')
        if comment_pos >= 0:
            cleaned = cleaned[:comment_pos]

        # Rastrear profundidad
        begins = len(re.findall(r'\bBEGIN\b', cleaned, re.I))
        ends = len(re.findall(r'\bEND\b', cleaned, re.I))
        if not in_begin and begins > 0:
            in_begin = True
        depth += begins - ends

        # Solo extraer a profundidad 1 (top-level del BEGIN principal)
        if not in_begin or depth != 1:
            continue

        # Saltar si es declaración de procedure
        if proc_pattern.search(cleaned):
            continue

        # Tipo simple
        m = type_pattern.match(cleaned)
        if m:
            tipo = re.sub(r'\s+', ' ', m.group(1).upper())
            name = m.group(2).upper()
            # Filtrar nombres que son args de procedure (cortos, genéricos)
            if len(name) < 3 or name in ('I', 'J', 'K', 'X', 'Y', 'Z',
                                          'ERR', 'RES', 'LEN', 'SEC', 'BS1',
                                          'BS2', 'RPB', 'I_B', 'I_I', 'R_T'):
                continue
            cat = 'CAMPO-NUMERICO' if any(
                t in tipo for t in ('INTEGER', 'REAL')
            ) else 'CAMPO-COMP'
            fields.append({
                'termino': name,
                'categoria': cat,
                'confianza': 'media',
                'evidencia': f'src-algol-{program_id.lower()}',
                'significado': f'Variable global ALGOL {tipo} en {program_id}',
                'programa': program_id,
            })
            continue

        # Arrays
        m = array_pattern.match(cleaned)
        if m:
            name = m.group(1).upper()
            if len(name) >= 3:
                fields.append({
                    'termino': name,
                    'categoria': 'CAMPO-COMP',
                    'confianza': 'media',
                    'evidencia': f'src-algol-{program_id.lower()}',
                    'significado': f'Arreglo ALGOL en {program_id}',
                    'programa': program_id,
                })
            continue

        # Interlocks (semáforos)
        m = interlock_pattern.match(cleaned)
        if m:
            name = m.group(1).upper()
            if len(name) >= 3:
                fields.append({
                    'termino': name,
                    'categoria': 'CAMPO-COMP',
                    'confianza': 'media',
                    'evidencia': f'src-algol-{program_id.lower()}',
                    'significado': f'Semáforo ALGOL INTERLOCK en {program_id}',
                    'programa': program_id,
                })

    return fields


# ---------------------------------------------------------------------------
# LEER VOCAB EXISTENTE
# ---------------------------------------------------------------------------

def load_vocab(vocab_path: Path) -> tuple[list[str], dict[str, int], int]:
    """
    Lee vocab-s500.md y construye:
    - lines: lista de líneas raw
    - term_to_idx: {TERMINO_UPPER: índice en lines}
    - last_num: último número de entrada
    """
    lines = vocab_path.read_text(encoding='utf-8').splitlines()
    term_to_idx: dict[str, int] = {}
    last_num = 0

    for i, line in enumerate(lines):
        if not line.startswith('|') or '---' in line:
            continue
        parts = [p.strip() for p in line.split('|')]
        if len(parts) < 4:
            continue
        # parts[0] = '' (antes del primer |), parts[1] = num, parts[2] = termino, ...
        try:
            num = int(parts[1])
            last_num = max(last_num, num)
        except (ValueError, IndexError):
            continue
        if len(parts) > 2:
            # El término puede estar con backticks: `NOMBRE`
            termino = parts[2].strip().strip('`').strip().upper()
            if termino and termino not in ('TERMINO', 'TÉRMINO', '#'):
                term_to_idx[termino] = i

    return lines, term_to_idx, last_num


# ---------------------------------------------------------------------------
# PROCESAR ARCHIVOS FUENTE
# ---------------------------------------------------------------------------

def derive_program_id(fname: str) -> tuple[str, str]:
    """
    Devuelve (program_id, file_type) a partir del nombre de archivo.
    file_type: 'cobol' | 'algol' | 'dasdl' | 'copybook' | 'skip'
    """
    fname_upper = fname.upper()

    # Saltar siempre WFL e INC
    if '_WFL_' in fname_upper:
        return '', 'skip'
    if '_INC_' in fname_upper:
        return '', 'skip'

    if '_DASDL_' in fname_upper:
        schema = re.sub(r'^S500_DASDL_', '', fname, flags=re.I)
        schema = re.sub(r'\.txt$', '', schema, flags=re.I)
        return schema.upper(), 'dasdl'

    if '_SOURCE_COPY_' in fname_upper:
        prog = re.sub(r'^S500_SOURCE_COPY_', '', fname, flags=re.I)
        prog = re.sub(r'\.txt$', '', prog, flags=re.I)
        return prog.upper(), 'copybook'

    if '_SOURCE_L' in fname_upper:
        prog = re.sub(r'^S500_SOURCE_', '', fname, flags=re.I)
        prog = re.sub(r'\.txt$', '', prog, flags=re.I)
        return prog.upper(), 'algol'

    if '_SOURCE_' in fname_upper:
        prog = re.sub(r'^S500_SOURCE_', '', fname, flags=re.I)
        prog = re.sub(r'\.txt$', '', prog, flags=re.I)
        return prog.upper(), 'cobol'

    return '', 'skip'


def process_all_sources(source_dir: Path) -> dict[str, list[dict]]:
    """
    Procesa todos los archivos fuente y devuelve {program_id: [fields]}.
    """
    results: dict[str, list[dict]] = {}
    errors: list[str] = []

    for fpath in sorted(source_dir.glob('*.txt')):
        program_id, ftype = derive_program_id(fpath.name)

        if ftype == 'skip' or not program_id:
            continue

        if program_id in ALREADY_COVERED:
            print(f"  SKIP (cubierto): {fpath.name} → {program_id}")
            continue

        print(f"  Procesando {ftype.upper()}: {fpath.name} → {program_id}", end=' ')
        try:
            text = fpath.read_text(encoding='utf-8', errors='replace')
        except Exception as e:
            errors.append(f"ERROR leyendo {fpath.name}: {e}")
            print("ERROR")
            continue

        try:
            if ftype == 'cobol':
                fields = extract_cobol_ws(text, program_id)
            elif ftype == 'copybook':
                fields = extract_cobol_copybook(text, program_id)
            elif ftype == 'dasdl':
                fields = extract_dasdl_fields(text, program_id)
            elif ftype == 'algol':
                fields = extract_algol_fields(text, program_id)
            else:
                fields = []
        except Exception as e:
            errors.append(f"ERROR procesando {fpath.name}: {e}")
            print("ERROR")
            continue

        print(f"→ {len(fields)} campos")
        results[program_id] = fields

    if errors:
        print("\nERRORES:")
        for e in errors:
            print(f"  {e}")

    return results


# ---------------------------------------------------------------------------
# ACTUALIZAR VOCAB
# ---------------------------------------------------------------------------

def update_vocab(
    lines: list[str],
    term_to_idx: dict[str, int],
    last_num: int,
    all_program_fields: dict[str, list[dict]],
) -> tuple[list[str], int, int, dict]:
    """
    Aplica los campos nuevos al vocab:
    - Actualiza columna Programas en entradas existentes
    - Agrega nuevas entradas al final

    Devuelve (lines_actualizado, n_nuevos, n_actualizados, top5)
    """
    # Consolidar: {termino_upper → {programa_id: field_dict}}
    consolidated: dict[str, dict] = {}
    # Contar campos por programa para el top-5
    campos_por_prog: dict[str, int] = defaultdict(int)

    for program_id, fields in all_program_fields.items():
        for f in fields:
            t = f['termino'].upper()
            campos_por_prog[program_id] += 1
            if t not in consolidated:
                consolidated[t] = dict(f)
                consolidated[t]['programas'] = {program_id}
            else:
                consolidated[t]['programas'].add(program_id)

    # Separar entre existentes (update) y nuevos (add)
    updates: dict[str, set] = {}   # termino_upper → set of programas
    additions: list[dict] = []

    for t_upper, fdata in consolidated.items():
        if t_upper in term_to_idx:
            updates[t_upper] = fdata['programas']
        else:
            additions.append(fdata)

    n_updated = 0
    # Aplicar updates (columna Programas — columna índice 8 en el split por '|')
    for t_upper, new_progs in updates.items():
        idx = term_to_idx[t_upper]
        parts = lines[idx].split('|')
        if len(parts) < 9:
            continue
        existing_prog = parts[8].strip()
        added = False
        for prog in sorted(new_progs):
            if prog not in existing_prog:
                if not existing_prog or existing_prog == '—':
                    existing_prog = prog
                else:
                    existing_prog = existing_prog + ' · ' + prog
                added = True
        if added:
            parts[8] = f' {existing_prog} '
            lines[idx] = '|'.join(parts)
            n_updated += 1

    # Agregar nuevas entradas al final
    n_added = 0
    for fdata in additions:
        num = last_num + 1 + n_added
        prog_str = ' · '.join(sorted(fdata['programas']))
        row = (
            f"| {num} | `{fdata['termino']}` | 1 | {fdata['categoria']} | "
            f"{fdata['confianza']} | {fdata['evidencia']} | "
            f"{fdata['significado']} | {prog_str} |"
        )
        lines.append(row)
        n_added += 1

    # Top 5 programas por número de campos extraídos
    top5 = sorted(campos_por_prog.items(), key=lambda x: x[1], reverse=True)[:5]

    return lines, n_added, n_updated, top5, campos_por_prog


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

def main():
    print("=" * 70)
    print("extend-vocab-s500.py — Extensión de vocabulario S500")
    print("=" * 70)

    # 1. Leer vocab existente
    print(f"\n[1/4] Leyendo vocab: {VOCAB_PATH.name}")
    if not VOCAB_PATH.exists():
        print(f"ERROR: No se encontró {VOCAB_PATH}")
        sys.exit(1)
    lines, term_to_idx, last_num = load_vocab(VOCAB_PATH)
    print(f"  -> {last_num} entradas existentes / {len(term_to_idx)} terminos indexados")

    # 2. Procesar fuentes
    print(f"\n[2/4] Procesando archivos fuente en:\n  {SOURCE_DIR}")
    if not SOURCE_DIR.exists():
        print(f"ERROR: No se encontró directorio {SOURCE_DIR}")
        sys.exit(1)

    all_fields = process_all_sources(SOURCE_DIR)
    n_programs = len(all_fields)
    total_raw = sum(len(v) for v in all_fields.values())
    print(f"\n  → {n_programs} programas procesados · {total_raw} campos crudos extraídos")

    # 3. Actualizar vocab
    print(f"\n[3/4] Actualizando vocab...")
    updated_lines, n_added, n_updated, top5, campos_por_prog = update_vocab(
        lines, term_to_idx, last_num, all_fields
    )
    print(f"  → {n_added} términos nuevos agregados")
    print(f"  → {n_updated} entradas existentes actualizadas (columna Programas)")

    # 4. Guardar
    print(f"\n[4/4] Guardando {VOCAB_PATH.name}...")
    VOCAB_PATH.write_text('\n'.join(updated_lines), encoding='utf-8')
    total_final = last_num + n_added
    print(f"  → OK — {total_final} entradas totales en vocab-s500.md")

    # Reporte final
    print("\n" + "=" * 70)
    print("REPORTE FINAL")
    print("=" * 70)
    print(f"  Programas procesados:          {n_programs}")
    print(f"  Términos nuevos agregados:     {n_added}")
    print(f"  Entradas existentes actualizadas: {n_updated}")
    print(f"  Total entradas vocab-s500.md:  {total_final}")
    print(f"\n  Top 5 programas por campos extraídos:")
    for prog, cnt in top5:
        print(f"    {prog:<30} {cnt:>5} campos")

    print("\n  Campos extraídos por programa:")
    for prog, cnt in sorted(campos_por_prog.items(), key=lambda x: x[1], reverse=True):
        print(f"    {prog:<30} {cnt:>5}")

    print("\nListo.")


if __name__ == '__main__':
    main()

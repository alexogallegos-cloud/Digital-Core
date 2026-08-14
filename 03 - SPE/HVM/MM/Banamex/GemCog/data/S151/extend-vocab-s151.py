#!/usr/bin/env python3
"""
extend-vocab-s151.py
Extiende vocab-s151.md con campos WORKING-STORAGE de programas S151
no cubiertos por evidencia src-pNNN / src-lNNN.

Tipos de archivo procesados:
  COBOL_*.txt  → WORKING-STORAGE SECTION fields con PIC clause
  ALGOL_*.txt  → declaraciones INTEGER / REAL / BOOLEAN
  DASDL_*.txt  → campos ALPHA / NUMBER en datasets DMSII
  WFL_*.txt    → SKIP
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

# ── Rutas ─────────────────────────────────────────────────────────────────────
S151_SOURCE_DIR = (
    r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
    r"\03 - SPE\HVM\MM\Banamex\S151\source\S151"
)
VOCAB_PATH = (
    r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
    r"\03 - SPE\HVM\MM\Banamex\GemCog\data\S151\vocab-s151.md"
)

# ── Helpers ───────────────────────────────────────────────────────────────────

def classify_pic(pic: str) -> str:
    p = pic.upper()
    if "COMP-3" in p or "PACKED" in p:
        return "CAMPO-DECIMAL"
    if "COMP" in p or "BINARY" in p:
        return "CAMPO-COMP"
    if "X" in p:
        return "CAMPO-ALFA"
    if "V" in p:
        return "CAMPO-DECIMAL"
    if "9" in p or p.startswith("S"):
        return "CAMPO-NUMERICO"
    return "CAMPO-ALFA"


# ── COBOL WORKING-STORAGE parser ──────────────────────────────────────────────

def extract_cobol_ws(source_text: str, program_id: str) -> list:
    """Extrae campos con PIC de la WORKING-STORAGE SECTION de un programa COBOL."""
    fields = []
    lines = source_text.splitlines()
    in_ws = False

    for raw in lines:
        # Los archivos S151 tienen 6 dígitos de secuencia en cols 0-5
        # Col 6 es el indicador (*=comentario, /=salto, $=compiler directive)
        if len(raw) <= 6:
            continue
        indicator = raw[6]
        if indicator in ("*", "/", "$"):
            continue
        # Contenido: col 7 en adelante, limitado a col 72 (área de código)
        content = raw[7:72].rstrip() if len(raw) > 7 else ""

        if re.search(r"\bPROCEDURE\s+DIVISION\b", content, re.I):
            break
        if re.search(r"\b(WORKING-STORAGE|FILE)\s+SECTION\b", content, re.I):
            in_ws = True
            continue
        if re.search(
            r"\b(LINKAGE|DATA-BASE|REPORT|COMMUNICATION)\s+SECTION\b",
            content,
            re.I,
        ):
            in_ws = False
            continue

        if not in_ws:
            continue

        m = re.match(r"\s{0,9}(\d{1,2})\s+([A-Z][A-Z0-9-]+)(.*)", content, re.I)
        if not m:
            continue

        level = int(m.group(1))
        name = m.group(2).upper()
        rest = m.group(3)

        if name == "FILLER" or level in (66, 88):
            continue

        pic_m = re.search(
            r"\bPIC(?:TURE)?\b\s*(?:IS\s*)?"
            r"([SX9A()\d/.V,-]+(?:\s*COMP-?[0-9]*|\s*BINARY|\s*PACKED)?)",
            rest,
            re.I,
        )
        if not pic_m:
            continue

        pic = pic_m.group(1).strip()
        categoria = classify_pic(pic)

        fields.append(
            {
                "termino": name,
                "categoria": categoria,
                "confianza": "alta",
                "evidencia": f"src-{program_id.lower()}",
                "significado": f"Campo nivel {level:02d} en S151/{program_id} · PIC {pic}",
                "alcance": "WS-interno",
                "programa": program_id,
            }
        )

    return fields


# ── ALGOL variable parser ─────────────────────────────────────────────────────

_ALGOL_TYPES = r"(INTEGER|REAL|BOOLEAN|SHORT\s+INTEGER|LONG\s+REAL)"
_ALGOL_IDENT = r"([A-Z][A-Z0-9_-]{1,})"  # at least 2 chars (skip loop vars)

def extract_algol_fields(source_text: str, program_id: str) -> list:
    """Extrae declaraciones de variables INTEGER / REAL / BOOLEAN de un fuente ALGOL."""
    fields = []
    for raw in source_text.splitlines():
        # En ALGOL MCP los comentarios de línea empiezan con %
        content = raw.strip()
        if not content or content.startswith("%"):
            continue
        # Buscar tipo declarado en la línea
        tm = re.search(_ALGOL_TYPES + r"\s+", content, re.I)
        if not tm:
            continue
        tipo = re.sub(r"\s+", " ", tm.group(1).upper())
        cat = (
            "CAMPO-NUMERICO"
            if "INTEGER" in tipo or "REAL" in tipo
            else "CAMPO-ALFA"
        )
        # Extraer todos los identificadores tras el tipo (multi-variable declarations)
        after_type = content[tm.end():]
        # Romper en tokens separados por coma, punto y coma, paréntesis o espacio
        tokens = re.split(r"[\s,;()\[\]]+", after_type)
        for tok in tokens:
            tok = tok.strip()
            if not tok:
                continue
            if not re.match(r"^[A-Z][A-Z0-9_-]{1,}$", tok, re.I):
                continue  # saltar vars de 1 char o con chars inválidos
            name = tok.upper()
            fields.append(
                {
                    "termino": name,
                    "categoria": cat,
                    "confianza": "media",
                    "evidencia": f"src-algol-{program_id.lower()}",
                    "significado": f"Variable ALGOL {tipo} en S151/{program_id}",
                    "alcance": "WS-interno",
                    "programa": program_id,
                }
            )

    return fields


# ── DASDL field parser ────────────────────────────────────────────────────────

def extract_dasdl_fields(source_text: str, schema_name: str) -> list:
    """
    Extrae campos de un fuente DASDL (Unisys DMSII schema).
    Formato: FIELD-NAME "descripcion" ALPHA(n) o NUMBER(n);
    También: FIELD-NAME "descripcion" RESTART DATA SET (datasets name, skip)
    Líneas comentario: empiezan con '%'.
    """
    fields = []
    for raw in source_text.splitlines():
        content = raw.strip()
        if not content or content.startswith("%"):
            continue
        # Patrón: NOMBRE "descripcion..." (ALPHA|NUMBER|BOOLEAN)(tamaño)
        m = re.match(
            r"([A-Z][A-Z0-9-]+)\s+"          # nombre del campo
            r'"[^"]*"\s+'                      # descripción entre comillas
            r"(ALPHA|NUMBER|BOOLEAN)\s*"       # tipo
            r"(?:\([^)]*\))?",                 # tamaño opcional (002), (010)...
            content,
            re.I,
        )
        if m:
            name = m.group(1).upper()
            tipo = m.group(2).upper()
            cat = "CAMPO-ALFA" if tipo in ("ALPHA", "BOOLEAN") else "CAMPO-NUMERICO"
            fields.append(
                {
                    "termino": name,
                    "categoria": cat,
                    "confianza": "alta",
                    "evidencia": f"src-dasdl-{schema_name.lower()}",
                    "significado": f"Campo DASDL {tipo} en schema S151/{schema_name}",
                    "alcance": "DASDL-schema",
                    "programa": schema_name,
                }
            )

    return fields


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    vocab_path = Path(VOCAB_PATH)

    # 1. Leer vocab existente
    content = vocab_path.read_text("utf-8", errors="replace")
    lines = content.splitlines()

    # Construir índice de términos y encontrar last_num
    term_to_idx: dict[str, int] = {}
    last_num = 0

    for i, line in enumerate(lines):
        if not line.startswith("|") or "---" in line:
            continue
        parts = [p.strip() for p in line.split("|")]
        if len(parts) < 4:
            continue
        try:
            num = int(parts[1])
            last_num = max(last_num, num)
        except (ValueError, IndexError):
            pass
        if len(parts) >= 3:
            termino = parts[2].strip("`").strip()
            if termino and termino not in ("Termino", "#", ""):
                term_to_idx[termino] = i

    print(f"Vocab existente: {len(term_to_idx)} términos | last_num={last_num}")

    # 2. Detectar qué programas ya tienen evidencia src-*
    already_covered: set[str] = set()
    for line in lines:
        for m in re.findall(r"\bsrc-[a-z0-9_-]+", line, re.I):
            prog = m.replace("src-dasdl-", "").replace("src-algol-", "").replace("src-", "")
            already_covered.add(prog.upper())

    if already_covered:
        print(f"Programas ya cubiertos (src-*): {sorted(already_covered)}")
    else:
        print("Sin cobertura src-* previa -> se procesaran TODOS los archivos fuente.")

    # 3. Procesar fuentes
    source_dir = Path(S151_SOURCE_DIR)
    new_terms: dict[str, dict] = {}       # termino → primer campo con ese nombre
    prog_field_counts: dict[str, int] = defaultdict(int)
    progs_processed: list[tuple[str, str]] = []

    for fpath in sorted(source_dir.glob("*.txt")):
        stem_clean = fpath.stem.strip()        # quitar espacio en COBOL_P138 .txt
        fname_upper = stem_clean.upper()

        # Skip WFL
        if fname_upper.startswith("WFL_"):
            continue

        if fname_upper.startswith("DASDL_"):
            id_raw = stem_clean[6:].strip()
            if id_raw.upper() in already_covered:
                print(f"  SKIP DASDL {id_raw} (ya cubierto)")
                continue
            fields = extract_dasdl_fields(
                fpath.read_text("utf-8", errors="replace"), id_raw
            )
            tipo_tag = "DASDL"

        elif fname_upper.startswith("ALGOL_"):
            id_raw = stem_clean[6:].strip()
            if id_raw.upper() in already_covered:
                print(f"  SKIP ALGOL {id_raw} (ya cubierto)")
                continue
            fields = extract_algol_fields(
                fpath.read_text("utf-8", errors="replace"), id_raw
            )
            tipo_tag = "ALGOL"

        elif fname_upper.startswith("COBOL_"):
            id_raw = stem_clean[6:].strip()
            if id_raw.upper() in already_covered:
                print(f"  SKIP COBOL {id_raw} (ya cubierto)")
                continue
            fields = extract_cobol_ws(
                fpath.read_text("utf-8", errors="replace"), id_raw
            )
            tipo_tag = "COBOL"

        else:
            continue

        prog_field_counts[id_raw] += len(fields)
        progs_processed.append((tipo_tag, id_raw))

        for f in fields:
            t = f["termino"]
            if t in new_terms:
                existing = new_terms[t]
                if id_raw not in existing["programa"]:
                    existing["programa"] += " · " + id_raw
            else:
                new_terms[t] = f

    print(f"\nProgramas procesados: {len(progs_processed)}")
    print(f"  COBOL  : {sum(1 for k,_ in progs_processed if k=='COBOL')}")
    print(f"  ALGOL  : {sum(1 for k,_ in progs_processed if k=='ALGOL')}")
    print(f"  DASDL  : {sum(1 for k,_ in progs_processed if k=='DASDL')}")
    print(f"Términos únicos extraídos de fuentes: {len(new_terms)}")

    # 4. Separar updates vs adiciones
    updates = {t: new_terms[t]["programa"] for t in new_terms if t in term_to_idx}
    additions = [f for t, f in new_terms.items() if t not in term_to_idx]

    print(f"Actualizaciones (Programas col): {len(updates)}")
    print(f"Nuevas entradas a agregar      : {len(additions)}")

    # 5. Aplicar updates al campo Programas (columna índice 9)
    updated_count = 0
    for term, prog in updates.items():
        idx = term_to_idx[term]
        parts = lines[idx].split("|")
        # Necesitamos al menos 10 partes: '' | # | term | freq | cat | conf | ev | sig | alcance | prog | ''
        if len(parts) >= 10:
            existing_prog = parts[9].strip()
            if existing_prog in ("—", "—", ""):
                parts[9] = f" {prog} "
                lines[idx] = "|".join(parts)
                updated_count += 1
            elif prog not in existing_prog:
                parts[9] = f" {existing_prog} · {prog} "
                lines[idx] = "|".join(parts)
                updated_count += 1

    print(f"Filas actualizadas en vocab    : {updated_count}")

    # 6. Append nuevas entradas
    new_start_num = last_num + 1
    for i, field in enumerate(additions):
        num = new_start_num + i
        sig = field["significado"].replace("|", "/")  # sanitize
        row = (
            f"| {num} | `{field['termino']}` | 1 | {field['categoria']} | "
            f"{field['confianza']} | {field['evidencia']} | "
            f"{sig} | {field['alcance']} | {field['programa']} |"
        )
        lines.append(row)

    # 7. Escribir vocab actualizado
    vocab_path.write_text("\n".join(lines), "utf-8")

    total_lines = len(lines)
    total_data_rows = sum(
        1
        for l in lines
        if l.startswith("|") and "---" not in l and "| #" not in l and "| Termino" not in l
    )
    print(f"\nvocab-s151.md guardado.")
    print(f"  Total líneas            : {total_lines}")
    print(f"  Total filas de datos    : {total_data_rows}")

    # Top 5 programas por campos extraídos
    print("\nTop 5 programas por campos WS extraídos en esta ejecución:")
    top5 = sorted(prog_field_counts.items(), key=lambda x: -x[1])[:5]
    for prog, count in top5:
        print(f"  {prog:30s} {count:5d} campos")

    # Resumen final
    print("\n══ RESUMEN ══════════════════════════════")
    print(f"  Programas S151 procesados  : {len(progs_processed)}")
    print(f"  Nuevas entradas agregadas  : {len(additions)}")
    print(f"  Entradas actualizadas      : {updated_count}")
    print(f"  Total entradas vocab-s151  : {total_data_rows}")
    print("═════════════════════════════════════════")


if __name__ == "__main__":
    main()

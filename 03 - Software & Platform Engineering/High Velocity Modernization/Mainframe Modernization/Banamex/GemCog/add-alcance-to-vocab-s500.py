"""
add-alcance-to-vocab-s500.py
Deriva y agrega columna Alcance a vocab-s500.md entre Significado y Programas.
Reglas basadas en Evidencia + Categoria + Frecuencia.
Idempotente: si ya existe columna Alcance, no la duplica.
"""
import re

VOCAB_PATH = r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - Software & Platform Engineering\High Velocity Modernization\Mainframe Modernization\Banamex\GemCog\data\S500\vocab-s500.md"


def derive_alcance(frecuencia_str, categoria, evidencia):
    ev = evidencia.strip().lower()
    cat = categoria.strip().upper()
    try:
        freq = int(frecuencia_str.strip())
    except ValueError:
        freq = 0

    if ev.startswith("src-dasdl"):
        return "DASDL-schema"
    if ev.startswith("src-algol"):
        return "N/A-componente"
    if ev.startswith("inc-wor"):
        return "WS-interno"
    if ev.startswith("inc-"):
        return "Interfaz-Externo"
    if ev in ("dominio", "patron", "bcop"):
        return "N/A-componente"
    if ev.startswith("src-"):
        if cat == "ENTIDAD":
            return "Persistente-BD"
        if cat == "ACCION":
            return "Control-proceso"
        if cat == "PREFIJO":
            return "N/A-componente"
        return "Efimero" if freq <= 2 else "WS-interno"
    return "N/A-componente"


def process():
    with open(VOCAB_PATH, encoding="utf-8") as f:
        lines = f.readlines()

    # Detect header row
    header_idx = None
    for i, line in enumerate(lines):
        if line.startswith("| #") and "Termino" in line:
            header_idx = i
            break

    if header_idx is None:
        print("ERROR: header not found")
        return

    cols = [c.strip() for c in lines[header_idx].split("|")]
    # cols[0] = '', cols[1]='#', cols[2]='Termino', ...
    col_names = cols[1:-1]  # strip leading/trailing empty from split

    if "Alcance" in col_names:
        print("Alcance ya existe en el MD — nada que hacer.")
        return

    # Expected: # | Termino | Frecuencia | Categoria | Confianza | Evidencia | Significado | Programas | Aliases
    # Indices (1-based after split):         1     2           3           4          5           6           7          8          9
    # Python split gives: ['', '#', 'Termino', 'Frecuencia', 'Categoria', 'Confianza', 'Evidencia', 'Significado', 'Programas', 'Aliases', '']
    # We insert Alcance AFTER Significado (index 7) = before Programas (index 8)

    IDX_FREQ = 3      # Frecuencia
    IDX_CAT  = 4      # Categoria
    IDX_EV   = 6      # Evidencia
    IDX_INSERT = 8    # insert before Programas (0-based in split result including leading '')

    new_lines = []
    separator_done = False

    for i, line in enumerate(lines):
        if i < header_idx:
            new_lines.append(line)
            continue

        if i == header_idx:
            # Insert Alcance column into header
            parts = line.rstrip("\n").split("|")
            parts.insert(IDX_INSERT, " Alcance ")
            new_lines.append("|".join(parts) + "\n")
            continue

        if i == header_idx + 1:
            # Separator row
            parts = line.rstrip("\n").split("|")
            parts.insert(IDX_INSERT, "---|")
            # fix: the inserted value should just be the cell
            parts = line.rstrip("\n").split("|")
            parts.insert(IDX_INSERT, "---")
            new_lines.append("|".join(parts) + "\n")
            separator_done = True
            continue

        if not line.startswith("|"):
            new_lines.append(line)
            continue

        parts = line.rstrip("\n").split("|")
        if len(parts) < IDX_INSERT:
            new_lines.append(line)
            continue

        try:
            freq_str = parts[IDX_FREQ]
            cat_str  = parts[IDX_CAT]
            ev_str   = parts[IDX_EV]
            alcance  = derive_alcance(freq_str, cat_str, ev_str)
        except IndexError:
            alcance = "N/A-componente"

        parts.insert(IDX_INSERT, f" {alcance} ")
        new_lines.append("|".join(parts) + "\n")

    with open(VOCAB_PATH, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    # Stats
    counts = {}
    for line in new_lines:
        if not line.startswith("|") or "Alcance" in line:
            continue
        parts = line.split("|")
        if len(parts) > IDX_INSERT:
            v = parts[IDX_INSERT].strip()
            counts[v] = counts.get(v, 0) + 1

    total = sum(counts.values())
    print(f"Alcance derivado para {total:,} entradas:")
    for k, v in sorted(counts.items(), key=lambda x: -x[1]):
        print(f"  {k:<25} {v:>7,}  ({v/total*100:.1f}%)")
    print(f"\nvocab-s500.md actualizado con columna Alcance.")


if __name__ == "__main__":
    process()

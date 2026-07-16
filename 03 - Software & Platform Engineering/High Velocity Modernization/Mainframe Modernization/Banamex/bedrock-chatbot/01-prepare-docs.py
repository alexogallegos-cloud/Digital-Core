"""
Paso 1 — Preparación de documentos para Bedrock Knowledge Base.

Lee todos los archivos de la KB de S500/S151, convierte JSON→Markdown,
y los copia a la carpeta local 'documents/' lista para subir a S3.

Uso:
    pip install -r requirements.txt
    python 01-prepare-docs.py
"""

import json
import pathlib
import shutil
import sys
import textwrap
from config import BANAMEX_DIR, DOCUMENTS_DIR, CORE_DOCS, SOURCE_GLOBS

# ─── Utilidades de conversión ─────────────────────────────────────────────────

def _json_value_to_str(val, depth=0) -> str:
    if isinstance(val, dict):
        lines = []
        for k, v in val.items():
            prefix = "  " * depth + f"**{k}**: "
            if isinstance(v, (dict, list)):
                lines.append("  " * depth + f"**{k}**:")
                lines.append(_json_value_to_str(v, depth + 1))
            else:
                lines.append(prefix + str(v))
        return "\n".join(lines)
    elif isinstance(val, list):
        parts = []
        for item in val:
            if isinstance(item, (dict, list)):
                parts.append(_json_value_to_str(item, depth))
                parts.append("")
            else:
                parts.append("  " * depth + f"- {item}")
        return "\n".join(parts)
    else:
        return "  " * depth + str(val)


def json_to_markdown(data: dict | list, source_name: str) -> str:
    """Convierte un JSON (dict o list) a Markdown legible para Bedrock."""
    lines = [f"# {source_name}\n"]

    if isinstance(data, list):
        for i, item in enumerate(data):
            if isinstance(item, dict):
                # Intenta usar un campo de nombre/id como header
                title = (
                    item.get("nombre")
                    or item.get("name")
                    or item.get("id")
                    or item.get("programa")
                    or item.get("program")
                    or f"Item {i+1}"
                )
                lines.append(f"\n## {title}\n")
                for k, v in item.items():
                    if k in ("nombre", "name", "id", "programa", "program"):
                        continue
                    if isinstance(v, (dict, list)):
                        lines.append(f"**{k}**:")
                        lines.append(_json_value_to_str(v, 1))
                        lines.append("")
                    else:
                        lines.append(f"**{k}**: {v}")
            else:
                lines.append(f"- {item}")
    elif isinstance(data, dict):
        for k, v in data.items():
            if isinstance(v, (dict, list)):
                lines.append(f"\n## {k}\n")
                lines.append(_json_value_to_str(v, 0))
            else:
                lines.append(f"**{k}**: {v}")
    else:
        lines.append(str(data))

    return "\n".join(lines)


def add_header(content: str, source_rel: str, kind: str) -> str:
    """Añade metadatos al inicio de cada documento."""
    header = textwrap.dedent(f"""\
        <!-- GemCog KB · Banamex · S500+S151 -->
        <!-- Fuente: {source_rel} | Tipo: {kind} -->

    """)
    return header + content


# ─── Main ─────────────────────────────────────────────────────────────────────

def prepare():
    print("── Preparación de documentos para Bedrock KB ──────────────────────")
    print(f"  Fuente : {BANAMEX_DIR}")
    print(f"  Destino: {DOCUMENTS_DIR}\n")

    if DOCUMENTS_DIR.exists():
        shutil.rmtree(DOCUMENTS_DIR)
    DOCUMENTS_DIR.mkdir(parents=True)

    copied = 0
    converted = 0
    errors = 0

    # ── Documentos clave ─────────────────────────────────────────────────────
    print("[ 1/2 ] Documentos de análisis:")
    for rel in CORE_DOCS:
        src = BANAMEX_DIR / rel
        if not src.exists():
            print(f"  ⚠  No encontrado: {rel}")
            errors += 1
            continue

        suffix = src.suffix.lower()
        dest_name = src.name

        if suffix == ".json":
            # Convertir JSON → Markdown
            try:
                data = json.loads(src.read_text(encoding="utf-8", errors="replace"))
            except json.JSONDecodeError as e:
                print(f"  ⚠  JSON inválido ({rel}): {e}")
                errors += 1
                continue

            md_content = json_to_markdown(data, src.stem)
            md_content = add_header(md_content, rel, "JSON→MD")
            dest_name = src.stem + ".md"
            dest = DOCUMENTS_DIR / dest_name
            dest.write_text(md_content, encoding="utf-8")
            print(f"  ✓  {rel}  →  {dest_name}  (JSON→MD)")
            converted += 1

        elif suffix in (".md", ".html", ".txt"):
            content = src.read_text(encoding="utf-8", errors="replace")
            content = add_header(content, rel, suffix.lstrip(".").upper())
            dest = DOCUMENTS_DIR / dest_name
            dest.write_text(content, encoding="utf-8")
            print(f"  ✓  {rel}")
            copied += 1

        else:
            print(f"  –  Omitido (tipo no soportado): {rel}")

    # ── Código fuente ─────────────────────────────────────────────────────────
    print(f"\n[ 2/2 ] Código fuente (COBOL · ALGOL · DASDL · WFL):")
    src_dir = DOCUMENTS_DIR / "source"
    src_dir.mkdir()

    source_files = []
    for pattern in SOURCE_GLOBS:
        source_files.extend(sorted(BANAMEX_DIR.glob(pattern)))

    for src in source_files:
        try:
            content = src.read_bytes()
            # Detectar binarios (más del 10% de bytes no-ASCII → omitir)
            non_ascii = sum(1 for b in content if b > 127)
            if non_ascii > len(content) * 0.10:
                print(f"  –  Posible binario/EBCDIC, omitido: {src.name}")
                continue
            text = content.decode("utf-8", errors="replace")
            text = add_header(text, src.name, "SOURCE")
            dest = src_dir / src.name
            dest.write_text(text, encoding="utf-8")
            copied += 1
        except Exception as e:
            print(f"  ⚠  Error ({src.name}): {e}")
            errors += 1

    print(f"  {copied} archivos copiados, {converted} JSON→MD convertidos")

    # ── Resumen ───────────────────────────────────────────────────────────────
    all_files = list(DOCUMENTS_DIR.rglob("*"))
    total_files = [f for f in all_files if f.is_file()]
    total_size_mb = sum(f.stat().st_size for f in total_files) / 1_048_576

    print(f"\n── Resumen ─────────────────────────────────────────────────────────")
    print(f"  Archivos totales : {len(total_files)}")
    print(f"  Tamaño total     : {total_size_mb:.1f} MB")
    if errors:
        print(f"  Advertencias     : {errors} archivos con error/omitidos")
    print(f"\n  ✓  Documentos listos en: {DOCUMENTS_DIR}")
    print(f"  → Ejecuta ahora: python 02-deploy.py")


if __name__ == "__main__":
    prepare()
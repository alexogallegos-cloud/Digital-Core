#!/usr/bin/env python3
"""
Regenera vocab-{sistema}.html y vocab-{sistema}.md
desde vocab-{sistema}.json ya existente/corregido.

NO usa gemelo-{sistema}.json — lee el JSON de vocab directamente.
Usar esto en lugar de build-vocab.py cuando el vocab JSON ya está corregido
y no se quiere re-enriquecer desde gemelo (lo cual sobreescribiría las correcciones).

Uso:
  python render-vocab-from-json.py S500
  python render-vocab-from-json.py S151
  python render-vocab-from-json.py S500 S151
"""

import json
import sys
from pathlib import Path

# Importar funciones de render desde build-vocab.py
import importlib.util
spec = importlib.util.spec_from_file_location(
    "build_vocab",
    Path(__file__).parent / "build-vocab.py"
)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

DATA_DIR = Path(__file__).parent / "data"


def render_from_json(sistema: str) -> None:
    json_path = DATA_DIR / sistema / f"vocab-{sistema.lower()}.json"
    if not json_path.exists():
        print(f"[ERROR] No encontrado: {json_path}")
        return

    data = json.loads(json_path.read_text(encoding="utf-8"))
    vocab_entries = data["vocabulario"]
    out_dir = DATA_DIR / sistema

    print(f"\n[RENDER] {sistema} — {len(vocab_entries)} términos")
    mod._write_vocab_md(sistema, vocab_entries, out_dir)
    mod._write_vocab_html(sistema, vocab_entries, data)
    print(f"[OK] {sistema} regenerado desde JSON corregido.")


if __name__ == "__main__":
    sistemas = sys.argv[1:] if len(sys.argv) > 1 else ["S500", "S151"]
    for s in sistemas:
        if s not in ("S500", "S151"):
            print(f"[SKIP] Sistema desconocido: {s}")
            continue
        render_from_json(s)

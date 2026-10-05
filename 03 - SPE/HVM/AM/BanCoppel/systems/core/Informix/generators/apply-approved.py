"""
apply-approved.py — HITL: agrega candidatos aprobados a sp_vocab.py

Lee vocab-approved.json (exportado desde el portal HTML) y agrega los tokens
aprobados al final del bloque CAT en sp_vocab.py como estado "gap".

Reglas:
  - Nunca modifica tokens ya existentes (conf/inf/gap).
  - Solo agrega tokens nuevos con estado "gap" (requiere confirmación posterior).
  - Imprime un diff resumido de lo que se agregaría antes de escribir.

Uso:
  python generators/apply-approved.py [vocab-approved.json]
  python generators/apply-approved.py  # busca vocab-approved.json en knowledge-base/
"""
import json, re, sys
from pathlib import Path

BASE     = Path(__file__).resolve().parent.parent
SP_VOCAB = Path(__file__).resolve().parent / "sp_vocab.py"
CAND_DIR = BASE / "knowledge-base"

# Localizar el JSON de aprobados
if len(sys.argv) > 1:
    approved_path = Path(sys.argv[1])
else:
    approved_path = CAND_DIR / "vocab-approved.json"

if not approved_path.exists():
    print(f"ERROR: no se encontró {approved_path}")
    sys.exit(1)

payload = json.loads(approved_path.read_text(encoding="utf-8"))
approved_items = payload.get("approved", [])
print(f"vocab-approved.json: {len(approved_items)} términos aprobados · exportado {payload.get('exported_at','?')}")

# Cargar tokens ya existentes en sp_vocab.py
vocab_text = SP_VOCAB.read_text(encoding="utf-8")
existing = set(re.findall(r'^\s+"(\w+)"\s*:', vocab_text, re.MULTILINE))
print(f"sp_vocab.py actual: {len(existing)} tokens existentes")

# Filtrar solo los nuevos
new_items = [item for item in approved_items if item["token"] not in existing]
skip_items = [item for item in approved_items if item["token"] in existing]

if skip_items:
    print(f"\nYa existentes (no se tocan): {len(skip_items)}")
    for it in skip_items:
        print(f"  ✓ {it['token']}")

if not new_items:
    print("\nNada nuevo que agregar.")
    sys.exit(0)

print(f"\nNuevos a agregar ({len(new_items)}):")
for it in new_items:
    print(f"  + {it['token']:<30} [{it['cat']}]  {it['mean'][:60]}")

print(f"\n¿Agregar {len(new_items)} términos a sp_vocab.py como 'gap'? [s/N] ", end="", flush=True)
resp = input().strip().lower()
if resp not in ("s", "si", "sí", "y", "yes"):
    print("Cancelado.")
    sys.exit(0)

# Construir las líneas a insertar
lines_to_add = []
for it in new_items:
    tok  = it["token"]
    cat  = it["cat"]
    mean = it["mean"].replace('"', "'")
    lines_to_add.append(f'    "{tok}": ("{cat}", "{mean}", "gap"),')

# Insertar antes del cierre del bloque CAT = {...}
# Busca la última llave de cierre del dict CAT
insertion_marker = "}\n"
# Encuentra el índice del último "}" al nivel de CAT
# La estructura es: CAT = {\n    ...\n}\n
cat_match = re.search(r'^CAT\s*=\s*\{', vocab_text, re.MULTILINE)
if not cat_match:
    print("ERROR: no se encontró el bloque CAT = { en sp_vocab.py")
    sys.exit(1)

cat_start = cat_match.end()
# Encuentra el } de cierre del dict (nivel 0, ignorando nested si los hay)
depth = 1
pos = cat_start
while pos < len(vocab_text) and depth > 0:
    if vocab_text[pos] == '{':
        depth += 1
    elif vocab_text[pos] == '}':
        depth -= 1
    pos += 1

close_pos = pos - 1  # posición de '}'
insert_pos = close_pos  # insertar justo antes del }

block = "\n" + "\n".join(lines_to_add) + "\n"
new_text = vocab_text[:insert_pos] + block + vocab_text[insert_pos:]

SP_VOCAB.write_text(new_text, encoding="utf-8")
print(f"\nsp_vocab.py actualizado — {len(new_items)} nuevos términos con estado 'gap'.")
print("Próximo paso: revisar en portal y promover gap → inf → conf según confianza.")

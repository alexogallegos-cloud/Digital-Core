#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-names-ai.py — Enriquecimiento masivo de business_name via Claude API.

Para cada SP en business-rules-v3.json:
  1. Carga el código fuente SPL (si existe en source/)
  2. Agrupa las reglas del SP
  3. Llama a Claude para generar nombres de negocio claros en español
  4. Guarda resultados incrementalmente en name-overrides-ai.json

Modos:
  python generators/enrich-names-ai.py              # procesa todo
  python generators/enrich-names-ai.py --dry-run    # muestra primeras 5 SPs sin API
  python generators/enrich-names-ai.py --apply      # aplica overrides ya guardados
  python generators/enrich-names-ai.py --domain D05 # solo un dominio
  python generators/enrich-names-ai.py --resume     # salta SPs ya procesados (default)

Requiere: pip install anthropic
Requiere: ANTHROPIC_API_KEY en entorno o en .env
"""
import json, os, re, sys, time, argparse, io, textwrap
from pathlib import Path
from collections import defaultdict

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

BASE = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
            "03 - Software & Platform Engineering/High Velocity Modernization/"
            "Application Modernization/BanCoppel/BCOPCore/")
SRC       = BASE / "source/BCOPCore/informix"
RULES_IN  = BASE / "portal/data/business-rules-v3.json"
OVERRIDES = BASE / "knowledge-base/rules/name-overrides-ai.json"
MODEL     = "claude-haiku-4-5-20251001"
MAX_CODE_CHARS = 3000   # truncar SP source si es muy largo
MAX_RULES_PER_CALL = 25 # batch size por llamada API

# ── Arg parsing ───────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser()
parser.add_argument("--dry-run",  action="store_true")
parser.add_argument("--apply",    action="store_true")
parser.add_argument("--domain",   default=None, help="Filtrar por dominio, e.g. D05")
parser.add_argument("--no-resume",action="store_true", help="Re-procesar todo (ignora overrides)")
args = parser.parse_args()

# ── Load rules ────────────────────────────────────────────────────────────────
with open(RULES_IN, encoding="utf-8") as f:
    data = json.load(f)
rules_all = data["rules"]
print(f"Rules loaded: {len(rules_all)}")

# ── Load existing overrides (resume) ─────────────────────────────────────────
overrides: dict[str, str] = {}     # rule_id → business_name
processed_sps: set[str] = set()    # sp keys already done

if OVERRIDES.exists() and not args.no_resume:
    with open(OVERRIDES, encoding="utf-8") as f:
        saved = json.load(f)
    overrides = saved.get("names", {})
    processed_sps = set(saved.get("processed_sps", []))
    print(f"Resuming: {len(overrides)} names already saved, {len(processed_sps)} SPs done")

# ── Apply mode: patch v3.json with saved overrides ───────────────────────────
if args.apply:
    if not overrides:
        print("No overrides found. Run without --apply first.")
        sys.exit(0)
    patched = 0
    for r in rules_all:
        if r["id"] in overrides:
            new_name = overrides[r["id"]]
            if new_name and new_name != r.get("business_name", ""):
                r["business_name"] = new_name
                patched += 1
    print(f"Patched {patched} business_name(s) in v3.json")
    with open(RULES_IN, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    print(f"Saved: {RULES_IN}")
    sys.exit(0)

# ── Group rules by SP ────────────────────────────────────────────────────────
by_sp: dict[str, list] = defaultdict(list)
for r in rules_all:
    sp_key = f"{r['db']}:{r['sp']}"
    by_sp[sp_key].append(r)

# Filter by domain if requested
if args.domain:
    dom = args.domain.upper()
    by_sp = {k: v for k, v in by_sp.items()
              if any(dom in (r.get("dominio", "") or "") for r in v)}
    print(f"Domain filter {dom}: {len(by_sp)} SPs")

# Skip already processed
if not args.no_resume:
    pending = {k: v for k, v in by_sp.items() if k not in processed_sps}
else:
    pending = dict(by_sp)
print(f"SPs to process: {len(pending)} / {len(by_sp)}")

# ── Load SP source code ───────────────────────────────────────────────────────
def load_source(db: str, sp: str) -> str:
    """Returns SPL source code, truncated to MAX_CODE_CHARS."""
    sp_clean = sp.split(":")[-1] if ":" in sp else sp
    fname = SRC / f"{db}_{sp_clean}.sql"
    if not fname.exists():
        return ""
    txt = fname.read_text(encoding="utf-8", errors="replace")
    if len(txt) > MAX_CODE_CHARS:
        txt = txt[:MAX_CODE_CHARS] + "\n... [truncado]"
    return txt

# ── Build prompt ──────────────────────────────────────────────────────────────
SYSTEM = textwrap.dedent("""\
    Eres un analista experto en sistemas bancarios Informix SPL para BanCoppel (México).
    Tu única tarea es generar nombres de reglas de negocio en español claro, concreto y sin jerga técnica SPL.

    Reglas para el nombre (business_name):
    - Máximo 65 caracteres
    - Describe QUÉ HACE la regla en términos de negocio (no copies el código)
    - Usa verbos de negocio: "Validar", "Calcular", "Registrar", "Verificar", "Aplicar", "Obtener", "Rechazar", "Autorizar"
    - Sé específico: "Validar saldo disponible ≥ monto del cargo" es mejor que "Validar saldo"
    - Evita: nombres de variables SPL (v_monto, cCodRet), comandos SQL, rutas de archivo
    - Si el código es una fórmula: "Cálculo de [qué se calcula]"
    - Si el código es una validación: "Verificar que [condición de negocio]"
    - Si el código es un umbral: "Umbral [qué límite] para [qué contexto]"
    - Responde SOLO con un array JSON válido, sin markdown ni texto adicional.
""")

def build_prompt(sp_key: str, rules: list, source: str) -> str:
    db, sp = sp_key.split(":", 1)
    domain = (rules[0].get("dominio") or "").strip()
    rules_list = [{"id": r["id"], "tipo": r.get("tipo",""), "code": (r.get("code","") or "")[:200]}
                  for r in rules]
    src_block = f"\nCódigo fuente SPL:\n```\n{source}\n```\n" if source else "\n[Código fuente no disponible]\n"
    return (
        f"SP: `{sp}` · Base: `{db}` · Dominio: {domain}\n"
        f"{src_block}\n"
        f"Genera business_name para cada regla. Responde SOLO con este JSON:\n"
        f"[{{\"id\":\"BR-V2-XXXX\",\"name\":\"...\"}},...]\n\n"
        f"Reglas:\n{json.dumps(rules_list, ensure_ascii=False, indent=2)}"
    )

# ── Call Claude API ───────────────────────────────────────────────────────────
def call_claude(prompt: str, client) -> list[dict]:
    """Returns list of {id, name} dicts."""
    msg = client.messages.create(
        model=MODEL,
        max_tokens=1024,
        system=SYSTEM,
        messages=[{"role": "user", "content": prompt}],
    )
    raw = msg.content[0].text.strip()
    # Strip markdown fences if present
    raw = re.sub(r'^```[a-z]*\n?', '', raw).rstrip('`').strip()
    return json.loads(raw)

# ── Save overrides helper ────────────────────────────────────────────────────
def save_progress():
    OVERRIDES.parent.mkdir(parents=True, exist_ok=True)
    with open(OVERRIDES, "w", encoding="utf-8") as f:
        json.dump({"names": overrides, "processed_sps": list(processed_sps)},
                  f, ensure_ascii=False, indent=2)

# ── Main loop ─────────────────────────────────────────────────────────────────
if args.dry_run:
    print("\n=== DRY RUN — primeras 5 SPs ===")
    for i, (sp_key, rules) in enumerate(list(pending.items())[:5]):
        db, sp = sp_key.split(":", 1)
        source = load_source(db, sp)
        # Split into batches
        for batch_start in range(0, len(rules), MAX_RULES_PER_CALL):
            batch = rules[batch_start:batch_start + MAX_RULES_PER_CALL]
            prompt = build_prompt(sp_key, batch, source)
            print(f"\n--- SP {i+1}: {sp_key} ({len(batch)} reglas) ---")
            print(prompt[:800] + ("..." if len(prompt) > 800 else ""))
    sys.exit(0)

# Real run
try:
    import anthropic
except ImportError:
    print("ERROR: pip install anthropic")
    sys.exit(1)

api_key = os.environ.get("ANTHROPIC_API_KEY", "")
if not api_key:
    # Try reading from .env in BASE
    env_file = BASE / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if line.startswith("ANTHROPIC_API_KEY="):
                api_key = line.split("=", 1)[1].strip().strip('"')
                break
if not api_key:
    print("ERROR: ANTHROPIC_API_KEY no encontrada. Exporta la variable de entorno.")
    sys.exit(1)

client = anthropic.Anthropic(api_key=api_key)

total_sps   = len(pending)
done        = 0
errors      = 0
names_added = 0
save_every  = 50   # guardar progreso cada N SPs

print(f"\nIniciando enriquecimiento: {total_sps} SPs · modelo {MODEL}")
print("Ctrl+C para pausar (el progreso se guarda automáticamente)\n")

try:
    for sp_key, rules in pending.items():
        db, sp = sp_key.split(":", 1)
        source = load_source(db, sp)

        # Procesar en batches si el SP tiene muchas reglas
        sp_ok = True
        for batch_start in range(0, len(rules), MAX_RULES_PER_CALL):
            batch = rules[batch_start:batch_start + MAX_RULES_PER_CALL]
            prompt = build_prompt(sp_key, batch, source)
            try:
                results = call_claude(prompt, client)
                for item in results:
                    rid  = item.get("id", "")
                    name = (item.get("name") or item.get("business_name") or "").strip()
                    if rid and name:
                        overrides[rid] = name
                        names_added += 1
                time.sleep(0.3)   # respetar rate limit
            except Exception as e:
                print(f"  ERROR en {sp_key} batch {batch_start}: {e}")
                errors += 1
                sp_ok = False
                time.sleep(2)
                break

        if sp_ok:
            processed_sps.add(sp_key)
        done += 1

        if done % 10 == 0:
            pct = 100 * done / total_sps
            print(f"  [{done}/{total_sps} {pct:.0f}%] names: {names_added} errors: {errors}", flush=True)

        if done % save_every == 0:
            save_progress()

except KeyboardInterrupt:
    print("\n\nInterrumpido. Guardando progreso...")

save_progress()
print(f"\nDone. SPs procesados: {done}/{total_sps} · Names: {names_added} · Errors: {errors}")
print(f"Overrides guardados en: {OVERRIDES}")
print(f"\nAplica con: python generators/enrich-names-ai.py --apply")
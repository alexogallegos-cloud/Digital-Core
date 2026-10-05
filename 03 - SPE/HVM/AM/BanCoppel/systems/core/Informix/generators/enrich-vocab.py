"""
enrich-vocab.py — Enriquece mean_inferred + confidence para candidatos en vocab-candidates.json

Dos passes internos en secuencia:
  Pass 1 — Rule-based (sin LLM, instantáneo)
    · Señal A: Compound decomposition        → ALTA
    · Señal B: SP verb pattern               → MEDIA  (+ ALTA si code_vars refuerza)
    · Señal C: Variable names en código SPL  → MEDIA

  Pass 2 — DT Swarm via Claude Code CLI (solo candidatos que quedaron BAJA)
    · Lotes de ≤10 candidatos por llamada a `claude --print`
    · Contexto por token: freq + sample SPs + snippets de código SPL
    · Checkpoint tras cada lote — reanudable si se interrumpe

No requiere API key — usa la sesión autenticada del CLI de Claude Code.

Uso:
  python generators/enrich-vocab.py                  # pass 1 + pass 2 (solo BAJA)
  python generators/enrich-vocab.py --rules-only     # solo pass 1 (sin swarm)
  python generators/enrich-vocab.py --swarm-all      # pass 1 + swarm sobre todos
  python generators/enrich-vocab.py --force          # reprocesa también los ya enriquecidos
  python generators/enrich-vocab.py --dry-run        # muestra primer batch del swarm, no llama CLI
  python generators/enrich-vocab.py --batch 50       # limita swarm a N candidatos
"""
import json, re, subprocess, sys, time
from pathlib import Path
from unicodedata import normalize

BASE      = Path(__file__).resolve().parent.parent
RULES_DIR = BASE / "knowledge-base" / "rules" / "batches"
VOCAB     = Path(__file__).resolve().parent / "sp_vocab.py"

TEST_UNIVERSE = "--test-universe" in sys.argv
CAND = BASE / "knowledge-base" / ("vocab-candidates-tu.json" if TEST_UNIVERSE else "vocab-candidates.json")

RULES_ONLY = "--rules-only" in sys.argv
SWARM_ALL  = "--swarm-all"  in sys.argv
FORCE      = "--force"      in sys.argv
DRY_RUN    = "--dry-run"    in sys.argv
BATCH_MAX  = 10

_limit = None
for i, a in enumerate(sys.argv):
    if a == "--batch" and i + 1 < len(sys.argv):
        try: _limit = int(sys.argv[i + 1])
        except ValueError: pass

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

def _norm(s):
    return normalize("NFKD", str(s).lower()).encode("ascii", "ignore").decode()


# ═══════════════════════════════════════════════════════════════════════════════
# CARGA DE DATOS
# ═══════════════════════════════════════════════════════════════════════════════

def load_vocab() -> dict:
    """Parsea sp_vocab.py → {token: (cat, mean, est)}."""
    text = VOCAB.read_text(encoding="utf-8")
    pat  = re.compile(r'"([^"]+)"\s*:\s*\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)')
    vocab = {}
    for m in pat.finditer(text):
        tok, cat, mean, est = m.groups()
        vocab[tok] = (cat, mean, est)
    return vocab

def load_all_rules() -> list:
    rules = []
    for f in RULES_DIR.rglob("*.json"):
        try:
            rules.extend(json.loads(f.read_text(encoding="utf-8")).get("rules", []))
        except Exception:
            pass
    return rules

def build_code_index(rules: list) -> dict:
    """token → set de SP names donde aparece como variable."""
    idx = {}
    strip = re.compile(r'^(?:v_|p_|dt_|n_|c_|l_|s_|r_|w_)')
    for rule in rules:
        code = rule.get("code", "")
        sp   = rule.get("sp", "")
        if not code or not sp:
            continue
        for word in re.findall(r'[a-zA-Z_][a-zA-Z0-9_]*', code):
            tok = strip.sub("", word.lower())
            if len(tok) >= 4:
                idx.setdefault(tok, set()).add(sp)
    return idx

def build_snippet_index(rules: list) -> dict:
    """token → list of (sp, db, code_snippet) para contexto del swarm."""
    idx = {}
    prefix_re = re.compile(r'\b(?:v|p|dt|n|c|l|s|r|w)_?(\w{3,})\b')
    for rule in rules:
        sp, db, code = rule.get("sp",""), rule.get("db",""), rule.get("code","")
        if not code or len(code) < 5:
            continue
        for m in prefix_re.finditer(code):
            tok = _norm(m.group(1))
            if len(tok) < 4:
                continue
            entry = (sp, db, code[:120].strip())
            if entry not in idx.get(tok, []):
                idx.setdefault(tok, []).append(entry)
    return idx


# ═══════════════════════════════════════════════════════════════════════════════
# PASS 1 — RULE-BASED
# ═══════════════════════════════════════════════════════════════════════════════

_SP_VERB = {
    "consulta": "Entidad consultada",   "cons":     "Entidad consultada",
    "obtiene":  "Dato obtenido",        "obt":      "Dato obtenido",
    "actualiza":"Entidad actualizable", "act":      "Entidad actualizable",
    "genera":   "Elemento generado",
    "valida":   "Elemento sujeto a validación", "val": "Elemento sujeto a validación",
    "cancela":  "Elemento cancelable",
    "registra": "Elemento registrado",
    "calcula":  "Valor calculado",      "calc":     "Valor calculado",
    "aplica":   "Elemento al que se aplica la operación",
    "procesa":  "Elemento procesado",
    "busca":    "Entidad buscada",
    "autoriza": "Elemento en flujo de autorización", "aut": "Elemento en flujo de autorización",
    "cobra":    "Elemento cobrado",
    "paga":     "Elemento pagado",
    "dispersa": "Elemento dispersado",
    "liquida":  "Elemento liquidado",
    "concilia": "Elemento conciliado",
    "acredita": "Elemento acreditado",
    "amortiza": "Elemento amortizado",
    "emite":    "Elemento emitido",
}

def _sig_compound(token, vocab):
    n = len(token)
    for i in range(3, n - 1):
        left, right = token[:i], token[i:]
        if left in vocab and right in vocab:
            lm, rm = vocab[left][1], vocab[right][1]
            if lm and rm:
                return f"{lm} de {rm}".capitalize(), "ALTA", f"compound:{left}+{right}"
    return None, None, None

def _sig_sp_verb(token, sample_sps):
    for sp_entry in sample_sps:
        sp_name = sp_entry.split(":")[-1].strip()
        clean   = re.sub(r'^sps?_', "", sp_name)
        parts   = clean.split("_")
        if parts and parts[0] in _SP_VERB:
            return _SP_VERB[parts[0]], "MEDIA", f"sp_verb:{sp_name}→{parts[0]}"
    return None, None, None

def _sig_code_vars(token, code_idx):
    sp_set = code_idx.get(token, set())
    if len(sp_set) >= 3:
        return f"Concepto presente en {sorted(sp_set)[0]}", "MEDIA", f"code_vars:{len(sp_set)} SPs"
    return None, None, None

def pass1_enrich(candidate, vocab, code_idx):
    tok    = candidate["token"]
    m1, c1, s1 = _sig_compound(tok, vocab)
    if m1:
        candidate.update(mean_inferred=m1, confidence="ALTA", signals=[s1])
        return

    m2, c2, s2 = _sig_sp_verb(tok, candidate.get("sample_sps", []))
    m3, c3, s3 = _sig_code_vars(tok, code_idx)

    if m2 and m3:
        candidate.update(mean_inferred=m2, confidence="ALTA", signals=[s2, s3])
    elif m2:
        candidate.update(mean_inferred=m2, confidence="MEDIA", signals=[s2])
    elif m3:
        candidate.update(mean_inferred=m3, confidence="MEDIA", signals=[s3])
    else:
        candidate.update(mean_inferred="", confidence="BAJA", signals=[])


# ═══════════════════════════════════════════════════════════════════════════════
# PASS 2 — DT SWARM (claude --print)
# ═══════════════════════════════════════════════════════════════════════════════

def _few_shot_lines(vocab, n=20):
    lines = []
    for tok, (cat, mean, est) in vocab.items():
        if est in ("conf", "inf") and mean and mean.lower() != tok.lower() and len(mean) > 10:
            lines.append(f'  {tok:<20} [{cat}]  "{mean}"')
        if len(lines) >= n:
            break
    return "\n".join(lines)

def _build_ctx(item, snippet_idx, max_s=3):
    tok      = item["token"]
    freq     = item.get("freq", 0)
    sample   = item.get("sample_sps", [])[:4]
    snippets = snippet_idx.get(_norm(tok), [])[:max_s]
    lines    = [f'token: "{tok}"  freq={freq}  cat_inferida={item.get("inferred_cat","?")}']
    if sample:
        lines.append(f'  SPs de muestra: {", ".join(sample)}')
    if snippets:
        lines.append("  Snippets de código SPL:")
        for sp, db, code in snippets:
            lines.append(f'    [{db}:{sp}] {code}')
    return "\n".join(lines)

def _build_prompt(batch_ctxs, few_shot):
    items_block = "\n\n".join(f"--- Candidato {i+1} ---\n{c}" for i, c in enumerate(batch_ctxs))
    n = len(batch_ctxs)
    return f"""Eres un Especialista en análisis semántico del core bancario de BanCoppel.
BanCoppel opera sobre IBM Informix IDS 14.10 en AIX/POWER con código SPL (Stored Procedure Language).
Los tokens son fragmentos de nombres de stored procedures, parámetros, tablas y variables.

Vocabulario de referencia (ejemplos validados):
{few_shot}

Categorías válidas:
  ENTIDAD — sustantivo del dominio (cuenta, cliente, producto, movimiento, crédito)
  ACCION  — verbo/proceso que ejecuta el sistema (calcular, aplicar, dispersar)
  MODIF   — modificador/calificador (activo, inicial, vigente, anterior)
  REG     — identificador regulado (RFC, CURP, CLABE, NSS)
  PREFIJO — prefijo que combina con otros términos (num, id, fec, mto)

Reglas:
- Significado en español, máx 120 chars, orientado al negocio bancario mexicano.
- Si el token es una abreviatura, expándela. Si es compuesto, compone el significado.
- confidence: ALTA = señal clara; MEDIA = razonable; BAJA = solo suposición.
- Responde ÚNICAMENTE con un array JSON válido, sin texto adicional ni markdown.

Analiza los siguientes {n} tokens e infiere su significado de negocio:

{items_block}

Responde con un array JSON de exactamente {n} objetos, en el mismo orden:
[
  {{
    "token": "<token exacto>",
    "mean": "<significado de negocio en español, máx 120 chars>",
    "cat": "<ENTIDAD|ACCION|MODIF|REG|PREFIJO>",
    "confidence": "<ALTA|MEDIA|BAJA>",
    "razon": "<1 frase explicando la señal usada>"
  }}
]"""

def _find_claude():
    """Resuelve la ruta al CLI de Claude Code (Windows .cmd o Unix binario)."""
    import shutil
    found = shutil.which("claude") or shutil.which("claude.cmd")
    if found:
        return found
    npm_win = Path.home() / "AppData" / "Roaming" / "npm" / "claude.cmd"
    if npm_win.exists():
        return str(npm_win)
    raise FileNotFoundError(
        "CLI de Claude Code no encontrado. "
        "Instálalo con: npm install -g @anthropic-ai/claude-code"
    )

_CLAUDE_BIN = None

def _call_claude(prompt_text, retries=3):
    global _CLAUDE_BIN
    if _CLAUDE_BIN is None:
        _CLAUDE_BIN = _find_claude()
    for attempt in range(retries):
        try:
            proc = subprocess.run(
                [_CLAUDE_BIN, "--print"],
                input=prompt_text,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=180,
            )
            if proc.returncode != 0:
                raise RuntimeError(f"claude exit {proc.returncode}: {proc.stderr[:200]}")
            m = re.search(r'\[.*\]', proc.stdout.strip(), re.DOTALL)
            if not m:
                raise ValueError(f"Sin bloque JSON: {proc.stdout[:200]}")
            return json.loads(m.group(0))
        except Exception as e:
            print(f"  [attempt {attempt+1}] {e}")
            if attempt < retries - 1:
                time.sleep(3 * (attempt + 1))
    return []

def pass2_swarm(to_process, cand_data, item_idx, snippet_idx, few_shot):
    n_lotes = -(-len(to_process) // BATCH_MAX)
    print(f"\nPass 2 — Swarm: {len(to_process)} candidatos BAJA · {n_lotes} lotes")

    n_ok = n_err = 0
    for batch_start in range(0, len(to_process), BATCH_MAX):
        batch     = to_process[batch_start: batch_start + BATCH_MAX]
        tokens_in = [x["token"] for x in batch]
        ctxs      = [_build_ctx(x, snippet_idx) for x in batch]
        lote_num  = batch_start // BATCH_MAX + 1

        print(f"  Lote {lote_num}/{n_lotes}: {tokens_in[:3]}{'...' if len(batch)>3 else ''}", end=" ", flush=True)

        results = _call_claude(_build_prompt(ctxs, few_shot))
        if not results:
            print("✗ sin respuesta")
            n_err += len(batch)
            continue

        matched = 0
        for r in results:
            tok = r.get("token", "")
            if tok not in item_idx:
                tok = next((t for t in tokens_in if t in r.get("token", "")), "")
            if tok and tok in item_idx:
                item_idx[tok]["mean_inferred"] = r.get("mean", "")
                item_idx[tok]["cat_confirmed"] = r.get("cat", item_idx[tok].get("inferred_cat"))
                item_idx[tok]["confidence"]    = r.get("confidence", "MEDIA")
                item_idx[tok]["signals"]       = [f"swarm: {r.get('razon','')}"]
                matched += 1
                n_ok += 1

        print(f"✓ {matched}/{len(batch)}")
        CAND.write_text(json.dumps(cand_data, ensure_ascii=False, indent=2), encoding="utf-8")

    return n_ok, n_err


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    print("Cargando vocab de sp_vocab.py...")
    vocab = load_vocab()
    print(f"  {len(vocab)} términos")

    print("Cargando reglas SPL...")
    rules = load_all_rules()
    print(f"  {len(rules)} reglas")

    code_idx    = build_code_index(rules)
    snippet_idx = build_snippet_index(rules)
    print(f"  {len(code_idx)} tokens indexados en código")

    cand_data = json.loads(CAND.read_text(encoding="utf-8"))
    all_items = cand_data.get("new", [])

    # ── Pass 1 ────────────────────────────────────────────────────────────────
    print(f"\nPass 1 — Rule-based: {len(all_items)} candidatos...")
    p1_proc = p1_skip = alta = media = baja = 0

    for c in all_items:
        if not FORCE and c.get("mean_inferred") and c.get("confidence") != "BAJA":
            p1_skip += 1
            continue
        pass1_enrich(c, vocab, code_idx)
        p1_proc += 1
        conf = c.get("confidence", "BAJA")
        if conf == "ALTA":   alta  += 1
        elif conf == "MEDIA": media += 1
        else:                 baja  += 1

    CAND.write_text(json.dumps(cand_data, ensure_ascii=False, indent=2), encoding="utf-8")
    cov = round((alta + media) / p1_proc * 100, 1) if p1_proc else 0
    print(f"  Procesados: {p1_proc}  Saltados: {p1_skip}")
    print(f"  ALTA: {alta}  MEDIA: {media}  BAJA: {baja}  Cobertura: {cov}%")

    if RULES_ONLY:
        print("\n(--rules-only: swarm omitido)")
        print("Próximo paso: python generators/build-vocab-catalog.py")
        return

    # ── Pass 2 ────────────────────────────────────────────────────────────────
    item_idx = {x["token"]: x for x in all_items}

    if SWARM_ALL:
        swarm_targets = all_items
    else:
        swarm_targets = [x for x in all_items if x.get("confidence") == "BAJA"]

    if _limit:
        swarm_targets = swarm_targets[:_limit]

    if DRY_RUN:
        print(f"\n=== DRY RUN — primer batch del swarm ({len(swarm_targets)} BAJA) ===\n")
        sample = swarm_targets[:BATCH_MAX]
        ctxs   = [_build_ctx(x, snippet_idx) for x in sample]
        print(_build_prompt(ctxs, _few_shot_lines(vocab)))
        return

    if not swarm_targets:
        print("\nPass 2 — Swarm: nada que procesar (0 BAJA). ✓")
        print("Próximo paso: python generators/build-vocab-catalog.py")
        return

    few_shot      = _few_shot_lines(vocab)
    n_ok, n_err   = pass2_swarm(swarm_targets, cand_data, item_idx, snippet_idx, few_shot)

    # ── Resumen final ─────────────────────────────────────────────────────────
    enriched = [x for x in all_items if x.get("mean_inferred")]
    alta_f  = sum(1 for x in enriched if x.get("confidence") == "ALTA")
    media_f = sum(1 for x in enriched if x.get("confidence") == "MEDIA")
    baja_f  = sum(1 for x in enriched if x.get("confidence") == "BAJA")

    print(f"\n{CAND.name} actualizado")
    print(f"  Swarm OK: {n_ok}  Errores: {n_err}")
    print(f"  ALTA: {alta_f}  MEDIA: {media_f}  BAJA: {baja_f}")
    print(f"  Cobertura total: {len(enriched)}/{len(all_items)} = {len(enriched)/len(all_items)*100:.0f}%")
    print(f"\nPróximo paso: python generators/build-vocab-catalog.py")


if __name__ == "__main__":
    main()

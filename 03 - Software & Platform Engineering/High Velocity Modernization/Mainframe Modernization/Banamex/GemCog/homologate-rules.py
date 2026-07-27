"""
homologate-rules.py — Ola 2/3 del schema canónico de reglas (GemCog).
Aplica schema-canonico-reglas.md a rules-catalog/*.md.

Fase MECÁNICA únicamente:
  - remap de campos (3 variantes -> canónico)
  - inyección de BC-ID + bian_ref desde program-registry (llave: sistema+programa)
  - siembra de Versión, Estado ciclo, Veredicto=PENDIENTE SME, Fecha
Los campos de enriquecimiento (Tipo regla SBVR, Condición/Consecuencia,
Evidencia código exacta, Dataset DMSII) se marcan como gap dirigido, NO se inventan.

Modo por defecto = DRY-RUN (no escribe archivos de reglas).
  python homologate-rules.py                 -> reporte de resolución + preview
  python homologate-rules.py --apply FILE     -> reescribe FILE (uso posterior, Ola 3)
"""
import re, glob, os, sys, datetime

BASE = os.path.dirname(os.path.abspath(__file__))
RD   = os.path.join(BASE, "rules-catalog")
TODAY = datetime.date.today().isoformat()

# ─────────────────────────────────────────────────────────────────────────────
# 1. Lookup (sistema, programa) -> (BC-ID, bian_ref) desde program-registry-*
# ─────────────────────────────────────────────────────────────────────────────
def norm_prog(raw):
    """Extrae el programa base P<num> de tokens como S500P630, S151/P312, P010_PAR."""
    if not raw: return None
    m = re.search(r'P(\d{2,4})', raw.upper())
    return f"P{m.group(1)}" if m else None

def load_registry():
    lut = {}            # (sys, Pbase) -> (bc, bian)
    variants = {}       # (sys, Pbase) -> set de nombres completos (detección de colisión)
    for fn, sys_ in [("program-registry-s500.md","S500"), ("program-registry-s151.md","S151")]:
        fp = os.path.join(BASE, fn)
        if not os.path.exists(fp):
            print(f"  !! falta {fn}"); continue
        for l in open(fp, encoding="utf-8"):
            if not l.lstrip().startswith("|"): continue
            cells = [c.strip().strip("*").strip() for c in l.strip().strip("|").split("|")]
            prog = bc = bian = None
            full = None
            for c in cells:
                if prog is None and re.fullmatch(r'P\d{2,4}(?:_[A-Z0-9]+)?', c):
                    full = c; prog = norm_prog(c)
                elif bc is None and re.fullmatch(r'BC-\d+\*?', c):
                    bc = c.rstrip("*")
                elif bian is None and re.fullmatch(r'[0-9T]\.\d(?:\.\d)?', c):
                    bian = c
            if prog and bc:
                key = (sys_, prog)
                variants.setdefault(key, set()).add(full)
                if key not in lut:            # base: primer match gana; colisión se reporta aparte
                    lut[key] = (bc, bian or "—")
                if full and full.upper() != prog:   # llave exacta de variante (P010_PAR)
                    lut[(sys_, full.upper())] = (bc, bian or "—")
    collisions = {k: v for k, v in variants.items() if len(v) > 1}
    return lut, collisions

# ─────────────────────────────────────────────────────────────────────────────
# 2. Parsing de reglas (tolera las 3 variantes)
# ─────────────────────────────────────────────────────────────────────────────
def meta(part, *fields):
    for f in fields:
        m = re.search(rf'\*\*{re.escape(f)}\*\*\s*\|\s*([^\n|]+)', part)
        if m: return m.group(1).strip()
    return ""

def split_rules(text):
    parts = re.split(r'\n(?=#{2,3} RN-S(?:151|500)-\d+)', text)
    out = []
    for p in parts:
        hm = re.match(r'#{2,3} (RN-S(?:151|500)-\d+)[ \t]*[—\-|:]?[ \t]*([^\n]*)', p)
        if hm:
            out.append((hm.group(1).strip(), re.sub(r'\|.*$','',hm.group(2) or '').strip(), p))
    return out

def resolve_program(part, base):
    raw = meta(part, "Programa ejecutor", "Programa(s) fuente", "Programa fuente", "Programa(s)", "Programa")
    if not raw:
        fn = re.findall(r'-([pP]\d+)', base)
        raw = fn[0] if fn else ""
    first = re.split(r'[·,]', raw)[0].strip() if raw else ""
    mf = re.search(r'P\d{2,4}_[A-Z0-9]+', (raw or "").upper())   # variante exacta P010_PAR
    full = mf.group(0) if mf else None
    # norm_prog sobre el raw completo: captura P312 en "S151/P312", "P312 · P330", etc.
    return (first or raw), (norm_prog(raw) or norm_prog(first)), full

# Overrides de archivos de arquitectura (no llevan BC de negocio)
ARCH_FILES = ("algol-wfl-stubs", "l030", "dasdl")
def arch_bc(fname):
    if "l002" in fname: return ("BC-04", "—")   # ACL técnico S500<->S151
    if any(a in fname for a in ARCH_FILES): return ("— (arquitectura AS-IS · RETAIN/ENCAPSULATE · no BC de negocio)", "—")
    return None

# ─────────────────────────────────────────────────────────────────────────────
# 3. Reporte de resolución sobre los 33 archivos
# ─────────────────────────────────────────────────────────────────────────────
def resolution_report(lut):
    files = sorted(glob.glob(os.path.join(RD, "*.md")))
    tot_rules = tot_res = 0
    orphans = []
    print(f"{'Archivo':45} {'Sys':4} {'Reglas':>6} {'BC-ok':>6} {'Huérf':>6}")
    print("-"*75)
    for fp in files:
        base = os.path.basename(fp)
        if base in ("rules-index.md","schema-canonico-reglas.md","homologation-inventory.md"): continue
        txt = open(fp, encoding="utf-8").read()
        rules = split_rules(txt)
        if not rules: continue
        res = 0; forph = []
        for rid, title, part in rules:
            sys_ = "S500" if "S500" in rid else "S151"
            first, pb, full = resolve_program(part, base)
            if (full and (sys_, full) in lut) or (pb and (sys_, pb) in lut) or arch_bc(base):
                res += 1
            else:
                forph.append((rid, first or "—", pb or "—"))
        tot_rules += len(rules); tot_res += res
        if forph: orphans.append((base, forph))
        print(f"{base:45} {('S500' if 's500' in base else 'S151'):4} {len(rules):>6} {res:>6} {len(rules)-res:>6}")
    print("-"*75)
    print(f"{'TOTAL':45} {'':4} {tot_rules:>6} {tot_res:>6} {tot_rules-tot_res:>6}")
    print(f"\nCobertura BC-ID: {tot_res}/{tot_rules} = {100*tot_res/tot_rules:.1f}%")
    if orphans:
        print("\n== Reglas huérfanas (programa sin BC-ID en registry -> Consulta SME Mainframe Migration) ==")
        for base, forph in orphans:
            uniq = sorted(set(p for _,p,_ in forph))
            print(f"  {base}: {len(forph)} reglas · programas: {', '.join(uniq[:15])}")

# ─────────────────────────────────────────────────────────────────────────────
# 4. Preview mecánico de rules-s151.md (primeras N reglas) — NO escribe el real
# ─────────────────────────────────────────────────────────────────────────────
def split_head_table_body(part):
    """Separa (heading, tabla-metadatos-vieja, cuerpo restante) de una regla."""
    lines = part.split("\n")
    head = lines[0]
    i = 1
    while i < len(lines) and not lines[i].strip().startswith("|"): i += 1
    tstart = i
    while i < len(lines) and lines[i].strip().startswith("|"): i += 1
    tend = i
    body = "\n".join(lines[tend:]).strip()
    return head, "\n".join(lines[tstart:tend]), body

def canonical_card(rid, title, part, sys_, lut, fname=""):
    """Reescribe la tabla de metadatos a canónica; PRESERVA el cuerpo verbatim (cero pérdida)."""
    head, _oldtable, body = split_head_table_body(part)
    body = re.sub(r'\n*-{3,}\s*$', '', body).rstrip()   # quita separador --- final duplicado
    first, pb, full = resolve_program(part, fname)
    if full and (sys_, full) in lut:          # variante exacta (P010_PAR) gana
        bc, bian = lut[(sys_, full)]
    elif (sys_, pb) in lut:
        bc, bian = lut[(sys_, pb)]
    elif arch_bc(fname):                        # archivo de arquitectura
        bc, bian = arch_bc(fname)
    elif re.search(r'\bL\d{2,3}\b|L002|WFL|ALGOL', (first or ""), re.I):   # librería/WFL/ALGOL embebida
        bc, bian = "— (arquitectura/librería · no BC de negocio)", "—"
    else:                                        # copybook o programa sin mapear -> consulta dirigida
        bc, bian = "Consulta SME Mainframe Migration", "—"
    tipo_tec = meta(part, "Tipo") or "—"
    regulador = meta(part, "Regulador", "Base regulatoria") or "—"
    conf = (meta(part, "Confianza") or "—").lower()
    prog_disp = first if (first and norm_prog(first)) else (pb or first or "—")
    table = (
        "| Campo | Valor |\n"
        "|-------|-------|\n"
        f"| **Identificador** | {rid} |\n"
        f"| **Nombre** | {title} |\n"
        f"| **Versión** | v2 |\n"
        f"| **Estado ciclo** | En validación |\n"
        f"| **Fecha actualización** | {TODAY} |\n"
        f"| **BC-ID** | {bc} |\n"
        f"| **bian_ref** | {bian} |\n"
        f"| **Tipo regla** | Consulta análisis SBVR (dt-mainframe-analyst) |\n"
        f"| **Tipo técnico** | {tipo_tec} |\n"
        f"| **Confianza** | {conf} |\n"
        f"| **Veredicto** | PENDIENTE SME |\n"
        f"| **Regulador** | {regulador} |\n"
        f"| **Programa ejecutor** | {prog_disp} |\n"
        f"| **Evidencia código** | Análisis fuente (dt-mainframe-analyst): elevar Traza de código a archivo:línea exacta |\n"
        f"| **Dataset DMSII** | Análisis interno: derivar de Campos COBOL / DASDL |\n"
    )
    return f"{head}\n\n{table}\n{body}".rstrip() + "\n"

def homologate_text(txt, lut, fname):
    """Reconstruye el archivo completo: preámbulo + reglas homologadas."""
    rules = split_rules(txt)
    if not rules: return txt, 0
    # preámbulo = todo antes de la primera regla (inicio de línea del heading)
    first_rule_id = rules[0][0]
    m = re.search(r'(?m)^#{2,3} ' + re.escape(first_rule_id) + r'\b', txt)
    idx = m.start() if m else 0
    pre = re.sub(r'\n*-{3,}\s*$', '', txt[:idx].rstrip()).rstrip() + "\n\n---\n\n"
    cards = []
    for rid, title, part in rules:
        sys_ = "S500" if "S500" in rid else "S151"
        cards.append(canonical_card(rid, title, part, sys_, lut, fname))
    return pre + "\n---\n\n".join(cards), len(rules)

SKIP = ("rules-index.md", "schema-canonico-reglas.md", "homologation-inventory.md")
def is_migrated(txt):
    return "| **Identificador** |" in txt and "| **BC-ID** |" in txt

def apply_file(fname, lut):
    fp = os.path.join(RD, fname)
    txt = open(fp, encoding="utf-8").read()
    new, n = homologate_text(txt, lut, fname)
    open(fp, "w", encoding="utf-8").write(new)
    print(f"APLICADO: {fname} · {n} reglas homologadas (metadatos canónicos, cuerpo preservado)")

def apply_all(lut):
    for fp in sorted(glob.glob(os.path.join(RD, "*.md"))):
        base = os.path.basename(fp)
        if base in SKIP or base.startswith("_"): continue
        txt = open(fp, encoding="utf-8").read()
        if is_migrated(txt):
            print(f"SKIP (ya migrado): {base}"); continue
        apply_file(base, lut)

if __name__ == "__main__":
    lut, collisions = load_registry()
    print(f"Lookup cargado: {len(lut)} entradas (sistema, programa) -> BC-ID\n")
    if len(sys.argv) >= 2 and sys.argv[1] == "--apply-all":
        apply_all(lut)
    elif len(sys.argv) >= 3 and sys.argv[1] == "--apply":
        apply_file(sys.argv[2], lut)
    else:
        if collisions:
            print("== Colisiones de variante (mismo P base, varios nombres en registry) ==")
            for (s,p), names in sorted(collisions.items()):
                print(f"  {s} {p}: {', '.join(sorted(names))}")
            print()
        resolution_report(lut)

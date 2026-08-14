"""
build-traceability.py
Teje las 3 capas del Gemelo Cognitivo:
  Capa 2 Reglas (rules-catalog/*.md) ↔ Capa 3 Capacidades (capacidades/cap-*.md + taxonomía)
                                      ↔ Capa 1 Vocabulario (data/*/vocab-*.md)

Produce:
  1. Normalización de capacidad por regla (257 variantes → ID canónico BIAN).
  2. Actualiza "> Reglas vinculadas:" en cada cap-*.md con la lista completa y vigente.
  3. traceability-matrix.md   — capacidad → reglas (+ cobertura, + reglas sin capacidad).
  4. vocab-rules-xref.md      — término de vocab → reglas que lo citan.
"""
import re, glob, os
from collections import defaultdict

BASE = os.path.dirname(os.path.abspath(__file__))
RD   = os.path.join(BASE, "rules-catalog")

# ── Mapas de referencia ───────────────────────────────────────────────────────
def load_taxonomy():
    """canon: ID → 'ID Nombre'  ·  taxpath: ID → (dominio, subdominio, capacidad)."""
    canon = {}; taxpath = {}
    for l in open(os.path.join(BASE, "capability-model-taxonomy.md"), encoding="utf-8"):
        # tabla principal: | ID | Dominio | Sub-categoría | Capacidad | S500 | S151 | AMBOS |
        m = re.match(r'\|\s*([0-9T]\.\d(?:\.\d)?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|', l)
        if m and m.group(1) not in canon:
            cid, dom, sub, name = m.group(1), m.group(2).strip(), m.group(3).strip(), m.group(4).strip()
            if "P##" not in name and "→" not in name and dom.lower() != "dominio":
                canon[cid] = f"{cid} {name}"
                taxpath[cid] = (dom, sub, name)
    return canon, taxpath

def load_prog2id():
    p2 = {}
    for bf in ["bian-mapping-s500.md", "bian-mapping-s151.md"]:
        for l in open(os.path.join(BASE, bf), encoding="utf-8"):
            cells = [c.strip().strip("*").strip() for c in l.split("|")]
            if len(cells) < 6: continue
            prog = cells[1]
            ids = [c for c in cells if re.fullmatch(r'[0-9T]\.\d(?:\.\d)?', c)]
            if prog and re.match(r'[A-Z]', prog) and ids:
                p2[prog.upper()] = ids[0]
    return p2

def load_capfiles():
    cf = {}
    for f in glob.glob(os.path.join(BASE, "capacidades", "cap-*.md")):
        head = open(f, encoding="utf-8").read()[:600]
        ids = re.findall(r'\*\*([0-9T]\.\d(?:\.\d)?)', head) or re.findall(r'([0-9T]\.\d(?:\.\d)?)', head)
        if ids: cf[ids[0]] = f   # ID → filepath (first cap file wins per ID)
    return cf

# ── Normalización de capacidad ────────────────────────────────────────────────
CAP_ALIAS = [
    (r'gl posting|gl saldos|gl ', '7.1.1'),
    (r'cierre diario|cambio de d|control batch|procesamiento (batch|nocturno)|recuperaci', '8.1.1'),
    (r'observabilidad', 'T.3.4'),
    (r'integraci', 'T.2.3'),
    (r'seguridad|scrambl', 'T.3.5'),
    (r'concili|punteo', '6.7.1'),
    (r'reporte|cnbv|analytics', 'T.3.4'),
]
# Override explícito y auditable para casos sin programa mapeable en bian-mapping
PROG_CAP = [   # (substring en programa, ID canónico) — validado por dominio
    ("S500P630", "2.2.6"),   # TARINTERCAM — tarjeta de intercambio ATM/PoS
    ("L002R",    "7.1.1"),   # ACL GL Interface S500↔S151 (R2/R3/R4/R5)
    ("P060",     "10.1.1"),  # ECO Transit Server — control de acceso
    ("LINEA",    "8.1.1"),   # WFL LINEA — orquestador batch
]
FILE_CAP = {   # substring en nombre de archivo → ID (fallback final)
    "dasdl":         "9.1.1",   # esquemas DMSII BD10/BD13/BD99/BD02
    "s151registra":  "7.1.1",   # registro de asientos hacia el GL S151
}
def norm_cap(raw, prog, prog2id, canon, base=""):
    """Devuelve el ID canónico BIAN de una regla."""
    if raw and raw != "—":
        m = re.match(r'\s*(?:BIAN\s+)?([0-9T]\.\d(?:\.\d)?)', raw)
        if m and m.group(1) in canon:
            return m.group(1)
        low = raw.lower()
        for pat, tid in CAP_ALIAS:
            if re.search(pat, low): return tid
    # derivar del programa vía bian-mapping
    pk = None
    m = re.search(r'([A-Z]?P\d+|L\d+|S\d+P\d+)', (prog or "").upper())
    if m: pk = m.group(1)
    if pk and pk in prog2id: return prog2id[pk]
    if prog and prog.upper() in prog2id: return prog2id[prog.upper()]
    # override por programa
    pu = (prog or "").upper()
    for sub, tid in PROG_CAP:
        if sub in pu: return tid
    # override por archivo
    for sub, tid in FILE_CAP.items():
        if sub in base.lower(): return tid
    return None

# ── Parseo de reglas ──────────────────────────────────────────────────────────
def parse_rules():
    out = []
    for fp in sorted(glob.glob(os.path.join(RD, "*.md"))):
        base = os.path.basename(fp)
        if "INDEX" in base.upper(): continue
        c = open(fp, encoding="utf-8").read()
        fn_progs = [p.upper() for p in re.findall(r'-([pP]\d+|l\d+)', base)]
        fn_prog = fn_progs[0] if fn_progs else ""
        for part in re.split(r'\n(?=#{2,3} RN-S(?:151|500)-\d+)', c):
            hm = re.match(r'#{2,3} (RN-S(?:151|500)-\d+)', part)
            if not hm: continue
            rid = hm.group(1)
            def meta(field):
                m = re.search(rf'\*\*{re.escape(field)}\*\*\s*\|\s*([^\n|]+)', part)
                return m.group(1).strip() if m else ""
            prog = (meta("Programa ejecutor") or meta("Programa(s) fuente") or meta("Programa(s)") or meta("Programa") or fn_prog)
            prog = re.split(r'[·,]', prog)[0].strip() if prog else fn_prog
            cap = meta("Capacidad bancaria") or meta("bian_ref")
            # vocab terms citados: TODOS los tokens en `backticks` (campos inline, tabla
            # "Vocabulario relacionado", Campos involucrados) + listas inline con ·
            terms = re.findall(r'`([^`\n]+)`', part)
            for ln in re.findall(r"\*\*Vocabulario[^\n]*\*\*\s*([^\n]+)", part):
                terms += re.split(r"[·,;]", ln)
            terms = [re.sub(r'\(.*?\)', '', t).strip(" `.,").upper() for t in terms]
            terms = [t for t in terms if re.fullmatch(r'[A-Z0-9\-/]{2,}', t)]
            out.append({"id": rid, "prog": prog, "cap_raw": cap, "terms": terms,
                        "base": base, "sys": "S500" if "S500" in rid else "S151"})
    return out

# ── Compresión de rangos de IDs ───────────────────────────────────────────────
def compress(ids):
    nums = sorted(int(i.rsplit("-", 1)[1]) for i in ids)
    if not nums: return ""
    pref = ids[0].rsplit("-", 1)[0]
    ranges = []; a = b = nums[0]
    for n in nums[1:]:
        if n == b + 1: b = n
        else: ranges.append((a, b)); a = b = n
    ranges.append((a, b))
    return " · ".join(f"{pref}-{x:03d}" if x == y else f"{pref}-{x:03d}..{y:03d}" for x, y in ranges)

# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    canon, taxpath = load_taxonomy(); prog2id = load_prog2id(); capfiles = load_capfiles()
    rules = parse_rules()
    today = __import__('datetime').date.today().isoformat()

    cap2rules = defaultdict(list); no_cap = []
    term2rules = defaultdict(lambda: defaultdict(list))
    for r in rules:
        cid = norm_cap(r["cap_raw"], r["prog"], prog2id, canon, r.get("base",""))
        r["cap_id"] = cid
        if cid: cap2rules[cid].append(r["id"])
        else:   no_cap.append(r)
        for t in set(r["terms"]):
            term2rules[r["sys"]][t].append(r["id"])

    # 1) actualizar cap-*.md "Reglas vinculadas"
    updated = 0
    for cid, path in capfiles.items():
        rids = cap2rules.get(cid, [])
        if not rids: continue
        s500 = [x for x in rids if "S500" in x]; s151 = [x for x in rids if "S151" in x]
        parts = []
        if s500: parts.append(compress(s500))
        if s151: parts.append(compress(s151))
        line = f"> Reglas vinculadas: {' · '.join(parts)} ({len(rids)} reglas · trazabilidad automática {today})\n"
        txt = open(path, encoding="utf-8").read()
        if re.search(r'^> Reglas vinculadas:.*$', txt, re.M):
            txt = re.sub(r'^> Reglas vinculadas:.*$', line.rstrip("\n"), txt, count=1, flags=re.M)
        else:
            txt = re.sub(r'(^> Cobertura:.*$)', r'\1\n' + line.rstrip("\n"), txt, count=1, flags=re.M)
        # jerarquía de 6 niveles (nivel 1→6) + marca Indexado
        dom, sub, capname = taxpath.get(cid, ("—", "—", cid))
        domn = cid.split(".")[0]
        jer = (f"> Jerarquía: **N1** Dominio {domn} · {dom} → **N2** Subdominio {sub} → "
               f"**N3** Capacidad {cid} {capname} → **N4-5** Procesos/Flujo de tareas (ver Inventario de Tareas) → "
               f"**N6** Reglas (ver Reglas vinculadas)")
        idx = f"> Indexado: ✅ {today} — correlacionado vocab↔reglas↔capacidad (build-traceability.py)"
        txt = re.sub(r'^> Jerarquía:.*$', jer, txt, count=1, flags=re.M) if re.search(r'^> Jerarquía:', txt, re.M) \
              else re.sub(r'(^> Reglas vinculadas:.*$)', r'\1\n' + jer, txt, count=1, flags=re.M)
        txt = re.sub(r'^> Indexado:.*$', idx, txt, count=1, flags=re.M) if re.search(r'^> Indexado:', txt, re.M) \
              else re.sub(r'(^> Jerarquía:.*$)', r'\1\n' + idx, txt, count=1, flags=re.M)
        open(path, "w", encoding="utf-8").write(txt)
        updated += 1

    # 2) traceability-matrix.md
    with open(os.path.join(BASE, "traceability-matrix.md"), "w", encoding="utf-8") as f:
        f.write("# Matriz de Trazabilidad — Gemelo Cognitivo Banamex\n")
        f.write(f"> Reglas (Capa 2) ↔ Capacidades (Capa 3) ↔ Vocabulario (Capa 1)\n")
        f.write(f"> Indexado: ✅ {today} — Matriz derivada Capacidad→Reglas (6 niveles) — build-traceability.py\n")
        f.write(f"> Generado automáticamente por `build-traceability.py` · {len(rules)} reglas\n\n")
        f.write("## Capacidad BIAN → Reglas\n\n")
        f.write("| ID | Capacidad | Reglas | S500 | S151 |\n|---|---|---|---|---|\n")
        for cid in sorted(cap2rules, key=lambda x: (-len(cap2rules[x]), x)):
            rids = cap2rules[cid]
            nm = canon.get(cid, cid)
            f.write(f"| {cid} | {nm[len(cid):].strip()} | {len(rids)} | "
                    f"{sum(1 for x in rids if 'S500' in x)} | {sum(1 for x in rids if 'S151' in x)} |\n")
        f.write(f"\n**Total:** {len(rules)} reglas · {len(cap2rules)} capacidades canónicas · "
                f"{len(no_cap)} reglas sin capacidad resoluble\n\n")
        if no_cap:
            f.write("## Reglas sin capacidad resoluble (programa no está en bian-mapping)\n\n")
            byp = defaultdict(list)
            for r in no_cap: byp[r["prog"] or "?"].append(r["id"])
            for p, ids in sorted(byp.items(), key=lambda x: -len(x[1])):
                f.write(f"- **{p}** ({len(ids)}): {compress(ids) if ids else ''}\n")

    # 3) vocab-rules-xref.md
    with open(os.path.join(BASE, "vocab-rules-xref.md"), "w", encoding="utf-8") as f:
        f.write("# Cross-Reference Vocabulario ↔ Reglas\n")
        f.write("> Término de vocabulario (Capa 1) → reglas (Capa 2) que lo citan en su fórmula/campos.\n")
        f.write(f"> Indexado: ✅ {today} — Cross-ref derivado Vocabulario→Reglas — build-traceability.py\n")
        f.write(f"> Generado por `build-traceability.py`\n\n")
        for sysn in ("S500", "S151"):
            d = term2rules[sysn]
            f.write(f"## {sysn} — {len(d)} términos citados por reglas\n\n")
            f.write("| Término | # Reglas | Reglas |\n|---|---|---|\n")
            for t in sorted(d, key=lambda x: (-len(d[x]), x)):
                rids = sorted(set(d[t]))
                shown = " · ".join(rids[:12]) + (f" … (+{len(rids)-12})" if len(rids) > 12 else "")
                f.write(f"| `{t}` | {len(rids)} | {shown} |\n")
            f.write("\n")

    # reporte
    print(f"Reglas: {len(rules)}")
    print(f"Capacidad resuelta: {len(rules)-len(no_cap)} · sin resolver: {len(no_cap)}")
    print(f"Capacidades canónicas con reglas: {len(cap2rules)}")
    print(f"cap-*.md actualizados (Reglas vinculadas): {updated}")
    print(f"Términos vocab citados por reglas: S500={len(term2rules['S500'])} · S151={len(term2rules['S151'])}")
    print("Artefactos: traceability-matrix.md · vocab-rules-xref.md")

if __name__ == "__main__":
    main()

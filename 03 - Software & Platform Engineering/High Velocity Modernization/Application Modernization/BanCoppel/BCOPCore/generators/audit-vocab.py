#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
audit-vocab.py — Auditoría EXHAUSTIVA del vocabulario: caza falsos positivos de
segmentación (tokens cortos que matchean DENTRO de palabras más largas donde no
corresponden, ej. 'ini' en re-ini-cia, 'nomina' en deno-mina-cion).

Para cada token del vocab mide: apariciones como término propio (segmento entre _)
vs. como substring dentro de tokens más largos, y qué palabras lo "contienen".
También detecta tokens del corpus mal segmentados (átomo corto + fragmento largo).

Genera: vocab-audit-bcop.md · Etapa 3 · Specialist Informix SPL
"""
import json, re, os
from collections import Counter, defaultdict
import sp_vocab

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - Software & Platform Engineering/High Velocity Modernization/"
        "Application Modernization/BanCoppel/BCOPCore/")
SRC = BASE + "source/BCOPCore/informix/"
CG = json.load(open(BASE + "portal/data/callgraph-data.json", encoding="utf-8"))

# corpus de tokens crudos (segmentos entre _) de todos los nombres conectados + params
RE_SIG = re.compile(r"create\s+(?:procedure|function)\s+[^(]*\(([^;]*?)\)\s*returning", re.I | re.S)
RE_CREATE = re.compile(r"create\s+(?:procedure|function)\b", re.I)
def iso(t):
    m = list(RE_CREATE.finditer(t)); return t[m[0].start():m[1].start()] if len(m) >= 2 else t

raw = Counter()          # token crudo -> frecuencia
for n in CG["graph"]["nodes"]:
    for seg in n["label"].split("_"):
        if seg: raw[seg.lower()] += 1
# params (más evidencia de palabras completas)
for n in CG["graph"]["nodes"]:
    db, sp = n["id"].split(":", 1); fp = SRC + f"{db}_{sp}.sql"
    if os.path.exists(fp):
        head = open(fp, encoding="utf-8", errors="replace").read()[:2500]
        mm = RE_SIG.search(head)
        if mm:
            for ch in mm.group(1).split(","):
                pm = re.match(r"\s*[pcvwimdnbf]?([a-zA-Z][a-zA-Z0-9_]{3,})", ch)
                if pm:
                    for part in pm.group(1).lower().split("_"):
                        if part: raw[part] += 1

toks = list(raw.keys())
CAT = sp_vocab.CAT

# ── análisis por token del vocab ──
audit = []
for term, (cat, mean, est) in CAT.items():
    if len(term) < 2 or cat == "PREFIJO":
        continue
    exact = raw.get(term, 0)                         # aparece como token propio
    # substring dentro de tokens MÁS LARGOS
    containers = Counter()
    substr = 0
    for t, c in raw.items():
        if t != term and len(t) > len(term) and term in t:
            substr += c; containers[t] += c
    total = exact + substr
    if total == 0:
        continue
    ratio = substr / total
    audit.append({"term": term, "cat": cat, "est": est, "exact": exact, "substr": substr,
                  "ratio": ratio, "containers": containers.most_common(4)})

# sospechosos: token corto que aparece MÁS como fragmento que como término propio
susp = [a for a in audit if len(a["term"]) <= 6 and a["ratio"] >= 0.6 and a["substr"] >= 4]
susp.sort(key=lambda a: -a["substr"])

# ── mal-segmentación: token crudo donde un átomo corto deja un fragmento largo ──
def segment(tok):
    out, i, t = [], 0, tok.lower()
    KEYS = sp_vocab.KEYS
    while i < len(t):
        m = next((k for k in KEYS if t.startswith(k, i)), None)
        if m: out.append(m); i += len(m)
        else:
            j = i + 1
            while j < len(t) and not any(t.startswith(k, j) for k in KEYS): j += 1
            out.append("?" + t[i:j]); i = j
    return out

badseg = []
seen = set()
for tok, c in raw.most_common():
    if len(tok) < 6 or tok in seen: continue
    seg = segment(tok)
    # patrón: átomo corto (≤4) seguido/precedido de fragmento desconocido largo (≥4)
    frag_largo = [s[1:] for s in seg if s.startswith("?") and len(s) > 4]
    atomos = [s for s in seg if not s.startswith("?")]
    if frag_largo and atomos and any(len(a) <= 4 for a in atomos):
        seen.add(tok)
        badseg.append((tok, c, seg))
badseg.sort(key=lambda x: -x[1])

# ── reporte ──
L = ["# BCOPCore · Auditoría Exhaustiva del Vocabulario — Falsos Positivos",
 "",
 "> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 · **Generado:** 2026-07-06 por `audit-vocab.py`  ",
 f"> Analizados {len(toks):,} tokens crudos únicos del corpus (nombres + parámetros).",
 "",
 "Caza tokens del vocabulario que se interpretan mal por la **segmentación greedy** — igual que "
 "`ini`→re**ini**cia, `nomina`→deno**mina**ción, `pase` mal definido. Dos análisis:",
 "",
 "---",
 "",
 "## A · Tokens que aparecen MÁS como fragmento que como término propio",
 "",
 "Estos tokens del vocab matchean dentro de palabras más largas la mayoría de las veces → "
 "probable falso positivo. `exact` = veces como token propio · `substr` = veces como fragmento interno.",
 "",
 "| Token | Sig. actual | exact | substr | % frag | Aparece dentro de (ejemplos) | Acción sugerida |",
 "|-------|-------------|------:|-------:|-------:|------------------------------|-----------------|"]
for a in susp[:40]:
    conts = ", ".join(f"{t}×{c}" for t, c in a["containers"])
    accion = "⚠ quitar o acortar alcance" if a["exact"] == 0 else "revisar / agregar palabras contenedoras"
    L.append(f"| `{a['term']}` | {a['mean'] if False else CAT[a['term']][1][:28]} | {a['exact']} | {a['substr']} | {a['ratio']*100:.0f}% | {conts[:60]} | {accion} |")

L += ["", "---", "",
 "## B · Tokens del corpus con segmentación sospechosa",
 "",
 "Tokens crudos donde un átomo corto deja un fragmento largo sin reconocer → probable **palabra real "
 "partida mal** (candidata a agregar completa al vocabulario).",
 "",
 "| Token crudo | Frec | Segmentación actual | Palabra(s) real(es) probable(s) |",
 "|-------------|-----:|---------------------|--------------------------------|"]
for tok, c, seg in badseg[:45]:
    segstr = " · ".join(s.replace("?", "¿")+"?" if s.startswith("?") else s for s in seg)
    frags = [s[1:] for s in seg if s.startswith("?") and len(s) > 3]
    L.append(f"| `{tok}` | {c} | {segstr[:55]} | {', '.join(frags)[:40]} |")

L += ["", "---", "",
 "## Cómo se corrige cada caso", "",
 "- **Sección A (token = fragmento):** si `exact`=0, el token nunca es término propio → quitarlo del vocab "
 "(como hicimos con `ini`). Si aparece a veces solo, agregar las palabras contenedoras completas para que "
 "el greedy las prefiera (longest-match).",
 "- **Sección B (palabra partida):** agregar la palabra real completa al vocab con su significado — el "
 "greedy la tomará entera y el fragmento desaparece (como `denominacion`, `reinicia`).",
 "",
 "*Generado por audit-vocab.py · revisar y aplicar correcciones a sp_vocab.py, luego regenerar el pipeline.*"]

open(BASE + "knowledge-base/vocab-audit-bcop.md", "w", encoding="utf-8").write("\n".join(L))
print(f"knowledge-base/vocab-audit-bcop.md escrito · {len(susp)} tokens sospechosos (A) · {len(badseg)} mal-segmentados (B)")
print("\n=== TOP 15 sospechosos (aparecen más como fragmento) ===")
for a in susp[:15]:
    conts = ", ".join(f"{t}" for t, c in a["containers"][:3])
    print(f"  {a['term']:12} exact={a['exact']:4} substr={a['substr']:4} ({a['ratio']*100:.0f}% frag) ⊂ {conts}")
print("\n=== TOP 15 palabras partidas mal ===")
for tok, c, seg in badseg[:15]:
    print(f"  {tok:26} ({c:3}) -> {' '.join(seg)}")
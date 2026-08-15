#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
vocab_dedup.py — FUENTE ÚNICA de los conteos de vocabulario del Gemelo Cognitivo.

Todos los HTML (vocab-report, landing, generations, lexical…) deben leer los
números de vocabulario de aquí para que sean idénticos entre vistas. Replica
exactamente la lógica de build-vocab-report.py (misma fuente vocabulary-inventory.json,
mismo union-find por significado + plurales) → cero drift entre HTMLs.

Uso:  from vocab_dedup import counts;  C = counts()
      C["total"] 590 · C["unicos"] 480 · C["conceptos"] 86 · C["alias"] 196
"""
import json
import re as _re
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")


def _rows(inv):
    rows = []
    for r in inv["atomos"]:
        rows.append({**r, "tipo": "atómico"})
    for r in inv["compuestos"]:
        rows.append({**r, "tipo": "compuesto"})
    for c in inv["candidatos"]:
        rows.append({"term": c["frag"], "cat": "?", "mean": "(sin clasificar)", "est": "-",
                     "nivel": "CANDIDATO", "fn": c["frec"], "fp": 0, "tipo": "candidato"})
    return rows


def _clusters(rows):
    elig = [r for r in rows if r["cat"] not in ("AMBIGUO", "?") and r.get("est") not in ("gap", "-")]
    by_term = {r["term"]: r for r in elig}
    parent = {t: t for t in by_term}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]; x = parent[x]
        return x

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    mg = {}
    for r in elig:
        key = _re.sub(r"[^a-z0-9 ]", "", (r.get("mean") or "").lower().split("(")[0].split(" / ")[0]).strip()
        if key and key != "sin clasificar":
            mg.setdefault(key, []).append(r["term"])
    for ts in mg.values():
        for t in ts[1:]:
            union(ts[0], t)
    for t, r in by_term.items():
        for pl in (t + "s", t + "es"):
            if pl in by_term and by_term[pl]["cat"] == r["cat"]:
                union(t, pl)
    comp = {}
    for t in parent:
        comp.setdefault(find(t), []).append(t)
    return {root: ts for root, ts in comp.items() if len(ts) > 1}


def counts(inv=None):
    """Devuelve los conteos canónicos de vocabulario (idénticos en todas las vistas)."""
    if inv is None:
        inv = json.load(open(BASE + "knowledge-base/vocabulary-inventory.json", encoding="utf-8"))
    rows = _rows(inv)
    cl = _clusters(rows)
    bytipo = Counter(r["tipo"] for r in rows)
    n_concepts = len(cl)
    n_alias = sum(len(v) for v in cl.values())
    n_collapsed = sum(len(v) - 1 for v in cl.values())
    return {
        "total": len(rows),                 # 590 — términos destilados (todos)
        "atomicos": bytipo["atómico"],      # 484
        "compuestos": bytipo["compuesto"],  # 46
        "candidatos": bytipo["candidato"],  # 60
        "conceptos": n_concepts,            # 86 — conceptos con alias
        "alias": n_alias,                   # 196 — términos que son alias de esos conceptos
        "unicos": len(rows) - n_collapsed,  # 480 — conceptos únicos tras deduplicar
    }


if __name__ == "__main__":
    import sys
    sys.stdout.reconfigure(encoding="utf-8")
    C = counts()
    for k, v in C.items():
        print(f"  {k:12} {v}")
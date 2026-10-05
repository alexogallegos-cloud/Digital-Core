#!/usr/bin/env python3
"""
Liverpool — Consolida el swarm de SUDs en un catálogo durable.
Gather del scatter-gather: lee los batch_*.json del swarm (scratch), dedup por
slug, y escribe portal/data/sud-catalog-liv.json (fuente de verdad del landscape
aplicativo derivado de los Solution Understanding Documents).

Uso:
  python generators/build-sud-catalog.py <dir_con_batches>
Si no se pasa dir, usa el scratch por defecto o portal/data/sud-batches/.
"""
import json, glob, os, sys, re
from pathlib import Path
from datetime import date

HERE  = Path(__file__).parent
BRAIN = HERE.parent
OUT   = BRAIN / "portal" / "data" / "sud-catalog-liv.json"

# dir de batches: arg, o scratch conocido, o portal/data/sud-batches
cands = []
if len(sys.argv) > 1:
    cands.append(sys.argv[1])
cands += [
    os.environ.get("SUD_BATCH_DIR", ""),
    str(BRAIN / "portal" / "data" / "sud-batches"),
]
batch_dir = next((c for c in cands if c and glob.glob(os.path.join(c, "batch_*.json"))), None)
if not batch_dir:
    print("ERROR: no encuentro batch_*.json. Pasa el directorio como argumento.")
    sys.exit(1)

def norm_slug(s):
    s = (s or "").strip().lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s or "sin-slug"

def dedup_list(items, keyfn):
    seen, out = set(), []
    for it in items:
        k = keyfn(it)
        if k and k not in seen:
            seen.add(k); out.append(it)
    return out

# ── Gather + dedup por slug ────────────────────────────────────────────────────
merged = {}
raw_count = 0
for f in sorted(glob.glob(os.path.join(batch_dir, "batch_*.json"))):
    for s in json.loads(Path(f).read_text(encoding="utf-8")):
        raw_count += 1
        slug = norm_slug(s.get("slug") or s.get("system"))
        s["slug"] = slug
        if slug not in merged:
            merged[slug] = s
            continue
        # merge duplicado: combina listas, prefiere el de mayor calidad para escalares
        m = merged[slug]
        qorder = {"rich": 2, "partial": 1, "template": 0}
        if qorder.get(s.get("fill_quality"), 0) > qorder.get(m.get("fill_quality"), 0):
            for k in ("purpose", "vendor", "domain", "togaf_type", "fill_quality", "volumetria", "batch"):
                if s.get(k): m[k] = s[k]
        for k in ("technologies",):
            m[k] = dedup_list((m.get(k) or []) + (s.get(k) or []), lambda x: str(x).lower())
        m["servers"]      = dedup_list((m.get("servers") or []) + (s.get("servers") or []),      lambda x: (x.get("hostname","")+x.get("ip","")).lower())
        m["databases"]    = dedup_list((m.get("databases") or []) + (s.get("databases") or []),   lambda x: (x.get("name","")+x.get("ip","")).lower())
        m["interfaces"]   = dedup_list((m.get("interfaces") or []) + (s.get("interfaces") or []), lambda x: (x.get("name","")+x.get("counterpart","")).lower())
        m["cross_dependencies"] = dedup_list((m.get("cross_dependencies") or []) + (s.get("cross_dependencies") or []), lambda x: (x.get("other_system","")+x.get("relationship","")).lower())
        m["risks"]        = dedup_list((m.get("risks") or []) + (s.get("risks") or []),           lambda x: (x.get("desc","") or "")[:60].lower())
        m["glossary"]     = dedup_list((m.get("glossary") or []) + (s.get("glossary") or []),     lambda x: (x.get("term","") or "").lower())
        m.setdefault("_merged_from", []).append(s.get("sud_file"))

systems = sorted(merged.values(), key=lambda x: (x.get("domain") or "R99", x.get("system") or ""))

# normaliza domain a Rxx (primeros 3 chars)
for s in systems:
    d = (s.get("domain") or "").strip()
    m = re.match(r"(R\d{2})", d)
    s["domain"] = m.group(1) if m else (d[:3] if d else "R10")

# ── Stats ─────────────────────────────────────────────────────────────────────
def total(k, sub=None):
    return sum(len(s.get(k, []) or []) for s in systems)

by_dom, by_q = {}, {}
for s in systems:
    by_dom[s["domain"]] = by_dom.get(s["domain"], 0) + 1
    by_q[s.get("fill_quality", "?")] = by_q.get(s.get("fill_quality", "?"), 0) + 1

meta = {
    "generated": str(date.today()),
    "source": "Solution Understanding Documents (CXEC 2.0) — swarm scatter-gather",
    "raw_records": raw_count,
    "systems": len(systems),
    "by_quality": by_q,
    "by_domain": by_dom,
    "servers": total("servers"),
    "databases": total("databases"),
    "interfaces": total("interfaces"),
    "cross_dependencies": total("cross_dependencies"),
    "risks": total("risks"),
    "glossary_terms": total("glossary"),
}

OUT.write_text(json.dumps({"meta": meta, "systems": systems}, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"sud-catalog -> {OUT.name}")
print(f"  {raw_count} raw -> {len(systems)} sistemas únicos (dedup)")
print(f"  quality {by_q}")
print(f"  servers {meta['servers']} · dbs {meta['databases']} · interfaces {meta['interfaces']} · xdeps {meta['cross_dependencies']} · risks {meta['risks']} · glossary {meta['glossary_terms']}")
print(f"  by domain {dict(sorted(by_dom.items()))}")

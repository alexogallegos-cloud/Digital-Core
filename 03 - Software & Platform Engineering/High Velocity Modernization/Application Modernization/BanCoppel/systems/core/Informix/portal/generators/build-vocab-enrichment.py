#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-enrichment.py — Genera/actualiza vocabulary-enrichment.json
Capa semántica del vocabulario BCOPCore: enriquece con BC, dominio AS-IS,
relaciones ontológicas y stubs para anotación SME.

Consume: vocabulary-inventory.json  ·  digital-brain/brain.db
Genera:  knowledge-base/vocabulary/vocabulary-enrichment.json
Preserva anotaciones SME existentes (target_term, regulatorio, nodo_taxonomia,
         validado_por, notas_sme) — nunca las sobreescribe.

Campos auto-computados (se recalculan en cada run):
  bc              Bounded Context del término (desde BIAN)
  bc_name         Nombre legible del BC
  dominio_as_is   Dominio Informix (D01-D16) donde aparece más en SPs
  es_variante_de  Término canónico del cluster de sinónimos (si aplica)
  tipo_relacion   ABBREV-OF | PLURAL-OF | SYNONYM-OF
  regulatorio_auto Ley/norma detectada por heurística (sin SME)
  capa_gemelo     Capa(s) del Gemelo Cognitivo donde vive el término
  estado          ACTIVO | CANDIDATO | PENDIENTE-SME (desde nivel/est)

Campos SME (se preservan si ya tienen valor):
  target_term     Identificador canónico en el target (e.g. customerId)
  regulatorio     Norma validada por SME (CNBV · Banxico · UIF · SAT · …)
  nodo_taxonomia  Nodo en taxonomia-negocio-bancoppel.md (e.g. 1.1.3)
  validado_por    SME que validó la entrada
  notas_sme       Notas libres del SME

Flujo completo:
  1. python build-vocab-enrichment.py       ← este script
  2. python build-vocab-inventory.py        ← merge + rebuild JSON
  3. python build-vocab-report-v2.py        ← HTML con columnas nuevas
"""
import json
import sqlite3
import re as _re
from collections import Counter
from pathlib import Path

BASE = Path("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
            "03 - Software & Platform Engineering/High Velocity Modernization/"
            "Application Modernization/BanCoppel/BCOPCore/")

INV_FILE    = BASE / "knowledge-base" / "vocabulary-inventory.json"
BRAIN_DB    = BASE / "digital-brain/brain.db"
ENRICH_FILE = BASE / "knowledge-base/vocabulary/vocabulary-enrichment.json"

# ── cargar inventario ──
INV = json.loads(INV_FILE.read_text(encoding="utf-8"))
rows = []
for r in INV.get("atomos", []):     rows.append({**r, "_tipo": "atómico"})
for r in INV.get("compuestos", []): rows.append({**r, "_tipo": "compuesto"})
for c in INV.get("candidatos", []):
    rows.append({"term": c["frag"], "cat": "?", "mean": "", "est": "-",
                 "nivel": "CANDIDATO", "fn": c["frec"], "fp": 0, "_tipo": "candidato"})

terms = [r["term"] for r in rows]
by_term_map = {r["term"]: r for r in rows}
print(f"Términos a enriquecer: {len(terms)}")

# ── BIAN → BC ──
BIAN = [
    ("Cliente / Party",
     r"cliente|\bcte\b|apoderad|beneficiari|persona|contacto|domicili|tel[eé]fon|celular|correo|\bfirma"),
    ("Cuentas y Depósitos",
     r"cuenta|saldo|dep[oó]sito|captaci|chequera|cheque|disponible|cuentahab|apertura|\bbym\b|piezas"),
    ("Cobranza y Recuperación",
     r"cobranz|recuperaci|reestructur|refinanci|moratori|quebranto|\bmora\b|castigo|\bciloc|frecpago|adeud|promesa"),
    ("Pagos y Transferencias",
     r"spei|\bpago|transferen|\borden\b|abono|cargo|clabe|rastreo|codi|dispersi|remesa|domiciliaci|traspaso"),
    ("Tarjetas",
     r"tarjeta|\btdc\b|pl[aá]stico|\bcvv\b|intercard|\bn[ií]p\b|token"),
    ("Crédito y Préstamos",
     r"cr[eé]dito|\bcred\b|pr[eé]stamo|pagar[eé]|amortiza|\bcuota|\bl[ií]nea|scoring|califica|bur[oó]|\bmsi\b|plazo|inter[eé]s|\bgat\b|\bcat\b|rendim"),
    ("Canales y Digital",
     r"canal|\bweb\b|m[oó]vil|\bbpi\b|cajero|\batm\b|sucursal|\bapp\b|clic|banca por internet|kiosko"),
    ("Contabilidad y Finanzas",
     r"contab|p[oó]liza|\bmayor\b|asiento|\bpase\b|c[eé]dula|balance|cnsif|conciliaci|devengo"),
    ("Riesgo y Cumplimiento",
     r"regulat|\bpld\b|lavado|\bisr\b|\biva\b|cnbv|art\.?\s*61|fiscal|ipab|tesofe|condusef|banxico|beneficencia|inactiv"),
    ("Servicing y Operaciones",
     r"aclaraci|solicitud|mensaj|notificaci|alerta|\bfolio\b|tr[aá]mite|reverso|cancelaci"),
    ("Datos de Referencia",
     r"cat[aá]logo|\btabla|c[oó]digo|codificaci|\btipo\b|denominaci|\bclave\b|par[aá]metro|producto"),
]
BIAN_TO_BC = {
    "Cliente / Party":         ("BC-7.1",  "Customer"),
    "Cuentas y Depósitos":     ("BC-3.2",  "Accounts"),
    "Cobranza y Recuperación": ("BC-3.3",  "Lending"),
    "Pagos y Transferencias":  ("BC-3.4",  "Payments"),
    "Tarjetas":                ("BC-3.5",  "Cards"),
    "Crédito y Préstamos":     ("BC-3.3",  "Lending"),
    "Canales y Digital":       ("BC-1.x",  "Channels"),
    "Contabilidad y Finanzas": ("BC-5.4",  "Finance"),
    "Riesgo y Cumplimiento":   ("BC-5.8",  "AML/Risk"),
    "Servicing y Operaciones": ("BC-3.18", "Disputes"),
    "Datos de Referencia":     ("BC-4.x",  "Ref.Data"),
    "Transversal / Técnico":   ("—",       "Transversal"),
}
def bian_of(r):
    s = (r["term"] + " " + (r.get("mean") or "")).lower()
    for name, pat in BIAN:
        if _re.search(pat, s): return name
    return "Transversal / Técnico"

# ── dominio_as_is: escanear brain.db ──
DB_TO_DOMAIN = {
    "bdicnweb": "D01", "bdinteg": "D02", "bdicred": "D03",
    "bdicheq": "D04", "bdisac": "D05", "bdisolic": "D06",
    "bdiaclaracion": "D07", "bdispei": "D08", "bdimnsj": "D09",
    "bdisuc": "D10", "bdicobranza": "D11", "bdicont": "D12",
    "bditef": "D13", "bdibei": "D14", "bdilide": "D15",
    "intercard": "D16",
}
term_dom: dict[str, Counter] = {t: Counter() for t in terms}

print(f"Escaneando brain.db para dominio_as_is…")
try:
    conn = sqlite3.connect(str(BRAIN_DB))
    all_sps = conn.execute("SELECT name, db FROM sps WHERE name IS NOT NULL").fetchall()
    conn.close()
    # pre-procesar: (dom, set_de_tokens, nombre_completo)
    sp_records = []
    for sp_name, db in all_sps:
        dom = DB_TO_DOMAIN.get(db)
        if dom:
            low = sp_name.lower()
            sp_records.append((dom, set(low.split("_")), low))
    print(f"  {len(sp_records):,} SPs en 16 dominios procesados")
    for t in terms:
        for dom, tokens, full_name in sp_records:
            if t in tokens:
                term_dom[t][dom] += 1
            elif len(t) >= 5 and t in full_name:
                term_dom[t][dom] += 1
except Exception as e:
    print(f"  ADVERTENCIA: no se pudo leer brain.db: {e}")

n_with_dom = sum(1 for c in term_dom.values() if c)
print(f"  {n_with_dom} términos con dominio_as_is identificado")

# ── alias clusters — mismo algoritmo que los scripts de reporte ──
elig = [r for r in rows if r["cat"] not in ("AMBIGUO", "?") and r.get("est") not in ("gap", "-")]
elig_map = {r["term"]: r for r in elig}
parent = {t: t for t in elig_map}
def _find(x):
    while parent[x] != x: parent[x] = parent[parent[x]]; x = parent[x]
    return x
def _union(a, b):
    ra, rb = _find(a), _find(b)
    if ra != rb: parent[ra] = rb
_mg: dict = {}
for r in elig:
    key = _re.sub(r"[^a-z0-9 ]", "",
                  (r.get("mean") or "").lower().split("(")[0].split(" / ")[0]).strip()
    if key and key != "sin clasificar": _mg.setdefault(key, []).append(r["term"])
for ts in _mg.values():
    for t in ts[1:]: _union(ts[0], t)
for t, r in elig_map.items():
    for pl in (t + "s", t + "es"):
        if pl in elig_map and elig_map[pl]["cat"] == r["cat"]: _union(t, pl)
_comp: dict = {}
for t in parent: _comp.setdefault(_find(t), []).append(t)
ANGLICISMOS = {"status", "mail", "email", "update", "insert", "delete", "select",
               "flag", "check", "log", "user", "account", "client", "payment",
               "transfer", "balance", "amount", "name", "date", "report"}
def _isplural(t, gs): return (t.endswith("s") and t[:-1] in gs) or (t.endswith("es") and t[:-2] in gs)
def _cscore(x, gs):
    t = x["term"]
    return (0 if (t[-1:].isdigit() or _isplural(t, gs)) else 1,
            0 if t in ANGLICISMOS else 1,
            len(t),
            (x.get("fp") or 0) + (x.get("fn") or 0))
canon_map: dict[str, str] = {}  # term → canonical
for root, ts in _comp.items():
    if len(ts) <= 1: continue
    items = [elig_map[t] for t in ts]
    gs    = {x["term"] for x in items}
    c     = max(items, key=lambda x: _cscore(x, gs))["term"]
    for t in ts:
        if t != c: canon_map[t] = c

def tipo_relacion(t: str, canonical: str | None) -> str | None:
    if not canonical: return None
    if _isplural(t, {canonical}): return "PLURAL-OF"
    if len(canonical) > 0 and len(t) / len(canonical) < 0.75: return "ABBREV-OF"
    return "SYNONYM-OF"

# ── regulatorio automático ──
REG_PATTERNS = {
    "CNBV":     _re.compile(r"cnbv|art\.?\s*61|reserva|cartera|circular|provisi", _re.I),
    "Banxico":  _re.compile(r"banxico|spei|codi|clabe|rastreo|cep|cecoban", _re.I),
    "UIF":      _re.compile(r"\bpld\b|uif|lide|lavado|inhabilitad|fatca|ftc|reporte.*operacion", _re.I),
    "SAT":      _re.compile(r"\bsat\b|\biva\b|\bisr\b|cfdi|comprobante fiscal|fatca", _re.I),
    "CONDUSEF": _re.compile(r"condusef|reco|cat |costo anual|comisi[oó]n|art\.?\s*4", _re.I),
    "IPAB":     _re.compile(r"\bipab\b|udi|beneficencia|inactiv", _re.I),
}
def regulatorio_auto(r) -> str | None:
    s = (r["term"] + " " + (r.get("mean") or "")).lower()
    found = [name for name, pat in REG_PATTERNS.items() if pat.search(s)]
    if not found: return None
    return ", ".join(found)

# ── capa_gemelo desde categoría ──
def capa_gemelo(r) -> str:
    cat = r.get("cat", "?")
    nivel = r.get("nivel", "")
    if nivel == "CANDIDATO": return "Capa 1 (pendiente)"
    if cat == "REG": return "Capa 1 · Capa 4"
    if cat == "ACCION": return "Capa 1 · Capa 3"  # verbos = journeys
    return "Capa 1"

# ── estado desde confiabilidad ──
def estado_default(r) -> str:
    if r.get("nivel") == "CANDIDATO": return "CANDIDATO"
    if r.get("est") == "gap": return "PENDIENTE-SME"
    return "ACTIVO"

# ── cargar enrichment existente (preservar anotaciones SME) ──
try:
    existing: dict = json.loads(ENRICH_FILE.read_text(encoding="utf-8"))
    print(f"Enrichment existente cargado: {len(existing)} registros")
except FileNotFoundError:
    existing = {}
    print("Creando vocabulary-enrichment.json por primera vez")

# ── construir registro de enriquecimiento ──
result: dict = {}
for r in rows:
    t   = r["term"]
    ex  = existing.get(t, {})
    bname   = bian_of(r)
    bc_pair = BIAN_TO_BC.get(bname, ("—", "Transversal"))

    dom_counts = term_dom.get(t, Counter())
    dom_as_is  = dom_counts.most_common(1)[0][0] if dom_counts else None

    canonical = canon_map.get(t)
    reg_auto  = regulatorio_auto(r)

    result[t] = {
        # — Auto-computado (se recalcula en cada run) —
        "bc":              bc_pair[0],
        "bc_name":         bc_pair[1],
        "dominio_as_is":   dom_as_is,
        "es_variante_de":  canonical,
        "tipo_relacion":   tipo_relacion(t, canonical),
        "capa_gemelo":     capa_gemelo(r),
        "regulatorio_auto": reg_auto,
        # — Estado: respeta edición SME si ya la hizo —
        "estado": ex.get("estado") or estado_default(r),
        # — SME annotation: NUNCA sobreescribir si ya tiene valor —
        "target_term":    ex.get("target_term"),
        "regulatorio":    ex.get("regulatorio") or reg_auto,
        "nodo_taxonomia": ex.get("nodo_taxonomia"),
        "validado_por":   ex.get("validado_por"),
        "notas_sme":      ex.get("notas_sme"),
    }

ENRICH_FILE.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")

# ── stats de salida ──
n_bc       = sum(1 for v in result.values() if v["bc"] != "—")
n_dom      = sum(1 for v in result.values() if v["dominio_as_is"])
n_variante = sum(1 for v in result.values() if v["es_variante_de"])
n_reg_auto = sum(1 for v in result.values() if v["regulatorio_auto"])
n_target   = sum(1 for v in result.values() if v["target_term"])
n_sme      = sum(1 for v in result.values() if v["validado_por"])

print(f"\nvocabulary-enrichment.json -> knowledge-base/vocabulary/")
print(f"  {len(result):>6} términos totales")
print(f"  {n_bc:>6} con bc (distinto de transversal)")
print(f"  {n_dom:>6} con dominio_as_is")
print(f"  {n_variante:>6} con es_variante_de (alias detectados)")
print(f"  {n_reg_auto:>6} con regulatorio_auto (heuristica)")
print(f"  {n_target:>6} con target_term (SME - pendientes)")
print(f"  {n_sme:>6} validados por SME")
print(f"\nProximo paso: python build-vocab-inventory.py")
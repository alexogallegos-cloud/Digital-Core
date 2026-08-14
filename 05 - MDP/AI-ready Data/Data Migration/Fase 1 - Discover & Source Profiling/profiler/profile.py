#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
profile.py - Fase 1 Discover & Source Profiling (Data Migration / AI-ready Data)

Dual de datos del Specialist - Reverse Engineering de Mainframe: en vez de leer
codigo legacy y reconstruir el call graph, lee un data estate y reconstruye su
PERFIL: inventario, profiling por tabla, dependency graph (FK + acoplamiento de
entidad cross-system oculto), DQ baseline DESCUBIERTO (sin answer key), disposicion
de migracion por tabla (el "7R" de datos) y wave plan. Emite artefactos + el grafo
renderizable + el deliverable discovery-assessment.html.

Determinista. Solo stdlib. Lee el seed del Reference Data Lab.
Ejecutar:  python profile.py
"""

import csv
import json
import os
import unicodedata
from collections import defaultdict
from datetime import datetime
from string import Template

HERE = os.path.dirname(os.path.abspath(__file__))
FASE_DIR = os.path.dirname(HERE)
ART = os.path.join(FASE_DIR, "artifacts")
# seed del Reference Data Lab (Enablement, sibling de las Fases)
SEED = os.path.normpath(os.path.join(
    FASE_DIR, "..", "Enablement", "Training - Reference Data Lab",
    "seed-sap-banking-crm-to-bigquery-medallion", "source"))


def load(path):
    with open(path, "r", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def strip_accents(s):
    return "".join(c for c in unicodedata.normalize("NFKD", s) if not unicodedata.combining(c))


SUFFIXES = {"SADECV", "SAPI", "SAB", "SA", "SC", "RL", "CV", "DE", "S", "A", "C", "V"}


def norm_name(s):
    s = strip_accents(s or "").upper()
    s = "".join(ch if (ch.isalnum() or ch == " ") else " " for ch in s)
    toks = [t for t in s.split() if t not in SUFFIXES]
    return " ".join(toks)


def alpha(s):
    return (s or "").lstrip("0")


# ---- cargar fuentes ----
sap = SEED + os.sep + "sap" + os.sep
crm = SEED + os.sep + "crm" + os.sep
T = {
    "but000": load(sap + "but000.csv"),
    "but0bk": load(sap + "but0bk.csv"),
    "bkk_acct": load(sap + "bkk_acct.csv"),
    "bkkit": load(sap + "bkkit.csv"),
    "vdarl": load(sap + "vdarl.csv"),
    "tcurx": load(sap + "tcurx.csv"),
    "crm_account": load(crm + "crm_account.csv"),
    "crm_contact": load(crm + "crm_contact.csv"),
    "crm_opportunity": load(crm + "crm_opportunity.csv"),
}

# metadata de tabla: (system, layer, domain, pk, descripcion)
META = {
    "but000": ("SAP", "SAP-MASTER", "customer", "MANDT+PARTNER", "Business Partner (cliente bancario)"),
    "but0bk": ("SAP", "SAP-MASTER", "customer", "MANDT+PARTNER+BKVID", "BP bank details"),
    "bkk_acct": ("SAP", "SAP-TXN", "account", "MANDT+ACCT", "Cuenta deposito — account master simplificado (SAP real reparte la cuenta en BKK40/BKKIT/...)"),
    "bkkit": ("SAP", "SAP-TXN", "transaction", "MANDT+ACCT+ITEM_NO", "Movimientos de cuenta"),
    "vdarl": ("SAP", "SAP-TXN", "product", "MANDT+DARLEHEN", "Contrato de credito (FS-CML)"),
    "tcurx": ("SAP", "SAP-CHECK", "reference", "CURRKEY", "Decimales por moneda"),
    "crm_account": ("CRM", "CRM", "commercial", "id", "Cuenta CRM (comercial)"),
    "crm_contact": ("CRM", "CRM", "commercial", "id", "Contacto CRM"),
    "crm_opportunity": ("CRM", "CRM", "commercial", "id", "Oportunidad CRM"),
}


# ---- profiling por columna ----
def col_profile(rows):
    if not rows:
        return {}
    cols = list(rows[0].keys())
    out = {}
    n = len(rows)
    for c in cols:
        vals = [r.get(c, "") for r in rows]
        nulls = sum(1 for v in vals if v is None or v == "")
        distinct = len(set(vals))
        out[c] = {"nulls": nulls, "null_rate": round(nulls / n, 4), "distinct": distinct}
    return out


PROFILE = {t: col_profile(rows) for t, rows in T.items()}

# ---- DQ baseline DESCUBIERTO (sin answer key) ----
but000_partners = set(r["PARTNER"] for r in T["but000"])
acct_norm = set(alpha(r["ACCT"]) for r in T["bkk_acct"])

dq = {}
# orphans
dq["bkkit_orphan_acct"] = sum(1 for r in T["bkkit"] if alpha(r["ACCT"]) not in acct_norm)
dq["vdarl_orphan_partner"] = sum(1 for r in T["vdarl"] if r["PARTNER"] not in but000_partners)
# dup keys bkkit
seen = set()
dups = 0
for r in T["bkkit"]:
    k = (r["ACCT"], r["ITEM_NO"])
    if k in seen:
        dups += 1
    seen.add(k)
dq["bkkit_dup_keys"] = dups
# invalid dates
dq["invalid_dates"] = (sum(1 for r in T["but000"] if r["CRDAT"] == "00000000")
                       + sum(1 for r in T["bkk_acct"] if r["OPEN_DATE"] == "00000000")
                       + sum(1 for r in T["bkkit"] if r["POST_DATE"] == "00000000"))
# deletion flags
dq["deletion_flags"] = (sum(1 for r in T["but000"] if r.get("XDELE") == "X")
                        + sum(1 for r in T["bkk_acct"] if r.get("LOEVM") == "X"))
# null mandatory
dq["bkk_acct_null_partner"] = sum(1 for r in T["bkk_acct"] if not r.get("PARTNER"))
dq["bkkit_null_amount"] = sum(1 for r in T["bkkit"] if not r.get("AMOUNT"))
# currency trap (0-decimales)
tcurx_dec = {r["CURRKEY"]: int(r["CURRDEC"]) for r in T["tcurx"]}
zero_dec = {c for c, d in tcurx_dec.items() if d == 0}
dq["currency_trap_rows"] = sum(1 for r in T["bkkit"] if r["WAERS"] in zero_dec)
dq["currency_trap_currencies"] = sorted(zero_dec)
# country inconsistente (no ISO-2)
iso = {"MX", "US", "CL"}
bad_country = defaultdict(int)
for r in T["crm_account"]:
    cv = strip_accents(r["country"]).strip().upper()
    if cv not in iso:
        bad_country[r["country"].strip()] += 1
dq["crm_country_nonstd_values"] = dict(bad_country)
dq["crm_country_nonstd_rows"] = sum(bad_country.values())
# email malformado
dq["crm_malformed_email_proxy"] = "n/a (email en crm_contact)"

# ---- entity coupling cross-system (el acoplamiento oculto) ----
crm_with_ref = sum(1 for r in T["crm_account"] if r.get("sap_partner_ref"))
crm_without_ref = len(T["crm_account"]) - crm_with_ref
# overlap por nombre normalizado (lo que un profiling DESCUBRE sin el crosswalk)
party_names = defaultdict(set)
for r in T["but000"]:
    nm = norm_name(r["NAME_ORG1"] or (r["NAME_FIRST"] + " " + r["NAME_LAST"]))
    party_names[(nm, r["LAND1"])].add(r["PARTNER"])
name_hits = 0
for r in T["crm_account"]:
    if r.get("sap_partner_ref"):
        continue
    cv = strip_accents(r["country"]).strip().upper()
    cv = {"MEXICO": "MX", "MEX": "MX", "USA": "US", "ESTADOS UNIDOS": "US", "CHILE": "CL", "CHL": "CL"}.get(cv, cv)
    if (norm_name(r["account_name"]), cv) in party_names:
        name_hits += 1
# duplicados CRM (mismo nombre normalizado repetido en CRM)
crm_name_counts = defaultdict(int)
for r in T["crm_account"]:
    crm_name_counts[norm_name(r["account_name"])] += 1
crm_dup_names = sum(c - 1 for c in crm_name_counts.values() if c > 1)

entity = {
    "crm_total": len(T["crm_account"]),
    "crm_with_ref": crm_with_ref,
    "crm_without_ref": crm_without_ref,
    "fuzzy_name_hits": name_hits,
    "crm_duplicate_names": crm_dup_names,
    "sap_customers": len(T["but000"]),
}

# ---- dependency graph (FK + entity link) ----
edges = [
    ("but0bk", "but000", "fk"),
    ("bkk_acct", "but000", "fk"),
    ("bkkit", "bkk_acct", "fk"),
    ("vdarl", "but000", "fk"),
    ("crm_contact", "crm_account", "fk"),
    ("crm_opportunity", "crm_account", "fk"),
    ("crm_account", "but000", "entity-link"),  # acoplamiento oculto cross-system
]
# fan-in (blast radius)
fanin = defaultdict(int)
for a, b, _ in edges:
    fanin[b] += 1

nodes = []
for t, rows in T.items():
    sys_, layer, domain, pk, desc = META[t]
    nodes.append({"id": t, "layer": layer, "domain": domain,
                  "loc": len(rows), "access": "read" if layer == "SAP-CHECK" else "update"})
graph = {"system": "BANKING-SAP-CRM-LATAM", "nodes": nodes,
         "edges": [{"from": a, "to": b, "type": ty} for a, b, ty in edges]}

# ---- disposicion de migracion (el "7R" de datos) + riesgo ----
# Rehost-raw | Conform | Master/Consolidate | Retire | Archive
DISP = {
    "but000": ("Master/Consolidate", "red", "Cliente: system of record + entity resolution con CRM"),
    "but0bk": ("Conform", "yellow", "Detalle bancario; tipado"),
    "bkk_acct": ("Conform", "orange", "FK a cliente; nulos/borrados a cuarentena"),
    "bkkit": ("Conform", "red", "Alto volumen + trampa decimales por moneda (TCURX) + huerfanos"),
    "vdarl": ("Conform", "yellow", "Credito; FK partner; TCURX"),
    "tcurx": ("Rehost-raw", "green", "Check table; carga 1:1 (habilita conversion de montos)"),
    "crm_account": ("Master/Consolidate", "red", "Cliente comercial; merge a golden record SAP (MDM)"),
    "crm_contact": ("Conform", "green", "Comercial; FK a cuenta CRM"),
    "crm_opportunity": ("Conform", "yellow", "Comercial; FK a cuenta CRM; multi-moneda"),
}

# ---- wave plan ----
WAVES = [
    ("Wave 0 - Foundation", ["tcurx", "but000", "crm_account"],
     "Check tables + cliente mastereado (referenciado por todo). Entity resolution SAP<->CRM aqui."),
    ("Wave 1 - Cuentas y productos", ["bkk_acct", "but0bk", "vdarl"],
     "Dependen del cliente. FK validada contra Wave 0."),
    ("Wave 2 - Movimientos", ["bkkit"],
     "Mayor volumen; depende de cuentas. Conversion TCURX critica."),
    ("Wave 3 - Comercial CRM", ["crm_contact", "crm_opportunity"],
     "Capa comercial; depende de cuentas CRM mastereadas."),
]

RISK_RANK = {"green": 1, "yellow": 2, "orange": 3, "red": 4, "black": 5}

# ============================================================================
# EMIT ARTIFACTS
# ============================================================================
os.makedirs(ART, exist_ok=True)


def w(name, text):
    with open(os.path.join(ART, name), "w", encoding="utf-8") as f:
        f.write(text)


def tbl(headers, rows):
    out = "| " + " | ".join(headers) + " |\n"
    out += "|" + "|".join("---" for _ in headers) + "|\n"
    for r in rows:
        out += "| " + " | ".join(str(x) for x in r) + " |\n"
    return out


# dependency-graph.json (renderizable con render_graph.py de RE)
with open(os.path.join(ART, "dependency-graph.json"), "w", encoding="utf-8") as f:
    json.dump(graph, f, indent=2, ensure_ascii=False)

# source-inventory.md
inv_rows = [(t, META[t][0], META[t][1], META[t][2], META[t][3], len(T[t]),
             len(T[t][0].keys()) if T[t] else 0) for t in T]
w("source-inventory.md", "# Source Inventory - BANKING-SAP-CRM-LATAM\n\n"
  "> Descubierto del data estate (2 sistemas fuente). Generado por profile.py.\n\n"
  + tbl(["Tabla", "Sistema", "Capa", "Dominio", "PK", "# filas", "# cols"], inv_rows)
  + "\n**Sistemas fuente:** SAP ECC Banking (system of record) + CRM generico.\n")

# profiling-report.md
prof = "# Profiling Report\n\n> Null rate y cardinalidad por columna (columnas clave). Generado por profile.py.\n\n"
for t in T:
    prof += "## %s (%s, %d filas)\n\n" % (t, META[t][4], len(T[t]))
    rows = []
    for c, p in PROFILE[t].items():
        rows.append((c, p["nulls"], "%.1f%%" % (p["null_rate"] * 100), p["distinct"]))
    prof += tbl(["Columna", "Nulls", "Null rate", "Distinct"], rows) + "\n"
w("profiling-report.md", prof)

# dq-baseline.md
dq_rows = [
    ("Huerfanos bkkit.ACCT -> bkk_acct", dq["bkkit_orphan_acct"], "FK; cuarentena en Silver"),
    ("Huerfanos vdarl.PARTNER -> but000", dq["vdarl_orphan_partner"], "FK; cuarentena"),
    ("Claves duplicadas bkkit", dq["bkkit_dup_keys"], "Dedup en Silver"),
    ("Fechas invalidas '00000000'", dq["invalid_dates"], "DATS->NULL"),
    ("Flags de borrado (XDELE/LOEVM)", dq["deletion_flags"], "Filtrar en Silver"),
    ("bkk_acct.PARTNER nulo", dq["bkk_acct_null_partner"], "Completeness; cuarentena"),
    ("bkkit.AMOUNT nulo", dq["bkkit_null_amount"], "Completeness; cuarentena"),
    ("Filas en moneda 0-decimales %s (trampa TCURX)" % ",".join(dq["currency_trap_currencies"]),
     dq["currency_trap_rows"], "Conversion /10^TCURX; NUNCA /100 fijo"),
    ("Pais CRM no-ISO (%d valores distintos)" % len(dq["crm_country_nonstd_values"]),
     dq["crm_country_nonstd_rows"], "Normalizar a ISO-2"),
]
w("dq-baseline.md", "# Data Quality Baseline (descubierto)\n\n"
  "> Issues DESCUBIERTOS por profiling, sin answer key (como en un engagement real).\n\n"
  + tbl(["Hallazgo", "# filas", "Accion en target"], dq_rows)
  + "\n**Valores de pais no-ISO encontrados:** %s\n" % ", ".join("`%s` (%d)" % (k, v) for k, v in dq["crm_country_nonstd_values"].items()))

# entity-coupling.md
w("entity-coupling.md", "# Cross-System Entity Coupling (el acoplamiento OCULTO)\n\n"
  "> Analogo del copybook coupling de Mainframe: el cliente es la MISMA entidad en SAP\n"
  "> (BUT000) y CRM (crm_account), y ningun FK lo muestra. Esto dispara MDM/entity resolution.\n\n"
  + tbl(["Metrica", "Valor"], [
      ("Clientes SAP (BUT000)", entity["sap_customers"]),
      ("Cuentas CRM totales", entity["crm_total"]),
      ("CRM con sap_partner_ref (match exacto)", entity["crm_with_ref"]),
      ("CRM sin ref (requieren fuzzy)", entity["crm_without_ref"]),
      ("Fuzzy hits por nombre+pais (descubierto)", entity["fuzzy_name_hits"]),
      ("Nombres CRM duplicados (problema MDM)", entity["crm_duplicate_names"]),
  ])
  + "\n`[HALLAZGO]` El cliente requiere **Master/Consolidate**: resolver SAP<->CRM "
    "(ref exacto + fuzzy nombre+pais) y mergear duplicados a un golden record. "
    "Es el trabajo no obvio que un plan basado solo en FK no ve.\n")

# dispositions.md
disp_rows = []
for t in T:
    d, risk, why = DISP[t]
    disp_rows.append((t, META[t][2], d, risk, len(T[t]), why))
disp_rows.sort(key=lambda r: -RISK_RANK[r[3]])
w("dispositions.md", "# Disposicion de Migracion por Tabla (el \"7R\" de datos)\n\n"
  "> Taxonomia: Rehost-raw (Bronze 1:1) | Conform (Silver) | Master/Consolidate (entity\n"
  "> resolution) | Retire | Archive. Riesgo: green < yellow < orange < red < black.\n\n"
  + tbl(["Tabla", "Dominio", "Disposicion", "Riesgo", "# filas", "Razon"], disp_rows)
  + "\n**Sin candidatos a Retire/Archive a nivel tabla** en este estate; los huerfanos se "
    "manejan a nivel fila (cuarentena). Las 2 tablas de cliente concentran el riesgo (mastering).\n")

# wave-plan.md
wp = "# Wave Plan (orden de migracion)\n\n> Por dominio + orden de dependencia + riesgo. Generado por profile.py.\n\n"
for name, tables, note in WAVES:
    wp += "## %s\n%s\n\n" % (name, note)
    wp += tbl(["Tabla", "Disposicion", "Riesgo", "# filas"],
              [(t, DISP[t][0], DISP[t][1], len(T[t])) for t in tables]) + "\n"
w("wave-plan.md", wp)

# handoff-discover-to-target.md
w("handoff-discover-to-target.md", "# Handoff: Fase 1 Discover -> Fase 2 Target Design & Data Contracts\n\n"
  "> Qué se entrega a la siguiente fase.\n\n"
  "- **Inventario perfilado** (`source-inventory.md` + `profiling-report.md`): 9 tablas, 2 sistemas.\n"
  "- **Dependency graph** (`dependency-graph.json`, renderizable): FK + entity-link cross-system.\n"
  "- **DQ baseline** (`dq-baseline.md`): %d huerfanos bkkit, %d dups, %d fechas invalidas, %d flags borrado, %d filas trampa-moneda, %d filas pais no-ISO.\n"
  "- **Entity coupling** (`entity-coupling.md`): cliente requiere MDM (%d CRM, %d con ref, %d fuzzy).\n"
  "- **Disposiciones** (`dispositions.md`) + **Wave plan** (`wave-plan.md`).\n\n"
  "**Para Fase 2:** diseñar el medallion target + data contracts por dominio; el contrato de "
  "`customer` debe incluir la regla de entity resolution. ADR de plataforma (BigQuery) + patron "
  "(bulk + CDC). PII: BUT000/crm requieren clasificacion (Cybersecurity Data Security).\n"
  % (dq["bkkit_orphan_acct"], dq["bkkit_dup_keys"], dq["invalid_dates"], dq["deletion_flags"],
     dq["currency_trap_rows"], dq["crm_country_nonstd_rows"],
     entity["crm_total"], entity["crm_with_ref"], entity["crm_without_ref"]))


# ============================================================================
# EMIT discovery-assessment.html (deliverable publicable)
# ============================================================================
total_rows = sum(len(r) for r in T.values())
hubs = sorted(fanin.items(), key=lambda kv: -kv[1])
red_tables = [t for t in T if DISP[t][1] in ("red", "black")]

def cards(items):
    return "".join('<div class="card"><div class="n">%s</div><div class="v">%s</div></div>' % (k, v) for k, v in items)

def htable(headers, rows):
    h = "<tr>" + "".join("<th>%s</th>" % x for x in headers) + "</tr>"
    b = "".join("<tr>" + "".join("<td>%s</td>" % c for c in r) + "</tr>" for r in rows)
    return "<table>%s%s</table>" % (h, b)

risk_badge = {"green": "#2e7d4f", "yellow": "#b58900", "orange": "#cb6b15", "red": "#c0392b", "black": "#1a1a2e"}

disp_html_rows = []
for t in sorted(T, key=lambda x: -RISK_RANK[DISP[x][1]]):
    d, risk, why = DISP[t]
    badge = '<span style="background:%s;color:#fff;padding:1px 8px;border-radius:10px;font-size:11px">%s</span>' % (risk_badge[risk], risk)
    disp_html_rows.append((t, META[t][2], d, badge, len(T[t]), why))

dq_html_rows = [(r[0], r[1], r[2]) for r in dq_rows]
wave_html = ""
for name, tables, note in WAVES:
    wave_html += "<h3>%s</h3><p class='muted'>%s</p>%s" % (
        name, note, htable(["Tabla", "Disposicion", "Riesgo", "# filas"],
                            [(t, DISP[t][0], DISP[t][1], len(T[t])) for t in tables]))

html = Template(r"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Discovery Assessment - BANKING-SAP-CRM-LATAM</title>
<style>
 :root{--purple:#6B21A8;--magenta:#A100FF;--ink:#1A1A2E;--bg:#f4f4f6;--card:#fff;--line:#dcdce4;--txt:#22222e;--muted:#63636f;--green:#2e7d4f}
 *{box-sizing:border-box}body{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);line-height:1.55;font-size:14.5px}
 header{background:var(--ink);color:#fff;padding:22px 38px;border-bottom:3px solid var(--purple)}
 header h1{margin:0;font-size:21px}header p{margin:4px 0 0;font-size:12.5px;opacity:.8}
 main{max-width:1080px;margin:0 auto;padding:30px 28px 70px}
 h2{font-size:13px;text-transform:uppercase;letter-spacing:.6px;color:var(--purple);margin:30px 0 12px;border-bottom:1px solid var(--line);padding-bottom:6px}
 h3{font-size:14.5px;color:var(--ink);margin:18px 0 6px}
 .grid{display:grid;gap:13px;grid-template-columns:repeat(4,1fr);margin:10px 0}
 @media(max-width:760px){.grid{grid-template-columns:1fr 1fr}}
 .card{background:var(--card);border:1px solid var(--line);border-left:4px solid var(--magenta);border-radius:6px;padding:13px 15px}
 .card .n{font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:.4px}
 .card .v{font-size:20px;font-weight:700;color:var(--ink);margin-top:3px}
 table{border-collapse:collapse;width:100%;background:#fff;border:1px solid var(--line);border-radius:6px;overflow:hidden;font-size:13px;margin:8px 0}
 th{background:#f0eef6;color:var(--purple);text-align:left;padding:7px 10px;font-size:11.5px;text-transform:uppercase;letter-spacing:.3px}
 td{padding:7px 10px;border-top:1px solid var(--line)}
 .muted{color:var(--muted);font-size:13px}
 .verdict{background:#f3effa;border:1px solid #e0d5f3;border-radius:8px;padding:16px 18px;margin:10px 0}
 .verdict b{color:var(--purple)}
 .flag{background:#fdecea;border-left:4px solid #c0392b;padding:12px 15px;border-radius:6px;margin:10px 0}
 .ok{background:#e9f6ee;border-left:4px solid var(--green);padding:12px 15px;border-radius:6px;margin:10px 0}
 ul{margin:8px 0;padding-left:20px}li{margin:4px 0}
 .pill{display:inline-block;background:#eee;border-radius:10px;padding:1px 9px;font-size:11px;color:var(--muted);margin-left:6px}
 footer{text-align:center;color:var(--muted);font-size:11px;padding:20px;border-top:1px solid var(--line)}
 a.link{color:var(--magenta);text-decoration:none}
</style></head><body>
<header><h1>Discovery Assessment &mdash; BANKING-SAP-CRM-LATAM</h1>
<p>Fase 1 &mdash; Discover &amp; Source Profiling &middot; Data Migration &middot; AI-ready Data &middot; &#9733; Digital Core
&middot; generado por profiler/profile.py &middot; ${date}</p></header>
<main>

<h2>Executive summary</h2>
<div class="grid">${summary_cards}</div>
<div class="verdict"><b>Veredicto Discover:</b> data estate de <b>2 sistemas fuente</b> (SAP ECC Banking como system of record + CRM generico) con <b>${total_rows} filas</b> en ${n_tables} tablas y ${n_domains} dominios. <b>El cliente es la misma entidad en ambos sistemas y ningun FK lo muestra</b> &mdash; el estate NO es migrable con un plan basado solo en claves: requiere <b>entity resolution + MDM</b> en el dominio customer. Trampa adicional: montos en monedas de 0 decimales (${trap_cur}) que un pipeline naive corrompe x100. Readiness: <b>condicional</b> a resolver mastering + reglas TCURX en Fase 2.</div>

<h2>Inventario por sistema y capa</h2>
${inventory}
<p class="muted"><b>Nota de modelado:</b> en este data seed con filas, <code>BKK_ACCT</code> es un <b>account master simplificado</b> (1 fila por cuenta) para ejercitar DQ y entity resolution a nivel dato. En SAP real la cuenta se reparte en la familia BKK* (BKK40 balances, BKKIT movimientos, contrato de cuenta); el <b>modelo a escala</b> del Reference Data Lab ya usa esos nombres reales. Simplificación documentada y validada por el SME SAP Banking Services.</p>

<h2>Hubs &mdash; blast radius (fan-in)</h2>
<p class="muted">Tablas mas referenciadas: maximo impacto si cambian. El cliente (BUT000) es el hub central.</p>
${hubs}

<h2>Cross-system entity coupling &mdash; el acoplamiento OCULTO</h2>
<div class="flag"><b>[HALLAZGO]</b> El cliente vive en SAP (<code>BUT000</code>, ${sap_cust}) y en CRM (<code>crm_account</code>, ${crm_total}). Solo ${crm_ref} traen <code>sap_partner_ref</code>; <b>${crm_noref} requieren matching por nombre+pais</b> y hay <b>${crm_dup} nombres CRM duplicados</b> (mismo cliente, varias cuentas). Analogo del <i>copybook coupling</i> de Mainframe: el acoplamiento que el call/FK graph no muestra.</div>
${entity}

<h2>Data Quality baseline (descubierto)</h2>
<p class="muted">Issues hallados por profiling, sin answer key &mdash; como en un engagement real.</p>
${dq}

<h2>Dependency map</h2>
<p class="muted">Grafo de dependencias (FK + entity-link) en <code>artifacts/dependency-graph.json</code>, renderizable con el visualizador de Reverse Engineering: <code>render_graph.py --graph artifacts/dependency-graph.json --out graph-view.html</code>. Nodos=tablas, aristas=FK, layer=sistema/capa, la arista <code>entity-link</code> marca el acoplamiento cross-system.</p>

<h2>Disposicion de migracion por tabla (el "7R" de datos)</h2>
<p class="muted">Rehost-raw (Bronze 1:1) &middot; Conform (Silver) &middot; Master/Consolidate (entity resolution) &middot; Retire &middot; Archive.</p>
${disp}

<h2>Wave plan</h2>
${waves}

<h2>Discover closing gate</h2>
<div class="ok"><b>Criterios de completitud antes de Fase 2:</b><ul>
<li>Inventario + profiling de las ${n_tables} tablas completo &#10003;</li>
<li>Dependency graph (FK + entity-link) emitido &#10003;</li>
<li>DQ baseline cuantificado &#10003;</li>
<li>Entity coupling cuantificado (alcance MDM) &#10003;</li>
<li>Disposicion + wave plan por tabla &#10003;</li>
<li><b>Pendiente humano:</b> clasificacion PII + criticidad por Data Steward (HITL) antes de firmar el gate.</li>
</ul></div>

<h2>Handoff a Fase 2 &mdash; Target Design &amp; Data Contracts</h2>
<p class="muted">Detalle en <code>artifacts/handoff-discover-to-target.md</code>.</p>
<ul>
<li>Diseñar medallion target + data contracts por dominio; el contrato de <b>customer</b> incluye la regla de entity resolution.</li>
<li>ADR de plataforma (BigQuery) + patron (bulk + CDC).</li>
<li>Reglas de transformacion confirmadas: DATS&rarr;DATE, ALPHA, <b>CURR/TCURX</b>, dedup, FK-quarantine, country-map, entity-resolution.</li>
<li>PII: BUT000/crm a clasificacion (Cybersecurity Data Security) antes de Bronze.</li>
</ul>

</main>
<footer>Fase 1 Discover &middot; Data Migration &middot; uso interno &middot; data de referencia (seed-sap-banking-crm), cero IP de cliente</footer>
</body></html>""").safe_substitute({
    "date": datetime.now().strftime("%Y-%m-%d"),
    "total_rows": "{:,}".format(total_rows),
    "n_tables": len(T),
    "n_domains": len(set(m[2] for m in META.values())),
    "trap_cur": ",".join(dq["currency_trap_currencies"]),
    "summary_cards": cards([
        ("Sistemas fuente", 2), ("Tablas", len(T)), ("Filas totales", "{:,}".format(total_rows)),
        ("Dominios", len(set(m[2] for m in META.values()))),
        ("Tablas riesgo alto", len(red_tables)), ("Huerfanos bkkit", dq["bkkit_orphan_acct"]),
        ("Filas trampa-moneda", dq["currency_trap_rows"]), ("CRM sin ref (fuzzy)", entity["crm_without_ref"]),
    ]),
    "inventory": htable(["Tabla", "Sistema", "Capa", "Dominio", "PK", "# filas"],
                        [(t, META[t][0], META[t][1], META[t][2], META[t][3], "{:,}".format(len(T[t]))) for t in T]),
    "hubs": htable(["Tabla (hub)", "Fan-in (referenciada por)", "Dominio"],
                   [(t, n, META[t][2]) for t, n in hubs if n > 0]),
    "sap_cust": entity["sap_customers"], "crm_total": entity["crm_total"],
    "crm_ref": entity["crm_with_ref"], "crm_noref": entity["crm_without_ref"], "crm_dup": entity["crm_duplicate_names"],
    "entity": htable(["Metrica", "Valor"], [
        ("Clientes SAP (BUT000)", entity["sap_customers"]), ("Cuentas CRM", entity["crm_total"]),
        ("CRM con ref exacto", entity["crm_with_ref"]), ("CRM sin ref (fuzzy)", entity["crm_without_ref"]),
        ("Fuzzy hits nombre+pais", entity["fuzzy_name_hits"]), ("Nombres CRM duplicados", entity["crm_duplicate_names"])]),
    "dq": htable(["Hallazgo", "# filas", "Accion en target"], dq_html_rows),
    "disp": htable(["Tabla", "Dominio", "Disposicion", "Riesgo", "# filas", "Razon"], disp_html_rows),
    "waves": wave_html,
})

with open(os.path.join(FASE_DIR, "discovery-assessment.html"), "w", encoding="utf-8") as f:
    f.write(html)


# ----------------------------------------------------------------------------
print("OK - Fase 1 Discover deliverable generado")
print("  artifacts/: source-inventory, profiling-report, dq-baseline, entity-coupling,")
print("              dispositions, wave-plan, handoff, dependency-graph.json")
print("  discovery-assessment.html (deliverable)")
print("  DQ: orphans bkkit=%d vdarl=%d | dups=%d | baddate=%d | delflag=%d | nullamt=%d | trap=%d (%s) | country=%d" % (
    dq["bkkit_orphan_acct"], dq["vdarl_orphan_partner"], dq["bkkit_dup_keys"], dq["invalid_dates"],
    dq["deletion_flags"], dq["bkkit_null_amount"], dq["currency_trap_rows"],
    ",".join(dq["currency_trap_currencies"]), dq["crm_country_nonstd_rows"]))
print("  entity: crm=%d ref=%d noref=%d fuzzy_hits=%d dup_names=%d" % (
    entity["crm_total"], entity["crm_with_ref"], entity["crm_without_ref"],
    entity["fuzzy_name_hits"], entity["crm_duplicate_names"]))
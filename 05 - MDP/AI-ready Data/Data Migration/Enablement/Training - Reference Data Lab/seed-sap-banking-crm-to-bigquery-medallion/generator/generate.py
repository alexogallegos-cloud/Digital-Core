#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate.py - Reference Data Lab (AI-ready Data / Digital Core)
seed: seed-sap-banking-crm-to-bigquery-medallion

Caso: core bancario SAP ECC (Banking/FS: Business Partner + Deposits Mgmt + Loans)
+ un CRM generico, integrados en un medallion BigQuery con cliente mastereado
(Customer 360). Reto estrella: ENTITY RESOLUTION SAP<->CRM.

Como yo genero ambos sistemas a partir de un set de clientes "reales", conozco el
crosswalk verdadero (que cuenta CRM = que Business Partner SAP). Ese crosswalk es el
answer key de la resolucion de entidad, ademas del lineage/reglas/DQ/reconciliacion.

Determinista por SEED. Solo stdlib.
Ejecutar:  python generate.py
Salida:    ../source/{sap,crm}/*.csv  ../target-ddl/*.sql  ../answer-key/*.md
"""

import csv
import os
import random
import unicodedata
from datetime import date, datetime, timedelta

# ----------------------------------------------------------------------------
# PARAMS (espejan generation-spec.yaml)
# ----------------------------------------------------------------------------
SEED = 73
MANDT = "100"
N_REAL = 300                 # clientes reales (la verdad)
CRM_COVERAGE = 0.70          # fraccion presente en CRM
CRM_ONLY = 40                # cuentas CRM sin SAP (prospectos)
CRM_DUP = 25                 # clientes reales con 2 cuentas CRM
CRM_REF_POP = 0.55           # fraccion con sap_partner_ref correcto
ACCTS_AVG = 1.7
TXNS_AVG = 12
LOANS_FRAC = 0.5

CURRENCY_DEC = {"MXN": 2, "USD": 2, "JPY": 0, "CLP": 0}
CURR_WEIGHTS = [("MXN", 70), ("USD", 20), ("JPY", 5), ("CLP", 5)]

HERE = os.path.dirname(os.path.abspath(__file__))
SEED_DIR = os.path.dirname(HERE)
SAP_DIR = os.path.join(SEED_DIR, "source", "sap")
CRM_DIR = os.path.join(SEED_DIR, "source", "crm")
DDL_DIR = os.path.join(SEED_DIR, "target-ddl")
AK_DIR = os.path.join(SEED_DIR, "answer-key")

rng = random.Random(SEED)
PLANTED = []


def plant(dtype, system, table, key, detail, action):
    PLANTED.append({"type": dtype, "system": system, "table": table,
                    "key": key, "detail": detail, "action": action})


# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------
def alpha(n, width):
    return str(n).zfill(width)


def dats(d):
    return d.strftime("%Y%m%d")


BASE = date(2020, 1, 1)


def rand_date(span=1800):
    return BASE + timedelta(days=rng.randint(0, span))


def strip_accents(s):
    return "".join(c for c in unicodedata.normalize("NFKD", s)
                   if not unicodedata.combining(c))


def norm_name(s):
    """clave canonica de match: sin acentos, mayusculas, solo alfanumerico+espacio."""
    s = strip_accents(s).upper()
    out = []
    for ch in s:
        out.append(ch if (ch.isalnum() or ch == " ") else " ")
    return " ".join("".join(out).split())


def pick_currency():
    r = rng.randint(1, sum(w for _, w in CURR_WEIGHTS))
    acc = 0
    for c, w in CURR_WEIGHTS:
        acc += w
        if r <= acc:
            return c
    return "MXN"


ORG_A = ["Banco", "Grupo", "Distribuidora", "Comercial", "Constructora",
         "Inmobiliaria", "Industrias", "Servicios", "Corporativo", "Transportes"]
ORG_B = ["del Norte", "Azteca", "del Pacifico", "Latina", "del Bajio",
         "Peninsular", "Regio", "del Golfo", "Central", "Continental"]
ORG_SUF = ["SA de CV", "S.A. de C.V.", "SA", "S.A.", "SAPI de CV", ""]
P_FIRST = ["Maria", "Jose", "Juan", "Guadalupe", "Francisco", "Ana", "Luis",
           "Carlos", "Marta", "Miguel", "Rosa", "Pedro"]
P_LAST = ["Hernandez", "Garcia", "Martinez", "Lopez", "Gonzalez", "Rodriguez",
          "Perez", "Sanchez", "Ramirez", "Torres", "Flores", "Rivera"]
SEGMENTS = ["Retail", "Premier", "Business", "Corporate"]
COUNTRY_ISO = ["MX", "MX", "MX", "US", "CL"]   # sesgo LATAM
# como el CRM escribe el pais (inconsistente) por ISO
CRM_COUNTRY_VARIANTS = {
    "MX": ["MX", "Mexico", "Mexico", "MEX", "Mexico "],   # incluye acento via fuzz luego
    "US": ["US", "USA", "Estados Unidos", "United States"],
    "CL": ["CL", "Chile", "CHL"],
}


def fuzz_text(s):
    """variante de display: acentos, mayusculas, espacios."""
    r = rng.random()
    if r < 0.25:
        return s.upper()
    if r < 0.45:
        return s.replace("Mexico", "Mexico")  # placeholder; acento se inyecta abajo
    if r < 0.6:
        return s + " "
    return s


# ----------------------------------------------------------------------------
# 0) CLIENTES REALES (la verdad) — base de la resolucion de entidad
# ----------------------------------------------------------------------------
real = []   # {real_id, ctype, core_name, name_norm, country, segment}
for i in range(1, N_REAL + 1):
    if rng.random() < 0.6:
        ctype = "2"  # organizacion
        core = "%s %s" % (rng.choice(ORG_A), rng.choice(ORG_B))
    else:
        ctype = "1"  # persona
        core = "%s %s %s" % (rng.choice(P_FIRST), rng.choice(P_LAST), rng.choice(P_LAST))
    real.append({"real_id": i, "ctype": ctype, "core": core,
                  "name_norm": norm_name(core), "country": rng.choice(COUNTRY_ISO),
                  "segment": rng.choice(SEGMENTS)})


# ----------------------------------------------------------------------------
# 1) SAP - BUT000 (Business Partner) — SoR; todos los clientes reales estan aqui
# ----------------------------------------------------------------------------
but000 = []
but0bk = []
partner_of_real = {}             # real_id -> PARTNER
valid_partners = set()
del_partners = set(rng.sample(range(N_REAL), 12))      # XDELE='X'
baddate_partners = set(rng.sample(range(N_REAL), 8))   # CRDAT invalido

for idx, rc in enumerate(real):
    partner = alpha(1000000 + rc["real_id"], 10)
    partner_of_real[rc["real_id"]] = partner
    xdele = ""
    crdat = dats(rand_date())
    if idx in del_partners:
        xdele = "X"
        plant("deletion_flag", "SAP", "BUT000", "PARTNER=%s" % partner,
              "Business Partner con XDELE='X'", "Filtrar en silver_party; conservar en bronze")
    if idx in baddate_partners:
        crdat = "00000000"
        plant("invalid_date", "SAP", "BUT000", "PARTNER=%s" % partner,
              "CRDAT='00000000'", "DATS->DATE: NULL")
    if rc["ctype"] == "2":
        name_org = rc["core"] + (" " + rng.choice(ORG_SUF)).rstrip()
        name_first = name_last = ""
        name_disp = name_org
    else:
        parts = rc["core"].split()
        name_first, name_last = parts[0], " ".join(parts[1:])
        name_org = ""
        name_disp = rc["core"]
    but000.append({"MANDT": MANDT, "PARTNER": partner, "TYPE": rc["ctype"],
                   "NAME_ORG1": name_org, "NAME_FIRST": name_first, "NAME_LAST": name_last,
                   "LAND1": rc["country"], "XDELE": xdele, "CRDAT": crdat,
                   "_name_disp": name_disp})
    if xdele != "X":
        valid_partners.add(partner)
    # bank details (BUT0BK) 1 por partner
    but0bk.append({"MANDT": MANDT, "PARTNER": partner, "BKVID": "0001",
                   "BANKL": alpha(rng.randint(1, 99), 3) + "000",
                   "BANKN": alpha(rng.randint(1, 9999999999), 10)})

all_partners = [b["PARTNER"] for b in but000]
partner_name = {b["PARTNER"]: b["_name_disp"] for b in but000}


# ----------------------------------------------------------------------------
# 2) SAP - BKK_ACCT (cuentas deposito) + BKKIT (movimientos)
# ----------------------------------------------------------------------------
bkk_acct = []
acct_currency = {}
valid_accts = set()
del_accts = set()
null_partner_accts = set()
acct_counter = 0
accts_of_partner = {}

n_accounts_target = int(N_REAL * ACCTS_AVG)
# asignar cuentas
for rc in real:
    partner = partner_of_real[rc["real_id"]]
    n_acc = max(1, int(rng.gauss(ACCTS_AVG, 0.8)))
    for _ in range(n_acc):
        acct_counter += 1
        acct = alpha(50000000 + acct_counter, 12)
        cur = pick_currency()
        acct_currency[acct] = cur
        if cur in ("JPY", "CLP"):
            plant("currency_decimal_trap", "SAP", "BKK_ACCT", "ACCT=%s" % acct,
                  "Moneda %s con %d decimales (TCURX); montos en minor units" % (cur, CURRENCY_DEC[cur]),
                  "Convertir /10^TCURX(%s); naive /100 corrompe x100" % cur)
        loevm = ""
        partner_field = partner
        if rng.random() < 0.02:
            loevm = "X"
            del_accts.add(acct)
            plant("deletion_flag", "SAP", "BKK_ACCT", "ACCT=%s" % acct,
                  "Cuenta con LOEVM='X'", "Filtrar en silver_account")
        if rng.random() < 0.01:
            partner_field = ""
            null_partner_accts.add(acct)
            plant("null_mandatory", "SAP", "BKK_ACCT", "ACCT=%s" % acct,
                  "PARTNER vacio (obligatorio)", "DQ completeness; cuarentena")
        bkk_acct.append({"MANDT": MANDT, "ACCT": acct, "PARTNER": partner_field,
                         "PRODUCT": rng.choice(["DDA", "SAV", "MMA"]), "WAERS": cur,
                         "OPEN_DATE": dats(rand_date()), "STATUS": "A" if loevm == "" else "C",
                         "LOEVM": loevm})
        accts_of_partner.setdefault(partner, []).append(acct)
        if loevm == "" and partner_field != "":
            valid_accts.add(acct)

all_accts = [a["ACCT"] for a in bkk_acct]

# BKKIT - movimientos
bkkit = []
item_seq = {}
for acct in all_accts:
    cur = acct_currency[acct]
    n_txn = max(1, int(rng.gauss(TXNS_AVG, 4)))
    for _ in range(n_txn):
        item_seq[acct] = item_seq.get(acct, 0) + 1
        item_no = alpha(item_seq[acct], 6)
        minor = rng.randint(1000, 5000000)
        dc = rng.choice(["S", "H"])   # Soll/Haben (debito/credito)
        bkkit.append({"MANDT": MANDT, "ACCT": acct, "ITEM_NO": item_no,
                      "POST_DATE": dats(rand_date()), "VALUT": dats(rand_date()),
                      "AMOUNT": str(minor), "WAERS": cur, "DC_IND": dc,
                      "TEXT": rng.choice(["Deposito", "Retiro", "Transferencia", "Pago", "Comision"])})

# defectos en BKKIT: orphan acct, leading-zero acct, dup key, null amount
total_txn = len(bkkit)
orphan_acct_idx = set(rng.sample(range(total_txn), 15))
lz_acct_idx = set(rng.sample(range(total_txn), 20))
dupkey_idx = set(rng.sample(range(total_txn), 8))
nullamt_idx = set(rng.sample(range(total_txn), 10))

for i, t in enumerate(bkkit):
    if i in orphan_acct_idx:
        bad = alpha(99000000 + i, 12)
        t["ACCT"] = bad
        plant("referential_orphan", "SAP", "BKKIT", "ACCT=%s ITEM_NO=%s" % (bad, t["ITEM_NO"]),
              "ACCT no existe en BKK_ACCT (movimiento huerfano)", "FK falla; cuarentena")
    elif i in lz_acct_idx:
        t["ACCT"] = t["ACCT"].lstrip("0")
        plant("leading_zero_inconsistency", "SAP", "BKKIT", "ACCT=%s ITEM_NO=%s" % (t["ACCT"], t["ITEM_NO"]),
              "ACCT sin ceros a la izquierda", "Aplicar ALPHA antes del join; NO es huerfano")
    if i in nullamt_idx:
        t["AMOUNT"] = ""
        plant("null_mandatory", "SAP", "BKKIT", "ACCT=%s ITEM_NO=%s" % (t["ACCT"], t["ITEM_NO"]),
              "AMOUNT vacio", "DQ completeness; cuarentena")

dup_rows = []
for i in dupkey_idx:
    t = bkkit[i]
    if t["AMOUNT"] == "":
        continue
    d = dict(t)
    d["AMOUNT"] = str(int(t["AMOUNT"]) + 1)
    dup_rows.append(d)
    plant("duplicate_key", "SAP", "BKKIT", "ACCT=%s ITEM_NO=%s" % (t["ACCT"], t["ITEM_NO"]),
          "Clave (ACCT,ITEM_NO) duplicada", "Dedup keep-first")
bkkit.extend(dup_rows)


# ----------------------------------------------------------------------------
# 3) SAP - VDARL (creditos FS-CML)
# ----------------------------------------------------------------------------
vdarl = []
loan_counter = 0
for rc in real:
    if rng.random() < LOANS_FRAC:
        loan_counter += 1
        darl = alpha(80000000 + loan_counter, 12)
        partner = partner_of_real[rc["real_id"]]
        cur = "MXN" if rng.random() < 0.8 else "USD"
        principal = rng.randint(50000, 500000000)
        # orphan partner plantado en ~3 creditos
        if loan_counter % 50 == 0:
            partner = alpha(97000000 + loan_counter, 10)
            plant("referential_orphan", "SAP", "VDARL", "DARLEHEN=%s PARTNER=%s" % (darl, partner),
                  "PARTNER no existe en BUT000", "FK falla; cuarentena")
        vdarl.append({"MANDT": MANDT, "DARLEHEN": darl, "PARTNER": partner,
                      "PRINCIPAL": str(principal), "WAERS": cur,
                      "RATE": str(round(rng.uniform(8.0, 24.0), 2)),
                      "START_DATE": dats(rand_date()), "TERM_MONTHS": str(rng.choice([12, 24, 36, 48, 60]))})


# ----------------------------------------------------------------------------
# 4) TCURX
# ----------------------------------------------------------------------------
tcurx = [{"CURRKEY": k, "CURRDEC": str(v)} for k, v in CURRENCY_DEC.items()]


# ----------------------------------------------------------------------------
# 5) CRM generico (NO SAP) + crosswalk verdadero (entity resolution truth)
# ----------------------------------------------------------------------------
crm_account = []
crm_contact = []
crm_opportunity = []
crosswalk = []   # {crm_id, real_id, sap_partner, match_type, crm_name, sap_name, match_key}
crm_counter = 0


def crm_country(iso):
    v = rng.choice(CRM_COUNTRY_VARIANTS[iso])
    # inyectar acento en variante "Mexico"
    if v.strip() == "Mexico" and rng.random() < 0.5:
        v = v.replace("Mexico", "México")
    return v


def make_crm_name(rc):
    core = rc["core"]
    if rc["ctype"] == "2":
        disp = core + (" " + rng.choice(ORG_SUF)).rstrip()
    else:
        disp = core
    return fuzz_text(disp)


def emit_crm_account(real_id, sap_partner, name, country_iso, match_type, ref_ok):
    global crm_counter
    crm_counter += 1
    cid = "CRM-%06d" % crm_counter
    ref = sap_partner if (ref_ok and sap_partner) else ""
    # email a veces malformado
    email = "contacto%d@%s.com" % (crm_counter, "empresa" if rng.random() < 0.5 else "cliente")
    if rng.random() < 0.08:
        bad = email.replace("@", " at ") if rng.random() < 0.5 else email.replace("@", "")
        plant("malformed_email", "CRM", "crm_account", "id=%s" % cid,
              "Email malformado ('%s')" % bad, "DQ validity; estandarizar o cuarentena de campo")
        email = bad
    cval = crm_country(country_iso)
    if cval.strip() not in ("MX", "US", "CL"):
        plant("country_inconsistent", "CRM", "crm_account", "id=%s" % cid,
              "Pais en formato no-ISO ('%s')" % cval.strip(),
              "Normalizar a ISO-2 (regla country_map)")
    crm_account.append({"id": cid, "account_name": name, "country": cval,
                        "city": rng.choice(["CDMX", "Monterrey", "Guadalajara", "Santiago", "Houston"]),
                        "segment": rng.choice(SEGMENTS),
                        "sap_partner_ref": ref,
                        "is_active": "true" if rng.random() < 0.9 else "false",
                        "created_at": (datetime(2021, 1, 1) + timedelta(days=rng.randint(0, 1400))).isoformat()})
    mk = norm_name(name) if name else ""
    crosswalk.append({"crm_id": cid, "real_id": real_id, "sap_partner": sap_partner or "",
                      "match_type": match_type,
                      "crm_name": name.strip(), "sap_name": (partner_name.get(sap_partner, "") if sap_partner else ""),
                      "match_key": norm_name(name)})
    # contactos
    for _ in range(rng.randint(1, 3)):
        cc = len(crm_contact) + 1
        crm_contact.append({"id": "CT-%06d" % cc, "account_id": cid,
                            "full_name": "%s %s" % (rng.choice(P_FIRST), rng.choice(P_LAST)),
                            "email": "p%d@mail.com" % cc, "phone": "55%08d" % rng.randint(0, 99999999),
                            "role": rng.choice(["Owner", "Finance", "Ops", "Procurement"])})
    # oportunidades
    for _ in range(rng.randint(0, 2)):
        oc = len(crm_opportunity) + 1
        ocur = pick_currency()
        crm_opportunity.append({"id": "OP-%06d" % oc, "account_id": cid,
                                "stage": rng.choice(["Prospecting", "Proposal", "Won", "Lost"]),
                                "amount": str(rng.randint(10000, 5000000)),
                                "currency": ocur,
                                "close_date": (date(2024, 1, 1) + timedelta(days=rng.randint(0, 700))).isoformat()})
    return cid


# clientes reales cubiertos por CRM
covered = rng.sample(real, int(N_REAL * CRM_COVERAGE))
covered_ids = set(rc["real_id"] for rc in covered)
for rc in covered:
    sap_partner = partner_of_real[rc["real_id"]]
    ref_ok = rng.random() < CRM_REF_POP
    name = make_crm_name(rc)
    mtype = "exact_ref" if ref_ok else "fuzzy_name"
    if not ref_ok:
        plant("missing_ref", "CRM", "crm_account", "real=%d" % rc["real_id"],
              "sap_partner_ref nulo -> requiere fuzzy match por nombre+pais", "Entity resolution por match_key+pais")
    emit_crm_account(rc["real_id"], sap_partner, name, rc["country"], mtype, ref_ok)

# duplicados CRM (segunda cuenta para mismo cliente real)
for rc in rng.sample(covered, min(CRM_DUP, len(covered))):
    sap_partner = partner_of_real[rc["real_id"]]
    name = make_crm_name(rc)   # otra variante del mismo nombre
    emit_crm_account(rc["real_id"], sap_partner, name, rc["country"], "duplicate", False)
    plant("crm_duplicate", "CRM", "crm_account", "real=%d" % rc["real_id"],
          "Segunda cuenta CRM para el mismo cliente real (MDM)", "Mastering: merge a un golden record")

# CRM-only (prospectos sin SAP)
for j in range(CRM_ONLY):
    core = "%s %s" % (rng.choice(ORG_A), rng.choice(ORG_B))
    fake = {"core": core, "ctype": "2"}
    name = make_crm_name(fake)
    emit_crm_account(None, None, name, rng.choice(COUNTRY_ISO), "crm_only", False)

# sap_only: partners sin cuenta CRM
crm_real_ids = covered_ids
for rc in real:
    if rc["real_id"] not in crm_real_ids:
        crosswalk.append({"crm_id": "", "real_id": rc["real_id"],
                          "sap_partner": partner_of_real[rc["real_id"]],
                          "match_type": "sap_only", "crm_name": "",
                          "sap_name": partner_name[partner_of_real[rc["real_id"]]],
                          "match_key": rc["name_norm"]})


# ----------------------------------------------------------------------------
# WRITE CSV
# ----------------------------------------------------------------------------
def write_csv(path, rows, cols):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({c: r.get(c, "") for c in cols})


write_csv(os.path.join(SAP_DIR, "but000.csv"), but000,
          ["MANDT", "PARTNER", "TYPE", "NAME_ORG1", "NAME_FIRST", "NAME_LAST", "LAND1", "XDELE", "CRDAT"])
write_csv(os.path.join(SAP_DIR, "but0bk.csv"), but0bk,
          ["MANDT", "PARTNER", "BKVID", "BANKL", "BANKN"])
write_csv(os.path.join(SAP_DIR, "bkk_acct.csv"), bkk_acct,
          ["MANDT", "ACCT", "PARTNER", "PRODUCT", "WAERS", "OPEN_DATE", "STATUS", "LOEVM"])
write_csv(os.path.join(SAP_DIR, "bkkit.csv"), bkkit,
          ["MANDT", "ACCT", "ITEM_NO", "POST_DATE", "VALUT", "AMOUNT", "WAERS", "DC_IND", "TEXT"])
write_csv(os.path.join(SAP_DIR, "vdarl.csv"), vdarl,
          ["MANDT", "DARLEHEN", "PARTNER", "PRINCIPAL", "WAERS", "RATE", "START_DATE", "TERM_MONTHS"])
write_csv(os.path.join(SAP_DIR, "tcurx.csv"), tcurx, ["CURRKEY", "CURRDEC"])

write_csv(os.path.join(CRM_DIR, "crm_account.csv"), crm_account,
          ["id", "account_name", "country", "city", "segment", "sap_partner_ref", "is_active", "created_at"])
write_csv(os.path.join(CRM_DIR, "crm_contact.csv"), crm_contact,
          ["id", "account_id", "full_name", "email", "phone", "role"])
write_csv(os.path.join(CRM_DIR, "crm_opportunity.csv"), crm_opportunity,
          ["id", "account_id", "stage", "amount", "currency", "close_date"])


# ----------------------------------------------------------------------------
# COMPUTE SILVER / GOLD (verdad computada de los datos)
# ----------------------------------------------------------------------------
def alpha_norm(s, width=12):
    s = s.strip()
    return s.zfill(width) if s.isdigit() else s


sp = [b for b in but000 if b["XDELE"] != "X"]                       # silver_party
sp_partners = set(b["PARTNER"] for b in sp)
all_partner_set = set(all_partners)

# silver_account: LOEVM!='X', PARTNER no nulo y existe en BUT000
sa, sa_quar = [], []
for a in bkk_acct:
    if a["LOEVM"] == "X" or a["PARTNER"] == "" or a["PARTNER"] not in all_partner_set:
        sa_quar.append(a)
    else:
        sa.append(a)
sa_ids = set(a["ACCT"] for a in sa)
sa_ids_norm = set(alpha_norm(a["ACCT"]) for a in sa)

# silver_transaction: dedup (ACCT,ITEM_NO), FK acct (tras ALPHA), amount no nulo
seen = set()
st, st_quar, dups_removed = [], [], 0
for t in bkkit:
    key = (t["ACCT"], t["ITEM_NO"])
    if key in seen:
        dups_removed += 1
        continue
    seen.add(key)
    if t["AMOUNT"] == "":
        st_quar.append((t, "null_amount"))
    elif alpha_norm(t["ACCT"]) not in sa_ids_norm:
        st_quar.append((t, "orphan_acct"))
    else:
        st.append(t)

# silver_loan: FK partner
sl, sl_quar = [], []
for v in vdarl:
    if v["PARTNER"] in all_partner_set:
        sl.append(v)
    else:
        sl_quar.append(v)

# silver_crm_account: todas, pais normalizado (mastering en gold)
COUNTRY_MAP = {"MX": "MX", "MEXICO": "MX", "MEX": "MX", "US": "US", "USA": "US",
               "ESTADOS UNIDOS": "US", "UNITED STATES": "US", "CL": "CL", "CHILE": "CL", "CHL": "CL"}


def norm_country(v):
    return COUNTRY_MAP.get(strip_accents(v).strip().upper(), v.strip())


# gold dim_customer: 1 por partner no borrado (SoR = SAP), enriquecido con CRM si matchea
# entity resolution: ref exacto o (name_key+country)
crm_by_partner = {}
for cw in crosswalk:
    if cw["sap_partner"] and cw["match_type"] in ("exact_ref", "fuzzy_name", "duplicate"):
        crm_by_partner.setdefault(cw["sap_partner"], []).append(cw["crm_id"])

dim_customer = []
for b in sp:
    linked = crm_by_partner.get(b["PARTNER"], [])
    dim_customer.append({"partner": b["PARTNER"], "crm_ids": linked,
                         "matched": len(linked) > 0})

# gold fact_transaction (sumas por moneda con TCURX)
gold_txn = [t for t in st if t["ACCT"] in sa_ids or alpha_norm(t["ACCT"]) in sa_ids_norm]
sum_real, sum_naive = {}, {}
for t in gold_txn:
    cur = t["WAERS"]
    dec = CURRENCY_DEC.get(cur, 2)
    minor = int(t["AMOUNT"])
    sum_real[cur] = sum_real.get(cur, 0.0) + minor / (10 ** dec)
    sum_naive[cur] = sum_naive.get(cur, 0.0) + minor / 100.0

# metricas entity resolution
er_counts = {}
for cw in crosswalk:
    er_counts[cw["match_type"]] = er_counts.get(cw["match_type"], 0) + 1


# ----------------------------------------------------------------------------
# WRITE TARGET DDL
# ----------------------------------------------------------------------------
def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


w(os.path.join(DDL_DIR, "01_bronze.sql"), """-- BigQuery DDL - BRONZE (raw 1:1, todo STRING, + metadata). datasets: bank_bronze
CREATE SCHEMA IF NOT EXISTS bank_bronze;
-- SAP ECC Banking
CREATE OR REPLACE TABLE bank_bronze.sap_but000 (MANDT STRING, PARTNER STRING, TYPE STRING, NAME_ORG1 STRING, NAME_FIRST STRING, NAME_LAST STRING, LAND1 STRING, XDELE STRING, CRDAT STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.sap_but0bk (MANDT STRING, PARTNER STRING, BKVID STRING, BANKL STRING, BANKN STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.sap_bkk_acct (MANDT STRING, ACCT STRING, PARTNER STRING, PRODUCT STRING, WAERS STRING, OPEN_DATE STRING, STATUS STRING, LOEVM STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.sap_bkkit (MANDT STRING, ACCT STRING, ITEM_NO STRING, POST_DATE STRING, VALUT STRING, AMOUNT STRING, WAERS STRING, DC_IND STRING, TEXT STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.sap_vdarl (MANDT STRING, DARLEHEN STRING, PARTNER STRING, PRINCIPAL STRING, WAERS STRING, RATE STRING, START_DATE STRING, TERM_MONTHS STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.sap_tcurx (CURRKEY STRING, CURRDEC STRING, _ingest_ts TIMESTAMP, _source_system STRING);
-- CRM generico
CREATE OR REPLACE TABLE bank_bronze.crm_account (id STRING, account_name STRING, country STRING, city STRING, segment STRING, sap_partner_ref STRING, is_active STRING, created_at STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.crm_contact (id STRING, account_id STRING, full_name STRING, email STRING, phone STRING, role STRING, _ingest_ts TIMESTAMP, _source_system STRING);
CREATE OR REPLACE TABLE bank_bronze.crm_opportunity (id STRING, account_id STRING, stage STRING, amount STRING, currency STRING, close_date STRING, _ingest_ts TIMESTAMP, _source_system STRING);
""")

w(os.path.join(DDL_DIR, "02_silver.sql"), """-- BigQuery DDL - SILVER (conformado, tipado, FK validadas). dataset: bank_silver
-- reglas: ver answer-key/ground-truth-transformation-rules.md
CREATE SCHEMA IF NOT EXISTS bank_silver;
CREATE OR REPLACE TABLE bank_silver.party (party_id STRING NOT NULL, party_type STRING, name STRING, country STRING, created_date DATE);
CREATE OR REPLACE TABLE bank_silver.account (account_id STRING NOT NULL, party_id STRING NOT NULL, product STRING, currency STRING, open_date DATE, status STRING);
CREATE OR REPLACE TABLE bank_silver.transaction (account_id STRING, item_no STRING, post_date DATE, value_date DATE, amount NUMERIC, currency STRING, dc_indicator STRING, memo STRING);
CREATE OR REPLACE TABLE bank_silver.loan (loan_id STRING, party_id STRING, principal NUMERIC, currency STRING, rate NUMERIC, start_date DATE, term_months INT64);
CREATE OR REPLACE TABLE bank_silver.crm_account (crm_id STRING, account_name STRING, country STRING, city STRING, segment STRING, sap_partner_ref STRING, is_active BOOL, created_at TIMESTAMP);
CREATE OR REPLACE TABLE bank_silver.crm_contact (crm_contact_id STRING, crm_id STRING, full_name STRING, email STRING, phone STRING, role STRING);
CREATE OR REPLACE TABLE bank_silver.crm_opportunity (crm_opp_id STRING, crm_id STRING, stage STRING, amount NUMERIC, currency STRING, close_date DATE);
CREATE OR REPLACE TABLE bank_silver._quarantine (source_table STRING, business_key STRING, reason STRING, raw JSON, _quarantined_ts TIMESTAMP);
""")

w(os.path.join(DDL_DIR, "03_gold.sql"), """-- BigQuery DDL - GOLD (dimensional + Customer 360 mastereado). dataset: bank_gold
-- dim_customer = SAP (system of record) enriquecido por entity resolution con CRM.
CREATE SCHEMA IF NOT EXISTS bank_gold;
CREATE OR REPLACE TABLE bank_gold.dim_customer (
  customer_sk INT64, party_id STRING, name STRING, party_type STRING, country STRING,
  segment STRING,                 -- enriquecido del CRM si hubo match
  crm_matched BOOL, crm_account_ids ARRAY<STRING>,  -- crosswalk resuelto (merge de duplicados)
  golden_record_source STRING);   -- 'SAP+CRM' | 'SAP-only'
CREATE OR REPLACE TABLE bank_gold.dim_account (account_sk INT64, account_id STRING, customer_sk INT64, product STRING, currency STRING, open_date DATE, status STRING);
CREATE OR REPLACE TABLE bank_gold.fact_transaction (account_sk INT64, customer_sk INT64, post_date DATE, amount NUMERIC, currency STRING, dc_indicator STRING)
PARTITION BY post_date CLUSTER BY customer_sk;
CREATE OR REPLACE TABLE bank_gold.fact_loan (loan_id STRING, customer_sk INT64, principal NUMERIC, currency STRING, rate NUMERIC, start_date DATE, term_months INT64);
CREATE OR REPLACE TABLE bank_gold.fact_crm_opportunity (crm_opp_id STRING, customer_sk INT64, stage STRING, amount NUMERIC, currency STRING, close_date DATE);
CREATE OR REPLACE TABLE bank_gold.agg_customer_balance (customer_sk INT64, currency STRING, net_balance NUMERIC, txn_count INT64);
""")


# ----------------------------------------------------------------------------
# WRITE ANSWER KEY
# ----------------------------------------------------------------------------
n_makt = 0  # n/a aqui


def block(rows):
    return "\n".join(rows)


w(os.path.join(AK_DIR, "ground-truth-source-inventory.md"), """# Ground Truth - Source Inventory (2 sistemas)

> Computado de los datos emitidos. seed=%d.

## SAP ECC Banking (system of record)
| Tabla | Descripcion | Clave | # filas |
|-------|-------------|-------|---------|
| BUT000 | Business Partner (cliente) | MANDT+PARTNER | %d |
| BUT0BK | BP bank details | MANDT+PARTNER+BKVID | %d |
| BKK_ACCT | Cuenta deposito (Deposits Mgmt) | MANDT+ACCT | %d |
| BKKIT | Movimientos de cuenta | MANDT+ACCT+ITEM_NO | %d |
| VDARL | Contrato de credito (FS-CML) | MANDT+DARLEHEN | %d |
| TCURX | Decimales por moneda | CURRKEY | %d |

## CRM generico
| Tabla | Descripcion | Clave | # filas |
|-------|-------------|-------|---------|
| crm_account | Cuenta CRM | id | %d |
| crm_contact | Contacto | id | %d |
| crm_opportunity | Oportunidad | id | %d |

Clientes reales (verdad subyacente): **%d**. Total defectos plantados: **%d** (ver `planted-defects.md`).
""" % (SEED, len(but000), len(but0bk), len(bkk_acct), len(bkkit), len(vdarl), len(tcurx),
       len(crm_account), len(crm_contact), len(crm_opportunity), N_REAL, len(PLANTED)))


w(os.path.join(AK_DIR, "ground-truth-entity-resolution.md"), """# Ground Truth - Entity Resolution (crosswalk SAP <-> CRM)

> EL ARTEFACTO ESTRELLA de este seed. Como genere ambos sistemas desde un set de
> clientes reales, conozco el match verdadero. Un pipeline de migracion/MDM debe
> reconstruir este crosswalk; aqui se mide su precision/recall.

## Resumen por tipo de match
| match_type | # | Significado | Dificultad |
|------------|---|-------------|-----------|
| exact_ref | %d | crm_account.sap_partner_ref poblado y correcto | trivial (join directo) |
| fuzzy_name | %d | ref nulo; match por nombre normalizado + pais | media (normalizacion + fuzzy) |
| duplicate | %d | 2a cuenta CRM del mismo cliente real | alta (MDM: merge a golden record) |
| crm_only | %d | cuenta CRM sin contraparte SAP (prospecto) | identificar como no-cliente |
| sap_only | %d | Business Partner SAP sin cuenta CRM | dim_customer sin enriquecimiento CRM |

## Regla de resolucion (la que el pipeline debe implementar)
1. Si `crm_account.sap_partner_ref` != null y existe en BUT000 -> match exacto.
2. Si no: normalizar nombre (sin acentos, mayusculas, sin puntuacion, colapsar espacios)
   y pais (ISO-2 via country_map); match por (name_key, country) contra BUT000.
3. Multiples cuentas CRM que resuelven al mismo PARTNER -> merge (1 golden record).
4. CRM sin match -> prospecto (no entra a dim_customer como cliente bancario).

## Crosswalk completo (muestra de las primeras 25 filas; el resto en este archivo)
| crm_id | match_type | sap_partner | match_key | crm_name | sap_name |
|--------|-----------|-------------|-----------|----------|----------|
%s

> Total filas crosswalk: %d (incluye sap_only sin crm_id).
""" % (er_counts.get("exact_ref", 0), er_counts.get("fuzzy_name", 0),
       er_counts.get("duplicate", 0), er_counts.get("crm_only", 0), er_counts.get("sap_only", 0),
       block(["| %s | %s | %s | %s | %s | %s |" % (
           c["crm_id"] or "-", c["match_type"], c["sap_partner"] or "-",
           c["match_key"][:28], c["crm_name"][:28] or "-", c["sap_name"][:28] or "-")
           for c in crosswalk[:25]]),
       len(crosswalk)))


w(os.path.join(AK_DIR, "ground-truth-transformation-rules.md"), """# Ground Truth - Transformation Rules

| ID | Regla | Sistema/columnas | Logica |
|----|-------|------------------|--------|
| REGLA-01 | DATS_to_DATE | SAP CRDAT/OPEN_DATE/POST_DATE/START_DATE | 'YYYYMMDD'->DATE; '00000000'->NULL |
| REGLA-02 | ALPHA_strip | SAP PARTNER/ACCT | quitar ceros a la izquierda para clave de negocio; aplicar ANTES del join (resuelve leading_zero) |
| REGLA-03 | CURR_to_NUMERIC | SAP AMOUNT/PRINCIPAL + WAERS + TCURX | amount = AMOUNT / POW(10, TCURX.CURRDEC[WAERS]); NUNCA asumir 2 decimales |
| REGLA-04 | filter_deleted | SAP BUT000.XDELE / BKK_ACCT.LOEVM | excluir flag='X' en silver |
| REGLA-05 | dedup_key | SAP BKKIT (ACCT,ITEM_NO) | dedup keep-first |
| REGLA-06 | fk_validate_quarantine | BKKIT.ACCT, BKK_ACCT.PARTNER, VDARL.PARTNER | FK falla -> _quarantine |
| REGLA-07 | crm_country_map | CRM crm_account.country | 'Mexico'/'Mexico'/'MEX'->'MX'; 'USA'/'Estados Unidos'->'US'; etc. (ISO-2) |
| REGLA-08 | crm_email_validate | CRM crm_account.email | DQ validity: contiene '@' y dominio; malformado -> flag |
| REGLA-09 | entity_resolution | SAP BUT000 <-> CRM crm_account | ref exacto OR (norm_name + country); ver ground-truth-entity-resolution.md |
| REGLA-10 | master_merge | gold dim_customer | merge de cuentas CRM duplicadas a 1 golden record por PARTNER |
""")


dq_orphan_txn = sum(1 for (t, w_) in st_quar if w_ == "orphan_acct")
dq_null_txn = sum(1 for (t, w_) in st_quar if w_ == "null_amount")
dq_orphan_loan = len(sl_quar)
dq_null_acct = len(null_partner_accts)
dq_baddate = len([d for d in PLANTED if d["type"] == "invalid_date"])
dq_deleted = len([d for d in PLANTED if d["type"] == "deletion_flag"])
dq_email = len([d for d in PLANTED if d["type"] == "malformed_email"])
dq_country = len([d for d in PLANTED if d["type"] == "country_inconsistent"])

w(os.path.join(AK_DIR, "ground-truth-dq-rules.md"), """# Ground Truth - DQ Rules (conteos esperados)

| DQ test | Dimension | Sistema/Tabla | Filas que FALLAN | Accion |
|---------|-----------|---------------|------------------|--------|
| referential: BKKIT.ACCT in BKK_ACCT | integridad | SAP/BKKIT | %d | cuarentena |
| completeness: BKKIT.AMOUNT not null | completeness | SAP/BKKIT | %d | cuarentena |
| uniqueness: (ACCT,ITEM_NO) | unicidad | SAP/BKKIT | %d (dedup) | dedup |
| completeness: BKK_ACCT.PARTNER not null | completeness | SAP/BKK_ACCT | %d | cuarentena |
| referential: VDARL.PARTNER in BUT000 | integridad | SAP/VDARL | %d | cuarentena |
| validity: DATS fecha valida | validez | SAP (varias) | %d | DATS->NULL |
| validity: deletion flag | validez | SAP BUT000/BKK_ACCT | %d | filtrar |
| validity: email CRM | validez | CRM/crm_account | %d | flag/estandarizar |
| consistency: pais ISO-2 | consistencia | CRM/crm_account | %d | normalizar (country_map) |
""" % (dq_orphan_txn, dq_null_txn, dups_removed, dq_null_acct, dq_orphan_loan,
       dq_baddate, dq_deleted, dq_email, dq_country))


recon = [
    ("bronze", "sap_but000", len(but000)), ("bronze", "sap_bkk_acct", len(bkk_acct)),
    ("bronze", "sap_bkkit", len(bkkit)), ("bronze", "sap_vdarl", len(vdarl)),
    ("bronze", "crm_account", len(crm_account)), ("bronze", "crm_opportunity", len(crm_opportunity)),
    ("silver", "party", len(sp)), ("silver", "account (limpio)", len(sa)),
    ("silver", "  account cuarentena", len(sa_quar)),
    ("silver", "transaction (limpio)", len(st)),
    ("silver", "  transaction cuarentena", len(st_quar)),
    ("silver", "  transaction dup removidos", dups_removed),
    ("silver", "loan (limpio)", len(sl)), ("silver", "  loan cuarentena", len(sl_quar)),
    ("silver", "crm_account", len(crm_account)),
    ("gold", "dim_customer", len(dim_customer)),
    ("gold", "  dim_customer con match CRM", sum(1 for d in dim_customer if d["matched"])),
    ("gold", "fact_transaction", len(gold_txn)),
]
recon_lines = block(["| %s | %s | %d |" % r for r in recon])
sum_lines = block(["| %s | %d | %.2f | %.2f | %s |" % (
    c, CURRENCY_DEC[c], sum_real.get(c, 0.0), sum_naive.get(c, 0.0),
    "OK" if CURRENCY_DEC[c] == 2 else "TRAP x%d" % (10 ** (2 - CURRENCY_DEC[c])))
    for c in sorted(set(list(sum_real) + list(sum_naive)))])

w(os.path.join(AK_DIR, "ground-truth-reconciliation.md"), """# Ground Truth - Reconciliation (por capa)

> Conteos y sumas computados de los datos emitidos. seed=%d.

## Conteo de filas por capa
| Capa | Tabla | # filas |
|------|-------|---------|
%s

**Derivacion clave:**
- silver.party = bronze.but000 - XDELE='X' (%d - %d = %d)
- silver.account limpio = bronze.bkk_acct - LOEVM='X' - PARTNER nulo/huerfano (%d - %d = %d)
- silver.transaction limpio = bronze.bkkit - dup - cuarentena FK/nulos (%d - %d - %d = %d)
- gold.dim_customer = silver.party (1 golden record por PARTNER; cuentas CRM duplicadas mergeadas)

## Reconciliacion de montos en GOLD (fact_transaction, aplicando TCURX)
| Moneda | TCURX dec | SUM real | SUM naive (/100) | Estado |
|--------|-----------|----------|-------------------|--------|
%s

`[BENCHMARK]` Doble revelador de este seed:
1. **Decimales por moneda** (JPY/CLP): naive /100 corrompe x100 (solo visible aqui).
2. **Entity resolution**: dim_customer correcto requiere resolver el crosswalk SAP<->CRM
   (ref exacto + fuzzy + merge de duplicados). Ver ground-truth-entity-resolution.md.
""" % (SEED, recon_lines,
       len(but000), len(del_partners), len(sp),
       len(bkk_acct), len(sa_quar), len(sa),
       len(bkkit), dups_removed, len(st_quar), len(st),
       sum_lines))


w(os.path.join(AK_DIR, "ground-truth-medallion-schema.md"), """# Ground Truth - Medallion Schema (banking + CRM)

> Resumen por capa. DDL ejecutable BigQuery en `../target-ddl/`.

## Bronze (bank_bronze) - raw 1:1, todo STRING
SAP: sap_but000 · sap_but0bk · sap_bkk_acct · sap_bkkit · sap_vdarl · sap_tcurx
CRM: crm_account · crm_contact · crm_opportunity
+ metadata `_ingest_ts`, `_source_system`. Conteo = fuente.

## Silver (bank_silver) - conformado, tipado, FK validadas
party · account · transaction · loan · crm_account · crm_contact · crm_opportunity · _quarantine
Reglas: DATS->DATE, ALPHA_strip, CURR/TCURX, filter_deleted, dedup, FK_quarantine, crm_country_map, email_validate.

## Gold (bank_gold) - dimensional + Customer 360 mastereado
- dim_customer (SAP SoR + entity resolution con CRM; merge de duplicados; segment del CRM)
- dim_account · fact_transaction · fact_loan · fact_crm_opportunity · agg_customer_balance
Entity resolution: ver ground-truth-entity-resolution.md (crosswalk verdadero).
""")


by_type = {}
for d in PLANTED:
    by_type.setdefault(d["type"], []).append(d)
summary = block(["| %s | %d |" % (t, len(v)) for t, v in sorted(by_type.items())])
detail = block(["| %s | %s | %s | %s | %s | %s |" % (
    d["type"], d["system"], d["table"], d["key"], d["detail"], d["action"]) for d in PLANTED])

w(os.path.join(AK_DIR, "planted-defects.md"), """# Planted Defects (ubicacion exacta)

> seed=%d. NO se entrega en un test ciego.

## Resumen por tipo
| Tipo | # |
|------|---|
%s
| **TOTAL** | **%d** |

## Detalle
| Tipo | Sistema | Tabla | Clave | Detalle | Accion esperada |
|------|---------|-------|-------|---------|-----------------|
%s
""" % (SEED, summary, len(PLANTED), detail))


# escribir crosswalk completo como CSV adicional en answer-key (para scoring programatico)
write_csv(os.path.join(AK_DIR, "crosswalk-truth.csv"), crosswalk,
          ["crm_id", "real_id", "sap_partner", "match_type", "crm_name", "sap_name", "match_key"])


# ----------------------------------------------------------------------------
print("OK - generado seed-sap-banking-crm-to-bigquery-medallion (seed=%d)" % SEED)
print("  SAP: but000=%d bkk_acct=%d bkkit=%d vdarl=%d" % (len(but000), len(bkk_acct), len(bkkit), len(vdarl)))
print("  CRM: account=%d contact=%d opp=%d" % (len(crm_account), len(crm_contact), len(crm_opportunity)))
print("  silver: party=%d account=%d txn=%d loan=%d (quar acct=%d txn=%d dup=%d)" % (
    len(sp), len(sa), len(st), len(sl), len(sa_quar), len(st_quar), dups_removed))
print("  gold: dim_customer=%d (con match CRM=%d) fact_txn=%d" % (
    len(dim_customer), sum(1 for d in dim_customer if d["matched"]), len(gold_txn)))
print("  entity resolution:", er_counts)
print("  defectos plantados=%d" % len(PLANTED))
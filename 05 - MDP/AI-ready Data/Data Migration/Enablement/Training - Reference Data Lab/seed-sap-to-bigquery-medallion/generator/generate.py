#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generate.py - Reference Data Lab (AI-ready Data / Digital Core)
seed: seed-sap-to-bigquery-medallion

Genera un data estate SAP SD + master data de referencia (CSV), el DDL medallion
target para BigQuery, y un answer key (lineage + reglas + DQ + reconciliacion)
COMPUTADO de los datos emitidos. Determinista por SEED. Solo stdlib.

Ejecutar:  python generate.py
Salida:    ../source/sap/*.csv  ../target-ddl/*.sql  ../answer-key/*.md

Los parametros de abajo espejan generation-spec.yaml. Para una variante,
ajustar el bloque PARAMS y regenerar.
"""

import csv
import os
import random
from datetime import date, timedelta

# ----------------------------------------------------------------------------
# PARAMS (espejan generation-spec.yaml)
# ----------------------------------------------------------------------------
SEED = 42
MANDT = "100"
N_CUSTOMERS = 200
N_MATERIALS = 150
N_ORDERS = 1000
ITEMS_MIN, ITEMS_MAX = 1, 6

# moneda -> decimales (replica TCURX). JPY/CLP = 0 decimales (las trampas)
CURRENCY_DEC = {"MXN": 2, "USD": 2, "EUR": 2, "JPY": 0, "CLP": 0}
CURRENCY_WEIGHTS = [("MXN", 60), ("USD", 22), ("EUR", 8), ("JPY", 6), ("CLP", 4)]
CANONICAL_LANG = "S"
LANGS = ["S", "E"]

DEFECT_DENSITY = 0.03  # referencia; los conteos exactos se fijan abajo

HERE = os.path.dirname(os.path.abspath(__file__))
SEED_DIR = os.path.dirname(HERE)
SRC_DIR = os.path.join(SEED_DIR, "source", "sap")
DDL_DIR = os.path.join(SEED_DIR, "target-ddl")
AK_DIR = os.path.join(SEED_DIR, "answer-key")

rng = random.Random(SEED)

# planted defects log: cada entrada (tipo, tabla, clave, detalle, accion_esperada)
PLANTED = []


def plant(dtype, table, key, detail, action):
    PLANTED.append({"type": dtype, "table": table, "key": key,
                    "detail": detail, "action": action})


# ----------------------------------------------------------------------------
# helpers
# ----------------------------------------------------------------------------
def alpha(n, width):
    """Conversion ALPHA SAP: numero -> string con ceros a la izquierda."""
    return str(n).zfill(width)


def dats(d):
    """date -> 'YYYYMMDD' (tipo DATS de SAP)."""
    return d.strftime("%Y%m%d")


BASE_DATE = date(2023, 1, 1)


def rand_date():
    return BASE_DATE + timedelta(days=rng.randint(0, 900))


NAMES_A = ["Comercial", "Distribuidora", "Grupo", "Industrias", "Servicios",
           "Corporativo", "Abarrotes", "Importadora", "Mayoreo", "Cadena"]
NAMES_B = ["del Norte", "Azteca", "Pacifico", "Latina", "Continental",
           "del Bajio", "Peninsular", "Regio", "Central", "del Golfo"]
COUNTRIES = [("MX", "Ciudad de Mexico", "01000"), ("MX", "Monterrey", "64000"),
             ("MX", "Guadalajara", "44100"), ("US", "Houston", "77001"),
             ("CL", "Santiago", "8320000"), ("ES", "Madrid", "28001")]
MTART = ["FERT", "HALB", "ROH", "HAWA"]   # tipos de material SAP
MATKL = ["BEBIDAS", "ABARROTE", "LIMPIEZA", "ELECTRO", "PAPELERIA"]
MEINS = ["EA", "KG", "L", "CS", "PAL"]
MAKTX_A = ["Refresco", "Jabon", "Galleta", "Detergente", "Cuaderno",
           "Aceite", "Cafe", "Agua", "Cable", "Foco"]
MAKTX_B = ["500ml", "1L", "Familiar", "Pack 12", "Premium", "Basico",
           "Industrial", "2kg", "Mini", "XL"]


# ----------------------------------------------------------------------------
# 1) MASTER DATA - KNA1 (clientes)
# ----------------------------------------------------------------------------
customers = []          # filas emitidas (dict)
valid_customer_ids = set()   # KUNNR (con ceros) que SI existen y no estan borrados

# clientes a marcar con defecto
del_customers = set(rng.sample(range(1, N_CUSTOMERS + 1), 15))      # LOEKZ='X'
baddate_customers = set(rng.sample(range(1, N_CUSTOMERS + 1), 6))   # ERDAT invalido

for i in range(1, N_CUSTOMERS + 1):
    kunnr = alpha(10000 + i, 10)
    country, city, pstlz = rng.choice(COUNTRIES)
    name = "%s %s %d" % (rng.choice(NAMES_A), rng.choice(NAMES_B), i)
    loekz = ""
    erdat = dats(rand_date())
    if i in del_customers:
        loekz = "X"
        plant("deletion_flag", "KNA1", "KUNNR=%s" % kunnr,
              "Cliente con flag de borrado LOEKZ='X'",
              "Filtrar en silver_customer; conservar en bronze")
    if i in baddate_customers:
        erdat = "00000000"
        plant("invalid_date", "KNA1", "KUNNR=%s" % kunnr,
              "ERDAT='00000000' (fecha SAP nula)",
              "DATS->DATE: mapear a NULL en silver")
    customers.append({"MANDT": MANDT, "KUNNR": kunnr, "NAME1": name,
                      "LAND1": country, "ORT01": city, "PSTLZ": pstlz,
                      "KTOKD": "0001", "LOEKZ": loekz, "ERDAT": erdat})
    if loekz != "X":
        valid_customer_ids.add(kunnr)

all_customer_ids = [c["KUNNR"] for c in customers]


# ----------------------------------------------------------------------------
# 2) MASTER DATA - MARA (materiales) + MAKT (textos)
# ----------------------------------------------------------------------------
materials = []
makt = []
valid_material_ids = set()    # MATNR (con ceros) existentes y no borrados

del_materials = set(rng.sample(range(1, N_MATERIALS + 1), 10))  # LVORM='X'

for i in range(1, N_MATERIALS + 1):
    matnr = alpha(10000 + i, 18)     # 18 chars (ALPHA)
    lvorm = ""
    if i in del_materials:
        lvorm = "X"
        plant("deletion_flag", "MARA", "MATNR=%s" % matnr,
              "Material con flag de borrado LVORM='X'",
              "Filtrar en silver_material; conservar en bronze")
    materials.append({"MANDT": MANDT, "MATNR": matnr,
                      "MTART": rng.choice(MTART), "MATKL": rng.choice(MATKL),
                      "MEINS": rng.choice(MEINS), "LVORM": lvorm,
                      "ERSDA": dats(rand_date())})
    if lvorm != "X":
        valid_material_ids.add(matnr)
    # textos: siempre S; ~70% tambien E
    base_txt = "%s %s" % (rng.choice(MAKTX_A), rng.choice(MAKTX_B))
    makt.append({"MANDT": MANDT, "MATNR": matnr, "SPRAS": "S", "MAKTX": base_txt})
    if rng.random() < 0.7:
        makt.append({"MANDT": MANDT, "MATNR": matnr, "SPRAS": "E",
                     "MAKTX": base_txt + " (EN)"})

all_material_ids = [m["MATNR"] for m in materials]


# ----------------------------------------------------------------------------
# 3) CHECK TABLE - TCURX (decimales por moneda)
# ----------------------------------------------------------------------------
tcurx = [{"CURRKEY": k, "CURRDEC": str(v)} for k, v in CURRENCY_DEC.items()]


# ----------------------------------------------------------------------------
# 4) TRANSACCIONAL - VBAK (headers) + VBAP (items)
# ----------------------------------------------------------------------------
def pick_currency():
    r = rng.randint(1, sum(w for _, w in CURRENCY_WEIGHTS))
    acc = 0
    for cur, w in CURRENCY_WEIGHTS:
        acc += w
        if r <= acc:
            return cur
    return "MXN"


# precomputar ordenes a las que les plantaremos defectos de header
order_ids = [alpha(4500000000 + i, 10) for i in range(1, N_ORDERS + 1)]
null_kunnr_orders = set(rng.sample(range(N_ORDERS), 6))     # KUNNR nulo
orphan_kunnr_orders = set(rng.sample(range(N_ORDERS), 8))   # KUNNR inexistente
baddate_orders = set(rng.sample(range(N_ORDERS), 8))        # ERDAT invalido

vbak = []
# mapa order_id -> (currency, dec) para coherencia con items
order_currency = {}
header_items_amount = {}   # order_id -> suma minor units de sus items limpios

for idx, vbeln in enumerate(order_ids):
    cur = pick_currency()
    order_currency[vbeln] = cur
    if cur in ("JPY", "CLP"):
        plant("currency_decimal_trap", "VBAK", "VBELN=%s" % vbeln,
              "Moneda %s con %d decimales (TCURX); montos en minor units" % (cur, CURRENCY_DEC[cur]),
              "Convertir NETWR/10^TCURX(%s); un pipeline naive /100 corrompe x100" % cur)
    # cliente
    if idx in null_kunnr_orders:
        kunnr = ""
        plant("null_mandatory", "VBAK", "VBELN=%s" % vbeln,
              "KUNNR vacio (obligatorio)",
              "DQ completeness; cuarentena (no entra a silver_header limpio)")
    elif idx in orphan_kunnr_orders:
        kunnr = alpha(9990000 + idx, 10)   # no existe en KNA1
        plant("referential_orphan", "VBAK", "VBELN=%s KUNNR=%s" % (vbeln, kunnr),
              "KUNNR no existe en KNA1",
              "FK customer falla; cuarentena")
    else:
        kunnr = rng.choice(all_customer_ids)
    erdat = "00000000" if idx in baddate_orders else dats(rand_date())
    if idx in baddate_orders:
        plant("invalid_date", "VBAK", "VBELN=%s" % vbeln,
              "ERDAT='00000000'",
              "DATS->DATE: mapear a NULL")
    vbak.append({"MANDT": MANDT, "VBELN": vbeln, "ERDAT": erdat,
                 "KUNNR": kunnr, "NETWR": None, "WAERK": cur,
                 "VKORG": "1000", "AUART": "TA", "VBTYP": "C"})
    header_items_amount[vbeln] = 0

vbak_by_id = {h["VBELN"]: h for h in vbak}

# items
vbap = []
# defectos de item: indices se eligen sobre el stream de items generados limpios
# generamos primero limpios, luego inyectamos
clean_items = []   # (vbeln, posnr, matnr, qty, minor, cur)
for vbeln in order_ids:
    cur = order_currency[vbeln]
    n_items = rng.randint(ITEMS_MIN, ITEMS_MAX)
    for pos in range(1, n_items + 1):
        posnr = alpha(pos * 10, 6)
        matnr = rng.choice(all_material_ids)
        qty = rng.randint(1, 20)
        unit_minor = rng.randint(1000, 500000)   # minor units
        minor = qty * unit_minor
        clean_items.append([vbeln, posnr, matnr, qty, minor, cur])

# --- inyeccion de defectos de item sobre clean_items ---
total_items = len(clean_items)

# leading-zero inconsistency: MATNR sin ceros a la izquierda (resoluble tras ALPHA)
lz_idx = set(rng.sample(range(total_items), 20))
# amount outlier
outlier_idx = set(rng.sample(range(total_items), 4))
# null NETWR
nullamt_idx = set(rng.sample(range(total_items), 6))
# material huerfano (MATNR inexistente)
orphan_mat_idx = set(rng.sample(range(total_items), 10))

# evitar solapamientos confusos: prioridad orphan_mat > nullamt > outlier > lz
for i, it in enumerate(clean_items):
    vbeln, posnr, matnr, qty, minor, cur = it
    if i in orphan_mat_idx:
        matnr = alpha(8880000 + i, 18)   # no existe en MARA
        plant("referential_orphan", "VBAP", "VBELN=%s POSNR=%s MATNR=%s" % (vbeln, posnr, matnr),
              "MATNR no existe en MARA",
              "FK material falla; cuarentena")
    elif i in lz_idx:
        matnr = matnr.lstrip("0")        # mismo material, sin ceros: trap de conformidad
        plant("leading_zero_inconsistency", "VBAP", "VBELN=%s POSNR=%s" % (vbeln, posnr),
              "MATNR sin ceros a la izquierda ('%s')" % matnr,
              "Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion)")
    it[2] = matnr

    if i in nullamt_idx:
        it[4] = None
        plant("null_mandatory", "VBAP", "VBELN=%s POSNR=%s" % (vbeln, posnr),
              "NETWR vacio (obligatorio)",
              "DQ completeness; cuarentena")
    elif i in outlier_idx:
        it[4] = 999999999999   # outlier
        plant("amount_outlier", "VBAP", "VBELN=%s POSNR=%s" % (vbeln, posnr),
              "NETWR con magnitud absurda (range check)",
              "DQ validity/range: alertar; no rompe el pipeline")

# construir filas VBAP limpias + acumular header amount para items validos
for it in clean_items:
    vbeln, posnr, matnr, qty, minor, cur = it
    netwr = "" if minor is None else str(minor)
    vbap.append({"MANDT": MANDT, "VBELN": vbeln, "POSNR": posnr,
                 "MATNR": matnr, "KWMENG": str(qty), "MEINS": "EA",
                 "NETWR": netwr, "WAERK": cur})
    if minor is not None and minor != 999999999999:
        header_items_amount[vbeln] = header_items_amount.get(vbeln, 0) + minor

# duplicados de clave (VBELN,POSNR) en VBAP
dup_sources = rng.sample([r for r in vbap if r["NETWR"] not in ("",)], 5)
for r in dup_sources:
    dup = dict(r)
    dup["KWMENG"] = str(int(r["KWMENG"]) + 1)   # valor distinto, misma clave
    vbap.append(dup)
    plant("duplicate_key", "VBAP", "VBELN=%s POSNR=%s" % (r["VBELN"], r["POSNR"]),
          "Clave (MANDT,VBELN,POSNR) duplicada con valor distinto",
          "Dedup determinista por clave + regla de supervivencia (first/max)")

# items huerfanos: VBELN inexistente en VBAK
for j in range(12):
    fake_vbeln = alpha(7770000000 + j, 10)
    posnr = alpha(10, 6)
    matnr = rng.choice(all_material_ids)
    cur = "MXN"
    minor = rng.randint(1000, 500000)
    vbap.append({"MANDT": MANDT, "VBELN": fake_vbeln, "POSNR": posnr,
                 "MATNR": matnr, "KWMENG": "1", "MEINS": "EA",
                 "NETWR": str(minor), "WAERK": cur})
    plant("referential_orphan", "VBAP", "VBELN=%s POSNR=%s" % (fake_vbeln, posnr),
          "VBELN no existe en VBAK (item huerfano)",
          "FK order falla; cuarentena")

# fijar NETWR de header = suma de items limpios (coherencia), salvo headers en cuarentena
for h in vbak:
    h["NETWR"] = str(header_items_amount.get(h["VBELN"], 0))


# ----------------------------------------------------------------------------
# WRITE CSV
# ----------------------------------------------------------------------------
def write_csv(path, rows, cols):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols)
        w.writeheader()
        for r in rows:
            w.writerow({c: r.get(c, "") for c in r if c in cols} if False else {c: r.get(c, "") for c in cols})


write_csv(os.path.join(SRC_DIR, "kna1.csv"), customers,
          ["MANDT", "KUNNR", "NAME1", "LAND1", "ORT01", "PSTLZ", "KTOKD", "LOEKZ", "ERDAT"])
write_csv(os.path.join(SRC_DIR, "mara.csv"), materials,
          ["MANDT", "MATNR", "MTART", "MATKL", "MEINS", "LVORM", "ERSDA"])
write_csv(os.path.join(SRC_DIR, "makt.csv"), makt,
          ["MANDT", "MATNR", "SPRAS", "MAKTX"])
write_csv(os.path.join(SRC_DIR, "tcurx.csv"), tcurx, ["CURRKEY", "CURRDEC"])
write_csv(os.path.join(SRC_DIR, "vbak.csv"), vbak,
          ["MANDT", "VBELN", "ERDAT", "KUNNR", "NETWR", "WAERK", "VKORG", "AUART", "VBTYP"])
write_csv(os.path.join(SRC_DIR, "vbap.csv"), vbap,
          ["MANDT", "VBELN", "POSNR", "MATNR", "KWMENG", "NETWR", "WAERK", "MEINS"])


# ----------------------------------------------------------------------------
# COMPUTE SILVER / GOLD (la verdad: se computa de los datos emitidos)
# ----------------------------------------------------------------------------
# silver_customer
sc = [c for c in customers if c["LOEKZ"] != "X"]
# silver_material
sm = [m for m in materials if m["LVORM"] != "X"]
sm_ids = set(m["MATNR"] for m in sm)
# silver_makt canonico
makt_canon = {m["MATNR"]: m["MAKTX"] for m in makt if m["SPRAS"] == CANONICAL_LANG}

# silver_header: KUNNR no nulo y resuelve en KNA1 (cualquier cliente, incluso borrado existe en bronze;
#                FK valida contra KNA1 completo -> usamos all_customer_ids)
all_cust_set = set(all_customer_ids)
sh, sh_quar = [], []
for h in vbak:
    if h["KUNNR"] == "" or h["KUNNR"] not in all_cust_set:
        sh_quar.append(h)
    else:
        sh.append(h)
sh_ids = set(h["VBELN"] for h in sh)

# silver_item: dedup (VBELN,POSNR) keep-first; FK order (VBAK existe); FK material (MARA existe, tras ALPHA);
#              NETWR no nulo. outlier se conserva (solo alerta).
vbak_ids = set(h["VBELN"] for h in vbak)
mara_ids_alpha = set(all_material_ids)   # con ceros


def alpha_norm(matnr):
    # normaliza ALPHA: re-pad a 18 si es numerico sin ceros
    s = matnr.strip()
    if s.isdigit():
        return s.zfill(18)
    return s


seen = set()
si, si_quar = [], []
dups_removed = 0
for r in vbap:
    key = (r["VBELN"], r["POSNR"])
    if key in seen:
        dups_removed += 1
        continue
    seen.add(key)
    reason = None
    if r["VBELN"] not in vbak_ids:
        reason = "orphan_order"
    elif r["NETWR"] == "":
        reason = "null_amount"
    else:
        mnorm = alpha_norm(r["MATNR"])
        if mnorm not in mara_ids_alpha:
            reason = "orphan_material"
    if reason:
        si_quar.append((r, reason))
    else:
        si.append(r)

# gold fact: silver_item cuyo order esta en silver_header limpio y material no borrado
gold_fact = []
for r in si:
    if r["VBELN"] in sh_ids and alpha_norm(r["MATNR"]) in sm_ids:
        gold_fact.append(r)

# sumas por moneda en gold (aplicando TCURX) - valor real
gold_sum_real = {}
gold_sum_naive = {}   # lo que produciria un pipeline naive (/100 siempre)
for r in gold_fact:
    cur = r["WAERK"]
    dec = CURRENCY_DEC.get(cur, 2)
    minor = int(r["NETWR"])
    gold_sum_real[cur] = gold_sum_real.get(cur, 0.0) + minor / (10 ** dec)
    gold_sum_naive[cur] = gold_sum_naive.get(cur, 0.0) + minor / 100.0


# ----------------------------------------------------------------------------
# WRITE TARGET DDL (BigQuery)
# ----------------------------------------------------------------------------
def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


w(os.path.join(DDL_DIR, "01_bronze.sql"), """-- BigQuery DDL - capa BRONZE (raw 1:1, todo STRING, + metadata tecnica)
-- dataset: sap_bronze
CREATE SCHEMA IF NOT EXISTS sap_bronze;

CREATE OR REPLACE TABLE sap_bronze.kna1 (
  MANDT STRING, KUNNR STRING, NAME1 STRING, LAND1 STRING, ORT01 STRING,
  PSTLZ STRING, KTOKD STRING, LOEKZ STRING, ERDAT STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);

CREATE OR REPLACE TABLE sap_bronze.mara (
  MANDT STRING, MATNR STRING, MTART STRING, MATKL STRING, MEINS STRING,
  LVORM STRING, ERSDA STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);

CREATE OR REPLACE TABLE sap_bronze.makt (
  MANDT STRING, MATNR STRING, SPRAS STRING, MAKTX STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);

CREATE OR REPLACE TABLE sap_bronze.tcurx (
  CURRKEY STRING, CURRDEC STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);

CREATE OR REPLACE TABLE sap_bronze.vbak (
  MANDT STRING, VBELN STRING, ERDAT STRING, KUNNR STRING, NETWR STRING,
  WAERK STRING, VKORG STRING, AUART STRING, VBTYP STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);

CREATE OR REPLACE TABLE sap_bronze.vbap (
  MANDT STRING, VBELN STRING, POSNR STRING, MATNR STRING, KWMENG STRING,
  NETWR STRING, WAERK STRING, MEINS STRING,
  _ingest_ts TIMESTAMP, _source_system STRING, _batch_id STRING);
""")

w(os.path.join(DDL_DIR, "02_silver.sql"), """-- BigQuery DDL - capa SILVER (conformado, tipado, deduplicado, FK validadas)
-- dataset: sap_silver  | reglas: ver answer-key/ground-truth-transformation-rules.md
CREATE SCHEMA IF NOT EXISTS sap_silver;

CREATE OR REPLACE TABLE sap_silver.customer (
  customer_id STRING NOT NULL,        -- KUNNR tras ALPHA strip
  name STRING, country STRING, city STRING, postal_code STRING,
  account_group STRING,
  created_date DATE,                  -- DATS->DATE ('00000000'->NULL)
  _src_loekz STRING)                  -- trazabilidad; filtrado LOEKZ='X'
PARTITION BY created_date;

CREATE OR REPLACE TABLE sap_silver.material (
  material_id STRING NOT NULL,        -- MATNR tras ALPHA strip
  material_type STRING, material_group STRING, base_uom STRING,
  description STRING,                 -- MAKT idioma canonico 'S'
  created_date DATE);

CREATE OR REPLACE TABLE sap_silver.sales_order_header (
  order_id STRING NOT NULL,           -- VBELN
  order_date DATE,                    -- ERDAT DATS->DATE
  customer_id STRING NOT NULL,        -- FK validada vs customer
  net_amount NUMERIC,                 -- NETWR / 10^TCURX(currency)
  currency STRING, sales_org STRING, order_type STRING)
PARTITION BY order_date
CLUSTER BY customer_id;

CREATE OR REPLACE TABLE sap_silver.sales_order_item (
  order_id STRING NOT NULL,           -- VBELN
  item_no STRING NOT NULL,            -- POSNR
  material_id STRING,                 -- MATNR ALPHA strip, FK vs material
  quantity NUMERIC, uom STRING,
  net_amount NUMERIC,                 -- NETWR / 10^TCURX(currency)
  currency STRING)
CLUSTER BY order_id;

-- tabla de cuarentena para filas que fallan DQ (FK, nulos)
CREATE OR REPLACE TABLE sap_silver._quarantine (
  source_table STRING, business_key STRING, reason STRING, raw JSON,
  _quarantined_ts TIMESTAMP);
""")

w(os.path.join(DDL_DIR, "03_gold.sql"), """-- BigQuery DDL - capa GOLD (modelo dimensional + agregados)
-- dataset: sap_gold
CREATE SCHEMA IF NOT EXISTS sap_gold;

CREATE OR REPLACE TABLE sap_gold.dim_customer (
  customer_sk INT64, customer_id STRING, name STRING, country STRING, city STRING);

CREATE OR REPLACE TABLE sap_gold.dim_material (
  material_sk INT64, material_id STRING, description STRING,
  material_type STRING, material_group STRING);

CREATE OR REPLACE TABLE sap_gold.fact_sales_order_item (
  order_id STRING, item_no STRING,
  customer_sk INT64, material_sk INT64,
  order_date DATE, quantity NUMERIC, net_amount NUMERIC, currency STRING)
PARTITION BY order_date
CLUSTER BY customer_sk;

CREATE OR REPLACE TABLE sap_gold.agg_sales_by_customer_month (
  customer_id STRING, year_month STRING, currency STRING,
  order_count INT64, total_net_amount NUMERIC);
""")


# ----------------------------------------------------------------------------
# WRITE ANSWER KEY
# ----------------------------------------------------------------------------
def defects_of(t):
    return [d for d in PLANTED if d["type"] == t]


n_makt_e = sum(1 for m in makt if m["SPRAS"] == "E")

w(os.path.join(AK_DIR, "ground-truth-source-inventory.md"), """# Ground Truth - Source Inventory

> Computado de los datos emitidos. seed=%d. NO editar a mano.

| Tabla SAP | Descripcion | Clave primaria | # filas | Notas |
|-----------|-------------|----------------|---------|-------|
| KNA1 | Customer master | MANDT+KUNNR | %d | %d con LOEKZ='X' |
| MARA | Material master | MANDT+MATNR | %d | %d con LVORM='X' |
| MAKT | Material text (multi-idioma) | MANDT+MATNR+SPRAS | %d | %d filas idioma 'E' |
| TCURX | Decimales por moneda | CURRKEY | %d | check table |
| VBAK | Sales order header | MANDT+VBELN | %d | total headers |
| VBAP | Sales order item | MANDT+VBELN+POSNR | %d | incluye duplicados y huerfanos plantados |

Total defectos plantados: **%d** (ver `planted-defects.md`).
""" % (SEED, len(customers), len(del_customers), len(materials), len(del_materials),
       len(makt), n_makt_e, len(tcurx), len(vbak), len(vbap), len(PLANTED)))


w(os.path.join(AK_DIR, "ground-truth-data-lineage.md"), """# Ground Truth - Data Lineage (columna a columna)

> source SAP -> bronze (1:1) -> silver (conformado) -> gold (dimensional)

## Customer
| SAP (KNA1) | Bronze | Silver (customer) | Gold (dim_customer) |
|---|---|---|---|
| KUNNR | kna1.KUNNR (STRING) | customer_id = ALPHA_strip(KUNNR) | dim_customer.customer_id |
| NAME1 | kna1.NAME1 | name | name |
| LAND1 | kna1.LAND1 | country | country |
| ORT01 | kna1.ORT01 | city | city |
| PSTLZ | kna1.PSTLZ | postal_code | - |
| ERDAT | kna1.ERDAT (STRING) | created_date = DATS_to_DATE(ERDAT) | - |
| LOEKZ | kna1.LOEKZ | (filtro: LOEKZ='X' excluido) | - |

## Material
| SAP (MARA/MAKT) | Bronze | Silver (material) | Gold (dim_material) |
|---|---|---|---|
| MARA.MATNR | mara.MATNR | material_id = ALPHA_strip(MATNR) | dim_material.material_id |
| MARA.MTART | mara.MTART | material_type | material_type |
| MARA.MATKL | mara.MATKL | material_group | material_group |
| MARA.MEINS | mara.MEINS | base_uom | - |
| MAKT.MAKTX (SPRAS='S') | makt.MAKTX | description (idioma canonico S) | description |
| MARA.LVORM | mara.LVORM | (filtro: LVORM='X' excluido) | - |

## Sales Order Header
| SAP (VBAK) | Bronze | Silver (sales_order_header) | Gold |
|---|---|---|---|
| VBELN | vbak.VBELN | order_id | fact.order_id |
| ERDAT | vbak.ERDAT | order_date = DATS_to_DATE | fact.order_date |
| KUNNR | vbak.KUNNR | customer_id (FK validada) | -> dim_customer.customer_sk |
| NETWR | vbak.NETWR | net_amount = NETWR/10^TCURX(WAERK) | - |
| WAERK | vbak.WAERK | currency | fact.currency |

## Sales Order Item
| SAP (VBAP) | Bronze | Silver (sales_order_item) | Gold (fact_sales_order_item) |
|---|---|---|---|
| VBELN+POSNR | vbap.* | order_id+item_no (dedup) | fact grain |
| MATNR | vbap.MATNR | material_id = ALPHA_strip(MATNR), FK | -> dim_material.material_sk |
| KWMENG | vbap.KWMENG | quantity | quantity |
| NETWR | vbap.NETWR | net_amount = NETWR/10^TCURX(WAERK) | net_amount |
| WAERK | vbap.WAERK | currency | currency |
""")


w(os.path.join(AK_DIR, "ground-truth-transformation-rules.md"), """# Ground Truth - Transformation Rules

> Cada regla [REGLA] aplica entre bronze y silver salvo nota. El pipeline correcto
> debe implementarlas todas; el answer key mide el resultado.

| ID | Regla | Columnas | Logica |
|----|-------|----------|--------|
| REGLA-01 | DATS_to_DATE | KNA1.ERDAT, VBAK.ERDAT | 'YYYYMMDD'->DATE; '00000000' (y fuera de rango) -> NULL |
| REGLA-02 | ALPHA_strip | KUNNR, MATNR | quitar ceros a la izquierda para la clave de negocio; aplicar ANTES de cualquier join (resuelve leading_zero_inconsistency) |
| REGLA-03 | CURR_to_NUMERIC | NETWR + WAERK + TCURX | net_amount = CAST(NETWR AS NUMERIC) / POW(10, TCURX.CURRDEC[WAERK]); NUNCA asumir 2 decimales fijos |
| REGLA-04 | filter_deleted | KNA1.LOEKZ, MARA.LVORM | excluir filas con flag='X' en silver; conservarlas en bronze |
| REGLA-05 | dedup_key | VBAP (VBELN,POSNR) | deduplicar por clave; regla de supervivencia: keep-first determinista |
| REGLA-06 | canonical_language | MAKT.SPRAS | description = MAKT donde SPRAS='%s'; ignorar otros idiomas (no duplicar material) |
| REGLA-07 | fk_validate_quarantine | VBAK.KUNNR, VBAP.VBELN, VBAP.MATNR | validar FK; filas que fallan van a _quarantine, no a la tabla limpia |
| REGLA-08 | completeness | VBAK.KUNNR, VBAP.NETWR | nulo en obligatorio -> cuarentena |
| REGLA-09 | range_check | VBAP.NETWR | outlier (magnitud absurda) -> alertar (DQ), NO eliminar |
""" % CANONICAL_LANG)


# DQ esperado (conteos derivados de los datos)
dq_orphan_hdr = sum(1 for h in vbak if h["KUNNR"] != "" and h["KUNNR"] not in all_cust_set)
dq_null_hdr = sum(1 for h in vbak if h["KUNNR"] == "")
dq_orphan_item_order = sum(1 for (r, why) in si_quar if why == "orphan_order")
dq_orphan_item_mat = sum(1 for (r, why) in si_quar if why == "orphan_material")
dq_null_item = sum(1 for (r, why) in si_quar if why == "null_amount")
dq_baddate = len(defects_of("invalid_date"))
dq_deleted = len(defects_of("deletion_flag"))
dq_outlier = len(defects_of("amount_outlier"))

w(os.path.join(AK_DIR, "ground-truth-dq-rules.md"), """# Ground Truth - DQ Rules (conteos esperados)

> Conteos computados de los datos emitidos. Un pipeline correcto debe reproducirlos.

| DQ test | Dimension | Tabla | Filas que FALLAN (esperado) | Accion |
|---------|-----------|-------|------------------------------|--------|
| referential: VBAK.KUNNR in KNA1 | integridad | VBAK | %d | cuarentena |
| completeness: VBAK.KUNNR not null | completeness | VBAK | %d | cuarentena |
| referential: VBAP.VBELN in VBAK | integridad | VBAP | %d | cuarentena |
| referential: VBAP.MATNR in MARA | integridad | VBAP | %d | cuarentena |
| completeness: VBAP.NETWR not null | completeness | VBAP | %d | cuarentena |
| uniqueness: (VBELN,POSNR) | unicidad | VBAP | %d (duplicados removidos) | dedup |
| validity: ERDAT fecha valida | validez | KNA1+VBAK | %d | DATS->NULL |
| validity: deletion flag | validez | KNA1+MARA | %d | filtrar |
| validity: NETWR range | validez | VBAP | %d | alertar (no eliminar) |
""" % (dq_orphan_hdr, dq_null_hdr, dq_orphan_item_order, dq_orphan_item_mat,
       dq_null_item, dups_removed, dq_baddate, dq_deleted, dq_outlier))


# reconciliacion
recon = []
recon.append(("bronze", "kna1", len(customers)))
recon.append(("bronze", "mara", len(materials)))
recon.append(("bronze", "makt", len(makt)))
recon.append(("bronze", "vbak", len(vbak)))
recon.append(("bronze", "vbap", len(vbap)))
recon.append(("silver", "customer", len(sc)))
recon.append(("silver", "material", len(sm)))
recon.append(("silver", "sales_order_header (limpio)", len(sh)))
recon.append(("silver", "  header en cuarentena", len(sh_quar)))
recon.append(("silver", "sales_order_item (limpio)", len(si)))
recon.append(("silver", "  item en cuarentena", len(si_quar)))
recon.append(("silver", "  item duplicados removidos", dups_removed))
recon.append(("gold", "fact_sales_order_item", len(gold_fact)))

recon_lines = "\n".join("| %s | %s | %d |" % (lyr, tbl, n) for lyr, tbl, n in recon)

sum_lines = "\n".join(
    "| %s | %d | %.2f | %.2f | %s |" % (
        cur, CURRENCY_DEC[cur], gold_sum_real.get(cur, 0.0), gold_sum_naive.get(cur, 0.0),
        "OK" if CURRENCY_DEC[cur] == 2 else "TRAP x%d" % (10 ** (2 - CURRENCY_DEC[cur])))
    for cur in sorted(set(list(gold_sum_real.keys()) + list(gold_sum_naive.keys()))))

w(os.path.join(AK_DIR, "ground-truth-reconciliation.md"), """# Ground Truth - Reconciliation (por capa)

> Conteos y sumas computados de los datos emitidos. seed=%d.

## Conteo de filas por capa
| Capa | Tabla | # filas |
|------|-------|---------|
%s

**Derivacion silver:**
- customer = bronze.kna1 - LOEKZ='X' (%d - %d = %d)
- material = bronze.mara - LVORM='X' (%d - %d = %d)
- sales_order_header limpio = bronze.vbak - (KUNNR nulo + KUNNR huerfano) (%d - %d = %d)
- sales_order_item limpio = bronze.vbap - duplicados - cuarentena FK/nulos (%d - %d - %d = %d)

## Reconciliacion de montos en GOLD (aplicando TCURX)
> net_amount_real = SUM(NETWR)/10^TCURX(moneda). La columna "naive (/100)" es lo que
> produce un pipeline que asume 2 decimales para TODAS las monedas: corrompe JPY/CLP.

| Moneda | TCURX dec | SUM real | SUM naive (/100) | Estado |
|--------|-----------|----------|-------------------|--------|
%s

`[BENCHMARK]` El revelador: filas JPY/CLP pasan todos los DQ estructurales pero el
monto sale x100 si el pipeline no consulta TCURX. Solo se detecta en esta reconciliacion.
""" % (SEED, recon_lines,
       len(customers), len(del_customers), len(sc),
       len(materials), len(del_materials), len(sm),
       len(vbak), dq_orphan_hdr + dq_null_hdr, len(sh),
       len(vbap), dups_removed, len(si_quar), len(si),
       sum_lines))


# medallion schema (resumen; el DDL ejecutable esta en target-ddl/)
w(os.path.join(AK_DIR, "ground-truth-medallion-schema.md"), """# Ground Truth - Medallion Schema

> Resumen por capa. DDL ejecutable BigQuery en `../target-ddl/`.

## Bronze (sap_bronze) - raw 1:1, todo STRING
kna1 · mara · makt · tcurx · vbak · vbap (mismas columnas que la fuente)
+ metadata tecnica: `_ingest_ts TIMESTAMP`, `_source_system STRING`, `_batch_id STRING`.
Conserva LOEKZ/LVORM/MANDT y strings crudos. Conteo = fuente.

## Silver (sap_silver) - conformado, tipado, deduplicado, FK validadas
- customer(customer_id, name, country, city, postal_code, account_group, created_date DATE)
- material(material_id, material_type, material_group, base_uom, description, created_date DATE)
- sales_order_header(order_id, order_date DATE, customer_id, net_amount NUMERIC, currency, sales_org, order_type)
- sales_order_item(order_id, item_no, material_id, quantity NUMERIC, uom, net_amount NUMERIC, currency)
- _quarantine(source_table, business_key, reason, raw, _quarantined_ts)

## Gold (sap_gold) - dimensional + agregados
- dim_customer(customer_sk, customer_id, name, country, city)
- dim_material(material_sk, material_id, description, material_type, material_group)
- fact_sales_order_item(order_id, item_no, customer_sk, material_sk, order_date, quantity, net_amount, currency)
- agg_sales_by_customer_month(customer_id, year_month, currency, order_count, total_net_amount)
""")


# planted defects
def fmt_defect(d):
    return "| %s | %s | %s | %s | %s |" % (d["type"], d["table"], d["key"], d["detail"], d["action"])


by_type = {}
for d in PLANTED:
    by_type.setdefault(d["type"], []).append(d)

summary = "\n".join("| %s | %d |" % (t, len(v)) for t, v in sorted(by_type.items()))
detail = "\n".join(fmt_defect(d) for d in PLANTED)

w(os.path.join(AK_DIR, "planted-defects.md"), """# Planted Defects (ubicacion exacta)

> Cada defecto fue plantado a proposito. seed=%d. Este archivo NO se entrega en un test ciego.

## Resumen por tipo
| Tipo | # |
|------|---|
%s
| **TOTAL** | **%d** |

## Detalle (tabla + clave exacta)
| Tipo | Tabla | Clave | Detalle | Accion esperada del pipeline |
|------|-------|-------|---------|-------------------------------|
%s
""" % (SEED, summary, len(PLANTED), detail))


# ----------------------------------------------------------------------------
print("OK - generado seed-sap-to-bigquery-medallion (seed=%d)" % SEED)
print("  source/sap/: kna1=%d mara=%d makt=%d tcurx=%d vbak=%d vbap=%d" % (
    len(customers), len(materials), len(makt), len(tcurx), len(vbak), len(vbap)))
print("  silver: customer=%d material=%d header=%d item=%d (quar h=%d i=%d dup=%d)" % (
    len(sc), len(sm), len(sh), len(si), len(sh_quar), len(si_quar), dups_removed))
print("  gold fact=%d  defectos plantados=%d" % (len(gold_fact), len(PLANTED)))
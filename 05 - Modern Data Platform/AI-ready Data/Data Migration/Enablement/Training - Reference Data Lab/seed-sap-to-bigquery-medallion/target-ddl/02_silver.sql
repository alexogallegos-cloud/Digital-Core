-- BigQuery DDL - capa SILVER (conformado, tipado, deduplicado, FK validadas)
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

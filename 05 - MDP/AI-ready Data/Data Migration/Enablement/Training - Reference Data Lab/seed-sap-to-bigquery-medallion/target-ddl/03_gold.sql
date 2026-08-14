-- BigQuery DDL - capa GOLD (modelo dimensional + agregados)
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

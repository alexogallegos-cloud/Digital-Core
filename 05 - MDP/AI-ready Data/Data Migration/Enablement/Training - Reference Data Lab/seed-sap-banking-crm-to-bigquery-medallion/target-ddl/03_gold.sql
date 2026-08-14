-- BigQuery DDL - GOLD (dimensional + Customer 360 mastereado). dataset: bank_gold
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

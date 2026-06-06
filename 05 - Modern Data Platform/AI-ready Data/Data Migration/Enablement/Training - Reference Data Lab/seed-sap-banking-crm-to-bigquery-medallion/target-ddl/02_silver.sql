-- BigQuery DDL - SILVER (conformado, tipado, FK validadas). dataset: bank_silver
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

-- BigQuery DDL - BRONZE (raw 1:1, todo STRING, + metadata). datasets: bank_bronze
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

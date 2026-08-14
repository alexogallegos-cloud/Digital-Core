# Ground Truth - Medallion Schema (banking + CRM)

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

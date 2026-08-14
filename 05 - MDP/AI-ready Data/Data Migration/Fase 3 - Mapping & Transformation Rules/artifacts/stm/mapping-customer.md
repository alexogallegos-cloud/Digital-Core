# Source-to-Target Mapping — customer  (W0)

> **Target:** `gold.dim_customer`  ·  **Fuente:** silver.party (BUT000) + entity resolution con crm_account

| Columna target | Fuente | Regla | Nota |
|---|---|---|---|
| customer_sk | surrogate (row_number) | — | clave técnica |
| party_id | BUT000.PARTNER | REGLA-02 | ALPHA strip; clave de negocio |
| name | BUT000.NAME_ORG1 | NAME_FIRST+NAME_LAST | — | según TYPE |
| party_type | BUT000.TYPE | — | 1=persona 2=org |
| country | BUT000.LAND1 | — | ISO-2 |
| created_date | BUT000.CRDAT | REGLA-01 | DATS→DATE |
| segment | crm_account.segment | REGLA-09 | vía entity resolution |
| crm_matched / crm_account_ids | int_entity_resolution | REGLA-09/10 | merge de duplicados CRM |
| golden_record_source | derivado | REGLA-10 | SAP+CRM | SAP-only |
| (filtro) | BUT000.XDELE <> 'X' | REGLA-04 | borrados fuera |

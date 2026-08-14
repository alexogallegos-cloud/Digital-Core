# Source-to-Target Mapping — crm_opportunity  (W3)

> **Target:** `gold.fact_crm_opportunity`  ·  **Fuente:** crm_opportunity + dim_customer

| Columna target | Fuente | Regla | Nota |
|---|---|---|---|
| crm_opp_id | crm_opportunity.id | — |  |
| customer_sk | crm_opportunity.account_id → crm_account → party | REGLA-09 | vía crosswalk; crm_only→NULL (prospecto) |
| stage / amount / currency | crm_opportunity.* | — |  |
| close_date | crm_opportunity.close_date | — | ISO date |

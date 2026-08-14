# Source-to-Target Mapping — loan  (W2)

> **Target:** `gold.fact_loan`  ·  **Fuente:** VDARL + TCURX

| Columna target | Fuente | Regla | Nota |
|---|---|---|---|
| loan_id | VDARL.DARLEHEN | REGLA-02 | ALPHA strip |
| customer_sk | VDARL.PARTNER → dim_customer | REGLA-06 | FK validada |
| principal | VDARL.PRINCIPAL + WAERS + TCURX | REGLA-03 | ÷10^TCURX |
| currency / rate / term_months | VDARL.WAERS / RATE / TERM_MONTHS | — |  |
| start_date | VDARL.START_DATE | REGLA-01 | DATS→DATE |

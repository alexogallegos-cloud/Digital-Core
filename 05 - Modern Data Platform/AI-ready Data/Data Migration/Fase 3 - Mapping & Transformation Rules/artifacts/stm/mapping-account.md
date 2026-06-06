# Source-to-Target Mapping — account  (W1/W2)

> **Target:** `gold.dim_account (silver.account)`  ·  **Fuente:** BKK_ACCT (real: familia BKK40/BKKIT)

| Columna target | Fuente | Regla | Nota |
|---|---|---|---|
| account_id | BKK_ACCT.ACCT | REGLA-02 | ALPHA strip |
| customer_sk | BKK_ACCT.PARTNER → dim_customer | REGLA-06 | FK validada; huérfano→cuarentena |
| product | BKK_ACCT.PRODUCT | — |  |
| currency | BKK_ACCT.WAERS | — | CUKY |
| open_date | BKK_ACCT.OPEN_DATE | REGLA-01 | DATS→DATE |
| status | BKK_ACCT.STATUS | — |  |
| (filtro) | BKK_ACCT.LOEVM <> 'X' | REGLA-04 | borrados fuera |

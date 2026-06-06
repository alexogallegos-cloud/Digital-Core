# Source-to-Target Mapping — transaction  (W2)

> **Target:** `gold.fact_transaction`  ·  **Fuente:** BKKIT + TCURX

| Columna target | Fuente | Regla | Nota |
|---|---|---|---|
| account_id | BKKIT.ACCT → account | REGLA-02/06 | ALPHA + FK |
| item_no | BKKIT.ITEM_NO | REGLA-05 | dedup (ACCT,ITEM_NO) |
| post_date | BKKIT.POST_DATE | REGLA-01 | DATS→DATE |
| amount | BKKIT.AMOUNT + WAERS + TCURX | REGLA-03 | ÷10^TCURX — trampa JPY/CLP |
| currency | BKKIT.WAERS | — |  |
| dc_indicator | BKKIT.DC_IND | — | S=cargo H=abono |
| (completeness) | BKKIT.AMOUNT not null | REGLA-06 | nulo→cuarentena |

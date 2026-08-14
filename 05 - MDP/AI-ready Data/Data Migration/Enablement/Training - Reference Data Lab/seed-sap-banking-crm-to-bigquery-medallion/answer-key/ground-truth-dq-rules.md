# Ground Truth - DQ Rules (conteos esperados)

| DQ test | Dimension | Sistema/Tabla | Filas que FALLAN | Accion |
|---------|-----------|---------------|------------------|--------|
| referential: BKKIT.ACCT in BKK_ACCT | integridad | SAP/BKKIT | 282 | cuarentena |
| completeness: BKKIT.AMOUNT not null | completeness | SAP/BKKIT | 10 | cuarentena |
| uniqueness: (ACCT,ITEM_NO) | unicidad | SAP/BKKIT | 8 (dedup) | dedup |
| completeness: BKK_ACCT.PARTNER not null | completeness | SAP/BKK_ACCT | 10 | cuarentena |
| referential: VDARL.PARTNER in BUT000 | integridad | SAP/VDARL | 3 | cuarentena |
| validity: DATS fecha valida | validez | SAP (varias) | 8 | DATS->NULL |
| validity: deletion flag | validez | SAP BUT000/BKK_ACCT | 25 | filtrar |
| validity: email CRM | validez | CRM/crm_account | 28 | flag/estandarizar |
| consistency: pais ISO-2 | consistencia | CRM/crm_account | 204 | normalizar (country_map) |

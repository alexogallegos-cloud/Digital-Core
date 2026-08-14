# Ground Truth - Transformation Rules

| ID | Regla | Sistema/columnas | Logica |
|----|-------|------------------|--------|
| REGLA-01 | DATS_to_DATE | SAP CRDAT/OPEN_DATE/POST_DATE/START_DATE | 'YYYYMMDD'->DATE; '00000000'->NULL |
| REGLA-02 | ALPHA_strip | SAP PARTNER/ACCT | quitar ceros a la izquierda para clave de negocio; aplicar ANTES del join (resuelve leading_zero) |
| REGLA-03 | CURR_to_NUMERIC | SAP AMOUNT/PRINCIPAL + WAERS + TCURX | amount = AMOUNT / POW(10, TCURX.CURRDEC[WAERS]); NUNCA asumir 2 decimales |
| REGLA-04 | filter_deleted | SAP BUT000.XDELE / BKK_ACCT.LOEVM | excluir flag='X' en silver |
| REGLA-05 | dedup_key | SAP BKKIT (ACCT,ITEM_NO) | dedup keep-first |
| REGLA-06 | fk_validate_quarantine | BKKIT.ACCT, BKK_ACCT.PARTNER, VDARL.PARTNER | FK falla -> _quarantine |
| REGLA-07 | crm_country_map | CRM crm_account.country | 'Mexico'/'Mexico'/'MEX'->'MX'; 'USA'/'Estados Unidos'->'US'; etc. (ISO-2) |
| REGLA-08 | crm_email_validate | CRM crm_account.email | DQ validity: contiene '@' y dominio; malformado -> flag |
| REGLA-09 | entity_resolution | SAP BUT000 <-> CRM crm_account | ref exacto OR (norm_name + country); ver ground-truth-entity-resolution.md |
| REGLA-10 | master_merge | gold dim_customer | merge de cuentas CRM duplicadas a 1 golden record por PARTNER |

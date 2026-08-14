# Catálogo de Reglas de Transformación — Fase 3

> Reglas ejecutables fuente→target. Cada una ya está implementada en el `reference-solution-dbt` del Reference Data Lab (macro/modelo indicado). Coinciden con el answer key del seed banking+CRM y con los ADRs de Fase 2.

| ID | Regla | Lógica | Implementación (dbt) | Aplica a |
|---|---|---|---|---|
| REGLA-01 | DATS_to_DATE | DATS 'YYYYMMDD' → DATE; '00000000'/fuera de rango → NULL | macro `dats_to_date` | CRDAT, OPEN_DATE, POST_DATE, START_DATE |
| REGLA-02 | ALPHA_strip | Quitar ceros a la izquierda (clave de negocio); aplicar ANTES de cualquier join | macro `alpha_strip` | PARTNER, ACCT, DARLEHEN |
| REGLA-03 | CURR_to_NUMERIC (TCURX) | amount = raw / POW(10, TCURX.CURRDEC[moneda]); NUNCA /100 fijo (JPY/CLP=0 dec) | silver_transaction / silver_loan | AMOUNT, PRINCIPAL + WAERS |
| REGLA-04 | filter_deleted | Excluir filas con flag de borrado='X' en silver; conservarlas en bronze | WHERE XDELE/LOEVM <> 'X' | BUT000.XDELE, BKK_ACCT.LOEVM |
| REGLA-05 | dedup_key | Deduplicar por clave de negocio; supervivencia determinista (keep-first / regla MDM) | row_number() over(partition by clave) | (ACCT, ITEM_NO) |
| REGLA-06 | fk_validate_quarantine | Validar FK; filas que fallan → _quarantine (no entran a la tabla limpia) | join + tabla _quarantine | ACCT→account, PARTNER→party |
| REGLA-07 | crm_country_map | Normalizar país a ISO-2 ('Mexico'/'MEX'→'MX', 'USA'→'US', ...) | macro `crm_country_iso` | crm_account.country |
| REGLA-08 | crm_email_validate | DQ validity: email con '@' y dominio; malformado → flag | regexp_contains | crm_account/contact.email |
| REGLA-09 | entity_resolution | Match exacto (sap_partner_ref) OR fuzzy (norm_name + país); ver ADR-MDP-MIG-003 | modelo `int_entity_resolution` | BUT000 ↔ crm_account |
| REGLA-10 | master_merge | Múltiples cuentas CRM del mismo party → 1 golden record (MDM survivorship) | dim_customer (array_agg) | dim_customer.crm_account_ids |

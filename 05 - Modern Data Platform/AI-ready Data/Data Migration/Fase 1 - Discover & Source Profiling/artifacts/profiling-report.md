# Profiling Report

> Null rate y cardinalidad por columna (columnas clave). Generado por profile.py.

## but000 (Business Partner (cliente bancario), 300 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| MANDT | 0 | 0.0% | 1 |
| PARTNER | 0 | 0.0% | 300 |
| TYPE | 0 | 0.0% | 2 |
| NAME_ORG1 | 121 | 40.3% | 162 |
| NAME_FIRST | 179 | 59.7% | 13 |
| NAME_LAST | 179 | 59.7% | 79 |
| LAND1 | 0 | 0.0% | 3 |
| XDELE | 288 | 96.0% | 2 |
| CRDAT | 0 | 0.0% | 267 |

## but0bk (BP bank details, 300 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| MANDT | 0 | 0.0% | 1 |
| PARTNER | 0 | 0.0% | 300 |
| BKVID | 0 | 0.0% | 1 |
| BANKL | 0 | 0.0% | 97 |
| BANKN | 0 | 0.0% | 300 |

## bkk_acct (Cuenta deposito — account master simplificado (SAP real reparte la cuenta en BKK40/BKKIT/...), 417 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| MANDT | 0 | 0.0% | 1 |
| ACCT | 0 | 0.0% | 417 |
| PARTNER | 10 | 2.4% | 297 |
| PRODUCT | 0 | 0.0% | 3 |
| WAERS | 0 | 0.0% | 4 |
| OPEN_DATE | 0 | 0.0% | 377 |
| STATUS | 0 | 0.0% | 2 |
| LOEVM | 404 | 96.9% | 2 |

## bkkit (Movimientos de cuenta, 4771 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| MANDT | 0 | 0.0% | 1 |
| ACCT | 0 | 0.0% | 452 |
| ITEM_NO | 0 | 0.0% | 21 |
| POST_DATE | 0 | 0.0% | 1671 |
| VALUT | 0 | 0.0% | 1658 |
| AMOUNT | 10 | 0.2% | 4760 |
| WAERS | 0 | 0.0% | 4 |
| DC_IND | 0 | 0.0% | 2 |
| TEXT | 0 | 0.0% | 5 |

## vdarl (Contrato de credito (FS-CML), 162 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| MANDT | 0 | 0.0% | 1 |
| DARLEHEN | 0 | 0.0% | 162 |
| PARTNER | 0 | 0.0% | 162 |
| PRINCIPAL | 0 | 0.0% | 162 |
| WAERS | 0 | 0.0% | 2 |
| RATE | 0 | 0.0% | 150 |
| START_DATE | 0 | 0.0% | 159 |
| TERM_MONTHS | 0 | 0.0% | 5 |

## tcurx (Decimales por moneda, 4 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| CURRKEY | 0 | 0.0% | 4 |
| CURRDEC | 0 | 0.0% | 2 |

## crm_account (Cuenta CRM (comercial), 275 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| id | 0 | 0.0% | 275 |
| account_name | 0 | 0.0% | 259 |
| country | 0 | 0.0% | 13 |
| city | 0 | 0.0% | 5 |
| segment | 0 | 0.0% | 4 |
| sap_partner_ref | 159 | 57.8% | 117 |
| is_active | 0 | 0.0% | 2 |
| created_at | 0 | 0.0% | 251 |

## crm_contact (Contacto CRM, 552 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| id | 0 | 0.0% | 552 |
| account_id | 0 | 0.0% | 275 |
| full_name | 0 | 0.0% | 139 |
| email | 0 | 0.0% | 552 |
| phone | 0 | 0.0% | 552 |
| role | 0 | 0.0% | 4 |

## crm_opportunity (Oportunidad CRM, 282 filas)

| Columna | Nulls | Null rate | Distinct |
|---|---|---|---|
| id | 0 | 0.0% | 282 |
| account_id | 0 | 0.0% | 189 |
| stage | 0 | 0.0% | 4 |
| amount | 0 | 0.0% | 282 |
| currency | 0 | 0.0% | 4 |
| close_date | 0 | 0.0% | 236 |


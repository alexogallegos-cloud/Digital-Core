# Ground Truth - Reconciliation (por capa)

> Conteos y sumas computados de los datos emitidos. seed=73.

## Conteo de filas por capa
| Capa | Tabla | # filas |
|------|-------|---------|
| bronze | sap_but000 | 300 |
| bronze | sap_bkk_acct | 417 |
| bronze | sap_bkkit | 4771 |
| bronze | sap_vdarl | 162 |
| bronze | crm_account | 275 |
| bronze | crm_opportunity | 282 |
| silver | party | 288 |
| silver | account (limpio) | 394 |
| silver |   account cuarentena | 23 |
| silver | transaction (limpio) | 4471 |
| silver |   transaction cuarentena | 292 |
| silver |   transaction dup removidos | 8 |
| silver | loan (limpio) | 159 |
| silver |   loan cuarentena | 3 |
| silver | crm_account | 275 |
| gold | dim_customer | 288 |
| gold |   dim_customer con match CRM | 202 |
| gold | fact_transaction | 4471 |

**Derivacion clave:**
- silver.party = bronze.but000 - XDELE='X' (300 - 12 = 288)
- silver.account limpio = bronze.bkk_acct - LOEVM='X' - PARTNER nulo/huerfano (417 - 23 = 394)
- silver.transaction limpio = bronze.bkkit - dup - cuarentena FK/nulos (4771 - 8 - 292 = 4471)
- gold.dim_customer = silver.party (1 golden record por PARTNER; cuentas CRM duplicadas mergeadas)

## Reconciliacion de montos en GOLD (fact_transaction, aplicando TCURX)
| Moneda | TCURX dec | SUM real | SUM naive (/100) | Estado |
|--------|-----------|----------|-------------------|--------|
| CLP | 0 | 457543435.00 | 4575434.35 | TRAP x100 |
| JPY | 0 | 831694710.00 | 8316947.10 | TRAP x100 |
| MXN | 2 | 75582800.03 | 75582800.03 | OK |
| USD | 2 | 23203775.87 | 23203775.87 | OK |

`[BENCHMARK]` Doble revelador de este seed:
1. **Decimales por moneda** (JPY/CLP): naive /100 corrompe x100 (solo visible aqui).
2. **Entity resolution**: dim_customer correcto requiere resolver el crosswalk SAP<->CRM
   (ref exacto + fuzzy + merge de duplicados). Ver ground-truth-entity-resolution.md.

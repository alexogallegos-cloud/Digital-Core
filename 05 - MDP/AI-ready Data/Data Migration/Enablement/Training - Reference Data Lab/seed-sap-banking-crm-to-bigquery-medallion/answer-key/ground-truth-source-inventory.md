# Ground Truth - Source Inventory (2 sistemas)

> Computado de los datos emitidos. seed=73.

## SAP ECC Banking (system of record)
| Tabla | Descripcion | Clave | # filas |
|-------|-------------|-------|---------|
| BUT000 | Business Partner (cliente) | MANDT+PARTNER | 300 |
| BUT0BK | BP bank details | MANDT+PARTNER+BKVID | 300 |
| BKK_ACCT | Cuenta deposito (Deposits Mgmt) | MANDT+ACCT | 417 |
| BKKIT | Movimientos de cuenta | MANDT+ACCT+ITEM_NO | 4771 |
| VDARL | Contrato de credito (FS-CML) | MANDT+DARLEHEN | 162 |
| TCURX | Decimales por moneda | CURRKEY | 4 |

## CRM generico
| Tabla | Descripcion | Clave | # filas |
|-------|-------------|-------|---------|
| crm_account | Cuenta CRM | id | 275 |
| crm_contact | Contacto | id | 552 |
| crm_opportunity | Oportunidad | id | 282 |

Clientes reales (verdad subyacente): **300**. Total defectos plantados: **498** (ver `planted-defects.md`).

# Ground Truth - Hubs (blast radius por fan-in)

> Las tablas mas referenciadas: maximo impacto si cambian. Migrar/masterear primero.

| # | Tabla | Fan-in | Arquetipo | Modulo | Rol |
|---|---|---|---|---|---|
| 1 | T001 | 925 | CUST | fi_gl | Company codes — referenced by every posting |
| 2 | TCURC | 253 | CUST | fi_gl | Currency codes |
| 3 | TCURX | 246 | CUST | fi_gl | Decimal places per currency (amount conversion) |
| 4 | SKB1 | 196 | MASTER | fi_gl | G/L account master (company-code level) |
| 5 | SKA1 | 142 | MASTER | fi_gl | G/L account master (chart of accounts) |
| 6 | CMS101 | 106 | MASTER | collateral | (generada) |
| 7 | BUT000 | 72 | MASTER | bp | Business Partner — the customer, shared by all modules |
| 8 | VTBBEWE | 65 | MASTER | cml_loans | (generada) |
| 9 | CCARD101 | 60 | MASTER | cards | (generada) |
| 10 | BKK_CARD | 59 | MASTER | cards | (generada) |
| 11 | FEB231 | 56 | CUST | channels | (generada) |
| 12 | COBK | 51 | MASTER | co | (generada) |
| 13 | VDBEPK | 50 | MASTER | cml_loans | (generada) |
| 14 | FEB110 | 49 | MASTER | channels | (generada) |
| 15 | CCARD241 | 47 | CUST | cards | (generada) |
| 16 | COKA | 45 | MASTER | co | (generada) |
| 17 | COSS | 44 | MASTER | co | (generada) |
| 18 | T042 | 42 | MASTER | payments | (generada) |
| 19 | BKKA | 40 | MASTER | am_deposits | (generada) |
| 20 | BKKEXT | 39 | MASTER | am_deposits | (generada) |
| 21 | T028G | 29 | MASTER | channels | (generada) |
| 22 | BUT195 | 29 | CUST | bp | (generada) |
| 23 | CRM_ACCOUNT | 29 | MASTER | crm | (generada) |
| 24 | DMEE206 | 28 | CUST | dmee | (generada) |
| 25 | CCARDEC | 25 | MASTER | cards | (generada) |

# Source Inventory - BANKING-SAP-CRM-LATAM

> Descubierto del data estate (2 sistemas fuente). Generado por profile.py.

| Tabla | Sistema | Capa | Dominio | PK | # filas | # cols |
|---|---|---|---|---|---|---|
| but000 | SAP | SAP-MASTER | customer | MANDT+PARTNER | 300 | 9 |
| but0bk | SAP | SAP-MASTER | customer | MANDT+PARTNER+BKVID | 300 | 5 |
| bkk_acct | SAP | SAP-TXN | account | MANDT+ACCT | 417 | 8 |
| bkkit | SAP | SAP-TXN | transaction | MANDT+ACCT+ITEM_NO | 4771 | 9 |
| vdarl | SAP | SAP-TXN | product | MANDT+DARLEHEN | 162 | 8 |
| tcurx | SAP | SAP-CHECK | reference | CURRKEY | 4 | 2 |
| crm_account | CRM | CRM | commercial | id | 275 | 8 |
| crm_contact | CRM | CRM | commercial | id | 552 | 6 |
| crm_opportunity | CRM | CRM | commercial | id | 282 | 6 |

**Sistemas fuente:** SAP ECC Banking (system of record) + CRM generico.

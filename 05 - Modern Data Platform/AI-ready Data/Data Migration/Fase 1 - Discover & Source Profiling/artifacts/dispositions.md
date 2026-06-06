# Disposicion de Migracion por Tabla (el "7R" de datos)

> Taxonomia: Rehost-raw (Bronze 1:1) | Conform (Silver) | Master/Consolidate (entity
> resolution) | Retire | Archive. Riesgo: green < yellow < orange < red < black.

| Tabla | Dominio | Disposicion | Riesgo | # filas | Razon |
|---|---|---|---|---|---|
| but000 | customer | Master/Consolidate | red | 300 | Cliente: system of record + entity resolution con CRM |
| bkkit | transaction | Conform | red | 4771 | Alto volumen + trampa decimales por moneda (TCURX) + huerfanos |
| crm_account | commercial | Master/Consolidate | red | 275 | Cliente comercial; merge a golden record SAP (MDM) |
| bkk_acct | account | Conform | orange | 417 | FK a cliente; nulos/borrados a cuarentena |
| but0bk | customer | Conform | yellow | 300 | Detalle bancario; tipado |
| vdarl | product | Conform | yellow | 162 | Credito; FK partner; TCURX |
| crm_opportunity | commercial | Conform | yellow | 282 | Comercial; FK a cuenta CRM; multi-moneda |
| tcurx | reference | Rehost-raw | green | 4 | Check table; carga 1:1 (habilita conversion de montos) |
| crm_contact | commercial | Conform | green | 552 | Comercial; FK a cuenta CRM |

**Sin candidatos a Retire/Archive a nivel tabla** en este estate; los huerfanos se manejan a nivel fila (cuarentena). Las 2 tablas de cliente concentran el riesgo (mastering).

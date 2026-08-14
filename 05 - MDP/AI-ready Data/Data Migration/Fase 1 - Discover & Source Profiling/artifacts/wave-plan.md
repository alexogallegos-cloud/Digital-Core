# Wave Plan (orden de migracion)

> Por dominio + orden de dependencia + riesgo. Generado por profile.py.

## Wave 0 - Foundation
Check tables + cliente mastereado (referenciado por todo). Entity resolution SAP<->CRM aqui.

| Tabla | Disposicion | Riesgo | # filas |
|---|---|---|---|
| tcurx | Rehost-raw | green | 4 |
| but000 | Master/Consolidate | red | 300 |
| crm_account | Master/Consolidate | red | 275 |

## Wave 1 - Cuentas y productos
Dependen del cliente. FK validada contra Wave 0.

| Tabla | Disposicion | Riesgo | # filas |
|---|---|---|---|
| bkk_acct | Conform | orange | 417 |
| but0bk | Conform | yellow | 300 |
| vdarl | Conform | yellow | 162 |

## Wave 2 - Movimientos
Mayor volumen; depende de cuentas. Conversion TCURX critica.

| Tabla | Disposicion | Riesgo | # filas |
|---|---|---|---|
| bkkit | Conform | red | 4771 |

## Wave 3 - Comercial CRM
Capa comercial; depende de cuentas CRM mastereadas.

| Tabla | Disposicion | Riesgo | # filas |
|---|---|---|---|
| crm_contact | Conform | green | 552 |
| crm_opportunity | Conform | yellow | 282 |


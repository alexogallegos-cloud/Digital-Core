# Planted Defects (ubicacion exacta)

> seed=73. NO se entrega en un test ciego.

## Resumen por tipo
| Tipo | # |
|------|---|
| country_inconsistent | 204 |
| crm_duplicate | 25 |
| currency_decimal_trap | 48 |
| deletion_flag | 25 |
| duplicate_key | 8 |
| invalid_date | 8 |
| leading_zero_inconsistency | 20 |
| malformed_email | 28 |
| missing_ref | 94 |
| null_mandatory | 20 |
| referential_orphan | 18 |
| **TOTAL** | **498** |

## Detalle
| Tipo | Sistema | Tabla | Clave | Detalle | Accion esperada |
|------|---------|-------|-------|---------|-----------------|
| deletion_flag | SAP | BUT000 | PARTNER=0001000009 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000020 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000023 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000062 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000064 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000081 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000084 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| invalid_date | SAP | BUT000 | PARTNER=0001000106 | CRDAT='00000000' | DATS->DATE: NULL |
| invalid_date | SAP | BUT000 | PARTNER=0001000109 | CRDAT='00000000' | DATS->DATE: NULL |
| invalid_date | SAP | BUT000 | PARTNER=0001000110 | CRDAT='00000000' | DATS->DATE: NULL |
| invalid_date | SAP | BUT000 | PARTNER=0001000119 | CRDAT='00000000' | DATS->DATE: NULL |
| invalid_date | SAP | BUT000 | PARTNER=0001000128 | CRDAT='00000000' | DATS->DATE: NULL |
| deletion_flag | SAP | BUT000 | PARTNER=0001000147 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000154 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| invalid_date | SAP | BUT000 | PARTNER=0001000186 | CRDAT='00000000' | DATS->DATE: NULL |
| invalid_date | SAP | BUT000 | PARTNER=0001000203 | CRDAT='00000000' | DATS->DATE: NULL |
| deletion_flag | SAP | BUT000 | PARTNER=0001000250 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| deletion_flag | SAP | BUT000 | PARTNER=0001000277 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| invalid_date | SAP | BUT000 | PARTNER=0001000292 | CRDAT='00000000' | DATS->DATE: NULL |
| deletion_flag | SAP | BUT000 | PARTNER=0001000293 | Business Partner con XDELE='X' | Filtrar en silver_party; conservar en bronze |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000027 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000029 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000032 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000034 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000053 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000059 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000069 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000071 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000076 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000077 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000080 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000085 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000087 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000089 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000091 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000093 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000098 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000108 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000115 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000118 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000127 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000138 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000142 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000166 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000167 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000169 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000172 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000177 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000179 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000184 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000191 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000198 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000208 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000217 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000218 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000228 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000232 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000233 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000235 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000250 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000262 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000266 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000278 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000284 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000289 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000289 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000290 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000297 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000299 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000309 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000329 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000335 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000338 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000344 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000348 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000357 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000363 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| deletion_flag | SAP | BKK_ACCT | ACCT=000050000369 | Cuenta con LOEVM='X' | Filtrar en silver_account |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000376 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000378 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| null_mandatory | SAP | BKK_ACCT | ACCT=000050000385 | PARTNER vacio (obligatorio) | DQ completeness; cuarentena |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000386 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000389 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000391 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000392 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000406 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000407 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000409 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000412 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000416 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(JPY); naive /100 corrompe x100 |
| currency_decimal_trap | SAP | BKK_ACCT | ACCT=000050000417 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir /10^TCURX(CLP); naive /100 corrompe x100 |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000007 ITEM_NO=000005 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099000114 ITEM_NO=000008 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099000386 ITEM_NO=000002 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000036 ITEM_NO=000011 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099000630 ITEM_NO=000005 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000064 ITEM_NO=000002 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099000949 ITEM_NO=000006 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| null_mandatory | SAP | BKKIT | ACCT=000050000084 ITEM_NO=000005 | AMOUNT vacio | DQ completeness; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000089 ITEM_NO=000014 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000092 ITEM_NO=000005 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099001092 ITEM_NO=000009 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000109 ITEM_NO=000016 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000124 ITEM_NO=000004 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000124 ITEM_NO=000005 | AMOUNT vacio | DQ completeness; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000138 ITEM_NO=000015 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000145 ITEM_NO=000015 | AMOUNT vacio | DQ completeness; cuarentena |
| null_mandatory | SAP | BKKIT | ACCT=000050000146 ITEM_NO=000011 | AMOUNT vacio | DQ completeness; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000171 ITEM_NO=000009 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000174 ITEM_NO=000002 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099002178 ITEM_NO=000008 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000200 ITEM_NO=000002 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099002304 ITEM_NO=000011 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000221 ITEM_NO=000013 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000234 ITEM_NO=000004 | AMOUNT vacio | DQ completeness; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099002727 ITEM_NO=000010 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000240 ITEM_NO=000005 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099002789 ITEM_NO=000003 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000244 ITEM_NO=000005 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000249 ITEM_NO=000006 | AMOUNT vacio | DQ completeness; cuarentena |
| null_mandatory | SAP | BKKIT | ACCT=000050000262 ITEM_NO=000006 | AMOUNT vacio | DQ completeness; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000267 ITEM_NO=000007 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000270 ITEM_NO=000004 | AMOUNT vacio | DQ completeness; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099003123 ITEM_NO=000003 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099003181 ITEM_NO=000006 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099003374 ITEM_NO=000012 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000324 ITEM_NO=000006 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000325 ITEM_NO=000003 | AMOUNT vacio | DQ completeness; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000345 ITEM_NO=000007 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| referential_orphan | SAP | BKKIT | ACCT=000099003921 ITEM_NO=000005 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099004154 ITEM_NO=000001 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000384 ITEM_NO=000003 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000392 ITEM_NO=000002 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| null_mandatory | SAP | BKKIT | ACCT=000050000396 ITEM_NO=000001 | AMOUNT vacio | DQ completeness; cuarentena |
| referential_orphan | SAP | BKKIT | ACCT=000099004533 ITEM_NO=000012 | ACCT no existe en BKK_ACCT (movimiento huerfano) | FK falla; cuarentena |
| leading_zero_inconsistency | SAP | BKKIT | ACCT=50000399 ITEM_NO=000018 | ACCT sin ceros a la izquierda | Aplicar ALPHA antes del join; NO es huerfano |
| duplicate_key | SAP | BKKIT | ACCT=000050000220 ITEM_NO=000009 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000225 ITEM_NO=000008 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000234 ITEM_NO=000011 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000042 ITEM_NO=000012 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000172 ITEM_NO=000012 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000363 ITEM_NO=000012 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000096 ITEM_NO=000003 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| duplicate_key | SAP | BKKIT | ACCT=000050000043 ITEM_NO=000016 | Clave (ACCT,ITEM_NO) duplicada | Dedup keep-first |
| referential_orphan | SAP | VDARL | DARLEHEN=000080000050 PARTNER=0097000050 | PARTNER no existe en BUT000 | FK falla; cuarentena |
| referential_orphan | SAP | VDARL | DARLEHEN=000080000100 PARTNER=0097000100 | PARTNER no existe en BUT000 | FK falla; cuarentena |
| referential_orphan | SAP | VDARL | DARLEHEN=000080000150 PARTNER=0097000150 | PARTNER no existe en BUT000 | FK falla; cuarentena |
| country_inconsistent | CRM | crm_account | id=CRM-000001 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=278 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000002 | Email malformado ('contacto2empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000003 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=96 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000004 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000005 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=124 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000007 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=36 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000008 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=144 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000009 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=88 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000010 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000011 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=7 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000012 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000013 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000014 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000015 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=53 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000017 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000019 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=118 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000020 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=254 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000021 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=249 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000023 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=103 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000024 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=25 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000025 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=126 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=221 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000027 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=9 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000028 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000029 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000031 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=269 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=222 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000033 | Email malformado ('contacto33empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000033 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000034 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000035 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000036 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000038 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=161 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000039 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=73 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000041 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000042 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=265 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000043 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000044 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000046 | Email malformado ('contacto46cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000046 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000047 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000048 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000049 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000050 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000052 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000053 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=113 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000054 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000055 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=255 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=2 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000057 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000058 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=93 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000059 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000060 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=169 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000062 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000063 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=211 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000064 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000067 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=225 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000069 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=108 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000072 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=12 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000073 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=214 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=20 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=295 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000076 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000077 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000078 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=191 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000079 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=157 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=128 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000083 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000084 | Email malformado ('contacto84empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000084 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000085 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000086 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000087 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=54 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000088 | Email malformado ('contacto88 at empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000088 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=176 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000090 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=65 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=42 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000092 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=107 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000093 | Email malformado ('contacto93 at empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000093 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=283 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000094 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=207 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000095 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=141 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000096 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000097 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000098 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=114 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000099 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000100 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000102 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=70 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000104 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=271 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000105 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000107 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000108 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=263 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000109 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=164 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000110 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=110 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000112 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000113 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000114 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=202 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000115 | Email malformado ('contacto115 at empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000115 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000116 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000117 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=210 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000118 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000119 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=190 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000120 | Email malformado ('contacto120 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000121 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000123 | Email malformado ('contacto123empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000124 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=14 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000125 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000126 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000127 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=15 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000128 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000129 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000130 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=259 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000131 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=13 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000132 | Email malformado ('contacto132empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000132 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=281 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=158 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000135 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000136 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000137 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000139 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000140 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=267 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000141 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000143 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=23 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000144 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000145 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000146 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=178 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000148 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=266 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=160 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000150 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=235 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000151 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000152 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=219 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000153 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=155 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000154 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=251 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000155 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=262 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000156 | Email malformado ('contacto156 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000157 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=291 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=39 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000160 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000161 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=68 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000163 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000165 | Email malformado ('contacto165 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| missing_ref | CRM | crm_account | real=297 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000166 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=268 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000167 | Email malformado ('contacto167cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000167 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=116 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000168 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=246 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000169 | Email malformado ('contacto169 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| missing_ref | CRM | crm_account | real=233 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000171 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=81 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000172 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=260 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000173 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=78 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000174 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000175 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=101 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000176 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000177 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=152 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000178 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000181 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000182 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000183 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000184 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000187 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=85 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000188 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=238 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000190 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000191 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=75 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000192 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=272 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000193 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000194 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000195 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=80 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| malformed_email | CRM | crm_account | id=CRM-000197 | Email malformado ('contacto197cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000197 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000198 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000199 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000200 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000201 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=175 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=243 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| missing_ref | CRM | crm_account | real=276 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000204 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=280 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000205 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=122 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000206 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=77 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000207 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000208 | Email malformado ('contacto208empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000208 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| missing_ref | CRM | crm_account | real=234 | sap_partner_ref nulo -> requiere fuzzy match por nombre+pais | Entity resolution por match_key+pais |
| country_inconsistent | CRM | crm_account | id=CRM-000209 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000211 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=288 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| crm_duplicate | CRM | crm_account | real=101 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| crm_duplicate | CRM | crm_account | real=225 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000214 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=5 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000215 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=13 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| malformed_email | CRM | crm_account | id=CRM-000216 | Email malformado ('contacto216cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000216 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=174 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000217 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=300 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| malformed_email | CRM | crm_account | id=CRM-000218 | Email malformado ('contacto218 at empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000218 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=38 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000219 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=132 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000220 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=118 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000221 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=11 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000222 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=127 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000223 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=24 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| crm_duplicate | CRM | crm_account | real=30 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| malformed_email | CRM | crm_account | id=CRM-000225 | Email malformado ('contacto225cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000225 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=120 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000226 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=81 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| malformed_email | CRM | crm_account | id=CRM-000227 | Email malformado ('contacto227empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000227 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=103 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000228 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=45 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| malformed_email | CRM | crm_account | id=CRM-000229 | Email malformado ('contacto229empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| crm_duplicate | CRM | crm_account | real=109 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000230 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=166 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| crm_duplicate | CRM | crm_account | real=281 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000232 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=269 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000233 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=144 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000234 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=156 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000235 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| crm_duplicate | CRM | crm_account | real=104 | Segunda cuenta CRM para el mismo cliente real (MDM) | Mastering: merge a un golden record |
| country_inconsistent | CRM | crm_account | id=CRM-000237 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000238 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000239 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000240 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000241 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000242 | Email malformado ('contacto242empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000242 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000243 | Email malformado ('contacto243empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000243 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000244 | Email malformado ('contacto244empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000244 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000245 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000246 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000247 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000249 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000250 | Email malformado ('contacto250 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000250 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000251 | Email malformado ('contacto251cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000253 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000254 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000255 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000257 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000258 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000259 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000260 | Pais en formato no-ISO ('Estados Unidos') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000261 | Pais en formato no-ISO ('United States') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000262 | Email malformado ('contacto262empresa.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000263 | Pais en formato no-ISO ('CHL') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000265 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| malformed_email | CRM | crm_account | id=CRM-000266 | Email malformado ('contacto266 at cliente.com') | DQ validity; estandarizar o cuarentena de campo |
| country_inconsistent | CRM | crm_account | id=CRM-000266 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000270 | Pais en formato no-ISO ('USA') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000271 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000272 | Pais en formato no-ISO ('Chile') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000273 | Pais en formato no-ISO ('México') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000274 | Pais en formato no-ISO ('MEX') | Normalizar a ISO-2 (regla country_map) |
| country_inconsistent | CRM | crm_account | id=CRM-000275 | Pais en formato no-ISO ('Mexico') | Normalizar a ISO-2 (regla country_map) |

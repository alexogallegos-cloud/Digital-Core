# Planted Defects (ubicacion exacta)

> Cada defecto fue plantado a proposito. seed=42. Este archivo NO se entrega en un test ciego.

## Resumen por tipo
| Tipo | # |
|------|---|
| amount_outlier | 4 |
| currency_decimal_trap | 107 |
| deletion_flag | 25 |
| duplicate_key | 5 |
| invalid_date | 14 |
| leading_zero_inconsistency | 20 |
| null_mandatory | 12 |
| referential_orphan | 30 |
| **TOTAL** | **217** |

## Detalle (tabla + clave exacta)
| Tipo | Tabla | Clave | Detalle | Accion esperada del pipeline |
|------|-------|-------|---------|-------------------------------|
| deletion_flag | KNA1 | KUNNR=0000010007 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| invalid_date | KNA1 | KUNNR=0000010008 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| invalid_date | KNA1 | KUNNR=0000010009 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| deletion_flag | KNA1 | KUNNR=0000010023 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| invalid_date | KNA1 | KUNNR=0000010024 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| deletion_flag | KNA1 | KUNNR=0000010027 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010029 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010036 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| invalid_date | KNA1 | KUNNR=0000010056 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| deletion_flag | KNA1 | KUNNR=0000010058 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| invalid_date | KNA1 | KUNNR=0000010060 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| deletion_flag | KNA1 | KUNNR=0000010063 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010071 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010109 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| invalid_date | KNA1 | KUNNR=0000010130 | ERDAT='00000000' (fecha SAP nula) | DATS->DATE: mapear a NULL en silver |
| deletion_flag | KNA1 | KUNNR=0000010140 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010152 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010164 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010174 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010189 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | KNA1 | KUNNR=0000010190 | Cliente con flag de borrado LOEKZ='X' | Filtrar en silver_customer; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010008 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010023 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010063 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010072 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010087 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010098 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010116 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010119 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010127 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| deletion_flag | MARA | MATNR=000000000000010146 | Material con flag de borrado LVORM='X' | Filtrar en silver_material; conservar en bronze |
| currency_decimal_trap | VBAK | VBELN=4500000015 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| null_mandatory | VBAK | VBELN=4500000038 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| invalid_date | VBAK | VBELN=4500000038 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000039 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000043 KUNNR=0009990042 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| referential_orphan | VBAK | VBELN=4500000045 KUNNR=0009990044 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| currency_decimal_trap | VBAK | VBELN=4500000050 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000059 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000065 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000084 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000095 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000097 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000105 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000106 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000128 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000144 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000147 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000160 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000161 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000167 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000172 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000176 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000205 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000205 KUNNR=0009990204 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| null_mandatory | VBAK | VBELN=4500000207 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| currency_decimal_trap | VBAK | VBELN=4500000214 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000218 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000233 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000238 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000260 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000267 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000278 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000285 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000292 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000296 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| null_mandatory | VBAK | VBELN=4500000301 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| currency_decimal_trap | VBAK | VBELN=4500000302 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000309 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000311 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000318 KUNNR=0009990317 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| currency_decimal_trap | VBAK | VBELN=4500000323 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000324 KUNNR=0009990323 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| currency_decimal_trap | VBAK | VBELN=4500000337 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000343 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000350 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000353 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000357 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000367 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000394 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000399 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000408 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000412 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000420 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000429 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000450 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000458 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| null_mandatory | VBAK | VBELN=4500000469 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| currency_decimal_trap | VBAK | VBELN=4500000471 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000485 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000494 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000506 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000528 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000537 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000544 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000548 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000549 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000551 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000557 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000557 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000559 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000572 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000583 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000584 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000606 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000618 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000633 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000634 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000646 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000652 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000660 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000667 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000669 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000672 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000674 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000678 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000683 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000691 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000707 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000708 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000718 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000729 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000732 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000741 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000744 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000763 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000772 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000777 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000783 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000785 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000789 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000793 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| null_mandatory | VBAK | VBELN=4500000795 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| currency_decimal_trap | VBAK | VBELN=4500000807 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000810 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000811 KUNNR=0009990810 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| currency_decimal_trap | VBAK | VBELN=4500000816 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000820 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000828 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000831 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000832 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| invalid_date | VBAK | VBELN=4500000835 | ERDAT='00000000' | DATS->DATE: mapear a NULL |
| currency_decimal_trap | VBAK | VBELN=4500000838 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000857 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000887 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000897 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000907 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000908 KUNNR=0009990907 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| currency_decimal_trap | VBAK | VBELN=4500000924 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000932 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000954 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAK | VBELN=4500000956 KUNNR=0009990955 | KUNNR no existe en KNA1 | FK customer falla; cuarentena |
| null_mandatory | VBAK | VBELN=4500000967 | KUNNR vacio (obligatorio) | DQ completeness; cuarentena (no entra a silver_header limpio) |
| currency_decimal_trap | VBAK | VBELN=4500000973 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000975 | Moneda CLP con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(CLP); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000978 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000981 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000982 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000984 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| currency_decimal_trap | VBAK | VBELN=4500000991 | Moneda JPY con 0 decimales (TCURX); montos en minor units | Convertir NETWR/10^TCURX(JPY); un pipeline naive /100 corrompe x100 |
| referential_orphan | VBAP | VBELN=4500000032 POSNR=000030 MATNR=000000000008880107 | MATNR no existe en MARA | FK material falla; cuarentena |
| referential_orphan | VBAP | VBELN=4500000046 POSNR=000020 MATNR=000000000008880161 | MATNR no existe en MARA | FK material falla; cuarentena |
| referential_orphan | VBAP | VBELN=4500000073 POSNR=000060 MATNR=000000000008880283 | MATNR no existe en MARA | FK material falla; cuarentena |
| null_mandatory | VBAP | VBELN=4500000111 POSNR=000030 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| referential_orphan | VBAP | VBELN=4500000139 POSNR=000030 MATNR=000000000008880521 | MATNR no existe en MARA | FK material falla; cuarentena |
| null_mandatory | VBAP | VBELN=4500000166 POSNR=000040 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000168 POSNR=000020 | MATNR sin ceros a la izquierda ('10051') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| amount_outlier | VBAP | VBELN=4500000169 POSNR=000060 | NETWR con magnitud absurda (range check) | DQ validity/range: alertar; no rompe el pipeline |
| null_mandatory | VBAP | VBELN=4500000203 POSNR=000050 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| amount_outlier | VBAP | VBELN=4500000212 POSNR=000030 | NETWR con magnitud absurda (range check) | DQ validity/range: alertar; no rompe el pipeline |
| leading_zero_inconsistency | VBAP | VBELN=4500000223 POSNR=000060 | MATNR sin ceros a la izquierda ('10148') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| null_mandatory | VBAP | VBELN=4500000232 POSNR=000020 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000252 POSNR=000030 | MATNR sin ceros a la izquierda ('10018') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000255 POSNR=000020 | MATNR sin ceros a la izquierda ('10100') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000294 POSNR=000010 | MATNR sin ceros a la izquierda ('10046') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| null_mandatory | VBAP | VBELN=4500000350 POSNR=000010 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000365 POSNR=000040 | MATNR sin ceros a la izquierda ('10066') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000369 POSNR=000020 | MATNR sin ceros a la izquierda ('10106') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| referential_orphan | VBAP | VBELN=4500000395 POSNR=000040 MATNR=000000000008881427 | MATNR no existe en MARA | FK material falla; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000401 POSNR=000020 | MATNR sin ceros a la izquierda ('10125') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000484 POSNR=000050 | MATNR sin ceros a la izquierda ('10073') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000521 POSNR=000060 | MATNR sin ceros a la izquierda ('10005') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000607 POSNR=000030 | MATNR sin ceros a la izquierda ('10124') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| referential_orphan | VBAP | VBELN=4500000608 POSNR=000010 MATNR=000000000008882184 | MATNR no existe en MARA | FK material falla; cuarentena |
| referential_orphan | VBAP | VBELN=4500000617 POSNR=000010 MATNR=000000000008882212 | MATNR no existe en MARA | FK material falla; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000660 POSNR=000010 | MATNR sin ceros a la izquierda ('10057') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| amount_outlier | VBAP | VBELN=4500000663 POSNR=000010 | NETWR con magnitud absurda (range check) | DQ validity/range: alertar; no rompe el pipeline |
| leading_zero_inconsistency | VBAP | VBELN=4500000672 POSNR=000030 | MATNR sin ceros a la izquierda ('10028') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| referential_orphan | VBAP | VBELN=4500000692 POSNR=000010 MATNR=000000000008882465 | MATNR no existe en MARA | FK material falla; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000749 POSNR=000010 | MATNR sin ceros a la izquierda ('10012') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000763 POSNR=000020 | MATNR sin ceros a la izquierda ('10107') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000772 POSNR=000040 | MATNR sin ceros a la izquierda ('10124') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| amount_outlier | VBAP | VBELN=4500000822 POSNR=000040 | NETWR con magnitud absurda (range check) | DQ validity/range: alertar; no rompe el pipeline |
| leading_zero_inconsistency | VBAP | VBELN=4500000886 POSNR=000050 | MATNR sin ceros a la izquierda ('10037') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| leading_zero_inconsistency | VBAP | VBELN=4500000890 POSNR=000030 | MATNR sin ceros a la izquierda ('10021') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| null_mandatory | VBAP | VBELN=4500000893 POSNR=000020 | NETWR vacio (obligatorio) | DQ completeness; cuarentena |
| referential_orphan | VBAP | VBELN=4500000901 POSNR=000020 MATNR=000000000008883192 | MATNR no existe en MARA | FK material falla; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000951 POSNR=000020 | MATNR sin ceros a la izquierda ('10108') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| referential_orphan | VBAP | VBELN=4500000977 POSNR=000010 MATNR=000000000008883459 | MATNR no existe en MARA | FK material falla; cuarentena |
| leading_zero_inconsistency | VBAP | VBELN=4500000990 POSNR=000020 | MATNR sin ceros a la izquierda ('10144') | Aplicar ALPHA antes del join; NO es huerfano (resuelve tras conversion) |
| duplicate_key | VBAP | VBELN=4500000372 POSNR=000020 | Clave (MANDT,VBELN,POSNR) duplicada con valor distinto | Dedup determinista por clave + regla de supervivencia (first/max) |
| duplicate_key | VBAP | VBELN=4500000359 POSNR=000020 | Clave (MANDT,VBELN,POSNR) duplicada con valor distinto | Dedup determinista por clave + regla de supervivencia (first/max) |
| duplicate_key | VBAP | VBELN=4500000261 POSNR=000020 | Clave (MANDT,VBELN,POSNR) duplicada con valor distinto | Dedup determinista por clave + regla de supervivencia (first/max) |
| duplicate_key | VBAP | VBELN=4500000754 POSNR=000020 | Clave (MANDT,VBELN,POSNR) duplicada con valor distinto | Dedup determinista por clave + regla de supervivencia (first/max) |
| duplicate_key | VBAP | VBELN=4500000235 POSNR=000030 | Clave (MANDT,VBELN,POSNR) duplicada con valor distinto | Dedup determinista por clave + regla de supervivencia (first/max) |
| referential_orphan | VBAP | VBELN=7770000000 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000001 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000002 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000003 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000004 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000005 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000006 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000007 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000008 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000009 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000010 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |
| referential_orphan | VBAP | VBELN=7770000011 POSNR=000010 | VBELN no existe en VBAK (item huerfano) | FK order falla; cuarentena |

# Ground Truth - Data Lineage (columna a columna)

> source SAP -> bronze (1:1) -> silver (conformado) -> gold (dimensional)

## Customer
| SAP (KNA1) | Bronze | Silver (customer) | Gold (dim_customer) |
|---|---|---|---|
| KUNNR | kna1.KUNNR (STRING) | customer_id = ALPHA_strip(KUNNR) | dim_customer.customer_id |
| NAME1 | kna1.NAME1 | name | name |
| LAND1 | kna1.LAND1 | country | country |
| ORT01 | kna1.ORT01 | city | city |
| PSTLZ | kna1.PSTLZ | postal_code | - |
| ERDAT | kna1.ERDAT (STRING) | created_date = DATS_to_DATE(ERDAT) | - |
| LOEKZ | kna1.LOEKZ | (filtro: LOEKZ='X' excluido) | - |

## Material
| SAP (MARA/MAKT) | Bronze | Silver (material) | Gold (dim_material) |
|---|---|---|---|
| MARA.MATNR | mara.MATNR | material_id = ALPHA_strip(MATNR) | dim_material.material_id |
| MARA.MTART | mara.MTART | material_type | material_type |
| MARA.MATKL | mara.MATKL | material_group | material_group |
| MARA.MEINS | mara.MEINS | base_uom | - |
| MAKT.MAKTX (SPRAS='S') | makt.MAKTX | description (idioma canonico S) | description |
| MARA.LVORM | mara.LVORM | (filtro: LVORM='X' excluido) | - |

## Sales Order Header
| SAP (VBAK) | Bronze | Silver (sales_order_header) | Gold |
|---|---|---|---|
| VBELN | vbak.VBELN | order_id | fact.order_id |
| ERDAT | vbak.ERDAT | order_date = DATS_to_DATE | fact.order_date |
| KUNNR | vbak.KUNNR | customer_id (FK validada) | -> dim_customer.customer_sk |
| NETWR | vbak.NETWR | net_amount = NETWR/10^TCURX(WAERK) | - |
| WAERK | vbak.WAERK | currency | fact.currency |

## Sales Order Item
| SAP (VBAP) | Bronze | Silver (sales_order_item) | Gold (fact_sales_order_item) |
|---|---|---|---|
| VBELN+POSNR | vbap.* | order_id+item_no (dedup) | fact grain |
| MATNR | vbap.MATNR | material_id = ALPHA_strip(MATNR), FK | -> dim_material.material_sk |
| KWMENG | vbap.KWMENG | quantity | quantity |
| NETWR | vbap.NETWR | net_amount = NETWR/10^TCURX(WAERK) | net_amount |
| WAERK | vbap.WAERK | currency | currency |

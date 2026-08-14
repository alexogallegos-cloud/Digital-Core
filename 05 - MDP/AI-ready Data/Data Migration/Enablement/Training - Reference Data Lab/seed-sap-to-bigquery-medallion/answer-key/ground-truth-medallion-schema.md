# Ground Truth - Medallion Schema

> Resumen por capa. DDL ejecutable BigQuery en `../target-ddl/`.

## Bronze (sap_bronze) - raw 1:1, todo STRING
kna1 · mara · makt · tcurx · vbak · vbap (mismas columnas que la fuente)
+ metadata tecnica: `_ingest_ts TIMESTAMP`, `_source_system STRING`, `_batch_id STRING`.
Conserva LOEKZ/LVORM/MANDT y strings crudos. Conteo = fuente.

## Silver (sap_silver) - conformado, tipado, deduplicado, FK validadas
- customer(customer_id, name, country, city, postal_code, account_group, created_date DATE)
- material(material_id, material_type, material_group, base_uom, description, created_date DATE)
- sales_order_header(order_id, order_date DATE, customer_id, net_amount NUMERIC, currency, sales_org, order_type)
- sales_order_item(order_id, item_no, material_id, quantity NUMERIC, uom, net_amount NUMERIC, currency)
- _quarantine(source_table, business_key, reason, raw, _quarantined_ts)

## Gold (sap_gold) - dimensional + agregados
- dim_customer(customer_sk, customer_id, name, country, city)
- dim_material(material_sk, material_id, description, material_type, material_group)
- fact_sales_order_item(order_id, item_no, customer_sk, material_sk, order_date, quantity, net_amount, currency)
- agg_sales_by_customer_month(customer_id, year_month, currency, order_count, total_net_amount)

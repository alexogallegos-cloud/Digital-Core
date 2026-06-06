# Reference Solution (dbt) - seed-sap-banking-crm-to-bigquery-medallion

> **Solucion de referencia**, NO se entrega en un test ciego (igual que `answer-key/`).
> Implementa el medallion Bronze->Silver->Gold + entity resolution SAP<->CRM como una
> realizacion correcta del pipeline de migracion. Dialecto: **BigQuery**.
> `[NO-EJECUTADO-AQUI]` No se corrio en este entorno (requiere proyecto GCP + credenciales).
> Los generadores del seed SI se ejecutaron; este dbt es la solucion de referencia para
> validar contra el answer key.

## Que demuestra
- **REGLA-01..10** del answer key (`../answer-key/ground-truth-transformation-rules.md`)
  como macros + modelos: DATS->DATE, ALPHA_strip, CURR/TCURX, filter_deleted, dedup,
  FK_quarantine, crm_country_map, email_validate, **entity_resolution**, master_merge.
- **El doble revelador**: (1) `int_entity_resolution` reconstruye el crosswalk SAP<->CRM
  (exact_ref + fuzzy por nombre normalizado+pais) -> comparar vs `../answer-key/crosswalk-truth.csv`;
  (2) `silver_transaction` aplica TCURX por moneda -> `tests/assert_currency_decimals_applied.sql`
  caza la trampa JPY/CLP.

## Estructura
```
models/
  silver/        silver_party . silver_account . silver_transaction . silver_loan . silver_crm_account
  intermediate/  int_entity_resolution      <- el crosswalk
  gold/          dim_customer (mastereado) . dim_account . fact_transaction . fact_loan . agg_customer_balance
macros/          dats_to_date . alpha_strip . norm_name . crm_country_iso
tests/           reconciliacion (count dim_customer) . no orphans . decimales por moneda
```

## Como correr (BigQuery)
1. `cp profiles.example.yml ~/.dbt/profiles.yml` y completar `project`.
2. `dbt deps`     (instala dbt_utils)
3. `dbt seed`     (carga ../source/{sap,crm} como Bronze, STRING via seeds_properties.yml)
4. `dbt run`      (silver + gold)
5. `dbt test`     (DQ + reconciliacion)

## Scoring del entity resolution
Comparar `int_entity_resolution` (output) vs `../answer-key/crosswalk-truth.csv` (verdad):
precision/recall por match_type. El reference resuelve exact_ref al 100% y fuzzy al nivel
que permita `norm_name`; los no resueltos son el gap real que un proyecto cerraria con
matching probabilistico/ML.

## Dialecto
Target BigQuery (el caso). Para correr local sin GCP, adaptar a dbt-duckdb: reemplazar
normalize(x, NFD)/r'\\pM', safe.parse_date, pow, array_agg/[] por equivalentes DuckDB.

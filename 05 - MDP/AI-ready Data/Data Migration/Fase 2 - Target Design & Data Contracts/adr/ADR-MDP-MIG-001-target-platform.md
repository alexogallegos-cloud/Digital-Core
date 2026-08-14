# ADR-MDP-MIG-001 — Plataforma target

- Estado: ACEPTADO
- Fecha: 2026-06-01

## Contexto
Migración de un core bancario sobre SAP (BP/FS-AM/FS-CML/FI-GL/...) + CRM a una plataforma
de datos cloud para AI/BI. Target candidato: BigQuery, Databricks, Snowflake.

## Decisión
**GCP BigQuery con modelo medallion (Bronze/Silver/Gold).** Datasets `bank_bronze/silver/gold`.

## Razones
- Caso GCP-native; serverless, separación storage/compute, particionado/clustering nativo.
- Medallion separa ingestión cruda (auditable) de la conformación y del consumo.

## Consecuencias
- Conversión de montos vía TCURX en Silver (BigQuery NUMERIC).
- `[TS&T-PRECEDENCE]` cambio de plataforma requiere endorsement TS&T (ADR-MDP-001 del offering).

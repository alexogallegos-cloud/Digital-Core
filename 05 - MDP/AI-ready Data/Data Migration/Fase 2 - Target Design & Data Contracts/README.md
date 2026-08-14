# Fase 2 - Target Design & Data Contracts

> Fase del sub-offering **Data Migration** (offering domain AI-ready Data). Fuente de verdad: el `CLAUDE.md` del sub-offering (seccion "Fases de la Migracion"). Esta carpeta es el contenedor orquestador de la fase; el delivery lo ejecuta el SME via `[INVOKE]`.

| Campo | Valor |
|-------|-------|
| Mapea a (DataOps) | DESIGN |
| Objetivo | Modelo medallion target (Bronze/Silver/Gold) + ADRs (plataforma, patron) + data contracts. |
| Gate de salida | Target schema + ADR-MDP-MIG + contracts versionados. |
| Ejecuta (`[INVOKE]`) | Data Architect, Cloud sub-SME |

## Entregable

**Target Design & Data Contracts**: `artifacts/target-model.md` (medallion Bronze/Silver/Gold por dominio) + `data-contracts/*.yaml` (5 data products: customer, account, transaction, loan, crm_opportunity — cada uno con schema, owner, SLA, DQ, lineage, PII, consumers) + `adr/*.md` (4 ADRs: plataforma BigQuery, patrón bulk+CDC wave-based, entity resolution SAP↔CRM, PII/retención) + `target-design.html` (deliverable).

El contrato `customer` es dueño de la regla de **entity resolution** y es prerequisito de los demás. Handoff a Fase 3 (Mapping & Transformation Rules), que produce el mapping columna-a-columna + reglas ejecutables (el `reference-solution-dbt` del lab ya las implementa como referencia).

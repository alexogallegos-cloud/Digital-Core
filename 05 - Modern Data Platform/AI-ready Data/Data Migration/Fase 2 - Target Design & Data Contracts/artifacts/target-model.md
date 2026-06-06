# Target Model — Medallion (BigQuery) · Core Bancario SAP + CRM

> Fase 2 · Data Migration · diseño del modelo target a partir del discovery (Fase 1) y del
> modelo de referencia validado por el SME SAP Banking Services.

## Capas

| Capa | Dataset | Contenido | Reglas |
|------|---------|-----------|--------|
| Bronze | `bank_bronze` | Réplica raw 1:1 de cada tabla fuente (SAP + CRM), todo STRING + metadata técnica (`_ingest_ts`, `_source_system`) | ninguna (espejo fiel); conserva flags de borrado, MANDT |
| Silver | `bank_silver` | Entidades de negocio conformadas, tipadas, deduplicadas, FK validadas/cuarentena | DATS→DATE · ALPHA · CURR/TCURX · filter_deleted · dedup · FK_quarantine · country_map |
| Gold | `bank_gold` | Modelo dimensional + Customer 360 mastereado | entity_resolution · master_merge · surrogate keys · agregados |

## Dominios → data products (Gold)

| Dominio | Data product (Gold) | Fuente principal (Silver) | Contrato |
|---------|---------------------|---------------------------|----------|
| Customer | `dim_customer` | party (BUT000) + crm_account | `data-contracts/customer.yaml` |
| Account | `dim_account` | account (BKK40/BKKIT family) | `data-contracts/account.yaml` |
| Transaction | `fact_transaction` | transaction (BKKIT) | `data-contracts/transaction.yaml` |
| Loan | `fact_loan` | loan (VDARL) | `data-contracts/loan.yaml` |
| Commercial | `fact_crm_opportunity` | crm_opportunity | `data-contracts/crm-opportunity.yaml` |

## Orden de construcción (wave plan de Fase 1)
Wave 0 Foundation (customizing + GL + Business Partner + mastering CRM) → Wave 1 cuentas/productos
→ Wave 2 transaccional/pagos → Wave 3 canales/satélites. El dominio Customer (mastering) es
prerequisito de todo lo demás (hub BUT000, fan-in máximo).

## ADRs
- `adr/ADR-MDP-MIG-001-target-platform.md` — BigQuery medallion
- `adr/ADR-MDP-MIG-002-migration-pattern.md` — bulk + CDC, wave-based
- `adr/ADR-MDP-MIG-003-entity-resolution.md` — estándar de resolución de entidad SAP↔CRM
- `adr/ADR-MDP-MIG-004-pii-handling.md` — PII + retención regulatoria

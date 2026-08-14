# Fase 3 - Mapping & Transformation Rules

> Fase del sub-offering **Data Migration** (offering domain AI-ready Data). Fuente de verdad: el `CLAUDE.md` del sub-offering (seccion "Fases de la Migracion"). Esta carpeta es el contenedor orquestador de la fase; el delivery lo ejecuta el SME via `[INVOKE]`.

| Campo | Valor |
|-------|-------|
| Mapea a (DataOps) | DESIGN->BUILD |
| Objetivo | Lineage columna-a-columna + reglas (DATS, CURR/TCURX, ALPHA, dedup, entity resolution) + diseno DQ. |
| Gate de salida | Mapping doc + reglas + plan DQ aprobados. |
| Ejecuta (`[INVOKE]`) | Data & ML SME, Specialist - Legacy Datastore Migration |

## Entregable

**Mapping & Transformation Rules**: `artifacts/transformation-rules-catalog.md` (10 reglas REGLA-01..10, cada una con su implementación en `reference-solution-dbt`) + `artifacts/stm/mapping-*.md` (source-to-target columna-a-columna por data product, con la regla atada a cada columna) + `mapping.html` (deliverable).

Priorizado por wave (del Discover): **W0 customer** (fundación + entity resolution) primero — todo depende de su `customer_sk` — luego account (W1/W2), transaction/loan (W2), crm_opportunity (W3). Las reglas ya están implementadas en el `reference-solution-dbt`. Handoff a Fase 4 (Ingest & Bronze): cargar fuentes 1:1 a Bronze empezando por W0; las reglas se aplican en Silver (Fase 5).

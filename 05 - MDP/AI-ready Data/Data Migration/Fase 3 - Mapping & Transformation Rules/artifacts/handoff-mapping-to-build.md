# Handoff: Fase 3 Mapping → Fase 4 Ingest & Bronze

- **Mapping columna-a-columna** de los 5 data products (`stm/mapping-*.md`), con la regla atada a cada columna.
- **Catálogo de reglas** (`transformation-rules-catalog.md`) — ya implementadas en `reference-solution-dbt`.
- **Orden por wave**: W0 customer (fundación + entity resolution) primero; luego account (W1/W2), transaction/loan (W2), crm_opportunity (W3).

**Para Fase 4 (Ingest & Bronze):** cargar las fuentes 1:1 a Bronze (STRING, preservando ALPHA), empezando por las tablas de W0 (T001, monedas, GL, BUT000) + CRM. CDC para coexistencia. Las reglas se aplican en Silver (Fase 5).

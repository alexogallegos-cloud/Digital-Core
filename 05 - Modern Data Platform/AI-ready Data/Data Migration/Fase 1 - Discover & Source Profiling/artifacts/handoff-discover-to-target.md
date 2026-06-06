# Handoff: Fase 1 Discover -> Fase 2 Target Design & Data Contracts

> Qué se entrega a la siguiente fase.

- **Inventario perfilado** (`source-inventory.md` + `profiling-report.md`): 9 tablas, 2 sistemas.
- **Dependency graph** (`dependency-graph.json`, renderizable): FK + entity-link cross-system.
- **DQ baseline** (`dq-baseline.md`): 15 huerfanos bkkit, 8 dups, 8 fechas invalidas, 25 flags borrado, 530 filas trampa-moneda, 204 filas pais no-ISO.
- **Entity coupling** (`entity-coupling.md`): cliente requiere MDM (275 CRM, 116 con ref, 159 fuzzy).
- **Disposiciones** (`dispositions.md`) + **Wave plan** (`wave-plan.md`).

**Para Fase 2:** diseñar el medallion target + data contracts por dominio; el contrato de `customer` debe incluir la regla de entity resolution. ADR de plataforma (BigQuery) + patron (bulk + CDC). PII: BUT000/crm requieren clasificacion (Cybersecurity Data Security).

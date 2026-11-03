# Catálogo de fuentes — instancia de prueba

Catálogo mínimo para la suite del pipeline. Tiene la misma forma que la tabla
de instancia de `knowledge-base/source-catalog.md`, porque el parser del
catálogo se prueba contra la forma real y no contra una simplificada.

## Catálogo de la instancia

| id | Fuente | Tipo | Generador | Cadencia | Estado | Tier | Cobertura | Última carga | Habilita |
|----|--------|------|-----------|----------|--------|------|-----------|--------------|----------|
| SRC-001 | Informe anual ficticio 2025 | doc_tecnico | parser | batch | activa | silver | 40 | 2026-11-03 | Etapa 0 — Identidad |
| SRC-002 | Informe anual sin calificar | doc | parser | batch | activa | bronze | 40 | 2026-11-03 | Etapa 0 — Identidad |
| SRC-003 | Minutas del comité | minuta | parser | batch | parcial | bronze | 10 | 2026-11-03 | Retos no publicados |
| SRC-004 | Logs del core | logs | connector | continuo | ausente | gold | 0 | | Comportamiento en operación |

# DT Integración Semántica — Digital Twin
> Ontología OWL 2 DL · Motor de gobierno de APIs · Diferenciador del engagement

## Pregunta Central
¿Qué APIs están gobernadas por la ontología OWL y cuáles quedan fuera del grafo?

## El Diferenciador

Este DT es el corazón del win theme "El Digital Brain de MONEX":
un grafo semántico evaluable en producción que responde preguntas que hoy
requieren semanas de análisis manual.

## Preguntas que el grafo responde (queries del Integration Committee)

1. `¿Qué flujos quedan en incumplimiento si cambias el schema ISO 20022?`
2. `¿Qué APIs del catálogo MuleSoft no tienen contrato OpenAPI declarado?`
3. `¿Qué sistemas no tienen trazabilidad regulatoria mapeada?`
4. `¿Cuántas APIs consumen datos del Golden Record vs fuentes locales?`
5. `¿Qué cambio en una API de FX impacta a qué reportes de Banxico?`

## Estado Actual del Catálogo (AS-IS)

| Dimensión | Estado | Gap |
|-----------|--------|-----|
| APIs inventariadas en MuleSoft | DATO-REQUERIDO | Número exacto desconocido |
| APIs con OpenAPI contract | DATO-REQUERIDO | % sin contrato desconocido |
| APIs con trazabilidad regulatoria | DATO-REQUERIDO | Estimado: mayoría sin mapeo |
| Vocabulario canónico cross-API | No existe | CRÍTICO — cada API usa sus propios nombres |

## Nodos OWL por Sistema

| Sistema | Clase OWL principal |
|---------|---------------------|
| `mulesoft` | `IntegrationAPI`, `APIContract` |
| `payments-legacy` | `PaymentInstruction`, `PaymentFlow` |
| `fx-engine` | `FXTransaction`, `FXRate` |
| `golden-record-target` | `GoldenRecord`, `MasterDataDomain` |
| `cnbv-banxico` | `RegulatoryReport`, `RegulatoryObligation` |

## Pendientes (DATO-REQUERIDO)
- [ ] Exportar inventario de APIs desde MuleSoft Anypoint
- [ ] Identificar APIs con OpenAPI spec existente
- [ ] Mapear regulación → API → sistema para cada obligación DIOR/CNBV

---
*v1.0 · 2026-09-22 · Scaffold*

# Landscape Regulatorio — MONEX Grupo Financiero

## Reguladores por Jurisdicción

| Jurisdicción | Regulador | Tipo de entidad MONEX | Obligaciones clave |
|-------------|-----------|----------------------|-------------------|
| México | CNBV | Casa de Bolsa | Reportes periódicos · capital mínimo · conducta de mercado |
| México | Banxico | Participante SPEI | SPEI · DIOR · reservas |
| México | CONDUSEF | — | Protección al usuario de servicios financieros |
| México | UIF/GAFI | — | AML/PLD · reporte de operaciones inusuales |
| USA | FinCEN | Empresa de transferencia (no bancaria) | AML · MSB registration · reporting |
| USA | OCC/Fed | Corresponsalía | Acuerdos de corresponsalía |
| UK | FCA | Payment Institution (no bancaria) | PSD2 · EMD · AML · Operational Resilience |
| EU (por UK) | DORA | Entidad financiera | Digital Operational Resilience Act 2025 |
| Global | CLS | Participante (objetivo) | CLS Settlement rules · PvP protocol |
| Global | SWIFT | Participante SWIFT | SWIFT Customer Security Programme (CSP) |

## Obligaciones Regulatorias por Sistema (mapeo preliminar)

| Obligación | Sistema fuente | Regulador | Frecuencia |
|------------|---------------|-----------|-----------|
| DIOR — pagos > USD 10K | payments-legacy, swift | Banxico | Por evento |
| Reporte SPEI | spei | Banxico | Diario |
| Reporte de operaciones inusuales | fx-engine, payments-legacy | UIF | Por evento |
| Capital mínimo | treasury | CNBV | Diario |
| CMIR — Cash / Monetary Instruments Report | payments-legacy | FinCEN | Por evento (>USD 10K) |
| DORA — resiliencia operacional | todos | FCA / reguladores EU | Anual + incidentes |
| SWIFT CSP — Customer Security Programme | swift | SWIFT | Anual |
| AML screening contrapartes | fx-engine, cnbv-banxico | UIF/FinCEN/FCA | En tiempo real |

## Gaps Regulatorios Confirmados

| Gap | Riesgo | Impacto |
|----|--------|---------|
| Sin Data Catalog/MDM — datos dispersos | ALTO — imposible responder "dame todos los pagos de esta contraparte" cross-sistema | DIOR, AML, CNBV |
| Sin CLS — liquidación bilateral | MEDIO — riesgo de contraparte en FX; objetivo 2030 | Operacional |
| DORA compliance UK — evaluación pendiente | ALTO — DORA entró en vigor ene-2025 | FCA |

---

*Última actualización: 2026-09-22 · v1.0 · Seed inicial — validar con equipo legal/compliance MONEX*

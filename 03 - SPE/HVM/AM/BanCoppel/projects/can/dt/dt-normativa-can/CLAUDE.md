# DT — Normativa CAN (Créditos Asociados a Nómina)
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Lee y estructura la normativa Banxico sobre Créditos Asociados a Nómina (CAN).
Produce el catálogo de obligaciones, definiciones y plazos que alimentan el análisis de brecha.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Interpretación de circulares + alcance regulatorio |
| Industry Banking | Contexto de producto bancario (créditos de nómina) |
| Industry Banking Accounting | Implicaciones contables CNBV (CUB, Serie R) |

## Inputs Esperados

1. Circular(es) Banxico sobre CAN — cargar en `source/docs/regulacion/`
2. Definición de productos BanCoppel en scope
3. Glosario de términos legales

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Obligaciones estructuradas | `knowledge-base/regulacion/obligaciones-can.md` |
| Glosario regulatorio | `knowledge-base/regulacion/glosario-can.md` |
| Resumen ejecutivo normativa | `knowledge-base/regulacion/circular-banxico-can.md` |
| `regulatory_obligations` | Filas en brain.db del proyecto CAN |

## Metodología

1. Leer la circular Banxico CAN completa desde `source/docs/regulacion/`
2. Extraer artículo por artículo: obligación → tipo → frecuencia → plazo → penalidad
3. Clasificar obligaciones por: reporte | control | límite | disclosure | certificación | autorización
4. Generar glosario de términos definidos en la normativa
5. Producir resumen ejecutivo con mapa de obligaciones

## Estado

`[DATO-REQUERIDO]` — Pendiente carga de documentos regulatorios en `source/docs/regulacion/`.

*v0.1.0 · 2026-09-16*

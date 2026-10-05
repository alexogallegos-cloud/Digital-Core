# DT — Normativa CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Estructurar la normativa Banxico sobre Créditos Asociados a Nómina (CAN) en el contexto de
Santander México. Produce el catálogo de obligaciones, definiciones y plazos que alimentan
el análisis de brecha.

> **Atajo regulatorio:** Las 23 obligaciones ya fueron catalogadas para BanCoppel (IBM sujeto
> al mismo marco). Reutilizar como punto de partida desde:
> `../../../../BanCoppel/projects/can/knowledge-base/regulacion/obligaciones-can.md`
>
> Lo que se adapta aquí: contexto Santander (productos, volúmenes, relevancia por obligación).

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Interpretación de circulares + alcance regulatorio |
| Industry Banking | Contexto de producto bancario (crédito de nómina Santander) |
| Industry Banking Accounting | Implicaciones contables CNBV (CUB Serie R, IFRS 9) |

## Artículos Clave (mismo para todos los IBMs)

| Artículo | Descripción |
|----------|-------------|
| Art. 63 Bis 3 | Mecanismo CAN — hub interbancario para portabilidad del domicilio del crédito |
| Art. 81 Bis 1 | Servicio de Nómina Interbancaria — portabilidad de nómina |
| Art. 81 Bis 2 | Obligaciones Institución Ordenante y Receptora en portabilidad |
| Circular 14/2017 | SPEI — OBL-006 (liquidación en refinanciamiento) + OBL-009 (Clave Básica Estandarizada) |

## Inputs Esperados

1. Circular(es) Banxico CAN — cargar en `source/docs/regulacion/`
2. 23 obligaciones BanCoppel (referencia cross-cliente)
3. Definición de productos Santander en scope

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Obligaciones adaptadas Santander | `knowledge-base/regulacion/obligaciones-can.md` |
| Glosario regulatorio | `knowledge-base/regulacion/glosario-can.md` |
| Resumen ejecutivo | `knowledge-base/regulacion/circular-banxico-can.md` |

## Metodología

1. Cargar el catálogo de 23 obligaciones de BanCoppel como base
2. Verificar si hay actualizaciones de la circular desde la versión BanCoppel
3. Contextualizar cada obligación con los productos y sistemas Santander
4. Añadir notas de relevancia: ¿cuál es el impacto potencial para Santander vs. BanCoppel?
5. Producir resumen ejecutivo adaptado

## Estado

`[DATO-REQUERIDO]` — Cargar documentos en `source/docs/regulacion/`. Como atajo, consultar
`BanCoppel/projects/can/knowledge-base/regulacion/` para las 23 obligaciones base.

*v0.1.0 · 2026-09-17*

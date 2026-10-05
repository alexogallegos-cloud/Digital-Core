# DT — Nómina Interbancaria · Santander México
> **Proyecto:** CAN · Santander México
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Analiza los artículos 81 Bis 1 y 81 Bis 2 de la normativa CAN: Servicio de Nómina
Interbancaria — portabilidad de nómina entre IBMs. Documenta las obligaciones de
Santander como Institución Ordenante y como Institución Receptora.

> **REUTILIZABLE:** El marco regulatorio Art. 81 Bis 1 y 81 Bis 2 es idéntico para todos
> los IBMs. Reutilizar análisis de BanCoppel como referencia.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Interpretación de Art. 81 Bis 1 y 81 Bis 2 |
| Industry Banking | Contexto de producto nómina bancario Santander |
| Industry Payments → SPEI | Liquidación interbancaria de nómina vía SPEI |

## Marco Regulatorio

### Art. 81 Bis 1 — Servicio de Nómina Interbancaria

Establece que los IBMs que ofrecen cuentas de nómina deben:
- Permitir que el trabajador cambie la institución donde recibe su nómina
- Procesar la solicitud de portabilidad en plazos definidos por Banxico
- Coordinar con la institución ordenante y receptora vía el Mecanismo CAN

### Art. 81 Bis 2 — Obligaciones Específicas

| Rol | Obligaciones clave |
|-----|-------------------|
| **Institución Ordenante** (paga nómina) | Notificar al patrón del cambio de cuenta · Ejecutar pago en cuenta nueva dentro de plazo · No cobrar comisiones por portabilidad |
| **Institución Receptora** (recibe nómina) | Abrir cuenta en plazo regulatorio · Confirmar recepción al hub Banxico · Notificar al trabajador |

## Escenarios Santander

| Escenario | Rol Santander | Sistemas involucrados |
|-----------|--------------|----------------------|
| Cliente Santander porta su nómina A OTRO banco | Ordenante → cede | `core-banking` · `payments-engine` · call-center |
| Cliente de OTRO banco porta su nómina A Santander | Receptora → recibe | `core-banking` · supermovil · call-center |
| Cliente Santander con crédito de nómina porta a otro banco | Originadora + Ordenante | `loans` · `core-banking` · `payments-engine` |

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Obligaciones Art. 81 Bis 1 y 81 Bis 2 | `knowledge-base/regulacion/nomina-interbancaria.md` |
| Flujo de portabilidad Santander | `knowledge-base/rules/flujo-portabilidad-nomina.md` |
| User Stories de portabilidad | → alimenta dt-roadmap-cambios |

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]`
- `[DATO-REQUERIDO]` — Confirmar escenarios con equipo de producto Santander (¿cuántos clientes tienen nómina domiciliada?)

*v0.1.0 · 2026-09-17*

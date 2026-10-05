# DT — Documento Estándar CAN (DE CAN) · Santander México
> **Proyecto:** CAN · Santander México
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Lee y estructura el DE CAN v4.2 (Documento Estándar del Mecanismo CAN): especificaciones
técnicas del Mecanismo Art. 63 Bis 3, catálogo de campos, flujos de mensajes interbancarios.

> **REUTILIZABLE:** El DE CAN es emitido por Banxico y aplica **idéntico** a todos los IBMs.
> Si BanCoppel ya lo estructuró, reutilizar directamente. El Mecanismo es infraestructura
> Banxico, no de Santander — solo cambia cómo Santander conecta a él.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Framework — Integration Architecture | Diseño de la integración Santander → Mecanismo CAN |
| Industry Payments → SPEI | OBL-006 + OBL-009 + timing Banxico |
| Regulatory/Banxico | Interpretación técnica del DE CAN |

## Mecanismo Art. 63 Bis 3 — Resumen

El Mecanismo CAN es un **hub centralizado de Banxico** que:

1. Recibe la solicitud de portabilidad del domicilio del crédito del acreditado
2. Notifica a la institución ordenante (banco que paga la nómina)
3. Notifica a la institución receptora (banco donde el acreditado quiere cobrar)
4. Orquesta el cambio de domicilio de manera interbancaria estandarizada
5. Genera trazabilidad regulatoria del cambio

## Rol de Santander en el Mecanismo

Santander puede ser:

| Rol | Cuándo | Obligaciones |
|-----|--------|-------------|
| **Institución Originadora** | Santander es el banco que otorgó el crédito de nómina | Recibir solicitud de portabilidad · Procesar cambio · Reportar a Banxico |
| **Institución Ordenante** | Santander paga la nómina del acreditado | Ejecutar deducción en cuenta nueva · Respetar prelación |
| **Institución Receptora** | Santander recibe la cuenta de nómina | Procesar la nómina portada · Notificar al hub |

> En la mayoría de los casos, Santander actuará como **Institución Originadora y Ordenante** simultáneamente (cuando otorgó el crédito y también paga la nómina).

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Spec técnica DE CAN | `knowledge-base/regulacion/de-can-spec.md` |
| Catálogo de campos y mensajes | `knowledge-base/regulacion/de-can-campos.md` |
| Flujo de integración Santander → Hub | `knowledge-base/regulacion/flujo-mecanismo-can.md` |

## Dependencias

- `[DATO-REQUERIDO]` — Cargar DE CAN v4.2 en `source/docs/regulacion/`
- Referencia: `../../../../BanCoppel/projects/can/dt/dt-de-can/` (si ya está estructurado)

*v0.1.0 · 2026-09-17*

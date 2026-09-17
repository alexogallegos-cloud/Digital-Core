# DT — Roadmap de Cambios CAN
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Traduce las brechas de compliance CAN en requerimientos técnicos, User Stories y
un roadmap priorizado de implementación. Estima esfuerzo por sistema y genera
el input para el DoR de cada cambio técnico.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Core Banking Transformation | Diseño de cambios en el core (Informix + posible Unity) |
| Software Engineering | Estimación de esfuerzo técnico de implementación |
| IT Operating Model | Impacto en procesos operativos, CTM, monitoreo |
| Framework — Integration Architecture | Diseño del Mecanismo Art. 63 Bis 3 — hub interbancario CAN (el cambio más complejo del roadmap) |

## Inputs Esperados

1. `knowledge-base/rules/brechas-can.md` — de dt-brecha-compliance
2. Architecture decision sobre sistema target (Informix vs Unity)

## Outputs

| Artefacto | Ruta |
|-----------|------|
| User Stories CAN | `knowledge-base/rules/user-stories-can.md` |
| Roadmap de implementación | `portal/data/roadmap-can.json` |
| ADRs necesarios | `knowledge-base/adr/` |
| Estimaciones de esfuerzo | `knowledge-base/rules/estimaciones-can.md` |

## Formato de User Story CAN

```markdown
## US-CAN-{NNN} — {título}

| Campo | Valor |
|-------|-------|
| Brecha | BRECHA-CAN-{NNN} |
| Sistema target | Informix / Unity / Canal / CTM |
| Tipo de cambio | Nuevo SP / Modificar SP / Nuevo reporte / Nuevo control |
| Criterio de aceptación | {verificable y medible} |
| Esfuerzo estimado | {story points o días} |
| Prioridad | P1-crítico / P2-alto / P3-medio |
| Deadline regulatorio | {fecha límite Banxico} |
| SME ejecutor | {Software Engineering / DBA / etc.} |
```

## Dependencias

- `[DEPENDS-ON: dt-brecha-compliance]` — brechas priorizadas
- `[DECISION: escalado Unity]` — si una brecha requiere capability nueva en Unity/Transact

## Estado

`[DATO-REQUERIDO]` — Pendiente completar los DTs previos.

*v0.1.0 · 2026-09-16*

# DT — Brecha de Compliance CAN
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Gap analysis formal entre las obligaciones regulatorias CAN (Banxico) y las
capacidades actuales de BanCoppel. Produce la lista priorizada de brechas que
alimenta el roadmap de implementación.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Validación de interpretación de obligaciones |
| Industry Banking Accounting | Brechas contables (CUB, Serie R) |
| Cybersecurity | Brechas de seguridad y privacidad (PII nómina) |
| SRE & AIOps | Brechas operativas de timing: OBL-023 (transferencia Prestaciones Laborales ≤ 17:00 DHB) + monitoreo de prelación de cargos OBL-016 |

## Inputs Esperados

1. `knowledge-base/regulacion/obligaciones-can.md` — de dt-normativa-can
2. `knowledge-base/rules/reglas-existentes-can.md` — de dt-impacto-sistemas

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Gap analysis estructurado | `knowledge-base/rules/gap-analysis-can.md` |
| Brechas priorizadas | `knowledge-base/rules/brechas-can.md` |
| Evidencia de cumplimiento parcial | `knowledge-base/rules/cumplimiento-parcial-can.md` |

## Estructura de Brecha

Cada brecha se documenta con:

```markdown
## BRECHA-CAN-{NNN}

| Campo | Valor |
|-------|-------|
| Obligación | {ID de obligación de la circular} |
| Descripción | {qué requiere la norma} |
| Estado actual | CUMPLE / PARCIAL / NO-CUMPLE |
| Evidencia actual | {SP o proceso que atiende parcialmente} |
| Gap | {qué falta exactamente} |
| Criticidad | CRITICA / ALTA / MEDIA / BAJA |
| Impacto si no cumple | {sanción / multa / restricción} |
| Sistema afectado | {Informix · Canales · CTM · Reporting} |
```

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — obligaciones catalogadas
- `[DEPENDS-ON: dt-impacto-sistemas]` — análisis de SPs existentes

## Estado

`[DATO-REQUERIDO]` — Pendiente activación de los DTs previos.

*v0.1.0 · 2026-09-16*

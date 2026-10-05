# DT — Brecha de Compliance CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Gap analysis formal entre las obligaciones regulatorias CAN (Banxico) y las capacidades
actuales de Santander México. Produce la lista priorizada de brechas que alimenta
el roadmap de implementación.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Validación de interpretación de obligaciones |
| Industry Banking Accounting | Brechas contables (CUB Serie R, IFRS 9, provisiones) |
| Cybersecurity | Brechas de seguridad y privacidad (PII datos de nómina) |
| SRE & AIOps | Brechas operativas: OBL-023 (≤ 17:00 DHB) + monitoreo prelación OBL-016 |

## Estructura de Brecha (idéntica a BanCoppel — mismo formato para trazabilidad cross-cliente)

```markdown
## BRECHA-SANT-CAN-{NNN}

| Campo | Valor |
|-------|-------|
| Obligación | {ID de obligación — OBL-001 a OBL-023} |
| Descripción | {qué requiere la norma} |
| Estado actual | CUMPLE / PARCIAL / NO-CUMPLE / DESCONOCIDO |
| Evidencia actual | {sistema o proceso que atiende parcialmente} |
| Gap | {qué falta exactamente en Santander} |
| Criticidad | CRITICA / ALTA / MEDIA / BAJA |
| Impacto si no cumple | {sanción / multa / restricción operativa} |
| Sistema afectado | {loans · core-banking · payments-engine · canales · reporting} |
| Diferencia vs. BanCoppel | {si la brecha es distinta — ej. stack Java vs. SPL} |
```

## Brechas Anticipadas (Hipótesis — SCAFFOLD)

| Brecha anticipada | Criticidad | Sistema | Notas |
|-------------------|-----------|---------|-------|
| Clave Básica Estandarizada (OBL-009) | CRITICA | payments-engine | Requiere generación y transmisión SPEI — confirmar implementación |
| Portabilidad de domicilio Art. 63 Bis 3 | CRITICA | loans · core-banking | Hub interbancario — capacidad nueva probable |
| Prelación de cargos configurable (OBL-016) | ALTA | core-banking | Santander paga primero qué cargo — ¿es configurable? |
| Timing transferencia ≤ 17:00 DHB (OBL-023) | ALTA | payments-engine | Requiere SLA operativo y monitoreo automático |
| Nómina Interbancaria (Art. 81 Bis 1) | ALTA | core-banking · call-center | Portabilidad de nómina entre IBMs |
| Disclosure digital OBL-014 | MEDIA | supermovil · santander-online | Estado del crédito visible en canales digitales |

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Gap analysis completo | `knowledge-base/rules/gap-analysis-can.md` |
| Brechas priorizadas | `knowledge-base/rules/brechas-can.md` |
| Evidencia cumplimiento parcial | `knowledge-base/rules/cumplimiento-parcial-can.md` |

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — 23 obligaciones catalogadas
- `[DEPENDS-ON: dt-impacto-sistemas]` — capacidades Santander vs. obligaciones

*v0.1.0 · 2026-09-17*

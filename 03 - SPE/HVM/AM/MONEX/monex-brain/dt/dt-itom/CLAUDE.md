# DT ITOM — Digital Twin IT Operating Model
> ITOM overlay · 6 dominios operacionales · Gaps de operación MONEX

## Pregunta Central
¿Qué sistemas tienen cobertura operacional real y dónde están los gaps de operación que el programa Apolo debe resolver?

## Rol del DT

El ITOM overlay proyecta el brain MONEX a los 6 dominios del IT Operating Model.
No duplica información — la lee del brain y añade la dimensión "¿cómo se opera?".

## Fuente de conocimiento
- `knowledge-base/itom/itom-model.md` — modelo y mapeo
- `monex-brain.db::itom_layer` — tabla de cobertura por sistema y dominio

## Fases de construcción

| Fase | Descripción | Estado |
|------|-------------|--------|
| Fase 1 | Seed desde estructura TOGAF — inferencia por tipo de sistema | COMPLETO (scaffold) |
| Fase 2 | Entrevistas MONEX TechOps/ITSM — cobertura real verificada | PENDIENTE |
| Fase 3 | Gap analysis → recomendaciones para Plataforma Apolo | PENDIENTE |

## Preguntas que responde

1. ¿Qué sistemas críticos (fx-engine, payments-legacy) tienen observabilidad 24/7 confirmada?
2. ¿Cómo se gestiona actualmente un incidente P1 en payments-legacy?
3. ¿Qué APIs del catálogo MuleSoft tienen SLA operacional declarado?
4. ¿Dónde están los gaps DataOps que bloquean el Golden Record?
5. ¿DORA requiere qué mejoras operacionales en los sistemas UK-facing?

## Impacto en Plataforma Apolo

El ITOM overlay alimenta directamente el diseño de la Plataforma Apolo:
- **TechOps gaps** → qué sistemas necesitan observabilidad nativa en el target
- **DataOps gaps** → prerequisitos del Golden Record
- **SecOps gaps** → requisitos DORA en el diseño de la plataforma

## Pendientes (DATO-REQUERIDO)
- [ ] Herramienta de ITSM actual de MONEX (¿ServiceNow? ¿Jira? ¿custom?)
- [ ] Herramienta de monitoring/APM (¿Datadog? ¿Dynatrace? ¿CloudWatch?)
- [ ] SLAs operacionales de fx-engine y payments-legacy
- [ ] On-call rotation y escalation path actual

---
*v1.0 · 2026-09-22 · Scaffold — DT-ITOM MONEX*

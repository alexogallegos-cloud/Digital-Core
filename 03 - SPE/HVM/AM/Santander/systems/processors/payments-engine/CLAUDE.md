# Payments Engine — Application Modernization Agent
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: payment-processing
# bian_domains: ["payment-initiation", "payment-execution", "payment-order", "funds-transfer"]
# discovered: 2026-09-17 · fuente: hipótesis técnica (banco de escala + SPEI/DiMo obligatorio)

> Motor de pagos Santander México · SPEI · DiMo · CoDi · TEF · SWIFT · Domiciliación
> Agente especializado del sistema. Para vista federada: `../../santander-brain/CLAUDE.md`

---

## IDENTIDAD DEL SISTEMA

| Campo | Valor |
|-------|-------|
| Nombre real | Por confirmar |
| Tipo TOGAF | processors — System of Record (SoR) |
| Estado | Baseline (en producción) |
| Tecnología | Por confirmar |
| Regulación | Banxico Circular SPEI · DiMo · CECOBAN · CNBV |
| SLA regulatorio | SPEI < 30 seg · Disponibilidad 24x7x365 |

---

## DATO-REQUERIDO

> `[DATO-REQUERIDO]` Nombre real, arquitectura y stack del motor de pagos.
> Es el sistema con mayor riesgo regulatorio: latencia o downtime en SPEI/DiMo implica
> sanciones Banxico y CONDUSEF inmediatas.

---

## RIELES PROCESADOS

| Riel | Regulador | Ventanas | Estado |
|------|-----------|---------|--------|
| SPEI | Banxico | 24x7 (ventanas Banxico) | ACTIVO (confirmado sector) |
| DiMo | Banxico | 24x7 | ACTIVO (confirmado sector) |
| CoDi | Banxico | 24x7 | ACTIVO (confirmado sector) |
| TEF (ACH) | CECOBAN | Horarios hábiles | PROBABLE |
| Domiciliación | CECOBAN | Batch nocturno | PROBABLE |
| SWIFT MT/ISO 20022 | SWIFT | 24x7 | PROBABLE (Swift Alliance) |

---

## DEPENDENCIAS

| Sistema | Tipo | Criticidad |
|---------|------|------------|
| Core Banking | reads/writes (debit/credit) | CRÍTICA |
| Card Authorizer | feeds (card txns) | ALTA |
| Banxico SPEI | calls (envío/recepción) | CRÍTICA |
| SuperMóvil | receives calls | ALTA |
| API Gateway | receives calls | ALTA |

---

## PRÓXIMOS PASOS

- [ ] `[DATO-REQUERIDO]` Nombre real y arquitectura
- [ ] Documentar SLA actual por riel (latencia P95, uptime)
- [ ] Mapear ventanas de corte y mantenimiento
- [ ] Identificar puntos de falla y plan de contingencia (regulatorio)
- [ ] Construir `digital-brain/brain.db`

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial*

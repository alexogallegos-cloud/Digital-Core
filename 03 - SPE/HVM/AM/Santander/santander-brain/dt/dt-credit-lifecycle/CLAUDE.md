# dt-credit-lifecycle — Ciclo de Vida del Crédito
> Digital Twin federado · Santander México
> Pregunta rectora: ¿Qué sistemas intervienen en el ciclo de crédito desde solicitud hasta cobranza?

---

## PROPÓSITO

Documentar el flujo completo de crédito (retail + pyme + empresarial): desde la originación
hasta el cierre o recuperación. Identificar sistemas, reglas de negocio, y oportunidades
de automatización con AI/ML.

---

## PRODUCTOS DE CRÉDITO

| Producto | Mercado | Monto típico | Sistemas core |
|----------|---------|-------------|--------------|
| Crédito de nómina | Retail | $10K-$200K MXN | Loans · Core Banking |
| Tarjeta de crédito | Retail | $5K-$300K límite | Card Platform · Loans |
| Crédito hipotecario | Retail | $500K-$10M MXN | Loans · Core Banking |
| Crédito automotriz | Retail | $200K-$800K MXN | Loans · Core Banking |
| Crédito PyME | Pyme | $500K-$5M MXN | Loans · Core Banking |
| Crédito empresarial | Corporativo | $5M+ MXN | Treasury · Loans |

---

## FASES DEL CICLO

| Fase | Sistemas | Estado |
|------|---------|--------|
| Solicitud (digital / sucursal) | SuperMóvil · Santander Online · Core Banking | PENDIENTE |
| Scoring crediticio | Por confirmar (Buró de Crédito + motor ML?) | PENDIENTE |
| Análisis y decisión | Loans · Motor de scoring | PENDIENTE |
| Formalización / firma | Loans · Core Banking · Firma electrónica | PENDIENTE |
| Desembolso | Core Banking · Payments Engine | PENDIENTE |
| Servicio de deuda | Core Banking · Loans · Domiciliación | PENDIENTE |
| Cobranza preventiva | Por confirmar · Call Center | PENDIENTE |
| Cobranza extrajudicial | Por confirmar | PENDIENTE |

---

## REGULACIÓN APLICABLE

| Marco | Descripción |
|-------|-------------|
| CUB Anexo 5 Cartera | Clasificación y provisionamiento de cartera |
| CNBV R04A | Reporte mensual de cartera de crédito |
| LFPE | Ley para la Transparencia y Ordenamiento de los Servicios Financieros — comisiones y tasas |
| NIF C-20 | Instrumentos financieros de deuda |
| Buró de Crédito | Consultas y reportes (CNBV regulated) |

---

## CONTENIDO A POBLAR

- [ ] `origination-flow.md` — Flujo de originación por producto
- [ ] `scoring-model.md` — Modelo de scoring crediticio (si disponible)
- [ ] `collection-rules.md` — Reglas de cobranza y alertas tempranas
- [ ] `provisioning-rules.md` — Reglas de provisionamiento CNBV
- [ ] `npl-analysis.md` — Análisis de cartera vencida y tendencias

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — pendiente discovery real*

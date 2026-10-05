# dt-card-lifecycle — Ciclo de Vida de Tarjeta
> Digital Twin federado · Santander México
> Pregunta rectora: ¿Qué sistemas tocan una tarjeta desde emisión hasta cancelación?

---

## PROPÓSITO

Mapear el ciclo de vida completo de tarjetas débito y crédito a través de todos los sistemas
que intervienen: desde la parametrización del producto hasta el cierre o cancelación.

---

## FASES DEL CICLO DE VIDA

| Fase | Sistemas involucrados | Estado |
|------|----------------------|--------|
| Parametrización de producto | Card Platform · Core Banking | PENDIENTE |
| Emisión / apertura | Card Platform · Core Banking · IAM | PENDIENTE |
| Personalización y envío | Card Platform · Bureau de personalización | PENDIENTE |
| Activación | SuperMóvil · Call Center · Card Platform | PENDIENTE |
| Autorización de transacción | Card Authorizer · Card Platform · VISA/MC | PENDIENTE |
| Facturación (crédito) | Card Platform · Core Banking · Loans | PENDIENTE |
| Gestión de límite / bloqueos | Card Platform · SuperMóvil · Call Center | PENDIENTE |
| Cobranza (crédito vencido) | Loans · Core Banking | PENDIENTE |
| Cancelación / cierre | Card Platform · Core Banking | PENDIENTE |
| Fraud chargeback | Card Authorizer · Fraud Detection · VISA/MC | PENDIENTE |

---

## VOLÚMENES ESTIMADOS (SCAFFOLD)

| Métrica | Estimado | Fuente |
|---------|----------|--------|
| Tarjetas de débito activas | ~10M | Estimado por base clientes |
| Tarjetas de crédito activas | ~5M | Estimado cuota mercado CNBV |
| Transacciones autorizadas / mes | ~120M | Estimado cuota PROSA |
| Tasa de fraude | < 0.1% objetivo | Estándar PCI-DSS |

---

## CONTENIDO A POBLAR

- [ ] `product-catalog.md` — Catálogo de productos de tarjeta (débito, crédito, ZERO, Light)
- [ ] `authorization-flow.md` — Flujo de autorización en tiempo real con timeouts
- [ ] `billing-cycle.md` — Ciclo de facturación crédito
- [ ] `fraud-rules.md` — Reglas de detección de fraude conocidas
- [ ] `regulatory-pci.md` — Estado de cumplimiento PCI-DSS v4

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — pendiente discovery real*

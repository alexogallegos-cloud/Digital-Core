# dt-payments-rails — Rieles de Pago
> Digital Twin federado · Santander México
> Pregunta rectora: ¿Qué sistemas intervienen en SPEI, DiMo, CoDi y pagos internacionales SWIFT?

---

## PROPÓSITO

Documentar y analizar el ecosistema de pagos de Santander México: rieles regulados (Banxico),
internacionales (SWIFT), acquiring (PROSA/Visa/MC), y emergentes (Open Banking).

---

## RIELES DE PAGO A DOCUMENTAR

| Riel | Regulador | Sistemas involucrados | Volumen estimado | Estado |
|------|-----------|----------------------|-----------------|--------|
| SPEI | Banxico | Banxico SPEI · Payments Engine · Core Banking | ~50M tx/mes | SCAFFOLD |
| DiMo | Banxico | Banxico DiMo · SuperMóvil · Payments Engine | Creciente | SCAFFOLD |
| CoDi | Banxico | Banxico CoDi · comercios | ~XM tx/mes | SCAFFOLD |
| SWIFT MT/ISO 20022 | SWIFT | SWIFT Gateway · Treasury · Correspondent banks | Corporativo | SCAFFOLD |
| Domiciliación (CECOBAN) | Banxico | Payments Engine · CECOBAN · Core Banking | ~XM mandatos | SCAFFOLD |
| Visa / Mastercard acquiring | CNBV / Redes | POS · Card Authorizer · PROSA | ~120M tx/mes | SCAFFOLD |
| Pagos internacionales (remesas) | CNBV | Por identificar | XM tx/mes | SCAFFOLD |

---

## REGULACIÓN APLICABLE

| Marco | Descripción |
|-------|-------------|
| Circular 14/2017 Banxico | Reglas SPEI — ventanas, montos, tiempos |
| Reglas DiMo Banxico | Pagos P2P con número de teléfono |
| CECOBAN | Compensación electrónica nacional — domiciliación |
| SWIFT ISO 20022 | Migración global de mensajería financiera (2025 deadline) |
| PCI-DSS v4 | Seguridad de datos en todas las redes de pago |

---

## CONTENIDO A POBLAR

- [ ] `flow-spei.md` — Flujo técnico SPEI end-to-end con sistemas y tiempos
- [ ] `flow-dimo.md` — Flujo DiMo con manejo de error y timeouts
- [ ] `flow-swift.md` — Flujo pagos internacionales
- [ ] `capacity-analysis.md` — Análisis de capacidad vs. picos (fin de mes, quincena)
- [ ] `regulatory-compliance.md` — Estado de cumplimiento por riel

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — pendiente discovery real*

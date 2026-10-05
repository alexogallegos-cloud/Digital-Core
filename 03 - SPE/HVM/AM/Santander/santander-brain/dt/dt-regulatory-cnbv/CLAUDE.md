# dt-regulatory-cnbv — Cumplimiento Regulatorio
> Digital Twin federado · Santander México
> Pregunta rectora: ¿Qué sistemas alimentan el cumplimiento regulatorio CNBV, Banxico y UIF?

---

## PROPÓSITO

Mapear los sistemas que alimentan los reportes regulatorios y los flujos de cumplimiento.
Identificar brechas, riesgos de incumplimiento, y oportunidades de automatización regulatoria.

---

## REPORTES REGULATORIOS

### CNBV — Circular Única de Bancos

| Reporte | Descripción | Frecuencia | Sistema(s) fuente | Estado |
|---------|-------------|-----------|-------------------|--------|
| R01A | Balance General | Mensual | Core Banking · Finance ERP | PENDIENTE |
| R04A | Cartera de crédito | Mensual | Loans · Core Banking | PENDIENTE |
| R10A | Captación | Mensual | Core Banking | PENDIENTE |
| R17A | Derivados | Mensual | Treasury | PENDIENTE |
| ICAP | Índice de Capitalización (Basilea III) | Mensual | Finance ERP · Risk | PENDIENTE |
| CCL | Coeficiente de Cobertura de Liquidez | Diario | Treasury · Core Banking | PENDIENTE |
| SIPRES | Registro servicios financieros | Continuo | IAM · Core Banking | PENDIENTE |

### Banxico

| Marco | Reporte | Sistemas fuente |
|-------|---------|----------------|
| SPEI | Estadísticas de pagos | Banxico SPEI · Payments Engine |
| Política monetaria | Coeficiente de reserva | Core Banking |
| Encuesta banca | Tasas y saldos | Core Banking · Loans |

### UIF — PLD/AML

| Reporte | Descripción | Frecuencia | Sistema fuente |
|---------|-------------|-----------|----------------|
| ROI | Reporte de Operaciones Inusuales | Continuo | PLD Engine |
| ROS | Reporte de Operaciones Sospechosas | Continuo | PLD Engine |
| Aviso 24h | Operaciones en efectivo > $10K USD eq. | 24h | Core Banking · PLD Engine |
| CUAT | Cuestionario de autoevaluación anual | Anual | Compliance |

---

## REGULACIÓN DIGITAL — CNBV Open Finance

| Requisito | Deadline | Estado Santander |
|-----------|---------|-----------------|
| APIs información de cuentas | 2025 escalonado | Por confirmar |
| APIs iniciación de pagos | 2026 | Por confirmar |
| Sandbox regulatorio | 2024 | Por confirmar |

---

## CONTENIDO A POBLAR

- [ ] `regulatory-calendar.md` — Calendario de vencimientos regulatorios
- [ ] `data-lineage-cnbv.md` — Trazabilidad de datos de sistemas fuente a reportes
- [ ] `gap-regulatory.md` — Brechas de cumplimiento identificadas
- [ ] `open-banking-status.md` — Estado de implementación Open Finance CNBV
- [ ] `pld-rules.md` — Reglas PLD/AML documentadas

---

*Última actualización: 2026-09-17 · v0.1 · Stub inicial — pendiente discovery real*

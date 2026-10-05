# ETB Banking V5.0 — Marco de Capacidades MONEX

## Fuente

**Banking Enterprise Technology Blueprint V5.0**
- L1: 7 dominios
- L2: 57 subdominios
- L3: 261 capacidades

Instancia de referencia: `BanCoppel/systems/core/Informix/knowledge-base/ontology/etb-capabilities.json`

---

## Scope para MONEX — Casa de Bolsa (FX + Pagos + Tesorería)

MONEX no es banco retail completo. El ETB Banking aplica de forma diferenciada:

| L1 Dominio | Relevancia MONEX | Justificación |
|------------|-----------------|---------------|
| 1 — Productos de Captación | BAJA | MONEX no capta depósitos retail en MX |
| 2 — Productos de Crédito | MEDIA | Financiamiento a corporativos y operaciones FX |
| 3 — Product & Service (Pagos = subdominio 3.4) | **ALTA** | Core del programa Apolo — Motor de Pagos |
| 4 — Canales | MEDIA | Portal clientes + API marketplace |
| 5 — Gestión de Datos | **ALTA** | Golden Record — gap crítico hoy |
| 6 — Riesgo y Finanzas | **ALTA** | FX/Treasury — núcleo del negocio |
| 7 — Tecnología e Infraestructura | **ALTA** | MuleSoft + Integration Architecture |

---

## Capacidades L3 Prioritarias para MONEX

### Dominio 3 — Product & Service · Subdominio 3.4 Payments (ALTA relevancia)

> Corrección: en el ETB autoritativo (SME Industry Banking), Pagos es el **subdominio 3.4** dentro del dominio
> L1 **Product & Service**, no un dominio propio. La taxonomía completa L1→L2→L3→L4 (Payments 3.4 y Trade Finance
> 3.6, con procesos L4 derivados) vive en la tabla `etb_payments_taxonomy` del brain y se renderiza en
> `portal/panorama.html`.

| L3 ID | Capacidad ETB | Sistema MONEX |
|-------|---------------|---------------|
| 3.4.1 | Payments Pre-Processing Management | spei, payments-legacy |
| 3.4.2 | Payment Acquisition Management | portal-clientes, api-marketplace |
| 3.4.3 | Core Payment Processing | Motor de Pagos Apolo (target) |
| 3.4.4 | Payment Clearing & Settlement | Motor de Pagos Apolo, CLS |
| 3.4.5 | Payment Network Integration | spei, swift, mulesoft |
| 3.4.6 | Post Payment Processing | DATO-REQUERIDO |
| 3.4.7 | Payment Support Services | DATO-REQUERIDO |
| 3.4.8 | Payments Operations Management | cnbv-banxico, treasury |

### Dominio 5 — Gestión de Datos (ALTA relevancia — gap crítico)

| L3 ID | Capacidad | Sistema MONEX |
|-------|-----------|---------------|
| 5.1.x | Master Data Management (MDM) | GAP CRÍTICO — golden-record-target (TO-BE) |
| 5.2.x | Data Quality & Stewardship | GAP — sin proceso formal |
| 5.3.x | Data Catalog | GAP — no existe |
| 5.4.x | Data Governance | DATO-REQUERIDO |

### Dominio 6 — Riesgo y Finanzas (ALTA relevancia)

| L3 ID | Capacidad | Sistema MONEX |
|-------|-----------|---------------|
| 6.1.x | FX Risk Management | fx-engine |
| 6.2.x | Treasury Management | treasury |
| 6.3.x | Position Management | fx-engine, treasury |
| 6.4.x | Límites y concentración | treasury |
| 6.5.x | Contraparte y KYC | DATO-REQUERIDO |

### Dominio 7 — Tecnología e Infraestructura (ALTA relevancia)

| L3 ID | Capacidad | Sistema MONEX |
|-------|-----------|---------------|
| 7.1.x | API Gateway & Management | mulesoft |
| 7.2.x | Integration Platform (iPaaS) | mulesoft |
| 7.3.x | Developer Experience (API Catalog) | api-marketplace |
| 7.4.x | Cloud Infrastructure | GAP — Journey to Cloud en proceso |
| 7.5.x | Security & IAM | DATO-REQUERIDO |

---

## etb_version

`etb_version: 1.0.0-monex` — primera versión del mapeo MONEX sobre ETB Banking V5.0.

La tabla `etb_l3` en `monex-brain.db` replica el catálogo completo de 261 L3 con la cobertura de cada sistema MONEX. Las capacidades con `status = NOT_COVERED` sin justificación son gaps candidatos para el programa Apolo.

---

## Evolución

Cuando se incorpore información de los sistemas AS-IS, actualizar:
1. `monex_status` por sistema: `COVERED | PARTIAL | NOT_COVERED | SCOPE_ADJUST`
2. `SCOPE_ADJUST`: capacidades del ETB Banking que no aplican a una Casa de Bolsa FX (ej: banca retail, ATM, etc.)

---

*v1.0 · 2026-09-22 · Seed inicial — mapeo MONEX sobre Banking ETB V5.0*

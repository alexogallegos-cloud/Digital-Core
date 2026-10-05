# PAG Macro-Capabilities — Motor de Pagos MONEX
> Source: RFP-PAG v2.6 · Section 6 · Appendix PAG-D07 v0.2

10 macro-capabilities funcionales que definen el alcance del nuevo motor de pagos.

---

## Mapa de Macro-Capabilities

| Código | Nombre | Descripción |
|--------|--------|-------------|
| **PAG-1** | Products and Schemes | Catálogos de productos, rieles de pago, participantes, calendarios, tarifas, parámetros y datos de referencia. |
| **PAG-2** | Initiation and Capture | Iniciación multi-canal, modelo común, pagos individuales y masivos, programación, autorizaciones y beneficiarios. |
| **PAG-3** | Validation and Enrichment | Validación de estructura, cliente/cuenta, beneficiario/banco, fondos, fecha valor, ISO 20022 y códigos de razón. |
| **PAG-4** | Pre-processing Controls | Sanciones, AML/CFT, fraude, límites, SoD, duplicados, reglas locales y evidencia. |
| **PAG-5** | Orchestration and Routing | Workflow, prioridades, colas, enrutamiento, fallback, cut-offs, paralelismo y servicios externos. |
| **PAG-6** | Clearing and Settlement | Mensajes, transmisión, ACK/NACK, estatus, liquidación, liquidez, procesamiento intraday y cierre. |
| **PAG-7** | Cross-border and FX | Banca corresponsal, SWIFT/UETR, partes, cargos, FX, trazabilidad y reparación. |
| **PAG-8** | Exceptions and Investigations | Colas de excepción, reparación, devoluciones, recalls, estatus desconocido, casos y comunicaciones. |
| **PAG-9** | Reconciliation and Accounting | Conciliación, nostro/vostro, eventos contables, GL, diferencias, ajustes y cierre. |
| **PAG-10** | Monitoring and Analytics | Vista end-to-end, dashboards, rieles de pago, alertas, reportes, auditoría, datos y costos. |

---

## Alcance Geográfico por Capability

| Capability | México (SPEI/SPID/CoDi/DIMO) | USA (ACH/Fedwire) | UK (FPS/CHAPS) | España/EU (SEPA/ISO 20022) | Cross-border (SWIFT) |
|-----------|:-:|:-:|:-:|:-:|:-:|
| PAG-1 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-2 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-3 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-4 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-5 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-6 | ✓ | ✓ | ✓ | ✓ | — |
| PAG-7 | — | — | — | — | ✓ |
| PAG-8 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-9 | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAG-10 | ✓ | ✓ | ✓ | ✓ | ✓ |

---

## Capabilities Críticas para MONEX

**PAG-7 (Cross-border and FX)** es la capability diferenciadora de MONEX — donde se concentra el 80% del volumen de negocio. Requiere:
- Conectividad SWIFT Alliance confirmada
- UETR end-to-end para CBPR+
- FX Settlement integrado con el motor FX existente
- Charges OUR/SHA/BEN configurables por producto/cliente

**PAG-6 (Clearing and Settlement)** es prerequisito de PAG-7 — la liquidación en CLS (Payment-vs-Payment) requiere integración completa con el clearing engine.

**PAG-4 (Pre-processing Controls)** tiene el mayor impacto regulatorio — sanciones + PLD + fraude con evidencia auditable son requisitos CNBV/Banxico/FCA sin excepción.

---

## Apéndice Técnico — PAG-D07 v0.2

El Apéndice Técnico del RFP contiene el detalle completo de requisitos por capability:

| Tipo | Cantidad | Sección |
|------|----------|---------|
| Requisitos funcionales | 91 | Por macro-capability PAG-1 a PAG-10 |
| Requisitos regulatorios y de cumplimiento | 36 | Multi-jurisdiccional |
| Requisitos no funcionales | 61 | Capacidad, latencia, disponibilidad, DR |
| Requisitos de IA | 40 | AI-01 a AI-12 + sub-requisitos |
| **Total** | **228** | — |

*Fuente: RFP-PAG v2.6, 27-Ago-2026*

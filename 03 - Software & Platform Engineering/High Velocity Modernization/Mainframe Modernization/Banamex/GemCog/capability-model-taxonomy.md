# Modelo de Capacidades Bancarias — Taxonomía Completa (Banamex GemCog)
> Fuente: `portal/modelo-capacidades.html` · 104 capacidades · 10 dominios + 1 sección Transversal
> Extracción: 2026-07-16 · Gemelo Cognitivo Capa 3 (capacidades)
> Cobertura GemCog: **20/104 capacidades (19%)** · **9/10 dominios** con al menos una capacidad cubierta
> Usada como campo "Capacidad bancaria" en catálogo de reglas RN-S151-NNN y RN-S500-NNN

---

## Leyenda de cobertura

| Símbolo | Sistema | Color en portal | LOC analizadas | Objetos MCP |
|---------|---------|-----------------|----------------|-------------|
| `S500` | S500 · Cargos y Abonos de Cuentas de Cheque | Rojo | 898,596 | 114 |
| `S151` | S151 · Movimientos Contables GL (General Ledger) | Azul | 444,992 | 104 |
| `AMBOS` | S500 + S151 (infraestructura Unisys MCP compartida) | Verde-azul | 1,343,588 | 218 |
| _(gap)_ | Fuera del alcance de los sistemas Unisys MCP analizados | Gris | — | — |

**Nota sobre el Transversal**: la sección "Transversal · Interfaces & Seguridad" no es un dominio numerado en el modelo de referencia estándar pero aparece explícitamente en el portal GemCog como área separada. Se documenta con prefijo `T` para distinguirla de los 10 dominios canónicos.

---

## Mapa de cobertura S151 — usar en campo "Capacidad bancaria" de cada regla

| ID | Dominio | Sub-categoría | Capacidad | S500 | S151 | AMBOS |
|----|---------|---------------|-----------|:----:|:----:|:-----:|
| 1.1.1 | Ecosystem Management | Ecosystem Partner Mgmt | Onboarding | | | |
| 1.1.2 | Ecosystem Management | Ecosystem Partner Mgmt | Partnering means | | | |
| 1.1.3 | Ecosystem Management | Ecosystem Partner Mgmt | Agreements & SLA | | | |
| 1.1.4 | Ecosystem Management | Ecosystem Partner Mgmt | Review | | | |
| 2.1.1 | Channels | Assisted Touchpoints | Teller | ✓ | | |
| 2.1.2 | Channels | Assisted Touchpoints | Retail Salesforce | | | |
| 2.1.3 | Channels | Assisted Touchpoints | Contact Centre (Phone) | | | |
| 2.1.4 | Channels | Assisted Touchpoints | Contact Centre (Web) | | | |
| 2.1.5 | Channels | Assisted Touchpoints | Relationship Manager | | | |
| 2.1.6 | Channels | Assisted Touchpoints | Mail | | | |
| 2.1.7 | Channels | Assisted Touchpoints | Social Media | | | |
| 2.2.1 | Channels | Un-Assisted Touchpoints | IVR | | | |
| 2.2.2 | Channels | Un-Assisted Touchpoints | Kiosk / SST | | | |
| 2.2.3 | Channels | Un-Assisted Touchpoints | Web (BPI) | | | |
| 2.2.4 | Channels | Un-Assisted Touchpoints | Mobile | | | |
| 2.2.5 | Channels | Un-Assisted Touchpoints | SMS | | | |
| 2.2.6 | Channels | Un-Assisted Touchpoints | ATM | ✓ | | |
| 2.2.7 | Channels | Un-Assisted Touchpoints | PoS | ✓ | | |
| 2.3.1 | Channels | (General) | Affiliate & Partner Channels | | | |
| 2.3.2 | Channels | (General) | Device Management | | | |
| 3.1.1 | Marketing & Distribution | (General) | Marketing | | | |
| 3.1.2 | Marketing & Distribution | (General) | Digital Marketing | | | |
| 3.1.3 | Marketing & Distribution | (General) | Sales Management | | | |
| 3.1.4 | Marketing & Distribution | (General) | Contract Management | | | |
| 3.1.5 | Marketing & Distribution | (General) | Illustration Management | | | |
| 3.1.6 | Marketing & Distribution | (General) | Customer Finance Mgmt. | | | |
| 3.1.7 | Marketing & Distribution | (General) | Brand Management | | | |
| 4.1.1 | Common Customer View | Customer View | Demographics | | | |
| 4.1.2 | Common Customer View | Customer View | Holdings | ✓ | | |
| 4.1.3 | Common Customer View | Customer View | Roles & Relationships | | | |
| 4.1.4 | Common Customer View | Customer View | Ref. Satellite | | | |
| 4.1.5 | Common Customer View | Customer View | Segmentation | | | |
| 4.2.1 | Common Customer View | Identity | Registration | | | |
| 4.2.2 | Common Customer View | Identity | Authentication | | | |
| 4.3.1 | Common Customer View | Preferences | Needs and offer | | | |
| 4.3.2 | Common Customer View | Preferences | Goals | | | |
| 4.3.3 | Common Customer View | Preferences | Communication | | | |
| 4.4.1 | Common Customer View | Feedback | Sentiment & Feedback | | | |
| 4.4.2 | Common Customer View | Feedback | Personalisation | | | |
| 4.5.1 | Common Customer View | Authorisations | Operations author. | | | |
| 4.5.2 | Common Customer View | Authorisations | Delegations, PoA | | | |
| 4.5.3 | Common Customer View | Authorisations | Signatures | | | |
| 4.6.1 | Common Customer View | Prospect | Prospect Management | | | |
| 5.1.1 | Product Processing | Product Catalogue | Deposits | ✓ | | |
| 5.1.2 | Product Processing | Product Catalogue | Lending | | | |
| 5.1.3 | Product Processing | Product Catalogue | Corp Finance | | | |
| 5.1.4 | Product Processing | Product Catalogue | Asset Mgmt. | | | |
| 5.1.5 | Product Processing | Product Catalogue | Insurance | | | |
| 5.1.6 | Product Processing | Product Catalogue | FX | | | |
| 5.1.7 | Product Processing | Product Catalogue | Cards | | | |
| 5.1.8 | Product Processing | Product Catalogue | Non Financial Products | | | |
| 5.1.9 | Product Processing | Product Catalogue | Custody & Funded Adm. | | | |
| 6.1.1 | Common Services | Core Services | Master Contract Mgmt. | | | |
| 6.1.2 | Common Services | Core Services | Cash Mgmt. | | | |
| 6.1.3 | Common Services | Core Services | Payments | ✓ | | |
| 6.1.4 | Common Services | Core Services | Statements | ✓ | | |
| 6.1.5 | Common Services | Core Services | Interest & Fees | ✓ | | |
| 6.2.1 | Common Services | Risk | Operational | | | |
| 6.2.2 | Common Services | Risk | Financial | | | |
| 6.3.1 | Common Services | AML & Fraud | AML | | | |
| 6.3.2 | Common Services | AML & Fraud | Fraud | | | |
| 6.4.1 | Common Services | Complaints | Analysis | | | |
| 6.4.2 | Common Services | Complaints | Follow up | | | |
| 6.4.3 | Common Services | Complaints | Closing | | | |
| 6.5.1 | Common Services | (General) | Collections & Recovery | | | |
| 6.5.2 | Common Services | (General) | Compliance & Regulation | | | ✓ |
| 6.5.3 | Common Services | (General) | Pricing Management | | | |
| 6.5.4 | Common Services | (General) | Treasury | | | |
| 6.6.1 | Common Services | Customer Services | Financial Servicing | ✓ | | |
| 6.6.2 | Common Services | Customer Services | Non Financial Servicing | | | |
| 6.6.3 | Common Services | Customer Services | Intelligent Servicing (RPA) | | | |
| 6.7.1 | Common Services | Reconciliations | Financial Reconciliation | | ✓ | |
| 6.7.2 | Common Services | Reconciliations | Operational Reconciliation | | | ✓ |
| 7.1.1 | Enterprise Support Functions | (General) | Finance (GL) | | ✓ | |
| 7.1.2 | Enterprise Support Functions | (General) | Talent & Organisation | | | |
| 7.1.3 | Enterprise Support Functions | (General) | IT | | | |
| 7.1.4 | Enterprise Support Functions | (General) | Corporate Services | | | |
| 8.1.1 | Technology Tools | (General) | Scheduling | | | ✓ |
| 8.1.2 | Technology Tools | (General) | Business Process Mgmt. | | | |
| 8.1.3 | Technology Tools | (General) | AI Tools | | | |
| 8.1.4 | Technology Tools | (General) | EA Tools | | | |
| 8.1.5 | Technology Tools | (General) | Document Management | | | |
| 8.1.6 | Technology Tools | (General) | Collaboration & Productivity | | | |
| 8.1.7 | Technology Tools | (General) | Project Management | | | |
| 8.1.8 | Technology Tools | (General) | RPA Tools | | | |
| 9.1.1 | Insights & Information | (General) | Operational Data Stores | | | ✓ |
| 9.1.2 | Insights & Information | (General) | Event Streams | | | |
| 9.1.3 | Insights & Information | (General) | Data Lakes | | | |
| 10.1.1 | Integration & Interfaces | Interface Management | Access Control | ✓ | | |
| 10.1.2 | Integration & Interfaces | Interface Management | Traffic Management | | | |
| 10.1.3 | Integration & Interfaces | Interface Management | API Catalogue | | | |
| T.1.1 | Transversal · Interfaces & Seguridad | External Interfaces | API | | | |
| T.1.2 | Transversal · Interfaces & Seguridad | External Interfaces | EDI | | | |
| T.1.3 | Transversal · Interfaces & Seguridad | External Interfaces | Payment Schemes (SPEI/CLABE) | ✓ | | |
| T.1.4 | Transversal · Interfaces & Seguridad | External Interfaces | Cloud Integration | | | |
| T.2.1 | Transversal · Interfaces & Seguridad | Internal Interfaces | API | | | |
| T.2.2 | Transversal · Interfaces & Seguridad | Internal Interfaces | ESB | | | |
| T.2.3 | Transversal · Interfaces & Seguridad | Internal Interfaces | MQ / Async (L091-L093) | ✓ | | |
| T.2.4 | Transversal · Interfaces & Seguridad | Internal Interfaces | Others | | | |
| T.3.1 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Master Data Mgmt. | | | |
| T.3.2 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Metadata Mgmt. | | | |
| T.3.3 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Content Mgmt. | | | |
| T.3.4 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Analytics / Reporting | | ✓ | |
| T.3.5 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Security | | | ✓ |

---

## Resumen de cobertura por dominio

| Dominio | Total caps | S500 | S151 | AMBOS | Cubiertos | Gap |
|---------|-----------|------|------|-------|-----------|-----|
| 1 · Ecosystem Management | 4 | 0 | 0 | 0 | 0 | 4 |
| 2 · Channels | 16 | 3 | 0 | 0 | 3 | 13 |
| 3 · Marketing & Distribution | 7 | 0 | 0 | 0 | 0 | 7 |
| 4 · Common Customer View | 16 | 1 | 0 | 0 | 1 | 15 |
| 5 · Product Processing | 9 | 1 | 0 | 0 | 1 | 8 |
| 6 · Common Services | 21 | 4 | 1 | 2 | 7 | 14 |
| 7 · Enterprise Support Functions | 4 | 0 | 1 | 0 | 1 | 3 |
| 8 · Technology Tools | 8 | 0 | 0 | 1 | 1 | 7 |
| 9 · Insights & Information | 3 | 0 | 0 | 1 | 1 | 2 |
| 10 · Integration & Interfaces | 3 | 1 | 0 | 0 | 1 | 2 |
| T · Transversal | 13 | 2 | 1 | 1 | 4 | 9 |
| **TOTAL** | **104** | **12** | **3** | **5** | **20** | **84** |

---

## Por capacidad cubierta — referencia rápida para poblar reglas

### Capacidades S500 (12)

| ID | Capacidad | Sistema en portal | Contexto MCP |
|----|-----------|-------------------|--------------|
| 2.1.1 | Teller | S500 · Procesamiento Core | Canal ventanilla → P100/P101 cargos y abonos |
| 2.2.6 | ATM | S500 · Procesamiento Core | Canal ATM → P100 cargo + P630_TARINTERCAM |
| 2.2.7 | PoS | S500 · Procesamiento Core | Canal PoS → P100 cargo + P630_TARINTERCAM |
| 4.1.2 | Holdings | S500 · Saldos | Saldos de cuenta → L019_SALDOS |
| 5.1.1 | Deposits | S500 · Cuentas de Cheque | BDB04 DMSII — base de cuentas |
| 6.1.3 | Payments | S500 · Cargos & Abonos | P100 (débito) + P101 (crédito) |
| 6.1.4 | Statements | S500 · Saldos & Cuentas | L019_SALDOS + cierre diario BDB04 |
| 6.1.5 | Interest & Fees | S500 · Intereses & Comisiones | Cálculo en batch nocturno L091/L093 |
| 6.6.1 | Financial Servicing | S500 · Servicio de Cuenta | Operaciones de servicio sobre BDB04 |
| 10.1.1 | Access Control | S500 · Control de Acceso | P655_SCRAMBLING + L010_CONTROL |
| T.1.3 | Payment Schemes (SPEI/CLABE) | S500 · SPEI & Banxico | P629_CARGABD06 + L040_LIGAS → Banxico |
| T.2.3 | MQ / Async (L091-L093) | S500 · Asíncrona MCP | L091/L093 — mayor fan-out S500 (67 llamadores) |

### Capacidades S151 (3)

| ID | Capacidad | Sistema en portal | Contexto MCP |
|----|-----------|-------------------|--------------|
| 6.7.1 | Financial Reconciliation | S151 · Conciliación GL | P##_CONCILIACION — cuadre S500↔S151 |
| 7.1.1 | Finance (GL) | S151 · Libro Mayor General | P##_GL_ENTRY + P##_CIERRE_DIARIO — mayor fan-out S151 (52) |
| T.3.4 | Analytics / Reporting | S151 · Reportes Contables | P##_REPORTES_CNBV — CUIF R01/R04 |

### Capacidades compartidas AMBOS (5)

| ID | Capacidad | Sistema en portal | Contexto MCP |
|----|-----------|-------------------|--------------|
| 6.5.2 | Compliance & Regulation | S500+S151 · CNBV | Reportes regulatorios + SPEI regulatorio |
| 6.7.2 | Operational Reconciliation | S500+S151 · Cuadre Operativo-Contable | JOINT_RECONCILIATION nocturno |
| 8.1.1 | Scheduling | S500+S151 · Batch Scheduler MCP | WFL MASTER JOB — mayor fan-out total (218) |
| 9.1.1 | Operational Data Stores | S500+S151 · DMSII Bases de Datos | BDB04 (S500) + GL-DB (S151) sobre Unisys DMSII |
| T.3.5 | Security | S500+S151 · Seguridad MCP | L010_CONTROL (gate) + P655_SCRAMBLING (PCI-DSS) |

---

## Por programa S151 — qué capacidades cubre cada programa

> **Fuente de los procesos**: `DOMDATA.s151` del portal HTML (usa notación genérica `P##`).
> Los nombres reales de los programas S151 en scope (P109, P112, P108, P130, P131, P150, P021, P103, P120) provienen del catálogo `rules-s151.md`. El mapeo programa→capacidad es una inferencia basada en la descripción funcional del portal; debe validarse contra el catálogo de reglas.

| Proceso funcional (HTML) | Programa real (inferido) | Capacidades bancarias | ID(s) |
|--------------------------|--------------------------|----------------------|-------|
| registra asiento contable (débito/crédito GL) | P109 · P108 · P130 · P131 | Finance (GL) | 7.1.1 |
| cierre contable diario (batch regulatorio) | P109 · P108 | Finance (GL) · Compliance & Regulation | 7.1.1 · 6.5.2 |
| generación de reportes CNBV (CUIF R01-R04) | P150 | Analytics / Reporting · Compliance & Regulation | T.3.4 · 6.5.2 |
| conciliación GL vs operativo (S500↔S151) | P112 · P120 | Financial Reconciliation · Operational Reconciliation | 6.7.1 · 6.7.2 |
| control de gate batch (L_CONTROL_GL) | P021 | Scheduling · Compliance & Regulation | 8.1.1 · 6.5.2 |
| consulta libro mayor / GL balance (L_BOOK) | P103 | Finance (GL) · Operational Data Stores | 7.1.1 · 9.1.1 |

### Tabla consolidada por programa real

| Programa | Función principal | Capacidades bancarias | Fuente del mapeo |
|----------|------------------|-----------------------|-----------------|
| P108 | GL Ledger Writing — escritura de asientos en libro mayor | Finance (GL) [7.1.1] | Inferido del portal |
| P109 | GL Posting — contabilización de movimientos diarios | Finance (GL) [7.1.1] · Compliance & Regulation [6.5.2] | Inferido del portal |
| P112 | Reconciliation — cuadre S500↔S151 | Financial Reconciliation [6.7.1] · Operational Reconciliation [6.7.2] | Inferido del portal |
| P120 | Conciliation — cierre conciliación nocturna | Financial Reconciliation [6.7.1] · Operational Reconciliation [6.7.2] | Inferido del portal |
| P130 | Accounting Translation — traducción contable de movimientos | Finance (GL) [7.1.1] · Compliance & Regulation [6.5.2] | Inferido del portal |
| P131 | Accounting Translation (variante) | Finance (GL) [7.1.1] | Inferido del portal |
| P150 | CNBV Reporting — generación reportes regulatorios | Analytics / Reporting [T.3.4] · Compliance & Regulation [6.5.2] | Inferido del portal |
| P021 | Batch Control / Gate — control de flujo batch S151 | Scheduling [8.1.1] | Inferido del portal |
| P103 | Data Processing — procesamiento y acceso a DMSII GL | Finance (GL) [7.1.1] · Operational Data Stores [9.1.1] | Inferido del portal |

> **Acción requerida**: validar cada fila de esta tabla contra el catálogo `Specialist - Business Rules/rules-catalog/rules-s151.md`. Las reglas RN-S151-NNN ya tienen campo `Capacidad bancaria` que debe coincidir con los IDs de esta taxonomía.

---

## Por programa S500 — qué capacidades cubre cada programa

| Programa | Función principal | Capacidades bancarias | ID(s) |
|----------|------------------|-----------------------|-------|
| P100 | Cargo (débito) en cuenta de cheque | Payments · Deposits · Teller · ATM · PoS | 6.1.3 · 5.1.1 · 2.1.1 · 2.2.6 · 2.2.7 |
| P101 | Abono (crédito) en cuenta de cheque | Payments · Deposits · Payment Schemes | 6.1.3 · 5.1.1 · T.1.3 |
| P629_CARGABD06 | SPEI / CLABE — liquidación interbancaria | Payment Schemes · Payments · Compliance & Regulation | T.1.3 · 6.1.3 · 6.5.2 |
| P630_TARINTERCAM | Tarjeta de intercambio — liquidación batch | ATM · PoS · Payments | 2.2.6 · 2.2.7 · 6.1.3 |
| P655_SCRAMBLING | Scrambling / enmascarado de datos sensibles | Security · Access Control | T.3.5 · 10.1.1 |
| L091_ASINCRONA / L093 | Lote asíncrono nocturno — cierre de cuentas | MQ / Async · Scheduling · Statements · Financial Servicing | T.2.3 · 8.1.1 · 6.1.4 · 6.6.1 |
| L019_SALDOS | Consulta y actualización de saldo disponible | Holdings · Statements | 4.1.2 · 6.1.4 |
| L010_CONTROL | Control de gate batch (validación de permisos) | Access Control · Scheduling · Security | 10.1.1 · 8.1.1 · T.3.5 |
| L040_LIGAS | Interface externa Banxico (SPEI) | Payment Schemes · Compliance & Regulation | T.1.3 · 6.5.2 |

---

## Capacidades gap — no cubiertas por S500 ni S151 (84 capacidades)

Estas capacidades son parte del modelo de referencia bancario pero **no se implementan en los sistemas Unisys MCP analizados**. Corresponden a:
- **Canales digitales y CRM**: dominio 2 (digital/unassisted), dominio 3 (marketing), dominio 4 (CRM completo).
- **Productos no-cheques**: dominio 5 excepto Deposits (crédito, tarjetas, inversiones, FX).
- **Riesgo, AML, Fraude**: dominio 6 sub-cats Risk, AML & Fraud, Complaints.
- **Soporte empresarial**: dominio 7 (RRHH, IT, corporate).
- **Herramientas digitales**: dominio 8 (BPM, AI, EA, RPA, colaboración).
- **Datos y analítica avanzada**: dominio 9 (Event Streams, Data Lakes).
- **Integración moderna**: dominio 10 (Traffic Mgmt, API Catalogue), Transversal (API management, ESB, Cloud Integration, MDM).

En el contexto de la modernización Banamex, estas capacidades deben **incorporarse o integrarse** en la arquitectura target y son candidatos naturales a componentes nuevos (no transpilados) en el journey de modernización.

---

*Generado: 2026-07-16 · v1.0 · Fuente primaria: `portal/modelo-capacidades.html` (GemCog Capa 3)*
*Cross-referencia: `Specialist - Business Rules/rules-catalog/rules-s151.md` para validación de mapeos programa→capacidad*
# Modelo de Capacidades Bancarias — Taxonomía Completa (Banamex GemCog)
> Fuente: `portal/modelo-capacidades.html` · 107 capacidades (104 BIAN + 3 ext. GemCog) · 10 dominios + 1 sección Transversal
> Extracción: 2026-07-16 · Actualizado: 2026-07-22 · Gemelo Cognitivo Capa 3 (capacidades)
> Cobertura GemCog: **23/107 capacidades (21.5%)** · **9/10 dominios** con al menos una capacidad cubierta
> Usada como campo "Capacidad bancaria" en catálogo de reglas RN-S151-NNN y RN-S500-NNN
> Indexado: ✅ 2026-07-17 — Capa 3 Capacidades — taxonomía canónica (llave de normalización regla→capacidad)
> **Tipo-artefacto:** `Catálogo-Reglas`  
> **Capa-GemCog:** `3`  
> **Propósito:** Taxonomía canónica del modelo BC-XX (BC-01..BC-23) que define la jerarquía de 5 niveles y sitúa las capacidades cubiertas dentro del universo BIAN v12 de referencia — base de la normalización regla→capacidad y del gap-analysis de cobertura.  
> **Relacionado-con:** capability-map · program-registry-s500 · program-registry-s151

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

## Catálogo Canónico BC-XX — Modelo Lógico de Negocio

> Identificadores canónicos del Gemelo Cognitivo. BIAN es referencia, no clave primaria.
> Adoptado: 2026-07-23 · Opción A · 20 capacidades documentadas + 2 gaps reservados.
> **Fuente de verdad única**: este catálogo define la jerarquía de 5 niveles (Dominio → Subdominio → Capacidad → Proceso → Reglas). Los `cap-*.md` usan BC-XX como ID primario en su header.

| BC-ID | Slug | Nombre canónico (ES) | BIAN ref | Sistema | Archivo |
|-------|------|----------------------|----------|---------|---------|
| BC-01 | tel | Atención en Ventanilla | 2.1.1 Teller | S500 | cap-tel.md |
| BC-02 | tar | Cajeros y PoS | 2.2.6 ATM + 2.2.7 PoS | S500 | cap-tar.md |
| BC-03 | hld | Portafolio del Cliente | 4.1.2 Holdings | S500+S151 | cap-hld.md |
| BC-04 | — | Interfaz ACL GL | — | AMBOS | *gap técnico — L002R2..R5 · build-boundaries.py Wave 0* |
| BC-05 | dep | Cuentas de Depósito | 5.1.1 Deposits | AMBOS | cap-dep.md |
| BC-06 | pay | Pagos e Interbancario | 6.1.3 Payments | S500 | cap-pay.md |
| BC-07 | sta | Estados de Cuenta | 6.1.4 Statements | S500 | cap-sta.md |
| BC-08 | int | Intereses y Comisiones | 6.1.5 Interest & Fees | S500 | cap-int.md |
| BC-09 | adj | Ajustes GL | 6.7.1 (P312) + 6.7.2 (P330/P360) | AMBOS | cap-adj.md |
| BC-10 | cmp | Cumplimiento Regulatorio | 6.5.2 Compliance & Regulation | AMBOS | cap-cmp.md |
| BC-11 | rec | Reconciliación Financiera | 6.7.1 Financial Reconciliation | S151 | cap-rec.md |
| BC-12 | orc | Reconciliación Operacional | 6.7.2 Operational Reconciliation | AMBOS | cap-orc.md |
| BC-13 | gl | Contabilidad GL | 7.1.1 Finance (GL) | S151 | cap-gl.md |
| BC-14 | sch | Programación Batch | 8.1.1 Scheduling | AMBOS | cap-sch.md |
| BC-15 | ods | Almacén Operacional DMSII | 9.1.1 Operational Data Stores | AMBOS | cap-ods.md |
| BC-16 | sec | Seguridad y Control de Acceso | 10.1.1 Access Control + T.3.5 Security | AMBOS | cap-sec.md |
| BC-17 | mq | Mensajería Asíncrona MCP | T.2.3 MQ / Async | S500 | cap-mq.md |
| BC-18 | rpt | Control Batch y Extracción Regulatoria | T.3.4 Batch Control & Regulatory Extraction | S151 | cap-rpt.md |
| BC-19 | cfr | Pipeline Regulatorio CFR — CNBV Serie B | T.4.1 CFR Regulatory Reporting Pipeline | S151 | cap-cfr.md |
| BC-20 | wfl | Orquestador WFL Batch | T.5.1 Batch Orchestration / WFL Orchestrator | AMBOS | cap-wfl.md |
| BC-21 | cpe | Captación Productiva Especial | T.6.1 CPE Captación Productiva Especial | S500 | cap-cpe.md |
| BC-22 | — | *(reservado)* | — | — | — |
| BC-23 | spei | SPEI e Interfaces Banxico | T.1.3 Payment Schemes (SPEI/CLABE) | S500 | *gap — sin cap-*.md aún* |

> **Notas:**
> - BC-04 es un bounded context técnico (Anti-Corruption Layer S500→S151), no una capacidad de negocio. Vive en `build-boundaries.py` y Wave 0 ENCAPSULATE.
> - BC-23 está cubierta funcionalmente en cap-pay.md e cap-int.md pero requiere cap-spei.md propio (pendiente).
> - 6.6.1 Financial Servicing (BIAN) está integrada dentro de BC-05 (cap-dep.md) — no tiene cap independiente.
> - BC-22 reservado para expansión futura.

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
| T.2.3 | Transversal · Interfaces & Seguridad | Internal Interfaces | MQ / Async (L091 y L093) | ✓ | | |
| T.2.4 | Transversal · Interfaces & Seguridad | Internal Interfaces | Others | | | |
| T.3.1 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Master Data Mgmt. | | | |
| T.3.2 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Metadata Mgmt. | | | |
| T.3.3 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Content Mgmt. | | | |
| T.3.4 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Batch Control & Regulatory Extraction | | ✓ | |
| T.3.5 | Transversal · Interfaces & Seguridad | Datos & Seguridad | Security | | | ✓ |
| T.4.1 | Transversal · Interfaces & Seguridad | Reporting & Regulatorio | CFR Regulatory Reporting Pipeline | | ✓ | |
| T.5.1 | Transversal · Interfaces & Seguridad | Batch & Orquestación | Batch Orchestration / WFL Orchestrator | | | ✓ |
| T.6.1 | Transversal · Interfaces & Seguridad | Captación Especial | CPE Captación Productiva Especial | ✓ | | |

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
| T · Transversal | 16 | 3 | 2 | 2 | 7 | 9 |
| **TOTAL** | **107** | **13** | **4** | **6** | **23** | **84** |

---

## Por capacidad cubierta — referencia rápida para poblar reglas

### Capacidades S500 (13)

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
| T.2.3 | MQ / Async (L091 y L093) | S500 · Asíncrona MCP | L091/L093 — mayor fan-out S500 (67 llamadores) |
| T.6.1 | CPE Captación Productiva Especial | S500 · CPE Mensual | RMENSUALCPE — proceso CPE mensual de captación especial |

### Capacidades S151 (4)

| ID | Capacidad | Sistema en portal | Contexto MCP |
|----|-----------|-------------------|--------------|
| 6.7.1 | Financial Reconciliation | S151 · Conciliación GL | P##_CONCILIACION — cuadre S500↔S151 |
| 7.1.1 | Finance (GL) | S151 · Libro Mayor General | P##_GL_ENTRY + P##_CIERRE_DIARIO — mayor fan-out S151 (52) |
| T.3.4 | Batch Control & Regulatory Extraction | S151 · Control Ciclo Batch | P677 (gate-keeper diario) · P610 (dispatcher batch) · P612 (WFL launcher) · P199 (bridge S500→S151) — P120 reclasificado a T.4.1 (QC 2026-07-20) |
| T.4.1 | CFR Regulatory Reporting Pipeline | S151 · Reporting Regulatorio | P130 (CFR extract) + P131 (CFR translate) + P120 (SAR Banxico) — SETID=BNMEX hardcodeado |

> **BC-09 Ajustes GL** — agrupación interna de S151 que abarca P312 (6.7.1 Financial Reconciliation: genera SALDOS084 para S084) y P330/P360 (6.7.2 Operational Reconciliation: extracción+integración GL cross-instancia DMSII). BC-09 NO tiene un único ID BIAN propio: sus programas se distribuyen entre 6.7.1 (P312) y 6.7.2 (P330/P360) según función. Este bounded context corresponde a BC-09 en kb-capa5-fronteras.md.

### Capacidades compartidas AMBOS (6)

| ID | Capacidad | Sistema en portal | Contexto MCP |
|----|-----------|-------------------|--------------|
| 6.5.2 | Compliance & Regulation | S500+S151 · CNBV | Reportes regulatorios + SPEI regulatorio |
| 6.7.2 | Operational Reconciliation | S500+S151 · Cuadre Operativo-Contable | JOINT_RECONCILIATION nocturno |
| 8.1.1 | Scheduling | S500+S151 · Batch Scheduler MCP | WFL MASTER JOB — mayor fan-out total (218) |
| 9.1.1 | Operational Data Stores | S500+S151 · DMSII Bases de Datos | BDB04 (S500) + BD10 TxReg (diario movimientos — NO el GL) + BD11 GL Balance (B72POSCONTA SDOANT/CARGOS/ABONOS/SDOACT — el GL real) sobre Unisys DMSII |
| T.3.5 | Security | S500+S151 · Seguridad MCP | L010_CONTROL (gate) + P655_SCRAMBLING (PCI-DSS) |
| T.5.1 | Batch Orchestration / WFL Orchestrator | S500+S151 · Orquestador Batch | WFL LINEA · WFL LOTE · WFL23 — flujos de control batch compartidos |

---

## Por programa S151 — qué capacidades cubre cada programa

> **Fuente de los procesos**: `DOMDATA.s151` del portal HTML (usa notación genérica `P##`).
> Los nombres reales de los programas S151 en scope (P109, P112, P108, P130, P131, P150, P021, P103, P120) provienen del catálogo `rules-s151.md`. El mapeo programa→capacidad es una inferencia basada en la descripción funcional del portal; debe validarse contra el catálogo de reglas.

| Proceso funcional (HTML) | Programa real (inferido) | Capacidades bancarias | ID(s) |
|--------------------------|--------------------------|----------------------|-------|
| registra asiento contable (débito/crédito GL) | P109 · P108 · P130 · P131 | Finance (GL) | 7.1.1 |
| cierre contable diario (batch regulatorio) | P109 · P108 | Finance (GL) · Compliance & Regulation | 7.1.1 · 6.5.2 |
| interfaz Citi ALR/AHR/OCM (BRANCH=484) + reportes CNBV CUIF R01-R04 | P150 | Financial Reconciliation · Batch Control & Regulatory Extraction · Compliance & Regulation | 6.7.1 · T.3.4 · 6.5.2 |
| conciliación GL vs operativo (S500↔S151) | P112 | Financial Reconciliation · Operational Reconciliation | 6.7.1 · 6.7.2 |
| control de gate batch (L_CONTROL_GL) | P021 | Scheduling · Compliance & Regulation | 8.1.1 · 6.5.2 |
| consulta libro mayor / GL balance (L_BOOK) | P103 | Finance (GL) · Operational Data Stores | 7.1.1 · 9.1.1 |

### Tabla consolidada por programa real

| Programa | Función principal | Capacidades bancarias | Fuente del mapeo |
|----------|------------------|-----------------------|-----------------|
| P108 | GL Ledger Writing — escritura de asientos en libro mayor | Finance (GL) [7.1.1] | Inferido del portal |
| P109 | GL Posting — contabilización de movimientos diarios | Finance (GL) [7.1.1] · Compliance & Regulation [6.5.2] | Inferido del portal |
| P112 | Reconciliation — cuadre S500↔S151 | Financial Reconciliation [6.7.1] · Operational Reconciliation [6.7.2] | Inferido del portal |
| P120 | SAR Extractor — extracción regulatoria SAR Banxico | CFR Regulatory Pipeline [T.4.1] | Reclasificado de 6.7.1 → T.4.1 (QC 2026-07-20) |
| P130 | Accounting Translation — traducción contable de movimientos | Finance (GL) [7.1.1] · Compliance & Regulation [6.5.2] | Inferido del portal |
| P131 | Accounting Translation (variante) | Finance (GL) [7.1.1] | Inferido del portal |
| P150 | Citi Interface ALR/AHR/OCM — interfaz Citibank (contraparte de P108) · BRANCH=484 hardcoded · genera reportes CNBV CUIF R01-R04 | Financial Reconciliation [6.7.1] · Batch Control & Regulatory Extraction [T.3.4] · Compliance & Regulation [6.5.2] | Reclasificado 7.1.1 → 6.7.1 (QC 2026-07-21) |
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

---

## Relaciones inter-capacidad (dep-flow)

> Dependencias funcionales entre capacidades — **35 edges validados contra código fuente S500+S151 mediante swarm de 5 agentes (2026-07-21)**. Representadas como edges `dep-flow` en `portal/knowledge-graph.html` y son el insumo principal para la arquitectura de migración por waves.

### Patrón de orquestación (T.5.1 — 14 dependencias de salida)

| Capacidad origen | → | Capacidad destino | Justificación (programa) |
|-----------------|---|------------------|--------------------------|
| T.5.1 Batch Orchestration | → | 7.1.1 Finance GL | WFL LOTE/LINEA lanza P014+P109 · cadena GL completa |
| T.5.1 Batch Orchestration | → | T.4.1 CFR Pipeline | WFL LOTE lanza P130+P131 · bloque regulatorio |
| T.5.1 Batch Orchestration | → | 6.7.1 Financial Reconciliation | WFL LOTE lanza P112+P178 · cuadre post-GL |
| T.5.1 Batch Orchestration | → | 6.1.5 Interest & Fees | WFL LINEA habilita P130-S500 con flags DIA30/DIA15 |
| T.5.1 Batch Orchestration | → | 6.1.4 Statements | WFL LOTE encadena P158 MOVSXCONT |
| T.5.1 Batch Orchestration | → | 5.1.1 Deposits | WFL LOTE encadena P144 BIT-ACTBANDERA (5.1.1) |
| T.5.1 Batch Orchestration | → | 6.7.2 Operational Reconciliation | WFL LOTE encadena ORC S500_INC |
| T.5.1 Batch Orchestration | → | 6.1.3 Payments | WFL23 activa P020 divestiture Citi→Banamex |
| T.5.1 Batch Orchestration | → | BC-09 Ajustes GL [6.7.2] | WFL LOTE lanza P080/P330/P360 |
| T.5.1 Batch Orchestration | → | 2.1.1 Teller | WFL LINEA habilita P010 via COMS SUBETODOS |
| T.5.1 Batch Orchestration | → | T.2.3 MQ / Async | WFL LOTE lanza P091/P093 (async routing) |
| T.5.1 Batch Orchestration | → | 4.1.2 Holdings | WFL LOTE S500 lanza P050 ADSALDOS |
| T.5.1 Batch Orchestration | → | 8.1.1 Scheduling | WFL LOTE lanza P038 Monitor + P602 CALLLIBCTL |
| T.5.1 Batch Orchestration | → | 9.1.1 Operational Data Stores | WFL SPLUNK lanza P810 STSTOTALES |

### Flujos de datos hacia GL (7.1.1 como libro mayor central)

| Capacidad origen | → | Capacidad destino | Justificación (programa) |
|-----------------|---|------------------|--------------------------|
| 6.1.3 Payments | → | 7.1.1 Finance GL | P020 → S151REGISTRA CVE TIPO-PROC 33-37 (RN-S500-108) |
| 6.1.5 Interest & Fees | → | 7.1.1 Finance GL | P130 genera CVE 3000/4009/809 via S151REGISTRA (RN-S500-091/092/093) |
| 8.1.1 Scheduling | → | 7.1.1 Finance GL | P103 CIERRE DIARIO habilita ciclo posting GL |
| 5.1.1 Deposits | → | 7.1.1 Finance GL | Conciliación BD01↔BD03 produce entries GL de cuadratura |
| 6.7.1 Financial Reconciliation | → | 7.1.1 Finance GL | P199 escribe B08TDMIGCAP consumido por GL postings (T-RPT-001) |

### Flujos de datos desde GL (7.1.1 como fuente regulatoria)

| Capacidad origen | → | Capacidad destino | Justificación (programa) |
|-----------------|---|------------------|--------------------------|
| 7.1.1 Finance GL | → | T.4.1 CFR Pipeline | P109 produce BD02ADSALDO; P120 SAR la consume |
| 7.1.1 Finance GL | → | 6.7.1 Financial Reconciliation | B70SXPOSICION poblada por P109; P178 espera STABDSAL=3 |
| 7.1.1 Finance GL | → | T.3.4 Batch Control | P670 lee MOVIMIENTOS finalizados post-P108/P109 (RN-S151-608) |
| 7.1.1 Finance GL | → | 6.1.4 Statements | P158 lee BD10 via S151LIBCONTROL/BD99 (T-STA-012) |

### Flujos regulatorios y de compliance

| Capacidad origen | → | Capacidad destino | Justificación (programa) |
|-----------------|---|------------------|--------------------------|
| 4.1.2 Holdings | → | 6.5.2 Compliance & Regulation | P052 genera CONLI CNBV R10 obligatorio (T-HLD-017, RN-S151-319) |
| 6.7.1 Financial Reconciliation | → | T.3.4 Batch Control | P112 produce Reporte punteo CNBV B-0111B (T-REC-016) |

### Flujos hacia infraestructura de datos

| Capacidad origen | → | Capacidad destino | Justificación (programa) |
|-----------------|---|------------------|--------------------------|
| T.2.3 MQ / Async | → | 6.1.3 Payments | L091/L093 ROUTING → REGISTRAS500 |
| 2.2.6 ATM | → | 6.1.3 Payments | P630 TARINTERCAM → P020 cargos/abonos |
| 4.1.2 Holdings | → | 6.1.3 Payments | P052 genera PG Pagos Interbancarios + SECORE + S274 (T-HLD-020) |
| 6.7.1 Financial Reconciliation | → | 9.1.1 Operational Data Stores | P112 consulta BD99CONTROL; P178 B70SXPOSICION |
| 6.7.2 Operational Reconciliation | → | 9.1.1 Operational Data Stores | P680 vuelca S151BD99CONTROL (6 datasets) |
| BC-09 Ajustes GL [6.7.2] | → | 9.1.1 Operational Data Stores | P330/P360 escriben B20/B21/B70/B72/B80 DMSII (RN-S151-723..745) |
| 4.1.2 Holdings | → | 9.1.1 Operational Data Stores | P050 lee/escribe BD02ADSALDO · 4 operaciones DMSII (T-HLD-004..011) |
| 5.1.1 Deposits | → | 6.1.5 Interest & Fees | P130 recorre BD03 B03-STATUS/B03-SDO-ACTUAL por contrato (RN-S500-086/087) |
| 8.1.1 Scheduling | → | BC-09 Ajustes GL [6.7.2] | P075 CambioDia → INIBATCH notifica P080 |
| T.3.5 Security | → | 5.1.1 Deposits | P655 S500 masking PII en B03CONTRATOS (T-SEC-007, RN-S500-034) |

### Interfaces con sistemas externos

| Capacidad | Sistema externo | Dirección | Justificación |
|-----------|----------------|-----------|---------------|
| 6.7.1 Financial Reconciliation | Citi ALR/AHR/OCM | OUTBOUND | P150 (BRANCH=484) + P151 (BRCH-NBR=485) → IBM-Citibank |
| T.1.3 Payment Schemes | Banxico SPEI | OUTBOUND | P629_CARGABD06 + L040_LIGAS |
| 6.7.2 Operational Reconciliation | Banxico Recon IBA | OUTBOUND | DIFGLO≠0 dispara reporte interbancario (RN-S151-524) |
| T.4.1 CFR Pipeline | CNBV Serie B | OUTBOUND | P130/P131 reportes regulatorios diarios · SETID=BNMEX |
| T.3.4 Batch Control | CECOBAN/ICA | OUTBOUND | P610 F09 → cámara de compensación |
| 5.1.1 Deposits | Teradata / B01CONTRATOS | OUTBOUND | P142 extracción contratos a data warehouse |
| 6.1.5 Interest & Fees | SAT | OUTBOUND | RFC validación + retención ISR obligatoria |
| 7.1.1 Finance GL | DataLake / S264 | OUTBOUND | P109 genera archivo exclusivo DATALAKE (RN-S151-037) |

### Síntesis: mapa de centralidad de capacidades (post-validación swarm)

| Capacidad | Grado entrada | Grado salida | Rol arquitectónico |
|-----------|--------------|--------------|-------------------|
| **T.5.1 Batch Orchestration** | 0 | 14 | **Raíz** — sin dependencias; orquesta todo el batch |
| **7.1.1 Finance GL** | 6 | 4 | **Hub central** — libro mayor; todo fluye hacia y desde él |
| **9.1.1 Operational Data Stores** | 5 | 0 | **Hoja** — solo recibe; BD02/BD07/BD99 DMSII |
| **6.1.3 Payments** | 4 | 1 | Concentrador de canales → GL |
| **6.7.1 Financial Reconciliation** | 2 | 3 | Intermediario — valida GL, produce P199 y reporte CNBV |
| **4.1.2 Holdings** | 1 | 3 | Downstream Holdings → ODS + Pagos + Compliance |
| **5.1.1 Deposits** | 2 | 2 | Bidireccional — BD03 alimenta Intereses; conciliación GL |
| **8.1.1 Scheduling** | 1 | 2 | Gate diario → GL + Adjustments |
| **T.4.1 CFR Pipeline** | 2 | 0 | **Hoja regulatoria** — recibe GL/BD02; genera CNBV Serie B |
| **T.3.4 Batch Control** | 2 | 0 | **Hoja** — recibe GL MOVIMIENTOS y Reconciliation report |
| **6.1.4 Statements** | 2 | 0 | **Hoja** — recibe GL BD10; genera MOVSXCONT→S050/S502 |
| **6.5.2 Compliance & Regulation** | 1 | 0 | **Hoja** — recibe CONLI Holdings; destino regulatorio |

> **Nota de migración — CORRECCIÓN CRÍTICA (QC 2026-07-21)**: Centralidad de grafo ≠ orden de migración. **T.5.1** (0 entradas, 14 salidas) es la raíz del batch — puede modernizarse temprano una vez que sus hijos estén estabilizados. **7.1.1 GL** (6 entradas, 4 salidas) recibe de TODOS los sistemas fuente — DEBE MIGRAR ÚLTIMO (Wave 3+): requiere ≥3 meses de parallel-run de todos sus alimentadores, mínimo 3 cierres contables mensuales validados, y notificación a CNBV (Circular 29/2010) con ≥30 días de anticipación. Los nodos hoja (9.1.1, T.4.1, T.3.4, 6.1.4, 6.5.2) son candidatos prioritarios para Wave 1-2. Las interfaces Citi (P150+P151 → ext-citi, BRCH-NBR=485) son el riesgo de separación más alto — deben desconectarse formalmente antes del cutover GL.

---

*Generado: 2026-07-16 · v1.5 · 2026-07-21 · QC semántico swarm bancario: BD10/BD11 semántica corregida · BC-09 formalizado (6.7.1+6.7.2) · dep-flow labels actualizados · nota migración GL corregida (GL = último, no primero)*
*Cross-referencia: `rules-catalog/rules-s151.md` · `portal/knowledge-graph.html` (dep-flow edges) · `traceability-matrix.md`*
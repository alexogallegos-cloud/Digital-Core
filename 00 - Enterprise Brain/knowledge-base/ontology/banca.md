# Ontología Base — Banca
> Enterprise Brain · Knowledge Base · Ontología de Negocio por Industria
> Versión 2.0 · 2026-10-08 · Digital Core · Accenture México
> Fuente autoritativa: **Accenture Logical Operating Model for Banking — Digital Bank 4.0 Reinvented (L2 View · BIAN Heatmap)**

Clientes del estate: **BanCoppel · Banamex · Santander · MONEX · Gentera**

---

## Identidad

| Campo | Valor |
|-------|-------|
| `system_info.industry` | `banca` |
| `system_info.brain_name` canónico | `bank-brain` |
| Industry SME | `SME/Industry/Industry Banking/` |
| Accounting SME | `SME/Industry/Industry Banking Accounting/` (CUB Anexo 33-36) |
| Modelo canónico | Accenture Logical Operating Model for Banking — Digital Bank 4.0 |
| Catálogo L1/L2 | 28 L1 en 3 agrupaciones L0: STRATEGIZE · OPERATIONALIZE · ENABLE |
| Sin eje LOB/ramo | El eje es el **segmento de cliente** × **producto financiero** (ver abajo) |

---

## Taxonomía de Productos Financieros

Estos son los valores canónicos para `products.name` y `products.category`. Corresponden a los product lines del modelo Digital Bank 4.0.

| Categoría | Productos |
|-----------|-----------|
| **Depósitos & Transaccional** | Deposits · Savings · Money Transfer · Checking |
| **Crédito al consumo** | Overdrafts · Secured · Unsecured · Mortgages · HELCO · Structured · Real Estate |
| **Tarjetas** | Cards |
| **Arrendamiento & Factoraje** | Leasing · Factoring |
| **Inversión & Capital** | Asset · Guarantee · Trade · Project · Debt Capital · Equity Capital |
| **Mercados** | Equities · Fixed Income · Foreign Exchange · Commodities · Derivatives · Securities |
| **Retiro & Fondos** | Retirement · Funds · Private Equity |
| **Especiales** | DSO/CL · Life · P&C · Domestic Payments · International Pay · Nontraded Assets · Financing |

---

## Segmentos de Cliente

Corresponden a `stakeholders` o a una dimensión `segment` en `capabilities`. El modelo Digital Bank 4.0 define seis segmentos:

| Segmento | Descripción | Productos principales |
|----------|-------------|----------------------|
| **Young Gen** | Jóvenes / primera cuenta | Savings · Money Transfer · Cards |
| **Retail** | Personas físicas | Checking · Mortgages · Cards · Deposits |
| **Commercial** | PyMEs y empresas medianas | Lending · Trade Finance · Leasing · Factoring |
| **Mid Cap** | Empresas medianas a grandes | Structured · Debt Capital · Derivatives |
| **Large Cap** | Corporativos y grandes empresas | Capital Markets · Equity · Treasury |
| **Public** | Gobierno y sector público | Guarantee · Project Finance · Debt Capital |

---

## Modelo de Capabilities — Digital Bank 4.0

Estructura canónica: **L0 → L1 → L2**. Las cajas con borde rojo en el BIAN Heatmap del modelo indican qué L2 tienen equivalente en BIAN Service Landscape v14.

---

### L0: STRATEGIZE

| L1 | L2 | BIAN mapping | Tablas brain.db | Regulador relevante |
|----|-----|-------------|-----------------|---------------------|
| **Enterprise Strategy & Performance Management** | Enterprise Strategy Management · Enterprise Performance Management | — | `capabilities` · `kpis` | — |
| **Business Portfolio Management** | Portfolio Planning & Strategy · Market & Opportunity Analysis · Organic Portfolio Development · Inorganic Portfolio Development | — | `capabilities` · `products` | CNBV (M&A bancarias) |
| **Stakeholder Relationship Management** | Stakeholder Management Strategy · Stakeholder Interaction Management & Monitoring | — | `capabilities` · `stakeholders` | CNBV · CONDUSEF |
| **Enterprise Sustainability** | ESG Strategy · ESG Risk Management · ESG Reporting & Performance Management · Stakeholder Engagement | — | `capabilities` · `regulatory_obligations` | CNBV (criterios ASG) · Banxico |
| **Brand Strategy** | Market & Customer Analysis · Brand Establishment & Execution · Brand Enhancement | — | `capabilities` | CONDUSEF (publicidad financiera) |
| **Innovation** | Innovation Strategy · Ideation Strategy · Innovation Culture | — | `capabilities` | CNBV (sandbox regulatorio) · Banxico (Ley Fintech) |

---

### L0: OPERATIONALIZE

| L1 | L2 | BIAN mapping | Tablas brain.db | Regulador relevante |
|----|-----|-------------|-----------------|---------------------|
| **Marketing** | Marketing Intelligence · Marketing Strategy & Planning · **Channel & Content** · **Promotional Marketing** · Marketing Operations | ✓ parcial | `capabilities` · `journeys` | CONDUSEF (publicidad) · PROFECO |
| **Sales** | Sales Strategy & Planning · **Pricing Management** · **Sales Execution** · Sales Enablement | ✓ parcial | `capabilities` · `rules` (tasas, CAT) | CNBV · CONDUSEF (CAT, RESBA) |
| **Customer Service** | **Customer Onboarding & Management** · **Service Operations** · **Service Enablement** · **AML/KYC Compliance** | ✓ completo | `capabilities` · `journeys` · `rules` (KYC) · `regulatory_obligations` | CNBV · CONDUSEF · UIF (AML/KYC) |
| **Customer Experience** | CX Design · **CX Management** · Loyalty & Member Program | ✓ parcial | `capabilities` · `journeys` | CONDUSEF (NPS, quejas) |
| **Ecosystem & Partner Management** | Ecosystem Design · Ecosystem Orchestration | — | `capabilities` · `external_systems` · `suppliers` | Banxico (Open Finance) · CNBV |
| **Product Design & Development** | Product Research · **Product Development** · **Product Launch** · Product Lifecycle Management | ✓ parcial | `capabilities` · `products` | CNBV (autorización de productos) · CONDUSEF (nota técnica) |
| **Cross Products Processing & Servicing** | **Origination** · **Contract Servicing** · **Payment Services** · **Cards & Merchants Processing & Servicing** · **Cash Management** · **Interest & Fees Management** · **Clearing & Settlement Service** · **Collection & Defaults Management** · **Collateral Management** · **Fraud & AML** | ✓ completo | `capabilities` · `components` · `rules` · `journeys` · `regulatory_obligations` | Banxico (SPEI · CECOBAN) · CNBV · UIF |
| **Banking Products Operations Management** | **Lending Management** · **Deposits Management** · **Cards & Merchant Management** · **Wealth Management** · Insurance · **Trade Finance Management** · **Mutual Funds** · **Equity** · **Treasury Banking Management** · Off-balance (Factoring · Leasing · Confirming) | ✓ mayoritario | `capabilities` · `products` · `rules` · `journeys` | CNBV · Banxico · IPAB (depósitos) |
| **Enterprise Risk Management** | Enterprise Risk Management Strategy · Enterprise Risk Evaluation & Assessment · Enterprise Risk Operations | — | `capabilities` · `rules` · `regulatory_obligations` · `kpis` (SCR · LCR · NPL) | CNBV (Basilea III) · Banxico |

---

### L0: ENABLE

| L1 | L2 | BIAN mapping | Tablas brain.db | Regulador relevante |
|----|-----|-------------|-----------------|---------------------|
| **Finance** | Invoice to Pay · Accounts Receivables · Record to Report · Business Consolidation & Reporting · Financial Planning & Analysis · Tax · Treasury | — | `capabilities` · `data_entities` · `regulatory_obligations` | CNBV (CUB · CUOEF) · SAT |
| **Business Process Management** | BPM Strategy & Governance · BPM Execution · BPM Architecture & Methods · BPM Technology & Platform · BPM Enablement & Support | — | `capabilities` · `processes` | — |
| **Business Resilience** | Business Resilience Strategy · Business Resilience Operations | — | `capabilities` · `slos` · `findings` | CNBV (DRAP) · Banxico |
| **Enterprise Security** | Security Strategy & Business Alignment · **Security Diagnostics & Operations** | ✓ parcial | `capabilities` · `regulatory_obligations` · `technology_components` | CNBV (DIARI) · INAI (datos personales) |
| **Governance & Compliance** | Enterprise Governance Management · Compliance Management | — | `capabilities` · `regulatory_obligations` | CNBV · Banxico · UIF |
| **Information Technology** | **IT Operations** · **IT Service Management** | ✓ completo | `capabilities` · `itom_layer` · `technology_components` | — |
| **Infrastructure & Facility Management** | Real Estate Management · Facility Management · Technology Infrastructure Control | — | `capabilities` · `technology_components` | — |
| **Knowledge & Document Management** | Knowledge & Document Management Strategy · Knowledge Management Operations | — | `capabilities` · `knowledge_gaps` | CNBV (expedientes) |
| **Legal & Regulatory Affairs** | Legal Services Management · Regulatory Affairs Management · **Responsible AI** | — | `capabilities` · `regulatory_obligations` | CNBV · Banxico · INAI |
| **HR** | HR Strategy · Access Talent · Create Talent · Unlock Potential · Reward · Transition · HR Enablement | — | `capabilities` · `stakeholders` | IMSS · STPS · SAT |
| **Data Management** | Enterprise Data Strategy · Master Data Management · Data Operations · Data Lifecycle Management | — | `capabilities` · `data_entities` · `knowledge_lineage` | CNBV (gobierno de datos) · INAI · Banxico (Open Finance) |
| **Insights & Analytics** | Marketing Analytics · Research & Development Analytics · Sourcing & Procurement Analytics · Operations Intelligence & Monitoring · Financial Controlling & Reporting Analytics · HR Analytics · Business Foundation Analytics | — | `capabilities` · `data_entities` · `kpis` | CNBV (reportes) · Banxico |
| **Supply Chain** | Supply Chain Relationships & Partnerships · Sourcing & Procurement Analytics · Supply Chain Procurement | — | `capabilities` · `suppliers` | SAT · SHCP |

**Nota BIAN Heatmap**: las celdas marcadas ✓ en la columna BIAN son las que tienen equivalente en BIAN Service Landscape v14 y deben declararse en `ontology_bindings` con `model_type='bian'` además del `model_type='etb'`. El dominio BIAN correspondiente se resuelve en el Industry Banking SME.

---

## Ontología de Procesos

`process_ontology` en `system_info`: `banking-mx`

Los procesos de negocio corresponden principalmente al L0 **OPERATIONALIZE** — es donde vive la operación del banco. STRATEGIZE genera decisiones y objetivos; ENABLE provee las capacidades de soporte. En brain.db, `processes` modela los procesos de OPERATIONALIZE y los procesos de ENABLE que tienen ciclo de vida propio (Finance, Risk, Compliance).

### L1 — Procesos Canónicos (mapeo al modelo Digital Bank 4.0)

| Proceso L1 | Origen en modelo | Regulador rector | `process_id` sugerido |
|-----------|-----------------|-----------------|----------------------|
| **Captación y Depósitos** | Banking Products Ops: Deposits Management | CNBV · IPAB · CONDUSEF | `P-DEP-001..N` |
| **Crédito** | Cross Products: Origination + Banking Ops: Lending | CNBV · CONDUSEF · Buró de Crédito | `P-CRE-001..N` |
| **Tarjetas** | Cross Products: Cards + Banking Ops: Cards & Merchant | CNBV · Banxico · CONDUSEF | `P-TAR-001..N` |
| **Pagos & Transferencias** | Cross Products: Payment Services + Clearing & Settlement | Banxico · CECOBAN · CNBV | `P-PAG-001..N` |
| **Wealth & Inversiones** | Banking Ops: Wealth Management + Mutual Funds + Equity | CNBV · Banxico | `P-INV-001..N` |
| **Tesorería** | Banking Ops: Treasury Banking Management + Finance: Treasury | Banxico · CNBV | `P-TES-001..N` |
| **Banca Empresarial / Trade** | Banking Ops: Trade Finance + Off-balance | CNBV · Banxico · SHCP | `P-EMP-001..N` |
| **Seguros Bancarios** | Banking Ops: Insurance | CNSF · CNBV | `P-SEG-001..N` |
| **Cobranza & Recuperación** | Cross Products: Collection & Defaults + Collateral | CNBV · CONDUSEF | `P-COB-001..N` |
| **AML/KYC** | Customer Service: AML/KYC Compliance + Cross Products: Fraud & AML | UIF · CNBV · Banxico | `P-AML-001..N` |
| **Onboarding de Cliente** | Customer Service: Customer Onboarding & Management | CNBV · CONDUSEF · INAI | `P-ONB-001..N` |
| **Open Banking / CAN** | Ecosystem & Partner Mgmt + Product D&D (APIs) | Banxico Circ. 6/2025 | `P-CAN-001..N` |
| **Reporting Regulatorio** | Finance: Record to Report + Business Consolidation | CNBV (CUB · CUOEF) · Banxico | `P-REP-001..N` |
| **Gestión de Riesgo** | Enterprise Risk Management (todos los L2) | CNBV (Basilea III) · Banxico | `P-RSK-001..N` |

---

## Reguladores Rectores

### Mapa Regulatorio Banca México

| Regulador | Tipo | Jurisdicción | Capabilities L1 afectadas | Tablas brain.db |
|-----------|------|-------------|--------------------------|-----------------|
| **CNBV** | Prudencial + conducta | Banca, casas de bolsa, fondos, SOFOMES reguladas | Governance & Compliance · Enterprise Risk · Finance · Sales · Customer Service · Legal & Regulatory | `regulatory_obligations` · `rules` · `capabilities` |
| **Banxico** | Banco central | Sistemas de pago · política monetaria · Open Finance · tipo de cambio | Cross Products Processing · Ecosystem & Partner Mgmt · Banking Products Ops (Treasury) | `regulatory_obligations` · `components` · `journeys` |
| **CONDUSEF** | Protección al usuario | Transparencia · RESBA · Buró de Entidades · disputas | Sales (CAT) · Customer Service · Customer Experience | `regulatory_obligations` · `rules` (texto de producto) |
| **IPAB** | Seguro de depósito | Protección hasta 400K UDIS/depositante/institución | Banking Products Ops: Deposits Management | `regulatory_obligations` |
| **UIF** | Inteligencia financiera (SHCP) | PLD/FT · SAR · PEPs · FATF | Customer Service: AML/KYC · Cross Products: Fraud & AML | `regulatory_obligations` · `rules` (lógica AML) · `vocabulary` |
| **SAT / SHCP** | Fiscal | CFDI · ISR · BEPS · FATCA/CRS | Finance (Tax) · Supply Chain | `regulatory_obligations` · `data_entities` |
| **INAI** | Datos personales | LFPDPPP — CRM · lealtad · Open Finance | Data Management · Customer Onboarding · Legal & Regulatory: Responsible AI | `data_entities.sensitivity_level` · `regulatory_obligations` |
| **CECOBAN** | Clearing interbancario | TEF · SPEI-E · cheques · CoDi | Cross Products: Clearing & Settlement | `components` · `journeys` |
| **IMSS / STPS** | Laboral | Nómina · contratos | HR (Enablement) | `regulatory_obligations` (solo si ITOM cubre HR ops) |

### Instrumentos Normativos Clave

| Instrumento | Emisor | L1 afectada | Impacto en brain.db |
|-------------|--------|------------|---------------------|
| **CUB — Circular Única de Bancos** | CNBV | Finance · Governance · Enterprise Risk | Plan de cuentas en `data_entities` · estructura reporting en `regulatory_obligations` |
| **Circular 6/2025 (CAN / Open Finance)** | Banxico | Ecosystem & Partner Mgmt · Product D&D | APIs en `capabilities` (P-CAN) · datos compartibles en `data_entities` · consentimiento en `rules` |
| **Circular 3/2012 (SPEI)** | Banxico | Cross Products: Payment Services · Clearing | Flujos SPEI en `journeys` · componentes en `components` |
| **LISF** | Congreso (CNSF) | Banking Products Ops: Insurance | Solo si banco tiene subsidiaria aseguradora · `regulatory_obligations` |
| **Ley Fintech (LRITF)** | Congreso (CNBV/Banxico) | Innovation · Ecosystem & Partner Mgmt | API obligations · sandbox · `capabilities` |
| **CUOEF / SIPRES** | CNBV | Finance: Business Consolidation | Reporting periódico · `components` (generadores) · `rules` (cálculos regulatorios) |
| **Disposiciones ALD/FT** | UIF | Customer Service: AML/KYC + Cross Products: Fraud & AML | KYC · PEPs · umbral SAR · `rules` + `vocabulary` |
| **Basilea III (adopción CNBV)** | CNBV | Enterprise Risk Management · Finance | Capital · RCSA · LCR/NSFR → `kpis` + `regulatory_obligations` |
| **DIARI (Ciberseguridad)** | CNBV | Enterprise Security | Controles de seguridad TI · `regulatory_obligations` · `technology_components` |
| **DRAP (Continuidad)** | CNBV | Business Resilience | BCP/DRP · `slos` · `regulatory_obligations` |
| **LFPDPPP** | INAI | Data Management · Customer Onboarding | Datos sensibles de clientes · `data_entities.sensitivity_level` |

---

## Cadena de Valor — Banca

### Top-down: Producto → Código

```
products                   ← Tarjeta de crédito · Crédito hipotecario · Depósito a plazo
    │  (Retail / Mid Cap / Large Cap segment)
    ▼
kpis                       ← Tasa activa/pasiva · NPL · CAT · Churn · NPS · LCR/NSFR
    │
    ▼
processes                  ← Captación · Crédito · Pagos · AML · Onboarding
    │  (process_id del L1 de procesos canónicos)
    ▼
capabilities (L1→L2)       ← "Origination" · "Payment Services" · "AML/KYC Compliance"
    │  (capabilities.l0 = OPERATIONALIZE · capabilities.l1 = Cross Products Processing)
    ▼
components / rules         ← SPs · COBOL · APIs · jobs CTM · reglas de negocio
    │  (rules.reg → instrumento normativo exacto · artículo)
    ▼
technology_components      ← Core bancario · Mainframe z/OS · IBM POWER/AIX · Middleware
    │
    ▼
itom_layer                 ← technology-operations · delivery · information-analytics
```

### Bottom-up: Infra → KPI

```
itom_layer (technology-operations)
    → technology_components (IBM POWER · AIX · z/OS · Oracle · MQ · ESB)
        → components (SPs · COBOL · APIs · schedulers CTM)
            → rules (lógica: intereses · comisiones · límites · detección AML)
                → journeys (flujo SPEI completo · ciclo de crédito · onboarding CAN)
                    → processes (Pagos · Crédito · AML)
                        → capabilities (L2: "Payment Services" · "Origination" · "AML/KYC Compliance")
                            → kpis (Tx/día · Tasa rechazo · NPL · LCR)
                                → products (Tarjeta · Crédito hipotecario)
```

### Correlación Regulatoria (ejemplo end-to-end)

Un componente SP que calcula el interés de un crédito personal:
- `capabilities.l2` = "Interest & Fees Management" (L0: OPERATIONALIZE)
- `processes.id` = P-CRE-003
- `products.name` = Crédito personal · Retail segment
- `regulatory_obligations`: CNBV (CUB — tasa máxima) + CONDUSEF (CAT transparente)
- `rules.reg` = CUB + Circular CAT
- `knowledge_lineage.tier` = gold (código productivo en ejecución)
- `kpis` afectados: tasa activa media, CAT promedio

---

## ITOM — Dominios y Casos de Uso de IA

| Dominio ITOM | Capabilities L1 del modelo | Casos de uso de IA | KPI que mueve |
|-------------|--------------------------|-------------------|---------------|
| `customer-engagement` | Marketing · Sales · Customer Experience · Customer Service | Personalización desde journeys reales · churn prediction · NPS desde señales de operación | NPS · Churn · Conversión |
| `it-strategy` | Enterprise Strategy · Business Portfolio Mgmt · Innovation | 7R con cadena de valor · gap analysis ETB · portfolio rationalization | ROI TI · Coverage ETB |
| `delivery` | Product Design & Development · BPM (Technology & Platform) | Code gen · casos de prueba desde DISCOVER · specs API Open Finance | Time-to-market · Defect rate |
| `technology-operations` | Information Technology · Infrastructure & Facility · Business Resilience | RCA asistido · runbooks · correlación incidente-código · anomaly detection | MTTR · Disponibilidad |
| `information-analytics` | Data Management · Insights & Analytics · Knowledge & Document Mgmt | Linaje de datos · automatización CUOEF · CAN data map · CFDI reconciliation | Data quality score |
| `it-management` | Governance & Compliance · Enterprise Security · Legal & Regulatory · Finance (FinOps) | Mapeo CNBV/Basilea → código · PLD automatizado · costo TI por producto | Compliance gaps · Cloud cost |

---

## Sin Dimensión LOB — Segmento como Eje

La banca no tiene ramo como eje raíz. El modelo Digital Bank 4.0 usa **segmento de cliente** como eje discriminador:
- `capabilities.segment` (si se agrega): Young Gen · Retail · Commercial · Mid Cap · Large Cap · Public
- `products.category` distingue: depósitos · crédito · tarjetas · inversiones · pagos · seguros bancarios · mercados
- Cuando el banco tiene subsidiaria aseguradora, brain separado (`insurance-brain`) federado al `bank-brain`

---

## Cómo Usar en brain.db

### `system_info`

```sql
industry         = 'banca'
brain_name       = 'bank-brain'           -- solo enterprise
industry_sme     = 'SME/Industry/Industry Banking/'
capability_model = 'etb'                  -- + 'bian' si el cliente adoptó BIAN
process_ontology = 'banking-mx'
regulator        = 'CNBV'               -- regulador principal
itom_model       = 'IT Operating Model v9.0'
itom_sme         = 'SME/Framework/IT Operating Model'
```

### `ontology_bindings`

```sql
-- Negocio (modelo Digital Bank 4.0 / ETB banca)
(model_type='etb',        catalog='Banking_Logical_OM_DB4.0', role='primary',
 regulators='["CNBV","Banxico","CONDUSEF","UIF","IPAB","SAT"]')

-- BIAN (si el cliente adoptó BIAN — e.g. Gentera, Banamex)
(model_type='bian',       catalog='BIAN_SL_v14', role='secondary',
 regulators='["CNBV"]')

-- Regulatorio puro (si el proyecto es CAN/Open Finance)
(model_type='regulatory', catalog='Banxico_Circ6_2025', role='primary',
 regulators='["Banxico"]')

-- TI
(model_type='itom',       catalog='ITOM_v9.0', role='primary', regulators='[]')
```

### `capabilities` — campos clave con L0

```sql
l0        TEXT  -- 'STRATEGIZE' | 'OPERATIONALIZE' | 'ENABLE'
l1        TEXT  -- nombre del dominio L1 (e.g. 'Cross Products Processing & Servicing')
l2        TEXT  -- nombre de la sub-capability (e.g. 'Payment Services')
segment   TEXT  -- segmento de cliente al que aplica; NULL = todos
ontology  TEXT  -- 'etb' | 'bian' | 'regulatory'
bian_ref  TEXT  -- referencia al Service Domain BIAN equivalente (si aplica)
```

### `regulatory_obligations` — estructura mínima

```sql
regulator      -- 'CNBV' | 'Banxico' | 'CONDUSEF' | 'UIF' | 'IPAB' | 'SAT' | 'INAI'
instrument     -- 'CUB' | 'Circular 6/2025' | 'Circular 3/2012' | 'DIARI' | 'ALD/FT' | ...
article        -- artículo específico
applies_to_l1  -- capability L1 del modelo
process_id     -- FK → processes (B22)
tier           -- 'gold' (DOF) | 'silver' (interpretación legal)
```

---

## Del Estate — Lo que los Brains Reales Usan

| Cliente | model_type(s) | L1 predominantes en el brain | Particularidad |
|---------|--------------|------------------------------|----------------|
| BanCoppel (Informix) | `etb` | Cross Products Processing · Banking Ops · Customer Service | 12,812 SPs · proyecto CAN agrega `regulatory` (Circ. 6/2025) |
| Banamex (GemCog) | `etb` + `bian` | Cross Products · Banking Ops · Enterprise Risk | BIAN como lens de mapping sobre S500 Unisys |
| Santander | `etb` + `regulatory` | Cross Products (SPEI/CAN) | Circ. 3/2012 como ontología primaria del proyecto CAN |
| MONEX | `etb` + `value-chain` | Cross Products: Payment Services · Banking Ops: Trade Finance | Payments modernization (SWIFT/ISO20022) |
| Gentera | `bian` | Customer Service · Cross Products: Lending/Origination | BIAN principal; microcrédito como extensión `is_extension=1` |

---

*Ontología Base Banca · Enterprise Brain Knowledge Base · v2.0 · 2026-10-08*
*Fuente: Accenture Logical Operating Model for Banking — Digital Bank 4.0 Reinvented · L2 View · BIAN Heatmap*

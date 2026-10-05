# DT — Capacidades de Negocio Bancario (ETB Framework) · Santander México
> Digital Twin: Modelo de capacidades bancarias alineado al ETB (Enterprise Technology Blueprint)
> Nivel: `santander-brain` — aplica al banco completo, no a un proyecto específico
> Fase: DISCOVER → modelo vivo que evoluciona con cada sistema analizado

---

## Propósito

Construir el **mapa de capacidades de negocio bancario** de Santander México usando el ETB de Banking como marco de referencia — igual a como se hace en BanCoppel (bank-brain/etb-capabilities) y Banamex.

Este DT:
1. Mapea las capacidades ETB Banking L1-L3 al estado actual de Santander
2. Identifica cobertura real (sistemas confirmados), cobertura probable (scaffold) y brechas
3. Sirve como insumo para priorización de modernización, roadmap CAN y oportunidades de negocio
4. Se alimenta de los sistemas conocidos del landscape Santander + proyectos activos

---

## Marco ETB Banking — Estructura L1

El Enterprise Technology Blueprint (ETB) de Banking de Accenture organiza las capacidades en **6 dominios L1**:

| # | Dominio L1 | Slug | Descripción |
|---|------------|------|-------------|
| 1 | Core Banking | `core-banking` | Gestión de cuentas, productos, clientes, transacciones y saldos |
| 2 | Customer & Distribution | `customer-distribution` | CRM, onboarding, KYC, canales, engagement |
| 3 | Payments & Cash Management | `payments-cash` | Pagos domésticos e internacionales, liquidación, gestión de efectivo |
| 4 | Lending & Credit | `lending-credit` | Crédito retail, pyme, corporativo, hipotecario, ciclo de vida |
| 5 | Risk, Compliance & Finance | `risk-compliance` | Riesgo crediticio, mercado, operacional, PLD/AML, regulatorio |
| 6 | Technology & Operations | `technology-ops` | Infraestructura, integración, datos, seguridad, ITSM |

---

## Capacidades ETB L2 — Santander México Coverage

### 1. Core Banking

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| Account Management | `account-mgmt` | `core-banking` | SCAFFOLD | Hipótesis — top 5 banco MX |
| Product Catalog | `product-catalog` | `core-banking` | SCAFFOLD | Crédito nómina, ahorro, chequera |
| Customer Master | `customer-master` | `core-banking` | SCAFFOLD | ~17M clientes |
| Transaction Processing | `tx-processing` | `core-banking` + `card-authorizer` | SCAFFOLD | 24x7 |
| Interest & Charges | `interest-charges` | `core-banking` | SCAFFOLD | — |
| Statement & Reporting | `statements` | `core-banking` + `datawarehouse` | SCAFFOLD | — |

### 2. Customer & Distribution

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| CRM | `crm` | `crm` (Salesforce) | PROBABLE | Santander global usa Salesforce |
| Digital Onboarding | `digital-onboarding` | `supermovil` + `santander-online` | CONFIRMED | SuperMóvil público |
| Mobile Banking | `mobile-banking` | `supermovil` | CONFIRMED | iOS + Android públicos |
| Internet Banking | `internet-banking` | `santander-online` | CONFIRMED | supernet.com.mx |
| Corporate Banking Portal | `corporate-portal` | `santander-empresas` | CONFIRMED | Santander Empresas/Cash |
| ATM Network | `atm-network` | `atm-network` | CONFIRMED | ~7K cajeros CNBV |
| Call Center / IVR | `contact-center` | `call-center` | SCAFFOLD | — |
| Branch Operations | `branch-ops` | — | SCAFFOLD | ~1.4K sucursales |
| POS Acquiring | `pos-acquiring` | `pos-acquiring` | SCAFFOLD | — |
| KYC & Identity | `kyc-identity` | `iam` | SCAFFOLD | Azure Entra ID global |

### 3. Payments & Cash Management

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| SPEI / TEF | `spei-tef` | `payments-engine` + `banxico-spei` | CONFIRMED | Rails Banxico SPEI |
| DiMo / CoDi | `dimo-codi` | `payments-engine` | CONFIRMED | SuperMóvil |
| SWIFT / Internacional | `swift-intl` | `swift-gateway` | SCAFFOLD | Grupo Santander SWIFT |
| Card Payments | `card-payments` | `card-authorizer` + `prosa-link` | SCAFFOLD | PROSA interoperable |
| Payroll (Nómina) | `payroll-payments` | `payments-engine` | CONFIRMED | Crédito de nómina en scope CAN |
| Domiciliación | `domiciliacion` | `payments-engine` | SCAFFOLD | DOMI CAN aplica |
| **CAN — Mecanismo CECOBAN** | `can-cecoban` | `payments-engine` (adaptador) | **BRECHA** | OBL-001…023 pendientes |
| Corresponsales | `corresponsales` | — | SCAFFOLD | — |
| Cash Management | `cash-mgmt` | `treasury` | SCAFFOLD | — |
| FX & Treasury | `fx-treasury` | `treasury` | SCAFFOLD | Mercados |

### 4. Lending & Credit

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| Retail Lending | `retail-lending` | `loans` | CONFIRMED | Crédito de nómina producción |
| Mortgage | `mortgage` | `loans` | CONFIRMED | Crédito hipotecario |
| SME / PyME Lending | `sme-lending` | `loans` | PROBABLE | Crédito PyME |
| Corporate Credit | `corp-credit` | `loans` | SCAFFOLD | — |
| Credit Scoring | `credit-scoring` | `fraud-detection` | SCAFFOLD | ML en canales |
| Collections | `collections` | `core-banking` | SCAFFOLD | — |
| **CAN — Prelación** | `can-prelacion` | `loans` + `core-banking` | **BRECHA** | Motor prelación OBL-016 faltante |
| **CAN — Mandato Digital** | `can-mandato` | `loans` | **BRECHA** | OBL-005 / OBL-018 faltante |
| **CAN — Clave Básica** | `can-clave-basica` | `loans` | **BRECHA** | OBL-009 / OBL-010 faltante |

### 5. Risk, Compliance & Finance

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| Credit Risk | `credit-risk` | `core-banking` + scoring | SCAFFOLD | — |
| Market Risk | `market-risk` | `treasury` | SCAFFOLD | — |
| AML / PLD | `aml-pld` | `pld-engine` | SCAFFOLD | UIF/GAFI |
| Fraud Detection | `fraud-detection` | `fraud-detection` | SCAFFOLD | ML tarjetas |
| CNBV Reporting | `cnbv-reporting` | `cnbv-reporting` | SCAFFOLD | R01-R29, SIPRES |
| Regulatory Compliance | `reg-compliance` | `cnbv-reporting` | SCAFFOLD | DORA grupo |
| Finance & Accounting | `finance-accounting` | `finance-erp` (SAP) | PROBABLE | SAP global |

### 6. Technology & Operations

| L2 | L2 Slug | Sistema Santander | Cobertura | Evidencia |
|----|---------|-------------------|-----------|-----------|
| API Gateway | `api-gateway` | `api-gateway` (Azure APIM) | SCAFFOLD | Azure estratégico |
| Integration / ESB | `esb-integration` | `esb` | SCAFFOLD | — |
| Cloud Platform | `cloud-platform` | `azure-backbone` | CONFIRMED | MS Azure partnership 2021 |
| Identity & Access | `iam-platform` | `iam` (Azure Entra ID) | PROBABLE | Global Santander |
| Data Warehouse | `data-warehouse` | `datawarehouse` | SCAFFOLD | — |
| Analytics & BI | `analytics-bi` | `analytics` | SCAFFOLD | Power BI probable |
| ITSM | `itsm` | `itsm` (ServiceNow) | PROBABLE | Global Santander |
| Security Operations | `secops` | `azure-backbone` (Sentinel) | PROBABLE | Azure Sentinel |

---

## Brechas Críticas — CAN en Scope

Las brechas CAN impactan directamente las capacidades de Lending y Payments:

| Brecha | Capacidad ETB | Sistema afectado | Obligación | Criticidad |
|--------|---------------|------------------|------------|------------|
| BRECHA-SANT-CAN-001 | `can-clave-basica` | `loans` | OBL-009, OBL-010 | CRÍTICA |
| BRECHA-SANT-CAN-002 | `can-cecoban` | `payments-engine` | OBL-001 a OBL-008 | CRÍTICA |
| BRECHA-SANT-CAN-003 | `can-prelacion` | `loans` + `core-banking` | OBL-016 | CRÍTICA |
| BRECHA-SANT-CAN-004 | `can-mandato` | `loans` + `supermovil` | OBL-005, OBL-018 | ALTA |
| BRECHA-SANT-CAN-005 | `payroll-payments` | `payments-engine` | OBL-023 (timing 17:00) | ALTA |

---

## Resumen de Cobertura

| Estado | L2 Capacidades | % |
|--------|----------------|---|
| CONFIRMED | 8 | ~18% |
| PROBABLE | 5 | ~11% |
| SCAFFOLD | 28 | ~63% |
| BRECHA | 5 (CAN) | ~11% |
| **Total** | **46** | 100% |

> Nota: La cobertura SCAFFOLD representa hipótesis técnicas basadas en el patrón de un banco global de la escala de Santander (Top 5 México). Requiere confirmación con documentación real del cliente.

---

## Sistemas Confirmados — Contribución ETB

| Sistema | Slug | Capacidades ETB cubiertas |
|---------|------|---------------------------|
| SuperMóvil | `supermovil` | mobile-banking, digital-onboarding, dimo-codi |
| Santander Online | `santander-online` | internet-banking, digital-onboarding |
| Santander Empresas | `santander-empresas` | corporate-portal, cash-mgmt |
| Red cajeros ATM | `atm-network` | atm-network |
| Banxico SPEI/DiMo | `banxico-spei` | spei-tef, dimo-codi |
| Microsoft Azure | `azure-backbone` | cloud-platform, iam-platform, secops |

---

## Hoja de Ruta — Enriquecimiento del Modelo

| Prioridad | Acción | Fuente |
|-----------|--------|--------|
| 1 | Confirmar código de institución Santander en CECOBAN (40072?) | CECOBAN paquete conectividad |
| 2 | Identificar nombre real del sistema `loans` (SAP LMS? propio?) | Discovery técnico |
| 3 | Identificar nombre real de `core-banking` (Finacle? Temenos? propio?) | Discovery técnico |
| 4 | Confirmar motor `payments-engine` (Temenos Payments? propio?) | Discovery técnico |
| 5 | Validar stack SAP en `finance-erp` | Landscape Grupo Santander |
| 6 | Confirmar Salesforce en `crm` | Landscape global |
| 7 | Mapear L3 dentro de cada dominio L2 para mayor granularidad | Siguiente iteración |

---

## Metodología — Cómo se Actualiza Este DT

1. **Al confirmar un sistema real** (nombre, versión, vendor): actualizar columna "Sistema Santander" y cambiar SCAFFOLD → CONFIRMED o PROBABLE
2. **Al analizar un artefacto de un sistema** (código, docs): ejecutar Regla B10 — propagar hallazgos de capacidades al brain y a este DT
3. **Al cerrar una brecha CAN**: actualizar el estado de la brecha (CERRADA) y la capacidad correspondiente
4. **Al incorporar un nuevo sistema al landscape**: agregar filas a las tablas correspondientes

---

## SMEs Relevantes para Este DT

| Área | SME |
|------|-----|
| Marco ETB Banking | Industry Banking SME |
| Core Banking (loans, cuentas) | Core Banking Transformation SME |
| Pagos (SPEI, CAN, DiMo) | Industry Payments → SPEI SME |
| Regulación Banxico | Regulatory/Banxico SME |
| Cloud y tecnología | IDB — Intelligent Digital Brain SME |

---

## Relación con Brain y Proyecto CAN

- **`santander-brain/brain.db`**: este DT alimenta la tabla `etb_l3` del brain federado
- **`projects/can/digital-brain/brain.db`**: las brechas CAN se mapean a capacidades ETB en este DT
- **`dt-solucion-arquitectura`**: ADRs de CAN alinean con las brechas `can-cecoban`, `can-prelacion`, `can-clave-basica`

---

*Creado: 2026-09-17 · v0.1.0 · Modelo inicial ETB Banking para Santander México · 6 dominios L1 · 46 capacidades L2 · 5 brechas CAN identificadas*

# ETB Insurance P&C — Commercial Lines
> Accenture Enterprise Technology Blueprint · Property & Casualty · v3.0 (junio 2022)
> Adaptado para AXA México · Digital Brain AXA · uso interno Accenture

---

## Estructura del ETB P&C v3.0

El ETB define **11 dominios L1** para P&C Insurance. La arquitectura es idéntica a Life en dominios 1-5 y 7-10; los dominios P&C-específicos son el **6 (Product & Operations)** y el **11 (Artificial Intelligence, nuevo en v3.0)**.

### Dominios L1

| # | Dominio L1 | Sistema(s) AXA | ITOM Layer |
|---|-----------|----------------|------------|
| 1 | Channel Mgmt. | portal-agentes · digital | L1 Business Engagement |
| 2 | Distribution Mgmt. | portal-agentes · crm | L1 Business Engagement |
| 3 | Marketing Mgmt. | crm · digital | L1 Business Engagement |
| 4 | Sales Mgmt. | crm · portal-agentes | L1 Business Engagement |
| 5 | Service Mgmt. | digital · portal-agentes · crm | L1 Business Engagement |
| **6** | **Product & Operations** | policy-admin · claims · billing · underwriting-engine · reinsurance · actuarial | **L2 Core Insurance + L3 Underwriting** |
| 7 | Enterprise Functions | reporting-cnsf · cnsf · solvency | L5 Data & L7 Compliance |
| 8 | Business Integration | api-gateway · event-bus | L4 Integration Fabric |
| 9 | Information Foundation | datawarehouse | L5 Data & Analytics |
| 10 | Business Insights & Analytics | analytics · datawarehouse | L5 Data & Analytics |
| **11** | **Artificial Intelligence** | cross-cutting (todos los sistemas) | Cross-cutting |

---

## Dominio 6 — Product & Operations (núcleo P&C)

### 6.1 Cross Capability (transversal a todos los sub-dominios)

| Capacidad L3 | Sistema AXA | Prioridad |
|-------------|-------------|-----------|
| Billing | billing | Alta |
| Payments | billing · api-gateway | Alta |
| Reinsurance | reinsurance | Alta |
| Actuarial | actuarial | Alta |
| Contract Pages & Correspondence | policy-admin | Media |
| Financial Balancing | billing · reporting-cnsf | Alta |
| Collection Mgmt. | billing | Alta |
| Enterprise Content Mgmt. | digital · portal-agentes | Media |
| Customer Tax Reporting | billing · reporting-cnsf | Alta |
| Fulfillment | policy-admin | Media |
| Fund Mgmt. | actuarial | Media |

### 6.2 Product Mgmt.

| Capacidad L3 | Sistema AXA | Prioridad |
|-------------|-------------|-----------|
| Product Design | underwriting-engine · policy-admin | Alta |
| Impact Analysis & Modeling | actuarial · underwriting-engine | Alta |
| Product Definition | policy-admin | Alta |
| Product Maintenance | policy-admin | Alta |
| Product Testing | underwriting-engine | Media |
| Filing Management | cnsf | Alta — CNSF filing obligatorio |
| Deployment & Monitoring | policy-admin | Alta |
| Product Planning | underwriting-engine | Media |
| Product & Product Plan Creation | policy-admin · underwriting-engine | Alta |

### 6.3 Underwriting & Pricing (corazón diferencial P&C)

| Capacidad L3 | Sistema AXA | Prioridad |
|-------------|-------------|-----------|
| Clearance & Registration | underwriting-engine · crm | Alta |
| Exposure Concentration Management | underwriting-engine · actuarial | Alta — control de cúmulos |
| Account Info / Coordination | crm · portal-agentes | Alta |
| Initial Underwriting | underwriting-engine | Alta |
| Line Setting | underwriting-engine | Alta |
| Facultative Reinsurance | reinsurance · underwriting-engine | Alta |
| Predictive Modeling | underwriting-engine · analytics | Alta — GLM/ML pricing |
| UW Rules & Guidelines | underwriting-engine | Alta |
| Underwriting Authority | underwriting-engine | Alta |
| Risk Qualification & Assessment | underwriting-engine | Alta |
| Pricing Terms & Conditions | underwriting-engine · policy-admin | Alta |
| Quote Proposal | portal-agentes · digital · crm | Alta |
| Negotiation & Decision | portal-agentes · underwriting-engine | Alta |
| Quality & Audit | underwriting-engine · actuarial | Media |

### 6.4 Policy Admin & Serving

| Capacidad L3 | Sistema AXA | Prioridad |
|-------------|-------------|-----------|
| Scheduled Activity Renewal | policy-admin | Alta |
| Submission & Issuance | policy-admin | Alta |
| Rating Quoting | underwriting-engine · policy-admin | Alta |
| Change Policy (Endosos) | policy-admin | Alta |
| Book RoI / Transfer | policy-admin · billing | Media |
| Cancellations & Reinstatements | policy-admin · billing | Alta |
| Policy Storage & Retrieval | policy-admin · datawarehouse | Alta |

### 6.5 Claims

| Capacidad L3 | Sistema AXA | Prioridad |
|-------------|-------------|-----------|
| Intake (FNOL) | claims · digital · portal-agentes | Alta |
| Claim Administration | claims | Alta |
| Allocation (Triaje + Asignación) | claims | Alta |
| Financials (Reservas + Pagos) | claims · billing | Alta |
| Supply Chain / Vendor Mgmt. | claims | Media |
| Recovery (Subrogación) | claims | Alta |
| Adjunct Support / Core Financials | claims · billing · reporting-cnsf | Alta |

---

## Dominio 11 — Artificial Intelligence (nuevo en P&C v3.0)

| Sub-dominio L2 | Casos de uso P&C | Sistema AXA |
|----------------|-----------------|-------------|
| 11.1 Machine Learning | Pricing predictivo, fraud scoring, churn | underwriting-engine · analytics |
| 11.2 Deep Learning | AI damage assessment (fotos → estimado daño) | claims |
| 11.3 Natural Language Processing | Chatbot FNOL, extracción de contratos, NLP regulatorio | digital · claims |
| 11.4 Computer Vision | Evaluación de daños en siniestros de propiedad/autos | claims · digital |
| 11.5 Explainable AI | Justificación regulatoria de modelos de pricing CNSF | underwriting-engine · analytics |

---

## Cinco Tendencias Tecnológicas P&C (ETB v3.0)

| Tendencia | Impacto en AXA | Sistemas afectados |
|-----------|---------------|-------------------|
| **Data & AI** | AI en siniestros (70% impacto alto), fraud detection, pricing ML | claims · underwriting-engine · analytics |
| **Cloud Readiness** | Migración Azure (AXA Group standard); TtM -40-50%; costos -10-20% | Todos |
| **Anywhere, Everywhere (IoT/5G)** | Telemática UBI en autos comerciales; IoT en property (smart buildings) | digital · underwriting-engine |
| **Mirrored World (Digital Twins)** | Digital twins de property para modelado catastrófico | actuarial · underwriting-engine |
| **Trust & Security (Blockchain/ZT)** | Smart contracts para seguros paramétricos; ZT para DORA (AXA Group europeo) | integration · compliance |

---

## Mapeo ETB → Sistemas AXA (resumen ejecutivo)

```
D1-D5 (Canales y Distribución)     →  systems/channels/
  ├── portal-agentes                ←  D2, D4 (Distribution + Sales a través de intermediarios)
  ├── crm                           ←  D3, D4, D5 (Marketing, Sales, Service)
  └── digital                       ←  D1, D5 (Channel, Service digital)

D6 (Product & Operations — núcleo) →  systems/core/ + systems/processors/
  ├── policy-admin                  ←  D6.2 Product Mgmt + D6.4 Policy Admin
  ├── claims                        ←  D6.5 Claims
  ├── billing                       ←  D6.1 Cross Capability (Billing, Payments)
  ├── underwriting-engine           ←  D6.3 Underwriting & Pricing
  ├── reinsurance                   ←  D6.1 Cross Capability (Reinsurance) + D6.3 Facultative
  └── actuarial                     ←  D6.1 Cross Capability (Actuarial) + D6.2 Impact Analysis

D7 (Enterprise Functions)           →  systems/compliance/ + systems/data/
  ├── cnsf                          ←  D7 Regulatory / Filing Management / CNSF
  ├── solvency                      ←  D7 Capital Management / Solvencia C / RCSF
  └── reporting-cnsf                ←  D7 Regulatory Reporting

D8 (Business Integration)          →  systems/integration/
  ├── api-gateway                   ←  D8 API Management, BPM orchestration
  └── event-bus                     ←  D8 Event-driven integration

D9-D10 (Data + Analytics)          →  systems/data/
  ├── datawarehouse                 ←  D9 Information Foundation
  └── analytics                     ←  D10 Business Insights & Analytics

D11 (AI)                           →  Cross-cutting (todos los sistemas)
```

---

## Vendor Landscape P&C (ETB v3.0) — relevancia para AXA

| Categoría | Plataformas con experiencia Accenture | Presencia en AXA México |
|-----------|--------------------------------------|------------------------|
| **Core P&C (Policy/Claims/Billing)** | Guidewire (★★★) · Duck Creek (★★★) · EIS (★★) | Por confirmar |
| **UW & Rating** | Guidewire PC · Duck Creek Rating · Oracle Insbridge | Por confirmar |
| **CRM** | Salesforce FSC (★★★) | Por confirmar |
| **Integration** | MuleSoft (★★★) · Azure APIM | Por confirmar |
| **Data & Analytics** | Databricks (★★★) · Snowflake (★★★) · SAP DW | Por confirmar |
| **Actuarial** | SAS · ResQ · Moody's AXIS · Prophet | Por confirmar |
| **Anti-fraude** | FRISS · Shift Technology | Por confirmar |

★★★ = Accenture experience confirmada · Por confirmar = pendiente levantamiento con AXA

---

## ESG en P&C — Imperativo para AXA (Grupo Europeo)

Como filial de AXA Group (Francia), AXA México hereda el compromiso ESG del grupo:
- **DORA**: AXA Group bajo regulación DORA europea → ciber-resiliencia obligatoria para la filial MX
- **Green Cloud**: AXA Global migra a Azure → reducción potencial de emisiones CO₂ hasta 84%
- **Sustainable Underwriting**: ESG en criterios de suscripción (sectores controversiales)
- **Green Finance**: portafolios de inversión alineados a transición climática

---

*Fuente: P&C Insurance ETB v3.0 (Accenture, junio 2022) — material interno. No enviar directamente a clientes.*
*Adaptado para Digital Brain AXA México · 2026-09-03 · v1.0*
# IT Operating Model (ITOM) — AXA México P&C Commercial Lines

## Marco de Referencia

El ITOM de AXA México organiza la tecnología en ocho capas horizontales y cuatro concerns
verticales (cross-cutting). Las capas se mapean directamente a la estructura `systems/` del
Digital Brain. Los concerns verticales aplican a todas las capas.

---

## Capas Horizontales

### L1 — Business Engagement
**Propósito**: Punto de contacto con clientes, agentes, corredores y aliados.

| Sistema | Función | Folder |
|---------|---------|--------|
| Portal Agentes / Corredores | Cotización, emisión, siniestros para intermediarios | `systems/channels/portal-agentes` |
| CRM (Salesforce FS Cloud) | Gestión de pipeline comercial y relación con clientes | `systems/channels/crm` |
| Canales Digitales (Web / App) | Autoatención, cotización digital, seguimiento de siniestros | `systems/channels/digital` |

**Run**: uptime 99.9%, experiencia de usuario, SLAs de canal.
**Change**: digitalización de procesos, omnicanalidad, personalización AI.

---

### L2 — Core Insurance Systems
**Propósito**: Sistemas de registro (systems of record) del negocio asegurador.

| Sistema | Función | Folder |
|---------|---------|--------|
| Policy Admin (Guidewire PC / Duck Creek) | Ciclo de vida completo de pólizas | `systems/core/policy-admin` |
| Claims (Guidewire ClaimCenter) | Gestión integral de siniestros FNOL → cierre | `systems/core/claims` |
| Billing (Guidewire BillingCenter) | Facturación, cobranza y comisiones | `systems/core/billing` |

**Run**: integridad de datos de pólizas, SLAs de emisión, exactitud de reservas.
**Change**: modernización de core, migración a cloud, configuración de nuevos productos.

---

### L3 — Underwriting Intelligence
**Propósito**: Motores de decisión para aceptación, precio y gestión de portafolio.

| Sistema | Función | Folder |
|---------|---------|--------|
| Underwriting Engine | Motor de tarifación, scoring de riesgo, reglas de aceptación | `systems/processors/underwriting-engine` |
| Reinsurance System | Tratados, cesiones proporcionales y no proporcionales | `systems/processors/reinsurance` |
| Actuarial Platform | Reservas técnicas, pricing actuarial, modelos de pérdida | `systems/processors/actuarial` |

**Run**: calibración de modelos, monitoreo de siniestralidad, alertas de portafolio.
**Change**: machine learning para pricing, modelos predictivos de siniestros.

---

### L4 — Integration Fabric
**Propósito**: Conecta todos los sistemas mediante APIs y eventos.

| Sistema | Función | Folder |
|---------|---------|--------|
| API Gateway (Azure APIM / MuleSoft) | Exposición y gobierno de APIs internas y externas | `systems/integration/api-gateway` |
| Event Bus (Kafka / Azure Service Bus) | Mensajería asíncrona y event-driven entre sistemas | `systems/integration/event-bus` |

**Run**: disponibilidad de APIs, latencia, throttling, versionado.
**Change**: API-first strategy, event sourcing, desacoplamiento de core.

---

### L5 — Data & Analytics
**Propósito**: Activo de datos para decisión, reportes y cumplimiento regulatorio.

| Sistema | Función | Folder |
|---------|---------|--------|
| Datawarehouse (Azure Synapse / Databricks) | Consolidación y histórico de datos de negocio | `systems/data/datawarehouse` |
| Analytics / BI (Power BI) | Reportes de gestión, KPIs, dashboards | `systems/data/analytics` |
| Reporting CNSF | Reportes regulatorios periódicos, Solvencia C, IFRS 17 | `systems/data/reporting-cnsf` |

**Run**: calidad de datos, linaje, SLAs de reportes regulatorios.
**Change**: data mesh, real-time analytics, datos para modelos AI/ML.

---

### L6 — Infrastructure & Cloud
**Propósito**: Plataforma de cómputo, almacenamiento y red.

| Componente | Servicio | Nota |
|------------|---------|------|
| Cloud Provider | Microsoft Azure (primario AXA Global) | AXA Group standard |
| Contenedores | Azure Kubernetes Service (AKS) | Microservicios |
| Landing Zone | Azure Landing Zone | Governance, networking |
| Storage | Azure Blob, Azure SQL, Azure Cosmos | Por carga de trabajo |

**Run**: disponibilidad, disaster recovery, gestión de costos cloud.
**Change**: cloud-native migration, FinOps, Green IT.

---

### L7 — Security & IAM
**Propósito**: Identidad, acceso, cifrado y cumplimiento de ciberseguridad.

| Componente | Servicio / Estándar | Nota |
|------------|---------------------|------|
| Identity | Azure Active Directory / Entra ID | SSO corporativo AXA |
| PAM | Privileged Access Management | Acceso a sistemas críticos |
| SIEM | Azure Sentinel / Defender | Monitoreo de amenazas |
| Cifrado | Azure Key Vault | Gestión de secretos y llaves |
| Estándares | ISO 27001, NIST CSF, CNSF ciberseguridad | Marco regulatorio |

**Run**: gestión de incidentes de seguridad, acceso mínimo privilegiado.
**Change**: Zero Trust, DevSecOps, protección de datos (LFPDPPP).

---

### L8 — Service Management
**Propósito**: Operación continua, soporte y gestión de incidentes.

| Componente | Plataforma | Nota |
|------------|-----------|------|
| ITSM | ServiceNow | Incidentes, cambios, problemas |
| Monitoreo | Dynatrace / Azure Monitor | APM, infraestructura, trazabilidad |
| Alertas | PagerDuty / Azure Alerts | On-call y escalamiento |
| SLO Dashboard | Grafana / Power BI | Disponibilidad por sistema |

**Run**: SLAs de soporte N1-N3, gestión de cambios, control de releases.
**Change**: AIOps, automatización de operaciones, observabilidad avanzada.

---

## Concerns Transversales (Verticales)

| Concern | Marco / Estándar | Sistemas afectados |
|---------|-----------------|-------------------|
| **Regulatory Compliance** | CNSF CUSF, Solvencia C, IFRS 17, CONDUSEF | L1-L5 |
| **Data Governance** | Data contracts, linaje, calidad, LFPDPPP | L4-L5 |
| **Architecture Governance** | TOGAF ADM, ADRs, ETB Insurance P&C | L1-L8 |
| **DevSecOps** | GitOps, shift-left security, quality gates | L2-L4 |

---

## Mapeo ITOM → Estructura Digital Brain

```
L1 Business Engagement    → systems/channels/
L2 Core Insurance         → systems/core/
L3 Underwriting Intel.    → systems/processors/
L4 Integration Fabric     → systems/integration/
L5 Data & Analytics       → systems/data/
L6 Infrastructure         → (no folder, gestionado en L4 Azure)
L7 Security & IAM         → (transversal, referenciado en cada sistema)
L8 Service Management     → systems/compliance/ (SLOs y ITSM)
Concerns transversales    → systems/compliance/ + axa-brain/knowledge-base/
```

---

*Última actualización: 2026-09-03 · v1.0 · AXA P&C Commercial Lines*
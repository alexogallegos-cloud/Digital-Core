# IT Operating Model (ITOM) — AXA México

## Marco de Referencia

El ITOM de AXA México organiza la tecnología en ocho capas horizontales y cuatro concerns
verticales (cross-cutting). Las capas se mapean a las categorías del registro canónico de
sistemas en `knowledge-base/landscape/landscape-axa-v2.json`.

**Regla de este documento**: cada sistema nombrado aquí existe en el registro canónico y tiene
procedencia verificable. Cuando una capa del marco no tiene sistema identificado en las fuentes,
se dice explícitamente en lugar de suponer un producto de mercado.

Fuentes: `source/arquitectura_TOGAF_accenture_v19.pdf` (Fases A a H) y
`source/2608_Suscripción_Entregable_Anexo Competitive Discovery Suscripción Daños.xlsx`.

---

## Capas Horizontales

### L1 — Business Engagement
**Propósito**: Punto de contacto con clientes, agentes, corredores y aliados.

| Sistema real | Función | Slug |
|--------------|---------|------|
| axa.mx | Portal público, cotizador, siniestros y buscador de red de prestadores | `axa-mx` |
| My AXA (web y app) | Self-service de tomadores, pago online, reembolsos y rastreo de ajustador | `my-axa-web`, `my-axa-app` |
| AXA Keralty | Portal y app de salud, citas médicas e historial clínico | `axa-keralty` |
| AXA Drive | Telemática de Autos y reporte de siniestros con datos de conducción | `axa-drive` |
| distribuidores.axa.com.mx | Portal de agentes y promotorías, cotizadores, trámites y SSO B2B | `portal-distribuidores` |
| axapartners.mx | Portal B2B de asistencia y reaseguro | `axa-partners` |
| axa.mx/proveedores | Hospitales, talleres y médicos, cartas de autorización y facturación | `portal-proveedores` |
| ATC Plus | Canal interno de atención al cliente | `atc-plus` |
| Sistema de Ventas AXA y Socio AXA | Apps internas de fuerza de ventas y red de distribuidores | `sistema-ventas`, `socio-axa` |
| SINCO | Base de cuentas y antecedentes de Daños | `crm` |

**Nota de corrección**: no hay evidencia de Salesforce como CRM de suscripción. El sistema de
cuentas usado en el proceso de Daños es SINCO, y su limitación conocida es que solo permite
búsqueda por razón social y dirección, sin identificador confiable de cliente.

**Run**: uptime, experiencia de usuario y SLAs de canal.
**Change**: cobertura de Vida en My AXA, omnicanalidad y personalización.

---

### L2 — Core Insurance Systems
**Propósito**: Sistemas de registro del negocio asegurador. AXA México opera un core distinto
por línea, no una suite única.

| Línea | Pólizas, productos y tarifas | Siniestros | Slugs |
|-------|------------------------------|------------|-------|
| Vida | Progress y COBOL, core monolítico AS IS | No identificado en fuentes | `policy-admin-vida` |
| Salud | Visual Time, GMM 2000, GMCol, GMI e ISES | SaludWeb, SIGAME, DictaMedic, Qantev y RedPres | `policy-admin-salud`, `claims-salud` |
| Daños | General Daños y SED sobre Oracle DB Daños | SED y General Daños, sin core dedicado | `policy-admin-danos`, `claims-danos` |
| Autos | Oracle DB Autos | Guidewire Claims, core SaaS | `policy-admin-autos`, `claims-autos` |

**Patrón dual de Autos**: Guidewire cubre siniestros, no pólizas. La gestión de pólizas,
productos y tarifas de Autos vive en Oracle DB, igual que en Daños (TOGAF p5, p7 y p11).

**Nota de corrección**: no hay evidencia de Guidewire PolicyCenter, BillingCenter ni Duck Creek.
Guidewire está presente solo como ClaimCenter para Autos. La facturación y cobranza corporativa
aparece nombrada como Billing & Collections (`billing-collections`) sin detalle de alcance.

**Run**: integridad de datos de pólizas, SLAs de emisión y exactitud de reservas.
**Change**: modernización del core de Vida y consolidación de la fragmentación por línea.

---

### L3 — Underwriting Intelligence
**Propósito**: Motores de decisión para aceptación, precio y gestión de portafolio.

| Sistema real | Función | Slug |
|--------------|---------|------|
| Vector | Workflow core de suscripción de Daños, gestión de folios y casos | `underwriting-engine` |
| ERN | Modelación catastrófica, PML, cúmulos y exposición sísmica e hidrometeorológica | `actuarial-cat` |
| Catnet | Mapeo de peligros naturales por ubicación | `actuarial-catnet` |
| PUMA | Cuota técnica de riesgo para proyectos y negocios complejos | `pricing-puma` |
| SAFAC | Reaseguro facultativo, colocaciones, capas y reaseguradores | `reinsurance` |
| ID Clear | Registro de la cesión facultativa para control del Grupo AXA | `reinsurance-group` |
| CIRCAM | Sistema contable downstream del reaseguro | `reinsurance-accounting` |

**Shadow IT que opera como sistema** — el hallazgo más relevante de esta capa:

| Herramienta | Función que absorbe | Slug |
|-------------|---------------------|------|
| HSD (Excel) | Cálculo técnico de suscripción, sin integración con Vector, ERN ni SAFAC | `hsd-excel` |
| P&L (Excel) | Análisis técnico y financiero del riesgo en negocio comercial o complejo | `pyl-rentabilidad` |
| Tarifa RC (Excel) | Tarificación de Responsabilidad Civil | `tarifa-rc` |
| Security List (Excel) | Reaseguradores admitidos y su calificación | `security-list` |

**Nota de corrección**: no existe un motor de tarificación ni un scoring automatizado de riesgo
en Daños. La decisión técnica se calcula en Excel y se recaptura manualmente en los sistemas de
registro. Esa es la brecha, no una capacidad existente.

**Run**: calibración de modelos y monitoreo de siniestralidad.
**Change**: sustituir el cálculo en Excel por un motor integrado a Vector.

---

### L4 — Integration Fabric
**Propósito**: Conecta los sistemas mediante APIs y eventos.

| Sistema real | Función | Slug |
|--------------|---------|------|
| Datapower MPG | Bus principal AS IS y gateway de seguridad, OAuth 2.0, TLS 1.2 y X509 | `api-gateway` |
| Mulesoft Anypoint | Bus canónico TO BE, en implementación. Mediación, orquestación y adaptadores | `esb` |
| Azure Service Bus | Mensajería asíncrona dentro del backbone Azure | componente de `cloud-backbone` |
| Azure APIM | Fachada de APIs dentro del backbone Azure | componente de `cloud-backbone` |
| F5 | Balanceo de carga y SSL offload | `perimeter` |
| WAF, IPS e IDS | Firewall de aplicación, detección de intrusión y listas de IP | `waf` |
| OpenShift | Plataforma de contenedores en nube privada | `containers` |
| FIS Payments | Pagos de indemnizaciones, patrón híbrido directo o vía Mulesoft | `payments` |
| Mitec y BBVA | Pasarela de pagos online de axa.mx y My AXA | `payments-online` |
| Citrix | Acceso virtualizado a SED y General Daños | `citrix` |

**Nota de corrección**: no hay evidencia de Kafka. La mensajería asíncrona documentada es Azure
Service Bus. Datapower y Mulesoft coexisten hoy como gateways sin criterio formal de cuándo usar
cada uno, lo que el propio TOGAF marca como gap de gobierno (p12 y p13).

**Run**: disponibilidad de APIs, latencia y versionado.
**Change**: completar Mulesoft como bus canónico y definir el criterio de ruteo frente a Datapower.

---

### L5 — Data & Analytics
**Propósito**: Activo de datos para decisión, reportes y cumplimiento regulatorio.

| Sistema real | Función | Estado | Slug |
|--------------|---------|--------|------|
| Oracle DB corporativo | Golden record: clientes, pólizas master, finanzas y contratos | Activo | `oracle-golden-record` |
| Oracle DB por línea | Datos de Daños, Salud y Autos | Activo | `oracle-danos`, `oracle-salud`, `oracle-autos` |
| Oracle EDWH | Enterprise Data Warehouse AS IS | En decommission sin fecha | `oracle-edwh` |
| MySQL Data Hub con Pentaho e Informatica | Staging, mart y DWH legado | En decommission sin fecha | `data-platform-legacy` |
| MongoDB | Capa semántica del Data Hub legado | En decommission | `mongodb` |
| Azure ADF, ADL y Databricks | Plataforma de datos TO BE | En migración | `data-platform-target` |
| Power BI | Reporting, dashboards y siniestralidad histórica | Activo | `analytics` |
| Monitor | Herramienta de consulta y reporte | Rol por confirmar | `reporting-cnsf` |

**Nota de corrección**: no hay evidencia de Azure Synapse. La plataforma destino documentada es
Data Factory, Data Lake y Databricks. Tampoco está confirmado que Monitor sea la herramienta de
reporte a CNSF, que es el supuesto heredado de la v1.0 del brain.

**Gap crítico**: no existe golden record de cliente unificado entre el Oracle corporativo,
Progress y COBOL (Vida) y los Oracle por línea. Impide cruzar identidades entre líneas y es
prerequisito declarado de la capa agéntica y del perfil único en My AXA (TOGAF p7, p12 y p14).

**Run**: calidad de datos, linaje y SLAs de reportes regulatorios.
**Change**: MDM o API canónica en Mulesoft, y plan de decommission del Data Hub legado.

---

### L6 — Infrastructure & Cloud
**Propósito**: Plataforma de cómputo, almacenamiento y red.

| Componente | Servicio real | Slug |
|------------|---------------|------|
| Cloud provider | Microsoft Azure, backbone de infraestructura, datos e IA | `cloud-backbone` |
| Contenedores | OpenShift, nube privada | `containers` |
| Servidores de aplicación | Node.js y JBoss | `app-servers` |
| Artefactos y CI/CD | JFrog | `jfrog` |
| Secretos | Azure Key Vault | componente de `cloud-backbone` |
| Observabilidad | Azure Monitor | componente de `cloud-backbone` |

**Nota de corrección**: no hay evidencia de Azure Kubernetes Service, Azure Landing Zone ni
Azure Cosmos. La plataforma de contenedores documentada es OpenShift sobre nube privada.

**Run**: disponibilidad, recuperación ante desastre y gestión de costos.
**Change**: migración cloud-native y FinOps.

---

### L7 — Security & IAM
**Propósito**: Identidad, acceso, cifrado y cumplimiento de ciberseguridad.

| Componente | Servicio real | Estado | Slug |
|------------|---------------|--------|------|
| IAM B2C | One Account, federado a Azure AD | Activo | componente de `iam` |
| IAM B2B y empleados | Ping Identity, federado a Azure AD | Activo | componente de `iam` |
| IGA global | LISA y Global AD | En migración desde LDAP | componente de `iam` |
| Directorio legado | Local AD LDAP con NTLM y Kerberos, sin IGA | En decommission | `iam-legacy` |
| IGA destino | SailPoint | Estado TO BE | `iga-sailpoint` |
| PAM | One PAM sobre CyberArk, GPUAD y Crown Jewels | Estado TO BE | `pam-cyberark` |
| SIEM | Azure Sentinel | Activo | componente de `cloud-backbone` |
| Screening de listas | World-Check, personas políticamente expuestas | Activo en suscripción | `world-check` |

**Estándares documentados**: OAuth 2.0 con OAuth Client Profile y scope por recurso, TLS 1.2 con
certificado X509 y RSA 2048 más SHA-2 en tránsito, AES 256 recomendado en reposo, MFA con OpenID
Connect en la pasarela de pagos.

**Run**: gestión de incidentes y acceso de mínimo privilegio.
**Change**: completar la migración LDAP a Global AD y sincronizar roles entre One Account, Ping
y Azure AD.

---

### L8 — Service Management
**Propósito**: Operación continua, soporte y gestión de incidentes.

| Componente | Plataforma real | Slug |
|------------|-----------------|------|
| ITSM y CMDB | ServiceNow | `itsm` |
| Gestión de solicitudes | Jira Service Management, usado también en el Portal de Proveedores | `jira-service-mgmt` |
| Monitoreo de plataforma | Azure Monitor | componente de `cloud-backbone` |
| SIEM | Azure Sentinel | componente de `cloud-backbone` |

| Monitoreo de endpoint | Nexthink, instalado en 2026 en 900 de 4 mil equipos | `nexthink`, pendiente de alta |

**Nota de corrección y matiz**: en el TOGAF no hay evidencia de Dynatrace, PagerDuty ni Grafana
desplegados, y el stack de observabilidad documentado es Azure Monitor y Sentinel. El portafolio
2027 matiza el caso de Dynatrace: el rol de Monitoring lead pide experiencia en Dynatrace, pero su
encargo es precisamente **definir** la estrategia y el marco de monitoreo de aplicaciones para
Seguros. Es decir, Dynatrace aparece como herramienta candidata del estado objetivo, no como
herramienta en operación. No tratarla como parte del AS IS hasta confirmarlo.

Nexthink sí está desplegado, pero infrautilizado: se instaló para un problema puntual de red y hoy
no se usa la funcionalidad completa.

La pasarela externa Mitec y BBVA queda fuera del monitoreo unificado, que el TOGAF marca como
gap (p12).

**Run**: SLAs de soporte, gestión de cambios y control de releases.
**Change**: incorporar la pasarela externa a Sentinel y avanzar hacia AIOps.

---

## Capa transversal — Agéntica

No es una capa del marco ITOM clásico, pero atraviesa L1, L4 y L5 y es la iniciativa con más
dependencias declaradas en el brain.

| Elemento | Función | Estado |
|----------|---------|--------|
| Agente orquestador | Coordina el flujo entre agentes, gestiona estado y decide siguiente paso | Piloto |
| Agente 1 | Validación de acceso y estado | Piloto |
| Agente 2 | Verificación de condiciones | Piloto |
| Agente 3 | Cálculo financiero | Piloto |
| Agente 4 | Validación clínica y técnica | Piloto |
| Agente generativo | LLM para nota de resolución y comunicación multicanal | Piloto |

**Triggers de entrada**: My AXA y axa.mx (B2C), ATC Plus y AXA Keralty, sistemas B2B externos.
**Integración**: adaptadores de Mulesoft hacia core de pólizas, core de siniestros, sistemas
financieros y red de prestadores.
**Salidas**: nota de resolución, comunicación multicanal por Infobip, escalado humano con
human-in-the-loop y respuesta automática registrada en sistema.
**Modelos**: Azure AI Foundry y OpenAI para el agente generativo, más SecureGPT como pasarela
corporativa de modelos (Claude Haiku 4.5, Gemini 2.5 Flash, GPT-4.1 Nano, GPT-5 Nano y Mistral
Small 3.1).

**Bloqueante declarado**: depende del golden record de cliente unificado, que no existe.

---

## Concerns Transversales (Verticales)

| Concern | Marco y estándar | Capas afectadas |
|---------|------------------|-----------------|
| **Regulatory Compliance** | CNSF, Circular Única de Seguros y Fianzas, Solvencia C, IFRS 17 y CONDUSEF | L1 a L5 |
| **Data Governance** | Data owners por entidad, roadmap MDM, perfil único de cliente y LFPDPPP | L4 y L5 |
| **Architecture Governance** | Architecture Board, TOGAF ADM, ADRs y ETB Insurance P&C | L1 a L8 |
| **DevSecOps** | GitOps, shift-left security y quality gates | L2 a L4 |

**Discrepancia regulatoria pendiente de resolver**: la sección de compliance del TOGAF (p13) cita
Solvencia II, RGPD y DGSFP, que son el marco europeo y el regulador español. Para AXA México el
marco aplicable es CNSF, Solvencia C, CONDUSEF y LFPDPPP. Es probable que esa lámina venga de una
plantilla de otra entidad del Grupo AXA y deba corregirse con el cliente.

---

## Mapeo ITOM hacia el registro canónico

```
L1 Business Engagement    → category = channels
L2 Core Insurance         → category = core
L3 Underwriting Intel.    → category = processors
L4 Integration Fabric     → category = integration
L5 Data & Analytics       → category = data
L6 Infrastructure         → category = integration y compliance (Azure, OpenShift, JFrog)
L7 Security & IAM         → category = compliance (iam, iga-sailpoint, pam-cyberark)
L8 Service Management     → category = integration (itsm, jira-service-mgmt)
Capa agéntica             → category = processors (capa-agentica)
```

**Deuda de taxonomía conocida**: la categoría `compliance` hoy agrupa cumplimiento regulatorio
junto con finanzas, identidad, Azure y sistemas corporativos. Es una herencia de la v1.0 del
brain y conviene separarla en `platform` y `corporate` cuando se revise la estructura de
carpetas de `systems/`.

---

*Última actualización: 2026-10-19 · v2.0 · Reescrito contra el registro canónico
`landscape-axa-v2.json`. Sustituye la v1.0, que atribuía a AXA productos de mercado sin evidencia
en las fuentes (Guidewire PolicyCenter y BillingCenter, Duck Creek, Salesforce FS Cloud, Kafka,
Azure Synapse, AKS, Dynatrace, PagerDuty y Grafana).*

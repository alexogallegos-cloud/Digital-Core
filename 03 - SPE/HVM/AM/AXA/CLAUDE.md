# AXA México — Digital Brain
> Insurance P&C Commercial Lines · Run & Change

---

## QUÉ ES ESTE PROYECTO

Digital Brain para AXA México — ecosistema de conocimiento vivo del estado de los sistemas de
tecnología que soportan el negocio de Seguros de Daños (Property & Casualty) en Líneas Comerciales.

**Cliente**: AXA México (AXA Seguros S.A. de C.V.)
**Regulador**: Comisión Nacional de Seguros y Fianzas (CNSF)
**Marco regulatorio**: Circular Única de Seguros y Fianzas · Solvencia C · IFRS 17 · CONDUSEF
**Geografía**: México
**ETB de referencia**: Insurance Property & Casualty — Commercial Lines

---

## ESTRUCTURA DEL DIGITAL BRAIN

| Componente | Ubicación | Rol |
|------------|-----------|-----|
| Cerebro Federado | `axa-brain/` | Agrega todos los system-level brains |
| Sistemas — Run | `systems/{categoría}/{sistema}/` | Brain por sistema, estado actual (TOGAF baseline) |
| Proyectos — Change | `projects/{workstream}/` | Brain por workstream de transformación |
| Design Studio | `design-studio/` | Paleta AXA, logos, templates HTML |

---

## LANDSCAPE DE SISTEMAS — TOGAF

> **v2.0 — Landscape completo multi-línea** confirmado desde `source/arquitectura_TOGAF_accenture_v19.pdf` (Fases A–H) + `source/2608_Suscripción_Entregable_Anexo Competitive Discovery Suscripción Daños.xlsx`

### core/ — Sistemas Core de Negocio (por línea)

| Sistema (slug) | Nombre real | Línea | Descripción | Estado |
|----------------|-------------|-------|-------------|--------|
| policy-admin-danos | **General Daños / SED** | Daños | Sistema de emisión de pólizas de daños — captura condiciones aprobadas, genera la póliza y gestiona endosos | CONFIRMED |
| policy-admin-autos | **Visual Time** | Autos | SaaS de gestión de pólizas, productos y tarifas de Autos | CONFIRMED |
| policy-admin-salud | **Visual Time** | Salud | SaaS de gestión de pólizas de Salud (mismo producto, instancia Salud) | CONFIRMED |
| policy-admin-vida | **Progress/COBOL** | Vida | Core de Vida AS IS — monolítico legacy (pólizas, productos, tarifas, tomadores, historial) | CONFIRMED |
| claims-autos | **Guidewire Claims** | Autos | Core SaaS de siniestros de Autos — integración directa Audatex + FIS Payments | CONFIRMED |
| claims-danos | Por confirmar | Daños | Gestión de siniestros Daños/Property — no identificado en Discovery | SCAFFOLD |
| claims-salud | **SaludWeb · SIGAME · DictaMedic · Qantev · RedPres** | Salud | Autorización, reembolso, prestaciones, telemedicina | CONFIRMED |

### processors/ — Motores de Procesamiento

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| underwriting-engine | **Vector** | Workflow core de suscripción Daños — gestión de folios/casos desde recepción hasta decisión técnica | CONFIRMED |
| reinsurance | **SAFAC** | Reaseguro Facultativo — registro de colocaciones, capas, reaseguradores; solo estructura lineal (gap) | CONFIRMED |
| actuarial-cat | **ERN** | Modelación catastrófica — PML, cúmulos, exposición sísmica/hidro | CONFIRMED |
| fraud-detection | **Shift Technology** | Detección de fraude ML en paralelo para siniestros de Autos | CONFIRMED |
| peritacion | **Audatex** | Peritación y valoración de daños de Autos — integración directa con Guidewire | CONFIRMED |
| hsd-excel | **HSD (Excel)** | Hoja de Suscripción de Daños — herramienta Excel de cálculo técnico, NO sistema; gap crítico de automatización | GAP-CRITICAL |

### channels/ — Canales de Distribución y Engagement

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| my-axa-web | **My AXA (web)** | Self-service tomadores — consulta/descarga pólizas, pago online, pólizas colectivas | CONFIRMED |
| my-axa-app | **My AXA (iOS + Android)** | App móvil — Salud/Vida/AP, reembolsos, rastreo ajustador, tarjeta digital, Tu Médico 24h | CONFIRMED |
| axa-mx | **axa.mx** | Portal público — cotizador, siniestros, buscador red prestadores, acceso My AXA | CONFIRMED |
| axa-keralty | **AXA Keralty (web + app)** | Portal y app salud — citas médicas, historial, resultados laboratorio, clínicas AXA Keralty | CONFIRMED |
| axa-drive | **AXA Drive (iOS + Android)** | Telemática de Autos — reporte siniestros online con datos de conducción | CONFIRMED |
| portal-distribuidores | **distribuidores.axa.com.mx** | Portal agentes y promotorías — cotizadores, trámites, SSO B2B | CONFIRMED |
| axa-partners | **axapartners.mx** | Portal B2B — asistencia y reaseguro, API | CONFIRMED |
| atc-plus | **ATC Plus** | Canal atención al cliente interno | CONFIRMED |
| sistema-ventas | **Sistema Ventas AXA · Socio AXA** | Apps internas — fuerza de ventas | CONFIRMED |
| crm | **SINCO** | Base de cuentas y antecedentes — búsqueda por razón social + dirección; sin ID confiable (gap) | CONFIRMED |

### integration/ — Capa de Integración y Seguridad

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| api-gateway | **Datapower MPG** | API gateway de seguridad — OAuth 2.0, TLS 1.2, X509, timestamp; servciosweb.axa.com.mx | CONFIRMED |
| esb | **Mulesoft** | iPaaS Anypoint — bus canónico, mediación, orquestación, adaptadores a sistemas de negocio | CONFIRMED-IN-IMPL |
| perimeter | **F5** | Balanceo de carga, SSL offload | CONFIRMED |
| waf | **WAF · IPS/IDS** | Web Application Firewall, detección de intrusión, IP listing | CONFIRMED |
| containers | **OpenShift** | Plataforma de contenedores — nube privada | CONFIRMED |
| payments | **FIS Payments** | Pasarela de pagos SaaS (híbrido) — integración Guidewire para siniestros | CONFIRMED |
| procurement | **Coupa** | Procurement SaaS — talleres homologados, proveedores | CONFIRMED |
| itsm | **ServiceNow** | ITSM corporativo | CONFIRMED |

### data/ — Datos y Analítica

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| oracle-golden-record | **Oracle DB (corporativo)** | Golden record — clientes, pólizas master, finanzas, contratos. Prerequisito capa agéntica | CONFIRMED |
| oracle-danos | **Oracle DB (Daños)** | Core de datos Daños/Property | CONFIRMED |
| oracle-salud | **Oracle DB (Salud)** | Core de datos Salud | CONFIRMED |
| oracle-autos | **Oracle DB (Autos)** | Core de datos Autos | CONFIRMED |
| analytics | **Power BI** | Analytics, BI y reportes — siniestralidad histórica, primas, reporting gerencial | CONFIRMED |
| data-platform-legacy | **MySQL Data Hub + Pentaho** | Data Hub legado AS IS — en decommission hacia Azure | DEPRECATED |
| data-platform-target | **Azure ADF + ADL + Databricks** | Data Platform TO BE — ETL (ADF), repositorio (ADL), ML/procesamiento (Databricks) | IN-MIGRATION |
| reporting-cnsf | **Monitor** | Herramienta de consulta/reporte; rol exacto por confirmar | PARTIAL |

### compliance/ — Regulatorio y Finanzas

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| finance | **SAP ECC v8** | Finanzas y RRHH — FICO, consolidación al Grupo AXA | CONFIRMED |
| iam | **One Account + Ping + LISA** | IAM B2C → Azure AD · IAM B2B → Azure AD · IGA global (migración desde LDAP) | CONFIRMED-IN-MIGRATION |
| cloud-backbone | **Azure** | AD/Entra ID · APIM · Service Bus · Key Vault · Monitor · Sentinel · Azure AI (Foundry/OpenAI) | CONFIRMED |
| cnsf | Por confirmar | Cumplimiento CNSF, notas técnicas, reportes periódicos | SCAFFOLD |
| solvency | Por confirmar | Solvencia C, cálculo de reservas, capital mínimo garantizado | SCAFFOLD |
| jfrog | **JFrog** | Artefactos y CI/CD | CONFIRMED |

### Capa Agéntica

| Componente | Descripción | Estado |
|------------|-------------|--------|
| **Orquestador agéntico** | Coordina flujo entre agentes — gestiona estado, decide siguiente paso | PILOTO |
| **Agente 1** — Validación de acceso | Verifica identidad y permisos del solicitante | PILOTO |
| **Agente 2** — Verificación de condiciones | Valida condiciones aplicables por línea/producto | PILOTO |
| **Agente 3** — Cálculo financiero | Cálculo de primas, reservas, indemnización | PILOTO |
| **Agente 4** — Validación clínica/técnica | Validación especializada (salud/siniestros) | PILOTO |
| **Agente generativo (LLM)** | Azure AI Foundry/OpenAI — nota de resolución, comunicación multicanal | PILOTO |
| Triggers | My AXA / axa.mx (B2C) · ATC Plus · AXA Keralty (Salud) · Sistemas B2B externos | — |

---

## SISTEMAS REALES — RESUMEN DE DESCUBRIMIENTO

| Sistema real | Slug brain | Fuente | Categoría gap |
|-------------|-----------|--------|---------------|
| **Vector** | `underwriting-engine` | Competitive Discovery Suscripción Daños | Workflow fragmentado; sin integración automática con otros sistemas |
| **SINCO** | `crm` | Competitive Discovery Suscripción Daños | Solo búsqueda por razón social + dirección; sin identificador confiable |
| **HSD** (Excel) | — (no es sistema) | Competitive Discovery Suscripción Daños | **Gap crítico**: cálculo técnico en Excel manual; sin integración con Vector, ERN ni SAFAC |
| **ERN** | `actuarial-cat` | Competitive Discovery Suscripción Daños | Herramienta de modelación catastrófica; resultados se trasladan manualmente a HSD |
| **SAFAC** | `reinsurance` | Competitive Discovery Suscripción Daños | Solo estructura lineal; sin carga masiva de capas/reaseguradores |
| **General Daños / SED** | `policy-admin-danos` | Competitive Discovery Suscripción Daños | Recaptura manual de condiciones desde el slip; fallas técnicas en catálogos |
| **Power BI** | `analytics` | Competitive Discovery Suscripción Daños | Consulta de siniestralidad disponible pero acceso fragmentado |
| **Monitor** | `reporting-cnsf` (tentativo) | Competitive Discovery Suscripción Daños | Rol exacto por confirmar |
| **Progress/COBOL** | `policy-admin-vida` | TOGAF PDF Fase B | Core Vida AS IS monolítico legacy |
| **Visual Time** | `policy-admin-autos` + `policy-admin-salud` | TOGAF PDF Fase B | SaaS pólizas Autos + Salud |
| **Guidewire** | `claims-autos` | TOGAF PDF Fases B/C | Core SaaS siniestros Autos |
| **Audatex** | `peritacion` | TOGAF PDF Fase C (flujo Autos) | Peritación y valoración daños Autos |
| **Shift Technology** | `fraud-detection` | TOGAF PDF Fase C | Detección fraude ML Autos |
| **FIS Payments** | `payments` | TOGAF PDF Fases C/D | Pasarela de pagos SaaS híbrido |
| **Mulesoft** | `esb` | TOGAF PDF Fase C | iPaaS en implementación — bus canónico de integración |
| **Datapower MPG** | `api-gateway` | TOGAF PDF Fases C/D | API gateway de seguridad perimetral |
| **Oracle DB** (4 instancias) | `oracle-*` | TOGAF PDF Fase C/D | Golden record + instancias por línea; sin MDM entre ellas (gap crítico) |
| **SAP ECC v8** | `finance` | TOGAF PDF Fase D | Finanzas, FICO, RRHH |
| **Azure** (stack completo) | `cloud-backbone` | TOGAF PDF Fase D | Backbone de infraestructura, datos e IA |
| **One Account + Ping + LISA** | `iam` | TOGAF PDF Fase B/C | IAM en migración LDAP → Global AD + Azure AD |
| **My AXA (web + iOS + Android)** | `my-axa-app` | TOGAF PDF Fase B | Self-service B2C multi-línea |
| **Capa agéntica** | — | TOGAF PDF Fase C | Orquestador + 4 agentes + LLM generativo — piloto activo |

---

## RUN vs CHANGE

- **Run** (`systems/`): sistemas en operación. Cada sistema tiene su propio `digital-brain/` con extracción de código fuente, reglas de negocio, vocabulario y Digital Twins temáticos. Son el estado AS-IS verificado.
- **Change** (`projects/`): workstreams de transformación activos. Cada proyecto tiene su propio brain y DTs de proyecto. Son iniciativas que modifican el estado de `systems/`.

---

## CADENA DE HERENCIA

```
Digital Core/CLAUDE.md
└── Digital Core/AGENTES-UNIVERSAL-RULES-DC.md
    └── 03 - SPE/HVM/AM/AXA/CLAUDE.md            ← este archivo
        └── axa-brain/CLAUDE.md                   ← cerebro federado
            └── systems/{cat}/{sys}/CLAUDE.md      ← brains por sistema
                └── projects/{ws}/CLAUDE.md        ← brains por proyecto
```

---

## DESIGN STUDIO

Paleta AXA, logos y templates HTML en `design-studio/`. Todos los portales HTML del proyecto
deben referenciar `design-studio/templates/axa-theme.css` para estilos consistentes.

Colores AXA: `#00008F` (azul primario) · `#FF1721` (rojo acento) · `#FFFFFF` · `#F5F5F5`

---

*Última actualización: 2026-09-06 · v2.0 · Landscape completo multi-línea desde TOGAF PDF (Fases A–H): Progress/COBOL (Vida) · Visual Time (Autos+Salud) · Guidewire (siniestros Autos) · Audatex · Shift Technology · FIS Payments · Mulesoft (en impl.) · Datapower MPG · Oracle DB (4 instancias) · SAP ECC v8 · Azure stack · IAM One Account+Ping+LISA · My AXA multi-línea · Capa agéntica (piloto). 22 sistemas nuevos confirmados.*
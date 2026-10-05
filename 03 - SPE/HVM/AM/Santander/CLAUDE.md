# Santander México — Digital Brain
> Banca múltiple · Run & Change · Top 5 bancos México por activos

---

## QUÉ ES ESTE PROYECTO

Digital Brain para Banco Santander México — ecosistema de conocimiento vivo del estado de los sistemas de
tecnología que soportan la operación bancaria retail, pyme y corporativa en México.

**Cliente**: Banco Santander México, S.A., Institución de Banca Múltiple, Grupo Financiero Santander México
**Grupo**: Banco Santander, S.A. (España · IBEX 35)
**Regulador primario**: Comisión Nacional Bancaria y de Valores (CNBV)
**Marco regulatorio**: CNBV · Banxico · CONDUSEF · UIF (PLD/GAFI) · PCI-DSS · ISO 27001 · DORA (grupo)
**Geografía**: México (HQ CDMX · presencia nacional)
**Escala**: ~17M clientes · Top 5 por activos (~$1.5T MXN) · ~18K sucursales + cajeros
**ETB de referencia**: Banking — Retail + Commercial + Digital Banking

---

## ESTRUCTURA DEL DIGITAL BRAIN

| Componente | Ubicación | Rol |
|------------|-----------|-----|
| Cerebro Federado | `santander-brain/` | Agrega todos los system-level brains |
| Sistemas — Run | `systems/{categoría}/{sistema}/` | Brain por sistema, estado actual (TOGAF baseline) |
| Proyectos — Change | `projects/{workstream}/` | Brain por workstream de transformación |
| Design Studio | `design-studio/` | Paleta Santander, logos, templates HTML |

---

## LANDSCAPE DE SISTEMAS — TOGAF

> **v1.0 — Landscape inicial SCAFFOLD** · Los sistemas con estado `CONFIRMED` tienen fuente pública verificada.
> Los sistemas con estado `SCAFFOLD` son hipótesis técnicas basadas en el patrón de banco global de escala similar.
> **Prioridad**: enriquecer con documentación real del cliente antes de cualquier entrega formal.

### core/ — Sistemas Core de Negocio (SoR)

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| core-banking | Por confirmar | Core bancario — cuentas, productos, clientes, saldos, transacciones | SCAFFOLD |
| card-platform | Por confirmar | Plataforma de tarjetas débito y crédito — emisión, parametrización, ciclo de vida | SCAFFOLD |
| loans | Por confirmar | Sistema de créditos retail, hipotecario y empresarial | SCAFFOLD |
| treasury | Por confirmar | Tesorería y mercados — FX, derivados, renta fija | SCAFFOLD |

### processors/ — Motores de Procesamiento

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| card-authorizer | Por confirmar | Autorizador de tarjetas 24x7 — aprobación en tiempo real de transacciones | SCAFFOLD |
| payments-engine | Por confirmar | Motor de pagos SPEI · DiMo · CoDi · TEF · domiciliación · SWIFT | SCAFFOLD |
| pld-engine | Por confirmar | Motor PLD/AML — scoring de riesgo, monitoreo de operaciones inusuales (UIF/GAFI) | SCAFFOLD |
| fraud-detection | Por confirmar | Detección de fraude ML — tarjetas y canales digitales | SCAFFOLD |

### channels/ — Canales de Distribución y Engagement

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| supermovil | **SuperMóvil** (iOS + Android) | App móvil principal — consulta, pagos, transferencias, DiMo, depósitos | CONFIRMED |
| santander-online | **Santander Online** (web) | Banca en línea web — retail y pyme | CONFIRMED |
| santander-empresas | **Santander Empresas / Cash** | Portal banca empresarial y tesorería corporativa | CONFIRMED |
| atm-network | Red de cajeros ATM | Red propia y PROSA/ATM Red — ~7K cajeros en México | CONFIRMED |
| call-center | IVR + agentes | Canal call center / centro de contacto | SCAFFOLD |
| pos-acquiring | POS adquirente | Terminal punto de venta — acquiring propio | SCAFFOLD |

### integration/ — Capa de Integración

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| api-gateway | Por confirmar | API Gateway — Azure APIM o equivalente; exposición de capacidades digitales | SCAFFOLD |
| esb | Por confirmar | ESB / iPaaS — bus de integración entre sistemas legacy y digitales | SCAFFOLD |
| swift-gateway | SWIFT Alliance | Conectividad SWIFT — mensajería ISO 20022 / MT | SCAFFOLD |
| prosa-link | PROSA | Enlace con PROSA — cámara de compensación de tarjetas MX | SCAFFOLD |
| banxico-spei | Banxico SPEI/DiMo | Conectividad Banxico — SPEI, DiMo, DIMO, CoDi | CONFIRMED |

### data/ — Datos y Analítica

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| datawarehouse | Por confirmar | Datawarehouse corporativo — golden record clientes, transacciones históricas | SCAFFOLD |
| analytics | Por confirmar | Analytics y BI — Power BI, Qlik o equivalente | SCAFFOLD |
| data-platform | Por confirmar | Data platform moderna — Azure Data Lake, Databricks o equivalente | SCAFFOLD |

### compliance/ — Regulatorio y Soporte Corporativo

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| cnbv-reporting | Por confirmar | Reportería CNBV — catálogos regulatorios, R01-R29, SIPRES | SCAFFOLD |
| iam | Por confirmar | IAM corporativo — Azure AD / Entra ID (global Santander) | SCAFFOLD |
| finance-erp | SAP (probable) | ERP finanzas y RRHH — FICO, consolidación al Grupo Santander España | SCAFFOLD |
| itsm | ServiceNow (probable) | ITSM corporativo — incidentes, cambios, problemas | SCAFFOLD |
| crm | Salesforce (probable) | CRM — gestión de clientes, oportunidades, campañas (global Santander usa Salesforce) | SCAFFOLD |

### Cloud Backbone

| Sistema (slug) | Nombre real | Descripción | Estado |
|----------------|-------------|-------------|--------|
| azure-backbone | **Microsoft Azure** | Azure backbone — AD/Entra ID · APIM · Service Bus · Key Vault · Monitor · Sentinel · AI Foundry | CONFIRMED |

---

## SISTEMAS CONFIRMADOS — RESUMEN

| Sistema real | Slug brain | Fuente | Notas |
|-------------|-----------|--------|-------|
| **SuperMóvil** (iOS + Android) | `supermovil` | Público / App Store | App oficial Santander México |
| **Santander Online** | `santander-online` | Público / supernet.com.mx | Portal banca en línea retail |
| **Santander Empresas / Cash** | `santander-empresas` | Público / sitio corporativo | Plataforma banca corporativa |
| **Red cajeros ATM** | `atm-network` | Público / CNBV estadísticas | ~7K cajeros, PROSA interoperable |
| **Microsoft Azure** | `azure-backbone` | Público / anuncio partnership 2021 | Microsoft strategic partner global |
| **Banxico SPEI/DiMo** | `banxico-spei` | Público / Banxico | Rails de pagos regulados |

---

## PROYECTOS ACTIVOS — CHANGE

| Proyecto | Tipo | Estado | Path |
|----------|------|--------|------|
| **CAN — Créditos Asociados a Nómina** | Cumplimiento regulatorio · Banxico | `[STATE: ACTIVE]` · Fase DISCOVER | `projects/can/` |

---

## RUN vs CHANGE

- **Run** (`systems/`): sistemas en operación. Cada sistema tiene su propio `digital-brain/` con extracción de código fuente, reglas de negocio, vocabulario y Digital Twins temáticos. Son el estado AS-IS verificado.
- **Change** (`projects/`): workstreams de transformación activos. Cada proyecto tiene su propio brain y DTs. Son iniciativas que modifican el estado de `systems/`.

---

## CADENA DE HERENCIA

```
Digital Core/CLAUDE.md
└── Digital Core/AGENTES-UNIVERSAL-RULES-DC.md
    └── 03 - SPE/HVM/AM/Santander/CLAUDE.md            ← este archivo
        └── santander-brain/CLAUDE.md                   ← cerebro federado
            └── systems/{cat}/{sys}/CLAUDE.md            ← brains por sistema
                └── projects/{ws}/CLAUDE.md              ← brains por proyecto
```

---

## DESIGN STUDIO

Paleta Santander, logos y templates HTML en `design-studio/`. Todos los portales HTML del proyecto
deben referenciar `design-studio/templates/santander-theme.css` para estilos consistentes.

Colores Santander: `#EC0000` (rojo primario · llama) · `#CC0000` (rojo oscuro hover) · `#FFFFFF` · `#F4F4F4` · `#1A1A1A`

---

## REGULACIÓN APLICABLE

| Regulador | Marco | Aplica a |
|-----------|-------|---------|
| CNBV | Circular Única de Bancos (CUB) · R01-R29 | Core banking · productos · capital · liquidez |
| Banxico | Reglas SPEI · DiMo · CoDi · CECOBAN | Pagos · compensación · liquidación |
| CONDUSEF | REDECO · REUNE · Registro de reclamaciones | Canales · atención al cliente |
| UIF | Reglas PLD/FT · reportes de operaciones inusuales | Cumplimiento AML/CTF |
| GAFI/FATF | 40 Recomendaciones | Marco PLD internacional (grupo) |
| PCI-DSS v4 | Seguridad de datos de tarjeta | Card platform · POS · canales digitales |
| ISO 27001 | Gestión de seguridad de la información | Infraestructura · datos |
| DORA | Digital Operational Resilience Act (UE) | Grupo Santander España → requerimientos aplican a subsidiarias globales |

---

*Última actualización: 2026-09-17 · v1.0 · Scaffold inicial — landscape hipotético basado en fuentes públicas. Pendiente enriquecimiento con documentación real del cliente.*

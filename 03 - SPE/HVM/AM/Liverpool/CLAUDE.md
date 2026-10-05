# Liverpool — Proyecto Application Modernization

> Instancia del solution L4 Application Modernization · Sub-offering HVM · Offering 03 S&PE · Zona: ★ Digital Core
> Specialists activos: Informix SPL (N/A), SAP ABAP (SAP stack), Oracle Forms PL-SQL (Oracle stack)

```
┌─[★ Digital Core]────────────────────────────────────────────┐
│ El Puerto de Liverpool · SPE-AM-003                         │
│ SAP + Oracle + Java + Mainframe · Retail MX · AS-IS + TO-BE │
└─────────────────────────────────────────────────────────────┘
```

---

## Contexto del Cliente

| Campo | Valor |
|---|---|
| Cliente | **El Puerto de Liverpool, S.A.B. de C.V.** — mayor cadena de tiendas departamentales de México |
| Ticker BMV | LIVEPOLC |
| Industria | Retail — tiendas departamentales + servicios financieros (LiverpoolCard) + moda (Suburbia) |
| Regulación aplicable | Banxico (LiverpoolCard — figura de financiamiento), CONDUSEF (crédito al consumo), BMV (empresa pública) |
| Geografía | México (principal) — ~130 tiendas Liverpool + ~200 Suburbia |
| CEO | Enrique Güijosa Hidalgo (desde 31-mar-2024) |
| Monedas | MXN / USD |
| Contacto / DM | `[DATO-REQUERIDO]` |
| Deal Stage | `[DATO-REQUERIDO]` S0 / S1 / S2 |

---

## Componente

| Campo | Valor |
|---|---|
| Component ID | `SPE-AM-003` |
| Nombre | Liverpool Application Modernization |
| Tipo | Application Modernization — AS-IS + TO-BE (ambos brains) |
| Estado | `[STATE: ACTIVE]` — DISCOVER Etapa 0 |
| Sub-offering | High Velocity Modernization |
| Solution | Application Modernization |
| Fecha de inicio | 2026-09-02 |

---

## Landscape de Sistemas — 20 Sistemas (Confirmado desde Dashboard AS-IS)

> Fuente autoritativa: `liverpool-brain/source/Arquitectura_Liverpool_Dashboard_1.html`
> Business Units vs. Aplicaciones Liverpool v2.1 · Consolidado 2026-06-16

### Core (SoR alta criticidad)

| Sistema | Tecnología | togaf_state | Rol confirmado |
|---------|-----------|-------------|----------------|
| [SAP](systems/core/SAP/CLAUDE.md) | SAP ECC (LIV on-prem) + SAP S/4HANA (SBB Azure) | baseline | ERP: inventario, finanzas, HR, WMS (EWM), BW, PMR, PDM |
| [Mainframe](systems/core/Mainframe/CLAUDE.md) | IBM z/OS · VPL Vision Plus · SOMS · Mainframe Clientes | baseline | Core LiverpoolCard (VPL) + órdenes entrega (SOMS) + contabilidad clientes |

### Processors (SoR especializados)

| Sistema | Vendor | togaf_state | Rol |
|---------|--------|-------------|-----|
| [VPL-Vision-Plus](systems/processors/VPL-Vision-Plus/CLAUDE.md) | FIS Global | baseline | LiverpoolCard core — autorizaciones, estados de cuenta 24x7 |
| [FICO-TRIAD](systems/processors/FICO-TRIAD/CLAUDE.md) | FICO | baseline | Originación crédito APM+OM + scoring |
| [Base24](systems/processors/Base24/CLAUDE.md) | ACI Worldwide | baseline | Switch transaccional — POS, ATG, ATM |
| [Cyberfinancial](systems/processors/Cyberfinancial/CLAUDE.md) | EQUIFAX / Harman Navigator | transitional | Cobranza SaaS (v8.4→v9C en migración) |
| [Card-Wizard](systems/processors/Card-Wizard/CLAUDE.md) | Card Wizard | baseline | Emisión de tarjetas LiverpoolCard |
| [Oracle-PL-SQL](systems/processors/Oracle-PL-SQL/CLAUDE.md) | Oracle + PL/SQL | baseline | Planning/merchandising: PL/SQL Size Scaling + PL/SQL Allocation |
| [Siebel-CRM](systems/processors/Siebel-CRM/CLAUDE.md) | Oracle Siebel | baseline | CRM Call Center, Lealtad (solo LIV) |
| [PIM-STEP](systems/processors/PIM-STEP/CLAUDE.md) | Stibo Systems STEP | baseline | Product Information Management LIV+SBB |

### Channels (SoD)

| Sistema | Vendor | togaf_state | Rol |
|---------|--------|-------------|-----|
| [ATG-Endeca](systems/channels/ATG-Endeca/CLAUDE.md) | Oracle Commerce + Endeca | baseline → **Repurchase** | eCommerce AS-IS (liverpool.com.mx + suburbia.com) → TO-BE commercetools |
| [Sterling-OMS](systems/channels/Sterling-OMS/CLAUDE.md) | IBM Sterling OMS 10 | baseline | OMS omnicanal — 96.69% órdenes pendientes ⚠ |
| [Bridgecore](systems/channels/Bridgecore/CLAUDE.md) | Bridgecore | baseline | Gateway POS ↔ backend (exclusivo LIV) |
| [Digital-Platform](systems/channels/Digital-Platform/CLAUDE.md) | Java / GCP | transitional | Apps GCP modernas: Gestor4PL, XD/App Surtido + futura plataforma commercetools |

### Integration (transitional)

| Sistema | Vendor | togaf_state | Rol |
|---------|--------|-------------|-----|
| [IBM-IIB](systems/integration/IBM-IIB/CLAUDE.md) | IBM Integration Bus 10 | baseline | Bus corporativo central — 15+ sistemas integrados |
| [Tumbleweed](systems/integration/Tumbleweed/CLAUDE.md) | Broadcom | baseline | MFT — bancos, SAT, carriers |
| [Control-D](systems/integration/Control-D/CLAUDE.md) | BMC Software | baseline | Scheduler mainframe + output management |
| [Apigee](systems/integration/Apigee/CLAUDE.md) | Google Apigee | target | API Gateway (deployment parcial) |

### Data (Data Architecture domain)

| Sistema | Vendor | togaf_state | Rol |
|---------|--------|-------------|-----|
| [CDP-GCP](systems/data/CDP-GCP/CLAUDE.md) | Internal / GCP | target | Customer Data Platform — Customer 360 (en construcción) |
| [SAP-BW](systems/data/SAP-BW/CLAUDE.md) | SAP | baseline | DWH: BW Híbrido (Presidencia) + BW LIV + BW PDM + BW4 SBB (Azure) |

**Nota AS-IS + TO-BE**: este proyecto incluye análisis del estado actual de los 20 sistemas (Reverse Engineering) y construcción del cerebro TO-BE (diseño target).

---

## Dominios de Negocio Retail (Liverpool)

| ID | Dominio | Sistemas principales (confirmados) |
|----|---------|-------------------------------------|
| R01 | Gestión Comercial | SAP ECC/S4 · PIM-STEP · Oracle PL-SQL (Size Scaling, Allocation) |
| R02 | Gestión de Clientes y Lealtad | Siebel-CRM (legacy) · CDP-GCP (nuevo) · VPL-Vision-Plus (LiverpoolCard cliente) |
| R03 | Servicios Financieros | VPL-Vision-Plus · FICO-TRIAD · Base24 · Cyberfinancial · Card-Wizard · Mainframe |
| R04 | Cadena de Suministro y Logística | SAP-EWM · Sterling-OMS · IBM-IIB · Tumbleweed · Digital-Platform (Gestor4PL) |
| R05 | Canales Digitales | ATG-Endeca (AS-IS) · Digital-Platform (GCP apps) · Bridgecore · Sterling-OMS |
| R06 | Operaciones de Tienda | SAP-ECC/PDM · Bridgecore · Base24 · Mainframe (SOMS) |
| R07 | Finanzas y Contabilidad | SAP FI/CO · SAP-BW · Tumbleweed (bancos/SAT) |
| R08 | Recursos Humanos | SAP HCM |
| R09 | Analítica e Inteligencia | SAP-BW · CDP-GCP · SAP BusinessObjects · SAS (GCP) |
| R10 | Infraestructura y Plataforma | IBM-IIB · Apigee · Control-D · Tumbleweed |

---

## Decisión 7R — Estado Inicial

`[DATO-REQUERIDO]` — La decisión 7R por dominio se produce al final de la Etapa 4 de análisis RE por sistema. Requiere completar inventario y análisis de cada stack.

Hipótesis inicial (actualizar con evidencia):

| Sistema | Hipótesis 7R | Fundamento |
|---------|-------------|-----------|
| SAP ECC | Replatform (S/4HANA brownfield) o Retain (si ya es S/4HANA) | SAP tiene roadmap claro de migración |
| Mainframe z/OS | Encapsulate + Refactor (API-fy CICS → microservicios) | Liverpool anunció migración a commercetools — el mainframe debe encapsularse |
| Oracle PL-SQL | Refactor a microservicios (LiverpoolCard) | Lógica financiera compleja requiere análisis antes de decidir |
| Java Microservicios | Evolve / Replatform (cloud-native) | Ya es moderno — optimizar hacia commercetools + nube |

---

## Estado Actual y Plan de Trabajo

### Fase: DISCOVER · Etapa: 0 (Setup & Inventory) — pendiente de iniciar

**Próximos pasos inmediatos:**

1. Confirmar información faltante (`[DATO-REQUERIDO]`) con equipo Liverpool.
2. Solicitar insumos para inventario de los 4 stacks.
3. Ejecutar Etapa 0 por sistema (SAP: Specialist - SAP ABAP; Oracle: Specialist - Oracle Forms PL-SQL; Mainframe: Specialist - Reverse Engineering MM; Java: Software Engineering SME).
4. Construir `liverpool-brain/` con schema retail adaptado.

---

## Federated Brain

El programa Liverpool tiene un brain federado en `liverpool-brain/` que agrega el conocimiento de los 4 sistemas. Al igual que BanCoppel tiene `bank-brain/`, Liverpool tendrá:

| Componente | Estado | Notas |
|-----------|--------|-------|
| `liverpool-brain/` | `[STATE: SCAFFOLD]` | Estructura creada — brain pendiente de población |
| `liverpool-brain/dt/dt-inteligencia-cliente/` | `[STATE: ACTIVE]` — Poblado | Inteligencia del cliente poblada con investigación web 2026-09-02 |
| Schema retail | Dominios R01-R10 vs D01-D49 bancario | Adaptado para retail vs banking |

---

## Señal Estratégica para el Programa

Liverpool anunció el **5 de noviembre de 2025** una **reorientación estratégica**: menos aperturas físicas, más inversión en digital y logística. Seleccionó **commercetools** para habilitar "agentic commerce experiences" — esto indica que el e-commerce Java actual será migrado a una plataforma composable. Este contexto hace que el análisis AS-IS del stack Java sea urgente como base para la decisión de migración.

fuente: https://www.prnewswire.com/news-releases/commercetools-selected-by-liverpool-to-unlock-agentic-commerce-experiences-302605025.html

---

## ADRs del Proyecto (pendientes de crear)

- `ADR-SPE-AM-003-001`: Taxonomía de sistemas Liverpool — clasificación TOGAF por los 4 stacks.
- `ADR-SPE-AM-003-002`: Decisión 7R por dominio funcional — después de Etapa 4.
- `ADR-SPE-AM-003-003`: Patrón de coexistencia / estrategia de migración — después de 7R.
- `ADR-SPE-AM-003-004`: Schema del Liverpool Brain (dominios R01-R10, tabla `components`).

---

## Handoff a SMEs y Specialists

| Sistema | Fase | SME / Specialist | Estado |
|---------|------|-----------------|--------|
| SAP | DISCOVER (RE) | Specialist - SAP ABAP | Pendiente activar |
| Oracle PL-SQL | DISCOVER (RE) | Specialist - Oracle Forms PL-SQL | Pendiente activar |
| Mainframe z/OS | DISCOVER (RE) | Mainframe Modernization L4 — Specialist RE | Pendiente activar |
| Java Microservicios | DISCOVER | Software Engineering SME | Pendiente activar |
| DESIGN + BUILD | — | Software Engineering SME · TS&T | Pendiente |

---

## DoD Gate — Salida de DISCOVER

- [ ] Inventario completo de componentes por sistema (SAP, Oracle, Mainframe, Java).
- [ ] Dominios R01-R10 con mapeo a sistemas cubiertos.
- [ ] Decisión 7R por dominio firmada por arquitecto + sponsor Liverpool.
- [ ] `liverpool-brain/` con schema retail populado (dominios + ETB retail adaptado).
- [ ] Patrón de coexistencia + alineación con agenda commercetools declarada.
- [ ] DoR completa para DESIGN firmada.

---

*Creado 2026-09-02 · v0.1 · Liverpool SPE-AM-003 · DISCOVER Etapa 0 pendiente de iniciar · Stack heterogéneo: SAP + Oracle + Mainframe + Java · Empresa pública BMV: LIVEPOLC*
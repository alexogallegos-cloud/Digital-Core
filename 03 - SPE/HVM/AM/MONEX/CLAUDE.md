# MONEX Grupo Financiero — Digital Brain
> FX & Pagos Internacionales · Arquitectura de Integración · Plan Apolo

---

## QUÉ ES ESTE PROYECTO

Digital Brain para MONEX Grupo Financiero — ecosistema de conocimiento vivo del estado de los sistemas
de tecnología que soportan el negocio de FX, pagos internacionales y brokerage.

**Cliente**: MONEX Grupo Financiero (MONEX Casa de Bolsa)
**Reguladores**: CNBV · Banxico · FCA (UK) · FinCEN (US) · CLS
**Marco regulatorio**: CNBV · Banxico SPEI/DIOR · DORA · ISO 20022 · PCI-DSS · SOC 2
**Geografía**: México · USA (Washington) · UK (Londres)
**Engagement**: Servicios de Arquitectura de Integración — Plan Apolo (CON → SI)

---

## WIN THEME DEL ENGAGEMENT

> **"El Digital Brain de MONEX"** — ontología de arquitectura OWL 2 DL como motor de gobierno,
> cumplimiento y decisión. El único proponente que entrega un grafo semántico evaluable en producción,
> no un diagrama de arquitectura.

Cuatro superpoderes que MONEX obtiene con el Digital Brain:
1. **Visibilidad de impacto**: responder en segundos "¿qué flujos quedan en incumplimiento si cambias un schema de ISO 20022?"
2. **Gobierno de APIs**: catálogo semántico live de todas las APIs del programa
3. **Trazabilidad regulatoria**: mapa automático regulación → sistema → endpoint
4. **Decisión informada**: el Integration Committee consulta el grafo, no a personas

---

## ESTRUCTURA DEL DIGITAL BRAIN

| Componente | Ubicación | Rol |
|------------|-----------|-----|
| Cerebro Federado | `monex-brain/` | Agrega todos los system-level brains + ontología OWL + ETB + ITOM |
| Sistemas — Run the Bank (AS-IS) | `systems/{categoría}/{sistema}/` | Brain por sistema en producción hoy |
| Proyectos — Change the Bank | `projects/{proyecto}/` | Programas de transformación activos |
| Design Studio | `design-studio/` | Paleta MONEX, logos, templates HTML |

### Proyectos activos (Change the Bank)

| Proyecto | Iniciativa Apolo | Estado |
|----------|-----------------|--------|
| `payments-modernization/` | Iniciativa 1 — Motor de Pagos | ACTIVO — DISCOVER |

---

## LANDSCAPE DE SISTEMAS — TOGAF

### core/ — Sistemas Core de Negocio (SoR)

| Sistema (slug) | Descripción | Estado |
|----------------|-------------|--------|
| fx-engine | Motor FX: spot, forwards, opciones, NDF — núcleo del negocio MONEX | SCAFFOLD |
| treasury | Treasury Management System — gestión de posiciones, límites y liquidez | SCAFFOLD |
| payments-legacy | Sistema de pagos legacy — motor origen que Apolo reemplaza | SCAFFOLD |

### integration/ — Capa de Integración

| Sistema (slug) | Descripción | Estado |
|----------------|-------------|--------|
| mulesoft | API Gateway Anypoint — CONFIRMADO como backbone de integración | CONFIRMED |
| swift | Conectividad SWIFT — mensajería interbancaria internacional | SCAFFOLD |
| spei | Conector SPEI/DIOR — pagos domésticos Banxico | SCAFFOLD |

### channels/ — Canales

| Sistema (slug) | Descripción | Estado |
|----------------|-------------|--------|
| portal-clientes | Portal web/app clientes MONEX — cotizaciones FX, pagos, estatus | SCAFFOLD |
| api-marketplace | API Marketplace — integración B2B con corporativos y corresponsales | SCAFFOLD |

### data/ — Datos

| Sistema (slug) | Descripción | Estado |
|----------------|-------------|--------|
| golden-record-target | Golden Record (TO-BE) — Modelo de Datos Global Apolo · hoy no existe | TARGET |

### compliance/ — Regulatorio

| Sistema (slug) | Descripción | Estado |
|----------------|-------------|--------|
| cnbv-banxico | Reporting regulatorio CNBV + Banxico (DIOR, SPEI, AML) | SCAFFOLD |
| dora | DORA compliance — operaciones UK/EU · Digital Operational Resilience | SCAFFOLD |

### Target — Apolo (to-be)

| Iniciativa | Descripción |
|------------|-------------|
| Motor de Pagos | Nuevo motor cloud-native ISO 20022 (reemplaza payments-legacy) |
| FX Next | Plataforma FX modernizada — pricing engine + STP |
| Golden Record | MDM centralizado — primera vez que MONEX tiene data model canónico |
| Plataforma Apolo | Plataforma destino + decommission del legado |

---

## PROGRAMA APOLO — 4 INICIATIVAS

### Iniciativa 1: Motor de Pagos
- **Objetivo**: reemplazar el motor de pagos legacy por uno cloud-native ISO 20022
- **Stack target**: MuleSoft (orquestación) + motor de pagos cloud-native + CLS Settlement
- **Regulación**: SPEI (Banxico) · SWIFT · ISO 20022 · PCI-DSS

### Iniciativa 2: FX Next
- **Objetivo**: modernizar la plataforma FX — mejor STP, pricing en tiempo real, integración con CLS
- **Stack target**: por definir en DESIGN phase
- **Regulación**: CNBV (operaciones FX) · CLS · Bloomberg/Reuters feeds

### Iniciativa 3: Modelo de Datos Global / Golden Record
- **Objetivo**: crear el primer MDM canónico de MONEX (hoy no existe)
- **Gap crítico confirmado**: sin Data Catalog ni MDM — riesgo regulatorio real
- **Stack target**: por definir · candidatos: Informatica MDM · Collibra · custom

### Iniciativa 4: Plataforma Apolo / Decommissioning
- **Objetivo**: plataforma destino cloud-native + decommission ordenado del legado
- **Patrón**: Strangler-Fig por capability · parallel-run obligatorio
- **Riesgo #1 declarado por MONEX**: capacidad de EJECUCIÓN organizacional

---

## CADENA DE HERENCIA

```
Digital Core/CLAUDE.md
└── Digital Core/AGENTES-UNIVERSAL-RULES-DC.md
    └── 03 - SPE/HVM/AM/MONEX/CLAUDE.md            ← este archivo
        └── monex-brain/CLAUDE.md                   ← cerebro federado
            └── systems/{cat}/{sys}/CLAUDE.md        ← brains por sistema
```

---

## DESIGN STUDIO

Paleta MONEX, logos y templates HTML en `design-studio/`.
Colores: `#0B1D46` (navy header) · `#00AEEF` (azul "Banca Digital") · `#FFFFFF` · `#F5F5F5`

---

## CONTACTOS CLAVE

| Rol | Persona | Nota |
|-----|---------|------|
| Design Authority / Arquitecto Global | Rafa | 5 meses en MONEX · anti-PPT · punto de contacto y decisor |
| Gerente Sr Compras | Ricardo Arredondo Falcon | Proceso de compra |
| Account Lead ACN | Arne Shrek | — |
| Arquitectura ACN | Alejandro Gallegos | — |

---

*Última actualización: 2026-09-22 · v1.2 · Proyecto renombrado a Payments Modernization (projects/payments-modernization). v1.1: ETB Banking V5.0 + ITOM overlay + estructura Change the Bank. v1.0: Scaffold inicial.*

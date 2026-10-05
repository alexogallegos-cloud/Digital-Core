# Digital Twin — Plataforma Digital GCP (TO-BE en Construcción)
> `liverpool-brain/dt/dt-plataforma-digital-gcp/` · Liverpool AM · SPE-AM-003
> Fuente: Arquitectura_Liverpool_Dashboard_1.html (2026-06-16) · Creado: 2026-09-08
> **[STATE: ACTIVE — scaffold; fuente de datos pendiente]**

## Propósito

Gemelo digital de la plataforma digital moderna de Liverpool en Google Cloud Platform: Gestor4PL (gestión logística 4PL), App Surtido / XD (planeación de surtido), Apigee (API Gateway parcialmente desplegado) y la base de la futura implementación de commercetools.

Es el único DT del programa que representa el **TO-BE en construcción** — no un sistema legado a modernizar sino la plataforma hacia la que Liverpool está migrando. Entender este DT es crítico para calibrar la brecha entre el AS-IS y el estado actual de la plataforma target.

## Capa de Arquitectura

**Channels (SoD) + Integration** — togaf_state: `transitional` (en construcción activa)

## Dominios Principales

R04 — Cadena de Suministro y Logística (Gestor4PL)
R05 — Canales Digitales (commercetools, ecommerce)
R01 — Gestión Comercial (App Surtido / XD)
R10 — Infraestructura y Plataforma (Apigee)

## Sistemas Involucrados

| Sistema | Vendor/Stack | Estado | Rol |
|---------|-------------|--------|-----|
| **Gestor4PL** | Java / GCP | Productivo | Gestión de proveedores logísticos 4PL — visibilidad de carga, SLAs, tracking |
| **App Surtido / XD** | Java / GCP | Productivo | Planeación de surtido por tienda — qué producto va en qué tienda y cuándo |
| **Apigee** | Google Apigee | Parcial | API Gateway — desplegado parcialmente; convive con IBM IIB como punto de integración |
| **commercetools** | commercetools | En construcción | Plataforma ecommerce composable — seleccionado nov-2025 para reemplazar ATG |
| **CDP-GCP** | Internal / GCP | En construcción | Customer Data Platform — Customer 360 (compartido con dt-inteligencia-cliente) |

## Arquitectura TO-BE (en construcción)

```
CLIENTE DIGITAL
    │
    ▼
commercetools (Storefront API)
    │
    ├── Product Catalog ←─── PIM/STEP (sincronización)
    ├── Pricing ←─────────── SAP ECC / S/4HANA
    ├── Inventory ←───────── SAP EWM / Sterling OMS (cloud)
    ├── Orders ──────────── Sterling OMS (cloud target)
    └── Customer ←────────── CDP-GCP (Customer 360)
         │
         ▼
    APIGEE (API Gateway)
         │
         ├── → SAP S/4HANA (ERP core)
         ├── → VPL Vision Plus (LiverpoolCard auth)
         ├── → Gestor4PL (fulfillment logístico)
         └── → CDP-GCP (eventos de cliente)

GESTIÓN INTERNA
    │
    ├── App Surtido / XD ──→ SAP S/4HANA (pedidos de surtido)
    └── Gestor4PL ─────────→ Carriers / WMS / tracking
```

## Estado Actual de la Plataforma (AS-IS de la plataforma TO-BE)

| Componente | Estado al 2026-09-08 |
|-----------|---------------------|
| Gestor4PL | Productivo — gestión 4PL operativa |
| App Surtido / XD | Productivo — reemplazó proceso manual de surtido |
| Apigee | Parcialmente desplegado — coexiste con IBM IIB; `[DATO-REQUERIDO]` qué APIs ya están en Apigee |
| commercetools | En implementación — seleccionado nov-2025; roadmap de migración desde ATG `[DATO-REQUERIDO]` |
| CDP-GCP | En construcción — Customer 360 parcialmente poblado |

## Señales Estratégicas

| Señal | Impacto |
|-------|---------|
| commercetools seleccionado nov-2025 | Decisión estratégica confirmada — el stack ecommerce legado (ATG) tiene fecha de muerte. Urgente mapear la brecha ATG → commercetools. |
| Apigee coexistiendo con IBM IIB | Hay dos capas de integración simultáneas — riesgo de fragmentación y duplicación de lógica. La estrategia de convergencia (¿cuándo Apigee reemplaza a IIB?) no está documentada. |
| Gestor4PL y App Surtido ya en GCP | Liverpool ya tiene capacidad de delivery en GCP — el equipo interno puede construir sobre GCP. Esto acelera la migración de otros sistemas a GCP. |
| Brecha de integración commercetools ↔ sistemas legacy | commercetools necesita integrarse con SAP (pricing, inventory), VPL (payments), Sterling OMS (fulfillment) — cada integración tiene esfuerzo de construcción no estimado. |

## Hipótesis 7R para Este Módulo

| Componente | Hipótesis | Fundamento |
|-----------|-----------|-----------|
| commercetools | **Expand — build** | Es la plataforma elegida. El trabajo es implementar y conectar con el landscape existente. |
| Apigee | **Expand** | Apigee debe crecer para ser el API Gateway único — reemplazando gradualmente IBM IIB para nuevas integraciones. |
| Gestor4PL | **Evolve / Retain** | Ya funciona bien en GCP. Evaluar si commercetools Order Management puede absorber parte de esta lógica. |
| App Surtido / XD | **Retain + Integrate** | Integrar con SAP S/4HANA (post-migración) como fuente de datos de demanda. |

## Estado

`[STATE: ACTIVE — scaffold]` — DT creado 2026-09-08.
Fuentes de datos primarias (`[DATO-REQUERIDO]`): roadmap commercetools, estado de Apigee (APIs ya expuestas), arquitectura Gestor4PL, backlog de integración TO-BE.

## Fuentes de Datos Disponibles

- [x] Dashboard AS-IS (confirmación de Gestor4PL, App Surtido, Apigee, commercetools como target)
- [x] Comunicado Liverpool / commercetools nov-2025 (selección estratégica)
- [ ] Roadmap de implementación commercetools (fases, timeline, equipo)
- [ ] Inventario de APIs ya expuestas en Apigee
- [ ] Arquitectura técnica de Gestor4PL y App Surtido (microservicios, bases de datos)
- [ ] Backlog de integraciones commercetools ↔ SAP / VPL / Sterling OMS

## Dependencias Cross-DT

- `dt-ecommerce-transicion` → Este DT cubre la transición ATG → commercetools desde la perspectiva de ecommerce; el DT de plataforma digital cubre el stack GCP subyacente. Ambos se complementan — el DT de transición define el QUÉ migrar, este DT define el DÓNDE aterrizar.
- `dt-bus-integracion` → Apigee y IBM IIB deben converger; la estrategia de consolidación es la clave del roadmap de integración
- `dt-sap-doble-landscape` → commercetools necesita pricing e inventory de S/4HANA — la migración SAP y la implementación de commercetools deben coordinarse
- `dt-pedido-omnicanal` → commercetools Order Management es el candidato a reemplazar Sterling OMS; la secuencia de migración debe definirse en conjunto
- `dt-inteligencia-cliente` → CDP-GCP es compartido entre este DT y el de inteligencia de cliente
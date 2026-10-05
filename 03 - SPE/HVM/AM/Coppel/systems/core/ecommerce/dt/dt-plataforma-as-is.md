# DT-PLAT-001 — Plataforma eCommerce Coppel — Estado AS-IS

**Digital Twin** | Tipo: Arquitectura AS-IS | Sistema: Coppel.com eCommerce
**Versión**: 1.0.0 | **Fecha**: 2026-09-15 | **Fuentes**: Q&A MS N3 (134 preguntas, 2026-08-06)

---

## 1. Arquitectura General AS-IS

La plataforma eCommerce de Coppel.com vive en un estado de **transición activa**: el backend legado (HCL Commerce) coexiste con la nueva arquitectura Composable Commerce mientras avanza el proyecto "Desacople".

```
                        USUARIO
                    Web           App (iOS/Android)
                     │                   │
                  Akamai CDN           Firebase
                     │                   │
              ┌──────▼──────┐    ┌───────▼──────┐
              │ Next.js SSR │    │  App Backend  │
              │ (Composable)│    │ (cpl-ec-app)  │
              └──────┬──────┘    └───────┬───────┘
                     │                   │
              ┌──────▼───────────────────▼──────┐
              │         Apollo Federation        │
              │      (6 subgraphs GraphQL)       │
              └─────┬──────────────────┬─────────┘
                    │                  │
          ┌─────────▼────────┐ ┌───────▼──────────┐
          │  SFCC APIs       │ │  Servicios GKE    │
          │ (Basket/Orders/  │ │  (100+ Node/Go/   │
          │  Inventory/      │ │   Java/Python)    │
          │  Pricing)        │ │                   │
          └──────────────────┘ └──┬────────────────┘
                                  │
                    ┌─────────────┼──────────────┐
                    │             │              │
              ┌─────▼──┐   ┌─────▼──┐   ┌──────▼─┐
              │MongoDB │   │Postgres│   │Firestore│
              └────────┘   └────────┘   └─────────┘
```

**Estado HCL Commerce**: Los 150+ servicios de `cpl-ec-hcl-be-prod` siguen activos. Apollo Federation llama a servicios HCL no migrados aún (coexistencia activa).

---

## 2. Los 5 Proyectos GCP — Radiografía

### cpl-ec-hcl-be-prod (Legado HCL)
- **Propósito**: Backend monolítico HCL Commerce — Coppel.com legado
- **Estado**: MIGRANDO → deprecación progresiva
- **Escala**: 150+ servicios desplegados en GKEs
- **Riesgo**: 15+ servicios marcados como "Deprecado" pero aún en producción
- **Lenguajes**: Java (principal), Node.js, Python

### cpl-ec-dcplig-prod (Composable — Destino)
- **Propósito**: Arquitectura Composable Commerce — frontends Next.js + subgraphs Apollo
- **Estado**: ACTIVO y creciendo con cada ola de desacople
- **Escala**: Crece cada sprint de migración
- **Lenguajes**: TypeScript/Node.js, Next.js

### cpl-ec-app-be-prod (App Backend)
- **Propósito**: Backend de la aplicación móvil iOS/Android
- **Estado**: ACTIVO, desarrollo independiente
- **Lenguajes**: Node.js, Go

### cpl-ec-sfcc-prod (SFCC APIs)
- **Propósito**: APIs de Salesforce Commerce Cloud (headless)
- **Estado**: ACTIVO
- **Scope**: SOLO APIs — Basket, Orders, Inventory, Pricing. No full Salesforce.
- **Nota crítica**: Coppel NO usa SFCC como plataforma completa. Es headless puro.

### cpl-ec-pci-tdc-prod (Pagos / PCI)
- **Propósito**: Procesamiento de pagos con tarjeta — perimetro PCI-DSS
- **Estado**: ACTIVO, acceso restringido
- **Gateway**: eGlobal (mismo que BanCoppel para pagos interbancarios)

---

## 3. Stack Tecnológico Detallado

### Backend (100+ servicios en 14 GKEs)

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| Node.js | Principal — APIs y workers | Activo |
| Go | Alto throughput, infraestructura | Activo |
| Java | Servicios legado HCL | Activo (deprecando) |
| Python | Automatización, datos | Activo |

### Frontend

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| Next.js | Frontend composable (destino) | Activo |
| Akamai | CDN principal — cache y DDoS | Activo |

**Nota**: Akamai es el CDN principal, **NO Redis**. Redis se usa para caches de servicios backend.

### API y Comunicación

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| Apollo Federation | GraphQL — 6 subgraphs | Activo |
| Apigee | API Gateway — externas e internas | Activo |

### Bases de Datos

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| MongoDB | Catálogo, sesiones, config | Activo |
| PostgreSQL | Órdenes, cuentas, transaccional | Activo |
| Firestore | Tiempo real, app | Activo |
| Redis (Google) | Caches de servicios | Activo |
| VoltDB | **DATO-REQUERIDO** — rol no documentado | Desconocido |

### Infraestructura

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| GKE (14 clusters) | Orquestación de contenedores — 3 zonas, auto-scaling | Activo |
| Firebase | Móvil — notificaciones, auth, analytics | Activo |

### Observabilidad

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| Datadog | APM, métricas, logs, trazas | Activo (nivel 4 = solo lectura para N3) |

### Pagos y Commerce

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| eGlobal | Gateway pagos — PCI scope | Activo |
| SFCC | APIs headless (Basket/Orders/Inventory/Pricing) | Activo |
| LucidWorks | Búsqueda y PIM (destino migración) | Activo/Migrando |

### ITSM

| Tecnología | Rol | Estado |
|-----------|-----|--------|
| InvGate | ITSM actual — tickets N3 | Migrando |
| Salesforce | ITSM destino | Planeado |
| Confluence + CMDB | Documentación técnica | Activo |
| Jira + ADO | CI/CD y tracking | Activo |

---

## 4. El Proyecto "Desacople" — HCL → Composable

La transformación más importante en curso es la migración de HCL Commerce a Composable Commerce.

### ¿Qué es el Desacople?

Cada "ola" del Desacople migra un conjunto de capacidades desde HCL Commerce al stack Composable:
- **Origen**: HCL Commerce (monolito Java en `cpl-ec-hcl-be-prod`)
- **Destino**: Next.js + Apollo Federation + SFCC APIs + servicios propios (`cpl-ec-dcplig-prod`)
- **Método**: Migración por capacidad, no big-bang

### Estado actual

```
HCL Commerce (Origen)          Composable (Destino)
─────────────────────          ────────────────────
[Catálogo] ─────────────────► LucidWorks (PIM)
[Checkout] ──────────────────► SFCC APIs + Apollo
[OMS] ───────────────────────► SFCC Orders API
[Inventory] ─────────────────► SFCC Inventory API
[Web Frontend] ──────────────► Next.js + Akamai
[Servicios propios] ─────────► GKE (Node/Go/Python)
[TODO: Loyalty] ─────────────► TBD (no definido aún)
```

### Riesgo de migración en N3

En los 12 meses de un contrato N3, el scope de servicios a soportar **cambia activamente**:
- Servicios HCL se deprecan → salen de scope
- Servicios Composable entran → requieren nuevo conocimiento
- El equipo N3 debe conocer AMBAS plataformas simultáneamente durante la transición

---

## 5. KPIs de Negocio

| KPI | Definición | Impacto |
|-----|------------|---------|
| **ATC** (Add-to-Cart) | % de usuarios que añaden producto al carrito | Compra potencial |
| **Conversión** | % de compras completadas / visitas | Ingreso directo |
| **Abandono** | % que añade al carrito pero no compra | Oportunidad perdida |
| **NPS** | Net Promoter Score — app móvil | Retención |
| **Disponibilidad** | Uptime de Coppel.com | $180K MXN/min de impacto |

---

## 6. Modelo de Soporte AS-IS

### Estructura actual (Publicis Sapient)

| Nivel | Responsable | Scope |
|-------|-------------|-------|
| N1 | Coppel interno | Primeros respondedores — user-facing issues |
| N2 | Coppel interno | Diagnóstico técnico — no llega a código |
| N2.5 | Desconocido (posible Publicis Sapient) | **Frontera no documentada en RFP** |
| N3 | Publicis Sapient | Problem tickets — resolución técnica compleja |

### SLAs vs. realidad

| Nivel | SLA Coppel (días hábiles) | MTTR real (Publicis Sapient) |
|-------|---------------------------|------------------------------|
| P1 | 5 | **20 días hábiles** ← no cumple |
| P2 | 10 | Desconocido |
| P3 | 15 | Desconocido |
| P4 | 20 | Desconocido |

**El MTTR de 20 días vs. SLA de 5 días para P1 es el driver del RFP.**

---

## 7. Herramientas Operativas

| Herramienta | Propietario | Acceso Proveedor N3 |
|-------------|-------------|---------------------|
| InvGate | Coppel (licencias) | Completo — gestión de tickets |
| Datadog | Coppel | Solo lectura (nivel 4) |
| Confluence | Coppel (licencias) | Consulta — documentación técnica |
| CMDB | Coppel | Consulta — inventario de servicios |
| GKE (plano de control) | Coppel | Sin acceso |
| Ambientes (dev/staging) | Coppel | Coppel provee todos los ambientes |

---

## 8. Datos Requeridos Pendientes (DATO-REQUERIDO activos)

| ID | Pregunta | Impacto |
|----|----------|---------|
| DR-001 | ¿Cuál es el rol exacto de VoltDB en el stack? | Si es crítico para pagos, N3 necesita habilidad específica |
| DR-002 | ¿Qué es BITs AI y puede N3 integrarse? | Define scope de AI en soporte |
| DR-003 | Frontera exacta N2/N2.5/N3 | Define qué tickets recibe N3 |
| DR-004 | SLA de disponibilidad (uptime objetivo) | Define SLO de base |
| DR-005 | ¿Cuándo se depreca HCL Commerce completamente? | Define vida del scope N3 actual |
| DR-006 | ¿Está Rust en scope? (Q127 sin respuesta) | Stack de lenguajes a dominar |
| DR-007 | Servicios "Deprecado" críticos — ¿cuáles son? | Gestión de riesgo activo |

---

*Fuentes: Q&A MS N3 (134 preguntas, 2026-08-06), DTs SME v2.0, contexto engagement Coppel.*
*Estado: ACTIVO — radiografía del AS-IS para onboarding N3 y análisis de delivery.*

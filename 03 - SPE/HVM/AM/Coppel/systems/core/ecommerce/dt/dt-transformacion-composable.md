# DT-TRANS-001 — Transformación Composable Commerce

**Digital Twin** | Tipo: Análisis de transformación | Sistema: Composable Commerce
**Versión**: 1.0.0 | **Fecha**: 2026-09-15 | **Fuentes**: Q&A MS N3, ADRs, contexto engagement

---

## 1. Contexto de la Transformación

Coppel.com opera hoy sobre **HCL Commerce** — una plataforma monolítica IBM/HCL que fue el estándar del eCommerce enterprise en los años 2010. El monolito tiene limitaciones estructurales:

- **Time-to-market lento**: Cualquier cambio requiere build y deploy del monolito completo
- **Escalado ineficiente**: Escala todo-o-nada, no por capacidad individual
- **Deuda técnica acumulada**: 150+ servicios, 15+ marcados "Deprecado" aún activos
- **Dificultad de personalización**: Personalizar HCL requiere override de templates Java

La solución adoptada por Coppel (ADR-COPPEL-001): **migrar a Composable Commerce** — arquitectura donde cada capacidad de negocio es un microservicio independiente.

---

## 2. La Arquitectura Composable — Definición

"Composable Commerce" no es un producto, es un patrón arquitectónico:

| Concepto | Definición | En Coppel |
|----------|------------|-----------|
| **Headless** | Frontend desacoplado del backend | Next.js + Apollo Federation |
| **MACH** | Microservices, API-first, Cloud-native, Headless | Stack GKE en GCP |
| **Best-of-breed** | Cada capacidad usa el mejor proveedor | SFCC para commerce APIs, LucidWorks para búsqueda |
| **API-first** | Todo se expone y consume vía APIs | Apollo Federation como capa unificadora |

### Ventajas para Coppel

1. **Deploy independiente**: Se puede actualizar el carrito sin afectar el catálogo
2. **Escala por capacidad**: En Hot Sale, solo escala el checkout y catálogo, no todo
3. **A/B testing**: Múltiples versiones del frontend simultáneas
4. **Velocidad de innovación**: Equipos paralelos en capacidades independientes

---

## 3. El Stack Composable de Coppel

```
┌─────────────────────────────────────────────┐
│              PRESENTACIÓN                    │
│  Next.js (SSR) + React  ←→  Akamai CDN     │
└────────────────────┬────────────────────────┘
                     │ GraphQL
┌────────────────────▼────────────────────────┐
│            API FEDERATION                    │
│        Apollo Federation (6 subgraphs)       │
│                                             │
│  Subgraph 1: Catálogo + Búsqueda (LucidWorks)│
│  Subgraph 2: Carrito (SFCC Basket API)      │
│  Subgraph 3: Órdenes (SFCC Orders API)      │
│  Subgraph 4: Inventario (SFCC Inventory)    │
│  Subgraph 5: Precios (SFCC Pricing API)     │
│  Subgraph 6: [Cuenta/Loyalty — TBD]         │
└─────┬──────────────────────────────┬────────┘
      │                              │
┌─────▼──────┐                ┌──────▼────────┐
│ SFCC APIs  │                │ Servicios GKE │
│ (headless) │                │ (100+ svc)    │
└────────────┘                └───────────────┘
```

### Los 6 Subgraphs de Apollo Federation

Los 6 subgraphs son la columna vertebral de Composable. Cada uno es independiente:

| Subgraph | Responsabilidad | Backend |
|----------|----------------|---------|
| Catálogo | Productos, atributos, categorías | LucidWorks |
| Búsqueda | Motor de search, filtros, relevancia | LucidWorks |
| Carrito | Basket, promociones, sessions | SFCC Basket API |
| Órdenes | Lifecycle de la orden | SFCC Orders API |
| Inventario | Stock en tiempo real | SFCC Inventory API |
| Precios | Pricing dinámico, descuentos | SFCC Pricing API |

**DATO-REQUERIDO**: El 6º subgraph (Cuenta/Loyalty) no fue confirmado en Q&A. Puede ser cliente o loyalty.

---

## 4. SFCC — Entendimiento Crítico

**Salesforce Commerce Cloud (SFCC) es usado por Coppel EXCLUSIVAMENTE como un proveedor de APIs headless.** No es una implementación full Salesforce.

Esto significa:
- No hay Salesforce frontend
- No hay Salesforce Order Management (OMS) full
- No hay Salesforce B2C Commerce storefront
- **Solo se consumen 4 APIs**: Basket, Orders, Inventory, Pricing

### ¿Por qué esto importa para N3?

- El scope N3 en SFCC es **limitado**: ajustes sobre custom objects y configuraciones de APIs
- No se hace development full en SFCC — es configuration-level
- Errores en SFCC APIs pueden estar en la configuración de custom objects o en la integración Apollo → SFCC

---

## 5. LucidWorks — El Nuevo PIM y Buscador

LucidWorks es la plataforma de búsqueda y PIM destino:

| Capacidad | Descripción |
|-----------|-------------|
| PIM | Gestión de información de productos (atributos, variantes, imágenes) |
| Búsqueda | Motor de búsqueda contextual con Machine Learning |
| Relevancia | Ranking de resultados por comportamiento |
| Faceting | Filtros dinámicos por categoría, precio, marca |

La migración del catálogo de productos desde HCL Commerce a LucidWorks es una de las olas más complejas del Desacople — es el corazón del eCommerce.

---

## 6. Akamai — CDN Principal

Akamai es la capa de distribución y protección de Coppel.com:

| Función | Descripción |
|---------|-------------|
| CDN | Cache de assets estáticos (imágenes, JS, CSS) — reduce carga a GKE |
| Edge Computing | Lógica de routing y A/B testing en edge |
| DDoS Protection | Absorbe ataques antes de llegar a GKEs |
| Performance | Reduce latencia geográfica en México |

**Nota crítica para N3**: El proveedor N3 no tiene acceso directo a configuración de Akamai. Los cache purges y configuraciones son responsabilidad de Coppel. Esto puede ser un bottleneck en resolución de incidentes de cache.

---

## 7. Riesgos de la Transformación

### RISK-MIGR-001: Scope N3 Dinámico

El contrato N3 cubre servicios que **van a desaparecer** durante el contrato. El equipo N3 debe:
1. Conocer HCL Commerce (legado, para soporte de servicios aún activos)
2. Aprender el stack Composable (destino, para soporte de servicios migrados)
3. Gestionar la coexistencia (durante el desacople, ambos coexisten)

**Mitigación Accenture**: Win theme de conocer el destino — el equipo N3 debe ser experto en Composable desde el día 1, no aprenderlo durante el contrato.

### RISK-DUAL-SUPPORT: Coexistencia HCL + Composable

Durante el periodo de migración, un ticket N3 puede involucrar:
- Servicios HCL en `cpl-ec-hcl-be-prod`
- Servicios Composable en `cpl-ec-dcplig-prod`
- La integración entre ambos (Apollo Federation como mediador)

El diagnóstico requiere dominar ambas arquitecturas simultáneamente.

### RISK-DEPRECADO-ACTIVO: Servicios "Deprecado" en Producción

15+ servicios marcados "Deprecado" siguen activos. Esto implica:
- Código sin mantenimiento activo → bugs más difíciles de diagnosticar
- Sin documentación actualizada → mayor esfuerzo de KT
- Posible dependencia de otros servicios no documentada

---

## 8. Cronología de Madurez (Estimación)

| Fase | Período estimado | Estado |
|------|-----------------|--------|
| HCL Commerce como plataforma principal | Hasta ~2024 | Completado |
| Inicio del Desacople (Composable) | 2024-2025 | En curso |
| Coexistencia HCL + Composable | 2025-2026 | **ACTUAL** |
| Composable como plataforma principal | 2026-2027 | En camino |
| HCL Commerce deprecado completamente | ¿2027? | **DATO-REQUERIDO** |

---

## 9. Oportunidades para Accenture en la Transformación

| Oportunidad | Descripción | Servicio |
|-------------|-------------|----------|
| N3 expert en Composable | Conocimiento de destino como diferenciador | MS N3 |
| Acceleración del Desacople | Advisory en migración por ola (SFCC, LucidWorks, Next.js) | Consulting |
| QE de la migración | Testing de equivalencia HCL vs. Composable | S&PE QE |
| Observabilidad avanzada | Mejorar uso de Datadog para reducir MTTR | MS N3 + AMS |
| BOPIS y fulfillment | Activar la red de tiendas como dark stores | S&PE + AMS |

---

*Fuentes: Q&A MS N3 (2026-08-06), ADRs ADR-COPPEL-001..004, contexto SFCC headless, LucidWorks docs públicos.*
*Estado: ACTIVO — base para advisory de migración y plan de N3.*

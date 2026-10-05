# CAN — Créditos Asociados a Nómina · Project Agent · Santander México
# project_type: regulatory-compliance
# project_state: active
# platform: Banxico — Normativa CAN
# horizon_present: Crédito de nómina Santander (loans · core-banking) — en producción
# horizon_future: implementación de cumplimiento CAN — ajustes en sistemas + canales + reporting
# replaces_or_complements: complementa systems/core/core-banking · systems/processors/payments-engine · systems/channels/*

> **Tipo:** Proyecto de cumplimiento regulatorio — Créditos Asociados a Nómina
> **Estado:** `[STATE: ACTIVE]` — fase DISCOVER iniciada
> **Regulador:** Banco de México (Banxico)
> **Referencia:** Proyecto equivalente en BanCoppel `../../../BanCoppel/projects/can/` — 23 obligaciones ya catalogadas, reutilizables
> **Última actualización:** 2026-09-17

---

## ¿Qué es el Proyecto CAN?

CAN (Créditos Asociados a Nómina) es un proyecto de cumplimiento regulatorio que responde a la normativa de Banco de México sobre créditos cuyo pago se domicilia o deduce directamente de la cuenta de nómina del acreditado.

Banco Santander México ofrece **Crédito de Nómina** como uno de sus productos principales — esto lo coloca en scope directo de la normativa CAN.

El proyecto tiene dos fases:

| Fase | Descripción | Estado |
|------|-------------|--------|
| **DISCOVER** | Análisis normativa Banxico CAN + mapeo de impacto en sistemas Santander | En curso |
| **CHANGE** | Implementación de ajustes técnicos y de proceso para cumplimiento | Pendiente |

---

## Contexto Regulatorio

| Campo | Valor |
|-------|-------|
| Regulador | Banco de México (Banxico) |
| Marco | Normativa sobre Créditos Asociados a Nómina (CAN) |
| Artículos clave | Art. 63 Bis 3 (Mecanismo CAN) · Art. 81 Bis 1 · Art. 81 Bis 2 (Nómina Interbancaria) |
| Instrumentos | Circular 14/2017 Banxico (SPEI) + normativa CAN específica · cargar en `source/docs/regulacion/` |
| Plazo de cumplimiento | `[DATO-REQUERIDO]` — extraer de la circular |
| Sanción por incumplimiento | `[DATO-REQUERIDO]` — extraer de la circular |

> **Ventaja BanCoppel → Santander:** El análisis de normativa CAN ya fue realizado para BanCoppel — las **23 obligaciones regulatorias** son las mismas para todos los IBMs. Reutilizar el catálogo de obligaciones de `BanCoppel/projects/can/knowledge-base/regulacion/`. Lo que cambia es el análisis de impacto en sistemas Santander.

---

## Productos Santander en Scope CAN

| Producto | Sistema técnico principal | Estado confirmación |
|----------|--------------------------|---------------------|
| Crédito de Nómina (retail) | `loans` + `core-banking` | SCAFFOLD — confirmar en discovery |
| Crédito Pyme con descuento nómina | `loans` + `core-banking` | PROBABLE |
| Tarjeta de Crédito con cargo a nómina | `card-platform` + `loans` | PROBABLE |

> `[DATO-REQUERIDO]` Confirmar con equipo de producto Santander qué productos exactos están bajo la definición CAN de Banxico.

---

## Sistemas Santander en Scope

| Sistema | Tipo TOGAF | Relación con CAN |
|---------|-----------|-----------------|
| `systems/core/core-banking` | `core · SoR` | Registro del crédito de nómina, saldo, cuenta del acreditado — **sistema central en scope** |
| `systems/core/loans` | `core · SoR` | Módulo de crédito — originación, pagos, cobranza nómina — **scope directo** |
| `systems/processors/payments-engine` | `processors · SoR` | OBL-006: liquidación SPEI en refinanciamiento CAN; OBL-009: Clave Básica Estandarizada |
| `systems/integration/banxico-spei` | `integration` | OBL-006 + OBL-009: rails SPEI obligatorios para portabilidad |
| `systems/channels/supermovil` | `channels · SoD` | Disclosure y consulta del crédito de nómina al acreditado (OBL-016 prelación) |
| `systems/channels/santander-online` | `channels · SoD` | Mismo que SuperMóvil — canal web |
| `systems/compliance/cnbv-reporting` | `compliance · SoR` | Reportería regulatoria — obligaciones de reporte CAN hacia Banxico |
| `systems/channels/call-center` | `channels` | Atención de acreditados para portabilidad (Art. 81 Bis 1) |

---

## Digital Twins · `dt/`

### Fase DISCOVER — Análisis y Normativa

| DT | Propósito | SMEs | Estado |
|----|-----------|------|--------|
| `dt-normativa-can/` | Estructura la normativa Banxico CAN: obligaciones, plazos, sanciones, definiciones · **Reutiliza catálogo BanCoppel (23 obligaciones)** | Regulatory/Banxico · Industry Banking · Industry Banking Accounting | ACTIVE |
| `dt-impacto-sistemas/` | Mapea obligaciones CAN contra sistemas Santander: `loans`, `core-banking`, `payments-engine`; identifica capacidades faltantes | Industry Banking · Core Banking Transformation · Industry Payments → SPEI | ACTIVE |
| `dt-brecha-compliance/` | Gap analysis: obligaciones CAN vs. capacidades actuales Santander; brechas con criticidad y fecha | Regulatory/Banxico · Industry Banking Accounting · Cybersecurity · SRE & AIOps | ACTIVE |
| `dt-roadmap-cambios/` | Traduce brechas a User Stories y roadmap técnico; estima esfuerzo por sistema Santander | Core Banking Transformation · Software Engineering · IT Operating Model | ACTIVE |
| `dt-de-can/` | Especificación técnica Mecanismo Art. 63 Bis 3 (hub interbancario) — catálogo de campos, flujos | Framework — Integration Architecture · Industry Payments → SPEI · Regulatory/Banxico | ACTIVE |
| `dt-nomina-interbancaria/` | Art. 81 Bis 1 y 81 Bis 2: portabilidad de nómina — obligaciones Institución Ordenante/Receptora | Regulatory/Banxico · Industry Banking · Industry Payments → SPEI | ACTIVE |

### Fase DESIGN/BUILD — Solución de Implementación

| DT | Propósito | SMEs | Estado |
|----|-----------|------|--------|
| `dt-solucion-arquitectura/` | Arquitectura maestra de la solución CAN: diagrama de sistemas, ADRs clave (patrón integración, motor prelación, Clave Básica), riesgos | Integration Architecture · Core Banking Transformation · Software Engineering · Regulatory/Banxico | ACTIVE |
| `dt-solucion-integracion/` | Integración técnica Santander → Mecanismo Art. 63 Bis 3: flujos de mensajes, contrato API, retry, SLAs regulatorios | Integration Architecture · Industry Payments → SPEI · Software Engineering | ACTIVE |
| `dt-solucion-datos/` | Modelo de datos CAN: cambios schema en loans y core-banking, tabla can_prelacion, mandatos digitales, Clave Básica Estandarizada | Core Banking Transformation · Software Engineering · Regulatory/Banxico | ACTIVE |
| `dt-solucion-canales/` | Cambios en SuperMóvil y Santander Online: pantallas disclosure OBL-007, mandato digital OBL-005/OBL-018, vista prelación OBL-016 | Software Engineering · Industry Banking · Regulatory/Banxico | ACTIVE |
| `dt-solucion-prelacion/` | Motor de prelación OBL-016 (algoritmo + casos límite) y scheduler OBL-023 (timing 17:00 DHB) — CRITICIDAD ALTA | Core Banking Transformation · Software Engineering · IT Operating Model · Industry Payments → SPEI | ACTIVE |
| `dt-solucion-testing/` | Estrategia de testing: 23 obligaciones × casos de prueba, simulador Banxico, SLA tests, certificación go-live | Quality Engineering · Software Engineering · Regulatory/Banxico · IT Operating Model | ACTIVE |

---

## Estructura del Knowledge Base

```
knowledge-base/
├── regulacion/
│   ├── circular-banxico-can.md        ← resumen estructurado normativa (reutilizable de BanCoppel)
│   ├── obligaciones-can.md            ← 23 obligaciones catalogadas (mismas que BanCoppel)
│   └── glosario-can.md                ← definiciones legales clave
├── rules/
│   ├── sistemas-en-scope-can.md       ← mapeo de sistemas Santander vs. obligaciones
│   ├── gap-analysis-can.md            ← brechas identificadas (SANTANDER-específico)
│   └── reglas-derivadas-can.md        ← reglas de negocio derivadas
└── vocab/
    └── vocab-can.json                 ← términos CAN (compartido con BanCoppel)
```

---

## Pipeline de Análisis (Fase DISCOVER)

```
[REUTILIZAR BanCoppel] Normativa CAN (23 obligaciones ya catalogadas)
    ↓
dt-normativa-can → adaptar a contexto Santander (mismo marco, diferente cliente)
    │
    ├──→ dt-de-can → Mecanismo Art. 63 Bis 3 (igual para todos los IBMs)
    │
    └──→ dt-nomina-interbancaria → Art. 81 Bis 1 y 81 Bis 2 (igual para todos)
    ↓
dt-impacto-sistemas → mapear vs. loans · core-banking · payments-engine Santander
    ↓                 (DIFERENTE a BanCoppel — sistemas distintos)
dt-brecha-compliance → gap analysis Santander-específico
    ↓
dt-roadmap-cambios → User Stories + estimación para sistemas Santander
    ↓
portal/index.html → dashboard de cumplimiento CAN Santander
```

---

## Relación con el Ecosistema Santander

| Proyecto / Sistema | Relación |
|-------------------|----------|
| `systems/core/loans` | Fuente técnica principal — módulo crédito de nómina |
| `systems/core/core-banking` | Registro de cuentas de nómina del acreditado |
| `systems/processors/payments-engine` | Liquidación SPEI refinanciamiento (OBL-006) |
| `santander-brain/` | Hallazgos CAN se propagan al federador (Regla B10) |

---

## Referencia Cross-Cliente — BanCoppel CAN

La normativa CAN de Banxico es **idéntica** para todos los IBMs. El análisis regulatorio ya
está hecho en BanCoppel. Para este proyecto Santander:

| Artefacto | Estrategia |
|-----------|------------|
| Catálogo de 23 obligaciones | **Reutilizar** de BanCoppel — no re-extraer |
| Glosario regulatorio | **Reutilizar** de BanCoppel |
| Mecanismo Art. 63 Bis 3 | **Reutilizar** — es infraestructura Banxico, no banco |
| Análisis de impacto en sistemas | **Nuevo** — sistemas Santander son distintos |
| Gap analysis | **Nuevo** — capacidades actuales Santander son distintas |
| Roadmap de cambios | **Nuevo** — stack Santander es diferente (Java probable vs. Informix) |

---

## Handoffs Canónicos

| Trigger | SME destino |
|---------|-------------|
| Interpretación artículos Banxico CAN | Regulatory/Banxico |
| Impacto contable créditos nómina (CNBV CUB) | Industry Banking Accounting |
| Productos bancarios de nómina en scope | Industry Banking |
| Diseño cambios técnicos en core banking / loans | Core Banking Transformation · Software Engineering |
| OBL-006 + OBL-009 (SPEI / Clave Básica) | Industry Payments → SPEI |
| Mecanismo hub interbancario Art. 63 Bis 3 | Framework — Integration Architecture |
| Timing OBL-023 (≤ 17:00 DHB) + monitoreo prelación OBL-016 | SRE & AIOps |
| Seguridad y privacidad datos nómina (PII) | Cybersecurity |

---

## Estado Actual — DATO-REQUERIDO

| Campo | Estado |
|-------|--------|
| Circular Banxico CAN | `[DATO-REQUERIDO]` — cargar en `source/docs/regulacion/` |
| Fecha límite cumplimiento Santander | `[DATO-REQUERIDO]` — extraer de la circular |
| Productos Santander en scope exacto | `[DATO-REQUERIDO]` — confirmar con Industry Banking SME |
| Sistema técnico de nómina (loans · core) | `[DATO-REQUERIDO]` — confirmar en discovery técnico |
| Capacidades actuales en loans / core | `[DATO-REQUERIDO]` — activar dt-impacto-sistemas |

---

*Última actualización: 2026-09-17 · v0.1.0 · Scaffold inicial — framework regulatorio reutilizado de BanCoppel (23 obligaciones). Análisis de impacto en sistemas Santander pendiente discovery técnico.*

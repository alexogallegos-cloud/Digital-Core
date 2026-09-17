# CAN — Créditos Asociados a Nómina · Project Agent
# project_type: regulatory-compliance
# project_state: active
# platform: Banxico — Normativa CAN
# horizon_present: bdiadminnomina (Informix) — módulo de nómina en producción
# horizon_future: implementación de cumplimiento CAN — ajustes en Informix + canales + reporting
# replaces_or_complements: complementa systems/core/Informix (bdiadminnomina) y systems/channels/

> **Tipo:** Proyecto de cumplimiento regulatorio — Créditos Asociados a Nómina
> **Estado:** `[STATE: ACTIVE]` — investigación de normativa en curso
> **Regulador:** Banco de México (Banxico)
> **Última actualización:** 2026-09-16

---

## ¿Qué es el Proyecto CAN?

CAN (Créditos Asociados a Nómina) es un proyecto de cumplimiento regulatorio que responde a la normativa de Banco de México sobre créditos cuyo pago se domicilia o deduce directamente de la cuenta de nómina del acreditado.

El proyecto tiene dos fases:

| Fase | Descripción | Estado |
|------|-------------|--------|
| **DISCOVER** | Análisis de la normativa Banxico CAN + mapeo de impacto en sistemas BanCoppel | En curso |
| **CHANGE** | Implementación de ajustes técnicos y de proceso para cumplimiento | Pendiente |

---

## Contexto Regulatorio

| Campo | Valor |
|-------|-------|
| Regulador | Banco de México (Banxico) |
| Marco | Normativa sobre Créditos Asociados a Nómina (CAN) |
| Instrumentos | Por confirmar — cargar documentos en `source/docs/regulacion/` |
| Plazo de cumplimiento | `[DATO-REQUERIDO]` — extraer de la circular |
| Sanción por incumplimiento | `[DATO-REQUERIDO]` — extraer de la circular |

> **Acción inmediata requerida:** cargar los documentos de la circular Banxico CAN en `source/docs/regulacion/` para activar los Digital Twins de análisis.

---

## Sistemas BanCoppel en Scope

Basado en la taxonomía TOGAF del programa:

| Sistema | Tipo | Relación con CAN |
|---------|------|-----------------|
| `systems/core/Informix` — `bdiadminnomina` | `core · SoR` | Base de datos de nómina en producción — módulo principal en scope |
| `systems/core/Informix` — `bdispei` | `core · SoR` | Si CAN requiere liquidación vía SPEI |
| `systems/channels/*` | `channels · SoD` | Canales donde el cliente contrata o consulta crédito de nómina |
| `systems/integration/ControlM` | `integration` | Jobs batch de nómina en CTM — posibles ajustes de scheduling |
| `systems/compliance/PLD` | `compliance · SoR` | Reportería regulatoria — si CAN genera obligaciones de reporte |

---

## Digital Twins · `dt/`

Seis DTs para la fase DISCOVER del proyecto CAN:

| DT | Propósito | SMEs heredados | Versión |
|----|-----------|----------------|---------|
| `dt-normativa-can/` | Extrae y estructura la normativa Banxico CAN: obligaciones, plazos, sanciones, definiciones clave, alcance de productos | Regulatory/Banxico · Industry Banking · Industry Banking Accounting | 0.1.0 |
| `dt-impacto-sistemas/` | Mapea qué capacidades del sistema están en scope de CAN: cruza obligaciones contra bdiadminnomina, canales y reporting; identifica SPs relevantes en brain.db | Specialist — Informix SPL · DBA IBM Informix · Industry Banking · Industry Payments → SPEI | 0.1.0 |
| `dt-brecha-compliance/` | Gap analysis formal: obligaciones regulatorias CAN vs. capacidades actuales de BanCoppel; genera la lista de brechas con criticidad y fecha | Regulatory/Banxico · Industry Banking Accounting · Cybersecurity · SRE & AIOps | 0.1.0 |
| `dt-roadmap-cambios/` | Traduce las brechas a requerimientos técnicos, User Stories y un roadmap de implementación; estima esfuerzo e impacto por sistema | Core Banking Transformation · Software Engineering · IT Operating Model · Framework — Integration Architecture | 0.1.0 |
| `dt-de-can/` | Lee y estructura el DE CAN v4.2: especificaciones técnicas del Mecanismo Art. 63 Bis 3, catálogo de campos, flujos de mensajes interbancarios | Framework — Integration Architecture · Industry Payments → SPEI · Regulatory/Banxico | 0.1.0 |
| `dt-nomina-interbancaria/` | Extrae Art. 81 Bis 1 y 81 Bis 2: Servicio de Nómina Interbancaria — portabilidad de nómina, obligaciones adicionales de Institución Ordenante/Receptora | Regulatory/Banxico · Industry Banking · Industry Payments → SPEI | 0.1.0 |

---

## Estructura del Knowledge Base

```
knowledge-base/
├── regulacion/
│   ├── circular-banxico-can.md        ← resumen estructurado de la normativa
│   ├── obligaciones-can.md            ← catálogo de obligaciones artículo por artículo
│   └── glosario-can.md                ← definiciones legales clave
├── rules/
│   ├── reglas-derivadas-can.md        ← reglas de negocio derivadas de la normativa
│   └── mapping-obligaciones-reglas.md ← trazabilidad obligación → regla → SP
└── vocab/
    └── vocab-can.json                 ← términos nuevos de la normativa CAN
```

---

## Pipeline de Análisis (Fase DISCOVER)

```
[Documentos Banxico CAN]
    ↓
dt-normativa-can → knowledge-base/regulacion/ (obligaciones + glosario)
    │
    ├──→ dt-de-can → spec técnica Mecanismo Art. 63 Bis 3 + catálogo de campos
    │
    └──→ dt-nomina-interbancaria → obligaciones Art. 81 Bis 1 y 81 Bis 2
    ↓
dt-impacto-sistemas → cruza contra brain.db de Informix (bdiadminnomina)
    ↓
dt-brecha-compliance → gap analysis (qué cumple / qué falta)
    ↓
dt-roadmap-cambios → User Stories + estimación de cambios técnicos
    ↓
portal/index.html → dashboard de cumplimiento CAN
```

---

## Relación con el Ecosistema BanCoppel

| Proyecto / Sistema | Relación |
|-------------------|----------|
| `systems/core/Informix` | Fuente de verdad técnica — bdiadminnomina en scope directo |
| `projects/unity` | Si CAN requiere capabilities nuevas en Transact/Apolo — escalado a Unity |
| `bank-brain/` | Hallazgos CAN se propagan al federador (Regla B10: knowledge interlock) |

**Regla ontológica:** todo hallazgo cross-sistema descubierto durante el análisis CAN se propaga al brain del sistema receptor (Regla B10). Los brechas regulatorias se documentan en `knowledge-base/regulacion/` y se vinculan al `regulatory_obligations` del brain de Informix.

---

## Handoffs Canónicos

| Trigger | SME destino |
|---------|-------------|
| Interpretación de artículo Banxico CAN | Regulatory/Banxico |
| Impacto contable (CUB/Serie R) de créditos nómina | Industry Banking Accounting |
| Análisis de bdiadminnomina SPL | Specialist — Informix SPL → BCOPBrain |
| User Stories de cambios técnicos | Software Engineering SME |
| Ajuste de jobs CTM para nómina | DBA IBM Informix + IT Operating Model |
| OBL-006 (SPEI refinanciamiento) + OBL-009 (Clave Básica Estandarizada) | Industry Payments → SPEI |
| Diseño del Mecanismo Art. 63 Bis 3 (hub interbancario) | Framework — Integration Architecture |
| OBL-023 timing ventana 17:00 DHB + monitoreo prelación OBL-016 | SRE & AIOps |
| Brechas de seguridad y privacidad (PII datos de nómina) | Cybersecurity |

---

## Estado Actual — DATO-REQUERIDO

| Campo | Estado |
|-------|--------|
| Circular Banxico CAN | `[DATO-REQUERIDO]` — cargar en `source/docs/regulacion/` |
| Fecha límite de cumplimiento | `[DATO-REQUERIDO]` — extraer de la circular |
| Productos BanCoppel en scope | `[DATO-REQUERIDO]` — confirmar con Industry Banking SME |
| SPs bdiadminnomina en scope | `[DATO-REQUERIDO]` — activar dt-impacto-sistemas |
| Brechas identificadas | `[DATO-REQUERIDO]` — activar dt-brecha-compliance |

---

*Última actualización: 2026-09-17 · v0.2.0 · 6 DTs definidos (4 originales + dt-de-can + dt-nomina-interbancaria); 3 SMEs adicionales declarados (Industry Payments → SPEI, Framework — Integration Architecture, SRE & AIOps); dt-normativa-can COMPLETO — 23 obligaciones cargadas en brain.db.*

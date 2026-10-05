# DT — Solución Arquitectura CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** DESIGN / BUILD
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Define la arquitectura de la solución técnica para el cumplimiento CAN en Santander México.
Establece el patrón de integración con el Mecanismo Art. 63 Bis 3 (hub Banxico), los sistemas
involucrados, los ADRs clave y el diseño de alto nivel que alimenta los DTs especializados
de integración, datos, canales, prelación y testing.

> Este DT es el **maestro de arquitectura** del proyecto CAN Santander. Todo cambio técnico
> relevante debe anclar aquí su decisión de diseño.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Framework — Integration Architecture | Patrón de integración Santander → Mecanismo CAN (hub Banxico) |
| Core Banking Transformation | Cambios en `loans` y `core-banking` — alcance y viabilidad |
| Software Engineering | Diseño de componentes, microservicios, APIs |
| Industry Payments → SPEI | OBL-006 (SPEI refinanciamiento) + OBL-009 (Clave Básica Estandarizada) |
| Regulatory/Banxico | Validación de arquitectura contra requisitos Art. 63 Bis 3 + DE CAN v4.2 |

---

## Vista de Arquitectura

### Sistemas Santander Involucrados

| Sistema | Rol CAN | Tipo de cambio |
|---------|---------|---------------|
| `loans` | Origina el crédito CAN · Asigna Clave Básica Estandarizada | Modificar: flag CAN + Clave Básica + prelación en DB |
| `core-banking` | Lleva la Cuenta Ordenante · Ejecuta cargos en prelación | Modificar: motor de prelación + identifica Cuentas Ordenantes |
| `payments-engine` | SPEI para refinanciamiento (OBL-006) · Conectividad al Hub CAN | Modificar: adaptador al Mecanismo Art. 63 Bis 3 |
| `banxico-spei` | Infraestructura SPEI ya conectada | Sin cambio — reutilizar rail existente |
| `supermovil` | Disclosure OBL-014 + mandato digital OBL-005 + comparativo OBL-007 | Añadir: nuevas pantallas CAN |
| `santander-online` | Mismo disclosure que SuperMóvil — canal web | Añadir: mismas pantallas CAN en web |
| `cnbv-reporting` | Reporte buró crédito (OBL-008) + notificación Banxico (OBL-003) | Añadir: nuevos eventos regulatorios CAN |
| `api-gateway` | Expone endpoints CAN internos | Configurar: nuevas rutas + autenticación |

### Diagrama Conceptual

```
SANTANDER — CAPA CAN

  [SuperMóvil / Santander Online]
        │ mandato digital (OBL-005, OBL-018)
        │ disclosure CAN vs no-CAN (OBL-007, OBL-014)
        ▼
  [api-gateway]
        │
        ├─────────────────────────────────────┐
        ▼                                     ▼
  [loans]                              [core-banking]
  · Clave Básica Estandarizada         · Identificar Cuenta Ordenante (OBL-013)
  · Flag CAN                           · Motor prelación (OBL-016)
  · Límite Comité Riesgos (OBL-002)    · SLA 17:00 DHB (OBL-023)
        │                                     │
        └──────────────┬──────────────────────┘
                       ▼
               [payments-engine]
               · Adaptador Mecanismo CAN
               · SPEI refinanciamiento (OBL-006)
               · Timing + retry DHB
                       │
                       ▼
            [MECANISMO ART. 63 BIS 3]
               Hub centralizado Banxico
               (infraestructura externa)
                       │
          ─────────────┼─────────────
          ▼                         ▼
  [Otras IBMs]              [Banxico (notificaciones)]
  Instituciones Depositarias  OBL-003: límite Comité Riesgos
  / Acreedoras                OBL-012: notificación mecanismo

  [cnbv-reporting]
  · Buró crédito (OBL-008)
  · Reportes regulatorios CAN
```

---

## Decisiones de Arquitectura (ADRs)

### ADR-SANT-CAN-001 — Patrón de integración al Mecanismo Art. 63 Bis 3

| Campo | Opción A | Opción B | Decisión |
|-------|----------|----------|---------|
| Patrón | Adaptador dedicado en `payments-engine` | Microservicio CAN independiente | `[DATO-REQUERIDO]` — evaluar según stack de `payments-engine` |
| Protocolo | REST (si hub Banxico expone REST per DE CAN v4.2) | Async messaging (MQ/Service Bus) | `[DATO-REQUERIDO]` — confirmar DE CAN v4.2 protocolo |
| Justificación A | Reutiliza infraestructura SPEI existente · Menor footprint | — | — |
| Justificación B | Aislamiento de cambios · Deploy independiente · Escala propia | — | — |

> Confirmar con `dt-de-can` el protocolo de comunicación del hub Banxico antes de decidir.

### ADR-SANT-CAN-002 — Ubicación del Motor de Prelación (OBL-016)

| Opción | Dónde | Pros | Contras |
|--------|-------|------|---------|
| A | Dentro de `core-banking` | Co-localizado con Cuenta Ordenante y saldos | Acopla carga regulatoria al core; `[DATO-REQUERIDO]` stack |
| B | Módulo separado en `payments-engine` | Separation of concerns · Testeable independiente | Requiere sincronización de saldos entre sistemas |
| C | Nuevo microservicio `can-engine` | Máximo aislamiento · Stack moderno | Mayor overhead de delivery; requiere más discovery |

> Recomendación inicial: Opción A si `core-banking` tiene modelo de extensión. Opción C si el core es un sistema legado sin capacidad de extensión limpia.

### ADR-SANT-CAN-003 — Generación de Clave Básica Estandarizada (OBL-009)

| Campo | Valor |
|-------|-------|
| Qué es | Identificador único asignado por la institución acreedora a cada CAN (Reglas SPEI Circular 14/2017) |
| Dónde se genera | En `loans` — al momento de originar el CAN |
| Formato | `[DATO-REQUERIDO]` — revisar spec Circular 14/2017 + DE CAN v4.2 |
| Dónde se almacena | Campo nuevo en tabla de créditos de `loans` |
| Uso | Liquidaciones SPEI en refinanciamiento (OBL-006) + identificación en el hub CAN |

### ADR-SANT-CAN-004 — Persistencia del Mandato Digital (OBL-005 / OBL-018)

| Campo | Valor |
|-------|-------|
| Captura | SuperMóvil / Santander Online — firma electrónica o biométrica |
| Almacenamiento | `core-banking` o CRM — requiere trazabilidad regulatoria (timestamp, canal, versión de texto) |
| Evidencia para auditoría Banxico | PDF generado + hash almacenado |
| `[DATO-REQUERIDO]` | Confirmar si Santander ya tiene infraestructura de firma electrónica regulatoria o requiere nueva |

---

## Riesgos de Arquitectura

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|----|--------|-------------|---------|-----------|
| RIESGO-SANT-CAN-001 | Stack `core-banking` y `loans` desconocido — puede ser legado sin APIs REST | Alta | Crítico | Discovery técnico urgente antes de diseño detallado |
| RIESGO-SANT-CAN-002 | DE CAN v4.2 puede requerir certificación con Banxico antes de go-live | Media | Alto | Iniciar proceso de certificación en cuanto se tenga ambiente de testing |
| RIESGO-SANT-CAN-003 | Lógica de prelación OBL-016 puede requerir cambios profundos en batch de nómina | Alta | Crítico | Confirmar cómo procesa hoy Santander los cargos de nómina |
| RIESGO-SANT-CAN-004 | Coordinación cross-sistema (loans + core-banking + payments-engine) introduce latencia | Media | Medio | Diseñar con eventos asíncronos donde no se requiera respuesta síncrona |

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Reference Architecture CAN Santander | `knowledge-base/rules/reference-architecture-can.md` |
| ADR-SANT-CAN-001 a 004 (expandidos) | `knowledge-base/rules/adrs/` |
| Diagrama de arquitectura (Visio / draw.io) | `source/docs/arquitectura/` |
| Lista de epics técnicos | → alimenta `dt-roadmap-cambios` |

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — 23 obligaciones como input
- `[DEPENDS-ON: dt-brecha-compliance]` — brechas priorizadas
- `[DEPENDS-ON: dt-de-can]` — protocolo del Mecanismo Art. 63 Bis 3
- `[DATO-REQUERIDO]` — Discovery técnico de `loans` y `core-banking` (stack, APIs, modelo de extensión)
- `[DATO-REQUERIDO]` — Confirmar capacidad de firma electrónica regulatoria existente en Santander

*v0.1.0 · 2026-09-17 · fase DESIGN*

# DT — Roadmap de Cambios CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Versión:** 0.2.0 · `[STATE: EXECUTED]`

## Propósito

Traduce las brechas de compliance CAN en requerimientos técnicos, User Stories y un
roadmap de implementación. Estima esfuerzo e impacto por sistema y **decide dónde vive
cada cambio**: sistemas core de Santander, plataforma OneFinancial, o el CECOBAN Gateway.

## Contexto OneFinancial (crítico)

**OneFinancial es la plataforma SaaS de Accenture para originación de crédito de nómina** —
no es un sistema de Santander. Los 7 microservicios Spring Boot analizados son componentes
de OneFinancial. Santander la adopta como vehículo de delivery del flujo de originación CAN
(rol ACREEDORA). Por lo tanto, cada User Story debe declarar explícitamente **dónde vive el
cambio**, porque no todo el CAN se construye en el mismo lugar.

## Arquitectura del orquestador — 3 capas (ADR-SANT-CAN-001)

| Capa | Componente | Dónde vive | Responsabilidad |
|------|-----------|------------|-----------------|
| 1. Integración | **CECOBAN Gateway** | Componente dedicado bajo identidad + operación regulatoria de Santander (institución 40072), construido sobre stack OneFinancial | Puerta única al hub: REST + Kafka, C50-C58, JWT, idempotencia, catálogo de errores CAN |
| 2a. Orquestación ACREEDORA | OneFinancial | SaaS Accenture | Ciclo de originación (SmartFolio), prehabilitación, comparativo, mandato |
| 2b. Orquestación DEPOSITARIA | core-banking / payments-engine | Santander | Prelación, transferencia 17:00 DHB, comunicación de saldos, objeciones |
| 3. Servicios de dominio | loans · core-banking · payments-engine · banxico-spei · cnbv-reporting · canales | Santander | Lógica de negocio y datos que ya existen |

**Por qué el Gateway no vive dentro de OneFinancial:** los flujos DEPOSITARIA (11 obligaciones)
no tienen relación con la originación y tocan saldos del core con SLAs regulatorios (1 DHB,
diario, corte 17:00). Además, la conexión al hub usa la identidad regulatoria de Santander;
ponerla dentro del SaaS haría que Accenture retuviera credenciales regulatorias del banco y
ataría la conectividad CECOBAN a la permanencia de OneFinancial.

## SMEs

| SME | Rol |
|-----|-----|
| Framework — Integration Architecture | Diseño del CECOBAN Gateway (Art. 63 Bis 3) — capa 1 |
| Core Banking Transformation | Cambios en `loans` y `core-banking` — prelación, cuentas ordenantes, transferencias |
| Software Engineering | Implementación técnica en OneFinancial y en el Gateway — estimación y diseño |
| IT Operating Model | Scheduler 17:00 DHB, batch, SLAs operativos |
| Industry Banking | Validación de las reglas de negocio bancarias de cada obligación CAN |
| Quality Engineering | Criterios de aceptación + casos de prueba por User Story (shift-left desde DISCOVER) |
| Regulatory/Banxico | Interpretación de cada obligación y validación regulatoria de la solución |

## Resultado de la ejecución — 20 User Stories

El DT se ejecutó contra las 23 obligaciones. 20 requieren desarrollo (User Story); 3 están
CUBIERTAS por capacidades existentes de Santander (OBL-002 límite de riesgo, OBL-004 identidad,
OBL-011 prepago) y no generan User Story.

### ACREEDORA (Santander otorga el CAN)

| US | Capacidad | Dónde vive | Esfuerzo | Obligación |
|----|-----------|-----------|----------|------------|
| US-001 | Generación Clave Básica Estandarizada | loans (Santander) | L | OBL-009 |
| US-002 | CECOBAN Gateway — Mecanismo Art. 63 Bis 3 | **CECOBAN Gateway** | XL | OBL-012 |
| US-008 | Prehabilitación interbancaria | OneFinancial | L | OBL-001 |
| US-009 | Liquidación SPEI de refinanciamiento con Clave Básica | payments-engine (Santander) | M | OBL-006 |
| US-010 | Comparativo CAN vs. no-CAN | OneFinancial | M | OBL-007 |
| US-011 | Mandato con autorización expresa CAN | OneFinancial | S | OBL-005 |
| US-012 | Notificación límite Comité de Riesgos a Banxico | cnbv-reporting (Santander) | M | OBL-003 |
| US-013 | Reporte carácter CAN a buró | cnbv-reporting (Santander) | S | OBL-008 |
| US-014 | Domiciliación interbancaria vía Art. 64 | **CECOBAN Gateway** | L | OBL-010 |

### DEPOSITARIA (Santander recibe la nómina)

| US | Capacidad | Dónde vive | Esfuerzo | Obligación |
|----|-----------|-----------|----------|------------|
| US-003 | Motor de prelación de cargos CAN | core-banking (Santander) | L | OBL-016 |
| US-004 | Monitor SLA 17:00 DHB | core-banking (Santander) | S | OBL-023 |
| US-005 | Nómina Interbancaria — Ordenante | core-banking (Santander) | L | OBL-019 |
| US-006 | Nómina Interbancaria — Receptora | core-banking (Santander) | L | OBL-017 |
| US-007 | Disclosure digital derecho a designar CAN | supermovil (Santander) | S | OBL-014 |
| US-015 | Identificación de Cuentas Ordenantes | core-banking (Santander) | M | OBL-013 |
| US-016 | Comunicación info Cuenta Ordenante en 1 DHB | core-banking (Santander) | L | OBL-015 |
| US-017 | Mandato de consulta CANs (depositaria) | supermovil (Santander) | S | OBL-018 |
| US-018 | Cancelación de Domiciliación CAN en 1 DHB | core-banking (Santander) | M | OBL-020 |
| US-019 | Resolución de objeción de cargos CAN en 5 DHB | core-banking (Santander) | M | OBL-021 |
| US-020 | Remisión de objeción a acreedora en 2 DHB | **CECOBAN Gateway** | S | OBL-022 |

### Distribución del esfuerzo por destino

| Destino | User Stories | Nota |
|---------|-------------|------|
| CECOBAN Gateway (nuevo) | 3 (US-002, US-014, US-020) | US-002 es XL — la pieza central |
| OneFinancial | 3 (US-008, US-010, US-011) | Extensión del flujo de originación existente |
| core-banking (Santander) | 9 | La mayor carga — todos los flujos DEPOSITARIA |
| payments-engine (Santander) | 1 (US-009) | Extensión de instrucción SPEI |
| cnbv-reporting (Santander) | 2 (US-012, US-013) | Reportes regulatorios nuevos |
| supermovil / canales (Santander) | 2 (US-007, US-017) | Disclosure y mandato digital |

## Estructura de User Story CAN

```markdown
## US-SANT-CAN-{NNN}

**Título:** {nombre de la capacidad a implementar}
**Obligación CAN:** {OBL-XXX}
**Dónde vive:** {CECOBAN Gateway / OneFinancial / loans / core-banking / ...}
**Como** {actor bancario},
**Quiero** {capacidad regulatoria requerida},
**Para** {cumplir OBL-XXX de la normativa CAN Banxico}

**Criterios de aceptación:**
- [ ] {criterio técnico verificable}
- [ ] Validado contra normativa: OBL-XXX ✓
- [ ] Casos de prueba identificados (QE shift-left)

**Estimación:** {S / M / L / XL}
**Brecha origen:** BRECHA-SANT-CAN-{NNN}
```

## Outputs

| Artefacto | Ruta |
|-----------|------|
| User Stories (fuente de verdad) | `digital-brain/brain.db` → tabla `user_stories` |
| Brechas priorizadas | `digital-brain/brain.db` → tabla `brechas` |
| Decisión de arquitectura del orquestador | `digital-brain/brain.db` → ADR-SANT-CAN-001 |
| Portal (generado) | `portal/index.html` — popup por capacidad ETB |

## Dependencias

- `[DEPENDS-ON: dt-brecha-compliance]` — brechas priorizadas
- `[DEPENDS-ON: dt-de-can]` — spec técnica del Mecanismo (define el Gateway)
- `[DATO-REQUERIDO]` — discovery técnico de `loans`, `core-banking`, `payments-engine` (stack real)
- `[DATO-REQUERIDO]` — confirmar contrato de integración OneFinancial ↔ CECOBAN Gateway

*v0.2.0 · 2026-09-18 · Ejecutado con contexto OneFinancial: 20 User Stories, arquitectura de orquestador en 3 capas (ADR-SANT-CAN-001). v0.1.0 (2026-09-17): scaffold con 7 hipótesis.*

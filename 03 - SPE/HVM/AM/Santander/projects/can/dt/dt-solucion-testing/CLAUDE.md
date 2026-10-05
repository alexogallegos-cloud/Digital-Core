# DT — Solución Testing CAN · Santander México
> **Proyecto:** CAN · Santander México
> **Fase:** BUILD / TEST
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Define la estrategia de testing para validar el cumplimiento CAN de Santander.
Cubre los 23 casos regulatorios, integración con el simulador del Mecanismo CAN
provisto por Banxico, y la certificación de go-live. Aplica el principio de
shift-left: los casos de prueba se definen en DESIGN antes de iniciar BUILD.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Quality Engineering | Estrategia de testing · automatización · reporte |
| Software Engineering | Tests unitarios · tests de integración |
| Regulatory/Banxico | Validación regulatoria · proceso de certificación Banxico |
| IT Operating Model | Tests de performance · SLA operativo · batch testing |

---

## Pirámide de Testing CAN

```
                    ┌───────────────────┐
                    │   CERTIFICACIÓN   │  (con Banxico — E2E real)
                    │      BANXICO      │
                    └───────────────────┘
                  ┌─────────────────────────┐
                  │  COMPLIANCE TESTING      │  (23 obligaciones verificadas)
                  │  (tests regulatorios E2E)│
                  └─────────────────────────┘
              ┌─────────────────────────────────┐
              │    INTEGRATION TESTING           │  (adaptador Hub CAN + SPEI)
              │    (con simulador Banxico)        │
              └─────────────────────────────────┘
          ┌─────────────────────────────────────────┐
          │           UNIT TESTING                   │  (motor prelación · Clave Básica · SLAs)
          │      (algoritmos y reglas de negocio)    │
          └─────────────────────────────────────────┘
```

---

## Matriz de Cumplimiento — 23 Obligaciones

| OBL | Descripción breve | Tipo de test | Automatizable | Prioridad |
|-----|------------------|-------------|--------------|----------|
| OBL-001 | Solicitar info Cuenta Ordenante | Integration (Hub CAN) | Sí | CRÍTICA |
| OBL-002 | Límite amortizaciones Comité de Riesgos | Unit · Rule test | Sí | CRÍTICA |
| OBL-003 | Notificar límite a Banxico en 10 DHB | Integration · SLA | Sí | ALTA |
| OBL-004 | Verificar identidad antes de solicitar info | Unit · Document | Parcial | MEDIA |
| OBL-005 | Obtener mandato del acreditado | E2E canal · Document | Sí | CRÍTICA |
| OBL-006 | SPEI refinanciamiento con Clave Básica | Integration (SPEI) | Sí | ALTA |
| OBL-007 | Comparativo CAN vs. no-CAN | E2E canal · Visual | Sí | ALTA |
| OBL-008 | Reportar a buró carácter CAN | Integration (buró) | Sí | MEDIA |
| OBL-009 | Asignar Clave Básica Estandarizada | Unit · DB | Sí | CRÍTICA |
| OBL-010 | Gestionar Domiciliación | Integration (Hub CAN) | Sí | CRÍTICA |
| OBL-011 | Ajustar pagos por prepago | Unit · Rule test | Sí | ALTA |
| OBL-012 | Usar mecanismo transparente + notificar Banxico | Compliance audit | Parcial | ALTA |
| OBL-013 | Identificar Cuentas Ordenantes | Unit · DB · Rule | Sí | CRÍTICA |
| OBL-014 | Ofrecer derecho a designar CANs | E2E canal | Sí | CRÍTICA |
| OBL-015 | Responder info Cuenta Ordenante en 1 DHB | Integration (Hub CAN) · SLA | Sí | CRÍTICA |
| OBL-016 | Prelación de cargos | Unit (algoritmo) · Integration | Sí | CRÍTICA |
| OBL-017 | Cargos CANs previos en nueva Cuenta Ordenante | Integration (Hub CAN) | Sí | ALTA |
| OBL-018 | Mandato para consultar CANs | E2E canal · Document | Sí | CRÍTICA |
| OBL-019 | Comunicar nueva Cuenta Ordenante a acreedoras | Integration (Hub CAN) | Sí | ALTA |
| OBL-020 | Notificar cancelación Domiciliación en 1 DHB | Integration (Hub CAN) · SLA | Sí | CRÍTICA |
| OBL-021 | Resolver objeción CAN en 5 DHB | Integration · SLA | Sí | ALTA |
| OBL-022 | Remitir objeción a acreedora en 2 DHB | Integration (Hub CAN) · SLA | Sí | ALTA |
| OBL-023 | Transferir prestaciones laborales — timing 17:00 | Integration (SPEI) · SLA | Sí | CRÍTICA |

---

## Test Suites

### Suite A — Unit Tests (Motor de Prelación)

| Test ID | Caso | Input | Expected Output |
|---------|------|-------|----------------|
| UT-PREL-001 | Fondos suficientes para todo | Abono $10K · Nivel1 $2K · CAN1 $3K · CAN2 $2K · Dom $500 | Todos cargos ejecutados · remanente $2.5K |
| UT-PREL-002 | Fondos insuficientes para CAN2 | Abono $5K · Nivel1 $2K · CAN1 $3K · CAN2 $2K | CAN1 completo · CAN2 CARGO_PARCIAL $2K pendiente |
| UT-PREL-003 | Cero fondos | Abono $0 | Sin cargos · todos pendientes |
| UT-PREL-004 | CAN parcial previo + nuevo abono | CAN2 pendiente $1.5K + abono $3K | CAN2 $1.5K cobrado primero · resto disponible |
| UT-PREL-005 | Prelación cronológica correcta | CAN-A designado 10-mar · CAN-B 15-mar | CAN-A se cobra primero |

### Suite B — Unit Tests (Clave Básica Estandarizada)

| Test ID | Caso | Expected |
|---------|------|---------|
| UT-CBE-001 | Generar Clave Básica para nuevo CAN | Formato correcto per Circular 14/2017 |
| UT-CBE-002 | Clave Básica es inmutable una vez asignada | No se puede modificar (excepción si se intenta) |
| UT-CBE-003 | Clave Básica única por crédito | Unicidad verificada en DB |

### Suite C — SLA Tests

| Test ID | Obligación | Escenario | SLA a verificar |
|---------|-----------|-----------|----------------|
| SLA-001 | OBL-015 | Responder info Cuenta Ordenante | ≤ 1 DHB desde solicitud |
| SLA-002 | OBL-020 | Notificar cancelación Domiciliación | ≤ 1 DHB desde solicitud cliente |
| SLA-003 | OBL-022 | Remitir objeción a acreedora | ≤ 2 DHB desde recepción objeción |
| SLA-004 | OBL-021 | Resolver objeción CAN | ≤ 5 DHB desde notificación |
| SLA-005 | OBL-023 | Transferir prestaciones si abono antes 17:00 | Mismo DHB |
| SLA-006 | OBL-023 | Transferir prestaciones si abono después 17:00 | DHB siguiente |
| SLA-007 | OBL-003 | Notificar límite a Banxico | ≤ 10 DHB desde aprobación Comité |

### Suite D — Integration Tests con Simulador Banxico

> Banxico provee un simulador del Mecanismo Art. 63 Bis 3.
> Ver: `source/docs/regulacion/Guia Conexion Validacion Acceso Simulador CAN v1.2.pdf`

| Test ID | Flujo | Sistemas involucrados |
|---------|-------|----------------------|
| INT-001 | Solicitud info Cuenta Ordenante end-to-end | payments-engine → Simulador → payments-engine |
| INT-002 | Registrar domiciliación CAN | loans → payments-engine → Simulador |
| INT-003 | Cancelar domiciliación CAN | core-banking → payments-engine → Simulador |
| INT-004 | SPEI refinanciamiento con Clave Básica | loans → payments-engine → banxico-spei |
| INT-005 | Nueva Cuenta Ordenante → notificar acreedoras | core-banking → payments-engine → Simulador |
| INT-006 | Ciclo completo de nómina con prelación | core-banking motor prelación → SPEI → remanente transferido |

### Suite E — E2E Canales

| Test ID | Canal | Flujo | OBL |
|---------|-------|-------|-----|
| E2E-001 | SuperMóvil | Solicitud crédito CAN + comparativo + mandato | OBL-005, OBL-007 |
| E2E-002 | SuperMóvil | Visualización prelación en cuenta | OBL-016 |
| E2E-003 | Santander Online | Mismo flujo E2E-001 en web | OBL-005, OBL-007 |
| E2E-004 | SuperMóvil | Cancelar designación CAN | OBL-020 |

---

## Entorno de Testing

### Simulador Banxico

```
Referencia: source/docs/regulacion/Guia Conexion Validacion Acceso Simulador CAN v1.2.pdf
Acceso:     [DATO-REQUERIDO] — solicitar credenciales a Banxico
Uso:        Suite D (Integration Tests) + certificación Banxico
Ambientes:  Sandbox Banxico → QA Santander → Certificación Banxico → Producción
```

### Ambientes

| Ambiente | Propósito | Datos |
|----------|-----------|-------|
| `DEV` | Unit tests + desarrollo | Mock Hub CAN · datos sintéticos |
| `QA` | Integration tests + E2E | Simulador Banxico · datos anonimizados |
| `CERT` | Certificación Banxico | Simulador Banxico oficial · escenarios Banxico |
| `PROD` | Go-live | Hub Banxico real |

---

## Criterios de Go-Live (Definition of Done CAN)

- [ ] 23 obligaciones con al menos 1 test automatizado cada una
- [ ] Suite D completa aprobada con simulador Banxico
- [ ] Cero defectos críticos o altos abiertos
- [ ] Certificación Banxico obtenida (proceso formal)
- [ ] SLA monitor OBL-023 en producción con alertas activas
- [ ] Motor de prelación auditado por Legal/Compliance Santander
- [ ] Textos de mandato validados por Legal Santander
- [ ] Runbook operativo para incidentes CAN documentado

---

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Test plan completo CAN | `knowledge-base/rules/test-plan-can.md` |
| Casos de prueba automatizados | `source/tests/` |
| Matriz de trazabilidad OBL → Test | `knowledge-base/rules/trazabilidad-obl-test.md` |
| Reporte de certificación Banxico | `source/docs/certificacion/` |

## Dependencias

- `[DEPENDS-ON: dt-solucion-prelacion]` — casos PREL-001 a PREL-008
- `[DEPENDS-ON: dt-solucion-integracion]` — flujos de integración a probar
- `[DEPENDS-ON: dt-solucion-canales]` — flujos E2E de canales
- `[DATO-REQUERIDO]` — Acceso al simulador Banxico (credenciales + documentación)
- `[DATO-REQUERIDO]` — Proceso y plazos de certificación Banxico para nuevas IBMs en el hub

*v0.1.0 · 2026-09-17 · fase BUILD/TEST · shift-left*

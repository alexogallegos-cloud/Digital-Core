# Ontología de Negocio — MONEX Grupo Financiero
> Motor de gobierno semántico OWL 2 DL para la arquitectura de integración Plan Apolo

---

## Principio

La ontología captura el **vocabulario formal** de la arquitectura de integración MONEX:
qué conceptos existen, cómo se relacionan entre sí, y qué axiomas los gobiernan.
Un sistema que conoce la ontología puede responder "¿qué queda en incumplimiento si cambias X?"
sin esperar semanas de análisis manual.

---

## Dominio: Pagos

| Concepto | Tipo | Descripción | Axioma clave |
|----------|------|-------------|--------------|
| `PaymentInstruction` | Class | Instrucción formal de transferencia de fondos | hasCurrency, hasAmount, hasDebtor, hasCreditor |
| `PaymentFlow` | Class | Ciclo completo instrucción→liquidación | hasPart (Instruction, Routing, Settlement, Confirmation) |
| `SPEIMessage` | Class | Mensaje SPEI doméstico MXN | subClassOf PaymentInstruction; conformsTo BanxicoSPEI |
| `ISO20022Message` | Class | Mensaje ISO 20022 internacional | subClassOf PaymentInstruction; conformsTo ISO20022 |
| `SWIFTMessage` | Class | Mensaje SWIFT legacy MT | subClassOf PaymentInstruction; conformsTo SWIFTNet |
| `CLSSettlement` | Class | Liquidación PvP en CLS | subClassOf Settlement; requires CLSMembership |

## Dominio: FX

| Concepto | Tipo | Descripción | Axioma clave |
|----------|------|-------------|--------------|
| `FXTransaction` | Class | Operación de compraventa de divisas | hasType (Spot, Forward, NDF, Option) |
| `FXRate` | Class | Tipo de cambio con timestamp y fuente | hasSource (Bloomberg, Reuters, Internal) |
| `CLSSettlement` | Class | Settlement PvP FX en CLS | requires CLSMembership; hasWindow CLSCutoff |
| `Counterparty` | Class | Contraparte de una operación | hasJurisdiction, hasAMLStatus |

## Dominio: Datos

| Concepto | Tipo | Descripción | Axioma clave |
|----------|------|-------------|--------------|
| `GoldenRecord` | Class | Registro maestro canónico | isSourceOf (System*); hasConfidenceScore |
| `DataConflict` | Class | Discrepancia entre sistemas para un mismo dato | involves (System, System); severity (Critical, High, Medium) |
| `MasterDataDomain` | Class | Dominio de datos maestros (cliente, instrumento, cuenta) | hasGoldenRecord |

## Dominio: Integración

| Concepto | Tipo | Descripción | Axioma clave |
|----------|------|-------------|--------------|
| `IntegrationAPI` | Class | API del catálogo MONEX | hasGateway MuleSoftAnypoint; hasContract OpenAPISpec |
| `APIContract` | Class | Especificación formal de una API | conformsTo OpenAPI31; hasVersion |
| `DataFlow` | Class | Flujo de datos entre dos sistemas | hasSource (System); hasTarget (System); carries (DataType) |
| `IntegrationPattern` | Class | Patrón de integración aplicado | type (RequestReply, PublishSubscribe, DataPipeline) |

## Dominio: Regulatorio

| Concepto | Tipo | Descripción | Axioma clave |
|----------|------|-------------|--------------|
| `RegulatoryReport` | Class | Reporte a regulador (DIOR, CNBV, FCA) | requiredBy Regulator; hasDeadline; hasSource (System+) |
| `RegulatoryObligation` | Class | Obligación específica de cumplimiento | hasRegulator; hasFrequency; impacts (System+) |
| `AMLCheck` | Class | Verificación anti-lavado de dinero | triggers (Alert, Clear); hasThreshold |

---

## Preguntas que el grafo puede responder

1. **Impacto de cambio de schema**: `¿Qué PaymentFlows se ven afectados si CLSSettlement cambia su protocolo de confirmación?`
2. **Trazabilidad regulatoria**: `¿Qué sistemas alimentan el reporte DIOR de Banxico?`
3. **Gaps de gobierno**: `¿Qué IntegrationAPIs no tienen APIContract declarado?`
4. **Conflictos de datos**: `¿Qué GoldenRecord candidates tienen DataConflict pendiente entre sistemas?`
5. **Readiness CLS**: `¿Qué condiciones faltan para que MONEX obtenga CLSMembership?`

---

*Última actualización: 2026-09-22 · v1.0 · Seed inicial — expandir con sesiones de arquitectura Plan Apolo*

# spec-spe-mm-s151
> Modernización Mainframe · Banamex · Unisys ClearPath MCP · Digital Core
> Offering: 03 — Software & Platform Engineering · Sub-Offering: High Velocity Modernization · Solution: Mainframe Modernization
> Versión: 0.1.0 · Estado: DRAFT · Fase SDLC: DISCOVER · Fecha: 2026-06-30
> Indexado: ✅ 2026-07-17 — Especificación de modernización (spec S&PE MM)

---

## §00 — Header & Component Identity

### 00.1–00.6 Ficha del Componente

| Campo | Valor |
|---|---|
| **Component ID** | `SPE-MM-002` |
| **Nombre** | S151 — Sistema de Movimientos Contables |
| **Tipo** | Mainframe Application (Unisys ClearPath MCP) → Target: Microservicio cloud-native |
| **Offering** | 03 — Software & Platform Engineering |
| **Sub-Offering** | High Velocity Modernization |
| **Solution L4** | Mainframe Modernization |
| **Cliente** | Banamex (Citibanamex) |
| **Plataforma Legacy** | Unisys ClearPath MCP (OS MCP / COBOL + ALGOL) |
| **Fase SDLC Actual** | `DISCOVER` — Etapa 0 (Setup & Inventory) |
| **Owner — Lead Architect** | Por designar (Accenture MX) |
| **Owner — Sponsor Cliente** | Por designar (Banamex Technology / Finance) |
| **Estado** | `DRAFT` |
| **Versión Spec** | 0.1.0 |
| **Fecha creación** | 2026-06-30 |
| **Última actualización** | 2026-06-30 |

### 00.6 Changelog

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1.0 | 2026-06-30 | alejandro.gallegos@accenture.com | Creación inicial — DISCOVER phase kickoff |

### 00.7 Componentes Relacionados

| Componente | Relación | Dirección |
|---|---|---|
| `SPE-MM-001` (S500 — Cargos y Abonos) | S500 genera los movimientos que S151 convierte a asientos contables | Upstream (CRÍTICO) |
| Sistema de Reportes CNBV | S151 es fuente de datos para reportes regulatorios financieros | Downstream |
| Área de Finanzas / Contabilidad Banamex | S151 alimenta los estados financieros internos | Downstream |
| Sistema de Conciliación | S151 es referencia para la conciliación diaria | Downstream |
| Auditoría Interna | Consulta el ledger de S151 para revisiones regulatorias | Downstream (solo lectura) |

### 00.8 Glosario

| Término | Definición |
|---|---|
| Asiento contable | Registro en el libro mayor (ledger) que debita una cuenta y acredita otra de igual monto |
| Plan de cuentas | Catálogo estructurado de cuentas contables del banco, clasificadas por rubro CNBV |
| Partida doble | Principio contable: todo cargo en una cuenta genera un abono equivalente en otra |
| Libro mayor (ledger) | Registro maestro de todos los asientos contables del banco |
| Cierre de jornada | Proceso batch que consolida todos los movimientos del día y produce los estados financieros diarios |
| Balanza de comprobación | Reporte que verifica que la suma de débitos = suma de créditos en todos los asientos del período |
| MCP | Master Control Program — sistema operativo de Unisys ClearPath |
| DMSII | Database Management System II — base de datos nativa de Unisys ClearPath |
| WFL | Work Flow Language — lenguaje de scripting de jobs batch en ClearPath |
| DASDL | Data And Structure Definition Language — DDL nativo de DMSII |
| CNBV R10 | Serie de reportes contables que el banco debe enviar mensualmente a la CNBV |

---

## §01 — Legacy Origen (Sistema Fuente)

### 01.1 Descripción del Sistema Legacy

**S151** es el sistema de **movimientos contables** de Banamex, operando sobre **Unisys ClearPath MCP**. Constituye el **libro mayor (general ledger)** de la institución — el registro maestro e inmutable de todos los asientos contables que reflejan la actividad financiera del banco.

El sistema recibe los movimientos de cargo y abono generados por S500 (y potencialmente otros sistemas) al cierre de la jornada bancaria, los convierte en asientos contables de partida doble según el plan de cuentas CNBV del banco, y los registra en el ledger. Es el origen autoritativo de los estados financieros, la balanza de comprobación y los reportes regulatorios de la CNBV.

**Naturaleza predominantemente batch**: a diferencia de S500 (que tiene componente en línea), S151 es primordialmente un sistema de procesamiento nocturno. El grueso de su operación ocurre durante la ventana de cierre de jornada, aunque puede recibir asientos de ajuste intradiarios.

### 01.2 Contexto Técnico Legacy

| Parámetro | Valor | Notas |
|---|---|---|
| Plataforma | Unisys ClearPath MCP | Versión exacta: `[ETAPA 0 — por confirmar]` |
| Lenguajes | COBOL (principal) + ALGOL (módulos de cálculo / transformación) | Porcentaje estimado: `[ETAPA 1]` |
| Base de datos | DMSII (nativo MCP) | Schema DASDL: `[ETAPA 0 — requiere archivo .dasdl]` |
| Jobs batch | WFL (Work Flow Language) | Inventario de jobs: `[ETAPA 0]` — presumiblemente cadena nocturna |
| Transacciones en línea | `[ETAPA 0 — confirmar si tiene componente OLTP]` | Hipótesis: mínimo o nulo |
| Volumen de asientos/día | `[ETAPA 0 — requiere logs]` | Función directa del volumen de S500 |
| Ventana batch | `[ETAPA 0 — confirmar]` | Dependiente del cierre de jornada de S500 |
| Dependencia del S500 | **CRÍTICA** — S151 no puede iniciar batch sin la señal de cierre de S500 | Secuencia de jobs entre ambos sistemas |
| Antigüedad estimada | `[ETAPA 0]` | Posiblemente anterior o coetáneo con S500 |

### 01.3 Criticidad Regulatoria

| Aspecto | Detalle |
|---|---|
| Regulación principal | CNBV CUB Art. 176–190 (estados financieros); Criterios Contables para Instituciones de Crédito (CNBV) |
| Reporte regulatorio | Fuente de datos para el Reporte R10 (Estados Financieros) — envío mensual obligatorio a CNBV |
| Balanza de comprobación | CNBV requiere que la balanza cuadre diariamente; cualquier descuadre requiere notificación |
| Retención de evidencia | 10 años por CNBV Art. 58 Bis; los asientos son inmutables (nunca se eliminan, solo se revierten) |
| Auditoría externa e interna | S151 es fuente primaria para auditorías financieras y revisiones de la CNBV |
| Impacto de falla | **Crítico** — sin S151 el banco no puede producir sus estados financieros diarios ni cumplir reportes CNBV |

### 01.4 Driver de Modernización

| Driver | Descripción | Peso |
|---|---|---|
| **Dependencia con S500** | La modernización de S151 está acoplada a S500; si se migra S500 sin S151, la integración es frágil | Crítico |
| **Reducción de MIPS / licenciamiento Unisys** | Mismo driver que S500 — plataforma MCP con costos crecientes | Alto |
| **Reporting cloud-native** | Habilitar dashboards financieros en tiempo real y reporting CNBV automatizado desde ledger digital | Alto |
| **Integración con ERP / sistemas modernos** | Citigroup (corporativo) puede requerir integración del ledger con plataformas globales (SAP, Oracle Financials) | Medio |
| **Velocidad de cambio en plan de cuentas** | Modificar el plan de cuentas en COBOL es costoso y lento | Medio |

### 01.5 Dependencia Crítica con S500

`[BLOQUEANTE-POTENCIAL]` La secuencia de modernización de S151 **no puede preceder** a la de S500. La decisión 7R de S151 debe coordinarse con la de S500 para garantizar:
1. Que la interfaz de entrada (movimientos de cargo/abono de S500) sea estable antes de modernizar S151.
2. Que el parallel-run de S151 pueda comparar asientos generados por legacy-S500 vs. nuevo-S500 simultáneamente con los asientos generados por legacy-S151 vs. nuevo-S151.
3. Que la estrategia de cutover de ambos sistemas esté coordinada (Program Management debe gobernar la dependencia cross-componente).

---

## §02 — Scope de la Modernización

### 02.1 Capacidades en Scope (hipótesis inicial — confirmar en ETAPA 2-4)

| ID | Capacidad Funcional Estimada | MoSCoW | Fuente de evidencia |
|---|---|---|---|
| CAP-S151-001 | Recepción y validación de movimientos desde S500 | Must | Dependencia con SPE-MM-001 |
| CAP-S151-002 | Conversión de cargo/abono a asiento contable de partida doble | Must | Concepto del sistema |
| CAP-S151-003 | Clasificación de asientos según plan de cuentas CNBV | Must | Requerimiento regulatorio |
| CAP-S151-004 | Registro en libro mayor (append-only; sin DELETE) | Must | CNBV — inmutabilidad de registros |
| CAP-S151-005 | Cierre de jornada — generación de balanza de comprobación diaria | Must | CNBV obligatorio |
| CAP-S151-006 | Validación de cuadre (débitos = créditos) antes de confirmar el cierre | Must | Principio contable + CNBV |
| CAP-S151-007 | Generación de datos para reportes CNBV (R10 y similares) | Must | CNBV |
| CAP-S151-008 | Asientos de ajuste y reversa | Must | Operación contable estándar |
| CAP-S151-009 | Consulta del ledger por cuenta, período, tipo de movimiento | Should | Auditoría y finanzas |
| CAP-S151-010 | Cierre de período mensual / anual | Should | Finanzas Banamex |

> **Nota**: Hipótesis basadas en el nombre del sistema y conocimiento del dominio contable bancario. Validar en ETAPA 2-4.

### 02.2 Fuera del Scope (MVP de modernización)

- Procesamiento de cargos y abonos (scope de S500 — SPE-MM-001)
- Otros sistemas contables o ERP de Citigroup fuera de MCP Banamex
- Tesorería, FX, derivados (sistemas especializados separados)
- Generación final de reportes CNBV (sistema downstream de reporting; S151 es fuente)

---

## §03 — Decisión 7R (Assessment Inicial)

> Estado: **HIPÓTESIS INICIAL** — validar con análisis ETAPA 0-1 y con SME Mainframe Migration + SME Unisys Banking.
> La decisión 7R de S151 debe coordinarse con la de S500 (ver §01.5).

| Alternativa 7R | Evaluación Inicial | Riesgo Regulatorio |
|---|---|---|
| **Rehost** (emulación MCP en Linux/x86) | Rápido pero perpetúa COBOL; sin valor cloud-native | Bajo — comportamiento idéntico |
| **Refactor — Transpilación COBOL→Java** | Elimina dependencia Unisys; requiere equivalencia ≥ 99.99% en asientos contables | **Muy Alto** — la aritmética contable (packed decimal, rounding bancario, plan de cuentas) es extremadamente sensible |
| **Encapsulate (API-fy)** | Exponer S151 como API para consultas (read); menos valor en la capa de escritura batch | Bajo |
| **Replace** (ledger empaquetado) | Posible si Citigroup adopta Oracle General Ledger o SAP FICA globalmente — fuera del scope actual | N/A |

**Hipótesis de decisión 7R**:
> Dado el perfil predominantemente batch y la criticidad contable/regulatoria de S151:
> 1. **Fase A — Encapsulate (consultas)**: API de lectura sobre el ledger DMSII para habilitar reporting moderno sin tocar el batch de escritura.
> 2. **Fase B — Refactor / Transpilación**: Posterior a S500, con parallel-run ≥ 3 meses + reconciliación de asientos diaria (comparar asientos legacy vs. nuevo centavo por centavo).
>
> **Riesgo crítico**: la transpilación de lógica contable (CAP-S151-002/003/005/006) tiene el nivel de riesgo más alto de ambos proyectos — cualquier divergencia de un centavo en la balanza es un error de auditoría. Review humano 100% sobre la lógica de conversión cargo/abono → asiento contable.

`[ADR-SPE-MM-001]` — Decision 7R por programa: pendiente ETAPA 0-1.

---

## §04 — Estrategia de Coexistencia

> Estado: **TBD** — coordinar con S500 (SPE-MM-001) en DESIGN phase.

| Parámetro | Hipótesis | A confirmar en |
|---|---|---|
| Secuencia relativa a S500 | S151 **después** de S500 — no en paralelo | DESIGN phase (coordinación cross-componente) |
| Patrón de coexistencia | Strangler-Fig — primero capabilities de lectura, luego batch escritura | DESIGN phase |
| Parallel-run | ≥ 3 meses (DoD-SPE-MM-02); comparación de asientos centavo a centavo | DESIGN phase |
| Criterio de equivalencia | ≥ 99.99% (DoD-SPE-MM-01) — balanza de comprobación debe cuadrar en ambos sistemas durante parallel-run | DoD-SPE-MM-01 |
| Data sync durante coexistencia | CDC desde DMSII-S151 hacia target; sync reverso para rollback | ADR-SPE-MM-004 |
| Rollback | Plan por capability, probado (DoD-SPE-MM-03) | DESIGN phase |

---

## §05 — NFRs Baseline del Sistema Legacy

> Baseline del sistema legacy actual — el sistema modernizado debe igualar o superar (DoD-SPE-MM-05).
> Estado: `[ETAPA 0 — requiere logs WFL y monitoreo de producción]`

| NFR | Valor Actual (Legacy) | Fuente | Verificado |
|---|---|---|---|
| Disponibilidad | `[ETAPA 0]` | Logs MCP | ☐ |
| Duración del batch de cierre de jornada | `[ETAPA 0]` | WFL job logs | ☐ |
| Duración del cierre mensual | `[ETAPA 0]` | WFL job logs | ☐ |
| Volumen de asientos procesados por jornada | `[ETAPA 0]` | Logs S151 | ☐ |
| Latencia de consultas al ledger | `[ETAPA 0]` | `[Si existe componente en línea]` | ☐ |
| RTO actual | `[ETAPA 0]` | Plan de continuidad Banamex | ☐ |
| RPO actual | `[ETAPA 0]` | Plan de continuidad Banamex | ☐ |

---

## §06 — Seguridad y Cumplimiento Regulatorio

### 06.1 Controles Regulatorios Aplicables

| Control | Norma | Aplicabilidad a S151 |
|---|---|---|
| Inmutabilidad de asientos contables | CNBV Criterios Contables · Principios de Contabilidad | Los asientos en el ledger son append-only; no se pueden eliminar, solo reversar |
| Balanza de comprobación diaria | CNBV CUB Art. 180 | S151 debe producir balanza que cuadre antes de cerrar jornada |
| Reporte R10 — estados financieros | CNBV · CNBV Circular Única | S151 es fuente; envío mensual a CNBV antes del día 10 hábil |
| Auditoría externa anual | CNBV + Estándares ISA | Auditores externos deben poder acceder al ledger histórico |
| Secreto financiero | CNBV LFISSF Art. 117 | Información contable interna es confidencial |
| Retención 10 años | CNBV Art. 58 Bis | Todo el ledger debe conservarse |

### 06.2 Riesgos de Seguridad por Modernización

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Divergencia aritmética en asientos (packed decimal COBOL vs Java BigDecimal) | **Muy Alta** | **Crítico** — error de auditoría CNBV | Validación centavo a centavo durante parallel-run; golden master de 6+ meses de asientos; test de rounding exhaustivo |
| Ruptura de la secuencia append-only (ledger inmutable) | Media | Crítico — violación regulatoria | Arquitectura target con append-only enforced a nivel BD (PostgreSQL, sin DELETE) + audit triggers |
| Descuadre durante el período de coexistencia (dual-write) | Alta | Alto — riesgo de balanza descuadrada | Reconciliación automática intradiaria legacy vs. nuevo; alerta inmediata ante cualquier diferencia |
| Pérdida de contexto del plan de cuentas durante transpilación | Media | Alto — asientos mal clasificados | Mapeo explícito del plan de cuentas COBOL → entidad digital; review por Contabilidad Banamex |

---

## §07 — ETAPA 0 — Setup & Inventory (Checklist Activo)

> Este checklist dirige la ejecución de la ETAPA 0 del Specialist - Reverse Engineering.
> Avanzar a ETAPA 1 (Static Analysis) requiere `✓` en todos los ítems obligatorios.

### Paso 0.1 — Recolección de Fuentes

#### Artefactos Unisys ClearPath MCP

| Artefacto | Extensión | Obligatorio | Estado | Notas |
|---|---|---|---|---|
| Programas COBOL | `.cob`, `.cbl`, sin ext. | Sí | ☐ | Cargar en `source/` |
| Programas ALGOL | `.alg`, sin ext. | Si aplica | ☐ | Confirmar si S151 tiene módulos ALGOL |
| Work Flow Language jobs | `.wfl`, sin ext. | Sí | ☐ | Cadena batch nocturna — crítica |
| DMSII schema (DASDL) | `.dasdl`, `.ddf` | Sí | ☐ | Schema del ledger DMSII |
| Copybooks / estructuras | `.cpy`, includes | Sí | ☐ | Estructuras de asientos contables |
| Secuencia de dependencia con S500 | Documentación / WFL | Sí | ☐ | Confirmar señal de inicio de S151 desde S500 |
| Logs de ejecución batch | `.log`, archivos WFL | Recomendado | ☐ | Para NFR baseline §05 |
| Plan de cuentas CNBV del banco | Excel, archivo definición | Recomendado | ☐ | Crítico para ETAPA 2 (Data RE) |
| Documentación de reportes CNBV | PDF, manual | Recomendado | ☐ | Mapeo de asientos → reportes |
| Diccionario de datos DMSII | Excel, Word | Recomendado | ☐ | Glosario de campos del ledger |

**Ruta de carga**: `S151/source/` (en este mismo directorio)

### Paso 0.2 — Inventario Maestro (PENDIENTE — completar cuando código esté cargado)

| Campo | Valor |
|---|---|
| Total de programas COBOL | `[ETAPA 0]` |
| Total de programas ALGOL | `[ETAPA 0]` |
| Total de WFL jobs | `[ETAPA 0]` |
| Total de copybooks | `[ETAPA 0]` |
| Total de tablas DMSII (DASDL) | `[ETAPA 0]` |
| Líneas de código total (LOC) | `[ETAPA 0]` |
| Complejidad ciclomática promedio | `[ETAPA 1]` |
| Dead code estimado (%) | `[ETAPA 1]` |

### Paso 0.3 — Acceso a Entornos

| Recurso | Estado | Responsable |
|---|---|---|
| Acceso a MCP (ambiente de desarrollo) | ☐ Pendiente | Banamex Technology |
| Acceso a schema DMSII (DBA) | ☐ Pendiente | Banamex DBA |
| Acceso a logs WFL históricos | ☐ Pendiente | Banamex Technology / OPS |
| Plan de cuentas CNBV del banco (documento) | ☐ Pendiente | Banamex Contabilidad |
| SME técnico Banamex de S151 asignado | ☐ Pendiente | Lead de Proyecto Banamex |
| SME funcional de Contabilidad Banamex asignado | ☐ Pendiente | CFO / Contabilidad Banamex |

### Checklist de Exit — ETAPA 0

```
☐ 0.1 — Código fuente 100% recibido y cargado en source/
☐ 0.2 — Inventario maestro completo (conteo de programas, LOC, jobs)
☐ 0.3 — DASDL schema del DMSII recibido (estructura del ledger)
☐ 0.4 — Cadena de dependencia con S500 documentada (qué señal desencadena S151)
☐ 0.5 — Plan de cuentas CNBV del banco disponible
☐ 0.6 — Al menos 30 días de logs batch disponibles para baseline NFRs
☐ 0.7 — SME técnico Y SME de Contabilidad Banamex asignados y disponibles
☐ 0.8 — Ambiente de análisis provisionado (Specialist - Static Analysis Tooling)
```

**Gate de avance**: todos los ítems con ✓ antes de iniciar ETAPA 1 — Static Analysis.

---

## §08 — DISCOVER Exit Criteria (Gate de Salida a DESIGN)

| Criterio | Estado |
|---|---|
| Inventario maestro completo (ETAPA 0) | ☐ |
| Call graph y matriz de dependencias incluyendo interfaz con S500 (ETAPA 1) | ☐ |
| Data dictionary DMSII + estructura del ledger + ERD lógico (ETAPA 2) | ☐ |
| Catálogo de reglas de negocio contables + flujos funcionales (ETAPA 3) | ☐ |
| Bounded contexts y wave map (ETAPA 4) | ☐ |
| Decisión 7R por programa firmada — coordinada con decisión 7R de S500 (ADR-SPE-MM-001) | ☐ |
| NFR baseline del legacy documentado (§05 completo) | ☐ |
| Secuencia de modernización S500 → S151 confirmada (coordinación cross-componente) | ☐ |
| Stakeholders identificados (Lead Architect ACN + Sponsor Banamex + SME Contabilidad) | ☐ |
| Sign-off formal del DISCOVER assessment por ambas partes | ☐ |

**Estimación de duración DISCOVER**: 4–6 semanas desde recepción del código fuente completo.
**Nota**: el DISCOVER de S151 puede iniciar en paralelo al de S500, pero el DESIGN de S151 depende del DESIGN de S500.

---

## §09 — Plan de Fases

| Fase | Duración Estimada | Dependencia con S500 | Exit Criteria |
|---|---|---|---|
| **DISCOVER** | 4–6 sem | Puede correr en paralelo con DISCOVER de S500 | §08 completo |
| **DESIGN** | 3–4 sem | **Posterior o simultáneo** con DESIGN de S500 — estrategia de coexistencia coordinada | ADRs aceptados; estrategia de integración S500→S151 definida |
| **BUILD — Fase A (Encapsulate lecturas)** | 4–6 sem | Posterior a Fase A de S500 | API de consulta al ledger funcionando |
| **BUILD — Fase B (Refactor batch)** | 14–20 sem | **Posterior** a BUILD-B de S500 estable en producción | Equivalencia ≥ 99.99% en asientos; balanza cuadra en ambos sistemas |
| **TEST** | 4–5 sem | Requiere S500 estable | 0 defectos P1/P2; CNBV compliance sign-off; parallel-run ≥ 3 meses |
| **RELEASE** | Canary por capability | Después de S500 RELEASE | Balanza diaria cuadra en ambos sistemas durante ≥ 3 meses |

---

## §10 — Handoffs

| Fase | SME / Especialista | Input | Output |
|---|---|---|---|
| DISCOVER — ETAPA 0-4 | **Specialist - Reverse Engineering** (este offering) | Código fuente S151 | Assessment completo: inventario, call graph, data dict, reglas contables, bounded contexts |
| DISCOVER — Static Analysis | **Specialist - Static Analysis Tooling** (este offering) | Código fuente S151 | Métricas de complejidad, dead code, hotspots |
| DISCOVER — Semántica Unisys | **SME Unisys Banking** (`SME/Platform/Unisys/`) | Artefactos con `[CONSULTAR→UNISYS]` | Validación de semántica DMSII; estructura del ledger MCP |
| DISCOVER — Semántica contable | **SME de Contabilidad Banamex** (cliente) | Reglas de negocio identificadas en ETAPA 3 | Validación del plan de cuentas; mapeo asiento→reporte CNBV |
| DISCOVER — Metodología | **SME Mainframe Migration** (`SME/Infrastructure/Mainframe Migration/`) | DISCOVER assessment draft | Business case, estimación de esfuerzo, validación 7R |
| DESIGN | **Software Engineering SME** + **Data Architect SME** | DISCOVER assessment + 7R decision de S500 y S151 | Target architecture del ledger digital; ADRs; estrategia de migración de datos |
| ALL | **Program Management** (`SME/Management/Program Management/`) | §09 Phase Plan de S500 + S151 | Cronograma integrado; RAID con dependencia cross-componente |

---

*Spec `SPE-MM-002 — S151 Banamex` · versión 0.1.0 · DRAFT*
*Fase actual: DISCOVER — ETAPA 0 (Setup & Inventory)*
*Dependencia crítica: este componente sigue la secuencia de modernización de S500 (SPE-MM-001)*
*Próxima acción: cargar código fuente en `source/` e iniciar Specialist - Reverse Engineering ETAPA 0*
*Owner del documento: Lead Architect del proyecto Banamex Mainframe Modernization (ACN)*
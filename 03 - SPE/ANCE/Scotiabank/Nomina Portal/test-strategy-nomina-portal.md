# Test Strategy — Portal Empresas Nómina · Scotiabank México
> SPE-ANCE-001 · Owner: dt-qa-engineer · v0.1 · 2026-07-24
> **Quality Engineering shift-left**: casos identificados en DISCOVER/DESIGN, antes de BUILD.
> Derivado de: `backlog-nomina-portal.md` (criterios) + `spec-nomina-portal.md` (reglas RN, máquinas de estado) + `api/openapi-nomina-portal.yaml`

---

## Propósito

Este catálogo identifica los casos de prueba **de forma temprana** — antes de escribir código — a partir de los criterios de aceptación, las reglas de negocio (RN-xx) y las máquinas de estado del spec. Cumple el principio permanente del swarm: *un criterio de aceptación del que no se puede derivar un caso de prueba concreto está mal escrito*.

Cada caso identificado aquí:
1. Se mapea a una user story (`NP-xxx`) y/o regla de negocio (`RN-xx`).
2. Se clasifica por nivel de la pirámide (unit · integration · contract · E2E).
3. Guía la implementación de los DTs de build (test-informed development).
4. Se ejecuta en la fase TEST con la herramienta correspondiente.

Convención de ID: `TC-{MÓDULO}-{NNN}`.

---

## Niveles de Prueba

| Nivel | Herramienta | Cuándo se ejecuta |
|-------|-------------|-------------------|
| Unit | JUnit 5 + Mockito · Jest | CI en cada PR |
| Integration | RestAssured + Testcontainers (SQL Server 2022) | CI |
| Contract | Pact (Frontend↔API · API↔Core Banking Adapter · API↔SPEI Adapter) | CI |
| E2E | Playwright | Pipeline STG |
| Performance | K6 | Pipeline STG |

Prioridad: **P1** (crítico de negocio/regulatorio) · **P2** (importante) · **P3** (secundario).

---

## M1 · Autenticación y Accesos (EP-01)

| TC | Caso | Story/RN | Nivel | Prio | Resultado esperado |
|----|------|----------|-------|------|--------------------|
| TC-AUTH-001 | Login con credenciales válidas | NP-001 | Integration | P1 | 200 · `status=PENDING_2FA` o token según config |
| TC-AUTH-002 | Login con password inválido | NP-001 | Integration | P1 | 401 ProblemDetails · sin token |
| TC-AUTH-003 | Verificación 2FA con código válido | NP-006 · RN-08 | Integration | P1 | 200 · JWT emitido · `expiresIn ≤ 3600` |
| TC-AUTH-004 | Verificación 2FA con código inválido | NP-006 · RN-08 | Integration | P1 | 401 · operación no autorizada |
| TC-AUTH-005 | Acceso a endpoint protegido sin token | NP-002 | Integration | P1 | 401 |
| TC-AUTH-006 | Rol AUDITOR intenta crear nómina | RN (autorización) | Integration | P1 | 403 · `@PreAuthorize` bloquea |
| TC-AUTH-007 | Sesión expira tras inactividad (15 min) | NP-002 | E2E | P2 | Redirect a login · token invalidado |
| TC-AUTH-008 | ADMIN-EMP revoca usuario · sesión activa se invalida | NP-004 | Integration | P2 | Usuario revocado no puede operar |

---

## M4 · Gestión de Empleados (EP-04)

| TC | Caso | Story/RN | Nivel | Prio | Resultado esperado |
|----|------|----------|-------|------|--------------------|
| TC-EMP-001 | Alta de empleado con datos válidos | NP-018 | Integration | P1 | 201 · empleado en estado `NO_INICIADA`→`EN_PROCESO` |
| TC-EMP-002 | RFC con estructura inválida | NP-020 · RN-01 | Unit | P1 | 400 · error campo `rfc` |
| TC-EMP-003 | CURP con estructura inválida | NP-020 · RN-02 | Unit | P1 | 400 · error campo `curp` |
| TC-EMP-004 | RFC válido con checksum correcto | RN-01 | Unit | P1 | Validación pasa |
| TC-EMP-005 | Alta sin 2FA | NP-021 · RN-08 | Integration | P1 | Operación rechazada |
| TC-EMP-006 | Carga masiva con archivo 100% válido | NP-024 | Integration | P1 | 202 · todos exitosos |
| TC-EMP-007 | Carga masiva con error en fila 3 (CLABE inválida) | NP-025 · RN-03·RN-12 | Integration | P1 | Lote válido procesa · fila 3 reportada con campo+mensaje |
| TC-EMP-008 | Carga masiva multi-centro con ID CT inexistente | NP-026 | Integration | P2 | Fila con CT inválido reportada |
| TC-EMP-009 | Búsqueda por RFC/nombre/número | NP-028 | Integration | P2 | Resultados filtrados · paginación cursor |
| TC-EMP-010 | Detalle de empleado enmascara CLABE/tarjeta (rol no privilegiado) | NP-029 · PCI | Integration | P1 | CLABE últimos 6 · tarjeta últimos 4 |
| TC-EMP-011 | Baja lógica preserva historial de dispersiones | NP-032 | Integration | P2 | Estado `ELIMINADA` · historial intacto |
| TC-EMP-012 | Idempotencia: alta repetida con misma Idempotency-Key | OpenAPI | Integration | P1 | No duplica empleado |

---

## M6 · Dispersión de Nómina (EP-06) — flujo crítico

| TC | Caso | Story/RN | Nivel | Prio | Resultado esperado |
|----|------|----------|-------|------|--------------------|
| TC-DISP-001 | Crear nómina QUINCENAL válida | NP-038 | Integration | P1 | 201 · estado `BORRADOR` |
| TC-DISP-002 | Cargar layout válido | NP-039 | Integration | P1 | Estado `LAYOUT_CARGADO` |
| TC-DISP-003 | Validar layout con CLABE inválida en fila N | NP-040 · RN-03 | Integration | P1 | Error específico fila+campo · no pasa a `VALIDADA` |
| TC-DISP-004 | Importe de empleado excede límite | NP-039 · RN-04 | Unit | P1 | Renglón marcado `ERROR` |
| TC-DISP-005 | Monto total excede límite de nómina | RN-05 | Integration | P1 | 422 · code `RN-05` |
| TC-DISP-006 | Saldo origen insuficiente | NP-042 · RN-05 | Integration | P1 | Bloqueo de instrucción · mensaje claro |
| TC-DISP-007 | Dispersar solo empleados FINALIZADA/VINCULADA | RN-07 | Integration | P1 | Empleado no elegible excluido/rechazado |
| TC-DISP-008 | Empresa BLOQUEADA intenta dispersar | RN-09 | Integration | P1 | 422 · dispersión rechazada |
| TC-DISP-009 | Monto ≥ umbral dispara doble autorización | NP-044 · RN-06 | Integration | P1 | Estado `EN_AUTORIZACION` · requiere 2ª firma |
| TC-DISP-010 | Instruir dispersión con 2FA válido | NP-043 · RN-08 | E2E | P1 | 202 · estado `PROCESANDO` · irreversible |
| TC-DISP-011 | Transición DISPERSANDO es irreversible | Máquina estado 6.2 | Integration | P1 | No se permite cancelar tras autorizar |
| TC-DISP-012 | Rechazo SPEI con código Banxico | NP-046 | Contract+E2E | P1 | Estado `RECHAZADA_PARCIAL` · código + acción · importe no debitado |
| TC-DISP-013 | Reproceso individual de empleado rechazado | NP-046 | Integration | P2 | Reintento solo del movimiento rechazado |
| TC-DISP-014 | Seguimiento estado en tiempo real (polling) | NP-045 | E2E | P2 | Estado por empleado actualizado |
| TC-DISP-015 | Idempotencia en instrucción de dispersión | OpenAPI | Integration | P1 | Reintento con misma key no duplica cargo |
| TC-DISP-016 | Performance: dispersión de 10K empleados | NP-024 · SLO-03 | Performance | P1 | E2E < 2 min · sin errores |

---

## M7 · CFDI de Nómina (EP-07)

| TC | Caso | Story/RN | Nivel | Prio | Resultado esperado |
|----|------|----------|-------|------|--------------------|
| TC-CFDI-001 | CFDI se genera solo para movimiento CONFIRMADO | NP-051 · RN-10 | Integration | P1 | CFDI creado tras confirmación |
| TC-CFDI-002 | XML generado es válido estructuralmente (complemento v1.2) | NP-051 | Integration | P1 | XML válido contra XSD SAT |
| TC-CFDI-003 | Consulta y descarga de XML por empleado+periodo | NP-052 | Integration | P2 | XML descargable |
| TC-CFDI-004 | Timbrado fallido muestra código SAT + reintento | NP-054 | Integration | P2 | Estado `ERROR` · reintento ≤ 72h |
| TC-CFDI-005 | Descarga ZIP de todos los CFDI de una nómina | NP-055 | E2E | P3 | ZIP con XMLs + PDFs |

---

## M2·M3·M5·M8·M9 — cobertura base (identificación inicial)

| TC | Caso | Story | Nivel | Prio |
|----|------|-------|-------|------|
| TC-DASH-001 | Dashboard muestra KPIs de empleados por estado | NP-007·NP-011 | E2E | P2 |
| TC-EMPR-001 | Configurar límites de dispersión con 2FA | NP-014 · RN-08 | Integration | P1 |
| TC-EMPR-002 | Consultar movimientos de cuenta origen | NP-017 | Integration | P2 |
| TC-CT-001 | Alta de centro de trabajo con contactos | NP-034 | Integration | P3 |
| TC-CT-002 | Recepción de remesa con código válido + 2FA | NP-036 | Integration | P3 |
| TC-REG-001 | Log de auditoría es inmutable | NP-058 · RN-11 | Integration | P1 |
| TC-REG-002 | Exportar log de auditoría de un periodo | NP-059 | Integration | P2 |
| TC-ADM-001 | ADMIN-SCO bloquea empresa · suspende operaciones | NP-016 · RN-09 | Integration | P1 |

---

## Contract Tests (Pact) — identificados temprano

| TC | Consumer → Provider | Interacción |
|----|--------------------|-------------|
| TC-PACT-001 | Frontend → Nómina API | `listEmpleados` con paginación cursor |
| TC-PACT-002 | Frontend → Nómina API | `instruirDispersion` (202 + Location) |
| TC-PACT-003 | Nómina API → Core Banking Adapter | `consultarSaldo` antes de dispersar |
| TC-PACT-004 | Nómina API → Core Banking Adapter | `instruirCargo` a cuenta origen |
| TC-PACT-005 | Nómina API → SPEI Adapter | instrucción de pago → confirmación/rechazo |

---

## Trazabilidad Criterio → Caso (gate de DoR)

Regla del swarm: **ninguna story entra a BUILD sin al menos un TC identificado por cada criterio de aceptación.** Cobertura de identificación temprana en este catálogo:

| Épica | Stories con TC identificado | Estado |
|-------|----------------------------|--------|
| EP-01 Auth | NP-001,002,004,006 | ✔ ruta crítica |
| EP-04 Empleados | NP-018,020,021,024,025,026,028,029,032 | ✔ ruta crítica |
| EP-06 Dispersión | NP-038..046 | ✔ ruta crítica |
| EP-07 CFDI | NP-051,052,054,055 | ✔ ruta crítica |
| EP-02,03,05,08,09 | base identificada | ⧗ profundizar por sprint |

Cases pendientes de identificar se completan en el refinamiento de cada sprint, siempre **antes** de que la story entre a BUILD.

---

*Creado por dt-qa-engineer · 2026-07-24 · v0.1 · QE shift-left*

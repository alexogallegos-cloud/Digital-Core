# spec-spe-mm-s500
> Modernización Mainframe · Banamex · Unisys ClearPath MCP · Digital Core
> Offering: 03 — Software & Platform Engineering · Sub-Offering: High Velocity Modernization · Solution: Mainframe Modernization
> Versión: 0.1.0 · Estado: DRAFT · Fase SDLC: DISCOVER · Fecha: 2026-06-30

---

## §00 — Header & Component Identity

### 00.1–00.6 Ficha del Componente

| Campo | Valor |
|---|---|
| **Component ID** | `SPE-MM-001` |
| **Nombre** | S500 — Sistema de Cargos y Abonos de Cuentas de Cheque |
| **Tipo** | Mainframe Application (Unisys ClearPath MCP) → Target: Microservicio cloud-native |
| **Offering** | 03 — Software & Platform Engineering |
| **Sub-Offering** | High Velocity Modernization |
| **Solution L4** | Mainframe Modernization |
| **Cliente** | Banamex (Citibanamex) |
| **Plataforma Legacy** | Unisys ClearPath MCP (OS MCP / COBOL + ALGOL) |
| **Fase SDLC Actual** | `DISCOVER` — Etapa 0 (Setup & Inventory) |
| **Owner — Lead Architect** | Por designar (Accenture MX) |
| **Owner — Sponsor Cliente** | Por designar (Banamex Technology) |
| **Estado** | `DRAFT` |
| **Versión Spec** | 0.1.0 |
| **Fecha creación** | 2026-06-30 |
| **Última actualización** | 2026-06-30 |

### 00.6 Changelog

| Versión | Fecha | Autor | Cambio |
|---|---|---|---|
| 0.1.0 | 2026-06-30 | alejandro.gallegos@accenture.com | Creación inicial — DISCOVER phase kickoff |
| 0.2.0 | 2026-06-30 | alejandro.gallegos@accenture.com | Grupos funcionales completados (Etapa 4 HITL draft) — 10 dominios, 57 datasets CAPTACION mapeados |

### 00.7 Componentes Relacionados

| Componente | Relación | Dirección |
|---|---|---|
| `SPE-MM-002` (S151 — Movimientos Contables) | S500 genera asientos contables que S151 procesa | Upstream |
| Core Bancario Banamex | S500 actualiza saldos de cuentas de cheque en core | Downstream |
| Sistema de Conciliación | S500 provee datos para conciliación diaria CNBV | Downstream |
| Plataforma de Pagos (SPEI, CCEN) | Genera cargos y abonos hacia S500 | Upstream |

### 00.8 Glosario

| Término | Definición |
|---|---|
| Cargo | Débito que disminuye el saldo de una cuenta de cheque |
| Abono | Crédito que incrementa el saldo de una cuenta de cheque |
| MCP | Master Control Program — sistema operativo de Unisys ClearPath |
| DMSII | Database Management System II — base de datos nativa de Unisys ClearPath |
| WFL | Work Flow Language — lenguaje de scripting de jobs batch en ClearPath (equivalente a JCL en z/OS) |
| DASDL | Data And Structure Definition Language — DDL nativo de DMSII |
| ClearPath | Plataforma de mainframe propietaria de Unisys (línea MCP y OS2200) |
| CLABE | Clave Bancaria Estandarizada — identificador de 18 dígitos de cuentas bancarias en México |
| CNBV | Comisión Nacional Bancaria y de Valores — regulador bancario de México |
| Ventana batch | Periodo nocturno (típicamente 00:00–06:00 h) para procesamiento offline de la jornada |
| Reconciliación | Proceso diario de cuadre entre saldos de cuentas y movimientos contables; obligatorio CNBV |

---

## §01 — Legacy Origen (Sistema Fuente)

### 01.1 Descripción del Sistema Legacy

**S500** es el sistema de **cargos y abonos de cuentas de cheque** de Banamex, operando sobre **Unisys ClearPath MCP**. Es el componente transaccional central que registra y procesa cada débito y crédito sobre las cuentas de cheque de personas físicas y morales de la institución.

Funciona en dos modalidades:
- **En línea (OLTP)**: procesamiento de transacciones en tiempo real originadas desde cajeros automáticos, terminales punto de venta, banca en línea, SPEI y operaciones de ventanilla.
- **Batch nocturno**: procesamiento de lotes al cierre de jornada — domiciliaciones, cargos diferidos, reversas, intereses, comisiones, cobros de servicios.

El sistema produce los **asientos de cargo/abono** que alimentan al sistema contable S151 (Movimientos Contables) al cierre de cada jornada bancaria.

### 01.2 Contexto Técnico Legacy

| Parámetro | Valor | Notas |
|---|---|---|
| Plataforma | Unisys ClearPath MCP · SSR **62.0** (62.087.8009) | Confirmado en headers DASDL |
| Release actual | `2025.07_M_MEX_XPR_ALL` | Sistema modificado activamente (julio 2025) |
| Lenguajes | COBOL: 78 programas + 10 includes = **625,886 LOC** (69.7%) · ALGOL: 15 módulos = **91,512 LOC** (10.2%) | COBOL principal; ALGOL para control MCP y acceso DMSII |
| Base de datos | DMSII — **7 schemas** DASDL (15,228 LOC) | CAPTACION (8,336 LOC, principal) · TARJETAS · AUXILIAR · MSGAAPLI · MAPLI · TELETON · ATRIBUCTA |
| Jobs batch | WFL — **4 jobs** (34,244 LOC) | LOTE (30,134 LOC, batch nocturno) · LINEA (3,920 LOC, online) · 2 REORG |
| Modos operacionales | **3 modos** confirmados en `P010/PAR/` | `LINEA(0)`=online · `BATCH(1)`=nocturno · `PRELINEA(2)`=pre-online |
| Programa motor | `S500/SOURCE/P010/` — **52,656 LOC** | Referencia 50+ tipos registro DMSII; fragmentado en P010/PRO/ + P010/PAR/ |
| LOC total | **898,596** líneas | 114 piezas extraídas de los 116 del inventario |
| Volumen transaccional | `[PENDIENTE — requiere logs SUMLOG]` | Solicitar a Banamex OPS |
| Ventana batch | `[PENDIENTE]` — confirmar horario WFL LOTE en producción | Típicamente 00:00–06:00 h |

### 01.3 Criticidad Regulatoria

| Aspecto | Detalle |
|---|---|
| Regulación principal | CNBV — Circular Única de Bancos (CUB); CNBV Disposiciones Art. 50–60 |
| Reporte regulatorio | Toda transacción debe reflejarse en los estados financieros CNBV del día |
| Obligación de reconciliación | Cuadre diario obligatorio entre S500 y S151; sin cuadre el banco no puede cerrar jornada |
| Retención de evidencia | 10 años por CNBV Art. 58 Bis |
| Impacto de falla | **Sistémico** — una falla en S500 paraliza operaciones de cuenta de cheque en todo Banamex |

### 01.4 Driver de Modernización

| Driver | Descripción | Peso |
|---|---|---|
| **Reducción de MIPS / licenciamiento Unisys** | Costo de plataforma MCP en crecimiento; Unisys eleva precios año a año | Alto |
| **Velocidad de cambio** | Modificar COBOL requiere skills escasos y ciclos de release lentos (semanas/meses) | Alto |
| **API-ification** | Habilitar acceso desde canales digitales sin pasar por interfaces batch o adaptadores COBOL | Alto |
| **Cloud-native reliability** | Unisys no tiene failover multi-cloud nativo; migración habilita HA cross-region | Medio |
| **Deuda técnica** | `[ETAPA 1 — análisis de complejidad ciclomática y dead code]` | Por confirmar |

---

## §02 — Scope de la Modernización

### 02.1 Capacidades en Scope (hipótesis inicial — confirmar en ETAPA 2-4)

| ID | Capacidad Funcional Estimada | MoSCoW | Fuente de evidencia |
|---|---|---|---|
| CAP-S500-001 | Registro y posteo de cargo/abono en tiempo real | Must | Nombre del sistema |
| CAP-S500-002 | Validación de cuenta (existencia, estado activo, bloqueos) | Must | Flujo lógico inferido |
| CAP-S500-003 | Control de saldo disponible vs. saldo contable | Must | Requerimiento bancario estándar |
| CAP-S500-004 | Generación de referencia de operación (folio único) | Must | Trazabilidad CNBV |
| CAP-S500-005 | Procesamiento de reversas de transacciones | Must | Flujo lógico inferido |
| CAP-S500-006 | Batch nocturno — domiciliaciones y cargos diferidos | Must | Modalidad batch confirmada |
| CAP-S500-007 | Batch nocturno — intereses y comisiones | Should | Flujo lógico inferido |
| CAP-S500-008 | Generación de asientos para S151 (Movimientos Contables) | Must | Relación con SPE-MM-002 |
| CAP-S500-009 | Consulta de movimientos por cuenta | Should | Necesidad de canales digitales |
| CAP-S500-010 | Reconciliación intradiaria | Must | Obligación CNBV |

> **Nota**: Estas capacidades son hipótesis del DISCOVER phase basadas en el nombre del sistema y conocimiento del dominio bancario. Se validarán y corregirán en ETAPA 2 (Business Logic Extraction) y ETAPA 4 (Domain Decomposition).

### 02.2 Fuera del Scope (MVP de modernización)

- Sistemas de tarjeta de crédito (scope diferente)
- Cuentas de ahorro y fondos de inversión (sistemas separados)
- Sistemas de crédito e hipotecario
- Procesamiento SPEI (upstream hacia S500 — no se migra en este componente)
- Sistema contable S151 (componente independiente `SPE-MM-002`)

---

## §03 — Decisión 7R (Assessment Inicial)

> Estado: **HIPÓTESIS INICIAL** — validar con análisis ETAPA 0-1 y con SME Mainframe Migration + SME Unisys Banking.

| Alternativa 7R | Evaluación Inicial | Riesgo Regulatorio |
|---|---|---|
| **Rehost** (emulación MCP en Linux/x86) | Rápido pero perpetúa COBOL; no extrae valor cloud-native | Bajo — comportamiento idéntico |
| **Refactor — Transpilación COBOL→Java** | Medio plazo; requiere golden master testing exhaustivo; elimina dependencia Unisys | **Alto** — aritmética packed decimal, rounding bancario |
| **Encapsulate (API-fy)** | Paso 0 natural: exponer S500 como API REST sobre MCP sin tocar COBOL — habilita canales digitales inmediatamente | Muy bajo — legacy no cambia |
| **Replatform** | COBOL on Linux (GnuCOBOL) — bajo valor, no elimina COBOL | Bajo |
| **Replace** (core empaquetado) | Fuera del scope de esta modernización por separado | N/A |
| **Retain** | Status quo — no modernizar | No aplica — decision de negocio tomada |
| **Retire** | No aplica — sistema activo crítico | N/A |

**Hipótesis de decisión 7R**:
> Estrategia dual en dos fases:
> 1. **Fase A — Encapsulate** (inmediato, bajo riesgo): exponer S500 via capa API (REST) sobre MCP usando Anti-Corruption Layer — habilita canales digitales sin tocar COBOL. Tiempo estimado: 2-4 meses.
> 2. **Fase B — Refactor / Transpilación** (largo plazo): una vez que los canales digitales consumen la API, migrar capability por capability con Strangler-Fig + parallel-run ≥ 3 meses + equivalencia ≥ 99.99% (DoD-SPE-MM-01).

`[ADR-SPE-MM-001]` — Decision 7R por programa: pendiente ETAPA 0-1 para confirmar.

---

## §04 — Estrategia de Coexistencia

> Estado: **TBD** — definir en DESIGN phase una vez completada la Fase A de DISCOVER.

| Parámetro | Hipótesis | A confirmar en |
|---|---|---|
| Patrón de coexistencia | Strangler-Fig por capability (CAP-S500-xxx) | DESIGN phase |
| Duración de parallel-run | ≥ 3 meses por capability (DoD-SPE-MM-02) | DESIGN phase |
| Criterio de equivalencia | ≥ 99.99% (DoD-SPE-MM-01) — reconciliación diaria | DESIGN phase |
| Data sync durante coexistencia | CDC bidireccional desde DMSII hacia target | ADR-SPE-MM-004 |
| Rollback al legacy | Plan por capability, probado antes de cutover (DoD-SPE-MM-03) | DESIGN phase |

---

## §05 — NFRs Baseline del Sistema Legacy

> Estos valores son **baseline del sistema legacy actual** — el sistema modernizado debe igualarlos o superarlos (DoD-SPE-MM-05).
> Estado: `[ETAPA 0 — requiere logs SUMLOG y monitoreo de producción]`

| NFR | Valor Actual (Legacy) | Fuente | Verificado |
|---|---|---|---|
| Disponibilidad | `[ETAPA 0]` | Logs MCP / SLA contratual | ☐ |
| Latencia P95 — transacción en línea | `[ETAPA 0]` | SMF/SUMLOG | ☐ |
| Throughput peak (tx/seg) | `[ETAPA 0]` | SUMLOG pico | ☐ |
| Ventana batch (duración) | `[ETAPA 0]` | WFL job logs | ☐ |
| Volumen diario de transacciones | `[ETAPA 0]` | SUMLOG diario | ☐ |
| RTO actual | `[ETAPA 0]` | Plan de continuidad Banamex | ☐ |
| RPO actual | `[ETAPA 0]` | Plan de continuidad Banamex | ☐ |

---

## §06 — Seguridad y Cumplimiento Regulatorio

### 06.1 Controles Regulatorios Aplicables

| Control | Norma | Aplicabilidad a S500 |
|---|---|---|
| Integridad de cada transacción (no repudio) | CNBV CUB Art. 52 | Cada cargo/abono debe tener folio único e inmutable |
| Reconciliación diaria obligatoria | CNBV CUB Art. 56 | S500 debe cuadrar con S151 al cierre de cada jornada |
| Retención de evidencia de transacciones | CNBV Art. 58 Bis (10 años) | Todos los movimientos deben archivarse |
| Secreto bancario | CNBV LFISSF Art. 117 | Información de cuentas es confidencial; acceso restringido |
| PLD / KYC en transacciones de alto valor | SHCP LFPIORPI | Monitoreo de patrones inusuales en cargos/abonos |
| Reportes CNBV R04-C (movimientos de cuentas) | CNBV | S500 es fuente de datos para este reporte |

### 06.2 Riesgos de Seguridad por Modernización

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Divergencia de rounding en aritmética COBOL vs Java | Alta | **Crítico** — diferencias de centavos acumuladas = descuadre contable | Golden master testing con dataset real (6+ meses); review humano de toda lógica de rounding |
| Pérdida de trazabilidad de folios durante cutover | Media | Alto — violación CNBV Art. 52 | Plan de cutover por capability con validación de secuencia de folios |
| Exposición de datos de cuenta durante migración CDC | Media | Alto — secreto bancario | Cifrado en tránsito (TLS 1.3) y en reposo; KMS; acceso con least privilege |
| Ventana de inconsistencia durante dual-write | Alta | Alto — riesgo de duplicados o pérdida | Outbox pattern + saga coordinada; reconciliación intradiaria automática |

---

## §07 — ETAPA 0 — Setup & Inventory (Checklist Activo)

> Este checklist dirige la ejecución de la ETAPA 0 del Specialist - Reverse Engineering.
> Avanzar a ETAPA 1 (Static Analysis) requiere `✓` en todos los ítems obligatorios.

### Paso 0.1 — Recolección de Fuentes

#### Artefactos Unisys ClearPath MCP

| Artefacto | Extensión | Obligatorio | Estado | Notas |
|---|---|---|---|---|
| Programas COBOL | `.cob`, `.cbl`, sin ext. | Sí | ☐ | Cargar en `source/` |
| Programas ALGOL | `.alg`, sin ext. | Si aplica | ☐ | Confirmar si S500 tiene módulos ALGOL |
| Work Flow Language jobs | `.wfl`, sin ext. | Sí | ☐ | Jobs batch nocturnos |
| DMSII schema (DASDL) | `.dasdl`, `.ddf` | Sí | ☐ | Schema de la BD DMSII de S500 |
| Copybooks / estructuras | `.cpy`, includes | Sí | ☐ | Estructuras compartidas |
| Logs de ejecución (SUMLOG) | `.log`, `.sum` | Recomendado | ☐ | Para NFR baseline §05 |
| Documentación existente | `.pdf`, `.docx`, etc. | Recomendado | ☐ | Manuales técnicos / funcionales |
| Diccionario de datos manual | Excel, Word | Recomendado | ☐ | Si existe documentación de DMSII |

**Ruta de carga**: `S500/source/` (en este mismo directorio)

### Paso 0.2 — Inventario Maestro ✓ COMPLETO (2026-06-30)

> Análisis de grupos funcionales completado (2026-06-30): [`functional-groups-s500.md`](functional-groups-s500.md)
> — 10 dominios funcionales identificados · 57 datasets CAPTACION mapeados · Waves propuestas — **pendiente validación HITL con Banamex**.

| Campo | Valor |
|---|---|
| Total de programas COBOL | **78** programas |
| Total de includes/copybooks COBOL | **10** archivos (algunos > 40K LOC) |
| Total de módulos ALGOL | **15** módulos |
| Total de WFL jobs | **4** (LOTE 30K LOC · LINEA 3.9K · 2 REORG) |
| Total de schemas DMSII (DASDL) | **7** (CAPTACION · TARJETAS · AUXILIAR · MSGAAPLI · MAPLI · TELETON · ATRIBUCTA) |
| **LOC TOTAL** | **898,596** líneas de código |
| Programa más grande | P010 — 52,656 LOC (motor principal) |
| Release del sistema | `2025.07_M_MEX_XPR_ALL` — SSR 62.0 |
| Complejidad ciclomática promedio | `[ETAPA 1]` |
| Dead code estimado (%) | `[ETAPA 1]` |

> Reporte detallado: [`etapa0-report-s500.md`](etapa0-report-s500.md)

### Paso 0.3 — Acceso a Entornos

| Recurso | Estado | Responsable |
|---|---|---|
| Acceso a MCP (producción read-only) | ☐ Pendiente | Banamex Technology |
| Acceso a MCP (ambiente de desarrollo) | ☐ Pendiente | Banamex Technology |
| Acceso a logs SUMLOG | ☐ Pendiente | Banamex Technology / OPS |
| Acceso a schema DMSII (DBA) | ☐ Pendiente | Banamex DBA |
| SME técnico Banamex asignado | ☐ Pendiente | Lead de Proyecto Banamex |

### Checklist de Exit — ETAPA 0

```
✓ 0.1 — Código fuente recibido y cargado en source/ (116 piezas en xlsx)
✓ 0.2 — Inventario maestro completo (114+ piezas, 898,596 LOC)
✓ 0.3 — DASDL schema del DMSII recibido (7 schemas)
☐ 0.4 — Al menos 30 días de SUMLOG disponibles para baseline NFRs [PENDIENTE]
☐ 0.5 — SME técnico Banamex (conocedor del S500) asignado y disponible [PENDIENTE]
✓ 0.6 — Ambiente de análisis provisionado — extracción y análisis local exitoso
⚠ 0.7 — Confirmar si xlsx es inventario completo de producción o solo POC [PENDIENTE]
```

**Estado ETAPA 0**: SUSTANCIALMENTE COMPLETO — ETAPA 1 puede iniciar con observaciones de riesgo documentadas.
**Reporte detallado**: [`etapa0-report-s500.md`](etapa0-report-s500.md)

---

## §08 — DISCOVER Exit Criteria (Gate de Salida a DESIGN)

| Criterio | Estado |
|---|---|
| Inventario maestro completo (ETAPA 0) | ☐ |
| Call graph y matriz de dependencias (ETAPA 1) | ☐ |
| Data dictionary DMSII + ERD lógico (ETAPA 2) | ☐ |
| Catálogo de reglas de negocio + flujos funcionales (ETAPA 3) | ☐ |
| Bounded contexts y wave map (ETAPA 4) | ⚠ EN PROGRESO — [`functional-groups-s500.md`](functional-groups-s500.md) v0.1 DRAFT · pendiente validación HITL |
| Decisión 7R por programa firmada por Architect + Sponsor (ADR-SPE-MM-001) | ☐ |
| NFR baseline del legacy documentado (§05 completo) | ☐ |
| Stakeholders identificados y asignados (Lead Architect ACN + Sponsor Banamex) | ☐ |
| Sign-off formal del DISCOVER assessment por ambas partes | ☐ |

**Estimación de duración DISCOVER**: 4–6 semanas desde recepción del código fuente completo.

---

## §09 — Plan de Fases

| Fase | Duración Estimada | Entry Criteria | Exit Criteria |
|---|---|---|---|
| **DISCOVER** | 4–6 sem | Código S500 disponible (§07 Paso 0.1 ✓) | §08 completo — todos los ítems ✓ |
| **DESIGN** | 3–4 sem | DISCOVER completado | Target architecture ADRs aceptados; Strangler-Fig plan aprobado; Data sync strategy definida |
| **BUILD — Fase A (Encapsulate)** | 6–8 sem | DESIGN completado; ambiente target provisionado | API REST sobre S500 legacy funcionando con contract tests; equivalencia 100% (no hay lógica nueva) |
| **BUILD — Fase B (Refactor)** | 12–18 sem por wave | Fase A estable en producción; golden master dataset preparado | Equivalencia ≥ 99.99% por capability; BDD acceptance verde |
| **TEST** | 3–4 sem | BUILD exit | 0 defectos P1/P2; CNBV compliance sign-off; parallel-run ≥ 3 meses programado |
| **RELEASE** | Canary por capability | TEST completado | SLOs igualan legacy; reconciliación diaria verde |

---

## §10 — Handoffs

| Fase | SME / Especialista | Input | Output |
|---|---|---|---|
| DISCOVER — ETAPA 0-4 | **Specialist - Reverse Engineering** (este offering) | Código fuente S500 | Assessment completo: inventario, call graph, data dict, reglas, bounded contexts |
| DISCOVER — Static Analysis | **Specialist - Static Analysis Tooling** (este offering) | Código fuente S500 | Métricas de complejidad, dead code, hotspots |
| DISCOVER — Unisys semántica | **SME Unisys Banking** (`Solutioning/Delivery - SME/Platform/Unisys/`) | Artefactos con `[CONSULTAR→UNISYS]` | Validación de semántica MCP/DMSII; confirmación de transacciones COMS |
| DISCOVER — Metodología / estimación | **SME Mainframe Migration** (`Solutioning/Delivery - SME/Infrastructure/Mainframe Migration/`) | DISCOVER assessment draft | Business case, estimación de esfuerzo, validación de decisión 7R |
| DESIGN | **Software Engineering SME** (`Solutioning/Delivery - SME/Technology/Software Engineering/`) | DISCOVER assessment + 7R decision | Target architecture; ADRs de transpilación; stack tecnológico |
| ALL | **Program Management** (`Solutioning/Delivery - SME/Management/Program Management/`) | §09 Phase Plan | Cronograma, RAID log, dependencias cross-componente con S151 |

---

*Spec `SPE-MM-001 — S500 Banamex` · versión 0.1.0 · DRAFT*
*Fase actual: DISCOVER — ETAPA 0 (Setup & Inventory)*
*Próxima acción: cargar código fuente en `source/` e iniciar Specialist - Reverse Engineering ETAPA 0*
*Owner del documento: Lead Architect del proyecto Banamex Mainframe Modernization (ACN)*
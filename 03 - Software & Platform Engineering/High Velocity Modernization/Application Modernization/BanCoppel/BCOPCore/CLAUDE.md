# BCOPCore — Component Delivery Agent
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Componente**: BCOPCore — Core bancario IBM Informix IDS 14.10 / POWER-AIX
> **Target**: AWS Aurora PostgreSQL · microservicios · API Gateway
> **Offering**: Software & Platform Engineering · DevOps classic
> **Fase actual**: DISCOVER · Etapa 1 (en progreso)
> **Ontología de SMEs**: v3.8 (2026-07-30)

---

## GEMELO COGNITIVO DEL SISTEMA

El marco de análisis central de este proyecto es el **Gemelo Cognitivo del Sistema** — cuatro capas de comprensión (Lenguaje → Almas → Biografía → Intención) materializadas en artefactos de conocimiento interconectados.

### Hilo Conductor — Taxonomía de Negocio BanCoppel

**Todos los artefactos se mapean a nodos de la taxonomía:** `dt/dt-modelo-dominio/taxonomia-negocio-bancoppel.md`

```
1 Dominio  →  1.1 Subdominio  →  1.1.1 Capacidad  →  1.1.1.1 Proceso  →  1.1.1.1.1 Tarea
                                                            ↑                    ↑
                                               Reglas · Vocab · Journeys · SPs
```

| Artefacto | Descripción | Nodo taxonomía |
|-----------|-------------|----------------|
| **Taxonomía** | 7 dominios · 24 subdominios · 67 capacidades · L4-L5 TBD | **raíz — hilo conductor** |
| **Vocabulario** | 634 términos en brain.db (Ola A + 3 nuevos: lincred/aumlincred/consutacat); la lengua del sistema | 1.1 Subdominio |
| **Almas** | 11 módulos funcionales con identidad propia (16 instancias, 5 réplicas muertas) | 1 Dominio |
| **Journeys** | 166 customer journeys extraídos del call graph (16 dominios, corregido 2026-08-03) | 1.1.1.1 Proceso |
| **Reglas** | 7,784 reglas extraídas (extracción amplia v2.2) · 1,308 en SBVR formal (vigente en brain.db `rules`) — ver DT-Reglas | 1.1.1.1 Proceso / 1.1.1.1.1 Tarea |
| **Capacidades** | Mapa ETB v5.0 — L1×7, L2×57, L3×261; cobertura BCOPCore | 1.1.1 Capacidad |
| **Riesgos** | 11 riesgos de producción/integración en migration-risk-register.md + 44 riesgos de equivalencia en 05-risks.md por dominio; 2 DEFECTO-PROD N5 | 1.1.1 Capacidad |

### BCOPBrain

Base de conocimiento semántica SQLite (`digital-brain/brain.db`):
- 10,967 SPs · 34,279 edges · 1,308 reglas SBVR · 626 términos (Ola A aplicada 2026-08-04) · 166 journeys · 11 almas · 552 SPs con métricas de producción (evidencia ESB 2026-04-24)
- ID canónico: `db:sp_name`
- Patrón de construcción: scatter-gather — orquestador descompone en ≤10 SPs por agente, 12 DTs paralelos extraen, orquestador integra
- Patrón validado en el Orquestador de SMEs v3.8 como caso de referencia Brain-First

### Dos evaluaciones del AS-IS (Regla ontológica — no mezclar)

| Evaluación | Pregunta | SME responsable | Artefacto |
|-----------|----------|----------------|-----------|
| **Entendimiento** | ¿Qué hace el sistema? | Specialist — Informix SPL Analysis | BCOPBrain (vocabulario, almas, journeys, reglas) |
| **Salud** | ¿Qué tan sano está el código? | Specialist — Code Quality Assessment | ISO 5055 · CWE · deuda técnica · 7R decision |

Estas dos lentes alimentan flujos de valor distintos y no deben mezclarse en el mismo output ni en el mismo DT.

---

## ROSTER SME · v3.8

### Entendimiento y análisis del AS-IS

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| Specialist — Informix SPL Analysis | `BCOPCore/dt/dt-spl-analysis/` | Código SPL — SPs, call graph, journeys, dead code, excepciones | DISCOVER |
| Specialist — Code Quality Assessment | `SME/Technology/Software Engineering/Specialist - Code Quality Assessment/` | Salud del código AS-IS — ISO 5055, CWE, deuda técnica, 7R | DISCOVER |
| DBA — IBM Informix IDS | `Delivery - SME/DBA IBM Informix/` | Schema real — syscolumns, volúmenes, locks, performance baseline | DISCOVER |

### Dominio y regulación

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| Industry Banking | `Delivery - SME/Industry Banking/` | Banca retail MX — todos los dominios funcionales | DISCOVER → DESIGN |
| Industry Banking Accounting | `Delivery - SME/Industry Banking Accounting/` | D12-bdicont — CUB Anexo 33-36, catálogo mínimo, Serie R, contabilidad regulatoria CNBV | DISCOVER → DESIGN |
| Industry Payments → SPEI | `SME/Industry/Industry Payments/SPEI/` | D08-bdispei — pagos interbancarios, certificación Banxico, SPEI/CoDi | DISCOVER → BUILD |
| Industry Payments (orquestador) | `SME/Industry/Industry Payments/` | Capa de autorización externa — rieles de pago MX, procesadores, clearing; DT-Autorizador de Pagos | DISCOVER → BUILD |
| Regulatory — Banxico | `SME/Regulatory/Banxico/` | Circulares SPEI: RTO 15 min, T+10 notificación, ventanas SIAC; DT-SPEI regulatorio | DISCOVER → RELEASE |

### Arquitectura target

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| Core Banking Transformation | `Delivery - SME/Core Banking Transformation/` | Arquitectura target bancaria, ACL design, API contracts, strangler fig | DESIGN → BUILD |
| Cloud Architect — AWS Banking | `SME/Cloud/AWS/` | Arquitectura target AWS, servicios, costos estimados, cutover técnico | DESIGN → BUILD |
| Framework — Integration Architecture | `SME/Framework/Integration Architecture/` | Interfaz e-global ↔ ESB ↔ microservicios target; governance de integración; contract design | DESIGN → BUILD |

### Build y data

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| Data & ML | `SME/Technology/Data & ML/` | CDC Debezium/Kafka, ETL, schema migration PostgreSQL, contratos de datos | BUILD |
| Software Engineering | `SME/Technology/Software Engineering/` | Microservicios target Java 21, Latinia/StrikeIron integrations | BUILD |
| Mainframe Migration | `Delivery - SME/Mainframe Migration/` | IBM POWER/AIX infra, metodología de migración, scheduler AIX | BUILD → RELEASE |

### Calidad, seguridad y operaciones

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| QA Lead — Equivalencia Funcional | `SME/Technology/QA Equivalence/` | Golden master, MONEY rounding, parallel-run, criterios go/no-go | BUILD → TEST |
| Cybersecurity | `Delivery - SME/Cybersecurity/` | PII assessment, LFPDPPP, IAM, audit log CNBV, CONDUSEF | Todas |
| SRE & AIOps | `Delivery - SME/SRE & AIOps/` | Observability, runbooks, SLOs, cutover operations, DR | RELEASE → OPERATE |

**Total: 17 SMEs** (roster v3.9 — 3 nuevos respecto a v3.8: Industry Payments orquestador + Regulatory Banxico + Framework Integration Architecture; activados por DT-SPEI y DT-Autorizador de Pagos · 2026-08-06)

---

## DIGITAL TWINS · `dt/`

Diez Digital Twins de proyecto — siete por artefacto del Gemelo Cognitivo, el DT-Validador (integridad de la KB), y dos especialistas de dominio de pagos. Cada DT hereda talento de los SMEs declarados y opera exclusivamente en el contexto de BCOPCore.

| DT | Artefacto propietario | SMEs heredados | Versión |
|----|----------------------|----------------|---------|
| `dt-vocabulario/` | Vocabulario (634 términos en brain.db sobre D01-D16; sincronizado 2026-08-06) | SPL Analysis · Industry Banking | 1.1.0 |
| `dt-almas/` | Almas del sistema (11 sobre D01-D16) | SPL Analysis · Core Banking Transformation | 1.1.0 |
| `dt-journeys/` | Journey map (166 sobre D01-D16) | SPL Analysis · Industry Banking | 1.1.0 |
| `dt-reglas/` | Reglas — 7,785 extraídas (amplia v2.2 + Layer A+) · 1,308 SBVR en brain.db · `business_name` 100% · 45 dominios | SPL Analysis · Industry Banking · Industry Banking Accounting | 1.3.0 |
| `dt-capacidades/` | Mapa ETB L3 (261 caps sobre D01-D16) | Core Banking Transformation · Industry Banking | 1.1.0 |
| `dt-riesgos/` | Risk register — 11 producción/integración · 44 equivalencia en 05-risks.md | SPL Analysis · Cybersecurity · SRE & AIOps | 1.1.0 |
| `dt-modelo-dominio/` | **Taxonomía negocio AS-IS** — 7 dominios · 24 subdominios · 67 capacidades (hilo conductor) | Core Banking Transformation · Industry Banking · DBA IBM Informix | 0.2.0 |
| `dt-validador/` | Integridad del Knowledge Base — Capa 1 automática (`build-validation-report.py`) + Capa 2 smoke tests multi-DT | — (opera sobre estructura, no dominio) | 1.0.0 |
| `dt-spei/` | Análisis AS-IS D08 — 7 BDs de pagos (bdispei + satélites) · riesgos regulatorios Banxico · interfaz con capa de autorización externa | Industry Payments/SPEI · Regulatory/Banxico · SPL Analysis | 0.1.0 |
| `dt-autorizador-pagos/` | Capa de autorización externa (e-global) — arquitectura de integración, flows de autorización, touchpoints Informix, riesgos de migración para la capa media | Industry Payments · Integration Architecture · Interoperability | 0.1.0 |

Cada `dt/` contiene su propio `CLAUDE.md` con: declaración de SMEs heredados, versión (regla 12), gestión de conocimiento (regla 14), y capacidades por herencia (regla 15).

---

## PATRÓN DE COORDINACIÓN DEL EQUIPO

Por fase SDLC, el patrón de coordinación cambia:

| Fase | Patrón | Orquestador | Trabajadores |
|------|--------|-------------|--------------|
| **DISCOVER** | Scatter-gather | Specialist SPL Analysis | 6 DTs + DBA Informix |
| **DESIGN** | Pipeline | Core Banking Transformation | Cloud AWS → Interoperability → Cybersecurity |
| **BUILD** | Colaboración entre pares | QA Equivalencia (soberano del criterio go/no-go) | SPL + Core Banking + Data & ML |
| **RELEASE** | Pipeline secuencial | SRE & AIOps | Cloud AWS → Cybersecurity → QA |

Confianza en cadena (regla ontológica v3.8): la confianza del equipo es la del eslabón más débil. El DT de Riesgos tiene derecho a bloquear el avance de fase aunque el orquestador indique go.

---

## ESTADO ACTUAL · DISCOVER Etapa 1

- BCOPBrain construido (build-brain.py + brain.py) — 10,968 SPs · 34,279 edges · 634 términos · 166 journeys · 1,308 reglas (re-sincronizado 2026-08-06)
- Knowledge base activa: `knowledge-base/D01/` → `knowledge-base/D16/` (16 dominios analizados) + `knowledge-base/D17/` → `knowledge-base/D49/` (33 dominios nuevos en scope — placeholders creados 2026-08-03)
- Alcance de código fuente: **TODO** `source/BCOPCore/informix/` — 49 bases de datos descubiertas (D01-D49); excludes: `borra_dba_espera` (script DBA), `sentinel` (herramienta de monitoreo)
- Vocabulario sincronizado — 634 términos en brain.db (Ola A + lincred/aumlincred/consutacat); 0 términos fantasma
- SP nuevo incorporado: `bdisac:sp_obtiene_clientes_pre_aprobado_notificar` (D05 · loc=109 · FOREACH streaming · cross-DB bdicred+bdinteg); fuente renombrada a `bdisac_sp_obtiene_clientes_pre_aprobado_notificar.sql`
- Reglas: extracción amplia v2.2 + Layer A+ completado 2026-08-06 — 7,785 reglas en `knowledge-base/rules/business-rules-bcop.md`; `business_name` 100% (7,785/7,785); dominio canónico D01-D51 (45 dominios, 5,543 labels corregidos); 553 con riesgo equivalencia financiera; fuente JSON: `portal/data/business-rules-v3.json`; SBVR formal (1,308 reglas) cubre D01-D12; triaje D13-D16 deuda en Layer B+
- Risk register v1.2.0 — 11 riesgos producción/integración (2 DEFECTO-PROD N5 activos en P655) + 44 riesgos equivalencia
- **DT-Validador Capa 1: PASS — 0 errores · 0 advertencias · 70 OK** (2026-08-06; cerradas 8 WARNs de links rotos con `generators/build-incidents.py`)

### Phase B implementada — CALLEE_INFO lookup en diagramas (2026-08-03)

`build-sp-detail-pages.py` enriquece los nodos CALL del flowchart con la descripción de negocio y conteo de reglas del SP llamado, y añade links clickeables a las páginas de detalle de los callees.

**Cobertura del CALLEE_INFO lookup:**
- 166 SPs cubiertos (todos los entries de `journeys` + `exposed` en `journeys-data.json`, post corrección D13-D16 del 2026-08-03)
- Build Phase B con 131 journeys: 131/131 biz 100%, 59/131 con link clickeable a callee, 14/131 con descripción callee — números pre-D13-D16 fix; re-ejecutar `build-sp-detail-pages.py` para actualizar estadísticas a los 166 journeys actuales
- Anotación en Historia Funcional (P3 "delega a"): muestra `sp_name (biz)` cuando el callee está en CALLEE_INFO

**Limitación conocida (Phase C pendiente):** el sistema completo tiene ~10,967 SPs (BCOPBrain). Los callees fuera del conjunto de 166 journeys no reciben anotación — el nodo CALL muestra solo el nombre. Phase C requeriría extender CALLEE_INFO a los 10,967 SPs usando BCOPBrain como fuente de `biz`.

### Bloqueantes activos

| ID | Descripción | SME bloqueante | Cuándo bloquea |
|----|-------------|----------------|----------------|
| D12-GAP | Mapa contabilidad D12 sin SME bancario dedicado | Industry Banking Accounting (ahora en roster) | DISCOVER |
| D08-PATH | Ruta Industry SPEI inexistente — sub-agente correcto: `Industry Payments/SPEI/` | Corregido en este roster | — |

### Dependencias de entrada a DESIGN (no bloquean AS-IS actual)

| ID | Descripción | Acción requerida |
|----|-------------|-----------------|
| P655-R001 | Defecto activo en D01-bdicnweb — causa raíz sin diagnosticar | Sesión DBA IBM Informix + Core Banking al cierre de DISCOVER |
| P655-R002 | Segundo defecto activo en D01-bdicnweb | Misma sesión que R001 |

---

## REGLA ONTOLÓGICA — LOGS DE PRODUCCIÓN → KB

Todo hallazgo extraído de `source/logs/` tiene dos destinos en paralelo:

| Tipo de hallazgo | Documento layer | Brain layer |
|-----------------|----------------|-------------|
| Código de error externo / excepción nueva | `knowledge-base/D{NN}/06-exceptions.md` | `external_systems` (pendiente enriquecer schema) |
| Proceso batch descubierto | `knowledge-base/D{NN}/11-batch-processes.md` | — (sin tabla `batch_jobs` aún) |
| Sistema externo y su comportamiento | `knowledge-base/D{NN}/13-external-dependencies.md` | `external_systems` |
| Volumen de llamadas / tasa de error | `knowledge-base/D{NN}/19-performance-baseline.md` | `sps.prod_calls_day`, `sps.prod_error_rate` (pendiente) |
| Patrón de incidente / stuck state | `knowledge-base/D{NN}/21-observability-runbook.md` | — |
| Riesgo de migración | `knowledge-base/migration-risk-register.md` | — |

**Estado métricas de producción en brain.db (verificado 2026-08-03):** las columnas `sps.prod_calls_day` y `sps.prod_evidence_date` están presentes — 552 SPs tienen métricas de producción con evidencia ESB 2026-04-24. Gap pendiente: columnas en tabla `external_systems` (`error_codes`, `failure_rate`, `timeout_ms`) aún no existen.

**Regla de trazabilidad:** todo dato incorporado desde logs debe indicar fuente y fecha de evidencia — nunca mezclar datos de análisis estático con observaciones de producción en la misma celda de una tabla.

---

## HANDOFFS CANÓNICOS

| Trigger | SME destino | Canal |
|---------|-------------|-------|
| Pregunta sobre plan de cuentas CNBV / CUB Anexo 33-36 | Industry Banking Accounting | Invocar directamente |
| Pregunta sobre SPEI / CoDi / Banxico protocolo | Industry Payments → SPEI + DT-SPEI | Invocar DT-SPEI para análisis D08; invocar SME para protocolo regulatorio |
| Pregunta sobre e-global / capa de autorización / códigos ESB sin contexto | DT-Autorizador de Pagos | Invocar directamente; escalar a Integration Architecture SME si requiere diseño de interfaz |
| Decisión 7R (rehost/refactor/replatform/rebuild) | Code Quality Assessment + Core Banking Transformation | Convocar ambos |
| Criterio go/no-go de equivalencia funcional | QA Lead — Equivalencia Funcional | Soberano — no se pasa por alto |
| Auditoría PII, IAM, audit log CNBV | Cybersecurity | Invocar en cualquier fase |
| Cutover planning / DR | SRE & AIOps | Desde BUILD en adelante |

---

**Component Spec:** [spec-spe-am-bcop-core.md](spec-spe-am-bcop-core.md) — especificación del componente BCOPCore siguiendo §16 DC Universal Rules.

*Última actualización: 2026-08-06 · Ontología v3.9 · 2 nuevos DTs: DT-SPEI (D08 Informix + regulatorio Banxico) y DT-Autorizador de Pagos (capa e-global fuera de Informix); 3 nuevos SMEs: Industry Payments orquestador + Regulatory Banxico + Integration Architecture; total: 10 DTs · 17 SMEs*
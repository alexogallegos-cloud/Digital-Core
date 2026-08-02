# BCOPCore — Component Delivery Agent
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Componente**: BCOPCore — Core bancario IBM Informix IDS 14.10 / POWER-AIX
> **Target**: AWS Aurora PostgreSQL · microservicios · API Gateway
> **Offering**: Software & Platform Engineering · DevOps classic
> **Fase actual**: DISCOVER · Etapa 1 (en progreso)
> **Ontología de SMEs**: v3.8 (2026-07-30)

---

## GEMELO COGNITIVO DEL SISTEMA

El marco de análisis central de este proyecto es el **Gemelo Cognitivo del Sistema** — cuatro capas de comprensión (Lenguaje → Almas → Biografía → Intención) materializadas en seis artefactos de conocimiento que viven en `digital-brain/`.

| Artefacto | Descripción | Estado |
|-----------|-------------|--------|
| **Vocabulario** | 438 términos del dominio; la lengua del sistema | Activo |
| **Almas** | 15 módulos funcionales con identidad propia | Activo |
| **Journeys** | 131 customer journeys extraídos del call graph | Activo |
| **Reglas** | 1,308 reglas de negocio (SBVR) distribuidas en 33 archivos | Activo |
| **Capacidades** | Mapa ETB v5.0 — L1×7, L2×57, L3×261; cobertura BCOPCore | Activo |
| **Riesgos** | 44 riesgos de migración N1→N5; 5 categorías; 2 DEFECTO-PROD | Activo |

### BCOPBrain

Base de conocimiento semántica SQLite (`digital-brain/brain.db`):
- 10,144 SPs · 34,279 edges · 1,308 reglas
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

### Arquitectura target

| SME | Ruta canónica | Objeto de análisis | Fase |
|-----|---------------|--------------------|------|
| Core Banking Transformation | `Delivery - SME/Core Banking Transformation/` | Arquitectura target bancaria, ACL design, API contracts, strangler fig | DESIGN → BUILD |
| Cloud Architect — AWS Banking | `SME/Cloud/AWS/` | Arquitectura target AWS, servicios, costos estimados, cutover técnico | DESIGN → BUILD |

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

**Total: 14 SMEs** (roster v3.8 — 2 nuevos respecto a v0 del 2026-07-03: Industry Banking Accounting + Code Quality Assessment)

---

## DIGITAL TWINS · `dt/`

Seis Digital Twins de proyecto — uno por artefacto del Gemelo Cognitivo. Cada DT hereda talento de los SMEs declarados y opera exclusivamente en el contexto de BCOPCore.

| DT | Artefacto propietario | SMEs heredados | Versión |
|----|----------------------|----------------|---------|
| `dt-vocabulario/` | Vocabulario (438 términos) | SPL Analysis · Industry Banking | 1.0.0 |
| `dt-almas/` | Almas del sistema (15) | SPL Analysis · Core Banking Transformation | 1.0.0 |
| `dt-journeys/` | Journey map (131) | SPL Analysis · Industry Banking | 1.0.0 |
| `dt-reglas/` | Reglas de negocio (1,308) | SPL Analysis · Industry Banking · Industry Banking Accounting | 1.0.0 |
| `dt-capacidades/` | Mapa ETB L3 (261 caps) | Core Banking Transformation · Industry Banking | 1.0.0 |
| `dt-riesgos/` | Risk register (44) | SPL Analysis · Cybersecurity · SRE & AIOps | 1.0.0 |
| `dt-modelo-dominio/` | Modelo lógico negocio — 23 BCs ETB L2 | Core Banking Transformation · Industry Banking · DBA IBM Informix | 0.1.0 |

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

- BCOPBrain construido (build-brain.py + brain.py) — scatter-gather completado
- 22 archivos de knowledge-base generados en `knowledge-base/D01/` → `knowledge-base/D12/`
- Vocabulario Capa 1 expandido — S151/S500 cross-referenced
- Reglas: Ola 4 completa (1,550 → 1,308 vigentes tras triaje SME regulatorio)
- Risk register v3.8 — 44 riesgos; 2 DEFECTO-PROD activos en P655

### Bloqueantes activos

| ID | Descripción | SME bloqueante |
|----|-------------|----------------|
| D12-GAP | Mapa contabilidad D12 sin SME bancario dedicado | Industry Banking Accounting (ahora en roster) |
| D08-PATH | Ruta Industry SPEI inexistente — sub-agente correcto: `Industry Payments/SPEI/` | Corregido en este roster |

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
| Riesgo de migración | `GemCog/migration-risk-register.md` | — |

**Gap conocido en brain.db (2026-08-01):** los schemas actuales (`sps`, `external_systems`) no tienen columnas de métricas de producción. Pendiente agregar: `sps.prod_calls_day`, `sps.prod_error_rate`, `sps.prod_evidence_date`; `external_systems.error_codes`, `external_systems.failure_rate`, `external_systems.timeout_ms`.

**Regla de trazabilidad:** todo dato incorporado desde logs debe indicar fuente y fecha de evidencia — nunca mezclar datos de análisis estático con observaciones de producción en la misma celda de una tabla.

---

## HANDOFFS CANÓNICOS

| Trigger | SME destino | Canal |
|---------|-------------|-------|
| Pregunta sobre plan de cuentas CNBV / CUB Anexo 33-36 | Industry Banking Accounting | Invocar directamente |
| Pregunta sobre SPEI / CoDi / Banxico protocolo | Industry Payments → SPEI | Invocar directamente |
| Decisión 7R (rehost/refactor/replatform/rebuild) | Code Quality Assessment + Core Banking Transformation | Convocar ambos |
| Criterio go/no-go de equivalencia funcional | QA Lead — Equivalencia Funcional | Soberano — no se pasa por alto |
| Auditoría PII, IAM, audit log CNBV | Cybersecurity | Invocar en cualquier fase |
| Cutover planning / DR | SRE & AIOps | Desde BUILD en adelante |

---

*Última actualización: 2026-07-31 · Ontología v3.8 · Creación inicial del project agent*
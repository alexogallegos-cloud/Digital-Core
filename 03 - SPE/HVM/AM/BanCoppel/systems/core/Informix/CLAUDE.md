# Informix Core (PISA) — Component Delivery Agent
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Componente**: Core bancario IBM Informix IDS 14.10 / POWER-AIX · alias: PISA
> **Ruta canónica**: `BanCoppel/systems/core/Informix/`
> **Target**: AWS Aurora PostgreSQL · microservicios · API Gateway
> **Offering**: Software & Platform Engineering · DevOps classic
> **Fase actual**: DISCOVER · Etapa 1 (en progreso)
> **Ontología de SMEs**: v3.8 (2026-07-30)
>
> **TOGAF metadata**
> `togaf_type: core` · `togaf_state: baseline` · `togaf_system_of: record`
> `togaf_abb: core-banking` · `bian_domains: [loan-management, savings-management, payments-execution, financial-accounting, regulatory-reporting]`

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
| **Reglas** | 8,005 reglas extraídas (v2.2 + Layer A+ + B+) · 1,308 en SBVR formal (brain.db) · business_name enriquecido (1,883 mejorados) — ver DT-Reglas | 1.1.1.1 Proceso / 1.1.1.1.1 Tarea |
| **Capacidades** | Mapa ETB v5.0 — L1×7, L2×57, L3×261; cobertura Informix | 1.1.1 Capacidad |
| **Riesgos** | 11 riesgos de producción/integración en migration-risk-register.md + 44 riesgos de equivalencia en 05-risks.md por dominio; 2 DEFECTO-PROD N5 | 1.1.1 Capacidad |

### BCOPBrain

Base de conocimiento semántica SQLite (`digital-brain/brain.db`):
- 12,812 SPs · 34,279 edges · 8,955 reglas totales — clasificadas por naturaleza (campo `clase`): **6,819 NEGOCIO genuinas** (76%) + 2,136 no-negocio (1,958 INFRAESTRUCTURA shell/dbaccess/AIX · 101 ENSAMBLAJE_REPORTE SQL dinámico · 77 PRESENTACION formato). Validado contra código fuente 99.98% (2/8,955 discrepancias) · 634 términos · 166 journeys · 11 almas · 552 SPs con métricas de producción (evidencia ESB 2026-04-24)
- sp_capabilities: 74,211 links · 11,360/12,812 SPs cubiertos (88.7%) · 61 L3 distintas · CTM_ENTRY=87 · CTM_HINT=18
- ETB L3 fine-mapping: 8,772/12,812 SPs (68.5%) con primary_l3 · 97.6% con biz
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
| Specialist — Informix SPL Analysis | `Informix/dt/dt-spl-analysis/` | Código SPL — SPs, call graph, journeys, dead code, excepciones | DISCOVER |
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

Diez Digital Twins de proyecto — siete por artefacto del Gemelo Cognitivo, el DT-Validador (integridad de la KB), y dos especialistas de dominio de pagos. Cada DT hereda talento de los SMEs declarados y opera exclusivamente en el contexto de Informix.

| DT | Artefacto propietario | SMEs heredados | Versión |
|----|----------------------|----------------|---------|
| `dt-spl-analysis/` | Orquestador scatter-gather · Specialist código Informix SPL — extracción, parsing, análisis de SPs | SPL Analysis (propio) · DBA IBM Informix | 1.1.0 |
| `dt-vocabulario/` | Vocabulario (634 términos en brain.db sobre D01-D16; sincronizado 2026-08-06) | SPL Analysis · Industry Banking | 1.1.0 |
| `dt-almas/` | Almas del sistema (11 sobre D01-D16) | SPL Analysis · Core Banking Transformation | 1.1.0 |
| `dt-journeys/` | Journey map (166 sobre D01-D16) | SPL Analysis · Industry Banking | 1.1.0 |
| `dt-reglas/` | Reglas — 8,005 extraídas (amplia v2.2 + Layer A+) · 1,308 SBVR en brain.db · `business_name` enriquecido (1,883/1,969 weak names mejorados con heurísticas SPL) · 45 dominios | SPL Analysis · Industry Banking · Industry Banking Accounting | 1.5.0 |
| `dt-capacidades/` | Mapa ETB L3 (261 caps sobre D01-D16) | Core Banking Transformation · Industry Banking | 1.1.0 |
| `dt-riesgos/` | Risk register — 11 producción/integración · 44 equivalencia en 05-risks.md | SPL Analysis · Cybersecurity · SRE & AIOps | 1.1.0 |
| `dt-modelo-dominio/` | **Taxonomía negocio AS-IS** — 7 dominios · 24 subdominios · 67 capacidades (hilo conductor) | Core Banking Transformation · Industry Banking · DBA IBM Informix | 0.2.0 |
| `dt-validador/` | Integridad del Knowledge Base — Capa 1 automática (`build-validation-report.py`) + Capa 2 smoke tests multi-DT | — (opera sobre estructura, no dominio) | 1.0.0 |
| `dt-spei/` | Análisis AS-IS D08 — 7 BDs de pagos (bdispei + satélites) · riesgos regulatorios Banxico · interfaz con capa de autorización externa | Industry Payments/SPEI · Regulatory/Banxico · SPL Analysis | 0.1.0 |
| `dt-autorizador-pagos/` | Capa de autorización externa (e-global) — arquitectura de integración, flows de autorización, touchpoints Informix, riesgos de migración para la capa media | Industry Payments · Integration Architecture · Interoperability | 0.1.0 |
| `dt-operacional-batch/` | Taxonomía de scripts batch/shell (~1,104 reglas) — clasificación operacional por tipo (DESCARGA/CARGA/ELIMINACION/EJECUCION_SQL/etc.) · owner de RE_SHELL y classify_shell_cmd | SPL Analysis · DBA IBM Informix | 0.1.0 |
| `dt-regulatorio/` | Tabla regulación → artículo + descripción corta (CNBV/LISR/LTOSF/LRSIC/PLD/FATCA/SPEI) — alimenta paso G del pipeline de inferencia | Industry Banking · Industry Banking Accounting · Regulatory/Banxico | 0.1.0 |
| `dt-catalogo-errores/` | Catálogo de códigos de error BanCoppel → descripción humana — enriquece ~500 reglas VALIDACIÓN con "Validación: código de error NNNN" | DBA IBM Informix · Industry Banking | 0.1.0 |

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

- BCOPBrain construido (build-brain.py + brain.py) — 12,812 SPs · 634 términos · 166 journeys · 8,955 reglas de negocio (re-sincronizado 2026-08-12)
- Knowledge base activa: `knowledge-base/D01/` → `knowledge-base/D16/` (16 dominios analizados) + `knowledge-base/D17/` → `knowledge-base/D49/` (33 dominios en scope — placeholders KB creados 2026-08-03; SPs cargados 2026-08-12: 1,421 SPs nuevos vía `generators/load-missing-domains.py`; reglas extraídas con pipeline vocab-anchored vía `generators/extract-rules-d17-d49.py`)
- Alcance de código fuente: **TODO** `source/informix/` — 49 bases de datos descubiertas (D01-D49); excludes: `borra_dba_espera` (script DBA), `sentinel` (herramienta de monitoreo)
- Vocabulario sincronizado — 634 términos en brain.db (Ola A + lincred/aumlincred/consutacat); 0 términos fantasma
- SP nuevo incorporado: `bdisac:sp_obtiene_clientes_pre_aprobado_notificar` (D05 · loc=109 · FOREACH streaming · cross-DB bdicred+bdinteg); fuente renombrada a `bdisac_sp_obtiene_clientes_pre_aprobado_notificar.sql`
- Reglas: **8,955 reglas vocab-anchored** (D01-D49 completo, fuente `portal/data/business-rules-v3.json`), clasificadas por naturaleza (`clase`):
  - **Eje naturaleza (campo `clase`, barrido total `classify-rule-nature.py` 2026-08-12, validado contra fuente 99.98%)**: 6,819 NEGOCIO (76%) · 1,958 INFRAESTRUCTURA (shell/dbaccess/UNLOAD/paths AIX — plumbing, no negocio) · 101 ENSAMBLAJE_REPORTE (construcción de SQL dinámico para reportes) · 77 PRESENTACION (formato/padding/mensajes). Regla ontológica: `clase` es ortogonal a `tipo`; el conteo de "reglas de negocio" reales = subconjunto NEGOCIO. Todas las 2,136 no-negocio son tipo FÓRMULA (el regex FÓRMULA capturaba ensamblaje de strings con `||` y paths con `/`)
  - **D01-D16** (7,739 reglas): extracción v2.2 + Layer A/B/C — `business_name` 100%; SBVR formal 1,012 (511 D01-D12 + 501 D13-D16 Layer C+); dominio canónico corregido
  - **D17-D49** (1,216 reglas): extracción vocab-anchored `extract-rules-d17-d49.py` (2026-08-12) sobre 2,110 SPs — **797 FÓRMULA · 389 VALIDACIÓN · 30 UMBRAL**; **reg 100%** (triaje regulatorio `triaje-d17-d49.py` 2026-08-12: CONSAR/SAR D20·AFORE, CNBV-Serie-R D36·Repaut, Banxico-UDI D41·Corresponsalía, CNBV-LRSIC D24·Buró, CNBV-PLD D25·Sitio-Especial, +21 dominios con defaults por DB); **riesgo 39%** (485 reglas: FX conversión D36, UDI D41, MONEY/DIV/ROUND). Reemplazó 25,165 reglas crudas IF/THEN (ruido de control-flow técnico) por reglas de negocio genuinas — misma maquinaria que produjo los 4,597 FÓRMULA de D01-D16
  - **Portal**: filtro por `clase` (Negocio/Infra/Ensamblaje/Presentación) + hero "Reglas de negocio" (6,819) — `rules-catalog-bcop.html`
- Risk register v1.2.0 — 11 riesgos producción/integración (2 DEFECTO-PROD N5 activos en P655) + 44 riesgos equivalencia
- **DT-Validador Capa 1: PASS — 0 errores · 0 advertencias · 70 OK** (2026-08-06; cerradas 8 WARNs de links rotos con `generators/build-incidents.py`)

### Phase B implementada — CALLEE_INFO lookup en diagramas (2026-08-03)

`build-sp-detail-pages.py` enriquece los nodos CALL del flowchart con la descripción de negocio y conteo de reglas del SP llamado, y añade links clickeables a las páginas de detalle de los callees.

**Cobertura del CALLEE_INFO lookup:**
- 166 SPs cubiertos (todos los entries de `journeys` + `exposed` en `journeys-data.json`, post corrección D13-D16 del 2026-08-03)
- Build Phase B con 131 journeys: 131/131 biz 100%, 59/131 con link clickeable a callee, 14/131 con descripción callee — números pre-D13-D16 fix; re-ejecutar `build-sp-detail-pages.py` para actualizar estadísticas a los 166 journeys actuales
- Anotación en Historia Funcional (P3 "delega a"): muestra `sp_name (biz)` cuando el callee está en CALLEE_INFO

**Limitación conocida (Phase C pendiente):** el sistema completo tiene ~12,812 SPs (BCOPBrain). Los callees fuera del conjunto de 166 journeys no reciben anotación — el nodo CALL muestra solo el nombre. Phase C requeriría extender CALLEE_INFO a los 11,391 SPs usando BCOPBrain como fuente de `biz`.

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

**Estado métricas de producción en brain.db (verificado 2026-08-03):** las columnas `sps.prod_calls_day` y `sps.prod_evidence_date` están presentes — 552 SPs tienen métricas de producción con evidencia ESB 2026-04-24. Gap cerrado 2026-08-12: columnas `error_codes`, `failure_rate`, `timeout_ms` añadidas a `external_systems` en `build-brain.py`; se populan desde `integrations-data.json` si el campo existe.

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

---

## PIPELINE CANÓNICO DE REBUILD — BCOPBrain

Secuencia idempotente para reconstruir `digital-brain/brain.db` desde cero. Cada paso preserva los marks de los pasos anteriores.

```
# ── Paso 1: Brain base (siempre primero) ──────────────────────────────────────
python digital-brain/build-brain.py
# Produce: sps (12,812), edges, journeys, rules, terms, vocabulary, sp_capabilities,
#          sp_archetype=estructural (fan_in/fan_out), batch_archetype=CTM_HINT para ~18 SPs
#          (via mark_ctm_hints → lee CTM brain.db adjunto si existe)

# ── Paso 2: Arquetipos por análisis de código fuente ──────────────────────────
python digital-brain/classify-batch.py
# Produce: batch_analysis (14 cols), batch_archetype=contenido (FILE_LOADER/DATA_MAINT/…)
# PRESERVA: batch_archetype=CTM_HINT del paso 1
# SOBREESCRIBE: batch_archetype de contenido en el resto

# ── Paso 3: CTM entry points (requiere source/controlm/*.xls) ────────────────
python generators/load-ctm-to-brain.py
# Produce: ctm_jobs, batch_archetype=CTM_ENTRY para ~87 SPs matcheados por nombre
# PRESERVA: batch_archetype IN (CTM_ENTRY, CTM_HINT)
# SOBREESCRIBE: batch_archetype de contenido en SPs CTM confirmados

# ── Paso 4: Enriquecimiento D17-D49 ──────────────────────────────────────────
python generators/enrich-d17-d49.py
# Produce: UPDATE sps.biz para SPs D17-D49 sin descripción + INSERT rules
# No toca archetypes — siempre idempotente en cualquier orden post-paso 1

# ── Paso 5: ETB fine-mapping (solo cuando cambian capacidades — ~30 min) ─────
python generators/build-sp-fine-mapping.py
# Produce: tabla sp_capability_map en brain.db
# NOTA: la siguiente vez que corra build-brain.py, merge_fine_capabilities() 
#       la incorporará automáticamente vía INSERT OR IGNORE en sp_capabilities

# ── Paso 6: Output de análisis ────────────────────────────────────────────────
python generators/build-decoupling-cost.py    # → portal/data/decoupling-cost.json
```

### Reglas de preservación de marks

| Mark | Fuente | Preservado por |
|------|--------|----------------|
| `CTM_HINT` | `build-brain.py:mark_ctm_hints()` vía CTM brain.db | `classify-batch.py` (CASE WHEN) |
| `CTM_ENTRY` | `load-ctm-to-brain.py` vía Excel CTM | No sobreescrito por pasos posteriores |
| Arquetipos de contenido | `classify-batch.py` (FILE_LOADER/DATA_MAINT/…) | Se regeneran en cada corrida |

### Scripts de generación de datos (pre-requisitos del paso 1)

Los archivos JSON en `portal/data/` y `knowledge-base/` son **inputs** de `build-brain.py`, no outputs. Se generan con scripts separados cuando cambia el conocimiento:

| JSON / KB | Script generador |
|-----------|-----------------|
| `portal/data/callgraph-data.json` | `generators/mine-source.py` → `generators/extract-journeys.py` → `generators/build-catalog.py` |
| `portal/data/journeys-data.json` | `generators/extract-journeys.py` |
| `portal/data/business-rules-v3.json` | `generators/extract-rules-v2.py` → olas enriquecimiento (ola-a/b/c/d-enrich.py, enrich-rules-v3.py, extract-rules-d17-d49.py) |
| `knowledge-base/vocabulary-inventory.json` | `generators/build-vocab-inventory.py` |
| `portal/data/integrations-data.json` | manual / `generators/build-sp-architecture.py` |

### Reglas de código fuente — convención de naming y cobertura

**Regla universal**: todo archivo `.sql` en `source/informix/` es código fuente válido del sistema, independientemente del prefijo de nombre. El pipeline NO filtra por prefijo `sp_`.

| Propiedad | Regla |
|-----------|-------|
| **Naming de archivos fuente** | `{db}_{sp_name}.sql` — el primer segmento antes del primer `_` es la base de datos; el resto es el nombre del SP |
| **Cobertura del extractor activo** | `extract-rules-v2.py` y `extract-rules-d17-d49.py` usan `os.listdir(SRC)` + `.endswith(".sql")` — cubren TODO `source/informix/` sin filtro de prefijo |
| **SPs sin prefijo `sp_`** | `cargo_ref`, `abono_ref`, `califica_scoring2_cjunk`, `regex_match` son Almas válidas y están incluidas (el archivo existe como `{db}_cargo_ref.sql`, etc.) |
| **Extractor legacy `extract-rules.py` (v1)** | Contiene filtro `CALC.search(sp)` — solo cubría ~427 SPs financieros. **Supersedido** por v2. No usar para nuevas extracciones |
| **`mine-source.py`** | Lee `journeys-data.json`; construye path `{db}_{sp}.sql` y verifica existencia. No filtra por prefijo; depende de que el SP esté en el call graph |

**Señal `vsql` = comando shell/OS**: en SPL, la variable `vsql` (y variantes `cSql`, `cCmd`) frecuentemente contiene cadenas de comandos de sistema operativo (`dbaccess`, `gzip`, `tar`, `UNLOAD TO`, `echo`, `awk`, `grep`). Este patrón marca la regla como `clase=INFRAESTRUCTURA`. El `business_name` debe describir el **propósito del proceso shell** (ej. "Exportar tabla de cartera vencida a archivo plano para reporte CNBV"), no una fórmula financiera. Prohibido: "Calcular vsql: bdiburo ÷ resplogifx".

**Señal regulatoria en reglas INFRAESTRUCTURA**: el tag regulatorio (CNBV, Banxico, etc.) se hereda del SP, no se asigna por `tipo`/`clase`. Una regla `FÓRMULA + INFRAESTRUCTURA` con tag CNBV es semánticamente correcta si el SP genera reportes regulatorios — la regla infra ES el mecanismo de ejecución del proceso regulatorio.

**Component Spec:** [spec-spe-am-informix.md](spec-spe-am-informix.md) — especificación del componente Informix siguiendo §16 DC Universal Rules.

*Última actualización: 2026-08-14 · v2.1.0: **reglas de código fuente documentadas** — convención naming `{db}_{sp}.sql`; sin filtro `sp_*` en pipeline activo; señal `vsql`=comando shell/OS documentada; tag regulatorio en reglas INFRA explicado; extractor v1 marcado como legacy. v2.0.0: **pipeline canónico documentado + idempotencia corregida** — sección PIPELINE CANÓNICO DE REBUILD; `classify-batch.py` preserva CTM_HINT (CASE WHEN); `load-ctm-to-brain.py` overrides batch_archetype no-CTM (condición NOT IN); `external_systems` enriquecida con `error_codes`/`failure_rate`/`timeout_ms`; `build-sp-detail-pages.py` BASE path corregido (portal/generators/ → Informix/). v1.9.0: **triaje regulatorio D17-D49** — `triaje-d17-d49.py` eleva cobertura reg D17-D49 de 59% → **100%** (1,216/1,216); 515 referencias nuevas (CONSAR D20/AFORE, CNBV-Serie-R D36/Repaut, Banxico-UDI D41/Corresponsalía, CNBV-LRSIC D24/Buró, CNBV-PLD D25/Sitio-Especial, 21 dominios con defaults); 485 riesgos nuevos (FX D36, UDI D41, MONEY/DIV/ROUND transversal); portal regenerado (rules-catalog-bcop.html 2,798 grupos, 8,955 reglas 100% reg D17-D49). v1.8.0: **clasificación por naturaleza (barrido total)** — `classify-rule-nature.py` añade el campo `clase` ortogonal a `tipo`, distinguiendo 6,819 reglas de NEGOCIO genuinas (76%) de 2,136 no-negocio (1,958 INFRAESTRUCTURA shell/dbaccess/AIX · 101 ENSAMBLAJE_REPORTE SQL dinámico · 77 PRESENTACION); validado contra código fuente 99.98% (2/8,955 discrepancias); portal con filtro de clase + hero "Reglas de negocio". Hallazgo: el regex FÓRMULA capturaba ensamblaje de strings (cCmd/vsql/echo/UNLOAD) como si fueran fórmulas financieras; ahora separado. v1.7.0: **análisis vocab-anchored D17-D49** — `extract-rules-d17-d49.py` reemplaza las 25,165 reglas crudas IF/THEN por 1,216 reglas de negocio genuinas (797 FÓRMULA · 389 VALIDACIÓN · 30 UMBRAL; reg 59% · riesgo 36%), misma maquinaria que D01-D16; total catálogo 8,955 reglas (7,739 D01-D16 + 1,216 D17-D49); portal 2,798 grupos; hallazgo clave: cálculos ISR/interés en D28 Inversiones con riesgo base-año 360/365, inventario de tarjetas D18 vía DBACCESS shell/AIX. triaje-d17-d49.py movido a old/ (superseded). v1.6.2: Layer C+ SBVR D13-D16 aplicado — 209 reglas nuevas clasificadas (IVA, DBACCESS, PII-tarjeta, Cross-DB ref, códigos de error, FX); SBVR formal total: 1,012 (511 D01-D12 + 501 D13-D16); cobertura D16 88%. v1.6.1: BCOPBrain referencias corregidas — sp_capabilities 74,211 links (88.7% cobertura) · CTM_ENTRY=87 · CTM_HINT=18 · SBVR formal verificado 803 reglas D01-D12. v1.6.0: D17-D49 cargados en brain.db — 12,812 SPs totales (1,421 nuevos) · 32,904 reglas · 97.6% biz · ETB L3 68.5% fine-mapped · load-missing-domains.py (INSERT-capable para 19 dominios ausentes). v1.5.0 (2026-08-10): Layer B+ `business_name` enrichment — 1,883/1,969 nombres débiles mejorados con heurísticas SPL (enrich-names-local.py); 8,005 reglas (dedup definitivo); sp_capabilities 164,931 links (pre-rebuild). v1.4.0: 8,005 extraídas (mapping BDs secundarias corregido — 5,543 labels arreglados, 7 DBs sin cobertura añadidas); SPs actualizados a 11,391. v anterior 2026-08-07: Ontología v3.9 · 3 nuevos DTs inferencia: DT-Operacional-Batch, DT-Regulatorio, DT-Catálogo-Errores; total: 14 DTs · 17 SMEs*
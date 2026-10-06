# Delivery Playbook — Enterprise Brain
> Versión 1.0 · 2026-09-29 · Ecosistema Digital Core · Accenture México

## Lifecycle Variant: Brain Lifecycle

El Brain Lifecycle es una especialización del SDLC canónico de 8 fases para la construcción y operación de gemelos cognitivos de sistemas legacy. A diferencia de un microservicio, el "componente" entregado es conocimiento — estructurado, consultable y vivo. El valor no está en el código que se escribe sino en el código del cliente que se entiende.

---

## Fases del Brain Lifecycle

### Fase 1 — DISCOVER: Brain Bootstrap

**Objetivo**: crear el esqueleto del brain con evidencia inicial del sistema y establecer las dependencias cross-sistema conocidas.

**Entradas — DoR específico Enterprise Brain**:

- [ ] Acceso al código fuente del sistema en `source/code/` (al menos una muestra representativa)
- [ ] Identificación del tipo de sistema (togaf_type, togaf_state, togaf_abb)
- [ ] Selección del Specialist RE adecuado a la tecnología (SPL, COBOL, ABAP, PL/SQL, T-SQL, Java EE)
- [ ] Seeds de sistemas vecinos ingestados si existen (Regla B12)
- [ ] Nombre del sistema en vocabulario empresarial del cliente (si el bank-brain ya existe)

**Actividades**:

1. Crear estructura canónica de carpetas: `source/`, `digital-brain/`, `knowledge-base/`, `generators/`, `dt/`, `portal/`, `old/`.
2. Inicializar schema de brain.db con las tablas canónicas (components, rules, vocabulary, journeys, souls, etb_l3, cross_dependencies, external_systems, system_info).
3. Ejecutar extractor de componentes (mine-source.py o equivalente tecnológico).
4. Construir vocabulario inicial (Capa 1 — Lenguaje): ≥ 50 términos confirmados.
5. Identificar módulos funcionales / almas candidatos (Capa 2): ≥ 2 almas.
6. Emitir seeds iniciales (Regla B11) para sistemas vecinos conocidos.
7. Actualizar bank-brain (Regla B9) si el sistema ya fue descubierto desde otro brain.

**Salida — gate de salida**:

- brain.db con `status='building'` y schema completo
- Vocabulario Capa 1 con ≥ 50 términos
- Al menos 2 almas identificadas en `souls`
- Seeds emitidos en `digital-brain/seeds/manifest.json`

**SMEs involucrados**: Specialist RE de la tecnología del sistema · DBA (si base de datos propietaria) · Industry SME del cliente (vocabulario de negocio)

---

### Fase 2 — DESIGN: Knowledge Architecture

**Objetivo**: diseñar el schema del brain y el roster de Digital Twins antes de poblar masivamente. Evita reprocesamientos costosos si el diseño cambia a mitad del BUILD.

**Actividades**:

1. Definir taxonomía de negocio del cliente como hilo conductor (7 dominios → 24 subdominios → 67 capacidades → procesos → tareas).
2. Diseñar roster de DTs: cuántos, qué dimensión cubre cada uno, qué SMEs heredan.
3. Mapear al ETB (Enterprise Technology Blueprint) — 261 capabilities L3: qué L3 cubre este sistema.
4. Crear CLAUDE.md de cada DT con SMEs heredados declarados explícitamente.
5. Decidir si se requiere ADR por departures del schema canónico (nueva tabla, campo adicional obligatorio).
6. Estimar cobertura objetivo: N SPs/programas, N reglas esperadas, N dominios.

**Salida**:

- Taxonomía de negocio en `knowledge-base/taxonomy/` o `dt/dt-modelo-dominio/`
- Roster de DTs con CLAUDE.md de cada uno
- ADR-EB-NNN si hay decisiones de diseño no triviales
- ETB mapping inicial en el mapeo de building blocks del cliente, cuando exista

**SMEs involucrados**: Industry SME del cliente (taxonomía de negocio) · TS&T (si decisiones de target architecture se anticipan desde el brain)

---

### Fase 3 — BUILD: Brain Population

**Objetivo**: poblar las 4 capas del gemelo cognitivo con datos reales del sistema.

**Pipeline (extracción, enriquecimiento y carga)**:

```
Extracción (JSON crudo)
  ↓  extract-rules.py (o equivalente tecnológico)
Enriquecimiento (JSON enriquecido)
  ↓  enrich-rules.py — clase + reg + business_name LLM
Carga (brain.db vivo)
  ↓  build-brain.py — FTS5 + ATTACH-ready + ETB mapped + knowledge_lineage
```

Bronze, Silver y Gold no son etapas: son el nivel de calidad de cada afirmación (Regla B37). El código extraído entra gold por origen; lo que el enriquecimiento infiere entra silver hasta que el SME lo valida.

**Actividades por capa**:

| Capa | Actividad | Gate de salida |
|------|-----------|----------------|
| 1 — Lenguaje | Extracción de vocabulario → clustering semántico → cruce Regla V1 | ≥ N términos confirmados en vocabulary |
| 2 — Almas | Identificación de módulos funcionales por fan_in/fan_out → bautismo | Todas las almas con display_name de negocio |
| 3 — Biografía | Extracción de journeys desde call graph → narrativa de negocio | ≥ N journeys con display_name y description |
| 4 — Intención | Extracción → enriquecimiento (clase + reg + biz) → carga, con nivel B37 por campo | `COUNT(*) WHERE business_name IS NULL = 0` · D9 sin bloqueantes |

**Síntesis LLM scatter-gather** (para business_name — ADR-EB-004):

1. Exportar reglas con business_name vacío/débil a lotes de ~70-80 con `source_file`.
2. Por lote: un agente Lee el SP completo (no el fragmento), sintetiza el nombre, escribe JSON `{id: name}`.
3. Colectar → deduplicar → guardia anti-genérico → cargar en brain.db con `method='llm_synthesis_source_read'`.
4. Verificar: 0 vacíos, 0 genéricos, 0 tokens de código fuente, 0 errores factuales.

**Gate bloqueante para salir de BUILD**: `COUNT(*) WHERE business_name IS NULL = 0`

**SMEs involucrados**: Specialist RE · Industry SME (validación vocabulario y reglas) · Domain SME (taxonomía)

---

### Fase 4 — TEST: Brain Validation

**Objetivo**: garantizar la integridad del brain antes de activarlo. Un brain con datos incorrectos produce peores decisiones que no tener brain.

**DT-Validador — 9 dimensiones de validación**:

| Dimensión | Criterio de PASS |
|-----------|-----------------|
| 1. Schema integridad | Todas las tablas canónicas presentes y con las columnas correctas |
| 2. Coverage | % de componentes con datos ≥ umbral objetivo del sistema |
| 3. business_name quality | 0 vacíos · 0 genéricos · 0 tokens de código · 0 errores factuales verificables |
| 4. Regulación coverage | 100% de reglas con `reg` anotada (vacío válido si no aplica) |
| 5. Clase coverage | 100% de reglas con `clase` asignada |
| 6. Cross-references | Seeds emitidos · bank-brain actualizado si aplica |

**Gate de salida**: DT-Validador PASS — 0 errores, 0 advertencias bloqueantes

**SMEs involucrados**: Specialist RE (validación de muestras) · QA Equivalence (si el brain alimenta golden master tests de modernización)

---

### Fase 5 — RELEASE: Brain Activation

**Objetivo**: poner el brain a disposición del equipo de modernización como fuente de verdad.

**Actividades**:

1. Verificar DoD-EB-01 a DoD-EB-12 (checklist completo, incluidos linaje poblado y roster canónico de DTs).
2. Generar portal HTML: `python generators/build-portal.py` → `portal/` con el HTML generado (NUNCA hand-authored — Regla P4).
3. Actualizar bank-brain si existe: ATTACH el nuevo brain.db + actualizar `capabilities_consolidated()`.
4. Emitir seeds finales (Regla B11) — todos los sistemas externos conocidos con evidencia cuantificada.
5. Actualizar `component-catalog-enterprise-brain.md` con el nuevo deployment.
6. Cambiar `status` de `'building'` a `'active'` en `system_info`.
7. Comunicar al equipo de modernización: brain activo, cómo interrogarlo, DTs disponibles.

**Gate de salida**: DoD-EB-01 a DoD-EB-12 verdes · portal accesible · equipo informado

**SMEs involucrados**: SRE & AIOps (si el portal se hostea en cloud) · Software Engineering (integración brain-to-modernization-pipeline)

---

### Fase 6 — OPERATE: Brain-First Delivery

**Objetivo**: el brain gobierna las decisiones del equipo de modernización — es la fuente de verdad, no un artefacto de referencia opcional.

**Patrones de uso activo**:

- DTs interrogan brain para reglas de negocio antes de diseñar el microservicio target.
- Assessment 7R basado en `capability_gap()` del bank-brain — cuantitativo, no intuitivo.
- Golden master tests derivados de reglas en brain.db — equivalencia funcional verificable.
- Risk register alimentado desde brain: reglas de alta criticidad, MONEY rounding, regulación.
- Vocabulary del brain como lenguaje compartido entre equipo Accenture y cliente.

**Regla operativa**: si el equipo de modernización toma una decisión sin consultar el brain sobre el área afectada, es una deuda de conocimiento — documentar como `[BREAK-GLASS]` con owner.

---

### Fase 7 — OBSERVE: Brain Health

**Objetivo**: detectar brain stale, degradado o desalineado antes de que afecte decisiones de modernización.

**Métricas de salud canónicas**:

| Métrica | Definición | Umbral de alerta |
|---------|-----------|-----------------|
| `brain_freshness_days` | Días desde el último rebuild exitoso | > 30 días con cambios en source/ |
| `business_name_null_pct` | % de reglas sin business_name | > 0% |
| `coverage_pct` | % de componentes con datos completos | < 60% |
| `etb_version_alignment` | ¿Todos los brains usan el mismo ETB? | Cualquier desalineación |
| `dt_query_count` | Cuántas veces los DTs consultan el brain (proxy de utilidad) | < 1 consulta/semana = brain subutilizado |

**Cadencia de health check**: DT-Validador Capa 1 (automático en cada rebuild) + revisión semanal de `brain_freshness_days`.

---

### Fase 8 — ITERATE: Brain Evolution

**Objetivo**: mantener el brain vivo y alineado conforme el sistema legacy evoluciona y el conocimiento del equipo crece.

**Triggers de iteración**:

| Trigger | Acción |
|---------|--------|
| Nueva ola de código fuente del cliente | Cargar en source/ → rebuild pipeline → DT-Validador |
| Nuevo dominio descubierto (Regla B8 + B9) | Abrir estructura canónica → sembrar brain → seeds |
| ETB version bump | Realinear todos los brains afectados (Regla B3) |
| Vocabulario empresarial v{N+1} publicado | Volver a cruzar términos del sistema (Regla V1) |
| Nuevo sistema descubierto via seeds (Regla B10) | Knowledge Interlock — propagar a ambos extremos |
| business_name débil detectado post-release | Scatter-gather LLM sobre el lote afectado → reload |
| Corrección de error factual en un nombre | Reload puntual con `method='llm_synthesis_source_read'` |

**Principio de idempotencia (Regla P2)**: todo rebuild es seguro — INSERT OR IGNORE garantiza que los marks de alta confianza (CTM_ENTRY, CTM_HINT, nombres validados) no se pierden.

---

## Stack de Herramientas Canónicas

| Herramienta | Propósito | Fase |
|-------------|-----------|------|
| `mine-source.py` | Extractor de componentes (call graph, SPs) | BUILD |
| `extract-rules.py` | Extracción cruda de reglas | BUILD |
| `enrich-rules.py` | Enriquecimiento: clase, reg y business_name | BUILD |
| `build-brain.py` | Carga a brain.db (idempotente) con linaje B37 | BUILD (todas) |
| `generate-seeds.py` | Emisión de seeds para sistemas vecinos | BUILD/RELEASE |
| `build-portal.py` | Generación del portal HTML desde brain.db | RELEASE/ITERATE |
| `build-vocab-inventory.py` | Inventario de vocabulario del sistema | BUILD |
| `bootstrap-from-seeds.py` | Inicialización de estructuras desde seeds (bank-brain) | DISCOVER |
| `initialize-seed-brains.py` | Inicialización de brain.db mínimo desde seeds (Regla B12) | DISCOVER |
| DT-Validador | Health check del brain — 9 dimensiones | TEST/OBSERVE |

---

## Change Log

| Versión | Fecha | Descripción |
|---------|-------|-------------|
| v1.0 | 2026-09-29 | Creación inicial — Brain Lifecycle formalizado a partir de las implementaciones reales de BanCoppel (Informix, AppMóvil, Unity), Banamex (GemCog S500+S151), MONEX, Liverpool y AXA. |

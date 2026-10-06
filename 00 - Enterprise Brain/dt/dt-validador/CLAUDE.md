# DT-Validador — Digital Twin de Health Check del Enterprise Brain
> Component Delivery Agent · Enterprise Brain · Digital Core · Accenture México
> **[STATE: ACTIVE]** · Versión 1.0 · 2026-09-29

---

## Identidad

| Campo | Valor |
|-------|-------|
| Nombre | DT-Validador |
| Tipo | Meta-agente — Digital Twin transversal |
| Scope | Cualquier deployment del Enterprise Brain |
| Lifecycle phase | TEST (gate bloqueante) · OBSERVE (health check periódico) |
| Modo default | RUN |
| Owner | Enterprise Brain Agent (este asset) |

---

## Principio Rector

El DT-Validador **reporta, no corrige**. Su función es ejecutar las 9 dimensiones de validación sobre un brain.db y emitir un reporte estructurado con hallazgos — los cuales el equipo decide cómo resolver. No modifica el brain.db ni los archivos fuente.

Un brain que no pasa el DT-Validador **no puede activarse** (fase RELEASE bloqueada). Un brain ACTIVE que falla el DT-Validador en OBSERVE entra en estado STALE hasta que se corrija.

---

## SMEs Heredados

| Dimensión | SME responsable de resolver hallazgos |
|-----------|--------------------------------------|
| Schema integridad | Specialist RE de la tecnología del sistema |
| Coverage | Specialist RE + Domain SME |
| business_name quality | Specialist RE (scatter-gather LLM — ADR-EB-004) |
| Regulación coverage | Industry SME del cliente (bancario, seguros, etc.) |
| Clase coverage | Specialist RE + Domain SME |
| Cross-references | Enterprise Brain Agent |

---

## Las 9 Dimensiones de Validación

### Dimensión 1 — Schema Integridad

**Qué valida**: que el brain implementa el CORE completo más la extensión que le corresponde por `brain_type` (canon v2.0 — ADR-EB-006).

**Criterio de PASS**:

| Capa | Tablas exigidas | A quién aplica |
|------|----------------|---------------|
| CORE | `system_info` · `ontology_bindings` · `capabilities` · `processes` · `products` · `kpis` · `stakeholders` · `data_entities` · `technology_components` · `suppliers` · `itom_layer` · `cross_dependencies` · `signals` · `knowledge_gaps` · `knowledge_lineage` | Todo brain |
| SYSTEM | `components` · `component_calls` · `component_data` · `rules` · `rule_enrichment_log` · `vocabulary` · `journeys` · `component_capabilities` · `component_processes` · `regulatory_obligations` · `external_systems` | `brain_type='system'` |
| PROJECT | `applications` · `waves` · `risks` · `decisions` · `user_stories` | `brain_type='project'` |
| ENTERPRISE | `federated_brains` · `documents` | `brain_type='enterprise'` |
| PUENTE lado Change | `plateaus` · `transitions` · `readiness_gates` · `slos` | `brain_type='project'` (Regla B24) |
| PUENTE lado Run | `findings` · `slos` | `brain_type='system'` (Regla B24) |

D1 también verifica columnas recomendadas (hallazgo no bloqueante): `system_info.source_of_truth` (Regla B31 — corpus fuente declarado) y `system_info.build_agent` (Regla B29 — DT que construyó el brain). Si la columna existe pero está vacía, D1 lo reporta como advertencia.

El `brain_type` se lee de `system_info`. Si el brain aún no lo declara (pre-homologación), el validador lo infiere de `brain_meta` o de las tablas presentes y lo marca como inferido en el reporte.

**Hallazgo bloqueante**: tabla del CORE o de la extensión ausente, o columna crítica ausente (`business_name`, `clase`, `reg` en `rules`; `slug`, `brain_type`, `hemisphere` en `system_info`).

**Nota sobre vistas**: una `CREATE VIEW` con el nombre canónico satisface D1 igual que una tabla (Regla B16). Homologar por vista es la ruta por defecto para brains con corpus poblado.

---

### Dimensión 2 — Coverage

**Qué valida**: que el porcentaje de componentes con datos completos alcanza el umbral objetivo del sistema.

**Criterio de PASS**:
```sql
SELECT
    COUNT(*) as total,
    COUNT(CASE WHEN description IS NOT NULL AND description != '' THEN 1 END) as con_descripcion,
    COUNT(CASE WHEN primary_capability IS NOT NULL THEN 1 END) as con_etb,
    ROUND(100.0 * COUNT(CASE WHEN primary_capability IS NOT NULL THEN 1 END) / COUNT(*), 1) as etb_pct
FROM components;
-- etb_pct >= 60 para PASS (SLO-EB-03)
```

**Hallazgo no bloqueante si etb_pct < 60**: advertencia — no impide RELEASE pero registra deuda.

---

### Dimensión 3 — business_name Quality

**Qué valida**: que ninguna regla tiene business_name vacío, genérico o con tokens de código fuente.

**Criterio de PASS**:
```sql
-- Vacíos (BLOQUEANTE):
SELECT COUNT(*) FROM rules WHERE business_name IS NULL OR business_name = '';
-- Debe ser 0

-- Genéricos (BLOQUEANTE):
SELECT id, business_name FROM rules
WHERE business_name IN (
    'proceso', 'validación', 'cálculo', 'proceso de datos',
    'validación de registro', 'actualización de tabla'
)
OR LENGTH(business_name) < 10;

-- Tokens de código (BLOQUEANTE):
SELECT id, business_name FROM rules
WHERE business_name GLOB '*vl_*' OR business_name GLOB '*sp_*'
   OR business_name GLOB '*DEFINE*' OR business_name GLOB '*IF *';
```

---

### Dimensión 4 — Regulación Coverage

**Qué valida**: que todas las reglas tienen el campo `reg` anotado (vacío es válido cuando no aplica, NULL no lo es).

**Criterio de PASS**:
```sql
SELECT COUNT(*) FROM rules WHERE reg IS NULL;
-- Debe ser 0
-- reg='' (string vacío) es válido — significa "sin regulación aplicable"
-- reg=NULL significa "no revisado" — eso es el hallazgo
```

---

### Dimensión 5 — Clase Coverage

**Qué valida**: que todas las reglas tienen `clase` asignada a una de las 4 categorías canónicas.

**Criterio de PASS**:
```sql
SELECT COUNT(*) FROM rules WHERE clase IS NULL;
-- Debe ser 0

SELECT clase, COUNT(*) FROM rules GROUP BY clase;
-- Todos los valores deben ser: NEGOCIO | INFRAESTRUCTURA | ENSAMBLAJE | PRESENTACION
-- Cualquier otro valor es un hallazgo bloqueante
```

---

### Dimensión 6 — Cross-References

**Qué valida**: que los seeds están emitidos y el bank-brain está actualizado.

**Criterio de PASS**:
```sql
-- En system_info:
SELECT status FROM system_info;
-- Para RELEASE: status debe ser 'active' o 'building' (no 'discovered' ni 'seeded')

-- Seeds manifest debe existir:
-- digital-brain/seeds/manifest.json presente si hay sistemas externos en cross_dependencies
```

También verifica: `git check-ignore digital-brain/brain.db` retorna positivo (brain.db en .gitignore).

---

### Dimensión 7 — Process Linkage

**Qué valida**: que todo conocimiento dentro del brain está vinculado a un proceso de negocio (Regla B22). Un brain con conocimiento huérfano no puede activarse porque sus hallazgos no se pueden priorizar, agregar ni comparar.

**Tablas evaluadas**: `rules` · `vocabulary` · `capabilities` · `products` · `kpis` · `applications` · `risks` · `user_stories` · `regulatory_obligations` · `knowledge_gaps` · `journeys` · `transitions` · `findings` · `slos`.

**Criterio de PASS**:
```sql
-- Para cada tabla de conocimiento presente:
SELECT COUNT(*) FROM {tabla} WHERE process_id IS NULL;
-- Debe ser 0 en todas las tablas

-- La ontología de procesos debe estar cargada:
SELECT COUNT(*) FROM processes;
-- > 0 para PASS (scaffold sin procesos = hallazgo no bloqueante)
```

**Hallazgos bloqueantes**:
- Columna `process_id` ausente en una tabla de conocimiento.
- Filas con `process_id IS NULL` en cualquier tabla.

**Hallazgo no bloqueante**: tabla `processes` vacía (scaffold sin ontología de procesos cargada aún).

---

### Dimensión 8 — Puente Change–Run (cuerpo calloso)

**Qué valida**: que el brain implementa correctamente **su lado** del puente entre hemisferios (Regla B24 · ADR-EB-008). El cruce entre brains no lo valida esta dimensión; lo razona `templates/callosum.py` desde el enterprise brain.

| brain_type | Lado | Hallazgos bloqueantes |
|-----------|------|----------------------|
| `project` | Change → Run | `fate` fuera del canon (7R más encapsulate) · status inválido · transición sin `from_system`/`to_system` · plateau inexistente · transición en cutover o done sin `run_owner` o sin todos sus gates en done/waived |
| `system` | Run → Change | Severidad fuera del canon · `route_status` inválido · hallazgo marcado como ruteado sin `routed_to_brain` |
| `enterprise` | N/A | Razona el cruce con `callosum.py` |

**Hallazgos no bloqueantes**: SLOs sin `kpi_id`, porque el círculo TI-negocio no cierra (Regla B36, ambos lados); SLOs sin target (en el lado Change); hallazgos blocker o critical sin rutear (en el lado Run). En este segundo caso el validador no sabe, por sí solo, si tocan algo en transición: eso lo responde `callosum.py`.

```bash
# Razonar el cruce entre hemisferios
python templates/callosum.py --brain projects/unity/digital-brain/brain.db \
                             --brain systems/core/Informix/digital-brain/brain.db
python templates/callosum.py --enterprise bank-brain/digital-brain/bank-brain.db
```

---

### Dimensión 9 — Calidad y linaje del conocimiento

**Qué valida**: que cada afirmación del brain declara su nivel (gold, silver, bronze o rejected) y su fuente, y que ninguna decisión de gate se apoya en conocimiento que puede cambiar (Regla B37 · ADR-EB-010). Aplica a todo `brain_type`.

**Hechos irrefutables** que pueden entrar directo a gold sin HITL: `code`, `log`, `monitoring`, `job_run`, `regulation`, `signed_artifact`. Cualquier otra fuente llega a gold solo con `validated_by`.

**Hallazgos bloqueantes**:
- Tabla de conocimiento sin columna `tier`, o con valores fuera del canon.
- Transición en `cutover` o `done`, o readiness gate en `done`, que no es gold.
- Gold por origen cuya fuente no es un hecho irrefutable (salto indebido a gold).
- Gold por validación sin `validated_by`.
- Gold sin `source_ref`: un hecho irrefutable tiene que poder comprobarse.
- Fila marcada gold sin registro vigente en `knowledge_lineage` que la respalde.

**Hallazgos no bloqueantes**:
- Gold de código, log o monitoreo sin `source_version`: si la fuente cambia, el brain no sabrá degradarlo.
- Silver sin revisión en más de 90 días: va a la cola HITL (`brain.py hitl_queue()`).

**Métrica reportada**: distribución porcentual de gold, silver y bronze en todas las tablas de conocimiento, y número de registros de linaje.

---

## Formato de Reporte

El DT-Validador emite un reporte estructurado al final de cada ejecución:

```
DT-VALIDADOR REPORT
Sistema: {slug} · Build: {built_at} · Versión brain: {version}
══════════════════════════════════════════════════════════

[PASS/FAIL] D1 Schema Integridad    — {tablas} tablas presentes
[PASS/FAIL] D2 Coverage             — etb_pct: {N}% · components: {N}
[PASS/FAIL] D3 business_name        — {N} vacíos · {N} genéricos · {N} tokens
[PASS/FAIL] D4 Regulación           — {N} NULLs (debe ser 0)
[PASS/FAIL] D5 Clase                — {N} NULLs · {N} valores inválidos
[PASS/FAIL] D6 Cross-references     — seeds: {OK/MISSING} · gitignore: {OK/MISSING}
[PASS/FAIL] D7 Process Linkage      — processes: {N} · huérfanos: {N} en {N} tabla(s)
[PASS/FAIL] D8 Puente Change-Run    — transiciones: {N} · hallazgos: {N} · graves sin rutear: {N}

RESULTADO FINAL: {PASS / FAIL — N dimensiones bloqueantes}

Hallazgos bloqueantes:
  {lista de hallazgos con IDs afectados}

Hallazgos no bloqueantes:
  {lista de advertencias}
```

**PASS**: 0 dimensiones bloqueantes y 0 hallazgos bloqueantes.
**FAIL**: cualquier hallazgo bloqueante — impide activar el brain en RELEASE.

---

## Cuándo ejecutar

| Evento | Obligatorio |
|--------|------------|
| Gate de salida de fase TEST | Sí — bloqueante |
| Antes de cambiar `status` a `'active'` en system_info | Sí |
| Post-ITERATE (nueva ola de extracción) | Sí |
| Health check semanal en OBSERVE | Sí (puede correr en modo --summary sin detalle) |
| Antes de compartir el brain con el cliente | Sí |

---

## Invocación

```bash
# Gate completo (fase TEST):
python dt/dt-validador/validate.py --db digital-brain/brain.db --system informix

# Health check rápido (OBSERVE):
python dt/dt-validador/validate.py --db digital-brain/brain.db --summary

# Solo una dimensión:
python dt/dt-validador/validate.py --db digital-brain/brain.db --dim business_name

# Forzar el tipo cuando el brain aún no declara brain_type:
python dt/dt-validador/validate.py --db digital-brain/brain.db --brain-type project

# Salida JSON para agregar el estado de varios brains:
python dt/dt-validador/validate.py --db digital-brain/brain.db --json
```

**Exit codes**: `0` PASS · `1` FAIL (hallazgos bloqueantes) · `2` error de ejecución. Apto para usar como gate en CI.

El validador abre el brain.db en modo read-only (`mode=ro`) — no puede modificarlo ni por accidente.

---

## Baseline del estate

`baseline-2026-09-29.json` congela el resultado sobre los 16 brains con implementación real del estate al momento de adoptar el canon v2.0. En esa fecha el validador tenía seis dimensiones; hoy tiene 9, así que ese archivo solo es comparable en D1 a D6. Sirve para medir avance de la homologación en esas seis, no para D7, D8 ni D9.

**El baseline vigente quedó obsoleto con ADR-EB-011.** El CORE pasó a 15 tablas y D1 ahora exige también `suppliers`, `component_processes` y `documents`, así que los tres baselines existentes miden un canon anterior. Hace falta uno nuevo antes de usar cualquiera como medida de avance.

Al 2026-09-29 los 16 brains reprueban D1. Es el resultado correcto — mide la deuda real en vez de ocultarla.

---

## Anti-patrones

- **[ANTIPATRÓN]** Activar un brain (status='active') sin haber ejecutado el DT-Validador — un brain con datos incorrectos produce peores decisiones que no tener brain.
- **[ANTIPATRÓN]** Corregir los hallazgos editando directamente el brain.db con INSERT/UPDATE manual fuera del pipeline — la corrección debe ir al pipeline (enrich-rules.py → build-brain.py).
- **[ANTIPATRÓN]** Ignorar hallazgos no bloqueantes indefinidamente — cada advertencia ignorada es deuda de conocimiento. Documentar en el CLAUDE.md del sistema si hay razón para diferirla.

---

*DT-Validador · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*

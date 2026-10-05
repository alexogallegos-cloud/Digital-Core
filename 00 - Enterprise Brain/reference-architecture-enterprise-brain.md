# Reference Architecture — Enterprise Brain
> Versión 1.0 · 2026-09-29 · Digital Core · Accenture México

---

## Arquitectura de una Instancia (un sistema)

```
SOURCE LAYER                    BRAIN LAYER (SQLite)             CONSUMPTION LAYER
────────────                    ────────────────────             ─────────────────

source/
├── code/                       brain.db
│   (SPs · COBOL · ABAP  ──→   ├── system_info                  brain.py
│    PL-SQL · T-SQL ·           ├── components                   (Agent API)
│    Java EE · configs)         ├── rules                             │
├── docs/                       │   ├── clase                    ┌────┼─────────┐
│   (vendor docs ·              │   ├── reg                      ↓    ↓         ↓
│    specs · runbooks)          │   ├── riesgo                  DTs  Portal   bank-
└── ops/                        │   └── business_name           swarm (HTML)  brain
    (CTM · JCL · scripts)       ├── vocabulary
                                ├── journeys
PIPELINE:                       ├── souls
  extract-rules.py →            ├── etb_l3
  JSON crudo                    ├── cross_dependencies
      ↓                         └── external_systems
  enrich-rules.py →
  JSON enriq.
      ↓
  build-brain.py →
  brain.db (gold, silver y bronze marcados)
```

---

## Arquitectura de Federación (bank-brain = Enterprise Brain del cliente)

El **bank-brain** es el brain de nivel más alto del cliente (`brain_type='enterprise'`). Federa los dos hemisferios del cliente vía SQLite ATTACH:

```
{cliente}/
├── bank-brain/                          ← Enterprise Brain del cliente (nivel más alto)
│   ├── bank-brain.db                    ← SQLite ATTACH — federa Change + Run
│   ├── bank-brain.py                    ← Agent API federada
│   └── build-bank-brain.py             ← pipeline de construcción
│
├── projects/                            ← Hemisferio Change (Change the Business)
│   ├── exodus/digital-brain/brain.db   ← brain_type='project', hemisphere='change'
│   ├── can/digital-brain/brain.db
│   └── unity/digital-brain/brain.db
│
└── systems/                             ← Hemisferio Run (Run the Business)
    ├── core/informix/digital-brain/brain.db    ← brain_type='system', hemisphere='run'
    ├── channels/appmovil/digital-brain/brain.db
    └── integration/controlm/digital-brain/brain.db

  bank-brain.db — ATTACH de ambos hemisferios:
    -- Hemisferio Change
    ATTACH 'projects/exodus/digital-brain/brain.db' AS exodus
    ATTACH 'projects/can/digital-brain/brain.db' AS can
    -- Hemisferio Run
    ATTACH 'systems/core/informix/digital-brain/brain.db' AS informix
    ATTACH 'systems/channels/appmovil/digital-brain/brain.db' AS appmovil
         │
         ├── capabilities_consolidated()   ── UNION ALL etb_l3 de Change + Run
         ├── capability_gap()              ── L3 sin cobertura en ningún brain
         ├── capability_alignment()        ── brains con etb_version desalineada
         ├── system_dependencies()         ── grafo global de dependencias
         ├── change_inventory()            ── proyectos activos en Change
         └── run_inventory()              ── sistemas en producción en Run
```

---

## Extractores por Tecnología

| Tecnología | Extractor | Estado | Instancia de referencia |
|-----------|-----------|--------|------------------------|
| IBM Informix SPL | Specialist - Informix SPL | ACTIVE | BanCoppel EB-001 |
| Unisys COBOL/DMSII | Mainframe Migration SME | ACTIVE | Banamex EB-004 |
| SAP ABAP | Specialist - SAP ABAP | ACTIVE | Gentera SPE-AM-002 |
| Oracle Forms + PL/SQL | Specialist - Oracle Forms PL-SQL | PROPOSED | — |
| SQL Server T-SQL | Specialist - SQL Server T-SQL | PROPOSED | — |
| Java EE monolito | Software Engineering SME + análisis estático | via análisis | — |

**Principio de reutilización**: el método (las 4 capas del Gemelo Cognitivo) es constante e independiente de la tecnología. Lo que varía por tecnología es la **mecánica de extracción** — cómo parsear el código fuente para producir el JSON crudo. El pipeline de extracción, enriquecimiento y carga es siempre el mismo. Bronze, Silver y Gold designan la calidad de cada afirmación (Regla B37), no las etapas.

---

## Schema Canónico de brain.db (v2.0 — destilado)

**La fuente de verdad ejecutable es [`templates/schema.sql`](templates/schema.sql).**
Este documento no transcribe el DDL: un schema duplicado en prosa se desincroniza.

El canon v2.0 está destilado de los 16 brains con implementación real del estate
(ver ADR-EB-006). Reemplaza el schema aspiracional de 9 tablas de la v1.0, que
ningún brain implementaba.

### Estructura

Todo brain implementa **CORE + exactamente una extensión** según su `brain_type`.

| Capa | Tablas | Obligatoriedad |
|------|--------|---------------|
| **CORE** | `system_info` · `ontology_bindings` · `capabilities` · `processes` · `products` · `kpis` · `stakeholders` · `data_entities` · `technology_components` · `itom_layer` · `cross_dependencies` · `signals` · `knowledge_gaps` · `knowledge_lineage` | Todo brain, sin excepción |
| **SYSTEM** (`hemisphere='run'`) | `components` · `component_calls` · `component_data` · `rules` · `rule_enrichment_log` · `vocabulary` · `journeys` · `component_capabilities` · `regulatory_obligations` · `external_systems` | Solo `brain_type='system'` |
| **PROJECT** (`hemisphere='change'`) | `applications` · `waves` · `risks` · `decisions` · `user_stories` | Solo `brain_type='project'` |
| **ENTERPRISE** | `federated_brains` · `documents` | Solo `brain_type='enterprise'` |

El CORE cubre cuatro contratos: **identidad** (`system_info`), **ontología** (`ontology_bindings` + sus dos dimensiones), **federación** (`cross_dependencies` + `signals`) y **honestidad** (`knowledge_gaps`).

La ontología tiene dos dimensiones inseparables — ambas declaradas en `ontology_bindings`:

| Dimensión | Tablas | `model_type` | Fuente |
|-----------|--------|-------------|--------|
| **Definición del negocio** — qué es el negocio y cómo opera | `capabilities` · `processes` | `etb` · `bian` · `regulatory` · `value-chain` · `client-logical` | Industry SME |
| **Habilitador IT** — cómo IT entrega y opera lo que el negocio necesita | `itom_layer` | `itom` | SME IT Operating Model |

| `model_type` en uso | En |
|--------------------|----|
| `etb` | BanCoppel · Banamex · Liverpool · AXA |
| `bian` | Gentera · Banamex |
| `regulatory` | BanCoppel CAN · Santander CAN |
| `it-capability` | Unity |
| `value-chain` | Liverpool |
| `client-logical` | AXA P&C |

### Puente Change–Run (cuerpo calloso)

Además del CORE y de su extensión, cada brain implementa **su lado** del puente entre hemisferios (Regla B24 · ADR-EB-008):

| Lado | brain_type | Tablas |
|------|-----------|--------|
| Change → Run | `project` | `plateaus` · `transitions` · `readiness_gates` · `slos` |
| Run → Change | `system` | `findings` · `slos` |

El cruce no se copia entre brains. Lo razona el enterprise brain con `templates/callosum.py`, vía ATTACH, y produce seis tipos de ruptura. Ejemplos: un hallazgo de Run que toca algo que Change está migrando y nunca se ruteó, o una transición que Change da por terminada mientras Run sigue operando la entidad.

### Las tres ontologías no se confunden

| Tabla | Qué contiene | Pregunta que responde |
|-------|-------------|----------------------|
| `capabilities` | Modelo de capacidades de la industria | ¿Qué sabe hacer el negocio? |
| `processes` | Ontología de procesos de la industria | ¿Cómo debería operar? |
| `journeys` | Trazas reales por el call graph | ¿Qué hace de hecho el sistema? |

La brecha entre `processes` y `journeys` es **hallazgo de negocio**, no error de datos: un proceso sin journey que lo realice es capacidad declarada sin soporte en código; un journey sin proceso es funcionalidad no documentada.

El CORE es el contrato de interoperabilidad: es lo que un brain debe exponer
para que los demás puedan federarlo. Cada una de sus 4 tablas existe hoy en
producción en al menos 3 brains independientes.

### Por qué las ontologías divergen por tipo

Los brains de proyecto y de sistema modelan realidades distintas, y eso es
correcto. Cinco brains construidos de forma independiente (Exodus, Unity, CAN
BanCoppel, CAN Santander, payments-modernization MONEX) convergieron en
`applications`/`waves`/`risks`/`decisions` en lugar de `components`/`rules`.
El canon acomoda esa distinción en vez de forzar un molde único.

### Decisiones de homologación

| Concepto | Resolución | Razón |
|----------|-----------|-------|
| Identidad del brain | `system_info` tabular | Mayor base instalada (44 scaffolds) sobre `project_info`, `program_info`, `brain_meta`, `hemisphere_meta` |
| `cross_dependencies` | Modelo de perspectiva (`other_system` + `direction`) | Preserva autonomía del brain (Regla B1) — no requiere grafo global |
| Capabilities | `capabilities` con columna `ontology` | Conviven ETB, BIAN, RTL+FSV y ETB P&C. El canon fija la jerarquía, no el catálogo |
| Procesos | `processes` — tabla propia, L1-L4 + `lob` | La ontología de procesos es distinta por industria y **no se deriva** de la de capabilities (ADR-EB-007) |
| Nombre del brain de cliente | `{industria}-brain` | La semántica la determina la industria, no el cliente (ADR-EB-007) |
| `souls` | Retirada como tabla → `components.is_soul` | Cero brains la implementaban como tabla |
| Regulación | `system_info.regulator` configurable | El hook es universal; el regulador cambia (CNBV, CNSF, PROFECO) |

### Homologar sin reescribir: vista de compatibilidad

Para brains productivos con corpus poblado (Informix 90 MB, Banamex 122 MB) la
ruta por defecto **no es migrar datos**, sino el patrón validado en Banamex
(`risks` ← `hallazgos`): crear una vista con el nombre canónico sobre la tabla
histórica.

```sql
-- El brain de Informix expone la interfaz canónica sin tocar su pipeline
CREATE VIEW IF NOT EXISTS components AS
SELECT id, name, label AS display_name, biz AS description, domain,
       'sp' AS tipo, fan_in, fan_out, loc, is_soul, soul_rank,
       batch_archetype AS archetype
FROM sps;
```

Homologa la interfaz, preserva la inversión en el pipeline y es reversible.

---

## Frameworks de Referencia

| Framework | Uso en Enterprise Brain | Cuándo aplica |
|-----------|------------------------|---------------|
| TOGAF | Gobierno de la arquitectura: estructura (dominios BDAT), método (ADM) y gobierno. Envuelve a ETB e ITOM (Reglas B28 y B36) | Todo deployment |
| IT Operating Model (ITOM v9.0) | Cómo TI planea, entrega y opera la tecnología que habilita al negocio (`itom_layer`) | Todo deployment |
| ITIL 4 | Capa de prácticas dentro de ITOM: incidentes y problemas (`findings`), niveles de servicio (`slos`), cambio y liberaciones (`readiness_gates`) | Todo deployment, sobre todo Run |
| Taxonomía System-of-X (ADR-SPE-AM-008) | Clasificación del sistema en `togaf_type` (core, processors, channels, data, integration, compliance). Es taxonomía propia, no del metamodelo TOGAF | Todo deployment |
| BIAN Service Landscape v14 | Mapeo de dominios legacy a capabilities bancarias estándar (bian-mapping.json) | Clientes bancarios |
| ETB (Enterprise Technology Blueprint) | 261 capabilities L3 — lenguaje común de cobertura entre todos los brains | Todo deployment |
| ISO/IEC 5055:2021 | Evaluación de salud del código AS-IS (transversal Calidad — Code Quality Assessment SME) | DISCOVER en HVM AM/MM |
| Calidad y linaje del conocimiento (Gold/Silver/Bronze) | Nivel de certeza de cada afirmación; los hechos irrefutables entran directo a gold (Regla B37, ADR-EB-010) | Todo brain |
| SQLite FTS5 | Búsqueda fulltext sobre reglas y vocabulario | Todo brain activo |

---

## ADRs Canónicos del Asset

| ADR | Decisión | Estado |
|-----|---------|--------|
| ADR-EB-001 | SQLite como motor del brain (vs Postgres, MongoDB, vector DB) | APROBADO |
| ADR-EB-002 | brain.db en .gitignore — reconstruido desde pipeline | APROBADO |
| ADR-EB-003 | Federación via SQLite ATTACH (vs API runtime entre brains) | APROBADO |
| ADR-EB-004 | Síntesis LLM source-read como fuente de business_name (vs heurísticos) | APROBADO |
| ADR-EB-005 | Portal HTML generado siempre desde build-portal.py (prohibición de hand-authored) | APROBADO |
| ADR-EB-006 | Canon v2.0 destilado del estate (CORE + extensión por brain_type); retiro del schema aspiracional de 9 tablas | APROBADO |
| ADR-EB-007 | La industria determina la semántica del brain; nomenclatura `{industria}-brain`; ontología de procesos separada de capabilities | APROBADO |
| ADR-EB-008 | Cuerpo calloso: cada hemisferio declara su lado del puente Change–Run; el cruce lo razona `callosum.py` vía ATTACH | APROBADO |
| ADR-EB-009 | Estructura TOGAF en el CORE: `stakeholders`, `data_entities`, `technology_components`, `component_data` y `slos.kpi_id`; excepción acotada al principio de destilación | APROBADO |
| ADR-EB-010 | Calidad y linaje del conocimiento: gold, silver y bronze por afirmación; `knowledge_lineage` en el CORE; D9 | APROBADO |

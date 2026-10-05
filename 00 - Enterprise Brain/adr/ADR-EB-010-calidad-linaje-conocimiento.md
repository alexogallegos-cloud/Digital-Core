# ADR-EB-010 — Calidad y linaje del conocimiento: gold, silver y bronze

> Estado: **APROBADO** · Propuesto: 2026-10-02 · Aprobado: 2026-10-02 · Asset: Enterprise Brain · Digital Core

---

## Contexto

El brain razona sobre conocimiento de certeza muy distinta. Parte es irrefutable: la lógica que corre en el código productivo, lo que registran los logs, una regulación publicada o un objetivo estratégico firmado. Parte todavía puede cambiar: el estatus de un proyecto, un diseño funcional en ejecución o la hipótesis sobre la causa de un incidente. Y parte es volumen que nadie ha revisado: minutas, documentos crudos o exportaciones masivas.

El canon v2.0 no distinguía esos niveles. Cada brain resolvió una parte por su cuenta:

| Brain | Mecanismo | Qué resuelve | Qué le falta |
|-------|-----------|-------------|--------------|
| Varios | Columna `confidence` (confirmed, inferred, suspected) en `rules`, `component_processes`, `transitions`, `findings`, `stakeholders` y `component_data` | Certeza del enlace | Fuente y versión; "confirmed" con fuente secundaria no es irrefutable |
| Informix | `rule_enrichment_log`, 22,425 filas | Procedencia campo por campo: quién cambió qué y con qué método | Solo cubre reglas |
| Banamex | `documents`, corpus crudo con cero pérdida | El nivel bronze: nada del corpus se pierde | No distingue qué del corpus se volvió hecho |
| Liverpool y AXA | `seeded_by`, `fill_quality` | Procedencia y completitud del componente | Nivel de certeza |
| Canon | Regla P3, precedencia de marcas (ejecución real sobre inferencia sobre clasificador) | Una jerarquía de evidencia | Solo para marcas de batch |

Además, la Regla P1 usaba Bronze, Silver y Gold para nombrar etapas del pipeline. Con este ADR las mismas palabras pasan a designar calidad del conocimiento, así que P1 se corrige.

## Decisión

**1. Regla B37.** Cada afirmación del brain declara su nivel: gold, silver, bronze o rejected.

**2. Los hechos irrefutables entran directo a gold**, sin validación humana. Son seis tipos de fuente: código productivo, logs, monitoreo, ejecuciones de jobs, regulación publicada y artefactos firmados o aprobados. Una regulación no es debatible y un log representa la realidad que gobierna al negocio; en un artefacto firmado, la aprobación humana ya ocurrió. Todo lo demás llega a gold solo por validación de un rol con autoridad (HITL).

**3. El nivel es de la afirmación, no de la fuente.** El código es gold; el `business_name` que un LLM sintetizó de él es silver hasta que lo valide el SME. El linaje puede registrarse por campo.

**4. Schema:**
- Columna `tier` en las 29 tablas de conocimiento, por defecto `bronze`.
- Tabla `knowledge_lineage` en el CORE, que pasa de 13 a 14 tablas. Registra por afirmación: nivel, base del nivel, tipo, ubicación y versión de la fuente, quién afirmó, quién validó y qué la reemplazó.

**5. Gates por nivel.** Decommission, cutover o cierre de transición, readiness en `done` y afirmaciones de cumplimiento regulatorio exigen gold.

**6. Herramientas:**
- `build-brain.py`: `record_lineage()` rechaza en construcción los saltos indebidos a gold y el gold por validación sin validador.
- `brain.py`: `min_tier`, `tier_summary`, `lineage()` y `hitl_queue()`.
- DT-Validador: nueva dimensión D9, calidad del conocimiento.

**7. Corrección de P1.** Las etapas del pipeline se llaman extracción, enriquecimiento y carga.

## Consecuencias

- Los 16 brains del estate reprueban D9: ninguno tiene columna `tier`. Es deuda real. La ruta de homologación (B16) mapea `confidence` a un nivel inicial mediante vistas: `confirmed` con fuente primaria a gold, `inferred` a silver y `suspected` a bronze.
- La degradación de gold depende de `source_version`. Un gold de código o log sin versión genera aviso, porque si la fuente cambia el brain no sabrá degradarlo.
- Gold contra gold no se resuelve en automático: es un hallazgo del puente Change-Run (B24).
- La cola HITL deja de ser una lista plana. `hitl_queue()` prioriza lo que sostiene decisiones de gate, regulación y procesos que mueven KPIs.

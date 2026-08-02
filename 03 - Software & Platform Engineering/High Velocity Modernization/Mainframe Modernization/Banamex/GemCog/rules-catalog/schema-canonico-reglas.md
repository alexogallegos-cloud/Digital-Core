# Schema Canónico de Regla de Negocio — GemCog (efectivo)
> **Fuente:** template `source/2026-07-24_Propuesta_Schema_Reglas_Negocio.md` (solo lectura) + enmiendas de alineación al modelo canónico BC-XX.
> **Estado:** ratificado 2026-07-24 · aplica a los 33 archivos de `rules-catalog/`.
> **Representación:** tabla Markdown `| **Campo** | valor |` (preserva build-traceability.py y render-rules-report.py). NO YAML.

---

## Enmiendas sobre el template (por qué este archivo y no el de source/)

El template en `source/` es correcto en fondo pero precede al pivote BC-XX. Tres correcciones lo alinean al modelo canónico vigente:

1. **`bc_id` es la clave primaria de capacidad** (BC-01..BC-23), no BIAN. Se inyecta cruzando el programa ejecutor contra `program-registry-s500.md` / `program-registry-s151.md`.
2. **BIAN baja a `bian_ref`** (campo de referencia). El template lo llamaba `capacidad_bian` y lo derivaba de `bian-mapping-*`, hoy `[DEPRECATED]`. La fuente de derivación es el **program-registry**.
3. **`dataset_dmsii`** explícito (BD10MOVDIA151, BD11SDOS151, BD99CONTROL…) — clave para data-lineage en DMSII; el template lo diluía en `campos_cobol`.

El template en `source/` permanece intacto como registro del autor.

---

## Campos canónicos (M = obligatorio · R = recomendado · O = opcional)

### A. Identidad y ciclo de vida
| Campo | M/R/O | Origen en homologación |
|-------|-------|------------------------|
| **Identificador** | M | del heading `### RN-S{sys}-{nnn}` |
| **Nombre** | M | del título del heading |
| **Versión** | M | nueva — `v1` en la primera homologación |
| **Estado ciclo** | M | Borrador / En validación / Validado / Obsoleto — de `Estado validación` previo |
| **Fecha actualización** | M | fecha de homologación (ISO) |

### B. Contenido de negocio (SBVR)
| Campo | M/R/O | Origen |
|-------|-------|--------|
| **Descripción** | M | reusar la existente; depurar jerga COBOL (la mecánica va a Pseudocódigo) |
| **Tipo regla** | M | **NUEVO** — clasificar: Restricción · Derivación · Cálculo · Habilitación · Clasificación |
| **Condición** | R | derivar de `Trigger` + código |
| **Consecuencia** | R | derivar del código |
| **Excepciones** | O | si aplica |

### C. Clasificación y contexto (alineado a BC-XX)
| Campo | M/R/O | Origen |
|-------|-------|--------|
| **BC-ID** | M | **NUEVO — clave primaria** · inyectar desde program-registry por programa |
| **bian_ref** | R | referencia BIAN · del program-registry (antes `Capacidad bancaria` / `Base regulatoria`) |
| **Flujo actividades** | R | journey funcional derivado de la capacidad |
| **Tipo técnico** | O | etiqueta de riesgo multi-valor — del campo `Tipo` previo (`[LÓGICA-CONTABLE]`, `[HARDCODE-SOSPECHOSO]`…) |
| **Regulador** | R | Banxico / CNBV / CONDUSEF / — |
| **Base regulatoria** | O | norma/artículo específico |

### D. Evidencia y trazabilidad al código
| Campo | M/R/O | Origen |
|-------|-------|--------|
| **Programa ejecutor** | M | del campo `Programa(s)` — el que ejecuta, nunca el copybook |
| **Evidencia código** | M | `archivo:línea` EXACTA de fuente sin expandir · de `Traza de código` (elevar de ~aprox a exacto al validar) |
| **Copybook fuente** | M si aplica | copybook con `archivo:línea` + programas que hacen COPY |
| **Dataset DMSII** | R | **NUEVO** · datasets accedidos (BD10, BD11, BD99…) |
| **Campos COBOL** | R | de la tabla `Campos involucrados` |
| **Vocab ref** | R | de la tabla `Vocabulario en la fórmula` (Capa 1) |
| **Sistemas downstream** | O | archivos/sistemas que reciben el resultado |
| **Pseudocódigo** | O | de `Traza de código` (bloque técnico) |

### E. Validación y gobernanza (HITL)
| Campo | M/R/O | Origen |
|-------|-------|--------|
| **Veredicto** | M | VALIDADO · DRIFT · RECHAZADO · INFERIDO · PENDIENTE SME · DUDOSO |
| **Confianza** | M | alta / media / baja — existente |
| **Validado por Lead** | R | Lead + fecha |
| **Validado por SME** | R | SME + fecha |
| **Nota Lead** | O | — |
| **Nota SME** | O | — |

### F. Trazabilidad de proceso
| Campo | M/R/O | Origen |
|-------|-------|--------|
| **Tarea flujo** | R | tarea de Capa 4 (task-process-rules-index.md) |
| **Reglas relacionadas** | O | IDs ligados |

---

## Convenciones de llenado obligatorias

1. **Descripción en lenguaje de negocio** — sin nombres de párrafo ni campos COBOL; eso va en Pseudocódigo / Campos COBOL / Evidencia código.
2. **Evidencia código siempre `archivo:línea`** de fuente **sin expandir**. Sin ancla exacta, el veredicto máximo es `INFERIDO`.
3. **Cuando el código viene de un COPY**: indicar el copybook (con `archivo:línea`) en Copybook fuente Y los programas que lo llaman en Programa ejecutor. Un copybook no se ejecuta solo.
4. **Programa ejecutor** = el/los que corren la regla; nunca un copybook ni el nombre del volcado.
5. **BC-ID derivado del program-registry**, no de bian-mapping deprecado.
6. Toda edición incrementa **Versión** y actualiza **Fecha actualización**.
7. **Ningún campo se inventa, ningún hueco se deja muerto.** Lo que no se deriva del código ni del conocimiento ya generado se expresa como **consulta dirigida**: `Consulta [SME destino]: [pregunta concreta de análisis]`. El hueco es trabajo pendiente con dueño y pregunta, no un valor supuesto ni un simple "pendiente".

---

## Ruteo de gaps a SME (para complementar, no inventar)

Los `dt-*` del swarm **preparan** la consulta (extraen la evidencia, formulan la pregunta); el **SME** (exclusivamente en `SME/`) la responde. Ver handoffs en `Mainframe Modernization/CLAUDE.md`.

| Tipo de hueco | Quién lo prepara (swarm) | SME que complementa | Ejemplo de pregunta |
|---------------|--------------------------|---------------------|---------------------|
| Rationale de negocio / "por qué" | dt-banking-domain | SME Platform · Unisys Banking | ¿Por qué SPEI en MXN se registra sin dimensión banco? |
| Requisito regulatorio (norma, artículo) | dt-banking-domain | SME Regulatorio (Banxico / CNBV) | ¿El registro sin banco responde a un requisito de reporte SPEI de Banxico? |
| Reclasificación BC-ID en confianza BAJA | dt-mainframe-analyst | SME Mainframe Migration (advisory) | ¿La lógica de P167 corresponde a Depósitos o a Pagos? |
| Mapeo Tarea flujo (Capa 4) | dt-knowledge-curator | análisis interno vs task-process-rules-index.md (no SME) | ¿A qué tarea del flujo nocturno pertenece esta regla? |
| Equivalencia funcional target | dt-qa-engineer | SME Equivalence Testing | ¿El golden-master replica este redondeo? |

**Estados de gap admitidos** (en lugar de un valor inventado):
- `Consulta [SME]: [pregunta]` — requiere SME externo.
- `Análisis interno: [fuente a revisar]` — se resuelve con artefactos ya generados (vocab, task-index, program-registry).
- `INFERIDO` — hipótesis explícita del swarm, marcada como tal, nunca presentada como hecho.

---

## Mapeo determinista formato viejo → canónico (para el script de homologación)

| Campo viejo (cualquier variante) | Campo canónico |
|----------------------------------|----------------|
| `Sistema` / `Identificador` | Identificador (ID) + Nombre (título) |
| `Tipo` (`[ETIQUETA]`) | Tipo técnico |
| `Base regulatoria` / `Regulador` | Regulador + Base regulatoria |
| `Programa(s)` / `Programa(s) fuente` / `Programa` | Programa ejecutor |
| `Capacidad bancaria` (código BIAN) | bian_ref (+ derivar BC-ID) |
| `Confianza` | Confianza |
| `Trigger` | Condición |
| `Campos involucrados` (tabla) | Campos COBOL |
| `Traza de código` (bloque) | Evidencia código + Pseudocódigo |
| `Vocabulario en la fórmula` (tabla) | Vocab ref |
| `Estado validación` | Estado ciclo + Veredicto |
| _(no existía)_ | **BC-ID · Tipo regla SBVR · Dataset DMSII · Versión · gobernanza HITL** ← generar |

---

## Fases de homologación

- **Fase mecánica (script):** renombrar campos, inyectar BC-ID + bian_ref desde program-registry, sembrar Versión/Fecha/Veredicto=PENDIENTE SME. Reversible, sin re-lectura de fuente.
- **Fase de enriquecimiento (swarm):** Tipo regla SBVR, Condición/Consecuencia, elevar Evidencia código a línea exacta, Dataset DMSII, validación HITL. Requiere `dt-mainframe-analyst` + `dt-banking-domain` leyendo `source/`.

---

*Creado: 2026-07-24 · rules-catalog/ · aplica el template de source/ con enmiendas BC-XX · gobernado por swarm/dt-knowledge-curator*

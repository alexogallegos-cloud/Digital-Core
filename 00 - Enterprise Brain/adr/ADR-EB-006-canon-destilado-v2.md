# ADR-EB-006 — Canon destilado del estate (v2.0) y retiro del schema aspiracional v1.0

> Estado: **APROBADO y ENMENDADO** · Fecha: 2026-09-29 · Enmendado: 2026-10-05 · Asset: Enterprise Brain · Digital Core

---

## Enmiendas posteriores

**Su decisión de fondo sigue vigente**: el canon se destila de la evidencia del estate, y un brain implementa el CORE más exactamente una extensión según su `brain_type`. Ese principio no cambió y es el que todavía gobierna.

Lo que sí cambió son las cifras y una resolución específica. Cuatro decisiones posteriores alteraron la estructura que este ADR fijó, y hasta esta enmienda no tenían enlace de regreso, de modo que un lector del ADR fundacional se llevaba un canon de hace una semana:

| Qué dice este ADR | Qué rige hoy | Dónde se cambió |
|-------------------|--------------|-----------------|
| CORE de **4 tablas** | CORE de **15 tablas** | ADR-EB-007, ADR-EB-009, ADR-EB-010 y ADR-EB-011 |
| `capabilities` en la extensión SYSTEM | `capabilities` es CORE | ADR-EB-007 |
| Canon de **21 tablas** | Canon de **38 tablas**, incluida la capa del puente Change-Run | ADR-EB-008 y posteriores |
| El CORE se justifica solo por destilación, con 3 brains o más | El CORE tiene **dos fundamentos**: destilación, e implicación del roster canónico de DTs | ADR-EB-011 |
| **Medallion se degrada a patrón recomendado** | **Medallion se retiró.** Su vocabulario se reasignó | ADR-EB-010 y Regla P1 |

La última fila es la más importante y se detalla abajo, en la resolución 5.

---

## Contexto

El asset Enterprise Brain nació documentando un schema canónico de 9 tablas
(`system_info`, `components`, `rules`, `vocabulary`, `journeys`, `souls`,
`etb_l3`, `cross_dependencies`, `external_systems`) y un pipeline obligatorio
Medallion Bronze → Silver → Gold.

Ese canon se escribió de arriba hacia abajo, antes de auditar las
implementaciones existentes. La auditoría de los 16 brains con implementación
real del estate (BanCoppel, Banamex, MONEX, Santander, Liverpool, AXA, Coppel,
Gentera) mostró que el canon v1.0 no describe la realidad:

| Afirmación del canon v1.0 | Evidencia del estate |
|--------------------------|---------------------|
| Tabla `souls` | **0 de 16 brains** la tienen. Informix la modela como columna `is_soul` |
| Pipeline Medallion obligatorio | **0 de 16 brains** lo implementan. Liverpool lo intentó sobre JSON de portal y nunca construyó Silver |
| Tabla `journeys` | Solo Informix. AXA la modela mejor como `process_steps` L1→L4 |
| `vocabulary_fts` | Solo Coppel-ecommerce |
| Tabla `etb_l3` | Conviven 4 ontologías incompatibles: ETB banca, RTL+FSV retail, BIAN, ETB P&C seguros |
| `system_info` como nombre único | **5 nombres en uso**: `system_info`, `project_info`, `program_info`, `brain_meta`, `hemisphere_meta` |
| `cross_dependencies` con una firma | **3 firmas incompatibles** (modelo de perspectiva vs. modelo de arista) |

Además, la auditoría reveló un hecho estructural que el canon v1.0 no
contemplaba: **los brains de proyecto y los de sistema tienen ontologías
genuinamente distintas**. Exodus, Unity, CAN (BanCoppel), CAN (Santander) y
payments-modernization convergieron de forma independiente en
`applications` / `waves` / `risks` / `decisions` / `user_stories`, no en
`components` / `rules`. Cinco brains construidos por separado llegando al mismo
modelo no es divergencia: es una señal de canon.

Un canon que ningún brain cumple no gobierna nada — solo produce un gate que
todos reprueban por razones equivocadas.

---

## Decisión

Se retira el canon v1.0 y se adopta el **canon v2.0, destilado de la
evidencia**, con esta estructura:

**CORE (4 tablas) — obligatorio en todo brain, sin excepción:**
`system_info` · `cross_dependencies` · `signals` · `knowledge_gaps`

Cada una existe hoy en producción en al menos 3 brains independientes. Son el
contrato de interoperabilidad: lo que un brain debe exponer para que los demás
puedan federarlo.

> **[ENMIENDA 2026-10-05]** El CORE son hoy **15 tablas**. Creció con ADR-EB-007
> (ontología por industria), ADR-EB-009 (dominios D y T de TOGAF, más
> stakeholders), ADR-EB-010 (linaje del conocimiento) y ADR-EB-011 (`suppliers`).
> La lista vigente está en la Regla B15 y el DDL en `templates/schema.sql`.
> El criterio de "al menos 3 brains" también se extendió: ADR-EB-011 agregó un
> segundo fundamento, la implicación del roster canónico de DTs.

**Extensión por `brain_type` — un brain implementa CORE + exactamente una:**

| brain_type | Tablas | Referencias del estate |
|-----------|--------|-----------------------|
| `system` | components, component_calls, rules, rule_enrichment_log, vocabulary, journeys, ~~capabilities~~, component_capabilities, regulatory_obligations, external_systems | Informix, Banamex, Gentera, Coppel |

> **[ENMIENDA 2026-10-05]** `capabilities` dejó de ser extensión SYSTEM y pasó al
> CORE con ADR-EB-007: todo brain ancla su ontología de negocio, incluidos los de
> proyecto, para los que es el modelo contra el cual se mide el cambio (Regla B21).
> La extensión SYSTEM suma además `component_data` y `component_processes`.
| `project` | applications, waves, risks, decisions, user_stories | Exodus, Unity, CAN ×2, payments-modernization |
| `enterprise` | federated_brains, documents | bank-brain, MONEX, Liverpool, AXA, Santander |

El schema ejecutable vive en `templates/schema.sql` y es la única fuente de
verdad. Ningún documento vuelve a transcribir el DDL: los documentos apuntan al
archivo.

### Resoluciones de homologación específicas

1. **Identidad → `system_info`** (tabular, no k/v). Gana por base instalada: es
   el nombre de los 33 scaffolds de BanCoppel y los 11 de MONEX.

2. **`cross_dependencies` → modelo de perspectiva** (`other_system` +
   `direction`), no modelo de arista (`source_system` + `target_system`). Razón:
   preserva la autonomía del brain (Regla B1) — cada brain declara lo que ve
   desde sí mismo sin necesitar el grafo global. `dependency_type` gana sobre
   `relationship`.

3. **`etb_l3` → `capabilities` con columna `ontology`.** El canon fija la
   estructura jerárquica L1/L2/L3, no el catálogo. Lección de Liverpool
   (RTL+FSV), Gentera (BIAN) y AXA (ETB P&C): la ontología es un atributo
   configurable del cliente, no parte del schema.

4. **`souls` se retira como tabla** → `components.is_soul` + `soul_rank`.

5. **Medallion deja de ser obligatorio.** Se degrada a patrón recomendado para
   brains que extraen de código fuente. La invariante real del estate es otra y
   sí se eleva a canon: `source/` → `knowledge-base/` → `digital-brain/`,
   presente en los 6 brains maduros.

   > **[ENMIENDA 2026-10-05 — la corrección más importante de este ADR]**
   > Medallion **no se degradó: se retiró**, y su vocabulario se reasignó a otra
   > cosa. Desde ADR-EB-010 y la Regla B37, las palabras gold, silver y bronze
   > designan **niveles de certeza del conocimiento**, no etapas de un pipeline:
   > gold es el hecho irrefutable y comprobable, silver lo que tiene fuente pero
   > aún puede cambiar, y bronze el volumen que espera validación humana.
   >
   > Las etapas del pipeline se llaman hoy **extracción, enriquecimiento y
   > carga** (Regla P1). Leer esta línea sin la enmienda es peligroso justamente
   > porque las palabras siguen existiendo y hoy significan algo distinto: quien
   > la siga creyendo que Medallion es recomendado estará usando el vocabulario
   > de la calidad del conocimiento para nombrar fases de un proceso.

6. **`regulator` e `industry` entran a `system_info`.** Lección de AXA: el hook
   regulatorio es universal; lo que cambia es el regulador (CNBV banca, CNSF
   seguros, PROFECO retail). El canon no puede asumir banca.

### Lo mejor de cada brain, promovido a canon

| Origen | Aporte |
|--------|--------|
| Informix | `knowledge_gaps` — el brain como su propio backlog; `hemisphere_meta` → `system_info.hemisphere`; `rule_enrichment_log` como provenance campo-por-campo |
| Banamex | Principio anti-invención: ningún hueco se deja muerto, se expresa como consulta dirigida a un SME. `documents` + FTS como red de cero pérdida |
| Exodus | `origin_artifact` por fila; `reconciliation()` como validación anti-cifras-fabricadas |
| Gentera | `rules.linea` — trazabilidad a nivel de línea de código; `component_calls` como grafo |
| Liverpool | `seeded_by` + `fill_quality` (procedencia y completitud del dato); ontología de capabilities en 2 capas |
| AXA | `journeys` jerárquico L1→L4 con FK a capability y a regla; `regulator` configurable |
| Coppel | `current_platform`/`target_platform`/`migration_status`; `decisions` como ADR dentro del brain |
| AppMóvil | `signals` como bus entre brains; idempotencia dura por DROP explícito |
| MONEX | `federated_brains` con `brain_path` + `brain_attached` como control de salud de la federación |

---

## Consecuencias

**Positivas**
- El canon es verificable: `dt/dt-validador/validate.py` lo ejecuta contra
  cualquier `brain.db` y emite PASS/FAIL por dimensión.
- La homologación pasa de opinión a medición. El baseline del estate al
  2026-09-29 está congelado en `dt/dt-validador/baseline-2026-09-29.json`.
- Los brains de proyecto dejan de reprobar por no tener `rules`: el validador
  marca N/A las dimensiones que no aplican a su ontología.

**Negativas / costo asumido**
- Los 16 brains reales reprueban el gate hoy. Es el resultado correcto: mide la
  deuda real, no la oculta.
- Homologar implica renombrar tablas en brains productivos de 90 MB y 122 MB.
  Se adopta el **patrón de vista de compatibilidad** de Banamex (`risks` ←
  `hallazgos`): el brain crea una `CREATE VIEW` con el nombre canónico sobre su
  tabla histórica. Homologa la interfaz sin reescribir el pipeline ni migrar
  datos. Es la ruta por defecto para todo brain con corpus poblado.

**Neutras**
- El canon v2.0 es más grande (21 tablas vs. 9), pero ningún brain implementa
  las 21: implementa CORE (4) + su extensión.

  > **[ENMIENDA 2026-10-05]** El canon son hoy **38 tablas**: CORE 15, SYSTEM 11,
  > PROJECT 5, ENTERPRISE 2 y la capa del puente Change-Run con 5 (ADR-EB-008).
  > El principio no cambió, solo las cifras: ningún brain implementa las 38, sino
  > el CORE más su extensión más su lado del puente.

---

## Alternativas consideradas

- **Mantener el canon v1.0 y migrar los 16 brains hacia él.** Rechazada: exige
  reescribir pipelines maduros y productivos para adoptar tablas que la práctica
  ya demostró innecesarias (`souls`) o mal modeladas (`etb_l3` mono-ontología).

- **No tener canon; que cada brain defina su schema.** Rechazada: la federación
  (ADR-EB-003) requiere un contrato mínimo compartido. Sin `cross_dependencies`
  homologada, el `ATTACH` no compone.

- **Canon por cliente en vez de por `brain_type`.** Rechazada: la auditoría
  muestra que la variación real sigue al tipo de trabajo (change vs. run), no al
  cliente. Exodus (BanCoppel) se parece más a payments-modernization (MONEX) que
  a Informix (BanCoppel).

---

*Supersede: el schema de 9 tablas documentado en `reference-architecture-enterprise-brain.md` v1.0 y en `CLAUDE.md` §Componentes.*

*Enmendado por: ADR-EB-007 (ontología por industria), ADR-EB-008 (puente Change-Run), ADR-EB-009 (estructura TOGAF en el CORE), ADR-EB-010 (calidad y linaje del conocimiento) y ADR-EB-011 (roster canónico de DTs). Las enmiendas corrigen cifras y una resolución; el principio de destilar el canon de la evidencia sigue vigente.*

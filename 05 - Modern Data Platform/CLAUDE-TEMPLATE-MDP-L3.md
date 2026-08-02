# {Sub-Offering L3} — Sub-Offering Delivery Agent (Modern Data Platform / AI-ready Data)

> Hereda `AGENTES-UNIVERSAL-RULES-DC.md` (Digital Core) + el `CLAUDE.md` del offering domain **AI-ready Data** (`../CLAUDE.md`) + el `CLAUDE.md` del offering **05 Modern Data Platform** (L1).
> Por referencia, la capa COMÚN `AGENTES-UNIVERSAL-RULES-CORE.md` (fuente única de reglas comunes).
> Zona: ★ Digital Core · Offering: 05 Modern Data Platform · Offering domain: **AI-ready Data** · Nivel: **L3 Sub-Offering** · Lifecycle: **DataOps** (instanciado por solution L4).
> Ubicación canónica: `05 - Modern Data Platform/AI-ready Data/{Sub-Offering L3}/CLAUDE.md`.

```
┌─[★ Digital Core]──────────────────────────┐
│ {Sub-Offering L3 name}                    │
│ {tipo entregable} · DataOps · {stack}     │
└───────────────────────────────────────────┘
```

---

## Identidad y Perfil

{2-3 frases · qué problema de datos resuelve este sub-offering · perfil del lead técnico equivalente · alcance frente al offering padre 05 y frente a otros sub-offerings L3 de AI-ready Data}

**Honestidad técnica vs. marketing del slide**: el slide oficial enmarca todo "using AI/Agents" (AI-Accelerated, Data Agents, Knowledge Agents, Autonomous Ops). El cuerpo del documento debe declarar **el límite real** de esa autonomía — qué acelera el AI/agente (extracción de schema, generación de dbt, profiling, reconciliación) vs. qué exige juicio humano y firma de Data Steward (aprobar contract, breaking schema change, política de PII, scope regulatorio). No copiar el marketing sin matizar el % de aceleración real vs. reemplazo.

**Lo que NO hago**: ejecuto el delivery técnico end-to-end (escribir el pipeline dbt, el job Flink, la ontología concreta). Delego al SME canónico de `SME/` vía `[INVOKE]` siguiendo §13 de DC Universal Rules. Mi rol es gobernar el lifecycle DataOps específico de este sub-offering, mantener el catálogo de data products / migraciones, y validar gates de calidad y contrato.

---

## Principio Rector

> **{Una frase declarativa que captura la tensión central del sub-offering — qué se rompe silenciosamente downstream si se cede en la disciplina del contrato/lifecycle de datos}**

{Cuando el cliente / equipo data empuja a saltarse el principio, di la verdad antes de ejecutar: ofrecer dos rutas — cumplir el gate (contract + DQ + lineage) vs. documentar excepción con `[BREAK-GLASS]` firmado por Data Steward + owner del riesgo downstream + fecha de remediación ≤ 24 hrs.}

---

## Estado del Sub-Offering

Declarar madurez para que Sales sepa qué comprometer:

| Aspecto | Valor |
|---------|-------|
| Madurez | `[STATE: PROPOSED \| APPROVED \| ACTIVE \| ON-HOLD]` |
| Solutions L4 con deals firmados | {lista · `NINGUNO` si greenfield} |
| Última actualización del lifecycle | {YYYY-MM-DD} |

---

## Alcance del Sub-Offering — Solutions L4 que Gobierna

> Los solutions L4 son **los del slide oficial AI & Data L1-L4** (ver `source/ai-data-offering-architecture-L1-L4.md`). No inventar solutions fuera del slide; si emerge una necesidad nueva, marcarla `[PROPUESTO]` y abrir CR.

| Solution L4 (slide oficial) | Tipo de entregable | SME canónico que ejecuta delivery |
|-----------------------------|--------------------|------------------------------------|
| **{Solution 1}** | {pipeline · data product · migración · ontología · runbook DataOps} | `SME/{ruta}/` |
| **{Solution 2}** | ... | `[GAP — crear o asignar SME]` si no existe SME canónico aún |

**Regla**: si un solution L4 no tiene SME canónico en `SME/`, declararlo explícitamente como `[GAP — crear o asignar]` con owner del gap. **No improvisar** delivery sin SME asignado — el sub-offering no puede comprometer ese solution hasta resolverlo.

Cada solution L4 instancia el lifecycle DataOps del offering 05 con sus particularidades — declaradas en las secciones por solution más abajo.

---

## Lifecycle Variant — Particularidades del Sub-Offering

Hereda las 8 fases canónicas DataOps (DISCOVER → ITERATE) del offering 05. Diferencias específicas:

| Fase | Particularidad de este sub-offering |
|------|--------------------------------------|
| DISCOVER (Source Profiling + Use Case) | {qué profila distinto — legacy data estate, consumo BI real, ontología fuente, etc.} |
| DESIGN (Data Modeling + ADRs) | {qué ADRs típicos · qué patrones (Medallion, Data Vault, Data Mesh, Strangler para EDW)} |
| BUILD (Pipeline / Asset Build) | {stack típico · gates de DQ específicos} |
| TEST (DQ + Schema Contract + Perf) | {tipos de validación específicos — reconciliación vs. source legacy, drift, etc.} |
| RELEASE (Deploy + Backfill) | {estrategia — cutover, parallel run, backfill histórico, dual-write} |
| OPERATE | {modelo operativo post-go-live} |
| OBSERVE (DQ + Freshness + Drift) | {SLOs específicos del dominio} |
| ITERATE (Refactor / Schema Evolution) | {patrón de mejora continua} |

---

## ID Prefix Convention

Hereda `MDP-{NNN}` del offering 05 + sufijo por solution L4:

| Solution L4 | Prefix de componente/asset |
|-------------|----------------------------|
| {Solution 1} | `MDP-{slug-corto-1}-{NNN}` |
| {Solution 2} | `MDP-{slug-corto-2}-{NNN}` |

---

## Aplicación de Universal Rules v2.1 — Énfasis del Sub-Offering

| § | Sección Universal | Énfasis específico aquí |
|---|-------------------|---------------------------|
| §16 | Component / Data Product Spec | {qué secciones del spec son más críticas — source profile, schema, DQ rules, lineage, PII} |
| §17 | Versioning | {política de schema versioning · compat. con dataset legacy migrado} |
| §18 | Repo & Branching | {polyrepo por data product · monorepo dbt · gates de PR} |
| §19 | CI/CD Pipeline | {**gates DataOps dentro de las stages canónicas** — Source Profiling, DQ Tests, Schema Contract Check, Backfill validation} |
| §20 | Lifecycle State | {transiciones — dataset/EDW legacy → DEPRECATED durante ventana de migración} |
| §21 | Postmortem | {triggers de datos específicos — DQ cascade, schema break, drift, ontología inconsistente} |
| §22 | Contract-First | {dbt contracts + Schema Registry obligatorios · contract test con consumers} |
| §23 | Catalog / Discoverability | {DataHub/Collibra · lineage poblada desde dbt + orquestador} |

---

## Solutions L4 — Descripción Operativa

### Solution L4-1: {Nombre del Solution 1, literal del slide}

**Definición**: {2-3 frases · qué entrega · cuándo se invoca · qué hace el AI/agente vs. el humano}

**Componentes / assets que entrega**:
| Tipo | Definición | Stack típico |
|------|------------|--------------|
| ... | ... | ... |

**DoR específico**:
- {Criterios adicionales a §2.1 DC para este solution}

**DoD específico (suma a §2.2 + DoD-MDP del offering 05)**:
- [ ] DoD-MDP-{slug}-01: {criterio específico}
- [ ] DoD-MDP-{slug}-02: ...

**Quality Gates específicos**:
| Gate | Fase | Criterio |
|------|------|----------|
| ... | ... | ... |

**Reference Architecture / Patrones canónicos**:
- {Pattern 1 — Medallion, Data Vault 2.0, Strangler para EDW, CDC dual-write, Data Mesh, etc. con cuándo aplicar}
- {Pattern 2}

**ADRs canónicos del solution**:
- ADR-MDP-{slug}-001: {decisión típica — target platform, transformation framework, etc.}
- ADR-MDP-{slug}-002: ...

**SLOs canónicos**:
- SLO-{slug}-01: {SLO específico con target — freshness, completeness, reconciliation accuracy}

**SME canónico que ejecuta delivery**: `SME/{ruta}/`

**Packet [INVOKE] típico a SME**:
```
[INVOKE: SME en SME/{ruta}/]
COMPONENTE/ASSET : {ID + nombre}
FASE OBJETIVO    : {DISCOVER/DESIGN/BUILD/TEST/RELEASE/OPERATE}
DELIVERABLE      : {data product · pipeline · migración · ontología}
DoD APLICABLE    : {lista}
CONTRATO         : {schema + SLA + ownership a respetar}
DEPENDENCIES     : {upstream sources · consumers downstream}
ENV TARGET       : {DEV/QA/UAT/STG/PROD}
DEADLINE         : {fecha}
```

**Common Scenarios**:
1. {Escenario típico 1 con pasos}
2. {Escenario típico 2}

**Anti-patrones específicos del solution**:
- **[ANTIPATRÓN]** {específico del dominio de datos}

---

### Solution L4-2: {Nombre del Solution 2}

{Misma estructura}

---

{Repetir bloque por cada solution L4 del sub-offering — solo los del slide oficial}

---

## Modos de Operación

Hereda los 4 modos del offering 05 (REQUIREMENTS · BUILD · RELEASE · RUN). Si el contexto no es explícito, infiero del trigger del usuario y del estado del data product / migración activa.

---

## Decision Authority

Hereda la tabla de Decision Authority del offering 05. Adiciones específicas de este sub-offering:

| Tipo de decisión | Autoridad |
|------------------|-----------|
| {Decisión típica del sub-offering} | {Autónomo / Requiere ADR / Requiere Data Steward / Requiere TS&T / etc.} |

---

## Handoffs Canónicos hacia `SME/`

| Fase | SME(s) responsable(s) por solution |
|------|-------------------------------------|
| DISCOVER | {Solution 1: SME ...} · {Solution 2: SME ...} |
| DESIGN | ... |
| BUILD | ... |
| TEST | ... |
| RELEASE | ... |
| OPERATE | AMS Reinvention + Data & ML (continuidad) + ITSM si change formal |
| OBSERVE | SRE & AIOps + Data & ML (DQ ops) · Specialist Monte Carlo/Acceldata si en stack |
| ITERATE | Data & ML + Innovation (si patrón emergente) |

---

## Estimation & Pricing Handoff

Triggers que activan Pricing & Commercial Modeler (heredados del offering 05 + específicos):

| Trigger específico | Cuándo |
|--------------------|--------|
| {Trigger 1 del sub-offering} | {Stage / contexto} |

Packet a Pricing siguiendo formato del offering 05 + campo adicional `SUB-OFFERING: {L3 name}` + `SOLUTION: {L4 name}`.

---

## Cross-Offering Dependencies

Hereda las del offering 05 + específicas:

| Dependencia específica | Cuándo |
|------------------------|--------|
| `[DEPENDS-ON: 0X {offering}]` | {contexto} |

---

## Anti-patrones del Sub-Offering

- **[ANTIPATRÓN]** {específico del L3 — no solo del solution L4}

---

## Checklist DoD del Sub-Offering Antes de Cerrar OPERATE

Hereda checklist del offering 05 + criterios específicos:
- [ ] {Criterio adicional 1 del sub-offering}
- [ ] {Criterio adicional 2}

---

*Última actualización: {YYYY-MM-DD} · v0.1 · {nota de versión}*
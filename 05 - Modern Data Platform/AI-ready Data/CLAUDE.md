# AI-ready Data — Offering Domain (Modern Data Platform / DataOps)

> Hereda `AGENTES-UNIVERSAL-RULES-DC.md` (Digital Core) + el `CLAUDE.md` del offering **05 Modern Data Platform** (L1).
> Por referencia, `AGENTES-UNIVERSAL-RULES.md` de Solutioning.
> Zona: ★ Digital Core · Offering: 05 Modern Data Platform · Nivel: **Offering Domain** · Lifecycle: **DataOps**.

```
┌─[★ Digital Core]──────────────────────────┐
│ AI-ready Data — Offering Domain            │
│ Migration · Modernization · Knowledge · Ops│
└────────────────────────────────────────────┘
```

---

## Qué es este nivel

**Orquestador delgado.** Este documento NO repite el lifecycle DataOps, los gates, el stack ni los SLOs — todo eso vive en el L1 (`../CLAUDE.md`) y es transversal a los 4 sub-offerings. Aquí solo se define:

1. La identidad del offering domain **AI-ready Data** según el slide oficial AI & Data L1-L4.
2. El catálogo de sus **4 sub-offerings L3** y a qué `CLAUDE.md` dirigirse.
3. El protocolo de despacho (qué sub-offering activar según el trigger del usuario).

Toda ejecución de delivery se delega al SME canónico de `SME/` vía `[INVOKE]` (§13 DC Universal Rules), gobernada por el L3 correspondiente.

---

## Jerarquía y posición

```
Digital Core                              (RP)
└─ 05 Modern Data Platform                (offering · ../CLAUDE.md)
   ├─ AI-ready Data/                       (offering domain · ESTE archivo)   ◄── estás aquí
   │  ├─ Data Migration/                   (sub-offering L3)
   │  ├─ Data Modernization/               (sub-offering L3)
   │  ├─ Knowledge Engineering Services/   (sub-offering L3)
   │  └─ Data Managed Services/            (sub-offering L3)
   └─ (Scaled AI Foundation — domain hermano del slide; se realiza en 02 AI Enabled Enterprise, fuera de scope de 05)
```

---

## Identidad del Offering Domain

> **AI-ready Data** (slide oficial AI & Data L1-L4): hacer el data estate listo para AI — migrado, modernizado, con conocimiento contextualizado y operado como servicio, *using AI/Agents*, para que la empresa tenga data lista para AI en una fracción del tiempo y con conocimiento (no solo filas) federado cerca de las LoBs.

**Honestidad técnica vs. marketing**: el slide enmarca todo "using AI/Agents". Cada L3 declara el límite real de esa autonomía — qué acelera el AI/agente vs. qué exige juicio humano y firma de Data Steward. No copiar el marketing sin matizar.

---

## Catálogo de Sub-Offerings L3

| # | Sub-offering L3 | Foco (slide oficial) | Solutions L4 | `CLAUDE.md` | Estado |
|---|------------------|----------------------|--------------|-------------|--------|
| 1 | **Data Migration** | Migrar legacy data estate a plataformas target *using AI/Agents* — data lista para AI en fracción del tiempo | AI-Accelerated Migration · Data Product Factory | `Data Migration/CLAUDE.md` | `[STATE: PROPOSED]` |
| 2 | **Data Modernization** | Modernizar data estates con industry data products + data federada cerca de LoBs *using AI/Agents* | Data Products & Strategy · AI for BI (AI4BI) · Data Agents · Txn & Realtime Data Modernization | `Data Modernization/CLAUDE.md` | `[STATE: PROPOSED]` |
| 3 | **Knowledge Engineering Services** | Construir la capa de conocimiento (semántica + ontologías) que convierte data cruda en conocimiento empresarial contextualizado | Knowledge Agents · Scaled ontology creation | `Knowledge Engineering Services/CLAUDE.md` | `[STATE: PROPOSED]` |
| 4 | **Data Managed Services** | Operar data y conocimiento como servicio de largo plazo *using AI/Agents* | Data Ops · Data to Knowledge Ops · Autonomous BI Ops · AI Lifecycle Management | `Data Managed Services/CLAUDE.md` | `[STATE: PROPOSED]` |

Los solutions L4 son **literales del slide** — no inventar fuera de él (ver `../source/ai-data-offering-architecture-L1-L4.md`).

---

## Protocolo de Despacho

Según el trigger del usuario, dirigir al L3 correspondiente:

| Si el trigger es sobre… | Activar sub-offering |
|--------------------------|----------------------|
| Migrar/mover un data estate legacy (EDW, data marts) a plataforma target; producir data products migrados con contrato | **Data Migration** |
| Estrategia de data products, BI aumentada con AI, agentes sobre datos, modernización transaccional/tiempo real | **Data Modernization** |
| Construir capa semántica/ontologías/knowledge graph; agentes de conocimiento | **Knowledge Engineering Services** |
| Operar data/conocimiento/BI en producción como servicio de largo plazo (run, DQ, freshness, incident) | **Data Managed Services** |

Si el alcance cruza dos sub-offerings (p. ej. migración + operación continua), gobernar la secuencia y declarar el handoff entre L3s explícitamente.

---

## Fronteras del Domain

- **Con `Scaled AI Foundation` (02 AI Enabled Enterprise)**: AI-ready Data prepara y opera el lado DATOS. El razonamiento agentic AI-native, los modelos y MLOps viven en 02. Varios L4 (AI4BI, Data Agents, Knowledge Agents, Autonomous BI Ops, AI Lifecycle Management) tienen `[DEPENDS-ON: 02 AI Enabled Enterprise]` declarado en su L3.
- **Con `07 AMS Reinvention`**: Data Managed Services aporta el know-how DataOps/DQ/contract; 07 aporta el modelo AMS general, SLAs, transición y AIOps. No duplicar el modelo AMS.

---

*Última actualización: 2026-05-31 · v0.1 · Offering domain creado al insertar el nivel faltante entre el L1 (Modern Data Platform) y los 4 sub-offerings L3.*
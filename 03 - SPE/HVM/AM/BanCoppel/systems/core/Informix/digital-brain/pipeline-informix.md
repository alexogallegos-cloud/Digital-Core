# Pipeline — Informix Digital Brain (BCOPBrain)

## Arquitectura Medallion — Rules Pipeline (Bronze → Silver → Gold)

```
[source/Informix/  ·  49 DBs  ·  ~12,812 SPs]
[knowledge-base/vocabulary-inventory.json]
              │
              ▼
   extract-rules.py          ← BRONZE  (D01-D49 unificado, vocab-anchored)
              │                 Detecta: FÓRMULA / VALIDACIÓN / UMBRAL / ESTADO
              │                 Aplica: reg/riesgo patterns + BC tagging
              ▼
   portal/data/rules-bronze.json   (raw: sin business_name, sin clase asignada)
              │
              ▼
   enrich-rules.py           ← SILVER  (clasificación clase + triaje reg + biz)
              │                 Aplica: clase (NEGOCIO/INFRA/ENSAMBLAJE/PRESENTACION)
              │                 Aplica: regulatory domain defaults D17-D49
              │                 Copia: business_name desde brain.db (si existe)
              ▼
   portal/data/business-rules-v3.json  {"meta":..., "rules":..., "stats":...}
              │
              ▼
   build-brain.py --reset     ← GOLD   (load_rules() → brain.db)
              │
              ▼
   brain.db (reglas correlacionadas con journeys, términos y SPs)
```

Scripts archivados en `generators/old/`:
- `extract-rules-v2.py` — supersedido por extract-rules.py (D01-D16)
- `extract-rules-d17-d49.py` — supersedido por extract-rules.py (D17-D49)
- `enrich-d17-d49.py` — lógica absorbida en enrich-rules.py
- `triaje-d17-d49.py` — lógica absorbida en enrich-rules.py
- `ola-a/b/c/d-*.py` — operaban sobre `terms` (vocabulario); pipeline separado

---

## Pipeline Completo (Mermaid)

```mermaid
flowchart LR
    subgraph SRC["Fuente"]
        F1["source/Informix/\n49 DBs · 12,812 SPs"]
        F2["source/logs/\nCTM · WAS · ESB"]
        F3["source/controlm/\n*.xls"]
        F4["knowledge-base/\nvocabulary-inventory.json"]
    end

    subgraph BRONZE["Bronze — Extracción"]
        E1["mine-source.py\nextract-journeys.py"]
        E2["extract-rules.py\nD01-D49 unificado"]
        EJ[("callgraph-data.json\njourneys-data.json")]
        EB[("rules-bronze.json\nraw · sin clase · sin biz")]
    end

    subgraph SILVER["Silver — Enriquecimiento"]
        S1["enrich-rules.py\nclase + triaje reg + biz"]
        ER[("business-rules-v3.json\n~6,800+ reglas NEGOCIO")]
    end

    subgraph BUILD["Gold — Build Brain (secuencia)"]
        B1["① build-brain.py --reset\nsps · edges · journeys\nrules · vocabulary"]
        B2["② classify-batch.py\nbatch_archetype"]
        B3["③ load-ctm-to-brain.py\nCTM_ENTRY 87 SPs"]
        B3B["③b mark-ctm-entry-points.py\nCTM_ENTRY +68 SPs"]
        B5["④ build-sp-fine-mapping.py\nETB L3 map"]
        B6["⑤ build-decoupling-cost.py"]
        DB[("brain.db\n12,812 SPs · reglas\n634 términos · 166 journeys")]
    end

    subgraph CL["Clasificación semántica (post-build)"]
        CL2["classify-sp-types.py"]
        CL3["assign-scope.py"]
    end

    subgraph GEN["Generadores de Portal"]
        G1["build-rules-report.py\ngen-rules-portal.py"]
        G2["build-sp-detail-pages.py\nPhase B CALLEE_INFO"]
        G3["build-dependency-graph.py"]
        G4["build-migration-complexity.py"]
        G5["build-capability-model.py"]
        G6["build-forecast-spei.py\nbuild-percentiles-correlacionados.py"]
        G7["build-souls.py"]
        G8["build-landing.py · build-catalog.py\nbuild-quality-report.py"]
        G9["build-chord.py · build-sp-architecture.py"]
    end

    subgraph PORTAL["Portal localhost:3000"]
        P1["rules-catalog-bcop.html\n~6,800 reglas NEGOCIO"]
        P2["SP detail pages\n166 journeys"]
        P3["ETB Capability Map\nL3 × 261"]
        P4["Forecast SPEI\nCapacidad"]
        P5["Landing · Quality\nArchitecture · Catalog"]
    end

    F1 --> E1
    F1 --> E2
    F4 --> E2

    E1 --> EJ
    E2 --> EB
    EB --> S1
    S1 --> ER

    EJ --> B1
    ER --> B1
    F2 --> B3
    F2 --> B3B
    F3 --> B3

    B1 --> B2
    B2 --> B3
    B3 --> B3B
    B3B --> B5
    B5 --> B6

    B1 --> DB
    B2 --> DB
    B3 --> DB
    B3B --> DB
    B5 --> DB
    B6 --> DB

    DB --> CL2
    DB --> CL3
    CL2 --> DB
    CL3 --> DB

    DB --> G1
    DB --> G2
    DB --> G3
    DB --> G4
    DB --> G5
    DB --> G6
    DB --> G7
    DB --> G8
    DB --> G9

    G1 --> P1
    G2 --> P2
    G5 --> P3
    G6 --> P4
    G7 --> P5
    G8 --> P5
    G9 --> P5
    G3 --> P5
    G4 --> P5

    P1 --> SRV["serve-nocache.py\nlocalhost:3000"]
    P2 --> SRV
    P3 --> SRV
    P4 --> SRV
    P5 --> SRV
```

---

## Comandos canónicos de rebuild completo

```bash
# ── Bronze: extracción unificada D01-D49 ─────────────────────────────────────
python generators/extract-rules.py
# Output: portal/data/rules-bronze.json

# ── Silver: enriquecimiento (clase + reg defaults + biz desde brain.db) ───────
python generators/enrich-rules.py
# Output: portal/data/business-rules-v3.json

# ── Gold: rebuild brain ───────────────────────────────────────────────────────
python digital-brain/build-brain.py --reset
python digital-brain/classify-batch.py
python generators/load-ctm-to-brain.py
python generators/mark-ctm-entry-points.py
python generators/build-sp-fine-mapping.py     # opcional · ~30 min
python generators/build-decoupling-cost.py

# ── Generadores del portal ────────────────────────────────────────────────────
python generators/gen-rules-portal.py          # rules-catalog-bcop.html
python generators/build-sp-detail-pages.py    # SP detail pages

# ── Servidor local ────────────────────────────────────────────────────────────
# (desde raíz BanCoppel/)
python -m http.server 3000
# http://localhost:3000/systems/core/Informix/portal/
```

---

*Actualizado: 2026-08-25 · Medallion Architecture (Bronze/Silver/Gold) consolidada.*
*Scripts archivados: extract-rules-v2.py, extract-rules-d17-d49.py, enrich-d17-d49.py, triaje-d17-d49.py, ola-a/b/c/d-*.py → generators/old/*

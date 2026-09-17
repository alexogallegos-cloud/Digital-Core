# DT — IT Operating Model Overlay (BanCoppel Informix)
> **Proyecto**: BanCoppel Application Modernization · `SPE-AM-001`
> **Digital Twin**: `dt-itom/` — Análisis ITOM del sistema Informix Core (PISA)
> **Versión**: 0.1.0 · 2026-08-29
> **SME heredado**: IT Operating Model (`SME/Framework/IT Operating Model/`)
> **Brain propietario**: `digital-brain/brain.db` (tablas: `itom_layer`, `knowledge_completeness`)

---

## Identidad y Propósito

Soy el **Digital Twin de IT Operating Model** del sistema Informix Core (PISA). Mi misión es leer el cerebro del sistema (BCOPBrain) y proyectar lo que observo en términos del **IT Operating Model Framework** — los 6 dominios canónicos definidos por el SME heredado:

1. Customer and Ecosystem Engagement
2. IT Strategy
3. Product / Service Delivery
4. **Technology Operations** ← dominio primario de un sistema core en producción
5. Information and Analytics
6. IT Management

Para un sistema legacy como Informix (IBM IDS 14.10 / POWER-AIX, producción ininterrumpida desde ~1990s), el foco analítico es **Technology Operations**: cómo opera hoy el sistema, quién lo gestiona, qué plataformas sostiene, y qué brechas del modelo operativo amenazan la migración.

**Principio rector**: todo lo que BCOPBrain sabe del sistema (SPs, arquetipos batch, puntos de entrada CTM, dependencias externas, journeys) es evidencia del modelo operativo real — no del modelo operativo declarado. La diferencia entre ambos es el gap que este DT expone.

---

## SME Heredado

| SME | Ruta | Qué aporta |
|-----|------|-----------|
| IT Operating Model | `SME/Framework/IT Operating Model/` | Framework canónico de 6 dominios, taxonomía `itom_layer`, principios de evaluación de madurez operativa |

---

## Ontología ITOM Aplicada a Informix

### Mapeo de evidencia brain.db → dominio ITOM

El BCOPBrain contiene señales que mapean directamente a los dominios ITOM:

| Dominio ITOM | `layer` canónico | Evidencia en brain.db | Tablas fuente |
|--------------|------------------|-----------------------|---------------|
| Technology Operations | `technology-operations` | 155 CTM_ENTRY SPs (batch), 12,812 SPs en producción AIX, 25 sistemas en `external_systems`, operación scheduler Control-M | `sps`, `ctm_jobs`, `external_systems`, `cross_dependencies` |
| Product / Service Delivery | `delivery` | 166 customer journeys, 8,005 reglas de negocio (6,819 NEGOCIO), pipeline de releases batch vs OLTP | `journeys`, `rules`, `sp_capabilities` |
| Information and Analytics | `information-analytics` | 101 reglas ENSAMBLAJE_REPORTE (SQL dinámico reportes), integración Atlas/DataLake, feeds regulatorios CNBV | `rules` (clase=ENSAMBLAJE_REPORTE), `external_systems` |
| IT Management | `it-management` | 1,216 reglas regulatorias (D17-D49), 11 riesgos de producción, compliance CNBV/Banxico/PLD/FATCA | `rules` (reg!=null), `regulatory_obligations`, `sp_regulatory_links` |
| Customer and Ecosystem Engagement | `customer-engagement` | Canales AppMóvil, Banca Internet, Cajero/ATM, SPEI/CoDi (dependencias externas) | `external_systems`, journeys de canal |
| IT Strategy | `it-strategy` | migration_fate (absorbed 59%/replicate 24%/complement 17%), ETB L3 coverage (88.7%), decisiones 7R | `sp_capabilities`, `etb_l3` |

### Sub-capacidades ITOM priorizadas para Informix

Dado que Informix es un **SoR core bancario en estado Baseline** (`togaf_state: baseline`), las sub-capacidades con mayor evidencia empírica son:

| Sub-capacidad | Evidencia concreta | Gap detectado |
|---------------|--------------------|---------------|
| Infrastructure & Platform Operations | IBM POWER-AIX · IDS 14.10 · 60TB · scripts shell 1,104 | Sin IaC; operación manual; sin runbook CLAUDE-managed |
| Service Management | Control-M orquesta 155 SPs batch; sin ITSM formal | Sin CMDB; dependencias parcialmente documentadas |
| Service Operations | 552 SPs con métricas ESB producción; 2 defectos activos P655 | Sin SLO formal; alertas sin codificación |
| Release & Deployment Management | Ciclos de release sin CI/CD formal; deployment manual AIX | Ausencia de deployment pipeline |
| Risk & Compliance Management | 485 riesgos de equivalencia; 11 riesgos producción | Registro activo pero sin workflow de remediación |
| Information & Data Management | 25 sistemas externos; feeds CNBV/Banxico/SAT | Sin data contracts; sin linaje automatizado |

---

## Fuentes de Datos para Seeding de `itom_layer`

### Fase 1 — Desde brain.db existente (sin entrevistas)

Las siguientes queries producen rows para `itom_layer` sin requerir información adicional:

```sql
-- CTM_ENTRY SPs → Technology Operations / Service Management
SELECT 
    sp_key AS component_id,
    'technology-operations' AS layer,
    'scheduler-batch' AS technology,
    'batch' AS operation_model,
    'batch_archetype=CTM_ENTRY' AS evidence_type,
    'SPL Analysis DT' AS owner_domain
FROM sps 
WHERE batch_archetype = 'CTM_ENTRY';
-- Resultado esperado: ~155 rows

-- External systems → Customer Engagement + IT Management
SELECT 
    system_name AS component_id,
    CASE 
        WHEN system_type IN ('canal', 'channel') THEN 'customer-engagement'
        WHEN system_type IN ('regulatory', 'compliance') THEN 'it-management'
        WHEN system_type IN ('integration', 'esb') THEN 'delivery'
        ELSE 'technology-operations'
    END AS layer,
    interface_type AS technology,
    'integration' AS operation_model,
    'external_systems' AS evidence_type,
    'Integration Architecture' AS owner_domain
FROM external_systems
WHERE total_endpoints > 0;
-- Resultado esperado: ~25 rows
```

### Fase 2 — Con entrevistas BanCoppel (pendiente)

Los siguientes gaps de `itom_layer` requieren información que solo el cliente puede proveer:

| Gap | Pregunta al cliente | Tabla destino |
|-----|--------------------|----|
| Ownership de dominios | ¿Quién es el owner funcional de cada módulo (D01-D49)? | `domain_experts` |
| SLOs declarados | ¿Cuáles son los SLAs formales del sistema en producción? | `itom_layer.slo_ref` |
| Modelo de soporte | ¿Cómo se escalan incidentes? ¿Existe un runbook formal? | `itom_layer.operation_model` |
| Change Advisory Board | ¿Cómo se aprueba un cambio en producción? | `decisions_history` |
| Financiamiento TI | ¿Cómo se costea el sistema? ¿CAPEX/OPEX? | `itom_layer` (layer=it-management) |

---

## Script de Seeding Inicial

Ubicación canónica: `generators/seed-itom-layer.py`

Este script popula `itom_layer` desde los datos ya presentes en brain.db (Fase 1). Ejecutar después de `build-brain.py`:

```python
# generators/seed-itom-layer.py
# Siembra itom_layer desde evidencia ya disponible en brain.db
# No requiere entrevistas — usa CTM_ENTRY, external_systems, cross_dependencies
import sqlite3, pathlib, json
from datetime import date

BRAIN = pathlib.Path(__file__).parent.parent / "digital-brain" / "brain.db"

ROWS = []

with sqlite3.connect(BRAIN) as db:
    db.row_factory = sqlite3.Row

    # CTM_ENTRY SPs → Technology Operations / Service Management
    for r in db.execute("SELECT sp_key, sp_name FROM sps WHERE batch_archetype='CTM_ENTRY'"):
        ROWS.append({
            "component_id": r["sp_key"],
            "layer": "technology-operations",
            "technology": "IBM-Informix-SPL",
            "operation_model": "batch-scheduler-CTM",
            "slo_ref": None,
            "owner_domain": "Control-M",
            "notes": f"CTM entry point: {r['sp_name']}"
        })

    # External systems → según tipo
    layer_map = {
        "canal": "customer-engagement",
        "channel": "customer-engagement",
        "regulatory": "it-management",
        "compliance": "it-management",
        "integration": "delivery",
        "esb": "delivery",
    }
    for r in db.execute("SELECT system_name, system_type, interface_type FROM external_systems WHERE total_endpoints > 0"):
        ROWS.append({
            "component_id": r["system_name"],
            "layer": layer_map.get((r["system_type"] or "").lower(), "technology-operations"),
            "technology": r["interface_type"] or "unknown",
            "operation_model": "integration",
            "slo_ref": None,
            "owner_domain": "Integration Layer",
            "notes": f"Evidencia: external_systems · {r['total_endpoints'] if 'total_endpoints' in r.keys() else 'N/A'} endpoints"
        })

if ROWS:
    with sqlite3.connect(BRAIN) as db:
        db.execute("DELETE FROM itom_layer WHERE notes LIKE 'CTM entry point:%' OR notes LIKE 'Evidencia: external_systems%'")
        db.executemany(
            "INSERT INTO itom_layer (component_id, layer, technology, operation_model, slo_ref, owner_domain, notes) VALUES (:component_id, :layer, :technology, :operation_model, :slo_ref, :owner_domain, :notes)",
            ROWS
        )
        db.commit()
    print(f"itom_layer: {len(ROWS)} rows insertados ({date.today()})")
else:
    print("itom_layer: sin datos suficientes en brain.db — ejecutar build-brain.py primero")
```

---

## Qué Produce Este DT

| Output | Descripción | Destino |
|--------|-------------|---------|
| `itom_layer` poblada (Fase 1) | 155 CTM_ENTRY + ~25 external_systems clasificados por dominio ITOM | `digital-brain/brain.db` |
| `knowledge_completeness` actualizada | Registro de fill_pct por dimensión ITOM vs total esperado | VIEW en brain.db |
| Análisis de madurez ITOM | Nivel de madurez por sub-capacidad (1-5) basado en evidencia disponible | Entregable para DESIGN gate |
| Gap report ITOM → migración | Qué dominios ITOM del sistema NO están cubiertos → riesgos de migración | Alimenta `dt-riesgos/` |

---

## Preguntas que Este DT Puede Responder

- ¿Qué tan maduro es el modelo operativo actual de Informix por dominio ITOM?
- ¿Qué sub-capacidades de Technology Operations están implícitas vs. formalizadas?
- ¿Cuáles son los gaps de ITOM que representan riesgo para la migración a AWS Aurora?
- ¿Qué Change Management existe para este sistema hoy?
- ¿Qué dominio ITOM tiene mayor evidencia empírica en brain.db vs. menor documentación formal?

---

## Restricciones

- Este DT **no prescribe** el modelo operativo target — ese es el trabajo del IT Operating Model SME con el cliente. Este DT describe el AS-IS desde el código y los artefactos operativos.
- Las conclusiones sobre madurez se basan en evidencia empírica (brain.db). No se generan scores sin evidencia.
- Los gaps identificados en Fase 1 son hipótesis que la Fase 2 (entrevistas) valida o corrige — nunca certezas.

---

*Versión 0.1.0 · 2026-08-29 · Inicial — seeding desde brain.db existente (CTM_ENTRY + external_systems). Fase 2 (entrevistas) pendiente.*
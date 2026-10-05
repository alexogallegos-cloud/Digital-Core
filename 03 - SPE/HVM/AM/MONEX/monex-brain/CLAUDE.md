# monex-brain — Cerebro Federado MONEX Grupo Financiero
> Agente de segundo orden: agrega y razona sobre los brains de cada sistema + ontología OWL 2 DL.
> No lee código fuente directamente. Para análisis de un sistema específico, ve al CLAUDE.md del sistema.

---

## ROL DE ESTE AGENTE

Soy el **Cerebro Federado** de MONEX Grupo Financiero. Mi responsabilidad es:

1. **Agregar** el conocimiento de todos los system-level brains vía SQLite `ATTACH`
2. **Mantener** el vocabulario empresarial canónico (Rosetta Stone MONEX)
3. **Gobernar** la ontología OWL 2 DL de la arquitectura de integración
4. **Razonar** sobre el landscape tecnológico: dependencias cross-sistema, gaps, cumplimiento regulatorio
5. **Proponer** escenarios de integración para el programa Apolo

---

## CAPAS DE CONOCIMIENTO

| Maturity | Capa | Descripción |
|----------|------|-------------|
| `HOY` | AS-IS | Estado actual verificado en producción |
| `AYER` | Historia | Decisiones pasadas, evolución arquitectónica |
| `MAÑANA` | Pipeline Apolo | `idea → exploring → decided → implementing → live → rejected` |

---

## VOCABULARIO EMPRESARIAL — ROSETTA STONE

Archivo: `knowledge-base/vocab/vocab-monex-v1.json`

Estructura de entrada:
```json
{
  "term": "Operación FX",
  "domain": "fx",
  "scope": "enterprise",
  "en": "fx_transaction",
  "systems": {
    "fx-engine": "FX_OPR",
    "treasury": "fx_operation_id",
    "mulesoft": "fx-transaction"
  }
}
```

---

## ONTOLOGÍA OWL 2 DL — MOTOR DE GOBIERNO

La ontología de arquitectura es el diferenciador del engagement. Vive en:
- `knowledge-base/ontology/business-ontology.md` — vocabulario y axiomas en lenguaje natural
- `knowledge-base/ontology/abb-to-sbb.json` — mapeo ABB → SBB (capability → sistema)

**Preguntas que el grafo puede responder:**
1. ¿Qué flujos quedan en incumplimiento si cambias el schema de ISO 20022?
2. ¿Qué sistemas procesan una operación FX desde cotización hasta liquidación CLS?
3. ¿Qué APIs del catálogo no tienen trazabilidad regulatoria declarada?
4. ¿Qué sistemas alimentan el reporte DIOR de Banxico?

---

## SISTEMA DE BRAINS — AGREGACIÓN

```
monex-brain.db
├── ATTACH → systems/core/fx-engine/digital-brain/brain.db
├── ATTACH → systems/core/treasury/digital-brain/brain.db
├── ATTACH → systems/core/payments-legacy/digital-brain/brain.db
├── ATTACH → systems/integration/mulesoft/digital-brain/brain.db
├── ATTACH → systems/integration/swift/digital-brain/brain.db
├── ATTACH → systems/integration/spei/digital-brain/brain.db
├── ATTACH → systems/channels/portal-clientes/digital-brain/brain.db
├── ATTACH → systems/channels/api-marketplace/digital-brain/brain.db
├── ATTACH → systems/data/golden-record-target/digital-brain/brain.db
├── ATTACH → systems/compliance/cnbv-banxico/digital-brain/brain.db
└── ATTACH → systems/compliance/dora/digital-brain/brain.db
```

---

## ETB BANKING V5.0 — MARCO DE CAPACIDADES

Referencia: `knowledge-base/etb/etb-banking-v5.md`
Tabla en brain: `etb_l3` (29 capacidades L3 mapeadas — scope MONEX)

| L1 Dominio ETB | Relevancia | Estado cobertura |
|---------------|-----------|-----------------|
| 3 — Servicios de Pago | ALTA | PARTIAL (ISO 20022 y CLS: NOT_COVERED) |
| 5 — Gestión de Datos | ALTA | NOT_COVERED (Golden Record gap crítico) |
| 6 — Riesgo y Finanzas / FX | ALTA | COVERED |
| 7 — Tecnología / APIs | ALTA | PARTIAL (cloud y observabilidad: gap) |

---

## ITOM OVERLAY — IT OPERATING MODEL

Referencia: `knowledge-base/itom/itom-model.md`
Tabla en brain: `itom_layer` (66 entradas — 11 sistemas × 6 dominios ITOM)

**Gaps ITOM críticos:**
- `DataOps`: NOT_COVERED cross-sistemas — prerequisito del Golden Record
- `TechOps/Observabilidad`: PARTIAL — sin monitoring unificado cross-sistema
- `SecOps`: DATO-REQUERIDO — DORA pendiente de self-assessment

---

## DIGITAL TWINS — NIVEL FEDERADO

| Digital Twin | Pregunta que responde |
|-------------|----------------------|
| `dt-motor-pagos/` | ¿Qué sistemas tocan un pago desde instrucción hasta liquidación? |
| `dt-fx-next/` | ¿Cómo fluye una operación FX desde cotización hasta settlement CLS? |
| `dt-golden-record/` | ¿Qué sistemas son fuente de datos maestros y cómo se resuelven conflictos? |
| `dt-plataforma-apolo/` | ¿Cómo es el path de decommission del legado capability por capability? |
| `dt-integracion-semantica/` | ¿Qué APIs están gobernadas por la ontología OWL y cuáles quedan fuera? |
| `dt-regulatorio/` | ¿Qué sistemas alimentan qué reportes regulatorios (CNBV · Banxico · FCA)? |
| `dt-liquidacion-cls/` | ¿Cuál es la arquitectura de conectividad CLS y qué gaps bloquean el acceso? |
| `dt-itom/` | ¿Qué sistemas tienen cobertura operacional real y dónde están los gaps de operación? |
| `dt-inteligencia-negocio/` | ¿Cuál es el contexto estratégico, competitivo y de mercado de MONEX — y por qué la oportunidad de pagos es crítica? |

---

## PIPELINE DE RECONSTRUCCIÓN

```bash
# Desde MONEX/monex-brain/
python build-monex-brain.py        # reconstruye monex-brain.db
python monex-brain.py "FX"         # query de prueba
python monex-brain.py systems      # lista sistemas registrados
```

---

*Última actualización: 2026-09-22 · v1.0 · Scaffold inicial*

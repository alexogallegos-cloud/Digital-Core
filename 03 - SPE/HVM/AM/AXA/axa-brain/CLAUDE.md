# axa-brain — Cerebro Federado AXA México
> Agente de segundo orden: agrega y razona sobre los brains de cada sistema.
> No lee código fuente directamente. Para análisis de un sistema específico, ve al CLAUDE.md del sistema.

---

## ROL DE ESTE AGENTE

Soy el **Cerebro Federado** de AXA México. Mi responsabilidad es:

1. **Agregar** el conocimiento de los 16 system-level brains vía SQLite `ATTACH`
2. **Mantener** el vocabulario empresarial canónico (Rosetta Stone AXA)
3. **Razonar** sobre el landscape tecnológico completo: dependencias cross-sistema, duplicidades, gaps
4. **Proponer** escenarios de cambio (capa MAÑANA) y alternativas de transformación

Para analizar código fuente o reglas de un sistema específico: `../systems/{categoría}/{sistema}/CLAUDE.md`.

---

## CAPAS DE CONOCIMIENTO

Cada registro en `axa-brain.db` tiene un campo `maturity`:

| Maturity | Capa | Descripción |
|----------|------|-------------|
| `HOY` | Estado actual | AS-IS verificado, lo que opera hoy en producción |
| `AYER` | Historia | Por qué las cosas son como son, decisiones pasadas |
| `MAÑANA` | Pipeline | `idea → exploring → decided → implementing → live → rejected` |

---

## VOCABULARIO EMPRESARIAL — ROSETTA STONE

Archivo: `knowledge-base/vocab/vocab-axa-v1.json`

El vocabulario es el **Rosetta Stone** cross-sistema: mapea el mismo concepto de negocio a sus
representaciones en cada sistema tecnológico. Toda extracción de código en un system-brain debe
cruzar con este vocabulario.

Estructura de entrada:
```json
{
  "term": "Prima neta",
  "domain": "finanzas",
  "scope": "enterprise",
  "en": "net_premium",
  "etb_capability": "Premium Management",
  "systems": {
    "policy-admin": "NET_PREM",
    "billing": "net_premium_amount",
    "datawarehouse": "DIM_PRIMA.NET_PREMIUM",
    "reporting-cnsf": "PRIMA_NETA"
  }
}
```

---

## SISTEMA DE BRAINS — AGREGACIÓN

`build-axa-brain.py` registra y (cuando existen) adjunta todos los system brains:

```
axa-brain.db
├── ATTACH → systems/core/policy-admin/digital-brain/brain.db
├── ATTACH → systems/core/claims/digital-brain/brain.db
├── ATTACH → systems/core/billing/digital-brain/brain.db
├── ATTACH → systems/processors/underwriting-engine/digital-brain/brain.db
├── ATTACH → systems/processors/reinsurance/digital-brain/brain.db
├── ATTACH → systems/processors/actuarial/digital-brain/brain.db
├── ATTACH → systems/channels/portal-agentes/digital-brain/brain.db
├── ATTACH → systems/channels/crm/digital-brain/brain.db
├── ATTACH → systems/channels/digital/digital-brain/brain.db
├── ATTACH → systems/integration/api-gateway/digital-brain/brain.db
├── ATTACH → systems/integration/event-bus/digital-brain/brain.db
├── ATTACH → systems/data/datawarehouse/digital-brain/brain.db
├── ATTACH → systems/data/analytics/digital-brain/brain.db
├── ATTACH → systems/data/reporting-cnsf/digital-brain/brain.db
├── ATTACH → systems/compliance/cnsf/digital-brain/brain.db
└── ATTACH → systems/compliance/solvency/digital-brain/brain.db
```

---

## DIGITAL TWINS — NIVEL FEDERADO (cross-sistema)

| Digital Twin | Pregunta que responde |
|-------------|----------------------|
| `dt-policy-lifecycle/` | ¿Qué sistemas tocan una póliza desde cotización hasta cancelación? |
| `dt-claims-lifecycle/` | ¿Qué sistemas intervienen de FNOL a cierre del siniestro? |
| `dt-underwriting-intelligence/` | ¿Cómo se toma la decisión de suscripción y en qué sistemas vive? |
| `dt-distribution-network/` | ¿Cómo fluye la venta de un agente/corredor a la póliza emitida? |
| `dt-reinsurance-program/` | ¿Cómo se calcula y registra la cesión de reaseguro cross-sistema? |
| `dt-regulatory-solvency/` | ¿Qué sistemas alimentan el cálculo de reservas técnicas para CNSF? |
| `dt-financial-reporting/` | ¿Cómo se consolida el resultado técnico y se reporta internamente y al regulador? |
| `dt-inteligencia-mercado/` | ¿Cuál es el contexto competitivo, regulatorio y de crecimiento del mercado asegurador? |

---

## PIPELINE DE RECONSTRUCCIÓN

```bash
# Desde AXA/axa-brain/
python build-axa-brain.py          # reconstruye axa-brain.db desde todos los system brains
python axa-brain.py "prima neta"   # query de prueba
python axa-brain.py systems        # lista sistemas registrados
```

---

## GENERATORS — PIPELINE DE FEDERACIÓN

| Script | Propósito |
|--------|-----------|
| `build-axa-brain.py` | ETL principal: ATTACH + agregación |
| `build-vocab-v1.py` | Construye vocab-axa-v1.json (Rosetta Stone) |
| `enrich-strategic.py` | Enriquece con perspectiva estratégica (ETB capabilities) |
| `extract-strategic.py` | Extrae capacidades desde ETB Insurance P&C |

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold inicial*
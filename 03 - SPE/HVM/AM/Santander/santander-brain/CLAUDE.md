# santander-brain — Cerebro Federado Santander México
> Agente de segundo orden: agrega y razona sobre los brains de cada sistema.
> No lee código fuente directamente. Para análisis de un sistema específico, ve al CLAUDE.md del sistema.

---

## ROL DE ESTE AGENTE

Soy el **Cerebro Federado** de Santander México. Mi responsabilidad es:

1. **Agregar** el conocimiento de los system-level brains vía SQLite `ATTACH`
2. **Mantener** el vocabulario empresarial canónico (Rosetta Stone Santander)
3. **Razonar** sobre el landscape tecnológico completo: dependencias cross-sistema, duplicidades, gaps
4. **Proponer** escenarios de cambio (capa MAÑANA) y alternativas de transformación
5. **Emitir** análisis de inteligencia de mercado y benchmarks vs. competidores digitales

Para analizar código fuente o reglas de un sistema específico: `../systems/{categoría}/{sistema}/CLAUDE.md`.

---

## CAPAS DE CONOCIMIENTO

Cada registro en `santander-brain.db` tiene un campo `maturity`:

| Maturity | Capa | Descripción |
|----------|------|-------------|
| `HOY` | Estado actual | AS-IS verificado, lo que opera hoy en producción |
| `AYER` | Historia | Por qué las cosas son como son, decisiones pasadas |
| `MAÑANA` | Pipeline | `idea → exploring → decided → implementing → live → rejected` |

---

## VOCABULARIO EMPRESARIAL — ROSETTA STONE

Archivo: `knowledge-base/vocab/vocab-santander-v1.json`

El vocabulario es el **Rosetta Stone** cross-sistema: mapea el mismo concepto de negocio a sus
representaciones en cada sistema tecnológico. Toda extracción de código en un system-brain debe
cruzar con este vocabulario.

Estructura de entrada:
```json
{
  "term": "Crédito disponible",
  "domain": "crédito",
  "scope": "enterprise",
  "en": "available_credit",
  "etb_capability": "Credit Management",
  "systems": {
    "core-banking": "CRED_DISPONIBLE",
    "card-platform": "AVAIL_CREDIT_AMT",
    "supermovil": "availableCredit",
    "analytics": "DIM_CREDITO.DISPONIBLE"
  }
}
```

---

## SISTEMA DE BRAINS — AGREGACIÓN

`build-santander-brain.py` registra y (cuando existen) adjunta todos los system brains:

```
santander-brain.db
├── ATTACH → systems/core/core-banking/digital-brain/brain.db
├── ATTACH → systems/core/card-platform/digital-brain/brain.db
├── ATTACH → systems/core/loans/digital-brain/brain.db
├── ATTACH → systems/core/treasury/digital-brain/brain.db
├── ATTACH → systems/processors/card-authorizer/digital-brain/brain.db
├── ATTACH → systems/processors/payments-engine/digital-brain/brain.db
├── ATTACH → systems/processors/pld-engine/digital-brain/brain.db
├── ATTACH → systems/processors/fraud-detection/digital-brain/brain.db
├── ATTACH → systems/channels/supermovil/digital-brain/brain.db
├── ATTACH → systems/channels/santander-online/digital-brain/brain.db
├── ATTACH → systems/channels/santander-empresas/digital-brain/brain.db
├── ATTACH → systems/channels/atm-network/digital-brain/brain.db
├── ATTACH → systems/channels/call-center/digital-brain/brain.db
├── ATTACH → systems/channels/pos-acquiring/digital-brain/brain.db
├── ATTACH → systems/integration/api-gateway/digital-brain/brain.db
├── ATTACH → systems/integration/esb/digital-brain/brain.db
├── ATTACH → systems/integration/swift-gateway/digital-brain/brain.db
├── ATTACH → systems/integration/banxico-spei/digital-brain/brain.db
├── ATTACH → systems/data/datawarehouse/digital-brain/brain.db
├── ATTACH → systems/data/analytics/digital-brain/brain.db
├── ATTACH → systems/data/data-platform/digital-brain/brain.db
├── ATTACH → systems/compliance/cnbv-reporting/digital-brain/brain.db
├── ATTACH → systems/compliance/iam/digital-brain/brain.db
├── ATTACH → systems/compliance/finance-erp/digital-brain/brain.db
├── ATTACH → systems/compliance/itsm/digital-brain/brain.db
├── ATTACH → systems/compliance/crm/digital-brain/brain.db
└── ATTACH → systems/compliance/azure-backbone/digital-brain/brain.db
```

---

## DIGITAL TWINS — NIVEL FEDERADO (cross-sistema)

| Digital Twin | Pregunta que responde |
|-------------|----------------------|
| `dt-landscape-analysis/` | ¿Cuál es el mapa tecnológico AS-IS completo de Santander México? |
| `dt-customer-journey/` | ¿Qué sistemas toca un cliente retail desde onboarding hasta operación diaria? |
| `dt-payments-rails/` | ¿Qué sistemas intervienen en SPEI, DiMo, CoDi y pagos internacionales SWIFT? |
| `dt-card-lifecycle/` | ¿Qué sistemas tocan una tarjeta desde emisión hasta cancelación? |
| `dt-credit-lifecycle/` | ¿Qué sistemas intervienen en el ciclo de crédito (solicitud → desembolso → cobranza)? |
| `dt-regulatory-cnbv/` | ¿Qué sistemas alimentan el cumplimiento regulatorio (CNBV, Banxico, UIF)? |
| `dt-gap-analysis/` | ¿Cuáles son las brechas tecnológicas vs. competidores y regulación? |
| `dt-inteligencia-mercado/` | ¿Cuál es el contexto competitivo, regulatorio y de crecimiento del mercado bancario MX? |
| `dt-modernization-roadmap/` | ¿Cuál es el roadmap de transformación tecnológica (HOY → MAÑANA)? |

---

## PIPELINE DE RECONSTRUCCIÓN

```bash
# Desde Santander/santander-brain/
python build-santander-brain.py          # reconstruye santander-brain.db desde todos los system brains
python santander-brain.py "crédito"      # query de prueba
python santander-brain.py systems        # lista sistemas registrados
python santander-brain.py vocab "pago"   # busca en vocabulario
```

---

## GENERATORS — PIPELINE DE FEDERACIÓN

| Script | Propósito |
|--------|-----------|
| `build-santander-brain.py` | ETL principal: ATTACH + agregación |
| `build-vocab-v1.py` | Construye vocab-santander-v1.json (Rosetta Stone) |
| `enrich-strategic.py` | Enriquece con perspectiva estratégica (ETB Banking capabilities) |
| `extract-strategic.py` | Extrae capacidades desde ETB Banking |
| `seed-market-intel.py` | Siembra inteligencia de mercado bancario MX |
| `build-portal.py` | Genera portal/index.html desde santander-brain.db |

---

## ETB DE REFERENCIA — Banking

El brain usa el **Banking ETB** (Enterprise Technology Blueprint) con capacidades L3 bancarias:

- **Retail Banking**: Onboarding · Deposits · Payments · Cards · Loans · Wealth Management
- **Commercial Banking**: Treasury · Trade Finance · Cash Management · FX
- **Digital Banking**: Mobile Banking · Open Banking · API Management
- **Risk & Compliance**: PLD/AML · Credit Risk · Market Risk · Regulatory Reporting
- **Operations**: Core Banking Operations · Branch Operations · Contact Center

---

*Última actualización: 2026-09-17 · v1.0 · Scaffold inicial*

# Payments Modernization — Project Agent
# project_type: core-payments-modernization
# project_state: active
# platform: cloud-native (por definir en DESIGN)
# horizon_present: payments-legacy — motor de pagos legado en producción
# horizon_future: motor-pagos-apolo — cloud-native, ISO 20022, CLS-enabled
# replaces_or_complements: systems/core/payments-legacy

> **Engagement**: Modernización del Core de Pagos MONEX
> **Relación con Apolo**: Iniciativa 1 del programa Apolo
> **Modelo**: Change the Bank — transformación del motor de pagos con Strangler-Fig

---

## QUÉ ES ESTE PROYECTO

Modernización del motor de pagos de MONEX. El objetivo es reemplazar el motor de pagos
legacy por una plataforma cloud-native que soporte:

- **ISO 20022** nativo (mensajería MX)
- **CLS Settlement** — Payment-vs-Payment para eliminar riesgo de contraparte FX
- **Multi-riel** — SPEI (MXN) + SWIFT (USD/EUR/GBP) + ISO 20022 cross-border
- **STP ≥ 99%** — Straight-Through Processing sin intervención manual
- **Disponibilidad 24/7/365** — pagos en tiempo real (SPEI ya lo exige)
- **Regulatorio embebido** — DIOR generado automáticamente, AML en tiempo real

---

## CONTEXTO DEL PROYECTO

| Atributo | Valor |
|----------|-------|
| Estado | Activo — DISCOVER |
| Alcance | SI (System Integration) — implementación del motor |
| Duración estimada | 18-24 meses |
| Iniciativa Apolo | Iniciativa 1 — Motor de Pagos |
| Sistema que reemplaza | `systems/core/payments-legacy/` |
| Patrón de coexistencia | Strangler-Fig por capability |
| CCI objetivo | 41% (SI) |

---

## SISTEMAS INVOLUCRADOS

| Sistema | Rol | Fase |
|---------|-----|------|
| `payments-legacy` | Sistema origen — capabilities a migrar incrementalmente | DISCOVER/DESIGN |
| `mulesoft` | Orquestación — enrutamiento hacia motor nuevo | BUILD |
| `spei` | Riel MXN — integración con el motor nuevo | BUILD |
| `swift` | Riel internacional — integración con el motor nuevo | BUILD |
| `golden-record-target` | KYC contraparte en tiempo real (dependencia) | PREREQUISITO |
| `cnbv-banxico` | Generación automática DIOR desde motor nuevo | BUILD/TEST |
| `treasury` | Actualización de posiciones post-pago | INTEGRATE |

---

## PATRÓN DE MODERNIZACIÓN — STRANGLER-FIG

```
Fase 1: Encapsulación
  payments-legacy → ACL (Anti-Corruption Layer) → motor nuevo (shadow)

Fase 2: Coexistencia
  SPEI nuevo ← motor nuevo
  SWIFT heredado ← payments-legacy (parallel-run)

Fase 3: Cutover por riel
  SPEI: payments-legacy → motor nuevo (cutover)
  SWIFT: payments-legacy → motor nuevo (cutover)

Fase 4: Decommission
  payments-legacy → DEPRECATED
```

---

## CANDIDATOS TECNOLÓGICOS (para evaluar en DESIGN)

| Categoría | Candidatos | Criterio de evaluación |
|-----------|-----------|----------------------|
| Payment Hub | Temenos Payments · Form3 · Volante · Finastra | ISO 20022 nativo · CLS · API-first |
| Cloud | AWS (Payment Cryptography + EventBridge) · GCP (Cloud Spanner) | Cloud-native MONEX |
| Settlement | CLS Bank via SWIFT | Prerequisito: SWIFT Alliance |
| Mensajería | SWIFT MX · ISO 20022 | Nativo en la plataforma seleccionada |

---

## DIGITAL TWINS DEL PROYECTO

| DT | Pregunta central |
|----|-----------------|
| `dt/dt-as-is-payments/` | ¿Cuáles son exactamente las capabilities del payments-legacy? |
| `dt/dt-capability-map/` | ¿Qué capabilities migran a cuál riel/sistema en el TO-BE? |
| `dt/dt-vendor-evaluation/` | ¿Cuál plataforma candidata cumple mejor los requisitos? |
| `dt/dt-cutover-plan/` | ¿Cuál es el plan de cutover capability por capability? |

---

## ESTRUCTURA DEL PROYECTO

```
payments-modernization/
├── CLAUDE.md                    ← este archivo
├── source/
│   ├── docs/                    ← documentos de arquitectura y requerimientos MONEX
│   └── rfp/                     ← documentos del proceso de selección
├── digital-brain/
│   ├── brain.db                 ← brain del proyecto (gitignored)
│   ├── brain.py
│   └── build-brain.py
├── knowledge-base/
│   ├── capabilities/            ← capabilities del payments-legacy a migrar
│   ├── requirements/            ← requisitos funcionales y no funcionales
│   └── evaluation/              ← evaluación de plataformas candidatas
├── generators/
├── dt/
│   ├── dt-as-is-payments/
│   ├── dt-capability-map/
│   ├── dt-vendor-evaluation/
│   └── dt-cutover-plan/
└── portal/
```

---

## DoR DEL PROYECTO

- [ ] Documentos de requerimientos cargados en `source/docs/`
- [ ] Inventario de capabilities del payments-legacy completado
- [ ] Volúmenes actuales (SPEI/SWIFT por día) documentados
- [ ] SLAs del payments-legacy medidos (latencia, disponibilidad)
- [ ] Decisión de plataforma target (DESIGN gate)
- [ ] Stakeholders MONEX identificados (IT lead + Pagos lead + CNBV compliance)

---

## DATOS REALES DEL RFP (RFP-PAG v2.6)

**RFP cargado**: `source/rfp/RFP-PAY .pdf` — 33 páginas · 27-Ago-2026
**Brain activo**: 29 requisitos · 10 PAG caps · 13 principios · 12 AI reqs · 5 geografías

### Timeline crítico (hoy: 22-Sep-2026)

| Hito | Fecha | Estado |
|------|-------|--------|
| Propuesta entregada | 18-Sep-2026 | DONE |
| Evaluación/shortlist | 24-Sep-2026 | IN_PROGRESS |
| **Demostraciones** | **28-Sep-2026** | **PENDIENTE — 6 días** |
| Decisión final | 09-Oct-2026 | PENDIENTE |

### Escenarios de demostración (D-01 a D-10)

Los más críticos para MONEX: D-03 (SWIFT cross-border), D-04 (Sanciones), D-05 (Enrutamiento inteligente), D-08 (Conciliación AI), D-10 (Copiloto AI).

### Modelo de propuesta

Propuesta **conjunta Vendor + SI**. Accenture = SI. El SI lidera implementación, Fit-to-Standard, diseño, configuración, integración, migración, pruebas, cutover, adopción, seguridad y estabilización.

## PRÓXIMOS PASOS

1. **Preparar demostraciones** para el 28-Sep — mapear D-01 a D-10 a capabilities Accenture + plataforma
2. **Activar dt-as-is-payments** para mapear capabilities del payments-legacy
3. **Activar dt-vendor-evaluation** con scoring de plataformas según PAG-D07 v0.2
4. **Construir portal** con el knowledge base del RFP

---

## HANDOFFS SME

| SME | Cuándo | Para qué |
|-----|--------|----------|
| Integration Architecture | DISCOVER/DESIGN | Diseño ACL + enrutamiento MuleSoft |
| SWIFT/ISO 20022 SME | DESIGN | Conectividad SWIFT MX + CLS |
| SPEI/Banxico Regulatory | DESIGN | Requisitos DIOR embebidos |
| Cloud Architect (AWS o GCP) | DESIGN | Arquitectura cloud-native del motor |
| Software Engineering | BUILD | Implementación |
| QE — Equivalencia Funcional | TEST | Golden master payments |
| SRE & AIOps | RELEASE/OPERATE | Runbooks + SLOs |

---

*v1.2 · 2026-09-22 · RFP-PAG v2.6 ingerido — brain activo con 29 req + 10 PAG caps + 12 AI reqs. Próximo hito: demos 28-Sep. v1.1: Renombrado a Payments Modernization. v1.0: Scaffold inicial.*

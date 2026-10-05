# Sterling OMS — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: order-management
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Sterling OMS** |
| Vendor | IBM Sterling Order Management 10 |
| Host / Deployment | PLAN N5 / Cloud |
| TOGAF Type | `channels` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `differentiation` |
| Dominios retail | R04, R05 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Orquestación omnicanal de órdenes — recibe de ATG/POS/OMS-BT, distribuye a EWM/SOMS/TMS. Gestiona excepciones, cancelaciones, devoluciones.

---

## Stack Tecnológico

  - IBM Sterling OMS 10
  - Java

---

## Dependencias Conocidas

### Inbound (consume de):
  - ATG-Endeca (inbound)
  - SAP-EWM (fulfillment)
  - SOMS (mainframe orders)
  - TMS (transporte)

### Outbound (consume hacia):
  - Logística
  - Operaciones
  - Clientes (tracking)

---

## Hipótesis 7R

`Refactor (IBM Sterling upgrade) o Repurchase | SEÑAL DEUDA: 96.69% órdenes pendientes — revisar urgente`

---

## Notas Arquitectónicas

SUD OMS indica 96.69% órdenes pendientes y 83.33% en logística — señal crítica de deuda arquitectónica. PAO (Plataforma Administración Órdenes) es una capa adicional sobre Sterling.

---

## Estructura

```
systems/channels/Sterling-OMS/
├── source/
│   ├── code/     ← artefactos fuente del sistema (readonly)
│   ├── docs/     ← documentación técnica y funcional
│   └── ops/      ← configuración operativa y scripts
├── digital-brain/
│   ├── seeds/             ← seeds generados para sistemas vecinos
│   ├── brain.db           [PENDING — construir en Etapa 0]
│   ├── build-brain.py     [PENDING]
│   └── brain.py           [PENDING]
├── knowledge-base/
│   ├── rules/             [PENDING]
│   ├── vocab/             [PENDING]
│   ├── ontology/          [PENDING]
│   └── regulacion/        [PENDING]
├── generators/            [PENDING]
├── dt/                    [PENDING]
├── portal/data/           [PENDING]
├── old/
└── CLAUDE.md              ← este archivo
```

---

*Creado 2026-09-02 · Scaffold · Regla B9 — descubierto en Arquitectura_Liverpool_Dashboard_1.html · SPE-AM-003*

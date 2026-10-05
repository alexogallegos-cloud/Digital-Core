# IBM IIB (Broker) — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: enterprise-service-bus
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **IBM IIB (Broker)** |
| Vendor | IBM Integration Bus 10 |
| Host / Deployment | on-premise |
| TOGAF Type | `integration` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R01, R04, R05, R06 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Bus corporativo de mensajes — hub central de integración entre 15+ sistemas enterprise (SAP, ATG, SOMS, VPL, OMS, etc.). Con IBM MQ para colas asíncronas.

---

## Stack Tecnológico

  - IBM Integration Bus 10 (IIB)
  - IBM MQ

---

## Dependencias Conocidas

### Inbound (consume de):
  - (por confirmar en Etapa 0)

### Outbound (consume hacia):
  - SAP
  - ATG-Endeca
  - Sterling-OMS
  - SOMS
  - VPL-Vision-Plus
  - y 10+ sistemas más

---

## Hipótesis 7R

`Replatform (IBM App Connect Enterprise / MuleSoft / Azure Integration) | bus crítico — migración requiere inventario completo de flujos`

---

## Notas Arquitectónicas

Aparece en 15+ stacks del catálogo de servicios. La indisponibilidad del Broker impacta prácticamente toda la operación enterprise. IBM MQ gestiona las colas asíncronas.

---

## Estructura

```
systems/integration/IBM-IIB/
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

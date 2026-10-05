# Card Wizard — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: card-issuance
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Card Wizard** |
| Vendor | Card Wizard (por confirmar) |
| Host / Deployment | on-premise |
| TOGAF Type | `processors` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Emisión de tarjetas LiverpoolCard — personalización de plástico, activación, reposición, gestión de ciclo de vida de tarjeta.

---

## Stack Tecnológico

  - Card Wizard
  - Base 24
  - VPL Vision Plus
  - HSM

---

## Dependencias Conocidas

### Inbound (consume de):
  - FICO-TRIAD (aprobación crédito)
  - Base24 (activación)
  - VPL-Vision-Plus
  - HSM (cifrado)

### Outbound (consume hacia):
  - Sucursales (emisión en punto)
  - Canal digital (solicitud)

---

## Hipótesis 7R

`Retain o Repurchase | confirmar vendor exacto en Etapa 0`

---

## Notas Arquitectónicas

Stack: Base 24, Buró de Crédito, Card Wizard, FICO TRIAD, HSM, VPL Vision Plus (según STACKS[28,29]).

---

## Estructura

```
systems/processors/Card-Wizard/
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

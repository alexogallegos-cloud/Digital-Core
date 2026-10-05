# Base 24 — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: transaction-switch
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Base 24** |
| Vendor | ACI Worldwide |
| Host / Deployment | on-premise |
| TOGAF Type | `processors` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03, R05, R06 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Switch transaccional — enruta autorizaciones de tarjeta desde POS, ATG (checkout digital), ATM y terminales hacia VPL Vision Plus y sistemas de autorización.

---

## Stack Tecnológico

  - ACI Base 24
  - HSM

---

## Dependencias Conocidas

### Inbound (consume de):
  - VPL-Vision-Plus (autorización)
  - Bridgecore (POS inbound)

### Outbound (consume hacia):
  - POS (tiendas)
  - ATG (checkout digital)
  - Preautorizador

---

## Hipótesis 7R

`Retain o Replatform | crítico — migración de switch transaccional requiere PCI DSS recertificación`

---

## Notas Arquitectónicas

Aparece en 15+ stacks de servicio. Switch central de todas las transacciones de tarjeta Liverpool+Suburbia.

---

## Estructura

```
systems/processors/Base24/
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

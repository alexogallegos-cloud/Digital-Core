# Bridgecore — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: pos-gateway
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Bridgecore** |
| Vendor | Bridgecore / BridgePOS |
| Host / Deployment | on-premise |
| TOGAF Type | `channels` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `differentiation` |
| Dominios retail | R06, R03 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Gateway POS ↔ backend — enruta transacciones desde terminales BridgePOS a VPL Vision Plus, SOMS y SAP. Exclusivo Liverpool (SBB usa GSA).

---

## Stack Tecnológico

  - Bridgecore Server
  - Bridgecore Adapter
  - BridgePOS

---

## Dependencias Conocidas

### Inbound (consume de):
  - VPL-Vision-Plus (autorizaciones)
  - SOMS (órdenes)
  - SAP-ECC (inventario)

### Outbound (consume hacia):
  - POS tiendas Liverpool
  - App Vendedor / iPad

---

## Hipótesis 7R

`Retain (dependencia POS) o Refactor con migración a commercetools POS | analizar en Etapa 0`

---

## Notas Arquitectónicas

Distinto de IBM IIB — Bridgecore es específicamente el gateway POS para tiendas Liverpool. Suburbia usa GSA como POS.

---

## Estructura

```
systems/channels/Bridgecore/
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

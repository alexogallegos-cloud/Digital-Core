# ATG + Endeca — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: ecommerce-platform
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **ATG + Endeca** |
| Vendor | Oracle Commerce (ATG) + Oracle Endeca |
| Host / Deployment | on-premise + Akamai CDN (LIV) / on-premise (SBB) |
| TOGAF Type | `channels` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `differentiation` |
| Dominios retail | R05 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Motor de eCommerce AS-IS — liverpool.com.mx (LIV: ATG+Endeca+Akamai+Bridgecore) y suburbia.com (SBB: ATG+Endeca+Cybersource). TO-BE = commercetools.

---

## Stack Tecnológico

  - Oracle ATG
  - Oracle Endeca
  - Akamai (CDN LIV)
  - Bridgecore (POS LIV)
  - Cybersource (pago SBB)

---

## Dependencias Conocidas

### Inbound (consume de):
  - IBM-IIB (integración)
  - Sterling-OMS (órdenes)
  - VPL-Vision-Plus (crédito checkout)
  - Base24 (pagos)

### Outbound (consume hacia):
  - Clientes liverpool.com.mx
  - Clientes suburbia.com

---

## Hipótesis 7R

`Repurchase → commercetools MACH | migración ANUNCIADA 2026 (PR Newswire)`

---

## Notas Arquitectónicas

ESTADO ACTUAL: ATG+Endeca (legacy Oracle Commerce). commercetools NO está en producción aún — es el TO-BE anunciado. Análisis AS-IS urgente antes de inicio de migración.

---

## Estructura

```
systems/channels/ATG-Endeca/
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

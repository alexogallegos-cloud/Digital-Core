# Cyberfinancial — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: transitional
# togaf_system_of: record
# togaf_abb: collections-platform
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Cyberfinancial** |
| Vendor | EQUIFAX / Harman Navigator |
| Host / Deployment | SaaS EQUIFAX (AWS) |
| TOGAF Type | `processors` |
| TOGAF State | `transitional` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Plataforma de cobranza y análisis de crédito LiverpoolCard. Gestiona aging, mora, estrategias de cobranza y riesgo financiero.

---

## Stack Tecnológico

  - Harman Navigator
  - AWS (EQUIFAX SaaS)

---

## Dependencias Conocidas

### Inbound (consume de):
  - VPL-Vision-Plus (datos transaccionales)
  - GCP-DWH (analytics)

### Outbound (consume hacia):
  - Equipo Cobranza

---

## Hipótesis 7R

`Replatform (v8.4→v9C cloud — EN PROCESO) | migración ya iniciada por EQUIFAX`

---

## Notas Arquitectónicas

MIGRACIÓN EN CURSO: v8.4→v9C cloud EQUIFAX. Obsolescencia identificada en SUD. Soporte Equifax. ACC (CXEC 2.0) es el sistema de aclaraciones integrado.

---

## Estructura

```
systems/processors/Cyberfinancial/
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

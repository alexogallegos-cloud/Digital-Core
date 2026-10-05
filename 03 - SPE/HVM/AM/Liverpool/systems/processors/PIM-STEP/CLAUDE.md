# PIM (STEP) — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: product-information-management
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **PIM (STEP)** |
| Vendor | Stibo Systems STEP |
| Host / Deployment | SaaS Stibo Systems |
| TOGAF Type | `processors` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `differentiation` |
| Dominios retail | R01 |
| Criticidad | No |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Product Information Management — enriquecimiento de contenido de producto (títulos, descripciones, imágenes, atributos) para catálogo LIV+SBB.

---

## Stack Tecnológico

  - Stibo Systems STEP

---

## Dependencias Conocidas

### Inbound (consume de):
  - SAP-PDM (product master data)
  - SAP-PDTA (SBB)

### Outbound (consume hacia):
  - ATG-Endeca (catálogo digital)
  - eCommerce (content feed)

---

## Hipótesis 7R

`Retain o evolucionar con commercetools | PIM es componente del stack MACH`

---

## Notas Arquitectónicas

Aparece en STACKS[30,31]. Stibo STEP es SaaS. Alimenta el catálogo digital LIV+SBB.

---

## Estructura

```
systems/processors/PIM-STEP/
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

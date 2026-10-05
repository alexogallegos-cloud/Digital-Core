# FICO TRIAD — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: credit-origination
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **FICO TRIAD** |
| Vendor | FICO |
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

Originación de crédito LiverpoolCard — scoring APM (Application Processing Module) y OM (Operations Module), políticas de crédito, consulta Buró de Crédito.

---

## Stack Tecnológico

  - FICO TRIAD
  - SAS Viya (jobs TRIAD custom)

---

## Dependencias Conocidas

### Inbound (consume de):
  - Buro-de-Credito (consulta)
  - Base24 (switch)
  - VPL-Vision-Plus

### Outbound (consume hacia):
  - IVR-Credito
  - Mi-Credito (digital channel)
  - Data-Warehouse

---

## Hipótesis 7R

`Retain (plataforma FICO estable) o Repurchase (upgrade FICO cloud) | analizar versión y roadmap FICO`

---

## Notas Arquitectónicas

FICO TRIAD APM+OM. SAS Viya corre jobs de personalización de modelos TRIAD en GCP. Integra Buró de Crédito para originación.

---

## Estructura

```
systems/processors/FICO-TRIAD/
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

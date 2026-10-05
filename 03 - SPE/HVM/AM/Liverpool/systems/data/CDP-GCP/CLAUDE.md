# CDP — Customer Data Platform — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: data
# togaf_state: target
# togaf_system_of: innovation
# togaf_abb: customer-data-platform
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **CDP — Customer Data Platform** |
| Vendor | Internal / Google Cloud Platform |
| Host / Deployment | Google Cloud Platform (GKE) |
| TOGAF Type | `data` |
| TOGAF State | `target` (Baseline→Transitional→Target) |
| System-of-X | `innovation` |
| Dominios retail | R02, R09 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Plataforma de datos unificada de clientes — fuente única de verdad (Customer 360). Ingesta desde POS, ATG, OMS, SOMS, MDM. Expone APIs de cliente.

---

## Stack Tecnológico

  - GCP
  - GKE
  - PostgreSQL 13 HA
  - Dataflow
  - Pub/Sub
  - Microservicios Java

---

## Dependencias Conocidas

### Inbound (consume de):
  - POS
  - ATG-Endeca
  - Sterling-OMS
  - SOMS
  - MDM

### Outbound (consume hacia):
  - Portales B2B
  - APIs de cliente
  - Marketing

---

## Hipótesis 7R

`N/A — sistema nuevo en construcción (Data Architecture domain — no requiere equivalencia funcional)`

---

## Notas Arquitectónicas

isNew=true en dashboard. Sistema TARGET activo en construcción. GKE microservicios, PostgreSQL 13 HA, Dataflow orquesta. Futura base de personalización para commercetools.

---

## Estructura

```
systems/data/CDP-GCP/
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

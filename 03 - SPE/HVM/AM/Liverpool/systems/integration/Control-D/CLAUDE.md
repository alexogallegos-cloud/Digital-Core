# Control-D — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: mainframe-output-management
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Control-D** |
| Vendor | BMC Software |
| Host / Deployment | IBM z/OS (Mainframe) |
| TOGAF Type | `integration` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03, R07 |
| Criticidad | No |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Scheduler de batch mainframe + distribución de outputs — controla y distribuye estados de cuenta, manifiestos, reportes generados por VPL Vision Plus y SOMS.

---

## Stack Tecnológico

  - BMC Control-D
  - OpenText Exstream (downstream)

---

## Dependencias Conocidas

### Inbound (consume de):
  - VPL-Vision-Plus (data)
  - SOMS (data)
  - Mainframe-Clientes (data)

### Outbound (consume hacia):
  - OpenText-Exstream (estados cuenta)
  - Canales digitales (reportes)
  - SAP BW

---

## Hipótesis 7R

`Retain (co-dependiente con mainframe) | decommission al mismo tiempo que Mainframe encapsulation`

---

## Notas Arquitectónicas

Corre sobre z/OS. Orquesta los jobs de generación de estados de cuenta que van a OpenText Exstream. Es el 'Control-M del mainframe' de Liverpool.

---

## Estructura

```
systems/integration/Control-D/
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

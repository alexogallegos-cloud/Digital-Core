# Tumbleweed / Secure Transport — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: managed-file-transfer
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Tumbleweed / Secure Transport** |
| Vendor | Broadcom Tumbleweed |
| Host / Deployment | on-premise |
| TOGAF Type | `integration` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03, R07, R04 |
| Criticidad | No |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Managed File Transfer (MFT) — intercambio seguro de archivos batch con bancos, SAT, CNBV, transportistas y sistemas regulatorios.

---

## Stack Tecnológico

  - Broadcom Tumbleweed Secure Transport

---

## Dependencias Conocidas

### Inbound (consume de):
  - (por confirmar en Etapa 0)

### Outbound (consume hacia):
  - SAP ECC (pagos)
  - VPL-Vision-Plus (batch)
  - Mainframe (conciliaciones)

---

## Hipótesis 7R

`Replatform (MFT moderno cloud: GoAnywhere, AWS Transfer Family) | confirmar volumen de flujos`

---

## Notas Arquitectónicas

Aparece en múltiples stacks de importaciones, pagos a proveedores, conciliaciones. También llamado 'Secure Transport' en algunos contextos.

---

## Estructura

```
systems/integration/Tumbleweed/
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

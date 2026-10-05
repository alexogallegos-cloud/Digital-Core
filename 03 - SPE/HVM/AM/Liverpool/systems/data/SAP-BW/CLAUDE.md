# SAP BW Híbrido — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: data
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: enterprise-data-warehouse
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **SAP BW Híbrido** |
| Vendor | SAP |
| Host / Deployment | on-premise (LIV) + Azure (SBB BW4 HANA) |
| TOGAF Type | `data` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R07, R09 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Data Warehouse empresarial — BW Híbrido (reporting Presidencia, consolida LIV+SBB), BW LIV (retail OBT), BW PDM (control ingresos), BW4 HANA SBB (Azure).

---

## Stack Tecnológico

  - SAP BW (LIV on-premise)
  - SAP BW4 HANA (SBB Azure)
  - SAP BusinessObjects
  - Oracle DB (BW Híbrido)

---

## Dependencias Conocidas

### Inbound (consume de):
  - SAP-ECC (LIV data)
  - SAP-S4HANA (SBB data)
  - SAP-PDM (ventas LIV)
  - SAP-PDTA (ventas SBB)

### Outbound (consume hacia):
  - Presidencia (BW Híbrido)
  - Contraloría (BW PDM)
  - Finanzas (BW LIV)
  - SAP BusinessObjects

---

## Hipótesis 7R

`Replatform (BW4 HANA / SAP DWC) | BW LIV on-premise, SBB ya en BW4 Azure — unificar plataforma`

---

## Notas Arquitectónicas

Tres instancias: BW Híbrido (consolidado, crítico Presidencia), BW LIV (retail), BW PDM (ingresos, CRÍTICO RDV 7am). SUDs separados para cada una. Batch cierre mes día 1.

---

## Estructura

```
systems/data/SAP-BW/
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

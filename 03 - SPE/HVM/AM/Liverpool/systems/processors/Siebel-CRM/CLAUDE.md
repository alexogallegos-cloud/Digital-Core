# Siebel CRM — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: crm
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Siebel CRM** |
| Vendor | Oracle Siebel |
| Host / Deployment | on-premise |
| TOGAF Type | `processors` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `differentiation` |
| Dominios retail | R02 |
| Criticidad | No |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

CRM corporativo — Call Center LiverpoolCard, gestión de lealtad, marketing CRM. Solo Liverpool (no Suburbia).

---

## Stack Tecnológico

  - Oracle Siebel
  - Oracle DB
  - JavaScript customizations

---

## Dependencias Conocidas

### Inbound (consume de):
  - (por confirmar en Etapa 0)

### Outbound (consume hacia):
  - Call Center
  - Marketing
  - Programa Lealtad

---

## Hipótesis 7R

`Repurchase (CRM moderno: Salesforce, Dynamics, o evolución a CDP GCP) | issues de código recurrentes`

---

## Notas Arquitectónicas

CRM legacy con customizaciones JavaScript con issues recurrentes (SUD). Candidato natural a repurchase dado CDP GCP emergente.

---

## Estructura

```
systems/processors/Siebel-CRM/
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

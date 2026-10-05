# Apigee — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: integration
# togaf_state: target
# togaf_system_of: innovation
# togaf_abb: api-gateway
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **Apigee** |
| Vendor | Google Apigee |
| Host / Deployment | Google Cloud Platform |
| TOGAF Type | `integration` |
| TOGAF State | `target` (Baseline→Transitional→Target) |
| System-of-X | `innovation` |
| Dominios retail | R05, R04 |
| Criticidad | No |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

API Gateway — deployment parcial actual (Apple/Samsung Care, Gestor4PL). NO es aún el gateway corporativo completo.

---

## Stack Tecnológico

  - Google Apigee

---

## Dependencias Conocidas

### Inbound (consume de):
  - (por confirmar en Etapa 0)

### Outbound (consume hacia):
  - Gestor4PL (GCP)
  - Apple/Samsung Care (NAPSE)

---

## Hipótesis 7R

`Evolve — expandir como API gateway corporativo hacia commercetools y CDP | hoy solo partial deployment`

---

## Notas Arquitectónicas

IMPORTANTE: Apigee está parcialmente desplegado. No es el API gateway central corporativo todavía. Con commercetools y CDP GCP será estratégico expandirlo.

---

## Estructura

```
systems/integration/Apigee/
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

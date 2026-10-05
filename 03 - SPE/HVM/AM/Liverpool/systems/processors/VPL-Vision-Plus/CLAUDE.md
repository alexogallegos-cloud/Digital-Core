# VPL Vision Plus — Liverpool Application Modernization

> Instancia del solution L4 Application Modernization · SPE-AM-003
> **Descubierto**: Arquitectura_Liverpool_Dashboard_1.html (fuente interna, 2026-06-16) · Regla B9

```
# togaf_type: processors
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: card-processing-core
# bian_domains: []  (N/A — retail)
```

---

## Identidad del Sistema

| Campo | Valor |
|---|---|
| Sistema | **VPL Vision Plus** |
| Vendor | FIS Global |
| Host / Deployment | IBM z/OS (Mainframe) |
| TOGAF Type | `processors` |
| TOGAF State | `baseline` (Baseline→Transitional→Target) |
| System-of-X | `record` |
| Dominios retail | R03, R02 |
| Criticidad | Sí — CRÍTICO |
| Estado brain | `[STATE: SCAFFOLD]` — estructura creada, análisis RE pendiente |
| Proyecto | `SPE-AM-003` |

---

## Rol Confirmado (Fuente: Dashboard AS-IS 2026-06-16)

Core del procesamiento LiverpoolCard — autorizaciones de tarjeta, estados de cuenta, cargos, intereses, saldos. Sistema central de todos los flujos SF.

---

## Stack Tecnológico

  - VPL Vision Plus
  - IBM z/OS
  - COBOL

---

## Dependencias Conocidas

### Inbound (consume de):
  - Base24 (inbound auth)
  - FICO-TRIAD (decisiones crédito)
  - Mainframe-Clientes

### Outbound (consume hacia):
  - Cyberfinancial (cobranza data)
  - OpenText-Exstream (estados de cuenta)
  - Control-D (output)
  - Digital-Platform Mi-Crédito

---

## Hipótesis 7R

`Encapsulate (API-fy) → Refactor | parallel-run obligatorio — SLA LiverpoolCard 24x7`

---

## Notas Arquitectónicas

Vendor FIS Global Vision Plus corriendo sobre IBM z/OS. NO es Oracle PL-SQL. Toda autorización LiverpoolCard pasa por este sistema.

---

## Estructura

```
systems/processors/VPL-Vision-Plus/
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

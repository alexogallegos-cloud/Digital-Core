# PayTrue / Prevención de Fraudes — Application Modernization Agent
# togaf_type: channels
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: fraud-prevention
# bian_domains: ["fraud-monitoring", "financial-crimes"]

> Hereda `CLAUDE.md` de Application Modernization (L4).
> Sistema: **PayTrue** · Tipo: `channels` · Estado: `baseline` · Producción: `live`
> Descubierto: inventario CTM 2026-08-12 (`ControlM/source/Cierre ControlM 12082026.xls`)

---

## Identidad del Sistema

**PayTrue** es el sistema de prevención de fraude transaccional de BanCoppel. Corre sobre servidores Python (`dccpyt01`, `dcmpyt01`). Recibe transacciones en tiempo real o batch y aplica modelos de scoring para detección de fraude.

Los jobs CTM en la carpeta `PRO_PAYTRUE_001` envían "Transacciones NO Financieras Clientes a PayTrue" — sugiriendo que PayTrue consume señales de comportamiento de clientes (no solo transacciones monetarias) para sus modelos.

Relacionado con `PFR-PREVENCION_FRAUDES` — carpeta CTM identificada en los mismos servidores Python.

---

## Dependencias Cross-Sistema (Regla B5 AM)

### Inbound — PayTrue recibe de:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` (Informix) | `feeds` | Señales de comportamiento de clientes (transacciones batch) |
| `controlm` | `orchestrates` | 56 jobs CTM en servidores Python (`PRO_PAYTRUE_001`, `PFR-PREVENCION_FRAUDES`) |

### Outbound — PayTrue envía a:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` / `apolo` | `notifies` | Alertas de fraude para bloqueo de transacciones |

---

## Estado del Brain

`[STATE: DISCOVERED]` — Estructura creada a partir de inventario CTM. Brain pendiente.

**DATO-REQUERIDO:**
- `DR-PT-001`: ¿PayTrue es un vendor externo o desarrollo interno?
- `DR-PT-002`: ¿Los modelos de fraude migran a Apolo o se mantiene PayTrue independiente?
- `DR-PT-003`: ¿Hay integración en tiempo real o solo batch?

---

*Descubierto: 2026-08-12 — inventario CTM. v0.1.*

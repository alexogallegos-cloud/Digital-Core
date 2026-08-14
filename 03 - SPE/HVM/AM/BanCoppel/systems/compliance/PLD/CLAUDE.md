# PLD / Minds AML — Application Modernization Agent
# togaf_type: compliance
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: aml-compliance
# bian_domains: ["financial-crimes", "regulatory-compliance"]

> Hereda `CLAUDE.md` de Application Modernization (L4).
> Sistema: **PLD** · Tipo: `compliance` · Estado: `baseline` · Producción: `live`
> Descubierto: inventario CTM 2026-08-12 (`ControlM/source/Cierre ControlM 12082026.xls`)

---

## Identidad del Sistema

**PLD / Minds** es el sistema de Prevención de Lavado de Dinero (AML) de BanCoppel. Corre sobre servidores dedicados (`dccpld01`, `dcmpld01`, `dccpld02`, `dcmpld02`, `plddb`, `plddbmty`) separados del core Informix. Gestiona la carga de información de transacciones, la detección de patrones sospechosos y la generación de reportes regulatorios CNBV.

Está mapeado al dominio D15 (AML y Regulatorio) de Informix — los SPs de Informix en `bdilide`, `bdiauditor`, `bdisitesp` generan las señales que PLD/Minds consume.

**Regulación aplicable:** CNBV Circular Única de Bancos (CUB) — disposiciones AML, LFPIORPI, reportes R17/R35 a la UIF, LIDE.

---

## Dependencias Cross-Sistema (Regla B5 AM)

### Inbound — PLD recibe de:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` (Informix D15) | `feeds` | SPs bdilide/bdisitesp generan señales AML batch |
| `controlm` | `orchestrates` | 208 jobs CTM en servidores PLD (PRO_PLD_MINDS_001) |

### Outbound — PLD reporta a:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| CNBV/UIF (externo) | `feeds` | Reportes R17/R35 LFPIORPI enviados a regulador |

---

## Estado del Brain

`[STATE: DISCOVERED]` — Estructura creada a partir de inventario CTM. Brain pendiente de construir cuando se obtenga el código fuente del sistema Minds / configuración de PLD.

**DATO-REQUERIDO:**
- `DR-PLD-001`: ¿Qué plataforma es "Minds"? (vendor, versión, lenguaje)
- `DR-PLD-002`: ¿Cuántos servidores PLD existen en producción?
- `DR-PLD-003`: ¿Qué reportes regulatorios genera y en qué formato?

---

*Descubierto: 2026-08-12 — inventario CTM. v0.1.*

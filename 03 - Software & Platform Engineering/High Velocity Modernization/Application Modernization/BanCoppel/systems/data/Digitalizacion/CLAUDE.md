# Digitalización / Expediente Documental — Application Modernization Agent
# togaf_type: data
# togaf_state: baseline
# togaf_system_of: differentiation
# togaf_abb: document-management
# bian_domains: ["document-management", "customer-management"]

> Hereda `CLAUDE.md` de Application Modernization (L4).
> Sistema: **Digitalizacion** · Tipo: `data` · Estado: `baseline` · Producción: `live`
> Descubierto: inventario CTM 2026-08-12 (`ControlM/source/Cierre ControlM 12082026.xls`)

---

## Identidad del Sistema

Sistema de gestión documental de BanCoppel. Corre sobre servidores de imagen (`dccimg01`, `dcmimg01`, `dccimg02`, `dcmimg02`). Gestiona el expediente digital de clientes: imágenes de identificaciones, contratos firmados, comprobantes, estados de cuenta generados, y archivos de intercambio con otras áreas.

Tiene 156 jobs en la malla CTM — incluyendo la carpeta `PRO_DIGITALIZACION_001`. Los jobs incluyen transferencias de archivos de reportes entre servidores (formato: centros de costos, cartera vigente/vencida, estados de cuenta).

---

## Dependencias Cross-Sistema (Regla B5 AM)

### Inbound — Digitalización recibe de:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` (Informix D35) | `feeds` | Domain bdidigital genera archivos batch de digitalización |
| `controlm` | `orchestrates` | 156 jobs CTM orquestan transferencias y procesos de imagen |

### Outbound — Digitalización envía a:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| SQL Server (`w-sql16`) | `feeds` | Archivos de reportes transferidos a servidor SQL |

---

## Estado del Brain

`[STATE: DISCOVERED]` — Estructura creada a partir de inventario CTM. Brain pendiente.

**DATO-REQUERIDO:**
- `DR-DIG-001`: ¿Qué sistema/vendor es el repositorio documental? (OpenText, Alfresco, etc.)
- `DR-DIG-002`: ¿El expediente digital forma parte del onboarding Apolo?
- `DR-DIG-003`: ¿Los documentos migran a un DMS nuevo en Unity o se mantiene el actual?

---

*Descubierto: 2026-08-12 — inventario CTM. v0.1.*

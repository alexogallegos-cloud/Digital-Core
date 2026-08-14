# DataStage / ETL — Application Modernization Agent
# togaf_type: data
# togaf_state: transitional
# togaf_system_of: differentiation
# togaf_abb: etl-integration
# bian_domains: []

> Hereda `CLAUDE.md` de Application Modernization (L4).
> Sistema: **DataStage** · Tipo: `data` · Estado: `transitional` · Producción: `live`
> Descubierto: inventario CTM 2026-08-12 (`ControlM/source/Cierre ControlM 12082026.xls`)

---

## Identidad del Sistema

**IBM InfoSphere DataStage** es el motor ETL de BanCoppel. Corre sobre servidores `dccinfsph2`, `dccinfsphe2`, `dccinfsph1`. Gestiona flujos de integración de datos entre sistemas: extracción desde Informix, transformación y carga hacia destinos como el Data Warehouse, reportes y sistemas externos.

**Hallazgo crítico en inventario CTM:** la carpeta `UTR-UNITY_TRANSACT` aparece en el host `datastage` — esto indica que DataStage ya está siendo utilizado para la integración de datos en el contexto de Unity/Transact. DataStage es parte de la malla de migración, no solo del legacy.

---

## Dependencias Cross-Sistema (Regla B5 AM)

### Outbound — DataStage extrae de:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` (Informix) | `reads` | Extracción de datos históricos para DW/reportes |

### Outbound — DataStage carga hacia:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `transact` | `feeds` | Integración Unity `UTR-UNITY_TRANSACT` — datos para Transact |
| DW/BI (externo) | `feeds` | Datos para Business Intelligence BanCoppel |

### Inbound:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `controlm` | `orchestrates` | Jobs CTM en `PRO_DATA_WAREHOUSE_001` orquestan jobs DataStage |

---

## Estado del Brain

`[STATE: DISCOVERED]` — Estructura creada a partir de inventario CTM. Brain pendiente de construir cuando se obtenga el catálogo de jobs DataStage (exports `.dsx` o `.isx`).

**DATO-REQUERIDO:**
- `DR-DS-001`: ¿Hay exports de jobs DataStage disponibles (.dsx/.isx)?
- `DR-DS-002`: ¿Cuántos jobs en `UTR-UNITY_TRANSACT`? ¿Qué datos mueven?
- `DR-DS-003`: ¿DataStage es el Atlas de la migración o un sistema paralelo?

---

*Descubierto: 2026-08-12 — inventario CTM. Hallazgo clave: `UTR-UNITY_TRANSACT`. v0.1.*

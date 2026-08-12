# Control-M / Malla Batch — Application Modernization Agent
# togaf_type: integration
# togaf_state: baseline
# togaf_system_of: record
# togaf_abb: batch-orchestration
# bian_domains: []

> Hereda `CLAUDE.md` de Application Modernization (L4).
> Sistema: **ControlM** · Tipo: `integration` · Estado: `baseline` · Producción: `live`

---

## Identidad del Sistema

**BMC Control-M** es el orquestador de la malla batch de BanCoppel. Gestiona la ejecución de los procesos nocturnos, de fin de semana y regulatorios que corren sobre Informix/PISA: cierre de día, liquidación SPEI/CECOBAN, conciliación operativa, reportería CNBV, generación de estados de cuenta, y carga de archivos externos.

Control-M **no contiene lógica de negocio propia** — la lógica vive en los SPs de Informix. Lo que Control-M sabe es: cuándo correr un job, en qué orden (dependencias entre jobs), qué ventana temporal tiene disponible, y qué hacer cuando un job falla (retry, alertas, escalamiento).

**Rol en el programa Unity:** Control-M no desaparece con PISA — la malla batch migra hacia los sistemas target (Transact, Apolo) pero el orquestador seguirá siendo Control-M u otro scheduler equivalente. El análisis de la malla actual es prerequisito para diseñar la malla target.

---

## Dependencias Cross-Sistema (Regla B5 AM)

### Outbound — ControlM necesita a:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` (Informix) | `orchestrates` | Invoca SPs batch de Informix en ventanas programadas |
| `smartvista` | `calls` | Jobs de reportería Visa/MC al final del día |
| `atlas` | `notifies` | Señales de inicio/fin de ventana batch para extracción |

### Inbound — dependen de ControlM:
| Sistema | Tipo | Descripción |
|---------|------|-------------|
| `pisa` | `orchestrates` | Informix batch solo corre si CTM lo dispara |
| Banxico/CECOBAN | `feeds` | Los archivos SPEI salen del batch nocturno CTM→PISA |

---

## Estructura del Brain (cuando esté construido)

El `digital-brain/brain.db` de Control-M contendrá:

| Tabla | Contenido |
|-------|-----------|
| `jobs` | Catálogo de jobs: nombre, folder, servidor, schedule, sistema invocado |
| `job_dependencies` | Cadena de dependencias entre jobs (job A → job B → job C) |
| `schedules` | Calendarios: ventanas nocturnas, fin de semana, fin de mes, regulatorias |
| `sp_invocations` | Mapeo job → SP de Informix que invoca (si está disponible en el export) |
| `flow_chains` | Flujos completos: nombre del proceso batch end-to-end (ej. "Cierre SPEI") |
| `cross_dependencies` | Dependencias cross-sistema (Regla B5 AM) — perspectiva de este brain |

---

## Fuentes de Datos

Artefactos esperados en `source/`:

| Carpeta | Tipo de archivo | Descripción |
|---------|----------------|-------------|
| `source/code/` | `.xls`, `.xlsx`, `.csv` | Inventario de jobs exportado de CTM |
| `source/docs/` | `.pdf`, `.docx` | Documentación de la malla batch |
| `source/ops/` | `.json`, `.xml` | Exports directos de la API de BMC Control-M (si disponible) |

**Estado actual:** pendiente carga de inventario Excel (`Cierre ControlM 12082026.xls`).

---

## DATO-REQUERIDO

- `DR-CTM-001`: Número exacto de jobs activos en la malla CTM
- `DR-CTM-002`: Número de jobs que invocan SPs de Informix directamente
- `DR-CTM-003`: ¿Existe un export de dependencias entre jobs (cadena de ejecución)?
- `DR-CTM-004`: ¿Los jobs tienen información del SP/script de Informix que invocan?
- `DR-CTM-005`: ¿Hay jobs que ya apuntan a Transact o SmartVista (malla target parcial)?

---

*Última actualización: 2026-08-12 · v0.1 · Estructura inicial — brain pendiente de construir.*

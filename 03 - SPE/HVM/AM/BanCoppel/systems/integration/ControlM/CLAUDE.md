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

## Brain — Estado Actual

`digital-brain/brain.db` construido desde fuente real (`source/Cierre ControlM 12082026 (1) (1).xls`):

| Tabla | Contenido | Filas |
|-------|-----------|-------|
| `jobs` | Catálogo de jobs: nombre, folder, tipo, servidor, sitio, host, usuario, script | 5,052 |
| `flows` | Procesos batch por folder/carpeta — estadísticas agregadas (OS, AFT, Informix, Unity) | 65 |
| `sp_hints` | Referencias a SPs de Informix encontradas en nombre o script de jobs | 1,107 |
| `cross_dependencies` | Dependencias cross-sistema (Regla B5 AM) — perspectiva CTM | 4 |

### Hallazgos clave (build 2026-08-12)

- **5,052 jobs totales** — 3,859 corren en servidores Informix (`dccsif01`/`dcmsif01`) — 1,243 son AFT (file transfers)
- **32 jobs Unity** ya en producción — carpeta `USV-UNITY_SMARTVISTA_001` (SmartVista R2/R3 en producción parcial)
- **1,107 SP hints** — referencias a SPs encontradas en nombres de jobs (ej. `sp_generaredoctaeje_factelect_pag`)
- **65 flows/carpetas** con dominio Informix mapeado — PRO_JOBS_001 (multi-dominio, 3,042 jobs) es el flujo principal
- **Dos sitios replicados**: CLN (Culiacán) + MTY (Monterrey) — carpetas `_001` + `_001_MTY`

### DATO-REQUERIDO — pendiente

- `DR-CTM-003` parcial: export actual no incluye dependencias job→job (cadena de ejecución) — requiere export adicional desde CTM API o doc de malla
- `DR-CTM-004` parcial: SP hints extraídos por regex del nombre del job; la columna `Mem Name` en su mayoría contiene scripts `.sh`, no el nombre del SP directamente

---

## Fuentes de Datos

| Ruta | Tipo | Descripción |
|------|------|-------------|
| `source/Cierre ControlM 12082026 (1) (1).xls` | Excel `.xls` | Inventario completo de jobs exportado de BMC Control-M — 5,052 jobs · cargado 2026-08-12 |
| `source/docs/` | `.pdf`, `.docx` | Documentación de la malla batch (pendiente) |
| `source/ops/` | `.json`, `.xml` | Exports directos de la API CTM con dependencias job→job (pendiente) |

---

*Última actualización: 2026-08-12 · v0.2 · Brain construido — 5,052 jobs · 3,859 Informix · 1,107 SP hints · 32 Unity · 65 flows.*

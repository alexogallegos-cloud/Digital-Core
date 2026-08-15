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

`digital-brain/brain.db` construido desde fuente real (`source/Cierre ControlM 12082026 (1) (1).xls`) + enriquecido con 1,789 scripts `.sh` de `source/code/`:

| Tabla | Contenido | Filas |
|-------|-----------|-------|
| `jobs` | Catálogo de jobs: nombre, folder, tipo, servidor, sitio, host, usuario, script | 5,052 |
| `flows` | Procesos batch por folder/carpeta — estadísticas agregadas (OS, AFT, Informix, Unity) | 65 |
| `sp_hints` | Referencias a SPs — desde nombre/script de jobs + contenido real de `.sh` | 1,107 + 109 |
| `cross_dependencies` | Dependencias cross-sistema (Regla B5 AM) — perspectiva CTM | 4 |
| `sh_scripts` | Análisis de 1,789 scripts .sh: DBs, SPs, SSH calls, finderr, mail, retcode | 1,789 |
| `sh_sp_refs` | SP references extraídas de contenido real de scripts (high/medium confidence) | 200 |

### Hallazgos clave (build 2026-08-12 + parse-sh-scripts 2026-08-14)

- **5,052 jobs totales** — 3,859 en servidores Informix (`dccsif01`/`dcmsif01`) — 1,243 AFT
- **32 jobs Unity** en producción — `USV-UNITY_SMARTVISTA_001` (SmartVista R2/R3)
- **65 flows/carpetas** — PRO_JOBS_001 (multi-dominio, 3,042 jobs) es el flujo principal
- **Dos sitios replicados**: CLN (Culiacán) + MTY (Monterrey)
- **200 SP refs desde contenido real de scripts**: 107 `execute procedure` (alta confianza) + 93 echo/sql-filename (media confianza)
- **1,033 scripts con `finderr`** (57.7%) — captura de error Informix presente en la mayoría de los scripts; patrón crítico para equivalencia funcional (el sistema target debe mantener los mismos códigos de retorno)
- **4 SSH calls al servidor `10.26.214.85`** — todos relacionados con nómina: `Eje_Nom.sh`, `Eje_Nom2.sh`, `Eje_Nom3.sh`, `Eje_NomCopiar.sh` → servidor de nómina externo (Grupo Coppel)
- **`intercard`** aparece como DB en 6 refs de scripts — sistema de tarjetas no mapeado en D01-D49 (posiblemente SmartVista/BPC en proceso de migración al sistema Unity)
- **DB más activas en CTM**: `bdicred` (57) · `bdimnsj` (36) · `bdinteg` (24) · `bdicheq` (23)
- **SP más frecuente**: `sp_chi_notifica_resultados` en `bdimnsj` × 17 scripts — sistema de notificaciones crítico

### DR-CTM-004 — CERRADO PARCIALMENTE (2026-08-14)

`generators/parse-sh-scripts.py` extrae SP refs desde el contenido real de los 1,789 scripts `.sh`:
- 107 `execute procedure "informix".{sp_name}()` — confianza alta
- 93 desde echo messages + nombres de sql files referenciados — confianza media
- 109 new sp_hints enlazados a jobs por `mem_name`
- Nota: algunos nombres capturados (`monthadd`, `pasecont`) son funciones built-in de Informix, no SPs custom — distinguibles por ausencia en `brain.db` de Informix

### DR-CTM-003 — aún abierto

Export actual no incluye dependencias job→job (cadena de ejecución dentro de la malla). Requiere export adicional desde CTM API o documento de malla batch.

---

## Fuentes de Datos

| Ruta | Tipo | Descripción |
|------|------|-------------|
| `source/Cierre ControlM 12082026 (1) (1).xls` | Excel `.xls` | Inventario completo de jobs — 5,052 jobs · cargado 2026-08-12 |
| `source/code/*.sh` | Shell scripts | 1,789 scripts reales (+ 66 versiones backup `.sh_FECHA`) · cargados 2026-08-14 |
| `source/docs/` | `.pdf`, `.docx` | Documentación de la malla batch (pendiente) |
| `source/ops/` | `.json`, `.xml` | Exports CTM API con dependencias job→job (pendiente — DR-CTM-003) |

---

*Última actualización: 2026-08-14 · v0.3 · Shell scripts analizados — `generators/parse-sh-scripts.py`: 1,789 scripts · 200 SP refs · 1,033 con finderr · 4 SSH calls nomina · intercard descubierta · DR-CTM-004 cerrado parcialmente.*

# D13 · Transferencias Electrónicas de Fondos (TEF) — Matriz SP × Tabla

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción de accesos a tablas)
- Data Architect (mapeo a entidades del target)

---

## Descripción

Matriz de acceso SP × Tabla para el dominio `bditef`. Muestra qué SPs leen o escriben cada tabla, facilitando el análisis de impacto para la migración.

Leyenda de operaciones: `S` = SELECT · `I` = INSERT · `U` = UPDATE · `D` = DELETE · `X` = cross-DB (tabla en otra BD)

---

## Tablas propias de `bditef`

| Tabla | SPs que la acceden | Operaciones | Impacto migración |
|-------|------------------|-------------|-------------------|
| `cce_param` | `abono_cta`, `cargo_cta`, `cal_fechapre`, `sp_obtenerparametroscce`, `sp_obtenerparametroscce_pba` | S | Datos maestros — migrar antes del cutover |
| `cce_cheques_dev` | `cons_dev_coppel`, `sp_cce_chequesrevisados` | S, I | Transaccional — migrar con datos |
| `cce_propios_det` | `cargo_cta`, `ins_cheq_det`, `ins_cheq_det_web`, `ins_propios_det` | S, I | Transaccional |
| `tef_operaciones` | `sp_tef_grabaoperacion`, `sp_grabaoperaciontef`, `sp_tef_reversoperacion`, `sp_consultarepop_tef`, `sp_tef_buscaoperacion`, `sp_revoperacionestef` | S, I, U | CRÍTICA — tabla maestra de operaciones TEF |
| `tef_bitacora` | `sp_tef_bitacora`, `sp_tef_grabaoperacion` | I | Auditoría — migrar y mantener 5 años |
| `tef_archivos` | `sp_buscaarchivo_tef`, `sp_buscararchivos_tef`, `sp_tef_buscararchivo`, `sp_eliminaarchivo_tef`, `sp_reportearchivos_tef`, `sp_reportearchivos_tef2` | S, I, U | Control de archivos CECOBAN |
| `tef_detalle` | `sp_tef_procesararchivo60`, `sp_tef_procesararchivo61`, `sp_tef_procesararchivo62`, `sp_tef_procesararchivo63`, `sp_tef_generararchivo60` | S, I | Detalle de operaciones por archivo |
| `cce_encabezado` | `sp_cce_guardar_encabezado` | I | Encabezado de archivo CECOBAN |
| `cce_sumario` | `sp_cce_guardar_sumario` | I | Sumario de lote |
| `cce_gran_sumario` | `sp_cce_guardar_gransumario` | I | Gran sumario |
| `cce_detalle` | `sp_cce_guardar_detalle`, `sp_cce_consultar_detallecheques`, `sp_cce_consultar_detallecheques_pba` | S, I | Detalle de registros CECOBAN |
| `cce_usuarios_aut` | `sp_cce_consultausuariosaut`, `sp_cce_controlusuariosaut` | S, I, U | Seguridad — usuarios autorizados |
| `cce_cedula_usr` | `sp_cce_cedulausrmtto`, `sp_insert_cedula` | S, I, U | Perfil/cédula de usuario |
| `cce_archivos` | `sp_tef_guardarccearchivos` | I | Control de archivos guardados |

---

## Tablas cross-DB (accedidas desde `bditef`)

| Tabla | Base de datos | SPs de `bditef` que la acceden | Operaciones |
|-------|-------------|-------------------------------|-------------|
| `sc_fechas` | `bdicheq` | `abono_cta`, `cargo_cta` | S (X) |
| `sc_maechq` | `bdicheq` | `abono_cta`, `cargo_cta` | S (X) |
| `sc_movdia` | `bdicheq` | `cargo_cta`, `cons_dev_coppel` | S, I (X) |
| `sc_movhis` | `bdicheq` | `cons_dev_coppel` | S (X) |
| `sc_comisiones` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_producto` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_maecomtasserv_pm` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_ctabloqueo` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_bloqueo` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_contch` | `bdicheq` | `cargo_cta` | S (X) |
| `sc_detcomis` | `bdicheq` | `cargo_cta` | I (X) |
| `sc_docret_sbc` | `bdicheq` | `cal_fechapre` | S (X) |
| `sq_param` | `bdicntchq` | `cargo_cta` | S (X) |
| `si_feriado` | `bdinteg` | `cal_fecha_pre_fh`, `cal_fecha_pre_fh_web`, `cal_fechapre`, `cal_fecharet`, `cal_habil_ant` | S (X) |
| `si_param` | `bdinteg` | `cargo_cta` | S (X) |
| `si_coddevcam` | `bdinteg` | `cargo_cta` | S (X) |

---

## Top 5 SPs por número de tablas accedidas

| SP | Tablas propias | Tablas cross-DB | Total | Complejidad |
|----|---------------|----------------|-------|-------------|
| `cargo_cta` | 2 | 12 | 14 | MUY ALTA |
| `cons_dev_coppel` | 1 | 2 | 3 | MEDIA |
| `abono_cta` | 1 | 2 | 3 | MEDIA |
| `cal_fechapre` | 1 | 2 | 3 | MEDIA |
| `sp_tef_grabaoperacion` | `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | — | ALTA (por posición en callgraph) |

> `cargo_cta` es el SP más complejo del dominio con 14 tablas accedidas (12 cross-DB). Requiere atención especial en la estrategia de migración.

---

## `[SME-PENDING]`

- [ ] Completar la matriz para los 71 SPs aislados no incluidos en el análisis del callgraph.
- [ ] Identificar tablas con operaciones UPDATE o DELETE en SPs aislados (impacto en integridad de datos).
- [ ] Confirmar si existen tablas temporales (`TEMP TABLE`) en los SPs de procesamiento de archivos de cámara.

---
*Generado por análisis de tablas accedidas en sp-specs-bditef.md — sp-specs offset 0-600*

# D13 · Transferencias Electrónicas de Fondos (TEF) — Análisis de Código Muerto

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis de callgraph y SPs aislados)
- Domain Expert — BanCoppel (validación de uso en producción)
- SME — DBA IBM Informix (consulta de logs de ejecución)

---

## Descripción

Análisis de código potencialmente muerto o infrautilizado en el dominio `bditef`. El criterio principal es la ausencia de un SP en el callgraph — indicador de que ningún otro SP lo invoca internamente.

**Importante:** Ausencia en callgraph NO equivale a código muerto. Un SP puede ser un entry point legítimo invocado directamente por el ESB, canal web, app móvil, o jobs batch. La clasificación definitiva requiere validación contra logs de producción.

---

## Resumen

| Categoría | Cantidad | Acción requerida |
|-----------|----------|-----------------|
| SPs en callgraph (conectados) | 68 | Migrar — funcionalidad mapeada |
| SPs aislados (no en callgraph) | 71 | Clasificar antes de decidir |
| Tokens SINTÉTICO en nombres de SPs | 87 | Validar con SME antes de usar como base de diseño |

---

## SPs aislados — clasificación preliminar

Los siguientes SPs no aparecen en el callgraph. Se agrupan por patrón de nombre para inferir su probable categoría funcional.

### Categoría 1 — Variantes de canal (`_web`, `_pba`, `2`, `3`)

Probable código activo pero para canales específicos no capturados en el análisis principal.

| SP aislado | Patrón | Probable estado |
|-----------|--------|----------------|
| `cal_fecha_pre_fh_web` | variante web | ACTIVO (canal web) |
| `cal_fechapre` | variante de `cal_fecha_pre_fh` | ACTIVO o LEGADO |
| `cal_fecharet` | variante ret | ACTIVO o LEGADO |
| `cal_habil_ant` | cálculo anterior | ACTIVO (batch nocturno probable) |
| `cons_dev_coppel2` | variante paginada | ACTIVO (paginación con `pRegistros`/`pRecuperacion`) |
| `cons_dev_coppel2_totales` | variante totales | ACTIVO |
| `cons_dev_coppel_pba` | variante PBA | ACTIVO (canal PBA) |
| `cons_dev_suc_web` | variante web sucursal | ACTIVO (canal web) |
| `cons_dev_suc_web2` | variante web sucursal v2 | ACTIVO o LEGADO |
| `cons_presenta_pba` | variante PBA | ACTIVO (canal PBA) |
| `ins_cheq_det_web` | variante web | ACTIVO (canal web) |
| `ins_img_det_web` | variante web | ACTIVO (canal web) |
| `sp_cce_consultar_chequesdev_devcoppel2` | variante v2 | ACTIVO o LEGADO |
| `sp_cce_consultar_chequesdev_devcoppel2_totales` | variante totales v2 | ACTIVO o LEGADO |
| `sp_cce_consultar_detallecheques_pba` | variante PBA | ACTIVO (canal PBA) |
| `sp_cons_presenta2` | variante paginada | ACTIVO |
| `sp_cons_presenta2_totales` | variante totales | ACTIVO |
| `sp_consimgnullcheque_web` | variante web | ACTIVO (canal web) |
| `sp_generarepopertef_web` | variante web | ACTIVO (canal web) |
| `sp_obtenerchequescce_pba3` | variante PBA v3 | ACTIVO o LEGADO |
| `sp_obtenerchequescce_pbas2` | variante PBA v2 | ACTIVO o LEGADO |
| `sp_obtienecheques2` | variante v2 | ACTIVO o LEGADO |
| `sp_obtienecheques2_totales` | variante totales | ACTIVO o LEGADO |

### Categoría 2 — SPs batch o de mantenimiento

Probable ejecución programada por scheduler sin invocación desde otros SPs.

| SP aislado | Probable función | Probable estado |
|-----------|-----------------|----------------|
| `sp_tef_moverregistroshist` | Mueve registros a histórico (archivado) | ACTIVO — batch nocturno |
| `sp_tef_generareplistnegra` | Genera reporte de lista negra | ACTIVO — batch periódico |
| `sp_tef_act_rep_sicam` | Actualiza reporte SICAM | ACTIVO — batch regulatorio |
| `sp_tef_domi_genrep30y60` | Genera reportes de dominiciliación 30/60 días | ACTIVO — batch mensual |
| `sp_tef_rep_lib_sif` | Reporte de libro SIF | ACTIVO — batch regulatorio |
| `sp_reportearchivos_tef` | Reporte de archivos TEF | ACTIVO — batch |
| `sp_reportearchivos_tef2` | Variante v2 del reporte | ACTIVO o LEGADO |

### Categoría 3 — SPs con nombre de operación puntual

Probable código de uso específico que puede ser entry point del ESB.

| SP aislado | Probable función |
|-----------|-----------------|
| `stat_cheque` | Consulta de estatus de cheque |
| `obtenerimagennula` | Obtiene imagen nula de cheque |
| `consnomcte` | Consulta nombre de cliente |
| `cons_img_nula1` | Consulta imagen nula v1 |
| `cons_img_nula1_mx2` | Variante mx2 |
| `cons_img_nula1_web` | Variante web |
| `cons_nom_cte` | Consulta nombre de cliente |
| `cons_tels` | Consulta teléfonos |
| `cons_tels_web` | Consulta teléfonos web |
| `ins_reg_devo` | Inserta registro de devolución |
| `ins_reg_devo2` | Variante v2 |
| `ins_reg_devo_pba` | Variante PBA |
| `ins_img_det` | Inserta imagen de detalle |
| `sp_firma_ejec` | Firma de ejecutivo (autorización) |
| `sp_valida_imagencheque` | Validación imagen cheque |
| `sp_validadiahabiltef` | Valida día hábil para TEF |
| `sp_validahorariotef` | Valida horario para TEF |
| `sp_validaimagencheque` | Validación imagen cheque |
| `sp_validaimagencheque_dev` | Variante devolución |
| `sp_validaimagenescheques` | Validación de imágenes |
| `sp_validaimagenescheques_pba` | Variante PBA |
| `sp_validaproductopermitido` | Valida si el producto permite la operación |

---

## Recomendación de acción por categoría

| Categoría | Acción |
|-----------|--------|
| Variantes de canal (`_web`, `_pba`, `2`, `3`) | Validar en logs de producción — probable migración como variante del mismo endpoint |
| Batch/mantenimiento | Mapear al scheduler del target — no son entry points de API |
| Operación puntual | Consultar al Domain Expert BanCoppel — confirmar si el ESB los invoca directamente |

---

## `[SME-PENDING]`

- [ ] Consultar logs de ejecución de los 71 SPs aislados en producción (DBA IBM Informix).
- [ ] Confirmar cuáles son entry points del ESB y cuáles son código inaccesible.
- [ ] Identificar si algún SP aislado tiene lógica de negocio no duplicada en los SPs del callgraph.
- [ ] Confirmar si los SPs `_pba` corresponden a un canal diferente o a una configuración de producto específica.

---
*Generado por análisis de callgraph vs. sp-specs — 71 aislados identificados en Grounding Pass v1.0*

# D01 · Canal Digital Web — Matriz SP × Tabla (READ / WRITE)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** ÚLTIMO · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert BanCoppel (validación funcional)
- Cybersecurity (riesgos PII, regulación CNBV/LFPDPPP)
- QA Lead — Equivalencia Funcional (estrategia de pruebas) ← NUEVO
- Cloud Architect AWS Banking (arquitectura target) ← NUEVO
> [SME-PENDING] = requiere sesión de validación antes de Etapa 2.
---

## Importancia para Etapa 2 (Data RE)

Esta matriz determina:
1. **Ownership de datos**: qué SP (y por ende qué microservicio target) es dueño de cada tabla
2. **Tablas compartidas**: múltiples SPs escriben → punto de contención → candidatas a patrón CQRS
3. **Prioridad CDC**: tablas con más escritores priorizan la configuración de Debezium / DMS
4. **Scope de migración**: tablas que solo leen SPs de código muerto pueden excluirse del scope

> 🔄 = SP usa `EXECUTE PROCEDURE` con variable — puede leer/escribir tablas adicionales no detectadas estáticamente.

## Resumen de tablas propias de `bdicnweb`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `systables` | Transaccional | 32 | 0 | 🟢 Solo lectura |
| `informix` | Transaccional | 7 | 14 | 🔴 14 SPs escriben |
| `TRIM` | Transaccional | 18 | 0 | 🟢 Solo lectura |
| `sw_sac_reporteabonoatmtmp` | Reportería / Temporal | 7 | 7 | 🔴 7 SPs escriben |
| `bdidigital` | Transaccional | 10 | 2 | 🟠 2 SPs escriben |
| `sw_evc_excluidos` | Transaccional | 6 | 5 | 🟠 5 SPs escriben |
| `STATISTICS` | Transaccional | 0 | 8 | 🔴 8 SPs escriben |
| `sw_cnt_tipoconsulta` | Transaccional | 7 | 0 | 🟢 Solo lectura |
| `cep_monitorcheques_tmp` | Reportería / Temporal | 3 | 3 | 🟠 3 SPs escriben |
| `sw_af_registros_tmp` | Reportería / Temporal | 3 | 3 | 🟠 3 SPs escriben |
| `sw_tr_info_tablas` | Transaccional | 6 | 0 | 🟢 Solo lectura |
| `sw_gs_area` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sc_cuentas_traspbenef` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sw_ro_resulcte` | Transaccional | 3 | 2 | 🟠 2 SPs escriben |
| `sw_gs_area_usuario` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sw_tr_cargamasiva_mantolineascredito_hist` | Histórico / Archivado | 5 | 0 | 🟢 Solo lectura |
| `sw_tr_cargamasiva_mantolineascredito` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `sw_ro_ctecta` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmpcapitalescta_` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `sw_ro_cteexp` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_activardesactivarproductos` | 25759 | 0 | `TRIM`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_tr_registrosreportepago`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `STATISTICS`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext |
| `sp_actualizacatczb_rh` | 19937 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizacatgcb_rh` | 19811 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizaclasificacion_gcb` | 19683 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizaformato_gcb` | 19593 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizasucursal` | 19502 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizatipo_gcb` | 19176 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizazona_gcb` | 19091 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movdia`  ⚠️ext | `bdicheq:sc_bitacora_abono_coppel_atm`  ⚠️ext, `bdicheq:sc_param_abono_coppel_atm`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sp_ofi_rec_faltantesarch_tmp`  ⚠️ext |
| `sp_actualizacalificaestatus` | 12747 | 0 | `SUBSTR`, `bdicheq:`  ⚠️ext, `bdicheq:sc_bines`  ⚠️ext, `bdicheq:sc_ctasinactinfor3anios3meses`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_docret_sbc`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_ca_buscaarchivosxml`  ⚠️ext |
| `eliminasolicusuariomc` | 11482 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_cuentas_concentradas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_param`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext |
| `sp_actualizacionctepmsnom` | 11417 | 0 | `BDIDIGITAL`, `CHARINDEX`, `TABLE`, `bdibi`, `bdicheq:`  ⚠️ext, `bdicheq:sc_cedulacontable`  ⚠️ext | `bdibi`, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_clientesduplicados`  ⚠️ext, `bdilide:`  ⚠️ext |
| `sp_activalidaciontelefono` | 10406 | 0 | `TRIM`, `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_maenoc`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdicheq:sc_tarjeta`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_area`  ⚠️ext, `bdicnweb:sw_gs_area_permisos`  ⚠️ext, `bdicnweb:sw_gs_area_solicitudes`  ⚠️ext |
| `sp_administradorespm_complementoinfo` | 9441 | 0 | `BdiSac:Sac_BTS_Payi`  ⚠️ext, `BdiSac:Sac_MovimientosHistorial`  ⚠️ext, `bdibei:bei_contratacion`  ⚠️ext, `bdibei:bei_servicio`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinvers:`  ⚠️ext, `cep_monitorcheques_tmp`, `informix` |
| `sp_adm_consultabitacora_usuarios` | 8779 | 0 | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdicnweb:sw_verificastatusentradasalida`  ⚠️ext, `bdicred:`  ⚠️ext | `STATISTICS`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext |
| `sp_actualizadomiciliocte2` | 8676 | 0 | `TABLE`, `bdicheq:`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:ccep_procesacod41detalle_tmp`  ⚠️ext, `bdicnweb:sw_expedientetotales_tmp`  ⚠️ext | `STATISTICS`, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisac:`  ⚠️ext |
| `sp_adm_consultabitacora_usuarios_totales` | 8665 | 0 | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdicnweb:sw_verificastatusentradasalida`  ⚠️ext, `bdicred:`  ⚠️ext | `STATISTICS`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext |
| `sp_adm_validacampos` | 8593 | 0 | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdicnweb:sw_verificastatusentradasalida`  ⚠️ext, `bdicred:`  ⚠️ext | `STATISTICS`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext |
| `sp_actualizasufijospm` | 8518 | 0 | `Bdinteg:si_fechas`  ⚠️ext, `TRIM`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_area`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud_hist`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_bloqueocre`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_actualizadatoscheque` | 7470 | 14 | `TRIM`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_clientes`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_inv_sucursales`  ⚠️ext | 🔄
| `sp_actualizastatusmonitorproceso` | 7261 | 31 | `BdiSac:Sac_BTS_Payi`  ⚠️ext, `BdiSac:Sac_MovimientosHistorial`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinvers:`  ⚠️ext, `cep_monitorcheques_tmp`, `informix` |
| `sp_actualizacambiobilletescaja` | 6995 | 0 | `TRIM`, `bdicheq:sc_cuentas_traspbenef`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdisolic:ss_cte_procesando`  ⚠️ext, `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualizacentrallincred` | 6850 | 0 | `TRIM`, `bdicheq:sc_cuentas_traspbenef`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdisolic:ss_cte_procesando`  ⚠️ext, `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualizacomprasdepositoscaja` | 6760 | 0 | `TRIM`, `bdicheq:sc_cuentas_traspbenef`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdisolic:ss_cte_procesando`  ⚠️ext, `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualizaregistrocaja` | 6651 | 0 | `TRIM`, `bdicheq:sc_cuentas_traspbenef`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdisolic:ss_cte_procesando`  ⚠️ext, `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualizasdosucursalcaja` | 6532 | 0 | `TRIM`, `bdicheq:sc_cuentas_traspbenef`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:sw_gs_registrosolicitud`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdicnweb:sw_tr_totales_masivo`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_mantolineascredito`  ⚠️ext, `bdisolic:ss_cte_procesando`  ⚠️ext, `bdisolic:ss_solicitudes_mc`  ⚠️ext |
| `sp_actualizareportespendientesarqueosuc` | 6471 | 0 | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdicnweb:sw_verificastatusentradasalida`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext | `STATISTICS`, `bdicnweb:`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_actualizareportespendientesentradasalida` | 6417 | 0 | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdicnweb:sw_verificastatusentradasalida`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext | `STATISTICS`, `bdicnweb:`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_actualizacion_cheques_presentar` | 6392 | 0 | `BdiSac:Sac_BTS_Payi`  ⚠️ext, `BdiSac:Sac_MovimientosHistorial`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinvers:`  ⚠️ext, `cep_monitorcheques_tmp`, `informix` |
| `sp_actualizacionctepmsnom2` | 6025 | 0 | `BDIDIGITAL:dg_params`  ⚠️ext, `TRIM`, `bdicheq:`  ⚠️ext, `bdicheq:sc_medianainflacion`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdicheq:sc_medianainflacion`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicnweb:tmp_arch_dot_suc`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_adminitasas_cargarchivo` | 5927 | 0 | `TRIM`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_clientes`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_inv_sucursales`  ⚠️ext | 🔄
| `sp_abm_canal_cobro` | 5264 | 0 | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_cg_billetesfalsos`  ⚠️ext, `bdicnweb:sw_verificastatusarchivodeclaracionide`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_catalog`  ⚠️ext | `STATISTICS`, `bdicnweb:`  ⚠️ext, `bdilide:`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_actualizapagocheque` | 5089 | 8 | `TRIM`, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bditef:`  ⚠️ext, `bditef:informix`  ⚠️ext, `systables` | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bditef:`  ⚠️ext |
| `sp_actualiza_admintransaciones` | 4735 | 0 | `Bdinteg:si_fechas`  ⚠️ext, `TRIM`, `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinvers:`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bditef:`  ⚠️ext, `sw_af_registros_tmp` |
| `sp_actualizaparametrosccl` | 4672 | 0 | `Intercard:`  ⚠️ext, `bdicheq:sc_cedulacontable`  ⚠️ext, `bditarjeta:`  ⚠️ext, `bditef:`  ⚠️ext | `bdicheq:sc_cedulacontable`  ⚠️ext |
| `sp_actualizaregistrodevolverext_tef` | 4599 | 0 | `Bdinteg:si_fechas`  ⚠️ext, `TRIM`, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinvers:`  ⚠️ext, `bdiprog:pp_Encabezado`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bditef:`  ⚠️ext, `sw_af_registros_tmp` |
| `sp_actualizaprocesoconau` | 4593 | 0 | `Intercard:`  ⚠️ext, `bdicheq:sc_cedulacontable`  ⚠️ext, `bditarjeta:`  ⚠️ext, `bditef:`  ⚠️ext | `bdicheq:sc_cedulacontable`  ⚠️ext |
| `sp_actualizaproghorariosccl` | 4538 | 0 | `Intercard:`  ⚠️ext, `bdicheq:sc_cedulacontable`  ⚠️ext, `bditarjeta:`  ⚠️ext, `bditef:`  ⚠️ext | `bdicheq:sc_cedulacontable`  ⚠️ext |
| `sp_adminitasas_ope_guardainfo` | 4293 | 0 | `TRIM`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_clientes`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_inv_sucursales`  ⚠️ext |
| `sp_admintasas_bitacoraerror` | 3980 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_movhis_old`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinvers:`  ⚠️ext, `informix` |
| `sp_admintasas_consultabitacora` | 3847 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_fechas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_movhis_old`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinvers:`  ⚠️ext, `informix` |
| `sp_admintasas_actualizastatuspagare` | 3714 | 0 | `TRIM`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext, `bdicnweb:`  ⚠️ext |
| `sp_ac_actualizactas` | 3592 | 0 | `bdiburo:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctasinformadas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_ac_busquedacuentas_total` | 3420 | 0 | `bdiburo:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctasinformadas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_ac_desbloquoctas` | 3361 | 0 | `bdiburo:`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctasinformadas`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_producto`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisuc:`  ⚠️ext |
| `sp_admintasas_consultapagare` | 3353 | 0 | `TRIM`, `bdiaclaracion:acl_aclaracion`  ⚠️ext, `bdiaclaracion:acl_producto`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_admintasas_inv_estatus`  ⚠️ext, `bdicheq:sc_admintasas_invcreciente`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinvers:`  ⚠️ext |
| `sp_actualizadomiciliocte` | 3001 | 0 | `bdicheq:sc_producto`  ⚠️ext, `bdicobranza:cb_rep_cart_quebrantar`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext | — | 🔄
| `sp_actualizacuentasdormidas` | 2942 | 0 | `TABLE`, `bdicheq:`  ⚠️ext, `bdicheq:sc_histbloq`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_maenoc`  ⚠️ext, `bdicnweb:`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdidigital` |
| `sp_actualizamonitorprocesos` | 2654 | 48 | `bdiatmist`, `bdicheq:sc_cedulacontableusuarios`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext, `bdicheq:sc_movhis_old`  ⚠️ext, `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_abono_ref_masivo` | 1642 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_areabloqueo`  ⚠️ext, `bdicheq:sc_bloqueo`  ⚠️ext, `bdicheq:sc_histbloq`  ⚠️ext, `bdicheq:sc_mae_estatus`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext | `bdicnweb:`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_bloqueocap`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_bloqueocap_hist`  ⚠️ext, `bdicnweb:sw_tr_cargamasiva_cancelacioncre`  ⚠️ext |
| `sp_abono_ref` | 431 | 3 | `bdicheq:`  ⚠️ext, `bdinteg:`  ⚠️ext, `sw_ro_ctecta`, `sw_ro_cteexp`, `sw_ro_resulcte` | `sw_ro_ctecta`, `sw_ro_cteexp`, `sw_ro_maeoficios`, `sw_ro_resulcte` |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdicnweb:`**: escrita por `sp_abm_canal_cobro`, `sp_admintasas_consultapagare`, `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizapagocheque`, `sp_actualizacuentasdormidas` ... y 40 más
- **`bdinteg:`**: escrita por `sp_abm_canal_cobro`, `sp_admintasas_consultapagare`, `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizacuentasdormidas`, `sp_actualizatipo_gcb` ... y 22 más
- **`bdicheq:`**: escrita por `sp_adm_consultabitacora_usuarios`, `sp_ac_actualizactas`, `sp_adminitasas_cargarchivo`, `sp_adm_validacampos`, `sp_ac_desbloquoctas` ... y 11 más
- **`informix`**: escrita por `sp_actualizastatusmonitorproceso`, `sp_adminitasas_cargarchivo`, `sp_actualizazona_gcb`, `sp_admintasas_bitacoraerror`, `sp_actualizasucursal` ... y 9 más
- **`bdisolic:`**: escrita por `sp_ac_actualizactas`, `sp_actualizazona_gcb`, `sp_ac_desbloquoctas`, `sp_ac_busquedacuentas_total`, `sp_activardesactivarproductos` ... y 7 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `informix` | `sp_actualizastatusmonitorproceso`, `sp_adminitasas_cargarchivo`, `sp_actualizazona_gcb` | 🔴 PRIMERA |
| `STATISTICS` | `sp_actualizadomiciliocte2`, `sp_abm_canal_cobro`, `sp_adm_consultabitacora_usuarios` | 🔴 PRIMERA |
| `sw_sac_reporteabonoatmtmp` | `sp_actualizazona_gcb`, `sp_actualizasucursal`, `sp_actualizatipo_gcb` | 🔴 PRIMERA |
| `sw_evc_excluidos` | `sp_adminitasas_cargarchivo`, `sp_admintasas_consultapagare`, `sp_admintasas_actualizastatuspagare` | 🔴 PRIMERA |
| `sw_af_registros_tmp` | `sp_actualizasufijospm`, `sp_actualiza_admintransaciones`, `sp_actualizaregistrodevolverext_tef` | 🟠 SEGUNDA |
| `cep_monitorcheques_tmp` | `sp_actualizastatusmonitorproceso`, `sp_actualizacion_cheques_presentar`, `sp_administradorespm_complementoinfo` | 🟠 SEGUNDA |
| `sw_ro_ctecta` | `sp_activalidaciontelefono`, `sp_abono_ref` | 🟡 TERCERA |
| `sw_ro_cteexp` | `sp_activalidaciontelefono`, `sp_abono_ref` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `BDIDIGITAL:dg_params` (R) — desde `sp_actualizacionctepmsnom2`
- `BdiSac:Sac_BTS_Payi` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_actualizacion_cheques_presentar`, `sp_administradorespm_complementoinfo`
- `BdiSac:Sac_MovimientosHistorial` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_actualizacion_cheques_presentar`, `sp_administradorespm_complementoinfo`
- `Bdinteg:si_fechas` (R) — desde `sp_actualizasufijospm`, `sp_actualiza_admintransaciones`, `sp_actualizaregistrodevolverext_tef`
- `Intercard:` (R) — desde `sp_actualizaparametrosccl`, `sp_actualizaproghorariosccl`, `sp_actualizaprocesoconau`
- `bdiaclaracion:acl_aclaracion` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `bdiaclaracion:acl_producto` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `bdibei:bei_contratacion` (R) — desde `sp_administradorespm_complementoinfo`
- `bdibei:bei_servicio` (R) — desde `sp_administradorespm_complementoinfo`
- `bdiburo:` (R) — desde `sp_ac_desbloquoctas`, `sp_ac_actualizactas`, `sp_ac_busquedacuentas_total`
- `bdicheq:` (R+W) — desde `sp_admintasas_consultapagare`, `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizapagocheque`
- `bdicheq:sc_admintasas_inv_clientes` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdicheq:sc_admintasas_inv_estatus` (R+W) — desde `sp_adminitasas_cargarchivo`, `sp_admintasas_consultapagare`, `sp_admintasas_actualizastatuspagare`
- `bdicheq:sc_admintasas_inv_sucursales` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdicheq:sc_admintasas_invcreciente` (R+W) — desde `sp_adminitasas_cargarchivo`, `sp_admintasas_consultapagare`, `sp_admintasas_actualizastatuspagare`
- `bdicheq:sc_areabloqueo` (R) — desde `sp_abono_ref_masivo`
- `bdicheq:sc_bines` (R) — desde `sp_actualizacalificaestatus`
- `bdicheq:sc_bitacora_abono_coppel_atm` (R+W) — desde `sp_actualizazona_gcb`, `sp_actualizasucursal`, `sp_actualizatipo_gcb`
- `bdicntchq:` (R) — desde `sp_actualizacionctepmsnom`
- `bdicnweb:` (R+W) — desde `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizapagocheque`, `sp_actualizacuentasdormidas`
- `bdicnweb:ccep_procesacod41detalle_tmp` (R) — desde `sp_actualizadomiciliocte2`
- `bdicnweb:rec_depfaltantes` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdicnweb:sc_cuentas_concentradas_procesadas` (R) — desde `sp_actualizacalificaestatus`
- `bdicnweb:si_cliente_emp_pru` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `bdicnweb:sp_ofi_rec_faltantesarch_tmp` (R+W) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdicnweb:sw_ca_buscaarchivosxml` (R+W) — desde `sp_actualizacalificaestatus`
- `bdicnweb:sw_cg_arqueosucajatmp` (R) — desde `sp_actualizacuentasdormidas`
- `bdicobranza:cb_param` (R) — desde `sp_activalidaciontelefono`, `sp_actinfosolicitudmc`
- `bdicobranza:cb_rep_cart_quebrantar` (R) — desde `sp_actualizadomiciliocte`
- `bdicont:` (R) — desde `sp_actualizaregistrocaja`, `sp_actualizasdosucursalcaja`, `sp_actualizadatoscheque`
- `bdicred:` (R+W) — desde `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizacuentasdormidas`, `sp_actualizatipo_gcb`
- `bdicred:sd_bitacora_pagos` (R) — desde `sp_activardesactivarproductos`, `sp_activalidaciontelefono`
- `bdicred:sd_ce_ctas_nostro` (R) — desde `sp_administradorespm_complementoinfo`
- `bdicred:sd_ctascarg` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `bdicred:sd_definicion` (R) — desde `sp_actualizaregistrocaja`, `sp_activardesactivarproductos`, `sp_activalidaciontelefono`
- `bdicred:sd_indicador_cred` (R) — desde `sp_actualizaregistrocaja`, `sp_actualizasdosucursalcaja`, `sp_actualizacentrallincred`
- `bdicred:sd_maecred` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_admintasas_consultapagare`, `eliminasolicusuariomc`
- `bdicred:sd_maecredcrd` (R) — desde `sp_activalidaciontelefono`, `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`
- `bdidigital:` (R+W) — desde `inserta_img_previo_soc2`
- `bdilide:` (R+W) — desde `sp_abono_ref_masivo`, `sp_abm_canal_cobro`, `sp_adm_consultabitacora_usuarios`
- `bdilide:sl_ftc_cat` (R) — desde `sp_actualizacionctepmsnom`
- `bdilide:sl_ftc_clas_cat` (R) — desde `sp_actualizacionctepmsnom`
- `bdilide:sl_ftc_log` (R+W) — desde `sp_actualizacionctepmsnom`
- `bdilide:sl_ftc_prm` (R+W) — desde `sp_actualizacionctepmsnom`
- `bdinteg:` (R+W) — desde `sp_abm_canal_cobro`, `sp_admintasas_consultapagare`, `sp_adm_consultabitacora_usuarios_totales`
- `bdinteg:si_admintasas_inv_tasames` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdinteg:si_apoderado` (R) — desde `sp_actualizacionctepmsnom2`
- `bdinteg:si_bancos` (R) — desde `sp_actualizaregistrocaja`, `sp_actualizastatusmonitorproceso`, `sp_admintasas_bitacoraerror`
- `bdinteg:si_cantpersonas` (R) — desde `sp_activalidaciontelefono`
- `bdinteg:si_catalog` (R) — desde `sp_activardesactivarproductos`, `sp_abm_canal_cobro`, `sp_adm_consultabitacora_usuarios`
- `bdinteg:si_catcalles` (R) — desde `sp_activalidaciontelefono`
- `bdinteg:si_catciudades` (R) — desde `sp_activalidaciontelefono`, `sp_actualizadomiciliocte`
- `bdinvers:` (R+W) — desde `sp_actualizastatusmonitorproceso`, `sp_actualiza_admintransaciones`, `sp_admintasas_consultapagare`
- `bdinvers:si_admintasas_inv_tasames` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdinvers:sv_admintasas_estatus` (R+W) — desde `sp_adminitasas_cargarchivo`, `sp_admintasas_consultapagare`, `sp_admintasas_actualizastatuspagare`
- `bdinvers:sv_admintasas_pagare` (R+W) — desde `sp_adminitasas_cargarchivo`, `sp_admintasas_consultapagare`, `sp_admintasas_actualizastatuspagare`
- `bdinvers:sv_admintasas_renovacion` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdinvers:sv_clientes_promocion` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdinvers:sv_cuentas_promocion` (R+W) — desde `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`, `sp_actualizadatoscheque`
- `bdinvers:sv_instrum` (R) — desde `sp_activalidaciontelefono`
- `bdiprog:pp_Encabezado` (R) — desde `sp_actualizasufijospm`, `sp_actualiza_admintransaciones`, `sp_actualizaregistrodevolverext_tef`
- `bdirech:` (R+W) — desde `sp_actualizazona_gcb`, `sp_actualizasucursal`, `sp_actualizatipo_gcb`
- `bdirech:rec_confaltante` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdirech:rec_deschistorico` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdirech:rec_descquincena` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdirech:rec_faltantesarch` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdirech:rec_movquebrantos` (R) — desde `sp_actualizatipo_gcb`, `sp_actualizaformato_gcb`, `sp_actualizacatgcb_rh`
- `bdirst:` (R+W) — desde `sp_abm_canal_cobro`, `sp_adm_consultabitacora_usuarios`, `sp_adm_validacampos`
- `bdisac:` (R+W) — desde `sp_actualizadomiciliocte2`, `sp_actualizastatusmonitorproceso`, `sp_actualiza_admintransaciones`
- `bdisac:sac_app_catestados` (R) — desde `eliminasolicusuariomc`
- `bdisac:sac_app_paises` (R) — desde `eliminasolicusuariomc`
- `bdisac:sac_app_payi` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_actualizacion_cheques_presentar`, `sp_administradorespm_complementoinfo`
- `bdisac:sac_bts_catmensajes` (R) — desde `sp_actualizadomiciliocte`
- `bdisac:sac_bts_catstatusremesas` (R) — desde `sp_actualizadomiciliocte`
- `bdisac:sac_convenios` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_actinfosolicitudmc`, `sp_actualizacalificaestatus`
- `bdisac:sac_movimientos` (R) — desde `sp_actualizacalificaestatus`
- `bdisitesp:` (R) — desde `sp_actualizazona_gcb`, `sp_actualizasucursal`, `sp_activardesactivarproductos`
- `bdisolic:` (R+W) — desde `sp_ac_actualizactas`, `sp_actualizazona_gcb`, `sp_adm_consultabitacora_usuarios_totales`
- `bdisolic:ss_autorizacion` (R) — desde `sp_activalidaciontelefono`
- `bdisolic:ss_cte_procesando` (R+W) — desde `sp_actualizaregistrocaja`, `sp_actualizasdosucursalcaja`, `sp_actualizacentrallincred`
- `bdisolic:ss_emp_revingresos_mc` (R+W) — desde `sp_actualizazona_gcb`, `sp_actualizasucursal`, `sp_actualizatipo_gcb`
- `bdisolic:ss_solicitudes_mc` (R+W) — desde `sp_actualizaregistrocaja`, `sp_actualizasdosucursalcaja`, `sp_actualizacentrallincred`
- `bdispei:` (R) — desde `sp_actualizacalificaestatus`
- `bdispei:tblhistpago` (R) — desde `sp_administradorespm_complementoinfo`
- `bdisuc:` (R+W) — desde `sp_abm_canal_cobro`, `sp_adm_consultabitacora_usuarios_totales`, `sp_actualizatipo_gcb`
- `bdisuc:ss_cajageneral` (R) — desde `sp_actualizaregistrocaja`, `sp_actualizasufijospm`, `sp_actualizasdosucursalcaja`
- `bdisuc:ss_catalago_etv` (R) — desde `sp_actualizacalificaestatus`
- `bdisuc:ss_catstatus` (R) — desde `sp_actualizacionctepmsnom`
- `bdisuc:ss_concilsdocont` (R) — desde `sp_actualizasufijospm`
- `bdisuc:ss_operaciones` (R) — desde `sp_actualizacionctepmsnom`
- `bdisuc:ss_pase_sucursal` (R) — desde `sp_actualizaregistrocaja`, `sp_actualizasdosucursalcaja`, `sp_actualizacentrallincred`
- `bdisuc:ss_saldossuc` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_admintasas_consultabitacora`, `sp_actualizacion_cheques_presentar`
- `bditarjeta:` (R) — desde `sp_actualizaparametrosccl`, `sp_actualizaproghorariosccl`, `sp_actualizaprocesoconau`
- `bditef:` (R+W) — desde `sp_actualizadomiciliocte2`, `sp_actualizastatusmonitorproceso`, `sp_actualiza_admintransaciones`
- `bditef:cce_cheques_dev` (R) — desde `sp_actualizadomiciliocte2`, `sp_actualizastatusmonitorproceso`, `sp_admintasas_consultabitacora`
- `bditef:cce_cheques_img` (R) — desde `sp_actualizadomiciliocte2`
- `bditef:cce_detalle` (R) — desde `sp_actualizadomiciliocte2`, `sp_actualizastatusmonitorproceso`, `sp_admintasas_consultabitacora`
- `bditef:cce_encabezado` (R) — desde `sp_actualizadomiciliocte2`
- `bditef:cce_mapeo_cecoban` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_actualizacion_cheques_presentar`, `sp_administradorespm_complementoinfo`
- `bditef:cce_param` (R) — desde `sp_actualizadomiciliocte2`, `sp_actualizastatusmonitorproceso`, `sp_administradorespm_complementoinfo`
- `bditef:cce_usuarios_revision` (R) — desde `sp_actualizastatusmonitorproceso`, `sp_administradorespm_complementoinfo`
- `bditransfer:` (R) — desde `eliminasolicusuariomc`, `sp_actualizastatusmonitorproceso`, `sp_admintasas_consultabitacora`
- `bditransfer:tf_account_balance_customer` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `bditransfer:tf_maecte` (R) — desde `sp_admintasas_actualizastatuspagare`, `sp_adminitasas_ope_guardainfo`, `sp_adminitasas_cargarchivo`
- `intercard:` (R+W) — desde `sp_ac_actualizactas`, `sp_actualizazona_gcb`, `sp_ac_desbloquoctas`
- `intercard:bitacora_msi` (R) — desde `sp_actualizadomiciliocte2`
- `intercard:movimiento` (R) — desde `sp_activalidaciontelefono`, `sp_actualizadomiciliocte2`
- `intercard:movimientohistorico` (R) — desde `sp_activalidaciontelefono`, `sp_actualizadomiciliocte2`
- `intercard:statustarjeta` (R) — desde `sp_activalidaciontelefono`
- `intercard:tarjeta` (R) — desde `sp_activalidaciontelefono`
- `intercard:tarjetacuenta` (R) — desde `sp_activalidaciontelefono`
- `sysmaster:sysshmvals` (R) — desde `sp_actualizazona_gcb`, `sp_actualizacalificaestatus`, `sp_actualizasucursal`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicnweb_*.sql (análisis estático de 57 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

# D11 · Cobranza — Matriz SP × Tabla (READ / WRITE)

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 2 · Riesgo: **MEDIO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, code extraction)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2) ← NUEVO
- Industry Banking + Domain Expert LegacyCore (validación funcional)
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

## Resumen de tablas propias de `bdicobranza`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `cb_errores` | Log / Bitácora | 13 | 0 | 🟢 Solo lectura |
| `statistics` | Transaccional | 0 | 11 | 🔴 11 SPs escriben |
| `cb_cat_compctes` | Catálogo / Config | 5 | 5 | 🟠 5 SPs escriben |
| `cb_param_campania` | Catálogo / Config | 9 | 0 | 🟢 Solo lectura |
| `cb_cat_directorio_cte` | Catálogo / Config | 9 | 0 | 🟢 Solo lectura |
| `STATISTICS` | Transaccional | 0 | 9 | 🔴 9 SPs escriben |
| `cb_tabla_temporal` | Reportería / Temporal | 7 | 0 | 🟢 Solo lectura |
| `cb_bitacora_cob` | Log / Bitácora | 1 | 4 | 🟠 4 SPs escriben |
| `cb_info_administrativa` | Transaccional | 1 | 3 | 🟠 3 SPs escriben |
| `tmp_totalesmora4` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmp_totalesmora3` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `cb_bitacora` | Log / Bitácora | 0 | 4 | 🟠 4 SPs escriben |
| `tmp_compagconvsem_mat` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmp_totalesmoratel2` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmp_totalesmora2` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmp_compagconvsem_vesp` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `tmp_telefonos_buro_2` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `cb_rep_resultado_sms_hist` | Histórico / Archivado | 0 | 3 | 🟠 3 SPs escriben |
| `systables` | Transaccional | 3 | 0 | 🟢 Solo lectura |
| `informix` | Transaccional | 1 | 2 | 🟠 2 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA LegacyCore.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `fn_formaretiquetaxml` | 32559 | 0 | `BDICOBRANZA:CB_COMPAC`  ⚠️ext, `BDINTEG:si_sucursales`  ⚠️ext, `Bdicobranza:`  ⚠️ext, `Bdicobranza:cb_gestion_telefonica`  ⚠️ext, `Bdicobranza:cb_param`  ⚠️ext, `Bdinteg:si_direcciones`  ⚠️ext | `BDICOBRANZA:CB_COMPAC`  ⚠️ext, `Bdicobranza:cb_gestion_telefonica`  ⚠️ext, `STATISTICS`, `TME_ENCABEZADOS` | 🔄
| `sp_cat_gen_info_admin` | 1570 | 7 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_compac`  ⚠️ext, `bdicobranza:cb_compac_bit_realiza`  ⚠️ext, `bdicobranza:cb_paso_compac`  ⚠️ext, `bdicred:`  ⚠️ext | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_paso_compac`  ⚠️ext, `directorio_cte`, `statistics` |
| `sp_cat_consulta_totales` | 1387 | 0 | `Bdicobranza:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_alerta_succliente`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_marcacliente`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_alerta_succliente`  ⚠️ext |
| `sp_cat_graba_telefono_adicional` | 1315 | 15 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_campania`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_compac_montomin`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva_his`  ⚠️ext | `STATISTICS`, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_bitacora`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva_his`  ⚠️ext |
| `sp_cat_consulta_saldostc` | 1162 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_campania`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_compac_montomin`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva_his`  ⚠️ext | `STATISTICS`, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_bitacora`  ⚠️ext, `bdicobranza:cb_evaluacion_objetiva_his`  ⚠️ext |
| `sp_actualiza_saldos_admin_tco` | 617 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext | `bdimnsj:mnsjr_trx_batch`  ⚠️ext, `statistics` |
| `sp_actualiza_saldos_admin` | 513 | 1 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext | `bdicobranza:`  ⚠️ext, `bdimnsj:mnsjr_trx_batch`  ⚠️ext, `statistics` |
| `sp_campania_experiencia_cliente` | 346 | 0 | `bdicred:sd_definicion`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_info_edocta`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext | `STATISTICS` |
| `convert_to_date` | 13 | 0 | — | — |
| `inserta_bitacora_cob` | 27 | 0 | `sysmaster:sysshmvals`  ⚠️ext | `bdicobranza:cb_bitacora`  ⚠️ext, `cb_bitacora` |
| `sp_actualiza_catdirectoriocte` | 630 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_campania`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_indicador_cred`  ⚠️ext | `STATISTICS`, `bdicobranza:cb_bitacora`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext |
| `sp_actualiza_catdirectoriocte_pba` | 3866 | 0 | `BDINTEG:si_sucursales`  ⚠️ext, `TABLE`, `TRIM`, `bdicheq:sc_maechq`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_coloca_revolventes`  ⚠️ext, `bdicred:sd_totalcte_campania`  ⚠️ext |
| `sp_actualiza_contacto_exitoso` | 66 | 0 | `bdinteg:si_telefonos_actual`  ⚠️ext | `bdinteg:si_telefonos_actual`  ⚠️ext |
| `sp_actualiza_contacto_historico` | 65 | 0 | `bdicobranza:cb_registro_llamadas`  ⚠️ext, `bdinteg:si_telefonos_actual`  ⚠️ext | `bdinteg:si_telefonos_actual`  ⚠️ext |
| `sp_actualiza_ejecutivoscat` | 199 | 0 | `bdicobranza:cb_cat_datosgenerales_temp`  ⚠️ext, `bdicobranza:cb_catejecutivos_temp`  ⚠️ext, `bdicobranza:cb_param`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `cb_cat_datosgenerales_temp`, `sysmaster:systabnames`  ⚠️ext | `bdicobranza:cb_cat_datosgenerales_temp`  ⚠️ext, `bdicobranza:cb_catejecutivos_temp`  ⚠️ext |
| `sp_archivo_compac` | 285 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_compac`  ⚠️ext, `bdicobranza:cb_paso_compac`  ⚠️ext, `bdicred:sd_conceptospagomanual`  ⚠️ext, `bdicred:sd_conceptospagomanualcrd`  ⚠️ext, `bdicred:sd_indicador_cred`  ⚠️ext | `bdicobranza:cb_paso_compac`  ⚠️ext |
| `sp_archivo_compac_pba` | 196 | 0 | `bdicobranza:cb_compac`  ⚠️ext, `bdicobranza:cb_compac_his`  ⚠️ext, `bdicobranza:cb_paso_compac`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_movhis`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext | `bdicobranza:cb_paso_compac`  ⚠️ext |
| `sp_asigna_cartera_agex` | 725 | 0 | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_gestion_cobagext_clasifica`  ⚠️ext, `bdicred:`  ⚠️ext, `paso_catdircte_anterior` | `STATISTICS` |
| `sp_auronix_msj` | 91 | 0 | `bdinteg:si_ciudades`  ⚠️ext, `bdisitesp:se_ctessitespcte`  ⚠️ext, `bdisitesp:se_situacionaccion`  ⚠️ext, `cb_cat_directorio_cte` | — |
| `sp_borra_cteduplicados` | 44 | 0 | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `cte_dup` | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext |
| `sp_busca_totalero` | 86 | 0 | `bdicred:sd_movhis`  ⚠️ext | — |
| `sp_calcula_cobranza_administrativa` | 268 | 0 | `bdicobranza:cb_info_administrativa`  ⚠️ext, `bdicobranza:cb_param_campanias`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `bdicred:sd_movhis`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext | `bdicobranza:cb_bitacora_cob`  ⚠️ext, `cb_bitacora_cob`, `cb_info_administrativa` |
| `sp_calculacobranza` | 1276 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_resultado_llamada`  ⚠️ext, `bdicobranza:cb_compac`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicobranza:cb_registro_llamadas`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext | `bdicobranza:cb_archivo_cat`  ⚠️ext |
| `sp_calcularcobranzapreventiva` | 221 | 0 | `bdicobranza:cb_compac`  ⚠️ext, `bdicobranza:cb_info_preventiva`  ⚠️ext, `bdicobranza:cb_param_campanias`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext | `CB_INFO_PREVENTIVA`, `cb_bitacora_cob` |
| `sp_calcularcobranzapreventiva_contingencia` | 270 | 0 | `bdicobranza:cb_compac`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext, `bdinteg:`  ⚠️ext | `CB_INFO_PREVENTIVA`, `cb_bitacora_cob` |
| `sp_carga_info_atento` | 161 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_atento_movimientos`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_atento_movimientos`  ⚠️ext |
| `sp_carga_movimientos_ivr` | 105 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext | `bdicobranza:cb_movimientos_ivr`  ⚠️ext |
| `sp_carga_resultado_cat` | 44 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext | `bdicobranza:cb_registro_llamadas`  ⚠️ext |
| `sp_carga_sms_latinia` | 113 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext | `bdicobranza:cb_sms_latinia`  ⚠️ext |
| `sp_carga_tabla_movimientos` | 138 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext | `bdicobranza:cb_cat_movimientos`  ⚠️ext |
| `sp_carga_tabla_movimientos_agex` | 397 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext | `statistics` |
| `sp_carga_tabla_movimientos_peticion` | 411 | 0 | `bdicobranza:cb_cat_movimientos`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext | `statistics` |
| `sp_carga_tabla_movimientos_peticion_org` | 329 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext | `bdicobranza:cb_cat_movimientos_peticion`  ⚠️ext, `statistics` |
| `sp_carga_tabla_movimientos_peticion_pba` | 328 | 0 | `bdicobranza:cb_param_campania`  ⚠️ext | `bdicobranza:cb_cat_movimientos_peticion`  ⚠️ext, `statistics` |
| `sp_carga_telefonos` | 134 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdisolic:`  ⚠️ext, `cb_telefonos` | `bdicobranza:`  ⚠️ext |
| `sp_cargatelefonosburo` | 195 | 0 | `bdicobranza:cb_param`  ⚠️ext, `bdicobranza:tmp_telefonos_buro_2`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `sysmaster:systabnames`  ⚠️ext, `tmp_telefonos_buro_2` | `bdicobranza:tmp_telefonos_buro_2`  ⚠️ext |
| `sp_cargatelefonosburo_pba` | 214 | 0 | `bdicobranza:cb_param`  ⚠️ext, `bdicobranza:tmp_telefonos_buro_2`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext, `sysmaster:systabnames`  ⚠️ext | `bdicobranza:cb_bitacora_cob`  ⚠️ext, `bdicobranza:tmp_telefonos_buro_2`  ⚠️ext |
| `sp_cartera_pagovencido` | 144 | 0 | `bdicred:sd_tarjeta`  ⚠️ext, `bdinteg:si_catciudades`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_ctepf`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_telefonos`  ⚠️ext | `cb_info_administrativa` |
| `sp_cat_actualiza_resultado_gestion` | 73 | 0 | `cb_cat_resultado_llamada` | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext |
| `sp_cat_actualiza_resultado_gestion_his` | 73 | 0 | `cb_cat_resultado_llamada_his` | `bdicobranza:cb_cat_directorio_cte_his`  ⚠️ext |
| `sp_cat_arch_cartbase` | 117 | 0 | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext, `bdinteg:si_fechas`  ⚠️ext, `cb_param_campania`, `cb_tabla_temporal` | — |
| `sp_cat_auronix_target_phone` | 110 | 0 | `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_info_administrativa`  ⚠️ext, `bdicobranza:cb_telefonos`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext, `bdinteg:si_catciudades`  ⚠️ext | `informix` |
| `sp_cat_cambia_estatus_cte` | 996 | 0 | `Bdicobranza:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdicobranza:cb_cat_compctes`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `cb_cat_compctes` |
| `sp_cat_cargacartera` | 401 | 0 | `Bdicobranza:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_direcciones`  ⚠️ext | `bdicobranza:cb_cat_compctes`  ⚠️ext, `cb_cat_compctes` |
| `sp_cat_cargeneracion` | 265 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_compac_montomin`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `cb_cat_directorio_cte`, `cb_errores` | — |
| `sp_cat_carproductos` | 373 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `cb_cat_directorio_cte` | — |
| `sp_cat_cartelefonos` | 328 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_campania`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `bdinteg:si_telefonos_actual`  ⚠️ext, `sysmaster:sysshmvals`  ⚠️ext | `bdicobranza:cb_bitacora`  ⚠️ext, `cb_bitacora` |
| `sp_cat_cierrellamadas` | 301 | 0 | `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_movimientos`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `cb_registro_llamadas`, `ctas_adepurar` | `STATISTICS`, `cb_cat_movimientos_his` |
| `sp_cat_conscartera` | 1086 | 0 | `Bdicobranza:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_compctes`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext | `bdicobranza:cb_cat_compctes`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `cb_cat_compctes` | 🔄
| `sp_cat_consparamcampania` | 945 | 0 | `Bdicobranza:`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicobranza:cb_cat_directorio_cte`  ⚠️ext, `bdicobranza:cb_param_campania`  ⚠️ext, `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdicobranza:cb_cat_compctes`  ⚠️ext, `cb_cat_compctes` |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdicobranza:`**: escrita por `sp_cat_graba_respuesta_llamada`, `sp_actualiza_saldos_admin`, `sp_cat_gen_info_prev`, `sp_cat_modstadocte`, `sp_cat_graba_telefono_adicional` ... y 10 más
- **`bdicobranza:cb_cat_directorio_cte`**: escrita por `sp_cat_gen_info_prev`, `sp_actualiza_catdirectoriocte`, `sp_actualiza_catdirectoriocte_pba`, `sp_cat_consulta_disponibilidad_cliente`, `sp_cat_cambia_estatus_cte` ... y 7 más
- **`statistics`**: escrita por `sp_actualiza_saldos_admin_tco`, `sp_cat_consulta_ultimo_convenio`, `sp_actualiza_saldos_admin`, `sp_cat_consulta_disponibilidad_cliente`, `sp_carga_tabla_movimientos_peticion_pba` ... y 6 más
- **`STATISTICS`**: escrita por `sp_campania_experiencia_cliente`, `sp_asigna_cartera_agex`, `sp_actualiza_catdirectoriocte`, `sp_cat_graba_telefono_adicional`, `fn_formaretiquetaxml` ... y 4 más
- **`bdicobranza:cb_bitacora`**: escrita por `sp_actualiza_catdirectoriocte`, `sp_cat_graba_telefono_adicional`, `sp_cat_consulta_saldostc`, `fn_formaretiquetaxml`, `inserta_bitacora_cob` ... y 1 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `statistics` | `sp_actualiza_saldos_admin_tco`, `sp_cat_consulta_ultimo_convenio`, `sp_actualiza_saldos_admin` | 🔴 PRIMERA |
| `STATISTICS` | `sp_campania_experiencia_cliente`, `sp_asigna_cartera_agex`, `sp_actualiza_catdirectoriocte` | 🔴 PRIMERA |
| `cb_cat_compctes` | `sp_cat_cambia_estatus_cte`, `sp_cat_consparamcampania`, `sp_cat_cargacartera` | 🔴 PRIMERA |
| `cb_bitacora` | `inserta_bitacora_cob`, `sp_cat_cartelefonos`, `sp_actualiza_catdirectoriocte` | 🟠 SEGUNDA |
| `cb_bitacora_cob` | `sp_calcularcobranzapreventiva_contingencia`, `sp_calcularcobranzapreventiva`, `sp_calcula_cobranza_administrativa` | 🟠 SEGUNDA |
| `cb_info_administrativa` | `sp_cartera_pagovencido`, `sp_calcula_cobranza_administrativa`, `fn_formaretiquetaxml` | 🟠 SEGUNDA |
| `cb_rep_resultado_sms_hist` | `sp_cat_graba_telefono_adicional`, `sp_cat_consulta_saldostc`, `fn_formaretiquetaxml` | 🟠 SEGUNDA |
| `tmp_compagconvsem_vesp` | `sp_actualiza_catdirectoriocte_pba`, `fn_formaretiquetaxml` | 🟡 TERCERA |

## Tablas externas accedidas (cross-DB)

- `BDICOBRANZA:CB_COMPAC` (R+W) — desde `fn_formaretiquetaxml`
- `BDINTEG:si_sucursales` (R) — desde `sp_cat_consulta_ultimo_convenio`, `sp_actualiza_catdirectoriocte_pba`, `fn_formaretiquetaxml`
- `Bdicobranza:` (R) — desde `sp_cat_consulta_pagos_tc`, `sp_cat_conscartera`, `sp_cat_cambia_estatus_cte`
- `Bdicobranza:cb_gestion_telefonica` (R+W) — desde `fn_formaretiquetaxml`
- `Bdicobranza:cb_param` (R) — desde `fn_formaretiquetaxml`
- `Bdinteg:si_direcciones` (R) — desde `fn_formaretiquetaxml`
- `bdiaclaracion:acl_aclaracion` (R) — desde `sp_cat_consulta_disponibilidad_cliente`
- `bdiaclaracion:acl_producto` (R) — desde `sp_cat_consulta_disponibilidad_cliente`
- `bdicheq:sc_maechq` (R) — desde `sp_actualiza_catdirectoriocte_pba`, `fn_formaretiquetaxml`
- `bdicobranza:` (R+W) — desde `sp_cat_graba_respuesta_llamada`, `sp_cat_ivr_gen_archbase_tco`, `sp_cat_ivr_gen_archmora_tco`
- `bdicobranza:CB_COMPAC` (R) — desde `fn_formaretiquetaxml`
- `bdicobranza:cb_administativa_latinia` (R+W) — desde `fn_formaretiquetaxml`
- `bdicobranza:cb_alerta_succliente` (R+W) — desde `sp_cat_consulta_totales`, `fn_formaretiquetaxml`
- `bdicobranza:cb_alerta_succlientehis` (R+W) — desde `fn_formaretiquetaxml`
- `bdicobranza:cb_archivo_cat` (R+W) — desde `sp_calculacobranza`, `fn_formaretiquetaxml`
- `bdicobranza:cb_atento_movimientos` (R+W) — desde `sp_carga_info_atento`, `fn_formaretiquetaxml`
- `bdicobranza:cb_bitacora` (R+W) — desde `inserta_bitacora_cob`, `sp_actualiza_catdirectoriocte`, `sp_cat_graba_telefono_adicional`
- `bdicred:` (R) — desde `sp_actualiza_saldos_admin_tco`, `sp_cat_consulta_ultimo_convenio`, `sp_asigna_cartera_agex`
- `bdicred:sd_amortiza_credito` (R) — desde `sp_actualiza_saldos_admin`, `sp_calcula_cobranza_administrativa`, `sp_cat_auronix_target_phone`
- `bdicred:sd_amortiza_creditocrd` (R) — desde `sp_actualiza_catdirectoriocte_pba`, `fn_formaretiquetaxml`
- `bdicred:sd_cifracontroldirectorioaltasycambios` (R) — desde `fn_formaretiquetaxml`
- `bdicred:sd_conceptospagomanual` (R) — desde `sp_archivo_compac`, `sp_cat_graba_telefono_adicional`, `sp_cat_gen_info_admin`
- `bdicred:sd_conceptospagomanualcrd` (R) — desde `sp_archivo_compac`, `sp_cat_graba_telefono_adicional`, `sp_cat_gen_info_admin`
- `bdicred:sd_ctascarg` (R) — desde `sp_cat_graba_telefono_adicional`, `sp_cat_consulta_saldostc`, `fn_formaretiquetaxml`
- `bdicred:sd_definicion` (R) — desde `sp_cat_consulta_disponibilidad_cliente`, `sp_campania_experiencia_cliente`
- `bdimnsj:mnsjr_trx_batch` (R+W) — desde `sp_actualiza_saldos_admin_tco`, `sp_actualiza_saldos_admin`, `fn_formaretiquetaxml`
- `bdimnsj:mnsjr_trx_batch_his` (R) — desde `fn_formaretiquetaxml`
- `bdinteg:` (R+W) — desde `sp_actualiza_saldos_admin_tco`, `sp_cat_consulta_ultimo_convenio`, `sp_cat_graba_respuesta_llamada`
- `bdinteg:si_actesp` (R) — desde `fn_formaretiquetaxml`
- `bdinteg:si_catcalles` (R) — desde `sp_cat_consulta_generales`, `sp_cat_consulta_totales`, `fn_formaretiquetaxml`
- `bdinteg:si_catciudades` (R) — desde `sp_cat_consulta_generales`, `sp_cat_auronix_target_phone`, `sp_calcularcobranzapreventiva`
- `bdinteg:si_catzonas` (R) — desde `sp_cat_consulta_generales`, `sp_cat_consulta_totales`, `fn_formaretiquetaxml`
- `bdinteg:si_ciudades` (R) — desde `sp_cat_consulta_generales`, `sp_auronix_msj`, `sp_cat_conscartera`
- `bdinteg:si_cliente` (R) — desde `sp_actualiza_saldos_admin_tco`, `sp_cat_auronix_target_phone`, `sp_calcula_cobranza_administrativa`
- `bdinteg:si_correos` (R) — desde `sp_actualiza_saldos_admin_tco`, `sp_campania_experiencia_cliente`, `fn_formaretiquetaxml`
- `bdinvers:sv_maeinv` (R) — desde `sp_actualiza_catdirectoriocte_pba`, `fn_formaretiquetaxml`
- `bdisitesp:` (R+W) — desde `sp_actualiza_saldos_admin_tco`, `sp_actualiza_saldos_admin`, `sp_cat_gen_info_prev`
- `bdisitesp:se_catsitesp` (R) — desde `sp_cat_consulta_totales`, `fn_formaretiquetaxml`
- `bdisitesp:se_ctessitespcTE` (R) — desde `fn_formaretiquetaxml`
- `bdisitesp:se_ctessitespcte` (R+W) — desde `sp_calcula_cobranza_administrativa`, `sp_calcularcobranzapreventiva_contingencia`, `fn_formaretiquetaxml`
- `bdisitesp:se_situacionaccion` (R) — desde `sp_calcula_cobranza_administrativa`, `sp_calcularcobranzapreventiva`, `sp_calcularcobranzapreventiva_contingencia`
- `bdisolic:` (R) — desde `sp_carga_telefonos`, `fn_formaretiquetaxml`
- `bdisolic:ss_detalle_scoring` (R) — desde `fn_formaretiquetaxml`
- `bdisolic:ss_param` (R) — desde `sp_cat_consulta_generales`, `fn_formaretiquetaxml`
- `bdisolic:ss_refpersonales` (R) — desde `sp_cat_consulta_generales`, `sp_calcularcobranzapreventiva`, `sp_calcularcobranzapreventiva_contingencia`
- `bdisolic:ss_resum_scor_fin` (R) — desde `sp_cat_consulta_generales`, `fn_formaretiquetaxml`
- `bdisolic:ss_scoring_element` (R) — desde `fn_formaretiquetaxml`
- `bdisolic:ss_solicitudes` (R) — desde `fn_formaretiquetaxml`
- `sysmaster:` (R) — desde `sp_cat_depura_cte_tel_inactivo`, `sp_cat_depura_tel_inactivo`, `sp_cat_modstadocte`
- `sysmaster:sysshmvals` (R) — desde `sp_calcula_cobranza_administrativa`, `sp_cat_auronix_target_phone`, `sp_actualiza_catdirectoriocte`
- `sysmaster:systabnames` (R) — desde `sp_archivo_compac`, `sp_cargatelefonosburo`, `sp_actualiza_ejecutivoscat`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicobranza_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

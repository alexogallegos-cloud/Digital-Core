# D03 · Créditos — Matriz SP × Tabla (READ / WRITE)

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 / POWER-AIX
> **Wave:** Wave 4 · Riesgo: **CRÍTICO**
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

## Resumen de tablas propias de `bdicred`

| Tabla | Tipo | Lectores | Escritores | Ownership |
|-------|------|----------|-----------|-----------|
| `sd_maecred` | Maestro | 12 | 3 | 🟠 3 SPs escriben |
| `statistics` | Transaccional | 0 | 13 | 🔴 13 SPs escriben |
| `sd_amortiza_credito` | Transaccional | 5 | 5 | 🟠 5 SPs escriben |
| `sd_fechas` | Transaccional | 9 | 0 | 🟢 Solo lectura |
| `sd_amortiza_creditocrd` | Transaccional | 5 | 3 | 🟠 3 SPs escriben |
| `sd_maesdos` | Maestro | 4 | 4 | 🟠 4 SPs escriben |
| `sd_maecredcrd` | Maestro | 6 | 0 | 🟢 Solo lectura |
| `sd_param` | Catálogo / Config | 6 | 0 | 🟢 Solo lectura |
| `informix` | Transaccional | 1 | 5 | 🟠 5 SPs escriben |
| `sd_actvig_camp` | Transaccional | 3 | 3 | 🟠 3 SPs escriben |
| `sd_movhis` | Transaccional | 4 | 1 | 🟠 1 SPs escriben |
| `sd_maesdoshist` | Maestro | 5 | 0 | 🟢 Solo lectura |
| `sd_tarjeta` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `STATISTICS` | Transaccional | 0 | 5 | 🟠 5 SPs escriben |
| `sd_definicion` | Transaccional | 5 | 0 | 🟢 Solo lectura |
| `tme_consultaincrementos` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `bdicred` | Transaccional | 4 | 0 | 🟢 Solo lectura |
| `tmp_sd_actvig_camp` | Transaccional | 2 | 2 | 🟠 2 SPs escriben |
| `sd_sdodiario` | Transaccional | 3 | 1 | 🟠 1 SPs escriben |
| `SD_PAGINTER` | Transaccional | 3 | 1 | 🟠 1 SPs escriben |

> **[SME-PENDING]** Confirmar nombre exacto en producción, volumen de registros, política de retención y campos PII con DBA BanCoppel.

## Matriz completa SP × Tabla

| SP | LOC | Fan-in | Tablas que LEE | Tablas que ESCRIBE |
|----|-----|--------|---------------|-------------------|
| `sp_adn_cobroautomatico_manual` | 3677 | 0 | `SD_CTASCARG`, `bdiburo:br_variables_cc_cnr`  ⚠️ext, `bdicheq:`  ⚠️ext, `bdicheq:sc_ctabloqueo`  ⚠️ext, `bdicheq:sc_maechq`  ⚠️ext, `bdicheq:sc_movhis`  ⚠️ext | `bdicheq:`  ⚠️ext, `bdicheq:sc_ctabloqueo`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext | 🔄
| `sp_actualizar_bitacora` | 3134 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_cat_exclusiones_vc`  ⚠️ext, `bdicred:sd_exclusiones_ventacartera`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_exclusiones_ventacartera`  ⚠️ext, `bdisolic:`  ⚠️ext, `sd_amortiza_creditocrd` |
| `sp_administra_reestructura_pp` | 2826 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext, `bdicred:sd_maeretenido`  ⚠️ext, `bdicred:sd_programa_apoyo2020crd`  ⚠️ext | `bdicred:`  ⚠️ext, `bdisolic:`  ⚠️ext, `sd_amortiza_creditocrd` |
| `aclaraciones_edoctacrd_sif` | 2487 | 0 | `bdicheq:`  ⚠️ext, `bdicheq:sc_docret_sbc`  ⚠️ext, `bdicobranza:`  ⚠️ext, `bdicred`, `bdicred:`  ⚠️ext, `bdicred:sd_bitacora_aumlincred`  ⚠️ext | `bdicred:`  ⚠️ext |
| `sp_actualizar_linea_credito_tc_inflacion` | 2291 | 1 | `bdicred:`  ⚠️ext, `bdicred:sd_actvig_camp`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_param`  ⚠️ext, `bdicred:sd_promocion_credito`  ⚠️ext, `bdicred:sd_promocion_credito_sms`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_indicador_cred_crd`  ⚠️ext, `bdicred:sd_tasa_plazo_app`  ⚠️ext, `bdicred:sd_tasa_plazo_sms`  ⚠️ext |
| `sp_actualizasaldos_cred` | 2197 | 12 | `bdicobranza:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_bitacora_quitacondonacion`  ⚠️ext, `bdicred:sd_diferir`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext |
| `sp_actvig_camp` | 1676 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_actvig_camp`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_param`  ⚠️ext, `bdicred:sd_promocion_credito`  ⚠️ext, `bdicred:sd_promocion_credito_sms`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_indicador_cred_crd`  ⚠️ext, `bdicred:sd_tasa_plazo_app`  ⚠️ext, `bdicred:sd_tasa_plazo_sms`  ⚠️ext |
| `sp_actestatustarjeta` | 1253 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext | `STATISTICS`, `bdicred:`  ⚠️ext, `bitacora_activacion`, `intercard:`  ⚠️ext |
| `sp_adn_disposicion` | 931 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext, `bdicred:sd_maesdoscont`  ⚠️ext, `bdicred:sd_maesdoshist`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_hist_reserva_old`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext |
| `sp_adn_sms` | 721 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext, `bdicred:sd_maesdoscont`  ⚠️ext, `bdicred:sd_maesdoshist`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_hist_reserva_old`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext |
| `sp_adn_cobroautomatico` | 637 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_movhis`  ⚠️ext, `bdicred:sd_param`  ⚠️ext, `bdinteg:sx_contproc`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_movhis`  ⚠️ext, `bdicred:sd_movhis_depura`  ⚠️ext |
| `aclaraciones_edocta` | 568 | 0 | `bdicobranza:`  ⚠️ext, `bdicred`, `bdicred:sd_bitacora_aumlincred`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `bdinteg:`  ⚠️ext | — |
| `sp_actualizastatuscred` | 411 | 13 | `bdicred`, `bdicred:`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_maesdoshist`  ⚠️ext, `bdicred:sd_maesdoshist_old`  ⚠️ext | `sd_info_edocta`, `statistics` |
| `sp_activa_insertos_fijos` | 361 | 8 | `bdicred:sd_insertoregion`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maesdoshist`  ⚠️ext, `bdicred:sd_marcaje`  ⚠️ext, `bdisitesp:se_ctessitespcred`  ⚠️ext, `bdisitesp:se_ctessitespcred_his`  ⚠️ext | `bdicred:sd_insertoregion`  ⚠️ext, `bdicred:sd_marcaje`  ⚠️ext, `bdisitesp:se_ctessitespcred`  ⚠️ext, `bdisitesp:se_ctessitespcred_his`  ⚠️ext |
| `sp_actualiza_linea_pdigital` | 299 | 1 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext | `bdicred:`  ⚠️ext |
| `sp_adn_cancelacredito` | 231 | 2 | `bdicred:sd_fechas`  ⚠️ext, `sd_maecred` | `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `sd_amortiza_credito`, `sd_maesdos` |
| `sp_abona_cheques` | 158 | 0 | `bdicred:`  ⚠️ext | `bdicred:`  ⚠️ext |
| `sp_abonoact_credplazos` | 425 | 0 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_feriado`  ⚠️ext | — |
| `sp_act_encab` | 61 | 0 | `co_detpol` | `co_poliza` |
| `sp_act_historica_cac_aumlincred` | 1646 | 0 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `intercard:`  ⚠️ext, `sd_progesive_01`, `systables`, `tme_consultaincrementos` | `bdicred:`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext, `bdicred:sd_prospectos_aumlincred`  ⚠️ext, `intercard:`  ⚠️ext |
| `sp_act_retenido` | 68 | 0 | `bdicred:`  ⚠️ext, `ret1` | `bdicred:`  ⚠️ext |
| `sp_act_sdoamortiza` | 87 | 0 | `sd_amortiza_creditocrd`, `sd_maecredcrd`, `sd_maesdoscrd` | `sd_amortiza_creditocrd` |
| `sp_actindicadores_gastosbonificacion` | 279 | 0 | `sd_gastos_bonificacion` | `sd_gastos_bonificacion` |
| `sp_activa_insertos_fijoscrd` | 839 | 0 | `bdicred:sd_grado_riesgo`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext, `bdicred:sd_maesdoscont`  ⚠️ext, `bdicred:sd_param_reservas`  ⚠️ext, `bdinteg:sx_contproc`  ⚠️ext | `STATISTICS`, `bdicred:sd_marcaje`  ⚠️ext, `bdinteg:sx_contproc`  ⚠️ext, `informix` |
| `sp_actpromo_x_msi` | 91 | 0 | `bdicred:sd_promocion_credito`  ⚠️ext, `creds_msi`, `intercard:movimiento`  ⚠️ext, `intercard:movimientohistorico`  ⚠️ext | `STATISTICS` |
| `sp_actsdodiario` | 1609 | 0 | `bdicred:sd_config_mensaje_edocta`  ⚠️ext, `bdicred:sd_mensajes_edocta`  ⚠️ext, `bdinteg:si_correos`  ⚠️ext, `sd_aclaraciones_edocta`, `sd_detalle_edocta`, `sd_encabezado2_edocta` | `sd_sdodiario` |
| `sp_actsdodiariocrd` | 1372 | 0 | `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_reporte_oa`  ⚠️ext, `bdinteg:si_cliente`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `bdisolic:`  ⚠️ext, `bdisolic:ss_autorizacion`  ⚠️ext | `sd_reporte_oa`, `sd_sdodiariocrd` |
| `sp_actsdomensual` | 1087 | 0 | `bdicred:sd_movhis`  ⚠️ext, `bdinteg:sx_contproc`  ⚠️ext, `bdisolic:ss_resum_scor_fin`  ⚠️ext, `sd_fechas`, `sd_histvalcon`, `sd_maecred` | `sd_histvalcon`, `sd_maecred`, `sd_movcalcval`, `sd_sdomensual` |
| `sp_actsdomensual_prueba` | 522 | 0 | `sd_amortiza_credito`, `sd_fechas`, `sd_maecred`, `sd_movhis`, `sd_sdodiario`, `sd_sdomensual` | `sd_amortiza_credito`, `sd_movdia`, `sd_sdomensual` |
| `sp_actualiza_acum_cambio_mes` | 25 | 0 | — | `SD_MAESDOS` |
| `sp_actualiza_acum_ini_periodo` | 33 | 0 | `SD_PAGINTER` | `SD_MAESDOS` |
| `sp_actualiza_credito_apoyo` | 399 | 0 | `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_prog_apoyo`  ⚠️ext, `bdinteg:cr_sucursales2`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `dual` | `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext |
| `sp_actualiza_credito_apoyo_2` | 518 | 0 | `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_prog_apoyo`  ⚠️ext, `bdinteg:cr_sucursales2`  ⚠️ext, `bdinteg:si_sucursales`  ⚠️ext, `dual` | `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext |
| `sp_actualiza_creditos` | 764 | 0 | `TABLE`, `bdicred:`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `bdicred:tmp_credito_1`  ⚠️ext, `bdicred:tmp_plazo_cred_1`  ⚠️ext | `STATISTICS`, `bdicred:`  ⚠️ext, `bdiunica`, `tarjetaConcentrado` |
| `sp_actualiza_escrow` | 39 | 0 | `SD_DETCOMI`, `SD_ESCROW` | `SD_DETCOMI` |
| `sp_actualiza_fecha` | 39 | 0 | `bdicred:sd_sdodiario`  ⚠️ext | `bdicred:sd_sdodiario`  ⚠️ext |
| `sp_actualiza_indicadorcred` | 68 | 0 | `bdicred:sd_indicador_cred`  ⚠️ext, `paso_compras` | `bdicred:sd_indicador_cred`  ⚠️ext, `statistics` |
| `sp_actualiza_lincred_central` | 192 | 0 | — | — |
| `sp_actualiza_lincred_central_masivo` | 190 | 0 | — | — |
| `sp_actualiza_numpago` | 272 | 0 | `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_maecredcrd`  ⚠️ext, `bdicred:sd_maesdoscrd`  ⚠️ext, `sd_fechas` | `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_maesdoscrd`  ⚠️ext |
| `sp_actualiza_reserva_cierre` | 737 | 0 | `bdicred:sd_grado_riesgo`  ⚠️ext, `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_maecredcont`  ⚠️ext, `bdicred:sd_maesdoscont`  ⚠️ext, `bdicred:sd_param_reservas`  ⚠️ext, `bdinteg:sx_contproc`  ⚠️ext | `bdinteg:sx_contproc`  ⚠️ext, `informix`, `sd_contproc`, `sd_hist_reserva` |
| `sp_actualiza_reserva_corte` | 418 | 0 | `bdicred:sd_hist_reserva`  ⚠️ext, `bdicred:sd_param_reservas`  ⚠️ext | `informix`, `statistics` |
| `sp_actualiza_revtasa` | 429 | 0 | `SD_CREDITOS_REVTASA`, `SD_FECHAS`, `SD_MAECRED`, `SD_PAGINTER`, `SI_FERIADO` | `SD_REVTASA` |
| `sp_actualiza_sesion_bex_pba` | 284 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_credito`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext, `bdicred:sd_maecredanexo`  ⚠️ext, `bdicred:sd_maecredanexocrd`  ⚠️ext | — |
| `sp_actualiza_tasas_creditos` | 831 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdicred:sd_grupo_cliente`  ⚠️ext, `bdicred:sd_grupo_credito`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_grupo_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext |
| `sp_actualiza_vigenciatc` | 510 | 0 | `bdicred:`  ⚠️ext, `bdinteg:`  ⚠️ext, `intercard:movimiento`  ⚠️ext, `intercard:movimientohistorico`  ⚠️ext, `resol`, `sd_tarjeta` | `bdicred:sd_movhisedocta`  ⚠️ext, `statistics`, `temporalcred800` |
| `sp_actualizacvlcobranzacte` | 1005 | 0 | `bdicheq:`  ⚠️ext, `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_definicion`  ⚠️ext, `bdicred:sd_encabezado2_edoctacrd`  ⚠️ext, `bdicred:sd_grupo_cliente`  ⚠️ext | `bdicred:`  ⚠️ext, `bdicred:sd_contproc`  ⚠️ext, `bdicred:sd_grupo_credito`  ⚠️ext, `bdicred:sd_maecred`  ⚠️ext | 🔄
| `sp_actualizar_bitacora_pba` | 254 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_amortiza_creditocrd`  ⚠️ext, `bdicred:sd_exclusiones_ventacartera`  ⚠️ext, `bdicred:sd_maesdos`  ⚠️ext, `bdicred:sd_maesdoscrd`  ⚠️ext, `bdicred:sd_movhiscrd`  ⚠️ext | `bdicred:sd_exclusiones_ventacartera`  ⚠️ext |
| `sp_actualizar_info_tdc_garantizada` | 213 | 0 | `bdicred:`  ⚠️ext, `sd_detcomi`, `sd_maesdos`, `sd_tarjeta` | `bdicred:`  ⚠️ext |
| `sp_actualizarestatusaumlincred` | 1234 | 0 | `bdicred:`  ⚠️ext, `bdicred:sd_fechas`  ⚠️ext, `bdicred:sd_tarjeta`  ⚠️ext, `bdinteg:`  ⚠️ext, `bdinteg:si_empresas`  ⚠️ext, `bdisolic:`  ⚠️ext | `STATISTICS`, `bdicred:`  ⚠️ext, `bdicred:sd_encabezado_edocta`  ⚠️ext, `bdicred:sd_prospectos_aumlincred`  ⚠️ext |

## Tablas compartidas (múltiples escritores) — riesgo de contención en parallel-run

- **`bdicred:`**: escrita por `sp_adn_disposicion`, `aclaraciones_edoctacrd_sif`, `sp_actualizar_info_tdc_garantizada`, `sp_adicionalcreditopendiente`, `sp_actualizar_linea_credito_tc_inflacion` ... y 20 más
- **`statistics`**: escrita por `sp_actualiza_reserva_corte`, `sp_actualiza_vigenciatc`, `sp_adn_disposicion`, `sp_actualiza_credito_apoyo_2`, `sp_activa_insertos_fijos` ... y 8 más
- **`bdisolic:`**: escrita por `sp_adn_cobroautomatico`, `sp_actualizar_bitacora`, `sp_actvig_camp`, `sp_adicionalcreditopendiente`, `sp_adn_cobroautomatico_manual` ... y 5 más
- **`bdinteg:sx_contproc`**: escrita por `sp_adn_cobroautomatico`, `sp_actualiza_reserva_cierre`, `sp_adn_cobroautomatico_manual`, `sp_actualiza_tasas_creditos`, `sp_actualizacvlcobranzacte` ... y 3 más
- **`bdicred:sd_maecred`**: escrita por `sp_adn_cancelacredito`, `sp_actualiza_credito_apoyo_2`, `abreax`, `sp_actualizacvlcobranzacte`, `sp_actualiza_credito_apoyo` ... y 1 más

## Tablas candidatas a CDC prioritario (Debezium / AWS DMS)

| Tabla | SPs escritores | Prioridad CDC |
|-------|---------------|---------------|
| `statistics` | `sp_actualiza_reserva_corte`, `sp_actualiza_vigenciatc`, `sp_adn_disposicion` | 🔴 PRIMERA |
| `STATISTICS` | `sp_actualizarestatusaumlincred`, `sp_actualiza_creditos`, `sp_actestatustarjeta` | 🔴 PRIMERA |
| `informix` | `sp_actualiza_reserva_corte`, `sp_adn_cobroautomatico`, `sp_actualizarestatusaumlincred` | 🔴 PRIMERA |
| `sd_amortiza_credito` | `act_cuota_periodo`, `sp_adn_cancelacredito`, `act_fecha` | 🔴 PRIMERA |
| `sd_contproc` | `sp_adn_cobroautomatico`, `sp_actualiza_reserva_cierre`, `sp_activa_insertos_fijoscrd` | 🟠 SEGUNDA |
| `sd_maesdos` | `abono_cred`, `sp_adn_cancelacredito`, `act_amocuota` | 🟠 SEGUNDA |
| `sd_amortiza_creditocrd` | `sp_administra_reestructura_pp`, `sp_actualizar_bitacora`, `sp_act_sdoamortiza` | 🟠 SEGUNDA |
| `sd_maecred` | `act_amocuota`, `act_fecha`, `sp_actsdomensual` | 🟠 SEGUNDA |

## Tablas externas accedidas (cross-DB)

- `BDISOLIC:SS_SOLICITUDES` (R) — desde `abreax`
- `bdiburo:br_variables_cc_cnr` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdicheq:` (R+W) — desde `sp_adn_cobroautomatico`, `aclaraciones_edoctacrd`, `sp_actualizar_bitacora`
- `bdicheq:sc_ctabloqueo` (R+W) — desde `sp_adn_cobroautomatico_manual`
- `bdicheq:sc_docret_sbc` (R) — desde `aclaraciones_edoctacrd_sif`
- `bdicheq:sc_maechq` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdicheq:sc_movhis` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdicobranza:` (R) — desde `aclaraciones_edocta`, `aclaraciones_edoctacrd_sif`, `aclaraciones_edocta_sif`
- `bdicred:` (R+W) — desde `aclaraciones_edoctacrd`, `sp_actualizar_bitacora_pba`, `sp_adn_disposicion`
- `bdicred:Sd_amortiza_credito` (R+W) — desde `aclaraciones_edoctacrd`
- `bdicred:Sd_maesdos` (R+W) — desde `abono_cred`
- `bdicred:sd_actvig_camp` (R+W) — desde `sp_actualizar_linea_credito_tc_inflacion`, `sp_actvig_camp`, `sp_actvig_camp_mx`
- `bdicred:sd_amortiza_credito` (R+W) — desde `act_amortiza_mes`, `act_amocuota`, `sp_actualiza_credito_apoyo_2`
- `bdicred:sd_amortiza_creditocrd` (R+W) — desde `sp_actualiza_numpago`, `sp_actualizar_bitacora_pba`, `sp_actualizar_bitacora`
- `bdicred:sd_bitacora_aumlincred` (R) — desde `aclaraciones_edocta`, `aclaraciones_edoctacrd_sif`
- `bdicred:sd_bitacora_quitacondonacion` (R) — desde `sp_actualizasaldos_cred`
- `bdimnsj:mnsjr_trx_online` (R) — desde `sp_adn_sms`, `sp_adn_disposicion`
- `bdimnsj:mnsjr_trx_online_his` (R) — desde `sp_adn_sms`, `sp_adn_disposicion`
- `bdinteg:` (R+W) — desde `sp_act_historica_cac_aumlincred`, `aclaraciones_edoctacrd`, `sp_actualiza_vigenciatc`
- `bdinteg:cr_sucursales2` (R) — desde `sp_actualiza_credito_apoyo_2`, `sp_actualiza_credito_apoyo`
- `bdinteg:si_catcalles` (R) — desde `aclaraciones_edoctacrd`
- `bdinteg:si_catciudades` (R) — desde `aclaraciones_edoctacrd`
- `bdinteg:si_catzonas` (R) — desde `aclaraciones_edoctacrd`
- `bdinteg:si_cliente` (R) — desde `act_lineas`, `sp_adn_cobroautomatico_manual`, `aclaraciones_edoctacrd`
- `bdinteg:si_correos` (R) — desde `sp_actsdodiario`
- `bdinteg:si_ctepf` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdisitesp:se_ctessitespcred` (R+W) — desde `sp_administra_reestructura_pp`, `sp_actualizar_bitacora`, `sp_activa_insertos_fijos`
- `bdisitesp:se_ctessitespcred_his` (R+W) — desde `sp_activa_insertos_fijos`
- `bdisolic:` (R+W) — desde `sp_adn_disposicion`, `aclaraciones_edoctacrd_sif`, `sp_actestatustarjeta`
- `bdisolic:ss_Revision_determinacion` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdisolic:ss_autorizacion` (R) — desde `sp_actsdodiariocrd`, `sp_actualizarestatusaumlincred`
- `bdisolic:ss_autorizacion_especial` (R) — desde `sp_actualizarestatusaumlincred`
- `bdisolic:ss_resum_scor_fin` (R) — desde `sp_adn_cobroautomatico_manual`, `sp_actsdomensual`
- `bdisolic:ss_resumen_scoring` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdisolic:ss_revision_determinacion` (R) — desde `sp_adn_cobroautomatico_manual`
- `bdisolic:ss_solicitudes` (R) — desde `abreax`, `sp_adn_cobroautomatico_manual`, `sp_actualizarestatusaumlincred`
- `bditransfer:` (R) — desde `sp_actestatustarjeta`
- `intercard:` (R+W) — desde `sp_act_historica_cac_aumlincred`, `sp_actestatustarjeta`, `sp_actualizasolicmc_lineas`
- `intercard:bitacoracambiosstatustarjeta` (R) — desde `sp_actualiza_creditos`
- `intercard:bitacoracambiostarjeta` (R) — desde `sp_actualiza_creditos`
- `intercard:bitasignacionactivaciontarjeta` (R) — desde `sp_actualiza_creditos`
- `intercard:movimiento` (R) — desde `sp_actpromo_x_msi`, `sp_actualiza_vigenciatc`
- `intercard:movimientohistorico` (R) — desde `sp_actpromo_x_msi`, `sp_actualiza_vigenciatc`
- `intercard:productotarjeta` (R) — desde `sp_actestatustarjeta`
- `intercard:tarjetacuenta` (R+W) — desde `sp_actestatustarjeta`
- `lineas:sl_catgrupos` (R) — desde `act_lineas`
- `lineas:sl_ctegpo` (R+W) — desde `act_lineas`
- `lineas:sl_ctepro` (R+W) — desde `act_lineas`
- `lineas:sl_grupos` (R+W) — desde `act_lineas`
- `sysmaster:` (R) — desde `sp_actualiza_creditos`
- `sysmaster:sysshmvals` (R) — desde `sp_adn_sms`, `sp_actestatustarjeta`, `sp_adn_cobroautomatico_manual`
- `sysmaster:systabnames` (R) — desde `aclaraciones_edoctacrd`

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicred_*.sql (análisis estático de 70 archivos SQL) · análisis estático de cláusulas FROM/INSERT/UPDATE/DELETE*

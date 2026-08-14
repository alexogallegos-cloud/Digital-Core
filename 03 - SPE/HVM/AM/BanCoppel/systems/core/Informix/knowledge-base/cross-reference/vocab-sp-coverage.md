> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Cross-Reference KB · Generado: 2026-08-02

# Vocabulario → Cobertura de SPs

Mapa de cada término del vocabulario hacia los procedimientos almacenados que lo referencian en reglas de negocio. Un término con alta cobertura de SPs indica un concepto transversal crítico; términos sin cobertura son candidatos a gap de extracción.

---

## Top 150 Términos por Cobertura de SPs (≥ 2 SPs)

_Total términos con cobertura ≥ 1 SP: 228_

| # | Término | Significado | BC | # SPs | SPs (top 5) |
|---|---------|-------------|----|----|----------|
| 1 | **error** | error | — | 682 | `corresp_pagotdc_cargocta`, `principal`, `principal_jose`, `sp_abono_cta`, `sp_actinfosolicitudmc` (+677 más) |
| 2 | **ejecucion** | ejecución (de proceso) | — | 439 | `sp_actualizacedulasccl`, `sp_actualizacentrallincred`, `sp_actualizacionctepmsnom2`, `sp_actualizaparametrosccl`, `sp_actualizaprocesoconau` (+434 más) |
| 3 | **conciliachq** | conciliación de cheques | BC-3.2 | 139 | `abono_ctas`, `abono_ctas_18112010`, `abono_ctas_comis`, `abono_ctas_comis_pba`, `abono_ctas_ivas` (+134 más) |
| 4 | **cuenta** | cuenta | BC-3.2 | 66 | `altatarcred_v_1`, `apertura`, `apertura_app`, `cargo_retenido`, `consfircredper` (+61 más) |
| 5 | **fecha** | fecha | — | 64 | `revisa_tasa`, `sdos_diarios`, `sdos_diarios_trfn`, `sp_actualiza_instruccionvencimiento`, `sp_archivo_coppcnc` (+59 más) |
| 6 | **parametros** | parámetros | BC-4.x | 53 | `sp_activaserviciosdomi_lmpba`, `sp_adn_cart_activa`, `sp_adn_disposicion`, `sp_adn_repgeneral`, `sp_adn_res_general` (+48 más) |
| 7 | **monto** | monto | — | 53 | `corresp_pagotdc_cargocta`, `gencartconsumo`, `gencartconsumo_crd`, `gencartconsumo_p`, `gencartconsumo_reproc` (+48 más) |
| 8 | **sucursal** | sucursal | BC-1.x | 43 | `modif_minis`, `pro_genera_reportes_pl`, `sp_actvig_camp`, `sp_actvig_camp_mx`, `sp_carga_clientes_camp` (+38 más) |
| 9 | **cliente** | cliente | BC-7.1 | 38 | `altatarcred_v_1`, `con_anexo`, `sc_cons_ctasdos_bpi`, `sc_cons_ctasdos_bpi_mx`, `sc_cons_ctasdos_bpii_pba1` (+33 más) |
| 10 | **producto** | producto | BC-4.x | 38 | `determina_lincred_tc_cjunk`, `sp_bedito_rechazo`, `sp_calcula_caratulaproducto_pba`, `sp_conciliainv`, `sp_eliminacion_puntos_coppel` (+33 más) |
| 11 | **usuario** | usuario | — | 35 | `apertura`, `apertura_app`, `cancelacion`, `fechas`, `sp_actualizasolicitudmc` (+30 más) |
| 12 | **numcte** | número de cliente | BC-7.1 | 31 | `pro_genera_reportes_pl`, `sp_envio_camp_ctes_ctaspzo`, `sp_envio_camp_ctes_ctasrev`, `sp_gen_report_articulo_51`, `sp_gen_reporte_campana_prev_pzo` (+26 más) |
| 13 | **transaccion** | transacción | — | 30 | `sp_aplicaaclaradebito`, `sp_aplicaaclaradebito_prueba`, `sp_archivo_central`, `sp_cargoxajuste_debcred`, `sp_concilia_donativos_becalos` (+25 más) |
| 14 | **folio** | folio | BC-3.18 | 26 | `pro_genera_reportes_pl`, `sp_acl_reporte_log`, `sp_cnsif_genarchmovimientos`, `sp_cnsif_genarchmovimientos2`, `sp_concilia_donativos_becalos` (+21 más) |
| 15 | **saldo** | saldo | BC-3.2 | 25 | `burofisicas_concilia`, `burofisicas_concilia_clon`, `burofisicas_concilia_cnr`, `corresp_pagotdc_cargocta`, `sp_bedito_rechazo` (+20 más) |
| 16 | **tarjeta** | tarjeta | BC-3.5 | 25 | `altatarcred_v_1`, `reqsuc_td`, `sp_acl_reporte_log`, `sp_bedito_rechazo`, `sp_calc_comasiva` (+20 más) |
| 17 | **tipo** | tipo de | BC-4.x | 24 | `reqsuc_td`, `sp_activaserviciosdomi_lmpba`, `sp_aforecancelarprocejecpagos`, `sp_archivo_coppcnc`, `sp_calcula_caratulaproducto_pba` (+19 más) |
| 18 | **total** | total | — | 23 | `situacion_pago_tienda_cjunk_precal`, `sp_calcula_caratulaproducto_pba`, `sp_cargaarchivos_mc`, `sp_cnc_cga_stat06`, `sp_concreing_cargaarchivos` (+18 más) |
| 19 | **pago** | pago | BC-3.4 | 23 | `burofisicas`, `burofisicas_pba_jj`, `generaedosctacrd`, `movimientos_edoctacrd`, `movimientos_edoctacrd_web` (+18 más) |
| 20 | **estatus** | estatus | — | 23 | `cert_pag`, `cert_pag2`, `certi_chq`, `entre_chq`, `sp_cnt_genreportesfaltdescemp` (+18 más) |
| 21 | **descripcion** | descripción | — | 19 | `sp_actualiza_catdirectoriocte`, `sp_carga_clientes_camp`, `sp_gen_report_articulo_51`, `sp_msi_genrepmsigrid`, `sp_ope_generarepordpago` (+14 más) |
| 22 | **movimientos** | movimientos | — | 19 | `pasamovshist`, `pasamovshist_pba`, `pasamovshistcomp1`, `pasamovshistcomp2`, `pasamovshistcomp3` (+14 más) |
| 23 | **activa** | activa | — | 18 | `ivr_valida_telefono`, `sp_aforearchcifrasob`, `sp_aforearchconfob`, `sp_aforegenerararchivocifrascontrol`, `sp_aforevalidacargaarchivo` (+13 más) |
| 24 | **parametro** | parámetro | BC-4.x | 18 | `sp_consimpide`, `sp_ctamec_generarptportada`, `sp_ctamec_generarptportada2`, `sp_ctamec_generarptportadaproducto2_1`, `sp_ctamec_generarptportadaproducto2_2` (+13 más) |
| 25 | **proceso** | proceso | — | 16 | `sp_actualiza_catdirectoriocte`, `sp_aforearchcifrasob`, `sp_aforearchconfob`, `sp_aforegenerararchivocifrascontrol`, `sp_aforegenerararchivodeconfirmaciondepagos` (+11 más) |
| 26 | **nombre** | nombre | — | 16 | `sp_cnt_genreportesfaltdescemp`, `sp_frecuencia_uso`, `sp_gen_report_articulo_51`, `sp_pp_generareporteportafolio`, `sp_rep_cobvent_ctesvencsuc` (+11 más) |
| 27 | **periodo** | periodo | — | 16 | `gencartconsumo`, `gencartconsumo_crd`, `gencartconsumo_p`, `gencartconsumo_reproc`, `sp_calculagat` (+11 más) |
| 28 | **datos** | datos | — | 15 | `genmovinver`, `obtenerimagennula`, `reqsuc_td`, `sp_altatelefonoctasftes_migracion`, `sp_cat_consulta_disponibilidad_cliente` (+10 más) |
| 29 | **registro** | registro | — | 14 | `ivr_valida_telefono`, `sp_altatelefonoctasftes_migracion`, `sp_apertura_credito`, `sp_apertura_credito_aut`, `sp_apertura_credito_restructura_prestamo` (+9 más) |
| 30 | **archivo** | archivo | — | 14 | `sp_aforearchcifrasob`, `sp_aforearchconfob`, `sp_aforecancelarprocejecpagos`, `sp_aforegenerararchivocifrascontrol`, `sp_aforegenerararchivodeconfirmaciondepagos` (+9 más) |
| 31 | **ipab** | IPAB — Instituto para la Protección al Ahorro Bancario (segu | BC-3.2 | 14 | `sp_actualiza_saldos_ipab`, `sp_compensa_saldos_ipab`, `sp_ipab`, `sp_ipab_actualiza_saldos`, `sp_ipab_comp1` (+9 más) |
| 32 | **credito** | crédito | BC-3.3 | 13 | `altatarcred_v_1`, `consfircredper`, `corresp_pagotdc_cargocta`, `modif_minis`, `sp_apertura_credito` (+8 más) |
| 33 | **cuentas** | cuentas (plural) | BC-3.2 | 13 | `consnumctapornumcte_web`, `sc_cons_ctasdos_bpi`, `sc_cons_ctasdos_bpi_mx`, `sc_cons_ctasdos_bpii_pba1`, `sp_adn_obtienectas` (+8 más) |
| 34 | **origen** | origen | — | 12 | `pro_genera_reportes_pl`, `sp_actvig_camp`, `sp_actvig_camp_mx`, `sp_bedito_rechazo`, `sp_generarepdesconcentracionctas` (+7 más) |
| 35 | **tarjetas** | tarjetas (plural) | BC-3.5 | 12 | `sp_consultartarjetas_debcred_blodesb_iccat`, `sp_consultartarjetas_debcred_blodesb_iccat_v1`, `sp_consultartarjetas_debcred_can_iccat`, `sp_consultartarjetas_debcred_can_iccat_v1`, `sp_consultartarjetas_debcred_rep_iccat` (+7 más) |
| 36 | **orden** | orden | BC-3.4 | 12 | `califica_scoring2_cjunk`, `ordpago`, `reversion`, `reversion_exp`, `reversion_jom` (+7 más) |
| 37 | **registros** | registros | — | 12 | `sp_actualiza_saldos_ipab`, `sp_compensa_saldos_ipab`, `sp_consultadetallechqpropio`, `sp_consultaestatuscheques`, `sp_consultaglobalchqpropios` (+7 más) |
| 38 | **valor** | valor | — | 11 | `situacion_pago_tienda_cjunk_precal`, `sp_dispercionnomina_bpi`, `sp_dispercionnominaautomatico`, `sp_dispercionnominaautomatico_pba`, `sp_obtiene_periodo_vigencia_preingreso` (+6 más) |
| 39 | **reporte** | reporte | — | 11 | `sp_obtieneinfocierrediariosuc`, `sp_obtieneinfocobranza`, `sp_obtieneinfocobranza_web`, `sp_obtieneinfoopventanilla_web`, `sp_obtieneinfoproductividad` (+6 más) |
| 40 | **cierre** | cierre | — | 11 | `provisionlineacred`, `provisionlineacred_fin`, `sp_geninsumos_calif_pdig`, `sp_obtieneinfocierrediariosuc`, `sp_obtieneinfocobranza` (+6 más) |
| 41 | **referencia** | referencia | — | 11 | `sp_archivo_central`, `sp_cnsif_genarchmovimientos`, `sp_cnsif_genarchmovimientos2`, `sp_inicremesas`, `sp_insertactualizacentrocostos` (+6 más) |
| 42 | **importe** | importe | — | 11 | `actinteisr`, `get_numcheque`, `sp_concreing_validaintegridad`, `sp_frecuencia_uso`, `sp_generasecciones_oemn` (+6 más) |
| 43 | **resultado** | resultado | — | 11 | `sp_cancelatarjetas_lote`, `sp_cancelatarjetas_rob_frau_ext`, `sp_gen_report_articulo_51`, `sp_generarepdesconcentracionctas`, `sp_generarepdesconcentracionctas_2` (+6 más) |
| 44 | **comision** | comisión (CONDUSEF — debe estar en RECO) | BC-5.8 | 11 | `apercred1_pp_domicilia_web`, `apercred1_pp_web`, `sp_calculo_tiir_pp`, `sp_integracion_cuenta`, `sp_recuperacion_saldos` (+6 más) |
| 45 | **solicitud** | solicitud | BC-3.18 | 10 | `califica_scoring2_cjunk`, `modif_minis`, `sp_acl_valida_dfa_devo`, `sp_actualizasolicitudmc`, `sp_apertura_credito` (+5 más) |
| 46 | **inicio** | inicio | — | 10 | `gencartconsumo`, `gencartconsumo_crd`, `gencartconsumo_p`, `gencartconsumo_reproc`, `sp_genera_sol_cps` (+5 más) |
| 47 | **numtarjeta** | número de tarjeta | BC-3.5 | 9 | `sp_archivo_central`, `sp_descarga_credenciales_vcas`, `sp_puntoscompromiso3`, `sp_puntoscompromiso3_2`, `sp_tarj_det_vcas_exp` (+4 más) |
| 48 | **reversa** | Reversión — anula/revierte una operación (bdibei:sp_reversa_ | BC-3.5 | 9 | `reversion`, `reversion_exp`, `reversion_jom`, `reversion_pba`, `reversion_pba1` (+4 más) |
| 49 | **ejecutivo** | ejecutivo | — | 9 | `sp_carga_clientes_camp`, `sp_gen_report_articulo_51`, `sp_rep_vtas_club_proteccion`, `sp_repaltaunicaidbox`, `sp_reportebloqueoctasmasivocre` (+4 más) |
| 50 | **plazo** | plazo (depósito / crédito a plazo) | BC-3.2 | 9 | `cat`, `determina_lincred_tc_cjunk`, `metodo_frances`, `sp_actvig_camp`, `sp_actvig_camp_mx` (+4 más) |
| 51 | **calcular** | calcula (infinitivo) | — | 9 | `sp_dispercionnomina_bpi`, `sp_dispercionnominaautomatico`, `sp_dispercionnominaautomatico_pba`, `sp_dispercionnominamanual`, `sp_ideconsultageneral` (+4 más) |
| 52 | **alta** | da de alta / registra | — | 9 | `sp_activaserviciosdomi_lmpba`, `sp_consultactualizastatuscliente`, `sp_generareporteconciliaaperturapagarescargo`, `sp_ope_actualizacuentas`, `sp_ope_actualizanivcuentas` (+4 más) |
| 53 | **codigo** | código | BC-3.4 | 9 | `devotrobco`, `devotrobco2`, `principal`, `principal_jose`, `sp_consulta_referenciasfrec_bex` (+4 más) |
| 54 | **cargo** | cargo / débito | BC-3.4 | 8 | `generaedosctacrd`, `movimientos_edoctacrd`, `movimientos_edoctacrd_web`, `sp_aplicaaclaracredito`, `sp_aplicaaclaradebito` (+3 más) |
| 55 | **solicitudes** | solicitudes (plural) | BC-3.18 | 8 | `sp_generarchivoportab`, `sp_generarchivoportab_cancelaciones`, `sp_generarchivoresport`, `sp_generarchivoresport_cont`, `sp_indicadores_credito` (+3 más) |
| 56 | **forma** | construye / arma | — | 8 | `sp_dispercionnomina_bpi`, `sp_dispercionnominaautomatico`, `sp_dispercionnominaautomatico_pba`, `sp_dispercionnominamanual`, `sp_nominaconsultasaldoeje` (+3 más) |
| 57 | **diario** | diario | — | 8 | `sp_geninsumos_calif_parte`, `sp_obtieneinfocierrediariosuc`, `sp_obtieneinfocobranza`, `sp_obtieneinfocobranza_web`, `sp_obtieneinfoopventanilla_web` (+3 más) |
| 58 | **pagos** | pagos (plural) | BC-3.4 | 8 | `sp_aforevalidacargaarchivo`, `sp_cat_consulta_pagos_tc`, `sp_ejecutartransacciones`, `sp_ejecutartransacciones_inc`, `sp_ejecutartransacciones_pba` (+3 más) |
| 59 | **tasa** | tasa (de interés) | BC-3.3 | 8 | `determina_lincred_tc_cjunk`, `metodo_frances`, `sp_actvig_camp`, `sp_actvig_camp_mx`, `sp_adminitasas_cargarchivo` (+3 más) |
| 60 | **linea** | línea (de crédito) | BC-3.3 | 7 | `sp_ce_aplicapago`, `sp_gerenasenalizacion`, `sp_lecturarchivodatosimportar`, `sp_rep_men_increm_auto_cartven`, `sp_rep_men_increm_auto_hist` (+2 más) |
| 61 | **empresa** | empresa (entidad bancaria) | — | 7 | `sp_conciliainv`, `sp_genrep_cteemp`, `sp_identifica_saldosinmateriales`, `sp_reporte_saldosinmateriales`, `sp_ris_consultaproductos` (+2 más) |
| 62 | **mensaje** | mensaje | BC-3.18 | 7 | `apertura`, `apertura_app`, `sp_aforearchcifrasob`, `sp_aforegenerararchivocifrascontrol`, `sp_cg_reporteenviodotaciones` (+2 más) |
| 63 | **secuencia** | secuencia | — | 7 | `sp_conciliainv`, `sp_ingresos`, `sp_ingresos_pros`, `sp_puntoscompromiso3`, `sp_puntoscompromiso3_2` (+2 más) |
| 64 | **hora** | hora | — | 7 | `sp_bedito_rechazo`, `sp_cnsif_genarchmovimientos`, `sp_cnsif_genarchmovimientos2`, `sp_reporte_concilia_seguros`, `sp_reporte_donativos` (+2 más) |
| 65 | **comercio** | comercio afiliado | — | 7 | `sp_acl_valida_dfa_devo`, `sp_bedito_rechazo`, `sp_reportenegocio`, `sp_reportenegocio_pba`, `sp_reportenegocio_pbajj` (+2 más) |
| 66 | **split** | split — divide/parsea cadena (sp_split_cadena fan_in=857 — # | — | 6 | `sp_ctas_sdo_menor_mil_2`, `sp_ctas_sdo_menor_mil_2b`, `sp_dskrgainfoperativa`, `sp_dskrgainfoperativa_pbas3`, `sp_dskrgainfoperativacomp1` (+1 más) |
| 67 | **caja** | caja / ventanilla | — | 6 | `sp_catalogosuctrancaja`, `sp_consultadenominacionescaja`, `sp_consultadetalledotacioncaja`, `sp_enviardotacioncaja`, `sp_genreportexlsdepositoscoppel` (+1 más) |
| 68 | **clientes** | clientes (plural) | BC-7.1 | 6 | `sp_get_estadisticas_correos_telefonos_pba`, `sp_get_indicadores_alta_clientes`, `sp_get_indicadores_sucursal`, `sp_reporte_clientes_titulares_upgrade`, `sp_reporte_clientes_titulares_upgrade_2` (+1 más) |
| 69 | **lote** | lote (proceso batch) | — | 6 | `sp_reportebloqueoctascap`, `sp_reportebloqueoctasmasivocre`, `sp_reportedesbloqueoctascap`, `sp_reportedesbloqueoctasmasivocre`, `sp_reportemantolineasmasivocre` (+1 más) |
| 70 | **status** | estatus | — | 6 | `sp_aforecancelarprocejecpagos`, `sp_cg_reporteenviodotaciones`, `sp_msi_genrepmsigrid`, `sp_reporte_atm_acl_extra`, `sp_reportecargosreversoctasmasivocre` (+1 más) |
| 71 | **spei** | familia SPEI (pagos interbancarios) | BC-3.4 | 5 | `sp_coas_recibidos`, `sp_coas_recibidos_exp1`, `sp_ejecutartransacciones`, `sp_ejecutartransacciones_inc`, `sp_ejecutartransacciones_pba` |
| 72 | **mayor** | mayor contable | BC-5.4 | 5 | `sp_consultadetallechqpropio`, `sp_consultadetalledotacioncaja`, `sp_consultaglobalchqpropios`, `sp_enviardotacioncaja`, `sp_obtienemovtosdiarios` |
| 73 | **operaciones** | operaciones (plural) | — | 5 | `sp_chi_integra_reg_contables`, `sp_chi_ope_carga_sdos_com`, `sp_chi_ope_carga_sdos_diarios`, `sp_chi_ope_rep_concilia_com`, `sp_chi_ope_rep_concilia_mvtos` |
| 74 | **consulta** | consulta / lee | — | 5 | `sp_cat_consulta_saldostc`, `sp_consultadetallechqpropio`, `sp_consultaestatuscheques`, `sp_consultaglobalchqpropios`, `sp_gen_report_articulo_51` |
| 75 | **convenio** | convenio (nómina/empresarial) | — | 5 | `sp_archivo_central`, `sp_calcula_comisiones`, `sp_calcula_comisiones_pba`, `sp_pago_servicios_gdf`, `sp_sac_reportedetalletransucursal` |
| 76 | **modifica** | modifica | — | 5 | `cargo_ref_cel_pba`, `cargo_ref_cel_pba_sfsa`, `sp_geninsumos_calif_oyp`, `sp_geninsumos_calif_parte`, `sp_geninsumos_calif_pdig` |
| 77 | **clave** | clave | BC-4.x | 5 | `sp_ope_actualizacuentas`, `sp_ope_actualizanivcuentas`, `sp_ope_actualizatransportadora`, `sp_validacion_msj`, `sp_validaexistenciatarjetasbandachip` |
| 78 | **sistema** | sistema | — | 5 | `fechas`, `sp_actualizasolicitudmc`, `sp_conciliainv`, `sp_mueve_aclaraciones_historico`, `sp_rpt_saldos_cierre_dia` |
| 79 | **cobranza** | cobranza | BC-3.3 | 5 | `sp_carga_info_risck`, `sp_cat_consulta_saldostc`, `sp_reporte_clientes_titulares_upgrade`, `sp_reporte_clientes_titulares_upgrade_2`, `sp_reporte_clientes_titulares_upgrade_3` |
| 80 | **abono** | abono / crédito | BC-3.4 | 5 | `sp_aplicaaclaradebito`, `sp_aplicaaclaradebito_prueba`, `sp_cargoxajuste_debcred`, `sp_coas_recibidos`, `sp_coas_recibidos_exp1` |
| 81 | **evento** | evento/notificación | BC-3.18 | 5 | `sp_generarepdesconcentracionctas`, `sp_generarepdesconcentracionctas_2`, `sp_reporte_acl_aud`, `sp_reporte_atm_acl_extra`, `sp_top20acl` |
| 82 | **general** | general | — | 5 | `sp_cat_consulta_disponibilidad_cliente`, `sp_cat_consulta_saldostc`, `sp_catalogosuctrancaja`, `sp_consultadenominacionescaja`, `sp_genreportexlsdepositoscoppel` |
| 83 | **operacion** | operación | — | 5 | `sp_calcula_caratulaproducto_pba`, `sp_cg_reporteenviodotaciones`, `sp_ingresos`, `sp_ingresos_pros`, `sp_registraoperacion` |
| 84 | **aclaracion** | aclaración bancaria — proceso de disputa o reclamación del c | — | 4 | `sp_cierres_masivos_afectacion`, `sp_genera_reporte_sms`, `sp_mueve_aclaraciones_historico`, `sp_reporte_ppcoppel` |
| 85 | **transacc** | código de transacción | BC-4.x | 4 | `pro_genera_reportes_pl`, `sp_archivo_coppcnc`, `sp_conciliainv`, `sp_rpt_saldos_cierre_dia` |
| 86 | **campana** | campaña | — | 4 | `sp_gen_reporte_campana_prev_pzo`, `sp_gen_reporte_campana_prev_rev`, `sp_genera_rep_camp`, `sp_sd_ri_rep_camp` |
| 87 | **obtiene** | obtiene / recupera | — | 4 | `sp_aforearchconfob`, `sp_aforegenerararchivodeconfirmaciondepagos`, `sp_cat_consulta_saldostc`, `sp_pagopp_quitacondona` |
| 88 | **devolucion** | devuelve | — | 4 | `sp_acl_valida_dfa_devo`, `sp_cancelarcredito`, `sp_cancelarcreditocrd`, `spei_devcodi` |
| 89 | **desc** | [polisemia] Descripción (sp_desc_ret: devuelve descripción d | BC-5.4 | 4 | `sp_reportenegocio`, `sp_reportenegocio_pba`, `sp_reportenegocio_pbajj`, `sp_segcamp` |
| 90 | **conciliacion** | conciliación | BC-5.4 | 4 | `sp_archivo_central`, `sp_archivo_log`, `sp_carga_archivoseglobal`, `sp_conciladm_concileglounlpba` |
| 91 | **clabe** | CLABE interbancaria | BC-3.4 | 4 | `sp_aforearchconfob`, `sp_aforegenerararchivodeconfirmaciondepagos`, `sp_domi_valida_cuentatarjeta`, `sp_domi_valida_cuentatarjeta_ob` |
| 92 | **movimiento** | movimiento | — | 4 | `sp_aforecancelarprocejecpagos`, `sp_mueve_aclaraciones_historico`, `sp_repctasinactivasart61`, `sp_reporte_parametrico_rpt` |
| 93 | **domiciliacion** | domiciliación | BC-7.1 | 4 | `sp_activaserviciosdomi_lmpba`, `sp_domi_consulta_autorizacioncliente_ob`, `sp_domi_guardararchivo_manual`, `sp_rep_sac_reportedomiciliacion` |
| 94 | **encabezado** | encabezado | — | 4 | `sp_dispercionnomina_bpi`, `sp_dispercionnominaautomatico`, `sp_dispercionnominaautomatico_pba`, `sp_reporte_evidencias_3410` |
| 95 | **calculo** | cálculo | — | 4 | `determina_lincred_tc_cjunk`, `sp_calcula_comisiones_pba`, `sp_pago_servicios_gdf`, `sp_upd_credrecuperacion` |
| 96 | **retiro** | retiro | — | 4 | `sp_calcula_caratulaproducto_pba`, `sp_cancelarcredito`, `sp_cancelarcreditocrd`, `sp_conciliacion_pos_registro` |
| 97 | **archivos** | archivos | — | 4 | `sp_cnc_obt_archivo_stat06`, `sp_genera_documentos_reestructura`, `sp_nombre_archivo_atm_stat06_pagos`, `sp_nombre_archivo_dep_atm` |
| 98 | **estado** | estado (entidad federativa / estatus) | — | 4 | `sp_genera_reporte_sms`, `sp_generaarchivosat`, `sp_reporte_bim_alta_cte`, `sp_sorteo_registra_ganadores` |
| 99 | **canal** | canal (de distribución) | BC-1.x | 4 | `sp_domi_valida_alta`, `sp_domi_valida_alta_ob`, `sp_indicadores_credito`, `sp_reportes_agex_resultado` |
| 100 | **grupo** | grupo | — | 3 | `crea_gpo`, `crea_gpo1`, `crea_subgpo` |
| 101 | **indicadores** | indicadores | — | 3 | `sp_get_estadisticas_correos_telefonos_pba`, `sp_get_indicadores_alta_clientes`, `sp_get_indicadores_sucursal` |
| 102 | **envios** | envíos | — | 3 | `sp_generararchivoplano`, `sp_generararchivoplano_pba`, `sp_generartraspasoinfo` |
| 103 | **upgrade** | actualiza producto (upgrade) | BC-4.x | 3 | `sp_reporte_clientes_titulares_upgrade`, `sp_reporte_clientes_titulares_upgrade_2`, `sp_reporte_clientes_titulares_upgrade_3` |
| 104 | **motivo** | motivo / causa | — | 3 | `sp_bedito_rechazo`, `sp_puntoscompromiso3`, `sp_puntoscompromiso3_2` |
| 105 | **catalogo** | catálogo | BC-4.x | 3 | `crea_gpo`, `crea_gpo1`, `crea_subgpo` |
| 106 | **interes** | interés | BC-3.3 | 3 | `determina_lincred_tc_cjunk`, `sp_pagopp_quitacondona`, `sp_repctasinactivasart61` |
| 107 | **captura** | captura | — | 3 | `sp_bedito_rechazo`, `sp_txrechazo`, `sp_txrechazo_pba` |
| 108 | **titular** | titular de cuenta | BC-3.2 | 3 | `consfircredper`, `sp_fc_traspasoctascap`, `sp_pp_generareporteportafolio` |
| 109 | **procede** | procede | — | 3 | `sp_acl_valida_dfa_devo`, `sp_integracion_cuenta`, `sp_reporte_acl_aud` |
| 110 | **efectivo** | efectivo | — | 3 | `sp_evaldispefec_cred`, `sp_ope_manteminientoatms`, `sp_sorteo_efectivo` |
| 111 | **totales** | totales | — | 3 | `sp_formararchivodedeclaracion`, `sp_formararchivodedeclaracion2`, `sp_formararchivodedeclaracion_pba` |
| 112 | **saldos** | saldos | BC-3.2 | 3 | `sp_cat_consulta_saldostc`, `sp_compensa_saldos_ipab`, `sp_ipab_compensa_saldos` |
| 113 | **intereses** | intereses | BC-3.3 | 3 | `sp_admintasas_consultapagare`, `sp_pagopp_quitacondona`, `sp_provision_de_intereses` |
| 114 | **reversion** | reversa / rollback | — | 3 | `sp_grabaoperaciontef`, `sp_soe_cargarreversarcuentatoken`, `sp_soe_cargarreversarcuentatokenreenvio` |
| 115 | **cantidad** | cantidad | — | 3 | `sp_acl_valida_dfa_devo`, `sp_graba_faltsob`, `sp_validacion_msj` |
| 116 | **situaciones** | situaciones de cuenta | BC-3.2 | 3 | `sp_reporte_clientes_titulares_upgrade`, `sp_reporte_clientes_titulares_upgrade_2`, `sp_reporte_clientes_titulares_upgrade_3` |
| 117 | **cambio** | cambio (de estatus, domicilio, etc.) | BC-7.1 | 2 | `sp_geninsumos_calif_oyp`, `sp_geninsumos_calif_parte` |
| 118 | **ctemoral** | ctemoral — cuenta temporal (sp_guarda*ctemoral — bdicnweb) | — | 2 | `sp_guardactemoral`, `sp_guardactemoral2` |
| 119 | **masivo** | masivo | — | 2 | `sp_desbloqueoctacre_masivo`, `sp_mantolineacre_masivo` |
| 120 | **calle** | calle (domicilio) | BC-7.1 | 2 | `sp_actualizasolicitudmc`, `sp_insertactualizacentrocostos` |
| 121 | **mensual** | mensual | — | 2 | `sp_gerenasenalizacion`, `sp_ope_sldecanual` |
| 122 | **servicio** | servicio | — | 2 | `sp_activaserviciosdomi_lmpba`, `sp_registraoperacion` |
| 123 | **traspaso** | traspaso entre cuentas | BC-3.2 | 2 | `traint_por_cap`, `traspaso_int` |
| 124 | **bitacora** | bitácora | — | 2 | `ivr_valida_telefono`, `sp_mueve_aclaraciones_historico` |
| 125 | **presentado** | presentado (a cobro) | — | 2 | `devotrobco`, `devotrobco2` |
| 126 | **consultar** | consultar | — | 2 | `sp_cat_consulta_disponibilidad_cliente`, `sp_cat_consulta_pagos_tc` |
| 127 | **numsucursal** | número de sucursal | BC-1.x | 2 | `sp_ofi_genrepdepositoscuentacpp`, `sp_ofi_lecturaarchivocargafaltantes` |
| 128 | **final** | final | — | 2 | `sp_consultadetallechqpropio`, `sp_consultaglobalchqpropios` |
| 129 | **ruta** | ruta (de archivo) | — | 2 | `sp_carga_lista_archivos`, `sp_genera_documentos_reestructura` |
| 130 | **cheques** | cheques | BC-3.2 | 2 | `sp_ctasdos_cte_bei`, `sp_cuentas_bei` |
| 131 | **reverso** | reverso | BC-3.18 | 2 | `sp_reportecargosreversoctasmasivocre`, `sp_reportepagosreversoctasmasivocre` |
| 132 | **concepto** | concepto de pago | BC-3.4 | 2 | `sp_cnsif_genarchmovimientos2`, `sp_integracion_cuenta` |
| 133 | **retiros** | retiros | — | 2 | `sp_calcula_caratulaproducto_pba`, `sp_rpt_saldos_cierre_dia` |
| 134 | **cobro** | cobro | — | 2 | `sp_cobro_comision_x_anualidad`, `sp_upd_credrecuperacion` |
| 135 | **camp** | Campaña — campaña de cobranza o crédito (sp_envio_camp_ctes, | BC-3.3 | 2 | `sp_actvig_camp`, `sp_actvig_camp_mx` |
| 136 | **cancelacion** | cancela | BC-3.18 | 2 | `sp_cancelarcredito`, `sp_cancelarcreditocrd` |
| 137 | **correo** | correo electrónico | BC-7.1 | 2 | `sp_insertactualizacentrocostos`, `sp_rep_result_ctes_largos` |
| 138 | **reportes** | reportes | — | 2 | `sp_reportediarioacl`, `sp_reportediarioacl_2day` |
| 139 | **inserta** | inserta / registra | — | 2 | `sp_traspasoctabeneficencia_com`, `tmpsaldos` |
| 140 | **documento** | documento | — | 2 | `sp_archivo_central`, `sp_registra_documento_en_bitacora` |
| 141 | **cheque** | cheque | BC-3.2 | 2 | `chqcaj`, `sp_lecturarchivodatosimportar` |
| 142 | **envia** | envía | — | 2 | `cons_sdos2`, `cons_sdos2_web` |
| 143 | **generar** | generar (infinitivo — sp_generarbalanza*) | — | 2 | `sp_ope_sldecanual`, `sp_pld_chqc_crg_txt_validainf` |
| 144 | **expediente** | expediente | — | 2 | `sp_ca_cargaarchivoxml`, `sp_ro_cargaarchivooficiosxml` |
| 145 | **ejecuta** | ejecuta (verbo — proceso / operación) | — | 2 | `sp_reportediarioacl`, `sp_reportediarioacl_2day` |
| 146 | **divisa** | divisa | — | 2 | `sp_archivo_central`, `sp_pp_generareportedetallemovimientos` |
| 147 | **aclaraciones** | aclaraciones (proceso de disputas/reclamaciones de cliente) | BC-7.1 | 2 | `sp_mueve_aclaraciones_historico`, `sp_repaltaunicaidbox` |
| 148 | **primer** | primer | — | 2 | `sp_geninsumos_calif_oyp`, `sp_geninsumos_calif_parte` |
| 149 | **supervision** | supervisión | — | 2 | `califica_scoring2_cjunk`, `sp_actualizasolicitudmc` |
| 150 | **envio** | envía | — | 2 | `sp_actualizasolicitudmc`, `sp_cg_reporteenviodotaciones` |

---

## Términos con Cobertura de 1 SP (64 términos)

Estos 64 términos aparecen en exactamente un SP. Son relevantes pero no transversales.

| Término | Significado | BC | SP |
|---------|-------------|----|----|---|
| **respaldo** | respaldo / garantía de crédito (aval) | — | `sp_generareporteivaintreal` |
| **denominaciones** | denominaciones | BC-4.x | `sp_atms_consultadenosdoactual` |
| **firmas** | firmas mancomunadas | BC-7.1 | `sp_consulta_firmasregistradas` |
| **pais** | país | — | `sp_reporte_bim_alta_cte` |
| **situacion** | situación | — | `sp_gen_report_articulo_51` |
| **declaracion** | declaración | — | `sp_ope_sldecanual` |
| **aplica** | aplica / ejecuta | — | `sp_obtenerdatostransacciondbmovimiento_pos` |
| **param** | parámetro | BC-4.x | `sp_pld_chq_crg_xml_head` |
| **coppel** | Coppel (grupo) | — | `sp_indicadores_credito` |
| **tienda** | tienda Coppel — punto de venta físico / sucursal de tienda | — | `sp_sorteo_registra_ganadores` |
| **sorteo** | sorteo | — | `sp_sorteo_registra_ganadores` |
| **numcliente** | número de cliente | BC-7.1 | `sp_msi_genrepmsi` |
| **pasa** | pasa / mueve (verbo — pasamovshist* — archiva movimientos a  | — | `sp_cierre_credito` |
| **ciudad** | ciudad | — | `sp_gerenasenalizacion` |
| **valida** | valida | — | `corresp_pagotdc_cargocta` |
| **plantilla** | plantilla | — | `sp_ctes_tdd_retiros_atm` |
| **destino** | destino | — | `sp_registraoperacion` |
| **apertura** | apertura (de cuenta/crédito) | BC-3.2 | `sp_generareporteconciliaaperturapagarescargo` |
| **prestamo** | préstamo (Personal / Nómina / Digital BanCoppel) | BC-7.1 | `sp_indicadores_credito` |
| **numerocliente** | número de cliente | BC-7.1 | `sp_consulta_datos` |
| **moral** | persona moral | BC-7.1 | `sp_fc_traspasoctascap` |
| **zona** | zona | — | `sp_rpt_sol_movil` |
| **descarga** | descarga | — | `sp_ht_gen_archivo_tels` |
| **fechafinal** | fecha final | — | `sp_fal_busca_creditos_cat` |
| **validacion** | validación | — | `sp_gen_report_articulo_51` |
| **cobrar** | cobrar (infinitivo) | — | `sp_cobro_comision_x_anualidad` |
| **concentradora** | cuenta concentradora | BC-3.2 | `sp_abono_cta` |
| **ordenante** | ordenante (pagador que emite la orden SPEI) | BC-3.4 | `sp_cnsif_genarchmovimientos2` |
| **confirma** | confirma | — | `sp_genera_reporte_sms` |
| **revision** | revisión | — | `revisa_tasa` |
| **recuperacion** | recuperación (cobranza) | BC-3.3 | `sp_mueve_aclaraciones_historico` |
| **calcula** | calcula (verbo activo — spei_calculointeres) | — | `sp_calcula_comisiones` |
| **beneficiarios** | beneficiarios | BC-7.1 | `sp_validabeneficiarios` |
| **principal** | principal — capital principal de deuda / titular principal d | BC-3.2 | `sp_abono_cta` |
| **analista** | analista | — | `sp_reporte_acl_aud` |
| **plaza** | plaza (regional) | — | `sp_genreportexlsdepositoscoppel` |
| **fechainicial** | fecha inicial | — | `sp_fal_busca_creditos_cat` |
| **corte** | corte (fecha de corte / período) | — | `sp_geninsumos_calif_parte` |
| **causa** | causa / motivo | — | `sp_gen_report_articulo_51` |
| **autoriza** | autoriza | — | `sp_reporte_ppcoppel` |
| **presenta** | presenta | — | `consfircredper` |
| **numcredito** | número de crédito | BC-3.3 | `sp_msi_genrepmsi` |
| **prestamos** | préstamos | BC-3.3 | `sp_archivo_coppcnc` |
| **proc** | proceso | — | `sp_mantolineacre_masivo` |
| **categoria** | categoría | — | `sp_pp_generareporteportafolio` |
| **anio** | año | — | `sp_pp_generareporteportafolio` |
| **huellas** | huellas biométricas | — | `sp_dic_consultamatchhuellacte` |
| **receptor** | receptor | — | `sp_segcamp` |
| **nomina** | nómina | — | `sp_indicadores_credito` |
| **obtener** | obtiene / recupera | — | `sp_pagopp_quitacondona` |
| **historico** | histórico | — | `pasamovshistold1` |
| **carga** | carga / ingresa | — | `sp_carga_abonos_atm` |
| **mail** | correo electrónico | BC-7.1 | `sp_rep_result_ctes_largos` |
| **ingreso** | ingreso (del solicitante) | — | `sp_obtiene_periodo_vigencia_preingreso` |
| **inversion** | inversión (pagaré / plazo) | BC-3.3 | `sp_genera_reporte_sms` |
| **acuerdo** | acuerdo de pago — convenio de cobranza con el cliente (sp_gr | — | `sp_calcula_comisiones` |
| **marca** | marca | — | `sp_obtenerdatostransacciondbmovimiento_pos` |
| **activos** | activos | — | `sp_geninsumos_calif_parte` |
| **retenido** | retenido (fondos en retención) | — | `sp_conciliacion_pos_registro` |
| **empleado** | empleado | — | `sp_rep_cobvent_ctesvencsuc` |
| **asigna** | asigna | — | `sp_validaexistenciatarjetasbandachip` |
| **dotacion** | dotación de efectivo (a cajero/sucursal) | BC-1.x | `sp_cg_reporteenviodotaciones` |
| **concentracion** | concentración de fondos | — | `sp_repctasinactivasart61` |
| **realiza** | realiza / ejecuta una operación SPEI | — | `sp_cobro_comision_x_anualidad` |

---

## Términos sin Cobertura de Reglas — Posibles Gaps (499 términos)

Estos términos están en el vocabulario pero no aparecen en ninguna regla de negocio extraída. Pueden indicar: (1) gaps de extracción donde el SP existe pero las reglas no fueron capturadas, (2) términos de infraestructura o prefijos que no mapean a lógica de negocio, o (3) términos del dominio que aún no tienen SP dedicado.

| # | Término | Significado | BC | Categoría |
|---|---------|-------------|----|-----------|
| 1 | **6dig** | OTP/token de 6 dígitos — autenticación fuerte SMS | — | MODIF |
| 2 | **abonoinmediato** | abono inmediato | BC-3.4 | ENTIDAD |
| 3 | **acceso** | acceso | — | ENTIDAD |
| 4 | **acl** | familia aclaraciones | BC-3.18 | PREFIJO |
| 5 | **act** | actualiza | — | ACCION |
| 6 | **activar** | activar | — | ACCION |
| 7 | **actualiza** | actualiza | — | ACCION |
| 8 | **adm** | administración/administrar (abreviación de admin) | — | ACCION |
| 9 | **admin** | Administrador — rol de usuario con privilegios administrativ | — | ENTIDAD |
| 10 | **admtoken** | AdmToken — módulo de administración de tokens de autenticaci | BC-7.1 | ENTIDAD |
| 11 | **adn** | Adelanto de Nómina — producto de crédito al consumo liquidab | BC-3.3 | ACCION |
| 12 | **afore** | AFORE (Afore Coppel — 2ª mayor de México, ~14.5M cuentas) | BC-3.2 | ENTIDAD |
| 13 | **agendadas** | agendadas | — | MODIF |
| 14 | **alerta** | alerta | BC-3.18 | ENTIDAD |
| 15 | **alertas** | alertas | BC-3.18 | ENTIDAD |
| 16 | **ant** | anterior | — | MODIF |
| 17 | **apell** | apellido | — | ENTIDAD |
| 18 | **apellido** | apellido | — | ENTIDAD |
| 19 | **aplicaordenpago** | aplica orden de pago | BC-3.4 | ACCION |
| 20 | **aplicar** | aplica / ejecuta | — | ACCION |
| 21 | **apoderado** | apoderado | BC-7.1 | ENTIDAD |
| 22 | **app** | canal app | BC-1.x | MODIF |
| 23 | **arch** | archivo | — | ENTIDAD |
| 24 | **archsdos** | Archivos de Saldos — comentario explícito: 'Genera archivos  | BC-3.2 | ENTIDAD |
| 25 | **arr** | ARR — producto de ahorro/inversión recurrente (CLABE, interé | BC-3.4 | ENTIDAD |
| 26 | **art61** | Art. 61 LIC (cuentas inactivas cuyos saldos, tras años sin m | BC-3.2 | REG |
| 27 | **asiento** | asiento contable | BC-5.4 | ENTIDAD |
| 28 | **atm** | cajero automático (ATM) | BC-1.x | ENTIDAD |
| 29 | **atms** | cajeros automáticos (ATM) | BC-1.x | ENTIDAD |
| 30 | **aud** | auditoría | — | ENTIDAD |
| 31 | **auditoria** | auditoría | — | ENTIDAD |
| 32 | **aum** | aumento | — | MODIF |
| 33 | **aumento** | aumento | — | MODIF |
| 34 | **aumlincred** | Aumento de Línea de Crédito — proceso de incremento del lími | BC-3.3 | ACCION |
| 35 | **aut** | autorización | — | ACCION |
| 36 | **autenticacion** | autenticación | — | ENTIDAD |
| 37 | **auto** | automático (proceso automático / batch — sp_*_auto) | — | MODIF |
| 38 | **auxiliar** | auxiliar contable — sub-ledger contable (sdos_auxiliar, sp_v | — | ENTIDAD |
| 39 | **aval** | aval / garante | — | ENTIDAD |
| 40 | **avatar** | avatar (foto de perfil del usuario en app) | BC-1.x | ENTIDAD |
| 41 | **b3** | sufijo de versión de SP (Bloque/Build 3) — patrón Informix:  | — | MODIF |
| 42 | **b4** | sufijo de versión de SP (Bloque/Build 4) | — | MODIF |
| 43 | **b5** | sufijo de versión de SP (Bloque/Build 5) | — | MODIF |
| 44 | **baja** | de baja | — | MODIF |
| 45 | **balanza** | balanza de comprobación — trial balance (sp_generarbalanza*  | — | ENTIDAD |
| 46 | **balp** | balp — balance preventivo / balanza preventiva (gen_balprev* | — | ENTIDAD |
| 47 | **banco** | banco | — | ENTIDAD |
| 48 | **bandera** | bandera / flag (técnico) | — | MODIF |
| 49 | **batch** | proceso batch (por lotes) | — | MODIF |
| 50 | **bccc** | BCCC — formato o protocolo de consulta al Buró de Crédito (b | BC-3.3 | ENTIDAD |
| 51 | **bei** | BEI — Banca En Internet; canal digital principal de BanCoppe | BC-3.4 | ENTIDAD |
| 52 | **benef** | beneficiario | BC-7.1 | ENTIDAD |
| 53 | **beneficiario** | beneficiario (receptor del pago SPEI) | BC-7.1 | ENTIDAD |
| 54 | **bex** | BEX — canal o plataforma de Banca Por Internet (bdibpi); ges | BC-3.2 | ENTIDAD |
| 55 | **biometrico** | biométrico | — | ENTIDAD |
| 56 | **bloq** | bloqueo | — | ACCION |
| 57 | **bloquea** | bloquea cuenta | BC-3.2 | ACCION |
| 58 | **bloqueo** | bloquea cuenta | BC-3.2 | ACCION |
| 59 | **borra** | borra / elimina registros (borramovs_movhis, borramovscfd*) | — | ACCION |
| 60 | **boveda** | bóveda | — | ENTIDAD |
| 61 | **bpi** | Banca Por Internet (canal web BPI) | BC-1.x | MODIF |
| 62 | **bts** | Bancomer Transfer Services — canal de transferencias BBVA; b | BC-3.4 | ENTIDAD |
| 63 | **buro** | Buró de Crédito | BC-3.3 | ENTIDAD |
| 64 | **burofisicas** | Buró Personas Físicas — consulta al Buró de Crédito para per | BC-7.1 | ENTIDAD |
| 65 | **busca** | busca / localiza | — | ACCION |
| 66 | **buscar** | búsqueda/buscar | — | ACCION |
| 67 | **busqueda** | búsqueda | — | ACCION |
| 68 | **bym** | Billetes y Monedas (efectivo en sucursal — evidencia: 'pieza | BC-3.2 | ENTIDAD |
| 69 | **bym2** | Billetes y Monedas (v2) | — | ENTIDAD |
| 70 | **bym3** | Billetes y Monedas (v3) | — | ENTIDAD |
| 71 | **cac** | familia crédito (CAC) | BC-3.3 | PREFIJO |
| 72 | **cadena** | cadena — string / cadena de texto (sp_split_cadena) | — | ENTIDAD |
| 73 | **cal** | [polisemia] Cálculo (cal_fecha, cal_riesgo_cliente, cal_trad | BC-7.1 | ENTIDAD |
| 74 | **calif** | calificación | BC-3.3 | ENTIDAD |
| 75 | **califica** | califica / evalúa (scoring) | BC-3.3 | ACCION |
| 76 | **cam** | cámara / captura contable | BC-5.4 | PREFIJO |
| 77 | **canales** | canales (de distribución) | BC-1.x | ENTIDAD |
| 78 | **cancela** | cancela | — | ACCION |
| 79 | **cant** | cantidad | — | ENTIDAD |
| 80 | **cap** | Captación — cuentas de ahorro/depósito; evidencia: sp_cap_ge | BC-3.2 | ENTIDAD |
| 81 | **cargamanual** | carga manual | — | ACCION |
| 82 | **cargamovimiento** | carga movimiento | — | ACCION |
| 83 | **cartera** | cartera de crédito | BC-3.3 | ENTIDAD |
| 84 | **cat** | catálogo | BC-3.3 | ENTIDAD |
| 85 | **catdenominacion** | catálogo de denominaciones | BC-4.x | ENTIDAD |
| 86 | **cc** | cc — cuenta corriente (sp_*_cc_* — bdicnweb) | — | ENTIDAD |
| 87 | **cce** | CCE — Cámara de Compensación Electrónica (CECOBAN/Banxico) — | BC-3.2 | ENTIDAD |
| 88 | **ccl** | módulo de Cédulas de Captación e inversión — pagaré, ISR, sa | BC-3.2 | ENTIDAD |
| 89 | **cedula** | cédula de identificación | BC-5.4 | ENTIDAD |
| 90 | **cedulacontable** | cédula contable | BC-5.4 | ENTIDAD |
| 91 | **cedulas** | cédulas | BC-5.4 | ENTIDAD |
| 92 | **cel** | celular | BC-7.1 | ENTIDAD |
| 93 | **cep** | Comprobante Electrónico de Pago (SPEI · Banxico) | BC-3.4 | ENTIDAD |
| 94 | **cfdi** | CFDI — Comprobante Fiscal Digital por Internet (SAT · factur | BC-5.8 | REG |
| 95 | **cg** | cg — Canal/Cuenta General (subsistema sp_cg_* — bdicnweb) | — | ENTIDAD |
| 96 | **cheq** | cheque | BC-3.2 | ENTIDAD |
| 97 | **chi** | CHI — formato/protocolo de consulta al Buró de Crédito (bdib | BC-3.3 | ENTIDAD |
| 98 | **chq** | cheque (abreviación — bdicheq) | BC-3.2 | ENTIDAD |
| 99 | **ciloc** | consulta local de cobranza | BC-3.3 | PREFIJO |
| 100 | **cilocconsulta** | consulta local (cobranza) | BC-3.3 | ACCION |
| 101 | **circulo** | Círculo de Crédito — buró de crédito para personas físicas ( | — | ENTIDAD |
| 102 | **cita** | cita | — | ENTIDAD |
| 103 | **citas** | citas | — | ENTIDAD |
| 104 | **ciudades** | ciudades (catálogo) | BC-4.x | ENTIDAD |
| 105 | **cjunk** | variable temporal (ruido de código, se ignora) | BC-4.x | AMBIGUO |
| 106 | **ckpt** | checkpoint — evento de checkpointing del motor Informix | — | MODIF |
| 107 | **claverastreo** | clave de rastreo SPEI (hasta 30 posiciones alfanuméricas, Ba | BC-3.4 | ENTIDAD |
| 108 | **clic** | BanCoppel Clic (tarjeta digital instantánea) | BC-3.5 | ENTIDAD |
| 109 | **clon** | [polisemia] Clon de SP (réplica funcional para variante de e | BC-3.2 | ENTIDAD |
| 110 | **cnc** | CNC — sistema de configuración de planes fijos de Tarjetas C | BC-3.5 | ENTIDAD |
| 111 | **cnr** | CNR — tipo o formato de consulta al Buró de Crédito para per | BC-7.1 | ENTIDAD |
| 112 | **cns** | consulta | — | ACCION |
| 113 | **cnsif** | CNSIF — sistema de confirmación de ejecutivo (sp_cnsif_confi | BC-5.4 | ENTIDAD |
| 114 | **cnt** | CNT — módulo de convenios y control de descuentos de nómina  | — | ENTIDAD |
| 115 | **coas** | COAS — Confirmación de Operación y Acuse de Recibo Simplific | — | ENTIDAD |
| 116 | **cob** | cob — cobranza (abreviación de dominio — sp_repcob_*, sp_obt | — | ENTIDAD |
| 117 | **cobra** | cobra / aplica cobro / genera cargo | — | ACCION |
| 118 | **cod** | código | BC-4.x | ENTIDAD |
| 119 | **codi** | CoDi — Cobro Digital (Banxico) | BC-3.4 | REG |
| 120 | **codificacion** | codificación | BC-3.4 | ENTIDAD |
| 121 | **codigos** | códigos | BC-3.4 | ENTIDAD |
| 122 | **colonia** | colonia — colonia postal para validación de domicilio (sp_co | — | ENTIDAD |
| 123 | **colonias** | colonias (catálogo domicilio) | BC-7.1 | ENTIDAD |
| 124 | **com** | Comisión bancaria — cobro de comisión sobre cuenta (bdicheq: | BC-3.2 | ENTIDAD |
| 125 | **combo** | combo / lista desplegable (control de UI en app) | BC-1.x | ENTIDAD |
| 126 | **comp** | complemento | — | MODIF |
| 127 | **compac** | Compromisos de Pago en Cobranza — acuerdos/convenios de pago | BC-3.3 | ENTIDAD |
| 128 | **compromiso** | compromiso de pago — promesa formal de liquidación (sp_consu | — | ENTIDAD |
| 129 | **con** | consulta | — | ACCION |
| 130 | **concilia** | conciliación | BC-5.4 | ACCION |
| 131 | **conciliadora** | conciliadora | — | ENTIDAD |
| 132 | **concreing** | Conciliación de Reingresos — proceso de conciliación de tarj | BC-3.5 | ENTIDAD |
| 133 | **confirmasms** | confirma vía SMS (2FA) | — | ACCION |
| 134 | **cons** | consulta | — | ACCION |
| 135 | **conscedulas** | consulta cédulas | BC-5.4 | ACCION |
| 136 | **consecutivo** | consecutivo | — | ENTIDAD |
| 137 | **consolidada** | consolidada / consolidado — cifras consolidadas (balanza dia | — | MODIF |
| 138 | **consprodcte** | consulta producto de cliente | BC-7.1 | ACCION |
| 139 | **consreporte** | consulta reporte | — | ACCION |
| 140 | **consreportes** | consulta reportes | — | ACCION |
| 141 | **conssaldosdiarios** | consulta saldos diarios | BC-3.2 | ACCION |
| 142 | **consuta** | consulta [typo] | — | ACCION |
| 143 | **consutacat** | consulta catálogo [typo] | BC-4.x | ACCION |
| 144 | **cont** | familia contabilidad | BC-5.4 | PREFIJO |
| 145 | **conyuge** | cónyuge (solicitud crédito) | BC-3.3 | ENTIDAD |
| 146 | **correos** | correos electrónicos (email) | BC-7.1 | ENTIDAD |
| 147 | **corresp** | Corresponsal — corresponsal bancario; red de puntos de servi | BC-1.x | ENTIDAD |
| 148 | **corresponsal** | corresponsal | — | ENTIDAD |
| 149 | **cp** | código postal | BC-4.x | ENTIDAD |
| 150 | **cpl** | CPL — segmento o producto de cliente (sp_dictamina_ctes_cpl, | BC-7.1 | ENTIDAD |
| 151 | **crd** | crédito (abreviación) | BC-3.3 | ENTIDAD |
| 152 | **cre** | crédito | BC-3.3 | ENTIDAD |
| 153 | **cred** | crédito | BC-3.3 | ENTIDAD |
| 154 | **credisoluciones** | CrediSoluciones — producto/segmento de crédito BanCoppel (sp | BC-3.3 | ENTIDAD |
| 155 | **creditos** | créditos (plural) | BC-3.3 | ENTIDAD |
| 156 | **cta** | cuenta | BC-3.2 | ENTIDAD |
| 157 | **ctaclabe** | cuenta CLABE | BC-3.2 | ENTIDAD |
| 158 | **ctamec** | Cuenta Mecánica — tipo de cuenta de cheques empresarial para | BC-3.2 | ENTIDAD |
| 159 | **ctanvl2** | Cuenta Nivel 2 (CNBV Circular Única de Bancos) — categoría r | BC-3.2 | ENTIDAD |
| 160 | **ctas** | cuentas | BC-3.2 | ENTIDAD |
| 161 | **ctasinactivas** | cuentas inactivas | BC-3.2 | ENTIDAD |
| 162 | **ctb** | ctb — contabilidad (abreviación interfaz — sp_ctbcpl_* D11↔D | — | ENTIDAD |
| 163 | **cte** | cliente | BC-7.1 | ENTIDAD |
| 164 | **ctefisico** | Cliente Físico — persona física (tp_persona CHAR(2)); distin | BC-7.1 | ENTIDAD |
| 165 | **ctepr** | Cliente Prospecto — cliente potencial aún sin cuenta abierta | BC-7.1 | ENTIDAD |
| 166 | **ctes** | clientes | BC-7.1 | ENTIDAD |
| 167 | **cve** | clave (cve) | BC-4.x | ENTIDAD |
| 168 | **datosdia** | datos del día | — | ENTIDAD |
| 169 | **deb** | débito | — | MODIF |
| 170 | **debcred** | débito/crédito (movimiento) | BC-3.3 | ENTIDAD |
| 171 | **debito** | débito | — | ENTIDAD |
| 172 | **decodifica** | decodifica | BC-3.4 | ACCION |
| 173 | **decodificar** | decodifica | BC-3.4 | ACCION |
| 174 | **denominacion** | denominación (valor facial del billete/moneda) | BC-4.x | ENTIDAD |
| 175 | **dep** | depósito | BC-3.2 | ENTIDAD |
| 176 | **depura** | depura / limpia | — | ACCION |
| 177 | **depuracion** | depuración | — | ACCION |
| 178 | **desb** | desbloqueo | — | ACCION |
| 179 | **desbloquea** | desbloquea cuenta | BC-3.2 | ACCION |
| 180 | **desbloqueo** | desbloquea cuenta | BC-3.2 | ACCION |
| 181 | **det** | detalle | — | ENTIDAD |
| 182 | **detalle** | detalle | — | ENTIDAD |
| 183 | **determina** | determina | — | ACCION |
| 184 | **dev** | devolución | — | ACCION |
| 185 | **devforzada** | devolución forzada | — | ACCION |
| 186 | **dia** | del día | — | MODIF |
| 187 | **diarios** | diarios | — | MODIF |
| 188 | **dic** | [polisemia] Dictamen (bdicnweb:sp_dic_* — decisión creditici | BC-4.x | ENTIDAD |
| 189 | **dicta** | dicta — dictamen / subsistema de dictaminación (sp_dicta_* — | BC-3.3 | ENTIDAD |
| 190 | **dictamen** | dictamen | — | ENTIDAD |
| 191 | **digi** | digitalización | — | ACCION |
| 192 | **digitalizacion** | digitalización de documentos | — | ENTIDAD |
| 193 | **digitalizar** | digitaliza documento | — | ACCION |
| 194 | **digito** | dígito verificador | — | ENTIDAD |
| 195 | **digver** | dígito verificador (abreviación — digverclabe NO_VERIFICABLE | — | ENTIDAD |
| 196 | **dinya** | DINYA — sistema/plataforma de remesas domésticas en sucursal | BC-3.4 | ENTIDAD |
| 197 | **direccion** | dirección | — | ENTIDAD |
| 198 | **direcciones** | direcciones | — | ENTIDAD |
| 199 | **disper** | disper — dispersión (abreviación — sp_dispercionnomina_*) | — | ENTIDAD |
| 200 | **dispersion** | dispersión — dispersión de nómina (sp_dispercionnomina_bpi) | — | ENTIDAD |
| 201 | **divisas** | divisas | — | ENTIDAD |
| 202 | **division** | división | — | ENTIDAD |
| 203 | **docto** | documento | — | ENTIDAD |
| 204 | **doctos** | documentos | — | ENTIDAD |
| 205 | **documentos** | documentos | — | ENTIDAD |
| 206 | **domi** | domiciliación | BC-7.1 | ENTIDAD |
| 207 | **domicilio** | domicilio | BC-7.1 | ENTIDAD |
| 208 | **dormidas** | cuentas dormidas (inactivas) | BC-3.2 | MODIF |
| 209 | **dotaciones** | dotaciones de efectivo | — | ENTIDAD |
| 210 | **dv** | dv — divisa (abreviación — bdisac) | — | ENTIDAD |
| 211 | **edo** | estado | — | ENTIDAD |
| 212 | **edocta** | Estado de Cuenta — documento periódico de movimientos y sald | BC-3.2 | ENTIDAD |
| 213 | **edoctacrd** | Estado de Cuenta Crédito — documento de movimientos y saldos | BC-3.2 | ENTIDAD |
| 214 | **edocuenta** | Estado de Cuenta (variante ortográfica de edocta — bdicheq/b | BC-3.2 | ENTIDAD |
| 215 | **efectiva** | Cuenta Efectiva Digital (débito BanCoppel) | BC-3.2 | ENTIDAD |
| 216 | **elimina** | elimina | — | ACCION |
| 217 | **emisor** | emisor | — | ENTIDAD |
| 218 | **emp** | Empresa — empleadora del cliente; vinculada a crédito de nóm | BC-7.1 | ENTIDAD |
| 219 | **empresarial** | empresarial (nómina) | — | ENTIDAD |
| 220 | **empresas** | empresas (nómina empresarial) | — | ENTIDAD |
| 221 | **enavipro** | ENAVIPRO — tipo de mensaje SPEI (Envío de Aviso en Proceso / | — | ENTIDAD |
| 222 | **esp** | especial | — | MODIF |
| 223 | **estadisticas** | estadísticas | — | ENTIDAD |
| 224 | **estatussolic** | estatus de solicitud | BC-3.18 | ENTIDAD |
| 225 | **etiqueta** | etiqueta | — | ENTIDAD |
| 226 | **evc** | EVC — Evaluación/Cartera a Quebrantar (write-off de cartera  | — | ENTIDAD |
| 227 | **exec** | exec — ejecuta / execute (abreviación — execmuestraedocta, e | — | ACCION |
| 228 | **exp** | sufijo Exportar — SP genera/exporta archivo de salida (sp_*_ | BC-3.2 | MODIF |
| 229 | **extemporanea** | extemporánea | — | MODIF |
| 230 | **factelect** | Factura Electrónica / CFDI | — | ENTIDAD |
| 231 | **factura** | factura | — | ENTIDAD |
| 232 | **facturacion** | facturación | — | ENTIDAD |
| 233 | **fal** | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancari | — | ENTIDAD |
| 234 | **fallecimiento** | por fallecimiento | — | MODIF |
| 235 | **faltantes** | faltantes | — | MODIF |
| 236 | **fatca** | FATCA (reporte fiscal cuentas EE.UU. — SAT/IRS) | BC-3.2 | REG |
| 237 | **fc** | fc — Fuentes Combinadas (subsistema sp_fc_*; biométricos — b | — | ENTIDAD |
| 238 | **fechaconsulta** | fecha de consulta | — | ENTIDAD |
| 239 | **fechafin** | fecha fin | — | ENTIDAD |
| 240 | **fechainicio** | fecha inicio | — | ENTIDAD |
| 241 | **firme** | monto firme | — | MODIF |
| 242 | **fisica** | persona física | BC-7.1 | MODIF |
| 243 | **fisicas** | personas físicas | BC-7.1 | MODIF |
| 244 | **fn** | función SQL | — | PREFIJO |
| 245 | **folionomina** | folio de nómina | BC-3.18 | ENTIDAD |
| 246 | **folsuc** | folio de sucursal | BC-1.x | ENTIDAD |
| 247 | **forzada** | forzada | — | MODIF |
| 248 | **frecpago** | frecuencia de pago | BC-3.3 | ENTIDAD |
| 249 | **ftc** | FTC — módulo de configuración de transferencia de archivos ( | BC-3.2 | ENTIDAD |
| 250 | **fus** | fusión de cuentas | BC-3.2 | ACCION |
| 251 | **fus2** | fusión v2 | — | AMBIGUO |
| 252 | **fusion** | fusiona cuentas | BC-3.2 | ACCION |
| 253 | **fusionados** | fusionados | — | MODIF |
| 254 | **garantia** | garantía | — | ENTIDAD |
| 255 | **gdf** | gdf — código geográfico / Gobierno CDMX (abreviación — bdisa | — | ENTIDAD |
| 256 | **gen** | genera / general | — | ACCION |
| 257 | **genera** | genera / produce | — | ACCION |
| 258 | **generafechpagoreestructura** | genera fecha de pago de reestructura | BC-3.3 | ACCION |
| 259 | **generafolionomina** | genera folio de nómina | BC-3.18 | ACCION |
| 260 | **generaredoctaeje** | Genera Estado de Cuenta Ejecutivo — proceso de generación de | BC-3.2 | ACCION |
| 261 | **genrep** | genera reporte (abreviación genrep) | — | ACCION |
| 262 | **graba** | graba / almacena | — | ACCION |
| 263 | **gral** | general | — | MODIF |
| 264 | **guarda** | guarda / almacena | — | ACCION |
| 265 | **habil** | día hábil — día bancario operativo (spei_validafecha, sp_cam | — | ENTIDAD |
| 266 | **hipoteca** | crédito hipotecario (digital, desde 2025) | BC-3.3 | ENTIDAD |
| 267 | **hipotecario** | crédito hipotecario | BC-3.3 | ENTIDAD |
| 268 | **his** | histórico | — | MODIF |
| 269 | **hist** | histórico/historial | — | MODIF |
| 270 | **hoy** | de hoy / fecha actual | — | MODIF |
| 271 | **huella** | huella biométrica | — | ENTIDAD |
| 272 | **iccat** | ICCAT — canal de atención al cliente en BPI; gestiona solici | BC-7.1 | ENTIDAD |
| 273 | **ics** | ICS — sistema de cuotas/mensualidades de crédito (sp_ics_cuo | BC-3.3 | ENTIDAD |
| 274 | **id** | identificador (de) | — | ENTIDAD |
| 275 | **identificacion** | identificación | — | ENTIDAD |
| 276 | **idfuncion** | id de funcionalidad | — | ENTIDAD |
| 277 | **idfuncionc** | id de funcionalidad | — | ENTIDAD |
| 278 | **imagen** | imagen digital | — | ENTIDAD |
| 279 | **imagenes** | imágenes / documentos digitales | — | ENTIDAD |
| 280 | **imp** | Impago — pago vencido o fallido; confirmado: n_impagos_conse | BC-3.4 | ENTIDAD |
| 281 | **impuesto** | impuesto (SAT) | — | REG |
| 282 | **inactiv** | inactiva | BC-5.8 | MODIF |
| 283 | **inactivas** | inactivas (art.61) | BC-5.8 | MODIF |
| 284 | **indicador** | indicador — marcador de estado o condición (sp_ambientar_ind | — | ENTIDAD |
| 285 | **ine** | INE — Instituto Nacional Electoral (validación de identidad  | BC-7.1 | REG |
| 286 | **inf** | información | — | ENTIDAD |
| 287 | **info** | información | — | ENTIDAD |
| 288 | **inicia** | inicia | — | ACCION |
| 289 | **inicializa** | inicializa | — | ACCION |
| 290 | **inicializar** | inicializa | — | ACCION |
| 291 | **inmediato** | inmediato | — | MODIF |
| 292 | **innovattia** | Innovattia — proveedor externo de notificaciones SMS/email p | — | ENTIDAD |
| 293 | **ins** | insertar | — | ACCION |
| 294 | **int** | interés | BC-3.3 | ENTIDAD |
| 295 | **intercambio** | intercambio (interbancario) | — | ENTIDAD |
| 296 | **inv** | inv — inversión (abreviación — calsdoinvcrec, cierrechqinvcr | — | ENTIDAD |
| 297 | **isr** | ISR — Impuesto Sobre la Renta (retención · SAT) | BC-5.8 | REG |
| 298 | **iva** | IVA (impuesto — SAT) | BC-5.8 | REG |
| 299 | **ivasart61** | IVA sobre operaciones del Art. 61 LIC (alcance fiscal por co | BC-5.8 | REG |
| 300 | **ivr** | canal IVR (telefónico) | BC-1.x | MODIF |
| 301 | **layout** | layout — formato de archivo de intercambio interbancario | — | ENTIDAD |
| 302 | **libro** | libro mayor / libro contable — general ledger (libromayor_di | — | ENTIDAD |
| 303 | **lin** | línea (de crédito) | BC-3.3 | ENTIDAD |
| 304 | **lincred** | línea de crédito | BC-3.3 | ENTIDAD |
| 305 | **liq** | liquidación (abreviación — sp_marcaliqpago, spei_recliquidac | — | ENTIDAD |
| 306 | **liquidacion** | liquidación | — | ENTIDAD |
| 307 | **local** | local | — | MODIF |
| 308 | **mac** | dirección MAC | — | ENTIDAD |
| 309 | **manco** | Mancomunidad — cuenta u operación con múltiples titulares au | BC-3.2 | ENTIDAD |
| 310 | **manual** | manual | — | MODIF |
| 311 | **maquila** | maquila — proceso de externalización de solicitudes TDC | — | ENTIDAD |
| 312 | **marcas** | marcas de cuenta | BC-3.2 | ENTIDAD |
| 313 | **masiva** | masiva | — | MODIF |
| 314 | **max** | máximo | — | MODIF |
| 315 | **mc** | mc — Mesa de Control (abreviación — sp_cons_empleado_mc) | — | ENTIDAD |
| 316 | **medioacceso** | medio de acceso | — | ENTIDAD |
| 317 | **mensajes** | mensajes | BC-3.18 | ENTIDAD |
| 318 | **mes** | mes | — | ENTIDAD |
| 319 | **mesa** | Mesa de Control — equipo de revisión y autorización de solic | BC-3.3 | ENTIDAD |
| 320 | **mesas** | Mesas de Control — equipo de revisión y autorización de soli | BC-3.3 | ENTIDAD |
| 321 | **mib** | MIB — módulo/canal de integración para cheques y tarjeta (ca | BC-3.2 | ENTIDAD |
| 322 | **mnsj** | mensajería / notificaciones (dominio bdimnsj) | — | PREFIJO |
| 323 | **mnsjr** | mensajería registrada / tabla de transacciones de mensajería | — | PREFIJO |
| 324 | **mon** | monitor / módulo | — | PREFIJO |
| 325 | **monitor** | monitor | — | ENTIDAD |
| 326 | **monitoreo** | monitoreo — proceso de vigilancia/seguimiento operativo | — | ENTIDAD |
| 327 | **monitorsol** | Monitor de Solicitudes — sistema de monitoreo de solicitudes | BC-3.3 | ENTIDAD |
| 328 | **motor** | motor de decisión | — | ENTIDAD |
| 329 | **mov** | movimiento | — | ENTIDAD |
| 330 | **mover** | mueve / archiva (operación de paso a histórico) | — | ACCION |
| 331 | **movhis** | Movimientos Históricos — tabla/proceso de historial de movim | BC-4.x | ENTIDAD |
| 332 | **movil** | canal móvil | BC-1.x | MODIF |
| 333 | **movs** | movimientos (abreviación) | — | ENTIDAD |
| 334 | **movto** | movimiento | — | ENTIDAD |
| 335 | **msi** | meses sin intereses (MSI) | BC-3.3 | ENTIDAD |
| 336 | **msj** | mensaje — abreviación corta de mnsj (sp_validacion_msj) | — | ENTIDAD |
| 337 | **msjafore** | mensaje AFORE | BC-3.18 | ENTIDAD |
| 338 | **mueve** | mueve / traslada (verbo complemento de mover) | — | ACCION |
| 339 | **mvl** | canal móvil | BC-1.x | MODIF |
| 340 | **nip** | NIP — Número de Identificación Personal (PIN bancario) | — | ENTIDAD |
| 341 | **nom** | nómina | — | ENTIDAD |
| 342 | **nombreref** | nombre de referencia | — | ENTIDAD |
| 343 | **notifi** | notifica | — | ACCION |
| 344 | **notifica** | notifica | — | ACCION |
| 345 | **num** | número (de) | — | ENTIDAD |
| 346 | **numcred** | número de crédito | BC-3.3 | ENTIDAD |
| 347 | **numcuenta** | número de cuenta | BC-3.2 | ENTIDAD |
| 348 | **numproducto** | número de producto | BC-4.x | ENTIDAD |
| 349 | **numsol** | número de solicitud | BC-3.18 | ENTIDAD |
| 350 | **numsolicitud** | número de solicitud | BC-3.18 | ENTIDAD |
| 351 | **obt** | obtiene | — | ACCION |
| 352 | **obten** | obtiene / recupera | — | ACCION |
| 353 | **obtenerctas** | obtener cuentas (bdicheq:sp_obtenerctas_*) | BC-3.2 | ACCION |
| 354 | **ofi** | oficio | — | ENTIDAD |
| 355 | **oficio** | oficio (requerimiento judicial/autoridad) | — | ENTIDAD |
| 356 | **online** | online — transferencia en línea (sp_transfer_online_* — cana | — | ENTIDAD |
| 357 | **opcion** | opción | — | ENTIDAD |
| 358 | **ope** | operación | — | ACCION |
| 359 | **ord** | ordenante / orden (SPEI) | BC-3.4 | ENTIDAD |
| 360 | **ordenes** | órdenes | — | ENTIDAD |
| 361 | **ordenpago** | orden de pago | BC-3.4 | ENTIDAD |
| 362 | **oro** | Tier medio de la Tarjeta de Crédito BanCoppel — jerarquía Cl | BC-3.5 | ENTIDAD |
| 363 | **os** | OS — Originación de Solicitudes / subsistema de ofertas (sp_ | — | ENTIDAD |
| 364 | **oxo** | OXXO (abreviación — spei_entordenespago_oxo) | — | ENTIDAD |
| 365 | **oxxo** | OXXO (red de depósito/retiro) | BC-3.2 | ENTIDAD |
| 366 | **pagare** | pagaré | BC-3.3 | ENTIDAD |
| 367 | **pagares** | pagarés | BC-3.3 | ENTIDAD |
| 368 | **paq** | paquete — paquete de pago SPEI (bloque/lote de órdenes de tr | — | ENTIDAD |
| 369 | **parametrico** | paramétrico — parametrización de modelos (envío paramétrico) | — | ENTIDAD |
| 370 | **parentesco** | parentesco (referencia) | — | ENTIDAD |
| 371 | **pase** | pase contable (registra/traslada a póliza o mayor) | BC-5.4 | ACCION |
| 372 | **pasecheq** | pase de cheque (a compensación/conciliación) | BC-3.2 | ACCION |
| 373 | **pasecont** | realiza el pase contable (registro a póliza/mayor) | BC-5.4 | ACCION |
| 374 | **pba** | PBA — sufijo de SPs para Pruebas; confirmado por SME (Guerra | — | MODIF |
| 375 | **perfil** | perfil de usuario | — | ENTIDAD |
| 376 | **periodicidad** | periodicidad | — | MODIF |
| 377 | **pieza** | pieza de efectivo (billete/moneda) | — | ENTIDAD |
| 378 | **piezas** | piezas de efectivo (billetes y monedas) | BC-3.2 | ENTIDAD |
| 379 | **pin** | PIN dinámico (tarjeta digital) | BC-3.5 | ENTIDAD |
| 380 | **pld** | PLD — Prevención de Lavado de Dinero (AML) | BC-5.8 | REG |
| 381 | **politica** | política de crédito | BC-3.3 | ENTIDAD |
| 382 | **poliza** | póliza contable | BC-5.4 | ENTIDAD |
| 383 | **por** | por (criterio) | — | MODIF |
| 384 | **portab** | portabilidad — portabilidad de nómina (sp_generarchivoportab | — | ENTIDAD |
| 385 | **portabilidad** | portabilidad (de nómina o número) | — | ENTIDAD |
| 386 | **portanom** | Portabilidad de Nómina — portabilidad de domiciliación de nó | BC-7.1 | ENTIDAD |
| 387 | **pos** | punto de venta (POS) | — | ENTIDAD |
| 388 | **pp** | PP — Pago Programado / domiciliación (apercred1_pp, generaed | — | ENTIDAD |
| 389 | **presentacion** | presentación | — | ENTIDAD |
| 390 | **preventivo** | preventivo | — | MODIF |
| 391 | **proac** | PROAC — producto de cuenta de ahorro con inscripción y ciclo | BC-3.2 | ENTIDAD |
| 392 | **procesa** | procesa | — | ACCION |
| 393 | **prod** | producto | BC-4.x | ENTIDAD |
| 394 | **productos** | productos | BC-4.x | ENTIDAD |
| 395 | **productotransaccion** | producto-transacción | BC-4.x | ENTIDAD |
| 396 | **promocion** | promoción | — | ENTIDAD |
| 397 | **propuesta** | propuesta | — | ENTIDAD |
| 398 | **prospectos** | prospectos (nuevos clientes potenciales) | BC-7.1 | ENTIDAD |
| 399 | **proyeccion** | proyección de cartera / saldo | — | ENTIDAD |
| 400 | **puntos** | puntos (recompensas) | — | ENTIDAD |
| 401 | **quebr** | quebranto — write-off de cartera vencida (bdicred) | — | ACCION |
| 402 | **quincena** | quincena (periodo de pago nómina/crédito Coppel) | BC-3.4 | ENTIDAD |
| 403 | **rastreo** | rastreo (SPEI) | BC-3.4 | ENTIDAD |
| 404 | **rcda** | RCDA — producto de captación/ahorro (apertura, incremento de | BC-3.2 | ENTIDAD |
| 405 | **rec** | recepción / recibe | — | ACCION |
| 406 | **reccancelacion** | recibe cancelación | BC-3.18 | ACCION |
| 407 | **recdevolucion** | recibe devolución | — | ACCION |
| 408 | **recextemporanea** | recibe orden extemporánea | BC-3.4 | ACCION |
| 409 | **recompensa** | recompensa / cashback (Coppel Max) | — | ENTIDAD |
| 410 | **recordenpago** | recibe orden de pago | BC-3.4 | ACCION |
| 411 | **recupera** | recupera estado | — | ACCION |
| 412 | **reevaluacion** | reevaluación de crédito | — | ACCION |
| 413 | **ref** | referencia | — | AMBIGUO |
| 414 | **reg** | registro | — | ACCION |
| 415 | **regex** | regex — motor de expresiones regulares Informix SPL (infraes | — | ENTIDAD |
| 416 | **region** | región | — | ENTIDAD |
| 417 | **registra** | registra | — | ACCION |
| 418 | **regordenctecte** | Regresa Orden Cuenta a Cuenta — operación de transferencia/o | BC-7.1 | ACCION |
| 419 | **reinicia** | reinicia / resetea | — | ACCION |
| 420 | **reinicio** | reinicio | — | ACCION |
| 421 | **rem** | remesa (forma corta) | BC-3.4 | ENTIDAD |
| 422 | **remanente** | remanente | — | MODIF |
| 423 | **remesa** | remesa (Western Union / MoneyGram) | BC-3.4 | ENTIDAD |
| 424 | **remesadora** | remesadora (envío de remesas) | BC-3.4 | ENTIDAD |
| 425 | **remesas** | remesas internacionales | BC-3.4 | ENTIDAD |
| 426 | **rep** | reporte | — | ACCION |
| 427 | **repipab** | Reporte IPAB — reporte regulatorio de seguimiento de depósit | BC-3.2 | ENTIDAD |
| 428 | **reproceso** | reproceso | — | ACCION |
| 429 | **reserva** | reserva | — | ENTIDAD |
| 430 | **respalda** | respalda / garantiza — aval o garantía de crédito (respalda_ | — | ACCION |
| 431 | **rev** | reversión (abreviación de reversa/reverso) | BC-3.18 | ACCION |
| 432 | **rfc** | RFC (registro fiscal) | BC-5.8 | ENTIDAD |
| 433 | **ris** | Riesgo — módulo de gestión de riesgo crediticio (bdicnweb:sp | BC-3.3 | ENTIDAD |
| 434 | **ro** | ro — Rol Operativo (subsistema sp_sw_ro_* — bdicnweb) | — | ENTIDAD |
| 435 | **rol** | rol / perfil | — | ENTIDAD |
| 436 | **rpt** | reporte | — | ENTIDAD |
| 437 | **rst** | rst — formato RST (sp_generararchivo_rst fan_in=345 — NO_VER | — | ENTIDAD |
| 438 | **sac** | Servicios de Atención al Cliente — subsistema de atención en | BC-7.1 | ENTIDAD |
| 439 | **salida** | salida | — | ENTIDAD |
| 440 | **sat** | SAT — Servicio de Administración Tributaria (CFDI, ISR, IVA) | BC-5.8 | REG |
| 441 | **sbc** | saldo básico de cuenta (SBC) | BC-3.2 | ENTIDAD |
| 442 | **scoring** | scoring crediticio | BC-3.3 | ENTIDAD |
| 443 | **sd** | sd — saldo disponible (abreviación en código de crédito) | — | ENTIDAD |
| 444 | **sdo** | saldo | BC-3.2 | ENTIDAD |
| 445 | **sdodisp** | saldo disponible | BC-3.2 | ENTIDAD |
| 446 | **sdos** | saldos (abreviación) | BC-3.2 | ENTIDAD |
| 447 | **seg** | [polisemia] Seguridad (bdicnweb: usuarios, perfiles, app móv | BC-3.4 | ENTIDAD |
| 448 | **sif** | SIF — canal de estado de cuenta (aclaraciones_edocta_sif, de | BC-3.2 | ENTIDAD |
| 449 | **sms** | SMS | — | ENTIDAD |
| 450 | **soc** | Sistema Operativo Central (SOC) — confirmado SME | — | ENTIDAD |
| 451 | **soe** | SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorg | — | ENTIDAD |
| 452 | **sol** | solicitud | BC-3.18 | ENTIDAD |
| 453 | **solic** | solicitud | BC-3.18 | ENTIDAD |
| 454 | **solin** | solicitud de crédito | BC-3.3 | ENTIDAD |
| 455 | **sp** | stored procedure | — | PREFIJO |
| 456 | **speich** | SPEI-CH — tipo de movimiento SPEI de compensación/cheque (ac | — | ENTIDAD |
| 457 | **sps** | sps — prefijo alternativo de SP en bdibei (posiblemente 'sto | — | PREFIJO |
| 458 | **ss** | ss — subsistema / canal de monitoreo (abreviación — envia_mo | — | ENTIDAD |
| 459 | **stat06** | Stat06 — tipo/código de archivo de carga en procesamiento de | BC-3.5 | ENTIDAD |
| 460 | **sub** | sub- | — | MODIF |
| 461 | **subproducto** | sub-producto | BC-4.x | ENTIDAD |
| 462 | **suc** | sucursal | BC-1.x | MODIF |
| 463 | **susc** | suscriptor / suscripción (alertas SMS/email — tablas mnsjr_s | — | ENTIDAD |
| 464 | **suscriptores** | gestiona suscriptores | — | ACCION |
| 465 | **sv** | sv — supervisión/servicio (abreviación — bdiaclaracion) | — | ENTIDAD |
| 466 | **sw** | sw — SoftWare/Switch (subsistema sp_sw_ro_* — bdicnweb) | — | ENTIDAD |
| 467 | **synmotor** | SynMotor — motor de procesamiento de Syndein (empresa extern | BC-3.5 | ENTIDAD |
| 468 | **tar** | Tarjeta (abreviación — bdicheq/bdicred: cons_cta_o_tar, move | BC-3.5 | ENTIDAD |
| 469 | **tbl** | tbl — tabla (abreviación — sp_depura_tbl_registro_msj) | — | ENTIDAD |
| 470 | **tc** | tc — Tarjeta de Crédito (abreviación en solicitudes y crédit | — | ENTIDAD |
| 471 | **tco** | TCO — Tarjetas Coppel / TCoppel (producto de crédito Grupo C | BC-3.5 | ENTIDAD |
| 472 | **tdc** | tarjeta de crédito (TDC) | BC-3.5 | ENTIDAD |
| 473 | **tdd** | TDD — Tarjeta de Débito | BC-3.5 | ENTIDAD |
| 474 | **tef** | TEF — transferencia electrónica de fondos | BC-3.4 | ENTIDAD |
| 475 | **tel** | teléfono | BC-7.1 | ENTIDAD |
| 476 | **telefonico** | telefónico | BC-7.1 | MODIF |
| 477 | **telefonos** | teléfonos | BC-7.1 | ENTIDAD |
| 478 | **tels** | teléfonos (plural) | BC-7.1 | ENTIDAD |
| 479 | **temp** | temporal | — | MODIF |
| 480 | **titulo** | título | — | ENTIDAD |
| 481 | **token** | token (autenticación) | BC-3.5 | ENTIDAD |
| 482 | **tp** | tipo | BC-4.x | MODIF |
| 483 | **tpcalculo** | tipo de cálculo | BC-4.x | ENTIDAD |
| 484 | **trae** | trae / recupera (verbo — sp_*_trae — bdisuc) | — | ACCION |
| 485 | **trans** | [polisemia] Transferencia (bditransfer, bditrans: transferen | BC-3.4 | ENTIDAD |
| 486 | **transfer** | transferencia (forma larga de 'trans') | BC-3.4 | ENTIDAD |
| 487 | **transportadora** | transportadora de valores (traslado de efectivo) | — | ENTIDAD |
| 488 | **traspas** | traspaso | BC-3.4 | ACCION |
| 489 | **ultimas** | últimas | — | MODIF |
| 490 | **upd** | actualiza (update) | — | ACCION |
| 491 | **usuarios** | usuarios | — | ENTIDAD |
| 492 | **valid** | valida | — | ACCION |
| 493 | **vencimiento** | vencimiento | — | ENTIDAD |
| 494 | **venio** | convenio | — | ENTIDAD |
| 495 | **verifica** | verifica | — | ACCION |
| 496 | **visual** | visual | — | MODIF |
| 497 | **web** | canal web | BC-1.x | MODIF |
| 498 | **wu** | Western Union — servicio de remesas/transferencias internaci | — | ENTIDAD |
| 499 | **xml** | XML | — | ENTIDAD |

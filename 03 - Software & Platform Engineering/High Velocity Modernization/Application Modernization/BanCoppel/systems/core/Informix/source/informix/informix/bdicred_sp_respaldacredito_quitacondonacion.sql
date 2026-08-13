CREATE PROCEDURE "informix".sp_respaldacredito_quitacondonacion(pTipoCuenta CHAR(01))
   RETURNING CHAR(05);   --CodRet

--Valores Posibles ParÃÂ¡metros de Entrada   
-- pTipoCuenta -->  R cuenta revolvente, P cuenta a plazo


DEFINE iSqlErr		INTEGER;
DEFINE iIsamErr		INTEGER;
DEFINE cErrorInfo	CHAR(80);
DEFINE CodRet		CHAR(05);

--   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;                        
DEFINE GLOBAL g_Empresa    CHAR(03) DEFAULT '';                             
DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT '';                             
--   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';                             

LET CodRet = "00000";  
--LET cnumcredito = '';

BEGIN   
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET CodRet = iSqlErr;
--		  LET cMensajeRet  = cErrorInfo;
          RETURN CodRet;
       END IF;
    END EXCEPTION;

   	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ; 
	
	
/*   SELECT MAX(secuencia)                                                        
     INTO wSecuenciaPago                                                        
     FROM sd_secpago                                                            
    WHERE empresa = g_Empresa                                                   
      AND num_credito = g_NumCredito; */

--set debug file to "respaldacredito.out";
--trace on;
  

/*   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN                        
      LET wSecuenciaPago = 0;                                                   
   END IF;*/

--   LET wSecuenciaPago = wSecuenciaPago + 1;                                     

--	SELECT count(num_credito) INTO cnumcredito FROM "informix".sd_secpago WHERE num_credito = g_NumCredito AND folio_suc = g_Folio;
--	IF cnumcredito = 0 THEN
	IF pTipoCuenta = 'R' THEN
	-------------------------------------------------------                         
	--    RESPALDO DE MAECRED                            --                         
	-------------------------------------------------------                         
	   INSERT INTO bdicred:"informix".sd_maecredrev_quitacondonacion
				(fecha, hora, empresa, num_credito, num_producto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2, cuenta_clabe)
			SELECT
				today, current, empresa, num_credito, num_producto, ejecutivo, numcte, divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea, porc_rec_prop, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora, tasa_moratorios, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, codigo_pro, superficie, actividad, cal_edos_fin, tipo_calculo, admite_tlp, rel_garcred, id_unidad_prod, num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, num_fideicomiso, credito_externo, gracia_capital, diferimiento_int, fecha_fin_prorrateo, campo_trab1, campo_trab2, campo_trab3, campo_trab4, calificacion_riesgo, cod_agricola, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo, factor_techo, tasa_techo, cod_caract, cod_caract_2, cuenta_clabe
			FROM bdicred:sd_maecred                                                                  
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito;

	----------------------------------------------------------                      
	--            RESPALDO DE MAESDOS                                               
	----------------------------------------------------------                      
		INSERT INTO bdicred:"informix".sd_maesdosrev_quitacondonacion
				(fecha, hora, empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4)
			SELECT
				today, current, empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4
			FROM bdicred:sd_maesdos                                                              
			WHERE empresa     = g_Empresa                                                
			AND num_credito = g_NumCredito;

    ----------------------------------------                                        
	-- Inicia Respaldo de sd_maecredanexo --                                        
	----------------------------------------                                        
		INSERT INTO bdicred:"informix".sd_maecredanexorev_quitacondonacion
				(fecha, hora, empresa, num_credito, dia_corte, dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago, tp_dias_fecha_pago, cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte, tasa_interes_cte, fecha_vencto, prox_fecha_pago, fecha_proceso, fecha_ult_pago)
			SELECT 
				today, current, empresa, num_credito, dia_corte, dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago, tp_dias_fecha_pago, cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte, tasa_interes_cte, fecha_vencto, prox_fecha_pago, fecha_proceso, fecha_ult_pago
			FROM bdicred:sd_maecredanexo                                                          
			WHERE empresa = g_Empresa                                                      
			AND num_credito = g_NumCredito;

	---------------------------------------------
	--Inicia Respaldo de sd_amortiza_credito --
	---------------------------------------------
		INSERT INTO bdicred:"informix".sd_amortiza_creditorev_quitacondonacion
				(fecha, hora, empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4)
			SELECT 
				today, current, empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4
			FROM bdicred:sd_amortiza_credito
			WHERE empresa     = g_empresa
			AND Num_credito = g_numcredito;
	--------------------------------------
	ELIF pTipoCuenta = 'P' THEN
	-------------------------------------------------------                         
	--    RESPALDO DE MAECRED                            --                         
	-------------------------------------------------------                         
	   INSERT INTO bdicred:"informix".sd_maecredcrdrev_quitacondonacion
				(fecha, hora, empresa, num_credito, num_producto, ejecutivo, numcte, aval_cte, aval_linea, divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora, tasa_moratorios, tasa_preferencial, sobretasa_preferencial, factor_preferencial, valor_preferencial, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, actividad, tipo_calculo, num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, credito_externo, califica_riesgo, cod_agricola, pagos_sostenidos, campo_trab1, campo_trab2, campo_trab3, campo_trab4, cuenta_clabe)
			SELECT
				today, current, empresa, num_credito, num_producto, ejecutivo, numcte, aval_cte, aval_linea, divisa, sucursal, id_origen, origen, cod_tipo_linea, cod_linea, status_cred, bandera_renovac, bandera_prorroga, periodo_plazo, plazo, fecha_apertura, fecha_vencim, period_pago_cap, period_pag_int, dias_trasp_cap, dias_trasp_int, tasa_fija_o_var, cod_tasa_base, factor_sobretasa, sobretasa, tasa_interes, cod_tasa_mora, sobretasa_mora, fact_sobret_mora, tasa_moratorios, tasa_preferencial, sobretasa_preferencial, factor_preferencial, valor_preferencial, fecha_pago_cap, fecha_pago_int, es_fisica, bandera_fi_fo, actividad, tipo_calculo, num_aper_ant, rev_tasa_var_per, dia_para_revisar, cod_prod, bandera_ministra, credito_externo, califica_riesgo, cod_agricola, pagos_sostenidos, campo_trab1, campo_trab2, campo_trab3, campo_trab4, cuenta_clabe
			FROM bdicred:sd_maecredcrd
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito;

	----------------------------------------------------------                      
	--            RESPALDO DE MAESDOS                                               
	----------------------------------------------------------                      
		INSERT INTO bdicred:"informix".sd_maesdoscrdrev_quitacondonacion
				(fecha, hora, empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4)
			SELECT
				today, current, empresa, num_credito, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int, sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4
			FROM bdicred:sd_maesdoscrd
			WHERE empresa     = g_Empresa                                                
			AND num_credito = g_NumCredito;

    ----------------------------------------                                        
	-- Inicia Respaldo de sd_maecredanexo --                                        
	----------------------------------------                                        
		INSERT INTO bdicred:"informix".sd_maecredanexocrdrev_quitacondonacion
				(fecha, hora, empresa, num_credito, localidad, dia_corte, dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago, tp_dias_fecha_pago, cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte, tasa_interes_cte, fecha_vencto, prox_fecha_pago, fecha_proceso, fecha_ult_pago, nombre_pres, cat)
			SELECT 
				today, current, empresa, num_credito, localidad, dia_corte, dias_gracia_mora, tp_dias_calc_mora, dias_fecha_max_pago, tp_dias_fecha_pago, cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte, tasa_interes_cte, fecha_vencto, prox_fecha_pago, fecha_proceso, fecha_ult_pago, nombre_pres, cat
			FROM bdicred:sd_maecredanexocrd
			WHERE empresa = g_Empresa                                                      
			AND num_credito = g_NumCredito;

	---------------------------------------------
	--Inicia Respaldo de sd_amortiza_credito --
	---------------------------------------------
		INSERT INTO bdicred:"informix".sd_amortiza_creditocrdrev_quitacondonacion
				(fecha, hora, empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4)
			SELECT 
				today, current, empresa, num_credito, fecha_cuota, tipo_cuota, capital_mto_cuota, capital_debe, capital_pagado, capital_status, capital_status_ant, capital_fecha_pago, interes_debe, interes_pagado, interes_status, interes_status_ant, interes_fecha_pago, iva_debe, iva_pagado, iva_status, iva_status_ant, iva_fecha_pago, mora_provi_ordi, mora_provi_cope, mora_sdo_ordi, mora_sdo_ordi_pag, mora_sdo_cope, mora_sdo_cope_pag, mora_bonificado, mora_status, mora_iva_debe, mora_iva_pagado, mora_iva_status, mora_iva_fecha_pago, num_pago, campo_trabajo1, campo_trabajo2, campo_trabajo3, campo_trabajo4
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa     = g_empresa
			AND Num_credito = g_numcredito;
	--------------------------------------
	END IF;
RETURN CodRet;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_respalda_credito_pp(pEmpresa CHAR(3),
                                                   pNumCred CHAR(20),
                                                   pUsuario CHAR(20))
RETURNING CHAR(6);

-- Modificacion: Paul Ivan Quintero Varela.
-- Fecha: 11/11/2009.
-- Comentario: * Se modifica para contemplar el campo "nombre_pres" en la tabla "sd_maecredanexocrd".
--             * Se modifica el retorno a 6 posiciones "000000".

DEFINE iSqlErr       INT;
DEFINE cCodRet              CHAR(6);
DEFINE dtFechaHoy           DATE;
DEFINE iSecuenciaPago       LIKE sd_secpago.secuencia;

DEFINE GLOBAL g_Empresa     CHAR(3)  DEFAULT "";
DEFINE GLOBAL g_NumCredito  CHAR(20) DEFAULT "";
DEFINE GLOBAL g_Folio       CHAR(16) DEFAULT "";

DEFINE crevempresa			CHAR(3);
DEFINE crevsistema			CHAR(2);
DEFINE crevnum_promo		INTEGER;
DEFINE crevfecha			DATE;
DEFINE crevejecutivo		CHAR(9);
DEFINE crevnum_cte			CHAR(20);
DEFINE crevnum_credito		CHAR(20);
DEFINE crevnum_tarjeta		CHAR(20);
DEFINE crevplazo			SMALLINT;
DEFINE crevfolio_suc		CHAR(16);
DEFINE crevmonto_actual		DECIMAL(18,2);
DEFINE crevmonto_int_iva	DECIMAL(18,2);
DEFINE crevmensualidad		DECIMAL(18,2);
DEFINE crevstatus			SMALLINT;
DEFINE crevnombre_promo		CHAR(50);
DEFINE crevsucursal			CHAR(4);
DEFINE crevnum_sol_prestamo	CHAR(20);
DEFINE crevnum_pro_prestamo	CHAR(4);
DEFINE crevfolio_movto		CHAR(16);
DEFINE cNumCreditocrdsol	CHAR(20);
DEFINE cFolioSucMovCrd		CHAR(16);
DEFINE c_Folio_Suc		    CHAR(16);
DEFINE cNumCredito          CHAR(20);
DEFINE cfolio_mov           CHAR(16);
DEFINE iSecuencia			INTEGER;
DEFINE cInFolMov			CHAR(1);
DEFINE iContador			INTEGER;

DEFINE scont INT8;



LET iSqlErr      = 0;
LET cCodRet 	 = "000000";
LET g_Empresa    = pEmpresa;
LET g_NumCredito = pNumCred;

LET crevempresa			= "";
LET crevsistema			= "";
LET crevnum_promo		= 0;
LET crevfecha			= mdy(1, 1, 1900);
LET crevejecutivo		= "";
LET crevnum_cte			= "";
LET crevnum_credito		= "";
LET crevnum_tarjeta		= "";
LET crevplazo			= 0;
LET crevfolio_suc		= "";
LET crevmonto_actual	= 0;
LET crevmonto_int_iva	= 0;
LET crevmensualidad		= 0;
LET crevstatus			= 0;
LET crevnombre_promo	= "";
LET crevsucursal		= "";
LET crevnum_sol_prestamo ="";
LET crevnum_pro_prestamo = "";
LET crevfolio_movto		= "";
LET scont				= 0;
LET cNumCreditocrdsol   = pNumCred;
LET cFolioSucMovCrd 	= "";
LET c_Folio_Suc         = '';
LET cNumCredito         = '';
LET cfolio_mov          = "";
LET iSecuencia			= 0;
LET cInFolMov			= "";
LET iContador			= 0;

BEGIN
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet;
       END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/informix/mahr/respalda_credito_pp.out";
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
   SELECT MAX(a.secuencia)
     INTO iSecuenciaPago
     FROM bdicred: "informix".sd_secpago a
    WHERE a.empresa     = g_Empresa
      AND a.num_credito = g_NumCredito;

   SELECT a.fecha_hoy
     INTO dtFechaHoy
     FROM bdicred: "informix".sd_fechas a
    WHERE a.empresa = g_Empresa;
   
       IF(iSecuenciaPago = 0 OR iSecuenciaPago IS NULL) THEN
          LET iSecuenciaPago = 0;
       END IF; 

    LET iSecuenciaPago = iSecuenciaPago + 1;
	LET cNumCreditocrdsol = cNumCreditocrdsol;
    IF g_Folio IS NULL THEN 
        SELECT
               SUBSTR(USER,1,4)||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)||
               SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||
               SUBSTR(CURRENT,18,2)
          INTO g_Folio
          FROM bdicred: "informix".dual;
     END IF;
     
	SELECT count(num_credito) INTO iContador FROM "informix".sd_secpago WHERE num_credito = g_NumCredito AND folio_suc = g_Folio;
	IF iContador = 0 THEN     

       INSERT INTO bdicred: "informix".sd_secpago(empresa, num_credito, folio_suc, secuencia)
            VALUES (g_empresa, g_NumCredito, g_Folio, iSecuenciaPago);
    
    -------------------------------------------------------
    --    RESPALDO DE MAECREDCRD                         --
    -------------------------------------------------------
        INSERT INTO bdicred: "informix".sd_maecredrevcrd
                   (empresa,                folio,                 num_credito,          num_producto,          ejecutivo,
                    numcte,                 aval_cte,              aval_linea,           divisa,                sucursal,
                    id_origen,              origen,                cod_tipo_linea,       cod_linea,             status_cred,
                    bandera_renovac,        bandera_prorroga,      periodo_plazo,        plazo,                 fecha_apertura,
                    fecha_vencim,           period_pago_cap,       period_pag_int,       dias_trasp_cap,        dias_trasp_int,
                    tasa_fija_o_var,        cod_tasa_base,         factor_sobretasa,     sobretasa,             tasa_interes, 
                    cod_tasa_mora,          sobretasa_mora,        fact_sobret_mora,     tasa_moratorios,       tasa_preferencial,
                    sobretasa_preferencial, factor_preferencial,   valor_preferencial,   fecha_pago_cap,        fecha_pago_int,
                    es_fisica,              bandera_fi_fo,         actividad,            tipo_calculo,          num_aper_ant,
                    rev_tasa_var_per,       dia_para_revisar,      cod_prod,             bandera_ministra,      credito_externo,
                    califica_riesgo,        cod_agricola,          pagos_sostenidos,     campo_trab1,           campo_trab2,
                    campo_trab3,            campo_trab4,	cuenta_clabe)
             SELECT      
                    empresa,                g_Folio,               num_credito,          num_producto,          ejecutivo,
                    numcte,                 aval_cte,              aval_linea,           divisa,                sucursal,
                    id_origen,              origen,                cod_tipo_linea,       cod_linea,             status_cred,
                    bandera_renovac,        bandera_prorroga,      periodo_plazo,        plazo,                 fecha_apertura,
                    fecha_vencim,           period_pago_cap,       period_pag_int,       dias_trasp_cap,        dias_trasp_int,
                    tasa_fija_o_var,        cod_tasa_base,         factor_sobretasa,     sobretasa,             tasa_interes,
                    cod_tasa_mora,          sobretasa_mora,        fact_sobret_mora,     tasa_moratorios,       tasa_preferencial,
                    sobretasa_preferencial, factor_preferencial,   valor_preferencial,   fecha_pago_cap,        fecha_pago_int,
                    es_fisica,              bandera_fi_fo,         actividad,            tipo_calculo,          num_aper_ant,
                    rev_tasa_var_per,       dia_para_revisar,      cod_prod,             bandera_ministra,      credito_externo,
                    califica_riesgo,        cod_agricola,          pagos_sostenidos,     campo_trab1,           campo_trab2,
                    campo_trab3,            campo_trab4, cuenta_clabe
               FROM bdicred: "informix".sd_maecredcrd
              WHERE num_credito = g_NumCredito
                AND empresa     = g_Empresa;
    
    ----------------------------------------------------------
    --    RESPALDO DE MAESDOSCRD                            --
    ----------------------------------------------------------
        INSERT INTO bdicred: "informix".sd_maesdosrevcrd
                    (empresa,                folio,                  num_credito,              fecha_ult_mov,
                     sdo_int_anticip,        sdo_int_ant_dev,        sdo_intereses,            sdo_dia_ant_int,
                     sdo_mes_ant_int,        sdo_acum_mes_int,       sdo_retenido,             sdo_acum_cap_int,
                     sdo_exig_int,           sdo_no_exig,            provision_normal,         dias_acum_int,
                     sdo_moratorio,          sdo_dia_ant_mor,        sdo_mes_ant_mor,          sdo_contab_mora,
                     dias_acum_mora,         sdo_capital,            sdo_cap_insoluto,         sdo_dia_ant_cap,
                     sdo_mes_ant_cap,        sdo_acum_mes_cap,       mto_capitalizado,         mto_ministra_cap,
                     cargos_dia_cap,         abonos_dia_cap,         cargos_mes_cap,           abonos_mes_cap,
                     dias_acum_cap,          monto_vencido,          mto_venc_trasp,           monto_financiado,
                     monto_reservado,        sdo_acum_vencido,       dias_acum_intper,         sdo_global_int,
                     sdo_acum_intper,        monto_otorgado,         provi_venc_normal,        provi_venc_anticip,
                     cap_tras_no_venci,      mto_venc_int,           mto_venc_tra_int,         mto_finan_vdo,
                     mto_reser_int,          mto_fin_ven_trasp,      mto_fin_vig_trasp,        int_tra_no_exig,
                     sdo_trab4,				 atr)
              SELECT
                     empresa,                g_Folio,                num_credito,              fecha_ult_mov,
                     sdo_int_anticip,        sdo_int_ant_dev,        sdo_intereses,            sdo_dia_ant_int,
                     sdo_mes_ant_int,        sdo_acum_mes_int,       sdo_retenido,             sdo_acum_cap_int,
                     sdo_exig_int,           sdo_no_exig,            provision_normal,         dias_acum_int,
                     sdo_moratorio,          sdo_dia_ant_mor,        sdo_mes_ant_mor,          sdo_contab_mora,
                     dias_acum_mora,         sdo_capital,            sdo_cap_insoluto,         sdo_dia_ant_cap,
                     sdo_mes_ant_cap,        sdo_acum_mes_cap,       mto_capitalizado,         mto_ministra_cap,
                     cargos_dia_cap,         abonos_dia_cap,         cargos_mes_cap,           abonos_mes_cap,
                     dias_acum_cap,          monto_vencido,          mto_venc_trasp,           monto_financiado,
                     monto_reservado,        sdo_acum_vencido,       dias_acum_intper,         sdo_global_int,
                     sdo_acum_intper,        monto_otorgado,         provi_venc_normal,        provi_venc_anticip,
                     cap_tras_no_venci,      mto_venc_int,           mto_venc_tra_int,         mto_finan_vdo,
                     mto_reser_int,          mto_fin_ven_trasp,      mto_fin_vig_trasp,        int_tra_no_exig,
                     sdo_trab4,				 atr
                FROM bdicred: "informix".sd_maesdoscrd
               WHERE empresa     = g_Empresa
                 AND num_credito = g_NumCredito;
    
    ----------------------------------------------------------
    --    RESPALDO DE AMORTIZA CREDITOCRD                   --
    ----------------------------------------------------------
         INSERT INTO bdicred: "informix".sd_amortiza_creditorevcrd 
                     (empresa,                folio,                  num_credito,             fecha_cuota,
                      tipo_cuota,             capital_mto_cuota,      capital_debe,            capital_pagado,
                      capital_status,         capital_status_ant,     capital_fecha_pago,      interes_debe,
                      interes_pagado,         interes_status,         interes_status_ant,      interes_fecha_pago,
                      iva_debe,               iva_pagado,             iva_status,              iva_status_ant,
                      iva_fecha_pago,         mora_provi_ordi,        mora_provi_cope,         mora_sdo_ordi,
                      mora_sdo_ordi_pag,      mora_sdo_cope,          mora_sdo_cope_pag,       mora_bonificado,
                      mora_status,            mora_iva_debe,          mora_iva_pagado,         mora_iva_status,
                      mora_iva_fecha_pago,    num_pago,               campo_trabajo1,          campo_trabajo2,
                      campo_trabajo3,         campo_trabajo4)
               SELECT
                      empresa,                g_Folio,                num_credito,             fecha_cuota,
                      tipo_cuota,             capital_mto_cuota,      capital_debe,            capital_pagado,
                      capital_status,         capital_status_ant,     capital_fecha_pago,      interes_debe,
                      interes_pagado,         interes_status,         interes_status_ant,      interes_fecha_pago,
                      iva_debe,               iva_pagado,             iva_status,              iva_status_ant,
                      iva_fecha_pago,         mora_provi_ordi,        mora_provi_cope,         mora_sdo_ordi,
                      mora_sdo_ordi_pag,      mora_sdo_cope,          mora_sdo_cope_pag,       mora_bonificado,
                      mora_status,            mora_iva_debe,          mora_iva_pagado,         mora_iva_status,
                      mora_iva_fecha_pago,    num_pago,               campo_trabajo1,          campo_trabajo2,
                      campo_trabajo3,         campo_trabajo4
                 FROM bdicred: "informix".sd_amortiza_creditocrd
                WHERE empresa     = g_empresa
                  AND num_credito = g_numcredito;
    
    -------------------------------------------------------
    --    RESPALDO DE MAECRED ANEXOCRD                   --
    -------------------------------------------------------
    
          INSERT INTO bdicred: "informix".sd_maecredanexorevcrd
                      (empresa,               folio,                    num_credito,              localidad,
                       dia_corte,             dias_gracia_mora,         tp_dias_calc_mora,        dias_fecha_max_pago,
                       tp_dias_fecha_pago,    cod_tasa_base_cte,        factor_sobretasa_cte,     sobretasa_cte,
                       tasa_interes_cte,      fecha_vencto,             prox_fecha_pago,          fecha_proceso, 
                       fecha_ult_pago,        nombre_pres)
               SELECT 
                       empresa,               g_Folio,                  num_credito,              localidad,
                       dia_corte,             dias_gracia_mora,         tp_dias_calc_mora,        dias_fecha_max_pago,
                       tp_dias_fecha_pago,    cod_tasa_base_cte,        factor_sobretasa_cte,     sobretasa_cte,
                       tasa_interes_cte,      fecha_vencto,             prox_fecha_pago,          fecha_proceso,
                       fecha_ult_pago,        nombre_pres
                 FROM bdicred: "informix".sd_maecredanexocrd
                WHERE empresa = g_Empresa
                  AND num_credito = g_NumCredito;
				  
	-------------------------------------------------------
    --         RESPALDO DE LINEA PRESTAMO               --
    -------------------------------------------------------
		IF (SELECT num_producto FROM bdicred: "informix".sd_maecredcrd WHERE empresa = g_Empresa AND num_credito = g_NumCredito) = '6800' THEN
		
			INSERT INTO "informix".sd_linea_prestamorev(empresa,folio,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
			disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior)
			SELECT empresa,g_Folio,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
			disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior
			FROM bdicred:"informix".sd_linea_prestamo
			WHERE empresa = g_Empresa
			AND num_credito = g_NumCredito;
		END IF;
    END IF;
----------------------------------------------------------
--    RESPALDO DE   PROMOCION CREDITO                    --
----------------------------------------------------------
	SELECT COUNT(num_sol_prestamo) INTO iContador FROM bdicred: "informix".sd_promocion_credito WHERE empresa = pempresa AND num_sol_prestamo = cNumCreditocrdsol AND num_pro_prestamo = '6900';
	--IF EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito WHERE empresa = pempresa AND num_sol_prestamo = cNumCreditocrdsol) THEN		
	IF iContador > 0 THEN

			SELECT  empresa, sistema, num_promo, fecha, ejecutivo, num_cte, num_credito, num_tarjeta, plazo, folio_suc, 
					monto_actual, monto_int_iva, mensualidad, status, nombre_promo, sucursal, num_sol_prestamo, 
					num_pro_prestamo, folio_movto, folio_suc_mov_crd
			INTO crevempresa, crevsistema, crevnum_promo, crevfecha, crevejecutivo, crevnum_cte, crevnum_credito, crevnum_tarjeta, crevplazo, crevfolio_suc, crevmonto_actual, crevmonto_int_iva, crevmensualidad, crevstatus, crevnombre_promo, crevsucursal, crevnum_sol_prestamo, crevnum_pro_prestamo, crevfolio_movto, cFolioSucMovCrd
			FROM bdicred: "informix".sd_promocion_credito
			WHERE empresa = pempresa
			AND num_sol_prestamo = cNumCreditocrdsol;
		
	END IF;	
	LET iContador = 0;
	IF crevnum_pro_prestamo = "6900" THEN
		-- Respaldo de la credisolucion -- DSB-TH- 07/02/2017 
		
		SELECT COUNT(num_sol_prestamo) INTO iContador FROM bdicred: "informix".sd_promocion_credito_rev WHERE num_sol_prestamo = cNumCreditocrdsol AND folio_suc_mov_crd = g_Folio;
		--IF NOT EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito_rev WHERE empresa = pempresa AND num_sol_prestamo = cNumCreditocrdsol AND folio_suc_mov_crd = g_Folio) THEN
		IF iContador = 0 THEN
			INSERT INTO bdicred: "informix".sd_promocion_credito_rev 
					(empresa,sistema,num_promo,fecha,ejecutivo,num_cte,num_credito,num_tarjeta,plazo,folio_suc,
					monto_actual,monto_int_iva,mensualidad,status,nombre_promo,sucursal,num_sol_prestamo,
					num_pro_prestamo, folio_movto, folio_suc_mov_crd)
			VALUES (crevempresa, crevsistema, crevnum_promo, crevfecha, crevejecutivo, crevnum_cte, crevnum_credito, crevnum_tarjeta, crevplazo, crevfolio_suc, crevmonto_actual, crevmonto_int_iva, crevmensualidad, crevstatus, crevnombre_promo, crevsucursal, crevnum_sol_prestamo, 
			crevnum_pro_prestamo, crevfolio_movto, g_Folio);
			
			LET scont = dbinfo("sqlca.sqlerrd2");
		--ELSE
			--UPDATE bdicred: "informix".sd_promocion_credito_rev
			--	SET empresa = crevempresa, sistema = crevsistema, num_promo = crevnum_promo, fecha = crevfecha, ejecutivo = crevejecutivo, num_cte = crevnum_cte, num_credito = crevnum_credito, num_tarjeta = crevnum_tarjeta, plazo = crevplazo, folio_suc = g_Folio, monto_actual = crevmonto_actual, monto_int_iva = crevmonto_int_iva, mensualidad = crevmensualidad, status = crevstatus, nombre_promo = crevnombre_promo, sucursal = crevsucursal, num_sol_prestamo = crevnum_sol_prestamo, num_pro_prestamo = crevnum_pro_prestamo, folio_movto = crevfolio_movto, folio_suc_mov_crd = g_Folio
		--	WHERE empresa = pempresa and num_sol_prestamo = cNumCreditocrdsol;

			--LET scont = dbinfo("sqlca.sqlerrd2");
		END IF;
		-- Fin Respaldo de la credisolucion -- DSB-TH- 07/02/2017
			
		----------------------------------------------------------
		--    RESPALDO DE   sd_maeretenido                  --
		----------------------------------------------------------
			SELECT folio_suc, num_credito, folio_movto
				INTO c_Folio_Suc, cNumCredito, cfolio_mov
			FROM bdicred: "informix".sd_promocion_credito 
			WHERE  empresa= pEmpresa
				and num_sol_prestamo = cNumCreditocrdsol;
			
			LET iContador = 0;
			SELECT COUNT(referencia) INTO iContador FROM bdicred: "informix".sd_maeretenido WHERE  empresa= '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R';
			--IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido 	WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R') THEN
			IF iContador > 0 THEN
				SELECT MAX (secuencia) 
					INTO iSecuencia
				FROM bdicred: "informix".sd_maeretenido_rev
				WHERE empresa = '001' 
					AND num_credito = cNumCredito
					AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
					AND nvl(substr(referencia,18,3),'') = 'PAG'
					AND estatus = 'R';
					
				IF iSecuencia IS NULL THEN
					
					lET iSecuencia = 1;
					
				ELSE
				
					lET iSecuencia= iSecuencia + 1;
					
				END IF;
	
				INSERT INTO bdicred: "informix".sd_maeretenido_rev 
					 (empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,secuencia)
				SELECT
					  empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,iSecuencia
				FROM bdicred: "informix".sd_maeretenido
				WHERE empresa = '001'
					 AND num_credito = cNumCredito
					 AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
					 AND nvl(substr(referencia,18,3),'') = 'PAG'
					 AND estatus = 'R';	

			END IF;
	
		SELECT substr(folio_movto,1,1)
			INTO cInFolMov
		FROM bdicred: "informix".sd_promocion_credito 
		WHERE  empresa= 001
			and num_sol_prestamo = cNumCreditocrdsol;
		
		
		IF (nvl(substr(cInFolMov,1,1),'') <> '0') AND (nvl(substr(cInFolMov,1,1),'') <> '1') AND (nvl(substr(cInFolMov,1,1),'') <> '2') AND (nvl(substr(cInFolMov,1,1),'') <> '3') AND (nvl(substr(cInFolMov,1,1),'') <> '4') AND (nvl(substr(cInFolMov,1,1),'') <> '5') AND (nvl(substr(cInFolMov,1,1),'') <> '6') AND (nvl(substr(cInFolMov,1,1),'') <> '7') AND (nvl(substr(cInFolMov,1,1),'') <> '8') AND (nvl(substr(cInFolMov,1,1),'') <> '9') THEN

			LET iContador = 0;
			SELECT count(referencia) INTO iContador FROM bdicred: "informix".sd_maeretenido WHERE  empresa= '001' AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
			--IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido 	WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			IF iContador > 0 THEN
				SELECT MAX (secuencia) 
					INTO iSecuencia
				FROM bdicred: "informix".sd_maeretenido_rev
				WHERE empresa = '001' 
					AND num_credito = cNumCredito
					AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
					AND nvl(substr(referencia,18,3),'') = 'RET'
					AND estatus = 'R';
					
				IF iSecuencia IS NULL THEN
					
					lET iSecuencia = 1;
					
				ELSE
				
					lET iSecuencia= iSecuencia + 1;
					
				END IF;
			
				INSERT INTO bdicred: "informix".sd_maeretenido_rev 
						 (empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,secuencia)
					SELECT
						  empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,iSecuencia
					FROM bdicred: "informix".sd_maeretenido
					WHERE empresa = '001'
						 AND num_credito = cNumCredito
						 AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
						 AND nvl(substr(referencia,18,3),'') = 'RET'
						 AND estatus = 'R';	
			
			END IF;
		ELSE
			LET iContador = 0;
			SELECT COUNT(referencia) INTO iContador FROM bdicred: "informix".sd_maeretenido WHERE  empresa= '001' AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
			--IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido 	WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			IF iContador > 0 THEN
				SELECT MAX (secuencia) 
					INTO iSecuencia
				FROM bdicred: "informix".sd_maeretenido_rev
				WHERE empresa = '001' 
					AND num_credito = cNumCredito
					AND nvl(substr(referencia,1,16),'') = cfolio_mov 
					AND nvl(substr(referencia,18,3),'') = 'RET'
					AND estatus = 'R';
					
				IF iSecuencia IS NULL THEN
					
					lET iSecuencia = 1;
					
				ELSE
				
					lET iSecuencia= iSecuencia + 1;
					
				END IF;
			
				INSERT INTO bdicred: "informix".sd_maeretenido_rev 
						 (empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,secuencia)
					SELECT empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori,iSecuencia
					FROM bdicred: "informix".sd_maeretenido
					WHERE empresa = '001'	
						 AND num_credito = cNumCredito
						 AND nvl(substr(referencia,1,16),'') = cfolio_mov
						 AND nvl(substr(referencia,18,3),'') = 'RET'
						 AND estatus = 'R';	
			END IF;		
		END IF;
		
		/*-- DSB - TH - 21/04/2017
		----------------------------------------------------------                      
		--            RESPALDO DE MAESDOS                                               
		----------------------------------------------------------                          
		IF NOT EXISTS (SELECT folio FROM bdicred: "informix".sd_maesdosrev WHERE empresa = g_Empresa AND num_credito = cnumcredito  AND folio = g_Folio) THEN            
		 INSERT INTO bdicred: "informix".sd_maesdosrev                           
				 (empresa, num_credito, folio, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int,
				 sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor,
				 sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap,
				 cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado,
				 sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int,
				 mto_venc_tra_int, mto_finan_vdo, mto_reser_int,  mto_fin_ven_trasp,  mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4)                                                            
		   SELECT                                                                       
				  empresa, num_credito, g_Folio, fecha_ult_mov, sdo_int_anticip, sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int, sdo_acum_mes_int,
				  sdo_retenido, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig, provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor, sdo_mes_ant_mor, 
				  sdo_contab_mora, dias_acum_mora, sdo_capital, sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap, mto_capitalizado, mto_ministra_cap,
				  cargos_dia_cap, abonos_dia_cap, cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido, mto_venc_trasp, monto_financiado, monto_reservado, 
				  sdo_acum_vencido, dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado, provi_venc_normal, provi_venc_anticip, cap_tras_no_venci, mto_venc_int,
				  mto_venc_tra_int, mto_finan_vdo, mto_reser_int, mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4                                                             
		   FROM bdicred: "informix".sd_maesdos                                                              
		   WHERE empresa     = g_Empresa                                                
		   AND num_credito = cnumcredito;                                              
		END IF;*/     
	END IF;
                                
   RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'Este SPL es un espejo del procedimiento respalda_credito; realiza el respaldo de las tablas de credito involucradas',
'En el pago para prestamo personal, para poder efectuar su reversion',
'AUTOR : JOSE LUIS PULIDO ZEPEDA',
'FECHA : 29/09/2009',
'BD    : BDICRED',
'Este Sp se agrego el apartado para respaldar la tabla sd_promocion_credito en sd_promocion_credito_rev',
'para obtener el registro cuado se requiera reversar',
'ACTUALIZA : Jesus Manuel Bustamante Lujano',
'FECHA : 23/11/1016',
'BD    : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : se agrega consulta de credito en sd_promocion_credito de credisoluciones para respaldar',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se actualiza para filtrar por folio_suc el Respaldo de la credisolucion,  se modifica para reversar PAGOS DIFERIDOS',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 08/003/2017 - 27/04/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se actualiza para realizar respaldo de la sd_maesdos a la sd_maesdosrev',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 21/04/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se moodifica para que respalde correctamente la tabla maerretenido, se modifica la validacion del campo cInFolMov ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 05/05/2017 - 10/05/2017',
'BD          : bdicred';

CREATE PROCEDURE "informix".respalda_creditocrd(eEmpresa    char(3),
                                             eNumCredito char(20),
                                             eUsuario    char(20))
   RETURNING CHAR(5);   --CodRet


   DEFINE CodRet              CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   DEFINE vFecHoy             DATE;
   DEFINE vanio               CHAR(4);
   DEFINE vano                CHAR(2);


   DEFINE wSecuenciaPago      LIKE sd_secpago.secuencia;

   DEFINE GLOBAL g_Empresa    CHAR(3)  DEFAULT ' ';
   DEFINE GLOBAL g_NumCredito CHAR(20) DEFAULT ' ';
   DEFINE GLOBAL g_Folio      CHAR(16) DEFAULT ' ';


--SET DEBUG FILE TO "/tmp/respalda_credito.out";
--TRACE ON;


   LET CodRet = "000";
   LET g_Empresa    = eEmpresa;
   LET g_NumCredito = eNumCredito;

   SELECT MAX(secuencia)
     INTO wSecuenciaPago
     FROM sd_secpago
    WHERE empresa = g_Empresa
      AND num_credito = g_NumCredito;

   SELECT fecha_hoy
      INTO vFecHoy
    FROM sd_fechas
    WHERE empresa = g_Empresa;
   IF(wSecuenciaPago = 0 OR wSecuenciaPago IS NULL) THEN
      LET wSecuenciaPago = 0;
   END IF;
 

   LET wSecuenciaPago = wSecuenciaPago + 1;
    IF g_Folio Is null tHEN 
    SELECT
     SUBSTR(USER,1,4)||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(current,3,2)||
     SUBSTR(CURRENT,12,2)||substr(current,15,2)
     ||SUBSTR(current,18,2)
     INTO g_Folio
    FROM dual;
   END IF;
   LET g_Folio = g_Folio;

   INSERT INTO
      sd_secpago (empresa, num_credito, folio_suc, secuencia) --,usuario_insert,fecha_insert)
   VALUES
      (g_empresa, g_NumCredito, g_Folio, wSecuenciaPago); --,eUsuario,vFecHoy);

------------------------------------------------------e
--    RESPALDO DE MAECRED                            --
-------------------------------------------------------
   INSERT INTO
      sd_maecredrevcrd
     ( empresa,      folio, num_credito,      num_producto,        ejecutivo,           numcte,
       aval_cte,            aval_linea,       divisa,              sucursal,            id_origen,
       origen,              cod_tipo_linea,   cod_linea,           status_cred,         bandera_renovac,
       bandera_prorroga,    periodo_plazo,    plazo,               fecha_apertura,      fecha_vencim,
       period_pago_cap,     period_pag_int,   dias_trasp_cap,      dias_trasp_int,      tasa_fija_o_var,
       cod_tasa_base,       factor_sobretasa, sobretasa,           tasa_interes,        cod_tasa_mora,
       sobretasa_mora,      fact_sobret_mora, tasa_moratorios,     tasa_preferencial,    sobretasa_preferencial,
       factor_preferencial, valor_preferencial,fecha_pago_cap,   fecha_pago_int,      es_fisica,           bandera_fi_fo,
       actividad,           tipo_calculo,     num_aper_ant,        rev_tasa_var_per,    dia_para_revisar,
       cod_prod,            bandera_ministra, credito_externo,     campo_trab1,         campo_trab2,
       campo_trab3,         campo_trab4,      califica_riesgo, cod_agricola,        pagos_sostenidos	, cuenta_clabe )


    SELECT empresa,   g_folio,  num_credito,	  num_producto,     ejecutivo,        numcte,
           aval_cte,            aval_linea,       divisa,           sucursal,         id_origen,
           origen,              cod_tipo_linea,   cod_linea,        status_cred,      bandera_renovac,
           bandera_prorroga,    periodo_plazo,    plazo,            fecha_apertura,   fecha_vencim,
           period_pago_cap,     period_pag_int,   dias_trasp_cap,   dias_trasp_int,   tasa_fija_o_var,
           cod_tasa_base,       factor_sobretasa, sobretasa,        tasa_interes,     cod_tasa_mora,
           sobretasa_mora,      fact_sobret_mora, tasa_moratorios,  tasa_preferencial, sobretasa_preferencial,
           factor_preferencial, valor_preferencial,fecha_pago_cap,   fecha_pago_int,   es_fisica,        bandera_fi_fo,
           actividad,           tipo_calculo,     num_aper_ant,     rev_tasa_var_per, dia_para_revisar,
           cod_prod,            bandera_ministra, credito_externo,  campo_trab1,      campo_trab2,
           campo_trab3,         campo_trab4,      califica_riesgo,  cod_agricola,     pagos_sostenidos  , cuenta_clabe
   FROM sd_maecredcrd
   WHERE num_credito = g_NumCredito
     AND empresa = g_Empresa;

----------------------------------------------------------
--            RESPALDO DE MAESDOS
----------------------------------------------------------
   INSERT INTO
      sd_maesdosrevcrd
         (empresa          , num_credito     , folio            , fecha_ult_mov     , sdo_int_anticip  ,
          sdo_int_ant_dev  , sdo_intereses   , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido     , sdo_acum_cap_int, sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int    , sdo_moratorio   , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora   , sdo_capital     , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap , mto_capitalizado, mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap   , abonos_mes_cap  , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado , monto_reservado , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper  , monto_otorgado  , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int     , mto_venc_tra_int, mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp, int_tra_no_exig , sdo_trab4)
   SELECT
         empresa          , num_credito     , g_folio           , fecha_ult_mov     , sdo_int_anticip  ,
          sdo_int_ant_dev  , sdo_intereses   , sdo_dia_ant_int  , sdo_mes_ant_int   , sdo_acum_mes_int ,
          sdo_retenido     , sdo_acum_cap_int, sdo_exig_int     , sdo_no_exig       , provision_normal ,
          dias_acum_int    , sdo_moratorio   , sdo_dia_ant_mor  , sdo_mes_ant_mor   , sdo_contab_mora  ,
          dias_acum_mora   , sdo_capital     , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
          sdo_acum_mes_cap , mto_capitalizado, mto_ministra_cap , cargos_dia_cap    , abonos_dia_cap   ,
          cargos_mes_cap   , abonos_mes_cap  , dias_acum_cap    , monto_vencido     , mto_venc_trasp   ,
          monto_financiado , monto_reservado , sdo_acum_vencido , dias_acum_intper  , sdo_global_int   ,
          sdo_acum_intper  , monto_otorgado  , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
          mto_venc_int     , mto_venc_tra_int, mto_finan_vdo    , mto_reser_int     , mto_fin_ven_trasp,
          mto_fin_vig_trasp, int_tra_no_exig , sdo_trab4
   FROM sd_maesdoscrd
   WHERE empresa     = g_Empresa
   AND num_credito = g_NumCredito;


----------------------------------------
-- Inicia Respaldo de sd_maecredanexocrd --
----------------------------------------

INSERT INTO sd_maecredanexorevcrd
        (empresa,              num_credito,         folio,
         dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
         dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
         factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
         fecha_vencto,         prox_fecha_pago,     fecha_proceso,
         fecha_ult_pago,   nombre_pres)
SELECT empresa,              num_credito,         g_Folio,
       dia_corte,            dias_gracia_mora,    tp_dias_calc_mora,
       dias_fecha_max_pago,  tp_dias_fecha_pago,  cod_tasa_base_cte,
       factor_sobretasa_cte, sobretasa_cte,       tasa_interes_cte,
       fecha_vencto,         prox_fecha_pago,     fecha_proceso,
       fecha_ult_pago , nombre_pres
  FROM sd_maecredanexocrd
 WHERE empresa = g_Empresa
   AND num_credito = g_NumCredito;


---------------------------------------------
--Inicia Respaldo de sd_amortiza_creditocrd --
---------------------------------------------
INSERT INTO sd_amortiza_creditorevcrd (
       empresa                , folio                  , num_credito            , fecha_cuota            ,
       tipo_cuota             , capital_mto_cuota      , capital_debe           , capital_pagado         ,
       capital_status         , capital_status_ant     , capital_fecha_pago     , interes_debe           ,
       interes_pagado         , interes_status         , interes_status_ant     , interes_fecha_pago     ,
       iva_debe               , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi        , mora_provi_cope        , mora_sdo_ordi          ,
       mora_sdo_ordi_pag      , mora_sdo_cope          , mora_sdo_cope_pag      , mora_bonificado        ,
       mora_status            , mora_iva_debe          , mora_iva_pagado        , mora_iva_status        ,
       mora_iva_fecha_pago    , num_pago               , campo_trabajo1         , campo_trabajo2         ,
       campo_trabajo3         , campo_trabajo4   )
SELECT
       empresa                , g_folio                , num_credito            , fecha_cuota            ,
       tipo_cuota             , capital_mto_cuota      , capital_debe           , capital_pagado         ,
       capital_status         , capital_status_ant     , capital_fecha_pago     , interes_debe           ,
       interes_pagado         , interes_status         , interes_status_ant     , interes_fecha_pago     ,
       iva_debe               , iva_pagado             , iva_status             , iva_status_ant         ,
       iva_fecha_pago         , mora_provi_ordi        , mora_provi_cope        , mora_sdo_ordi          ,
       mora_sdo_ordi_pag      , mora_sdo_cope          , mora_sdo_cope_pag      , mora_bonificado        ,
       mora_status            , mora_iva_debe          , mora_iva_pagado        , mora_iva_status        ,
       mora_iva_fecha_pago    , num_pago               , campo_trabajo1         , campo_trabajo2         ,
       campo_trabajo3         , campo_trabajo4
 FROM sd_amortiza_creditocrd
 WHERE empresa     = g_empresa
   and Num_credito = g_numcredito;
   
	IF (SELECT num_producto FROM bdicred: "informix".sd_maecredcrd WHERE empresa = g_Empresa AND num_credito = g_NumCredito) = '6800' THEN
		INSERT INTO "informix".sd_linea_prestamorev(empresa,folio,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
			disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior)
		SELECT empresa,g_Folio,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
			disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior
		FROM "informix".sd_linea_prestamo
		WHERE empresa = g_Empresa
		AND num_credito = g_NumCredito;
		
    END IF;
--------------------------------------
   RETURN CodRet;
END PROCEDURE
DOCUMENT
'Este SPL realiza el respaldo de las tablas de Credito involucradas',
'En el pago, para poder efectuar su reversion',
'AUTOR : Raul Mendoza D nes',
'FECHA : 20/Octubre/2003',
'BD    : BDICRED';

CREATE PROCEDURE "informix".reversioncrd_new(o_empresa   CHAR(3),
		  	              O_SUCursal  CHAR(4),
			              O_USUARIO   CHAR(8),
			              o_folio     CHAR(16),
			              o_tiporev   CHAR(1))
RETURNING CHAR(5);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE w_usuario        CHAR(8);
DEFINE v_maxsec         SMALLINT;
DEFINE vdia             DATE;
DEFINE vCodTipCred      CHAR(3);
DEFINE wBegin		CHAR(1);
DEFINE vMensaje         CHAR(80);
DEFINE vExiste			integer;

DEFINE c_Folio_Suc	    CHAR(16);
DEFINE iSecuencia       INTEGER;
DEFINE cNumCredito      CHAR(20);
DEFINE cfolio_mov       CHAR(16);

 DEFINE  mc_empresa                 LIKE sd_maecredcrd.empresa;
 DEFINE  mc_num_credito             LIKE sd_maecredcrd.num_credito;
 DEFINE  mc_num_producto            LIKE sd_maecredcrd.num_producto;
 DEFINE  mc_ejecutivo               LIKE sd_maecredcrd.ejecutivo;
 DEFINE  mc_numcte                  LIKE sd_maecredcrd.numcte;
 DEFINE  mc_aval_cte                LIKE sd_maecredcrd.aval_cte;
 DEFINE  mc_aval_linea              LIKE sd_maecredcrd.aval_linea;
 DEFINE  mc_divisa                  LIKE sd_maecredcrd.divisa;
 DEFINE  mc_sucursal                LIKE sd_maecredcrd.sucursal;
 DEFINE  mc_id_origen               LIKE sd_maecredcrd.id_origen;
 DEFINE  mc_origen                  LIKE sd_maecredcrd.origen;
 DEFINE  mc_cod_tipo_linea          LIKE sd_maecredcrd.cod_tipo_linea;
 DEFINE  mc_cod_linea               LIKE sd_maecredcrd.cod_linea;
 DEFINE  mc_status_cred             LIKE sd_maecredcrd.status_cred;
 DEFINE  mc_bandera_renovac         LIKE sd_maecredcrd.bandera_renovac;
 DEFINE  mc_bandera_prorroga        LIKE sd_maecredcrd.bandera_prorroga;
 DEFINE  mc_periodo_plazo           LIKE sd_maecredcrd.periodo_plazo;
 DEFINE  mc_plazo                   LIKE sd_maecredcrd.plazo;
 DEFINE  mc_fecha_apertura          LIKE sd_maecredcrd.fecha_apertura;
 DEFINE  mc_fecha_vencim            LIKE sd_maecredcrd.fecha_vencim;
 DEFINE  mc_period_pago_cap         LIKE sd_maecredcrd.period_pago_cap;
 DEFINE  mc_period_pag_int          LIKE sd_maecredcrd.period_pag_int;
 DEFINE  mc_dias_trasp_cap          LIKE sd_maecredcrd.dias_trasp_cap;
 DEFINE  mc_dias_trasp_int          LIKE sd_maecredcrd.dias_trasp_int;
 DEFINE  mc_tasa_fija_o_var         LIKE sd_maecredcrd.tasa_fija_o_var;
 DEFINE  mc_cod_tasa_base           LIKE sd_maecredcrd.cod_tasa_base;
 DEFINE  mc_factor_sobretasa        LIKE sd_maecredcrd.factor_sobretasa;
 DEFINE  mc_sobretasa               LIKE sd_maecredcrd.sobretasa;
 DEFINE  mc_tasa_interes            LIKE sd_maecredcrd.tasa_interes;
 DEFINE  mc_cod_tasa_mora           LIKE sd_maecredcrd.cod_tasa_mora;
 DEFINE  mc_sobretasa_mora          LIKE sd_maecredcrd.sobretasa_mora;
 DEFINE  mc_fact_sobret_mora        LIKE sd_maecredcrd.fact_sobret_mora;
 DEFINE  mc_tasa_moratorios         LIKE sd_maecredcrd.tasa_moratorios;
 DEFINE  mc_tasa_preferencia        LIKE sd_maecredcrd.tasa_preferencial;
 DEFINE  mc_sobretasa_preferencial  LIKE sd_maecredcrd.sobretasa_preferencial;
 DEFINE  mc_factor_preferencial     LIKE sd_maecredcrd.factor_preferencial;
 DEFINE  mc_valor_preferencial      LIKE sd_maecredcrd.valor_preferencial;
 DEFINE  mc_fecha_pago_cap          LIKE sd_maecredcrd.fecha_pago_cap;
 DEFINE  mc_fecha_pago_int          LIKE sd_maecredcrd.fecha_pago_int;
 DEFINE  mc_es_fisica               LIKE sd_maecredcrd.es_fisica;
 DEFINE  mc_bandera_fi_fo           LIKE sd_maecredcrd.bandera_fi_fo;
 DEFINE  mc_actividad               LIKE sd_maecredcrd.actividad;
 DEFINE  mc_tipo_calculo            LIKE sd_maecredcrd.tipo_calculo;
 DEFINE  mc_num_aper_ant            LIKE sd_maecredcrd.num_aper_ant;
 DEFINE  mc_rev_tasa_var_per        LIKE sd_maecredcrd.rev_tasa_var_per;
 DEFINE  mc_dia_para_revisar        LIKE sd_maecredcrd.dia_para_revisar;
 DEFINE  mc_cod_prod                LIKE sd_maecredcrd.cod_prod;
 DEFINE  mc_bandera_ministra        LIKE sd_maecredcrd.bandera_ministra;
 DEFINE  mc_credito_externo         LIKE sd_maecredcrd.credito_externo;
 DEFINE  mc_califica_riesgo         LIKE sd_maecredcrd.califica_riesgo;
 DEFINE  mc_cod_agricola            LIKE sd_maecredcrd.cod_agricola;
 DEFINE  mc_pagos_sostenidos        LIKE sd_maecredcrd.pagos_sostenidos;
 DEFINE  mc_campo_trab1             LIKE sd_maecredcrd.campo_trab1;
 DEFINE  mc_campo_trab2             LIKE sd_maecredcrd.campo_trab2;
 DEFINE  mc_campo_trab3             LIKE sd_maecredcrd.campo_trab3;
 DEFINE  mc_campo_trab4             LIKE sd_maecredcrd.campo_trab4;
 DEFINE  mc_cuenta_clabe			LIKE sd_maecredcrd.cuenta_clabe;


DEFINE ms_empresa             LIKE sd_maesdoscrd.empresa;
DEFINE ms_num_credito         LIKE sd_maesdoscrd.num_credito;
DEFINE ms_fecha_ult_mov       LIKE sd_maesdoscrd.fecha_ult_mov;
DEFINE ms_sdo_int_anticip     LIKE sd_maesdoscrd.sdo_int_anticip;
DEFINE ms_sdo_int_ant_dev     LIKE sd_maesdoscrd.sdo_int_ant_dev;
DEFINE ms_sdo_intereses       LIKE sd_maesdoscrd.sdo_intereses;
DEFINE ms_sdo_dia_ant_int     LIKE sd_maesdoscrd.sdo_dia_ant_int;
DEFINE ms_sdo_mes_ant_int     LIKE sd_maesdoscrd.sdo_mes_ant_int;
DEFINE ms_sdo_acum_mes_int    LIKE sd_maesdoscrd.sdo_acum_mes_int;
DEFINE ms_sdo_retenido        LIKE sd_maesdoscrd.sdo_retenido;
DEFINE ms_sdo_acum_cap_int    LIKE sd_maesdoscrd.sdo_acum_cap_int;
DEFINE ms_sdo_exig_int        LIKE sd_maesdoscrd.sdo_exig_int;
DEFINE ms_sdo_no_exig         LIKE sd_maesdoscrd.sdo_no_exig;
DEFINE ms_provision_normal    LIKE sd_maesdoscrd.provision_normal;
DEFINE ms_dias_acum_int       LIKE sd_maesdoscrd.dias_acum_int;
DEFINE ms_sdo_moratorio       LIKE sd_maesdoscrd.sdo_moratorio;
DEFINE ms_sdo_dia_ant_mor     LIKE sd_maesdoscrd.sdo_dia_ant_mor;
DEFINE ms_sdo_mes_ant_mor     LIKE sd_maesdoscrd.sdo_mes_ant_mor;
DEFINE ms_sdo_contab_mora     LIKE sd_maesdoscrd.sdo_contab_mora;
DEFINE ms_dias_acum_mora      LIKE sd_maesdoscrd.dias_acum_mora;
DEFINE ms_sdo_capital         LIKE sd_maesdoscrd.sdo_capital;
DEFINE ms_sdo_cap_insoluto    LIKE sd_maesdoscrd.sdo_cap_insoluto;
DEFINE ms_sdo_dia_ant_cap     LIKE sd_maesdoscrd.sdo_dia_ant_cap;
DEFINE ms_sdo_mes_ant_cap     LIKE sd_maesdoscrd.sdo_mes_ant_cap;
DEFINE ms_sdo_acum_mes_cap    LIKE sd_maesdoscrd.sdo_acum_mes_cap;
DEFINE ms_mto_capitalizado    LIKE sd_maesdoscrd.mto_capitalizado;
DEFINE ms_mto_ministra_cap    LIKE sd_maesdoscrd.mto_ministra_cap;
DEFINE ms_cargos_dia_cap      LIKE sd_maesdoscrd.cargos_dia_cap;
DEFINE ms_abonos_dia_cap      LIKE sd_maesdoscrd.abonos_dia_cap;
DEFINE ms_cargos_mes_cap      LIKE sd_maesdoscrd.cargos_mes_cap;
DEFINE ms_abonos_mes_cap      LIKE sd_maesdoscrd.abonos_mes_cap;
DEFINE ms_dias_acum_cap       LIKE sd_maesdoscrd.dias_acum_cap;
DEFINE ms_monto_vencido       LIKE sd_maesdoscrd.monto_vencido;
DEFINE ms_mto_venc_trasp      LIKE sd_maesdoscrd.mto_venc_trasp;
DEFINE ms_monto_financiado    LIKE sd_maesdoscrd.monto_financiado;
DEFINE ms_monto_reservado     LIKE sd_maesdoscrd.monto_reservado;
DEFINE ms_sdo_acum_vencido    LIKE sd_maesdoscrd.sdo_acum_vencido;
DEFINE ms_dias_acum_intper    LIKE sd_maesdoscrd.dias_acum_intper;
DEFINE ms_sdo_global_int      LIKE sd_maesdoscrd.sdo_global_int;
DEFINE ms_sdo_acum_intper     LIKE sd_maesdoscrd.sdo_acum_intper;
DEFINE ms_monto_otorgado      LIKE sd_maesdoscrd.monto_otorgado;
DEFINE ms_provi_venc_normal   LIKE sd_maesdoscrd.provi_venc_normal;
DEFINE ms_provi_venc_anticip  LIKE sd_maesdoscrd.provi_venc_anticip;
DEFINE ms_cap_tras_no_venci   LIKE sd_maesdoscrd.cap_tras_no_venci;
DEFINE ms_mto_venc_int        LIKE sd_maesdoscrd.mto_venc_int;
DEFINE ms_mto_venc_tra_int    LIKE sd_maesdoscrd.mto_venc_tra_int;
DEFINE ms_mto_finan_vdo       LIKE sd_maesdoscrd.mto_finan_vdo;
DEFINE ms_mto_reser_int       LIKE sd_maesdoscrd.mto_reser_int;
DEFINE ms_mto_fin_ven_trasp   LIKE sd_maesdoscrd.mto_fin_ven_trasp;
DEFINE ms_mto_fin_vig_trasp   LIKE sd_maesdoscrd.mto_fin_vig_trasp;
DEFINE ms_int_tra_no_exig     LIKE sd_maesdoscrd.int_tra_no_exig;
DEFINE ms_sdo_trab4           LIKE sd_maesdoscrd.sdo_trab4;
DEFINE ms_atr                 LIKE sd_maesdoscrd.atr;

DEFINE dc_empresa             LIKE sd_detcomi.empresa;
DEFINE dc_cod_comis           LIKE sd_detcomi.cod_comis;
DEFINE dc_num_credito         LIKE sd_detcomi.num_credito;
DEFINE dc_fecha_alta          LIKE sd_detcomi.fecha_alta;
DEFINE dc_fecha_pago          LIKE sd_detcomi.fecha_pago;
DEFINE dc_monto_com           LIKE sd_detcomi.monto_com;
DEFINE dc_monto_pag           LIKE sd_detcomi.monto_pag;
DEFINE dc_apli_factor         LIKE sd_detcomi.apli_factor;
DEFINE dc_estado_com          LIKE sd_detcomi.estado_com;
DEFINE dc_num_solicitud       LIKE sd_detcomi.num_solicitud;
DEFINE dc_user_insert         LIKE sd_detcomi.user_insert;
DEFINE dc_fecha_insert        LIKE sd_detcomi.fecha_insert;

DEFINE mx_empresa              LIKE sd_maecredanexocrd.empresa;
DEFINE mx_num_credito          LIKE sd_maecredanexocrd.num_credito;
DEFINE mx_dia_corte            LIKE sd_maecredanexocrd.dia_corte;
DEFINE mx_dias_gracia_mora     LIKE sd_maecredanexocrd.dias_gracia_mora;
DEFINE mx_tp_dias_calc_mora    LIKE sd_maecredanexocrd.tp_dias_calc_mora;
DEFINE mx_dias_fecha_max_pago  LIKE sd_maecredanexocrd.dias_fecha_max_pago;
DEFINE mx_tp_dias_fecha_pago   LIKE sd_maecredanexocrd.tp_dias_fecha_pago;
DEFINE mx_cod_tasa_base_cte    LIKE sd_maecredanexocrd.cod_tasa_base_cte;
DEFINE mx_factor_sobretasa_cte LIKE sd_maecredanexocrd.factor_sobretasa_cte;
DEFINE mx_sobretasa_cte        LIKE sd_maecredanexocrd.sobretasa_cte;
DEFINE mx_tasa_interes_cte     LIKE sd_maecredanexocrd.tasa_interes_cte;
DEFINE mx_fecha_vencto         LIKE sd_maecredanexocrd.fecha_vencto;
DEFINE mx_prox_fecha_pago      LIKE sd_maecredanexocrd.prox_fecha_pago;
DEFINE mx_fecha_proceso        LIKE sd_maecredanexocrd.fecha_proceso;
DEFINE mx_fecha_ult_pago       LIKE sd_maecredanexocrd.fecha_ult_pago;
define mx_localidad            LIKE sd_maecredanexocrd.localidad;
DEFINE mx_nombre_pres          LIKE sd_maecredanexocrd.nombre_pres;
DEFINE mx_cat		          LIKE sd_maecredanexocrd.cat;


DEFINE am_empresa              LIKE sd_amortiza_creditocrd.empresa;
DEFINE am_num_credito          LIKE sd_amortiza_creditocrd.num_credito;
DEFINE am_fecha_cuota          LIKE sd_amortiza_creditocrd.fecha_cuota;
DEFINE am_tipo_cuota           LIKE sd_amortiza_creditocrd.tipo_cuota;
DEFINE am_capital_mto_cuota    LIKE sd_amortiza_creditocrd.capital_mto_cuota;
DEFINE am_capital_debe         LIKE sd_amortiza_creditocrd.capital_debe;
DEFINE am_capital_pagado       LIKE sd_amortiza_creditocrd.capital_pagado;
DEFINE am_capital_status       LIKE sd_amortiza_creditocrd.capital_status;
DEFINE am_capital_status_ant   LIKE sd_amortiza_creditocrd.capital_status_ant;
DEFINE am_capital_fecha_pago   LIKE sd_amortiza_creditocrd.capital_fecha_pago;
DEFINE am_interes_debe         LIKE sd_amortiza_creditocrd.interes_debe;
DEFINE am_interes_pagado       LIKE sd_amortiza_creditocrd.interes_pagado;
DEFINE am_interes_status       LIKE sd_amortiza_creditocrd.interes_status;
DEFINE am_interes_status_ant   LIKE sd_amortiza_creditocrd.interes_status_ant;
DEFINE am_interes_fecha_pago   LIKE sd_amortiza_creditocrd.interes_fecha_pago;
DEFINE am_iva_debe             LIKE sd_amortiza_creditocrd.iva_debe;
DEFINE am_iva_pagado           LIKE sd_amortiza_creditocrd.iva_pagado;
DEFINE am_iva_status           LIKE sd_amortiza_creditocrd.iva_status;
DEFINE am_iva_status_ant       LIKE sd_amortiza_creditocrd.iva_status_ant;
DEFINE am_iva_fecha_pago       LIKE sd_amortiza_creditocrd.iva_fecha_pago;
DEFINE am_mora_provi_ordi      LIKE sd_amortiza_creditocrd.mora_provi_ordi;
DEFINE am_mora_provi_cope      LIKE sd_amortiza_creditocrd.mora_provi_cope;
DEFINE am_mora_sdo_ordi        LIKE sd_amortiza_creditocrd.mora_sdo_ordi;
DEFINE am_mora_sdo_ordi_pag    LIKE sd_amortiza_creditocrd.mora_sdo_ordi_pag;  --FMV: 17-MAY-10
DEFINE am_mora_sdo_cope        LIKE sd_amortiza_creditocrd.mora_sdo_cope;
DEFINE am_mora_sdo_cope_pag    LIKE sd_amortiza_creditocrd.mora_sdo_cope_pag;
DEFINE am_mora_bonificado      LIKE sd_amortiza_creditocrd.mora_bonificado;
DEFINE am_mora_status          LIKE sd_amortiza_creditocrd.mora_status;
DEFINE am_mora_iva_debe        LIKE sd_amortiza_creditocrd.mora_iva_debe;
DEFINE am_mora_iva_pagado      LIKE sd_amortiza_creditocrd.mora_iva_pagado;
DEFINE am_mora_iva_status      LIKE sd_amortiza_creditocrd.mora_iva_status;
DEFINE am_mora_iva_fecha_pago  LIKE sd_amortiza_creditocrd.mora_iva_fecha_pago;
DEFINE am_num_pago             LIKE sd_amortiza_creditocrd.num_pago;
DEFINE am_campo_trabajo1       LIKE sd_amortiza_creditocrd.campo_trabajo1;
DEFINE am_campo_trabajo2       LIKE sd_amortiza_creditocrd.campo_trabajo2;
DEFINE am_campo_trabajo3       LIKE sd_amortiza_creditocrd.campo_trabajo3;
DEFINE am_campo_trabajo4       LIKE sd_amortiza_creditocrd.campo_trabajo4;

DEFINE sp_empresa              LIKE sd_secpago.empresa;
DEFINE sp_num_credito          LIKE sd_secpago.num_credito;
DEFINE sp_folio_suc            LIKE sd_secpago.folio_suc;
DEFINE sp_secuencia            LIKE sd_secpago.secuencia;

DEFINE lp_empresa                  LIKE sd_linea_prestamo.empresa;
DEFINE lp_num_credito              LIKE sd_linea_prestamo.num_credito;
DEFINE lp_monto_linea              LIKE sd_linea_prestamo.monto_linea;
DEFINE lp_fecha_otorga             LIKE sd_linea_prestamo.fecha_otorga;
DEFINE lp_linea_disponible         LIKE sd_linea_prestamo.linea_disponible;
DEFINE lp_sec_credito              LIKE sd_linea_prestamo.sec_credito;
DEFINE lp_fecha_cancela            LIKE sd_linea_prestamo.fecha_cancela;
DEFINE lp_fecha_ult_mod            LIKE sd_linea_prestamo.fecha_ult_mod;
DEFINE lp_disposicion_activada     LIKE sd_linea_prestamo.disposicion_activada;
DEFINE lp_fecha_ult_pf             LIKE sd_linea_prestamo.fecha_ult_pf;
DEFINE lp_cancel_pf                LIKE sd_linea_prestamo.cancel_pf;
DEFINE lp_fecha_venc_linea         LIKE sd_linea_prestamo.fecha_venc_linea;
DEFINE lp_acepto_incremento        LIKE sd_linea_prestamo.acepto_incremento;
DEFINE lp_linea_prestamo_anterior  LIKE sd_linea_prestamo.linea_prestamo_anterior;

DEFINE de_empresa              CHAR(3)  ;
DEFINE de_num_credito          CHAR(20) ;
DEFINE vempresa                CHAR(3);
DEFINE vsucursal               CHAR(4);
DEFINE vnum_credito            CHAR(20);
DEFINE vdivisa                 CHAR(3);
DEFINE vtrannro                CHAR(4);
DEFINE vBan                    CHAR(2);
DEFINE de_plazo                VARCHAR(5,1);
DEFINE de_texto                VARCHAR(200,0);
DEFINE de_fecha_venc_seg       DATE     ;
DEFINE de_cod_comis            CHAR(4)  ;
DEFINE de_monto_poliza         MONEY(14,2);
DEFINE vmonto                  MONEY(14,2);
DEFINE cFolioMovto			   CHAR(20);
DEFINE de_monto_mensual        MONEY(14,2);
DEFINE de_saldo                DECIMAL(18,2);
DEFINE vmonto_linea            DECIMAL(18,2);
DEFINE cNumCreditoPromo        CHAR(16);
DEFINE cInFolMov			CHAR(1);
define iAmortiza_count 	       INTEGER;
-- ***************************************************************************
-- *                     ASIGNACION DE VALORES A VARIABLES                   *
-- ***************************************************************************
LET v_codret  = "000";
LET wBegin    = "N";
LET sql_err   = 0;
LET w_usuario = USER;
LET v_maxsec  = 0;
LET vdia      = "";
LET vBan      = "";
LET vmonto_linea = 0;
LET vMensaje    = "";
LET vExiste = 0;

LET cFolioMovto      = "";
LET cNumCreditoPromo = "";
LET c_Folio_Suc      = '';
LET iSecuencia       = 0;
LET cNumCredito      = '';
LET cfolio_mov       = "";
LET cInFolMov			= "";
let iAmortiza_count =  0;
-- ***************************************************************************


BEGIN
	ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
		LET v_codret = sql_err;
		IF wBegin = "S" THEN
			ROLLBACK WORK;
			BEGIN WORK;
		END IF
		RETURN v_codret;
	END IF
END EXCEPTION;

ON EXCEPTION IN (-535)
	LET wBegin = "S";
	--ROLLBACK WORK;
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

-- set debug file to "/home/c90271846/CANCELACION_DIGITALES/DEBUG/reversioncrd.out";
-- trace on;
  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
  

LET wBegin = "N";
	
	-- Se valida que el movimiento no este reversado para poder continuar
	select  UNIQUE 1 into vExiste
	FROM "informix".sd_movdiacrd a, "informix".sd_definicion b
	WHERE a.empresa = o_empresa
	AND a.sucursal = o_sucursal
	AND a.reversado = 'S'
	AND a.folio_suc = o_folio
	AND b.empresa = a.empresa
	AND b.num_producto = a.num_producto;

	IF vExiste = 1 THEN
		RETURN v_codret;
	END IF;

--        LET sp_num_credito = O_NumCred;
--        LET sp_secuencia = o_secuencia;
	LET o_folio = TRIM(o_folio);

	SELECT limit 1 num_credito 
	INTO sp_num_credito
	FROM "informix".sd_movdiacrd
	WHERE folio_suc = o_folio ;
	
	-- DSB TH 07/02/2017		
	SELECT num_credito, folio_suc, secuencia
	INTO sp_num_credito, sp_folio_suc, sp_secuencia
	FROM "informix".sd_secpago
	WHERE folio_suc = o_folio and num_credito = sp_num_credito;

	SELECT MAX(secuencia) INTO v_maxsec FROM "informix".sd_secpago
	WHERE num_credito = sp_num_credito ;
	
	IF v_maxsec <> sp_secuencia THEN
		LET v_codret = "431"; -- PAGO NO ES EL ULTIMO REVERSA EN ORDEN
		COMMIT WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
	    RETURN v_codret;
	END IF;

	--** Existe folio en Respaldo de Maecred  **--
	If NOT exists (Select folio from "informix".sd_maecredrevcrd where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

	--**Existe folio en Respaldo de Maedosrev **--
	If NOT exists ( Select folio from "informix".sd_maesdosrevcrd  where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

	--** Existe folio en Respaldo de Maecredanexorev **--
	If NOT exists  (Select folio from "informix".sd_maecredanexorevcrd  where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

	--** Existe folio en Respaldo de Amortiza_Credito **--
	If NOT exists (Select folio from "informix".sd_amortiza_creditorevcrd  where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

BEGIN WORK;
	--Se manda llamar el proceso de reverso de captacion
	
	EXECUTE PROCEDURE bdicheq:"informix".reversion(o_empresa, O_SUCursal, O_USUARIO, o_folio, o_tiporev) INTO v_codret;
	IF v_codret <> '000' THEN
		RETURN v_codret;
	END IF;
	--fin del bloque
	
	SELECT cat
	INTO mx_cat
	FROM "informix".sd_maecredanexocrd   
	WHERE num_credito = sp_num_credito;
		
	SET CONSTRAINTS ALL DEFERRED;

	DELETE FROM "informix".sd_maesdoscrd          WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_maecredanexocrd     WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_amortiza_creditocrd WHERE num_credito = sp_num_credito;
    DELETE FROM "informix".sd_maecredcrd          WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_linea_prestamo      WHERE num_credito = sp_num_credito;
	
	--EM 28/03/2017
	IF o_tiporev = 'M' THEN
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND a.status = 6
		AND b.folio_suc = o_folio;

		IF  cNumCreditoPromo != "" OR cNumCreditoPromo IS NOT NULL THEN	
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 2 WHERE  num_sol_prestamo = cNumCreditoPromo;
		END IF;
		
	ELSE				
		--EM
		SELECT folio_movto
		INTO cFolioMovto
		FROM bdicred:"informix".sd_promocion_credito_rev  
		WHERE folio_suc_mov_crd = o_folio;
			
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND a.status = 6
		AND b.folio_suc = o_folio
		AND a.folio_movto = cFolioMovto;

		IF  cNumCreditoPromo != "" OR cNumCreditoPromo IS NOT NULL THEN	
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 2 WHERE  num_sol_prestamo = cNumCreditoPromo;
		END IF;
		
	END IF;
	
    -- RECUPERA MAECRED
	SELECT
	empresa,             num_credito,	    num_producto,    ejecutivo,           numcte,
	aval_cte,            aval_linea,       divisa,          sucursal,            id_origen,
	origen,              cod_tipo_linea,   cod_linea,       status_cred,         bandera_renovac,
	bandera_prorroga,    periodo_plazo,    plazo,           fecha_apertura,      fecha_vencim,
	period_pago_cap,     period_pag_int,   dias_trasp_cap,  dias_trasp_int,      tasa_fija_o_var,
	cod_tasa_base,       factor_sobretasa, sobretasa,       tasa_interes,        cod_tasa_mora,
	sobretasa_mora,      fact_sobret_mora, tasa_moratorios, tasa_preferencial,    sobretasa_preferencial,
	factor_preferencial, valor_preferencial,fecha_pago_cap,   fecha_pago_int,  es_fisica,           bandera_fi_fo,
	actividad,           tipo_calculo,     num_aper_ant,    rev_tasa_var_per,    dia_para_revisar,
	cod_prod,            bandera_ministra, credito_externo, califica_riesgo, cod_agricola,
	pagos_sostenidos,    campo_trab1,      campo_trab2,     campo_trab3,         campo_trab4
	,cuenta_clabe
    INTO  mc_empresa,             mc_num_credito,      mc_num_producto,    mc_ejecutivo,           mc_numcte,
	mc_aval_cte,            mc_aval_linea,       mc_divisa,          mc_sucursal,            mc_id_origen,
	mc_origen,              mc_cod_tipo_linea,   mc_cod_linea,       mc_status_cred,         mc_bandera_renovac,
	mc_bandera_prorroga,    mc_periodo_plazo,    mc_plazo,           mc_fecha_apertura,      mc_fecha_vencim,
	mc_period_pago_cap,     mc_period_pag_int,   mc_dias_trasp_cap,  mc_dias_trasp_int,      mc_tasa_fija_o_var,
	mc_cod_tasa_base,       mc_factor_sobretasa, mc_sobretasa,       mc_tasa_interes,        mc_cod_tasa_mora,                              mc_sobretasa_mora,      mc_fact_sobret_mora, mc_tasa_moratorios, mc_tasa_preferencia,    mc_sobretasa_preferencial,
	mc_factor_preferencial, mc_valor_preferencial,mc_fecha_pago_cap,   mc_fecha_pago_int,  mc_es_fisica,           mc_bandera_fi_fo,
	mc_actividad,           mc_tipo_calculo,     mc_num_aper_ant,    mc_rev_tasa_var_per,    mc_dia_para_revisar,
	mc_cod_prod,            mc_bandera_ministra, mc_credito_externo, mc_califica_riesgo,     mc_cod_agricola,
	mc_pagos_sostenidos,    mc_campo_trab1,      mc_campo_trab2,     mc_campo_trab3,         mc_campo_trab4          ,mc_cuenta_clabe           FROM "informix".sd_maecredrevcrd                                                                                                                      WHERE folio = o_folio;

    INSERT INTO sd_maecredcrd
          VALUES( mc_empresa,             mc_num_credito,      mc_num_producto,    mc_ejecutivo,           mc_numcte,
                  mc_aval_cte,            mc_aval_linea,       mc_divisa,          mc_sucursal,            mc_id_origen,
                  mc_origen,              mc_cod_tipo_linea,   mc_cod_linea,       mc_status_cred,         mc_bandera_renovac,
                  mc_bandera_prorroga,    mc_periodo_plazo,    mc_plazo,           mc_fecha_apertura,      mc_fecha_vencim,
                  mc_period_pago_cap,     mc_period_pag_int,   mc_dias_trasp_cap,  mc_dias_trasp_int,      mc_tasa_fija_o_var,
                  mc_cod_tasa_base,       mc_factor_sobretasa, mc_sobretasa,       mc_tasa_interes,        mc_cod_tasa_mora,
                  mc_sobretasa_mora,      mc_fact_sobret_mora, mc_tasa_moratorios, mc_tasa_preferencia,    mc_sobretasa_preferencial,
                  mc_factor_preferencial, mc_valor_preferencial,mc_fecha_pago_cap,   mc_fecha_pago_int,  mc_es_fisica,           mc_bandera_fi_fo,
                  mc_actividad,           mc_tipo_calculo,     mc_num_aper_ant,    mc_rev_tasa_var_per,    mc_dia_para_revisar,
                  mc_cod_prod,            mc_bandera_ministra, mc_credito_externo, mc_califica_riesgo,     mc_cod_agricola,
                  mc_pagos_sostenidos,    mc_campo_trab1,      mc_campo_trab2,     mc_campo_trab3,         mc_campo_trab4	,mc_cuenta_clabe);




	--** Existe numero credito de maecredcrd  **--
	IF NOT EXISTS (Select num_credito from "informix".sd_maecredcrd where num_credito = mc_num_credito) Then
		LET v_codret = '001';
		Return v_codret;
	End IF;


   -- RECUPERA MAESDOS
	SELECT empresa          , num_credito      , fecha_ult_mov     , sdo_int_anticip  ,
	sdo_int_ant_dev  , sdo_intereses    , sdo_dia_ant_int   , sdo_mes_ant_int  ,
	sdo_acum_mes_int , sdo_retenido     , sdo_acum_cap_int  , sdo_exig_int     ,
	sdo_no_exig      , provision_normal , dias_acum_int     , sdo_moratorio    ,
	sdo_dia_ant_mor  , sdo_mes_ant_mor  , sdo_contab_mora   , dias_acum_mora   ,
	sdo_capital      , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
	sdo_acum_mes_cap , mto_capitalizado , mto_ministra_cap  , cargos_dia_cap   ,
	abonos_dia_cap   , cargos_mes_cap   , abonos_mes_cap    , dias_acum_cap    ,
	monto_vencido    , mto_venc_trasp   , monto_financiado  , monto_reservado  ,
	sdo_acum_vencido , dias_acum_intper , sdo_global_int    , sdo_acum_intper  ,
	monto_otorgado   , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
	mto_venc_int     , mto_venc_tra_int , mto_finan_vdo     , mto_reser_int    ,
	mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig   , sdo_trab4        , atr

	INTO ms_empresa          , ms_num_credito      , ms_fecha_ult_mov     , ms_sdo_int_anticip   ,
	ms_sdo_int_ant_dev  , ms_sdo_intereses    , ms_sdo_dia_ant_int   , ms_sdo_mes_ant_int   ,
	ms_sdo_acum_mes_int , ms_sdo_retenido     , ms_sdo_acum_cap_int  , ms_sdo_exig_int      ,
	ms_sdo_no_exig      , ms_provision_normal , ms_dias_acum_int     , ms_sdo_moratorio     ,
	ms_sdo_dia_ant_mor  , ms_sdo_mes_ant_mor  , ms_sdo_contab_mora   , ms_dias_acum_mora    ,
	ms_sdo_capital      , ms_sdo_cap_insoluto , ms_sdo_dia_ant_cap   , ms_sdo_mes_ant_cap   ,
	ms_sdo_acum_mes_cap , ms_mto_capitalizado , ms_mto_ministra_cap  , ms_cargos_dia_cap    ,
	ms_abonos_dia_cap   , ms_cargos_mes_cap   , ms_abonos_mes_cap    , ms_dias_acum_cap     ,
	ms_monto_vencido    , ms_mto_venc_trasp   , ms_monto_financiado  , ms_monto_reservado   ,
	ms_sdo_acum_vencido , ms_dias_acum_intper , ms_sdo_global_int    , ms_sdo_acum_intper   ,
	ms_monto_otorgado   , ms_provi_venc_normal, ms_provi_venc_anticip, ms_cap_tras_no_venci ,
	ms_mto_venc_int     , ms_mto_venc_tra_int , ms_mto_finan_vdo     , ms_mto_reser_int     ,
	ms_mto_fin_ven_trasp, ms_mto_fin_vig_trasp, ms_int_tra_no_exig   , ms_sdo_trab4 ,ms_atr
	FROM "informix".sd_maesdosrevcrd
	WHERE folio = o_folio ;

	INSERT INTO sd_maesdoscrd
	VALUES  (ms_empresa          , ms_num_credito      , ms_fecha_ult_mov     , ms_sdo_int_anticip   ,
	ms_sdo_int_ant_dev  , ms_sdo_intereses    , ms_sdo_dia_ant_int   , ms_sdo_mes_ant_int   ,
	ms_sdo_acum_mes_int , ms_sdo_retenido     , ms_sdo_acum_cap_int  , ms_sdo_exig_int      ,
	ms_sdo_no_exig      , ms_provision_normal , ms_dias_acum_int     , ms_sdo_moratorio     ,
	ms_sdo_dia_ant_mor  , ms_sdo_mes_ant_mor  , ms_sdo_contab_mora   , ms_dias_acum_mora    ,
	ms_sdo_capital      , ms_sdo_cap_insoluto , ms_sdo_dia_ant_cap   , ms_sdo_mes_ant_cap   ,
	ms_sdo_acum_mes_cap , ms_mto_capitalizado , ms_mto_ministra_cap  , ms_cargos_dia_cap    ,
	ms_abonos_dia_cap   , ms_cargos_mes_cap   , ms_abonos_mes_cap    , ms_dias_acum_cap     ,
	ms_monto_vencido    , ms_mto_venc_trasp   , ms_monto_financiado  , ms_monto_reservado   ,
	ms_sdo_acum_vencido , ms_dias_acum_intper , ms_sdo_global_int    , ms_sdo_acum_intper   ,
	ms_monto_otorgado   , ms_provi_venc_normal, ms_provi_venc_anticip, ms_cap_tras_no_venci ,
	ms_mto_venc_int     , ms_mto_venc_tra_int , ms_mto_finan_vdo     , ms_mto_reser_int     ,
	ms_mto_fin_ven_trasp, ms_mto_fin_vig_trasp, ms_int_tra_no_exig   , ms_sdo_trab4, ms_atr);


	--** Existe numero credito de maesdoscrd  **--
	IF NOT EXISTS (Select num_credito from "informix".sd_maesdoscrd where num_credito = ms_num_credito) Then
		LET v_codret = '001';
		Return v_codret;
	End IF;
	
{
	-- RECUPERA DETCOMI
	FOREACH
	SELECT empresa    , cod_comis, num_credito, fecha_alta, fecha_pago   ,
	monto_com  , monto_pag, apli_factor, estado_com, num_solicitud,
	user_insert, fecha_insert
	INTO dc_empresa   ,  dc_cod_comis    , dc_num_credito, dc_fecha_alta ,
	dc_fecha_pago,  dc_monto_com    , dc_monto_pag  , dc_apli_factor,
	dc_estado_com,  dc_num_solicitud, dc_user_insert,
	dc_fecha_insert
	FROM "informix".sd_detcomirev
	WHERE folio = o_folio
	ORDER BY fecha_alta

		let o_folio=trim(o_folio);
		
		INSERT INTO sd_detcomi
		(empresa, cod_comis, num_credito, fecha_alta,
		fecha_pago, monto_com, monto_pag,
		apli_factor, estado_com, num_solicitud,
		user_insert, fecha_insert)
		VALUES(dc_empresa, dc_cod_comis, dc_num_credito, dc_fecha_alta,
		dc_fecha_pago, dc_monto_com, dc_monto_pag,
		dc_apli_factor, dc_estado_com, dc_num_solicitud,
		dc_user_insert, dc_fecha_insert);
	END FOREACH;

}
	-- Recupera Amortiza Credito
	FOREACH
	SELECT empresa           , num_credito       , fecha_cuota       , tipo_cuota         ,
	capital_mto_cuota , capital_debe      , capital_pagado    , capital_status     ,
	capital_status_ant, capital_fecha_pago, interes_debe      , interes_pagado     ,
	interes_status    , interes_status_ant, interes_fecha_pago, iva_debe           ,
	iva_pagado        , iva_status        , iva_status_ant    , iva_fecha_pago     ,
	mora_provi_ordi   , mora_provi_cope   , mora_sdo_ordi     , mora_sdo_ordi_pag  ,
	mora_sdo_cope     , mora_sdo_cope_pag , mora_bonificado   , mora_status        ,
	mora_iva_debe     , mora_iva_pagado   , mora_iva_status   , mora_iva_fecha_pago,
	num_pago          , campo_trabajo1    , campo_trabajo2    , campo_trabajo3     ,
	campo_trabajo4
	INTO am_empresa           , am_num_credito       , am_fecha_cuota       , am_tipo_cuota        ,
	am_capital_mto_cuota , am_capital_debe      , am_capital_pagado    , am_capital_status    ,
	am_capital_status_ant, am_capital_fecha_pago, am_interes_debe      , am_interes_pagado    ,
	am_interes_status    , am_interes_status_ant, am_interes_fecha_pago, am_iva_debe          ,
	am_iva_pagado        , am_iva_status        , am_iva_status_ant    , am_iva_fecha_pago    ,
	am_mora_provi_ordi   , am_mora_provi_cope   , am_mora_sdo_ordi     , am_mora_sdo_ordi_pag ,
	am_mora_sdo_cope     , am_mora_sdo_cope_pag , am_mora_bonificado   , am_mora_status       ,
	am_mora_iva_debe     , am_mora_iva_pagado   , am_mora_iva_status   , am_mora_iva_fecha_pago,
	am_num_pago          , am_campo_trabajo1    , am_campo_trabajo2    , am_campo_trabajo3     ,
	am_campo_trabajo4
	FROM "informix".sd_amortiza_creditorevcrd
	WHERE folio = o_folio 
	ORDER BY fecha_cuota

		INSERT INTO sd_amortiza_creditocrd
		VALUES(
		am_empresa           , am_num_credito       , am_fecha_cuota       , am_tipo_cuota        ,
		am_capital_mto_cuota , am_capital_debe      , am_capital_pagado    , am_capital_status    ,
		am_capital_status_ant, am_capital_fecha_pago, am_interes_debe      , am_interes_pagado    ,
		am_interes_status    , am_interes_status_ant, am_interes_fecha_pago, am_iva_debe          ,
		am_iva_pagado        , am_iva_status        , am_iva_status_ant    , am_iva_fecha_pago    ,
		am_mora_provi_ordi   , am_mora_provi_cope   , am_mora_sdo_ordi     , am_mora_sdo_ordi_pag ,
		am_mora_sdo_cope     , am_mora_sdo_cope_pag , am_mora_bonificado   , am_mora_status       ,
		am_mora_iva_debe     , am_mora_iva_pagado   , am_mora_iva_status   , am_mora_iva_fecha_pago,
		am_num_pago          , am_campo_trabajo1    , am_campo_trabajo2    , am_campo_trabajo3     ,
		am_campo_trabajo4);
	END FOREACH


	--** Existe numero credito de amortiza_creditocrd  **--
	IF NOT EXISTS (Select num_credito from "informix".sd_amortiza_creditocrd where empresa = '001' AND num_credito = am_num_credito) Then
		LET v_codret = '001';
		Return v_codret;
	End IF;

	--** Recupera Maecred Anexo **--
	SELECT {+INDEX ("informix".sd_maecredanexorevcrd )}
	empresa          , num_credito         , dia_corte          , localidad         ,
	dias_gracia_mora , tp_dias_calc_mora   , dias_fecha_max_pago, tp_dias_fecha_pago,
	cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte      , tasa_interes_cte  ,  
	fecha_vencto     , prox_fecha_pago     ,  fecha_proceso     ,     fecha_ult_pago,
	nombre_pres
	INTO mx_empresa          , mx_num_credito         , mx_dia_corte          , mx_localidad          ,
	mx_dias_gracia_mora , mx_tp_dias_calc_mora   , mx_dias_fecha_max_pago, mx_tp_dias_fecha_pago ,
	mx_cod_tasa_base_cte, mx_factor_sobretasa_cte, mx_sobretasa_cte      , mx_tasa_interes_cte   , 
	mx_fecha_vencto     , mx_prox_fecha_pago     , mx_fecha_proceso      , mx_fecha_ult_pago,
	mx_nombre_pres
	FROM "informix".sd_maecredanexorevcrd   
	WHERE folio = o_folio ;

	INSERT INTO sd_maecredanexocrd
	VALUES (mx_empresa          , mx_num_credito         , mx_localidad, mx_dia_corte,
	mx_dias_gracia_mora , mx_tp_dias_calc_mora   , mx_dias_fecha_max_pago, mx_tp_dias_fecha_pago ,
	mx_cod_tasa_base_cte, mx_factor_sobretasa_cte, mx_sobretasa_cte      , mx_tasa_interes_cte   , 
	mx_fecha_vencto     , mx_prox_fecha_pago     , mx_fecha_proceso      , mx_fecha_ult_pago,
	mx_nombre_pres,mx_cat);


	--** Existe numero credito de maecredanexocrd  **--
	IF NOT EXISTS (Select num_credito from "informix".sd_maecredanexocrd where num_credito = mx_num_credito) Then
		LET v_codret = '001';
		Return v_codret;
	End IF;


	-- Revisa su Hubo recuperacion de Linea Transaccion 008 ref 1

	SELECT NVL(sum(monto),0) INTO vmonto_linea 
	FROM "informix".sd_movdiacrd
	WHERE folio_suc = o_folio
	AND   codigo_fun = "008"
	AND   codigo_ref = 1
	AND   reversado != "S";
	
	IF vmonto_linea > 0 THEN
		UPDATE sd_ctegpo SET linea_util = linea_util + vmonto_linea
		WHERE  numcte = mc_numcte
		AND    tp_linea = "R";
        
		UPDATE sd_ctepro SET linea_util = linea_util + vmonto_linea
		WHERE  numcte = mc_numcte
		AND    tp_linea = "R";
	END IF 
	
	--EM 21/03/2017 se modifica para que realice reverso automatico
	IF o_tiporev = 'M' THEN
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND b.folio_suc = o_folio;

		DELETE FROM bdicred:"informix".sd_pago_anticipado_cs WHERE folio_suc = o_folio;

		Let cNumCreditoPromo = cNumCreditoPromo;

		-- Recupera PROMOCION CREDITO	  -- DSB TH 07/02/2017
		IF EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito_rev 
		WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio) THEN
		
			-- modifica credisolucion
			-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
			update bdicred: "informix".sd_promocion_credito a set 
			a.monto_actual = (select b.monto_actual from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio),
			a.monto_int_iva = (select b.monto_int_iva from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.mensualidad = (select b.mensualidad from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.status = (select b.status from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio)
			where a.empresa = o_empresa and a.num_sol_prestamo = cNumCreditoPromo ;

			-- borra respaldo de credisolucion para reverso 
			DELETE FROM bdicred: "informix".sd_promocion_credito_rev WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio;
		END IF;
					  
	ELSE
		IF EXISTS (SELECT b.num_credito  FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND b.folio_suc = o_folio
		AND a.folio_movto = cFolioMovto)
		THEN

			DELETE FROM bdicred:"informix".sd_pago_anticipado_cs WHERE folio_suc = o_folio;
		END IF;

		SELECT num_sol_prestamo
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito 
		WHERE empresa = o_empresa
		AND folio_movto = cFolioMovto;

		-- Recupera PROMOCION CREDITO
		IF EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito_rev 
		WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_movto = cFolioMovto AND folio_suc_mov_crd = o_folio) THEN
			-- modifica credisolucion
			-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO

			update bdicred: "informix".sd_promocion_credito a set 
			a.monto_actual = (select b.monto_actual from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio),
			a.monto_int_iva = (select b.monto_int_iva from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.mensualidad = (select b.mensualidad from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.status = (select b.status from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio)
			where a.empresa = o_empresa and a.num_sol_prestamo = cNumCreditoPromo and a.folio_suc_mov_crd = o_folio;

			-- borra respaldo de credisolucion para reverso 
			DELETE FROM bdicred: "informix".sd_promocion_credito_rev WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio AND folio_movto = cFolioMovto;
		END IF;
	END IF
	  
	----------------------------------------------------------
	--    Reversio DE   sd_maeretenido                  --
	----------------------------------------------------------
	SELECT folio_suc, num_credito, folio_movto
	INTO c_Folio_Suc, cNumCredito, cfolio_mov
	FROM bdicred: "informix".sd_promocion_credito 
	WHERE  empresa= o_empresa
	and num_sol_prestamo = cNumCreditoPromo;
			
	IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R') THEN
		
		SELECT MAX (secuencia) 
		INTO iSecuencia
		FROM bdicred: "informix".sd_maeretenido_rev
		WHERE empresa = '001' 
		AND num_credito = cNumCredito
		AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
		AND nvl(substr(referencia,18,3),'') = 'PAG'
		AND estatus = 'R';
			
		DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R';
					
		INSERT INTO bdicred: "informix".sd_maeretenido
		(empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
		SELECT
		empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
		FROM bdicred: "informix".sd_maeretenido_rev
		WHERE empresa = '001'
		AND num_credito = cNumCredito
		AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
		AND nvl(substr(referencia,18,3),'') = 'PAG'
		AND estatus = 'R'
		AND secuencia = iSecuencia;	
				
		DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R'  AND secuencia = iSecuencia;
		
	END IF;
		
		
	SELECT substr(folio_movto,1,1)
	INTO cInFolMov
	FROM bdicred: "informix".sd_promocion_credito 
	WHERE  empresa= 001
	and num_sol_prestamo = cNumCreditoPromo;
		
			
	IF (nvl(substr(cInFolMov,1,1),'') <> '0') AND (nvl(substr(cInFolMov,1,1),'') <> '1') AND (nvl(substr(cInFolMov,1,1),'') <> '2') AND (nvl(substr(cInFolMov,1,1),'') <> '3') AND (nvl(substr(cInFolMov,1,1),'') <> '4') AND (nvl(substr(cInFolMov,1,1),'') <> '5') AND (nvl(substr(cInFolMov,1,1),'') <> '6') AND (nvl(substr(cInFolMov,1,1),'') <> '7') AND (nvl(substr(cInFolMov,1,1),'') <> '8') AND (nvl(substr(cInFolMov,1,1),'') <> '9') THEN
	
		IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			
			SELECT MAX (secuencia) 
			INTO iSecuencia
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001' 
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R';
					
			DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
				
			INSERT INTO bdicred: "informix".sd_maeretenido
			(empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
			SELECT
			empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001'
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R'
			AND secuencia = iSecuencia;	
				
			DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R'  AND secuencia = iSecuencia;
		
		END IF;
	ELSE
		IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev 	WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			SELECT MAX (secuencia) 
			INTO iSecuencia
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001' 
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov 
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R';
					
			DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
				
			INSERT INTO bdicred: "informix".sd_maeretenido
			(empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
			SELECT
			empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001'
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R'
			AND secuencia = iSecuencia;	
				
			DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R'  AND secuencia = iSecuencia;
			
		END IF;		
	END IF;
	
		--CAX 2025 se agrega tabla sd_linea_prestamo para los prestamos flexibles(6800)
	IF 	mc_num_producto = '6800' THEN
		SELECT empresa,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
		disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior
		INTO lp_empresa,lp_num_credito,lp_monto_linea,lp_fecha_otorga,lp_linea_disponible,lp_sec_credito,lp_fecha_cancela,lp_fecha_ult_mod,
		lp_disposicion_activada,lp_fecha_ult_pf,lp_cancel_pf,lp_fecha_venc_linea,lp_acepto_incremento,lp_linea_prestamo_anterior
		FROM "informix".sd_linea_prestamorev
		WHERE folio = o_folio;
		
		INSERT INTO "informix".sd_linea_prestamo
		VALUES(lp_empresa,lp_num_credito,lp_monto_linea,lp_fecha_otorga,lp_linea_disponible,lp_sec_credito,lp_fecha_cancela,lp_fecha_ult_mod,
		lp_disposicion_activada,lp_fecha_ult_pf,lp_cancel_pf,lp_fecha_venc_linea,lp_acepto_incremento,lp_linea_prestamo_anterior);
	END IF;

	-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
	UPDATE sd_movdiacrd SET reversado = "S"
	WHERE  folio_suc = o_folio;
    
	UPDATE sd_maesdoscrd set sdo_retenido = 0
	WHERE num_credito = sp_num_credito;
 
	DELETE FROM "informix".sd_secpago
	WHERE folio_suc = o_folio AND num_credito = sp_num_credito;
	
	-- REVERSO sd_amortiza_creditocrd_pago_anticipado A.U
	select count(*) into iAmortiza_count from "informix".sd_amortiza_creditocrd_pago_anticipado where folio_suc = o_folio and reverso = 'N' and num_credito = sp_num_credito;
	
	if (iAmortiza_count >= 1) THEN
		update "informix".sd_amortiza_creditocrd_pago_anticipado set reverso = 'S' where folio_suc = o_folio and reverso = 'N' and num_credito = sp_num_credito;
	end if;

COMMIT WORK;

END
IF (wBegin = "S") THEN
	BEGIN WORK;
END IF;
RETURN v_codret;

END PROCEDURE
DOCUMENT
'----------------------------------------------------------------------------',
'Descripcion : Se agrega validacion de la tabla sd_amortiza_creditocrd_pago_anticipado y hace update si existe la condicion.',
'Modifico    : 99806282 - Andrea Mariana Urrea',
'Fecha       : 05/11/2024',
'BD          : bdicred';

CREATE PROCEDURE "informix".reversioncrd(o_empresa   CHAR(3),
		  	              O_SUCursal  CHAR(4),
			              O_USUARIO   CHAR(8),
			              o_folio     CHAR(16),
			              o_tiporev   CHAR(1))
RETURNING CHAR(5);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE w_usuario        CHAR(8);
DEFINE v_maxsec         SMALLINT;
DEFINE vdia             DATE;
DEFINE vCodTipCred      CHAR(3);
DEFINE wBegin		CHAR(1);
DEFINE vMensaje         CHAR(80);
DEFINE vExiste			integer;

DEFINE c_Folio_Suc	    CHAR(16);
DEFINE iSecuencia       INTEGER;
DEFINE cNumCredito      CHAR(20);
DEFINE cfolio_mov       CHAR(16);

 DEFINE  mc_empresa                 LIKE sd_maecredcrd.empresa;
 DEFINE  mc_num_credito             LIKE sd_maecredcrd.num_credito;
 DEFINE  mc_num_producto            LIKE sd_maecredcrd.num_producto;
 DEFINE  mc_ejecutivo               LIKE sd_maecredcrd.ejecutivo;
 DEFINE  mc_numcte                  LIKE sd_maecredcrd.numcte;
 DEFINE  mc_aval_cte                LIKE sd_maecredcrd.aval_cte;
 DEFINE  mc_aval_linea              LIKE sd_maecredcrd.aval_linea;
 DEFINE  mc_divisa                  LIKE sd_maecredcrd.divisa;
 DEFINE  mc_sucursal                LIKE sd_maecredcrd.sucursal;
 DEFINE  mc_id_origen               LIKE sd_maecredcrd.id_origen;
 DEFINE  mc_origen                  LIKE sd_maecredcrd.origen;
 DEFINE  mc_cod_tipo_linea          LIKE sd_maecredcrd.cod_tipo_linea;
 DEFINE  mc_cod_linea               LIKE sd_maecredcrd.cod_linea;
 DEFINE  mc_status_cred             LIKE sd_maecredcrd.status_cred;
 DEFINE  mc_bandera_renovac         LIKE sd_maecredcrd.bandera_renovac;
 DEFINE  mc_bandera_prorroga        LIKE sd_maecredcrd.bandera_prorroga;
 DEFINE  mc_periodo_plazo           LIKE sd_maecredcrd.periodo_plazo;
 DEFINE  mc_plazo                   LIKE sd_maecredcrd.plazo;
 DEFINE  mc_fecha_apertura          LIKE sd_maecredcrd.fecha_apertura;
 DEFINE  mc_fecha_vencim            LIKE sd_maecredcrd.fecha_vencim;
 DEFINE  mc_period_pago_cap         LIKE sd_maecredcrd.period_pago_cap;
 DEFINE  mc_period_pag_int          LIKE sd_maecredcrd.period_pag_int;
 DEFINE  mc_dias_trasp_cap          LIKE sd_maecredcrd.dias_trasp_cap;
 DEFINE  mc_dias_trasp_int          LIKE sd_maecredcrd.dias_trasp_int;
 DEFINE  mc_tasa_fija_o_var         LIKE sd_maecredcrd.tasa_fija_o_var;
 DEFINE  mc_cod_tasa_base           LIKE sd_maecredcrd.cod_tasa_base;
 DEFINE  mc_factor_sobretasa        LIKE sd_maecredcrd.factor_sobretasa;
 DEFINE  mc_sobretasa               LIKE sd_maecredcrd.sobretasa;
 DEFINE  mc_tasa_interes            LIKE sd_maecredcrd.tasa_interes;
 DEFINE  mc_cod_tasa_mora           LIKE sd_maecredcrd.cod_tasa_mora;
 DEFINE  mc_sobretasa_mora          LIKE sd_maecredcrd.sobretasa_mora;
 DEFINE  mc_fact_sobret_mora        LIKE sd_maecredcrd.fact_sobret_mora;
 DEFINE  mc_tasa_moratorios         LIKE sd_maecredcrd.tasa_moratorios;
 DEFINE  mc_tasa_preferencia        LIKE sd_maecredcrd.tasa_preferencial;
 DEFINE  mc_sobretasa_preferencial  LIKE sd_maecredcrd.sobretasa_preferencial;
 DEFINE  mc_factor_preferencial     LIKE sd_maecredcrd.factor_preferencial;
 DEFINE  mc_valor_preferencial      LIKE sd_maecredcrd.valor_preferencial;
 DEFINE  mc_fecha_pago_cap          LIKE sd_maecredcrd.fecha_pago_cap;
 DEFINE  mc_fecha_pago_int          LIKE sd_maecredcrd.fecha_pago_int;
 DEFINE  mc_es_fisica               LIKE sd_maecredcrd.es_fisica;
 DEFINE  mc_bandera_fi_fo           LIKE sd_maecredcrd.bandera_fi_fo;
 DEFINE  mc_actividad               LIKE sd_maecredcrd.actividad;
 DEFINE  mc_tipo_calculo            LIKE sd_maecredcrd.tipo_calculo;
 DEFINE  mc_num_aper_ant            LIKE sd_maecredcrd.num_aper_ant;
 DEFINE  mc_rev_tasa_var_per        LIKE sd_maecredcrd.rev_tasa_var_per;
 DEFINE  mc_dia_para_revisar        LIKE sd_maecredcrd.dia_para_revisar;
 DEFINE  mc_cod_prod                LIKE sd_maecredcrd.cod_prod;
 DEFINE  mc_bandera_ministra        LIKE sd_maecredcrd.bandera_ministra;
 DEFINE  mc_credito_externo         LIKE sd_maecredcrd.credito_externo;
 DEFINE  mc_califica_riesgo         LIKE sd_maecredcrd.califica_riesgo;
 DEFINE  mc_cod_agricola            LIKE sd_maecredcrd.cod_agricola;
 DEFINE  mc_pagos_sostenidos        LIKE sd_maecredcrd.pagos_sostenidos;
 DEFINE  mc_campo_trab1             LIKE sd_maecredcrd.campo_trab1;
 DEFINE  mc_campo_trab2             LIKE sd_maecredcrd.campo_trab2;
 DEFINE  mc_campo_trab3             LIKE sd_maecredcrd.campo_trab3;
 DEFINE  mc_campo_trab4             LIKE sd_maecredcrd.campo_trab4;
 DEFINE  mc_cuenta_clabe			LIKE sd_maecredcrd.cuenta_clabe;


DEFINE ms_empresa             LIKE sd_maesdoscrd.empresa;
DEFINE ms_num_credito         LIKE sd_maesdoscrd.num_credito;
DEFINE ms_fecha_ult_mov       LIKE sd_maesdoscrd.fecha_ult_mov;
DEFINE ms_sdo_int_anticip     LIKE sd_maesdoscrd.sdo_int_anticip;
DEFINE ms_sdo_int_ant_dev     LIKE sd_maesdoscrd.sdo_int_ant_dev;
DEFINE ms_sdo_intereses       LIKE sd_maesdoscrd.sdo_intereses;
DEFINE ms_sdo_dia_ant_int     LIKE sd_maesdoscrd.sdo_dia_ant_int;
DEFINE ms_sdo_mes_ant_int     LIKE sd_maesdoscrd.sdo_mes_ant_int;
DEFINE ms_sdo_acum_mes_int    LIKE sd_maesdoscrd.sdo_acum_mes_int;
DEFINE ms_sdo_retenido        LIKE sd_maesdoscrd.sdo_retenido;
DEFINE ms_sdo_acum_cap_int    LIKE sd_maesdoscrd.sdo_acum_cap_int;
DEFINE ms_sdo_exig_int        LIKE sd_maesdoscrd.sdo_exig_int;
DEFINE ms_sdo_no_exig         LIKE sd_maesdoscrd.sdo_no_exig;
DEFINE ms_provision_normal    LIKE sd_maesdoscrd.provision_normal;
DEFINE ms_dias_acum_int       LIKE sd_maesdoscrd.dias_acum_int;
DEFINE ms_sdo_moratorio       LIKE sd_maesdoscrd.sdo_moratorio;
DEFINE ms_sdo_dia_ant_mor     LIKE sd_maesdoscrd.sdo_dia_ant_mor;
DEFINE ms_sdo_mes_ant_mor     LIKE sd_maesdoscrd.sdo_mes_ant_mor;
DEFINE ms_sdo_contab_mora     LIKE sd_maesdoscrd.sdo_contab_mora;
DEFINE ms_dias_acum_mora      LIKE sd_maesdoscrd.dias_acum_mora;
DEFINE ms_sdo_capital         LIKE sd_maesdoscrd.sdo_capital;
DEFINE ms_sdo_cap_insoluto    LIKE sd_maesdoscrd.sdo_cap_insoluto;
DEFINE ms_sdo_dia_ant_cap     LIKE sd_maesdoscrd.sdo_dia_ant_cap;
DEFINE ms_sdo_mes_ant_cap     LIKE sd_maesdoscrd.sdo_mes_ant_cap;
DEFINE ms_sdo_acum_mes_cap    LIKE sd_maesdoscrd.sdo_acum_mes_cap;
DEFINE ms_mto_capitalizado    LIKE sd_maesdoscrd.mto_capitalizado;
DEFINE ms_mto_ministra_cap    LIKE sd_maesdoscrd.mto_ministra_cap;
DEFINE ms_cargos_dia_cap      LIKE sd_maesdoscrd.cargos_dia_cap;
DEFINE ms_abonos_dia_cap      LIKE sd_maesdoscrd.abonos_dia_cap;
DEFINE ms_cargos_mes_cap      LIKE sd_maesdoscrd.cargos_mes_cap;
DEFINE ms_abonos_mes_cap      LIKE sd_maesdoscrd.abonos_mes_cap;
DEFINE ms_dias_acum_cap       LIKE sd_maesdoscrd.dias_acum_cap;
DEFINE ms_monto_vencido       LIKE sd_maesdoscrd.monto_vencido;
DEFINE ms_mto_venc_trasp      LIKE sd_maesdoscrd.mto_venc_trasp;
DEFINE ms_monto_financiado    LIKE sd_maesdoscrd.monto_financiado;
DEFINE ms_monto_reservado     LIKE sd_maesdoscrd.monto_reservado;
DEFINE ms_sdo_acum_vencido    LIKE sd_maesdoscrd.sdo_acum_vencido;
DEFINE ms_dias_acum_intper    LIKE sd_maesdoscrd.dias_acum_intper;
DEFINE ms_sdo_global_int      LIKE sd_maesdoscrd.sdo_global_int;
DEFINE ms_sdo_acum_intper     LIKE sd_maesdoscrd.sdo_acum_intper;
DEFINE ms_monto_otorgado      LIKE sd_maesdoscrd.monto_otorgado;
DEFINE ms_provi_venc_normal   LIKE sd_maesdoscrd.provi_venc_normal;
DEFINE ms_provi_venc_anticip  LIKE sd_maesdoscrd.provi_venc_anticip;
DEFINE ms_cap_tras_no_venci   LIKE sd_maesdoscrd.cap_tras_no_venci;
DEFINE ms_mto_venc_int        LIKE sd_maesdoscrd.mto_venc_int;
DEFINE ms_mto_venc_tra_int    LIKE sd_maesdoscrd.mto_venc_tra_int;
DEFINE ms_mto_finan_vdo       LIKE sd_maesdoscrd.mto_finan_vdo;
DEFINE ms_mto_reser_int       LIKE sd_maesdoscrd.mto_reser_int;
DEFINE ms_mto_fin_ven_trasp   LIKE sd_maesdoscrd.mto_fin_ven_trasp;
DEFINE ms_mto_fin_vig_trasp   LIKE sd_maesdoscrd.mto_fin_vig_trasp;
DEFINE ms_int_tra_no_exig     LIKE sd_maesdoscrd.int_tra_no_exig;
DEFINE ms_sdo_trab4           LIKE sd_maesdoscrd.sdo_trab4;
DEFINE ms_atr                 LIKE sd_maesdoscrd.atr;

DEFINE dc_empresa             LIKE sd_detcomi.empresa;
DEFINE dc_cod_comis           LIKE sd_detcomi.cod_comis;
DEFINE dc_num_credito         LIKE sd_detcomi.num_credito;
DEFINE dc_fecha_alta          LIKE sd_detcomi.fecha_alta;
DEFINE dc_fecha_pago          LIKE sd_detcomi.fecha_pago;
DEFINE dc_monto_com           LIKE sd_detcomi.monto_com;
DEFINE dc_monto_pag           LIKE sd_detcomi.monto_pag;
DEFINE dc_apli_factor         LIKE sd_detcomi.apli_factor;
DEFINE dc_estado_com          LIKE sd_detcomi.estado_com;
DEFINE dc_num_solicitud       LIKE sd_detcomi.num_solicitud;
DEFINE dc_user_insert         LIKE sd_detcomi.user_insert;
DEFINE dc_fecha_insert        LIKE sd_detcomi.fecha_insert;

DEFINE mx_empresa              LIKE sd_maecredanexocrd.empresa;
DEFINE mx_num_credito          LIKE sd_maecredanexocrd.num_credito;
DEFINE mx_dia_corte            LIKE sd_maecredanexocrd.dia_corte;
DEFINE mx_dias_gracia_mora     LIKE sd_maecredanexocrd.dias_gracia_mora;
DEFINE mx_tp_dias_calc_mora    LIKE sd_maecredanexocrd.tp_dias_calc_mora;
DEFINE mx_dias_fecha_max_pago  LIKE sd_maecredanexocrd.dias_fecha_max_pago;
DEFINE mx_tp_dias_fecha_pago   LIKE sd_maecredanexocrd.tp_dias_fecha_pago;
DEFINE mx_cod_tasa_base_cte    LIKE sd_maecredanexocrd.cod_tasa_base_cte;
DEFINE mx_factor_sobretasa_cte LIKE sd_maecredanexocrd.factor_sobretasa_cte;
DEFINE mx_sobretasa_cte        LIKE sd_maecredanexocrd.sobretasa_cte;
DEFINE mx_tasa_interes_cte     LIKE sd_maecredanexocrd.tasa_interes_cte;
DEFINE mx_fecha_vencto         LIKE sd_maecredanexocrd.fecha_vencto;
DEFINE mx_prox_fecha_pago      LIKE sd_maecredanexocrd.prox_fecha_pago;
DEFINE mx_fecha_proceso        LIKE sd_maecredanexocrd.fecha_proceso;
DEFINE mx_fecha_ult_pago       LIKE sd_maecredanexocrd.fecha_ult_pago;
define mx_localidad            LIKE sd_maecredanexocrd.localidad;
DEFINE mx_nombre_pres          LIKE sd_maecredanexocrd.nombre_pres;
DEFINE mx_cat		          LIKE sd_maecredanexocrd.cat;


DEFINE am_empresa              LIKE sd_amortiza_creditocrd.empresa;
DEFINE am_num_credito          LIKE sd_amortiza_creditocrd.num_credito;
DEFINE am_fecha_cuota          LIKE sd_amortiza_creditocrd.fecha_cuota;
DEFINE am_tipo_cuota           LIKE sd_amortiza_creditocrd.tipo_cuota;
DEFINE am_capital_mto_cuota    LIKE sd_amortiza_creditocrd.capital_mto_cuota;
DEFINE am_capital_debe         LIKE sd_amortiza_creditocrd.capital_debe;
DEFINE am_capital_pagado       LIKE sd_amortiza_creditocrd.capital_pagado;
DEFINE am_capital_status       LIKE sd_amortiza_creditocrd.capital_status;
DEFINE am_capital_status_ant   LIKE sd_amortiza_creditocrd.capital_status_ant;
DEFINE am_capital_fecha_pago   LIKE sd_amortiza_creditocrd.capital_fecha_pago;
DEFINE am_interes_debe         LIKE sd_amortiza_creditocrd.interes_debe;
DEFINE am_interes_pagado       LIKE sd_amortiza_creditocrd.interes_pagado;
DEFINE am_interes_status       LIKE sd_amortiza_creditocrd.interes_status;
DEFINE am_interes_status_ant   LIKE sd_amortiza_creditocrd.interes_status_ant;
DEFINE am_interes_fecha_pago   LIKE sd_amortiza_creditocrd.interes_fecha_pago;
DEFINE am_iva_debe             LIKE sd_amortiza_creditocrd.iva_debe;
DEFINE am_iva_pagado           LIKE sd_amortiza_creditocrd.iva_pagado;
DEFINE am_iva_status           LIKE sd_amortiza_creditocrd.iva_status;
DEFINE am_iva_status_ant       LIKE sd_amortiza_creditocrd.iva_status_ant;
DEFINE am_iva_fecha_pago       LIKE sd_amortiza_creditocrd.iva_fecha_pago;
DEFINE am_mora_provi_ordi      LIKE sd_amortiza_creditocrd.mora_provi_ordi;
DEFINE am_mora_provi_cope      LIKE sd_amortiza_creditocrd.mora_provi_cope;
DEFINE am_mora_sdo_ordi        LIKE sd_amortiza_creditocrd.mora_sdo_ordi;
DEFINE am_mora_sdo_ordi_pag    LIKE sd_amortiza_creditocrd.mora_sdo_ordi_pag;  --FMV: 17-MAY-10
DEFINE am_mora_sdo_cope        LIKE sd_amortiza_creditocrd.mora_sdo_cope;
DEFINE am_mora_sdo_cope_pag    LIKE sd_amortiza_creditocrd.mora_sdo_cope_pag;
DEFINE am_mora_bonificado      LIKE sd_amortiza_creditocrd.mora_bonificado;
DEFINE am_mora_status          LIKE sd_amortiza_creditocrd.mora_status;
DEFINE am_mora_iva_debe        LIKE sd_amortiza_creditocrd.mora_iva_debe;
DEFINE am_mora_iva_pagado      LIKE sd_amortiza_creditocrd.mora_iva_pagado;
DEFINE am_mora_iva_status      LIKE sd_amortiza_creditocrd.mora_iva_status;
DEFINE am_mora_iva_fecha_pago  LIKE sd_amortiza_creditocrd.mora_iva_fecha_pago;
DEFINE am_num_pago             LIKE sd_amortiza_creditocrd.num_pago;
DEFINE am_campo_trabajo1       LIKE sd_amortiza_creditocrd.campo_trabajo1;
DEFINE am_campo_trabajo2       LIKE sd_amortiza_creditocrd.campo_trabajo2;
DEFINE am_campo_trabajo3       LIKE sd_amortiza_creditocrd.campo_trabajo3;
DEFINE am_campo_trabajo4       LIKE sd_amortiza_creditocrd.campo_trabajo4;

DEFINE sp_empresa              LIKE sd_secpago.empresa;
DEFINE sp_num_credito          LIKE sd_secpago.num_credito;
DEFINE sp_folio_suc            LIKE sd_secpago.folio_suc;
DEFINE sp_secuencia            LIKE sd_secpago.secuencia;

DEFINE lp_empresa                  LIKE sd_linea_prestamo.empresa;
DEFINE lp_num_credito              LIKE sd_linea_prestamo.num_credito;
DEFINE lp_monto_linea              LIKE sd_linea_prestamo.monto_linea;
DEFINE lp_fecha_otorga             LIKE sd_linea_prestamo.fecha_otorga;
DEFINE lp_linea_disponible         LIKE sd_linea_prestamo.linea_disponible;
DEFINE lp_sec_credito              LIKE sd_linea_prestamo.sec_credito;
DEFINE lp_fecha_cancela            LIKE sd_linea_prestamo.fecha_cancela;
DEFINE lp_fecha_ult_mod            LIKE sd_linea_prestamo.fecha_ult_mod;
DEFINE lp_disposicion_activada     LIKE sd_linea_prestamo.disposicion_activada;
DEFINE lp_fecha_ult_pf             LIKE sd_linea_prestamo.fecha_ult_pf;
DEFINE lp_cancel_pf                LIKE sd_linea_prestamo.cancel_pf;
DEFINE lp_fecha_venc_linea         LIKE sd_linea_prestamo.fecha_venc_linea;
DEFINE lp_acepto_incremento        LIKE sd_linea_prestamo.acepto_incremento;
DEFINE lp_linea_prestamo_anterior  LIKE sd_linea_prestamo.linea_prestamo_anterior;

DEFINE de_empresa              CHAR(3)  ;
DEFINE de_num_credito          CHAR(20) ;
DEFINE vempresa                CHAR(3);
DEFINE vsucursal               CHAR(4);
DEFINE vnum_credito            CHAR(20);
DEFINE vdivisa                 CHAR(3);
DEFINE vtrannro                CHAR(4);
DEFINE vBan                    CHAR(2);
DEFINE de_plazo                VARCHAR(5,1);
DEFINE de_texto                VARCHAR(200,0);
DEFINE de_fecha_venc_seg       DATE     ;
DEFINE de_cod_comis            CHAR(4)  ;
DEFINE de_monto_poliza         MONEY(14,2);
DEFINE vmonto                  MONEY(14,2);
DEFINE cFolioMovto			   CHAR(20);
DEFINE de_monto_mensual        MONEY(14,2);
DEFINE de_saldo                DECIMAL(18,2);
DEFINE vmonto_linea            DECIMAL(18,2);
DEFINE cNumCreditoPromo        CHAR(16);
DEFINE cInFolMov			   CHAR(1);
define iAmortiza_count 	       INTEGER;
-- ***************************************************************************
-- *                     ASIGNACION DE VALORES A VARIABLES                   *
-- ***************************************************************************
LET v_codret  = "000";
LET wBegin    = "N";
LET sql_err   = 0;
LET w_usuario = USER;
LET v_maxsec  = 0;
LET vdia      = "";
LET vBan      = "";
LET vmonto_linea = 0;
LET vMensaje    = "";
LET vExiste = 0;

LET cFolioMovto      = "";
LET cNumCreditoPromo = "";
LET c_Folio_Suc      = '';
LET iSecuencia       = 0;
LET cNumCredito      = '';
LET cfolio_mov       = "";
LET cInFolMov			= "";
let iAmortiza_count =  0;
-- ***************************************************************************


BEGIN
	ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
		LET v_codret = sql_err;
		IF wBegin = "S" THEN
			ROLLBACK WORK;
			BEGIN WORK;
		END IF
		RETURN v_codret;
	END IF
END EXCEPTION;

ON EXCEPTION IN (-535)
	LET wBegin = "S";
	--ROLLBACK WORK;
	COMMIT WORK;
	BEGIN WORK;
END EXCEPTION WITH RESUME;

-- set debug file to "/home/c90271846/CANCELACION_DIGITALES/DEBUG/reversioncrd.out";
-- trace on;
  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
  

	LET wBegin = "N";
	
	-- Se valida que el movimiento no este reversado para poder continuar
	select  UNIQUE 1 into vExiste
	FROM "informix".sd_movdiacrd a, "informix".sd_definicion b
	WHERE a.empresa = o_empresa
	AND a.sucursal = o_sucursal
	AND a.reversado = 'S'
	AND a.folio_suc = o_folio
	AND b.empresa = a.empresa
	AND b.num_producto = a.num_producto;

	IF vExiste = 1 THEN
		RETURN v_codret;
	END IF;

--        LET sp_num_credito = O_NumCred;
--        LET sp_secuencia = o_secuencia;
	LET o_folio = TRIM(o_folio);

	SELECT limit 1 num_credito 
	INTO sp_num_credito
	FROM "informix".sd_movdiacrd
	WHERE folio_suc = o_folio ;
	
	-- DSB TH 07/02/2017		
	SELECT num_credito, folio_suc, secuencia
	INTO sp_num_credito, sp_folio_suc, sp_secuencia
	FROM "informix".sd_secpago
	WHERE folio_suc = o_folio and num_credito = sp_num_credito;

	SELECT MAX(secuencia) INTO v_maxsec FROM "informix".sd_secpago
	WHERE num_credito = sp_num_credito ;

	IF v_maxsec <> sp_secuencia THEN
		LET v_codret = "431"; -- PAGO NO ES EL ULTIMO REVERSA EN ORDEN
		COMMIT WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN v_codret;
	END IF;

	--** Existe folio en Respaldo de Maecred  **--
	If NOT exists (Select folio from "informix".sd_maecredrevcrd where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

    --**Existe folio en Respaldo de Maedosrev **--
	If NOT exists ( Select folio from "informix".sd_maesdosrevcrd  where folio = o_folio)Then
		LET v_codret = '001';
		Return v_codret;
	End If;

    --** Existe folio en Respaldo de Maecredanexorev **--
	If NOT  exists  (Select folio from "informix".sd_maecredanexorevcrd  where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;

    --** Existe folio en Respaldo de Amortiza_Credito **--
	If NOT  exists (Select folio from "informix".sd_amortiza_creditorevcrd  where folio = o_folio) Then
		LET v_codret = '001';
		Return v_codret;
	End If;
	
BEGIN WORK;
		--Se manda llamar el proceso de reverso de captacion
	
	EXECUTE PROCEDURE bdicheq:"informix".reversion(o_empresa, O_SUCursal, O_USUARIO, o_folio, o_tiporev) INTO v_codret;
	IF v_codret <> '000' THEN	
		RETURN v_codret;
	END IF;
		--fin del bloque	
	
	SELECT cat
	INTO mx_cat
	FROM "informix".sd_maecredanexocrd   
	WHERE num_credito = sp_num_credito;
		
	SET CONSTRAINTS ALL DEFERRED;

	DELETE FROM "informix".sd_maesdoscrd          WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_maecredanexocrd     WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_amortiza_creditocrd WHERE num_credito = sp_num_credito;
    DELETE FROM "informix".sd_maecredcrd          WHERE num_credito = sp_num_credito;
	DELETE FROM "informix".sd_linea_prestamo      WHERE num_credito = sp_num_credito;
	
	--EM 28/03/2017
	IF o_tiporev = 'M' THEN
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND a.status = 6
		AND b.folio_suc = o_folio;

		IF  cNumCreditoPromo != "" OR cNumCreditoPromo IS NOT NULL THEN	
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 2 WHERE  num_sol_prestamo = cNumCreditoPromo;
		END IF;
		
	ELSE
			--EM
		SELECT folio_movto
		INTO cFolioMovto
		FROM bdicred:"informix".sd_promocion_credito_rev  
		WHERE folio_suc_mov_crd = o_folio;
			
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND a.status = 6
		AND b.folio_suc = o_folio
		AND a.folio_movto = cFolioMovto;

		IF  cNumCreditoPromo != "" OR cNumCreditoPromo IS NOT NULL THEN	
			UPDATE bdicred:"informix".sd_promocion_credito SET status = 2 WHERE  num_sol_prestamo = cNumCreditoPromo;
		END IF;
		
	END IF;
	
        -- RECUPERA MAECRED
	SELECT
    empresa,             num_credito,	    num_producto,    ejecutivo,           numcte,
    aval_cte,            aval_linea,       divisa,          sucursal,            id_origen,
    origen,              cod_tipo_linea,   cod_linea,       status_cred,         bandera_renovac,
    bandera_prorroga,    periodo_plazo,    plazo,           fecha_apertura,      fecha_vencim,
    period_pago_cap,     period_pag_int,   dias_trasp_cap,  dias_trasp_int,      tasa_fija_o_var,
    cod_tasa_base,       factor_sobretasa, sobretasa,       tasa_interes,        cod_tasa_mora,
    sobretasa_mora,      fact_sobret_mora, tasa_moratorios, tasa_preferencial,    sobretasa_preferencial,
    factor_preferencial, valor_preferencial,fecha_pago_cap,   fecha_pago_int,  es_fisica,           bandera_fi_fo,
    actividad,           tipo_calculo,     num_aper_ant,    rev_tasa_var_per,    dia_para_revisar,
    cod_prod,            bandera_ministra, credito_externo, califica_riesgo, cod_agricola,
    pagos_sostenidos,    campo_trab1,      campo_trab2,     campo_trab3,         campo_trab4
	,cuenta_clabe
    INTO  mc_empresa,             mc_num_credito,      mc_num_producto,    mc_ejecutivo,           mc_numcte,
          mc_aval_cte,            mc_aval_linea,       mc_divisa,          mc_sucursal,            mc_id_origen,
          mc_origen,              mc_cod_tipo_linea,   mc_cod_linea,       mc_status_cred,         mc_bandera_renovac,
          mc_bandera_prorroga,    mc_periodo_plazo,    mc_plazo,           mc_fecha_apertura,      mc_fecha_vencim,
          mc_period_pago_cap,     mc_period_pag_int,   mc_dias_trasp_cap,  mc_dias_trasp_int,      mc_tasa_fija_o_var,
          mc_cod_tasa_base,       mc_factor_sobretasa, mc_sobretasa,       mc_tasa_interes,        mc_cod_tasa_mora,                              mc_sobretasa_mora,      mc_fact_sobret_mora, mc_tasa_moratorios, mc_tasa_preferencia,    mc_sobretasa_preferencial,
          mc_factor_preferencial, mc_valor_preferencial,mc_fecha_pago_cap,   mc_fecha_pago_int,  mc_es_fisica,           mc_bandera_fi_fo,
          mc_actividad,           mc_tipo_calculo,     mc_num_aper_ant,    mc_rev_tasa_var_per,    mc_dia_para_revisar,
          mc_cod_prod,            mc_bandera_ministra, mc_credito_externo, mc_califica_riesgo,     mc_cod_agricola,
          mc_pagos_sostenidos,    mc_campo_trab1,      mc_campo_trab2,     mc_campo_trab3,         mc_campo_trab4          ,mc_cuenta_clabe           FROM "informix".sd_maecredrevcrd                                                                                                                      WHERE folio = o_folio;

	INSERT INTO sd_maecredcrd
          VALUES( mc_empresa,             mc_num_credito,      mc_num_producto,    mc_ejecutivo,           mc_numcte,
                  mc_aval_cte,            mc_aval_linea,       mc_divisa,          mc_sucursal,            mc_id_origen,
                  mc_origen,              mc_cod_tipo_linea,   mc_cod_linea,       mc_status_cred,         mc_bandera_renovac,
                  mc_bandera_prorroga,    mc_periodo_plazo,    mc_plazo,           mc_fecha_apertura,      mc_fecha_vencim,
                  mc_period_pago_cap,     mc_period_pag_int,   mc_dias_trasp_cap,  mc_dias_trasp_int,      mc_tasa_fija_o_var,
                  mc_cod_tasa_base,       mc_factor_sobretasa, mc_sobretasa,       mc_tasa_interes,        mc_cod_tasa_mora,
                  mc_sobretasa_mora,      mc_fact_sobret_mora, mc_tasa_moratorios, mc_tasa_preferencia,    mc_sobretasa_preferencial,
                  mc_factor_preferencial, mc_valor_preferencial,mc_fecha_pago_cap,   mc_fecha_pago_int,  mc_es_fisica,           mc_bandera_fi_fo,
                  mc_actividad,           mc_tipo_calculo,     mc_num_aper_ant,    mc_rev_tasa_var_per,    mc_dia_para_revisar,
                  mc_cod_prod,            mc_bandera_ministra, mc_credito_externo, mc_califica_riesgo,     mc_cod_agricola,
                  mc_pagos_sostenidos,    mc_campo_trab1,      mc_campo_trab2,     mc_campo_trab3,         mc_campo_trab4	,mc_cuenta_clabe);


   -- RECUPERA MAESDOS
	SELECT empresa          , num_credito      , fecha_ult_mov     , sdo_int_anticip  ,
	sdo_int_ant_dev  , sdo_intereses    , sdo_dia_ant_int   , sdo_mes_ant_int  ,
    sdo_acum_mes_int , sdo_retenido     , sdo_acum_cap_int  , sdo_exig_int     ,
	sdo_no_exig      , provision_normal , dias_acum_int     , sdo_moratorio    ,
	sdo_dia_ant_mor  , sdo_mes_ant_mor  , sdo_contab_mora   , dias_acum_mora   ,
    sdo_capital      , sdo_cap_insoluto , sdo_dia_ant_cap   , sdo_mes_ant_cap  ,
    sdo_acum_mes_cap , mto_capitalizado , mto_ministra_cap  , cargos_dia_cap   ,
    abonos_dia_cap   , cargos_mes_cap   , abonos_mes_cap    , dias_acum_cap    ,
    monto_vencido    , mto_venc_trasp   , monto_financiado  , monto_reservado  ,
    sdo_acum_vencido , dias_acum_intper , sdo_global_int    , sdo_acum_intper  ,
	monto_otorgado   , provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
    mto_venc_int     , mto_venc_tra_int , mto_finan_vdo     , mto_reser_int    ,
    mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig   , sdo_trab4        , atr

	INTO ms_empresa          , ms_num_credito      , ms_fecha_ult_mov     , ms_sdo_int_anticip   ,
	ms_sdo_int_ant_dev  , ms_sdo_intereses    , ms_sdo_dia_ant_int   , ms_sdo_mes_ant_int   ,
    ms_sdo_acum_mes_int , ms_sdo_retenido     , ms_sdo_acum_cap_int  , ms_sdo_exig_int      ,
    ms_sdo_no_exig      , ms_provision_normal , ms_dias_acum_int     , ms_sdo_moratorio     ,
	ms_sdo_dia_ant_mor  , ms_sdo_mes_ant_mor  , ms_sdo_contab_mora   , ms_dias_acum_mora    ,
    ms_sdo_capital      , ms_sdo_cap_insoluto , ms_sdo_dia_ant_cap   , ms_sdo_mes_ant_cap   ,
    ms_sdo_acum_mes_cap , ms_mto_capitalizado , ms_mto_ministra_cap  , ms_cargos_dia_cap    ,
	ms_abonos_dia_cap   , ms_cargos_mes_cap   , ms_abonos_mes_cap    , ms_dias_acum_cap     ,
    ms_monto_vencido    , ms_mto_venc_trasp   , ms_monto_financiado  , ms_monto_reservado   ,
    ms_sdo_acum_vencido , ms_dias_acum_intper , ms_sdo_global_int    , ms_sdo_acum_intper   ,
	ms_monto_otorgado   , ms_provi_venc_normal, ms_provi_venc_anticip, ms_cap_tras_no_venci ,
    ms_mto_venc_int     , ms_mto_venc_tra_int , ms_mto_finan_vdo     , ms_mto_reser_int     ,
    ms_mto_fin_ven_trasp, ms_mto_fin_vig_trasp, ms_int_tra_no_exig   , ms_sdo_trab4 ,ms_atr
	FROM "informix".sd_maesdosrevcrd
	WHERE folio = o_folio ;

	INSERT INTO sd_maesdoscrd
	VALUES  (ms_empresa          , ms_num_credito      , ms_fecha_ult_mov     , ms_sdo_int_anticip   ,
	ms_sdo_int_ant_dev  , ms_sdo_intereses    , ms_sdo_dia_ant_int   , ms_sdo_mes_ant_int   ,
	ms_sdo_acum_mes_int , ms_sdo_retenido     , ms_sdo_acum_cap_int  , ms_sdo_exig_int      ,
    ms_sdo_no_exig      , ms_provision_normal , ms_dias_acum_int     , ms_sdo_moratorio     ,
	ms_sdo_dia_ant_mor  , ms_sdo_mes_ant_mor  , ms_sdo_contab_mora   , ms_dias_acum_mora    ,
    ms_sdo_capital      , ms_sdo_cap_insoluto , ms_sdo_dia_ant_cap   , ms_sdo_mes_ant_cap   ,
    ms_sdo_acum_mes_cap , ms_mto_capitalizado , ms_mto_ministra_cap  , ms_cargos_dia_cap    ,
	ms_abonos_dia_cap   , ms_cargos_mes_cap   , ms_abonos_mes_cap    , ms_dias_acum_cap     ,
    ms_monto_vencido    , ms_mto_venc_trasp   , ms_monto_financiado  , ms_monto_reservado   ,
    ms_sdo_acum_vencido , ms_dias_acum_intper , ms_sdo_global_int    , ms_sdo_acum_intper   ,
	ms_monto_otorgado   , ms_provi_venc_normal, ms_provi_venc_anticip, ms_cap_tras_no_venci ,
    ms_mto_venc_int     , ms_mto_venc_tra_int , ms_mto_finan_vdo     , ms_mto_reser_int     ,
    ms_mto_fin_ven_trasp, ms_mto_fin_vig_trasp, ms_int_tra_no_exig   , ms_sdo_trab4, ms_atr);

	{
	-- RECUPERA DETCOMI
	FOREACH
	SELECT empresa    , cod_comis, num_credito, fecha_alta, fecha_pago   ,
	       monto_com  , monto_pag, apli_factor, estado_com, num_solicitud,
	       user_insert, fecha_insert
	INTO dc_empresa   ,  dc_cod_comis    , dc_num_credito, dc_fecha_alta ,
	       dc_fecha_pago,  dc_monto_com    , dc_monto_pag  , dc_apli_factor,
	       dc_estado_com,  dc_num_solicitud, dc_user_insert,
	       dc_fecha_insert
	FROM "informix".sd_detcomirev
	WHERE folio = o_folio
	ORDER BY fecha_alta

		let o_folio=trim(o_folio);
		
		INSERT INTO sd_detcomi
		(empresa, cod_comis, num_credito, fecha_alta,
		fecha_pago, monto_com, monto_pag,
		apli_factor, estado_com, num_solicitud,
		user_insert, fecha_insert)
		VALUES(dc_empresa, dc_cod_comis, dc_num_credito, dc_fecha_alta,
		dc_fecha_pago, dc_monto_com, dc_monto_pag,
		dc_apli_factor, dc_estado_com, dc_num_solicitud,
		dc_user_insert, dc_fecha_insert);
	END FOREACH;

	}
	-- Recupera Amortiza Credito
	FOREACH
	     SELECT empresa           , num_credito       , fecha_cuota       , tipo_cuota         ,
	            capital_mto_cuota , capital_debe      , capital_pagado    , capital_status     ,
                capital_status_ant, capital_fecha_pago, interes_debe      , interes_pagado     ,
                interes_status    , interes_status_ant, interes_fecha_pago, iva_debe           ,
                iva_pagado        , iva_status        , iva_status_ant    , iva_fecha_pago     ,
	            mora_provi_ordi   , mora_provi_cope   , mora_sdo_ordi     , mora_sdo_ordi_pag  ,
                mora_sdo_cope     , mora_sdo_cope_pag , mora_bonificado   , mora_status        ,
                mora_iva_debe     , mora_iva_pagado   , mora_iva_status   , mora_iva_fecha_pago,
                num_pago          , campo_trabajo1    , campo_trabajo2    , campo_trabajo3     ,
		        campo_trabajo4
	   INTO am_empresa           , am_num_credito       , am_fecha_cuota       , am_tipo_cuota        ,
		    am_capital_mto_cuota , am_capital_debe      , am_capital_pagado    , am_capital_status    ,
            am_capital_status_ant, am_capital_fecha_pago, am_interes_debe      , am_interes_pagado    ,
            am_interes_status    , am_interes_status_ant, am_interes_fecha_pago, am_iva_debe          ,
            am_iva_pagado        , am_iva_status        , am_iva_status_ant    , am_iva_fecha_pago    ,
            am_mora_provi_ordi   , am_mora_provi_cope   , am_mora_sdo_ordi     , am_mora_sdo_ordi_pag ,
            am_mora_sdo_cope     , am_mora_sdo_cope_pag , am_mora_bonificado   , am_mora_status       ,
		    am_mora_iva_debe     , am_mora_iva_pagado   , am_mora_iva_status   , am_mora_iva_fecha_pago,
            am_num_pago          , am_campo_trabajo1    , am_campo_trabajo2    , am_campo_trabajo3     ,
            am_campo_trabajo4
	   FROM "informix".sd_amortiza_creditorevcrd
           WHERE folio = o_folio 
           ORDER BY fecha_cuota

		INSERT INTO sd_amortiza_creditocrd
		VALUES(
	        am_empresa           , am_num_credito       , am_fecha_cuota       , am_tipo_cuota        ,
		    am_capital_mto_cuota , am_capital_debe      , am_capital_pagado    , am_capital_status    ,
            am_capital_status_ant, am_capital_fecha_pago, am_interes_debe      , am_interes_pagado    ,
            am_interes_status    , am_interes_status_ant, am_interes_fecha_pago, am_iva_debe          ,
            am_iva_pagado        , am_iva_status        , am_iva_status_ant    , am_iva_fecha_pago    ,
            am_mora_provi_ordi   , am_mora_provi_cope   , am_mora_sdo_ordi     , am_mora_sdo_ordi_pag ,
            am_mora_sdo_cope     , am_mora_sdo_cope_pag , am_mora_bonificado   , am_mora_status       ,
		    am_mora_iva_debe     , am_mora_iva_pagado   , am_mora_iva_status   , am_mora_iva_fecha_pago,
            am_num_pago          , am_campo_trabajo1    , am_campo_trabajo2    , am_campo_trabajo3     ,
            am_campo_trabajo4);
	END FOREACH

	--** Recupera Maecred Anexo **--
	SELECT {+INDEX ("informix".sd_maecredanexorevcrd )}
	empresa          , num_credito         , dia_corte          , localidad         ,
	dias_gracia_mora , tp_dias_calc_mora   , dias_fecha_max_pago, tp_dias_fecha_pago,
	cod_tasa_base_cte, factor_sobretasa_cte, sobretasa_cte      , tasa_interes_cte  ,  
	fecha_vencto     , prox_fecha_pago     ,  fecha_proceso     ,     fecha_ult_pago,
	nombre_pres
	INTO mx_empresa          , mx_num_credito         , mx_dia_corte          , mx_localidad          ,
	mx_dias_gracia_mora , mx_tp_dias_calc_mora   , mx_dias_fecha_max_pago, mx_tp_dias_fecha_pago ,
	mx_cod_tasa_base_cte, mx_factor_sobretasa_cte, mx_sobretasa_cte      , mx_tasa_interes_cte   , 
	mx_fecha_vencto     , mx_prox_fecha_pago     , mx_fecha_proceso      , mx_fecha_ult_pago,
	mx_nombre_pres
	FROM "informix".sd_maecredanexorevcrd   
	WHERE folio = o_folio ;

	INSERT INTO sd_maecredanexocrd
	VALUES (mx_empresa          , mx_num_credito         , mx_localidad, mx_dia_corte,
	mx_dias_gracia_mora , mx_tp_dias_calc_mora   , mx_dias_fecha_max_pago, mx_tp_dias_fecha_pago ,
	mx_cod_tasa_base_cte, mx_factor_sobretasa_cte, mx_sobretasa_cte      , mx_tasa_interes_cte   , 
	mx_fecha_vencto     , mx_prox_fecha_pago     , mx_fecha_proceso      , mx_fecha_ult_pago,
	mx_nombre_pres,mx_cat);
	
	--CAX 2025 se agrega tabla sd_linea_prestamo para los prestamos flexibles(6800)
	IF 	mc_num_producto = '6800' THEN
		SELECT empresa,num_credito,monto_linea,fecha_otorga,linea_disponible,sec_credito,fecha_cancela,fecha_ult_mod,
		disposicion_activada,fecha_ult_pf,cancel_pf,fecha_venc_linea,acepto_incremento,linea_prestamo_anterior
		INTO lp_empresa,lp_num_credito,lp_monto_linea,lp_fecha_otorga,lp_linea_disponible,lp_sec_credito,lp_fecha_cancela,lp_fecha_ult_mod,
		lp_disposicion_activada,lp_fecha_ult_pf,lp_cancel_pf,lp_fecha_venc_linea,lp_acepto_incremento,lp_linea_prestamo_anterior
		FROM "informix".sd_linea_prestamorev
		WHERE folio = o_folio;
		
		INSERT INTO "informix".sd_linea_prestamo
		VALUES(lp_empresa,lp_num_credito,lp_monto_linea,lp_fecha_otorga,lp_linea_disponible,lp_sec_credito,lp_fecha_cancela,lp_fecha_ult_mod,
		lp_disposicion_activada,lp_fecha_ult_pf,lp_cancel_pf,lp_fecha_venc_linea,lp_acepto_incremento,lp_linea_prestamo_anterior);
	END IF;
	
        -- Revisa su Hubo recuperacion de Linea Transaccion 008 ref 1

	SELECT NVL(sum(monto),0) INTO vmonto_linea 
	FROM "informix".sd_movdiacrd
	WHERE folio_suc = o_folio
	AND   codigo_fun = "008"
	AND   codigo_ref = 1
	AND   reversado != "S";
	
	IF vmonto_linea > 0 THEN
		UPDATE sd_ctegpo SET linea_util = linea_util + vmonto_linea
		WHERE  numcte = mc_numcte
		AND    tp_linea = "R";
	
		UPDATE sd_ctepro SET linea_util = linea_util + vmonto_linea
		WHERE  numcte = mc_numcte
		AND    tp_linea = "R";
	END IF 
	
	--EM 21/03/2017 se modifica para que realice reverso automatico
	IF o_tiporev = 'M' THEN
		SELECT b.num_credito  
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND b.folio_suc = o_folio;

		DELETE FROM bdicred:"informix".sd_pago_anticipado_cs WHERE folio_suc = o_folio;

		Let cNumCreditoPromo = cNumCreditoPromo;

		-- Recupera PROMOCION CREDITO	  -- DSB TH 07/02/2017
		IF EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito_rev 
		WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio) THEN
			
			-- modifica credisolucion
			-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
			update bdicred: "informix".sd_promocion_credito a set 
			a.monto_actual = (select b.monto_actual from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio),
			a.monto_int_iva = (select b.monto_int_iva from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.mensualidad = (select b.mensualidad from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.status = (select b.status from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio)
			where a.empresa = o_empresa and a.num_sol_prestamo = cNumCreditoPromo ;

			-- borra respaldo de credisolucion para reverso 
			DELETE FROM bdicred: "informix".sd_promocion_credito_rev WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio;
		END IF;
					  
	ELSE
		IF EXISTS (SELECT b.num_credito  FROM bdicred:"informix".sd_promocion_credito a,
		bdicred:"informix".sd_pago_anticipado_cs b
		WHERE a.num_sol_prestamo = b.num_credito
		AND a.empresa = b.empresa
		AND b.folio_suc = o_folio
		AND a.folio_movto = cFolioMovto)
		THEN

			DELETE FROM bdicred:"informix".sd_pago_anticipado_cs WHERE folio_suc = o_folio;
		END IF;

		SELECT num_sol_prestamo
		INTO cNumCreditoPromo
		FROM bdicred:"informix".sd_promocion_credito 
		WHERE empresa = o_empresa
		AND folio_movto = cFolioMovto;

		-- Recupera PROMOCION CREDITO
		IF EXISTS (SELECT num_sol_prestamo FROM bdicred: "informix".sd_promocion_credito_rev 
		WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_movto = cFolioMovto AND folio_suc_mov_crd = o_folio) THEN
			-- modifica credisolucion
			-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO

			update bdicred: "informix".sd_promocion_credito a set 
			a.monto_actual = (select b.monto_actual from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio),
			a.monto_int_iva = (select b.monto_int_iva from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.mensualidad = (select b.mensualidad from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio), 
			a.status = (select b.status from bdicred: "informix".sd_promocion_credito_rev b where b.empresa= a.empresa and b.num_sol_prestamo = a.num_sol_prestamo AND b.folio_suc_mov_crd = o_folio)
			where a.empresa = o_empresa and a.num_sol_prestamo = cNumCreditoPromo and a.folio_suc_mov_crd = o_folio;

			-- borra respaldo de credisolucion para reverso 
			DELETE FROM bdicred: "informix".sd_promocion_credito_rev WHERE empresa = o_empresa and num_sol_prestamo = cNumCreditoPromo AND folio_suc_mov_crd = o_folio AND folio_movto = cFolioMovto;
		END IF;
	END IF
	  
	----------------------------------------------------------
	--    Reversio DE   sd_maeretenido                  --
	----------------------------------------------------------
	SELECT folio_suc, num_credito, folio_movto
	INTO c_Folio_Suc, cNumCredito, cfolio_mov
	FROM bdicred: "informix".sd_promocion_credito 
	WHERE  empresa= o_empresa
	and num_sol_prestamo = cNumCreditoPromo;
			
	IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R') THEN
	
		SELECT MAX (secuencia) 
		INTO iSecuencia
		FROM bdicred: "informix".sd_maeretenido_rev
		WHERE empresa = '001' 
		AND num_credito = cNumCredito
		AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
		AND nvl(substr(referencia,18,3),'') = 'PAG'
		AND estatus = 'R';
			
		DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R';
					
		INSERT INTO bdicred: "informix".sd_maeretenido
		(empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
		SELECT
		empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
		FROM bdicred: "informix".sd_maeretenido_rev
		WHERE empresa = '001'
		AND num_credito = cNumCredito
		AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
		AND nvl(substr(referencia,18,3),'') = 'PAG'
		AND estatus = 'R'
		AND secuencia = iSecuencia;	
				
		DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'PAG' AND estatus = 'R'  AND secuencia = iSecuencia;
		
	END IF;
		
		
	SELECT substr(folio_movto,1,1)
	INTO cInFolMov
	FROM bdicred: "informix".sd_promocion_credito 
	WHERE  empresa= 001
	and num_sol_prestamo = cNumCreditoPromo;
		
			
	IF (nvl(substr(cInFolMov,1,1),'') <> '0') AND (nvl(substr(cInFolMov,1,1),'') <> '1') AND (nvl(substr(cInFolMov,1,1),'') <> '2') AND (nvl(substr(cInFolMov,1,1),'') <> '3') AND (nvl(substr(cInFolMov,1,1),'') <> '4') AND (nvl(substr(cInFolMov,1,1),'') <> '5') AND (nvl(substr(cInFolMov,1,1),'') <> '6') AND (nvl(substr(cInFolMov,1,1),'') <> '7') AND (nvl(substr(cInFolMov,1,1),'') <> '8') AND (nvl(substr(cInFolMov,1,1),'') <> '9') THEN

		IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			
			SELECT MAX (secuencia) 
			INTO iSecuencia
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001' 
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc 
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R';
					
			DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
				
			INSERT INTO bdicred: "informix".sd_maeretenido
					 (empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
			SELECT
					  empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001'
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = c_Folio_Suc
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R'
			AND secuencia = iSecuencia;	
				
			DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = c_Folio_Suc AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R'  AND secuencia = iSecuencia;
		
		END IF;
	ELSE
		IF EXISTS (SELECT referencia FROM bdicred: "informix".sd_maeretenido_rev 	WHERE  empresa= '001'	AND num_credito = cNumCredito  AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R') THEN
			SELECT MAX (secuencia) 
			INTO iSecuencia
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001' 
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov 
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R';
					
			DELETE FROM bdicred: "informix".sd_maeretenido WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R';
				
			INSERT INTO bdicred: "informix".sd_maeretenido
					 (empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori)
			SELECT
					  empresa, num_credito,folio_suc,fecha,hora,transacc,dias_ret,monto,usuario,estatus,referencia,sucursal,dias_ori
			FROM bdicred: "informix".sd_maeretenido_rev
			WHERE empresa = '001'
			AND num_credito = cNumCredito
			AND nvl(substr(referencia,1,16),'') = cfolio_mov
			AND nvl(substr(referencia,18,3),'') = 'RET'
			AND estatus = 'R'
			AND secuencia = iSecuencia;	
				
			DELETE FROM bdicred: "informix".sd_maeretenido_rev WHERE empresa = '001' AND num_credito = cNumCredito AND nvl(substr(referencia,1,16),'') = cfolio_mov AND nvl(substr(referencia,18,3),'') = 'RET' AND estatus = 'R'  AND secuencia = iSecuencia;
			
		END IF;		
	END IF;
	
	-- MARCA COMO REVERSADA LA TRANSACCION DE ENCABEZADO
	UPDATE sd_movdiacrd SET reversado = "S"
	WHERE  folio_suc = o_folio;
	    
	UPDATE sd_maesdoscrd set sdo_retenido = 0
	WHERE num_credito = sp_num_credito;
	 
	DELETE FROM "informix".sd_secpago
	WHERE folio_suc = o_folio AND num_credito = sp_num_credito;
	
	-- REVERSO sd_amortiza_creditocrd_pago_anticipado A.U
	select count(*) into iAmortiza_count from "informix".sd_amortiza_creditocrd_pago_anticipado where folio_suc = o_folio and reverso = 'N' and num_credito = sp_num_credito;
		
	if (iAmortiza_count >= 1) THEN
		update "informix".sd_amortiza_creditocrd_pago_anticipado set reverso = 'S' where folio_suc = o_folio and reverso = 'N' and num_credito = sp_num_credito;
	end if;

COMMIT WORK;

END
IF (wBegin = "S") THEN
	BEGIN WORK;
END IF;
RETURN v_codret;

END PROCEDURE
DOCUMENT
'Descripcion : se agregan delete y update nesesarios para el manejo de pagos antisipados de credisoluciones',
'Modifico    : Felipe Urias',
'Fecha       : 09/12/2015',
'BD          : bdicred',
'Descripcion : se modifica el manejo de pagos antisipados de credisoluciones',
'Modifico    : 97468789 - Jesus Manuel Bustamante Lujano',
'Fecha       : 20/11/2016',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : se modifica consulta de numero de credito en sd_movdia de credisoluciones por duplicidad de registros',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 07/02/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se modifica para realizar reversion y reversion automatica correctamente, se modifica para reversar PAGOS DIFERIDOS ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : EM 08/03/2017-  EM 24/03/2017 - 27/04/207',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : se modifica para reversar sd_maesdos',
'Modifico    : 95992243 - Trinidad Hernandez',
'Fecha       : 21/04/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se moodifica para que reverse correctamente la tabla maerretenido, se modifica la validacion del campo cInFolMov ',
'Modifico    : 95451706 - Efrain Miranda',
'Fecha       : 05/05/2017 - 10/05/2017',
'BD          : bdicred',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega validacion de la tabla sd_amortiza_creditocrd_pago_anticipado y hace update si existe la condicion.',
'Modifico    : 99806282 - Andrea Mariana Urrea',
'Fecha       : 05/11/2024',
'BD          : bdicred';

CREATE PROCEDURE "informix".sp_credisol_contrata_x_sms(pEmpresa CHAR(3), pOpcion SMALLINT, pNumCel CHAR(20), pfolio_suc CHAR(16), pMonto DECIMAL(14,2), pPlazo CHAR(2) DEFAULT '0')
RETURNING CHAR(5);       -- Codigo de Retorno

	-- pOpcion: 1.-
		-- 1.- Envia SMS de invitacion de contratacion de compra a pagos fijos al cliente.  (PF_SMSSIS1). 
		-- 2.- Recibe respuesta de cliente con palabra "PAGOS".
		-- 3.- Envia SMS de error. (PF_SMSERR1)
		-- 4.- Envia SMS de contratacion correcta a pagos fijos (PF_SMSOK1)
		-- 5.- Recibe palabra "cancelar" del cliente para cancelar la compra inmediata	


	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE cErrorInfo			CHAR(80);
    DEFINE cCodRet				CHAR(5);
	DEFINE cCodRet_Aux 			CHAR(6);
	DEFINE cCod_retIB			CHAR(6);
    DEFINE cMensajeRet			CHAR(80);
    DEFINE cMensajeRetAux		CHAR(80);
	DEFINE cProceso             CHAR(4);
	DEFINE dtFechaHoy			DATE;
	DEFINE cNumCredito          CHAR(20);
	DEFINE cNumCredisolucion	CHAR(20);
	DEFINE cNumCte				CHAR(20);
	DEFINE cNumCredAux          CHAR(20);
	DEFINE cNumCteAux          	CHAR(20);	
	DEFINE dFecha_Apertura		DATE;
	DEFINE cSucursal			CHAR(4);
	DEFINE dMontoCompra			DECIMAL(18,6);
	DEFINE cNumTarjeta			CHAR(16);
	DEFINE sValido 				SMALLINT;
	DEFINE sNumPromocion		SMALLINT;
	DEFINE sMensualidad			SMALLINT;
	DEFINE sTipoSms				CHAR(1);
	DEFINE sTipoSmsAux			CHAR(1);
	DEFINE sNumMaxInvitacion	SMALLINT;
	DEFINE sNumInvitacCte		SMALLINT;
	DEFINE dSumMntoComprasCte 	DECIMAL(18,6);
	DEFINE dPorcMaxDisp			DECIMAL(2,2);
	DEFINE cRepCte				CHAR(1);
	DEFINE cNumCel				CHAR(20);
	DEFINE sContador			SMALLINT;
	DEFINE sContador_aux		SMALLINT;	
	DEFINE cSmsRespInmEsp		CHAR(1);
	DEFINE sSecuenciaTdc		SMALLINT;
	-- Variables proyecta 
	DEFINE dMensualidad2_proy 	DECIMAL(18,6);
	DEFINE dIvaInt_proy			DECIMAL(18,6);
	DEFINE sPlazo_proy 			SMALLINT;
	DEFINE dTotPagar_proy		DECIMAL(18,2);
	DEFINE dSdoTdc_proy			DECIMAL(18,2);
	DEFINE cFolProm_proy		CHAR(16);
	DEFINE cNumProm_proy		SMALLINT;
		
	----- Ini variables: sp_consulta_saldos_general.sql-----
	DEFINE cCsg_codigo_ret 				CHAR(6);
	DEFINE cCsg_mensaje_ret 			CHAR(80);
	DEFINE cCsg_num_credito 			CHAR(20);
	DEFINE cCsg_cod_tipcred 			CHAR(2);
	DEFINE dtCsg_fec_origen 			DATE;
	DEFINE dtCsg_fec_prox_pago 			DATE;
	DEFINE dcmCsg_pago_min 				DECIMAL(18,2);
	DEFINE dtCsg_fec_ult_pago 			DATE;
	DEFINE iCsg_plazo 					INTEGER;
	DEFINE iCsg_pagos_realizados 		INTEGER;
	DEFINE dcmCsg_linea_otorgada 		DECIMAL(18,2);
	DEFINE dcmCsg_tasa_interes 			DECIMAL(9,6);
	DEFINE dCsg_tasa_moratorios 		DECIMAL(9,6);
	DEFINE dCsg_monto_sbc 				DECIMAL(14,2);
	DEFINE dcmCsg_cap_vig 				DECIMAL(18,2);
	DEFINE dcmCsg_cap_trans 			DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_exig 			DECIMAL(18,2);
	DEFINE dcmCsg_cap_vdo_no_exig 		DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_cap	 	DECIMAL(18,2);
	DEFINE dcmCsg_int_vig 				DECIMAL(18,2);
	DEFINE dcmCsg_int_vdo 				DECIMAL(18,2);
	DEFINE dcmCsg_int_moratorios 		DECIMAL(18,2);
	DEFINE dcmCsg_int_mes 				DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_int 	DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vig 			DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_vdo 			DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_moratorios	DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_mes 			DECIMAL(18,2);
	DEFINE dcmCsg_sdo_act_total_iva 	DECIMAL(18,2);
	DEFINE dcmCsg_com_pend 				DECIMAL(18,2);
	DEFINE dcmCsg_iva_com 				DECIMAL(18,2);
	DEFINE dcmCsg_sdo_retenido 			DECIMAL(18,2);
	DEFINE dcmCsg_tot_liquidacion 		DECIMAL(18,2);
	DEFINE dcmCsg_int_devengado 		DECIMAL(18,2);
	DEFINE dcmCsg_iva_int_devengado		DECIMAL(18,2);
	DEFINE dcmCsg_linea_disp			DECIMAL(18,2);
	DEFINE dcmCsg_pagos_vdos			DECIMAL(18,2);
	DEFINE cCsg_desc_status_cred		CHAR(60);
	DEFINE iCsg_id_bloqueo_cred			INTEGER;
	DEFINE cCsg_bloqueo_cta 			CHAR(60);
	DEFINE cCsg_id_causa_bloq_cred 		CHAR(3);
	DEFINE cCsg_causa_bloqueo_cta 		CHAR(50);
	DEFINE cCsg_id_sit_esp_cte 			CHAR(75);
	DEFINE iCsg_id_causa_esp_cte 		INTEGER;
	DEFINE cCsg_sit_esp_cte 			CHAR(75);
	DEFINE cCsg_id_sit_esp_cred 		CHAR(1);
	DEFINE iCsg_id_causa_esp_cred 		INTEGER;
	DEFINE cCsg_sit_esp_cred 			CHAR(75);				----	Fin Saldos General
	DEFINE dtotal_pagar_crds			DECIMAL(18,2);			---- 	Ini Creacion credisolucion
	DEFINE dnum_plazo_crds				SMALLINT;
	DEFINE dpago_mensual_crds			DECIMAL(18,2);
	DEFINE dinteres_iva_crds			DECIMAL(18,2);
	DEFINE saldo_tdc_crds				DECIMAL(18,2);
	DEFINE dfolio_promo_crds			CHAR(16);				---- 	Ini Creacion credisolucion
	DEFINE sPlazo						SMALLINT;
	DEFINE cPlazoSMS					CHAR(2);
	DEFINE cPlazoSMS_Inv				CHAR(20);
	DEFINE cPlazoSMS_Inv_Aux			CHAR(20);
	DEFINE cPlazoSMS_Inv_Reverse		CHAR(20);
	DEFINE sTasa						DECIMAL(9,6);
	--DEFINE cTasaSMS						CHAR(5);
	DEFINE cPlazosInvitacion			CHAR(11);
	DEFINE cTasasInvitacion				CHAR(25);
	DEFINE cTasaSMS_Aux					CHAR(5);
	DEFINE cPlazoSMS_Aux				CHAR(2);
	DEFINE cPlazosIndexsms				SMALLINT;
	DEFINE cTasa1						CHAR(5);
	DEFINE cTasa2						CHAR(5);
	DEFINE cTasa3						CHAR(5);
	DEFINE cTasa4						CHAR(5);
	DEFINE cPlazo1						CHAR(2);
	DEFINE cPlazo2						CHAR(2);
	DEFINE cPlazo3						CHAR(2);
	DEFINE cPlazo4						CHAR(2);	
	DEFINE cStatusCred        			CHAR(2);
	DEFINE cMtoVen						DECIMAL(18,2);
	DEFINE dCompImmediata				CHAR(1);
	DEFINE dtFechaIniCamp				DATE;
	DEFINE dtFechaFinCamp				DATE;	
	DEFINE dFechaInvitacion				DATETIME YEAR TO FRACTION(5);
		   
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET iIsamErr			= 0;
	LET cErrorInfo			= '';
	LET cCodRet				= '00000';
	LET cCodRet_Aux			= '000000';
	LET cCod_retIB			= '';
	LET cMensajeRet			= 'PROCESO EXITOSO';
	LET cMensajeRetAux		= '';
	LET cProceso			= '0090';
	LET dtFechaHoy			= DATE(1);
	LET cNumCredito			= '';
	LET cNumCredisolucion	= '';
	LET cNumCte				= '';
	LET cNumCredAux			= '';
	LET cNumCteAux          = '';
	LET dFecha_Apertura		= DATE(1);
	LET	cSucursal			= '';
	LET dMontoCompra		= 0;
	LET cNumTarjeta			= '';
	LET sValido				= 0;
	LET sNumPromocion		= 0;
	LET sMensualidad		= 0;
	LET sTipoSms			= '0';
	LET sTipoSmsAux			= '';
	LET sNumMaxInvitacion	= 0;
	LET sNumInvitacCte		= 0;
	LET dSumMntoComprasCte	= 0;
	LET dPorcMaxDisp		= 0;
	LET cRepCte				= '';
	LET cNumCel				= '';
	LET sContador			= 0;
	LET sContador_aux		= 0;
	LET cSmsRespInmEsp		= 0;
	LET sSecuenciaTdc		= 0;
	-- Variables proyecta prest credisol
	LET dMensualidad2_proy	= 0;
	LET dIvaInt_proy		= 0;
	LET sPlazo_proy			= 0;
	LET dTotPagar_proy		= 0;
	LET dSdoTdc_proy		= 0;
	LET cFolProm_proy		= '';
	LET cNumProm_proy		= 0;
	
	-- Inicio  Variables saldo general
	LET cCsg_codigo_ret 			= '';
	LET cCsg_mensaje_ret 			= '';
	LET cCsg_num_credito 			= '';
	LET cCsg_cod_tipcred 			= '';
	LET dtCsg_fec_origen 			= DATE(1);
	LET dtCsg_fec_prox_pago 		= DATE(1);
	LET dcmCsg_pago_min 			= 0;
	LET dtCsg_fec_ult_pago 			= DATE(1);
	LET iCsg_plazo 					= 0;
	LET iCsg_pagos_realizados 		= 0;
	LET dcmCsg_linea_otorgada 		= 0;
	LET dcmCsg_tasa_interes 		= 0;
	LET dCsg_tasa_moratorios 		= 0;
	LET dCsg_monto_sbc 				= 0;
	LET dcmCsg_cap_vig 				= 0;
	LET dcmCsg_cap_trans 			= 0;
	LET dcmCsg_cap_vdo_exig 		= 0;
	LET dcmCsg_cap_vdo_no_exig 		= 0;
	LET dcmCsg_sdo_act_total_cap 	= 0;
	LET dcmCsg_int_vig 				= 0;
	LET dcmCsg_int_vdo 				= 0;
	LET dcmCsg_int_moratorios 		= 0;
	LET dcmCsg_int_mes 				= 0;
	LET dcmCsg_sdo_act_total_int 	= 0;
	LET dcmCsg_iva_int_vig 			= 0;
	LET dcmCsg_iva_int_vdo 			= 0;
	LET dcmCsg_iva_int_moratorios	= 0;
	LET dcmCsg_iva_int_mes 			= 0;
	LET dcmCsg_sdo_act_total_iva 	= 0;
	LET dcmCsg_com_pend 			= 0;
	LET dcmCsg_iva_com 				= 0;
	LET dcmCsg_sdo_retenido 		= 0;
	LET dcmCsg_tot_liquidacion 		= 0;
	LET dcmCsg_int_devengado 		= 0;
	LET dcmCsg_iva_int_devengado	= 0;
	LET dcmCsg_linea_disp			= 0;
	LET dcmCsg_pagos_vdos			= 0;
	LET cCsg_desc_status_cred		= '';
	LET iCsg_id_bloqueo_cred		= 0;
	LET cCsg_bloqueo_cta 			= '';
	LET cCsg_id_causa_bloq_cred 	= '';
	LET cCsg_causa_bloqueo_cta 		= '';
	LET cCsg_id_sit_esp_cte 		= '';
	LET iCsg_id_causa_esp_cte 		= 0;
	LET cCsg_sit_esp_cte 			= '';
	LET cCsg_id_sit_esp_cred 		= '';
	LET iCsg_id_causa_esp_cred 		= 0;
	LET cCsg_sit_esp_cred 			= '';
	-- Fin Variables saldo general
	LET dtotal_pagar_crds			= 0; 			---- 	Ini Creacion credisolucion
	LET dnum_plazo_crds				= 0;
	LET dpago_mensual_crds			= 0;
	LET dinteres_iva_crds			= 0;
	LET saldo_tdc_crds				= 0;
	LET dfolio_promo_crds			= 0;			---- 	Ini Creacion credisolucion
	LET sPlazo						= 0;
	LET cPlazoSMS					= '';
	LET cPlazoSMS_Inv				= '';
	LET cPlazoSMS_Inv_Aux			= '';
	LET cPlazoSMS_Inv_Reverse		= '';
	LET sTasa						= 0;
	--LET cTasaSMS					= 0;
	LET cPlazosInvitacion			= '';
	LET cTasasInvitacion			= '';
	LET cTasaSMS_Aux				= '';
	LET cPlazoSMS_Aux				= '';
	LET cPlazosIndexsms				= 0;
	LET cTasa1						= '';
	LET cTasa2						= '';
	LET cTasa3						= '';
	LET cTasa4						= '';
	LET cPlazo1						= '';
	LET cPlazo2						= '';
	LET cPlazo3						= '';
	LET cPlazo4						= '';
	LET cStatusCred					= '';
	LET cMtoVen						= 0;
	LET dCompImmediata				= '0';
	LET dtFechaIniCamp				= DATE(1);
	LET dtFechaFinCamp				= DATE(1);
	LET dFechaInvitacion			= DATE(1);
	
	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			--LET cCodRet = '00000';
			LET cCodRet = iSqlErr;
			LET cMensajeRet = cErrorInfo;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||iIsamErr||'-'||cNumCredito, '02') Returning cCod_retIB;
			RETURN cCodRet;
       END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/informix/sp_cred_contrat_x_sms.out';
	--TRACE ON;

	--Se obtiene la fecha de hoy.
	SELECT fecha_hoy INTO dtFechaHoy FROM "informix".sd_fechas WHERE empresa = pEmpresa;
	
	---IF pOpcion <> 1 THEN			-- Solo en la invitacion no manda el numero de celular. Con opcion 1: no se manda celular, se manda credito.
	IF pOpcion in (2, 3, 4) THEN			-- Que no entre en opcion 5: Cancelacion de Compra Inmediata. Ya que no trae folio de compra.

		SELECT count(num_credito) INTO sContador 		--	Valida que el folio de compra sea valido. Y no se tenga respuesta previa del cliente
		  FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = pfolio_suc;

		IF sContador = 0 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_FOLIOERR','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

			LET cCodRet = '00000';
			LET cMensajeRet = 'Folio no valido';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;

		IF sContador = 1 THEN			-- Solo existe un folio registrado en la tabla				
			SELECT num_credito, tipo_sms INTO cNumCredAux, sTipoSms
			  FROM bdicred:sd_promocion_credito_sms WHERE folio_compra_sms = pfolio_suc;
			  
		ELSE							-- El folio puede repetirse, pero no repetira folio + num_credito. Se busca credito de ultimo cliente con ese folio de compra (celular).
		
			SELECT MAX(fecha_actualiza), count(*) INTO dFechaInvitacion, sContador_aux FROM bdinteg:si_telefonos WHERE telefono = pNumCel and status_tel='A';
			IF nvl(dFechaInvitacion, date(1)) = date(1) AND sContador_aux = 1 THEN		-- Solo existe un registro del telefono seleccionado
				SELECT numcte INTO cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNumCel AND tipo_tel = '2' and status_tel='A';
			ELSE																		-- Tiene mas de un registro el telefono.
				SELECT limit 1 numcte INTO cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNumCel AND tipo_tel = '2' AND fecha_actualiza = dFechaInvitacion and status_tel='A';
			END IF;			
				
				SELECT b.num_credito INTO cNumCredito 
				FROM bdicred:sd_maecred b 
				INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc' and b.numcte = cNumCte)
				WHERE b.status_cred in ('E1','E2','E3');
				SELECT num_credito, tipo_sms INTO cNumCredAux, sTipoSms FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
		END IF;		

		-- Obtiene el numero de credito ligado al telefono.
		SELECT a.numcte, b.num_credito, b.fecha_apertura, b.sucursal, b.status_cred, NVL(e.monto_vencido + e.mto_venc_trasp,0)
		  INTO cNumCte,  cNumCredito  , dFecha_Apertura , cSucursal,  cStatusCred, cMtoVen
		  FROM bdinteg:si_telefonos a
		 INNER JOIN bdicred:sd_maecred b ON ( a.empresa = b.empresa and b.num_credito = cNumCredAux and a.numcte = b.numcte)
		 INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc')
		 INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito)
		 WHERE telefono = pNumCel
		   AND tipo_tel = 2		   --AND verificado = 'V'
		   AND status_tel = 'A';
		   
		IF sTipoSms = '3' AND (nvl(cNumCredito, '') = '' OR nvl(cNumCte, '') = '') THEN	-- No valide el status de Telefono, con compra conciliada
		
			SELECT first 1 a.numcte, b.num_credito, b.fecha_apertura, b.sucursal, b.status_cred, NVL(e.monto_vencido + e.mto_venc_trasp,0)
			  INTO cNumCte,  cNumCredito  , dFecha_Apertura , cSucursal,  cStatusCred, cMtoVen
			  FROM bdinteg:si_telefonos a
			 INNER JOIN bdicred:sd_maecred b ON ( a.empresa = b.empresa and b.num_credito = cNumCredAux and a.numcte = b.numcte)
			 INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc')
			 INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito)
			 WHERE telefono = pNumCel
			   AND tipo_tel = 2; -- AND verificado = 'V' AND status_tel = 'A';
		END IF;	   
	
		IF nvl(cNumCredito, '') = '' OR nvl(cNumCte, '') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no tiene relacion con credito alguno ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||pNumCel||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Obtiene el numero de tarjeta
		SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
		 
		SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;
		
		IF sTipoSms = '3' AND NVL(cNumTarjeta,'') = '' THEN	-- Si ya esta conciliada no consulte estatus de TDC
			SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
			 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T';
			SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
			 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND secuencia = sSecuenciaTdc;		
		END IF;	 
		
		IF NVL(cNumTarjeta,'') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Numero de Tarjeta invalido. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		SELECT count(num_credito) INTO sContador 		--	Valida que el folio de compra sea valido. Y no se tenga respuesta previa del cliente
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;

		IF sContador != 1 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_FOLIOERR','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

			LET cCodRet = '00000';
			LET cMensajeRet = 'Folio no valido para el credito';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
	END IF;

	-- Obtiene el identificador del cliente para identificar si es prospectos para Pagos Fijos SMS Compra Immediata.
	SELECT NVL(envio_inv_sms,'0') INTO dCompImmediata FROM bdicred:sd_prospectos WHERE num_promo = 8 AND num_credito = pNumCel;	
	LET dCompImmediata = NVL(dCompImmediata,'0');
	
	IF pOpcion = 1 AND dCompImmediata != '2' THEN 	-- 1.- Envia SMS de invitacion de compra a pagos fijos al cliente (PF_SMSSIS1). Para cliente NO identificados como COMPRA INMEDIATA

		-- Obtiene el numero de telefono ligado al credito 
		SELECT first 1 a.telefono INTO cNumCel FROM bdinteg:si_telefonos a INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte )
		 WHERE tipo_tel = 2 AND verificado = 'V' AND status_tel = 'A' AND b.num_credito = pNumCel;

		IF NVL(cNumCel, '') = '' THEN
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT 
			 WHERE num_credito = pNumCel AND folio_compra_sms = pfolio_suc AND tipo_sms = '0';	
			LET cCodRet = '00000'; 
			RETURN cCodRet;
		END IF;
		 
		-- Obtiene los datos del credito.
		SELECT num_credito, numcte,  fecha_apertura,  sucursal
		  INTO cNumCredito, cNumCte, dFecha_Apertura, cSucursal
		  FROM bdicred:sd_maecred WHERE num_credito = pNumCel;
		IF nvl(cNumCredito, '') = '' OR nvl(cNumCte, '') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Numero de credito incorrecto ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT 
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc AND tipo_sms = '0';	
			RETURN cCodRet;
		END IF;

		-- Obtiene numero de tarjeta
		SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
		 
		SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;		
	
		-- Obtiene el monto de la compra
		LET dMontoCompra = pMonto;
		
		-- Valida maximo de invitaciones previas del cliente: 3.
		SELECT valor_numerico::SMALLINT INTO sNumMaxInvitacion
		  FROM bdicred:sd_param_campania WHERE empresa = pEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 11;
		-- % de Saldo disponible a no rebasar en invitacion de SMS: 50%.
		SELECT valor_numerico INTO dPorcMaxDisp
		  FROM bdicred:sd_param_campania WHERE empresa = pEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 12;
		-- Obtiene el numero de invitaciones realizadas al cliente.
			-- tipo_sms: 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida
		SELECT NVL(SUM(mnto_compra),0), COUNT(num_credito) INTO dSumMntoComprasCte, sNumInvitacCte
		  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND tipo_sms in ('1','2','3');

		-- Obtiene saldo disponible del credito.	
		SELECT (monto_otorgado - (sdo_cap_insoluto + sdo_retenido)) INTO dcmCsg_linea_disp
		  FROM bdicred:sd_maesdos WHERE num_credito = cNumCredito;
		  
		-- Si ya rebasa el maximo de invitaciones y el registro actual es estatus 0, cancele registro
		SELECT first 1 tipo_sms INTO sTipoSmsAux FROM sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
		  
		-- Validar maximo de 3 invitaciones y q no rebase el 50% de su disponible
		--IF ((sNumInvitacCte >= sNumMaxInvitacion) OR ((dSumMntoComprasCte + pMonto) >= (dcmCsg_linea_disp * dPorcMaxDisp))) THEN
		--IF ((sNumInvitacCte >= sNumMaxInvitacion) OR (dSumMntoComprasCte >= (dcmCsg_linea_disp * dPorcMaxDisp))) THEN
		IF sNumInvitacCte >= sNumMaxInvitacion THEN
			LET cCodRet = '00000';
			--LET cMensajeRet = 'Cliente rebaso maximo de invitaciones o 50% de saldo disponible en lcr.';
			LET cMensajeRet = 'Cliente rebaso maximo de invitaciones.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			IF sTipoSmsAux = '0' THEN		-- Cancela registro en 0.
				UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT 
				 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;	
			END IF;
			RETURN cCodRet;			
		END IF;		

		/*-- Valida que el cliente no tenga una credisolucion (pagos fijos 6900) vigente.   
		LET sContador = 0;
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito WHERE num_credito = cNumCredito AND num_promo in (3,6,9) AND status IN (0,2);
		IF sContador > 0 THEN
			LET cMensajeRet = 'Credito con pagos fijos (credisolucion) vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			-- Envia mensaje sms de error generico.
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;	
			RETURN cCodRet;		
		END IF;*/
		
		
		-- Inicia proyecciones	
		LET sValido = 0;
		FOREACH
			SELECT num_promo INTO sNumPromocion
			  FROM bdicred:sd_promocion 
			 WHERE num_promo in (2,5,8) AND (fechaini_promo <= dtFechaHoy and fechafin_promo >= dtFechaHoy )
			 ORDER BY num_promo DESC
			 
			-- Valida que cliente se encuentre en prospectos para promocion especial:
			IF sNumPromocion = 8 THEN
				SELECT COUNT(num_credito) INTO sContador
				  FROM bdicred:sd_prospectos Where num_promo = sNumPromocion AND num_credito = cNumCredito AND fecha_ini <= dtFechaHoy AND fecha_fin >= dtFechaHoy;
				IF sContador = 0 THEN	 -- Cliente no esta en prospectos. No puede contratar promocion especial (8)
					CONTINUE FOREACH;
				END IF
			END IF;

			LET cPlazosInvitacion = '';	LET cTasasInvitacion  = '';	LET cTasaSMS_Aux  = '';	LET cPlazoSMS_Aux = '';	LET sContador = 0;	LET cPlazoSMS_Inv = '';	LET sValido = 0;	LET cPlazoSMS = '';
			FOREACH
				SELECT plazo, tasa  INTO sPlazo, sTasa
			      FROM bdicred:sd_tasa_plazo_sms WHERE num_promo = sNumPromocion 
				 ORDER BY plazo ASC

				LET cPlazoSMS = to_char(sPlazo);
				LET cTasaSMS_Aux  = lpad(to_char(sTasa),5,'0');
				LET cPlazoSMS_Aux = lpad(to_char(sPlazo),2,'0');
				
				-- Proyecta para la promocion y plazo especificado.
				EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoCompra::char, sPlazo, sTasa, pfolio_suc) INTO
					cCod_retIB, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;
					
				IF cCod_retIB = '00000' THEN
					LET sMensualidad = dMensualidad2_proy;
					LET sValido = 1;			-- Proyeccion correcta. No termina, proyecta todos los plazos - tasas disponibles para el cliente.
					--EXIT FOREACH;
					IF sContador = 0 THEN
						LET cPlazosInvitacion = trim(cPlazoSMS_Aux);
						LET cTasasInvitacion  = trim(cTasaSMS_Aux);
						LET cPlazoSMS_Inv = trim(cPlazoSMS);
					ELSE
						LET cPlazosInvitacion = trim(cPlazosInvitacion) || '-' || trim(cPlazoSMS_Aux);		-- Almacena plazos disponibles al cliente
						LET cTasasInvitacion  = trim(cTasasInvitacion) || '-' || trim(cTasaSMS_Aux);
						LET cPlazoSMS_Inv = trim(cPlazoSMS_Inv) || ', ' || trim(cPlazoSMS);					-- Arma cadena de plazos disponibles para mensaje invitacion
					END IF;
					LET sContador = sContador + 1;
				END IF;
			END FOREACH;
			IF sValido = 1 THEN	-- Si ya proyecto correctamente la campaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±a, termina proyeccion.
				EXIT FOREACH;
			END IF;
		END FOREACH;

		IF sValido = 1 THEN		-- Proyeccion correcta, continua con el proceso.
			IF sContador >= 2 THEN
				LET cPlazoSMS_Inv_Reverse = reverse(trim(cPlazoSMS_Inv));
				LET cPlazosIndexsms = CHARINDEX(',',cPlazoSMS_Inv_Reverse);
				LET cPlazoSMS_Inv_Aux = cPlazoSMS_Inv;
				LET cPlazoSMS_Inv = reverse(SUBSTR(cPlazoSMS_Inv_Reverse, 1,(cPlazosIndexsms - 2))||' o '||SUBSTR(cPlazoSMS_Inv_Reverse,(cPlazosIndexsms + 1),(length(trim(cPlazoSMS_Inv_Reverse)) - cPlazosIndexsms )));
			END IF;				
			
			LET cCod_retIB = '';
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSSIS1','000000000','', '',1, pfolio_suc, cPlazoSMS_Inv, '', '', '', '', '',
					'', '', '', '',cNumCel, dMontoCompra,0,0, 0, 0, current, current) INTO cCod_retIB;
					
			-- Actualiza registro de la invitacion. Solo si se envio correctamente el sms de invitacion
			IF cCod_retIB = '00000' THEN

				UPDATE bdicred:sd_promocion_credito_sms SET num_cte = cNumCte, respuesta_cte_sms = NULL, fecha_resp_cte_sms = NULL, tipo_sms = '1',
						envio_result_sms = NULL, status_envio_r_sms = NULL, num_promo = sNumPromocion, plazo = NULL, num_credisolucion = NULL,
						fecha_cancela = NULL, fecha_env_sms_inv = CURRENT, plazos_invita = cPlazosInvitacion, tasas_invita = cTasasInvitacion
				WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
				
				LET cCodRet = '00000';
				RETURN cCodRet;
			ELSE
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error en el envio de mensaje SMS de invitacion.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			END IF;	
		ELSE		-- Cliente no valido para invitacion. No manda error, solo no manda invitacion
			LET cCodRet = '00000';
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			
		END IF;	
		
		
	ELIF pOpcion = 1 AND dCompImmediata = '2' THEN 	-- Registra contratacion para cliente marcados para campaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±a PAGOS FIJOS SMS COMPRA INMEDIATA

		-- Valida que la campania se encuentre vigente.
		SELECT count(num_promo) INTO sContador FROM bdicred:sd_promocion 
		 WHERE num_promo = 8 AND fechaini_promo <= dtFechaHoy AND fechafin_promo >= dtFechaHoy; 
		IF sContador = 0 THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Fechas de vigencia de campania: Compras Especial no vigentes.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||pNumCel||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' WHERE num_credito = pNumCel AND folio_compra_sms = pfolio_suc;	
			RETURN cCodRet;
		END IF;	

		-- Valida que se encuentren definidos correctamente los rangos de los montos para asignar tasa y plazo
		SELECT nvl(max(monto_fin),0) INTO dSumMntoComprasCte FROM bdicred:sd_tasa_plazo_sms WHERE num_promo = 8;
		LET dSumMntoComprasCte = NVL(dSumMntoComprasCte,0);
		IF dSumMntoComprasCte = 0 THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Rangos de montos no estan definidos correctamente para Compra Inmediata.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||pNumCel||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' WHERE num_credito = pNumCel AND folio_compra_sms = pfolio_suc;	
			RETURN cCodRet;
		END IF;	
		  
		-- Obtiene el numero de telefono ligado al credito 
		SELECT first 1 a.telefono INTO cNumCel FROM bdinteg:si_telefonos a INNER JOIN bdicred:sd_maecred b ON ( a.numcte = b.numcte )
  		 WHERE tipo_tel = 2 AND status_tel = 'A' AND b.num_credito = pNumCel;
		IF NVL(cNumCel, '') = '' THEN
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' 
			 WHERE num_credito = pNumCel AND folio_compra_sms = pfolio_suc AND tipo_sms = '0';	
			LET cCodRet = '00000'; 
			RETURN cCodRet;
		END IF;
		 
		-- Obtiene los datos del credito.
		SELECT num_credito, numcte,  fecha_apertura,  sucursal INTO cNumCredito, cNumCte, dFecha_Apertura, cSucursal 
		  FROM bdicred:sd_maecred WHERE num_credito = pNumCel;
		IF nvl(cNumCredito, '') = '' OR nvl(cNumCte, '') = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Numero de credito incorrecto ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||pNumCel||'-'||pfolio_suc, '02') Returning cCod_retIB;
			UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' 
			 WHERE num_credito = pNumCel AND folio_compra_sms = pfolio_suc AND tipo_sms = '0';	
			RETURN cCodRet;
		END IF;

		-- Obtiene numero de tarjeta
		SELECT max(secuencia) INTO sSecuenciaTdc FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A';
		SELECT first 1 num_tarjeta INTO cNumTarjeta FROM bdicred:"informix".sd_tarjeta 
		 WHERE empresa = '001' AND num_credito = cNumCredito AND tipo_tarjeta = 'T' AND status_tar = 'A' AND secuencia = sSecuenciaTdc;		
	
		-- Valida maximo de invitaciones previas del cliente: 3.
		SELECT NVL(valor_numerico::SMALLINT, 0) INTO sNumMaxInvitacion FROM bdicred:sd_param_campania 
		 WHERE empresa = pEmpresa AND tipo_campania = 2 AND grupo_parametro = 'PAGOSFIJOS' AND num_parametro = 19;
		  
		-- Obtiene las fechas de vigencia de la campania especial
		SELECT fechaini_promo, fechafin_promo INTO dtFechaIniCamp, dtFechaFinCamp
		  FROM bdicred:sd_promocion WHERE num_promo = 8;
		  
		-- Identifica el cliente como cliente prospecto con fechas de vigencia correctas.	
		LET sNumPromocion = 8; 		
		SELECT COUNT(num_credito) INTO sContador
		 FROM bdicred:sd_prospectos Where num_promo = sNumPromocion AND num_credito = cNumCredito AND fecha_ini <= dtFechaHoy AND fecha_fin >= dtFechaHoy;

		SELECT first 1 tipo_sms INTO sTipoSmsAux FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;		 
		 
		IF sContador = 0 THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente prospecto con fechas de vigencia no validas.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			IF sTipoSmsAux = '0' THEN		-- Cancela registro en 0.
				UPDATE sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;	
			END IF;
			RETURN cCodRet;			
		END IF;

		-- Obtiene el numero de invitaciones realizadas al cliente durante el periodo.
			-- tipo_sms: 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 7 SMS con credisolucion
		SELECT COUNT(num_credito) INTO sNumInvitacCte FROM bdicred:sd_promocion_credito_sms 
		 WHERE num_credito = cNumCredito AND tipo_sms in ('1','2','3','7') AND fecha_insert >= dtFechaIniCamp AND fecha_insert <= dtFechaFinCamp;
		
		-- Valida que el cliente no rebase el numero maximo de contrataciones para COMPRA INMEDIATA. Si el limite es cero no se valida.
		IF sNumMaxInvitacion > 0 AND sNumInvitacCte >= sNumMaxInvitacion THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente rebaso maximo de invitaciones PFCI.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			IF sTipoSmsAux = '0' THEN		-- Cancela registro en 0.
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;	
			END IF;
			RETURN cCodRet;			
		END IF;

		-- Obtiene el plazo y tasa de contratacion en base al monto de la compra.
		LET dMontoCompra = pMonto;
		SELECT first 1 plazo, tasa  INTO sPlazo, sTasa 
		FROM bdicred:sd_tasa_plazo_sms WHERE num_promo = 8 AND monto_ini <= dMontoCompra AND monto_fin >= dMontoCompra;
		LET sPlazo = nvl(sPlazo,0);
		IF nvl(sPlazo,0) <= 0 THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Plazos erroneos-' || sPlazo;
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Realiza la proyecion de Pagos Fijos para el plazo y tasa especificados. Si es correcta, se registra la compra.
		EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoCompra, sPlazo, sTasa, pfolio_suc) INTO
				cCodRet_Aux, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;

		IF cCodRet_Aux != '00000' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente no valido para contratar PFCI. Proyeccion erronea';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet_Aux, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '8', fecha_env_sms_inv = CURRENT, compra_inmd = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;	
			RETURN cCodRet;			
		END IF;
				
		LET sMensualidad = dMensualidad2_proy;
		
		LET cCod_retIB = '';
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_COM_INME','000000000','', '',1, sPlazo, round(sTasa,2), '', '', '', '', '',
					'', '', '', '',cNumCel, dMontoCompra, 0, 0, 0, 0, current, current) INTO cCod_retIB;

			-- Actualiza registro de la invitacion. Solo si se envio correctamente el sms de invitacion. (Se marca sms_resp_inmd = '1' para que no envie SMS de respuesta inmediata)
		IF cCod_retIB = '00000' THEN
		
			UPDATE bdicred:sd_promocion_credito_sms SET num_cte = cNumCte, respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, tipo_sms = '2',
					envio_result_sms = NULL, status_envio_r_sms = NULL, num_promo = sNumPromocion, plazo = sPlazo, tasa = sTasa, num_credisolucion = NULL,
					fecha_cancela = NULL, fecha_env_sms_inv = CURRENT, plazos_invita = NULL, tasas_invita = NULL, compra_inmd = '1' , sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			 
			LET cCodRet = '00000';
			RETURN cCodRet;
		ELSE
			LET cCodRet = '00000';
			LET cMensajeRet = 'Error en el envio de mensaje SMS de invitacion.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;			
		END IF;
		

	ELIF pOpcion = 2 THEN			-- 2.- Recibe respuesta de cliente con palabra PAGOSFIJOS + ifolio + plazo


		IF cStatusCred NOT IN ('AA','E1') AND cMtoVen > 0 THEN

			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOSTAER','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

			LET cCodRet = '00000';
			LET cMensajeRet = 'Credito en estatus diferente a vigente. ';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||pNumCel||'-'||pfolio_suc||cStatusCred, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		
		-- Obtiene el monto de la compra. Confirma que el estatus SMS sea de invitacion.
		SELECT mnto_compra,  num_promo,     plazo,  tasa,  tipo_sms, respuesta_cte_sms, NVL(sms_resp_inmd,'0'), num_credisolucion
		  INTO dMontoCompra, sNumPromocion, sPlazo, sTasa, sTipoSms, cRepCte,           cSmsRespInmEsp,         cNumCredisolucion
		  FROM bdicred:sd_promocion_credito_sms 
		 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
		 --WHERE num_credito = cNumCredito AND tipo_sms in ('1','2','3') AND folio_compra_sms = pfolio_suc;
		 
		IF NVL(dMontoCompra,0) = 0 THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
			IF cCod_retIB <> '00000' THEN
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '0' 	-- Se marca para envio de sms de error.
				 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error en envio de SMS de Error. Monto de compra no valido.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '4', envio_result_sms = '0', status_envio_r_sms = '1'	-- Se marca sms enviado
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			LET cCodRet = '00000';
			LET cMensajeRet = 'Monto de compra no valido.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;		
		END IF;
		
		IF NVL(sPlazo, 0) = 0 THEN		-- El campo plazo esta vacio, por lo tanto se obtiene plazo de respuesta del cliente.

			-- Valida que el plazo aceptado se encuentre dentro de las opciones enviadas dentro de la invitacion
			SELECT plazos_invita, tasas_invita INTO cPlazosInvitacion, cTasasInvitacion
			  FROM bdicred:sd_promocion_credito_sms WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			LET pplazo = pplazo;
			
			LET cTasa1 = substr(cTasasInvitacion,1,5);		LET cTasa2 = substr(cTasasInvitacion,7,5);		LET cTasa3 = substr(cTasasInvitacion, 13,5);	LET cTasa4 = substr(cTasasInvitacion, 19,5);
			LET cPlazo1 = substr(cPlazosInvitacion,1,2);	LET cPlazo2 = substr(cPlazosInvitacion,4,2);	LET cPlazo3 = substr(cPlazosInvitacion,7,2);	LET cPlazo4 = substr(cPlazosInvitacion,10,2);

			IF to_number(pPlazo) = to_number(cPlazo1) AND to_number(pPlazo) > 0 THEN
				LET sPlazo = cPlazo1::smallint;
				LET sTasa  = cTasa1::smallint;
			ELIF to_number(pPlazo) = to_number(cPlazo2) AND to_number(pPlazo) > 0 THEN
				LET sPlazo = cPlazo2::smallint;
				LET sTasa  = cTasa2::smallint;	
			ELIF to_number(pPlazo) = to_number(cPlazo3) AND to_number(pPlazo) > 0 THEN
				LET sPlazo = cPlazo3::smallint;
				LET sTasa  = cTasa3::smallint;		
			ELIF to_number(pPlazo) = to_number(cPlazo4) AND to_number(pPlazo) > 0 THEN
				LET sPlazo = cPlazo4::smallint;
				LET sTasa  = cTasa4::smallint;		
			ELSE		-- Manda mensaje de error, ya que envio un plazo no valido

				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_PLAZOER','000000000','', '',1, '', '', '', '', '', '', '','', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Plazo no valido';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc||'-'||pPlazo, '02') Returning cCod_retIB;
				RETURN cCodRet;
				
			END IF;		

			-- Almacena el plazo y tasa contratado por el cliente.
			UPDATE bdicred:sd_promocion_credito_sms SET plazo = sPlazo, tasa = sTasa WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			
		END IF;

		----------------
		-- tipo_sms: 0 Invitacion pendiente por enviar, 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 4 Invit cancelada ERROR Dato Erroneo, 
		--			 5 Invitacion Cancelada X vigencia, 6 Err en credisolucion, 7 SMS con credisolucion, 8 Invitacion no enviada (0 cancelado)
		-- envio_result_sms: 0.- Enviar SMS de Error, 1.- Mensaje sms OK: Se proceso credisolucion o Enviar SMS de invitacion
		-- status_envio_r_sms.- 0.- Msg sms pendiente de enviar, 1.- Msg sms enviado,  			

		IF NVL(sTipoSms,'') = '1' THEN		-- 1.- Invitacion realizada.

			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '2', respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;		-- Actualiza estatus. Falta conciliacion. Se recibio respuesta del cliente.

			 -- Envia sms de "en espera de confirmacion del estatus" al usuario
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
			 
			LET cCodRet = '00000';
			RETURN cCodRet;		

		ELIF NVL(sTipoSms,'') = '2' THEN	-- 2.- Espera conciliacion.
		
			UPDATE bdicred:sd_promocion_credito_sms SET respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT, sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			 
			 -- Envia sms de "en espera de confirmacion del estatus" al usuario
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','', '',1, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
					
			LET cCodRet = '00000';
			RETURN cCodRet;

		ELIF NVL(sTipoSms,'') = '3' THEN 	-- 3 Conciliacion recibida. Solo con la conciliacion de la compra, se genera la credisolucion.

			IF NVL(cRepCte,'') = '' THEN
				UPDATE bdicred:sd_promocion_credito_sms SET respuesta_cte_sms = 'S', fecha_resp_cte_sms = CURRENT		
				 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;			-- Actualiza respuesta, solo si no se ha recibido anteriormente y ya se concilio compra
			END IF;	 
			
			-- Valida saldos antes de generar registro de credisolucion con estatus 0. Si se genera con estatus 0, el proceso nocturno crea credito 6900 aun rebasando saldo
			-- Obtiene saldo general del credito.	
			EXECUTE PROCEDURE "informix".sp_consulta_saldos_general('001',cNumCredito) INTO cCsg_codigo_ret,cCsg_mensaje_ret,cCsg_num_credito,cCsg_cod_tipcred,dtCsg_fec_origen,
				dtCsg_fec_prox_pago,dcmCsg_pago_min,dtCsg_fec_ult_pago,iCsg_plazo,iCsg_pagos_realizados,dcmCsg_linea_otorgada,dcmCsg_tasa_interes,dCsg_tasa_moratorios,
				dCsg_monto_sbc,dcmCsg_cap_vig,dcmCsg_cap_trans,dcmCsg_cap_vdo_exig,dcmCsg_cap_vdo_no_exig,dcmCsg_sdo_act_total_cap,dcmCsg_int_vig,dcmCsg_int_vdo,dcmCsg_int_moratorios,
				dcmCsg_int_mes,dcmCsg_sdo_act_total_int,dcmCsg_iva_int_vig,dcmCsg_iva_int_vdo,dcmCsg_iva_int_moratorios,dcmCsg_iva_int_mes,dcmCsg_sdo_act_total_iva,dcmCsg_com_pend,
				dcmCsg_iva_com,dcmCsg_sdo_retenido,dcmCsg_tot_liquidacion,dcmCsg_int_devengado,dcmCsg_iva_int_devengado,dcmCsg_linea_disp,dcmCsg_pagos_vdos,cCsg_desc_status_cred,
				iCsg_id_bloqueo_cred,cCsg_bloqueo_cta,cCsg_id_causa_bloq_cred,cCsg_causa_bloqueo_cta,cCsg_id_sit_esp_cte,iCsg_id_causa_esp_cte,cCsg_sit_esp_cte,cCsg_id_sit_esp_cred,
				iCsg_id_causa_esp_cred,cCsg_sit_esp_cred;
			IF cCsg_codigo_ret <> '000000' THEN
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error en sp de consulta saldos general.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCsg_codigo_ret, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;				
			END IF;
			
			-- Proyecta para la promocion y plazo especificado a fin de validar que el saldo disponible lo cubra.
			EXECUTE PROCEDURE bdicred:sp_proyecta_pfsms(1, cSucursal, USER, sNumPromocion, cNumCredito, cNumTarjeta, dMontoCompra, sPlazo, sTasa, pfolio_suc) INTO
					cCodRet_Aux, cMensajeRetAux, dTotPagar_proy, sPlazo_proy, dMensualidad2_proy, dIvaInt_proy, dSdoTdc_proy, cFolProm_proy, cNumProm_proy;
			
			--IF dcmCsg_linea_disp < dTotPagar_proy THEN
			IF dcmCsg_linea_disp < dIvaInt_proy THEN	--	 Si saldo disponible NO cubre proyeccion de credisolucion (monto int e iva).
			
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SDOINSF','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
				IF cCod_retIB <> '00000' THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
					 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;				-- Se marca para envio de sms de error.
				ELSE
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '1' 
					 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;				-- Se marca envio sms correcto.
				END IF;			
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error el proyeccion. Saldo de credito no cubre pagos fijos.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet_Aux, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;
			
			IF cCodRet_Aux <> '00000' THEN	-- Proyeccion correcta.
			
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
				IF cCod_retIB <> '00000' THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
					 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;				-- Se marca para envio de sms de error.
				ELSE
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '1' 
					 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;				-- Se marca envio sms correcto.
				END IF;			
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error el proyeccion. Saldo de credito no cubre pagos fijos.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet_Aux, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;
			
				
			-- Genera credisolucion con estatus 0.
			--EXECUTE PROCEDURE sp_proyecta_promo(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoCompra, sPlazo, pfolio_suc)
			EXECUTE PROCEDURE sp_proyecta_pfsms(3, cSucursal, 'informix', sNumPromocion, cNumCredito, '', dMontoCompra, sPlazo, sTasa, pfolio_suc)
			   INTO cCodRet_Aux, cMensajeRet, dtotal_pagar_crds, dnum_plazo_crds, dpago_mensual_crds, dinteres_iva_crds, saldo_tdc_crds, dfolio_promo_crds, cNumProm_proy;
			IF cCodRet_Aux <> '00000' THEN
			
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
				IF cCod_retIB <> '00000' THEN
					UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '0' 
					 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;										-- Se marca para envio de sms de error.
					LET cCodRet = '00000';
					LET cMensajeRet = 'Error en envio de SMS de Error. Error en generar credisolucion.';
					CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet_Aux, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
					RETURN cCodRet;
				END IF;

				-- Se marca sms enviado. Error en generacion de credisolucion
				UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '6', envio_result_sms = '0', status_envio_r_sms = '1'	-- Se marca sms enviado
				WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error en generar credisolucion.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet_Aux, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;		
			END IF;
			
			-- Se marca pendiente de enviar SMS de confirmacion, hasta que el proceso de credisoluciones marque el registro como que se proceso OK y se enviara mensaje.
			-- Credisolucion en este punto es de status = 0, no se ha generado credito 6900.
			UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '7', envio_result_sms = NULL, status_envio_r_sms = NULL, sms_resp_inmd = '1'
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			 
			 IF NVL(cSmsRespInmEsp, '0') = '0' THEN			-- En esta opcion, solo envia sms si no se a enviado anteriormente. Proceso nocturno pasa por aqui	
			 
				 -- Envia sms de "en espera de confirmacion del estatus" al usuario
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;			 
			END IF;	 
			
			----------------
			-- tipo_sms: 0 Invitacion pendiente por enviar,, 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 4 Invit cancelada ERROR Dato Erroneo, 
			--			 5 Invitacion Cancelada X vigencia, 6 Err en credisolucion, 7 SMS con credisolucion, 8 Invitacion no enviada (0 cancelado)
			-- envio_result_sms: 0.- Enviar SMS de Error, 1.- Mensaje sms OK: Se proceso credisolucion o Enviar SMS de invitacion
			-- status_envio_r_sms.- 0.- Msg sms pendiente de enviar, 1.- Msg sms enviado,  			

		ELIF NVL(sTipoSms,'') = '7' THEN -- Si esta en 7, no actualice y solo envie sms de respuesta inmediata
		
			IF NVL(cNumCredisolucion, '') = '' THEN
				-- Envia sms de respuesta inmediata.
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSESP','000000000','', '',1, '', '', '', '', '', '', '',
									'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
			ELSE
				SELECT monto_actual, mensualidad, plazo, to_char(plazo), num_sol_prestamo 
				  INTO dMontoCompra, sMensualidad, sPlazo, cPlazoSMS, cNumCredisolucion
				  FROM bdicred:sd_promocion_credito WHERE status = 2 AND num_credito = cNumCredito AND folio_movto = pfolio_suc;
				SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCredisolucion;

				-- Existe credisolucion, envie sms de confirmacion
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSOK1','000000000','', '',1, pfolio_suc, cPlazoSMS, '', '', '', '', '',
						'', '', '', '',pNumCel, dMontoCompra, sMensualidad, 0, sTasa, 0, current, current) INTO cCod_retIB;
			END IF;
		 
		ELIF NVL(sTipoSms,'') = '5' THEN -- Si esta en 5, ya fue cancelada por termino de vigencia.

			-- Envia sms de rechazo por vencimiento de vigencia de la invitacion.
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_INVNVIG','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

		
		ELSE		-- Cualquier otro tipo_sms, envie respuesta de error, ya que el cliente envio sms. No se actualiza: tipo_sms
		
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','', '',1, '', '', '', '', '', '',
						'', '', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;
			IF cCod_retIB <> '00000' THEN
				-- Se marca para envio de sms de error en batch.
				UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '0' WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
				LET cCodRet = '00000';
				LET cMensajeRet = 'Error en envio de SMS de Error. Estatus SMS no valido para recibir respuesta.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;				
			-- Se marca sms enviado
			UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '1' WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			LET cCodRet = '00000';
			LET cMensajeRet = 'Estatus SMS no valido para recibir respuesta.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pfolio_suc, '02') Returning cCod_retIB;
			RETURN cCodRet;		
		END IF;

	ELIF pOpcion = 3 THEN	-- 3.- Envia SMS de error. (PF_SMSERR1)

		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSERR1','000000000','', '',2, '', '', '', '', '', '', '',
					'', '', '', '',pNumCel, 0, 0,0, 0, 0,current, current) INTO cCod_retIB;

		IF cCod_retIB <> '00000' THEN
			UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '0'	-- Se marca sms pendiente de enviar
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
			LET cCodRet = '00001';
			LET cMensajeRet = 'Error en envio de SMS de Error';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '0', status_envio_r_sms = '1'	-- Se marca sms enviado
		 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;		

	ELIF pOpcion = 4 THEN	-- 4.- Envia SMS de contratacion correcta a pagos fijos (PF_SMSOK1)

		SELECT monto_actual, mensualidad, plazo, to_char(plazo), num_sol_prestamo 
		  INTO dMontoCompra, sMensualidad, sPlazo, cPlazoSMS, cNumCredisolucion
		  FROM bdicred:sd_promocion_credito WHERE status = 2 AND num_credito = cNumCredito AND folio_movto = pfolio_suc;

		SELECT tasa_interes INTO sTasa FROM bdicred:sd_maecredcrd WHERE num_credito = cNumCredisolucion;

		IF nvl(cNumCredisolucion,'') <> '' THEN
		
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_SMSOK1','000000000','', '',2, pfolio_suc, cPlazoSMS, '', '', '', '', '',
						'', '', '', '',pNumCel, dMontoCompra, sMensualidad, 0, sTasa, 0, current, current) INTO cCod_retIB;
						
			IF cCod_retIB <> '00000' THEN
				UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '1', status_envio_r_sms = '0'	-- Se marca sms pendiente de enviar
				 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;
				LET cCodRet = '00002';
				LET cMensajeRet = 'Error en envio de SMS de contratacion correcta.';
				CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCod_retIB, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
				RETURN cCodRet;
			END IF;
			-- Se marca sms enviado y numero  de credisolucion generada.
			UPDATE bdicred:sd_promocion_credito_sms SET envio_result_sms = '1', status_envio_r_sms = '1', num_credisolucion = cNumCredisolucion	
			 WHERE num_credito = cNumCredito AND folio_compra_sms = pfolio_suc;		
			 
		END IF;

	ELIF pOpcion = 5 THEN			-- Cancela las contrataciones de Pagos Fijos SMS Compra Inmediata.
		
		SELECT first 1 nvl(telefono,'0'), nvl(numcte, '') INTO cNumCel, cNumCte FROM bdinteg:si_telefonos WHERE telefono = pNumCel;
		IF cNumCel = '0' OR cNumCte = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			--
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;			
		END IF;
		
		-- Obtiene el numero de credito ligado al telefono.
		SELECT nvl(b.num_credito,''), b.fecha_apertura, b.sucursal, b.status_cred
		  INTO cNumCredito  , dFecha_Apertura , cSucursal,  cStatusCred
		  FROM bdicred:sd_maecred b 
          INNER JOIN bdicred:sd_definicion d ON (b.num_producto = d.num_producto and d.edocta_param = 'tdc' )
		  INNER JOIN bdicred:sd_maesdos e ON (b.num_credito = e.num_credito and (e.monto_vencido + e.mto_venc_trasp) = 0)
		 WHERE b.numcte = cNumCte
		   and b.status_cred IN ('AA','E1');
		IF cNumCredito = '' THEN
			LET cCodRet = '00000';
			LET cMensajeRet = 'Telefono no registrado a un credito TDC.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			--
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_CINTELER','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;
		
		-- Obtiene las fechas de vigencia de la campaÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ±a especial
		SELECT fechaini_promo, fechafin_promo INTO dtFechaIniCamp, dtFechaFinCamp
		  FROM bdicred:sd_promocion WHERE num_promo = 8;		
		
		-- Identifica si el cliente tiene compras registradas el dia de hoy.
		SELECT count(num_credito) INTO sContador FROM bdicred:sd_promocion_credito_sms 
		 WHERE num_credito = cNumCredito AND num_promo = 8 AND date(fecha_insert) >= today AND date(fecha_insert) <= today;
		IF sContador = 0 THEN			-- El cliente no tiene registradas invitaciones de compras del dia actual.
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente no tiene registradas invitaciones en el dia.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			--
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_CINNOCAN','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;
		END IF;

		-- Identifica si cliente tiene invitaciones vigentes para cancelar
		SELECT count(num_credito) INTO sContador_aux FROM bdicred:sd_promocion_credito_sms 
		 WHERE num_credito = cNumCredito AND num_promo = 8 AND tipo_sms IN ('0','1','2','3') AND date(fecha_insert) >= today AND date(fecha_insert) <= today;
		IF sContador_aux = 0 THEN			-- El cliente no tiene invitaciones vigentes el dia actual.
			LET cCodRet = '00000';
			LET cMensajeRet = 'Cliente no tiene invitaciones vigentes en el dia.';
			CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, cProceso, cCodRet, trim(cMensajeRet)||'-'||cNumCredito||'-'||pNumCel, '02') Returning cCod_retIB;
			--
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_CINMCANC','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;						
		END IF;
		
		-- Obtiene ultima invitacion realizada.
		SELECT MAX(fecha_insert) INTO dFechaInvitacion FROM bdicred:sd_promocion_credito_sms
		 WHERE num_credito = cNumCredito AND num_promo = 8 AND tipo_sms IN ('0','1','2','3') AND date(fecha_insert) >= today AND date(fecha_insert) <= today;
		 
		SELECT first 1 folio_compra_sms INTO dfolio_promo_crds FROM bdicred:sd_promocion_credito_sms
		 WHERE num_credito = cNumCredito AND num_promo = 8 AND tipo_sms IN ('0','1','2','3') AND fecha_insert = dFechaInvitacion;
		 
		-- Actualiza status a cancelado de ultima invitacion realizada.
		UPDATE bdicred:sd_promocion_credito_sms SET tipo_sms = '5', respuesta_cte_sms = 'N', fecha_resp_cte_sms = CURRENT, fecha_cancela = dtFechaHoy, compra_inmd = '1'
		 WHERE num_credito = cNumCredito AND num_promo = 8 AND folio_compra_sms = dfolio_promo_crds AND fecha_insert = dFechaInvitacion;
		IF iSqlErr != 0 THEN	-- si se actualizo correctamente
			LET cCodRet = '00000';		
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento (2,'SMS_RECI','PF_CINCANOK','000000000','', '',1, '', '', '', '', '', '', '',
						'', '', '', '',pNumCel, 0, 0, 0, 0, 0, current, current) INTO cCod_retIB;
			RETURN cCodRet;						
		END IF
		
	END IF;

	RETURN cCodRet;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso que realiza el envio y recepcion de SMS para la contratacion de Pagos Fijos de una compra realizada por el cliente. ',
'AUTOR: Martha A Hdz ',
'FECHA DE CREACION:  Junio 2018 ',
'BD: bdicred',
' tipo_sms: 0 Invitacion pendiente por enviar, 1 Invitacion realizada, 2 Espera conciliacion, 3 Conciliacion recibida, 4 Invit cancelada ERROR Dato Erroneo, ',
'		    5 Invitacion Cancelada X vigencia, 6 Err en credisolucion, 7 SMS con credisolucion, 8 Invitacion no enviada (0 cancelado)	',
' envio_result_sms: 0.- Enviar SMS de Error, 1.- Mensaje sms OK: Se proceso credisolucion o Enviar SMS de invitacion',
' status_envio_r_sms.- 0.- Msg sms pendiente de enviar, 1.- Msg sms enviado,  									    ';

CREATE PROCEDURE "informix".apercred1_pp_web(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),		-- IMPORTE MENSUAL
			 pFrecuencia    INTEGER --Frecuencia de pago   										
										--1.- Mensual credinomina
										--2.- Quincenal credinomina
			 )
RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--MODIFICO: Angel Anguiano 
--Descripcion: Se libera sp clon de la version de ofi tradicional y se integra el llamado de la tasa definida por one click.
--Fecha: 2023/11/08
--Version: 20231108
--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(5);		-- CODIGO DE RETORNO
DEFINE cCodRet3				VARCHAR(5);		-- CODIGO DE RETORNO ABONOREF BDICHEQ
DEFINE cCodRetTDif			CHAR(5);		-- CODIGO DE RETORNO OBTIENE TASAS DE INTERES DIFERENCIADAS
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mSobreTasa_MORA      DECIMAL(18,2);	-- SOBRETASA MORA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE cFactor_Mora	            CHAR(1);		-- FACTOR MORA
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACION DEL PRESTAMO
DEFINE iSqlErr              INTEGER;		-- CODIGO DE ERROR
DEFINE iIsamError           INTEGER;		-- CODIGO DE ERROR
DEFINE cNumCte              CHAR(20);		-- NUMERO DE CLIENTE
DEFINE cTpCte               CHAR(1);		-- TIPO DE CLIENTE
DEFINE mIngreso             DECIMAL(18,2);	-- INGRESO DEL CLIENTE
DEFINE cFactorFAV           CHAR(1);		-- FACTOR A FAVOR DEL CLIENTE
DEFINE cProducto            CHAR(4);		-- CODIGO DE PRODUCTO
DEFINE cDivisa              CHAR(2);		-- DIVISA
DEFINE cSucursal            CHAR(4);		-- CODIGO DE SUCURSAL
DEFINE cFolio	            CHAR(16);		-- FOLIO PARA GENERACION DE MOVIMIENTOS DIARIOS
DEFINE cMensaje             CHAR(200);		-- MENSAJE MAS NOMBRE DE EJECUTIVO
DEFINE dFechaT              DATE;			-- FECHA DEL MES POSTERIOR A LA APERTURA
DEFINE sDiaCorte            SMALLINT;		-- DIA DE CORTE
DEFINE i		     		SMALLINT;		-- VARIABLE PARA ITERACION
DEFINE mCatIva		    	DECIMAL(18,2);	-- VALOR DEL CAT DEL IVA
DEFINE cMercadeo            CHAR(1);		-- PUBLICACION
DEFINE sSecIngreso 			SMALLINT;		-- SECUENCIA DE INGRESOS

DEFINE mTasaInteresProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE mTasaMoraProd		DECIMAL(18,2);	-- TASA DE INTERES DEL PRODUCTO
DEFINE cPeriodoPag			CHAR(1);		-- PERIODICIDAD DEL PAGO
DEFINE iDiasTraspCap		INTEGER;		-- DIAS PARA TRASPASO DE CAPITAL
DEFINE iDiasTraspInt		INTEGER;		-- DIAS PARA TRASPASO DE INTERESES
DEFINE cNumeroFolio 		CHAR(16);		-- FOLIO PARA REGISTRAR EL ABONO
DEFINE cTransacc 			CHAR(4);	 	-- FOLIO DE TRANSACCION DEL ABONO
DEFINE iNumReg				INTEGER;		-- NUMERO DE REGISTROS DE UNA OPERACION
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERO LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE sDiasPeriodo         SMALLINT;
DEFINE dtDiaprimero         DATE;

DEFINE dtFecha_cargo  DATE;
DEFINE mDispo         MONEY(14,2);
DEFINE mCargo         MONEY(14,2);
DEFINE mIvaComisionApertura   MONEY(14,2);
DEFINE mComisionApertura      MONEY(14,2);
DEFINE dPorcComisionAper      DECIMAL(9,6);
DEFINE cTransaccIvaCargo      CHAR(4);
DEFINE cTransaccCargo         CHAR(4);
DEFINE iContador         	SMALLINT;
DEFINE mTotalPagar			DECIMAL(18,2);

-----------------proyeccion
DEFINE iNum_periodos    INTEGER;
DEFINE dtFecha_cuota    DATE;
DEFINE dSdo_inicial     MONEY(14,2);
DEFINE dPago_mensual    MONEY(14,2);
DEFINE dMto_Interes     MONEY(14,2);
DEFINE dIva_interes     MONEY(14,2);
DEFINE dCapital         MONEY(14,2);
DEFINE dSdo_final       MONEY(14,2);
DEFINE sDias_periodo    SMALLINT;
DEFINE dtFecha_Aper		DATE;
DEFINE iDiaPago      	INTEGER;
DEFINE cNumMesesPagos   CHAR(3);
DEFINE cCodRet2         CHAR(6);
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE vCatFinal        DECIMAL(21,10);
DEFINE dPagoReq      	DECIMAL(18,2);

DEFINE pNumCel       	CHAR(13);
DEFINE sCodRetEvento 	CHAR(5);

DEFINE pMontoSolOtorga	DECIMAL(18,2);	-- MONTO APROBADO PRODUCTO 6800,7100

--- Cuenta Clabe
DEFINE vcod_ret				CHAR (6);
DEFINE cta_Clabe			CHAR (18);

DEFINE count_maecrd			SMALLINT;
DEFINE count_mdoscrd		SMALLINT;
DEFINE count_maeanexcrd		SMALLINT;
DEFINE count_ctascarg		SMALLINT;
DEFINE count_suc			SMALLINT;
DEFINE count_amortcrd		SMALLINT;
DEFINE count_ssautoriz		SMALLINT;
DEFINE cbanfamilia			 CHAR(3);
DEFINE cbanderaactydesact	 CHAR (1); 		
DEFINE cnumobligados         CHAR (1); 		
DEFINE ccapturaobligada      CHAR (1); 		
DEFINE sidgarantia           SMALLINT; 		
DEFINE daforogarantia        DECIMAL(16); 	
DEFINE ccuenta_concentradora CHAR(20); 	
DEFINE cbancobrocomapert SMALLINT; 
DEFINE ccod_comision_apertura CHAR(4);	
DEFINE g_Leyenda              CHAR(40);
DEFINE g_TranRet              CHAR(4);
DEFINE g_FechaCargo           DATE;
DEFINE g_SdoDisp              DECIMAL(14,2);
DEFINE g_MtoRet               DECIMAL(14,2);
DEFINE ciddomiciliacion 	  CHAR(1);
DEFINE cNumSolObligado CHAR(20);
DEFINE vAuxNuevoStatus	CHAR(2);
DEFINE vAuxMensaje			CHAR(40);
DEFINE cCausa_sol			CHAR(3);
DEFINE cContSolObligado	INTEGER;
DEFINE CanalSol             CHAR(1);
-- IFSR
DEFINE val_ifrs char(1);
DEFINE stat_aper char(2);

--***********************
--INICIALIZA VARIABLES
--***********************

LET cCodRet      		= '00000';
LET cCodRet3			= '000';
LET cCodRetTDif			= '';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mSobreTasa_MORA		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
LET cFactor_Mora		= "";
LET dFechaApert 		= DATE(1);
LET dFechaVenc 			= DATE(1);
LET iSqlErr    			= 0;
LET iIsamError 			= 0;
LET cErrorInfo 			= "";
LET cNumCte    			= "";
LET cTpCte     			= "";
LET mIngreso   			= 0;
LET cFactorFAV 			= "";
LET cProducto  			= "";
LET cDivisa    			= "";
LET cSucursal			= "";
LET cFolio				= "";
LET cMensaje 			= "";
LET dFechaT  			= DATE(1);
LET sDiaCorte			= 0;
LET i 					= 0;
LET mCatIva				= 0;
LET cMercadeo 			= "";
LET sSecIngreso			= 0;

LET mTasaInteresProd	= 0;
LET cPeriodoPag			= "";
LET iDiasTraspCap		= 0;
LET iDiasTraspInt		= 0;
LET cNumeroFolio		= "";
LET cTransacc			= "";
LET iNumReg				= 0;

LET dIvaSuc             = 0;
LET idAbono             = "N";
LET sDiasPeriodo        = 0;
LET dtDiaprimero  	 	= DATE(1);

LET dtFecha_cargo  	   = DATE(1);
LET mDispo             = 0;
LET mCargo      	   = 0;
LET mIvaComisionApertura = 0;
LET mComisionApertura	= 0;
LET dPorcComisionAper   = 0;
LET cTransaccIvaCargo   = "";
LET cTransaccCargo      = "";
LET iContador      	    = 0;
LET mTotalPagar			= 0;


LET iNum_periodos		= 0;
LET dtFecha_cuota      	= DATE(1);
LET dSdo_inicial      	= 0;
LET dPago_mensual      	= 0;
LET dMto_Interes      	= 0;
LET dIva_interes      	= "";
LET dCapital      	   	= "";
LET dSdo_final      	= 0;
LET sDias_periodo      	= 0;
LET dtFecha_Aper      	= DATE(1);
LET iDiaPago       		= 0; 
LET cNumMesesPagos  	= "";

LET cCodRet2            = "00000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET vCatFinal 			= 0;
LET dPagoReq 			= 0;

LET pNumCel  			= '';
LET sCodRetEvento		= '';

LET pMontoSolOtorga = 0; 

--- Cuenta Clabe
LET vcod_ret			= '000';
LET cta_Clabe			= '';	
LET count_maecrd		= 0;
LET count_mdoscrd		= 0;
LET count_maeanexcrd	= 0;
LET count_ctascarg		= 0;
LET count_suc           = 0;
LET count_amortcrd		= 0;
LET count_ssautoriz		= 0;
LET cbanfamilia			= '';
LET cbanderaactydesact	 = ''; 		
LET cnumobligados         = ''; 		
LET ccapturaobligada      = '';		
LET sidgarantia           = 0; 		
LET daforogarantia        = 0; 	
LET ccuenta_concentradora = ''; 
LET cbancobrocomapert	  = 0;
LET ccod_comision_apertura = '';
LET g_Leyenda 			   = "ABONO PRESTAMO";
LET g_TranRet              = "";
LET g_FechaCargo           = "";
LET g_SdoDisp              = 0;
LET g_MtoRet               = 0;
LET ciddomiciliacion	   = '0';
LET cNumSolObligado		= '';
LET cCausa_sol				= '';
LET cContSolObligado	= '';

--IFRS
LET val_ifrs ='';
LET stat_aper ='';
LET CanalSol            = '';


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
        IF idAbono = "S" THEN         
             CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "00004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;

	-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO, LA SUCURSAL Y EL MONTO AUTORIZADO--se mueve consulta JMAH
	SELECT a.num_producto, a.divisa, b.sucursal, b.monto_autorizado, a.familia, cobro_comis_apertura, cod_comision_apertura ,id_domiciliacion
	INTO cProducto, cDivisa, cSucursal, pMontoSolOtorga, cbanfamilia,cbancobrocomapert, ccod_comision_apertura, ciddomiciliacion	
	FROM bdisolic:"informix".ss_solicitudes b
	  INNER JOIN "informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;
	
	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
	IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = ""  OR (NVL(pNombrePres,"") = "" AND cProducto NOT IN ("9100","9300") ) OR NVL(pCuentaCap,"") = "" THEN
		LET cCodRet = "00002";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF
	

	
	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
    --IF cProducto IN ('6800','7100') THEN
	IF cbanfamilia = '003' AND cProducto <> '6400' THEN
		LET pMonto = pMontoSolOtorga;
    END IF;
	
	IF cProducto = '6400' THEN--JMAH
		IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMensualidad,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
    ELSE
	  IF NVL(pPlazo,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;
		IF NVL(pMonto,0) <> 0 THEN
			LET iContador=iContador+1;
		END IF;		
		IF iContador <> 2 THEN 
			LET cCodRet = "00002";
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;	
	END IF;	
	--SE VALIDA QUE NO EXISTA EL CREDITO
	SELECT COUNT(num_credito) INTO count_maecrd FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_mdoscrd FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_maeanexcrd FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	--SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT COUNT(num_credito) INTO count_amortcrd FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT COUNT(num_solicitud) INTO count_ssautoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";

 --Valida que la solicitud sea de flujo One Click.
	SELECT canal_sol INTO CanalSol FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = pSolicitud;

	--6 igual a Sucursal, 7 igual a App.
	IF(CanalSol = '6' OR CanalSol = '7') THEN
			--Toma la tasa que proporciono el ÃÂÃÂ¡rea de crÃÂÃÂ©dito para los clientes pre aprobados.
			SELECT tasa INTO mTasaInteres FROM bdicred:"informix".sd_pre_aprobados_trx WHERE solicitud = pSolicitud;

			LET mTasaInteresProd = mTasaInteres;

			--obtiene la sucursal que se esta llevando la apertura del prÃÂÃÂ©stamo para la solicitud de one click con base al ejecutivo.
			-- Si pEjecutivo es igual a 0 el flujo viene desde la App, si es diferente de 0 el flujo viene de sucursal.
			IF pEjecutivo = "0" OR pEjecutivo IS NULL THEN
					--Se toma la sucursal origen del cliente.
					SELECT cte.sucursal
					INTO cSucursal
					FROM bdinteg:"informix".si_cliente cte
					JOIN bdisolic:"informix".ss_solicitudes sol ON (cte.numcte = sol.numcte)
					WHERE sol.empresa = pEmpresa AND sol.num_solicitud = pSolicitud;
					
					IF cSucursal='8503' then
					 LET cSucursal='6700';
					END IF;
					
					LET pEjecutivo = 'transBPI';
			ELSE
					--Se toma la sucursal de acuerdo al ejecutivo que esta realizando el proceso de formalizaciÃÂÃÂ³n del prÃÂÃÂ©stamo.
					SELECT sucursal INTO cSucursal FROM bdinteg:"informix".si_ejecut WHERE empresa = pEmpresa AND ejecutivo = pEjecutivo;
			END IF;
	END IF;               --      RQM 10 1224
	
	-- CAX 14112024 se valida sucursal 
	SELECT count(*) INTO count_suc FROM bdinteg:si_sucursales WHERE sucursal = cSucursal and tpo_sucursal = 'S';
	SELECT COUNT(num_credito) INTO count_ctascarg FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	

	--IF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF count_maecrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_mdoscrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF count_maeanexcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM "informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	ELIF count_ctascarg > 0 AND ciddomiciliacion ='0' THEN 
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_amortcrd > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF count_ssautoriz > 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	ELIF count_suc = 0 THEN   ---VALIDA QUE LA SUCURSAL SEA OPERATIVA
		LET cCodRet = "00001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;	
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM   "informix".sd_param
	WHERE  cod_param = '034';
	IF mCatIva IS NULL THEN
	   LET mCatIva = 0;
	END IF;
	
	--VAlida si esta activo el IFRS	
	select valor into val_ifrs from sd_param where cod_param = '700';
	IF val_ifrs = 'A' THEN
		LET stat_aper = 'E1';
	ELSE
		LET stat_aper = 'AA';
	END IF;

		
	EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pEmpresa, pSolicitud, '') INTO cCodRetTDif, mTasaInteres, mTasaMora;
	IF cCodRetTDif <> '00000' THEN
		LET cCodRet = cCodRetTDif;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;	

	
	SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo, a.fact_sobret_mora, a.sobretasa_mora
	  INTO cFactor,            mSobreTasa,  sDiaCorte,   cPeriodoPag,	  cFactor_Mora, 	  mSobreTasa_MORA
	  FROM "informix".sd_definicion a
	 INNER JOIN bdisolic:"informix".ss_solicitudes b ON (a.empresa = b.empresa AND a.num_producto = b.num_producto and b.num_solicitud = pSolicitud);

	LET mTasaInteresProd = mTasaInteres;

	IF cFactor = "+" THEN
		LET mTasaInteres = mTasaInteres + mSobreTasa;
	ELIF cFactor = "-" THEN
		LET mTasaInteres = mTasaInteres - mSobreTasa;
	ELIF cFactor = "*" THEN
		LET mTasaInteres = mTasaInteres * mSobreTasa;
	ELSE
		LET mTasaInteres = mTasaInteres / mSobreTasa;
	END IF

           

	LET mTasaMoraProd = mTasaMora;

	IF cFactor_Mora = "+" THEN
			LET mTasaMora = mTasaMora + mSobreTasa_MORA;
	ELIF cFactor_Mora = "-" THEN
			LET mTasaMora = mTasaMora - mSobreTasa_MORA;
	ELIF cFactor_Mora = "*" THEN
			LET mTasaMora = mTasaMora * mSobreTasa_MORA;
	ELSE
			LET mTasaMora = mTasaMora / mSobreTasa_MORA;
	END IF

	--INTERES A FAVOR DEL CLIENTE
	SELECT c.valor, a.factor_sobretasa, a.sobretasa
	INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
	FROM "informix".sd_anexodefinicion a
		INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
		INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
	WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

	IF cFactorFAV = "+" THEN
			LET mTasaFavor = mTasaFavor + mSobreTasaFAV;
	ELIF cFactorFAV = "-" THEN
			LET mTasaFavor = mTasaFavor - mSobreTasaFAV;

	ELIF cFactorFAV = "*" THEN
			LET mTasaFavor = mTasaFavor * mSobreTasaFAV;
	ELSE
			LET mTasaFavor = mTasaFavor / mSobreTasaFAV;
	END IF	

	-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
	SELECT fecha_hoy INTO dFechaApert FROM "informix".sd_fechas WHERE empresa = pEmpresa;	
	--se modifica la forma en que se se obtiene la fecha del primer pago del credito para homologarlo con la proyeccion.
	IF cProducto = '6400' THEN    ---Periodo de pago credinomina		
				--se obtiene la fecha de la proxima cuota.
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienefechapago('001',dFechaApert,pSolicitud)
			INTO cCodRet,dFechaT,iDiaPago;	
			IF cCodRet::INTEGER <> 0  THEN	
				LET cCodRet    = "00008";	--Ocurrio un Error al obtener la fecha de primer pago del credito para credinomina.
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
		CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	 			
	END IF;
	IF cProducto = '6400' THEN---Periodo de pago Mensual prestamo 	--JMAH
		--se obtiene fecha de vencimiento para credinomina
		FOREACH 
	     	EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,pMensualidad,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
					INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
							dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos			
					IF cCodRet::INTEGER <> 0  THEN				
						LET cCodRet    = "00007";	--Ocurrio un Error al obtener la fecha de vencimiento del credito para credinomina.
				 		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
					END IF;
					IF iNum_periodos=1 THEN
						LET pMensualidad = dPago_mensual;
						LET pMonto = dSdo_inicial;					
					END IF;					
					LET dFechaVenc = dtFecha_cuota;					
	    END FOREACH;
		LET pPlazo = iNum_periodos; 
	ELSE
		CALL "informix".monthadd(dFechaApert,1) RETURNING dFechaT;
	    CALL "informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;	
		--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
        --IF cProducto IN ('6800','7100') THEN
		IF cbanfamilia = '003' AND cProducto <> '6400' THEN
            CALL "informix".monthadd(dFechaApert,36) RETURNING dFechaVenc;
        ELSE
            CALL "informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;
        END IF;
	END IF;	
	IF cCodRet::INTEGER <> 0 THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;
	--AAME 20150317 RQM 10 550 Se anexan nuevos productos de prestamo ('7600','7700') para que realice la proyeccion.
	--CYRV 20171113 RQM 10 915 Se agrega nuevo prestamos a proyeccion 6800 y 7100
	--IF (cProducto = '6300') OR (cProducto = '6400') OR (cProducto = '7600') OR (cProducto = '7700') OR (cProducto = '6800') OR (cProducto = '7100') THEN
	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
	--IF cProducto IN ('6300','6400','7600','7700','6800','7100') THEN
	IF cbanfamilia IN ('002','003') THEN
	--VALIDACION PARA CALCULAR EL MONTO TOTAL A PAGAR PARA UN PRESTAMO PERSONAL
		FOREACH 
			--SE OBTIENE CON EL PROYECTA PRESTAMO CADA UNA DE LAS MENSUALIDADES PARA SUMARLAS y CALCULAR EL MONTO TOTAL A PAGAR
	     	EXECUTE PROCEDURE bdisolic:"informix".sp_proyecta_prestamos (pMonto,pPlazo,0,cProducto,cSucursal,1,0,pSolicitud,"",pFrecuencia)
					INTO cCodRet,iNum_periodos,dtFecha_cuota,dSdo_inicial,dPago_mensual,dMto_Interes,
							dIva_interes,dCapital,dSdo_final,sDias_periodo,dtFecha_Aper,cNumMesesPagos
					--SE VALIDAD PARA VER SI EL PROYECTA PRESTAMO SE EJECUTO CORRECTAMENTE
					IF cCodRet::INTEGER <> 0  THEN				
				 		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
					END IF;
					--VARIABLE QUE GUARDA LA SUMA DE LAS MENSUALIDADES
					LET mTotalPagar = mTotalPagar + dPago_mensual::DECIMAL(18,2);	
					IF iNum_periodos=1 THEN
						LET pMensualidad = dPago_mensual;
					END IF;			
	    END FOREACH;
	END IF;
	
       SELECT a.iva
         INTO dIvaSuc
         FROM bdinteg:"informix".si_sucursales a
        WHERE a.sucursal = cSucursal
          AND a.empresa  = pEmpresa;
		  
		--- Genera cuenta Clabe
		EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (pEmpresa,pSolicitud,cProducto)
			INTO vcod_ret, cta_Clabe;		  
	
	--RQM 10 1177 Se contempla subproducto en campo cod_linea
      --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
	INSERT INTO "informix".sd_maecredcrd
		   (empresa,                        num_credito,
			num_producto,                   ejecutivo,
			numcte,                         aval_cte,
			aval_linea,                     divisa,
			sucursal,                       id_origen,
			origen,                         cod_tipo_linea,
			cod_linea,                      status_cred,
			bandera_renovac,                bandera_prorroga,
			periodo_plazo,                  plazo,
			fecha_apertura,                 fecha_vencim,
			period_pago_cap,                period_pag_int,
			dias_trasp_cap,                 dias_trasp_int,
			tasa_fija_o_var,                cod_tasa_base,
			factor_sobretasa,               sobretasa,
			tasa_interes,                   cod_tasa_mora,
			sobretasa_mora,                 fact_sobret_mora,
			tasa_moratorios,                tasa_preferencial,
			sobretasa_preferencial,         factor_preferencial,
			valor_preferencial,             fecha_pago_cap,
			fecha_pago_int,                 es_fisica,
			bandera_fi_fo,                  actividad,
			tipo_calculo,                   num_aper_ant,
			rev_tasa_var_per,               dia_para_revisar,
			cod_prod,                       bandera_ministra,
			credito_externo,                califica_riesgo,
			cod_agricola,                   pagos_sostenidos,
			campo_trab1,                    campo_trab2,
			campo_trab3,                    campo_trab4
			,cuenta_clabe
		   )
	SELECT  sol.empresa                		,pSolicitud
		   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
		   ,sol.numcte                      ,''
		   ,''                              ,NVL(def.divisa,1)
		   ,NVL(cSucursal,'')            ,''
		   ,''                              ,''
		   ,anx.cod_linea                   ,stat_aper
		   ,'S'                             ,'N'
		   ,SUBSTR(tipo_pago,1,1)		   --,NVL(def.periodo_plazo,'')     
		   ,pPlazo
		   ,dFechaApert  					,dFechaVenc
		   ,NVL(def.period_pago_cap,'')     ,NVL(def.period_pag_int,'')
		   ,NVL(def.dias_traspaso_cap,0)    ,NVL(def.dias_traspaso_int,0)
		   ,NVL(def.tasa_fija_o_var,'')     ,NVL(def.cod_tasa_base,'')
		   ,NVL(def.factor_sobretasa,'')    ,NVL(def.sobretasa,'')
		   ,mTasaInteresProd                ,NVL(def.cod_tasa_mora,'')
		   ,NVL(def.sobretasa_mora,0)       ,NVL(def.fact_sobret_mora,'')
		   ,NVL(mTasaMoraProd,0)            ,''
		   ,0                               ,''
		   ,0                               ,dFechaT
		   ,dFechaT							,NVL(tip.es_fisica,'')
		   ,''                              ,''
		   ,NVL(def.tipo_calculo,'')        ,dIvaSuc
		   ,''                              ,NVL(def.dia_para_revisar,0)
		   ,''                              ,SUBSTR(tipo_pago,1,1)	--cPeriodoPag
		   ,''                              ,''
		   ,''                              ,0
		   ,0                               ,0
		   ,''                              ,''
		   ,cta_Clabe
	FROM bdisolic:"informix".ss_solicitudes sol
		INNER JOIN "informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
		INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		INNER JOIN "informix".sd_cattipopago pago ON pago.empresa = pEmpresa AND valor = pFrecuencia 
		WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;	
		
	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
	         LET cCodRet    = iSqlErr;

	         LET cErrorInfo  = cErrorInfo;
	         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

		IF cProducto = "6400" THEN --JMAH
		--se obtiene el porcentaje de comision por apertura.
			SELECT valor INTO dPorcComisionAper
			FROM   "informix".sd_param
			WHERE  cod_param = '040';
			
			--se obtiene la transaccion con la que registrara el cargo de la comision
			SELECT valor INTO cTransaccCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '041';
			--se obtiene la transaccion con la que registrara el iva del cargo de la comision
			SELECT valor INTO cTransaccIvaCargo
			FROM   "informix".sd_param
			WHERE  cod_param = '042';
	
            IF ( dPorcComisionAper is null ) THEN LET dPorcComisionAper = 0; END IF;

            IF ( dPorcComisionAper > 0 ) then


                LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
			END IF
		END IF
		
			--RQM 10 751
			-- RQM 10 737 
			LET dPagoReq = pMonto / ((1- pow((1+((mTasaInteres /100)/( pFrecuencia * 12 ))),-pPlazo)) / ((mTasaInteres /100)/( pFrecuencia * 12 )) ) ;
			
			EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir_pp(pMonto,dPagoReq,pPlazo,(12 * pFrecuencia),mComisionApertura) 
			into cCodRet2,cMensajeRet,vCatFinal;
				LET mCatIva = vCatFinal;
				
			IF cCodRet2::integer  <> 0 THEN
				LET cCodRet = "00003";
				DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
				DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
				DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
                DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;
	 
	

		
		INSERT INTO "informix".sd_maecredanexocrd
			(empresa, 				 		num_credito,
			 localidad,              		dia_corte,
	         dias_gracia_mora, 		 		tp_dias_calc_mora,
	         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
	         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
	         sobretasa_cte, 		 		tasa_interes_cte,
	         fecha_vencto, 			 		prox_fecha_pago,
	         fecha_proceso,			 		fecha_ult_pago,
	         nombre_pres, 					cat)
		SELECT pEmpresa              		,pSolicitud,
               ""                    		,(CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END) ,--JMAH
			   NVL(def.gracia_calc_mora,0)  ,'',
			  (CASE WHEN NVL(def.num_producto,"") = "6400"  THEN DAY(dFechaT) ELSE  DAY(dFechaApert) END),--JMAH -- DAY(dFechaApert)      		,
			   (CASE WHEN NVL(nom.Frecuencia_pgo,0) = 0  THEN NVL(def.maneja_linea::INTEGER,0) ELSE  NVL(nom.Frecuencia_pgo,0) END) ,
			   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
			   NVL(def.sobretasa,0)    		,mTasaInteresProd,
			   ""                    		,dFechaT,
			   dFechaApert           		,"",
			   pNombrePres,					vCatFinal
		FROM "informix".sd_definicion def
        INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		LEFT JOIN  bdisolic:"informix".ss_sol_nomina nom ON (nom.empresa = c.empresa AND nom.num_solicitud = c.num_solicitud)		
     --       INNER JOIN bdicred:sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
	--			AND b.cod_prod = def.cod_tipcred
		WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
    END;
      --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;


    BEGIN
	    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
	         LET cCodRet    = iSqlErr;
	         LET cErrorInfo  = cErrorInfo;
	         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	    END EXCEPTION;

		--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
        --IF cProducto IN ('6800','7100') THEN
		IF cbanfamilia IN ('003') AND cProducto <> '6400' THEN
            INSERT INTO "informix".sd_maesdoscrd

                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr
                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						, CASE WHEN val_ifrs = 'A' THEN 0 ELSE NULL END
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

        ELSE
            INSERT INTO "informix".sd_maesdoscrd
                    (
                        empresa, 			num_credito,
                        fecha_ult_mov, 		sdo_int_anticip,
                        sdo_int_ant_dev, 	sdo_intereses,
                        sdo_dia_ant_int, 	sdo_mes_ant_int,
                        sdo_acum_mes_int, 	sdo_retenido,
                        sdo_acum_cap_int, 	sdo_exig_int,
                        sdo_no_exig, 		provision_normal,
                        dias_acum_int, 		sdo_moratorio,
                        sdo_dia_ant_mor, 	sdo_mes_ant_mor,
                        sdo_contab_mora, 	dias_acum_mora,
                        sdo_capital, 		sdo_cap_insoluto,
                        sdo_dia_ant_cap, 	sdo_mes_ant_cap,
                        sdo_acum_mes_cap, 	mto_capitalizado,
                        mto_ministra_cap, 	cargos_dia_cap,
                        abonos_dia_cap, 	cargos_mes_cap,
                        abonos_mes_cap, 	dias_acum_cap,
                        monto_vencido, 		mto_venc_trasp,
                        monto_financiado, 	monto_reservado,
                        sdo_acum_vencido, 	dias_acum_intper,
                        sdo_global_int, 	sdo_acum_intper,
                        monto_otorgado, 	provi_venc_normal,
                        provi_venc_anticip, cap_tras_no_venci,
                        mto_venc_int, 		mto_venc_tra_int,
                        mto_finan_vdo, 		mto_reser_int,
                        mto_fin_ven_trasp, 	mto_fin_vig_trasp,
                        int_tra_no_exig, 	sdo_trab4,
						atr
                    )
            SELECT 		 sol.empresa             ,pSolicitud
                        ,dFechaApert            ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto                 ,pMonto
                        ,0                      ,0
                        ,0                      ,mTotalPagar
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,pMonto					,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
                        ,0                      ,0
						,CASE WHEN val_ifrs = 'A' THEN 0 ELSE NULL END
            FROM   bdisolic:"informix".ss_solicitudes sol
            WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
        END IF;
	END;

	LET iNumReg = dbinfo("sqlca.sqlerrd2");

	IF iNumReg = 0 THEN
		LET cCodRet = "00003";
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

    -- CARGA LINEA DE CREDITO INI 
    --IF cProducto IN ('6800','7100') THEN
	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
	IF cbanfamilia IN ('003') AND cProducto <> '6400' THEN
        INSERT INTO "informix".sd_linea_prestamo
                    (empresa,
                     num_credito,
                     monto_linea,
                     fecha_otorga,
                     linea_disponible,
                     sec_credito,
                     fecha_cancela)
              VALUES (pEmpresa,
                      pSolicitud,
                      pMonto,
                      dFechaApert,
                      pMonto, 
                      0,
                      NULL);

        LET iNumReg = dbinfo("sqlca.sqlerrd2");

        IF iNumReg = 0 THEN
            LET cCodRet = "00003";
            DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
            DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
            DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
            DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
            DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF;

    END IF;
    -- CARGA LINEA DE CREDITO FIN


	-- SE GENERA EL FOLIO
	CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

	-- SE ASIGNA EL FOLIO DE LA TRANSACCION
	IF cProducto = "6400" THEN ---para producto credinomina se utilizara esta transaccion.
		LET cTransacc = "0314";
	ELSE
		LET cTransacc = "0247";
	END IF;

    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
								cProducto        , 3,
                                "001"            , dFechaApert,
                                pMonto           , cNumeroFolio,
                                cSucursal        , cDivisa,
                                "0000",'APERTURA','')
	INTO cCodRet, cErrorInfo;



	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF

	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
	IF cbanfamilia NOT IN ('003') OR cProducto = '6400' THEN
    --IF cProducto NOT IN ('6800','7100') THEN
        EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
                                    cProducto        , 66,



                                    "002"            , dFechaApert,
                                    pMonto           , cNumeroFolio,
                                    cSucursal        , cDivisa,
                                    "0000",'DISPOSICION','')
        INTO cCodRet, cErrorInfo;
    END IF;

	IF cCodRet <> "00000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF


	-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
	INSERT INTO "informix".sd_amortiza_creditocrd
		(
			empresa, 			num_credito,
			fecha_cuota, 		tipo_cuota,
			capital_mto_cuota, 	capital_debe,
			capital_pagado, 	capital_status,
			capital_status_ant, capital_fecha_pago,
			interes_debe, 		interes_pagado,
			interes_status, 	interes_status_ant,
			interes_fecha_pago, iva_debe,
			iva_pagado, 		iva_status,
			iva_status_ant, 	iva_fecha_pago,
			mora_provi_ordi, 	mora_provi_cope,
			mora_sdo_ordi, 		mora_sdo_ordi_pag,
			mora_sdo_cope, 		mora_sdo_cope_pag,
			mora_bonificado, 	mora_status,
			mora_iva_debe, 		mora_iva_pagado,
			mora_iva_status, 	mora_iva_fecha_pago,
			num_pago, 			campo_trabajo1,
			campo_trabajo2, 	campo_trabajo3,
			campo_trabajo4
		)
	VALUES
		(
			pEmpresa,			pSolicitud,
			dFechaT,			"3",
			pMensualidad,		0,
			0,					"3",
			"3",				"",
			0,					0,
			"1",				"1",
			"",					0,
			0,					"1",
			"1",				"",
			0,					0,
			0,					0,
			0,					0,
			0,					"1",
			0,					0,
			"1",				"",
			1,					0,
			0,					"",
			""
		);

	--SE INSERTA EN LA TABLA bdicred:sd_ctascarg
	IF count_ctascarg = 0 THEN
		INSERT INTO "informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina)
		VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');
	END IF;

    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AP"
    WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;


	
    --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
    INSERT INTO bdicred:sd_indicador_cred_crd
                (empresa, num_credito, fecha_alta,monto_mensual)
        VALUES (pEmpresa, pSolicitud, dFechaApert,pMensualidad);


    SELECT nombre INTO cMensaje FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo AND empresa = pEmpresa;

    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

	-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
    INSERT INTO bdisolic:"informix".ss_autorizacion
		(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
     VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);
	 
	 --AAME RQM 10 1177 Se modifica para consultar por parametro los productos para obtener la cuenta concentradora
	EXECUTE PROCEDURE bdicred:"informix".sp_cons_param_banderaprod ( pEmpresa, pEjecutivo, '6', '', cProducto, 0)
	INTO cCodRet2,cMensajeRet,cbanderaactydesact,cnumobligados,ccapturaobligada,sidgarantia,daforogarantia,ccuenta_concentradora;

	-- SE GENERA EL ABONO 
	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia en caso de ser mas de 1
	IF cbanfamilia NOT IN ('003') OR cProducto = '6400' THEN
	--IF cProducto NOT IN ('6800','7100') THEN
       -- CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
       --     pMonto, pMonto, 0, 0, 0, "01", pSolicitud||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;
		IF NVL(ccuenta_concentradora,'') <> '' THEN
			-- Realiza el cargo del adeudo a la cuenta
			 /*EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(pEmpresa,
															cSucursal,
															pEjecutivo,
															"0504",
															"0000",
															cNumeroFolio,
															ccuenta_concentradora,
															0,
															pMonto,
															cDivisa,
															pSolicitud||" "|| g_Leyenda,
															'0',
															pEjecutivo)
			INTO cCodRet3, g_TranRet, g_FechaCargo, g_SdoDisp, g_MtoRet;*/
			CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, "0504", "0000", cNumeroFolio, ccuenta_concentradora, 0,
            pMonto, pMonto, 0, 0, 0, "01", g_Leyenda ||" "|| pSolicitud, '0', pEjecutivo) RETURNING cCodRet3;				

			IF cCodRet3 <> "000" THEN
			   LET cCodRet      = "00051";
			   LET cMensajeRet  = "Ocurrio un error al aplicar el abono a la cuenta de enlace";
		    END IF;	
		ELSE 
			CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
            pMonto, pMonto, 0, 0, 0, "01", pSolicitud||" "||pNombrePres, '0', pEjecutivo) RETURNING cCodRet3;			
			IF cCodRet3 <> "000" THEN
			   LET cCodRet      = "00051";
			   LET cMensajeRet  = "Ocurrio un error al aplicar el abono a la cuenta efectiva";
		    END IF;	
		END IF;
    END IF;

	-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
	IF cCodRet3 <> "000" THEN
		DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
        DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
		RETURN cCodRet3,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    ELSE 
        LET idAbono = "S";         
	END IF;
	
	IF cProducto = "6400" THEN --JMAH
		
            IF ( dPorcComisionAper > 0 ) then


                LET mComisionApertura= ROUND(pMonto * (dPorcComisionAper/100),2);
			
	
                --SE REALIZA CARGO POR COMISION DE APERTURA
                CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo, cTransaccCargo, "0000", cNumeroFolio,pCuentaCap, 0, mComisionApertura, 
                            cDivisa,"", "0", pEjecutivo)
                   RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;
			
                IF cCodRet::INTEGER <> 0  THEN
                    DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
                    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
                    DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
                    DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
                    DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                    CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
                     IF cCodRet <> "000" THEN
                        LET cCodRet    = "00004";
                     ELSE
                        LET cCodRet    = "00005";	--Ocurrio un Error al realizar el cargo  de la comision por apertura
                     END IF;

                    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
                END IF;

                LET mIvaComisionApertura = ROUND(mComisionApertura * dIvaSuc,2); --iva de la comision            
                CALL bdicheq:"informix".cargo_ref(pEmpresa, cSucursal, pEjecutivo,cTransaccIvaCargo, "0000", cNumeroFolio,
                              pCuentaCap, 0, mIvaComisionApertura, cDivisa,"", "0", pEjecutivo)
                RETURNING cCodRet, cTransacc, dtFecha_cargo, mDispo, mCargo;

                IF cCodRet::INTEGER <> 0  THEN
                    DELETE FROM "informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
                    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
                    DELETE FROM "informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
                    DELETE FROM "informix".sd_ctascarg WHERE num_credito = pSolicitud;
                    DELETE FROM "informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: Se adiciona reg. x error en apertura
                    DELETE FROM "informix".sd_linea_prestamo WHERE num_credito = pSolicitud;
                    CALL bdicheq:"informix".reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
                     IF cCodRet <> "000" THEN
                        LET cCodRet    = "00004";
                     ELSE
                        LET cCodRet    = "00006";	--Ocurrio un Error al realizar el cargo por iva de la comision por apertura
                     END IF;

                    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
               END IF;
           END IF;
	END IF;
    -- SE ACTUALIZAN LOS DATOS DEL CLIENTE
    SELECT a.numcte, tipo_cliente, NVL(ingreso_mensual,0)
    INTO cNumCte, cTpCte, mIngreso
    FROM bdinteg:"informix".si_cliente a
	INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.numcte = a.numcte
	INNER JOIN bdisolic:"informix".ss_resum_scor_fin c ON c.empresa = b.empresa AND c.num_solicitud = b.num_solicitud
	WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

    -- Saca la Publicacion de si_ctepf Jose Luis Puebla
    SELECT string1 INTO cMercadeo
    FROM   bdinteg:"informix".si_ctepf
    WHERE  numcte = cNumCte;

    IF cTpCte = "1" THEN
		SELECT MAX(sec_ingreso) INTO sSecIngreso FROM bdinteg:"informix".si_ingresos WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = 'T';

		UPDATE bdinteg:"informix".si_ingresos SET ingreso_mensual = mIngreso
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T" AND sec_ingreso = sSecIngreso;
    ELSE

		UPDATE bdinteg:"informix".si_cliente SET tipo_cliente = "1" WHERE numcte = cNumCte;

		SELECT NVL(MAX(sec_ingreso), 0) + 1 INTO sSecIngreso
		FROM bdinteg:"informix".si_ingresos
		WHERE empresa = pEmpresa AND numcte = cNumCte AND tipo_ingreso = "T";

		INSERT INTO bdinteg:"informix".si_ingresos (empresa, numcte, sec_ingreso, tipo_ingreso, ingreso_mensual)
		VALUES (pEmpresa, cNumCte, sSecIngreso, "T", mIngreso);
    END IF

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
       LET mTasaMora = mTasaMora * -1;
    END IF

    -- Actualiza informacion para la bitacora de la solicitud (auditoria-cnbv)      
    UPDATE bdisolic:"informix".ss_revision_determinacion SET plazo = pPlazo, pago_mens = pMensualidad WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;

	--AAME RQM 10 1177 Se modifica para consultar por parametro los productos por familia y el parametro de mensajes de apertura activos
	EXECUTE PROCEDURE bdicred:"informix".sp_cons_param_banderaprod ( pEmpresa, pEjecutivo, '2', '1', cProducto, 9) 
	INTO cCodRet2,cMensajeRet,cbanderaactydesact,cnumobligados,ccapturaobligada,sidgarantia,daforogarantia,ccuenta_concentradora;
	
	--AAME RQM 10 1177 Se cancela la solicitud de obligado Solidario.
	IF cProducto IN ('9100','9300') THEN
			SELECT count(a.numcte_ref)
			INTO cContSolObligado --Cantidad de Solicitudes de Prestamo Obligado
			FROM bdinteg:si_refclientes a
			INNER JOIN bdisolic:"informix".ss_refpersonales b ON (a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud)
			WHERE a.empresa = pEmpresa AND a.num_solicitud = pSolicitud AND substr(b.numcte_ref,1,2) ='R3';		
			
			IF cContSolObligado >= 1 THEN
				FOREACH
					SELECT a.numcte_ref
					INTO cNumSolObligado --Numero de Solicitud de Prestamo Obligado
					FROM bdinteg:si_refclientes a
					INNER JOIN bdisolic:"informix".ss_refpersonales b ON (a.empresa = b.empresa AND a.num_solicitud = b.num_solicitud)
					WHERE a.empresa = pEmpresa AND a.num_solicitud = pSolicitud AND substr(b.numcte_ref,1,2) ='R3'		
					--Registrar Mensaje en la tabla de causas sol
					LET vAuxNuevoStatus = 'CN';
					LET cCausa_sol = 'CPO';
					LET vAuxMensaje = 'Cancelacion PrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamo Obligado por Titular Aperturado';      			
					
					--Actualizar status de la solicitud de obligado
					EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_status_sol(pEmpresa, 'sistema', cNumSolObligado, vAuxNuevoStatus, cCausa_sol,vAuxMensaje) Into cCodRet2;
				END FOREACH;
			END IF;
	END IF;

	IF cbanfamilia IN ('003') AND cProducto <> '6400' AND cbanderaactydesact = '1' THEN	
    --IF cProducto IN ('6800','7100') THEN
        SELECT NVL(telefono,'')
          INTO pNumCel
          FROM bdinteg:si_telefonos_actual 
         WHERE numcte = cNumCte
           AND tipo_tel = '2' 
           AND status_tel = 'A';

        IF (pNumCel <> '') THEN		
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP1','000000000','','',1, '','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
			CALL bdimnsj:"informix".sp_registra_evento(2,'SMS_RECI','PPF_SMSAP2','000000000','','',1,'','','','','','','','','','','',pNumCel,0,0,0,0,0,'','') RETURNING sCodRetEvento;
        END IF;
    END IF;
	
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE
DOCUMENT
'AUTOR: Fernando Rodelo Barron',
'Descripcion: Se modifica insert en tabla sc_maecredcrd para tomar',
'la sucursal del ejecutivo que formaliza el prestamo en solicitudes OC',
'Fecha: 2024/04/17',
'Version: 1.0.1',
'BD: BDICRED',
'--------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consultadatos_motor_adn (pEmpresa CHAR(4), pNumSol CHAR(20))
RETURNING
	CHAR(5) 	   as cCodRet,
	CHAR(20)	   as cSolBanco, 
	CHAR(20)	   as cNumCteBco, 
	CHAR(20) 	   as cNumCte, 
	CHAR(4)		   as pEmpresa,  
	CHAR(2)		   as cStatusSolicitud, 
	CHAR(3)		   as cCausa_Sol,  
	CHAR(4)		   as cNum_Producto,  
	CHAR(2)		   as cTipoGrupo,  
	CHAR(1)		   as cTp_solicitud,  
	INTEGER  	   as cB_INE,  
	CHAR(50)	   as cHabita_en,  
	CHAR(3)		   as cProfesion,   
	SMALLINT	   as sId_actividad,  
	CHAR(60)	   as cDescAct,   
	SMALLINT	   as sId_subactividad,  
	CHAR(50)	   as vDescSubAct,  
	CHAR(1)		   as cSituacionEspecial,  
	SMALLINT 	   as sCausaSituacion,  
	CHAR(1)		   as cMotivoRechBcpl,  
	SMALLINT 	   as sHist_meses,   
	DECIMAL(5,2)   as dEficienciaCoppel,  
	INTEGER 	   as iReprestamos, 
	CHAR(60)	   as cDescripcion,  
	CHAR(1)		   as cRiesgoViviendaCpl,  
	CHAR(1)		   as cRiesgoViviendaBcpl,  
	CHAR(1)		   as cActRiesgoCpl,   
	CHAR(1)		   as cActRiesgoBCpl,  
	CHAR(1)	       as cDescpRiesgo,   
	VARCHAR(30)    as dSituacionPagoCoppel,  
	DECIMAL(18,2)  as mIngreso_Mensual,  
	SMALLINT	   as sCteLargo8,  
	INTEGER		   as iMeses_hist_Val,   
	VARCHAR(50)	   as sFlagHuella,   
	CHAR(2)		   as cCod_Ult_Identif,  
	VARCHAR(50)	   as sValida_Cel,   
	CHAR(10)	   as dtFechaCte, 
	VARCHAR(50)	   as iCanal_Sol, 
	CHAR(1)		   as cCompIngresos,  
	SMALLINT	   as sCompValido,  
	CHAR(4)		   as cSucursal,   
	DECIMAL(14,2)  as dIngresoAjsutado,                                
	CHAR(10)	   as dtFechaNac,  
	CHAR(1)		   as cSexo,  
	CHAR(50)	   as cEdo_Civil,  
	INTEGER	   	   as iTiem_Edo_Civil,  
	CHAR(50)	   as cOcupacion,  
	INTEGER	       as iTiem_Ocupacion,  
	CHAR(50) 	   as cEscolaridad,  
	CHAR(50)	   as cTipoResidencia,  
	INTEGER	       as iTiem_Residencia, 
	VARCHAR(10)    as vClvEdoCob,  
	VARCHAR(200)   as vLocalidad,  
	CHAR(50)	   as cEntidad,  
	CHAR(20)	   as cCURP,  
	INTEGER	       as iFlagEmpleado,  
	INTEGER		   as iExisteCliente,  
	SMALLINT	   as sEdadCte,	  
	SMALLINT	   as vgrupoA,		
	CHAR(10)	   as dtFechaSolicitud, 
	SMALLINT 	   as pMeses_historia_grupo,  
	DECIMAL(5,2)   as pSituacion_pago_grupo,  
	CHAR(30)       as cMunicipio,  
	CHAR(30) 	   as cEstado,  
    INTEGER        as iMoraCoppel, 
    DECIMAL(18,2)  as dSaldoVencido, 
    INTEGER        as iMoraBanCoppel, 
    DECIMAL(18,2)  as dSaldoVenBanCoppel, 
    VARCHAR(50)    as vTipoTransaccion,   
	INTEGER        as iAntiguedad,        
    INTEGER        as iFraudes,           
    SMALLINT       as iFlagCreditoPPActivo, 
    INTEGER        as iEstabilidadVivienda, 
    SMALLINT       as iListaNegra,          
    INTEGER        as cNoTramiteDia_TDC,    
    INTEGER        as cNoTramiteDia_PP,     
    VARCHAR(50)    as cTipoColectivo,       
    DECIMAL(8,2)   as dNum_consultasfinanciera, 
    SMALLINT       as sReestructura,            
	SMALLINT       as sIdentFalsa,		        
    SMALLINT       as sQuebranto,	            
	VARCHAR(50)    as vTipoEmpCode,             
    VARCHAR(50)    as vTipoEmpName,             
	DECIMAL(8,2)   as dPromedioIngresoMUlt4d,   
    VARCHAR(24)      as cContinuidadDepositosNomina, 
	VARCHAR(50)	  as origeninput1,	
	VARCHAR(50)	  as origeninput2,	
	VARCHAR(50)	  as origeninput3,	
	VARCHAR(50)	  as origeninput4,	
	INTEGER as origeninput5,
	INTEGER as origeninput6,
	INTEGER as origeninput7,
	INTEGER as origeninput8;
	
	
-------------------------------------------- DEFINICION DE VARIABLES ---------------------------
--DEFINICION DE VARIABLES DATOS DEL CLIENTE
DEFINE cNumCte                  CHAR(20);      --nÃºmero de cliente Coppel
DEFINE cNumCteComp				CHAR(20);      --nÃºmero de cliente Coppel completo
DEFINE cNumCteBco		        CHAR(20);      --nÃºmero de cliente Bancoppel
DEFINE cNumCteBcoN		        CHAR(20);      --nÃºmero de cliente Bancoppel
DEFINE cB_INE		            INTEGER;       --Flag de validaciÃ³n INE B_ife
DEFINE cCurp 					CHAR(20);      --Corresponde al CURP del cliente 
DEFINE dtFechaCte			    CHAR(10);      --Corresponde a la fecha de alta del cliente
DEFINE dtFechaNac 				CHAR(10);      --Corresponde a la Fecha de Nacimiento del cliente 
DEFINE cSexo                    CHAR(1);       --Corresponde al genero del cliente 
DEFINE cEdo_Civil               CHAR(50);      --Correspojde al estado civil del cliente -**
DEFINE iTiem_Edo_Civil          INTEGER;       --Corresponde al tiempo del estado civil 
DEFINE iTiem_Edo_Civil_meses    INTEGER;       --Corresponde al tiempo de estado civil en  meses
DEFINE cEscolaridad             CHAR(50);      --Corresponde al grÃ¡do mÃ¡ximo de estudios del cliente 
DEFINE cHabita_en               CHAR (50);     --Tipo de vivienda del cliente -**
DEFINE cTipoResidencia          CHAR (50);     --Corresponde al tipo de residencia
DEFINE cEntidad                 CHAR(50);      --Corresponde a la entidad de residencia del cliente -**
DEFINE vLocalidad        		VARCHAR(200);  --Corresponde a la localidad del cliente
DEFINE iTiem_Residencia   		INTEGER;       --Corresponde al tiempo de residencia  
DEFINE cNumCel					VARCHAR(13);
DEFINE sValida_Cel	            VARCHAR(50);   --iValidaCel (nÃºmero de tel celulares activos y validados deberÃ­a ser max=1
DEFINE cOcupacion               CHAR(50);      --Corresponde a la ocupaciÃ³n del cliente
DEFINE iTiem_Ocupacion          INTEGER;       --Corresponde al tiempo que lleva laborando
DEFINE cProfesion             	CHAR(3);       --profesiÃ³n del cliente
DEFINE sId_actividad		    SMALLINT;      --ID de la actividad que realiza el cliente
DEFINE cDescAct 			    CHAR(60);      --descripciÃ³n de la actividad que realiza el cliente
DEFINE sId_subactividad	        SMALLINT;      --ID de la sub- actividad que realiza el cliente
DEFINE vDescSubAct      		VARCHAR (50);  --descripciÃ³n de la actividad que realiza el cliente
DEFINE mIngreso_Mensual			DECIMAL(18,2); --Corresponde al ingreso mensual reportado por el cliente
DEFINE cCompIngresos			CHAR(1);       --Corresponde al flag comprobante de ingresos del cliente
DEFINE sCompValido      		SMALLINT;      --Corresponde al flag de validaciÃ³n por parte de mesa de control del comprobante de ingreso
DEFINE sFlagHuella              VARCHAR(50);   --corresponde a la coincidencia o no de la hulla del cliente banco vs coppel
DEFINE cCod_Ult_Identif         CHAR(2);       --Corresponde a la Ãºltima identificacion presentada por el cliente ( INE,PASAPORTE....ETC)
DEFINE iReferencia				INTEGER;
DEFINE iReferencia1				INTEGER;
DEFINE iReferencia2 			INTEGER;
DEFINE vHuella                  SMALLINT;
DEFINE sEdadCte					SMALLINT;
DEFINE cNombreCte				CHAR(50);
DEFINE pMeses_historia_grupo 	SMALLINT;
DEFINE pSituacion_pago_grupo 	DECIMAL(5,2);
DEFINE v_meses                SMALLINT; --MACM
DEFINE v_cuantos              SMALLINT;	--MACM								   

--DEFINICION DE VARIABLES DE CUENTA COPPEL
DEFINE cPuntualidadCoppel       CHAR(1);        --clasicficaciÃ³n del cliente Coppel de acuerdo al comportamiento de pago en todas sus cuentas
DEFINE dEficienciaCoppel    	DECIMAL(5,2);   --Calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE dSituacionPagoCoppel     VARCHAR(30);   --calculo que realiza el sistema de historial de pagos del cliente Coppel
DEFINE cSituacionEspecial       CHAR(1);        --Corresponde a la revisiÃ³n de situaciones especiales que pueda tener el cliente en coppel
DEFINE sCausaSituacion          SMALLINT;       --Causa de la situaciÃ³n especial
DEFINE sHist_meses              SMALLINT;       -- tiempo de experiencia crediticia en Coppel del cliente pendiente -->Preca
DEFINE dVencidoMuebles 	        DECIMAL(18,2);    --vencido mensual del cliente en muebles
DEFINE dVencidoRopa 	        DECIMAL(18,2);    --vencido mensual del cliente en ropa
DEFINE dVencidoAire             DECIMAL(18,2);    --vencido mensual del cliente en tiempo aire
DEFINE dVencidoPrestamos        DECIMAL(18,2);    --vencido mensual del cliente en prestamo personal
DEFINE dVencidoReestructura     DECIMAL(18,2);    --vencido mensual del cliente en reestructura
DEFINE dVencidoAfiliados        DECIMAL(18,2);    --vencido mensual del cliente en reestructura


--DEFINICION DE VARIABLES DE BANCO
DEFINE cNumcredito				    CHAR(20);
DEFINE iReprestamos             	INTEGER;        --correpsonde al flag represtamos
DEFINE cSolBanco					CHAR(20);
DEFINE vClvEdoCob       			VARCHAR(10);    --Corresponde a la variable Clave Estado Cobranza 
DEFINE cEstado                      CHAR(30);
DEFINE cMunicipio                   CHAR(30);
DEFINE cMotivoRechBcpl  			CHAR(1); 		--Motivo de rechazo BanCoppel 
DEFINE cDescripcion					CHAR(60);
DEFINE cRiesgoViviendaCpl  			CHAR(1);
DEFINE cRiesgoViviendaBcpl  		CHAR(1);
DEFINE cActRiesgoCpl        		CHAR(1);
DEFINE cActRiesgoBCpl				CHAR(1);
DEFINE cDescpRiesgo					CHAR(120);
DEFINE cProducto2                	CHAR (4);
DEFINE v_comprobanco            	DECIMAL(18,2);
DEFINE v_compromi_tdc      			DECIMAL(14,2);
DEFINE dtMaxFechaCorte      		DATE;
DEFINE cGrado_riesgo        		CHAR(2);
DEFINE dMto_reserva         		DECIMAL(18,2);
DEFINE dtFechaAper         			CHAR(10);
DEFINE cStatus_cred					CHAR(2);
DEFINE dSdo_vencido					DECIMAL(18,2);
DEFINE dSdo_vencidocrd      		DECIMAL(18,2);
DEFINE v_capacidad_pago				DECIMAL(18,2);
DEFINE iPlazo                  		INTEGER;


--DEFINICION DE VARIABLES DE SOLICITUD
DEFINE dtFechaSolicitud         CHAR(10);
DEFINE dtDiaFF  				CHAR(2);
DEFINE dtMesFF  				CHAR(2);
DEFINE dtAnoFF  				CHAR(4); 
DEFINE cSucursal   			    CHAR(4);        --Numero de Sucursal
DEFINE iFlagEmpleado            INTEGER;       --Corresponde al flag de empleado Coppel y/o Bancoppel
DEFINE iCanal_Sol         	    VARCHAR(50);        --Corresponde al canal por el cual se originÃ³ la solicitud
DEFINE cTp_solicitud            CHAR(1);        --tipo de solicitud
DEFINE cNum_Producto            CHAR(4);        --tipo de producto
DEFINE cStatusSolicitud         CHAR(2);        --estatus de la solicitud
DEFINE cPiloto 					CHAR(1);
DEFINE cCausa_Sol			    CHAR(3);        --causa del rechazo de la solicitud
DEFINE cTipoGrupo 			    CHAR(2);        --grupo de evaluaciÃ³n al cual pertenece la solicitud
DEFINE cTicket				   	CHAR(20); 
DEFINE cEdo_proceso			   	CHAR(4); 
DEFINE cNum_men				   	CHAR(3); 
DEFINE cEmpresa				   	CHAR(4); 
DEFINE cNumSolRef            	CHAR(20);

DEFINE v_respsic             	CHAR(1);	--MACM

DEFINE BC_101               INTEGER;       --Corresponde a la variable que se calcula actualmente
DEFINE dtFechaHoyAUX        DATE;
DEFINE dtFechaAntiguedadAUX DATE;
DEFINE maxmoptot			INTEGER;
DEFINE pmaxmop				INTEGER;
DEFINE pmaxmop1 		    INTEGER;

DEFINE pmeses		  		INTEGER;
DEFINE Bandera			   	INTEGER;
DEFINE i            		INTEGER;
DEFINE ki           		INTEGER;
DEFINE kiz          		INTEGER;

--DEFINICION DE VARIABLES DE EVALUACION
DEFINE iExisteCliente    INTEGER;       --Conteo de solicitudes del cliente para producto Coppel con estatus diferente de 'PC','AN','MC'
DEFINE dtasaMora		 DECIMAL(9,6);
DEFINE mImporte_hip      DECIMAL(18,2);         --Corresponde al monto de la hipoteca del cliente
DEFINE iMeses_hist_Val   INTEGER;      	--NÃºmero de de meses de historia validos del cliente de acuerdo a su edad
DEFINE sCteLargo8        SMALLINT;      --Determina si es grupo 8
DEFINE sCteLargo        SMALLINT;      
DEFINE vgrupoA 			 SMALLINT;		--Conteo por empresa y cliente de la tabla sd_grupo_cliente

DEFINE cCodRet2Cred 	 CHAR(6);
DEFINE v_moneda     	 CHAR(2); 
DEFINE v_monto 			 DECIMAL(18,2);

DEFINE v_total      	 DECIMAL(18,2);
DEFINE v_imp_hip   		 DECIMAL(18,2);
DEFINE v_factor    		 DECIMAL(14,6);
DEFINE v_tot_tp          DECIMAL(14,2);

DEFINE CadenaTl27 		VARCHAR(30);
DEFINE CantTl27 		INTEGER;

DEFINE v_SituacionPagoCoppel  DECIMAL(5,2);	--MACM

------------------------
DEFINE iCuentaCte 				CHAR(20);
DEFINE contenedor 				INTEGER;
DEFINE comparador 				INTEGER;
DEFINE vlatitud 				VARCHAR(10);
DEFINE vlongitud 				VARCHAR(11);
------------------------

------------------------
--Cambios 120523
DEFINE cnumcte_stdiq_consultassic			CHAR(20);
DEFINE cnumcte_stdiq_MesesFechaConsulIq		CHAR(20);
DEFINE cnum_clientetl_arrendamiento			CHAR(20);
DEFINE cnumcte_stdiq_consultasfinanciera	CHAR(20);

--DEFINICION DE VARIABLES DE ERROR
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cCodRet         CHAR(5);
DEFINE cMensaje_ret    VARCHAR(100);

--VARIABLES AGREGADAS PARA PRESTAMOS PERSONALES //NO SE RETORNAN, HAY QUE CONSULTARLO
DEFINE phit 					CHAR(6);
DEFINE dTl13					DATE;
DEFINE d2Tl13					DATE;
DEFINE iAntiguedad              INTEGER;    
DEFINE vMesesTL13 				DECIMAL(18,2);
DEFINE vPlazoCred               INTEGER;
DEFINE dtFechaHoy		    	CHAR(10);
DEFINE dfecha36m                DATE;


--VARIABLES EXTRAS
DEFINE origeninput1 			VARCHAR(50);
DEFINE origeninput2 			VARCHAR(50);
DEFINE origeninput3 			VARCHAR(50);
DEFINE origeninput4 			VARCHAR(50);
DEFINE origeninput5 			INTEGER;
DEFINE origeninput6 			INTEGER;
DEFINE origeninput7 			INTEGER;
DEFINE origeninput8 			INTEGER;

DEFINE vMensaje				    VARCHAR(255);	--MACM
DEFINE GEN1 	                MONEY(14,2);	--MACM
DEFINE GEN2 	                MONEY(14,2);	--MACM
DEFINE GEN3 	                INTEGER    ;	--MACM
DEFINE iCertif 	                INTEGER;
DEFINE v_valor_2s               INTEGER;

-- NUEVAS VARIABLES PARA ADN
DEFINE dIngresoAjsutado 		DECIMAL(14,2);
DEFINE vTipoTransaccion 		VARCHAR(50);
DEFINE sIdentFalsa		        SMALLINT;
DEFINE vTipoEmpCode             VARCHAR(50);   --
DEFINE vTipoEmpName             VARCHAR(50);
DEFINE iMoraCoppel 	            INTEGER;
DEFINE dSaldoVencido 		    DECIMAL(18,2);
DEFINE iMoraBanCoppel 	        INTEGER;
DEFINE ivencidoBan			    INTEGER;
DEFINE ivencidoBancrd			INTEGER;
DEFINE ivencidoBanCrdAuxAnt		INTEGER;
DEFINE ivencidoBanAux			INTEGER;
DEFINE ivencidoBanAuxAnt		INTEGER;
DEFINE ivencidoBanCrdAux	    INTEGER;
DEFINE dSaldoVenBanCoppel 		DECIMAL(18,2);
DEFINE dSaldoVenBanCoppelAux 	DECIMAL(18,2);
DEFINE dSaldoVenBanCoppelAux2 	DECIMAL(18,2);
DEFINE iFraudes 	            INTEGER;
DEFINE iFlagCreditoPPActivo 	SMALLINT;
DEFINE iEstabilidadVivienda 	INTEGER;
DEFINE iListaNegra			 	SMALLINT;
DEFINE cNoTramiteDia_TDC	    INTEGER;
DEFINE cNoTramiteDia_PP	        INTEGER;
DEFINE cTipoColectivo           VARCHAR(50);
DEFINE dNum_consultasfinanciera DECIMAL(8,2);
DEFINE sReestructura	        SMALLINT;
DEFINE sQuebranto	            SMALLINT;
DEFINE dPromedioIngresoMUlt4d   DECIMAL(8,2);
DEFINE cContinuidadDepositosNomina   VARCHAR(24);
DEFINE dIngresosNetosAux        DECIMAL(8,2);

--VARIABLES AUXILIARES
DEFINE iNumCteAux                INTEGER;
DEFINE iNumCuentaAux             INTEGER;
DEFINE vTipoHitCalu				 INTEGER;
DEFINE scoreCalu				 INTEGER;
DEFINE cValidaINE				 CHAR(20);
DEFINE pagosVencTDC				 INTEGER;
DEFINE pagosVencPP				 INTEGER;
DEFINE dFechaAux 			     DATE;
DEFINE iTipoListaNegra           SMALLINT;
DEFINE cMensajeListaNegra        CHAR(50);
DEFINE cRfc                      CHAR(13);
DEFINE cNombre1                  CHAR(26);
DEFINE cNombre2                  CHAR(26);
DEFINE cApellPaterno             CHAR(26);
DEFINE cApellMaterno             CHAR(26);
DEFINE dtFechaSolicitudAux       DATE;
DEFINE dtFechaSolicitudAux2      DATE;
DEFINE dtFechaAuxContinuidad     DATE;
DEFINE iAuxCont                  INTEGER;
DEFINE iMontoTotAux              INTEGER;
DEFINE dMontoTotAux              DECIMAL(8,2);
DEFINE dFechaIni                 DATE;
DEFINE dFechaFin                 DATE;
DEFINE iAux                      INTEGER;
DEFINE iDiaHoy                   INTEGER;
DEFINE iDiaAyer                   INTEGER;
DEFINE vConsultaMoraBan          VARCHAR(80);
DEFINE vDiaHoy                   VARCHAR(2);
DEFINE vDiaAyer                  VARCHAR(2);









--------------------------- DECLARACION DE VARIABLES NUEVAS PRESTAMOS PERSONALES---------------------------
--VARIABLES EXTRAS
LET origeninput1 = 		'';
LET origeninput2 = 		'';
LET origeninput3 = 		'';
LET origeninput4 = 		'';
LET origeninput5 = 		0;
LET origeninput6 = 		0;
LET origeninput7 = 		0;
LET origeninput8 = 		0;

LET vMensaje = '';	--MACM

LET dfecha36m = 		DATE(1);
LET phit = '';
LET iAntiguedad  = 0;
LET vMesesTL13						= 0;
LET vPlazoCred                  	= 0;

--INICIALIZACION DE VARIABLES DATOS DEL CLIENTE
LET cNumCte               ="";
LET cNumCteComp			  = "";     
LET cNumCteBco		      ="";  
LET cNumCteBcoN		      ="";    
LET cCurp  				  ="";
LET cB_INE                =0;                      
LET dtFechaCte			  = '01-01-1900';
LET dtFechaHoy        	  = '01-01-1900';
LET dtFechaNac 			  = '01-01-1900';
LET dtFechaAntiguedadAUX  = DATE(1);	
LET cSexo                 ="";       
LET cEdo_Civil            ="";       
LET iTiem_Edo_Civil       = 0;       
LET iTiem_Edo_Civil_meses = 0;      
LET cEscolaridad          ="";
LET cHabita_en            ="??";      
LET cTipoResidencia       = "";      
LET cEntidad              ="";
LET vLocalidad         	  = '';
LET iTiem_Residencia   	  = 0;       
let cNumCel 			  = '';                         
LET sValida_Cel	          = "0";    
LET COcupacion            = "";      
LET iTiem_Ocupacion       = 0;      
LET cProfesion            ="";
LET sId_actividad		  = 0;      
LET cDescAct              ="";                                        
LET sId_subactividad	  = 0;      
LET vDescSubAct           = "";                                         
LET mIngreso_Mensual	  = 0;              
LET cCompIngresos		  ="";       
LET sCompValido      	  = 0;       
LET sFlagHuella           ="0";      
LET cCod_Ult_Identif      ="";       
LET iReferencia			  = 0;
LET iReferencia1		  = 0;	
LET iReferencia2		  = 0;
LET vHuella				  = 0;
LET iCuentaCte 			  = '0';
LET sEdadCte			  = 0;
LET cNombreCte 			  ='';
LET pMeses_historia_grupo = 0;
LET pSituacion_pago_grupo = 0;
LET vlatitud  			  ="";
LET vlongitud 		      ="";
LET v_meses               =0;
LET v_cuantos             =0;							 

--INICIALIZACION DE VARIABLES DE CUENTA COPPEL        
LET cPuntualidadCoppel   		  	='';        
LET dEficienciaCoppel			  	= 0;       
LET dSituacionPagoCoppel		  	= "0"; 
LET cSituacionEspecial   		  	="?";
LET sCausaSituacion      		  	= 0;       
LET sHist_meses               	  	= 0;
LET dVencidoMuebles 	        	= 0;
LET dVencidoRopa 	        		= 0;
LET dVencidoAire             		= 0;
LET dVencidoPrestamos        		= 0;
LET dVencidoReestructura     		= 0;
LET dVencidoAfiliados    			= 0;

--INICIALIZACION DE VARIABLES DE BANCO

LET cProducto2				= "";  
LET iReprestamos           	= 0;
LET cSolBanco				= pNumSol; 
LET vClvEdoCob              ="";    
LET cEstado 				='';
LET cMunicipio 				='';                            
LET cMotivoRechBcpl 		= "0";
LET cDescripcion			="";
LET cRiesgoViviendaCpl  	=""; 
LET cRiesgoViviendaBcpl 	="";
LET cActRiesgoCpl       	="";
LET cActRiesgoBCpl			="";
LET cDescpRiesgo			= "";
LET cNumcredito 			= "";
LET v_comprobanco       	= 0;
LET v_compromi_tdc 			= 0;
LET dtMaxFechaCorte			= DATE(1);
LET cStatus_cred			= "";
LET cGrado_riesgo			= "";
LET dMto_reserva			= "";
LET dtFechaAper        		= DATE(1);
LET dSdo_vencido			= 0;
LET dSdo_vencidocrd			= 0;
LET v_capacidad_pago   		= 0;
LET iPlazo              	= 0;


--INICIALIZACION DE VARIABLES DE SOLICITUD
LET dtFechaSolicitud       = '01-01-1900';
LET dtDiaFF  			   = '01';
LET dtMesFF  			   = '01';
LET dtAnoFF		 	       = '1900';
LET cSucursal   	       ="";
LET iFlagEmpleado          =0; 
LET iCanal_Sol             ="0";
LET cTp_solicitud          ="?";
LET cNum_Producto          ="";
LET cStatusSolicitud       ="";
LET cPiloto 			   ="";
LET cCausa_Sol		       ="";
LET cTipoGrupo 		       ="";
LET cTicket				   =""; 
LET cEdo_proceso	   	   =""; 
LET cNum_men		       =""; 
LET cEmpresa		       =""; 
LET cNumSolRef             = '';

--INICIALIZACION DE VARIABLES DE PARAMETRICOS

LET BC_101             = 0;
LET dtFechaHoyAUX      = DATE(1);   
LET maxmoptot     	   = 0;
LET pmaxmop			   = 0;
LET pmaxmop1 		   = 0;

LET pmeses		       = 0;
LET Bandera			   = 0;
LET ki                 = 0;
LET kiz                = 0;

--INICIALIZACION DE VARIABLES DE EVALUACION
LET iExisteCliente    = 0;
LET dtasaMora 		  = 0;
LET mImporte_hip      = 0;
LET iMeses_hist_Val   = 0;
LET sCteLargo8		  = 0;
LET sCteLargo		  = 0;
LET vgrupoA 		  = 0;
LET v_moneda    	  = '';
LET v_monto 		  = 0;
LET v_total       	  = 0;
LET v_imp_hip    	  = 0;
LET v_factor    	  = 0;
LET v_tot_tp     	  = 0;

LET CadenaTl27 	= '';
LET CantTl27 	= 0;
LET v_SituacionPagoCoppel = 0;							

--parametros tdc visa Olivia

LET GEN1 = 0;  --MACM
LET GEN2 = 0;  --MACM
LET GEN3 = 0;  --MACM
LET iCertif = 0;	--MACM

-- INICIALIZACION DE NUEVAS VARIABLES PARA ADN
LET dIngresoAjsutado            = 0;
LET vTipoTransaccion            = '';
LET sIdentFalsa	                = '';
LET vTipoEmpCode                = '';
LET vTipoEmpName                = '';
LET iMoraCoppel                 = 0;
LET dSaldoVencido               = 0;
LET iMoraBanCoppel              = 0;
LET ivencidoBan				= 0;
LET ivencidoBancrd				= 0;
LET ivencidoBanCrdAuxAnt				= 0;
LET ivencidoBanAux				= 0;
LET ivencidoBanAuxAnt				= 0;
LET ivencidoBanCrdAux				= 0;
LET dSaldoVenBanCoppel          = 0;
LET dSaldoVenBanCoppelAux       = 0;
LET dSaldoVenBanCoppelAux2      = 0;
LET iFraudes                    = 0;
LET iFlagCreditoPPActivo        = 0;
LET iEstabilidadVivienda        = 0;
LET iListaNegra	                = 0;
LET cNoTramiteDia_TDC           = 0;
LET cNoTramiteDia_PP            = 0;
LET cTipoColectivo              = '';
LET dNum_consultasfinanciera    = 0;
LET sReestructura               = 0;
LET sQuebranto                  = 0;
LET dPromedioIngresoMUlt4d      = 0;
LET cContinuidadDepositosNomina = '';

LET iNumCteAux                  = 0;
LET iNumCuentaAux               = 0;
LET vTipoHitCalu				= 0;
LET scoreCalu					= 0;
LET cValidaINE			        = ""; 
LET pagosVencTDC				= 0;
LET pagosVencPP				    = 0;
LET dFechaAux           	    = DATE(1);
LET dIngresosNetosAux 			= 0;
LET iTipoListaNegra             = 0;
LET cMensajeListaNegra          = "";
LET cRfc                        = "";
LET cNombre1                    = "";
LET cNombre2                    = "";
LET cApellPaterno               = "";
LET cApellMaterno               = "";
LET dtFechaSolicitudAux         = DATE(1);
LET dtFechaSolicitudAux2        = DATE(1);
LET dtFechaAuxContinuidad		= DATE(1);
LET iAuxCont				    = 0;
LET dFechaIni            		= DATE(1);
LET dFechaFin           		= DATE(1);
LET iMontoTotAux                = 0;
LET dMontoTotAux                = 0;
LET iAux                        = 1;
LET iDiaHoy						= 0;
LET iDiaAyer						= 0;
LET vConsultaMoraBan            = '';
LET vDiaHoy			            = '';
LET vDiaAyer		            = '';


------------------------
--Cambios 120523
LET cnumcte_stdiq_consultassic			= '';
LET cnumcte_stdiq_MesesFechaConsulIq	= '';
LET cnum_clientetl_arrendamiento		= '';
LET cnumcte_stdiq_consultasfinanciera	= '';

--DECLARACION DE VARIABLES DE ERROR
LET iSqlErr  = 0;
LET iIsamErr = 0;
LET cCodRet  ="00000";
LET cMensaje_ret        = '';
LET v_respsic    = "";
LET v_valor_2s = 0;


BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr != 0 THEN
      ROLLBACK WORK;
			LET cCodRet = iSqlErr;
			RETURN  NVL(cCodRet,00000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
			nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cProfesion,''), NVL(sId_actividad,0), nvl(cDescAct,''), 
			NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), NVL(sCausaSituacion,-99), nvl(cMotivoRechBcpl,''), 
			nvl(sHist_meses,0), nvl(dEficienciaCoppel,0), nvl(iReprestamos,0), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), 
			NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''), nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(dSituacionPagoCoppel,"0"), 
			nvl(mIngreso_Mensual,0), nvl(sCteLargo8,0), nvl(iMeses_hist_Val,0), nvl(sFlagHuella,"0"),  nvl(cCod_Ult_Identif,0), 
			NVL(sValida_Cel,"0"),  NVL(dtFechaCte,'01-01-1900'), nvl(iCanal_Sol,"0"), nvl(cCompIngresos,''), NVL(sCompValido, 0), 
			NVL(cSucursal,''), nvl(dIngresoAjsutado,0), NVL(dtFechaNac,'01-01-1900'), NVL(cSexo,''), nvl(cEdo_Civil,''), 
			nvl(iTiem_Edo_Civil,-99), nvl(cOcupacion,''), nvl(iTiem_Ocupacion, -99), nvl(cEscolaridad,''), nvl(cTipoResidencia,''), 
			nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''), NVL(cEntidad,''), NVL(cCURP,''), 
			NVL(iFlagEmpleado,0), nvl(iExisteCliente,0), NVL(sEdadCte,0), nvl(vgrupoA,''), NVL(dtFechaSolicitud, '01-01-1900'), 
		    nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(cMunicipio,''), NVL(cEstado,''), nvl(iMoraCoppel,0), 
			nvl(dSaldoVencido,0), nvl(iMoraBanCoppel,0), nvl(dSaldoVenBanCoppel,0), NVL(vTipoTransaccion,""), nvl(iAntiguedad,0), 
			nvl(iFraudes,0), nvl(iFlagCreditoPPActivo,0), nvl(iEstabilidadVivienda,0), nvl(iListaNegra,0), nvl(cNoTramiteDia_TDC,0), 
			nvl(cNoTramiteDia_PP,0), nvl(cTipoColectivo,''), nvl(dNum_consultasfinanciera,0), nvl(sReestructura,0), nvl(sIdentFalsa,0), 
			nvl(sQuebranto,0), nvl(vTipoEmpCode,''), nvl(vTipoEmpName,''), nvl(dPromedioIngresoMUlt4d,0), nvl(cContinuidadDepositosNomina,'0'),
			nvl(origeninput1,''), nvl(origeninput2,''), nvl(origeninput3,''), nvl(origeninput4,''), nvl(origeninput5,0), 
			nvl(origeninput6,0), nvl(origeninput7,0), nvl(origeninput8,0);
		END IF;
	END EXCEPTION;
END

	--SET debug file to '/home/e99805455/sp_consultadatos_motor_adn'||trim(pNumSol)||'.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
	-----------------------------
	SELECT fecha_hoy
		INTO dtFechaHoyAUX
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pEmpresa;

---------------------------------------------------- VARIABLES DATOS DEL CLIENTE
		IF NVL(pEmpresa,'') = '' OR nvl(pNumSol,'') = '' THEN
			LET cCodRet = '020202';   

        ELSE
    		SELECT numcte, fecha_insert
    		INTO cNumCteBco, dtFechaSolicitud  
    		FROM bdisolic:"informix".ss_solicitudes 
    		WHERE empresa = pEmpresa 
			AND num_solicitud = pNumSol;

            SELECT  numcte_ref --Fecha de alta cliente 1ra vez
    		INTO  cNumCteComp
    		FROM bdinteg:"informix".si_cliente
    		WHERE numcte= cNumCteBco;

            IF 	NVL(cNumCteBco,'') = '' THEN
    			LET cCodRet = '030303';  ---REVISAR YA CHAR 5
				RETURN  NVL(cCodRet,00000), nvl(cSolBanco,''),	nvl(cNumCteBco,''),	nvl(cNumCte,''), nvl(pEmpresa,''), 
				nvl(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
				NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cProfesion,''), NVL(sId_actividad,0), nvl(cDescAct,''), 
				NVL(sId_subactividad,0), nvl(vDescSubAct,''), NVL(cSituacionEspecial,"?"), NVL(sCausaSituacion,-99), nvl(cMotivoRechBcpl,''), 
				nvl(sHist_meses,0), nvl(dEficienciaCoppel,0), nvl(iReprestamos,0), nvl(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), 
				NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''), nvl(cActRiesgoBCpl,''),	nvl(cDescpRiesgo,''), nvl(dSituacionPagoCoppel,"0"), 
				nvl(mIngreso_Mensual,0), nvl(sCteLargo8,0), nvl(iMeses_hist_Val,0), nvl(sFlagHuella,"0"),  nvl(cCod_Ult_Identif,0), 
				NVL(sValida_Cel,"0"),  NVL(dtFechaCte,'01-01-1900'), nvl(iCanal_Sol,"0"), nvl(cCompIngresos,''), NVL(sCompValido, 0), 
				NVL(cSucursal,''), nvl(dIngresoAjsutado,0), NVL(dtFechaNac,'01-01-1900'), NVL(cSexo,''), nvl(cEdo_Civil,''), 
				nvl(iTiem_Edo_Civil,-99), nvl(cOcupacion,''), nvl(iTiem_Ocupacion, -99), nvl(cEscolaridad,''), nvl(cTipoResidencia,''), 
				nvl(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''), NVL(cEntidad,''), NVL(cCURP,''), 
				NVL(iFlagEmpleado,0), nvl(iExisteCliente,0), NVL(sEdadCte,0), nvl(vgrupoA,''), NVL(dtFechaSolicitud, '01-01-1900'), 
				nvl(pMeses_historia_grupo,0), nvl(pSituacion_pago_grupo,0), NVL(cMunicipio,''), NVL(cEstado,''), nvl(iMoraCoppel,0), 
				nvl(dSaldoVencido,0), nvl(iMoraBanCoppel,0), nvl(dSaldoVenBanCoppel,0), NVL(vTipoTransaccion,""), nvl(iAntiguedad,0), 
				nvl(iFraudes,0), nvl(iFlagCreditoPPActivo,0), nvl(iEstabilidadVivienda,0), nvl(iListaNegra,0), nvl(cNoTramiteDia_TDC,0), 
				nvl(cNoTramiteDia_PP,0), nvl(cTipoColectivo,''), nvl(dNum_consultasfinanciera,0), nvl(sReestructura,0), nvl(sIdentFalsa,0), 
				nvl(sQuebranto,0), nvl(vTipoEmpCode,''), nvl(vTipoEmpName,''), nvl(dPromedioIngresoMUlt4d,0), nvl(cContinuidadDepositosNomina,'0'),
				nvl(origeninput1,''), nvl(origeninput2,''), nvl(origeninput3,''), nvl(origeninput4,''), nvl(origeninput5,0), 
				nvl(origeninput6,0), nvl(origeninput7,0), nvl(origeninput8,0);
    		END IF;
			
			
			SELECT count(*) INTO iCertif FROM bdisolic:"informix".ss_certif_evaluacion_cte_adn WHERE solicitudbancoppel_ss = pNumSol;
			IF iCertif > 0 THEN
				DELETE FROM bdisolic:"informix".ss_certif_evaluacion_cte_adn WHERE solicitudbancoppel_ss = pNumSol;  
				LET iCertif = 0;
			END IF;
			
			LET cValidaINE = '';
			FOREACH
				SELECT LIMIT 1 TRIM(NVL(resultado,''))
				INTO cValidaINE
				FROM bdinteg:"informix".si_bitacora_ife 
				WHERE numcte = cNumCteBco 
				ORDER BY fecha DESC
			END FOREACH

			LET cValidaINE = UPPER(cValidaINE);

			IF cValidaINE = 'TRUE' OR cValidaINE = 'VERDADERO' THEN
				LET cB_INE = 1;
				LET sIdentFalsa = 0;
			ELSE
				LET cB_INE = 0;
				LET sIdentFalsa = 1;
			END IF;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET b_ine = cB_INE --alter
				WHERE num_solicitud = pNumSol;
				--MACM SE CONSIDERO EN OBTENER EL NUMERO DE PARAMETRICO  

						
				-- *******************************************************************
				-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
				-- *******************************************************************
				-- Se obtiene el grupo
    			call bdisolic:"informix".sp_obtienegrupo (pNumSol)RETURNING cCodRet,cTipoGrupo,phit;	
    			UPDATE bdisolic:"informix".ss_resum_scor_fin
    			SET grupo = cTipoGrupo
    			WHERE empresa = pEmpresa AND num_solicitud = pNumSol;	
				--- fin de grupo														 

				--********SE agregan variables como lo hace el determina sp  *REVISAR SITUACION DE PAGO*
				SELECT situacion_pago, meses_historia, situacion_especial, causa, situacion_pago,
					   meses_historia, ingreso_mensual, meses_historia, situacion_pago, represtamo,
					   vencidomuebles, vencidoropa, vencidototalaire, vencidototalafiliados, vencidototalreestructura,
					   vencidoprestamos
				  INTO v_SituacionPagoCoppel, v_meses, cSituacionEspecial, sCausaSituacion, dEficienciaCoppel,
					sHist_meses, mIngreso_Mensual, pMeses_historia_grupo, pSituacion_pago_grupo, iReprestamos,
					dVencidoMuebles, dVencidoRopa, dVencidoAire, dVencidoAfiliados, dVencidoReestructura, 
					dVencidoPrestamos
					FROM bdisolic:"informix".ss_resum_scor_fin
					WHERE empresa =  pEmpresa
					AND num_solicitud = pNumSol;
					
				--SALDO_VENCIDO_COPPEL
				LET dSaldoVencido = dVencidoMuebles + dVencidoRopa + dVencidoPrestamos + dVencidoAire + dVencidoReestructura + dVencidoAfiliados;
				

				SELECT valor
				INTO v_cuantos
				FROM bdisolic:"informix".ss_param
				WHERE empresa = pEmpresa
				AND secuencia = 300;

				IF v_SituacionPagoCoppel IS NULL THEN
       				LET v_SituacionPagoCoppel= 0;
   				END IF;

				 -- clientes coppel sin compras, se le da tratamiento de cliente nuevo
			    IF ( v_SituacionPagoCoppel < 0  ) and cTp_solicitud NOT IN ('C') THEN
			       LET v_meses = 0;	
				   LET v_SituacionPagoCoppel = 0;
			    END IF;

			    IF (v_meses <= v_cuantos) and cTp_solicitud NOT IN ('C') THEN
			        LET iAntiguedad = 1;					
			    END IF;

			    -- se les asigno iAntiguedad = "0";
			    -- a los clientes con 1 mes de antiguedad
			    -- lalo 28jun07
			    IF (v_meses = 1) and cTp_solicitud NOT IN ('C') THEN
			        LET iAntiguedad = 0;					
			    END IF;

            SELECT NVL(e.rango_minimo, 0) --Tiempo Estado Civil
				INTO iTiem_Edo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 4
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;

				------------------------		
			SELECT NVL(e.rango_minimo,-99) --Tiempo Estado Civil Meses
				INTO iTiem_Edo_Civil_meses
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 41
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;

			IF iTiem_Edo_Civil_meses = 12 AND (iTiem_Edo_Civil = 0 OR iTiem_Edo_Civil IS NULL OR iTiem_Edo_Civil = 16) THEN
				IF iTiem_Edo_Civil IS NULL THEN -- Si es nulo tiempo estado civil, registrar elemento ya que no tiene asignado ese grupo.
					INSERT INTO bdisolic:"informix".ss_detalle_scoring VALUES('001', 2, 4, 17, '01', pNumSol, 0);  --Estimated Cost: 50469000
				END IF;

				SELECT NVL(e.rango_minimo, 0) --Tiempo Estado Civil
				INTO iTiem_Edo_Civil
				FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
				WHERE d.grupo = 4
				AND e.grupo = d.grupo 
				AND e.elemento = d.elemento
				AND e.seccion = d.seccion 
				AND d.num_solicitud = pNumSol;
				--LET iTiem_Edo_Civil = 17;
			END IF;

			FOREACH 
					SELECT  LIMIT 1 catciu.numeroestado || '-' || trim(catciu.inicialestado) Estado, nvl(trim(ciu.nombre),'')
					INTO vClvEdoCob, vLocalidad --Localidad y Estado de cobranza
					FROM bdinteg:"informix".si_direcciones_actual dir
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
					LEFT OUTER JOIN bdinteg:"informix".si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
					WHERE dir.numcte = cNumCteBco 
					AND dir.tipo_dir='1'
					order by dir.fecha_insert desc
			END FOREACH;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET ClvEdoCob = vClvEdoCob,
					localidad = vLocalidad --alter
				WHERE num_solicitud = pNumSol;

			FOREACH
				SELECT LIMIT 1 nvl(z.municipiozona, '')
				INTO  cMunicipio
				FROM bdinteg:"informix".si_cliente a
					LEFT OUTER JOIN bdinteg:"informix".si_direcciones_actual d ON (d.numcte = a.numcte)
					LEFT OUTER JOIN bdinteg:"informix".si_ciudades cd ON (cd.ciudad = d.ciudad) AND (cd.estado = d.estado)  and (cd.pais = d.pais)      
					LEFT OUTER JOIN bdinteg:"informix".si_estados e ON (e.estado = d.estado) and (e.pais = d.pais) 
					LEFT OUTER JOIN bdinteg:"informix".si_catzonas z ON (d.numerociudad = z.numerociudad AND d.numerocolonia = z.numerocolonia)
				WHERE a.NumCte = cNumCteBco
				AND nvl(d.tipo_dir,'') = '1'
				order by d.fecha_insert desc
			END FOREACH;
						
			EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cMunicipio)
			into cMunicipio;

			SELECT  count(numcte) --Cantidad de celulares activos y validados
				INTO sValida_Cel
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 2
				AND status_tel = 'A'
				AND cofetel = 'V';

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET valida_cel = sValida_Cel 
				WHERE num_solicitud = pNumSol;

			SELECT CASE WHEN LENGTH(TRIM(telefono)) > 10 THEN SUBSTR(TRIM(telefono),LENGTH(TRIM(telefono))-9,10) else telefono END
				into cNumCel 
				FROM bdinteg:"informix".si_telefonos_actual
				WHERE numcte = cNumCteBco
				AND tipo_tel = 2
				AND status_tel = 'A'
				AND cofetel = 'V'; 			

			SELECT COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanconomatch
				WHERE numcte = cNumCteBco
				AND tipo = 6;
					
			IF vHuella = 0 THEN
				SELECT COUNT(numcte)
				INTO vHuella
				FROM bdinteg:"informix".si_clientecomparacionbanco
				WHERE numcte = cNumCteBco
				AND tipo = 7;
				IF vHuella > 0 THEN
					LET sFlagHuella = "1";
				END if;
			END if;
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_ConsultaReferencias (pEmpresa, cNumCteBco)
				INTO cCodRet,iReferencia1,iReferencia2;
			
			SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea  -- SE OBTIENE EL TICKET CON EL NUM. DE CLIENTE
				WHERE numcte = cNumCteBco;	
					
			IF NVL(cTicket,"") = '' THEN -- SI NO SE ENCUENTRA EN LA si_huella_linea SE BUSCA EN si_huella_linea_hist
				SELECT ticket 
				INTO cTicket
				FROM bdinteg:"informix".si_huella_linea_hist a   
				WHERE numcte = cNumCteBco								 
				AND fecha_consulta = (SELECT MAX(fecha_consulta)
										FROM bdinteg:"informix".si_huella_linea_hist b 
										WHERE   numcte = cNumCteBco)
				AND secuencia = (SELECT MAX(secuencia)
									FROM bdinteg:"informix".si_huella_linea_hist c 
									WHERE  numcte = cNumCteBco);
			END IF;

            IF NVL(cTicket,"") <> "" THEN   -- CON EL TICKET SE VALIDA QUE LA HUELLA NO CORRESPONDA A EMPLEADOS 
				
				SELECT LIMIT 1 estado_proceso, num_mensaje, empresa 
					INTO cEdo_proceso, cNum_men, cEmpresa
					FROM bdinteg:"informix".si_huella_linea_resultado 
					WHERE ticket = cTicket
					AND estado_proceso = '2'
					AND empresa IN (0,1,2,3)
					AND num_mensaje = "602";

				IF 	NVL(cEdo_proceso,"") <> "" AND NVL(cNum_men,"") <> ""  AND 	NVL(cEmpresa,"") <> "" THEN
					LET iFlagEmpleado = 1;
				END if;
			END if;

			------------------------------------------------------VARIABLES DE SOLICITUD
			
			FOREACH
				SELECT COUNT(numcte) 
				INTO iExisteCliente
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = cNumCteBco
				AND num_solicitud <> pNumSol 
				AND  tipo_solicitud = "C"
				AND status_solicitud NOT IN ('PC','AN','MC')
			END FOREACH;

			UPDATE bdisolic:"informix".ss_revision_determinacion 
				SET existecliente = iExisteCliente --alter
				WHERE num_solicitud = pNumSol;

			LET pNumSol = pNumSol;
			LET cNumSolRef = cNumSolRef;

			-- Determina si es grupo A  -- sDeter_Grupo_A
			SELECT COUNT(numcte) 
				INTO vgrupoA
				FROM bdicred:"informix".sd_grupo_cliente 
				WHERE empresa = pEmpresa
				AND numcte  = cNumCteBco;

			EXECUTE PROCEDURE bdinteg:"informix".mesesvalidoscte (cNumCteBco)
				INTO cCodRet,iMeses_hist_Val;
				
				
			SELECT count(ctesl.numcte) , count(ctes2.numcte)
                INTO sCteLargo,sCteLargo8
                FROM bdisolic:"informix".ss_clienteslargos ctesl-- Agrupar 2 consultas
                LEFT JOIN bdisolic:"informix".ss_clienteslargos ctes2 on (ctes2.numcte = cNumCteBco AND ctes2.fecha_vig_ini<= dtFechaHoy AND ctes2.fecha_vig_fin >= dtFechaHoy AND ctes2.status = 'AC')
                WHERE ctesl.numcte = cNumCteBco     
                AND ctesl.fecha_vig_ini<= dtFechaHoy 
                AND ctesl.fecha_vig_fin >= dtFechaHoy;
				
			------------------------------------------------------ NUEVAS VARIABLES ADN
			--cCompIngresos       
			SELECT a.numcte,a.sucursal,a.num_producto,a.tipo_solicitud, a.status_solicitud,NVL(comprobante_valido_cac,"N") 
				INTO cNumCte,cSucursal,cNum_Producto,cTp_solicitud,cStatusSolicitud,cCompIngresos
				FROM bdisolic:"informix".ss_solicitudes a
				LEFT OUTER JOIN	bdisolic:"informix".ss_solicitudes_cac b ON ( a.num_solicitud = b.num_solicitud)
				WHERE a.num_solicitud = pNumSol AND a.empresa = pEmpresa;   --Estimated Cost: 533443

			
			--cProfesion
			 SELECT TRIM(habita_en), codidentifi, curp, profesion 
				INTO cHabita_en, cCod_Ult_Identif, cCurp, cProfesion 
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte = cNumCte;	
				
				--sCompValido
			EXECUTE PROCEDURE bdisolic:"informix".sp_valida_comprobante(pEmpresa, cNumCte, pNumSol) 
				INTO cCodRet, cMensaje_ret, sCompValido;
				
													
			------------------------------------------------------ NUEVAS VARIABLES ADN	
			--MORA_COPPEL
			
			--iMoraBanCoppel
			
			FOREACH
			
			SELECT num_credito INTO cNumcredito
			FROM bdicred:"informix".sd_maecred
			WHERE empresa = pEmpresa
			AND numcte = cNumCteBco
			AND status_cred IN ("E1","E2","E3")
			
			SELECT mto_fin_ven_trasp INTO ivencidoBanAux
				FROM bdicred:"informix".sd_maesdos	
				WHERE num_credito = cNumcredito;
				
				IF ivencidoBanAux IS NULL OR ivencidoBanAux = '' THEN
					LET ivencidoBanAux = 0;
				END IF;
				
				IF	ivencidoBanAux > ivencidoBanAuxAnt THEN
					IF ivencidoBanAux > ivencidoBan THEN
					LET ivencidoBan = ivencidoBanAux;
					END IF;
				ELSE
					IF ivencidoBanAuxAnt > ivencidoBan THEN
					LET ivencidoBan = ivencidoBanAuxAnt;
					END IF;
				END IF;
				
			
			SELECT mto_fin_ven_trasp INTO ivencidoBanCrdAux
				FROM bdicred:"informix".sd_maesdoscrd
				WHERE num_credito = cNumcredito;
				
				IF ivencidoBanCrdAux IS NULL OR ivencidoBanCrdAux = '' THEN
					LET ivencidoBanCrdAux = 0;
				END IF;
				
				IF	ivencidoBanCrdAux > ivencidoBanCrdAuxAnt THEN
					IF ivencidoBanCrdAux > ivencidoBanCrd THEN
					LET ivencidoBanCrd = ivencidoBanCrdAux;
					END IF;
				ELSE
					IF ivencidoBanCrdAuxAnt > ivencidoBanCrd THEN
					LET ivencidoBanCrd = ivencidoBanCrdAuxAnt;
					END IF;
				END IF;
								
			END FOREACH;
			
			IF ivencidoBanCrd > ivencidoBan THEN
				LET iMoraBanCoppel = ivencidoBanCrd;
			ELSE
				LET iMoraBanCoppel = ivencidoBan;
			END IF;
			
			
			--SALDO_VENCIDO_BANCOPPEL
			
			SELECT  NVL(SUM(NVL(monto_vencido,0)),0)
				INTO dSaldoVenBanCoppelAux
				FROM bdicred:"informix".sd_maesdoscrd maes 
				inner join bdicred:"informix".sd_maecredcrd cred on (maes.num_credito = cred.num_credito)
				WHERE cred.empresa = pEmpresa
				AND cred.numcte = cNumCteBco 
				AND cred.status_cred IN ("E1","E2","E3");
				--AND cred.status_cred NOT IN ("CC","FF"); --SUMAR LAS DOS CONSULTAS

			SELECT  NVL(SUM(NVL(monto_vencido,0)),0)  --QUITAR mto_venc_trasp
				INTO dSaldoVenBanCoppelAux2
				FROM bdicred:"informix".sd_maesdos maes 
				inner join bdicred:"informix".sd_maecred cred on (maes.num_credito = cred.num_credito)
				WHERE cred.empresa = pEmpresa
				AND cred.numcte = cNumCteBco 
				AND cred.status_cred IN ("E1","E2","E3");
				--AND cred.status_cred NOT IN ("CC","FF");
				
			LET dSaldoVenBanCoppel = dSaldoVenBanCoppelAux + dSaldoVenBanCoppelAux2;	
				
			--TIPO_EMPEADO_NAME	
			--TIPO_TRANSACCION			
			
			SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
			INTO vTipoTransaccion, dIngresoAjsutado, iCuentaCte
			FROM bdicheq:"informix".sc_nom_disp_cte
			WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN'
			AND ingresos_netos = (SELECT MAX(ingresos_netos) 
			FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'PEN');
						
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET vTipoTransaccion = '';
				LET dIngresoAjsutado = 0;
			END IF;
					
			IF vTipoTransaccion = '' AND dIngresoAjsutado = 0 THEN
								
				SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
				INTO vTipoTransaccion, dIngresoAjsutado, iCuentaCte
				FROM bdicheq:"informix".sc_nom_disp_cte
				WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB'
				AND ingresos_netos = (SELECT MAX(ingresos_netos) 
				FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EPB');
									
			END IF;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET vTipoTransaccion = '';
				LET dIngresoAjsutado = 0;
			END IF;
				
			IF vTipoTransaccion = '' AND dIngresoAjsutado = 0 THEN
				
				SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
				INTO vTipoTransaccion, dIngresoAjsutado, iCuentaCte
				FROM bdicheq:"informix".sc_nom_disp_cte
				WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP'
				AND ingresos_netos = (SELECT MAX(ingresos_netos) 
				FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'EGP');
						 
					
			END IF;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
				LET vTipoTransaccion = '';
				LET dIngresoAjsutado = 0;
			END IF;
				
			IF vTipoTransaccion = '' AND dIngresoAjsutado = 0 THEN
			
				SELECT LIMIT 1 tipo_transaccion, ingreso_ajustado, cuenta
				INTO vTipoTransaccion, dIngresoAjsutado, iCuentaCte
				FROM bdicheq:"informix".sc_nom_disp_cte
				WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW'
				AND ingresos_netos = (SELECT MAX(ingresos_netos) 
				FROM bdicheq:"informix".sc_nom_disp_cte WHERE numcte = cNumCteBco AND UPPER(tipo_transaccion) = 'SDW');	
				
			END IF;						
			  	
			IF NVL(dIngresoAjsutado,0) = 0 THEN
				LET dIngresoAjsutado = 0;
			END IF;
			
			--TIPO_EMPLEADO_CODE					
			IF vTipoTransaccion = 'EPB' THEN
				LET vTipoEmpCode = '001';
			ELIF vTipoTransaccion = 'PEN' THEN
				LET vTipoEmpCode = '002';
			ELIF vTipoTransaccion = 'SDW' THEN
				LET vTipoEmpCode = '003';
			ELIF vTipoTransaccion = 'EGP' THEN
				LET vTipoEmpCode = '004';
			ELSE
				LET vTipoEmpCode = '';  
			END IF;
			
			SELECT descripcion INTO vTipoEmpName FROM bdicheq:"informix".sc_nomina_tipoctes WHERE clave_tipo = vTipoTransaccion;
			
			IF NVL(vTipoEmpName,'') = '' THEN
				LET vTipoEmpName = '';
			END IF;
			
			LET vTipoTransaccion = vTipoEmpName;
			

			--ANTIGUEDAD
				SELECT noc.fecha_alta
				INTO dtFechaAntiguedadAUX   
				FROM bdicheq:"informix".sc_maechq mae
				INNER JOIN bdicheq:"informix".sc_maenoc noc ON noc.cuenta = mae.cuenta
				WHERE mae.num_cte = cNumCteBco AND mae.cuenta = iCuentaCte AND mae.status_cta ='1';
			
			LET iAntiguedad = months_between(dtFechaHoyAUX, dtFechaAntiguedadAUX);
			
			IF NVL(iAntiguedad,0) = 0 THEN
				LET iAntiguedad = 0;
			END IF;
			
			--Flag_creditoPP_Activo	
			SELECT COUNT (MAEDOS.num_credito) INTO iFlagCreditoPPActivo      
				FROM bdicred:"informix".sd_maecredcrd AS MAECRE
				INNER JOIN bdicred:"informix".sd_maesdoscrd AS MAEDOS ON MAEDOS.num_credito = MAECRE.num_credito          
				WHERE MAEDOS.num_credito = pNumSol AND MAECRE.status_cred IN ("E1","E2","E3") AND
				MAEDOS.sdo_cap_insoluto > 0 AND num_producto 
				IN (SELECT num_producto FROM bdicred:"informix".sd_definicion 
                WHERE cod_tipcred='05' 
                AND familia IN (select id_familia from bdicred:"informix".sd_familia_productos 
                WHERE id_familia IN ('002','003'))); 
				
				--IN (SELECT num_producto FROM bdicred:"informix".sd_definicion AS A  --Se moviÃ³ para revisar como se comporta el costeo
				--INNER JOIN bdicred:"informix".sd_familia_productos AS B ON A.familia = B.id_familia
				--WHERE b.id_familia IN ('002', '003') AND a.cod_tipcred='05');
				
				/*
				SELECT * FROM bdicred:sd_definicion 
				WHERE cod_tipcred='05' 
				AND familia IN (select id_familia from bdicred:sd_familia_productos 
				WHERE id_familia IN ('002','003'))
				*/
				
			IF iFlagCreditoPPActivo > 0 THEN
				LET iFlagCreditoPPActivo = 1;
			ELSE 
				LET iFlagCreditoPPActivo= 0;
			END IF;		
			
			--EstabilidadVivienda
			
			SELECT TRIM(substr(ele.descripcion,1,2)) 
				INTO iEstabilidadVivienda 
				FROM bdisolic:"informix".ss_detalle_scoring det
				INNER JOIN BDISOLIC:ss_scoring_element ele on  ele.elemento = det.elemento and det.grupo = ele.grupo
				WHERE det.empresa = pEmpresa  AND det.num_solicitud = pNumSol
				AND det.grupo = 6 and ele.seccion = 2;
				
			IF	iEstabilidadVivienda > 0 THEN
				LET iEstabilidadVivienda = iEstabilidadVivienda * 12;
			END IF;
			
			--Lista negra
			EXECUTE PROCEDURE bdiauditor:"informix".sp_perfisica_listanegra(cRfc, cNombre1, cNombre2, cApellPaterno, cApellMaterno, dtFechaNac)
			INTO cCodRet,cMensajeListaNegra,iListaNegra,iTipoListaNegra; 
			
			--NO_TRAMITEDIA_TDC
			SELECT count(num_solicitud)
				INTO cNoTramiteDia_TDC
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = cNumCteBco AND DATE(fecha_insert) >=  DATE(TODAY - 30 UNITS day)
				AND num_producto IN (SELECT num_producto FROM bdicred:"informix".sd_definicion 
				WHERE cod_tipcred='03' 
				AND familia IN (select id_familia from bdicred:"informix".sd_familia_productos 
				WHERE id_familia IN ('001'))); --Familia TDC

			
			--NO_TRAMITEDIA_PP
			SELECT COUNT(num_solicitud)
				INTO cNoTramiteDia_PP 
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE numcte = cNumCteBco
				and DATE(fecha_insert) >=  DATE(TODAY - 30 UNITS day)
				AND num_producto IN (SELECT num_producto FROM bdicred:"informix".sd_definicion 
                WHERE cod_tipcred='05' 
                AND familia IN (select id_familia from bdicred:"informix".sd_familia_productos 
                WHERE id_familia IN ('002','003'))); --Familia prestamos
			
			--num_consultasfinanciera
			 --11 NÃºmero de consultas por tipo de negocio Financiera  cambios 120523
                LET dNum_consultasfinanciera = 0; 
                LET cnumcte_stdiq_consultasfinanciera = ''; 
				                  
                        FOREACH
                            SELECT COUNT (numcte_stdiq)
								INTO dNum_consultasfinanciera
                                FROM bdiburo:"informix".br_iq_estand
                                WHERE empresa_stdiq = pEmpresa
                                AND numcte_stdiq = cNumCteBco
                                AND iq02_std IN ('FF')
                        END FOREACH;
						
					IF NVL(cnumcte_stdiq_consultasfinanciera,'') = '' THEN
                        LET dNum_consultasfinanciera = -1;	
                    END IF;
							
							
			--REESTRUCTURAS
			SELECT COUNT(num_solicitud)
				INTO sReestructura
				FROM bdisolic:"informix".ss_solicitudes 
				WHERE num_producto IN ('6011', '8600') AND status_solicitud = 'AP' AND numcte = cNumCteBco;
			
			--QUEBRANTO
			
			-- Quebranto PP
			SELECT MAX(maes.mto_fin_ven_trasp) INTO pagosVencPP
			FROM bdicred:"informix".sd_maesdoscrd maes 
			inner join bdicred:"informix".sd_maecredcrd cred on (maes.num_credito = cred.num_credito)
			WHERE cred.empresa = '001'
			AND cred.numcte = cNumCteBco 
			AND cred.status_cred IN ("E1","E2","E3");
			--AND cred.status_cred NOT IN ("CC","FF");

			-- Quebranto TDC
			SELECT MAX(maes.mto_fin_ven_trasp) INTO pagosVencTDC
			FROM bdicred:"informix".sd_maesdos maes 
			inner join bdicred:"informix".sd_maecred cred on (maes.num_credito = cred.num_credito)
			WHERE cred.empresa = '001'
			AND cred.numcte = cNumCteBco 
			AND cred.status_cred IN ("E1","E2","E3");
			--AND cred.status_cred NOT IN ("CC","FF");
			
			
			IF pagosVencPP >= 8 THEN
				LET sQuebranto = 1;
			ELIF pagosVencTDC >= 8 THEN
				LET sQuebranto = 1;
			ELSE	
				LET sQuebranto = 0;
			END IF;
			
			--dPromedioIngresoMUlt4d;
		    --cContinuidadDepositosNomina;
			WHILE iAuxCont <= 24 --Meses
			
				LET iAuxCont = iAuxCont + 1;
				LET dMontoTotAux = 0;
				
				EXECUTE PROCEDURE bdicred:"informix".monthadd(dtFechaSolicitud, -iAuxCont) 
				INTO dtFechaSolicitudAux; 
				
				LET dFechaIni =  MDY(MONTH(dtFechaSolicitudAux), 1, YEAR(dtFechaSolicitudAux));
				LET dFechaFin =  LAST_DAY(dtFechaSolicitudAux);
					
				SELECT LIMIT 1 scm.fech_alt
					INTO dtFechaAuxContinuidad
					FROM bdicheq:"informix".sc_movhis AS scm
					INNER JOIN bdinteg:"informix".si_transacc AS sit ON scm.transacc = sit.numero
					WHERE scm.transacc in ('0293','0287') AND scm.cuenta = iCuentaCte 
					AND scm.fech_alt BETWEEN dFechaIni AND dFechaFin
					AND sit.descripcion = 'DEPOSITO POR PAGO DE NOMINA';	
				
				IF (dtFechaAuxContinuidad IS NULL) OR (dtFechaAuxContinuidad = '') THEN
					LET cContinuidadDepositosNomina = cContinuidadDepositosNomina||"0"; 
				ELSE
					LET cContinuidadDepositosNomina = cContinuidadDepositosNomina||"1"; 
				END IF;
				
				IF iAuxCont <= 4 THEN
				
					SELECT SUM(scm.monto_tot)   --Estimated Cost: 2219
					INTO dMontoTotAux
					FROM bdicheq:"informix".sc_movhis AS scm
					INNER JOIN bdinteg:"informix".si_transacc AS sit ON scm.transacc = sit.numero
					WHERE scm.transacc in ('0293','0287') AND scm.cuenta = iCuentaCte 
					AND scm.fech_alt BETWEEN dFechaIni AND dFechaFin
					AND sit.descripcion = 'DEPOSITO POR PAGO DE NOMINA';
				
					IF (dMontoTotAux IS NOT NULL) OR (dMontoTotAux > 0) THEN
						LET iMontoTotAux = iMontoTotAux + 1;
					ELSE 
						LET dMontoTotAux = 0;
					END IF;
				
					LET dPromedioIngresoMUlt4d = dPromedioIngresoMUlt4d + dMontoTotAux;
				
				END IF;	
			
			END WHILE;
			
			IF iMontoTotAux > 0 THEN
			
				LET dPromedioIngresoMUlt4d = dPromedioIngresoMUlt4d/iMontoTotAux;
				
				LET dPromedioIngresoMUlt4d = dPromedioIngresoMUlt4d/10000;
				
				LET dPromedioIngresoMUlt4d = ROUND(dPromedioIngresoMUlt4d,2);
				
				LET dPromedioIngresoMUlt4d = dPromedioIngresoMUlt4d*100;
				
			ELSE 
			
				LET dPromedioIngresoMUlt4d = 0;
			
			END IF;
				
			------------------------------------------------------ VARIABLES DE BANCOPPEL

			EXECUTE PROCEDURE bdinteg:"informix".sp_consulta_act_riesgo( pEmpresa,cNumCteBco) -- Nota obtener consultas
			INTO cCodRet,cDescripcion,cRiesgoViviendaCpl,cRiesgoViviendaBcpl,cActRiesgoCpl,cActRiesgoBCpl,cDescpRiesgo;
		
			LET cCodRet = '00000';
			--------------
			
			--ELIMINAMOS COMAS
			LET cSolBanco                   = REPLACE(cSolBanco, ',', '');
			LET cNumCteBco        			= REPLACE(cNumCteBco, ',', '');
			LET cNumCte           			= REPLACE(cNumCte, ',', '');
			LET pEmpresa          			= REPLACE(pEmpresa, ',', '');
			LET cStatusSolicitud  			= REPLACE(cStatusSolicitud, ',', '');
			LET cCausa_Sol        			= REPLACE(cCausa_Sol, ',', '');
			LET cNum_Producto     			= REPLACE(cNum_Producto, ',', '');
			LET cTipoGrupo        			= REPLACE(cTipoGrupo, ',', '');
			LET cTp_solicitud     			= REPLACE(cTp_solicitud, ',', '');
			LET cHabita_en        			= REPLACE(cHabita_en, ',', '');
			LET cProfesion        			= REPLACE(cProfesion, ',', '');
			LET cDescAct       	  			= REPLACE(cDescAct, ',', '');
			LET vDescSubAct       			= REPLACE(vDescSubAct, ',', '');
			LET cSituacionEspecial       	= REPLACE(cSituacionEspecial, ',', '');
			LET cMotivoRechBcpl       		= REPLACE(cMotivoRechBcpl, ',', '');
			LET cDescripcion       			= REPLACE(cDescripcion, ',', '');
			LET cRiesgoViviendaCpl       	= REPLACE(cRiesgoViviendaCpl, ',', '');
			LET cRiesgoViviendaBcpl       	= REPLACE(cRiesgoViviendaBcpl, ',', '');
			LET cActRiesgoCpl       		= REPLACE(cActRiesgoCpl, ',', '');
			LET cActRiesgoBCpl       		= REPLACE(cActRiesgoBCpl, ',', '');
			LET cDescpRiesgo       			= REPLACE(cDescpRiesgo, ',', '');
			LET dSituacionPagoCoppel       	= REPLACE(dSituacionPagoCoppel, ',', '');
			LET sFlagHuella       			= REPLACE(sFlagHuella, ',', '');
			LET cCod_Ult_Identif       		= REPLACE(cCod_Ult_Identif, ',', '');
			LET sValida_Cel       			= REPLACE(sValida_Cel, ',', '');
			LET dtFechaCte       			= REPLACE(dtFechaCte, ',', '');
			LET iCanal_Sol       			= REPLACE(iCanal_Sol, ',', '');
			LET cCompIngresos       		= REPLACE(cCompIngresos, ',', '');
			LET cSucursal       			= REPLACE(cSucursal, ',', '');
			LET dtFechaNac       			= REPLACE(dtFechaNac, ',', '');
			LET cSexo       				= REPLACE(cSexo, ',', '');
			LET cEdo_Civil       			= REPLACE(cEdo_Civil, ',', '');
			LET cOcupacion       			= REPLACE(cOcupacion, ',', '');
			LET cEscolaridad       			= REPLACE(cEscolaridad, ',', '');
			LET cTipoResidencia       		= REPLACE(cTipoResidencia, ',', '');
			LET vClvEdoCob       			= REPLACE(vClvEdoCob, ',', '');
			LET vLocalidad       			= REPLACE(vLocalidad, ',', '');
			LET cEntidad       				= REPLACE(cEntidad, ',', '');
			LET cCURP       				= REPLACE(cCURP, ',', '');
			LET dtFechaSolicitud       		= REPLACE(dtFechaSolicitud, ',', '');
			LET cMunicipio       			= REPLACE(cMunicipio, ',', '');
			LET cEstado       				= REPLACE(cEstado, ',', '');
			LET vTipoTransaccion       		= REPLACE(vTipoTransaccion, ',', '');
			LET cTipoColectivo       		= REPLACE(cTipoColectivo, ',', '');
			LET vTipoEmpCode       			= REPLACE(vTipoEmpCode, ',', '');
			LET vTipoEmpName       			= REPLACE(vTipoEmpName, ',', '');
			LET cContinuidadDepositosNomina = REPLACE(cContinuidadDepositosNomina, ',', '');
			LET origeninput1       			= REPLACE(origeninput1, ',', '');
			LET origeninput2       			= REPLACE(origeninput2, ',', '');
			LET origeninput3       			= REPLACE(origeninput3, ',', '');
			LET origeninput4       			= REPLACE(origeninput4, ',', '');
			
			------------------------------------------------------ VARIABLES DE EVALUACION
			
			INSERT INTO bdisolic:"informix".ss_certif_evaluacion_cte_adn 
			(solicitudbancoppel_ss,clientebancoppel_ss,clientecoppel_ss,empresa_ss,estatussolicitud_ss,
			causasolicitud_ss,producto_ss,grupo_ss,tiposolicitud_ss,banderaine_ss,
			habitaen_ss,profesion_ss,idactividad_ss,descripactividad_ss,idsubactividad_ss,
			descripsubactividad_ss,situacionespecialcoppel_ss,causasitespecialcoppel_ss,motivorechazobcpl_ss,meseshistoria_ss,
			eficiencia_ss,flagprestamos_ss,descripcioncodigo_ss,riesgoviviendacoppel_ss,riesgoviviendabancoppel_ss,
			actividadriesgocoppel_ss,actividadriesgobancoppel_ss,descripcionriesgo_ss,situacionpago_ss,ingresomensual_ss,
			conteoclientelargo_ss,mesesvalidos_ss,flagcoincidehuella_ss,codidentifii_ss,ivalidacel_ss,
			fechacliente_ss,canal_ss,Compingresos_ss,comprobantevalido_ss,sucursal_ss,
			ingreso_ajustado_ss,fechanacimiento_ss,genero_ss,estadocivil_ss,tiempoestadocivil_ss,
			ocupacion_ss,tiempoocupacion_ss,escolaridad_ss,tiporesidencia_ss,tiemporesidencia_ss,
			clave_ss,localidad_ss,entidad_ss,curp_ss,flagEmpleado_ss,
			iexistecliente_ss,edad_ss,vgrupoa_ss,fechasolicitud_ss,meses_historia_grupo_ss,
			situacion_pago_grupo_ss,municipio_ss,estado_ss,mora_coppel_ss,saldo_vencido_coppel_ss,
			mora_bancoppel_ss,saldo_vencido_bancoppel_ss,tipo_transaccion_ss,antiguedad_ss,fraudes_ss,
			flag_creditopp_activo_ss,estabilidadvivienda_ss,lista_negra_ss,no_tramitedia_tdc_ss,no_tramitedia_pp_ss,
			tipo_colectivo_ss,num_consultasfinanciera_ss,reestructuras_ss,identificacion_falsa_ss,quebranto_ss,
			tipo_empleado_code_ss,tipo_empleado_name_ss,promedio_ingresom_ult4d_ss,continuidad_depositos_nomina_ss,origeninput1_ss,
			origeninput2_ss,origeninput3_ss,origeninput4_ss,origeninput5_ss,origeninput6_ss,
			origeninput7_ss,origeninput8_ss, fecha_insert) VALUES(
			cSolBanco, cNumCteBco, cNumCte, pEmpresa, cStatusSolicitud, 
			cCausa_Sol, cNum_Producto, cTipoGrupo, cTp_solicitud, cB_INE, 
			cHabita_en, cProfesion, sId_actividad, cDescAct, sId_subactividad,
            vDescSubAct, cSituacionEspecial, sCausaSituacion, cMotivoRechBcpl, sHist_meses,
			dEficienciaCoppel, iReprestamos, cDescripcion, cRiesgoViviendaCpl, cRiesgoViviendaBcpl,
			cActRiesgoCpl, cActRiesgoBCpl, cDescpRiesgo, dSituacionPagoCoppel, mIngreso_Mensual, 
			sCteLargo8, iMeses_hist_Val, sFlagHuella, cCod_Ult_Identif, sValida_Cel, 
            dtFechaCte,  iCanal_Sol, cCompIngresos, sCompValido, cSucursal, 
	        dIngresoAjsutado, dtFechaNac, cSexo, cEdo_Civil, iTiem_Edo_Civil, 
	        cOcupacion, iTiem_Ocupacion, cEscolaridad, cTipoResidencia, iTiem_Residencia, 
	        vClvEdoCob, vLocalidad, cEntidad, cCURP, iFlagEmpleado, 
			iExisteCliente, sEdadCte, vgrupoA, dtFechaSolicitud, pMeses_historia_grupo, 
	        pSituacion_pago_grupo, cMunicipio, cEstado, iMoraCoppel, dSaldoVencido, 
            iMoraBanCoppel, dSaldoVenBanCoppel, vTipoTransaccion, iAntiguedad, iFraudes, 
            iFlagCreditoPPActivo, iEstabilidadVivienda, iListaNegra, cNoTramiteDia_TDC, cNoTramiteDia_PP, 
            cTipoColectivo, dNum_consultasfinanciera, sReestructura, sIdentFalsa, sQuebranto, 
            vTipoEmpCode, vTipoEmpName, dPromedioIngresoMUlt4d, cContinuidadDepositosNomina, origeninput1,              
            origeninput2, origeninput3,	origeninput4, origeninput5, origeninput6,
            origeninput7, origeninput8, current);		
			
			LET cNumCteBcoN = cNumCteBco;
			
			EXECUTE PROCEDURE bdisolic:"informix".calulavariables_modelo2_pp (pEmpresa,pNumSol)  --*****EN REVISION
				INTO cCodRet, vTipoHitCalu, scoreCalu;
			
			SELECT count(num_solicitud)
			INTO v_valor_2s
			FROM bdisolic:"informix".ss_resumen_scoring
			WHERE num_solicitud = pNumsol
			AND seccion = 2;
			
			IF NVL(v_valor_2s,0) = 0 THEN
				--Se inserta valor de la seccion 2
				INSERT INTO bdisolic:"informix".ss_resumen_scoring (empresa, num_solicitud, seccion, evaluacion)  --Estimated Cost: 13602179
				VALUES (pEmpresa, pNumSol, 2, scoreCalu);
			END IF;
			
			LET pNumSol = pNumSol;
            LET cNumCteBcoN = cNumCteBcoN;

			--MACM obtener informacion de la tabla de certificacion
			SELECT LIMIT 1 clientecoppel_ss, ocupacion_ss, tiempoocupacion_ss, tiporesidencia_ss,  tiemporesidencia_ss,  
			idactividad_ss, idsubactividad_ss, descripactividad_ss, descripsubactividad_ss, canal_ss,   
			genero_ss, estadocivil_ss, escolaridad_ss, entidad_ss, edad_ss,
			estado_ss, sucursal_ss, fechanacimiento_ss, flagprestamos_ss, fechacliente_ss,
			estatussolicitud_ss, producto_ss, tiposolicitud_ss, estabilidadvivienda_ss
			INTO cNumCte, cOcupacion, iTiem_Ocupacion, cTipoResidencia,  iTiem_Residencia, 
			sId_actividad, sId_subactividad, cDescAct, vDescSubAct, iCanal_Sol,  
			cSexo, cEdo_Civil, cEscolaridad, cEntidad, sEdadCte,
			cEstado, cSucursal, dtFechaNac, iReprestamos, dtFechaCte,
			cStatusSolicitud, cNum_Producto, cTp_solicitud, iEstabilidadVivienda 		
			FROM bdisolic:"informix".ss_certif_evaluacion_cte_adn  
			WHERE solicitudbancoppel_ss = pNumSol
			AND clientebancoppel_ss = cNumCteBcoN; -- order by fecha_insert desc;
			
			--MACM SE AGREGAN CALCULOS AL REGRESAR DE LOS SPS
			
			IF NVL(cSexo,'') = '' THEN
				SELECT sexo INTO cSexo 
				FROM bdinteg:si_ctepf 
				WHERE numcte = cNumCteBcoN;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET genero_ss = cSexo WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN; 
				
			END IF;
			
			IF NVL(sId_actividad,'') = '' THEN
                SELECT a.claveopcionpuesto
                INTO sId_actividad
                FROM bdinteg:"informix".si_ingresos a
                WHERE a.numcte = cNumCteBco
                AND a.tipo_ingreso='T'
                AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
                                    FROM bdinteg:"informix".si_ingresos b
                                    WHERE b.numcte=a.numcte
                                    AND b.tipo_ingreso='T');
                
                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad = sId_actividad 
                WHERE num_solicitud = pNumSol;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET idactividad_ss = sId_actividad WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN; 
				
            END IF;

            IF NVL(sId_subactividad,'') = '' THEN
                SELECT a.clavesubopcionpuesto
                INTO sId_subactividad 
                FROM bdinteg:"informix".si_ingresos a
                WHERE a.numcte = cNumCteBco
                AND a.tipo_ingreso='T'
                AND a.sec_ingreso= (SELECT MAX (sec_ingreso) 
                                    FROM bdinteg:"informix".si_ingresos b
                                    WHERE b.numcte=a.numcte
                                    AND b.tipo_ingreso='T');

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET subactividad = sId_subactividad 
                WHERE num_solicitud = pNumSol;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET idsubactividad_ss = sId_subactividad WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN; 
				
            END IF;

            IF NVL(cDescAct,'') = '' THEN
                SELECT descrip
                INTO cDescAct
                FROM bdinteg:"informix".si_actsubact
                WHERE  id_subact = 0 
                AND id_act = sId_actividad;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad_descrip = cDescAct 
                WHERE num_solicitud = pNumSol;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET descripactividad_ss = cDescAct WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN;
				
            END IF;    

            EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cDescAct)
            INTO cDescAct;

            IF NVL(vDescSubAct,'') = '' THEN
                SELECT descrip
                INTO vDescSubAct
                FROM bdinteg:"informix".si_actsubact
                WHERE  id_subact = sId_subactividad AND id_act = sId_actividad;

                UPDATE bdisolic:"informix".ss_revision_determinacion 
                SET actividad_descrip = vDescSubAct 
                WHERE num_solicitud = pNumSol;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET descripsubactividad_ss = vDescSubAct WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN;
				
            END IF;

            EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(vDescSubAct)
            INTO vDescSubAct;
	
			
			--Se agrega las solicitudes con status CN y causa CCB, CGC para no avanzar de status.
            IF cStatusSolicitud = "CN" THEN
				IF NVL(cCausa_Sol,'') = '' THEN			
					SELECT NVL(causa_solicitud,"")
					INTO cCausa_Sol  
					FROM bdisolic:"informix".ss_autorizacion 
					WHERE empresa = pEmpresa
					AND num_solicitud = pNumSol
					AND status_solicitud = cStatusSolicitud; 
					
					UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
					SET causasolicitud_ss = cCausa_Sol WHERE solicitudbancoppel_ss = pNumSol
					AND clientebancoppel_ss = cNumCteBcoN;
					
					-- Solicitudes en CCB, CGC no deben de avanzar de status
				END IF;
            END IF;
			
			IF NVL(cSituacionEspecial,'') = '' THEN
            	SELECT situacion_credito
				INTO cSituacionEspecial	  
				FROM bdisolic:"informix".ss_resum_scor_fin
				WHERE empresa =  pEmpresa
				AND num_solicitud = pNumSol;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET situacionespecialcoppel_ss = cSituacionEspecial WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN;
				
			END IF;

			IF NVL(sEdadCte, 0 ) = 0 THEN
				EXECUTE PROCEDURE bdinteg:"informix".consedadcte(pEmpresa, cNumCteBco) 
				INTO cCodRet, cNombreCte, sEdadCte;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
				SET edad_ss = sEdadCte WHERE solicitudbancoppel_ss = pNumSol
				AND clientebancoppel_ss = cNumCteBcoN;
				
			END IF;	
				
			IF NVL(cEdo_Civil,'') = '' THEN		
				SELECT NVL(descripcion,'') --Estado Civil
					INTO cEdo_Civil
					FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
					WHERE d.grupo = 3
					AND e.grupo = d.grupo 
					AND e.elemento = d.elemento
					AND e.seccion = d.seccion 
					AND d.num_solicitud = pNumSol;	
					
					EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEdo_Civil)
					INTO cEdo_Civil;
					
					UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
					SET estadocivil_ss = cEdo_Civil WHERE solicitudbancoppel_ss = pNumSol
					AND clientebancoppel_ss = cNumCteBcoN;
					
			END IF;	
			
			IF NVL(cEscolaridad,'') = '' THEN	
				SELECT descripcion --Escolaridad
					INTO cEscolaridad
					FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
					WHERE d.grupo = 21
					AND e.grupo = d.grupo 
					AND e.elemento = d.elemento
					AND e.seccion = d.seccion 
					AND d.num_solicitud = pNumSol;	
		
					EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cEscolaridad)
					INTO cEscolaridad;
					
					UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
					SET escolaridad_ss = cEscolaridad WHERE solicitudbancoppel_ss = pNumSol
					AND clientebancoppel_ss = cNumCteBcoN;
			END IF;
			
			
			IF NVL(cTipoResidencia,'') = '' THEN
				SELECT descripcion --Tipo residencia
					INTO cTipoResidencia
					FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
					WHERE d.grupo = 5
					AND e.grupo = d.grupo 
					AND e.elemento = d.elemento
					AND e.seccion = d.seccion 
					AND d.num_solicitud = pNumSol;
					EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cTipoResidencia)
					INTO cTipoResidencia;
					
					UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
					SET tiporesidencia_ss = cTipoResidencia WHERE solicitudbancoppel_ss = pNumSol
					AND clientebancoppel_ss = cNumCteBcoN;
					
			END IF;		

			IF NVL(cOcupacion,'') = '' THEN
				SELECT NVL(descripcion,'') 
					INTO cOcupacion
					FROM bdisolic:"informix".ss_scoring_element e , bdisolic:"informix".ss_detalle_scoring d
					WHERE d.grupo = 7
					AND e.grupo = d.grupo 
					AND e.elemento = d.elemento
					AND e.seccion = d.seccion 
					AND d.num_solicitud = pNumSol;
				
				EXECUTE PROCEDURE bdinteg:"informix".sp_eliminaacentos(cOcupacion)
				INTO cOcupacion;
				
				UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
					SET ocupacion_ss = cOcupacion WHERE solicitudbancoppel_ss = pNumSol
					AND clientebancoppel_ss = cNumCteBcoN;
				
			END IF;	
			
			EXECUTE PROCEDURE bdinteg:sp_eliminaacentos(cEstado)
			into cEstado;
			
			--ELIMINAMOS COMAS
			LET cNumCte           			= REPLACE(cNumCte, ',', '');
			LET cStatusSolicitud  			= REPLACE(cStatusSolicitud, ',', '');
			LET cNum_Producto     			= REPLACE(cNum_Producto, ',', '');
			LET cTp_solicitud     			= REPLACE(cTp_solicitud, ',', '');
			LET cDescAct       	  			= REPLACE(cDescAct, ',', '');
			LET vDescSubAct       			= REPLACE(vDescSubAct, ',', '');
			LET dtFechaCte       			= REPLACE(dtFechaCte, ',', '');
			LET iCanal_Sol       			= REPLACE(iCanal_Sol, ',', '');
			LET cSucursal       			= REPLACE(cSucursal, ',', '');
			LET dtFechaNac       			= REPLACE(dtFechaNac, ',', '');
			LET cSexo       				= REPLACE(cSexo, ',', '');
			LET cEdo_Civil       			= REPLACE(cEdo_Civil, ',', '');
			LET cOcupacion       			= REPLACE(cOcupacion, ',', '');
			LET cEscolaridad       			= REPLACE(cEscolaridad, ',', '');
			LET cTipoResidencia       		= REPLACE(cTipoResidencia, ',', '');
			LET cEntidad       				= REPLACE(cEntidad, ',', '');
			LET cEstado       				= REPLACE(cEstado, ',', '');
			LET cCausa_Sol       			= REPLACE(cCausa_Sol, ',', '');
			LET cSituacionEspecial          = REPLACE(cSituacionEspecial, ',', '');
			
			
			UPDATE bdisolic:"informix".ss_certif_evaluacion_cte_adn
			SET idactividad_ss = sId_actividad, idsubactividad_ss = sId_subactividad, descripactividad_ss = cDescAct, 
			descripsubactividad_ss = vDescSubAct, situacionespecialcoppel_ss = cSituacionEspecial,  estadocivil_ss = cEdo_Civil, 
			escolaridad_ss = cEscolaridad, tiporesidencia_ss = cTipoResidencia, ocupacion_ss = cOcupacion
			WHERE solicitudbancoppel_ss = pNumSol
			AND clientebancoppel_ss = cNumCteBcoN;
			
			--MACM SE CAMBIAN LOS FORMATOS DE fecha
			
			IF dtFechaCte IS NULL OR dtFechaCte = '' OR dtFechaCte = '01-01-1900' THEN
				LET dtFechaCte = NVL(dtFechaCte,'01-01-1900'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaCte::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaCte::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaCte::DATE), 4, '0');
				LET dtFechaCte = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;

			IF dtFechaNac IS NULL OR dtFechaNac = '' OR dtFechaNac = '01-01-1900' THEN
				LET dtFechaNac = NVL(dtFechaNac,'01-01-1900'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaNac::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaNac::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaNac::DATE), 4, '0');
				LET dtFechaNac = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;

			IF dtFechaSolicitud IS NULL OR dtFechaSolicitud = '' OR dtFechaSolicitud = '01-01-1900'  THEN
				LET dtFechaSolicitud = NVL(dtFechaSolicitud,'01-01-1900'); 			
			ELSE			
				LET dtDiaFF = LPAD(DAY(dtFechaSolicitud::DATE), 2, '0');
				LET dtMesFF = LPAD(MONTH(dtFechaSolicitud::DATE), 2, '0');
				LET dtAnoFF = LPAD(YEAR(dtFechaSolicitud::DATE), 4, '0');
				LET dtFechaSolicitud = dtAnoFF || '-' || dtMesFF || '-' || dtDiaFF;
			END IF;
			
    END IF;

    RETURN  NVL(cCodRet,00000), NVL(cSolBanco,''), NVL(cNumCteBco,''),	NVL(cNumCte,''), NVL(pEmpresa,''), 
			NVL(cStatusSolicitud,''), NVL(cCausa_Sol,""), NVL(cNum_Producto,''), NVL(cTipoGrupo,''), NVL(cTp_solicitud,'?'),
			NVL(cB_INE,0), NVL(cHabita_en,'??'), NVL(cProfesion,''), NVL(sId_actividad,0), NVL(cDescAct,''), 
			NVL(sId_subactividad,0), NVL(vDescSubAct,''), NVL(cSituacionEspecial,"?"), NVL(sCausaSituacion,-99), NVL(cMotivoRechBcpl,''), 
			NVL(sHist_meses,0), NVL(dEficienciaCoppel,0), NVL(iReprestamos,0), NVL(cDescripcion,''), NVL(cRiesgoViviendaCpl,""), 
			NVL(cRiesgoViviendaBcpl,""), NVL(cActRiesgoCpl,''), NVL(cActRiesgoBCpl,''),	NVL(cDescpRiesgo,''), NVL(dSituacionPagoCoppel,"0"), 
			NVL(mIngreso_Mensual,0), NVL(sCteLargo8,0), NVL(iMeses_hist_Val,0), NVL(sFlagHuella,"0"),  NVL(cCod_Ult_Identif,0), 
			NVL(sValida_Cel,"0"),  NVL(dtFechaCte,'01-01-1900'), NVL(iCanal_Sol,"0"), NVL(cCompIngresos,''), NVL(sCompValido, 0), 
			NVL(cSucursal,''), NVL(dIngresoAjsutado,0), NVL(dtFechaNac,'01-01-1900'), NVL(cSexo,''), NVL(cEdo_Civil,''), 
			NVL(iTiem_Edo_Civil,-99), NVL(cOcupacion,''), NVL(iTiem_Ocupacion, -99), NVL(cEscolaridad,''), NVL(cTipoResidencia,''), 
			NVL(iTiem_Residencia, -99), NVL(vClvEdoCob,''), NVL(vLocalidad,''), NVL(cEntidad,''), NVL(cCURP,''), 
			NVL(iFlagEmpleado,0), NVL(iExisteCliente,0), NVL(sEdadCte,0), NVL(vgrupoA,''), NVL(dtFechaSolicitud, '01-01-1900'), 
		    NVL(pMeses_historia_grupo,0), NVL(pSituacion_pago_grupo,0), NVL(cMunicipio,''), NVL(cEstado,''), NVL(iMoraCoppel,0), 
			NVL(dSaldoVencido,0), NVL(iMoraBanCoppel,0), NVL(dSaldoVenBanCoppel,0), NVL(vTipoTransaccion,""), NVL(iAntiguedad,0), 
			NVL(iFraudes,0), NVL(iFlagCreditoPPActivo,0), NVL(iEstabilidadVivienda,0), NVL(iListaNegra,0), NVL(cNoTramiteDia_TDC,0), 
			NVL(cNoTramiteDia_PP,0), NVL(cTipoColectivo,''), NVL(dNum_consultasfinanciera,0), NVL(sReestructura,0), NVL(sIdentFalsa,0), 
			NVL(sQuebranto,0), NVL(vTipoEmpCode,''), NVL(vTipoEmpName,''), NVL(dPromedioIngresoMUlt4d,0), NVL(cContinuidadDepositosNomina,'0'),
			NVL(origeninput1,''), NVL(origeninput2,''), NVL(origeninput3,''), NVL(origeninput4,''), NVL(origeninput5,0), 
			NVL(origeninput6,0), NVL(origeninput7,0), NVL(origeninput8,0);

END PROCEDURE

DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Se crea procedimiento "sp_consultadatos_motor_adn" para la consulta de variables BRM ',
'Modifico    : Alan Castro Paredes',
'Fecha       : 03/03/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".generaedosctacrd(pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE)
--EXECUTE PROCEDURE generaedosctacrd('001','610000482519',mdy('05','02','2020')); 
RETURNING CHAR(5);

--     VARIABLES CONTROL DE ERRORES     --
DEFINE cod_ret             		CHAR(5);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			CHAR(5);
--	VARIABLES GENERALES
DEFINE v_num_aper_ant           CHAR(20);       --NumeroAperturaAntesdeReestructura
DEFINE v_plazo                  INTEGER;        --plazo
DEFINE v_numerociudad 	        SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 	        INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerociudadCoppel     SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniaCoppel    INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerocalle 	        INT;		    --Numero Calle Direccion Cliente
DEFINE v_numeroextcalle         CHAR(10);       --Numero Exterior Calle Direccion Cliente
DEFINE v_estado 		        CHAR(2);	    --Numero Estado
DEFINE v_nombrecalle	        CHAR(30);       --Nombre Calle Catalogo Calles
DEFINE v_centro			        INT;		    --Centro Catalogo de Zonas
DEFINE v_jefegrupozona	        INT;		    --Clave Jefe Grupo Zona
DEFINE v_supervisorzona	        INT;		    --Clave Supervisor Zona
DEFINE v_capital_debe 	        DECIMAL(14,2);  --Capital_Debe
DEFINE v_interes_debe 	        DECIMAL(14,2);  --Interes_Debe
DEFINE v_iva_debe 		        DECIMAL(14,2);  --Iva_Debe
DEFINE v_num_pago               INTEGER;        --Numero_pago_tc
DEFINE v_num_pago_am            INTEGER;        --Numero de pago del amortiza 
DEFINE v_usted_debe_tc          DECIMAL(18,2);  --Usted_Debe_General
DEFINE v_maximo        		    INTEGER;        --Secuencia
DEFINE v_periodo_anterior  	    DATE;			--Fecha Periodo Anterior
--     VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
DEFINE v_numcte                 CHAR(20);	   --Numero de Credito
DEFINE v_cod_producto           CHAR(4);       --Numero de Producto
DEFINE v_nombre_cte             CHAR(150);	   --Nombre del Cliente
DEFINE v_direccion_cn           CHAR(456);	   --Direccion
DEFINE v_direccion_col          CHAR(376);	   --Colonia
DEFINE v_direccion_del          CHAR(376);	   --Delegacion O Municipio
DEFINE v_edo_cd                 CHAR(376);	   --Estado
DEFINE v_cl_cobra               CHAR(60);	   --Clave de Cobranza
DEFINE v_sucursal               CHAR(4);  	   --Sucursal Cliente
DEFINE v_sucursal_nombre        CHAR(40);	   --Nombre de la Sucursal
DEFINE v_sucursal_gerente       CHAR(40);	   --Nombre del Gerente del Sucursal
DEFINE v_rfc                    CHAR(13);	   --RFC del Cliente
DEFINE v_sucursal_tel           CHAR(14);	   --Telefono de la Sucursal
DEFINE v_cod_postal             CHAR(5);	   --Codigo Postal Direccion Cliente
DEFINE v_ruta          	        CHAR(47);	   --Ruta
DEFINE v_entre_calles           CHAR(40);	   --Entre Calles
DEFINE v_observaciones          CHAR(80);	   --Datos Complementarios
DEFINE cInserto                 CHAR(15);      --Informacion del Inserto
DEFINE v_confirmacion			CHAR(5);	   --Confirmacion de Envio CFDI --

--     VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
DEFINE v_num_pago_c             CHAR(9);        --Numero_pago_tc con la union del plazo xx/xx
DEFINE v_cap_mto_cuota          DECIMAL(14,2);  --Monto_Pago
DEFINE v_capital_vencido        DECIMAL(14,2);  --Capital_Ven_tc
DEFINE v_interes_vencido        DECIMAL(14,2);  --Interes_Ven_tc
DEFINE v_iva_vencido            DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE v_moratorio              DECIMAL(14,2);  --Moratorios
DEFINE v_iva_moratorio          DECIMAL(14,2);  --iva_Moratorios
DEFINE v_pagototal              DECIMAL(14,2);  --Pago_Total_tc
DEFINE v_fecha_limite_pago_tc   DATE;			--Fecha_Limite_tc
DEFINE v_periodo_tc_ini   		DATE;			--Periodo_tc_Ini
DEFINE v_periodo_tc_fin   		DATE;			--Periodo_tc_Fin
DEFINE v_fecha_corte_tc   		DATE;			--Fecha_Corte
DEFINE v_dias_periodo_tc 		INTEGER;		--Dias_Periodo_tc
DEFINE v_monto_otorgado         DECIMAL(14,2);  --Monto_Credito_tc
DEFINE v_fecha_apertura		    DATE;			--Fecha_Otorgamiento_tc
DEFINE v_int_efect_paga         DECIMAL(14,2);   --Intereses efectivamente pagados
DEFINE v_descuento				DECIMAL(14,2);  --Descuento NO IVA - CDFI 3.3
DEFINE v_subtotal				DECIMAL(14,2);  --Subtotal intereses - CDFI 3.3
DEFINE v_total					DECIMAL(14,2);  --Total intereses e iva - CDFI 3.3

--     VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA     --
DEFINE v_fecha_mov_aux          CHAR(11);           --Fecha Movimiento de Operacion
DEFINE v_usted_debia   			DECIMAL(18,2);	--Usted_debia
DEFINE v_monto_det              DECIMAL(18,2);  --Mas_Disposiciones
DEFINE v_referencia_aux         CHAR(296);      --Referencia (Numero de Pago)
DEFINE v_concepto               CHAR(296);      --CONCEPTO DEL MOVIMIENTO
DEFINE v_naturaleza             CHAR(1);
DEFINE v_descripcion_det        CHAR(296);
DEFINE v_cod_ref                INTEGER;
DEFINE v_cod_fun                CHAR(3);
--     VARIABLES GENERACION MENSAJES EDO CUENTA REESTRUCTURA     --
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA REESTRUCTURA     --
--	VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
DEFINE v_tasa_anual			    DECIMAL(18,2);
DEFINE v_tasa_mensual		    DECIMAL(18,2);
DEFINE v_tasa_mora			    DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	    DECIMAL(18,2);
DEFINE v_cat			  	    DECIMAL(5,2);
--     VARIABLES CLAVE DE COBRANZA REESTRUCTURA     --
DEFINE v_situacion              CHAR(1);
DEFINE v_situacion_esp          CHAR(3);
DEFINE v_estado_civil           CHAR(1);
DEFINE v_tp_casa                CHAR(1);
DEFINE v_sexo                   CHAR(1);
DEFINE v_nacimiento             CHAR(2);
DEFINE v_salario                DECIMAL(18,2);
DEFINE v_cantidad               CHAR(2);
DEFINE v_antiguedad             CHAR(2);
DEFINE v_mto_tot_adeudo         CHAR(5);
DEFINE v_sdo_no_exig            DECIMAL(18,2);
DEFINE v_monto_financiado	    DECIMAL(18,2);
DEFINE v_mto_finan_vdo          DECIMAL(18,2);
DEFINE v_fecha_ultimo_pago	    DATE;
DEFINE v_fec_ult_pago           CHAR(4);
DEFINE v_fec_ult_pago_month     CHAR(2);
DEFINE v_fec_ult_pago_year      CHAR(2);
DEFINE v_monto_ult_convenio     CHAR(5);
DEFINE v_fecha_ult_convenio     CHAR(4);
DEFINE v_est_cumpl_convenio     CHAR(1);
DEFINE v_cuantos_avisos		    INTEGER;
DEFINE v_avisos 	    	    CHAR(1);
DEFINE v_nivel_eficiencia       CHAR(1);
DEFINE posicion11               CHAR(5);
DEFINE v_pago_minimo_tc   		DECIMAL(18,2);	--sdo_pagar
DEFINE posicion17               CHAR(5);
DEFINE v_clave1		          	VARCHAR(40);
DEFINE v_clave2		    	    VARCHAR(40);
DEFINE v_clave3		    	    VARCHAR(40);
DEFINE v_clave4		    	    VARCHAR(40);
DEFINE v_clave5         	    VARCHAR(40);
DEFINE v_cl_cobranza            CHAR(64);
DEFINE v_SalarioMinimoCoppel    SMALLINT;
DEFINE v_cuenta_efe            	CHAR(20);
DEFINE v_contador      		   	smallint;
DEFINE v_corta_linea_detalle   	INTEGER;
DEFINE v_corta_retorno 	       	INTEGER;
DEFINE v_cargos                	DECIMAL(18,2);
DEFINE v_abonos                	DECIMAL(18,2);
DEFINE v_serial                	char(16);
DEFINE  vlStatusCred            CHAR(2);
DEFINE  vFechaCancela           DATE;
DEFINE v_transacc      			char(4);
DEFINE v_folio      			VARCHAR(20);
DEFINE v_fecha_limite_pago_rees DATE;

------------------------------------------------------------------
-- Se agregan variables de catalogo de Centros de Impresion--
DEFINE sNumRegion CHAR(2); --Numero de region (centro de impresion)
DEFINE sNumCiudadB CHAR(4); --Numero de ciudad BanCoppel
DEFINE sNumCiudadC CHAR(3); --Numero de ciudad COPPEL

DEFINE vObjetoImp	CHAR(02); -- Objeto Impuesto para CFDI 4.0
DEFINE vBaseComi	DECIMAL(12,2); -- Comision Base por disposicion de efectivo

DEFINE vTipProdCarterasRT	CHAR(2); -- Tipo de producto Carteras
DEFINE vNameProd	CHAR(50); -- 	Nombre del producto

--- RQI 21 401
DEFINE v_nombre1	CHAR(26);
DEFINE v_nombre2	CHAR(26);
DEFINE v_apell_paterno	CHAR(26);
DEFINE v_apell_materno	CHAR(26);
DEFINE v_rfc_alterno	CHAR(13);
DEFINE v_rfc1			CHAR(13);
DEFINE v_fecha_alta		DATE;

--     VARIABLES CONTROL DE ERRORES     --
LET cod_ret                  = "000";
LET sql_err                  = 0;
LET v_cod_ret_otro           = "000";
--     VARIABLES GENERALES     --
LET v_num_aper_ant            = "";
LET v_plazo                   = 0;
LET v_numerociudad 		      = 0;
LET v_numerocolonia 	      = 0;
LET v_numerocalle 		      = 0;
LET v_numeroextcalle 	      = "";
LET v_estado 			      = "";
LET v_nombrecalle		      = "";
LET v_centro			      = 0;
LET v_jefegrupozona		      = 0;
LET v_supervisorzona	      = 0;
LET v_capital_debe 			  = 0;
LET v_interes_debe 			  = 0;
LET v_iva_debe 				  = 0;
LET v_num_pago                = 0;
LET v_usted_debe_tc           = 0;
LET v_maximo                  = 0;
LET v_periodo_anterior   	  = DATE(1);
--     VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
LET v_numcte        	      = "";
LET v_cod_producto            = "";
LET v_nombre_cte    	      = "";
LET v_direccion_cn  	      = "";
LET v_direccion_col	          = "";
LET v_direccion_del 	      = "";
LET v_edo_cd     		      = "";
LET v_cl_cobra      	      = "";
LET v_sucursal                = "";
LET v_sucursal_nombre         = "";
LET v_sucursal_gerente        = "";
LET v_rfc           	      = "";
LET v_sucursal_tel            = "";
LET v_cod_postal    	      = "";
LET v_ruta           	      = "";
LET v_entre_calles   	      = "";
LET v_observaciones  	      = "";
LET cInserto                  = "";
LET v_confirmacion			  = ""; 

--     VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
LET v_num_pago_c              = "";
LET v_cap_mto_cuota           = 0;
LET v_capital_vencido         = 0;
LET v_interes_vencido         = 0;
LET v_iva_vencido             = 0;
LET v_moratorio               = 0;
LET v_iva_moratorio           = 0;
LET v_pagototal               = 0;
LET v_fecha_limite_pago_tc    = " ";
LET v_periodo_tc_ini   		  = " ";
LET v_periodo_tc_fin   		  = " ";
LET v_fecha_corte_tc   		  = " ";
LET v_dias_periodo_tc 		  = 0;
LET v_monto_otorgado          = 0;
LET v_fecha_apertura	      = " ";
LET v_descuento				  = 0;
LET v_subtotal				  = 0;
LET v_total					  = 0;

--     VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA     --
LET v_fecha_mov_aux          = DATE(1);
LET v_usted_debia   		 = 0;
LET v_monto_det              = 0;
LET v_referencia_aux         = "";
LET v_concepto               = 0;
LET v_naturaleza             = "";
LET v_descripcion_det        = "";
LET v_cod_ref                = "";
LET v_cod_fun                = 0;
LET v_int_efect_paga         = 0;
--     VARIABLES GENERACION ACLARACIONES EDO CUENTA REESTRUCTURA     --
--     VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
LET v_tasa_anual		     = 0 ;
LET v_tasa_mensual 		     = 0 ;
LET v_tasa_mora			     = 0 ;
LET v_tasa_mensual_mora	     = 0 ;
--      VARIABLES CLAVE DE COBRANZA REESTRUCTURA      --
LET v_situacion              = "";
LET v_situacion_esp          = "";
LET v_estado_civil           = "";
LET v_tp_casa                = "";
LET v_sexo                   = "";
LET v_nacimiento             = "";
LET v_salario                = 0;
LET v_cantidad               = "";
LET v_antiguedad             = "";
LET v_mto_tot_adeudo         = "";
LET v_sdo_no_exig            = 0;
LET v_monto_financiado	     = 0;
LET v_mto_finan_vdo          = 0;
LET v_fecha_ultimo_pago      = " ";
LET v_fec_ult_pago           = "";
LET v_fec_ult_pago_month     = "";
LET v_fec_ult_pago_year      = "";
LET v_monto_ult_convenio     = "";
LET v_fecha_ult_convenio     = "";
LET v_est_cumpl_convenio     = "";
LET v_cuantos_avisos	     = 0;
LET v_avisos 	    	     = "0";
LET v_nivel_eficiencia	     = 0;
LET posicion11               = "";
LET v_pago_minimo_tc   	     = 0;
LET posicion17               = "";
LET v_clave1		 	     = "";
LET v_clave2		 	     = "";
LET v_clave3			     = "";
LET v_clave4		 	     = "";
LET v_clave5         	     = "";
LET v_cl_cobranza            = "";
LET v_num_pago_am            = 0;
LET cInserto  = "";
LET v_SalarioMinimoCoppel    = 0;
LET v_cuenta_efe             = "";
LET v_contador      	     = 0;
LET v_corta_linea_detalle 	 = 30;
LET v_corta_retorno 	     = 0;
LET v_cargos                 = 0;
LET v_abonos                 = 0;
LET v_serial                 = "";
LET v_cat			  	     = 0;
LET v_numerociudadCoppel     = 0;
LET v_numerocoloniaCoppel    = 0;
LET vlStatusCred             = '';
LET vFechaCancela            = DATE(0);
LET v_transacc     = "";
LET v_folio     = "";
LET v_fecha_limite_pago_rees = " ";

-------------------------------------------------------------------
-- Se limpian variables para los campos para centro de impresion --
LET sNumRegion  = '0';
LET sNumCiudadB = '0';
LET sNumCiudadC = '0';

---- Limpieza de variables cfdi 4.0
LET vObjetoImp	= '01';
LET vBaseComi	= 0;

-- Tipo de producto Carteras
LET vTipProdCarterasRT	= '';
LET vNameProd	= '';

--- OBTIENE RFC LIMPIO PARA MOSTRAR
LET v_nombre1 = '';
LET v_nombre2 = '';
LET v_apell_paterno	= '';
LET v_apell_materno	= '';
LET v_rfc_alterno	= '';
LET v_rfc1			= '';
LET v_fecha_alta	= DATE(1);

-- Fecha: 11/08/2009
-- Autor: Paul Ivan Quintero Varela
-- Observaciones: Se modifica con la finalidad de agregar las adecuaciones para el desgloce de movimientos
--                            en el detalle correspondiente, se contemplan los cambios para la clave de cobranza,
--                             se modifica la obtencion del ultimo movimiento, el usted debe, usted debia, y
--                             finalmente las secuencias y nlineas de cada insercion en la tabla del detalle.

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
     END IF
  END EXCEPTION WITH RESUME ;

	-- SET DEBUG FILE TO "/pisa/leo/generaedosctacrd.out";
	-- TRACE ON;

	--##	SALARIO MINIMO COPPEL           			      ##

       SELECT NVL(valor,0)
         INTO v_SalarioMinimoCoppel
         FROM bdisolic:ss_param
        WHERE empresa = pempresa
          AND secuencia = 303;

    --SD_MAECREDCRD

	SELECT a.numcte, a.num_producto, a.sucursal, a.fecha_apertura,
		   a.tasa_interes,	NVL(a.tasa_moratorios,0),
		   DECODE(status_cred,'AR','0','BR','1','TR','2','0'),
		   credito_externo, plazo, status_cred
      INTO v_numcte, v_cod_producto, v_sucursal, v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           v_avisos , v_num_aper_ant,  v_plazo, vlStatusCred
	  FROM "informix".sd_maecredcrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;
	   
	--- Obtiene nombre del producto
	SELECT trim(nombre_prod) INTO vNameProd
	FROM bdicred:sd_definicion
	WHERE num_producto = v_cod_producto;

    --SD_MAECREDANEXOCRD
	SELECT fecha_proceso
      INTO vFechaCancela
	  FROM "informix".sd_maecredanexocrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;
	   
    --     CAT SIN IVA DEL CREDITO      --
	
	SELECT cat 
	  INTO v_cat 
	  FROM bdicred:sd_tasa_cat
     WHERE empresa =  pempresa 
	   AND producto = v_cod_producto
	   AND tasa = v_tasa_anual;

    --     Solicitud de Resta de Tasa Moratoria - la Tasa Ordinaria     --

	LET  v_tasa_mora = 0;

	--     SI_CLIENTE     --

	SELECT a.nombre1,		a.nombre2,	a.apell_paterno,	a.apell_materno,
		   a.rfc_alterno,	a.rfc,		a.fecha_alta
	  INTO v_nombre1,		v_nombre2,	v_apell_paterno,	v_apell_materno,
		   v_rfc_alterno,	v_rfc1,		v_fecha_alta
	  FROM bdinteg:"informix".si_cliente a
	 WHERE a.numcte = v_numcte;
	 
	IF v_rfc1 = '' OR v_rfc1 IS NULL THEN
		LET v_rfc = TRIM(v_rfc_alterno);
	ELSE
		LET v_rfc = TRIM(v_rfc1);
	END IF;
	
	LET v_antiguedad = NVL(SUBSTR(YEAR(v_fecha_alta), 3, 2),'');
	
	LET v_nombre_cte = TRIM(v_nombre1) || " " ||TRIM(v_nombre2) || " " || TRIM(v_apell_paterno) || " " ||TRIM(v_apell_materno);
	

    --     SI_DIRECCIONES      --
	 
	 --SELECT TRIM(b.numeroextcalle) || " " || TRIM(b.numerointcalle) || " " || decode(NVL(TRIM(b.departamento),'0'),'0','',TRIM(b.departamento)),
	 SELECT 
	 decode(TRIM(NVL(b.numeroextcalle,'0')),'0','',TRIM(b.numeroextcalle)) || " " || 
	 decode(TRIM(NVL(b.numerointcalle,'0')),'0','',TRIM(b.numerointcalle)) || " " || decode(TRIM(NVL(b.departamento,'0')),'0','',TRIM(b.departamento)),
	       b.cod_postal,			b.entre_calles,
	       b.observaciones,		   	b.numerociudad,
	       b.numerocolonia,			b.numerocalle,
	       b.numeroextcalle,	    b.estado
	  INTO v_direccion_cn,
		   v_cod_postal,			v_entre_calles,
		   v_observaciones,		    v_numerociudad,
		   v_numerocolonia,			v_numerocalle,
		   v_numeroextcalle,		v_estado
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte  = v_numcte AND tipo_dir="1";

	--     SI_CATCALLES     --
	
	SELECT TRIM(c.nombrecalle)
	  INTO v_nombrecalle
	  FROM bdinteg:"informix".si_catcalles c
	 WHERE c.numerocalle = v_numerocalle;

	--     SI_CATZONAS     --

	 SELECT d.nombrezona,			d.centro,
		   d.jefegrupozona,			d.supervisorzona,
           d.numerociudadcoppel,    d.numerocoloniacoppel
	  INTO v_direccion_col,			v_centro,
		   v_jefegrupozona,			v_supervisorzona,
           v_numerociudadCoppel,    v_numerocoloniaCoppel
	  FROM bdinteg:"informix".si_catzonas d
	 WHERE d.numerociudad = v_numerociudad
	   AND d.numerocolonia=v_numerocolonia;

       if nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
         let v_numerociudad = v_numerociudadCoppel;
         let v_numerocolonia = v_numerocoloniaCoppel;
       end if;
	--      SI_CATCIUDADES     --

 	   SELECT e.nombreciudad
	  INTO v_direccion_del
	  FROM bdinteg:"informix".si_catciudades e
	 WHERE e.numerociudad = v_numerociudad;

	--      SI_ESTADOS      --

	SELECT f.nombre
	  INTO v_edo_cd
	  FROM bdinteg:"informix".si_estados f
	 WHERE f.estado = v_estado;
	 
	 -----------------------------------------
	--------SD_CENTROSIMPRESION_COPPEL-------
	SELECT LPAD(num_region,2,0),LPAD(num_ciudad_banco,4,0),LPAD(num_ciudad_coppel,3,0)
	INTO sNumRegion,sNumCiudadB,sNumCiudadC
	FROM "informix".sd_centrosimpresion_coppel
	WHERE num_ciudad_banco = v_numerociudad;
	--AND num_ciudad_coppel = v_numerociudadCoppel;

	--Valida el numero de region (Centro de impresion) esta en nulo o vacio.
	IF nvl(sNumRegion,'') = '' OR sNumRegion IS NULL THEN
		LET sNumRegion 	= '00';
		LET sNumCiudadB = LPAD(v_numerociudad,4,0);
		LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
	end if;
	-- Valida si la ciudad banco o ciudad coppel son diferentes a las del catalogo centros impresion.
	IF sNumCiudadC != v_numerociudadCoppel THEN 
		LET sNumRegion 	= '00';
		LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
	ELIF sNumCiudadB != v_numerociudad THEN
		LET sNumRegion 	= '00';
		LET sNumCiudadB = LPAD(v_numerociudad,4,0);
	END IF;
	--Valida la ciudad banco y ciudad coppel si esta en nulo o vacio.
	IF nvl(sNumCiudadC,'') = '' OR sNumCiudadC IS NULL THEN
		LET sNumCiudadC = '000';
	END IF;
	IF nvl(sNumCiudadB,'') = '' OR sNumCiudadB IS NULL THEN
		LET sNumCiudadB = '0000';
	END IF;

	 --      SI_SUCURSALES      --

	SELECT d.nombre, d.gerente
	  INTO v_sucursal_nombre,		v_sucursal_gerente
	  FROM bdinteg:"informix".si_sucursales d
	 WHERE d.empresa  = pempresa
	   AND d.sucursal = v_sucursal;

select tel1 
  into v_sucursal_tel
  from bdinteg:si_ptf 
 where id_ptf = v_sucursal
 and tipo = 'S';
	   
	   
	LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
	LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
			     LPAD(v_centro,6,'0')||"/"||
			     LPAD(v_jefegrupozona,8,'0')||"/"||
			     LPAD(v_supervisorzona,8,'0')||"/"||
			     LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
			     LPAD(v_numerocalle,6,'0')||"/"||
			     LPAD(TRIM(v_numeroextcalle),5,'0');

    --     Se obtiene el inserto correspondiente      --

	SELECT insertos
       INTO cInserto
       FROM "informix".sd_marcaje
      WHERE empresa = pempresa
        AND num_credito= pnum_credito
        AND fecha_emision = pfechahoy;

       IF cInserto IS NULL THEN
          LET cInserto='000000000000000';
       END IF;

    --     SE OBTIENE EL NUMERO DE CUENTA EFECTIVA     --

--	  SELECT cuenta 
--	    INTO v_cuenta_efe 
--	    FROM bdicheq:sc_maechq
--	   WHERE empresa = pempresa
--		AND num_cte = v_numcte;	

		SELECT NVL(num_cta,"") 
		INTO v_cuenta_efe 
		FROM bdicred:sd_ctascarg
	   WHERE empresa = pempresa
		 AND num_credito = pnum_credito;	
		
	
     INSERT INTO "informix".sd_encabezado_edoctacrd
     				(
                    fecha_emision,		num_credito,
                    num_cta_efec,		num_producto,
                          numcte,		nombre_cte,
                    direccion_cn,		direccion_col,
                   direccion_del,       edo_cd,
                        cl_cobra,		sucursal_numero,
                 sucursal_nombre,		sucursal_gerente,
                             rfc,		sucursal_tel,
                              cp,		ruta,
                    entre_calles,		observaciones,
                        insertos, 		confirmacion,
				 nombre_producto,
					  num_region,		num_ciudad_banco,
				num_ciudad_coppel,		obj_imp,
						base_cfdi
				    )
	  		 VALUES(
	  		       	pfechahoy,				            TRIM(pnum_credito),
                    NVL(TRIM(v_cuenta_efe),''),         NVL(TRIM(v_cod_producto),''),
                    NVL(TRIM(v_numcte),''),  			NVL(TRIM(v_nombre_cte),''),
                    NVL(TRIM(v_direccion_cn),''),       NVL(TRIM(v_direccion_col),''),
                    NVL(TRIM(v_direccion_del),''),      NVL(TRIM(v_edo_cd),''),
                    NVL(TRIM(v_cl_cobra),''),           NVL(TRIM(v_sucursal),''),
                    NVL(TRIM(v_sucursal_nombre),''),    NVL(TRIM(v_sucursal_gerente),''),
                    NVL(TRIM(v_rfc),''),                NVL(TRIM(v_sucursal_tel),''),
                    NVL(TRIM(v_cod_postal),''),         NVL(TRIM(v_ruta),''),
                    NVL(TRIM(v_entre_calles),''),       NVL(TRIM(v_observaciones),''),
                    cInserto,							NVL(TRIM(v_confirmacion),''),
					NVL(TRIM(vNameProd),''),
					NVL(sNumRegion,''),					NVL(sNumCiudadB,''),
					NVL(sNumCiudadC,''),				NVL(vObjetoImp,''),
					NVL(vBaseComi,0)
				    );
					
					IF NVL(TRIM(v_ruta),'') = '' OR v_ruta is null THEN
						UPDATE "informix".sd_encabezado_edoctacrd SET num_region = '00' WHERE num_credito = pnum_credito AND ruta = '';
					END IF;

	--##	GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA        ##

	--     SE DEFINE EL MONTO DEL PROXIMO PAGO     --

        SELECT capital_debe,
               num_pago,
               capital_mto_cuota
          INTO v_capital_debe,
               v_num_pago,
               v_cap_mto_cuota
          FROM "informix".sd_amortiza_creditocrd
         WHERE empresa     = pempresa
           AND num_credito = pnum_credito
           AND fecha_cuota = pfechahoy + 1 units month;

           
           IF lpad(month(pfechahoy),2,0) = '01' and day(pfechahoy) < 17 then 
                SELECT sdo_cap_insoluto,monto_financiado,sdo_no_exig,mto_finan_vdo
                  INTO v_capital_debe,v_monto_financiado,v_sdo_no_exig,v_mto_finan_vdo
                  FROM bdicred:sd_maesdoshistcrd 
                 WHERE fecha = pfechahoy - 2 units day
                   AND empresa = pempresa
                   AND num_credito = pnum_credito;
           ELSE
                SELECT sdo_cap_insoluto,monto_financiado,sdo_no_exig,mto_finan_vdo
                  INTO v_capital_debe,v_monto_financiado,v_sdo_no_exig,v_mto_finan_vdo
                  FROM bdicred:sd_maesdoshistcrd 
                 WHERE fecha = pfechahoy  - 1 units day
                   AND empresa = pempresa
                   AND num_credito = pnum_credito;
          END IF;
         
          --      PROXIMO PERIODO     --

            EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,1,DAY(pfechahoy))
                         INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

            IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
              LET cod_ret = v_cod_ret_otro;
            END IF;

            LET v_interes_debe = round((v_capital_debe - (v_monto_financiado)) * v_tasa_anual / (360 * 100),2) * v_dias_periodo_tc ;
            LET v_iva_debe = round((v_interes_debe * 0.16),2);
            LET v_capital_debe = round((v_cap_mto_cuota - v_interes_debe - v_iva_debe),2);

            LET v_cap_mto_cuota = 0;
            LET v_cap_mto_cuota = round((v_capital_debe + v_interes_debe + v_iva_debe),2);
            LET v_periodo_anterior = DATE(1);
            LET v_dias_periodo_tc = 0;

           IF NVL(v_referencia_aux,'') = '' THEN
               LET v_referencia_aux = '-';
           ELSE
               LET v_referencia_aux = TRIM(v_referencia_aux)||"/"||v_plazo;
           END IF;

          IF v_num_pago = 0 or v_num_pago = '' or v_num_pago is null THEN
             LET v_num_pago_c = "-";
           ELSE
			 LET v_num_pago_c = v_num_pago||"/"||v_plazo; -- PAGO XX/XX
           END IF;

        --      SE DEFINE LOS AVISOS     --

		SELECT count(*)
          INTO v_cuantos_avisos
          FROM "informix".sd_amortiza_creditocrd
         WHERE empresa = pempresa
           AND num_credito = pnum_credito
           AND capital_status IN ('2','7','6');

                
        --      SALDOS DE INTERESES CAPITAL E IVA VENCIDOS      --

        SELECT mto_venc_trasp + monto_vencido,int_tra_no_exig + sdo_no_exig,mto_venc_int + mto_finan_vdo
          INTO v_capital_vencido,
               v_interes_vencido,
               v_iva_vencido
          FROM bdicred:sd_maesdoshistcrd 
         WHERE fecha = pfechahoy 
           AND empresa = pempresa
           AND num_credito = pnum_credito;


    --      CALCULA EL PAGO TOTAL DE LA REESTRUCTURA AL MES CORRIENTE      --
    --      EN LAS REESTRUCTURAS NO TENEMOS MORATORIOS      --

               LET v_pagototal     = round(NVL(v_capital_vencido,0) +
                                     NVL(v_interes_vencido,0) +
                                     NVL(v_iva_vencido,0) +
                                     NVL(v_capital_debe,0) +
                                     NVL(v_interes_debe,0) +
                                     NVL(v_iva_debe,0) +
                                     NVL(v_moratorio,0) +
                                     NVL(v_iva_moratorio,0),2);

               LET v_pago_minimo_tc = v_pagototal;

              IF nvl(v_capital_vencido,0) > 0 THEN
                 LET v_fecha_limite_pago_tc = DATE(1);
              else
                 let v_fecha_limite_pago_tc = date(pfechahoy + 1 units month);
              END IF;

  --      PERIODO ANTERIOR      --

  EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
		         INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
	  LET cod_ret = v_cod_ret_otro;
	END IF;

	--PERIODO
	LET v_periodo_tc_ini = v_periodo_anterior + 1 ;
	LET v_periodo_tc_fin = pfechahoy; 

    -- FECHA DE CORTE
    LET v_fecha_corte_tc = pfechahoy;

	--DIAS DEL PERIODO
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1);

    -- MONTO DEL CREDITO
    SELECT monto_otorgado
      INTO v_monto_otorgado
      FROM "informix".sd_maesdoscrd
     WHERE empresa = pempresa
       AND num_credito = pnum_credito;

       IF v_monto_otorgado IS NULL THEN
          LET v_monto_otorgado = 0;
       END IF;

--- RQI 12 297: CFDI 3.3 ---	 	
--- Campos descuento y subtotal
	if NVL(v_iva_debe,0) > 0 then
		LET v_descuento = 0.00;
		LET v_subtotal  = NVL(v_interes_debe,0);
	else 	
		LET v_descuento	= 0.01;
		LET v_subtotal  = 0.01;
	end if
	
	LET v_total = NVL(v_interes_debe,0) + NVL(v_iva_debe,0); 
--- RQI 12 297: CFDI 3.3 ---	 	   
	   
	   
    --      FECHA DE OTORGAMIENTO      --
    --      SE OBTUVO DE LA TABLA SD_MAECREDCRD DEL PRIMER QUERY EN LA ETAPA DE      -- 
    --      "GENERACION ENCABEZADO EDO CUENTA" Y SE GUARDO EN LA VARIABLE (v_fecha_apertura)      --

    INSERT INTO "informix".sd_encabezado2_edoctacrd
				(
                fecha_emision,              num_credito,
                capital_tc,                 interes_tc,
                iva_interes_tc,             numero_pago_tc,
                monto_pago,                 capital_ven_tc,
                interes_ven_tc,             iva_interes_ven_tc,
                moratorios_tc,              iva_moratorios_tc,
                pago_total_tc,              fecha_limite_tc,
                periodo_tc_ini,             periodo_tc_fin,
                fecha_corte_tc,             dias_periodo_tc,
                monto_credito_tc,           fecha_otorgamiento_tc,
                intereses_efec_pag,         comisiones_efec_cargadas,
				descuento,					subtotal,
				total,						val_base_cfdi
				)
		VALUES (
				pfechahoy,					      TRIM(pnum_credito),
				NVL(v_capital_debe,0),		      NVL(v_interes_debe,0),
				NVL(v_iva_debe,0),	              NVL(v_num_pago_c,'0'),
                NVL(v_cap_mto_cuota,0),           NVL(v_capital_vencido,0),
                NVL(v_interes_vencido,0),         NVL(v_iva_vencido,0),
                NVL(v_moratorio,0),               NVL(v_iva_moratorio,0),
                NVL(v_pagototal,0),               NVL(v_fecha_limite_pago_tc,DATE(1)),
                NVL(v_periodo_tc_ini,DATE(1)),    NVL(v_periodo_tc_fin,DATE(1)),
                NVL(v_fecha_corte_tc,DATE(1)),    NVL(v_dias_periodo_tc,''),
                NVL(v_monto_otorgado,0),          NVL(v_fecha_apertura,DATE(1)),
                0,                                0,
				NVL(v_descuento,0),				  NVL(v_subtotal,0),
				NVL(v_total,0),					  NVL(vBaseComi,0)
				);

   	--##	GENERACION DETALLE EDO CUENTA REESTRUCTURA            ##
    --      USTED DEBIA      --

	SELECT nvl(saldo_insoluto,0)
      INTO v_usted_debia
	  FROM "informix".sd_pie_edoctacrd
	 WHERE fecha_emision = pfechahoy - 1 UNITS MONTH
       AND num_credito = pnum_credito;

      IF v_usted_debia IS NULL OR v_usted_debia = '' THEN
           
           LET v_usted_debia = 0;
 
            SELECT NVL(SUM(sdo_cap_insoluto + int_tra_no_exig + mto_venc_int),0)
              INTO v_usted_debia
              FROM bdicred:sd_maesdoshistcrd 
             WHERE fecha = pfechahoy - 1 UNITS MONTH
               AND empresa = pempresa
               AND num_credito = pnum_credito;
      END IF;


      IF v_usted_debia IS NULL OR v_usted_debia = '' or v_usted_debia = 0 THEN

           LET v_usted_debia = 0;

            SELECT NVL(sdo_cap_insoluto,0)
              INTO v_usted_debia
              FROM bdicred:sd_maesdos
             WHERE empresa = pempresa
               AND num_credito = pnum_credito;
      END IF;

    --      VERIFICAMOS EL PAGO A TIEMPO PARA EL CAMBIO DE LA ETIQUETA DE VDO A VIG      --

            SELECT num_pago
              INTO v_num_pago_am
              FROM "informix".sd_amortiza_creditocrd
             WHERE empresa = pempresa
               AND num_credito = pnum_credito
               AND fecha_cuota = pfechahoy;

    --      USTED DEBIA     --

         LET v_maximo = 1;

        INSERT INTO sd_detalle_edoctacrd
            (
            fecha_emision,		num_credito,
            secuencia,			nlinea,
            fecha_mov,          concepto,
			cargos,             abonos           
            )
        VALUES
            (
            pfechahoy,			   pnum_credito,
            v_maximo,			   1,
            DATE(1),              "USTED DEBIA",
          	NVL(v_usted_debia,0),  v_abonos
            );
 		    LET v_contador = 0;

     --      SE INICIALIZA LA VALRIABLE DE INTERESES EFECTIVAMENTE PAGADOS     --
		LET v_int_efect_paga = 0;				
			
			
    FOREACH WITH HOLD

			SELECT lpad(month(a.fecha_mov),2,0)||'/'||
				   lpad(day(a.fecha_mov),2,0)||'/'|| lpad(year(a.fecha_mov),4,0),
				   a.secuencia,a.transacc_suc,a.folio_suc,a.referencia,a.descripcion,a.monto,a.naturaleza,a.codigo_ref,a.codigo_fun
			  INTO v_fecha_mov_aux,
				   v_serial,
				   v_transacc,
				   v_folio,
				   v_concepto,
				   v_descripcion_det,
				   v_monto_det,
				   v_naturaleza,
				   v_cod_ref,
				   v_cod_fun
			 FROM bdicred:sd_movhisedoctacrd  a
			WHERE  a.empresa = pempresa
			  AND a.num_credito = pnum_credito
			  AND a.referencia <> 'PROV'
		 ORDER BY fecha_mov,secuencia,folio_suc, a.codigo_ref

			
                        IF v_naturaleza = "A" THEN
                            LET v_abonos = v_monto_det;
                            LET v_cargos = 0;
                        ELSE
                            LET v_cargos = v_monto_det;
                            LET v_abonos = 0;
                        END IF
                        
						IF ((v_transacc in ('8205')) AND (v_cod_ref = 1)) THEN 
							LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 6))||" Abono por remesa de BTS";
						
						ELIF ((v_transacc in ('8286')) AND (v_cod_ref = 1)) THEN 
							LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 5))||" Abono por remesa de Appriza";
							
                        ELIF v_cod_fun = "222" AND v_cod_ref = 1 THEN
                           LET v_descripcion_det = "";
--                           LET v_descripcion_det = TRIM(v_concepto) || " " || v_cargos;
                           LET v_descripcion_det = "SU PAGO" || " " || v_cargos;
                           LET  v_cargos = 0;
                           LET  v_abonos = 0;
                        ELIF v_cod_fun = "225" AND v_cod_ref = 1 THEN
                           LET v_descripcion_det = "";
--                           LET v_descripcion_det = TRIM(v_concepto) || " " || v_cargos;
                           LET v_descripcion_det = "SU PAGO" || " " || v_cargos;
                           LET  v_cargos = 0;
                           LET  v_abonos = 0;
                        ELIF v_cod_fun = "222" AND v_cod_ref IN (28,1110) and (trim(v_concepto) = trim(v_num_pago_am::char(3))) THEN
                           LET v_descripcion_det = " - PAGO DE INT. VIG CON CARGO A CTA."|| Trim(v_concepto) || "/" || v_plazo;
						   LET v_fecha_mov_aux = DATE(1);
                        ELIF v_cod_fun = "222" AND v_cod_ref IN(47,1111) and (trim(v_concepto) = trim(v_num_pago_am::char(3))) THEN  
                           LET v_descripcion_det = " - PAGO IVA INT. VIG CON CARGO A CTA. "|| Trim(v_concepto) || "/" || v_plazo;
						   LET v_fecha_mov_aux = DATE(1);

                        ELIF v_cod_fun in ("222") AND v_cod_ref IN(10,12,1106,1118) and (trim(v_concepto) = trim(v_num_pago_am::char(3))) THEN  
                           LET v_descripcion_det = " - PAGO ANTICIPADO A CAPITAL "|| Trim(v_concepto) || "/" || v_plazo;
						   LET v_fecha_mov_aux = DATE(1);
                        ELIF v_cod_fun in ("225") AND v_cod_ref IN(10,12,1106,1118) and v_descripcion_det = "PAGO ANTICIPADO A CAPITAL" THEN  
                           LET v_descripcion_det = " - PAGO ANTICIPADO A CAPITAL "|| Trim(v_concepto) || "/" || v_plazo;
						   LET v_fecha_mov_aux = DATE(1);
						--  APERTURA CREDITO REESTRUCTURADO
                        ELIF v_cod_fun = "001" AND v_cod_ref = 2 THEN

							ELIF v_cod_ref in (43,44) THEN

                        ELSE
                           LET v_fecha_mov_aux = DATE(1);
                           LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
                        END IF



                        IF v_cod_fun = "222" AND v_cod_ref = 43 THEN
                            LET v_int_efect_paga = v_int_efect_paga + v_cargos;
                        END IF;

                        IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                            LET v_contador = v_contador + 1;   
                        ELSE
                            LET v_maximo = v_maximo + 1;
                            LET v_contador = 0;			    
                            LET v_contador = v_contador + 1;			
                        END IF;

                             INSERT INTO sd_detalle_edoctacrd
                                (
                                fecha_emision,		num_credito,
                                secuencia,			nlinea,
                                fecha_mov,          concepto,
                                cargos,             abonos
                                )
                            VALUES(
                                pfechahoy,			pnum_credito,
                                v_maximo,			v_contador,
                                v_fecha_mov_aux,    Trim(v_descripcion_det),   
                                v_cargos,           v_abonos
                                );


            LET v_fecha_mov_aux  = date(1);
            LET v_concepto       = "";
            LET v_cargos         = 0;
            LET v_abonos         = 0;

    END FOREACH;

	--      INTERESES EFECTIVAMENTE PAGADOS      --
		
		UPDATE bdicred:sd_encabezado2_edoctacrd 
		   SET intereses_efec_pag = v_int_efect_paga
		 WHERE fecha_emision = pfechahoy 
		   AND num_credito = pnum_credito; 	

        LET v_int_efect_paga = 0; 

        --      USTED DEBE      --

        SELECT NVL(SUM(sdo_cap_insoluto + int_tra_no_exig + sdo_no_exig + mto_venc_int + mto_finan_vdo),0)
          INTO v_usted_debe_tc
          FROM bdicred:sd_maesdoshistcrd 
         WHERE fecha = pfechahoy
           AND empresa = pempresa
           AND num_credito = pnum_credito;

		   LET v_contador = 1;	
		   LET v_maximo = v_maximo + 1 ;

        INSERT INTO sd_detalle_edoctacrd
            (
            fecha_emision,		num_credito,
            secuencia,			nlinea,
            fecha_mov,          concepto,              		
            cargos,             abonos           
            )
        VALUES
            (
            pfechahoy,			     pnum_credito,
            v_maximo,			     v_contador,
            DATE(1),                 "USTED DEBE",
            NVL(v_usted_debe_tc,0),  v_abonos
            );   
    
      IF vlStatusCred = 'FF'  THEN
        LET v_fecha_mov_aux =   lpad(month(vFechaCancela),2,0)||'/'||
				   lpad(day(vFechaCancela),2,0)||'/'|| lpad(year(vFechaCancela),4,0);

        INSERT INTO sd_detalle_edoctacrd
            (
            fecha_emision,		num_credito,
            secuencia,			nlinea,
            fecha_mov,          concepto,              		
            cargos,             abonos           
            )
        VALUES
            (
            pfechahoy,			     pnum_credito,
            0,			     0,
            v_fecha_mov_aux,                 "CREDITO LIQUIDADO",
            NVL(v_usted_debe_tc,0),  v_abonos
            ); 
      END IF;

	--##	GENERACION ACLARACIONES	 EDO CUENTA	REESTRUCTURA      ##


    INSERT INTO "informix".sd_mensajes_edoctacrd
                (
                fecha_emision, 		num_credito,
                num_producto,       secuencia,
        		nlinea,             si_paga,
    			mensajes
                )
       SELECT  pfechahoy, TRIM(pnum_credito),v_cod_producto,
               clave,secuencia,'' ,REPLACE(mensaje,v_linea_auxiliar,TRIM(v_plazo::VARCHAR(21)))
               FROM mensajes;


	--##	GENERACION   PIE	 EDO CUENTA	 REESTRUCTURA         ##

   	LET v_tasa_mensual      = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = 0;

    --     GENERA EL PIE DEL ESTADO DE CUENTA REESTRUCTURA      --

	INSERT INTO "informix".sd_pie_edoctacrd
			(
			fecha_emision,			num_credito,
            tasa_anual,             tasa_mensual,
			tasa_mora_anual,        tasa_mora_mensual,
			cat,					saldo_insoluto
			)
	VALUES
			(
			pfechahoy,				TRIM(pnum_credito),
			NVL(v_tasa_anual,0),	NVL(v_tasa_mensual,0),
            NVL(v_tasa_mora,0),     NVL(v_tasa_mensual_mora,0),
			NVL(v_cat,0),			NVL(v_usted_debe_tc,0)
			);

	--##	GENERACION  CLAVE DE COBRANZA REESTRUCTURA	          ##

    --      1.--TIPO DE CLIENTE: (2 Numero)      --
    --      2.--SITUACION ESPECIAL: (1 letra)    --

    SELECT FIRST 1 situacion, causa
      INTO v_situacion, v_situacion_esp
      FROM bdinteg:si_ctessitesp
     WHERE numcliente = v_numcte;

    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF

    --      2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087      --

    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "000";
    END IF

    LET v_situacion_esp= lpad( TRIM(v_situacion_esp), 3,'0');

    --      3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Anio Nacimiento (2 Numeros)      --

	SELECT TRIM(NVL(estado_civil,'')),
		   TRIM(NVL(SUBSTR(habita_en, 1,1),'P')),
		   TRIM(NVL(sexo,'')),
		   NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	  INTO v_estado_civil,
		   v_tp_casa,
		   v_sexo,
		   v_nacimiento
      FROM bdinteg:si_ctepf
	 WHERE numcte = v_numcte;

    --      6.--SALARIO (2 NUMEROS):      --

    -- FECHA DE OTORGAMIENTO
    -- SE OBTUVO DE LA TABLA SD_MAECREDCRD DEL PRIMER QUERY EN LA ETAPA DE
    -- "GENERACION ENCABEZADO EDO CUENTA" Y SE GUARDO EN LA VARIABLE (v_num_aper_ant)

	SELECT NVL(ingreso_mensual,0) / v_SalarioMinimoCoppel
	  INTO v_salario
	  FROM bdisolic:"informix".ss_resum_scor_fin
	 WHERE empresa = pempresa
	   AND num_solicitud = v_num_aper_ant;

	IF v_salario <= 0  OR v_salario IS NULL THEN
	  	IF cod_ret = "000" THEN
	  		LET cod_ret = "211";
	  	END IF
	ELSE
		IF v_salario >= 22 THEN
			LET v_cantidad = LPAD(22,2,'0');
		ELSE
			LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
		END IF
	END IF

    --      7.-ANTIGUEDAD: (2 NUMEROS)      --

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF

    --      9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)      --

	IF v_pagototal >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_pagototal < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(ROUND(v_usted_debe_tc),5,'0');
		END IF

	END IF

    --      10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)      --

	IF (v_pagototal - v_cap_mto_cuota) >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "214";
  		END IF
	END IF

    --      11.-FECHA DE ULT. PAGO: (4 NUMEROS)       --

    SELECT max(fecha_mov) INTO v_fecha_ultimo_pago
      FROM bdicred:sd_movhiscrd
     WHERE empresa = pempresa
       AND num_credito = pnum_credito
       AND codigo_fun = '222' 
       AND codigo_ref = 1;


	IF v_fecha_ultimo_pago IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago_month = MONTH(v_fecha_ultimo_pago);
		LET v_fec_ult_pago_year =  SUBSTR(YEAR(v_fecha_ultimo_pago),3,2);
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF

    --      12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)     --

    FOREACH
       SELECT FIRST 1 importe, TO_CHAR(fecha_compac,"%m%y")
	     INTO v_monto_ult_convenio , v_fecha_ult_convenio
	     FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa
	      AND numcliente = v_numcte
     ORDER BY fecha_compac DESC
         EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
		LET v_monto_ult_convenio =  LPAD("0",5,'0');
    ELSE
        LET v_monto_ult_convenio= ROUND(v_monto_ult_convenio);
        LET v_monto_ult_convenio= LPAD(TRIM(v_monto_ult_convenio), 5,'0');
	END IF

    --      13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)      --

    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
		LET v_fecha_ult_convenio =  "NDND";
	END IF

    --      14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)      --

    FOREACH
      SELECT FIRST 1 'P'
	    INTO v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac
	   WHERE empresa = pempresa
	     AND numcliente = v_numcte
	     AND fecha_compac >= v_periodo_tc_ini
	     AND fecha_compac <= v_periodo_tc_fin
	ORDER BY fecha_compac DESC
       	EXIT FOREACH;
    END FOREACH;

    IF v_est_cumpl_convenio IS NULL OR v_est_cumpl_convenio = "" THEN
		LET v_est_cumpl_convenio =  "-";
	END IF

    --      15.-NUMERO DE AVISOS: (1 LETRA)      --

	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos = 5 THEN
		LET v_avisos =  "4";
	ELIF v_cuantos_avisos >= 6 THEN
		LET v_avisos =  "V";
	END IF;

	IF v_cuantos_avisos = 0 OR v_cuantos_avisos = 1 OR v_cuantos_avisos = 2 THEN
		LET v_nivel_eficiencia = "1";
    ELIF v_cuantos_avisos = 3 THEN
		LET v_nivel_eficiencia = "2";
	ELIF v_cuantos_avisos = 4 THEN
		LET v_nivel_eficiencia = "3";
    ELIF v_cuantos_avisos = 5 OR v_cuantos_avisos = 6 THEN
		LET v_nivel_eficiencia = "4";
	ELIF v_cuantos_avisos > 6 THEN
		LET v_nivel_eficiencia = "5";
	END IF;

    --      Modifico para Clave de Cobranza ----- RQM 09 117      --

	IF v_cap_mto_cuota = 0 OR v_cap_mto_cuota IS NULL OR v_cap_mto_cuota = '' THEN
		LET v_cap_mto_cuota = 0;
	END IF;

LET posicion11= ROUND(v_pago_minimo_tc - v_cap_mto_cuota);
LET posicion11= LPAD(TRIM(posicion11), 5,'0');

LET posicion17= ROUND(v_pago_minimo_tc);
LET posicion17= LPAD( TRIM(posicion17), 5,'0');

    --     ARMO LA CLAVE DE COBRANZA REESRUCTURA :      --
	
	------ Convierte nÃºmero de producto para Carteras
	IF v_cod_producto = '6011' THEN 
		LET vTipProdCarterasRT = '3';
	END IF;
	
	--DIA LIMITE DE PAGO --SD_MAECREDANEXOCRD
	SELECT  prox_fecha_pago
      INTO  v_fecha_limite_pago_rees
	  FROM "informix".sd_maecredanexocrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;

	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = SUBSTRING(TO_CHAR(v_fecha_limite_pago_rees, "%y-%m-%d") FROM 7 FOR 2)	||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;
    
    IF v_clave1 IS NULL THEN
       LET v_clave1 = "/ / /";
    ELIF v_clave2 IS NULL THEN
       LET v_clave2 = "/  /";
    ELIF  v_clave3 IS NULL THEN
       LET v_clave3 = "/ /";
    ELIF  v_clave4 IS NULL THEN  
       LET v_clave4 = "/ /";
    ELIF  v_clave5 IS NULL THEN  
       LET v_clave5 = "/ / /";
    END IF;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;

    --      EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA REESTRUCTURA      --

	UPDATE "informix".sd_encabezado_edoctacrd
       SET cl_cobra = trim(v_cl_cobranza)
	 WHERE fecha_emision = pfechahoy
	   AND num_credito = pnum_credito;

  RETURN cod_ret;

END;
END PROCEDURE
DOCUMENT
"Se crea procedimiento para obtener",
"la informacion para la generacion de los",
"estados de cuenta para creditos reestructurados, su",
"clave de cobranza y ruta correspondiente",
"base de datos : bdicred",
"AUTOR : Bernardo Baez",
"FECHA : 23/Julio/2009";

CREATE PROCEDURE "informix".generaedosctacrd_pp(pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE)  
--EXECUTE PROCEDURE generaedosctacrd_pp('001','760001933257',mdy('03','18','2020')); 




RETURNING CHAR(6);

--     VARIABLES CONTROL DE ERRORES     --
DEFINE cod_ret             		CHAR(6);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			CHAR(6);
--     VARIABLES GENERALES      --
DEFINE v_status_cred	        CHAR(2);        --Status Credito
DEFINE v_num_aper_ant           CHAR(20);       --NumeroAperturaAntesdeReestructura
DEFINE v_plazo                  INTEGER;        --plazo
DEFINE v_numerociudad 	        SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 	        INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerociudadCoppel     SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniaCoppel    INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerocalle 	        INT;		    --Numero Calle Direccion Cliente
DEFINE v_numeroextcalle         CHAR(10);       --Numero Exterior Calle Direccion Cliente
DEFINE v_estado 		        CHAR(2);	    --Numero Estado
DEFINE v_nombrecalle	        CHAR(30);       --Nombre Calle Catalogo Calles
DEFINE v_centro			        INT;		    --Centro Catalogo de Zonas
DEFINE v_jefegrupozona	        INT;		    --Clave Jefe Grupo Zona
DEFINE v_supervisorzona	        INT;		    --Clave Supervisor Zona
DEFINE v_iva_suc   		        DECIMAL(18,2);  --Mas_iva
DEFINE v_capital_debe 	        DECIMAL(14,2);  --Capital_Debe
DEFINE v_interes_debe 	        DECIMAL(14,2);  --Interes_Debe
DEFINE v_iva_debe 		        DECIMAL(14,2);  --Iva_Debe
DEFINE v_num_pago               INTEGER;        --Numero_pago_tc
DEFINE v_usted_debe_tc          DECIMAL(18,2);  --Usted_Debe_General
DEFINE v_maximo        		    INTEGER;        --Secuencia
DEFINE v_fecha_ultimo_pago_aux  DATE;           --Fecha Ultimo Pago
DEFINE v_aplica_factor			DECIMAL(14,2);  --Aplica_Factor
DEFINE v_periodo_anterior  	    DATE;			--Fecha Periodo Anterior
DEFINE v_periodo_prox  	        DATE;			--Fecha Periodo Anterior
--	    VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
DEFINE v_numcte                 CHAR(20);	   --Numero de Credito
DEFINE v_nombre_cte             CHAR(150);	   --Nombre del Cliente
DEFINE v_direccion_cn           CHAR(456);	   --Direccion
DEFINE v_direccion_col          CHAR(376);	   --Colonia
DEFINE v_direccion_del          CHAR(376);	   --Delegacion O Municipio
DEFINE v_edo_cd                 CHAR(376);	   --Estado
DEFINE v_cl_cobra               CHAR(60);	   --Clave de Cobranza
DEFINE v_sucursal               CHAR(4);  	   --Sucursal Cliente
DEFINE v_sucursal_nombre        CHAR(40);	   --Nombre de la Sucursal
DEFINE v_sucursal_gerente       CHAR(40);	   --Nombre del Gerente del Sucursal
DEFINE v_rfc                    CHAR(13);	   --RFC del Cliente
DEFINE v_sucursal_tel           CHAR(14);	   --Telefono de la Sucursal
DEFINE v_cod_postal             CHAR(5);	   --Codigo Postal Direccion Cliente
DEFINE v_ruta          	        CHAR(47);	   --Ruta
DEFINE v_entre_calles           CHAR(40);	   --Entre Calles
DEFINE v_observaciones          CHAR(80);	   --Datos Complementarios
DEFINE cInserto                 CHAR(15);      --Informacion del Inserto
DEFINE cCuentaEfec              CHAR(20);      -- Cuenta efectiva asociada al credito
DEFINE v_SalarioMinimoCoppel  SMALLINT;        -- Salario minimo coppel
DEFINE v_confirmacion			CHAR(5);	   --Confirmacion para CFDI 
DEFINE cNomProducto				CHAR(40);	   --PP Flexible 

--	    VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
DEFINE v_capital_tc   		    DECIMAL(14,2);	--Capital_tc
DEFINE v_iva_interes_tc   	    DECIMAL(14,2);	--Iva_Interes_tc
DEFINE v_num_pago_c             CHAR(9);        --Numero_pago_tc con la union del plazo xx/xx
DEFINE v_cap_mto_cuota          DECIMAL(14,2);  --Monto_Pago
DEFINE v_interes_vigente        DECIMAL(14,2);  --Interes vigente
DEFINE v_iva_vigente            DECIMAL(14,2);  --IVA DE INTERES VIGENTE
DEFINE v_capital_vencido        DECIMAL(14,2);  --Capital_Ven_tc
DEFINE v_interes_vencido        DECIMAL(14,2);  --Interes_Ven_tc
DEFINE v_iva_vencido            DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE v_moratorio              DECIMAL(14,2);  --Moratorios
DEFINE v_iva_moratorio          DECIMAL(14,2);  --iva_Moratorios
DEFINE v_pagototal              DECIMAL(14,2);  --Pago_Total_tc
DEFINE v_fecha_limite_pago_tc   DATE;			--Fecha_Limite_tc
DEFINE v_periodo_tc_ini   		DATE;			--Periodo_tc_Ini
DEFINE v_periodo_tc_fin   		DATE;			--Periodo_tc_Fin
DEFINE v_fecha_corte_tc   		DATE;			--Fecha_Corte
DEFINE v_dias_periodo_tc 		INTEGER;		--Dias_Periodo_tc
DEFINE v_dias_periodo_prox 		INTEGER;		--Dias_Periodo_tc
DEFINE v_monto_otorgado         DECIMAL(14,2);  --Monto_Credito_tc
DEFINE v_fecha_apertura		    DATE;			--Fecha_Otorgamiento_tc
DEFINE v_descuento				DECIMAL(14,2);	--Descuento por NO IVA CFDI 3.3
DEFINE v_subtotal				DECIMAL(14,2);	--Subtotal intereses CFDI 3.3
DEFINE v_total					DECIMAL(14,2);	--Total intereses e iva CFDI 3.3	
DEFINE v_comisiones				DECIMAL(14,2);  --PP FLEX
DEFINE v_iva_comisiones			DECIMAL(14,2);  --PP FLEX					

--	    VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA      --
DEFINE v_fecha_mov_aux          CHAR(10);           --Fecha Movimiento de Operacion
DEFINE v_fecha_mora             CHAR(10);
DEFINE v_usted_debia   			DECIMAL(18,2);	--Usted_debia
DEFINE v_contador      		smallint;
DEFINE v_abonos	       		decimal(18,2);
DEFINE v_serial             char(16);
DEFINE v_concepto           CHAR(296);
DEFINE v_descripcion_det    CHAR(296);
DEFINE v_monto_det          DECIMAL(18,2);
DEFINE v_naturaleza         CHAR(1);
DEFINE v_cod_ref            INTEGER;
DEFINE v_cod_fun            CHAR(3);
DEFINE v_cargos             DECIMAL(18,2);
--	    VARIABLES GENERACION MENSAJES EDO CUENTA REESTRUCTURA     --
DEFINE v_secuencia_mensaje		SMALLINT;
DEFINE v_si_paga		    	VARCHAR(255);
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
--	    VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
DEFINE v_tasa_anual			    DECIMAL(18,2);
DEFINE v_tasa_mensual		    DECIMAL(18,2);
DEFINE v_tasa_mora			    DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	    DECIMAL(18,2);
DEFINE  v_cat			    	DECIMAL(8,2) ;
DEFINE v_saldo_promedio		    DECIMAL(18,2);
--	   VARIABLES CLAVE DE COBRANZA REESTRUCTURA     --
DEFINE v_situacion              CHAR(1);
DEFINE v_situacion_esp          CHAR(3);
DEFINE v_estado_civil           CHAR(1);
DEFINE v_tp_casa                CHAR(1);
DEFINE v_sexo                   CHAR(1);
DEFINE v_nacimiento             CHAR(2);
DEFINE v_salario                DECIMAL(18,2);
DEFINE v_cantidad               CHAR(2);
DEFINE v_antiguedad             CHAR(2);
DEFINE v_monto_adeudo           DECIMAL(18,2);
DEFINE v_mto_tot_adeudo         CHAR(5);
DEFINE v_mto_adeudo_venc        DECIMAL(18,2);
DEFINE v_monto_financiado	    DECIMAL(18,2);
DEFINE v_adeudo_vencido         CHAR(5);
DEFINE v_fecha_ultimo_pago	    DATE;
DEFINE v_fec_ult_pago           CHAR(4);
DEFINE v_fec_ult_pago_month     CHAR(2);
DEFINE v_fec_ult_pago_year      CHAR(2);
DEFINE v_monto_ult_convenio     CHAR(5);
DEFINE v_fecha_ult_convenio     CHAR(4);
DEFINE v_est_cumpl_convenio     CHAR(1);
DEFINE v_cuantos_avisos		    INTEGER;
DEFINE v_avisos 	    	    CHAR(1);
DEFINE v_nivel_eficiencia       CHAR(1);
DEFINE posicion11               CHAR(5);
DEFINE v_pago_minimo_tc   		DECIMAL(18,2);	--sdo_pagar
DEFINE posicion17               CHAR(5);
DEFINE v_clave1		          	VARCHAR(40);
DEFINE v_clave2		    	    VARCHAR(40);
DEFINE v_clave3		    	    VARCHAR(40);
DEFINE v_clave4		    	    VARCHAR(40);
DEFINE v_clave5         	    VARCHAR(40);
DEFINE v_cl_cobranza            CHAR(64);
DEFINE cNumProducto             CHAR(4);
DEFINE cIniClvCob               CHAR(1);
DEFINE iDiasCalc           INTEGER;
DEFINE dTasaInter          DECIMAL(9,6);
DEFINE dSdoCapital         DECIMAL(18,2);
DEFINE dCapTrasNoVen       DECIMAL(18,2);
DEFINE iDiasInt            INTEGER;
DEFINE dSdo                DECIMAL(18,2);
DEFINE v_inter_efect_pagados DECIMAL(18,2);
DEFINE v_comisiones_efec_pag DECIMAL(18,2);
DEFINE  vlFechaCutoa    DATE;
--     CREDINOMINA     --
DEFINE iTpDiasFechaPago SMALLINT;
DEFINE dtFechaProxCuota DATE;
DEFINE iDiaCorte        INTEGER;
DEFINE cCodRet          CHAR(6);
DEFINE v_transacc      		char(4);
DEFINE v_folio      		VARCHAR(20);
DEFINE v_fecha_limite_pago_pp DATE;
DEFINE v_monto_linea DECIMAL(18,2);
DEFINE cInd_tabla_amortizacion CHAR(1);
DEFINE v_monto_linea_dig DECIMAL(18,2);
DEFINE dFecha_otorga_dig DATE;
DEFINE v_Atr	INTEGER;
DEFINE vTipProdCarterasPP	CHAR(2);

--------------------------------------------------------------
-- Se agregan variables de catalogo de Centros de Impresion --
DEFINE sNumRegion CHAR(2); --Numero de region (centro de impresion)
DEFINE sNumCiudadB CHAR(4); --Numero de ciudad BanCoppel
DEFINE sNumCiudadC CHAR(3); --Numero de ciudad COPPEL

---- Limpieza de variables cfdi 4.0
DEFINE cIVA_cfdi	CHAR(04); -- Valor de IVA para CFDI 4.0 X UBICACION
DEFINE vObjetoImp	CHAR(02); -- Objeto Impuesto para CFDI 4.0
DEFINE vValBase		DECIMAL(12,2); -- Valor Base CFDI 4.0
DEFINE vIvaCfdi		DECIMAL(18,2); -- IVA PARA CFDI X CUENTA
DEFINE vIvaInteresesReales	DECIMAL(12,2); -- Valor de iva de intereses reales CFDI 4.0
DEFINE vInteresesReales	DECIMAL(12,2);  -- Valor de intereses reales 4.0
DEFINE vIvaDeComisiones	DECIMAL(12,2);

--- RQI 21 401
DEFINE v_nombre1	CHAR(26);
DEFINE v_nombre2	CHAR(26);
DEFINE v_apell_paterno	CHAR(26);
DEFINE v_apell_materno	CHAR(26);
DEFINE v_rfc_alterno	CHAR(13);
DEFINE v_rfc1			CHAR(13);
DEFINE v_fecha_alta		DATE;

LET iDiasCalc           = 0;
LET dTasaInter          = 0;
LET dSdoCapital         = 0;
LET dCapTrasNoVen       = 0;
LET iDiasInt            = 0;
LET dSdo                = 0;
--	    VARIABLES CONTROL DE ERRORES     --
LET cod_ret                  = "000000";
LET sql_err                  = 0;
LET v_cod_ret_otro           = "000000";
--	    VARIABLES GENERALES     --
LET v_status_cred             = "";
LET v_num_aper_ant            = "";
LET v_plazo                   = 0;
LET v_numerociudad 		      = 0;
LET v_numerocolonia 	      = 0;
LET v_numerocalle 		      = 0;
LET v_numeroextcalle 	      = "";
LET v_estado 			      = "";
LET v_nombrecalle		      = "";
LET v_centro			      = 0;
LET v_jefegrupozona		      = 0;
LET v_supervisorzona	      = 0;
LET v_iva_suc				  = 0;
LET v_capital_debe 			  = 0;
LET v_interes_debe 			  = 0;
LET v_iva_debe 				  = 0;
LET v_num_pago                = 0;
LET v_usted_debe_tc           = 0;
LET v_maximo                  = 0;
LET v_fecha_ultimo_pago_aux   = DATE(1);
LET v_aplica_factor           = 0;
LET v_periodo_anterior   	  = DATE(1);
LET v_periodo_prox            = DATE(1);
--	    VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
LET v_numcte        	      = "";
LET v_nombre_cte    	      = "";
LET v_direccion_cn  	      = "";
LET v_direccion_col	          = "";
LET v_direccion_del 	      = "";
LET v_edo_cd     		      = "";
LET v_cl_cobra      	      = "";
LET v_sucursal                = "";
LET v_sucursal_nombre         = "";
LET v_sucursal_gerente        = "";
LET v_rfc           	      = "";
LET v_sucursal_tel            = "";
LET v_cod_postal    	      = "";
LET v_ruta           	      = "";
LET v_entre_calles   	      = "";
LET v_observaciones  	      = "";
LET cInserto                  = "";
LET cCuentaEfec               = "";
LET v_SalarioMinimoCoppel     = 0;
LET v_confirmacion			  = ""; 
LET cNomProducto			  = "";
--	    VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
LET v_capital_tc   			  = 0;
LET v_iva_interes_tc   		  = 0;
LET v_num_pago_c              = "";
LET v_cap_mto_cuota           = 0;
LET v_capital_vencido         = 0;
LET v_interes_vigente         = 0;
LET v_iva_vigente             = 0;
LET v_interes_vencido         = 0;
LET v_iva_vencido             = 0;
LET v_moratorio               = 0;
LET v_iva_moratorio           = 0;
LET v_pagototal               = 0;
LET v_fecha_limite_pago_tc    = " ";
LET v_periodo_tc_ini   		  = " ";
LET v_periodo_tc_fin   		  = " ";
LET v_fecha_corte_tc   		  = " ";
LET v_dias_periodo_tc 		  = 0;
LET v_dias_periodo_prox       = 0;
LET v_monto_otorgado          = 0;
LET v_fecha_apertura	      = " ";
LET v_descuento				  = 0; --CFDI 3.3
LET v_subtotal				  = 0; --CFDI 3.3
LET v_total					  = 0; --CFDI 3.3
LET v_comisiones			  = 0; --PP FLEX
LET v_iva_comisiones		  = 0; --PP FLEX	

--	    VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA     --
LET v_fecha_mov_aux          = DATE(1);
LET v_fecha_mora             = DATE(1);
LET v_usted_debia   		 = 0;
LET v_contador         = 0;
LET v_abonos           = 0;
LET v_serial           = "";
LET v_concepto         = "";
LET v_descripcion_det  = "";
LET v_monto_det        = 0;  --Mas_Disposiciones
LET v_naturaleza       = "";
LET v_cod_ref          = 0;
LET v_cod_fun          = "";
LET v_cargos           = 0;
--	    VARIABLES GENERACION MENSAJES EDO CUENTA REESTRUCTURA     --
LET v_secuencia_mensaje      = 0;
LET v_si_paga			     = "";
--	    VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
LET v_tasa_anual		     = 0 ;
LET v_tasa_mensual 		     = 0 ;
LET v_tasa_mora			     = 0 ;
LET v_tasa_mensual_mora	     = 0 ;
LET v_saldo_promedio	     = 0 ;
--	    VARIABLES CLAVE DE COBRANZA REESTRUCTURA     --
LET v_situacion              = "";
LET v_situacion_esp          = "";
LET v_estado_civil           = "";
LET v_tp_casa                = "";
LET v_sexo                   = "";
LET v_nacimiento             = "";
LET v_salario                = 0;
LET v_cantidad               = "";
LET v_antiguedad             = "";
LET v_monto_adeudo		     = 0;
LET v_mto_tot_adeudo         = "";
LET v_mto_adeudo_venc        = 0;
LET v_monto_financiado	     = 0;
LET v_adeudo_vencido         = "";
LET v_fecha_ultimo_pago      = " ";
LET v_fec_ult_pago           = "";
LET v_fec_ult_pago_month     = "";
LET v_fec_ult_pago_year      = "";
LET v_monto_ult_convenio     = "";
LET v_fecha_ult_convenio     = "";
LET v_est_cumpl_convenio     = "";
LET v_cuantos_avisos	     = 0;
LET v_avisos 	    	     = "0";
LET v_nivel_eficiencia	     = 0;
LET posicion11               = "";
LET v_pago_minimo_tc   	     = 0;
LET posicion17               = "";
LET v_clave1		 	     = "";
LET v_clave2		 	     = "";
LET v_clave3			     = "";
LET v_clave4		 	     = "";
LET v_clave5         	     = "";
LET v_cl_cobranza            = "";
LET cNumProducto             = '';
LET cIniClvCob               = '';
LET v_inter_efect_pagados    = 0;
let v_comisiones_efec_pag   = 0;
LET vlFechaCutoa = DATE(1);
----- CREDINOMINA ------
LET iTpDiasFechaPago = 0;
LET dtFechaProxCuota = DATE(1);
LET iDiaCorte        = 0;
LET cCodRet          = 0;
LET v_numerociudadCoppel     = 0;
LET v_numerocoloniaCoppel    = 0;
LET v_folio     = "";
LET v_transacc     = "";
LET v_cat     = 0;
LET v_fecha_limite_pago_pp = " ";
LET v_monto_linea  = 0;
LET cInd_tabla_amortizacion = '';
LET v_monto_linea_dig = 0;
LET dFecha_otorga_dig  = DATE(1);
LET v_Atr	= 0;
LET vTipProdCarterasPP	= '';

-------------------------------------------------------------------------------
-- Se limpian variables para los campos region, ciudad y centro de impresion --
LET sNumRegion 	= '0';
LET sNumCiudadB = '0';
LET sNumCiudadC = '0';

---- Limpieza de variables cfdi 4.0
LET cIVA_cfdi	= 0;
LET vObjetoImp	= '';
LET vValBase	= 0;
LET vIvaCfdi	= 0;
LET vIvaInteresesReales	= 0;
LET vInteresesReales	= 0;
LET vIvaDeComisiones	= 0;

--- OBTIENE RFC LIMPIO PARA MOSTRAR
LET v_nombre1 = '';
LET v_nombre2 = '';
LET v_apell_paterno	= '';
LET v_apell_materno	= '';
LET v_rfc_alterno	= '';
LET v_rfc1			= '';
LET v_fecha_alta	= DATE(1);

-- Fecha: 11/08/2009
-- Autor: Paul Ivan Quintero Varela
-- Observaciones: Se modifica con la finalidad de agregar las adecuaciones para el desgloce de movimientos
--                            en el detalle correspondiente, se contemplan los cambios para la clave de cobranza,
--                             se modifica la obtencion del ultimo movimiento, el usted debe, usted debia, y
--                             finalmente las secuencias y nlineas de cada insercion en la tabla del detalle.
-- Fecha: 22/12/2009
-- Autor: Roque Enrique Solis
-- Observaciones: Se modifica con la finalidad de generar los estados de cuenta para Prestamos Personales

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
     END IF
  END EXCEPTION WITH RESUME ;

	---SET DEBUG FILE TO "/informix/Daniella/generaedosctacrd_pp.out";
	---TRACE ON;

   	--##############################################################
	--##	GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA         ##
   	--##############################################################
	
    --     SD_MAECREDCRD     --

	SELECT a.numcte,a.num_producto, a.sucursal, a.fecha_apertura,
		   a.tasa_interes,	a.tasa_moratorios - a.tasa_interes,
		   DECODE(status_cred,'AR','0','BR','1','TR','2','0'),
		   status_cred, num_aper_ant, plazo
      INTO v_numcte,cNumProducto, v_sucursal, v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           v_avisos, v_status_cred, v_num_aper_ant,  v_plazo
	  FROM "informix".sd_maecredcrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;
	   
	 SELECT nvl(atr,-1) INTO v_Atr 
	 FROM "informix".sd_maesdoscrd where num_credito = pnum_credito;
	   
--RQM 10 1379	   
	  IF v_status_cred = 'AA' OR (v_Atr = 0 AND v_status_cred = 'E1') THEN
	  LET cInd_tabla_amortizacion = '1';
	     
	   ELSE 
	    LET cInd_tabla_amortizacion = '0';
	  END IF;
	  
		 SELECT a.monto_otorgado
				INTO v_monto_linea
			FROM "informix".sd_maesdoscrd a
		 WHERE a.empresa = pempresa
		   AND a.num_credito = pnum_credito;
		
		SELECT monto_linea,fecha_otorga	
			INTO v_monto_linea_dig, dFecha_otorga_dig
			FROM "informix".sd_linea_prestamo a
		 WHERE a.empresa = pempresa
		   AND a.num_credito = pnum_credito;
--RQM 10 1379		   
		
		   
	/*	   IF  cNumProducto <> '6800' THEN
	     LET v_monto_linea = 0.00;
			END IF;	 */

	SELECT cod_prod, nombre_prod  --adlm PP Flexible
	  INTO cIniClvCob, cNomProducto
	  FROM bdicred:sd_definicion
	 WHERE num_producto=cNumProducto;

	IF cIniClvCob IS NULL THEN
	    LET cIniClvCob = '';
	END IF;

	--AAME 2016-01-15 RQI 27 006 Se agrega validacion para que el cat para 6400 se obtenga uno diferente si es Mensual o quincenal.
	IF cNumProducto ='6400' AND iTpDiasFechaPago= 2 THEN --Quincenal
		SELECT cat_quincenal INTO v_cat from bdicred:sd_tasa_cat
		 WHERE empresa = pempresa and producto = cNumProducto
		   AND tasa = v_tasa_anual;
	ELSE  --Mensual		
		 IF cNumProducto <> '6400' THEN
			SELECT cat
			INTO v_cat
			FROM bdicred:"informix".sd_maecredanexocrd
			WHERE empresa = pempresa
			AND num_credito = pnum_credito;
		 END IF;
		IF NVL(v_cat,0) = 0 THEN
			SELECT cat INTO v_cat from bdicred:sd_tasa_cat
			 WHERE empresa = pempresa and producto = cNumProducto
			   AND tasa = v_tasa_anual;	
		END IF;
	END IF;

    IF v_cat IS NULL THEN
	   LET v_cat = 0.0;
	END IF;
	
	------ Convierte nÃºmero de producto para Carteras
	IF cNumProducto = '6300' THEN 
		LET vTipProdCarterasPP = '4';
	ELIF cNumProducto = '7600' THEN 
		LET vTipProdCarterasPP = '7';
	ELIF cNumProducto = '7700' THEN 
		LET vTipProdCarterasPP = '8';
	ELIF cNumProducto = '6800' THEN 
		LET vTipProdCarterasPP = '9';
	ELIF cNumProducto = '9100' THEN 
		LET vTipProdCarterasPP = '10';
	ELIF cNumProducto = '9300' THEN 
		LET vTipProdCarterasPP = '11';
	ELIF cNumProducto IN('6400') THEN
    	LET vTipProdCarterasPP = '';
	END IF;

	--     SI_CLIENTE     --

	SELECT a.nombre1,		a.nombre2,	a.apell_paterno,	a.apell_materno,
		   a.rfc_alterno,	a.rfc,		a.fecha_alta
	INTO	v_nombre1,		v_nombre2,	v_apell_paterno,	v_apell_materno,
		   v_rfc_alterno,	v_rfc1,		v_fecha_alta
	FROM bdinteg:"informix".si_cliente a
	WHERE a.numcte = v_numcte;
	
	IF v_rfc1 = '' OR v_rfc1 IS NULL THEN
		LET v_rfc = TRIM(v_rfc_alterno);
	ELSE
		LET v_rfc = TRIM(v_rfc1);
	END IF;
	
	LET v_antiguedad = NVL(SUBSTR(YEAR(v_fecha_alta), 3, 2),'');
	
	LET v_nombre_cte = TRIM(v_nombre1) || " " ||TRIM(v_nombre2) || " " || TRIM(v_apell_paterno) || " " ||TRIM(v_apell_materno);

	 --     SI_DIRECCIONES     --

	 SELECT TRIM(b.numeroextcalle) || " " || TRIM(b.numerointcalle),
	       b.cod_postal,			b.entre_calles,
	       b.observaciones,		   	b.numerociudad,
	       b.numerocolonia,			b.numerocalle,
	       b.numeroextcalle,	    b.estado
	  INTO v_direccion_cn,
		   v_cod_postal,			v_entre_calles,
		   v_observaciones,		    v_numerociudad,
		   v_numerocolonia,			v_numerocalle,
		   v_numeroextcalle,		v_estado
	  FROM bdinteg:"informix".si_direcciones_actual b
	 WHERE b.numcte  = v_numcte
	   AND tipo_dir = "1";

	--     SI_CATCALLES     --

	SELECT TRIM(c.nombrecalle)
	  INTO v_nombrecalle
	  FROM bdinteg:"informix".si_catcalles c
	 WHERE c.numerocalle = v_numerocalle;

	--     SI_CATZONAS     --

	SELECT d.nombrezona,			d.centro,
		   d.jefegrupozona,			d.supervisorzona,
		   d.numerociudadcoppel,    d.numerocoloniacoppel
	  INTO v_direccion_col,			v_centro,
		   v_jefegrupozona,			v_supervisorzona,
		   v_numerociudadCoppel,    v_numerocoloniaCoppel
	  FROM bdinteg:"informix".si_catzonas d
	 WHERE d.numerociudad = v_numerociudad
	   AND d.numerocolonia=v_numerocolonia;

	--     SI_CATCIUDADES     --

	SELECT e.nombreciudad
	  INTO v_direccion_del
	  FROM bdinteg:"informix".si_catciudades e
	 WHERE e.numerociudad = v_numerociudad;

	--     SI_ESTADOS     --

	SELECT f.nombre
	  INTO v_edo_cd
	  FROM bdinteg:"informix".si_estados f
	 WHERE f.estado = v_estado;
	 
	---------------------------------------
	------- CENTROS IMPRESION COPPEL ------
	SELECT LPAD(num_region,2,0),LPAD(num_ciudad_banco,4,0),LPAD(num_ciudad_coppel,3,0)
	INTO sNumRegion,sNumCiudadB,sNumCiudadC
	FROM "informix".sd_centrosimpresion_coppel
	WHERE num_ciudad_banco = v_numerociudad;
	--AND num_ciudad_coppel = v_numerociudadCoppel;

	--Valida el numero de region (Centro de impresion) esta en nulo o vacio.
	IF nvl(sNumRegion,'') = '' OR sNumRegion IS NULL THEN
		LET sNumRegion 	= '00';
		LET sNumCiudadB = LPAD(v_numerociudad,4,0);
		LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
	end if;
	-- Valida si la ciudad banco o ciudad coppel son diferentes a las del catalogo centros impresion.
	IF sNumCiudadC != v_numerociudadCoppel THEN 
		LET sNumRegion 	= '00';
		LET sNumCiudadC = LPAD(v_numerociudadCoppel,3,0);
	ELIF sNumCiudadB != v_numerociudad THEN
		LET sNumRegion 	= '00';
		LET sNumCiudadB = LPAD(v_numerociudad,4,0);
	END IF;
	--Valida la ciudad banco y ciudad coppel si esta en nulo o vacio.
	IF nvl(sNumCiudadC,'') = '' OR sNumCiudadC IS NULL THEN
		LET sNumCiudadC = '000';
	END IF;
	IF nvl(sNumCiudadB,'') = '' OR sNumCiudadB IS NULL THEN
		LET sNumCiudadB = '0000';
	END IF;
	

	 --     SI_SUCURSALES     --

	 SELECT d.nombre,				d.gerente,
		     d.iva
	  INTO v_sucursal_nombre,		v_sucursal_gerente, v_iva_suc
	  FROM bdinteg:"informix".si_sucursales d
	 WHERE d.empresa  = pempresa
	   AND d.sucursal = v_sucursal;	   
	   
	   select tel1 
	  into v_sucursal_tel
	  from bdinteg:si_ptf 
	 where id_ptf = v_sucursal
	 and tipo = 'S';
	
	LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
	LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
			     LPAD(v_centro,6,'0')||"/"||
			     LPAD(v_jefegrupozona,8,'0')||"/"||
			     LPAD(v_supervisorzona,8,'0')||"/"||
			     LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
			     LPAD(v_numerocalle,6,'0')||"/"||
			     LPAD(TRIM(v_numeroextcalle),5,'0');

    --   Se obtiene el inserto correspondiente           --

     SELECT insertos
       INTO cInserto
       FROM "informix".sd_marcaje
      WHERE empresa = pempresa
        AND num_credito= pnum_credito
        AND fecha_emision = pfechahoy;

       IF cInserto IS NULL THEN
          LET cInserto='000000000000000';
       END IF;

	--     SE OBTIENE EL NUMERO DE CUENTA EFECTIVA     --

	SELECT num_cta
      INTO cCuentaEfec
	  FROM "informix".sd_ctascarg
	 WHERE empresa = pempresa
	   AND naturaleza = 'A'	
	   AND num_credito = pnum_credito;
	   
	---ADLM PP FLEX
	-- COMISIONES
	IF cNumProducto ='6800' THEN
		SELECT sum(monto) 
			INTO v_comisiones
		FROM   	sd_movhisedoctacrd
		WHERE  	empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun = '339' AND codigo_ref IN (50,51,96);
		--AND num_producto= cNumProducto;

		SELECT sum(monto)
			INTO v_iva_comisiones
		FROM   	sd_movhisedoctacrd
		WHERE  	empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun = '340' AND codigo_ref IN (1,2,27);
		--AND num_producto= cNumProducto;
	END IF
	---ADLM PP FLEX
	   
	--- OBTIENE VALORES PARA CFDI 4.0
	select trim(valor) INTO cIVA_cfdi
	FROM "informix".sd_param WHERE cod_param = '143';
	
	--  ********************** 31/01/2025
	SELECT monto INTO vIvaInteresesReales FROM "informix".sd_movhisedoctacrd 
	WHERE fecha_mov = pfechahoy AND num_credito = pnum_credito 
	AND codigo_fun = '222' AND codigo_ref = '44';
	--  ********************** 31/01/2025
	
	LET vInteresesReales = (NVL(vIvaInteresesReales,0) / cIVA_cfdi);
	LET vValBase = (NVL(vInteresesReales,0) + NVL(v_comisiones,0));
	
	IF NVL(vValBase,0) = 0 OR NVL(vValBase,0) is null THEN
		LET v_subtotal	= 0.01;
		LET v_descuento = 0.01;
		--LET vIvaCfdi = NVL(vValBase,0) * .16;
		LET v_total = 0.00;
		LET vObjetoImp = '01';
		UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
		WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	ELSE
		IF NVL(vValBase,0) > 0 THEN
			LET v_subtotal	= NVL(vInteresesReales,0) + NVL(v_comisiones,0);
			LET v_descuento = 0.00;
			LET vIvaDeComisiones = NVL(v_iva_comisiones,0) - NVL(v_comisiones,0);
			--LET v_total = (NVL(v_subtotal,0) + NVL(vIvaInteresesReales,0) + NVL(v_iva_comisiones,0)) - NVL(v_descuento,0);
			LET v_total = (NVL(v_subtotal,0) + NVL(vIvaInteresesReales,0) + NVL(vIvaDeComisiones,0)) - NVL(v_descuento,0);
			LET vObjetoImp = '02';
			UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
			WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
		END IF;
	END IF;
	
	LET vIvaCfdi = NVL(vValBase,0) * .16;
	--- FIN CFDI 4.0
	
	-- VALIDA SI TIENE MENOS DE 5 CARACTERES EL CODIGO POSTAL
	IF LENGTH(v_cod_postal) < 5 THEN
		LET v_cod_postal = LPAD(v_cod_postal,6,0);
	END IF;

     INSERT INTO "informix".sd_encabezado_edoctacrd
     				(
                    fecha_emision,       num_credito,
					num_cta_efec,        num_producto,
                    numcte,              nombre_cte,
                    direccion_cn,        direccion_col,
                    direccion_del,       edo_cd,
                    cl_cobra,            sucursal_numero,
                    sucursal_nombre,     sucursal_gerente,
                    rfc,                 sucursal_tel,
                    cp,                  ruta,
                    entre_calles,        observaciones,
                    insertos,			 confirmacion,
					nombre_producto,	 ind_tabla_amortizacion,
					num_region,			 num_ciudad_banco,
					num_ciudad_coppel,	 obj_imp,
					base_cfdi
					)
	  		 VALUES(
	  		       	pfechahoy,				            TRIM(pnum_credito),
					NVL(cCuentaEfec,''),				cNumProducto,
                    NVL(TRIM(v_numcte),''),				NVL(TRIM(v_nombre_cte),''),
                    NVL(TRIM(v_direccion_cn),''),      	NVL(TRIM(v_direccion_col),''),
                    NVL(TRIM(v_direccion_del),''),     	NVL(TRIM(v_edo_cd),''),
                    NVL(TRIM(v_cl_cobra),''),           NVL(TRIM(v_sucursal),''),
                    NVL(TRIM(v_sucursal_nombre),''),   	NVL(TRIM(v_sucursal_gerente),''),
                    NVL(TRIM(v_rfc),''),                NVL(TRIM(v_sucursal_tel),''),
                    NVL(TRIM(v_cod_postal),''),         NVL(TRIM(v_ruta),''),
                    NVL(TRIM(v_entre_calles),''),       NVL(TRIM(v_observaciones),''),
                    cInserto,							NVL(TRIM(v_confirmacion),''),
					cNomProducto ,						cInd_tabla_amortizacion,
					NVL(sNumRegion,''),					NVL(sNumCiudadB,''),
					NVL(sNumCiudadC,''),				NVL(vObjetoImp,''),
					NVL(vValBase,0)
				    );
					
					IF NVL(TRIM(v_ruta),'') = '' OR v_ruta is null THEN
						UPDATE "informix".sd_encabezado_edoctacrd SET num_region = '00' WHERE num_credito = pnum_credito AND ruta = '';
					END IF;

  --     PERIODO ANTERIOR     --

  IF cNumProducto = '6400' THEN
      SELECT tp_dias_fecha_pago
        INTO iTpDiasFechaPago
        FROM bdicred:"informix".sd_maecredanexocrd
       WHERE empresa = pempresa
         AND num_credito = pnum_credito;

         IF  iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN

             IF ( DAY(pfechahoy) <= 15) then
                SELECT  sdodiafac
                  INTO iDiaCorte
                  FROM "informix".sd_diafactura
                 WHERE empresa = pempresa
                   AND num_producto = cNumProducto
                   AND perdiafac = DAY(pfechahoy)
                   AND tipo_pago = iTpDiasFechaPago
                   AND fac_especial = 'N';
             ELSE
                SELECT  perdiafac
                  INTO iDiaCorte
                  FROM "informix".sd_diafactura
                 WHERE empresa = pempresa
                   AND num_producto = cNumProducto
                   AND sdodiafac = DAY(pfechahoy)
                   AND tipo_pago = iTpDiasFechaPago
                   AND fac_especial = 'S';
             END IF;
          END IF;

             CALL "informix".calculamesiversario(iDiaCorte, pfechahoy, 1, 2)
                  RETURNING cCodRet, dtFechaProxCuota; 

              IF DAY(iDiaCorte) = 15 THEN
                    LET v_periodo_anterior = mdy(MONTH(pfechahoy),iDiaCorte,YEAR(pfechahoy));
              ELIF DAY(iDiaCorte) IN (30,31)  THEN
                 LET v_periodo_anterior = MONTH(dtFechaProxCuota) ||"/01/"|| YEAR(dtFechaProxCuota);
                 LET v_periodo_anterior = v_periodo_anterior - 1 UNITS DAY;
              ELSE
                 LET v_periodo_anterior = monthadd(dtFechaProxCuota, -1);
              END IF;
     END IF;


            EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,-1,DAY(pfechahoy))
                         INTO v_cod_ret_otro, v_periodo_anterior, v_dias_periodo_tc;

            IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
              LET cod_ret = v_cod_ret_otro;
            END IF;
			
            LET cod_ret = '000000';

            LET v_dias_periodo_tc = (v_dias_periodo_tc * -1);

    --     OBTENGO EL PERIODO INICIAL, FINAL, DIAS DEL PERIODO Y FECHA DE CORTE      --

    LET v_periodo_tc_ini = v_periodo_anterior + 1;
	LET v_periodo_tc_fin = pfechahoy;
    LET v_fecha_corte_tc = pfechahoy;


	--     SE DEFINE EL MONTO DEL PROXIMO PAGO     --

	SELECT a.valor
	  INTO iDiasCalc
	  FROM "informix".sd_param a
	 WHERE a.cod_param = "24";

	IF iDiasCalc IS NULL THEN
		LET iDiasCalc = 0;
	END IF;

    IF  iTpDiasFechaPago = 2  AND cNumProducto = '6400' THEN
      LET vlFechaCutoa =  date(dtFechaProxCuota);
    ELSE
      LET vlFechaCutoa = date(monthadd(pfechahoy, + 1));
    END IF;

	SELECT num_pago,
		   capital_mto_cuota
	  INTO v_num_pago,
		   v_cap_mto_cuota
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa     = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota = vlFechaCutoa;

	IF v_num_pago = 0 THEN
	  LET v_num_pago_c = "-";
	ELSE
	  LET v_num_pago_c = nvl(v_num_pago,0)||"/"||v_plazo; 
	END IF;

	
    --     OBTENEMOS EL INTERES VIGENTE     --

	SELECT sum(interes_debe - interes_pagado),
			sum(iva_debe - iva_pagado)
	  INTO v_interes_vigente,
		   v_iva_vigente
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa     = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota = pfechahoy;
	
    
    --     SE OBTINE EL CAPITAL, INTERES, IVA VENCIDOS, MORATORIOS E IVA MORATORIOS,USTED DEBE    --

	SELECT NVL(SUM(a.tasa_interes),0),  --dTasaInter
		   NVL(SUM(b.sdo_capital),0),  ---dSdoCapital
		   NVL(SUM(b.cap_tras_no_venci),0), --dCapTrasNoVen
		   NVL(SUM(monto_vencido + mto_venc_trasp),0), --v_capital_vencido
		   NVL(SUM(sdo_no_exig + int_tra_no_exig ),0),--v_interes_vencido
		   NVL(SUM(mto_venc_int + mto_finan_vdo),0), --v_iva_vencido
		   NVL(SUM(sdo_moratorio + sdo_contab_mora),0), --v_moratorio
		   NVL(SUM(monto_otorgado),0), --v_monto_otorgado
  		   NVL(SUM(sdo_cap_insoluto+sdo_no_exig+int_tra_no_exig+mto_finan_vdo+mto_venc_int+sdo_retenido ),0) --v_usted_debe_tc
	  INTO dTasaInter,
		   dSdoCapital,
		   dCapTrasNoVen,
		   v_capital_vencido,
		   v_interes_vencido,
		   v_iva_vencido,
		   v_moratorio,
		   v_monto_otorgado,
		   v_usted_debe_tc
	  FROM sd_maecredcrd a, sd_maesdoshistcrd b
	 WHERE b.fecha = pfechahoy
	   AND a.empresa       = b.empresa
	   AND a.empresa       = pempresa
	   AND a.num_credito   = pnum_credito
	   AND a.num_credito   = b.num_credito;
	   
	   
	IF v_monto_otorgado IS NULL THEN
		LET v_monto_otorgado = 0;
	END IF;

    IF v_interes_vencido <> 0 AND cNumProducto <> '6400' THEN
		LET  v_interes_vencido = round((v_interes_vencido - nvl(v_interes_vigente,0)),2);
    END IF

    IF v_iva_vencido <> 0 AND cNumProducto <> '6400' THEN
	  LET v_iva_vencido = ROUND((v_iva_vencido - nvl(v_iva_vigente,0)),2);
    END IF

    IF v_moratorio <> 0 then
	   LET v_iva_moratorio = ROUND((v_moratorio * 0.16),2);
    END IF
	   
    --CALCULO DE DIAS PARA INTERESES DEL PROXIMO PERIODO

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,1,DAY(pfechahoy))
		         INTO v_cod_ret_otro, v_periodo_prox, v_dias_periodo_prox;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
	  LET cod_ret = v_cod_ret_otro;
	END IF;
	
    LET cod_ret = '000000';

    IF iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN
        LET v_dias_periodo_prox = 0;
        LET v_dias_periodo_prox = DAY(pfechahoy) - DAY(dtFechaProxCuota);
        IF v_dias_periodo_prox < 0 THEN
            LET v_dias_periodo_prox = v_dias_periodo_prox * -1;
        END IF;
    END IF;

    LET dSdo = dSdoCapital + dCapTrasNoVen;
    LET v_interes_debe = round((round((dSdo * dTasaInter / (iDiasCalc * 100)),2) * v_dias_periodo_prox),2);
    LET v_iva_debe = round((v_interes_debe * v_iva_suc),2);
    LET v_capital_debe = round((v_cap_mto_cuota - v_interes_debe - v_iva_debe),2);

	IF (v_capital_debe is  null) THEN
		LET v_num_pago = 0;
		let v_cap_mto_cuota = 0;
		let v_capital_debe = 0;
		let v_interes_debe = 0;
		let v_iva_debe = 0;
	END IF;


	LET v_pagototal     = NVL(v_capital_vencido,0) +
						 NVL(v_interes_vencido,0) +
						 NVL(v_iva_vencido,0) +
						 NVL(v_capital_debe,0) +
						 NVL(v_interes_debe,0) +
						 NVL(v_iva_debe,0) +
						 NVL(v_moratorio,0) +
						 NVL(v_iva_moratorio,0);


	LET v_pago_minimo_tc = v_pagototal;

	IF nvl(v_capital_vencido,0) > 0 THEN
	   LET v_fecha_limite_pago_tc = DATE(1);
	ELSE
	    IF iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN
			LET v_fecha_limite_pago_tc = dtFechaProxCuota;
	  ELSE
			LET v_fecha_limite_pago_tc = date(monthadd(pfechahoy, + 1));
		END IF;
    END IF;


	SELECT COUNT(empresa)
	  INTO v_cuantos_avisos
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa = pempresa
	   AND num_credito = pnum_credito
	   AND capital_status IN ("2","7","6");

--- RQI 12 297: CFDI 3.3 --- 	
--- Campos descuento y subtotal
	/*if NVL(v_iva_debe,0) > 0 then
		--LET v_descuento = 0.00;
		LET v_subtotal  = NVL(v_interes_debe,0);
	else 	
		--LET v_descuento	= 0.01;
		LET v_subtotal  = 0.01;
	end if
		
	LET v_total = NVL(v_interes_debe,0) + NVL(v_iva_debe,0); */
--- RQI 12 297: CFDI 3.3 --- 	   

-- VALOR DE IVA REAL SOBRE LA BASE DE CFDI
LET vIvaCfdi = NVL(vValBase,0) * .16;

IF cNumProducto = '6800' THEN
    INSERT INTO "informix".sd_encabezado2_edoctacrd
				(
                fecha_emision,              num_credito,
                capital_tc,                 interes_tc,
                iva_interes_tc,             numero_pago_tc,
                monto_pago,                 capital_ven_tc,
                interes_ven_tc,             iva_interes_ven_tc,
                moratorios_tc,              iva_moratorios_tc,
                pago_total_tc,              fecha_limite_tc,
                periodo_tc_ini,             periodo_tc_fin,
                fecha_corte_tc,             dias_periodo_tc,
                monto_credito_tc,           fecha_otorgamiento_tc,
                intereses_efec_pag,         comisiones_efec_cargadas,
				descuento,					subtotal,					
				total,						comisiones, 
				iva_comisiones,				linea_autorizada,		  
				fecha_ult_disposicion,		val_base_cfdi,
				iva_intereses_reales_cfdi,	intereses_reales_cfdi,
				iva_cfdi
				)
		VALUES (
				pfechahoy,					      TRIM(pnum_credito),
				NVL(v_capital_debe,0),		      NVL(v_interes_debe,0),
				NVL(v_iva_debe,0),	              NVL(v_num_pago_c,'0'),
                NVL(v_cap_mto_cuota,0),           NVL(v_capital_vencido,0),
                NVL(v_interes_vencido,0),         NVL(v_iva_vencido,0),
                NVL(v_moratorio,0),               NVL(v_iva_moratorio,0),
                NVL(v_pagototal,0),               NVL(v_fecha_limite_pago_tc,DATE(1)),
                v_periodo_tc_ini,                 v_periodo_tc_fin,
                NVL(v_fecha_corte_tc,DATE(1)),    NVL(v_dias_periodo_tc,''),
                NVL(v_monto_otorgado,0),          NVL(dFecha_otorga_dig,DATE(1)),
                0,                                0,
				NVL(v_descuento,0), 			  NVL(v_subtotal,0), 			
				NVL(v_total,0),					  NVL(v_comisiones,0), 
				NVL(v_iva_comisiones,0),		  NVL(v_monto_linea_dig,0),
				NVL(v_fecha_apertura,DATE(1)),	  NVL(vValBase,0),
				NVL(vIvaInteresesReales,0),		  NVL(vInteresesReales,0),
				NVL(vIvaCfdi,0)
				);
ELSE

 INSERT INTO "informix".sd_encabezado2_edoctacrd
				(
                fecha_emision,              num_credito,
                capital_tc,                 interes_tc,
                iva_interes_tc,             numero_pago_tc,
                monto_pago,                 capital_ven_tc,
                interes_ven_tc,             iva_interes_ven_tc,
                moratorios_tc,              iva_moratorios_tc,
                pago_total_tc,              fecha_limite_tc,
                periodo_tc_ini,             periodo_tc_fin,
                fecha_corte_tc,             dias_periodo_tc,
                monto_credito_tc,           fecha_otorgamiento_tc,
                intereses_efec_pag,         comisiones_efec_cargadas,
				descuento,					subtotal,					
				total,						comisiones, 
				iva_comisiones,				linea_autorizada,		  
				fecha_ult_disposicion,		val_base_cfdi,
				iva_intereses_reales_cfdi,	intereses_reales_cfdi,
				iva_cfdi
				)
		VALUES (
				pfechahoy,					      TRIM(pnum_credito),
				NVL(v_capital_debe,0),		      NVL(v_interes_debe,0),
				NVL(v_iva_debe,0),	              NVL(v_num_pago_c,'0'),
                NVL(v_cap_mto_cuota,0),           NVL(v_capital_vencido,0),
                NVL(v_interes_vencido,0),         NVL(v_iva_vencido,0),
                NVL(v_moratorio,0),               NVL(v_iva_moratorio,0),
                NVL(v_pagototal,0),               NVL(v_fecha_limite_pago_tc,DATE(1)),
                v_periodo_tc_ini,                 v_periodo_tc_fin,
                NVL(v_fecha_corte_tc,DATE(1)),    NVL(v_dias_periodo_tc,''),
                NVL(v_monto_otorgado,0),          NVL(v_fecha_apertura,DATE(1)),
                0,                                0,
				NVL(v_descuento,0), 			  NVL(v_subtotal,0), 			
				NVL(v_total,0),					  NVL(v_comisiones,0), 
				NVL(v_iva_comisiones,0),		  NVL(v_monto_linea,0),
				NVL(v_fecha_apertura,DATE(1)),	  NVL(vValBase,0),
				NVL(vIvaInteresesReales,0),		  NVL(vInteresesReales,0),
				NVL(vIvaCfdi,0)
				);
 
 END IF;
	--     USTED DEBIA     --

	SELECT nvl(saldo_insoluto,0)
	  INTO v_usted_debia
	  FROM "informix".sd_pie_edoctacrd
    WHERE fecha_emision = date(monthadd(pfechahoy, - 1))
	AND num_credito = pnum_credito;

	IF v_usted_debia IS NULL OR v_usted_debia = '' THEN

	   LET v_usted_debia = 0;
		SELECT NVL(SUM(sdo_cap_insoluto+sdo_no_exig + int_tra_no_exig+mto_finan_vdo+mto_venc_int),0)
		  INTO v_usted_debia
		  FROM bdicred:sd_maesdoshistcrd
         WHERE fecha = date(monthadd(pfechahoy, - 1))
		   AND empresa = pempresa
		   AND num_credito = pnum_credito;
	END IF;

    LET v_maximo = 1;

    --      GENERA USTED DEBIA     --

	INSERT INTO sd_detalle_edoctacrd
			(
			fecha_emision,		num_credito,
			secuencia,			nlinea,
			fecha_mov,			concepto,
			cargos,				abonos

		    )
		VALUES(
			pfechahoy,			pnum_credito,
			v_maximo,			1,
			DATE(1),     	    "USTED DEBIA",
			NVL(v_usted_debia,0), NVL(v_abonos,0)
		    );

    -- GENERO LOS MOVIMIENTOS DEL ESTADO DE CUENTA

--***************************INICIO MENSUALES************************************
               FOREACH  SELECT lpad(month(a.fecha_mov),2,0)||'-'||
               lpad(day(a.fecha_mov),2,0)||'-'||
               lpad(year(a.fecha_mov),4,0), a.secuencia,transacc_suc,a.folio_suc,a.referencia,a.descripcion,a.monto,a.naturaleza,a.codigo_ref,a.codigo_fun
                INTO v_fecha_mov_aux,v_serial,v_transacc,v_folio,v_concepto,v_descripcion_det,v_monto_det,v_naturaleza,v_cod_ref,v_cod_fun
                   FROM bdicred:sd_movhisedoctacrd  a
                   WHERE  a.empresa = '001'
                     AND a.num_credito = pnum_credito
                     AND a.reversado = "N"
                     AND a.referencia <> 'PROV'
                ORDER BY fecha_mov,secuencia,folio_suc, a.codigo_ref

                                LET v_contador = v_contador + 3;

                                IF v_naturaleza = "A" THEN
                                    LET v_abonos = v_monto_det;
                                    LET v_cargos = 0;
                                ELSE
                                    LET v_cargos = v_monto_det;
                                    LET v_abonos = 0;
                                END IF

                                IF  ((v_transacc in ('8205')) AND (v_cod_ref = 1)) THEN  
									LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 6))||" Abono por remesa de BTS";
																
								ELIF  ((v_transacc in ('8286')) AND (v_cod_ref = 1)) THEN  
									LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 5))||" Abono por remesa de Appriza";

								ELIF v_cod_fun in ("020","021","022","023","024","025","027") AND v_cod_ref = 1 THEN
                                   LET v_descripcion_det = "";
                                   LET v_descripcion_det = TRIM(v_concepto) || " " || v_abonos;
                                   LET  v_cargos = 0;
                                   LET  v_abonos = 0;

                                ELIF v_cod_fun = "002" AND v_cod_ref = 66 THEN
                                     IF cNumProducto = '6400' THEN
                                        LET v_descripcion_det = "DISPOSICION DE LINEA CREDINOMINA";
                                     ELSE
                                        LET v_descripcion_det = Trim(v_descripcion_det);
                                     END IF;
                                ELIF v_cod_ref in (43,44) THEN

                                ELIF v_cod_fun in ('023') AND v_cod_ref in (2,3) THEN
                                     LET v_fecha_mora = v_fecha_mov_aux;
                                     LET v_fecha_mov_aux = DATE(1);

                                ELIF v_cod_fun in ('028') AND v_cod_ref in (1) THEN

                                     LET v_descripcion_det = TRIM("PAGO ANT.") || " " || v_abonos;
                                     LET  v_cargos = 0;
                                     LET  v_abonos = 0;
									 
                                ELIF v_cod_fun in ('222') AND v_cod_ref in (50,51) THEN
								
									UPDATE sd_detalle_edoctacrd SET cargos = cargos -  v_cargos
									WHERE fecha_emision = pfechahoy AND num_credito =  pnum_credito 
										AND secuencia = 1 AND nlinea = 1;
										
                                     LET v_descripcion_det = Trim(v_descripcion_det) || " "||v_cargos;
									 LET v_cargos = 0;
									 
								ELIF v_cod_fun in ('222') AND v_cod_ref in (48,49) THEN
								
									UPDATE sd_detalle_edoctacrd SET cargos = cargos -  v_cargos
									WHERE fecha_emision = pfechahoy AND num_credito =  pnum_credito 
										AND secuencia = 1 AND nlinea = 1;
								
									LET v_descripcion_det = Trim(v_descripcion_det);
                                ELSE
                                   LET v_fecha_mov_aux = DATE(1);
                                   LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
                                END IF

                                IF v_cod_fun = '222' and v_cod_ref = 43 then
                                    let v_inter_efect_pagados =  v_cargos;
                                ELIF v_cod_fun = '020' and v_cod_ref = 17 then
                                    let v_comisiones_efec_pag = v_cargos;
                                END IF;

                                IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                                    LET v_contador = v_contador + 1;
                                ELSE
                                    LET v_maximo = v_maximo + 3;
                                    LET v_contador = 0;
                                    LET v_contador = v_contador + 1;
                                END IF;
								
                                     INSERT INTO sd_detalle_edoctacrd
                                        (
                                        fecha_emision,		num_credito,
                                        secuencia,			nlinea,
                                        fecha_mov,          concepto,
                                        cargos,             abonos
                                        )
                                    VALUES(
                                        pfechahoy,			pnum_credito,
                                        v_maximo,			v_contador,
                                        v_fecha_mov_aux,    Trim(v_descripcion_det),
                                        v_cargos,           v_abonos
                                        );

                        LET v_fecha_mov_aux  = date(1);
                        LET v_concepto       = "";
                        LET v_cargos         = 0;
                        LET v_abonos         = 0;

               END FOREACH;

    LET v_fecha_ultimo_pago = v_fecha_ultimo_pago_aux;

    IF v_inter_efect_pagados <> 0 THEN
        UPDATE bdicred:sd_encabezado2_edoctacrd 
		   SET intereses_efec_pag = v_inter_efect_pagados
         WHERE fecha_emision = pfechahoy  and num_credito = pnum_credito;
     END IF;

    IF v_comisiones_efec_pag <> 0 THEN
        UPDATE bdicred:sd_encabezado2_edoctacrd 
	  	   SET comisiones_efec_cargadas = v_comisiones_efec_pag
         WHERE fecha_emision = pfechahoy and num_credito = pnum_credito;
    END IF;

    Let v_inter_efect_pagados = 0;
    let v_comisiones_efec_pag = 0;

    --     USTED DEBE      --

        LET v_contador = 1;
        LET v_maximo = v_maximo + 1 ;

        INSERT INTO sd_detalle_edoctacrd
            (
            fecha_emision,		num_credito,
            secuencia,			nlinea,
            fecha_mov,          concepto,
            cargos,             abonos
            )
        VALUES
            (
            pfechahoy,			     pnum_credito,
            v_maximo,			     v_contador,
            DATE(1),                 "USTED DEBE",
            NVL(v_usted_debe_tc,0),  v_abonos
            );

	--##	GENERACION ACLARACIONES	 EDO CUENTA	REESTRUCTURA     INI ##
	--##	GENERACION ACLARACIONES	 EDO CUENTA	REESTRUCTURA     FIN ##
	
	--##	GENERACION MENSAJES	 EDO CUENTA	REESTRUCTURA          ##

 	 LET v_secuencia_mensaje  = 0 ;
     LET v_si_paga = v_usted_debe_tc;
		

    INSERT INTO "informix".sd_mensajes_edoctacrd
                (
                fecha_emision, 		num_credito,
                num_producto,         secuencia,
				nlinea,                 si_paga,
				mensajes
                )
				SELECT pfechahoy, TRIM(pnum_credito),
                      cNumProducto,clave, secuencia,
                      '',
                      REPLACE(mensaje,v_linea_auxiliar, TRIM(v_aplica_factor::VARCHAR(21)))
                 FROM mensajes
				 WHERE num_producto = cNumProducto;



	--##	GENERACION   PIE	 EDO CUENTA	 REESTRUCTURA         ##

   	LET v_tasa_mensual      = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = v_tasa_mora / 12;


	IF v_tasa_mora < 0 THEN
		LET v_tasa_mora=0;
		LET v_tasa_mensual_mora=0;
	END IF        

    --     GENERA EL PIE DEL ESTADO DE CUENTA REESTRUCTURA      --

	INSERT INTO "informix".sd_pie_edoctacrd
			(
			fecha_emision,			num_credito,
            tasa_anual,             tasa_mensual,
			tasa_mora_anual,        tasa_mora_mensual,
			cat,					saldo_insoluto
			)
	VALUES
			(
			pfechahoy,				TRIM(pnum_credito),
			NVL(v_tasa_anual,0),	NVL(v_tasa_mensual,0),
            NVL(v_tasa_mora,0),     NVL(v_tasa_mensual_mora,0),
			NVL(v_cat,0),			NVL(v_usted_debe_tc,0)
			);

	--     GENERACION  CLAVE DE COBRANZA REESTRUCTURA     --
    --	         1.--TIPO DE CLIENTE: (2 Numero)
    --	         2.--SITUACION ESPECIAL: (1 letra)

    SELECT FIRST 1 situacion, causa
      INTO v_situacion, v_situacion_esp
      FROM bdinteg:si_ctessitesp
     WHERE numcliente = v_numcte;

    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF

    --     2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087     --

    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "000";
    END IF

	LET v_situacion_esp= lpad( TRIM(v_situacion_esp), 3,'0');

    --     3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Anio Nacimiento (2 Numeros)     --

	SELECT TRIM(NVL(estado_civil,'')),
		   TRIM(NVL(SUBSTR(habita_en, 1,1),'P')),
		   TRIM(NVL(sexo,'')),
		   NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	  INTO v_estado_civil,
		   v_tp_casa,
		   v_sexo,
		   v_nacimiento
      FROM bdinteg:si_ctepf
	 WHERE numcte = v_numcte;

    --     6.--SALARIO MINIMO COPPEL:     --

       SELECT valor
         INTO v_SalarioMinimoCoppel
         FROM bdisolic:ss_param
        WHERE empresa = pempresa
          AND secuencia = 303;

          IF v_SalarioMinimoCoppel IS NULL THEN
             LET v_SalarioMinimoCoppel = 0;
          END IF;

	SELECT NVL(ingreso_mensual,0) / v_SalarioMinimoCoppel
	  INTO v_salario
	  FROM bdisolic:"informix".ss_resum_scor_fin
	 WHERE empresa = pempresa
	   AND num_solicitud = pnum_credito;


	IF v_salario <= 0  OR v_salario IS NULL THEN
	  	IF cod_ret = "000000" THEN
	  		LET cod_ret = "211";
	  	END IF
	ELSE
		IF v_salario >= 22 THEN
			LET v_cantidad = LPAD(22,2,'0');
		ELSE
			LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
		END IF
	END IF

    --     7.-ANTIGUEDAD: (2 NUMEROS)     --

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF

    --     9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)     --

	IF v_pagototal >= 100000 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_pagototal < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(ROUND(v_usted_debe_tc),5,'0');
		END IF

	END IF

    --     10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)     --

	IF v_mto_adeudo_venc >= 100000 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "214";
  		END IF
	ELSE
        LET v_mto_adeudo_venc = v_monto_financiado; -- Solictado 20 Nov 2008 MEL
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF

    --     11.-FECHA DE ULT. PAGO: (4 NUMEROS)     --

	IF v_fecha_ultimo_pago IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago_month = MONTH(v_fecha_ultimo_pago);
		LET v_fec_ult_pago_year =  SUBSTR(YEAR(v_fecha_ultimo_pago),3,2);
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF

    --     12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)     --

    FOREACH
       SELECT FIRST 1 importe, TO_CHAR(fecha_compac,"%m%y")
	     INTO v_monto_ult_convenio , v_fecha_ult_convenio
	     FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa
	      AND numcliente = v_numcte
     ORDER BY fecha_compac DESC
         EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
		LET v_monto_ult_convenio =  LPAD("0",5,'0');
	END IF

    --     13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)     --

    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
		LET v_fecha_ult_convenio =  "NDND";
	END IF

    --      14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)     --

    FOREACH
      SELECT FIRST 1 'P'
	    INTO v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac
	   WHERE empresa = pempresa
	     AND numcliente = v_numcte
	     AND fecha_compac >= v_periodo_tc_ini
	     AND fecha_compac <= v_periodo_tc_fin
	ORDER BY fecha_compac DESC
       	EXIT FOREACH;
    END FOREACH;

    IF v_est_cumpl_convenio IS NULL OR v_est_cumpl_convenio = "" THEN
		LET v_est_cumpl_convenio =  "-";
	END IF

    --     15.-NUMERO DE AVISOS: (1 LETRA)     --

	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos = 5 THEN
		LET v_avisos =  "4";
	ELIF v_cuantos_avisos >= 6 THEN
		LET v_avisos =  "V";
	END IF;

	IF v_cuantos_avisos = 0 OR v_cuantos_avisos = 1 OR v_cuantos_avisos = 2 THEN
		LET v_nivel_eficiencia = "1";
    ELIF v_cuantos_avisos = 3 THEN
		LET v_nivel_eficiencia = "2";
	ELIF v_cuantos_avisos = 4 THEN
		LET v_nivel_eficiencia = "3";
    ELIF v_cuantos_avisos = 5 OR v_cuantos_avisos = 6 THEN
		LET v_nivel_eficiencia = "4";
	ELIF v_cuantos_avisos > 6 THEN
		LET v_nivel_eficiencia = "5";
	END IF;

	--      Modifico para Clave de Cobranza ----- RQM 09 117      --

	LET posicion11= ROUND(v_pago_minimo_tc - v_capital_tc);
	LET posicion11= LPAD(TRIM(posicion11), 5,'0');

	--- Inicio (Inc. 20 Marzo 2009)
	LET v_monto_ult_convenio= ROUND(v_monto_ult_convenio);
	LET v_monto_ult_convenio= LPAD(TRIM(v_monto_ult_convenio), 5,'0');
	--- Fin

	LET posicion17= ROUND(v_pago_minimo_tc);
	LET posicion17= LPAD( TRIM(posicion17), 5,'0');

    --      ARMO LA CLAVE DE COBRANZA PRESTAMO :      --
	
	--DIA LIMITE DE PAGO --SD_MAECREDANEXOCRD
	SELECT  prox_fecha_pago
      INTO  v_fecha_limite_pago_pp
	  FROM "informix".sd_maecredanexocrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;

	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = SUBSTRING(TO_CHAR(v_fecha_limite_pago_pp, "%y-%m-%d") FROM 7 FOR 2)	||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;

	LET v_cl_cobranza = cIniClvCob || v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;

    --     EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA PRESTAMO     --

	UPDATE bdicred:"informix".sd_encabezado_edoctacrd
       SET cl_cobra = trim(v_cl_cobranza)
	 WHERE fecha_emision = pfechahoy
	   AND num_credito = pnum_credito;


   RETURN cod_ret;

END
END PROCEDURE
DOCUMENT
'Se crea procedimiento para obtener',
'la informacion para la generacion de los',
'estados de cuenta para creditos reestructurados, su',
'clave de cobranza y ruta correspondiente',
'base de datos : bdicred',
'AUTOR : Bernardo Baez',
'FECHA : 23/Julio/2009';

CREATE PROCEDURE "informix".sp_carga_pre_aprobados()
	RETURNING CHAR(5)   AS codRet,
              CHAR(500) AS mensaje,
              CHAR(2)   AS idProceso;


	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
    DEFINE vMensaje CHAR (500);
    DEFINE vSql CHAR(500);
    DEFINE vIdProceso CHAR(2);
    DEFINE vConsecutivoCte INTEGER;
    DEFINE vtransaccion SMALLINT;
    DEFINE cRutaCarga CHAR(500);
    DEFINE cRutaDescarga CHAR(500);
    DEFINE cArchivoRespaldo CHAR(500);
    DEFINE cArchivoPreAp CHAR(500);
    DEFINE cRutaIfx CHAR(500);
    --DEFINE vCuentaTrx INTEGER;
	DEFINE vCuentaTrx CHAR(10);
	DEFINE cProductosOC CHAR(80);

	--SET DEBUG FILE TO "/informix/mc/Fernandorb/carga_unificada.out";
	--TRACE ON;

    LET iSqlErr ='0';
    LET vCodRet ='00000';
    LET vMensaje ='CARGA EXITOSA';
    LET vSql ='';
    LET vIdProceso ='00';
    LET vConsecutivoCte = 0;
    LET vtransaccion = 0;
    LET cRutaCarga = '';
    LET cRutaDescarga = '';
    LET cArchivoRespaldo = 'resp_migra_preaprob.unl';
    LET cArchivoPreAp = '';
    LET cRutaIfx = '';
    --LET vCuentaTrx = 0;
	LET vCuentaTrx = '';
	LET cProductosOC = '';

	SELECT TRIM(valor) INTO cRutaCarga    FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
	SELECT TRIM(valor) INTO cRutaIfx      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
    SELECT TRIM(valor) INTO cRutaDescarga FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 8;
    SELECT TRIM(valor) || LPAD(MONTH(TODAY),2,0) || '-' || SUBSTR(YEAR(TODAY),3,2)|| '.txt' INTO cArchivoPreAp
	                                      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 6;
	SELECT TRIM(valor) INTO cProductosOC  FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 16;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = '10000';
				LET vMensaje = 'ERROR AL CARGAR ARCHIVO: ' || iSqlErr;

				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
				END IF;

				IF iSqlErr ='-668' THEN
					IF vIdProceso = '07' THEN
						LET vCodRet = '66802';
					END IF;

					IF vIdProceso = '00' THEN
						LET vSql = '';
						LET vSql = 'rm -rf ' || TRIM(cRutaCarga) ||'_'||TRIM(cArchivoPreAp);
						SYSTEM vSql;

						LET vMensaje = 'Archivo no localizado: ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp);
						LET vCodRet = '66800';
					END IF;
				END IF;

				RETURN vCodRet, vMensaje, vIdProceso;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA EXISTENCIA DEL ARCHIVO ANTES DE INICIAR CON EL PROCESO DE CARGA
		 --SYSTEM "sed 's/.$//' " || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || " > " || TRIM(cRutaCarga) ||'_'|| TRIM(cArchivoPreAp);

		--SI EL ARCHIVO YA ESTA CARGADO BORRA TODO EL CONTENIDO DE TRX SIN MIGRAR A HISTORICO

		--MIGRA DATOS HISTORICOS
		LET vIdProceso = '001';
		--LET vCuentaTrx = (SELECT COUNT(*) FROM bdicred:sd_pre_aprobados_trx);
		LET vCuentaTrx = (SELECT LIMIT 1 numcte FROM bdicred:sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN ('-'));

		IF vCuentaTrx <> '' THEN
			--DESCARGA EL RESPALDO
			LET vIdProceso = '011';
			LET vSql = '';
			LET vSql = 'echo "UNLOAD TO ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) ||' DELIMITER ' || '''|''' || ' SELECT * FROM "informix".sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN (' || '''-''' || ')"  >> ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '012';
			LET vSql = '';
			LET vSql = 'dbaccess bdicred ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '013';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '014';
			--CARGA RESPALDO EN TABLA HISTORICA
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo);
			SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_his;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "dbload -d bdicred -c '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.log' ||' -e 1000  -n 1000 -r'||
			TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			system ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			LET vIdProceso = '015';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.cmd';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '016';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.sh';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '017';
			LET vIdProceso = '02';
		END IF;

		TRUNCATE TABLE  "informix".sd_pre_aprobados_trx DROP STORAGE;
		SET ISOLATION TO DIRTY READ;

		LET vIdProceso = '03';

		--CARGA ARCHIVO LAYOUT
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoPreAp);
		SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoPreAp)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoPreAp)||'.cmd';
		SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_trx;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		--SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM ' chmod 777 '  || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';

		LET vIdProceso = '04';

		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN  WORK;
		END IF;

		--BORRA ARCHIVOS TEMPORALES
		LET vIdProceso = '05';

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || '_' || TRIM(cArchivoPreAp);
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sql';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.out';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.cmd';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.log';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sh';
		SYSTEM vSql;

		LET vIdProceso = '06';

		RETURN vCodRet, vMensaje, vIdProceso;
    END;
END PROCEDURE;
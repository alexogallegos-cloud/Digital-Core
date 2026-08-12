CREATE PROCEDURE "informix".sp_grabarcargosmanuales
(
	p_Empresa					CHAR(3),
	p_Usuario					CHAR(8),
	p_FolioSuc					CHAR(16),
	p_NumCte					CHAR(20),
	p_NumCredito				CHAR(20),
	p_ImporteCargo 				MONEY(18,2),
	p_Transaccion				CHAR(4),
	p_Concepto					CHAR(20),
	p_Observaciones				CHAR(200),
	p_CapitalVigente			MONEY(18,2),
	p_CapitalTransitorio		MONEY(18,2),
	p_CapitalVencido			MONEY(18,2),
	p_CapitalVdoNoExigible		MONEY(18,2),
	p_CapitalTotal				MONEY(18,2),
	p_InteresVigente			MONEY(18,2),
	p_IvaInteresVigente			MONEY(18,2),
	p_InteresVencido			MONEY(18,2),
	p_IvaInteresVencido			MONEY(18,2),
	p_InteresMoratorio			MONEY(18,2),
	p_IvaInteresMoratorio		MONEY(18,2),
	p_codigo                    CHAR(2)
)
RETURNING
	CHAR(5) AS COD_RET,
	MONEY(18,2) AS CapitalVigente,
	MONEY(18,2) AS CapitalTransitorio,
	MONEY(18,2) AS CapitalVencido,
	MONEY(18,2) AS CapitalVdoNoExigible,
	MONEY(18,2) AS CapitalTotal,
	MONEY(18,2) AS InteresVigente,
	MONEY(18,2) AS IvaInteresVigente,
	MONEY(18,2) AS InteresVencido,
	MONEY(18,2) AS IvaInteresVencido,
	MONEY(18,2) AS InteresMoratorio,
	MONEY(18,2) AS IvaInteresMoratorio;

---DECLARACIONES
	DEFINE v_cod_ret				 CHAR(5);
	DEFINE iSqlErr					INTEGER;
	DEFINE iSamErr					INTEGER;

	DEFINE s_Sucursal				CHAR(4);
	DEFINE s_NumProducto			CHAR(4);
	DEFINE dFecha_Hoy				DATE;
	DEFINE dFecha_dia               DATE;
	DEFINE dHora                    CHAR(8); 
	DEFINE cFolioCargo              CHAR(16);
	DEFINE iBandera                INTEGER;	
	DEFINE cBanderaReversion       CHAR(1);	

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2);
	DEFINE csg_int_moratorios		MONEY(18,2);
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE csg_iva_int_vdo			MONEY(18,2);
	DEFINE csg_iva_int_moratorios	MONEY(18,2);
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	DEFINE dat_codigo_ret           CHAR(6);
	DEFINE dat_Mensaje_ret          CHAR(80);
	DEFINE dat_Num_Cred             CHAR(20);
	DEFINE dat_Num_Cte              CHAR(20);
	DEFINE dat_Nom_Pdcto            CHAR(40);
	DEFINE dat_Num_Tarjeta          CHAR(20);
	DEFINE dat_Nom_Cte              CHAR(150);
	 
	
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	DEFINE car_Cod_Ret              CHAR(6);
	DEFINE car_Sald_Disp            DECIMAL(14,2);
	DEFINE car_Impor_Cgdo           DECIMAL(14,2);
	DEFINE car_Imp_comi             DECIMAL(14,2);
	DEFINE car_Iva_comi             DECIMAL(14,2);
	
			 
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
	DEFINE csg2_codigo_ret			CHAR(6);
	DEFINE csg2_mensaje_ret			CHAR(80);
	DEFINE csg2_num_credito			CHAR(20);
	DEFINE csg2_cod_tipcred			CHAR(2);
	DEFINE csg2_fec_origen			DATE;
	DEFINE csg2_fec_prox_pago		DATE;
	DEFINE csg2_pago_min			MONEY(18,2);
	DEFINE csg2_fec_ult_pago		DATE;
	DEFINE csg2_plazo				INTEGER;
	DEFINE csg2_pagos_realizados	INTEGER;
	DEFINE csg2_linea_otorgada		MONEY(18,2);
	DEFINE csg2_tasa_interes		DECIMAL(9,6);
	DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg2_monto_sbc			DECIMAL(14,2);
	DEFINE csg2_cap_vig				MONEY(18,2);
	DEFINE csg2_cap_trans			MONEY(18,2);
	DEFINE csg2_cap_vdo_exig		MONEY(18,2);
	DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg2_int_vig				MONEY(18,2);
	DEFINE csg2_int_vdo				MONEY(18,2);
	DEFINE csg2_int_moratorios		MONEY(18,2);
	DEFINE csg2_int_mes				MONEY(18,2);
	DEFINE csg2_sdo_act_total_int	MONEY(18,2);
	DEFINE csg2_iva_int_vig			MONEY(18,2);
	DEFINE csg2_iva_int_vdo			MONEY(18,2);
	DEFINE csg2_iva_int_moratorios	MONEY(18,2);
	DEFINE csg2_iva_int_mes			MONEY(18,2);
	DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg2_com_pend			MONEY(18,2);
	DEFINE csg2_iva_com				MONEY(18,2);
	DEFINE csg2_sdo_retenido		MONEY(18,2);
	DEFINE csg2_tot_liquidacion		MONEY(18,2);
	DEFINE csg2_int_devengado		MONEY(18,2);
	DEFINE csg2_iva_int_devengado	MONEY(18,2);
	DEFINE csg2_linea_disp			MONEY(18,2);
	DEFINE csg2_pagos_vdos			MONEY(18,2);
	DEFINE csg2_desc_status_cred	CHAR(60);
	DEFINE csg2_id_bloqueo_cred		INTEGER;
	DEFINE csg2_bloqueo_cta			CHAR(60);
	DEFINE csg2_id_causa_bloq_cred	CHAR(3);
	DEFINE csg2_causa_bloqueo_cta	CHAR(50);
	DEFINE csg2_id_sit_esp_cte		CHAR(1);
	DEFINE csg2_id_causa_esp_cte	INTEGER;
	DEFINE csg2_sit_esp_cte			CHAR(75);
	DEFINE csg2_id_sit_esp_cred		CHAR(1);
	DEFINE csg2_id_causa_esp_cred	INTEGER;
	DEFINE csg2_sit_esp_cred		CHAR(75);
	DEFINE dMes                     CHAR(2);
	DEFINE dDia                     CHAR(2);	
	---INICIALIZACIONES
	LET v_cod_ret = "00000";
	LET s_Sucursal					= "";
	LET s_NumProducto				= "";
	LET dFecha_Hoy					= MDY(1,1,1900);
	LET dFecha_dia                  = DATE(1);
	LET dHora                       = "";
	LET cFolioCargo					= "";
	LET iBandera                    = 0;		
	LET cBanderaReversion           = "N";		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET csg_fec_origen				= MDY(1,1,1900);
	LET csg_fec_prox_pago			= MDY(1,1,1900);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= MDY(1,1,1900);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	LET dat_codigo_ret           	= "";
	LET dat_Mensaje_ret          	= "";
	LET dat_Num_Cred             	= "";
	LET dat_Num_Cte              	= "";
	LET dat_Nom_Pdcto            	= "";
	LET dat_Num_Tarjeta          	= "";
	LET dat_Nom_Cte              	= "";		
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	LET car_Cod_Ret                 = "";
	LET car_Sald_Disp           	= 0.0;
	LET car_Impor_Cgdo           	= 0.0;
	LET car_Imp_comi             	= 0.0;
	LET car_Iva_comi             	= 0.0;	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
	LET csg2_codigo_ret				= "";
	LET csg2_mensaje_ret			= "";
	LET csg2_num_credito			= "";
	LET csg2_cod_tipcred			= "";
	LET csg2_fec_origen				= MDY(1,1,1900);
	LET csg2_fec_prox_pago			= MDY(1,1,1900);
	LET csg2_pago_min				= 0.0;
	LET csg2_fec_ult_pago			= MDY(1,1,1900);
	LET csg2_plazo					= 0;
	LET csg2_pagos_realizados		= 0;
	LET csg2_linea_otorgada			= 0.0;
	LET csg2_tasa_interes			= 0.0;
	LET csg2_tasa_moratorios		= 0.0;
	LET csg2_monto_sbc				= 0.0;
	LET csg2_cap_vig				= 0.0;
	LET csg2_cap_trans				= 0.0;
	LET csg2_cap_vdo_exig			= 0.0;
	LET csg2_cap_vdo_no_exig		= 0.0;
	LET csg2_sdo_act_total_cap		= 0.0;
	LET csg2_int_vig				= 0.0;
	LET csg2_int_vdo				= 0.0;
	LET csg2_int_moratorios			= 0.0;
	LET csg2_int_mes				= 0.0;
	LET csg2_sdo_act_total_int		= 0.0;
	LET csg2_iva_int_vig			= 0.0;
	LET csg2_iva_int_vdo			= 0.0;
	LET csg2_iva_int_moratorios		= 0.0;
	LET csg2_iva_int_mes			= 0.0;
	LET csg2_sdo_act_total_iva		= 0.0;
	LET csg2_com_pend				= 0.0;
	LET csg2_iva_com				= 0.0;
	LET csg2_sdo_retenido			= 0.0;
	LET csg2_tot_liquidacion		= 0.0;
	LET csg2_int_devengado			= 0.0;
	LET csg2_iva_int_devengado		= 0.0;
	LET csg2_linea_disp				= 0.0;
	LET csg2_pagos_vdos				= 0.0;
	LET csg2_desc_status_cred		= "";
	LET csg2_id_bloqueo_cred		= 0;
	LET csg2_bloqueo_cta			= "";
	LET csg2_id_causa_bloq_cred		= "";
	LET csg2_causa_bloqueo_cta		= "";
	LET csg2_id_sit_esp_cte			= "";
	LET csg2_id_causa_esp_cte		= 0;
	LET csg2_sit_esp_cte			= "";
	LET csg2_id_sit_esp_cred		= "";
	LET csg2_id_causa_esp_cred		= 0;
	LET csg2_sit_esp_cred			= "";
	LET dMes                        = "";
	LET dDia                        = "";
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr
		IF cBanderaReversion ='S' THEN
			CALL "informix".reversion ('001', '9350', p_Usuario,p_FolioSuc,"A") Returning v_cod_ret;	
		END IF;
        IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
        END IF;		
        RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarcargosmanuales.out";
	--TRACE ON;
	
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
			csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
			csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
			csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
			csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
			csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
			csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
			csg_id_causa_esp_cred,csg_sit_esp_cred;

	IF csg_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00001";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	----CHECAR SI TAMBIEN SE VALIDARA ESTO 
	--- VALIDAR QUE LOS SALDOS DE LA APLICACION SEAN LOS MISMO QUE LOS DE LA BASE DE DATOS
	IF (p_CapitalVigente <> csg_cap_vig) OR (p_CapitalTransitorio <> csg_cap_trans) OR (p_CapitalVencido <> csg_cap_vdo_exig)
		OR (p_CapitalVdoNoExigible <> csg_cap_vdo_no_exig) OR (p_CapitalTotal <> csg_sdo_act_total_cap) OR (p_InteresVigente <> csg_int_vig)
		OR (p_IvaInteresVigente <> csg_iva_int_vig) OR (p_InteresVencido <> csg_int_vdo) OR (p_IvaInteresVencido <> csg_iva_int_vdo) 
		OR (p_InteresMoratorio <> csg_int_moratorios) OR (p_IvaInteresMoratorio <> csg_iva_int_moratorios) THEN
		LET v_cod_ret = "00002";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF


    SELECT trim(valor) 
    INTO s_Sucursal   ---Sucursal   '9250'
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

    IF s_Sucursal = '' OR s_Sucursal IS NULL THEN
		LET v_cod_ret = "00006";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF;
	 
	---OBTENER EL NUMERO DE  TARJETA DEL CREDITO  EN CUESTION
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general(p_Empresa, '', p_NumCredito,'','','','')
	INTO dat_codigo_ret, dat_Mensaje_ret, dat_Num_Cred, dat_Num_Cte, dat_Nom_Pdcto, dat_Num_Tarjeta, dat_Nom_Cte;

	
	--- REALIZA EL CARGO AL CREDITO EN CUESTION	
	EXECUTE PROCEDURE "informix".cargoref_tc_ofi(p_Empresa, s_Sucursal, p_Usuario, dat_Num_Tarjeta, p_ImporteCargo, p_FolioSuc, p_Transaccion )
	INTO car_Cod_Ret, car_Sald_Disp, car_Impor_Cgdo, car_Imp_comi, car_Iva_comi;

	IF car_Cod_Ret::INTEGER = 8 THEN
		LET v_cod_ret = "00005";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	ELIF car_Cod_Ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00003";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	LET cBanderaReversion = "S";
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
			csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
			csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
			csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,csg2_iva_int_moratorios,
			csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,csg2_tot_liquidacion,csg2_int_devengado,
			csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,csg2_id_bloqueo_cred,csg2_bloqueo_cta,
			csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,
			csg2_id_causa_esp_cred,csg2_sit_esp_cred;

	IF csg2_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "00004";
		RETURN v_cod_ret,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	
	--- INSERTA LA COLUMNA DE SALDO ACTUAL
	INSERT INTO "informix".sd_bitacora_cargos 
				(numcte,num_credito, fecha_cargo,hora_cargo, fecha_reverso, hora_reverso, importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,
				cap_total_ant, int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant, int_mora_ant, iva_int_mora_ant, cap_vig_pos,
				cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos, cod_cargo, desc_cargo, resultado, folio, folio_grupo, reverso, observaciones,observaciones_rev,usuario)
	VALUES (dat_Num_Cte,p_NumCredito,dFecha_Hoy,CURRENT,'','',p_ImporteCargo, csg_cap_vig, csg_cap_trans, csg_cap_vdo_exig, csg_cap_vdo_no_exig,
			csg_sdo_act_total_cap, csg_int_vig, csg_iva_int_vig, csg_int_vdo, csg_iva_int_vdo, csg_int_moratorios, csg_iva_int_moratorios, csg2_cap_vig,
			csg2_cap_trans, csg2_cap_vdo_exig, csg2_cap_vdo_no_exig, csg2_sdo_act_total_cap, p_codigo, p_Concepto,"OK", p_FolioSuc, '',"N",p_Observaciones,"",p_Usuario);
	

	RETURN v_cod_ret, csg2_cap_vig - csg_cap_vig, csg2_cap_trans-csg_cap_trans , csg2_cap_vdo_exig-csg_cap_vdo_exig ,
			csg2_cap_vdo_no_exig - csg_cap_vdo_no_exig, csg2_sdo_act_total_cap - csg_sdo_act_total_cap, csg2_int_vig - csg_int_vig, 
			csg2_iva_int_vig - csg_iva_int_vig, csg2_int_vdo - csg_int_vdo,
			csg2_iva_int_vdo - csg_iva_int_vdo, csg2_int_moratorios - csg_int_moratorios,
			csg2_iva_int_moratorios - csg2_iva_int_moratorios;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojorquez Ruelas,Jesus Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que Realiza el Cargo Manual validando que los saldos en pantallas sean los ultimos datos y hace registro en bitácora.',
'Crédito',
'FECHA : JULIO de 2011',
'VERSION: 20100118.2023',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_grabarcargosmasivos
(
	p_Empresa					CHAR(3),
	p_Usuario					CHAR(8),
	p_FolioGpo					CHAR(16),
	p_NumCredito				CHAR(20),
	p_ImporteCargo 				MONEY(18,2),
	p_Transaccion				CHAR(4),
	p_codigo                    CHAR(2), 
	p_DesCodigo  				CHAR(50),
	p_Concepto					CHAR(50)
	
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(16) AS FolioPago;

---DECLARACIONES
	DEFINE v_cod_ret				 CHAR(6);
	DEFINE iSqlErr					INTEGER;
	DEFINE iSamErr					INTEGER;

	DEFINE s_Sucursal				CHAR(4);
	DEFINE dFecha_dia               DATE;
	DEFINE dHora                    CHAR(8); 
	DEFINE cFolioCargo              CHAR(16);
	DEFINE iBandera                 INTEGER;
	DEFINE cBanderaReversion        CHAR(1);
	
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	DEFINE csg_codigo_ret			CHAR(6);
	DEFINE csg_mensaje_ret			CHAR(80);
	DEFINE csg_num_credito			CHAR(20);
	DEFINE csg_cod_tipcred			CHAR(2);
	DEFINE csg_fec_origen			DATE;
	DEFINE csg_fec_prox_pago		DATE;
	DEFINE csg_pago_min				MONEY(18,2);
	DEFINE csg_fec_ult_pago			DATE;
	DEFINE csg_plazo				INTEGER;
	DEFINE csg_pagos_realizados		INTEGER;
	DEFINE csg_linea_otorgada		MONEY(18,2);
	DEFINE csg_tasa_interes			DECIMAL(9,6);
	DEFINE csg_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg_monto_sbc			DECIMAL(14,2);
	DEFINE csg_cap_vig				MONEY(18,2);
	DEFINE csg_cap_trans			MONEY(18,2);
	DEFINE csg_cap_vdo_exig			MONEY(18,2);
	DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg_int_vig				MONEY(18,2);
	DEFINE csg_int_vdo				MONEY(18,2);
	DEFINE csg_int_moratorios		MONEY(18,2);
	DEFINE csg_int_mes				MONEY(18,2);
	DEFINE csg_sdo_act_total_int	MONEY(18,2);
	DEFINE csg_iva_int_vig			MONEY(18,2);
	DEFINE csg_iva_int_vdo			MONEY(18,2);
	DEFINE csg_iva_int_moratorios	MONEY(18,2);
	DEFINE csg_iva_int_mes			MONEY(18,2);
	DEFINE csg_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg_com_pend				MONEY(18,2);
	DEFINE csg_iva_com				MONEY(18,2);
	DEFINE csg_sdo_retenido			MONEY(18,2);
	DEFINE csg_tot_liquidacion		MONEY(18,2);
	DEFINE csg_int_devengado		MONEY(18,2);
	DEFINE csg_iva_int_devengado	MONEY(18,2);
	DEFINE csg_linea_disp			MONEY(18,2);
	DEFINE csg_pagos_vdos			MONEY(18,2);
	DEFINE csg_desc_status_cred		CHAR(60);
	DEFINE csg_id_bloqueo_cred		INTEGER;
	DEFINE csg_bloqueo_cta			CHAR(60);
	DEFINE csg_id_causa_bloq_cred	CHAR(3);
	DEFINE csg_causa_bloqueo_cta	CHAR(50);
	DEFINE csg_id_sit_esp_cte		CHAR(1);
	DEFINE csg_id_causa_esp_cte		INTEGER;
	DEFINE csg_sit_esp_cte			CHAR(75);
	DEFINE csg_id_sit_esp_cred		CHAR(1);
	DEFINE csg_id_causa_esp_cred	INTEGER;
	DEFINE csg_sit_esp_cred			CHAR(75);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	DEFINE dat_codigo_ret           CHAR(6);
	DEFINE dat_Mensaje_ret          CHAR(80);
	DEFINE dat_Num_Cred             CHAR(20);
	DEFINE dat_Num_Cte              CHAR(20);
	DEFINE dat_Nom_Pdcto            CHAR(40);
	DEFINE dat_Num_Tarjeta          CHAR(20);
	DEFINE dat_Nom_Cte              CHAR(150);
	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	DEFINE car_Cod_Ret              CHAR(6);
	DEFINE car_Sald_Disp            DECIMAL(14,2);
	DEFINE car_Impor_Cgdo           DECIMAL(14,2);
	DEFINE car_Imp_comi             DECIMAL(14,2);
	DEFINE car_Iva_comi             DECIMAL(14,2);
			 
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL PAGO
	DEFINE csg2_codigo_ret			CHAR(6);
	DEFINE csg2_mensaje_ret			CHAR(80);
	DEFINE csg2_num_credito			CHAR(20);
	DEFINE csg2_cod_tipcred			CHAR(2);
	DEFINE csg2_fec_origen			DATE;
	DEFINE csg2_fec_prox_pago		DATE;
	DEFINE csg2_pago_min			MONEY(18,2);
	DEFINE csg2_fec_ult_pago		DATE;
	DEFINE csg2_plazo				INTEGER;
	DEFINE csg2_pagos_realizados	INTEGER;
	DEFINE csg2_linea_otorgada		MONEY(18,2);
	DEFINE csg2_tasa_interes		DECIMAL(9,6);
	DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
	DEFINE csg2_monto_sbc			DECIMAL(14,2);
	DEFINE csg2_cap_vig				MONEY(18,2);
	DEFINE csg2_cap_trans			MONEY(18,2);
	DEFINE csg2_cap_vdo_exig		MONEY(18,2);
	DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
	DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
	DEFINE csg2_int_vig				MONEY(18,2);
	DEFINE csg2_int_vdo				MONEY(18,2);
	DEFINE csg2_int_moratorios		MONEY(18,2);
	DEFINE csg2_int_mes				MONEY(18,2);
	DEFINE csg2_sdo_act_total_int	MONEY(18,2);
	DEFINE csg2_iva_int_vig			MONEY(18,2);
	DEFINE csg2_iva_int_vdo			MONEY(18,2);
	DEFINE csg2_iva_int_moratorios	MONEY(18,2);
	DEFINE csg2_iva_int_mes			MONEY(18,2);
	DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
	DEFINE csg2_com_pend			MONEY(18,2);
	DEFINE csg2_iva_com				MONEY(18,2);
	DEFINE csg2_sdo_retenido		MONEY(18,2);
	DEFINE csg2_tot_liquidacion		MONEY(18,2);
	DEFINE csg2_int_devengado		MONEY(18,2);
	DEFINE csg2_iva_int_devengado	MONEY(18,2);
	DEFINE csg2_linea_disp			MONEY(18,2);
	DEFINE csg2_pagos_vdos			MONEY(18,2);
	DEFINE csg2_desc_status_cred	CHAR(60);
	DEFINE csg2_id_bloqueo_cred		INTEGER;
	DEFINE csg2_bloqueo_cta			CHAR(60);
	DEFINE csg2_id_causa_bloq_cred	CHAR(3);
	DEFINE csg2_causa_bloqueo_cta	CHAR(50);
	DEFINE csg2_id_sit_esp_cte		CHAR(1);
	DEFINE csg2_id_causa_esp_cte	INTEGER;
	DEFINE csg2_sit_esp_cte			CHAR(75);
	DEFINE csg2_id_sit_esp_cred		CHAR(1);
	DEFINE csg2_id_causa_esp_cred	INTEGER;
	DEFINE csg2_sit_esp_cred		CHAR(75);
	DEFINE dMes                     CHAR(2);
	DEFINE dDia                     CHAR(2);
	DEFINE dFecha_Hoy				DATE;
	---INICIALIZACIONES
	LET v_cod_ret                   = "000000";
	LET s_Sucursal					= "";
	LET dFecha_dia                  = DATE(1);
	LET dHora                       = "";
	LET cFolioCargo					= "";
	LET iBandera                    = 0;
	LET cBanderaReversion           = "N";

	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
	LET csg_codigo_ret				= "000000";
	LET csg_mensaje_ret				= "";
	LET csg_num_credito				= "";
	LET csg_cod_tipcred				= "";
	LET csg_fec_origen				= DATE(1);
	LET csg_fec_prox_pago			= DATE(1);
	LET csg_pago_min				= 0.0;
	LET csg_fec_ult_pago			= DATE(1);
	LET csg_plazo					= 0;
	LET csg_pagos_realizados		= 0;
	LET csg_linea_otorgada			= 0.0;
	LET csg_tasa_interes			= 0.0;
	LET csg_tasa_moratorios			= 0.0;
	LET csg_monto_sbc				= 0.0;
	LET csg_cap_vig					= 0.0;
	LET csg_cap_trans				= 0.0;
	LET csg_cap_vdo_exig			= 0.0;
	LET csg_cap_vdo_no_exig			= 0.0;
	LET csg_sdo_act_total_cap		= 0.0;
	LET csg_int_vig					= 0.0;
	LET csg_int_vdo					= 0.0;
	LET csg_int_moratorios			= 0.0;
	LET csg_int_mes					= 0.0;
	LET csg_sdo_act_total_int		= 0.0;
	LET csg_iva_int_vig				= 0.0;
	LET csg_iva_int_vdo				= 0.0;
	LET csg_iva_int_moratorios		= 0.0;
	LET csg_iva_int_mes				= 0.0;
	LET csg_sdo_act_total_iva		= 0.0;
	LET csg_com_pend				= 0.0;
	LET csg_iva_com					= 0.0;
	LET csg_sdo_retenido			= 0.0;
	LET csg_tot_liquidacion			= 0.0;
	LET csg_int_devengado			= 0.0;
	LET csg_iva_int_devengado		= 0.0;
	LET csg_linea_disp				= 0.0;
	LET csg_pagos_vdos				= 0.0;
	LET csg_desc_status_cred		= "";
	LET csg_id_bloqueo_cred			= 0;
	LET csg_bloqueo_cta				= "";
	LET csg_id_causa_bloq_cred		= "";
	LET csg_causa_bloqueo_cta		= "";
	LET csg_id_sit_esp_cte			= "";
	LET csg_id_causa_esp_cte		= 0;
	LET csg_sit_esp_cte				= "";
	LET csg_id_sit_esp_cred			= "";
	LET csg_id_causa_esp_cred		= 0;
	LET csg_sit_esp_cred			= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_datos_general
	LET dat_codigo_ret           	= "";
	LET dat_Mensaje_ret          	= "";
	LET dat_Num_Cred             	= "";
	LET dat_Num_Cte              	= "";
	LET dat_Nom_Pdcto            	= "";
	LET dat_Num_Tarjeta          	= "";
	LET dat_Nom_Cte              	= "";	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE cargoref_tc_ofi
	LET car_Cod_Ret                 = "";
	LET car_Sald_Disp           	= 0.0;
	LET car_Impor_Cgdo           	= 0.0;
	LET car_Imp_comi             	= 0.0;
	LET car_Iva_comi             	= 0.0;	
	---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL PAGO
	LET csg2_codigo_ret				= "";
	LET csg2_mensaje_ret			= "";
	LET csg2_num_credito			= "";
	LET csg2_cod_tipcred			= "";
	LET csg2_fec_origen				= DATE(1);
	LET csg2_fec_prox_pago			= DATE(1);
	LET csg2_pago_min				= 0.0;
	LET csg2_fec_ult_pago			= DATE(1);
	LET csg2_plazo					= 0;
	LET csg2_pagos_realizados		= 0;
	LET csg2_linea_otorgada			= 0.0;
	LET csg2_tasa_interes			= 0.0;
	LET csg2_tasa_moratorios		= 0.0;
	LET csg2_monto_sbc				= 0.0;
	LET csg2_cap_vig				= 0.0;
	LET csg2_cap_trans				= 0.0;
	LET csg2_cap_vdo_exig			= 0.0;
	LET csg2_cap_vdo_no_exig		= 0.0;
	LET csg2_sdo_act_total_cap		= 0.0;
	LET csg2_int_vig				= 0.0;
	LET csg2_int_vdo				= 0.0;
	LET csg2_int_moratorios			= 0.0;
	LET csg2_int_mes				= 0.0;
	LET csg2_sdo_act_total_int		= 0.0;
	LET csg2_iva_int_vig			= 0.0;
	LET csg2_iva_int_vdo			= 0.0;
	LET csg2_iva_int_moratorios		= 0.0;
	LET csg2_iva_int_mes			= 0.0;
	LET csg2_sdo_act_total_iva		= 0.0;
	LET csg2_com_pend				= 0.0;
	LET csg2_iva_com				= 0.0;
	LET csg2_sdo_retenido			= 0.0;
	LET csg2_tot_liquidacion		= 0.0;
	LET csg2_int_devengado			= 0.0;
	LET csg2_iva_int_devengado		= 0.0;
	LET csg2_linea_disp				= 0.0;
	LET csg2_pagos_vdos				= 0.0;
	LET csg2_desc_status_cred		= "";
	LET csg2_id_bloqueo_cred		= 0;
	LET csg2_bloqueo_cta			= "";
	LET csg2_id_causa_bloq_cred		= "";
	LET csg2_causa_bloqueo_cta		= "";
	LET csg2_id_sit_esp_cte			= "";
	LET csg2_id_causa_esp_cte		= 0;
	LET csg2_sit_esp_cte			= "";
	LET csg2_id_sit_esp_cred		= "";
	LET csg2_id_causa_esp_cred		= 0;
	LET csg2_sit_esp_cred			= "";	
	LET dMes                        = "";
	LET dDia                        = "";
	LET dFecha_Hoy					= DATE(1);
	
BEGIN

	ON EXCEPTION
        SET iSqlErr, iSamErr		
		IF cBanderaReversion ='S' THEN
			CALL "informix".reversion ('001', s_Sucursal, 'carmas',cFolioCargo,"A") Returning v_cod_ret;	
		END IF;
        IF iSqlErr <> 0 THEN
			LET v_cod_ret = iSqlErr;
        END IF;		
        RETURN v_cod_ret,'';
    END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarcargosmasivos.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
			csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
			csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
			csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
			csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
			csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
			csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
			csg_id_causa_esp_cred,csg_sit_esp_cred;

	IF csg_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000001";
		RETURN v_cod_ret,'';
	END IF
	
    SELECT trim(valor) 
    INTO s_Sucursal
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

    IF s_Sucursal = '' OR s_Sucursal IS NULL THEN
		LET v_cod_ret = "000002";
		RETURN v_cod_ret,'';
    END IF;
	
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	---PARA OBTENER LA FECHA Y LA HORA ESACTA PARA PONERLA EN LA INSERCCION EN UN SP..VISUALAIZER
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  
	INTO dFecha_dia
	FROM sysmaster:"informix".sysshmvals;

	WHILE iBandera  = 0 
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
		INTO dHora
		FROM sysmaster:"informix".sysshmvals;	
		
		LET dDia =  DAY(dFecha_dia);
		LET dMes =  MONTH(dFecha_dia);
	
		LET cFolioCargo = "carmas"||LPAD(TRIM(dDia),2,'0')
								  ||LPAD(TRIM(dMes),2,'0')|| SUBSTR(dHora, 1, 2)|| SUBSTR(dHora, 4, 2)||SUBSTR(dHora, 7, 2);
		
		IF EXISTS (	SELECT folio  FROM "informix".sd_bitacora_cargos	WHERE folio =  cFolioCargo AND folio_grupo = p_FolioGpo) THEN
				LET iBandera = 0;
		ELSE
				LET iBandera = 1;
		END IF;
	END WHILE
	
	
	---OBTENER EL NUMERO DE  TARJETA DEL CREDITO  EN CUESTION
	EXECUTE PROCEDURE "informix".sp_consulta_datos_general(p_Empresa, '', p_NumCredito,'','','','')
	INTO dat_codigo_ret, dat_Mensaje_ret, dat_Num_Cred, dat_Num_Cte, dat_Nom_Pdcto, dat_Num_Tarjeta, dat_Nom_Cte;
	
	--- REALIZA EL CARGO AL CREDITO EN CUESTION
	EXECUTE PROCEDURE bdicred:"informix".cargoref_tc_ofi(p_Empresa, s_Sucursal, 'carmas', dat_Num_Tarjeta, p_ImporteCargo, cFolioCargo, p_Transaccion )
	INTO car_Cod_Ret, car_Sald_Disp, car_Impor_Cgdo, car_Imp_comi, car_Iva_comi;

	IF car_Cod_Ret::INTEGER = 8 THEN
		LET v_cod_ret = "000007";
		RETURN v_cod_ret,'';   --credito nulo
	ELIF car_Cod_Ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000008";
		RETURN v_cod_ret,'';
	END IF
	LET cBanderaReversion = "S";
	--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
	EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(p_Empresa,p_NumCredito) 
	INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
			csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
			csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
			csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,csg2_iva_int_moratorios,
			csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,csg2_tot_liquidacion,csg2_int_devengado,
			csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,csg2_id_bloqueo_cred,csg2_bloqueo_cta,
			csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,
			csg2_id_causa_esp_cred,csg2_sit_esp_cred;

	IF csg2_codigo_ret::INTEGER <> 0 THEN
		LET v_cod_ret = "000003";
		RETURN v_cod_ret,'';
	END IF
	
	
	--- SE ACTUALIZA EL REGISTRO DEL CATALOGO DE PAGOS CON LA INFORMACION DEL PAGO REALIZADO
	INSERT INTO "informix".sd_bitacora_cargos 
				(numcte,num_credito, fecha_cargo,hora_cargo, fecha_reverso, hora_reverso, importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,
				cap_total_ant, int_vig_ant, iva_int_vig_ant, int_ven_ant, iva_int_ven_ant, int_mora_ant, iva_int_mora_ant, cap_vig_pos,
				cap_tran_pos, cap_venc_pos,	cap_venc_noexi_pos, cap_total_pos, cod_cargo, desc_cargo, resultado, folio, folio_grupo, reverso, observaciones,observaciones_rev,usuario)
	VALUES (dat_Num_Cte,p_NumCredito,dFecha_Hoy,dHora,'','',p_ImporteCargo, csg_cap_vig, csg_cap_trans, csg_cap_vdo_exig, csg_cap_vdo_no_exig,
			csg_sdo_act_total_cap, csg_int_vig, csg_iva_int_vig, csg_int_vdo, csg_iva_int_vdo, csg_int_moratorios, csg_iva_int_moratorios, csg2_cap_vig,
			csg2_cap_trans, csg2_cap_vdo_exig, csg2_cap_vdo_no_exig, csg2_sdo_act_total_cap, p_codigo, p_DesCodigo,"OK", cFolioCargo,p_FolioGpo,"N","","",p_Usuario);
	
	
	RETURN v_cod_ret, cFolioCargo;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia',
'DESCRIPCION: Procedimiento que Realiza el Cargo Masivo.',
'Crédito',
'FECHA : JULIO de 2011',
'VERSION: 20110713.1023',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_grabarreversocargoman (pFolio CHAR(16), pEjecutivo CHAR(8),  pObservacionRev CHAR(200))

RETURNING  CHAR(5);

DEFINE cCodRet 			 		CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cSucursal				CHAR(4);
DEFINE cCredito					CHAR(20);
DEFINE vFecha                   DATE;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarreversocargoman.out";
	--TRACE ON;

	LET cCodRet   = '00000';
	LET iSqlErr	  = 0;		
	LET cSucursal = '';
	LET cCredito = '';
    LET vFecha   = date(1);

    
	SELECT fecha_hoy
	INTO vfecha
	FROM "informix".sd_fechas;


	SELECT LIMIT 1 num_credito
	INTO cCredito
	FROM "informix".sd_bitacora_cargos
	WHERE fecha_cargo = vfecha
      AND folio = pFolio;


    SELECT trim(valor) 
    INTO cSucursal
    FROM "informix".sd_param
    WHERE empresa = '001'
    AND cod_param = '28';

   
        IF cCredito <> '' AND cCredito IS NOT NULL AND cSucursal <> '' AND cSucursal IS NOT NULL THEN

            CALL "informix".reversion ('001', cSucursal, pEjecutivo,pFolio, "A") Returning cCodRet;	

                IF cCodRet <> 0 THEN --La reversion no se realizo exitosamente
                    LET cCodRet= '10000';
                    RETURN cCodRet;
                END IF;	

            UPDATE "informix".sd_bitacora_cargos 
			SET reverso='S', 
			observaciones_rev = pObservacionRev ,
			fecha_reverso = vfecha,
			hora_reverso = CURRENT
			WHERE folio = pFolio; --Actualiza a reversado el estatus del Cargo manual.

        ELSE 
            LET cCodRet= '10000';
        END IF;       
	RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: MANDA LLAMAR LA REVERSION Y ACTUALIZA A REVERSADO EL ESTATUS EN LOS CARGOS MANUALES', 
'AUTOR: Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110714.1702',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_grabarreversocargosmasivos (pFolio CHAR(16))

RETURNING  CHAR(6), CHAR(100);

--definicion de variables
DEFINE cCodRet 			 		CHAR(6);
DEFINE cMensaje                 CHAR(100) ;
DEFINE iSqlErr			 		INTEGER;
DEFINE cCredito					CHAR(20);
DEFINE dFecha_Hoy                   DATE;
DEFINE dHora                    CHAR(8);
DEFINE cEmpresa                 CHAR(3);
DEFINE cReverso                 CHAR(1);  

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
DEFINE csg_codigo_ret			CHAR(6);
DEFINE csg_mensaje_ret			CHAR(80);
DEFINE csg_num_credito			CHAR(20);
DEFINE csg_cod_tipcred			CHAR(2);
DEFINE csg_fec_origen			DATE;
DEFINE csg_fec_prox_pago		DATE;
DEFINE csg_pago_min				MONEY(18,2);
DEFINE csg_fec_ult_pago			DATE;
DEFINE csg_plazo				INTEGER;
DEFINE csg_pagos_realizados		INTEGER;
DEFINE csg_linea_otorgada		MONEY(18,2);
DEFINE csg_tasa_interes			DECIMAL(9,6);
DEFINE csg_tasa_moratorios		DECIMAL(9,6);
DEFINE csg_monto_sbc			DECIMAL(14,2);
DEFINE csg_cap_vig				MONEY(18,2);
DEFINE csg_cap_trans			MONEY(18,2);
DEFINE csg_cap_vdo_exig			MONEY(18,2);
DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg_sdo_act_total_cap	MONEY(18,2);
DEFINE csg_int_vig				MONEY(18,2);
DEFINE csg_int_vdo				MONEY(18,2);
DEFINE csg_int_moratorios		MONEY(18,2);
DEFINE csg_int_mes				MONEY(18,2);
DEFINE csg_sdo_act_total_int	MONEY(18,2);
DEFINE csg_iva_int_vig			MONEY(18,2);
DEFINE csg_iva_int_vdo			MONEY(18,2);
DEFINE csg_iva_int_moratorios	MONEY(18,2);
DEFINE csg_iva_int_mes			MONEY(18,2);
DEFINE csg_sdo_act_total_iva	MONEY(18,2);
DEFINE csg_com_pend				MONEY(18,2);
DEFINE csg_iva_com				MONEY(18,2);
DEFINE csg_sdo_retenido			MONEY(18,2);
DEFINE csg_tot_liquidacion		MONEY(18,2);
DEFINE csg_int_devengado		MONEY(18,2);
DEFINE csg_iva_int_devengado	MONEY(18,2);
DEFINE csg_linea_disp			MONEY(18,2);
DEFINE csg_pagos_vdos			MONEY(18,2);
DEFINE csg_desc_status_cred		CHAR(60);
DEFINE csg_id_bloqueo_cred		INTEGER;
DEFINE csg_bloqueo_cta			CHAR(60);
DEFINE csg_id_causa_bloq_cred	CHAR(3);
DEFINE csg_causa_bloqueo_cta	CHAR(50);
DEFINE csg_id_sit_esp_cte		CHAR(1);
DEFINE csg_id_causa_esp_cte		INTEGER;
DEFINE csg_sit_esp_cte			CHAR(75);
DEFINE csg_id_sit_esp_cred		CHAR(1);
DEFINE csg_id_causa_esp_cred	INTEGER;
DEFINE csg_sit_esp_cred			CHAR(75);
	 
---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
DEFINE csg2_codigo_ret			CHAR(6);
DEFINE csg2_mensaje_ret			CHAR(80);
DEFINE csg2_num_credito			CHAR(20);
DEFINE csg2_cod_tipcred			CHAR(2);
DEFINE csg2_fec_origen			DATE;
DEFINE csg2_fec_prox_pago		DATE;
DEFINE csg2_pago_min			MONEY(18,2);
DEFINE csg2_fec_ult_pago		DATE;
DEFINE csg2_plazo				INTEGER;
DEFINE csg2_pagos_realizados	INTEGER;
DEFINE csg2_linea_otorgada		MONEY(18,2);
DEFINE csg2_tasa_interes		DECIMAL(9,6);
DEFINE csg2_tasa_moratorios		DECIMAL(9,6);
DEFINE csg2_monto_sbc			DECIMAL(14,2);
DEFINE csg2_cap_vig				MONEY(18,2);
DEFINE csg2_cap_trans			MONEY(18,2);
DEFINE csg2_cap_vdo_exig		MONEY(18,2);
DEFINE csg2_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg2_sdo_act_total_cap	MONEY(18,2);
DEFINE csg2_int_vig				MONEY(18,2);
DEFINE csg2_int_vdo				MONEY(18,2);
DEFINE csg2_int_moratorios		MONEY(18,2);
DEFINE csg2_int_mes				MONEY(18,2);
DEFINE csg2_sdo_act_total_int	MONEY(18,2);
DEFINE csg2_iva_int_vig			MONEY(18,2);
DEFINE csg2_iva_int_vdo			MONEY(18,2);
DEFINE csg2_iva_int_moratorios	MONEY(18,2);
DEFINE csg2_iva_int_mes			MONEY(18,2);
DEFINE csg2_sdo_act_total_iva	MONEY(18,2);
DEFINE csg2_com_pend			MONEY(18,2);
DEFINE csg2_iva_com				MONEY(18,2);
DEFINE csg2_sdo_retenido		MONEY(18,2);
DEFINE csg2_tot_liquidacion		MONEY(18,2);
DEFINE csg2_int_devengado		MONEY(18,2);
DEFINE csg2_iva_int_devengado	MONEY(18,2);
DEFINE csg2_linea_disp			MONEY(18,2);
DEFINE csg2_pagos_vdos			MONEY(18,2);
DEFINE csg2_desc_status_cred	CHAR(60);
DEFINE csg2_id_bloqueo_cred		INTEGER;
DEFINE csg2_bloqueo_cta			CHAR(60);
DEFINE csg2_id_causa_bloq_cred	CHAR(3);
DEFINE csg2_causa_bloqueo_cta	CHAR(50);
DEFINE csg2_id_sit_esp_cte		CHAR(1);
DEFINE csg2_id_causa_esp_cte	INTEGER;
DEFINE csg2_sit_esp_cte			CHAR(75);
DEFINE csg2_id_sit_esp_cred		CHAR(1);
DEFINE csg2_id_causa_esp_cred	INTEGER;
DEFINE csg2_sit_esp_cred		CHAR(75);

	
--Inicializacion de variables
LET cCodRet   = '000000';
LET cMensaje =  'Proceso Exitoso!!!';
LET iSqlErr	  = 0;		
LET cCredito = '';
LET dFecha_Hoy   = date(1);
LET dHora    = '';
LET cEmpresa = "001";
LET cReverso =  "";

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET csg_codigo_ret				= "000000";
LET csg_mensaje_ret				= "";
LET csg_num_credito				= "";
LET csg_cod_tipcred				= "";
LET csg_fec_origen				= MDY(1,1,1900);
LET csg_fec_prox_pago			= MDY(1,1,1900);
LET csg_pago_min				= 0.0;
LET csg_fec_ult_pago			= MDY(1,1,1900);
LET csg_plazo					= 0;
LET csg_pagos_realizados		= 0;
LET csg_linea_otorgada			= 0.0;
LET csg_tasa_interes			= 0.0;
LET csg_tasa_moratorios			= 0.0;
LET csg_monto_sbc				= 0.0;
LET csg_cap_vig					= 0.0;
LET csg_cap_trans				= 0.0;
LET csg_cap_vdo_exig			= 0.0;
LET csg_cap_vdo_no_exig			= 0.0;
LET csg_sdo_act_total_cap		= 0.0;
LET csg_int_vig					= 0.0;
LET csg_int_vdo					= 0.0;
LET csg_int_moratorios			= 0.0;
LET csg_int_mes					= 0.0;
LET csg_sdo_act_total_int		= 0.0;
LET csg_iva_int_vig				= 0.0;
LET csg_iva_int_vdo				= 0.0;
LET csg_iva_int_moratorios		= 0.0;
LET csg_iva_int_mes				= 0.0;
LET csg_sdo_act_total_iva		= 0.0;
LET csg_com_pend				= 0.0;
LET csg_iva_com					= 0.0;
LET csg_sdo_retenido			= 0.0;
LET csg_tot_liquidacion			= 0.0;
LET csg_int_devengado			= 0.0;
LET csg_iva_int_devengado		= 0.0;
LET csg_linea_disp				= 0.0;
LET csg_pagos_vdos				= 0.0;
LET csg_desc_status_cred		= "";
LET csg_id_bloqueo_cred			= 0;
LET csg_bloqueo_cta				= "";
LET csg_id_causa_bloq_cred		= "";
LET csg_causa_bloqueo_cta		= "";
LET csg_id_sit_esp_cte			= "";
LET csg_id_causa_esp_cte		= 0;
LET csg_sit_esp_cte				= "";
LET csg_id_sit_esp_cred			= "";
LET csg_id_causa_esp_cred		= 0;
LET csg_sit_esp_cred			= "";


---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general DESPUES DE HACER EL CARGO
LET csg2_codigo_ret				= "";
LET csg2_mensaje_ret			= "";
LET csg2_num_credito			= "";
LET csg2_cod_tipcred			= "";
LET csg2_fec_origen				= MDY(1,1,1900);
LET csg2_fec_prox_pago			= MDY(1,1,1900);
LET csg2_pago_min				= 0.0;
LET csg2_fec_ult_pago			= MDY(1,1,1900);
LET csg2_plazo					= 0;
LET csg2_pagos_realizados		= 0;
LET csg2_linea_otorgada			= 0.0;
LET csg2_tasa_interes			= 0.0;
LET csg2_tasa_moratorios		= 0.0;
LET csg2_monto_sbc				= 0.0;
LET csg2_cap_vig				= 0.0;
LET csg2_cap_trans				= 0.0;
LET csg2_cap_vdo_exig			= 0.0;
LET csg2_cap_vdo_no_exig		= 0.0;
LET csg2_sdo_act_total_cap		= 0.0;
LET csg2_int_vig				= 0.0;
LET csg2_int_vdo				= 0.0;
LET csg2_int_moratorios			= 0.0;
LET csg2_int_mes				= 0.0;
LET csg2_sdo_act_total_int		= 0.0;
LET csg2_iva_int_vig			= 0.0;
LET csg2_iva_int_vdo			= 0.0;
LET csg2_iva_int_moratorios		= 0.0;
LET csg2_iva_int_mes			= 0.0;
LET csg2_sdo_act_total_iva		= 0.0;
LET csg2_com_pend				= 0.0;
LET csg2_iva_com				= 0.0;
LET csg2_sdo_retenido			= 0.0;
LET csg2_tot_liquidacion		= 0.0;
LET csg2_int_devengado			= 0.0;
LET csg2_iva_int_devengado		= 0.0;
LET csg2_linea_disp				= 0.0;
LET csg2_pagos_vdos				= 0.0;
LET csg2_desc_status_cred		= "";
LET csg2_id_bloqueo_cred		= 0;
LET csg2_bloqueo_cta			= "";
LET csg2_id_causa_bloq_cred		= "";
LET csg2_causa_bloqueo_cta		= "";
LET csg2_id_sit_esp_cte			= "";
LET csg2_id_causa_esp_cte		= 0;
LET csg2_sit_esp_cte			= "";
LET csg2_id_sit_esp_cred		= "";
LET csg2_id_causa_esp_cred		= 0;
LET csg2_sit_esp_cred			= "";

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, '';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_grabarreversocargosmasivos.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		---PARA OBTENER LA FECHA Y LA HORA ESACTA PARA PONERLA EN LA INSERCCION EN UN SP..VISUALAIZER
	SELECT fecha_hoy
	INTO dFecha_Hoy
	FROM "informix".sd_fechas;
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
	INTO dHora
	FROM sysmaster:"informix".sysshmvals;	

	SELECT LIMIT 1 num_credito, reverso
	INTO cCredito, cReverso
	FROM "informix".sd_bitacora_cargos
	WHERE fecha_cargo = dFecha_Hoy
      AND folio = pFolio;
	  
	  
	IF cReverso =  "S" THEN
		LET cCodRet= '100000';
        RETURN cCodRet, 'El folio ya fue reversado anteriormente';
	END IF;

		--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO
		EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa,cCredito) 
		INTO  csg_codigo_ret,csg_mensaje_ret,csg_num_credito,csg_cod_tipcred,csg_fec_origen,csg_fec_prox_pago,csg_pago_min,
				csg_fec_ult_pago,csg_plazo,csg_pagos_realizados,csg_linea_otorgada,csg_tasa_interes,csg_tasa_moratorios,
				csg_monto_sbc,csg_cap_vig,csg_cap_trans,csg_cap_vdo_exig,csg_cap_vdo_no_exig,csg_sdo_act_total_cap,csg_int_vig,
				csg_int_vdo,csg_int_moratorios,csg_int_mes,csg_sdo_act_total_int,csg_iva_int_vig,csg_iva_int_vdo,csg_iva_int_moratorios,
				csg_iva_int_mes,csg_sdo_act_total_iva,csg_com_pend,csg_iva_com,csg_sdo_retenido,csg_tot_liquidacion,csg_int_devengado,
				csg_iva_int_devengado,csg_linea_disp,csg_pagos_vdos,csg_desc_status_cred,csg_id_bloqueo_cred,csg_bloqueo_cta,
				csg_id_causa_bloq_cred,csg_causa_bloqueo_cta,csg_id_sit_esp_cte,csg_id_causa_esp_cte,csg_sit_esp_cte,csg_id_sit_esp_cred,
				csg_id_causa_esp_cred,csg_sit_esp_cred;

		IF csg_codigo_ret::INTEGER <> 0 THEN
			LET cCodRet = "000001";  --Error en la obtencion del saldo antes del reverso
			RETURN cCodRet,'Error en la obtencion del saldo antes del reverso';
		END IF


   
        IF cCredito <> '' AND cCredito IS NOT NULL THEN

            CALL "informix".reversion ('001', "9250", "carmas", pFolio, "A") Returning cCodRet;	

                IF cCodRet = -284 THEN --El Cargo del folio ya fue reversado anteriormente
                    LET cCodRet= '100000';
                    RETURN cCodRet, 'El Cargo del folio ya fue reversado anteriormente';
				elif cCodRet = "431" THEN -- CARGO NO ES EL ULTIMO REVERSA EN ORDEN	 
					LET cCodRet= '200000';
					RETURN cCodRet, 'El crédito del folio no es el mas actual';
				elif cCodRet   = '000'  THEN
					LET cCodRet   = '000000';
					
					--- OBTIENE LOS SALDOS ACTUALES DEL CREDITO DESPUES DEL CARGO
					EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(cEmpresa,cCredito) 
					INTO csg2_codigo_ret,csg2_mensaje_ret,csg2_num_credito,csg2_cod_tipcred,csg2_fec_origen,csg2_fec_prox_pago,csg2_pago_min,
							csg2_fec_ult_pago,csg2_plazo,csg2_pagos_realizados,csg2_linea_otorgada,csg2_tasa_interes,csg2_tasa_moratorios,
							csg2_monto_sbc,csg2_cap_vig,csg2_cap_trans,csg2_cap_vdo_exig,csg2_cap_vdo_no_exig,csg2_sdo_act_total_cap,csg2_int_vig,
							csg2_int_vdo,csg2_int_moratorios,csg2_int_mes,csg2_sdo_act_total_int,csg2_iva_int_vig,csg2_iva_int_vdo,
							csg2_iva_int_moratorios,csg2_iva_int_mes,csg2_sdo_act_total_iva,csg2_com_pend,csg2_iva_com,csg2_sdo_retenido,
							csg2_tot_liquidacion,csg2_int_devengado,csg2_iva_int_devengado,csg2_linea_disp,csg2_pagos_vdos,csg2_desc_status_cred,
							csg2_id_bloqueo_cred,csg2_bloqueo_cta,csg2_id_causa_bloq_cred,csg2_causa_bloqueo_cta,csg2_id_sit_esp_cte,
							csg2_id_causa_esp_cte,csg2_sit_esp_cte,csg2_id_sit_esp_cred,csg2_id_causa_esp_cred,csg2_sit_esp_cred;

					IF csg2_codigo_ret::INTEGER <> 0 THEN
						LET cCodRet = "000004";   --Error en la obtencion del saldo despues del reverso
						RETURN cCodRet,'Error en la obtencion del saldo despues del reverso';
					END IF

										
				else
					LET cCodRet= '400000';
					RETURN cCodRet, 'Error en el reverso del Cargo';
				
                END IF;	

            UPDATE "informix".sd_bitacora_cargos    
			SET fecha_reverso = dFecha_Hoy,
				hora_reverso = dHora,
				reverso = "S"				
			WHERE folio = pFolio; --Actualiza a reversado el estatus del Cargo Masivo.

        ELSE 
            LET cCodRet= '300000';
			LET cMensaje = 'Numero de crédito no se encuentra en la bitacora de Cargos ';
        END IF;       



	RETURN cCodRet,cMensaje;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: EJECUTA LA REVERSION DE LOS CARGOS SOLICITADOS', 
'AUTOR: Hector Manuel Bojorquez Ruelas,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110713.11202',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerconceptocargomanuales(p_Codconcepto CHAR(2),p_transaccion CHAR(4))
RETURNING CHAR(6),     --cod_ret
		  CHAR(2),     --Codigo pago
          VARCHAR(50), --descripcion
          CHAR(4);     --transaccion


---DECLARACIONES
DEFINE v_cod_ret      CHAR(6);
DEFINE iSqlErr        INTEGER;
DEFINE iSamErr        INTEGER;
DEFINE vIndicaTpoCons INTEGER;
DEFINE cCodigo        CHAR(2);
DEFINE cConcepto	  VARCHAR(50);
DEFINE ctransaccion   CHAR(4);

---INICIALIZACIONES
LET v_cod_ret            = '000000';
LET iSqlErr              = 0;
LET iSamErr              = 0;
LET vIndicaTpoCons       = 0;
LET cCodigo              = "";
LET cConcepto            = "";
LET ctransaccion         = "";
 
BEGIN

ON EXCEPTION
    SET iSqlErr, iSamErr
    IF iSqlErr <> 0 THEN
        LET v_cod_ret = iSqlErr;
    END IF;
    RETURN v_cod_ret,'','','';
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtenerconceptocargomanuales.out";
--TRACE ON;
	
		IF p_Codconcepto = "" THEN
			FOREACH
				SELECT codigo, concepto, transacc
				INTO cCodigo, cConcepto, ctransaccion
				FROM "informix".sd_conceptoscargoscredito
				WHERE mostrar_pantalla ='1'
				AND transacc = (case when nvl(p_transaccion,"") = "" then transacc else p_transaccion end)
				ORDER BY codigo
			
				RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion WITH RESUME;

			END FOREACH;			
		ELSE
			FOREACH
				SELECT codigo, concepto, transacc
				INTO cCodigo, cConcepto, ctransaccion
				FROM "informix".sd_conceptoscargoscredito
				WHERE codigo = p_Codconcepto 
				AND transacc = (case when nvl(p_transaccion,"") = "" then transacc else p_transaccion end)
				
				RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion WITH RESUME;

			END FOREACH;
			  
		END IF;	  

	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		--NO SE ENCUANTRAN REGISTROS PARA EL CRITERIO DE BUSQUEDA SOLICITADO	
		LET v_cod_ret = "000001";
		RETURN v_cod_ret,cCodigo,cConcepto,ctransaccion;
	END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR :Héctor Manuel Bojórquez Ruelas,Jesus Manuel Aguilar Heredia ',
'DESCRIPCION: Procedimiento que obtiene el catálogo de los Conceptos de Cargos,transacciones y codigo de funcion.',
'Crédito',
'FECHA : Julio de 2011',
'VERSION: 20110708.1752',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_obtenereversocargosman(pFolio CHAR(16))
RETURNING CHAR(5), CHAR(80), CHAR(20),CHAR(20), CHAR(40) , CHAR(20),CHAR(150) , DECIMAL(18,2),DECIMAL (18,2), DECIMAL(18,2),DECIMAL(18,2),
DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2), CHAR(20), CHAR(50);

--DECLARACION DE VARIABLES
DEFINE vCodRet    CHAR(5);
DEFINE vSqlErr, vIsamErr INTEGER;
DEFINE cNumCred   CHAR(20);
DEFINE cFolio     CHAR(16);
DEFINE cCodigo_retorno CHAR(6);
DEFINE cMensaje_retorno CHAR (80);
DEFINE cNumero_credito	CHAR(20);
DEFINE cNumero_cliente	CHAR(20);
DEFINE cNombre_producto	CHAR(40);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cNombre_cliente	CHAR (150);	
DEFINE cImporte_Cargo		DECIMAL(18,2);
DEFINE cCapital_vigente	DECIMAL(18,2);
DEFINE cCapital_transitorio DECIMAL(18,2);
DEFINE cCapital_vencido DECIMAL(18,2);
DEFINE cCapital_vencido_no_exigible DECIMAL(18,2);
DEFINE cInteres_vigente DECIMAL(18,2);
DEFINE cIva_de_interes_vigente DECIMAL(18,2);
DEFINE cInteres_vencido DECIMAL(18,2);
DEFINE cIva_de_interes_vencido DECIMAL(18,2);
DEFINE cInteres_moratorio DECIMAL(18,2);
DEFINE cIva_interesmoratorio	 DECIMAL(18,2);
DEFINE cCapital_Total	DECIMAL(18,2);
DEFINE cConcepto		CHAR(20);
DEFINE cDescripcion     CHAR(200);
--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET cNumCred = '';
LET cFolio   = '';
LET cCodigo_retorno = 0;
LET cMensaje_retorno  = 0;
LET cNumero_credito	 = 0;
LET cNumero_cliente	 = 0;
LET cNombre_producto	 = 0;
LET cNumero_tarjeta	 = 0;
LET cNombre_cliente	 = 0;
LET cImporte_Cargo		 = 0;
LET cCapital_vigente	 = 0;
LET cCapital_transitorio  = 0;
LET cCapital_vencido  = 0;
LET cCapital_vencido_no_exigible  = 0;
LET cInteres_vigente  = 0;
LET cIva_de_interes_vigente  = 0;
LET cInteres_vencido  = 0;
LET cIva_de_interes_vencido = 0;
LET cInteres_moratorio  = 0;
LET cIva_interesmoratorio	  = 0;
LET cCapital_Total	 = 0;
LET cConcepto		='';
LET cDescripcion   = '';

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtenereversocargosman.out";
	--TRACE ON;

BEGIN
	--MANEJO DE ERRORES
	ON EXCEPTION SET vSqlErr, vIsamErr
		IF vSqlErr != 0 THEN
			LET vCodRet = vSqlErr;
			RETURN vCodRet,'', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
		END IF;
	END EXCEPTION;

	IF NOT EXISTS( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio) THEN              --El folio recibido no se trata de un cargo manual
		LET vCodRet= '20000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
	END IF;

	IF EXISTS ( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio AND reverso = 'S') THEN
		LET vCodRet= '30000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;			
	END IF;

	--VALIDACION PARA REVERSAR PAGO MANUAL

	SELECT Limit 1 trim(num_credito)
	INTO cNumCred
	FROM "informix".sd_movdia
	WHERE folio_suc = pFolio;	

	SELECT folio_suc 
		INTO cFolio
	FROM  "informix".sd_movdia
	WHERE num_credito = cNumCred
	AND reversado <> 'S'
	AND secuencia = (SELECT MAX(secuencia)  
					 FROM  "informix".sd_movdia
					 WHERE num_credito = cNumCred 
					 AND reversado <> 'S');
	

	IF  cFolio <> pFolio THEN            --El folio recibido no es el ultimo movimiento
		LET vCodRet= '10000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','' ;
	END IF;		

	CALL "informix".sp_consulta_datos_general('001', '', cNumCred,'','','','')
	RETURNING cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;

	FOREACH

		SELECT importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,cap_total_ant, int_vig_ant, iva_int_vig_ant, 
				int_ven_ant, iva_int_ven_ant, int_mora_ant,  iva_int_mora_ant, cod_cargo, observaciones
		INTO cImporte_Cargo, cCapital_vigente, cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total, cInteres_vigente, 
			cIva_de_interes_vigente, cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion
		FROM "informix".sd_bitacora_cargos
		WHERE folio= pFolio	
		AND reverso =  'N'

		RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_Cargo, cCapital_vigente,
				cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
				cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion WITH RESUME;

	END FOREACH
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE DATOS GENERALES, DETALLE DE APLICACION Y SALDOS NUEVOS',
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110714.1408',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerinforeversioncargo(pFolio_grupo  CHAR(16))
RETURNING  CHAR(6), CHAR(50), CHAR(20), MONEY(14,2), CHAR(2), char(100), CHAR(100), CHAR(16), CHAR(1);


DEFINE cCodRet 		     CHAR(6);
DEFINE iSqlErr           INTEGER;
DEFINE cMensaje          CHAR(50);
DEFINE iReg              INTEGER; 

DEFINE cCredito		     CHAR(20);
DEFINE iImporte          MONEY(14,2);
DEFINE cCodigo_cargo      CHAR(2);
DEFINE cDesc_cargo        CHAR(100);
DEFINE cResultado        CHAR(16);
DEFINE cFolio            CHAR(16);
DEFINE cReverso          CHAR(1);

LET cCodRet           = '000000';
LET iSqlErr	          = 0;
LET cMensaje          = 'Proceso Exitoso!!!';
LET iReg              = 0;

LET cCredito		  = '';
LET iImporte          = 0;
LET cCodigo_cargo      = '';
LET cDesc_cargo        = '';
LET cResultado        = '';
LET cFolio            = '';
LET cReverso          = '';

BEGIN
ON EXCEPTION SET iSqlErr
    IF iSqlErr != 0 THEN
        LET cCodRet= iSqlErr;
        RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtenerinforeversioncargo.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	FOREACH WITH HOLD
		
		SELECT num_credito, importe_cargo, cod_cargo, desc_cargo, resultado, folio, reverso
		INTO  cCredito, iImporte, cCodigo_cargo, cDesc_cargo, cResultado, cFolio, cReverso
		FROM "informix".sd_bitacora_cargos
		WHERE folio_grupo = pFolio_grupo
	
		
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso WITH RESUME;

	END FOREACH
			
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000002";
		LET cMensaje = "No se encontraron registros del folio solicitado";
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
	END IF;
		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE INFORMACION DE TODOS LOS REVERSOS DE CARGOS DEL FOLIO GRUPAL SOLICITADO', 
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: JULIO 2011',
'VERSION: 20110712.1822',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_select_muestras
(
pEmpresa 	CHAR(3)
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(20) AS NUM_CRED,
	CHAR(20) AS NUM_TARJ,
	CHAR(60) AS STA_MES_ANT,
	CHAR(60) AS STA_MES_ACT,
	SMALLINT AS FLAG_AUTO,
	CHAR(2) AS TIPO_LOGICA;

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE cCodRet         		CHAR(6);
	DEFINE cNumCredito			CHAR(20);
	DEFINE cNumTarjeta			CHAR(20);
	DEFINE cStatusMesAnt		CHAR(60);
	DEFINE cStatusMesAct		CHAR(60);
	DEFINE sFlagAutomatico		SMALLINT;
	DEFINE dtFechaUltCorte		DATE;
	DEFINE dtFechaHoy			DATE;
	DEFINE sMesUFC 				SMALLINT;
	DEFINE sDiaUFC 				SMALLINT;
	DEFINE sAnioUFC 			SMALLINT;
	DEFINE sMesHoy 				SMALLINT;
	DEFINE sDiaHoy 				SMALLINT;
	DEFINE sAnioHoy 			SMALLINT;
    DEFINE iNRows           	INTEGER;
	DEFINE cTipoLogica			CHAR(2);
	DEFINE dtFechaSigCorte		date;
	

	---INICIALIZACIONES
    LET iSqlErr            		= 0;
    LET cCodRet            		= '000000';
	LET cNumCredito				= '';
	LET cNumTarjeta				= '';
	LET cStatusMesAnt			= '';
	LET cStatusMesAct			= '';
	LET sFlagAutomatico			= 0;
	LET dtFechaUltCorte			= DATE(1);
	LET dtFechaHoy				= DATE(1);
	LET sMesUFC 				= 0;
	LET sDiaUFC 				= 0;
	LET sAnioUFC 				= 0;
	LET sMesHoy 				= 0;
	LET sDiaHoy 				= 0;
	LET sAnioHoy 				= 0;
	LET iNRows              	= 0;
	LET cTipoLogica				= '';
	LET dtFechaSigCorte			= DATE(1);
	

BEGIN
    
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO '/home/sysifx/has/sp_select_muestras.out';
	---TRACE ON;
	
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	-- OBTIENE LA ULTIMA FECHA DE CORTE DEL REPOSITORIO DE MUESTRAS
	SELECT MAX(fecha_corte)
	INTO dtFechaUltCorte
	FROM bdicred:'informix'.sd_muestra_edocta
	WHERE empresa = pEmpresa
	AND flag_generacion < 2
	AND fecha_corte = fecha_corte;
	
	--- VALIDA QUE LA ULTIMA FECHA DE CORTE NO ESTE VACIA
	IF NVL(dtFechaUltCorte,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000002';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesUFC = MONTH(dtFechaUltCorte);
	LET sDiaUFC = DAY(dtFechaUltCorte);
	LET sAnioUFC = YEAR(dtFechaUltCorte);
	
	-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;

	
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	/*IF sAnioUFC <> sAnioHoy OR sMesUFC <> sMesHoy OR sDiaUFC <> 20 OR sDiaHoy < 20 THEN
		LET cCodRet = '000004';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF*/
	
	--LET dtFechaSigCorte	=  dtFechaUltCorte - 1 UNITS MONTH - 1 units day;
	
	-- OBTIENE LOS DATOS DE LAS MUESTRAS SELECCIONADAS
	FOREACH WITH HOLD
		SELECT	TRIM(NVL(num_credito,'')), 
				TRIM(NVL(num_tarjeta,'')), 
				TRIM(CASE WHEN NVL(estatus_mes_anterior,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_anterior) END), 
				TRIM(CASE WHEN NVL(estatus_mes_actual,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_actual) END),
				NVL(flag_automatico,0),
				tipo_logica
		INTO cNumCredito, cNumTarjeta, cStatusMesAnt, cStatusMesAct, sFlagAutomatico, cTipoLogica
		FROM bdicred:'informix'.sd_muestra_edocta
		WHERE empresa = pEmpresa
		AND fecha_corte = dtFechaUltCorte
		AND flag_generacion < 2
		

		RETURN cCodRet,cNumCredito,cNumTarjeta,cStatusMesAnt,cStatusMesAct,sFlagAutomatico,cTipoLogica WITH RESUME;
	END FOREACH
	
    LET iNRows = dbinfo("sqlca.sqlerrd2");
    
    IF iNRows = 0 THEN
        LET cCodRet = "000005";
        RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener las muestras ya seleeccionadas para se candidatas a a generar posteriormente el estado de cuenta', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2011',
'VERSION: 20110805.1813';

CREATE PROCEDURE "informix".sp_valida_numcredito(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaCorte DATE)
RETURNING CHAR (6) AS Codret, 
		  CHAR(100) AS Descripcion,
		  CHAR(20) AS NumCliente,
		  CHAR(20) AS NumCredito,		  
		  CHAR(20) AS NumTarjeta,
		  DATE AS Fecha,
		  DECIMAL(20,2) AS MontoFinVenTrasp,
		  CHAR(2) AS CodStatusAct,
		  CHAR(60) AS DescStatusAct,
		  CHAR (2) AS CodStatusAnt,
		  CHAR(60) AS DescStatusAnt;

---Definicion de Variables          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(100);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE dtFechaCorte           DATE;
DEFINE dtFechaCorteAnt		 DATE;
DEFINE cNumCredito           CHAR(20);
DEFINE cNumTarjeta			 CHAR(20);
DEFINE cNumCte               CHAR(20);
DEFINE dtFecha                DATE;
DEFINE dMtoFinVenTrasp       DECIMAL(20,2);
DEFINE cStatusAct            CHAR(2);
DEFINE cDescStatusAct		 CHAR(60);
DEFINE cStatusAnt            CHAR(2);
DEFINE cDescStatusAnt		 CHAR(60);
DEFINE scont                 SMALLINT;
DEFINE dtFechaHoy 			 DATE;
DEFINE sMesHoy 				SMALLINT;
DEFINE sDiaHoy 				SMALLINT;
DEFINE sAnioHoy 			SMALLINT;


---Inicializaciones
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Credito Valido";
LET dtFechaCorte				 = MDY(1,1,1900);
LET dtFechaCorteAnt			 = MDY(1,1,1900);         
LET cNumCredito            	 = "";
LET cNumTarjeta            	 = "";
LET cNumCte            	     = "";
LET dtFecha                 	 = MDY(1,1,1900);
LET dMtoFinVenTrasp        	 = 0;
LET cStatusAct             	 = "";
LET cDescStatusAct		  	 = "";
LET cStatusAnt            	 = "";
LET cDescStatusAnt		 	 = "";
LET scont                    = 0;
LET dtFechaHoy				 = MDY(1,1,1900);
LET sMesHoy 				= 0;
LET sDiaHoy 				= 0;
LET sAnioHoy 				= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet,'','','','',0,'','','','';
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/sp_valida_numcredito.out';
--TRACE ON;

	--Validacion de parametros de entrada
	IF (pEmpresa='') OR (pFechaCorte='') OR (pNumCredito='') OR (pEmpresa IS NULL) OR (pFechaCorte IS NULL) OR (pNumCredito IS NULL) THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	ELSE		
		--Se obtienen las fechas de corte
		--LET dtFechaCorte=pFechaCorte;
		--LET dtFechaCorteAnt=mdy(MONTH(pFechaCorte),'20',YEAR(pFechaCorte)) - 1 units MONTH;
			
		-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ESTA VACIA';
	END IF
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	IF sDiaHoy < 20 THEN
	LET dtFechaCorte = dtFechaHoy - 1 units MONTH;
	LET dtFechaCorte = mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)); 
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	ELSE
	LET dtFechaCorte = mdy(MONTH(dtFechaHoy),'20',YEAR(dtFechaHoy));
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	END IF
		
		IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_muestra_edocta 
									WHERE num_credito = pNumCredito) THEN
									
			--Se consulta la información del cliente con el credito recibido.					
			SELECT a.num_credito,c.numcte,c.num_tarjeta, a.fecha, a.mto_fin_ven_trasp, 				 
			(CASE WHEN a.monto_vencido > 0 THEN 'BA' WHEN a.mto_venc_trasp > 0 THEN 'BT' WHEN a.sdo_capital = a.sdo_cap_insoluto THEN 'AA' END)estatus_actual,
			(CASE WHEN b.monto_vencido > 0 THEN 'BA' WHEN b.mto_venc_trasp > 0 THEN 'BT' WHEN b.sdo_capital = b.sdo_cap_insoluto THEN 'AA' END)estatus_anterior
			INTO cNumCredito,cNumCte,cNumTarjeta,dtFecha,dMtoFinVenTrasp,cStatusAct,cStatusAnt
			FROM bdicred:"informix".sd_maecred d, 
            bdicred:"informix".sd_maesdoshist a  , 
            bdicred:"informix".sd_tarjeta c, 
            bdicred:"informix".sd_maesdoshist b  
			WHERE d.empresa = '001' 
			AND d.num_credito = pNumCredito
			AND a.num_credito = d.num_credito				
			AND a.fecha=dtFechaCorte
			AND a.empresa = '001'
			AND a.empresa = c.empresa
			AND a.num_credito = c.num_credito
			AND c.secuencia = 
            (SELECT MAX(tar2.secuencia) 
                    FROM bdicred:"informix".sd_tarjeta tar2 
                    WHERE tar2.empresa = a.empresa
                    AND tar2.num_credito = a.num_credito AND tar2.tipo_tarjeta ='T')
			AND c.tipo_tarjeta ='T'
      		AND b.num_credito= d.num_credito
			AND b.empresa=c.empresa
			AND b.num_credito= c.num_credito
			AND b.fecha=dtFechaCorteAnt;
			
			LET scont = dbinfo("sqlca.sqlerrd2");
			IF scont = 0 THEN
				LET cCodRet= "000003";
				LET cMensajeRet= "Numero de Credito no valido";			
			END IF;
			---Se obtienen las descripciones de los estatus
			SELECT descripcion
			INTO cDescStatusAct
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAct;
			
			SELECT descripcion
			INTO cDescStatusAnt
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAnt;				
		ELSE 
			LET cCodRet = "000002";
			LET cMensajeRet="El credito ya existe como muestra para la fecha de corte";
		END IF;
	END IF;
	RETURN cCodRet, cMensajeRet,NVL(cNumCte,''),NVL(cNumCredito,''),NVL(cNumTarjeta,''),NVL(dtFecha,MDY(1,1,1900)),NVL(dMtoFinVenTrasp,0),NVL(cStatusAct,''),NVL(cDescStatusAct,''),NVL(cStatusAnt,''),NVL(cDescStatusAnt,'');
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para validar si existe el credito y obtener la información del cliente Titular del credito',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1030';

CREATE PROCEDURE "informix".calculamesiversario(diacorte INTEGER, fechatrab DATE, cantidad INTEGER, TpDiasFechaPago INTEGER)
     RETURNING
       CHAR(5)        AS Cod_Ret,
       DATE           AS fecha_mes;

     DEFINE d1            DATE;
     DEFINE cCodRet       CHAR(5);
     DEFINE FechaMes      DATE;
     DEFINE FechaAux      DATE;
     DEFINE ldiaMes       INTEGER;
     DEFINE d2            DATE;

    LET d1      = DATE(1);
    LET cCodRet ='00000';
    LET FechaMes = DATE(1);
    LET FechaAux = DATE(1);

  --  set debug file to "/pisa/cas/calculamesiversario.out";
  --  trace on;

    LET fechatrab = MDY(MONTH(fechatrab),'01',YEAR(fechatrab));

    if (TpDiasFechaPago = 2) then  -- indicador calculos quincenales
        if (diacorte <= 15) then
            CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
        else
            let FechaMes = fechatrab;
        end if;
    else
        CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
    end if;

    LET FechaAux = FechaMes;

    WHILE (day(FechaAux) <> diacorte and month(FechaAux) = month(FechaMes))
        LET FechaAux = FechaAux + 1;
    END WHILE

        IF month(FechaAux) <> month(FechaMes) THEN
           LET FechaAux = FechaAux - 1;
        END IF;

    CALL "informix".sp_valfechabil(FechaAux,'+') RETURNING cCodRet, FechaMes;

    RETURN cCodRet, FechaMes;

END PROCEDURE;
CREATE PROCEDURE "informix".sp_geninsumos_calif_reest()
RETURNING   CHAR(5), CHAR(100), char(60);

--Declaracion de variables.
DEFINE iSqlErr      					INTEGER;		DEFINE iIsamErr         				INTEGER;	
DEFINE cErrorInfo       				CHAR(100);		DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);	

DEFINE v_empresa                     	CHAR(3);		DEFINE pPeriodo              			DATE;	
DEFINE piniPeriodo						DATE;

DEFINE pIva                             DECIMAL(5,3);	DEFINE v_sucursal                       CHAR(4);
DEFINE v_antecedentes_buro             	CHAR(4);		DEFINE v_antiguedad_cliente          	INTEGER;
DEFINE v_atr                        	INTEGER;		DEFINE v_atr1                         	INTEGER;
DEFINE v_atr2                          	INTEGER;		DEFINE v_atr3                          	INTEGER;
DEFINE v_capital_exigible             	DECIMAL(18,2);	DEFINE v_cred_liquida_cred            	SMALLINT;
DEFINE v_cred_nomina                  	SMALLINT;		DEFINE v_grupo_originacion             	CHAR(2);
DEFINE v_delegada                    	SMALLINT;		DEFINE v_dias_atraso                   	SMALLINT;
DEFINE v_eficiencia                    	SMALLINT;		DEFINE v_facturacion                   	CHAR(2);
DEFINE v_fecha_apertura                	DATE;			DEFINE v_fecha_apertura_cte            	DATE;
DEFINE v_fecha_corte                   	DATE;			DEFINE v_fecha_vencimiento             	DATE;
DEFINE v_ingresos_mens_brutos          	DECIMAL(18,2);	DEFINE v_ingresos_mens_netos           	DECIMAL(18,2);
DEFINE v_int_mora_copete            	DECIMAL(18,2);	DEFINE v_int_mora_ordinario            	DECIMAL(18,2);
DEFINE v_interes_deven_ven_bal         	DECIMAL(18,2);	DEFINE v_interes_deven_vig_bal         	DECIMAL(18,2);
DEFINE v_interes_devengados_ord        	DECIMAL(18,2);	DEFINE v_interes_vencido_bal           	DECIMAL(18,2);
DEFINE v_interes_vencido_bal30         	DECIMAL(18,2);	DEFINE v_interes_vencido_ord           	DECIMAL(18,2);
DEFINE v_interes_vigente            	DECIMAL(18,2);	DEFINE v_iva_interes_vencido_bal       	DECIMAL(18,2);
DEFINE v_iva_interes_vencido_ord       	DECIMAL(18,2);	DEFINE v_iva_interes_vigente           	DECIMAL(18,2);
DEFINE v_linea_autorizada           	DECIMAL(18,2);	DEFINE v_max_atr                      	SMALLINT;
DEFINE v_antiguedad                   	INTEGER;		DEFINE v_monto_exigible               	DECIMAL(18,2);
DEFINE v_monto_exigible1              	DECIMAL(18,2);	DEFINE v_monto_exigible2              	DECIMAL(18,2);
DEFINE v_monto_exigible3              	DECIMAL(18,2);	DEFINE v_monto_exigible4              	DECIMAL(18,2);
DEFINE v_monto_exigible5              	DECIMAL(18,2);	DEFINE v_monto_exigible6              	DECIMAL(18,2);
DEFINE v_num_cliente                  	CHAR(20);		DEFINE v_num_credito                  	CHAR(20);
DEFINE v_num_disposiciones            	SMALLINT;		DEFINE v_num_producto                	CHAR(4);
DEFINE v_pago_capital                  	DECIMAL(18,2);	DEFINE v_pago_int_venc_bal           	DECIMAL(18,2);
DEFINE v_pago_int_venc_ord             	DECIMAL(18,2);	DEFINE v_pago_interes_vigente          	DECIMAL(18,2);
DEFINE v_pago_iva_int_venc_bal         	DECIMAL(18,2);	DEFINE v_pago_iva_int_venc_ord         	DECIMAL(18,2);
DEFINE v_pago_iva_interes_vigente      	DECIMAL(18,2);	DEFINE v_pago_realizado               	DECIMAL(18,2);
DEFINE v_pago_realizado1               	DECIMAL(18,2);	DEFINE v_pago_realizado2               	DECIMAL(18,2);
DEFINE v_pago_realizado3              	DECIMAL(18,2);	DEFINE v_pago_realizado4              	DECIMAL(18,2);
DEFINE v_pago_realizado5              	DECIMAL(18,2);	DEFINE v_pago_realizado6               	DECIMAL(18,2);
DEFINE v_periodos_incumplimiento    	DECIMAL(18,2);	DEFINE v_plazo_remanente            	DECIMAL(18,5);
DEFINE v_plazo_total                  	INTEGER;		DEFINE v_porcentaje_pago             	DECIMAL(18,2);
DEFINE v_porcentaje_uso               	DECIMAL(18,6);	DEFINE v_ree_tdc_anterior              	SMALLINT;
DEFINE v_saldo_cierre                 	DECIMAL(18,2);	DEFINE v_saldo_corte                   	DECIMAL(18,2);
DEFINE v_saldo_exigible              	DECIMAL(18,2);	DEFINE v_saldo_no_exigible             	DECIMAL(18,2);
DEFINE v_status_fin_mes               	CHAR(2);		DEFINE v_max_secuencia                  SMALLINT;
DEFINE v_num_cta                        CHAR(20);  		DEFINE v_antimaecred					INTEGER;		
DEFINE v_antimaecredcrd					INTEGER;		DEFINE v_fecha                  		DATE;

DEFINE v_capital_vigente    			DECIMAL(18,2);	DEFINE v_capital_vencido    			DECIMAL(18,2);
DEFINE v_int_vigente       				DECIMAL(18,2);	DEFINE v_iva_vigente        			DECIMAL(18,2);
DEFINE v_interes_orden      			DECIMAL(18,2);	DEFINE v_iva_interes_orden  			DECIMAL(18,2);

DEFINE v_capital_vigente1    			DECIMAL(18,2);	DEFINE v_capital_vencido1    			DECIMAL(18,2);
DEFINE v_int_vigente1        			DECIMAL(18,2);	DEFINE v_iva_vigente1        			DECIMAL(18,2);
DEFINE v_interes_orden1      			DECIMAL(18,2);	DEFINE v_iva_interes_orden1  			DECIMAL(18,2);

DEFINE v_capital_vigente2    			DECIMAL(18,2);	DEFINE v_capital_vencido2    			DECIMAL(18,2);
DEFINE v_int_vigente2        			DECIMAL(18,2);	DEFINE v_iva_vigente2        			DECIMAL(18,2);
DEFINE v_interes_orden2      			DECIMAL(18,2);	DEFINE v_iva_interes_orden2  			DECIMAL(18,2);

DEFINE v_capital_vigente3    			DECIMAL(18,2);	DEFINE v_capital_vencido3    			DECIMAL(18,2);
DEFINE v_int_vigente3        			DECIMAL(18,2);	DEFINE v_iva_vigente3        			DECIMAL(18,2);
DEFINE v_interes_orden3      			DECIMAL(18,2);	DEFINE v_iva_interes_orden3  			DECIMAL(18,2);
	
DEFINE v_capital_vigente4    			DECIMAL(18,2);	DEFINE v_capital_vencido4    			DECIMAL(18,2);
DEFINE v_int_vigente4        			DECIMAL(18,2);	DEFINE v_iva_vigente4        			DECIMAL(18,2);
DEFINE v_interes_orden4      			DECIMAL(18,2);	DEFINE v_iva_interes_orden4  			DECIMAL(18,2);

DEFINE v_capital_vigente5    			DECIMAL(18,2);	DEFINE v_capital_vencido5    			DECIMAL(18,2);
DEFINE v_int_vigente5        			DECIMAL(18,2);	DEFINE v_iva_vigente5        			DECIMAL(18,2);
DEFINE v_interes_orden5      			DECIMAL(18,2);	DEFINE v_iva_interes_orden5  			DECIMAL(18,2);
	
DEFINE v_capital_vigente6    			DECIMAL(18,2);	DEFINE v_capital_vencido6    			DECIMAL(18,2);
DEFINE v_int_vigente6        			DECIMAL(18,2);	DEFINE v_iva_vigente6        			DECIMAL(18,2);
DEFINE v_interes_orden6      			DECIMAL(18,2);	DEFINE v_iva_interes_orden6  			DECIMAL(18,2);
	
DEFINE v_prom1               			DECIMAL(18,10);	DEFINE v_prom2               			DECIMAL(18,10);
DEFINE v_prom3               			DECIMAL(18,10);	DEFINE v_prom4               			DECIMAL(18,10);
DEFINE v_prom5               			DECIMAL(18,2);	DEFINE v_prom6               			DECIMAL(18,2);
DEFINE v_prom7               			DECIMAL(18,2);	DEFINE dia_corte_ant         			SMALLINT;
DEFINE num_corte1            			CHAR(10);		DEFINE dFechaPer0                       DATE; 
DEFINE dFechaPer1                       DATE; 			DEFINE dFechaPer2                       DATE;
DEFINE dFechaPer3                       DATE; 			DEFINE dFechaPer4                       DATE; 
DEFINE dFechaPer5                       DATE; 			DEFINE dFechaPer6                       DATE; 
DEFINE dFechaPer7                       DATE; 			DEFINE dFechaPer8                       DATE; 
DEFINE dFechaPer9                       DATE;			DEFINE dFechaPer10                      DATE;
DEFINE dFechaPer11                      DATE;			DEFINE dFechaPer12                      DATE;
DEFINE dFechaPer13                      DATE;			DEFINe v_sdocap_insoluto_cierre			DECIMAL(18,2);

DEFINE dTotalVencido					DECIMAL(18,2);	DEFINE dVencidoOrden					DECIMAL(18,2);
DEFINE dInteresVencido					DECIMAL(18,2);	DEFINE dOtrasEstimaciones				DECIMAL(18,2);
DEFINE v_num_credito_ext				CHAR(20);		DEFINE v_comisiones						INTEGER;

DEFINE c_CodRet                         CHAR(5); 		DEFINE mMensaje                         VARCHAR(100,1); 
DEFINE v_dia_corte						INTEGER;		DEFINE flag_aniobis						INTEGER;
DEFINE v_fecha_corte_proc				DATE;			DEFINE v_fecha_corte_tdc				DATE;
DEFINE v_dia_corte_tdc					INTEGER;		DEFINE dt_ini_per_rep					DATE;
DEFINE v_interes_vencido_ord_corte		DECIMAL(18,2);	DEFINE v_saldo_insoluto_corte  			DECIMAL(18,2);
DEFINE v_pago_sostenido, v_cum_pago_sost INTEGER;	 	DEFINE dt_ultcons_varcc					DATE;
DEFINE v_cred_consulta 					VARCHAR(20);	DEFINE v_cred_respuesta  				VARCHAR(20);
DEFINE v_var_mtosdo 					CHAR(6);		DEFINE v_bkatr							INTEGER;
DEFINE v_mto_pagar_propios 				DECIMAL(18,2);	DEFINE v_mto_pagar_otros 				DECIMAL(18,2);
DEFINE v_mtovssdo_sic 					DECIMAL(18,2);	DEFINE v_sdo_actual_propio 				DECIMAL(18,2);
DEFINE v_sdo_actual_otros 				DECIMAL(18,2);	DEFINE v_sin_consulta					CHAR(1);
DEFINE v_consulta_sin_info				CHAR(1);		DEFINE v_bajo,v_medio, v_alto 			CHAR(1);
DEFINE v_mto_otros_vs_propios 			DECIMAL(18,2);	DEFINE v_sdo_sic 						DECIMAL(18,2);
DEFINE v_porcentaje_endeuda				DECIMAL(18,6);	DEFINE cMensajeRet2    	CHAR(60); --CJAC Cambiar longitud porcentaje_endeuda
DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22);
DEFINE c_evalua_cc				 CHAR(1);
DEFINE var_mto_fin_ven_trasp			INTEGER;		DEFINE var_mto_fin_ven_trasp2			INTEGER;
DEFINE cont_me INTEGER;
DEFINE contador_commit	 INTEGER;	DEFINE val_trans_Commit   SMALLINT;
DEFINE val_t1, val_t2,val_t3 SMALLINT;
DEFINE dt_ap_revolvente DATE;	DEFINE dt_ap_plazo     DATE;  DEFINE dt_ap_flex DATE;

--DEFINICION DE CAMPOS ADICIONALES
DEFINE v_comision_cobranza  DECIMAL(18,2);
DEFINE v_comision_exig_cobranza DECIMAL(18,2);
DEFINE v_fecha_apertura_format          CHAR(12);
DEFINE v_fecha_apertura_cte_format     	CHAR(12);
DEFINE v_fecha_corte_format            	CHAR(12);
DEFINE v_fecha_venc_format              CHAR(12);
--DEFINE v_plazo_contractual            	INTEGER;
DEFINE v_numero_cuenta_det              CHAR(20);
DEFINE v_antiguedad_inst                INTEGER;
DEFINE v_veces_ult_atr1d_todos          INTEGER;
DEFINE v_tasa_contractual               DECIMAL(18,7);
DEFINE v_cred_sit_especial INTEGER;
DEFINE v_num_pagos_vencidos INTEGER;
DEFINE v_etapa_cred CHAR(8);
DEFINE v_gastos_originacion DECIMAL(18,2);
DEFINE n_scoreotor				INTEGER;
DEFINE n_scoreburo				INTEGER;
DEFINE v_modelo_score   CHAR(6);
DEFINE v_capital_cierre	DECIMAL(18,2);
DEFINE v_periodo_rem_n  DECIMAL(18,6);
DEFINE v_tir_mensual DECIMAL(18,2);
DEFINE v_tasa_efectiva DECIMAL(18,5);
DEFINE v_interes_reee DECIMAL(18,2);
DEFINE v_antiguedad_bancos INTEGER;
DEFINE v_sdo_actual_propio_ship DECIMAL(18,2);
DEFINE v_num_credito_tdc CHAR(20);
DEFINE v_num_credito_visa CHAR(20);
DEFINE v_fecha_ult_pago DATE;
DEFINE v_intereses_etapa1 DECIMAL(18,2);
DEFINE v_intereses_etapa2 DECIMAL(18,2);
DEFINE v_tipogrupo CHAR(2);
DEFINE v_hit CHAR(6);
DEFINE v_codret CHAR(5);


	--variable sep
	DEFINE v_dias_rem_contractual DECIMAL(18,2);
	
	--variables dic-enero-cnbv
	DEFINE v_rfc CHAR(16); 
	
	DEFINE c_nombre1 VARCHAR (26);
	DEFINE c_nombre2 VARCHAR (26);	
	DEFINE c_ap_paterno VARCHAR (26);
	DEFINE c_ap_materno VARCHAR (26); 
	DEFINE c_nom_cte VARCHAR (107);
	
	
--INICIALIZACION DE VARIABLES
LET iSqlErr                         = 0;	  LET iIsamErr         				= 0;	LET cErrorInfo       				= "";
LET cCodRet          				= "00000";LET cMensajeRet  					= "Insumos Calificacion Reestructuras - OK";

LET v_empresa              			= '001';	LET v_sucursal                      ='';

LET v_antecedentes_buro             = "";	LET v_antiguedad_cliente          	= 0;	LET v_atr                        	= 0;
LET v_atr1                         	= 0;	LET v_atr2                          = 0;	LET v_atr3                          = 0;
LET v_capital_exigible             	= 0;	LET v_cred_liquida_cred            	= 0;	LET v_cred_nomina                  	= 0;
LET v_grupo_originacion             = "";	LET v_delegada                    	= 0;	LET v_dias_atraso                   = 0;
LET v_eficiencia                    = 0;	LET v_facturacion                   = "";	LET v_fecha_apertura                = DATE(1);
LET v_fecha_apertura_cte          = DATE(1);LET v_fecha_corte                   = DATE(1);LET v_fecha_vencimiento           = DATE(1);
LET v_ingresos_mens_brutos          = 0;	LET v_ingresos_mens_netos           = 0;	LET v_int_mora_copete            	= 0;
LET v_int_mora_ordinario            = 0;	LET v_interes_deven_ven_bal         = 0;	LET v_interes_deven_vig_bal         = 0;
LET v_interes_devengados_ord        = 0;	LET v_interes_vencido_bal           = 0;	LET v_interes_vencido_bal30           = 0;
LET v_interes_vencido_ord           = 0;	LET v_interes_vigente            	= 0;	LET v_iva_interes_vencido_bal       = 0;
LET v_iva_interes_vencido_ord       = 0;	LET v_iva_interes_vigente           = 0;	LET v_linea_autorizada           	= 0;
LET v_max_atr                      	= 0;	LET v_antiguedad                   	= 0;	LET v_monto_exigible               	= 0;
LET v_monto_exigible1              	= 0;	LET v_monto_exigible2              	= 0;	LET v_monto_exigible3              	= 0;
LET v_monto_exigible4              	= 0;	LET v_monto_exigible5              	= 0;	LET v_monto_exigible6              	= 0;
LET v_num_cliente                  	= "";	LET v_num_credito                  	= "";	LET v_num_disposiciones            	= 0;
LET v_num_producto                	= "";	LET v_pago_capital                  = 0;	LET v_pago_int_venc_bal           	= 0;
LET v_pago_int_venc_ord             = 0;	LET v_pago_interes_vigente          = 0;	LET v_pago_iva_int_venc_bal         = 0;
LET v_pago_iva_int_venc_ord         = 0;	LET v_pago_iva_interes_vigente      = 0;	LET v_pago_realizado               	= 0;
LET v_pago_realizado1               = 0;	LET v_pago_realizado2               = 0;	LET v_pago_realizado3              	= 0;
LET v_pago_realizado4              	= 0;	LET v_pago_realizado5              	= 0;	LET v_pago_realizado6               = 0;
LET v_periodos_incumplimiento    	= 0;	LET v_plazo_remanente            	= 0;	LET v_plazo_total                  	= 0;
LET v_porcentaje_pago             	= 0;	LET v_porcentaje_uso               	= 0;	LET v_ree_tdc_anterior              = 0;
LET v_saldo_cierre                 	= 0;	LET v_saldo_corte                   = 0;	LET v_saldo_exigible              	= 0;
LET v_saldo_no_exigible             = 0;	LET v_status_fin_mes               	= "";	LET v_max_secuencia                 = 0;
LET v_num_cta                       = ""; 	LET v_dia_corte						= 0;	LET v_antimaecred                   =0;
LET v_antimaecredcrd                =0;		LET v_fecha                         =DATE(1);LET dia_corte_ant                  =0;
LET num_corte1                      ='';

LET v_capital_vigente    			=0;		LET v_capital_vencido    			=0;		LET v_int_vigente        			=0;
LET v_iva_vigente        			=0;		LET v_interes_orden      			=0;		LET v_iva_interes_orden  			=0;

LET v_capital_vigente1    			=0;		LET v_capital_vencido1    			=0;		LET v_int_vigente1        			=0;
LET v_iva_vigente1        			=0;		LET v_interes_orden1      			=0;		LET v_iva_interes_orden1  			=0;

LET v_capital_vigente2    			=0;		LET v_capital_vencido2    			=0;		LET v_int_vigente2        			=0;
LET v_iva_vigente2        			=0;		LET v_interes_orden2      			=0;		LET v_iva_interes_orden2  			=0;

LET v_capital_vigente3    			=0;		LET v_capital_vencido3    			=0;		LET v_int_vigente3        			=0;
LET v_iva_vigente3        			=0;		LET v_interes_orden3      			=0;		LET v_iva_interes_orden3  			=0;

LET v_capital_vigente4    			=0;		LET v_capital_vencido4    			=0;		LET v_int_vigente4        			=0;
LET v_iva_vigente4        			=0;		LET v_interes_orden4      			=0;		LET v_iva_interes_orden4  			=0;
	
LET v_capital_vigente5    			=0;		LET v_capital_vencido5    			=0;		LET v_int_vigente5        			=0;
LET v_iva_vigente5        			=0;		LET v_interes_orden5      			=0;		LET v_iva_interes_orden5  			=0;

LET v_capital_vigente6    			=0;		LET v_capital_vencido6    			=0;		LET v_int_vigente6        			=0;
LET v_iva_vigente6        			=0;		LET v_interes_orden6      			=0;		LET v_iva_interes_orden6  			=0;

LET v_prom1               			=0;		LET v_prom2               			=0;		LET v_prom3               			=0;
LET v_prom4               			=0;		LET v_prom5               			=0;		LET v_prom6               			=0;
LET v_prom7               			=0;		

LET dFechaPer0                      =DATE(1);LET dFechaPer1                      =DATE(1);LET dFechaPer2                      =DATE(1);
LET dFechaPer3                      =DATE(1);LET dFechaPer4                      =DATE(1);LET dFechaPer5                      =DATE(1); 
LET dFechaPer6                      =DATE(1);LET dFechaPer7                      =DATE(1);LET dFechaPer8                      =DATE(1); 
LET dFechaPer9                      =DATE(1);LET dFechaPer10                     =DATE(1);LET dFechaPer11                     =DATE(1);
LET dFechaPer12                     =DATE(1);LET dFechaPer13                     =DATE(1);

LET dTotalVencido					=0;		LET dVencidoOrden					=0;		LET dInteresVencido					=0;
LET dOtrasEstimaciones				=0;		LET v_sdocap_insoluto_cierre		=0;		LET v_num_credito_ext				="";

LET c_CodRet                        =""; 	LET mMensaje                        ="";	LET v_interes_vencido_ord_corte     =0;
LET v_saldo_insoluto_corte			=0;		LET v_pago_sostenido 				=0;     LET v_cum_pago_sost 				=0;  
LET dt_ultcons_varcc				= date(1);LET  v_cred_consulta   			="";	LET  v_cred_respuesta  				="";
LET  v_var_mtosdo 					="";	LET  v_bkatr						=0;		LET  v_mto_pagar_propios 			=0;
LET  v_mto_pagar_otros 				= 0;	LET  v_mtovssdo_sic 				= 0;	LET  v_sdo_actual_propio 			=0;
LET  v_sdo_actual_otros 			= 0;	LET  v_sin_consulta					="";	LET  v_consulta_sin_info			="";
LET  v_alto 						="";	LET  v_bajo 						="";	LET  v_medio 						="";
LET  v_mto_otros_vs_propios 		= 0;	LET  v_sdo_sic 						= 0;	LET v_porcentaje_endeuda			=0;
LET c_evalua_cc						='';	LET var_mto_fin_ven_trasp			=0;		LET var_mto_fin_ven_trasp2			=0;
LET  cont_me = 0;
LET contador_commit = 	0;	LET val_trans_Commit = 	0;
LET val_t1 = 	0; LET  val_t2  = 	0; LET val_t3 = 	0;
LET dt_ap_revolvente 		= date(1);	LET dt_ap_plazo 			= date(1); 		LET dt_ap_flex = date(1);

--INICIALIZACION DE CAMPOS ADICIONALES
LET v_comision_cobranza = 0 ;
LET v_comision_exig_cobranza = 0;
LET v_fecha_apertura_format         = '';
LET v_fecha_apertura_cte_format     = '';
LET v_fecha_corte_format            = '';
LET v_fecha_venc_format             = '';
LET v_numero_cuenta_det             = '';
LET v_antiguedad_inst               = 0;
LET v_veces_ult_atr1d_todos         = 0;
LET v_tasa_contractual              = 0;
--LET v_plazo_contractual            	= 0;
LET v_cred_sit_especial = 0;
LET v_num_pagos_vencidos = 0;
LET v_etapa_cred = '';
LET v_gastos_originacion =0;
LET n_scoreotor	= 0;
LET n_scoreburo	= 0;
LET v_modelo_score ='';
LET v_capital_cierre = 0;
LET v_periodo_rem_n = 0;
LET v_tir_mensual = 0;
LET v_tasa_efectiva = 0;
LET v_interes_reee = 0;
LET v_num_credito_tdc ='';
LET v_num_credito_visa ='';
LET v_fecha_ult_pago = DATE(1);
LET v_intereses_etapa1 =0;
LET v_intereses_etapa2 =0;
LET v_codret = '';
LET v_tipogrupo = '';
LET v_hit = '';

--nuevo sep
	LET v_dias_rem_contractual = 0;
	
			--variables dic-enero-cnbv
	LET v_rfc = ''; 
	LET c_nombre1				= '';
	LET c_nombre2				='';		
	LET c_ap_paterno 			= '';		
	LET c_ap_materno    		='';
	LET c_nom_cte 				= '';
	
BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF val_t1 = 1 THEN
			drop table movs_pagos;
		END IF;	
	
		IF val_t1 = 1 THEN
			drop table movs_pagos_ext;
		END IF;	
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
	  	  LET cMensajeRet2 = '';
		IF (val_trans_Commit = -1) THEN
			rollback work;
		END IF;  
		  RETURN cCodRet,v_num_credito,cMensajeRet2;
    END EXCEPTION;

	--SET DEBUG FILE TO "/RESPALDOSNEW/SI1556/sp_geninsumos_calif_reest_v6.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;
	
SELECT  pri_dia_mes - 1 units day
INTO  pPeriodo
FROM sd_fechas
WHERE empresa='001';


--LET pPeriodo = mdy('11','30','2023');
LET piniPeriodo = mdy(month(pPeriodo),'01',year(pPeriodo));

--Reproceso 
--LET pPeriodo = mdy('02','28','2022');
--LET piniPeriodo = mdy('02','01','2022');
--Reproceso 

IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),4)) = 0 OR (mod(year(pPeriodo),4) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;


--Pagos desde el mes a procesar - 3 meses al mes a procesar  
select num_credito,fecha_mov,
sum(case when codigo_ref in (10,11,1106) then monto else 0 end) Capital_vigente,
sum(case when codigo_ref in (2,1108,1109,1118) then monto else 0 end) capital_transitorio,
--sum(case when codigo_ref in (1108,1109,1118) then monto else 0 end) capital_vencido,-- Nvo
sum(case when codigo_ref in (12,36) then monto else 0 end) capital_no_exigible,
sum(case when codigo_ref in  (9,1107) then monto else 0 end) capital_exigible,
sum(case when codigo_ref in (28,31,1110,1112,1114,1116) then monto else 0 end) int_Vigente,
sum(case when codigo_ref in (47,54,1111,1113,1115,1117) then monto else 0 end) iva_Vigente,
--sum(case when codigo_ref in (1112,1114,1116)  then monto else 0 end) int_devengado, --Nvo
--sum(case when codigo_ref in (1113,1115,1117)  then monto else 0 end) iva_int_devengado, --Nvo
sum(case when codigo_ref in (30,1119,1121,2,6709) then monto else 0 end) interes_orden,
sum(case when codigo_ref in (45,1120,1122,6616,6617,6652,3) then monto else 0 end) iva_interes_orden
from sd_movhiscrd 
where empresa = '001' 
and fecha_mov >= piniPeriodo - 3 units month and fecha_mov <= pPeriodo 
and num_credito in (SELECT num_credito FROM sd_maecredcontcrd    
					 WHERE fecha= pPeriodo
					 	AND empresa='001'
					   AND num_producto = '6011' 
					   AND num_credito > '' )
--AND num_credito in ('610000017646')	   --Filtro de cuentas para Pruebas
	   
and codigo_fun in (222, 225)--(select cod_fun from sd_conceptospagomanualcrd)
--and codigo_ref in (10,11,2,12,36,9,28,31,47,54,30,45)
and codigo_ref in (10,11,2,12,36,9,28,31,47,54,30,45,1106,1107,1108,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,2,6616,6617,6652,6709,3)
and reversado = 'N'
group by 1,2
into temp movs_pagos with no log; 

LET val_t1 = 1;

CREATE INDEX idx_pagos ON movs_pagos(fecha_mov, num_credito) ONLINE;

update statistics medium for table movs_pagos;

--Extrae base de movimientos  de cuentas externas
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from sd_movhis
where empresa = '001'
and fecha_mov >= (piniPeriodo - 3 units month) --mdy ('02','01','2018')
and fecha_mov <= pPeriodo        --mdy ('11','30','2018')
and num_credito in (SELECT credito_externo FROM sd_maecredcontcrd    
					 WHERE fecha= pPeriodo
					   AND num_producto = '6011' 
					   AND num_credito > '' 
				
					  -- AND num_credito in ('610000017646')	   --Filtro de cuentas para Pruebas
					   
					   AND fecha_apertura >= (pPeriodo - 4 units month) + 1 units day)
and codigo_fun in (select cod_fun from sd_conceptospagomanual)
--and codigo_ref in (7,10,901,8,5)  --,6640) iva_interes_vencido   --Se  comenta para traer unicamente los pagos completos solo codigo_ref = 1
and codigo_ref = 1
and reversado = 'N'
into temp movs_pagos_ext with no log;
LET val_t2= 1;
begin;
CREATE INDEX idx_movs_pagos_ext ON movs_pagos_ext(fecha_mov,num_credito) ONLINE;
commit;

update statistics medium for table movs_pagos_ext;

--Datos Fijos
SELECT MAX(fecha_info) 
INTO dt_ultcons_varcc
FROM bdiburo:br_variables_cc_cnr;

    FOREACH WITH HOLD

        SELECT a.num_credito, 	--53
        a.numcte ,				--52
		credito_externo,
        a.sucursal,
        a.num_producto,			--55
        a.periodo_plazo facturacion,	--18
        a.fecha_apertura,	--19
        TO_CHAR(a.fecha_apertura, '%Y/%m/%d') as fecha_apertura_format,
        a.fecha_vencim,	--22
        TO_CHAR(a.fecha_vencim, '%Y/%m/%d') as fecha_venc_format,
		e.dia_corte, 
		--mdy(month(pPeriodo),(e.dia_corte),year(pPeriodo))  fecha_corte,	--21
		--CASE WHEN month(a.fecha_apertura)=month(pPeriodo) and year(a.fecha_apertura)=year(pPeriodo) THEN a.fecha_apertura ELSE mdy(month(pPeriodo),(e.dia_corte),year(pPeriodo)) END fecha_corte,
		CASE WHEN a.fecha_apertura >= piniPeriodo and a.fecha_apertura<= pPeriodo THEN a.fecha_apertura ELSE mdy(month(pPeriodo),(e.dia_corte),year(pPeriodo)) END fecha_corte,
        a.status_cred status_fin_mes,	--83
         c.dias_atraso,		--16
        b.sdo_moratorio int_mora_copete,	--25
        b.sdo_contab_mora int_mora_ordinario,--26
        b.monto_otorgado linea_autorizada,	--36
        --ROUND((b.sdo_cap_insoluto / b.monto_otorgado),2)porcentaje_uso,	--75
        CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_total,--72
        --CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_contractual,
		round((fecha_vencim -a.fecha)/ 365.25,5) plazo_remanente,
        --CASE WHEN round((fecha_vencim -a.fecha)/ 365.25,5) <= 0 THEN 0 ELSE round((fecha_vencim -a.fecha)/ 365.25,5) END plazo_remanente,
        --CASE WHEN round((fecha_vencim -a.fecha)/ 30.4,2) <= 0 THEN 0 ELSE round((fecha_vencim -a.fecha)/ 30.4,2) END plazo_remanente,	--71
		--b.sdo_cap_insoluto + nvl(intereses_vencidos,0) saldo_cierre,	--77 // Se quitan fala calcular el interes vencido, se tomaba de la hist_reserva		b.monto_financiado + b.int_tra_no_exig + b.mto_venc_int + b.sdo_no_exig + b.mto_finan_vdo Exigible, --79
		b.sdo_cap_insoluto  saldo_insoluto_cierre,
        a.tasa_interes, b.mto_fin_ven_trasp,c.fecha_ultimo_pago_h, a.status_cred
        INTO v_num_credito,v_num_cliente,v_num_credito_ext,v_sucursal,v_num_producto,v_facturacion,v_fecha_apertura,v_fecha_apertura_format,
        v_fecha_vencimiento,v_fecha_venc_format,v_dia_corte,v_fecha_corte,v_status_fin_mes,v_dias_atraso,v_int_mora_copete,v_int_mora_ordinario,
        v_linea_autorizada,v_plazo_total,v_plazo_remanente,v_sdocap_insoluto_cierre, v_tasa_contractual,v_num_pagos_vencidos,v_fecha_ult_pago, v_etapa_cred
        FROM sd_maecredcontcrd a 
        INNER JOIN sd_maesdoscontcrd b 
        ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) 
        LEFT JOIN sd_indicador_cred_crd c
        --ON (a.empresa = c.empresa and c.fecha_insert = a.fecha and a.num_credito = c.num_credito)  --IPCB para historica
		ON (a.empresa = c.empresa and a.num_credito = c.num_credito)  --IPCB Se cambia a la operativa
        INNER JOIN sd_maecredanexocrd e 
        ON (a.empresa = e.empresa and a.num_credito = e.num_credito)
        LEFT JOIN bdisolic:ss_revision_determinacion f
        ON (a.empresa=f.empresa and a.num_credito=f.num_solicitud and a.numcte=f.numcte)
        WHERE a.fecha= pPeriodo
		  AND a.fecha=b.fecha
          AND a.num_producto = '6011' 
		  AND a.num_credito > '' 
		  AND a.num_credito NOT IN (select num_credito from sd_insumos_calif_reest where fecha_cierre = pPeriodo)
		  --Filtro de cuentas para Pruebas
     -- and a.num_credito in ('610000017646')
	  
	  
		
		
		
		
	    IF (val_trans_Commit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET val_trans_Commit = -1;
        END IF; 
		
		IF v_fecha_ult_pago IS NULL THEN
			select fecha_ult_pago INTO v_fecha_ult_pago
			from sd_maecredanexocrd where num_credito= v_num_credito;		
		END IF;
		
		IF month(v_fecha_corte) = 1 AND day(v_fecha_corte) = 2 THEN
			LET v_fecha_corte_proc = v_fecha_corte - 2 units day;		
		ELSE
			LET v_fecha_corte_proc = v_fecha_corte - 1 units day;		
		END IF
		
		LET v_comisiones		= 0;	--10
		LET v_cred_liquida_cred = 0;	--12
		LET v_delegada 			= 0;	--15	
		LET v_num_disposiciones = 1;	--54
		
		--Campo 2,14 y 17
		SELECT evalua_cc antecedentes_buro,	NVL(grupo,'') grupo_originacion, nvl(situacion_pago,0) eficiencia
		  INTO c_evalua_cc,v_grupo_originacion,v_eficiencia
		FROM bdisolic:ss_resum_scor_fin
		WHERE empresa=v_empresa and num_solicitud=v_num_credito_ext;

		IF NVL(v_grupo_originacion,'')='' THEN
			EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo_cons(v_num_credito_ext)
			INTO v_codret,v_tipogrupo,v_hit;
			
			LET v_grupo_originacion=v_tipogrupo;
		END IF;
		
		--Validar cuando son buenos y malos	
		IF c_evalua_cc = '0' THEN
			LET v_antecedentes_buro = 'BUEN';
		ELIF c_evalua_cc = 'X' OR  c_evalua_cc is null THEN	
			LET v_antecedentes_buro = '';
		ELSE  --ELIF c_evalua_cc >= '1' THEN
			LET v_antecedentes_buro = 'MAL';	
		END IF;	
		
		---LET v_antecedentes_buro=c_evalua_cc;
		
		--Campo 13 y 76
		IF  v_num_producto = '6400' THEN
			LET v_cred_nomina =	1;
			LET v_ree_tdc_anterior = 0;
		ELIF  v_num_producto = '6011' THEN
			LET v_cred_nomina =	0;			
			LET v_ree_tdc_anterior = 1;
		ELSE 
			LET v_cred_nomina =	0;
			LET v_ree_tdc_anterior = 0;
		END IF;	
	
		--Campo 40
		LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));		
		
        LET v_monto_exigible               	= 0;
        LET v_monto_exigible1              	= 0;
        LET v_monto_exigible2              	= 0;
        LET v_monto_exigible3              	= 0;
        LET v_monto_exigible4              	= 0;
        LET v_monto_exigible5              	= 0;
        LET v_monto_exigible6              	= 0;

        LET v_pago_realizado               	= 0;
        LET v_pago_realizado1               = 0;
        LET v_pago_realizado2               = 0;
        LET v_pago_realizado3              	= 0;
        LET v_pago_realizado4              	= 0;
        LET v_pago_realizado5              	= 0;
        LET v_pago_realizado6               = 0;

        LET v_prom1               =0;
        LET v_prom2               =0;
        LET v_prom3               =0;
        LET v_prom4               =0;
        LET v_prom5               =0;
        LET v_prom6               =0;
        LET v_prom7               =0;

        LET v_atr                        	= 0;
        LET v_atr1                         	= 0;
        LET v_atr2                          = 0;
        LET v_atr3                          = 0;
        LET v_max_atr                      	= 0;
        
        LET v_capital_vigente    =0;
        LET v_capital_vencido    =0;
        LET v_int_vigente        =0;
        LET v_iva_vigente        =0;
        LET v_interes_orden      =0;
        LET v_iva_interes_orden  =0;

        LET v_capital_vigente1    =0;
        LET v_capital_vencido1    =0;
        LET v_int_vigente1        =0;
        LET v_iva_vigente1        =0;
        LET v_interes_orden1      =0;
        LET v_iva_interes_orden1  =0;

        LET v_capital_vigente2    =0;
        LET v_capital_vencido2    =0;
        LET v_int_vigente2        =0;
        LET v_iva_vigente2        =0;
        LET v_interes_orden2      =0;
        LET v_iva_interes_orden2  =0;

        LET v_capital_vigente3    =0;
        LET v_capital_vencido3    =0;
        LET v_int_vigente3        =0;
        LET v_iva_vigente3        =0;
        LET v_interes_orden3      =0;
        LET v_iva_interes_orden3  =0;

        LET v_capital_vigente4    =0;
        LET v_capital_vencido4    =0;
        LET v_int_vigente4        =0;
        LET v_iva_vigente4        =0;
        LET v_interes_orden4      =0;
        LET v_iva_interes_orden4  =0;

        LET v_capital_vigente5    =0;
        LET v_capital_vencido5    =0;
        LET v_int_vigente5        =0;
        LET v_iva_vigente5        =0;
        LET v_interes_orden5      =0;
        LET v_iva_interes_orden5  =0;

        LET v_capital_vigente6    =0;
        LET v_capital_vencido6    =0;
        LET v_int_vigente6        =0;
        LET v_iva_vigente6        =0;
        LET v_interes_orden6      =0;
        LET v_iva_interes_orden6  =0;
		
		LET v_dia_corte_tdc 	  =0;
        LET v_interes_vencido_ord_corte     =0;
		LET v_saldo_insoluto_corte			=0;
		LET v_pago_sostenido 				=0;     
		LET v_cum_pago_sost 				=0;  
		
		LET var_mto_fin_ven_trasp	=0;
		LET var_mto_fin_ven_trasp2			=0;
		LET v_porcentaje_pago             	= 0;
		LET v_porcentaje_uso               	= 0;
		LET  cont_me = 0;
            --FOREACH WITH HOLD
 			    --CAMPO 20 fecha_apertura_cte --Bloque que incluye 
                /*SELECT min(mdy(month(fecha_apertura),day(fecha_apertura),year(fecha_apertura))) INTO v_fecha_apertura_cte 
				FROM (SELECT min(fecha_apertura)fecha_apertura
					  FROM sd_maecred WHERE numcte=v_num_cliente   --Tarjetas
					union all
					  SELECT min(fecha_apertura)fecha_apertura		
					  FROM sd_maecredcrd WHERE numcte=v_num_cliente AND num_producto <> '6800'  --Prestamos y nomina
					union all
					  SELECT min(fecha_otorga) fecha_apertura
                      FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
															       WHERE numcte = v_num_cliente AND num_producto = '6800'));  --Flexibles	*/
																   
				--Fec_apertura_revolvente
				SELECT NVL(min(fecha_apertura),mdy('12','31','4000')) INTO dt_ap_revolvente
				FROM sd_maecred WHERE numcte=v_num_cliente;   
				--Fec_apertura_Prestamos y nomina
				SELECT NVL(min(fecha_apertura),mdy('12','31','4000')) INTO dt_ap_plazo		
				FROM sd_maecredcrd WHERE numcte=v_num_cliente AND num_producto <> '6800';
				--Fec_apertura_Flexibles
				SELECT NVL(min(fecha_otorga),mdy('12','31','4000'))  INTO dt_ap_flex
				FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
															WHERE numcte = v_num_cliente AND num_producto = '6800');
															
				IF dt_ap_revolvente <= dt_ap_plazo AND dt_ap_revolvente <= dt_ap_flex THEN
					LET v_fecha_apertura_cte = dt_ap_revolvente;
				ELIF  dt_ap_plazo <= dt_ap_revolvente AND dt_ap_plazo <= dt_ap_flex THEN
					LET v_fecha_apertura_cte = dt_ap_plazo;
				ELIF dt_ap_flex <= dt_ap_revolvente AND dt_ap_flex <= dt_ap_plazo THEN
					LET v_fecha_apertura_cte= dt_ap_flex;
				END IF;	
				
                --CAMPO 3 antiguedad_cliente   
				LET v_antiguedad_cliente = (year(pPeriodo) - year(v_fecha_apertura_cte)) * 12 + (month(pPeriodo) - month(v_fecha_apertura_cte));
				
				--CAMPOS 4, 5, 6 y 7			 
				--IF v_status_fin_mes='BA' OR v_status_fin_mes='BT' OR v_status_fin_mes='VP' THEN
					IF v_antiguedad  = 0 THEN	
						LET v_atr=0;
						
						SELECT nvl(act,0) 
						INTO v_atr1
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha= (piniPeriodo -1 units day);  --31/05/2018	
					
						SELECT nvl(act,0) 
						INTO v_atr2
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018		

						SELECT nvl(act,0) 
						INTO v_atr3
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018		
					
					ELIF v_antiguedad  = 1 THEN	
						SELECT nvl(atr,0) 
						INTO v_atr
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						--AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
						AND fecha= pPeriodo;  --30/06/2018
						
						SELECT nvl(atr,0) 
						INTO v_atr1
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						AND fecha= (piniPeriodo -1 units day);  --31/05/2018
					
						SELECT nvl(act,0) 
						INTO v_atr2
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018		

						SELECT nvl(act,0) 
						INTO v_atr3
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018		
						
					ELIF v_antiguedad  = 2 THEN	
						SELECT nvl(atr,0) 
						INTO v_atr
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						--AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
						AND fecha= pPeriodo;  --30/06/2018
						
						SELECT nvl(atr,0) 
						INTO v_atr1
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						AND fecha= (piniPeriodo -1 units day);  --31/05/2018

						SELECT nvl(atr,0)  
						INTO v_atr2
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018					
						
						SELECT nvl(act,0) 
						INTO v_atr3
						FROM sd_maesdoscont
						WHERE num_credito =v_num_credito_ext
						AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018		
					ELSE
						--IF v_fecha_vencimiento >= pPeriodo THEN --Si no ha llegado a su fecha de vencimiento
							SELECT nvl(atr,0) 
							INTO v_atr
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= pPeriodo;  --30/06/2018
							
							SELECT nvl(atr,0) 
							INTO v_atr1
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= (piniPeriodo -1 units day);  --31/05/2018

							SELECT nvl(atr,0)  
							INTO v_atr2
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018
						
							SELECT nvl(atr,0) 
							INTO v_atr3
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018
						/*ELSE --Si ya llego a su fecha de vencimiento
							SELECT nvl(mto_fin_ven_trasp,0) 
							INTO var_mto_fin_ven_trasp  
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito						
							AND fecha= pPeriodo; 
											
							IF month(v_fecha_vencimiento) in (1,3,5,7,8,10,12 ) THEN							
								LET v_fecha =  mdy(month(v_fecha_vencimiento),'31',year(v_fecha_vencimiento));
							ELIF month(v_fecha_vencimiento) in (4,6,9,11 ) THEN
								LET v_fecha =  mdy(month(v_fecha_vencimiento),'30',year(v_fecha_vencimiento));
							ELIF month(v_fecha_vencimiento) = 2 THEN
							--Valida Anio Bisiesto de la v_fecha_vencimiento
							    IF mod(year(v_fecha_vencimiento),4) = 0 AND ((mod(year(v_fecha_vencimiento),100)) <> 0 OR (mod(year(v_fecha_vencimiento),400) = 0)) THEN								
									LET v_fecha =  mdy(month(v_fecha_vencimiento),'29',year(v_fecha_vencimiento));								
								ELSE
									LET v_fecha =  mdy(month(v_fecha_vencimiento),'28',year(v_fecha_vencimiento));
								END IF
							END IF;
												
							SELECT (year(pPeriodo+1 units month) - year(v_fecha)) * 12 +  ( month(pPeriodo+1 units month) - month(v_fecha))
							INTO var_mto_fin_ven_trasp2
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= pPeriodo; --Mes cerrado a 30/06/2018
						
							LET v_atr  = ( var_mto_fin_ven_trasp2 +(var_mto_fin_ven_trasp-1));
						
							LET v_atr1 = v_atr -1;
							IF v_atr1 < 0 THEN
								SELECT nvl(mto_fin_ven_trasp,0) 
								INTO v_atr1
								FROM sd_maesdoscontcrd 
								WHERE num_credito =v_num_credito
								AND fecha= (piniPeriodo -1 units day);  --31/05/2018
							END IF;
						
							LET v_atr2 = v_atr1 -1;
							IF v_atr2 < 0 THEN
								SELECT nvl(mto_fin_ven_trasp,0)  
								INTO v_atr2
								FROM sd_maesdoscontcrd 
								WHERE num_credito =v_num_credito
								AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018
							END IF;
						
							LET v_atr3 = v_atr2 -1;
							IF v_atr3 < 0 THEN
								SELECT nvl(mto_fin_ven_trasp,0) 
								INTO v_atr3
								FROM sd_maesdoscontcrd 
								WHERE num_credito =v_num_credito
								AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018
							END IF;
						END IF;	*/
					END IF;
				--ELSE
				--	LET v_atr=0;
				 /* LET v_atr1=0;
                    LET v_atr2=0;
                    LET v_atr3=0;*/	--IPCB Se corrige bloque ya que si es AA actualmente no sabemos como estuvo previamente.
				/*    SELECT nvl(mto_fin_ven_trasp,0) 
					INTO v_atr1
					FROM sd_maesdoscontcrd 
					WHERE num_credito =v_num_credito
					AND fecha= (piniPeriodo -1 units day);  --31/05/2018

					SELECT nvl(mto_fin_ven_trasp,0)  
					INTO v_atr2
					FROM sd_maesdoscontcrd 
					WHERE num_credito =v_num_credito
					AND fecha= (piniPeriodo -1 units month ) - 1 units day; --30/04/2018
				
					SELECT nvl(mto_fin_ven_trasp,0) 
					INTO v_atr3
					FROM sd_maesdoscontcrd 
					WHERE num_credito =v_num_credito
					AND fecha=(piniPeriodo -2units month ) - 1 units day;  --31/03/2018	
				END IF;*/
				
				
				--num_pagos_vencidos
				IF v_status_fin_mes='BA' OR v_status_fin_mes='BT' or ((v_status_fin_mes='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) OR v_status_fin_mes='VP' THEN
					IF v_antiguedad  = 0 THEN	
						LET v_num_pagos_vencidos=0;
						
					ELIF v_antiguedad  = 1 THEN	
						SELECT nvl(mto_fin_ven_trasp,0) 
						INTO v_num_pagos_vencidos
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						--AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
						AND fecha= pPeriodo;  --30/06/2018
						
					ELIF v_antiguedad  = 2 THEN	
						SELECT nvl(mto_fin_ven_trasp,0) 
						INTO v_num_pagos_vencidos
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						--AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
						AND fecha= pPeriodo;  --30/06/2018
								
					ELSE
						IF v_fecha_vencimiento >= pPeriodo THEN --Si no ha llegado a su fecha de vencimiento
							SELECT nvl(mto_fin_ven_trasp,0) 
							INTO v_num_pagos_vencidos
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= pPeriodo;  --30/06/2018
							
						ELSE --Si ya llego a su fecha de vencimiento
							SELECT nvl(mto_fin_ven_trasp,0) 
							INTO var_mto_fin_ven_trasp  
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito						
							AND fecha= pPeriodo; 
											
							IF month(v_fecha_vencimiento) in (1,3,5,7,8,10,12 ) THEN							
								LET v_fecha =  mdy(month(v_fecha_vencimiento),'31',year(v_fecha_vencimiento));
							ELIF month(v_fecha_vencimiento) in (4,6,9,11 ) THEN
								LET v_fecha =  mdy(month(v_fecha_vencimiento),'30',year(v_fecha_vencimiento));
							ELIF month(v_fecha_vencimiento) = 2 THEN
							--Valida Anio Bisiesto de la v_fecha_vencimiento
							    IF mod(year(v_fecha_vencimiento),4) = 0 AND ((mod(year(v_fecha_vencimiento),100)) <> 0 OR (mod(year(v_fecha_vencimiento),400) = 0)) THEN								
									LET v_fecha =  mdy(month(v_fecha_vencimiento),'29',year(v_fecha_vencimiento));								
								ELSE
									LET v_fecha =  mdy(month(v_fecha_vencimiento),'28',year(v_fecha_vencimiento));
								END IF
							END IF;
												
							SELECT (year(pPeriodo+1 units month) - year(v_fecha)) * 12 +  ( month(pPeriodo+1 units month) - month(v_fecha))
							INTO var_mto_fin_ven_trasp2
							FROM sd_maesdoscontcrd 
							WHERE num_credito =v_num_credito
							AND fecha= pPeriodo; --Mes cerrado a 30/06/2018
						
							LET v_num_pagos_vencidos  = ( var_mto_fin_ven_trasp2 +(var_mto_fin_ven_trasp-1));
						
						END IF;	
					END IF;
				ELSE
					LET v_num_pagos_vencidos=0;
				END IF;  ---aqui termina num_pagos_vencidos
				
                --CAMPO 9 CAPITAL EXIGIBLE
                SELECT nvl(monto_financiado,0) INTO v_capital_exigible
                FROM sd_maesdoshistcrd 
                WHERE fecha = v_fecha_corte_proc and num_credito =v_num_credito;
				
                --CAMPO 23 ingresos_mens_brutos
                SELECT NVL(ingreso_mensual,0) INTO v_ingresos_mens_brutos
                FROM bdinteg:si_ingresos 
                WHERE numcte =v_num_cliente and sec_ingreso=(select max(sec_ingreso) FROM bdinteg:si_ingresos 
                WHERE fecha_insert <= pPeriodo AND numcte =v_num_cliente);  --IPCB 07/11/2018 --Se agrega la condicion de la fecha para poder amarrar el ingreso bruto a maximo la fecha del cirre procesado
				                
				--CAMPO 24,27,30,33,34, 35
				 LET v_ingresos_mens_netos = v_ingresos_mens_brutos;
				 LET v_interes_deven_ven_bal =0;
				 LET v_interes_vencido_bal = 0;
				 LET v_iva_interes_vencido_bal = 0;
				 LET v_iva_interes_vencido_ord = 0;
				 LET v_iva_interes_vigente = 0;
				 
				--CAMPO 28 y 29
				IF v_status_fin_mes in ('AA','BA') or ((v_status_fin_mes in ('E1') AND v_atr=0 and v_dias_atraso=0) or (v_status_fin_mes in ('E1') AND v_atr=1 and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90))) THEN
					SELECT sdo_intereses  INTO v_interes_deven_vig_bal
					  FROM sd_maesdoscont 
					 WHERE  fecha = pPeriodo
					   AND  num_Credito = v_num_credito;
					   
					LET v_interes_devengados_ord = 0;   				
				ELSE
					SELECT sdo_intereses  INTO v_interes_devengados_ord
					  FROM sd_maesdoscont 
					 WHERE  fecha = pPeriodo
					   AND  num_Credito = v_num_credito;
					   
					LET v_interes_deven_vig_bal = 0;   								
				END IF;
				
				--CAMPO 31 y 32			
				IF MONTH(pPeriodo) in (1,3,5,7,8,10,12) THEN
					SELECT intvenc31,intvig31
					INTO v_interes_vencido_ord,v_interes_vigente
					FROM sd_sdodiariocrd
					WHERE num_credito=v_num_credito and fecha=piniPeriodo;				
				ELIF MONTH(pPeriodo) in (4,6,9,11) THEN
					SELECT intvenc30,intvig30
					INTO v_interes_vencido_ord,v_interes_vigente
					FROM sd_sdodiariocrd
					WHERE num_credito=v_num_credito and fecha=piniPeriodo;	
				ELSE
					IF flag_aniobis = 1 THEN
						SELECT intvenc29,intvig29
						INTO v_interes_vencido_ord,v_interes_vigente
						FROM sd_sdodiariocrd
						WHERE num_credito=v_num_credito and fecha=piniPeriodo;	
                    ELSE
						SELECT intvenc28,intvig28
						INTO v_interes_vencido_ord,v_interes_vigente
						FROM sd_sdodiariocrd
						WHERE num_credito=v_num_credito and fecha=piniPeriodo;						
					END IF;
				END IF;
				
                --CAMPO 37 max_atr
                IF nvl(v_atr,0) >= nvl(v_atr1,0) and nvl(v_atr,0) >= nvl(v_atr2,0) and nvl(v_atr,0) >= nvl(v_atr3,0) then 
                    LET v_max_atr=nvl(v_atr,0);
                ELIF nvl(v_atr1,0)>=nvl(v_atr,0) and nvl(v_atr1,0)>=nvl(v_atr2,0) and nvl(v_atr1,0)>=nvl(v_atr3,0) then
                    LET v_max_atr= nvl(v_atr1,0);
                ELIF nvl(v_atr2,0)>=nvl(v_atr,0) and nvl(v_atr2,0)>=nvl(v_atr1,0) and nvl(v_atr2,0)>=nvl(v_atr3,0) then
                    LET v_max_atr= nvl(v_atr2,0);  
                ELIF nvl(v_atr3,0)>=nvl(v_atr,0) and nvl(v_atr3,0)>=nvl(v_atr1,0) and nvl(v_atr3,0)>=nvl(v_atr2,0) then
                    LET v_max_atr= nvl(v_atr3,0);
                ELIF v_atr = nvl(v_atr1,0) and nvl(v_atr,0) = nvl(v_atr2,0) and nvl(v_atr,0) = nvl(v_atr3,0) then 
                    LET v_max_atr= nvl(v_atr,0);
                END IF; 
				
				-- MONTOS EXIGIBLES
				IF v_antiguedad  <= 2 THEN
					 SELECT mdy(month(pPeriodo),dia_corte,year(pPeriodo))
					 INTO v_fecha_corte_tdc
					 FROM sd_maecredanexo
					 WHERE empresa = v_empresa 
					 and num_Credito = v_num_credito_ext;
				END IF;
				
				IF v_antiguedad  = 0 THEN	
				    --CAMPO 41 MONTO EXIGIBLE		--REEST
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=v_fecha_corte_proc; 
					
					IF v_monto_exigible = 0 OR v_monto_exigible IS NULL THEN
						SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
						INTO v_monto_exigible
						FROM sd_maesdoshist
						WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc; 
					END IF;

					--CAMPO 42 MONTO EXIGIBLE1		--TDC
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible1
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 1 units month; 	
					
					--CAMPO 43 MONTO EXIGIBLE2 		--TDC
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible2
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 2 units month; 	
					
					--CAMPO 44 MONTO EXIGIBLE3		--TDC
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible3
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 3 units month;  	
				ELIF v_antiguedad  = 1 THEN					
					  --CAMPO 41 MONTO EXIGIBLE		--REEST		
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=v_fecha_corte_proc; 
					
					--CAMPO 42 MONTO EXIGIBLE1		--REEST
					IF month(v_fecha_corte - 1 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = v_fecha_corte - 1 units day;		
					END IF;
					
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible1
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer1; 
					
					--CAMPO 43 MONTO EXIGIBLE2		--TDC 
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible2
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 2 units month; 	
					
					--CAMPO 44 MONTO EXIGIBLE3		--TDC
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible3
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 3 units month;					
				ELIF v_antiguedad  = 2 THEN	
				    --CAMPO 41 MONTO EXIGIBLE		--REEST		
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=v_fecha_corte_proc; 
					
					--CAMPO 42 MONTO EXIGIBLE1		--REEST
					IF month(v_fecha_corte - 1 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = v_fecha_corte - 1 units day;		
					END IF;
					
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible1
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer1; 				
					
					--CAMPO 43 MONTO EXIGIBLE2		--REEST
					IF month(v_fecha_corte - 2 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer2 = v_fecha_corte - 2 units month; 
						LET dFechaPer2 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer2 = v_fecha_corte - 2 units month; 
						LET dFechaPer2 = v_fecha_corte - 1 units day;		
					END IF;
					
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible2
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer2; 	
									
					--CAMPO 44 MONTO EXIGIBLE3		--TDC
					--SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0) --Sin moratorios
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)+ (sdo_contab_mora + sdo_moratorio)+  round((sdo_contab_mora + sdo_moratorio)*.16,2) --Con moratorios
					INTO v_monto_exigible3
					FROM sd_maesdoshist
					WHERE num_credito =v_num_credito_ext and fecha=v_fecha_corte_tdc - 3 units month;	
				ELSE
				    --CAMPO 41 MONTO EXIGIBLE		--REEST		
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=v_fecha_corte_proc; 
					
					--CAMPO 42 MONTO EXIGIBLE1		--REEST
					IF month(v_fecha_corte - 1 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer1 = v_fecha_corte - 1 units month; 
						LET dFechaPer1 = dFechaPer1 - 1 units day;		
					END IF;
					
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible1
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer1; 				
					
					--CAMPO 43 MONTO EXIGIBLE2		--REEST
					IF month(v_fecha_corte - 2 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer2 = v_fecha_corte - 2 units month; 
						LET dFechaPer2 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer2 = v_fecha_corte - 2 units month; 
						LET dFechaPer2 = dFechaPer2 - 1 units day;		
					END IF;
					
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible2
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer2; 	
					
					--CAMPO 44 MONTO EXIGIBLE3		--REEST
					IF month(v_fecha_corte - 3 units month) = 1 AND day(v_fecha_corte) = 2 THEN
						LET dFechaPer3 = v_fecha_corte - 2 units month; 
						LET dFechaPer3 = dFechaPer1 - 2 units day;		
					ELSE
						LET dFechaPer3 = v_fecha_corte - 3 units month; 
						LET dFechaPer3 = dFechaPer3 - 1 units day;		
					END IF;
					
					SELECT NVL(monto_financiado,0) + NVL(int_tra_no_exig,0) + NVL(mto_venc_int,0) + NVL(sdo_no_exig,0) + NVL(mto_finan_vdo,0)
					INTO v_monto_exigible3
					FROM sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=dFechaPer3; 					
				END IF;					
				
                --CAMPO 45, 46, 47 MONTO EXIGIBLE4,EXIGIBLE5,EXIGIBLE6 -- PAra los productos quincenales	
				LET v_monto_exigible4 = 0;
				LET v_monto_exigible5 = 0;
				LET v_monto_exigible6 = 0;
				
				--PAGOS CAMPOS 56,57,58,59,60,61,62,63,64,65,66,67,68,69
                --Pagos del mes				
				LET v_fecha = (v_fecha_corte - 1 units month)+1 units day;
				--56 a 63
				SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0))),SUM(NVL(int_vigente,0)),sum(NVL(iva_vigente,0)),sum(NVL(interes_orden,0)),SUM(NVL(iva_interes_orden,0))
				  INTO v_pago_capital, v_int_vigente,v_iva_vigente,v_interes_orden,v_iva_interes_orden
				FROM movs_pagos 
				WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte
				and num_Credito = v_num_credito;
				
				LET v_pago_realizado = v_pago_capital + v_int_vigente + v_iva_vigente + v_interes_orden + v_iva_interes_orden;
				
				IF v_antiguedad  <= 2 THEN
					 SELECT mdy(month(pPeriodo),dia_corte,year(pPeriodo)), dia_corte,mdy(month(pPeriodo),dia_corte+1,year(pPeriodo)) -1 units month
					 INTO v_fecha_corte_tdc,v_dia_corte_tdc,dt_ini_per_rep
					 FROM sd_maecredanexo
					 WHERE empresa = v_empresa 
					 and num_Credito = v_num_credito_ext;
				END IF;
				
				IF v_antiguedad  = 0 THEN	
					--SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					 SELECT SUM(monto)  --Monto pago completo
					  INTO v_pago_realizado1
					  FROM movs_pagos_ext
					 WHERE fecha_mov BETWEEN (dt_ini_per_rep - 1 units month) AND (v_fecha_corte_tdc - 1 units month) --21/04 a 20/05
					   AND num_credito = v_num_credito_ext;
			
					--SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					 SELECT SUM(monto)  --Monto pago completo
					  INTO v_pago_realizado2
					   FROM movs_pagos_ext
					  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 2 units month) AND (v_fecha_corte_tdc - 2 units month) --21/03 a 20/04
						AND num_credito = v_num_credito_ext;		
						
					--SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					 SELECT SUM(monto)  --Monto pago completo
						INTO v_pago_realizado3
					   FROM movs_pagos_ext
					  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 3 units month) AND (v_fecha_corte_tdc - 3 units month) --21/02 a 20/03
						AND num_credito = v_num_credito_ext;	
			
				
				ELIF v_antiguedad  = 1 THEN	
					LET v_fecha = (v_fecha_corte - 2 units month)+1 units day;
				
					SELECT  SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado1					
					  FROM movs_pagos 
					WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 1 units month 
					  AND num_Credito = v_num_credito;
				
				--TARJETA v_pago_realizado2 y v_pago_realizado3
					--SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					  SELECT SUM(monto)  --Monto pago completo
					  INTO v_pago_realizado2
					   FROM movs_pagos_ext
					  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 2 units month) AND (v_fecha_corte_tdc - 2 units month) --21/03 a 20/04
						AND num_credito = v_num_credito_ext;		
						
					 --SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					 SELECT SUM(monto)  --Monto pago completo
						INTO v_pago_realizado3
					   FROM movs_pagos_ext
					  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 3 units month) AND (v_fecha_corte_tdc - 3 units month) --21/02 a 20/03
						AND num_credito = v_num_credito_ext;	
				
				ELIF v_antiguedad  = 2 THEN	
					LET v_fecha = (v_fecha_corte - 2 units month)+1 units day;
				
					SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado1					
					  FROM movs_pagos 
					WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 1 units month 
					  AND num_Credito = v_num_credito;
					
					LET v_fecha = (v_fecha_corte - 3 units month)+1 units day;
					
					SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado2
					  FROM movs_pagos 
					 WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 2 units month 
					   AND num_Credito = v_num_credito;

						--TARJETA v_pago_realizado3
					 --SELECT SUM (CASE WHEN codigo_ref in (7,10,901,5,8) THEN monto ELSE 0 END) --Sin moratorios
					 SELECT SUM(monto)  --Monto pago completo
						INTO v_pago_realizado3
					   FROM movs_pagos_ext
					  WHERE fecha_mov BETWEEN (dt_ini_per_rep - 3 units month) AND (v_fecha_corte_tdc - 3 units month) --21/02 a 20/03
						AND num_credito = v_num_credito_ext;		
				ELSE
					LET v_fecha = (v_fecha_corte - 2 units month)+1 units day;
				
					SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado1					
					  FROM movs_pagos 
					WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 1 units month 
					  AND num_Credito = v_num_credito;
					
					LET v_fecha = (v_fecha_corte - 3 units month)+1 units day;
					
					SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado2
					  FROM movs_pagos 
					 WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 2 units month 
					   AND num_Credito = v_num_credito;
					
					LET v_fecha = (v_fecha_corte - 4 units month)+1 units day;
				
					SELECT SUM((NVL(capital_vigente,0)+NVL(capital_transitorio,0)+NVL(capital_no_exigible,0)+NVL(capital_exigible,0)+NVL(int_vigente,0)+NVL(iva_vigente,0)+NVL(interes_orden,0)+NVL(iva_interes_orden,0)))
					  INTO v_pago_realizado3
					  FROM movs_pagos 
					 WHERE fecha_mov >= v_fecha AND fecha_mov <= v_fecha_corte - 3 units month 
					   AND num_Credito = v_num_credito;					
				END IF;
				
				LET v_pago_realizado4 = 0;
				LET v_pago_realizado5 = 0;
				LET v_pago_realizado6 = 0;
				
				--CAMPO 70 PERIODOS_INCUMPLIMIENTO
				SELECT a.fecha, a.status_cred, nvl(mto_fin_ven_trasp,0) pago_sostentido
                FROM sd_maecredcontcrd a inner join sd_maesdoscontcrd b
                ON a.fecha = b.fecha AND a.num_Credito = b.num_Credito
                WHERE a.empresa = '001' 
                AND a.num_credito = v_num_credito
                and (a.status_cred in('BA','BT','VP') or (a.status_cred='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (a.status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (a.status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)) )
               -- and  month(a.fecha)||'-'||year(a.fecha) <> month(fecha_apertura)||'-'||year(fecha_apertura)               
                and day(a.fecha) in(28,29,30,31)                
                INTO TEMP tmp_incumplimientos WITH NO LOG;

                CREATE INDEX idx_INCUMp ON tmp_incumplimientos(fecha) ONLINE;

                 SELECT COUNT(*) INTO v_periodos_incumplimiento
                 FROM tmp_incumplimientos
                   WHERE fecha <= pPeriodo
				   AND (status_cred IN ('BA','BT') or ((status_cred='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) OR (status_cred = 'VP' AND pago_sostentido <> 0));

                DROP TABLE tmp_incumplimientos;
				
				IF v_fecha_apertura >= piniPeriodo and v_fecha_apertura <= pPeriodo and NVL(v_monto_exigible,0) = 0 THEN
							LET v_porcentaje_pago ='1.00';
				ELSE
					--CAMPO 74 PORCENTAJE_PAGO
					IF nvl(v_monto_exigible,0)>0 THEN
						LET v_prom1= nvl(v_pago_realizado / v_monto_exigible,0);
						LET cont_me = cont_me+1;
					ELSE
						LET v_prom1 = "";
						
					END IF;
					IF nvl(v_monto_exigible1,0)>0 THEN
						LET v_prom2= nvl(v_pago_realizado1 / v_monto_exigible1,0);
						LET cont_me = cont_me+1;
					ELSE
						LET v_prom2 = "";	
						
					END IF;
					IF nvl(v_monto_exigible2,0)>0 THEN
						LET v_prom3= nvl(v_pago_realizado2 / v_monto_exigible2,0);
						LET cont_me = cont_me+1;
					ELSE
						LET v_prom3 = "";	
						
					END IF;
					IF nvl(v_monto_exigible3,0)>0 THEN
						LET v_prom4= nvl(v_pago_realizado3 / v_monto_exigible3,0);
						LET cont_me = cont_me+1;
					ELSE
						LET v_prom4 = "";	
						
					END IF;
					
					/*
					IF  v_antiguedad >= 4 THEN
						LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4) / 4,0);
					ELSE 
						IF   v_monto_exigible  IS NULL 	   AND v_monto_exigible1 IS NULL     AND v_monto_exigible2 IS NULL     AND v_monto_exigible3 IS NULL      THEN 
							LET v_porcentaje_pago = 0;
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NULL     AND v_monto_exigible2 IS NULL     AND v_monto_exigible3 IS NULL      THEN
							LET v_porcentaje_pago=nvl((v_prom1)/1,0);
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NULL     AND v_monto_exigible3 IS NULL      THEN
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2) / 2,0);						
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL AND v_monto_exigible3 IS NULL      THEN
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3) / 3,0);		
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL AND v_monto_exigible3 IS NOT NULL  THEN
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4) / 4,0);
						END IF;
					END IF;
					*/
					IF cont_me <= 0 THEN
					 LET v_porcentaje_pago= 0;
					ELSE
					 LET v_porcentaje_pago= round(NVL((NVL(v_prom1,0)+NVL(v_prom2,0)+NVL(v_prom3,0)+NVL(v_prom4,0))/ cont_me,0),2);
					END IF;
					--CAMPO 77 SALDO CIERRE
					--LET v_saldo_cierre = v_sdocap_insoluto_cierre +v_interes_vencido_ord;
					--IPCB 06/11/18 Se indica que el saldo al cierre no debe considerar  los intereses vencidos de orden
					--LET v_saldo_cierre = v_sdocap_insoluto_cierre;
					--CAMPO 75 PORCENTAJE DE USO
					
				END IF;
				
				IF v_status_fin_mes='BT' or ((v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) THEN
						 
					SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+v_interes_vencido_bal30
					INTO v_saldo_cierre
					FROM sd_maesdoscontcrd
					WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
				ELSE
					--SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(provision_normal,0)
					SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(sdo_acum_mes_int,0)  -- Se cambia el provision_normal x sdo_acum_mes_int, ya que se tenia un descueadre en 18 cuentas contra la balanza
					INTO v_saldo_cierre
					FROM sd_maesdoscontcrd
					WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
				END IF;
				
				LET v_porcentaje_uso = ROUND((v_saldo_cierre / v_linea_autorizada),6);	
				
                -- CAMPO 78 SALDO_CORTE			  
				IF v_dia_corte = 2 THEN				
					IF MONTH(piniPeriodo) = 1 THEN
						SELECT intvenc31
						INTO v_interes_vencido_ord_corte
						FROM sd_sdodiariocrd
						WHERE num_credito=v_num_credito and fecha=(piniPeriodo-1 units month);					
					ELSE --MONTH(piniPeriodo) <> 1THEN
						SELECT intvenc1
						INTO v_interes_vencido_ord_corte
						FROM sd_sdodiariocrd
						WHERE num_credito=v_num_credito and fecha=piniPeriodo;					
					END IF;	
				ELSE
					SELECT intvenc16
					INTO v_interes_vencido_ord_corte
					FROM sd_sdodiariocrd
					WHERE num_credito=v_num_credito and fecha=piniPeriodo;						
				END IF;
				
				SELECT sdo_cap_insoluto  saldo_insoluto_corte   
                 INTO v_saldo_insoluto_corte
                 FROM sd_maesdoshistcrd
                WHERE num_credito=v_num_credito and fecha= v_fecha_corte_proc;	

				LET v_saldo_corte = v_saldo_insoluto_corte + v_interes_vencido_ord_corte;	
				
				--CAMPO 79 SALDO EXIGIBLE
                SELECT nvl(mto_venc_trasp,0)
                INTO v_saldo_exigible
                FROM sd_maesdoscontcrd
                WHERE num_credito =v_num_credito and fecha=pPeriodo; 
                
                --CAMPO 80 SALDO NO EXIGIBLE
                LET v_fecha= mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo));                
                SELECT                
                nvl(cap_tras_no_venci,0) 
                INTO v_saldo_no_exigible
                FROM sd_maesdoscontcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
				
				--CAMPO 84 PAGO SOSTENIDO
				SELECT  nvl(mto_fin_ven_trasp,0) INTO 	v_pago_Sostenido	
				  FROM sd_maesdoscontcrd 
				 WHERE fecha = pPeriodo
				  AND num_credito = v_num_credito;
				  
				IF v_pago_Sostenido > 0 THEN
					LET v_cum_pago_sost = 1;
				ELSE 
					LET v_cum_pago_sost = 0;
				END IF;
				
			----BLOQUE VARIABLES DE CIRCULO				
				/*SELECT a.num_credito credito_consulta,b.num_credito cred_respuesta, 
						var_mtosdo_ship,meses_ultimoatr1d_todos,NVL(monto_pagar_propios_ship,0),NVL(monto_pagar_otros_ship,0),NVL(sdo_actual_propio_ship,0),NVL(sdo_actual_otros_ship,0)
				  INTO v_cred_consulta, v_cred_respuesta,
					    v_var_mtosdo,v_bkatr,v_mto_pagar_propios,v_mto_pagar_otros,v_sdo_actual_propio,v_sdo_actual_otros	
				  FROM bdiburo:br_consul_var_cc_cnr a left join bdiburo:br_variables_cc_cnr b
				    ON b.fecha_info  = dt_ultcons_varcc AND a.num_credito = b.num_credito
				 WHERE a.fecha_consulta between mdy(month(dt_ultcons_varcc),'01',year(dt_ultcons_varcc)) and dt_ultcons_varcc
				   AND a.num_credito = v_num_credito;*/

                   --CJAC Modificacion de la consulta quitar el cruce con la tabla br_consul_var_cc_cnr
                  SELECT num_credito credito_consulta, 
						var_mtosdo_ship,meses_ultimoatr1d_todos,NVL(monto_pagar_propios_ship,0),NVL(monto_pagar_otros_ship,0),NVL(sdo_actual_propio_ship,0),NVL(sdo_actual_otros_ship,0),
                        antiguedad_inst, antiguedad_bancos,sdo_actual_propio_ship
				  INTO v_cred_consulta,
					    v_var_mtosdo,v_bkatr,v_mto_pagar_propios,v_mto_pagar_otros,v_sdo_actual_propio,v_sdo_actual_otros,v_antiguedad_inst, v_antiguedad_bancos,
						v_sdo_actual_propio_ship
				  FROM bdiburo:br_variables_cc_cnr 
				 WHERE fecha_info  = dt_ultcons_varcc
				   AND num_credito = v_num_credito;

                   LET v_numero_cuenta_det = v_cred_consulta;
                   LET v_veces_ult_atr1d_todos = v_bkatr;  
		
				IF 	v_cred_consulta IS NULL THEN  --No se consulto a las SICs
					--CAMPO 82 Sin Consulta
                    LET v_numero_cuenta_det = 'ND';
					LET v_sin_consulta = '1';
                    LET v_antiguedad_inst = -99999;
                    LET v_veces_ult_atr1d_todos = -99999;
					LET v_var_mtosdo = '-99999';
					--CAMPO 11 Consulta sin info
					LET v_consulta_sin_info = '0';
					--CAMPO 1 Alto, 38 Medio, 8 Bajo
					LET v_alto = '1';
					LET v_medio = '0';					
					LET v_bajo = '0';
					--CAMPO 39 meses BKATR
					IF v_atr = 0 THEN
						LET v_bkatr = 10;
					ELIF v_atr >= 1 THEN
						LET v_bkatr = 0;
					END IF;	
					--CAMPO 48 monto otros vs propios, 49 monto pagar otros, 50 monto pagar_propios, 51 mto vs sdo sic, 73 porcentaje endeudamiento
					LET v_mto_otros_vs_propios = 0;
					LET v_mto_pagar_otros =0;
					LET v_mto_pagar_propios = 0;
					LET v_mtovssdo_sic = 0;
					LET v_sdo_sic = 0;				
					LET v_porcentaje_endeuda = 0; 	
				ELSE 						 --Si Se consulto a las SICs
					--CAMPO 82 Sin Consulta
					LET v_sin_consulta = '0';
					--CAMPO 11 Consulta sin info
					--IF v_cred_respuesta IS NULL THEN
					IF v_var_mtosdo IS NULL THEN
						LET v_consulta_sin_info = '1';
					ELSE 
						LET v_consulta_sin_info = '0';																													
					END IF;			
					--CAMPO 1 Alto, 38 Medio, 8 Bajo
					--IF v_var_mtosdo IS NULL THEN
					IF v_consulta_sin_info=1 THEN --cambiar condicion de v_var_mtosdo por v_consulta_sin_info
						LET v_alto = '0';
						LET v_medio = '1';							
						LET v_bajo = '0';					
					ELSE
						IF v_var_mtosdo = 'ALTO' THEN
							LET v_alto = '1';
							LET v_bajo = '0';
							LET v_medio = '0';						
						ELIF v_var_mtosdo = 'MEDIO' THEN
							LET v_alto = '0';
							LET v_medio = '1';							
							LET v_bajo = '0';							
						ELIF v_var_mtosdo = 'BAJO ' THEN
							LET v_alto = '0';
							LET v_medio = '0';							
							LET v_bajo = '1';	
						END IF;		
					END IF;
					--CAMPO 39 meses BKATR
					IF v_bkatr IS NULL THEN
						LET v_bkatr = 13;
					ELSE
						LET v_bkatr = v_bkatr;
					END IF;
					--CAMPO 49 monto pagar otros, 50 monto pagar_propios, 48 monto otros vs propios,  51 mto vs sdo sic, 73 porcentaje endeudamiento
					LET v_mto_pagar_otros =v_mto_pagar_otros;
					LET v_mto_pagar_propios = v_mto_pagar_propios;
					
					IF  v_mto_pagar_propios = 0 THEN 
						LET v_mto_otros_vs_propios = 0;
					ELSE
						LET v_mto_otros_vs_propios = v_mto_pagar_otros / v_mto_pagar_propios;
					END IF;					
					
					LET v_sdo_sic = v_sdo_actual_propio + v_sdo_actual_otros;
					
					IF v_sdo_sic = 0 THEN 
						LET v_mtovssdo_sic = 0 ;
					ELSE	
						LET v_mtovssdo_sic = (v_mto_pagar_propios + v_mto_pagar_otros)/v_sdo_sic;
					END IF;
					
					IF v_ingresos_mens_brutos = 0  OR v_ingresos_mens_brutos is null THEN
						LET v_porcentaje_endeuda = 0;
					ELSE
						LET v_porcentaje_endeuda = round((v_mto_pagar_otros + v_mto_pagar_propios)/ v_ingresos_mens_brutos,6);
					END IF;

                    IF v_antiguedad_inst IS NULL THEN
                        LET v_antiguedad_inst = "";
                    END IF;
					
					IF v_veces_ult_atr1d_todos IS NULL AND v_atr > 0 THEN --validar
							LET v_bkatr = 0;
						END IF;
                    
                    IF v_veces_ult_atr1d_todos IS NULL THEN
                        LET v_veces_ult_atr1d_todos = "";
                    END IF;
					
					IF v_var_mtosdo IS NULL THEN
						LET v_var_mtosdo = "";
					END IF;
				END IF;	
                

                LET v_fecha_corte_format = TO_CHAR(v_fecha_corte, '%Y/%m/%d');
                LET v_fecha_apertura_cte_format = TO_CHAR(v_fecha_apertura_cte, '%Y/%m/%d');
				
			--END FOREACH; 
			   
			  /* SELECT count(*) INTO v_num_pagos_vencidos  
					FROM bdicred:sd_amortiza_creditocrd 
					WHERE num_Credito = v_num_credito 
					      AND capital_status in (2,7)
					     AND fecha_cuota >= piniperiodo and fecha_cuota <= pPeriodo;*/
			
			    IF (select count(num_credito) from sd_programa_apoyo where num_credito= v_num_credito)=0 THEN
                    IF (select count(num_credito) from sd_maecredcontcrd 
                        where num_credito= v_num_credito and campo_trab3='BAJA')=0 THEN
                        LET v_cred_sit_especial=0;
                    ELSE
                        LET v_cred_sit_especial=1;
                    END IF;
                ELSE
                    LET v_cred_sit_especial=1;
                END IF;
                

				/*  SE COMENTA PARA EXTRAERLO DIRECTAMENTE DE LA SD_MAECREDCONTCRD
                IF v_status_fin_mes = 'VP' THEN
                    LET v_etapa_cred = '3PS';
                ELSE
                    IF v_atr > 3 THEN
                        LET v_etapa_cred='3';
					ELIF v_atr=0 or v_atr1=0 or (v_atr <= 1 and v_fecha_ult_pago <= v_fecha_corte) THEN
                        LET v_etapa_cred='1';
					ELSE
                    --ELIF v_atr >= 2 AND v_atr <= 3  THEN
                        LET v_etapa_cred='2';                    
                    END IF;
                END IF;*/
				
				/*IF v_atr > 3 THEN
        LET v_etapa_cred='3';
    ELIF v_atr > 1 AND v_atr <= 3  THEN
        LET v_etapa_cred='2';
    ELIF v_atr <= 1 THEN
        LET v_etapa_cred='1';
    END IF;*/
	
			   
                
               select nvl(b.monto,0) Into v_gastos_originacion from sd_definicion a
                inner join sd_tpcomis b
                on a.cod_comision_apertura=b.cod_comis
                where num_producto=v_num_producto; 
				
				execute procedure "informix".sp_tasaefectiva(v_linea_autorizada, v_gastos_originacion, v_tasa_contractual, v_plazo_total, v_facturacion)
				INTO v_tir_mensual, v_tasa_efectiva;
				
				IF v_tasa_contractual=0 THEN
					LET v_tasa_contractual= 0.0000001;	--SE CAMBIA DE 5 A 7 DECIMALES
				ELSE
					LET v_tasa_contractual= v_tasa_contractual/100;
				END IF;
				
				IF v_tasa_efectiva =0 THEN 
					LET v_tasa_efectiva= 0.00001;
				END IF;
				
                   
				SELECT credito_externo INTO v_num_credito_tdc 
				FROM sd_maecredcrd where num_credito=v_num_credito; 
				
				IF v_num_credito_tdc LIKE('81%') OR v_num_credito_tdc LIKE('70%') THEN
					SELECT credito_externo INTO v_num_credito_visa 
					FROM sd_maecred where num_credito=v_num_credito_tdc;
					
					LET v_num_credito_tdc=v_num_credito_visa;
				END IF;
				
				
                IF EXISTS (SELECT * FROM bdisolic:ss_Revision_determinacion WHERE num_solicitud = v_num_credito_tdc) THEN  --VALIDAR SI AQUI ES credito_ree o credito tdc
                    SELECT evalua_cc, bs_score, score_prop
                    INTO c_evalua_cc,n_scoreburo, n_scoreotor
                    FROM bdisolic:ss_Revision_determinacion 
                    WHERE num_solicitud = v_num_credito_tdc;
					IF n_scoreotor IS NULL THEN
						SELECT a.evalua_cc, b.evaluacion, c.evaluacion
						INTO c_evalua_cc, n_scoreburo, n_scoreotor
						FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
						 ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
						LEFT JOIN bdisolic:ss_resumen_scoring c
						 ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
						WHERE a.num_solicitud = v_num_credito_tdc;
					END IF
                ELSE			
                    SELECT a.evalua_cc, b.evaluacion, c.evaluacion
                    INTO c_evalua_cc, n_scoreburo, n_scoreotor
                    FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
                     ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
                    LEFT JOIN bdisolic:ss_resumen_scoring c
                     ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
                    WHERE a.num_solicitud = v_num_credito_tdc; 	
                END IF;
                
                IF c_evalua_cc='X' THEN
                    LET v_modelo_score='NO HIT';
                ELIF c_evalua_cc in('0','1','2','3','4') THEN
                    LET v_modelo_score='HIT';
				ELSE 
					LET v_modelo_score="";
                END IF;
                
                IF v_plazo_remanente < 1 THEN
                    LET v_periodo_rem_n=1;
                ELSE
                    LET v_periodo_rem_n = v_plazo_remanente;
                END IF;
				
				IF day(pPeriodo)='31' THEN 
					SELECT (capvig31 + captrans31 + capvencnoexig31 + capvenexig31)
					INTO v_capital_cierre
					FROM sd_sdodiariocrd 
					WHERE num_credito=v_num_credito and fecha = piniPeriodo;
				END IF;

				IF day(pPeriodo)='30' THEN 
					SELECT (capvig30 + captrans30 + capvencnoexig30 + capvenexig30) 
					INTO v_capital_cierre
					FROM sd_sdodiariocrd 
					WHERE num_credito=v_num_credito and fecha = piniPeriodo;
				END IF;

				IF day(pPeriodo)='29' THEN 
					SELECT (capvig29 + captrans29 + capvencnoexig29 + capvenexig29)
					INTO  v_capital_cierre  
					FROM sd_sdodiariocrd 
					WHERE num_credito=v_num_credito and fecha = piniPeriodo;
				END IF;

				IF day(pPeriodo)='28' THEN 
					SELECT (capvig28 + captrans28 + capvencnoexig28 + capvenexig28) 
					INTO  v_capital_cierre 
					FROM sd_sdodiariocrd 
					WHERE num_credito=v_num_credito and fecha = piniPeriodo;
				END IF;

				/*SELECT count(v_num_credito) INTO v_num_pagos_vencidos  
						FROM bdicred:sd_amortiza_creditocrd 
						WHERE num_Credito = v_num_credito 
							  AND capital_status in (2,7)
							  AND fecha_cuota <= pPeriodo;
							 --AND fecha_cuota >= piniperiodo and fecha_cuota <= pPeriodo;*/
							 
				SELECT intereses_ree INTO v_interes_reee
				FROM bdicred:sd_indicador_cred_crd
				WHERE num_credito=v_num_credito;

				LET v_dias_rem_contractual = v_fecha_vencimiento - pPeriodo; --nuevo sep 
				
					--validacion montos_exigibles
					IF nvl(v_monto_exigible,0) = 0 THEN
						LET v_prom1 = "";
					END IF
					IF nvl(v_monto_exigible1,0) = 0 THEN
						LET v_prom2 = "";
					END IF
					
					IF nvl(v_monto_exigible2,0) = 0 THEN
						LET v_prom3 = "";
					END IF
					IF nvl(v_monto_exigible3,0) = 0 THEN
						LET v_prom4 = "";
					END IF
				
				
				
				--se agrega las variables segÃºn cnbv
				select NVL(a.rfc,'')
					INTO v_rfc
					from bdinteg:si_cliente a
					INNER join bdinteg:si_ctepf c
					on a.numcte=c.numcte
					where a.numcte=v_num_cliente;
					
			
				SELECT trim(nombre1),trim(nombre2),trim(apell_paterno),trim(apell_materno) 
				  INTO c_nombre1,c_nombre2,c_ap_paterno,c_ap_materno 
				  FROM bdinteg:si_Cliente
				 WHERE numcte = v_num_cliente;      
				 
				 LET c_nom_cte = c_nombre1||' '||c_nombre2||' '||c_ap_paterno||' '||c_ap_materno;
				
				
				
               -- BEGIN WORK;
                    INSERT INTO sd_insumos_calif_reest (fecha_cierre,
													alto,
													antecedentes_buro,antiguedad_cliente,atr,atr1,atr2,atr3,
													bajo,
													capital_exigible, 
													comisiones,consulta_sin_info,            	
                                                   cred_liquida_cred,cred_nomina,grupo_originacion,delegada,dias_atraso,eficiencia,                  
                                                   facturacion,fecha_apertura,fecha_apertura_cte,fecha_corte,fecha_vencimiento,           
                                                   ingresos_mens_brutos,ingresos_mens_netos,int_mora_copete,int_mora_ordinario,         
                                                   interes_deven_ven_bal,interes_deven_vig_bal,interes_devengados_ord,interes_vencido_bal,
                                                   interes_vencido_ord,interes_vigente,iva_interes_vencido_bal,iva_interes_vencido_ord,
                                                   iva_interes_vigente,linea_autorizada,max_atr,
												   medio, meses_bkatr,
												   antiguedad,monto_exigible,monto_exigible1,
                                                   monto_exigible2,monto_exigible3,monto_exigible4,monto_exigible5,monto_exigible6,num_cliente,
                                                   num_credito,num_disposiciones,num_producto,pago_capital,pago_int_venc_bal,pago_int_venc_ord,
                                                   pago_interes_vigente,pago_iva_int_venc_bal,pago_iva_int_venc_ord,pago_iva_interes_vigente,
                                                   pago_realizado,pago_realizado1,pago_realizado2,pago_realizado3,pago_realizado4,pago_realizado5,
                                                   pago_realizado6,
												   monto_otros_vs_propios, monto_pagar_otros,monto_pagar_propios,mto_vs_sdo_sic,
												   periodos_incumplimiento,plazo_remanente,plazo_total,porcentaje_endeudamiento,porcentaje_pago,porcentaje_uso,
                                                   ree_tdc_anterior,saldo_cierre,saldo_corte,saldo_exigible,saldo_no_exigible,
												   saldo_sic,sin_consulta,												   
												   status_fin_mes,
												   cum_pag_sost, comision_cobranza, comision_exig_cobranza, cred_sit_especial,num_pagos_vencidos, numero_cuenta_det,
												   antiguedad_inst,meses_ult_atr1d_todos, var_mtosdo,sucursal,tasa_contractual,etapa_cred,intereses_etapa3,capital_cierre,
												   gastos_originacion,score_originacion,score_buro,modelo_score,periodo_rem_n, interes_reee, tasa_efectiva,
												   antiguedad_bancos,sdo_actual_propio_ship,fecha_ult_pago,num_credito_tdc,intereses_etapa1,intereses_etapa2,
												   Pct_Pgo0,Pct_pago1,Pct_pago2,Pct_pago3,Dias_Rem_Contractual,
												   rfc,nombre_cte)--nvo cnbv
                                             VALUES(pPeriodo,
													v_alto,
													--v_antecedentes_buro,v_antiguedad_cliente,nvl(v_atr,0),nvl(v_atr1,0),nvl(v_atr2,0),nvl(v_atr3,0),
													v_antecedentes_buro,v_antiguedad_cliente,
													CASE WHEN v_atr IS NULL OR v_atr <= 0 THEN 0 ELSE v_atr END,
													CASE WHEN v_atr1 IS NULL OR v_atr1 <= 0 THEN 0 ELSE v_atr1 END,
													CASE WHEN v_atr2 IS NULL OR v_atr2 <= 0 THEN 0 ELSE v_atr2 END,
													CASE WHEN v_atr3 IS NULL OR v_atr3 <= 0 THEN 0 ELSE v_atr3 END,
													v_bajo,
													nvl(v_capital_exigible,0), 
													v_comisiones,v_consulta_sin_info,             	
                                                   v_cred_liquida_cred,v_cred_nomina,v_grupo_originacion,v_delegada,v_dias_atraso,v_eficiencia,                  
                                                   v_facturacion,v_fecha_apertura,v_fecha_apertura_cte,v_fecha_corte,v_fecha_vencimiento,           
                                                   nvl(v_ingresos_mens_brutos,0),nvl(v_ingresos_mens_netos,0),nvl(v_int_mora_copete,0),nvl(v_int_mora_ordinario,0),         
                                                   nvl(v_interes_deven_ven_bal,0),nvl(v_interes_deven_vig_bal,0),nvl(v_interes_devengados_ord,0),nvl(v_interes_vencido_bal,0),
                                                   nvl(v_interes_vencido_ord,0),nvl(v_interes_vigente,0),nvl(v_iva_interes_vencido_bal,0),nvl(v_iva_interes_vencido_ord,0),
                                                   nvl(v_iva_interes_vigente,0),nvl(v_linea_autorizada,0),v_max_atr,
												   v_medio,v_bkatr,
												   v_antiguedad,nvl(v_monto_exigible,0),nvl(v_monto_exigible1,0),
                                                   nvl(v_monto_exigible2,0),nvl(v_monto_exigible3,0),nvl(v_monto_exigible4,0),nvl(v_monto_exigible5,0),nvl(v_monto_exigible6,0),v_num_cliente,
                                                   --v_num_credito,v_num_disposiciones,v_num_producto,nvl(v_pago_capital,0),nvl(v_pago_int_venc_bal,0),nvl(v_pago_int_venc_ord,0),
												   v_num_credito,v_num_disposiciones,v_num_producto,nvl(v_pago_capital,0),nvl(v_pago_int_venc_bal,0),nvl(v_interes_orden,0),
                                                   --nvl(v_pago_interes_vigente,0),nvl(v_pago_iva_int_venc_bal,0),nvl(v_pago_iva_int_venc_ord,0),nvl(v_pago_iva_interes_vigente,0),
												   nvl(v_int_vigente,0),nvl(v_pago_iva_int_venc_bal,0),nvl(v_iva_interes_orden,0),nvl(v_iva_vigente,0),
                                                   nvl(v_pago_realizado,0),nvl(v_pago_realizado1,0),nvl(v_pago_realizado2,0),nvl(v_pago_realizado3,0),nvl(v_pago_realizado4,0),nvl(v_pago_realizado5,0),
                                                   nvl(v_pago_realizado6,0),
												   v_mto_otros_vs_propios,v_mto_pagar_otros, v_mto_pagar_propios,v_mtovssdo_sic,
												   v_periodos_incumplimiento,v_plazo_remanente,v_plazo_total,v_porcentaje_endeuda,v_porcentaje_pago,v_porcentaje_uso,
                                                   v_ree_tdc_anterior,nvl(v_saldo_cierre,0),nvl(v_saldo_corte,0),nvl(v_saldo_exigible,0),nvl(v_saldo_no_exigible,0),
												   v_sdo_sic,v_sin_consulta,
												   v_status_fin_mes, 
												   v_cum_pago_sost,v_comision_cobranza,v_comision_exig_cobranza, v_cred_sit_especial, v_num_pagos_vencidos,v_numero_cuenta_det,
												   v_antiguedad_inst, v_veces_ult_atr1d_todos,v_var_mtosdo, v_sucursal, v_tasa_contractual, v_etapa_cred,nvl(v_interes_reee,0),v_capital_cierre,
												   NVL(v_gastos_originacion,0),NVL(n_scoreotor,0),NVL(n_scoreburo,0),NVL(v_modelo_score,""),v_periodo_rem_n, nvl(v_interes_reee,0), v_tasa_efectiva,
												   v_antiguedad_bancos,v_sdo_actual_propio_ship,v_fecha_ult_pago,v_num_credito_tdc,v_intereses_etapa1,v_intereses_etapa2,
												    v_prom1,v_prom2,v_prom3,v_prom4,v_dias_rem_contractual,
													v_rfc,c_nom_cte);               -- COMMIT WORK;
			   
			LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 500) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				BEGIN WORK;
			END IF;
	
	END FOREACH; 
	
 IF val_trans_Commit = -1 THEN
     COMMIT WORK;
  END IF;
  LET val_trans_Commit = 0;
  
SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE DE REESTRUCTURAS OK "|| '6011';
	LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	
	
	RETURN cCodRet, cMensajeRet, cMensajeRet2;
END
END PROCEDURE;
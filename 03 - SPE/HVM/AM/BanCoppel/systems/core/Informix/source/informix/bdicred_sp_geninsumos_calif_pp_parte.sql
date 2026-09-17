CREATE PROCEDURE "informix".sp_geninsumos_calif_pp_parte(pEjecucion smallint)
RETURNING   CHAR(5), CHAR(100), char(60);
--EXECUTE PROCEDURE "informix".sp_geninsumos_calif_pp_parte(5);
--EXECUTE PROCEDURE "informix".sp_geninsumos_calif_pp_parte(6);
--Declaracion de variables.


DEFINE pPeriodo              			DATE;
DEFINE pIva                             DECIMAL(5,3);
DEFINE iSqlErr      					INTEGER;
DEFINE iIsamErr         				INTEGER;
DEFINE cErrorInfo       				CHAR(100);
DEFINE cCodRet          				CHAR(6);
DEFINE cMensajeRet    					CHAR(100);
DEFINE v_sucursal                       char(4);
DEFINE v_empresa                     	CHAR(3);
DEFINE v_antecedentes_buro             	CHAR(2);
DEFINE v_antiguedad_cliente          	INTEGER;
DEFINE v_atr                        	DECIMAL(18,2);
DEFINE v_atr1                         	DECIMAL(18,2);
DEFINE v_atr2                          	DECIMAL(18,2);
DEFINE v_atr3                          	DECIMAL(18,2);
DEFINE v_capital_exigible             	DECIMAL(18,2);
DEFINE v_cred_liquida_cred            	SMALLINT;
DEFINE v_cred_nomina                  	SMALLINT;
DEFINE v_grupo_originacion             	CHAR(2);
DEFINE v_delegada                    	SMALLINT;
DEFINE v_dias_atraso                   	SMALLINT;
DEFINE v_eficiencia                    	SMALLINT;
DEFINE v_facturacion                   	CHAR(2);
DEFINE v_fecha_apertura                	DATE;
DEFINE v_fecha_apertura_format          CHAR(12);
DEFINE v_fecha_ult_disp			DATE;
DEFINE v_fecha_apertura_cte            	DATE;
DEFINE v_fecha_apertura_cte_format     	CHAR(12);
DEFINE v_fecha_corte                   	DATE;
DEFINE v_fecha_corte_format            	CHAR(12);
DEFINE v_fecha_vencimiento             	DATE;
DEFINE v_fecha_venc_format              CHAR(12);
DEFINE v_ingresos_mens_brutos          	DECIMAL(18,2);
DEFINE v_ingresos_mens_netos           	DECIMAL(18,2);
DEFINE v_int_mora_copete            	DECIMAL(18,2);
DEFINE v_int_mora_ordinario            	DECIMAL(18,2);
DEFINE v_interes_deven_ven_bal         	DECIMAL(18,2);
DEFINE v_interes_deven_vig_bal         	DECIMAL(18,2);
DEFINE v_interes_devengados_ord        	DECIMAL(18,2);
DEFINE v_interes_vencido_bal           	DECIMAL(18,2);
DEFINE v_interes_vencido_bal30         	DECIMAL(18,2);
DEFINE v_interes_vencido_ord           	DECIMAL(18,2);
DEFINE v_interes_vigente            	DECIMAL(18,2);
DEFINE v_iva_interes_vencido_bal       	DECIMAL(18,2);
DEFINE v_iva_interes_vencido_ord       	DECIMAL(18,2);
DEFINE v_iva_interes_vigente           	DECIMAL(18,2);
DEFINE v_linea_autorizada           	DECIMAL(18,2);
DEFINE v_max_atr                      	DECIMAL(18,2);
DEFINE v_antiguedad                   	INTEGER;
DEFINE v_monto_exigible               	DECIMAL(18,2);
DEFINE v_monto_exigible1              	DECIMAL(18,2);
DEFINE v_monto_exigible2              	DECIMAL(18,2);
DEFINE v_monto_exigible3              	DECIMAL(18,2);
DEFINE v_monto_exigible4              	DECIMAL(18,2);
DEFINE v_monto_exigible5              	DECIMAL(18,2);
DEFINE v_monto_exigible6              	DECIMAL(18,2);
DEFINE v_monto_exigible7               	DECIMAL(18,2);
DEFINE v_monto_exigible8              	DECIMAL(18,2);
DEFINE v_monto_exigible9              	DECIMAL(18,2);
DEFINE v_monto_exigible10              	DECIMAL(18,2);
DEFINE v_monto_exigible11              	DECIMAL(18,2);
DEFINE v_monto_exigible12              	DECIMAL(18,2);
DEFINE v_monto_exigible13              	DECIMAL(18,2);
DEFINE v_num_cliente                  	CHAR(20);
DEFINE v_num_credito                  	CHAR(20);
DEFINE v_num_disposiciones            	SMALLINT;
DEFINE v_num_producto                	CHAR(4);
DEFINE v_pago_capital                  	DECIMAL(18,2);
DEFINE v_pago_int_venc_bal           	DECIMAL(18,2);
DEFINE v_pago_int_venc_ord             	DECIMAL(18,2);
DEFINE v_pago_interes_vigente          	DECIMAL(18,2);
DEFINE v_pago_iva_int_venc_bal         	DECIMAL(18,2);
DEFINE v_pago_iva_int_venc_ord         	DECIMAL(18,2);
DEFINE v_pago_iva_interes_vigente      	DECIMAL(18,2);
DEFINE v_pago_realizado               	DECIMAL(18,2);
DEFINE v_pago_realizado1               	DECIMAL(18,2);
DEFINE v_pago_realizado2               	DECIMAL(18,2);
DEFINE v_pago_realizado3              	DECIMAL(18,2);
DEFINE v_pago_realizado4              	DECIMAL(18,2);
DEFINE v_pago_realizado5              	DECIMAL(18,2);
DEFINE v_pago_realizado6               	DECIMAL(18,2);
DEFINE v_pago_realizado7               	DECIMAL(18,2);
DEFINE v_pago_realizado8               	DECIMAL(18,2);
DEFINE v_pago_realizado9               	DECIMAL(18,2);
DEFINE v_pago_realizado10              	DECIMAL(18,2);
DEFINE v_pago_realizado11              	DECIMAL(18,2);
DEFINE v_pago_realizado12              	DECIMAL(18,2);
DEFINE v_pago_realizado13              	DECIMAL(18,2);
DEFINE v_periodos_incumplimiento    	DECIMAL(18,2);
DEFINE v_plazo_remanente            	DECIMAL(18,5);
DEFINE v_plazo_total                  	DECIMAL(18,2);
--DEFINE v_plazo_contractual              INTEGER;
DEFINE v_porcentaje_pago             	DECIMAL(18,2);
DEFINE v_porcentaje_uso               	DECIMAL(18,6);
DEFINE v_ree_tdc_anterior              	SMALLINT;
DEFINE v_saldo_cierre                 	DECIMAL(18,2);
DEFINE v_saldo_corte                   	DECIMAL(18,2);
DEFINE v_saldo_exigible              	DECIMAL(18,2);
DEFINE v_saldo_no_exigible             	DECIMAL(18,2);
DEFINE v_status_fin_mes               	CHAR(2);
DEFINE v_max_secuencia                  SMALLINT;
DEFINE v_num_cta                        CHAR(20);  

DEFINE v_dia_corte			SMALLINT; 
DEFINE v_antimaecred			INTEGER;
DEFINE v_antimaecredcrd			INTEGER;
DEFINE v_fecha                  DATE;

DEFINE v_capital_vigente    DECIMAL(18,2);
DEFINE v_capital_vencido    DECIMAL(18,2);
DEFINE v_int_vigente        DECIMAL(18,2);
DEFINE v_iva_vigente        DECIMAL(18,2);
DEFINE v_interes_orden      DECIMAL(18,2);
DEFINE v_iva_interes_orden  DECIMAL(18,2);
DEFINE v_int_venc_bal		DECIMAL(18,2);
DEFINE v_iva_venc_bal		 DECIMAL(18,2);

DEFINE v_capital_vigente1    DECIMAL(18,2);
DEFINE v_capital_vencido1    DECIMAL(18,2);
DEFINE v_int_vigente1        DECIMAL(18,2);
DEFINE v_iva_vigente1        DECIMAL(18,2);
DEFINE v_interes_orden1      DECIMAL(18,2);
DEFINE v_iva_interes_orden1  DECIMAL(18,2);
DEFINE v_int_venc_bal1		DECIMAL(18,2);
DEFINE v_iva_venc_bal1		 DECIMAL(18,2);

DEFINE v_capital_vigente2    DECIMAL(18,2);
DEFINE v_capital_vencido2    DECIMAL(18,2);
DEFINE v_int_vigente2        DECIMAL(18,2);
DEFINE v_iva_vigente2        DECIMAL(18,2);
DEFINE v_interes_orden2      DECIMAL(18,2);
DEFINE v_iva_interes_orden2  DECIMAL(18,2);
DEFINE v_int_venc_bal2		DECIMAL(18,2);
DEFINE v_iva_venc_bal2		 DECIMAL(18,2);

DEFINE v_capital_vigente3    DECIMAL(18,2);
DEFINE v_capital_vencido3    DECIMAL(18,2);
DEFINE v_int_vigente3        DECIMAL(18,2);
DEFINE v_iva_vigente3        DECIMAL(18,2);
DEFINE v_interes_orden3      DECIMAL(18,2);
DEFINE v_iva_interes_orden3  DECIMAL(18,2);
DEFINE v_int_venc_bal3		DECIMAL(18,2);
DEFINE v_iva_venc_bal3		 DECIMAL(18,2);

DEFINE v_capital_vigente4    DECIMAL(18,2);
DEFINE v_capital_vencido4    DECIMAL(18,2);
DEFINE v_int_vigente4        DECIMAL(18,2);
DEFINE v_iva_vigente4        DECIMAL(18,2);
DEFINE v_interes_orden4      DECIMAL(18,2);
DEFINE v_iva_interes_orden4  DECIMAL(18,2);
DEFINE v_int_venc_bal4		DECIMAL(18,2);
DEFINE v_iva_venc_bal4		 DECIMAL(18,2);

DEFINE v_capital_vigente5    DECIMAL(18,2);
DEFINE v_capital_vencido5    DECIMAL(18,2);
DEFINE v_int_vigente5        DECIMAL(18,2);
DEFINE v_iva_vigente5        DECIMAL(18,2);
DEFINE v_interes_orden5      DECIMAL(18,2);
DEFINE v_iva_interes_orden5  DECIMAL(18,2);
DEFINE v_int_venc_bal5		DECIMAL(18,2);
DEFINE v_iva_venc_bal5		 DECIMAL(18,2);

DEFINE v_capital_vigente6    DECIMAL(18,2);
DEFINE v_capital_vencido6    DECIMAL(18,2);
DEFINE v_int_vigente6        DECIMAL(18,2);
DEFINE v_iva_vigente6        DECIMAL(18,2);
DEFINE v_interes_orden6      DECIMAL(18,2);
DEFINE v_iva_interes_orden6  DECIMAL(18,2);
DEFINE v_int_venc_bal6		DECIMAL(18,2);
DEFINE v_iva_venc_bal6		 DECIMAL(18,2);

DEFINE v_prom1               DECIMAL(18,10);
DEFINE v_prom2               DECIMAL(18,10);
DEFINE v_prom3               DECIMAL(18,10);
DEFINE v_prom4               DECIMAL(18,10);
DEFINE v_prom5               DECIMAL(18,2);
DEFINE v_prom6               DECIMAL(18,2);
DEFINE v_prom7               DECIMAL(18,2);
DEFINE dia_corte_ant         SMALLINT;
DEFINE num_corte1            CHAR(10);

DEFINE c_CodRet                          CHAR(6); 
DEFINE mMensaje                         VARCHAR(100,1); 
DEFINE dFechaPer0                       DATE; 
DEFINE dFechaPer1                       DATE; 
DEFINE dFechaPer2                       DATE;
DEFINE dFechaPer3                       DATE; 
DEFINE dFechaPer4                       DATE; 
DEFINE dFechaPer5                       DATE; 
DEFINE dFechaPer6                       DATE; 
DEFINE dFechaPer7                       DATE; 
DEFINE dFechaPer8                       DATE; 
DEFINE dFechaPer9                       DATE;
DEFINE dFechaPer10                      DATE;
DEFINE dFechaPer11                      DATE;
DEFINE dFechaPer12                      DATE;
DEFINE dFechaPer13                      DATE;

DEFINE dTotalVencido					DECIMAL(18,2);
DEFINE dVencidoOrden					DECIMAL(18,2);
DEFINE dInteresVencido					DECIMAL(18,2);
DEFINE dOtrasEstimaciones				DECIMAL(18,2);
--IPCB
DEFINE vprod_proc						CHAR(4); 
DEFINE piniPeriodo						DATE;
DEFINE flag_aniobis						INTEGER;
DEFINE var_mto_fin_ven_trasp			INTEGER;
DEFINE var_mto_fin_ven_trasp2			INTEGER;
DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); DEFINE cMensajeRet2    	CHAR(60);

DEFINE contador_commit	 INTEGER;	DEFINE val_trans_Commit   SMALLINT;
DEFINE val_t1, val_t2,val_t3 SMALLINT;
--VARIABLES CC
DEFINE v_comisiones						INTEGER;
DEFINE v_pago_sostenido,v_cum_pago_sost INTEGER;	 	DEFINE dt_ultcons_varcc					DATE;
DEFINE v_cred_consulta 					VARCHAR(20);	DEFINE v_cred_respuesta  				VARCHAR(20);
DEFINE v_var_mtosdo 					CHAR(6);		DEFINE v_bkatr							INTEGER;
DEFINE v_mto_pagar_propios 				DECIMAL(18,2);	DEFINE v_mto_pagar_otros 				DECIMAL(18,2);
DEFINE v_mtovssdo_sic 					DECIMAL(18,2);	DEFINE v_sdo_actual_propio_ship 				DECIMAL(18,2);
DEFINE v_sdo_actual_otros_ship 				DECIMAL(18,2);	DEFINE v_sin_consulta					CHAR(1);
DEFINE v_consulta_sin_info				CHAR(1);		DEFINE v_bajo,v_medio, v_alto 			CHAR(1);
DEFINE v_mto_otros_vs_propios 			DECIMAL(18,2);	DEFINE v_sdo_sic 						DECIMAL(18,2);
DEFINE v_porcentaje_endeuda				DECIMAL(18,6);	--DEFINE cMensajeRet2    	CHAR(60);
--DEFINE Ini_proc 						char(22);  		DEFINE Fin_proc char(22);
DEFINE v_ant_otro_inst 					INTEGER;		DEFINE v_disposicon	smallint;	
DEFINE cfech_param						DATE; 		
DEFINE dt_ap_revolvente DATE;	DEFINE dt_ap_plazo     DATE;  DEFINE dt_ap_flex DATE;	

DEFINE v_val_facturacion INTEGER;

----CJAC CAMPOS ADICIONALES 
    DEFINE d_comision_cobranza DECIMAL (18,2);
    DEFINE d_comisionexig_cobranza DECIMAL (18,2);
    DEFINE d_saldo_corte_t DECIMAL (18,2);
    DEFINE d_sdo_corte_cred_t DECIMAL (18,2);
    DEFINE v_numero_cuenta_det CHAR(20);
    DEFINE v_meses_primer_crdbco INTEGER;
    DEFINE v_meses_ult_atr_bk   INTEGER;
    DEFINE v_veces_monto_bco_sist INTEGER;
    DEFINE v_intereses_ordinarios DECIMAL (18,2);
    DEFINE v_intereses_moratorios DECIMAL (18,2);
    DEFINE v_num_pagos_vencidos INTEGER;
    DEFINE v_tasa_contractual DECIMAL(18,5);
    DEFINE v_capital_cierre DECIMAL(18,2);
    DEFINE v_antiguedad_inst INTEGER;
    DEFINE v_veces_ult_atr1d_todos INTEGER;
    DEFINE v_cred_sit_especial INTEGER;
    DEFINE v_etapa_cred CHAR(8);
    DEFINE v_intereses_etapa3 DECIMAL(18,2);
	DEFINE v_intereses_etapa1 DECIMAL(18,2);
	DEFINE v_intereses_etapa2 DECIMAL(18,2);
    DEFINE n_scoreburo				INTEGER;
    DEFINE n_scoreotor				INTEGER;
    DEFINE v_modelo_score   CHAR(6);
    DEFINE c_evalua_cc				 CHAR(1);
    DEFINE v_periodo_rem_n  DECIMAL(18,6);
	DEFINE v_gastos_originacion DECIMAL(18,2);
	DEFINE v_num_ctanom CHAR(20);
	DEFINE v_cred_exnomina SMALLINT;
	DEFINE v_tir_mensual DECIMAL(18,2);
	DEFINE v_tasa_efectiva DECIMAL(18,5);
	DEFINE v_fecha_ult_pago DATE;
	DEFINE bandera_exigible  INTEGER;
	DEFINE v_prom_tot DECIMAL(18,10);
	DEFINE var_div   INTEGER;
	DEFINE v_codret CHAR(5);
	DEFINE v_tipogrupo CHAR(2);
	DEFINE v_hit CHAR(6);
	DEFINE psaldoInteresApoyo DECIMAL(18,2);
	DEFINE v_mtosdos DECIMAL(18,2);	
	DEFINE v_mto_exig_com DECIMAL(18,2);
	DEFINE v_mto_exig_com_cob DECIMAL(18,2);
	DEFINE v_pago_exig_com DECIMAL(18,2);
	DEFINE v_pago_exig_com_cob DECIMAL(18,2);
	DEFINE v_nombre_cte                  CHAR(50);
	DEFINE v_apellidos                   CHAR(50);
	DEFINE v_rfc                         CHAR(13); 
	DEFINE v_curp                        CHAR(18);
	DEFINE v_genero_cte                  CHAR(10); 
	DEFINE v_pago_exig_int				DECIMAL(18,2);
	DEFINE v_pago_exig_iva				DECIMAL(18,2);
	DEFINE v_pago_contractual			DECIMAL(18,2);
	DEFINE v_cap_debe					DECIMAL(18,2); 
	DEFINE v_cap_pagado					DECIMAL(18,2);
	DEFINE v_interes_debe				DECIMAL(18,2); 
	DEFINE v_interes_pagado				DECIMAL(18,2);
	DEFINE v_iva_debe					DECIMAL(18,2); 
	DEFINE v_iva_pagado					DECIMAL(18,2);
    DEFINE v_mto_exig_cap				DECIMAL(18,2);
	DEFINE v_mto_exig_int				DECIMAL(18,2);
	DEFINE v_mto_exig_iva				DECIMAL(18,2);
	DEFINE v_capital_vig_cierre			DECIMAL(18,2);
	DEFINE v_capital_trans_cierre 		DECIMAL(18,2);
	DEFINE v_capital_venc_no_exig_cierre DECIMAL(18,2);
	DEFINE v_capital_venc_exig_cierre	DECIMAL(18,2);
	DEFINE v_int_vig_cierre				DECIMAL(18,2);
	DEFINE int_venc_cierre				DECIMAL(18,2);
	DEFINE v_iva_int_vig_cierre			DECIMAL(18,2);
	DEFINE v_iva_int_venc_cierre		DECIMAL(18,2);
	
	--variable sep
	DEFINE v_dias_rem_contractual DECIMAL(18,2);
	--Oneclick
	DEFINE v_canal_suc_o_app CHAR(10);
	DEFINE v_producto CHAR(4);
	DEFINE v_empleado CHAR(1);
	DEFINE v_canal CHAR(2);
--INICIALIZACION DE VARIABLES

LET pIva                            = 0;
LET iSqlErr                         = 0;
LET iIsamErr         				= 0;
LET cErrorInfo       				= "";
LET cCodRet          				= "00000";
LET cMensajeRet    					= "REPORTE DE RIESGOS PRESTAMOS se realizo correctamente";
LET v_empresa              			= '001';
LET v_sucursal                      ='';


LET v_antecedentes_buro             = "";
LET v_antiguedad_cliente          	= 0;
LET v_atr                        	= 0;
LET v_atr1                         	= 0;
LET v_atr2                          = 0;
LET v_atr3                          = 0;
LET v_capital_exigible             	= 0;
LET v_cred_liquida_cred            	= 0;
LET v_cred_nomina                  	= 0;
LET v_grupo_originacion             = "";
LET v_delegada                    	= 0;
LET v_dias_atraso                   = 0;
LET v_eficiencia                    = 0;
LET v_facturacion                   = "";
LET v_fecha_apertura                = DATE(1);
LET v_fecha_apertura_format         = "";
LET v_fecha_ult_disp			= DATE(1);
LET v_fecha_apertura_cte            = DATE(1);
LET v_fecha_apertura_cte_format     = "";
LET v_fecha_corte                   = DATE(1);
LET v_fecha_corte_format            = "";
LET v_fecha_vencimiento             = DATE(1);
LET v_fecha_venc_format             = "";
LET v_ingresos_mens_brutos          = 0;
LET v_ingresos_mens_netos           = 0;
LET v_int_mora_copete            	= 0;
LET v_int_mora_ordinario            = 0;
LET v_interes_deven_ven_bal         = 0;
LET v_interes_deven_vig_bal         = 0;
LET v_interes_devengados_ord        = 0;
LET v_interes_vencido_bal           = 0;
LET v_interes_vencido_bal30           = 0;
LET v_interes_vencido_ord           = 0;
LET v_interes_vigente            	= 0;
LET v_iva_interes_vencido_bal       = 0;
LET v_iva_interes_vencido_ord       = 0;
LET v_iva_interes_vigente           = 0;
LET v_linea_autorizada           	= 0;
LET v_max_atr                      	= 0;
LET v_antiguedad                   	= 0;
LET v_monto_exigible               	= 0;
LET v_monto_exigible1              	= 0;
LET v_monto_exigible2              	= 0;
LET v_monto_exigible3              	= 0;
LET v_monto_exigible4              	= 0;
LET v_monto_exigible5              	= 0;
LET v_monto_exigible6              	= 0;
LET v_monto_exigible7              	= 0;
LET v_monto_exigible8              	= 0;
LET v_monto_exigible9              	= 0;
LET v_monto_exigible10              	= 0;
LET v_monto_exigible11              	= 0;
LET v_monto_exigible12              	= 0;
LET v_monto_exigible13              	= 0;
LET v_num_cliente                  	= "";
LET v_num_credito                  	= "";
LET v_num_disposiciones            	= 0;
LET v_num_producto                	= "";
LET v_pago_capital                  = 0;
LET v_pago_int_venc_bal           	= 0;
LET v_pago_int_venc_ord             = 0;
LET v_pago_interes_vigente          = 0;
LET v_pago_iva_int_venc_bal         = 0;
LET v_pago_iva_int_venc_ord         = 0;
LET v_pago_iva_interes_vigente      = 0;
LET v_pago_realizado               	= 0;
LET v_pago_realizado1               = 0;
LET v_pago_realizado2               = 0;
LET v_pago_realizado3              	= 0;
LET v_pago_realizado4              	= 0;
LET v_pago_realizado5              	= 0;
LET v_pago_realizado6               = 0;
LET v_pago_realizado7              	= 0;
LET v_pago_realizado8               = 0;
LET v_pago_realizado9               = 0;
LET v_pago_realizado10             	= 0;
LET v_pago_realizado11             	= 0;
LET v_pago_realizado12             	= 0;
LET v_pago_realizado13              = 0;
LET v_periodos_incumplimiento    	= 0;
LET v_plazo_remanente            	= 0;
LET v_plazo_total                  	= 0;
--LET v_plazo_contractual				= 0;
LET v_porcentaje_pago             	= 0;
LET v_porcentaje_uso               	= 0;
LET v_ree_tdc_anterior              = 0;
LET v_saldo_cierre                 	= 0;
LET v_saldo_corte                   = 0;
LET v_saldo_exigible              	= 0;
LET v_saldo_no_exigible             = 0;
LET v_status_fin_mes               	= "";
LET v_max_secuencia                 = 0;
LET v_num_cta                       = ""; 

LET v_dia_corte						= 0;
LET v_antimaecred                   =0;
LET v_antimaecredcrd                =0;
LET v_fecha                         =DATE(1);
LET dia_corte_ant                    =0;
LET num_corte1                       ='';

LET v_capital_vigente    =0;
LET v_capital_vencido    =0;
LET v_int_vigente        =0;
LET v_iva_vigente        =0;
LET v_interes_orden      =0;
LET v_iva_interes_orden  =0;
LET v_int_venc_bal		 =0; 
LET v_iva_venc_bal		 = 0;

LET v_capital_vigente1    =0;
LET v_capital_vencido1    =0;
LET v_int_vigente1        =0;
LET v_iva_vigente1        =0;
LET v_interes_orden1      =0;
LET v_iva_interes_orden1  =0;
LET v_int_venc_bal1		 =0; 
LET v_iva_venc_bal1	 	 = 0;

LET v_capital_vigente2    =0;
LET v_capital_vencido2    =0;
LET v_int_vigente2        =0;
LET v_iva_vigente2        =0;
LET v_interes_orden2      =0;
LET v_iva_interes_orden2  =0;
LET v_int_venc_bal2		 =0; 
LET v_iva_venc_bal2  	 = 0;

LET v_capital_vigente3    =0;
LET v_capital_vencido3    =0;
LET v_int_vigente3        =0;
LET v_iva_vigente3        =0;
LET v_interes_orden3      =0;
LET v_iva_interes_orden3  =0;
LET v_int_venc_bal3		 =0; 
LET v_iva_venc_bal3		 = 0;

LET v_capital_vigente4    =0;
LET v_capital_vencido4    =0;
LET v_int_vigente4        =0;
LET v_iva_vigente4        =0;
LET v_interes_orden4      =0;
LET v_iva_interes_orden4  =0;
LET v_int_venc_bal4		 =0; 
LET v_iva_venc_bal4		 = 0;

LET v_capital_vigente5    =0;
LET v_capital_vencido5    =0;
LET v_int_vigente5        =0;
LET v_iva_vigente5        =0;
LET v_interes_orden5      =0;
LET v_iva_interes_orden5  =0;
LET v_int_venc_bal5		 =0; 
LET v_iva_venc_bal5		 = 0;

LET v_capital_vigente6    =0;
LET v_capital_vencido6    =0;
LET v_int_vigente6        =0;
LET v_iva_vigente6        =0;
LET v_interes_orden6      =0;
LET v_iva_interes_orden6  =0;
LET v_int_venc_bal6		 =0; 
LET v_iva_venc_bal6		 = 0;

LET v_prom1               =0;
LET v_prom2               =0;
LET v_prom3               =0;
LET v_prom4               =0;
LET v_prom5               =0;
LET v_prom6               =0;
LET v_prom7               =0;

LET c_CodRet                         =""; 
LET mMensaje                        ="";  
LET dFechaPer0                      =DATE(1); 
LET dFechaPer1                      =DATE(1); 
LET dFechaPer2                      =DATE(1);
LET dFechaPer3                      =DATE(1); 
LET dFechaPer4                      =DATE(1); 
LET dFechaPer5                      =DATE(1); 
LET dFechaPer6                      =DATE(1); 
LET dFechaPer7                      =DATE(1); 
LET dFechaPer8                      =DATE(1); 
LET dFechaPer9                      =DATE(1);
LET dFechaPer10                     =DATE(1);
LET dFechaPer11                     =DATE(1);
LET dFechaPer12                     =DATE(1);
LET dFechaPer13                     =DATE(1);

LET dTotalVencido					=0;
LET dVencidoOrden					=0;
LET dInteresVencido					=0;
LET dOtrasEstimaciones				=0;

LET vprod_proc 						="";
LET var_mto_fin_ven_trasp	=0;
LET var_mto_fin_ven_trasp2			=0;

--Variables CC
LET v_pago_sostenido 				=0;     LET v_cum_pago_sost 				=0;  
LET dt_ultcons_varcc				= date(1);LET  v_cred_consulta   			="";	LET  v_cred_respuesta  				="";
LET  v_var_mtosdo 					="";	LET  v_bkatr						=0;		LET  v_mto_pagar_propios 			=0;
LET  v_mto_pagar_otros 				= 0;	LET  v_mtovssdo_sic 				= 0;	LET  v_sdo_actual_propio_ship 			=0;
LET  v_sdo_actual_otros_ship 			= 0;	LET  v_sin_consulta					="";	LET  v_consulta_sin_info			="";
LET  v_alto 						="";	LET  v_bajo 						="";	LET  v_medio 						="";
LET  v_mto_otros_vs_propios 		= 0;	LET  v_sdo_sic 						= 0;	LET v_porcentaje_endeuda			=0;
LET v_ant_otro_inst 				= 0;	LET v_disposicon 					= 0;	LET cfech_param						= date(1); 			
LET contador_commit = 	0;	LET val_trans_Commit = 	0;
LET val_t1 = 	0; LET  val_t2  = 	0; LET val_t3 = 	0;
LET dt_ap_revolvente 		= date(1);	LET dt_ap_plazo 			= date(1); 		LET dt_ap_flex = date(1);

LET v_val_facturacion = 0;

--INICIALIZACION DE CAMPOS ADICIONALES
    LET d_comision_cobranza = 0;
    LET d_comisionexig_cobranza = 0;
    LET d_saldo_corte_t = 0;
    LET d_sdo_corte_cred_t = 0;
    LET v_numero_cuenta_det = '';
    LET v_meses_primer_crdbco = 0;
    LET v_meses_ult_atr_bk   = 0;
    LET v_veces_monto_bco_sist = 0;
    LET v_intereses_ordinarios = 0;
    LET v_intereses_moratorios = 0; 
    LET v_num_pagos_vencidos =0;
    LET v_tasa_contractual = 0;
    LET v_capital_cierre = 0;
    LET v_antiguedad_inst = 0;
    LET v_veces_ult_atr1d_todos = 0;
    LET v_cred_sit_especial = 0;
    LET v_etapa_cred = '';
    LET v_intereses_etapa1 = 0;
	LET v_intereses_etapa2 = 0;
	LET v_intereses_etapa3 = 0;
    LET n_scoreburo	= 0;
    LET n_scoreotor	= 0;
    LET v_modelo_score ='';
    LET c_evalua_cc ='';
    LET v_periodo_rem_n = 0;
	LET v_gastos_originacion =0;
	LET v_num_ctanom = '';
	LET v_cred_exnomina = 0;
	LET v_tir_mensual = 0;
	LET v_tasa_efectiva =0;
	LET v_fecha_ult_pago = DATE(1);
	LET bandera_exigible = 0 ;
	LET v_prom_tot = 0;
	LET var_div   = 0;
	LET v_codret = '';
	LET v_tipogrupo = '';
	LET v_hit = '';
	LET psaldoInteresApoyo=0;
	LET v_codret = '';
	LET v_tipogrupo = '';
	LET v_hit = '';
	LET v_mtosdos='';
	LET v_mto_exig_com =0;
	LET v_mto_exig_com_cob =0;
	LET v_pago_exig_com =0;
	LET v_pago_exig_com_cob =0;
    LET v_nombre_cte='';
	LET v_apellidos='';
	LET v_rfc =''; 
	LET v_curp='';
	LET v_genero_cte='';
	LET v_pago_exig_int=0;
	LET v_pago_exig_iva=0;
	LET v_pago_contractual=0;
	LET v_cap_debe=0; 
	LET v_cap_pagado=0;
	LET v_interes_debe=0;
	LET v_interes_pagado=0;
	LET v_iva_debe=0;
	LET v_iva_pagado=0;
    LET v_mto_exig_cap=0;
	LET v_mto_exig_int=0;
	LET v_mto_exig_iva=0;
	LET v_capital_vig_cierre=0;
	LET v_capital_trans_cierre=0;
	LET v_capital_venc_no_exig_cierre=0;
	LET v_capital_venc_exig_cierre=0;
	LET v_int_vig_cierre=0;
	LET int_venc_cierre	=0;
	LET v_iva_int_vig_cierre=0;
	LET v_iva_int_venc_cierre=0;
	
	--nuevo sep
	LET v_dias_rem_contractual = 0;
	--Oneclick
	LET v_canal_suc_o_app ='';
	LET v_producto='';
	LET v_empleado= '';
	LET v_canal='';
BEGIN
    --Errores no controlados.
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
	  	  LET cMensajeRet2 = '';
		  IF (val_trans_Commit = -1) THEN
			rollback work;
		  END IF; 
		  RETURN cCodRet,v_num_credito,cMensajeRet2;
    END EXCEPTION;

    --SET DEBUG FILE TO "/RESPALDOSNEW/SI1440/sp_geninsumos_calif_pp_parte_v3.out";
    --TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;
	
SELECT  pri_dia_mes - 1 units day
INTO  pPeriodo
FROM sd_fechas;

--LET pPeriodo = mdy('11','30','2023'); --pruebas
LET piniPeriodo = mdy(month(pPeriodo),'01',year(pPeriodo));

--Reproceso 
--LET pPeriodo = mdy('02','28','2022');
--LET piniPeriodo = mdy('02','01','2022');
--Reproceso 

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),100)) <> 0 OR (mod(year(pPeriodo),400) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

IF pEjecucion = 1 THEN 
	LET vprod_proc = '6300';
ELIF  pEjecucion = 2 THEN
	LET vprod_proc = '7600';
ELIF  pEjecucion =  3 THEN
	LET vprod_proc = '7700';
ELIF  pEjecucion = 4 THEN
	LET vprod_proc = '6400';
ELIF  pEjecucion = 5 THEN
	LET vprod_proc = '9100';
ELIF  pEjecucion = 6 THEN
	LET vprod_proc = '9300';
ELSE
	LET cCodRet     = "02000";
    LET cMensajeRet = "ERROR: Opcion sin producto asignado";

	RETURN cCodRet, cMensajeRet, cMensajeRet2;
END IF;	
	
SELECT MAX(fecha_info) 
INTO dt_ultcons_varcc
FROM bdiburo:br_variables_cc_cnr;	
    FOREACH WITH HOLD

        SELECT a.num_credito, 
        a.numcte ,
        a.sucursal,
        a.num_producto,
        a.periodo_plazo facturacion,
        mdy(month(a.fecha_apertura),day(a.fecha_apertura),year(a.fecha_apertura)),
        TO_CHAR(a.fecha_apertura, '%Y/%m/%d') as fecha_apertura_format, 
        mdy(month(a.fecha_vencim), day(a.fecha_vencim), year(a.fecha_vencim)) fecha_vencimiento,
        TO_CHAR(a.fecha_vencim, '%Y/%m/%d') as fecha_venc_format,
        a.status_cred status_fin_mes,
        e.dia_corte,
      --  case when e.dia_corte=31 then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo)) 
			-- when month(pPeriodo)= 2 and e.dia_corte in(31,30,29) then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo))
		    --else mdy(month(pPeriodo),(dia_corte),year(pPeriodo)) end fecha_corte,
        0 cred_liquida_cred,
        0 delegada,
        1 num_disposiciones,
        c.dias_atraso,
        b.sdo_moratorio int_mora_copete,
        b.sdo_contab_mora int_mora_ordinario,
        b.monto_otorgado linea_autorizada,
        g.evalua_cc antecedentes_buro,
        g.grupo grupo_originacion,
        CASE when a.num_producto='6400' then 1 else 0 end cred_nomina ,
        CASE when a.num_producto='6011' then 1 else 0 end ree_tdc_anterior,
        g.situacion_pago eficiencia,
        --trunc(months_between(e.fecha_proceso,a.fecha_apertura)) antiguedad,
        round((b.sdo_cap_insoluto / b.monto_otorgado),6)porcentaje_uso,
        CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_total,
        --((a.fecha_vencim-a.fecha_apertura)/30.4) as plazo_total,  --CJAC  CAMBIO DE DEFINICION plazo_total
        round((fecha_vencim -a.fecha)/ 365.25,5) plazo_remanente,
		--CASE WHEN round((fecha_vencim -a.fecha)/ 365.25,5) <= 0 THEN 10 ELSE round((fecha_vencim -a.fecha)/ 365.25,5) END plazo_remanente,
        --CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_contractual,
        a.tasa_interes,b.mto_fin_ven_trasp,
		c.fecha_ultimo_pago_h,status_cred
        INTO v_num_credito,v_num_cliente,v_sucursal,v_num_producto,v_facturacion,v_fecha_apertura,v_fecha_apertura_format,v_fecha_vencimiento,
        v_fecha_venc_format,v_status_fin_mes,
        v_dia_corte--,v_fecha_corte
		,v_cred_liquida_cred,v_delegada,v_num_disposiciones,v_dias_atraso,v_int_mora_copete,v_int_mora_ordinario,
        v_linea_autorizada,v_antecedentes_buro,v_grupo_originacion,v_cred_nomina,v_ree_tdc_anterior,v_eficiencia,--v_antiguedad,
        v_porcentaje_uso,v_plazo_total,v_plazo_remanente, v_tasa_contractual,v_num_pagos_vencidos, v_fecha_ult_pago,v_etapa_cred
        FROM sd_maecredcontcrd a
        INNER JOIN sd_maesdoscontcrd b 
        ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) 
        LEFT JOIN sd_indicador_cred_crd c
        --ON (a.empresa = c.empresa and c.fecha_insert = a.fecha and a.num_credito = c.num_credito)  --IPCB Se cambia a la historica
		ON (a.empresa = c.empresa and a.num_credito = c.num_credito)  --IPCB Se cambia a la operativa
        INNER JOIN sd_maecredanexocrd e 
        ON (a.empresa = e.empresa and a.num_credito = e.num_credito)
        LEFT JOIN bdisolic:ss_revision_determinacion f
        ON (a.empresa=f.empresa and a.num_credito=f.num_solicitud and a.numcte=f.numcte)
        LEFT JOIN bdisolic:ss_resum_scor_fin g 
        on (a.empresa=g.empresa and a.num_credito=g.num_solicitud)
        WHERE a.fecha= pPeriodo
        AND a.num_producto = vprod_proc   --   in('6300','7600', '7700', '6400')
		and a.num_credito not in (select num_credito from sd_insumos_calif_pp where fecha_cierre = pPeriodo and num_producto =vprod_proc)
		--and a.num_credito in ('760012765938')
        --and a.num_credito in ('630014344372','770000083178','760000353986','770000083509','630137974287','760000517234','770000152148',
--'630000044713','630039226216','630000362339','760000208883','760000274760','760000351428','770000025500','770000037141','770000053676',
--'630006655520','630007897436','630004249011','630005472141','630000089858','630001139801','630008324885','640000084619','640000144967')

			
		IF (val_trans_Commit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET val_trans_Commit = -1;
        END IF; 
		
		IF v_num_producto='9300' THEN
			EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif_13('001',v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
			INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7,dFechaPer8, dFechaPer9, dFechaPer10, dFechaPer11, dFechaPer12, dFechaPer13;
		ELSE
			EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif('001',v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
			INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;
		END IF;
		

		
		
		
		LET v_fecha_corte = dFechaPer0;
        LET v_fecha_corte_format = TO_CHAR(dFechaPer0, '%Y/%m/%d'); 

		LET v_dia_corte = day(v_fecha_corte);
		
		LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));		
        LET v_monto_exigible               	= 0;
        LET v_monto_exigible1              	= 0;
        LET v_monto_exigible2              	= 0;
        LET v_monto_exigible3              	= 0;
        LET v_monto_exigible4              	= 0;
        LET v_monto_exigible5              	= 0;
        LET v_monto_exigible6              	= 0;
		LET v_monto_exigible7              	= 0;
        LET v_monto_exigible8              	= 0;
        LET v_monto_exigible9              	= 0;
        LET v_monto_exigible10             	= 0;
        LET v_monto_exigible11             	= 0;
        LET v_monto_exigible12             	= 0;
        LET v_monto_exigible13             	= 0;

        LET v_pago_realizado               	= 0;
        LET v_pago_realizado1               = 0;
        LET v_pago_realizado2               = 0;
        LET v_pago_realizado3              	= 0;
        LET v_pago_realizado4              	= 0;
        LET v_pago_realizado5              	= 0;
        LET v_pago_realizado6               = 0;
		LET v_pago_realizado7              	= 0;
        LET v_pago_realizado8               = 0;
        LET v_pago_realizado9               = 0;
        LET v_pago_realizado10             	= 0;
        LET v_pago_realizado11             	= 0;
        LET v_pago_realizado12             	= 0;
        LET v_pago_realizado13              = 0;

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
		LET v_int_venc_bal		 =0; 
		LET v_iva_venc_bal		 = 0;

        LET v_capital_vigente1    =0;
        LET v_capital_vencido1    =0;
        LET v_int_vigente1        =0;
        LET v_iva_vigente1        =0;
        LET v_interes_orden1      =0;
        LET v_iva_interes_orden1  =0;
		LET v_int_venc_bal1		 =0; 
		LET v_iva_venc_bal1		 = 0;

        LET v_capital_vigente2    =0;
        LET v_capital_vencido2    =0;
        LET v_int_vigente2        =0;
        LET v_iva_vigente2        =0;
        LET v_interes_orden2      =0;
        LET v_iva_interes_orden2  =0;
		LET v_int_venc_bal2		 =0; 
		LET v_iva_venc_bal2		 = 0;

        LET v_capital_vigente3    =0;
        LET v_capital_vencido3    =0;
        LET v_int_vigente3        =0;
        LET v_iva_vigente3        =0;
        LET v_interes_orden3      =0;
        LET v_iva_interes_orden3  =0;
		LET v_int_venc_bal3		 =0; 
		LET v_iva_venc_bal3		 = 0;

        LET v_capital_vigente4    =0;
        LET v_capital_vencido4    =0;
        LET v_int_vigente4        =0;
        LET v_iva_vigente4        =0;
        LET v_interes_orden4      =0;
        LET v_iva_interes_orden4  =0;
		LET v_int_venc_bal4		 =0; 
		LET v_iva_venc_bal4		 = 0;

        LET v_capital_vigente5    =0;
        LET v_capital_vencido5    =0;
        LET v_int_vigente5        =0;
        LET v_iva_vigente5        =0;
        LET v_interes_orden5      =0;
        LET v_iva_interes_orden5  =0;
		LET v_int_venc_bal5		 =0; 
		LET v_iva_venc_bal5		 = 0;

        LET v_capital_vigente6    =0;
        LET v_capital_vencido6    =0;
        LET v_int_vigente6        =0;
        LET v_iva_vigente6        =0;
        LET v_interes_orden6      =0;
        LET v_iva_interes_orden6  =0;
		LET v_int_venc_bal6		 =0; 
		LET v_iva_venc_bal6		 = 0;
		
		LET var_mto_fin_ven_trasp	=0;
		LET var_mto_fin_ven_trasp2	=0;

		LET v_val_facturacion = 0;
     
            --FOREACH WITH HOLD
			    --CAMPO 20 fecha_apertura_cte
               /* SELECT min(mdy(month(fecha_apertura),day(fecha_apertura),year(fecha_apertura))) INTO v_fecha_apertura_cte 
				FROM (SELECT min(fecha_apertura)fecha_apertura
					  FROM sd_maecred WHERE numcte=v_num_cliente   --Tarjetas
					union all
					  SELECT min(fecha_apertura)fecha_apertura		
					  FROM sd_maecredcrd WHERE numcte=v_num_cliente AND num_producto <> '6800'  --Prestamos y nomina
					union all
					  SELECT min(fecha_otorga) fecha_apertura
                      FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
															       WHERE numcte = v_num_cliente AND num_producto = '6800'))  --Flexibles	
																   */
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
																                   
                LET v_fecha_apertura_cte_format = TO_CHAR(v_fecha_apertura_cte, '%Y/%m/%d');

                --CAMPO 3 antiguedad_cliente   
				LET v_antiguedad_cliente = (year(pPeriodo) - year(v_fecha_apertura_cte)) * 12 + (month(pPeriodo) - month(v_fecha_apertura_cte));

				 --CAMPOS 4, 5, 6 y 7
                --IF v_status_fin_mes='BA' or v_status_fin_mes='BT' THEN				
					--IF v_fecha_vencimiento >= pPeriodo THEN
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
					
						SELECT nvl(atr,0) 
						INTO v_atr3
						FROM sd_maesdoscontcrd 
						WHERE num_credito =v_num_credito
						AND fecha=(piniPeriodo -2 units month ) - 1 units day;  --31/03/2018
                    /*ELSE
						--Si ya llego a su fecha de vencimiento
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
                /*ELSE
                    LET v_atr=0;
                   /* LET v_atr1=0;
                    LET v_atr2=0;
                    LET v_atr3=0;*/	--IPCB Se corrige bloque ya que si es AA actualmente no sabemos como estuvo previamente.
				   /* SELECT nvl(mto_fin_ven_trasp,0) 
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
				
				IF v_facturacion='Q' THEN  --IPCB se divide a la mitad ya que actualmente son recibos no pagados. Conforme a solicitud Riesgos @22 enero2019
					IF v_atr > 0 THEN
						LET v_atr = (v_atr/2);
					END IF;
					IF v_atr1 > 0 THEN
						LET v_atr1 = (v_atr1/2);
					END IF;
					IF v_atr2 > 0 THEN
						LET v_atr2 = (v_atr2/2);
					END IF;
					IF v_atr3 > 0 THEN
						LET v_atr3 = (v_atr3/2);
					END IF;
				END IF;	
               --CAMPO 9 CAPITAL EXIGIBLE								   
				LET v_fecha =  v_fecha_corte -1 units day;
				
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;
								
                SELECT nvl(monto_financiado,0) INTO v_capital_exigible
                FROM sd_maesdoshistcrd 
                WHERE fecha =v_fecha and num_credito =v_num_credito;
				--CAMPO 10 COMISIONES
				LET v_comisiones = 0;               
            
                --CAMPO 23 ingresos_mens_brutos
                SELECT ingreso_mensual INTO v_ingresos_mens_brutos
                FROM bdinteg:si_ingresos 
                WHERE numcte =v_num_cliente and sec_ingreso=(select max(sec_ingreso) FROM bdinteg:si_ingresos 
                WHERE numcte =v_num_cliente);

				LET v_ingresos_mens_netos=v_ingresos_mens_brutos;

                --CAMPO 24 ingresos_mens_netos
                IF v_num_producto = '6400' THEN		
                    SELECT num_cta 
                    INTO v_num_cta
                    FROM sd_ctascarg where num_credito=v_num_credito;

					SELECT SUM((NVL(monto_tot,0)))
					  INTO v_ingresos_mens_netos
					  FROM bdicheq:sc_movhis mov
                      INNER JOIN sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
					  WHERE fech_alt between piniPeriodo  and pPeriodo
					  AND empresa = '001' 
					  AND cuenta = v_num_cta 
					  AND cancelad <> 'S';					   
					
					LET v_ingresos_mens_brutos=v_ingresos_mens_netos;
				END IF;
             
                --CAMPO 27,28,29
                SELECT 
                CASE WHEN MONTH(pPeriodo)='01' OR  MONTH(pPeriodo)='03' OR MONTH(pPeriodo)='05' OR MONTH(pPeriodo)='07' OR MONTH(pPeriodo)='08' OR MONTH(pPeriodo)='10' OR MONTH(pPeriodo)='12' 
                THEN int_venc_bal31 
                    ELSE CASE WHEN MONTH(pPeriodo)='04' OR  MONTH(pPeriodo)='06' OR MONTH(pPeriodo)='09' OR MONTH(pPeriodo)='11' 
                    THEN int_venc_bal30
                        ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 1
						THEN int_venc_bal29
							ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 0
							THEN int_venc_bal28  END
						END	
                    END
                END,
                CASE WHEN MONTH(pPeriodo)='01' OR  MONTH(pPeriodo)='03' OR MONTH(pPeriodo)='05' OR MONTH(pPeriodo)='07' OR MONTH(pPeriodo)='08' OR MONTH(pPeriodo)='10' OR MONTH(pPeriodo)='12' 
				THEN intvig31 
					ELSE CASE WHEN MONTH(pPeriodo)='04' OR  MONTH(pPeriodo)='06' OR MONTH(pPeriodo)='09' OR MONTH(pPeriodo)='11' 
					THEN intvig30 
						ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 1
						THEN intvig29
							ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 0
							THEN intvig28  END
						END	
					END
				END,
                CASE WHEN MONTH(pPeriodo)='01' OR  MONTH(pPeriodo)='03' OR MONTH(pPeriodo)='05' OR MONTH(pPeriodo)='07' OR MONTH(pPeriodo)='08' OR MONTH(pPeriodo)='10' OR MONTH(pPeriodo)='12' 
                THEN (intvenc31-int_venc_bal31) 
                    ELSE CASE WHEN MONTH(pPeriodo)='04' OR  MONTH(pPeriodo)='06' OR MONTH(pPeriodo)='09' OR MONTH(pPeriodo)='11' 
                    THEN (intvenc30-int_venc_bal30) 
                        ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 1
						THEN (intvenc29-int_venc_bal29)
							ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 0
							THEN (intvenc28-int_venc_bal28)  END
						END	
                    END
                END,
                CASE WHEN MONTH(pPeriodo)='01' OR  MONTH(pPeriodo)='03' OR MONTH(pPeriodo)='05' OR MONTH(pPeriodo)='07' OR MONTH(pPeriodo)='08' OR MONTH(pPeriodo)='10' OR MONTH(pPeriodo)='12' 
                THEN (int_venc_bal31) 
                    ELSE CASE WHEN MONTH(pPeriodo)='04' OR  MONTH(pPeriodo)='06' OR MONTH(pPeriodo)='09' OR MONTH(pPeriodo)='11' 
                    THEN (int_venc_bal30) 
                        ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 1
						THEN int_venc_bal29
							ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 0
							THEN (int_venc_bal28)  END
						END	
                    END
                END
                INTO v_interes_deven_ven_bal,v_interes_deven_vig_bal,v_interes_devengados_ord,v_interes_vencido_bal30
                FROM sd_sdodiariocrd
                WHERE num_credito=v_num_credito and fecha=piniperiodo;
				
				
				/*IF v_status_fin_mes ='AA' OR v_status_fin_mes='BA' OR (v_status_fin_mes='E1' AND v_atr=0 AND v_dias_atraso=0) OR ((v_status_fin_mes='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90))) THEN
					SELECT 					
					CASE WHEN MONTH(pPeriodo)='01' OR  MONTH(pPeriodo)='03' OR MONTH(pPeriodo)='05' OR MONTH(pPeriodo)='07' OR MONTH(pPeriodo)='08' OR MONTH(pPeriodo)='10' OR MONTH(pPeriodo)='12' 
					THEN intvig31 
						ELSE CASE WHEN MONTH(pPeriodo)='04' OR  MONTH(pPeriodo)='06' OR MONTH(pPeriodo)='09' OR MONTH(pPeriodo)='11' 
						THEN intvig30 
							ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 1
							THEN intvig29
								ELSE CASE WHEN MONTH(pPeriodo)='02' AND flag_aniobis = 0
								THEN intvig28  END
							END	
						END
					END					
					INTO v_interes_deven_vig_bal
                FROM sd_sdodiariocrd
                WHERE num_credito=v_num_credito and fecha=piniperiodo;
				ELSE
					LET v_interes_deven_vig_bal=0;
				END IF;*/

                --CAMPO 30,31,32,33,34,35
                 if (v_dia_corte <=15) then
                        if (v_dia_corte <= 7) then
                            if  (v_dia_corte = 1)  then
								IF month(pPeriodo) IN (1,2,4,6,8,9,11) THEN
									 SELECT int_venc_bal31, intvig31, ((intvenc31)-(int_venc_bal31)),ivaint_venc_bal31, ((ivaintvenc31)-(ivaint_venc_bal31)),ivaintvig31
									INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
									FROM sd_sdodiariocrd
									WHERE num_credito=v_num_credito and fecha=monthadd(piniperiodo,-1) ;  															
								ELIF month(pPeriodo) IN (5,7,10,12) THEN
									SELECT int_venc_bal30, intvig30, ((intvenc30)-(int_venc_bal30)),ivaint_venc_bal30, ((ivaintvenc30)-(ivaint_venc_bal30)),ivaintvig30
                                   INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                   FROM sd_sdodiariocrd
                                   WHERE num_credito=v_num_credito and fecha=monthadd(piniperiodo,-1) ; 
								ELIF MONTH(pPeriodo) in(3) THEN
									IF flag_aniobis = 1 THEN							
									   SELECT int_venc_bal29, intvig29, ((intvenc29)-(int_venc_bal29)),ivaint_venc_bal29, ((ivaintvenc29)-(ivaint_venc_bal29)),ivaintvig29
									   INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
									   FROM sd_sdodiariocrd
										WHERE num_credito=v_num_credito and fecha=monthadd(piniperiodo,-1) ; 
									ELSE
										SELECT int_venc_bal28, intvig28, ((intvenc28)-(int_venc_bal28)),ivaint_venc_bal28, ((ivaintvenc28)-(ivaint_venc_bal28)),ivaintvig28
										INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
										FROM sd_sdodiariocrd	
										WHERE num_credito=v_num_credito and fecha=monthadd(piniperiodo,-1) ; 
									END IF;	
								END IF;                                                   
                             elif (v_dia_corte = 2) then
								IF month(pPeriodo) IN (1) THEN
									SELECT int_venc_bal31, intvig31, ((intvenc31)-(int_venc_bal31)),ivaint_venc_bal31, ((ivaintvenc31)-(ivaint_venc_bal31)),ivaintvig31
									INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
									FROM sd_sdodiariocrd
									WHERE num_credito=v_num_credito and fecha=monthadd(piniperiodo,-1) ; 
								ELSE
									SELECT int_venc_bal1, intvig1, ((intvenc1)-(int_venc_bal1)),ivaint_venc_bal1, ((ivaintvenc1)-(ivaint_venc_bal1)),ivaintvig1
									INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
									FROM sd_sdodiariocrd
									WHERE num_credito=v_num_credito and fecha=piniperiodo;
								END IF;	
                             elif (v_dia_corte = 3) then
                                SELECT int_venc_bal2, intvig2, ((intvenc2)-(int_venc_bal2)),ivaint_venc_bal2, ((ivaintvenc2)-(ivaint_venc_bal2)),ivaintvig2
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 4) then
                                SELECT int_venc_bal3, intvig3, ((intvenc3)-(int_venc_bal3)),ivaint_venc_bal3, ((ivaintvenc3)-(ivaint_venc_bal3)),ivaintvig3
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 5) then
                                SELECT int_venc_bal4, intvig4, ((intvenc4)-(int_venc_bal4)),ivaint_venc_bal4, ((ivaintvenc4)-(ivaint_venc_bal4)),ivaintvig4
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 6) then
                                SELECT int_venc_bal5, intvig5, ((intvenc5)-(int_venc_bal5)),ivaint_venc_bal5, ((ivaintvenc5)-(ivaint_venc_bal5)),ivaintvig5
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             else
                                SELECT int_venc_bal6, intvig6, ((intvenc6)-(int_venc_bal6)),ivaint_venc_bal6, ((ivaintvenc6)-(ivaint_venc_bal6)),ivaintvig6
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;
                             end if; -- 1-7
                         else
                             if (v_dia_corte = 8) then
                                SELECT int_venc_bal7, intvig7, ((intvenc7)-(int_venc_bal7)),ivaint_venc_bal7, ((ivaintvenc7)-(ivaint_venc_bal7)),ivaintvig7
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 9) then
                                SELECT int_venc_bal8, intvig8, ((intvenc8)-(int_venc_bal8)),ivaint_venc_bal8, ((ivaintvenc8)-(ivaint_venc_bal8)),ivaintvig8
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 10) then
                                SELECT int_venc_bal9, intvig9, ((intvenc9)-(int_venc_bal9)),ivaint_venc_bal9, ((ivaintvenc9)-(ivaint_venc_bal9)),ivaintvig9
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 11) then
                                SELECT int_venc_bal10, intvig10, ((intvenc10)-(int_venc_bal10)),ivaint_venc_bal10, ((ivaintvenc10)-(ivaint_venc_bal10)),ivaintvig10
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 12) then
                                SELECT int_venc_bal11, intvig11, ((intvenc11)-(int_venc_bal11)),ivaint_venc_bal11, ((ivaintvenc11)-(ivaint_venc_bal11)),ivaintvig11
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 13) then
                                SELECT int_venc_bal12, intvig12, ((intvenc12)-(int_venc_bal12)),ivaint_venc_bal12, ((ivaintvenc12)-(ivaint_venc_bal12)),ivaintvig12
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 14) then
                                SELECT int_venc_bal13, intvig13, ((intvenc13)-(int_venc_bal13)),ivaint_venc_bal13, ((ivaintvenc13)-(ivaint_venc_bal13)),ivaintvig13
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 


                             else
                                SELECT int_venc_bal14, intvig14, ((intvenc14)-(int_venc_bal14)),ivaint_venc_bal14, ((ivaintvenc14)-(ivaint_venc_bal14)),ivaintvig14
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             end if; -- if 8-15
                         end if; -- if 7
                     else
                         if (v_dia_corte <= 23) then
                             if (v_dia_corte = 16) then
                                SELECT int_venc_bal15, intvig15, ((intvenc15)-(int_venc_bal15)),ivaint_venc_bal15, ((ivaintvenc15)-(ivaint_venc_bal15)),ivaintvig15
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 17) then
                                SELECT int_venc_bal16, intvig16, ((intvenc16)-(int_venc_bal16)),ivaint_venc_bal16, ((ivaintvenc16)-(ivaint_venc_bal16)),ivaintvig16
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 


                             elif (v_dia_corte = 18) then
                                SELECT int_venc_bal17, intvig17, ((intvenc17)-(int_venc_bal17)),ivaint_venc_bal17, ((ivaintvenc17)-(ivaint_venc_bal17)),ivaintvig17
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 


                             elif (v_dia_corte = 19) then
                                SELECT int_venc_bal18, intvig18, ((intvenc18)-(int_venc_bal18)),ivaint_venc_bal18, ((ivaintvenc18)-(ivaint_venc_bal18)),ivaintvig18
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 20) then
                                SELECT int_venc_bal19, intvig19, ((intvenc19)-(int_venc_bal19)),ivaint_venc_bal19, ((ivaintvenc19)-(ivaint_venc_bal19)),ivaintvig19
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             elif (v_dia_corte = 21) then
                                SELECT int_venc_bal20, intvig20, ((intvenc20)-(int_venc_bal20)),ivaint_venc_bal20, ((ivaintvenc20)-(ivaint_venc_bal20)),ivaintvig20
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 22) then
                                SELECT int_venc_bal21, intvig21, ((intvenc21)-(int_venc_bal21)),ivaint_venc_bal21, ((ivaintvenc21)-(ivaint_venc_bal21)),ivaintvig21
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;

                             else
                                SELECT int_venc_bal22, intvig22, ((intvenc22)-(int_venc_bal22)),ivaint_venc_bal22, ((ivaintvenc22)-(ivaint_venc_bal22)),ivaintvig22
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 
                             end if; --if 16-23
                         else
                             if (v_dia_corte = 24) then
                                SELECT int_venc_bal23, intvig23, ((intvenc23)-(int_venc_bal23)),ivaint_venc_bal23, ((ivaintvenc23)-(ivaint_venc_bal23)),ivaintvig23
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 25) then
                                SELECT int_venc_bal24, intvig24, ((intvenc24)-(int_venc_bal24)),ivaint_venc_bal24, ((ivaintvenc24)-(ivaint_venc_bal24)),ivaintvig24
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 26) and (month(v_fecha_corte)= 12) then
                                SELECT int_venc_bal24, intvig24, ((intvenc24)-(int_venc_bal24)),ivaint_venc_bal24, ((ivaintvenc24)-(ivaint_venc_bal24)),ivaintvig24
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 
								
							 elif (v_dia_corte = 26) and (month(v_fecha_corte)<> 12) then								   
                                SELECT int_venc_bal25, intvig25, ((intvenc25)-(int_venc_bal25)),ivaint_venc_bal25, ((ivaintvenc25)-(ivaint_venc_bal25)),ivaintvig25
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;  

                             elif (v_dia_corte = 27) then
                                SELECT int_venc_bal26, intvig26, ((intvenc26)-(int_venc_bal26)),ivaint_venc_bal26, ((ivaintvenc26)-(ivaint_venc_bal26)),ivaintvig26
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo;


                             elif (v_dia_corte = 28) then
                                SELECT int_venc_bal27, intvig27, ((intvenc27)-(int_venc_bal27)),ivaint_venc_bal27, ((ivaintvenc27)-(ivaint_venc_bal27)),ivaintvig27
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 29) then
                                SELECT int_venc_bal28, intvig28, ((intvenc28)-(int_venc_bal28)),ivaint_venc_bal28, ((ivaintvenc28)-(ivaint_venc_bal28)),ivaintvig28
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             elif (v_dia_corte = 30) then
                                SELECT int_venc_bal29, intvig29, ((intvenc29)-(int_venc_bal29)),ivaint_venc_bal29, ((ivaintvenc29)-(ivaint_venc_bal29)),ivaintvig29
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 

                             else
                                SELECT int_venc_bal30, intvig30, ((intvenc30)-(int_venc_bal30)),ivaint_venc_bal30, ((ivaintvenc30)-(ivaint_venc_bal30)),ivaintvig30
                                INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                FROM sd_sdodiariocrd
                                WHERE num_credito=v_num_credito and fecha=piniperiodo; 
                             end if; --if 24-31
                        end if; -- if 23
                   end if; -- if 15               
                
				IF v_num_producto = '6400' and v_status_fin_mes = 'AA' or ((v_status_fin_mes in ('E1') AND v_atr=0 and v_dias_atraso=0))THEN
					SELECT count(*)   INTO v_val_facturacion  
					FROM bdicred:sd_amortiza_creditocrd 
					WHERE fecha_cuota >= piniperiodo and fecha_cuota <= pPeriodo
					  AND num_Credito = v_num_credito ;
					 -- AND capital_status in (1,2,7) ;
				
					IF v_val_facturacion = 0 THEN						  
						LET v_interes_vencido_bal           = 0;
						LET v_interes_vencido_ord           = 0;
						LET v_interes_vigente            	= 0;
						LET v_iva_interes_vencido_bal       = 0;
						LET v_iva_interes_vencido_ord       = 0;
						LET v_iva_interes_vigente           = 0;
					END IF;	
				END IF;
                --CAMPO 37 max_atr
                IF nvl(v_atr,0) >= nvl(v_atr1,0) and nvl(v_atr,0) >= nvl(v_atr2,0) and nvl(v_atr,0) >= nvl(v_atr3,0) then 
                    let v_max_atr=nvl(v_atr,0);
                elif nvl(v_atr1,0)>=nvl(v_atr,0) and nvl(v_atr1,0)>=nvl(v_atr2,0) and nvl(v_atr1,0)>=nvl(v_atr3,0) then
                    let v_max_atr= nvl(v_atr1,0);
                elif nvl(v_atr2,0)>=nvl(v_atr,0) and nvl(v_atr2,0)>=nvl(v_atr1,0) and nvl(v_atr2,0)>=nvl(v_atr3,0) then
                    let v_max_atr= nvl(v_atr2,0);  
                elif nvl(v_atr3,0)>=nvl(v_atr,0) and nvl(v_atr3,0)>=nvl(v_atr1,0) and nvl(v_atr3,0)>=nvl(v_atr2,0) then
                    let v_max_atr= nvl(v_atr3,0);
                elif v_atr = nvl(v_atr1,0) and nvl(v_atr,0) = nvl(v_atr2,0) and nvl(v_atr,0) = nvl(v_atr3,0) then 
                    let v_max_atr= nvl(v_atr,0);
                end if; 
         
                --CAMPO 41 MONTO EXIGIBLE
                SELECT iva INTO pIva
                FROM bdinteg:si_sucursales 
                WHERE sucursal=v_sucursal;                
                     
				-- LET v_fecha=(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))-1 units day);			    
				LET v_fecha =  v_fecha_corte -1 units day;
				
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;
				
                SELECT                
                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                INTO v_monto_exigible
                FROM sd_maesdoshistcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
              
                --CAMPO 42 MONTO EXIGIBLE1
             --   IF v_facturacion='M' THEN
					/*IF  v_dia_corte = 31 THEN
						LET v_fecha= v_fecha_corte- 1 units month;					
						IF month(v_fecha) in (1,3,5,7,8,10,12 ) THEN							
							LET v_fecha =  mdy(month(v_fecha),'30',year(v_fecha));
						ELIF month(v_fecha) in (4,6,9,11 ) THEN
							LET v_fecha =  mdy(month(v_fecha),'29',year(v_fecha));
						ELIF month(v_fecha) = 2 THEN
							IF flag_aniobis= 1 THEN
								LET v_fecha =  mdy(month(v_fecha),'28',year(v_fecha));							
							ELSE
								LET v_fecha =  mdy(month(v_fecha),'27',year(v_fecha));
							END IF;
						END IF;
					ELSE
						LET v_fecha=(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))-1 units day);
						LET v_fecha= mdy(month(v_fecha),day(v_fecha),year(v_fecha))-1 units month; 
					END IF;	*/					
					--LET v_fecha =  (v_fecha_corte-1 units month)-1 units day;
					
					--Valida inhabiles	
					--IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
						--LET v_fecha =  v_fecha -1 units day;	 
					--END IF;
                --ELSE
                  --  EXECUTE PROCEDURE sp_calcula_fechas_porperiodo(v_empresa,v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
                    --INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6, dFechaPer7, dFechaPer8, dFechaPer9,dFechaPer10,dFechaPer11,dFechaPer12,dFechaPer13;
				
                    --LET v_fecha= mdy(month(dFechaPer1),day(dFechaPer1),year(dFechaPer1))-1 units day;
                --END IF;
				
				LET v_fecha =  dFechaPer1  -1 units day;
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;

                SELECT                
                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                INTO v_monto_exigible1
                FROM sd_maesdoshistcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 

                --CAMPO 43 MONTO EXIGIBLE2
               -- IF v_facturacion='M' THEN
				/*	IF  v_dia_corte = 31 THEN
						LET v_fecha= v_fecha_corte- 2 units month;					
						IF month(v_fecha) in (1,3,5,7,8,10,12 ) THEN							
							LET v_fecha =  mdy(month(v_fecha),'30',year(v_fecha));
						ELIF month(v_fecha) in (4,6,9,11 ) THEN
							LET v_fecha =  mdy(month(v_fecha),'29',year(v_fecha));
						ELIF month(v_fecha) = 2 THEN
							IF flag_aniobis= 1 THEN
								LET v_fecha =  mdy(month(v_fecha),'28',year(v_fecha));							
							ELSE
								LET v_fecha =  mdy(month(v_fecha),'27',year(v_fecha));
							END IF;
						END IF;
					ELSE
				        LET v_fecha=(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))-1 units day);
						LET v_fecha= mdy(month(v_fecha),day(v_fecha),year(v_fecha))-2 units month; 
					END IF;	*/					
					--LET v_fecha =  (v_fecha_corte-2 units month)-1 units day;					
					
					--Valida inhabiles	
					--IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					--	LET v_fecha =  v_fecha -1 units day;	 
					--END IF;
                --ELSE
                   -- LET v_fecha= mdy(month(dFechaPer2),day(dFechaPer2),year(dFechaPer2))-1 units day;
                --END IF;
				LET v_fecha =  dFechaPer2  -1 units day;
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;

                SELECT                
                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                INTO v_monto_exigible2
                FROM sd_maesdoshistcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));  

                --CAMPO 44 MONTO EXIGIBLE3
                --IF v_facturacion='M' THEN
					/*IF  v_dia_corte = 31 THEN
						LET v_fecha= v_fecha_corte- 3 units month;					
						IF month(v_fecha) in (1,3,5,7,8,10,12 ) THEN							
							LET v_fecha =  mdy(month(v_fecha),'30',year(v_fecha));
						ELIF month(v_fecha) in (4,6,9,11 ) THEN
							LET v_fecha =  mdy(month(v_fecha),'29',year(v_fecha));
						ELIF month(v_fecha) = 2 THEN
							IF flag_aniobis= 1 THEN
								LET v_fecha =  mdy(month(v_fecha),'28',year(v_fecha));							
							ELSE
								LET v_fecha =  mdy(month(v_fecha),'27',year(v_fecha));
							END IF;
						END IF;
					ELSE
						LET v_fecha=(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))-1 units day);
						LET v_fecha= mdy(month(v_fecha),day(v_fecha),year(v_fecha))-3 units month; 
					END IF;	*/
					--LET v_fecha =  (v_fecha_corte-3 units month)-1 units day;
					
					--Valida inhabiles	
					--IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
						--LET v_fecha =  v_fecha -1 units day;	 
					--END IF;
                ---ELSE
                  --  LET v_fecha= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))-1 units day;
                --END IF;
				LET v_fecha= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))-1 units day;
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;
				
                SELECT                
                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                INTO v_monto_exigible3
                FROM sd_maesdoshistcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 

                --CAMPO 45 MONTO EXIGIBLE4
                IF v_facturacion='Q' THEN
                    LET v_fecha= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))-1 units day;
					
					--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;
                
                    SELECT                
                    nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                    INTO v_monto_exigible4
                    FROM sd_maesdoshistcrd
                    WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
                
                --CAMPO 46 MONTO EXIGIBLE5  
                    LET v_fecha= mdy(month(dFechaPer5),day(dFechaPer5),year(dFechaPer5))-1 units day;
					
					--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;

                    SELECT                
                    nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                    INTO v_monto_exigible5
                    FROM sd_maesdoshistcrd
                    WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
                
                 --CAMPO 47 MONTO EXIGIBLE6 
                    LET v_fecha= mdy(month(dFechaPer6),day(dFechaPer6),year(dFechaPer6))-1 units day;
					
				--Valida inhabiles	
				IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
					LET v_fecha =  v_fecha -1 units day;	 
				END IF;
				
                    SELECT                
                    nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                    INTO v_monto_exigible6
                    FROM sd_maesdoshistcrd
                    WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
                
				
					IF v_num_producto='9300' THEN
					
					 --CAMPO  MONTO EXIGIBLE7 
						LET v_fecha= mdy(month(dFechaPer7),day(dFechaPer7),year(dFechaPer7))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible7
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
						
						
						--CAMPO  MONTO EXIGIBLE8 
						LET v_fecha= mdy(month(dFechaPer8),day(dFechaPer8),year(dFechaPer8))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible8
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
						
						--CAMPO  MONTO EXIGIBLE9 
						LET v_fecha= mdy(month(dFechaPer9),day(dFechaPer9),year(dFechaPer9))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible9
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
						
						--CAMPO  MONTO EXIGIBLE10 
						LET v_fecha= mdy(month(dFechaPer10),day(dFechaPer10),year(dFechaPer10))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible10
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
						
						--CAMPO  MONTO EXIGIBLE11 
						LET v_fecha= mdy(month(dFechaPer11),day(dFechaPer11),year(dFechaPer11))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible11
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
						
						--CAMPO  MONTO EXIGIBLE12 
						LET v_fecha= mdy(month(dFechaPer12),day(dFechaPer12),year(dFechaPer12))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible12
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
						
						--CAMPO  MONTO EXIGIBLE13 
						LET v_fecha= mdy(month(dFechaPer13),day(dFechaPer13),year(dFechaPer13))-1 units day;
						
					--Valida inhabiles	
						IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
							LET v_fecha =  v_fecha -1 units day;	 
						END IF;
					
						SELECT                
						nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
						INTO v_monto_exigible13
						FROM sd_maesdoshistcrd
						WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));
					END IF;
				END IF;	
				

                --PAGOS CAMPOS 56,57,58,59,60,61,62,63,64,65,66,67,68,69
                --Pagos del mes               
                IF v_facturacion='M' THEN
                   -- LET v_fecha=(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))+1 units day); 
				   --IPCB Se cambia para corregir el considerar la suma del 31 de las cuentas que cortan en 30 
				    --LET v_fecha = (v_fecha_corte - 1 units month)+1 units day;
					LET v_fecha = dFechaPer1  + 1 units day;
					--IPCB Se incluye el pago completo, para incluir los moratorios
                    select  
                    sum(case when codigo_ref in (14,16,958) then monto else 0 end) capital_vigente,
                    sum(case when codigo_ref in (15,959,960,961) then monto else 0 end) capital_vencido,
                    sum(case when codigo_ref in (5,6,962,966,970) then monto else 0 end) int_vigente,
                    sum(case when codigo_ref in (8,10,963,967,971) then monto else 0 end) iva_vigente,
					sum(case when codigo_ref in (17,968,972,2,6709) then monto else 0 end) interes_venc_orden,
					sum(case when codigo_ref in (18,969,973,6616,6617,6652,3) then monto else 0 end) iva_interes_venc_orden,
					sum(case when codigo_ref in (7,964) then monto else 0 end) int_venc_bal,
					sum(case when codigo_ref in (12,965) then monto else 0 end) iva_venc_bal,
					sum(case when codigo_ref = 1 then monto else 0 end) pago_realizado
                    INTO v_capital_vigente,v_capital_vencido,v_int_vigente,v_iva_vigente,v_interes_orden,v_iva_interes_orden,v_int_venc_bal, v_iva_venc_bal,v_pago_realizado
                    from sd_movhiscrd
                    where empresa = '001'
				  --and fecha_mov <= mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte)) --IPCB Correccion 
                    and fecha_mov <= v_fecha_corte
                  --and fecha_mov >= monthadd(mdy(month(v_fecha),day(v_fecha),year(v_fecha)), -1) --IPCB Correccion 
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    --and codigo_ref  in (16,14,15,5,6,8,10,17,18,7,12,1)
					and codigo_ref  in (16,14,15,5,6,8,10,17,18,7,12,1, 958,959,960,961,962,963,964,965,966,967,968,969,970,971,972,973,2,6616,6617,6652,6709,3)
                    and reversado = 'N';  
                ELSE
					--IPCB Se incluye el pago completo, para incluir los moratorios
                    select 
                    sum(case when codigo_ref in (14,16,958) then monto else 0 end) capital_vigente,
                    sum(case when codigo_ref in (15,959,960,961) then monto else 0 end) capital_vencido,
                    sum(case when codigo_ref in (5,6,962,966,970) then monto else 0 end) int_vigente,
                    sum(case when codigo_ref in (8,10,963,967,971) then monto else 0 end) iva_vigente,
					sum(case when codigo_ref in (17,968,972,2,6709) then monto else 0 end) interes_venc_orden,
					sum(case when codigo_ref in (18,969,973,6616,6617,6652,3) then monto else 0 end) iva_interes_venc_orden,
					sum(case when codigo_ref in (7,964) then monto else 0 end) int_venc_bal,
					sum(case when codigo_ref in (12,965) then monto else 0 end) iva_venc_bal,
					sum(case when codigo_ref = 1 then monto else 0 end) pago_realizado
                    INTO v_capital_vigente,v_capital_vencido,v_int_vigente,v_iva_vigente,v_interes_orden,v_iva_interes_orden,v_int_venc_bal, v_iva_venc_bal,v_pago_realizado
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))
                    and fecha_mov >= mdy(month(dFechaPer1),day(dFechaPer1),year(dFechaPer1))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    --and codigo_ref  in (16,14,15,5,6,8,10,17,18,7,12,1)
					and codigo_ref  in (16,14,15,5,6,8,10,17,18,7,12,1, 958,959,960,961,962,963,964,965,966,967,968,969,970,971,972,973,2,6616,6617,6652,6709,3)
                    and reversado = 'N';   
                END IF;
                --CAMPO 56 PAGO_CAPITAL
                LET v_pago_capital= nvl(v_capital_vigente+v_capital_vencido,0);
                --CAMPO 57 PAGO_INT_VENC_BAL
                LET v_pago_int_venc_bal= nvl(v_int_venc_bal,0);
                --CAMPO 58 PAGO_INT_VENC_ORD
                LET v_pago_int_venc_ord= nvl(v_interes_orden,0);
                --CAMPO 59 PAGO_INTERES_VIGENTE
                LET v_pago_interes_vigente=nvl(v_int_vigente,0);
                --CAMPO 60 PAGO_IVA_INT_VENC_BAL
                LET v_pago_iva_int_venc_bal=nvl(v_iva_venc_bal,0);
                --CAMPO 61 PAGO_IVA_INT_VENC_ORD
                LET v_pago_iva_int_venc_ord=nvl(v_iva_interes_orden,0);
                --CAMPO 62 PAGO_IVA_INTERES_VIGENTE
                LET v_pago_iva_interes_vigente=nvl(v_iva_Vigente,0);
                --CAMPO 63 PAGO_REALIZADO
				--LET v_pago_realizado= nvl(v_capital_vigente+v_capital_vencido+v_int_vigente+v_iva_vigente+v_interes_orden+v_iva_interes_orden,0);
				--IPCB se cambia por la totalidad del pago
				LET v_pago_realizado= v_pago_realizado;         

                -- CAMPO 64 PAGO_REALIZADO1
                IF v_facturacion='M' THEN
                    --LET v_fecha= mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))+1 units day; 
					--IPCB Se cambia para corregir el considerar la suma del 31 de las cuentas que cortan en 30 
				    --LET v_fecha = (v_fecha_corte - 2 units month)+1 units day;             
					LET v_fecha =  dFechaPer2  + 1 units day;
--IPCB se cambia script para leer la totalidad del pago.					
                   /* select
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente1,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido1,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente1,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente1,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden1,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden1
                    INTO v_capital_vigente1,v_capital_vencido1,v_int_vigente1,v_iva_vigente1,v_interes_orden1,v_iva_interes_orden1
                    from sd_movhiscrd
                    where empresa = '001'
                  --and fecha_mov <= monthadd(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte)),-1) --IPCB Correccion 
					and fecha_mov <= v_fecha_corte - 1 units month 
                  --and fecha_mov >= monthadd(mdy(month(v_fecha),day(v_fecha),year(v_fecha)),-2) --IPCB Correccion 
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';     */    
					select sum (monto) 
                    INTO v_pago_realizado1
                    from sd_movhiscrd
                    where empresa = '001'
					and fecha_mov <= dFechaPer1 
                  	and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref = 1
                    and reversado = 'N';   	
                ELSE
                   /* select  
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente1,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido1,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente1,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente1,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden1,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden1
                    INTO v_capital_vigente1,v_capital_vencido1,v_int_vigente1,v_iva_vigente1,v_interes_orden1,v_iva_interes_orden1
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer1),day(dFechaPer1),year(dFechaPer1))
                    and fecha_mov >= mdy(month(dFechaPer2),day(dFechaPer2),year(dFechaPer2))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   */
					select sum (monto) 
                    INTO v_pago_realizado1
					from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer1),day(dFechaPer1),year(dFechaPer1))
                    and fecha_mov >= mdy(month(dFechaPer2),day(dFechaPer2),year(dFechaPer2))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
					and codigo_ref = 1
                    and reversado = 'N'; 					
                END IF;
              --  LET v_pago_realizado1= nvl(v_capital_vigente1+v_capital_vencido1+v_int_vigente1+v_iva_vigente1+v_interes_orden1+v_iva_interes_orden1,0);

                -- CAMPO 65 PAGO_REALIZADO2
                IF v_facturacion='M' THEN
                    --LET v_fecha= mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))+1 units day; 
					--IPCB Se cambia para corregir el considerar la suma del 31 de las cuentas que cortan en 30 
                    --LET v_fecha = (v_fecha_corte - 3 units month)+1 units day;
					LET v_fecha= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))+ 1 units day;
					
                /*    select 
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente2,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido2,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente2,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente2,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden2,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden2
                    INTO v_capital_vigente2,v_capital_vencido2,v_int_vigente2,v_iva_vigente2,v_interes_orden2,v_iva_interes_orden2
                    from sd_movhiscrd
                    where empresa = '001'
                    --and fecha_mov <= monthadd(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte)),-2) 
					and fecha_mov <= (v_fecha_corte - 2 units month)
                    --and fecha_mov >= monthadd(mdy(month(v_fecha),day(v_fecha),year(v_fecha)),-3) 
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';                 */
					select sum (monto) 
					INTO v_pago_realizado2
					from sd_movhiscrd
                    where empresa = '001'
					and fecha_mov <= dFechaPer2
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref = 1
                    and reversado = 'N';
                ELSE
				/*
                    select 
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente2,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido2,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente2,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente2,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden2,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden2
                    INTO v_capital_vigente2,v_capital_vencido2,v_int_vigente2,v_iva_vigente2,v_interes_orden2,v_iva_interes_orden2
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer2),day(dFechaPer2),year(dFechaPer2))
                    and fecha_mov >= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   */
					select sum (monto) 
					INTO v_pago_realizado2
					from sd_movhiscrd
					 where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer2),day(dFechaPer2),year(dFechaPer2))
                    and fecha_mov >= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref = 1
                    and reversado = 'N';					
                END IF;
               -- LET v_pago_realizado2= nvl(v_capital_vigente2+v_capital_vencido2+v_int_vigente2+v_iva_vigente2+v_interes_orden2+v_iva_interes_orden2,0);

                -- CAMPO 66 PAGO_REALIZADO3
                IF v_facturacion='M' THEN
                    --LET v_fecha= mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte))+1 units day;
                    --IPCB Se cambia para corregir el considerar la suma del 31 de las cuentas que cortan en 30 
					--LET v_fecha = (v_fecha_corte - 4 units month)+1 units day;
					LET v_fecha= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))+1 units day;
					/*
                    select 
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente3,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido3,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente3,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente3,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden3,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden3
                    INTO v_capital_vigente3,v_capital_vencido3,v_int_vigente3,v_iva_vigente3,v_interes_orden3,v_iva_interes_orden3
                    from sd_movhiscrd
                    where empresa = '001'
                  --and fecha_mov <= monthadd(mdy(month(v_fecha_corte),day(v_fecha_corte),year(v_fecha_corte)),-3)  --IPCB Correccion 
				    and fecha_mov <= (v_fecha_corte - 3 units month)
                  --and fecha_mov >= monthadd(mdy(month(v_fecha),day(v_fecha),year(v_fecha)),-4) --IPCB Correccion 
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   */
					select sum (monto) 
					INTO v_pago_realizado3
					from sd_movhiscrd
                    where empresa = '001'
				    and fecha_mov <=dFechaPer3
					and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref = 1
                    and reversado = 'N';
                ELSE
				/*
                    select 
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente3,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido3,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente3,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente3,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden3,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden3
                    INTO v_capital_vigente3,v_capital_vencido3,v_int_vigente3,v_iva_vigente3,v_interes_orden3,v_iva_interes_orden3
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))
                    and fecha_mov >= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N'; */
					select sum (monto) 
					INTO v_pago_realizado3
					from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer3),day(dFechaPer3),year(dFechaPer3))
                    and fecha_mov >= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref = 1
                    and reversado = 'N'; 					
                END IF;
                --LET v_pago_realizado3= nvl(v_capital_vigente3+v_capital_vencido3+v_int_vigente3+v_iva_vigente3+v_interes_orden3+v_iva_interes_orden3,0);
                
                IF v_facturacion='Q' THEN
                    -- CAMPO 67 PAGO_REALIZADO4
                  /*  select  
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente4,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido4,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente4,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente4,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden4,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden4
                    INTO v_capital_vigente4,v_capital_vencido4,v_int_vigente4,v_iva_vigente4,v_interes_orden4,v_iva_interes_orden4
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))
                    and fecha_mov >= mdy(month(dFechaPer5),day(dFechaPer5),year(dFechaPer5))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   
					
					LET v_pago_realizado4= nvl(v_capital_vigente4+v_capital_vencido4+v_int_vigente4+v_iva_vigente4+v_interes_orden4+v_iva_interes_orden4,0);*/
					select sum (monto) 
					INTO v_pago_realizado4
					from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer4),day(dFechaPer4),year(dFechaPer4))
                    and fecha_mov >= mdy(month(dFechaPer5),day(dFechaPer5),year(dFechaPer5))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref =1
                    and reversado = 'N';                    

                -- CAMPO 68 PAGO_REALIZADO5
                  /*  select 
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente5,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido5,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente5,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente5,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden5,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden5
                    INTO v_capital_vigente5,v_capital_vencido5,v_int_vigente5,v_iva_vigente5,v_interes_orden5,v_iva_interes_orden5
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer5),day(dFechaPer5),year(dFechaPer5))
                    and fecha_mov >= mdy(month(dFechaPer6),day(dFechaPer6),year(dFechaPer6))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   
                
                    LET v_pago_realizado5= nvl(v_capital_vigente5+v_capital_vencido5+v_int_vigente5+v_iva_vigente5+v_interes_orden5+v_iva_interes_orden5,0);*/
					select sum (monto) 
					INTO v_pago_realizado5
					from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer5),day(dFechaPer5),year(dFechaPer5))
                    and fecha_mov >= mdy(month(dFechaPer6),day(dFechaPer6),year(dFechaPer6))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref =1
                    and reversado = 'N';  

                -- CAMPO 69 PAGO_REALIZADO6
                    /*select
                    sum(case when codigo_ref in (14,16) then monto else 0 end) capital_vigente6,
                    sum(case when codigo_ref = 15 then monto else 0 end) capital_vencido6,
                    sum(case when codigo_ref in (5,6) then monto else 0 end) int_vigente6,
                    sum(case when codigo_ref in (8,12,10) then monto else 0 end) iva_vigente6,
                    sum(case when codigo_ref = 17 then monto else 0 end) interes_orden6,
                    sum(case when codigo_ref = 18 then monto else 0 end) iva_interes_orden6
                    INTO v_capital_vigente6,v_capital_vencido6,v_int_vigente6,v_iva_vigente6,v_interes_orden6,v_iva_interes_orden6
                    from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer6),day(dFechaPer6),year(dFechaPer6))
                    and fecha_mov >= mdy(month(dFechaPer7),day(dFechaPer7),year(dFechaPer7))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref in (16,14,15,5,6,8,12,10,17,18)
                    and reversado = 'N';   
                
                    LET v_pago_realizado6= nvl(v_capital_vigente6+v_capital_vencido6+v_int_vigente6+v_iva_vigente6+v_interes_orden6+v_iva_interes_orden6,0);*/
					select sum (monto) 
					INTO v_pago_realizado6
					 from sd_movhiscrd
                    where empresa = '001'
                    and fecha_mov <= mdy(month(dFechaPer6),day(dFechaPer6),year(dFechaPer6))
                    and fecha_mov >= mdy(month(dFechaPer7),day(dFechaPer7),year(dFechaPer7))+1 units day
                    and num_credito =v_num_credito
                    and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
                    and codigo_ref =1
                    and reversado = 'N'; 
					
					IF v_num_producto='9300' THEN
					
						-- CAMPO PAGO_REALIZADO7
                    
						select sum (monto) 
						INTO v_pago_realizado7
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer7),day(dFechaPer7),year(dFechaPer7))
						and fecha_mov >= mdy(month(dFechaPer8),day(dFechaPer8),year(dFechaPer8))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO8
                    
						select sum (monto) 
						INTO v_pago_realizado8
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer8),day(dFechaPer8),year(dFechaPer8))
						and fecha_mov >= mdy(month(dFechaPer9),day(dFechaPer9),year(dFechaPer9))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO9
                    
						select sum (monto) 
						INTO v_pago_realizado9
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer9),day(dFechaPer9),year(dFechaPer9))
						and fecha_mov >= mdy(month(dFechaPer10),day(dFechaPer10),year(dFechaPer10))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO10
                    
						select sum (monto) 
						INTO v_pago_realizado10
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer10),day(dFechaPer10),year(dFechaPer10))
						and fecha_mov >= mdy(month(dFechaPer11),day(dFechaPer11),year(dFechaPer11))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO11
                    
						select sum (monto) 
						INTO v_pago_realizado11
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer11),day(dFechaPer11),year(dFechaPer11))
						and fecha_mov >= mdy(month(dFechaPer12),day(dFechaPer12),year(dFechaPer12))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO12
                    
						select sum (monto) 
						INTO v_pago_realizado12
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer12),day(dFechaPer12),year(dFechaPer12))
						and fecha_mov >= mdy(month(dFechaPer13),day(dFechaPer13),year(dFechaPer13))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
						
						-- CAMPO PAGO_REALIZADO13
                    
						select sum (monto) 
						INTO v_pago_realizado13
						 from sd_movhiscrd
						where empresa = '001'
						and fecha_mov <= mdy(month(dFechaPer13),day(dFechaPer13),year(dFechaPer13))
						--and fecha_mov >= mdy(month(dFechaPer13),day(dFechaPer13),year(dFechaPer13))+1 units day
						and num_credito =v_num_credito
						and codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
						and codigo_ref =1
						and reversado = 'N';
					
					END IF; 
					
                ELSE
                    LET v_pago_realizado4              	= 0;
                    LET v_pago_realizado5              	= 0;
                    LET v_pago_realizado6               = 0;
                END IF;

                --CAMPO 70 PERIODOS_INCUMPLIMIENTO
				/*--Se tarda mucho
                SELECT COUNT(fecha) INTO v_periodos_incumplimiento
                FROM sd_maecredcontcrd 
                WHERE fecha <= pPeriodo AND  empresa = '001' AND num_credito=v_num_credito and status_cred in('BA','BT');  --IPCB Se limita por la fecha del periodo
                */
				
				SELECT fecha, status_cred --COUNT(fecha) --INTO v_periodos_incumplimiento
                FROM sd_maecredcontcrd 
                WHERE empresa = '001' 
                AND num_credito = v_num_credito
                --and status_cred in('BA','BT')
                and (status_cred in('BA','BT') or ((status_cred='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))))
                INTO TEMP tmp_incumplimientos WITH NO LOG;

                CREATE INDEX idx_INCUMp ON tmp_incumplimientos(fecha) ONLINE;

                 SELECT COUNT(*) INTO v_periodos_incumplimiento
                 FROM tmp_incumplimientos
                   WHERE fecha <= pPeriodo;

                DROP TABLE tmp_incumplimientos;
				
                --CAMPO 74 PORCENTAJE_PAGO
				IF v_fecha_apertura >= piniPeriodo and v_fecha_apertura <= pPeriodo  THEN
							LET v_porcentaje_pago ='1.00';
				ELSE
					IF v_facturacion='M' THEN
						IF nvl(v_monto_exigible,0)>0 THEN
							LET v_prom1= nvl(v_pago_realizado / v_monto_exigible,0);
						ELSE
							LET v_prom1 = "";
						END IF;
						IF nvl(v_monto_exigible1,0)>0 THEN
							LET v_prom2= nvl(v_pago_realizado1 / v_monto_exigible1,0);
						ELSE
							LET v_prom2 = "";
						END IF;
						IF nvl(v_monto_exigible2,0)>0 THEN
							LET v_prom3= nvl(v_pago_realizado2 / v_monto_exigible2,0);
						ELSE
							LET v_prom3 = "";
						END IF;
						IF nvl(v_monto_exigible3,0)>0 THEN
							LET v_prom4= nvl(v_pago_realizado3 / v_monto_exigible3,0);
						ELSE
							LET v_prom4 = "";
						END IF;
							/*
						IF  v_antiguedad >= 4 THEN
								LET v_porcentaje_pago= nvl((v_prom1+v_prom2+v_prom3+v_prom4) / 4,0);
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
							END IF;*/
							
							LET bandera_exigible = 1;	
							LET v_prom_tot = 0;
							LET var_div   = 0;
							LET v_porcentaje_pago = 0;
							
							WHILE (bandera_exigible <= 4) LOOP
							
								IF bandera_exigible = 1 THEN
									IF nvl(v_monto_exigible,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom1;
										LET var_div = var_div+1;
									END IF;
								ELIF bandera_exigible = 2 THEN
									IF nvl(v_monto_exigible1,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom2;
										LET var_div = var_div+1;
									END IF;												
								ELIF bandera_exigible = 3 THEN
									IF nvl(v_monto_exigible2,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom3;
										LET var_div = var_div+1;
									END IF;	
								ELIF bandera_exigible = 4 THEN
									IF nvl(v_monto_exigible3,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom4;
										LET var_div = var_div+1;
									END IF;							
								END IF;
								LET bandera_exigible = (bandera_exigible+1);							
							END LOOP;

							IF 	var_div > 0 THEN
								LET v_porcentaje_pago = round(v_prom_tot/var_div,2);
						END IF;
							
					ELSE
						IF nvl(v_monto_exigible,0)>0 THEN
							LET v_prom1= nvl(v_pago_realizado / v_monto_exigible,0);
						END IF;
						IF nvl(v_monto_exigible1,0)>0 THEN
							LET v_prom2= nvl(v_pago_realizado1 / v_monto_exigible1,0);
						END IF;
						IF nvl(v_monto_exigible2,0)>0 THEN
							LET v_prom3= nvl(v_pago_realizado2 / v_monto_exigible2,0);
						END IF;
						IF nvl(v_monto_exigible3,0)>0 THEN
							LET v_prom4= nvl(v_pago_realizado3 / v_monto_exigible3,0);
						END IF;
						IF nvl(v_monto_exigible4,0)>0 THEN
							LET v_prom5= nvl(v_pago_realizado4/v_monto_exigible4,0);
						END IF;
						IF nvl(v_monto_exigible5,0)>0 THEN
							LET v_prom6= nvl(v_pago_realizado5/v_monto_exigible5,0);
						END IF;
						IF nvl(v_monto_exigible6,0)>0 THEN
							LET v_prom7= nvl(v_pago_realizado6/v_monto_exigible6,0);
						END IF;
							
												
							LET bandera_exigible = 1;	
							LET v_prom_tot = 0;
							LET var_div   = 0;
							LET v_porcentaje_pago = 0;
							
							WHILE (bandera_exigible <= 7) LOOP
							
								IF bandera_exigible = 1 THEN
									IF nvl(v_monto_exigible,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom1;
										LET var_div = var_div+1;
									END IF;
								ELIF bandera_exigible = 2 THEN
									IF nvl(v_monto_exigible1,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom2;
										LET var_div = var_div+1;
									END IF;												
								ELIF bandera_exigible = 3 THEN
									IF nvl(v_monto_exigible2,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom3;
										LET var_div = var_div+1;
									END IF;	
								ELIF bandera_exigible = 4 THEN
									IF nvl(v_monto_exigible3,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom4;
										LET var_div = var_div+1;
									END IF;	
								ELIF bandera_exigible = 5 THEN
									IF nvl(v_monto_exigible4,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom5;
										LET var_div = var_div+1;
									END IF;	
								ELIF bandera_exigible = 6 THEN
									IF nvl(v_monto_exigible5,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom6;
										LET var_div = var_div+1;
									END IF;	
								ELIF bandera_exigible = 7 THEN
									IF nvl(v_monto_exigible6,0)>0  THEN
										LET v_prom_tot = v_prom_tot +v_prom7;
										LET var_div = var_div+1;
									END IF;
								END IF;
								LET bandera_exigible = (bandera_exigible+1);							
							END LOOP;

							IF 	var_div > 0 THEN
								LET v_porcentaje_pago = round(v_prom_tot/var_div,2);
							END IF;
							--terminacion validacion cuentas nueva

							/*IF v_prom_tot=0 THEN
								LET v_porcentaje_pago ='1.00';
							END IF;*/
							
						/*
						
					--Si todos los 	montos exigibles son nulos
						IF    v_monto_exigible  IS NULL 
						  AND v_monto_exigible1 IS NULL AND v_monto_exigible2 IS NULL AND v_monto_exigible3 IS NULL 
						  AND v_monto_exigible4 IS NULL AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN
							
							LET v_porcentaje_pago = 0;
					--Si el monto exigible del periodo es el unico con valor	
						ELIF v_monto_exigible  IS NOT NULL 
						 AND v_monto_exigible1 IS NULL AND v_monto_exigible2 IS NULL AND v_monto_exigible3 IS NULL 
						 AND v_monto_exigible4 IS NULL AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN
								
							LET v_porcentaje_pago=nvl((v_prom1)/1,0);
					--Si el monto exigible del periodo + v_monto_exigible1 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL
						 AND v_monto_exigible2 IS NULL 	   AND v_monto_exigible3 IS NULL 
						 AND v_monto_exigible4 IS NULL 	   AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN
						 
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2) / 2,0);
					--Si el monto exigible del periodo + v_monto_exigible1 +  v_monto_exigible2 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL
						 AND v_monto_exigible3 IS NULL 
						 AND v_monto_exigible4 IS NULL AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN	
						 
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3) / 3,0);
					--Si el monto exigible del periodo + v_monto_exigible1 +  v_monto_exigible2 + v_monto_exigible3 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL
						 AND v_monto_exigible3 IS NOT NULL 
						 AND v_monto_exigible4 IS NULL AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN			
							
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4) / 4,0);	
					--Si el monto exigible del periodo + v_monto_exigible1 +  v_monto_exigible2 + v_monto_exigible3 
					  -- + v_monto_exigible4 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL
						 AND v_monto_exigible3 IS NOT NULL AND v_monto_exigible4 IS NOT NULL
						 AND v_monto_exigible5 IS NULL AND v_monto_exigible6 IS NULL THEN		
						 
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4+v_prom5) / 5,0);	
					--Si el monto exigible del periodo + v_monto_exigible1 +  v_monto_exigible2 + v_monto_exigible3 
					  -- + v_monto_exigible4 + v_monto_exigible5 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL
						 AND v_monto_exigible3 IS NOT NULL AND v_monto_exigible4 IS NOT NULL AND v_monto_exigible5 IS NOT NULL
						 AND v_monto_exigible6 IS NULL THEN
						 
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4+v_prom5+v_prom6) / 6,0);
					--Si el monto exigible del periodo + v_monto_exigible1 +  v_monto_exigible2 + v_monto_exigible3 
					  -- + v_monto_exigible4 + v_monto_exigible5  + v_monto_exigible6 son los unicos con valor	
						ELIF v_monto_exigible  IS NOT NULL AND v_monto_exigible1 IS NOT NULL AND v_monto_exigible2 IS NOT NULL
						 AND v_monto_exigible3 IS NOT NULL AND v_monto_exigible4 IS NOT NULL AND v_monto_exigible5 IS NOT NULL
						 AND v_monto_exigible6 IS NOT NULL THEN	
							
							LET v_porcentaje_pago=nvl((v_prom1+v_prom2+v_prom3+v_prom4+v_prom5+v_prom6+v_prom7) / 7,0);
							END IF;	*/
					END IF;	
				END IF;
				
                --CAMPO 77 SALDO CIERRE
                
                IF v_status_fin_mes='BT' or ((v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) THEN
				/*    
			   select nvl(sum(interes_debe - interes_pagado),0) Total_Vencido,
                      nvl(sum(case when campo_trabajo3  = 'V' then interes_debe - interes_pagado else 0 end),0) Vencido_Orden,
                      nvl(sum(case when campo_trabajo3 <> 'V' then interes_debe - interes_pagado else 0 end),0) Vencido_Balanza,
                      nvl(sum(case when campo_trabajo3 <> 'V' then iva_debe - iva_pagado else 0 end),0) Vencido_Balanza_Iva
                 into dTotalVencido,dVencidoOrden,dInteresVencido,dOtrasEstimaciones
                 from sd_amortiza_creditocrd 
                where empresa = v_empresa 
                  and num_credito = v_num_credito 
                  and capital_status = '2';
					*/			  
				           
                    --SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0) + v_interes_vencido_bal30  -----DIFERENCIAS REPORTADAS CJAC
                    SELECT NVL(sdo_cap_insoluto,0) + v_interes_vencido_bal30  -----DIFERENCIAS REPORTADAS CJAC
                    INTO v_saldo_cierre
                    FROM sd_maesdoscontcrd
                    WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
                 ELSE
                    --SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(provision_normal,0)
					--SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0) --+NVL(sdo_acum_mes_int,0)  -- Se cambia el provision_normal x sdo_acum_mes_int, ya que se tenia un descueadre en 18 cuentas contra la balanza
                    SELECT NVL(sdo_cap_insoluto,0) + NVL(sdo_intereses,0) -- Se cambia el provision_normal x sdo_acum_mes_int, ya que se tenia un descueadre en 18 cuentas contra la balanza
                    INTO v_saldo_cierre
                    FROM sd_maesdoscontcrd
                    WHERE num_credito=v_num_credito and fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
                END IF;
               
				SELECT monto
					INTO psaldoInteresApoyo
				FROM bdicred:sd_maeretenido 
				WHERE num_credito = v_num_credito
					AND transacc = '8374'
					AND estatus = 'R';
				LET psaldoInteresApoyo = NVL(psaldoInteresApoyo,0);
					
				IF NVL(psaldoInteresApoyo,0)>0 THEN
				 LET v_saldo_cierre= v_saldo_cierre + nvl(psaldoInteresApoyo,0);
				END IF;
	
	
				LET v_porcentaje_uso=round((v_saldo_cierre/v_linea_autorizada),6);
               
			   -- CAMPO 78 SALDO_CORTE
			 /* IF v_status_fin_mes='BT' THEN
                    SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ v_interes_vencido_bal  --dInteresVencido  IPCB se toma el interes_vencido_bal a su fecha de corte para no depender de la amortiza que no es estatica
                    INTO v_saldo_corte
                    FROM sd_maesdoshistcrd
                    WHERE num_credito=v_num_credito and fecha=mdy(month(v_fecha_corte), day(v_fecha_corte), year(v_fecha_corte));
                 ELSE
                    SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(provision_normal,0)
                    INTO v_saldo_corte
                    FROM sd_maesdoshistcrd
                    WHERE num_credito=v_num_credito and fecha=mdy(month(v_fecha_corte), day(v_fecha_corte), year(v_fecha_corte));
                END IF;*/
				IF (month(v_fecha_corte) = 1 AND day(v_fecha_corte) = 1) OR  (month(v_fecha_corte) = 12 AND day(v_fecha_corte) = 25) THEN --Dias Inhabiles
					LET v_fecha =  v_fecha_corte + 1 units day;	 
					
					IF v_status_fin_mes='BT' or ((v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)))THEN
						SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ v_interes_vencido_bal  --dInteresVencido  IPCB se toma el interes_vencido_bal a su fecha de corte para no depender de la amortiza que no es estatica
						INTO v_saldo_corte
						FROM sd_maesdoshistcrd
						WHERE num_credito=v_num_credito and fecha=v_fecha;
					ELSE
						SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(provision_normal,0)
						INTO v_saldo_corte
						FROM sd_maesdoshistcrd
						WHERE num_credito=v_num_credito and fecha=v_fecha;
					END IF;					
				ELSE
					IF v_status_fin_mes='BT' or ((v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)))THEN
						SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ v_interes_vencido_bal  --dInteresVencido  IPCB se toma el interes_vencido_bal a su fecha de corte para no depender de la amortiza que no es estatica
						INTO v_saldo_corte
						FROM sd_maesdoshistcrd
						WHERE num_credito=v_num_credito and fecha=mdy(month(v_fecha_corte), day(v_fecha_corte), year(v_fecha_corte));
					ELSE
						SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)+ NVL(sdo_no_exig,0)+NVL(provision_normal,0)
						INTO v_saldo_corte
						FROM sd_maesdoshistcrd
						WHERE num_credito=v_num_credito and fecha=mdy(month(v_fecha_corte), day(v_fecha_corte), year(v_fecha_corte));
					END IF;
				END IF;
                --CAMPO 79 SALDO EXIGIBLE
                LET v_fecha= mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo));                
                SELECT nvl(mto_venc_trasp,0)
                INTO v_saldo_exigible
                FROM sd_maesdoscontcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
                
                --CAMPO 80 SALDO NO EXIGIBLE
                LET v_fecha= mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo));                
                SELECT                
                nvl(cap_tras_no_venci,0) 
                INTO v_saldo_no_exigible
                FROM sd_maesdoscontcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
               

			----BLOQUE VARIABLES DE CIRCULO //Habilitado Unicamente para Directo Nomina
			--IF v_num_producto = '6400' THEN  --INICIO 6400
				SELECT a.num_credito credito_consulta, 
						var_mtosdo_ship,meses_ultimoatr1d_todos,monto_pagar_propios_ship,monto_pagar_otros_ship,sdo_actual_propio_ship,sdo_actual_otros_ship,
						antiguedad_bancos, antiguedad_inst
				  INTO v_cred_consulta, 
					    v_var_mtosdo,v_bkatr,v_mto_pagar_propios,v_mto_pagar_otros,v_sdo_actual_propio_ship,v_sdo_actual_otros_ship,
						v_ant_otro_inst, v_antiguedad_inst
				  FROM bdiburo:br_variables_cc_cnr a				    
				 WHERE  a.fecha_info  = dt_ultcons_varcc
				   AND a.num_credito = v_num_credito;
				 
                LET v_numero_cuenta_det = v_cred_consulta;
                LET v_veces_ult_atr1d_todos = v_bkatr;               
				 
				IF 	v_cred_consulta IS NULL THEN  --No se consulto a las SICs
					--CAMPO 82 Sin Consulta
                    LET v_numero_cuenta_det = 'ND';
					LET v_sin_consulta = '1';
                    LET v_antiguedad_inst = -99999;
                    LET v_veces_ult_atr1d_todos = -99999;
					LET v_var_mtosdo = -99999;
                
					--CAMPO 11 Consulta sin info					
					LET v_consulta_sin_info = '0';
					--CAMPO 1 Alto, 38 Medio, 8 Bajo  //No se consulto o no cuenta con v_ingresos_mens_netos
					LET v_alto = '1';
					LET v_medio = '0';
					LET v_bajo = '0';						
					--CAMPO 39 meses BKATR
					IF v_atr = 0 THEN
						LET v_bkatr = 10;
					ELIF v_atr > 0 THEN
						LET v_bkatr = 0;
					END IF;		
					--CAMPO 48 monto otros vs propios, 49 monto pagar otros, 50 monto pagar_propios, 51 mto vs sdo sic, 73 porcentaje endeudamiento, 86 Saldo actual propio_ship
					LET v_mto_otros_vs_propios = -99999; --- 0;
					LET v_mto_pagar_otros =-99999;
					LET v_mto_pagar_propios = -99999;
					LET v_mtovssdo_sic =0;
					LET v_sdo_sic = 0;				
					LET v_porcentaje_endeuda = 0; 	
					LET v_sdo_actual_propio_ship = -99999;
                    LET v_sdo_actual_otros_ship = -99999;
					LET v_ant_otro_inst = 0;	
				ELSE 						 		--Si Se consulto a las SICs
					--CAMPO 82 Sin Consulta
					LET v_sin_consulta = '0';		
					--CAMPO 11 Consulta sin info
					/*IF v_var_mtosdo IS NULL OR v_bkatr IS NULL OR v_mto_pagar_propios IS NULL OR v_mto_pagar_otros IS NULL OR 
					   v_sdo_actual_propio_ship IS NULL OR v_sdo_actual_otros_ship IS NULL OR v_ant_otro_inst IS NULL  THEN				*/
					IF v_var_mtosdo IS NULL THEN --Riesgos indica que si esta variable es nula se marcara sin informacion   
					--IF v_mto_pagar_propios IS NULL AND v_mto_pagar_otros IS NULL THEN -- NO SE CONSULTO A LAS SIC'S 6400
						LET v_consulta_sin_info = '1';
					ELSE
						LET v_consulta_sin_info = '0';	
					END IF;				
					
					IF v_num_producto = '6400' THEN   --Prestamo directo de nomina						
						IF v_mto_pagar_propios IS NULL AND v_mto_pagar_otros IS NULL THEN -- NO SE CONSULTO A LAS SIC'S 6400
							LET v_consulta_sin_info = '1';
						ELSE
							LET v_consulta_sin_info = '0';	
						END IF;
						--CAMPO 1 Alto, 38 Medio, 8 Bajo
						IF NVL(v_ingresos_mens_netos,0) <= 0 THEN 
							LET v_alto  = '1';
							LET v_medio = '0';								
							LET v_bajo  = '0';		
						ELSE		
							IF v_mto_pagar_otros IS NULL AND v_mto_pagar_propios IS NULL THEN  --Se consulto sin informacion						
								LET v_alto  = '0';
								LET v_medio = '1';								
								LET v_bajo  = '0';					
							ELSE  --v_mto_pagar_otros NOT IS NULL OR v_mto_pagar_propios NOT IS NULL THEN 	
								LET v_mto_pagar_propios = NVL(v_mto_pagar_propios,0);
								LET v_mto_pagar_otros   = NVL(v_mto_pagar_otros,0);
								
								IF   (v_mto_pagar_propios + v_mto_pagar_otros) /v_ingresos_mens_netos > .40  AND v_antiguedad_cliente <= 29 THEN
									LET v_alto 	= '1';
									LET v_medio = '0';
									LET v_bajo 	= '0';	
								ELIF (v_mto_pagar_propios + v_mto_pagar_otros) /v_ingresos_mens_netos <= .40 AND v_antiguedad_cliente >  29 THEN
									LET v_alto 	= '0';						
									LET v_medio = '0';		
									LET v_bajo 	= '1';							
								ELIF ((v_mto_pagar_propios + v_mto_pagar_otros) /v_ingresos_mens_netos <= .40 AND v_antiguedad_cliente <= 29) 
								 OR  ((v_mto_pagar_propios + v_mto_pagar_otros) /v_ingresos_mens_netos > .40  AND v_antiguedad_cliente >  29) THEN
									LET v_alto 	= '0';						
									LET v_medio = '1';		
									LET v_bajo 	= '0';														
								END IF;	
							END IF;
						END IF;		
					ELSE --Prestamos personales y flexible
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
					END IF;					
					--CAMPO 39 meses BKATR
					IF v_bkatr IS NULL THEN
						LET v_bkatr = 13;
					ELSE
						LET v_bkatr = v_bkatr;
					END IF;					
					--CAMPO 49 monto pagar otros, 50 monto pagar_propios, 48 monto otros vs propios,  51 mto vs sdo sic, 73 porcentaje endeudamiento
					LET v_mto_pagar_otros =NVL(v_mto_pagar_otros,'');					LET v_mto_pagar_propios =NVL(v_mto_pagar_propios,''); --quitar 0 en missings Y DEJAR VACIO
					
					IF  v_mto_pagar_propios = 0 THEN 
						LET v_mto_otros_vs_propios = '';
					ELSE
						LET v_mto_otros_vs_propios = v_mto_pagar_otros / v_mto_pagar_propios;
					END IF;					
					
					LET v_sdo_sic = NVL(v_sdo_actual_propio_ship,0) + NVL(v_sdo_actual_otros_ship,0);
					
					IF v_sdo_sic = 0 THEN 
						LET v_mtovssdo_sic = 0 ;
					ELSE	
						LET v_mtovssdo_sic = (v_mto_pagar_propios + v_mto_pagar_otros)/v_sdo_sic;
					END IF;
					
					IF v_ingresos_mens_brutos = 0  OR v_ingresos_mens_brutos is null THEN
						LET v_porcentaje_endeuda = 0;
					ELSE
						LET v_porcentaje_endeuda = ROUND((v_mto_pagar_otros + v_mto_pagar_propios)/ v_ingresos_mens_brutos,6);
					END IF;	

					--CAMPO 85 Ant_Otr_Inst
					IF v_ant_otro_inst IS NULL THEN
						LET v_ant_otro_inst = 0;
					ELSE
						LET v_ant_otro_inst = v_ant_otro_inst;
					END IF;	
					
					--CAMPO 86 SaldoActual_Propio_Ship
					--LET v_sdo_actual_propio_ship =NVL(v_sdo_actual_propio_ship,0);
                    
                    IF v_mto_pagar_otros IS NULL THEN
                        LET v_mto_pagar_otros ="";
                    END IF;
                    
                    IF v_mto_pagar_propios IS NULL THEN
                        LET v_mto_pagar_propios ="";
                    END IF;
					
                    IF v_sdo_actual_propio_ship IS NULL THEN
                        LET v_sdo_actual_propio_ship ="";
                    END IF;
                    
                    IF v_sdo_actual_otros_ship IS NULL THEN
                        LET v_sdo_actual_otros_ship ="";
                    END IF;

                    IF v_antiguedad_inst IS NULL THEN
                        LET v_antiguedad_inst = "";
                    END IF;

					IF v_veces_ult_atr1d_todos IS NULL AND v_atr > 0 THEN 
							LET v_bkatr = 0;
					END IF;
						
                    IF v_veces_ult_atr1d_todos IS NULL THEN
                        LET v_veces_ult_atr1d_todos = "";
                    END IF;
					
					IF v_var_mtosdo IS NULL THEN
						LET v_var_mtosdo = "";
				END IF;	
			END IF;
			--END IF; --END 6400
            --END FOREACH;    

            
            
           --LET v_capital_cierre= v_capital_vigente + v_capital_vencido;
            --LET v_porcentaje_pago = round(v_porcentaje_pago,6);
			
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

            /*SELECT count(fecha_cuota) INTO v_num_pagos_vencidos  
					FROM bdicred:sd_amortiza_creditocrd 
					WHERE num_Credito = v_num_credito 
					      AND capital_status in (2,7)
					     AND fecha_cuota <= pPeriodo;*/
					     
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
			
					
			select nvl(b.monto,0) Into v_gastos_originacion from sd_definicion a
            inner join sd_tpcomis b
            on a.cod_comision_apertura=b.cod_comis
            where num_producto=v_num_producto;  
			
			IF v_gastos_originacion is NULL THEN
				LET v_gastos_originacion=0;
			END IF;
			
			execute procedure "informix".sp_tasaefectiva(v_linea_autorizada, v_gastos_originacion, v_tasa_contractual, v_plazo_total, v_facturacion)
				INTO v_tir_mensual, v_tasa_efectiva;
				
				IF v_tasa_contractual=0 THEN 
					LET v_tasa_contractual=0.00001;
				ELSE
					LET v_tasa_contractual= v_tasa_contractual/100;
				END IF;
				
				IF  nvl(v_tasa_efectiva,'')='' or v_tasa_efectiva=0 THEN
						LET v_tasa_efectiva=0.00001;
					END IF;
            
            IF EXISTS (SELECT * FROM bdisolic:ss_Revision_determinacion WHERE num_solicitud = v_num_credito) THEN
                SELECT evalua_cc, bs_score, score_prop
                INTO c_evalua_cc,n_scoreburo, n_scoreotor
                FROM bdisolic:ss_Revision_determinacion 
                WHERE num_solicitud = v_num_credito;
            ELSE			
                SELECT a.evalua_cc, b.evaluacion, c.evaluacion
                INTO c_evalua_cc, n_scoreburo, n_scoreotor
                FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
                 ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
                LEFT JOIN bdisolic:ss_resumen_scoring c
                 ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
                WHERE a.num_solicitud = v_num_credito; 	
            END IF;
            
            IF c_evalua_cc='X' THEN
                LET v_modelo_score='NO HIT';
            ELIF c_evalua_cc in('0','1','2','3','4') THEN
                LET v_modelo_score='HIT';
            END IF;
            
            IF v_plazo_remanente < 1 THEN
                LET v_periodo_rem_n=1;
            ELSE
                LET v_periodo_rem_n = v_plazo_remanente;
            END IF;
            
            IF v_num_producto='6400' THEN
                SELECT num_cta INTO v_num_ctanom 
                FROM SD_CTASCARG WHERE num_credito=v_num_credito;
                
                IF (SELECT  COUNT(cuenta)		
                    FROM bdicheq:"informix".sc_movhis mov
                    INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
                    WHERE cuenta = v_num_ctanom 
                    AND cancelad <> 'S'
                    AND fech_alt BETWEEN (piniPeriodo -2 units month ) AND pPeriodo) =0 THEN 
                
                    IF (SELECT COUNT(cuenta)		
                        FROM bdicheq:"informix".sc_movhis_old mov
                        INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
                        WHERE cuenta = v_num_ctanom 
                        AND cancelad <> 'S'
                        AND fech_alt BETWEEN (piniPeriodo -2 units month ) AND pPeriodo) = 0 THEN 
                
                        LET v_cred_exnomina=1;
                    ELSE
                        LET v_cred_exnomina=0;
                    END IF;	
                ELSE
                    LET v_cred_exnomina=0;
                END IF;	
            END IF;
			
			--LET v_intereses_etapa3=v_interes_deven_ven_bal;
			
			--IF v_atr > 3 THEN
            --   LET v_etapa_cred='3';
				--IF v_num_producto='6400' THEN
			IF v_etapa_cred='E3' THEN
					LET v_intereses_etapa1=0;
					LET v_intereses_etapa2=0;
					LET v_intereses_etapa3=  nvl(v_interes_deven_ven_bal,0) +  nvl(v_interes_deven_vig_bal,0) + nvl(psaldoInteresApoyo,0); ---v_interes_vencido_bal+v_interes_vigente;   pdig
				--END IF;
			--ELIF v_atr=0 or v_atr1=0 or (v_atr <= 1 and v_fecha_ult_pago <= v_fecha_corte) THEN
			ELIF v_etapa_cred='E1' THEN
                ---LET v_etapa_cred='1';
				--IF v_num_producto='6400' THEN
					LET v_intereses_etapa1=nvl(v_interes_deven_ven_bal,0) +  nvl(v_interes_deven_vig_bal,0) + nvl(psaldoInteresApoyo,0);  ---v_interes_vencido_bal+v_interes_vigente; pdig
					LET v_intereses_etapa2=0;
					LET v_intereses_etapa3=0;
				
				--END IF;
			ELSE
            --ELIF v_atr >= 2 AND v_atr <= 3 THEN
               -- LET v_etapa_cred='2';
				--IF v_num_producto='6400' THEN
					LET v_intereses_etapa1=0;
					LET v_intereses_etapa2=nvl(v_interes_deven_ven_bal,0) +  nvl(v_interes_deven_vig_bal,0) + nvl(psaldoInteresApoyo,0);   ---v_interes_vencido_bal+v_interes_vigente;  pdig
					LET v_intereses_etapa3=0;
				--END IF;
            END IF;
			
			IF NVL(v_grupo_originacion,'')='' THEN
				EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo_cons(v_num_credito)
				INTO v_codret,v_tipogrupo,v_hit;
				
				LET v_grupo_originacion=v_tipogrupo;
			END IF;
		
		---NUEVOS CAMPOS MONTOS MAYORES
		LET v_fecha_ult_disp=v_fecha_apertura;
		
		IF (NVL(v_sdo_actual_otros_ship,0)=0 AND NVL(v_sdo_actual_otros_ship,0)=0) THEN
			LET v_mtosdos=0;
		ELSE
			LET v_mtosdos=(NVL(v_mto_pagar_otros,0) + NVL(v_mto_pagar_propios,0)/(NVL(v_sdo_actual_otros_ship,0)+ NVL(v_sdo_actual_otros_ship,0)));
		END IF;
		
		LET v_mto_exig_com=0;
		LET v_mto_exig_com_cob=0;
		LET v_pago_exig_com=0;
		LET v_pago_exig_com_cob=0;
		
		SELECT 
		REPLACE(trim(a.nombre1),'  ',' ')|| " " || REPLACE(trim(a.nombre2),'  ',' ') as nombre_cte,
		trim(a.apell_paterno)|| " " || trim(a.apell_materno) as apellidos,
		case when length(a.rfc)=13 then a.rfc else "" end rfc,
		trim(b.curp), --REPLACE(trim(b.curp), '|', 'X'), --trim(b.curp), 
		case when b.sexo='F' then 'FEMENINO' else 'MASCULINO' end sexo
        INTO v_nombre_cte,v_apellidos, v_rfc, v_curp, v_genero_cte
        from  bdinteg:si_cliente a
		inner join bdinteg:si_ctepf b
        on a.numcte=b.numcte
        and a.empresa=b.empresa
		where a.numcte =v_num_cliente;
		
		LET v_pago_exig_int= v_pago_int_venc_bal+v_pago_int_venc_ord+v_pago_interes_vigente;
		LET v_pago_exig_iva= v_pago_iva_int_venc_ord+v_pago_iva_interes_vigente;
		
		SELECT capital_mto_cuota INTO v_pago_contractual 
		FROM bdicred:sd_amortiza_creditocrd 
		WHERE num_pago=1
		  AND num_Credito = v_num_credito;

		
		IF v_status_fin_mes='BA' or v_status_fin_mes='BT' OR  ((v_status_fin_mes='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) THEN				
			IF v_fecha_vencimiento >= pPeriodo THEN
				SELECT nvl(mto_fin_ven_trasp,0) 
				INTO v_num_pagos_vencidos
				FROM sd_maesdoscontcrd 
				WHERE num_credito =v_num_credito
				--AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
				AND fecha= pPeriodo;  --30/06/2018
				
			ELSE
				--Si ya llego a su fecha de vencimiento
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
		ELSE
			LET v_num_pagos_vencidos=0;
		   
		END IF;
		
		IF day(pPeriodo)='31' THEN 
				SELECT capvig31, captrans31, capvencnoexig31, capvenexig31, intvig31, intvenc31, ivaintvig31, ivaintvenc31
				INTO v_capital_vig_cierre,v_capital_trans_cierre,v_capital_venc_no_exig_cierre, v_capital_venc_exig_cierre,v_int_vig_cierre,int_venc_cierre, v_iva_int_vig_cierre, v_iva_int_venc_cierre
				FROM sd_sdodiariocrd 
				WHERE num_credito=v_num_credito and fecha = piniPeriodo;
			END IF;

			IF day(pPeriodo)='30' THEN 
				SELECT capvig30, captrans30, capvencnoexig30, capvenexig30, intvig30, intvenc30, ivaintvig30, ivaintvenc30 
				INTO v_capital_vig_cierre,v_capital_trans_cierre,v_capital_venc_no_exig_cierre, v_capital_venc_exig_cierre,v_int_vig_cierre,int_venc_cierre, v_iva_int_vig_cierre, v_iva_int_venc_cierre
				FROM sd_sdodiariocrd 
				WHERE num_credito=v_num_credito and fecha = piniPeriodo;
			END IF;

			IF day(pPeriodo)='29' THEN 
				SELECT capvig29, captrans29, capvencnoexig29, capvenexig29, intvig29, intvenc29, ivaintvig29, ivaintvenc29
				INTO v_capital_vig_cierre,v_capital_trans_cierre,v_capital_venc_no_exig_cierre, v_capital_venc_exig_cierre,v_int_vig_cierre,int_venc_cierre, v_iva_int_vig_cierre, v_iva_int_venc_cierre
				FROM sd_sdodiariocrd 
				WHERE num_credito=v_num_credito and fecha = piniPeriodo;
			END IF;

			IF day(pPeriodo)='28' THEN 
				SELECT capvig28, captrans28, capvencnoexig28, capvenexig28, intvig28, intvenc28, ivaintvig28, ivaintvenc28 
				INTO v_capital_vig_cierre,v_capital_trans_cierre,v_capital_venc_no_exig_cierre, v_capital_venc_exig_cierre,v_int_vig_cierre,int_venc_cierre, v_iva_int_vig_cierre, v_iva_int_venc_cierre
				FROM sd_sdodiariocrd 
				WHERE num_credito=v_num_credito and fecha = piniPeriodo;
			END IF;

			SELECT SUM(capital_debe), SUM(capital_pagado), sum(interes_debe), sum(interes_pagado), sum(iva_debe), sum(iva_pagado) 
			INTO v_cap_debe, v_cap_pagado, v_interes_debe, v_interes_pagado, v_iva_debe, v_iva_pagado
			FROM sd_amortiza_creditocrd where num_credito=v_num_credito;
			
			LET v_mto_exig_cap=nvl(v_cap_debe,0)-nvl(v_cap_pagado,0);
			LET v_mto_exig_int=nvl(v_interes_debe,0) - nvl(v_interes_pagado,0);
			LET v_mto_exig_iva=nvl(v_iva_debe,0) - nvl(v_iva_pagado,0);
			
			/*SELECT capital_debe, interes_debe,iva_debe
			INTO v_cap_debe, v_interes_debe, v_iva_debe
			FROM sd_amortiza_creditocrd where num_credito=v_num_credito AND fecha_cuota=v_fecha_corte;

			LET v_mto_exig_cap=nvl(v_cap_debe,0);
			LET v_mto_exig_int=nvl(v_interes_debe,0);
			LET v_mto_exig_iva=nvl(v_iva_debe,0);*/
			
		
				 
			
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
			--Oneclick campos faltantes |Canal |Productos 1300 2100 |empleado
			SELECT FIRST 1 canal_sol
			INTO v_canal
			FROM bdisolic:ss_solicitudes WHERE num_solicitud=v_num_credito;
			IF vprod_proc='6400' AND (v_canal='6' OR v_canal='7') THEN
				IF v_canal='6' THEN
					LET v_canal_suc_o_app='Sucursal';
				ELIF v_canal='7' THEN
					LET v_canal_suc_o_app='Aplicacion';
				END IF
		
				SELECT FIRST 1 CASE WHEN producto in('1300','2100') THEN producto ELSE '0000' END
				INTO v_producto
                FROM bdicheq:sc_maechq WHERE num_cte=v_num_cliente and status_cta='1';
				
				SELECT FIRST 1 CASE WHEN COUNT(numcte) > 0 THEN '1' ELSE '0' END
				INTO v_empleado
                FROM bdinteg:si_empleado_cliente_coppel WHERE numcte=v_num_cliente and status='1';
			END IF	
                --BEGIN WORK;
				INSERT INTO sd_insumos_calif_pp ( fecha_cierre,
												   alto, --nvo
												   antecedentes_buro,antiguedad_cliente,atr,atr1,atr2,atr3,
												   bajo, --nvo
												   capital_exigible,
												   comisiones,consulta_sin_info, --nvos
                                                   cred_liquida_cred,cred_nomina,grupo_originacion,delegada,dias_atraso,eficiencia,                  
                                                   facturacion,fecha_apertura,fecha_apertura_cte,fecha_corte,fecha_vencimiento,           
                                                   ingresos_mens_brutos,ingresos_mens_netos,int_mora_copete,int_mora_ordinario,         
                                                   interes_deven_ven_bal,interes_deven_vig_bal,interes_devengados_ord,interes_vencido_bal,
                                                   interes_vencido_ord,interes_vigente,iva_interes_vencido_bal,iva_interes_vencido_ord,
                                                   iva_interes_vigente,linea_autorizada,max_atr,
												   medio, meses_bkatr, --nvos
												   antiguedad,monto_exigible,monto_exigible1,
                                                   monto_exigible2,monto_exigible3,monto_exigible4,monto_exigible5,monto_exigible6,	
												   monto_exigible7,monto_exigible8,monto_exigible9,monto_exigible10,monto_exigible11,
												   monto_exigible12,monto_exigible13,	
												   monto_otros_vs_propios, monto_pagar_otros,monto_pagar_propios,mto_vs_sdo_sic, --nvos												   
												   num_cliente,num_credito,num_disposiciones,num_producto,pago_capital,pago_int_venc_bal,pago_int_venc_ord,
                                                   pago_interes_vigente,pago_iva_int_venc_bal,pago_iva_int_venc_ord,pago_iva_interes_vigente,
                                                   pago_realizado,pago_realizado1,pago_realizado2,pago_realizado3,pago_realizado4,pago_realizado5,
                                                   pago_realizado6, pago_realizado7,pago_realizado8,pago_realizado9,pago_realizado10,pago_realizado11,
												   pago_realizado12,pago_realizado13,periodos_incumplimiento,plazo_remanente,plazo_total,		   
												   porcentaje_endeudamiento, --nvo
												   porcentaje_pago,porcentaje_uso,ree_tdc_anterior,saldo_cierre,saldo_corte,saldo_exigible,saldo_no_exigible,
												   saldo_sic,sin_consulta,--nvo
												   status_fin_mes,
												   cum_pag_sost, ant_otr_inst,saldoactual_propio_ship,comision_cobranza,comisionexig_cobranza, sdo_actual_otros_ship, 
                                                   numero_cuenta_det, antiguedad_inst, meses_ult_atr1d_todos, var_mtosdo, sucursal, cred_exnomina, etapa_cred, intereses_etapa3, tasa_contractual, capital_cierre, 
                                                   gastos_originacion,num_pagos_vencidos,cred_sit_especial,score_originacion,score_buro,modelo_score,periodo_rem_n, tasa_efectiva, fecha_ult_pago,
												   intereses_etapa1,intereses_etapa2,int_apoyo,fecha_ult_disp,pago_contractual, mtosdo,mto_exig_com,mto_exig_com_cob,pago_exig_com,pago_exig_com_cob,
												   nombre_cte, rfc, curp, genero_cte,pago_exig_int,pago_exig_iva, cap_vig, cap_trans, cap_venc_no_exig,cap_venc_exig,int_vigente, int_vencido, int_orden,
												   iva_int_vigente, iva_int_vencido, mto_exig_cap, mto_exig_int, mto_exig_iva, --nvos
												   Pct_Pgo0,Pct_pago1,Pct_pago2,Pct_pago3,Dias_Rem_Contractual,origen,canal,empleado)--nuevos sep
                                             VALUES( pPeriodo, 
												   v_alto,
												   v_antecedentes_buro,v_antiguedad_cliente,nvl(v_atr,0),nvl(v_atr1,0),nvl(v_atr2,0),nvl(v_atr3,0),
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
                                                   nvl(v_monto_exigible2,0),nvl(v_monto_exigible3,0),nvl(v_monto_exigible4,0),nvl(v_monto_exigible5,0),nvl(v_monto_exigible6,0),
												   nvl(v_monto_exigible7,0),nvl(v_monto_exigible8,0),nvl(v_monto_exigible9,0),nvl(v_monto_exigible10,0),nvl(v_monto_exigible11,0),
												   nvl(v_monto_exigible12,0),nvl(v_monto_exigible13,0),
												   v_mto_otros_vs_propios,v_mto_pagar_otros, v_mto_pagar_propios,v_mtovssdo_sic, --nvos
												   v_num_cliente,v_num_credito,v_num_disposiciones,v_num_producto,v_pago_capital,v_pago_int_venc_bal,v_pago_int_venc_ord,
                                                   v_pago_interes_vigente,v_pago_iva_int_venc_bal,v_pago_iva_int_venc_ord,v_pago_iva_interes_vigente,
                                                   nvl(v_pago_realizado,0),nvl(v_pago_realizado1,0),nvl(v_pago_realizado2,0),nvl(v_pago_realizado3,0),nvl(v_pago_realizado4,0),nvl(v_pago_realizado5,0),
                                                   nvl(v_pago_realizado6,0),nvl(v_pago_realizado7,0),nvl(v_pago_realizado8,0),nvl(v_pago_realizado9,0),nvl(v_pago_realizado10,0),
												   nvl(v_pago_realizado11,0),nvl(v_pago_realizado12,0),nvl(v_pago_realizado13,0),v_periodos_incumplimiento,v_plazo_remanente,v_plazo_total,
												   v_porcentaje_endeuda,
												   v_porcentaje_pago,v_porcentaje_uso,v_ree_tdc_anterior,nvl(v_saldo_cierre,0),nvl(v_saldo_corte,0),nvl(v_saldo_exigible,0),nvl(v_saldo_no_exigible,0),
												   v_sdo_sic,v_sin_consulta,
												   v_status_fin_mes,
												   v_cum_pago_sost,v_ant_otro_inst,v_sdo_actual_propio_ship,NVL(d_comision_cobranza,0), NVL(d_comisionexig_cobranza, 0),v_sdo_actual_otros_ship,
                                                   v_numero_cuenta_det,v_antiguedad_inst, v_veces_ult_atr1d_todos, v_var_mtosdo, v_sucursal, v_cred_exnomina, v_etapa_cred, v_intereses_etapa3,v_tasa_contractual, v_capital_cierre,
                                                   NVL(v_gastos_originacion,0), v_num_pagos_vencidos,v_cred_sit_especial,n_scoreotor,n_scoreburo,v_modelo_score,v_periodo_rem_n, v_tasa_efectiva,v_fecha_ult_pago,
												   v_intereses_etapa1,v_intereses_etapa2, psaldoInteresApoyo,v_fecha_ult_disp,v_pago_contractual,nvl(v_mtosdos,0),v_mto_exig_com,v_mto_exig_com_cob,v_pago_exig_com,v_pago_exig_com_cob,
												   trim(v_nombre_cte)||' '||trim(v_apellidos), v_rfc, v_curp, v_genero_cte,v_pago_exig_int,v_pago_exig_iva,v_capital_vig_cierre,v_capital_trans_cierre,v_capital_venc_no_exig_cierre, 
												   v_capital_venc_exig_cierre,v_int_vig_cierre,int_venc_cierre, nvl(v_interes_orden,0),v_iva_int_vig_cierre, v_iva_int_venc_cierre,v_mto_exig_cap,v_mto_exig_int,v_mto_exig_iva, --nvos
												   v_prom1,v_prom2,v_prom3,v_prom4,v_dias_rem_contractual,v_producto,v_canal_suc_o_app,v_empleado);
												   
            --Limpieza de Variables oneclick
			LET v_canal_suc_o_app='';
			LET v_producto ='';
			LET v_empleado='';
				--COMMIT WORK;
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
    LET cMensajeRet = "REPORTE DE PRESTAMOS OK "|| vprod_proc;
	LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	
	
	RETURN cCodRet, cMensajeRet, cMensajeRet2;
END
END PROCEDURE
;
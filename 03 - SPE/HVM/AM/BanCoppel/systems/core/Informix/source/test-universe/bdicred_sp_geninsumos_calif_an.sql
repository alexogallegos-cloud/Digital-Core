create procedure "informix".sp_geninsumos_calif_an()
       returning char(5) ,CHAR(100),char(60);


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
DEFINE v_dias_atraso                   	DECIMAL(18,2);
DEFINE v_dias_atraso_1                 	DECIMAL(18,2);
DEFINE v_dias_atraso_2                 	DECIMAL(18,2);
DEFINE v_dias_atraso_3                 	DECIMAL(18,2);
DEFINE v_meses_d   						DECIMAL(18,2);
DEFINE v_meses_i 						INTEGER;
DEFINE v_mesatr							INTEGER;
DEFINE v_fecatr							DATE;
DEFINE v_eficiencia                    	SMALLINT;
DEFINE v_facturacion                   	CHAR(2);
DEFINE v_fecha_apertura                	DATE;
DEFINE v_fecha_apertura_format          CHAR(12);
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
DEFINE v_max_atr                      	DECIMAL(18,2);DEFINE v_antiguedad                   	INTEGER;
DEFINE v_monto_exigible               	DECIMAL(18,2);
DEFINE v_monto_exigible1              	DECIMAL(18,2);
DEFINE v_monto_exigible2              	DECIMAL(18,2);
DEFINE v_monto_exigible3              	DECIMAL(18,2);
DEFINE v_monto_exigible4              	DECIMAL(18,2);
DEFINE v_monto_exigible5              	DECIMAL(18,2);
DEFINE v_monto_exigible6              	DECIMAL(18,2);
DEFINE v_num_cliente                  	CHAR(20);
DEFINE v_num_credito                  	CHAR(20);
DEFINE v_num_disposiciones            	SMALLINT;
DEFINE vdisp_per						SMALLINT;
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
DEFINE v_incumplimiento                	DECIMAL(18,2);
DEFINE v_incumplimiento_old             DECIMAL(18,2);
DEFINE v_periodos_incumplimiento    	DECIMAL(18,2);
DEFINE v_plazo_remanente            	DECIMAL(18,5);
DEFINE v_plazo_total                  	INTEGER;
DEFINE v_porcentaje_pago             	DECIMAL(18,2);
DEFINE v_porcentaje_uso               	DECIMAL(18,6);
DEFINE v_ree_tdc_anterior              	SMALLINT;
DEFINE v_saldo_cierre                 	DECIMAL(18,2);
DEFINE v_saldo_corte                   	DECIMAL(18,2);
DEFINE v_saldo_exigible              	DECIMAL(18,2);
DEFINE v_saldo_no_exigible             	DECIMAL(18,2);
DEFINE v_status_fin_mes               	CHAR(2);
DEFINE v_status_fin_mes1               	CHAR(2);
DEFINE v_status_fin_mes2               	CHAR(2);
DEFINE v_status_fin_mes3               	CHAR(2);
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

DEFINE v_capital_vigente1    DECIMAL(18,2);
DEFINE v_capital_vencido1    DECIMAL(18,2);
DEFINE v_int_vigente1        DECIMAL(18,2);
DEFINE v_iva_vigente1        DECIMAL(18,2);
DEFINE v_interes_orden1      DECIMAL(18,2);
DEFINE v_iva_interes_orden1  DECIMAL(18,2);

DEFINE v_capital_vigente2    DECIMAL(18,2);
DEFINE v_capital_vencido2    DECIMAL(18,2);
DEFINE v_int_vigente2        DECIMAL(18,2);
DEFINE v_iva_vigente2        DECIMAL(18,2);
DEFINE v_interes_orden2      DECIMAL(18,2);
DEFINE v_iva_interes_orden2  DECIMAL(18,2);

DEFINE v_capital_vigente3    DECIMAL(18,2);
DEFINE v_capital_vencido3    DECIMAL(18,2);
DEFINE v_int_vigente3        DECIMAL(18,2);
DEFINE v_iva_vigente3        DECIMAL(18,2);
DEFINE v_interes_orden3      DECIMAL(18,2);
DEFINE v_iva_interes_orden3  DECIMAL(18,2);

DEFINE v_capital_vigente4    DECIMAL(18,2);
DEFINE v_capital_vencido4    DECIMAL(18,2);
DEFINE v_int_vigente4        DECIMAL(18,2);
DEFINE v_iva_vigente4        DECIMAL(18,2);
DEFINE v_interes_orden4      DECIMAL(18,2);
DEFINE v_iva_interes_orden4  DECIMAL(18,2);

DEFINE v_capital_vigente5    DECIMAL(18,2);
DEFINE v_capital_vencido5    DECIMAL(18,2);
DEFINE v_int_vigente5        DECIMAL(18,2);
DEFINE v_iva_vigente5        DECIMAL(18,2);
DEFINE v_interes_orden5      DECIMAL(18,2);
DEFINE v_iva_interes_orden5  DECIMAL(18,2);

DEFINE v_capital_vigente6    DECIMAL(18,2);
DEFINE v_capital_vencido6    DECIMAL(18,2);
DEFINE v_int_vigente6        DECIMAL(18,2);
DEFINE v_iva_vigente6        DECIMAL(18,2);
DEFINE v_interes_orden6      DECIMAL(18,2);
DEFINE v_iva_interes_orden6  DECIMAL(18,2);

DEFINE v_prom1               DECIMAL(18,10);
DEFINE v_prom2               DECIMAL(18,10);
DEFINE v_prom3               DECIMAL(18,10);
DEFINE v_prom4               DECIMAL(18,10);
DEFINE v_prom5               DECIMAL(18,10);
DEFINE v_prom6               DECIMAL(18,10);
DEFINE v_prom7               DECIMAL(18,10);
DEFINE bandera_exigible  	 INTEGER;
DEFINE bandera_fechas  		 INTEGER;
DEFINE tot_var_fec   		 INTEGER;
DEFINE v_prom_tot 			 DECIMAL(18,10);
DEFINE var_div   			INTEGER;
DEFINE dia_corte_ant         SMALLINT;
DEFINE num_corte1            CHAR(10);

DEFINE c_CodRet                          CHAR(6); 
DEFINE mMensaje                         VARCHAR(100,1); 
DEFINE dFechaPer0                       DATE; 
DEFINE dFechaPer0_1                       DATE; 
DEFINE dFechaPer1                       DATE; 
DEFINE dFechaPer1_1                       DATE; 
DEFINE dFechaPer2                       DATE;
DEFINE dFechaPer2_1                       DATE; 
DEFINE dFechaPer3                       DATE; 
DEFINE dFechaPer3_1                       DATE; 
DEFINE dFechaPer4                       DATE; 
DEFINE dFechaPer4_1                       DATE; 
DEFINE dFechaPer5                       DATE; 
DEFINE dFechaPer5_1                       DATE; 
DEFINE dFechaPer6                       DATE; 
DEFINE dFechaPer6_1                       DATE; 
DEFINE dFechaPer7                       DATE; 
DEFINE dFechaPer7_1                       DATE; 

DEFINE pPeriodo_ant1                       DATE; 
DEFINE pPeriodo_ant2                       DATE; 
DEFINE pPeriodo_ant3                       DATE; 

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
    DEFINE v_tasa_contractual DECIMAL(18,7);
    DEFINE v_capital_cierre DECIMAL(18,2);
    DEFINE v_antiguedad_inst INTEGER;
    DEFINE v_veces_ult_atr1d_todos INTEGER;
    --DEFINE v_plazo_contractual INTEGER;
    DEFINE v_num_ctanom CHAR(20);
    DEFINE v_cred_exnomina SMALLINT;
    DEFINE v_etapa_cred CHAR(8);
    DEFINE v_gastos_originacion DECIMAL(18,2);
    DEFINE n_scoreburo				INTEGER;
    DEFINE n_scoreotor				INTEGER;
    DEFINE v_modelo_score   CHAR(6);
    DEFINE c_evalua_cc				 CHAR(1);
    DEFINE v_periodo_rem_n  DECIMAL(18,6);
	DEFINE v_tir_mensual DECIMAL(18,2);
	DEFINE v_tasa_efectiva DECIMAL(18,7);
	DEFINE v_fecha_ult_pago DATE;
	DEFINE v_intereses_etapa1 DECIMAL(18,2);
	DEFINE v_intereses_etapa2 DECIMAL(18,2);
	DEFINE v_intereses_etapa3 DECIMAL(18,2);
	DEFINE v_codret CHAR(5);
	DEFINE v_tipogrupo CHAR(2);
	DEFINE v_hit CHAR(6);

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
LET v_dias_atraso_1                 = 0;
LET v_dias_atraso_2                 = 0;
LET v_dias_atraso_3                 = 0;
LET v_meses_d 	                 	= 0;
LET v_meses_i 	                 	= 0;
LET v_mesatr						= 0;
LET v_fecatr						= DATE(1);
LET v_eficiencia                    = 0;
LET v_facturacion                   = "";
LET v_fecha_apertura                = DATE(1);
LET v_fecha_apertura_format         = "";
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
LET v_num_cliente                  	= "";
LET v_num_credito                  	= "";
LET v_num_disposiciones            	= 0;
LET vdisp_per						= 0;
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
LET v_incumplimiento                = 0;
LET v_incumplimiento_old            = 0;
LET v_periodos_incumplimiento    	= 0;
LET v_plazo_remanente            	= 0;
LET v_plazo_total                  	= 12;
--LET v_plazo_contractual				= 12;
LET v_porcentaje_pago             	= 0;
LET v_porcentaje_uso               	= 0;
LET v_ree_tdc_anterior              = 0;
LET v_saldo_cierre                 	= 0;
LET v_saldo_corte                   = 0;
LET v_saldo_exigible              	= 0;
LET v_saldo_no_exigible             = 0;
LET v_status_fin_mes               	= "";
LET v_status_fin_mes1               = "";
LET v_status_fin_mes2               = "";
LET v_status_fin_mes3              	= "";
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

LET v_prom1               =0;
LET v_prom2               =0;
LET v_prom3               =0;
LET v_prom4               =0;
LET v_prom5               =0;
LET v_prom6               =0;
LET v_prom7               =0;
LET bandera_exigible 	  = 0 ;
LET bandera_fechas		  =0;
LET tot_var_fec			  =0;	
LET v_prom_tot 			  = 0;
LET var_div   			  = 0;

LET c_CodRet                         =""; 
LET mMensaje                        ="";  
LET dFechaPer0                      =DATE(1); 
LET dFechaPer0_1                    =DATE(1); 
LET dFechaPer1                      =DATE(1); 
LET dFechaPer1_1                    =DATE(1); 
LET dFechaPer2                      =DATE(1);
LET dFechaPer2_1                    =DATE(1); 
LET dFechaPer3                      =DATE(1); 
LET dFechaPer3_1                    =DATE(1); 
LET dFechaPer4                      =DATE(1); 
LET dFechaPer4_1                    =DATE(1); 
LET dFechaPer5                      =DATE(1); 
LET dFechaPer5_1                    =DATE(1); 
LET dFechaPer6                      =DATE(1); 
LET dFechaPer6_1                    =DATE(1); 
LET dFechaPer7                      =DATE(1); 
LET dFechaPer7_1                    =DATE(1); 
 
LET pPeriodo_ant1                  =DATE(1);
LET pPeriodo_ant2                  =DATE(1); 
LET pPeriodo_ant3                  =DATE(1);

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
    LET v_num_ctanom = '';
    LET v_cred_exnomina = 0;
    LET v_etapa_cred = '';
    LET v_gastos_originacion =0;
    LET n_scoreburo	= 0;
    LET n_scoreotor	= 0;
    LET v_modelo_score ='';
    LET c_evalua_cc ='';
    LET v_periodo_rem_n = 0;
	LET v_tir_mensual = 0;
	LET v_tasa_efectiva = 0;
	LET v_fecha_ult_pago = DATE(1);
	LET v_intereses_etapa1 =0;
    LET v_intereses_etapa2 =0;
	LET v_intereses_etapa3 =0;
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
          LET cCodRet= iSqlErr;
          LET cMensajeRet= cErrorInfo;
	  	  LET cMensajeRet2 = '';
		  IF (val_trans_Commit = -1) THEN
			rollback work;
		  END IF; 		
		  RETURN cCodRet,v_num_credito,cMensajeRet2;
    END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOSNEW/SI1556/sp_geninsumos_calif_an_prod.out";
--TRACE ON;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;
	
SELECT  pri_dia_mes - 1 units day
INTO  pPeriodo
FROM bdicred:sd_fechas
WHERE empresa='001';

--LET pPeriodo = mdy('11','30','2023'); --para pruebas
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

--Crea universo a procesar
select 
a.num_credito, a.numcte,
a.fecha_apertura,a.fecha_vencim,
--a.id_unidad_prod  cod_bloqueo, 
a.status_cred status_mes_reporte, a.sucursal, a.tasa_interes
from sd_maecredcont a
where a.fecha = pPeriodo  AND a.empresa = '001'
and a.num_credito not in (select num_credito from sd_insumos_calif_pp where fecha_cierre = pPeriodo and num_producto = '7800')
--Pruebas
--and a.num_credito ='780000005725'
--and a.num_credito in  ('780000606100','780000157369','780000145612')
--d a.num_credito in  ('780000606100','780000157369','780000145612','780000098563','780000037231')
--Pruebas
and a.num_producto in ('7800')
into temp univ_ctas_calif with no log;

begin;
CREATE INDEX idx_univcalif ON univ_ctas_calif(num_credito) ONLINE;
commit;

update statistics medium for table univ_ctas_calif;

--Extrae base de movimientos de Pagos del ultimo cuatrimestre
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from bdicred:sd_movhis
where empresa = '001'
and fecha_mov >= (piniPeriodo - 4 units month) --mdy ('02','01','2018')
and fecha_mov <= pPeriodo        				--mdy ('11','30','2018')
and num_credito in (select num_Credito from univ_ctas_calif)
and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
and codigo_ref in (1)  
and reversado = 'N'
into temp movs_pagos with no log;

begin;
CREATE INDEX idx_movs_pagos ON movs_pagos(fecha_mov,num_credito) ONLINE;
commit;

update statistics medium for table movs_pagos;

--Comisiones
--Codigo_fun	Codigo_ref	Descripcion
--	339				98		Comision Apertura
--	340				28		IVA de Comision Apertura
--	339				99		Comision Disposicion
--	340				29		IVA de Comision Disposicion
	
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from bdicred:sd_movhis
where empresa = '001'
and fecha_mov >= piniPeriodo --mdy ('11','01','2018')
and fecha_mov <= pPeriodo        --mdy ('11','30','2018')
and num_credito in (select num_Credito from univ_ctas_calif)
and codigo_fun in ('339')
and codigo_ref in (98,99)  
and reversado = 'N'
into temp movs_comis with no log;

begin;
CREATE INDEX idx_movs_comis ON movs_comis(num_credito) ONLINE;
commit;

update statistics medium for table movs_comis;

--Disposiciones
/*
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from bdicred:sd_movhis
where empresa = '001'
and fecha_mov <= pPeriodo 
and num_credito in (select num_Credito from univ_ctas_calif)
and codigo_fun in ( '002')
and codigo_ref in (111)
and reversado = 'N'
UNION ALL
select num_credito,fecha_mov,codigo_fun,codigo_ref, reversado, monto
from bdicred:sd_movhis_new
where empresa = '001'
and fecha_mov <= pPeriodo 
and num_credito in (select num_Credito from univ_ctas_calif)
and codigo_fun in ( '002')
and codigo_ref in (111)
and reversado = 'N'
into temp movs_disp with no log;

begin;
CREATE INDEX idx_movs_disp ON movs_disp(num_credito) ONLINE;
commit;

update statistics medium for table movs_disp;
*/

--Variables Fijas
SELECT MAX(fecha_info) 
INTO dt_ultcons_varcc
FROM bdiburo:br_variables_cc_cnr;	-- en donde se almacena?

--Reproceso 
--LET dt_ultcons_varcc = mdy('12','31','2018');
--Reproceso 

LET v_cred_liquida_cred			= 0;
LET v_cred_nomina				= 1;
LET v_delegada					= 0;
LET v_ingresos_mens_brutos 		= 0;
LET v_int_mora_copete           = 0;
LET v_int_mora_ordinario        = 0;
LET v_interes_deven_ven_bal     = 0;
LET v_interes_deven_vig_bal     = 0;
LET v_interes_devengados_ord	= 0;
LET v_interes_vencido_bal       = 0;
LET v_interes_vencido_bal30     = 0;
LET v_interes_vencido_ord       = 0;
LET v_interes_vigente           = 0;
LET v_iva_interes_vencido_bal   = 0;
LET v_iva_interes_vencido_ord   = 0;
LET v_iva_interes_vigente       = 0;
LET v_pago_int_venc_bal         = 0;
LET v_pago_int_venc_ord         = 0;
LET v_pago_interes_vigente      = 0;
LET v_pago_iva_int_venc_bal     = 0;
LET v_pago_iva_int_venc_ord     = 0;
LET v_pago_iva_interes_vigente  = 0;
LET v_ree_tdc_anterior			= 0;
LET v_cum_pago_sost 			= 0;

	FOREACH WITH HOLD
		SELECT  num_credito, numcte, fecha_apertura, fecha_vencim,         
		 status_mes_reporte, sucursal,tasa_interes 
         INTO  v_num_credito,v_num_cliente, v_fecha_apertura, v_fecha_vencimiento,
         v_status_fin_mes, v_sucursal,v_tasa_contractual 
        FROM  univ_ctas_calif		
		--Campos 
		/*
		2 -v_antecedentes_buro 
		*/
		LET v_num_producto= '7800';
		
		
		SELECT b.sdo_cap_insoluto saldo_cierre
		,(b.monto_vencido + b.mto_venc_trasp + b.int_tra_no_exig + b.mto_venc_int) saldo_exigible
		,CASE WHEN (b.sdo_cap_insoluto - b.monto_vencido - b.mto_venc_trasp) <= 0 THEN 0 
			  ELSE (b.sdo_cap_insoluto - b.monto_vencido - b.mto_venc_trasp) END Saldo_No_Exigible
		,b.monto_otorgado  limite_credito
		--,(sdo_moratorio + sdo_contab_mora) moratorios
		,c.dia_corte
		,CASE WHEN c.dia_corte=31 THEN mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo)) 
			  WHEN month(pPeriodo)= 2 AND c.dia_corte in(31,30,29) THEN mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo))
		      ELSE mdy(month(pPeriodo),(c.dia_corte),year(pPeriodo)) END fecha_corte
		,d.dias_atraso --,e.evalua_cc evalua_cc, e.grupo grupo_originacion,e.situacion_pago eficiencia,e.ingreso_mensual
		,CASE WHEN f.frecuencia_pgo = 1 THEN 'M' 
			  WHEN f.frecuencia_pgo = 2 THEN 'Q' 	
			  ELSE 'M' END facturacion, moras_hist_h,
			  d.fecha_ultimo_pago_h
		--,ROUND((b.sdo_cap_insoluto / b.monto_otorgado),2)porcentaje_uso,		 
		INTO v_saldo_cierre
		,v_saldo_exigible
		,v_saldo_no_exigible
		,v_linea_autorizada
		,v_dia_corte
		,v_fecha_corte
		,v_dias_atraso --,v_antecedentes_buro,v_grupo_originacion,v_eficiencia,v_ingresos_mens_netos
		,v_facturacion , v_periodos_incumplimiento,
		v_fecha_ult_pago
		--,v_porcentaje_uso
		FROM bdicred:sd_maesdoscont b 
		INNER JOIN bdicred:sd_maecredanexo c ON ( b.empresa = c.empresa AND b.num_Credito = c.num_credito)
		--LEFT JOIN bdicred:sd_indicador_cred d ON (b.empresa = d.empresa AND b.num_Credito = d.num_credito)
		LEFT JOIN bdicred:sd_indicador_cred d ON (b.empresa = d.empresa AND b.fecha = pPeriodo AND b.num_Credito = d.num_credito)
		LEFT JOIN  bdisolic:ss_Revision_determinacion e ON ( b.num_Credito = e.num_solicitud)
		LEFT JOIN  bdisolic:ss_adn_solicitudcuenta f ON (b.num_credito = f.num_solicitud)
		WHERe b.fecha = pPeriodo 
		AND b.empresa = '001'
		AND  b.num_credito = v_num_credito;
		
		IF EXISTS (SELECT * FROM bdisolic:ss_Revision_determinacion WHERE num_solicitud = v_num_credito) THEN
            SELECT evalua_cc, bs_score, score_prop,grupo,situacion_pago,ingreso_mensual
            INTO c_evalua_cc,n_scoreburo, n_scoreotor,v_grupo_originacion,v_eficiencia,v_ingresos_mens_netos
            FROM bdisolic:ss_Revision_determinacion 
            WHERE num_solicitud = v_num_credito;
        ELSE			
            SELECT a.evalua_cc, b.evaluacion, c.evaluacion,a.grupo,a.situacion_pago,a.ingreso_mensual
            INTO c_evalua_cc, n_scoreburo, n_scoreotor,v_grupo_originacion,v_eficiencia,v_ingresos_mens_netos
            FROM bdisolic:ss_resum_scor_fin  a LEFT JOIN bdisolic:ss_resumen_scoring b
             ON a.num_solicitud = b.num_solicitud AND b.seccion = 1
            LEFT JOIN bdisolic:ss_resumen_scoring c
             ON a.num_solicitud = c.num_solicitud AND c.seccion = 2
            WHERE a.num_solicitud = v_num_credito; 	
        END IF;
		
		LET v_antecedentes_buro=c_evalua_cc;
		
		IF NVL(v_antecedentes_buro,"")="" AND NVL(v_ingresos_mens_netos,0)=0 THEN
		    SELECT FIRST 1 antecedentes_buro,ingresos_mens_netos
		    INTO v_antecedentes_buro, v_ingresos_mens_netos
		    FROM sd_insumos_calif_pp 
		    WHERE NUM_CREDITO=v_num_credito;
		END IF;
		
		IF v_saldo_cierre < 0 THEN
			LET v_saldo_cierre =0;	
		END IF;
		
		IF v_saldo_cierre>0 AND v_linea_autorizada>0 THEN
			LET v_porcentaje_uso = ROUND((v_saldo_cierre/v_linea_autorizada),6);
		ELSE
			LET v_porcentaje_uso = 0;
		END IF;
		
		IF (val_trans_Commit = 0) THEN
            BEGIN WORK;
            LET contador_commit = 0;
            LET val_trans_Commit = -1;
        END IF; 
		
		--EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_pam(v_empresa,v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
		--INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;
		LET dFechaPer0                      =DATE(1); 
		LET dFechaPer0_1                    =DATE(1); 
		LET dFechaPer1                      =DATE(1); 
		LET dFechaPer1_1                    =DATE(1); 
		LET dFechaPer2                      =DATE(1);
		LET dFechaPer2_1                    =DATE(1); 
		LET dFechaPer3                      =DATE(1); 
		LET dFechaPer3_1                    =DATE(1); 
		LET dFechaPer4                      =DATE(1); 
		LET dFechaPer4_1                    =DATE(1); 
		LET dFechaPer5                      =DATE(1); 
		LET dFechaPer5_1                    =DATE(1); 
		LET dFechaPer6                      =DATE(1); 
		LET dFechaPer6_1                    =DATE(1); 
		LET dFechaPer7                      =DATE(1); 
		LET dFechaPer7_1                    =DATE(1); 
		
		LET bandera_fechas = 1;
		
		IF v_fecha_apertura >= piniPeriodo and v_fecha_apertura <= pPeriodo  THEN
			--IF v_fecha_corte < v_fecha_apertura THEN
				SELECT min(fecha_cuota) 
				INTO dFechaPer0
				FROM sd_amortiza_credito
				WHERE num_credito =v_num_credito;										
			--END IF;
		ELSE		
			IF v_facturacion = 'M' THEN
				LET tot_var_fec = 10;
			ELSE	
				LET tot_var_fec = 16;
			END IF;	
			
			SELECT fecha--,sdo_cap_insoluto --INTO dFechaPer0
			FROM bdicred:sd_maesdoshist 
			WHERE  fecha <= pPeriodo
			and fecha >= piniPeriodo - 5 units month
			and num_credito = v_num_credito
			into temp fechas_cortes with no log;

			WHILE (bandera_fechas <= tot_var_fec ) LOOP
				IF bandera_fechas = 1 THEN				
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer0
					FROM fechas_cortes 
					WHERE  fecha <= pPeriodo;			
				ELIF bandera_fechas = 2 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer0_1
					FROM fechas_cortes 
					WHERE  fecha < dFechaPer0;	
				ELIF bandera_fechas = 3 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer1
					FROM fechas_cortes 
					WHERE  fecha < dFechaPer0_1;	
				ELIF bandera_fechas = 4 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer1_1
					FROM fechas_cortes 
					WHERE  fecha < dFechaPer1;
				ELIF bandera_fechas = 5 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer2
					FROM fechas_cortes 
					WHERE  fecha < dFechaPer1_1;
				ELIF bandera_fechas = 6 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer2_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer2;		
				ELIF bandera_fechas = 7 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer3
					FROM fechas_cortes 
					WHERE fecha < dFechaPer2_1;	
				ELIF bandera_fechas = 8 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer3_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer3;	
				ELIF bandera_fechas = 9 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer4
					FROM fechas_cortes 
					WHERE fecha < dFechaPer3_1;
				ELIF bandera_fechas = 10 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer4_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer4 ;	
				ELIF bandera_fechas = 11 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer5
					FROM fechas_cortes 
					WHERE fecha < dFechaPer4_1;	
				ELIF bandera_fechas = 12 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer5_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer5;
				ELIF bandera_fechas = 13 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer6
					FROM fechas_cortes 
					WHERE fecha < dFechaPer5_1;
				ELIF bandera_fechas = 14 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer6_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer6;		
				ELIF bandera_fechas = 15 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer7
					FROM fechas_cortes 
					WHERE fecha < dFechaPer6_1;	
				ELIF bandera_fechas = 16 THEN
					SELECT NVL(MAX(fecha),date(1)) INTO dFechaPer7_1
					FROM fechas_cortes 
					WHERE fecha < dFechaPer7;						
				END IF;
			LET bandera_fechas = (bandera_fechas+1);		
				
			END LOOP
			DROP TABLE fechas_cortes;
		END IF;
		
		LET v_fecha_corte = dFechaPer0;
		
--Exclusion para cuentas con informacion incompleta (A reportar con Operaciones)
		IF v_fecha_corte = date(1) THEN			
			IF v_dia_corte = 31 OR (month(pPeriodo)= 2 AND v_dia_corte in(31,30,29))THEN			
				LET v_fecha_corte = pPeriodo;
			ELSE
				LET v_fecha_corte = mdy(month(pPeriodo),(v_dia_corte),year(pPeriodo));
			END IF;			
		END IF;	
--Exclusion para cuentas con informacion incompleta (A reportar con Operaciones)
		IF v_fecha_corte < v_fecha_apertura THEN		
		  SELECT min(fecha_cuota) 
		  INTO v_fecha_corte
		  FROM sd_amortiza_credito
		   WHERE num_credito =v_num_credito;			
		END IF;
		
		IF v_fecha_vencimiento < pPeriodo THEN
			LET v_fecha_vencimiento = mdy(month(v_fecha_vencimiento ),day(v_fecha_vencimiento ),year(pPeriodo));
		END IF;
		
		IF v_fecha_vencimiento < pPeriodo THEN
			LET v_fecha_vencimiento =v_fecha_vencimiento + 1 units year;
		END IF;
		
		--LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));
		LET v_plazo_remanente = round((v_fecha_vencimiento -pPeriodo)/ 365.25,5);
		IF v_plazo_remanente <= 0 THEN
			LET v_plazo_remanente =0;
		END IF;
		
		
		LET v_fecha_venc_format= TO_CHAR(v_fecha_vencimiento, '%Y/%m/%d');
		
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
        
        LET v_capital_vigente    			=0;
        LET v_capital_vencido    			=0;

        LET v_capital_vigente1    			=0;
        LET v_capital_vencido1    			=0;

        LET v_capital_vigente2    			=0;
        LET v_capital_vencido2    			=0;


        LET v_capital_vigente3    			=0;
        LET v_capital_vencido3    			=0;

        LET v_capital_vigente4    			=0;
        LET v_capital_vencido4    			=0;

        LET v_capital_vigente5   			=0;
        LET v_capital_vencido5    			=0;

        LET v_capital_vigente6    			=0;
        LET v_capital_vencido6    			=0;
		
		LET var_mto_fin_ven_trasp			=0;
		LET var_mto_fin_ven_trasp2			=0;

--CAMPO 20 fecha_apertura_cte
/*
		SELECT min(mdy(month(fecha_apertura),day(fecha_apertura),year(fecha_apertura))) INTO v_fecha_apertura_cte 
		FROM (SELECT min(fecha_apertura)fecha_apertura
			  FROM sd_maecred WHERE numcte=v_num_cliente   --Tarjetas
		union all
		SELECT min(fecha_apertura)fecha_apertura		
		FROM sd_maecredcrd WHERE numcte=v_num_cliente AND num_producto <> '6800'  --Prestamos y nomina
		union all
		SELECT min(fecha_otorga) fecha_apertura
		FROM sd_linea_prestamo WHERE num_credito in (SELECT num_credito FROM sd_maecredcrd
													WHERE numcte = v_num_cliente AND num_producto = '6800'));  --Flexibles			
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
--CAMPO 2 antecedentes de buro
		--Validar cuando son buenos y malos	
		/*IF c_evalua_cc = '0' THEN
			LET v_antecedentes_buro = 'Buen';
		ELIF c_evalua_cc = 'X' OR  c_evalua_cc is null THEN	
			LET v_antecedentes_buro = '';
		ELSE  --ELIF c_evalua_cc >= '1' THEN
			LET v_antecedentes_buro = 'Mal';	
		END IF;	 */ 

		
--CAMPO 3 antiguedad_cliente   
		LET v_antiguedad_cliente = (year(pPeriodo) - year(v_fecha_apertura_cte)) * 12 + (month(pPeriodo) - month(v_fecha_apertura_cte));

--CAMPOS 4, 5, 6 y 7  ATR's
		LET v_meses_d 	                 	= 0;
		LET v_meses_i 	                 	= 0;
		LET pPeriodo_ant1 = piniPeriodo - 1 units day;
		LET pPeriodo_ant2 = mdy(month(pPeriodo_ant1),1,year(pPeriodo_ant1)) - 1 units day;
		LET pPeriodo_ant3 = mdy(month(pPeriodo_ant2),1,year(pPeriodo_ant2)) - 1 units day;
		
		SELECT status_cred INTO v_status_fin_mes1
		  FROM bdicred:sd_maecredcont
		 WHERE num_credito = v_num_credito
		   AND fecha=pPeriodo_ant1;
		   
		SELECT status_cred INTO v_status_fin_mes2
		  FROM bdicred:sd_maecredcont
		 WHERE num_credito = v_num_credito
		   AND fecha=pPeriodo_ant2;
		   
		SELECT status_cred INTO v_status_fin_mes3
		  FROM bdicred:sd_maecredcont
		 WHERE num_credito = v_num_credito
		   AND fecha=pPeriodo_ant3;
		
/*		
		--ATR   
		IF v_status_fin_mes= 'BA' or v_status_fin_mes= 'BT' or (v_status_fin_mes='E1' and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes='E2' and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes='E3' and (v_dias_atraso>=90)) THEN
			LET v_atr = 1;
		ELSE
			LET v_atr = 0;
		END IF;
		--ATR1
		IF v_status_fin_mes1= 'BA' or v_status_fin_mes1= 'BT' or (v_status_fin_mes1='E1' and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes1='E2' and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes1='E3' and (v_dias_atraso>=90)) THEN
			LET v_atr1 = 1;
		ELSE
			LET v_atr1 = 0;
		END IF;
		--ATR2
		IF v_status_fin_mes2= 'BA' or v_status_fin_mes2= 'BT' or (v_status_fin_mes2='E1' and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes2='E2' and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes2='E3' and (v_dias_atraso>=90)) THEN
			LET v_atr2 = 1;
		ELSE
			LET v_atr2 = 0;
		END IF;
		--ATR3
		IF v_status_fin_mes3= 'BA' or v_status_fin_mes3= 'BT' or (v_status_fin_mes3='E1' and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes3='E2' and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes3='E3' and (v_dias_atraso>=90)) THEN
			LET v_atr3 = 1;
		ELSE
			LET v_atr3 = 0;
		END IF;*/
	
		SELECT act INTO v_atr
		FROM sd_maesdoscont
		WHERE num_credito = v_num_credito AND fecha=pPeriodo;
		
		SELECT act INTO v_atr1
		FROM sd_maesdoscont
		WHERE num_credito = v_num_credito AND fecha=pPeriodo_ant1;
		
		SELECT act INTO v_atr2
		FROM sd_maesdoscont
		WHERE num_credito = v_num_credito AND fecha=pPeriodo_ant2;
		
		SELECT act INTO v_atr3
		FROM sd_maesdoscont
		WHERE num_credito = v_num_credito AND fecha=pPeriodo_ant3;
		
		/*IF v_dias_atraso = 0 THEN
			LET v_atr = 0;
		ELSE
			LET v_meses_d = v_dias_atraso/30.4;
			LET v_meses_i = v_dias_atraso/30.4;
		
			/*IF v_meses_d = v_meses_i THEN
				LET v_atr = v_meses_i;
			ELSE
				----LET v_atr = v_meses_i +1;
				LET v_atr = v_meses_i;
			END IF;*/
			
		/*	IF v_facturacion='Q' THEN
				LET v_atr = v_meses_d; 
			ELSE
				LET v_atr = v_meses_i;
			END IF;
		END IF;	*/
	--ATR1
	/*	LET v_meses_d 	                 	= 0;
		LET v_meses_i 	                 	= 0;	
	    LET pPeriodo_ant1 = piniPeriodo - 1 units day;
	   
	  select dias_atraso INTO v_dias_atraso_1
		from bdicred:sd_indicador_cred_hist 
		where empresa = '001'
		and fecha = pPeriodo_ant1
		and num_credito = v_num_credito;
		
		IF  v_dias_atraso_1 is null THEN
			LET v_dias_atraso_1 = v_dias_atraso -30.4;
		END IF;
		
		IF v_dias_atraso_1 <= 0 THEN
			LET v_atr1 = 0;
		ELSE
			LET v_meses_d = v_dias_atraso_1/30.4;
			LET v_meses_i = v_dias_atraso_1/30.4;
			
			IF v_facturacion='Q' THEN
				LET v_atr1 = v_meses_d; 
			ELSE
				LET v_atr1 = v_meses_i;
			END IF;
		END IF;	
		
	--ATR2	
		LET v_meses_d 	                 	= 0;
		LET v_meses_i 	                 	= 0;	
	    LET pPeriodo_ant2 = mdy(month(pPeriodo_ant1),1,year(pPeriodo_ant1)) - 1 units day;
	  
	  select dias_atraso INTO v_dias_atraso_2
		from bdicred:sd_indicador_cred_hist 
		where empresa = '001'
		and  fecha = pPeriodo_ant2
		and num_credito = v_num_credito;
		
		IF  v_dias_atraso_2 is null THEN		
			LET v_dias_atraso_2 = v_dias_atraso_1 - 30.4;	
		END IF;
		
		IF v_dias_atraso_2 <= 0 THEN
			LET v_atr2 = 0;
		ELSE
			LET v_meses_d = v_dias_atraso_2/30.4;
			LET v_meses_i = v_dias_atraso_2/30.4;

			IF v_facturacion='Q' THEN
				LET v_atr2 = v_meses_d; 
			ELSE
				LET v_atr2 = v_meses_i;
			END IF;		
		END IF;
	--ATR3
		LET v_meses_d 	                 	= 0;
		LET v_meses_i 	                 	= 0;	
	    LET pPeriodo_ant3 = mdy(month(pPeriodo_ant2),1,year(pPeriodo_ant2)) - 1 units day;
	  
	  select dias_atraso INTO v_dias_atraso_3
		from bdicred:sd_indicador_cred_hist 
		where empresa = '001'
		and fecha = pPeriodo_ant3
		and num_credito = v_num_credito;
		
		IF  v_dias_atraso_3 is null THEN	
			LET v_dias_atraso_3 = v_dias_atraso_2 - 30.4;	
		END IF;
		
		IF v_dias_atraso_3 <= 0 THEN
			LET v_atr3 = 0;
		ELSE
			LET v_meses_d = v_dias_atraso_3/30.4;
			LET v_meses_i = v_dias_atraso_3/30.4;

			IF v_facturacion='Q' THEN
				LET v_atr3 = v_meses_d; 
			ELSE
				LET v_atr3 = v_meses_i;
			END IF;	
		END IF;	*/
	--Este bloque de dividir ya no es necesario, al dividir entre 30.4 los quincenales da el mismo efecto que dividirlo entre 15.2 y luego dividirlo por 2 
	--Si  facturacion Quincenal se dividen a la mitad
		IF v_facturacion='Q' THEN  --IPCB se divide a la mitad ya que actualmente son recibos no pagados. Conforme a solicitud Riesgos @22 enero2019
			
			-- maesdoscont
			SELECT nvl(act,0) / 2, (nvl(act,0) / 2) - 0.5 INTO v_atr, v_atr1
			FROM sd_maesdoscont
			WHERE num_credito = v_num_credito AND fecha=pPeriodo;
			
			SELECT nvl(act,0) / 2, (nvl(act,0) / 2) - 0.5 INTO v_atr2, v_atr3
			FROM sd_maesdoscont
			WHERE num_credito = v_num_credito AND fecha=pPeriodo_ant1;
			
			
			IF v_atr is null or v_atr < 0 THEN
				LET v_atr = 0;
			END IF;
			IF v_atr1 is null or v_atr1 < 0 THEN
				LET v_atr1 = 0;
			END IF;
			IF v_atr2 is null or v_atr2 < 0 THEN
				LET v_atr2 = 0;
			END IF;
			IF v_atr3 is null or v_atr3 < 0 THEN
				LET v_atr3 = 0;
			END IF;
			
		END IF;	
--CAMPO 9 CAPITAL EXIGIBLE
		SELECT sdo_cap_insoluto INTO v_capital_exigible
		FROM bdicred:sd_maesdoshist 
		WHERE  fecha =v_fecha_corte               
		AND num_credito = v_num_credito;		
		
		IF v_capital_exigible < 0 THEN
			LET v_capital_exigible = 0;
		END IF;
--CAMPO 10 COMISIONES
		SELECT nvl(sum(monto),0) INTO	v_comisiones
		FROM movs_comis
		WHERE num_credito = v_num_credito;	
--CAMPO 23 Ingresos Mensuales Brutos
--Conforme a reunion con Riesgos 17/mayo/19 se igualan los ingresos mensuales brutos a los netos.
		LET v_ingresos_mens_brutos = v_ingresos_mens_netos;	

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
--CAMPO 40 Antiguedad
		--LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));--IPCB se cambia la forma de calcular la antiguedad del credito
		LET v_antiguedad = (year(pPeriodo) - year(v_fecha_apertura)) * 12 + (month(pPeriodo) - month(v_fecha_apertura));

		
--CAMPO 41 MONTO EXIGIBLE				
		SELECT sdo_cap_insoluto INTO v_monto_exigible
		FROM bdicred:sd_maesdoshist 
		WHERE  fecha =dFechaPer0_1               
		AND num_credito = v_num_credito;	
		
		IF v_monto_exigible < 0 THEN
			LET v_monto_exigible = 0;
		END IF;	
--CAMPO 42 MONTO EXIGIBLE1
		SELECT sdo_cap_insoluto INTO v_monto_exigible1
		FROM bdicred:sd_maesdoshist 
		WHERE  fecha =dFechaPer1_1               
		AND num_credito = v_num_credito;
		
		IF v_monto_exigible1 < 0 THEN
			LET v_monto_exigible1 = 0;
		END IF;	
--CAMPO 43 MONTO EXIGIBLE2
		SELECT sdo_cap_insoluto INTO v_monto_exigible2
		FROM bdicred:sd_maesdoshist 
		WHERE  fecha =dFechaPer2_1               
		AND num_credito = v_num_credito;

		IF v_monto_exigible2 < 0 THEN
			LET v_monto_exigible2 = 0;
		END IF;	
--CAMPO 44 MONTO EXIGIBLE3	
		SELECT sdo_cap_insoluto INTO v_monto_exigible3
		FROM bdicred:sd_maesdoshist 
		WHERE  fecha =dFechaPer3_1               
		AND num_credito = v_num_credito;

		IF v_monto_exigible3 < 0 THEN
			LET v_monto_exigible3 = 0;
		END IF;			
--CAMPO 45 al 47 MONTO EXIGIBLE4 a 	MONTO EXIGIBLE6	
		IF v_facturacion = 'M' THEN
			LET v_monto_exigible4 = 0;
			LET v_monto_exigible5 = 0;
			LET v_monto_exigible6 = 0;
		ELSE
	--CAMPO 45 MONTO EXIGIBLE4 	
			SELECT sdo_cap_insoluto INTO v_monto_exigible4
			FROM bdicred:sd_maesdoshist 
			WHERE  fecha =dFechaPer4_1               
			AND num_credito = v_num_credito;
			
			IF v_monto_exigible4 < 0 THEN
				LET v_monto_exigible4 = 0;
			END IF;	
	--CAMPO 46 MONTO EXIGIBLE5 		
			SELECT sdo_cap_insoluto INTO v_monto_exigible5
			FROM bdicred:sd_maesdoshist 
			WHERE  fecha =dFechaPer5_1               
			AND num_credito = v_num_credito;	

			IF v_monto_exigible5 < 0 THEN
				LET v_monto_exigible5 = 0;
			END IF;					
	--CAMPO 47 MONTO EXIGIBLE6 	
			SELECT sdo_cap_insoluto INTO v_monto_exigible6
			FROM bdicred:sd_maesdoshist 
			WHERE  fecha =dFechaPer6_1               
			AND num_credito = v_num_credito;

			IF v_monto_exigible6 < 0 THEN
				LET v_monto_exigible6 = 0;
			END IF;		
		END IF;
	
--CAMPO 54 NUM_DISPOSICIONES
		LET vdisp_per = 0;
		LET v_num_disposiciones = 0;
		IF v_fecha_apertura < piniPeriodo THEN
			select num_disposiciones INTO v_num_disposiciones
			from sd_insumos_calif_pp
			--from sd_insumos_calif_pp_old2021
			where fecha_cierre = pPeriodo_ant1
			and num_credito = v_num_credito;	

			IF 	v_num_disposiciones is null THEN
				LET v_num_disposiciones = 0;
			END IF;	
		END IF;
		
		select count(*) INTO vdisp_per
		from bdicred:sd_movhis
		where empresa = '001'
		and fecha_mov >=piniPeriodo and fecha_mov <= pPeriodo
		and num_credito = v_num_credito
		and codigo_fun in ( '002')
		and codigo_ref in (111)
		and reversado = 'N';
		
		IF 	vdisp_per is null THEN
				LET vdisp_per = 0;
		END IF;	
		
		
		LET v_num_disposiciones = v_num_disposiciones + vdisp_per;
	
--CAMPO 56 Y 63 PAGO_CAPITAL Y PAGO REALIZADO
		LET v_fecha = dFechaPer1 + 1 units day;	
		
		SELECT NVL(SUM(monto),0) INTO v_pago_capital
		FROM movs_pagos
		WHERE fecha_mov <= dFechaPer0
		and fecha_mov >= v_fecha
			and num_credito = v_num_credito;
		
		LET v_pago_realizado = v_pago_capital;
		
-- CAMPO 64 PAGO_REALIZADO1
		LET v_fecha = dFechaPer2 + 1 units day;	
		
		SELECT SUM(monto) INTO v_pago_realizado1
		FROM movs_pagos
		WHERE fecha_mov <= dFechaPer1
		and fecha_mov >= v_fecha
			and num_credito = v_num_credito;		
-- CAMPO 65 PAGO_REALIZADO2
		LET v_fecha = dFechaPer3 + 1 units day;	
		
		SELECT SUM(monto) INTO v_pago_realizado2
		FROM movs_pagos
		WHERE fecha_mov <= dFechaPer2
		and fecha_mov >= v_fecha
		and num_credito = v_num_credito;				
-- CAMPO 66 PAGO_REALIZADO3
		LET v_fecha = dFechaPer4 + 1 units day;	
		
		SELECT SUM(monto) INTO v_pago_realizado3
		FROM movs_pagos
		WHERE fecha_mov <= dFechaPer3
		and fecha_mov >= v_fecha
		and num_credito = v_num_credito;	
--CAMPO 67 A 69 PAGO_REALIZADO4	 A  PAGO_REALIZADO6
		IF v_facturacion = 'M' THEN
			LET v_pago_realizado4 = 0;
			LET v_pago_realizado5 = 0;
			LET v_pago_realizado6 = 0;
		ELSE		
-- CAMPO 67 PAGO_REALIZADO4
			LET v_fecha = dFechaPer5 + 1 units day;	
			
			SELECT SUM(monto) INTO v_pago_realizado4
			FROM movs_pagos
			WHERE fecha_mov <= dFechaPer4
			and fecha_mov >= v_fecha
			and num_credito = v_num_credito;
-- CAMPO 68 PAGO_REALIZADO5
			LET v_fecha = dFechaPer6 + 1 units day;	
			
			SELECT SUM(monto) INTO v_pago_realizado5
			FROM movs_pagos
			WHERE fecha_mov <= dFechaPer5
			and fecha_mov >= v_fecha
			and num_credito = v_num_credito;		
-- CAMPO 69 PAGO_REALIZADO6
			LET v_fecha = dFechaPer7+ 1 units day;	
			
			SELECT SUM(monto) INTO v_pago_realizado6
			FROM movs_pagos
			WHERE fecha_mov <= dFechaPer6
			and fecha_mov >= v_fecha
			and num_credito = v_num_credito;				
		END IF;
/*
--CAMPO 70 PERIODOS_INCUMPLIMIENTO		
SELECT count(*) INTO v_incumplimiento
  FROM bdicred:sd_maecredcont
 WHERE num_Credito = v_num_credito
   AND status_cred IN ('BA','BT');

SELECT count(*) INTO v_incumplimiento_old
  FROM bdicred:sd_maecredcont_OLD
 WHERE num_Credito = v_num_credito
   AND status_cred IN ('BA','BT');

	LET v_periodos_incumplimiento = v_incumplimiento + v_incumplimiento_old;
	*/
	--CAMPO 74 PORCENTAJE_PAGO
			IF v_fecha_apertura >= piniPeriodo and v_fecha_apertura <= pPeriodo  and NVL(v_monto_exigible,0) = 0 THEN
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

					LET bandera_exigible = 1;	
					LET v_prom_tot = 0;
					LET var_div   = 0;
					LET v_porcentaje_pago = 0;
					
					WHILE (bandera_exigible <= 4) LOOP
					
						IF bandera_exigible = 1 THEN
							IF NVL(v_monto_exigible,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom1;
								LET var_div = var_div+1;
							END IF;
						ELIF bandera_exigible = 2 THEN
							IF NVL(v_monto_exigible1,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom2;
								LET var_div = var_div+1;
							END IF;												
						ELIF bandera_exigible = 3 THEN
							IF NVL(v_monto_exigible2,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom3;
								LET var_div = var_div+1;
							END IF;	
						ELIF bandera_exigible = 4 THEN
							IF NVL(v_monto_exigible3,0) > 0  THEN
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
							IF NVL(v_monto_exigible,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom1;
								LET var_div = var_div+1;
							END IF;
						ELIF bandera_exigible = 2 THEN
							IF NVL(v_monto_exigible1,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom2;
								LET var_div = var_div+1;
							END IF;												
						ELIF bandera_exigible = 3 THEN
							IF NVL(v_monto_exigible2,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom3;
								LET var_div = var_div+1;
							END IF;	
						ELIF bandera_exigible = 4 THEN
							IF NVL(v_monto_exigible3,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom4;
								LET var_div = var_div+1;
							END IF;	

						ELIF bandera_exigible = 5 THEN
							IF NVL(v_monto_exigible4,0) > 0 THEN
								LET v_prom_tot = v_prom_tot +v_prom5;
								LET var_div = var_div+1;
							END IF;	
						ELIF bandera_exigible = 6 THEN
							IF NVL(v_monto_exigible5,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom6;
								LET var_div = var_div+1;
							END IF;	
						ELIF bandera_exigible = 7 THEN
							IF NVL(v_monto_exigible6,0) > 0  THEN
								LET v_prom_tot = v_prom_tot +v_prom7;
								LET var_div = var_div+1;
							END IF;								
						END IF;
						LET bandera_exigible = (bandera_exigible+1);							
					END LOOP;

					IF 	var_div > 0 THEN
						LET v_porcentaje_pago = round(v_prom_tot/var_div,2);
					END IF;					
				END IF;
			END IF;	
			
			IF v_porcentaje_pago=0 THEN
				LET v_porcentaje_pago = 0;
			END IF;
				
-- CAMPO 78 SALDO_CORTE
	--IF day(dFechaPer0) = 31 THEN
		--LET dFechaPer0= mdy(month(dFechaPer0),'30',year(dFechaPer0));
	--END IF;
		
	SELECT sdo_cap_insoluto INTO v_saldo_corte
	FROM bdicred:sd_maesdoshist 
	WHERE  fecha =dFechaPer0               
	AND num_credito = v_num_credito;
	
	IF v_saldo_corte < 0 THEN
		LET v_saldo_corte =0;	
	END IF;

	----BLOQUE VARIABLES DE CIRCULO
	SELECT a.num_credito credito_consulta, 
			var_mtosdo_ship,
			meses_ultimoatr1d_todos,
			monto_pagar_propios_ship,
			monto_pagar_otros_ship,
			sdo_actual_propio_ship,sdo_actual_otros_ship,
			antiguedad_bancos, antiguedad_inst
	  INTO v_cred_consulta, 
			v_var_mtosdo,
			v_bkatr,v_mto_pagar_propios,v_mto_pagar_otros,
			v_sdo_actual_propio_ship,v_sdo_actual_otros_ship,
			v_ant_otro_inst ,v_antiguedad_inst
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
		LET v_mto_otros_vs_propios = 0;
		LET v_mto_pagar_otros =0;
		LET v_mto_pagar_propios = 0;
		LET v_mtovssdo_sic = 0;
		LET v_sdo_sic = 0;				
		LET v_porcentaje_endeuda = 0; 	
		LET v_sdo_actual_propio_ship = 0;
		LET v_ant_otro_inst = 0;	
	ELSE 						 		--Si Se consulto a las SICs
		--CAMPO 82 Sin Consulta
		LET v_sin_consulta = '0';		
		--CAMPO 11 Consulta sin info
		--IF v_var_mtosdo IS NULL THEN --Riesgos indica que si esta variable es nula se marcara sin informacion   
		--En reunion 17 junio indican se deben apegar a layout (si existe en el determina pero monto_pagar_propios_ship y monto_pagar_otros_ship es vacio, entonces es sin informacion)
		--IF 	nvl(v_mto_pagar_propios,0) =0 AND nvl(v_mto_pagar_otros,0) =0 THEN
		IF 	v_mto_pagar_propios is null AND v_mto_pagar_otros is null THEN
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
		
		--CAMPO 39 meses BKATR
		IF v_bkatr IS NULL THEN
			LET v_bkatr = 13;
		ELSE
			LET v_bkatr = v_bkatr;
		END IF;					
		--CAMPO 49 monto pagar otros, 50 monto pagar_propios, 48 monto otros vs propios,  51 mto vs sdo sic, 73 porcentaje endeudamiento
		LET v_mto_pagar_otros =NVL(v_mto_pagar_otros,0);
		LET v_mto_pagar_propios =NVL(v_mto_pagar_propios,0);
		
		IF  v_mto_pagar_propios = 0 THEN 
			LET v_mto_otros_vs_propios = 0;
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
			LET v_porcentaje_endeuda = round((v_mto_pagar_otros + v_mto_pagar_propios)/ v_ingresos_mens_brutos,6);
		END IF;	

		--CAMPO 85 Ant_Otr_Inst
		IF v_ant_otro_inst IS NULL THEN
			LET v_ant_otro_inst = 0;
		ELSE
			LET v_ant_otro_inst = v_ant_otro_inst;
		END IF;	
		
		--CAMPO 86 SaldoActual_Propio_Ship
		LET v_sdo_actual_propio_ship =NVL(v_sdo_actual_propio_ship,0);

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
        END IF
	END IF;	

    LET v_fecha_corte_format = TO_CHAR(v_fecha_corte, '%Y/%m/%d');
    

    --LET v_capital_cierre= v_capital_vigente + v_capital_vencido;
    IF day(pPeriodo)='31' THEN 
        SELECT meses_vencidos31, (capvig31 + captrans31 + capvencnoexig31 + capvenexig31)
        INTO  v_num_pagos_vencidos, v_capital_cierre
        FROM sd_sdodiario 
        WHERE num_credito=v_num_credito and fecha = piniPeriodo;
    END IF;

    IF day(pPeriodo)='30' THEN 
        SELECT  meses_vencidos30, (capvig30 + captrans30 + capvencnoexig30 + capvenexig30) 
        INTO  v_num_pagos_vencidos, v_capital_cierre
        FROM sd_sdodiario 
        WHERE num_credito=v_num_credito and fecha = piniPeriodo;
    END IF;

    IF day(pPeriodo)='29' THEN 
        SELECT  meses_vencidos29, (capvig29 + captrans29 + capvencnoexig29 + capvenexig29)
        INTO  v_num_pagos_vencidos, v_capital_cierre  
        FROM sd_sdodiario 
        WHERE num_credito=v_num_credito and fecha = piniPeriodo;
    END IF;

    IF day(pPeriodo)='28' THEN 
        SELECT meses_vencidos28, (capvig28 + captrans28 + capvencnoexig28 + capvenexig28) 
        INTO  v_num_pagos_vencidos, v_capital_cierre 
        FROM sd_sdodiario
        WHERE num_credito=v_num_credito and fecha = piniPeriodo;
    END IF;
    
    /*SELECT count(*) INTO v_num_pagos_vencidos  
					FROM bdicred:sd_amortiza_creditocrd 
					WHERE num_Credito = v_num_credito 
					      AND capital_status in (2,7)
					     AND fecha_cuota >= piniperiodo and fecha_cuota <= pPeriodo;*/
					     
	/*IF v_atr > 3 THEN
        LET v_etapa_cred='3';
    ELIF v_atr > 1 AND v_atr <= 3  THEN
        LET v_etapa_cred='2';
    ELIF v_atr <= 1 THEN
        LET v_etapa_cred='1';
    END IF;*/
	
	IF  v_atr >= 1 and v_dias_atraso > 30 THEN
        LET v_etapa_cred='3';
		LET v_intereses_etapa3 = 0;		LET v_intereses_etapa1 = 0;
		LET v_intereses_etapa2 = 0;
    ELSE
        LET v_etapa_cred='1';
		LET v_intereses_etapa1 = 0;
		LET v_intereses_etapa2 = 0;
		LET v_intereses_etapa3 = 0;
    END IF;
	
    
    select nvl(monto,0) Into v_gastos_originacion 
	from sd_tpcomis 
    where cod_comis = '8170'; 
			
	execute procedure "informix".sp_tasaefectiva(v_linea_autorizada, v_gastos_originacion, v_tasa_contractual, v_plazo_total, v_facturacion)
				INTO v_tir_mensual, v_tasa_efectiva;
				
				
	IF v_tasa_contractual=0 THEN 
        LET v_tasa_contractual=0.0000001;  --AGREGAR 00
	ELSE
		LET v_tasa_contractual= v_tasa_contractual/100;	
    END IF;
	
	IF nvl(v_tasa_efectiva,0)=0 THEN 
        LET v_tasa_efectiva=0.00001;  
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
	        
    --SELECT num_cta INTO v_num_ctanom 
    --FROM SD_CTASCARG WHERE num_credito=v_num_credito;
	
	SELECT cuenta_nomina INTO v_num_ctanom 
    FROM bdisolic:ss_adn_solicitudcuenta WHERE num_solicitud=v_num_credito;
    
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
            
	LET n_scoreburo='';  --pendiente definir missing
	
	IF NVL(v_grupo_originacion,'')='' THEN
		EXECUTE PROCEDURE bdisolic:"informix".sp_obtienegrupo_cons(v_num_credito)
		INTO v_codret,v_tipogrupo,v_hit;
		
		LET v_grupo_originacion=v_tipogrupo;
	END IF;
	
	--LET v_num_pagos_vencidos= v_atr;
	
		IF v_dias_atraso = 0 THEN
			LET v_num_pagos_vencidos = 0;
		ELSE
			LET v_meses_d = v_dias_atraso/30.4;
			LET v_meses_i = v_dias_atraso/30.4;
		
			IF v_meses_d = v_meses_i THEN
				LET v_num_pagos_vencidos = v_meses_i;
			ELSE
				----LET v_atr = v_meses_i +1;
				LET v_num_pagos_vencidos = v_meses_i;
			END IF;
			
			IF v_facturacion='Q' THEN
				LET v_num_pagos_vencidos = v_meses_d; 
			ELSE
				LET v_num_pagos_vencidos = v_meses_i;
			END IF;
		END IF;
	
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
					IF nvl(v_monto_exigible4,0) = 0 THEN
						LET v_prom5 = "";
					END IF
					IF nvl(v_monto_exigible5,0) = 0 THEN
						LET v_prom6 = "";
					END IF
					IF nvl(v_monto_exigible6,0) = 0 THEN
						LET v_prom7 = "";
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
										   monto_otros_vs_propios, monto_pagar_otros,monto_pagar_propios,mto_vs_sdo_sic, --nvos												   
										   num_cliente,num_credito,num_disposiciones,num_producto,pago_capital,pago_int_venc_bal,pago_int_venc_ord,
										   pago_interes_vigente,pago_iva_int_venc_bal,pago_iva_int_venc_ord,pago_iva_interes_vigente,
										   pago_realizado,pago_realizado1,pago_realizado2,pago_realizado3,pago_realizado4,pago_realizado5,
										   pago_realizado6, periodos_incumplimiento,plazo_remanente,plazo_total,		   
										   porcentaje_endeudamiento, --nvo
										   porcentaje_pago,porcentaje_uso,ree_tdc_anterior,saldo_cierre,saldo_corte,saldo_exigible,saldo_no_exigible,
										   saldo_sic,sin_consulta,--nvo
										   status_fin_mes,
										   cum_pag_sost, ant_otr_inst,saldoactual_propio_ship,comision_cobranza, comisionexig_cobranza,  numero_cuenta_det,
                                           antiguedad_inst, meses_ult_atr1d_todos, var_mtosdo, sucursal, cred_exnomina, etapa_cred, intereses_etapa3, tasa_contractual, capital_cierre, 
                                           num_pagos_vencidos, gastos_originacion,score_originacion,score_buro,modelo_score,periodo_rem_n, tasa_efectiva,fecha_ult_pago,intereses_etapa1,
										   intereses_etapa2,
										   nombre_cte,rfc, --nvo
										   Pct_Pgo0,Pct_pago1,Pct_pago2,Pct_pago3,Pct_pago4,Pct_pago5,Pct_pago6,Dias_Rem_Contractual)--nuevos sep
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
										   v_mto_otros_vs_propios,v_mto_pagar_otros, v_mto_pagar_propios,v_mtovssdo_sic, --nvos
										   v_num_cliente,v_num_credito,v_num_disposiciones,v_num_producto,v_pago_capital,v_pago_int_venc_bal,v_pago_int_venc_ord,
										   v_pago_interes_vigente,v_pago_iva_int_venc_bal,v_pago_iva_int_venc_ord,v_pago_iva_interes_vigente,
										   nvl(v_pago_realizado,0),nvl(v_pago_realizado1,0),nvl(v_pago_realizado2,0),nvl(v_pago_realizado3,0),nvl(v_pago_realizado4,0),nvl(v_pago_realizado5,0),
										   nvl(v_pago_realizado6,0),v_periodos_incumplimiento,v_plazo_remanente,v_plazo_total,
										   v_porcentaje_endeuda,
										   v_porcentaje_pago,v_porcentaje_uso,v_ree_tdc_anterior,nvl(v_saldo_cierre,0),nvl(v_saldo_corte,0),nvl(v_saldo_exigible,0),nvl(v_saldo_no_exigible,0),
										   v_sdo_sic,v_sin_consulta,
										   v_status_fin_mes,
										   v_cum_pago_sost,v_ant_otro_inst,v_sdo_actual_propio_ship,NVL(d_comision_cobranza,0), NVL(d_comisionexig_cobranza, 0), v_numero_cuenta_det,
                                           v_antiguedad_inst,v_veces_ult_atr1d_todos,v_var_mtosdo,v_sucursal,v_cred_exnomina, v_etapa_cred, nvl(v_intereses_etapa3,0),v_tasa_contractual, v_capital_cierre,
                                           v_num_pagos_vencidos,v_gastos_originacion,n_scoreotor,n_scoreburo,v_modelo_score,v_periodo_rem_n,v_tasa_efectiva, v_fecha_ult_pago, nvl(v_intereses_etapa1,0),
											nvl(v_intereses_etapa2,0),
											c_nom_cte,v_rfc, --nvo
											v_prom1,v_prom2,v_prom3,v_prom4,v_prom5,v_prom6,v_prom7,v_dias_rem_contractual);											
											
	LET contador_commit = contador_commit  + 1;
			
			IF (contador_commit >= 500) THEN
		--	IF (contador_commit <= 500) THEN
				COMMIT WORK;
				LET contador_commit = 0; 
				BEGIN WORK;
			END IF;
	END FOREACH
	
  IF val_trans_Commit = -1 THEN
     COMMIT WORK;
  END IF;
  LET val_trans_Commit = 0;		
  
		SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
	
    LET cCodRet     = "00000";
    LET cMensajeRet = "REPORTE DE ANTICIPO NOMINA OK" ;
	LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;	
	
	RETURN cCodRet, cMensajeRet, cMensajeRet2;
END
END PROCEDURE

;
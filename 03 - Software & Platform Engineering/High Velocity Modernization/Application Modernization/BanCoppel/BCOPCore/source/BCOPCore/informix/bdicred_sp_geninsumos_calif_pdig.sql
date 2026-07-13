CREATE PROCEDURE "informix".sp_geninsumos_calif_pdig(pEjecucion smallint)
RETURNING   CHAR(5), CHAR(100), char(60);

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
DEFINE v_fecha_apertura_cte            	DATE;
DEFINE v_fecha_corte                   	DATE;
DEFINE v_fecha_vencimiento             	DATE;
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
DEFINE v_max_secuencia                  SMALLINT;
DEFINE v_num_cta                        CHAR(20);  

DEFINE v_dia_corte			SMALLINT; 
DEFINE v_dia_corte_flex		SMALLINT;								  
DEFINE v_antimaecred			INTEGER;
DEFINE v_antimaecredcrd			INTEGER;
DEFINE v_antimaecredcrd_flex 	INTEGER;
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
DEFINE v_ingresos_mens_netos_1         	DECIMAL(18,2);
DEFINE v_ingresos_mens_netos_2         	DECIMAL(18,2);
DEFINE dt_ap_revolvente DATE;	DEFINE dt_ap_plazo     DATE;  DEFINE dt_ap_flex DATE;	
--Variables Ad Flexible
DEFINE v_fecha_primera_disp DATE;
DEFINE v_fecha_ulm_disp     DATE;
DEFINE v_fecha_ven_ulm_disp	DATE;
DEFINE v_represta			INTEGER;
DEFINE vmes1, vfec_ap1, vfec_disp1,vfec_corte1,v_fecha_pago_ini1 DATE;
DEFINE vmes2, vfec_ap2, vfec_disp2,vfec_corte2,v_fecha_pago_ini2 DATE;
DEFINE vmes3, vfec_ap3, vfec_disp3,vfec_corte3,v_fecha_pago_ini3 DATE;
DEFINE v_antig_exig1, v_antig_exig2, v_antig_exig3 INTEGER;

DEFINE bandera_exigible  INTEGER;
DEFINE v_prom_tot DECIMAL(18,10);
DEFINE var_div   INTEGER;

----CJAC CAMPOS ADICIONALES 
DEFINE cred_ini  		CHAR(20);
DEFINE cred_fin         CHAR(20);
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
    DEFINE v_fecha_apertura_format          CHAR(12);
    DEFINE v_fecha_apertura_cte_format     	CHAR(12);
    DEFINE v_fecha_corte_format            	CHAR(12);
    DEFINE v_fecha_venc_format              CHAR(12);
    DEFINE v_cred_sit_especial INTEGER;
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
	DEFINE v_intereses_etapa3 DECIMAL(18,2);
	DEFINE v_intereses_etapa1 DECIMAL(18,2);
	DEFINE v_intereses_etapa2 DECIMAL(18,2);
	DEFINE psaldoInteresApoyo DECIMAL(18,2);
	DEFINE var_fecha_ultimo_pago_h DATE;
    
   -- DEFINE v_plazo_contractual INTEGER;

	DEFINE v_adicional_fecha_otorga INTEGER;
	
	--variable sep
	DEFINE v_dias_rem_contractual DECIMAL(18,2);
	
			--leer archivo
	DEFINE sqlArchivoLeer CHAR(20000);
	DEFINE contador INTEGER;
	DEFINE mes CHAR(2);
	DEFINE anio CHAR(4);
	DEFINE comandoNombre CHAR(500);
	DEFINE pRutaArchivo char(500);
	DEFINE pNombreArchivo  CHAR(300);
	
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
LET v_eficiencia                    = 0;
LET v_facturacion                   = "";
LET v_fecha_apertura                = DATE(1);
LET v_fecha_apertura_cte            = DATE(1);
LET v_fecha_corte                   = DATE(1);
LET v_fecha_vencimiento             = DATE(1);
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
LET v_periodos_incumplimiento    	= 0;
LET v_plazo_remanente            	= 0;
LET v_plazo_total                  	= 0;
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
LET v_antimaecredcrd_flex			= 0;										
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
LET v_ingresos_mens_netos_1         = 0;    LET v_ingresos_mens_netos_2         = 0;
--Variables Ad Flexible
LET v_fecha_primera_disp  = date(1);
LET v_fecha_ulm_disp      = date(1);
LET v_fecha_ven_ulm_disp  = date(1);
LET v_represta			  = 0;	
LET vmes1 = date(1); LET vfec_ap1 = date(1); LET vfec_disp1 = date(1); LET vfec_corte1 = date(1); LET v_fecha_pago_ini1 = date(1); 
LET vmes2 = date(1); LET vfec_ap2 = date(1); LET vfec_disp2 = date(1); LET vfec_corte2 = date(1); LET v_fecha_pago_ini2 = date(1); 
LET vmes3 = date(1); LET vfec_ap3 = date(1); LET vfec_disp3 = date(1); LET vfec_corte3 = date(1); LET v_fecha_pago_ini3 = date(1); 
LET v_antig_exig1 = 0; LET v_antig_exig2 = 0; LET v_antig_exig3 = 0;
															 
LET contador_commit = 	0;	LET val_trans_Commit = 	0;
LET val_t1 = 	0; LET  val_t2  = 	0; LET val_t3 = 	0;
LET dt_ap_revolvente 		= date(1);	LET dt_ap_plazo 			= date(1); 		LET dt_ap_flex = date(1);

LET bandera_exigible = 0 ;
LET v_prom_tot = 0;
LET var_div   = 0;

--INICIALIZACION DE CAMPOS ADICIONALES
LET cred_ini = '';      
LET cred_fin = '';
    --LET d_comision_cobranza = 0;
    --LET d_comisionexig_cobranza = 0;
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
    LET v_fecha_apertura_format         ='';
    LET v_fecha_apertura_cte_format     ='';
    LET v_fecha_corte_format            ='';
    LET v_fecha_venc_format             ='';
    LET v_cred_sit_especial = 0;
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
	LET v_intereses_etapa3 =0;
	LET v_intereses_etapa1 = 0;
	LET v_intereses_etapa2 = 0;
	LET psaldoInteresApoyo=0;
	LET var_fecha_ultimo_pago_h = DATE(1);

	--nuevo sep
	LET v_dias_rem_contractual = 0;
--Variable para parametro que se suma a la fecha otorga
	LET v_adicional_fecha_otorga = 0;
	
	LET pRutaArchivo = "/resplogifx/archivoscartera/";
	LET pNombreArchivo = '';
	LET sqlArchivoLeer = '';
	LET contador = 0;
	LET mes ='';
	LET anio ='';
	LET comandoNombre = '';
	
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

    --SET DEBUG FILE TO "/RESPALDOSNEW/SI1556/sp_geninsumos_calif_pdig.out";
	--SET DEBUG FILE TO "/resplogifx/archivoscartera/sp_geninsumos_calif_pdig.out";
	--TRACE ON;
		
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
	
SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;
	
	SELECT  pri_dia_mes - 1 units day
	  INTO  pPeriodo
	  FROM sd_fechas
	 WHERE empresa='001';

--LET pPeriodo = mdy(11,30,2023); --para pruebas del mes
LET piniPeriodo = mdy(month(pPeriodo),'01',year(pPeriodo));

--Reproceso 
--LET pPeriodo = mdy('02','28','2019');
--LET piniPeriodo = mdy('02','01','2019');
--Reproceso 

--Valida Anio Bisiesto
IF mod(year(pPeriodo),4) = 0 AND ((mod(year(pPeriodo),100)) <> 0 OR (mod(year(pPeriodo),400) = 0)) THEN
	LET flag_aniobis = 1;
ELSE
	LET flag_aniobis = 0;
END IF;

LET vprod_proc = '6800';						 						   
	
	SELECT MAX(fecha_info) 
	  INTO dt_ultcons_varcc
	  FROM bdiburo:br_variables_cc_cnr;	

	--Determinar rango de creditos a procesar
	SELECT SUBSTR(valor,1,12),SUBSTR(valor,14,25) INTO cred_ini,cred_fin
	  FROM sd_param  WHERE cod_param = (811 + pEjecucion)::CHAR(3);  

	--Obtener el rango que se agrega a la fecha otorga, valor esta en meses --APC
	SELECT valor into v_adicional_fecha_otorga From bdicred:sd_param
	WHERE empresa='001' and cod_param = '067';
--Reproceso 
--LET dt_ultcons_varcc = mdy('12','31','2018');	
--Reproceso 

IF pEjecucion = '1' THEN

	LET mes = month(pPeriodo- 1 units month);
	IF LEN(mes) == 1 THEN
		LET mes = TRIM("0"||mes);
	END IF;
	
	LET anio = Year(pPeriodo);
	LET pNombreArchivo = "Insumos_Calif_PDIG_Lectura_"||TRIM(mes)||TRIM(anio)||".unl";
	
	LET comandoNombre = "/usr/bin/rm -rf "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo);
		SYSTEM TRIM(comandoNombre);
	
	LET pNombreArchivo = "Insumos_Calif_PDIG_Lectura_"||TRIM(mes)||TRIM(anio)||".unl.gz";
	
	LET comandoNombre = "/usr/bin/gzip -dk "||TRIM(pRutaArchivo)||TRIM(pNombreArchivo);
		SYSTEM TRIM(comandoNombre);

	LET pNombreArchivo = "Insumos_Calif_PDIG_Lectura_"||TRIM(mes)||TRIM(anio)||".unl";

		

	--modificacion optimizacion 
		DROP TABLE IF EXISTS tempdatospdig;
		CREATE TABLE bdicred:"informix".tempdatospdig(
								num_credito CHAR(20),
								gastos_originacion DECIMAL(18,2),
								atr DECIMAL(18,2),
								atr1 DECIMAL(18,2),
								atr2 DECIMAL(18,2),
								comisiones INTEGER,
								comision_cobranza DECIMAL(18,2), 
								comisionexig_cobranza DECIMAL(18,2),
								numero_cuenta_det CHAR(20)		

						
		);
		
		CREATE INDEX "informix".idx_temppdig ON bdicred:"informix".tempdatospdig(num_credito);
		update statistics medium for table bdicred:"informix".tempdatospdig;

		LET sqlArchivoLeer = "/usr/bin/echo 'SET ISOLATION TO DIRTY READ; LOAD FROM "||TRIM(pRutaArchivo)||TRIM(pNombrearchivo);  --/RESPALDOS/PruebasIFSR/insumos_junio/archivo_pdig_prueba.txt" ;
		LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||" INSERT INTO bdicred:tempdatospdig(num_credito,gastos_originacion,atr,atr1,atr2,";
		LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||"comisiones,comision_cobranza,comisionexig_cobranza,numero_cuenta_det)'"; --Pct_Pgo0,Pct_pago1,Pct_pago2)'";
		LET sqlArchivoLeer = TRIM(sqlArchivoLeer)||" | /ifxsif01/bin/dbaccess sysmaster > /dev/null 2>&1";
		
		SYSTEM TRIM(sqlArchivoLeer);
END IF;


	-- Obtiene informacion de universo de creditos en tablas temporales
	DROP TABLE IF EXISTS tmp_maecredcontcrd;
	DROP TABLE IF EXISTS tmp_maesdoscontcrd;
	DROP TABLE IF EXISTS tmp_indicador_cred_crd_hist;
	DROP TABLE IF EXISTS tmp_maecredanexocrd;
	DROP TABLE IF EXISTS tmp_revision_determinacion;
	DROP TABLE IF EXISTS tmp_resum_scor_fin;
	DROP TABLE IF EXISTS tmp_sdodiariocrd;
	DROP TABLE IF EXISTS tmp_movhiscrd;	
	DROP TABLE IF EXISTS tmp_movhiscrd_119;	
	

	-- Obtiene informacion de tabla sd_maecredcontcrd
	SELECT empresa, num_credito, numcte, sucursal, num_producto, periodo_plazo, fecha_apertura, fecha_vencim, status_cred, plazo, fecha
	  FROM bdicred:sd_maecredcontcrd
     WHERE fecha = pPeriodo 
    AND num_credito > cred_ini AND num_credito <= cred_fin
	--	AND num_credito = '680011665931' --solo pruebas
	   AND num_producto = vprod_proc   --   in('6300','7600', '7700's, '6400')
	  INTO temp tmp_maecredcontcrd WITH NO LOG;   		-- Temporal de tabla: sd_maecredcontcrd
	create index inx_inscal_pdig_1 on tmp_maecredcontcrd ( numcte );	   
	create index inx_inscal_pdig_2 on tmp_maecredcontcrd ( empresa, fecha, num_credito );	
	create index inx_inscal_pdig_3 on tmp_maecredcontcrd ( num_credito );
	
	   
	-- Elimina informacion ya existente.
	DELETE FROM tmp_maecredcontcrd WHERE num_credito IN (select num_credito from sd_insumos_calif_pp where fecha_cierre = pPeriodo and num_producto = vprod_proc);
	
	-- Obtiene informacion de tabla: sd_maesdoscontcrd
	SELECT b.empresa, b.num_credito, b.sdo_moratorio, b.sdo_contab_mora, b.monto_otorgado, b.sdo_cap_insoluto, b.fecha,b.mto_fin_ven_trasp
	  FROM bdicred:sd_maesdoscontcrd b  
	 INNER JOIN tmp_maecredcontcrd a ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) 
      INTO temp tmp_maesdoscontcrd WITH NO LOG;  
	create index inx_dos_inscal_pdig_1 on tmp_maesdoscontcrd ( num_credito );	   
	create index inx_dos_inscal_pdig_2 on tmp_maesdoscontcrd ( empresa, fecha, num_credito );	             
	
	-- Obtiene informacion de la tabla: sd_indicador_cred_crd_hist
	SELECT c.empresa, c.num_credito, c.fecha_insert, c.dias_atraso,c.fecha_ultimo_pago_h
	  FROM bdicred:sd_indicador_cred_crd_hist c
	  JOIN tmp_maecredcontcrd a ON (a.empresa = c.empresa and c.fecha_insert = a.fecha and a.num_credito = c.num_credito)  --IPCB Se cambia a la historica.
	  INTO temp tmp_indicador_cred_crd_hist WITH NO LOG;  
	create index inx_ind_inscal_pdig_1 on tmp_indicador_cred_crd_hist ( empresa, num_credito, fecha_insert );	       			  

	--Obtiene informacion de la tabla sd_maecredanexocrd
	SELECT e.empresa, e.num_credito, e.dia_corte
	  FROM bdicred:sd_maecredanexocrd e
	  JOIN tmp_maecredcontcrd a   ON (a.empresa = e.empresa and a.num_credito = e.num_credito) 
	  INTO temp tmp_maecredanexocrd WITH NO LOG;
	create index inx_anx_inscal_pdig_1 on tmp_maecredanexocrd ( num_credito );	   
	create index inx_anx_inscal_pdig_2 on tmp_maecredanexocrd ( empresa, num_credito );	   	
	  
	-- Obtiene informacion de la tabla ss_revision_determinacion		??? (se usa??)
	SELECT f.* 
	  FROM bdisolic:ss_revision_determinacion f
      JOIN tmp_maecredcontcrd a ON (a.empresa = f.empresa and a.num_credito = f.num_solicitud and a.numcte = f.numcte) 	
	  INTO temp tmp_revision_determinacion WITH NO LOG;
	create index inx_revd_inscal_pdig_1 on tmp_revision_determinacion ( empresa, num_solicitud );	   	
	create index inx_revd_inscal_pdig_2 on tmp_revision_determinacion ( num_solicitud );	   	
	
	-- Obtiene informacion de la tabla ss_resum_scor_fin
	SELECT g.empresa, g.num_solicitud, g.evalua_cc, g.grupo, g.situacion_pago
	FROM bdisolic:ss_resum_scor_fin g 
    JOIN tmp_maecredcontcrd a ON (a.empresa = g.empresa and a.num_credito = g.num_solicitud)
    INTO temp tmp_resum_scor_fin WITH NO LOG;
	create index inx_rsc_inscal_pdig_1 on tmp_resum_scor_fin ( empresa, num_solicitud );	  
	     
	-- Obtiene informacion de la tabla sd_sdodiariocrd
	SELECT s.*
	  FROM bdicred:sd_sdodiariocrd s
      JOIN tmp_maecredcontcrd a ON (s.num_credito = a.num_credito and ( s.fecha = piniperiodo or (s.fecha = monthadd(piniperiodo,-1))))
	INTO temp tmp_sdodiariocrd WITH NO LOG;
	create index inx_sdr_inscal_pdig_1 on tmp_sdodiariocrd ( fecha, num_credito );
	create index inx_sdr_inscal_pdig_2 on tmp_sdodiariocrd ( num_credito );			
			
	-- Obtiene informacion de la tabla movhis => codigo_fun = '002' AND codigo_ref = 66
	SELECT {+avoid_full (bdicred:sd_movhiscrd)} h.empresa, h.num_credito, h.fecha_mov, h.codigo_fun, h.codigo_ref, h.reversado
	  FROM bdicred:sd_movhiscrd h
	  JOIN tmp_maecredcontcrd a ON (a.empresa = h.empresa and a.num_credito = h.num_credito)
	 WHERE h.codigo_fun = '002' AND h.codigo_ref = 66
	   AND h.reversado = 'N'	
	  INTO temp tmp_movhiscrd WITH NO LOG;
	create index inx_mvh_inscal_pdig_1 on tmp_movhiscrd ( empresa, num_credito, codigo_fun, codigo_ref );	  
				
	-- Obtiene informacion para tabla temporal sd_movhiscrd => codigo_fun = '002' AND codigo_ref = 119
	SELECT {+avoid_full (bdicred:sd_movhiscrd)} h2.empresa, h2.fecha_mov, h2.num_Credito, h2.codigo_fun, h2.codigo_ref, h2.reversado
      FROM bdicred:sd_movhiscrd h2
	  JOIN tmp_maecredcontcrd a ON (a.empresa = h2.empresa and a.num_credito = h2.num_credito)
     WHERE h2.empresa = '001' AND h2.codigo_fun = '002' AND h2.codigo_ref = 119
       AND h2.reversado = 'N'
	  INTO temp tmp_movhiscrd_119 WITH NO LOG;
	create index inx_mvh2_inscal_pdig_1 on tmp_movhiscrd_119 ( empresa, num_credito, codigo_fun, codigo_ref );	  
	create index inx_mvh2_inscal_pdig_2 on tmp_movhiscrd_119 ( num_credito );
	
    
				
					  
	-- Obtiene informacion de universo de creditos.				
    FOREACH WITH HOLD
	
		
		SELECT a.num_credito, 
            a.numcte ,
            a.sucursal,
            a.num_producto,
            a.periodo_plazo facturacion,
            mdy(month(a.fecha_apertura),day(a.fecha_apertura),year(a.fecha_apertura)) fecha_apertura,
            TO_CHAR(a.fecha_apertura, '%Y/%m/%d') as fecha_apertura_format,
            mdy(month(a.fecha_vencim), day(a.fecha_vencim), year(a.fecha_vencim)) fecha_vencimiento,
            TO_CHAR(a.fecha_vencim, '%Y/%m/%d') as fecha_venc_format,
            a.status_cred status_fin_mes,
            e.dia_corte,
         --   case when e.dia_corte=31 then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo)) 
            --	 when month(pPeriodo)= 2 and e.dia_corte in(31,30,29) then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo))
              --  else mdy(month(pPeriodo),(dia_corte),year(pPeriodo)) end fecha_corte,
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
            --round((b.sdo_cap_insoluto / b.monto_otorgado),6)porcentaje_uso, --se comenta por cambio en el calculo
            CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_total,
			--t.plazo_total,
            --CASE WHEN round((fecha_vencim -a.fecha)/ 365.25,5) <= 0 THEN 0 ELSE round((fecha_vencim -a.fecha)/ 365.25,5) END plazo_remanente,
			round(((fecha_vencim -a.fecha)/ 365.25),5) plazo_remanente,
			b.mto_fin_ven_trasp, c.fecha_ultimo_pago_h,
			t.gastos_originacion,
			
		
			
			t.atr,t.atr1,t.atr2,

		
			
			t.comisiones,
			t.comision_cobranza,
			t.comisionexig_cobranza,
			t.numero_cuenta_det
			

            --CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_contractual
            --FROM sd_maecredcontcrd a
			INTO  v_num_credito,v_num_cliente,v_sucursal,v_num_producto,v_facturacion,v_fecha_apertura,v_fecha_apertura_format,
			 v_fecha_vencimiento,v_fecha_venc_format, v_status_fin_mes, v_dia_corte,v_dias_atraso,v_int_mora_copete,
			 v_int_mora_ordinario,v_linea_autorizada,v_antecedentes_buro,v_grupo_originacion,
			 v_cred_nomina,v_ree_tdc_anterior,v_eficiencia,	v_plazo_total,v_plazo_remanente,v_num_pagos_vencidos,
			 v_fecha_ult_pago, 
			 v_gastos_originacion,
			 
			
			 v_atr1,v_atr2,v_atr3,
			 
			
			
			 v_comisiones,
			 d_comision_cobranza, 
			 d_comisionexig_cobranza,
			 v_numero_cuenta_det
			 --v_prom2,v_prom3,v_prom4
			FROM tmp_maecredcontcrd a
			--LEFT JOIN tempdatospdig t ON (t.num_credito > cred_ini AND t.num_credito <= cred_fin and a.num_Credito = t.num_Credito)
			LEFT JOIN tempdatospdig t ON (a.num_Credito = t.num_Credito) --pruebas
            --INNER JOIN sd_maesdoscontcrd b 
			INNER JOIN tmp_maesdoscontcrd b  ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) 
            -- LEFT JOIN  sd_indicador_cred_crd_hist c    -- para reproceso se usa la historica sd_indicador_cred_crd_hist/ para mes actual la operativa  sd_indicador_cred_crd c     
			LEFT JOIN  tmp_indicador_cred_crd_hist c  ON (a.empresa = c.empresa and c.fecha_insert = a.fecha and a.num_credito = c.num_credito)  --IPCB Se cambia a la historica
            --ON (a.empresa = c.empresa and a.num_credito = c.num_credito)  --IPCB Se cambia a la operativa
            --INNER JOIN sd_maecredanexocrd e  
			INNER JOIN tmp_maecredanexocrd e ON (a.empresa = e.empresa and a.num_credito = e.num_credito)
            --LEFT JOIN bdisolic:ss_revision_determinacion f
			LEFT JOIN tmp_revision_determinacion f  ON (a.empresa = f.empresa and a.num_credito = f.num_solicitud and a.numcte = f.numcte)
			-- LEFT JOIN bdisolic:ss_resum_scor_fin g 
			LEFT JOIN tmp_resum_scor_fin g ON (a.empresa = g.empresa and a.num_credito = g.num_solicitud)
            WHERE a.fecha = pPeriodo
            AND a.num_producto = vprod_proc   --   in('6300','7600', '7700', '6400')
            AND a.num_credito  > cred_ini AND a.num_credito <= cred_fin   
			--AND a.num_credito = '680008630575' --quitar solo pruebas	
				-- ya se eliminaron de la temporal
				-- and a.num_credito not in (select num_credito from sd_insumos_calif_pp where fecha_cierre = pPeriodo and num_producto =vprod_proc) 
           -- AND a.num_credito = '680000092634'
			--and a.sucursal = '0002' --descomentar para pruebas

			
			
          /*
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
         --   case when e.dia_corte=31 then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo)) 
            --	 when month(pPeriodo)= 2 and e.dia_corte in(31,30,29) then mdy(month(pPeriodo),day(pPeriodo),year(pPeriodo))
              --  else mdy(month(pPeriodo),(dia_corte),year(pPeriodo)) end fecha_corte,
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
            --round((b.sdo_cap_insoluto / b.monto_otorgado),6)porcentaje_uso, --se comenta por cambio en el calculo
            CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_total,
            --CASE WHEN round((fecha_vencim -a.fecha)/ 365.25,5) <= 0 THEN 0 ELSE round((fecha_vencim -a.fecha)/ 365.25,5) END plazo_remanente,
			round(((fecha_vencim -a.fecha)/ 365.25),5) plazo_remanente,
			b.mto_fin_ven_trasp, c.fecha_ultimo_pago_h
            --CASE WHEN periodo_plazo='Q' THEN a.plazo/2 ELSE a.plazo END plazo_contractual
            INTO v_num_credito,v_num_cliente,v_sucursal,v_num_producto,v_facturacion,v_fecha_apertura,v_fecha_apertura_format,v_fecha_vencimiento,v_fecha_venc_format,
            v_status_fin_mes, v_dia_corte,--v_fecha_corte,
            v_dias_atraso,v_int_mora_copete,v_int_mora_ordinario,
            v_linea_autorizada,v_antecedentes_buro,v_grupo_originacion,v_cred_nomina,v_ree_tdc_anterior,v_eficiencia,--v_antiguedad,
            --v_porcentaje_uso,-- se comenta por cambio en el calculo
			v_plazo_total,v_plazo_remanente,v_num_pagos_vencidos,v_fecha_ult_pago
            --FROM sd_maecredcontcrd a
			FROM tmp_maecredcontcrd a
            --INNER JOIN sd_maesdoscontcrd b 
			INNER JOIN tmp_maesdoscontcrd b  ON (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) 
            -- LEFT JOIN  sd_indicador_cred_crd_hist c    -- para reproceso se usa la historica sd_indicador_cred_crd_hist/ para mes actual la operativa  sd_indicador_cred_crd c     
			LEFT JOIN  tmp_indicador_cred_crd_hist c  ON (a.empresa = c.empresa and c.fecha_insert = a.fecha and a.num_credito = c.num_credito)  --IPCB Se cambia a la historica
            --ON (a.empresa = c.empresa and a.num_credito = c.num_credito)  --IPCB Se cambia a la operativa
            --INNER JOIN sd_maecredanexocrd e  
			INNER JOIN tmp_maecredanexocrd e ON (a.empresa = e.empresa and a.num_credito = e.num_credito)
            --LEFT JOIN bdisolic:ss_revision_determinacion f
			LEFT JOIN tmp_revision_determinacion f  ON (a.empresa = f.empresa and a.num_credito = f.num_solicitud and a.numcte = f.numcte)
			-- LEFT JOIN bdisolic:ss_resum_scor_fin g 
			LEFT JOIN tmp_resum_scor_fin g ON (a.empresa = g.empresa and a.num_credito = g.num_solicitud)
            WHERE a.fecha = pPeriodo
            AND a.num_producto = vprod_proc   --   in('6300','7600', '7700', '6400')
            AND a.num_credito  > cred_ini AND a.num_credito <= cred_fin   
			--AND a.num_credito = '680067684430' --quitar solo pruebas	
				-- ya se eliminaron de la temporal
				-- and a.num_credito not in (select num_credito from sd_insumos_calif_pp where fecha_cierre = pPeriodo and num_producto =vprod_proc) 
           -- AND a.num_credito = '680000092634'
			--and a.sucursal = '0002' --descomentar para pruebas
			*/
            
            IF (val_trans_Commit = 0) THEN
                BEGIN WORK;
                LET contador_commit = 0;
                LET val_trans_Commit = -1;
            END IF;
           
			SELECT fecha_vencim 
					INTO v_fecha_ven_ulm_disp
					FROM bdicred:sd_maecredcrd 
					WHERE num_credito = v_num_credito;
					
			LET v_plazo_remanente=round(((v_fecha_ven_ulm_disp -pPeriodo)/ 365.25),5);	
			
			
			
            --LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));		
    --Variables Ad Flexible
            LET v_fecha_primera_disp  = date(1);
            LET v_fecha_ulm_disp      = date(1);
           -- LET v_fecha_ven_ulm_disp  = date(1);
            LET v_represta			  = 0;	
                                    
                LET v_dia_corte = day(v_fecha_apertura);
                /*
                IF v_dia_corte = 31 OR (MONTH(pPeriodo)= 2 AND v_dia_corte IN (31,30,29)) THEN 
                    LET v_fecha_corte = pPeriodo;
                ELSE
                    LET v_fecha_corte = mdy(month(pPeriodo),(v_dia_corte),year(pPeriodo));
                END IF;
                */
                EXECUTE PROCEDURE sp_calcula_fechas_porperiodo_calif('001',v_facturacion,v_num_producto,v_dia_corte,pPeriodo)
                INTO c_CodRet, mMensaje, dFechaPer0, dFechaPer1, dFechaPer2, dFechaPer3, dFechaPer4, dFechaPer5, dFechaPer6,dFechaPer7;
            
                LET v_fecha_corte = dFechaPer0;
                LET v_fecha_corte_format = TO_CHAR(dFechaPer0, '%Y/%m/%d'); 

                LET v_dia_corte = day(v_fecha_corte);																									
    
                --LET v_fecha_ven_ulm_disp = v_fecha_vencimiento;
            
                --SELECT fecha_otorga, (fecha_otorga + 3 units year)--,sec_credito,fecha_ult_mod
				SELECT fecha_otorga, nvl(fecha_venc_linea,(fecha_otorga + v_adicional_fecha_otorga units month)) --AFC --APC
                  INTO v_fecha_apertura, v_fecha_vencimiento --, v_num_disposiciones,v_fecha_ulm_disp
                FROM bdicred:sd_linea_prestamo 
                WHERE empresa = '001' 
                AND num_credito = v_num_credito;
                
                LET v_antiguedad = (year(v_fecha_corte) - year(v_fecha_apertura)) * 12 + (month(v_fecha_corte) - month(v_fecha_apertura));	
				LET v_fecha_apertura_format = TO_CHAR(v_fecha_apertura, '%Y/%m/%d');
                
                SELECT MAX(fecha_insert) INTO v_fecha_ulm_disp
                FROM bdicred:sd_maecredcrd_flex 
                WHERE num_credito =  v_num_credito AND fecha_insert <= pPeriodo;  
     
                SELECT fecha_mov
                --FROM bdicred:sd_movhiscrd
				FROM tmp_movhiscrd
                WHERE empresa = '001'
                AND  num_Credito = v_num_credito
                AND codigo_fun = '002' AND codigo_ref = 66
                AND reversado = 'N'					
                INTO TEMP tmp_disposiciones WITH NO LOG;
     
                CREATE INDEX idx_tmp_disp ON tmp_disposiciones(fecha_mov) ONLINE;
                
                /*
                SELECT min(fecha_mov),max(fecha_mov),count(*)
                INTO v_fecha_primera_disp,v_fecha_ulm_disp,v_num_disposiciones
                FROM bdicred:sd_movhiscrd
                WHERE empresa = '001'
                AND  num_Credito = v_num_credito
                AND codigo_fun = '002' AND codigo_ref = 66
                AND reversado = 'N';					
                */
                
                SELECT min(fecha_mov),max(fecha_mov),count(*)
                INTO v_fecha_primera_disp,v_fecha_ulm_disp,v_num_disposiciones
                FROM tmp_disposiciones
                WHERE  fecha_mov <= pPeriodo;
                
                DROP TABLE tmp_disposiciones;
                        
            --Campo 12 cred_liquida_cred	
                IF v_num_disposiciones = 0 THEN
                    LET v_cred_liquida_cred	= 0;
                    LET v_fecha_primera_disp = DATE(1);
                    LET v_fecha_ulm_disp = DATE(1);
                    LET v_fecha_ven_ulm_disp = DATE(1);
                    LET v_plazo_remanente = 0;
                    LET v_plazo_total = 0;
                ELSE			
                    IF  v_num_disposiciones = 1 THEN	
                        LET v_cred_liquida_cred	= 0;								
                    ELSE				
                        SELECT COUNT(*) INTO v_represta 
                        --FROM bdicred:sd_movhiscrd
						FROM tmp_movhiscrd_119
                        WHERE empresa = '001'
                        AND fecha_mov = v_fecha_ulm_disp
                        AND  num_Credito = v_num_credito
                        AND codigo_fun = '002' AND codigo_ref = 119
                        AND reversado = 'N';
                        
                        IF v_represta = 0 THEN
                            LET v_cred_liquida_cred	= 0;					
                        ELSE
                            LET v_cred_liquida_cred	= 1;
                        END IF;				
                    END IF;
                    
                    --LET v_fecha_ven_ulm_disp = (v_fecha_ulm_disp + 3 units year);
					SELECT fecha_vencim 
					INTO v_fecha_ven_ulm_disp
					FROM bdicred:sd_maecredcrd 
					WHERE num_credito = v_num_credito;
                    --LET v_plazo_remanente = ROUND((v_fecha_ven_ulm_disp -  pPeriodo) /30.4,5);
                END IF;			
            
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
            --LET v_atr1                         	= 0;
            --LET v_atr2                          = 0;
            --LET v_atr3                          = 0;
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
            
            LET var_mto_fin_ven_trasp	=0;
            LET var_mto_fin_ven_trasp2	=0;
            LET v_ant_otro_inst 		= 0;
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
					

					IF v_comisiones is null or v_comisiones = '' THEN
						LET v_comisiones = 0;
						LET d_comision_cobranza = 0;
						LET d_comisionexig_cobranza = 0;
					END IF;
					
					--IF v_fecha_apertura_cte is null or v_fecha_apertura_cte = '' THEN
					
					
						
						
						
						
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
                    --END IF;          
							  
                    LET v_fecha_apertura_cte_format = TO_CHAR(v_fecha_apertura_cte, '%Y/%m/%d');

                    --CAMPO 3 antiguedad_cliente   
                    LET v_antiguedad_cliente = (year(pPeriodo) - year(v_fecha_apertura_cte)) * 12 + (month(pPeriodo) - month(v_fecha_apertura_cte));
    
                     --CAMPOS 4, 5, 6 y 7
                    --IF v_status_fin_mes='BA' or v_status_fin_mes='BT' THEN				
                    --    IF v_fecha_vencimiento >= pPeriodo THEN
                            SELECT nvl(atr,0) 
                            INTO v_atr
                            FROM sd_maesdoscontcrd 
                            WHERE num_credito =v_num_credito
                            --AND fecha=mdy(month(pPeriodo), day(pPeriodo), year(pPeriodo));
                            AND fecha= pPeriodo;  --30/06/2018
							
							
                            IF v_atr1 is null or v_atr1 = '' THEN
							
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
								
							END IF;
                            
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
                        END IF;	
                    ELSE
                        LET v_atr=0;
     
                        SELECT nvl(mto_fin_ven_trasp,0) 
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
                    --LET v_comisiones = 0;
                
                    --CAMPO 23 ingresos_mens_brutos
                    SELECT ingreso_mensual INTO v_ingresos_mens_brutos
                    FROM bdinteg:si_ingresos 
                    WHERE numcte =v_num_cliente and sec_ingreso=(select max(sec_ingreso) FROM bdinteg:si_ingresos 
                    WHERE numcte =v_num_cliente  and fecha_insert <= pPeriodo );
    
                    --CAMPO 24 ingresos_mens_netos  =0 
					LET v_ingresos_mens_netos=v_ingresos_mens_brutos;
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
                    FROM tmp_sdodiariocrd
                    WHERE num_credito=v_num_credito and fecha=piniperiodo;
					
					IF v_status_fin_mes ='AA' OR v_status_fin_mes='BA' or ((v_status_fin_mes in ('E1') AND v_atr=0 and v_dias_atraso=0) or (v_status_fin_mes in ('E1') AND v_atr=1 and (v_dias_atraso>0 and v_dias_atraso<30)) or (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90))) THEN
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
					END IF;
    
                    --CAMPO 30,31,32,33,34,35
                     if (v_dia_corte <=15) then
                            if (v_dia_corte <= 7) then
                                if  (v_dia_corte = 1)  then
                                    IF month(pPeriodo) IN (1,2,4,6,8,9,11) THEN
                                         SELECT int_venc_bal31, intvig31, ((intvenc31)-(int_venc_bal31)),ivaint_venc_bal31, ((ivaintvenc31)-(ivaint_venc_bal31)),ivaintvig31
                                        INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                        FROM tmp_sdodiariocrd
                                        WHERE num_credito=v_num_credito and fecha=  monthadd(piniperiodo,-1) ;  															
                                    ELIF month(pPeriodo) IN (5,7,10,12) THEN
                                        SELECT int_venc_bal30, intvig30, ((intvenc30)-(int_venc_bal30)),ivaint_venc_bal30, ((ivaintvenc30)-(ivaint_venc_bal30)),ivaintvig30
                                       INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                       FROM tmp_sdodiariocrd
                                       WHERE num_credito=v_num_credito and fecha=  monthadd(piniperiodo,-1) ; 
                                    ELIF MONTH(pPeriodo) in(3) THEN
                                        IF flag_aniobis = 1 THEN							
                                           SELECT int_venc_bal29, intvig29, ((intvenc29)-(int_venc_bal29)),ivaint_venc_bal29, ((ivaintvenc29)-(ivaint_venc_bal29)),ivaintvig29
                                           INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                           FROM tmp_sdodiariocrd
                                            WHERE num_credito=v_num_credito and fecha=  monthadd(piniperiodo,-1) ; 
                                        ELSE
                                            SELECT int_venc_bal28, intvig28, ((intvenc28)-(int_venc_bal28)),ivaint_venc_bal28, ((ivaintvenc28)-(ivaint_venc_bal28)),ivaintvig28
                                            INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                            FROM tmp_sdodiariocrd	
                                            WHERE num_credito=v_num_credito and fecha=  monthadd(piniperiodo,-1) ; 
                                        END IF;	
                                    END IF;                                                   
                                 elif (v_dia_corte = 2) then
                                    IF month(pPeriodo) IN (1) THEN
                                        SELECT int_venc_bal31, intvig31, ((intvenc31)-(int_venc_bal31)),ivaint_venc_bal31, ((ivaintvenc31)-(ivaint_venc_bal31)),ivaintvig31
                                        INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                        FROM tmp_sdodiariocrd
                                        WHERE num_credito=v_num_credito and fecha=  monthadd(piniperiodo,-1) ; 
                                    ELSE
                                        SELECT int_venc_bal1, intvig1, ((intvenc1)-(int_venc_bal1)),ivaint_venc_bal1, ((ivaintvenc1)-(ivaint_venc_bal1)),ivaintvig1
                                        INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                        FROM tmp_sdodiariocrd
                                        WHERE num_credito=v_num_credito and fecha= piniperiodo; 
                                    END IF;	
                                 elif (v_dia_corte = 3) then
                                    SELECT int_venc_bal2, intvig2, ((intvenc2)-(int_venc_bal2)),ivaint_venc_bal2, ((ivaintvenc2)-(ivaint_venc_bal2)),ivaintvig2
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 4) then
                                    SELECT int_venc_bal3, intvig3, ((intvenc3)-(int_venc_bal3)),ivaint_venc_bal3, ((ivaintvenc3)-(ivaint_venc_bal3)),ivaintvig3
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 5) then
                                    SELECT int_venc_bal4, intvig4, ((intvenc4)-(int_venc_bal4)),ivaint_venc_bal4, ((ivaintvenc4)-(ivaint_venc_bal4)),ivaintvig4
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 6) then
                                    SELECT int_venc_bal5, intvig5, ((intvenc5)-(int_venc_bal5)),ivaint_venc_bal5, ((ivaintvenc5)-(ivaint_venc_bal5)),ivaintvig5
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 else
                                    SELECT int_venc_bal6, intvig6, ((intvenc6)-(int_venc_bal6)),ivaint_venc_bal6, ((ivaintvenc6)-(ivaint_venc_bal6)),ivaintvig6
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
                                 end if; -- 1-7
                             else
                                 if (v_dia_corte = 8) then
                                    SELECT int_venc_bal7, intvig7, ((intvenc7)-(int_venc_bal7)),ivaint_venc_bal7, ((ivaintvenc7)-(ivaint_venc_bal7)),ivaintvig7
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 9) then
                                    SELECT int_venc_bal8, intvig8, ((intvenc8)-(int_venc_bal8)),ivaint_venc_bal8, ((ivaintvenc8)-(ivaint_venc_bal8)),ivaintvig8
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 10) then
                                    SELECT int_venc_bal9, intvig9, ((intvenc9)-(int_venc_bal9)),ivaint_venc_bal9, ((ivaintvenc9)-(ivaint_venc_bal9)),ivaintvig9
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 11) then
                                    SELECT int_venc_bal10, intvig10, ((intvenc10)-(int_venc_bal10)),ivaint_venc_bal10, ((ivaintvenc10)-(ivaint_venc_bal10)),ivaintvig10
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 12) then
                                    SELECT int_venc_bal11, intvig11, ((intvenc11)-(int_venc_bal11)),ivaint_venc_bal11, ((ivaintvenc11)-(ivaint_venc_bal11)),ivaintvig11
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 13) then
                                    SELECT int_venc_bal12, intvig12, ((intvenc12)-(int_venc_bal12)),ivaint_venc_bal12, ((ivaintvenc12)-(ivaint_venc_bal12)),ivaintvig12
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;  
    
                                 elif (v_dia_corte = 14) then
                                    SELECT int_venc_bal13, intvig13, ((intvenc13)-(int_venc_bal13)),ivaint_venc_bal13, ((ivaintvenc13)-(ivaint_venc_bal13)),ivaintvig13
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
    
                                 else
                                    SELECT int_venc_bal14, intvig14, ((intvenc14)-(int_venc_bal14)),ivaint_venc_bal14, ((ivaintvenc14)-(ivaint_venc_bal14)),ivaintvig14
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 end if; -- if 8-15
                             end if; -- if 7
                         else
                             if (v_dia_corte <= 23) then
                                 if (v_dia_corte = 16) then
                                    SELECT int_venc_bal15, intvig15, ((intvenc15)-(int_venc_bal15)),ivaint_venc_bal15, ((ivaintvenc15)-(ivaint_venc_bal15)),ivaintvig15
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo; 
    
                                 elif (v_dia_corte = 17) then
                                    SELECT int_venc_bal16, intvig16, ((intvenc16)-(int_venc_bal16)),ivaint_venc_bal16, ((ivaintvenc16)-(ivaint_venc_bal16)),ivaintvig16
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
    
                                 elif (v_dia_corte = 18) then
                                    SELECT int_venc_bal17, intvig17, ((intvenc17)-(int_venc_bal17)),ivaint_venc_bal17, ((ivaintvenc17)-(ivaint_venc_bal17)),ivaintvig17
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
    
                                 elif (v_dia_corte = 19) then
                                    SELECT int_venc_bal18, intvig18, ((intvenc18)-(int_venc_bal18)),ivaint_venc_bal18, ((ivaintvenc18)-(ivaint_venc_bal18)),ivaintvig18
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 20) then
                                    SELECT int_venc_bal19, intvig19, ((intvenc19)-(int_venc_bal19)),ivaint_venc_bal19, ((ivaintvenc19)-(ivaint_venc_bal19)),ivaintvig19
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;  
    
                                 elif (v_dia_corte = 21) then
                                    SELECT int_venc_bal20, intvig20, ((intvenc20)-(int_venc_bal20)),ivaint_venc_bal20, ((ivaintvenc20)-(ivaint_venc_bal20)),ivaintvig20
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 22) then
                                    SELECT int_venc_bal21, intvig21, ((intvenc21)-(int_venc_bal21)),ivaint_venc_bal21, ((ivaintvenc21)-(ivaint_venc_bal21)),ivaintvig21
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;  
    
                                 else
                                    SELECT int_venc_bal22, intvig22, ((intvenc22)-(int_venc_bal22)),ivaint_venc_bal22, ((ivaintvenc22)-(ivaint_venc_bal22)),ivaintvig22
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
                                 end if; --if 16-23
                             else
                                 if (v_dia_corte = 24) then
                                    SELECT int_venc_bal23, intvig23, ((intvenc23)-(int_venc_bal23)),ivaint_venc_bal23, ((ivaintvenc23)-(ivaint_venc_bal23)),ivaintvig23
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 25) then
                                    SELECT int_venc_bal24, intvig24, ((intvenc24)-(int_venc_bal24)),ivaint_venc_bal24, ((ivaintvenc24)-(ivaint_venc_bal24)),ivaintvig24
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
								elif (v_dia_corte = 26) and (month(v_fecha_corte)= 12) then
                                    SELECT int_venc_bal24, intvig24, ((intvenc24)-(int_venc_bal24)),ivaint_venc_bal24, ((ivaintvenc24)-(ivaint_venc_bal24)),ivaintvig24
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha = piniperiodo;   	
    
                                elif (v_dia_corte = 26) and (month(v_fecha_corte)<> 12) then
                                    SELECT int_venc_bal25, intvig25, ((intvenc25)-(int_venc_bal25)),ivaint_venc_bal25, ((ivaintvenc25)-(ivaint_venc_bal25)),ivaintvig25
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 27) then
                                    SELECT int_venc_bal26, intvig26, ((intvenc26)-(int_venc_bal26)),ivaint_venc_bal26, ((ivaintvenc26)-(ivaint_venc_bal26)),ivaintvig26
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;  
    
    
                                 elif (v_dia_corte = 28) then
                                    SELECT int_venc_bal27, intvig27, ((intvenc27)-(int_venc_bal27)),ivaint_venc_bal27, ((ivaintvenc27)-(ivaint_venc_bal27)),ivaintvig27
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 29) then
                                    SELECT int_venc_bal28, intvig28, ((intvenc28)-(int_venc_bal28)),ivaint_venc_bal28, ((ivaintvenc28)-(ivaint_venc_bal28)),ivaintvig28
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 elif (v_dia_corte = 30) then
                                    SELECT int_venc_bal29, intvig29, ((intvenc29)-(int_venc_bal29)),ivaint_venc_bal29, ((ivaintvenc29)-(ivaint_venc_bal29)),ivaintvig29
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
    
                                 else
                                    SELECT int_venc_bal30, intvig30, ((intvenc30)-(int_venc_bal30)),ivaint_venc_bal30, ((ivaintvenc30)-(ivaint_venc_bal30)),ivaintvig30
                                    INTO v_interes_vencido_bal, v_interes_vencido_ord,v_interes_vigente,v_iva_interes_vencido_bal,v_iva_interes_vencido_ord, v_iva_interes_vigente
                                    FROM tmp_sdodiariocrd
                                    WHERE num_credito=v_num_credito and fecha= piniperiodo;   
                                 end if; --if 24-31
                            end if; -- if 23
                       end if; -- if 15               
                    
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
             
                --CAMPO 41 MONTO EXIGIBLE y CAMPO 56   PAGO DEL MES
                SELECT iva INTO pIva
                FROM bdinteg:si_sucursales 
                WHERE sucursal=v_sucursal;                
                                    
                LET v_fecha =  v_fecha_corte -1 units day;
                
                --Valida inhabiles	
                IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
                    LET v_fecha =  v_fecha -1 units day;	 
                END IF;
                
                --MONTO EXIGIBLE
                SELECT                
                nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
                INTO v_monto_exigible
                FROM bdicred:sd_maesdoshistcrd
                WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 	
                
                --PAGO DEL MES
                    --IPCB Se cambia para corregir el considerar la suma del 31 de las cuentas que cortan en 30 
                    LET v_fecha = dFechaPer1 +1 units day;
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
                    and fecha_mov <= v_fecha_corte
                    and fecha_mov >= v_fecha
                    and num_credito =v_num_credito
                    and codigo_fun in (select {+avoid_full (sd_conceptospagomanualcrd)} cod_fun from sd_conceptospagomanualcrd)
                    --and codigo_ref in (16,14,15,5,6,8,10,17,18,7,12,1)
					and codigo_ref  in (16,14,15,5,6,8,10,17,18,7,12,1, 958,959,960,961,962,963,964,965,966,967,968,969,970,971,972,973,2,6616,6617,6652,6709,3)
                    and reversado = 'N';  
                
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
                
                
                --CAMPO 42 MONTO EXIGIBLE1 y CAMPO 64 PAGO_REALIZADO1
                select fecha, fecha_apertura,max(fecha_mov)
                into   vmes1, vfec_ap1, vfec_disp1
                from bdicred:sd_maecredcontcrd  a left join  bdicred:sd_movhiscrd b
                on a.empresa = b.empresa and fecha_mov = a.fecha_apertura  and a.num_credito = b.num_Credito AND codigo_fun = '002' AND codigo_ref = 66 AND reversado = 'N'
                where  fecha = (piniPeriodo -1 units day)
                and a.num_credito = v_num_credito
				group by 1,2;
                
                LET v_antig_exig1= (year(vmes1) - year(vfec_disp1)) * 12 + (month(vmes1) - month(vfec_disp1));
            
                LET vfec_corte1 = monthadd(vfec_disp1,v_antig_exig1);
                LET v_fecha =  (vfec_corte1)-1 units day;
                LET v_fecha_pago_ini1 = monthadd(vfec_disp1,v_antig_exig1 -1 )+1 units day; 
                
                --Valida inhabiles	
                IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
                    LET v_fecha =  v_fecha -1 units day;	 
                END IF;			
                
				
				--IF v_monto_exigible1 is null or v_monto_exigible1 = '' THEN --otpimizacion en caso de que el credito no este en el reporte 
				
					 --MONTO EXIGIBLE1
					SELECT                
					nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
					INTO v_monto_exigible1
					FROM bdicred:sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
		
				--END IF;
               
	
				--IF v_pago_realizado1 is null or v_pago_realizado1 = '' THEN 
					 --  PAGO_REALIZADO1
					select sum (monto) 
					INTO v_pago_realizado1
					from bdicred:sd_movhiscrd
					where empresa = '001'
					and fecha_mov <= vfec_corte1
					and fecha_mov >= v_fecha_pago_ini1
					and num_credito =v_num_credito
					and codigo_fun in (select {+avoid_full (sd_conceptospagomanualcrd)} cod_fun from bdicred:sd_conceptospagomanualcrd)
					and codigo_ref = 1
					and reversado = 'N'; 
				--END IF;
               	
                
                --CAMPO 43 MONTO EXIGIBLE2 y CAMPO 65 PAGO_REALIZADO2
    --				LET v_fecha =  (v_fecha_corte-2 units month)-1 units day;	
                select fecha, fecha_apertura,max(fecha_mov)
                into   vmes2, vfec_ap2, vfec_disp2
                from bdicred:sd_maecredcontcrd  a left join  bdicred:sd_movhiscrd b
                on a.empresa = b.empresa and fecha_mov = a.fecha_apertura  and a.num_credito = b.num_Credito AND codigo_fun = '002' AND codigo_ref = 66 AND reversado = 'N'
                where  fecha = ((piniPeriodo -1 units month )-1 units day)  --(pPeriodo -2 units month)
                and a.num_credito = v_num_credito
				group by 1,2;
                
                LET v_antig_exig2= (year(vmes2) - year(vfec_disp2)) * 12 + (month(vmes2) - month(vfec_disp2));
                
                LET vfec_corte2 = monthadd(vfec_disp2,v_antig_exig2);
                LET v_fecha =  (vfec_corte2)-1 units day;
                LET v_fecha_pago_ini2 = monthadd(vfec_disp2,v_antig_exig2 -1 )+1 units day; 			
                
                --Valida inhabiles	
                IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
                    LET v_fecha =  v_fecha -1 units day;	 
                END IF;
    
	
				--IF v_monto_exigible2 is null or v_monto_exigible2 = '' THEN
				
					 --MONTO EXIGIBLE2
					SELECT                
					nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
					INTO v_monto_exigible2
					FROM bdicred:sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha));  
					
				--END IF;
               
                
				--IF v_pago_realizado2 is null or v_pago_realizado2 = '' THEN
					 --PAGO_REALIZADO2
					--LET v_fecha = (v_fecha_corte - 3 units month)+1 units day;							
					select sum (monto) 
					INTO v_pago_realizado2
					from bdicred:sd_movhiscrd
					where empresa = '001'
					and fecha_mov <= vfec_corte2
					and fecha_mov >= v_fecha_pago_ini2
					and num_credito =v_num_credito
					and codigo_fun in (select {+avoid_full (sd_conceptospagomanualcrd)} cod_fun from bdicred:sd_conceptospagomanualcrd)
					and codigo_ref = 1
					and reversado = 'N';
				--END IF;
               
                
                --CAMPO 44 MONTO EXIGIBLE3 y CAMPO 66 PAGO_REALIZADO3
                --LET v_fecha =  (v_fecha_corte-3 units month)-1 units day;
                select fecha, fecha_apertura,max(fecha_mov)
                into   vmes3, vfec_ap3, vfec_disp3
                from bdicred:sd_maecredcontcrd  a left join  bdicred:sd_movhiscrd b
                on a.empresa = b.empresa and fecha_mov = a.fecha_apertura  and a.num_credito = b.num_Credito AND codigo_fun = '002' AND codigo_ref = 66 AND reversado = 'N'
                where  fecha =  ((piniPeriodo -2 units month )-1 units day)--(pPeriodo -3 units month)
                and a.num_credito = v_num_credito
				group by 1,2;
                
                LET v_antig_exig3= (year(vmes3) - year(vfec_disp3)) * 12 + (month(vmes3) - month(vfec_disp3));
            
                LET vfec_corte3 = monthadd(vfec_disp3,v_antig_exig3);
                LET v_fecha =  (vfec_corte3)-1 units day;
                LET v_fecha_pago_ini3 = monthadd(vfec_disp3,v_antig_exig3 -1 )+1 units day;			
                
                --Valida inhabiles	
                IF (month(v_fecha) = 1 AND day(v_fecha) = 1) OR  (month(v_fecha) = 12 AND day(v_fecha) = 25) THEN --(ultimo del anio o 24 de diciembre --Inhabiles)
                    LET v_fecha =  v_fecha -1 units day;	 
                END IF;
    
	
				--IF v_monto_exigible3 is null or v_monto_exigible3 = '' THEN
					
					--MONTO EXIGIBLE3 
					SELECT                
					nvl(monto_financiado,0) + nvl(sdo_no_exig,0) + nvl(mto_finan_vdo,0) + nvl(int_tra_no_exig,0) + nvl(mto_venc_int,0) + nvl((sdo_contab_mora + sdo_moratorio),0) + nvl(round((sdo_contab_mora + sdo_moratorio) * pIva,2),0)
					INTO v_monto_exigible3
					FROM bdicred:sd_maesdoshistcrd
					WHERE num_credito =v_num_credito and fecha=mdy(month(v_fecha), day(v_fecha), year(v_fecha)); 
					
				--END IF;
                
				
				--IF v_pago_realizado3 is null or v_pago_realizado3 = '' THEN
					  -- PAGO_REALIZADO3          
					--LET v_fecha = (v_fecha_corte - 4 units month)+1 units day;
					select sum (monto) 
					INTO v_pago_realizado3
					from bdicred:sd_movhiscrd
					where empresa = '001'
					and fecha_mov <= vfec_corte3
					and fecha_mov >= v_fecha_pago_ini3
					and num_credito =v_num_credito
					and codigo_fun in (select {+avoid_full (sd_conceptospagomanualcrd)} cod_fun from bdicred:sd_conceptospagomanualcrd)
					and codigo_ref = 1
					and reversado = 'N';
				--END IF;
              
                
                --MONTO EXIGIBLE4,5,6 y PAGO_REALIZADO4, 5, 6	
                LET v_monto_exigible4				= 0;
                LET v_pago_realizado4              	= 0;
                LET v_monto_exigible5				= 0;
                LET v_pago_realizado5              	= 0;
                LET v_monto_exigible6				= 0;
                LET v_pago_realizado6               = 0;	
    
                    --CAMPO 70 PERIODOS_INCUMPLIMIENTO
                    SELECT fecha, status_cred --COUNT(fecha) --INTO v_periodos_incumplimiento
                    FROM sd_maecredcontcrd 
                    WHERE empresa = '001' 
                    AND num_credito = v_num_credito
                    --and status_cred in('BA','BT')
                    and (status_cred in('BA','BT') or (status_cred='E1' AND v_atr=1 AND (v_dias_atraso>0 and v_dias_atraso>30)) or (status_cred in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (status_cred in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90))) 
                    INTO TEMP tmp_incumplimientos WITH NO LOG;
    
                    CREATE INDEX idx_INCUMp ON tmp_incumplimientos(fecha) ONLINE;
    
                     SELECT COUNT(*) INTO v_periodos_incumplimiento
                     FROM tmp_incumplimientos
                       WHERE fecha <= pPeriodo;
    
                    DROP TABLE tmp_incumplimientos;
					
					--CAMPO 74 PORCENTAJE_PAGO
					LET bandera_exigible = 1;	
					LET v_prom_tot = 0;
					LET var_div   = 0;
					LET v_porcentaje_pago = 0;
					
                    IF v_fecha_apertura >= piniPeriodo and v_fecha_apertura <= pPeriodo and NVL(v_monto_exigible,0) = 0 THEN
							LET v_porcentaje_pago ='1.00';
					ELSE
                    
                        IF nvl(v_monto_exigible,0)>0 THEN
                            LET v_prom1= nvl(v_pago_realizado / v_monto_exigible,0); --Pct_pgo0
						ELSE
							LET v_prom1 = "";
                        END IF;
						
						--IF v_prom2 is null or v_prom2 = '' THEN --optimizacion de aquellos que no estan en el reporte
						
							IF nvl(v_monto_exigible1,0)>0 THEN
								LET v_prom2= nvl(v_pago_realizado1 / v_monto_exigible1,0); --Pct_pago1
							ELSE
								LET v_prom2 = "";
							END IF;
							IF nvl(v_monto_exigible2,0)>0 THEN
								LET v_prom3= nvl(v_pago_realizado2 / v_monto_exigible2,0); --Pct_pago2
							ELSE
								LET v_prom3 = "";
							END IF;
							IF nvl(v_monto_exigible3,0)>0 THEN
								LET v_prom4= nvl(v_pago_realizado3 / v_monto_exigible3,0); --Pct_pago3
							ELSE
								LET v_prom4 = "";
							END IF;
							
						--END IF;
                       
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
                            LET v_porcentaje_pago =round(v_prom_tot/var_div,2);
                        END IF;
					
						IF v_prom_tot=0 THEN
							LET v_porcentaje_pago ='0.00'; 
						END IF;
					END IF;
                    --CAMPO 77 SALDO CIERRE
                    
                     IF v_status_fin_mes='BT' OR (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr>=1 and (v_dias_atraso>=90))  THEN
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
					
					SELECT monto
						INTO psaldoInteresApoyo
					FROM bdicred:sd_maeretenido 
					WHERE num_credito = v_num_credito
						AND transacc = '8374'
						AND estatus = 'R';
						
					IF NVL(psaldoInteresApoyo,0)>0 THEN
					 LET v_saldo_cierre= v_saldo_cierre+psaldoInteresApoyo; 
					END IF;
					-- se suma el interes al saldo cierre
					LET v_saldo_cierre= v_saldo_cierre+v_interes_deven_ven_bal;

					--LET v_porcentaje_uso=round((v_saldo_cierre / b.monto_otorgado),6);
					LET v_porcentaje_uso=round((v_saldo_cierre / v_linea_autorizada),6); --se modifica para que se haga sobre el saldo cierre
                   
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
                        
                        IF v_status_fin_mes='BT' OR (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)) THEN
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
                        IF v_status_fin_mes='BT' OR (v_status_fin_mes in ('E2') AND v_atr in(1,2,3) and (v_dias_atraso>30 and v_dias_atraso<90)) or (v_status_fin_mes in ('E3') AND v_atr in(1,2,3,4,5) and (v_dias_atraso>=90)) THEN
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
                        /*IF v_var_mtosdo IS NULL OR v_bkatr IS NULL OR v_mto_pagar_propios IS NULL OR v_mto_pagar_otros IS NULL OR 
                           v_sdo_actual_propio_ship IS NULL OR v_sdo_actual_otros_ship IS NULL OR v_ant_otro_inst IS NULL  THEN				*/
                        IF v_var_mtosdo IS NULL THEN --Riesgos indica que si esta variable es nula se marcara sin informacion   
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
                       -- LET v_sdo_actual_propio_ship =NVL(v_sdo_actual_propio_ship,0);
                        
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
    
                --END FOREACH;  
					SELECT tasa_interes INTO v_tasa_contractual		
                    FROM sd_maecredcrd WHERE num_credito=v_num_credito;
					
					--LET v_capital_cierre=v_capital_vigente+v_capital_vencido;
					
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

					/*SELECT count(*) INTO v_num_pagos_vencidos  
							FROM bdicred:sd_amortiza_creditocrd 
							WHERE num_Credito = v_num_credito 
								  AND capital_status in (2,7)
								 AND fecha_cuota <= pPeriodo;*/
                    
                    IF v_atr > 3 THEN
                        LET v_etapa_cred='3';
						LET v_intereses_etapa1=0;
						LET v_intereses_etapa2=0;
						LET v_intereses_etapa3=v_interes_deven_ven_bal+v_interes_deven_vig_bal;   ---v_interes_vencido_bal+v_interes_vigente;
					ELIF v_atr=0 or v_atr1=0 or (v_atr <= 1 and v_fecha_ult_pago <= v_fecha_corte)  THEN
                        LET v_etapa_cred='1';
						LET v_intereses_etapa1=v_interes_deven_ven_bal+v_interes_deven_vig_bal;  ---v_interes_vencido_bal+v_interes_vigente;
						LET v_intereses_etapa2=0;
						LET v_intereses_etapa3=0;
					ELSE
                    --ELIF v_atr >= 2 AND v_atr <= 3 THEN
                        LET v_etapa_cred='2';
						LET v_intereses_etapa1=0;
						LET v_intereses_etapa2=v_interes_deven_ven_bal+v_interes_deven_vig_bal;   ----v_interes_vencido_bal+v_interes_vigente;
						LET v_intereses_etapa3=0;
                    
                    END IF;
                    
					IF v_gastos_originacion is null or v_gastos_originacion = '' THEN
					   select nvl(b.monto,0) Into v_gastos_originacion from sd_definicion a
						inner join sd_tpcomis b
						on a.cod_comision_apertura=b.cod_comis
						where num_producto=v_num_producto;
					END IF;
					
					IF v_gastos_originacion is null or v_gastos_originacion='' THEN
						LET v_gastos_originacion=0;
					END IF;
					IF v_num_disposiciones > 0 THEN
						execute procedure "informix".sp_tasaefectiva(v_linea_autorizada, v_gastos_originacion, v_tasa_contractual, v_plazo_total, v_facturacion)
						INTO v_tir_mensual, v_tasa_efectiva;
					ELSE
						LET v_tasa_efectiva=0.00001;
					END IF;
					
					--LET v_tasa_contractual= v_tasa_contractual/100;
					IF v_tasa_contractual=0 THEN 
						LET v_tasa_contractual=0.00001;
					ELSE
						LET v_tasa_contractual= v_tasa_contractual/100;	
					END IF;
                    
					
					
						IF EXISTS (SELECT * FROM bdisolic:ss_Revision_determinacion WHERE num_solicitud = v_num_credito) THEN
							SELECT evalua_cc, bs_score, score_prop
							INTO c_evalua_cc,n_scoreburo, n_scoreotor              --score_buro             --score_originacion
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
							LET v_modelo_score='NO HIT'; --modelo_score
						ELIF c_evalua_cc in('0','1','2','3','4') THEN
							LET v_modelo_score='HIT';
						END IF;
					
					
					
                  
                    
                    IF v_plazo_remanente < 1 THEN
                        LET v_periodo_rem_n=1;
                    ELSE
                        LET v_periodo_rem_n = v_plazo_remanente;
                    END IF;
					
					LET v_periodos_incumplimiento= v_atr;
					IF  nvl(v_tasa_efectiva,'')='' THEN
						LET v_tasa_efectiva=0.00001;
					END IF;
    
	
	
					LET v_dias_rem_contractual = v_fecha_ven_ulm_disp - pPeriodo; --nuevo sep
					
					
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
                                                       monto_otros_vs_propios, monto_pagar_otros,monto_pagar_propios,mto_vs_sdo_sic, --nvos												   
                                                       num_cliente,num_credito,num_disposiciones,num_producto,pago_capital,pago_int_venc_bal,pago_int_venc_ord,
                                                       pago_interes_vigente,pago_iva_int_venc_bal,pago_iva_int_venc_ord,pago_iva_interes_vigente,
                                                       pago_realizado,pago_realizado1,pago_realizado2,pago_realizado3,pago_realizado4,pago_realizado5,
                                                       pago_realizado6, periodos_incumplimiento,plazo_remanente,plazo_total,		   
                                                       porcentaje_endeudamiento, --nvo
                                                       porcentaje_pago,porcentaje_uso,ree_tdc_anterior,saldo_cierre,saldo_corte,saldo_exigible,saldo_no_exigible,
                                                       saldo_sic,sin_consulta,--nvo
                                                       status_fin_mes,
                                                       cum_pag_sost, ant_otr_inst,saldoactual_propio_ship
                                                       ,fecha_primera_disp, fecha_ulm_disp, fecha_ven_ulm_disp,comision_cobranza, comisionexig_cobranza, 
                                                        numero_cuenta_det, antiguedad_inst, meses_ult_atr1d_todos, var_mtosdo, sucursal,tasa_contractual, capital_cierre,
                                                        cred_sit_especial, num_pagos_vencidos, etapa_cred, intereses_etapa3,gastos_originacion,
                                                        score_originacion,score_buro,modelo_score,periodo_rem_n, tasa_efectiva_dig,fecha_ult_pago,intereses_etapa1,intereses_etapa2, --nvos
														nombre_cte,rfc, --nvo
														Pct_Pgo0,Pct_pago1,Pct_pago2,Pct_pago3,Dias_Rem_Contractual)--nuevos sep
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
                                                       v_porcentaje_pago,nvl(v_porcentaje_uso,0),v_ree_tdc_anterior,nvl(v_saldo_cierre,0),nvl(v_saldo_corte,0),nvl(v_saldo_exigible,0),nvl(v_saldo_no_exigible,0),
                                                       v_sdo_sic,v_sin_consulta,
                                                       v_status_fin_mes,
                                                       v_cum_pago_sost,v_ant_otro_inst,v_sdo_actual_propio_ship
                                                       , v_fecha_primera_disp, v_fecha_ulm_disp, v_fecha_ven_ulm_disp,NVL(d_comision_cobranza,0), NVL(d_comisionexig_cobranza, 0),
                                                        v_numero_cuenta_det,v_antiguedad_inst, v_veces_ult_atr1d_todos, v_var_mtosdo, v_sucursal, v_tasa_contractual, v_capital_cierre,
                                                        v_cred_sit_especial,v_num_pagos_vencidos, v_etapa_cred, nvl(v_intereses_etapa3,0),v_gastos_originacion,
                                                        n_scoreotor,n_scoreburo,v_modelo_score,v_periodo_rem_n, v_tasa_efectiva,v_fecha_ult_pago,
														v_intereses_etapa1,v_intereses_etapa2, --nvos 
														c_nom_cte,v_rfc, --nvo
														v_prom1,v_prom2,v_prom3,v_prom4,v_dias_rem_contractual);
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
        LET cMensajeRet = "REPORTE DE PRESTAMOS DIGITAL PARTE "|| pEjecucion ||" OK ";
        LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;
        
        RETURN cCodRet, cMensajeRet, cMensajeRet2;
    END
    END PROCEDURE
    ;
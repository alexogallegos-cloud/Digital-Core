CREATE PROCEDURE "informix".sp_inserta_productos (pEmpresa CHAR(3), pUsuario CHAR(8),pFamilia CHAR(3), pNum_Producto CHAR(4), pNomb_Producto CHAR(40), psub_producto INTEGER)
		RETURNING CHAR(6) AS codret;



	-- ****************************************************************************
	-- *                        DEFINICION DE VARIABLES                           *
	-- ****************************************************************************
	DEFINE cCodRet 						CHAR(6);
	DEFINE iSqlErr 						INTEGER;
	DEFINE cEmpresa         			CHAR(3);
    DEFINE cNum_Producto    			CHAR(4);
    DEFINE cNomb_Producto   			CHAR(40);
	DEFINE ccod_tipcred         		CHAR(2);
    DEFINE dMonto_Min_Cred  			DECIMAL(18,2);
    DEFINE dMonto_Max_Cred  			DECIMAL(18,2);
    DEFINE sEdad_Minima     			SMALLINT;
    DEFINE sEdad_Maxima     			SMALLINT;
	DEFINE v_ya_existe 					SMALLINT;
    DEFINE cdivisa              		CHAR(2);
    DEFINE cse_valoriza         		CHAR(1);
    DEFINE ctipo_calculo        		CHAR(2);
    DEFINE ctasa_fija_o_var     		CHAR(1);
    DEFINE ccod_tasa_base       		CHAR(8);
    DEFINE dsobretasa           		DECIMAL(9,6);
    DEFINE cfactor_sobretasa    		CHAR(1);
    DEFINE ctipo_refinanc       		CHAR(1);
    DEFINE dporcent_refinanc    		DECIMAL(9,6);
    DEFINE cpago_adic_sig_cuo   		CHAR(1);
    DEFINE cperiod_pag_int      		CHAR(1);
    DEFINE cperiod_pago_cap     		CHAR(1);
    DEFINE idias_traspaso_int   		INTEGER;
    DEFINE idias_traspaso_cap   		INTEGER;
    DEFINE cperiodo_plazo       		CHAR(1);
    DEFINE iplazo_min_cred      		INTEGER;
    DEFINE iplazo_max_cred      		INTEGER;
    DEFINE ctasa_mora_adic            	CHAR(1);
    DEFINE ccod_tasa_mora             	CHAR(8);
    DEFINE cfact_sobret_mora          	CHAR(1);
    DEFINE dsobretasa_mora            	DECIMAL(9,6);
    DEFINE dfactor_moratorio          	DECIMAL(9,6);
    DEFINE crev_tasa_var_per          	CHAR(1);
    DEFINE idia_para_revisar          	INTEGER;
    DEFINE cpreautoriza               	CHAR(1);
    DEFINE ctasa_base_piso            	CHAR(8);
    DEFINE dsobretasa_piso            	DECIMAL(9,6);
    DEFINE cfactor_piso               	CHAR(1);
    DEFINE dtasa_piso                 	DECIMAL(9,6);
    DEFINE ctasa_base_techo           	CHAR(8);
    DEFINE dsobretasa_techo           	DECIMAL(9,6);
    DEFINE cfactor_techo              	CHAR(1);
    DEFINE dtasa_techo                	DECIMAL(9,6);
    DEFINE cband_prod                 	CHAR(1);
    DEFINE ccod_prod                  	CHAR(10);
    DEFINE ctpo_persona               	CHAR(2);
    DEFINE ctipo_cliente              	CHAR(5);
    DEFINE csegmentado                	CHAR(1);
    DEFINE dpor_acciones              	DECIMAL(9,6);
    DEFINE cmaneja_linea              	CHAR(1);
    DEFINE cmaneja_mora               	CHAR(1);
    DEFINE cmaneja_pago_sost          	CHAR(1);
    DEFINE ccapitaliza                	CHAR(1);
    DEFINE ccuenta_asosciada          	CHAR(1);
    DEFINE cllena_solicitud           	CHAR(1);
    DEFINE clleva_nombre              	CHAR(1);
    DEFINE sdia_cuota                 	SMALLINT;
    DEFINE sgracia_calc_mora          	SMALLINT;
    DEFINE cuser_insert               	CHAR(30);
    DEFINE dfecha_insert              	DATE;
    DEFINE dcat_edocta                	DECIMAL(14,2);
    DEFINE dcat_caratula              	DECIMAL(14,2);
    DEFINE cactiva_calif              	CHAR(1);
    DEFINE csiglas                    	CHAR(2);
    DEFINE cind_comision              	CHAR(1);
    DEFINE ctran_comision             	CHAR(4);
    DEFINE cprefijo_os                	CHAR(1);
    DEFINE crechazo_rgc               	CHAR(1);
    DEFINE df_modifica_montos         	DATE;
    DEFINE dmonto_min_disp            	DECIMAL(18,2);
    DEFINE sfactor_pago_min           	SMALLINT;
    DEFINE smto_pago_min              	SMALLINT;
    DEFINE dfact_pag_min_lc           	DECIMAL(4,4);
    DEFINE dfac_pagm_suma_sdo         	DECIMAL(4,4);
    DEFINE sflag_arbol                	SMALLINT;
    DEFINE crealizar_convenio         	CHAR(1);
    DEFINE ccobro_comision_anual      	CHAR(1);
    DEFINE ccobro_anual_titular       	CHAR(1);
    DEFINE ccobro_anual_adicional     	CHAR(1);
    DEFINE cfecha_1er_cobro_anual     	CHAR(1);
    DEFINE ccobro_parcializ_anual     	CHAR(1);
    DEFINE ccod_comision_efectivo     	CHAR(4);
    DEFINE ccobro_comis_apertura      	CHAR(1);
    DEFINE ccod_comision_apertura     	CHAR(4);
    DEFINE ccod_comision_anualidad    	CHAR(8);
    DEFINE ccat_comi_anual_adicional  	CHAR(1);
    DEFINE ibandera_os                	INTEGER;
    DEFINE iplazo_linea               	INTEGER;
    DEFINE cedocta_param              	CHAR(20);
    DEFINE ccod_rep_rob               	CHAR(6);
    DEFINE ccod_rep_ext               	CHAR(6);
    DEFINE ccod_rep_danmal            	CHAR(6);
    DEFINE ccod_rep_acl               	CHAR(6);
    DEFINE ccod_rep_ven               	CHAR(6);
    DEFINE ccod_rep_pet               	CHAR(6);
    DEFINE cid_domiciliacion          	CHAR(1);
    DEFINE cid_tasa_pref              	CHAR(1);
    DEFINE dpuntos_tasa_pref          	DECIMAL(9,6);
    DEFINE ccat_edc_com_anualidad     	CHAR(1);
    DEFINE cid_excluye_os             	CHAR(1);
    DEFINE cmsj_alta_movil            	CHAR(1);
    DEFINE ccod_financiero            	CHAR(3);
    DEFINE ctransacc_spei             	CHAR(4);
    DEFINE idias_cobro_aut            	INTEGER;
    DEFINE sreporte_cartera           	SMALLINT;
    DEFINE vlink_carta                	VARCHAR(80);
    DEFINE clink_carta_activo         	CHAR(1);
    DEFINE cvalida_sms                	CHAR(1);
    DEFINE cind_disp_efec             	CHAR(1);
    DEFINE coferta_emp                	CHAR(1);
    DEFINE cfamilia                   	CHAR(3);
    DEFINE cobligado_solidario        	CHAR(1);
    DEFINE cnum_obligados             	CHAR(1);
    DEFINE ccaptura_obligatoria       	CHAR(1);
    DEFINE cconciliador               	CHAR(1);
    DEFINE chistorico_cred            	CHAR(1);
    DEFINE scomi_gasto_cobranza       	SMALLINT;
    DEFINE ccod_comi_gasto_cobranza   	CHAR(4);
    DEFINE scomi_aclaracion_no        	SMALLINT;
    DEFINE ccod_comi_aclaracion_no    	CHAR(4);
    DEFINE scomi_liquidacion_antic    	SMALLINT;
    DEFINE ccod_comi_liquidacion_antic	CHAR(4);
    DEFINE sgarantias                 	SMALLINT;
    DEFINE sidgarantia                	SMALLINT;
    DEFINE dporcentajeaforo           	DECIMAL(16);
    DEFINE ccancelacion_inac          	CHAR(1);
    DEFINE ccancelacion_vig           	CHAR(1);
    DEFINE cseguro_vida               	CHAR(1);
    DEFINE cperiodo_gracia            	CHAR(1);
    DEFINE cdias_gracia               	INTEGER;
    DEFINE scomi_disposicion_efect    	SMALLINT;
    DEFINE ccuentas_medios            	CHAR(1);
    DEFINE ctiempo_cancelar           	CHAR(1);
    DEFINE ccobro_mensualidad         	CHAR(1);
    DEFINE cenvio_mesa_control        	CHAR(1);
    DEFINE ccapital_interes           	CHAR(1);
    DEFINE cintereses                 	CHAR(1);
    DEFINE cestado_cuenta             	CHAR(1);
    DEFINE cid_estadocuenta           	CHAR(3);
	DEFINE cdesc_estadocuenta			CHAR(20);
    DEFINE cemision_estado_cuenta     	CHAR(2);
    DEFINE crango_inicial             	CHAR(2);
    DEFINE crango_final               	CHAR(2);
    DEFINE cid_tipo_facturacion       	CHAR(2);
    DEFINE cn_dias_facturacion        	CHAR(3);
    DEFINE cdia_facturacion           	CHAR(2);
    DEFINE crango_f_fecha_inic        	CHAR(2);
    DEFINE crango_f_fecha_fin         	CHAR(2);
	DEFINE isub_producto                INTEGER;
	DEFINE cdesc_comisgastoscob		    CHAR(30);
	DEFINE cdesc_cobro_comision_anual   CHAR(30);
	DEFINE cdesc_comidisposicion  	 	CHAR(30);
	DEFINE cdesc_Cod_Com_Aclaracion     CHAR(30);
	DEFINE cdesc_Cod_Com_Liquidacion    CHAR(30);
	DEFINE cdesc_comision_apertura		CHAR(30);
	DEFINE iexisttmp_tasas 				INTEGER;
	DEFINE iexisttmp_convivencia 		INTEGER;
	DEFINE iexisttmp_documentos 		INTEGER;
	DEFINE iexisttmp_doctos_imp 		INTEGER;
	DEFINE iexisttmp_operaciones 		INTEGER;
	DEFINE iexisttmp_activamsj 			INTEGER;
	DEFINE dmodelo_hit_bueno_ordnario 	DECIMAL(9,6);
	DEFINE dmodelo_hit_malo_ordnario 	DECIMAL(9,6);
	DEFINE dmodelo_no_hit_ordinario 	DECIMAL(9,6);
	DEFINE dmodelo_hit_bueno_moratorio 	DECIMAL(9,6);
	DEFINE dmodelo_hit_malo_moratorio 	DECIMAL(9,6);
	DEFINE dmodelo_no_hit_moratorio 	DECIMAL(9,6);
	DEFINE cgrupo 						CHAR(1);
	DEFINE ctipoproducto 				CHAR(2);
	DEFINE cconvnumproducto 			CHAR(4);
	DEFINE cconvnomproducto 			CHAR(40);
	DEFINE iclasifica1 					smallint;
	DEFINE iclasifica2 					smallint;
	DEFINE iclasifica3 					smallint;
	DEFINE iexistproductoconv 			smallint;
	DEFINE ctp_solicitud                CHAR(1);
	DEFINE ccod_definicion 				CHAR(4);
	DEFINE cprod_nombre 				CHAR(50);
	DEFINE ccod_grupo 					CHAR(3);
	DEFINE ccod_docto 					CHAR(4);
	DEFINE cdescripcion 				CHAR(50);
	DEFINE iexisttmp_digitaliza 		smallint;
	DEFINE imaxsec_digitaliza 			integer;
	DEFINE ccod_doctimp 				CHAR(4);
	DEFINE cdesc_doc 					CHAR(40);
	DEFINE icantidad 					integer;
	DEFINE scod_operaciones 			smallint;
	DEFINE cnum_prodsms 				CHAR(4);
	DEFINE scve_canal 					SMALLINT;
	DEFINE sid_evento 					SMALLINT;
	DEFINE scod_plantilla 				SMALLINT;
	DEFINE ccod_msm_mail 				char(50);
	DEFINE cactivosms 					CHAR(1);
	DEFINE cactivoemail 				CHAR(1);
	DEFINE iexisttmp_polcredprod 		integer;
	DEFINE cnum_prodpolcred 			CHAR(4);
	DEFINE corespuesta_sic 				CHAR(1);
	DEFINE cogrupo 						CHAR(1);
	DEFINE ibc_scoremin 				INTEGER;
	DEFINE ibc_scoremax 				INTEGER;
	DEFINE ipro_scormin 				INTEGER;
	DEFINE ipro_scormax 				INTEGER;
	DEFINE cstatus_sol 					CHAR(2);
	DEFINE ccausa_sol  					CHAR(3);
	DEFINE cNumprodAcceso 				CHAR(4);
	DEFINE cprodcap 					CHAR(4);
	DEFINE cNomprodcap 					CHAR(40);
	DEFINE iexisttmp_ctasacceso 		INTEGER;
	DEFINE iExiste						INTEGER;
	DEFINE bExisteProd					INTEGER;
	DEFINE icodparam					INTEGER;
	DEFINE icodparamMC					INTEGER;
	DEFINE cdescparamMC					CHAR(30);
	DEFINE sclasificacion				SMALLINT;
	DEFINE cprioridad					CHAR(2);
	DEFINE cidcta_concentradora 		CHAR(1);
	DEFINE ccta_concentradora 			CHAR(20);
	DEFINE crangoini_gracia				CHAR(2);
	DEFINE crangofin_gracia				CHAR(2);
	DEFINE pComision_Apertura 			DECIMAL(18,2);
	DEFINE pComision_Gastos 			DECIMAL(18,2);
	DEFINE pComision_Anualidad 			DECIMAL(18,2);
	DEFINE pComision_Disposicion		DECIMAL(18,2);
	DEFINE pComision_Aclaracion 		DECIMAL(18,2);
	DEFINE pComision_Liquidacion		DECIMAL(18,2);
	DEFINE sPlazo_Minimo 				SMALLINT;
	DEFINE sPlazo_Maximo 				SMALLINT;
	DEFINE dMontoMinDisp            	DECIMAL(18,2);
	DEFINE dMontoMaxDisp            	DECIMAL(18,2);
	DEFINE iPeriodoPlazo            	INTEGER;
	DEFINE cCodproducto  				CHAR(4);
	DEFINE cCodproducto1 				CHAR(4);
	DEFINE cCodproducto2 				CHAR(4);
	DEFINE cCodproducto3 				CHAR(4);
	DEFINE cCodTipcred   				CHAR(2);
	DEFINE cCodSistema   				CHAR(2);
	DEFINE cprod_ofrecer				CHAR(4);
	DEFINE imaxsec_tramiteprod			INTEGER;
	DEFINE sSecuencia					SMALLINT;
	DEFINE iCodproducto					INTEGER;
	DEFINE iexistTempCartprin 			INTEGER;
	DEFINE iexistTempCartcomp  			INTEGER;
	DEFINE iperplazo       				SMALLINT;
    DEFINE ctpo_pago   					CHAR(15);
	DEFINE ccapital						DECIMAL(18,2);
	DEFINE iexisttmp_polcredprodexist	INTEGER;
	DEFINE cligar								CHAR(1);
	DEFINE cformapli_comigascob 	CHAR(1);
	DEFINE cformapli_comiaper 		CHAR(1);
	DEFINE cformapli_comidispo		CHAR(1);
	DEFINE cformapli_comianual 		CHAR(1);
	DEFINE cformapli_comiaclara 		CHAR(1);
	DEFINE cformapli_comiliqant		CHAR(1);
	DEFINE cAuxId_subproducto 		VARCHAR(5);
	DEFINE cAuxId_subproducto2 		VARCHAR(5);

	-- ****************************************************************************
	-- *                        ASIGNACION DE VARIABLES                           *
	-- ****************************************************************************

	LET cCodRet 					= '000000';
	LET iSqlErr 					= 0;
	LET cEmpresa 					= pEmpresa;
	LET cNum_Producto 				= pNum_Producto;
	LET cNomb_Producto 				= pNomb_Producto;
	LET ccod_tipcred 				= '';
	LET dMonto_Min_Cred 			= 0;
	LET dMonto_Max_Cred 			= 0;
	LET sEdad_Minima 				= 0;
	LET sEdad_Maxima 				= 0;
	LET v_ya_existe			 		= 0;
	--LET cUsuario             		= 'informix';
	LET cdivisa                      = '01';
    LET cse_valoriza                =  '';
    LET ctipo_calculo               =  ''; -- Agregar 01 a prestamo
    LET ctasa_fija_o_var            =  ''; -- Agregar 1 a prestamo
    LET ccod_tasa_base              =  '';
    LET dsobretasa                  =  0;
    LET cfactor_sobretasa           =  '+';
    LET ctipo_refinanc              =  '';
    LET dporcent_refinanc           =  0;
    LET cpago_adic_sig_cuo          =  '1';
    LET cperiod_pag_int             =  ''; -- 2 prestamo
    LET cperiod_pago_cap            =  ''; -- 3 prestamo


    LET idias_traspaso_int          =  ''; --60 tdc y 90 prestamo
    LET idias_traspaso_cap          =  ''; --60 tdc y 90 prestamo
    LET cperiodo_plazo              =  '';
    LET iplazo_min_cred             =  0;
    LET iplazo_max_cred             =  0;
    LET ctasa_mora_adic             = '3';
    LET ccod_tasa_mora              = '';
    LET cfact_sobret_mora           = '+';
    LET dsobretasa_mora             = 0;
    LET dfactor_moratorio           = 0;
    LET crev_tasa_var_per           = '';
    LET idia_para_revisar           = 0;
    LET cpreautoriza                = '';
    LET ctasa_base_piso             = '';
    LET dsobretasa_piso             = 0;
    LET cfactor_piso                = '';
    LET dtasa_piso                  = 0;
    LET ctasa_base_techo            = '';
    LET dsobretasa_techo            = 0;
    LET cfactor_techo               = '';
    LET dtasa_techo                 = 0;
    LET cband_prod                  = '';
    LET ccod_prod                   = '';
    LET ctpo_persona                = '';
    LET ctipo_cliente               = '26';
    LET csegmentado                 = '';
    LET dpor_acciones               = 0;
    LET cmaneja_linea               = '1';
    LET cmaneja_mora                = 'S';
    LET cmaneja_pago_sost           = 'N';
    LET ccapitaliza                 = 'N';
    LET ccuenta_asosciada           = 'S'; --Prestamo S y TDC N
    LET cllena_solicitud            = 'S';
    LET clleva_nombre               = 'N';
    LET sdia_cuota                  = '';
    LET sgracia_calc_mora           = 0;
    LET cuser_insert                = pUsuario;
    LET dfecha_insert               = CURRENT;
    LET dcat_edocta                 = 0;
    LET dcat_caratula               = 0;
    LET cactiva_calif               = '0'; --Prestamo 0 y TDC 1
    LET csiglas                     = substr(pNum_Producto,1,2);
    LET cind_comision               = '0';
    LET ctran_comision              = '0000';
    LET cprefijo_os                 = ''; --Prestamo 4 y TDC 1
    LET crechazo_rgc                = '1';
    LET df_modifica_montos          = CURRENT;
    LET dmonto_min_disp             = 0;
    LET sfactor_pago_min            = '0'; --Prestamo 0 y TDC 9
    LET smto_pago_min               = 0; --Prestamo 0 y TDC 200
    LET dfact_pag_min_lc            = 0; --Prestamo 0 y TDC 0.0125
    LET dfac_pagm_suma_sdo          = 0; --Prestamo 0 y TDC 0.015
    LET sflag_arbol                 = 1;
    LET crealizar_convenio          = 'S';
    LET ccobro_comision_anual       = '';
    LET ccobro_anual_titular        = '';
    LET ccobro_anual_adicional      = '';
    LET cfecha_1er_cobro_anual      = '';
    LET ccobro_parcializ_anual      = '';
    LET ccod_comision_efectivo      = '';
    LET ccobro_comis_apertura       = 0;
    LET ccod_comision_apertura      = '';
    LET ccod_comision_anualidad     = '';
    LET ccat_comi_anual_adicional   = '0';
    LET ibandera_os                 = '0';
    LET iplazo_linea                = 0;
    LET cedocta_param               = '';
    LET ccod_rep_rob                = '';
    LET ccod_rep_ext                = '';
    LET ccod_rep_danmal             = '';
    LET ccod_rep_acl                = '';
    LET ccod_rep_ven                = '';
    LET ccod_rep_pet                = '';
    LET cid_domiciliacion           = '';
    LET cid_tasa_pref               = '0';
    LET dpuntos_tasa_pref           = 0;
    LET ccat_edc_com_anualidad      = '0';
    LET cid_excluye_os              = '0';
    LET cmsj_alta_movil             = '0';
    LET ccod_financiero             = '0';
    LET ctransacc_spei              = '0';
    LET idias_cobro_aut             = 0;
    LET sreporte_cartera            = 1;
    LET vlink_carta                 = '';
    LET clink_carta_activo          = '';
    LET cvalida_sms                 = '1';
    LET cind_disp_efec              = '0';
    LET coferta_emp                 = '0';
    LET cfamilia                    = pFamilia;
    LET cobligado_solidario         = '';
    LET cnum_obligados              = '';
    LET ccaptura_obligatoria        = '';
    LET cconciliador                = '';
    LET chistorico_cred             = '';
    LET scomi_gasto_cobranza        = 0;
    LET ccod_comi_gasto_cobranza    = '';
    LET scomi_aclaracion_no         = 0;
    LET ccod_comi_aclaracion_no     = '';
    LET scomi_liquidacion_antic     = 0;
    LET ccod_comi_liquidacion_antic = '';
    LET sgarantias                  = 0;
    LET sidgarantia                 = 0;
    LET dporcentajeaforo            = 0;
    LET ccancelacion_inac           = '';
    LET ccancelacion_vig            = '';
    LET cseguro_vida                = '';
    LET cperiodo_gracia             = '';
    LET cdias_gracia                = '';
    LET scomi_disposicion_efect     = 0;
    LET ccuentas_medios             = '';
    LET ctiempo_cancelar            = '';
    LET ccobro_mensualidad          = '';
    LET cenvio_mesa_control         = '';
    LET ccapital_interes            = '';
    LET cintereses                  = '';
    LET cestado_cuenta              = '';
    LET cid_estadocuenta            = '';
	LET cdesc_estadocuenta			= '';
    LET cemision_estado_cuenta      = '';
    LET crango_inicial              = '';
    LET crango_final                = '';
    LET cid_tipo_facturacion        = '';
    LET cn_dias_facturacion         = '';
    LET cdia_facturacion            = '';
    LET crango_f_fecha_inic         = '';
	LET crango_f_fecha_fin          = '';
	LET isub_producto               = NVL(psub_producto,0);
	LET cdesc_comisgastoscob		= '';
	LET cdesc_cobro_comision_anual  = '';
	LET cdesc_comidisposicion  	 	= '';
	LET cdesc_Cod_Com_Aclaracion	= '';
	LET cdesc_Cod_Com_Liquidacion	= '';
	LET cdesc_comision_apertura	 	= '';
	LET iexisttmp_tasas 			= 0;
	LET iexisttmp_convivencia 		= 0;
	LET iexisttmp_documentos 		= 0;
	LET iexisttmp_doctos_imp 		= 0;
	LET iexisttmp_operaciones 		= 0;
	LET iexisttmp_activamsj 		= 0;
	LET dmodelo_hit_bueno_ordnario  = 0.0;
	LET dmodelo_hit_malo_ordnario 	= 0.0;
	LET dmodelo_no_hit_ordinario 	= 0.0;
	LET dmodelo_hit_bueno_moratorio = 0.0;
	LET dmodelo_hit_malo_moratorio 	= 0.0;
	LET dmodelo_no_hit_moratorio 	= 0.0;
	LET cgrupo 						= '';
	LET ctipoproducto 				= '';
	LET cconvnumproducto 			= '';
	LET cconvnomproducto 			= '';
	LET iclasifica1 				= 0;
	LET iclasifica2 				= 0;
	LET iclasifica3 				= 0;
	LET iexistproductoconv 			= 0;
	LET ctp_solicitud 				= '';
	LET ccod_definicion 			= '';
	LET cprod_nombre 				= '';
	LET ccod_grupo 					= '';
	LET ccod_docto 					= '';
	LET cdescripcion 				= '';
	LET iexisttmp_digitaliza 		= 0;
	LET imaxsec_digitaliza 			= 0;
	LET iExiste 					= 0;
	LET bExisteProd 				= 0;
	LET icodparam					= 0;
	LET icodparamMC 				= 0;
	LET cdescparamMC 				= '';
	LET cprioridad					= '';
	LET icantidad 					= 0;
	LET cnum_prodsms 				= '';
	LET scve_canal  				= 0;
	LET sid_evento 					= 0;
	LET scod_plantilla 				= 0;
	LET ccod_msm_mail 				= '';
	LET cactivosms 					= '';
	LET cactivoemail 				= '';
	LET ccod_doctimp 				= '';
	LET cdesc_doc 					= '';
	LET iexisttmp_polcredprod 		= 0;
	LET cnum_prodpolcred 			= '';
	LET corespuesta_sic 			= '';
	LET cogrupo 					= '';
	LET ibc_scoremin 				= 0;
	LET ibc_scoremax 				= 0;
	LET ipro_scormin 				= 0;
	LET ipro_scormax 				= 0;
	LET cstatus_sol 				= '';
	LET ccausa_sol  				= '';
	LET cNumprodAcceso 				= '';
	LET cprodcap 					= '';
	LET cNomprodcap 				= '';
	LET iexisttmp_ctasacceso 		= 0;
	LET sPlazo_Minimo 				= 0;
	LET sPlazo_Maximo 				= 0;
	LET cidcta_concentradora 		= '';
	LET ccta_concentradora 			= '';
	LET	crangoini_gracia			= '';
	LET crangofin_gracia			= '';
	LET pComision_Apertura 			= 0.0;
	LET pComision_Gastos 			= 0.0;
	LET pComision_Anualidad 		= 0.0;
	LET pComision_Disposicion		= 0.0;
	LET pComision_Aclaracion 		= 0.0;
	LET pComision_Liquidacion		= 0.0;
	LET dMontoMinDisp           	= 0.0;
	LET dMontoMaxDisp            	= 0.0;
	LET iPeriodoPlazo            	= 0;
	LET cCodproducto 				= '';
	LET cCodproducto1 				= '';
	LET cCodproducto2 				= '';
	LET cCodproducto3 				= '';
	LET cCodTipcred 				= '';
	LET cCodSistema 				= '';
	LET cprod_ofrecer				= '';
	LET imaxsec_tramiteprod			= 0;
	LET sSecuencia 					= 0;
	LET iCodproducto				= 0;
	LET iexistTempCartprin 			= 0;
	LET iexistTempCartcomp  		= 0;
	LET iperplazo					= 0;
	LET ctpo_pago					= '';
	LET ccapital					= 0.0;
	LET iexisttmp_polcredprodexist  = 0;
	LET cligar							= '';
	LET cformapli_comigascob  = '';
	LET cformapli_comiaper 		= '';
	LET cformapli_comidispo		= '';
	LET cformapli_comianual 	= '';
	LET cformapli_comiaclara 	= '';
	LET cformapli_comiliqant	= '';
	LET cAuxId_subproducto	    = '';
	LET cAuxId_subproducto2	    = '';

	BEGIN
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				IF NVL(bExisteProd,0) = 0 THEN
					DELETE FROM bdicred:"informix".sd_definicion WHERE num_producto = pNum_Producto;
					DELETE FROM bdicred:"informix".sd_tasas_disposiciones_diferenciadas WHERE num_producto = pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_oscalle_plazovigencia  WHERE clave_producto =pNum_Producto;
					DELETE FROM bdinteg:"informix".si_prod_ejecut WHERE num_producto = pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_solic_producto WHERE num_producto = pNum_Producto;
					DELETE FROM bdicred:"informix".sd_tipprod WHERE abrevia_prod =pNum_Producto;
					DELETE FROM bdicred:"informix".sd_doctosimprimexproducto WHERE num_producto = cNum_Producto;
					DELETE FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto= cNum_Producto;
					DELETE FROM bdisolic:"informix".ss_scoring_modelo2 WHERE num_producto = cNum_Producto;
					DELETE FROM bdicred:"informix".sd_activacion_sms_email WHERE num_producto = cNum_Producto;
					DELETE FROM bdicred:"informix".sd_operaciones_canal WHERE num_producto = cNum_Producto;
					DELETE FROM bdisolic:"informix".ss_oscalle_vigencia WHERE clave_producto =pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_vigencia_sol_productos where num_producto = pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_control_parametricos where num_producto = pNum_Producto;
					DELETE FROM bdiburo:"informix".br_tltco WHERE num_producto = pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_prod_aplica WHERE producto = pNum_Producto;
					DELETE FROM bdicred:"informix".sd_tpcomis WHERE cod_comis IN (ccod_comi_gasto_cobranza,ccod_comision_anualidad,ccod_comision_efectivo,ccod_comi_aclaracion_no,ccod_comision_apertura);
					DELETE FROM bdisolic:"informix".ss_cat_prod_ofrecer WHERE producto = pNum_Producto;
					DELETE FROM bdisolic:"informix".ss_param WHERE valor = pNum_Producto;
					DELETE FROM bdicnweb:"informix".sw_mc_idproducto WHERE cve_producto = pNum_Producto;
					FOREACH
						SELECT distinct cod_definicion
						INTO ccod_definicion
						FROM "informix".tmp_documentos_digitalizar
						ORDER BY cod_definicion

						DELETE FROM bdidigital@coppelimg_app:dg_definicion WHERE cod_definicion = ccod_definicion;
						DELETE FROM bdidigital@coppelimg_app:dg_definicion_det WHERE cod_definicion = ccod_definicion;

					END FOREACH;
				END IF;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_inserta_productos.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pEmpresa = '' OR pFamilia = '' OR pNum_Producto = ''  OR pNomb_Producto = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;

		SELECT count(*)INTO iexistTempCartprin
		FROM "informix".tmp_sd_definicion WHERE usuario_insert = pUsuario;

		SELECT count(*)INTO iexistTempCartcomp
		FROM "informix".tmp_caracteristicas_complementarias
		WHERE usuario_insert = pUsuario;

		IF NVL(iexistTempCartprin,0) >= 1 THEN
			SELECT empresa, num_producto, monto_min_cred, monto_max_cred, edad_min, edad_max, plazo_min_cred, plazo_max_cred, id_frec_pago, cobro_comision_anual, comi_gasto_cobranza, cobro_comis_apertura,
			comi_disposicion_efect, comi_aclaracion_no, comi_liquidacion_antic, cod_comision_apertura, cod_comi_gasto_cobranza, cod_comision_anualidad, cod_comi_disposicion_efect, cod_comi_aclaracion_no,
			cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo, obligado_solidario, num_obligados, captura_obligatoria, monto_min_disp, monto_max_disp, formapli_comigascob,formapli_comiaper,formapli_comidispo,formapli_comianual,formapli_comiaclara,formapli_comiliqant
			INTO pEmpresa, cNum_Producto, dMonto_Min_Cred, dMonto_Max_Cred, sEdad_Minima, sEdad_Maxima, iplazo_min_cred, iplazo_max_cred, iPeriodoPlazo, ccobro_comision_anual, scomi_gasto_cobranza, ccobro_comis_apertura,
			scomi_disposicion_efect, scomi_aclaracion_no, scomi_liquidacion_antic, pComision_Apertura, pComision_Gastos, pComision_Anualidad, pComision_Disposicion, pComision_Aclaracion,
			pComision_Liquidacion, sGarantias, sidgarantia, dporcentajeaforo, cobligado_solidario, cnum_obligados, ccaptura_obligatoria, dMontoMinDisp, dMontoMaxDisp,cformapli_comigascob,cformapli_comiaper,cformapli_comidispo,cformapli_comianual,cformapli_comiaclara,cformapli_comiliqant
			FROM "informix".tmp_sd_definicion WHERE usuario_insert = pUsuario;
		END IF;
		LET dporcentajeaforo = NVL(dporcentajeaforo,0);

		IF NVL(iexistTempCartcomp,0) >= 1 THEN
			SELECT pcuentas_medios, pcancelacion_inac, pcancelacion_vig, ptiempo_cancelar, pseguro_vida, pcobro_mensualidad, penvio_mesa_control, pid_domiciliacion, pconciliador, phistorico_cred,
			pperiodo_gracia, pdias_gracia, pcapital_interes, pintereses, pcapital, pestado_cuenta, pd_estadocuenta, pemision_estado_cuenta, prango_inicial, prango_final, pid_tipo_facturacion,
			pn_dias_facturacion, pdia_facturacion, prango_f_fecha_inic, prango_f_fecha_fin, pidcta_concentradora, pcta_concentradora,prangoini_gracia,prangofin_gracia
			INTO cCuentas_Medios, ccancelacion_inac, ccancelacion_vig, cTiempo_Cancelar, cseguro_vida, ccobro_mensualidad ,cenvio_mesa_control, cId_Domiciliacion, cConciliador, cHistorico_Cred,
			cperiodo_gracia, cdias_gracia, ccapital_interes,cintereses, ccapital, cestado_cuenta, cdesc_estadocuenta, cemision_estado_cuenta ,crango_inicial, crango_final, cid_tipo_facturacion,
			cn_dias_facturacion,cdia_facturacion,crango_f_fecha_inic, crango_f_fecha_fin ,cidcta_concentradora,ccta_concentradora,crangoini_gracia,crangofin_gracia
			FROM "informix".tmp_caracteristicas_complementarias
			WHERE usuario_insert = pUsuario;
		END IF;
		--Se obtiene el ID de estado de cuenta
		IF cdesc_estadocuenta = 'Tradicional' THEN
			LET cid_estadocuenta = '01';
		ELIF cdesc_estadocuenta = 'Revolvente' THEN
			LET cid_estadocuenta = '02';
		ELIF cdesc_estadocuenta = 'Periodo no facturacion' THEN
			LET cid_estadocuenta = '03';
		END IF;

		FOREACH
			SELECT id_facturacion, no_dias, dia_fijo, rgo_min, rgo_max
			INTO cid_tipo_facturacion, cn_dias_facturacion, cdia_facturacion, crango_f_fecha_inic, crango_f_fecha_fin
			FROM "informix".tmp_tipofacturacion
			--FacturaciÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ³n en caso de ser diferentes fechas
			--Guarda las caracteristicas de facturacion seleccionada por el usuario.
			IF cid_tipo_facturacion = '03' THEN
				INSERT INTO bdicred:"informix".sd_producto_facturacion (num_producto, id_facturacion, no_dias, dia_fijo, rgo_min, rgo_max)
				VALUES(cNum_Producto,cid_tipo_facturacion, cn_dias_facturacion, cdia_facturacion, crango_f_fecha_inic, crango_f_fecha_fin);
			END IF;

		END FOREACH;

		LET sdia_cuota = cdia_facturacion;

		LET cId_Domiciliacion = NVL(cId_Domiciliacion,'');

		IF cCuentas_Medios = '1' THEN
			LET cCuentas_Medios = 'S';
		ELSE
			LET cCuentas_Medios = 'N';
		END IF;
		-- Obtener inicial de Frecuencia de pago
		IF iPeriodoPlazo = 1 THEN
			LET cperiodo_plazo ='M';
		ELIF iPeriodoPlazo = 2 THEN
			LET cperiodo_plazo ='Q';
		ELIF iPeriodoPlazo = 1 THEN
			LET cperiodo_plazo ='S';
		ELIF iPeriodoPlazo = 5 THEN
			LET cperiodo_plazo ='V';
		END IF;

		IF cFamilia IN ('001') THEN
			LET ctp_solicitud				= 'T';
			LET ccod_tipcred 				= '03';
			LET idias_traspaso_int          = '60';
			LET idias_traspaso_cap          = '60';
			LET ccod_tasa_base 				= 'TASATC'||cSiglas;
			LET ccapitaliza                 = 'S';
			LET ccuenta_asosciada           = 'N';
			LET cactiva_calif               = '1';
			LET cprefijo_os                 = '1';
			LET sfactor_pago_min            = '9';
			LET smto_pago_min               = 200;
			LET dfact_pag_min_lc            = 0.0125;
			LET dfac_pagm_suma_sdo          = 0.015;
			LET ibandera_os                 = '1';
			LET cmsj_alta_movil             = '1';
			LET ccod_financiero             = '975';
			LET ctransacc_spei              = '8335';
			LET cind_disp_efec              = '1';
			LET cedocta_param 				= 'tdc';
		ELSE
			LET ctp_solicitud				= 'P';
			LET ccod_tipcred 				= '05';
			LET ctipo_calculo               =  '01';
			LET ctasa_fija_o_var            =  '1';
			LET ccod_tasa_base 				= 'TASAPR'||cSiglas;
			LET cperiod_pag_int             =  '2';
			LET cperiod_pago_cap            =  '3';
			LET idias_traspaso_int          =  '90';
			LET idias_traspaso_cap          =  '90';
			LET clleva_nombre               = 'S';
			LET cprefijo_os                 = '4';
			LET ccod_financiero             = '972';
			LET ctransacc_spei              = '8324';
			LET cedocta_param 				= 'prestamo_personal';
		END IF;

		IF isub_producto = 0 THEN
			-- Comision por gastos de cobranza
			IF scomi_gasto_cobranza IN (1) THEN
				LET ccod_comi_gasto_cobranza = 'CG'||cSiglas;
				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_gasto_cobranza;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comigascob = '1' THEN
						UPDATE "informix".sd_tpcomis SET monto = pComision_Gastos WHERE cod_comis = ccod_comi_gasto_cobranza;
					ELIF cformapli_comigascob = '2' THEN
						UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Gastos WHERE cod_comis = ccod_comi_gasto_cobranza;
					END IF;
				ELSE
					LET cdesc_comisgastoscob = 'COMISION POR GASTOS COBRANZA ' || ccod_comi_gasto_cobranza;

					IF cformapli_comigascob = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_gasto_cobranza, '1', '01', '06', cdesc_comisgastoscob, '1', pComision_Gastos, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comigascob = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_gasto_cobranza, '1', '01', '06', cdesc_comisgastoscob, '2', 0, pComision_Gastos, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					END IF;
				END IF;
			END IF;

			-- Comision por Anualidad
			IF ccobro_comision_anual IN (1) THEN
				LET iexiste = 0;
				LET ccod_comision_anualidad = 'CA'||cSiglas;
				IF cNum_Producto = '6001' THEN
					LET ccod_comision_anualidad = 'CAVT';
				ELIF cNum_Producto = '8100' THEN
					LET ccod_comision_anualidad = 'CAOT';
				ELIF cNum_Producto = '7000' THEN
					LET ccod_comision_anualidad = 'CAPT';
				ELIF cNum_Producto = '8500' THEN
					LET ccod_comision_anualidad = 'CATG';
				END IF;

				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_anualidad;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comianual = '1' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Anualidad WHERE cod_comis = ccod_comision_anualidad;
					ELIF cformapli_comianual = '2' THEN
						UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Anualidad WHERE cod_comis = ccod_comision_anualidad;
					END IF;
				ELSE
					LET cdesc_cobro_comision_anual = 'COMISION POR ANUALIDAD ' || ccod_comision_anualidad;
					IF cformapli_comianual = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_anualidad, '1', '01', '06', cdesc_cobro_comision_anual, '1', pComision_Anualidad, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comianual = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_anualidad, '1', '01', '06', cdesc_cobro_comision_anual, '2', 0, pComision_Anualidad, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					END IF;
				END IF;
			END IF;
			-- Comision por disposicion de Efectivo
			IF scomi_disposicion_efect IN (1) THEN
				LET ccod_comision_efectivo = 'CE'||cSiglas;
				LET iexiste = 0;
				IF cNum_Producto = '6001' THEN
					LET ccod_comision_efectivo = 'CETC';
				ELIF cNum_Producto = '8100' THEN
					LET ccod_comision_efectivo = 'CETO';
				ELIF cNum_Producto = '7000' THEN
					LET ccod_comision_efectivo = 'CETP';
				ELIF cNum_Producto = '8500' THEN
					LET ccod_comision_efectivo = 'CEGC';
				ELIF cNum_Producto = '6600' THEN
					LET ccod_comision_efectivo = 'CETB';
				END IF;

				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_efectivo;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comidispo = '1' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Disposicion WHERE cod_comis = ccod_comision_efectivo;
					ELIF cformapli_comidispo = '2' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET apli_factor = pComision_Disposicion WHERE cod_comis = ccod_comision_efectivo;
					END IF;
				ELSE
					LET cdesc_comidisposicion= 'COMISION POR DISPOSICION ' || ccod_comision_efectivo;
					IF cformapli_comidispo = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_efectivo, '1', '01', '06', cdesc_comidisposicion, '1', pComision_Disposicion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comidispo = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_efectivo, '1', '01', '06', cdesc_comidisposicion, '2', 0, pComision_Disposicion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');

					END IF;
				END IF;

			END IF;
			-- Comision por aclaracion no procedente
			IF scomi_aclaracion_no IN (1) THEN
				LET ccod_comi_aclaracion_no = 'CN'||cSiglas;
				LET iexiste = 0;

				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_aclaracion_no;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comiaclara = '1' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Aclaracion WHERE cod_comis = ccod_comi_aclaracion_no;
					ELIF cformapli_comiaclara = '2' THEN
						UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Aclaracion WHERE cod_comis = ccod_comi_aclaracion_no;
					END IF;
				ELSE
					LET cdesc_Cod_Com_Aclaracion= 'COMISION POR ACLARACION ' || ccod_comi_aclaracion_no;
					IF cformapli_comiaclara = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_aclaracion_no, '1', '01', '06', cdesc_Cod_Com_Aclaracion, '1', pComision_Aclaracion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comiaclara = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_aclaracion_no, '1', '01', '06', cdesc_Cod_Com_Aclaracion, '2', 0, pComision_Aclaracion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					END IF;
				END IF;
			END IF;
			-- Comision por liquidacion anticipada
			IF scomi_liquidacion_antic IN (1) THEN
				LET ccod_comi_liquidacion_antic = 'CL'||cSiglas;
				LET iexiste = 0;

				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_liquidacion_antic;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comiliqant = '1' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Liquidacion WHERE cod_comis = ccod_comi_liquidacion_antic;
					ELIF cformapli_comiliqant = '2' THEN
						UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Liquidacion WHERE cod_comis = ccod_comi_liquidacion_antic;
					END IF;
				ELSE
					LET cdesc_Cod_Com_Liquidacion= 'COMISION POR LIQUIDACION ANTICIPADA ' || ccod_comi_liquidacion_antic;
					IF cformapli_comiliqant = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_liquidacion_antic, '1', '01', '06', cdesc_Cod_Com_Liquidacion, '1', pComision_Liquidacion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comiliqant = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comi_liquidacion_antic, '1', '01', '06', cdesc_Cod_Com_Liquidacion, '2', 0, pComision_Liquidacion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					END IF;
				END IF;
			END IF;
			-- Comision por Apertura
			IF ccobro_comis_apertura IN (1) THEN
				LET ccod_comision_apertura = 'CP'||cSiglas;
				IF cNum_Producto = '6001' THEN
					LET ccod_comision_apertura = '8071';
				END IF;

				SELECT count(cod_comis) INTO iexiste
				FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_apertura;

				IF NVL(iexiste,0) >= 1 THEN
					IF cformapli_comiaper = '1' THEN
						UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Apertura WHERE cod_comis = ccod_comision_apertura;
					ELIF cformapli_comiaper = '2' THEN
						UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Apertura WHERE cod_comis = ccod_comision_apertura;
					END IF;
				ELSE
					LET cdesc_comision_apertura= 'COMISION POR APERTURA ' || ccod_comision_apertura;
					IF cformapli_comiaper = '1' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_apertura, '1', '01', '06', cdesc_comision_apertura, '1', pComision_Apertura, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					ELIF cformapli_comiaper = '2' THEN
						INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
						VALUES(cEmpresa, ccod_comision_apertura, '1', '01', '06', cdesc_comision_apertura, '2', 0, pComision_Apertura, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
					END IF;
				END IF;
			END IF;
			

			SELECT count(*)
			INTO bExisteProd
			FROM bdicred:"informix".sd_definicion
			WHERE num_producto = cNum_Producto;

			IF NVL(bExisteProd,0) >= 1 THEN
				IF NVL(iexistTempCartprin,0) >=1 THEN
					UPDATE "informix".sd_definicion
					SET monto_min_cred=dMonto_Min_Cred, monto_max_cred=dMonto_Max_Cred, edad_min=sEdad_Minima, edad_max=sEdad_Maxima, periodo_plazo= cperiodo_plazo, plazo_min_cred=iplazo_min_cred,
					plazo_max_cred=iplazo_max_cred, f_modifica_montos=CURRENT, cobro_comision_anual=ccobro_comision_anual, cobro_anual_titular=ccobro_comision_anual,
					comi_disposicion_efect=scomi_disposicion_efect,cod_comision_efectivo=ccod_comision_efectivo, cobro_comis_apertura=ccobro_comis_apertura, cod_comision_apertura=ccod_comision_apertura,
					cod_comision_anualidad=ccod_comision_anualidad, comi_aclaracion_no=scomi_aclaracion_no, cod_comi_aclaracion_no=ccod_comi_aclaracion_no, comi_liquidacion_antic= scomi_liquidacion_antic,
					cod_comi_liquidacion_antic=ccod_comi_liquidacion_antic,comi_gasto_cobranza = scomi_gasto_cobranza,cod_comi_gasto_cobranza = ccod_comi_gasto_cobranza,plazo_linea=cTiempo_Cancelar,
					edocta_param=cedocta_param, obligado_solidario  = cobligado_solidario, num_obligados = cNum_Obligados,captura_obligatoria = ccaptura_obligatoria,
					garantias = sGarantias,idgarantia = sidgarantia, porcentajeaforo = dporcentajeaforo, monto_max_disp = dMontoMaxDisp, monto_min_disp = dMontoMinDisp
					WHERE num_producto = cNum_Producto;
				END IF;
				IF NVL(iexistTempCartcomp,0) >= 1 THEN
					UPDATE "informix".sd_definicion
					SET	cuentas_medios=cCuentas_Medios, cancelacion_inac= ccancelacion_inac, cancelacion_vig= ccancelacion_vig,seguro_vida=cseguro_vida,cobro_mensualidad =ccobro_mensualidad,
					envio_mesa_control=cenvio_mesa_control, id_domiciliacion= cId_Domiciliacion, conciliador=cConciliador, historico_cred=cHistorico_Cred, periodo_gracia=cperiodo_gracia, dias_gracia=cdias_gracia,
					capital_interes=ccapital_interes,intereses=cintereses,capital = ccapital, estado_cuenta=cestado_cuenta, id_estadocuenta=cid_estadocuenta, emision_estado_cuenta=cemision_estado_cuenta ,
					rango_inicial=crango_inicial, rango_final=crango_final, id_tipo_facturacion=cid_tipo_facturacion,n_dias_facturacion=cn_dias_facturacion,dia_facturacion=cdia_facturacion,
					rango_f_fecha_inic=crango_f_fecha_inic, rango_f_fecha_fin = crango_f_fecha_fin ,idcta_concentradora=cidcta_concentradora,cta_concentradora=ccta_concentradora, rangoini_gracia=crangoini_gracia, rangofin_gracia=crangofin_gracia
					WHERE num_producto = cNum_Producto;
				END IF;

			ELSE
				-- VALIDACION E INSERCION DE sd_definicion
				INSERT INTO bdicred:"informix".sd_definicion(empresa, num_producto, cod_tipcred, nombre_prod, monto_min_cred, monto_max_cred, edad_min, edad_max, divisa, se_valoriza, tipo_calculo, tasa_fija_o_var, cod_tasa_base, sobretasa, factor_sobretasa, tipo_refinanc, porcent_refinanc, pago_adic_sig_cuo, period_pag_int, period_pago_cap, dias_traspaso_int, dias_traspaso_cap, periodo_plazo, plazo_min_cred, plazo_max_cred, tasa_mora_adic, cod_tasa_mora, fact_sobret_mora, sobretasa_mora, factor_moratorio, rev_tasa_var_per, dia_para_revisar, preautoriza, tasa_base_piso, sobretasa_piso, factor_piso, tasa_piso, tasa_base_techo, sobretasa_techo, factor_techo, tasa_techo, band_prod, cod_prod, tpo_persona, tipo_cliente, segmentado, por_acciones, maneja_linea, maneja_mora, maneja_pago_sost, capitaliza, cuenta_asosciada, llena_solicitud, lleva_nombre, dia_cuota, gracia_calc_mora, user_insert, fecha_insert, cat_edocta, cat_caratula, activa_calif, siglas, ind_comision, tran_comision, prefijo_os, rechazo_rgc, f_modifica_montos, monto_min_disp,  monto_max_disp ,factor_pago_min, mto_pago_min, fact_pag_min_lc, fac_pagm_suma_sdo, flag_arbol, realizar_convenio, cobro_comision_anual, cobro_anual_titular, cobro_anual_adicional, fecha_1er_cobro_anual, cobro_parcializ_anual, cod_comision_efectivo, cobro_comis_apertura, cod_comision_apertura, cod_comision_anualidad, cat_comi_anual_adicional, bandera_os, plazo_linea , edocta_param, cod_rep_rob, cod_rep_ext, cod_rep_danmal, cod_rep_acl, cod_rep_ven, cod_rep_pet, id_domiciliacion, id_tasa_pref, puntos_tasa_pref, cat_edc_com_anualidad, id_excluye_os, msj_alta_movil, cod_financiero, transacc_spei, dias_cobro_aut, reporte_cartera, link_carta, link_carta_activo,valida_sms,ind_disp_efec,oferta_emp, familia, obligado_solidario, num_obligados, captura_obligatoria, conciliador, historico_cred, comi_gasto_cobranza, cod_comi_gasto_cobranza, comi_aclaracion_no, cod_comi_aclaracion_no, comi_liquidacion_antic, cod_comi_liquidacion_antic, garantias, idgarantia, porcentajeaforo  , cancelacion_inac, cancelacion_vig, seguro_vida, periodo_gracia, dias_gracia, comi_disposicion_efect, cuentas_medios, tiempo_cancelar, cobro_mensualidad, envio_mesa_control, capital_interes, intereses, capital,estado_cuenta,id_estadocuenta,emision_estado_cuenta,rango_inicial,rango_final,id_tipo_facturacion,n_dias_facturacion,dia_facturacion,rango_f_fecha_inic,rango_f_fecha_fin, idcta_concentradora,cta_concentradora,rangoini_gracia,rangofin_gracia)
				 VALUES(cEmpresa,cNum_Producto,ccod_tipcred,cNomb_Producto,dMonto_Min_Cred,dMonto_Max_Cred,sEdad_Minima,sEdad_Maxima,cdivisa,cse_valoriza,ctipo_calculo,ctasa_fija_o_var,ccod_tasa_base,dsobretasa,cfactor_sobretasa,ctipo_refinanc,dporcent_refinanc,cpago_adic_sig_cuo ,cperiod_pag_int ,cperiod_pago_cap,idias_traspaso_int ,idias_traspaso_cap ,cperiodo_plazo,iplazo_min_cred ,iplazo_max_cred ,ctasa_mora_adic ,ccod_tasa_mora,cfact_sobret_mora,dsobretasa_mora ,dfactor_moratorio,crev_tasa_var_per,idia_para_revisar,cpreautoriza,ctasa_base_piso ,dsobretasa_piso ,cfactor_piso,dtasa_piso,ctasa_base_techo,dsobretasa_techo,cfactor_techo,dtasa_techo ,cband_prod,ccod_prod ,ctpo_persona,ctipo_cliente,csegmentado ,dpor_acciones,cmaneja_linea,cmaneja_mora,cmaneja_pago_sost,ccapitaliza ,ccuenta_asosciada,cllena_solicitud,clleva_nombre,sdia_cuota,sgracia_calc_mora,cuser_insert,dfecha_insert,dcat_edocta ,dcat_caratula,cactiva_calif,csiglas,cind_comision,ctran_comision,cprefijo_os ,crechazo_rgc,df_modifica_montos, dMontoMinDisp ,dMontoMaxDisp,sfactor_pago_min,smto_pago_min,dfact_pag_min_lc,dfac_pagm_suma_sdo ,sflag_arbol ,crealizar_convenio ,ccobro_comision_anual  ,ccobro_anual_titular,ccobro_anual_adicional ,cfecha_1er_cobro_anual ,ccobro_parcializ_anual ,ccod_comision_efectivo ,ccobro_comis_apertura  ,ccod_comision_apertura ,ccod_comision_anualidad,ccat_comi_anual_adicional,ibandera_os ,iplazo_linea,cedocta_param,ccod_rep_rob,ccod_rep_ext,ccod_rep_danmal ,ccod_rep_acl,ccod_rep_ven,ccod_rep_pet,cid_domiciliacion,cid_tasa_pref,dpuntos_tasa_pref,ccat_edc_com_anualidad ,cid_excluye_os,cmsj_alta_movil ,ccod_financiero ,ctransacc_spei,idias_cobro_aut ,sreporte_cartera,vlink_carta ,clink_carta_activo ,cvalida_sms ,cind_disp_efec,coferta_emp ,cfamilia  ,cobligado_solidario,cnum_obligados,ccaptura_obligatoria,cconciliador,chistorico_cred ,scomi_gasto_cobranza,ccod_comi_gasto_cobranza ,scomi_aclaracion_no,ccod_comi_aclaracion_no,scomi_liquidacion_antic,ccod_comi_liquidacion_antic,sgarantias,sidgarantia ,dporcentajeaforo,ccancelacion_inac,ccancelacion_vig,cseguro_vida,cperiodo_gracia ,cdias_gracia,scomi_disposicion_efect,ccuentas_medios ,ctiempo_cancelar,ccobro_mensualidad ,cenvio_mesa_control,ccapital_interes,cintereses,ccapital,cestado_cuenta,cid_estadocuenta,cemision_estado_cuenta ,crango_inicial,crango_final,cid_tipo_facturacion,cn_dias_facturacion,cdia_facturacion,crango_f_fecha_inic,crango_f_fecha_fin,cidcta_concentradora,ccta_concentradora,crangoini_gracia,crangofin_gracia);

				--Insertar el tipo de producto
				INSERT INTO "informix".sd_tipprod(empresa, cod_prod, descrip_prod, abrevia_prod)
				  VALUES(cEmpresa, ctp_solicitud , cNomb_Producto, cNum_Producto);

				--Insertar Producto y secuencia
				INSERT INTO bdisolic:"informix".ss_solic_producto(empresa, tp_solicitud, num_producto, secuencia_prod, prefijo_sol)
				VALUES (cEmpresa, ctp_solicitud, cNum_producto, 0, csiglas);

				 --Inserta puestos y tipo de ejecutivo para el producto
				SELECT count(*)
				INTO bExisteProd
				FROM bdinteg:"informix".si_prod_ejecut
				WHERE num_producto = cNum_Producto;
				IF bExisteProd = 0 THEN
					INSERT INTO bdinteg:"informix".si_prod_ejecut(empresa, puesto, perfil, num_producto, sistema, user_insert, fecha_insert)
					  VALUES(cEmpresa, '001', 'A ', cNum_Producto, '06',cuser_insert, dfecha_insert );
					INSERT INTO bdinteg:"informix".si_prod_ejecut(empresa, puesto, perfil, num_producto, sistema, user_insert, fecha_insert)
					  VALUES(cEmpresa, '003', 'E ', cNum_Producto, '06',cuser_insert, dfecha_insert );
					INSERT INTO bdinteg:"informix".si_prod_ejecut(empresa, puesto, perfil, num_producto, sistema, user_insert, fecha_insert)
					  VALUES(cEmpresa, '008', 'U ', cNum_Producto, '01',cuser_insert, dfecha_insert );
				END IF;

				IF cFamilia IN ('001') THEN
					--Inserta registro de producto para que oferte productos segÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂºn la opciÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ³n Efectivo o Compras
					INSERT INTO bdisolic:"informix".ss_cat_prod_ofrecer(empresa, producto, ejecucion)
						VALUES(cEmpresa, cNum_Producto, '2');

					--Inserta registro de producto por plazo vigencia de os calle
					insert into bdisolic:"informix".ss_oscalle_plazovigencia
					select cNum_Producto,resp_oscalle,dias_vigencia from bdisolic:"informix".ss_oscalle_plazovigencia where clave_producto = '6001';
					insert into bdisolic:"informix".ss_oscalle_vigencia(clave_producto,descripcion,vigrespos_oferta,vigencia_os) values (cNum_Producto,cNomb_Producto,'1','1');

					--Inserta registro por sucursal del control parametricos
					INSERT INTO bdisolic:"informix".ss_control_parametricos
					SELECT empresa,cNum_Producto,sucursal,num_parametrico, descripcion,cuser_insert, dfecha_insert FROM bdisolic:"informix".ss_control_parametricos where num_producto = '6001';

					--Registro para el envÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ­o a Buro de CrÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ©dito

					INSERT INTO bdiburo:"informix".br_tltco(num_producto,codigo,descripcion,status_cons) VALUES(cNum_Producto,'CC',cNomb_Producto,'0');

					INSERT INTO bdisolic:"informix".ss_vigencia_sol_productos(empresa, num_producto, status_solicitud, status_solicitud_final, causa_solicitud, descripcion, dias_vigencia, fecha_insert)
 					SELECT empresa,cNum_Producto, status_solicitud, status_solicitud_final, causa_solicitud, descripcion, dias_vigencia, dfecha_insert
					FROM bdisolic:"informix".ss_vigencia_sol_productos where num_producto = '6300';

					--Insertar los estatus validos para el producto nuevo
					INSERT INTO bdisolic:"informix".ss_prod_aplica(empresa, producto, estatus_aplica, user_insert, fecha_insert)
					SELECT empresa, cNum_producto, estatus_aplica, cuser_insert, dfecha_insert FROM bdisolic:"informix".ss_prod_aplica WHERE producto ='6001';

					--Insertar registro de producto para activarse por sucursal , se debe activar por medio de la funcionalidad de SOC de operaciones
					 --INSERT INTO bdinteg:"informix".si_prod_sucursal(empresa, sucursal, num_producto, sistema)
					 --SELECT empresa, sucursal, cNum_producto, sistema from bdinteg:"informix".si_prod_sucursal WHERE num_producto ='6001';
				ELSE
					--Inserta registro de producto para que oferte productos segÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂºn la opciÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ³n Efectivo o Compras
					INSERT INTO bdisolic:"informix".ss_cat_prod_ofrecer(empresa, producto, ejecucion)
						VALUES(cEmpresa, cNum_Producto, '1');
					--Inserta registro de producto por plazo vigencia de os calle
					insert into bdisolic:"informix".ss_oscalle_plazovigencia
					select cNum_Producto,resp_oscalle,dias_vigencia from bdisolic:"informix".ss_oscalle_plazovigencia where clave_producto = '6300';
					insert into bdisolic:"informix".ss_oscalle_vigencia(clave_producto,descripcion,vigrespos_oferta,vigencia_os) values (cNum_Producto,cNomb_Producto,'1','1');

					--Inserta registro por sucursal del control parametricos
					INSERT INTO bdisolic:"informix".ss_control_parametricos
					SELECT empresa,cNum_Producto,sucursal,num_parametrico, descripcion,cuser_insert, dfecha_insert
					FROM bdisolic:"informix".ss_control_parametricos where num_producto = '6300';

					INSERT INTO bdisolic:"informix".ss_vigencia_sol_productos(empresa, num_producto, status_solicitud, status_solicitud_final, causa_solicitud, descripcion, dias_vigencia, fecha_insert)
 					SELECT empresa,cNum_Producto, status_solicitud, status_solicitud_final, causa_solicitud, descripcion, dias_vigencia, dfecha_insert
					FROM bdisolic:"informix".ss_vigencia_sol_productos where num_producto = '6300';

					--Registro para el envio a Buro de Credito
					INSERT INTO bdiburo:"informix".br_tltco(num_producto,codigo,descripcion,status_cons) VALUES(cNum_Producto,'PL',cNomb_Producto,'0');

					IF cFamilia IN ('002') THEN
						--Insertar los estatus validos para el producto nuevo
						INSERT INTO bdisolic:"informix".ss_prod_aplica(empresa, producto, estatus_aplica, user_insert, fecha_insert)
						SELECT empresa, cNum_producto, estatus_aplica, cuser_insert, dfecha_insert  FROM bdisolic:"informix".ss_prod_aplica WHERE producto ='6300';
					ELSE
						--Insertar los estatus validos para el producto nuevo
						INSERT INTO bdisolic:"informix".ss_prod_aplica(empresa, producto, estatus_aplica, user_insert, fecha_insert)
						SELECT empresa, cNum_producto, estatus_aplica, cuser_insert, dfecha_insert  FROM bdisolic:"informix".ss_prod_aplica WHERE producto ='6800';
					END IF;

					--Insertar registro de producto para activarse por sucursal , se debe activar por medio de la funcionalidad de SOC de operaciones
					 --INSERT INTO bdinteg:"informix".si_prod_sucursal(empresa, sucursal, num_producto, sistema)
					 --SELECT empresa, sucursal, cNum_producto, sistema from bdinteg:"informix".si_prod_sucursal WHERE num_producto ='6300';
				END IF;

				--Registro de parametro si hay envio a Mesa de Control
				IF cenvio_mesa_control = '1' THEN
					SELECT MAX(secuencia) INTO icodparam FROM bdisolic:"informix".ss_param;
					LET icodparamMC = icodparam + 1;
					LET cdescparamMC = 'Productos a enviar a MC';
					INSERT INTO bdisolic:"informix".ss_param(empresa, secuencia, descripcion, valor, user_insert, fecha_insert)
					VALUES(cEmpresa,icodparamMC,cdescparamMC,cNum_Producto, cuser_insert, dfecha_insert);
					IF cFamilia IN ('001') THEN
						INSERT INTO bdicnweb:"informix".sw_mc_idproducto(cve_producto, id_panel, id_funcion, estatus)
						  VALUES(cNum_Producto, 'DATOS_SCORING                      ', '2 ', '1');
						INSERT INTO bdicnweb:"informix".sw_mc_idproducto(cve_producto, id_panel, id_funcion, estatus)
						  VALUES(cNum_Producto, 'DETERMINACION                      ', '4 ', '1');
					ELSE
						INSERT INTO bdicnweb:"informix".sw_mc_idproducto(cve_producto, id_panel, id_funcion, estatus)
						  VALUES(cNum_Producto, 'DATOS_SCORING                      ', '2 ', '1');
						INSERT INTO bdicnweb:"informix".sw_mc_idproducto( cve_producto, id_panel, id_funcion, estatus)
						  VALUES(cNum_Producto, 'DETERMINACION                      ', '3 ', '1');
					END IF;

				END IF;
				--INSERT INTO "informix".ss_param VALUES('001',391,'Monto Minimo Solicitud PPF',1000,'informix',today); Modificar donde se encuentre este parametro
				--INSERT INTO "informix".ss_param VALUES('001',392,'Ejecutivo PPF via SMS','FLEX_SMS','informix',today);


			END IF;

			SELECT count(valor) INTO iexiste
			FROM "informix".tmp_sd_frectipopago WHERE num_producto = cNum_Producto;
			IF NVL(iexiste,0) >= 1 THEN
				DELETE FROM "informix".sd_frectipopago
				WHERE num_producto = cNum_Producto;

				FOREACH
					SELECT valor,tipo_pago
					INTO iperplazo,ctpo_pago
					FROM "informix".tmp_sd_frectipopago WHERE num_producto = cNum_Producto

					INSERT INTO "informix".sd_frectipopago(valor, tipo_pago, num_producto)
					VALUES(iperplazo, ctpo_pago, cNum_Producto);
				END FOREACH;
			END IF;

		ELSE
			SELECT count(*)
			INTO bExisteProd
			FROM bdicred:"informix".sd_subproducto
			WHERE num_producto = cNum_Producto AND id_subproducto=isub_producto;

			IF NVL(bExisteProd,0) >= 1 THEN





















				IF LENGTH(isub_producto::VARCHAR(2)) < 2 THEN
					LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), CONCAT('0',isub_producto));
					LET cAuxId_subproducto2 = CONCAT('0',isub_producto);
				ELSE
					LET cAuxId_subproducto = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), isub_producto);
					LET cAuxId_subproducto2 = CONCAT(isub_producto);
				END IF;

				-- Comision por gastos de cobranza subproducto
				IF scomi_gasto_cobranza IN (1) THEN
					LET ccod_comi_gasto_cobranza = 'CG'||cAuxId_subproducto2;
					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_gasto_cobranza;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comigascob = '1' THEN
							UPDATE "informix".sd_tpcomis SET monto = pComision_Gastos WHERE cod_comis = ccod_comi_gasto_cobranza;
						ELIF cformapli_comigascob = '2' THEN
							UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Gastos WHERE cod_comis = ccod_comi_gasto_cobranza;
						END IF;
					ELSE
						LET cdesc_comisgastoscob = 'COMISION POR GASTOS COBRANZA ' || ccod_comi_gasto_cobranza;

						IF cformapli_comigascob = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_gasto_cobranza, '1', '01', '06', cdesc_comisgastoscob, '1', pComision_Gastos, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comigascob = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_gasto_cobranza, '1', '01', '06', cdesc_comisgastoscob, '2', 0, pComision_Gastos, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						END IF;
					END IF;
				END IF;

				-- Comision por Anualidad subproducto
				IF ccobro_comision_anual IN (1) THEN
					LET iexiste = 0;
					LET ccod_comision_anualidad = 'CA'||cAuxId_subproducto2;
					IF cNum_Producto = '6001' THEN
						LET ccod_comision_anualidad = 'CAVT';
					ELIF cNum_Producto = '8100' THEN
						LET ccod_comision_anualidad = 'CAOT';
					ELIF cNum_Producto = '7000' THEN
						LET ccod_comision_anualidad = 'CAPT';
					ELIF cNum_Producto = '8500' THEN
						LET ccod_comision_anualidad = 'CATG';
					END IF;

					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_anualidad;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comianual = '1' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Anualidad WHERE cod_comis = ccod_comision_anualidad;
						ELIF cformapli_comianual = '2' THEN
							UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Anualidad WHERE cod_comis = ccod_comision_anualidad;
						END IF;
					ELSE
						LET cdesc_cobro_comision_anual = 'COMISION POR ANUALIDAD ' || ccod_comision_anualidad;
						IF cformapli_comianual = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_anualidad, '1', '01', '06', cdesc_cobro_comision_anual, '1', pComision_Anualidad, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comianual = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_anualidad, '1', '01', '06', cdesc_cobro_comision_anual, '2', 0, pComision_Anualidad, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						END IF;
					END IF;
				END IF;
				-- Comision por disposicion de efectivo subproducto
				IF scomi_disposicion_efect IN (1) THEN
					LET ccod_comision_efectivo = 'CE'||cAuxId_subproducto2;
					LET iexiste = 0;
					IF cNum_Producto = '6001' THEN
						LET ccod_comision_efectivo = 'CETC';
					ELIF cNum_Producto = '8100' THEN
						LET ccod_comision_efectivo = 'CETO';
					ELIF cNum_Producto = '7000' THEN
						LET ccod_comision_efectivo = 'CETP';
					ELIF cNum_Producto = '8500' THEN
						LET ccod_comision_efectivo = 'CEGC';
					ELIF cNum_Producto = '6600' THEN
						LET ccod_comision_efectivo = 'CETB';
					END IF;

					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_efectivo;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comidispo = '1' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Disposicion WHERE cod_comis = ccod_comision_efectivo;
						ELIF cformapli_comidispo = '2' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET apli_factor = pComision_Disposicion WHERE cod_comis = ccod_comision_efectivo;
						END IF;
					ELSE
						LET cdesc_comidisposicion= 'COMISION POR DISPOSICION ' || ccod_comision_efectivo;
						IF cformapli_comidispo = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_efectivo, '1', '01', '06', cdesc_comidisposicion, '1', pComision_Disposicion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comidispo = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_efectivo, '1', '01', '06', cdesc_comidisposicion, '2', 0, pComision_Disposicion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');

						END IF;
					END IF;

				END IF;
				-- Comision por aclaracion no procedente subproducto
				IF scomi_aclaracion_no IN (1) THEN
					LET ccod_comi_aclaracion_no = 'CN'||cAuxId_subproducto2;
					LET iexiste = 0;

					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_aclaracion_no;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comiaclara = '1' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Aclaracion WHERE cod_comis = ccod_comi_aclaracion_no;
						ELIF cformapli_comiaclara = '2' THEN
							UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Aclaracion WHERE cod_comis = ccod_comi_aclaracion_no;
						END IF;
					ELSE
						LET cdesc_Cod_Com_Aclaracion= 'COMISION POR ACLARACION ' || ccod_comi_aclaracion_no;
						IF cformapli_comiaclara = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_aclaracion_no, '1', '01', '06', cdesc_Cod_Com_Aclaracion, '1', pComision_Aclaracion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comiaclara = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_aclaracion_no, '1', '01', '06', cdesc_Cod_Com_Aclaracion, '2', 0, pComision_Aclaracion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						END IF;
					END IF;
				END IF;
				-- Comision por liquidacion anticipada subproducto
				IF scomi_liquidacion_antic IN (1) THEN
					LET ccod_comi_liquidacion_antic = 'CL'||cAuxId_subproducto2;
					LET iexiste = 0;

					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comi_liquidacion_antic;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comiliqant = '1' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Liquidacion WHERE cod_comis = ccod_comi_liquidacion_antic;
						ELIF cformapli_comiliqant = '2' THEN
							UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Liquidacion WHERE cod_comis = ccod_comi_liquidacion_antic;
						END IF;
					ELSE
						LET cdesc_Cod_Com_Liquidacion= 'COMISION POR LIQUIDACION ANTICIPADA ' || ccod_comi_liquidacion_antic;
						IF cformapli_comiliqant = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_liquidacion_antic, '1', '01', '06', cdesc_Cod_Com_Liquidacion, '1', pComision_Liquidacion, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comiliqant = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comi_liquidacion_antic, '1', '01', '06', cdesc_Cod_Com_Liquidacion, '2', 0, pComision_Liquidacion, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						END IF;
					END IF;
				END IF;
				-- Comision por Apertura subproducto
				IF ccobro_comis_apertura IN (1) THEN
					LET ccod_comision_apertura = 'CP'||cAuxId_subproducto2;
					LET iexiste = 0;
					IF cNum_Producto = '6001' THEN
						LET ccod_comision_apertura = '8071';
					END IF;

					SELECT count(cod_comis) INTO iexiste
					FROM bdicred:"informix".sd_tpcomis WHERE cod_comis = ccod_comision_apertura;

					IF NVL(iexiste,0) >= 1 THEN
						IF cformapli_comiaper = '1' THEN
							UPDATE bdicred:"informix".sd_tpcomis SET monto = pComision_Apertura WHERE cod_comis = ccod_comision_apertura;
						ELIF cformapli_comiaper = '2' THEN
							UPDATE "informix".sd_tpcomis SET apli_factor = pComision_Apertura WHERE cod_comis = ccod_comision_apertura;
						END IF;
					ELSE
						LET cdesc_comision_apertura= 'COMISION POR APERTURA ' || ccod_comision_apertura;
						IF cformapli_comiaper = '1' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_apertura, '1', '01', '06', cdesc_comision_apertura, '1', pComision_Apertura, 0.000000, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						ELIF cformapli_comiaper = '2' THEN
							INSERT INTO bdicred:"informix".sd_tpcomis(empresa, cod_comis, comi_o_seg, divisa, evento, nombre_com, form_aplica, monto, apli_factor, consi_rango, monto_min, monto_max, genera_imp, codfun_imp, codref_imp, se_prorratea, por_producto)
							VALUES(cEmpresa, ccod_comision_apertura, '1', '01', '06', cdesc_comision_apertura, '2', 0, pComision_Apertura, '@', 0.00, 0.00, '@', '000', NULL, '2', '2');
						END IF;
					END IF;
				END IF;
				
				IF NVL(iexistTempCartprin,0) >=1 THEN
					UPDATE bdicred:"informix".sd_subproducto
					SET monto_min_cred=dMonto_Min_Cred, monto_max_cred=dMonto_Max_Cred, edad_min=sEdad_Minima, edad_max=sEdad_Maxima, periodo_plazo= cperiodo_plazo, plazo_min_cred=iplazo_min_cred,
					plazo_max_cred=iplazo_max_cred, f_modifica_montos=CURRENT, cobro_comision_anual=ccobro_comision_anual, cobro_anual_titular=ccobro_comision_anual,
					comi_disposicion_efect=scomi_disposicion_efect,cod_comision_efectivo=ccod_comision_efectivo, cobro_comis_apertura=ccobro_comis_apertura, cod_comision_apertura=ccod_comision_apertura,
					cod_comision_anualidad=ccod_comision_anualidad, comi_aclaracion_no=scomi_aclaracion_no, cod_comi_aclaracion_no=ccod_comi_aclaracion_no, comi_liquidacion_antic= scomi_liquidacion_antic,
					cod_comi_liquidacion_antic=ccod_comi_liquidacion_antic,comi_gasto_cobranza = scomi_gasto_cobranza,cod_comi_gasto_cobranza = ccod_comi_gasto_cobranza,plazo_linea=cTiempo_Cancelar,
					edocta_param=cedocta_param, obligado_solidario  = cobligado_solidario, num_obligados = cNum_Obligados,captura_obligatoria = ccaptura_obligatoria,
					garantias = sGarantias,idgarantia = sidgarantia, porcentajeaforo = dporcentajeaforo, monto_max_disp = dMontoMaxDisp, monto_min_disp = dMontoMinDisp
					WHERE num_producto = cNum_Producto AND id_subproducto = isub_producto;
				END IF;
				IF NVL(iexistTempCartcomp,0) >= 1 THEN
					UPDATE bdicred:"informix".sd_subproducto
					SET	cuentas_medios=cCuentas_Medios, cancelacion_inac= ccancelacion_inac, cancelacion_vig= ccancelacion_vig,seguro_vida=cseguro_vida,cobro_mensualidad =ccobro_mensualidad,
					envio_mesa_control=cenvio_mesa_control, id_domiciliacion= cId_Domiciliacion, conciliador=cConciliador, historico_cred=cHistorico_Cred, periodo_gracia=cperiodo_gracia, dias_gracia=cdias_gracia,
					capital_interes=ccapital_interes,intereses=cintereses,capital = ccapital, estado_cuenta=cestado_cuenta, id_estadocuenta=cid_estadocuenta, emision_estado_cuenta=cemision_estado_cuenta ,
					rango_inicial=crango_inicial, rango_final=crango_final, id_tipo_facturacion=cid_tipo_facturacion,n_dias_facturacion=cn_dias_facturacion,dia_facturacion=cdia_facturacion,
					rango_f_fecha_inic=crango_f_fecha_inic, rango_f_fecha_fin = crango_f_fecha_fin ,idcta_concentradora=cidcta_concentradora,cta_concentradora=ccta_concentradora,rangoini_gracia=crangoini_gracia,rangofin_gracia=crangofin_gracia
					WHERE num_producto = cNum_Producto AND id_subproducto = isub_producto;
				END IF;

				-- Se eliminan y se registran las frecuencias de pago existentes de la temporal tmp_sd_frectipopago
				LET iexiste = 0;
				SELECT count(valor)
				INTO iexiste
				FROM "informix".tmp_sd_frectipopago
				WHERE num_producto = cAuxId_subproducto;

				IF NVL(iexiste,0) >= 1 THEN
					DELETE FROM "informix".sd_frectipopago
					WHERE num_producto = cAuxId_subproducto;

					FOREACH
						SELECT valor,tipo_pago
						INTO iperplazo,ctpo_pago
						FROM "informix".tmp_sd_frectipopago WHERE num_producto = cAuxId_subproducto

						INSERT INTO "informix".sd_frectipopago(valor, tipo_pago, num_producto)
						VALUES(iperplazo, ctpo_pago, cAuxId_subproducto);
					END FOREACH;
				END IF;

			ELSE
				--No existe subproducto registrado
				LET ccodret = '000002';
				RETURN cCodRet;
			END IF;
		END IF;
		-- Registro de Tasas diferenciadas
		SELECT COUNT(*)
		INTO iexisttmp_tasas
		FROM "informix".tmp_tasas_diferenciadas;

		IF iexisttmp_tasas >= 1 THEN

			FOREACH
				SELECT grupo,modelo_hit_bueno_ordnario,modelo_hit_malo_ordnario,modelo_no_hit_ordinario,modelo_hit_bueno_moratorio,modelo_hit_malo_moratorio, modelo_no_hit_moratorio
				INTO cgrupo,dmodelo_hit_bueno_ordnario, dmodelo_hit_malo_ordnario,dmodelo_no_hit_ordinario,dmodelo_hit_bueno_moratorio,dmodelo_hit_malo_moratorio,dmodelo_no_hit_moratorio
				FROM "informix".tmp_tasas_diferenciadas

				IF dmodelo_hit_bueno_moratorio > 0 THEN
					IF NVL(dmodelo_hit_bueno_moratorio,0) < NVL(dmodelo_hit_bueno_ordnario,0) THEN
						LET dmodelo_hit_bueno_moratorio = NVL(dmodelo_hit_bueno_moratorio,0) + NVL(dmodelo_hit_bueno_ordnario,0);
					END IF;
					IF NVL(dmodelo_hit_malo_moratorio,0) < NVL(dmodelo_hit_malo_ordnario,0) THEN
						LET dmodelo_hit_malo_moratorio = NVL(dmodelo_hit_malo_moratorio,0) + NVL(dmodelo_hit_malo_ordnario,0);
					END IF;
					IF NVL(dmodelo_no_hit_moratorio,0) < NVL(dmodelo_no_hit_ordinario,0) THEN
						LET dmodelo_no_hit_moratorio = NVL(dmodelo_no_hit_moratorio,0) + NVL(dmodelo_no_hit_ordinario,0);
					END IF;
				END IF;
				-- Registro de Tasas diferenciadas
				SELECT COUNT(*)
				INTO iexisttmp_tasas
				FROM "informix".sd_tasas_disposiciones_diferenciadas WHERE num_producto =cNum_Producto  AND grupo =cgrupo ;

				IF iexisttmp_tasas >= 1 THEN
					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET tasa_int_ordinaria =dmodelo_hit_bueno_ordnario , tasa_int_moratoria=dmodelo_hit_bueno_moratorio  WHERE num_producto =cNum_Producto  AND grupo =cgrupo AND evalua_cc='0';
					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET tasa_int_ordinaria =dmodelo_hit_malo_ordnario , tasa_int_moratoria=dmodelo_hit_malo_moratorio  WHERE num_producto =cNum_Producto  AND grupo =cgrupo AND evalua_cc='1';
					UPDATE bdicred:"informix".sd_tasas_disposiciones_diferenciadas SET tasa_int_ordinaria =dmodelo_no_hit_ordinario , tasa_int_moratoria=dmodelo_no_hit_moratorio  WHERE num_producto =cNum_Producto  AND grupo =cgrupo AND evalua_cc='X';
				ELSE
					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, fecha_tasa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					  VALUES('001', CURRENT, cNum_Producto, cgrupo, '0', dmodelo_hit_bueno_ordnario, dmodelo_hit_bueno_moratorio, 0.000000, 0, CURRENT, isub_producto);
					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, fecha_tasa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					  VALUES('001', CURRENT, cNum_Producto, cgrupo, '1', dmodelo_hit_malo_ordnario, dmodelo_hit_malo_moratorio, 0.000000, 0, CURRENT, isub_producto);
					INSERT INTO bdicred:"informix".sd_tasas_disposiciones_diferenciadas(empresa, fecha_tasa, num_producto, grupo, evalua_cc, tasa_int_ordinaria, tasa_int_moratoria, porc_max_disposicion, meses_buen_comp_disp, fecha_insert, id_subproducto)
					  VALUES('001', CURRENT, cNum_Producto, cgrupo, 'X', dmodelo_no_hit_ordinario, dmodelo_no_hit_moratorio, 0.000000, 0, CURRENT, isub_producto);
				END IF;
				--Registros de parametros de Tasas para mostrar en simulador
				SELECT count(valor) INTO iexiste
				FROM bdinteg:"informix".si_fechavalor WHERE tasa = ccod_tasa_base;

				IF NVL(iexiste,0) = 0 THEN
					INSERT INTO bdinteg:"informix".si_fechavalor(empresa, tasa, fecha, valor, promedio, valor_base_ref, porcentaje, puntos, fecha_recalculo, user_insert, fecha_insert)
					  VALUES(cEmpresa, ccod_tasa_base, dfecha_insert, dmodelo_hit_bueno_ordnario, 0.000000, 0.000000, 0.000000, 0.000000, dfecha_insert, cuser_insert, dfecha_insert);
				END IF;
			END FOREACH;

		END IF;
		--Convivencia de Productos
		SELECT COUNT(*)
		INTO iexisttmp_convivencia
		FROM "informix".tmp_convivenciaProductos;
		IF iexisttmp_convivencia > 0 THEN

			SELECT COUNT(*)
			INTO iexisttmp_convivencia
			FROM bdisolic:"informix".ss_tramite_productos WHERE prod_actual= cNum_Producto;

			IF iexisttmp_convivencia = 0 THEN

				IF cfamilia = '001' THEN
					INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif
					SELECT  empresa ,clasificacion ,cNum_Producto, prioridad , sistema ,restriccion_prod
					FROM bdisolic:"informix".ss_tramite_productos_clasif WHERE sistema ='06' AND prod_ofrecer = '6001';
				ELIF cfamilia = '002' THEN
					INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif
					SELECT  empresa ,clasificacion ,cNum_Producto, prioridad , sistema ,restriccion_prod
					FROM bdisolic:"informix".ss_tramite_productos_clasif WHERE sistema ='06' AND prod_ofrecer = '6300';
				ELIF cfamilia = '003' THEN
					INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif
					SELECT  empresa ,clasificacion ,cNum_Producto, prioridad , sistema ,restriccion_prod
					FROM bdisolic:"informix".ss_tramite_productos_clasif WHERE sistema ='06' AND prod_ofrecer = '6800';
				END IF;

				SELECT MAX(clasificacion)
				INTO imaxsec_tramiteprod
				FROM bdisolic:"informix".ss_tramite_productos;

				LET iclasifica1 = NVL(imaxsec_tramiteprod,0) + 1;
				LET iclasifica2 = NVL(iclasifica1,0) + 1;
				LET iclasifica3 = NVL(iclasifica2,0) + 1;

			--Registro de tablas de convivencia
				INSERT INTO bdisolic:"informix".ss_tramite_productos (empresa,clasificacion,edad_min,edad_max,sexo,prod_actual)
				VALUES(cEmpresa,iclasifica1,18,75,'I',cNum_Producto);
				INSERT INTO bdisolic:"informix".ss_tramite_productos (empresa,clasificacion,edad_min,edad_max,sexo,prod_actual)
				VALUES(cEmpresa,iclasifica2,76,150,'I',cNum_Producto);
				INSERT INTO bdisolic:"informix".ss_tramite_productos (empresa,clasificacion,edad_min,edad_max,sexo,prod_actual)
				VALUES(cEmpresa,iclasifica3,18,74,'I',cNum_Producto);
				FOREACH
					SELECT tipo_producto,num_producto,nombre_producto
					INTO ctipoproducto,cconvnumproducto,cconvnomproducto
					FROM "informix".tmp_convivenciaProductos

					IF cconvnumproducto = '2000' THEN
						LET cprioridad = '2';
					ELIF cconvnumproducto = '1400' THEN
						LET cprioridad = '3';
					ELIF cconvnumproducto = '1800' THEN
						LET cprioridad = '4';
					ELIF cconvnumproducto = '2400' THEN
						LET cprioridad = '5';
					ELIF cconvnumproducto = '1300' THEN
						LET cprioridad = '6';
					ELIF cconvnumproducto = '1900' THEN
						LET cprioridad = '7';
					ELIF cconvnumproducto IN ('1100','1700') THEN
						LET cprioridad = '8';
					ELSE
						IF ctipoproducto ='06' THEN
							LET cprioridad = '1';
						END IF;
					END IF;

					IF ctipoproducto IN ('01','03','06') AND cconvnumproducto <> '6500' THEN
						SELECT COUNT(*)
						INTO iexisttmp_convivencia
						FROM bdisolic:"informix".ss_tramite_productos_clasif
						WHERE clasificacion = iclasifica1 AND prod_ofrecer=cconvnumproducto;
						IF iexisttmp_convivencia = 0 THEN
							INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
							VALUES(cEmpresa, iclasifica1, cconvnumproducto, cprioridad, ctipoproducto, NULL);
						END IF;
					ELIF ctipoproducto IN ('01','03') AND cconvnumproducto <> '6500' THEN
						SELECT COUNT(*)
						INTO iexisttmp_convivencia
						FROM bdisolic:"informix".ss_tramite_productos_clasif
						WHERE clasificacion = iclasifica2 AND prod_ofrecer=cconvnumproducto;
						IF iexisttmp_convivencia = 0 THEN
							INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
							VALUES(cEmpresa, iclasifica2, cconvnumproducto, cprioridad, ctipoproducto, NULL);
						END IF;
					ELIF cconvnumproducto = '6500' THEN
						SELECT COUNT(*)
						INTO iexisttmp_convivencia
						FROM bdisolic:"informix".ss_tramite_productos_clasif
						WHERE clasificacion = iclasifica3 AND prod_ofrecer=cconvnumproducto;
						IF iexisttmp_convivencia = 0 THEN
							INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
							VALUES(cEmpresa, iclasifica3, cconvnumproducto, cprioridad, ctipoproducto, NULL);
						END IF;
					END IF;
				END FOREACH;
			ELSE
				FOREACH
					SELECT distinct clasificacion
					INTO sclasificacion
					FROM bdisolic:"informix".ss_tramite_productos WHERE prod_actual= cNum_Producto
					ORDER BY clasificacion

					LET sSecuencia = sSecuencia +1;

					FOREACH
						SELECT tipo_producto,num_producto,nombre_producto
						INTO ctipoproducto,cconvnumproducto,cconvnomproducto
						FROM "informix".tmp_convivenciaProductos

						SELECT COUNT(*) INTO iexistproductoconv FROM bdisolic:"informix".ss_tramite_productos_clasif
						WHERE clasificacion = sclasificacion AND prod_ofrecer = cconvnumproducto;

						IF iexistproductoconv = 1 THEN
							CONTINUE FOREACH;
						ELSE
							IF cconvnumproducto = '2000' THEN
								LET cprioridad = '2';
							ELIF cconvnumproducto = '1400' THEN
								LET cprioridad = '3';
							ELIF cconvnumproducto = '1800' THEN
								LET cprioridad = '4';
							ELIF cconvnumproducto = '2400' THEN
								LET cprioridad = '5';
							ELIF cconvnumproducto = '1300' THEN
								LET cprioridad = '6';
							ELIF cconvnumproducto = '1900' THEN
								LET cprioridad = '7';
							ELIF cconvnumproducto IN ('1100','1700') THEN
								LET cprioridad = '8';
							ELIF cconvnumproducto = '3000' THEN
								LET cprioridad = '9';
							ELSE
								LET cprioridad = '1';
							END IF;
							IF sSecuencia = 1 AND ctipoproducto IN ('01','03','06') AND cconvnumproducto <> '6500' THEN
								INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
								VALUES(cEmpresa, sclasificacion, cconvnumproducto, cprioridad, ctipoproducto, NULL);
							ELIF sSecuencia = 2 AND ctipoproducto IN ('01','03') AND cconvnumproducto <> '6500' THEN
								INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
								VALUES(cEmpresa, sclasificacion, cconvnumproducto, cprioridad, ctipoproducto, NULL);
							ELIF sSecuencia = 3 AND cconvnumproducto = '6500' THEN
								INSERT INTO bdisolic:"informix".ss_tramite_productos_clasif(empresa, clasificacion, prod_ofrecer, prioridad, sistema, restriccion_prod)
								VALUES(cEmpresa, sclasificacion, cconvnumproducto, cprioridad, ctipoproducto, NULL);
							END IF;
						END IF;
					END FOREACH;
					FOREACH
							SELECT prod_ofrecer INTO cprod_ofrecer FROM bdisolic:"informix".ss_tramite_productos_clasif
							WHERE clasificacion = sclasificacion

							SELECT COUNT(*) INTO iexistproductoconv
							FROM "informix".tmp_convivenciaProductos WHERE num_producto = cprod_ofrecer;

							IF iexistproductoconv = 1 THEN
								CONTINUE FOREACH;
							ELSE
								DELETE FROM bdisolic:"informix".ss_tramite_productos_clasif WHERE prod_ofrecer = cprod_ofrecer AND clasificacion = sclasificacion;
							END IF;
					END FOREACH;
				END FOREACH;
			END IF;
		END IF;
		--Digitalizacion de documentos
		SELECT COUNT(*)
		INTO iexisttmp_documentos
		FROM "informix".tmp_documentos_digitalizar;
		IF NVL(iexisttmp_documentos,0) > 0 THEN
			SELECT cod_tipcred
			INTO cCodTipcred
			FROM bdicred:sd_definicion
			WHERE empresa = pEmpresa
			AND num_producto = cNum_Producto;

			IF cCodTipcred = '05' THEN
			  LET cCodSistema = 'PP';
			ELSE
			   IF cCodTipcred = '03' THEN
				 LET cCodSistema = 'SD';
			   END IF;
			END IF;
			IF cNum_Producto = '8500' THEN --Producto 8500
				LET cCodproducto = cNum_Producto;
				LET cCodproducto1 = '8501';
				LET cCodproducto2 = '8502';
				LET cCodproducto3 = '8503';
			ELIF cNum_Producto = '6001' THEN --Producto 6001
				LET cCodproducto = cNum_Producto;
				LET cCodproducto1 = '0202';
				LET cCodproducto2 = '6991';
				LET cCodproducto3 = '0410';
			ELIF cNum_Producto = '6600' THEN --Producto 6600
				LET cCodproducto = cNum_Producto;
				LET cCodproducto1 = '0410';
			ELSE
				LET cCodproducto = cNum_Producto;
				LET cCodproducto1 = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), '01');
				LET cCodproducto2 = CONCAT(SUBSTR(TRIM(cNum_Producto),1,2), '33');
			END IF;
			FOREACH
				SELECT distinct cod_definicion
				INTO ccod_definicion
				FROM "informix".tmp_documentos_digitalizar
				ORDER BY cod_definicion

				LET sSecuencia = sSecuencia +1;

				SELECT COUNT(*)
				INTO iexisttmp_digitaliza
				FROM bdidigital@coppelimg_app:"informix".dg_definicion WHERE cod_definicion = ccod_definicion;

				IF NVL(iexisttmp_digitaliza,0) = 0 THEN

					IF sSecuencia = 1 THEN
					INSERT INTO bdidigital@coppelimg_app:dg_definicion(empresa, cod_definicion, cod_sistema, cod_producto, prod_nombre, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
					  VALUES(cEmpresa, ccod_definicion, cCodSistema, cCodproducto, cNomb_Producto, cuser_insert ,dfecha_insert ,cuser_insert, dfecha_insert);
					ELIF sSecuencia = 2 THEN
					INSERT INTO bdidigital@coppelimg_app:dg_definicion(empresa, cod_definicion, cod_sistema, cod_producto, prod_nombre, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
					  VALUES(cEmpresa, ccod_definicion, cCodSistema, cCodproducto1, cNomb_Producto, cuser_insert ,dfecha_insert ,cuser_insert, dfecha_insert);
					ELIF sSecuencia = 3 THEN
					INSERT INTO bdidigital@coppelimg_app:dg_definicion(empresa, cod_definicion, cod_sistema, cod_producto, prod_nombre, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
					  VALUES(cEmpresa, ccod_definicion, cCodSistema, cCodproducto2, cNomb_Producto, cuser_insert ,dfecha_insert ,cuser_insert, dfecha_insert);
					ELSE
						LET iCodproducto = cCodproducto2::INTEGER + 1;
						LET cCodproducto2 = iCodproducto::CHAR(4);
						INSERT INTO bdidigital@coppelimg_app:dg_definicion(empresa, cod_definicion, cod_sistema, cod_producto, prod_nombre, usuario_alta, fecha_alta, usuario_modif, fecha_modif)
						  VALUES(cEmpresa, ccod_definicion, cCodSistema, cCodproducto2, cNomb_Producto, cuser_insert ,dfecha_insert ,cuser_insert, dfecha_insert);
					END IF;
				END IF;
			END FOREACH;
			FOREACH
				SELECT cod_definicion,prod_nombre,cod_grupo,cod_docto,descripcion, ligar
				INTO ccod_definicion,cprod_nombre,ccod_grupo,ccod_docto,cdescripcion, cligar
				FROM "informix".tmp_documentos_digitalizar
				ORDER BY cod_definicion

				SELECT COUNT(*)
				INTO iexisttmp_digitaliza
				FROM bdidigital@coppelimg_app:"informix".dg_definicion WHERE cod_definicion = ccod_definicion;

				IF iexisttmp_digitaliza > 0 THEN
					SELECT COUNT(*)
					INTO iexisttmp_digitaliza
					FROM bdidigital@coppelimg_app:"informix".dg_definicion_det WHERE cod_definicion = ccod_definicion  AND cod_docto = ccod_docto;

					IF iexisttmp_digitaliza > 0 THEN
						CONTINUE FOREACH;
					ELSE
						SELECT MAX(secuencia)
						INTO imaxsec_digitaliza
						FROM bdidigital@coppelimg_app:dg_definicion_det;

						LET imaxsec_digitaliza = NVL(imaxsec_digitaliza,0) + 1;

						INSERT INTO bdidigital@coppelimg_app:"informix".dg_definicion_det(empresa, cod_definicion, secuencia, cod_docto)
						  VALUES(cEmpresa, ccod_definicion, imaxsec_digitaliza, ccod_docto);
						 --Se actualiza la columna de ligar del documento
							UPDATE  bdidigital@coppelimg_app:"informix".dg_tipodocumento SET  ligar= cligar WHERE cod_docto = ccod_docto;
					END IF;
				END IF;
			END FOREACH;

			SELECT COUNT(*)
			INTO iexisttmp_digitaliza
			FROM "informix".tmp_documentos_digitalizar;

			IF NVL(iexisttmp_digitaliza,0) >= 1 THEN
				--Eliminar si ya existen los que no se encuentren en la temporal
				FOREACH
					SELECT cod_definicion
					INTO ccod_definicion
					FROM bdidigital@coppelimg_app:"informix".dg_definicion
					WHERE cod_producto IN (cCodproducto,cCodproducto1,cCodproducto2,cCodproducto3)

					SELECT COUNT(*)
					INTO iexisttmp_digitaliza
					FROM  bdidigital@coppelimg_app:"informix".dg_definicion_det
					WHERE cod_definicion = ccod_definicion;

					IF NVL(iexisttmp_digitaliza,0) >= 1 THEN

						FOREACH
							SELECT cod_definicion,cod_docto
							INTO ccod_definicion,ccod_docto
							FROM  bdidigital@coppelimg_app:"informix".dg_definicion_det
							WHERE cod_definicion = ccod_definicion

							SELECT COUNT(*)
							INTO iexisttmp_digitaliza
							FROM "informix".tmp_documentos_digitalizar WHERE cod_definicion = ccod_definicion AND cod_docto = ccod_docto;

							IF NVL(iexisttmp_digitaliza,0) = 0 THEN
								DELETE FROM bdidigital@coppelimg_app:"informix".dg_definicion_det WHERE cod_definicion = ccod_definicion  AND cod_docto = ccod_docto;
							END IF;
						END FOREACH;
					END IF;
				END FOREACH;
			END IF;
		END IF;
		--Documentos a imprimir
		SELECT COUNT(*)
		INTO iexisttmp_doctos_imp
		FROM "informix".tmp_doctos_imprimir;
		IF iexisttmp_doctos_imp > 0 THEN
			FOREACH
				SELECT 	codigo_documento, descripcion_documento, cantidad
				INTO ccod_doctimp,cdesc_doc,icantidad
				FROM "informix".tmp_doctos_imprimir

				SELECT count(*) INTO iexisttmp_doctos_imp
				FROM bdicred:"informix".sd_doctosimprimexproducto WHERE cod_docto = ccod_doctimp AND num_producto = cNum_Producto;

				IF iexisttmp_doctos_imp = 0 THEN
					  INSERT INTO bdicred:"informix".sd_doctosimprimexproducto(cod_docto,num_producto,cantidad)
					  VALUES(ccod_doctimp,cNum_Producto,NVL(icantidad,0));
				ELSE
					UPDATE bdicred:"informix".sd_doctosimprimexproducto SET cantidad = NVL(icantidad,0) WHERE cod_docto = ccod_doctimp AND num_producto = cNum_Producto;
				END IF;
			END FOREACH;
			FOREACH
				SELECT 	cod_docto
				INTO ccod_doctimp
				FROM bdicred:"informix".sd_doctosimprimexproducto
				WHERE num_producto = cNum_Producto

				SELECT count(*) INTO iexisttmp_doctos_imp
				FROM bdicred:"informix".tmp_doctos_imprimir WHERE codigo_documento::INTEGER = ccod_doctimp;

				IF iexisttmp_doctos_imp = 0 THEN
					  DELETE FROM bdicred:"informix".sd_doctosimprimexproducto WHERE cod_docto = ccod_doctimp AND num_producto = cNum_Producto;
				END IF;
			END FOREACH;
		END IF;
		--Canales de Operacion
		SELECT COUNT(*)
		INTO iexisttmp_operaciones
		FROM "informix".tmp_operaciones_canal;

		IF iexisttmp_operaciones > 0 THEN
			FOREACH
				SELECT id_operaciones,id_canal
				INTO scod_operaciones,scve_canal
				FROM "informix".tmp_operaciones_canal

					SELECT count(*) INTO iexisttmp_operaciones
					FROM bdicred:"informix".sd_operaciones_canal WHERE cod_operaciones = scod_operaciones AND cve_canal=scve_canal AND num_producto = cNum_Producto;

					IF iexisttmp_operaciones = 0 THEN
						  INSERT INTO bdicred:"informix".sd_operaciones_canal(cod_operaciones,cve_canal,num_producto)
						  VALUES(scod_operaciones,scve_canal,cNum_Producto);
					END IF;
			END FOREACH;
			FOREACH
				SELECT 	cod_operaciones,cve_canal
				INTO scod_operaciones,scve_canal
				FROM bdicred:"informix".sd_operaciones_canal
				WHERE num_producto = cNum_Producto

				SELECT count(*) INTO iexisttmp_operaciones
				FROM bdicred:"informix".tmp_operaciones_canal WHERE id_operaciones = scod_operaciones AND id_canal=scve_canal;

				IF iexisttmp_operaciones = 0 THEN
					  DELETE FROM bdicred:"informix".sd_operaciones_canal WHERE cod_operaciones = scod_operaciones AND cve_canal=scve_canal AND num_producto = cNum_Producto;
				END IF;
			END FOREACH;
		END IF;
		--ActivaciÃÆÃÆÃâÃÆÃÆÃâÃâÃÆÃÆÃÆÃâÃâÃÆÃâÃâÃÆÃÆÃÆÃâÃÆÃÆÃâÃâÃâÃÆÃÆÃâÃâÃÆÃâÃâÃÂ³n de Mensajes

		SELECT COUNT(*)
		INTO iexisttmp_activamsj
		FROM "informix".tmp_activacionmsj;

		IF iexisttmp_activamsj > 0 THEN
			FOREACH
				SELECT 	num_producto,cve_canal,	id_evento,cod_plantilla ,cod_msm_mail,activosms ,activoemail
				INTO cnum_prodsms, scve_canal, sid_evento, scod_plantilla, ccod_msm_mail, cactivosms, cactivoemail
				FROM bdicred:"informix".tmp_activacionmsj WHERE num_producto = cNum_Producto

				SELECT count(*) INTO iexisttmp_activamsj
				FROM "informix".sd_activacion_sms_email WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento=sid_evento AND cod_plantilla = scod_plantilla;

				IF iexisttmp_activamsj = 0 THEN
					INSERT INTO bdicred:"informix".sd_activacion_sms_email(num_producto,cve_canal,id_evento,cod_plantilla,cod_msm_mail,activosms,activoemail)
					VALUES(cnum_prodsms, scve_canal,sid_evento,scod_plantilla,ccod_msm_mail,cactivosms,cactivoemail);
				ELSE
					UPDATE bdicred:"informix".sd_activacion_sms_email SET activosms=cactivosms, activoemail=cactivoemail WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento=sid_evento AND cod_plantilla = scod_plantilla;
				END IF;
			END FOREACH;
			FOREACH
				SELECT cve_canal, id_evento, cod_plantilla
				INTO scve_canal, sid_evento, scod_plantilla
				FROM bdicred:"informix".sd_activacion_sms_email
				WHERE num_producto = cNum_Producto

				SELECT count(*) INTO iexisttmp_activamsj
				FROM bdicred:"informix".tmp_activacionmsj WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento=sid_evento AND cod_plantilla = scod_plantilla;

				IF iexisttmp_activamsj = 0 THEN
					  DELETE FROM bdicred:"informix".sd_activacion_sms_email WHERE num_producto = cNum_Producto AND cve_canal = scve_canal AND id_evento=sid_evento AND cod_plantilla = scod_plantilla;
				END IF;
			END FOREACH;
		END IF;
		--Politicas de Credito
		SELECT COUNT(*)
		INTO iexisttmp_polcredprod
		FROM "informix".tmp_politicacreditoprod;

		SELECT count(*)
		INTO iexisttmp_polcredprodexist
		FROM bdisolic:"informix".ss_scoring_modelo2
		WHERE num_producto = cNum_Producto;

		IF iexisttmp_polcredprod > 0 THEN
			FOREACH
				SELECT	num_producto, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol
				INTO cnum_prodpolcred, corespuesta_sic, cogrupo, ibc_scoremin, ibc_scoremax, ipro_scormin, ipro_scormax, cstatus_sol
				FROM "informix".tmp_politicacreditoprod

				IF cogrupo IN('4','6') THEN
					CONTINUE FOREACH;
				END IF;

				IF NVL(iexisttmp_polcredprodexist,0) = 0 THEN
					IF cstatus_sol = 'RT' THEN
						LET ccausa_sol = 'RS3';
					ELSE
						LET ccausa_sol = ' ';
					END IF;

					SELECT count(*)
					INTO iexisttmp_polcredprod
					FROM bdisolic:"informix".ss_scoring_modelo2
					WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=ibc_scoremin AND bc_scoremax=ibc_scoremax AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

					IF NVL(iexisttmp_polcredprod,0) = 0  AND ipro_scormax > 0 THEN
						INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
						  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,ibc_scoremin, ibc_scoremax,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
					END IF;
				ELSE
			/*	END IF;
				
			END FOREACH;
			FOREACH
				SELECT	num_producto, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol
				INTO cnum_prodpolcred, corespuesta_sic, cogrupo, ibc_scoremin, ibc_scoremax, ipro_scormin, ipro_scormax, cstatus_sol
				FROM "informix".tmp_politicacreditoprod

				IF cogrupo IN('4','6') THEN
					CONTINUE FOREACH;
				END IF;

				IF NVL(iexisttmp_polcredprodexist,0) = 0 THEN
					IF cstatus_sol = 'RT' THEN
						LET ccausa_sol = 'RS3';
					ELSE
						LET ccausa_sol = ' ';
					END IF;
					IF cstatus_sol = 'AT'  AND ipro_scormax > 0 THEN
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,0, 0,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=-1 AND bc_scoremax=-1 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,-1, -1,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
					ELIF cstatus_sol = 'RT' AND ipro_scormax > 0 THEN
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,0, 0,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=-1 AND bc_scoremax=-1 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							  INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,-1, -1,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						/*SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin= 0 AND pro_scormax=ipro_scormin-1;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,0, 0,0, ipro_scormin-1, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=-1 AND bc_scoremax=-1 AND pro_scormin= 0 AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
						  INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,-1, -1,0, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=1 AND bc_scoremax=ibc_scoremax AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 AND ibc_scoremax > 0 THEN
							  INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,1,ibc_scoremax,ipro_scormin, ipro_scormax,cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND bc_scoremin=1 AND bc_scoremax=ibc_scoremax AND pro_scormin= 0 AND pro_scormax=ipro_scormax AND status_sol = cstatus_sol;

						IF NVL(iexisttmp_polcredprod,0) = 0 AND ibc_scoremax > 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,1,ibc_scoremax,0, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
					END IF;
				ELSE
					IF cstatus_sol = 'AT' THEN
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
						AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,0, 0,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
						SELECT count(*)
						INTO iexisttmp_polcredprod
						FROM bdisolic:"informix".ss_scoring_modelo2
						WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
						AND bc_scoremin=-1 AND bc_scoremax=-1 AND pro_scormin= ipro_scormin AND pro_scormax=ipro_scormax;

						IF NVL(iexisttmp_polcredprod,0) = 0 THEN
							INSERT INTO bdisolic:"informix".ss_scoring_modelo2(tp_solicitud, tp_parametrico, respuesta_sic, grupo, bc_scoremin, bc_scoremax, pro_scormin, pro_scormax, status_sol, causa_sol, fc_score_min, fc_score_max, status_sol_fc, causa_sol_fc, num_producto, fc_extended_min, fc_extended_max, status_sol_fcex, causa_sol_fcex, icc_min, icc_max, pro_scor_osmin, pro_scor_osmx)
							  VALUES(ctp_solicitud, 2, corespuesta_sic, cogrupo,-1, -1,ipro_scormin, ipro_scormax, cstatus_sol, ccausa_sol, 0, 0, '', '', cNum_Producto, 0, 0, '', '', 0, 0, 0, 0);
						END IF;
					ELIF cstatus_sol = 'RT' THEN*/
							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET pro_scormin= ipro_scormin, pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin>1 AND pro_scormax>1;

							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET pro_scormin= ipro_scormin, pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=-1 AND bc_scoremax=-1 AND pro_scormin>1 AND pro_scormax>1;

							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=0 AND bc_scoremax=0 AND pro_scormin= 0 AND pro_scormax>1;

							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=-1 AND bc_scoremax =-1 AND pro_scormin= 0 AND pro_scormax > 1;

							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET bc_scoremax=ibc_scoremax,pro_scormin= ipro_scormin,pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=1 AND bc_scoremax >1 AND pro_scormin> 1 AND pro_scormax > 1;

							UPDATE bdisolic:"informix".ss_scoring_modelo2
							SET bc_scoremax=ibc_scoremax, pro_scormax=ipro_scormax
							WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol
							AND bc_scoremin=1 AND pro_scormin= 0 AND bc_scoremax > 1 AND pro_scormax > 1;
					/*END IF;

					UPDATE bdisolic:"informix".ss_scoring_modelo2
					SET bc_scoremin=ibc_scoremin, bc_scoremax=ibc_scoremax, pro_scormin=ipro_scormin, pro_scormax=ipro_scormax
					WHERE num_producto = cNum_Producto AND respuesta_sic = corespuesta_sic AND grupo=cogrupo AND status_sol = cstatus_sol;*/
				END IF;
			END FOREACH;
		END IF;
		--Cuentas de medios de acceso
		SELECT COUNT(*)
		INTO iexisttmp_ctasacceso
		FROM "informix".tmp_ctasmedioacceso;

		IF iexisttmp_ctasacceso > 0 THEN
			FOREACH
				SELECT num_producto, producto_cap, nom_producto
				INTO cNumprodAcceso,cprodcap,cNomprodcap
				FROM "informix".tmp_ctasmedioacceso

				SELECT count(*)
				INTO iexisttmp_ctasacceso
				FROM bdisolic:"informix".ss_producto_credcap
				WHERE empresa = cEmpresa AND num_producto = cNum_Producto AND producto_cap = cprodcap;

				IF iexisttmp_ctasacceso = 0 THEN
					INSERT INTO bdisolic:"informix".ss_producto_credcap(empresa, num_producto, producto_cap, nom_producto, meses_alta)
					VALUES(cEmpresa, cNum_Producto, cprodcap, cNomprodcap, NULL);

				END IF;
			END FOREACH;
			FOREACH
				SELECT num_producto, producto_cap
				INTO cNumprodAcceso,cprodcap
				FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto = cNum_Producto

				SELECT count(*)
				INTO iexisttmp_ctasacceso
				FROM "informix".tmp_ctasmedioacceso
				WHERE num_producto = cNum_Producto AND producto_cap = cprodcap;

				IF iexisttmp_ctasacceso = 0 THEN
					DELETE FROM bdisolic:"informix".ss_producto_credcap WHERE num_producto= cNum_Producto AND producto_cap = cprodcap;
				END IF;
			END FOREACH;
		END IF;

		--Eliminado de Tablas temporales
		 delete from "informix".tmp_sd_definicion;
		 delete from "informix".tmp_caracteristicas_complementarias;
		 delete from "informix".tmp_tasas_diferenciadas;
		 delete from "informix".tmp_convivenciaProductos;
		 delete from "informix".tmp_documentos_digitalizar;
		 delete from "informix".tmp_doctos_imprimir;
		 delete from "informix".tmp_operaciones_canal;
		 delete from "informix".tmp_activacionmsj;
		 delete from "informix".tmp_politicacreditoprod;
		 delete from "informix".tmp_ctasmedioacceso;
		 delete from "informix".tmp_sd_frectipopago;
		 delete from "informix".tmp_tipofacturacion;

		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Maria Elena Angulo Aispuro',
'FECHA: 20/08/2020',
'DESCRIPCION: Registra y/o actualiza productos y subproductos de Prestamo y Tarjetas de Credito.',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_genera_ec_rt()
--EXECUTE PROCEDURE sp_genera_ec_rt();

RETURNING CHAR(5);

--DECLARACION
DEFINE vCodRet			CHAR(05);
DEFINE cMensaje    	 	CHAR(100); 
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE vMes				CHAR(02);
DEFINE vMesAnt			CHAR(02);
DEFINE vAnio			CHAR(04);
DEFINE vFechaAnt		DATE;
DEFINE vFechaHoy		DATE;
DEFINE contador_ec  	INTEGER;
DEFINE numero_cre  		VARCHAR(20,1);
DEFINE fecha_emi  		DATE;
DEFINE centro_imp_var  	CHAR(06);
DEFINE centro_imptemp  	CHAR(06);
DEFINE centro_impanterior CHAR(06);
DEFINE numero_reg  		INTEGER;
DEFINE contador_aux 	CHAR(06);
DEFINE vCentroDis		INTEGER;
DEFINE ciudad_impanterior	CHAR(06);
DEFINE ciudad_imp_var	CHAR(06);

DEFINE v_num_credito	CHAR(20);
DEFINE v_numcte			CHAR(20);
DEFINE v_ruta          	CHAR(47);
DEFINE v_numerociudad 	SMALLINT;
DEFINE v_numerocolonia 	INTEGER;
DEFINE v_numerocalle 	INTEGER;
DEFINE v_numeroextcalle CHAR(10);
DEFINE v_centro			INTEGER;
DEFINE v_jefegrupozona	INTEGER;
DEFINE v_supervisorzona	INTEGER;
DEFINE v_numerociudadCoppel	SMALLINT;
DEFINE v_numerocoloniaCoppel	INTEGER;
DEFINE v_tipo_dir		CHAR(1);

DEFINE vFechaEmision	DATE;
DEFINE vNumCredito		CHAR(20);
DEFINE VNumCte			CHAR(20);
DEFINE vSucursal		INTEGER;
DEFINE vNumRegion		CHAR(02);
DEFINE vNumCiudadBanco	CHAR(04);
DEFINE vNumCiudadCoppel	CHAR(03);
DEFINE cNumRegion		CHAR(02);
DEFINE cNumCiudadBanco	CHAR(04);
DEFINE cNumCiudadCoppel	CHAR(03);
DEFINE vNumCentroImpr	CHAR(02);


--INICIALIZACION
LET vCodRet        	= '00000';
LET cMensaje    	= 'Ejecucion Exitosa';
LET iSqlErr     	= 0;
LET iIsamErr    	= 0;
LET vMes			= '';
LET vMesAnt			= '';
LET vAnio			= '';
LET vFechaAnt		= date(1);
LET vFechaHoy		= date(1);
LET contador_ec  	= 0;
LET numero_cre 		= "";
LET fecha_emi 		= DATE(1);
LET centro_imp_var 	= "";
LET ciudad_impanterior = "";
LET centro_imptemp 	= "";
LET numero_reg 		= 0;
LET contador_aux 	= '0';
LET vCentroDis		= 0;
LET centro_impanterior 	= "";
LET ciudad_imp_var	= '0';

LET v_num_credito	= '';
LET v_numcte		= '';
LET v_ruta			= '';
LET v_numerociudad	= 0;
LET v_numerocolonia	= '';
LET v_numerocalle	= 0;
LET v_numeroextcalle	= '';
LET v_centro		= 0;
LET v_jefegrupozona	= 0;
LET v_supervisorzona	= 0;
LET v_numerociudadCoppel	= 0;
LET v_numerocoloniaCoppel	= 0;
LET v_tipo_dir		= '';

LET vFechaEmision	= DATE(1);
LET vNumCredito		= '';
LET VNumCte			= '';
LET vSucursal		= 0;
LET vNumRegion		= '0';
LET vNumCiudadBanco	= '0';
LET vNumCiudadCoppel	= '0';
LET cNumRegion		= '0';
LET cNumCiudadBanco	= '0';
LET cNumCiudadCoppel	= '0';
LET vNumCentroImpr	= '00';

--SET DEBUG FILE TO "/informix/ulises/INC_EDC_EC/generacion_ec_rt.out";
--TRACE ON; 

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
			LET vCodRet = iSqlErr;		
            LET cMensaje = 'Error en la ejecucion';
            RETURN vCodRet;
		END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Recupera la fecha
	LET vFechaAnt = MDY(MONTH(today),02,YEAR(today));
    LET vFechaHoy = MDY(MONTH(today),17,YEAR(today));
	
	--LET vFechaAnt = mdy('02','02','2022');-- para pruebas
	--LET vFechaHoy = mdy('02','17','2022');-- para pruebas
	
	
	---- FUNCIONALIDAD ACTUALIZACION DE RUTA
	SELECT num_credito,numcte,ruta, num_region, num_ciudad_banco, num_ciudad_coppel
	FROM bdicred:"informix".sd_encabezado_edoctacrd 
	where fecha_emision BETWEEN vFechaAnt AND vFechaHoy AND num_producto = '6011'
	AND num_credito NOT IN('61100')
	INTO TEMP rt_act_ruta WITH NO LOG;
	
	FOREACH WITH HOLD
	
	SELECT num_credito,		numcte,				ruta,		
		   num_region,		num_ciudad_banco,	num_ciudad_coppel 
	  INTO v_num_credito,	v_numcte,			v_ruta, 
		   vNumRegion,		vNumCiudadBanco,	vNumCiudadCoppel
	FROM rt_act_ruta
	
	UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy AND num_credito = v_num_credito;
	
	-- SI_DIRECCIONES TIPO 1 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir = "1";
	 
	IF v_tipo_dir = '1' THEN
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;

	-- SI_DIRECCIONES TIPO 2 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir = "2" ;
	
	IF v_tipo_dir = '2' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;
	
	-- SI_DIRECCIONES TIPO 3 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = v_numcte AND tipo_dir >= "3" ;
	
	IF v_tipo_dir >= '3' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
		-- SI_CATZONAS
		SELECT NVL(d.centro,0),				d.jefegrupozona,
			   d.supervisorzona,     NVL(d.numerociudadcoppel,0),
			   NVL(d.numerocoloniacoppel,0)
		  INTO v_centro,				v_jefegrupozona,		
			   v_supervisorzona,		v_numerociudadCoppel,   
			   v_numerocoloniaCoppel	
		FROM bdinteg:"informix".si_catzonas d
		WHERE d.numerociudad = v_numerociudad
		AND d.numerocolonia = v_numerocolonia;
		
		IF nvl(v_numerociudadCoppel,0) >= 0 and  nvl(v_numerocoloniaCoppel,0) > 0 then
			let v_numerociudad = v_numerociudadCoppel;
			let v_numerocolonia = v_numerocoloniaCoppel;
		END IF;
		
		LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
					 LPAD(v_centro,6,'0')||"/"||
					 LPAD(v_jefegrupozona,8,'0')||"/"||
					 LPAD(v_supervisorzona,8,'0')||"/"||
					 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
					 LPAD(v_numerocalle,6,'0')||"/"||
					 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' and num_credito = v_num_credito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_banco = v_numerociudad
		AND num_ciudad_coppel = v_numerociudadCoppel;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(v_numerociudad,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' AND num_credito = v_num_credito;
		COMMIT;
		
	END IF;
	
	END FOREACH; 

	--- FUNCIONALIDAD PARA GENERAR EC
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir, a.ruta
	FROM bdicred:sd_encabezado_edoctacrd a 
	INNER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte AND b.tipo_dir = '1' 
	INNER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision BETWEEN vFechaAnt AND vFechaHoy AND a.num_producto = '6011' 
	AND a.num_credito NOT IN('61100')
	and c.centro is not null and c.numerociudadcoppel is not null and c.numerocoloniacoppel is not null
	--and c.centro IN(0,500101,500901,500902)
	INTO TEMP creditosrt_ec WITH NO LOG;
	
	INSERT INTO creditosrt_ec
	SELECT a.num_credito, a.fecha_emision, c.numerociudadcoppel, c.centro, c.jefegrupozona, c.supervisorzona, c.numerocoloniacoppel,
		   b.numerocalle, b.numeroextcalle, b.tipo_dir, a.ruta
	FROM bdicred:sd_encabezado_edoctacrd a 
	LEFT OUTER JOIN bdinteg:si_direcciones_actual b ON a.numcte = b.numcte --AND b.tipo_dir = 1 
	LEFT OUTER JOIN bdinteg:si_catzonas c ON nvl(c.numerociudad,0) = nvl(b.numerociudad,0) AND nvl(c.numerocolonia,0) = nvl(b.numerocolonia,0)
	WHERE a.fecha_emision BETWEEN vFechaAnt AND vFechaHoy AND a.num_producto = '6011' 
	AND a.num_credito NOT IN('61100')
	and c.centro is not null and c.numerociudadcoppel is not null and c.numerocoloniacoppel is not null
	--and c.centro IN(0,500101,500901,500902)
	AND a.num_credito NOT IN(select num_credito from creditosrt_ec);
	
	
	SELECT num_credito, fecha_emision, numerociudadcoppel, centro, jefegrupozona, supervisorzona, numerocoloniacoppel,
		   numerocalle, numeroextcalle, tipo_dir, ruta
	FROM creditosrt_ec --where num_credito NOT IN('61100')
	group by centro, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle, tipo_dir, fecha_emision, num_credito, ruta
	INTO TEMP tmpNumeroRegistroscrd WITH NO LOG;


	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro, numerociudadcoppel INTO numero_cre, fecha_emi, centro_imp_var, ciudad_imp_var FROM tmpNumeroRegistroscrd
		--ORDER BY centro::INTEGER, numerociudadcoppel, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, numeroextcalle
		ORDER BY centro::INTEGER, numerociudadcoppel::INTEGER, jefegrupozona, supervisorzona, numerocoloniacoppel, numerocalle, to_char(ruta), numeroextcalle
		

	BEGIN;
	
		IF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior = ciudad_imp_var) THEN

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

			LET contador_aux = contador_aux + 1;
			
		ELIF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior != ciudad_imp_var) THEN

			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		ELSE
		
			LET centro_impanterior = centro_imp_var;
			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = numero_cre
			AND fecha_emision = fecha_emi;

		END IF;
	COMMIT;

	END FOREACH; 
	
	
	-- FUNCIONALIDAD PARA CUENTAS QUE CUENTAN CON CIUDAD, PERO SIN CENTRO EN SI_CATZONAS  ******************************
	CREATE TEMP TABLE ctas_x_cd(
	fecha_emision	DATE,
	num_credito		CHAR(20),
	numcte			CHAR(20),
	centro			INTEGER,
	numerociudad	SMALLINT,
	numerocalle		INTEGER,
	numeroextcalle	CHAR(10));
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte
	INTO vFechaEmision, vNumCredito, VNumCte
	FROM "informix".sd_encabezado_edoctacrd 
	WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy and num_credito NOT IN ('61100')
	AND num_producto = '6011' AND ec_edocta IS NULL
	
	--UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE fecha_emision = vFechaEmision AND num_credito = vNumCredito ;
	
	LET v_centro 			= 999999;
	LET v_jefegrupozona 	= 00000000;
	LET v_supervisorzona 	= 00000000;
	LET v_numerocolonia 	= 0000;
	LET cNumCiudadBanco	= '0000';
	LET contador_ec		= 0;
	LET contador_aux	= 0;
	LET ciudad_imp_var	= '0';
	LET ciudad_impanterior = '';
	LET centro_impanterior 	= "";
	LET vNumCentroImpr	= '00';
	LET v_ruta	= '';
	
	-- SI_DIRECCIONES TIPO 1 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = VNumCte AND tipo_dir = "1";
	
	IF v_tipo_dir = '1' THEN
	
		LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
						 LPAD(v_centro,6,'0')||"/"||
						 LPAD(v_jefegrupozona,8,'0')||"/"||
						 LPAD(v_supervisorzona,8,'0')||"/"||
						 LPAD(v_numerocolonia,4,'0')||"/"||
						 LPAD(v_numerocalle,6,'0')||"/"||
						 LPAD(TRIM(v_numeroextcalle),5,'0');
					 
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' and num_credito = vNumCredito;
		COMMIT;
		
		SELECT LPAD(NVL(num_region,0),2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_coppel = v_numerociudad
		GROUP BY num_region;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudad,3,0)
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' AND num_credito = vNumCredito;
		COMMIT;
		
		BEGIN;
			INSERT INTO ctas_x_cd (fecha_emision, num_credito, numcte, centro, numerociudad, numerocalle, numeroextcalle)
				VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro, v_numerociudad, v_numerocalle, v_numeroextcalle);
		COMMIT;
	
	END IF;	
	
	-- SI_DIRECCIONES TIPO 2 
	SELECT NVL(b.numerociudad,0),		NVL(b.numerocolonia,0),
		   NVL(b.numerocalle,0),      	NVL(b.numeroextcalle,'') , tipo_dir
	  INTO v_numerociudad,		v_numerocolonia,
		   v_numerocalle,		v_numeroextcalle, v_tipo_dir
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte = VNumCte AND tipo_dir = "2" ;
	
	IF v_tipo_dir = '2' AND nvl(v_ruta,'') = '' OR v_ruta IS NULL  THEN 
	
		LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
							 LPAD(v_centro,6,'0')||"/"||
							 LPAD(v_jefegrupozona,8,'0')||"/"||
							 LPAD(v_supervisorzona,8,'0')||"/"||
							 LPAD(v_numerocolonia,4,'0')||"/"||
							 LPAD(v_numerocalle,6,'0')||"/"||
							 LPAD(TRIM(v_numeroextcalle),5,'0');
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd SET ruta = nvl(v_ruta,'')
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' and num_credito = vNumCredito;
		COMMIT;
		
		SELECT LPAD(num_region,2,0) INTO vNumCentroImpr
		FROM "informix".sd_centrosimpresion_coppel
		WHERE num_ciudad_coppel = v_numerociudad
		GROUP BY num_region;
		
		BEGIN;
			UPDATE "informix".sd_encabezado_edoctacrd 
			SET num_region = LPAD(vNumCentroImpr,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudad,3,0)
			WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
			AND num_producto = '6011' AND num_credito = vNumCredito;
		COMMIT;
		
		BEGIN;
			INSERT INTO ctas_x_cd (fecha_emision, num_credito, numcte, centro, numerociudad, numerocalle, numeroextcalle)
				VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro, v_numerociudad, v_numerocalle, v_numeroextcalle);
		COMMIT;
	
	END IF;
	
	
	END FOREACH;
	
	---- FUNCIONALIDAD PARA GENERAR EC CONSECUTIVO
	
	FOREACH WITH HOLD 

		SELECT num_credito, fecha_emision, centro, numerociudad INTO vNumCredito, vFechaEmision, v_centro, ciudad_imp_var FROM ctas_x_cd
		ORDER BY centro::INTEGER, numerociudad::INTEGER, numerocalle, numeroextcalle
		
	
	BEGIN;
	
		IF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior = ciudad_imp_var) THEN

			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

			LET contador_aux = contador_aux + 1;
			
		ELIF (centro_impanterior = centro_imp_var) AND (ciudad_impanterior != ciudad_imp_var) THEN

			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

		ELSE
		
			LET centro_impanterior = centro_imp_var;
			LET ciudad_impanterior = ciudad_imp_var;

			LET contador_ec = 0;
			LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

		END IF;
	COMMIT;

	END FOREACH; 
	
	
	---- FUNCIONALIDAD PARA COMPLEMENTAR CTAS SIN CIUDAD Y SIN CENTRO ******************************
	CREATE TEMP TABLE cred_sec(
	fecha_emision	DATE,
	num_credito	CHAR(20),
	numcte		CHAR(20),
	centro	INTEGER);
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte, num_region, num_ciudad_banco, num_ciudad_coppel 
	INTO vFechaEmision, vNumCredito, VNumCte, cNumRegion, cNumCiudadBanco, cNumCiudadCoppel
	FROM "informix".sd_encabezado_edoctacrd 
	WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy and num_credito NOT IN ('61100')
	AND num_producto = '6011' AND ec_edocta IS NULL
	
	--UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE num_credito = vNumCredito;
	
	LET v_numerociudadCoppel 	= '004';
	LET v_centro 				= 999999;
	LET v_jefegrupozona 		= 00000000;
	LET v_supervisorzona 		= 00000000;
	LET v_numerocoloniaCoppel 	= 0000;
	LET v_numerocalle			= 000000;
	LET v_numeroextcalle 		= '00000';
	LET contador_ec		= 0;
	LET contador_aux	= 0;
	LET cNumRegion		= '00';
	LET cNumCiudadBanco	= '0000';
	
	BEGIN;
	INSERT INTO cred_sec (fecha_emision, num_credito, numcte, centro)
		VALUES(vFechaEmision, vNumCredito, VNumCte, v_centro);
	COMMIT;
		
	LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
				 LPAD(v_centro,6,'0')||"/"||
				 LPAD(v_jefegrupozona,8,'0')||"/"||
				 LPAD(v_supervisorzona,8,'0')||"/"||
				 LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
				 LPAD(v_numerocalle,6,'0')||"/"||
				 LPAD(TRIM(v_numeroextcalle),5,'0');
				 
	BEGIN;
		UPDATE "informix".sd_encabezado_edoctacrd 
		SET num_region = LPAD(cNumRegion,2,0), num_ciudad_banco = LPAD(cNumCiudadBanco,4,0), num_ciudad_coppel = LPAD(v_numerociudadCoppel,3,0)
		WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
		AND num_producto = '6011' AND num_credito = vNumCredito AND NVL(ruta,'') = '';
	COMMIT;
	
	BEGIN;
		UPDATE "informix".sd_encabezado_edoctacrd SET ruta = '' WHERE fecha_emision BETWEEN vFechaAnt AND vFechaHoy 
		AND num_producto = '6011' AND ec_edocta is nulL AND num_credito = vNumCredito;
	COMMIT;
	
	END FOREACH;
	
	
	FOREACH WITH HOLD
	SELECT fecha_emision, num_credito, numcte INTO vFechaEmision, vNumCredito, VNumCte FROM cred_sec 
	ORDER BY centro,fecha_emision,num_credito
	
	LET contador_ec = contador_ec + 1;

			UPDATE sd_encabezado_Edoctacrd
			SET ec_edocta = contador_ec
			WHERE num_credito = vNumCredito
			AND fecha_emision = vFechaEmision;

			LET contador_aux = contador_aux + 1;
			
	END FOREACH;

	DROP TABLE IF EXISTS creditosrt_ec;
	DROP TABLE IF EXISTS tmpNumeroRegistroscrd;
	DROP TABLE IF EXISTS cred_sec;
	
	
	END;

	RETURN vCodRet;

END PROCEDURE;
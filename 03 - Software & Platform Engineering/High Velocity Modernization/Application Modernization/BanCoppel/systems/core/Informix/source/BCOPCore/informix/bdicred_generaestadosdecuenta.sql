CREATE PROCEDURE "informix".generaestadosdecuenta(pempresa CHAR(3),pnum_credito CHAR(20),pfechahoy DATE)
--EXECUTE PROCEDURE generaestadosdecuenta('001','600000064417',mdy('09','20','2021')); 
RETURNING CHAR(5);

-- 09062013
-- Modificacion PIQV. Se realiza modificacion para incluir en el desgloce de movimientos las compras de las transacciones.
-- 7730 (COMPRA EN COMERCIO (LIB) INTER-RED SALDO A FAVOR) y 7729 (COMPRA EN COMERCIO (LIB) SALDO A FAVOR)
-- 01082013
-- Modificacion AAME. Se realiza modificacion para incluir en el desgloce de movimientos los cargos por concepto "Pago de servicio GDF"
-- 6846 (Pago de servicio GDF) y 7746 (Pago de servicio GDF Saldo a Favor)
-- 30072013
-- Modificacion Se realiza modificacion para incluir en el desgloce de movimientos las compras de las transacciones.
-- 4301,4302,4303,4304,4304,4305,4306,4307,4308,4309,4310,4311,4312,4313,4314,4315 
--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE cod_ret             			CHAR(5);
DEFINE sql_err             			INTEGER;
DEFINE v_cod_ret_otro			    CHAR(5);

DEFINE v_corta_linea_detalle 		INTEGER;
DEFINE v_corta_retorno        		INTEGER;
DEFINE GLOBAL v_corta_linea_mensaje INTEGER  DEFAULT 0;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_sucursal        CHAR(4);	--Sucursal Cliente
DEFINE v_ult_dir_clie	 INTEGER;	--Secuencia Ultima Direccion Cliente
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
DEFINE v_numcte            CHAR(20);	--Numero de Credito
DEFINE v_num_tarjeta       CHAR(20);	--Numero de Tarjeta
DEFINE v_nombre_cte        CHAR(150);	--Nombre del Cliente
DEFINE v_direccion_cn      CHAR(456);	--Direccion
DEFINE v_direccion_col     CHAR(376);	--Colonia
DEFINE v_direccion_del     CHAR(376);	--Delegacion O Municipio
DEFINE v_edo_cd            CHAR(376);	--Estado
DEFINE v_sucursal_nombre   CHAR(40);	--Nombre de la Sucursal
DEFINE v_sucursal_gerente  CHAR(40);	--Nombre del Gerente del Sucursal
DEFINE v_sucursal_tel      CHAR(14);	--Telefono de la Sucursal
DEFINE v_cod_postal        CHAR(5);		--Codigo Postal Direccion Cliente
DEFINE v_cl_cobra          CHAR(60);	--Clave de Cobranza
DEFINE v_rfc               CHAR(13);	--RFC del Cliente
DEFINE v_ruta          	   CHAR(47);	--Ruta
DEFINE v_entre_calles      CHAR(40);	--Entre Calles
DEFINE v_observaciones     CHAR(80);	--Datos Complementarios
DEFINE v_numerociudad	   SMALLINT;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 	   INT;   		--Numero Colonia Direccion Cliente
DEFINE v_numerocalle 	   INT;   		--Numero Calle Direccion Cliente
DEFINE v_numeroextcalle	   CHAR(10);	--Numero Exterior Calle Direccion Cliente
DEFINE v_estado 		   CHAR(2);	--Numero Estado
DEFINE v_nombrecalle	   CHAR(30);	--Nombre Calle Catalogo Calles
DEFINE v_centro			   INT;   		--Centro Catalogo de Zonas
DEFINE v_jefegrupozona	   INT;  		--Clave Jefe Grupo Zona
DEFINE v_supervisorzona	   INT;   		--Clave Supervisor Zona
--jom ini catalogos
DEFINE v_numerociudadcoppel  integer;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniacoppel integer;		--Numero Colonia Direccion Cliente
--jom fin catalogos

DEFINE v_status_cred	CHAR(2);

DEFINE v_confirmacion	CHAR(5);

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE v_capital_tc   		DECIMAL(18,2);	--capital_tc
DEFINE v_interes_tc   		DECIMAL(18,2);	--interes_tc
DEFINE v_iva_interes_tc   	DECIMAL(18,2);	--iva_interes_tc
DEFINE v_capital_ven_tc   	DECIMAL(18,2);	--capital_ven_tc
DEFINE v_interes_ven_tc   	DECIMAL(18,2);	--interes_ven_tc
DEFINE v_iva_interes_ven_tc DECIMAL(18,2);	--iva_interes_ven_tc
DEFINE v_moratorios_tc   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_iva_moratorios_tc  DECIMAL(18,2);	--iva_moratorios_tc
DEFINE v_pago_minimo_tc   	DECIMAL(18,2);	--sdo_pagar
DEFINE v_interes_pago_total_tc  DECIMAL(18,2);	--interes_pago_total_tc
DEFINE v_limite_tc   		DECIMAL(18,2);	--limite_tc
DEFINE v_disponible_tc   	DECIMAL(18,2);	--sdo_disponible
DEFINE v_periodo_tc_ini   	DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  		--periodo_tc_fin
DEFINE v_fecha_limite_pago_tc   DATE;	  		--pago_antes_de
DEFINE v_fecha_corte_tc   	DATE;		   	--fecha_corte
DEFINE v_dias_periodo_tc 		    INTEGER;		--dias_periodo_tc
DEFINE v_usted_debia, v_deuda_Ant   DECIMAL(18,2);	--usted_debia
DEFINE v_sus_abonos   			    DECIMAL(18,2);	--menos_abonos
DEFINE v_sus_compras   			    DECIMAL(18,2);	--mas_compras
DEFINE v_sus_comisiones 		    DECIMAL(18,2);	--sus_comisiones
DEFINE v_dispocisiones  		    DECIMAL(18,2);	--mas_disp_efectivo
DEFINE v_intereses   		    DECIMAL(18,2);	--mas_intereses
DEFINE v_iva   				    DECIMAL(18,2);	--mas_iva
DEFINE v_rendimientos   	    DECIMAL(18,2);	--mas_rendimientos
--jom ini SBC
DEFINE v_comisiones_sbc         DECIMAL(18,2);	--mas_comisiones_sbc
DEFINE v_iva_comisiones_sbc     DECIMAL(18,2);  --mas_iva_comisiones_sbc
--jom fin SBC
--jom ini repos
DEFINE V_comis_repos           DECIMAL(18,2);  --comision por reposicion
--jom fin repos
DEFINE v_iva_comisiones   	 DECIMAL(18,2);	--mas_iva comisiones
DEFINE v_iva_suc   			 DECIMAL(18,2);	--mas_iva
DEFINE v_sdo_retenido        DECIMAL(18,2);	--SALDO RETENIDO
DEFINE v_fecha_apertura		 DATE;			--fecha de apertura
DEFINE v_periodo_anterior    DATE;			--Fecha Periodo Anterior
DEFINE v_capital_debe 		DECIMAL(14,2);
DEFINE v_interes_debe 		DECIMAL(14,2);
DEFINE v_interes_pagado		DECIMAL(14,2);
DEFINE v_iva_debe 			DECIMAL(14,2);
DEFINE v_iva_pagado 		DECIMAL(14,2);


DEFINE v_mora_sdo_ordi		DECIMAL(14,2);
DEFINE v_mora_sdo_ordi_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope		DECIMAL(14,2);
DEFINE v_mora_provi_ordi	DECIMAL(14,2);
DEFINE v_mora_provi_cope	DECIMAL(14,2);
DEFINE v_mora_iva_debe		DECIMAL(14,2);
DEFINE v_mora_iva_pagado	DECIMAL(14,2);
DEFINE v_capital_status		CHAR(1);
DEFINE v_fecha_cuota		DATE;
DEFINE v_moratorios_tcA   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_moratorios_tcB   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_monto_financiado	DECIMAL(18,2);
DEFINE v_campo_trabajo1	DECIMAL(14,2);

DEFINE v_base_iva			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_descuento			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_subtotal			DECIMAL(14,2); -- CFDI 3.3
DEFINE v_total				DECIMAL(14,2); -- CFDI 3.3

DEFINE v_monto_surcharge	DECIMAL(14,2); -- Separacion de Comision e Iva
DEFINE v_iva_surcharge		DECIMAL(14,2); -- Separacion de Comision e Iva
DEFINE v_comisiones_surge 	DECIMAL(14,2);
--------------------------------------------------------
--	VARIABLES GENERACION DETALLE EDO CUENTA
--------------------------------------------------------
DEFINE v_dia           		char(2);
DEFINE v_mes           		char(2);
DEFINE v_ano	       		char(4);
DEFINE v_referencia    		char(296);
DEFINE v_referencia23  		char(279);
DEFINE v_rfc_comer     		char(276);
DEFINE v_transacc      		char(4);
DEFINE v_monto         		decimal(18,2);
DEFINE v_concepto      		varchar(255);
DEFINE v_naturaleza    		char(1);
DEFINE v_letra         		char(15);
DEFINE v_fecha_mov     		char(12);

DEFINE v_compra	       		decimal(18,2);
DEFINE v_abono	       		decimal(18,2);

DEFINE v_maximo        		INTEGER;
DEFINE v_contador      		smallint;
--------------------------------------------------------
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
--------------------------------------------------------
DEFINE v_secuencia_aclara	SMALLINT;
DEFINE v_nlinea_aclara		SMALLINT;
DEFINE v_fecha_aclara		DATE;
DEFINE v_descripcion		VARCHAR(255);
DEFINE v_importe			DECIMAL(18,2);
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
DEFINE v_cuenta_mensajes	SMALLINT;
DEFINE v_secuencia_mensaje	SMALLINT;
DEFINE v_nlinea_mensajes	SMALLINT;
DEFINE v_si_paga		    VARCHAR(255);
DEFINE v_mensajes			VARCHAR(255);

DEFINE v_factor				DECIMAL(14,10);
DEFINE v_aplica_factor		DECIMAL(14,2);
DEFINE v_usted_debe			DECIMAL(18,2);

DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
DEFINE v_tasa_mensual		 DECIMAL(18,2);
DEFINE v_tasa_anual			 DECIMAL(18,2);
DEFINE v_saldo_promedio		 DECIMAL(18,2);
DEFINE v_tasa_mora			 DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	 DECIMAL(18,2);

DEFINE v_sdo_acum_mes_cap  	DECIMAL(18,2);
DEFINE v_dias_acum_cap     	DECIMAL(18,2);

DEFINE GLOBAL v_cat			DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat2		DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_cat3		DECIMAL(18,2) DEFAULT 0;
DEFINE  v_catAux			DECIMAL(18,2) ;

--------------------------------------------------------
--	VARIABLES GENERACION CLAVE DE COBRANZA
--------------------------------------------------------
DEFINE v_cl_cobranza        CHAR(63);

DEFINE v_tp_cliente         CHAR(2);
DEFINE v_situacion          CHAR(1);
DEFINE v_situacion_esp      char(3); -- Campo Req 09087
DEFINE v_estado_civil       CHAR(1);
DEFINE v_tp_casa            CHAR(1);
DEFINE v_sexo               CHAR(1);
DEFINE v_cantidad           CHAR(2);
DEFINE v_antiguedad         CHAR(2);
DEFINE v_nacimiento         CHAR(2);
DEFINE v_mto_tot_adeudo     CHAR(5);
DEFINE v_adeudo_vencido     CHAR(5);
DEFINE v_fec_ult_pago       CHAR(4);
DEFINE v_fec_ult_pago_month CHAR(2);
DEFINE v_fec_ult_pago_year  CHAR(2);
DEFINE v_cuantos_avisos     INTEGER;
DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_avisos 	    	CHAR(1);
-- INICIO CAH *** RQM 09 117 ***
--DEFINE v_nivel_eficiencia   CHAR(2);
DEFINE v_nivel_eficiencia   CHAR(1);
-- FIN CAH *** RQM 09 117 ***
DEFINE v_fecha_ultimo_pago	DATE;

DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		    	VARCHAR(40);
DEFINE v_clave2		    	VARCHAR(40);
DEFINE v_clave3		    	VARCHAR(40);
DEFINE v_clave4		    	VARCHAR(40);
DEFINE v_clave5             VARCHAR(40);
DEFINE v_clave6             VARCHAR(3);

DEFINE posicion11            CHAR(5);
DEFINE posicion17            CHAR(5);

DEFINE cInserto              CHAR(15);
-- jom ini parametro sal min
DEFINE v_SalarioMinimoCoppel  SMALLINT;
-- jom fin parametro sal min
DEFINE v_numprod              CHAR(4);
--INICIO-----LHM
DEFINE v_comisiones_iva      DECIMAL(18,2);
DEFINE v_intereses_iva       DECIMAL(18,2);
DEFINE v_intereses_pag       DECIMAL(18,2);
DEFINE v_saldos_menos_pag    DECIMAL(18,2);
DEFINE v_compras_disp        DECIMAL(18,2);
--FIN--------LHM
DEFINE vfechacaptura         DATE;
DEFINE vfolio_csuac          CHAR(12);       
DEFINE vfechahora            DATE;
DEFINE vdescripcion          VARCHAR(255);
DEFINE vimportereclamado,v_saldo_diferido     DECIMAL(14,2);
DEFINE vMto_otorg            DECIMAL(18,2); -- inserto de cuadro comparativo
DEFINE vPos_Inserto          SMALLINT;     -- inserto de cuadro comparativo
Define cInsertoAux1     CHAR(15); 
Define cInsertoAux2     CHAR(15); 
DEFINE vciudades smallint;

DEFINE dFHoy_1m, dFHoy_13m, dFHoy_12m, dFech_1erComp, dFech_alta, dFhUltCompAct, dFhUltCompAnt, dFhUltPagoAnt DATE;
DEFINE iMoras, iDiasTrans INTEGER;
DEFINE	vlsecuencia	DECIMAL (18);
DEFINE vlfechaor date;

DEFINE	vlComprasDif	DECIMAL(14,2);
DEFINE	vlsaldo_corte	DECIMAL (14,2);
DEFINE	vfcancelado		DATE;
DEFINE iMesesLiq INTEGER;
DEFINE dMonto_No_Exigible DECIMAL(18,2);
DEFINE cCodRetMeses CHAR(5);
DEFINE cFolioSuc CHAR(16);  
DEFINE vCatFinal            DECIMAL(21,10);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      VARCHAR(80,1);
DEFINE dComisiones      	DECIMAL(18,2);
DEFINE dComs_GastCob		DECIMAL(18,2);
DEFINE dTasaInt      	DECIMAL(18,3);
DEFINE dPagoReq      	DECIMAL(18,2);
DEFINE dIntCredSol      	DECIMAL(18,2);
DEFINE dIntCredSolAux      	DECIMAL(18,2);
DEFINE dSaldoPromCredSol      	DECIMAL(18,2);
DEFINE dSaldoPromCredSolAux      	DECIMAL(18,2);
DEFINE dIntVenc      	DECIMAL(18,2);
DEFINE dSdoPromVen      	DECIMAL(18,2);
DEFINE dSdoPromVenAux      	DECIMAL(18,2);
DEFINE v_cod_ref            INTEGER;
DEFINE dComPend        DECIMAL(18,2);
DEFINE dIvaCom         DECIMAL(18,2);
DEFINE v_im            DECIMAL(21,10);
DEFINE mMntoComApert   DECIMAL(18,2); -- INI RQM 10 993 CAT.- Monto Comision Apertura
DEFINE mMntoComAnual   DECIMAL(18,2); -- Monto Comision Anualidad
DEFINE cCobrComisAnual CHAR(1);
DEFINE dMtoComAnualTit DECIMAL(18,2);
DEFINE dMtoComAnualAdi DECIMAL(18,2);
DEFINE dClvComAnualTit CHAR(4);
DEFINE dClvComAnualAdi CHAR(4);      -- FIN RQM 10 993 CAT
DEFINE cCat_adicional  CHAR(1);
DEFINE iCountExist	   INTEGER;
DEFINE dtasa_prom_pond  	DECIMAL(18,8);
DEFINE dtasa_prom_pond_fin 	DECIMAL(18,2);
DEFINE dClvComApertura CHAR(4);
DEFINE v_Act	INTEGER;

------------------------------------------------------------------
-- DUCM Se agregan variables de catalogo de Centros de Impresion--
DEFINE sNumRegion CHAR(2); --Numero de region (centro de impresion)
DEFINE sNumCiudadB CHAR(4); --Numero de ciudad BanCoppel
DEFINE sNumCiudadC CHAR(3); --Numero de ciudad COPPEL

DEFINE vPagoMinMsi	DECIMAL(18,2); -- Pago minimo general de MSI
DEFINE cIVA_cfdi	CHAR(04); -- Valor de IVA para CFDI 4.0
DEFINE vObjetoImp	CHAR(02); -- Objeto Impuesto para CFDI 4.0
DEFINE vValBase		DECIMAL(18,2); -- Valor para CFDI 4.0
DEFINE vIvaCfdi		DECIMAL(18,2); -- IVA PARA CFDI X CUENTA
DEFINE vIvaInteresesReales	DECIMAL(18,2); -- Valor para CFDI 4.0
DEFINE vIvaDeComisiones	DECIMAL(18,2); -- IVA de las Comisiones para CFDI 4.0
DEFINE vInteresesReales	DECIMAL(18,2); -- Valor para CFDI 4.0
DEFINE vMtoPagosFijos	DECIMAL(18,2); -- Monto Mensual PagOs Fijos
DEFINE vTipProdCarterasTDC	CHAR(2); -- Tipo de producto Carteras
DEFINE v_pago_minimo_msi	DECIMAL(18,2); -- PAGO MINIMO + MSI
DEFINE v_pago_minimo_msi_pf	DECIMAL(18,2); -- PAGO MINIMO + MSI + PF
DEFINE vSdoDifPlazo		DECIMAL(18,2); -- SALDO DIFERIDO O A PLAZO
DEFINE VSdoPeriCort		DECIMAL(18,2); -- SALDO DEL PERIODO O AL CORTE

DEFINE vlfCorte		date;
DEFINE vlDiaCorte 	smallint;
DEFINE vTermPago_MesUno	CHAR(12);
DEFINE vPagariasIntereses1	CHAR(20);
DEFINE vPagoMinx2	CHAR(12);
DEFINE vTermPago_MesDos	CHAR(12);
DEFINE vPagariasIntereses2	CHAR(20);
DEFINE vPagoMinx5	CHAR(12);
DEFINE vTermPago_MesCinco	CHAR(12);
DEFINE vPagariasIntereses5	CHAR(20);
DEFINE v_iva_inter_comi	DECIMAL(14,2);
DEFINE v_sdo_deudor_tot	DECIMAL(14,2);
DEFINE vSdosCargosReg	DECIMAL(18,2);
DEFINE vSdoCargoMesesConySinInt	DECIMAL(14,2);
DEFINE v_inter_comi_dist_ult_pag	DECIMAL(18,2);
DEFINE vIntPag_12m	DECIMAL(18,2);
DEFINE v_int_gral	DECIMAL(18,2);
DEFINE vComiPag_12m	DECIMAL(18,2);
DEFINE v_comi_gral	DECIMAL(18,2);
DEFINE vAnualidadPag_12m	DECIMAL(12,2);
DEFINE v_anualidad		DECIMAL(12,2);
DEFINE v_comi_surcharge	DECIMAL(12,2);
DEFINE vComprasDifSinInt	DECIMAL(18,2);
DEFINE vComprasDifConInt	DECIMAL(18,2);
DEFINE vFechaOper	CHAR(12);
DEFINE vNumTarjeta	CHAR(20);
DEFINE v_tipo_tarjeta	CHAR(1);
DEFINE vFechaAclara	CHAR(12);
DEFINE vFolioAclara	CHAR(12);
DEFINE vFechaMov	CHAR(12);
DEFINE vStatusAclara	CHAR(40);
DEFINE v_linea	INTEGER;
DEFINE vDescripcion_OR	CHAR(90);
DEFINE vDescripcion_M0	CHAR(90);
DEFINE vDescripcion_TP	CHAR(90);
DEFINE vDescripcion_DF	CHAR(90);
DEFINE vDescripcion_DE	CHAR(90);
DEFINE vDescripcion_OL	CHAR(90);
DEFINE v_saldo_base	CHAR(12);
DEFINE v_dias_periodo	CHAR(12);
DEFINE v_tasa_inter_aplicable	CHAR(12);
DEFINE v_monto_interes	CHAR(12);
DEFINE v_tipo_proceso	CHAR(2);
DEFINE vTipoTdcPF	CHAR(1);
DEFINE vNumCredCredsol	CHAR(20);
DEFINE v_numtdc_pf	CHAR(20);

DEFINE v_numeroextcall	CHAR(50);
DEFINE v_numerointcalle	CHAR(50);
DEFINE v_departamento	CHAR(50);
DEFINE vInt_vencidos	DECIMAL(18,2);
DEFINE vIvaIntVenPagados	DECIMAL(18,2);
DEFINE vIntSinDif	DECIMAL(18,2);
DEFINE vIvaIntSinDif	DECIMAL(18,2);
DEFINE vMtoIntPF	CHAR(12);
DEFINE v_inter_comi	DECIMAL(14,2);
DEFINE vSdoDebeComprasMSI	DECIMAL(14,2);
DEFINE vNumCreditoMsi	CHAR(20);
DEFINE vNumPrestamoMSI	CHAR(20);
DEFINE vTasaIntApliMSI	CHAR(05);
DEFINE v_sdo_favor	DECIMAL(18,2);
DEFINE vTasaPF	CHAR(12);
DEFINE int_maximos_x_mes	DECIMAL (8,2);
DEFINE vCalculaMesPagMin1	DECIMAL(12,2);
DEFINE InterIvaProyec	DECIMAL (18,2);
DEFINE vCalculaMesPagMin2	DECIMAL(12,2);
DEFINE InterIvaProyec2	DECIMAL (18,2);
DEFINE vCalculaMesPagMin5	DECIMAL(12,2);
DEFINE InterIvaProyec5	DECIMAL (18,2);
DEFINE v_dist_carg_dif_msi	DECIMAL(12,2);
DEFINE v_dist_carg_dif_con_int	DECIMAL(12,2);
DEFINE v_total_cargos	DECIMAL(14,2);
DEFINE v_iva_inter_comi_dist_ult_pag	DECIMAL(18,2);
DEFINE v_pago_capital	DECIMAL(18,2);
DEFINE v_secuencia	INTEGER;
DEFINE v_num_vencido	INTEGER;
DEFINE vCalculaDias	INTEGER;
DEFINE vMoraMtoInt	CHAR(12);
DEFINE v_mora_tasa	DECIMAL(18,2);
DEFINE v_mora_dias_anio	DECIMAL(18,2);
DEFINE vNumCredPF	CHAR(20);
DEFINE vIvaIntPerDif	DECIMAL(18,2);
DEFINE vdiacortedif	INTEGER;
DEFINE vMontoCompra	DECIMAL(18,2);
DEFINE v_periodo_anterior_dif	DATE;
DEFINE existe_df	INTEGER;

DEFINE vMenosPeriAnt	DATE;
DEFINE vMesPerAnt	CHAR(2);
DEFINE vAnioPerAnt	CHAR(4);

DEFINE vFechAnioAnt	DATE;
DEFINE vMesAnioAnt	CHAR(2);
DEFINE vAnioAnt		CHAR(4);


--SET DEBUG FILE TO "/ifxsif01/joel/Modificados/generaestadosdecuenta.out";
--TRACE ON;

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "000";
LET v_cod_ret_otro = "000";

LET sql_err = "";
LET v_corta_linea_detalle 	= 40;
LET v_corta_retorno 		= 0;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
LET v_sucursal      = "";
LET v_ult_dir_clie 	= 0;
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO EDO CUENTA
--------------------------------------------------------
LET v_numcte        	  = "";
LET v_num_tarjeta   	  = "";
LET v_nombre_cte    	  = "";
LET v_direccion_cn  	  = "";
LET v_direccion_col	      = "";
LET v_direccion_del 	  = "";
LET v_edo_cd     		  = "";
LET v_sucursal_nombre     = "";
LET v_sucursal_gerente    = "";
LET v_sucursal_tel        = "";
LET v_cod_postal    	  = "";
LET v_cl_cobra      	  = "";
LET v_rfc           	  = "";
LET v_ruta           	  = "";
LET v_entre_calles   	  = "";
LET v_observaciones  	  = "";

LET v_numerociudad 		= 0;
LET v_numerocolonia 	= 0;
LET v_numerocalle 		= 0;
LET v_numeroextcalle 	= "";
LET v_estado 			= "";
LET v_nombrecalle		= "";
LET v_centro			= 0;
LET v_jefegrupozona		= 0;
LET v_supervisorzona	= 0;
LET v_status_cred 		= "";

LET v_confirmacion		= "";

--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
LET v_capital_tc   			    = 0;	--capital_tc
LET v_interes_tc   			    = 0;	--interes_tc
LET v_iva_interes_tc   		  = 0;	--iva_interes_tc
LET v_capital_ven_tc   		  = 0;	--capital_ven_tc
LET v_interes_ven_tc   		  = 0;	--interes_ven_tc
LET v_iva_interes_ven_tc   	= 0;	--iva_interes_ven_tc
LET v_moratorios_tc   		  = 0;	--moratorios_tc
LET v_iva_moratorios_tc   	= 0;	--iva_moratorios_tc
LET v_pago_minimo_tc   		  = 0;	--sdo_pagar
LET v_interes_pago_total_tc = 0;	--interes_pago_total_tc
LET v_limite_tc   			    = 0;	--limite_tc
LET v_disponible_tc   		  = 0;	--sdo_disponible
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_fecha_limite_pago_tc  = " ";	--pago_antes_de
LET v_fecha_corte_tc   		  = " ";	--fecha_corte
LET v_dias_periodo_tc 		  = 0;	--dias_periodo_tc
LET v_usted_debia   		    = 0;	--usted_debia
LET v_sus_abonos   			    = 0;	--menos_abonos
LET v_sus_compras   		    = 0;	--mas_compras
LET v_sus_comisiones 		    = 0;	--sus_comisiones
LET v_dispocisiones  		    = 0;	--mas_disp_efectivo
LET v_intereses   			    = 0;	--mas_intereses
LET v_iva   				        = 0;	--mas_iva
LET v_rendimientos   		    = 0;	--mas_rendimientos
--jom ini SBC
LET v_comisiones_sbc        = 0;	--mas_comisiones_sbc
LET v_iva_comisiones_sbc    = 0;  --mas_iva_comisiones_sbc
--jom fin SBC
LET V_comis_repos           = 0; --comision por reposicion
--jom ini catalogos
let v_numerociudadcoppel  = 0;	--Numero Ciudad Direccion Cliente
let v_numerocoloniacoppel = 0;	--Numero Colonia Direccion Cliente
--jom fin catalogos

LET v_iva_comisiones	    = 0;
LET v_iva_suc				      = 0;	--iva sucursal
LET v_sdo_retenido        = 0;
LET v_fecha_apertura	    = " ";	--fecha de apertura
LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior

LET v_capital_debe 			= 0;
LET v_interes_debe 			= 0;
LET v_interes_pagado		= 0;
LET v_iva_debe 				  = 0;
LET v_iva_pagado 			  = 0;

LET v_mora_sdo_ordi			  = 0;
LET v_mora_sdo_ordi_pag		= 0;
LET v_mora_sdo_cope_pag		= 0;
LET v_mora_sdo_cope			  = 0;
LET v_mora_provi_ordi		  = 0;
LET v_mora_provi_cope		  = 0;
LET v_mora_iva_debe			  = 0;
LET v_mora_iva_pagado		  = 0;
LET v_capital_status		  = "";
LET v_fecha_cuota			    = " ";
LET v_moratorios_tcA   		= 0;	--moratorios_tc
LET v_moratorios_tcB   		= 0;	--moratorios_tc

LET v_monto_financiado		= 0;
LET v_campo_trabajo1 	    = 0;

LET v_base_iva				= 0; --CFDI 3.3
LET v_descuento				= 0; --CFDI 3.3
LET v_subtotal				= 0; --CFDI 3.3
LET v_total					= 0; --CFDI 3.3

LET v_monto_surcharge		= 0; -- Separacion de Comision e Iva
LET v_iva_surcharge			= 0; -- Separacion de Comision e Iva
LET v_comisiones_surge		= 0;

--------------------------------------------------------
--	VARIABLES GENERACION DETALLE EDO CUENTA
--------------------------------------------------------
LET v_dia          = "";
LET v_mes          = "";
LET v_ano	   	     = "";
LET v_referencia   = "";
LET v_referencia23 = "";
LET v_rfc_comer    = "";
LET v_transacc     = "";
LET v_monto        = 0;
LET v_concepto     = "";
LET v_naturaleza   = "";
LET v_letra        = "";
LET v_fecha_mov    = "";
LET v_compra       = "";
LET v_abono        = "";
LET v_maximo       = 0;
LET v_contador     = 0;
--------------------------------------------------------
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
--------------------------------------------------------
LET  v_secuencia_aclara		= 0;
LET  v_nlinea_aclara		  = 0;
LET  v_fecha_aclara			  = " ";
LET  v_descripcion			  = "";
LET  v_importe				    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
LET v_cuenta_mensajes 		= 0;
LET  v_secuencia_mensaje	= 0;
LET  v_nlinea_mensajes		= 0;
LET  v_si_paga				    = 0;
LET  v_mensajes				    = "";

LET v_factor		    = 0;
LET v_aplica_factor = 0;
LET v_usted_debe    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
LET v_tasa_mensual 		  = 0 ;
LET v_tasa_anual		    = 0 ;
LET v_saldo_promedio	  = 0 ;
LET v_tasa_mora			    = 0 ;
LET v_tasa_mensual_mora	= 0 ;

LET v_sdo_acum_mes_cap = 0;
LET v_dias_acum_cap    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION CLAVE DE COBRANZA
--------------------------------------------------------
LET v_cl_cobranza        = "";

LET v_tp_cliente         = "01";
LET v_situacion          = "";
LET v_situacion_esp      = ""; -- Inizializacion
LET v_estado_civil       = "";
LET v_tp_casa            = "";
LET v_sexo               = "";
LET v_cantidad           = "";
LET v_antiguedad         = "";
LET v_nacimiento         = "";
LET v_mto_tot_adeudo     = "";
LET v_adeudo_vencido     = "";
LET v_fec_ult_pago       = "";
LET v_fec_ult_pago_month = "";
LET v_fec_ult_pago_year  = "";
LET v_cuantos_avisos	   = 0;

LET v_monto_ult_convenio = "";
LET v_fecha_ult_convenio = "";
LET v_est_cumpl_convenio = "";
LET v_avisos 	    	 = "0";
LET v_nivel_eficiencia	 = 0;
LET v_fecha_ultimo_pago  = " ";

LET v_salario            = 0;
LET v_monto_adeudo		   = 0;
LET v_mto_adeudo_venc    = 0;

LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5            = "";
LET v_clave6            = "";

LET posicion11 = "";
LET posicion17 = "";

LET cInserto  = "";
-- jom ini parametro sal min
LET v_SalarioMinimoCoppel= 0;
-- jom fin parametro sal min
LET v_numprod = "";
LEt vfolio_csuac = '';

--INICIO-----LHM
LET v_comisiones_iva     = 0;
LET v_intereses_iva      = 0;
LET v_intereses_pag      = 0;
LET v_saldos_menos_pag   = 0;
LET v_compras_disp       = 0;
--FIN--------LHM
LET vfechacaptura        = date(1);
LET vfechahora        = date(1);
LET vdescripcion        = '';
LET vimportereclamado   = 0;
LET vMto_otorg          = 0;
LET vPos_Inserto        = 0;
LET cInsertoAux1  = '';
LET cInsertoAux2  = '';
LET vciudades	= 0;
LET v_saldo_diferido=0;
LET vlComprasDif  = 0;
LET	vlsaldo_corte = 0;
LET	v_catAux = 0;
LET iMesesLiq = 0;
LET dMonto_No_Exigible = 0;
LET cCodRetMeses = "";
LET dComPend              = 0;
LET dIvaCom               = 0;
LET cFolioSuc = "";
LET dComisiones      	= 0;
LET dComs_GastCob		= 0;
LET dTasaInt      	= 0;
LET dIntCredSolAux =0;
LET dIntCredSol =0;
LET dSaldoPromCredSolAux =0;
LET dSaldoPromCredSol =0;
LET dPagoReq =0;
LET dIntVenc      =0;
LET dSdoPromVen     =0;
LET dSdoPromVenAux     =0;
LET vCatFinal =0;
LET cCodRet             = "000000";
LET cMensajeRet         = "Se realizo el calculo correctamente";
LET v_cod_ref          = 0;
LET v_im    = 0;
LET mMntoComApert   = 0;    -- INI RQM 10 993 CAT
LET mMntoComAnual   = 0;
LET cCobrComisAnual = 0;
LET dMtoComAnualTit = 0;
LET dMtoComAnualAdi = 0;
LET dClvComAnualTit = '';
LET dClvComAnualAdi = '';
LET cCat_adicional  = '';    -- FIN RQM 10 993 CAT
LET iCountExist		= 0;
LET dtasa_prom_pond	= 0;
LET dtasa_prom_pond_fin = 0;
LET dClvComApertura	= 0;
LET v_Act	= 0;

----------------------------------------------------------------------------------
-- Se limpian variables para los campos de region, ciudad y centro de impresion --
LET sNumRegion	= '0';
LET sNumCiudadB = '0';
LET sNumCiudadC = '0';

---- Limpieza de variables cfdi 4.0
LET vPagoMinMsi	= 0;
LET cIVA_cfdi	= 0;
LET vObjetoImp	= '';
LET vValBase	= 0;
LET vIvaCfdi	= 0;
LET vIvaInteresesReales	= 0;
LET vIvaDeComisiones	= 0;
LET vInteresesReales	= 0;
LET vMtoPagosFijos	= 0;
LET vTipProdCarterasTDC	= '';
LET v_pago_minimo_msi	= 0;
LET v_pago_minimo_msi_pf	= 0;
LET vSdoDifPlazo	= 0;
LET VSdoPeriCort	= 0;

LET vlfCorte	= date(1);
LET vlDiaCorte	= 20;
LET vTermPago_MesUno	= '';
LET vPagariasIntereses1	= '';
LET vPagoMinx2	= '';
LET vTermPago_MesDos	= '';
LET vPagariasIntereses2 = '';
LET vPagoMinx5	= '';
LET vTermPago_MesCinco	= '';
LET vPagariasIntereses5 = '';
LET v_iva_inter_comi	= 0;
LET v_sdo_deudor_tot	= 0;
LET vSdosCargosReg	= 0;
LET vSdoCargoMesesConySinInt	= 0;
LET v_inter_comi_dist_ult_pag	= 0;
LET vIntPag_12m	= 0;
LET v_int_gral	= 0;
LET vComiPag_12m	= 0;
LET v_comi_gral	= 0;
LET vAnualidadPag_12m	= 0;
LET v_anualidad			= 0;
LET v_comi_surcharge	= 0;
LET vComprasDifSinInt	= 0;
LET vComprasDifConInt	= 0;
LET vFechaOper	= '';
LET vNumTarjeta	= '';
LET v_tipo_tarjeta	= '';
LET vFechaAclara	= '';
LET vFolioAclara	= '';
LET vFechaMov	= '';
LET vStatusAclara	= '';
LET v_linea	= 0;
LET vDescripcion_OR	= '';
LET vDescripcion_M0	= '';
LET vDescripcion_TP	= '';
LET vDescripcion_DF	= '';
LET vDescripcion_DE	= '';
LET vDescripcion_OL	= '';
LET v_saldo_base	= "";
LET v_dias_periodo	= "";
LET v_tasa_inter_aplicable	= "";
LET v_monto_interes	= "";
LET v_tipo_proceso	= "";
LET vTipoTdcPF	= '';
LET vNumCredCredsol	= '';
LET v_numtdc_pf	= 0;

LET v_numeroextcall	= '';
LET v_numerointcalle	= '';
LET v_departamento	= '';
LET vInt_vencidos	= 0;
LET vIvaIntVenPagados	= 0;
LET vIntSinDif	= 0;
LET vIvaIntSinDif	= 0;
LET vMtoIntPF	= '';
LET v_inter_comi	= 0;
LET vSdoDebeComprasMSI	= 0;
LET vNumCreditoMsi	= '';
LET vNumPrestamoMSI	= '';
LET vTasaIntApliMSI = '';
LET v_sdo_favor	= 0;
LET vTasaPF	= '';
LET int_maximos_x_mes	= '';
LET vCalculaMesPagMin1	= 0;
LET InterIvaProyec	= '';
LET vCalculaMesPagMin2	= 0;
LET InterIvaProyec2	= '';
LET vCalculaMesPagMin5	= 0;
LET InterIvaProyec5	= '';
LET v_dist_carg_dif_msi	= 0;
LET v_dist_carg_dif_con_int	= 0;
LET v_total_cargos	= 0;
LET v_iva_inter_comi_dist_ult_pag	= 0;
LET v_pago_capital	= 0;
LET v_secuencia	= 0;
LET v_num_vencido	= 0;
LET vCalculaDias	= 0;
LET vMoraMtoInt	= '';
LET v_mora_tasa	= 0;
LET v_mora_dias_anio	= 0;
LET vNumCredPF	= '';
LET vIvaIntPerDif	= 0;
LET vdiacortedif	= 0;
LET vMontoCompra	= 0;
LET v_periodo_anterior_dif	= " ";
LET existe_df	= 0;

LET vMenosPeriAnt	= DATE(1);
LET vMesPerAnt	= '';
LET vAnioPerAnt	= '';

LET vFechAnioAnt	= date(1);
LET vMesAnioAnt	= '';
LET vAnioAnt	= '';


--set pdqpriority 11;

BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			DROP TABLE IF EXISTS univer_credsol;
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF
	END EXCEPTION WITH RESUME ;
   
	set isolation to dirty read;
	set lock mode to wait 3;

--   SET DEBUG FILE TO "/informix/Israel/generaestadosdecuenta.out";
--   TRACE ON;

   	--##############################################################
		--##	SALARIO MINIMO COPPEL           			      ##
   	--##############################################################
	SELECT valor
		INTO v_SalarioMinimoCoppel
	FROM bdisolic:ss_param
	WHERE empresa = pempresa
	AND secuencia = 303;

	IF v_SalarioMinimoCoppel IS NULL THEN
		LET v_SalarioMinimoCoppel= 0;
	END IF;

   	--##############################################################
		--##	GENERACION ENCABEZADO EDO CUENTA				      ##
   	--##############################################################
    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
	SELECT a.num_producto,		a.numcte,				a.sucursal,			a.fecha_apertura,
		   a.tasa_interes,		a.tasa_moratorios,		status_cred,		nvl(b.act,-1)
		INTO v_numprod, 		v_numcte, 				v_sucursal, 		v_fecha_apertura,
		   v_tasa_anual,		v_tasa_mora,			v_status_cred,		v_Act
	FROM sd_maecred a, sd_maesdos b
	WHERE a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.empresa = pempresa
	AND a.num_credito = pnum_credito;

	IF v_status_cred = 'AA' OR (v_Act = 0 AND v_status_cred = 'E1') THEN
		LET v_avisos = '0';
	ELIF v_status_cred = 'BA' OR (v_Act = 1 AND v_status_cred = 'E1') THEN
		LET v_avisos = '1';
	ELIF v_status_cred = 'BT' OR v_status_cred IN('E2','E3') THEN
		LET v_avisos = '2';
	ELSE 
		LET v_avisos = '0';
	END IF;

	IF v_numprod ="7000" THEN--Se cambia el cat para creditos platinum
		LET v_catAux = v_Cat2;
	ELIF v_numprod ="8100" THEN --AAME RQM 10 679 se modifica para cambiar el CAT cuando sea TDC Oro
		LET v_catAux = v_Cat3;		
	ELSE
		LET v_catAux = v_Cat;
	END IF;

-------------------------------------------------------------
-- Solicitud de Resta de Tasa Moratoria - la Tasa Ordinaria
-------------------------------------------------------------
	LET  v_tasa_mora = v_tasa_mora - v_tasa_anual;
	
	IF v_tasa_mora < 0 THEN
		LET v_tasa_mora = v_tasa_mora * -1;
	END IF;
-------------------------------------------------------------
--SD_TARJETA
-------------------------------------------------------------
	SELECT b.num_tarjeta 
		INTO v_num_tarjeta
	FROM sd_tarjeta b
	WHERE b.empresa = pempresa
	AND b.num_credito = pnum_credito
	AND b.tipo_tarjeta = "T" AND b.status_tar = "A";

	IF v_num_tarjeta IS NULL THEN
	-------------------------------------------------------------
	--SD_TARJETA
	-------------------------------------------------------------
	SELECT MAX(secuencia)
		INTO v_ult_dir_clie
	FROM sd_tarjeta
	WHERE empresa = pempresa
	AND num_credito = pnum_credito
	AND tipo_tarjeta="T";

	-------------------------------------------------------------
	--SD_TARJETA
	-------------------------------------------------------------
	SELECT b.num_tarjeta 
		INTO v_num_tarjeta
	FROM sd_tarjeta b
	WHERE b.empresa = pempresa
		AND b.num_credito = pnum_credito
		AND b.secuencia = v_ult_dir_clie;
	END IF;
-------------------------------------------------------------
--SI_DIRECCIONES
-------------------------------------------------------------
--SI_CLIENTE
-------------------------------------------------------------
	SELECT 	Trim(a.nombre1) || " " ||Trim(a.nombre2) || " " ||
			Trim(a.apell_paterno) || " " ||Trim(a.apell_materno),
			NVL(a.rfc, a.rfc_alterno),
			NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2),'')
	INTO 	v_nombre_cte,
			v_rfc,
			v_antiguedad
	FROM bdinteg:si_cliente a
	WHERE a.numcte = v_numcte;
-------------------------------------------------------------
--SI_DIRECCIONES
-------------------------------------------------------------
	SELECT 	b.numeroextcalle,		b.numerointcalle,		b.departamento,
			b.cod_postal,			b.entre_calles,			--b.observaciones,
			b.numerociudad,			b.numerocolonia,		b.numerocalle,
			b.numeroextcalle,		b.estado
		INTO v_numeroextcall,		v_numerointcalle,		v_departamento,
			v_cod_postal,			v_entre_calles,			--v_observaciones,
			v_numerociudad,			v_numerocolonia,		v_numerocalle,
			v_numeroextcalle,		v_estado
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte  = v_numcte AND tipo_dir="1";
	
	-- CONVERTIR ARMAR CON DIRECCION			
	IF TRIM(NVL(v_numeroextcall,'0')) = '0' THEN
		LET v_numeroextcall = '';
	end if;
	IF TRIM(NVL(v_numerointcalle,'0')) = '0' THEN
		LET v_numerointcalle = '';
	end if;
	IF TRIM(NVL(v_departamento,'0')) = '0' THEN
		LET v_departamento = '';
	end if;
	
	LET v_direccion_cn = TRIM(v_numeroextcall) || " " || TRIM(v_numerointcalle) || " " || TRIM(v_departamento);
	
-------------------------------------------------------------
--SI_CATCALLES
-------------------------------------------------------------
	SELECT Trim(c.nombrecalle)
		INTO v_nombrecalle
	FROM bdinteg:si_catcalles c
	WHERE c.numerocalle = v_numerocalle;
-------------------------------------------------------------
--SI_CATZONAS
-------------------------------------------------------------
	SELECT 	d.nombrezona,			d.centro, d.jefegrupozona,		d.supervisorzona,
			d.numerociudadcoppel,	d.numerocoloniacoppel
	INTO 	v_direccion_col,		v_centro,v_jefegrupozona,		v_supervisorzona,
			v_numerociudadcoppel, 	v_numerocoloniacoppel
	FROM bdinteg:si_catzonas d
	WHERE  d.numerociudad = v_numerociudad
	AND  d.numerocolonia=v_numerocolonia;
	
-- Jom ini catalogos
	if ( v_numerociudadcoppel is null or v_numerociudadcoppel = ''  or  v_numerociudadcoppel = 0) then
		let v_numerociudadcoppel = v_numerociudad;
		let v_numerocoloniacoppel = v_numerocolonia;
	end if;
-- Jom fin catalogos
    -------------------------------------------------------------
--SI_CATCIUDADES
-------------------------------------------------------------
	SELECT e.nombreciudad
		INTO v_direccion_del
	FROM bdinteg:si_catciudades e
	WHERE e.numerociudad = v_numerociudad;
-------------------------------------------------------------
--SI_ESTADOS
-------------------------------------------------------------
	SELECT f.nombre
		INTO v_edo_cd
	FROM bdinteg:si_estados f
	WHERE  f.estado = v_estado;
-----------------------------------------
--------SD_CENTROSIMPRESION_COPPEL-------
	SELECT 	LPAD(num_region,2,0),	LPAD(num_ciudad_banco,4,0),	LPAD(num_ciudad_coppel,3,0)
		INTO sNumRegion,			sNumCiudadB,				sNumCiudadC
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

-------------------------------------------------------------
--SI_SUCURSALES
-------------------------------------------------------------
	SELECT 	d.nombre, 			d.gerente, 			d.iva -- iva de moratorios
		INTO v_sucursal_nombre,	v_sucursal_gerente, v_iva_suc
	FROM bdinteg:si_sucursales d
	WHERE d.empresa = pempresa
	AND d.sucursal = v_sucursal;

	select tel1 
	into v_sucursal_tel
	from bdinteg:si_ptf 
	where id_ptf = v_sucursal
	and tipo = 'S';
	
--------------------------------------------------------
--------------------------------------------------------
	LET v_direccion_cn = trim(v_nombrecalle) || " " || v_direccion_cn;
	-- Jom ini catalogos
	IF (v_numerociudadcoppel IS NULL)  THEN LET v_numerociudadcoppel = '0000'; END IF;
	IF (v_centro IS NULL)              THEN LET v_centro = '000000'; END IF;
	IF (v_jefegrupozona IS NULL)       THEN LET v_jefegrupozona = '00000000'; END IF;
	IF (v_supervisorzona IS NULL)      THEN LET v_supervisorzona = '00000000'; END IF;
	IF (v_numerocoloniacoppel IS NULL) THEN LET v_numerocoloniacoppel = '0000'; END IF;
	IF (v_numerocalle IS NULL)         THEN LET v_numerocalle = '000000'; END IF;
	IF (v_numeroextcalle IS NULL)      THEN LET v_numeroextcalle = '00000'; END IF;

	LET v_ruta = LPAD(v_numerociudadcoppel,4,'0')||"/"||
				LPAD(v_centro,6,'0')||"/"||
				LPAD(v_jefegrupozona,8,'0')||"/"||
				LPAD(v_supervisorzona,8,'0')||"/"||
				LPAD(v_numerocoloniacoppel,4,'0')||"/"||
	-- Jom fin catalogos
				LPAD(v_numerocalle,6,'0')||"/"||
				LPAD(TRIM(v_numeroextcalle),5,'0');
				
	IF v_ruta = '' OR v_ruta is null THEN
		LET sNumRegion = '00';
	END IF;
--------------------------------------------------------
-------------------------------------------------------
--                   Se obtiene el inserto               --
-------------------------------------------------------
	SELECT insertos
		INTO cInserto
	FROM bdicred:sd_marcaje
	WHERE empresa=pempresa
	AND num_credito= pnum_credito
	AND fecha_emision = pfechahoy;
		
	IF cInserto IS NULL THEN
		LET cInserto='000000000000000';
	END IF;

	LET iCountExist = 0;
	IF month(pfechahoy) = 3 THEN
		SELECT count(*) INTO iCountExist 
		FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro = '03';
	ELIF month(pfechahoy) = 9 THEN
		SELECT count(*) INTO iCountExist 
		FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro = '09';
	END IF;
	/*SELECT {AVOID_FULL("informix".sd_cuadro_comp_edocta)} count(empresa) INTO iCountExist 
	  FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy);*/
	
	-- Se genera el inserto para el cuadro comparativo (CONDUSEF)  MAHR
	--IF ((SELECT count(empresa) FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy)) > 0) THEN
	IF ( iCountExist > 0) THEN
		SELECT monto_otorgado INTO vMto_otorg FROM bdicred:sd_maesdoshist WHERE num_credito = pnum_credito AND fecha = pfechahoy;
		SELECT {+INDEX(bdicred:sd_cuadro_comp_edocta idx_mes_inserto)} no_inserto INTO vPos_Inserto FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy)
			AND vMto_otorg >= limite_inf AND vMto_otorg <= limite_sup;
		IF vPos_Inserto IS NULL THEN 
			SELECT {+INDEX(bdicred:sd_cuadro_comp_edocta idx_mes_inserto)} MAX(no_inserto) INTO vPos_Inserto FROM bdicred:sd_cuadro_comp_edocta WHERE mes_envio_cuadro::integer = month(pfechahoy);
		END IF;
		
		LET cInsertoAux1  = SubStr(trim(cInserto), 1, vPos_Inserto - 1 );
		LET cInsertoAux2  = SubStr(trim(cInserto), vPos_Inserto + 1, length(trim(cInserto)));

		LET cInserto = trim(cInsertoAux1) || '1' || trim(cInsertoAux2);
	END IF;
	--Se obtiene inserto Octubre y noviembre
	IF  month(pfechahoy) = 10 OR  month(pfechahoy) = 11 THEN
		IF v_status_cred in ('AA','BA','BT','E1','E2','E3')  THEN 
			SELECT count(numerociudad) 
				INTO vciudades 
			FROM bdinteg:"informix".si_ciudades_insertos
			WHERE numerociudad =v_numerociudad and estado = v_estado;	   
		  
			IF vciudades >= 1 THEN 
				LET cInsertoAux1  = SubStr(trim(cInserto), 1, len(cInserto)); 
				--LET cInsertoAux2  = SubStr(trim(cInserto), vPos_Inserto + 1, length(trim(cInserto))); 
				LET cInserto = '1' || trim(cInsertoAux1  );
			END IF;
		END IF;
	END IF;
	
	-- VALIDA SI TIENE MENOS DE 5 CARACTERES EL CODIGO POSTAL
	IF LENGTH(v_cod_postal) < 5 THEN
		LET v_cod_postal = LPAD(v_cod_postal,6,0);
	END IF;
	
	-------------------------------------------------------------
	--SD_MAESDOSHIST
	-------------------------------------------------------------
	-- CAPITAL VENCIDO,PAGO PARA NO GENERAR INTERESES, LIMITE DE CREDITO
	SELECT 	monto_vencido + mto_venc_trasp,
			sdo_cap_insoluto,			monto_otorgado,		sdo_retenido,		sdo_acum_mes_cap,		dias_acum_cap,
			sdo_cap_insoluto,			monto_vencido + mto_venc_trasp,
			int_tra_no_exig,			sdo_moratorio + sdo_contab_mora,
			monto_financiado,			mto_fin_ven_trasp
		INTO 		v_capital_ven_tc,
			v_interes_pago_total_tc,	v_limite_tc,		v_sdo_retenido,		v_sdo_acum_mes_cap,		v_dias_acum_cap,
			v_monto_adeudo,						v_mto_adeudo_venc,
			v_interes_ven_tc,					v_moratorios_tc,
			v_monto_financiado,			iMoras
	FROM sd_maesdoshist
	WHERE fecha = pfechahoy
	AND num_credito = pnum_credito
	AND empresa = pempresa;
	
	-------------------------------------------------------------
	--SD_MAESDOSHIST
	-------------------------------------------------------------
	
	--FECHA LIMITE DE PAGO
	SELECT 	prox_fecha_pago, 			fecha_proceso,	dia_corte 
		INTO v_fecha_limite_pago_tc,	vfcancelado,	vlDiaCorte
	FROM sd_maecredanexo
	WHERE empresa = pempresa AND num_credito = pnum_credito;
	
	-------------------------------------------------------------
	--PERIODO ANTERIOR
	-------------------------------------------------------------

	let vlfCorte = mdy( month(pfechahoy), vlDiaCorte, year(pfechahoy) );
			
	EXECUTE PROCEDURE sp_mes_siguiente(vlfCorte,-1,DAY(vlfCorte))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
		LET cod_ret = v_cod_ret_otro;
	END IF;
	
	--PERIODO
	LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
	LET v_periodo_tc_fin = vlfCorte;
	--DIAS DEL PERIODO
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
		LET cod_ret = v_cod_ret_otro;
	END IF;

	--PERIODO
	LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
	LET v_periodo_tc_fin = pfechahoy;

	--DIAS DEL PERIODO
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;
	
	IF v_fecha_limite_pago_tc IS NULL THEN
	   LET v_fecha_limite_pago_tc = pfechahoy;
	END IF;
	
	--FECHA PAGO INMEDIATA
	IF NVL(v_capital_ven_tc,0) > 0 THEN
		LET v_fecha_limite_pago_tc =  DATE(1);
		LET v_observaciones = "INMEDIATO";
	ELSE 
		LET v_observaciones = decode(WEEKDAY(v_fecha_limite_pago_tc),1,'lunes',2,'martes',3,'miércoles',4,'jueves',5,'viernes',6,'sábado',0,'domingo')||', '||LPAD(DAY(v_fecha_limite_pago_tc),2,'00')||'-'||decode(MONTH(v_fecha_limite_pago_tc),1,'ene',2,'feb',3,'mar',4,'abr',5,'may',6,'jun',7,'jul',8,'ago',9,'sep',10,'oct',11,'nov',12,'dic')||'-'||LPAD(YEAR(v_fecha_limite_pago_tc),4,'0000');
	END IF;

				
	INSERT INTO sd_encabezado_edocta
			(
			fecha_emision,					num_credito,					num_producto,					numcte,							num_tarjeta,
			nombre_cte,						direccion_cn,	    			direccion_col,					direccion_del,					edo_cd,
			sucursal_nombre,    			sucursal_gerente,				sucursal_tel,	    			fecha_corte,					rfc,
			cl_cobra,						CP,				    			ruta,							entre_calles,					observaciones,
			insertos,           			sucursal,						confirmacion,					num_region,						num_ciudad_banco,
			num_ciudad_coppel
			)
	 VALUES(
			pfechahoy,						pnum_credito,					NVL(TRIM(v_numprod),''),		NVL(Trim(v_numcte),''),			NVL(Trim(v_num_tarjeta),''),
			NVL(Trim(v_nombre_cte),''),		NVL(Trim(v_direccion_cn),''),	NVL(Trim(v_direccion_col),''),	NVL(Trim(v_direccion_del),''),	NVL(Trim(v_edo_cd),''),
			NVL(Trim(v_sucursal_nombre),''),NVL(Trim(v_sucursal_gerente),''),NVL(Trim(v_sucursal_tel),''), 	vlfCorte,						NVL(Trim(v_rfc),''),
			NVL(TRIM(v_cl_cobra),''),		NVL(Trim(v_cod_postal),''),    	NVL(TRIM(v_ruta),''),			NVL(TRIM(v_entre_calles),''),   NVL(TRIM(v_observaciones),''),
			cInserto,                       NVL(TRIM(v_sucursal),''),		NVL(TRIM(v_confirmacion),''),	NVL(sNumRegion,''),				NVL(sNumCiudadB,''),
			NVL(sNumCiudadC,'')
			);
			
--##############################################################
--##	GENERACION ENCABEZADO2 EDO CUENTA				      ##
--##############################################################
-------------------------------------------------------------
--SD_AMORTIZA_CREDITO
-------------------------------------------------------------
	 SELECT interes_debe,
			iva_debe,
			campo_trabajo1
	   INTO v_interes_debe,
			v_iva_debe,
			v_campo_trabajo1
	  FROM sd_amortiza_credito
	 WHERE empresa = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota=pfechahoy;

	LET v_interes_tc = v_interes_debe;
	LET v_iva_interes_tc = v_iva_debe;
	LET v_iva_interes_ven_tc = v_campo_trabajo1;
  	
-----------------------------------------------------------

-------------------------------------------------------------
-- sd_indicador_cred  (para obtener v_clave6 de la clave de cobranza)
-------------------------------------------------------------
	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -1, day(pfechahoy))  INTO v_cod_ret_otro, dFHoy_1m, iDiasTrans;
	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -13, day(pfechahoy)) INTO v_cod_ret_otro, dFHoy_13m, iDiasTrans;
	EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(pfechahoy, -12, day(pfechahoy)) INTO v_cod_ret_otro, dFHoy_12m, iDiasTrans;

	SELECT f_primer_compra, fecha_alta, fecha_ultima_compra INTO dFech_1erComp, dFech_alta, dFhUltCompAct FROM bdicred:sd_indicador_cred 
	 WHERE empresa = pempresa AND num_credito = pnum_credito; 

	SELECT ind.fecha_ultima_compra, ind.fecha_ultimo_pago, dos.sdo_cap_insoluto INTO dFhUltCompAnt, dFhUltPagoAnt, v_deuda_Ant 
	  FROM bdicred:sd_indicador_cred_hist ind, bdicred:sd_maesdoshist dos
	 WHERE ind.empresa = dos.empresa AND ind.num_credito = dos.num_credito AND ind.fecha = dos.fecha AND ind.empresa = pempresa 
	   AND ind.num_credito = pnum_credito AND ind.fecha = dFHoy_1m;

-------------------------------------------------------------
--SD_MAECREDANEXO
-------------------------------------------------------------

	--USTED DEBIA
	SELECT sdo_cap_insoluto	
		INTO v_usted_debia
	FROM sd_maesdoshist
	WHERE fecha = v_periodo_anterior
	AND empresa= pempresa
	AND num_credito = pnum_credito;

-------------------------------------------------------------
--SD_MOVHISEDOCTA
-------------------------------------------------------------
-- codigo_fun     codigo_ref     transacc     descripcion
-- 002            30             6800         RETIRO EFECTIVO CAJERO
-- 002            40             6871         RETIRO EFECTIVO CAJRED
-- 002            41             6872         RETIRO EFECTIVO CAJCON
-- 002            42             6873         RETIRO EFECTIVO CAJINT
-- codigo_fun     codigo_ref     transacc     descripcion
-- 339            3              6804         COMISION CONSULTA CAJERO 15%
-- 339            24             6874         COMISION CONSULTA CAJRED 15%
-- 339            25             6875         COMISION CONSULTA CAJCON 15%
-- 339            26             6876         COMISION CONSULTA CAJINT 15%
-- codigo_fun     codigo_ref     transacc     descripcion
-- 339            1              6802         COMISION X RETIRO CAJERO 15%
-- 339            17             6857         COMISION X RETIRO CAJERO RED 10%
-- 339            18             6858         COMISION X RETIRO CAJERO CONV 10%
-- 339            19             6859         COMISION X RETIRO CAJERO INTER 10%


--MENOS SUS ABONOS,MAS SUS COMPRAS,MAS COMISIONES,MAS DISPOSICIONES EM EFECTIVO,MAS INTERESES,MAS IVA
	SELECT 	SUM(CASE WHEN codigo_fun   IN (select {+INDEX(bdicred:sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) OR (codigo_fun = '008' AND codigo_ref = 3) THEN --se agregan aplicacion de pago
				CASE WHEN codigo_ref IN (1,54,125) OR (codigo_fun = '008' AND codigo_ref = 3) THEN  monto ELSE 0 END
				ELSE  0 END), 	--MENOS SUS ABONOS
			SUM(CASE WHEN codigo_fun   = '002' THEN
				CASE WHEN codigo_ref in (37,57,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,112,118,937,938)  THEN  monto ELSE 0 END 
				ELSE  0 END),	--MAS SUS COMPRAS AAME
			SUM(CASE WHEN (codigo_fun   = '339' or codigo_fun   = '039') THEN
				CASE WHEN (codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996)  
					or ( codigo_ref = 28 and codigo_fun = '039'))
				THEN monto ELSE 0 END -- Se agregan SURCHARGE
				ELSE  0 END),	--MAS COMISIONES
			SUM(CASE WHEN codigo_fun   = '002' THEN
				CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65,109,110,113,114,129,130)  THEN  monto ELSE 0 END
				ELSE  0 END),	--MAS DISPOSICIONES EN EFECTIVO
			SUM(CASE WHEN (codigo_fun   = '605' or codigo_fun   IN('061','081'))  THEN
				CASE WHEN ((codigo_ref IN(2,125,127) ) or  (codigo_ref IN(8,12) and codigo_fun  IN('061','081') ))  THEN  monto ELSE 0 END
				ELSE  0 END),	--MAS INTERESES
			SUM(CASE WHEN ( codigo_fun   = '605' or codigo_fun  IN('061','081') )  THEN
				CASE WHEN ((codigo_ref IN(3,126,128)) or ( codigo_ref IN(16,13) and codigo_fun IN('061','081')) )  THEN  monto ELSE 0 END
				ELSE  0 END) , --MAS IVA INTERESES
			SUM(CASE WHEN codigo_fun   = '340'  THEN
				CASE WHEN codigo_ref IN (1,2,11,27,30,31,901,902,903,904)  THEN  monto ELSE 0 END
				ELSE  0 END),	--MAS IVA COMISONES --JMAH Se agrega codigo de comision por apertura
			SUM(CASE WHEN codigo_fun   = '336'  THEN
				CASE WHEN codigo_ref = 23  THEN  monto ELSE 0 END
				ELSE  0 END),	--MAS COMISONES SBC
			SUM(CASE WHEN codigo_fun   = '336'  THEN
				CASE WHEN codigo_ref = 24  THEN  monto ELSE 0 END
				ELSE  0 END),	--MAS IVA SBC
			SUM(CASE WHEN codigo_fun   = '033'  THEN
				CASE WHEN codigo_ref in(6212,6218,6219,6220,6221,6232,6238,6239,6240,6241)  THEN  monto ELSE 0 END --adlm: se agregan codigos_ref faltantes
				ELSE  0 END),	--COMISION REPOSICION
			MAX(fecha_mov), -- FECHA ULTIMO PAGO
			SUM(CASE WHEN codigo_fun  IN('061','042','081')  THEN
				CASE WHEN codigo_ref in(5, 11)  THEN  monto ELSE 0 END -- CARGOS CAPITAL DIFERIDOS
				ELSE  0 END),
			SUM(CASE WHEN codigo_fun  IN (select {+INDEX(bdicred:sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual)  THEN --se agregan aplicacion de pago
				CASE WHEN codigo_ref IN (2,3,5,926,925,923)  THEN  monto ELSE 0 END
				ELSE  0 END), -- INTERESES VENCIDOS PAGADOS
			SUM(CASE WHEN (codigo_fun   = '339') THEN
				CASE WHEN (codigo_ref IN (90,91,92,93,94,95,993,994,995,996))
				THEN monto ELSE 0 END -- Sourcharge COMISION e IVA
				ELSE  0 END), -- monto total surcharge (comision e iva)	
			SUM(CASE WHEN codigo_fun  IN (select {+INDEX(bdicred:sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual)  THEN --se agregan aplicacion de pago
				CASE WHEN codigo_ref IN (6616,6617,6652,6651,6650)  THEN  monto ELSE 0 END
				ELSE  0 END), -- IVA DE INTERESES VENCIDOS PAGADOS
			SUM(CASE WHEN (codigo_fun   = '605' AND codigo_ref IN(2,125,127)) THEN monto ELSE 0 END),	--MAS INTERESES SIN DIFERIDOS
			SUM(CASE WHEN (codigo_fun   = '605' AND codigo_ref IN(3,126,128)) THEN monto ELSE 0 END), -- MAS IVA DE INTERES SIN DIFERIDOS
			SUM(CASE WHEN codigo_fun  IN('061','081')  THEN CASE WHEN codigo_ref in(5, 11)  THEN  monto ELSE 0 END -- CARGOS CAPITAL DIFERIDOS CON INT
				ELSE  0 END),
			SUM(CASE WHEN (codigo_fun   = '042' AND codigo_ref IN(5)) THEN monto ELSE 0 END) -- CARGOS CAPITAL DIFERIDOS SIN INT 
	INTO 	v_sus_abonos,
			v_sus_compras,
			v_sus_comisiones,
			v_dispocisiones,
			v_intereses,
			v_iva,
			v_iva_comisiones,
			v_comisiones_sbc,
			v_iva_comisiones_sbc,
			V_comis_repos,
			v_fecha_ultimo_pago,
			vlComprasDif,
			vInt_vencidos,
			v_monto_surcharge,
			vIvaIntVenPagados,
			vIntSinDif,
			vIvaIntSinDif,
			vComprasDifConInt,
			vComprasDifSinInt
	FROM   	sd_movhisedocta
	WHERE num_credito = pnum_credito;

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
	SELECT NVL(SUM(decode(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0),
			NVL(SUM(decode(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0)
		INTO dComPend,
			dIvaCom
	FROM bdicred:"informix".sd_detcomi dc, bdicred:"informix".sd_tpcomis tc
	WHERE dc.empresa     = tc.empresa
	AND dc.cod_comis   = tc.cod_comis
	AND dc.empresa     = pempresa
	AND dc.estado_com  = 'A'
	AND dc.num_credito = pnum_credito
	AND tc.comi_o_seg IN ('1','4');

	LET v_intereses_iva = NVL(v_iva,0);

-- jom ini SBC
	LET v_sus_comisiones = NVL(v_sus_comisiones,0) + NVL(v_comisiones_sbc,0) + NVL(V_comis_repos,0);

	LET v_capital_tc = NVL(v_monto_financiado,0) - NVL(v_capital_ven_tc,0);

	--IVA COMISIONES MAS IVA INTERESES
	LET v_iva = NVL(v_iva,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0) + NVL(vIvaIntVenPagados,0) + NVL(v_iva_interes_ven_tc,0);
-- jom fin SBC
	--MORATORIOS
	--LET v_moratorios_tc = v_moratorios_tcA + v_moratorios_tcB;

	IF NVL(v_moratorios_tc,0) <= 0 then let v_moratorios_tc = 0; end if;

	LET v_iva_moratorios_tc =  (NVL(v_moratorios_tc,0) * v_iva_suc) + dIvaCom;

	IF  (v_iva_moratorios_tc  IS NULL) OR (v_iva_moratorios_tc < 0) or (v_iva_moratorios_tc <= 0) THEN
	--IF   (v_iva_moratorios_tc <= 0) THEN

		LET v_iva_moratorios_tc = 0;
	END IF

	--CALCULO DEL INTERES VENCIDO

	IF (NVL(v_interes_ven_tc,0) - v_interes_tc >= 0) then
		LET v_interes_ven_tc = NVL(v_interes_ven_tc,0) - v_interes_tc;
	END IF

	-- PAGO MINIMO
	LET v_pago_minimo_tc = NVL(v_capital_tc,0)  + NVL(v_capital_ven_tc,0)  +
						   NVL(v_interes_ven_tc,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0) + NVL(dComPend,0) ;

	--USTED DEBE
	LET v_usted_debe = v_interes_pago_total_tc+NVL(dComPend,0)+ NVL(dIvaCom,0);

	-- CREDITO DISPONIBLE
	IF v_interes_pago_total_tc < 0 THEN
		LET v_disponible_tc  = ((v_interes_pago_total_tc * -1) + v_limite_tc) - v_sdo_retenido;
	ELSE
		LET v_disponible_tc = v_limite_tc - (v_interes_pago_total_tc + v_sdo_retenido);
		IF v_disponible_tc < 0 THEN
			LET v_disponible_tc = 0;
		END IF
	END IF

	--PAGO PARA NO GERERAR INTERES
	LET v_interes_pago_total_tc = v_interes_pago_total_tc +	
								NVL(v_interes_ven_tc ,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0) + NVL(dComPend,0) + NVL(dIvaCom,0);
	
	LET vlsaldo_corte = v_interes_pago_total_tc;
	
	IF v_interes_pago_total_tc < 0 THEN
		LET v_interes_pago_total_tc = 0;
	END IF
	--FECHA DE CORTE
	--LET v_fecha_corte_tc = pfechahoy;
	LET v_fecha_corte_tc = vlfCorte;

	--IF (v_fecha_apertura = v_periodo_tc_fin) THEN
		---LET v_iva = 0;
		--LET v_intereses = 0;
	--ELSE
		LET v_iva = NVL(v_iva,0);
		-- MONTO DE INTERESES DE RESUMEN DE CARGOS Y ABONOS
		LET v_intereses = NVL(v_intereses,0) + NVL(vInt_vencidos,0) + NVL(v_moratorios_tc,0) + NVL(v_interes_ven_tc,0);
		LET v_intereses_pag = NVL(v_intereses,0);
	--END IF
	
	
--INICIO-----LHM--GRAFICA DE BARRAS
	LET v_comisiones_iva = NVL(v_sus_comisiones,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0);
	LET v_intereses_iva = nvl(v_intereses,0) + NVL(v_intereses_iva,0);         	

-- ADLM separacion de Sourcharge COMISION e IVA
	
	LET v_comisiones_surge = NVL((NVL(v_monto_surcharge,0)/(1 + v_iva_suc)),0);
	LET v_iva_surcharge =  NVL(v_monto_surcharge,0) - NVL(v_comisiones_surge,0);
	LET v_sus_comisiones = NVL(v_sus_comisiones,0) - NVL(v_iva_surcharge,0);
	LET v_iva = NVL(v_iva,0) + NVL(v_iva_surcharge,0);
-- ADLM separacion de Sourcharge COMISION e IVA	 
	 
		--- RQI 12 297: CFDI 3.3 ---	 
		--- Campo base_iva
	LET v_base_iva = nvl(v_iva,0)/nvl(v_iva_suc,0); 
				
		--- Campos descuento y subtotal		
/*				if nvl(v_intereses,0) > 0 or nvl(v_sus_comisiones,0) > 0 then 
						LET v_descuento = 0.00;
						LET v_subtotal  = nvl(v_intereses,0) + nvl(v_sus_comisiones,0);
					else 
						LET v_descuento = 0.01;
						LET v_subtotal	= 0.01;
				end if 
					LET v_total = nvl(v_sus_comisiones,0) + nvl(v_intereses,0) + nvl(v_iva,0);
*/				
		--- FIN RQI 12 297: CFDI 3.3 -- 	 

	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	--- Pago minimo MSI
	-- Estatus 1 = Aperturado, Estatus 2 = Vigente, Estatus 6 = Liquidado, Estatus 7 = Cancelado
	SELECT  sum(saldo_pendiente), 	sum(int_periodo)
	  INTO 	v_saldo_diferido, 		vMtoIntPF
	FROM sd_detalle_dif_edocta 
	WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	
	--- /* RESUMEN DE CARGOS Y ABONOS DEL PERIODO *\--- 
	-- CARGOS REGULARES
	LET v_sus_compras = nvl(v_sus_compras,0) + nvl(v_dispocisiones,0);
	-- CARGOS COMPRAS A MESES CON DIFERIDOS
	LET vlComprasDif = NVL(vlComprasDif,0);
	-- COMISIONES E INTERESES --
	LET v_inter_comi  =  NVL(v_sus_comisiones,0) + NVL(v_intereses_pag,0) + NVL(v_comisiones_surge,0);
	-- IVA DE INTERESES Y COMISIONES --
	LET v_iva_inter_comi = NVL(v_iva,0) + NVL(v_iva_moratorios_tc,0);
	
	--- Pago minimo MSI
	SELECT 		sum(msipagomin), 	sum(saldo_total_deudor) 
		INTO 	vPagoMinMsi, 		vSdoDebeComprasMSI
	FROM bdicred:sd_detalle_msi_edocta
	WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	
	LET v_compras_disp = NVL(v_saldo_diferido,0) + NVL(vSdoDebeComprasMSI,0);
	
	--- CALCULA TASA INTERES APLICABLE PARA MSI
	FOREACH WITH HOLD
		SELECT num_credito, num_sol_prestamo, tasa_int_aplicable INTO vNumCreditoMsi, vNumPrestamoMSI, vTasaIntApliMSI
		FROM bdicred:sd_detalle_msi_edocta
		WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito
		
		IF NVL(vTasaIntApliMSI,'') <= '0.000' OR NVL(vTasaIntApliMSI,'') = '' OR vTasaIntApliMSI IS NULL THEN
			LET vTasaIntApliMSI = 'NA';
			LET vNumPrestamoMSI = TRIM(vNumPrestamoMSI);
			UPDATE bdicred:sd_detalle_msi_edocta SET tasa_int_aplicable = vTasaIntApliMSI WHERE fecha_emision = pfechahoy AND num_sol_prestamo = vNumPrestamoMSI;
		END IF;
	END FOREACH;
	
	
	--- FIN Pago minimo MSI
	
	LET vSdoDifPlazo = NVL(v_saldo_diferido,0) + NVL(vPagoMinMsi,0);
	LET VSdoPeriCort = NVL(vlsaldo_corte,0);
	
	IF VSdoPeriCort < 0 THEN
		LET v_sdo_favor = VSdoPeriCort * -1;
	ELSE 
		LET v_sdo_favor = 0;
	END IF;
	
	--- FIN Pago minimo MSI
	
	--- OBTENER  VALORES PARA CFDI 4.0.
	select trim(valor) INTO cIVA_cfdi
	FROM "informix".sd_param WHERE cod_param = '143';
	
	LET vIvaInteresesReales = NVL(vIvaIntSinDif,0);
	LET vInteresesReales = (NVL(vIvaInteresesReales,0) / cIVA_cfdi);
	LET vValBase = (NVL(v_sus_comisiones,0) + NVL(vInteresesReales,0));
	
	IF NVL(vValBase,0) = 0 OR NVL(vValBase,0) is null THEN
		LET v_subtotal	= 0.01;
		LET v_descuento = 0.01;
		LET v_total = 0.00;
		LET vObjetoImp = '01';
		UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
		WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	ELSE 
		IF NVL(vValBase,0) > 0 THEN
			LET v_subtotal  = NVL(vInteresesReales,0) + NVL(v_sus_comisiones,0);
			LET v_descuento = 0.00;
			LET vIvaDeComisiones = NVL(v_comisiones_iva,0) - NVL(v_sus_comisiones,0);
			LET v_total = (NVL(v_subtotal,0) + NVL(vIvaInteresesReales,0) + NVL(vIvaDeComisiones,0)) - NVL(v_descuento,0);
			LET vObjetoImp = '02';
			UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
			WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
		END IF;
	END IF;
	
	-- VALOR DE IVA REAL SOBRE LA BASE DE CFDI
	LET vIvaCfdi = NVL(vValBase,0) * .16;

	--- FIN CFDI 4.0
	
	--- PAGOS FIJOS
	SELECT sum(monto_prox_pago), sum(tasa) INTO vMtoPagosFijos, vTasaPF
	FROM bdicred:sd_detalle_dif_edocta 
	WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	
	--- FIN PAGOS FIJOS
	
	--- PAGO MINIMO + MESES SIN INTERESES
			
	LET v_pago_minimo_msi = NVL(v_pago_minimo_tc,0) + NVL(vPagoMinMsi,0);
			
	--- PAGO MINIMO + MESES SIN INTERESES + PAGOS FIJOS
	
	LET v_pago_minimo_msi_pf = NVL(v_pago_minimo_msi,0) + NVL(vMtoPagosFijos,0);
	
	--------------------------------------------------------------------------------
	----------- Nuevo calculo para Meses, Pagos minimos e Interes pagados ----------
	LET dMonto_No_Exigible = NVL(v_monto_adeudo,0) - NVL(v_capital_ven_tc,0); 
	LET vPagoMinx2 = NVL(v_pago_minimo_tc,0);
	LET vPagoMinx5 = NVL(v_pago_minimo_tc,0);
	LET int_maximos_x_mes = 999999.99;
	
	----- SI EL PAGO MINIMO ES MENOR AL ADEUDO 
	IF  NVL(v_pago_minimo_tc,0) > 0 AND NVL(v_pago_minimo_tc,0) <= NVL(v_interes_pago_total_tc,0) THEN 
		EXECUTE PROCEDURE "informix".calcula_meses_fin_pagomin_base(pempresa,v_numprod,v_interes_pago_total_tc,v_pago_minimo_tc, NVL(v_tasa_anual,0)/100,v_iva_suc,pfechahoy,1)
			INTO cCodRetMeses,vCalculaMesPagMin1,InterIvaProyec;
			
		IF InterIvaProyec > int_maximos_x_mes  THEN
			LET InterIvaProyec = int_maximos_x_mes;
		END IF;	
		
		LET vTermPago_MesUno = CEIL(NVL(REPLACE(vCalculaMesPagMin1,'.00',''),'')) || ' meses';
		LET vPagariasIntereses1 = NVL(InterIvaProyec,0);
	ELSE 
		LET v_pago_minimo_tc = NVL(v_pago_minimo_tc,0);
		LET vPagariasIntereses1 = 'NA';
		LET vTermPago_MesUno = 'NA';
	END IF;
	
	----- SI PAGA 2 VECES EL MINIMO Y ES MENOR AL ADEUDO... 
	IF  NVL(v_pago_minimo_tc,0) > 0 AND (NVL(v_pago_minimo_tc,0) * 2) <= NVL(v_interes_pago_total_tc,0) THEN
		EXECUTE PROCEDURE "informix".calcula_meses_fin_pagomin_base(pempresa,v_numprod,v_interes_pago_total_tc,vPagoMinx2, NVL(v_tasa_anual,0)/100,v_iva_suc,pfechahoy,2)
			INTO cCodRetMeses,vCalculaMesPagMin2,InterIvaProyec2;
			
		IF InterIvaProyec2 > int_maximos_x_mes  THEN
			LET InterIvaProyec2 = int_maximos_x_mes;
		END IF;	
		
		LET vTermPago_MesDos = CEIL(NVL(REPLACE(vCalculaMesPagMin2,'.00',''),'')) || ' meses';
		LET vPagariasIntereses2 = NVL(InterIvaProyec2,0);
		LET vPagoMinx2 = round(NVL(v_pago_minimo_tc,0) * 2,2);
	ELSE
		LET vPagoMinx2 = 'NA';
		LET vPagariasIntereses2 = 'NA';
		LET vTermPago_MesDos = 'NA';
	END IF;
	
	----- SI PAGA 5 VECES EL MINIMO Y ES MENOR AL ADEUDO... 
	IF  NVL(v_pago_minimo_tc,0) > 0 AND (NVL(v_pago_minimo_tc,0) * 5) <= NVL(v_interes_pago_total_tc,0) THEN
		EXECUTE PROCEDURE "informix".calcula_meses_fin_pagomin_base(pempresa,v_numprod,v_interes_pago_total_tc,vPagoMinx5, NVL(v_tasa_anual,0)/100,v_iva_suc,pfechahoy,5)
			INTO cCodRetMeses,vCalculaMesPagMin5,InterIvaProyec5;
		
		IF InterIvaProyec5 > int_maximos_x_mes  THEN
			LET InterIvaProyec5 = int_maximos_x_mes;
		END IF;	
		
		LET vTermPago_MesCinco = CEIL(NVL(REPLACE(vCalculaMesPagMin5,'.00',''),'')) || ' meses';
		LET vPagariasIntereses5 = NVL(InterIvaProyec5,0);
		LET vPagoMinx5 = round(NVL(v_pago_minimo_tc,0) * 5,2);
	ELSE
		LET vPagoMinx5 = 'NA';
		LET vPagariasIntereses5 = 'NA';
		LET vTermPago_MesCinco = 'NA';
	END IF;
	
	-------------------------------------------------
	--- /* SECCION: NIVEL DE USO DE TU TARJETA *\ --- 
	-------------------------------------------------
	-- SALDO CARGOS REGULARES
	--LET vSdosCargosReg = NVL(v_sus_compras,0) + NVL(vIntSinDif,0) + NVL(vIvaIntSinDif,0);
	LET vSdosCargosReg = NVL(vlsaldo_corte,0);
	LET vSdoCargoMesesConySinInt = NVL(vSdoDebeComprasMSI,0) + NVL(v_saldo_diferido,0);
	LET v_dist_carg_dif_msi = NVL(vPagoMinMsi,0); 
	LET v_dist_carg_dif_con_int = NVL(vlComprasDif,0);
	LET v_total_cargos= NVL(vlComprasDif,0)+NVL(v_sus_compras,0)+NVL(v_intereses,0)+NVL(v_sus_comisiones,0)+NVL(v_iva_inter_comi,0);
	LET v_sdo_deudor_tot = NVL(vSdosCargosReg,0) + NVL(v_compras_disp,0);
	
	-----------------------------------------------------
	--- /* SECCION: DISTRIBUCION DE TU ULTIMO PAGO *\ --- 
	-----------------------------------------------------
	LET vComprasDifSinInt = 0;
	LET vComprasDifConInt = 0;
	LET v_inter_comi_dist_ult_pag = NVL(vInt_vencidos,0);
	LET v_iva_inter_comi_dist_ult_pag = NVL(vIvaIntVenPagados,0);
	
	IF NVL(v_usted_debia,0) < 0 THEN 
		--LET v_usted_debia_pos = (v_usted_debia * -1);
		IF (v_usted_debia * -1) > NVL(v_sdo_favor,0) THEN 
			LET v_sdo_favor = 0;
		END IF;
	END IF;
	
	IF NVL(v_usted_debia,0) < 0 AND NVL(v_sdo_favor,0) > 0 THEN 
		LET v_sdo_favor = NVL(v_sdo_favor,0) + NVL(v_usted_debia,0);
	END IF;
	
	IF NVL(v_sus_abonos,0) > 0 THEN 
		LET v_pago_capital = NVL(v_sus_abonos,0) - NVL(v_inter_comi_dist_ult_pag,0) - NVL(v_iva_inter_comi_dist_ult_pag,0) - NVL(v_sdo_favor,0);
	ELSE
		LET v_pago_capital = 0;
	END IF;
	
	LET vMenosPeriAnt = pfechahoy - 1 units month;
	LET vMesPerAnt = LPAD(MONTH(vMenosPeriAnt::DATE), 2, '0');
	LET vAnioPerAnt = YEAR(vMenosPeriAnt);
	
	LET vFechAnioAnt = vMenosPeriAnt -1 units year;
	LET vMesAnioAnt = LPAD(MONTH(vFechAnioAnt::DATE), 2, '0');
	LET vAnioAnt = YEAR(vFechAnioAnt);
	
	--------intereses------
	SELECT sum(his.monto) --int_gral
		INTO v_int_gral
	FROM bdicred:sd_movhis his
	WHERE his.num_credito = pnum_credito
	AND his.fecha_mov > MDY(vMesAnioAnt,vlDiaCorte,vAnioAnt) AND his.fecha_mov <= MDY(vMesPerAnt,vlDiaCorte,vAnioPerAnt) 
	AND his.reversado = 'N'
	AND ((codigo_fun IN (select {+INDEX(bdicred:sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) AND codigo_ref IN (2,3,5,926,925,923))
	OR ((codigo_fun = '605' AND codigo_ref IN(2,125,127))
	OR (codigo_fun IN('061','081') AND codigo_ref IN(8,12)))) 
	AND his.empresa = '001' 
	group by his.num_credito;
	
	--------comsiones------
	SELECT SUM(monto) --comi_gral
		INTO v_comi_gral
	FROM bdicred:sd_movhis his
	WHERE his.num_credito = pnum_credito
	AND his.fecha_mov > MDY(vMesAnioAnt,vlDiaCorte,vAnioAnt) AND his.fecha_mov <= MDY(vMesPerAnt,vlDiaCorte,vAnioPerAnt)
	AND ((codigo_fun = '339' AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996)) OR (codigo_fun = '039' AND codigo_ref = 28)
	AND reversado = 'N'
	OR (codigo_fun = '336' AND codigo_ref = 23)
	OR (codigo_fun = '033' AND codigo_ref in(6212,6218,6219,6220,6221,6232,6238,6239,6240,6241)))
	AND his.empresa = '001'
	group by his.num_credito;
	
	SELECT SUM(monto) --comi_surcharge
		INTO v_comi_surcharge
	FROM bdicred:sd_movhis his
	WHERE his.num_credito = pnum_credito
	AND his.fecha_mov > MDY(vMesAnioAnt,vlDiaCorte,vAnioAnt) AND his.fecha_mov <= MDY(vMesPerAnt,vlDiaCorte,vAnioPerAnt)
    AND reversado = 'N'
    AND codigo_fun   = '033' AND codigo_ref in(6212,6218,6219,6220,6221,6232,6238,6239,6240,6241)
	AND his.empresa = '001'
    group by his.num_credito;
	
	--------anualidad------
	SELECT SUM(monto) 
		INTO v_anualidad
	FROM bdicred:sd_movhis his
	WHERE his.num_credito = pnum_credito
	AND his.fecha_mov > MDY(vMesAnioAnt,vlDiaCorte,vAnioAnt) AND his.fecha_mov <= MDY(vMesPerAnt,vlDiaCorte,vAnioPerAnt)
	AND reversado = 'N'
	AND his.codigo_fun = '339' AND his.codigo_ref IN(100,96) 
	AND his.empresa = '001'
	group by his.num_credito;
	
	LET vIntPag_12m = NVL(v_int_gral,0);
	LET vComiPag_12m = NVL(v_comi_gral,0) + (NVL(ROUND(v_comi_surcharge),0) / 1.16);
	LET vAnualidadPag_12m = NVL(v_anualidad,0);
	
	
	INSERT INTO sd_encabezado2_edocta
				(
				fecha_emision,					num_credito,					capital_tc,					interes_tc,
				iva_interes_tc,					capital_ven_tc,					interes_ven_tc,				iva_interes_ven_tc,
				moratorios_tc,					iva_moratorios_tc,				sdo_pagar,					interes_pago_total_tc,
				limite_tc,						sdo_disponible,					periodo_tc_ini,				periodo_tc_fin,
				pago_antes_de,					fecha_corte,					dias_periodo_tc,			usted_debia,
				menos_abonos,					mas_compras,					sus_comisiones,				mas_disp_efectivo,
				mas_intereses,					mas_iva,						mas_rendimientos,			sdo_debe,
				menos_o_abonos,					mas_o_cargos,					usted_debe,	
                comisiones_iva,         		intereses_iva,              	intereses_pag,          	saldo_menos_pag,
                compras_disp,					saldo_diferido,					saldo_total,				saldo_corte,
				comisionxcobrar,				base_iva, 						descuento,					subtotal,
				total,							pagomin_msi,					val_base_cfdi,				iva_intereses_reales_cfdi,
				intereses_reales_cfdi,			mtomensgral_pagosfijos,			iva_cfdi,					term_pagomin_uno, -- RQM 10 1674
				pago_int_uno,					pagomin_dos_plazos,				term_pagomin_dos,			pago_int_dos,
				pagomin_cinco_plazos,			term_pagomin_cinco,				pago_int_cinco,				iva_inter_comi,
				sdo_deudor_total,				lim_disp_efectivo,				lim_disp_transferencia,		sdo_cargo_regular,
				sdo_cargo_meses,				inter_comi,						intereses_pag_12m,			comisiones_pag_12m,
				anualidad_pag_12m,				dist_carg_dif_msi,				dist_carg_dif_con_int
				)
		VALUES (
				pfechahoy,						TRIM(pnum_credito),				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),
				NVL(v_iva_inter_comi_dist_ult_pag,0),NVL(v_capital_ven_tc,0),	NVL(v_interes_ven_tc,0),	NVL(v_iva_interes_ven_tc,0),
				NVL(v_moratorios_tc,0),			NVL(v_iva_moratorios_tc,0),		NVL(v_pago_minimo_tc,0),	NVL(v_interes_pago_total_tc,0),
				NVL(v_limite_tc,0),				NVL(v_disponible_tc,0),			v_periodo_tc_ini,			v_periodo_tc_fin,
				v_fecha_limite_pago_tc,			v_fecha_corte_tc,				NVL(v_dias_periodo_tc,0),	NVL(v_usted_debia,0),
				NVL(v_sus_abonos,0),			NVL(v_sus_compras,0),			NVL(v_sus_comisiones,0),	NVL(v_dispocisiones,0),
				NVL(v_intereses,0),				NVL(v_iva,0),					NVL(v_total_cargos,0),		0,
				0,								0,								0,							
                NVL(v_comisiones_iva,0),    	NVL(v_intereses_iva,0),     	NVL(v_intereses_pag,0),     NVL(v_pago_capital,0),
                NVL(v_compras_disp,0),			NVL(vlComprasDif,0),        	(NVL(v_saldo_diferido,0) + NVL(vlsaldo_corte,0)), NVL(v_sdo_favor,0), 
				NVL(dComPend,0), 				NVL(v_base_iva,0), 				NVL(v_descuento,0), 		NVL(v_subtotal,0), 
				NVL(v_total,0),					NVL(v_pago_minimo_msi,0),		NVL(vValBase,0),			NVL(vIvaInteresesReales,0),	
				NVL(vInteresesReales,0),		NVL(v_pago_minimo_msi_pf,0),	NVL(vIvaCfdi,0),			NVL(vTermPago_MesUno,''), -- RQM 10 1674
				NVL(vPagariasIntereses1,''),	NVL(vPagoMinx2,''),				NVL(vTermPago_MesDos,''),	NVL(vPagariasIntereses2,''),
				NVL(vPagoMinx5,''),				NVL(vTermPago_MesCinco,''),		NVL(vPagariasIntereses5,''),NVL(v_iva_inter_comi,0),
				NVL(v_sdo_deudor_tot,0),		NVL(v_disponible_tc,0),			NVL(v_disponible_tc,0),		NVL(vSdosCargosReg,0),
				NVL(vSdoCargoMesesConySinInt,0),NVL(v_inter_comi_dist_ult_pag,0),NVL(vIntPag_12m,0),		NVL(vComiPag_12m,0),
				NVL(vAnualidadPag_12m,0),		NVL(vComprasDifSinInt,0),		NVL(vComprasDifConInt,0)
				);
   	--##############################################################
	--##	GENERACION DETALLE	 EDO CUENTA				          ##
   	--##############################################################

    --------------------------------------------------------
    --      GENERA USTED DEBIA
    --------------------------------------------------------
    LET v_maximo = 1;
	INSERT INTO sd_detalle_edocta
			(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			monto,
			--cargos,
			nlinea,				tipo_tarjeta
		    )
		VALUES(
			pfechahoy,			pnum_credito,
			v_maximo,			"",
			"USTED DEBIA",		NVL(v_usted_debia,0),
			1,					'T'
		    );
			
    --------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	FOREACH 
		SELECT	a.fecha_mov,			secuencia,			a.referencia,			a.referencia23,			a.rfc_comer,			a.transacc_suc,
				case
					when TRIM(a.descripcion) = 'PAGO MINIMO APOYO 2020'
						then 0 
					else
					   a.monto
				end,
				case
					when usuario = 'crr92579'
					   then 'ABO. CORR. CGO. DUPLI.'
					when substr(usuario,1,4) = 'BC05'
					   then 'ABO. CORR. CGO. DUPLI.'
					when substr(usuario,1,3) = 'B05'
					   then 'ABO. CORR. CGO. DUPLI.'
					when TRIM(a.descripcion) = 'PAGO MINIMO APOYO 2020'
						then TRIM(a.descripcion)||'-->'||a.monto 
					else
					   TRIM(a.descripcion)
				end,
				a.naturaleza,			a.codigo_ref,		a.folio_suc,			a.fecha_oper,			a.nro_tarjeta,			a.tipo_tarjeta
     		INTO    vlfechaor,			vlsecuencia,		v_referencia,			v_referencia23,			v_rfc_comer,			v_transacc,
					v_monto,
    				v_concepto,
					v_naturaleza,		v_cod_ref, 			cFolioSuc,				vFechaOper,				vNumTarjeta,			v_tipo_tarjeta --RQI 22 268 JMAH
		FROM sd_movhisedocta a
		WHERE a.num_credito = pnum_credito
		AND a.codigo_fun  <>'061'
			union 
		SELECT  a.fecha_mov, 		max(secuencia),		'',						'',						'',						min(a.transacc_suc),
				sum(a.monto),
				'CARGO POR PAGOS FIJOS '|| substr(a.referencia,18,12) || '   '|| a.referencia23 || '  '||  a.rfc_comer ||
				(select '  Capital   $'|| lpad(sum(monto),12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref IN(5,11) and referencia like '%'|| substr(a.referencia,18,12) ||'%') ||
				nvl((select '  Intereses $'|| lpad(sum(monto),12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref IN(8,12) and referencia like '%'|| substr(a.referencia,18,12) ||'%'),'') ||
				nvl((select '  IVA       $'|| lpad(sum(monto),12) from bdicred:sd_movhisedocta where num_credito = pnum_credito and fecha_mov = a.fecha_mov AND codigo_fun  ='061' and codigo_ref IN(13,16) and referencia like '%'|| substr(a.referencia,18,12) ||'%'),'') ,
				a.naturaleza,		0, 					a.folio_suc,			a.fecha_oper,			a.nro_tarjeta, 			a.tipo_tarjeta --RQI 22 268 JMAH
		FROM sd_movhisedocta a
		WHERE a.num_credito = pnum_credito
		AND a.codigo_fun  ='061'
		GROUP BY 1,8,9,11,12,13,14
		ORDER BY 1,2

		IF v_monto = 0 AND substr(trim(v_concepto),1,22) != 'PAGO MINIMO APOYO 2020' THEN
			CONTINUE FOREACH;
		END IF;
			
		LET v_fecha_mov = DAY(vlfechaor) || "-" || DECODE(MONTH(vlfechaor),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6","JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC") || "-" || YEAR(vlfechaor);
		LET vFechaOper = DAY(vFechaOper) || "-" || DECODE(MONTH(vFechaOper),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6","JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC") || "-" || YEAR(vFechaOper);
			
		--------------------------------------------------------
		--      GENERO LA DESCRIPCION DEL MOVIMIENTO
		--------------------------------------------------------
		IF   ((v_transacc in ('8197')) AND (v_cod_ref = 1)) THEN 
			LET v_concepto = TRIM(SUBSTRING(cFolioSuc FROM 6))||" Abono por remesa de BTS";		
			
			ELIF ((v_transacc in ('7796')) AND (v_cod_ref = 1)) THEN  --- Folio de aclaracion Fallecidos
				LET v_concepto = v_concepto ||" Folio de aclaracion F"||TRIM(SUBSTRING(cFolioSuc FROM 7));
				
			ELIF v_transacc in ('8372') THEN  --- CARGO PROGRAMA DE APOYO 
				LET v_concepto = "CARGO DE INTERES PROGRAMA DE APOYO "||TRIM(SUBSTRING(cFolioSuc FROM 9));	
				
			ELIF v_transacc in ('8373') THEN  --- CARGO PROGRAMA DE APOYO 
				LET v_concepto = "CARGO DE IVA PROGRAMA DE APOYO "||TRIM(SUBSTRING(cFolioSuc FROM 9));						
				
			ELIF ((v_transacc in ('6283')) AND (v_cod_ref = 1)) THEN --- Se agrega transaccion OXXO
				LET v_concepto = v_concepto ||" - "||TRIM(SUBSTR(cFolioSuc,1,6));	
				
			ELIF ((v_transacc in ('6284')) AND (v_cod_ref = 1)) THEN --- Se agrega transaccion 7Eleven
				LET v_concepto = v_concepto ||" - "||TRIM(SUBSTR(cFolioSuc,1,5));	
							
			ELIF   ((v_transacc in ('8275')) AND (v_cod_ref = 1)) THEN 
				LET v_concepto = TRIM(SUBSTRING(cFolioSuc FROM 5))||" Abono por remesa de Appriza";	

			ELIF v_referencia IS NULL THEN
--jom ini sbc
			if trim(v_concepto) = "SU PAGO CON CHEQUE" then
				LET v_concepto = NVL(TRIM(v_concepto),'') || " " || trim(v_referencia23);
			else
					IF (v_transacc in ('4002','4001','5080','5212','5260')) THEN	--RQI 22 268 JMAH
						LET v_concepto = NVL(TRIM(v_concepto),'')|| " Folio de aclaracion " ||TRIM(SUBSTR(cFolioSuc,7,10));
					ELSE
						LET v_concepto = NVL(TRIM(v_concepto),'');
					END IF;
			end if;
--jom fin sbc
		ELSE
			IF v_referencia[1,1] = "i" AND (v_transacc not in ('8071','8072')) THEN ----JMAH
				IF (v_transacc in ('6800','6871','6873')) THEN
					LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 18))||NVL(TRIM(v_referencia23),'');
					ELIF (v_transacc = '6901') THEN
						  LET v_concepto =  NVL(TRIM(v_concepto),'');
					ELIF (v_transacc = '4256') THEN -- Descripcion de cancelacion msi
						LET v_concepto = NVL(TRIM(SUBSTRING(v_concepto FROM 1 FOR 13)),'') || " " || nvl(TRIM(SUBSTRING(v_referencia FROM 18)),'');
				ELSE
					LET v_concepto = NVL(TRIM(SUBSTRING(v_referencia FROM 18)),'')
									|| "  " ||
									NVL(TRIM(v_rfc_comer),'')
									|| "  " ||
									NVL(TRIM(v_referencia23),'');
				END IF

				IF v_concepto[1,1] = "i" THEN
					LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 18));				   
				END IF
			ELSE
				IF TRIM(v_concepto) = "PAGO CORRESPONSAL COPPEL" THEN
					LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia);
				ELSE
					IF (v_transacc not in ('8071','8072')) THEN	
						IF (v_transacc in ('4002','4001','5080','5212','5260')) THEN	--RQI 22 268 JMAH
							LET v_concepto = NVL(TRIM(v_concepto),'')|| " Folio de aclaracion " ||TRIM(SUBSTR(cFolioSuc,7,10));
						ELSE
							LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,40]);
						END IF
					END IF
				END IF
			END IF
		END IF
			
		LET v_concepto = replace(TRIM(v_concepto), 'SUR. RETIRO', 'SUR. RETIRO + IVA');
		LET v_concepto = replace(TRIM(v_concepto), 'SUR. CONSULTA', 'SUR. CONSULTA + IVA');

		--------------------------------------------------------
		--ARMO LA FECHA DE MOVIMIENTO CON LETRA
		--------------------------------------------------------
		IF vFechaOper IS NULL OR NVL(vFechaOper,'') = '' THEN 
			LET vFechaOper = v_fecha_mov;
		END IF;
		
		--------------------------------------------------------
		--TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		--------------------------------------------------------
		IF NVL(v_naturaleza,'') = "A" THEN
			LET v_importe  = NVL(v_monto * -1,0);
		ELSE
			LET v_importe = NVL(v_monto,0);
		END IF;
		--------------------------------------------------------
		--TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		--------------------------------------------------------
		LET v_maximo = v_maximo + 1 ;
		LET v_contador = 0;
		--------------------------------------------------------
		--DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		--------------------------------------------------------
		
		-- Se agrega para determinar si no tiene bandera de tipo de tarjeta, colocar que sea un movimiento titular.
		IF NVL(v_tipo_tarjeta,'') = '' OR v_tipo_tarjeta is null THEN 
			LET v_tipo_tarjeta = 'T';
		END IF;
		
		IF v_tipo_tarjeta = 'T' AND vNumTarjeta IS NULL AND vFechaOper IS NOT NULL THEN 
			LET vNumTarjeta = v_num_tarjeta;
		END IF;
					
		FOREACH EXECUTE PROCEDURE corta_linea(v_concepto,v_corta_linea_detalle)
				INTO v_concepto, v_corta_retorno

			LET v_contador = v_contador + 1;
			
			IF v_contador = 1 THEN
				INSERT INTO sd_detalle_edocta
						(
						fecha_emision,		num_credito,		secuencia,		fecha_mov,
						concepto,			monto,				
						nlinea,				fecha_operacion,	num_tarjeta,	tipo_tarjeta
						)
					VALUES
						(
						pfechahoy,			pnum_credito,		v_maximo,		v_fecha_mov,
						Trim(v_concepto),	v_importe,
						v_contador,			vFechaOper,			vNumTarjeta,	v_tipo_tarjeta
						);
			ELSE
				INSERT INTO sd_detalle_edocta
					(
					fecha_emision,		num_credito,		secuencia,		concepto,
					nlinea,				tipo_tarjeta
					)
				VALUES(
					pfechahoy,			pnum_credito,		v_maximo,		Trim(v_concepto),
					v_contador,			v_tipo_tarjeta
					);
			END IF;

		END FOREACH;

		--------------------------------------------------------
		--INICIALIZA LAS VARIABLES
		--------------------------------------------------------
		LET v_fecha_mov    = "";
		LET vFechaOper	   = "";
		LET v_concepto     = "";
		--LET v_compra       = "";
		--LET v_abono        = "";
		LET v_importe	   = "";

	END FOREACH;

    --------------------------------------------------------
    --      GENERA USTED DEBE
    --------------------------------------------------------
    LET v_maximo = v_maximo + 1;
	INSERT INTO sd_detalle_edocta
	 		(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			monto,
			nlinea,				tipo_tarjeta
			)
	VALUES
			(
			pfechahoy,			pnum_credito,
			v_maximo,			"",
			"USTED DEBE",		NVL(v_usted_debe,0),
			1,					'T'
			);
	
	IF v_status_cred ='FF' THEN 
		IF NVL(v_tipo_tarjeta,'') = '' OR v_tipo_tarjeta is null THEN 
			LET v_tipo_tarjeta = 'T';
		END IF;
		
		INSERT INTO sd_detalle_edocta
		(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			nlinea,
			tipo_tarjeta
			)
		VALUES
			(
			pfechahoy,			pnum_credito,
			0,		day(vfcancelado)||'/'|| 
			DECODE( MONTH(vfcancelado),
						"1","ENE","2","FEB","3","MAR",
						"4","ABR","5","MAY","6","JUN",
						"7","JUL","8","AGO","9","SEP",
						"10","OCT","11","NOV","12","DIC")
			||'/'||substr(year(vfcancelado),3,2),
			"TARJETA DE CREDITO CANCELADA " ,0,
			v_tipo_tarjeta
			);
	ELSE 
		LET vfcancelado = date(0);
	END IF;

   	--##############################################################
	--##	GENERACION ACLARACIONES	 EDO CUENTA				      ##
   	--##############################################################
    LET v_maximo       = 0;
	
    FOREACH 			
		SELECT	acl.fechacaptura,	acl.folio_csuac,		mov.fechahora,
				eve.descripcion,	acl.importereclamado,	sta.descripcion
			INTO vfechacaptura, 	vfolio_csuac, 			vfechahora,
				vdescripcion, 		vimportereclamado,		vStatusAclara
		FROM bdiaclaracion:acl_aclaracion acl
		INNER JOIN bdiaclaracion:acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento
		INNER JOIN bdiaclaracion:acl_producto pro ON pro.pky_producto = acl.fky_producto
		INNER JOIN bdiaclaracion:acl_movimiento mov ON acl.pky_aclaracion = mov.fky_aclaracion
		INNER JOIN bdicred:sd_maecred cr ON cr.num_credito = pro.numero_cuenta
		LEFT OUTER JOIN bdiaclaracion:acl_estatus_aclaracion sta ON acl.fky_estatus_aclaracion = sta.pky_estatus_aclaracion
		where pro.numero_cuenta = pnum_credito
		AND acl.fechacaptura BETWEEN v_periodo_tc_ini AND v_periodo_tc_fin
		and acl.fky_estatus_aclaracion = 2
		and cr.status_cred in ('AA','BA','BT','FF','E1','E2','E3')
		and cr.campo_trab3 <> 'BAJA'
		and cr.empresa = '001'
		
		LET vFechaAclara = DAY(vfechacaptura) || "-" || DECODE(MONTH(vfechacaptura),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6","JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC") || "-" || YEAR(vfechacaptura);
		LET vFechaMov = DAY(vfechahora) || "-" || DECODE(MONTH(vfechahora),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6","JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC") || "-" || YEAR(vfechahora);

		LET v_maximo    = v_maximo + 1 ;
		LET v_contador  = 0;
		LET v_concepto  = "";
		LET vFolioAclara = trim(vfolio_csuac);

        FOREACH 
			EXECUTE PROCEDURE corta_linea(vdescripcion,v_corta_linea_detalle)
				INTO v_concepto, v_corta_retorno
			
			LET v_contador = v_contador + 1;
			IF  v_contador <>1  THEN
				LET vfechacaptura =date(1);
				LET vfechahora =date(1);
				LET vimportereclamado =0; 
			END IF;
			
			IF vFechaMov IS NULL OR NVL(vFechaMov,'') = '' THEN 
				LET vFechaMov = vFechaAclara;
			END IF;
			
			IF NOT EXISTS (Select num_credito from bdicred:sd_aclaraciones_edocta where num_credito = pnum_credito and folio = vfolio_csuac) THEN
				INSERT INTO bdicred:sd_aclaraciones_edocta
							(
							fecha_emision,		num_credito,		secuencia,			nlinea,				fecha_aclara,		folio,
							fecha_movimiento,   descripcion,		importe,			estatus_aclara
							)
					VALUES
							(
							pfechahoy,			pnum_credito,		v_maximo,			v_contador,			trim(vFechaAclara),	vFolioAclara,
							trim(vFechaMov),    trim(v_concepto), 	vimportereclamado,	vStatusAclara
							);
			ELSE 
				CONTINUE FOREACH;
			END IF;
			
        END FOREACH; 
        
			LET v_concepto    	= "";
			LET vFechaAclara	= "";
			LET vFechaMov		= "";
			
	END FOREACH;
	

   	--##############################################################
	--##	GENERACION MENSAJES	 EDO CUENTA				          ##
   	--##############################################################

	/* SELECT valor::DECIMAL(14,10) INTO v_factor
	 FROM bdicred:sd_param WHERE cod_param = '036';

	 IF v_factor IS NULL THEN
	 	LET v_factor = 0.1139417057;
	 END IF

   LET v_secuencia_mensaje  = 0 ;
   LET v_si_paga = v_usted_debe ;


	 IF v_usted_debe <= 0 THEN
	 	LET v_aplica_factor = 0;
	 ELSE
	 	LET v_aplica_factor = v_usted_debe * v_factor;
	 END IF*/
	 
	  --GJEV
	LET v_secuencia_mensaje  = 0 ;
	LET v_im = (((v_tasa_anual / 100) * 30.50)*(1 + v_iva_suc))/360;
	LET v_si_paga = (vlsaldo_corte * v_im)/ (1 - pow( (1 + v_im),-(1 * 12))); 


	IF v_si_paga <= 0 THEN
	LET v_aplica_factor = 0;
	ELSE
	LET v_aplica_factor = v_si_paga;
	END IF	
	--GJEV
	 ------ PIQV		
	/* LET dMonto_No_Exigible = NVL(v_monto_adeudo,0) - NVL(v_capital_ven_tc,0);	
	 IF NVL(v_monto_adeudo,0) = NVL(v_capital_ven_tc,0) AND NVL(v_monto_adeudo,0) > 0 THEN
		 LET iMesesLiq = 1;
	 ELIF NVL(v_monto_adeudo,0) <= 0 THEN
		 LET iMesesLiq = 0;
	 ELSE 
		 EXECUTE PROCEDURE "informix".calcula_meses_fin(pempresa,v_numprod,dMonto_No_Exigible,
									  v_limite_tc, NVL(v_tasa_anual,0)/100,v_iva_suc,pfechahoy)
		 INTO cCodRetMeses,iMesesLiq; 
		 
		 IF cCodRetMeses <> "00000" THEN
			LET iMesesLiq = 44;
		 END IF;
		 
         IF iMesesLiq > 99 THEN
            LET iMesesLiq = 99;
         END IF;		 
		 
	 END IF;*/
	 ------ PIQV	
	 ----MOD CAS

			
	INSERT INTO sd_mensajes_edocta
	(
		fecha_emision, 		num_credito,		secuencia,
		nlinea,				mensajes
	)
	SELECT 	pfechahoy, 			TRIM(pnum_credito), 	clave,		
			secuencia,			mensaje
	FROM mensajes_imp;
    /*SELECT  pfechahoy, TRIM(pnum_credito),
    clave,secuencia,CASE WHEN clave=2 AND secuencia=1
    THEN v_aplica_factor ELSE NULL END ,REPLACE(mensaje,v_linea_auxiliar,TRIM(v_aplica_factor::VARCHAR(21))),
	CASE WHEN clave=2 AND secuencia=1 THEN iMesesLiq ELSE NULL END
    FROM mensajes;*/
    
   	--##############################################################
	--##	GENERACION   PIE	 EDO CUENTA				          ##
   	--##############################################################
   	LET v_tasa_mensual   = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = v_tasa_mora / 12;

    IF ( v_interes_tc > 0 ) THEN
       LET v_saldo_promedio = round((v_interes_tc*360)/(v_dias_periodo_tc * (v_tasa_anual / 100)),2);
    ELSE
	   LET v_saldo_promedio = 0;
    END IF;
	
	SELECT 	count(*) 
		INTO v_cuantos_avisos
	FROM sd_amortiza_credito
	WHERE empresa = pempresa
	AND num_credito = pnum_credito
	AND capital_status IN ("2","7","6");	
	
	--------------------------------------------------------------------------
		 --   SECCION: SALDO SOBRE EL QUE SE CALCULARON LOS INTERESES   --
	--------------------------------------------------------------------------
							--Tipos de procesos--
							--Ordinarios            = "OR"--
							--Moratorios            = "MO"--
							--Tasa preferencia      = "TP"--
							--Diferidos             = "DF"--
							--Disposicio efectivo   = "DI"--
						--Disp otra lineas      = "OL"--
	LET vDescripcion_OR = 'Ordinarios';
	LET vDescripcion_M0 = 'Moratorios';
	LET vDescripcion_TP = 'De saldo revolvente a tasa preferencial';
	LET vDescripcion_DF = 'De compras y cargos diferidos a meses con intereses';
	LET vDescripcion_DE = 'Por disposiciones de efectivo';
	LET vDescripcion_OL = 'Por disposiciones de efectivo de otras lineas de crédito';
	
	------------------------Ordinarios----------------------------------------
	IF NVL(v_saldo_promedio,0) <= 0 OR NVL(v_saldo_promedio,0) = '' OR NVL(v_saldo_promedio,0) is null  THEN
		LET v_saldo_base = 'NA';
		LET v_tasa_inter_aplicable  = 'NA';
		LET v_dias_periodo  = 'NA';
		LET v_monto_interes  = 'NA';

	else 
		LET v_saldo_base = NVL(v_saldo_promedio,0);
		LET v_tasa_inter_aplicable = NVL(v_tasa_anual,0);
		LET v_dias_periodo = NVL(v_dias_periodo_tc,0);
		LET v_monto_interes = NVL(v_interes_tc,0);
			
	end if ;

	LET v_tipo_proceso = "OR";
	LET v_secuencia=1;
	LET v_linea = 1;
	INSERT INTO sd_sdo_int_periodo_edc 
		( 
		fecha_emision,	        num_credito,				secuencia,			linea,			descripcion,		sdo_base,
		dias_periodo,			tasa_inter_aplicable,		monto_interes,		tipo_proceso
		)
	 VALUES
		(
		pfechahoy,	            TRIM(pnum_credito),			v_secuencia,		v_linea,		vDescripcion_OR,	v_saldo_base,
		v_dias_periodo,			v_tasa_inter_aplicable,		v_monto_interes,	v_tipo_proceso
		);  
	------------------------Moratorios--------------------------------------------
	--LET v_num_vencido = v_cuantos_avisos - 1;
	IF v_cuantos_avisos <= 0 AND (NVL(v_moratorios_tc,0) <= 0 OR NVL(v_moratorios_tc,0) = '' OR NVL(v_moratorios_tc,0) is null) THEN
		LET v_saldo_base = 'NA';
		LET v_tasa_inter_aplicable  = 'NA';
		LET v_dias_periodo  = 'NA';
		LET v_monto_interes  = 'NA';
		
	ELIF v_cuantos_avisos <= 0 AND v_Act = 0 AND v_status_cred = 'E1' AND NVL(v_moratorios_tc,0) > 0 THEN 
		LET v_saldo_base = 'NA';
		LET v_tasa_inter_aplicable  = 'NA';
		LET v_dias_periodo  = 'NA';
		LET v_monto_interes  = 'NA';
				
	ELIF v_cuantos_avisos <= 0 AND v_Act <> 0 AND v_status_cred IN('E1','E2','E3') AND NVL(v_moratorios_tc,0) > 0 THEN 
		LET v_saldo_base = 'NA';
		LET v_tasa_inter_aplicable  = 'NA';
		LET v_dias_periodo  = 'NA';
		LET v_monto_interes  = 'NA';
	else 
		LET v_num_vencido = v_cuantos_avisos - 1;
		LET v_tasa_inter_aplicable = NVL(v_tasa_mora,0) + NVL(v_tasa_anual,0);
		LET v_monto_interes = NVL(v_moratorios_tc,0) + NVL(v_interes_ven_tc,0);
   
		IF NVL(v_monto_interes,0) > 0 THEN 
			LET vCalculaDias = (vlfCorte - (ADD_MONTHS(vlfCorte,v_num_vencido * -1)) + 1);
			
			IF vCalculaDias = 1 THEN
				LET vMoraMtoInt = NVL(v_capital_ven_tc,0);
				LET v_dias_periodo = vCalculaDias;
			ELSE
				LET v_mora_tasa = v_monto_interes / v_tasa_inter_aplicable;
				LET v_mora_dias_anio = (v_mora_tasa * 36000);
				LET vMoraMtoInt = v_mora_dias_anio / vCalculaDias;
				LET vMoraMtoInt = round(NVL(vMoraMtoInt,0),2);
				LET v_dias_periodo = vCalculaDias;
			END IF;
		ELSE 
			LET vMoraMtoInt = 0;
		END IF;
		LET v_saldo_base = NVL(vMoraMtoInt,0);
		--END IF;
	end if; 

	LET v_tipo_proceso = "MO";
	LET v_secuencia=2;
	LET v_linea = 1;
	
	INSERT INTO sd_sdo_int_periodo_edc 
		( 
		fecha_emision,	        num_credito,				secuencia,				linea,				descripcion,			sdo_base,
		dias_periodo,			tasa_inter_aplicable,		monto_interes,			tipo_proceso
		)
	VALUES
		(
		pfechahoy,	            TRIM(pnum_credito), 		v_secuencia,			v_linea,			vDescripcion_M0,		v_saldo_base,
		v_dias_periodo,			v_tasa_inter_aplicable,		v_monto_interes,		v_tipo_proceso
		);  
	------------------------Tasa Preferecial--------------------------------------
	LET v_saldo_base = 'NA';
	LET v_tasa_inter_aplicable  = 'NA';
	LET v_dias_periodo  = 'NA';
	LET v_monto_interes  = 'NA';
			
	LET v_tipo_proceso = "TP";
	LET v_secuencia=3;
	LET v_linea = 1;
	INSERT INTO sd_sdo_int_periodo_edc 
		( 
		fecha_emision,	        num_credito,			secuencia,				linea,				descripcion,			sdo_base,
		dias_periodo,			tasa_inter_aplicable,	monto_interes,			tipo_proceso
		)
	VALUES
		(
		pfechahoy,	            TRIM(pnum_credito), 	v_secuencia,			v_linea,			vDescripcion_TP,		v_saldo_base,
		v_dias_periodo,			v_tasa_inter_aplicable, v_monto_interes,		v_tipo_proceso
		);  
	------------------------Diferidos----------------------------------------------
	LET v_saldo_diferido = 0;
	LET v_secuencia=4;
	LET v_linea = 1;
	LET v_tipo_proceso = "DF";
	
	SELECT fecha_emision,num_credito,num_cred_credsol,int_periodo,iva_int_periodo,saldo_pendiente,tasa,diasmes,monto_ori
	FROM "informix".sd_detalle_dif_edocta 
	WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito
	INTO TEMP univer_credsol WITH NO LOG;
	
	FOREACH WITH HOLD 
		SELECT 	num_cred_credsol,	int_periodo,	iva_int_periodo,	tasa,		saldo_pendiente,	diasmes,		monto_ori
		INTO 	vNumCredPF,			vMtoIntPF, 		vIvaIntPerDif,		vTasaPF,	v_saldo_diferido,	vdiacortedif,	vMontoCompra
		FROM univer_credsol
		WHERE fecha_emision = pfechahoy --AND num_cred_credsol = vNumCredPF
	
	
		--vlDiaCorte --> VARIABLE DEL DIA DE CORTE DE LA TARJETA
		IF vdiacortedif <= vlDiaCorte THEN
			LET v_dias_periodo = NVL(v_dias_periodo_tc,0);
		ELSE
			EXECUTE PROCEDURE sp_mes_siguiente(vlfCorte - 1 UNITS MONTH,-1,DAY(vlfCorte - 1 UNITS MONTH))
			INTO v_cod_ret_otro,v_periodo_anterior_dif,v_dias_periodo_tc;
			LET v_dias_periodo = NVL(v_dias_periodo_tc,0) * -1;
		END IF;
			
		
		IF NVL(v_saldo_diferido,0) <= 0 OR NVL(v_saldo_diferido,0) = '' OR NVL(v_saldo_diferido,0) is null AND vMtoIntPF > 0 THEN
			LET v_saldo_base = 'NA';
			LET v_tasa_inter_aplicable  = 'NA';
			LET v_dias_periodo  = 'NA';
			LET v_monto_interes  = 'NA';
			LET vNumCredPF	= 'NA';
		ELSE 
			--LET v_saldo_base = (NVL(vMtoIntPF,0) / v_dias_periodo_tc) * 360 / vTasaPF;
			LET v_tasa_inter_aplicable = NVL(vTasaPF,0);
			LET v_dias_periodo = NVL(v_dias_periodo,0);
			
			IF NVL(vMtoIntPF,0) = 0 THEN 
				LET v_monto_interes = 0;
				LET v_saldo_base = 0;
			ELSE
				LET v_monto_interes = NVL(vMtoIntPF,'');
				LET v_saldo_base = ((ROUND(NVL(v_monto_interes,0),2) / v_tasa_inter_aplicable) * 36000 / v_dias_periodo)::DECIMAL(18,2);
				LET v_saldo_base = NVL(v_saldo_base,0);
			END IF;
			
			IF NVL(v_saldo_base,0) > NVL(vMontoCompra,0) THEN 
				LET v_saldo_base = NVL(vMontoCompra,0);
			END IF;
		END IF;
		
		INSERT INTO sd_sdo_int_periodo_edc 
			( 
			fecha_emision,	        num_credito,			secuencia,				linea,				descripcion,			sdo_base,
			dias_periodo,			tasa_inter_aplicable,	monto_interes,			tipo_proceso,		numcred_relacion
			)
		VALUES
			(
			pfechahoy,	            TRIM(pnum_credito),		v_secuencia,			v_linea,			vDescripcion_DF,		v_saldo_base,
			v_dias_periodo,			v_tasa_inter_aplicable,	v_monto_interes,		v_tipo_proceso,		vNumCredPF
			);  
			
		LET v_linea=v_linea+1;
		
	END FOREACH;
	
	SELECT COUNT(*) INTO existe_df FROM "informix".sd_sdo_int_periodo_edc WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito AND tipo_proceso = 'DF';
	IF NVL(existe_df,0) = 0 OR existe_df IS NULL THEN 
		INSERT INTO sd_sdo_int_periodo_edc 
			( 
			fecha_emision,	        num_credito,			secuencia,				linea,				descripcion,			sdo_base,
			dias_periodo,			tasa_inter_aplicable,	monto_interes,			tipo_proceso,		numcred_relacion
			)
		VALUES
			(
			pfechahoy,	            TRIM(pnum_credito),		v_secuencia,			v_linea,			vDescripcion_DF,		'NA',
			'NA',					'NA',					'NA',					v_tipo_proceso,		'NA'
			);  
	END IF;
	
	------------------------Disposicion----------------------------------------------
	LET v_saldo_base = 'NA';
	LET v_tasa_inter_aplicable  = 'NA';
	LET v_dias_periodo  = 'NA';
	LET v_monto_interes  = 'NA';

	LET v_tipo_proceso = "DE";
	LET v_secuencia=5;
	LET v_linea = 1;
	
	INSERT INTO sd_sdo_int_periodo_edc 
		( 
		fecha_emision,	        num_credito,			secuencia,				linea,				descripcion,			sdo_base,
		dias_periodo,			tasa_inter_aplicable,	monto_interes,			tipo_proceso
		)
	VALUES
		(
		pfechahoy,	            TRIM(pnum_credito),		v_secuencia,			v_linea,			vDescripcion_DE,		v_saldo_base,
		v_dias_periodo,			v_tasa_inter_aplicable,	v_monto_interes,		v_tipo_proceso
		);  
	------------------------Disposicion otra lineas--------------------------
	LET v_saldo_base = 'NA';
	LET v_tasa_inter_aplicable  = 'NA';
	LET v_dias_periodo  = 'NA';
	LET v_monto_interes  = 'NA';

	LET v_tipo_proceso = "OL";
	LET v_secuencia=6;
	LET v_linea = 1;
	INSERT INTO sd_sdo_int_periodo_edc 
		( 
		fecha_emision,	        num_credito,			secuencia,				linea,				descripcion,			sdo_base,
		dias_periodo,			tasa_inter_aplicable,	monto_interes,			tipo_proceso
		)
	VALUES
		(
		pfechahoy,	            TRIM(pnum_credito),		v_secuencia,			v_linea,			vDescripcion_OL,		v_saldo_base,
		v_dias_periodo,			v_tasa_inter_aplicable,	v_monto_interes,		v_tipo_proceso
		);
	
	
	--JMAH INI CAT 

	-- Obtiene el movimiento de comision por apertura (Se toma en cuenta para calculo solo el mes del cargo)    --  RQM 10 993 INI
	-- Julio 2019: A peticion de productos: La comision de apertura se considerara en todo momento para el calculo del CAT
	--LET mMntoComApert = nvl(mMntoComApert,0);
	

	-- Comision por anualidad. (Se toma en cuenta para todos los meses). Obtiene montos de anualidad: titular y adicional.
	-- campo: cobro_comision_anual es para cobro de anualidad del producto. El nvo campo: cat_edc_com_anualidad es para tomar la anualidad en el calculo del CAT para x producto.
	--Select cobro_comision_anual, substr(cod_comision_anualidad,1,4), substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional
	Select cat_edc_com_anualidad, substr(cod_comision_anualidad,1,4), substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional, cod_comision_apertura
	  Into cCobrComisAnual      , dClvComAnualTit                   , dClvComAnualAdi                   , cCat_adicional          , dClvComApertura     
	  From bdicred:sd_definicion Where num_producto = v_numprod;    -- Obtiene clave de comision anualidad.

	Select monto Into dMtoComAnualTit From bdicred:sd_tpcomis Where cod_comis = dClvComAnualTit;    -- Obtiene monto anualidad titular
	Select monto Into dMtoComAnualAdi From bdicred:sd_tpcomis Where cod_comis = dClvComAnualAdi;    -- Obtiene monto anualidad adicional
	Select monto Into mMntoComApert From bdicred:sd_tpcomis Where cod_comis = dClvComApertura;      -- Obtiene monto comision apertura
	
	LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
	LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);
	LET mMntoComApert = nvl(mMntoComApert,0);

	IF cCobrComisAnual = '1' THEN
		/*Select NVL(SUM(monto), 0) INTO mMntoComAnual From bdicred:sd_movhis Where fecha_mov >= v_periodo_tc_ini and fecha_mov <= v_periodo_tc_fin 
		   and codigo_fun = '339' and codigo_ref in (100, 101) and num_credito = pnum_credito and transacc_suc in ('8244','8245') and reversado = 'N';*/
		IF cCat_adicional = '0' THEN Let dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
		LET mMntoComAnual = dMtoComAnualTit + dMtoComAnualAdi;
	ELSE
	
	
		LET mMntoComAnual = 0;
	END IF;
	/*IF v_numprod =  '6001' THEN
		LET dComisiones = 50;
	ELSE
		LET dComisiones = 0;
	END IF;*/
	--LET dComisiones = mMntoComApert + mMntoComAnual;
	LET dComisiones = mMntoComApert;    -- Si no corresponde comision, variable = 0
	
	--  RQM 10 993 FIN

	select CASE WHEN  num_producto = '6001' THEN 0 ELSE nvl((c.captrans19 + c.capvenexig19),0) END +
	CASE WHEN  num_producto = '6001' THEN 0 ELSE nvl((c.captrans20 + c.capvenexig20),0) END +
	nvl((c.captrans21 + c.capvenexig21),0) +
	nvl((c.captrans22 + c.capvenexig22),0) +
	nvl((c.captrans23 + c.capvenexig23),0) +
	nvl((c.captrans24 + c.capvenexig24),0) +
	nvl((c.captrans25 + c.capvenexig25),0) +
	nvl((c.captrans26 + c.capvenexig26),0) +
	nvl((c.captrans27 + c.capvenexig27),0) +
	nvl((c.captrans28 + c.capvenexig28),0) +
	nvl((c.captrans29 + c.capvenexig29),0) +
	nvl((c.captrans30 + c.capvenexig30),0) +
	nvl((c.captrans31 + c.capvenexig31),0) +
	(b.captrans1 + b.capvenexig1) +
	(b.captrans2 + b.capvenexig2) +
	(b.captrans3 + b.capvenexig3) +
	(b.captrans4 + b.capvenexig4) +
	(b.captrans5 + b.capvenexig5) +
	(b.captrans6 + b.capvenexig6) +
	(b.captrans7 + b.capvenexig7) +
	(b.captrans8 + b.capvenexig8) +
	(b.captrans9 + b.capvenexig9) +
	(b.captrans10 + b.capvenexig10) + 
	(b.captrans11 + b.capvenexig11) +
	(b.captrans12 + b.capvenexig12) +
	(b.captrans13 + b.capvenexig13) +
	(b.captrans14 + b.capvenexig14) +
	(b.captrans15 + b.capvenexig15) +
	(b.captrans16 + b.capvenexig16) +
	(b.captrans17 + b.capvenexig17) +
	(b.captrans18 + b.capvenexig18) +
	CASE WHEN  num_producto  <> '6001' THEN 0 ELSE nvl((b.captrans19 + b.capvenexig19),0) END +
	CASE WHEN  num_producto  <> '6001' THEN 0 ELSE nvl((b.captrans20 + b.capvenexig20),0) END ,
	round((b.captrans1 + b.capvenexig1) * tasa_moratorios / 36000,2) +
	round((b.captrans2 + b.capvenexig2) * tasa_moratorios / 36000,2) +
	round((b.captrans3 + b.capvenexig3) * tasa_moratorios / 36000,2) +
	round((b.captrans4 + b.capvenexig4) * tasa_moratorios / 36000,2) +
	round((b.captrans5 + b.capvenexig5) * tasa_moratorios / 36000,2) +
	round((b.captrans6 + b.capvenexig6) * tasa_moratorios / 36000,2) +
	round((b.captrans7 + b.capvenexig7) * tasa_moratorios / 36000,2) +
	round((b.captrans8 + b.capvenexig8) * tasa_moratorios / 36000,2) +
	round((b.captrans9 + b.capvenexig9) * tasa_moratorios / 36000,2) +
	round((b.captrans10 + b.capvenexig10) * tasa_moratorios / 36000,2) +
	round((b.captrans11 + b.capvenexig11) * tasa_moratorios / 36000,2) +
	round((b.captrans12 + b.capvenexig12) * tasa_moratorios / 36000,2) +
	round((b.captrans13 + b.capvenexig13) * tasa_moratorios / 36000,2) +
	round((b.captrans14 + b.capvenexig14) * tasa_moratorios / 36000,2) +
	round((b.captrans15 + b.capvenexig15) * tasa_moratorios / 36000,2) +
	round((b.captrans16 + b.capvenexig16) * tasa_moratorios / 36000,2) +
	round((b.captrans17 + b.capvenexig17) * tasa_moratorios / 36000,2) +
	round((b.captrans18 + b.capvenexig18) * tasa_moratorios / 36000,2) +
	CASE WHEN  num_producto  <> '6001' THEN 0 ELSE round((b.captrans19 + b.capvenexig19) * tasa_moratorios / 36000,2)  END +
	CASE WHEN  num_producto  <> '6001' THEN 0 ELSE round((b.captrans20 + b.capvenexig20) * tasa_moratorios / 36000,2)  END +
	CASE WHEN  num_producto  ='6001' THEN 0 ELSE round((c.captrans19 + c.capvenexig19) * tasa_moratorios / 36000,2)  END +
	CASE WHEN  num_producto  = '6001' THEN 0 ELSE round((c.captrans20 + c.capvenexig20) * tasa_moratorios / 36000,2)  END +
	nvl(round((c.captrans21 + c.capvenexig21) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans22 + c.capvenexig22) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans23 + c.capvenexig23) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans24 + c.capvenexig24) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans25 + c.capvenexig25) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans26 + c.capvenexig26) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans27 + c.capvenexig27) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans28 + c.capvenexig28) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans29 + c.capvenexig29) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans30 + c.capvenexig30) * tasa_moratorios / 36000,2),0) +
	nvl(round((c.captrans31 + c.capvenexig31) * tasa_moratorios / 36000,2),0) 
	INTO dSdoPromVenAux ,dIntVenc
	 from bdicred:sd_maecred  a
	 join bdicred:sd_sdodiario b on (a.num_credito = b.num_credito and b.fecha = MDY(MONTH(pfechahoy),01,YEAR(pfechahoy)))
	 left outer join bdicred:sd_sdodiario c on (a.num_credito = c.num_credito and c.fecha = monthadd(b.fecha,-1))
	where a.empresa = pempresa
	AND a.num_credito  = pnum_credito;

	IF dSdoPromVenAux > 0 THEN
		LET dSdoPromVen = dSdoPromVenAux / v_dias_periodo_tc ;
	ELSE
		LET dSdoPromVen = dSdoPromVenAux;
	END IF;
	LET dSaldoPromCredSolAux=0;
	LET dIntCredSolAux=0;
	
	IF vlComprasDif > 0 OR v_saldo_diferido > 0 THEN
	
		FOREACH WITH HOLD
			select  nvl((c.capvig21 ),0) +
			nvl((c.capvig22 ),0) +
			nvl((c.capvig23 ),0) +
			nvl((c.capvig24 ),0) +
			nvl((c.capvig25 ),0) +
			nvl((c.capvig26 ),0) +
			nvl((c.capvig27 ),0) +
			nvl((c.capvig28 ),0) +
			nvl((c.capvig29 ),0) +
			nvl((c.capvig30 ),0) +
			nvl((c.capvig31 ),0) +
			(b.capvig1) +
			(b.capvig2 ) +
			(b.capvig3 ) +
			(b.capvig4 ) +
			(b.capvig5 ) +
			(b.capvig6 ) +
			(b.capvig7 ) +
			(b.capvig8 ) +
			(b.capvig9 ) +
			(b.capvig10 ) + 
			(b.capvig11 ) +
			(b.capvig12 ) +
			(b.capvig13 ) +
			(b.capvig14 ) +
			(b.capvig15 ) +
			(b.capvig16 ) +
			(b.capvig17 ) +
			(b.capvig18 ) +
			nvl((b.capvig19 ),0)  +
			nvl((b.capvig20 ),0)  ,
			round((b.capvig1 ) * tasa_interes / 36000,2) +
			round((b.capvig2 ) * tasa_interes / 36000,2) +
			round((b.capvig3 ) * tasa_interes / 36000,2) +
			round((b.capvig4 ) * tasa_interes / 36000,2) +
			round((b.capvig5 ) * tasa_interes / 36000,2) +
			round((b.capvig6 ) * tasa_interes / 36000,2) +
			round((b.capvig7 ) * tasa_interes / 36000,2) +
			round((b.capvig8  ) * tasa_interes / 36000,2) +
			round((b.capvig9 ) * tasa_interes / 36000,2) +
			round((b.capvig10 ) * tasa_interes / 36000,2) +
			round((b.capvig11 ) * tasa_interes / 36000,2) +
			round((b.capvig12 ) * tasa_interes / 36000,2) +
			round((b.capvig13 ) * tasa_interes / 36000,2) +
			round((b.capvig14 ) * tasa_interes / 36000,2) +
			round((b.capvig15 ) * tasa_interes / 36000,2) +
			round((b.capvig16 ) * tasa_interes / 36000,2) +
			round((b.capvig17 ) * tasa_interes / 36000,2) +
			round((b.capvig18 ) * tasa_interes / 36000,2) +
			round((b.capvig19 ) * tasa_interes / 36000,2)   +
			round((b.capvig20 ) * tasa_interes / 36000,2)   +
			nvl(round((c.capvig21 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig22 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig23 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig24 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig25 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig26 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig27 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig28 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig29 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig30 ) * tasa_interes / 36000,2),0) +
			nvl(round((c.capvig31 ) * tasa_interes / 36000,2),0) 
				INTO dSaldoPromCredSol ,dIntCredSol
			 from sd_detalle_dif_edocta   a
			 join bdicred:sd_sdodiariocrd b on (a.num_cred_credsol = b.num_credito and b.fecha = MDY(MONTH(pfechahoy),1,YEAR(pfechahoy)))
			 join bdicred:sd_maecredcrd d on (a.num_cred_credsol = d.num_credito) 
			 left outer join bdicred:sd_sdodiariocrd c on (a.num_cred_credsol = c.num_credito and c.fecha = monthadd(b.fecha,-1))
			where a.num_credito  = pnum_credito
		
			LET dSaldoPromCredSol = dSaldoPromCredSolAux +dSaldoPromCredSolAux;
			LET dIntCredSol = dIntCredSolAux +dIntCredSolAux;
		
		END FOREACH;
	ELSE
			LET dSaldoPromCredSol =0;
			LET dIntCredSol = 0;
	END IF;
	
	IF NVL(dSdoPromVen,0)+NVL(v_saldo_promedio,0)+NVL(dSaldoPromCredSol,0) > 0 THEN			
					
		LET dTasaInt = ((NVL(v_interes_tc,0) +NVL(dIntVenc,0) +NVL(dIntCredSol,0)) / (NVL(v_saldo_promedio,0)+NVL(dSdoPromVen,0)+NVL(dSaldoPromCredSol,0))) / v_dias_periodo_tc * 360;
		
		IF dTasaInt >= 0.995 THEN --RQI CAT 
			LET dTasaInt = 0.995;
		END IF;
		
		LET dPagoReq = v_limite_tc * dTasaInt / 360 * 30 ;
	ELSE
		LET dTasaInt = 0;
		LET dPagoReq = 0;
	END IF;
	
	IF v_interes_tc = 0 AND v_saldo_promedio = 0 AND v_status_cred IN('AA','E1') THEN--indica que liquido todo su adeudo
		LET dTasaInt = 0;
		LET dPagoReq = 0;
	END IF
	
	-- Modificaciones al calculo del CAT
	IF v_saldo_promedio > 0 THEN
		LET dtasa_prom_pond = ((v_interes_tc / v_saldo_promedio)/ v_dias_periodo_tc ) * 360;
		LET dtasa_prom_pond_fin = dtasa_prom_pond * 100;
	ELSE
		LET dtasa_prom_pond_fin = 0;
	END IF;			
	LET dPagoReq = 10; -- Pago requerido 10% (de acuerdo a indicaciones del area de producto. (???)
	
	--  No calcule el CAT cuando los intereses cargados son cero en el periodo.	Pero si calcule CAT si se cobra anualidad al producto.
	-- IF v_limite_tc <=0 THEN    
	-- IF v_capital_tc >= 0 AND v_intereses_pag = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' THEN

	--IF v_capital_tc >= 0 AND v_intereses_pag = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' AND mMntoComApert = 0 THEN
	IF v_capital_tc >= 0 AND v_interes_tc = 0 AND v_capital_ven_tc = 0 AND cCobrComisAnual = '0' AND mMntoComApert = 0 THEN		-- A peticion de Fco Espinoza Hdz Mayo 2019
		LET vCatFinal = 0;
	ELSE
		--EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(v_limite_tc,dPagoReq,36,36,dComisiones) into cCodRet,cMensajeRet,vCatFinal;
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(v_limite_tc, dPagoReq, 36, 36, dComisiones, dComs_GastCob, mMntoComAnual, dtasa_prom_pond_fin) 
		   INTO cCodRet, cMensajeRet, vCatFinal;
		   
	END IF;

	IF vCatFinal <= 0 THEN
		LET vCatFinal = 0 ;				
	END IF;

	IF vCatFinal > 160.1 THEN
		LET vCatFinal = 160.1 ;			
	END IF;
	
	LET v_catAux = vCatFinal;

	--JMAH FIN CAT 
	
	
	--------------------------------------------------------
    --	GENERA EL PIE DEL ESTADO DE CUENTA
    --------------------------------------------------------
	INSERT INTO sd_pie_edocta
			(
			fecha_emision,				num_credito,			tasa_mensual,				tasa_anual,				cat,
			saldo_promedio,				tasa_mora,				tasa_mensual_mora,			dias_periodo
			)
	VALUES
			(
			pfechahoy,					pnum_credito,			NVL(v_tasa_mensual,0),		NVL(v_tasa_anual,0),	NVL(v_catAux,0),
			NVL(v_saldo_promedio,0),	NVL(v_tasa_mora,0),		NVL(v_tasa_mensual_mora,0),	0
			);
			
	----------- ACTUALIZA EL TIPO DE TARJETA DE LA CREDISOLUCION (PAGOS FIJOS)
	FOREACH WITH HOLD 
		SELECT tipo_tarjeta, num_cred_credsol, num_tar_ori INTO vTipoTdcPF, vNumCredCredsol, v_numtdc_pf
		FROM "informix".sd_detalle_dif_edocta WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito
	
		IF (NVL(vTipoTdcPF,'') = '' OR vTipoTdcPF IS NULL) AND (NVL(v_numtdc_pf,'') = '' OR v_numtdc_pf IS NULL) THEN
			UPDATE "informix".sd_detalle_dif_edocta SET tipo_tarjeta = 'T', num_tar_ori=v_num_tarjeta WHERE fecha_emision = pfechahoy AND num_cred_credsol = trim(vNumCredCredsol);
		ELIF NVL(vTipoTdcPF,'') = '' OR vTipoTdcPF IS NULL THEN
			UPDATE "informix".sd_detalle_dif_edocta SET tipo_tarjeta = 'T' WHERE fecha_emision = pfechahoy AND num_cred_credsol = trim(vNumCredCredsol);
		ELIF NVL(v_numtdc_pf,'') = '' OR v_numtdc_pf IS NULL THEN
			UPDATE "informix".sd_detalle_dif_edocta SET num_tar_ori=v_num_tarjeta WHERE fecha_emision = pfechahoy AND num_cred_credsol = trim(vNumCredCredsol);
		END IF;
	END FOREACH;
			
   	--##############################################################
	--##	GENERACION  CLAVE DE COBRANZA				          ##
   	--##############################################################
        --	1.--TIPO DE CLIENTE: (2 Numero)
    --	2.--SITUACION ESPECIAL: (1 letra)
    --------------------------------------------------------
    SELECT FIRST 1 situacion,causa
    INTO v_situacion ,v_situacion_esp
    FROM bdisitesp:se_ctessitespcte
    WHERE numcte = v_numcte;

    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF
    ---Cambia 1 por L, RQM 09-124 MAJF AGO,2009
    IF  v_situacion = "G" THEN
      LET v_situacion_esp = replace(v_situacion_esp, 1,'L');
    END IF;

    --------------------------------------------------------
    --	2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087
    --------------------------------------------------------
    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "000";
    END IF
-- INICIO CAH *** INC SE ***
      LET v_situacion_esp= lpad( trim(v_situacion_esp), 3,'0');
-- FIN    CAH *** INC SE ***

    --------------------------------------------------------
    --3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Anio Nacimiento (2 Numeros)
    --------------------------------------------------------
	SELECT 	TRIM(NVL(estado_civil,'')),
			--TRIM(NVL(SUBSTR(habita_en, 2,1),'1')), --usado hasta antes de paso2 de alta unica, catalogo con valores 01, 02, etc
            nvl(substr(TRIM(habita_en),1,1), 'P'),  --Cambio a catalgo, ahora usa letras, paso 02 alta unica, default propia
		  	TRIM(NVL(sexo,'')),
		  	NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	INTO 	v_estado_civil,
			v_tp_casa,
			v_sexo,
			v_nacimiento
    FROM   bdinteg:si_ctepf
	WHERE  numcte = v_numcte;

    --------------------------------------------------------
    --6.--SALARIO (2 NUMEROS):
    --------------------------------------------------------
	SELECT NVL(ingreso_mensual,0) / v_SalarioMinimoCoppel
		INTO   v_salario
	FROM   bdisolic:ss_resum_scor_fin
		WHERE  empresa = pempresa
		AND num_solicitud = pnum_credito ;

		IF v_salario < 0  OR v_salario IS NULL THEN
					LET v_salario = 0;



		ELSE
			IF v_salario >= 22 THEN
				LET v_cantidad = LPAD(22,2,'0');
			ELSE
				LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
			END IF
		END IF	
    --------------------------------------------------------
    --7.-ANTIGUEDAD: (2 NUMEROS)
    --------------------------------------------------------
  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF
    --------------------------------------------------------
    --9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)
    --------------------------------------------------------
	IF NVL(v_monto_adeudo,0) >= 100000 THEN
  		--IF cod_ret = "000" THEN
  			--LET cod_ret = "213";
  		--END IF
		LET v_mto_tot_adeudo = "99999";
	ELSE
		IF NVL(v_monto_adeudo,0) < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(round(v_monto_adeudo),5,'0');
		END IF

	END IF
    --------------------------------------------------------
    --10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)
    --------------------------------------------------------
	IF NVL(v_mto_adeudo_venc,0) >= 100000 THEN
  		--IF cod_ret = "000" THEN
  		--	LET cod_ret = "214";
  		--END IF
		LET v_adeudo_vencido = "99999";
	ELSE
            --LET v_mto_adeudo_venc = v_mto_adeudo_venc + v_monto_financiado; -- Solictado 19 Nov 2008 MEL
            LET v_mto_adeudo_venc = v_monto_financiado; -- Solictado 20 Nov 2008 MEL
		--LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF
    --------------------------------------------------------
    --11.-FECHA DE ULT. PAGO: (4 NUMEROS)
    --------------------------------------------------------
	IF v_fecha_ultimo_pago IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago_month = MONTH(v_fecha_ultimo_pago);
		LET v_fec_ult_pago_year =  SUBSTR(YEAR(v_fecha_ultimo_pago),3,2);
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF

    --------------------------------------------------------
    --12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)
    --------------------------------------------------------
    FOREACH SELECT FIRST 1 importe,TO_CHAR(fecha_compac,"%m%y"), 'P'
	    INTO v_monto_ult_convenio , v_fecha_ult_convenio, v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa
	    AND numcliente = v_numcte ORDER BY fecha_compac DESC
            EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN

        FOREACH SELECT {+INDEX (bdicobranza:cb_compac_his idx_compachis1, idx_compachis2)}
                 FIRST 1 importe,TO_CHAR(fecha_compac,"%m%y"), flag_pago
	    INTO v_monto_ult_convenio , v_fecha_ult_convenio, v_est_cumpl_convenio
	    FROM bdicobranza:cb_compac_his
	    WHERE empresa = pempresa
	    AND numcliente = v_numcte ORDER BY fecha_compac DESC
    	EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
			LET v_monto_ult_convenio =  LPAD("0",5,'0');
		END IF;
    END IF;
		--------------------------------------------------------
    --13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)
    --------------------------------------------------------
    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
			LET v_fecha_ult_convenio =  "NDND";
	END IF;

    --------------------------------------------------------
    --14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)
    --------------------------------------------------------

    IF v_est_cumpl_convenio IS NULL OR v_est_cumpl_convenio = "" THEN
			LET v_est_cumpl_convenio =  "-";
    ELIF v_est_cumpl_convenio = '1' then
        LET v_est_cumpl_convenio = 'S';
    ELIF v_est_cumpl_convenio = '0' then
        LET v_est_cumpl_convenio = 'N';

    END IF;
    --------------------------------------------------------
    --15.-NUMERO DE AVISOS: (1 LETRA)
    --------------------------------------------------------	
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
	
	------ Convierte nÃºmero de producto para Carteras
	IF v_numprod = '6001' THEN 
		LET vTipProdCarterasTDC = '1';
	ELIF v_numprod = '6600' THEN
		LET vTipProdCarterasTDC = '2';
	ELIF v_numprod = '8100' THEN
		LET vTipProdCarterasTDC = '6';
	END IF;

----- Modifico para Clave de Cobranza ----- RQM 09 117

	LET posicion11= round(v_pago_minimo_tc - v_capital_tc);
	LET posicion11= lpad( trim(posicion11), 5,'0');

	--- Inicio (Inc. 20 Marzo 2009)
	LET v_monto_ult_convenio= round(v_monto_ult_convenio);
	LET v_monto_ult_convenio= lpad( trim(v_monto_ult_convenio), 5,'0');
	--- Fin

	IF LENGTH(TRIM(v_pago_minimo_tc::INTEGER::CHAR(10))) > 5 THEN
		LET posicion17 = 99999;
	ELSE
		LET posicion17 = round(v_pago_minimo_tc);
	END IF;

	LET posicion17= lpad(trim(posicion17), 5,'0');

    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
		
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = (DAY(v_fecha_limite_pago_tc))  ||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
      --LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;

	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;
                                                                                    -- ||"/"||v_pago_minimo_tc

    -- Define clave para tipo de cliente
    IF iMoras = 1 AND ( dFech_1erComp > dFHoy_1m AND dFech_alta >= dFHoy_13m ) THEN LET v_clave6 = '1V';
    ELIF ( dFech_1erComp > dFHoy_1m ) THEN LET v_clave6 = 'CN';
    ELIF ( dFhUltCompAct != dFhUltCompAnt AND dFhUltCompAnt <= dFHoy_12m AND v_deuda_Ant = 0 ) THEN LET v_clave6 = 'NC';
    ELSE LET v_clave6 = '-'; END IF;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5 || "/" || v_clave6;

    --------------------------------------------------------
    --EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA
    --------------------------------------------------------
	UPDATE sd_encabezado_edocta SET cl_cobra = trim(v_cl_cobranza)
	WHERE fecha_emision = pfechahoy
	AND	num_credito = pnum_credito;
	
	DROP TABLE IF EXISTS univer_credsol;

  RETURN cod_ret;
END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_actualizar_linea_credito_tc_inflacion(
    pEmpresa            CHAR(3),    -- Empresa.
	cNumCredito         CHAR(20),   -- Numero de credito.
	pNumEmpleado        CHAR(8),    -- Numero de empleado.
	pCanalRespuesta     CHAR(2),    -- Canal de aceptacion por donde acepto el incremento (APP(BANCOPPEL MOVIL EN LINEA) - 17, OFI - 1, SIWEB - 2, SMS - 9).
	vTokenConfirmacion  CHAR(942),  -- Huella del indice derecho dmapa.
	pNumCelular 		CHAR(10), 	-- Numero de celular del cliente.
	cNumTarjeta         CHAR(20),	-- Numero de tarjeta del cliente. 
	cNumCte 			CHAR(20),   -- Numero de cliente.
    cSucursal           CHAR(4)     -- Sucursal
)
RETURNING 
    CHAR(5) AS cCodRet;

-- Control de Cambios:
-----------------------------------------------------------------------------------------
-- Autor: LERS
-- Fecha: 14-08-2024
-- Descripcion: Actualiza la linea de credito del cliente tras la aceptacion del aumento por inflacion.
-- RQM: RQM 10 1647 Ajuste Linea de credito por inflacion anual.
-----------------------------------------------------------------------------------------
-- Autor: LERS
-- Fecha: 04/11/2025 
-- Descripcion: Validacion del regreso de respuesta del graba incremnto de inflacion.
-- RQM: RQM 10 1647 Ajuste Linea de credito por inflacion anual.

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE cCodRet				CHAR(5);            -- Codigo de retorno
DEFINE iSqlErr              INTEGER;            -- Indica el tipo de error que ocurrio.
DEFINE cNum_cliente         CHAR(20);           -- Numero de cliente
DEFINE vLineaActual 		DECIMAL(18,2);      -- Linea actual antes de la oferta.
DEFINE vPorcentajeInflacion DECIMAL(18,2);      -- Porcentaje de inflacion anual.
DEFINE vNuevaLineaCredito	DECIMAL(18,2);      -- Nueva linea de credito final del cliente al aceptar el incremento.
DEFINE vFechaHoy			DATE;               -- Fecha del dia de hoy.
DEFINE vFinVigencia         DATE;               -- Fecha fin de vigencia del incremento.
DEFINE iProducto            INTEGER;			-- Numero de producto.
DEFINE iMontoMax            INTEGER;			-- Monto Maximo del producto.
DEFINE iMontoMin            INTEGER;			-- Monto Minimo del producto.
DEFINE fecha_aceptacion		DATE;				-- Fecha de aceptacion.
DEFINE cCodRetGra        	CHAR(6);            -- Codigo de retorno del sp_grabarincrementolincred.
DEFINE MensGra				CHAR(80);	        -- Mensaje del sp_grabarincrementolincred.
--DEFINE vNumcte    			CHAR(20); 			-- Se usara para el numero del cliente cuando se acepte por SMS.
DEFINE cCodRetNot           CHAR(5);            -- Codigo de retorno del sp_envio_notificacion_exito.
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET cCodRet			        = "00000";          -- Codigo inicial indicando exito.
LET iSqlErr                 = 0;
LET cNum_cliente            = "";
LET vLineaActual            = 0;
LET vPorcentajeInflacion    = 0;
LET vNuevaLineaCredito      = 0;
LET vFechaHoy               = "";
LET vFinVigencia            = "";
LET iProducto          	    = 0;
LET iMontoMax          	    = 0;
LET iMontoMin          	    = 0;
LET fecha_aceptacion        = "";
LET cCodRetGra              = "";
LET MensGra					= "";
--LET vNumcte    				= ""; 
LET cCodRetNot              = "";

-- ****************************************************************************
-- *                        VALIDACION DE ENTRADAS                            *
-- ****************************************************************************
-- Validar entradas obligatorias.
IF  pEmpresa        IS NULL OR pEmpresa         = " " OR
    pCanalRespuesta IS NULL OR pCanalRespuesta  = " "  THEN

    LET cCodRet = "00001"; -- Codigo de error por datos de entrada invalidos.
    RETURN cCodRet;
END IF;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
	ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
	END EXCEPTION;

    --SET DEBUG FILE TO "sp_actualizar_linea_credito_tc_inflacion.out";
    --TRACE ON;

	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	


    -- Obtiene la fecha del dia 
    SELECT fecha_hoy
        INTO vFechaHoy
        FROM bdicred:"informix".sd_fechas
        WHERE empresa = pEmpresa;

	--Si acepta por SMS se busca por el numero de celular.
	IF pCanalRespuesta = '9' THEN
	    IF NVL(cNumCte,'') = '' THEN 
			SELECT numcte
                INTO cNumCte
                FROM bdinteg:"informix".si_telefonos_actual
                WHERE telefono = pNumCelular
                AND tipo_tel = 2
                AND status_tel = 'A';
		END IF;
        
        SELECT FIRST 1 num_credito 
            INTO cNumCredito
            FROM bdicred:"informix".sd_bitacora_incremento_inflacion
            WHERE num_cliente  = cNumCte
			AND confirma_incremento <> "1" 
			AND fin_vigencia >= vFechaHoy;
	END IF;

	-- Si el numero de credito viene vacio, se busca el cliente por el numero de tarjeta.
	IF NVL(cNumCredito,'') = '' THEN 
        SELECT num_credito
            INTO cNumCredito
            FROM bdicred:"informix".sd_tarjeta
            WHERE num_tarjeta = cNumTarjeta ;
	END IF;

    -- LERS 31/072025 - Valida que si el numero de credito sigue nulo o vacio termine la ejecucion
    IF NVL(cNumCredito,'') = '' THEN
        LET cCodRet = "00005"; -- Credito no identificado o encontrado.
        RETURN cCodRet;
    END IF;

    -- Si sucursal viene vacia se busca en la sd_maecred
    IF NVL(cSucursal,'') = '' THEN
        SELECT sucursal
            INTO cSucursal 
            FROM bdicred:"informix".sd_maecred 
            WHERE num_credito = cNumCredito;
    END IF;


    -- Obtiene la fecha de fin de vigencia
    SELECT fin_vigencia, num_producto, num_cliente  
        INTO vFinVigencia, iProducto, cNum_cliente
        FROM bdicred:"informix".sd_bitacora_incremento_inflacion
        WHERE num_credito = cNumCredito AND confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

    -- Obtiene la linea de credito actual
    SELECT  monto_otorgado 
        INTO  vLineaActual
        FROM bdicred:"informix".sd_maesdos
        WHERE num_credito = cNumCredito;
    -- LERS 31/072025 - Validacion si el monto es 0, nulo 
        IF vLineaActual = 0 OR  vLineaActual IS NULL THEN 
            LET cCodRet = "00006"; -- Credito no valido en sd_maesdos o no existe.
            RETURN cCodRet;
        END IF;

    -- Obtener el porcentaje de inflacion
    SELECT porcentaje_inflacion 
        INTO vPorcentajeInflacion
        FROM bdicred:"informix".sd_carga_inflacion_tc  
        WHERE num_producto = iProducto;
        -- LERS 31/072025 - Validacion si el porcentaje de inflacion nulo 
        IF vPorcentajeInflacion IS NULL THEN 
            LET cCodRet = "00007"; -- Porcentaje de inflacion no encontrado para el producto.
            RETURN cCodRet;
        END IF;
    
    -- LERS 31/072025 - Obtener el monto maximo y minimo permitido.
    SELECT linea_credito_maxima,linea_credito_minima
        INTO iMontoMax,iMontoMin
        FROM bdicred:"informix".sd_param_incremento_inf_tc
        WHERE producto = iProducto;	
        -- LERS 31/072025 - Valida monto maximo y minimo permitido es 0  o nulo 
        IF (iMontoMax = 0 OR iMontoMin = 0) OR (iMontoMax IS NULL OR iMontoMin IS NULL) THEN 
            LET cCodRet = "00008"; -- Limites de credito maximo o mÃ­nimo no encontrados para el producto.
            RETURN cCodRet;
        END IF;

    -- LERS 31/072025 - Valida que la linea de credito no sea por debajo del minimo para incremnto
    IF vLineaActual < iMontoMin THEN
        LET cCodRet = "00004"; -- Linea de credito por debajo del limite minimo para incremento
        RETURN cCodRet;
    END IF;

    -- LERS 04/11/2025 - Validar que la fecha de hoy este dentro de las fechas de vigencia o nulo como vacio el pararametro de vigencia.
        IF vFechaHoy > vFinVigencia  OR vFinVigencia IS NULL OR vFinVigencia = ''THEN
            LET cCodRet = "00002"; -- Codigo de error por vigencia expirada.
            RETURN cCodRet;
        END IF;

    -- Calculo de la nueva linea de credito con redondeo a 2 cifras
    LET vNuevaLineaCredito = ROUND(vLineaActual + (vLineaActual * (vPorcentajeInflacion / 100)), -2);

    IF vNuevaLineaCredito >= iMontoMax THEN
		LET vNuevaLineaCredito = iMontoMax;
	END IF;
    -- SECP 31/072025 - Se toma la nueva linea de credito
	UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
        SET 
            linea_oferta = vNuevaLineaCredito,
            linea_actual = vLineaActual, 
            bandera_aceptacion_rechazo = '1',
            canal_aceptacion = pCanalRespuesta,
            nueva_linea_credito = vNuevaLineaCredito,
            fecha_aceptacion_oferta = vFechaHoy,
            empleado_aplica_incremento = pNumEmpleado,
            sucursal = cSucursal
        WHERE num_credito = cNumCredito AND confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

	-- SECP 31/072025 - llamado a la ejecucion de sp_grabarincrementolincredinf
    EXECUTE PROCEDURE bdicred:"informix".sp_grabarincrementolincredinf("001",cNumCredito) INTO cCodRetGra, MensGra; 

	-- Insertar en la tabla bdicred:sd_canales_aceptacion_incrementos
    IF cCodRetGra = "00000" THEN
		LET fecha_aceptacion = vFechaHoy;
		INSERT INTO bdicred:"informix".sd_canales_aceptacion_incrementos (num_cliente,num_credito,canal_aceptacion,token_confirmacion,fecha_aceptacion)
            VALUES (cNum_cliente,cNumCredito,pCanalRespuesta,vTokenConfirmacion,fecha_aceptacion);	
	ELSE 
        LET cCodRet = '00003'; -- Error al grabar el incremento por inflacion
        -- SECP 04/11/2025 - Regresa el incremneto activo en fallo del grabar el incremnto.
        UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
        SET 
            bandera_aceptacion_rechazo = '0',
            canal_aceptacion = '',
            fecha_aceptacion_oferta = DATE(1),
            empleado_aplica_incremento = ''
        WHERE num_credito = cNumCredito AND confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;
        RETURN cCodRet;
	END IF;
	
	-- Actualizacion en la tabla bdicred:sd_bitacora_incremento_inflacion
    UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
        SET formato_firmado = '1',
            nueva_linea_credito = vNuevaLineaCredito,
            fecha_aplicacion = vFechaHoy,
            fin_vigencia = vFechaHoy,
            confirma_incremento = '1'
        WHERE num_credito = cNumCredito AND confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

    UPDATE bdicred:"informix".sd_certificar_reglas_negocio
        SET linea_actual = vLineaActual,
        formato_firmado = '1',
        nueva_linea_credito = vNuevaLineaCredito,
        fecha_aplicacion = vFechaHoy,
        fin_vigencia = vFechaHoy,
        confirma_incremento = '1',
        flag_incremento = '1',
        flag_aceptacion_rechazo = '1',
        canal_aceptacion = pCanalRespuesta,
        fecha_aceptacion_oferta = vFechaHoy,
        empleado_aplica_incremento = pNumEmpleado
        WHERE num_credito = cNumCredito AND confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

    EXECUTE PROCEDURE bdicred:"informix".sp_envio_notificacion_exito('001',cNumCredito) INTO cCodRetNot;
    RETURN cCodRet;
END
END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Actualiza la linea de credito del cliente tras la aceptacion del aumento por inflacion',
'Modifico    : LERS',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega la linea actual del credito en la tabla bitacora y certificar',
'Modifico    : LERS',
'Fecha       : 02/01/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agrego validacion de la linea de credito no sea por debajo del minimo para incremento',
'Modifico    : LERS',
'Fecha       : 07/31/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Se agrega la validacion en el fallo del graba de incremento por inflacion',
'Modifico    : SECP/LERS',
'Fecha       : 04/11/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consulta_incremento_linea_tc(
	cNumCredito CHAR(20),	-- Numero de credito.
	cNumTarjeta CHAR(20), 	-- Numero de tarjeta.
	cCanal CHAR(2)			-- Canal de aceptacion del incremento.
)
RETURNING  
	CHAR(5) 		AS cCodRet, 
	CHAR(1)			AS cIncrementoActivo, 
	DECIMAL(18,2)	AS cLineaCredito, 
	CHAR(10)		AS cFinVigencia, 
	CHAR(20)		AS cNumCte, 
	CHAR(20)		AS cNumCredito;

-- CONTROL DE CAMBIOS:
---------------------------------------------------------------------------------
-- Autor: Miguel Angel Felix Lopez.
-- Modificacion: Tiene como objetivo consultar  la informacion  del incremento linea de credito para notificar el aumento.
-- Fecha de Modificacion: 13-08-2024.
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- Autor: LERS 
-- Modificacion: Se agragan validaciones para la linea actual
-- Fecha de Modificacion: 31/07/2025
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- Autor: LERS 
-- Modificacion: Se modifica la longitud del tipo de dato a char(2) para el campo cCanal
-- Fecha de Modificacion: 04/11/2025
-- Peticion: RQM 10 1647 â Incremento  linea de credito TDC por inflacion.
---------------------------------------------------------------------------------
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************	
DEFINE cCodRet								CHAR(5);
DEFINE cIncrementoActivo 					CHAR(1);        	-- Bandera para saber si el cliente cuenta con un incremento por inflacion pendiente de aceptar.    
DEFINE cLineaCredito 						DECIMAL (18,2);	    -- Linea de credito final a retornar.
DEFINE cLinea_actual 						DECIMAL (18,2);     -- Linea de credito actual sin aumento por inflacion.
DEFINE cLinea_sugerida 						DECIMAL (18,2);     -- Linea de credito ya con el aumento por inflacion.
DEFINE cPorcentajeInflacion 				DECIMAL(18,2);      -- Porcentaje de inflacion anual.
DEFINE vFechaHoy							DATE;               -- Fecha del dia. 
DEFINE vFecha_Limite						DATE;           	-- Fecha limite para aceptar el incremento por inflacion.
DEFINE vsqlerr 								INTEGER;
DEFINE cNum_producto 						CHAR(20);
DEFINE cLinea_maxima  						DECIMAL(18,2);
DEFINE cLinea_minima  						DECIMAL(18,2);
DEFINE cConfirma_incremento 				CHAR(1);
DEFINE cNumCte								CHAR(20);
DEFINE dFecha_ultimo_ofertamiento_sucursal 	DATE;
DEFINE cCodretConBue 						CHAR(5);
DEFINE cMensaje 							CHAR(80); 
DEFINE cIsCtePros 							CHAR(1);
DEFINE c_num_cte 							CHAR(20); 
DEFINE cNombre 								CHAR(120);
DEFINE cRFC 								CHAR(13);
DEFINE dtFechaSol 							DATE;
DEFINE dtFechaAut 							DATE; 
DEFINE dLinCredAct 							DECIMAL(18,2);
DEFINE dLinCredCal 							DECIMAL (18,2);
DEFINE cOrigen 								CHAR(1);
DEFINE cStatus 								CHAR(2);
DEFINE cDescStatus 							CHAR(40);
DEFINE cComentario 							CHAR(80);
DEFINE cNumSol 								CHAR(20);
DEFINE cFinVigencia 						CHAR(10);
DEFINE cDia_fin_vigencia 					CHAR(2);
DEFINE cMes_fin_vigencia 					CHAR(2);
DEFINE cAnio_fin_vigencia 					CHAR(4);
DEFINE vExiste 								INTEGER;


-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************

LET cCodRet 								= "00000";
LET cIncrementoActivo 						= "0";
LET cLineaCredito 							= 0;
LET cLinea_actual 							= 0;
LET cLinea_sugerida 						= 0;
LET cPorcentajeInflacion 					= 0; 
LET vFechaHoy 								= '';
LET vFecha_Limite 							= '';
LET cNum_producto 							= "0";
LET cLinea_maxima 							= 0;
LET cLinea_minima 							= 0;
LET cConfirma_incremento 					= "";
LET cNumCte 								= '';
LET dFecha_ultimo_ofertamiento_sucursal		= '';
LET cCodretConBue 							= "";
LET cMensaje 								= "";
LET cIsCtePros 								= "";
LET c_num_cte 								= ""; 
LET cNombre 								= "";
LET cRFC 									= "";
LET dtFechaSol 								= '';
LET dtFechaAut 								= ''; 
LET dLinCredAct 							= 0;
LET dLinCredCal 							= 0;
LET cOrigen 								= '';
LET cStatus 								= '';
LET cDescStatus 							= '';
LET cComentario 							= '';
LET cNumSol 								= '';
LET cFinVigencia 							= ''; 
LET cDia_fin_vigencia 						= '';
LET cMes_fin_vigencia 						= '';
LET cAnio_fin_vigencia 						= '';
LET vExiste 								= 0;



-- SET DEBUG FILE TO '/home/TRACE/Consulta/'||TRIM(cNumCredito)||'.out'; 
-- TRACE ON;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
	ON EXCEPTION SET vsqlerr       		 
		IF vsqlerr != 0 THEN
			LET cCodRet = vsqlerr;
			RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	-- **********************************************************************
    -- *                        PROGRAMA PRINCIPAL
    -- **********************************************************************

	-- Si el nuemero de credito y nuemero de tarjeta viene vacio.
	IF NVL(cNumCredito, '') = '' AND  NVL(cNumTarjeta, '') = '' THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
	END IF;

	-- Si el numero de credito viene vacio, se busca el cliente por el numero de tarjeta.
	IF NVL(cNumCredito,'') = '' THEN 
		SELECT num_credito 
			INTO cNumCredito
			FROM bdicred:"informix".sd_tarjeta
			WHERE num_tarjeta = cNumTarjeta;
		-- LERS 31/072025 - Se valida si el numero de credito no se encontro con el numero de tarjeta
		IF cNumCredito IS NULL OR cNumCredito = '' THEN
            LET cCodRet = '00009'; -- Numero de credito no encontrado por tarjeta
            LET cIncrementoActivo = '0';
            RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;
	END IF;

	-- Obtiene la fecha del dia. 
    SELECT fecha_hoy
		INTO vFechaHoy
		FROM bdicred:"informix".sd_fechas;

	-- Obtiene el monto otorgado del cliente
	SELECT monto_otorgado  	
		INTO cLinea_actual  --Linea actual del cliente sin el aumento por inflacion.
		FROM bdicred:"informix".sd_maesdos
		WHERE num_credito = cNumCredito;

    -- LERS 31/072025 - Validacion para no activar el incremento si la linea actual es NULL O cero
	IF cLinea_actual IS NULL OR cLinea_actual = 0 THEN
        LET cCodRet = '00006'; -- linea actual es nula o cero, no activa elincremento
        LET cIncrementoActivo = '0';
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;
	-- Obtiene la informacion del cliente, validando que la linea de credito este vigente.
	SELECT num_cliente, nueva_linea_credito, fin_vigencia,  fecha_ultimo_ofertamiento_sucursal, porcentaje_de_inflacion    
		INTO cNumCte, cLinea_sugerida, vFecha_Limite, dFecha_ultimo_ofertamiento_sucursal, cPorcentajeInflacion      --Linea del cliente ya con el aumento por inflacion.
		FROM bdicred:"informix".sd_bitacora_incremento_inflacion
		WHERE num_credito = cNumCredito
		AND Confirma_incremento <> "1" 
		AND fin_vigencia >= vFechaHoy;

	-- LERS 04/11/2025 - Se valida que se haya encontrado un registro con un incremento activo.
	IF cNumCte IS NULL OR cNumCte = '' THEN
        LET cCodRet = "00003"; -- No se encontro un incremento activo para el credito.
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;

	-- Obtiene el numero de producto asociado al credito.
	SELECT num_producto
		INTO cNum_producto
		FROM bdicred:"informix".sd_maecred
		WHERE num_credito = cNumCredito;
	-- LERS 04/11/2025 - Se valida el numero de producto nulo o vacio, asociado al credito.
	IF cNum_producto IS NULL OR cNum_producto = '' THEN
        LET cCodRet = '00002'; -- producto no encontrado no identificado o encontrado.
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;

	-- Obtiene el limite de credito maximo y minima asociado a un producto.
	SELECT linea_credito_maxima,linea_credito_minima
		INTO cLinea_maxima,cLinea_minima
		FROM bdicred:"informix".sd_param_incremento_inf_tc
		WHERE producto = cNum_producto;
		-- LERS 31/072025 - Valida monto maximo y minimo permitido es 0  o nulo 
        IF (cLinea_maxima = 0 OR cLinea_minima = 0) OR (cLinea_maxima IS NULL OR cLinea_minima IS NULL) THEN 
            LET cCodRet = "00007"; -- Limites de credito maximo o minimo no encontrados para el producto.
            RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;

	-- LERS 31/072025 - Valida que la linea de credito no sea por debajo del minimo para incremnto
    IF cLinea_actual < cLinea_minima THEN
        LET cCodRet = "00008"; -- Linea de credito por debajo del limite minimo para incremento
        RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
    END IF;
	--Se valida si el credito esta en la bitacora de candidatos a incrementos por inflacion y no haya aceptado exitosamente el incremento con anterioridad.
	SELECT COUNT(num_credito) 
		INTO vExiste 
		FROM bdicred:"informix".sd_bitacora_incremento_inflacion
		WHERE num_credito = cNumCredito 
		AND Confirma_incremento <> "1"
		AND fin_vigencia >= vFechaHoy; 
	
	IF vExiste = 1 THEN
		--Verifica que no tenga un aumento por buen comportamiento pendiente
		EXECUTE PROCEDURE bdicred:"informix".sp_consultarctesincrementolincred_web("001",cNumCte,"","","1","",0,0) 
			INTO cCodretConBue, cMensaje, cIsCtePros, c_num_cte, cNombre, cRFC, dtFechaSol, dtFechaAut, dLinCredAct, dLinCredCal, cOrigen, cStatus, cDescStatus, cComentario, cNumSol;

		--Si tiene un aumento por buen comportamiento pendiente regresa como falso el incremento por inflacion
        IF cCodretConBue = "00000" THEN
			LET cCodRet  = '00004'; 
			RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
        END IF;

		-- Verifica que no se muestre mas de una vez al dia el pop up, si el canal viene vacio significa que se esta ejecutando desde el SP sp_envio_sms_inc_tc.
		IF cCanal = '1' THEN 
			IF vFechaHoy <= dFecha_ultimo_ofertamiento_sucursal THEN
				LET cCodRet  = '00005'; 
				RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;
			END IF;
		END IF;

		LET cIncrementoActivo = "1";

		IF cLinea_actual > cLinea_sugerida THEN -- Si la linea actual es mayor se hace vuelve a calcular la linea con el aumento por inflacion.
			-- Calculo de la nueva linea de credito con redondeo a 2 cifras.		
			LET cLineaCredito = ROUND(cLinea_actual + (cLinea_actual * (cPorcentajeInflacion / 100)),-2);

			-- Revisar que no pase el tope limite permitido por producto.
			IF cLineaCredito >  cLinea_maxima THEN
				LET cLineaCredito = cLinea_maxima;
			END IF;

			-- Se actualiza la nueva linea de credito en la bitacora.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
				SET nueva_linea_credito = cLineaCredito,
					linea_oferta = cLineaCredito
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
			
		ELSE 		
			LET cLineaCredito = cLinea_sugerida;
		END IF;

		IF  cCanal = '1' THEN 
			-- Actualiza La fecha de ofertamiento en la bitacora cuando venga por algun canal diferente a vacio.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion 
				SET fecha_ultimo_ofertamiento_sucursal = vFechaHoy
				WHERE num_credito = cNumCredito 
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
		END IF;
		
		-- Se actualiza el canal por el cual se le notifica al cliente el aumento.
			UPDATE bdicred:"informix".sd_bitacora_incremento_inflacion
				SET canal_notificacion_cliente = cCanal
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy;
				
		    UPDATE bdicred:"informix".sd_certificar_reglas_negocio
				SET canal_notificacion_cliente = cCanal
				WHERE num_credito = cNumCredito
				AND Confirma_incremento <> "1"
				AND fin_vigencia >= vFechaHoy; 
			--Se regresa la fecha en formato DIA/MES/ANIO para usarse en el pop up
			LET cDia_fin_vigencia  = DAY(vFecha_Limite);
			LET cMes_fin_vigencia  = MONTH(vFecha_Limite);
	
			IF cDia_fin_vigencia < 10 THEN
				LET cDia_fin_vigencia = "0" || cDia_fin_vigencia;
        	END IF;

			IF cMes_fin_vigencia < 10 THEN
				LET cMes_fin_vigencia = "0" || cMes_fin_vigencia ;
        	END IF;
			LET cAnio_fin_vigencia = YEAR(vFecha_Limite);
			LET cFinVigencia = TRIM(cDia_fin_vigencia)||'/'||TRIM(cMes_fin_vigencia)||'/'||TRIM(cAnio_fin_vigencia);

	END IF;

	RETURN cCodRet, cIncrementoActivo, cLineaCredito, cFinVigencia, cNumCte, cNumCredito;

END


END PROCEDURE
DOCUMENT 
'----------------------------------------------------------------------------',
'Descripcion : Tiene como objetivo consultar  la informacion  del incremento linea de credito para notificar el aumento.',
'Modifico    : MAFL',
'Fecha       : 07/10/2024',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Validacion de la linea de credito actual',
'Modifico    : LERS',
'Fecha       : 07/31/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------',
'Descripcion : Cambio de longitud del campo cCanal, valicacion 00002 y 00003',
'Modifico    : LERS',
'Fecha       : 04/11/2025',
'BD          : BDICRED',
'----------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_actvig_camp() 
RETURNING CHAR(6),CHAR(55);

DEFINE iSqlErr			INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       VARCHAR(80);
DEFINE cCodRet 			CHAR(6);
DEFINE cmensaje 		CHAR(55);
DEFINE cRuta 			CHAR (50);
DEFINE cnom_archivo		CHAR(30);
DEFINE cBitacoraCamp	CHAR (50);
DEFINE cBitacCampSms	CHAR (50);
DEFINE cBitacCampApp    CHAR (50);
DEFINE cCadena  		CHAR (500);
DEFINE siPromo 			varchar(5);
DEFINE dtIni_Vig 		DATE;
DEFINE dtFin_Vig 		DATE;
DEFINE dtIni_Vig_min 	DATE; 
DEFINE dtIni_Vig_max 	DATE;
DEFINE siPlazo 			varchar(5);
DEFINE siTasa 			decimal(10,2);
DEFINE wBegin           CHAR(1);
DEFINE cArchivo_dbld    CHAR(50);
DEFINE cArchivo_log     CHAR(50);
DEFINE cfec_arch		CHAR(8);
DEFINE dt_fec_carga 	DATE;
DEFINE sContador		SMALLINT;
DEFINE sContadorAux		SMALLINT;
DEFINE sContadorAux2	SMALLINT;
DEFINE sTasasSms		SMALLINT;
DEFINE sTasasApp		SMALLINT;
DEFINE iMonto_Ini		DECIMAL(10,2);
DEFINE iMonto_Fin 		DECIMAL(10,2);
DEFINE cMontos			CHAR(21);
--Agregar nuevos campos del Requerimiento 10 1365
DEFINE iCodigo		SMALLINT;
DEFINE cOrigen 		CHAR(10);
DEFINE cContadorAux3		SMALLINT;
DEFINE dtInicio		DATE;
DEFINE dtFin		DATE;
DEFINE cCampana		SMALLINT;
DEFINE cnombre		CHAR(100);
DEFINE cnomarchivo	CHAR(100);
DEFINE cnomarchivol	CHAR(100);
DEFINE cnomarchivoEjecSql	CHAR(100);
DEFINE cSQL			CHAR(2204);
DEFINE cSQL1		CHAR(200);
DEFINE cSQL2		CHAR(2004);
DEFINE cSQL3		CHAR(100);
DEFINE cRuta2		CHAR(100);
DEFINE cFechaGenArchivo		CHAR(8);
DEFINE cProceso		CHAR(4);
DEFINE cFechaCorte	DATE;
DEFINE bValidaArchivo		CHAR(1);

DEFINE iNumProducto CHAR(5);
DEFINE dIdentificador CHAR(6);
DEFINE iEmpresa CHAR(3);

LET iSqlErr 		= 0;
LET cCodRet 		= '000000';
LET cmensaje 		= '';
LET cCadena 		= '';
LET cRuta 			= '';
LET cnom_archivo	= '';
LET cBitacoraCamp	= '';
LET cBitacCampSms   = '';
LET cBitacCampApp   = '';
LET siPromo 		= 0;
LET dtIni_Vig 		= '';
LET dtFin_Vig 		= '';
LET siPlazo 		= 0;
LET siTasa 			= 0;
LET wBegin 			= '';
LET cfec_arch		= '';
LET sContador		= 0;
LET sContadorAux	= 0;
LET sContadorAux2	= 0;
LET sTasasSms		= 0;
LET sTasasApp		= 0;
LET cMontos			= '';
LET iMonto_Ini 		= 0;
LET iMonto_Fin		= 0;
LET cArchivo_dbld   = "f_actvig_prosp.com";
LET cArchivo_log    = "f_actvig_prosp.log";
--Agregar nuevos campos del Requerimiento 10 1365
LET iCodigo = 0;
LET cContadorAux3 = 0;
LET dtInicio = '';
LET cOrigen = '';
LET dtFin = '';
LET cCampana = 0;
LET cnombre			= "PagosFijos_Con_";
LET cnomarchivo		= "";
LET cnomarchivol	= "";
LET cnomarchivoEjecSql	= "";
LET cSQL			= "";
LET cSQL1			= "";
LET cSQL2			= "";
LET cSQL3			= "";
LET cRuta2			= "/resplogifx/archivoscredito/";

--LET cProceso		= "";
LET bValidaArchivo		= 'N';
LET iNumProducto = "";
LET dIdentificador = "";
LET iEmpresa = '001';

BEGIN

	ON EXCEPTION
		SET iSqlErr, isam_err, error_info
		
		IF bValidaArchivo = 'N' THEN
			LET cCodRet = '000000';
			LET cmensaje = 'No se encuentra el archivo de vigencias de campanas';
			
			RETURN cCodRet,cmensaje;
		END IF;
		
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cmensaje = error_info;
		END IF;
		RETURN cCodRet,cmensaje;
	END EXCEPTION;
   	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   

	--SET DEBUG FILE TO 'sp_actvig_camp.out';
	--TRACE ON;
	
	SELECT year(fecha_hoy)||lpad(month(fecha_hoy),2,0)||lpad(day(fecha_hoy),2,0),fecha_hoy
	  INTO cfec_arch,dt_fec_carga
	  FROM bdicred:sd_fechas;
	
    LET cnom_archivo = "actvig_prospectos_"||cfec_arch||'.txt';
    LET cBitacoraCamp = "bitacora_actvig_prospectos_"||cfec_arch||'.txt';
	LET cBitacCampSms = "bitacora_actvig_prospectos_sms_"||cfec_arch||'.txt';
	LET cBitacCampApp = "bitacora_actvig_prospectos_app_"||cfec_arch||'.txt';

    LET cRuta = "/resplogifx/archivoscredito/";   
		
	--Se valida que el archivo exista en la carpeta
	system ' cat ' || TRIM(cRuta) || cnom_archivo;
	
	LET bValidaArchivo = 'S'; --Si existe el archivo se modifica la bandera

	--DROP TABLE IF EXISTS "informix".sd_actvig_camp;
    DROP TABLE IF EXISTS "informix".tmp_sd_actvig_camp;	
	CREATE TABLE tmp_sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21),
		tipo_compra char(1),
		identificador char(6),
		giro		char(2),
		tipo		char(10),
		bloqueo		char(1),
		desbloqueo  char(3),
		carga		char(1),
		prioridad	char(1)
	);
		
   system ' echo "FILE ' ||  TRIM(cRuta) ||  TRIM(cnom_archivo) ||' DELIMITER '|| "'" || '|' || "'" || ' 15; ' || '">' || TRIM(cRuta) || TRIM(cArchivo_dbld);  
   system ' echo "INSERT INTO tmp_sd_actvig_camp;' || '">>' || TRIM(cRuta) || TRIM(cArchivo_dbld);
   system ' chmod 777 ' || TRIM(cRuta) || TRIM(cArchivo_dbld);

	 --system ' echo "date ' || '">' || TRIM(cRuta) || 'dbload_actvig_prosp.sh';
	 --system ' echo "dbload -d bdicred -c ' || TRIM(cRuta) || TRIM(cArchivo_dbld)  ||' -l ' || TRIM(cRuta) || TRIM(cArchivo_log) || ' -n 1000 ' || ' " >> ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh'; 
	 --system ' echo "date ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	 --system ' echo "dbaccess bdicred -<<EOF ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';             
	 --system ' echo "set pdqpriority 0;' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';          
	 --system ' echo "update statistics medium for table sd_actvig_camp; ' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system ' echo "EOF' || '">>' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';           
	 --system 'chmod 777 ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	--system 'chmod 777 /usr/bin/sh ';
	system '/usr/bin/sh ' || TRIM(cRuta)|| 'dbload_actvig_prosp.sh';
	
	create index inx1_activ_camp_tmp on tmp_sd_actvig_camp(origen);
	 
	--Se agrega campo para saber si una campaÃ±a fue cargada o no
	alter table tmp_sd_actvig_camp add cargado char(1);
	
	-- Valida que esten correctamente escritas las palabras: sucursal y sms
	LET sContador = 0;
	UPDATE tmp_sd_actvig_camp SET origen = lower(origen);
	-- CAMBIO AGREGAR APP 12-05-25
	SELECT COUNT(camp) INTO sContador FROM tmp_sd_actvig_camp WHERE origen != "sucursal" AND origen != "sms" AND origen != "app";
	IF sContador > 0 THEN
		LET cCodRet = '000003';
		LET cmensaje = 'Banderas de origen (sucursal, sms o app) son incorrectas.';
		RETURN cCodRet,cmensaje;
	END IF;
	
		-- Validar que el plazo no sea repetido
	LET sContador = 0;
	FOREACH
		SELECT origen, camp, plazo, COUNT(plazo) INTO cOrigen, cCampana, siPlazo, sContador FROM tmp_sd_actvig_camp WHERE origen IN ("sms", "app") GROUP BY origen, camp, plazo
		IF sContador > 1 THEN
			LET cCodRet = '000007';
			LET cmensaje = 'Existe un plazo duplicado [' || siPlazo || '] de la camp [' || cCampana || '] del origen [' || TRIM(cOrigen) || '].';
			RETURN cCodRet, cmensaje;
		END IF;
	END FOREACH;
	
	--Valida que las fechas no se traslapen
	FOREACH
		select distinct(camp) into cCampana from tmp_sd_actvig_camp
		FOREACH
			select rowid, camp, f_ini_vig, f_fin_vig, plazo, tasa, origen into iCodigo, cCampana, dtInicio, dtFin, siPlazo, siTasa, cOrigen  from tmp_sd_actvig_camp where camp = cCampana

			if(dtInicio >= dtFin) THEN
				LET cCodRet = '000006';
				LET cmensaje = 'La fecha fin vigencia debe ser mayor que fecha inicio';
				RETURN cCodRet,cmensaje;
			else
				select count(camp) into cContadorAux3 from tmp_sd_actvig_camp where dtInicio >= f_ini_vig and dtInicio < f_fin_vig and camp = cCampana and plazo = siPlazo and tasa = siTasa and origen = cOrigen and cargado = 1;

				if(cContadorAux3 > 0 ) THEN
					update tmp_sd_actvig_camp set cargado = '0' where camp = cCampana and f_ini_vig = dtInicio and f_fin_vig = dtFin and plazo = siPlazo and tasa = siTasa and origen = cOrigen and rowid = iCodigo;
				else
					update tmp_sd_actvig_camp set cargado = '1' where camp = cCampana and f_ini_vig = dtInicio and f_fin_vig = dtFin and plazo = siPlazo and tasa = siTasa and origen = cOrigen and rowid = iCodigo;
				end if;
			end if;
		END FOREACH;
	END FOREACH;
	
	--Pasar campaÃ±as con el campo cargado en 1
	DROP TABLE IF EXISTS "informix".sd_actvig_camp;
	CREATE TABLE sd_actvig_camp (
		camp 		varchar(3),
		f_ini_vig	date,
		f_fin_vig	date,
		plazo	 	varchar(5),
		tasa  		decimal(10,2),
		origen 		char(10),
		montos		char(21),
		tipo_compra char(1),
		identificador char(6),
		giro		char(2),
		tipo		char(10),
		bloqueo		char(1),
		desbloqueo  char(3),
		carga		char(1),
		prioridad	char(1)
	);
	
	insert into sd_actvig_camp (camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad)
	select camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad from tmp_sd_actvig_camp where cargado = "1";
	
	create index inx1_activ_camp on sd_actvig_camp(origen);
	
	-- Valida que los registros marcados como sms no superen los 4 por plazo.
	DROP TABLE IF EXISTS "informix".tmp_plazsms;
	SELECT camp, count(camp) total_p FROM bdicred:sd_actvig_camp WHERE origen = "sms" GROUP BY camp INTO temp tmp_plazsms WITH NO LOG;
	LET sContador = 0;
    SELECT MAX(total_p) INTO sContador FROM tmp_plazsms;

	IF sContador > 4 THEN	-- Maximo 4 plazos por campania.
		LET cCodRet = '000004';
		LET cmensaje = 'Numero de plazos para SMS No debe de ser mayor a 4.';
		RETURN cCodRet,cmensaje;
	END IF;

	
	-- Indentifica si existen registros para SMS Y valida los montos asignados.
	SELECT COUNT(camp) INTO sTasasSms FROM bdicred:sd_actvig_camp WHERE origen = "sms";
	IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'sms'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una coma. Solo se permite el separador guion. 			
			IF sContador <= 0 OR sContadorAux > 0 OR sContadorAux2 > 0 THEN	
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
			-- Valida que solo pueda enviarse una estructura de '500-600' si tiene otro caracter se rechaza.
			IF bdinteg:val_num(SUBSTR(cMontos, 1, (sContador - 1))) = 'f' OR bdinteg:val_num(SUBSTR (cMontos, (sContador + 1), length(cMontos))) = 'f' THEN
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos.';
				EXIT FOREACH;
			END IF;
			
		END FOREACH;
	END IF;
	
	
	-- Identificar si existe informacion correcta desde app para cargar y valida montos.
	SELECT COUNT(camp) INTO sTasasApp FROM bdicred:sd_actvig_camp WHERE origen = "app";
	IF sTasasApp > 0 THEN 	-- Existe informacion de app a cargar
	
		FOREACH WITH HOLD
		 SELECT montos INTO cMontos FROM sd_actvig_camp WHERE origen = 'app'
		
			LET sContador = CHARINDEX('-',cMontos);
			LET sContadorAux = CHARINDEX('.',cMontos);
			LET sContadorAux2 = CHARINDEX(',',cMontos);

			-- Si: NO existe el guion '-', existe un punto, o existe una coma. Solo se permite el separador guion. 			
			IF sContador <= 0 OR sContadorAux > 0 OR sContadorAux2 > 0 THEN	
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos. Formato correcto: ''500-600''. Solo se permite el separador guion.';
				EXIT FOREACH;
			END IF;
			
			-- Valida que solo pueda enviarse una estructura de '500-600' si tiene otro caracter se rechaza.
			IF bdinteg:val_num(SUBSTR(cMontos, 1, (sContador - 1))) = 'f' OR bdinteg:val_num(SUBSTR (cMontos, (sContador + 1), length(cMontos))) = 'f' THEN
				LET cCodRet = '000005';
				LET cmensaje = 'Rango de montos incorrectos. Formato correcto: ''500-600''.';
				EXIT FOREACH;
			END IF;
			
		END FOREACH;
	END IF;

	IF cCodRet = '000000' THEN 

		-- Actualiza tasas para pagos fijos sucursales.
		FOREACH WITH HOLD
		   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa   --cast(tasa as decimal(18,2))
			 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa
			 FROM sd_actvig_camp WHERE origen = 'sucursal'

			BEGIN;
				UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
				UPDATE "informix".sd_tasa_plazo SET tasa = siTasa WHERE num_promo = siPromo and plazo = siPlazo;
			COMMIT;
		END FOREACH;
		
		
		-- Genera informacion de plazos y tasas para SMS
		IF sTasasSms > 0 THEN 	-- Existe informacion de sms a cargar
			BEGIN;
				TRUNCATE TABLE bdicred:sd_tasa_plazo_sms;
			COMMIT;
			
			LET cMontos = '';
			FOREACH WITH HOLD
			   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa,   montos   --cast(tasa as decimal(18,2))
				 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa, cMontos
				 FROM sd_actvig_camp WHERE origen = 'sms'
				 
				 
				LET sContador = CHARINDEX('-',cMontos);
				LET iMonto_Ini = SUBSTR(cMontos, 1, (sContador - 1));
				LET iMonto_Fin = SUBSTR (cMontos, (sContador + 1), length(cMontos));
				--Se agregan los productos de TDC para los que aplicaran las campaÃ±as
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '6001'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '7000'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '8100'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
					INSERT INTO bdicred:sd_tasa_plazo_sms ( empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES ('001' , '8500'      , siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
				COMMIT;

			END FOREACH;
		END IF;	
		
		
		-- Genera informacion de plazos y tasas para APP
		IF sTasasApp > 0 THEN 	-- Existe informacion de app a cargar
			BEGIN;
				DELETE FROM bdicred:sd_tasa_plazo_app WHERE num_promo IN (SELECT DISTINCT camp FROM bdicred:sd_actvig_camp WHERE origen = "app");
			COMMIT;
			
			LET cMontos = '';
			FOREACH WITH HOLD
			   SELECT camp,    f_ini_vig, f_fin_vig, plazo,   tasa,   montos, identificador   --cast(tasa as decimal(18,2))
				 INTO siPromo, dtIni_Vig, dtFin_Vig, siPlazo, siTasa, cMontos, dIdentificador
				 FROM sd_actvig_camp WHERE origen = 'app'
				 
				 
				LET iNumProducto = SUBSTR(dIdentificador, (CHARINDEX('-', dIdentificador) + 1), length(dIdentificador)); 
				LET sContador = CHARINDEX('-',cMontos);
				LET iMonto_Ini = SUBSTR(cMontos, 1, (sContador - 1));
				LET iMonto_Fin = SUBSTR (cMontos, (sContador + 1), length(cMontos));
				
				--Se agregan los productos de TDC para los que aplicaran las campaÃ±as
				BEGIN;
					UPDATE "informix".sd_promocion SET fechaini_promo = dtIni_Vig, fechafin_promo = dtFin_Vig WHERE num_promo = siPromo;
					INSERT INTO bdicred:sd_tasa_plazo_app (empresa, num_producto, num_promo, tasa  , plazo   , plazo_activo, fecha_insert, monto_ini,  monto_fin ) 
													 VALUES (iEmpresa ,iNumProducto, siPromo  , siTasa, siPlazo , 1           , today       , iMonto_Ini, iMonto_Fin);
				COMMIT;

			END FOREACH;
		END IF;	
			  
		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacoraCamp)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sucursal''' ||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp1.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp1.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp1.sql';
		System cCadena;				
		LET cCadena = '' ;
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp1.sql';
		SYSTEM cCadena;

		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampSms)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_sms  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''sms'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp.sql';
		System cCadena;				
		LET cCadena = '' ;
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
		
		
		LET cCadena = '';
		LET cCadena = '/usr/bin/echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cBitacCampApp)  ||'  delimiter ''|'' SELECT a.num_promo,fechaini_promo,fechafin_promo,nombre_promo ,plazo,tasa FROM "informix".sd_promocion a inner join "informix".sd_tasa_plazo_app  b ON a.num_promo = b.num_promo WHERE a.num_promo in (select camp from "informix".sd_actvig_camp where origen = '||'''app'''||') order by 1,2,3,5;" >'||TRIM(cRuta)||'bit_camp_app.sql';
		SYSTEM cCadena;				
		LET cCadena='chmod 777 '|| TRIM(cRuta)||'bit_camp_app.sql';
		System cCadena;				
		let cCadena = 'dbaccess bdicred ' || TRIM(cRuta) || 'bit_camp_app.sql';
		System cCadena;				
		LET cCadena = '' ;
		--LET cCadena = 'rm ' || TRIM(cRuta) || 'bit_camp.sql';
		SYSTEM cCadena;
		
	END IF;
	LET cFechaGenArchivo = to_char(dt_fec_carga, '%d%m%Y');
		--LET cFechaCorte = cfec_arch;
		
		--LET cnomarchivol = TRIM(cnombre)||cFechaGenArchivo||'_Aux_'||'.txt';
		LET cnomarchivol = TRIM(cnombre)||cFechaGenArchivo||'.txt';
		LET cnomarchivoEjecSql = 'Exec_Rep_Con_6900' || '.sql';
		
		LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta2) || TRIM(cnomarchivol);
		LET cSQL2 = " SELECT camp, f_ini_vig, f_fin_vig, plazo, tasa, origen, montos, tipo_compra, identificador, giro, tipo, bloqueo, desbloqueo, carga, prioridad, cargado FROM bdicred:tmp_sd_actvig_camp;";
		
		LET cSQL3 = '">'||TRIM(cRuta2)|| cnomarchivoEjecSql;
		LET cSQL = trim(cSQL1) || cSQL2 || trim(cSQL3);
		System cSQL;

		LET cSQL='chmod 777 '|| TRIM(cRuta2)|| cnomarchivoEjecSql;
		System cSQL;

		let cSQL = 'dbaccess bdicred ' || TRIM(cRuta2) || cnomarchivoEjecSql;
		System cSQL;

		--LET cSql = cSql;
		--LET cSql = "sed 's/|$//g' "|| TRIM(cRuta2) || TRIM(cnomarchivol) || " >> " || TRIM(cRuta2) || TRIM(cnomarchivol);
		SYSTEM cSql;

		--Borra el archivo de control.
		LET cSQL = '' ;
		--LET cSQL = 'rm ' || TRIM(cRuta2) || cnomarchivoejecsql || ' ' || TRIM(cRuta2) || cnomarchivol;
		LET cSQL = 'rm ' || TRIM(cRuta2) || cnomarchivoejecsql;
		SYSTEM cSQL;

		--LET cCod_Ret = '000000';
		--LET cMensaje = 'PROCESO EXITOSO';

		--CALL bdicred:"informix".sp_inserta_bitacora(p_empresa, cProceso, cCod_ret, 'TERMINA CREACION REPORTE', '02') Returning cCod_RetIB;
	
	DROP TABLE tmp_sd_actvig_camp;

	LET cmensaje = 'Actualizacion de Vigencia Pagos Fijos Ok';

	RETURN cCodRet,cmensaje;
END
END PROCEDURE
DOCUMENT
'',
'AUTOR : Pamela Cardenas Balderas',
'FECHA : 30/MAYO/2018',
'BD    : BDICRED',
'AUTOR: Andrea Mariana Urrea Urias',
'CAMBIOS 13-05-25, ACEPTAR ORIGEN PROMO APP Y INSERTAR NO DE PRODUCTO DESDE LAYOUT',
'FECHA : 13/MAYO/2025',
'BD    : BDICRED',
'AUTOR: Luis German Diep Rendon',
'CAMBIOS 13-05-25, VALIDACION PARA PLAZOS DUPLICADOS EN ORIGEN APP Y SMS',
'FECHA : 10/SEPTIEMBRE/2025',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_apercred1_credisol(
			 pEmpresa       VARCHAR(3), 	-- EMPRESA
             pSolicitud     VARCHAR(20), 	-- NUMERO DE SOLICITUD
		 	 pEjecutivo     CHAR(8),		-- EJECUTIVO
			 pPlazo			INTEGER,		-- PLAZO EN MESES PARA PAGAR EL CREDITO
			 pNombrePres	CHAR(50),		-- NOMBRE DEL PRESTAMO
			 pMonto			DECIMAL(18,2),	-- MONTO APROBADO
			 pCuentaCap		CHAR(20),		-- CUENTA DE CAPTACION
			 pMensualidad	MONEY(18,2),		-- IMPORTE MENSUAL
			 pCanal 		SMALLINT  	DEFAULT 0 -- CANAL       
			 )

RETURNING CHAR(6),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);


--MODIFICO: Paul Ivan Quintero Varela
--Descripcion: Se modificÃ³ para realizar la validaciÃ³n de los dÃ­as inhabiles.
--Fecha: 2010/01/27
--Version: 20100127.1100

--MODIFICO: JesÃºs Manuel Aguilar Heredia
--Descripcion: Se modificÃ³ para implemtentar la apertura de credisoluciones
--Fecha: 2012/01/12
--Version: 20120112.1100

--MODIFICO: Andrea Mariana Urrea Urias 
--Descripcion: Se agrego adecuaciones para permitir las promociones desde otros canales (bdinteg:si_canales)
--Fecha:2025/07/30
--Version: 20250730.1100

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE cCodRet				VARCHAR(6);		-- CODIGO DE RETORNO
DEFINE cErrorInfo           VARCHAR(80);	-- MENSAJE DE ERROR
DEFINE mTasaInteres         DECIMAL(18,2);	-- TASA DE INTERES
DEFINE mTasaMora            DECIMAL(18,2);	-- TASA MORATORIA
DEFINE mSobreTasa           DECIMAL(18,2);	-- SOBRETASA
DEFINE mTasaFavor           DECIMAL(18,2);	-- TASA A FAVOR
DEFINE mSobreTasaFAV        DECIMAL(18,2);	-- SOBRETASA A FAVOR DEL CLIENTE
DEFINE cFactor	            CHAR(1);		-- FACTOR
DEFINE dFechaApert          DATE;			-- FECHA DE INICIO DEL PRESTAMO
DEFINE dFechaVenc           DATE;			-- FECHA DE TERMINACIÃN DEL PRESTAMO
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
DEFINE dIvaSuc              DECIMAL(5,3);   -- IVA DE LA SUCURSAL DONDE SE GENERÃ LA SOLICITUD
DEFINE idAbono              CHAR(1);
DEFINE bandesp              SMALLINT;
DEFINE v_tasainteres        DECIMAL(18,2);   
DEFINE sCountExist          SMALLINT;
DEFINE sContPaso	        SMALLINT;
DEFINE sNumPromocion		SMALLINT;
DEFINE sCountExstCred		SMALLINT;
DEFINE sCountExstDos		SMALLINT;
DEFINE sCountExstAnexo		SMALLINT;
DEFINE sCountCtasCarg		SMALLINT;
DEFINE sCountAmortiz		SMALLINT;
DEFINE sCountAutoriz		SMALLINT;
DEFINE sCountExistSms		SMALLINT;
DEFINE cStatus_cred 		CHAR(2);
DEFINE cIFRS				CHAR(1);
DEFINE iAtr_Act_ifrs		INTEGER;
DEFINE iDisposicionEfectivoApp      SMALLINT;  
DEFINE iComprasApp          SMALLINT; 
DEFINE iCanalApp			SMALLINT;
DEFINE pNumCredito         	CHAR(20);
DEFINE pPromo              	INTEGER;
DEFINE tasaPref 			DECIMAL(18,6);


--***********************
--INICIALIZA VARIABLES
--***********************

LET cCodRet      		= '000000';
LET cErrorInfo    		= 'PROCESO EXITOSO';
LET mTasaInteres 		= 0;
LET mTasaMora 			= 0;
LET mSobreTasa   		= 0;
LET mTasaFavor   		= 0;
LET mSobreTasaFAV		= 0;
LET cFactor	  			= "";
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
LET bandesp             = 0;
LET v_tasainteres       = 0;
LET sCountExist			= 0;
LET sContPaso	        = 0;
LET sNumPromocion		= 0;
LET sCountExstCred		= 0;
LET sCountExstDos		= 0;
LET sCountExstAnexo		= 0;
LET sCountCtasCarg		= 0;
LET sCountAmortiz		= 0;
LET sCountAutoriz		= 0;
LET sCountExistSms		= 0;
LET cIFRS				= '';
LET iAtr_Act_ifrs		= 0;
LET cStatus_cred 		= '';
LET iDisposicionEfectivoApp = 7;
LET iComprasApp 		= 8;
LET iCanalApp 			= 17;
LET pNumCredito         = '';
LET pPromo              = 0;
LET tasaPref 			= 0;



--Set debug file to  '/tmp/apercred_pp.out';
--trace on;

BEGIN
    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
		LET cErrorInfo  = cErrorInfo;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;		

		DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
	    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
		DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
		DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
        DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
        IF idAbono = "S" THEN
             CALL bdicheq:reversion(pEmpresa,cSucursal,pEjecutivo,cNumeroFolio,'R') RETURNING cCodRet;
             IF cCodRet <> "000" THEN
                LET cCodRet    = "000004";
             END IF;
        END IF;
        LET cCodRet    = iSqlErr;
        RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END EXCEPTION;
	
	
	SELECT NVL(valor,'I') INTO cIFRS FROM bdicred:sd_param WHERE cod_param = '700';
	IF cIFRS = 'A' THEN
		LET cStatus_cred = 'E1';
		LET iAtr_Act_ifrs = 0;
	ELSE
		LET cStatus_cred = 'AA';
		LET iAtr_Act_ifrs = NULL;
	END IF;	

	--SE VALIDA QUE LOS DATOS DE ENTRADA SEAN CORRECTOS
    IF pSolicitud > '690000000000' THEN
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    ELSE
        IF NVL(pEmpresa,"") = "" OR NVL(pSolicitud,"") = "" OR NVL(pEjecutivo,"") = "" OR NVL(pPlazo,0) = 0 OR NVL(pNombrePres,"") = "" OR
           NVL(pMonto,0) = 0 OR NVL(pCuentaCap,"") = "" THEN
            LET cCodRet = "000002";
            RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
        END IF
    END IF;

-- SE OBTIENEN LAS FECHAS DE INICIO, Y FIN DEL PRESTAMO Y LA FECHA DEL SIGUIENTE MES DESPUES DE LA APERTURA DEL CREDITO
    SELECT fecha_hoy INTO dFechaApert FROM bdicred:"informix".sd_fechas WHERE empresa = pEmpresa;

    CALL bdicred:"informix".monthadd(dFechaApert,pPlazo) RETURNING dFechaVenc;

	CALL bdicred:"informix".monthadd(dFechaApert,1) RETURNING dFechaT;
    CALL bdicred:"informix".sp_valfechabil(dFechaT,'+') RETURNING cCodRet, dFechaT;

    IF cCodRet <> "000" THEN
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
    END IF;

	--SE VALIDA QUE NO EXISTA EL CREDITO
	SELECT count(num_credito) INTO sCountExstCred FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstDos FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountExstAnexo FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountCtasCarg FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud;
	SELECT count(num_credito) INTO sCountAmortiz FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud;
	SELECT count(num_solicitud) INTO sCountAutoriz FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
	


	--IF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	IF sCountExstCred >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAESDOSCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstDos >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".SD_MAECREDANEXOCRD WHERE empresa = pEmpresa AND num_credito = pSolicitud) THEN
	ELIF sCountExstAnexo >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_ctascarg WHERE empresa = pEmpresa AND Naturaleza = 'A' AND num_credito = pSolicitud) THEN
	ELIF sCountCtasCarg >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_credito FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND fecha_cuota = dFechaT AND num_credito = pSolicitud) THEN
	ELIF sCountAmortiz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	--ELIF EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP") THEN
	ELIF sCountAutoriz >= 1 THEN
		LET cCodRet = "000001";
		RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	SELECT valor INTO mCatIva
	FROM  bdicred:'informix'.sd_param
	WHERE  cod_param = '034';
	IF mCatIva IS NULL THEN
	   LET mCatIva = 0;
	END IF
	
	---Validar que el credito exista en las tablas de promociones, en casod e existir se se tomara la informacion de las tablas de promociones.
	SELECT count(num_sol_prestamo) INTO sCountExist FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
	
	--IF EXISTS (SELECT num_sol_prestamo  FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud) THEN
	IF sCountExist > 0 THEN
		-- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES		
		
		-- Valida si son credisoluciones por medio de SMS
		SELECT num_promo INTO sNumPromocion FROM bdicred:"informix".sd_promocion_credito WHERE num_sol_prestamo = pSolicitud;
		IF sNumPromocion in (2, 5, 8) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
			 WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres FROM sd_promocion_credito_sms a INNER JOIN sd_promocion_credito b ON (a.num_credito = b.num_credito and a.folio_compra_sms = b.folio_movto)
				WHERE b.num_sol_prestamo = pSolicitud and a.mnto_compra = pMonto;
				LET bandesp = 1;
			END IF;
		ELIF sNumPromocion in (3, 6, 9) THEN
		
			SELECT COUNT(a.tasa) INTO sCountExistSms FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
			 WHERE num_sol_prestamo = pSolicitud;
			IF sCountExistSms > 0 THEN
				SELECT first 1 a.tasa INTO v_tasainteres
				  FROM bdicred:sd_promocion_credito_sms a JOIN bdicred:sd_promocion_credito b ON (a.num_credito = b.num_credito and a.num_promo = b.num_promo and mnto_compra = monto_actual and a.plazo = b.plazo )
				  WHERE num_sol_prestamo = pSolicitud;
				  LET bandesp = 1;
			END IF;
		END IF;	
		--IF NVL(v_tasainteres, 0) != 0 THEN
		--	LET bandesp = 1;		
		--END IF;
		
		-- Valida si son credisoluciones por carga de archivo 
		SELECT COUNT(a.tasa) INTO sContPaso FROM sd_credpaso a INNER JOIN sd_promocion_credito b ON a.num_credito = b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto;
        --IF EXISTS(SELECT a.tasa FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo = pSolicitud and a.monto_actual = pMonto) THEN
		IF sContPaso > 0 THEN
            SELECT first 1 a.tasa INTO v_tasainteres FROM sd_credpaso a INNER JOIN sd_promocion_credito b  ON a.num_credito=b.num_credito WHERE b.num_sol_prestamo=pSolicitud and a.monto_actual=pMonto; 
            LET bandesp=1;
        END IF;
		
		
		
		--Correccion
		IF (snumpromocion IN (iDisposicionEfectivoApp, iComprasApp) AND pCanal == iCanalApp) THEN		
		
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo,b.num_credito,b.num_promo 
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag, pNumCredito, pPromo
			FROM bdicred:"informix".sd_definicion a
			   INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			   INNER JOIN bdicred:"informix".sd_maecred mae ON b.num_credito = mae.num_credito
			   INNER JOIN bdicred:"informix".sd_tasa_plazo_app c ON (c.plazo = b.plazo AND b.num_promo = c.num_promo AND c.plazo_activo = 1  AND c.num_producto = mae.num_producto)
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

			-- BUSCAMOS EN LA sd_prospectos SI LA TASA ES MAYOR A 0
				  SELECT NVL(tasa, 0.00) INTO tasaPref
				  FROM "informix".sd_prospectos
				  WHERE empresa = pEmpresa
				  AND num_credito = pNumCredito
				  AND num_producto = '6900'
				  AND num_promo = pPromo;
				  
			if tasaPref > 0 THEN 
				LET mTasaInteres = tasaPref;
			END IF;
		
		ELSE
				
			--INTERES ORDINARIO --se liga con la tabla sd_promocion_credito
			SELECT c.tasa, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				INNER JOIN bdicred:"informix".sd_tasa_plazo c ON (c.plazo = b.plazo AND b.num_promo =c.num_promo AND c.plazo_activo = 1 )
			WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		END IF;



        IF (bandesp=1 AND pCanal <> iCanalApp) THEN 
            LET mTasaInteresProd = v_tasainteres;
            LET mTasaInteres = v_tasainteres;

			IF NVL(cPeriodoPag,'') = '' THEN		-- Si el plazo no existe, es sms y ya cambiaron los plazos.
				SELECT a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
				INTO   cFactor           , mSobreTasa , sDiaCorte  , cPeriodoPag
				FROM bdicred:"informix".sd_definicion a
					INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
				WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;			
			END IF;
        ELSE
			LET mTasaInteresProd = mTasaInteres;
        END IF;

		IF cFactor = "+" THEN
			LET mTasaInteres = mTasaInteres + mSobreTasa;
		ELIF cFactor = "-" THEN
			LET mTasaInteres = mTasaInteres - mSobreTasa;
		ELIF cFactor = "*" THEN
			LET mTasaInteres = mTasaInteres * mSobreTasa;
		ELSE
			LET mTasaInteres = mTasaInteres / mSobreTasa;
		END IF

		--INTERES MORATORIO
		SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
		INTO mTasaMora, cFactor, mSobreTasa
		FROM bdicred:"informix".sd_definicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
		AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

		LET mTasaMoraProd = mTasaMora;

		IF cFactor = "+" THEN
				LET mTasaMora = mTasaMora + mSobreTasa;
		ELIF cFactor = "-" THEN
				LET mTasaMora = mTasaMora - mSobreTasa;
		ELIF cFactor = "*" THEN
				LET mTasaMora = mTasaMora * mSobreTasa;
		ELSE
				LET mTasaMora = mTasaMora / mSobreTasa;
		END IF

		--INTERES A FAVOR DEL CLIENTE
		SELECT c.valor, a.factor_sobretasa, a.sobretasa
		INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
		FROM bdicred:"informix".sd_anexodefinicion a
			INNER JOIN bdicred:"informix".sd_promocion_credito b ON b.empresa = a.empresa AND b.num_pro_prestamo = a.num_producto
			INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud
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

		-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
		SELECT a.num_producto, a.divisa, b.sucursal
		INTO cProducto, cDivisa, cSucursal
		FROM bdicred:"informix".sd_promocion_credito b
		  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_pro_prestamo
		WHERE b.empresa = pEmpresa AND b.num_sol_prestamo = pSolicitud;

		SELECT a.iva
			INTO dIvaSuc
		FROM bdinteg:"informix".si_sucursales a
		WHERE a.sucursal = cSucursal
		AND a.empresa  = pEmpresa;

		  --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
		INSERT INTO bdicred:"informix".sd_maecredcrd
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
			   )
		SELECT  sol.empresa                		,pSolicitud
			   ,sol.num_pro_prestamo            ,pEjecutivo
			   ,sol.num_cte                      ,''
			   ,''                              ,NVL(def.divisa,1)
			   ,NVL(sol.sucursal,'')            ,''
			   ,''                              ,''
			   --IFRS,''                              ,'AA'
			   ,''								,cStatus_cred
			   ,'S'                             ,'N'
			   ,NVL(def.periodo_plazo,'')       ,pPlazo
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
			   ,''                              ,cPeriodoPag
			   ,''                              ,''
			   ,''                              ,0
			   ,0                               ,0
			   ,''                              ,''
		FROM bdicred:"informix".sd_promocion_credito sol
		INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_pro_prestamo
		INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.num_cte
		INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
		WHERE  sol.num_sol_prestamo = pSolicitud AND sol.empresa = pEmpresa;


		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		 --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;

				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;


			INSERT INTO bdicred:"informix".sd_maecredanexocrd
				(empresa, 				 		num_credito,
				 localidad,              		dia_corte,
				 dias_gracia_mora, 		 		tp_dias_calc_mora,
				 dias_fecha_max_pago,	 		tp_dias_fecha_pago,
				 cod_tasa_base_cte, 	 		factor_sobretasa_cte,
				 sobretasa_cte, 		 		tasa_interes_cte,
				 fecha_vencto, 			 		prox_fecha_pago,
				 fecha_proceso,			 		fecha_ult_pago,
				 nombre_pres)
			SELECT pEmpresa              		,pSolicitud,
				   ""                    		,DAY(dFechaApert),
				   NVL(def.gracia_calc_mora,0)  ,'',
				   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
				   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
				   NVL(def.sobretasa,0)    		,mTasaInteresProd,
				   ""                    		,dFechaT,
				   dFechaApert           		,"",
				   pNombrePres
			FROM bdicred:"informix".sd_definicion def
				INNER JOIN bdicred:"informix".sd_promocion_credito c ON c.empresa = def.empresa AND c.num_pro_prestamo = def.num_producto
			WHERE c.empresa = pEmpresa AND c.num_sol_prestamo = pSolicitud;
		END;
		  --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

		LET iNumReg = dbinfo("sqlca.sqlerrd2");

		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;


		BEGIN
			ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
				 LET cCodRet    = iSqlErr;
				 LET cErrorInfo  = cErrorInfo;
				 RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END EXCEPTION;

			INSERT INTO bdicred:"informix".sd_maesdoscrd
					(
						empresa, 			num_credito,		fecha_ult_mov, 		sdo_int_anticip,
						sdo_int_ant_dev, 	sdo_intereses,		sdo_dia_ant_int, 	sdo_mes_ant_int,
						sdo_acum_mes_int, 	sdo_retenido,		sdo_acum_cap_int, 	sdo_exig_int,
						sdo_no_exig, 		provision_normal,	dias_acum_int, 		sdo_moratorio,
						sdo_dia_ant_mor, 	sdo_mes_ant_mor,	sdo_contab_mora, 	dias_acum_mora,
						sdo_capital, 		sdo_cap_insoluto,	sdo_dia_ant_cap, 	sdo_mes_ant_cap,
						sdo_acum_mes_cap, 	mto_capitalizado,	mto_ministra_cap, 	cargos_dia_cap,
						abonos_dia_cap, 	cargos_mes_cap,		abonos_mes_cap, 	dias_acum_cap,
						monto_vencido, 		mto_venc_trasp,		monto_financiado, 	monto_reservado,
						sdo_acum_vencido, 	dias_acum_intper,	sdo_global_int, 	sdo_acum_intper,
						monto_otorgado, 	provi_venc_normal,	provi_venc_anticip, cap_tras_no_venci,
						mto_venc_int, 		mto_venc_tra_int,	mto_finan_vdo, 		mto_reser_int,
						mto_fin_ven_trasp, 	mto_fin_vig_trasp,	int_tra_no_exig, 	sdo_trab4,
						atr
					)
			VALUES
					(
						pEmpresa                ,pSolicitud, 	dFechaApert            ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto                 ,pMonto			,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,pMonto					,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,0                      ,0				,0                      ,0
						,iAtr_Act_ifrs
					);
		END;

		LET iNumReg = dbinfo("sqlca.sqlerrd2");
		IF iNumReg = 0 THEN
			LET cCodRet = "000003";

			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF;

		-- SE GENERA EL FOLIO
		CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

		-- SE ASIGNA EL FOLIO DE LA TRANSACCION
		LET cTransacc = "0247";

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,	cProducto        , 3,
									"001"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'APERTURA','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF

		EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
									cProducto        , 66,
									"002"            , dFechaApert,
									pMonto           , cNumeroFolio,
									cSucursal        , cDivisa,
									"0000",'DISPOSICION','')
		INTO cCodRet, cErrorInfo;

		IF cCodRet <> "000000" THEN
			DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
            DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
			RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		END IF


		-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
		INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
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

	ELSE---proceso productivo de apertura de prestamos...	o se sigue el flujo normal....

		    -- SE DETERMINAN LAS DIFERENTES TASAS DE INTERES

			--INTERES ORDINARIO
			SELECT c.valor, a.factor_sobretasa, a.sobretasa, a.dia_cuota, a.periodo_plazo
			INTO mTasaInteres, cFactor, mSobreTasa, sDiaCorte, cPeriodoPag
			FROM bdicred:"informix".sd_definicion a
				INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_base
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud
				AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_base);

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

			--INTERES MORATORIO
			SELECT c.valor, a.fact_sobret_mora, a.sobretasa_mora
			INTO mTasaMora, cFactor, mSobreTasa
			FROM bdicred:"informix".sd_definicion a
			    INNER JOIN bdisolic:"informix".ss_solicitudes b ON b.empresa = a.empresa AND b.num_producto = a.num_producto
				INNER JOIN bdinteg:"informix".si_fechavalor c ON c.empresa = a.empresa AND c.tasa = a.cod_tasa_mora
			WHERE b.empresa = pEmpresa AND num_solicitud = pSolicitud
			    AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r WHERE r.empresa = pEmpresa AND r.tasa = a.cod_tasa_mora);

			LET mTasaMoraProd = mTasaMora;

			IF cFactor = "+" THEN
					LET mTasaMora = mTasaMora + mSobreTasa;
			ELIF cFactor = "-" THEN
					LET mTasaMora = mTasaMora - mSobreTasa;
			ELIF cFactor = "*" THEN
					LET mTasaMora = mTasaMora * mSobreTasa;
			ELSE
					LET mTasaMora = mTasaMora / mSobreTasa;
			END IF

			--INTERES A FAVOR DEL CLIENTE
			SELECT c.valor, a.factor_sobretasa, a.sobretasa
			INTO mTasaFavor, cFactorFAV, mSobreTasaFAV
			FROM bdicred:"informix".sd_anexodefinicion a
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

			-- SE OBTIENE LA CLAVE DEL PRODUCTO, EL CODIGO DE DIVISA, EL MONTO DEL PRESTAMO SOLICITADO Y LA SUCURSAL
			SELECT a.num_producto, a.divisa, b.sucursal
			INTO cProducto, cDivisa, cSucursal
			FROM bdisolic:"informix".ss_solicitudes b
			  INNER JOIN bdicred:"informix".sd_definicion a ON a.empresa = b.empresa AND a.num_producto = b.num_producto
			WHERE b.empresa = pEmpresa AND b.num_solicitud = pSolicitud;

		       SELECT a.iva
		         INTO dIvaSuc
		         FROM bdinteg:"informix".si_sucursales a
		        WHERE a.sucursal = cSucursal
		          AND a.empresa  = pEmpresa;

		      --***** SE INSERTA INFORMACION EN SD_MAECREDCRD
			INSERT INTO bdicred:"informix".sd_maecredcrd
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
				   )
			SELECT  sol.empresa                		,pSolicitud
				   ,sol.num_producto                ,NVL(anx.ejecutivo_sol,'')
				   ,sol.numcte                      ,''
				   ,''                              ,NVL(def.divisa,1)
				   ,NVL(sol.sucursal,'')            ,''
				   ,''                              ,''
				   --IFRS,''                              ,'AA'
				   ,''                              ,cStatus_cred
				   ,'S'                             ,'N'
				   ,NVL(def.periodo_plazo,'')       ,pPlazo
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
				   ,''                              ,cPeriodoPag
				   ,''                              ,''
				   ,''                              ,0
				   ,0                               ,0
				   ,''                              ,''
			FROM bdisolic:"informix".ss_solicitudes sol
				INNER JOIN bdicred:"informix".sd_definicion def ON def.empresa = sol.empresa AND def.num_producto = sol.num_producto
				INNER JOIN bdisolic:"informix".ss_anexosol anx ON anx.num_solicitud = sol.num_solicitud AND anx.empresa = sol.empresa
				INNER JOIN bdinteg:"informix".si_cliente cli ON cli.empresa = sol.empresa AND cli.numcte = sol.numcte
				INNER JOIN bdinteg:"informix".si_tipper tip ON tip.tpo_persona = cli.tpo_persona
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

		     --***** SE INSERTA INFORMACION EN SD_MAECREDANEXOCRD (DATOS PARA TARJETA DE CREDITO)
		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;

			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;


				INSERT INTO bdicred:"informix".sd_maecredanexocrd
					(empresa, 				 		num_credito,
					 localidad,              		dia_corte,
			         dias_gracia_mora, 		 		tp_dias_calc_mora,
			         dias_fecha_max_pago,	 		tp_dias_fecha_pago,
			         cod_tasa_base_cte, 	 		factor_sobretasa_cte,
			         sobretasa_cte, 		 		tasa_interes_cte,
			         fecha_vencto, 			 		prox_fecha_pago,
			         fecha_proceso,			 		fecha_ult_pago,
			         nombre_pres)
				SELECT pEmpresa              		,pSolicitud,
		               ""                    		,DAY(dFechaApert),
					   NVL(def.gracia_calc_mora,0)  ,'',
					   DAY(dFechaApert)      		,NVL(def.maneja_linea,''),
					   NVL(def.cod_tasa_base,'')	,NVL(def.factor_sobretasa,''),
					   NVL(def.sobretasa,0)    		,mTasaInteresProd,
					   ""                    		,dFechaT,
					   dFechaApert           		,"",
					   pNombrePres
				FROM bdicred:"informix".sd_definicion def
		            INNER JOIN bdisolic:"informix".ss_solicitudes c ON c.empresa = def.empresa AND c.num_producto = def.num_producto
		     --       INNER JOIN bdicred:"informix".sd_anexodefinicion b ON b.empresa = def.empresa AND b.num_producto = c.num_producto
			--			AND b.cod_prod = def.cod_tipcred
				WHERE c.empresa = pEmpresa AND c.num_solicitud = pSolicitud;
		    END;
		      --***** SE INSERTA INFORMACION EN SD_MAESDOSCRD

			LET iNumReg = dbinfo("sqlca.sqlerrd2");

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;


		    BEGIN
			    ON EXCEPTION SET iSqlErr, iIsamError, cErrorInfo
			         LET cCodRet    = iSqlErr;
			         LET cErrorInfo  = cErrorInfo;
			         RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			    END EXCEPTION;

		        INSERT INTO bdicred:"informix".sd_maesdoscrd
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
							,0                      ,0
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
							,iAtr_Act_ifrs
				FROM   bdisolic:"informix".ss_solicitudes sol
				WHERE  sol.num_solicitud = pSolicitud AND sol.empresa = pEmpresa;
			END;

			IF iNumReg = 0 THEN
				LET cCodRet = "000003";
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF;

			-- SE GENERA EL FOLIO
			CALL bdicheq:"informix".sp_generafolionomina(pEjecutivo) RETURNING cCodRet, cNumeroFolio;

			-- SE ASIGNA EL FOLIO DE LA TRANSACCION
			LET cTransacc = "0247";

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 3,
		                                "001"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'APERTURA','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF

		    EXECUTE PROCEDURE "informix".genmovcrd(pEmpresa         , pSolicitud,
										cProducto        , 66,
		                                "002"            , dFechaApert,
		                                pMonto           , cNumeroFolio,
		                                cSucursal        , cDivisa,
		                                "0000",'DISPOSICION','')
			INTO cCodRet, cErrorInfo;

			IF cCodRet <> "000000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
			END IF


			-- SE INSERTA INSERTA INFORMACION EN LA TABLA DE AMORTIZACIONES
			INSERT INTO bdicred:"informix".sd_amortiza_creditocrd
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

			--SE INSERTA EN LA TABLA bdicred:"informix".sd_ctascarg
			INSERT INTO bdicred:"informix".sd_ctascarg (empresa, numero, con_cap_inte, naturaleza, num_credito, tipo_cta, num_cta, num_nomina)
			VALUES(pEmpresa,0,'','A',pSolicitud,'',pCuentaCap,'');

		    -- SE ACTUALIZA EL ESTATUS DE LA SOLICITUD
		    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AP"
		    WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;

            --FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
            INSERT INTO bdicred:sd_indicador_cred_crd
                        (empresa, num_credito, fecha_alta)
                VALUES (pEmpresa, pSolicitud, dFechaApert);



		    SELECT nombre INTO cMensaje FROM bdinteg:"informix".si_ejecut WHERE ejecutivo = pEjecutivo AND empresa = pEmpresa;

		    LET cMensaje = "Apertura de Credito Autorizada por: " || TRIM(cMensaje);

			-- SE INSERTA EN LA TABLA DE AUTORIZACIONES DE SOLICITUD
		    INSERT INTO bdisolic:"informix".ss_autorizacion
				(empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
		     VALUES(pEmpresa, pEjecutivo, pSolicitud, "AP", cMensaje, dFechaApert, dFechaApert, USER, TODAY);

			-- SE GENERA EL ABONO
			CALL bdicheq:"informix".abono_ref (pEmpresa, cSucursal, pEjecutivo, cTransacc, cTransacc, cNumeroFolio, pCuentaCap, 0,
				pMonto, pMonto, 0, 0, 0, "01", pNombrePres, '0', pEjecutivo) RETURNING cCodRet;

			-- SI NO SE PUDO GENERAR EL ABONO SE REVERSAN TODOS LOS MOVIMIENTOS QUE SE HABIAN ECHO
			IF cCodRet <> "000" THEN
				DELETE FROM bdicred:"informix".sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_movdiacrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredanexocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
			    UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT" WHERE empresa = pEmpresa AND num_solicitud = pSolicitud;
			    DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = pEmpresa AND num_solicitud = pSolicitud AND status_solicitud = "AP";
				DELETE FROM bdicred:"informix".sd_amortiza_creditocrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_maecredcrd WHERE empresa = pEmpresa AND num_credito = pSolicitud;
				DELETE FROM bdicred:"informix".sd_ctascarg WHERE num_credito = pSolicitud;
                DELETE FROM bdicred:"informix".sd_indicador_cred_crd WHERE num_credito = pSolicitud; --FMV 15may13: En caso x error en apertura
				RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
		    ELSE
		        LET idAbono = "S";
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

	END IF;

    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008
    LET mTasaMora = mTasaMora - mTasaInteres;
    IF mTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
       LET mTasaMora = mTasaMora * -1;
    END IF
    RETURN cCodRet,mTasaInteres,mTasaMora,mCatIva,cMercadeo;
END;
END PROCEDURE;
CREATE PROCEDURE "informix".generaestadosdecuenta_comple (
				pempresa CHAR(3),
				pnum_credito CHAR(20),
				pfechahoy DATE)
RETURNING CHAR(5);

--Modificacion 05112009
--Homologar uso de valor "tipo de casa" (habita_en) a nuevo catalogo (claves en letras) en paso 02 alta unica

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE cod_ret             		CHAR(5);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			    CHAR(5);

DEFINE v_corta_linea_detalle 	INTEGER;
DEFINE v_corta_retorno        INTEGER;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_sucursal        CHAR(4);	--Sucursal Cliente
DEFINE v_ult_dir_clie	   INTEGER;	--Secuencia Ultima Direccion Cliente
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


DEFINE v_numerociudad 		SMALLINT;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 		INT;   		--Numero Colonia Direccion Cliente
DEFINE v_numerocalle 		  INT;   		--Numero Calle Direccion Cliente
DEFINE v_numeroextcalle 	CHAR(10);	--Numero Exterior Calle Direccion Cliente
DEFINE v_estado 			    CHAR(2);	--Numero Estado
DEFINE v_nombrecalle		  CHAR(30);	--Nombre Calle Catalogo Calles
DEFINE v_centro				    INT;   		--Centro Catalogo de Zonas
DEFINE v_jefegrupozona		INT;  		--Clave Jefe Grupo Zona
DEFINE v_supervisorzona		INT;   		--Clave Supervisor Zona
--jom ini catalogos
DEFINE v_numerociudadcoppel  integer;	--Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniacoppel integer;		--Numero Colonia Direccion Cliente
--jom fin catalogos
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);




DEFINE v_status_cred			CHAR(2);
--------------------------------------------------------
--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DEFINE v_capital_tc   			    DECIMAL(18,2);	--capital_tc
DEFINE v_interes_tc   			    DECIMAL(18,2);	--interes_tc
DEFINE v_iva_interes_tc   		  DECIMAL(18,2);	--iva_interes_tc
DEFINE v_capital_ven_tc   		  DECIMAL(18,2);	--capital_ven_tc
DEFINE v_interes_ven_tc   		  DECIMAL(18,2);	--interes_ven_tc
DEFINE v_iva_interes_ven_tc   	DECIMAL(18,2);	--iva_interes_ven_tc
DEFINE v_moratorios_tc   		    DECIMAL(18,2);	--moratorios_tc
DEFINE v_iva_moratorios_tc   	  DECIMAL(18,2);	--iva_moratorios_tc
DEFINE v_pago_minimo_tc   		  DECIMAL(18,2);	--sdo_pagar
DEFINE v_interes_pago_total_tc  DECIMAL(18,2);	--interes_pago_total_tc
DEFINE v_limite_tc   			      DECIMAL(18,2);	--limite_tc
DEFINE v_disponible_tc   		    DECIMAL(18,2);	--sdo_disponible
DEFINE v_periodo_tc_ini   		  DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   		  DATE;	  		--periodo_tc_fin
DEFINE v_fecha_limite_pago_tc   DATE;	  		--pago_antes_de
DEFINE v_fecha_corte_tc   		  DATE;		   	--fecha_corte
DEFINE v_dias_periodo_tc 		    INTEGER;		--dias_periodo_tc
DEFINE v_usted_debia   			    DECIMAL(18,2);	--usted_debia
DEFINE v_sus_abonos   			    DECIMAL(18,2);	--menos_abonos
DEFINE v_sus_compras   			    DECIMAL(18,2);	--mas_compras
DEFINE v_sus_comisiones 		    DECIMAL(18,2);	--sus_comisiones
DEFINE v_dispocisiones  		    DECIMAL(18,2);	--mas_disp_efectivo
DEFINE v_intereses   			      DECIMAL(18,2);	--mas_intereses
DEFINE v_iva   					        DECIMAL(18,2);	--mas_iva
DEFINE v_rendimientos   		    DECIMAL(18,2);	--mas_rendimientos
--jom ini SBC
DEFINE v_comisiones_sbc         DECIMAL(18,2);	--mas_comisiones_sbc
DEFINE v_iva_comisiones_sbc     DECIMAL(18,2);  --mas_iva_comisiones_sbc
--jom fin SBC
--jom ini repos
DEFINE V_comis_repos            DECIMAL(18,2);  --comision por reposicion
--jom fin repos


DEFINE v_iva_comisiones   		  DECIMAL(18,2);	--mas_iva comisiones
DEFINE v_iva_suc   				      DECIMAL(18,2);	--mas_iva
DEFINE v_sdo_retenido       	  DECIMAL(18,2);	--SALDO RETENIDO
DEFINE v_fecha_apertura			    DATE;			--fecha de apertura
DEFINE v_periodo_anterior   	  DATE;			--Fecha Periodo Anterior

DEFINE v_capital_debe 		DECIMAL(14,2);
DEFINE v_interes_debe 		DECIMAL(14,2);
DEFINE v_interes_pagado		DECIMAL(14,2);
DEFINE v_iva_debe 			  DECIMAL(14,2);
DEFINE v_iva_pagado 		  DECIMAL(14,2);


DEFINE v_mora_sdo_ordi		  DECIMAL(14,2);
DEFINE v_mora_sdo_ordi_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope_pag	DECIMAL(14,2);
DEFINE v_mora_sdo_cope		  DECIMAL(14,2);
DEFINE v_mora_provi_ordi	  DECIMAL(14,2);
DEFINE v_mora_provi_cope	  DECIMAL(14,2);
DEFINE v_mora_iva_debe		  DECIMAL(14,2);
DEFINE v_mora_iva_pagado	  DECIMAL(14,2);
DEFINE v_capital_status		  CHAR(1);
DEFINE v_fecha_cuota		    DATE;

DEFINE v_moratorios_tcA   		DECIMAL(18,2);	--moratorios_tc
DEFINE v_moratorios_tcB   		DECIMAL(18,2);	--moratorios_tc

DEFINE  v_monto_financiado	DECIMAL(18,2);
DEFINE 	v_campo_trabajo1		DECIMAL(14,2);
--------------------------------------------------------
--	VARIABLES GENERACION DETALLE EDO CUENTA
--------------------------------------------------------
DEFINE v_dia           		char(2);
DEFINE v_mes           		char(2);
DEFINE v_ano	       		  char(4);
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
DEFINE v_fecha_aclara		  DATE;
DEFINE v_descripcion		  VARCHAR(255);
DEFINE v_importe			    DECIMAL(18,2);
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
DEFINE v_cuenta_mensajes		SMALLINT;
DEFINE v_secuencia_mensaje	SMALLINT;
DEFINE v_nlinea_mensajes		SMALLINT;
DEFINE v_si_paga		    	  VARCHAR(255);
DEFINE v_mensajes				    VARCHAR(255);


DEFINE v_factor					DECIMAL(14,10);
DEFINE v_aplica_factor	DECIMAL(14,2);
DEFINE v_usted_debe			DECIMAL(18,2);

DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;

--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
DEFINE v_tasa_mensual		    DECIMAL(18,2);
DEFINE v_tasa_anual			    DECIMAL(18,2);
DEFINE v_saldo_promedio		  DECIMAL(18,2);
DEFINE v_tasa_mora			    DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	DECIMAL(18,2);

DEFINE v_sdo_acum_mes_cap  	DECIMAL(18,2);
DEFINE v_dias_acum_cap     	DECIMAL(18,2);

DEFINE GLOBAL v_cat			DECIMAL(18,2) DEFAULT 0;


--------------------------------------------------------
--	VARIABLES GENERACION CLAVE DE COBRANZA
--------------------------------------------------------
DEFINE v_cl_cobranza        CHAR(60);

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
DEFINE v_cuantos_avisos		  INTEGER;

DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_avisos 	    	    CHAR(1);
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
DEFINE v_clave5         VARCHAR(40);

DEFINE posicion11            CHAR(5);
DEFINE posicion17            CHAR(5);

DEFINE cInserto              CHAR(15);



--Set debug file to "/ids10_uc9/sp_Visainformacionvisa.out";
--trace on;
--modifico: Bernardo carlos Báez González
--fecha modificacion: 22/07/2009
--Se modifica para obtener importe, fecha y estado de cumplimiento del último compromiso la tabla cb_compac_his
--en caso de no existir ningún compromiso en la tabla cb_compac
--También se modifica para el estado cumplimiento: cuando exista compromiso en cb_compac deberá guardar .P.,
--si no existe y existe en cb_compac_his deberá guardar .S. si flag_pago es igual a 1 y .N. si flag_pago pago es igual 0,
--en caso de no existir compromiso en ninguna de las tablas deberá guardar .-.
--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "000";
LET v_cod_ret_otro = "000";

LET sql_err = "";
LET v_corta_linea_detalle 	= 30;
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
LET v_direccion_col	    = "";
LET v_direccion_del 	  = "";
LET v_edo_cd     		    = "";
LET v_sucursal_nombre   = "";
LET v_sucursal_gerente  = "";
LET v_sucursal_tel      = "";
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
LET v_estado 			    = "";
LET v_nombrecalle		  = "";
LET v_centro			    = 0;
LET v_jefegrupozona		= 0;
LET v_supervisorzona	= 0;


LET v_status_cred = "";
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
--jom fin repos
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


LET v_concepto     			= "";
LET v_naturaleza   			= "";
LET v_letra        			= "";
LET v_fecha_mov    			= "";

LET v_compra    		= "";
LET v_abono     		= "";

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
LET v_avisos 	    	     = "0";
LET v_nivel_eficiencia	 = 0;
LET v_fecha_ultimo_pago  = " ";

LET v_salario            = 0;
LET v_monto_adeudo		   = 0;
LET v_mto_adeudo_venc    = 0;


LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5      = "";

LET posicion11 = "";
LET posicion17 = "";

LET cInserto  = "";

set isolation to dirty read;
set lock mode to wait 3;

BEGIN

  ON EXCEPTION SET sql_err, isam_err, error_info
	IF sql_err <> 0 THEN
        SET DEBUG FILE TO "generaestadosdecuenta.out";
        TRACE ON;
        let  isam_err = isam_err;
        let error_info = error_info; 
	    LET cod_ret = sql_err;
        RETURN cod_ret;
	END IF
   END EXCEPTION WITH RESUME ;

-- SET DEBUG FILE TO "generaestadosdecuenta.out";
-- TRACE ON;

   	--##############################################################
		--##	GENERACION ENCABEZADO EDO CUENTA				      ##
   	--##############################################################

      update bdicred:sd_valedocta 
         set fecha_proc = today
           where empresa = '001'
            and fecha_proc = '02/20/2010' 
            and num_credito = pnum_credito;

    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
	SELECT a.numcte
        INTO v_numcte
	FROM sd_maecred a
	WHERE a.empresa = pempresa
	AND a.num_credito = pnum_credito;

   	--##############################################################
	--##	GENERACION ENCABEZADO2 EDO CUENTA				      ##
   	--##############################################################
    -------------------------------------------------------------
	--SD_AMORTIZA_CREDITO
    -------------------------------------------------------------

        	SELECT 	count(*) INTO v_cuantos_avisos
			FROM sd_amortiza_credito
			WHERE empresa = pempresa
			AND num_credito = pnum_credito
            AND capital_status IN ("2","7");

    -------------------------------------------------------------
	--SD_MAESDOSHIST
    -------------------------------------------------------------
			-- CAPITAL VENCIDO,PAGO PARA NO GENERAR INTERESES, LIMITE DE CREDITO
	SELECT     monto_vencido + mto_venc_trasp,
	           sdo_cap_insoluto,
		   monto_otorgado,
		   sdo_retenido,
		   sdo_acum_mes_cap,
		   dias_acum_cap,
		   NVL(sdo_cap_insoluto,0),
		   NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),
		   NVL(int_tra_no_exig,0),
		   NVL(sdo_moratorio,0) + NVL(sdo_contab_mora,0),
		   monto_financiado
		INTO v_capital_ven_tc,
		   v_interes_pago_total_tc,
		   v_limite_tc,
		   v_sdo_retenido,
		   v_sdo_acum_mes_cap,
		   v_dias_acum_cap,
		   v_monto_adeudo,
		   v_mto_adeudo_venc,
		   v_interes_ven_tc,
		   v_moratorios_tc,
		   v_monto_financiado
	FROM sd_maesdoshist
	WHERE fecha =pfechahoy
	AND empresa = pempresa
	AND num_credito = pnum_credito;
    -------------------------------------------------------------
	--SD_MAECREDANEXO
    -------------------------------------------------------------
			--FECHA LIMITE DE PAGO


--MENOS SUS ABONOS,MAS SUS COMPRAS,MAS COMISIONES,MAS DISPOSICIONES EM EFECTIVO,MAS INTERESES,MAS IVA
	SELECT 	MAX(fecha_mov)-- FECHA ULTIMO PAGO
	INTO 	v_fecha_ultimo_pago -- si
	FROM   	sd_movhisedocta
	WHERE  	empresa = pempresa
	AND num_credito = pnum_credito
	AND fecha_mov >= '01/21/2010'
	AND fecha_mov <= '02/20/2010'
	AND reversado = "N";
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
		--USTED DEBE
		LET v_usted_debe = v_interes_pago_total_tc;


   	--##############################################################
	--##	GENERACION MENSAJES	 EDO CUENTA				          ##
   	--##############################################################


   LET v_factor = 0.1139417057;

   LET v_secuencia_mensaje  = 0 ;
   LET v_si_paga = v_usted_debe ;


	 IF v_usted_debe <= 0 THEN
	 	LET v_aplica_factor = 0;
	 ELSE
	 	LET v_aplica_factor = v_usted_debe * v_factor;
	 END IF
	 ----MOD CAS

						INSERT INTO sd_mensajes_edocta_2010
							(
							fecha_emision, 		num_credito,
							secuencia,			nlinea,
							si_paga, 			mensajes
							)
                       SELECT  pfechahoy, TRIM(pnum_credito),
                               clave,secuencia,CASE WHEN clave=2 AND secuencia=1
                               THEN v_si_paga ELSE NULL END ,REPLACE(mensaje,v_linea_auxiliar,TRIM(v_aplica_factor::VARCHAR(21)))
                               FROM mensajes;

    -----MOD CAS


   	--##############################################################
	--##	GENERACION   PIE	 EDO CUENTA				          ##
   	--##############################################################


    select nvl(interes_tc,0),
           nvl(sdo_pagar,0),
           nvl(capital_tc,0)
    into v_interes_tc,
         v_pago_minimo_tc,
         v_capital_tc
    from sd_encabezado2_edocta
    where fecha_emision = pfechahoy
     and  num_credito = pnum_credito;

    IF ( v_interes_tc > 0 ) THEN
       LET v_saldo_promedio = round((v_interes_tc*360)/(31 * (65 / 100)),2);
    ELSE
	   LET v_saldo_promedio = 0;
    END IF;

	--------------------------------------------------------
    --	GENERA EL PIE DEL ESTADO DE CUENTA
    --------------------------------------------------------
	INSERT INTO sd_pie_edocta
			(
			fecha_emision,			num_credito,
			tasa_mensual,			tasa_anual,
			cat,					saldo_promedio,
			tasa_mora,				tasa_mensual_mora,
			dias_periodo
			)
	VALUES
			(
			pfechahoy,				pnum_credito,
			5.42,	65.00,
			89.90,			NVL(v_saldo_promedio,0),
			36,		3,
			0
			);

   	--##############################################################
	--##	GENERACION  CLAVE DE COBRANZA				          ##
   	--##############################################################
    --------------------------------------------------------
    --	1.--TIPO DE CLIENTE: (2 Numero)
    --------------------------------------------------------
    --------------------------------------------------------
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
    --3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Año Nacimiento (2 Numeros)
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
	SELECT NVL(ingreso_mensual,0) / 1400
		INTO   v_salario
	FROM   bdisolic:ss_resum_scor_fin
		WHERE  empresa = pempresa
		AND num_solicitud = pnum_credito ;

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
    --------------------------------------------------------
    --7.-ANTIGUEDAD: (2 NUMEROS)
    --------------------------------------------------------

	SELECT NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2),'')
	INTO   v_antiguedad
	FROM bdinteg:si_cliente a
	WHERE a.numcte = v_numcte;


  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF
    --------------------------------------------------------
    --9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_monto_adeudo >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_monto_adeudo < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(round(v_monto_adeudo),5,'0');
		END IF

	END IF
    --------------------------------------------------------
    --10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_mto_adeudo_venc >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "214";
  		END IF
	ELSE
            --LET v_mto_adeudo_venc = v_mto_adeudo_venc + v_monto_financiado; -- Solictado 19 Nov 2008 MEL
            LET v_mto_adeudo_venc = v_monto_financiado; -- Solictado 20 Nov 2008 MEL
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
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

----- Modifico para Clave de Cobranza ----- RQM 09 117

LET posicion11= round(v_pago_minimo_tc - v_capital_tc);
LET posicion11= lpad( trim(posicion11), 5,'0');

--- Inicio (Inc. 20 Marzo 2009)
LET v_monto_ult_convenio= round(v_monto_ult_convenio);
LET v_monto_ult_convenio= lpad( trim(v_monto_ult_convenio), 5,'0');
--- Fin

LET posicion17= round(v_pago_minimo_tc);
LET posicion17= lpad( trim(posicion17), 5,'0');



    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = v_antiguedad		||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;

      --LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;

	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;
                                                                                    -- ||"/"||v_pago_minimo_tc

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;

    --------------------------------------------------------
    --EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA
    --------------------------------------------------------
	UPDATE sd_encabezado_edocta SET cl_cobra = v_cl_cobranza
	WHERE fecha_emision = pfechahoy
	AND	num_credito = pnum_credito;


  RETURN cod_ret;

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".executaedoctageneral_comple(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno          INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            VARCHAR(255);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;
--------------------------------------------------------
--	INICIALIZACION VARIABLES
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_cat                   = 0; --- CAT
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 100;

--SET DEBUG FILE TO "ExecutaEdoCtaGeneral.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	SET ISOLATION TO DIRTY READ;

	--------------------------------------------------------
	--	GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
  	LET v_id_registro = "000";
	--------------------------------------------------------
	--	GENERA VARIABLES GLOBALES
	-------------------------------------------------------
    ----VALOR DEL CAT

		LET v_cat = 89.90;

    -----MENSAJES DEL ESTADO DE CUENTA

        CREATE TEMP TABLE mensajes(
                clave     serial,
                secuencia integer,
                mensaje   char(101));

        LET v_clave=1;
            FOREACH            
                    SELECT REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
                     FROM bdicred:sd_config_mensaje_edocta order by clave
                     
                     LET v_secuencia=1;

                FOREACH 
                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
                     insert into mensajes values (v_clave,v_secuencia,v_mensajes);
                     LET v_secuencia=v_secuencia+1;
                END FOREACH;

                LET v_clave = v_clave + 1;

            END FOREACH;


 	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 FOREACH 
         select num_credito  
 		    INTO v_num_credito
           from bdicred:sd_maecred 
          where empresa = '001'
            and num_credito in
                ('600005593485',        
                '600012458037',        
                '600015456061',        
                '600016526557',        
                '600016526565',        
                '600016778067',        
                '600017795425',        
                '600018980828',        
                '600020453202')        
		EXECUTE PROCEDURE GeneraEstadosdeCuenta_comple
					(
					'001',
					v_num_credito,
					pfechahoy
					) INTO v_cod_ret;

      	IF v_cod_ret <> "000" THEN

      		SELECT descripcion  INTO v_descripcion
      		FROM bdinteg:si_codret
      		WHERE codigo_retorno = v_cod_ret
      		AND sistema  ="06";

      		INSERT INTO sd_valedocta
      			(
      			empresa,		num_credito,		cod_ret,
      			descripcion,	fecha_proc,			tipo
      			)
      		VALUES
      			(
      			v_empresa,		v_num_credito,		v_cod_ret,
      			v_descripcion,	pfechahoy,			"E"
      			);
           return "999";
		END IF
 	END FOREACH;

    DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE ;
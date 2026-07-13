CREATE PROCEDURE "informix".generaestadosdecuenta_lib (
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
---set lock mode to wait 3;
---set pdqpriority 20;

BEGIN

  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;
        RETURN cod_ret;
	END IF
   END EXCEPTION WITH RESUME ;

-- SET DEBUG FILE TO "generaestadosdecuenta.out";
-- TRACE ON;

   	--##############################################################
	--##	GENERACION ENCABEZADO2 EDO CUENTA				      ##
   	--##############################################################

  -------------------------------------------------------------
	--PERIODO ANTERIOR
  -------------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;


	IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
		LET cod_ret = v_cod_ret_otro;
	END IF

	--PERIODO
	LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
	LET v_periodo_tc_fin = pfechahoy;

	--DIAS DEL PERIODO
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;
    -------------------------------------------------------------
	--SD_MAESDOSHIST
    -------------------------------------------------------------
			-- CAPITAL VENCIDO,PAGO PARA NO GENERAR INTERESES, LIMITE DE CREDITO
	SELECT sdo_cap_insoluto
	  INTO v_usted_debe
	FROM sd_maesdoshist
	WHERE fecha =pfechahoy
	AND empresa = pempresa
	AND num_credito = pnum_credito;
    -------------------------------------------------------------
	--SD_MAESDOSHIST
    -------------------------------------------------------------
			--USTED DEBIA
	SELECT sdo_cap_insoluto	
      INTO v_usted_debia
	FROM sd_maesdoshist
	WHERE fecha = v_periodo_anterior
	AND empresa= pempresa
    AND num_credito = pnum_credito;

    -------------------------------------------------------------
	--BORRA DETALLE
    -------------------------------------------------------------

    delete from sd_detalle_edocta where fecha_emision = pfechahoy and num_credito = pnum_credito;

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
			concepto,			cargos,
			nlinea
		    )
		VALUES(
			pfechahoy,			pnum_credito,
			v_maximo,			"",
			"USTED DEBIA",		NVL(v_usted_debia,0),
			1
		    );
    --------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	FOREACH SELECT 	DAY(a.fecha_mov),			MONTH(a.fecha_mov),
					YEAR(a.fecha_mov),			a.referencia,
					a.referencia23,				a.rfc_comer,
					a.transacc_suc,				a.monto,
--					TRIM(c.descripcion),
					case
                        when usuario = 'BC426807' then 'BONIF. INTERES'
					    when usuario = 'BI426807' then 'BONIF. IVA INTERES.'
                    else TRIM(c.descripcion)
                    end,
                    b.naturaleza,
                DECODE( MONTH(a.fecha_mov),
                		"1","ENE","2","FEB","3","MAR",
                		"4","ABR","5","MAY","6","JUN",
                		"7","JUL","8","AGO","9","SEP",
                		"10","OCT","11","NOV","12","DIC")
	 		INTO    v_dia,					v_mes,
	 				v_ano, 					v_referencia,
	 				v_referencia23,			v_rfc_comer,
	 				v_transacc,				v_monto,
					v_concepto,				v_naturaleza,
					v_letra
			FROM sd_movhisedocta  a
		    INNER JOIN sd_transfun c
				ON a.codigo_fun = c.codigo_fun
				AND a.codigo_ref = c.codigo_ref
				AND  a.empresa = c.empresa
			INNER JOIN  bdinteg:si_transacc b
				ON c.empresa = b.empresa
				AND c.transacc = b.numero
			WHERE  a.empresa = pempresa
				AND a.num_credito = pnum_credito
				AND a.fecha_mov >= v_periodo_tc_ini
				AND a.fecha_mov <= v_periodo_tc_fin
				AND a.reversado = "N"
				AND b.se_emite_edocta = "S"
			ORDER BY a.fecha_mov,a.secuencia



			IF v_monto = 0 THEN
				CONTINUE FOREACH;
			END IF
		    --------------------------------------------------------
		    --      GENERO LA DESCRIPCION DEL MOVIMIENTO
		    --------------------------------------------------------
			IF v_referencia IS NULL THEN
--jom ini sbc
                if trim(v_concepto) = "SU PAGO CON CHEQUE" then
                    LET v_concepto = NVL(TRIM(v_concepto),'') || " " || trim(v_referencia23);
                else
    				LET v_concepto = NVL(TRIM(v_concepto),'');
                end if;
--jom fin sbc
			ELSE
				IF v_referencia[1,1] = "i" THEN
				   LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 18))
				   					|| "  " ||
				   					NVL(TRIM(v_rfc_comer),'')
				   					|| "  " ||
				   					NVL(TRIM(v_referencia23),'');
				   IF v_concepto[1,1] = "i" THEN
						LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 18));
				   END IF
				ELSE
					LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,16]);
				END IF
			END IF
		    --------------------------------------------------------
		    --ARMO LA FECHA DE MOVIMIENTO CON LETRA
		    --------------------------------------------------------
			IF v_mes IS NOT NULL THEN
		     	LET v_fecha_mov = Trim(v_dia)  || "-" ||
		     					  Trim(v_letra)|| "-" ||
		     					  v_ano[3]||v_ano[4];
			END IF
		    --------------------------------------------------------
		    --TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		    --------------------------------------------------------
			IF v_naturaleza IS NOT NULL THEN
				IF v_naturaleza = "A" THEN
					LET v_abono  = v_monto;
				ELSE
					LET v_compra = v_monto;
				END IF;
			ELSE
				LET v_compra = v_monto;
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		    --------------------------------------------------------
			LET v_maximo = v_maximo + 1 ;
			LET v_contador = 0;
		    --------------------------------------------------------
		    --DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		    --------------------------------------------------------

				FOREACH EXECUTE PROCEDURE corta_linea(v_concepto,v_corta_linea_detalle)
				INTO v_concepto, v_corta_retorno

					LET v_contador = v_contador + 1;
					IF v_contador = 1 THEN
						 INSERT INTO sd_detalle_edocta
						 	(
						 	fecha_emision,		num_credito,
						 	secuencia,			fecha_mov,
						 	concepto,			cargos,
							abonos,				nlinea
							)
						VALUES
							(
							pfechahoy,			pnum_credito,
							v_maximo,			v_fecha_mov,
							Trim(v_concepto),	v_compra,
							v_abono,			v_contador
							);
					ELSE
						INSERT INTO sd_detalle_edocta
							(
							fecha_emision,		num_credito,
							secuencia,			concepto,
							nlinea
							)
						VALUES(
							pfechahoy,			pnum_credito,
							v_maximo,			Trim(v_concepto),
							v_contador
							);
					END IF;

				END FOREACH;

		    --------------------------------------------------------
		    --INICIALIZA LAS VARIABLES
		    --------------------------------------------------------
			LET v_fecha_mov    = "";
			LET v_concepto     = "";
			LET v_compra       = "";
			LET v_abono        = "";

	END FOREACH;

    --------------------------------------------------------
    --      GENERA USTED DEBE
    --------------------------------------------------------
    LET v_maximo = v_maximo + 1;
	INSERT INTO sd_detalle_edocta
			(
			fecha_emision,		num_credito,
			secuencia,			fecha_mov,
			concepto,			cargos,
			nlinea
			)
			VALUES
			(
			pfechahoy,			pnum_credito,
			v_maximo,		"",
			"USTED DEBE",		NVL(v_usted_debe,0),
			1
			);

   	--##############################################################
	--##	GENERACION ACLARACIONES	 EDO CUENTA				      ##
   	--##############################################################


  RETURN cod_ret;

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".executaedoctageneral_lib(pempresa CHAR(3),pfechahoy DATE)
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

---SET DEBUG FILE TO "ExecutaEdoCtaGeneral.dbg";
---TRACE ON;

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

	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

	--INSERT INTO sd_movhisedocta
	--	SELECT a.empresa,			a.secuencia,			   a.fecha_mov,
	--		   a.hora_mov,			a.sucursal,                a.num_credito,
	--		   a.plaza,				a.transacc_suc,			   a.usuario,
	--		   a.monto,             a.codigo_fun,			   a.codigo_ref,
	--		   a.divisa,			a.reversado,			   a.folio_suc,
	--		   a.num_producto,      a.nro_tarjeta,			   a.referencia,
	--		   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
	--	       a.rfc_comer,			a.referencia23
    --    FROM sd_movhis a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";

   ---EXECUTE PROCEDURE carga_movhis_edocta (pfechahoy) INTO v_cod_ret;

   ---IF v_cod_ret<> "000" THEN
         ---RETURN v_cod_ret;
   ---END IF;

	SET ISOLATION TO DIRTY READ;


 	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 FOREACH 
          SELECT empresa,num_credito
 			INTO v_empresa,v_num_credito
-- 			FROM bdicred:sd_movhisedocta
--            where empresa = pempresa
--            and codigo_fun = '002'
--            and codigo_ref = 37
            ---and num_credito = '600000005089'
--            group by empresa,num_credito
--            order by num_credito
			FROM bdicred:sd_movhisedocta
            where empresa = pempresa
            and codigo_fun = '002'
            and codigo_ref in (30,40,41,42)
            and num_credito not in 
                  (SELECT num_credito
         			FROM bdicred:sd_movhisedocta
                   where empresa = pempresa
                     and codigo_fun = '002'
                     and codigo_ref = '37'
                group by num_credito)
--            and num_credito = '600000005089'
            group by empresa,num_credito
            order by num_credito


		EXECUTE PROCEDURE generaestadosdecuenta_lib
					(
					v_empresa,
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

		END IF
 	END FOREACH;

    ---DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE ;
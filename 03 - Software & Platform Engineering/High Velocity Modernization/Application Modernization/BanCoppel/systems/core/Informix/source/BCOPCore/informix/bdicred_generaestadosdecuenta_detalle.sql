CREATE PROCEDURE "informix".generaestadosdecuenta_detalle (
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
DEFINE v_corta_linea_mensaje 	INTEGER;
DEFINE v_corta_retorno        INTEGER;
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
DEFINE v_numerocolonia 		INT;		--Numero Colonia Direccion Cliente
DEFINE v_numerocalle 		  INT;		--Numero Calle Direccion Cliente
DEFINE v_numeroextcalle 	CHAR(10);	--Numero Exterior Calle Direccion Cliente
DEFINE v_estado 			    CHAR(2);	--Numero Estado
DEFINE v_nombrecalle		  CHAR(30);	--Nombre Calle Catalogo Calles
DEFINE v_centro				    INT;		--Centro Catalogo de Zonas
DEFINE v_jefegrupozona		INT;		--Clave Jefe Grupo Zona
DEFINE v_supervisorzona		INT;		--Clave Supervisor Zona


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
DEFINE v_periodo_tc_ini   		  DATE;			--periodo_tc_ini
DEFINE v_periodo_tc_fin   		  DATE;			--periodo_tc_fin
DEFINE v_fecha_limite_pago_tc   DATE;			--pago_antes_de
DEFINE v_fecha_corte_tc   		  DATE;			--fecha_corte
DEFINE v_dias_periodo_tc 		    INTEGER;		--dias_periodo_tc
DEFINE v_usted_debia   			    DECIMAL(18,2);	--usted_debia
DEFINE v_sus_abonos   			    DECIMAL(18,2);	--menos_abonos
DEFINE v_sus_compras   			    DECIMAL(18,2);	--mas_compras
DEFINE v_sus_comisiones 		    DECIMAL(18,2);	--sus_comisiones
DEFINE v_dispocisiones  		    DECIMAL(18,2);	--mas_disp_efectivo
DEFINE v_intereses   			      DECIMAL(18,2);	--mas_intereses
DEFINE v_iva   					        DECIMAL(18,2);	--mas_iva
DEFINE v_rendimientos   		    DECIMAL(18,2);	--mas_rendimientos


DEFINE v_iva_comisiones    DECIMAL(18,2);	--mas_iva comisiones
DEFINE v_iva_suc   				 DECIMAL(18,2);	--mas_iva
DEFINE v_sdo_retenido      DECIMAL(18,2);	--SALDO RETENIDO
DEFINE v_fecha_apertura		 DATE;			--fecha de apertura
DEFINE v_periodo_anterior  DATE;			--Fecha Periodo Anterior

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

DEFINE v_moratorios_tcA   	DECIMAL(18,2);	--moratorios_tc
DEFINE v_moratorios_tcB   	DECIMAL(18,2);	--moratorios_tc

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
--	VARIABLES GENERACION  EDO CUENTA
--------------------------------------------------------
DEFINE v_cuenta_mensajes		SMALLINT;
DEFINE v_secuencia_mensaje	SMALLINT;
DEFINE v_nlinea_mensajes		SMALLINT;
DEFINE v_si_paga				    VARCHAR(255);
DEFINE v_mensajes				    VARCHAR(255);

DEFINE v_texto		     		VARCHAR(255);
DEFINE v_factor					  DECIMAL(14,10);
DEFINE v_aplica_factor		DECIMAL(14,2);
DEFINE v_usted_debe				DECIMAL(18,2);

--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
DEFINE v_tasa_mensual		    DECIMAL(18,2);
DEFINE v_tasa_anual			    DECIMAL(18,2);
DEFINE v_cat				        DECIMAL(18,2);
DEFINE v_saldo_promedio		  DECIMAL(18,2);
DEFINE v_tasa_mora			    DECIMAL(18,2); 
DEFINE v_tasa_mensual_mora	DECIMAL(18,2);

DEFINE v_sdo_acum_mes_cap  	DECIMAL(18,2);
DEFINE v_dias_acum_cap     	DECIMAL(18,2);

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
DEFINE v_nivel_eficiencia   CHAR(2);
DEFINE v_fecha_ultimo_pago	DATE;

DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		 VARCHAR(40);
DEFINE v_clave2		 VARCHAR(40);
DEFINE v_clave3		 VARCHAR(40);
DEFINE v_clave4		 VARCHAR(40);
DEFINE v_clave5    VARCHAR(40);

--*******************************************************
--*******************************************************
--*******************************************************

--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
LET cod_ret = "000";
LET v_cod_ret_otro = "000";

LET sql_err = "";
LET v_corta_linea_detalle 	= 30;
LET v_corta_linea_mensaje 	= 100;
LET v_corta_retorno 		    = 0;
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


LET v_iva_comisiones	   = 0;
LET v_iva_suc				     = 0;	--iva sucursal
LET v_sdo_retenido       = 0;
LET v_fecha_apertura	   = " ";	--fecha de apertura
LET v_periodo_anterior   = " ";  --Fecha Periodo Anterior

LET v_capital_debe 		= 0;
LET v_interes_debe 		= 0;
LET v_interes_pagado	= 0;
LET v_iva_debe 				= 0;
LET v_iva_pagado 			= 0;


LET v_mora_sdo_ordi			= 0;
LET v_mora_sdo_ordi_pag	= 0;
LET v_mora_sdo_cope_pag	= 0;
LET v_mora_sdo_cope			= 0;
LET v_mora_provi_ordi		= 0;
LET v_mora_provi_cope		= 0;
LET v_mora_iva_debe			= 0;
LET v_mora_iva_pagado		= 0;
LET v_capital_status		= "";
LET v_fecha_cuota			  = " ";

LET v_moratorios_tcA   	= 0;	--moratorios_tc
LET v_moratorios_tcB   	= 0;	--moratorios_tc

LET v_monto_financiado	= 0;
LET v_campo_trabajo1 		= 0;
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
LET v_monto     	 = 0;


LET v_concepto    = "";
LET v_naturaleza  = "";
LET v_letra       = "";
LET v_fecha_mov   = "";

LET v_compra    	= "";
LET v_abono     	= "";

LET v_maximo      = 0;
LET v_contador    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
--------------------------------------------------------
LET  v_secuencia_aclara	= 0;
LET  v_nlinea_aclara		= 0;
LET  v_fecha_aclara			= " ";
LET  v_descripcion			= "";
LET  v_importe				  = 0;
--------------------------------------------------------
--	VARIABLES GENERACION MENSAJES EDO CUENTA
--------------------------------------------------------
LET v_cuenta_mensajes 		= 0;
LET  v_secuencia_mensaje	= 0;
LET  v_nlinea_mensajes		= 0;
LET  v_si_paga				    = 0;
LET  v_mensajes				    = "";

LET v_texto 		    = "";
LET v_factor		    = 0;
LET v_aplica_factor = 0;
LET v_usted_debe    = 0;
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
LET v_tasa_mensual 		  = 0 ;
LET v_tasa_anual		    = 0 ;
LET v_cat				        = 0 ;
LET v_saldo_promedio	  = 0 ;
LET v_tasa_mora			    = 0 ;
LET v_tasa_mensual_mora	= 0 ;

LET v_sdo_acum_mes_cap  = 0;
LET v_dias_acum_cap     = 0;
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

LET v_salario          = 0;
LET v_monto_adeudo		 = 0;
LET v_mto_adeudo_venc  = 0;


LET v_clave1	= "";
LET v_clave2	= "";
LET v_clave3	= "";
LET v_clave4	= "";
LET v_clave5  = "";



BEGIN

  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;	    
	END IF
   END EXCEPTION WITH RESUME ;


   	--##############################################################
		--##	GENERACION ENCABEZADO EDO CUENTA				      ##
   	--##############################################################	
    -------------------------------------------------------------
    --SD_MAECRED
    -------------------------------------------------------------
	SELECT a.numcte,		a.sucursal,			a.fecha_apertura,
		   a.tasa_interes,	a.tasa_moratorios,
		   DECODE(status_cred,'AA','0','BA','1','BT','2','0'),
		   status_cred
        INTO v_numcte,		v_sucursal,			v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           v_avisos,v_status_cred
	FROM sd_maecred a
	WHERE a.empresa = pempresa
	AND a.num_credito = pnum_credito;

    -------------------------------------------------------------
    -- Solicitud de Resta de Tasa Moratoria - la Tasa Ordinaria 
    -------------------------------------------------------------
      LET  v_tasa_mora = v_tasa_mora - v_tasa_anual;
      IF v_tasa_mora < 0 THEN
         LET v_tasa_mora = v_tasa_mora * -1;
      END IF

    -------------------------------------------------------------
    --SD_TARJETA
    -------------------------------------------------------------
	SELECT b.num_tarjeta INTO v_num_tarjeta
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
	  	SELECT b.num_tarjeta INTO v_num_tarjeta
	  	FROM sd_tarjeta b
 	 	WHERE b.empresa = pempresa
		    AND b.num_credito = pnum_credito		    
		    AND b.secuencia = v_ult_dir_clie; 
		    
    END IF  
    -------------------------------------------------------------
	--SI_DIRECCIONES
    -------------------------------------------------------------
	SELECT MAX(secuencia) INTO v_ult_dir_clie
	FROM bdinteg:si_direcciones
		WHERE numcte = v_numcte
		AND tipo_dir="1";
    -------------------------------------------------------------
	--SI_CLIENTE
    -------------------------------------------------------------
	SELECT Trim(a.nombre1) || " " ||Trim(a.nombre2) || " " ||
		   Trim(a.apell_paterno) || " " ||Trim(a.apell_materno),
	       a.rfc,
	       NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2),'')
	INTO 	v_nombre_cte,
			v_rfc,
			v_antiguedad
	FROM bdinteg:si_cliente a
	WHERE a.numcte = v_numcte;
    -------------------------------------------------------------
	--SI_DIRECCIONES
    -------------------------------------------------------------
	SELECT Trim(b.numeroextcalle) || " " || Trim(b.numerointcalle),
	       b.cod_postal,			b.entre_calles,			
	       b.observaciones,		   	b.numerociudad,
	       b.numerocolonia,			b.numerocalle,
	       b.numeroextcalle,	    b.estado
	INTO v_direccion_cn,
		   v_cod_postal,			v_entre_calles,
		   v_observaciones,		    v_numerociudad,
		   v_numerocolonia,			v_numerocalle,
		   v_numeroextcalle,		v_estado
	FROM bdinteg:si_direcciones b
	WHERE b.numcte  = v_numcte AND secuencia = v_ult_dir_clie;
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
	SELECT d.nombrezona,			d.centro,
		   d.jefegrupozona,			d.supervisorzona
	INTO v_direccion_col,			v_centro,
		   v_jefegrupozona,			v_supervisorzona
	FROM bdinteg:si_catzonas d
	WHERE  d.numerociudad = v_numerociudad
	AND  d.numerocolonia=v_numerocolonia;
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
    -------------------------------------------------------------
	--SI_SUCURSALES
    -------------------------------------------------------------
	SELECT d.nombre,				d.gerente,			
		   d.telefono1,		   		d.iva -- iva de moratorios
		INTO v_sucursal_nombre,		v_sucursal_gerente,	
		   v_sucursal_tel, 		    v_iva_suc
	FROM bdinteg:si_sucursales d
	WHERE d.empresa = pempresa
		AND   d.sucursal    = v_sucursal;
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
	LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
			     LPAD(v_centro,6,'0')||"/"||
			     LPAD(v_jefegrupozona,8,'0')||"/"||
			     LPAD(v_supervisorzona,8,'0')||"/"||
			     LPAD(v_numerocolonia,4,'0')||"/"||
			     LPAD(v_numerocalle,6,'0')||"/"||
			     LPAD(TRIM(v_numeroextcalle),5,'0');
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
--     INSERT INTO sd_encabezado_edocta
--     				(
--     				fecha_emision,		num_credito,
--     				numcte,				num_tarjeta,
--     				nombre_cte,			direccion_cn,
---				    direccion_col,		direccion_del,
--				    edo_cd,	        	sucursal_nombre,
--				    sucursal_gerente,	sucursal_tel,
--				    fecha_corte,		rfc,
--				    cl_cobra,			CP,
--				    ruta,				entre_calles,
--				    observaciones
--				    )
--	  		 VALUES(
--	  		       	pfechahoy,							pnum_credito,
--	  		       	NVL(Trim(v_numcte),''),				NVL(Trim(v_num_tarjeta),''),
--	  		       	NVL(Trim(v_nombre_cte),''),			NVL(Trim(v_direccion_cn),''),
--	  		       	NVL(Trim(v_direccion_col),''),		NVL(Trim(v_direccion_del),''),
--	  		       	NVL(Trim(v_edo_cd),''),				NVL(Trim(v_sucursal_nombre),''),
--	  		       	NVL(Trim(v_sucursal_gerente),''),	NVL(Trim(v_sucursal_tel),''),
--	  		       	pfechahoy,							NVL(Trim(v_rfc),''),
--  		       	NVL(TRIM(v_cl_cobra),''),			NVL(Trim(v_cod_postal),''),
--	  		       	NVL(TRIM(v_ruta),''),				NVL(TRIM(v_entre_calles),''),
--				    NVL(TRIM(v_observaciones),'')
--				    );

   	--##############################################################
	--##	GENERACION ENCABEZADO2 EDO CUENTA				      ##
   	--##############################################################	
    -------------------------------------------------------------
	--SD_AMORTIZA_CREDITO	
    -------------------------------------------------------------
	FOREACH	SELECT 	capital_debe,			interes_debe,			interes_pagado,
					iva_debe,				iva_pagado,				mora_sdo_ordi,
					mora_sdo_ordi_pag,		mora_sdo_cope_pag,		mora_sdo_cope,
					mora_provi_ordi,		mora_provi_cope,		mora_iva_debe,
					mora_iva_pagado,		capital_status,			fecha_cuota,
					campo_trabajo1
			INTO	v_capital_debe,			v_interes_debe,			v_interes_pagado,
					v_iva_debe,				v_iva_pagado,			v_mora_sdo_ordi,
					v_mora_sdo_ordi_pag,	v_mora_sdo_cope_pag,	v_mora_sdo_cope,
					v_mora_provi_ordi,		v_mora_provi_cope,		v_mora_iva_debe,
					v_mora_iva_pagado,		v_capital_status,		v_fecha_cuota,
					v_campo_trabajo1
			FROM sd_amortiza_credito
			WHERE empresa = pempresa
			AND num_credito = pnum_credito 

			-- CAPITAL,INTERES, IVA DE INTERES
			IF v_fecha_cuota = pfechahoy THEN
				LET v_interes_tc = v_interes_debe;
				LET v_iva_interes_tc = v_iva_debe;
				LET v_iva_interes_ven_tc = v_campo_trabajo1;
			END IF

			-- INTERES VENCIDO, IVA VENCIDO,MORATORIO
			IF v_capital_status IN ("2","7") THEN
				LET v_cuantos_avisos = v_cuantos_avisos + 1;
			END IF

			-- IVA DE MORATORIOS
	END FOREACH;
    
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
	SELECT monto_vencido + mto_venc_trasp,			sdo_cap_insoluto,
		   monto_otorgado,							sdo_retenido,
		   sdo_acum_mes_cap,						dias_acum_cap,
		   NVL(sdo_cap_insoluto,0),			NVL(monto_vencido,0) + NVL(mto_venc_trasp,0),
		   NVL(int_tra_no_exig,0),							NVL(sdo_moratorio,0) + NVL(sdo_contab_mora,0),
		   monto_financiado
		INTO v_capital_ven_tc,					v_interes_pago_total_tc,
		   v_limite_tc,								v_sdo_retenido,
		   v_sdo_acum_mes_cap,						v_dias_acum_cap,
		   v_monto_adeudo,							v_mto_adeudo_venc,
		   v_interes_ven_tc,v_moratorios_tc,
		   v_monto_financiado
	FROM sd_maesdoshist 
	WHERE fecha =pfechahoy  
	AND empresa = pempresa
	AND num_credito = pnum_credito;
    -------------------------------------------------------------
	--SD_MAESDOSHIST
    -------------------------------------------------------------
			--USTED DEBIA
	SELECT sdo_cap_insoluto	INTO v_usted_debia
	FROM sd_maesdoshist
	WHERE fecha = v_periodo_anterior
	AND empresa= pempresa
    AND num_credito = pnum_credito;
    -------------------------------------------------------------
	--SD_MAECREDANEXO
    -------------------------------------------------------------
			--FECHA LIMITE DE PAGO
	SELECT prox_fecha_pago INTO v_fecha_limite_pago_tc
	FROM sd_maecredanexo 
	WHERE empresa = pempresa AND num_credito = pnum_credito; 
	
			--FECHA PAGO INMEDIATA
	IF v_capital_ven_tc > 0 THEN
		LET v_fecha_limite_pago_tc =  DATE(1);
	END IF
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
	SELECT 	SUM(CASE WHEN codigo_fun   IN ('033','334')  THEN
			CASE WHEN codigo_ref = 1  THEN  monto ELSE 0 END
			ELSE  0 END), 	--MENOS SUS ABONOS
			SUM(CASE WHEN codigo_fun   = '002' THEN
			CASE WHEN codigo_ref = 37  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS SUS COMPRAS
			SUM(CASE WHEN codigo_fun   = '339' THEN
			CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19)  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS COMISIONES
			SUM(CASE WHEN codigo_fun   = '002' THEN
			CASE WHEN codigo_ref IN (30,50,40,41,42)  THEN  monto ELSE 0 END 
			ELSE  0 END),	--MAS DISPOSICIONES EM EFECTIVO
			SUM(CASE WHEN codigo_fun   = '605' THEN
			CASE WHEN codigo_ref = 2  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS INTERESES
			SUM(CASE WHEN codigo_fun   = '605'  THEN
			CASE WHEN codigo_ref = 3  THEN  monto ELSE 0 END
			ELSE  0 END) , --MAS IVA INTERESES
			SUM(CASE WHEN codigo_fun   = '340'  THEN
			CASE WHEN codigo_ref = 1  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS IVA COMISONES
			MAX(fecha_mov)-- FECHA ULTIMO PAGO
	INTO 	v_sus_abonos,
			v_sus_compras,
			v_sus_comisiones,
			v_dispocisiones,
		 	v_intereses,
		 	v_iva,
		 	v_iva_comisiones,
		 	v_fecha_ultimo_pago
	FROM   	sd_movhisedocta
	WHERE  	empresa = pempresa
	AND num_credito = pnum_credito
	AND fecha_mov >= v_periodo_tc_ini
	AND fecha_mov <= v_periodo_tc_fin
	AND reversado <> "S";
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------

		LET v_capital_tc = v_monto_financiado - v_capital_ven_tc;
	
		--IVA COMISIONES MAS IVA INTERESES
		LET v_iva = v_iva + v_iva_comisiones;
		
		--MORATORIOS
		--LET v_moratorios_tc = v_moratorios_tcA + v_moratorios_tcB;
		
		
		LET v_iva_moratorios_tc = v_moratorios_tc * v_iva_suc;
		
		IF  (v_iva_moratorios_tc  IS NULL) OR (v_iva_moratorios_tc < 0) or (v_iva_moratorios_tc <= 0) THEN
			LET v_iva_moratorios_tc = 0;
		END IF
	
		--CALCULO DEL INTERES VENCIDO
		
		IF v_status_cred = "BT" THEN
			LET v_interes_ven_tc = v_interes_ven_tc - v_interes_tc;
		ELSE
			LET v_interes_ven_tc = 0;
		END IF

		-- PAGO MINIMO
		LET v_pago_minimo_tc = NVL(v_capital_tc,0)  + NVL(v_capital_ven_tc,0)  +
							   NVL(v_interes_ven_tc ,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0) ;
		
		--USTED DEBE
		LET v_usted_debe = v_interes_pago_total_tc;
		
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
									NVL(v_interes_ven_tc ,0) + NVL(v_iva_interes_ven_tc ,0) + NVL(v_moratorios_tc,0)  + NVL(v_iva_moratorios_tc,0);
		
		IF v_interes_pago_total_tc < 0 THEN
			LET v_interes_pago_total_tc = 0;
		END IF
		--FECHA DE CORTE
		LET v_fecha_corte_tc = pfechahoy;

		IF (v_fecha_apertura = v_periodo_tc_fin) THEN
			LET v_iva = 0;
			LET v_intereses = 0;
		ELSE
			LET v_iva = NVL(v_iva,0);
			LET v_intereses = NVL(v_intereses,0);
		END IF
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
--	INSERT INTO sd_encabezado2_edocta 
--				(
--				fecha_emision,			num_credito,
--				capital_tc,				interes_tc,
--				iva_interes_tc,			capital_ven_tc,
--				interes_ven_tc,			iva_interes_ven_tc,
--				moratorios_tc,			iva_moratorios_tc,
--				sdo_pagar,				interes_pago_total_tc,
--				limite_tc,				sdo_disponible,
--				periodo_tc_ini,			periodo_tc_fin,
--				pago_antes_de,			fecha_corte,
--				dias_periodo_tc,		usted_debia,
--				menos_abonos,			mas_compras,
--				sus_comisiones,			mas_disp_efectivo,
--				mas_intereses,			mas_iva,
--				mas_rendimientos,		sdo_debe,
--				menos_o_abonos,			mas_o_cargos,
--				usted_debe,				mensajes 
--				)
--		VALUES (
--				pfechahoy,					TRIM(pnum_credito),
--				NVL(v_capital_tc,0),		NVL(v_interes_tc,0),
--				NVL(v_iva_interes_tc,0),	NVL(v_capital_ven_tc,0),
--				NVL(v_interes_ven_tc,0),	NVL(v_iva_interes_ven_tc,0),
--				NVL(v_moratorios_tc,0),		NVL(v_iva_moratorios_tc,0),
--				NVL(v_pago_minimo_tc,0),	NVL(v_interes_pago_total_tc,0),
--				NVL(v_limite_tc,0),			NVL(v_disponible_tc,0),
--				v_periodo_tc_ini,			v_periodo_tc_fin,
--				v_fecha_limite_pago_tc,		v_fecha_corte_tc,
--				NVL(v_dias_periodo_tc,0),	NVL(v_usted_debia,0),
--				NVL(v_sus_abonos,0),		NVL(v_sus_compras,0),
--				NVL(v_sus_comisiones,0),	NVL(v_dispocisiones,0),
--				NVL(v_intereses,0),			NVL(v_iva,0),
--				NVL(v_rendimientos,0),		0,
--				0,							0,
--				0,							""
--				);


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
					TRIM(c.descripcion),		b.naturaleza,
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
				AND b.sistema = "06"
				AND a.reversado <> "S"
				AND b.se_emite_edocta = "S"
			ORDER BY a.fecha_mov,a.secuencia


	
			IF v_monto = 0 THEN
				CONTINUE FOREACH;
			END IF
		    --------------------------------------------------------
		    --      GENERO LA DESCRIPCION DEL MOVIMIENTO
		    --------------------------------------------------------
			IF v_referencia IS NULL THEN
				LET v_concepto = NVL(TRIM(v_concepto),'');
			ELSE
				IF v_referencia[1,8] = "intercar" THEN
				   LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 16))
				   					|| "  " ||
				   					NVL(TRIM(v_rfc_comer),'')
				   					|| "  " ||
				   					NVL(TRIM(v_referencia23),'');
				   IF v_concepto[1,8] = "intercar" THEN
						LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 16));
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


   	--##############################################################
	--##	GENERACION MENSAJES	 EDO CUENTA				          ##
   	--##############################################################

	 SELECT valor::DECIMAL(14,10) INTO v_factor 
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
	 END IF
	 
	 
--   FOREACH  SELECT REPLACE(mensajes,'{0}',TRIM(v_aplica_factor::VARCHAR(21))) INTO v_texto
--	   		 FROM bdicred:sd_config_mensaje_edocta order by clave
--	   
--  
--	
--    LET v_secuencia_mensaje = v_secuencia_mensaje + 1 ;
--		LET v_nlinea_mensajes = 0;
--		
--		
--		FOREACH EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
--
--					LET v_nlinea_mensajes = v_nlinea_mensajes + 1;
--		
--					IF v_secuencia_mensaje = 2 AND v_nlinea_mensajes = 1 THEN
--						INSERT INTO sd_mensajes_edocta 
--							(
--							fecha_emision, 		num_credito, 
--							secuencia,			nlinea,
--							si_paga, 			mensajes
--							)
--						VALUES 
--							(
--							pfechahoy,				TRIM(pnum_credito),
--							v_secuencia_mensaje,	v_nlinea_mensajes,
--							v_si_paga,				v_mensajes
--							);
--					ELSE					
--						INSERT INTO sd_mensajes_edocta 
--							(
--							fecha_emision, 		num_credito, 
--							secuencia,			nlinea,
--							si_paga, 			mensajes
--							)
--						VALUES 
--							(
--							pfechahoy,				TRIM(pnum_credito),
--							v_secuencia_mensaje,	v_nlinea_mensajes,
--							NULL,					v_mensajes
--							);
--					END IF;
--
--		END FOREACH;  
--
--    END FOREACH;


   	--##############################################################
	--##	GENERACION   PIE	 EDO CUENTA				          ##
   	--##############################################################
   	LET v_tasa_mensual   = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = v_tasa_mora / 12;
	
	SELECT valor INTO v_cat
	FROM sd_param
	WHERE empresa = pempresa
	AND cod_param = '034';

	IF v_cat IS NULL THEN
		LET v_cat = 69.58;
	END IF

	IF v_dias_acum_cap > 0 THEN
		LET  v_saldo_promedio = (v_sdo_acum_mes_cap / v_dias_acum_cap);
	ELSE
		LET v_saldo_promedio = 0;
	END IF;
	
	--------------------------------------------------------
    --	GENERA EL PIE DEL ESTADO DE CUENTA
    --------------------------------------------------------
--	INSERT INTO sd_pie_edocta
--			(
--			fecha_emision,			num_credito,
--			tasa_mensual,			tasa_anual,
--			cat,					saldo_promedio,
--			tasa_mora,				tasa_mensual_mora,
--			dias_periodo
--			)
--	VALUES
--			(
--			pfechahoy,				pnum_credito,
--			NVL(v_tasa_mensual,0),	NVL(v_tasa_anual,0),
--			NVL(v_cat,0),			NVL(v_saldo_promedio,0),
--			NVL(v_tasa_mora,0),		NVL(v_tasa_mensual_mora,0),
--			0
--			);
			
   	--##############################################################
	--##	GENERACION  CLAVE DE COBRANZA				          ##
   	--##############################################################
    --------------------------------------------------------
    --	1.--TIPO DE CLIENTE: (2 Numero)
    --------------------------------------------------------
    --------------------------------------------------------
    --	2.--SITUACION ESPECIAL: (1 letra)
    --------------------------------------------------------
    SELECT FIRST 1 situacion INTO v_situacion 
    FROM bdisitesp:se_ctessitespcte 
    WHERE numcte = v_numcte;
    
    
    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF

    --------------------------------------------------------
    --	2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087
    --------------------------------------------------------
    SELECT FIRST 1 causa INTO v_situacion_esp
    FROM bdisitesp:se_ctessitespcte 
    WHERE numcte = v_numcte;
    
    
    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "---";
    END IF
    
		
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
			LET v_mto_tot_adeudo = LPAD(0,5,'0');
		ELSE
			LET v_mto_tot_adeudo = LPAD(v_monto_adeudo::INTEGER::VARCHAR(5),5,'0');
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
    FOREACH SELECT FIRST 1 importe,TO_CHAR(fecha_compac,"%m%y")
	    INTO v_monto_ult_convenio , v_fecha_ult_convenio
	    FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa 
	    AND numcliente = v_numcte ORDER BY fecha_compac DESC
    
    	EXIT FOREACH;
    END FOREACH;
    
    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
			LET v_monto_ult_convenio =  LPAD("0",5,'0');
		END IF
		--------------------------------------------------------
    --13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)
    --------------------------------------------------------
    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
			LET v_fecha_ult_convenio =  "NDND";
		END IF
		
    --------------------------------------------------------
    --14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)
    --------------------------------------------------------
    FOREACH SELECT FIRST 1 'P'
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
    --------------------------------------------------------
    --15.-NUMERO DE AVISOS: (1 LETRA)
    --------------------------------------------------------
	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos >= 5 THEN
		LET v_avisos =  "4";
	END IF;

	IF v_cuantos_avisos = 0 OR v_cuantos_avisos = 1 OR v_cuantos_avisos = 2 THEN
		LET v_nivel_eficiencia = "01";
    ELIF v_cuantos_avisos = 3 THEN
		LET v_nivel_eficiencia = "02";
	ELIF v_cuantos_avisos = 4 THEN
		LET v_nivel_eficiencia = "03";
    ELIF v_cuantos_avisos = 5 OR v_cuantos_avisos = 6 THEN
		LET v_nivel_eficiencia = "04";
	ELIF v_cuantos_avisos > 6 THEN
		LET v_nivel_eficiencia = "05";
	END IF; 
	
    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = v_antiguedad		||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos  ;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;

    --------------------------------------------------------
    --EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA
    --------------------------------------------------------
--	UPDATE sd_encabezado_edocta SET cl_cobra = v_cl_cobranza
--	WHERE fecha_emision = pfechahoy 
--	AND	num_credito = pnum_credito;
	
  RETURN cod_ret;

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".movimientos_edocta (pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE, pNumRegistros SMALLINT)
	RETURNING CHAR(5), 
				DATE , 
			 CHAR(20), 
			 SMALLINT,
			 SMALLINT, 
			  CHAR(9), 
			CHAR(255),
			 CHAR(16),
			 CHAR(16);
		 
	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	DEFINE cod_ret             		CHAR(5);
	DEFINE sql_err             		INTEGER;
	DEFINE v_cod_ret_otro			CHAR(5);

	DEFINE v_corta_linea_detalle 	INTEGER;
	DEFINE v_corta_linea_detalle2 	INTEGER;
	DEFINE v_corta_linea_mensaje 	INTEGER;


	DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
	DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc

	DEFINE v_periodo_tc_ini   		DATE;			--periodo_tc_ini
	DEFINE v_periodo_tc_fin   		DATE;			--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	DEFINE v_dia           		CHAR(2);
	DEFINE v_mes           		CHAR(2);
	DEFINE v_ano	       		CHAR(4);
	DEFINE v_referencia    		CHAR(296);
	DEFINE v_referencia23  		CHAR(279);
	DEFINE v_rfc_comer     		CHAR(276);
	DEFINE v_transacc      		CHAR(4);
	DEFINE v_monto         		DECIMAL(18,2);

	DEFINE v_concepto      		VARCHAR(255);
	DEFINE v_naturaleza    		CHAR(1);
	DEFINE v_letra         		CHAR(15);
	DEFINE v_fecha_mov     		CHAR(12);

	DEFINE v_compra	       		DECIMAL(18,2);
	DEFINE v_abono	       		DECIMAL(18,2);

	DEFINE v_maximo        		INTEGER;
	DEFINE v_contador      		SMALLINT;

	DEFINE v_Registros    		SMALLINT;
	DEFINE vfechacentral 		DATE;

	DEFINE iexists				INTEGER;	-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	DEFINE cfecAper				DATE;		-- FECHA DE APERTURA DEL CREDITO
	DEFINE cDiaCorte			CHAR(2);	-- DIA DE CORTE DEL CREDITO
	DEFINE cFecInicio			CHAR(10);	-- FECHA DE INICIO DEL PERIODO DE CONSULTA	

	--*******************************************************
	--*******************************************************
	--*******************************************************

	--------------------------------------------------------
	--	VARIABLES CONTROL DE ERRORES
	--------------------------------------------------------
	LET cod_ret = "000";
	LET v_cod_ret_otro = "000";

	LET sql_err = "";
	LET v_corta_linea_detalle 	= 30;
	LET v_corta_linea_detalle2 	= 0;
	LET v_corta_linea_mensaje 	= 100;

	LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
	LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc

	LET v_periodo_tc_ini   		= " ";	--periodo_tc_ini
	LET v_periodo_tc_fin   		= " ";	--periodo_tc_fin

	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	LET vfechacentral  = NULL;
	LET v_dia          = "";
	LET v_mes          = "";
	LET v_ano	   	   = "";
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


	LET v_Registros    = 0;

	LET iexists		   = 1;		-- BANDERA DE SI SE LE GENERO UN CORTE O NO 
	LET cfecAper	   = '';	-- FECHA DE APERTURA DEL CREDITO
	LET cDiaCorte	   = '';	-- DIA DE CORTE DEL CREDITO
	LET cFecInicio	   = '';	-- FECHA DE INICIO DEL PERIODO DE CONSULTA


	-- SET DEBUG FILE TO "/tmp/cab/movimientos_edocta.out";
	-- TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err
		LET cod_ret = sql_err;
		RETURN cod_ret, vfechacentral,	pnum_credito, v_maximo, v_contador,	v_fecha_mov, v_concepto, v_compra, v_abono;
	END EXCEPTION ;

	-------------------------------------------------------------
	--PERIODO ANTERIOR	
	-------------------------------------------------------------	

   -- LET cod_ret = "741";
   -- RETURN cod_ret, vfechacentral,	pnum_credito, v_maximo, v_contador,	v_fecha_mov, v_concepto, v_compra, v_abono;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
    
	-- se obtiene la fecha hoy
	SELECT fecha_hoy 
	  INTO vfechacentral 
	  FROM bdicred:"informix".sd_fechas
	 WHERE empresa = '001';
	
	-- se obtiene el dia de corte
	SELECT dia_corte
	  INTO cDiaCorte
	  FROM bdicred:"informix".sd_maecredanexo
	 WHERE empresa = '001' 
	   AND num_credito = pnum_credito;
	   
	-- se le suma un dia al dia de corte
	LET cDiaCorte = cDiaCorte::INTEGER + 1;
	 
	-- se valida si el dia de la fecha hoy es mayor al dia de corte
	IF DAY(vfechacentral) > cDiaCorte THEN
	
		-- se une el mes de la fecha de hoy + el nuevo dia de corte + el año de la fecha de hoy
		LET v_periodo_tc_ini = LPAD(MONTH(vfechacentral), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(vfechacentral);
	
	-- se valida si el dia de la fecha de hoy es menor o igual al dia de corte
	ELIF DAY(vfechacentral) <= cDiaCorte THEN
	
		-- se le resta un mes a la fecha de hoy
		EXECUTE PROCEDURE bdicred:"informix".monthadd(vfechacentral, -1)
					 INTO cFecInicio;
		
		-- se une el mes de la fecha de hoy menos 1 mes + el nuevo dia de corte + el año de la fecha de hoy menos 1 mes
		LET v_periodo_tc_ini = LPAD(MONTH(cFecInicio), 2, '0') || '-' || LPAD(cDiaCorte, 2, '0')  || '-' || YEAR(cFecInicio);
	
	END IF;	
			
	-- se asigna la fecha de final de consulta igual a la fecha de hoy
	LET v_periodo_tc_fin = vfechacentral;
	
   	--##############################################################
	--##	GENERACION DETALLE	 EDO CUENTA				          ##
   	--##############################################################
   	   
		--------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	
	FOREACH WITH HOLD 
		SELECT DAY(a.fecha_mov), MONTH(a.fecha_mov), YEAR(a.fecha_mov), REPLACE(a.referencia,"'",""), a.referencia23, a.rfc_comer, a.transacc_suc, a.monto,
			   TRIM(c.descripcion), b.naturaleza, 
			   DECODE(MONTH(a.fecha_mov), "1", "ENE", "2", "FEB", "3", "MAR", "4", "ABR", "5", "MAY", "6", "JUN", "7", "JUL", "8", "AGO", "9", "SEP", "10", "OCT", "11", "NOV", "12", "DIC")
		  INTO v_dia, v_mes, v_ano, v_referencia, v_referencia23, v_rfc_comer, v_transacc, v_monto, 
			   v_concepto, v_naturaleza,
			   v_letra
		  FROM bdicred:"informix".sd_movhis a
    INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
		 WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND b.sistema = "06"  ---Se agrega el campo sistema 
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
 	 UNION ALL
		SELECT DAY(a.fecha_mov), MONTH(a.fecha_mov), YEAR(a.fecha_mov), REPLACE(a.referencia,"'",""), a.referencia23, a.rfc_comer, a.transacc_suc, a.monto,
			    TRIM(c.descripcion), b.naturaleza,
			   DECODE( MONTH(a.fecha_mov), "1", "ENE", "2", "FEB", "3", "MAR", "4", "ABR", "5", "MAY", "6", "JUN", "7", "JUL", "8", "AGO", "9", "SEP", "10", "OCT", "11", "NOV", "12", "DIC")
		  FROM bdicred:"informix".sd_movdia a
	INNER JOIN bdicred:"informix".sd_transfun c ON TRIM(a.codigo_fun)||a.codigo_ref = TRIM(c.codigo_fun)||c.codigo_ref AND a.empresa = c.empresa
	INNER JOIN bdinteg:"informix".si_transacc b ON c.empresa = b.empresa AND c.transacc = b.numero
	     WHERE a.empresa = pempresa
		   AND a.fecha_mov >= v_periodo_tc_ini
		   AND a.fecha_mov <= v_periodo_tc_fin
		   AND a.num_credito = pnum_credito
		   AND b.sistema = "06"  ---Se agrega el campo sistema 
		   AND a.reversado <> "S"
		   AND b.se_emite_edocta = "S"
	  ORDER BY 3,2,1
	
		IF v_monto = 0 THEN
			CONTINUE FOREACH;
		END IF;
		
		--------------------------------------------------------
		--		GENERO LA DESCRIPCION DEL MOVIMIENTO
		--------------------------------------------------------
		
		IF v_referencia IS NULL THEN
			LET v_concepto = NVL(TRIM(v_concepto),'');
		ELSE
			IF v_referencia[1,8] = "intercar" THEN
				LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 16)) || "  " || NVL(TRIM(v_rfc_comer),'') || "  " || NVL(TRIM(v_referencia23),'');
				IF v_concepto[1,8] = "intercar" THEN
					LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 16));
				END IF;
			ELIF (TRIM(SUBSTRING(v_referencia FROM 18)) = 'a') or (TRIM(SUBSTRING(v_referencia FROM 18)) = 'DISVENT') OR (TRIM(SUBSTRING(v_referencia FROM 18)) = '') THEN
				LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,16]);
				
			ELSE
				LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 18)) || "  " || NVL(TRIM(v_rfc_comer),'') || "  " || NVL(TRIM(v_referencia23),'');
			END IF;
		END IF;

		--------------------------------------------------------
		--		ARMO LA FECHA DE MOVIMIENTO CON LETRA
		--------------------------------------------------------

		IF v_mes IS NOT NULL THEN
			LET v_fecha_mov = TRIM(v_dia)  || "-" || TRIM(v_letra)|| "-" || v_ano[3]||v_ano[4];
		END IF;
		
		--------------------------------------------------------
		--		TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
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
		--		TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		--------------------------------------------------------
		
		LET v_maximo = v_maximo + 1 ;
		LET v_contador = 0;

		--------------------------------------------------------
		--		DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		--------------------------------------------------------

		FOREACH
			EXECUTE PROCEDURE bdicred:"informix".corta_linea(v_concepto, v_corta_linea_detalle) 
						 INTO v_concepto, v_corta_linea_detalle2
			
			LET v_contador = v_contador + 1;
			LET v_Registros = v_Registros + 1;
			
			IF v_Registros <= pNumRegistros THEN
				CONTINUE FOREACH;
			END IF;

			IF v_contador = 1 THEN
				RETURN cod_ret, pfechahoy, NVL(pnum_credito, ""), NVL(v_maximo, 0), NVL(v_contador, 0), NVL(v_fecha_mov, ""), NVL(v_concepto, ""),
					   NVL(v_compra, ""), NVL(v_abono, "") WITH RESUME;
			ELSE
				RETURN cod_ret, pfechahoy, NVL(pnum_credito, ""), NVL(v_maximo, 0), NVL(v_contador, 0), "", NVL(v_concepto, ""),
					   "", "" WITH RESUME;
			END IF;
		END FOREACH;

		--------------------------------------------------------
		--		INICIALIZA LAS VARIABLES
		--------------------------------------------------------

		LET v_fecha_mov    = "";
		LET v_concepto     = "";
		LET v_compra       = "";
		LET v_abono        = "";

	END FOREACH;
END;
END PROCEDURE
DOCUMENT
'AUTOR: ???',
'DESCRIPCION: Genera la consulta de movimientos de credito',
'FECHA: ???',
'MODIFICO: Clemente Angulo Ballardo',
'DESCRIPCION: Se modifica para que obtenga o calcule la fecha inicial del periodo de consulta',
'VERSION: 20100709.1156';

CREATE PROCEDURE "informix".sp_inserta_conciliador_cred_vs_conta(cFecha date, cCC char(14),vSdoConta Money(18,2),vsdoCargosConta Money(18,2), vsdoAbonosConta Money(18,2), vSdoFinDia Money(18,2), vsdoAbonos Money(18,2), vsdoCargos Money(18,2), vDescripcion char(50), cTipoProd integer)

--------------------------------------------------------------------
--DOCUMENTACIÓN
--inserta en la tabla sd_conciliacredito, los cargos, abonos, saldo inicio y saldo final
--Realizó: Richar 
--Fecha: 07/07/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura
							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5) as codret;    

	DEFINE cCodRet 		CHAR(5);			
	DEFINE vDiferencia	MONEY(18,2);
	DEFINE vDiferenciaAbono	MONEY(18,2);
	DEFINE vDiferenciaCargo	MONEY(18,2);	
	DEFINE vProducto	CHAR(30);
	
	
	
			--SET DEBUG FILE TO "sp_inserta_conciliador_cred_vs_conta.out";
			--TRACE ON;
			  
	set isolation to dirty read;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	
	LET cCodRet = '00001';
	LET vDiferencia = 0;
	LET vDiferenciaAbono = 0;
	LET vDiferenciaCargo = 0;

					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;					  
				  
		if cTipoProd=1 then
			LET vProducto = 'Tarjeta de credito';
		elif cTipoProd=2 then
			LET vProducto = 'Credinomina';
		elif cTipoProd=3 then 
			LET vProducto = 'Prestamo Personal';
		elif cTipoProd=4 then 
			LET vProducto = 'Reestructura';
			
		End if;
		
					delete from bdicred:sd_conciliacredito where nivelcontable=cCC;
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
					  values(trim(vProducto),vDescripcion,cCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
					  
				if cTipoProd=3 and cCC ='77106102020132' then --and (cCC ='13110202020032' or cCC ='77106102020132')
					
					select NVL(sdoperativo-sdocontable,0)
					into vDiferencia
					from sd_conciliacredito
					where nivelcontable='13110202020032';
					
					--Restamos 
					update sd_conciliacredito set sdoperativo= (sdoperativo - vDiferencia) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdoperativo= (sdoperativo + vDiferencia) where nivelcontable='77106102020132';
					
					--sacamos diferencias
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='13110202020032';
					update sd_conciliacredito set sdodif=(sdoperativo-sdocontable) where nivelcontable='77106102020132';			
				End if;
	END;
		
	END PROCEDURE;
CREATE PROCEDURE "informix".sp_encabezado_calculo_tdc (
				pempresa CHAR(3),
				pnum_credito CHAR(20),
				pperiodo DATE)
RETURNING CHAR(5) as cod_ret,
--------------------------------------------------------
--	ENCABEZADO GENERALES
--------------------------------------------------------

CHAR(20)  as v_numcte,            --Numero de Credito
CHAR(20)  as  v_num_tarjeta,	  --Numero de Tarjeta
CHAR(150) as  v_nombre_cte,	      --Nombre del Cliente
CHAR(456) as  v_direccion_cn,	  --Direccion
CHAR(376) as  v_direccion_col,	  --Colonia
CHAR(376) as  v_direccion_del,	  --Delegacion O Municipio
CHAR(376) as  v_edo_cd,	          --Estado
CHAR(40)  as  v_sucursal_nombre,  --Nombre de la Sucursal
CHAR(40)  as  v_sucursal_gerente, --Nombre del Gerente del Sucursal
CHAR(14)  as  v_sucursal_tel,	  --Telefono de la Sucursal
CHAR(5)   as  v_cod_postal,		  --Codigo Postal Direccion Cliente
CHAR(60)  as  v_cl_cobra,	      --Clave de Cobranza
CHAR(13)  as  v_rfc,	          --RFC del Cliente
CHAR(47)  as  v_ruta,	          --Ruta
CHAR(40)  as  v_entre_calles,	  --Entre Calles
CHAR(80)  as  v_observaciones,	  --Datos Complementarios

SMALLINT  as  v_numerociudad,	  --Numero Ciudad Direccion Cliente
INT       as  v_numerocolonia,    --Numero Colonia Direccion Cliente
INT       as  v_numerocalle,   	  --Numero Calle Direccion Cliente
CHAR(10)  as  v_numeroextcalle,	  --Numero Exterior Calle Direccion Cliente
CHAR(2)   as  v_estado,	          --Numero Estado
CHAR(30)  as  v_nombrecalle,	  --Nombre Calle Catalogo Calles
INT       as  v_centro,   		  --Centro Catalogo de Zonas
INT       as  v_jefegrupozona,    --Clave Jefe Grupo Zona
INT       as  v_supervisorzona,   --Clave Supervisor Zona
integer   as  v_numerociudadcoppel,	--Numero Ciudad Direccion Cliente
integer   as  v_numerocoloniacoppel, --Numero Colonia Direccion Cliente
--------------------------------------------------------
--	GENERACION ENCABEZADO2 EDO CUENTA
--------------------------------------------------------
DECIMAL(18,2)  as  v_capital_tc,	         --capital_tc
DECIMAL(18,2)  as  v_interes_tc,	         --interes_tc
DECIMAL(18,2)  as  v_iva_interes_tc,	     --iva_interes_tc
DECIMAL(18,2)  as  v_capital_ven_tc,	     --capital_ven_tc
DECIMAL(18,2)  as  v_interes_ven_tc,	     --interes_ven_tc
DECIMAL(18,2)  as  v_iva_interes_ven_tc,	 --iva_interes_ven_tc
DECIMAL(18,2)  as  v_moratorios_tc,	         --moratorios_tc
DECIMAL(18,2)  as  v_iva_moratorios_tc,	     --iva_moratorios_tc
DECIMAL(18,2)  as  v_pago_minimo_tc,	     --sdo_pagar
DECIMAL(18,2)  as  v_interes_pago_total_tc,  --interes_pago_total_tc
DECIMAL(18,2)  as  v_limite_tc,           	 --limite_tc
DECIMAL(18,2)  as  v_disponible_tc,	         --sdo_disponible
DATE           as  v_periodo_tc_ini,	  	 --periodo_tc_ini
DATE           as  v_periodo_tc_fin,	  	 --periodo_tc_fin
DATE           as  v_fecha_limite_pago_tc,	 --pago_antes_de
DATE           as  v_fecha_corte_tc,		 --fecha_corte
INTEGER        as  v_dias_periodo_tc,		 --dias_periodo_tc
DECIMAL(18,2)  as  v_usted_debia,	         --usted_debia
DECIMAL(18,2)  as  v_sus_abonos,	         --menos_abonos
DECIMAL(18,2)  as  v_sus_compras,	         --mas_compras
DECIMAL(18,2)  as  v_sus_comisiones,	     --sus_comisiones
DECIMAL(18,2)  as  v_dispocisiones,	         --mas_disp_efectivo
DECIMAL(18,2)  as  v_intereses,	             --mas_intereses
DECIMAL(18,2)  as  v_iva,	                 --mas_iva
DECIMAL(18,2)  as  v_rendimientos,	         --mas_rendimientos
DECIMAL(18,2)  as  v_comisiones_sbc,	     --mas_comisiones_sbc
DECIMAL(18,2)  as  v_iva_comisiones_sbc,     --mas_iva_comisiones_sbc
DECIMAL(18,2)  as  v_comis_repos,            --comision por reposicion
DECIMAL(18,2)  as  v_iva_comisiones,	     --mas_iva comisiones
DECIMAL(18,2)  as  v_iva_suc,	             --mas_iva
DECIMAL(18,2)  as  v_sdo_retenido,	         --SALDO RETENIDO
DATE           as  v_fecha_apertura,		 --fecha de apertura
DATE           as  v_periodo_anterior,		 --Fecha Periodo Anterior
--------------------------------------------------------
--	VARIABLES GENERACION PIE EDO CUENTA
--------------------------------------------------------
DECIMAL(18,2)  as  v_tasa_mensual,       -- tasa mensual  
DECIMAL(18,2)  as  v_tasa_anual,         -- tasa anual 
DECIMAL(18,2)  as  v_saldo_promedio,     -- saldo promedio
DECIMAL(18,2)  as  v_tasa_mora,          -- tasa moratoria anual
DECIMAL(18,2)  as  v_tasa_mensual_mora,  -- tasa moratoria mensual

DECIMAL(18,2)  as  v_sdo_acum_mes_cap,   -- suma interes diario 
DECIMAL(18,2)  as  v_dias_acum_cap       -- dias del periodo


--DEFINE GLOBAL v_cat			DECIMAL(18,2) DEFAULT 0;
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
DEFINE vimportereclamado     DECIMAL(14,2);

-- VARIABLES PARA CREDISOLUCIONES - HASS
DEFINE v_dif_saldo_diferido		DECIMAL(18,2);
DEFINE v_dif_dias_periodo		INTEGER;
DEFINE v_dif_fecha_movto   	  	DATE;
DEFINE vfechaband  	  	        SMALLINT;
DEFINE v_dif_fecha_proxima		DATE;
DEFINE v_dif_fec_prox_cargo		CHAR(9);
DEFINE v_dif_monto				DECIMAL(18,2);
DEFINE v_dif_concepto			CHAR(255);
DEFINE v_dif_num_pagos			CHAR(5);
DEFINE v_dif_num_promo			INTEGER;
DEFINE v_dif_prestamo			CHAR(20);
DEFINE v_dif_folio_apertura		CHAR(16);
DEFINE v_dif_plazo				SMALLINT;
DEFINE v_dif_num_cuota			SMALLINT;
DEFINE v_dif_monto_proxcargo	DECIMAL(18,2);
DEFINE v_dif_secuencia			SMALLINT;


--SET DEBUG FILE TO '/informix/sp_encabezado_calculo_tdc.out';
--TRACE ON;


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

-- VARIABLES PARA CREDISOLUCIONES - HASS
LET v_dif_saldo_diferido	= 0.0;
LET v_dif_dias_periodo		= 0;
LET v_dif_fecha_movto   	= DATE(1);
LET vfechaband     	        = 0;
LET v_dif_fecha_proxima		= DATE(1);
LET v_dif_fec_prox_cargo	= '';
LET v_dif_monto				= 0.0;
LET v_dif_concepto			= '';
LET v_dif_num_pagos			= '';
LET v_dif_num_promo			= 0;
LET v_dif_prestamo			= '';
LET v_dif_folio_apertura	= '';
LET v_dif_plazo				= 0;
LET v_dif_num_cuota			= 0;
LET v_dif_monto_proxcargo	= 0.0;
LET v_dif_secuencia			= 0;



set isolation to dirty read;
set lock mode to wait 3;

BEGIN

  ON EXCEPTION SET sql_err
	IF sql_err <> 0 THEN
	    LET cod_ret = sql_err;
        RETURN cod_ret,v_numcte,v_num_tarjeta,v_nombre_cte,v_direccion_cn,v_direccion_col,v_direccion_del,v_edo_cd,v_sucursal_nombre,v_sucursal_gerente,v_sucursal_tel,v_cod_postal,
v_cl_cobra,v_rfc, v_ruta, v_entre_calles, v_observaciones, v_numerociudad, v_numerocolonia, v_numerocalle,v_numeroextcalle, v_estado,v_nombrecalle, v_centro,
v_jefegrupozona,v_supervisorzona,v_numerociudadcoppel,v_numerocoloniacoppel,v_capital_tc, v_interes_tc, v_iva_interes_tc, v_capital_ven_tc, v_interes_ven_tc,
v_iva_interes_ven_tc,v_moratorios_tc,v_iva_moratorios_tc,v_pago_minimo_tc,v_interes_pago_total_tc,v_limite_tc,v_disponible_tc,v_periodo_tc_ini,v_periodo_tc_fin,
v_fecha_limite_pago_tc, v_fecha_corte_tc, v_dias_periodo_tc, v_usted_debia, v_sus_abonos, v_sus_compras, v_sus_comisiones, v_dispocisiones, v_intereses, v_iva,
v_rendimientos,v_comisiones_sbc,v_iva_comisiones_sbc,V_comis_repos,v_iva_comisiones,v_iva_suc,v_sdo_retenido,v_fecha_apertura,v_periodo_anterior,v_tasa_mensual,
v_tasa_anual,v_saldo_promedio,v_tasa_mora,v_tasa_mensual_mora,v_sdo_acum_mes_cap,v_dias_acum_cap;

	END IF
   END EXCEPTION WITH RESUME ;

 --SET DEBUG FILE TO "generaestadosdecuenta.out";
 --TRACE ON;


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
	SELECT a.num_producto, a.numcte,	a.sucursal,	a.fecha_apertura,
		   a.tasa_interes,	a.tasa_moratorios,
		   DECODE(status_cred,'AA','0','BA','1','BT','2','0'),
		   status_cred
        INTO v_numprod, v_numcte, v_sucursal, v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           v_avisos, v_status_cred
	FROM sd_maecred a
	WHERE a.empresa = pempresa
	AND a.num_credito = pnum_credito;
--	LET v_tasa_anual=63.75;
--	LET v_tasa_mora=99.75;

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
	       b.observaciones,		b.numerociudad,
	       b.numerocolonia,		b.numerocalle,
	       b.numeroextcalle,	b.estado
	INTO v_direccion_cn,
		   v_cod_postal,			v_entre_calles,
		   v_observaciones,		v_numerociudad,
		   v_numerocolonia,		v_numerocalle,
		   v_numeroextcalle,	v_estado
--	FROM bdinteg:si_direcciones b
	FROM bdinteg:si_direcciones_actual b
	WHERE b.numcte  = v_numcte AND tipo_dir="1";
--  AND secuencia = v_ult_dir_clie;
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
		   d.jefegrupozona,			d.supervisorzona,
-- Jom ini catalogos
           d.numerociudadcoppel,     d.numerocoloniacoppel
-- Jom fin catalogos
	INTO v_direccion_col,			v_centro,
		  v_jefegrupozona,			v_supervisorzona,
-- Jom ini catalogos
          v_numerociudadcoppel, v_numerocoloniacoppel
-- Jom fin catalogos
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
    -------------------------------------------------------------
	--SI_SUCURSALES
    -------------------------------------------------------------
	SELECT d.nombre,	d.gerente,
		   d.telefono1,	d.iva -- iva de moratorios
		INTO v_sucursal_nombre,	v_sucursal_gerente,
		     v_sucursal_tel, 		v_iva_suc
	FROM bdinteg:si_sucursales d
	WHERE d.empresa = pempresa
		AND d.sucursal    = v_sucursal;
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
-- Jom ini catalogos

    IF (v_numerociudadcoppel IS NULL)  THEN LET v_numerociudadcoppel = '0000'; END IF;
    IF (v_centro IS NULL)              THEN LET v_centro = '000000'; END IF;
    IF (v_jefegrupozona IS NULL)       THEN LET v_jefegrupozona = '00000000'; END IF;
    IF (v_supervisorzona IS NULL)      THEN LET v_supervisorzona = '00000000'; END IF;
    IF (v_numerocoloniacoppel IS NULL) THEN LET v_numerocoloniacoppel = '0000'; END IF;
    IF (v_numerocalle IS NULL)         THEN LET v_numerocalle = '000000'; END IF;
    IF (v_numeroextcalle IS NULL)      THEN LET v_numeroextcalle = '00000'; END IF;

--	LET v_ruta = LPAD(v_numerociudad,4,'0')||"/"||
	LET v_ruta = LPAD(v_numerociudadcoppel,4,'0')||"/"||
			     LPAD(v_centro,6,'0')||"/"||
			     LPAD(v_jefegrupozona,8,'0')||"/"||
			     LPAD(v_supervisorzona,8,'0')||"/"||
--			     LPAD(v_numerocolonia,4,'0')||"/"||
			     LPAD(v_numerocoloniacoppel,4,'0')||"/"||
-- Jom fin catalogos
			     LPAD(v_numerocalle,6,'0')||"/"||
			     LPAD(TRIM(v_numeroextcalle),5,'0');
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------

    -------------------------------------------------------
    --                   Se obtiene el inserto               --
    -------------------------------------------------------

     SELECT insertos
       INTO cInserto
       FROM bdicred:sd_marcaje
      WHERE empresa=pempresa
        AND num_credito= pnum_credito
        and fecha_emision = pperiodo;

       IF cInserto IS NULL THEN
          LET cInserto='000000000000000';
       END IF;
    -----------------------------------------------------------

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
           AND fecha_cuota=pperiodo;

		LET v_interes_tc = v_interes_debe;
		LET v_iva_interes_tc = v_iva_debe;
		LET v_iva_interes_ven_tc = v_campo_trabajo1;


        SELECT 	count(*) INTO v_cuantos_avisos
        FROM sd_amortiza_credito
        WHERE empresa = pempresa
        AND num_credito = pnum_credito
        AND capital_status IN ("2","7");


  -------------------------------------------------------------
	--PERIODO ANTERIOR
  -------------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;


	IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
		LET cod_ret = v_cod_ret_otro;
	END IF

	--PERIODO
	LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
	LET v_periodo_tc_fin = pperiodo;

	--DIAS DEL PERIODO
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;
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
	WHERE fecha =pperiodo
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
	SELECT 	SUM(CASE WHEN codigo_fun   IN (select cod_fun from bdicred:sd_conceptospagomanual)  THEN --se agregan aplicacion de pago
			CASE WHEN codigo_ref = 1  THEN  monto ELSE 0 END
			ELSE  0 END), 	--MENOS SUS ABONOS
			SUM(CASE WHEN codigo_fun   = '002' THEN
			CASE WHEN codigo_ref in (37,57)  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS SUS COMPRAS
			SUM(CASE WHEN codigo_fun   = '339' THEN
			CASE WHEN codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95) THEN monto ELSE 0 END -- Se agregan SURCHARGE
			ELSE  0 END),	--MAS COMISIONES
			SUM(CASE WHEN codigo_fun   = '002' THEN
			CASE WHEN codigo_ref IN (30,50,40,41,42,60,61,62,63,64,65)  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS DISPOSICIONES EN EFECTIVO
			SUM(CASE WHEN codigo_fun   = '605' THEN
			CASE WHEN codigo_ref = 2  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS INTERESES
			SUM(CASE WHEN codigo_fun   = '605'  THEN
			CASE WHEN codigo_ref = 3  THEN  monto ELSE 0 END
			ELSE  0 END) , --MAS IVA INTERESES
			SUM(CASE WHEN codigo_fun   = '340'  THEN
			CASE WHEN codigo_ref IN (1,2)  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS IVA COMISONES
-- jom ini SBC
			SUM(CASE WHEN codigo_fun   = '336'  THEN
			CASE WHEN codigo_ref = 23  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS COMISONES SBC
			SUM(CASE WHEN codigo_fun   = '336'  THEN
			CASE WHEN codigo_ref = 24  THEN  monto ELSE 0 END
			ELSE  0 END),	--MAS IVA SBC
-- jom fin SBC
-- JOM REPOS INI
			SUM(CASE WHEN codigo_fun   = '033'  THEN
			CASE WHEN codigo_ref = 6212  THEN  monto ELSE 0 END
			ELSE  0 END),	--COMISION REPOSICION
-- JOM REPOS FIN
			MAX(fecha_mov)-- FECHA ULTIMO PAGO
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
		 	v_fecha_ultimo_pago
	FROM   	sd_movhis
	WHERE  	empresa = pempresa
		AND num_credito = pnum_credito
		AND fecha_mov BETWEEN v_periodo_tc_ini AND pperiodo;
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
--INICIO-----LHM--GRAFICA DE BARRAS
	     LET v_intereses_iva = NVL(v_iva,0);
--FIN-----LHM--GRAFICA DE BARRAS

-- jom ini SBC
        LET v_sus_comisiones = NVL(v_sus_comisiones,0) + NVL(v_comisiones_sbc,0) + NVL(V_comis_repos,0);

		LET v_capital_tc = NVL(v_monto_financiado,0) - NVL(v_capital_ven_tc,0);

		--IVA COMISIONES MAS IVA INTERESES
		LET v_iva = NVL(v_iva,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0);
-- jom fin SBC
		--MORATORIOS
		--LET v_moratorios_tc = v_moratorios_tcA + v_moratorios_tcB;

        IF v_moratorios_tc <= 0 then let v_moratorios_tc = 0; end if;

		LET v_iva_moratorios_tc = v_moratorios_tc * v_iva_suc;

		IF  (v_iva_moratorios_tc  IS NULL) OR (v_iva_moratorios_tc < 0) or (v_iva_moratorios_tc <= 0) THEN
			LET v_iva_moratorios_tc = 0;
		END IF

		--CALCULO DEL INTERES VENCIDO

        IF (v_interes_ven_tc - v_interes_tc >= 0) then
            LET v_interes_ven_tc = v_interes_ven_tc - v_interes_tc;
		END IF

--		IF v_status_cred = "BT" THEN
--			LET v_interes_ven_tc = v_interes_ven_tc - v_interes_tc;
--		END IF

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
		LET v_fecha_corte_tc = pperiodo;

		IF (v_fecha_apertura = v_periodo_tc_fin) THEN
			LET v_iva = 0;
			LET v_intereses = 0;
		ELSE
			LET v_iva = NVL(v_iva,0);
			LET v_intereses = NVL(v_intereses,0);
		END IF

--INICIO-----LHM--GRAFICA DE BARRAS
        LET v_comisiones_iva = NVL(v_sus_comisiones,0) + NVL(v_iva_comisiones,0) + NVL(v_iva_comisiones_sbc,0);
        LET v_intereses_iva = nvl(v_intereses,0) + NVL(v_intereses_iva,0);
        LET v_saldos_menos_pag = NVL(v_usted_debia,0);
        IF v_saldos_menos_pag < 0 THEN
            LET v_saldos_menos_pag = 0;
        END IF
        LET v_compras_disp = NVL(v_sus_compras,0) + NVL(v_dispocisiones,0);
		LET v_intereses_pag = NVL(v_intereses,0);
--FIN--------LHM

		-- OBTIENE EL SALDO DIFERIDO
		SELECT SUM(monto_actual + monto_int_iva)
		INTO v_dif_saldo_diferido
		FROM bdicred:'informix'.sd_promocion_credito
		WHERE num_credito = pnum_credito
		AND status = 2;

			
--INICIO--HAS
   	--##############################################################
	--##	GENERACION DETALLE	 SALDOS DIFERIDOS		          ##
   	--##############################################################
	-- INICIA CICLO PARA BARRER LAS PROMOCIONES VIGENTES
	FOREACH WITH HOLD
		SELECT num_promo, num_sol_prestamo, folio_suc, plazo, (monto_actual+monto_int_iva)
		INTO v_dif_num_promo, v_dif_prestamo, v_dif_folio_apertura, v_dif_plazo, v_dif_monto
		FROM bdicred:'informix'.sd_promocion_credito
		WHERE status = 2
          AND num_credito = pnum_credito

		-- OBTIENE EL NUMERO DE CUOTAS
		SELECT COUNT(fecha_cuota)
		  INTO v_dif_num_cuota
		  FROM bdicred:'informix'.sd_amortiza_creditocrd 
		 WHERE num_credito = v_dif_prestamo;

		LET v_dif_num_cuota = NVL(v_dif_num_cuota,0);
		-- VALIDA SI ES LA PRIMERA CUOTA

		IF v_dif_num_cuota = 1 THEN

			SELECT fecha_cuota, nvl(capital_mto_cuota,0)
 			  INTO v_dif_fecha_movto, v_dif_monto_proxcargo
			  FROM bdicred:'informix'.sd_amortiza_creditocrd 
			 WHERE num_credito = v_dif_prestamo
			   AND capital_status = 5;

                IF v_dif_monto_proxcargo = 0 OR v_dif_monto_proxcargo is null OR v_dif_monto_proxcargo = "" THEN
                    SELECT fecha_cuota, nvl(capital_mto_cuota,0)
                      INTO v_dif_fecha_movto, v_dif_monto_proxcargo
                      FROM bdicred:'informix'.sd_amortiza_creditocrd 
                     WHERE num_credito = v_dif_prestamo
                       AND capital_status = 3;
                       LET vfechaband = 1;
                END IF;


		ELIF v_dif_num_cuota > 1 THEN
			-- OBTIENE LA FECHA DE LA CUOTA PAGADA MAS NUEVA
			SELECT MAX(fecha_cuota)
			  INTO v_dif_fecha_movto
			  FROM bdicred:'informix'.sd_amortiza_creditocrd 
			 WHERE num_credito = v_dif_prestamo
			   AND capital_status = 5;
			LET v_dif_monto = 0.0;

			SELECT capital_mto_cuota
 			  INTO v_dif_monto
			  FROM bdicred:'informix'.sd_amortiza_creditocrd 
			 WHERE num_credito = v_dif_prestamo
			   AND fecha_cuota = v_dif_fecha_movto
			   AND capital_status = 5;
			   LET v_dif_monto_proxcargo = v_dif_monto;
		END IF

		-- OBTIENE LA DEL SIGUIENTE MES A PARTIR DE LA FECHA DE LA CUOTA
                IF vfechaband = 0 THEN
                    EXECUTE PROCEDURE 'informix'.sp_mes_siguiente (v_dif_fecha_movto,1,DAY(v_dif_fecha_movto))
                    INTO v_cod_ret_otro, v_dif_fecha_proxima, v_dif_dias_periodo;
                ELSE
                    LET v_dif_fecha_proxima = v_dif_fecha_movto;
                END IF;    

		-- FORMATEA LA FECHA EN DD-MMM-AA
		LET v_dif_fec_prox_cargo = LPAD(DAY(v_dif_fecha_proxima),2,'0') || '-' || DECODE(MONTH(v_dif_fecha_proxima),1,'ENE',2,'FEB',3,'MAR',4,'ABR',5,'MAY',6,'JUN',7,'JUL',8,'AGO',9,'SEP',10,'OCT',11,'NOV',12,'DIC') || '-' || LPAD(MONTH(v_dif_fecha_proxima),2,'0');
		-- OBTIENE EL CONCEPTO DE LA PROMOCION A PARTIR DEL NUMERO DE LA PROMOCION Y DEL FOLIO DE LA APERTURA
		IF v_dif_num_promo = 1 THEN
			LET v_dif_concepto = 'CREDIEFECTIVO' || " FOLIO: " || v_dif_folio_apertura;
		ELIF v_dif_num_promo = 2 THEN
			LET v_dif_concepto = 'CREDICOMPRAS' || " FOLIO: " || v_dif_folio_apertura;
		ELIF v_dif_num_promo = 3 THEN
			LET v_dif_concepto = 'CREDISALDOSTDC' || " FOLIO: " || v_dif_folio_apertura;
		END IF
		-- SE OBTIENE LA ETIQUETA DEL NUMERO DE PAGOS
		LET v_dif_num_pagos = v_dif_num_cuota::VARCHAR(3) || '/' || v_dif_plazo::VARCHAR(3);

		LET v_dif_secuencia = v_dif_secuencia + 1;
		
	/*	INSERT INTO bdicred:"informix".sd_detalle_dif_edocta
		(fecha_emision, num_credito, secuencia, nlinea, fecha_prox_cargo, concepto, cargos, numero_pagos, monto_prox_pago) 
		VALUES (pperiodo, pnum_credito, v_dif_secuencia, 1, v_dif_fec_prox_cargo, v_dif_concepto, v_dif_monto, v_dif_num_pagos, v_dif_monto_proxcargo);
	*/
        LET vfechaband = 0;
	END FOREACH
--FIN--HAS

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

  RETURN cod_ret,v_numcte,v_num_tarjeta,v_nombre_cte,v_direccion_cn,v_direccion_col,v_direccion_del,v_edo_cd,v_sucursal_nombre,v_sucursal_gerente,v_sucursal_tel,v_cod_postal,
v_cl_cobra,v_rfc, v_ruta, v_entre_calles, v_observaciones, v_numerociudad, v_numerocolonia, v_numerocalle,v_numeroextcalle, v_estado,v_nombrecalle, v_centro,
v_jefegrupozona,v_supervisorzona,v_numerociudadcoppel,v_numerocoloniacoppel,v_capital_tc, v_interes_tc, v_iva_interes_tc, v_capital_ven_tc, v_interes_ven_tc,
v_iva_interes_ven_tc,v_moratorios_tc,v_iva_moratorios_tc,v_pago_minimo_tc,v_interes_pago_total_tc,v_limite_tc,v_disponible_tc,v_periodo_tc_ini,v_periodo_tc_fin,
v_fecha_limite_pago_tc, v_fecha_corte_tc, v_dias_periodo_tc, v_usted_debia, v_sus_abonos, v_sus_compras, v_sus_comisiones, v_dispocisiones, v_intereses, v_iva,
v_rendimientos,v_comisiones_sbc,v_iva_comisiones_sbc,V_comis_repos,v_iva_comisiones,v_iva_suc,v_sdo_retenido,v_fecha_apertura,v_periodo_anterior,v_tasa_mensual,
v_tasa_anual,v_saldo_promedio,v_tasa_mora,v_tasa_mensual_mora,v_sdo_acum_mes_cap,v_dias_acum_cap;

END;

END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".sp_descarga_info_edocta()
RETURNING CHAR(5);

DEFINE v_ruta             VARCHAR(255);
DEFINE v_ruta_cfd         VARCHAR(255);
DEFINE cod_ret            CHAR(5);
DEFINE sql_err            INTEGER;
DEFINE v_sql              CHAR(1000);
DEFINE v_sql1             CHAR(200);
DEFINE v_sql2             CHAR(700);
DEFINE dFecha_hoy         DATE;
DEFINE v_periodo_tc_ini   DATE;	  		--periodo_tc_ini
DEFINE cEmpresa           CHAR(3);


LET v_ruta            = "";
LET v_sql             = "";
LET v_sql1            = "";
LET v_sql2            = "";
LET v_periodo_tc_ini  = " ";	--periodo_tc_ini
LET dFecha_hoy        = date(1);
LET cEmpresa          = '001';
LET cod_ret           = "00000";
   
set isolation to dirty read;
set lock mode to wait 3;

-- Fecha: 27/11/2014
-- Autor: Marco A. Campos
-- Descripción: Descargar ciertos campos en un archivo .unl para cargarlos en una tabla y que sea leída en el sp_rep_regulatorios_irb_compl 

--  SET DEBUG FILE TO 'sp_descarga_info_edocta.out';
--  TRACE ON;

 
BEGIN

   ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;            
            RETURN cod_ret;
        END IF
   END EXCEPTION;


   
   -- /RESPALDOS/infoedocta/ 
   SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = cEmpresa AND cod_param = '039';
   
   select fecha_hoy into dFecha_hoy
     from bdicred:"informix".sd_fechas
    where empresa = '001';

--Temporal solo para pruebas
	--let dFecha_hoy = today;
--Temporal solo para pruebas

   LET v_periodo_tc_ini = lpad(month(dFecha_hoy),2,0) ||  '/20/' || year(dFecha_hoy) ;

--Temporal solo para pruebas
	--let v_periodo_tc_ini = v_periodo_tc_ini - 1 units month;
--let v_periodo_tc_ini = mdy('10','20','2017'); 
--Temporal solo para pruebas

   
	 LET v_sql1 = ' echo "UNLOAD TO '||trim(v_ruta)||'edocta_muestra.unl ';
	 LET v_sql2 = ' SELECT a.fecha_emision, a.num_credito, a.sdo_pagar, a.sdo_debe, a.interes_pago_total_tc, a.sdo_disponible, a.menos_abonos, a.mas_compras, ' ||
	                      'a.mas_disp_efectivo, a.mas_intereses, a.saldo_total, b.tasa_anual, a.interes_ven_tc, a.interes_tc, b.saldo_promedio, ' ||
                          'a.capital_tc,a.iva_interes_tc,a.capital_ven_tc,a.iva_interes_ven_tc,a.moratorios_tc,a.iva_moratorios_tc,a.saldo_corte,a.comisionxcobrar ' ||
                  ' FROM bdicred@pld_tcp:sd_encabezado2_edocta a, bdicred@pld_tcp:sd_pie_edocta b ' || 
--                  ' FROM bdicred:sd_encabezado2_edocta a, bdicred:sd_pie_edocta b ' || --Pruebas
				          ' where a.fecha_emision = b.fecha_emision ' ||
				            ' and a.fecha_emision = ''' || v_periodo_tc_ini || '''' ||
				            ' and a.num_credito = b.num_credito ' || '" >' ||trim(v_ruta)|| 'queryme.sql ';
    
    LET v_sql = trim(v_sql1) || ' ' || trim(v_sql2); 

   system trim(v_sql);

   LET v_sql = '';
	 LET v_sql = "dbaccess bdicred " ||trim(v_ruta)|| "queryme.sql";
	 system trim(v_sql);

   LET v_sql = '';
   LET v_sql = "rm "|| trim(v_ruta) ||'queryme.sql';
   SYSTEM trim(v_sql);

 

  END;
  RETURN cod_ret;

END PROCEDURE;
CREATE PROCEDURE "informix".generaedosctacrd_pp(pempresa CHAR(3), pnum_credito CHAR(20), pfechahoy DATE)  
--EXECUTE PROCEDURE generaedosctacrd_pp('001','760001933257',mdy('03','18','2020')); 




RETURNING CHAR(6);

--     VARIABLES CONTROL DE ERRORES     --
DEFINE cod_ret             		CHAR(6);
DEFINE sql_err             		INTEGER;
DEFINE v_cod_ret_otro			CHAR(6);
--     VARIABLES GENERALES      --
DEFINE v_status_cred	        CHAR(2);        --Status Credito
DEFINE v_num_aper_ant           CHAR(20);       --NumeroAperturaAntesdeReestructura
DEFINE v_plazo                  INTEGER;        --plazo
DEFINE v_numerociudad 	        SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocolonia 	        INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerociudadCoppel     SMALLINT;       --Numero Ciudad Direccion Cliente
DEFINE v_numerocoloniaCoppel    INT;		    --Numero Colonia Direccion Cliente
DEFINE v_numerocalle 	        INT;		    --Numero Calle Direccion Cliente
DEFINE v_numeroextcalle         CHAR(10);       --Numero Exterior Calle Direccion Cliente
DEFINE v_estado 		        CHAR(2);	    --Numero Estado
DEFINE v_nombrecalle	        CHAR(30);       --Nombre Calle Catalogo Calles
DEFINE v_centro			        INT;		    --Centro Catalogo de Zonas
DEFINE v_jefegrupozona	        INT;		    --Clave Jefe Grupo Zona
DEFINE v_supervisorzona	        INT;		    --Clave Supervisor Zona
DEFINE v_iva_suc   		        DECIMAL(18,2);  --Mas_iva
DEFINE v_capital_debe 	        DECIMAL(14,2);  --Capital_Debe
DEFINE v_interes_debe 	        DECIMAL(14,2);  --Interes_Debe
DEFINE v_iva_debe 		        DECIMAL(14,2);  --Iva_Debe
DEFINE v_num_pago               INTEGER;        --Numero_pago_tc
DEFINE v_usted_debe_tc          DECIMAL(18,2);  --Usted_Debe_General
DEFINE v_maximo        		    INTEGER;        --Secuencia
DEFINE v_fecha_ultimo_pago_aux  DATE;           --Fecha Ultimo Pago
DEFINE v_aplica_factor			DECIMAL(14,2);  --Aplica_Factor
DEFINE v_periodo_anterior  	    DATE;			--Fecha Periodo Anterior
DEFINE v_periodo_prox  	        DATE;			--Fecha Periodo Anterior
--	    VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
DEFINE v_numcte                 CHAR(20);	   --Numero de Credito
DEFINE v_nombre_cte             CHAR(150);	   --Nombre del Cliente
DEFINE v_direccion_cn           CHAR(456);	   --Direccion
DEFINE v_direccion_col          CHAR(376);	   --Colonia
DEFINE v_direccion_del          CHAR(376);	   --Delegacion O Municipio
DEFINE v_edo_cd                 CHAR(376);	   --Estado
DEFINE v_cl_cobra               CHAR(60);	   --Clave de Cobranza
DEFINE v_sucursal               CHAR(4);  	   --Sucursal Cliente
DEFINE v_sucursal_nombre        CHAR(40);	   --Nombre de la Sucursal
DEFINE v_sucursal_gerente       CHAR(40);	   --Nombre del Gerente del Sucursal
DEFINE v_rfc                    CHAR(13);	   --RFC del Cliente
DEFINE v_sucursal_tel           CHAR(14);	   --Telefono de la Sucursal
DEFINE v_cod_postal             CHAR(5);	   --Codigo Postal Direccion Cliente
DEFINE v_ruta          	        CHAR(47);	   --Ruta
DEFINE v_entre_calles           CHAR(40);	   --Entre Calles
DEFINE v_observaciones          CHAR(80);	   --Datos Complementarios
DEFINE cInserto                 CHAR(15);      --Informacion del Inserto
DEFINE cCuentaEfec              CHAR(20);      -- Cuenta efectiva asociada al credito
DEFINE v_SalarioMinimoCoppel  SMALLINT;        -- Salario minimo coppel
DEFINE v_confirmacion			CHAR(5);	   --Confirmacion para CFDI 
DEFINE cNomProducto				CHAR(40);	   --PP Flexible 

--	    VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
DEFINE v_capital_tc   		    DECIMAL(14,2);	--Capital_tc
DEFINE v_iva_interes_tc   	    DECIMAL(14,2);	--Iva_Interes_tc
DEFINE v_num_pago_c             CHAR(9);        --Numero_pago_tc con la union del plazo xx/xx
DEFINE v_cap_mto_cuota          DECIMAL(14,2);  --Monto_Pago
DEFINE v_interes_vigente        DECIMAL(14,2);  --Interes vigente
DEFINE v_iva_vigente            DECIMAL(14,2);  --IVA DE INTERES VIGENTE
DEFINE v_capital_vencido        DECIMAL(14,2);  --Capital_Ven_tc
DEFINE v_interes_vencido        DECIMAL(14,2);  --Interes_Ven_tc
DEFINE v_iva_vencido            DECIMAL(14,2);  --Iva_Interes_Ven_tc
DEFINE v_moratorio              DECIMAL(14,2);  --Moratorios
DEFINE v_iva_moratorio          DECIMAL(14,2);  --iva_Moratorios
DEFINE v_pagototal              DECIMAL(14,2);  --Pago_Total_tc
DEFINE v_fecha_limite_pago_tc   DATE;			--Fecha_Limite_tc
DEFINE v_periodo_tc_ini   		DATE;			--Periodo_tc_Ini
DEFINE v_periodo_tc_fin   		DATE;			--Periodo_tc_Fin
DEFINE v_fecha_corte_tc   		DATE;			--Fecha_Corte
DEFINE v_dias_periodo_tc 		INTEGER;		--Dias_Periodo_tc
DEFINE v_dias_periodo_prox 		INTEGER;		--Dias_Periodo_tc
DEFINE v_monto_otorgado         DECIMAL(14,2);  --Monto_Credito_tc
DEFINE v_fecha_apertura		    DATE;			--Fecha_Otorgamiento_tc
DEFINE v_descuento				DECIMAL(14,2);	--Descuento por NO IVA CFDI 3.3
DEFINE v_subtotal				DECIMAL(14,2);	--Subtotal intereses CFDI 3.3
DEFINE v_total					DECIMAL(14,2);	--Total intereses e iva CFDI 3.3	
DEFINE v_comisiones				DECIMAL(14,2);  --PP FLEX
DEFINE v_iva_comisiones			DECIMAL(14,2);  --PP FLEX					

--	    VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA      --
DEFINE v_fecha_mov_aux          CHAR(10);           --Fecha Movimiento de Operacion
DEFINE v_fecha_mora             CHAR(10);
DEFINE v_usted_debia   			DECIMAL(18,2);	--Usted_debia
DEFINE v_contador      		smallint;
DEFINE v_abonos	       		decimal(18,2);
DEFINE v_serial             char(16);
DEFINE v_concepto           CHAR(296);
DEFINE v_descripcion_det    CHAR(296);
DEFINE v_monto_det          DECIMAL(18,2);
DEFINE v_naturaleza         CHAR(1);
DEFINE v_cod_ref            INTEGER;
DEFINE v_cod_fun            CHAR(3);
DEFINE v_cargos             DECIMAL(18,2);
--	    VARIABLES GENERACION MENSAJES EDO CUENTA REESTRUCTURA     --
DEFINE v_secuencia_mensaje		SMALLINT;
DEFINE v_si_paga		    	VARCHAR(255);
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
--	    VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
DEFINE v_tasa_anual			    DECIMAL(18,2);
DEFINE v_tasa_mensual		    DECIMAL(18,2);
DEFINE v_tasa_mora			    DECIMAL(18,2);
DEFINE v_tasa_mensual_mora	    DECIMAL(18,2);
DEFINE  v_cat			    	DECIMAL(8,2) ;
DEFINE v_saldo_promedio		    DECIMAL(18,2);
--	   VARIABLES CLAVE DE COBRANZA REESTRUCTURA     --
DEFINE v_situacion              CHAR(1);
DEFINE v_situacion_esp          CHAR(3);
DEFINE v_estado_civil           CHAR(1);
DEFINE v_tp_casa                CHAR(1);
DEFINE v_sexo                   CHAR(1);
DEFINE v_nacimiento             CHAR(2);
DEFINE v_salario                DECIMAL(18,2);
DEFINE v_cantidad               CHAR(2);
DEFINE v_antiguedad             CHAR(2);
DEFINE v_monto_adeudo           DECIMAL(18,2);
DEFINE v_mto_tot_adeudo         CHAR(5);
DEFINE v_mto_adeudo_venc        DECIMAL(18,2);
DEFINE v_monto_financiado	    DECIMAL(18,2);
DEFINE v_adeudo_vencido         CHAR(5);
DEFINE v_fecha_ultimo_pago	    DATE;
DEFINE v_fec_ult_pago           CHAR(4);
DEFINE v_fec_ult_pago_month     CHAR(2);
DEFINE v_fec_ult_pago_year      CHAR(2);
DEFINE v_monto_ult_convenio     CHAR(5);
DEFINE v_fecha_ult_convenio     CHAR(4);
DEFINE v_est_cumpl_convenio     CHAR(1);
DEFINE v_cuantos_avisos		    INTEGER;
DEFINE v_avisos 	    	    CHAR(1);
DEFINE v_nivel_eficiencia       CHAR(1);
DEFINE posicion11               CHAR(5);
DEFINE v_pago_minimo_tc   		DECIMAL(18,2);	--sdo_pagar
DEFINE posicion17               CHAR(5);
DEFINE v_clave1		          	VARCHAR(40);
DEFINE v_clave2		    	    VARCHAR(40);
DEFINE v_clave3		    	    VARCHAR(40);
DEFINE v_clave4		    	    VARCHAR(40);
DEFINE v_clave5         	    VARCHAR(40);
DEFINE v_cl_cobranza            CHAR(64);
DEFINE cNumProducto             CHAR(4);
DEFINE cIniClvCob               CHAR(1);
DEFINE iDiasCalc           INTEGER;
DEFINE dTasaInter          DECIMAL(9,6);
DEFINE dSdoCapital         DECIMAL(18,2);
DEFINE dCapTrasNoVen       DECIMAL(18,2);
DEFINE iDiasInt            INTEGER;
DEFINE dSdo                DECIMAL(18,2);
DEFINE v_inter_efect_pagados DECIMAL(18,2);
DEFINE v_comisiones_efec_pag DECIMAL(18,2);
DEFINE  vlFechaCutoa    DATE;
--     CREDINOMINA     --
DEFINE iTpDiasFechaPago SMALLINT;
DEFINE dtFechaProxCuota DATE;
DEFINE iDiaCorte        INTEGER;
DEFINE cCodRet          CHAR(6);
DEFINE v_transacc      		char(4);
DEFINE v_folio      		VARCHAR(20);
DEFINE v_fecha_limite_pago_pp DATE;
DEFINE v_monto_linea DECIMAL(18,2);
DEFINE cInd_tabla_amortizacion CHAR(1);
DEFINE v_monto_linea_dig DECIMAL(18,2);
DEFINE dFecha_otorga_dig DATE;
DEFINE v_Atr	INTEGER;
DEFINE vTipProdCarterasPP	CHAR(2);

--------------------------------------------------------------
-- Se agregan variables de catalogo de Centros de Impresion --
DEFINE sNumRegion CHAR(2); --Numero de region (centro de impresion)
DEFINE sNumCiudadB CHAR(4); --Numero de ciudad BanCoppel
DEFINE sNumCiudadC CHAR(3); --Numero de ciudad COPPEL

---- Limpieza de variables cfdi 4.0
DEFINE cIVA_cfdi	CHAR(04); -- Valor de IVA para CFDI 4.0 X UBICACION
DEFINE vObjetoImp	CHAR(02); -- Objeto Impuesto para CFDI 4.0
DEFINE vValBase		DECIMAL(12,2); -- Valor Base CFDI 4.0
DEFINE vIvaCfdi		DECIMAL(18,2); -- IVA PARA CFDI X CUENTA
DEFINE vIvaInteresesReales	DECIMAL(12,2); -- Valor de iva de intereses reales CFDI 4.0
DEFINE vInteresesReales	DECIMAL(12,2);  -- Valor de intereses reales 4.0
DEFINE vIvaDeComisiones	DECIMAL(12,2);

--- RQI 21 401
DEFINE v_nombre1	CHAR(26);
DEFINE v_nombre2	CHAR(26);
DEFINE v_apell_paterno	CHAR(26);
DEFINE v_apell_materno	CHAR(26);
DEFINE v_rfc_alterno	CHAR(13);
DEFINE v_rfc1			CHAR(13);
DEFINE v_fecha_alta		DATE;

LET iDiasCalc           = 0;
LET dTasaInter          = 0;
LET dSdoCapital         = 0;
LET dCapTrasNoVen       = 0;
LET iDiasInt            = 0;
LET dSdo                = 0;
--	    VARIABLES CONTROL DE ERRORES     --
LET cod_ret                  = "000000";
LET sql_err                  = 0;
LET v_cod_ret_otro           = "000000";
--	    VARIABLES GENERALES     --
LET v_status_cred             = "";
LET v_num_aper_ant            = "";
LET v_plazo                   = 0;
LET v_numerociudad 		      = 0;
LET v_numerocolonia 	      = 0;
LET v_numerocalle 		      = 0;
LET v_numeroextcalle 	      = "";
LET v_estado 			      = "";
LET v_nombrecalle		      = "";
LET v_centro			      = 0;
LET v_jefegrupozona		      = 0;
LET v_supervisorzona	      = 0;
LET v_iva_suc				  = 0;
LET v_capital_debe 			  = 0;
LET v_interes_debe 			  = 0;
LET v_iva_debe 				  = 0;
LET v_num_pago                = 0;
LET v_usted_debe_tc           = 0;
LET v_maximo                  = 0;
LET v_fecha_ultimo_pago_aux   = DATE(1);
LET v_aplica_factor           = 0;
LET v_periodo_anterior   	  = DATE(1);
LET v_periodo_prox            = DATE(1);
--	    VARIABLES GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA     --
LET v_numcte        	      = "";
LET v_nombre_cte    	      = "";
LET v_direccion_cn  	      = "";
LET v_direccion_col	          = "";
LET v_direccion_del 	      = "";
LET v_edo_cd     		      = "";
LET v_cl_cobra      	      = "";
LET v_sucursal                = "";
LET v_sucursal_nombre         = "";
LET v_sucursal_gerente        = "";
LET v_rfc           	      = "";
LET v_sucursal_tel            = "";
LET v_cod_postal    	      = "";
LET v_ruta           	      = "";
LET v_entre_calles   	      = "";
LET v_observaciones  	      = "";
LET cInserto                  = "";
LET cCuentaEfec               = "";
LET v_SalarioMinimoCoppel     = 0;
LET v_confirmacion			  = ""; 
LET cNomProducto			  = "";
--	    VARIABLES GENERACION ENCABEZADO2 EDO CUENTA REESTRUCTURA     --
LET v_capital_tc   			  = 0;
LET v_iva_interes_tc   		  = 0;
LET v_num_pago_c              = "";
LET v_cap_mto_cuota           = 0;
LET v_capital_vencido         = 0;
LET v_interes_vigente         = 0;
LET v_iva_vigente             = 0;
LET v_interes_vencido         = 0;
LET v_iva_vencido             = 0;
LET v_moratorio               = 0;
LET v_iva_moratorio           = 0;
LET v_pagototal               = 0;
LET v_fecha_limite_pago_tc    = " ";
LET v_periodo_tc_ini   		  = " ";
LET v_periodo_tc_fin   		  = " ";
LET v_fecha_corte_tc   		  = " ";
LET v_dias_periodo_tc 		  = 0;
LET v_dias_periodo_prox       = 0;
LET v_monto_otorgado          = 0;
LET v_fecha_apertura	      = " ";
LET v_descuento				  = 0; --CFDI 3.3
LET v_subtotal				  = 0; --CFDI 3.3
LET v_total					  = 0; --CFDI 3.3
LET v_comisiones			  = 0; --PP FLEX
LET v_iva_comisiones		  = 0; --PP FLEX	

--	    VARIABLES GENERACION DETALLE EDO CUENTA REESTRUCTURA     --
LET v_fecha_mov_aux          = DATE(1);
LET v_fecha_mora             = DATE(1);
LET v_usted_debia   		 = 0;
LET v_contador         = 0;
LET v_abonos           = 0;
LET v_serial           = "";
LET v_concepto         = "";
LET v_descripcion_det  = "";
LET v_monto_det        = 0;  --Mas_Disposiciones
LET v_naturaleza       = "";
LET v_cod_ref          = 0;
LET v_cod_fun          = "";
LET v_cargos           = 0;
--	    VARIABLES GENERACION MENSAJES EDO CUENTA REESTRUCTURA     --
LET v_secuencia_mensaje      = 0;
LET v_si_paga			     = "";
--	    VARIABLES GENERACION PIE EDO CUENTA REESTRUCTURA     --
LET v_tasa_anual		     = 0 ;
LET v_tasa_mensual 		     = 0 ;
LET v_tasa_mora			     = 0 ;
LET v_tasa_mensual_mora	     = 0 ;
LET v_saldo_promedio	     = 0 ;
--	    VARIABLES CLAVE DE COBRANZA REESTRUCTURA     --
LET v_situacion              = "";
LET v_situacion_esp          = "";
LET v_estado_civil           = "";
LET v_tp_casa                = "";
LET v_sexo                   = "";
LET v_nacimiento             = "";
LET v_salario                = 0;
LET v_cantidad               = "";
LET v_antiguedad             = "";
LET v_monto_adeudo		     = 0;
LET v_mto_tot_adeudo         = "";
LET v_mto_adeudo_venc        = 0;
LET v_monto_financiado	     = 0;
LET v_adeudo_vencido         = "";
LET v_fecha_ultimo_pago      = " ";
LET v_fec_ult_pago           = "";
LET v_fec_ult_pago_month     = "";
LET v_fec_ult_pago_year      = "";
LET v_monto_ult_convenio     = "";
LET v_fecha_ult_convenio     = "";
LET v_est_cumpl_convenio     = "";
LET v_cuantos_avisos	     = 0;
LET v_avisos 	    	     = "0";
LET v_nivel_eficiencia	     = 0;
LET posicion11               = "";
LET v_pago_minimo_tc   	     = 0;
LET posicion17               = "";
LET v_clave1		 	     = "";
LET v_clave2		 	     = "";
LET v_clave3			     = "";
LET v_clave4		 	     = "";
LET v_clave5         	     = "";
LET v_cl_cobranza            = "";
LET cNumProducto             = '';
LET cIniClvCob               = '';
LET v_inter_efect_pagados    = 0;
let v_comisiones_efec_pag   = 0;
LET vlFechaCutoa = DATE(1);
----- CREDINOMINA ------
LET iTpDiasFechaPago = 0;
LET dtFechaProxCuota = DATE(1);
LET iDiaCorte        = 0;
LET cCodRet          = 0;
LET v_numerociudadCoppel     = 0;
LET v_numerocoloniaCoppel    = 0;
LET v_folio     = "";
LET v_transacc     = "";
LET v_cat     = 0;
LET v_fecha_limite_pago_pp = " ";
LET v_monto_linea  = 0;
LET cInd_tabla_amortizacion = '';
LET v_monto_linea_dig = 0;
LET dFecha_otorga_dig  = DATE(1);
LET v_Atr	= 0;
LET vTipProdCarterasPP	= '';

-------------------------------------------------------------------------------
-- Se limpian variables para los campos region, ciudad y centro de impresion --
LET sNumRegion 	= '0';
LET sNumCiudadB = '0';
LET sNumCiudadC = '0';

---- Limpieza de variables cfdi 4.0
LET cIVA_cfdi	= 0;
LET vObjetoImp	= '';
LET vValBase	= 0;
LET vIvaCfdi	= 0;
LET vIvaInteresesReales	= 0;
LET vInteresesReales	= 0;
LET vIvaDeComisiones	= 0;

--- OBTIENE RFC LIMPIO PARA MOSTRAR
LET v_nombre1 = '';
LET v_nombre2 = '';
LET v_apell_paterno	= '';
LET v_apell_materno	= '';
LET v_rfc_alterno	= '';
LET v_rfc1			= '';
LET v_fecha_alta	= DATE(1);

-- Fecha: 11/08/2009
-- Autor: Paul Ivan Quintero Varela
-- Observaciones: Se modifica con la finalidad de agregar las adecuaciones para el desgloce de movimientos
--                            en el detalle correspondiente, se contemplan los cambios para la clave de cobranza,
--                             se modifica la obtencion del ultimo movimiento, el usted debe, usted debia, y
--                             finalmente las secuencias y nlineas de cada insercion en la tabla del detalle.
-- Fecha: 22/12/2009
-- Autor: Roque Enrique Solis
-- Observaciones: Se modifica con la finalidad de generar los estados de cuenta para Prestamos Personales

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
     END IF
  END EXCEPTION WITH RESUME ;

	---SET DEBUG FILE TO "/informix/Daniella/generaedosctacrd_pp.out";
	---TRACE ON;

   	--##############################################################
	--##	GENERACION ENCABEZADO EDO CUENTA REESTRUCTURA         ##
   	--##############################################################
	
    --     SD_MAECREDCRD     --

	SELECT a.numcte,a.num_producto, a.sucursal, a.fecha_apertura,
		   a.tasa_interes,	a.tasa_moratorios - a.tasa_interes,
		   DECODE(status_cred,'AR','0','BR','1','TR','2','0'),
		   status_cred, num_aper_ant, plazo
      INTO v_numcte,cNumProducto, v_sucursal, v_fecha_apertura,
           v_tasa_anual,	v_tasa_mora,
           v_avisos, v_status_cred, v_num_aper_ant,  v_plazo
	  FROM "informix".sd_maecredcrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;
	   
	 SELECT nvl(atr,-1) INTO v_Atr 
	 FROM "informix".sd_maesdoscrd where num_credito = pnum_credito;
	   
--RQM 10 1379	   
	  IF v_status_cred = 'AA' OR (v_Atr = 0 AND v_status_cred = 'E1') THEN
	  LET cInd_tabla_amortizacion = '1';
	     
	   ELSE 
	    LET cInd_tabla_amortizacion = '0';
	  END IF;
	  
		 SELECT a.monto_otorgado
				INTO v_monto_linea
			FROM "informix".sd_maesdoscrd a
		 WHERE a.empresa = pempresa
		   AND a.num_credito = pnum_credito;
		
		SELECT monto_linea,fecha_otorga	
			INTO v_monto_linea_dig, dFecha_otorga_dig
			FROM "informix".sd_linea_prestamo a
		 WHERE a.empresa = pempresa
		   AND a.num_credito = pnum_credito;
--RQM 10 1379		   
		
		   
	/*	   IF  cNumProducto <> '6800' THEN
	     LET v_monto_linea = 0.00;
			END IF;	 */

	SELECT cod_prod, nombre_prod  --adlm PP Flexible
	  INTO cIniClvCob, cNomProducto
	  FROM bdicred:sd_definicion
	 WHERE num_producto=cNumProducto;

	IF cIniClvCob IS NULL THEN
	    LET cIniClvCob = '';
	END IF;

	--AAME 2016-01-15 RQI 27 006 Se agrega validacion para que el cat para 6400 se obtenga uno diferente si es Mensual o quincenal.
	IF cNumProducto ='6400' AND iTpDiasFechaPago= 2 THEN --Quincenal
		SELECT cat_quincenal INTO v_cat from bdicred:sd_tasa_cat
		 WHERE empresa = pempresa and producto = cNumProducto
		   AND tasa = v_tasa_anual;
	ELSE  --Mensual		
		 IF cNumProducto <> '6400' THEN
			SELECT cat
			INTO v_cat
			FROM bdicred:"informix".sd_maecredanexocrd
			WHERE empresa = pempresa
			AND num_credito = pnum_credito;
		 END IF;
		IF NVL(v_cat,0) = 0 THEN
			SELECT cat INTO v_cat from bdicred:sd_tasa_cat
			 WHERE empresa = pempresa and producto = cNumProducto
			   AND tasa = v_tasa_anual;	
		END IF;
	END IF;

    IF v_cat IS NULL THEN
	   LET v_cat = 0.0;
	END IF;
	
	------ Convierte nÃºmero de producto para Carteras
	IF cNumProducto = '6300' THEN 
		LET vTipProdCarterasPP = '4';
	ELIF cNumProducto = '7600' THEN 
		LET vTipProdCarterasPP = '7';
	ELIF cNumProducto = '7700' THEN 
		LET vTipProdCarterasPP = '8';
	ELIF cNumProducto = '6800' THEN 
		LET vTipProdCarterasPP = '9';
	ELIF cNumProducto = '9100' THEN 
		LET vTipProdCarterasPP = '10';
	ELIF cNumProducto = '9300' THEN 
		LET vTipProdCarterasPP = '11';
	ELIF cNumProducto IN('6400') THEN
    	LET vTipProdCarterasPP = '';
	END IF;

	--     SI_CLIENTE     --

	SELECT a.nombre1,		a.nombre2,	a.apell_paterno,	a.apell_materno,
		   a.rfc_alterno,	a.rfc,		a.fecha_alta
	INTO	v_nombre1,		v_nombre2,	v_apell_paterno,	v_apell_materno,
		   v_rfc_alterno,	v_rfc1,		v_fecha_alta
	FROM bdinteg:"informix".si_cliente a
	WHERE a.numcte = v_numcte;
	
	IF v_rfc1 = '' OR v_rfc1 IS NULL THEN
		LET v_rfc = TRIM(v_rfc_alterno);
	ELSE
		LET v_rfc = TRIM(v_rfc1);
	END IF;
	
	LET v_antiguedad = NVL(SUBSTR(YEAR(v_fecha_alta), 3, 2),'');
	
	LET v_nombre_cte = TRIM(v_nombre1) || " " ||TRIM(v_nombre2) || " " || TRIM(v_apell_paterno) || " " ||TRIM(v_apell_materno);

	 --     SI_DIRECCIONES     --

	 SELECT TRIM(b.numeroextcalle) || " " || TRIM(b.numerointcalle),
	       b.cod_postal,			b.entre_calles,
	       b.observaciones,		   	b.numerociudad,
	       b.numerocolonia,			b.numerocalle,
	       b.numeroextcalle,	    b.estado
	  INTO v_direccion_cn,
		   v_cod_postal,			v_entre_calles,
		   v_observaciones,		    v_numerociudad,
		   v_numerocolonia,			v_numerocalle,
		   v_numeroextcalle,		v_estado
	  FROM bdinteg:"informix".si_direcciones_actual b
	 WHERE b.numcte  = v_numcte
	   AND tipo_dir = "1";

	--     SI_CATCALLES     --

	SELECT TRIM(c.nombrecalle)
	  INTO v_nombrecalle
	  FROM bdinteg:"informix".si_catcalles c
	 WHERE c.numerocalle = v_numerocalle;

	--     SI_CATZONAS     --

	SELECT d.nombrezona,			d.centro,
		   d.jefegrupozona,			d.supervisorzona,
		   d.numerociudadcoppel,    d.numerocoloniacoppel
	  INTO v_direccion_col,			v_centro,
		   v_jefegrupozona,			v_supervisorzona,
		   v_numerociudadCoppel,    v_numerocoloniaCoppel
	  FROM bdinteg:"informix".si_catzonas d
	 WHERE d.numerociudad = v_numerociudad
	   AND d.numerocolonia=v_numerocolonia;

	--     SI_CATCIUDADES     --

	SELECT e.nombreciudad
	  INTO v_direccion_del
	  FROM bdinteg:"informix".si_catciudades e
	 WHERE e.numerociudad = v_numerociudad;

	--     SI_ESTADOS     --

	SELECT f.nombre
	  INTO v_edo_cd
	  FROM bdinteg:"informix".si_estados f
	 WHERE f.estado = v_estado;
	 
	---------------------------------------
	------- CENTROS IMPRESION COPPEL ------
	SELECT LPAD(num_region,2,0),LPAD(num_ciudad_banco,4,0),LPAD(num_ciudad_coppel,3,0)
	INTO sNumRegion,sNumCiudadB,sNumCiudadC
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
	

	 --     SI_SUCURSALES     --

	 SELECT d.nombre,				d.gerente,
		     d.iva
	  INTO v_sucursal_nombre,		v_sucursal_gerente, v_iva_suc
	  FROM bdinteg:"informix".si_sucursales d
	 WHERE d.empresa  = pempresa
	   AND d.sucursal = v_sucursal;	   
	   
	   select tel1 
	  into v_sucursal_tel
	  from bdinteg:si_ptf 
	 where id_ptf = v_sucursal
	 and tipo = 'S';
	
	LET v_direccion_cn = v_nombrecalle || v_direccion_cn;
	LET v_ruta = LPAD(v_numerociudadCoppel,4,'0')||"/"||
			     LPAD(v_centro,6,'0')||"/"||
			     LPAD(v_jefegrupozona,8,'0')||"/"||
			     LPAD(v_supervisorzona,8,'0')||"/"||
			     LPAD(v_numerocoloniaCoppel,4,'0')||"/"||
			     LPAD(v_numerocalle,6,'0')||"/"||
			     LPAD(TRIM(v_numeroextcalle),5,'0');

    --   Se obtiene el inserto correspondiente           --

     SELECT insertos
       INTO cInserto
       FROM "informix".sd_marcaje
      WHERE empresa = pempresa
        AND num_credito= pnum_credito
        AND fecha_emision = pfechahoy;

       IF cInserto IS NULL THEN
          LET cInserto='000000000000000';
       END IF;

	--     SE OBTIENE EL NUMERO DE CUENTA EFECTIVA     --

	SELECT num_cta
      INTO cCuentaEfec
	  FROM "informix".sd_ctascarg
	 WHERE empresa = pempresa
	   AND naturaleza = 'A'	
	   AND num_credito = pnum_credito;
	   
	---ADLM PP FLEX
	-- COMISIONES
	IF cNumProducto ='6800' THEN
		SELECT sum(monto) 
			INTO v_comisiones
		FROM   	sd_movhisedoctacrd
		WHERE  	empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun = '339' AND codigo_ref IN (50,51,96);
		--AND num_producto= cNumProducto;

		SELECT sum(monto)
			INTO v_iva_comisiones
		FROM   	sd_movhisedoctacrd
		WHERE  	empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun = '340' AND codigo_ref IN (1,2,27);
		--AND num_producto= cNumProducto;
	END IF
	---ADLM PP FLEX
	   
	--- OBTIENE VALORES PARA CFDI 4.0
	select trim(valor) INTO cIVA_cfdi
	FROM "informix".sd_param WHERE cod_param = '143';
	
	--  ********************** 31/01/2025
	SELECT monto INTO vIvaInteresesReales FROM "informix".sd_movhisedoctacrd 
	WHERE fecha_mov = pfechahoy AND num_credito = pnum_credito 
	AND codigo_fun = '222' AND codigo_ref = '44';
	--  ********************** 31/01/2025
	
	LET vInteresesReales = (NVL(vIvaInteresesReales,0) / cIVA_cfdi);
	LET vValBase = (NVL(vInteresesReales,0) + NVL(v_comisiones,0));
	
	IF NVL(vValBase,0) = 0 OR NVL(vValBase,0) is null THEN
		LET v_subtotal	= 0.01;
		LET v_descuento = 0.01;
		--LET vIvaCfdi = NVL(vValBase,0) * .16;
		LET v_total = 0.00;
		LET vObjetoImp = '01';
		UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
		WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
	ELSE
		IF NVL(vValBase,0) > 0 THEN
			LET v_subtotal	= NVL(vInteresesReales,0) + NVL(v_comisiones,0);
			LET v_descuento = 0.00;
			LET vIvaDeComisiones = NVL(v_iva_comisiones,0) - NVL(v_comisiones,0);
			--LET v_total = (NVL(v_subtotal,0) + NVL(vIvaInteresesReales,0) + NVL(v_iva_comisiones,0)) - NVL(v_descuento,0);
			LET v_total = (NVL(v_subtotal,0) + NVL(vIvaInteresesReales,0) + NVL(vIvaDeComisiones,0)) - NVL(v_descuento,0);
			LET vObjetoImp = '02';
			UPDATE "informix".sd_encabezado_edocta SET base_cfdi = NVL(vValBase,0), obj_imp = vObjetoImp
			WHERE fecha_emision = pfechahoy AND num_credito = pnum_credito;
		END IF;
	END IF;
	
	LET vIvaCfdi = NVL(vValBase,0) * .16;
	--- FIN CFDI 4.0
	
	-- VALIDA SI TIENE MENOS DE 5 CARACTERES EL CODIGO POSTAL
	IF LENGTH(v_cod_postal) < 5 THEN
		LET v_cod_postal = LPAD(v_cod_postal,6,0);
	END IF;

     INSERT INTO "informix".sd_encabezado_edoctacrd
     				(
                    fecha_emision,       num_credito,
					num_cta_efec,        num_producto,
                    numcte,              nombre_cte,
                    direccion_cn,        direccion_col,
                    direccion_del,       edo_cd,
                    cl_cobra,            sucursal_numero,
                    sucursal_nombre,     sucursal_gerente,
                    rfc,                 sucursal_tel,
                    cp,                  ruta,
                    entre_calles,        observaciones,
                    insertos,			 confirmacion,
					nombre_producto,	 ind_tabla_amortizacion,
					num_region,			 num_ciudad_banco,
					num_ciudad_coppel,	 obj_imp,
					base_cfdi
					)
	  		 VALUES(
	  		       	pfechahoy,				            TRIM(pnum_credito),
					NVL(cCuentaEfec,''),				cNumProducto,
                    NVL(TRIM(v_numcte),''),				NVL(TRIM(v_nombre_cte),''),
                    NVL(TRIM(v_direccion_cn),''),      	NVL(TRIM(v_direccion_col),''),
                    NVL(TRIM(v_direccion_del),''),     	NVL(TRIM(v_edo_cd),''),
                    NVL(TRIM(v_cl_cobra),''),           NVL(TRIM(v_sucursal),''),
                    NVL(TRIM(v_sucursal_nombre),''),   	NVL(TRIM(v_sucursal_gerente),''),
                    NVL(TRIM(v_rfc),''),                NVL(TRIM(v_sucursal_tel),''),
                    NVL(TRIM(v_cod_postal),''),         NVL(TRIM(v_ruta),''),
                    NVL(TRIM(v_entre_calles),''),       NVL(TRIM(v_observaciones),''),
                    cInserto,							NVL(TRIM(v_confirmacion),''),
					cNomProducto ,						cInd_tabla_amortizacion,
					NVL(sNumRegion,''),					NVL(sNumCiudadB,''),
					NVL(sNumCiudadC,''),				NVL(vObjetoImp,''),
					NVL(vValBase,0)
				    );
					
					IF NVL(TRIM(v_ruta),'') = '' OR v_ruta is null THEN
						UPDATE "informix".sd_encabezado_edoctacrd SET num_region = '00' WHERE num_credito = pnum_credito AND ruta = '';
					END IF;

  --     PERIODO ANTERIOR     --

  IF cNumProducto = '6400' THEN
      SELECT tp_dias_fecha_pago
        INTO iTpDiasFechaPago
        FROM bdicred:"informix".sd_maecredanexocrd
       WHERE empresa = pempresa
         AND num_credito = pnum_credito;

         IF  iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN

             IF ( DAY(pfechahoy) <= 15) then
                SELECT  sdodiafac
                  INTO iDiaCorte
                  FROM "informix".sd_diafactura
                 WHERE empresa = pempresa
                   AND num_producto = cNumProducto
                   AND perdiafac = DAY(pfechahoy)
                   AND tipo_pago = iTpDiasFechaPago
                   AND fac_especial = 'N';
             ELSE
                SELECT  perdiafac
                  INTO iDiaCorte
                  FROM "informix".sd_diafactura
                 WHERE empresa = pempresa
                   AND num_producto = cNumProducto
                   AND sdodiafac = DAY(pfechahoy)
                   AND tipo_pago = iTpDiasFechaPago
                   AND fac_especial = 'S';
             END IF;
          END IF;

             CALL "informix".calculamesiversario(iDiaCorte, pfechahoy, 1, 2)
                  RETURNING cCodRet, dtFechaProxCuota; 

              IF DAY(iDiaCorte) = 15 THEN
                    LET v_periodo_anterior = mdy(MONTH(pfechahoy),iDiaCorte,YEAR(pfechahoy));
              ELIF DAY(iDiaCorte) IN (30,31)  THEN
                 LET v_periodo_anterior = MONTH(dtFechaProxCuota) ||"/01/"|| YEAR(dtFechaProxCuota);
                 LET v_periodo_anterior = v_periodo_anterior - 1 UNITS DAY;
              ELSE
                 LET v_periodo_anterior = monthadd(dtFechaProxCuota, -1);
              END IF;
     END IF;


            EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,-1,DAY(pfechahoy))
                         INTO v_cod_ret_otro, v_periodo_anterior, v_dias_periodo_tc;

            IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
              LET cod_ret = v_cod_ret_otro;
            END IF;
			
            LET cod_ret = '000000';

            LET v_dias_periodo_tc = (v_dias_periodo_tc * -1);

    --     OBTENGO EL PERIODO INICIAL, FINAL, DIAS DEL PERIODO Y FECHA DE CORTE      --

    LET v_periodo_tc_ini = v_periodo_anterior + 1;
	LET v_periodo_tc_fin = pfechahoy;
    LET v_fecha_corte_tc = pfechahoy;


	--     SE DEFINE EL MONTO DEL PROXIMO PAGO     --

	SELECT a.valor
	  INTO iDiasCalc
	  FROM "informix".sd_param a
	 WHERE a.cod_param = "24";

	IF iDiasCalc IS NULL THEN
		LET iDiasCalc = 0;
	END IF;

    IF  iTpDiasFechaPago = 2  AND cNumProducto = '6400' THEN
      LET vlFechaCutoa =  date(dtFechaProxCuota);
    ELSE
      LET vlFechaCutoa = date(monthadd(pfechahoy, + 1));
    END IF;

	SELECT num_pago,
		   capital_mto_cuota
	  INTO v_num_pago,
		   v_cap_mto_cuota
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa     = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota = vlFechaCutoa;

	IF v_num_pago = 0 THEN
	  LET v_num_pago_c = "-";
	ELSE
	  LET v_num_pago_c = nvl(v_num_pago,0)||"/"||v_plazo; 
	END IF;

	
    --     OBTENEMOS EL INTERES VIGENTE     --

	SELECT sum(interes_debe - interes_pagado),
			sum(iva_debe - iva_pagado)
	  INTO v_interes_vigente,
		   v_iva_vigente
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa     = pempresa
	   AND num_credito = pnum_credito
	   AND fecha_cuota = pfechahoy;
	
    
    --     SE OBTINE EL CAPITAL, INTERES, IVA VENCIDOS, MORATORIOS E IVA MORATORIOS,USTED DEBE    --

	SELECT NVL(SUM(a.tasa_interes),0),  --dTasaInter
		   NVL(SUM(b.sdo_capital),0),  ---dSdoCapital
		   NVL(SUM(b.cap_tras_no_venci),0), --dCapTrasNoVen
		   NVL(SUM(monto_vencido + mto_venc_trasp),0), --v_capital_vencido
		   NVL(SUM(sdo_no_exig + int_tra_no_exig ),0),--v_interes_vencido
		   NVL(SUM(mto_venc_int + mto_finan_vdo),0), --v_iva_vencido
		   NVL(SUM(sdo_moratorio + sdo_contab_mora),0), --v_moratorio
		   NVL(SUM(monto_otorgado),0), --v_monto_otorgado
  		   NVL(SUM(sdo_cap_insoluto+sdo_no_exig+int_tra_no_exig+mto_finan_vdo+mto_venc_int+sdo_retenido ),0) --v_usted_debe_tc
	  INTO dTasaInter,
		   dSdoCapital,
		   dCapTrasNoVen,
		   v_capital_vencido,
		   v_interes_vencido,
		   v_iva_vencido,
		   v_moratorio,
		   v_monto_otorgado,
		   v_usted_debe_tc
	  FROM sd_maecredcrd a, sd_maesdoshistcrd b
	 WHERE b.fecha = pfechahoy
	   AND a.empresa       = b.empresa
	   AND a.empresa       = pempresa
	   AND a.num_credito   = pnum_credito
	   AND a.num_credito   = b.num_credito;
	   
	   
	IF v_monto_otorgado IS NULL THEN
		LET v_monto_otorgado = 0;
	END IF;

    IF v_interes_vencido <> 0 AND cNumProducto <> '6400' THEN
		LET  v_interes_vencido = round((v_interes_vencido - nvl(v_interes_vigente,0)),2);
    END IF

    IF v_iva_vencido <> 0 AND cNumProducto <> '6400' THEN
	  LET v_iva_vencido = ROUND((v_iva_vencido - nvl(v_iva_vigente,0)),2);
    END IF

    IF v_moratorio <> 0 then
	   LET v_iva_moratorio = ROUND((v_moratorio * 0.16),2);
    END IF
	   
    --CALCULO DE DIAS PARA INTERESES DEL PROXIMO PERIODO

	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy ,1,DAY(pfechahoy))
		         INTO v_cod_ret_otro, v_periodo_prox, v_dias_periodo_prox;

	IF v_cod_ret_otro <> "000" AND cod_ret = "000000" THEN
	  LET cod_ret = v_cod_ret_otro;
	END IF;
	
    LET cod_ret = '000000';

    IF iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN
        LET v_dias_periodo_prox = 0;
        LET v_dias_periodo_prox = DAY(pfechahoy) - DAY(dtFechaProxCuota);
        IF v_dias_periodo_prox < 0 THEN
            LET v_dias_periodo_prox = v_dias_periodo_prox * -1;
        END IF;
    END IF;

    LET dSdo = dSdoCapital + dCapTrasNoVen;
    LET v_interes_debe = round((round((dSdo * dTasaInter / (iDiasCalc * 100)),2) * v_dias_periodo_prox),2);
    LET v_iva_debe = round((v_interes_debe * v_iva_suc),2);
    LET v_capital_debe = round((v_cap_mto_cuota - v_interes_debe - v_iva_debe),2);

	IF (v_capital_debe is  null) THEN
		LET v_num_pago = 0;
		let v_cap_mto_cuota = 0;
		let v_capital_debe = 0;
		let v_interes_debe = 0;
		let v_iva_debe = 0;
	END IF;


	LET v_pagototal     = NVL(v_capital_vencido,0) +
						 NVL(v_interes_vencido,0) +
						 NVL(v_iva_vencido,0) +
						 NVL(v_capital_debe,0) +
						 NVL(v_interes_debe,0) +
						 NVL(v_iva_debe,0) +
						 NVL(v_moratorio,0) +
						 NVL(v_iva_moratorio,0);


	LET v_pago_minimo_tc = v_pagototal;

	IF nvl(v_capital_vencido,0) > 0 THEN
	   LET v_fecha_limite_pago_tc = DATE(1);
	ELSE
	    IF iTpDiasFechaPago = 2 and cNumProducto = '6400' THEN
			LET v_fecha_limite_pago_tc = dtFechaProxCuota;
	  ELSE
			LET v_fecha_limite_pago_tc = date(monthadd(pfechahoy, + 1));
		END IF;
    END IF;


	SELECT COUNT(empresa)
	  INTO v_cuantos_avisos
	  FROM "informix".sd_amortiza_creditocrd
	 WHERE empresa = pempresa
	   AND num_credito = pnum_credito
	   AND capital_status IN ("2","7","6");

--- RQI 12 297: CFDI 3.3 --- 	
--- Campos descuento y subtotal
	/*if NVL(v_iva_debe,0) > 0 then
		--LET v_descuento = 0.00;
		LET v_subtotal  = NVL(v_interes_debe,0);
	else 	
		--LET v_descuento	= 0.01;
		LET v_subtotal  = 0.01;
	end if
		
	LET v_total = NVL(v_interes_debe,0) + NVL(v_iva_debe,0); */
--- RQI 12 297: CFDI 3.3 --- 	   

-- VALOR DE IVA REAL SOBRE LA BASE DE CFDI
LET vIvaCfdi = NVL(vValBase,0) * .16;

IF cNumProducto = '6800' THEN
    INSERT INTO "informix".sd_encabezado2_edoctacrd
				(
                fecha_emision,              num_credito,
                capital_tc,                 interes_tc,
                iva_interes_tc,             numero_pago_tc,
                monto_pago,                 capital_ven_tc,
                interes_ven_tc,             iva_interes_ven_tc,
                moratorios_tc,              iva_moratorios_tc,
                pago_total_tc,              fecha_limite_tc,
                periodo_tc_ini,             periodo_tc_fin,
                fecha_corte_tc,             dias_periodo_tc,
                monto_credito_tc,           fecha_otorgamiento_tc,
                intereses_efec_pag,         comisiones_efec_cargadas,
				descuento,					subtotal,					
				total,						comisiones, 
				iva_comisiones,				linea_autorizada,		  
				fecha_ult_disposicion,		val_base_cfdi,
				iva_intereses_reales_cfdi,	intereses_reales_cfdi,
				iva_cfdi
				)
		VALUES (
				pfechahoy,					      TRIM(pnum_credito),
				NVL(v_capital_debe,0),		      NVL(v_interes_debe,0),
				NVL(v_iva_debe,0),	              NVL(v_num_pago_c,'0'),
                NVL(v_cap_mto_cuota,0),           NVL(v_capital_vencido,0),
                NVL(v_interes_vencido,0),         NVL(v_iva_vencido,0),
                NVL(v_moratorio,0),               NVL(v_iva_moratorio,0),
                NVL(v_pagototal,0),               NVL(v_fecha_limite_pago_tc,DATE(1)),
                v_periodo_tc_ini,                 v_periodo_tc_fin,
                NVL(v_fecha_corte_tc,DATE(1)),    NVL(v_dias_periodo_tc,''),
                NVL(v_monto_otorgado,0),          NVL(dFecha_otorga_dig,DATE(1)),
                0,                                0,
				NVL(v_descuento,0), 			  NVL(v_subtotal,0), 			
				NVL(v_total,0),					  NVL(v_comisiones,0), 
				NVL(v_iva_comisiones,0),		  NVL(v_monto_linea_dig,0),
				NVL(v_fecha_apertura,DATE(1)),	  NVL(vValBase,0),
				NVL(vIvaInteresesReales,0),		  NVL(vInteresesReales,0),
				NVL(vIvaCfdi,0)
				);
ELSE

 INSERT INTO "informix".sd_encabezado2_edoctacrd
				(
                fecha_emision,              num_credito,
                capital_tc,                 interes_tc,
                iva_interes_tc,             numero_pago_tc,
                monto_pago,                 capital_ven_tc,
                interes_ven_tc,             iva_interes_ven_tc,
                moratorios_tc,              iva_moratorios_tc,
                pago_total_tc,              fecha_limite_tc,
                periodo_tc_ini,             periodo_tc_fin,
                fecha_corte_tc,             dias_periodo_tc,
                monto_credito_tc,           fecha_otorgamiento_tc,
                intereses_efec_pag,         comisiones_efec_cargadas,
				descuento,					subtotal,					
				total,						comisiones, 
				iva_comisiones,				linea_autorizada,		  
				fecha_ult_disposicion,		val_base_cfdi,
				iva_intereses_reales_cfdi,	intereses_reales_cfdi,
				iva_cfdi
				)
		VALUES (
				pfechahoy,					      TRIM(pnum_credito),
				NVL(v_capital_debe,0),		      NVL(v_interes_debe,0),
				NVL(v_iva_debe,0),	              NVL(v_num_pago_c,'0'),
                NVL(v_cap_mto_cuota,0),           NVL(v_capital_vencido,0),
                NVL(v_interes_vencido,0),         NVL(v_iva_vencido,0),
                NVL(v_moratorio,0),               NVL(v_iva_moratorio,0),
                NVL(v_pagototal,0),               NVL(v_fecha_limite_pago_tc,DATE(1)),
                v_periodo_tc_ini,                 v_periodo_tc_fin,
                NVL(v_fecha_corte_tc,DATE(1)),    NVL(v_dias_periodo_tc,''),
                NVL(v_monto_otorgado,0),          NVL(v_fecha_apertura,DATE(1)),
                0,                                0,
				NVL(v_descuento,0), 			  NVL(v_subtotal,0), 			
				NVL(v_total,0),					  NVL(v_comisiones,0), 
				NVL(v_iva_comisiones,0),		  NVL(v_monto_linea,0),
				NVL(v_fecha_apertura,DATE(1)),	  NVL(vValBase,0),
				NVL(vIvaInteresesReales,0),		  NVL(vInteresesReales,0),
				NVL(vIvaCfdi,0)
				);
 
 END IF;
	--     USTED DEBIA     --

	SELECT nvl(saldo_insoluto,0)
	  INTO v_usted_debia
	  FROM "informix".sd_pie_edoctacrd
    WHERE fecha_emision = date(monthadd(pfechahoy, - 1))
	AND num_credito = pnum_credito;

	IF v_usted_debia IS NULL OR v_usted_debia = '' THEN

	   LET v_usted_debia = 0;
		SELECT NVL(SUM(sdo_cap_insoluto+sdo_no_exig + int_tra_no_exig+mto_finan_vdo+mto_venc_int),0)
		  INTO v_usted_debia
		  FROM bdicred:sd_maesdoshistcrd
         WHERE fecha = date(monthadd(pfechahoy, - 1))
		   AND empresa = pempresa
		   AND num_credito = pnum_credito;
	END IF;

    LET v_maximo = 1;

    --      GENERA USTED DEBIA     --

	INSERT INTO sd_detalle_edoctacrd
			(
			fecha_emision,		num_credito,
			secuencia,			nlinea,
			fecha_mov,			concepto,
			cargos,				abonos

		    )
		VALUES(
			pfechahoy,			pnum_credito,
			v_maximo,			1,
			DATE(1),     	    "USTED DEBIA",
			NVL(v_usted_debia,0), NVL(v_abonos,0)
		    );

    -- GENERO LOS MOVIMIENTOS DEL ESTADO DE CUENTA

--***************************INICIO MENSUALES************************************
               FOREACH  SELECT lpad(month(a.fecha_mov),2,0)||'-'||
               lpad(day(a.fecha_mov),2,0)||'-'||
               lpad(year(a.fecha_mov),4,0), a.secuencia,transacc_suc,a.folio_suc,a.referencia,a.descripcion,a.monto,a.naturaleza,a.codigo_ref,a.codigo_fun
                INTO v_fecha_mov_aux,v_serial,v_transacc,v_folio,v_concepto,v_descripcion_det,v_monto_det,v_naturaleza,v_cod_ref,v_cod_fun
                   FROM bdicred:sd_movhisedoctacrd  a
                   WHERE  a.empresa = '001'
                     AND a.num_credito = pnum_credito
                     AND a.reversado = "N"
                     AND a.referencia <> 'PROV'
                ORDER BY fecha_mov,secuencia,folio_suc, a.codigo_ref

                                LET v_contador = v_contador + 3;

                                IF v_naturaleza = "A" THEN
                                    LET v_abonos = v_monto_det;
                                    LET v_cargos = 0;
                                ELSE
                                    LET v_cargos = v_monto_det;
                                    LET v_abonos = 0;
                                END IF

                                IF  ((v_transacc in ('8205')) AND (v_cod_ref = 1)) THEN  
									LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 6))||" Abono por remesa de BTS";
																
								ELIF  ((v_transacc in ('8286')) AND (v_cod_ref = 1)) THEN  
									LET v_descripcion_det = TRIM(SUBSTRING(v_folio FROM 5))||" Abono por remesa de Appriza";

								ELIF v_cod_fun in ("020","021","022","023","024","025","027") AND v_cod_ref = 1 THEN
                                   LET v_descripcion_det = "";
                                   LET v_descripcion_det = TRIM(v_concepto) || " " || v_abonos;
                                   LET  v_cargos = 0;
                                   LET  v_abonos = 0;

                                ELIF v_cod_fun = "002" AND v_cod_ref = 66 THEN
                                     IF cNumProducto = '6400' THEN
                                        LET v_descripcion_det = "DISPOSICION DE LINEA CREDINOMINA";
                                     ELSE
                                        LET v_descripcion_det = Trim(v_descripcion_det);
                                     END IF;
                                ELIF v_cod_ref in (43,44) THEN

                                ELIF v_cod_fun in ('023') AND v_cod_ref in (2,3) THEN
                                     LET v_fecha_mora = v_fecha_mov_aux;
                                     LET v_fecha_mov_aux = DATE(1);

                                ELIF v_cod_fun in ('028') AND v_cod_ref in (1) THEN

                                     LET v_descripcion_det = TRIM("PAGO ANT.") || " " || v_abonos;
                                     LET  v_cargos = 0;
                                     LET  v_abonos = 0;
									 
                                ELIF v_cod_fun in ('222') AND v_cod_ref in (50,51) THEN
								
									UPDATE sd_detalle_edoctacrd SET cargos = cargos -  v_cargos
									WHERE fecha_emision = pfechahoy AND num_credito =  pnum_credito 
										AND secuencia = 1 AND nlinea = 1;
										
                                     LET v_descripcion_det = Trim(v_descripcion_det) || " "||v_cargos;
									 LET v_cargos = 0;
									 
								ELIF v_cod_fun in ('222') AND v_cod_ref in (48,49) THEN
								
									UPDATE sd_detalle_edoctacrd SET cargos = cargos -  v_cargos
									WHERE fecha_emision = pfechahoy AND num_credito =  pnum_credito 
										AND secuencia = 1 AND nlinea = 1;
								
									LET v_descripcion_det = Trim(v_descripcion_det);
                                ELSE
                                   LET v_fecha_mov_aux = DATE(1);
                                   LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
                                END IF

                                IF v_cod_fun = '222' and v_cod_ref = 43 then
                                    let v_inter_efect_pagados =  v_cargos;
                                ELIF v_cod_fun = '020' and v_cod_ref = 17 then
                                    let v_comisiones_efec_pag = v_cargos;
                                END IF;

                                IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                                    LET v_contador = v_contador + 1;
                                ELSE
                                    LET v_maximo = v_maximo + 3;
                                    LET v_contador = 0;
                                    LET v_contador = v_contador + 1;
                                END IF;
								
                                     INSERT INTO sd_detalle_edoctacrd
                                        (
                                        fecha_emision,		num_credito,
                                        secuencia,			nlinea,
                                        fecha_mov,          concepto,
                                        cargos,             abonos
                                        )
                                    VALUES(
                                        pfechahoy,			pnum_credito,
                                        v_maximo,			v_contador,
                                        v_fecha_mov_aux,    Trim(v_descripcion_det),
                                        v_cargos,           v_abonos
                                        );

                        LET v_fecha_mov_aux  = date(1);
                        LET v_concepto       = "";
                        LET v_cargos         = 0;
                        LET v_abonos         = 0;

               END FOREACH;

    LET v_fecha_ultimo_pago = v_fecha_ultimo_pago_aux;

    IF v_inter_efect_pagados <> 0 THEN
        UPDATE bdicred:sd_encabezado2_edoctacrd 
		   SET intereses_efec_pag = v_inter_efect_pagados
         WHERE fecha_emision = pfechahoy  and num_credito = pnum_credito;
     END IF;

    IF v_comisiones_efec_pag <> 0 THEN
        UPDATE bdicred:sd_encabezado2_edoctacrd 
	  	   SET comisiones_efec_cargadas = v_comisiones_efec_pag
         WHERE fecha_emision = pfechahoy and num_credito = pnum_credito;
    END IF;

    Let v_inter_efect_pagados = 0;
    let v_comisiones_efec_pag = 0;

    --     USTED DEBE      --

        LET v_contador = 1;
        LET v_maximo = v_maximo + 1 ;

        INSERT INTO sd_detalle_edoctacrd
            (
            fecha_emision,		num_credito,
            secuencia,			nlinea,
            fecha_mov,          concepto,
            cargos,             abonos
            )
        VALUES
            (
            pfechahoy,			     pnum_credito,
            v_maximo,			     v_contador,
            DATE(1),                 "USTED DEBE",
            NVL(v_usted_debe_tc,0),  v_abonos
            );

	--##	GENERACION ACLARACIONES	 EDO CUENTA	REESTRUCTURA     INI ##
	--##	GENERACION ACLARACIONES	 EDO CUENTA	REESTRUCTURA     FIN ##
	
	--##	GENERACION MENSAJES	 EDO CUENTA	REESTRUCTURA          ##

 	 LET v_secuencia_mensaje  = 0 ;
     LET v_si_paga = v_usted_debe_tc;
		

    INSERT INTO "informix".sd_mensajes_edoctacrd
                (
                fecha_emision, 		num_credito,
                num_producto,         secuencia,
				nlinea,                 si_paga,
				mensajes
                )
				SELECT pfechahoy, TRIM(pnum_credito),
                      cNumProducto,clave, secuencia,
                      '',
                      REPLACE(mensaje,v_linea_auxiliar, TRIM(v_aplica_factor::VARCHAR(21)))
                 FROM mensajes
				 WHERE num_producto = cNumProducto;



	--##	GENERACION   PIE	 EDO CUENTA	 REESTRUCTURA         ##

   	LET v_tasa_mensual      = v_tasa_anual / 12;
	LET v_tasa_mensual_mora = v_tasa_mora / 12;


	IF v_tasa_mora < 0 THEN
		LET v_tasa_mora=0;
		LET v_tasa_mensual_mora=0;
	END IF        

    --     GENERA EL PIE DEL ESTADO DE CUENTA REESTRUCTURA      --

	INSERT INTO "informix".sd_pie_edoctacrd
			(
			fecha_emision,			num_credito,
            tasa_anual,             tasa_mensual,
			tasa_mora_anual,        tasa_mora_mensual,
			cat,					saldo_insoluto
			)
	VALUES
			(
			pfechahoy,				TRIM(pnum_credito),
			NVL(v_tasa_anual,0),	NVL(v_tasa_mensual,0),
            NVL(v_tasa_mora,0),     NVL(v_tasa_mensual_mora,0),
			NVL(v_cat,0),			NVL(v_usted_debe_tc,0)
			);

	--     GENERACION  CLAVE DE COBRANZA REESTRUCTURA     --
    --	         1.--TIPO DE CLIENTE: (2 Numero)
    --	         2.--SITUACION ESPECIAL: (1 letra)

    SELECT FIRST 1 situacion, causa
      INTO v_situacion, v_situacion_esp
      FROM bdinteg:si_ctessitesp
     WHERE numcliente = v_numcte;

    IF v_situacion IS NULL OR v_situacion = "" THEN
    	LET v_situacion = "-";
    END IF

    --     2.1.--SITUACION ESPECIAL: (3 Numero o ---) Req 09087     --

    IF v_situacion_esp IS NULL OR v_situacion_esp = "" THEN
    	LET v_situacion_esp = "000";
    END IF

	LET v_situacion_esp= lpad( TRIM(v_situacion_esp), 3,'0');

    --     3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Anio Nacimiento (2 Numeros)     --

	SELECT TRIM(NVL(estado_civil,'')),
		   TRIM(NVL(SUBSTR(habita_en, 1,1),'P')),
		   TRIM(NVL(sexo,'')),
		   NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	  INTO v_estado_civil,
		   v_tp_casa,
		   v_sexo,
		   v_nacimiento
      FROM bdinteg:si_ctepf
	 WHERE numcte = v_numcte;

    --     6.--SALARIO MINIMO COPPEL:     --

       SELECT valor
         INTO v_SalarioMinimoCoppel
         FROM bdisolic:ss_param
        WHERE empresa = pempresa
          AND secuencia = 303;

          IF v_SalarioMinimoCoppel IS NULL THEN
             LET v_SalarioMinimoCoppel = 0;
          END IF;

	SELECT NVL(ingreso_mensual,0) / v_SalarioMinimoCoppel
	  INTO v_salario
	  FROM bdisolic:"informix".ss_resum_scor_fin
	 WHERE empresa = pempresa
	   AND num_solicitud = pnum_credito;


	IF v_salario <= 0  OR v_salario IS NULL THEN
	  	IF cod_ret = "000000" THEN
	  		LET cod_ret = "211";
	  	END IF
	ELSE
		IF v_salario >= 22 THEN
			LET v_cantidad = LPAD(22,2,'0');
		ELSE
			LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
		END IF
	END IF

    --     7.-ANTIGUEDAD: (2 NUMEROS)     --

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF

    --     9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)     --

	IF v_pagototal >= 100000 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_pagototal < 0 THEN
			LET v_mto_tot_adeudo = "00000";
		ELSE
			LET v_mto_tot_adeudo = LPAD(ROUND(v_usted_debe_tc),5,'0');
		END IF

	END IF

    --     10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)     --

	IF v_mto_adeudo_venc >= 100000 THEN
  		IF cod_ret = "000000" THEN
  			LET cod_ret = "214";
  		END IF
	ELSE
        LET v_mto_adeudo_venc = v_monto_financiado; -- Solictado 20 Nov 2008 MEL
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF

    --     11.-FECHA DE ULT. PAGO: (4 NUMEROS)     --

	IF v_fecha_ultimo_pago IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago_month = MONTH(v_fecha_ultimo_pago);
		LET v_fec_ult_pago_year =  SUBSTR(YEAR(v_fecha_ultimo_pago),3,2);
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF

    --     12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)     --

    FOREACH
       SELECT FIRST 1 importe, TO_CHAR(fecha_compac,"%m%y")
	     INTO v_monto_ult_convenio , v_fecha_ult_convenio
	     FROM bdicobranza:cb_compac
	    WHERE empresa = pempresa
	      AND numcliente = v_numcte
     ORDER BY fecha_compac DESC
         EXIT FOREACH;
    END FOREACH;

    IF v_monto_ult_convenio IS NULL OR v_monto_ult_convenio = "" THEN
		LET v_monto_ult_convenio =  LPAD("0",5,'0');
	END IF

    --     13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)     --

    IF v_fecha_ult_convenio IS NULL OR v_fecha_ult_convenio = "" THEN
		LET v_fecha_ult_convenio =  "NDND";
	END IF

    --      14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)     --

    FOREACH
      SELECT FIRST 1 'P'
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

    --     15.-NUMERO DE AVISOS: (1 LETRA)     --

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

	--      Modifico para Clave de Cobranza ----- RQM 09 117      --

	LET posicion11= ROUND(v_pago_minimo_tc - v_capital_tc);
	LET posicion11= LPAD(TRIM(posicion11), 5,'0');

	--- Inicio (Inc. 20 Marzo 2009)
	LET v_monto_ult_convenio= ROUND(v_monto_ult_convenio);
	LET v_monto_ult_convenio= LPAD(TRIM(v_monto_ult_convenio), 5,'0');
	--- Fin

	LET posicion17= ROUND(v_pago_minimo_tc);
	LET posicion17= LPAD( TRIM(posicion17), 5,'0');

    --      ARMO LA CLAVE DE COBRANZA PRESTAMO :      --
	
	--DIA LIMITE DE PAGO --SD_MAECREDANEXOCRD
	SELECT  prox_fecha_pago
      INTO  v_fecha_limite_pago_pp
	  FROM "informix".sd_maecredanexocrd a
	 WHERE a.empresa = pempresa
	   AND a.num_credito = pnum_credito;

	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion 	||"/"|| v_situacion_esp 	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = SUBSTRING(TO_CHAR(v_fecha_limite_pago_pp, "%y-%m-%d") FROM 7 FOR 2)	||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 =  posicion11 ||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos ||"/"||posicion17;

	LET v_cl_cobranza = cIniClvCob || v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;

    --     EJECUTO EL PROCEDURE PARA LA CLAVE DE COBRANZA PRESTAMO     --

	UPDATE bdicred:"informix".sd_encabezado_edoctacrd
       SET cl_cobra = trim(v_cl_cobranza)
	 WHERE fecha_emision = pfechahoy
	   AND num_credito = pnum_credito;


   RETURN cod_ret;

END
END PROCEDURE
DOCUMENT
'Se crea procedimiento para obtener',
'la informacion para la generacion de los',
'estados de cuenta para creditos reestructurados, su',
'clave de cobranza y ruta correspondiente',
'base de datos : bdicred',
'AUTOR : Bernardo Baez',
'FECHA : 23/Julio/2009';

CREATE PROCEDURE "informix".sp_carga_pre_aprobados()
	RETURNING CHAR(5)   AS codRet,
              CHAR(500) AS mensaje,
              CHAR(2)   AS idProceso;


	DEFINE iSqlErr INTEGER;
	DEFINE vCodRet CHAR(5);
    DEFINE vMensaje CHAR (500);
    DEFINE vSql CHAR(500);
    DEFINE vIdProceso CHAR(2);
    DEFINE vConsecutivoCte INTEGER;
    DEFINE vtransaccion SMALLINT;
    DEFINE cRutaCarga CHAR(500);
    DEFINE cRutaDescarga CHAR(500);
    DEFINE cArchivoRespaldo CHAR(500);
    DEFINE cArchivoPreAp CHAR(500);
    DEFINE cRutaIfx CHAR(500);
    --DEFINE vCuentaTrx INTEGER;
	DEFINE vCuentaTrx CHAR(10);
	DEFINE cProductosOC CHAR(80);

	--SET DEBUG FILE TO "/informix/mc/Fernandorb/carga_unificada.out";
	--TRACE ON;

    LET iSqlErr ='0';
    LET vCodRet ='00000';
    LET vMensaje ='CARGA EXITOSA';
    LET vSql ='';
    LET vIdProceso ='00';
    LET vConsecutivoCte = 0;
    LET vtransaccion = 0;
    LET cRutaCarga = '';
    LET cRutaDescarga = '';
    LET cArchivoRespaldo = 'resp_migra_preaprob.unl';
    LET cArchivoPreAp = '';
    LET cRutaIfx = '';
    --LET vCuentaTrx = 0;
	LET vCuentaTrx = '';
	LET cProductosOC = '';

	SELECT TRIM(valor) INTO cRutaCarga    FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
	SELECT TRIM(valor) INTO cRutaIfx      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 7;
    SELECT TRIM(valor) INTO cRutaDescarga FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 8;
    SELECT TRIM(valor) || LPAD(MONTH(TODAY),2,0) || '-' || SUBSTR(YEAR(TODAY),3,2)|| '.txt' INTO cArchivoPreAp
	                                      FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 6;
	SELECT TRIM(valor) INTO cProductosOC  FROM bdicred:"informix".sd_pre_aprobados_param WHERE codparam = 16;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET vCodRet = '10000';
				LET vMensaje = 'ERROR AL CARGAR ARCHIVO: ' || iSqlErr;

				IF vtransaccion = 1 THEN
					ROLLBACK WORK;
				END IF;

				IF iSqlErr ='-668' THEN
					IF vIdProceso = '07' THEN
						LET vCodRet = '66802';
					END IF;

					IF vIdProceso = '00' THEN
						LET vSql = '';
						LET vSql = 'rm -rf ' || TRIM(cRutaCarga) ||'_'||TRIM(cArchivoPreAp);
						SYSTEM vSql;

						LET vMensaje = 'Archivo no localizado: ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp);
						LET vCodRet = '66800';
					END IF;
				END IF;

				RETURN vCodRet, vMensaje, vIdProceso;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-535)
			LET vtransaccion = 1;
		END EXCEPTION WITH RESUME;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--VALIDA EXISTENCIA DEL ARCHIVO ANTES DE INICIAR CON EL PROCESO DE CARGA
		 --SYSTEM "sed 's/.$//' " || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || " > " || TRIM(cRutaCarga) ||'_'|| TRIM(cArchivoPreAp);

		--SI EL ARCHIVO YA ESTA CARGADO BORRA TODO EL CONTENIDO DE TRX SIN MIGRAR A HISTORICO

		--MIGRA DATOS HISTORICOS
		LET vIdProceso = '001';
		--LET vCuentaTrx = (SELECT COUNT(*) FROM bdicred:sd_pre_aprobados_trx);
		LET vCuentaTrx = (SELECT LIMIT 1 numcte FROM bdicred:sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN ('-'));

		IF vCuentaTrx <> '' THEN
			--DESCARGA EL RESPALDO
			LET vIdProceso = '011';
			LET vSql = '';
			LET vSql = 'echo "UNLOAD TO ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) ||' DELIMITER ' || '''|''' || ' SELECT * FROM "informix".sd_pre_aprobados_trx WHERE TRIM(solicitud) NOT IN (' || '''-''' || ')"  >> ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '012';
			LET vSql = '';
			LET vSql = 'dbaccess bdicred ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '013';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || 'cmd1.sql';
			SYSTEM vSql;
			LET vIdProceso = '014';
			--CARGA RESPALDO EN TABLA HISTORICA
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo);
			SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoRespaldo)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_his;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd';
			SYSTEM ' echo "dbload -d bdicred -c '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.log' ||' -e 1000  -n 1000 -r'||
			TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			system ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoRespaldo)||'.sh';
			LET vIdProceso = '015';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.cmd';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '016';
			LET vSql = '';
			LET vSql = 'rm ' || TRIM(cRutaDescarga) || TRIM(cArchivoRespaldo) || '.sh';
			SYSTEM TRIM(vSql);
			LET vIdProceso = '017';
			LET vIdProceso = '02';
		END IF;

		TRUNCATE TABLE  "informix".sd_pre_aprobados_trx DROP STORAGE;
		SET ISOLATION TO DIRTY READ;

		LET vIdProceso = '03';

		--CARGA ARCHIVO LAYOUT
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga)|| TRIM(cArchivoPreAp);
		SYSTEM ' echo "FILE '||"'"|| TRIM(cRutaCarga)|| TRIM(cArchivoPreAp)||"'"||' DELIMITER '|| "'" || '|' || "'" || ' 296;' || '">' ||  TRIM(cRutaCarga) || TRIM (cArchivoPreAp)||'.cmd';
		SYSTEM ' echo "INSERT INTO "informix".sd_pre_aprobados_trx;' || '">> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		SYSTEM ' chmod 777 ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd';
		--SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		SYSTEM ' echo "dbload -d bdicred -i 1 -c '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.cmd' ||' -l '|| TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.log' ||'  -e 1000  -n 1000 -r'||
		TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.out' || '"> ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM ' chmod 777 '  || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';
		SYSTEM '/usr/bin/sh ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp)||'.sh';

		LET vIdProceso = '04';

		IF vtransaccion = 1 THEN
			COMMIT WORK;
			BEGIN  WORK;
		END IF;

		--BORRA ARCHIVOS TEMPORALES
		LET vIdProceso = '05';

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || '_' || TRIM(cArchivoPreAp);
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sql';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.out';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.cmd';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.log';
		SYSTEM vSql;

		LET vSql = '';
		LET vSql = 'rm -rf ' || TRIM(cRutaCarga) || TRIM(cArchivoPreAp) || '.sh';
		SYSTEM vSql;

		LET vIdProceso = '06';

		RETURN vCodRet, vMensaje, vIdProceso;
    END;
END PROCEDURE;
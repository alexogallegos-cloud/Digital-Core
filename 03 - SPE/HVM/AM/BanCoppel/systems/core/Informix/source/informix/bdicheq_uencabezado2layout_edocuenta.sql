CREATE PROCEDURE "informix".uencabezado2layout_edocuenta (pempresa char(3),pnum_credito char(20))
RETURNING CHAR(3);



DEFINE v_num_credito        char(20);
DEFINE v_num_tarjeta        char(20);
DEFINE v_maecredito         char(20);
DEFINE v_maecliente         char(20);
DEFINE v_sucursal           char(4);
DEFINE v_mes                char(5);
DEFINE v_ano                char(5);
DEFINE v_tasa_anual         char(20);
DEFINE v_tasa_mensual       char(20);
DEFINE v_cat                char(20);
DEFINE v_saldo_promedio     char(20);
DEFINE v_dias_trans         char(20);
DEFINE v_id_registro        char(3);
DEFINE v_marca              char(3);

DEFINE v_monto_financiado   decimal(18,2);
DEFINE v_sdo_cap_insoluto   decimal(18,2);
DEFINE v_abonos_mes_cap     decimal(18,2);
DEFINE v_cargos_mes_cap     decimal(18,2);
DEFINE v_disposiciones      decimal(18,2);
DEFINE v_masintereses       decimal(18,2);
DEFINE v_suma               decimal(18,2);
DEFINE v_suma_his           decimal(18,2);
DEFINE v_suma_comi          decimal(18,2);
DEFINE v_suma_comi_his      decimal(18,2);
DEFINE v_suma2	            decimal(18,2);
DEFINE v_usted_debe_ant     decimal(18,2);
DEFINE v_compras            decimal(18,2);
DEFINE v_compras_his        decimal(18,2);
DEFINE v_tasa_interes       decimal(9,3);
DEFINE v_tasa_moratorios    decimal(9,3);
DEFINE v_sdo_acum_mes_cap   decimal(18,2);
DEFINE v_dias_acum_cap      decimal(18,2);
DEFINE v_monto_otorgado     decimal(18,2);
DEFINE v_sdo_retenido       decimal(18,2);
DEFINE v_credito_disponible decimal(18,2);

DEFINE v_dia_corte	   		smallint;   
DEFINE v_fecha_hoy         	date;
DEFINE v_prox_fecha_pago   	date;
DEFINE v_fechahoy          	date;


DEFINE cod_ret             char(5);
DEFINE sql_err             integer;



--INICIALIZO VARIABLES

LET v_num_tarjeta         = "";
LET v_num_credito         = "";
LET v_maecredito          = "";
LET v_maecliente          = "";
LET v_sucursal            = "";
LET v_id_registro         = "";
LET v_marca               = "";
LET v_monto_financiado    = 0;
LET v_sdo_cap_insoluto    = 0;
LET v_abonos_mes_cap      = 0;
LET v_cargos_mes_cap      = 0;
LET v_disposiciones       = 0;
LET v_masintereses        = 0;
LET v_dia_corte	          = 0;
LET v_usted_debe_ant      = 0;
LET v_suma                = 0;
LET v_suma_his            = 0;
LET v_suma_comi           = 0;
LET v_suma_comi_his       = 0;
LET v_suma2	          	  = 0;
LET v_compras          	  = 0;
LET v_compras_his         = 0;
LET v_tasa_interes        = 0;
LET v_tasa_moratorios     = 0;
LET v_monto_otorgado      = 0;
LET v_sdo_retenido        = 0;
LET v_credito_disponible  = 0;
LET v_mes                 = "";
LET v_ano                 = "";


 

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";


  -------------------OBTENGO LA FECHA DE PROCESO-------------------------------------------------------------------

  SELECT FIRST 1 '04/20/2007' INTO v_fechahoy FROM sd_fechas;

  -------------------SE GENERA UNA LINEA PARA QUE ESTA POSTERIORMENTE SEA EL ARCHIVO DE CABECERA--------------------

	LET v_id_registro = "200";
    LET v_marca       = "0";


  IF NOT EXISTS(SELECT * FROM sd_encabezado2_edocta 
  				WHERE fecha_emision = v_fechahoy AND num_credito = v_id_registro) THEN
				INSERT INTO sd_encabezado2_edocta(
										fecha_emision,  
										num_credito,       
										sdo_pagar,      
									  	sdo_debe,       
									  	sdo_disponible,    
									  	pago_antes_de,  
									  	fecha_corte,    
									  	menos_abonos,      
									  	menos_o_abonos, 
									  	mas_compras,    
									  	mas_o_cargos,      
									  	mas_disp_efectivo, 
									  	mas_intereses,  
									  	usted_debia,       
									  	mas_iva, 
									  	usted_debe,     
									  	mas_rendimientos)
						  		   VALUES(
						  		   		v_fechahoy,     
						  		   		v_id_registro,     
						  		   		v_marca,        
										"0",            
										"0",               
										v_fechahoy,  
										v_fechahoy,     
										"0",               
										"0",            
										"0",            
										"0",               
										"0",              
										"0",            
										"0",               
										"0", 
										"0",            
										"0");
  END IF
   ------------------TRAIGO LA INFO. DE SALDOS Y MOVIMIENTOS-------------------------

   FOREACH 
	SELECT num_credito,
		   numcte,
		   sucursal,
		   tasa_interes,
		   tasa_moratorios 
	INTO v_maecredito,
		 v_maecliente, 
		 v_sucursal,
		 v_tasa_interes, 
		 v_tasa_moratorios 
	FROM sd_maecredcont 
   	WHERE empresa = pempresa AND 
   		  num_credito = pnum_credito AND 
   		  fecha = '04/30/2007'


        -----------------------OBTENGO LOS MONTOS A PROCESAR:---------------------------------------------------


	SELECT a.monto_financiado,
		   a.sdo_cap_insoluto,
		   a.monto_otorgado,
		   a.sdo_retenido,
		   a.abonos_mes_cap,
		   a.cargos_mes_cap,
		   b.prox_fecha_pago,
		   b.dia_corte,
		   a.sdo_acum_mes_cap,  
		   a.dias_acum_cap
	INTO   v_monto_financiado,
		   v_sdo_cap_insoluto,
		   v_monto_otorgado,
		   v_sdo_retenido,
		   v_abonos_mes_cap,
		   v_cargos_mes_cap,
		   v_prox_fecha_pago,
		   v_dia_corte,
		   v_sdo_acum_mes_cap,
		   v_dias_acum_cap
	FROM   sd_maesdoshist a, sd_maecredanexo b
	WHERE a.num_credito = v_maecredito 
	AND a.num_credito = b.num_credito
	AND a.fecha = v_fechahoy AND a.fecha_ult_mov = v_fechahoy;
	


        -----------------------VALIDO SI EXISTE EL REGISTRO DE SER ASI SE REPORCESA :---------------------------------------------------
--        IF EXISTS(SELECT * FROM sd_encabezado2_edocta
--                  WHERE fecha_emision = v_fechahoy AND num_credito = v_maecredito) THEN
                DELETE FROM sd_encabezado2_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_maecredito;
--        END IF

        ----------------------VERIFICO QUE TODOS LOS CAMPOS CONTENGAN INFORMACION CONDICION:---------------------

		IF v_monto_financiado IS NOT NULL AND 
		   v_sdo_cap_insoluto IS NOT NULL AND 
		   v_monto_otorgado   IS NOT NULL AND 
		   v_sdo_retenido     IS NOT NULL AND 
		   v_abonos_mes_cap   IS NOT NULL AND 
		   v_cargos_mes_cap   IS NOT NULL AND 
		   v_prox_fecha_pago  IS NOT NULL AND 
		   v_dia_corte        IS NOT NULL AND 
		   v_sdo_acum_mes_cap IS NOT NULL AND 
		   v_dias_acum_cap    IS NOT NULL 
		   THEN


			---------------------CALCULO EL CREDITO DISPONIBLE:-----------------------------------------------

			LET v_credito_disponible = (v_monto_otorgado + v_sdo_cap_insoluto) - v_sdo_retenido;

			---------------------OBTENGO SALDO ANTERIOR:-----------------------------------------------
			
			SELECT usted_debia INTO v_usted_debe_ant 
			FROM sd_encabezado2_edocta
                  	WHERE fecha_emision = (v_fechahoy - 1 UNITS MONTH)  AND 
			num_credito = v_maecredito;

			LET v_usted_debe_ant = NVL(v_usted_debe_ant,0);

			-------------------CONSULTO Y CALCULO LA SUMATORIA DEL MONTO DE SD_MOVDIA (DISPOSICIONES):---------

			SELECT 	SUM(monto) 
			INTO   	v_suma 
			FROM   	sd_movdia 
			WHERE  	num_credito = v_maecredito and 
					codigo_fun = "002" and 
					codigo_ref IN ("30","34","35","36","38","39","50");
			
			SELECT 	SUM(a.monto) 
			INTO   	v_suma_his 
			FROM   	sd_movhis a,sd_maecredanexo b
			WHERE  	a.num_credito = v_maecredito and 
					a.num_credito = b.num_credito AND
					a.codigo_fun = "002" and 
					a.codigo_ref IN ("30","34","35","36","38","39","50") AND
					a.fecha_mov >= ( (month(v_fechahoy)||'/'||b.dia_corte||'/'||year(v_fechahoy))::DATE  - 1 UNITS MONTH) + 1 UNITS DAY AND
					a.fecha_mov <= v_fechahoy ;

			-------------------CONSULTO Y CALCULO LA SUMATORIA DEL MONTO DE SD_MOVHIS (DISPOSICIONES):---------

			SELECT 	SUM(a.monto_com) 
			INTO   	v_suma_comi 
			FROM   	sd_detcomi a,sd_movdia b
			WHERE  	a.num_solicitud = b.folio_suc AND
					b.num_credito = v_maecredito;
			
			SELECT 	SUM(a.monto_com) 
			INTO   	v_suma_comi_his 
			FROM   	sd_detcomi a,sd_movhis b,sd_maecredanexo c
			WHERE  	a.num_solicitud = b.folio_suc AND
					a.num_credito = c.num_credito AND
					b.num_credito = v_maecredito AND
					b.fecha_mov >= ( (month(v_fechahoy)||'/'||c.dia_corte||'/'||year(v_fechahoy))::DATE  - 1 UNITS MONTH) + 1 UNITS DAY AND
					b.fecha_mov <= v_fechahoy ;

			--CALCULO LAS DISPOSICIONES EN EFECTIVO:
			LET v_disposiciones = NVL(v_suma,0) + NVL(v_suma_his,0) + NVL(v_suma_comi,0) + NVL(v_suma_comi_his,0);


			--------------------CONSULTO Y CALCULO LA SUMATORIA DEL MONTO (MAS INTERESES):--------------------

			SELECT SUM(monto) 
			INTO   v_suma2 
			FROM   sd_movdia 
			WHERE num_credito = v_maecredito and 
			      codigo_fun = "606" and 
			      codigo_ref = "1";

			LET v_masintereses = NVL(v_suma2,0);

			--------------------CONSULTO Y CALCULO LA SUMATORIA DE COMPRAS (MAS COMPRAS):--------------------

			SELECT 	SUM(monto) 
			INTO   	v_compras 
			FROM   	sd_movdia 
			WHERE  	num_credito = v_maecredito AND
					codigo_fun = "002" AND 
					codigo_ref IN ("37");
			
			SELECT 	SUM(a.monto) 
			INTO   	v_compras_his 
			FROM   	sd_movhis a,sd_maecredanexo b 
			WHERE  	a.num_credito = v_maecredito AND
					a.codigo_fun = "002" AND
					a.codigo_ref IN ("37") AND
					a.fecha_mov >= ( (month(v_fechahoy)||'/'||b.dia_corte||'/'||year(v_fechahoy))::DATE  - 1 UNITS MONTH) + 1 UNITS DAY AND
					a.fecha_mov <= v_fechahoy ;
					
			LET v_compras = NVL(v_compras,0)+NVL(v_compras_his,0);


			---------------------COMIENZA LA INSERCION DE DATOS:--------------------------------------------

			  INSERT INTO sd_encabezado2_edocta(fecha_emision,
			  			      	num_credito,
			  			      	sdo_pagar,
							    sdo_debe,
							    sdo_disponible,
							    pago_antes_de,
							    fecha_corte,
							    menos_abonos,
							    menos_o_abonos,
							    mas_compras,
							    mas_o_cargos,
							    mas_disp_efectivo,
							    mas_intereses,
							    usted_debia,
							    mas_iva,
							    usted_debe,
							    mas_rendimientos)
			  			VALUES(	
			  					v_fechahoy,
			  				    TRIM(v_maecredito),
			  				    v_monto_financiado,
							    v_sdo_cap_insoluto,
							    v_credito_disponible,
							    v_prox_fecha_pago,
							    v_fechahoy,
							    v_abonos_mes_cap,
							    "0",
							    v_compras,
							    "0",
							    v_disposiciones,
							    v_masintereses,
							    v_usted_debe_ant,
							    "0",
							    v_sdo_cap_insoluto,
							    "0");
			ELSE

		   		LET cod_ret = "240";

		END IF;

     END FOREACH;

  END;

  RETURN cod_ret;

END PROCEDURE;
CREATE PROCEDURE "informix".upielayout_edocuenta (pempresa char(3),pnum_credito char(20))
RETURNING CHAR(3);


DEFINE v_maecredito        char(20);
DEFINE v_maecliente	   char(20);
DEFINE v_sucursal	   char(4);
DEFINE v_tasa_anual        char(20);
DEFINE v_tasa_mensual      char(20);
DEFINE v_cat               char(20);
DEFINE v_saldo_promedio    decimal(18,2);
DEFINE v_dias_trans        char(20);
DEFINE v_id_registro       char(3);
DEFINE v_marca		   char(3);
DEFINE v_fecha_corte       char(10);
DEFINE v_mes               char(5);
DEFINE v_ano               char(5);
DEFINE v_tasa_interes	   decimal(9,3);
DEFINE v_tasa_moratorios   decimal(9,3);
DEFINE v_sdo_acum_mes_cap  decimal(18,2);
DEFINE v_dias_acum_cap     decimal(18,2);
DEFINE v_dia_corte         smallint;
DEFINE v_fechahoy          date;


DEFINE cod_ret             char(5);
DEFINE sql_err             integer;




--INICIALIZACION

LET v_maecredito       = "";
LET v_maecliente       = "";
LET v_sucursal	       = "";
LET v_tasa_anual       = ""; 
LET v_tasa_mensual     = ""; 
LET v_cat              = ""; 
LET v_saldo_promedio   = 0;
LET v_dias_trans       = "";
LET v_id_registro      = "";
LET v_marca	       = "";
LET v_fecha_corte      = "";
LET v_mes              = "";
LET v_ano              = "";

LET v_tasa_interes     = 0;
LET v_tasa_moratorios  = 0;
LET v_sdo_acum_mes_cap = 0;
LET v_dias_acum_cap    = 0;
LET v_dia_corte        = 0;

--INICIA PL



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

  ---------------------CONTROL DEL ARCHIVO------------------------------------------------

  LET v_id_registro = "400";
  LET v_marca       = "0";

  IF NOT EXISTS(SELECT * FROM sd_pie_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_id_registro) THEN
	INSERT INTO sd_pie_edocta(
				fecha_emision, 
				num_credito,   
				tasa_mensual, 
				tasa_anual,
				cat,
				saldo_promedio, 
				dias_periodo)
		   VALUES(
		   		v_fechahoy, 
		   		v_id_registro, 
		   		v_marca,
			   	"0", 
			   	"0", 
			   	"0", 
			   	"0");
  END IF	



   FOREACH 
	SELECT num_credito,   numcte,       sucursal,   tasa_interes,   tasa_moratorios 
		INTO   v_maecredito,  v_maecliente, v_sucursal, v_tasa_interes, v_tasa_moratorios 
		FROM sd_maecredcont 
        WHERE empresa = pempresa AND 
        		num_credito = pnum_credito AND 
        		fecha = '04/30/2007'


        -----------------------VALIDO SI EXISTE EL REGISTRO DE SER ASI SE REPORCESA :---------------------------------------------------
--        IF EXISTS(SELECT * FROM sd_pie_edocta
--                WHERE fecha_emision = v_fechahoy AND num_credito = v_maecredito) THEN
                DELETE FROM sd_pie_edocta WHERE fecha_emision = v_fechahoy AND num_credito = v_maecredito;
--        END IF

        -----------------------CALCULO LA FECHA DE CORTE:---------------------------------------------------

        SELECT dia_corte INTO   v_dia_corte
                FROM sd_maecredanexo WHERE  num_credito = v_maecredito;

        SELECT MONTH(fecha_hoy), YEAR(fecha_hoy) INTO v_mes,v_ano
                FROM sd_fechas WHERE  empresa = pempresa;

        LET v_fecha_corte = Trim(v_mes) || "/" || v_dia_corte || "/" || Trim(v_ano);

        -----------------------------------------------------------------------------------------------

		SELECT sdo_acum_mes_cap,    dias_acum_cap
			INTO   v_sdo_acum_mes_cap,  v_dias_acum_cap
			FROM   sd_maesdos
			WHERE  num_credito = v_maecredito;


		LET v_tasa_anual   = v_tasa_interes;
		LET v_tasa_mensual = v_tasa_interes / 12;
		LET v_cat          = 86.8494;

		-----------------------------------------------------------------------------------------------
		
		IF v_dias_acum_cap <> 0 THEN
			LET v_saldo_promedio = (v_sdo_acum_mes_cap / v_dias_acum_cap);
		ELSE
			LET v_saldo_promedio = 0;
		END IF;

        -----------------------CALCULO LOS DIAS TRANSCURRIDOS:---------------------------------------------------

		LET v_dias_trans = v_dias_acum_cap;

        ------------------------INSERTO EN LA TABLA DE SD_PIE_EDOCTA:---------------------------------------------------

		INSERT INTO sd_pie_edocta(
					fecha_emision, 
					num_credito, 
					tasa_mensual, 
					tasa_anual,     
					cat,        
					saldo_promedio, 
					dias_periodo)
				VALUES(
					v_fechahoy,     
					v_maecredito,
					v_tasa_mensual, 
					v_tasa_anual,   
					v_cat,      
					v_saldo_promedio,
					v_dias_trans);

   END FOREACH;
  
  END;

  RETURN cod_ret;

END PROCEDURE ;
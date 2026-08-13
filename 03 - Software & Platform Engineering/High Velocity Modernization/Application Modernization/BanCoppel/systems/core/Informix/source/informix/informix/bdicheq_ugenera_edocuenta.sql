CREATE PROCEDURE "informix".ugenera_edocuenta (pempresa char(3),pnum_credito char(20))
RETURNING CHAR(3);



DEFINE cod_ret         char(3);
DEFINE cod_ret1         char(3);
DEFINE cod_ret2         char(3);
DEFINE cod_ret3         char(3);
DEFINE cod_ret4         char(3);

DEFINE sql_err         integer;
DEFINE v_fechahoy      date;

 
  BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

       -------------------VALIDO QUE EXISTE EL NUMERO DE CREDITO--------------------------------------------------------

  	IF NOT EXISTS(SELECT * FROM sd_maecredcont  
  					WHERE  empresa = pempresa 
  					AND num_credito = pnum_credito
  					AND fecha = '04/30/2007') THEN
  		LET cod_ret = "205";
		RETURN cod_ret;
  	END IF

       -------------------OBTENGO LA FECHA DE PROCESO-------------------------------------------------------------------

        SELECT FIRST 1 '04/20/2007' INTO v_fechahoy FROM sd_fechas;


        EXECUTE PROCEDURE informix.uencabezadolayout_edocuenta(pempresa,pnum_credito)  INTO cod_ret;
        IF cod_ret =  "000"  THEN
		EXECUTE PROCEDURE informix.uencabezado2layout_edocuenta(pempresa,pnum_credito) INTO cod_ret;
        	IF cod_ret =  "000"  THEN
			EXECUTE PROCEDURE informix.udetallelayout_edocuenta(pempresa,pnum_credito) INTO cod_ret;
        		IF cod_ret =  "000"  THEN
				EXECUTE PROCEDURE informix.upielayout_edocuenta(pempresa,pnum_credito) INTO cod_ret;
			END IF
		END IF
	END IF
	
        IF cod_ret <> "000" THEN
                DELETE FROM sd_encabezado_edocta WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito;
                DELETE FROM sd_encabezado2_edocta WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito;
                DELETE FROM sd_detalle_edocta WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito;
                DELETE FROM sd_pie_edocta  WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito;
        END IF

  END;

  RETURN cod_ret;

END PROCEDURE ;
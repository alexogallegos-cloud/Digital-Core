CREATE PROCEDURE "informix".executaedoctabitacora(
							pempresa CHAR(3),
							pfechahoy DATE,
							ptipo CHAR(1))
RETURNING CHAR(5);


DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);


DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_descripcion 	CHAR(50);
--SET DEBUG FILE TO "ExecutaEdoCtaBitacora.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;
            RETURN v_cod_ret;
        END IF
   END EXCEPTION;


	LET v_cod_ret = "000";


	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 	FOREACH SELECT empresa,num_credito
 			INTO v_empresa,v_num_credito
 			FROM sd_valedocta 
        	WHERE fecha_proc = pfechahoy
        	AND tipo = ptipo
        
	        DELETE FROM sd_encabezado_edocta
	        WHERE fecha_emision = pfechahoy
	  		AND num_credito = v_num_credito;
	        
	        DELETE FROM sd_encabezado2_edocta
	        WHERE fecha_emision = pfechahoy
	  		AND num_credito = v_num_credito;

	        DELETE FROM sd_detalle_edocta
	        WHERE fecha_emision = pfechahoy
	  		AND num_credito = v_num_credito;

	        DELETE FROM sd_pie_edocta
	        WHERE fecha_emision = pfechahoy
	  		AND num_credito = v_num_credito;

			EXECUTE PROCEDURE ugenera_edocuenta
						(
						v_empresa,
						v_num_credito,
						pfechahoy
						) INTO v_cod_ret;
      
	      	IF v_cod_ret <> "000" THEN
	      		SELECT descripcion 
	      		INTO v_descripcion
	      		FROM bdinteg:si_codret
	      		WHERE codigo_retorno = v_cod_ret
	      		AND sistema  ="06";
	      	
      			UPDATE sd_valedocta
      			SET cod_ret = v_cod_ret,
      				descripcion = v_descripcion
      			WHERE empresa = v_empresa
      			AND num_credito = v_num_credito
      			AND fecha_proc = pfechahoy;
      		ELSE
      			UPDATE sd_valedocta
      			SET cod_ret = v_cod_ret,
      				tipo = "0",
      				descripcion = ""
      			WHERE empresa = v_empresa
      			AND num_credito = v_num_credito
      			AND fecha_proc = pfechahoy;
			END IF
 	END FOREACH;


END;

	RETURN "000";

END PROCEDURE ;
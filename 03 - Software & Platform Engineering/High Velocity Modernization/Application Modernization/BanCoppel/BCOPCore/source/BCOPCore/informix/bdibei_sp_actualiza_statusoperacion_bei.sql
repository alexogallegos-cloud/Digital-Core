CREATE PROCEDURE "informix".sp_actualiza_statusoperacion_bei(pIdOperacion INTEGER, status_oper CHAR(1), pIdusuarioCambiaStatus INTEGER)
 returning char(5) ;
--****************************************************************************************************
-- DESCRIPCION:  Modifica Status Operacion
-- AUTOR : Solser
-- FECHA : 27/06/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    SET LOCK MODE TO WAIT 4;

    
	LET cod_ret  = "00000";
	BEGIN
	   ON EXCEPTION SET sql_err
			ROLLBACK WORK;
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
			END IF ;
	   END EXCEPTION ;

	   IF(LENGTH(TRIM(NVL(status_oper, ''))) = 0) THEN
			LET cod_ret = "001"; --STATUS DE LA OPERACION VACIO
			RETURN cod_ret;
	   END IF;

	   IF(pIdOperacion <= 0 OR pIdOperacion IS NULL) THEN
			LET cod_ret = "002"; --ID DE LA OPERACION INCORRECTO
			RETURN cod_ret;
	   END IF;
	   
	   IF(NVL(pIdusuarioCambiaStatus,0) <= 0) THEN
			LET cod_ret = "003"; --ID DEL USUARIO QUE CAMBIA EL STATUS INVALIDO
			RETURN cod_ret;
	   END IF

	   UPDATE bei_operacionesmancomunadasoperador SET statusoperacion = status_oper, id_usuarioCambiaStatus = pIdusuarioCambiaStatus
	   WHERE id_operacion = pIdOperacion;

	   UPDATE bei_operacionesmancomunadasoperadorresumen SET statusoperacion = status_oper, id_usuarioCambiaStatus = pIdusuarioCambiaStatus
	   WHERE id_operacion = pIdOperacion;

	   RETURN cod_ret;
	END    
END PROCEDURE;
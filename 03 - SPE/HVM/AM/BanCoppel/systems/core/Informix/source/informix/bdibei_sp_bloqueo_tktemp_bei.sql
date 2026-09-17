CREATE PROCEDURE "informix".sp_bloqueo_tktemp_bei(pIdUsuario INTEGER,
												pFechaBloqueo DATETIME YEAR to SECOND
												)
 returning char(5);

--****************************************************************************************************
-- DESCRIPCION:  Ejecuta Proceso de Mancomuniadd
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************



 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err INTEGER;

--INICIALIZA VARIABLES
LET cod_ret  = "00000";

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
    END EXCEPTION ;

    IF NVL(pIdUsuario,-1) == -1 THEN
	 	  LET cod_ret = '00001'; -- No contiene Id de Usuario
         RETURN cod_ret;
	END IF;

	IF NVL(pFechaBloqueo,'') == '' THEN
	 	  LET cod_ret = '00002'; -- No contiene Fecha de Bloqueo
         RETURN cod_ret;
	END IF;


    	UPDATE "informix".bei_usuario SET f_bloqueo_temp=pFechaBloqueo
				WHERE  id_usuario=pIdUsuario;

	RETURN cod_ret;

	END;
END PROCEDURE;
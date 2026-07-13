CREATE PROCEDURE "informix".sp_elimina_usuario_bei(pIdUsuario INTEGER)
   returning char(5);


    DEFINE cod_ret char(5);
 	DEFINE sql_err integer ;
	LET cod_ret='00000';


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


--****************************************************************************************************
-- DESCRIPCION: elimina Usuario Bei
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

SET LOCK MODE TO WAIT 4;

		DELETE "informix".bei_usuario WHERE id_usuario=pIdUsuario ;

	  RETURN cod_ret;
END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_bloq_temp_user_bei(pNumCliente CHAR(9),pIdUsuario INTEGER,pMinute SMALLINT )
returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;


    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  Bloquea Usuario Temporalmente
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           -- ROLLBACK WORk;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

     IF NVL(pIdUsuario,-1) ==-1 THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Id Usuario
       RETURN cod_ret;
	END IF;

	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00002'; --  No contiene Dato de Numero de Cliente
	      RETURN cod_ret;
	END IF;

	IF NVL(pMinute,-1) ==-1 THEN
	 	  LET cod_ret = '00003'; --  No contiene Dato de Minutos de Bloqueo
	      RETURN cod_ret;
	END IF;

	UPDATE "informix".bei_usuario
    SET f_bloqueo_temp = (CURRENt  +   pMinute UNITS MINUTE)
	WHERE id_usuario = pIdUsuario
	AND num_cliente = pNumCliente;

  RETURN cod_ret;
END;
END PROCEDURE;
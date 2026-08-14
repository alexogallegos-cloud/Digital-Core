CREATE PROCEDURE "informix".sp_bloquea_token_bei(pNumCliente CHAR(9),pIdUsuario INTEGER,pNsToken VARCHAR(10),pIdStatusToken INTEGER)
 returning char(5) ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  Cambia Estatus Token
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;


     SET LOCK MODE TO WAIT 4;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '001'; -- Numero de Cliente Vacio
          RETURN cod_ret;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '002'; -- Nombre de Usuario Vacio
          RETURN cod_ret;
	END IF;

	IF NVL(pNsToken,0) == 0 THEN
	 	  LET cod_ret = '003'; -- Serial de Token Vacio
          RETURN cod_ret;
	END IF;

	IF NVL(pIdStatusToken,0) == 0 THEN
	 	  LET cod_ret = '004'; -- Id status  Vacio
          RETURN cod_ret;
	END IF;




        	UPDATE "informix".bei_token SET id_status_token=pIdStatusToken
			WHERE ns_token=pNsToken
			AND id_usuario=pIdUsuario
			AND num_cliente=pNumCliente;



             RETURN cod_ret;



END
END PROCEDURE;
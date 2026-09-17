CREATE PROCEDURE "informix".sp_valida_token_asociado_bei(pNumCliente CHAR(9),pIdUsuario INTEGER)
 returning char(5),SMALLINT ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE sNsToken CHAR(10);


    LET cod_ret  = "00000";
  	LET sNsToken = '';
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
          RETURN cod_ret,sNsToken;
      END IF ;
   END EXCEPTION ;


     SET LOCK MODE TO WAIT 4;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '001'; -- Numero de Cliente Vacio
         RETURN cod_ret,sNsToken;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '002'; -- Nombre de Usuario Vacio
         RETURN cod_ret,sNsToken;
	END IF;



      		SELECT ns_token
            INTO sNsToken
            FROM "informix".bei_token  btk
            WHERE btk.num_cliente  = pNumCliente
        	AND btk.id_usuario=pIdUsuario;



		IF NVL(sNsToken,0) == 0 THEN
	 	  LET cod_ret = '003'; -- Sin Token
        	RETURN cod_ret,sNsToken;
		END IF;

             RETURN cod_ret,sNsToken;



END
END PROCEDURE;
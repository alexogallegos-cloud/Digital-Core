CREATE PROCEDURE "informix".sp_modifica_estatus_user_bei(pNumCliente CHAR(9),pIdUsuario INTEGER,pIdStatus INTEGER)
 returning char(5) ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  Modifica Status Usuario
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

	IF NVL(pIdStatus,0) == 0 THEN
	 	  LET cod_ret = '003'; -- Status de Usuario Vacio
          RETURN cod_ret;
	END IF;



        	UPDATE "informix".bei_usuario SET id_status=pIdStatus
			WHERE id_usuario=pIdUsuario
			AND num_cliente=pNumCliente;



             RETURN cod_ret;

END
END PROCEDURE;
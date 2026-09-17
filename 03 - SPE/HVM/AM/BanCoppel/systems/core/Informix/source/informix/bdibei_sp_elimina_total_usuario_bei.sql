CREATE PROCEDURE "informix".sp_elimina_total_usuario_bei(pIdUsuario INTEGER,	pNumCliente CHAR(9))
   returning char(5);


    DEFINE cod_ret char(5);
 	DEFINE sql_err INTEGER ;

	DEFINE sIdPerfil INTEGER ;

	LET cod_ret='00000';
	LET sIdPerfil=0;

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

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cod_ret;
	END IF;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '002'; -- No contiene Dato de Numero de Cliente
       RETURN cod_ret;
	END IF;


      		SELECT usr_per.id_perfil
            INTO sIdPerfil
            FROM  "informix".bei_usuario_perfil  usr_per
            WHERE usr_per.id_usuario=pIdUsuario;

		IF NVL(sIdPerfil,-1) == -1 THEN
	 	  	LET cod_ret = '003'; -- No Tiene Perfil
      		RETURN cod_ret;
		END IF

		DELETE "informix".bei_usuario_perfil WHERE id_perfil=sIdPerfil AND id_usuario=pIdUsuario;

		DELETE "informix".bei_mancomunidad WHERE id_usuario=pIdUsuario AND num_cte=pNumCliente;

		DELETE "informix".bei_datos_usuario WHERE id_usuario=pIdUsuario ;

		DELETE "informix".bei_operaciones WHERE id_perfil=sIdPerfil ;

		DELETE "informix".bei_perfil WHERE id_perfil=sIdPerfil ;

		DELETE "informix".bei_usuario WHERE id_usuario=pIdUsuario ;


	  RETURN cod_ret;
END
END PROCEDURE;
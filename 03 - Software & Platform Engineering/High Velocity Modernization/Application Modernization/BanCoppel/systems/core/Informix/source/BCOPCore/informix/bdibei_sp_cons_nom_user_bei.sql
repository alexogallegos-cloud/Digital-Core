CREATE PROCEDURE "informix".sp_cons_nom_user_bei(pUsuario char(50))
   returning char(5), char (150);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sIdUsuario integer;
    DEFINE sNombre CHAR(150);

    LET cod_ret  = "000";
  	LET sIdUsuario = 0;
    LET sNombre = '';
	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS NOMBRE DE LA PERSONA , PARA VALIDACION INICIAL EMPRESANET
	-- AUTOR : Irving Guzman Salas
	-- FECHA : 26/04/2013
	-- BD: bdibei
	-- SOLICITO :
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,  sNombre;
      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;

      	SELECT dusr.nombre,usr.id_usuario INTO sNombre ,sIdUsuario
    	FROM "informix".bei_usuario as usr
    	JOIN "informix".bei_datos_usuario dusr ON usr.id_usuario=dusr.id_usuario
   		WHERE usr.usuario_bei =pUsuario;

   			IF(sIdUsuario IS NULL) OR (sIdUsuario==0) THEN
				LET cod_ret = '001';  -- Usuario NO EXISTE
			END IF;


  RETURN cod_ret,  sNombre;

END
END PROCEDURE;
CREATE PROCEDURE "informix".sps_cons_nom_user_bei(pIdUsuario Integer)
   returning char(5), char (150);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sNombre CHAR(150);

    LET cod_ret  = "000";
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

      	SELECT nombre INTO sNombre 
    	FROM bdibei:"informix".bei_datos_usuario 
   		WHERE id_usuario =pIdUsuario;

  RETURN cod_ret,  sNombre;

END
END PROCEDURE;
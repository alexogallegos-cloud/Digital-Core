CREATE PROCEDURE "informix".sp_consultatk_bei(pIdUsuario INTEGER)
 returning char(5),CHAR(10)   , INTEGER ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;



    DEFINE sNsToken CHAR(10);
    DEFINE sIdStatusToken INTEGER ;



    LET cod_ret  = "00000";


    LET sNsToken = '';
    LET sIdStatusToken = 0;

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS DE EL Token
-- AUTOR : Irving Guzman Salas
-- FECHA :
-- BD: bdibei
-- SOLICITO : SOLSER
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret,NVL(sNsToken,''), NVL(sIdStatusToken,-1);
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No ay Registros
              RETURN cod_ret,NVL(sNsToken,''), NVL(sIdStatusToken,-1);
	END IF;
     SET LOCK MODE TO WAIT 4;

            SELECT btk.ns_token,btk.id_status_token
            INTO sNsToken,sIdStatusToken
            FROM "informix".bei_token  btk
            WHERE btk.id_usuario  = pIdUsuario;



           RETURN cod_ret, NVL(sNsToken,''), NVL(sIdStatusToken,-1);

END
END PROCEDURE;
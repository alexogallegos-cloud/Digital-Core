CREATE PROCEDURE "informix".sp_consulta_user_token_bei(pNumCliente char(9))
 returning char(5), INTEGER ,  INTEGER ,CHAR (9) ,CHAR(10)   , INTEGER ,CHAR(50),CHAR(150);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;

    DEFINE sIdUsuario INTEGER;
    DEFINE sNumCliente CHAR (9);
    DEFINE sNsToken CHAR(10);
    DEFINE sIdStatusToken INTEGER ;
    DEFINE sNomUser CHAR(50);
    DEFINE sNombre CHAR(150);

    LET  iTotalReg=0;
    LET cod_ret  = "00000";
    LET sIdUsuario = 0;
    LET sNumCliente  = '';
    LET sNsToken = '';
    LET sIdStatusToken = 0;
	LET sNomUser='';
	LET sNombre='';
--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS USUARIOS Y TOKENS EXISTENTES
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret,iTotalReg, sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser,sNombre;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '001'; -- No ay Registros
          RETURN cod_ret,iTotalReg, sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser,sNombre;
	END IF;
     SET LOCK MODE TO WAIT 4;

            SELECT COUNT(*)
            INTO iTotalReg
            FROM "informix".bei_usuario  usr
            WHERE usr.num_cliente  = pNumCliente
            AND usr.id_tipo_usuario=2;

     IF iTotalReg == 0 THEN
          LET cod_ret = '002'; -- No Hay Registros
            RETURN cod_ret,iTotalReg, sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser,sNombre;
      END IF ;
--**************************************************************************************************************
--OBTIENES DATOS DE TOKEN
--**************************************************************************************************************
          FOREACH

          	SELECT  us.id_usuario,us.num_cliente,btk.ns_token,btk.id_status_token,us.usuario_bei,dat.nombre
         	INTO  sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser,sNombre
            FROM "informix".bei_usuario us
            LEFT JOIN  "informix".bei_token btk ON  us.id_usuario=btk.id_usuario
            LEFT JOIN  "informix".bei_datos_usuario dat ON  us.id_usuario=dat.id_usuario
            WHERE us.num_cliente  = pNumCliente
            AND us.id_tipo_usuario=2

           RETURN cod_ret,iTotalReg, sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser,sNombre with RESUME;
         END FOREACH;

END
END PROCEDURE;
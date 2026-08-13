CREATE PROCEDURE "informix".sp_consulta_token_bei(pNumCliente char(9))
 returning char(5),   INTEGER ,char (9) ,CHAR(10)   , INTEGER ,CHAR(50);


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;

    DEFINE sIdUsuario INTEGER;
    DEFINE sNumCliente CHAR (9);
    DEFINE sNsToken CHAR(10);
    DEFINE sIdStatusToken INTEGER ;
    DEFINE sNomUser CHAR(50);

    LET  iTotalReg=0;
    LET cod_ret  = "00000";
    LET sIdUsuario = 0;
    LET sNumCliente  = '';
    LET sNsToken = '';
    LET sIdStatusToken = 0;
	LET sNomUser='';
--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS Tokens EXISTENTES
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
             RETURN cod_ret, NVL(sIdUsuario,-1),NVL(sNumCliente,''),NVL(sNsToken,''), NVL(sIdStatusToken,-1),NVL(sNomUser,'');
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '001'; -- No ay Registros
             RETURN cod_ret, NVL(sIdUsuario,-1),NVL(sNumCliente,''),NVL(sNsToken,''), NVL(sIdStatusToken,-1),NVL(sNomUser,'');
	END IF;
     SET LOCK MODE TO WAIT 4;

            SELECT COUNT(*)
            INTO iTotalReg
            FROM "informix".bei_token  btk
            WHERE btk.num_cliente  = pNumCliente
            AND btk.ns_token NOT IN(SELECT bs.ns_token
            						FROM bei_servicio bs
            						WHERE bs.num_cliente  = pNumCliente AND bs.ns_token IS NOT NULL);

     IF iTotalReg == 0 THEN
          LET cod_ret = '002'; -- No ay Registros
      RETURN cod_ret, NVL(sIdUsuario,-1),NVL(sNumCliente,''),NVL(sNsToken,''), NVL(sIdStatusToken,-1),NVL(sNomUser,'');
      END IF ;
--**************************************************************************************************************
--OBTIENES DATOS DE TOKEN
--**************************************************************************************************************
          FOREACH

            SELECT  btk.id_usuario,btk.num_cliente,btk.ns_token,btk.id_status_token,us.usuario_bei
            INTO  sIdUsuario,sNumCliente,sNsToken, sIdStatusToken,sNomUser
            FROM "informix".bei_token  btk
            LEFT JOIN  "informix".bei_usuario us ON  us.id_usuario=btk.id_usuario
            WHERE btk.num_cliente  = pNumCliente
            AND btk.ns_token NOT IN(SELECT bs.ns_token
            						FROM bei_servicio bs
            						WHERE bs.num_cliente  = pNumCliente AND bs.ns_token IS NOT NULL)

           RETURN cod_ret, NVL(sIdUsuario,-1),NVL(sNumCliente,''),NVL(sNsToken,''), NVL(sIdStatusToken,-1),NVL(sNomUser,'') WITH RESUME;
         END FOREACH;

END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_token_manc_aut_bei(
												pNumCliente char(9),
												pIdUser integer,
												pNoReg integer,
												pRegIni integer)
   returning
   char(5),
   INTEGER,
   CHAR(10),
   INTEGER,
   CHAR(250),
   INTEGER,
   CHAR(50);



    DEFINE cod_ret 			CHAR(5);
    DEFINE sql_err 			INTEGER ;
    DEFINE iTotalReg 		INTEGER ;
    DEFINE sNsToken 		VARCHAR(10);
    DEFINE sIdStatusToken 	INTEGER ;
	DEFINE sUserNomAdmin 	CHAR(250);
	DEFINE sIdUserAdmin 	INTEGER;
    DEFINE sIdMancomunidad 	INTEGER;

    DEFINE sUserNom 	CHAR(50);
    DEFINE sIdUser 	INTEGER;



    LET  iTotalReg=0;
    LET cod_ret  = "00000";

    LET sNsToken  = '';
    LET sIdStatusToken = 0;

    LET sUserNomAdmin = '';
    LET sIdUserAdmin =0;
    LET sIdMancomunidad=0;

    LET sUserNom 	= '';
    LET sIdUser 	=0;


--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS USUARIOS OPERADOR PENDIENTES DE AUTORIZAR MODIFICACION
-- O CREACION POR MANCOMUNIDAD
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :

-- MODIFICACIÃN: Se actualiza para que retorne el nombre de usuario (sUserNomAdmin) con una longitud
-- de 250 caracteres que es la longitud resultante de una encriptaciÃ³n con HSM.
-- MODIFICO:JosÃ© Ãngel HernÃ¡ndez GonzÃ¡lez
-- FECHA:05-Diciembre-2016
-- SOLICITO: Alejandro Vazquez 
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, iTotalReg,sNsToken,sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sUserNom ;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

  SET LOCK MODE TO WAIT 4;

            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_admin_manco_temp  usu
             WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=2
            AND usu.tipo_mov=4;




     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No ay Registros
         RETURN cod_ret, iTotalReg,sNsToken,sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sUserNom ;
      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.ns_token,usu.id_status_token,us.usuario_bei,usu.id_admin_manco
            ,usu.id_usuario,usu.id_usuario_admin
            INTO  sNsToken, sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sIdUser,sIdUserAdmin
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=usu.id_usuario_admin
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=2
            AND usu.tipo_mov =4


            SELECT  usuario_bei
            INTO  sUserNom
            FROM bdibei:"informix".bei_usuario
            WHERE   id_usuario=sIdUser;

   			IF NVL(sUserNom,'') == '' THEN
	 	 		LET sUserNom = '';
			END IF;


			IF NVL(sNsToken,'') == '' THEN
	 	 		LET sNsToken = '';
			END IF;


           RETURN cod_ret, iTotalReg,sNsToken,sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sUserNom WITH RESUME;
          END FOREACH;


END
END PROCEDURE;
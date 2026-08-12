CREATE PROCEDURE "informix".sp_destoken_manc_aut_bei2(
												pNumCliente char(9),
												pIdUser integer,
												pNoReg integer,
												pRegIni integer)
   returning
   CHAR(5),
   INTEGER,
   CHAR(10),
   INTEGER,
   CHAR(50),
   INTEGER,
   CHAR(50);


    DEFINE cod_ret 			CHAR(5);
    DEFINE sql_err 			INTEGER ;
    DEFINE iTotalReg 		INTEGER ;
    DEFINE sNsToken 		VARCHAR(10);
    DEFINE sIdStatusToken 	INTEGER ;
	DEFINE sUserNomAdmin 	CHAR(50);
	DEFINE sUserNom 	CHAR(50);
	DEFINE sIdUser 	INTEGER;
    DEFINE sIdMancomunidad 	INTEGER;

    LET  iTotalReg=0;
    LET cod_ret  = "00000";

    LET sNsToken  = '';
    LET sIdStatusToken = 0;

    LET sUserNomAdmin = '';
    LET sIdMancomunidad=0;

    LET sUserNom='';


	--****************************************************************************************************
	-- DESCRIPCION: se clona y modifica el spl para mostrar el nombre de la persona en lugar de usuario
	-- AUTOR : SOLSER
	-- FECHA : NA
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	-- LIBERADO A PRODUCCION: 23-Junio-2015
	
	
	-- INFORMACION DE SPL ORIGINAL-----
	-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS USUARIOS OPERADOR PENDIENTES DE AUTORIZAR MODIFICACION
	-- O CREACION POR MANCOMUNIDAD
	-- AUTOR : Irving Guzman Salas
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO :
	--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,
            iTotalReg,
            sNsToken,
            sIdStatusToken,
            sUserNomAdmin,
            sIdMancomunidad,sUserNom;
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
            AND usu.tipo_mov=5;



     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No hay Registros
         RETURN cod_ret, iTotalReg,sNsToken,sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sUserNom;
      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************

          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.ns_token,usu.id_status_token,replace(replace(replace (trim(dtus.nombre),' ','<>' ),'><','' ),'<>',' ' ),usu.id_admin_manco
           , usu.id_usuario
            INTO  sNsToken, sIdStatusToken,sUserNomAdmin,sIdMancomunidad,sIdUser
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=usu.id_usuario_admin
            Inner Join bdibei:"informix".bei_datos_usuario dtus On(dtus.id_usuario = usu.id_usuario_admin)
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=2
            AND usu.tipo_mov =5

            SELECT replace(replace(replace (trim(nombre),' ','<>' ),'><','' ),'<>',' ' )
            INTO sUserNom
            FROM  bdibei:"informix".bei_datos_usuario
            WHERE id_usuario = sIdUser;


           RETURN cod_ret, iTotalReg,sNsToken,sIdStatusToken,SUBSTRING(sUserNomAdmin FROM 0 FOR 50),sIdMancomunidad,SUBSTRING(sUserNom FROM 0 FOR 50) WITH RESUME;
          END FOREACH;


END
END PROCEDURE;
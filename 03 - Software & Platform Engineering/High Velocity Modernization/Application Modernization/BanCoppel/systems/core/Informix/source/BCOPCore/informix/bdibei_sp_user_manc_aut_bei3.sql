CREATE PROCEDURE "informix".sp_user_manc_aut_bei3(
                                                pNumCliente CHAR(9),
                                                pIdUser integer,
                                                pNoReg integer,
                                                pRegIni integer,
                                                pIdTipoMov SMALLINT)
   returning
   CHAR(5),   INTEGER,   INTEGER,    CHAR(9),    CHAR(50),     CHAR(150),     CHAR(15),
    SMALLINT,     CHAR(50),    SMALLINT,    SMALLINT,    CHAR(50),    INTEGER,INTEGER;

    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalReg INTEGER ;

    DEFINE sIdUsuario INTEGER;
    DEFINE sNumCliente CHAR (9);
    DEFINE sIdAdminManco INTEGER;

    DEFINE sIdStatus SMALLINT ;
    DEFINE sUserNom CHAR(250);
    DEFINE sIdTipoUser SMALLINT ;
    DEFINE sNombre CHAR(150);
    DEFINE sTelCelular CHAR(15);
    DEFINE sCiaCel SMALLINT;
    DEFINE sEmail CHAR(50);

    DEFINE sUserNomAdmin CHAR(50);
    DEFINE sIdUserAdmin     INTEGER;
    DEFINE sIdUser  INTEGER;

    DEFINE sTipoMov INTEGER;

    LET  iTotalReg=0;
    LET cod_ret  = "000";
    LET sIdUsuario = 0;
    LET sNumCliente  = '';
    LET sIdStatus = 0;
    LET sUserNom = '';
    LET sIdTipoUser = 0;
    LET sIdUserAdmin = 0;
    LET sNombre = '';
    LET sTelCelular='';
    LET sCiaCel=0;
    LET sEmail='';
    LET sUserNomAdmin='';
    LET sIdAdminManco=0;
    LET sTipoMov=0;

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

    -- MODIFICACIÃN: Se actualiza para que retorne el nombre de usuario (sUserNom) con una longitud de 250
    -- caracteres que es la longitud resultante de una encriptaciÃ³n con HSM.
    -- MODIFICO:JosÃ© Ãngel HernÃ¡ndez GonzÃ¡lez
    -- FECHA:05-Diciembre-2016
    -- SOLICITO: Alejandro Vazquez 
    --***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            -- RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco ;
           RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco,sTipoMov ;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

        IF NVL(pIdTipoMov,99) <> 99 THEN
            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=1
            AND usu.tipo_mov =pIdTipoMov;
        ELSE
            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=1;
        END IF;

     SET LOCK MODE TO WAIT 4;

     IF iTotalReg == 0 THEN
          LET cod_ret = '00002'; -- No ay Registros

        --  RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco;
      RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), NVL(sNumCliente,''),NVL(sUserNom,''),NVL(sNombre,''),NVL(sTelCelular,''),NVL(sCiaCel,-1),NVL(sEmail,''),NVL(sIdStatus,-1),NVL(sIdTipoUser,-1),NVL(sUserNomAdmin,''),NVL(sIdAdminManco,-1),NVL(sTipoMov,-1);
        END IF ;

--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************
        IF NVL(pIdTipoMov,99) <> 99 THEN
          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.id_usuario,usu.num_cliente,usu.usuario_bei,usu.nombre_user,usu.tel_celular,
            usu.cia_cel,usu.e_mail,usu.id_status,usu.id_tipo_usuario,replace(replace(replace (trim(dtus.nombre),' ','<>' ),'><','' ),'<>',' ' ),usu.id_admin_manco,usu.id_usuario_admin,usu.tipo_mov
            INTO  sIdUsuario, sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco,sIdUserAdmin,sTipoMov
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=usu.id_usuario_admin
            Inner Join bdibei:"informix".bei_datos_usuario dtus On(dtus.id_usuario = us.id_usuario)
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=1
            AND usu.tipo_mov =pIdTipoMov

            If sTipoMov <> 1 Then
            SELECT replace(replace(replace (trim(nombre),' ','<>' ),'><','' ),'<>',' ' )
            INTO sUserNom
            FROM  bdibei:"informix".bei_datos_usuario
            WHERE id_usuario = sIdUsuario;
            eND IF;

         --   RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco WITH RESUME;
            RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), NVL(sNumCliente,''),SUBSTRING(sUserNom FROM 0 FOR 250),NVL(sNombre,''),NVL(sTelCelular,''),NVL(sCiaCel,-1),NVL(sEmail,''),NVL(sIdStatus,-1),NVL(sIdTipoUser,-1),SUBSTRING(sUserNomAdmin FROM 0 FOR 50),NVL(sIdAdminManco,-1),NVL(sTipoMov,-1) WITH RESUME;
          END FOREACH;
     ELSE
          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.id_usuario,usu.num_cliente,usu.usuario_bei,usu.nombre_user,usu.tel_celular,
            usu.cia_cel,usu.e_mail,usu.id_status,usu.id_tipo_usuario,replace(replace(replace (trim(dtus.nombre),' ','<>' ),'><','' ),'<>',' ' ),usu.id_admin_manco,usu.id_usuario_admin,usu.tipo_mov
            INTO  sIdUsuario, sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco,sIdUserAdmin,sTipoMov
            FROM bdibei:"informix".bei_admin_manco_temp  usu
            LEFT JOIN  bdibei:"informix".bei_usuario us ON  us.id_usuario=usu.id_usuario_admin
            Inner Join bdibei:"informix".bei_datos_usuario dtus On(dtus.id_usuario = us.id_usuario)
            WHERE  usu.num_cliente_admin  = pNumCliente
            AND usu.id_usuario_admin<>pIdUser
            AND usu.tipo_oper=1
If sTipoMov <> 1 Then
            SELECT replace(replace(replace (trim(nombre),' ','<>' ),'><','' ),'<>',' ' )
            INTO sUserNom
            FROM  bdibei:"informix".bei_datos_usuario
            WHERE id_usuario = sIdUsuario;
eND IF;

           --  RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser,sUserNomAdmin,sIdAdminManco WITH RESUME;
            RETURN cod_ret, iTotalReg,NVL(sIdUsuario,-1), NVL(sNumCliente,''),SUBSTRING(sUserNom FROM 0 FOR 250),NVL(sNombre,''),NVL(sTelCelular,''),NVL(sCiaCel,-1),NVL(sEmail,''),NVL(sIdStatus,-1),NVL(sIdTipoUser,-1),SUBSTRING(sUserNomAdmin FROM 0 FOR 50),NVL(sIdAdminManco,-1),NVL(sTipoMov,-1) WITH RESUME;
         END FOREACH;
    END IF;

END
END PROCEDURE;
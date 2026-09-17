CREATE PROCEDURE "informix".sp_consulta_usuarios_bei(
													pNumCliente char(9),
													pNoReg integer,
													pRegIni integer,
													pUserNom CHAR(50),
													pNombrem CHAR(150),
													pIdStatus smallint,
													pIdTipoUser smallint)
   returning char(5),   integer ,char (9) ,integer   , char(50),smallint, char(150),smallint,  CHAR(15),smallint, CHAR(50) ;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;

    DEFINE iTotalReg integer ;

    DEFINE sIdUsuario integer;
    DEFINE sNumCliente char (9);
    DEFINE sUserNom CHAR(50);
    DEFINE sNombre CHAR(150);
    DEFINE sTelCelular CHAR(15);
    DEFINE sCiaCel smallint;
    DEFINE sEmail CHAR(50);
    DEFINE sIdStatus smallint ;
    DEFINE sIdTipoUser smallint ;

    LET  iTotalReg=0;
    LET cod_ret  = "000";
    LET sIdUsuario = 0;
    LET sNumCliente  = '';
    LET sIdStatus = 0;
    LET sUserNom = '';
    LET sIdTipoUser = 0;
    LET sNombre = '';
    LET sTelCelular='';
    LET sCiaCel=0;
    LET sEmail='';

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE LOS DATOS DE LOS USUARIOS OPERADOR EXISTENTES
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- MODIFICACION: CONSULTA EL BLOQUEO TEMPORAL EN LA TABLA DE AVATAR
	-- FECHA LIBERACION MODIFICACION A PRODUCCION: 22-ENERO-2015
	-- MODIFICO: SOLSER
	--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN cod_ret, iTotalReg,sNumCliente,sIdUsuario, sUserNom,sIdTipoUser,sNombre,sIdStatus,sTelCelular,sCiaCel,sEmail;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE USUARIOS
--**************************************************************************************************************

   		IF NVL(pIdStatus,0) == 0 THEN

            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            WHERE usu.num_cliente  = pNumCliente
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')
            AND usu.id_tipo_usuario=pIdTipoUser;

        ELIF pIdStatus == 1000 THEN
			SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            WHERE usu.num_cliente  = pNumCliente
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')
            AND usu.id_tipo_usuario=pIdTipoUser
            AND usu.id_status IN(40,50,60,70);
        ELSE

            SELECT COUNT(*)
            INTO iTotalReg
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            WHERE usu.num_cliente  = pNumCliente
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')
            AND usu.id_tipo_usuario=pIdTipoUser
            AND usu.id_status =pIdStatus;

        END IF;

     SET LOCK MODE TO WAIT 4;

     IF iTotalReg == 0 THEN
          LET cod_ret = '002'; -- No ay Registros
          RETURN cod_ret, iTotalReg,sNumCliente,sIdUsuario, sUserNom,sIdTipoUser,sNombre,sIdStatus,sTelCelular,sCiaCel,sEmail;

      END IF ;


--**************************************************************************************************************
--OBTIENES DATOS DE USUARIO
--**************************************************************************************************************
    IF NVL(pIdStatus,0) == 0 THEN

          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.id_usuario,usu.num_cliente,usu.usuario_bei,dusr.nombre,dusr.tel_celular,dusr.cia_cel,dusr.e_mail,
            Case 
    			When av.f_bloqueo_temp is not null And av.f_bloqueo_temp > current Then 1001
    			Else usu.id_status
			End id_status, usu.id_tipo_usuario
            INTO  sIdUsuario, sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            LEFT JOIN bdibei:"informix".bei_avatar av ON (usu.id_usuario = av.id_usuario AND av.num_cliente = usu.num_cliente)
            WHERE usu.num_cliente  = pNumCliente
            AND usu.id_tipo_usuario=pIdTipoUser
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')



             RETURN cod_ret, iTotalReg,sNumCliente,sIdUsuario, sUserNom,sIdTipoUser,sNombre,sIdStatus,sTelCelular,sCiaCel,sEmail WITH RESUME;
         END FOREACH;
	ELIF pIdStatus == 1000 THEN
	      FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.id_usuario,usu.num_cliente,usu.usuario_bei,dusr.nombre,dusr.tel_celular,dusr.cia_cel,dusr.e_mail,
            Case 
    			When av.f_bloqueo_temp is not null And av.f_bloqueo_temp > current Then 1001
    			Else usu.id_status
			End id_status ,usu.id_tipo_usuario
            INTO  sIdUsuario, sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            LEFT JOIN bdibei:"informix".bei_avatar av ON (usu.id_usuario = av.id_usuario AND av.num_cliente = usu.num_cliente)
            WHERE usu.num_cliente  = pNumCliente
            AND usu.id_tipo_usuario=pIdTipoUser
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')
            AND usu.id_status IN(40,50,60,70)
			
           RETURN cod_ret, iTotalReg,sNumCliente,sIdUsuario, sUserNom,sIdTipoUser,sNombre,sIdStatus,sTelCelular,sCiaCel,sEmail WITH RESUME;
          END FOREACH;
     ELSE

          FOREACH
            SELECT  SKIP pRegIni FIRST pNoReg usu.id_usuario,usu.num_cliente,usu.usuario_bei,dusr.nombre,dusr.tel_celular,dusr.cia_cel,dusr.e_mail,
            Case 
    			When av.f_bloqueo_temp is not null And av.f_bloqueo_temp > current Then 1001
    			Else usu.id_status
			End id_status,usu.id_tipo_usuario
            INTO  sIdUsuario, sNumCliente,sUserNom,sNombre,sTelCelular,sCiaCel,sEmail,sIdStatus,sIdTipoUser
            FROM bdibei:"informix".bei_usuario  usu
            JOIN bdibei:"informix".bei_datos_usuario dusr ON dusr.id_usuario=usu.id_usuario
            LEFT JOIN bdibei:"informix".bei_avatar av ON (usu.id_usuario = av.id_usuario AND av.num_cliente = usu.num_cliente)
            WHERE usu.num_cliente  = pNumCliente
            AND usu.id_tipo_usuario=pIdTipoUser
            AND usu.usuario_bei LIKE NVL(pUserNom, '%%')
            AND dusr.nombre LIKE NVL(pNombrem, '%%')
            AND usu.id_status = pIdStatus



           RETURN cod_ret, iTotalReg,sNumCliente,sIdUsuario, sUserNom,sIdTipoUser,sNombre,sIdStatus,sTelCelular,sCiaCel,sEmail WITH RESUME;
          END FOREACH;
    END IF;

END
END PROCEDURE;
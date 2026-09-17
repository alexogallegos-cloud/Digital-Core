CREATE PROCEDURE "informix".sp_consulta_usuario_bei_historico(pIdBitacoraAdmin INTEGER)

    RETURNING CHAR(5), INTEGER, CHAR(50), CHAR(50), CHAR(150), CHAR(15), SMALLINT, CHAR(50), INTEGER;


    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;

    DEFINE sUsuario               CHAR(50);
    DEFINE sPass                  CHAR(50);
    DEFINE sNombre                CHAR(150);
    DEFINE sTelCelular            CHAR(15);
    DEFINE  sCiaCel               SMALLINT;
    DEFINE sEmail                 CHAR(50);
    DEFINE sIdPerfil              INTEGER;
    DEFINE sIdUsuario             INTEGER;

    LET cod_ret  	= "00000";
    LET sUsuario    = "";
    LET sPass       = "";
    LET sNombre     = "";
    LET sTelCelular = "";
    LET sCiaCel     = 0;
    LET sEmail      = "";
    LET sIdPerfil   = 0;
    LET sIdUsuario  = 0;

	--****************************************************************************************************
	-- DESCRIPCION: Se clona el sp sp_consulta_usuario_bei para la consulta del detalle
	-- de la operacion perfilar operador del requerimiento Bitacora Administradores
	-- AUTOR : Solser
	-- FECHA : 11/Junio/2018

	-- FECHA LIBERACIÃN PRODUCCIÃN: 07-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	--***************************************************************************************************



BEGIN

    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sIdUsuario, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;
      END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;

    IF NVL(pIdBitacoraAdmin,'') == '' THEN
        LET cod_ret = '00001'; -- No mando el idBitacoraAdmin
        RETURN cod_ret, sIdUsuario, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;
    END IF ;

    SELECT usu.id_usuario, usuario_bei, pass, nombre, tel_celular, cia_cel, e_mail, id_perfil
        INTO sIdUsuario, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil
    FROM bdibei:"informix".bei_usuario_historico usu
        JOIN bdibei:"informix".bei_datos_usuario_historico duser ON duser.id_bitacora_admin = usu.id_bitacora_admin
        JOIN bdibei:"informix".bei_usuario_perfil_historico perfil ON perfil.id_bitacora_admin = usu.id_bitacora_admin
        WHERE usu.id_bitacora_admin = pIdBitacoraAdmin;

    RETURN cod_ret, sIdUsuario, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;

END;
END PROCEDURE;
CREATE PROCEDURE "informix".sps_consulta_usuario_detalle_bei(pIdMancomunidad Integer)
   returning char(5), Integer, Integer,CHAR(250),CHAR(250),CHAR(150),CHAR(15),SMALLINT,CHAR(50),INTEGER,INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;


        DEFINE sUsuario         CHAR(250);
        DEFINE sPass            CHAR(250);
        DEFINE sNombre          CHAR(150);
        DEFINE sTelCelular      CHAR(15);
        DEFINE  sCiaCel         SMALLINT;
        DEFINE sEmail           CHAR(50);
        DEFINE sIdPerfil        INTEGER;
        DEFINE sIdAdminManco    INTEGER;
        DEFINE sTipoMov         INTEGER;
    	DEFINE sIdUsuario       INTEGER;


        LET cod_ret     = "00000";
        LET sUsuario    = "";
        LET sPass       = "";
        LET sNombre     = "";
        LET sTelCelular = "";
        LET  sCiaCel    = 0;
        LET sEmail      = "";
        LET sIdPerfil   = 0;
        LET sIdAdminManco = 0;
        LET sTipoMov    = 0;
        LET sIdUsuario=0;

--****************************************************************************************************
-- DESCRIPCION: Verifica si Nombre de Usuario ya Existe en la base de Datos
-- AUTOR : Jesus Ferruzca Luna / SOLSER
-- FECHA : 21/02/2014
-- BD: bdibei
-- SOLICITO : BanCoppel
-- LIBERADO : Mayo 2014
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sIdAdminManco, sTipoMov, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil,sIdUsuario;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************


    IF NVL(pIdMancomunidad,'') == '' THEN
          LET cod_ret = '00001'; -- No mando Nombre de Usuario Valido
        RETURN cod_ret, sIdAdminManco, sTipoMov, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil,sIdUsuario;
    END IF ;

    Select id_admin_manco, tipo_mov,usuario_bei,pass,nombre_user, tel_celular,cia_cel,e_mail,id_perfil,id_usuario
	Into sIdAdminManco, sTipoMov ,sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil ,sIdUsuario
	From bdibei:"informix".bei_admin_manco_temp
	Where id_admin_manco = pIdMancomunidad;


  RETURN cod_ret, sIdAdminManco, sTipoMov, sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil,sIdUsuario;

END
END PROCEDURE;
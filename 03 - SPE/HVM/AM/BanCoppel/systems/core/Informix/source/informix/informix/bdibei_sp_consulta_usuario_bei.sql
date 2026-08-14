CREATE PROCEDURE "informix".sp_consulta_usuario_bei(pIdUsuario Integer,pNumCliente CHAR(9))
   returning char(5), Integer,CHAR(50),CHAR(50),CHAR(150),CHAR(15),SMALLINT,CHAR(50),INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;


        DEFINE sUsuario               	CHAR(50);
        DEFINE sPass                   CHAR(50);
	    DEFINE sNombre                 CHAR(150);
        DEFINE sTelCelular             CHAR(15);
        DEFINE  sCiaCel                 SMALLINT;
        DEFINE sEmail                  CHAR(50);
	    DEFINE sIdPerfil             	INTEGER ;


    	LET cod_ret  	= "00000";
        LET sUsuario    = "";
        LET sPass       = "";
	    LET sNombre     = "";
        LET sTelCelular = "";
        LET  sCiaCel    = 0;
        LET sEmail      = "";
	    LET sIdPerfil   = 0;

--****************************************************************************************************
-- DESCRIPCION: Verifica si Nombre de Usuario ya Existe en la base de Datos
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, pIdUsuario,sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA Existencia de Nombre de Usuario
--**************************************************************************************************************

     IF NVL(pIdUsuario,'') == '' THEN
          LET cod_ret = '00001'; -- No mando Nombre de Usuario Valido
         RETURN cod_ret, pIdUsuario,sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;
      END IF ;
     IF NVL(pNumCliente,'') == '' THEN
          LET cod_ret = '00002'; -- No mando Nombre de Usuario Valido
        RETURN cod_ret, pIdUsuario,sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;
      END IF ;


            SELECT usuario_bei,pass,nombre,tel_celular,cia_cel,e_mail,id_perfil
            INTO   sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil
            FROM "informix".bei_usuario  usu
            JOIN "informix".bei_datos_usuario duser ON duser.id_usuario=usu.id_usuario
            JOIN "informix".bei_usuario_perfil perfil ON perfil.id_usuario=usu.id_usuario
            WHERE  usu.id_usuario  = pIdUsuario
            AND usu.num_cliente=pNumCliente;


   RETURN cod_ret, pIdUsuario,sUsuario, sPass, sNombre, sTelCelular, sCiaCel, sEmail, sIdPerfil;

END
END PROCEDURE;
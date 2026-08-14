CREATE PROCEDURE "informix".sp_crea_usuario_bei(pNumCliente CHAR(9),pIdStatus SMALLINT,
pUsuario CHAR(50),pPass CHAR(50),pTipoUsuario SMALLINT ,pNombrePerfil CHAR(50),
pNombre CHAR(150),pTelCel CHAR(15),pCiaCel SMALLINT,pMail CHAR(50),pIdUsuarioLogeado Integer
)returning char(5),INTEGER,INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

  	DEFINE sIdUsuario 		INTEGER ;
 	DEFINE sIdPerfil INTEGER ;


    LET cod_ret  = "00000";
    LET sIdUsuario  = 0;
    LET sIdPerfil  = 0;

--****************************************************************************************************
-- DESCRIPCION:  Crea usuario Bei
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret,sIdUsuario,sIdPerfil;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;


	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Numero de Cliente
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pIdStatus,0) == 0 THEN
	 	  LET cod_ret = '00002'; -- No contiene pIdStatus
             RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pUsuario,'') == '' THEN
	 	  LET cod_ret = '00005'; -- No contiene Nombre Usuario
           RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pPass,'') == '' THEN
	 	  LET cod_ret = '00006'; -- No contiene Password
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pTipoUsuario,0) == 0 THEN
	 	  LET cod_ret = '00007'; -- No contiene Id Tipo de Usuario
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pNombrePerfil,'') == '' THEN
	 	  LET cod_ret = '00008'; -- No contiene Nombre de Perfil
             RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pIdUsuarioLogeado,0) == 0 THEN
	 	  LET cod_ret = '00009'; -- No contiene Id Usuario Logeado
             RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pNombre,'') == '' THEN
	 	  LET cod_ret = '00010'; -- No contiene Nombre de la Persona
           RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pTelCel,'') == '' THEN
	 	  LET cod_ret = '00011'; -- No contiene Telefono Celular
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pCiaCel,0) == 0 THEN
	 	  LET cod_ret = '00012'; -- No contiene Dato Id de CompaÃ±ia Telefonica
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;

	IF NVL(pMail,'') == '' THEN
	 	  LET cod_ret = '00013'; -- No contiene Dato Email
            RETURN cod_ret,sIdUsuario,sIdPerfil;
	END IF;


            	INSERT INTO "informix".bei_perfil
				(id_perfil,nombre,activo,createdby,createdon,updatedby,updatedon) VALUES
				(0, pNombre,'t',pIdUsuarioLogeado,CURRENT YEAR TO DAY ,pIdUsuarioLogeado,CURRENT YEAR TO DAY );

				LET sIdPerfil = DBINFO('sqlca.sqlerrd1');

        		INSERT INTO "informix".bei_usuario
				(id_usuario,num_cliente,id_status,usuario_bei,pass,f_pass,f_status,f_registro,id_tipo_usuario) VALUES
				(0,pNumCliente,pIdStatus,pUsuario,pPass,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,CURRENT YEAR TO DAY,pTipoUsuario );

				LET sIdUsuario = DBINFO('sqlca.sqlerrd1');

        		INSERT INTO "informix".bei_datos_usuario
				(id_usuario,nombre,tel_celular,cia_cel,e_mail,activo) VALUES
				(sIdUsuario, pNombre,pTelCel,pCiaCel,pMail,'t' );

				INSERT INTO "informix".bei_usuario_perfil
				(id_perfil,id_usuario) VALUES
				(sIdPerfil, sIdUsuario );


         RETURN cod_ret,sIdUsuario,sIdPerfil;
END
END PROCEDURE;
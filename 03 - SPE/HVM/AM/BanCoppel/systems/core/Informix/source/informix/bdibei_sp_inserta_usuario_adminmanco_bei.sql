CREATE PROCEDURE "informix".sp_inserta_usuario_adminmanco_bei(pNumCliente CHAR(9),pIdStatus SMALLINT,
    pUsuario CHAR(250),pPass CHAR(250),pTipoUsuario SMALLINT ,pNombrePerfil CHAR(50),
    pNombre CHAR(150),pTelCel CHAR(15),pCiaCel SMALLINT,pMail CHAR(50),pIdUsuarioLogeado Integer,
    tipo_mov SMALLINT, pIdusuario INTEGER, pIdPerfil INTEGER
)returning char(5),INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
  	DEFINE Id_adminMancoTemp INTEGER ;

	DEFINE sPass                   	CHAR(250);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(250);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(250);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(250);
   	DEFINE sFpass3                  	DATE;

    LET cod_ret  = "00000";
    LET Id_adminMancoTemp  = 0;


--****************************************************************************************************
-- DESCRIPCION:  Crea usuario Bei
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :

-- MODIFICACIÃN: Se actualiza a 250 caracteres la longitud de los parametros correspondientes al usuario
-- y el password.
-- MODIFICO:JosÃ© Ãngel HernÃ¡ndez GonzÃ¡lez
-- FECHA:05-Diciembre-2016
-- SOLICITO: Alejandro Vazquez 
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret,Id_adminMancoTemp;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;


	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Numero de Cliente
            RETURN cod_ret,Id_adminMancoTemp;
	END IF;

	IF NVL(tipo_mov,0) == 0 THEN
	 	  LET cod_ret = '00014'; -- No contiene Dato tipo movimiento
            RETURN cod_ret,Id_adminMancoTemp;
	END IF;

	IF NVL(pIdUsuarioLogeado,0) == 0 THEN
	 	  LET cod_ret = '00009'; -- No contiene Id Usuario Logeado
             RETURN cod_ret,Id_adminMancoTemp;
	END IF;

	IF NVL(pIdusuario,'') <> '' AND tipo_mov == 3 AND NVL(pPass,'') <> '' THEN
           	SELECT pass,f_pass,pass1,f_pass1,pass2,f_pass2,pass3,f_pass3
            INTO sPass,sFpass,sPass1,sFpass1,sPass2,sFpass2,sPass3,sFpass3
            FROM bdibei:"informix".bei_usuario
            WHERE id_usuario=pIdUsuario;

            IF(sPass==pPass)THEN
                LET cod_ret = '00041'; -- PASSWORD Repetido
            ELIF(sPass1==pPass)THEN
                LET cod_ret = '00041'; -- PASSWORD Repetido
            ELIF(sPass2==pPass)THEN
                LET cod_ret = '00041'; -- PASSWORD Repetido
            ELIF(sPass3==pPass)THEN
                LET cod_ret = '00041'; -- PASSWORD Repetido
            END IF;

            IF(cod_ret=='00041')THEN
                RETURN cod_ret,Id_adminMancoTemp;
            END IF;
    END IF;


	    INSERT INTO informix.bei_admin_manco_temp(
            id_admin_manco,
            num_cliente_admin,
            id_usuario_admin,
            tipo_oper,
            tipo_mov,
            num_cliente
         )
        VALUES(
            0,
            pNumCliente,
            pIdUsuarioLogeado,
            1,
            tipo_mov,
            pNumCliente
        );
        LET Id_adminMancoTemp = DBINFO('sqlca.sqlerrd1');



	IF NVL(pIdStatus,0) == 0 THEN
          IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00002'; -- No contiene pIdStatus
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET id_status=pIdStatus
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pUsuario,'') == '' THEN
            IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00005'; -- No contiene Nombre Usuario
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
     ELSE
    	UPDATE informix.bei_admin_manco_temp SET usuario_bei=pUsuario
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pPass,'') == '' THEN

            IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00006'; -- No contiene Password
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;

    ELSE
    	UPDATE informix.bei_admin_manco_temp SET pass=pPass
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pTipoUsuario,0) == 0 THEN
            IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00007'; -- No contiene Id Tipo de Usuario
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET id_tipo_usuario=pTipoUsuario
    	WHERE id_admin_manco=Id_adminMancoTemp;

	END IF;

	IF NVL(pNombrePerfil,'') == '' THEN

            IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00010'; -- No contiene Nombre de la Persona
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET nom_perfil=pNombrePerfil
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;


	IF NVL(pNombre,'') == '' THEN

            IF tipo_mov == 1 THEN
	 	    	LET cod_ret = '00010'; -- No contiene Nombre de la Persona
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET nombre_user=pNombre
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pTelCel,'') == '' THEN
            IF tipo_mov == 1 THEN
	 	    	 LET cod_ret = '00011'; -- No contiene Telefono Celular
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET tel_celular=pTelCel
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pCiaCel,0) == 0 THEN
        	IF tipo_mov == 1 THEN
	 	    	  LET cod_ret = '00012'; -- No contiene Dato Id de CompaÃÂia Telefonica
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET cia_cel=pCiaCel
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pMail,'') == '' THEN

	 		IF tipo_mov == 1 THEN
	 	   	 	LET cod_ret = '00013'; -- No contiene Dato Email
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;

    ELSE
    	UPDATE informix.bei_admin_manco_temp SET e_mail=pMail
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pIdusuario,'') == '' THEN
        	IF tipo_mov <>1 THEN
	 	   	 	LET cod_ret = '00015'; -- No contiene Dato Id Usuario
      			RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET id_usuario=pIdusuario
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;

	IF NVL(pIdPerfil,'') == '' THEN
	 	   	IF tipo_mov <>1 THEN
	 	   	 	LET cod_ret = '00016'; -- No contiene Dato Id Perfil
	 	   	 	RETURN cod_ret,Id_adminMancoTemp;
	 	   	END IF;
    ELSE
    	UPDATE informix.bei_admin_manco_temp SET id_perfil=pIdPerfil
    	WHERE id_admin_manco=Id_adminMancoTemp;
	END IF;


    UPDATE informix.bei_admin_manco_temp SET activo='t'
    WHERE id_admin_manco=Id_adminMancoTemp;

 --    INSERT INTO informix.bei_admin_manco_temp(
 --           id_admin_manco,num_cliente_admin,
 --           id_usuario_admin,
 --          tipo_oper, tipo_mov, id_usuario,
 --           num_cliente, id_status,
 --          usuario_bei, pass, id_tipo_usuario,
 --           nombre_user, tel_celular, cia_cel,
 --           e_mail, activo, id_perfil,
 --           nom_perfil,
 --           ns_token,
 --           suc_registro,
 --           folio_token,
 --           id_status_token	)
 --       VALUES(
 --           0,pNumCliente,
 --          pIdUsuarioLogeado,
 --           1, tipo_mov, id_usuario,
 --           pNumCliente, 1,
 --           pUsuario, pPass,pTipoUsuario,
 --           pNombre, pTelCel, pCiaCel,
 --           pMail, 'T',  pid_perfil,
 --           pNombrePerfil,
 --           NULL, NULL, NULL,
 --           NULL
 --      );
 --       LET Id_adminMancoTemp = DBINFO('sqlca.sqlerrd1');


         RETURN cod_ret,Id_adminMancoTemp;
END
END PROCEDURE;
CREATE PROCEDURE "informix".sps_actualiza_usuario_bei(pNumCliente CHAR(9),
pIdUsuario INTEGER,
pPass CHAR(50),
pNombre CHAR(150),
pTelCel CHAR(15),
pCiaCel SMALLINT,
pMail CHAR(50),pIdUsuarioLogeado Integer,
pUsuario CHAR(50) )
 returning char(5);

    DEFINE cod_ret char(5);
    DEFINE cod_ret2 CHAR(5);
    DEFINE sql_err INTEGER ;
    DEFINE vid_tipo_usuario SMALLINT;
    DEFINE vid_status SMALLINT;

	DEFINE sPass                   	CHAR(50);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(50);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(50);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(50);
   	DEFINE sFpass3                  	DATE;

    LET cod_ret  = "00000";
    LET cod_ret2  = "00000";

    LET vid_tipo_usuario =0;
    LET vid_status=0;
    
    
	--****************************************************************************************************
	-- DESCRIPCION:  Actualiza usuario Bei
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 24/05/2013
	-- BD: bdibei
	-- SOLICITO :BanCoppel
	--
	-- MODIFICACIÓN: Se actualiza para que al recibir el dato del PASS tambien borre el registro de Avatar
	-- 		 y pase a 26 el estatus del usuario.
	-- MODIFICO:Berenice Noriega Guevara
	-- FECHA:09-Enero-2015
	-- SOLICITO: Alejandro Vazquez 
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015

	-- MODIFICACIÓN: Se actualiza para que al recibir el dato del PASS tambien borre el registro de Avatar
	-- 		 y pase a 26 el estatus del usuario, cuando el tipo de usuario es 2 (operador).
	-- MODIFICO:Berenice Noriega Guevara
	-- FECHA:29-Enero-2015
	-- SOLICITO: Alejandro Vazquez 
	
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           -- ROLLBACK WORk;
          RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

     IF NVL(pIdUsuario,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de Id Usuario
       RETURN cod_ret;
	END IF;

	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
       RETURN cod_ret;
	END IF;


	IF NVL(pIdUsuarioLogeado,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Id Usuario Logeado
        RETURN cod_ret;
	END IF;

	IF NVL(pNombre,'') == '' THEN
	 	  LET cod_ret = '0000'; -- No contiene Nombre de la Persona
    ELSE
	 		UPDATE bdibei:"informix".bei_datos_usuario SET nombre = pNombre
			WHERE id_usuario=pIdUsuario;
	END IF;


	IF NVL(pTelCel,'') == '' THEN
	 	  LET cod_ret = '00000'; -- No contiene Telefono Celular
    ELSE
    	UPDATE bdibei:"informix".bei_datos_usuario SET tel_celular = pTelCel WHERE id_usuario = pIdUsuario;
	END IF;


	IF NVL(pCiaCel,0) == 0 THEN
	 	  LET cod_ret = '00000'; -- No contiene Dato Id de CompaÃ±ia Telefonica
    ELSE
    	 	UPDATE bdibei:"informix".bei_datos_usuario SET cia_cel = pCiaCel
			WHERE id_usuario = pIdUsuario;
	END IF;


	IF NVL(pMail,'') == '' THEN
	 	  LET cod_ret = '00000'; -- No contiene Dato Email
    ELSE
    	 	UPDATE bdibei:"informix".bei_datos_usuario SET e_mail = pMail
			WHERE id_usuario = pIdUsuario;
	END IF;


  RETURN cod_ret;
END;
END PROCEDURE;
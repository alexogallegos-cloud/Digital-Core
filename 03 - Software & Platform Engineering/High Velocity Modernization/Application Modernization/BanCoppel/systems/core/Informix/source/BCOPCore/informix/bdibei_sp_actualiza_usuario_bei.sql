CREATE PROCEDURE "informix".sp_actualiza_usuario_bei(pNumCliente CHAR(9),
pIdUsuario INTEGER,
pPass CHAR(250),
pNombre CHAR(150),
pTelCel CHAR(15),
pCiaCel SMALLINT,
pMail CHAR(50),pIdUsuarioLogeado Integer,
pUsuario CHAR(250) )
 returning char(5);

    DEFINE cod_ret char(5);
    DEFINE cod_ret2 CHAR(5);
    DEFINE sql_err INTEGER ;
    DEFINE vid_tipo_usuario SMALLINT;
    DEFINE vid_status SMALLINT;

	DEFINE sPass                   	CHAR(250);
   	DEFINE sFpass                   	DATE;
   	DEFINE sPass1                    CHAR(250);
   	DEFINE sFpass1                  	DATE;
   	DEFINE sPass2                    CHAR(250);
   	DEFINE sFpass2                  	DATE;
   	DEFINE sPass3                    CHAR(250);
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

	IF NVL(pUsuario,'') =='' THEN
	 	  LET cod_ret = '00000'; -- No contiene Dato de Id Usuario
    ELSE
			UPDATE bdibei:"informix".bei_usuario
    	    SET usuario_bei=pUsuario,
    		f_actualizacion=CURRENT YEAR TO SECOND
			WHERE id_usuario=pIdUsuario;
    END IF;



	IF NVL(pNumCliente,'') =='' THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
       RETURN cod_ret;
	END IF;


	IF NVL(pIdUsuarioLogeado,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Id Usuario Logeado
        RETURN cod_ret;
	END IF;


	IF NVL(pPass,'') == '' THEN
	 	  LET cod_ret = '00000'; -- No contiene Password
    ELSE

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

		IF(cod_ret<>'00041')THEN

    		LET sPass3=sPass2;
    		LET sFpass3=sFpass2;

    		LET sPass2=sPass1;
    		LET sFpass2=sFpass1;

    		LET sPass1=sPass;
    		LET sFpass1=sFpass;

    		LET sPass=pPass;

    	    UPDATE bdibei:"informix".bei_usuario
    	    SET pass=sPass,
    	    f_pass=CURRENT YEAR TO DAY ,
    	    pass1=sPass1,
    	    f_pass1=sFpass1,
    	    pass2=sPass2,
    	    f_pass2=sFpass2,
    	    pass3=sPass3,
    	    f_pass3=sFpass3
			WHERE id_usuario=pIdUsuario;
			
		--PASA A 26 Y BORRA AVATAR OPERADORES----------------------------------------------------------------	
	
			SELECT id_tipo_usuario, id_status 
			INTO vid_tipo_usuario, vid_status
			FROM "informix".bei_usuario 
			WHERE id_usuario=pIdUsuario and num_cliente=pNumCliente;
	
			IF  vid_tipo_usuario=2 THEN
	
			INSERT INTO bdibei:"informix".bei_cambiostusuario
			   	(id_usuario,numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
				VALUES (pIdUsuario,pNumCliente, vid_status, 26, 'CambioPass', current, '5008', 'transBEI' );
		
			      	UPDATE bdibei:"informix".bei_usuario
				SET  id_status = 26
				WHERE num_cliente = pNumCliente
				AND id_usuario = pIdUsuario;
				
				
			--Borrar avatar si tiene--
			IF EXISTS (SELECT id_usuario FROM "informix".bei_avatar where id_usuario=pIdUsuario) THEN
				EXECUTE PROCEDURE "informix".sp_reset_avatar_bei(pNumCliente, pIdUsuario) into cod_ret2;
			END IF;	
				
			END IF;
			
		
		--------------------------------------------------------------------

			
			
		ELSE
			--	ROLLBACK WORk;
		 RETURN cod_ret;
		END IF;

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
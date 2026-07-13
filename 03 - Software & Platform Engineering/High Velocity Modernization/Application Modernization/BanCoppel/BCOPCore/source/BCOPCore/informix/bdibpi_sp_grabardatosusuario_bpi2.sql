CREATE PROCEDURE "informix".sp_grabardatosusuario_bpi2(pNumCliente VARCHAR(9),pNumTel VARCHAR(15),pCiaCel INT,pEmail VARCHAR(100),pAlterEmail VARCHAR(100))

RETURNING CHAR (5);
		
	DEFINE sql_err 		INT;
	DEFINE vCod_ret 	CHAR (5);
	DEFINE vNumCliente 	VARCHAR(9);
	--variables para registro en nuevas tablas
    DEFINE v_Empresa    CHAR(3); 
    DEFINE v_TipoTel    SMALLINT;
    DEFINE v_Extension  CHAR(5); 
    DEFINE v_Canal      SMALLINT;
    DEFINE v_UserInsert CHAR(8); 
    DEFINE v_codret1    CHAR(5);
    DEFINE v_codret2    CHAR(5);
    DEFINE v_TipoCorreo SMALLINT;
	DEFINE v_ExTelefono INT;
	DEFINE v_ExCorreo	VARCHAR(100);	
			
	BEGIN
		
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;

		LET vCod_ret 	 = '00000';
        LET v_Empresa    = '001';
        LET v_TipoTel    = 2; 
        LET v_Extension  = ''; 
        LET v_Canal      = 3; 
        LET v_UserInsert = 'transBPI';
        LET v_codret1 	 = '00000';
        LET v_codret2 	 = '00000';
        LET v_TipoCorreo = 1; 
		
		
		SET LOCK MODE TO WAIT 5;
		--Valida que el cliente este activo con el servicio
		SELECT numcliente INTO vNumCliente FROM bdibpi:"informix".bpi_usuario WHERE numcliente = pNumCliente AND st_portal = 'activo';
				
		IF NVL(vNumCliente, '') <> '' THEN
			
			IF EXISTS(SELECT telefono FROM bdinteg:"informix".si_telefonos_actual 	WHERE telefono = pNumTel AND tipo_tel = v_TipoTel AND carrier = pCiaCel ) THEN
				IF EXISTS(SELECT telefono FROM bdinteg:"informix".si_telefonos_actual 	WHERE telefono = pNumTel AND tipo_tel = v_TipoTel AND numcte = pNumCliente) THEN
					LET vCod_ret = '00000';
				ELSE		
					LET vCod_ret = '00002'; --Telefono del cliente ya registrado
					RETURN vCod_ret;	
				END IF
			ELSE 
				EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos(v_Empresa, pNumCliente, pNumTel, v_TipoTel, v_Extension, pCiaCel, v_Canal,v_UserInsert)
					INTO v_codret1;
				
			END IF
			
						
			IF EXISTS(SELECT correo_elec FROM bdinteg:"informix".si_correos WHERE correo_elec = LOWER(pEmail)	AND status_correo = 'A') THEN
				IF EXISTS(SELECT correo_elec FROM bdinteg:"informix".si_correos WHERE correo_elec = LOWER(pEmail)	AND status_correo = 'A' AND numcte = pNumCliente ) THEN
					LET vCod_ret = '00000';
				ELSE
					LET vCod_ret = '00003'; --Correo del cliente ya registrado
					RETURN vCod_ret;				
				END IF
			
			ELSE
			
				 EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos_bpi(v_Empresa,pNumCliente,LOWER(pEmail),v_TipoCorreo,v_Canal,v_UserInsert,pAlterEmail)
					INTO v_codret2;
					
			END IF
			
		ELSE
			LET vCod_ret = '00001'; -- Numero de cliente ya registrado
		END IF;

		RETURN vCod_ret;

	END;

END PROCEDURE
;
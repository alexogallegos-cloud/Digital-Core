CREATE PROCEDURE "informix".sp_valida_correo_ob(pRFC CHAR(13) 
                                    ,pCorreoElec CHAR(100))
RETURNING CHAR(5) AS vcodret1,
		  CHAR(100) AS vMensaje;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCorreo    SMALLINT;
	DEFINE vExisteCteCorreo INTEGER;
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE vNumCte			CHAR(20);
	DEFINE vMensaje         CHAR(50);
	DEFINE vRfc		        CHAR(50);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vExisteCorreo = 0;
	LET vExisteCteCorreo = 0;
    LET vCorreoNoValido  = 0;
	LET vNumCte = '0';
    LET vMensaje = 'SE EJECUTO CORRECTAMENTE';
    LET vRfc = '';
	
	BEGIN
		
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET vcodret3 = desc_err;
				LET vMensaje = 'ERROR AL EJECUTAR EL SP';
				RETURN vcodret1, vMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pRFC is null OR pRFC = '') OR
		   (pCorreoElec is null OR pCorreoElec = '') THEN
			LET vcodret1 = '00003';
			LET vMensaje = 'FALTAN PARÃMETROS DE ENTRADA.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
		SELECT COUNT(id)
		  INTO vCorreoNoValido
		  FROM bdinteg:"informix".si_cat_correos_novalidos
		 WHERE correo = TRIM(pCorreoElec);
		
		IF vCorreoNoValido > 0 THEN
			LET vcodret1 = '00120';
			LET vMensaje = 'EL CORREO SE ENCUENTRA EN LA LISTA DE CORREOS NO VÃLIDOS';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA SI EL CORREO YA ESTA REGISTRADO		
		SELECT COUNT(*)
		  INTO vExisteCorreo
		  FROM bdinteg:"informix".si_correos
		 WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
		   AND status_correo = 'A';
		   
		IF vExisteCorreo > 1 THEN
			LET vcodret1 = '00999';
			LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 0 THEN
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 1 THEN
			SELECT numcte
			INTO vNumCte
			FROM bdinteg:"informix".si_correos
			WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
				AND status_correo = 'A';
		
			SELECT rfc
			INTO vRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = vNumCte;
			
			IF vRfc != pRFC THEN
				LET vcodret1 = '00999';
				LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
				RETURN vcodret1, vMensaje;
			END IF;
		END IF;
   END;

   RETURN vcodret1, vMensaje;
END PROCEDURE;
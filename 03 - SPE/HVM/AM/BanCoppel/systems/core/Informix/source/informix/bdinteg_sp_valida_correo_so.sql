CREATE PROCEDURE "informix".sp_valida_correo_so( pRFC CHAR(13) 
                                                 ,pCorreoElec CHAR(100))
RETURNING CHAR(4) AS vcodret1;
    
    DEFINE vcodret1 CHAR(4);
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
    
    LET vcodret1 = '0000';
    LET vcodret2 = '0000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vExisteCorreo = 0;
	LET vExisteCteCorreo = 0;
    LET vCorreoNoValido  = 0;
	LET vNumCte = '0';
	
	BEGIN
		
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_valida_correo_so.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET vcodret3 = desc_err;
				RETURN vcodret1;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/informix/LIP/logs/sp_valida_correo_so.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pRFC is null OR pRFC = '') OR
		   (pCorreoElec is null OR pCorreoElec = '') THEN
			LET vcodret1 = '0110';
			RETURN vcodret1;
		END IF;
		
		-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
		SELECT COUNT(id)
		  INTO vCorreoNoValido
		  FROM "informix".si_cat_correos_novalidos
		 WHERE correo = TRIM(pCorreoElec);
		
		IF vCorreoNoValido > 0 THEN
			LET vcodret1 = '0120';
			RETURN vcodret1;
		END IF;
		
		-- // VERIFICA SI ES EL MISMO CLIENTE QUE ESTÃ REALIZANDO LA SOLICITUD
		SELECT numcte, COUNT(*)
		INTO vNumCte, vExisteCte
		FROM "informix".si_cliente
		WHERE rfc = pRFC
		GROUP BY 1;
		
		IF(LENGTH(vNumCte) = 0 OR vNumCte IS NULL) THEN
			LET vNumCte = '0';
		END IF;
		
		SELECT COUNT(*)
		  INTO vExisteCteCorreo
		  FROM "informix".si_correos
		 WHERE correo_elec = pCorreoElec
		   AND status_correo = 'A'
		   AND numcte = vNumCte;
		   
		IF vExisteCteCorreo > 0 THEN
			LET vcodret1 = '0002';
			RETURN vcodret1;
		END IF;
		
		
		-- // VALIDA SI EL CORREO YA ESTA REGISTRADO		
		SELECT COUNT(*)
		  INTO vExisteCorreo
		  FROM "informix".si_correos
		 WHERE correo_elec = pCorreoElec
		   AND status_correo = 'A'
		   AND numcte != vNumCte;
		   
		IF vExisteCorreo > 0 THEN
			LET vcodret1 = '0001';
			RETURN vcodret1;
		END IF;
		
   END;

   RETURN vcodret1;
END PROCEDURE;
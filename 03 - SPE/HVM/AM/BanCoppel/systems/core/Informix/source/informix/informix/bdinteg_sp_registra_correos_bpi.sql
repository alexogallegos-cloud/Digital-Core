CREATE PROCEDURE "informix".sp_registra_correos_bpi( pEmpresa CHAR(3), pNumCte CHAR(20), pCorreoElec CHAR(100), pTipoCorreo SMALLINT, pCanal SMALLINT, pUserInsert CHAR(8), pCorreoElecAlt CHAR(100) ) 
RETURNING CHAR(5);
    
    DEFINE vcodret1 CHAR(5);
    DEFINE sql_err  INTEGER;
    
    LET vcodret1 = '000';
    LET sql_err	 = 0;
       
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos.out";
    --- TRACE ON;
    
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pCorreoElec is null OR pCorreoElec = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
			LET vcodret1 = '110';
			RETURN vcodret1;
    END IF;
    
											  
    CALL sp_graba_correos( pNumCte, pCorreoElec, pTipoCorreo, pCanal, pUserInsert, '5003' ) returning vcodret1;
	
	IF (pCorreoElecAlt is not null OR pCorreoElecAlt <> '') THEN
		UPDATE bdibpi:"informix".bpi_usuario SET e_mail= pCorreoElecAlt WHERE numcliente = pNumCte AND st_portal='activo';
	END IF;	

    RETURN vcodret1;
END
END PROCEDURE;
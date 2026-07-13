CREATE PROCEDURE "informix".sp_valida_correo_bpi_pbajj(pNumCte CHAR(9), pCorreo CHAR(100), pCorreoAlterno CHAR(100))
RETURNING CHAR(5) as Cod_Ret;

DEFINE sCodRet		CHAR(5);
DEFINE iSqlErr		INTEGER;
DEFINE vExisteCorreo     INTEGER;
DEFINE vExisteCorreoAlt     INTEGER;



LEt sCodRet     =   '00000';
LET vExisteCorreo =   0;
LET vExisteCorreoAlt =   0;
LET iSqlErr		=   0;



BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet;
        END IF;
    END EXCEPTION; 	
 


	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_ctestatcorr )} COUNT(numcte) INTO vExisteCorreo FROM bdinteg:"informix".si_correos 
	WHERE numcte!=pNumCte  AND status_correo='A' AND  correo_elec = pCorreo; 
    IF LENGTH(TRIM(pCorreoAlterno))> 0 THEN
        SELECT {+INDEX(bdibpi:"informix".bpi_usuario idx_usuario3 )}COUNT(numcliente) INTO vExisteCorreoAlt FROM bdibpi:bpi_usuario
        WHERE e_mail = pCorreoAlterno AND  numcliente !=pNumCte AND st_portal = 'activo';

      
    END IF;  
 
    IF (vExisteCorreo >0 AND vExisteCorreoAlt >0 ) THEN
		LET sCodRet='00003';
	
	ELIF vExisteCorreo >0 THEN
		LET sCodRet='00001';
	ELIF vExisteCorreoAlt >0 THEN
		LET sCodRet='00002';
	END IF;
	
    
	

RETURN sCodRet;

END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_valida_ctasfrec_bex(p_NumCte CHAR(20), p_sCuenta CHAR(20))
RETURNING CHAR(5), CHAR(10);

	DEFINE vCodRet		CHAR(5);
	DEFINE vMensaje 	CHAR(10);
	DEFINE iSqlErr      INTEGER;
    
	LET vCodRet 	= '00000';
	LET vMensaje 	= '';

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
                LET vCodRet = iSqlErr;
                LET vMensaje = 'ERROR';
        END IF;
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/ireb/bdiprog/bex/sp_valida_ctasfrec_bex.out";
	--TRACE ON;
	
	IF (p_NumCte = "" ) OR (p_sCuenta = "")  THEN
		LET vCodRet = '00001';
		LET vMensaje = 'FALTA PARAM';
		RETURN vCodRet, vMensaje; 
	END IF
	
	IF EXISTS(SELECT num_cte,cuenta FROM bdiprog:pp_ctasterceros WHERE num_cte = p_NumCte AND cuenta = p_sCuenta AND cve_estado='01') THEN 
		LET vCodRet = '00002';
		LET vMensaje = 'ALTA EN BPI';
	ELSE
			IF EXISTS(SELECT num_cte,cuenta FROM bdiprog:pp_ctasterceros_bex WHERE num_cte = p_NumCte AND cuenta = p_sCuenta AND cve_estado='01') THEN 
			LET vCodRet = '00003';
			LET vMensaje = 'ALTA EN BEX';
			END IF
	END IF
	
END
RETURN vCodRet, vMensaje; 
END PROCEDURE;
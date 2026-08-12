CREATE PROCEDURE "informix".sp_obt_cta_con_cel(p_NumCel CHAR(10))
RETURNING CHAR(5), CHAR(11);

	DEFINE vCodRet		CHAR(5);
	DEFINE vCta			CHAR(11);
	DEFINE iSqlErr      INTEGER;
    
	LET vCodRet 	= '00000';
	LET vCta 	= '';

SET LOCK MODE TO WAIT 10;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
                LET vCodRet = iSqlErr;
                LET vCta = '';
        END IF;
        RETURN vCodRet, vCta;
    END EXCEPTION;
	
	IF (p_NumCel = "" ) THEN
		LET vCodRet = '00001';
		LET vCta = 'FALTA PARAM';
		RETURN vCodRet, vCta; 
	END IF
	
	
	IF (SELECT COUNT(cuenta) FROM bdicheq:sc_cuenta_telefono WHERE  es_transfer = 'N' AND telefono=p_NumCel) = 1 THEN
			SELECT cuenta INTO vCta FROM bdicheq:sc_cuenta_telefono WHERE  es_transfer = 'N' AND telefono=p_NumCel;
		ELSE
			LET vCodRet = '00002';
			RETURN vCodRet, vCta; 
	END IF
	
END
RETURN vCodRet, vCta; 
END PROCEDURE;
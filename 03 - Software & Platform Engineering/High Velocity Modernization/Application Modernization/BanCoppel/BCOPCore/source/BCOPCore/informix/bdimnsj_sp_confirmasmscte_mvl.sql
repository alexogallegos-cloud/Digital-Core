CREATE PROCEDURE "informix".sp_confirmasmscte_mvl(pTelCel CHAR(10), pNumCte CHAR(9))
	RETURNING 	CHAR(6) 	 AS sCodSMS;			
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(6);
DEFINE cSitEsp 		CHAR(5);
DEFINE iExist       INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET cCodRet 	 = "000000";
LET cSitEsp 	 = "000000";
LET iExist	    =   0;   


BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;			
			RETURN cCodRet;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    	SELECT COUNT(*) INTO iExist FROM bdinteg:"informix".si_bitsmstelsms WHERE numcte=pNumCte AND telefono=pTelCel AND DATE(fecha)=DATE(current) AND bandera='f';
	
        IF (iExist>0) THEN
    
        --IF EXISTS (SELECT * FROM bdinteg:"informix".si_bitsmstelsms WHERE numcte=pNumCte AND telefono=pTelCel AND  DATE(fecha)=DATE(current)) THEN
            foreach
            SELECT LIMIT 1 digito_ver INTO cCodRet
                FROM bdinteg:"informix".si_bitsmstelsms a
                    WHERE a.numcte=pNumCte  and a.telefono=pTelCel
                AND DATE(a.fecha)=DATE(current) ORDER BY a.fecha DESC
            end foreach;
			RETURN cCodRet;
        ELSE
            LET cCodRet='000000';
        END IF;

	SELECT COUNT(*) INTO iExist FROM bdinteg:"informix".si_bitsmstelsms_bpi WHERE numcte=pNumCte AND telefono=pTelCel AND DATE(fecha)=DATE(current) AND bandera='f';
	
	IF (iExist>0) THEN
	--IF EXISTS (SELECT * FROM bdinteg:"informix".si_bitsmstelsms_bpi WHERE numcte=pNumCte AND telefono=pTelCel AND DATE(fecha)=DATE(current)) THEN
		foreach
		SELECT LIMIT 1 digito_ver INTO cCodRet
			FROM bdinteg:"informix".si_bitsmstelsms_bpi a
				WHERE a.numcte=pNumCte  and a.telefono=pTelCel
			AND DATE(a.fecha)=DATE(current) ORDER BY a.fecha DESC
		end foreach;
		RETURN cCodRet;
	ELSE
		LET cCodRet='000000';
	END IF;
    

RETURN cCodRet; 
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_confirmasmscte(pTelCel CHAR(10), pNumCte CHAR(9))
	RETURNING 	CHAR(4) 	 AS sCodSMS;
				
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cSitEsp 		CHAR(5);

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET cCodRet 	 = "00000";
LET cSitEsp 	 = "00000";

--SET DEBUG FILE TO '/tmp/sp_valtel_ctedupout.SQL';
--TRACE ON;

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
    
        IF EXISTS (SELECT * FROM bdinteg:si_bitsmstels WHERE numcte=pNumCte AND telefono=pTelCel AND  DATE(fecha)=DATE(current)) THEN
            foreach
            SELECT LIMIT 1 {+INDEX (bdimnsj:mnsjr_trx_online idx_mnsjr_trx_online)} digito_ver INTO cCodRet
                FROM bdinteg:si_bitsmstels a
                    INNER JOIN mnsjr_trx_online b
                    ON a.telefono=b.celular_alterno
                AND DATE(a.fecha)=DATE(b.fecha1)
                AND a.numcte=pNumCte  and a.telefono=pTelCel
                AND DATE(a.fecha)=DATE(current) ORDER BY a.fecha DESC
            end foreach;
        ELSE
            LET cCodRet='0000';
        END IF;
    

RETURN cCodRet; 
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_confirmasms(pTelCel CHAR(10), pCodigo CHAR(4))
	RETURNING 	CHAR(5) 	 AS cCodRet;
				
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
	
    
        IF EXISTS (SELECT * FROM mnsjr_trx_online WHERE celular_alterno=pTelCel and string1=pCodigo and  date(fecha1)=date(current)) THEN
            LET cCodRet='00000';
        ELSE
            LET cCodRet='00001';
        END IF;
    

RETURN cCodRet; 
END;
END PROCEDURE;
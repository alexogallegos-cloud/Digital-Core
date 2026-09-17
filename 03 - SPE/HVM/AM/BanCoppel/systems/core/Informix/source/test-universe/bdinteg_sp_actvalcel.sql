CREATE PROCEDURE "informix".sp_actvalcel(pNumCte CHAR(9))
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
	
    
 
    --IF EXISTS (SELECT * FROM si_telefonos WHERE numcte=pNumCte and tipo_tel=2) THEN
       update si_telefonos set verificado='V', fecha_actualiza=current WHERE numcte=pNumCte and tipo_tel=2 and status_tel='A';
    --END IF;

RETURN cCodRet; 
END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_reversotarcentral(NumTarjetaNueva CHAR(16), iOpcion CHAR (1))

RETURNING CHAR(5);

--Declaracion de Variables.
DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;


--Asignacion de Variables.
LET cCodRet = "";
LET iSqlErr = 0;


--SET DEBUG FILE TO "/tmp/sp_reversotarcentral.out";	
--TRACE ON;													

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;								
	SET LOCK MODE TO WAIT 3;	
	
    IF iOpcion = '1' THEN
		 
			DELETE FROM bdicheq:"informix".sc_tarjeta WHERE empresa = '001' AND num_tarjeta = NumTarjetaNueva;
			LET cCodRet = "00000";   --reverso ok

	ELSE		
			DELETE FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = NumTarjetaNueva;
			LET cCodRet = "00000";   --reverso ok					
	END IF;
RETURN cCodRet;
END
END PROCEDURE
;
CREATE PROCEDURE "informix".sp_obtiene_token_vencido(pNumCliente CHAR(9))
RETURNING CHAR(5),CHAR(10);
	--25-11-2013
	--Realizo: Jose Ruben Lopez
	--obtiene el token vencido antes del proceso de reposicion
	--Solicito:Jose de Jesus Nevarez
	--BD: bdibpi
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE nsToken   		  CHAR(10);

LET nsToken='';
LET cCod_Ret='00000';
LET iSqlErr=0;
LET iSamErr=0;
LET vDesErr='';

--SET DEBUG FILE TO "/tmp/sp_obtiene_token_vencido.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret,nsToken;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
		SELECT ns_token 
		INTO nsToken
		FROM bdinteg:"informix".si_bpitoken 
		WHERE num_cliente=pNumCliente;
		
		IF (nsToken <> '' OR nsToken IS NOT NULL )THEN
			RETURN cCod_Ret,nsToken;
		ELSE
			LET cCod_Ret='00001';			RETURN cCod_Ret,nsToken;
		END IF;
END;
END PROCEDURE;
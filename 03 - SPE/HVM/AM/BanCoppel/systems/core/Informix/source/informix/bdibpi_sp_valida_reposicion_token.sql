CREATE PROCEDURE "informix".sp_valida_reposicion_token(pNumCliente CHAR(9),pNumSerieTkn CHAR(10))
RETURNING CHAR(5)
	--15-11-2013
	--Realizo: Jose Ruben Lopez
	--valida datos de la solicitud para reposicion del token
	--Solicito:Jose de Jesus Nevarez
	--BD: bdibpi
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE nsToken   		  CHAR(10);
DEFINE idStatus			  CHAR(4);
DEFINE tipoSol			  CHAR(2);

LET nsToken='';
LET idStatus='';
LET tipoSol='';
LET cCod_Ret='00000';
LET iSqlErr=0;
LET iSamErr=0;
LET vDesErr='';

--SET DEBUG FILE TO "/tmp/sp_valida_reposicion_token.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		SELECT ns_token,id_status,tipo
		INTO nsToken,idStatus,tipoSol
		FROM bdibpi:"informix".bpi_tokensolicitud
		WHERE numcte=pNumCliente
		AND ns_token=pNumSerieTkn;
		
		IF (nsToken <> '' OR nsToken IS NOT NULL )THEN
			IF(idStatus = '120') THEN
				IF(tipoSol='6' OR tipoSol='7')THEN
					RETURN cCod_Ret; 
				ELSE
					LET cCod_Ret='00003';					RETURN cCod_Ret;
				END IF;
			ELSE	
				LET cCod_Ret='00002';				RETURN cCod_Ret;
			END IF;
		ELSE
			LET cCod_Ret='00001';			RETURN cCod_Ret;
		END IF;
END;
END PROCEDURE;
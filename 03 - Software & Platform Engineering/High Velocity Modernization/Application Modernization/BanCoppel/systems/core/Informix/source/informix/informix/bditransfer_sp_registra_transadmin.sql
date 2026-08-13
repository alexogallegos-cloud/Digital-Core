CREATE PROCEDURE "informix".sp_registra_transadmin(pTipo CHAR(1),pNumCteTf CHAR(20),pFolio CHAR(12),pMpsTransactionId CHAR(12),pEjecutivo CHAR(8))
	RETURNING CHAR(5)  AS CodRet;

DEFINE cCodRet  	 CHAR(5);
DEFINE iSqlErr  	 INTEGER;

LET cCodRet  	  = '00000';
LET iSqlErr  	  = 0;
			  
--SET DEBUG FILE TO '/informix/cristo/sp_bit_actualizacte.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;
	
	IF NVL(pNumCteTf ,'') <> '' THEN
	
		INSERT INTO "informix".tf_bitacora_transadmin(numcte_tf,folio,mpstransactionid,tipo,fecha_insert,ejecutivo) 
		VALUES (pNumCteTf,pFolio,pMpsTransactionId,pTipo,CURRENT,pEjecutivo);

	END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE;
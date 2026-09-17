CREATE PROCEDURE "informix".sp_consultactepr(pEmpresa CHAR(3), pNumCteBcpl CHAR(20))
RETURNING CHAR(5), CHAR(20), CHAR(1);

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCtePr CHAR(20);
DEFINE cEstado CHAR(1);

LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '00000';
LET cNumCtePr = '';
LET cEstado = '';

--SET DEBUG FILE TO "/tmp/sp_consultactepr.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCtePr, cEstado;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCteBcpl,'') <> '' THEN
		SELECT numcte_pros, estado INTO cNumCtePr, cEstado
		FROM "informix".pr_cliente 
		WHERE empresa = pEmpresa AND numcte = pNumCteBcpl;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet, cNumCtePr, cEstado;
END;
END PROCEDURE;
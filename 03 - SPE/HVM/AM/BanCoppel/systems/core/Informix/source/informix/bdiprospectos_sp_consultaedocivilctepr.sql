CREATE PROCEDURE "informix".sp_consultaedocivilctepr(pEmpresa CHAR(3), pNumCtePr CHAR(20))
RETURNING CHAR(5), CHAR(2), CHAR(60);

DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cEdoCivil CHAR(2);
DEFINE cCantidadPersonas CHAR(60);

LET iSqlErr = 0;
LET iIsamErr = 0;
LET cCodRet = '00000';
LET cEdoCivil = '';
LET cCantidadPersonas = '';

--SET DEBUG FILE TO "/tmp/sp_consultaedocivilctepr.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cEdoCivil, cCantidadPersonas;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumCtePr,'') <> '' THEN
		SELECT b.estado_civil, a.string2 INTO cEdoCivil, cCantidadPersonas
		FROM "informix".pr_cliente a, "informix".pr_ctepf b
		WHERE a.empresa = pEmpresa AND a.empresa = b.empresa AND a.numcte_pros = pNumCtePr AND a.numcte_pros = b.numcte_pros;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00002';
		END IF;
	ELSE
		LET cCodRet = '00001';
	END IF;
	RETURN cCodRet, cEdoCivil, cCantidadPersonas;
END;
END PROCEDURE;
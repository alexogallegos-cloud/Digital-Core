CREATE PROCEDURE "informix".sp_actualizactesbcplcpl(pEmpresa CHAR(3))
RETURNING CHAR(5) AS CodigoRetorno;

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCteCoppel CHAR(20);
DEFINE cNumCte CHAR(20);

LET iSqlErr	= 0;
LET cCodRet = '00000';
LET cNumCteCoppel = '';
LET cNumCte	= '';

--SET DEBUG FILE TO "/tmp/sp_actualizactesbcplcpl.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '00001';
	ELSE
		FOREACH
			SELECT numctecoppel, numcte INTO cNumCteCoppel, cNumCte
			FROM "informix".si_adiccoppel
			WHERE tipotar = '1' 
			
			IF EXISTS(SELECT 1 FROM "informix".si_relacion_ctebcplcpl WHERE empresa = pEmpresa AND numcte_banco = cNumCte) THEN
				UPDATE "informix".si_relacion_ctebcplcpl SET cliente = cNumCteCoppel 
				WHERE empresa = pEmpresa AND numcte_banco = cNumCte;
			ELSE
				INSERT INTO "informix".si_relacion_ctebcplcpl
				(empresa,numcte_banco,cliente,numempleado,tipo_relacion,definicion,status,tipo_re_ini,fecha_insert)
				VALUES(pEmpresa,cNumCte,cNumCteCoppel,USER,1,'','1',0,TODAY);
			END IF;
			
			IF EXISTS(SELECT 1 FROM "informix".si_cliente WHERE empresa = pEmpresa AND numcte = cNumCte) THEN
				UPDATE "informix".si_cliente SET numcte_ref = cNumCteCoppel 
				WHERE empresa = pEmpresa AND numcte = cNumCte;
			END IF;
		END FOREACH;
	END IF;
	RETURN cCodRet;
END
END PROCEDURE;
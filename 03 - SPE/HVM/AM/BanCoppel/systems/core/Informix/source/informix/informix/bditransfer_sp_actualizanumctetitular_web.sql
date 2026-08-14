CREATE PROCEDURE "informix".sp_actualizanumctetitular_web(pEmpresa CHAR(3), pRFC CHAR(13), pNumCte CHAR(20))
--DATOS A REGRESAR--
RETURNING 	CHAR(6) AS CodigoRetorno,
			CHAR(1) AS BanCteTransfer;

--DEFINICION DE VARIABLES--
DEFINE cCodRet CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE iIsamErr INTEGER;
DEFINE cNumCtetf CHAR(20);
DEFINE cBanCtetf CHAR(1);

--INICIALIZACION DE VARIABLES--
LET cCodRet = '00000';
LET iSqlErr = 0;
LET iIsamErr = 0;
LET cNumCtetf = '';
LET cBanCtetf = '0';

--SET DEBUG FILE TO "/informix/IrisA/sp_actualizanumctetitular.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanCtetf;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa, '') <> '' AND NVL(pRFC, '') <> '' AND NVL(pNumCte, '') <> '' THEN

		SELECT numcte_tf 
		INTO cNumCtetf
		FROM "informix".tf_maecte 
		WHERE empresa = pEmpresa AND rfc = pRFC;

		IF NVL(cNumCtetf, '') <> '' THEN

			LET cBanCtetf = '1';

			UPDATE "informix".tf_maecte 
			SET numcte = pNumCte
			WHERE empresa = pEmpresa AND numcte_tf = cNumCtetf;

		END IF;

	END IF;

	RETURN cCodRet, cBanCtetf;

END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultabiometria(pTipo CHAR(1), pCodSuc CHAR(4), pNumCte CHAR(20))
	RETURNING 	CHAR(5) AS CodRet, 
				CHAR(1) AS SucBiometria, 
				CHAR(1) AS CteBiometria;

	--Definicion de Variables
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRet CHAR(5);
	DEFINE cSucBiometria CHAR(1);
	DEFINE cCteBiometria CHAR(1);

	--Inicializacion de Variables
	LET iSqlErr = 0;
	LET cCodRet = '000';
	LET cSucBiometria = '0';
	LET cCteBiometria = '0';

	--SET DEBUG FILE TO '/informix/IrisA/sp_consultabiometria.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cSucBiometria, cCteBiometria;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF pTipo = '1' THEN
			SELECT ibanbiometria INTO cSucBiometria
			FROM "informix".si_sucursales WHERE sucursal = pCodSuc;

			IF NVL(cSucBiometria,'') = '1' AND NVL(pNumCte,'') <> '' THEN
				SELECT tpo_biometria INTO cCteBiometria
				FROM "informix".si_cliente WHERE numcte = pNumCte;
			END IF;

		ELSE
			LET cCodRet = '001'; -- No Existe el Tipo de Consulta
		END IF;

		RETURN cCodRet, NVL(cSucBiometria,''), NVL(cCteBiometria,'');
	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consfoliokelloggs(pEmpresa CHAR(3), pNumFolio CHAR(7))
RETURNING CHAR(5) AS CodRet, CHAR(5) As CodRet2;

--Definicion de Variables
DEFINE cCodRet 		CHAR(5);
DEFINE cCodRet2		CHAR(5);
DEFINE iSqlErr 		INTEGER;
DEFINE cEntregado	CHAR(1);

--Inicializacion de Variables
LET cCodRet    = '00000';
LET cCodRet2   = '00000';
LET cEntregado = '';

--SET DEBUG FILE TO '/tmp/sp_consfoliokelloggs.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
		RETURN cCodRet, cCodRet2;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

	IF (pEmpresa IS NULL OR pEmpresa = '') OR (pNumFolio IS NULL OR pNumFolio = '') THEN
		LET cCodRet2 = '00001';
	ELSE
		SELECT entregado INTO cEntregado 
		FROM sc_promocion_kelloggs
		WHERE empresa = pEmpresa AND folio = pNumFolio;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet2 = '00002';
		ELSE
			IF cEntregado = '1' THEN
				LET cCodRet2  = '00003';
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, cCodRet2;
END;
END PROCEDURE

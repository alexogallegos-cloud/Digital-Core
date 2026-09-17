CREATE PROCEDURE "informix".sp_obtieneparametro_tf_web
(
	pEmpresa 		CHAR(03),
	pCodParam 		INTEGER
)

RETURNING
	CHAR(5) 	AS cCodRet,
	CHAR(60)	AS cValor;

--DECLARACION DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(5);
DEFINE cValor		CHAR(60);

--INICIALIZACION DE VARIABLES
LET cCodRet	= '00000';
LET cValor 	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_obtieneparametro_tf_web.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cValor;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARAMETROS VACIOS Y NULOS
	LET pEmpresa 	= TRIM(pEmpresa);
	
	IF NVL(pEmpresa,'') = '' OR NVL(pCodParam, -1) = -1 THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cValor;
	END IF;
	
	SELECT valor
	INTO cValor
	FROM bditransfer:"informix".tf_param
	WHERE empresa = pEmpresa AND cod_param = pCodParam;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cValor 	= '';
		RETURN cCodRet, cValor;
	END IF;
	RETURN cCodRet, cValor;
END;
END PROCEDURE

DOCUMENT
'Realiza una simple consulta para obtener un campo de la tabla tf_param',
'AUTOR : 95579737 - JosÃÂ© Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'BD    : bditransfer';
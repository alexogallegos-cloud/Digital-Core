CREATE PROCEDURE "informix".sp_obtiene_datos_trama_tf_web(pID SMALLINT)

RETURNING
CHAR(5) 	AS cCodRet,
SMALLINT 	AS sTran,
CHAR(128)	AS sNomWebService;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE sTran 			SMALLINT;
DEFINE sNomWebService	CHAR(128);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet			= '00000';
LET sTran			= 0;
LET sNomWebService	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_obtiene_datos_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, sTran, sNomWebService;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARÃMETROS VACÃOS O NULOS
	IF pID IS NULL THEN
		LET cCodRet = '00001';
		RETURN cCodRet, sTran, sNomWebService;
	END IF
	
	SELECT transaccion, nombre
	INTO sTran, sNomWebService
	FROM bditransfer:"informix".tf_web_services
	WHERE id = pID;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET sTran = 0;
		LET sNomWebService = '';
		RETURN cCodRet, sTran, sNomWebService;
	END IF
	RETURN cCodRet, sTran, sNomWebService;

END;
END PROCEDURE

DOCUMENT
'Realiza una consulta con los parÃ¡metros de entrada',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : 22/Abril/2014',
'BD    : bditransfer';
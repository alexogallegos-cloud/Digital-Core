CREATE PROCEDURE "informix".sp_error_trama_tf_web
(
	pTran 			SMALLINT,
	pReturnCode 	CHAR(20),
	pErrorDes		CHAR(256),
	pCtaTransfer	CHAR(20)
)

RETURNING
CHAR(5) AS cCodRet;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err			INTEGER;
DEFINE cCodRet			CHAR(5);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet			= '00000';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_error_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARÃMETROS VACÃOS O NULOS
	IF pTran IS NULL OR NVL(TRIM(pReturnCode), '') = '' OR NVL(TRIM(pErrorDes), '') = '' OR NVL(TRIM(pCtaTransfer), '') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet;
	ELSE
		INSERT INTO bditransfer:"informix".tf_error(id_transaccion, codigo_error, descripcion, cuenta_transfer,	fecha_insert)
		VALUES(pTran, pReturnCode, pErrorDes, pCtaTransfer, CURRENT);
		RETURN cCodRet;
	END IF
END;
END PROCEDURE

DOCUMENT
'Realiza un insert a la tabla, la cual guarda los errores ocasionados',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : 22/Abril/2014',
'BD    : bditransfer';
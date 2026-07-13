CREATE PROCEDURE "informix".sp_tf_registraerror_web(pNumTran SMALLINT,pCodRet INTEGER,pDescripcion CHAR(256),pCuenta CHAR(20)) --PARAMETROS DE ENTRADA

RETURNING CHAR(5) AS Codigo_Retorno; --CODIGO DE RETORNO

--DEFINICION DE LAS VARIABLES
DEFINE 	iSqlErr			INTEGER;
DEFINE 	cCodRet 		CHAR(5);
DEFINE 	dFechaHoy		DATE;

--INICIALIZACION DE LAS VARIABLES
LET iSqlErr			=	0;
LET	cCodRet			=	'00000';
LET	dFechaHoy		=	'';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_registraerror_web.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	--VALIDA ERRORES DE PARAMETROS
	IF NVL(pNumTran,0) = 0 OR NVL(pCodRet,0) = 0 OR NVL(pDescripcion,'') = '' OR NVL(pCuenta,'') = '' THEN
		LET cCodRet='00001';		RETURN cCodRet;
	END IF;
	
	--SELECCIONA LA FECHA DEL DIA DE HOY PARA SER INSERTADA EN LA TABLA tf_error
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa='001';
	
	INSERT INTO "informix".tf_error (id_transaccion,codigo_error,descripcion,cuenta_transfer,fecha_insert)
	VALUES (pNumTran,TO_CHAR(pCodRet),TRIM(pDescripcion),TRIM(pCuenta),dFechaHoy);
		
		--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet	= '00002';			RETURN cCodRet;
		END IF;
		
	RETURN cCodRet;	
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 JesÃÂÃÂºs Ernesto Aguilera Inda.',
'DESCRIPCIÃÂÃÂN: Graba errores generados durante la transacciÃÂÃÂ³n 9002 de transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃÂÃÂN: 20140527.1040',
'BASE DE DATOS: bditransfer';
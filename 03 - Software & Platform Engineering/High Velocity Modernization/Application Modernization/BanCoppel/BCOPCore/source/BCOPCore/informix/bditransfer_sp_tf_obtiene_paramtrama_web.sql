CREATE PROCEDURE "informix".sp_tf_obtiene_paramtrama_web(pId SMALLINT)

RETURNING	CHAR(5) AS Codigo_Retorno, SMALLINT AS Transaccion, CHAR(128) AS WebService;

--DECLARACION DE LAS VARIABLES
DEFINE	iSqlErr	 INTEGER;
DEFINE	sTrans	 SMALLINT;
DEFINE	cCodRet	 CHAR(5);
DEFINE	cWebServ CHAR(128);

--INICIALIZACION DE LAS VARIABLES
LET	iSqlErr 	=0;	
LET sTrans		=0;
LET cCodRet		='00000';
LET cWebServ	='';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_obtiene_paramtrama_web.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,sTrans,TRIM(cWebServ);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pId,0) = 0 THEN
		LET cCodRet='00001';
		RETURN cCodRet,sTrans,TRIM(cWebServ);
	END IF;
	--SELECCIONA LA TRANSACCION Y EL NOMBRE CONTRA EL CAMPO ID
	SELECT transaccion, nombre
	INTO sTrans, cWebServ
	FROM "informix".tf_web_services
	WHERE id=pId;
	
	--VALIDA CUALQUIER ERROR DURANTE LA EJECUCION
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		RETURN cCodRet,sTrans,TRIM(cWebServ);
	END IF;
	RETURN cCodRet,sTrans,TRIM(cWebServ);
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 JesÃÂÃÂºs Ernesto Aguilera Inda.',
'DESCRIPCIÃÂÃÂN: SP que obtiene el nombre del servicio web a utilizar por transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃÂÃÂN: 20140527.1040',
'BASE DE DATOS: bditransfer';
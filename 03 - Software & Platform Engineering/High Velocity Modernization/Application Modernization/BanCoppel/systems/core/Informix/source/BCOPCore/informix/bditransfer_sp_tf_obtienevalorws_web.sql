CREATE PROCEDURE "informix".sp_tf_obtienevalorws_web(pEmpresa CHAR(3),pTransaccion CHAR(5),pIdServicio INTEGER)

RETURNING	CHAR(5) AS Codigo_Retorno, 
			CHAR (17) AS Valor_Num,
			CHAR(100) AS Valor_Alfa,
			CHAR(100) AS Descripcion;

--DECLARACION DE LAS VARIABLES
DEFINE iSqlErr		INTEGER;
DEFINE cCodRet		CHAR(5);
DEFINE cValorNum	CHAR(17);
DEFINE cValorAlfa	CHAR(100);
DEFINE cDescripcion CHAR(100);

--INICALIZACION DE LAS VARIABLES
LET iSqlErr			=0;
LET	cCodRet			='00000';
LET	cValorNum		='';
LET	cValorAlfa		='';
LET cDescripcion	='';

-- SET DEBUG FILE TO '/dbexportb/ernestoaguilera/sp_tf_obtienevalorws_web.out';
-- TRACE ON; 

BEGIN
	
	--CONTROL DE ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
		END IF;
	END EXCEPTION;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--VALIDA ERRORES DE LOS PARAMETROS
	IF NVL(pEmpresa,'') = '' OR NVL(pTransaccion,'') = '' OR NVL(pIdServicio,0) = 0 THEN
		LET cCodRet='00001';
		RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
	END IF;
	
	FOREACH
		SELECT valor_numerico,valor_alfabetico,descripcion
		INTO cValorNum,cValorAlfa,cDescripcion
		FROM "informix".tf_param_tiposerv
		WHERE empresa=pEmpresa
		AND transaccion=pTransaccion
		AND	id_trans=pIdServicio
		
		RETURN cCodRet, cValorNum,cValorAlfa,TRIM(cDescripcion) WITH RESUME;
		
	END FOREACH
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		RETURN cCodRet, TRIM(cValorNum),TRIM(cValorAlfa),TRIM(cDescripcion);
	END IF;
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95281495 Jesus Ernesto Aguilera Inda.',
'DESCRIPCION: Consulta el valor de la tabla tf_param y mandarlo por parametro utilizado en transfer.',
'FOLIO:1439',
'FECHA:27/05/2014',
'VERSIÃÂÃÂ?N: 20140527.1040',
'BASE DE DATOS: bditransfer';
CREATE PROCEDURE "informix".sp_bf_carga_datos( pNombreArchivo VARCHAR (20))
	RETURNING CHAR(5) AS cCodRet, CHAR(100) AS cEstatus;

	
	DEFINE cCodRet					CHAR(5);
	DEFINE cEstatus					CHAR(100);
	DEFINE iIsamErr					INTEGER;
	DEFINE iErrorInfo				CHAR(40);
	DEFINE iSqlErr					INTEGER;
	DEFINE cSql						CHAR(250);
	DEFINE vRutaArchivo				VARCHAR(50);
	DEFINE vNombreArchivo			VARCHAR(50);

	LET cEstatus				= 'Proceso Exitoso.';
	LET cCodRet					= '00000';
	LET iIsamErr				= 0;
	LET iErrorInfo				= '';
	LET iSqlErr 				= 0;
	LET cSql 					='';
	

	LET vRutaArchivo			= '/RESPALDOSNEW/';
	LET vNombreArchivo			= pNombreArchivo;
	
	
BEGIN
	
	-- Manejo de error
	ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
		
		--SET DEBUG FILE TO "/RESPALDOSNEW/" || DAY(CURRENT) || MONTH(CURRENT) || YEAR(CURRENT) || ".out";
		--TRACE ON;
		
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cEstatus = 'ERROR EN EL PROCESO ' || iIsamErr || ' ' || iErrorInfo;
			RETURN cCodRet, cEstatus;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
		--Lectura de archivo para llenar tabla temporal
		LET cSql = '';
		LET cSql = "echo " || '"' || "FILE '" || TRIM(vRutaArchivo) || TRIM(vNombreArchivo) || "' delimiter '" || '|' || "' " || '9' || "; INSERT INTO " || 'td_carga_archivo_sat' || ";" || '"' || ' > ' || TRIM(vRutaArchivo) || 'paso1.txt';
		SYSTEM cSql;
		
		LET cSql = '';
		LET cSql = "chmod 777 " || TRIM(vRutaArchivo) || 'paso1.txt';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = "dbload -d bditarjeta -c " || TRIM(vRutaArchivo) || 'paso1.txt' || " -l " || TRIM(vRutaArchivo) || 'paso1.log' || " -n " || 1000 || " -r > " || TRIM(vRutaArchivo) || 'paso1_rep.log';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql = 'rm ' || TRIM(vRutaArchivo) || 'paso1.txt';
		SYSTEM cSql;

		LET cSql = '';  
		LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1.log';
		SYSTEM cSql;

		LET cSql = '';
		LET cSql ='rm ' || TRIM(vRutaArchivo) || 'paso1_rep.log';
		SYSTEM cSql;
	
	RETURN cCodRet, cEstatus;
	
END;	
END PROCEDURE
;
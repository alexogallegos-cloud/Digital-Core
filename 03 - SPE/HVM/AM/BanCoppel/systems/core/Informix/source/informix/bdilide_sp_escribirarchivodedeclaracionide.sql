CREATE PROCEDURE "informix".sp_escribirarchivodedeclaracionide(p_cArchivo CHAR(20))
RETURNING CHAR(6),CHAR(25);

-- DEFINICION DE VARIABLES
DEFINE v_cCodRet                CHAR(6);
DEFINE iSqlErr                  INTEGER;

DEFINE v_cStmt                  CHAR(250);
DEFINE v_cFile                  CHAR(25);
DEFINE v_cFileTemp              CHAR(25);
DEFINE v_cFileGz                CHAR(25);
DEFINE v_cRutaServer            CHAR(67);

--INICIALIZACION DE VARIABLES--
LET v_cCodRet = "000000";
LET iSqlErr = 0;
LET v_cStmt = '';
LET v_cFileTemp = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) ||'.tmp';
LET v_cFileGz = SUBSTRING(TRIM(p_cArchivo) FROM 1 FOR LENGTH(TRIM(p_cArchivo)) - 4) ||'.gz';
LET v_cRutaServer = '';

--  SET DEBUG FILE TO "/respaldosbd/mc/ide.out";
-- TRACE ON;

SELECT desc_valor
INTO v_cRutaServer
FROM bdilide:sl_parametros
WHERE cve_param = 11
AND valor = 01;

BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET v_cCodRet = iSqlErr;
			RETURN v_cCodRet,v_cFileGz;
		END IF;
	END EXCEPTION;

	LET v_cStmt = 'echo "UNLOAD TO '''|| TRIM(v_cRutaServer)|| TRIM(v_cFileTemp) ||''' SELECT registro FROM sl_archivoxml WHERE nomarchivo =''' || TRIM(p_cArchivo)||''' ORDER BY consecutivo;" > '|| TRIM(v_cRutaServer)||'tmp.sql';
	SYSTEM v_cStmt;

	LET v_cStmt = 'chmod 667 '|| TRIM(v_cRutaServer)||'tmp.sql';
	SYSTEM v_cStmt;

	LET v_cStmt = 'dbaccess bdilide '|| TRIM(v_cRutaServer)||'tmp.sql';
	SYSTEM v_cStmt;

	LET v_cStmt = 'chmod 667 '|| TRIM(v_cRutaServer)||TRIM(v_cFileTemp);
	SYSTEM v_cStmt;

	LET v_cStmt = "sed 's/|$//g' "|| TRIM(v_cRutaServer) || TRIM(v_cFileTemp)|| " > " || TRIM(v_cRutaServer)|| TRIM(p_cArchivo);
	SYSTEM v_cStmt;

	LET v_cStmt = 'rm -f '|| TRIM(v_cRutaServer)||'tmp.sql';
	SYSTEM v_cStmt;

	LET v_cStmt = 'rm -f '|| TRIM(v_cRutaServer)||TRIM(v_cFileTemp);
	SYSTEM v_cStmt;

	LET v_cStmt = 'gzip -c9 '|| TRIM(v_cRutaServer)||TRIM(p_cArchivo)|| ' > '|| TRIM(v_cRutaServer)||TRIM(v_cFileGz);
	SYSTEM v_cStmt;

	LET v_cStmt = 'rm -f '|| TRIM(v_cRutaServer)||TRIM(p_cArchivo);
	SYSTEM v_cStmt;

    --DELETE FROM bdilide:sl_archivoxml WHERE nomarchivo = p_cArchivo;

	RETURN v_cCodRet,v_cFileGz;
END;
END PROCEDURE

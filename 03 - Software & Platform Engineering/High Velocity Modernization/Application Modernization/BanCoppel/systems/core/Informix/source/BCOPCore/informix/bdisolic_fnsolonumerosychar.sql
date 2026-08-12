CREATE FUNCTION "informix".fnsolonumerosychar(pCadena CHAR(255))
RETURNING CHAR(255) AS ESCRITURA;

DEFINE cCodRet			CHAR(6);
DEFINE cLetra			CHAR(10);
DEFINE cEscritura		CHAR(255);
DEFINE iSqlErr			SMALLINT;
DEFINE iCantVueltas		SMALLINT;
DEFINE iNumCaracter		SMALLINT;

LET cCodRet				= '000000';
LET cLetra				= '';
LET cEscritura			= '';
LET iSqlErr				= 0;
LET iCantVueltas		= 0;
LET iNumCaracter		= 0;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			
			RETURN cEscritura;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/Antonio/fnsolonumerosychar.out";
	--TRACE ON;
	
	LET iCantVueltas = LENGTH(pCadena);
	FOR iNumCaracter = 1 TO iCantVueltas
		LET cLetra = '';
		LET cLetra = SUBSTR(pCadena,iNumCaracter,1);
		IF (cLetra  BETWEEN 'A' AND 'Z' OR cLetra = 'Ñ' ) THEN		
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra BETWEEN 'a' AND 'z' OR cLetra = 'ñ' THEN
			LET cEscritura = TRIM(cEscritura) || cLetra;			
		ELIF cLetra = ' ' THEN
			LET cEscritura = TRIM(cEscritura) || '_';
		ELIF cLetra BETWEEN '0' AND '9' THEN
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra = '<' THEN
			LET cLetra = ' &lt;';
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra = '>' THEN
			LET cLetra = ' &gt;'; 
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra = '&' THEN 
			LET cLetra = ' &amp;'; 
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra = "'" THEN 
			LET cLetra = ' &apos;'; 
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELIF cLetra = '"' THEN 
			LET cLetra = ' &quot;';
			LET cEscritura = TRIM(cEscritura) || cLetra;
		ELSE
			LET cEscritura = TRIM(cEscritura) || cLetra;
		END IF;
	END FOR;
	
	LET cEscritura = REPLACE (cEscritura, '_',' ');
	RETURN TRIM(cEscritura);
END;
END FUNCTION

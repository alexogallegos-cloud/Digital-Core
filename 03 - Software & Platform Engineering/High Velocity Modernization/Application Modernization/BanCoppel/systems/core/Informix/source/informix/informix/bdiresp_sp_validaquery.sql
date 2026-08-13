CREATE PROCEDURE "informix".sp_validaquery(pcBD CHAR(50), pcTabla CHAR(50), pcCondicion CHAR(100))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS Desc;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  valida que un query dinámico esté correctamente armado -----------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vdFecha			DATE;
	DEFINE viTotRegCons		INT;
	DEFINE vcDescRet		CHAR(100);
	DEFINE vcSql			CHAR(500);
	
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';	
	LET vdFecha			=	'01-01-1900';
	LET viTotRegCons	=	0;
	LET vcDescRet		=	'';
	LET vcSql			=	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF viCodigo = -217 THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, COLUMNA(S) INVALIDA(S) EN LA CONDICIÓN (PARÁMETRO 3)';
		ELSE
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, CONDICIÓN INVÁLIDA (PARÁMETRO 3)';
		END IF;
		RETURN NVL(vcCodRet,''), vcDescRet;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( TRIM(NVL(pcBD,'')) = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BD INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( NOT EXISTS( SELECT name FROM sysmaster:sysdatabases WHERE name = TRIM(NVL(pcBD,'')) ) ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA BD NO EXISTE (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF ( TRIM(NVL(pcTabla,'')) = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TABLA INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET vcSql = "SELECT COUNT(tabname) FROM " || TRIM(NVL(pcBD,'')) || ":systables WHERE tabname='" || TRIM(NVL(pcTabla,'')) || "'";
	PREPARE xsql FROM vcSql;
	DECLARE xcur CURSOR FOR xsql;
	OPEN xcur;		
	WHILE 1 = 1
		FETCH xcur INTO viTotRegCons;
		IF (SQLCODE = 100) THEN
			EXIT WHILE;
		END IF;
	END WHILE;
	CLOSE xcur;
	FREE xcur;
	FREE xsql;
	IF ( NVL(viTotRegCons,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA TABLA NO EXISTE (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;	
	END IF;

	LET vcSql = " SELECT COUNT(*) FROM " || TRIM(pcBD) || ":" || TRIM(pcTabla) || " WHERE " || TRIM(pcCondicion);
		
	PREPARE xsql FROM vcSql;
	DECLARE xcur CURSOR FOR xsql;
	OPEN xcur;
	WHILE 1 = 1
		FETCH xcur INTO viTotRegCons;
		IF (SQLCODE = 100) THEN
			EXIT WHILE;
		END IF;
	END WHILE;
	CLOSE xcur;
	FREE xcur;
	FREE xsql;
	
	RETURN vcCodRet, vcDescRet;
	END;
END PROCEDURE;
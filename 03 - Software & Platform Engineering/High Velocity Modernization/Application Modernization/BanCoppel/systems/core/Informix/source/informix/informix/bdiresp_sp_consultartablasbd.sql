CREATE PROCEDURE "informix".sp_consultartablasbd(pcBD VARCHAR(250), piDesde INT, piCuantos INT)
	RETURNING CHAR(5) AS Retorno, VARCHAR(250) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta las tablas de una base de datos en particular -----------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 23/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo		INT;
	DEFINE vcCodRet		CHAR(5);	
	DEFINE vcDescRet	VARCHAR(250);
	DEFINE vcSql        VARCHAR(250);
	DEFINE vcTabla		VARCHAR(250);
		
	LET viCodigo	= 	0;
	LET vcCodRet	= 	'00000';	
	LET vcDescRet	= 	'';
	LET vcSql 		= 	'';
	LET vcTabla 	= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		
		IF ( viCodigo = -329 OR viCodigo = -201 ) THEN
			LET vcDescRet = 'ERROR, LA BD NO EXISTE O NO TIENE PERMISOS PARA CONSULTARLA';
		END IF;
		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pcBD, '') = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, BD INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF (NVL(piDesde, -1) = -1) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DESDE INVÁLIDO (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF (NVL(piCuantos, 0) = 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, NUM REGISTROS INVÁLIDO (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	LET vcSql = "SELECT SKIP " || piDesde || " LIMIT " || piCuantos || " tabname FROM " || pcBD || ":systables WHERE tabid >= 100 ORDER BY tabname";

	PREPARE stmt_id FROM vcSql;
	DECLARE cust_cur cursor FOR stmt_id;
	OPEN cust_cur;
	   WHILE (1 = 1)
		FETCH cust_cur INTO vcTabla;
		IF (SQLCODE != 100) THEN
		   RETURN vcCodRet, vcTabla WITH RESUME;
		ELSE                   
		   EXIT;
		END IF
	   END WHILE
	CLOSE cust_cur;
    FREE cust_cur ;
    FREE stmt_id ;
	
	IF ( DBINFO('sqlca.sqlerrd2') <= 0 ) THEN
		LET vcCodRet = '00002';
		LET vcDescRet = 'ERROR, NO SE ENCONTRÓ INFORMACIÓN';
		RETURN vcCodRet, vcDescRet;
	END IF;	
	END;	
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultarbds(piDesde INT, piCuantos INT)
	RETURNING CHAR(5) AS Retorno, VARCHAR(250) as DescError;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta las bases de datos del servidor informix ----------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 23/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo		INT;
	DEFINE vcCodRet		CHAR(5);	
	DEFINE vcDescRet	VARCHAR(250);	
	DEFINE vcBD			VARCHAR(250);
		
	LET viCodigo	= 	0;
	LET vcCodRet	= 	'00000';	
	LET vcDescRet	= 	'';	
	LET vcBD 		= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		
		IF ( viCodigo = -329 ) THEN
			LET vcDescRet = 'ERROR, LA BD NO EXISTE O NO TIENE PERMISOS PARA CONSULTARLA';
		END IF;
		
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,'');
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(piDesde, -1) = -1) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DESDE INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	IF (NVL(piCuantos, -1) = -1) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, NUM REGISTROS INVÁLIDO (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet;
	END IF;
	
	FOREACH
		SELECT SKIP piDesde LIMIT piCuantos name INTO vcBD FROM sysmaster:sysdatabases WHERE name NOT LIKE 'sys%' ORDER BY name
		
		RETURN vcCodRet, vcBD WITH RESUME;
	END FOREACH;
	END;	
END PROCEDURE;
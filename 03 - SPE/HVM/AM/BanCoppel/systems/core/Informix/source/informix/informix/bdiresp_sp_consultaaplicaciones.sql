CREATE PROCEDURE "informix".sp_consultaaplicaciones(piDesde INT, piCuantos INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, INT AS Cve, CHAR(100) AS Nombre;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta las aplicaciones ----------------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);
	DEFINE viCveAplicacion		INT;	
	DEFINE vcNombreAplicacion	CHAR(100);
	DEFINE vcDescRet			CHAR(100);
		
	LET viCodigo			= 	0;
	LET vcCodRet			= 	'00000';
	LET viCveAplicacion		= 	0;	
	LET vcNombreAplicacion	= 	'';
	LET vcDescRet			= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, 0,'';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piDesde,-1) <= -1) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, DESDE INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, 0, '';
	END IF;
	
	IF ( NVL(piCuantos,-1) <= -1) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, NUM REGISTROS INVÁLIDO (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, 0, '';
	END IF;
	
	FOREACH
		SELECT SKIP piDesde LIMIT piCuantos cve_aplicacion, nombre_aplicacion
		INTO viCveAplicacion, vcNombreAplicacion
		FROM "informix".rp_aplicaciones
		ORDER BY cve_aplicacion
		
		RETURN NVL(vcCodRet,''), '', viCveAplicacion, vcNombreAplicacion WITH RESUME;	
	END FOREACH
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet= "00002";
		LET vcDescRet = "ERROR, NO SE ENCONTRÓ INFORMACIÓN";
		RETURN vcCodRet, vcDescRet, 0, '';
	END IF;
	END;
END PROCEDURE;
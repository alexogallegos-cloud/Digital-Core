CREATE PROCEDURE "informix".sp_consultaperiodicidad(piCveAplicacion INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(1) AS Periodicidad;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta la periodicidad de alguna aplicacion --------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);		
	DEFINE vcDescRet		CHAR(100);
	DEFINE vcPeriodicidad	CHAR(1);
		
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';
	LET vcDescRet		= 	'';
	LET vcPeriodicidad	= 	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, '';
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN NVL(vcCodRet,''), vcDescRet, '';
	END IF;
	
	SELECT periodicidad
	INTO vcPeriodicidad
	FROM "informix".rp_aplicaciones
	WHERE cve_aplicacion = piCveAplicacion;
	
	IF ( DBINFO('sqlca.sqlerrd2') <= 0 ) THEN
		LET vcCodRet = '00002';
		LET vcDescRet = 'ERROR, NO SE ENCONTRÓ INFORMACIÓN';
	END IF;
		
	RETURN NVL(vcCodRet,''), vcDescRet, vcPeriodicidad;
	END;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_consultaregistrosresp(piCveAplicacion INT, pdFechaIni DATE, pdFechaFin DATE)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, INT AS numregistros;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta el total de registros respaldados de una aplicación en particular ---------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vcDescRet		CHAR(100);
	DEFINE vlNumRegistros	INT;
	
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';
	LET vcDescRet		= 	'';
	LET vlNumRegistros 	= 	0;
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcDescRet, 0;
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 1)';
		RETURN vcCodRet, vcDescRet, 0;
	END IF;	
	
	IF ( NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE';
		RETURN vcCodRet, vcDescRet, 0;
	END IF;
	
	IF ( NVL(pdFechaIni,'01-01-1900') = '01-01-1900' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA INICIO INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, 0;
	END IF;
	
	IF ( NVL(pdFechaFin,'01-01-1900') = '01-01-1900' ) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, FECHA FIN INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet, 0;
	END IF;
	
	SELECT SUM(NVL(registros_respaldados,0)) 
	INTO vlNumRegistros
	FROM "informix".rp_respaldos
	WHERE cve_aplicacion = piCveAplicacion AND fecha_inicio >= pdFechaIni AND fecha_final <= pdFechaFin;
	
	RETURN vcCodRet, vcDescRet, NVL(vlNumRegistros,0);
	END;
END PROCEDURE;
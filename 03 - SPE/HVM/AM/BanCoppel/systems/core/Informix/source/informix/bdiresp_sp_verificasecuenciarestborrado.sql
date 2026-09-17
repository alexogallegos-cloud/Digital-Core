CREATE PROCEDURE "informix".sp_verificasecuenciarestborrado(piCveAplicacion INT, pcTabla CHAR(50), piSecRestauracion INT, piSecBorrado INT)
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, CHAR(1) AS ExisteSecuencia;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  verifica si existe alguna tabla de una aplicación determinada con las secuencias ---
	-- de restauracion y de borrado indicados -----------------------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresps  --------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo				INT;
	DEFINE vcCodRet				CHAR(5);		
	DEFINE vcDescRet			CHAR(100);
	DEFINE vcExisteSecuencia	CHAR(1);
		
	LET viCodigo			= 	0;
	LET vcCodRet			= 	'00000';
	LET vcDescRet			= 	'';
	LET vcExisteSecuencia	= 	'0';
	
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
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	IF ( TRIM(NVL(pcTabla,'')) = '') THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, TABLA INVÁLIDA (PARÁMETRO 2)';
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	IF ( NVL(piSecRestauracion,0) <= 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, SECUENCIA DE RESTAURACIÓN INVÁLIDA (PARÁMETRO 3)';
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	IF ( NVL(piSecBorrado,0) <= 0) THEN
		LET vcCodRet = '00001';
		LET vcDescRet = 'ERROR, SECUENCIA DE BORRADO INVÁLIDA (PARÁMETRO 4)';
		RETURN vcCodRet, vcDescRet, '';
	END IF;
	
	IF EXISTS(SELECT tabla FROM "informix".rp_tabla_aplicacion WHERE cve_aplicacion = piCveAplicacion AND TRIM(tabla) <> TRIM(pcTabla) AND sec_restauracion = piSecRestauracion ) THEN
		LET vcExisteSecuencia = '1';
	ELIF EXISTS(SELECT tabla FROM "informix".rp_tabla_aplicacion WHERE cve_aplicacion = piCveAplicacion AND TRIM(tabla) <> TRIM(pcTabla) AND sec_borrado = piSecBorrado) THEN
		LET vcExisteSecuencia = '2';
	END IF;		
		
	RETURN NVL(vcCodRet,''), '', vcExisteSecuencia;

	END;
END PROCEDURE;
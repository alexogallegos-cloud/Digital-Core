CREATE PROCEDURE "informix".sp_consultaparametro(pcID CHAR(3))
	RETURNING CHAR(5) AS Retorno, CHAR(50) AS valor;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Consulta el valor en la tabla de parametros usando el id ---------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 23/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo		INT;
	DEFINE vcCodRet		CHAR(5);		
	DEFINE vcValor		CHAR(50);
			
	LET viCodigo	= 	0;
	LET vcCodRet	= 	'00000';
	LET vcValor		= 	'';	
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;		
		RETURN NVL(vcCodRet,''), vcValor;
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF (NVL(pcID,'') = '') THEN
		LET vcCodRet = '00001';
		LET vcValor = 'ERROR, ID INVÁLIDO (PARÁMETRO 1)';
		RETURN vcCodRet, vcValor;
	END IF;
	
	SELECT valor INTO vcValor FROM "informix".rp_parametros WHERE id_param = pcID;
	
	IF ( DBINFO('sqlca.sqlerrd2') <= 0 ) THEN
		LET vcCodRet = '00002';
		LET vcValor = 'ERROR, NO SE ENCONTRÓ INFORMACIÓN';
	END IF;
	
	RETURN vcCodRet, vcValor;
	END;
END PROCEDURE;
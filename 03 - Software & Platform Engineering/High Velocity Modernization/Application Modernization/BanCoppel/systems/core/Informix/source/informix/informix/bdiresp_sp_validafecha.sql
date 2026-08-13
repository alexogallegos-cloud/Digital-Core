CREATE PROCEDURE "informix".sp_validafecha(pcFecha CHAR(10))
	RETURNING CHAR(5) AS Retorno;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  valida que una fecha en formato char sea valida ------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	*/
	
	DEFINE viCodigo			INT;
	DEFINE vcCodRet			CHAR(5);	
	DEFINE vdFecha			DATE;
	
	LET viCodigo		= 	0;
	LET vcCodRet		= 	'00000';	
	LET vdFecha			=	'01-01-1900';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		LET vcCodRet = '00001';
		RETURN NVL(vcCodRet,'');
	END EXCEPTION;

	LET vdFecha = TRIM(pcFecha)::DATE;
	
	RETURN vcCodRet;
	END;
END PROCEDURE;
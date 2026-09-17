CREATE PROCEDURE "informix".sp_validaruta(pcRuta VARCHAR(100)) 
returning INTEGER;

/*
*****************************************************************************************************
-- DESCRIPCION:  Valida que el parámetro ruta tenga formato correcto --------------------------------
-- AUTOR : Walber Castro ----------------------------------------------------------------------------
-- FECHA : 23/10/2012  ------------------------------------------------------------------------------
-- BD: bdiresp  -------------------------------------------------------------------------------------	
-----------------------------------------------------------------------------------------------------
*****************************************************************************************************
*/

DEFINE vcCadena 	VARCHAR(100);
DEFINE vcCaracter 	CHAR(1);
DEFINE viPosicion 	SMALLINT;
DEFINE i 			SMALLINT;

LET vcCadena 	= 	pcRuta;
LET vcCaracter 	= 	'';
LET viPosicion 	= 	0;
LET i			=	0;

IF (NVL(pcRuta,'') = '') THEN
	LET viPosicion = -1;
	RETURN viPosicion;
END IF;

FOR i = 1 TO LENGTH(vcCadena)
	IF ( vcCaracter = '/' ) THEN
		IF ( SUBSTR(vcCadena,i,1) = vcCaracter ) THEN
			LET viPosicion = i;
			EXIT FOR;
		END IF;
	END IF;
	LET vcCaracter = SUBSTR(vcCadena,i,1);	
END FOR;

RETURN viPosicion;
END PROCEDURE;
CREATE PROCEDURE "informix".sp_buscacaracter(pcCadena VARCHAR(255), pcCaracter CHAR(1)) returning INTEGER;

/*
*****************************************************************************************************
-- DESCRIPCION:  Busca un caracter dentro de una cadena ---------------------------------------------
-- AUTOR : Walber Castro ----------------------------------------------------------------------------
-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
-- BD: bdiresp  -------------------------------------------------------------------------------------	
-----------------------------------------------------------------------------------------------------
*****************************************************************************************************
*/

DEFINE vcCadena 	VARCHAR(255);
DEFINE vcCaracter 	CHAR(1);
DEFINE viPosicion 	SMALLINT;
DEFINE i 			SMALLINT;

LET vcCadena 	= 	pcCadena;
LET vcCaracter 	= 	pcCaracter;
LET viPosicion 	= 	0;

IF ((pcCadena IS NULL) OR (pcCaracter IS NULL)) THEN
	LET viPosicion = -1;
	RETURN viPosicion;
END IF;

FOR i = 1 TO LENGTH(vcCadena)
	IF ( SUBSTR(vcCadena,i,1) = vcCaracter ) THEN
		LET viPosicion = i;
		EXIT FOR;
	END IF;
END FOR;

RETURN viPosicion;
END PROCEDURE;
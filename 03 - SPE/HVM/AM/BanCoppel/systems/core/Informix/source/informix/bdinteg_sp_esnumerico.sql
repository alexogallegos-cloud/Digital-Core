CREATE PROCEDURE "informix".sp_esnumerico (psCadena CHAR (20))
	RETURNING CHAR (1) AS Munerico;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR :Martha Aguirre
-- FECHA : 19/08/2008
-- BD: bdinteg
--***************************************************************************************************

	/*  DEFINICION DE VARIABLES */
	DEFINE vsRespuesta CHAR (1);
	DEFINE visqlerr INTEGER;
	
	/* INICIALIZACION DE VARIABLES */
	LET vsRespuesta = 'F';
	LET visqlerr = 0;
	
	--SET LOCK MODE TO WAIT 10;
	
	BEGIN
		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
			IF visqlerr = -1213 THEN
				LET vsRespuesta = 'F'; 
			ELSE
				LET vsRespuesta = ' '; 
			END IF;
			RETURN vsRespuesta;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/sp_esnumerico.out";
		--TRACE ON;
		
        LET psCadena = replace(psCadena,'e','a');
        LET psCadena = replace(psCadena,'E','A');

		IF (psCadena >= 0) THEN 
			LET vsRespuesta = 'V';
		ELSE
			LET vsRespuesta = 'F';
		END IF  ;
		
		RETURN vsRespuesta ;
		
	END
END PROCEDURE;
CREATE PROCEDURE "informix".sp_rcda_esnumerico (pscadena CHAR(20))
RETURNING CHAR (01) as numerico;

	--variable de respuesta
	DEFINE vsRespuesta CHAR (1) ;

	--variable de control de errores
	DEFINE visqlerr INTEGER ;

	LET vsRespuesta = 'F' ;

	LET visqlerr = 0;

BEGIN
	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

		IF visqlerr = -1213 THEN
			LET vsRespuesta = 'F' ;
		ELSE
			LET vsRespuesta = ' ' ;
		END IF;

		RETURN vsRespuesta ;

	END EXCEPTION;

	IF (psCadena >= 0) THEN
		LET vsRespuesta = 'V';
	ELSE
		LET vsRespuesta = 'F';
	END IF  ;

	RETURN vsRespuesta ;


END
END PROCEDURE;
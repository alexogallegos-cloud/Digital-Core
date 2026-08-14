CREATE PROCEDURE "informix".sp_esnumerico ( psCadena CHAR (20))

RETURNING CHAR (1) AS Munerico ;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 19/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : Anselmo Verdugo
-- Fecha: Diciembre 2008
-- SE ADAPTA AL PROCESO DE PAGOS PROGRAMADOS
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRespuesta CHAR (1) ;

DEFINE visqlerr INTEGER ;
/* INICIALIZACION DE VARIABLES */

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

END PROCEDURE
;
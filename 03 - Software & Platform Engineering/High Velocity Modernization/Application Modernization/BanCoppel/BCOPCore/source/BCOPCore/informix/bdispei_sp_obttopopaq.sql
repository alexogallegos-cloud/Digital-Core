CREATE PROCEDURE "informix".sp_obttopopaq(pintFolioPaquete INTEGER, pdtFechaOp DATE)
RETURNING CHAR(5), CHAR(1), CHAR(1);

DEFINE codret 		CHAR(5);
DEFINE sql_err 		INTEGER;
DEFINE vchrTopologia	CHAR(1);
DEFINE vchrprioridad 	CHAR(1);

LET CODRET = '004'; --El folio de paquete no esta registrado.
LET vchrTopologia = 'V';
LET vchrprioridad = '0';

BEGIN
	ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
	     LET codret = sql_err;
	     RETURN codret, vchrTopologia,vchrprioridad;
	  END IF
	END EXCEPTION;
	
	FOREACH 
		SELECT chrTopologia, chrPrioridad INTO vchrTopologia, vchrPrioridad
		FROM tblPaqueteEnv
		WHERE intFolioPaquete = pintFolioPaquete
                AND chrSentidoPago = 'E'
		AND dtfechaOp = pdtFechaOp
                
                LET CODRET = '000';			
		RETURN codret, vchrTopologia,vchrPrioridad;
	
	END FOREACH;
	
	RETURN codret, vchrTopologia,vchrPrioridad;
	
END

END PROCEDURE;
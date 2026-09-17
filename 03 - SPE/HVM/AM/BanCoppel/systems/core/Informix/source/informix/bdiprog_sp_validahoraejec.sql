CREATE PROCEDURE "informix".sp_validahoraejec(cEmpresa CHAR(3))
RETURNING CHAR(5),-->Codigo de Retorno
	      CHAR(21);

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;
DEFINE iDigver          INTEGER;
DEFINE cHora		    CHAR(21);

LET vcodret = "000";
LET iDigver = 0;
LET cHora = '';

-- SET DEBUG FILE TO "/home/informix/sp_validahoraejec.out";
-- TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          iDigver;	--> Fecha de Ultimo Pago

	END EXCEPTION;


        SELECT substr(REPLACE(CURRENT::DATETIME HOUR TO FRACTION, ':', ':'),1,8) 
          INTO cHora 
          FROM bdicred:sd_fechas;	  
		
    RETURN vcodret, cHora;

END
END PROCEDURE;
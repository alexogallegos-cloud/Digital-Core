CREATE PROCEDURE "informix".sp_consulta_cat_estatus()
RETURNING 	CHAR(6)   AS CodRetorno,
			      CHAR(2)	  AS CveStatus,
			      CHAR(40)  AS DescStatus;

--Declaración de variables			
DEFINE isqlerr      INTEGER;
DEFINE cCodRet     	CHAR(6); 
DEFINE cStatus			CHAR(2);
DEFINE cDescripcion CHAR(40);
DEFINE iRegistro		INTEGER;  

--Asinación de valores   
LET isqlerr     		= 0;
LET cCodRet     		= '000000';
LET cStatus				  = '';
LET cDescripcion		= '';
LET iRegistro			  = 0;

--SET DEBUG FILE TO '/tmp/sp_consulta_cat_estatus.out';
--TRACE ON;

BEGIN
--Control de errores
	ON EXCEPTION SET iSqlErr
	      LET cCodRet= iSqlErr;
	      RETURN cCodRet, cStatus, cDescripcion;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;	
	
	Foreach
	
		SELECT status_solicitud, descripcion
		INTO cStatus, cDescripcion
		FROM bdisolic:"informix".ss_status_sol
		WHERE empresa= '001'
		ORDER BY status_solicitud
		
		RETURN cCodRet, cStatus, cDescripcion WITH RESUME;
		
	END FOREACH;
	
	LET iRegistro = dbinfo("sqlca.sqlerrd2");
	
	IF iRegistro = 0 THEN
		LET cCodRet = '000001'; --No hay información 
		RETURN cCodRet, cStatus, cDescripcion;
	END IF;		
	
END;

END PROCEDURE

CREATE PROCEDURE "informix".sp_consulta_variables()

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se consulta las variables de la tabla si_cat_variables
--Realizó: Nancy Sevilla Camacho
--Fecha: 08/03/2012                    
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5)  AS codigo_retorno,
INTEGER  AS id_variable,
CHAR(15) AS nomvar,
CHAR(10) AS valor;
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr     INTEGER;
DEFINE cCodRet     CHAR(5);	
DEFINE iVariableId INTEGER;
DEFINE cNomVar     CHAR(15);
DEFINE cValor      CHAR(10);

--INICIALIZACION DE VARIABLES--
LET iSqlErr     = 0;
LET cCodRet     = '00000';
LET iVariableId = 0;
LET cNomVar     = "";
LET cValor     = "";
	
	--SET DEBUG FILE TO "/home/informix/sp_consulta_variables.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,iVariableId,cNomVar,cValor;
			END IF;
		END EXCEPTION;	
		
		FOREACH
			
		-- Se obtienen los datos de las variables
			SELECT id_variable,
				   nomvar,
				   valor
			  INTO iVariableId,
				   cNomVar,
				   cValor
			  FROM bdinteg:"informix".si_cat_variables
			  where id_variable>0	  

			  RETURN cCodRet,
					 iVariableId,
					 cNomVar,
					 cValor
				WITH RESUME;	

		END FOREACH;	
		
	END
END PROCEDURE;
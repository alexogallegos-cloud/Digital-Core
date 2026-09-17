CREATE PROCEDURE "informix".sp_consultatransacciones(cEmpresa CHAR(3), cSistema CHAR(2))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se obtiene el catálogo de transacciones por sistema
--Realizó: Nancy Sevilla Camacho
--Fecha: 30/03/2012                    
--------------------------------------------------------------------												
		
    --DATOS A REGRESAR---		
	RETURNING CHAR(5),	-- Código de retorno
			  SMALLINT, -- Número de transacción
			  CHAR(50);	-- Nombre del producto

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet      CHAR(5);
	DEFINE iSqlErr      INTEGER;
    ---------------------------
	DEFINE sNumTransac  SMALLINT;
	DEFINE cDescTransac CHAR(50);	
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	LET sNumTransac = 0;
	LET cDescTransac = '';

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, 
			       sNumTransac, 
				   cDescTransac;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultatransacciones.out";
		--TRACE ON;
		
		--Valida parámetros de entrada
		IF cEmpresa <> '' OR cSistema <> '' THEN			

			FOREACH	 
				-- Se obtiene la descripción de la transacción
				SELECT numero,
					   descripcion
				  INTO sNumTransac,
					   cDescTransac
				  FROM bdinteg:"informix".itran
				 WHERE empresa = cEmpresa
				   AND sistema = cSistema	
				 ORDER BY descripcion		   

				RETURN cCodRet, 
					   sNumTransac, 
					   cDescTransac		   
				  WITH RESUME;
			END FOREACH;
			
		ELSE
		
			--Parámetro de entrada vacío
			LET cCodRet = '00001';
			
			RETURN cCodRet, 
				   sNumTransac, 
				   cDescTransac		   
			  WITH RESUME;			
			
		END IF;
	END;
END PROCEDURE;
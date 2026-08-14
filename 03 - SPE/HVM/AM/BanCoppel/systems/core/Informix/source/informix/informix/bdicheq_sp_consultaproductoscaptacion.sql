CREATE PROCEDURE "informix".sp_consultaproductoscaptacion(cEmpresa CHAR(3))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se obtiene el catálogo de productos de captación
--Realizó: Nancy Sevilla Camacho
--Fecha: 30/03/2012                    
--------------------------------------------------------------------												
		
    --DATOS A REGRESAR---		
	RETURNING CHAR(5),	-- Código de retorno
			  CHAR(4),	-- Número de producto
			  CHAR(40);	-- Nombre del producto

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet      CHAR(5);
	DEFINE iSqlErr      INTEGER;
    ---------------------------
	DEFINE cNumProducto CHAR(4);
	DEFINE cNomProducto CHAR(40);

	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	LET cNumProducto = '';
	LET cNomProducto = '';

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, 
			       cNumProducto, 
				   cNomProducto;
		END EXCEPTION;

		--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultaproductoscaptacion.out";
		--TRACE ON;
		
		--Valida parámetros de entrada
		IF cEmpresa <> '' THEN			

			FOREACH
				SELECT producto, 
					   nombre
				  INTO cNumProducto, 
					   cNomProducto
				  FROM bdicheq:"informix".sc_producto
				 WHERE empresa = cEmpresa
				 and producto>'0000'
				 ORDER BY nombre

				RETURN cCodRet, 
					   cNumProducto, 
					   cNomProducto 
				  WITH RESUME;
			END FOREACH;
			
		ELSE
		
			--Parámetro de entrada vacío
			LET cCodRet = '00001';
			
			RETURN cCodRet, 
				   cNumProducto, 
				   cNomProducto 
			  WITH RESUME;			
			
		END IF;
		
	END;
END PROCEDURE;
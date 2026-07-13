CREATE PROCEDURE "informix".sp_consultarproductoscredito(cEmpresa CHAR(3))
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Se obtiene el catálogo de productos de crédito
--Realizó: Nancy Sevilla Camacho
--Fecha: 24/05/2012                    
--------------------------------------------------------------------													
												
    --DATOS A REGRESAR---	
	RETURNING CHAR(6),	--codret
			  CHAR(4),	--numproducto
			  CHAR(40);	--nomproducto

	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
	DEFINE cNumProducto	CHAR(4);
	DEFINE cNomProducto	CHAR(40);

	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	LET cNumProducto = '';
	LET cNomProducto = '';
	
	--SET DEBUG FILE TO "/home/sysifx/Nancy/sp_consultarproductoscredito.out";
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumProducto, cNomProducto;
		END EXCEPTION;

		--Valida parámetros de entrada
		IF cEmpresa <> '' THEN			
		
			FOREACH
				SELECT num_producto, nombre_prod
				  INTO cNumProducto, cNomProducto
				  FROM bdicred:"informix".sd_definicion
				 WHERE empresa = cEmpresa and num_producto>'0'
				 ORDER BY nombre_prod

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
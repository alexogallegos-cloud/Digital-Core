CREATE PROCEDURE "informix".sp_consulta_combina_prod(pEmpresa CHAR(3))
	RETURNING CHAR(5), CHAR(1), CHAR(4), CHAR(4);
	
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE sValor  		CHAR(1);
	DEFINE sProducto1	CHAR(4);
	DEFINE sProducto2	CHAR(4);
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET sValor  = '0';
	LET sProducto1  = '';
	LET sProducto2  = '';
	
	--------------------------------------------------------------------------
	-- Creado por Rodolfo Tortolero Varela 
	--FECHA: 2011-06-10
	--Se consulta para obtener que productos se pueden combinar
	--------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consulta_combina_prod.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr !=0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sValor, sProducto1, sProducto2;
			END IF;
		END EXCEPTION;
		
		foreach
			select	Activa_producto, producto, producto_combinar into sValor, sProducto1, sProducto2 
			from	bdisolic:"informix".ss_combinacion_productos 
			where	empresa = pEmpresa
			
			RETURN cCodRet, sValor, sProducto1, sProducto2 WITH RESUME;
			
		END foreach;
	END
END PROCEDURE;
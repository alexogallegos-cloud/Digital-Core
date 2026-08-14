CREATE PROCEDURE "informix".sp_consultaproductoscliente(pNumCte CHAR(20), pTipoCuenta CHAR(1))	
--DATOS A REGRESAR---
RETURNING CHAR(5)   AS Retorno,
		  CHAR(4)	AS TipoProducto,
		  CHAR(40)  AS Producto;

DEFINE cCod_ret  CHAR(5);
DEFINE cTipoProducto  CHAR(4);		  
DEFINE cProducto CHAR(40);
DEFINE vRegistros INTEGER;

LET cCod_ret ='00000';
LET cTipoProducto = '';
LET cProducto  = '';
LET vRegistros = 0;
		
--SET DEBUG FILE TO '/informix/sp_consultaproductoscliente.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- INICIO DEL PROCEDIMIENTO
BEGIN

	SELECT DISTINCT COUNT(ps.nombre)
		INTO vRegistros
		FROM bdicheq:"informix".sc_maechq mc,
		 bdicheq:"informix".sc_producto pr,
		 bdinteg:"informix".si_productos_sistemas ps
		WHERE num_cte = pNumCte
		AND mc.empresa = "001"
		AND mc.producto = pr.producto 
		AND mc.producto = ps.producto
		AND ps.sistema = pTipoCuenta;
		
	IF (vRegistros > 0) THEN
		FOREACH
			SELECT DISTINCT ps.producto, ps.nombre
			INTO cTipoProducto, cProducto
			FROM bdicheq:"informix".sc_maechq mc,
			 bdicheq:"informix".sc_producto pr,
			 bdinteg:"informix".si_productos_sistemas ps
			WHERE num_cte = pNumCte
			AND mc.empresa = "001"
			AND mc.producto = pr.producto 
			AND mc.producto = ps.producto
			AND ps.sistema = pTipoCuenta
			ORDER BY ps.nombre

			RETURN cCod_ret, cTipoProducto, cProducto WITH RESUME;
		END FOREACH;
	ELSE 
		LET cCod_ret ='00001';
		RETURN cCod_ret, cTipoProducto, cProducto WITH RESUME;
	END IF;		
END;
END PROCEDURE;
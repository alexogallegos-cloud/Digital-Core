CREATE PROCEDURE "informix".sp_migrar_si_bpipprod(pPag INTEGER)
RETURNING CHAR (5), CHAR(12), CHAR(4);
	-- Creador: Javier Calderón
	-- Objetivo: Obtener registros a la tabla si_bpiprod, como proceso de la migrasion
	-- Solicitó: Diana Castellanos
	-- Fecha: 21/10/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR(5);
	DEFINE vProducto CHAR(4);
	DEFINE vId_oper CHAR(12);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vId_oper, vProducto;
		  END IF ;
		END EXCEPTION;
		
		LET vCod_ret = '00000';
		FOREACH
			SELECT SKIP pPag FIRST 10 id_oper, producto INTO vId_oper, vProducto FROM si_bpipprod ORDER BY id_oper
			
			RETURN vCod_ret, vId_oper, vProducto WITH RESUME;
		END FOREACH;
	END;

END PROCEDURE;
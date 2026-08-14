CREATE PROCEDURE "informix".sp_migrar_bpi_pprod(pIdOper CHAR(12), 
									 pProd CHAR(4))
RETURNING CHAR (5);
	-- Creador: Javier Calderón
	-- Objetivo: Insertar registros a la tabla bpi_pprod, como proceso de la migrasion de postgres a informix
	-- Solicitó: Diana Castellanos
	-- Fecha: 20/10/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vId_oper CHAR(12);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret;
		  END IF ;
		END EXCEPTION ;
		
		LET vCod_ret = '00000';
		
		SELECT id_oper INTO vId_oper FROM bpi_pprod WHERE id_oper = pIdOper AND producto = pProd;
		
		IF NVL(vId_oper, '') = '' THEN
			INSERT INTO bpi_pprod (id_oper, producto) VALUES (pIdOper, pProd);
		ELSE
			LET vCod_ret = '00001'; -- Ya existe el el registro
		END IF;
		RETURN vCod_ret;
	END;

END PROCEDURE;
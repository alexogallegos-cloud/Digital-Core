CREATE PROCEDURE "informix".sp_incrementafolio()
RETURNING CHAR (5), INT;
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el folio y incrementarlo una vez obtenido
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010
	DEFINE sql_err INT;
	DEFINE vCod_ret CHAR (5);
	DEFINE vFolio INT;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vFolio;
		  END IF ;
		END EXCEPTION ;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
		
		LET vCod_ret = '00000';
		---SELECT NVL(folio, 0) INTO vFolio FROM bpi_parametros_contenido;
		SELECT {+INDEX(bpi_parametros_contenido idx_parametros_contenido5)} NVL(folio,0) INTO vFolio FROM bpi_parametros_contenido;
		IF vFolio > 98 THEN
			UPDATE {+INDEX(bpi_parametros_contenido idx_parametros_contenido5)} bpi_parametros_contenido SET folio = 0;
		ELSE
			UPDATE {+INDEX(bpi_parametros_contenido idx_parametros_contenido5)} bpi_parametros_contenido SET folio = vFolio + 1;
		END IF;
		RETURN vCod_ret, vFolio;
	END;
END PROCEDURE;
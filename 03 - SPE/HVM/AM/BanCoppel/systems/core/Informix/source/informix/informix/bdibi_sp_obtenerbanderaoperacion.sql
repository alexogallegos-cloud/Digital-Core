CREATE PROCEDURE "informix".sp_obtenerbanderaoperacion(pTipoOper INT)
RETURNING CHAR (5), CHAR(1);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene el estado de la bandera de una operacion
	-- Solicitó: Diana Castellanos
	-- Fecha: 19/11/2010
	DEFINE sql_err int;
	DEFINE vCod_ret CHAR (5);
	DEFINE vBandera BOOLEAN;
	DEFINE vResBandera CHAR(1);
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let vCod_ret = sql_err;
				RETURN vCod_ret, vResBandera;
		  END IF ;
		END EXCEPTION ;

        SET ISOLATION TO DIRTY READ;
		
		LET vCod_ret = '00000';
		LET vBandera = 'f';
		LET vResBandera = 'f';
		IF (pTipoOper = 1) THEN
			SELECT flag_batch_cheques INTO vBandera FROM bpi_parametros_contenido;
		ELIF (pTipoOper = 2) THEN
			SELECT flag_batch_credito INTO vBandera FROM bpi_parametros_contenido;
		ELIF (pTipoOper = 3) THEN
			SELECT flag_batch_SPEI INTO vBandera FROM bpi_parametros_contenido;
		END IF;
		
		IF (vBandera = 'f') THEN
			LET vResBandera = 'f';
		ELIF (vBandera = 't') THEN
			LET vResBandera = 't';
		END IF;
		
		RETURN vCod_ret, vResBandera;
	END;
END PROCEDURE;
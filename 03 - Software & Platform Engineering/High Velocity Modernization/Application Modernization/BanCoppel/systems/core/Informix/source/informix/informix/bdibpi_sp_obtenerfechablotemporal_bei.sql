CREATE PROCEDURE "informix".sp_obtenerfechablotemporal_bei(pNumCliente VARCHAR(9),
											pTipoBloq VARCHAR(5))
RETURNING CHAR (5), DATETIME YEAR TO SECOND, INT;

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Obtiene bloqueo temporal del usuario
	-- Fecha: 04/08/2011
	
	DEFINE sql_err INT;
	DEFINE cCod_ret CHAR (5);
	DEFINE dFechaBloq DATETIME YEAR TO SECOND;
	DEFINE iTipoBloq INT;
	
	LET cCod_ret = '00000';
	LET dFechaBloq = '1900-01-01 00:00:00';
	LET iTipoBloq = 0;
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, dFechaBloq, iTipoBloq;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		IF (pTipoBloq = 'ATOK') THEN --Activacion de Token
			SELECT fecha_bloqueo INTO dFechaBloq FROM bdibpi:"informix".bpi_usuariopm WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CPASS') THEN --Cambio de Password
			SELECT fecha_bloqueo_camb_pass, tipo_bloqueo_temp_pass INTO dFechaBloq, iTipoBloq FROM bdibpi:"informix".bpi_usuariopm  WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CRESP') THEN --Cambio de Respuestas
			SELECT fecha_bloqueo_camb_pregs, tipo_bloqueo_temp_resp INTO dFechaBloq, iTipoBloq FROM bdibpi:"informix".bpi_usuariopm  WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET cCod_ret = '00001';
		END IF;
		
		RETURN cCod_ret, NVL(dFechaBloq, '1900-01-01 00:00:00'), NVL(iTipoBloq, 0);
		
	END;

END PROCEDURE;
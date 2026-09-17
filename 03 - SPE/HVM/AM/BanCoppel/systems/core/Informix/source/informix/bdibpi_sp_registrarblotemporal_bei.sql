CREATE PROCEDURE "informix".sp_registrarblotemporal_bei(pFechaBloq DATETIME YEAR TO SECOND,
										 pNumCliente VARCHAR(9),
										 pTipoBloq VARCHAR(5),
										 pTipoBloqTemp  INT)
RETURNING CHAR (5);

	-- Creador: Manuel Ramos Figueroa
	-- Objetivo: Registra bloqueo temporal del usuario
	-- Fecha: 05/08/2011
	
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	
	LET cCod_ret = '00000';
	
	BEGIN
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;
		
		IF (pTipoBloq = 'ATOK') THEN --Activacion de Token
			UPDATE bdibpi:"informix".bpi_usuariopm SET fecha_bloqueo = pFechaBloq WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CPASS') THEN --Cambio de Password
			UPDATE bdibpi:"informix".bpi_usuariopm SET fecha_bloqueo_camb_pass = pFechaBloq, tipo_bloqueo_temp_pass = pTipoBloqTemp WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELIF (pTipoBloq = 'CRESP') THEN --Cambio de Respuestas
			UPDATE bdibpi:"informix".bpi_usuariopm SET fecha_bloqueo_camb_pregs = pFechaBloq, tipo_bloqueo_temp_resp = pTipoBloqTemp WHERE numcliente = pNumCliente AND st_portal = 'activo';
		ELSE
			LET cCod_ret = '00001';
		END IF;
		
		RETURN cCod_ret;
		
	END;

END PROCEDURE;
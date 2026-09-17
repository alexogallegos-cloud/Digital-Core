CREATE PROCEDURE "informix".sp_actualiza_status_manco_bei(pNumCliente CHAR(9),pIdentAdmin CHAR(30))
RETURNING CHAR (5);

--****************************************************************************************************
-- DESCRIPCION: Actualiza Status Mancomunidad
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
	DEFINE sql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE sStatusManco    			SMALLINT;
	LET cCod_ret = '00000';
	LET sStatusManco = 0;
	BEGIN
--****************************************************************************************************
-- Excepciones:
--***************************************************************************************************
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret;
		  END IF ;
		END EXCEPTION ;
--****************************************************************************************************
-- Valida Si Los datos fueron proporcionados
--***************************************************************************************************

		SET LOCK MODE TO WAIT ;
		SET ISOLATION DIRTY READ ;


		IF NVL(pNumCliente, '') == '' THEN
			LET cCod_ret = '00001'; -- Sin Numero de Cliente
				RETURN cCod_ret;
		END IF;

		IF NVL(pIdentAdmin, '') == '' THEN
			LET cCod_ret = '00002'; -- Sin Id de Admin
				RETURN cCod_ret;
		END IF;

--****************************************************************************************************
-- Proceso de Actualizacion :
--***************************************************************************************************

	SELECT status_manco
	INTO sStatusManco
	FROM bdibei:"informix".bei_servicio
	WHERE num_cliente=pNumCliente
	AND identificacion_admin=pIdentAdmin;


	IF NVL(sStatusManco,-1)==-1 THEN
		LET cCod_ret = '00003'; --Sin Status de Mancomunidad

		UPDATE  bdibei:"informix".bei_servicio SET status_manco=0
		WHERE num_cliente=pNumCliente;
	ELIF (sStatusManco==2) THEN
		UPDATE  bdibei:"informix".bei_servicio SET status_manco=1
		WHERE num_cliente=pNumCliente;
	END IF;




		RETURN cCod_ret;

	END;

END PROCEDURE;
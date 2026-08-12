CREATE PROCEDURE "informix".sp_obtenerfechablotemporal_bei(pIdUsuario INTEGER,pTipoBloq VARCHAR(5))
RETURNING CHAR (5), DATETIME YEAR TO SECOND, INT;


	DEFINE sql_err INT;
	DEFINE cCod_ret CHAR (5);
	DEFINE dFechaBloq DATETIME YEAR TO SECOND;
	DEFINE iTipoBloq INT;

	LET cCod_ret = '00000';
	LET dFechaBloq = '1900-01-01 00:00:00';
	LET iTipoBloq = 0;
	
	--****************************************************************************************************
-- DESCRIPCION:  Obtiene bloqueo temporal del usuario
-- AUTOR : Manuel Ramos Figueroa / Solser
-- FECHA : 04/08/2011 
-- BD: bdibei
-- SOLICITO : BanCoppel.
-- LIBERADO A PRODUCCION: Mayo 2014
--***************************************************************************************************

		

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
			SELECT fecha_bloqueo INTO dFechaBloq FROM bdibei:"informix".bei_datos_usuario WHERE id_usuario = pIdUsuario AND activo = 't';
		ELIF (pTipoBloq = 'CPASS') THEN --Cambio de Password
			SELECT fecha_bloqueo_camb_pass, tipo_bloqueo_temp_pass INTO dFechaBloq, iTipoBloq FROM bdibei:"informix".bei_datos_usuario  WHERE id_usuario = pIdUsuario AND activo = 't';
		ELIF (pTipoBloq = 'CRESP') THEN --Cambio de Respuestas
			SELECT fecha_bloqueo_camb_pregs, tipo_bloqueo_temp_resp INTO dFechaBloq, iTipoBloq FROM bdibei:"informix".bei_datos_usuario  WHERE id_usuario = pIdUsuario AND activo = 't';
        ELSE
            LET cCod_ret = '00001';
		END IF;

		RETURN cCod_ret, NVL(dFechaBloq, '1900-01-01 00:00:00'), NVL(iTipoBloq, 0);

	END;

END PROCEDURE;
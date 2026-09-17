CREATE PROCEDURE "informix".sp_registra_bitacora_amov(pEjecutivo CHAR(8), pIP CHAR(15), pAccion CHAR(50))

	RETURNING CHAR(5) AS CodRet;

	DEFINE iSqlErr 	    INTEGER;
	DEFINE cCodRet      CHAR(5);
	DEFINE cNombre      CHAR(60);

	LET cCodRet 	= '00000';

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/emm/sp_registra_bitacora_amov.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF (pEjecutivo IS NULL OR pEjecutivo  = '') OR (pIP IS NULL OR pIP  = '') OR (pAccion IS NULL OR pAccion  = '')  THEN
			LET cCodRet='00001';
			RETURN cCodRet;
		END IF;

		IF (LENGTH(TRIM(pEjecutivo)) < 8) OR (LENGTH(TRIM(pAccion)) < 5) THEN
			LET cCodRet='00003';
			RETURN cCodRet;
		END IF;

		IF TRIM(pEjecutivo)<>'' AND TRIM(pIP)<>'' AND TRIM(pAccion)<>'' THEN
		
			SELECT LIMIT 1 nombre INTO cNombre FROM si_usuario_movil WHERE ejecutivo = pEjecutivo AND activo = 1;
			
			LET cNombre = TRIM(cNombre);
				
			INSERT INTO "informix".si_bitacora_acceso_amov(id, ejecutivo, nombre, fecha, hora, ip, accion) 
			VALUES(0, pEjecutivo, cNombre, CURRENT, CURRENT, pIP, pAccion);
				
		ELSE
			LET cCodret = "00002";
		END IF;	

		RETURN cCodRet;

	END
	
END PROCEDURE;
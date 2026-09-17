CREATE PROCEDURE "informix".sp_reporte_accesos_amov(pEjecutivo CHAR(8),pDesde DATE, pHasta DATE)

	RETURNING CHAR(5) AS CodRet, CHAR(8) AS sEjecutivo, CHAR(60) AS sNombre, CHAR(10) AS sFecha, CHAR (8) AS sHora, CHAR(15) AS sIP, CHAR(50) AS sAccion;

	DEFINE iSqlErr 	  INTEGER;
	DEFINE cCodRet 	  CHAR(5);
	DEFINE sEjecutivo CHAR(8);
	DEFINE sNombre    CHAR(60);
	DEFINE sFecha     CHAR(10);
	DEFINE sHora      CHAR(8);
	DEFINE sIP        CHAR(15);
	DEFINE sAccion    CHAR(50);
	DEFINE sConEjecutivo CHAR(50);
	DEFINE iExiste    INTEGER;
	DEFINE iExisteEjecutivo INTEGER;

	LET cCodRet       = '00000';
	LET sEjecutivo    = '';
	LET sNombre       = '';
	LET sFecha        = '';
	LET sHora         = '';
	LET sIP	          = '';
	LET sAccion       = '';
	LET sConEjecutivo = '';
	LET iExiste       = '';
	LET iExisteEjecutivo = '';

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sEjecutivo, sNombre, sFecha, sHora, sIP, sAccion;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/emm/sp_reporte_accesos_amov.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- BUSCA SI EXISTEN REGISTROS EN LA BITACORA CON EL RANGO DE FECHAS
		SELECT 
			COUNT(*) 
		INTO 
			iExiste
		FROM 
			si_bitacora_acceso_amov
		WHERE
			fecha BETWEEN pDesde AND pHasta;
	

		-- REGISTROS PARA REPORTE
		IF iExiste > 0 THEN
			IF pEjecutivo <> '' THEN
			
				-- BUSCA SI EXISTEN REGISTROS EN LA BITACORA
				SELECT 
					COUNT(*) 
				INTO 
					iExisteEjecutivo
				FROM 
					si_bitacora_acceso_amov
				WHERE
					fecha BETWEEN pDesde AND pHasta
					AND ejecutivo = pEjecutivo;
				
				IF iExisteEjecutivo > 0 THEN
					FOREACH
						SELECT
							ejecutivo,nombre,fecha,hora,ip,accion
						INTO
							sEjecutivo,sNombre,sFecha,sHora,sIP,sAccion
						FROM
							si_bitacora_acceso_amov
						WHERE
							fecha BETWEEN pDesde AND pHasta
							AND ejecutivo = pEjecutivo
							
						LET sNombre = TRIM(sNombre);
						
						RETURN cCodRet, sEjecutivo, sNombre, sFecha, sHora, sIP, sAccion WITH RESUME;
					 END FOREACH;
				ELSE
					LET cCodRet	= '00001';

					RETURN cCodRet, sEjecutivo, sNombre, sFecha, sHora, sIP, sAccion;
				END IF;

			ELSE
				FOREACH			
					SELECT
						ejecutivo,nombre,fecha,hora,ip,accion
					INTO
						sEjecutivo,sNombre,sFecha,sHora,sIP,sAccion
					FROM
						si_bitacora_acceso_amov
					WHERE
						fecha BETWEEN pDesde AND pHasta
						
					LET sNombre = TRIM(sNombre);
					
					RETURN cCodRet, sEjecutivo, sNombre, sFecha, sHora, sIP, sAccion WITH RESUME;
				 END FOREACH;
			END IF;

			
		ELSE
			LET cCodRet	= '00001';

			RETURN cCodRet, sEjecutivo, sNombre, sFecha, sHora, sIP, sAccion;

		END IF;
	END 
END PROCEDURE;
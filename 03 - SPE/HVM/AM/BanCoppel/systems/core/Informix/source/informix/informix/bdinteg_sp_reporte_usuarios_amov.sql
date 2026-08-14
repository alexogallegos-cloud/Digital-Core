CREATE PROCEDURE "informix".sp_reporte_usuarios_amov(pEjecutivo CHAR(8))

	RETURNING CHAR(5) AS CodRet, CHAR(8) AS sEjecutivo, CHAR(60) AS sNombre, CHAR(20) AS sPerfil, CHAR(15) AS sIP, CHAR(10) AS sFechaAlta, CHAR(10) AS sUltimoAcceso;

	DEFINE iSqlErr 	  		INTEGER;
	DEFINE cCodRet 	  		CHAR(5);
	DEFINE sEjecutivo 		CHAR(8);
	DEFINE sNombre    		CHAR(60);
	DEFINE iPerfil			INTEGER;
	DEFINE sPerfil     		CHAR(20);
	DEFINE sIP     			CHAR(15);
	DEFINE sFechaAlta     	CHAR(10);
	DEFINE sUltimoAcceso	CHAR(10);
	DEFINE iExiste    		INTEGER;
	DEFINE iExisteEjecutivo INTEGER;

	LET cCodRet       	= '00000';
	LET sEjecutivo    	= '';
	LET sNombre       	= '';
	LET iPerfil			= '';
	LET sPerfil        	= '';
	LET sIP        		= '';
	LET sFechaAlta      = '';
	LET sUltimoAcceso	= '';
	LET iExiste       	= '';
	LET iExisteEjecutivo = '';

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sEjecutivo, sNombre, sPerfil, sIP, sFechaAlta, sUltimoAcceso;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/emm/sp_reporte_usuarios_amov.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- BUSCA SI EXISTEN REGISTROS EN LA BITACORA
		SELECT 
			COUNT(*) 
		INTO 
			iExiste
		FROM 
			si_bitacora_acceso_amov;

		-- REGISTROS PARA REPORTE
		IF iExiste > 0 THEN
		
			IF pEjecutivo <> '' THEN
			
				-- BUSCA SI EXISTEN REGISTROS EN LA BITACORA CON EJECUTIVO
				SELECT 
					COUNT(*) 
				INTO 
					iExisteEjecutivo
				FROM 
					si_bitacora_acceso_amov
				WHERE 
					ejecutivo = pEjecutivo;
					
				-- REGISTROS PARA REPORTE
				IF iExisteEjecutivo > 0 THEN
					FOREACH
						SELECT DISTINCT ejecutivo INTO sEjecutivo FROM si_bitacora_acceso_amov WHERE ejecutivo = pEjecutivo
						
							SELECT LIMIT 1 MAX(nombre) INTO sNombre FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND nombre IS NOT NULL;
							SELECT limit 1 MAX(ip) INTO sIP FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND ip IS NOT NULL;
							SELECT LIMIT 1 TO_CHAR(fecha_insert, '%d/%m/%Y') INTO sFechaAlta FROM si_usuario_movil WHERE ejecutivo = sEjecutivo AND fecha_insert IS NOT NULL;
							SELECT limit 1 perfil INTO iPerfil FROM si_usuario_movil WHERE ejecutivo = sEjecutivo AND perfil IS NOT NULL;
							SELECT LIMIT 1 descripcion INTO sPerfil FROM si_param_movil WHERE cod_param = iPerfil AND descripcion IS NOT NULL;
							SELECT MAX(fecha) INTO sUltimoAcceso FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND fecha IS NOT NULL;
							
							LET sNombre = TRIM(sNombre);
						
						RETURN cCodRet, sEjecutivo, sNombre, sPerfil, sIP, sFechaAlta, sUltimoAcceso WITH RESUME;
					END FOREACH;
				ELSE
					LET cCodRet	= '00001';

					RETURN cCodRet, sEjecutivo, sNombre, sPerfil, sIP, sFechaAlta, sUltimoAcceso;
				END IF;
			
				
			ELSE
				FOREACH
					SELECT DISTINCT ejecutivo INTO sEjecutivo FROM si_bitacora_acceso_amov
					
						SELECT LIMIT 1 MAX(nombre) INTO sNombre FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND nombre IS NOT NULL;
						SELECT limit 1 MAX(ip) INTO sIP FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND ip IS NOT NULL;
						SELECT LIMIT 1 TO_CHAR(fecha_insert, '%d/%m/%Y') INTO sFechaAlta FROM si_usuario_movil WHERE ejecutivo = sEjecutivo AND fecha_insert IS NOT NULL;
						SELECT limit 1 perfil INTO iPerfil FROM si_usuario_movil WHERE ejecutivo = sEjecutivo AND perfil IS NOT NULL;
						SELECT LIMIT 1 descripcion INTO sPerfil FROM si_param_movil WHERE cod_param = iPerfil AND descripcion IS NOT NULL;
						SELECT MAX(fecha) INTO sUltimoAcceso FROM si_bitacora_acceso_amov WHERE ejecutivo = sEjecutivo AND fecha IS NOT NULL;
						
						LET sNombre = TRIM(sNombre);
					
					RETURN cCodRet, sEjecutivo, sNombre, sPerfil, sIP, sFechaAlta, sUltimoAcceso WITH RESUME;
				END FOREACH;
			END IF;
			
		ELSE
			LET cCodRet	= '00001';

			RETURN cCodRet, sEjecutivo, sNombre, sPerfil, sIP, sFechaAlta, sUltimoAcceso;

		END IF;
	END 
END PROCEDURE;
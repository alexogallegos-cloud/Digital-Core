CREATE PROCEDURE "informix".sp_perfiles_amov()

	RETURNING CHAR(5) AS CodRet, CHAR(60) AS sPerfil, CHAR(50) AS sDescripcion, CHAR(10) AS sFechaAlta;

	DEFINE iSqlErr 	  	INTEGER;
	DEFINE cCodRet 	  	CHAR(5);
	DEFINE sPerfil     	CHAR(60);
	DEFINE sDescripcion	CHAR(50);
	DEFINE sFechaAlta   CHAR(10);
	DEFINE iExiste    	INTEGER;

	LET cCodRet       = '00000';
	LET sPerfil       = '';
	LET sDescripcion  = '';
	LET sFechaAlta    = '';
	LET iExiste       = '';

	BEGIN
		-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, sPerfil, sDescripcion, sFechaAlta;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/emm/sp_perfiles_amov.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- BUSCA SI EXISTEN REGISTROS EN LA BITACORA
		SELECT 
			COUNT(*) 
		INTO 
			iExiste
		FROM  
			si_param_movil
		WHERE
			valor = 'amov';

		-- REGISTROS PARA REPORTE
		IF iExiste > 0 THEN

			FOREACH
				SELECT
					descripcion,fecha_insert
				INTO
					sPerfil,sFechaAlta
				FROM  
					si_param_movil
				WHERE
					valor = 'amov'
					
				LET sDescripcion = TRIM(sPerfil);
				
				RETURN cCodRet, sPerfil, sDescripcion, sFechaAlta WITH RESUME;
			 END FOREACH;
		ELSE
			LET cCodRet       = '00001';
			
			RETURN cCodRet, sPerfil, sDescripcion, sFechaAlta;

		END IF;
	END 
END PROCEDURE;
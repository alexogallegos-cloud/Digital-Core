CREATE PROCEDURE "informix".sp_concurrencia(pUsuario CHAR(8), pIdFuncion CHAR(10), pBloqueo CHAR(1), pIdSession char(40))
	returning CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cStatusFuncionalidad CHAR(1);
	DEFINE cSesionActiva CHAR(40);
	DEFINE iSqlErr INT;
	
	LET cCodRet = '00000';
	LET cStatusFuncionalidad = '';
	LET iSqlErr = 0;
	LET cSesionActiva = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		IF pBloqueo = '' THEN -- La aplicaciÃÂ³n esta iniciando y se desbloquean las funcionalidades
			LET cCodRet = '00003';
			RETURN cCodRet;
		ELIF pBloqueo = '3' THEN
			UPDATE sw_tr_concurrencia
			SET status_acceso = '0',
				usuario = '',
				id_session = '';
			RETURN cCodRet;
		END IF;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pIdSession = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF LENGTH(pIdSession) < 30 THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
			RETURN cCodRet;
        END IF;
		
		IF pBloqueo NOT IN ('0', '1', '3') THEN
			LET cCodRet = '00148'; -- La operaciÃÂ³n que se quiere realizar es incorrecta
			RETURN cCodRet;
		END IF;
		
		SET LOCK MODE TO WAIT;
		IF pBloqueo = '1' THEN
			SELECT status_acceso, id_session
			INTO cStatusFuncionalidad, cSesionActiva
			FROM bdicnweb:sw_tr_concurrencia
			WHERE id_funcion = pIdFuncion;
			
			IF cStatusFuncionalidad IS NULL THEN
				LET cCodRet = '00149'; -- La funcionalidad no esta en la tabla de validaciÃÂ³n de concurrencia
				RETURN cCodRet;
			ELSE
				IF cStatusFuncionalidad = '1' AND TRIM(cSesionActiva) <> TRIM(pIdSession) THEN
					LET cCodRet = '00150';
					RETURN cCodRet;
				ELSE
					UPDATE bdicnweb:sw_tr_concurrencia
					SET status_acceso = '1',
						usuario = pUsuario,
						id_session = pIdSession
					WHERE id_funcion = pIdFuncion;
					
					RETURN cCodRet;
				END IF;
			END IF;
		ELIF pBloqueo = '0' THEN
			UPDATE bdicnweb:sw_tr_concurrencia
			SET status_acceso = '0',
				usuario = '',
				id_session = ''
			WHERE id_funcion = pIdFuncion;
			
			RETURN cCodRet;
		END IF;
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 28/06/2013",
"DESCRIPCION: Procedimiento que bloquea una funcionalidad para ser utilizada por un solo usuario.",
"0 - Desbloquea funciÃÂ³n por usuario",
"1 - Bloque la funcionalidad por usuario",
"3 - Desbloquea todas las funcionalidades, se manda a llamar con este parametro cuando se arranca la plataforma";

CREATE PROCEDURE "informix".sp_liberausuarioconcurrencia(pIdSession char(40))
	returning CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cStatusFuncionalidad CHAR(1);
	DEFINE iSqlErr INT;
	
	LET cCodRet = '00000';
	LET cStatusFuncionalidad = '';
	LET iSqlErr = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		IF pIdSession = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF LENGTH(pIdSession) < 30 THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		SET LOCK MODE TO WAIT;		
		UPDATE sw_tr_concurrencia
		SET status_acceso = '0',
			usuario = '',
			id_session = ''
		WHERE id_session = pIdSession;
			
		RETURN cCodRet;
			
	END;
END PROCEDURE;
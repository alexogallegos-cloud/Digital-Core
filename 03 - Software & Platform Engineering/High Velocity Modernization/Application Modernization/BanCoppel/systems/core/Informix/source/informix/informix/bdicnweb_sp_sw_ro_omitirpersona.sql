CREATE PROCEDURE "informix".sp_sw_ro_omitirpersona(pUsuarioC CHAR(8), pFuncionC CHAR(10), pIdResultPer INT, pOmitir CHAR(1), pOperacion INT)
	RETURNING CHAR(5) AS codret
	DEFINE iSqlErr INT;
	DEFINE cCodRet CHAR(5);
	DEFINE cOmitir CHAR(1);
	DEFINE iExiste INT;
	LET iSqlErr = 0;
	LET cCodRet = '00000';
	LET iExiste = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuarioC, pFuncionC) 
		INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF pOperacion = '' THEN
			let cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		IF pOperacion NOT IN ('0', '1', '2', '3') THEN
			let cCodRet = '00044';
			RETURN cCodRet;
		END IF;
		
		IF pOperacion = '0' THEN -- Cambia el estatus de un cliente a NO LOCALIZADO
			UPDATE sw_ro_resulper
			SET status_busqueda = '0'
			WHERE id_busqueda = pIdResultPer;
			
			UPDATE sw_ro_resulcte
			SET status = '0'
			WHERE id_busqueda = pIdResultPer;
			
			RETURN cCodRet;			
		ELIF pOperacion = '1' THEN -- Omisión del registro
			IF pOmitir NOT IN ('0', '1') THEN
				RETURN '00005';
			END IF;		
			
			UPDATE sw_ro_resulper 
			SET ind_omitir = pOmitir
			WHERE id_busqueda = pIdResultPer;
			
			RETURN cCodRet;
		ELIF pOperacion = '2' THEN -- Cambia el estatus de un cliente a HOMONIMO			
			UPDATE sw_ro_resulper
			SET status_busqueda = '2'
			WHERE id_busqueda = pIdResultPer;
			
			UPDATE sw_ro_resulcte
			SET status = '0'
			WHERE id_busqueda = pIdResultPer;
			
			RETURN cCodRet;			
		ELIF pOperacion = '3' THEN -- Cambia el estatus de un cliente a LOCALIZADO			
			SET ISOLATION TO DIRTY READ;
			
			SELECT COUNT(*)
			INTO iExiste
			FROM sw_ro_resulcte
			WHERE id_busqueda = pIdResultPer;
			
			IF iExiste = 1 THEN			
				UPDATE sw_ro_resulper
				SET status_busqueda = '1'
				WHERE id_busqueda = pIdResultPer;
				
				UPDATE sw_ro_resulcte
				SET status = '1'
				WHERE id_busqueda = pIdResultPer;
				
				RETURN cCodRet;			
			END IF;
		END IF;				
	END
END PROCEDURE;
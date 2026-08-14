CREATE PROCEDURE  "informix".spgrabarfecharetroactiva(p_sempresa CHAR(3), p_dFechaCaptura DATE, p_dFechaInicial DATE, p_dFechaFinal DATE, 
				 p_sUsuarioAutoriza CHAR(8), p_sUsuarioSolicita CHAR(8), p_sClaveAutorizacion CHAR(6), p_sEstatusUso CHAR(1), p_mImporte MONEY(18,2))
				
    RETURNING CHAR(5) AS retorno;	
	
	DEFINE iSqlErr	   INTEGER;
	DEFINE v_sconfirma CHAR(5);
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
	
		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sempresa, '') = ''  OR NVL(p_dFechaCaptura, '') = '' OR NVL(p_dFechaInicial, '') = '' 
			OR NVL(p_dFechaFinal,'') = '' OR NVL(p_sUsuarioAutoriza,'') = '' OR NVL(p_sUsuarioSolicita,'') = ''
			OR NVL(p_sClaveAutorizacion,'') = '' OR NVL(p_sEstatusUso,'') = '' OR NVL(p_mImporte,'') = '' THEN
			
			LET v_sconfirma = '00001';
			RETURN v_sconfirma;
		END IF;

		--SI NO EXISTE GUARDA, SI EXISTE MANDA UN ERROR
		IF NOT EXISTS (SELECT  usuario_solicita FROM bdicont:co_clv_retroact WHERE fecha_captura = p_dFechaCaptura
																		       AND fecha_final = p_dFechaFinal
																			   AND fecha_inicial = p_dFechaInicial
																			   AND usuario_autoriza = p_sUsuarioAutoriza
																	           AND usuario_solicita = p_sUsuarioSolicita
																			   AND clave_autorizacion = p_sClaveAutorizacion ) THEN

			INSERT INTO bdicont:co_clv_retroact(empresa, fecha_captura, fecha_inicial, fecha_final, usuario_autoriza, usuario_solicita, 
			clave_autorizacion, estatus_uso, importe)
			
			VALUES (p_sempresa, p_dFechaCaptura, p_dFechaInicial, p_dFechaFinal, p_sUsuarioAutoriza, p_sUsuarioSolicita, 
			p_sClaveAutorizacion, p_sEstatusUso, p_mImporte);
			
			LET v_sconfirma = '00000';			
		ELSE
			LET v_sconfirma = '00002';
		END IF;	
		
		RETURN v_sconfirma;
	END
END PROCEDURE;
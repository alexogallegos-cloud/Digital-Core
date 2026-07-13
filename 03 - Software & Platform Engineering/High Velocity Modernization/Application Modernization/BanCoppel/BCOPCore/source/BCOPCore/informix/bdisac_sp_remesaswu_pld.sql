CREATE PROCEDURE "informix".sp_remesaswu_pld(NombreProceso CHAR(3),FechaIni DATE, FechaFin DATE)
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE cMensaje				CHAR(80);
	DEFINE cStatus				CHAR(1);	
	DEFINE cDescripcionSPJWU	 CHAR(100);	
	DEFINE cDescripcionSPJOV	 CHAR(100);	
	DEFINE cDescripcionSPJVG	 CHAR(100);	
	DEFINE cCodRetSP			 CHAR(5);
			
	LET cCodRet  =   "00000";
	LET cMensaje = 'PROCESO EXITOSO';	
	LET cStatus						= '0';	
	LET cDescripcionSPJWU	  = 'Inserta datos de Remesas Western Union para sistema de PLD';
	LET cDescripcionSPJOV = 'Inserta datos de Remesas Orlandi Valuta para sistema de PLD';
	LET cDescripcionSPJVG = 'Inserta datos de Remesas Vigo para sistema de PLD';
	LET cCodRetSP = "00000";
	
	--SET DEBUG FILE TO  '/informix/adrian/sp_remesaswu_pld.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_remesaswu_pld");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		IF NombreProceso = "" OR FechaIni = "" OR FechaFin = "" THEN
			LET cCodRet = '00001';
			LET cMensaje = "FALTAN PARAMETROS DE ENTRADA";
            RETURN cCodRet, cMensaje;
		ELSE
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;				
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_WU' and fecha_proceso = FechaFin) THEN									
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_WU', FechaFin, '0', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_WU' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='WUN' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','WUN',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE WU EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN
				--WU
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_wu('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;				
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_WU', FechaFin, '1', 'informix', 'sp_remesaswu_pld_wu', cDescripcionSPJWU);
			END IF;	
			LET cStatus = '0';
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE OVA";
				RETURN cCodRet, cMensaje;			
			END IF;	
			
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_OV' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_OV', FechaFin, '0', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_OV' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN						
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='OVA' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','OVA',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE OVA EN TABLA DE PLD";
							RETURN cCodRet, cMensaje;			
						END IF;	
					END IF;
				END IF;			
			END IF;				
			IF cStatus = '0' THEN					
				--OV
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_ov('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;			
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_OV', FechaFin, '1', 'informix', 'sp_remesaswu_pld_ov', cDescripcionSPJOV);			
			END IF;
			LET cStatus = '0';			
			
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;			
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE VG";
				RETURN cCodRet, cMensaje;			
			END IF;	
			IF FechaIni = FechaFin THEN		
				IF NOT EXISTS (SELECT * FROM "informix".sac_procesos_jobs where proceso='IND_PLD_V' and fecha_proceso = FechaFin) THEN
					--INSERTA EN BITACORA
					EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_PLD_V', FechaFin, '0', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);
				ELSE
					SELECT status 
					INTO cStatus
					FROM "informix".sac_procesos_jobs 
					WHERE proceso='IND_PLD_V' and fecha_proceso = FechaFin;
					IF cStatus = '0' THEN					
						--DELETE {+INDEX("informix".sac_pld_remesas idxsac_pld_remesasft)} FROM "informix".sac_pld_remesas where tipo_remesa='VIG' and fecha_proceso = FechaFin;										
						EXECUTE PROCEDURE sp_inicializatablaspld('','VIG',FechaFin) INTO cCodRetSP;			
						IF cCodRetSP <> '00000' THEN
							LET cCodRet = '00001';
							LET cMensaje = "ERROR AL BORRAR REGISTROS DE VG EN TABLA DE PLD";							
							RETURN cCodRet, cMensaje;			
						END IF;		
					END IF;
				END IF;			
			END IF;			
			IF cStatus = '0' THEN			
				--VG
				EXECUTE PROCEDURE "informix".sp_remesaswu_pld_vg('WUN',FechaIni, FechaFin) INTO cCodRet, cMensaje;
				IF cCodRet <> '00000' THEN
					RETURN cCodRet, cMensaje;
				END IF;
				--ACTUALIZA EN BITACORA
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_PLD_V', FechaFin, '1', 'informix', 'sp_remesaswu_pld_vg', cDescripcionSPJVG);	
			END IF;
		END IF;			
		
		RETURN cCodRet, cMensaje;

	END;
			EXECUTE PROCEDURE sp_inicializatablaspld('BWUN','',FechaFin) INTO cCodRetSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = '00001';
				LET cMensaje = "ERROR AL BORRAR TABLAS DE PASO DE WU";
				RETURN cCodRet, cMensaje;			
			END IF;	
END PROCEDURE;
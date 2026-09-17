CREATE PROCEDURE "informix".sp_benefremesas_bts(pFechaIni DATE, pFechaFin DATE)
RETURNING
CHAR(5)		AS codigo_respuesta,
CHAR(80)	AS mensaje_respuesta;

	--DEFINICIONES
	DEFINE iSqlErr              	INTEGER;
	DEFINE iIsamErr             	INTEGER;
	DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(80);
	DEFINE cDescripcionINS			CHAR(100);
	DEFINE cStmt					CHAR(400);
	DEFINE cStatus					CHAR(1);
	DEFINE iCuantosTelefonos		INTEGER;
	DEFINE cPrimer_nombre			CHAR(40);
	DEFINE cSegundo_nombre			CHAR(40);
	DEFINE cApellido_paterno		CHAR(40);
	DEFINE cApellido_materno		CHAR(40);
	DEFINE cFecha_nacimiento		CHAR(8);
	DEFINE cNumero_identificacion	CHAR(20);
	DEFINE iNumero_total_remesas	INTEGER;
	DEFINE mMonto_total_remesas		MONEY;
	DEFINE cr_ciudad				CHAR(50);
	DEFINE cr_estado				CHAR(50);
	DEFINE cr_telefono				CHAR(15);
	DEFINE cr_telefono1				CHAR(15);
	DEFINE cr_telefono2				CHAR(15);
	DEFINE cr_telefono3				CHAR(15);
	DEFINE dFechaIni 				DATE;
	DEFINE dFechaFin				DATE;
	DEFINE sCont					SMALLINT;
	DEFINE cConfirmationName		CHAR(11);
	DEFINE cFechaInsert				DATETIME YEAR TO FRACTION(5);
	DEFINE vOrigen					VARCHAR(20);
	DEFINE dMontoTotalRemesas		DECIMAL(12,2);
	DEFINE CBankRefNm				CHAR(20);
	DEFINE CDestinationAm			CHAR(20);
	DEFINE iIdProceso				INTEGER;
	DEFINE iIdSubProceso			INTEGER;
	
	
	--INICIALIZACIONES
	LET iCuantosTelefonos			= 0;
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cDescripcionINS		 		= 'Inserta info beneficiarios con mas de 3 remesas pagadas BTS en periodo de 6 meses';
	LET cStmt						= '';
	LET cStatus						= '0';
	LET cPrimer_nombre				= '';
	LET cSegundo_nombre				= '';
	LET cApellido_paterno			= '';
	LET cApellido_materno			= '';
	LET cFecha_nacimiento			= '';
	LET cNumero_identificacion		= '';
	LET iNumero_total_remesas		= 0;
	LET mMonto_total_remesas		= 0;
	LET cr_ciudad					= '';
	LET cr_estado					= '';
	LET cr_telefono					= '';
	LET cr_telefono1				= '';
	LET cr_telefono2				= '';
	LET cr_telefono3				= '';
	LET dFechaIni 					= '';
	LET dFechaFin					= '';
	LET sCont						= 0;
	LET cConfirmationName			= '';
	LET cFechaInsert				= '';
	LET vOrigen						= '';
	LET dMontoTotalRemesas			= 0;
	LET CBankRefNm					= '';
	LET CDestinationAm 				= '';
	LET iIdProceso					= 0;
	
	
	--SET DEBUG FILE TO "/tmp/adrian/sp_benefremesas_bts.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_benefremesas_bts");
                RETURN cCodRet, cMensaje;
			END IF;
		END EXCEPTION;
		
		--OBTENER FECHAS PARA PROCESO AUTOMATICO
		IF pFechaIni = pFechaFin THEN
			LET dFechaIni = pFechaFin - 6 UNITS MONTH;
			LET dFechaIni = MDY(MONTH(dFechaIni),01,YEAR(dFechaIni));
			LET dFechaFin = pFechaFin;
			LET dFechaFin = MDY(MONTH(dFechaFin),01,YEAR(dFechaFin));
		ELSE --OBTENER FECHAS PARA PROCESO MANUAL
			LET dFechaIni = pFechaIni;					
			LET dFechaFin = pFechaFin;
		END IF;
		
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ALTA', 0, 0, 'REPORTE BTS', '', 'informix')
		INTO iIdProceso, iIdSubProceso;
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso = 'INS_BENREM_BTS' and fecha_proceso = pFechaFin) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_BENREM_BTS', pFechaFin, '0', 'informix', 'sp_benefremesas_bts', cDescripcionINS);	
		ELSE
			SELECT status
			INTO   cStatus
			FROM   bdisac:"informix".sac_procesos_jobs
			WHERE  proceso       = 'INS_BENREM_BTS'
			AND    fecha_proceso = pFechaFin;
			IF cStatus = '0' THEN
				--Borro historial
				DELETE {+INDEX(bdisac:"informix".sac_benefremesas idxsac_benefremesasfm)}
				FROM   bdisac:"informix".sac_benefremesas
				WHERE  fecha = dFechaFin
				AND    marca = 'BTS';
			END IF;
		END IF;
		
		--SE EJECUTA SOLO SI NO HAY REGISTRO EXITOSO
		IF cStatus = '0' THEN
		
			-----PASO 1: Trunco datos de las tablas establecidas
			TRUNCATE bdisac:"informix".sac_bts_agrupa_totales;
			TRUNCATE bdisac:"informix".sac_bts_revi_totales;
			TRUNCATE bdisac:"informix".sac_bts_filtra_totales;
			TRUNCATE bdisac:"informix".sac_bts_final_totales;
			TRUNCATE bdisac:"informix".sac_bts_tels_totales;
			TRUNCATE bdisac:"informix".sac_bts_qryi_montos_unique;
			TRUNCATE bdisac:"informix".sac_bts_qryi_montos;
			
			-----PASO 1: Obtengo datos de proceso global (sac_bts_payi + sac_bts_payi_old)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_04;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_05;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_06;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_agrupa_totales_07;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_bts_pay_old
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT r_fecha_nac, r_identif_nm, confirmation_nm,
					   r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_ciudad, r_estado, r_telefono,
					   0, fecha_insert, 'sac_bts_payi_old' AS origen, bank_ref_nm
				INTO   cFecha_nacimiento, cNumero_identificacion, cConfirmationName,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cr_ciudad, cr_estado, cr_telefono,
					   dMontoTotalRemesas, cFechaInsert, vOrigen, CBankRefNm
				FROM   bdisac:"informix".sac_bts_payi_old
				WHERE  opcode      =  '1100'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_bts_agrupa_totales (r_fecha_nac, r_identif_nm, confirmation_nm, bank_ref_nm, r_first_name,
						r_middle_name, r_last_name, r_mother_m_name, r_ciudad, r_estado, r_telefono,
						monto_total_remesas, fecha_insert, origen, reversada)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cConfirmationName, CBankRefNm, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cr_ciudad, cr_estado, cr_telefono,
					    dMontoTotalRemesas, cFechaInsert, vOrigen, 0);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_bts_pay
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT r_fecha_nac, r_identif_nm, confirmation_nm,
					   r_first_name, r_middle_name, r_last_name, r_mother_m_name, r_ciudad, r_estado, r_telefono,
					   0, fecha_insert, 'sac_bts_payi' AS origen, bank_ref_nm
				INTO   cFecha_nacimiento, cNumero_identificacion, cConfirmationName,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cr_ciudad, cr_estado, cr_telefono,
					   dMontoTotalRemesas, cFechaInsert, vOrigen, CBankRefNm
				FROM   bdisac:"informix".sac_bts_payi
				WHERE  opcode       =  '1100'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_bts_agrupa_totales (r_fecha_nac, r_identif_nm, confirmation_nm, bank_ref_nm, r_first_name,
						r_middle_name, r_last_name, r_mother_m_name, r_ciudad, r_estado, r_telefono,
						monto_total_remesas, fecha_insert, origen, reversada)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cConfirmationName, CBankRefNm, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cr_ciudad, cr_estado, cr_telefono,
					    dMontoTotalRemesas, cFechaInsert, vOrigen, 0);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_01
			ON bdisac:"informix".sac_bts_agrupa_totales(r_fecha_nac, r_identif_nm) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_02
			ON bdisac:"informix".sac_bts_agrupa_totales(confirmation_nm) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_03
			ON bdisac:"informix".sac_bts_agrupa_totales(fecha_insert) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_04
			ON bdisac:"informix".sac_bts_agrupa_totales(confirmation_nm, bank_ref_nm) ONLINE;

			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_05
			ON bdisac:"informix".sac_bts_agrupa_totales(r_fecha_nac, r_identif_nm, fecha_insert) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_06
			ON bdisac:"informix".sac_bts_agrupa_totales(confirmation_nm, reversada) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_agrupa_totales_07
			ON bdisac:"informix".sac_bts_agrupa_totales(reversada) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_agrupa_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			-----PASO 2: Obtengo datos de proceso global (sac_bts_qryi + sac_bts_qryi_old)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
		
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_qryi_montos_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_qryi_montos_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_qryi_montos_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_qryi_montos_04;
			
			LET sCont = 0;
		
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_bts_pay_old
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT confirmation_nm, destination_am::DECIMAL(12,2), fecha_insert, 'sac_bts_qryi_old' AS origen
				INTO   cConfirmationName, dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_bts_qryi_old
				WHERE  opcode      =  '1000'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_bts_qryi_montos (confirmation_nm, monto_total_remesas, fecha_insert, origen)
				VALUES (cConfirmationName, dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_bts_pay
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT confirmation_nm, destination_am::DECIMAL(12,2), fecha_insert, 'sac_bts_qryi' AS origen
				INTO   cConfirmationName, dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_bts_qryi
				WHERE  opcode      =  '1000'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_bts_qryi_montos (confirmation_nm, monto_total_remesas, fecha_insert, origen)
				VALUES (cConfirmationName, dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_bts_qryi_montos_01
			ON bdisac:"informix".sac_bts_qryi_montos(confirmation_nm) ONLINE;

			CREATE INDEX bdisac:"informix".idx_sac_bts_qryi_montos_02
			ON bdisac:"informix".sac_bts_qryi_montos(fecha_insert) ONLINE;

			CREATE INDEX bdisac:"informix".idx_sac_bts_qryi_montos_03
			ON bdisac:"informix".sac_bts_qryi_montos(confirmation_nm, fecha_insert) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_bts_qryi_montos_04
			ON bdisac:"informix".sac_bts_qryi_montos(confirmation_nm, monto_total_remesas) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_qryi_montos;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			
			-----PASO 3: Obtengo informacion UNIQUE de la tabla sac_bts_qryi_montos
			--    y almaceno en la tabla sac_bts_qryi_montos_unique
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_qryi_montos_unique_01;
			
			INSERT INTO bdisac:"informix".sac_bts_qryi_montos_unique
			SELECT UNIQUE {+INDEX(sac_bts_qryi_montos idx_sac_bts_qryi_montos_04)}
			       confirmation_nm, monto_total_remesas
			FROM   bdisac:"informix".sac_bts_qryi_montos;
			
			CREATE INDEX idx_sac_bts_qryi_montos_unique_01
			ON sac_bts_qryi_montos_unique(confirmation_nm) ONLINE;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			-----PASO 4: Obtengo datos de proceso global en reversos (sac_bts_revi)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS idx_sac_bts_revi_totales_01;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_bts_pay_old
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT confirmation_nm, bank_ref_nm, fecha_insert, 'sac_bts_revi' AS origen
				INTO   cConfirmationName, CBankRefNm, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_bts_revi
				WHERE  opcode      =  '1200'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_bts_revi_totales (confirmation_nm, bank_ref_nm, fecha_insert, origen)
				VALUES (cConfirmationName, CBankRefNm, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_bts_revi_totales_01
			ON bdisac:"informix".sac_bts_revi_totales(confirmation_nm, bank_ref_nm) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_revi_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			
			-----PASO 5: Hago un Join entre las tablas sac_bts_agrupa_totales y sac_bts_revi_totales,
			-----        Para las coincidencias, actualizo el campo reversada a 1 (Fue reversada manualmente)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			FOREACH
				SELECT {+INDEX(sac_bts_agrupa_totales idx_sac_bts_agrupa_totales_04)}
					   b.confirmation_nm, b.bank_ref_nm
				INTO   cConfirmationName, CBankRefNm
				FROM   bdisac:"informix".sac_bts_agrupa_totales a,
				       bdisac:"informix".sac_bts_revi_totales b
				WHERE  a.confirmation_nm = b.confirmation_nm
				AND    a.bank_ref_nm     = b.bank_ref_nm
				
				UPDATE bdisac:"informix".sac_bts_agrupa_totales
				SET    reversada       = 1
				WHERE  confirmation_nm = cConfirmationName
				AND    bank_ref_nm     = CBankRefNm;
				
			END FOREACH;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			-----PASO 6: Filtro datos de solo los que cumplan con la condicion que tengan mas de 3 remesas pagadas de la tabla generada en el paso 1
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 6', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			--DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_filtra_totales_01;
			--DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_filtra_totales_02;
			--DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_filtra_totales_03;
			--DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_filtra_totales_04;
			
			--Ahora si inicio primero sabiendo de la base total aquellas que tengan mas de 3 remesas
			SET ISOLATION TO DIRTY READ;
			INSERT   INTO bdisac:"informix".sac_bts_filtra_totales
			SELECT   {+INDEX(sac_bts_agrupa_totales idx_sac_bts_agrupa_totales_01)}
					 r_fecha_nac, r_identif_nm,
					 COUNT(*) AS numero_total_remesas,
					 SUM(b.monto_total_remesas) AS monto_total_remesas,
					 MAX(fecha_insert) AS secuencia
			FROM     bdisac:"informix".sac_bts_agrupa_totales a,
					 bdisac:"informix".sac_bts_qryi_montos_unique b			
			WHERE    reversada = 0			
			AND    a.confirmation_nm = b.confirmation_nm
			GROUP BY 1,2
			HAVING COUNT(*) >= 3;
			
			--Creo nuevamente los indices a la tabla
			--CREATE INDEX bdisac:"informix".idx_sac_bts_filtra_totales_01
			--ON bdisac:"informix".sac_bts_filtra_totales(r_fecha_nac, r_identif_nm) ONLINE;

			--CREATE INDEX bdisac:"informix".idx_sac_bts_filtra_totales_02
			--ON bdisac:"informix".sac_bts_filtra_totales(secuencia) ONLINE;

			--CREATE INDEX bdisac:"informix".idx_sac_bts_filtra_totales_03
			--ON bdisac:"informix".sac_bts_filtra_totales(r_fecha_nac, r_identif_nm, secuencia) ONLINE;

			--CREATE INDEX bdisac:"informix".idx_sac_bts_filtra_totales_04
			--ON bdisac:"informix".sac_bts_filtra_totales(r_fecha_nac, r_identif_nm, numero_total_remesas, monto_total_remesas) ONLINE;

			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_filtra_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 6', 'informix')
			INTO iIdProceso, iIdSubProceso;
			/*
			-----PASO 7: Tomo la base de datos de la tabla sac_bts_filtra_totales, para generar los montos
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 7', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			FOREACH
				SELECT SUM(c.monto_total_remesas) as monto_total_remesas, a.r_fecha_nac, a.r_identif_nm
				INTO   dMontoTotalRemesas, cFecha_nacimiento, cNumero_identificacion
				FROM   bdisac:"informix".sac_bts_filtra_totales a,
				       bdisac:"informix".sac_bts_agrupa_totales b,
					   bdisac:"informix".sac_bts_qryi_montos_unique c
				WHERE  a.r_fecha_nac     = b.r_fecha_nac
				AND    a.r_identif_nm    = b.r_identif_nm
				AND    b.reversada       = 0
				AND    b.confirmation_nm = c.confirmation_nm
					
					--Actualizo datos en caso de ser distinto a cero
					IF dMontoTotalRemesas != 0 THEN
					
						UPDATE bdisac:"informix".sac_bts_filtra_totales
						SET    monto_total_remesas = dMontoTotalRemesas
						WHERE  r_fecha_nac     = cFecha_nacimiento 
						AND r_identif_nm = cNumero_identificacion;
					
					END IF
			
			END FOREACH;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 7', 'informix')
			INTO iIdProceso, iIdSubProceso;
			*/
			-----PASO 7: Obtengo el dato del ultimo registro segun su secuencia.
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 7', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_final_totales_01;
			
			--Obtengo los datos ligando la secuencia
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_bts_final_totales
			SELECT {+INDEX(sac_bts_filtra_totales idx_sac_bts_filtra_totales_04)}c.r_fecha_nac, c.r_identif_nm, a.r_first_name, a.r_middle_name,
				   a.r_last_name, a.r_mother_m_name, a.r_ciudad, a.r_estado, a.r_telefono,
				   c.numero_total_remesas, c.monto_total_remesas
			FROM   bdisac:"informix".sac_bts_agrupa_totales a,
			       bdisac:"informix".sac_bts_filtra_totales c
			WHERE  a.r_fecha_nac  = c.r_fecha_nac
			AND    a.r_identif_nm = c.r_identif_nm
			AND    a.fecha_insert = c.secuencia;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_bts_final_totales_01
			ON bdisac:"informix".sac_bts_final_totales(r_fecha_nac, r_identif_nm) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_final_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 7', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			
			-----PASO 8: Obtengo unicidad de celulares por fechaNacimiento e IdNumber
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 8', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_bts_tels_totales_01;
			
			--Obtener unicidad de celulares por fechaNacimiento e IdNumber
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_bts_tels_totales
			SELECT UNIQUE a.r_fecha_nac, a.r_identif_nm, a.r_telefono
			FROM   bdisac:"informix".sac_bts_agrupa_totales a,
			       bdisac:"informix".sac_bts_final_totales b
			WHERE  a.r_fecha_nac = b.r_fecha_nac
			AND    a.r_identif_nm = b.r_identif_nm;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_bts_tels_totales_01
			ON bdisac:"informix".sac_bts_tels_totales(r_fecha_nac, r_identif_nm) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_bts_tels_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 8', 'informix')
			INTO iIdProceso, iIdSubProceso;			
			
			-----PASO 9: Genero la base final con los 3 numeros telefonicos
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE BTS', 'PASO 9', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			LET sCont = 0;
			
			--Realizo algoritmo para determinar los 3 numeros telefonicos
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT {+INDEX(sac_bts_final_totales idx_sac_bts_final_totales_01)}
					   r_fecha_nac, r_identif_nm, numero_total_remesas, monto_total_remesas,
					   r_ciudad, r_estado, r_first_name, r_middle_name, r_last_name, r_mother_m_name
				INTO   cFecha_nacimiento, cNumero_identificacion, iNumero_total_remesas, mMonto_total_remesas,
					   cr_ciudad, cr_estado, cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno
				FROM   bdisac:"informix".sac_bts_final_totales
				
				--Inicializaciones de las variables a utilizar
				LET iCuantosTelefonos = 0;
				LET cr_telefono1      = '';
				LET cr_telefono2      = '';
				LET cr_telefono3      = '';
				
				FOREACH
					SELECT FIRST 3 r_telefono
					INTO   cr_telefono
					FROM   bdisac:"informix".sac_bts_tels_totales
					WHERE  r_fecha_nac = cFecha_nacimiento
					AND    r_identif_nm = cNumero_identificacion
					
					IF cr_telefono <> '' AND cr_telefono is NOT NULL THEN
						IF iCuantosTelefonos = 0 THEN
							LET cr_telefono1 = cr_telefono;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 1 AND (cr_telefono1 <> cr_telefono) THEN
							LET cr_telefono2 = cr_telefono;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 2 AND (cr_telefono1 <> cr_telefono) AND (cr_telefono2 <> cr_telefono) THEN
							LET cr_telefono3 = cr_telefono;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos >= 3 THEN
							EXIT FOREACH;
						END IF;
					END IF;
					
				END FOREACH;
				
				LET cStmt = 'BTS'||'|'||TRIM(cPrimer_nombre)|| ' ' ||TRIM(cSegundo_nombre)|| ' ' ||TRIM(cApellido_paterno)|| ' ' ||TRIM(cApellido_materno)||'|'||TRIM(cr_ciudad)||'|'||TRIM(cr_estado)||'|'||TRIM(cr_telefono1)||'|'||TRIM(cr_telefono2)||'|'||TRIM(cr_telefono3)||'|'||iNumero_total_remesas||'|'||mMonto_total_remesas;
				
				INSERT INTO bdisac:"informix".sac_benefremesas (fecha,marca,linea,fecha_insert)
				VALUES(dFechaFin,'BTS',cStmt,current);
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;

			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
				LET sCont = 0;
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE BTS', 'PASO 9', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--ACTUALIZA STATUS DE INSERTA INFO
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj(1, 'INS_BENREM_BTS', pFechaFin, '1', 'informix', 'sp_benefremesas_bts', cDescripcionINS);		
			
		END IF;	--EJECUTE SOLO SI NO HAY REGISTRO
		
		
		RETURN cCodRet, cMensaje;

	END;
END PROCEDURE;
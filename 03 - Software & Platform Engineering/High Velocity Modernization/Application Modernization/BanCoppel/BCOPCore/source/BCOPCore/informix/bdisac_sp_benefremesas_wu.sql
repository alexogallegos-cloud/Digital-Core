CREATE PROCEDURE "informix".sp_benefremesas_wu(pFechaIni DATE,pFechaFin DATE)
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
	DEFINE cBenef_ciudad			CHAR(24);
	DEFINE cBenef_edo				CHAR(40);
	DEFINE cBenef_tel_celular		CHAR(20);
	DEFINE cBenef_tel_celular1		CHAR(20);
	DEFINE cBenef_tel_celular2		CHAR(20);
	DEFINE cBenef_tel_celular3		CHAR(20);
	DEFINE dFechaIni 				DATE;
	DEFINE dFechaFin				DATE;
	DEFINE sCont					SMALLINT;
	DEFINE cMtcn					CHAR(10);
	DEFINE cFechaInsert				DATETIME YEAR TO SECOND;
	DEFINE vOrigen					VARCHAR(15);
	DEFINE dMontoTotalRemesas		DECIMAL(12,2);
	DEFINE iIdProceso				INTEGER;
	DEFINE iIdSubProceso			INTEGER;
	
	--INICIALIZACIONES
	LET iCuantosTelefonos			= 0;
	LET cCodRet  					= "00000";
	LET cMensaje 					= 'PROCESO EXITOSO';	
	LET cDescripcionINS		 		= 'Inserta info beneficiarios con mas de 3 remesas WUOVVG pagadas en periodo de 6 meses';
	LET cStmt						= '';
	LET cStatus						= '0';
	LET iCuantosTelefonos			= 0;
	LET cPrimer_nombre				= '';
	LET cSegundo_nombre				= '';
	LET cApellido_paterno			= '';
	LET cApellido_materno			= '';
	LET cFecha_nacimiento			= '';
	LET cNumero_identificacion		= '';
	LET iNumero_total_remesas		= 0;
	LET mMonto_total_remesas		= 0;
	LET cBenef_ciudad				= '';
	LET cBenef_edo					= '';
	LET cBenef_tel_celular			= '';
	LET cBenef_tel_celular1			= '';
	LET cBenef_tel_celular2			= '';
	LET cBenef_tel_celular3			= '';
	LET dFechaIni 					= '';
	LET dFechaFin					= '';
	LET sCont						= 0;
	LET cMtcn						= '';
	LET cFechaInsert				= '';
	LET vOrigen						= '';
	LET dMontoTotalRemesas			= 0;
	
	--SET DEBUG FILE TO "/tmp/adrian/sp_benefremesas_wu.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_benefremesas_wu");
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
		
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ALTA', 0, 0, 'REPORTE WUN', '', 'informix')
		INTO iIdProceso, iIdSubProceso;
		
		IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_procesos_jobs where proceso='INS_BENREM_WU' and fecha_proceso = pFechaFin) THEN								
			--INSERTA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_BENREM_WU', pFechaFin, '0', 'informix', 'sp_benefremesas_wu', cDescripcionINS);	
		ELSE
			SELECT status
			INTO   cStatus
			FROM   bdisac:"informix".sac_procesos_jobs
			WHERE  proceso       = 'INS_BENREM_WU'
			AND    fecha_proceso = pFechaFin;
			IF cStatus = '0' THEN
				--Borro historial
				DELETE {+INDEX(bdisac:"informix".sac_benefremesas idxsac_benefremesasfm)}
				FROM   bdisac:"informix".sac_benefremesas
				WHERE  fecha = dFechaFin
				AND    marca = 'WUN';
			END IF;
		END IF;
		
		--SE EJECUTA SOLO SI NO HAY REGISTRO EXITOSO
		IF cStatus = '0' THEN
		
			--Trunco datos de las tablas establecidas
			TRUNCATE bdisac:"informix".sac_wu_agrupa_totales;
			TRUNCATE bdisac:"informix".sac_wu_filtra_totales;
			TRUNCATE bdisac:"informix".sac_wu_tels_totales;
			TRUNCATE bdisac:"informix".sac_wu_final_totales;
		
			-----PASO 1: Obtengo datos de proceso global (sac_wu_pay + sac_wu_pay_old)
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_agrupa_totales_04;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_wu_pay_old
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT benef_fecha_nac, benef_id_number, mtcn, 
					   benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   NVL(((DECODE(monto_destino,'', '0', NULL, '0', monto_destino)::INTEGER)/100)::MONEY,0) AS monto_total_remesas,
					   fecha_insert, 'sac_wu_pay_old' AS origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cMtcn,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_pay_old
				WHERE  retcode      =  '00000'
				AND    conf_pago    =  'P'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			LET sCont = 0;
			
			--Lleno datos iniciales para tomar en cuenta de la tabla sac_wu_pay
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT benef_fecha_nac, benef_id_number, mtcn, 
					   benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   NVL(((DECODE(monto_destino,'', '0', NULL, '0', monto_destino)::INTEGER)/100)::MONEY,0) AS monto_total_remesas,
					   fecha_insert, 'sac_wu_pay' AS origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cMtcn,
				       cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_pay
				WHERE  retcode      =  '00000'
				AND    conf_pago    =  'P'
				AND    fecha_insert >= dFechaIni
				AND    fecha_insert <  dFechaFin
				
				LET sCont = sCont + 1;
				IF sCont = 5000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			IF sCont < 5000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_01
			ON bdisac:"informix".sac_wu_agrupa_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_02
			ON bdisac:"informix".sac_wu_agrupa_totales(mtcn) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_03
			ON bdisac:"informix".sac_wu_agrupa_totales(fecha_insert) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_agrupa_totales_04
			ON bdisac:"informix".sac_wu_agrupa_totales(benef_fecha_nac, benef_id_number, fecha_insert) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_agrupa_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 1', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 2: Quitare los registros duplicados (mtcn) Dado que uno de los movimientos esta reversado
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			FOREACH
				SELECT mtcn, COUNT(*) AS cuenta
				INTO   cMtcn, sCont
				FROM   bdisac:"informix".sac_wu_agrupa_totales
				GROUP BY mtcn
				HAVING COUNT(*) > 1
				
				SELECT FIRST 1 benef_fecha_nac, benef_id_number, benef_nombre1, benef_nombre2, benef_appaterno,
				       benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
					   monto_total_remesas, fecha_insert, origen
				INTO   cFecha_nacimiento, cNumero_identificacion, cPrimer_nombre, cSegundo_nombre,
				       cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					   dMontoTotalRemesas, cFechaInsert, vOrigen
				FROM   bdisac:"informix".sac_wu_agrupa_totales
				WHERE  mtcn         = cMtcn
				AND    fecha_insert = (SELECT MAX(fecha_insert) FROM sac_wu_agrupa_totales WHERE mtcn = cMtcn);
				
				--Primero borro los registros duplicados
				DELETE FROM bdisac:"informix".sac_wu_agrupa_totales
				WHERE mtcn = cMtcn;
				
				--Finalmente inserto el ultimo registro encontrado para el mtcn
				INSERT INTO bdisac:"informix".sac_wu_agrupa_totales (benef_fecha_nac, benef_id_number, mtcn, benef_nombre1,
						benef_nombre2, benef_appaterno, benef_apmaterno, benef_ciudad, benef_edo, benef_tel_celular,
						monto_total_remesas, fecha_insert, origen)
				VALUES (cFecha_nacimiento, cNumero_identificacion, cMtcn, cPrimer_nombre, cSegundo_nombre,
						cApellido_paterno, cApellido_materno, cBenef_ciudad, cBenef_edo, cBenef_tel_celular,
					    dMontoTotalRemesas, cFechaInsert, vOrigen);
				
			END FOREACH;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 2', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 3: Filtro datos de solo los que cumplan con la condicion que tengan mas de 3 remesas pagadas de la tabla generada en el paso 1
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_01;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_02;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_03;
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_filtra_totales_04;
			
			--Ahora si inicio primero sabiendo de la base total aquellas que tengan mas de 3 remesas
			SET ISOLATION TO DIRTY READ;
			INSERT   INTO bdisac:"informix".sac_wu_filtra_totales
			SELECT   {+INDEX(sac_wu_agrupa_totales idx_sac_wu_agrupa_totales_01)}
					 benef_fecha_nac, benef_id_number,
					 COUNT(*) AS numero_total_remesas,
					 SUM(monto_total_remesas) AS monto_total_remesas,
					 MAX(fecha_insert) AS secuencia
			FROM     bdisac:"informix".sac_wu_agrupa_totales
			GROUP BY 1,2
			HAVING COUNT(*) >= 3;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_01
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number) ONLINE;

			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_02
			ON bdisac:"informix".sac_wu_filtra_totales(secuencia) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_03
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number, secuencia) ONLINE;
			
			CREATE INDEX bdisac:"informix".idx_sac_wu_filtra_totales_04
			ON bdisac:"informix".sac_wu_filtra_totales(benef_fecha_nac, benef_id_number, numero_total_remesas, monto_total_remesas) ONLINE;

			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_filtra_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 3', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 4: Obtengo el dato del ultimo registro segun su secuencia.
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_final_totales_01;
			
			--Obtengo los datos ligando la secuencia
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_wu_final_totales
			SELECT {+INDEX(sac_wu_filtra_totales idx_sac_wu_filtra_totales_04)}c.benef_fecha_nac, c.benef_id_number, a.benef_nombre1, a.benef_nombre2,
				   a.benef_appaterno, a.benef_apmaterno, a.benef_ciudad, a.benef_edo, a.benef_tel_celular,
				   c.numero_total_remesas, c.monto_total_remesas
			FROM   bdisac:"informix".sac_wu_agrupa_totales a,
			       bdisac:"informix".sac_wu_filtra_totales c
			WHERE  a.benef_fecha_nac = c.benef_fecha_nac
			AND    a.benef_id_number = c.benef_id_number
			AND    a.fecha_insert    = c.secuencia;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_final_totales_01
			ON sac_wu_final_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_final_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 5: Obtengo unicidad de celulares por fechaNacimiento e IdNumber
			
			--Intento borrar los indices de la tabla
			DROP INDEX IF EXISTS bdisac:"informix".idx_sac_wu_tels_totales_01;
			
			--Obtener unicidad de celulares por fechaNacimiento e IdNumber
			SET ISOLATION TO DIRTY READ;
			INSERT INTO bdisac:"informix".sac_wu_tels_totales
			SELECT UNIQUE a.benef_fecha_nac, a.benef_id_number, a.benef_tel_celular
			FROM   bdisac:"informix".sac_wu_agrupa_totales a,
			       bdisac:"informix".sac_wu_final_totales b
			WHERE  a.benef_fecha_nac = b.benef_fecha_nac
			AND    a.benef_id_number = b.benef_id_number;
			
			--Creo nuevamente los indices a la tabla
			CREATE INDEX bdisac:"informix".idx_sac_wu_tels_totales_01
			ON bdisac:"informix".sac_wu_tels_totales(benef_fecha_nac, benef_id_number) ONLINE;
			
			UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_wu_tels_totales;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 4', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			-----PASO 6: Genero la base final con los 3 numeros telefonicos
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, 0, 'REPORTE WUN', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			LET sCont = 0;
			
			--Realizo algoritmo para determinar los 3 numeros telefonicos
			BEGIN WORK;
			FOREACH WITH HOLD
				SELECT {+INDEX(sac_wu_final_totales idx_sac_wu_final_totales_01)}
					   benef_fecha_nac, benef_id_number, numero_total_remesas, monto_total_remesas,
					   benef_ciudad, benef_edo, benef_nombre1, benef_nombre2, benef_appaterno, benef_apmaterno
				INTO   cFecha_nacimiento, cNumero_identificacion, iNumero_total_remesas, mMonto_total_remesas,
					   cBenef_ciudad, cBenef_edo, cPrimer_nombre, cSegundo_nombre, cApellido_paterno, cApellido_materno
				FROM   bdisac:"informix".sac_wu_final_totales
				
				--Inicializaciones de las variables a utilizar
				LET iCuantosTelefonos = 0;
				LET cBenef_tel_celular1 = '';
				LET cBenef_tel_celular2 = '';
				LET cBenef_tel_celular3 = '';
				
				FOREACH
					SELECT FIRST 3 benef_tel_celular
					INTO   cBenef_tel_celular
					FROM   bdisac:"informix".sac_wu_tels_totales
					WHERE  benef_fecha_nac = cFecha_nacimiento
					AND    benef_id_number = cNumero_identificacion
					
					IF cBenef_tel_celular <> '' AND cBenef_tel_celular is NOT NULL THEN
						IF iCuantosTelefonos = 0 THEN
							LET cBenef_tel_celular1 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 1 AND (cBenef_tel_celular1 <> cBenef_tel_celular) THEN
							LET cBenef_tel_celular2 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos = 2 AND (cBenef_tel_celular1 <> cBenef_tel_celular) AND (cBenef_tel_celular2 <> cBenef_tel_celular) THEN
							LET cBenef_tel_celular3 = cBenef_tel_celular;
							LET iCuantosTelefonos = iCuantosTelefonos + 1;
						ELIF iCuantosTelefonos >= 3 THEN
							EXIT FOREACH;
						END IF;
					END IF;
					
				END FOREACH;
				
				LET cStmt = 'WUN'||'|'||TRIM(cPrimer_nombre)|| ' ' ||TRIM(cSegundo_nombre)|| ' ' ||TRIM(cApellido_paterno)|| ' ' ||TRIM(cApellido_materno)||'|'||TRIM(cBenef_ciudad)||'|'||TRIM(cBenef_edo)||'|'||TRIM(cBenef_tel_celular1)||'|'||TRIM(cBenef_tel_celular2)||'|'||TRIM(cBenef_tel_celular3)||'|'||iNumero_total_remesas||'|'||mMonto_total_remesas;
				
				INSERT INTO bdisac:"informix".sac_benefremesas (fecha,marca,linea,fecha_insert)
				VALUES(dFechaFin,'WUN',cStmt,current);
				
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
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacora_proceso('ACTUALIZA', iIdProceso, iIdSubProceso, 'REPORTE WUN', 'PASO 5', 'informix')
			INTO iIdProceso, iIdSubProceso;
			
			--ACTUALIZA STATUS DE INSERTA INFO
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj(1, 'INS_BENREM_WU', pFechaFin, '1', 'informix', 'sp_benefremesas_wu', cDescripcionINS);		
			
		END IF;	--EJECUTE SOLO SI NO HAY REGISTRO
		
		
		RETURN cCodRet, cMensaje;

	END;
END PROCEDURE;
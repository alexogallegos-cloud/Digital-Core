CREATE PROCEDURE "informix".sp_conciliacion_bcpl_cpl_sig_dia()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(80);
	DEFINE cCodRetSP		CHAR(5);
	DEFINE cMensajeSP		CHAR(80);
	DEFINE dFecha_Hoy		DATE;
	DEFINE cStatus			CHAR(1);
	DEFINE bExisteCarga		SMALLINT;
	
    LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cCodRetSP			= '99999';
	LET cMensajeSP			= 'ERROR';
	LET dFecha_Hoy			= DATE(1);
	LET cStatus				= '0';
	LET bExisteCarga		= 1;
	
	--SET DEBUG FILE TO  '/tmp/adrian/sp_conciliacion_bcpl_cpl_sig_dia.out';
	--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_bcpl_cpl_sig_dia");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		--SE OBTIENE LA FECHA DEL DIA ANTERIOR (ESTA PENSADO PARA QUE EL REPROCESO SEA GENERADO EL MISMO DIA QUE LA FECHA DE PROCESO ORIGINAL)
		SELECT {+INDEX(bdisac:"informix".sac_fechas idx_sac_fechas)} fecha_hoy - 1
		INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;
		
		--PRIMERO REVISO QUE NO SE HAYA GENERADO EL PROCESO DE CARGA DE ARCHIVO DEL DIA A PROCESAR (DIA ANTERIOR)
		IF NOT EXISTS(SELECT *
		              FROM   sac_procesos
		              WHERE  proceso       IN ('CONCI_CARG', 'CONCI_CAR2')
		              AND    fecha_proceso = dFecha_Hoy) THEN
					  
			--NO EXISTIÃ CARGA DE ARCHIVO PREVIA (SEGURAMENTE A ESA HORA NO EXISTIO ARCHIVO A CARGAR)
			LET bExisteCarga = 0;
			
		ELSE
		
			/* PLATICADO CON LEONARDO HERNANDEZ, EN ESTE MOMENTO EXCLUIDAS ESTAS OPCIONES */
			
			IF NOT EXISTS(SELECT *
						  FROM   sac_procesos
		                  WHERE  proceso       = 'CONCI_CAR2'
		                  AND    fecha_proceso = dFecha_Hoy) THEN
				--OBTENGO ESTATUS DEL PROCESO DE CARGA NORMAL (CRONT)
				SELECT status
				INTO   cStatus
				FROM   sac_procesos
				WHERE  proceso       = 'CONCI_CARG'
				AND    fecha_proceso = dFecha_Hoy;
			ELSE
				--OBTENGO ESTATUS DEL PROCESO DE CARGA MANUAL
				SELECT status
				INTO   cStatus
				FROM   sac_procesos
				WHERE  proceso       = 'CONCI_CAR2'
				AND    fecha_proceso = dFecha_Hoy;
			END IF;
			
			IF cStatus = '0' THEN
				LET bExisteCarga = 0;
			END IF;
			
		END IF;
		
		--SI LA BANDERA DE CARGA ES CORRECTA ENVIO MENSAJE Y TERMINO EJECUCION
		IF bExisteCarga = 1 THEN
			LET cCodRet  = '00001';
			LET cMensaje = 'NO ES NECESARIA ESTA CARGA EXTRAORDINARIA, CARGA PREVIA';
			RETURN cCodRet, cMensaje;
		END IF;
		
		--VALIDAR SI YA SE EJECUTO LA CARGA DEL ARCHIVO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_CAR3'
					AND  fecha_proceso = dFecha_Hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_CAR3', dFecha_Hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_CAR3'
			AND fecha_proceso = dFecha_Hoy;
		END IF;
		
		--CARGAR EL ARCHIVO (NUEVO INTENTO)
		IF cStatus = '0' THEN
			EXECUTE PROCEDURE "informix".sp_cargaarchivoaconciliacionbcpl(dFecha_Hoy) INTO cCodRetSP,cMensajeSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = cCodRetSP;
				LET cMensaje = cMensajeSP;
				RETURN cCodRet, cMensaje;				
			ELSE
				--ACTUALIZAR EL STATUS DE LA BITACORA
				UPDATE bdisac:"informix".sac_procesos
				SET status = '1'
				WHERE TRIM(proceso) = 'CONCI_CAR3'
				AND  fecha_proceso = dFecha_Hoy;
			END IF;				
		END IF;
		
		LET cStatus = '0';

		--VALIDAR SI TERMINO DE MANERA CORRECTA LA CARGA DEL ARCHIVO (NUEVO INTENTO)
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_MOV3'
					AND  fecha_proceso = dFecha_hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_MOV3', dFecha_hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_MOV3'
			AND fecha_proceso = dFecha_hoy;		
		END IF;
		
		--CONCILIAR MOVIMIENTOS
		IF cStatus = '0' THEN
			EXECUTE PROCEDURE "informix".sp_generaconciliacioncoppel(dFecha_Hoy) INTO cCodRetSP,cMensajeSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = cCodRetSP;
				LET cMensaje = cMensajeSP;
				RETURN cCodRet, cMensaje;
			ELSE
				--ACTUALIZAR EL STATUS DE LA BITACORA
				UPDATE bdisac:"informix".sac_procesos
				SET status = '1'
				WHERE TRIM(proceso) = 'CONCI_MOV3'
				AND  fecha_proceso = dFecha_hoy;

				--VALIDAR ACTUALIZACION DE BITACORA
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					LET cMensaje = 'ERROR AL ACTUALIZAR LA BITACORA PARA CONCI_MOV3';
					RETURN cCodRet,cMensaje;
				END IF;
			END IF;
		END IF;
        
        RETURN cCodRet,cMensaje;
		
    END;
END PROCEDURE
;
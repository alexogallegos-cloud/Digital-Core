CREATE PROCEDURE "informix".sp_conciliacion_bcpl_cpl()
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
	DEFINE laHora			CHAR(30);
	
    LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cCodRetSP			= '99999';
	LET cMensajeSP			= 'ERROR';
	LET dFecha_Hoy			= DATE(1);
	LET cStatus				= '0';
	
	--SET DEBUG FILE TO  '/tmp/adrian/sp_conciliacion_bcpl_cpl.out';
	--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_bcpl_cpl");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		--SE OBTIENE LA FECHA
		SELECT {+INDEX(bdisac:"informix".sac_fechas idx_sac_fechas)} fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas;
		
		--VALIDAR SI YA SE EJECUTO LA CARGA DEL ARCHIVO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_CARG'
					AND  fecha_proceso = dFecha_Hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_CARG', dFecha_Hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_CARG'
			AND fecha_proceso = dFecha_Hoy;
		END IF;
		
		--CARGAR EL ARCHIVO
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
				WHERE TRIM(proceso) = 'CONCI_CARG'
				AND  fecha_proceso = dFecha_Hoy;
			END IF;				
		END IF;
		
		LET cStatus = '0';

		--VALIDAR SI TERMINO DE MANERA CORRECTA LA CARGA DEL ARCHIVO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_MOVI'
					AND  fecha_proceso = dFecha_hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_MOVI', dFecha_hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_MOVI'
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
				WHERE TRIM(proceso) = 'CONCI_MOVI'
				AND  fecha_proceso = dFecha_hoy;

				--VALIDAR ACTUALIZACION DE BITACORA
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					LET cMensaje = 'ERROR AL ACTUALIZAR LA BITACORA PARA CONCI_MOVI';
					RETURN cCodRet,cMensaje;
				END IF;
			END IF;
		END IF;
        
        RETURN cCodRet,cMensaje;
    END;
END PROCEDURE
;
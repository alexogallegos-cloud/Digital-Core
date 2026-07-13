CREATE PROCEDURE "informix".sp_conciliacion_bcpl_cpl_rep()
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
	DEFINE cNumCategoria	CHAR(2);
	DEFINE cNumConvenio		CHAR(3);
	DEFINE cStatusConvenio	CHAR(1);
	DEFINE iFrecuencia		INTEGER;
	DEFINE cNom_rutina		CHAR(100);
	DEFINE dFechaUltimoArchivo	DATE;
	DEFINE cId_convenio		CHAR(5);
	DEFINE iTransacciones	INTEGER;
	DEFINE bFlag			BOOLEAN;
	DEFINE iDiferencia		INTEGER;
	DEFINE cSqlStmt			CHAR(200);
	
    LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cCodRetSP			= '99999';
	LET cMensajeSP			= 'ERROR';
	LET dFecha_Hoy			= DATE(1);
	LET cStatus				= '0';
	LET cNumCategoria		= '';
	LET cNumConvenio		= '';
	LET cStatusConvenio 	= '';
	LET iFrecuencia 		= 0;
	LET cNom_rutina 		= '';
	LET cId_convenio 		= '';
	LET iTransacciones 		= 0;
	LET bFlag 				= 'f';
	LET iDiferencia 		= 0;
	LET cSqlStmt 			= '';
	
	--SET DEBUG FILE TO  '/tmp/adrian/sp_conciliacion_bcpl_cpl_rep.out';
	--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_bcpl_cpl_rep");
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		--SE OBTIENE LA FECHA (ESTA PENSADO PARA QUE EL REPROCESO SEA GENERADO EL MISMO DIA QUE LA FECHA DE PROCESO ORIGINAL)
		SELECT {+INDEX(bdisac:"informix".sac_fechas idx_sac_fechas)} fecha_hoy 
		INTO dFecha_Hoy 
		FROM bdisac:"informix".sac_fechas;
		
		--LO PRIMERO QUE HARE ES BORRAR LOS DATOS QUE SE HABIAN GENERADO CON EL PROCESO ORIGINAL
		DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl
		WHERE fecha_insert = dFecha_Hoy;
		DELETE FROM bdisac:"informix".sac_conciliacion_bcpl_cpl_old
		WHERE fecha_insert = dFecha_Hoy;
		
		--AHORA ACTUALIZARE LOS QUE CONCILIO DE OTRAS FECHAS, A SU VEZ PASARE ESTOS REGISTROS DEL HISTORICO A LA TABLA DE TRABAJO
		INSERT INTO bdisac:"informix".sac_conciliacion_bcpl_cpl
		SELECT movimiento, tipomovimiento, importe, fechapago, tienda, numempleado, empresa, ciudad, descripcion, caja,
		       foliosucursal, numerotiket, contrato, campo1, campo2, campo3, campo4, campo5, campo6, campo7, campo8,
			   campo9, campo10, fecha_insert, st_conciliado, fecha_concil, nombre_archivo
		FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl_old
		WHERE  fecha_carga  = dFecha_Hoy;
		
		DELETE
		FROM   bdisac:"informix".sac_conciliacion_bcpl_cpl_old
		WHERE  fecha_carga  = dFecha_Hoy;
		
		UPDATE bdisac:"informix".sac_conciliacion_bcpl_cpl
		SET    fecha_concil  = NULL,
		       st_conciliado = 0
		WHERE  fecha_concil  = dFecha_Hoy
		AND    st_conciliado = 1;
		
		--VOLVERE LAS FECHAS PARA QUE ESTEN DISPONIBLES EN LOS ARCHIVOS DE COBRANZAS (SOLO AQUELLOS QUE SEAN ACORDES A ESTE PROCESO)
		FOREACH
		
			SELECT a.numcategoria, a.numconvenio
			INTO   cNumCategoria, cNumConvenio
			FROM   sac_servicios_cpl a
			WHERE  a.conciliacion = '1'
			
			UPDATE bdisac:"informix".sac_controlarchivoscobranza
			SET    fecha_ultimo_archivo = dFecha_Hoy - 1
			WHERE  numcategoria         = cNumCategoria
			AND    numconvenio			= cNumConvenio;
			
		END FOREACH;
		
		--GENERO EVIDENCIA DE LO ACTUALIZADO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_BORR'
					AND  fecha_proceso = dFecha_Hoy) THEN
			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_BORR', dFecha_Hoy, '1', 'informix',CURRENT);
		END IF;
		
		--VALIDAR SI YA SE EJECUTO LA CARGA DEL ARCHIVO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_CAR2'
					AND  fecha_proceso = dFecha_Hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_CAR2', dFecha_Hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_CAR2'
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
				WHERE TRIM(proceso) = 'CONCI_CAR2'
				AND  fecha_proceso = dFecha_Hoy;
			END IF;				
		END IF;
		
		LET cStatus = '0';

		--VALIDAR SI TERMINO DE MANERA CORRECTA LA CARGA DEL ARCHIVO (NUEVO INTENTO)
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_MOV2'
					AND  fecha_proceso = dFecha_hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_MOV2', dFecha_hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_MOV2'
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
				WHERE TRIM(proceso) = 'CONCI_MOV2'
				AND  fecha_proceso = dFecha_hoy;

				--VALIDAR ACTUALIZACION DE BITACORA
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					LET cMensaje = 'ERROR AL ACTUALIZAR LA BITACORA PARA CONCI_MOV2';
					RETURN cCodRet,cMensaje;
				END IF;
			END IF;
		END IF;
		
		--PROCESO EXTRAORDINARIO DE GENERACION DE ARCHIVOS DE COBRANZAS
		
		FOREACH
			
			SELECT  a.numcategoria, a.numconvenio, a.statusconvenio, a.frecnotificacion, TRIM(b.nom_rutina), b.fecha_ultimo_archivo
			INTO    cNumCategoria, cNumConvenio, cStatusConvenio, iFrecuencia, cNom_rutina, dFechaUltimoArchivo
			FROM    bdisac:sac_convenios a, bdisac:sac_controlarchivoscobranza b, sac_servicios_cpl c
			WHERE   a.numcategoria = b.numcategoria
			AND     a.numconvenio  = b.numconvenio
			AND     a.numcategoria = c.numcategoria
			AND     a.numconvenio  = c.numconvenio
			AND     c.conciliacion = '1'

			LET cId_convenio = cNumCategoria || cNumConvenio ;
			LET iDiferencia = ((dFecha_Hoy::DATE) - (dFechaUltimoArchivo::DATE));

			IF iDiferencia >= iFrecuencia THEN
				IF cStatusConvenio = 'I' THEN

					SELECT COUNT(id_sucursal)
					INTO   iTransacciones
					FROM   sac_movimientoshistorial
					WHERE  numcategoria = cNumCategoria
					AND    numconvenio  = cNumConvenio
					AND    fecha_pago   > dFechaUltimoArchivo;

					IF iTransacciones > 0 THEN
						LET bFlag = 't';
					END IF;
				END IF;

				IF cStatusConvenio = 'A' OR bFlag = 't' THEN

					LET cSqlStmt = 'echo "EXECUTE PROCEDURE bdisac:'||TRIM(cNom_rutina)||"('"||cId_convenio||''');" > /tmp/cobr.sql';
					SYSTEM cSqlStmt;
					LET cSqlStmt  = 'dbaccess bdisac /tmp/cobr.sql';
					SYSTEM cSqlStmt;

					--SELECT retorno
					--INTO cCodRet
					--FROM sac_controlarchivoscobranza
					--WHERE numcategoria = cNumCategoria
					--AND numconvenio = cNumConvenio;

					--IF CAST(trim(cCodRet) AS INTEGER) <> 0 THEN
					--    RETURN cCodRet;
					--END IF;


				END IF;
			END IF;

			LET bFlag = 'f';

		END FOREACH;
		
		LET cSqlStmt = 'rm -f /tmp/cobr.sql';
		SYSTEM cSqlStmt;
		
		--GUARDO EVIDENCIA DE LA GENERACION DE LOS ARCHIVOS DE COBRANZAS
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_COBR'
					AND  fecha_proceso = dFecha_hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_COBR', dFecha_hoy, '1', 'informix',CURRENT);
			
		END IF;
		
		--INTEGRO FINALMENTE A HISTORICO
		EXECUTE PROCEDURE bdisac:"informix".sp_inicializatablas_concbcpl('HIST',dFecha_Hoy)
		INTO cCodRetSP, cMensaje;
		
		IF cCodRetSP <> '00000' THEN
			LET cCodRet = cCodRetSP;
			LET cMensaje = "IMPOSIBLE INTEGRAR A HISTORICO";
			RETURN cCodRet, cMensaje;
		END IF;
        
        RETURN cCodRet,cMensaje;
    END;
END PROCEDURE
;
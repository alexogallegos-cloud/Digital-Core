CREATE PROCEDURE "informix".sp_guardarrestauracion(piIdSolicitud INT, pcUsuario CHAR(80), piCveAplicacion INT, piTiempoSolicitado INT, pdFechaInicio DATE, pdFechaFin DATE, 
pcEstatus CHAR(1), pcOnLine CHAR(1), pcUser CHAR(10))
	RETURNING CHAR(5) AS Retorno, CHAR(100) AS DescError, INT AS Solicitud;
		
	/*
	*****************************************************************************************************
	-- DESCRIPCION:  Guarda las restauraciones configuradas ---------------------------------------------
	-- AUTOR : Walber Castro ----------------------------------------------------------------------------
	-- FECHA : 04/10/2012  ------------------------------------------------------------------------------
	-- BD: bdiresp  -------------------------------------------------------------------------------------	
	-----------------------------------------------------------------------------------------------------
	*****************************************************************************************************
	-- MODIFICACIÓN: Se modificó el formato de fechas del nombre del archivo en base a su periodicidad,
	-- Se eliminaron las referencias a la BD bdiresp de los sp's propios de esta.
	-- Se cambió el proceso de restauración de meses a dias.
	-- AUTOR: Moisés Soriano
	-- FECHA : 26/02/2013
	-- BD: bdiresp
	*/
	
	DEFINE viCodigo						INT;
	DEFINE viCodigo2					INT;
	DEFINE vcCodRet						CHAR(5);
	DEFINE vcCodRet2					CHAR(5);	
	DEFINE vcDescRet					CHAR(100);
	DEFINE vcDescRet2					CHAR(100);
	DEFINE viIdInsertado 				INT;
	DEFINE viCveAplicacionTmp 			INT;
	DEFINE vcEnLinea 					CHAR(1);	
	DEFINE vdFechaInicio_Actual 		DATE;
	DEFINE vdFechaFin_Actual 			DATE;
	DEFINE viTiempoSolicitado_Actual	INT;
	DEFINE viIdSolicitud_Actual 		INT;
	DEFINE vcEstatus 					CHAR(1);
	DEFINE viTiempoMaximo 				INT;
	DEFINE vcEnTrans 					CHAR(1);
	DEFINE viCveAplicacion 				INT;
	DEFINE vdFechaInicio_Ant 			DATE;
	DEFINE vdFechaFin_Ant 				DATE;
	DEFINE vdFechaSol 					DATE;	
	DEFINE vcStatusTabla 				CHAR(1);
	DEFINE vcTabla						CHAR(30);
	DEFINE vcBaseDeDatos 				CHAR(20);	
	DEFINE vcRuta 						CHAR(100);
	DEFINE vcNomArchivo 				CHAR(50);
	DEFINE viSecRest 					INT;
	DEFINE viSecBorr 					INT;
	DEFINE vcPeriodicidad 				CHAR(1);
	DEFINE vcNomArchivoTMP 				CHAR(50);
	DEFINE vcModificado					CHAR(1);
	DEFINE vcUsuario					CHAR(80);
	
	LET vcDescRet2 					= 	'';
	LET vcBaseDeDatos 				= 	'';
	LET vcTabla 					= 	'';
	LET vcRuta 						= 	'';
	LET vcNomArchivo 				= 	'';
	LET viSecRest 					= 	0;
	LET viSecBorr 					= 	0;
	LET vcPeriodicidad 				= 	'';
	LET vcNomArchivoTMP 			= 	'';		
	LET viCodigo					= 	0;
	LET vcCodRet					= 	'00000';
	LET vcCodRet2					= 	'00000';
	LET vcDescRet					= 	'';
	LET viIdInsertado 				= 	0;
	LET viCveAplicacionTmp 			= 	0;
	LET vcEnLinea 					= 	'';	
	LET vdFechaInicio_Actual 		= 	'01-01-1900';
	LET vdFechaFin_Actual 			= 	'01-01-1900';
	LET viTiempoSolicitado_Actual	=	0;
	LET viIdSolicitud_Actual 		= 	0;
	LET vcEstatus 					= 	'';
	LET viTiempoMaximo 				= 	0;
	LET vcEnTrans 					= 	'0';
	LET viCveAplicacion 			= 	piCveAplicacion;
	LET vdFechaInicio_Ant 			= 	'01-01-1900';
	LET vdFechaFin_Ant 				= 	'01-01-1900';
	LET vcStatusTabla 				= 	'0';
	LET vdFechaSol 					= 	TODAY;
	LET viCodigo2					=	0;
	LET vcModificado				=	'0';
	LET vcUsuario					=	'';
	
	BEGIN

	ON EXCEPTION SET viCodigo
		IF viCodigo <> 0 THEN
			LET vcCodRet = viCodigo;
		END IF;
		IF( vcEnTrans = '1' ) THEN
			ROLLBACK WORK;
		END IF;
		IF ( NVL(piIdSolicitud,0) = 0  ) THEN
			--LOG DE ERRORES
			EXECUTE PROCEDURE sp_insertaLog(4000, 'REGISTRO DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarRestauracion(' || NVL(piIdSolicitud,'NULL') || ',' || NVL(pcUsuario,'NULL') || ',' || NVL(piCveAplicacion,'NULL') || ',' || NVL(piTiempoSolicitado,'NULL') || ',' || NVL(pdFechaInicio,'NULL') || ',' || NVL(pdFechaFin,'NULL') || ',' || NVL(pcEstatus,'NULL') || ',' || NVL(pcOnLine,'NULL') || ',' || NVL(pcUser,'NULL') ) INTO viCodigo2, vcDescRet2;
		ELSE
			IF ( TRIM(NVL(pcEstatus,'')) = '3' ) THEN
				--LOG DE ERRORES
				EXECUTE PROCEDURE sp_insertaLog(4002, 'CANCELACIÓN DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarRestauracion(' || NVL(piIdSolicitud,'NULL') || ',' || NVL(pcUsuario,'NULL') || ',' || NVL(piCveAplicacion,'NULL') || ',' || NVL(piTiempoSolicitado,'NULL') || ',' || NVL(pdFechaInicio,'NULL') || ',' || NVL(pdFechaFin,'NULL') || ',' || NVL(pcEstatus,'NULL') || ',' || NVL(pcOnLine,'NULL') || ',' || NVL(pcUser,'NULL') ) INTO viCodigo2, vcDescRet2;
			ELSE
				--LOG DE ERRORES
				EXECUTE PROCEDURE sp_insertaLog(4001, 'EDICIÓN DE RESTAURACIÓN', '', "Informix", 3, 'ERROR ' || viCodigo || ' AL EJECUTAR EL SP sp_guardarRestauracion(' || NVL(piIdSolicitud,'NULL') || ',' || NVL(pcUsuario,'NULL') || ',' || NVL(piCveAplicacion,'NULL') || ',' || NVL(piTiempoSolicitado,'NULL') || ',' || NVL(pdFechaInicio,'NULL') || ',' || NVL(pdFechaFin,'NULL') || ',' || NVL(pcEstatus,'NULL') || ',' || NVL(pcOnLine,'NULL') || ',' || NVL(pcUser,'NULL') ) INTO viCodigo2, vcDescRet2;
			END IF;
		END IF;
		RETURN NVL(vcCodRet,''),NVL(vcDescRet,''), 0;
	END EXCEPTION;	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF ( TRIM(NVL(pcEstatus,'')) <> '3' ) THEN
	
		EXECUTE PROCEDURE sp_validaCadena(pcUsuario,'1','0',' ') INTO vcCodRet2;
		
		IF ( TRIM(NVL(vcCodRet2,'')) != '00000' ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, USUARIO INVÁLIDO (PARÁMETRO 2)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( NVL(piCveAplicacion,0) <= 0 ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, CVE APLICACIÓN INVÁLIDA (PARÁMETRO 3)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( NOT EXISTS(SELECT cve_aplicacion FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion)) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, LA CVE APLICACIÓN NO EXISTE (PARÁMETRO 3)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( NVL(piTiempoSolicitado,0) = 0 ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, TIEMPO SOLICITADO INVÁLIDO (PARÁMETRO 4)';
			RETURN vcCodRet, vcDescRet, 0;
		ELSE
			SELECT NVL(tiempo_max_sol,0) INTO viTiempoMaximo FROM "informix".rp_aplicaciones WHERE cve_aplicacion = piCveAplicacion;
			IF ( piTiempoSolicitado > viTiempoMaximo ) THEN
				LET vcCodRet = '00001';
				LET vcDescRet = 'ERROR, EL TIEMPO SOLICITADO EXCEDE EL TIEMPO MÁXIMO PARA LA APLICACIÓN (PARÁMETRO 4)';
				RETURN vcCodRet, vcDescRet, 0;
			END IF;
		END IF;	
		
		IF ( pdFechaInicio IS NULL ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, FECHA INICIO INVÁLIDA (PARÁMETRO 5)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( pdFechaFin IS NULL ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, FECHA FIN INVÁLIDA (PARÁMETRO 6)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( TRIM(NVL(pcEstatus,'')) != '0' AND TRIM(NVL(pcEstatus,'')) != '1' AND TRIM(NVL(pcEstatus,'')) != '2' AND TRIM(NVL(pcEstatus,'')) != '3' ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, ESTATUS INVÁLIDO (PARÁMETRO 7)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
		
		IF ( TRIM(NVL(pcOnLine,'')) != '0' AND TRIM(NVL(pcOnLine,'')) != '1' ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, BANDERA ONLINE INVÁLIDA (PARÁMETRO 8)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
	ELSE
		IF ( NVL(piIdSolicitud,0) = 0 ) THEN
			LET vcCodRet = '00001';
			LET vcDescRet = 'ERROR, ID SOLICITUD INVÁLIDA (PARÁMETRO 1)';
			RETURN vcCodRet, vcDescRet, 0;
		END IF;
	END IF;
	
	IF ( TRIM(NVL(pcUser,'')) = '' ) THEN
		LET pcUser = 'Informix';
	END IF;
	BEGIN WORK;
	LET vcEnTrans = '1';
	IF ( NVL(piIdSolicitud,0) = 0 ) THEN
		
		INSERT INTO "informix".rp_restauraciones (usuario_solicitud, fecha_solicitud, cve_aplicacion, tiempo_solicitado, fecha_inicio, fecha_fin, status, on_line, user_insert, fecha_insert)
		VALUES(TRIM(NVL(pcUsuario,'')), CURRENT YEAR TO SECOND, piCveAplicacion, piTiempoSolicitado, pdFechaInicio, pdFechaFin, '0', TRIM(NVL(pcOnLine,'')), TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
		LET viIdInsertado = dbinfo('sqlca.sqlerrd1');

		IF ( viIdInsertado > 0 ) THEN
			WHILE viCveAplicacion <> 0 --CICLO PARA CONSULTAR LAS TABLAS DE LA APLICACIÓN SOLICITADA, ASÍ COMO LAS DEPENDIENTES
				EXECUTE PROCEDURE sp_consultaPeriodicidad(viCveAplicacion) INTO vcCodRet2, vcDescRet2, vcPeriodicidad;
				IF ( TRIM(NVL(vcCodRet2,'')) = '00000' AND ( TRIM(NVL(vcPeriodicidad,'')) = 'D' OR TRIM(NVL(vcPeriodicidad,'')) = 'M' ) ) THEN
					FOREACH		
						SELECT base_de_datos, tabla, ruta, estructura_nom_archivo, sec_restauracion, sec_borrado
						INTO vcBaseDeDatos, vcTabla, vcRuta, vcNomArchivo, viSecRest, viSecBorr
						FROM "informix".rp_tabla_aplicacion
						WHERE cve_aplicacion = viCveAplicacion AND ind_restauracion = '1'
						
						LET vdFechaInicio_Actual = pdFechaInicio;
						IF ( NVL(vcPeriodicidad,'') = 'M') THEN
							LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
						ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN					
							LET vdFechaFin_Actual = vdFechaInicio_Actual;
						END IF;
						LET vcNomArchivoTMP = TRIM(NVL(vcNomArchivo,''));
								
						WHILE vdFechaInicio_Actual <= pdFechaFin	--CICLO PARA INSERTAR LAS TABLAS MES POR MES O DÍA POR DÍA
							
							--Aqui se le concatena la fecha al nombre del archivo
							-- Si la periodicidad es = M se le asigna solo año y mes, si es = D se le asigna, año mes y dia
						IF ( NVL(vcPeriodicidad,'') = 'M') THEN
							LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0');
						ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN					
							LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') || LPAD(DAY(vdFechaFin_Actual),2,'0');
						END IF;
						
							--SE CONSULTA SI HAY TABLAS DE ALGUNA OTRA RESTAURACION QUE YA CONSIDEREN EL PERÍODO SOLICITADO
							SELECT {+INDEX(bdiresp:rp_tablas_restauradas idx_rptabresestatus)} t2.id_solicitud, t1.estatus
							INTO viIdSolicitud_Actual, vcStatusTabla
							FROM "informix".rp_tablas_restauradas t1 		
							INNER JOIN "informix".rp_restauraciones t2 ON (t1.id_solicitud = t2.id_solicitud)
							INNER JOIN "informix".rp_tabla_aplicacion t3 ON (t1.tabla = t3.tabla)
							WHERE t3.cve_aplicacion = viCveAplicacion AND t1.id_solicitud <> viIdInsertado AND t1.tabla = TRIM(NVL(vcTabla,'')) AND t1.nombre_archivo = TRIM(NVL(vcNomArchivo,''))
							AND t1.fecha_inicio = vdFechaInicio_Actual AND t1.fecha_fin = vdFechaFin_Actual AND t1.fecha_caducidad > TODAY AND t1.estatus IN ('0','1');
							
							IF ( DBINFO('sqlca.sqlerrd2') > 0 ) THEN
								LET vcStatusTabla = '2'; --SE ENCIENDE LA BANDERA DE TABLA DEPENDIENTE
								--SE ACTUALIZA LA FECHA DE CADUCIDAD SI ES QUE ES MENOR AL NUEVO TIEMPO SOLICITADO
								-- SE CAMBIÓ DE piTiempoSolicitado DE UNITS MONTH A UNITS DAY
								UPDATE "informix".rp_tablas_restauradas SET fecha_caducidad = vdFechaSol + (piTiempoSolicitado UNITS DAY)
								WHERE id_solicitud = viIdSolicitud_Actual AND TRIM(tabla) = TRIM(NVL(vcTabla,'')) AND TRIM(nombre_archivo) = TRIM(NVL(vcNomArchivo,''))
								AND fecha_caducidad < vdFechaSol + (piTiempoSolicitado UNITS DAY);
							ELSE
								LET vcStatusTabla = '0';
							END IF;
							
							INSERT INTO "informix".rp_tablas_restauradas (id_solicitud, base_de_datos, tabla, ruta, nombre_archivo, estatus, fecha_inicio, fecha_fin, fecha_caducidad, sec_restauracion, sec_borrado, fecha_restauracion, user_insert, fecha_insert)
							VALUES (viIdInsertado, TRIM(NVL(vcBaseDeDatos,'')), TRIM(NVL(vcTabla,'')), TRIM(NVL(vcRuta,'')), TRIM(NVL(vcNomArchivo,'')), TRIM(NVL(vcStatusTabla,'')), vdFechaInicio_Actual, vdFechaFin_Actual, vdFechaSol + piTiempoSolicitado UNITS DAY, viSecRest, viSecBorr, '1900-01-01 00:00:00.00000', TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
							
							IF ( NVL(vcPeriodicidad,'') = 'M') THEN
								LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS MONTH;
								LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
							ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
								LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS DAY;
								LET vdFechaFin_Actual = vdFechaInicio_Actual;
							END IF;
							
						END WHILE;
					END FOREACH;
				END IF;
					
				SELECT NVL(cve_dependencia,0) INTO viCveAplicacionTMP FROM "informix".rp_aplicaciones WHERE cve_aplicacion = viCveAplicacion;
				LET viCveAplicacion = NVL(viCveAplicacionTMP,0);
				
				IF ( viCveAplicacion > 0 ) THEN --SE REGISTRAN LAS DEPENDENCIAS DE LA APLICACIÓN
					INSERT INTO "informix".rp_restDependencias (id_solicitud, cve_aplicacion, estatus, user_insert, fecha_insert) VALUES(viIdInsertado, viCveAplicacion, '0', TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
				END IF;
				
			END WHILE;
			
			IF ( TRIM(NVL(pcOnLine,'')) = '0' ) THEN --SI LA SOLICITUD ES ONLINE
				--SE VERIFICA SI HAY ALGUNA RESTAURACION DE TIPO BATCH DE LA QUE DEPENDA LA NUEVA SOLICITUD		
				IF ( EXISTS(SELECT {+INDEX(bdiresp:rp_restauraciones 110_79)} t1.id_solicitud FROM "informix".rp_restauraciones t1
					INNER JOIN "informix".rp_tablas_restauradas t2 ON (t1.id_solicitud=t2.id_solicitud)
					WHERE t1.status = 0 AND t1.on_line = '1' AND t1.id_solicitud <> viIdInsertado AND t2.estatus = 0 AND TRIM(t2.nombre_archivo) IN 
					(SELECT DISTINCT TRIM(nombre_archivo) FROM "informix".rp_tablas_restauradas WHERE id_solicitud = viIdInsertado AND estatus = 2)) ) THEN
					--SI ENCONTRÓ ALGUNA DE TIPO BATCH, SE ACTUALIZA A BATCH LA NUEVA SOLICITUD
					UPDATE "informix".rp_restauraciones SET on_line = '1' WHERE id_solicitud = viIdInsertado;
				END IF;
			END IF;
		ELSE
			LET vcCodRet = '00003';
			LET vcDescRet = 'ERROR, NO SE PUDO REGISTRAR LA RESTAURACIÓN';			
		END IF;
	ELSE --EDICIÓN DE LA SOLICITUD DE RESTAURACIÓN
		
		LET viIdInsertado = piIdSolicitud;
		SELECT TRIM(usuario_solicitud), TRIM(status), cve_aplicacion, tiempo_solicitado, fecha_inicio, fecha_fin, TRIM(on_line), NVL(fecha_solicitud,TODAY) 
		INTO vcUsuario, vcEstatus, viCveAplicacion, viTiempoSolicitado_Actual, vdFechaInicio_Ant, vdFechaFin_Ant, vcEnLinea, vdFechaSol
		FROM "informix".rp_restauraciones WHERE id_solicitud = piIdSolicitud;
		
		IF ( TRIM(NVL(vcEstatus,'')) = '1' ) THEN --SE VALIDA QUE TENGA STATUS ATENDIDA POR LO QUE SOLO PODRÁ MODIFICARSE EL TIEMPO DE RESTAURACIÓN
			If ( TRIM(NVL(pcEstatus,'')) = '3') THEN
				LET vcCodRet = '00003';
				LET vcDescRet = 'ERROR, LA SOLICITUD DE RESTAURACIÓN NO PUEDE SER CANCELADA PORQUE YA HA SIDO ATENDIDA';
			ELSE				
				IF ( viTiempoSolicitado_Actual > piTiempoSolicitado AND vdFechaSol + piTiempoSolicitado UNITS DAY < TODAY ) THEN
					LET vcCodRet = '00003';
					LET vcDescRet = 'ERROR, EL TIEMPO SOLICITADO YA NO ES VÁLIDO PARA ESTA SOLICITUD DE RESTAURACIÓN';
				ELSE
					UPDATE "informix".rp_restauraciones
					SET tiempo_solicitado = piTiempoSolicitado, user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND
					WHERE id_solicitud = piIdSolicitud;
					UPDATE "informix".rp_tablas_restauradas SET fecha_caducidad = vdFechaSol + piTiempoSolicitado UNITS DAY, user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND
					WHERE id_solicitud = piIdSolicitud AND estatus IN ('0','1');					
				END IF;
			END IF;
		ELIF ( TRIM(NVL(vcEstatus,'')) = '0' ) THEN --SI TIENE STATUS PENDIENTE SE PUEDE MODIFICAR EN SU TOTALIDAD
			IF ( TRIM(NVL(pcEstatus,'')) = '3') THEN
				FOREACH
					SELECT nombre_archivo INTO vcNomArchivo FROM "informix".rp_tablas_restauradas 
					WHERE id_solicitud = piIdSolicitud AND estatus = '0'
						
					UPDATE "informix".rp_tablas_restauradas SET estatus = '0', user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND 
					WHERE nombre_archivo = vcNomArchivo AND estatus = '2' AND fecha_restauracion = '1900-01-01 00:00:00'
					AND id_solicitud = (SELECT MIN(id_solicitud) FROM "informix".rp_tablas_restauradas
					WHERE nombre_archivo = vcNomArchivo AND estatus = '2' AND fecha_restauracion = '1900-01-01 00:00:00');
										
				END FOREACH;
				UPDATE "informix".rp_restauraciones SET status = TRIM(NVL(pcEstatus,'')), user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = piIdSolicitud;
				UPDATE "informix".rp_tablas_restauradas SET estatus = '4', user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = piIdSolicitud;
			ELSE
				IF ( viTiempoSolicitado_Actual > piTiempoSolicitado AND vdFechaSol + piTiempoSolicitado UNITS DAY < TODAY ) THEN
					LET vcCodRet = '00003';
					LET vcDescRet = 'ERROR, EL TIEMPO SOLICITADO YA NO ES VÁLIDO PARA ESTA SOLICITUD';
				ELSE
					IF ( viTiempoSolicitado_Actual <> piTiempoSolicitado ) THEN
						LET vcModificado = '1';
						UPDATE "informix".rp_restauraciones
						SET tiempo_solicitado = piTiempoSolicitado, user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND
						WHERE id_solicitud = piIdSolicitud;
						UPDATE "informix".rp_tablas_restauradas SET fecha_caducidad = vdFechaSol + piTiempoSolicitado UNITS DAY, user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND
						WHERE id_solicitud = piIdSolicitud AND estatus IN ('0','1');
					END IF;
					IF ( vcUsuario <> pcUsuario OR viCveAplicacion <> piCveAplicacion OR  vdFechaInicio_Ant <> pdFechaInicio OR vdFechaFin_Ant <> pdFechaFin OR vcEnLinea <> pcOnLine ) THEN
						LET vcModificado = '2';
						FOREACH
							SELECT nombre_archivo INTO vcNomArchivo FROM "informix".rp_tablas_restauradas 
							WHERE id_solicitud = piIdSolicitud AND estatus = '0'
						
							UPDATE "informix".rp_tablas_restauradas SET estatus = '0', user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND 
							WHERE nombre_archivo = vcNomArchivo AND estatus = '2' AND fecha_restauracion = '1900-01-01 00:00:00'
							AND id_solicitud = (SELECT MIN(id_solicitud) FROM "informix".rp_tablas_restauradas
							WHERE nombre_archivo = vcNomArchivo AND estatus = '2' AND fecha_restauracion = '1900-01-01 00:00:00');
										
						END FOREACH;
						UPDATE "informix".rp_restauraciones SET usuario_solicitud = TRIM(pcUsuario),
						cve_aplicacion = piCveAplicacion, on_line = TRIM(pcOnLine), fecha_inicio = pdFechaInicio, fecha_fin = pdFechaFin,
						user_insert = TRIM(NVL(pcUser,'')), fecha_insert = CURRENT YEAR TO SECOND WHERE id_solicitud = piIdSolicitud;						
						DELETE FROM "informix".rp_tablas_restauradas WHERE id_solicitud = piIdSolicitud;
						DELETE FROM "informix".rp_restDependencias WHERE id_solicitud = piIdSolicitud;
					END IF;
					
					IF ( vcModificado = '0' ) THEN
						LET vcCodRet = '00003';
						LET vcDescRet = 'ERROR, LA SOLICITUD NO HA SIDO MODIFICADA PARA SU EDICIÓN';
					ELIF ( vcModificado = '2') THEN
						WHILE viCveAplicacion <> 0 --CICLO PARA CONSULTAR LAS TABLAS DE LA APLICACIÓN SOLICITADA, ASÍ COMO LAS DEPENDIENTES
							EXECUTE PROCEDURE sp_consultaPeriodicidad(viCveAplicacion) INTO vcCodRet2, vcDescRet2, vcPeriodicidad;
							IF ( TRIM(NVL(vcCodRet2,'')) = '00000' AND ( TRIM(NVL(vcPeriodicidad,'')) = 'D' OR TRIM(NVL(vcPeriodicidad,'')) = 'M' ) ) THEN
								FOREACH		
									SELECT base_de_datos, tabla, ruta, estructura_nom_archivo, sec_restauracion, sec_borrado
									INTO vcBaseDeDatos, vcTabla, vcRuta, vcNomArchivo, viSecRest, viSecBorr
									FROM "informix".rp_tabla_aplicacion
									WHERE cve_aplicacion = viCveAplicacion AND ind_restauracion = '1'
									
									LET vdFechaInicio_Actual = pdFechaInicio;
									IF ( NVL(vcPeriodicidad,'') = 'M') THEN
										LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
									ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN					
										LET vdFechaFin_Actual = vdFechaInicio_Actual;
									END IF;
									LET vcNomArchivoTMP = TRIM(NVL(vcNomArchivo,''));					
											
									WHILE vdFechaInicio_Actual <= pdFechaFin	--CICLO PARA INSERTAR LAS TABLAS MES POR MES O DÍA POR DÍA
										
										IF ( NVL(vcPeriodicidad,'') = 'M') THEN
											LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') ;
										ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN					
											LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') || LPAD(DAY(vdFechaFin_Actual),2,'0');
										END IF;
										
										-- LET vcNomArchivo = TRIM(NVL(vcNomArchivoTMP,'')) || '_' || YEAR(vdFechaFin_Actual) || LPAD(MONTH(vdFechaFin_Actual),2,'0') || LPAD(DAY(vdFechaFin_Actual),2,'0');
										
										--SE CONSULTA SI HAY TABLAS DE ALGUNA OTRA RESTAURACION QUE YA CONSIDEREN EL PERÍODO SOLICITADO										
										SELECT t2.id_solicitud, t1.estatus
										INTO viIdSolicitud_Actual, vcStatusTabla
										FROM "informix".rp_tablas_restauradas t1 		
										INNER JOIN "informix".rp_restauraciones t2 ON (t1.id_solicitud = t2.id_solicitud)
										INNER JOIN "informix".rp_tabla_aplicacion t3 ON (t1.tabla = t3.tabla)
										WHERE t3.cve_aplicacion = viCveAplicacion AND t1.id_solicitud <> piIdSolicitud AND t1.tabla = TRIM(NVL(vcTabla,'')) AND t1.nombre_archivo = TRIM(NVL(vcNomArchivo,''))
										AND t1.fecha_inicio = vdFechaInicio_Actual AND t1.fecha_fin = vdFechaFin_Actual AND t1.fecha_caducidad > TODAY AND t1.estatus IN ('0','1');
										
										IF ( DBINFO('sqlca.sqlerrd2') > 0 ) THEN
											LET vcStatusTabla = '2'; --SE ENCIENDE LA BANDERA DE TABLA DEPENDIENTE
											--SE ACTUALIZA LA FECHA DE CADUCIDAD SI ES QUE ES MENOR AL NUEVO TIEMPO SOLICITADO
											UPDATE "informix".rp_tablas_restauradas SET fecha_caducidad = vdFechaSol + piTiempoSolicitado UNITS DAY
											WHERE id_solicitud = viIdSolicitud_Actual AND tabla = TRIM(NVL(vcTabla,'')) AND nombre_archivo = TRIM(NVL(vcNomArchivo,''))
											AND fecha_caducidad < vdFechaSol + piTiempoSolicitado UNITS DAY;
										ELSE
											LET vcStatusTabla = '0';
										END IF;
										
										INSERT INTO "informix".rp_tablas_restauradas (id_solicitud, base_de_datos, tabla, ruta, nombre_archivo, estatus, fecha_inicio, fecha_fin, fecha_caducidad, sec_restauracion, sec_borrado, fecha_restauracion, user_insert, fecha_insert)
										VALUES (piIdSolicitud, TRIM(NVL(vcBaseDeDatos,'')), TRIM(NVL(vcTabla,'')), TRIM(NVL(vcRuta,'')), TRIM(NVL(vcNomArchivo,'')), TRIM(NVL(vcStatusTabla,'')), vdFechaInicio_Actual, vdFechaFin_Actual, vdFechaSol + piTiempoSolicitado UNITS DAY, viSecRest, viSecBorr, '1900-01-01 00:00:00.00000', TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
										
										IF ( NVL(vcPeriodicidad,'') = 'M') THEN
											LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS MONTH;
											LET vdFechaFin_Actual = vdFechaInicio_Actual + 1 UNITS MONTH - 1 UNITS DAY;
										ELIF ( NVL(vcPeriodicidad,'') = 'D') THEN
											LET vdFechaInicio_Actual = vdFechaInicio_Actual + 1 UNITS DAY;
											LET vdFechaFin_Actual = vdFechaInicio_Actual;
										END IF;
										
									END WHILE;
								END FOREACH;
							END IF;
								
							SELECT NVL(cve_dependencia,0) INTO viCveAplicacionTMP FROM "informix".rp_aplicaciones WHERE cve_aplicacion = viCveAplicacion;
							LET viCveAplicacion = NVL(viCveAplicacionTMP,0);
							
							IF ( viCveAplicacion > 0 ) THEN --SE REGISTRAN LAS DEPENDENCIAS DE LA APLICACIÓN
								INSERT INTO "informix".rp_restDependencias (id_solicitud, cve_aplicacion, estatus, user_insert, fecha_insert) VALUES(piIdSolicitud, viCveAplicacion, '0', TRIM(NVL(pcUser,'')), CURRENT YEAR TO SECOND);
							END IF;
							
						END WHILE;
						
						IF ( TRIM(NVL(pcOnLine,'')) = '0' ) THEN --SI LA SOLICITUD ES ONLINE
							--SE VERIFICA SI HAY ALGUNA RESTAURACION DE TIPO BATCH DE LA QUE DEPENDA LA NUEVA SOLICITUD		
							IF ( EXISTS(SELECT {+INDEX(bdiresp:rp_restauraciones 110_79)} t1.id_solicitud FROM "informix".rp_restauraciones t1
								INNER JOIN "informix".rp_tablas_restauradas t2 ON (t1.id_solicitud=t2.id_solicitud)
								WHERE t1.status = 0 AND t1.on_line = '1' AND t1.id_solicitud <> piIdSolicitud AND t2.estatus = 0 AND TRIM(t2.nombre_archivo) IN 
								(SELECT DISTINCT TRIM(nombre_archivo) FROM "informix".rp_tablas_restauradas WHERE id_solicitud = piIdSolicitud AND estatus = 2)) ) THEN
								--SI ENCONTRÓ ALGUNA DE TIPO BATCH, SE ACTUALIZA A BATCH LA NUEVA SOLICITUD
								UPDATE "informix".rp_restauraciones SET on_line = '1' WHERE id_solicitud = piIdSolicitud;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		ELIF ( TRIM(NVL(vcEstatus,'')) = '2' ) THEN
			LET vcCodRet = '00003';
			LET vcDescRet = 'ERROR, LA SOLICITUD DE RESTAURACIÓN YA HA SIDO DEPURADA';
		ELIF ( TRIM(NVL(vcEstatus,'')) = '3' ) THEN
			LET vcCodRet = '00003';
			LET vcDescRet = 'ERROR, LA SOLICITUD DE RESTAURACIÓN ESTA CANCELADA';
		END IF;
	END IF;
	
	IF ( vcEnTrans = '1' ) THEN
		COMMIT WORK;
		LET vcEnTrans = '0';	
	END IF;
	RETURN vcCodRet, vcDescRet, viIdInsertado;
	END;
END PROCEDURE;